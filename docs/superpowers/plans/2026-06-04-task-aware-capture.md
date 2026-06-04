# Task-aware Quick-Capture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `oc` / `<leader>oc` route captures starting with `todo`/`task` into a `## Inbox` checkbox section, and teach `good morning` to promote those into real `01 - Tasks/` files.

**Architecture:** Add a pure keyword-parser and a generalized section-inserter to the existing `obsidian_capture.lua`; `M.append` picks the target section (`Inbox` for tasks, `Scratch Pad` for notes) — one detection point shared by terminal and nvim. Add `## Inbox` to the Daily Note template. Document a Promote-Inbox step in the vault's `good morning` logic that reuses the existing New Task Logic for inference.

**Tech Stack:** Lua (Neovim config), Markdown templates, the vault's `CLAUDE.md` prose logic.

**Spec:** `~/dotfiles/docs/superpowers/specs/2026-06-04-task-aware-capture-design.md`

**Important repo note:** Only `~/dotfiles` is a git repo — Task 1 commits there. The vault (`~/claude-code-time/mrs`) is NOT a git repo; Tasks 2–3 edit files in place with no commit. Do not attempt `git` in the vault.

**Testing note:** The capture routing is pure Lua and IS unit-testable headlessly (Tasks 1, 4). The template and `good morning` edits are prose/markdown verified by inspection. `good morning` promotion is exercised by the LLM in Cowork, not headlessly.

---

### Task 1: Task-aware routing in the capture module

**Files:**
- Modify: `~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua`

This task: (a) generalizes the `## Scratch Pad`-only `insert_entry` into a section-parameterized `insert_into_section`, (b) adds a pure `parse_task` keyword detector, (c) routes in `M.append`, and (d) exposes the two pure helpers as `M._insert_into_section` / `M._parse_task` for headless tests.

- [ ] **Step 1: Replace `insert_entry` with a section-parameterized helper**

In `~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua`, find the existing `insert_entry` function (it hardcodes `## Scratch Pad`) and replace the WHOLE function with:

```lua
-- Insert `entry` at the END of the named section ("## <label>") -- after the
-- hint/existing items, before trailing blank lines / the next "## " heading / EOF
-- -- so items accumulate at the bottom. Creates the section if absent. Operates
-- on a 1-indexed list; shared by the live-buffer and on-disk capture paths and by
-- both target sections (Inbox, Scratch Pad).
local function insert_into_section(lines, label, entry)
	local heading = "^##%s+" .. label
	local h = nil
	for i, l in ipairs(lines) do
		if l:match(heading) then
			h = i
			break
		end
	end

	if not h then
		table.insert(lines, "")
		table.insert(lines, "## " .. label)
		table.insert(lines, entry)
		return lines
	end

	local e = #lines + 1
	for i = h + 1, #lines do
		if lines[i]:match("^##%s") then
			e = i
			break
		end
	end

	while e - 1 > h and lines[e - 1]:match("^%s*$") do
		e = e - 1
	end

	table.insert(lines, e, entry)
	return lines
end
```

- [ ] **Step 2: Add the pure task-keyword parser (above `M.append`)**

Add this function immediately above `function M.append`:

```lua
-- If `text` starts with a `todo`/`task` keyword (case-insensitive, optional
-- colon) followed by non-empty content, return the trimmed remainder (the task
-- title). Otherwise return nil (it's a plain note). A bare keyword with nothing
-- after it returns nil -- no empty tasks.
local function parse_task(text)
	local body = text:match("^%s*[Tt][Oo][Dd][Oo]%s*:?%s+(.+)")
		or text:match("^%s*[Tt][Aa][Ss][Kk]%s*:?%s+(.+)")
	if body then
		body = body:gsub("^%s+", ""):gsub("%s+$", "")
		if body ~= "" then
			return body
		end
	end
	return nil
end
```

- [ ] **Step 3: Route in `M.append` and expose the pure helpers**

Replace the entire body of `M.append` (everything between `function M.append(text)` and its closing `end`) with the version below, which chooses section + entry format by `parse_task`. Keep `M.capture` unchanged.

```lua
function M.append(text)
	if not text or text == "" then
		return false
	end

	local title = parse_task(text)
	local label, entry
	if title then
		label, entry = "Inbox", "- [ ] " .. title
	else
		label, entry = "Scratch Pad", "- " .. text
	end

	local path = today_path()
	ensure_today(path)

	-- Buffer names are absolute paths; today_path() is already absolute.
	local bufnr = vim.fn.bufnr(path)
	if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
		-- Today's note is open: edit the LIVE buffer so we never clobber
		-- unsaved edits, then persist without stealing focus.
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		lines = insert_into_section(lines, label, entry)
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent write")
		end)
	else
		-- Note not open: safe to read/mutate/write the file on disk.
		local lines = vim.fn.readfile(path)
		lines = insert_into_section(lines, label, entry)
		vim.fn.writefile(lines, path)
	end

	if title then
		vim.notify("Task → Inbox: " .. title, vim.log.levels.INFO)
	else
		vim.notify("Captured to Scratch Pad", vim.log.levels.INFO)
	end
	return true
end
```

