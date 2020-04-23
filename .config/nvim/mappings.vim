" shift is for sucks!
let mapleader=','
noremap , :
noremap ; :
noremap <leader>; ;
noremap F :w<cr>:silent !pretty-print-files %<cr>:edit!<cr>
nnoremap <Space> @q
autocmd FileType markdown :nnoremap k gk
autocmd FileType markdown :nnoremap j gj
autocmd FileType org :nmap cc <Plug>OrgCheckBoxToggle
" easy ref to system clipboard (CLIPBOARD)
nnoremap <c-c> "+
vnoremap y "+y

" paste without comments mucking everything up
nnoremap cop :set invpaste<cr>
