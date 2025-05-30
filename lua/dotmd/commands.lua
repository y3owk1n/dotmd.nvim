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
				config.templates.todos
			)

			if
				config.rollover_todo.enabled == true
				and config.rollover_todo.headings ~= nil
				and #config.rollover_todo.headings > 0
			then
				for _, heading in ipairs(config.rollover_todo.headings) do
					local unchecked_tasks, source_path =
						todos.rollover_previous_todo_to_today(
							todo_dir,
							today,
							heading
						)

					if unchecked_tasks and source_path then
						todos.apply_rollover_todo(
							todo_path,
							unchecked_tasks,
							source_path,
							heading
						)
					end
				end
			end

			utils.open_file(todo_path, opts.split)
		end)
	else
		utils.open_file(todo_path, opts.split)
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
				config.templates.journals
			)

			utils.open_file(journal_path, opts.split)
		end)
	else
		utils.open_file(journal_path, opts.split)
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

	utils.open_file(inbox_path, opts.split)
end

--- Pick a file from a list of directories
---@param opts? DotMd.PickOpts Options for picking the file
---@return nil
function M.pick(opts)
	local directories = require("dotmd.directories")
	local picker = require("dotmd.picker")
	local native_select_files = require("dotmd.prompt").native_select_files

	opts = opts or {}
	opts.type = opts.type or "all"
	opts.grep = opts.grep or false
	opts.picker = opts.picker or require("dotmd.config").config.picker

	local dirs = directories.get_picker_dirs(opts.type)

	local prompt_name_type = opts.type == "all" and " "
		or " " .. opts.type .. " "
	local prompt_prefix = opts.grep and "Grep for" or "Pick a"
	local prompt = prompt_prefix .. prompt_name_type .. ": "

	local allowed_pickers = {
		fzf = true,
		telescope = true,
		snacks = true,
		mini = true,
	}

	if opts.picker then
		if not allowed_pickers[opts.picker] then
			vim.notify(
				"Aborted... Picker "
					.. opts.picker
					.. " is not supported, fallback to vim.ui.select",
				vim.log.levels.WARN
			)
		else
			local picker_ok = picker[opts.picker](opts, dirs, prompt)

			if picker_ok then
				return
			end
		end
	end

	-- else use vim.ui.select
	native_select_files(dirs, prompt_name_type, prompt)
end

---Navigate to the nearest previous/next date-based file
---@param direction "previous"|"next"
---@return nil
function M.navigate(direction)
	local directories = require("dotmd.directories")
	local utils = require("dotmd.utils")
	local config = require("dotmd.config").config

	local current_file = vim.fn.expand("%:t")

	local current_folder = vim.fn.expand("%:p:h")
	local current_folder_name = directories.get_current_folder_name()

	local current_date = current_file:match("^(%d%d%d%d%-%d%d%-%d%d)%.md$")

	if not utils.is_date_based_directory(current_folder_name) then
		vim.notify(
			"Aborted... This function can only be run in `journals` or `todos`",
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
		-- NOTE: Force to be either "float" or "none". Normally `navigation` should be called
		-- within a buffer already, and it should be navigating within the buffer.
		local normalised_split = config.default_split == "float" and "float"
			or "none"
		require("dotmd.utils").open_file(to_navigate_path, normalised_split)
	else
		vim.notify(
			string.format("No %s %s found", direction, current_folder_name),
			vim.log.levels.INFO
		)
	end
end

--- Open a file based on a type and an intelligent search query.
--- If a single file is found, it is opened; if multiple, the user is given a selection.
---@param opts? DotMd.OpenOpts Options for opening the file
function M.open(opts)
	local directories = require("dotmd.directories")
	local utils = require("dotmd.utils")

	opts = opts or {}
	opts.type = opts.type or "all"
	opts.split = opts.split or require("dotmd.config").config.default_split
	opts.pluralise_query = opts.pluralise_query or false

	local dirs = directories.get_picker_dirs(opts.type)

	local all_items = directories.prepare_items_for_select(dirs)
	if #all_items == 0 then
		vim.notify(
			"No "
				.. opts.type
				.. " Markdown files found in the specified directories.",
			vim.log.levels.WARN
		)
		return
	end

	---@param _all_items string[] The items to search
	---@param _query string The query to search for
	---@return nil
	local function perform_search(_all_items, _query)
		local lower_query = _query:lower()

		local query_words = {}
		for word in lower_query:gmatch("%S+") do
			table.insert(query_words, word)
		end

		local function normalize(s)
			return s:lower():gsub("[%-_%.]", " ")
		end

		local function fuzzy_filter(item)
			local normalized_display = normalize(item.display)

			for _, word in ipairs(query_words) do
				-- Also support optional "s" at the end of the word for plurals if configured
				local plural_suffix = opts.pluralise_query and "s?" or ""
				local pattern = "%f[%w]" .. word .. plural_suffix .. "%f[%W]"
				if not normalized_display:find(pattern) then
					return false
				end
			end
			return true
		end

		local filtered_items = vim.tbl_filter(fuzzy_filter, _all_items)

		if #filtered_items == 0 then
			vim.notify(
				"No matching "
					.. opts.type
					.. " files found for query: "
					.. _query,
				vim.log.levels.INFO
			)
			return
		elseif #filtered_items == 1 then
			-- Only one file was found; open it directly.
			utils.open_file(filtered_items[1].value, opts.split)
		else
			-- More than one matching file; let the user pick.
			vim.ui.select(filtered_items, {
				prompt = "Select a " .. opts.type .. " file:",
				format_item = function(item)
					return item.display
				end,
			}, function(selected)
				if selected then
					utils.open_file(selected.value, opts.split)
				end
			end)
		end
	end

	if opts.query and opts.query ~= "" then
		perform_search(all_items, opts.query)
	else
		vim.ui.input({ prompt = "Enter note search query: " }, function(query)
			if not query or query == "" then
				return
			end

			perform_search(all_items, query)
		end)
	end
end

return M
