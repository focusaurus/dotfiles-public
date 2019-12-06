install-aur() {
  cd ~/aur
  git clone "https://aur.archlinux.org/$1.git"
  cd "$1"
  makepkg -si
}
