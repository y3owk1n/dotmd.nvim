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

--- Get the root directory
---@return string path The path to the root directory
function M.get_root_dir()
	local config = require("dotmd.config").config
	local root_dir = vim.fn.expand(config.root_dir)

	root_dir = vim.fn.fnamemodify(root_dir, ":p")

	return root_dir .. "/"
end

--- Get directories for picker
---@param type DotMd.PickType Options for picking the file
---@return string[] dirs The directories to pick from
function M.get_picker_dirs(type)
	local dirs = {}
	if type == "all" then
		table.insert(dirs, M.get_notes_dir())
		table.insert(dirs, M.get_todo_dir())
		table.insert(dirs, M.get_journal_dir())
	elseif type == "notes" then
		table.insert(dirs, M.get_notes_dir())
	elseif type == "todos" then
		table.insert(dirs, M.get_todo_dir())
	elseif type == "journal" then
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

--- Get current folder name
---@return string folder_name
function M.get_current_folder_name()
	return vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":t")
end

--- Get the path to the previous file from today
---@param dir string
---@param date string|osdate
---@return string|nil path
function M.get_nearest_previous_from_date(dir, date)
	local find_cmd =
		string.format([[find %s -type f -name "*.md"]], vim.fn.shellescape(dir))

	local results = vim.fn.systemlist(find_cmd)
	if vim.v.shell_error ~= 0 or #results == 0 then
		return nil
	end

	local candidates = {}
	for _, file in ipairs(results) do
		local base = vim.fn.fnamemodify(file, ":t")
		local y, m, d = base:match("(%d%d%d%d)%-(%d%d)%-(%d%d)%.md$")
		if y and m and d then
			local file_date = string.format("%s-%s-%s", y, m, d)
			if file_date < date then
				table.insert(candidates, { path = file, date = file_date })
			end
		end
	end

	if #candidates == 0 then
		return nil
	end
	table.sort(candidates, function(a, b)
		return a.date > b.date
	end)
	return candidates[1].path
end

--- Get the path to the next todo file from today
---@param dir string
---@param date string|osdate
---@return string|nil path
function M.get_nearest_next_from_date(dir, date)
	local find_cmd =
		string.format([[find %s -type f -name "*.md"]], vim.fn.shellescape(dir))
	local results = vim.fn.systemlist(find_cmd)
	if vim.v.shell_error ~= 0 or #results == 0 then
		return nil
	end

	local candidates = {}
	for _, file in ipairs(results) do
		local base = vim.fn.fnamemodify(file, ":t")
		local y, m, d = base:match("(%d%d%d%d)%-(%d%d)%-(%d%d)%.md$")
		if y and m and d then
			local file_date = string.format("%s-%s-%s", y, m, d)
			if file_date > date then
				table.insert(candidates, { path = file, date = file_date })
			end
		end
	end

	if #candidates == 0 then
		return nil
	end
	table.sort(candidates, function(a, b)
		return a.date < b.date
	end)
	return candidates[1].path
end

--- Get files recursively from a directory
---@param directory string The directory to get files from
---@return string[] files
function M.get_files_recursive(directory)
	local files = {}
	local scan = vim.fn.readdir(directory)
	for _, entry in ipairs(scan) do
		local full_path = directory .. entry
		if vim.fn.isdirectory(full_path) == 1 then
			vim.list_extend(files, M.get_files_recursive(full_path .. "/"))
		elseif entry:match("%.md$") then
			table.insert(files, full_path)
		end
	end
	return files
end

---@param dirs string[]
---@return string[]
function M.prepare_items_for_select(dirs)
	local config = require("dotmd.config").config

	local items = {}
	for _, dir in ipairs(dirs) do
		vim.list_extend(items, M.get_files_recursive(dir))
	end

	-- Convert to display format
	return vim.tbl_map(function(path)
		local display_path = path:gsub(vim.fn.expand(config.root_dir), "")
		return {
			value = path,
			display = display_path,
		}
	end, items)
end

return M
