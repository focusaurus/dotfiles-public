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
  org="${HOME}/projects/exocortex/personal"
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

#Note to self, use sudoedit to edit files with my nvim config as root

# https://medium.com/@bobbypriambodo/blazingly-fast-spacemacs-with-persistent-server-92260f2118b7
em() {
  # Checks if there's a frame open
  emacsclient -n -e "(if (> (length (frame-list)) 1) ‘t)" 2>/dev/null | grep -q t
  if [ "$?" -eq "1" ]; then
    emacsclient -a '' -nqc "$@" &>/dev/null
  els
    emacsclient -nq "$@" &>/dev/null
  fi
}

alias spacevim="nvim -u ~/.SpaceVim/main.vim"
