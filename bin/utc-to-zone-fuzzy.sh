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

utcstamp="$1"
zonequery="$2"

if [[ "${zonequery}" =~ ^[0-9]{4} ]]; then
  # arguments passed in wrong order but handle it correctly no worries
  tmp="${utcstamp}"
  utcstamp="${zonequery}"
  zonequery="${tmp}"
fi
zone=$(find -L /usr/share/zoneinfo -type f | sed s,/usr/share/zoneinfo/,, | ~/bin/fuzzy-filter "${zonequery}")

# echo "${utcstamp}" "${zone}"
TZ="${zone:-UTC}" gdate --date="${utcstamp}" '+%Y-%m-%dT%H:%M%Z'
