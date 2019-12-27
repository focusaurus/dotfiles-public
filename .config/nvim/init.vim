"set nocompatible
"autocmd BufWritePost,FileWritePost *.coffee :silent !coffee -c <afile>
"autocmd FileType coffee setlocal shiftwidth=2 tabstop=2
"color solarized
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
"shiftwidth 0
"tabstab 4
:set shiftwidth=2
:set indentkeys-=:
:set cursorline
autocmd Filetype yaml setlocal shiftwidth=2 tabstop=2
autocmd Filetype yml setlocal shiftwidth=2 tabstop=2
autocmd Filetype sh setlocal shiftwidth=2 tabstop=2
