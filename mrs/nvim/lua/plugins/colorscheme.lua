-- Active colorscheme: tokyonight (moon variant).
return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000, -- load before everything else so the UI starts themed
		opts = {
			style = "moon",
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight-moon")
		end,
	},
}
