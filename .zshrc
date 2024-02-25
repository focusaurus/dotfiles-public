source-if-exists() {
  for file in "$@"; do
    if [[ -e "${file}" ]]; then
      source "${file}"
    fi
  done
}

export BREW_PREFIX="/opt/homebrew"
if [[ ! -e "${BREW_PREFIX}" && -e "/usr/local" ]]; then
  export BREW_PREFIX="/usr/local"
fi
# put this early to make sure compinit is run
source-if-exists ~/.config/zsh/zsh.sh
source-if-exists ~/.config/zsh/*.sh
# There's an ordering issue with the glob, so source
# this manually last
source-if-exists ~/.config/zsh/fuzzy.sh
source-if-exists ~/git.peterlyons.com/focus-retreat-center/frc.sh
source-if-exists ~/git.peterlyons.com/float-health/float-health.sh
source-if-exists ~/.devtool.env
source-if-exists "${HOME}/.config/zsh/os/$(uname).sh"
source-if-exists ~/.nvm/nvm.sh
source-if-exists "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source-if-exists "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# 1password
source-if-exists ~/.opam/opam-init/init.zsh
