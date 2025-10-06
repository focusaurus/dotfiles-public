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

handle() {
  local event_type=$(echo "$1" | jq -r 'keys[0]')

  case $event_type in
  WorkspacesChanged|WorkspaceActivated|WorkspaceActiveWindowChanged)
    echo "Workspace event: $event_type"
    eww --config ~/.config/eww/niri update "workspaces=$(./workspaces.sh)"
    ;;
  WindowsChanged|WindowOpenedOrChanged|WindowClosed|WindowFocusChanged)
    echo "Window event: $event_type"
    eww --config ~/.config/eww/niri update "clients=$(./windows.sh)"
    ;;
  *)
    # Ignore other events
    ;;
  esac
}

niri msg --json event-stream | while read -r line; do handle "$line"; done
