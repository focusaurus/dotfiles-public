" shift is for sucks!
let mapleader=','
noremap , :
noremap ; :
noremap <leader>; ;
noremap F :w<cr>:silent !pretty-print-files %<cr>:edit!<cr>
nnoremap <Space> @q
autocmd FileType markdown :nnoremap k gk
autocmd FileType markdown :nnoremap j gj
