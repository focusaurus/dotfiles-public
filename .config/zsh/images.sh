image-resize-in-place() {
  width="${WIDTH:-800}"
  for file_path in "$@"; do
    convert "${file_path}" -resize "${width}" - | sponge "${file_path}"
  done
}

alias image-view="feh --fullscreen --auto-zoom -."
if [[ "${XDG_SESSION_TYPE}" == "wayland" ]]; then
  alias image-view="imv -s full -w image-view"
fi
