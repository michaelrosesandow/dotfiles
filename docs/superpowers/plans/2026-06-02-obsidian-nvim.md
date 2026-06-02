# obsidian.nvim (capture + navigation) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire `obsidian-nvim/obsidian.nvim` into the existing hand-rolled Neovim config as a capture + navigation on-ramp for the Obsidian vault at `~/claude-code-time/mrs`, conforming to the vault's existing conventions.

**Architecture:** A single new lazy.nvim plugin spec file (`lua/plugins/obsidian.lua`) configures the plugin to read/write the same folders and filename formats the Obsidian app and the Cowork `good morning` automation already use. obsidian.nvim's own in-buffer UI is disabled so it doesn't conflict with the existing `render-markdown.nvim`. A small Lua function provides frictionless quick-capture into today's daily note. One existing keymap (`<leader>fn`) is repointed from a dead path to the vault.

**Tech Stack:** Neovim 0.12, lazy.nvim, obsidian.nvim (maintained fork), telescope.nvim (picker backend, already installed), which-key (group labels, already installed), render-markdown.nvim (already installed, must not conflict).

**Spec:** `docs/superpowers/specs/2026-06-02-obsidian-nvim-design.md`

**Note on testing:** This is editor configuration; there is no unit-test harness. Each task's verification is a manual step in a running Neovim instance with the exact keystrokes and expected observation. "Reload nvim" means quit and relaunch (`v` alias / `nvim`) so lazy.nvim re-reads specs and installs/updates plugins.

---

### Task 1: Add the obsidian.nvim plugin spec (core config, conforms to vault conventions)

**Files:**
- Create: `~/dotfiles/mrs/nvim/lua/plugins/obsidian.lua`

- [ ] **Step 1: Create the plugin spec file**

Create `~/dotfiles/mrs/nvim/lua/plugins/obsidian.lua` with exactly this content:

```lua
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
			preferred_link_style = "wiki",
			wiki_link_func = function(opts)
				return string.format("[[%s]]", opts.label or opts.id)
			end,

			-- We add our own keymaps in a separate file; disable plugin defaults
			-- so nothing is bound that we didn't ask for.
			mappings = {},
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
```

- [ ] **Step 2: Reload nvim and let lazy install the plugin**

Run: relaunch `nvim`, then `:Lazy sync` and wait for it to finish, then `:checkhealth obsidian`.
Expected: obsidian.nvim installs without error; `:checkhealth obsidian` reports the `mrs` workspace resolved to `~/claude-code-time/mrs` and the telescope picker found. No error about a missing completion engine.

- [ ] **Step 3: Verify daily-note naming matches existing files**

Run (in nvim): `:Obsidian today`
Expected: opens/creates a note named `<YYYY-MM-DD> <Weekday>.md` (e.g. `2026-06-02 Tuesday.md`) inside `00 - Daily Notes/` — same format as the existing files. If a note for today already exists (from the automation), it opens that one, not a duplicate.

If a new stub was created, confirm `# 2026-06-02 Tuesday` rendered at the top (template `{{date}}` substituted via `templates.date_format`).

- [ ] **Step 4: Commit**

```bash
cd ~/dotfiles
git add mrs/nvim/lua/plugins/obsidian.lua
git commit -m "feat(nvim): add obsidian.nvim, conformed to vault conventions"
```

---

### Task 2: Add navigation keymaps + which-key group

**Files:**
- Modify: `~/dotfiles/mrs/nvim/lua/plugins/obsidian.lua` (add a `keys` table to the spec)

- [ ] **Step 1: Add the `keys` table to the plugin spec**

In `~/dotfiles/mrs/nvim/lua/plugins/obsidian.lua`, inside the plugin table (sibling of `opts`/`config`/`ft`), add:

```lua
		keys = {
			{ "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
			{ "<leader>oy", "<cmd>Obsidian today -1<cr>", desc = "Yesterday's daily note" },
			{ "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
			{ "<leader>os", "<cmd>Obsidian quick_switch<cr>", desc = "Switch / jump to note" },
			{ "<leader>og", "<cmd>Obsidian search<cr>", desc = "Search vault contents" },
			{ "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks to this note" },
			{ "<leader>of", "<cmd>Obsidian follow_link<cr>", desc = "Follow [[link]] under cursor" },
		},
```

