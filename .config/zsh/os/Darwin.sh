#!/usr/bin/env bash
export TERM=xterm-256color
# make PATH system wide
# launchctl setenv PATH $PATH
alias cal="cal -y"
alias chrome='open -a "Google Chrome"'
alias screen-unlock="defaults write com.apple.screensaver askForPassword 0 && defaults write com.apple.screensaver askForPasswordDelay 0"
alias screen-lock="defaults write com.apple.screensaver askForPassword 1 && defaults write com.apple.screensaver askForPasswordDelay 60"
alias top="top -o cpu -s 5"
source-if-exists ~/.config/iterm2/iterm2-shell-integration.zsh

# homebrew
# macos + homebrew + python + virtualenv = :-(
# I hard code this because $(brew --prefix openssl) is super slow
#brew_prefix="/usr/local/opt"
#if [[ -d "${brew_prefix}" ]]; then
#  CFLAGS="-I${brew_prefix}/openssl/include"
#  export CFLAGS
#  LDFLAGS="-L${brew_prefix}/lib -L${brew_prefix}/libyaml/lib"
#  export LDFLAGS
#fi

# https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Analytics.md#opting-out
export HOMEBREW_NO_ANALYTICS=1

macos-save-brew() {
  (cd ~/.config/homebrew && brew bundle dump --force)
}

#homebrew-ssl-vars() {
#  export LDFLAGS="-L$(brew --prefix openssl)/lib"
#  export CFLAGS="-I$(brew --prefix openssl)/include"
#  export SWIG_FEATURES="-cpperraswarn -includeall -I$(brew --prefix openssl)/include"
#}

macos-app-config() {
  local OP="${1}"
  shift
  case "${OP}" in
    export | import) ;;
    *)
      echo "Usage: $0 <export|import> <app>" 1>&2
      return 1
      ;;
  esac
  local NAME
  NAME=$(echo "${1}" | tr '[:upper:]' '[:lower:]')
  local DIR="Library/Preferences"
  local PLIST
  case ${NAME} in
    terminal)
      PLIST="${DIR}/com.apple.Terminal.plist"
      ;;
    *)
      echo "Uknown App name ${1}" 1>&2
      return 10
      ;;
  esac
  local BIN="${HOME}/${PLIST}"
  local JSON="${HOME}/projects/dotfiles/${PLIST}"
  case "${OP}" in
    export)
      cp "${BIN}" "${JSON}"
      plutil -convert json "${JSON}"
      cd ~/projects/dotfiles || exit
      git status
      ;;
    import)
      cp "${JSON}" "${BIN}"
      plutil -convert binary1 "${BIN}"
      ;;
  esac
}

export MANPATH=$MANPATH:/usr/local/share/man

tc() {
  # color values are in '{R, G, B, A}' format
  # all 16-bit unsigned integers (0-65535)
  local max=65535
  local red="{${max}, 0, 0, ${max}}"
  local grey="{50000, 50000, 50000, ${max}}"
  local white="{${max}, ${max}, ${max}, ${max}}"
  local color="${grey}"
  case "$1" in
    red | production | prod)
      local color="${red}"
      ;;
    grey | remote)
      local color="${grey}"
      ;;
    white | local)
      local color="${white}"
      ;;
  esac
  osascript -e "tell application \"Terminal\" to set background color of window 1 to ${color}"
}

_dns() {
  networksetup -setdnsservers Wi-Fi "$@"
}

macos-dns-cloudflare() {
  _dns 1.1.1.1
}

macos-dns-google() {
  _dns 8.8.8.8
}

macos-dns-opendns() {
  _dns 208.67.222.222
}

macos-dns-quad9() {
  _dns 9.9.9.9
}

macos-dns-dhcp() {
  _dns empty
}

# macos preferences 2020 edition
# defaults write com.google.Chrome ExternalProtocolDialogShowAlwaysOpenCheckbox -bool true

