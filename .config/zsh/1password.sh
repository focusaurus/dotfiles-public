#!/usr/bin/env bash
op-add-ssh-key() {
  op-copy-password-by-title my "ssh focusaurus private keys"
}

op-copy-password-by-title() {
  account="$1"
  shift
  session=$(echo -n "\${OP_SESSION_${account}}")
  # shellcheck disable=SC2154
  if [[ -z "${session}" ]]; then
    eval "$(op signin "${account}")"
  fi
  items=$(op list items)
  if [[ -z "${items}" ]]; then
    eval "$(op signin "${account}")"
    return 1
  fi
  title=$(echo "${items}" |
    jq -r ".[].overview.title" |
    ~/bin/fuzzy-filter "$@")
  uuid=$(echo "${items}" |
    jq -r ".[] | select(.overview.title == \"${title}\") | .uuid")
  echo "${uuid} ${title}"
  op get item "${uuid}" |
    jq -r '.details.password // (.details.fields[] | select(.designation=="password").value)' |
    ~/bin/copy
  echo "Password \"${uuid}${title}\" copied"
}
