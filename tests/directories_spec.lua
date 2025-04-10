---@module 'luassert'

local directories = require("dotmd.directories") -- adjust the module name/path as needed
local config = require("dotmd.config")

-- Setup a known test configuration
local test_config = {
	root_dir = "/tmp/test_root/",
	dir_names = {
		notes = "notes",
		todo = "todos",
		journal = "journal",
	},
	default_split = "vertical",
}

-- Helper: create a temporary directory for our test files.
local function tmp_dir()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	return dir
end

-- Helper: remove the given directory (recursively)
local function remove_dir(dir)
	os.execute("rm -rf " .. dir)
end

describe("dotmd.directories module", function()
	-- Override the config for testing
	before_each(function()
		config.config = test_config
	end)

	describe("get_subdir", function()
		it(
			"should return the full path for a given subdirectory key",
			function()
				local subdir_path = directories.get_subdir("notes")
				local expected = test_config.root_dir
					.. test_config.dir_names["notes"]
					.. "/"
				assert.are.equal(expected, subdir_path)
			end
		)
	end)

	describe("get_notes_dir", function()
		it("should return the notes directory", function()
			local notes_dir = directories.get_notes_dir()
			local expected = test_config.root_dir
				.. test_config.dir_names["notes"]
				.. "/"
			assert.are.equal(expected, notes_dir)
		end)
	end)

	describe("get_todo_dir", function()
		it("should return the todo directory", function()
			local todo_dir = directories.get_todo_dir()
			local expected = test_config.root_dir
				.. test_config.dir_names["todo"]
				.. "/"
			assert.are.equal(expected, todo_dir)
		end)
	end)

	describe("get_journal_dir", function()
		it("should return the journal directory", function()
			local journal_dir = directories.get_journal_dir()
			local expected = test_config.root_dir
				.. test_config.dir_names["journal"]
				.. "/"
			assert.are.equal(expected, journal_dir)
		end)
	end)

	describe("get_root_dir", function()
		it("should return the root directory", function()
			local root_dir = directories.get_root_dir()
			local expected = test_config.root_dir .. "/"
			assert.are.equal(expected, root_dir)
		end)
	end)

	describe("get_picker_dirs", function()
		it("should return all directories when type is 'all'", function()
			local opts = { type = "all" }
			local dirs = directories.get_picker_dirs(opts)
			local expected = {
				test_config.root_dir .. test_config.dir_names["notes"] .. "/",
				test_config.root_dir .. test_config.dir_names["todo"] .. "/",
				test_config.root_dir .. test_config.dir_names["journal"] .. "/",
			}
			assert.are.same(expected, dirs)
		end)

		it("should return only notes directory when type is 'notes'", function()
			local opts = { type = "notes" }
			local dirs = directories.get_picker_dirs(opts)
			local expected = {
				test_config.root_dir .. test_config.dir_names["notes"] .. "/",
			}
			assert.are.same(expected, dirs)
		end)

		it("should return only todos directory when type is 'todos'", function()
			local opts = { type = "todos" }
			local dirs = directories.get_picker_dirs(opts)
			local expected = {
				test_config.root_dir .. test_config.dir_names["todo"] .. "/",
			}
			assert.are.same(expected, dirs)
		end)

		it(
			"should return only journal directory when type is 'journal'",
			function()
				local opts = { type = "journal" }
				local dirs = directories.get_picker_dirs(opts)
				local expected = {
					test_config.root_dir
						.. test_config.dir_names["journal"]
						.. "/",
				}
				assert.are.same(expected, dirs)
			end
		)
	end)

	describe("get_subdirs_recursive", function()
		local tmp_dir = nil

		-- Create a temporary directory structure for testing.
		before_each(function()
			-- Create a unique temporary directory.
			tmp_dir = vim.fn.tempname()
			vim.fn.mkdir(tmp_dir, "p")

			-- Create subdirectories:
			-- tmp_dir/sub1
			-- tmp_dir/sub1/nested
			-- tmp_dir/sub2
			vim.fn.mkdir(tmp_dir .. "/sub1", "p")
			vim.fn.mkdir(tmp_dir .. "/sub1/nested", "p")
			vim.fn.mkdir(tmp_dir .. "/sub2", "p")
		end)

		-- Clean up the temporary directory after each test.
		after_each(function()
			-- Recursively remove the temporary directory.
			os.execute("rm -rf " .. tmp_dir)
		end)

		it(
			"returns subdirectories recursively with expected headers",
			function()
				local subdirs = directories.get_subdirs_recursive(tmp_dir)

				-- Verify that the two header strings are the first two items.
				assert.equals("[Create new subdirectory]", subdirs[1])
				assert.equals("[base directory]", subdirs[2])

				-- Since the order of subdirectories from the filesystem might not be guaranteed,
				-- check that the expected paths are present in the returned list.
				local found = {}
				for i = 3, #subdirs do
					found[subdirs[i]] = true
				end

				assert.is_true(found["sub1"])
				assert.is_true(found["sub1/nested"])
				assert.is_true(found["sub2"])
			end
		)
	end)

	describe("get_current_folder", function()
		-- Save the original vim.fn functions to restore after the test.
		local original_expand = vim.fn.expand
		local original_fnamemodify = vim.fn.fnamemodify

		before_each(function()
			-- Override vim.fn.expand to simulate returning a file's directory path.
			vim.fn.expand = function(arg)
				if arg == "%:p:h" then
					return "/home/user/project"
				end
				return ""
			end

			-- Override vim.fn.fnamemodify to simulate extracting the tail of a path.
			vim.fn.fnamemodify = function(path, modifier)
				if modifier == ":t" then
					-- Assume path "/home/user/project" returns "project"
					return "project"
				end
				return path
			end
		end)

		after_each(function()
			-- Restore the original vim.fn functions.
			vim.fn.expand = original_expand
			vim.fn.fnamemodify = original_fnamemodify
		end)

		it("returns the name of the current folder", function()
			local folder_name = directories.get_current_folder_name()
			assert.equals("project", folder_name)
		end)
	end)

	describe("get_nearest_previous_from_date", function()
		local tempdir

		before_each(function()
			tempdir = tmp_dir() .. "/" -- ensure trailing slash for concatenation
		end)

		after_each(function()
			remove_dir(vim.fn.fnamemodify(tempdir, ":h"))
		end)

		it("should return nil if no markdown files exist", function()
			local today = "2025-04-15"
			-- Ensure no md files exist in tempdir
			local ret =
				directories.get_nearest_previous_from_date(tempdir, today)
			assert.is_nil(ret)
		end)

		it("should return nil if no files match the date pattern", function()
			-- Create a file that does not match the pattern
			local bad_file = tempdir .. "notadate.txt"
			vim.fn.writefile({ "dummy content" }, bad_file)
			local today = "2025-04-15"
			local ret =
				directories.get_nearest_previous_from_date(tempdir, today)
			assert.is_nil(ret)
		end)

		it(
			"should return the most recent candidate file before today",
			function()
				local files = {
					{ name = "2025-04-10.md", content = { "File A" } },
					{ name = "2025-04-12.md", content = { "File B" } },
					{ name = "2025-04-14.md", content = { "File C" } },
					{ name = "2025-04-15.md", content = { "File D" } }, -- should not qualify: equal to today.
				}
				for _, f in ipairs(files) do
					vim.fn.writefile(f.content, tempdir .. f.name)
				end

				local today = "2025-04-15"
				local ret =
					directories.get_nearest_previous_from_date(tempdir, today)
				assert.are.equal(tempdir .. "2025-04-14.md", ret)
			end
		)
	end)

	describe("get_nearest_next_from_date", function()
		local tempdir

		before_each(function()
			tempdir = tmp_dir() .. "/" -- ensure trailing slash for concatenation
		end)

		after_each(function()
			remove_dir(vim.fn.fnamemodify(tempdir, ":h"))
		end)

		it("should return nil if no markdown files exist", function()
			local today = "2025-04-15"
			-- Ensure no md files exist in tempdir
			local ret = directories.get_nearest_next_from_date(tempdir, today)
			assert.is_nil(ret)
		end)

		it("should return nil if no files match the date pattern", function()
			-- Create a file that does not match the pattern
			local bad_file = tempdir .. "notadate.txt"
			vim.fn.writefile({ "dummy content" }, bad_file)
			local today = "2025-04-15"
			local ret = directories.get_nearest_next_from_date(tempdir, today)
			assert.is_nil(ret)
		end)

		it(
			"should return the most recent candidate file after today",
			function()
				local files = {
					{ name = "2025-04-15.md", content = { "File A" } },
					{ name = "2025-04-16.md", content = { "File B" } },
					{ name = "2025-04-17.md", content = { "File C" } },
					{ name = "2025-04-18.md", content = { "File D" } }, -- should not qualify: equal to today.
				}
				for _, f in ipairs(files) do
					vim.fn.writefile(f.content, tempdir .. f.name)
				end

				local today = "2025-04-15"
				local ret =
					directories.get_nearest_next_from_date(tempdir, today)
				assert.are.equal(tempdir .. "2025-04-16.md", ret)
			end
		)
	end)
end)
