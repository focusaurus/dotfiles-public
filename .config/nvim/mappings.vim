" shift is for suckers!
let mapleader=','
noremap , :
" noremap ; :
" noremap <leader>; ;
noremap F :w<cr>:silent !pretty-print-files %<cr>:edit!<cr>

" Tab and shift+tab for indent/outdent including visual mode
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

" Use space instead of colon for commands
"noremap <Space> :

" The default mappings for back (b), end (e), and word (w)
" navigation treat dashes and some other characters as word
" separators. Normally the uppercase version is the version
" that only considers whitespace to be a word delimiter.
" I want the bigger, whitespace-only flavors to be the
" more ergonomic unshifted versions. The following
" mappings swap b, e, w and B, E, W
nnoremap b B
nnoremap B b
nnoremap e E
nnoremap E e
nnoremap w W
nnoremap W w

" nnoremap <Space> @q
inoremap <C-s> <Esc>:w<CR>a
" nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
autocmd FileType markdown :nnoremap k gk
autocmd FileType markdown :nnoremap j gj
"autocmd FileType org :nmap cc <Plug>OrgCheckBoxToggle
"autocmd FileType org :nmap cn <Plug>OrgCheckBoxNewBelow
"autocmd FileType org :nmap cN <Plug>OrgCheckBoxNewAbove
"autocmd FileType org :nmap ct <Plug>OrgTodoToggleNonInteractive
" easy ref to system clipboard (CLIPBOARD)
nnoremap <c-c> "+
vnoremap y "+y
cmap qq q!
" paste without comments mucking everything up
nnoremap cop :set invpaste<cr>
command CopyToClipboard let @+=@0
command CopyAll :%y+
