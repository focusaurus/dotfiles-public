# zsh setup

##### completion #####
fpath=(~/.config/zsh/completions $fpath)
autoload -Uz compinit && compinit
#autoload -Uz compinstall && compinstall

# Trigger basic filesystem completion anywhere in
# any command with ctrl+t
# https://stackoverflow.com/a/49968871/266795
zle -C complete-file complete-word _generic
zstyle ':completion:complete-file::::' completer _files
bindkey '^t' complete-file

set -o emacs

source-if-exists() {
  for file in "$@"; do
    if [[ -e "${file}" ]]; then
      source "${file}"
    fi
  done
}

have_exe() {
  command -v "$1" >/dev/null
}


source-if-exists ~/.config/zsh/*.sh
source-if-exists ~/work-reaction/common/shell-setup.sh
source-if-exists ~/mailchimp/mailchimp.sh
source-if-exists "${HOME}/.config/zsh/os/$(uname).sh"
source-if-exists "${HOME}/.nvm/nvm.sh"
#source-if-exists ~/github/Aloxaf/fzf-tab/fzf-tab.zsh

export SDKMAN_DIR="/home/plyons/.sdkman"
source-if-exists "${SDKMAN_DIR}/bin/sdkman-init.sh"

if have_exe navi; then
  source <(navi widget zsh)
fi
