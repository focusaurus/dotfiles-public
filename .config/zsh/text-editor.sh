#!/usr/bin/env bash
alias te="text-editor"

te-files-with-matches() {
  rg --ignore-case --files-with-matches watch "${@}" | xargs ~/bin/text-editor
}

te-clipboard() {
  ~/bin/paste | v -n -c startinsert -
}
alias paste-to-vim="te-clipboard"

te-daily() {
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

te-vimrc() {
  fd .vim ~/.config/nvim | xargs nvim -p
}

te-git-changed() {
  git status --short | awk '{print $2}' | xargs "${EDITOR}" -p
}
