local M = {}

M.config = {}

---@type DotMd.Config
local defaults = {
	root_dir = "~/dotmd",
	default_split = "none",
	rollover_todo = true,
	dir_names = {
		notes = "notes",
		todo = "todo",
		journal = "journal",
	},
	templates = {
		notes = function(title)
			return {
				"---",
				"title: " .. title,
				"created: " .. os.date("%Y-%m-%d %H:%M"),
				"---",
				"",
				"# " .. title,
				"",
			}
		end,
		todo = function(date)
			return {
				"---",
				"type: todo",
				"date: " .. date,
				"---",
				"",
				"# Todo for " .. date,
				"",
				"## Tasks",
				"",
			}
		end,
		journal = function(date)
			return {
				"---",
				"type: journal",
				"date: " .. date,
				"---",
				"",
				"# Journal Entry for " .. date,
				"",
				"## Highlights",
				"",
				"## Thoughts",
				"",
				"## Tasks",
				"",
			}
		end,
		inbox = function()
			return {
				"---",
				"type: inbox",
				"---",
				"",
				"# Inbox",
				"",
				"## Quick Notes",
				"",
				"## Tasks",
				"",
				"## References",
				"",
			}
		end,
	},
}

--- Setup the plugin
---@param user_config? DotMd.Config
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", defaults, user_config or {})

	M.setup_user_commands()
end

function M.setup_user_commands()
	local commands = require("dotmd.commands")
	local utils = require("dotmd.utils")

	vim.api.nvim_create_user_command("DotMdCreateNote", function(opts)
		local args = opts.args
		opts = utils.prepare_user_command_args(args)
		commands.create_note(opts)
	end, {
		nargs = "?",
		desc = "Create a new note",
	})

	vim.api.nvim_create_user_command("DotMdCreateTodoToday", function(opts)
		local args = opts.args
		opts = utils.prepare_user_command_args(args)
		commands.create_todo_today(opts)
	end, {
		nargs = "?",
		desc = "Create a new todo for today",
	})

	vim.api.nvim_create_user_command("DotMdCreateJournal", function(opts)
		local args = opts.args
		opts = utils.prepare_user_command_args(args)
		commands.create_journal(opts)
	end, {
		nargs = "?",
		desc = "Create a new journal entry",
	})

	vim.api.nvim_create_user_command("DotMdInbox", function(opts)
		local args = opts.args
		opts = utils.prepare_user_command_args(args)
		commands.inbox(opts)
	end, {
		nargs = "?",
		desc = "Create or open the inbox",
	})

	vim.api.nvim_create_user_command("DotMdPick", function(opts)
		local args = opts.args
		opts = utils.prepare_user_command_args(args)
		commands.pick(opts)
	end, {
		nargs = "?",
		desc = "Pick a file from a list of directories",
	})

	vim.api.nvim_create_user_command("DotMdOpen", function(opts)
		local args = opts.args
		opts = utils.prepare_user_command_args(args)
		commands.open(opts)
	end, {
		nargs = "?",
		desc = "Open a file from a list of directories",
	})

	vim.api.nvim_create_user_command("DotMdNavigate", function(opts)
		local direction = opts.args or "next"
		commands.navigate(direction)
	end, {
		nargs = "?",
		complete = function()
			return { "previous", "next" }
		end,
		desc = "Navigate to the nearest previous/next date-based file",
	})
end

return M
