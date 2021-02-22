function squeezebox-copy() {
  if ! findmnt --list --noheadings --output target,source --types vfat; then
    mountomatic
  fi
  rsync -avz ~/git.peterlyons.com/3d-prints/squeezebox-keyboard /mnt/usb-drive
  umountomatic
}
