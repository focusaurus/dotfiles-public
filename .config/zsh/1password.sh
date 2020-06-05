#!/usr/bin/env bash
op-add-ssh-key() {
  mc-copy-password-by-title "ssh focusaurus private keys"
}

op-copy-password-by-title() {
  # shellcheck disable=SC2154
  if [[ -z "${OP_SESSION_my}" ]]; then
    eval "$(op signin)"
  fi
  items=$(op list items)
  if [[ -z "${items}" ]]; then
    unset OP_SESSION_my
    eval "$(op signin)"
    return 1
  fi
  title=$(echo "${items}" |
    jq -r ".[].overview.title" | ~/bin/fuzzy-filter "$@")
  uuid=$(echo "${items}" |
    jq -r ".[] | select(.overview.title == \"${title}\") | .uuid")
  echo "${uuid} ${title}"
  op get item "${uuid}" |
    jq -r '.details.fields[] | select(.designation=="password").value' |
    ~/bin/copy
  echo "Password \"${uuid}${title}\" copied"
}
