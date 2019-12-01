#!/usr/bin/env bash
add-path() {
  if [[ -d "${1}" ]]; then
    if [[ -z "${PATH}" ]]; then
      export PATH="${1}"
    else
      export PATH=$PATH:"${1}"
    fi
  fi
}

setup-path() {
   # shellcheck disable=SC2123
  PATH=
  # For node and elm
  add-path "${PWD}/node_modules/.bin"

  # Homebrew, goes first for python virtualenvs
  add-path "/usr/local/bin"

  # Normal system stuff comes early for security
  # So npm packages can't override basic commands like ls
  add-path "/bin"
  add-path "/usr/bin"
  add-path "/sbin"
  add-path "/usr/sbin"
  add-path "/usr/X11/bin"
  # Personal home dir stuff
  add-path "${HOME}/bin"
  add-path "${HOME}/.local/bin"
  add-path "${HOME}/projects/daily-todos/bin"
  add-path "${HOME}/projects/md-to-pdf/bin"
  # Visual Studio Code
  # add-path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  # golang
  add-path "${HOME}/projects/go/bin"
  # rust
  add-path "${HOME}/.cargo/bin"
  add-path "/usr/local/m-cli"
  if [[ -d "${NVM_BIN}" ]]; then
    add-path "${NVM_BIN}"
  fi
  if [[ -e ~/.nvm/alias/default ]]; then
    add-path ~/".nvm/versions/node/$(cat ~/.nvm/alias/default)/bin"
  fi
  # add-path "${HOME}/.rbenv/bin"
  # [[ -d "${HOME}/.rbenv/bin" ]] && eval "$(rbenv init -)"

  # Local pwd stuff
  add-path "${PWD}/script"
  add-path "${PWD}/bin"

  # For per-project python virtualenvs
  add-path "${PWD}/python/bin"
  add-path "${PWD}/env/bin"

  if [[ -n "${VIRTUAL_ENV}" ]]; then
    add-path "${HOME}/.virtualenvs/$(basename "${VIRTUAL_ENV}")/bin"
  fi

  export PATH
}
# setup-path
