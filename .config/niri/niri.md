# Overview

I am running arch linux the X11 window system. My display manager is lightdm. My window manager is awesomewm. I have been on this setup for many years, but I'd like to experiment with wayland instead of X11 and specifically the niri window manager.

I want to change my linux configuration in a safe and gradual such that at all times I can still log into X11 and awesomewm reliably, but gain the ability to also log in and start wayland+niri to try it out and experiment.

Can you guide me through this process with checkpoints along the way?

# notes on packages and approaches
- clipboard history: cliphist (go)
- notifications: dunst (works fine with both X11 and wayland no changes)
- gofi: needed a dedicated niri config
    - needed a new ~/bin/focus-niri script that uses `niri msg -j windows`
- fuzz-script-choose: uses `wofi --dmenu` under wayland
- fuzz-snippet: uses wtype to simulate ctrl+v
- wifi: iwd and iwgtk. Had to disable NetworkManager and enable iwd in systemctl

# To do

- [x] figure out how to run Obsidian under wayland
  - OBSIDIAN_USE_WAYLAND=1 and -enable-features=UseOzonePlatform -ozone-platform=wayland
- [x] how to copy from ghostty and paste into ghostty
- [x] get 1Password working and configured in gofi
- [x] gofi fuzz-script-choose
- [x] app-nav and global keybinds for it
- [x] notifications daemon setup & config
- [x] some wayland clipboard manager
- [x] scripted typed snippets with some alternative to xdotool
- [x] flameshot screenshots
- [x] add-snippet something like zenity or yad dialogs
- [ ] bambu studio
- [x] fuzz-snippet round 2
- [x] get mouse extra buttons working
- [x] screen lock
- [ ] window switcher fuzzy popup thing

