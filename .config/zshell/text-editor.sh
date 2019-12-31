#!/usr/bin/env bash
alias te="text-editor"

rgte() {
  rg --ignore-case --files-with-matches watch "${@}" | xargs ~/bin/text-editor
}

paste-to-vim() {
  ~/bin/paste | vim -n -c startinsert -
}

if command -v nvim >/dev/null; then
  alias v="nvim"
  export EDITOR="nvim"
fi
