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
	-- Check for required shell commands
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

	separator("dotmd - Optional Dependencies")

	if pcall(require, "snacks") then
		report_status("ok", "snacks.nvim is installed (optional dependency).")
	else
		report_status(
			"warn",
			"snacks.nvim not found. It's optional, but recommended for enhanced fuzzy finding."
		)
	end

	if pcall(require, "fzf-lua") then
		report_status("ok", "fzf-lua is installed (optional dependency).")
	else
		report_status(
			"warn",
			"fzf-lua not found. It's optional, but recommended for enhanced fuzzy finding."
		)
	end

	if pcall(require, "telescope") then
		report_status(
			"ok",
			"telescope.nvim is installed (optional dependency)."
		)
	else
		report_status(
			"warn",
			"telescope.nvim not found. It's optional, but recommended for enhanced fuzzy finding."
		)
	end

	separator("dotmd - Root Directory Check")
	-- Check the configured root directory
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
end

return M
