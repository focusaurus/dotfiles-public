#!/usr/bin/env bash
_tf() {
  command=${1-plan}
  aws-vault exec "${AWS_PROFILE}" -- terraform "${command}" "$@"
}

tfa() {
  _tf apply "$@"
}

tfp() {
  _tf plan "$@"
}

tfg() {
  _tf get "$@"
}
