function squeezebox-copy() {
  if ! findmnt --list --noheadings --output target,source --types vfat; then
    mountomatic
  fi
  rsync -avz ~/git.peterlyons.com/3d-prints/squeezebox-keyboard /mnt/usb-drive
  umountomatic
}

function gcode-to-usb() {
  file=$(
    find ~/git.peterlyons.com/3d-prints -type f -iname '*.gcode' -print0 |
      xargs -0 ls -t |
      head |
      fzf
  )
  cp "${file}" "/run/media/${USER}/"*
}
