-- indent with 2 spaces for these file types
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "yaml", "yml", "sh", "lua" },
	command = "setlocal shiftwidth=2 tabstop=2",
})

-- Save all files automatically when switching to another window.
-- I usually like this, but to disable for the session,
-- Run the following command mode custom command:
-- :DisableSaveOnFocusLost
vim.api.nvim_create_autocmd("FocusLost", { pattern = { "*" }, command = "silent! wa" })

vim.cmd("command DisableSaveOnFocusLost :autocmd! FocusLost")

-- vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
--   pattern = {'*.txt', '*.md'},
--   command = 'setlocal spell'
-- })

-- start git commit messages in insert mode
vim.api.nvim_create_augroup("bufcheck", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = "bufcheck",
	pattern = { "gitcommit", "gitrebase" },
	command = "startinsert | 1",
})
