install-arch-package() {
  yay -S "$@"
  hash -r
}

search-arch-packages() {
  yay -Ss "$@" | less
}
# TODO curl -s "https://get.sdkman.io" | bash

save-installed-packages() {
  (pacman -Qet | awk '{print $1}' | {
    while IFS= read -r name; do
      if pacman -Ss "${name}" >/dev/null; then
        echo "pacman:${name}"
      else
        echo "yay:${name}"
      fi
    done
  }) | sort | tee >"${HOME}/.config/arch-linux/pacman-qet-$(uname -n).txt"
}

uninstall-via-pacman() {
  sudo pacman -R "$@"
}

sample-rofi-themes() {
  find /usr/share/rofi/themes -type f -name '*.rasi' | {
    while IFS= read -r file_path; do
      cat <<EOF | rofi -dmenu -theme "${file_path}"
${file_path}
apple
banana
cucumber
dirty rice
${file_path}
EOF
    done
  }
}
