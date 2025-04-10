local M = {}

--- Create a new note
---@param opts? DotMd.CreateFileOpts Options for creating the file
---@return nil
function M.create_note(opts)
	local utils = require("dotmd.utils")
	local directories = require("dotmd.directories")
	local prompt = require("dotmd.prompt")

	opts = utils.merge_default_create_file_opts(opts)

	local base_notes_dir = directories.get_notes_dir()

	local subdirs = directories.get_subdirs_recursive(base_notes_dir)

	vim.ui.select(subdirs, {
		prompt = "Select a subdirectory to create the note in: ",
	}, function(selected)
		if not selected or selected == "" then
			return
		end

		local base_path

		if selected == "[Create new subdirectory]" then
			vim.ui.input(
				{ prompt = "Enter new subdirectory name: ", default = "" },
				function(new_subdir)
					if not new_subdir or new_subdir == "" then
						return
					end

					local new_base_path = base_notes_dir .. new_subdir .. "/"

					prompt.input_note_name(new_base_path, opts)
				end
			)
		else
			if selected == "[base directory]" then
				base_path = base_notes_dir
			else
				base_path = base_notes_dir .. selected .. "/"
			end

			prompt.input_note_name(base_path, opts)
		end
	end)
end

--- Create a new todo for today
---@param opts? DotMd.CreateFileOpts Options for creating the file
---@return nil
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
		vim.ui.select({ "yes", "no" }, {
			prompt = "Create todo for today?",
		}, function(input)
			if not input or input == "" then
				return
			end

			if input == "no" then
				vim.notify("Aborted todo creation", vim.log.levels.INFO)
				return
			end

			utils.write_file(
				todo_path,
				"Todo for " .. today,
				config.templates.todo
			)

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

			if opts.open then
				utils.open_file(todo_path, opts)
			end
		end)
	else
		if opts.open then
			utils.open_file(todo_path, opts)
		end
	end
end

--- Create a new journal entry
---@param opts? DotMd.CreateFileOpts Options for creating the file
---@return nil
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
		vim.ui.select({ "yes", "no" }, {
			prompt = "Create journal entry for today?",
		}, function(input)
			if not input or input == "" then
				return
			end

			if input == "no" then
				vim.notify(
					"Aborted journal entry creation",
					vim.log.levels.INFO
				)
				return
			end

			utils.write_file(
				journal_path,
				"Journal Entry for " .. today,
				config.templates.journal
			)

			if opts.open then
				utils.open_file(journal_path, opts)
			end
		end)
	else
		if opts.open then
			utils.open_file(journal_path, opts)
		end
	end
end

--- Create or open inbox
---@param opts? DotMd.CreateFileOpts Options for creating the file
---@return nil
function M.inbox(opts)
	local utils = require("dotmd.utils")
	local config = require("dotmd.config").config
	local directories = require("dotmd.directories")

	opts = utils.merge_default_create_file_opts(opts)

	local inbox_path = directories.get_root_dir() .. "inbox.md"

	if vim.fn.filereadable(inbox_path) == 0 then
		utils.write_file(inbox_path, "Inbox", config.templates.inbox)
	end

	if opts.open then
		utils.open_file(inbox_path, opts)
	end
end

--- Pick a file from a list of directories
---@param opts? DotMd.PickOpts Options for picking the file
---@return nil
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

---Navigate to the nearest previous/next date-based file
---@param direction "previous"|"next"
---@return nil
function M.navigate(direction)
	local directories = require("dotmd.directories")
	local utils = require("dotmd.utils")

	local current_file = vim.fn.expand("%:t")

	local current_folder = vim.fn.expand("%:p:h")
	local current_folder_name = directories.get_current_folder_name()

	local current_date = current_file:match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")

	if not utils.is_date_based_directory(current_folder_name) then
		vim.notify(
			"Aborted... This function can only be run in `journal` or `todo`",
			vim.log.levels.WARN
		)
		return
	end

	if not current_date then
		vim.notify("Current file is not a todo file", vim.log.levels.WARN)
		return
	end

	local parsed_current_date = os.date(
		"%Y-%m-%d",
		os.time({
			year = current_date:sub(1, 4),
			month = current_date:sub(6, 7),
			day = current_date:sub(9, 10),
		})
	)

	local to_navigate_path

	if direction == "previous" then
		to_navigate_path = directories.get_nearest_previous_from_date(
			current_folder,
			parsed_current_date
		)
	elseif direction == "next" then
		to_navigate_path = directories.get_nearest_next_from_date(
			current_folder,
			parsed_current_date
		)
	end

	if to_navigate_path and vim.fn.filereadable(to_navigate_path) == 1 then
		vim.cmd("edit " .. vim.fn.fnameescape(to_navigate_path))
	else
		vim.notify(
			string.format("No %s %s found", direction, current_folder_name),
			vim.log.levels.INFO
		)
	end
end

return M
