-- ============================================================
-- Neovim Config - init.lua
-- Plugin manager: lazy.nvim (Packer foi arquivado em 2023)
-- ============================================================

-- ── Opções básicas ────────────────────────────────────────────
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt
opt.expandtab     = true
opt.tabstop       = 2
opt.softtabstop   = 2
opt.shiftwidth    = 2
opt.smartindent   = true
opt.number        = true
opt.relativenumber = true
opt.wrap          = false
opt.signcolumn    = "yes"
opt.termguicolors = true
opt.scrolloff     = 8
opt.sidescrolloff = 8
opt.updatetime    = 200
opt.timeoutlen    = 300
opt.undofile      = true
opt.clipboard     = "unnamedplus"     -- integra com clipboard do sistema
opt.splitright    = true
opt.splitbelow    = true
opt.cursorline    = true
opt.ignorecase    = true
opt.smartcase     = true

-- ── Bootstrap lazy.nvim ───────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  print("Instalando lazy.nvim...")
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Carregar plugins ──────────────────────────────────────────
-- Os plugins ficam em ~/.config/nvim/lua/plugins/
require("lazy").setup("plugins", {
  change_detection = { notify = false },
  checker = { enabled = true, notify = false },
})

-- ── Keymaps globais ───────────────────────────────────────────
local map = vim.keymap.set

-- Navegação entre janelas com Ctrl+hjkl
map('n', '<C-h>', '<C-w>h', { desc = 'Ir para janela esquerda' })
map('n', '<C-l>', '<C-w>l', { desc = 'Ir para janela direita' })
map('n', '<C-j>', '<C-w>j', { desc = 'Ir para janela abaixo' })
map('n', '<C-k>', '<C-w>k', { desc = 'Ir para janela acima' })

-- Salvar e sair
map('n', '<leader>w', '<cmd>w<cr>',  { desc = 'Salvar arquivo' })
map('n', '<leader>q', '<cmd>q<cr>',  { desc = 'Fechar janela' })

-- Limpar highlight de busca
map('n', '<Esc>', '<cmd>nohlsearch<cr>')

-- Mover linhas selecionadas (modo visual)
map('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Mover seleção para baixo' })
map('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Mover seleção para cima' })
