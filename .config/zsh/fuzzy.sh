# more widely-used program as the default
fuzzer='fzf'
if ~/bin/have-exe sk; then
  fuzzer='sk'
fi
#export FZF_DEFAULT_COMMAND='rg -g ""'
if ~/bin/have-exe ag; then
  export FZF_DEFAULT_COMMAND="ag --hidden -g ''"
fi
if ~/bin/have-exe fd; then
  #  export FZF_DEFAULT_COMMAND="fd --exclude vendor ."
  #  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --ignore-file .gitignore --ignore-file .ignore'
fi
# export FZF_COMPLETION_TRIGGER="**"
export FZF_COMPLETION_DIR_COMMANDS="cd pushd rmdir tree"
export FZF_DEFAULT_OPTS='--bind=alt-enter:print-query'
if [[ -n "${ZSH_VERSION}" ]]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    source-if-exists ${BREW_PREFIX}/Cellar/fzf/*/shell/key-bindings.zsh
    # source-if-exists "${BREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
  fi
  # source-if-exists /usr/share/fzf/key-bindings.zsh
  source-if-exists /usr/share/fzf/completion.zsh

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
    ~/bin/log "$0" "fuzz-all-into-line @: $*"
    # Print a newline or we'll clobber the old prompt.
    echo
    local query=""
    if [[ ! "${LBUFFER}" =~ "\s$" ]]; then
      ~/bin/log "$0" "No trailing space: query mode"
      # query-mode: grab last word of command line as the query
      # Command line does not end with a trailing space, use a pre-filter query
      query=$(echo "${LBUFFER}" | awk '{print $NF}')
    fi

    declare -a fd_opts=(--max-depth 12 "$@")

    for file in .gitignore .ignore; do
      if [[ -f "${file}" ]]; then
        fd_opts+=(--ignore-file "${file}")
      fi
    done
    # shellcheck disable=SC2145
    ~/bin/log "$0" "fuzz-all-into-line fd_opts: ${fd_opts[@]}"
    # Find the path; abort if the user doesn't select anything.
    ~/bin/log "$0" "running ${fuzzer} pipeline"
    local chosen_path
    chosen_path=$(fd "${fd_opts[@]}" | "${fuzzer}" --select-1 --exit-0 --query "${query}") || return
    ~/bin/log "$0" "fuzz-all-into-line chosen_path: ${chosen_path}"
    local new_buffer
    if [[ "${LBUFFER}" =~ "\s$" ]]; then
      # no-query-mode: append the chosen path
      new_buffer="${LBUFFER} ${chosen_path}"
    else
      # pre-filter mode, replace the last token with the chosen path
      # shellcheck disable=SC2034
      new_buffer="$(echo "${LBUFFER}" | awk '{$NF=""; print $0}')${chosen_path}"
    fi
    # Append the selection to the current command buffer.
    eval 'LBUFFER="${new_buffer} "'
    # Redraw the prompt since skim has drawn several new lines of text.
    zle reset-prompt
  }
  zle -N fuzz-all-into-line # Create the zle widget
  # TODO find a good keybinding for this
  # bindkey "^fa" "fuzz-all-into-line"

  function fuzz-directory-into-line() {
    fuzz-all-into-line --type directory
  }
  zle -N fuzz-directory-into-line # Create the zle widget
  # TODO find a good keybinding for this
  # bindkey "^fd" "fuzz-directory-into-line"

  function fuzz-file-into-line() {
    fuzz-all-into-line --type file
  }
  zle -N fuzz-file-into-line # Create the zle widget
  # TODO find a good keybinding for this
  bindkey "^f" "fuzz-file-into-line"

fi

c() {
  local dir
  dir=$(fasd -dl | "${fuzzer}" --select-1 --no-sort --tac --query "$@")
  if [[ -n "${dir}" ]]; then
    cd "${dir}" || return
  else
    echo "No match!" 1>&2
  fi
}

# kill-fzf() {
#   pkill --full 'fzf.*select-1.*query'
# }

# sigusr1-fuzzy() {
#   pid=$(ps -ef | fuzzy-filter "$@" | awk '{print $2}')
#   shift
#   [[ -z "${pid}" ]] && return 1
#   /bin/kill --signal USR1 "${pid}"
# }

xargs-fuzzy() {
  query="$1"
  shift
  file_command=(fd --type file)
  if git rev-parse HEAD &>/dev/null; then
    # we are inside a git repository
    file_command=(git ls-files)
  fi
  "${file_command[@]}" |
    fzf --no-sort --filter="${query}" |
    xargs "$@"
}

edf-fuzzy() {
  file=$(
    cd || exit 1
    dotfiles-begin
    git ls-files | fuzzy-filter "$@"
    dotfiles-end
  )
  if [[ ! -f "${file}" ]]; then
    return
  fi
  nvim "${HOME}/${file}"
}

# alias -g ff='$(fd --type f | "${fuzzer}" || return )'
