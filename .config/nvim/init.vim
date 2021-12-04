let g:NERDCreateDefaultMappings = 1
runtime! vim-plug-setup.vim

set shiftwidth=2
set expandtab
set tabstop=2
set indentkeys-=:
" set cursorline
set number
set noignorecase
set hlsearch
set incsearch
set list
"set clipboard=unnamedplus
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
" autocmd Filetype markdown CocDisable
autocmd FocusLost * silent! wa
autocmd Filetype org SoftPencil
" autocmd Filetype c SyntasticToggleMode
" autocmd Filetype h SyntasticToggleMode

" pum is pop-up menu
set completeopt=menuone,noinsert,noselect


runtime! abbreviations.vim
runtime! firenvim.vim
runtime! treesitter.vim
runtime! lsp-go.lua
" runtime! syntastic.vim
runtime! vim-pencil.vim
runtime! lsp-saga.vim
runtime! completion-nvim.vim
runtime! mappings.vim

" colorscheme koehler
" colorscheme ron
" colorscheme slate
colorscheme github_*

