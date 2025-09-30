op-add-ssh-key() {
  if [[ -n $(ssh-add -L | grep --invert-match "no identities") ]]; then
    echo ssh key already loaded into ssh-agent. Ready for passwordless ssh.
    return
  fi
  # op-copy-password-by-title my "ssh focusaurus private keys"
  op read --account my "op://Private/ssh focusaurus private keys/password" | ~/bin/copy
  passwordless
}

alias oask=op-add-ssh-key

op-copy-password-by-title() {
  local account="$1"
  shift
  session=$(echo -n "\${OP_SESSION_${account}}")
  # shellcheck disable=SC2154
  if [[ -z "${session}" ]]; then
    eval "$(op signin --account "${account}")"
  fi
  local items
  items=$(op item list --format json 2>/dev/null)
  if [[ -z "${items}" ]]; then
    eval "$(op signin --account "${account}")"
    items=$(op item list --format json)
  fi
  if [[ -z "${items}" ]]; then
    return 1
  fi
  title=$(echo "${items}" |
    jq -r ".[].title" |
    ~/bin/fuzzy-filter "$@")
  uuid=$(echo "${items}" |
    jq -r ".[] | select(.title == \"${title}\") | .id")
  if [[ -z "${uuid}" ]]; then
    return 1
  fi
  echo "${uuid} ${title}"
  op item get --format json "${uuid}" |
    jq -r '.fields[] | select(.id=="password").value' |
    ~/bin/copy
  echo "Password \"${uuid}${title}\" copied"
}

op-source-env-by-title() {
  local account="$1"
  shift
  session=$(echo -n "\${OP_SESSION_${account}}")
  # shellcheck disable=SC2154
  if [[ -z "${session}" ]]; then
    eval "$(op signin --account "${account}")"
  fi
  local items
  items=$(op item list --format json 2>/dev/null)
  if [[ -z "${items}" ]]; then
    eval "$(op signin --account "${account}")"
    items=$(op item list --format json)
  fi
  if [[ -z "${items}" ]]; then
    return 1
  fi
  title=$(echo "${items}" |
    jq -r ".[].title" |
    ~/bin/fuzzy-filter "$@")
  uuid=$(echo "${items}" |
    jq -r ".[] | select(.title == \"${title}\") | .id")
  if [[ -z "${uuid}" ]]; then
    return 1
  fi
  echo "# item found in 1password\n# uuid: ${uuid}\n# title: ${title}"
  op item get --format json "${uuid}" |
    jq -r '.fields[] | select(.id=="notesPlain").value'
}
