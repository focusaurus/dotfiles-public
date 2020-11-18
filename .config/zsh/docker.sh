#!/usr/bin/env bash
dquick() {
  # default node version
  local version=12.10.0
  local workdir=/host
  local volume=/host
  local home
  local label="$1"
  local image="${label}"
  if [[ -z "${label}" ]]; then
    # Compute the project tech stack label
    # If we find clear marker files indicating project type, use that
    if [[ -f "package.json" || -f ".nvmrc" ]]; then
      label="node"
    fi
    if [[ -f "Cargo.toml" ]]; then
      label="rust"
    fi
    if [[ -f "deps.edn" ]]; then
      label="clojure"
    fi
  else
    shift
  fi

  if [[ -z "${label}" ]]; then
    echo "Usage: dquick <label>" 1>&2
    return 1
  fi

  case "${label}" in
  node)
    image="node:${version}"
    if [[ -f ".nvmrc" ]]; then
      version=$(cat .nvmrc)
    fi
    ;;
  lambda-node-8)
    image="lambci/lambda:nodejs8.10"
    ;;
  rust)
    image="guangie88/rustfmt-clippy:stable"
    workdir="/volume"
    volume="/volume"
    ;;
  clojure)
    image="clojure:tools-deps-1.10.0.442"
    home="HOME=/host"
    username="app"
    ;;
  esac

  shell="${1-bash}"
  if [[ -z "${shell}" ]]; then
    shell="sh -c 'bash || sh'"
  fi
  declare -a opts=(
    --rm
    --interactive
    --tty
    --volume "${PWD}:${volume}"
    --user "$(id -u)"
    --workdir "${workdir}"
    --env "PATH=/usr/local/bin:/usr/bin:/bin:/host/node_modules/.bin:/opt/.cargo/bin"
  )
  if [[ -n "${home}" ]]; then
    opts+=(--env "HOME+=${home}")
  fi
  if [[ -n "${username}" ]]; then
    opts+=(--env "USER+=${username}")
  fi
  echo docker run "${opts[@]}" "${image}" "${shell}"
  docker run "${opts[@]}" "${image}" "${shell}"
}

drme() {
  declare -a opts=(--no-run-if-empty)
  if [[ "$(uname)" == "Darwin" ]]; then
    # BSD xargs doesn't support this option
    opts=()
  fi
  (
    for _status in exited created; do
      docker ps --quiet --all --filter "status=${_status}"
    done
  ) | xargs "${opts[@]}" docker rm
}

dcip() {
  local container
  container=$(docker ps | grep -E "\b$1\s*\$" | awk '{print $1}')
  docker inspect -f "{{ .NetworkSettings.IPAddress }}" "${container}"
}

alias dcd="docker-compose down &>/dev/null"
alias dcud="docker-compose up -d |& grep -v Creating &"

docker-prune() {
  docker images --all --quiet --filter="dangling=true" |
    xargs --no-run-if-empty docker rmi
}

dex() {
  local query
  query="$1"
  shift
  local container
  container=$(docker ps --format "{{.Names}}" | ~/bin/fuzzy-filter "${query}")
  [[ -z "${container}" ]] && return
  declare -a command=("$@")
  if [[ $# -eq 0 ]]; then
    command=(sh -c 'bash || sh')
  fi
  docker exec --interactive --tty "${container}" "${command[@]}"
}

dcl() {
  format="table {{.Label \"com.docker.compose.project\"}}\t{{.Label \"com.docker.compose.service\"}}\t{{.Names}}"
  line=$(docker ps -a --format "${format}" | ~/bin/fuzzy-filter "$@")
  name=$(echo "${line}" | awk '{print $3}')
  [[ -z "${name}" ]] && return
  docker logs --tail=500 -f "${name}"
}

dl() {
  local container
  container=$(docker ps --format "{{.Names}}" | ~/bin/fuzzy-filter "$@")
  [[ -z "${container}" ]] && return
  docker logs -f "${container}"
}

dstop() {
  local container
  container=$(docker ps --format "{{.Names}}" | ~/bin/fuzzy-filter "$@")
  [[ -z "${container}" ]] && return
  docker stop "${container}"
}

dcstop() {
  local container
  container=$(dcservices | ~/bin/fuzzy-filter "$@")
  [[ -z "${container}" ]] && return
  docker-compose stop "${container}"
}

drun() {
  declare -a command=("$@")
  if [[ $# -eq 0 ]]; then
    command=(sh -c 'bash || sh')
  fi
  docker run --rm --interactive --tty --volume "${PWD}:/host" --workdir=/host "${command[@]}"
}

dcrun() {
  local container
  container=$(dcservices | ~/bin/fuzzy-filter "$1")
  shift
  declare -a command=("$@")
  if [[ $# -eq 0 ]]; then
    command=(sh -c 'bash || sh')
  fi
  docker-compose run --rm --volume "${PWD}:/host" "${container}" "${command[@]}"
}

dcrunsp() {
  local container
  container=$(dcservices | ~/bin/fuzzy-filter "$1")
  shift
  declare -a command=("$@")
  if [[ $# -eq 0 ]]; then
    command=(sh -c 'bash || sh')
  fi
  docker-compose run --rm --volume "${PWD}:/host" --service-ports --use-aliases "${container}" "${command[@]}"
}

dcservices() {
  local filter='.services | keys | .[]'
  (
    yq -r "${filter}" <docker-compose.yml
    if [[ -e docker-compose.override.yml ]]; then
      yq -r "${filter}" <docker-compose.override.yml
    fi
  ) | sort | uniq
}

# https://stackoverflow.com/a/49281526/266795
# if [[ -n "${ZSH_VERSION}" ]]; then
#   autoload -U compinit && compinit
#   _deit() {
#     COMPREPLY=($(docker ps --format "{{.Names}}" -f name=$2))
#   }
#   # complete -F _deit deit
# fi
alias daws='docker run --rm --interactive --tty cgswong/aws'
alias dbd="docker build ."
alias dc="docker-compose"
alias dcb="docker-compose build"

dps() {
  # {{.Ports}}|
  # {{.Label "com.docker.compose.project"}}|
  # {{.Label "com.docker.compose.service"}}|

  format='table
{{.Names}}|
{{.Status}}|
{{.Ports}}'
  format=$(echo "${format}" | tr -d '\n')
  docker ps --format "${format}" | column -t -s '|'
}

dps-names() {
   docker ps --format='{{json .Names}}' | jq -r
}
