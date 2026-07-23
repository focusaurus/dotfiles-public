#!/usr/bin/env bash
#
# migrate-to-codecommit.sh
#
# Reads bare git directory paths on stdin, one per line, and mirrors each into
# AWS CodeCommit. Designed to run ON THE DROPLET where the bare repos live.
#
# Usage:
#   printf '%s\n' ~/projects/one.git ~/projects/two.git | ./migrate-to-codecommit.sh
#   ls -d ~/projects/*.git | ./migrate-to-codecommit.sh          # the whole batch
#   echo ~/projects/test.git | DRY_RUN=1 ./migrate-to-codecommit.sh
#
# Idempotency:
#   A repo is skipped (no-op) when its CodeCommit repository already exists AND
#   already has at least one branch. Set FORCE_PUSH=1 to push anyway (useful for
#   catching commits made during the grace period).
#
# SSH auth (User / IdentityFile) is left entirely to ~/.ssh/config for the
# git-codecommit host — nothing about the key is duplicated here.
#
# Env knobs:
#   REGION      AWS region                     (default: us-west-2)
#   CC_ENDPOINT CodeCommit ssh host            (default: derived from REGION)
#   DRY_RUN     print actions, change nothing   (default: unset)
#   FORCE_PUSH  push even if branches exist      (default: unset)
#   LOW_MEM     cap git packing memory so pack-objects doesn't get OOM-killed
#               on a small host (single-threaded, no delta search) (default: unset)

set -uo pipefail

REGION="${REGION:-us-west-2}"
CC_ENDPOINT="${CC_ENDPOINT:-git-codecommit.${REGION}.amazonaws.com}"
DRY_RUN="${DRY_RUN:-}"
FORCE_PUSH="${FORCE_PUSH:-}"
LOW_MEM="${LOW_MEM:-}"

# Packing knobs injected into `git push` when LOW_MEM is set. pack.window=0
# disables delta search (the memory-hungry part); the others keep a single
# thread and small caches. Trades a bigger upload for staying under the OOM line.
git_pack_opts=()
if [[ -n "$LOW_MEM" ]]; then
  git_pack_opts=(-c pack.threads=1 -c pack.windowMemory=64m \
                 -c pack.deltaCacheSize=64m -c pack.window=0)
fi

created=0 pushed=0 skipped=0 errors=0

log()  { printf '%s\n' "$*" >&2; }
run()  { if [[ -n "$DRY_RUN" ]]; then log "  DRY-RUN: $*"; else "$@"; fi; }

process_repo() {
  local path="$1"
  local name remote err branches

  # --- validate the local bare repo -------------------------------------
  if [[ ! -d "$path" ]]; then
    log "SKIP  $path : directory does not exist"; ((errors++)); return
  fi
  if ! git --git-dir="$path" rev-parse --git-dir >/dev/null 2>&1; then
    log "SKIP  $path : not a git repository"; ((errors++)); return
  fi
  if [[ -z "$(git --git-dir="$path" for-each-ref refs/heads 2>/dev/null)" ]]; then
    log "SKIP  $path : no local branches to push"; ((skipped++)); return
  fi

  name="$(basename "$path")"; name="${name%.git}"
  remote="ssh://${CC_ENDPOINT}/v1/repos/${name}"

  # --- does the CodeCommit repo already exist? --------------------------
  local exists=0
  if err="$(aws codecommit get-repository \
              --repository-name "$name" --region "$REGION" 2>&1)"; then
    exists=1
  elif grep -q 'RepositoryDoesNotExistException' <<<"$err"; then
    exists=0
  else
    log "ERROR $name : could not query CodeCommit:"; log "  $err"; ((errors++)); return
  fi

  # --- idempotency: repo exists AND already has branches → no-op --------
  if (( exists )); then
    branches="$(aws codecommit list-branches \
                  --repository-name "$name" --region "$REGION" \
                  --query 'branches' --output text 2>/dev/null)"
    if [[ -n "$branches" && "$branches" != "None" && -z "$FORCE_PUSH" ]]; then
      log "OK    $name : exists with branches, nothing to do"; ((skipped++)); return
    fi
  else
    log "NEW   $name : creating CodeCommit repository"
    if ! run aws codecommit create-repository \
               --repository-name "$name" --region "$REGION" \
               --repository-description "Migrated from git.peterlyons.com:${path}" \
               >/dev/null; then
      log "ERROR $name : create-repository failed"; ((errors++)); return
    fi
    ((created++))
  fi

  # --- push all branches and tags (git push is itself idempotent) -------
  log "PUSH  $name : $path -> $remote"
  if ! run git --git-dir="$path" ${git_pack_opts[@]+"${git_pack_opts[@]}"} push --all "$remote"; then
    log "ERROR $name : push --all failed"; ((errors++)); return
  fi
  # --tags is best-effort; a repo with no tags returns non-zero harmlessly.
  run git --git-dir="$path" ${git_pack_opts[@]+"${git_pack_opts[@]}"} push --tags "$remote" || true

  # --- verify the push landed -------------------------------------------
  if [[ -z "$DRY_RUN" ]]; then
    branches="$(aws codecommit list-branches \
                  --repository-name "$name" --region "$REGION" \
                  --query 'branches' --output text 2>/dev/null)"
    if [[ -z "$branches" || "$branches" == "None" ]]; then
      log "ERROR $name : push reported success but CodeCommit shows no branches"
      ((errors++)); return
    fi
    log "DONE  $name : branches on CodeCommit -> $branches"
  fi
  ((pushed++))
}

while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line#"${line%%[![:space:]]*}"}"   # ltrim
  line="${line%"${line##*[![:space:]]}"}"    # rtrim
  [[ -z "$line" || "$line" == \#* ]] && continue
  line="${line/#\~/$HOME}"                    # expand a leading ~
  process_repo "$line"
done

log "----------------------------------------"
log "created=$created  pushed=$pushed  skipped=$skipped  errors=$errors"
(( errors == 0 ))
