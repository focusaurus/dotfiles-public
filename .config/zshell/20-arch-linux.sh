install-via-yay() {
  yay -S "$@"
  hash -r
}

install-via-pacman() {
  sudo pacman -S "$@"
  hash -r
}

search-pacman-yay() {
  (
    echo '##### pacman #####'
    pacman -Ss "$@"
    echo '##### yay #####'
    yay -Ss "$@"
  ) | less
}
# curl -s "https://get.sdkman.io" | bash