Then, immediately above the final `return M` line, expose the pure helpers for testing:

```lua
-- Exposed for headless tests (pure, no side effects).
M._parse_task = parse_task
M._insert_into_section = insert_into_section
```

- [ ] **Step 4: Write & run the headless unit test for `parse_task`**

Run this exact command:

```bash
nvim --headless -c "lua
local m = dofile(vim.fn.expand('~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua'))
local function eq(got, want, msg) assert(got == want, msg..' (got: '..tostring(got)..')') end
eq(m._parse_task('todo talk to John'), 'talk to John', 'todo + space')
eq(m._parse_task('TODO: ping Eric'), 'ping Eric', 'TODO + colon')
eq(m._parse_task('task: review Q3 deck'), 'review Q3 deck', 'task + colon')
eq(m._parse_task('Task finish memo'), 'finish memo', 'Task mixed case')
eq(m._parse_task('todo'), nil, 'bare todo is a note')
eq(m._parse_task('todo   '), nil, 'todo + only spaces is a note')
eq(m._parse_task('todones backlog'), nil, 'no false-match on todones')
eq(m._parse_task('a random thought'), nil, 'plain note')
print('parse_task OK')
" -c "qa" 2>&1
```

Expected: prints `parse_task OK` and exits clean. If any assert fails, fix `parse_task` and re-run.

- [ ] **Step 5: Write & run the headless unit test for `insert_into_section`**

Run this exact command:

```bash
nvim --headless -c "lua
local m = dofile(vim.fn.expand('~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua'))
-- Inbox above Scratch Pad, each with a hint line.
local lines = {'## Inbox', '<!-- inbox hint -->', '', '## Scratch Pad', '> notes hint'}
m._insert_into_section(lines, 'Inbox', '- [ ] new task')
assert(lines[3] == '- [ ] new task', 'task should land at end of Inbox, before blank/next heading (got line3: '..tostring(lines[3])..')')
m._insert_into_section(lines, 'Scratch Pad', '- a note')
assert(lines[#lines] == '- a note', 'note should land at end of Scratch Pad section/EOF (got last: '..tostring(lines[#lines])..')')
-- Missing section is created.
local l2 = {'# Title'}
m._insert_into_section(l2, 'Inbox', '- [ ] x')
assert(l2[#l2] == '- [ ] x' and l2[#l2-1] == '## Inbox', 'missing Inbox section should be created with the entry')
print('insert_into_section OK')
" -c "qa" 2>&1
```

Expected: prints `insert_into_section OK` and exits clean. If asserts fail, fix `insert_into_section` and re-run.

- [ ] **Step 6: Parse-check the whole module loads**

Run:

```bash
nvim --headless -c "lua local m=dofile(vim.fn.expand('~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua')); assert(type(m.append)=='function' and type(m.capture)=='function')" -c "qa" 2>&1 && echo "module OK"
```

Expected: prints `module OK`.

- [ ] **Step 7: Commit**

```bash
cd ~/dotfiles
git add mrs/nvim/lua/config/obsidian_capture.lua
git commit -m "feat(capture): route todo/task captures to ## Inbox"
```

---

### Task 2: Add `## Inbox` to the Daily Note template (vault)

**Files:**
- Modify: `~/claude-code-time/mrs/_Templates/Daily Note.md`

NO git in the vault — just save the file.

- [ ] **Step 1: Insert the Inbox section above Scratch Pad**

In `~/claude-code-time/mrs/_Templates/Daily Note.md`, find this block near the end:

```markdown
## Scratch Pad
> Quick thoughts, links, things to process later
```

Insert a new `## Inbox` section immediately BEFORE it, so the file reads:

```markdown
## Inbox
<!-- Quick-captured tasks (e.g. `oc todo ...`). `good morning` files these into 01 - Tasks/ and clears this section. -->

## Scratch Pad
> Quick thoughts, links, things to process later
```

- [ ] **Step 2: Verify**

Run:

```bash
grep -n -e "^## Inbox" -e "^## Scratch Pad" "$HOME/claude-code-time/mrs/_Templates/Daily Note.md"
```

Expected: `## Inbox` appears on a line BEFORE `## Scratch Pad`.

---

### Task 3: Document the Promote-Inbox step in `good morning` (vault CLAUDE.md)

**Files:**
- Modify: `~/claude-code-time/mrs/CLAUDE.md`

NO git in the vault — just save the file. This task is prose edits to four spots in the "Today Logic" section. Read the file first to place edits precisely.

- [ ] **Step 1: Add `## Inbox` to the refresh-mode preserve-list (Step 2)**

In the "Today Logic" → Step 2 bullet that lists user-owned sections to preserve verbatim, which currently reads:

```
  - **Preserve verbatim** the user-owned sections: `## Scratch Pad`, `## Decisions`, `## EOD Reflection`, and any headings/sections not in the template (the user added them on purpose).
```

Change it to include `## Inbox`:

