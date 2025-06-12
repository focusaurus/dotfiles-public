vim.g.mapleader = " "
vim.g.mouse = false
vim.g.conceallevel = 0

-- Utility: Check if a keymap exists
local function keymap_exists(mode, lhs)
	for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
		if map.lhs == lhs then
			return true
		end
	end
	return false
end

-- Usage: Remove the keymap only if it exists
if keymap_exists("n", "<leader><leader>") then
	vim.keymap.del("n", "<leader><leader>")
end

-- save the buffer with double tap leader
vim.keymap.set("n", "<leader><leader>", ":w<cr>", { noremap = true })

-- save all buffers and exit
vim.keymap.set("n", "<leader>x", ":xa<cr>", { noremap = true })

-- close buffer without saving, no confirmation
vim.keymap.set("n", "<leader>q", ":q!<cr>", { noremap = true })

-- quit without saving any buffers, no confirmation
vim.keymap.set("n", "<leader>Q", ":qa!<cr>", { noremap = true })

vim.keymap.set("n", "<leader>v", "<c-v>", { noremap = true })

-- change from normal mode to command mode with comma
-- (The default is colon which requires shift modifier)
-- shift is for suckers!
vim.keymap.set("n", ",", ":", { noremap = true })

-- define named commands for clear reference later in key mappings
vim.cmd("command CopyToClipboard let @+=@0")
vim.cmd("command CopyAll :%y+")

-- copy the entire buffer to the system clipboard
vim.keymap.set("n", "<leader>ca", ":CopyAll<cr>", { noremap = true })

-- copy the selection to the system clipboard
vim.keymap.set("n", "<leader>cc", ":CopyToClipboard<cr>", { noremap = true })

-- easy ref to system clipboard (CLIPBOARD)
vim.keymap.set("n", "<c-c>", '"+', { noremap = true })

-- yank selection or lines to system clipboard (theprimeagen)
-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- paste the last thing yanked, even if you deleted something since
vim.keymap.set("n", "K", '"0p', { noremap = true })

-- delete without the default implicit yank
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- rerun the most recently-run macro
vim.keymap.set("n", "<leader>mm", ":@@<cr>", { noremap = true })
