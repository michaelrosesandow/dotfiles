-- Capture + navigation on-ramp for the Obsidian vault (~/claude-code-time/mrs).
-- The Obsidian app + the Cowork "good morning" automation remain the system of
-- record; this config conforms to their conventions rather than imposing new ones.
return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*", -- pin to released tags, not bleeding HEAD
		ft = "markdown",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			{ "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
			{ "<leader>oy", "<cmd>Obsidian today -1<cr>", desc = "Yesterday's daily note" },
			{ "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
			{ "<leader>os", "<cmd>Obsidian quick_switch<cr>", desc = "Switch / jump to note" },
			{ "<leader>og", "<cmd>Obsidian search<cr>", desc = "Search vault contents" },
			{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks to this note" },
			{ "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Follow [[link]] under cursor" },
			{
				"<leader>oc",
				function()
					require("config.obsidian_capture").capture()
				end,
				desc = "Quick capture to today",
			},
		},
		opts = {
			workspaces = {
				{ name = "mrs", path = "~/claude-code-time/mrs" },
			},

			-- New ad-hoc notes land in the PARA "Notes" folder.
			new_notes_location = "notes_subdir",
			notes_subdir = "04 - Notes",

			-- Daily notes: match the EXISTING files (e.g. "2026-03-31 Tuesday.md").
			-- obsidian.nvim uses Lua strftime, NOT the app's moment tokens.
			daily_notes = {
				folder = "00 - Daily Notes",
				date_format = "%Y-%m-%d %A", -- 2026-03-31 Tuesday
				template = "Daily Note.md",
			},

			templates = {
				folder = "_Templates",
				date_format = "%Y-%m-%d %A",
				time_format = "%H:%M",
			},

			-- Built-in in-process-LSP completion for [[ and #. No nvim-cmp/blink.
			completion = {
				nvim_cmp = false,
				blink = false,
				min_chars = 2,
			},

			picker = {
				name = "telescope.nvim",
			},

			-- Disable obsidian.nvim's own renderer: render-markdown.nvim owns that.
			ui = { enable = false },

			-- Human-readable filenames (e.g. "Foo Bar.md"), NOT Zettelkasten IDs.
			note_id_func = function(title)
				if title ~= nil and title ~= "" then
					return title
				end
				return tostring(os.time())
			end,

			-- Emit plain [[Note Name]] wikilinks, matching the app + automation.
			-- v3.x replaced `preferred_link_style`/`wiki_link_func` with `link`;
			-- "wiki" style already produces [[Note Name]], so no custom formatter.
			link = { style = "wiki" },
		},
		config = function(_, opts)
			require("obsidian").setup(opts)
			-- Conceal links/markup cleanly alongside render-markdown.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.opt_local.conceallevel = 2
				end,
			})
		end,
	},
}
