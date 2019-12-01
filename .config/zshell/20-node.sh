#!/usr/bin/env bash
# shellcheck disable=SC2148
########## node.js ##########
alias enep='export NODE_ENV=production'
alias enmp='npm --registry registry.npmjs.eu'
alias shrinkwrap='rm npm-shrinkwrap.json; npm install && npm shrinkwrap'
alias nsw='npm shrinkwrap'
alias nr='npm --silent run'
alias lt='l10ns'
alias ni='nvm exec v8.9.0 node --inspect'
alias nib='nvm exec v8.9.0 node --inspect-brk'
alias tnib='NODE_ENV=test nvm exec v8.9.0 node --inspect-brk'
alias t='NODE_ENV=test tap --reporter=spec --timeout=3'
alias mdb='NODE_ENV=test mocha --inspect-brk'
alias debug-node-pid='kill -SIGUSR1'
alias ndj='node . | json -g -a -0 -e "delete this.v; delete this.hostname;delete this.level; delete this.pid; delete this.name"'
alias bunson='json -g -a -0 -e "delete this.v; delete this.hostname;delete this.level; delete this.pid; delete this.name"'
alias td='NODE_ENV=test node --inspect-brk'

npm-g() {
  local package="$1"
  if grep $1 ~/projects/dotfiles/npm-globals.txt; then
    echo "${package} already available"
    return
  fi
  echo "${package}" >>~/projects/dotfiles/npm-globals.txt
  setup-stable-node
}

# http://2ality.com/2016/01/locally-installed-npm-executables.html
npm-do() {
  (
    PATH=$(npm bin):$PATH
    eval "${@}"
  )
}

nis() {
  npm install "$@" --save --save-exact
  hash -r
}

nisd() {
  npm install "$@" --save-dev --save-exact
  hash -r
}

nbin() {
  local command="$1"
  shift
  "$(npm bin)/${command}" "$@"
}

setup-node-lts() {
  nvm install --lts
  # shellcheck disable=SC2046
  npm install --global $(xargs <~/projects/dotfiles/npm-globals.txt)
  # To run something in default:
  # ~/.nvm/versions/node/$(cat ~/.nvm/alias/default)/bin
  # Or
  # nvm exec default html2jade
}

alias nus="npm uninstall --save"
alias nusd="npm uninstall --save-dev"
alias npmcomp=". <(npm completion)"
alias mo="NODE_ENV=test LOG_LEVEL=fatal mocha"
alias eslintrc="ht https://raw.githubusercontent.com/focusaurus/peterlyons.com/master/.eslintrc > .eslintrc"

npm-updates() {
  local reject
  local dir
  for dir in carson/white-glove chaimel config3 express_code_structure mjournal plws/code; do
    echo "#### ${dir}"
    reject=""
    cd "${HOME}/projects/${dir}" || return
    if [[ -n "$(git status --porcelain)" ]]; then
      echo "Working directory not clean. Skipping $PWD"
      continue
    fi
    if [[ "${dir}" == "mjournal" ]]; then
      reject="--reject knex"
    fi
    nvm use default
    IFS=" " ncu ${reject} -u
  done
}

##### nvm (node version manager) #####
# placeholder nvm shell function
# On first use, it will set nvm up properly which will replace the `nvm`
# shell function with the real one
nvm() {
  for nvmsh in "${HOME}/.nvm/nvm.sh" "/usr/local/opt/nvm/nvm.sh"; do
    if [[ -f "${nvmsh}" ]]; then
      NVM_DIR="$(dirname "${nvmsh}")"
      export NVM_DIR
      # shellcheck disable=SC1090
      source "${nvmsh}"
      if [[ -e "${HOME}/.nvm/alias/default" ]]; then
        PATH="${PATH}:${HOME}.nvm/versions/node/$(cat ~/.nvm/alias/default)/bin"
      fi
      # source "${NVM_DIR}/$(basename "${SHELL}")_completion"
      # invoke the real nvm function now
      nvm "$@"
      return
    fi
  done
  echo "nvm is not installed" >&2
}

devlog() {
  file="$1"
  grep -e '^\{' "${file}" |
    npx --quiet json -0age "delete this.v; delete this.file; delete this.groupId; delete this.topic;delete this.hostname;delete this.level; delete this.pid; delete this.name"
}

##### npm config #####
# Use env vars because npm login stores credentials in ~/.npmrc so
# we need to keep that out of git

# export CXXFLAGS="-fno-omit-frame-pointer"
# export GYP_DEFINES="v8_enable_disassembler=1 v8_object_print=1"
export NODE_ENV="development"
export NODE_REPL_HISTORY_FILE=~/.node-repl-history
export NPM_CONFIG_INIT_AUTHOR_EMAIL='pete@peterlyons.com'
export NPM_CONFIG_INIT_AUTHOR_NAME='Peter Lyons'
export NPM_CONFIG_INIT_AUTHOR_URL='http://peterlyons.com'
export NPM_CONFIG_INIT_LICENSE='MIT'
export NPM_CONFIG_INIT_VERSION='1.0.0'
export NPM_CONFIG_LOGLEVEL='error'
export NPM_CONFIG_SAVE_EXACT='true'
export NPM_CONFIG_SAVE_PREFIX=''
export NPM_CONFIG_SPIN=false
