#!/usr/bin/env bash
op-add-ssh-key() {
  op-copy-password-by-title my "ssh focusaurus private keys"
  passwordless
}

op-copy-password-by-title() {
  local account="$1"
  shift
  session=$(echo -n "\${OP_SESSION_${account}}")
  # shellcheck disable=SC2154
  if [[ -z "${session}" ]]; then
    eval "$(op signin "${account}")"
  fi
  local items=$(op list items 2>/dev/null)
  if [[ -z "${items}" ]]; then
    eval "$(op signin "${account}")"
    items=$(op list items)
  fi
  if [[ -z "${items}" ]]; then
    return 1
  fi
  title=$(echo "${items}" |
    jq -r ".[].overview.title" |
    ~/bin/fuzzy-filter "$@")
  uuid=$(echo "${items}" |
    jq -r ".[] | select(.overview.title == \"${title}\") | .uuid")
  if [[ -z "${uuid}" ]]; then
    return 1
  fi
  echo "${uuid} ${title}"
  op get item "${uuid}" |
    jq -r '.details.password // (.details.fields[] | select(.designation=="password").value)' |
    ~/bin/copy
  echo "Password \"${uuid}${title}\" copied"
}
