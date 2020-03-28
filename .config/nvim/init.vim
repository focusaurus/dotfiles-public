"set nocompatible
"autocmd FileType coffee setlocal shiftwidth=2 tabstop=2
"set guioptions-=L
"set autoread
":au BufNewFile,BufRead *.py so <sfile>:h/html.vim
"map bl :call BufferList()<CR>
"map <tab> >>
"map <s-tab> <<
"vmap <tab> >>
"vmap <s-tab> <<
" Bubble single lines
" http://vimcasts.org/episodes/bubbling-text/
"nmap <C-Up> [e
"nmap <C-Down> ]e
" Bubble multiple lines
"vmap <C-Up> [egv
"vmap <C-Down> ]egv
" Visually select the text that was last edited/pasted
"nmap gV `[v`]
" Use space instead of colon for commands
"noremap <Space> :
"python << EOF
"def testCommand1():
"  import vim
"  print len(vim.current.buffer)
"EOF
"command! -nargs=* TestCommand :python testCommand1(<f-args>)
set shiftwidth=2
set expandtab
set tabstop=2
set indentkeys-=:
set cursorline
set ignorecase
set hlsearch
set incsearch
set clipboard=unnamedplus
runtime! vim-plug-setup.vim
runtime! mappings.vim
":colorscheme koehler
":colorscheme ron
colorscheme slate
autocmd Filetype yaml setlocal shiftwidth=2 tabstop=2
autocmd Filetype yml setlocal shiftwidth=2 tabstop=2
autocmd Filetype sh setlocal shiftwidth=2 tabstop=2
