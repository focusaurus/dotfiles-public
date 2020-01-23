install-arch-package() {
  yay -S "$@"
  hash -r
}

search-arch-packages() {
  yay -Ss "$@" | less
}
# TODO curl -s "https://get.sdkman.io" | bash

save-arch-packages() {
  pacman -Qet | awk '{print $1}' | sort >"${HOME}/.config/arch-linux/pacman-qet-$(uname -n).txt"
  systemctl list-unit-files | grep enabled | awk '{print $1}' | sort >"${HOME}/.config/arch-linux/systemd-services-$(uname -n).txt"
}

uninstall-arch-package() {
  yay -Rs "$@"
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

alias i3config="~/bin/text-editor ~/.config/i3/config"
reset-i3sock() {
  export I3SOCK="/run/user/${UID}/i3/ipc-socket.$(pidof i3)"
}
