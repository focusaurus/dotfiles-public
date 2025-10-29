# if [[ -e "${BREW_PREFIX}/bin/mise" ]]; then
#   eval "$("${BREW_PREFIX}/bin/mise" activate zsh)"
# fi
if ~/bin/have-exe mise; then
  eval "$(mise activate zsh)"
fi
