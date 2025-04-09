local M = {}

--- Get the directory for a subdir
---@param subdir_name DotMd.Config.DirNameKeys The name of the subdirectory
---@return string path The path to the subdirectory
function M.get_subdir(subdir_name)
	return vim.fn.expand(require("dotmd.config").config.root_dir)
		.. require("dotmd.config").config.dir_names[subdir_name]
		.. "/"
end

--- Get the directory for notes
---@return string path The path to the notes directory
function M.get_notes_dir()
	return M.get_subdir("notes")
end

--- Get the directory for todos
---@return string path The path to the todos directory
function M.get_todo_dir()
	return M.get_subdir("todo")
end

--- Get the directory for journal
---@return string path The path to the journal directory
function M.get_journal_dir()
	return M.get_subdir("journal")
end

--- Get directories for picker
---@param opts DotMd.PickOpts Options for picking the file
---@return string[] dirs The directories to pick from
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
