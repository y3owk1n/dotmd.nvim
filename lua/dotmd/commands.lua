local M = {}

---@param opts? DotMd.CreateFileOpts
function M.create_note(opts)
	local utils = require("dotmd.utils")
	local directories = require("dotmd.directories")
	local config = require("dotmd.config").config

	opts = utils.merge_default_create_file_opts(opts)

	vim.ui.input({
		prompt = "Note name/path: ",
		default = "",
	}, function(name_or_path)
		if not name_or_path or name_or_path == "" then
			return
		end

		local base_path = directories.get_notes_dir()
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

---@param opts? DotMd.CreateFileOpts
function M.create_todo_today(opts)
	local utils = require("dotmd.utils")
	local todos = require("dotmd.todos")
	local directories = require("dotmd.directories")
	local config = require("dotmd.config").config

	opts = utils.merge_default_create_file_opts(opts)

	local todo_dir = directories.get_todo_dir()
	utils.ensure_directory(todo_dir)

	local today = os.date("%Y-%m-%d")
	local todo_path = todo_dir .. today .. ".md"

	if vim.fn.filereadable(todo_path) == 0 then
		utils.write_file(todo_path, "Todo for " .. today, config.templates.todo)

		local unchecked_tasks, source_path =
			todos.rollover_previous_todo_to_today(todo_dir, today)
		if unchecked_tasks and source_path then
			local today_lines = vim.fn.readfile(todo_path)
			if #today_lines > 0 and today_lines[#today_lines] ~= "" then
				table.insert(today_lines, "")
			end
			vim.list_extend(today_lines, unchecked_tasks)
			utils.safe_writefile(today_lines, todo_path)
			vim.notify(
				string.format(
					"Rolled over %d unchecked todo(s) from %s",
					#unchecked_tasks,
					vim.fn.fnamemodify(source_path, ":t")
				)
			)
		end
	end

	if opts.open then
		utils.open_file(todo_path, opts)
	end
end

---@param opts? DotMd.CreateFileOpts
function M.create_journal(opts)
	local utils = require("dotmd.utils")
	local directories = require("dotmd.directories")
	local config = require("dotmd.config").config

	opts = utils.merge_default_create_file_opts(opts)

	local journal_dir = directories.get_journal_dir()
	utils.ensure_directory(journal_dir)

	local today = os.date("%Y-%m-%d")
	local journal_path = journal_dir .. today .. ".md"

	if vim.fn.filereadable(journal_path) == 0 then
		utils.write_file(
			journal_path,
			"Journal Entry for " .. today,
			config.templates.journal
		)
	end

	if opts.open then
		utils.open_file(journal_path, opts)
	end
end

---@param opts? DotMd.CreateFileOpts
function M.inbox(opts)
	local utils = require("dotmd.utils")
	local config = require("dotmd.config").config

	opts = utils.merge_default_create_file_opts(opts)

	local inbox_path = vim.fn.expand(config.root_dir) .. "inbox.md"

	if vim.fn.filereadable(inbox_path) == 0 then
		utils.write_file(inbox_path, "Inbox", config.templates.inbox)
	end

	if opts.open then
		utils.open_file(inbox_path, opts)
	end
end

---@param opts? DotMd.PickOpts
function M.pick(opts)
	local directories = require("dotmd.directories")
	local config = require("dotmd.config").config

	opts = opts or {}
	opts.type = opts.type or "notes"
	opts.grep = opts.grep or false

	local dirs = directories.get_picker_dirs(opts)

	local prompt_name_type = opts.type == "all" and " "
		or " " .. opts.type .. " "
	local prompt_prefix = opts.grep and "Grep for" or "Pick a"
	local prompt = prompt_prefix .. prompt_name_type .. ": "

	-- Use snacks picker if exists
	local snacks_ok, snacks = pcall(require, "snacks")
	if snacks_ok and snacks and snacks.picker then
		if opts.grep then
			snacks.picker.grep({ dirs = dirs, prompt = prompt })
		else
			snacks.picker.files({ dirs = dirs, prompt = prompt })
		end
		return
	end

	-- else use vim.ui.select
	local function get_files_recursive(directory)
		local files = {}
		local scan = vim.fn.readdir(directory)
		for _, entry in ipairs(scan) do
			local full_path = directory .. entry
			if vim.fn.isdirectory(full_path) == 1 then
				vim.list_extend(files, get_files_recursive(full_path .. "/"))
			elseif entry:match("%.md$") then
				table.insert(files, full_path)
			end
		end
		return files
	end

	local function prepare_items()
		local items = {}
		for _, dir in ipairs(dirs) do
			vim.list_extend(items, get_files_recursive(dir))
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

	local function fuzzy_filter(query, items)
		query = query:lower()
		return vim.tbl_filter(function(item)
			return item.display:lower():find(query, 1, true) ~= nil
		end, items)
	end

	local items = prepare_items()
	if #items == 0 then
		vim.notify(
			"No" .. prompt_name_type .. "files found in specified directories",
			vim.log.levels.WARN
		)
		return
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
end

---Navigate to previous/next todo file
---@param direction "previous"|"next"
function M.todo_navigate(direction)
	local directories = require("dotmd.directories")

	local todo_dir = directories.get_todo_dir()
	local current_file = vim.fn.expand("%:t")
	local current_date = current_file:match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")

	local target_date
	if current_date then
		local days = direction == "previous" and -1 or 1
		target_date = os.date(
			"%Y-%m-%d",
			os.time({
				year = current_date:sub(1, 4),
				month = current_date:sub(6, 7),
				day = current_date:sub(9, 10) + days,
			})
		)
	else
		target_date = os.date("%Y-%m-%d")
	end

	local target_file = todo_dir .. target_date .. ".md"
	if vim.fn.filereadable(target_file) == 1 then
		vim.cmd("edit " .. vim.fn.fnameescape(target_file))
	else
		vim.notify(
			"No todo file found for " .. target_date,
			vim.log.levels.INFO
		)
	end
end

return M
