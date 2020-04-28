#!/usr/bin/env bash
alias te="text-editor"

rgte() {
  rg --ignore-case --files-with-matches watch "${@}" | xargs ~/bin/text-editor
}

paste-to-vim() {
  ~/bin/paste | v -n -c startinsert -
}

cte() {
 c "$@"
 v -p *.*
}

tedaily() {
  org="${HOME}/projects/org"
  "${EDITOR}" "${org}/$("${org}/bin/file-name-for" 0)"
}


if ~/bin/have-exe nvim; then
  alias v="nvim"
  export EDITOR="nvim"
elif ~/bin/have-exe vim; then
  alias v="vim"
  export EDITOR="vim"
else
  alias v="vi"
  export EDITOR="vi"
fi

vimrc() {
  fd .vim ~/.config/nvim | xargs nvim -p
}
