#!/usr/bin/env bash
alias te="text-editor"

rgte() {
  rg --ignore-case --files-with-matches watch "${@}" | xargs ~/bin/text-editor
}

paste-to-vim() {
  ~/bin/paste | v -n -c startinsert -
}

tedaily() {
  org="${HOME}/projects/org"
  "${EDITOR}" "${org}/$("${org}/bin/file-name-for" 0)"
}

if command -v nvim >/dev/null; then
  alias v="nvim"
  export EDITOR="nvim"
elif command -v vim >/dev/null; then
  alias v="vim"
  export EDITOR="vim"
else
  alias v="vi"
  export EDITOR="vi"
fi

vimrc() {
  fd .vim ~/.config/nvim | xargs nvim -p
}
