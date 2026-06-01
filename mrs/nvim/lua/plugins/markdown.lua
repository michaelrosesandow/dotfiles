-- The reason we're here: great markdown.
return {
	-- In-buffer rendering: headings, code blocks, tables, bullets, checkboxes
	-- styled right inside the editor as you write.
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		ft = { "markdown" },
		opts = {},
	},

	-- Browser live-preview: scroll-synced HTML render for reviewing finished docs.
	-- Built locally with node/yarn (reliable since node is installed).
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && npx --yes yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview (browser)" },
		},
	},
}
