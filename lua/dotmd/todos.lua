local M = {}

--- Rollover nearest previous todo to today
---@param todo_dir string
---@param today string|osdate
---@param header_text string
---@return string[]|nil, string|nil
function M.rollover_previous_todo_to_today(todo_dir, today, header_text)
	local previous_todo_file =
		require("dotmd.directories").get_nearest_previous_from_date(
			todo_dir,
			today
		)
	if not previous_todo_file then
		return nil, nil
	end

	local lines = vim.fn.readfile(previous_todo_file)
	local unchecked_tasks = {}
	local new_lines = {}

	local in_tasks = false
	for _, line in ipairs(lines) do
		if line:match("^##%s+" .. header_text) then
			in_tasks = true
			table.insert(new_lines, line)
		elseif in_tasks and line:match("^##") then
			in_tasks = false
			table.insert(new_lines, line)
		elseif in_tasks then
			if line:match("^%- %[%s*%]") then
				table.insert(unchecked_tasks, line)
			else
				table.insert(new_lines, line)
			end
		else
			table.insert(new_lines, line)
		end
	end

	if #unchecked_tasks == 0 then
		return nil, nil
	end

	require("dotmd.utils").safe_writefile(new_lines, previous_todo_file)
	return unchecked_tasks, previous_todo_file
end

--- Apply rollover todo to unchecked tasks
---@param todo_path string
---@param unchecked_tasks string[]
---@param source_path string
---@param header_text string
---@return nil
function M.apply_rollover_todo(
	todo_path,
	unchecked_tasks,
	source_path,
	header_text
)
	local utils = require("dotmd.utils")

	local today_lines = vim.fn.filereadable(todo_path) == 1
			and vim.fn.readfile(todo_path)
		or {}

	local inserted = false
	local result_lines = {}
	local header_found = false

	for i = 1, #today_lines do
		local line = today_lines[i]
		table.insert(result_lines, line)

		if not inserted and line:match("^##%s+" .. header_text) then
			header_found = true

			-- Check if the next line exists and is blank; if not, insert a blank line.
			if (i + 1 > #today_lines) or (today_lines[i + 1] ~= "") then
				table.insert(result_lines, "")
			end

			local insert_pos = i + 1

			while
				insert_pos <= #today_lines
				and not today_lines[insert_pos]:match("^##")
			do
				table.insert(result_lines, today_lines[insert_pos])
				insert_pos = insert_pos + 1
			end

			for _, task in ipairs(unchecked_tasks) do
				table.insert(result_lines, task)
			end

			inserted = true

			i = insert_pos - 1 -- Skip already inserted lines
		end
	end

	if not header_found then
		if #result_lines > 0 and result_lines[#result_lines] ~= "" then
			table.insert(result_lines, "")
		end
		table.insert(result_lines, "## " .. header_text)
		table.insert(result_lines, "")
		for _, task in ipairs(unchecked_tasks) do
			table.insert(result_lines, task)
		end
	end

	utils.safe_writefile(result_lines, todo_path)

	vim.notify(
		string.format(
			"Rolled over %d unchecked todo(s) under '%s' from %s",
			#unchecked_tasks,
			header_text,
			vim.fn.fnamemodify(source_path, ":t")
		)
	)
end

return M
