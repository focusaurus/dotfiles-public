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
# put this early to make sure nvm function is defined before chpwd-nvm runs
source-if-exists ~/.config/zsh/node.sh
source-if-exists ~/.config/zsh/*.sh
# There's an ordering issue with the glob, so source
# this manually last
source-if-exists ~/.config/zsh/fuzzy.sh
source-if-exists ~/projects/float-health/float-health.sh
source-if-exists ~/.devtool.env
source-if-exists "${HOME}/.config/zsh/os/$(uname).sh"
# nvm.sh is intentionally NOT sourced eagerly here - it's ~300ms+ of cost
# (nvm_auto resolving/using the default version across all installed
# versions) that we don't need at startup. node.sh defines a lazy `nvm`
# shell function that sources the real nvm.sh on first actual use, and
# chpwd.sh's chpwd-nvm calls that same function when cd'ing into a repo
# with a .nvmrc. The default version's bin/ is already on PATH via
# .zshenv's setup-path, so plain `node`/`npm` work without nvm loaded.
source-if-exists "${BREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source-if-exists "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
# 1password
source-if-exists ~/.opam/opam-init/init.zsh

[[ -s "/Users/plyons/.gvm/scripts/gvm" ]] && source "/Users/plyons/.gvm/scripts/gvm"
