" automatically install vim-plug if missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/site/vim-plug-plugins')

" auto-detect indent settings
Plug 'tpope/vim-sleuth'

" fuzzyness
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'neoclide/coc-tabnine'
"Plug 'neoclide/coc-tsserver'

Plug 'machakann/vim-sandwich'
Plug 'vim-syntastic/syntastic'
Plug 'tomtom/tcomment_vim'
Plug 'laher/fuzzymenu.vim'
Plug 'liuchengxu/vim-which-key'
Plug 'machakann/vim-highlightedyank'

" For markdown with soft line wrapping
Plug 'reedes/vim-pencil'
Plug 'kana/vim-textobj-user'
Plug 'Chun-Yang/vim-textobj-chunk'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim'
Plug 'nvim-lua/completion-nvim'
Plug 'nicwest/vim-camelsnek'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'projekt0n/github-nvim-theme'
" List ends here. Plugins become visible to Vim after this call.

call plug#end()
