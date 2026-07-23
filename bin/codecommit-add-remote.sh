#!/usr/bin/env bash

# Please Use Google Shell Style: https://google.github.io/styleguide/shell.xml

# ---- Start unofficial bash strict mode boilerplate
# http://redsymbol.net/artic…les/unofficial-bash-strict-mode/
set -o errexit  # always exit on error
set -o errtrace # trap errors in functions as well
set -o pipefail # don't ignore exit codes when piping output
set -u          # error on reference to unknown variable
[ "${DEBUG:-0}" = "1" ] && set -x

IFS=$'\n\t'
# ---- End unofficial bash strict mode boilerplate

base="ssh://git-codecommit.us-west-2.amazonaws.com/v1/repos"
find "${PWD}" -name .git -type d | grep -v .cargo/registry | {
  while IFS= read -r file_path; do
    cd "${file_path}/.."
    repo=$(echo "${PWD}" |
      cut -d / -f 5- |
      sed 's,/,-,g')
    if git remote -v | grep codecommit >/dev/null; then
      echo "OK ${repo}"
    else
      git remote add aws "${base}/${repo}"
      echo "ADDED ${repo}"
    fi
  done
}
