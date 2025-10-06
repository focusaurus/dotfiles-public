##### project specific path #####
chpwd-path() {
  if [[ -d .git || -d bin || -d node_modules/.bin || -d python/bin ]]; then
    setup-path
  fi
}

##### node version manager (nvm) #####
#source "$(dirname "${(%):-%N}")/node.sh"
chpwd-nvm() {
  if [[ -f ".nvmrc" ]]; then
    nvm use
    # nvm use --silent >/dev/null
  fi
}

##### set terminal title #####
# auto-terminal-title() {
# shellcheck disable=SC2076
# if [[ "${PWD}" =~ "/${USER}/projects/" ]]; then
# local project_name
# project_name=$(pwd | cut -d / -f 5)
# fi
# local dir_name
# dir_name="$(basename "$(pwd)")"
# AUTO_TERMINAL_TITLE="${dir_name}"
# if [[ -n "${project_name}" && "${dir_name}" != "${project_name}" ]]; then
# AUTO_TERMINAL_TITLE="${project_name}: ${dir_name}"
# fi
# }

##### activate python virtualenv #####
#chpwd-virtualenv() {
#  if [[ ! -e /usr/local/bin/virtualenvwrapper.sh ]]; then
#    return
#  fi
#  if [[ -e ".virtualenv" ]]; then
#    workon "$(cat .virtualenv)"
#  fi
#}

#chpwd-terminal-title() {
#  if [[ -z "${TERMINAL_TITLE}" ]]; then
#    auto-terminal-title
#  fi
#}

#precmd-terminal-title() {
#  for TT in "${TERMINAL_TITLE}" "${AUTO_TERMINAL_TITLE}"; do
#    if [[ -n "${TT}" ]]; then
#      print -Pn "\e]0;${TT}\a"
#      break
#    fi
#  done
#}

##### automagic on cd #####

if [[ -n "${ZSH_VERSION}" ]]; then
  autoload -U add-zsh-hook
  # add the hooks and run immediately as well
  add-zsh-hook chpwd chpwd-path && chpwd-path
  # add-zsh-hook chpwd chpwd-terminal-title && chpwd-terminal-title
  add-zsh-hook chpwd chpwd-nvm && chpwd-nvm
  # add-zsh-hook chpwd chpwd-virtualenv && chpwd-virtualenv

  ##### automagic before each command #####
  # add-zsh-hook precmd precmd-terminal-title
fi
