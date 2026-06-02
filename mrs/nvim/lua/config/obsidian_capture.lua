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
