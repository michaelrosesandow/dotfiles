-- ============================================================
--   MRS Neovim — hand-rolled, markdown/notes-first
--   Symlinked from ~/dotfiles/mrs/nvim to ~/.config/nvim
--   See DESIGN.md for the why.
-- ============================================================

-- Leader must be set BEFORE lazy.nvim loads so plugin mappings pick it up.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options") -- editor settings
require("config.lazy") -- bootstrap lazy.nvim + load lua/plugins/*
require("config.keymaps") -- muscle-memory mappings
