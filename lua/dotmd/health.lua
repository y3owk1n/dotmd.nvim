local M = {}

---Reports a status message using vim.health.
---Supports boolean values (true for OK, false for error) and string levels ("ok", "warn", "error").
---@param level "ok"|"warn"|"error" The status level.
---@param msg string The message to display.
local function report_status(level, msg)
	local health = vim.health or {}
	if level == "ok" then
		health.ok(msg)
	elseif level == "warn" then
		if health.warn then
			health.warn(msg)
		else
			health.ok("WARN: " .. msg)
		end
	elseif level == "error" then
		health.error(msg)
	else
		error("Invalid level: " .. level)
	end
end

---Prints a separator header for a new section.
---@param title string The section title.
local function separator(title)
	vim.health.start(title)
end

function M.check()
	separator("dotmd - Dependencies Check")
	if vim.fn.executable("find") == 1 then
		report_status("ok", "'find' command found.")
	else
		report_status(
			"error",
			"'find' command not found. Please install findutils."
		)
	end

	if vim.fn.executable("grep") == 1 then
		report_status("ok", "'grep' command found.")
	else
		report_status("error", "'grep' command not found. Please install grep.")
	end

	separator("dotmd - Root Directory Check")
	local ok, config = pcall(require, "dotmd.config")
	local root_dir = (
		ok
		and config
		and config.config
		and config.config.root_dir
	) or "~/notes"
	root_dir = vim.fn.expand(root_dir)
	if vim.fn.isdirectory(root_dir) == 1 then
		report_status("ok", "Configured root directory exists: " .. root_dir)
	else
		report_status(
			"warn",
			"Configured root directory does not exist: "
				.. root_dir
				.. ". It will be created on demand."
		)
	end

	separator("dotmd - Picker Check")

	if config.config.picker == nil then
		report_status(
			"warn",
			"No picker configured. It will fallback to builtin vim.ui.select. It's recommended to install one of the following plugins: fzf-lua, telescope.nvim, mini.pick, snacks."
		)
	else
		report_status("ok", "Picker configured: " .. config.config.picker)

		local picker_map = {
			fzf = "fzf-lua",
			telescope = "telescope.builtin",
			snacks = "snacks",
			mini = "mini.pick",
		}

		local picker = config.config.picker
		if picker_map[picker] then
			local picker_ok = pcall(require, picker_map[picker])
			if picker_ok then
				report_status("ok", picker_map[picker] .. " is installed.")
			else
				report_status("warn", picker .. " is not installed.")
			end
		else
			report_status(
				"warn",
				"Picker configured: " .. picker .. " is not supported."
			)
		end
	end
end

return M
