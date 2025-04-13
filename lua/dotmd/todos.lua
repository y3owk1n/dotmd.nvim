local M = {}

--- Rollover nearest previous todo to today
---@param todo_dir string
---@param today string|osdate
---@return string[]|nil, string|nil
function M.rollover_previous_todo_to_today(todo_dir, today)
	local config = require("dotmd.config").config
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

	-- Find the tasks section
	local in_tasks = false
	for _, line in ipairs(lines) do
		if line:match("^##%s+" .. config.rollover_todo.heading) then
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
