local M = {}

local winborder = vim.api.nvim_get_option_value(
	"winborder",
	{ scope = "local" }
) or "none"

local shared_win_opts = {
	relative = "editor",
	width = 0.8,
	height = 0.8,
	border = winborder,
	title_pos = "center",
	footer = "Remember to :wq to save and exit",
	footer_pos = "center",
}

--- Create a floating window for snacks
---@param buf integer The buffer to open
---@return snacks.win
local function create_snacks_float(buf)
	local win_opts = vim.tbl_deep_extend("force", shared_win_opts, {
		minimal = false,
		show = false,
		buf = buf,
		title = "DotMd (Snacks)",
		bo = {
			readonly = false,
			modifiable = true,
		},
	})
	local _, snacks = pcall(require, "snacks")

	return snacks.win.new(win_opts)
end

--- Create a floating window for native
---@param buf integer The buffer to open
---@return integer win_id
local function create_native_float(buf)
	local win_opts = vim.tbl_deep_extend("force", shared_win_opts, {
		title = "DotMd (Native)",
	})

	win_opts.width = math.floor(vim.o.columns * win_opts.width)
	win_opts.height = math.floor(vim.o.lines * win_opts.height)
	win_opts.row = math.floor((vim.o.lines - win_opts.height) / 2)
	win_opts.col = math.floor((vim.o.columns - win_opts.width) / 2)

	local win_id = vim.api.nvim_open_win(buf, true, win_opts)

	return win_id
end

local snacks_float = nil
local native_float = nil

---@param file_path string The path to the file
function M.open_float(file_path)
	if vim.fn.filereadable(file_path) == 0 then
		vim.notify("File not found: " .. file_path, vim.log.levels.WARN)
		return
	end

	local snacks_ok, snacks = pcall(require, "snacks")

	vim.cmd("badd " .. vim.fn.fnameescape(file_path))
	local buf = vim.fn.bufnr(file_path)

	if not (snacks_ok and snacks and snacks.win) then
		vim.schedule(function()
			vim.api.nvim_set_option_value(
				"filetype",
				"markdown",
				{ scope = "local", buf = buf }
			)

			if native_float then
				if vim.api.nvim_win_is_valid(native_float) then
					vim.api.nvim_win_set_buf(native_float, buf)
					return
				end
			end

			native_float = create_native_float(buf)
		end)
	else
		vim.schedule(function()
			if not snacks_float then
				snacks_float = create_snacks_float(buf)
			end

			snacks_float:show()
			snacks_float:set_buf(buf)
		end)
	end
end

return M
