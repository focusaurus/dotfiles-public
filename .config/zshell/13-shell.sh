#!/usr/bin/env bash
##### History #####
# http://www.joshuad.net/zshrc-config/

HISTFILE="${HOME}/.history/$(basename "${SHELL}")"
export HISTFILE
mkdir -p "$(dirname "${HISTFILE}")"

export TERM="xterm-color"
export EDITOR="neovim"
export TZ="America/Denver"
set -o emacs

tt() {
  export TERMINAL_TITLE="$*"
}

alias format-shell-script="shfmt -i 2 -w"
