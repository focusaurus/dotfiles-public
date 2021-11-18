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
Plug 'kristijanhusak/orgmode.nvim'
" Plug 'preservim/nerdcommenter'

" List ends here. Plugins become visible to Vim after this call.

call plug#end()

" This is setup for orgmode.nvim
lua << EOF
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.org = {
  install_info = {
    url = 'https://github.com/milisims/tree-sitter-org',
    revision = 'main',
    files = {'src/parser.c', 'src/scanner.cc'},
  },
  filetype = 'org',
}

require'nvim-treesitter.configs'.setup {
  -- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
  highlight = {
    enable = true,
    disable = {'org'}, -- Remove this to use TS highlighter for some of the highlights (Experimental)
    additional_vim_regex_highlighting = {'org'}, -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  ensure_installed = {'org'}, -- Or run :TSUpdate org
}

require('orgmode').setup({
  org_agenda_files = {'~/Dropbox/org/*', '~/my-orgs/**/*'},
  org_default_notes_file = '~/Dropbox/org/refile.org',
})
EOF
