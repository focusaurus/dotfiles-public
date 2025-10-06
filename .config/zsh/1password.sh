if ~/bin/have-exe op; then
  eval "$(op completion zsh)"; compdef _op op
fi

op-add-ssh-key() {
  cat >/dev/null <<'EOF'
op-add-ssh-key is no longer necessary!

1password ssh agent will automatically load private keys
from accounts+vaults available in the local 1password app setup.

Just make sure SSH_AUTH_SOCK points to the 1password ssh agent socket.
EOF
}

