#!/usr/bin/env zsh
export HISTFILE=/dev/null
export TERM="xterm-color"
export TZ="America/Denver"
set -o emacs

tt() {
  export TERMINAL_TITLE="$*"
}

alias -g /l='| less'
alias -g //l='2>&1 | less'
alias -g /p='$(paste)'


# alias -g devlog='json -g -a -0 -e "delete this.v; delete this.hostname;delete this.level; delete this.pid; delete this.name"'
##### shell prompt setup #####
setopt prompt_subst

#For reference and other fanciness:
#http://stackoverflow.com/q/1128496/266795
prompt-branch() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ -n "${branch}" ]]; then
    printf "%s " "${branch}"
  fi
}

prompt-kube-context() {
  local context
  context="$(kubectl config current-context 2>/dev/null | cut -d . -f 1)"
  if [[ -n "${context}" ]]; then
    printf "🔲  %s " "${context}"
  fi
}

prompt-aws-profile() {
  if [[ -n "${AWS_PROFILE}" ]]; then
    printf "🅰️  %s " "${AWS_PROFILE}"
  fi
}

setup-prompt() {
  export PROMPT='╭%~ $(prompt-branch)$(prompt-aws-profile)$(prompt-kube-context)%n@%m
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
  # export RPROMPT='%n@%m$(prompt-branch)'
}
setup-prompt

save-zsh-history() {
  # http://stackoverflow.com/a/842366/266795
  fc -W
}

TRAPUSR1() {
  { echo reloading due to rss USR1 signal; } 1>&2
  save-zsh-history
  exec "${SHELL}"
}

rss() {
  # TODO check this still works properly on macos
  ps -U "${USER}" | egrep '( -zsh$|[ /]zsh$)' | awk '{print $1}' | xargs kill -USR1 &
}

histsearch() {
  grep -R "$1" ~/.history | cut -d : -f 2-
}

# control-left-arrow goes back a word, right goes forward
bindkey ";5C" forward-word
bindkey ";5D" backward-word
bindkey "^S" kill-word
alias -g /g='| grep'

function watch-zsh() {
  WATCH_COMMAND='zsh -ci' /usr/local/bin/watch "$@"
}
