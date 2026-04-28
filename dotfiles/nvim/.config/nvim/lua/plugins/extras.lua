-- lua/plugins/extras.lua
-- Plugins utilitários essenciais para um ambiente de dev completo
return {

  -- ── File explorer ─────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      vim.keymap.set('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = 'Toggle file explorer' })
    end,
  },

  -- ── Statusline ─────────────────────────────────────────────────
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'monokai-pro',
          globalstatus = true,
        },
      })
    end,
  },

  -- ── Keybinding hints ──────────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },

  -- ── Auto-pairs ────────────────────────────────────────────────
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true,
  },

  -- ── Comentários rápidos (gcc / gc) ────────────────────────────
  {
    'numToStr/Comment.nvim',
    lazy = false,
    config = true,
  },

  -- ── Git integration ───────────────────────────────────────────
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add          = { text = '│' },
          change       = { text = '│' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
          untracked    = { text = '┆' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map('n', ']c', gs.next_hunk,   'Git: próxima mudança')
          map('n', '[c', gs.prev_hunk,   'Git: mudança anterior')
          map('n', '<leader>gb', gs.blame_line, 'Git: blame')
          map('n', '<leader>gd', gs.diff_this,  'Git: diff')
        end,
      })
    end,
  },

  -- ── Indent guides ─────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = true,
  },

  -- ── Notificações modernas ─────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  },

}
