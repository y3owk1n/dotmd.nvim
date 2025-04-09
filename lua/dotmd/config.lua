local M = {}

M.config = {}

---@type DotMd.Config
local defaults = {
	root_dir = "~/notes/",
	default_split = "vertical",
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

---@param user_config? DotMd.Config
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", defaults, user_config or {})
end

return M
