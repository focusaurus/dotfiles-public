alias te="text-editor"

te-files-with-matches() {
  rg --ignore-case --files-with-matches watch "${@}" | xargs ~/bin/text-editor
}

te-clipboard() {
  ~/bin/paste | ~/bin/text-editor -n -c startinsert -
}

te-daily() {
  org="${HOME}/projects/exocortex/personal"
  "${EDITOR}" "${org}/$("${org}/bin/file-name-for" 0)"
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
