##### python virtualenv #####
# this is a virtualenvwrapper placeholder for lazy loading
# first run it sets up virtualenvwrapper which will define the real "workon"
workon() {
  if [[ -s /usr/local/bin/virtualenvwrapper.sh ]]; then
    source /usr/local/bin/virtualenvwrapper.sh
    add-zsh-hook chpwd auto-python-virtualenv && auto-python-virtualenv
    workon "$@"
  else
    echo "virtualenvwrapper is not installed" >&2
    return 1
  fi
}
export VIRTUAL_ENV_DISABLE_PROMPT=yes
export WORKON_HOME=~/.virtualenvs
# alias ap="ansible-playbook"
# alias avd="ansible-vault decrypt"
# alias ave="ansible-vault edit"
python-black-formatter() {
  env_dir=~/python-envs/black
  if [[ ! -e "${env_dir}" ]]; then
    virtualenv --python=/usr/bin/python3 "${env_dir}"
  fi
  "${env_dir}/bin/black" "$@"
}
