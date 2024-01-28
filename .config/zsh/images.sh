image-resize-in-place() {
  width="${WIDTH:-800}"
  for file_path in "$@"; do
    convert "${file_path}" -resize "${width}" - | sponge "${file_path}"
  done
}

alias image-view="feh --fullscreen --auto-zoom -."