Because `keys` is present, lazy.nvim will also load the plugin on first use of any `<leader>o…` mapping (in addition to the `ft = "markdown"` trigger).

- [ ] **Step 2: Register the `<leader>o` group label with which-key**

In `~/dotfiles/mrs/nvim/lua/plugins/ui.lua`, the which-key spec currently has an empty `opts`:

```lua
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {},
	},
```

Change that `opts = {},` line to register the group (which-key v3 `spec` style):

```lua
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>o", group = "obsidian" },
			},
		},
	},
```

- [ ] **Step 3: Reload and verify navigation**

Run: relaunch `nvim`, open any note in the vault (`:Obsidian quick_switch` then pick one — e.g. a `06 - People/` entry).
Then:
- Press `<leader>o` and pause: which-key shows the `obsidian` group with `t/y/n/s/g/b/f` entries.
- `<leader>os` → telescope lists vault notes; selecting one opens it.
- With the cursor on an existing `[[...]]` link, `<leader>of` → opens the target note.
- `<leader>ob` on a note that is linked-to elsewhere → telescope shows backlinks.

Expected: each behaves as described; no errors.

- [ ] **Step 4: Verify built-in `[[` completion**

Run (in an open note, insert mode): type `[[`
Expected: a completion menu of note names appears after `min_chars` characters, with no separate completion plugin installed. Selecting one inserts `[[Note Name]]`.

- [ ] **Step 5: Commit**

```bash
cd ~/dotfiles
git add mrs/nvim/lua/plugins/obsidian.lua mrs/nvim/lua/plugins/ui.lua
git commit -m "feat(nvim): obsidian navigation keymaps + which-key group"
```

---

### Task 3: Add frictionless quick-capture into today's Scratch Pad

**Files:**
- Create: `~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua`
- Modify: `~/dotfiles/mrs/nvim/lua/plugins/obsidian.lua` (add the `<leader>oc` key)

- [ ] **Step 1: Create the capture module**

Create `~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua` with exactly this content. It appends a line under `## Scratch Pad` in today's daily note without stealing the current buffer's focus. It creates today's note from the template only if it is genuinely missing, then refreshes any open buffer pointing at it.

```lua
-- Frictionless quick-capture: prompt for a line, append it under "## Scratch Pad"
-- in today's daily note, without leaving the current buffer.
local M = {}

local VAULT = vim.fn.expand("~/claude-code-time/mrs")
local DAILY_DIR = VAULT .. "/00 - Daily Notes"
local TEMPLATE = VAULT .. "/_Templates/Daily Note.md"

local function today_path()
	return DAILY_DIR .. "/" .. os.date("%Y-%m-%d %A") .. ".md"
end

-- Create today's note from the template if it does not exist yet.
-- (The Cowork "good morning" automation is re-runnable and preserves the
-- Scratch Pad section, so a stub created here is safe.)
local function ensure_today(path)
	if vim.fn.filereadable(path) == 1 then
		return
	end
	local datestr = os.date("%Y-%m-%d %A")
	local lines
	if vim.fn.filereadable(TEMPLATE) == 1 then
		lines = vim.fn.readfile(TEMPLATE)
		for i, l in ipairs(lines) do
			lines[i] = l:gsub("{{date}}", datestr)
		end
	else
		lines = { "# " .. datestr, "", "## Scratch Pad" }
	end
	vim.fn.writefile(lines, path)
end

function M.capture()
	vim.ui.input({ prompt = "Capture: " }, function(input)
		if not input or input == "" then
			return
		end
		local path = today_path()
		ensure_today(path)

		local lines = vim.fn.readfile(path)
		local entry = "- " .. input

		local insert_at = nil
		for i, l in ipairs(lines) do
			if l:match("^##%s+Scratch Pad") then
				insert_at = i
			end
		end

		if insert_at then
			table.insert(lines, insert_at + 1, entry)
		else
			table.insert(lines, "")
			table.insert(lines, "## Scratch Pad")
			table.insert(lines, entry)
		end

		vim.fn.writefile(lines, path)
		-- If today's note is open in a buffer, reload it so it isn't stale.
		vim.cmd("checktime")
		vim.notify("Captured to " .. os.date("%Y-%m-%d %A"), vim.log.levels.INFO)
	end)
end

return M
```

