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

		name_or_path = utils.trim(name_or_path)

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

		utils.open_file(note_path, opts.split)
	end)
end

---@param dirs string[] The directories to pick from
---@param prompt_name_type string The type of the prompt
---@param prompt string The prompt to show
---@return boolean status true if successful, false if not
function M.native_select_files(dirs, prompt_name_type, prompt)
	local directories = require("dotmd.directories")

	local function fuzzy_filter(query, items)
		query = query:lower()
		return vim.tbl_filter(function(item)
			return item.display:lower():find(query, 1, true) ~= nil
		end, items)
	end

	local items = directories.prepare_items_for_select(dirs)
	if #items == 0 then
		vim.notify(
			"No " .. prompt_name_type .. " files found in specified directories",
			vim.log.levels.WARN
		)
		return false
	end

	vim.ui.select(items, {
		prompt = prompt,
		format_item = function(item)
			return item.display
		end,
		kind = "note",
		fuzzy = true,
		filter = fuzzy_filter,
	}, function(selected)
		if selected then
			vim.cmd("edit " .. vim.fn.fnameescape(selected.value))
		end
	end)

	return true
end

return M
