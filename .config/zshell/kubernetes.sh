#!/usr/bin/env bash
if command -v kubectl >/dev/null && [[ -n "${ZSH_VERSION}" ]]; then
  # shellcheck disable=SC1090
  source <(kubectl completion zsh)
fi
k-set-namespace() {
  # global variable
  n="$1"
}

k-use-config() {
  local config="$1"
  config=$(find ~/.kube -maxdepth 1 -type f -name '*.yaml' | ~/bin/fuzzy-filter "${config}")
  export KUBECONFIG="${config}"
  echo "✓ ${config}"
}

k-logs() {
  k-get-pods >/dev/null
  local pod
  pod=$(k-get-pod "$@")
  [[ -z "${pod}" ]] && return
  # echo "✓ pod: ${pod}"
  local container="$2"
  kubectl -n "${n}" logs "${pod}" "${container}"
}

k-logsf() {
  k-get-pods >/dev/null
  local pod
  pod=$(k-get-pod "$@")
  [[ -z "${pod}" ]] && return
  # echo "✓ pod: ${pod}"
  local container="$2"
  kubectl -n "${n}" logs --tail 1000 -f "${pod}" "${container}"
}

k-exec() {
  k-get-pods
  local pod
  pod=$(k-get-pod "$1")
  [[ -z "${pod}" ]] && return
  # echo "✓ pod: ${pod}"
  shift
  declare -a command=(sh -c 'bash || sh')
  if [[ $# -ge 1 ]]; then
    command=($@)
  fi
  declare -a container=()
  if [[ "${pod}" =~ "pricing-engine" ]]; then
    container=(-c reaction-pricing-engine)
  fi
  if [[ "${pod}" =~ "categories" ]]; then
    container=(-c reaction-categories)
  fi
  kubectl -n "${n}" exec -it "${container[@]}" "${pod}" -- "${command[@]}"
}

k-get-pods() {
  if [[ -z "${pods}" ]]; then
    pods=$(kubectl -n "${n}" get pods -o 'jsonpath={.items[*].metadata.name}' | xargs -n 1)
  fi
}

k-refresh-pods() {
  unset pods
  k-get-pods
}

k-get-pod() {
  k-get-pods
  local filter
  filter="$1"
  echo "${pods}" | ~/bin/fuzzy-filter "${filter}"
}

k-describe() {
  k-get-pods
  local pod
  pod=$(k-get-pod "$@")
  [[ -z "${pod}" ]] && return
  kubectl -n "${n}" describe pod "${pod}"
}

k-delete() {
  k-get-pods
  local pod
  pod=$(k-get-pod "$@")
  [[ -z "${pod}" ]] && return
  echo "✓ pod: ${pod}"
  kubectl -n "${n}" delete pod "${pod}"
}

k-get-configmap() {
  maps=$(kubectl -n "${n}" get configmaps -o 'jsonpath={.items[*].metadata.name}' | xargs -n 1)
  local filter
  filter="$1"
  local map
  map=$(echo "${maps}" | ~/bin/fuzzy-filter "${filter}")
  [[ -z "${map}" ]] && return
  kubectl -n "${n}" describe configmap "${map}"
}

k-port-forward() {
  filter="$1"
  port="$2"
  service=$(kubectl -n "${n}" get services -o name | fuzzy-filter "${filter}")
  [[ -z "${service}" ]] && return
  kubectl -n "${n}" port-forward "${service}" "${port}"
}
