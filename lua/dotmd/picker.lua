local M = {}

local config = require("dotmd.config").config

---@param opts DotMd.PickOpts Options for picking the file
---@param dirs string[] The directories to pick from
---@param prompt string The prompt to show
---@return boolean status true if successful, false if not
function M.snacks(opts, dirs, prompt)
	local snacks_ok, snacks = pcall(require, "snacks")

	if not (snacks_ok and snacks and snacks.picker) then
		vim.notify(
			"Snacks.nvim not found, fallback to native vim.ui.select",
			vim.log.levels.WARN
		)
		return false
	end

	if opts.grep then
		snacks.picker.grep({ dirs = dirs, prompt = prompt })
	else
		snacks.picker.files({ dirs = dirs, prompt = prompt })
	end
	return true
end

---@param opts DotMd.PickOpts Options for picking the file
---@param dirs string[] The directories to pick from
---@param prompt string The prompt to show
---@return boolean status true if successful, false if not
function M.telescope(opts, dirs, prompt)
	local telescope_ok, telescope = pcall(require, "telescope.builtin")

	if not (telescope_ok and telescope) then
		vim.notify(
			"Telescope not found, fallback to native vim.ui.select",
			vim.log.levels.WARN
		)
		return false
	end

	if opts.grep then
		telescope.live_grep({
			prompt_title = prompt,
			search_dirs = dirs,
		})
	else
		-- Telescope's find_files works best with a single cwd.
		if #dirs == 1 then
			telescope.find_files({
				prompt_title = prompt,
				cwd = dirs[1],
			})
		else
			telescope.find_files({
				prompt_title = prompt,
				-- Fallback: use the current working directory if multiple dirs exist.
				cwd = vim.fn.expand(config.root_dir),
			})
		end
	end
	return true
end

---@param opts DotMd.PickOpts Options for picking the file
---@param dirs string[] The directories to pick from
---@param prompt string The prompt to show
---@return boolean status true if successful, false if not
function M.fzf(opts, dirs, prompt)
	local fzf_ok, fzf_lua = pcall(require, "fzf-lua")

	if not (fzf_ok and fzf_lua) then
		vim.notify(
			"FZF not found, fallback to native vim.ui.select",
			vim.log.levels.WARN
		)
		return false
	end

	if opts.grep then
		-- For grep, if there's only one directory then use 'cwd'
		if #dirs == 1 then
			fzf_lua.live_grep({
				prompt = prompt,
				cwd = dirs[1],
			})
		else
			-- If multiple directories, pass them with 'search_dirs'
			fzf_lua.live_grep({
				prompt = prompt,
				search_dirs = dirs,
			})
		end
	else
		-- For files, the documentation recommends using the 'cwd' option.
		-- If there's only one directory, use it; otherwise, fallback to the current working directory.
		local cwd = #dirs == 1 and dirs[1] or vim.fn.getcwd()
		fzf_lua.files({
			prompt = prompt,
			cwd = cwd,
			actions = {
				["default"] = function(selected)
					vim.cmd("edit " .. vim.fn.fnameescape(selected.path))
				end,
			},
		})
	end

	return true
end

---@param opts DotMd.PickOpts Options for picking the file
---@param dirs string[] The directories to pick from
---@param prompt string The prompt to show
---@return boolean status true if successful, false if not
function M.mini(opts, dirs, prompt)
	local minipick_ok, minipick = pcall(require, "mini.pick")

	if not (minipick_ok and minipick) then
		vim.notify(
			"mini.pick not found, fallback to native vim.ui.select",
			vim.log.levels.WARN
		)
		return false
	end

	local cwd = (#dirs == 1) and dirs[1] or vim.fn.expand(config.root_dir)
	local original_cwd = vim.fn.getcwd()

	-- Temporarily set the local working directory.
	if cwd ~= original_cwd then
		vim.cmd("lcd " .. cwd)
	end

	local local_opts = {}

	if opts.grep then
		minipick.builtin.grep_live(local_opts, opts)
	else
		minipick.builtin.files(local_opts, opts)
	end

	-- Restore the original working directory if it was changed.
	if cwd ~= original_cwd then
		vim.cmd("lcd " .. original_cwd)
	end

	return true
end

return M
