local M = {}

function M.tmp_dir()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	return dir
end

function M.remove_dir(dir)
	os.execute("rm -rf " .. dir)
end

return M
