-- lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = "master",
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          -- Vim/Lua
          "lua", "vim", "vimdoc", "query",
          -- Web
          "html", "css", "scss", "javascript", "typescript", "tsx",
          "json", "yaml", "toml",
          -- Backend / sistemas
          "python", "ruby", "php", "go", "rust",
          "java", "kotlin", "c", "cpp", "c_sharp",
          -- Infra
          "bash", "dockerfile",
          -- Texto
          "markdown", "markdown_inline",
          -- Dados
          "sql", "graphql", "regex",
          -- Git
          "gitcommit", "gitignore",
        },
        auto_install = true,
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },
}
