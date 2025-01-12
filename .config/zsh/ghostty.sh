integ="${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
if [[ -x "${integ}" ]]; then
  builtin source "${integ}"
fi
