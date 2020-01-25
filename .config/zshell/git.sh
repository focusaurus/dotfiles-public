#!/usr/bin/env bash
##### git SCM #####
alias ga='git add'
# alias gassume='gitupdate-index --assume-unchanged'
# alias gassumed='!git ls-files -v | grep ^h | cut -c 3-'
alias gb='git branch -a'
alias gri='git rebase -i'
alias gf='git fetch'
alias gbd='git branch -d'
# alias gbl='git branch -a|less'
alias gc='git commit'
alias glone='git clone'
#git current branch
alias gr='git remote -v'
alias gfap='git fetch --all --prune'
alias gcb='git rev-parse --abbrev-ref HEAD'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcod='git checkout develop'
alias gcom='git checkout master'
alias gd='git diff --ignore-all-space'
alias gdc='git diff --ignore-all-space --cached'
#conflicts with graphicks-magic., use use full path to graphicsmagick when needed
alias gm='git merge'
alias gmnf='git merge --no-ff'
# alias gpg='git push github'
alias gpt='git push && git push --tags'
alias grpo='git remote prune origin'
alias gru='git remote update'
alias gs='git status --short'
alias gsnapshot='git stash save "snapshot: $(date)" && git stash apply "stash@{0}"'
alias gsu='git submodule update'
alias gull='git pull'
alias gp='git push'
alias gpu='git pull upstream'
# alias gunassume='git update-index --no-assume-unchanged'
alias gush='git push'
alias gphm='git push heroku master --tags'
alias gpr='hub pull-request'
alias enable-signed-git-commits='git config user.signingkey E205D5C6 && git config commit.gpgsign true'
alias undo-git-add="git reset"
alias undo-git-rm='git checkout HEAD'
alias gbmd="git branch --merged develop"
alias amend="git commit --amend"
alias git-not-pushed="git log --branches --not --remotes"

_base-url() {
  # shellcheck disable=SC2016
  git remote -v |
    awk '{print $2}' |
    sort |
    uniq |
    grep -E 'github\.com' |
    head -1 |
    sed -e 's_:_/_' -e 's_^\s*git@_https://_' -e 's_\.git$__'
}

gh() {
  subcommand="$1"
  shift
  case "${subcommand}" in
  clone)
    local url
    local org
    local repo
    url="${1:-$(~/bin/paste)}"
    org_repo=$(echo "${url}" | sed 's/.*github\.com.//')
    org="$(echo "${org_repo}" | cut -d / -f 1)"
    repo="$(echo "${org_repo}" | cut -d / -f 2)"
    echo "${org}"
    echo "${repo}"
    mkdir -p "${HOME}/github/${org}"
    cd "${HOME}/github/${org}" || return 1
    git clone "${url}"
    cd "$(basename "${repo}" .git)" || return 1
    ;;
  commits)
    xdg-open "$(_base-url)/commits"
    ;;
  issues)
    xdg-open "$(_base-url)/issues"
    ;;
  pr-description)
    git log '--pretty=format:%s%n%b' "$(git-get-default-branch)..HEAD" | grep -Ev Signed-off-by
    ;;
  pull-requests)
    xdg-open "$(_base-url)/pulls"
    ;;
  repo)
    xdg-open "$(_base-url)"
    ;;
  *)
    echo "Unknown subcommand"
    return 1
    ;;

  esac
}

gh-pr-description() {
  git log '--pretty=format:%s%n%b' "$(git-get-default-branch)..HEAD" | grep -Ev Signed-off-by
}

#git tag version
gtv() {
  git tag "v$(node --print --eval 'require("./package.json").version')"
}

# gmup and gmdown are for managing a file naming scheme with numeric
# prefixes for ordering like:
# 001-intro
# 002-chapter
# 003-appendix
# they allow adding/removing/re-ordering and adjusting the filenames
gmup() {
  local number
  number=$(echo "$1" | grep -Eo "^\d+")
  local suffix
  suffix=$(echo "$1" | grep -Eo "\-.*")
  local next
  next=$((number + 1))
  local target
  target=$(printf "%02d${suffix}" "${next}")
  if [[ -e "${target}" ]]; then
    echo "Error ${target} exists" 1>&2
    return 1
  fi
  git mv "$1" "${target}"
}

gmdown() {
  local number
  number=$(echo "$1" | grep -Eo "^\d+")
  local suffix
  suffix=$(echo "$1" | grep -Eo "\-.*")
  local next
  next=$((number - 1))
  local target
  target=$(printf "%02d${suffix}" "${next}")
  if [[ -e "${target}" ]]; then
    echo "Error ${target} exists" 1>&2
    return 1
  fi
  git mv "$1" "${target}"
}

github-repo() {
  # shellcheck disable=SC2016
  xdg-open "$(git remote -v |
    awk '{print $2}' |
    sort |
    uniq |
    grep -E 'github\.com' |
    head -1 |
    sed -e 's_:_/_' -e 's_^\s*git@_https://_' -e 's_\.git$__')"
}

#git delete remote branches
gdrb() {
  local branch=$1
  local remote
  remote=$(git remote -v | grep push | awk '{print $1}' | fuzzy-filter "$2")
  echo -n "Deleting ${branch} from ${remote}. ENTER to do it. CTRL-c to abort."
  # shellcheck disable=SC2034
  read -r confirm
  git push "${remote}" --delete --no-verify "${branch}"
}

