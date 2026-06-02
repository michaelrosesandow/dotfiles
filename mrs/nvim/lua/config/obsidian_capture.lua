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

-- Given a flat list of lines, return a new list with `entry` inserted at the END
-- of the "## Scratch Pad" section -- after the hint blockquote and any existing
-- captures, before trailing blank lines / the next "## " heading / EOF -- so
-- captures accumulate at the bottom of the section. If no Scratch Pad heading
-- exists, append a fresh section. Operates on a 1-indexed list; shared by both
-- the live-buffer and on-disk capture paths.
local function insert_entry(lines, entry)
	-- Locate the Scratch Pad heading.
	local h = nil
	for i, l in ipairs(lines) do
		if l:match("^##%s+Scratch Pad") then
			h = i
			break
		end
	end

	if not h then
		table.insert(lines, "")
		table.insert(lines, "## Scratch Pad")
		table.insert(lines, entry)
		return lines
	end

	-- Section end: first heading after `h`, else just past the last line.
	local e = #lines + 1
	for i = h + 1, #lines do
		if lines[i]:match("^##%s") then
			e = i
			break
		end
	end

	-- Trim back over trailing blank lines so the entry lands as the last
	-- content line of the section, not below its trailing whitespace.
	while e - 1 > h and lines[e - 1]:match("^%s*$") do
		e = e - 1
	end

	table.insert(lines, e, entry)
	return lines
end

-- Core capture: append `text` as a bullet under today's Scratch Pad. Shared by
-- the in-editor keymap (M.capture) and the terminal `oc` shell function, which
-- calls this directly via `nvim --headless`. Returns true on success. No-op on
-- empty input.
function M.append(text)
	if not text or text == "" then
		return false
	end
	local path = today_path()
	ensure_today(path)

	local entry = "- " .. text

	-- Buffer names are absolute paths; today_path() is already absolute.
	local bufnr = vim.fn.bufnr(path)
	if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
		-- Today's note is open: edit the LIVE buffer so we never clobber
		-- unsaved edits, then persist without stealing focus.
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		lines = insert_entry(lines, entry)
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
		vim.api.nvim_buf_call(bufnr, function()
			vim.cmd("silent write")
		end)
	else
		-- Note not open: safe to read/mutate/write the file on disk.
		local lines = vim.fn.readfile(path)
		lines = insert_entry(lines, entry)
		vim.fn.writefile(lines, path)
	end

	vim.notify("Captured to " .. os.date("%Y-%m-%d %A"), vim.log.levels.INFO)
	return true
end

-- In-editor entry point: prompt, then append. Bound to <leader>oc.
function M.capture()
	vim.ui.input({ prompt = "Capture: " }, function(input)
		M.append(input)
	end)
end

return M
