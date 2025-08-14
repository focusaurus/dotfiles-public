alias te="~/bin/text-editor"

te-files-with-matches() {
  rg --ignore-case --files-with-matches "${@}" | xargs ~/bin/text-editor
}

te-clipboard() {
  # this is admittedly unclean in that in theory
  # the intention behind ~/bin/text-editor is an integration
  # point where I could change which program I use as my primary
  # editor (nvim vs helix vs emacs vs nano or whatever)
  # and most of my simple scripts would just work once I
  # adjust ~/bin/text-editor to maintain its external interface
  #
  # In this case there are some nvim-specific args here
  if grep -q -E '^nvim ' ~/bin/text-editor; then
    ~/bin/paste | ~/bin/text-editor -n -c startinsert -
  else
    ~/bin/paste | ~/bin/text-editor
  fi
}

te-daily() {
  local exo="${HOME}/projects/exocortex/personal"
  "${EDITOR}" "${exo}/$("${exo}/bin/file-name-for" 0)"
}

if ~/bin/have-exe nvim; then
  export EDITOR="${HOME}/bin/text-editor"
elif ~/bin/have-exe vim; then
  alias v="vim"
  export EDITOR="vim"
else
  alias v="vi"
  export EDITOR="vi"
fi
