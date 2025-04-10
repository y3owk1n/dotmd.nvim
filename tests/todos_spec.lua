---@module 'luassert'

local todos = require("dotmd.todos")
local utils = require("dotmd.utils") -- Used by rollover; make sure this module is loaded if not in the same file

local fn = vim.fn
local uv = vim.loop

-- Helper: create a temporary directory for our test files.
local function tmp_dir()
	local dir = fn.tempname()
	fn.mkdir(dir, "p")
	return dir
end

-- Helper: remove the given directory (recursively)
local function remove_dir(dir)
	os.execute("rm -rf " .. dir)
end

describe("dotmd.todos module", function()
	describe("rollover_previous_todo_to_today", function()
		local tempdir

		setup(function()
			tempdir = tmp_dir() .. "/"
		end)

		teardown(function()
			remove_dir(fn.fnamemodify(tempdir, ":h"))
		end)

		it(
			"should do nothing and return nil,nil if no previous todo file exists",
			function()
				local today = "2025-04-20"
				local unchecked, path =
					todos.rollover_previous_todo_to_today(tempdir, today)
				assert.is_nil(unchecked)
				assert.is_nil(path)
			end
		)

		it(
			"should update the file and return unchecked tasks when tasks exist",
			function()
				-- Prepare a file with a tasks section including some unchecked tasks.
				local file_date = "2025-04-18"
				local filename = tempdir .. file_date .. ".md"
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
				fn.writefile(lines, filename)

				-- Create another file that should not be picked up because it is on/after today.
				local later_filename = tempdir .. "2025-04-20.md"
				fn.writefile(
					{ "# Todo for 2025-04-20", "## Tasks", "- [ ] Irrelevant" },
					later_filename
				)

				local today = "2025-04-20"
				local unchecked, path =
					todos.rollover_previous_todo_to_today(tempdir, today)
				-- Expect unchecked tasks to be those that match the pattern inside the tasks section.
				local expected_unchecked =
					{ "- [ ] Task one", "- [ ] Task three" }
				assert.are.same(expected_unchecked, unchecked)
				-- The file that was updated should be the one with file_date "2025-04-18".
				assert.are.equal(filename, path)

				-- Verify that the file content no longer contains the unchecked tasks.
				local new_lines = fn.readfile(filename)
				for _, task in ipairs(expected_unchecked) do
					assert.is_false(vim.tbl_contains(new_lines, task))
				end
			end
		)

		it(
			"should return nil,nil if there are no unchecked tasks in the tasks section",
			function()
				-- Prepare a file with tasks section but all tasks are checked.
				local file_date = "2025-04-17"
				local filename = tempdir .. file_date .. ".md"
				local lines = {
					"# Todo for " .. file_date,
					"",
					"## Tasks",
					"- [x] Task completed",
					"Other details",
					"## Done",
					"- Finished work",
				}
				fn.writefile(lines, filename)

				local today = "2025-04-18"
				local unchecked, path =
					todos.rollover_previous_todo_to_today(tempdir, today)
				assert.is_nil(unchecked)
				assert.is_nil(path)
			end
		)
	end)
end)
