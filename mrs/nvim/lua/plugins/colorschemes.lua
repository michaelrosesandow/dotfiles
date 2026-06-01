-- A "browsing pack" of popular colorschemes so you can preview and pick.
-- Each is loaded (lazy = false) only so it shows up in the picker; none is
-- *applied* here — colorscheme.lua still sets the active default.
-- Once you've chosen, we can delete this file and keep just the winner.
--
-- Browse them with  <leader>cs  (live preview — arrow to compare, Enter to apply).
-- Many of these ship several variants (e.g. tokyonight-night/storm/moon/day,
-- catppuccin-mocha/macchiato/frappe/latte), so the picker list is long.
return {
	{ "folke/tokyonight.nvim", lazy = false }, -- cool, crisp, very popular
	{ "catppuccin/nvim", name = "catppuccin", lazy = false }, -- soft pastels
	{ "ellisonleao/gruvbox.nvim", lazy = false }, -- warm retro
	{ "rebelot/kanagawa.nvim", lazy = false }, -- muted, painterly
	{ "rose-pine/neovim", name = "rose-pine", lazy = false }, -- muted rosy
	{ "EdenEast/nightfox.nvim", lazy = false }, -- nightfox/duskfox/carbonfox/...
	{ "sainnhe/everforest", lazy = false }, -- green, low-contrast, easy on eyes
	{ "savq/melange-nvim", name = "melange", lazy = false }, -- warm, low-key
	{ "navarasu/onedark.nvim", lazy = false }, -- the Atom one-dark look
	{ "craftzdog/solarized-osaka.nvim", lazy = false }, -- neon take on solarized
}
