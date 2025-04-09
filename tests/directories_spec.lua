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

describe("dotmd.directories module", function()
	-- Override the config for testing
	setup(function()
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
end)
