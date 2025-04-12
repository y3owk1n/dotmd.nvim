---@module 'luassert'

local directories = require("dotmd.directories")
local config = require("dotmd.config")
local test_utils = require("dotmd.test-utils")

local test_config = {
	root_dir = test_utils.tmp_dir() .. "/",
	default_split = "vertical",
}

describe("dotmd.directories module", function()
	before_each(function()
		config.setup(test_config)

		vim.fn.mkdir(config.config.root_dir, "p")
		vim.fn.mkdir(
			config.config.root_dir .. config.config.dir_names.notes,
			"p"
		)
		vim.fn.mkdir(
			config.config.root_dir .. config.config.dir_names.todos,
			"p"
		)
		vim.fn.mkdir(
			config.config.root_dir .. config.config.dir_names.journals,
			"p"
		)
	end)

	after_each(function()
		test_utils.remove_dir(vim.fn.fnamemodify(config.config.root_dir, ":h"))
		config.config = {}
	end)

	describe("get_subdir", function()
		it(
			"should return the full path for a given subdirectory key",
			function()
				local subdir_path = directories.get_subdir("notes")
				local expected = config.config.root_dir
					.. config.config.dir_names["notes"]
					.. "/"
				assert.are.equal(expected, subdir_path)
			end
		)
	end)

	describe("get_notes_dir", function()
		it("should return the notes directory", function()
			local notes_dir = directories.get_notes_dir()
			local expected = config.config.root_dir
				.. config.config.dir_names["notes"]
				.. "/"
			assert.are.equal(expected, notes_dir)
		end)
	end)

	describe("get_todo_dir", function()
		it("should return the todo directory", function()
			local todo_dir = directories.get_todo_dir()
			local expected = config.config.root_dir
				.. config.config.dir_names["todos"]
				.. "/"
			assert.are.equal(expected, todo_dir)
		end)
	end)

	describe("get_journal_dir", function()
		it("should return the journal directory", function()
			local journal_dir = directories.get_journal_dir()
			local expected = config.config.root_dir
				.. config.config.dir_names["journals"]
				.. "/"
			assert.are.equal(expected, journal_dir)
		end)
	end)

	describe("get_root_dir", function()
		it("should return the root directory", function()
			local root_dir = directories.get_root_dir()
			local expected = config.config.root_dir .. "/"
			assert.are.equal(expected, root_dir)
		end)
	end)

	describe("get_picker_dirs", function()
		it("should return all directories when type is 'all'", function()
			local opts = { type = "all" }
			local dirs = directories.get_picker_dirs(opts.type)
			local expected = {
				config.config.root_dir
					.. config.config.dir_names["notes"]
					.. "/",
				config.config.root_dir
					.. config.config.dir_names["todos"]
					.. "/",
				config.config.root_dir
					.. config.config.dir_names["journals"]
					.. "/",
			}
			assert.are.same(expected, dirs)
		end)

		it("should return only notes directory when type is 'notes'", function()
			local opts = { type = "notes" }
			local dirs = directories.get_picker_dirs(opts.type)
			local expected = {
				config.config.root_dir
					.. config.config.dir_names["notes"]
					.. "/",
			}
			assert.are.same(expected, dirs)
		end)

		it("should return only todos directory when type is 'todos'", function()
			local opts = { type = "todos" }
			local dirs = directories.get_picker_dirs(opts.type)
			local expected = {
				config.config.root_dir
					.. config.config.dir_names["todos"]
					.. "/",
			}
			assert.are.same(expected, dirs)
		end)

		it(
			"should return only journal directory when type is 'journal'",
			function()
				local opts = { type = "journals" }
				local dirs = directories.get_picker_dirs(opts.type)
				local expected = {
					config.config.root_dir
						.. config.config.dir_names["journals"]
						.. "/",
				}
				assert.are.same(expected, dirs)
			end
		)
	end)

	describe("get_subdirs_recursive", function()
		before_each(function()
			vim.fn.mkdir(config.config.root_dir .. "/sub1", "p")
			vim.fn.mkdir(config.config.root_dir .. "/sub1/nested", "p")
			vim.fn.mkdir(config.config.root_dir .. "/sub2", "p")
		end)

		it(
			"returns subdirectories recursively with expected headers",
			function()
				local subdirs =
					directories.get_subdirs_recursive(config.config.root_dir)

				assert.equals("[Create new subdirectory]", subdirs[1])
				assert.equals("[base directory]", subdirs[2])

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
					return "project"
				end
				return path
			end
		end)

		after_each(function()
			vim.fn.expand = original_expand
			vim.fn.fnamemodify = original_fnamemodify
		end)

		it("returns the name of the current folder", function()
			local folder_name = directories.get_current_folder_name()
			assert.equals("project", folder_name)
		end)
	end)

	describe("get_nearest_previous_from_date", function()
		it("should return nil if no markdown files exist", function()
			local today = "2025-04-15"
			local ret = directories.get_nearest_previous_from_date(
				config.config.root_dir,
				today
			)
			assert.is_nil(ret)
		end)

		it("should return nil if no files match the date pattern", function()
			local bad_file = config.config.root_dir .. "notadate.txt"
			vim.fn.writefile({ "dummy content" }, bad_file)
			local today = "2025-04-15"
			local ret = directories.get_nearest_previous_from_date(
				config.config.root_dir,
				today
			)
			assert.is_nil(ret)
		end)

		it(
			"should return the most recent candidate file before today",
			function()
				local files = {
					{ name = "2025-04-10.md", content = { "File A" } },
					{ name = "2025-04-12.md", content = { "File B" } },
					{ name = "2025-04-14.md", content = { "File C" } },
					{ name = "2025-04-15.md", content = { "File D" } },
				}
				for _, f in ipairs(files) do
					vim.fn.writefile(
						f.content,
						config.config.root_dir .. f.name
					)
				end

				local today = "2025-04-15"
				local ret = directories.get_nearest_previous_from_date(
					config.config.root_dir,
					today
				)
				assert.are.equal(config.config.root_dir .. "2025-04-14.md", ret)
			end
		)
	end)

	describe("get_nearest_next_from_date", function()
		it("should return nil if no markdown files exist", function()
			local today = "2025-04-15"
			local ret = directories.get_nearest_next_from_date(
				config.config.root_dir,
				today
			)
			assert.is_nil(ret)
		end)

		it("should return nil if no files match the date pattern", function()
			local bad_file = config.config.root_dir .. "notadate.txt"
			vim.fn.writefile({ "dummy content" }, bad_file)
			local today = "2025-04-15"
			local ret = directories.get_nearest_next_from_date(
				config.config.root_dir,
				today
			)
			assert.is_nil(ret)
		end)

		it(
			"should return the most recent candidate file after today",
			function()
				local files = {
					{ name = "2025-04-15.md", content = { "File A" } },
					{ name = "2025-04-16.md", content = { "File B" } },
					{ name = "2025-04-17.md", content = { "File C" } },
					{ name = "2025-04-18.md", content = { "File D" } },
				}
				for _, f in ipairs(files) do
					vim.fn.writefile(
						f.content,
						config.config.root_dir .. f.name
					)
				end

				local today = "2025-04-15"
				local ret = directories.get_nearest_next_from_date(
					config.config.root_dir,
					today
				)
				assert.are.equal(config.config.root_dir .. "2025-04-16.md", ret)
			end
		)
	end)

	describe("get_files_recursive", function()
		before_each(function()
			vim.fn.mkdir(config.config.root_dir, "p")

			vim.fn.mkdir(config.config.root_dir .. "/sub1", "p")
			vim.fn.mkdir(config.config.root_dir .. "/sub1/nested", "p")
			vim.fn.mkdir(config.config.root_dir .. "/sub2", "p")

			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "dummy.md"
			)
			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "sub1/dummy.md"
			)
			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "sub1/nested/dummy.md"
			)
			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "sub2/dummy.md"
			)
		end)

		it("recursively gets .md files", function()
			local files =
				directories.get_files_recursive(config.config.root_dir)
			local expected = {
				config.config.root_dir .. "dummy.md",
				config.config.root_dir .. "sub1/dummy.md",
				config.config.root_dir .. "sub1/nested/dummy.md",
				config.config.root_dir .. "sub2/dummy.md",
			}
			assert.are.same(expected, files)
		end)
	end)

	describe("prepare_items_for_select", function()
		before_each(function()
			vim.fn.mkdir(config.config.root_dir, "p")

			vim.fn.mkdir(config.config.root_dir .. "/sub1", "p")
			vim.fn.mkdir(config.config.root_dir .. "/sub1/nested", "p")
			vim.fn.mkdir(config.config.root_dir .. "/sub2", "p")

			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "dummy.md"
			)
			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "sub1/dummy.md"
			)
			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "sub1/nested/dummy.md"
			)
			vim.fn.writefile(
				{ "dummy content" },
				config.config.root_dir .. "sub2/dummy.md"
			)
		end)

		it("converts paths to display format", function()
			local items =
				directories.prepare_items_for_select({ config.config.root_dir })
			local expected = {
				{
					value = config.config.root_dir .. "dummy.md",
					display = "dummy.md",
				},
				{
					value = config.config.root_dir .. "sub1/dummy.md",
					display = "sub1/dummy.md",
				},
				{
					value = config.config.root_dir .. "sub1/nested/dummy.md",
					display = "sub1/nested/dummy.md",
				},
				{
					value = config.config.root_dir .. "sub2/dummy.md",
					display = "sub2/dummy.md",
				},
			}
			assert.are.same(expected, items)
		end)
	end)
end)
