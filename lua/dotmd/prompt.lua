local M = {}

--- Input a note name/path
---@param opts DotMd.CreateFileOpts Options for creating the file
---@return nil
function M.input_note_name(base_path, opts)
	vim.ui.input({
		prompt = "Note name/path: ",
		default = "",
	}, function(name_or_path)
		local utils = require("dotmd.utils")
		local config = require("dotmd.config").config

		if not name_or_path or name_or_path == "" then
			return
		end

		local subdir = vim.fn.fnamemodify(name_or_path, ":h")
		local filename = vim.fn.fnamemodify(name_or_path, ":t")

		if subdir ~= "." then
			base_path = base_path .. subdir .. "/"
			utils.ensure_directory(base_path)
		end

		local formatted_name = utils.format_filename(filename)
		local note_path = utils.get_unique_filepath(base_path, formatted_name)

		local display_name = utils.is_path_like(name_or_path)
				and utils.deformat_filename(filename)
			or name_or_path

		utils.write_file(note_path, display_name, config.templates.notes)

		if opts.open then
			utils.open_file(note_path, opts)
		end
	end)
end

return M
