#!/usr/bin/env zsh

# zsh history setup
export APPEND_HIST
export HISTFILE=~/.zsh-history
export HISTSIZE="10000"
export HIST_EXPIRE_DUPS_FIRST
export HIST_FIND_NO_DUPS
export HIST_IGNORE_DUPS
export HIST_NO_DUPS
export HIST_REDUCE_BLANKS
export INC_APPEND_HISTORY="1"
export SAVEHIST="10000"
export SHARE_HISTORY="1"

setopt autopushd pushdignoredups pushdsilent

export TZ="America/New_York"
tt() {
  export TERMINAL_TITLE="$*"
}

alias -g /l='| less'
alias -g //l='2>&1 | less'
alias -g /c='| copy'
alias -g /p='"$(paste)"'
alias -g /x='| xargs'
alias -g /bd='!$'
alias -g /g='| grep'
alias -g /gv='| grep -v'
alias -g /w='| wc -l'

# alias -g devlog='json -g -a -0 -e "delete this.v; delete this.hostname;delete this.level; delete this.pid; delete this.name"'
##### shell prompt setup #####
setopt prompt_subst
setopt interactivecomments

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
  if [[ "${PWD}" =~ (monolith|mailchimp|shopchimp) ]]; then
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

prompt-pando-target() {
  if [[ -n "${PANDO_TARGET}" ]]; then
    printf "🅿️ %s " "${PANDO_TARGET}"
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
  # export RPROMPT='$(prompt-git)$(prompt-pando-target)'
  export RPROMPT='$(prompt-pando-target)'
}

#emacs mode
# bindkey -e
# let's try vi mode
set -o vi

##### completion #####
fpath=(~/.config/zsh/completions $fpath)
autoload -Uz compinit && compinit
#autoload -Uz compinstall && compinstall

# Trigger basic filesystem completion anywhere in
# any command with ctrl+t
# https://stackoverflow.com/a/49968871/266795
zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files
# https://unix.stackexchange.com/questions/12288/zsh-insert-completion-on-first-tab-even-if-ambiguous
# setopt menucomplete
bindkey '^t' complete-file

# control-left-arrow goes back a word, right goes forward
bindkey ";5C" forward-word
bindkey ";5D" backward-word
bindkey "^S" kill-word
# ctrl+backspace: delete word before
bindkey '^H' backward-kill-word

set-terminal-title() {
 echo -n -e "\033]0;$@\007"
}
alias stt=set-terminal-title

# Disabling in favor of starship
# setup-prompt

TRAPUSR1() {
  { echo reloading due to rss USR1 signal; } 1>&2
  exec "${SHELL}"
}

# reload shell setup (rss mnemonic)
# Basically send a USR1 signal to every zsh process so they reload
# their config on next command
# Helpful when I add new functions and aliases
rss() {
  killall -u "${USER}" -SIGUSR1 -m 'zsh'
}

function watch-zsh() {
  WATCH_COMMAND='zsh -ci' /usr/local/bin/watch "$@"
}

autoload zmv
