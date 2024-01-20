ave() {
  if [[ -z "${AWS_PROFILE}" ]]; then
    echo "Set AWS_PROFILE env var first" 1>&2
    return 1
  fi
  aws-vault exec "${AWS_PROFILE}" -- "$@"
}

# set-aws-profile() {
#   local name
#   name="$1"
#   name=$(grep -E '^\[profile' ~/.aws/config |
#     cut -d " " -f 2 |
#     tr -d ']' | fuzzy-filter "${name}")
#   [[ -z "${name}" ]] && return
#   echo "✓ ${name}"
#   export AWS_PROFILE="${name}"
#   export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id) AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key) AWS_REGION=$(aws configure get region)
# }
# alias awsinfo='docker run -it -v ~/.aws:/root/.aws -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_SESSION_TOKEN -e AWS_DEFAULT_REGION -e AWS_PROFILE -e AWS_CONFIG_FILE -e AWSINFO_DEBUG theserverlessway/awsinfo'

setup-aws() {
  autoload -U bashcompinit && bashcompinit
  # autoload -Uz compinit && compinit
  # complete -C 'aws_completer' aws
  cpath="${BREW_PREFIX}/bin/aws_completer"
  if [[ -e "${cpath}" ]]; then
    complete -C "${cpath}" aws
  fi
}
