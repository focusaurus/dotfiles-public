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

export SDKMAN_DIR="/home/plyons/.sdkman"
source-if-exists "${SDKMAN_DIR}/bin/sdkman-init.sh"
