---@module "dotmd"

local M = {}

M.setup = require("dotmd.config").setup

------- Public API -------

---@param opts? DotMd.CreateFileOpts
function M.create_note(opts)
	local commands = require("dotmd.commands")
	return commands.create_note(opts)
end

---@param opts? DotMd.CreateFileOpts
function M.create_todo_today(opts)
	local commands = require("dotmd.commands")
	return commands.create_todo_today(opts)
end

---@param opts? DotMd.CreateFileOpts
function M.create_journal(opts)
	local commands = require("dotmd.commands")
	return commands.create_journal(opts)
end

---@param opts? DotMd.CreateFileOpts
function M.inbox(opts)
	local commands = require("dotmd.commands")
	return commands.inbox(opts)
end

---@param opts? DotMd.PickOpts
function M.pick(opts)
	local commands = require("dotmd.commands")
	return commands.pick(opts)
end

---@param direction "previous"|"next"
function M.todo_navigate(direction)
	local commands = require("dotmd.commands")
	return commands.todo_navigate(direction)
end

return M
