-- indenting and whitespace
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.indentkeys:remove{':'}

vim.opt.number = true
vim.opt.ignorecase = false
vim.opt.list = true

vim.opt.statusline = '%F'

vim.opt.timeout = false
vim.opt.ttimeout = true

-- search
vim.opt.hlsearch = true
vim.opt.incsearch = true
-- be smart about case sensitivity with search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- buffers
-- automatically write the buffer before :make, shell commands, etc
-- From: https://github.com/doy/conf/blob/master/vim/plugin/opinionated-defaults.vim
vim.opt.autowrite = true
-- ask to save modified buffers when quitting, instead of throwing an error
vim.opt.confirm = true
-- allow switching to other buffers when the current one is modified
vim.opt.hidden = true

vim.opt.completeopt = {'menuone', 'noinsert', 'noselect'}
-- vim.cmd 'colorscheme monokai'
-- vim.cmd 'colorscheme delek'
-- vim.cmd 'colorscheme slate'
vim.cmd 'colorscheme catppuccin-latte'
