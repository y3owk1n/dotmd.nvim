local M = {}

--- Get the path to the previous todo file from today
---@param todo_dir string
---@param today string|osdate
---@return string|nil path
function M.get_previous_todo_file_from_today(todo_dir, today)
	local find_cmd = string.format(
		[[find %s -type f -name "*.md"]],
		vim.fn.shellescape(todo_dir)
	)
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
			if file_date < today then
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

--- Rollover nearest previous todo to today
---@param todo_dir string
---@param today string|osdate
---@return string[]|nil, string|nil
function M.rollover_previous_todo_to_today(todo_dir, today)
	local previous_todo_file =
		M.get_previous_todo_file_from_today(todo_dir, today)
	if not previous_todo_file then
		return nil, nil
	end

	local lines = vim.fn.readfile(previous_todo_file)
	local unchecked_tasks = {}
	local new_lines = {}

	-- Find the tasks section
	local in_tasks = false
	for _, line in ipairs(lines) do
		if line:match("^##%s+Tasks") then
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

	if #unchecked_tasks > 0 then
		require("dotmd.utils").safe_writefile(new_lines, previous_todo_file)
		return unchecked_tasks, previous_todo_file
	end

	return nil, nil
end

return M
