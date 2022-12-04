local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- auto-detect indent settings
  use 'tpope/vim-sleuth'

  -- fuzzyness
  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'

  use 'machakann/vim-sandwich'
  use 'tomtom/tcomment_vim'
  use 'laher/fuzzymenu.vim'
  use 'machakann/vim-highlightedyank'
  -- use 'vim-syntastic/syntastic'
  -- use 'liuchengxu/vim-which-key'

  -- For markdown with soft line wrapping
  use { 'reedes/vim-pencil',
    run = function()
      vim.api.nvim_create_augroup('pencil', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = 'pencil',
        pattern = { 'markdown', 'md' },
        command = 'call pencil#init({"wrap":"soft"})',
      })
    end
  }

  use 'kana/vim-textobj-user'
  use 'Chun-Yang/vim-textobj-chunk'
  use { 'nvim-treesitter/nvim-treesitter',
    run = function()
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
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end 
  }

  -- use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }
  use 'neovim/nvim-lspconfig'
  use 'glepnir/lspsaga.nvim'
  use 'nvim-lua/completion-nvim'
  use 'nicwest/vim-camelsnek'
  use 'jeffkreeftmeijer/vim-numbertoggle'
  use 'projekt0n/github-nvim-theme'
  use {'nvim-orgmode/orgmode', config = function()
    require('orgmode').setup({
      org_default_notes_file = '~/refile.org',
    })
  end }
  use 'tpope/vim-repeat'

  -- telescope depends on plenary
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