```
  - **Preserve verbatim** the user-owned sections: `## Inbox`, `## Scratch Pad`, `## Decisions`, `## EOD Reflection`, and any headings/sections not in the template (the user added them on purpose). (`## Inbox` is emptied only by the Promote-Inbox step below, which processes the PRIOR note — today's freshly-captured inbox items are kept until the next run.)
```

- [ ] **Step 2: Add the Promote-Inbox step (new Step 3b, after Step 3a)**

Immediately AFTER the "Step 3a — Auto-close completed tasks" paragraph and BEFORE "Step 4 —", insert this new step:

```
Step 3b — Promote Inbox to task files: from the prior note's `## Inbox` section, take each unchecked `- [ ]` item (these were quick-captured via `oc todo ...` / `<leader>oc`). For each, run the New Task Logic (see its own section below) to parse a clean title, due date (natural language → YYYY-MM-DD), project, owner, and inferred type, and create `01 - Tasks/{Title}.md` with status: open. **Dedupe by title** — if a task file with that title already exists in 01 - Tasks/, skip it (this makes re-runs idempotent). Do NOT carry the raw Inbox text forward into today's note: the newly created task files are surfaced by the Step 6 scan and placed into the correct section (Overdue / Due Today / Due This Week / In Progress Ideas) by their due date. Run this BEFORE Step 6 so the new files are included in that scan. Today's (new) note starts with an empty `## Inbox`.
```

- [ ] **Step 3: Note the Step 4 exclusion**

In "Step 4 — Extract all unchecked items...", which currently reads:

```
Step 4 — Extract all unchecked items (- [ ]) from the prior note sections: Overdue, Due Today, Due This Week, In Progress Ideas, Scratch Pad; ignore Meetings Today, Decisions, and EOD Reflection
```

Change the ignore-list to also exclude Inbox (handled by Step 3b):

```
Step 4 — Extract all unchecked items (- [ ]) from the prior note sections: Overdue, Due Today, Due This Week, In Progress Ideas, Scratch Pad; ignore Meetings Today, Decisions, EOD Reflection, and Inbox (Inbox is handled by Step 3b — do not also extract it here, or items would be both filed and carried forward as free text)
```

- [ ] **Step 4: Add the Step 8 confirmation line**

In "Step 8 — Confirm:", which currently reads:

```
Step 8 — Confirm: report full path created, items carried forward by section, tasks pulled from 01 - Tasks/ by category, task files auto-closed from prior note
```

Append the Inbox promotion to the report:

```
Step 8 — Confirm: report full path created, items carried forward by section, tasks pulled from 01 - Tasks/ by category, task files auto-closed from prior note, and Inbox items promoted to new task files (count + titles)
```

- [ ] **Step 5: Verify**

Run:

```bash
grep -n -e "Step 3b" -e "## Inbox" -e "handled by Step 3b" "$HOME/claude-code-time/mrs/CLAUDE.md"
```

Expected: shows the new Step 3b, the `## Inbox` mention in Step 2's preserve-list, and the Step 4 exclusion note.

---

### Task 4: End-to-end smoke test + handoff

**Files:** none (verification only)

- [ ] **Step 1: Headless end-to-end on a TEMP note (no real vault writes)**

This proves routing end-to-end through the disk path without touching the real daily note. Run:

```bash
nvim --headless -c "lua
local m = dofile(vim.fn.expand('~/dotfiles/mrs/nvim/lua/config/obsidian_capture.lua'))
-- Simulate a note body and apply the same routing M.append uses.
local function route(lines, text)
  local title = m._parse_task(text)
  if title then return m._insert_into_section(lines, 'Inbox', '- [ ] '..title)
  else return m._insert_into_section(lines, 'Scratch Pad', '- '..text) end
end
local lines = {'## Inbox', '<!-- hint -->', '', '## Scratch Pad', '> hint'}
route(lines, 'todo talk to John about compliance')
route(lines, 'cool article to read')
local joined = table.concat(lines, '\n')
assert(joined:find('## Inbox\n<!-- hint -->\n%- %[ %] talk to John about compliance'), 'task under Inbox\n'..joined)
assert(joined:find('## Scratch Pad\n> hint\n%- cool article to read'), 'note under Scratch Pad\n'..joined)
print('e2e routing OK')
" -c "qa" 2>&1
```

Expected: prints `e2e routing OK`.

- [ ] **Step 2: Hand off the interactive + Cowork verification to the user**

Present this checklist (cannot be automated here — interactive nvim TUI + the Cowork LLM run):

1. Reload nvim (`v`). In a vault note, `<leader>oc` → type `todo test task one` → confirm `- [ ] test task one` lands under `## Inbox`.
2. `<leader>oc` → type `just a plain thought` → confirm `- just a plain thought` lands under `## Scratch Pad`.
3. Terminal (after `source ~/.zshrc`): `oc todo follow up with Blaine` → confirm it lands under today's `## Inbox`; `oc random link` → under `## Scratch Pad`.
4. Next `good morning` run in Cowork: confirm yesterday's `## Inbox` items become `01 - Tasks/` files (with inferred due/type/project) and appear in the right daily-note section, and that the inbox isn't double-carried as free text.
