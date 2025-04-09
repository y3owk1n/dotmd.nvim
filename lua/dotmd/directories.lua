local M = {}

---@param subdir_name DotMd.Config.DirNameKeys
---@return string
function M.get_subdir(subdir_name)
	return vim.fn.expand(require("dotmd.config").config.root_dir)
		.. require("dotmd.config").config.dir_names[subdir_name]
		.. "/"
end

function M.get_notes_dir()
	return M.get_subdir("notes")
end

function M.get_todo_dir()
	return M.get_subdir("todo")
end

function M.get_journal_dir()
	return M.get_subdir("journal")
end

---@param opts DotMd.PickOpts
function M.get_picker_dirs(opts)
	local dirs = {}
	if opts.type == "all" then
		table.insert(dirs, M.get_notes_dir())
		table.insert(dirs, M.get_todo_dir())
		table.insert(dirs, M.get_journal_dir())
	elseif opts.type == "notes" then
		table.insert(dirs, M.get_notes_dir())
	elseif opts.type == "todos" then
		table.insert(dirs, M.get_todo_dir())
	elseif opts.type == "journal" then
		table.insert(dirs, M.get_journal_dir())
	end
	return dirs
end

return M
