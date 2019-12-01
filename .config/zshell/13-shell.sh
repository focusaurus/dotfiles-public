#!/usr/bin/env bash
##### History #####
# http://www.joshuad.net/zshrc-config/

HISTFILE="${HOME}/.history/$(basename "${SHELL}")"
export HISTFILE
mkdir -p "$(dirname "${HISTFILE}")"

export TERM="xterm-color"
export EDITOR="vim"
export TZ="America/Denver"
set -o emacs

setup-prompt() {
  export PS1="╭ \w \u@\h\n╰○ "
}
setup-prompt

if [[ -n "${ZSH_VERSION}" ]]; then
  source "${HOME}/projects/dotfiles/shell/zshell.sh"
fi

tt() {
  export TERMINAL_TITLE="$*"
}
