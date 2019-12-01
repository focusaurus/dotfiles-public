#!/usr/bin/env bash
########## Project Specific Stuff ##########
##### change directory to active projects #####
alias tncd="cd ~/projects/training-node"
alias hlcd="cd ~/projects/hexagonal-lambda"
alias ggcd="cd ~/projects/goragora"
alias ggsmcd="cd '/Volumes/GoogleDrive/My Drive/GGO Sheet Music/alto-sax'"

##### stackoverflow #####
stackoverflow() {
  local dir
  dir="${HOME}/projects/stackoverflow/$(date +%Y-%m-%d)"
  mkdir -p "${dir}"
  cd "${dir}"
  nvm install stable
}

##### commander #####
export COMMANDER_VENV=commander
export COMMANDER_PATH="${DOTFILES}/commander.py"
if [ -f "${HOME}/projects/commander/commander.sh" ]; then
  source "${HOME}/projects/commander/commander.sh"
fi
alias ci="commander interpret"
commander-repl() {
  cd ~/projects/dotfiles
  rlwrap ~/python-envs/commander/bin/python3 commander.py --repl
}
