# dotfiles and home directory

This repo contains my dotfiles - unix configuration files that typically live in one's home directory. This repo represents the git-tracked subset of my home directory.

## How this setup works with git

At the moment the approach I'm using is my actual home directory is a checked-out git work tree, as opposed to any symlink-based approach. It's primarily based on 2 articles

- [How to store dotfiles](https://www.atlassian.com/git/tutorials/dotfiles) tutorial from Atlassian
- [Michael Sloan's approach](https://github.com/mgsloan/mgsloan-dotfiles/blob/master/env/home-dir-git.md)

Briefly, it goes like this:

- Use a bare repo at `~/.home.git` just to avoid the fact that git by default searches upward in the filesystem for any directory named `.git`. That means if you have non-git-repos in your home directory and accidentally run git commands there's some chance it affects your dotfiles repo. Not sure exactly how this would play out, I guess an errant `git add .` perhaps? But anyway, just choosing a different name solves that.
  - As a consequence of the nonstandard name, we need to tell git how our setup works when we do want to work with it.
    - I do this as needed by setting 2 environment variables by way of a pair of 1-liner zsh functions.

```sh

dotfiles-begin() { export GIT_DIR="${HOME}/.home.git" GIT_WORK_TREE="${HOME}" }

dotfiles-end() { unset GIT_DIR GIT_WORK_TREE }
```

  - I have an indicator in my prompt to remind me when I'm in this mode
  - I do it this way so my dozens of git alias and shell functions just work. Other tutorials have techniques like dedicated aliases or functions that cause everything else git related to be broken, so this is better.
- Another consequence of this approach is I need a large `~/.gitignore` which I maintain and add to regularly as programs write nonimportant stuff to my home directory
  - Maintaining this file is the main trade-off of this dotfiles approach compared to some symlink management approach. It's easy enough to maintain this large gitignore file, but it does require a lot of small tasks, especially when my software stack is undergoing a lot of churn, which has been the case recently, but should be starting to stabilize for a while now
- My global gitignore file is at the default path of `~/.config/git/ignore`

## Key parts of my stack (linux)

- lightdm as display manager
  - Suggestion from Ross. I don't particularly like it. Would prefer if keyboard layout was displayed and switchable via mouse on the lock screen
- i3wm
  - Suggestion from Ross. I think the keybinding modes has a lot of potential, but otherwise I don't like it and I will be shopping for a less-radical window manager
  - I don't think I get much benefit from tiling as 95% of the time I use maximized windows and 5% of the time I want side-by-side view and i3 wants me to prepare for side-by-side before launching a window vs easily switching after I have both windows launched
  - I did a bit of shopping around for other window managers and the landscape seems really bleak, so for the moment I'm going to stick with i3wm. I'm getting better at its way of working and understanding how to get 2 existing windows side-by-side and then back to maximized
- simple X hotkey daemon (sxhkd) for hotkey bindings
  - So far so good. Very nice. Very clean design.
- zsh
  - I prefer this to bash as it really is better, but most of my scripts for non-interactive stuff are still coded as bash scripts (not bourne, bash)
- tmux
  - I'm using this because the cool kids do but I have at best mixed feelings. Yeah it's powerful and I can keep things nicely organized, and urlview is fantastic as is doing most text selection with the mouse and vim keybindings, but otherwise tmux still sits squarely in my definition of "medieval software" which in general I try to avoid.
- sxhkd (simple X11 hot key daemon) for non-window-manager key bindings. I really like having a dedicated program to this and the sxhkd config file format is probably near-ideal.
- xcape and xmodmap for keyboard tweaking

## Key parts of my stack (macos)

- hammerspoon for general automation, hot keys, window manipulation
- choose for rofi-like fuzzy filter GUI menu
- bettertouchtool for mouse keys, fixing scroll wheel direction, and clipboard history
- karabiner-elements for keyboard tweaking
- spacelauncher for keyboard tweaking

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

## Navigation Hotkey Approach

I have found an approach to navigation hotkeys that I really like.

- It's ergonomic both on my ergodox keyboard and on my ThinkPad keyboard (within the constraints of the laptop keyboard being terrible ergonomically as a starting point)
- It has a simple concept that applies to my window manager, tmux, and applications
- It avoids conflicting with preset or common modifier keys

First, choice of modifiers rationale

- Don't really want to involve Shift. Shift is for typing uppercase and doing the normal shift stuff. That's plenty for that one key.
- Control is a default binding in many OSes for ultra-essentially like copy/paste, and tons of applications including most GUI text editors, most web browsers, most linux GUI apps, etc. Best to mostly leave that for the apps.
- Alt is commonly used for switching into a mode for activating menus by letter keys, like alt+f opens the file menu then o selects the "Open" menu item.
  - These days I never use this. I'm not sure why but it's not something that's necessary in most of my apps. Web apps tend not to use traditional GUI toolkit menubars anymore and although VS Code has one, I use the command palette instead which is way better anyway.
  - So for that reason I use alt as my window manager primary modifier
- That leaves Super, which on linux is mostly left available for end user hotkeys, and so I use it for that

OK now that we have chosen modifiers, how do we make it ergonomic-ish? I use the command `setxkbmap dvorak -option "ctrl:nocaps,altwin:swap_lalt_lwin"` to setup my keyboard, and that altwin option means my left alt and left win keys get swapped, but my right alt is still just right alt. That means on my thinkpad keyboard my main modifiers are the keys next to the spacebar.

Now for the non-modifier keys, I want this to easily be able to become muscle memory and I want it ergonomic, so that means mostly home row. So here's how I have it set up:

- I bind the home row keys as a "T-shaped" arrow layout
 - s is Left, d is Up, f is right, and c is down
   - That's qwerty which is printed on my keyboard, but I actually touch-type dvorak layout so it's o is Left, e is Up, u is Right, and j is down
- AFAIK this regular (non-inverted) "T" shape is rare. I remember reading somewhere that some early game used it, but I can no longer find a link for that. [Here's an interesting Nerd Corner article](http://eldacur.com/~brons/NerdCorner/InverseT-History.html) on various arrow key arrangements but interestingly it does **not** mention T-shape (it does have inverted-T though).
- My reasoning is avoid the already-overworked pinky and for me hitting the row below the home row is way easier than stretching up for the row above, so I go down for down arrow.
  - Non-columnar key layout on my thinkpad futzes with this a bit. It's really nice on the columnar ergodox layout.
- This T arrangement is mirrored on the right hand and I bind both of them so I can use either hand
- So on my ergodox I do everything with the left hand primarily since that's where my Super and Alt modifiers are
- But on my thinkpad to navigate my window manager, I use my left thumb on the Super key, which is mapped to the key just left of the spacebar. I do this by moving my whole hand so there's no reaching the thumb under the palm of the hand which I find intolerable. Then I navigate with my right hand home row.
- For navigating apps, it's the same arrangement but the hands are switched. Right hand thumb presses the right Alt key and left hand home row does the arrows.

OK so now the logical navigation works like this:

- Left/Right mean left/right
  - i3 focus left/right
  - firefox or VS Code activate tab to the left/right
  - tmux activate window to the left/right
- Up means "small switch" roughly
  - tmux this switches to previous pane
  - i3 this switches to the previous window
  - firefox currently I have this set to "Home" which scrolls to the top of the page
  - VS Code still TBD
- Down means "big switch" roughly
  - tmux this switches to the next session
  - i3 I don't have this bound. I don't yet make use of workspaces but if I start eventually this might move to the next workspace
  - firefox this does PgDown
    - These are the same bindings I have for the extra mouse buttons I have near my thumb on my vertical mouse, so I have Home and PgDown available both on the mouse itself as well as with home row hotkeys
  - VS Code still TBD

This is facilitated by my `~/bin/app-nav` script which can tell which application has focus and branch to send the appropriate keystrokes via `xdotool`.

So far for me this has been super clutch in not getting super frustrated with tmux. I can't stand prefix keys for stuff I'm doing very frequently, and this gives me most of what I need with a regular hotkey.
