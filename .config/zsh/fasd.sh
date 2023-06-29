if ~/bin/have-exe fasd; then
  eval "$(fasd --init zsh-hook)"
  #alias a='fasd -a'        # any
  #alias s='fasd -si'       # show / search / select
  #alias d='fasd -d'        # directory
  #alias f='fasd -f'        # file
  #alias sd='fasd -sid'     # interactive directory selection
  #alias sf='fasd -sif'     # interactive file selection
  alias z='fasd_cd -d'     # cd, same functionality as j in autojump
  alias zz='fasd_cd -d -i' # cd with interactive selection
  # bindkey ^D fasd-complete-d
fi

alias fasd-delete-db="echo -n > \"${HOME}/.cache/fasd\""
