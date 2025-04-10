local M = {}

--- Get the directory for a subdir
---@param subdir_name DotMd.Config.DirNameKeys The name of the subdirectory
---@return string path The path to the subdirectory
function M.get_subdir(subdir_name)
	local config = require("dotmd.config").config
	local root_dir = vim.fn.expand(config.root_dir)

	root_dir = vim.fn.fnamemodify(root_dir, ":p")

	local subdir = config.dir_names[subdir_name]

	local full_path = root_dir .. subdir .. "/"

	return vim.fn.fnamemodify(full_path, ":p") -- Normalize again
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

--- Get subdirectories from a base path
---@param base_path string The base path to get subdirectories from
---@return string[] subdirs The subdirectories
function M.get_subdirs_recursive(base_path)
	local subdirs = {}

	local function scan_dir(current_path, prefix)
		prefix = prefix or ""
		local scandir = vim.uv.fs_scandir(current_path)
		if scandir then
			while true do
				local name, type = vim.uv.fs_scandir_next(scandir)
				if not name then
					break
				end
				if type == "directory" then
					local relative_dir = prefix .. name
					table.insert(subdirs, relative_dir)
					scan_dir(current_path .. "/" .. name, relative_dir .. "/")
				end
			end
		end
	end

	scan_dir(base_path, "")

	table.insert(subdirs, 1, "[Create new subdirectory]")
	table.insert(subdirs, 2, "[base directory]")

	return subdirs
end

return M
