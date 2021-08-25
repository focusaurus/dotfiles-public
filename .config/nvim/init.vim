set shiftwidth=2
set expandtab
set tabstop=2
set indentkeys-=:
set cursorline
set number
set noignorecase
set hlsearch
set incsearch
set list
"set clipboard=unnamedplus
set statusline+=%F
set notimeout
set ttimeout

runtime! vim-plug-setup.vim
runtime! abbreviations.vim
runtime! firenvim.vim
runtime! mappings.vim
runtime! treesitter.vim
runtime! lsp-go.lua
" runtime! syntastic.vim
runtime! vim-pencil.vim
runtime! lsp-saga.vim
runtime! completion-nvim.vim

autocmd Filetype yaml setlocal shiftwidth=2 tabstop=2
autocmd Filetype yml setlocal shiftwidth=2 tabstop=2
autocmd Filetype sh setlocal shiftwidth=2 tabstop=2
" autocmd Filetype markdown CocDisable
autocmd FocusLost * silent! wa
autocmd Filetype org SoftPencil
" autocmd Filetype c SyntasticToggleMode
" autocmd Filetype h SyntasticToggleMode
"
" pum is pop-up menu
set completeopt=menuone,noinsert,noselect
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

":colorscheme koehler
":colorscheme ron
colorscheme slate
