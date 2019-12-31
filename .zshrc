# zshell setup
source-if-exists() {
  for file in "$@"; do
    if [[ -e "${file}" ]]; then
      source "${file}"
    fi
  done
}

source-if-exists ~/.config/zshell/*.sh
source-if-exists ~/work-reaction/common/shell-setup.sh
source-if-exists "${HOME}/.config/zshell/os/$(uname).sh"
source-if-exists "${HOME}/.nvm/nvm.sh"
#source-if-exists ~/github/Aloxaf/fzf-tab/fzf-tab.zsh

export SDKMAN_DIR="/home/plyons/.sdkman"
source-if-exists "${SDKMAN_DIR}/bin/sdkman-init.sh"
