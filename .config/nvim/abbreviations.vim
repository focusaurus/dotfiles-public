func Eatchar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc

" iabbrev <silent> qa "$@"<C-R>=Eatchar('\s')<CR>
iabbrev <silent> qda "$@"<C-R>=Eatchar('\s')<CR>
iabbrev <silent> qda "$@"<C-R>=Eatchar('\s')<CR>
iabbrev <silent> qdo "$1"<C-R>=Eatchar('\s')<CR>
iabbrev <silent> qdt "$2"<C-R>=Eatchar('\s')<CR>
" iabbrev <silent> qo "$1"<C-R>=Eatchar('\s')<CR>
" iabbrev <silent> qt "$2"<C-R>=Eatchar('\s')<CR>
iabbrev <silent> qv "${}"<Left><Left><C-R>=Eatchar('\s')<CR>
iabbrev <silent> sv ${}<Left><C-R>=Eatchar('\s')<CR>
iabbrev ecom ecommerce
iabbrev terab {% block foo -%}{% endblock foo -%}
