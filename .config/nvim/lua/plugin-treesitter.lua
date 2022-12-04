require'nvim-treesitter.configs'.setup {
  -- Modules and its options go here
  ensure_installed = {
    'bash',
    'dockerfile',
    'go',
    'html',
    'javascript',
    'json',
    'lua',
    'org',
    'php',
    'python',
    'rust',
    'toml',
    'yaml',
    },
  auto_install = true,
  highlight = { enable = true },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
}

