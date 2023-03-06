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

app-to-icon() {
  wmctrl -l | grep "$1" | awk '{print $1}' | {
    while IFS= read -r id_hex; do
      xseticon -id $((id_hex)) "$2"
    done
  }
}

app-to-icon "Obsidian" "/usr/share/pixmaps/obsidian.png"
app-to-icon "Slack" "/usr/share/icons/Arc-ICONS/apps/48/slack.png"
app-to-icon "1Password" "/usr/share/icons/hicolor/64x64/apps/1password.png"
app-to-icon "music" "${HOME}/.config/awesome/youtube-music-logo.png"
