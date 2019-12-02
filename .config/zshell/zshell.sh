#!/usr/bin/env zsh
# big history
export HISTSIZE="10000"
export SAVEHIST="10000"
# Allow multiple terminal sessions to all append to one zsh command history
setopt APPEND_HISTORY
# Add commands to history as they are typed, don't wait until shell exit
setopt INC_APPEND_HISTORY
# Shares history across multiple zsh sessions, in real time
# PL 2018-02-15 I don't like this one
# setopt SHARE_HISTORY
# makes history substitution commands a bit nicer. I don't fully understand
setopt HIST_VERIFY

# When duplicates are entered, get rid of the duplicates first when we hit $HISTSIZE
setopt HIST_EXPIRE_DUPS_FIRST
# Do not write events to history that are duplicates of the immediately previous event
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
# When searching history don't display results already cycled through twice
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
# Remove extra blanks from each command line being added to history
export HIST_REDUCE_BLANKS
# Don't enter commands into history if they start with a space
export HIST_IGNORE_SPACE

alias -g /l='| less'
alias -g /p='$(paste)'

setup-path-zsh() {
  # Lowercase `path` array is tied to `PATH` string.  Quoting the path array
  # elements seems to make it compute the array faster somehow.
  path=(
    # Homebrew, goes first for python virtualenvs
    "/usr/local/bin"
    # Normal system stuff comes early for security
    # So npm packages can't override basic commands like ls
    "/bin"
    "/usr/bin"
    "/sbin"
    "/usr/sbin"
    "/usr/X11/bin"
    "${HOME}/projects/dotfiles/bin"
    "${HOME}/bin"
    "/Applications/Google Chrome Canary.app/Contents/MacOS"
    # "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "${HOME}/projects/go/bin"
    "${HOME}/.cargo/bin"
    "/usr/local/m-cli"
    "${PWD}/node_modules/.bin"
    "${PWD}/script"
    "${PWD}/bin"
    "${PWD}/python/bin"
    "${PWD}/env/bin"
  )

  # Normalize `path` and rm dups and nonexistent dirs.
  # path=( ${(u)^path:A}(N-/) ) # FIXME
  export PATH
}

setup-path-zsh

setopt histignorealldups
setopt interactivecomments

# alias -g devlog='json -g -a -0 -e "delete this.v; delete this.hostname;delete this.level; delete this.pid; delete this.name"'
##### shell prompt setup #####
setopt prompt_subst

#For reference and other fanciness:
#http://stackoverflow.com/q/1128496/266795
prompt-branch() {
  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [[ -n "${branch}" ]]; then
    printf "%s " "${branch}"
  fi
}
prompt-kube-context() {
  local context
  context="$(kubectl config current-context 2>/dev/null | cut -d . -f 1)"
  if [[ -n "${context}" ]]; then
    printf "🔲  %s " "${context}"
  fi
}

prompt-aws-profile() {
  if [[ -n "${AWS_PROFILE}" ]]; then
    printf "🅰️  %s " "${AWS_PROFILE}"
  fi
}

setup-prompt() {
  export PROMPT='╭%~ $(prompt-branch)$(prompt-aws-profile)$(prompt-kube-context)%n@%m
╰○ '
  # https://unicode-search.net/unicode-namesearch.pl?term=down&.submit=Search
  # 𝄱
  # Wrap apround version
  # ╭
  # ╰○
  # from sindre sourhous zsh
  # ❯ '
  # small white square ▫️ '
  # ❯
  # export RPROMPT='%n@%m$(prompt-branch)'
}
setup-prompt

save-zsh-history() {
  # http://stackoverflow.com/a/842366/266795
  fc -W
}

TRAPUSR1() {
  { echo reloading due to rss USR1 signal; } 1>&2
  save-zsh-history
  exec "${SHELL}"
}

rss() {
  # TODO check this still works properly on macos
  ps -U "${USER}" | egrep '( -zsh$|[ /]zsh$)' | awk '{print $1}' | xargs kill -USR1 &
}

histsearch() {
  grep -R "$1" ~/.history | cut -d : -f 2-
}
# control-left-arrow goes back a word, right goes forward
bindkey ";5C" forward-word
bindkey ";5D" backward-word
bindkey "^s" kill-word
alias -g /g='| grep'

##### heatseeker zsh integration #####
# https://github.com/garybernhardt/selecta/blob/master/EXAMPLES.md
# Adapted this for heatseeker-v1
# By default, ^S freezes terminal output and ^Q resumes it. Disable that so
# that those keys can be used for other things.
unsetopt flowcontrol

function debug-widget() {
  field_count=$(echo "${LBUFFER}" | awk '{print NF}')
  echo -n "${field_count}"
  if [[ "${LBUFFER}" =~ "\s$" ]]; then
    echo -n "WS"
  else
    echo -n "Q"
  fi
}
zle -N debug-widget
bindkey "^[z" "debug-widget"

# Run fd/fzf in the current working directory, appending the chosen path, if
# any, to the current command, followed by a space.
# There are 2 modes
# query-mode
#  - command line did not end with a trailing space when hotkey was pressed
#  - Do a filtered fuzzy find and replace the last word with the chosen path
# no-query-mode
#  - command line ended with a trailing space when hotkey was pressed
#  - Do an unfiltered fuzzy find and append the chosen path to the command line
function fuzz-all-into-line() {
  echo "fuzz-all-into-line @: $@ " >>/tmp/fuzz.log
  # Print a newline or we'll clobber the old prompt.
  echo
  local query=""
  if [[ ! "${LBUFFER}" =~ "\s$" ]]; then
    # query-mode: grab last word of command line as the query
    # Command line does not end with a trailing space, use a pre-filter query
    query=$(echo "${LBUFFER}" | awk '{print $NF}')
  fi

  declare -a fd_opts=(--max-depth 12 "$@")
  echo "fuzz-all-into-line fd_opts: ${fd_opts}" >>/tmp/fuzz.log
  # Find the path; abort if the user doesn't select anything.
  local chosen_path
  chosen_path=$(fd "${fd_opts[@]}" | fzf --select-1 --exit-0 --query "${query}") || return
  echo "fuzz-all-into-line chosen_path: ${chosen_path}" >>/tmp/fuzz.log
  local new_buffer
  if [[ "${LBUFFER}" =~ "\s$" ]]; then
    # no-query-mode: append the chosen path
    new_buffer="$(echo "${LBUFFER}${chosen_path}")"
  else
    # pre-filter mode, replace the last token with the chosen path
    new_buffer="$(echo "${LBUFFER}" | awk '{$NF=""; print $0}')${chosen_path}"
  fi
  # Append the selection to the current command buffer.
  eval 'LBUFFER="${new_buffer} "'
  # Redraw the prompt since fzf has drawn several new lines of text.
  zle reset-prompt
}
zle -N fuzz-all-into-line # Create the zle widget
bindkey "^[a" "fuzz-all-into-line"

function fuzz-directory-into-line() {
  fuzz-all-into-line --type directory
}
zle -N fuzz-directory-into-line # Create the zle widget
bindkey "^[d" "fuzz-directory-into-line"

function fuzz-file-into-line() {
  fuzz-all-into-line --type file
}
zle -N fuzz-file-into-line # Create the zle widget
bindkey "^[f" "fuzz-file-into-line"

#This is evil. Doesn't fall back to files
#zstyle ':completion:*' menu select
zstyle ':completion:*' completer _complete _ignored _files
fpath=(${DOTFILES}/shell/zsh-completions/src $fpath)
fpath=(${DOTFILES}/shell/zsh-completions-custom $fpath)
autoload -U compinit && compinit
