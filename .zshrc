# zshell setup
source-if-exists() {
  for file in "$@"; do
	  if [[ -e "${file}" ]]; then
		  . "${file}"
	  fi
  done
}
source-if-exists ~/.config/zshell/zshell.sh
source-if-exists ~/.config/zshell/[0-9]*.sh

# OS-specific stuff
source-if-exists "${HOME}/.config/zshell/$(uname).sh" "${HOME}/.nvm/nvm.sh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/plyons/.sdkman"
[[ -s "/home/plyons/.sdkman/bin/sdkman-init.sh" ]] && source "/home/plyons/.sdkman/bin/sdkman-init.sh"
