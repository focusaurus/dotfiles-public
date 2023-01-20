vim.g.mapleader = ' '

-- normal mode keymaps

-- change from normal mode to command mode with comma
-- (The default is colon which requires shift modifier)
-- shift is for suckers!
vim.keymap.set('n', ',', ':', {noremap = true})

-- define named commands for clear reference later in key mappings
vim.cmd('command CopyToClipboard let @+=@0')
vim.cmd('command CopyAll :%y+')

-- copy the entire buffer to the system clipboard
vim.keymap.set('n', '<leader>ca', ':CopyAll<cr>', {noremap = true})

-- copy the selection to the system clipboard
vim.keymap.set('n', '<leader>cc', ':CopyToClipboard<cr>', {noremap = true})

-- easy ref to system clipboard (CLIPBOARD)
vim.keymap.set('n', '<c-c>', '"+', {noremap = true})
vim.keymap.set('n', 'K', '"0p', {noremap = true})

-- rerun the most recently-run macro
vim.keymap.set('n', '<leader>mm', ':@@<cr>', {noremap = true})

-- pretty print (autoformat) the buffer
vim.keymap.set('n', '<leader>pp',
               ':w<cr>:silent !pretty-print-files %<cr>:edit!<cr>',
               {noremap = true})

-- LSP mappings collide with this, delete them
-- vim.keymap.del('n', '<leader>wr')
-- vim.keymap.del('n', '<leader>ws')
-- save current buffer
vim.keymap.set('n', '<leader>w', ':w<cr>', {noremap = true})
vim.keymap.set('n', '<leader><leader>', ':w<cr>', {noremap = true})

-- save all buffers and exit
vim.keymap.set('n', '<leader>x', ':xa<cr>', {noremap = true})

-- close buffer without saving, no confirmation
vim.keymap.set('n', '<leader>q', ':q!<cr>', {noremap = true})

-- quit without saving any buffers, no confirmation
vim.keymap.set('n', '<leader>Q', ':qa!<cr>', {noremap = true})

vim.keymap.set('n', '<leader>V', '<c-v>', {noremap = true})

-- fuzzy navigation with telescope
-- See `:help telescope.builtin`
local builtin = require('telescope.builtin')
local project_files = require('telescope-config').project_files
local function map_telescope(follow_key, func, desc)
  vim.keymap.set('n', '<leader>' .. follow_key, func, {desc = desc})
end
map_telescope('so', builtin.oldfiles, '[Search] recently [O]pened files')
map_telescope('sF', builtin.find_files, '[S]earch All [F]iles')

map_telescope('sb', builtin.buffers, '[S]earch [B]uffers')
map_telescope('b', builtin.buffers, '[S]earch [B]uffers')
map_telescope('sd', builtin.diagnostics, '[S]earch [D]iagnostics')
map_telescope('sf', project_files, '[S]earch Git/Project [F]iles')
map_telescope('sg', builtin.live_grep, '[S]earch by [G]rep')
map_telescope('sh', builtin.help_tags, '[S]earch [H]elp')
map_telescope('sw', builtin.grep_string, '[S]earch current [W]ord')
map_telescope('sk', builtin.keymaps, '[S]earch [K]eymaps')
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false
  })
end, {desc = '[/] Fuzzily search in current buffer]'})

-- (Inactive) fuzzy navigation with junegunn/fzf.vim
-- open a buffer by fuzzy matching buffer paths (fzf plugin)
-- vim.keymap.set('n', '<leader>zb', ':Buffers<cr>', {noremap = true})

-- open a file by searching for contents with ripgrep (fzf plugin)
-- vim.keymap.set('n', '<leader>zg', ':Rg<cr>', {noremap = true})

-- " nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
-- vim.keymap.set('n', '<leader>zp', ':call fzf#vim#complete#path("fd")<cr><cr>',
--                {noremap = true})
-- vim.keymap.set('n', '<leader>zP', '<plug>(fzf-complete-path)',
--                {noremap = true})
-- vim.keymap.set('n', '<leader>zF', ':GFiles<cr>', {noremap = true})
-- vim.keymap.set('n', '<leader>zf',
--                ':call fzf#run({"source": "fd --type file", "sink": "tabedit"})<cr>',
--                {noremap = true})
-- change buffer by fuzzy typing name
-- vim.keymap.set('n', '<leader>b', ':Buffers<cr>', {noremap = true})

-- tab and shift+tab for indent/outdent
vim.keymap.set('n', '<Tab>', '>>', {noremap = true})
vim.keymap.set('n', '<S-Tab>', '<<', {noremap = true})

-- The default mappings for back (b), end (e), and word (w)
-- navigation treat dashes and some other characters as word
-- separators. Normally the uppercase version is the version
-- that only considers whitespace to be a word delimiter.
-- I want the bigger, whitespace-only flavors to be the
-- more ergonomic unshifted versions. The following
-- mappings swap b, e, w and B, E, W
vim.keymap.set('n', 'b', 'B', {noremap = true})
vim.keymap.set('n', 'B', 'b', {noremap = true})
vim.keymap.set('n', 'e', 'E', {noremap = true})
vim.keymap.set('n', 'E', 'e', {noremap = true})
vim.keymap.set('n', 'b', 'B', {noremap = true})
vim.keymap.set('n', 'w', 'W', {noremap = true})
vim.keymap.set('n', 'W', 'w', {noremap = true})

-- move up/down by soft wrapped lines by default
-- vim.keymap.set('n', '<expr> k', '(v:count == 0 ? "gk" : "k")', {noremap = true})
-- vim.keymap.set('n', '<expr> j', '(v:count == 0 ? "gj" : "j")', {noremap = true})
vim.keymap.set('n', 'k', 'gk', {noremap = true})
vim.keymap.set('n', 'j', 'gj', {noremap = true})

-- paste without comments mucking everything up
vim.keymap.set('n', 'cop', ':set invpaste<cr>', {noremap = true})

-- PL: 2022-11-26 This doesn't seem to work and 
-- also messes with gt for tab switching I think
-- bubble single lines
-- http://vimcasts.org/episodes/bubbling-text/
-- vim.keymap.set('n', '<C-Up>', '[e', { noremap = true })
-- vim.keymap.set('n', '<C-Down>', ']e', { noremap = true })
-- " Bubble multiple lines
-- "vmap <C-Up> [egv
-- "vmap <C-Down> ]egv

-- insert mode keymaps

-- Use Tab and Shift+Tab to navigate through popup menu
vim.keymap.set('i', '<expr> <Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]],
               {noremap = true})
vim.keymap.set('i', '<expr> <S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]],
               {noremap = true})

-- In insert mode, complete a filesystem path with fuzzy matching (fzf plugin)
-- vim.keymap.set('i', '<expr> <c-x><c-f>', 'fzf#vim#complete#path("fd")<cr>',
--                {noremap = true})
-- vim.keymap.set('i', '<expr> <c-x><c-f>', '<plug>(fzf-complete-file)',
--                {noremap = true})

-- inoremap <C-s> <Esc>:w<CR>a
-- ctrl+s in insert mode saves like modern programs
vim.keymap.set('i', '<C-s>', '<esc>:w<cr>a', {noremap = true})
vim.keymap.set('i', 'jk', '<esc>', {noremap = true})

-- visual mode keymaps
vim.keymap.set('v', 'y', '"+y', {noremap = true})
-- Paste over selection without overwriting the "0 register
-- (from The Primeagen on youtube)
vim.keymap.set('x', '<leader>p', '"_dP', {noremap = true})

-- command mode keymaps
vim.keymap.set('c', 'qq', 'q!<cr>', {noremap = true})
