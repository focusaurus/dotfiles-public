#!/usr/bin/env bash

# Please Use Google Shell Style: https://google.github.io/styleguide/shell.xml

# ---- Start unofficial bash strict mode boilerplate
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -o errexit  # always exit on error
set -o errtrace # trap errors in functions as well
set -o pipefail # don't ignore exit codes when piping output
# set -x # enable debugging

IFS=$'\n\t'
# ---- End unofficial bash strict mode boilerplate

cd "$(git rev-parse --show-toplevel)" || exit 1

git status --porcelain=v1 |
  grep -E '^\?\?' |
  cut -d ' ' -f 2- |
  sk --multi --query "$1" |
  tee -a .gitignore
