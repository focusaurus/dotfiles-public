runtime! plugins.vim

:lua require 'init_wip'
" set shiftwidth=2
" set expandtab
" set tabstop=2
" set indentkeys-=:
" set number
" set noignorecase
" set hlsearch
" set incsearch
" set list
" set statusline+=%F
" set notimeout
" set ttimeout
"
" " be smart about case sensitivity with search
" set ignorecase
" set smartcase
"
" " From: https://github.com/doy/conf/blob/master/vim/plugin/opinionated-defaults.vim
" """ BUFFERS """
"
" " automatically write the buffer before :make, shell commands, etc
" set autowrite
" " ask to save modified buffers when quitting, instead of throwing an error
" set confirm
" " allow switching to other buffers when the current one is modified
" set hidden

:lua require 'autocmds'

" pum is pop-up menu
" set completeopt=menuone,noinsert,noselect

" runtime! abbreviations.vim
:lua require 'abbreviations'
:lua require 'treesitter'
runtime! vim-pencil.vim
:lua require 'mappings'
