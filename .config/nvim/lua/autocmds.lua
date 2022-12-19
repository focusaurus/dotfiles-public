-- indent with 2 spaces for these file types
vim.api.nvim_create_autocmd('FileType', {
  pattern = {'yaml', 'yml', 'sh', 'lua'},
  command = 'setlocal shiftwidth=2 tabstop=2'
})

-- Save all files automatically when switching to another window.
-- I usually like this, but to disable for the session,
-- Run the following command mode custom command:
-- :DisableSaveOnFocusLost
vim.api.nvim_create_autocmd('FocusLost',
                            {pattern = {'*'}, command = 'silent! wa'})
-- Temporary hack since the above does not seem to work
vim.cmd('autocmd FocusLost * silent! wall')

vim.cmd('command DisableSaveOnFocusLost :autocmd! FocusLost')

vim.api.nvim_create_autocmd('FileType',
                            {pattern = {'*'}, command = 'SoftPencil'})

-- navigate up/down by soft wrapped lines instead of hard lines in markdown files
vim.api.nvim_create_autocmd({'FileType'}, {
  pattern = {'markdown'},
  callback = function()
    vim.keymap.set('n', 'k', 'gk', {noremap = true})
    vim.keymap.set('n', 'j', 'gj', {noremap = true})
  end
})

vim.api.nvim_create_autocmd({'BufRead', 'BufNewFile'}, {
  pattern = {'*.txt', '*.md'},
  command = 'setlocal spell'
})

-- start git commit messages in insert mode
vim.api.nvim_create_augroup('bufcheck', {clear = true})
vim.api.nvim_create_autocmd('FileType', {
  group = 'bufcheck',
  pattern = {'gitcommit', 'gitrebase'},
  command = 'startinsert | 1'
})
-- If I ever start using nvim-orgmode plugin again
-- vim.api.nvim_create_autocmd({ 'FileType' }, {pattern = { 'org' }, callback = function()
--     vim.keymap.set('n', 'cc', '<Plug>OrgCheckBoxToggle', { noremap = true })
--     vim.keymap.set('n', 'cn', '<Plug>OrgCheckBoxNewBelow', { noremap = true })
--     vim.keymap.set('n', 'cN', '<Plug>OrgCheckBoxNewAbove', { noremap = true })
--     vim.keymap.set('n', 'ct', '<Plug>OrgTodoToggleNonInteractive', { noremap = true })
-- end})
