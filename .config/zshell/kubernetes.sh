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
  config=$(find ~/.kube -maxdepth 1 -type f -name '*.yaml' | fuzzy-filter "${config}")
  export KUBECONFIG="${config}"
  echo "✓ ${config}"
}

k-use-context() {
  local context="$1"
  context=$(yaml-to-json "${KUBECONFIG:-${HOME}/.kube/config}" |
    jq -r '.contexts[].name' |
    grep -v kafka |
    fuzzy-filter "${context}")
  [[ -z "${context}" ]] && return
  # n is a global variable, heads up
  case "${context}" in
  *staging.k8s.bobs*)
    set-aws-profile sdi-management
    n=staging
    ;;
  *production.k8s.bobs*)
    set-aws-profile sdi-management
    n=production
    ;;
  *devEKSCluster*)
    set-aws-profile rc-dev
    n=dev
    ;;
  *stagingEKSCluster*)
    set-aws-profile rc-dev
    n=staging
    ;;
  *) ;;
  esac

  kubectl config use-context "${context}" -n "${n}"
  echo "✓ ${context}"
  echo "reloading pod list…"
  sleep 1 # seems to break sometimes if too fast?
  k-refresh-pods
  echo "${pods}"
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
  echo "${pods}" | fuzzy-filter "${filter}"
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
  map=$(echo "${maps}" | fuzzy-filter "${filter}")
  [[ -z "${map}" ]] && return
  kubectl -n "${n}" describe configmap "${map}"
}
