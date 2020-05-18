func Eatchar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc
iabbrev <silent> qv "${}"<Left><Left><C-R>=Eatchar('\s')<CR>
iabbrev <silent> sv ${}<Left><Left><C-R>=Eatchar('\s')<CR>
iabbrev <silent> qdo "$1"
iabbrev <silent> qdt "$2"
iabbrev <silent> qda "$@"
iabbrev ecom ecommerce
