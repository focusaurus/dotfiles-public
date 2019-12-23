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

save-installed-packages() {
  (pacman -Qet | awk '{print $1}' | {
    while IFS= read -r name; do
      if pacman -Ss "${name}" >/dev/null; then
        echo "pacman:${name}"
      else
        echo "yay:${name}"
      fi
    done
  }) | sort | tee >~/.config/arch-linux/pacman-qet.txt
}
