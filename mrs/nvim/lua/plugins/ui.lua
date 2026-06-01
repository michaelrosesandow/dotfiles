-- Statusline + keymap discovery.
return {
	-- Status line (replaces airline/powerline)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		opts = {
			options = {
				theme = "tokyonight",
				icons_enabled = true,
				section_separators = "",
				component_separators = "|",
				globalstatus = true,
			},
		},
	},

	-- Pops up available leader mappings as you type — great for relearning
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
}
