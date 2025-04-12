---@module "dotmd"

local M = {}

M.setup = require("dotmd.config").setup

------- Public API -------

--- Create a new note
---@param opts? DotMd.CreateFileOpts
---@return nil
function M.create_note(opts)
	local commands = require("dotmd.commands")
	return commands.create_note(opts)
end

--- Create a new todo for today
---@param opts? DotMd.CreateFileOpts
---@return nil
function M.create_todo_today(opts)
	local commands = require("dotmd.commands")
	return commands.create_todo_today(opts)
end

--- Create a new journal entry
---@param opts? DotMd.CreateFileOpts
---@return nil
function M.create_journal(opts)
	local commands = require("dotmd.commands")
	return commands.create_journal(opts)
end

--- Create or open inbox
---@param opts? DotMd.CreateFileOpts
---@return nil
function M.inbox(opts)
	local commands = require("dotmd.commands")
	return commands.inbox(opts)
end

-- Pick a file from a list of directories
---@param opts? DotMd.PickOpts
---@return nil
function M.pick(opts)
	local commands = require("dotmd.commands")
	return commands.pick(opts)
end

---Navigate to the nearest previous/next date-based file
---@param direction "previous"|"next"
---@return nil
function M.navigate(direction)
	local commands = require("dotmd.commands")
	return commands.navigate(direction)
end

--- Open a file from a list of directories
---@param opts? DotMd.OpenOpts
---@return nil
function M.open(opts)
	local commands = require("dotmd.commands")
	return commands.open(opts)
end

return M
