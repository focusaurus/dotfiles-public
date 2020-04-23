macos-fix-compaudit() {
  # run this as localadmin
  sudo chown peterlyons:staff /usr/local/share/zsh \
    /usr/local/share/zsh/site-functions \
    /usr/local/share/zsh/site-functions/_brew_cask \
    /usr/local/share/zsh/_brew
  sudo chmod g-w /usr/local/share/zsh
}

macos-install-brew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

_brew_bundle() {
  cd ~/.config/homebrew || return 1
  echo "$1 '$2'" >> Brewfile
  brew bundle
  cd - || return 1
}

macos-brew-cask() {
  _brew_bundle cask "$@"
}

macos-brew() {
  _brew_bundle brew "$@"
}
