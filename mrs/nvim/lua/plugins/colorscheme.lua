-- Solarized, dark — the look you've always run (old config used NeoSolarized).
-- maxmx03/solarized.nvim is the actively maintained, treesitter-aware modern port.
return {
	{
		"maxmx03/solarized.nvim",
		lazy = false,
		priority = 1000, -- load before everything else so UI starts themed
		opts = {},
		config = function(_, opts)
			require("solarized").setup(opts)
			vim.cmd.colorscheme("solarized")
		end,
	},
}
