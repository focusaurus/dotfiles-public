##### git SCM #####
function ensure_ssh_agent() {
  echo ensure_ssh_agent start
  if ssh-add -L | grep --quiet "no identities"; then
    echo ensure_ssh_agent add
    op-add-ssh-key
    return
  fi
  echo ensure_ssh_agent nope
}
alias g='lazygit'
# alias g='gitui'
alias ga='git add'
# alias gassume='gitupdate-index --assume-unchanged'
# alias gassumed='!git ls-files -v | grep ^h | cut -c 3-'
alias gb='git branch -a'
alias gri='git rebase -i'
alias gfom='git fetch origin main'
alias griom='git rebase -i origin/main'
alias grium='git rebase -i upstream/main'
alias gick='git cherry-pick'
alias gpum='git pull upstream main'
alias gpom='git pull origin main'
alias gpgm='git pull github main'
alias gPom='git push origin main'
alias gPgm='git push github main'
alias gf='git fetch --all'
alias gbd='git branch -d'
# alias gbl='git branch -a|less'
alias gc='git commit'
alias glone='git clone'
# alias gr='git remote -v'
# alias gfap='git fetch --all --prune'
#git current branch
alias gcb='git rev-parse --abbrev-ref HEAD'
# alias gco='git checkout'
# alias gcob='git checkout -b'
# alias gcot='git checkout --track'
alias gwmain='git switch main'
alias gore='git restore'
alias gd='git diff --ignore-all-space HEAD'
#conflicts with graphicks-magic., use use full path to graphicsmagick when needed
alias gm='git merge'
# alias gmnf='git merge --no-ff'
# alias gpg='git push github'
# alias gpt='git push && git push --tags'
alias grpo='git remote prune origin'
# alias gru='git remote update'
alias gs='git status --short'
# alias gsnapshot='git stash save "snapshot: $(date)" && git stash apply "stash@{0}"'
# alias gsu='git submodule update'
alias gull='git pull || ensure_ssh_agent'
alias gush='git push || ensure_ssh_agent'
# alias gP='git push'
# alias gpu='git pull upstream'
# alias gunassume='git update-index --no-assume-unchanged'
# alias gushup='git push --set-upstream'
alias gpr='hub pull-request'
alias enable-signed-git-commits='git config user.signingkey E205D5C6 && git config commit.gpgsign true'
alias undo-git-add="git reset"
alias undo-git-rm='git checkout HEAD'
alias gbmd="git branch --merged develop"
alias gamend="git commit --amend --no-edit"
alias git-not-pushed="git log --branches --not --remotes"
alias gls="git ls-files"
alias gw="git switch"
alias gwc="git switch --create"
alias gorce="git push --force-with-lease"
alias ts="tig status"
alias gD="git branch -D"

_base-url() {
  # heads up. Depends on a slightly obscure utility
  # https://github.com/sgreben/url
  # shellcheck disable=SC2016
  remotes=$(git remote -v)
  if [[ "${remotes}" =~ upstream ]]; then
    # If a remote named upstream exists, it's probably what we want
    remotes=$(echo "${remotes}" | grep upstream)
  elif [[ "${remotes}" =~ origin ]]; then
    # Otherwise, if a remote named origin exists, it's probably what we want
    remotes=$(echo "${remotes}" | grep origin)
  fi
  # Otherwise we're not sure so we take the first sorted one/shrug
  # shellcheck disable=SC2016
  echo "${remotes}" |
    awk '{print $2}' |
    sort |
    uniq |
    head -1 |
    sed -e 's_^git@_ssh://git@_' -e 's_github\.com:_github.com/_' -e 's_\.git$__' |
    xargs url -p -set-scheme https
}

github() {
  subcommand="$1"
  shift
  case "${subcommand}" in
  clone)
    repo_any_url="$1"
    if [[ -z "${repo_any_url}" ]]; then
      repo_any_url=$(~/bin/prompt-or-clipboard "Github Repo URL")
    fi
    local org
    local repo
    if [[ "${repo_any_url}" =~ ^https: ]]; then
      # parse https url
      local repo_base_url
      repo_base_url=$(echo "${repo_any_url}" | cut -d / -f 1-5)
      ~/bin/log "$0" "${repo_base_url}"
      if [[ ! "${repo_base_url}" =~ \.git$ ]]; then
        repo_base_url="${repo_base_url}.git"
      fi
      org="$(echo "${repo_base_url}" | cut -d / -f 4)"
      repo="$(echo "${repo_base_url}" | cut -d / -f 5)"
    else
      # parse ssh url
      repo_base_url="${repo_any_url}"
      org="$(echo "${repo_any_url}" | cut -d : -f 2 | cut -d / -f 1)"
      repo="$(echo "${repo_any_url}" | cut -d : -f 2 | cut -d / -f 2)"
      # repo="${repo/.git/}"
    fi
    echo "org: ${org}"
    echo "repo: ${repo}"
    mkdir -p "${HOME}/github.com/${org}"
    cd "${HOME}/github.com/${org}" || return 1
    git clone --recursive "${repo_base_url}"
    cd "$(basename "${repo}" .git)" || return 1
    ;;
  commits)
    ~/bin/open "$(_base-url)/commits"
    ;;
  issues)
    ~/bin/open "$(_base-url)/issues"
    ;;
  pr-description)
    git log --reverse '--pretty=format:%s%n%b' "$(git-get-default-branch)..HEAD" |
      grep --extended --invert-match '(Signed-off-by|Merge branch)'
    ;;
  pull-requests)
    ~/bin/open "$(_base-url)/pulls"
    ;;
  repo)
    ~/bin/open "$(_base-url)"
    ;;
  *)
    echo "Unknown subcommand"
    return 1
    ;;

  esac
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
gPsb() {
  git push --set-upstream origin HEAD
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
  git checkout main
  git merge --no-ff "${BRANCH}"
  git branch -d "${BRANCH}"
}

