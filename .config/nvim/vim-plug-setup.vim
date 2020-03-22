" automatically install vim-plug if missing
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/share/nvim/site/vim-plug-plugins')

" auto-detect indent settings
Plug 'tpope/vim-sleuth'
" fuzzyness
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" i3 config
Plug 'PotatoesMaster/i3-vim-syntax'
Plug 'eraserhd/parinfer-rust', { 'for': 'clojure', 'do': 'cargo build --release' }
" List ends here. Plugins become visible to Vim after this call.
call plug#end()

