#!/usr/bin/env bash
alias te="${HOME}/bin/text-editor.sh"

rgte() {
  rg --ignore-case --files-with-matches watch "${@}" | xargs atom
}

save-atom() {
  apm list --installed --bare >~/projects/dotfiles/home-dir-symlinks/.atom/packages.txt
}

setup-atom-packages() {
  cut -d @ -f 1 <~/projects/dotfiles/atom/packages.txt | xargs apm install
}

paste-to-vim() {
  paste | vim -n -c startinsert -
}

if command -v nvim >/dev/null; then
  alias v="nvim"
  export EDITOR="nvim"
fi
