---@module 'luassert'

local utils = require("dotmd.utils") -- adjust this as needed
local config = require("dotmd.config").config

local uv = vim.loop
local fn = vim.fn

-- helper: create a temporary directory to hold test files
local function tmp_dir()
	local dir = fn.tempname()
	fn.mkdir(dir, "p")
	return dir
end

-- helper: remove directory recursively
local function remove_dir(dir)
	os.execute("rm -rf " .. dir)
end

describe("dotmd.utils module", function()
	describe("merge_default_create_file_opts", function()
		it("should set default values when no opts provided", function()
			local opts = utils.merge_default_create_file_opts()
			-- by default opts.open is true if not explicitly false
			assert.is_true(opts.open)
			-- opts.split should be set to either dotmd.config default_split or "vertical"
			local expected = require("dotmd.config").config.default_split
				or "vertical"
			assert.are.equal(expected, opts.split)
		end)

		it("should keep opts.open false if provided as false", function()
			local opts = utils.merge_default_create_file_opts({ open = false })
			assert.is_false(opts.open)
		end)
	end)

	describe("sanitize_filename", function()
		it("should replace forbidden characters with dash", function()
			local input = [[test<file>:"/\|?*name]]
			local expected = "test-file--------name"
			local sanitized = utils.sanitize_filename(input)
			assert.are.equal(expected, sanitized)
		end)
	end)

	describe("format_filename", function()
		it(
			"should lower-case, replace spaces with dashes, remove .md extension, then sanitize",
			function()
				local input = "My Test File.md"
				-- First lower and space conversion: "my-test-file", then remove .md gives "my-test-file"
				local expected = "my-test-file"
				local formatted = utils.format_filename(input)
				assert.are.equal(expected, formatted)
			end
		)

		it("should sanitize any residual forbidden characters", function()
			local input = "Another Test: File.md"
			local expected = "another-test--file" -- colon is replaced
			local formatted = utils.format_filename(input)
			assert.are.equal(expected, formatted)
		end)
	end)

	describe("deformat_filename", function()
		it(
			"should replace dashes and underscores with spaces and capitalize first letter",
			function()
				local input = "my-test_file"
				local expected = "My test file"
				local deformatted = utils.deformat_filename(input)
				assert.are.equal(expected, deformatted)
			end
		)
	end)

	describe("ensure_directory", function()
		it("should create the directory recursively", function()
			local dir = fn.tempname() .. "/nested/dir"
			utils.ensure_directory(dir)
			local stat = uv.fs_stat(dir)
			assert.is_not_nil(stat)
			remove_dir(fn.fnamemodify(dir, ":h"))
		end)
	end)

	describe("safe_writefile", function()
		local original_notify

		before_each(function()
			original_notify = vim.notify
			vim.notify = function(msg, level)
				-- Optionally, capture the message in a global (or upvalue) variable for further assertions,
				-- or simply do nothing to silence output.
				_G.last_notify = msg
			end
		end)

		after_each(function()
			vim.notify = original_notify
			_G.last_notify = nil
		end)

		it("should write the file and return true", function()
			local tmp = tmp_dir()
			local file = tmp .. "/test.txt"
			local content = { "line1", "line2" }
			local ok = utils.safe_writefile(content, file)
			assert.is_true(ok)
			local read = fn.readfile(file)
			assert.are.same(content, read)
			remove_dir(tmp)
		end)

		it("should catch errors and return false", function()
			-- try writing to an illegal file path
			local illegal_path = "/illegal/path/to/file.txt"
			local ok = utils.safe_writefile({ "dummy" }, illegal_path)
			assert.is_false(ok)
		end)
	end)

	describe("is_path_like", function()
		it("should detect unix-like paths", function()
			assert.is_true(utils.is_path_like("folder/file"))
			assert.is_true(utils.is_path_like("./folder"))
			assert.is_true(utils.is_path_like("~/folder"))
		end)

		it("should detect windows-like paths", function()
			assert.is_true(utils.is_path_like("C:\\folder\\file"))
		end)

		it("should detect file extensions", function()
			assert.is_true(utils.is_path_like("file.txt"))
		end)

		it("should return nil if not a path-like string", function()
			assert.falsy(utils.is_path_like("plainstring"))
		end)
	end)

	describe("get_unique_filepath", function()
		it("should return a file path if no existing file", function()
			local tmp = tmp_dir() .. "/"
			local formatted_name = "testfile"
			local unique_path = utils.get_unique_filepath(tmp, formatted_name)
			assert.are.equal(tmp .. formatted_name .. ".md", unique_path)
			remove_dir(fn.fnamemodify(tmp, ":h"))
		end)

		it("should return an incremented file path if file exists", function()
			local tmp = tmp_dir() .. "/"
			local formatted_name = "duplicate"
			local file_path = tmp .. formatted_name .. ".md"
			-- create a dummy file
			fn.writefile({ "dummy" }, file_path)
			local unique_path = utils.get_unique_filepath(tmp, formatted_name)
			-- first alternative should end with "-1.md"
			assert.are.equal(tmp .. formatted_name .. "-1.md", unique_path)
			remove_dir(fn.fnamemodify(tmp, ":h"))
		end)
	end)

	describe("open_file", function()
		it("should open file using the provided split option", function()
			-- Create a temporary file to open
			local tmp = tmp_dir() .. "/"
			fn.mkdir(tmp, "p")
			local file_path = tmp .. "open_test.md"
			fn.writefile({ "# header" }, file_path)

			-- Choose split command based on opts.split
			local opts = { split = "vertical" }
			utils.open_file(file_path, opts)
			-- Verify that the current window's buffer name is the same as the file path
			local bufname = fn.expand("%:p")
			assert.are.equal(fn.fnamemodify(file_path, ":p"), bufname)

			remove_dir(fn.fnamemodify(tmp, ":h"))
		end)
	end)

	describe("write_file", function()
		it(
			"should create the file with header using provided template function",
			function()
				local tmp = tmp_dir() .. "/"
				fn.mkdir(tmp, "p")
				local file_path = tmp .. "write_test.md"
				local header = "Test Header"
				local template = function(h)
					return { "# " .. h, "", "Extra content" }
				end

				utils.write_file(file_path, header, template)
				local content = fn.readfile(file_path)
				assert.are.same(
					{ "# " .. header, "", "Extra content" },
					content
				)
				remove_dir(fn.fnamemodify(tmp, ":h"))
			end
		)

		it(
			"should create the file with default header when no template provided",
			function()
				local tmp = tmp_dir() .. "/"
				fn.mkdir(tmp, "p")
				local file_path = tmp .. "write_default.md"
				local header = "Default Header"
				utils.write_file(file_path, header)
				local content = fn.readfile(file_path)
				assert.are.same({ "# " .. header }, content)
				remove_dir(fn.fnamemodify(tmp, ":h"))
			end
		)
	end)

	describe("contains", function()
		it("should return true if exists", function()
			local arr = { "a", "b", "c" }
			local target = "b"
			assert.is_true(utils.contains(arr, target))
		end)

		it("should return false if not exists", function()
			local arr = { "a", "b", "c" }
			local target = "d"
			assert.is_false(utils.contains(arr, target))
		end)

		it("should return false if empty array", function()
			local arr = {}
			local target = "b"
			assert.is_false(utils.contains(arr, target))
		end)
	end)

	describe("is_date_based_directory", function()
		before_each(function()
			config.dir_names.journal = "journal"
			config.dir_names.todo = "todo"
			config.dir_names.notes = "notes"
		end)

		it("should return true if current folder is journal", function()
			local current_folder_name = "journal"
			local is_date_based =
				utils.is_date_based_directory(current_folder_name)
			assert.is_true(is_date_based)
		end)

		it("should return false if current folder is todo", function()
			local current_folder_name = "todo"
			local is_date_based =
				utils.is_date_based_directory(current_folder_name)
			assert.is_false(is_date_based)
		end)

		it(
			"should return false if current folder is not journal or todo",
			function()
				local current_folder_name = "notes"
				local is_date_based =
					utils.is_date_based_directory(current_folder_name)
				assert.is_false(is_date_based)
			end
		)

		it("should return false if current folder is empty", function()
			local current_folder_name = ""
			local is_date_based =
				utils.is_date_based_directory(current_folder_name)
			assert.is_false(is_date_based)
		end)
	end)
end)
