local M = {}

function M.merge_default_create_file_opts(opts)
	opts = opts or {}
	opts.open = opts.open ~= false
	opts.split = opts.split
		or require("dotmd.config").config.default_split
		or "vertical"
	return opts
end

function M.sanitize_filename(name)
	return name:gsub('[<>:"/\\|?*]', "-")
end

function M.format_filename(name)
	local formatted = name:lower():gsub(" ", "-"):gsub("%.md$", "")
	return M.sanitize_filename(formatted)
end

function M.deformat_filename(name)
	local deformatted = name:gsub("[-_]", " "):gsub("^%l", string.upper)
	return deformatted
end

function M.ensure_directory(dir)
	vim.fn.mkdir(dir, "p")
end

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

function M.open_file(note_path, opts)
	local cmd = ({
		vertical = "vsplit",
		horizontal = "split",
		none = "edit",
	})[opts.split] or "edit"

	vim.cmd(string.format("%s %s", cmd, vim.fn.fnameescape(note_path)))
end

function M.write_file(note_path, header, template_func)
	local dir_path = vim.fn.fnamemodify(note_path, ":p:h")
	M.ensure_directory(dir_path)

	local content = template_func and template_func(header)
		or { "# " .. header }
	M.safe_writefile(content, note_path)
end

return M
