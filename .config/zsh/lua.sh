add-path "${HOME}/.luarocks/bin"

if ~/bin/have-exe luarocks; then
  eval $(luarocks path --bin | grep -v "export PATH=")
fi

