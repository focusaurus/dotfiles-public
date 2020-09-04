" shift is for suckers!
let mapleader=','
noremap , :
noremap ; :
noremap <leader>; ;
noremap F :w<cr>:silent !pretty-print-files %<cr>:edit!<cr>
" nnoremap <Space> @q
inoremap <C-s> <Esc>:w<CR>a
" nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
autocmd FileType markdown :nnoremap k gk
autocmd FileType markdown :nnoremap j gj
autocmd FileType org :nmap cc <Plug>OrgCheckBoxToggle
autocmd FileType org :nmap cn <Plug>OrgCheckBoxNewBelow
autocmd FileType org :nmap cN <Plug>OrgCheckBoxNewAbove
autocmd FileType org :nmap ct <Plug>OrgTodoToggleNonInteractive
" easy ref to system clipboard (CLIPBOARD)
nnoremap <c-c> "+
vnoremap y "+y
cmap qq q!
" paste without comments mucking everything up
nnoremap cop :set invpaste<cr>
command CopyToClipboard let @+=@0