gcbm() {
  git checkout -b "${1}" main
}

# Save a stash for just-in-case reference, but immediately apply it
# so your working directory stays unchanged
gash() {
  local name
  name="snapshot-$(date +%Y-%m-%dT%H:%M:%S)-$1"
  git stash save --include-untracked "${name}"
  git stash apply 'stash@{0}'
}

alias gitlog='git log --pretty=oneline --abbrev-commit --branches=\* --graph --decorate'
#git release notes for weekly sprints
# alias grn='git log "--since=8 days ago" --reverse'

gmmd() {
  local BRANCH
  BRANCH="$(gcb)"
  git checkout main
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
  # ssh "${GIT}" git init --bare --initial-branch=main "projects/${REPO}.git"
  ssh "${GIT}" git init --bare "projects/${REPO}.git"
  cd ~/projects || return 1
  git clone "ssh://${GIT}/home/plyons/projects/${REPO}.git" "${REPO}"
  cd "${REPO}" || return 1
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

git-ztrash() {
  # I use this to keep a branch around but indicate it's in the trash can
  # "z" prefix pushes it to the bottom of sorted listings
  local name
  name="$1"
  name=$(git branch | awk '{print $NF}' | grep -v 'ztrash' | fuzzy-filter "$@")
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

git-switch-fuzzy() {
  local name="$1"
  name=$(git branch | grep -Ev '\*' | fuzzy-filter "${name}")
  [[ -z "${name}" ]] && return
  git switch "${name}"
}

git-repo-path() {
  git rev-parse --show-prefix
}

dotfiles-begin() {
  export GIT_DIR="${HOME}/.home.git" GIT_WORK_TREE="${HOME}"
}

dotfiles-end() {
  unset GIT_DIR GIT_WORK_TREE
}

dotfiles-git() {
  dotfiles-begin
  cd
  lazygit
  dotfiles-end
  cd -
}

alias dfb="dotfiles-begin"
alias dfe="dotfiles-end"
alias dfg="dotfiles-git"

dotfiles-ignore() {
  (
    dotfiles-begin
    cd || exit
    git status --short | grep '^??' | cut -d ' ' -f 2- | {
      while IFS= read -r file_path; do
        echo -n "Ignore ${file_path}? y/n"
        read -r -q response
        echo
        if [[ "${response}" == "y" ]]; then
          echo "/${file_path}" >>.gitignore
        fi
      done
    }
  )
}

dotfiles-search() {
  GIT_DIR="${HOME}/.home.git" git ls-files | xargs rg "$@"
}

dotfiles-edit-by-search() {
  (
    cd ~ || return 1
    dotfiles-begin
    # shellcheck disable=SC2145
    git ls-files |
      grep --extended-regexp --invert-match '(PrusaSlicer|/Spoons/)' |
      tr '\n' '\0' |
      xargs -0 rg -l "$@" |
      xargs nvim -p -c "/$@"
  )
}
alias dfebs="dotfiles-edit-by-search"

dotfiles-edit-fuzzy() {
  (
    cd ~ || return 1
    dotfiles-begin
    git ls-files | ~/bin/fuzzy-filter "$@" | xargs nvim -p
  )
}
alias dfef="dotfiles-edit-fuzzy"

gsync() {
  dotfiles-end
  if ! ssh-add -l &>/dev/null; then
    if [[ "$(uname -n)" =~ RSG ]]; then
      mc-add-ssh-key
    else
      op-add-ssh-key
    fi
  fi
  ~/bin/git-autocommit \
    ~/git.peterlyons.com/petes-personal-journal \
    ~/git.peterlyons.com/journals

  ~/bin/git-sync \
    ~ \
    ~/git.peterlyons.com/dotfiles \
    ~/git.peterlyons.com/journals \
    ~/git.peterlyons.com/petes-personal-journal \
    ~/git.peterlyons.com/3d-prints \
    ~/git.peterlyons.com/exocortex \
    ~/git.peterlyons.com/focus-retreat-center

  # if [[ -d ~/github.com/focusaurus/qmk_firmware ]]; then
  #   (
  #     cd ~/github.com/focusaurus/qmk_firmware || exit
  #     git commit -a -m "autocommit"
  #     git pull origin focusaurus
  #     git push origin focusaurus
  #   )
  # fi
}
# typo humane
alias gysnc=gsync

git-cd-repo-dir-fuzzy() {
  dir=$(git ls-files --full-name | xargs dirname | ~/bin/fuzzy-filter "$@")
  if [[ -d "${dir}" ]]; then
    cd "${dir}" || return 1
  fi
}

gcob-fuzzy() {
  name=$(git branch --all --format '%(refname)' | ~/bin/fuzzy-filter "$@")
  [[ -z "${name}" ]] && return 1
  local_name=$(echo "${name}" | cut -d / -f 3-)
  if [[ "${name}" =~ ^refs/remotes/ ]]; then
    local_name=$(echo "${name}" | cut -d / -f 4-)
  fi
  git checkout --track -B "${local_name}" "${name}"
}
