export TERM="xterm-256color"
if ~/bin/have-exe kitty; then
  export TERM="xterm-kitty"
elif ~/bin/have-exe termite; then
  export TERM="xterm-termite"
fi
alias aoeu="setxkbmap us"
alias asdf="setxkbmap dvorak"
alias dv="setxkbmap dvorak"
alias us="setxkbmap us"
alias isomount="mount -t iso9660 -o loop"
alias sai="sudo apt install"
alias CAPS="xdotool key Caps_Lock"
open() {
  for target in "$@"; do
    xdg-open "${target}" &
  done
}

battery() {
  upower -e |
    grep /devices/battery_BAT |
    xargs -n 1 upower -i |
    grep -E -i '(native-path:|percentage:|state:)'
}

#Many default shells alias these to the "-i" interactive version
#I don't like that. Undo it.
for command in rm mv cp; do
  if alias | grep -E -q "^${command}="; then
    unalias ${command}
  fi
done
