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

-- Given a flat list of lines, return a new list with `entry` inserted after the
-- first "## Scratch Pad" heading, or with a fresh Scratch Pad section appended
-- if no such heading exists.
local function insert_entry(lines, entry)
	local insert_at = nil
	for i, l in ipairs(lines) do
		if l:match("^##%s+Scratch Pad") then
			insert_at = i
			break
		end
	end

	if insert_at then
		table.insert(lines, insert_at + 1, entry)
	else
		table.insert(lines, "")
		table.insert(lines, "## Scratch Pad")
		table.insert(lines, entry)
	end
	return lines
end

function M.capture()
	vim.ui.input({ prompt = "Capture: " }, function(input)
		if not input or input == "" then
			return
		end
		local path = today_path()
		ensure_today(path)

		local entry = "- " .. input

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
	end)
end

return M
