#!/usr/bin/env bash
##### ssh #####
alias s="ssh"
alias kill-ssh='jobs -l|egrep " ss?h? " | cut -d " " -f 4| xargs kill; fg'
alias skr="ssh-keygen -R"
# alias passwordless="eval $(ssh-agent -s) >/dev/null; ssh-add 2>/dev/null"
passwordless() {
  for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa; do
    if [[ -e "${key}" ]]; then
      ssh-add "${key}"
    fi
  done
}

encrypt-ssh-private-key() {
  in="${1-}"
  out="${2-id_rsa.enc.pkcs8}"
  echo "Encrypting ${in} to ${out}"
  openssl pkcs8 -topk8 -v2 des3 -topk8 -in "${in}" -out "${out}"
}

dump-ssh-key() {
  local key_path="$1"
  local header
  header=$(head -1 "${key_path}" | grep '^----')
  if [[ -n "${header}" ]]; then
    # PEM format
    # 1. strip out the header/footer lines (they have dashes)
    # 2. Decode the base64, this handles newlines no problem
    # 3. dump that as hex
    hex=$(grep -v - "${key_path}" |
      base64 -D |
      xxd -p)
    case "${hex}" in
      30*)
        # Looks like ASN.1 data, dump it
        # openssl asn1parse -in "${key_path}"
        grep -v - "${key_path}" | base64 -D | der2ascii
        ;;
      *)
        echo "${hex}"
        ;;
    esac
  else
    # openssh public key format
    cut -d " " -f 2 "${key_path}" |
      base64 -D |
      xxd -p
  fi
}

reknown-host() {
  local name
  name="$1"
  local ips
  ips=$(getent hosts production-bastion-275ca332fb812d99.elb.us-east-1.amazonaws.com | cut -d " " -f 1)
  cat <<EOF | xargs -n 1 ssh-keygen -R
${name}
${ips}
EOF
}