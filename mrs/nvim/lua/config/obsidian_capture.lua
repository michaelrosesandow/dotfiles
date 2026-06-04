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
	-- Harden cold start: the daily notes dir may not exist yet.
	vim.fn.mkdir(DAILY_DIR, "p")
	vim.fn.writefile(lines, path)
end

-- Insert `entry` at the END of the named section ("## <label>") -- after the
-- hint/existing items, before trailing blank lines / the next "## " heading / EOF
-- -- so items accumulate at the bottom. Creates the section if absent. Operates
-- on a 1-indexed list; shared by the live-buffer and on-disk capture paths and by
-- both target sections (Inbox, Scratch Pad).
local function insert_into_section(lines, label, entry)
	-- `label` is interpolated into a Lua pattern: escape it (so a label with magic
	-- chars stays literal) and anchor the end (so "## Inbox" can't prefix-match a
	-- heading like "## Inbox Archive").
	local heading = "^##%s+" .. vim.pesc(label) .. "%s*$"
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

-- Core capture: append `text` as a bullet under today's Scratch Pad. Shared by
-- the in-editor keymap (M.capture) and the terminal `oc` shell function, which
-- calls this directly via `nvim --headless`. Returns true on success. No-op on
-- empty input.
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

-- In-editor entry point: prompt, then append. Bound to <leader>oc.
function M.capture()
	vim.ui.input({ prompt = "Capture: " }, function(input)
		M.append(input)
	end)
end

-- Exposed for headless tests (pure, no side effects).
M._parse_task = parse_task
M._insert_into_section = insert_into_section

return M