- [ ] **Step 2: Add the `<leader>oc` keymap to the plugin spec**

In `~/dotfiles/mrs/nvim/lua/plugins/obsidian.lua`, add this entry to the `keys` table created in Task 2:

```lua
			{
				"<leader>oc",
				function()
					require("config.obsidian_capture").capture()
				end,
				desc = "Quick capture to today",
			},
```

- [ ] **Step 3: Reload and verify capture from an unrelated buffer**

Run: relaunch `nvim`, open any non-vault file (e.g. `:e ~/dotfiles/mrs/nvim/init.lua`).
Press `<leader>oc`, type `test capture from plan`, press Enter.
Expected:
- A "Captured to <date>" notification appears.
- Focus stays on `init.lua` (capture did not open the daily note).
- Open today's daily note (`:Obsidian today`) and confirm `- test capture from plan` appears under `## Scratch Pad`.
- The daily note filename is `<YYYY-MM-DD> <Weekday>.md` in `00 - Daily Notes/` (no duplicate created).

- [ ] **Step 4: Verify capture when today's note is already open**

Run: open today's note (`:Obsidian today`), keep it focused, `<leader>oc`, type `second capture`, Enter.
Expected: the open buffer reloads (via `checktime`) and shows `- second capture` under `## Scratch Pad` without a "file changed" conflict prompt blocking the edit.

- [ ] **Step 5: Commit**

```bash
cd ~/dotfiles
git add mrs/nvim/lua/config/obsidian_capture.lua mrs/nvim/lua/plugins/obsidian.lua
git commit -m "feat(nvim): quick-capture to today's Scratch Pad"
```

---

### Task 4: Repoint the dead `<leader>fn` ("find notes") to the vault

**Files:**
- Modify: `~/dotfiles/mrs/nvim/lua/plugins/editor.lua`

- [ ] **Step 1: Update the keymap path**

In `~/dotfiles/mrs/nvim/lua/plugins/editor.lua`, find this line in the telescope `keys` table:

```lua
			{ "<leader>fn", "<cmd>Telescope find_files cwd=~/notes<cr>", desc = "Find notes" },
```

Replace it with (the vault path; `~/notes` does not exist):

```lua
			{ "<leader>fn", "<cmd>Telescope find_files cwd=~/claude-code-time/mrs<cr>", desc = "Find notes (vault)" },
```

- [ ] **Step 2: Reload and verify**

Run: relaunch `nvim`, press `<leader>fn`.
Expected: telescope opens rooted at the vault and lists vault files (daily notes, people, meetings, etc.). Previously this opened an empty/erroring picker at the nonexistent `~/notes`.

- [ ] **Step 3: Commit**

```bash
cd ~/dotfiles
git add mrs/nvim/lua/plugins/editor.lua
git commit -m "fix(nvim): point <leader>fn at the vault instead of dead ~/notes"
```

---

### Task 5: Full end-to-end smoke test

**Files:** none (verification only)

- [ ] **Step 1: Run the full acceptance walkthrough**

Relaunch `nvim` and confirm each, in order:

1. `<leader>oc` from a scratch buffer → prompt → entry lands under `## Scratch Pad` of the correctly-named daily note; original buffer stays focused.
2. `<leader>os` → telescope → pick a `06 - People/` note → opens.
3. Cursor on an existing `[[...]]` → `<leader>of` → opens target.
4. Insert mode, type `[[` → completion menu appears (no extra plugin).
5. `<leader>on` → name it `Plan Smoke Test` → filename is `Plan Smoke Test.md` (human-readable, not a timestamp) in `04 - Notes/`.
6. In that note, link to another note via `[[` completion → inserted as `[[Note Name]]` (plain wikilink).
7. Open a markdown note and confirm `render-markdown` still styles headings/checkboxes (no double-render, no obsidian.nvim UI overlay).
8. `<leader>fn` → telescope rooted at the vault.

Expected: all pass. Delete the throwaway `04 - Notes/Plan Smoke Test.md` afterward.

- [ ] **Step 2: Final confirmation**

Confirm `git log --oneline` in `~/dotfiles` shows the Task 1–4 commits and the working tree is clean (aside from the deleted smoke-test note, which lives in the vault repo, not dotfiles).
