vim.g.mapleader = ' '
vim.g.mouse = false

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

-- yank selection or lines to system clipboard (theprimeagen)
-- next greatest remap ever : asbjornHaland
vim.keymap.set({'n', 'v'}, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])

-- paste the last thing yanked, even if you deleted something since
vim.keymap.set('n', 'K', '"0p', {noremap = true})

-- delete without the default implicit yank
vim.keymap.set({'n', 'v'}, '<leader>d', [["_d]])

-- rerun the most recently-run macro
vim.keymap.set('n', '<leader>mm', ':@@<cr>', {noremap = true})

-- autoformat (pretty print, beautify) the current buffer
vim.keymap.set('n', '<leader>f',
               ':w<cr>:silent !pretty-print-files %<cr>:edit!<cr>',
               {noremap = true})

-- LSP mappings collide with this, delete them
-- vim.keymap.del('n', '<leader>wr')
-- vim.keymap.del('n', '<leader>ws')
-- save current buffer
-- vim.keymap.set('n', '<leader>w', ':w<cr>', {noremap = true})
-- save the buffer with double tap leader
vim.keymap.set('n', '<leader><leader>', ':w<cr>', {noremap = true})

-- save all buffers and exit
vim.keymap.set('n', '<leader>x', ':xa<cr>', {noremap = true})

-- close buffer without saving, no confirmation
vim.keymap.set('n', '<leader>q', ':q!<cr>', {noremap = true})

-- quit without saving any buffers, no confirmation
vim.keymap.set('n', '<leader>Q', ':qa!<cr>', {noremap = true})

vim.keymap.set('n', '<leader>v', '<c-v>', {noremap = true})

-- keep cursor in middle of screen during normal up/down navigation (theprimeagen)
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Keep cursor in middle of screen when searching (theprimeagen)
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
-- fuzzy navigation with telescope
-- See `:help telescope.builtin`
local builtin = require('telescope.builtin')
local project_files = require('telescope-config').project_files
local function map_telescope(follow_key, func, desc)
  vim.keymap.set('n', '<leader>' .. follow_key, func, {desc = desc})
end
map_telescope('so', builtin.oldfiles, '[Search] recently [O]pened files')
map_telescope('sf', builtin.find_files, '[S]earch All [F]iles')

map_telescope('sb', builtin.buffers, '[S]earch [B]uffers')
map_telescope('b', builtin.buffers, '[S]earch [B]uffers')
map_telescope('sd', builtin.diagnostics, '[S]earch [D]iagnostics')
map_telescope('sp', project_files, '[S]earch Git/Project [F]iles')
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
-- commenting this now because apparently <Tab> and <C-i>
-- are like the same in terminal land, and I want to
-- start using the jumplist and LSP more
-- vim.keymap.set('n', '<Tab>', '>>', {noremap = true})
-- vim.keymap.set('n', '<S-Tab>', '<<', {noremap = true})

-- The default mappings for back (b), end (e), and word (w)
-- navigation treat dashes and some other characters as word
-- separators. Normally the uppercase version is the version
-- that only considers whitespace to be a word delimiter.
-- I want the bigger, whitespace-only flavors to be the
-- more ergonomic unshifted versions. The following
-- mappings swap b, e, w and B, E, W
-- Updated 2023-07-23 I'm going to try the defaults instead
if false then
  vim.keymap.set('n', 'b', 'B', {noremap = true})
  vim.keymap.set('n', 'B', 'b', {noremap = true})
  vim.keymap.set('n', 'e', 'E', {noremap = true})
  vim.keymap.set('n', 'E', 'e', {noremap = true})
  vim.keymap.set('n', 'b', 'B', {noremap = true})
  vim.keymap.set('n', 'w', 'W', {noremap = true})
  vim.keymap.set('n', 'W', 'w', {noremap = true})
end

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

vim.keymap.set('i', '<c-bs>', '<c-w>', {noremap = true})

-- visual mode keymaps
-- Paste over selection without overwriting the "0 register
-- (from theprimeagen on youtube)
vim.keymap.set('x', '<leader>p', '"_dP', {noremap = true})

-- move visual selection up or down while selected
vim.keymap.set('v', 'J', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', 'K', ':m \'<-2<CR>gv=gv')
-- command mode keymaps
vim.keymap.set('c', 'qq', 'q!<cr>', {noremap = true})