#git push same branch
gpsb() {
  git push --set-upstream origin "$(gcb)"
}

#git commit all with message
gcam() {
  git commit -a -m "${*}"
}

#git merge develop
gmd() {
  local BRANCH
  BRANCH=$(gcb)
  git checkout develop
  git merge --no-ff "${BRANCH}"
  return "${BRANCH}"
}

#git merge develop then delete
gmdd() {
  local BRANCH
  BRANCH=$(gcb)
  gmd
  git branch -d "${BRANCH}"
}

gcbd() {
  git checkout -b "${1}" develop
}

gmmd() {
  local BRANCH
  BRANCH=$(gcb)
  git checkout master
  git merge --no-ff "${BRANCH}"
  git branch -d "${BRANCH}"
}

gcbm() {
  git checkout -b "${1}" master
}

# Save a stash for just-in-case reference, but immediately apply it
# so your working directory stays unchanged
gash() {
  local name
  name="trash-$(date +%Y-%m-%dT%H:%M:%S)"
  git stash save --include-untracked "${name}"
  git stash apply 'stash@{0}'
}

alias gitlog='git log --pretty=oneline --abbrev-commit --branches=\* --graph --decorate'
#git release notes for weekly sprints
alias grn='git log "--since=8 days ago" --reverse'

gmmd() {
  local BRANCH
  BRANCH="$(gcb)"
  git checkout master
  git merge --no-ff "${BRANCH}"
  git branch -d "${BRANCH}"
}

cdr() {
  cd "$(git rev-parse --show-toplevel)" || return
}

new-git-project() {
  local REPO="${1}"
  local GIT=git.peterlyons.com
  # shellcheck disable=SC2029
  ssh "${GIT}" git init --bare "projects/${REPO}.git"
  cd ~/projects || return 1
  git clone "ssh://${GIT}/home/plyons/projects/${REPO}.git" "${REPO}"
  cd "${REPO}" || return 1
}

plgc() {
  cd ~/projects || exit
  git clone "ssh://git.peterlyons.com/home/plyons/projects/${1}.git"
}

commits-by-year() {
  local first_hash
  first_hash=$(git rev-list --max-parents=0 HEAD)
  local start_year
  start_year=$(git log --format=%ai "${first_hash}" | cut -d - -f 1)
  local end_year
  end_year=$(git log -n 1 --format=%ai | cut -d - -f 1)
  for year in $(seq "${start_year}" "${end_year}"); do
    echo -en "${year}:\t"
    git log --since="${year}-01-01" --until="$((year + 1))-01-01" --no-merges --pretty=oneline | wc -l
  done
}

git-cleanup-merged-branches() {
  git fetch --quiet --all
  git remote | {
    while IFS= read -r remote; do
      git remote prune "${remote}"
    done
  }
  working_branch=$(git rev-parse --abbrev-ref HEAD)
  # Adapted from https://stackoverflow.com/a/6127884/266795
  git branch --format '%(refname:short)' --merged |
    grep -Ev "^(master|develop|release-latest|dev|next|trunk)" |
    grep -Ev "^${working_branch}\$" |
    xargs --no-run-if-empty git branch --delete
}

git-ztrash() {
  # I use this to keep a branch around but indicate it's in the trash can
  # "z" prefix pushes it to the bottom of sorted listings
  local name
  name="$1"
  name=$(git branch | awk '{print $NF}' | fuzzy-filter "$@")
  [[ -z "${name}" ]] && return
  git branch -m "${name}" "ztrash-${name}"
}

git-diff-side-by-side() {
  local file
  file=$(git ls-files -m | fuzzy-filter "$@")
  [[ -z "${file}" ]] && return
  git show "HEAD:${file}" | icdiff /dev/stdin "${file}" | less -R
}

git-get-repos() {
  if [[ -z "${GITHUB_TOKEN}" ]]; then
    echo "Set GITHUB_TOKEN using repo access token" 1>&2
    return 1
  fi
  organization="${1:-reactioncommerce}"
  dir="${HOME}/work-reaction/github-repo-data"
  mkdir -p "${dir}"
  opts=(--silent --fail --show-error --user "focusaurus:${GITHUB_TOKEN}")
  for p in $(seq 5); do
    url="https://api.github.com/orgs/${organization}/repos?page=${p}&sort=updated&direction=descending"
    curl "${opts[@]}" "${url}" >"${dir}/${organization}-repos-$(printf '%02d' "${p}").json"
  done
}

git-checkout() {
  git fetch --quiet --all
  local name="$1"
  name=$(git branch -a | grep -Ev '\*' | sed 's,remotes/.*/,,' | tr -d " " | fuzzy-filter "${name}")
  [[ -z "${name}" ]] && return
  local first_origin
  first_origin=$(git remote | head -1)
  default_branch=$(git-get-default-branch)
  git checkout "${name}" 2>/dev/null || git checkout -b "${name}" "${first_origin}/${default_branch}"
}

dotfiles-begin() {
  export GIT_DIR="${HOME}/.home.git" GIT_WORK_TREE="${HOME}"
}

dotfiles-end() {
  unset GIT_DIR GIT_WORK_TREE
}
