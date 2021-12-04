lua <<EOF
require'nvim-treesitter.configs'.setup {
  -- Modules and its options go here
  ensure_installed = "maintained",
  highlight = { enable = true },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
}
EOF

