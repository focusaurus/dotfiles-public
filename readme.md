# dotfiles and home directory

This repo contains my dotfiles - unix configuration files that typically live in one's home directory. This repo represents the git-tracked subset of my home directory.

## How this setup works with git

At the moment the approach I'm using is my actual home directory is a checked-out git work tree, as opposed to any symlink-based approach. It's primarily based on 2 articles

- [How to store dotfiles](https://www.atlassian.com/git/tutorials/dotfiles) tutorial from Atlassian
- [Michael Sloan's approach](https://github.com/mgsloan/mgsloan-dotfiles/blob/master/env/home-dir-git.md)

## Key parts of my stack

- lightdm as display manager
  - Suggestion from Ross. I don't particularly like it. Would prefer if keyboard layout was displayed and switchable via mouse on the lock screen
- i3wm
  - Suggestion from Ross. I think the keybinding modes has a lot of potential, but otherwise I don't like it and I will be shopping for a less-radical window manager
  - I don't think I get much benefit from tiling as 95% of the time I use maximized windows and 5% of the time I want side-by-side view and i3 wants me to prepare for side-by-side before launching a window vs easily switching after I have both windows launched
- simple X hotkey daemon (sxhkd) for hotkey bindings
  - So far so good. Very nice. Very clean design.
- zsh
  - I prefer this to bash as it really is better, but most of my scripts for non-interactive stuff are still coded as bash scripts (not bourne, bash)
- tmux
  - I'm using this because the cool kids do but I hate it mostly


## Philosophy of mind: menus and hotkeys

My approach to desktop computing is driven primarily by what's easy for my mind. Specifically it's really hard for me to remember hotkeys unless I use them near-constantly, but it's really easy for me to remember words and phrases for commands. I suspect I can only remember maybe ~25 hotkeys with no more than like 4 new ones at a time. But I know from looking at my command set that I can remember several hundred commands, combing regular command line programs, my custom programs, and my fuzzball shortcuts (which are really just programs too).

So I manage things in the following tiers:

### Tier 1: rarely used: terminal command line

I just switch to my always-on terminal and my tmux "misc" session and type a command line. I also do have a hotkey to pull down a `tilda` floating terminal and sometimes I use that. I don't bother scripting/automating things unless I'm doing them regularly and they seem stable and well-understood.

### Tier 2: occassionally used: fuzzy-filter rofi menus

Things that I do repeatedly but not necessarily every day are scripted in my fuzzball script directory and I access them with a dedicated hotkey followed by rofi-driven fuzzy filtering. It works great and I currently have ~350 of these. These includes several categories:

- Web bookmarks
- Web searches that prompt for a query string
- autotype advanced scripts
  - Simple expansion snippets are handled separately
  - This is for more complex things that fill out web forms and futz with keystrokes, mouse etc via xdotool or similar
- Data manipulation using the X clipboard as an I/O channel
  - Pretty-printing some JSON etc that's on the clipboard and replacing it with the pretty version
  - Decoding base64, hex, etc
- assorted desktop manipulation
  - toggling bluetooth

For regular text snippet expansion, I have a separate hotkey and a separate rofi menu for those.

### Tier 3: Frequently used: hotkeys

For things I do throughout a session like window manipulation, switching to applications, volume adjustment, I have dedicated hotkeys for those. I try to use the function keys with no modifiers heavily as I generally want to minimize use of modifier keys, but a small set of 1-modifier hotkeys seems unavoidable. I try to avoid 2-modifier hotkeys as they are so unergonomic to type.

At the moment I am not using sticky keys and getting good mileage out of `xcape` to give dual purpose to some modifiers: when pressed and released on their own, they send an alternate keystroke or series of keystrokes, which I then bind to a script. However, I have used sticky keys extensively in the past and I would consider it again if I found maybe a good modal hotkey system and good support in X11 if it wasn't glitchy.

See `~/.config/sxhkd/sxhkdrc` and `~/.config/i3/config` for my current set of keybindings.
