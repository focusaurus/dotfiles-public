# Overview

I am running arch linux the X11 window system. My display manager is lightdm. My window manager is awesomewm. I have been on this setup for many years, but I'd like to experiment with wayland instead of X11 and specifically the niri window manager.

I want to change my linux configuration in a safe and gradual such that at all times I can still log into X11 and awesomewm reliably, but gain the ability to also log in and start wayland+niri to try it out and experiment.

Can you guide me through this process with checkpoints along the way?

# To do

- [x] figure out how to run Obsidian under wayland
  - OBSIDIAN_USE_WAYLAND=1 and -enable-features=UseOzonePlatform -ozone-platform=wayland
- [x] how to copy from ghostty and paste into ghostty
- [x] get 1Password working and configured in gofi
- [x] gofi fuzz-script-choose
- [x] app-nav and global keybinds for it
- [ ] some wayland clipboard manager
- [x] scripted typed snippets with some alternative to xdotool
- [x] get mouse extra buttons working
- [ ] screen lock
- [ ] window switcher fuzzy popup thing
- [ ] notifications daemon setup & config

