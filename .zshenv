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
  # best to have go tools from projects before homebrew
  add-path "${HOME}/go/bin"

  # Allow GNU binaries to take precedent on macos
  # See https://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities#69332
  # https://ryanparman.com/posts/2019/using-gnu-command-line-tools-in-macos-instead-of-freebsd-tools/
  # Regenerate this list with the following command
  #  /usr/bin/find /usr/local/opt -follow -name gnubin -type d
  add-path /usr/local/opt/coreutils/libexec/gnubin
  add-path /usr/local/opt/gnu-indent/libexec/gnubin
  add-path /usr/local/opt/gnu-tar/libexec/gnubin
  add-path /usr/local/opt/grep/libexec/gnubin
  add-path /usr/local/opt/gnu-sed/libexec/gnubin
  add-path /usr/local/opt/gawk/libexec/gnubin
  add-path /usr/local/opt/findutils/libexec/gnubin

  add-path /opt/homebrew/bin
  add-path "${HOME}/.n/bin"
  add-path "${HOME}/.cargo/bin"
  add-path "${HOME}/.luarocks/bin"
  add-path "/usr/local/bin"
  add-path "/bin"
  add-path "/usr/bin"
  add-path "/sbin"
  add-path "/usr/sbin"
  add-path "/usr/X11/bin"
  add-path "${HOME}/.local/bin"
  add-path "${HOME}/projects/md-to-pdf/bin"
  add-path "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin"
  add-path "/Applications/Hammerspoon.app/Contents/Frameworks/hs"
  add-path "/Applications/Ghostty.app/Contents/MacOS"
  add-path "/opt/creality-print"

  if [[ -e ~/.nvm/alias/default ]]; then
    add-path ~/".nvm/versions/node/$(cat ~/.nvm/alias/default)/bin"
  fi

  # For node and elm
  add-path "${PWD}/node_modules/.bin"

  export PATH
}
setup-path

if ~/bin/have-exe luarocks; then
  eval $(luarocks path --bin | grep -v "export PATH=")
fi

export PAGER=less
export BREW_PREFIX="/opt/homebrew"
if [[ "${XDG_SESSION_TYPE}" == "wayland" ]]; then
  export ELECTRON_OZONE_PLATFORM_HINT=wayland
fi
if ~/bin/have-exe bat; then
  export PAGER="bat --paging=always"
fi
