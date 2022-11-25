require'nvim-treesitter.configs'.setup {
  -- Modules and its options go here
  ensure_installed = {"bash", "javascript", "lua", "go", "rust"},
  auto_install = true,
  highlight = { enable = true },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
}

