runtime! plugins.vim

set shiftwidth=2
set expandtab
set tabstop=2
set indentkeys-=:
set number
set noignorecase
set hlsearch
set incsearch
set list
set statusline+=%F
set notimeout
set ttimeout

" be smart about case sensitivity with search
set ignorecase
set smartcase

" From: https://github.com/doy/conf/blob/master/vim/plugin/opinionated-defaults.vim
""" BUFFERS """

" automatically write the buffer before :make, shell commands, etc
set autowrite
" ask to save modified buffers when quitting, instead of throwing an error
set confirm
" allow switching to other buffers when the current one is modified
set hidden

autocmd Filetype yaml setlocal shiftwidth=2 tabstop=2
autocmd Filetype yml setlocal shiftwidth=2 tabstop=2
autocmd Filetype sh setlocal shiftwidth=2 tabstop=2
autocmd FocusLost * silent! wa
autocmd Filetype org SoftPencil

" pum is pop-up menu
set completeopt=menuone,noinsert,noselect

runtime! abbreviations.vim
runtime! treesitter.vim
runtime! vim-pencil.vim
runtime! mappings.vim

" colorscheme slate
colorscheme github_*
