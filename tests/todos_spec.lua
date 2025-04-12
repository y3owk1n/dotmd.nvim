---@module 'luassert'

local todos = require("dotmd.todos")
local test_utils = require("dotmd.test-utils")
local config = require("dotmd.config")

local test_config = {
	root_dir = test_utils.tmp_dir() .. "/",
	default_split = "vertical",
}

describe("dotmd.todos module", function()
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

	describe("rollover_previous_todo_to_today", function()
		it(
			"should do nothing and return nil,nil if no previous todo file exists",
			function()
				local today = "2025-04-20"
				local unchecked, path = todos.rollover_previous_todo_to_today(
					config.config.root_dir,
					today
				)
				assert.is_nil(unchecked)
				assert.is_nil(path)
			end
		)

		it(
			"should update the file and return unchecked tasks when tasks exist",
			function()
				local file_date = "2025-04-18"
				local filename = config.config.root_dir .. file_date .. ".md"
				local lines = {
					"# Todo for " .. file_date,
					"",
					"## Tasks",
					"- [ ] Task one",
					"- [x] Task two",
					"Some intermediate text",
					"- [ ] Task three",
					"",
					"## Other Section",
					"More content",
				}
				vim.fn.writefile(lines, filename)

				-- Create another file that should not be picked up because it is on/after today.
				local later_filename = config.config.root_dir .. "2025-04-20.md"
				vim.fn.writefile(
					{ "# Todo for 2025-04-20", "## Tasks", "- [ ] Irrelevant" },
					later_filename
				)

				local today = "2025-04-20"
				local unchecked, path = todos.rollover_previous_todo_to_today(
					config.config.root_dir,
					today
				)

				-- Expect unchecked tasks to be those that match the pattern inside the tasks section.
				local expected_unchecked =
					{ "- [ ] Task one", "- [ ] Task three" }
				assert.are.same(expected_unchecked, unchecked)
				-- The file that was updated should be the one with file_date "2025-04-18".
				assert.are.equal(filename, path)

				-- Verify that the file content no longer contains the unchecked tasks.
				local new_lines = vim.fn.readfile(filename)
				for _, task in ipairs(expected_unchecked) do
					assert.is_false(vim.tbl_contains(new_lines, task))
				end
			end
		)

		it(
			"should return nil,nil if there are no unchecked tasks in the tasks section",
			function()
				local file_date = "2025-04-17"
				local filename = config.config.root_dir .. file_date .. ".md"
				local lines = {
					"# Todo for " .. file_date,
					"",
					"## Tasks",
					"- [x] Task completed",
					"Other details",
					"## Done",
					"- Finished work",
				}
				vim.fn.writefile(lines, filename)

				local today = "2025-04-18"
				local unchecked, path = todos.rollover_previous_todo_to_today(
					config.config.root_dir,
					today
				)
				assert.is_nil(unchecked)
				assert.is_nil(path)
			end
		)
	end)
end)
