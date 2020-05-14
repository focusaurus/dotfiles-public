#!/usr/bin/env zsh

unset HISTFILE
export TZ="America/Denver"

tt() {
  export TERMINAL_TITLE="$*"
}

alias -g /l='| less'
alias -g //l='2>&1 | less'
alias -g /c='| copy'
alias -g /p='$(paste)'

# alias -g devlog='json -g -a -0 -e "delete this.v; delete this.hostname;delete this.level; delete this.pid; delete this.name"'
##### shell prompt setup #####
setopt prompt_subst

# emacs mode
bindkey -e
# vi mode
# https://unix.stackexchange.com/a/393705/25728
#bindkey -v
#bindkey "^R" history-incremental-search-backward
KEYTIMEOUT=1

function zle-line-init zle-keymap-select {
    case ${KEYMAP} in
        (vicmd)      ZLE_VI_MODE="N" ;;
        (main|viins) ZLE_VI_MODE="I" ;;
        (*)          ZLE_VI_MODE="I" ;;
    esac
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

#For reference and other fanciness:
#http://stackoverflow.com/q/1128496/266795
prompt-git-branch() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ -n "${branch}" ]]; then
    printf "b: %s " "${branch}"
  fi
}

prompt-git-status() {
  if ! git status --porcelain &>/dev/null; then
    return
  fi
  local git_status
  git_status=$(git status --porcelain 2>/dev/null |
    awk '{print $1}' |
    sort |
    uniq -c |
    xargs)
  echo -n "s: "
  if [[ -z "${git_status}" ]]; then
    echo -n "clean"
  else
    echo -n "${git_status}"
  fi
  echo -n " "
}

prompt-git-dir() {
  if [[ -n "${GIT_DIR}" ]]; then
    printf "GIT_DIR "
  fi
}

prompt-git() {
  if [[ "${PWD}" =~ ^/Volumes/CaseSensitive ]]; then
    # For super large repositories, this slows the shell prompt down too much
    # so just disable it
    return
  fi
  echo "$(prompt-git-branch)$(prompt-git-status)$(prompt-git-dir)"
}

prompt-kube-context() {
  local context
  context="$(kubectl config current-context 2>/dev/null | cut -d . -f 1)"
  if [[ -n "${context}" ]]; then
    printf "🔲  %s " "${context}"
  fi
}

prompt-kube-namespace() {
  if [[ -n "${n}" ]]; then
    printf "🇳'  %s " "${n}"
  fi
}

prompt-aws-profile() {
  if [[ -n "${AWS_PROFILE}" ]]; then
    printf "🅰️  %s " "${AWS_PROFILE}"
  fi
}

setup-prompt() {
  export PROMPT='╭%4~ %n@%m
╰○ '
  # https://unicode-search.net/unicode-namesearch.pl?term=down&.submit=Search
  # 𝄱
  # Wrap apround version
  # ╭
  # ╰○
  # from sindre sourhous zsh
  # ❯ '
  # small white square ▫️ '
  # ❯
  # export RPROMPT='vi:${ZLE_VI_MODE}$(prompt-git)$(prompt-aws-profile)$(prompt-kube-context)$(prompt-kube-namespace)'
  export RPROMPT='$(prompt-git)$(prompt-aws-profile)$(prompt-kube-context)$(prompt-kube-namespace)'
}
setup-prompt

TRAPUSR1() {
  { echo reloading due to rss USR1 signal; } 1>&2
  exec "${SHELL}"
}

rss() {
  ps -U "${USER}" | egrep '( -zsh$|[ /]zsh$)' | awk '{print $1}' | xargs kill -USR1 &
}

# control-left-arrow goes back a word, right goes forward
bindkey ";5C" forward-word
bindkey ";5D" backward-word
bindkey "^S" kill-word
alias -g /g='| grep'

function watch-zsh() {
  WATCH_COMMAND='zsh -ci' /usr/local/bin/watch "$@"
}
