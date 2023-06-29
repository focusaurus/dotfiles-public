arch-install-package() {
  # yay --nodiffmenu --sync "$@"
  yup "$@"
  hash -r
}

arch-search-packages() {
  # yay -Ss "$@" | less
  yup "$@"
}
# TODO curl -s "https://get.sdkman.io" | bash

arch-update-packages() {
  topgrade
}

arch-update-keyring() {
  sudo pacman -Sy archlinux-keyring
}

arch-save-packages() {
  pacman -Qet | awk '{print $1}' | sort >"${HOME}/.config/arch-linux/pacman-qet-$(uname -n).txt"
  systemctl list-unit-files | grep enabled | awk '{print $1}' | sort >"${HOME}/.config/arch-linux/systemd-services-$(uname -n).txt"
}

arch-list-packages() {
  pacman -Qet | sort
}

arch-list-package-files() {
  pacman -Fl "$@"
}

arch-uninstall-package() {
  yay -Rs "$@"
}

arch-uninstall-orphans() {
  pacman -Qtdq | ifne sudo pacman -Rns -
}

arch-clear-cache() {
  sudo pacman -Sc
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
  I3SOCK="/run/user/${UID}/i3/ipc-socket.$(pidof i3)"
  export I3SOCK
}

view-systemd-service-logs() {
  service=$(find ~/.config/systemd/user -name '*.service' -print0 |
    xargs -0 -n 1 basename |
    ~/bin/fuzzy-filter "$@")
  journalctl --user --unit "${service}"
}

arch-pacman-cheat-sheet() {
  cat <<EOF | less
Querying package databases

Pacman queries the local package database with the -Q flag, the sync database with the -S flag and the files database with the -F flag. See pacman -Q --help, pacman -S --help and pacman -F --help for the respective suboptions of each flag.

Pacman can search for packages in the database, searching both in packages' names and descriptions:

$ pacman -Ss string1 string2 ...




Sometimes, -s's builtin ERE (Extended Regular Expressions) can cause a lot of unwanted results, so it has to be limited to match the package name only; not the description nor any other field:

$ pacman -Ss '^vim-'




To search for already installed packages:

$ pacman -Qs string1 string2 ...




To search for package file names in remote packages:

$ pacman -F string1 string2 ...




To display extensive information about a given package:

$ pacman -Si package_name

For locally installed packages:

$ pacman -Qi package_name





To retrieve a list of the files installed by a package:

$ pacman -Ql package_name




To retrieve a list of the files installed by a remote package:

$ pacman -Fl package_name




To verify the presence of the files installed by a package:

$ pacman -Qk package_name




Passing the k flag twice will perform a more thorough check.

To query the database to know which package a file in the file system belongs to:

$ pacman -Qo /path/to/file_name




To query the database to know which remote package a file belongs to:

$ pacman -F /path/to/file_name




To list all packages no longer required as dependencies (orphans):

$ pacman -Qdt




Tip: Add the above command to a pacman post-transaction hook to be notified if a transaction orphaned a package. This can be useful for being notified when a package has been dropped from a repository, since any dropped package will also be orphaned on a local installation (unless it was explicitly installed). To avoid any "failed to execute command" errors when no orphans are found, use the following command for Exec in your hook: /usr/bin/bash -c "/usr/bin/pacman -Qtd || /usr/bin/echo '=> None found.'"

To list all packages explicitly installed and not required as dependencies:

$ pacman -Qet




See Pacman/Tips and tricks for more examples.
Pactree
EOF
}
