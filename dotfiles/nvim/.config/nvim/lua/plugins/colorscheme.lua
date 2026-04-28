-- lua/plugins/colorscheme.lua
-- Tema Monokai Pro (mantido do seu config original)
return {
  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,    -- carrega imediatamente
    priority = 1000, -- carrega antes dos outros plugins
    config = function()
      require("monokai-pro").setup({
        filter = "pro",
        transparent_background = false,
        terminal_colors = true,
        devicons = true,
        styles = {
          comment    = { italic = true },
          keyword    = { italic = true },
          type       = { italic = true },
          storageclass = { italic = true },
          structure  = { italic = true },
          parameter  = { italic = true },
          annotation = { italic = true },
          tag_attribute = { italic = true },
        },
        background_clear = {
          "toggleterm",
          "telescope",
          "renamer",
          "notify",
        },
      })
      vim.cmd("colorscheme monokai-pro")
    end,
  },
}
