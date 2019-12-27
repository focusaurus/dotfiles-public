#!/usr/bin/env bash
export FZF_DEFAULT_COMMAND='rg -g ""'
export FZF_COMPLETION_TRIGGER="''"
export FZF_DEFAULT_OPTS='--bind=alt-enter:print-query'
if [[ -n "${ZSH_VERSION}" ]]; then
  #[[ -f "/usr/share/fzf/competion.zsh" ]] && source "/usr/share/fzf/competion.zsh"
  #[[ -f "/usr/share/fzf/key-bindings.zsh" ]] && source "/usr/share/fzf/key-bindings.zsh"

  # fzf-cd-all-widget() {
  #   setopt localoptions pipefail 2>/dev/null
  #
  #   local dir="$(fd --hidden --no-ignore-vcs --type directory --color=auto '' $HOME 2>/dev/null | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --multi --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" fzf)"
  #
  #   if [[ -z "$dir" ]]; then
  #     zle redisplay
  #     return 0
  #   fi
  #   cd "$dir"
  #   local ret=$?
  #   typeset -f zle-line-init >/dev/null && zle zle-line-init
  #   return $ret
  # }
  ##### fzf zsh integration #####
  # https://github.com/garybernhardt/selecta/blob/master/EXAMPLES.md
  # Adapted this for fzf
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
fi

# fuzzy-filter() {
#   cat | (fzf --select-1 --query "$1" || fzf --query "${1}")
# }

c() {
  local dir
  dir=$(fasd -dl | ~/bin/fuzzy-filter "$@")
  if [[ -n "${dir}" ]]; then
    cd "${dir}" || return
  else
    echo "No match!" 1>&2
  fi
}

# fuzz-directory-command-line() {
#   local dir
#   # dir="$(fd --hidden --no-ignore-vcs --type directory . 2>/dev/null |
#   #   FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --multi --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" fzf)"
#   dir="$(fd --hidden --no-ignore-vcs --type directory . 2>/dev/null | fzf)"
#   cat | fzf --select-1 --exit-0 --query "$1"
# }

kill-fzf() {
  pkill --full 'fzf.*select-1.*query'
}

sigusr1-fuzzy() {
  pid=$(ps -ef | fuzzy-filter "$@" | awk '{print $2}')
  shift
  [[ -z "${pid}" ]] && return 1
  /bin/kill --signal USR1 "${pid}"
}
