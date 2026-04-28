-- lua/plugins/telescope.lua
return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- FZF nativo: busca muito mais rápida
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      local telescope = require('telescope')
      local builtin   = require('telescope.builtin')

      telescope.setup({
        defaults = {
          layout_strategy = 'horizontal',
          sorting_strategy = 'ascending',
          layout_config = { prompt_position = 'top' },
          file_ignore_patterns = { "node_modules", ".git/", "%.lock" },
        },
      })

      -- Carregar extensão fzf se disponível
      pcall(telescope.load_extension, 'fzf')

      -- Keymaps
      local map = vim.keymap.set
      map('n', '<leader>ff', builtin.find_files,  { desc = 'Telescope: arquivos' })
      map('n', '<leader>fg', builtin.live_grep,   { desc = 'Telescope: grep' })
      map('n', '<leader>fb', builtin.buffers,     { desc = 'Telescope: buffers' })
      map('n', '<leader>fh', builtin.help_tags,   { desc = 'Telescope: ajuda' })
      map('n', '<leader>fr', builtin.oldfiles,    { desc = 'Telescope: recentes' })
      map('n', '<leader>fs', builtin.git_status,  { desc = 'Telescope: git status' })
    end,
  },
}
