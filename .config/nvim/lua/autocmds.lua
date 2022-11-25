vim.api.nvim_create_autocmd("FileType", {
    pattern = { "yaml", "yml", "sh", },
    command = "setlocal shiftwidth=2 tabstop=2",
})

vim.api.nvim_create_autocmd("FocusLost", {
    pattern = {"*"},
    command = "silent! wa",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "org", },
    command = "SoftPencil",
})
