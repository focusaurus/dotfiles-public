op-add-ssh-key() {
  mc-copy-password-by-title "ssh focusaurus private keys"
}

op-copy-password-by-title() {
  # shellcheck disable=SC2154
  if [[ -z "${OP_SESSION_my}" ]]; then
    eval "$(op signin)"
  fi
  op list items |
    jq -r ".[] | select(.overview.title == \"$1\") | .uuid" |
    xargs op get item |
    jq -r .details.password |
    ~/bin/copy
  echo "Password \"$1\" copied"
}
