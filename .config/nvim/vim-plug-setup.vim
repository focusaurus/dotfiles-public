" automatically install vim-plug if missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/site/vim-plug-plugins')
"needed for orgmode
Plug 'neovim/pynvim'
" auto-detect indent settings
Plug 'tpope/vim-sleuth'
" fuzzyness
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" i3 config
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'eraserhd/parinfer-rust', { 'for': 'clojure', 'do': 'cargo build --release' }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-tabnine'
"Plug 'neoclide/coc-tsserver'
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
Plug 'venantius/vim-cljfmt'
"Plug 'tpope/vim-surround'
"Plug 'tpope/vim-repeat'
Plug 'machakann/vim-sandwich'
Plug 'vim-syntastic/syntastic'
Plug 'jceb/vim-orgmode'
Plug 'tomtom/tcomment_vim'
" settings toggles and symmetrical before/after mappings
Plug 'tpope/vim-unimpaired'
Plug 'laher/fuzzymenu.vim'
Plug 'liuchengxu/vim-which-key'
" look at registers
Plug 'junegunn/vim-peekaboo'
Plug 'machakann/vim-highlightedyank'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()
