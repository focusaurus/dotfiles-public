#!/usr/bin/env bash

# Please Use Google Shell Style: https://google.github.io/styleguide/shell.xml

# ---- Start unofficial bash strict mode boilerplate
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -o errexit  # always exit on error
set -o errtrace # trap errors in functions as well
set -o pipefail # don't ignore exit codes when piping output
set -u          # error on reference to unknown variable
# set -x # enable debugging

IFS=$'\n\t'
# ---- End unofficial bash strict mode boilerplate

cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ "$(uname)" == "Darwin" ]]; then
  sed -E -e 's/(control|ctrl)/command/g' -e 's,/usr/share/ghostty/themes/,,g' <config.tpl >config
else
  cp config.tpl config
fi
