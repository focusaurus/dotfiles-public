# hyprland setup notes

## Keybindings Reference

- super+t = launch terminal (kitty)
- super+shift+x = exit hyprland
- super+x = close window

## TODO

- [x] fuzzball (F11)
- [x] snippets (F12)
- [x] screen lock
- [x] firefox dialogs
- [x] gofi
- [x] freecad
- [x] touchpad natural scroll
- [ ] app nav
- [x] terminal quick
  - [ ] print hyprctl clients json
- [x] desktop background
- [x] clipboard manager
- [x] gofi journal
- [x] wev floating rule
- [x] screenshots
- [ ] screen idle lock
- [x] color theme from peterlyons.com
- [ ] 1Password auth prompt floating workspace unset
- [ ] gofi-based side-by side
  - manually have main window focused
  - leader h s (gofi > hyprland > s)
  - gofi runs hyprctl dispatch workspace previous
  - main app is focused again
  - launch wofi window list to select second window
  - dispatch a command to move that window to the current workspace
