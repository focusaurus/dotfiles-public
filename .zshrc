# zsh setup

#emacs mode
bindkey -e

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

source-if-exists() {
  for file in "$@"; do
    if [[ -e "${file}" ]]; then
      source "${file}"
    fi
  done
}

source-if-exists ~/.config/zsh/*.sh
source-if-exists ~/git.peterlyons.com/mailchimp/mailchimp.sh
source-if-exists ~/git.peterlyons.com/reaction-common/reaction-commerce.sh
source-if-exists ~/.devtool.env
source-if-exists "${HOME}/.config/zsh/os/$(uname).sh"
source-if-exists ~/.nvm/nvm.sh
