-- Editor options. Ports the good parts of the old 02.init.vim.

local opt = vim.opt

-- Line numbers / position
opt.number = true
opt.ruler = true
opt.cursorline = true
opt.scrolloff = 10
opt.signcolumn = "yes"

-- Editing
opt.backspace = { "indent", "eol", "start" }
opt.autoindent = true
opt.smarttab = true

-- Indentation: 4-space soft tabs (matches old config)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

-- System clipboard
opt.clipboard = "unnamedplus"

-- Colors / true color
opt.termguicolors = true
opt.background = "dark"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Splits open where you'd expect
opt.splitright = true
opt.splitbelow = true

-- Persistent undo
opt.undofile = true

-- Use ripgrep for :grep (old config did this too)
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Prose-friendly behavior for markdown / text: soft wrap + spell check
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true -- wrap at word boundaries, not mid-word
		vim.opt_local.spell = true
	end,
})
