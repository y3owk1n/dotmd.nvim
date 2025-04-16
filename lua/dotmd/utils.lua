local M = {}

--- Merge default create file options
---@param opts? DotMd.CreateFileOpts
---@return DotMd.CreateFileOpts
function M.merge_default_create_file_opts(opts)
	opts = opts or {}
	opts.split = opts.split or require("dotmd.config").config.default_split
	return opts
end

--- Sanitize a filename
---@param name string The filename to sanitize
---@return string The sanitized filename
function M.sanitize_filename(name)
	local sanitized = name:gsub('[<>:"/\\|?*]', "-")
	return sanitized
end

--- Trim a string left and right
---@param string string The string to trim
---@return string The trimmed string
function M.trim(string)
	local trimmed = string:gsub("^%s*(.-)%s*$", "%1")
	return trimmed
end

--- Format a filename
---@param name string The filename to format
---@return string The formatted filename
function M.format_filename(name)
	local trimmed = M.trim(name)

	local formatted = trimmed:lower():gsub(" ", "-"):gsub("%.md$", "")
	return M.sanitize_filename(formatted)
end

--- Deformat a filename
---@param name string The filename to deformat
---@return string The deformatted filename
function M.deformat_filename(name)
	local deformatted =
		name:gsub("[-_]", " "):gsub("^%l", string.upper):gsub("%.md$", "")
	return deformatted
end

--- Ensure a directory exists
---@param dir string The directory to ensure
function M.ensure_directory(dir)
	vim.fn.mkdir(dir, "p")
end

--- Write a file safely
---@param file_path string The path to the file
---@param content string[] The content to write
---@return boolean True if the file was written successfully, false otherwise
function M.safe_writefile(content, file_path)
	local ok, err = pcall(vim.fn.writefile, content, file_path)
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
---@param file_path string The path to the file
---@param split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config
function M.open_file(file_path, split)
	if split == "float" then
		require("dotmd.floating-win").open_float(file_path)
		return
	end

	local cmd = ({
		vertical = "vsplit",
		horizontal = "split",
		none = "edit",
	})[split] or "edit"

	vim.cmd(string.format("%s %s", cmd, vim.fn.fnameescape(file_path)))
end

--- Write a file
---@param file_path string The path to the file
---@param header string The header of the file
---@param template_func? fun(header: string): string[] The template function
function M.write_file(file_path, header, template_func)
	local dir_path = vim.fn.fnamemodify(file_path, ":p:h")
	M.ensure_directory(dir_path)

	local content = template_func and template_func(header)
		or { "# " .. header }
	M.safe_writefile(content, file_path)
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
		config.dir_names.journals,
		config.dir_names.todos,
	}

	return M.contains(allowed_dirs, current_folder)
end

--- Parse user command arguments
---@param arg_str string The string to parse
---@return table args The parsed arguments
function M.parse_user_command_args(arg_str)
	local args = {}
	for _, token in ipairs(vim.split(arg_str, "%s+")) do
		local key, value = token:match("^(%w+)%=(%w+)$")
		if key and value then
			args[key] = value
		end
	end
	return args
end

--- Prepare user command arguments
---@param args string? The string to parse
---@return table? args The parsed arguments
function M.prepare_user_command_args(args)
	local file_args = nil

	if args and args ~= "" then
		file_args = M.parse_user_command_args(args)
	end

	return file_args
end

return M
