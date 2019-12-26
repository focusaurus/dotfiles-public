#!/usr/bin/env bash
export FZF_DEFAULT_COMMAND='rg -g ""'
export FZF_COMPLETION_TRIGGER="''"
export FZF_DEFAULT_OPTS='--bind=alt-enter:print-query'
if [[ -n "${ZSH_VERSION}" ]]; then
  [[ -f "/usr/share/fzf/competion.zsh" ]] && source "/usr/share/fzf/competion.zsh"
  [[ -f "/usr/share/fzf/key-bindings.zsh" ]] && source "/usr/share/fzf/key-bindings.zsh"

  # fzf-cd-all-widget() {
  #   setopt localoptions pipefail 2>/dev/null
  #
  #   local dir="$(fd --hidden --no-ignore-vcs --type directory --color=auto '' $HOME 2>/dev/null | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --multi --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" fzf)"
  #
  #   if [[ -z "$dir" ]]; then
  #     zle redisplay
  #     return 0
  #   fi
  #   cd "$dir"
  #   local ret=$?
  #   typeset -f zle-line-init >/dev/null && zle zle-line-init
  #   return $ret
  # }
fi

fuzzy-filter() {
  cat | (fzf --select-1 --query "$1" || fzf --query "${1}")
}

c() {
  local dir
  dir=$(fasd -dl | fuzzy-filter "$@")
  if [[ -n "${dir}" ]]; then
    cd "${dir}" || return
  else
    echo "No match!" 1>&2
  fi
}

fuzz-directory-command-line() {
  local dir
  # dir="$(fd --hidden --no-ignore-vcs --type directory . 2>/dev/null |
  #   FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --multi --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" fzf)"
  dir="$(fd --hidden --no-ignore-vcs --type directory . 2>/dev/null | fzf)"
  cat | fzf --select-1 --exit-0 --query "$1"
}

kill-fzf() {
  pkill --full 'fzf.*select-1.*query'
}

sigusr1-fuzzy() {
  pid=$(ps -ef | fuzzy-filter "$@" | awk '{print $2}')
  shift
  [[ -z "${pid}" ]] && return 1
  /bin/kill --signal USR1 "${pid}"
}
