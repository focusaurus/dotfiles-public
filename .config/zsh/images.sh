image-smallify() {
  input="$1"
  output="$2"
  width="${3:-600}"
  convert "${input}" -resize "${width}" "${output}"
}

alias image-view="feh --fullscreen --auto-zoom -."
