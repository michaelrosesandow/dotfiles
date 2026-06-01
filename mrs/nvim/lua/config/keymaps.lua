-- Muscle-memory mappings carried over from the old vimrc / keybindings.vim.
local map = vim.keymap.set

-- ; for command mode (no more reaching for shift)
map("n", ";", ":", { desc = "Command mode" })

-- jk / kj escape from insert mode
map("i", "jk", "<Esc>")
map("i", "kj", "<Esc>")

-- 0 jumps to first non-blank char
map("n", "0", "^")

-- Move by visual line when a long line is wrapped
map("n", "j", "gj")
map("n", "k", "gk")

-- NOTE: <C-h/j/k/l> window navigation is provided by vim-tmux-navigator,
-- which also hops seamlessly across tmux panes. Don't remap them here.

-- Window zoom / balance (from old vimrc)
map("n", "<leader>-", "<cmd>wincmd _<cr><cmd>wincmd |<cr>", { desc = "Zoom window" })
map("n", "<leader>=", "<cmd>wincmd =<cr>", { desc = "Balance windows" })

-- Edit / reload config
map("n", "<leader>vr", "<cmd>edit $MYVIMRC<cr>", { desc = "Edit config (init.lua)" })
map("n", "<leader>so", "<cmd>source $MYVIMRC<cr>", { desc = "Source config" })

-- Clear search highlight
map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Quick buffer switch (from old config)
map("n", "<Tab>", ":buffers<CR>:buffer<Space>", { desc = "Switch buffer" })

-- Escape exits terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Auto-rebalance splits when the window is resized (from old vimrc)
vim.api.nvim_create_autocmd("VimResized", { command = "wincmd =" })
