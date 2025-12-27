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

niri msg -j windows | jq '
  def get_emoji(app_id; title):
    if app_id == null then ""
    elif (app_id | ascii_downcase | test("firefox")) then
      if (title | startswith("main:")) then "🌎"
      elif (title | startswith("calendar:")) then "📅"
      elif (title | startswith("music:")) then "🎵"
      elif (title | startswith("trello:")) then "✅"
      else "🌐"
      end
    elif (app_id | ascii_downcase | test("chrom")) then "🌍"
    elif (app_id | ascii_downcase | test("zen")) then "🐵"
    elif (app_id | ascii_downcase | test("code|zed")) then "💻"
    elif (app_id | ascii_downcase | test("vim|nvim")) then "📝"
    elif (app_id | ascii_downcase | test("terminal|kitty|alacritty|wezterm|xterm|ghostty")) then "🖥️"
    elif (app_id | ascii_downcase | test("dolphin|nautilus|thunar|pcmanfm")) then "📁"
    elif (app_id | ascii_downcase | test("slack|discord")) then "💬"
    elif (app_id | ascii_downcase | test("1password")) then "🔑"
    elif (app_id | ascii_downcase | test("spotify|rhythmbox|ario|clementine")) then "🎵"
    elif (app_id | ascii_downcase | test("vlc|mpv|totem")) then "🎬"
    elif (title | ascii_downcase | test("gofi")) then "🔃"
    elif (app_id | ascii_downcase | test("localsend")) then "📦"
    elif (app_id | ascii_downcase | test("libreoffice|writer|calc|gedit|xournalpp")) then "📄"
    elif (app_id | ascii_downcase | test("thunderbird|evolution|mail")) then "📧"
    elif (app_id | ascii_downcase | test("freecad")) then "🧊"
    elif (app_id | ascii_downcase | test("bambu")) then "🖨️"
    elif (app_id | ascii_downcase | test("obsidian")) then "🪨"
    elif (app_id | ascii_downcase | test("zoom")) then "📞"
    else ""
    end;

  sort_by(.workspace_id, .layout.pos_in_scrolling_layout[0], .layout.pos_in_scrolling_layout[1]) |
  map(. + {emoji: get_emoji(.app_id; .title)}) |
  . as $windows |
  to_entries |
  map(
    {
      key: .key,
      value: (.value + {
        last_in_workspace: (
          if (.key + 1) >= ($windows | length) then true
          else .value.workspace_id != $windows[.key + 1].workspace_id
          end
        )
      })
    }.value
  )'
