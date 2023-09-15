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
shopt -s nocaseglob
shopt -s nocasematch
# case-insensitive match on the file extension
# to dispatch an appropriate preview program
case "${1##*.}" in
mov | mp4 | avi)
  # don't preview movies
  echo "we don't preview movies in the terminal in lf. Hit right arrow to launch a video player."
  # exec mpv "$1"
  ;;
pdf)
  exec pdftotext "$1" -
  ;;
png | jpg | jpeg | heic)
  echo "no preview for photos. Hit right arrow to launch a viewer."
  ;;
zip)
  exec zipinfo "$1"
  ;;
gz | bz2)
  exec tar tf "$1"
  ;;
*)
  # ~/bin/log "$0" previewing "$1"
  exec bat --paging=always --color=always --style=plain "$1"
  ;;
esac
