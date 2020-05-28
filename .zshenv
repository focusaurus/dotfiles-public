#!/usr/bin/env bash
gnubin() {
  dir="$1"

  if [[ -d "${dir}" ]]; then
    /usr/bin/find /usr/local/Cellar/{coreutils,findutils,gawk,gnu-indent,gnu-sed,gnu-tar,grep}/ -type d -name gnubin | {
      while IFS= read -r file_path; do
        add-path "${file_path}"
      done
    }
  fi
}

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
  # Normal system stuff comes early for security
  # So npm packages can't override basic commands like ls
  add-path "${HOME}/bin"
  # Allow GNU binaries to take precedent on macos
  # See https://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities#69332
  gnubin /usr/local/Cellar
  gnubin /usr/local/opt
  add-path "/usr/local/bin"
  add-path "/bin"
  add-path "/usr/bin"
  add-path "/sbin"
  add-path "/usr/sbin"
  add-path "/usr/X11/bin"
  add-path "${HOME}/.local/bin"
  add-path "${HOME}/projects/daily-todos/bin"
  add-path "${HOME}/projects/md-to-pdf/bin"
  add-path "${HOME}/.cargo/bin"
  add-path "${NVM_BIN}"
  add-path "/opt/nosqlbooster-mongodb"

  if [[ -e ~/.nvm/alias/default ]]; then
    add-path ~/".nvm/versions/node/$(cat ~/.nvm/alias/default)/bin"
  fi

  # Local pwd stuff
  add-path "${PWD}/script"
  add-path "${PWD}/bin"

  # For node and elm
  add-path "${PWD}/node_modules/.bin"

  export PATH
}
setup-path
