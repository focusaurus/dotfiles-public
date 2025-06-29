alias nvim-unplugged="nvim -u ~/.config/nvim/unplugged-init.lua -p"
alias vu=nvim-unplugged
lv() {
  NVIM_APPNAME=lazyvim nvim -p "$@"
}
alias paste-to-vim="te-clipboard"
alias v="nvim -p"
#Note to self, use sudoedit to edit files with my nvim config as root

alias nvim-plugin-update="nvim -c PackerSync"
alias nvim-plugin-install="nvim -c PackerInstall"
te-vimrc() {
  (
    cd ~/.config/nvim || exit
    ~/bin/text-editor ./*init.lua lua/*/*.lue lua/*.lua
  )
}
