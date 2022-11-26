-- pencil is a markdown plugin
vim.api.nvim_create_augroup('pencil', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    group = 'pencil',
    pattern = { 'markdown', 'md' },
    command = 'call pencil#init({"wrap":"soft"})',
})
