# macos setup notes
# sudoers and brew setup
#   - su - localadmin
#   - sudo visudo
#   - add a line for peterlyons
#   - run a bunch of sudo chown and sudo chmod commands to fix brew errors
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
