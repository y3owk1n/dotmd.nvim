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
	describe("get_previous_todo_file_from_today", function()
		local tempdir

		setup(function()
			tempdir = tmp_dir() .. "/" -- ensure trailing slash for concatenation
		end)

		teardown(function()
			remove_dir(fn.fnamemodify(tempdir, ":h"))
		end)

		it("should return nil if no markdown files exist", function()
			local today = "2025-04-15"
			-- Ensure no md files exist in tempdir
			local ret =
				todos.get_nearest_previous_todo_from_date(tempdir, today)
			assert.is_nil(ret)
		end)

		it("should return nil if no files match the date pattern", function()
			-- Create a file that does not match the pattern
			local bad_file = tempdir .. "notadate.txt"
			fn.writefile({ "dummy content" }, bad_file)
			local today = "2025-04-15"
			local ret =
				todos.get_nearest_previous_todo_from_date(tempdir, today)
			assert.is_nil(ret)
		end)

		it(
			"should return the most recent candidate file before today",
			function()
				-- Create several markdown files with dates in the filename.
				local files = {
					{ name = "2025-04-10.md", content = { "File A" } },
					{ name = "2025-04-12.md", content = { "File B" } },
					{ name = "2025-04-14.md", content = { "File C" } },
					{ name = "2025-04-15.md", content = { "File D" } }, -- should not qualify: equal to today.
				}
				for _, f in ipairs(files) do
					fn.writefile(f.content, tempdir .. f.name)
				end

				local today = "2025-04-15"
				local ret =
					todos.get_nearest_previous_todo_from_date(tempdir, today)
				-- Candidates are those with dates strictly less than today:
				-- "2025-04-10.md", "2025-04-12.md", and "2025-04-14.md".
				-- The function should return the one with the highest date, i.e. "2025-04-14.md".
				assert.are.equal(tempdir .. "2025-04-14.md", ret)
			end
		)
	end)

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
