-- Completion engine. Primary reason: obsidian.nvim's [[ and # completion is
-- delivered through blink (its in-process LSP does not do completion). blink is
-- the modern, fast, low-config choice; defaults are deliberately unobtrusive.
return {
	{
		"saghen/blink.cmp",
		version = "*", -- release tag → prebuilt binary, no Rust build needed
		event = "InsertEnter",
		opts = {
			-- <C-space> open/toggle, <C-y> accept, <C-n>/<C-p> navigate.
			-- Intentionally does NOT bind <CR>/<Tab> so it won't fight
			-- obsidian's <CR> smart-action in markdown notes.
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
	},
}
