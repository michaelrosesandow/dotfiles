-- Core editing experience: highlighting, fuzzy find, surround, comments, tmux nav.
return {
	-- Treesitter: real syntax highlighting (replaces vim-polyglot).
	-- Uses the `main` branch — the supported one for Neovim 0.11+/0.12.
	-- (The old `master` branch is broken on 0.12.) Neovim already bundles the
	-- markdown parsers, so markdown highlights immediately; code parsers below
	-- install in the background on first launch.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- Extra parsers beyond the ones Neovim bundles. Installs async.
			require("nvim-treesitter").install({
				"python",
				"sql",
				"javascript",
				"typescript",
				"json",
				"yaml",
				"bash",
			})
			-- Start treesitter highlighting for any buffer whose language has a
			-- parser available (bundled or installed). pcall = no error for the rest.
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},

	-- Fuzzy finder (replaces ctrlp / fzy). Uses ripgrep for live grep.
	{
		"nvim-telescope/telescope.nvim",
		-- Track the default branch (not the frozen 0.1.x release): the current
		-- previewer uses Neovim's built-in treesitter API, which is required
		-- now that nvim-treesitter is on its `main` branch.
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		keys = {
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
			{ "<leader>cs", "<cmd>Telescope colorscheme enable_preview=true<cr>", desc = "Browse colorschemes (live preview)" },
		},
		opts = {},
	},

	-- Surround text objects (replaces tpope/vim-surround, same muscle memory)
	{ "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

	-- gcc / gc to toggle comments (replaces tpope/vim-commentary)
	{ "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },

	-- Seamless <C-h/j/k/l> navigation across vim splits and tmux panes (kept)
	{ "christoomey/vim-tmux-navigator", event = "VeryLazy" },
}
