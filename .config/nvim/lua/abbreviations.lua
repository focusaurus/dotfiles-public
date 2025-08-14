vim.cmd([[func Eatchar(pat)
  let c = nr2char(getchar(0))
  return (c =~ a:pat) ? '' : c
endfunc
]])
local eat_space = "<C-R>=Eatchar('\\s')<CR>"
local abbrevs = {
	qda = '"$@"',
	qdo = '"$1"',
	qdt = '"$2"',
	qa = "$@",
	qo = "$1",
	qt = "$2",
	qv = '"${}"<Left><Left>' .. eat_space,
	sv = "${}<Left>" .. eat_space,
	iferr = [[if err != nil {
\treturn err
\t}]],
}

for short, long in pairs(abbrevs) do
	vim.cmd.iabbrev({ "<buffer>", short, long .. eat_space })
end

vim.cmd.iabbrev({ "<buffer>", "terab", "{% block foo -%}{% endblock foo -%}" })
vim.cmd.iabbrev({
	"<buffer>",
	"functest",
	"func TestFoo(t *testing.T) {\n\tassert.NoError(t, err)\n}<Up><Left>" .. eat_space,
})
