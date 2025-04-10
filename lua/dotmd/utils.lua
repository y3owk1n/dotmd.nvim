local M = {}

--- Merge default create file options
---@param opts? DotMd.CreateFileOpts
---@return DotMd.CreateFileOpts
function M.merge_default_create_file_opts(opts)
	opts = opts or {}
	opts.open = opts.open ~= false
	opts.split = opts.split
		or require("dotmd.config").config.default_split
		or "vertical"
	return opts
end

--- Sanitize a filename
---@param name string The filename to sanitize
---@return string The sanitized filename
function M.sanitize_filename(name)
	local sanitized = name:gsub('[<>:"/\\|?*]', "-")
	return sanitized
end

--- Format a filename
---@param name string The filename to format
---@return string The formatted filename
function M.format_filename(name)
	local formatted = name:lower():gsub(" ", "-"):gsub("%.md$", "")
	return M.sanitize_filename(formatted)
end

--- Deformat a filename
---@param name string The filename to deformat
---@return string The deformatted filename
function M.deformat_filename(name)
	local deformatted = name:gsub("[-_]", " "):gsub("^%l", string.upper)
	return deformatted
end

--- Ensure a directory exists
---@param dir string The directory to ensure
function M.ensure_directory(dir)
	vim.fn.mkdir(dir, "p")
end

--- Write a file safely
---@param path string The path to the file
---@param content string[] The content to write
---@return boolean True if the file was written successfully, false otherwise
function M.safe_writefile(content, path)
	local ok, err = pcall(vim.fn.writefile, content, path)
	if not ok then
		vim.notify("Error writing file: " .. err, vim.log.levels.ERROR)
		return false
	end
	return true
end

--- Check if a string is a path-like string
---@param str string The string to check
---@return boolean|nil True if the string is a path-like string, false otherwise
function M.is_path_like(str)
	return (
		str:find("[/\\]")
		or str:match("^%a:[/\\]")
		or str:match("^%.?/")
		or str:match("^~")
		or str:match("%.%w+$")
	) ~= nil
end

--- Get an unique filepath
---@param base_path string The base path for the note
---@param formatted_name string The formatted name of the note
---@return string The unique filepath for the file
function M.get_unique_filepath(base_path, formatted_name)
	local note_path = base_path .. formatted_name .. ".md"
	if vim.fn.filereadable(note_path) == 1 then
		local counter = 1
		local new_path = ""
		repeat
			new_path = base_path .. formatted_name .. "-" .. counter .. ".md"
			counter = counter + 1
		until vim.fn.filereadable(new_path) == 0
		note_path = new_path
	end
	return note_path
end

--- Open a file
---@param note_path string The path to the file
---@param opts DotMd.CreateFileOpts Options for creating the file
function M.open_file(note_path, opts)
	local cmd = ({
		vertical = "vsplit",
		horizontal = "split",
		none = "edit",
	})[opts.split] or "edit"

	vim.cmd(string.format("%s %s", cmd, vim.fn.fnameescape(note_path)))
end

--- Write a file
---@param note_path string The path to the file
---@param header string The header of the file
---@param template_func? fun(header: string): string[] The template function
function M.write_file(note_path, header, template_func)
	local dir_path = vim.fn.fnamemodify(note_path, ":p:h")
	M.ensure_directory(dir_path)

	local content = template_func and template_func(header)
		or { "# " .. header }
	M.safe_writefile(content, note_path)
end

--- Function to check if a given array contains a string
---@param arr string[] The array to check
---@param target string The string to check for
---@return boolean is_contained if the array contains the string, false otherwise
function M.contains(arr, target)
	for _, value in ipairs(arr) do
		if value == target then
			return true
		end
	end
	return false
end

--- Check if the current directory is a date-based directory
---@param current_folder string The name of the current directory
---@return boolean is_date_based Whether the current directory is a date-based directory
function M.is_date_based_directory(current_folder)
	local config = require("dotmd.config").config

	local allowed_dirs = {
		config.dir_names.journal,
		config.dir_names.todo,
	}

	return M.contains(allowed_dirs, current_folder)
end

return M
