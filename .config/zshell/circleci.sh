#!/usr/bin/env bash
circleci-get-job() {
  ~/bin/yaml-to-json <.circleci/config.yml |
    jq -r '.jobs | keys[]' |
    ~/bin/fuzzy-filter "$@"
}

circleci-run-job() {
  local query
  query="$1"
  local job
  job=$(circleci-get-job "${query}")
  [[ -z "${job}" ]] && return

  tmp=$(mktemp .config-XXX.yml)
  chmod a+r "${tmp}"
  circleci config process .circleci/config.yml >"${tmp}"
  circleci local execute \
    --skip-checkout \
    --config "${tmp}" \
    --env "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
    --env "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
    --env "AWS_REGION=${AWS_REGION}" \
    --job "${job}" || true
  rm "${tmp}"

}

circleci-validate() {
  circleci config validate
}
