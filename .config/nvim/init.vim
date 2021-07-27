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

runtime! vim-plug-setup.vim
runtime! mappings.vim
runtime! syntastic.vim
runtime! abbreviations.vim
runtime! vim-pencil.vim
runtime! firenvim.vim

":colorscheme koehler
":colorscheme ron
colorscheme slate

autocmd Filetype yaml setlocal shiftwidth=2 tabstop=2
autocmd Filetype yml setlocal shiftwidth=2 tabstop=2
autocmd Filetype sh setlocal shiftwidth=2 tabstop=2
autocmd Filetype markdown CocDisable
autocmd FocusLost * silent! wa
autocmd Filetype org SoftPencil
autocmd Filetype c SyntasticToggleMode
autocmd Filetype h SyntasticToggleMode
