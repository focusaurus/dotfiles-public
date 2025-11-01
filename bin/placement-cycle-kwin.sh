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

# View output with: journalctl --user -f -u plasma-kwin_wayland.service

script_file=$(mktemp "/tmp/placement-cycle-kwin-XXX.js")
cp ~/bin/kwin/placement-cycle.js "${script_file}"

# Load and run the script
script_id=$(qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$script_file")
if [ $? -eq 0 ]; then
  qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.start
  qdbus org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$script_id" 2>/dev/null
fi

rm -f "$script_file"