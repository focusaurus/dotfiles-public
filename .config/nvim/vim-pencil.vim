let g:pencil#wrapModeDefault = 'soft'   " default is 'hard'
augroup pencil
  " Remove all vim-pencil autocommands
  autocmd!
  autocmd FileType markdown,mkd call pencil#init()
augroup END