########## OS X Preferences ##########
# Sources:
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx
# http://www.applegazette.com/mac/10-useful-defaults-write-commands-osx/
# https://gist.github.com/2260182
# Many things removed or edited by Pete
_macos_prefs() {
  # Immediately return for now. It would be very dangerous to just run
  # this entire function without vetting against recent versions of macos
  return
  # Kill system preferences to not have it trying to override config we're about
  # to change.
  osascript -e "tell application \"System Preferences\" to quit"
  echo "Disable Apple Persistence and get Save As back"
  defaults write com.apple.Preview ApplePersistence -bool no
  defaults write com.apple.TextEdit ApplePersistence -bool no
  defaults write -g NSDocumentSaveNewDocumentsToCloud -bool false
  defaults write com.googlecode.iterm2 SplitPaneDimmingAmount -float 0.5

  echo "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
  defaults write -g AppleKeyboardUIMode -int 3

  echo "Enable subpixel font rendering on non-Apple LCDs"
  defaults write -g AppleFontSmoothing -int 2

  echo "Automatically hide and show the Dock"
  # confirmed as really working by PL 2014-08-17
  defaults write com.apple.dock autohide -bool true

  echo "Disable menu bar transparency"
  defaults write -g AppleEnableMenuBarTransparency -bool false

  echo "Always show scrollbars"
  defaults write -g AppleShowScrollBars -string "Always"

  echo "Disable window animations and Get Info animations in Finder"
  defaults write com.apple.finder DisableAllAnimations -bool true

  echo "Show all filename extensions in Finder"
  defaults write -g AppleShowAllExtensions -bool true

  echo "Use current directory as default search scope in Finder"
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  echo "Show Path bar in Finder"
  defaults write com.apple.finder ShowPathbar -bool true

  echo "Show Status bar in Finder"
  defaults write com.apple.finder ShowStatusBar -bool true

  echo "Display full POSIX path as Finder window title"
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  echo "Expand save panel by default"
  defaults write -g NSNavPanelExpandedStateForSaveMode -bool true

  echo "Expand print panel by default"
  defaults write -g PMPrintingExpandedStateForPrint -bool true

  echo "Automatically quit printer app once the print jobs complete"
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  echo "Disable the 'Are you sure you want to open this application?' dialog"
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  echo "Disable shadow in screenshots"
  defaults write com.apple.screencapture disable-shadow -bool true
  defaults write com.apple.screencapture location /tmp

  echo "Show indicator lights for open applications in the Dock"
  defaults write com.apple.dock show-process-indicators -bool true

  echo "Don’t animate opening applications from the Dock"
  defaults write com.apple.dock launchanim -bool false

  echo "Disable press-and-hold for keys in favor of key repeat"
  # confirmed as really working by PL 2014-08-17
  defaults write -g ApplePressAndHoldEnabled -bool false

  echo "Set a blazingly fast keyboard repeat rate"
  # MacOS 10.12 Sierra and later
  defaults write -g KeyRepeat -int 1
  # OS X 10.11 El Capitan and earlier
  # defaults write -g KeyRepeat -int 0

  echo "Set a shorter Delay until key repeat"
  defaults write -g InitialKeyRepeat -int 10

  echo "Disable auto-correct"
  defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false

  echo "Disable opening and closing window animations"
  defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

  echo "Automatically open a new Finder window when a volume is mounted"
  defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
  defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
  defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

  echo "Increase window resize speed for Cocoa applications"
  defaults write -g NSWindowResizeTime -float 0.001

  echo "Avoid creating .DS_Store files on network volumes"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

  echo "Disable the warning when changing a file extension"
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  echo "Disable the warning before emptying the Trash"
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Empty Trash securely by default
  # defaults write com.apple.finder EmptyTrashSecurely -bool true

  echo "Require password after sleep or screen saver begins"
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 1

  # echo "Enable tap to click (Trackpad)"
  # defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

  echo "Map bottom right Trackpad corner to right-click"
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

  echo "Disable the Ping sidebar in iTunes"
  defaults write com.apple.iTunes disablePingSidebar -bool true

  echo "Disable all the other Ping stuff in iTunes"
  defaults write com.apple.iTunes disablePing -bool true

  echo "Make ⌘ + F focus the search input in iTunes"
  defaults write com.apple.iTunes NSUserKeyEquivalents -dict-add "Target Search Field" "@F"

  echo "Show the ~/Library folder"
  chflags nohidden ~/Library

  echo "Fast expose animation"
  defaults write com.apple.dock expose-animation-duration -float 0.15

  echo "Disable smart quotes and dashes as they’re annoying when typing code"
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  echo "Menu bar: hide the Time Machine, Volume, User, and Bluetooth icons"
  for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
    defaults write "${domain}" dontAutoLoad -array \
      "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
      "/System/Library/CoreServices/Menu Extras/Volume.menu" \
      "/System/Library/CoreServices/Menu Extras/User.menu" \
      "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
      "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
      "/System/Library/CoreServices/Menu Extras/Battery.menu"
  done
  defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/Clock.menu"

  echo "Kill affected applications"
  for app in Safari Finder Dock Mail SystemUIServer; do killall "$app" >/dev/null 2>&1; done
}
