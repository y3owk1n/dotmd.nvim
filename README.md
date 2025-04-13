# 📓 dotmd.nvim

Organize. Navigate. Create. Markdown. All without leaving your keyboard.

<!-- panvimdoc-ignore-start -->

<https://github.com/user-attachments/assets/509f19d9-4172-4708-ad48-6a31735e6a6b>

## Why **dotmd.nvim**?

> "I just want to write Markdown files... **fast**."

As a Neovim user, we spent most of our time in the editor. Yet everytime when we need to:

- Jot a quick thought
- Write a note
- Create a daily journal
- Track todos

...we end up reaching for external underused but overpowered apps or fighting complex plugins.

**dotmd.nvim** fixes this with:

- ⚡ **Zero context-switching** - Manage everything in Neovim
- 🎯 **Dead-simple workflow** - No databases, no proprietary formats, just Markdown that we loved
- 🔋 **Batteries included** - Smart templates, navigation, and cross-device sync ready (It's just Markdown files and folders)

<!-- panvimdoc-ignore-end -->

## ✨ Features

| Feature   | Description    |
|--------------- | --------------- |
| **🗂️ Effortless Organization**   | Auto-structured directories for `notes/`, `todos/`, `journals/` + `inbox`    |
| **🎩 Smart File Creation**   | Templates that adapt to your needs   |
| **🔄 Todo Time Machine**   | Unfinished tasks automatically roll over to today's list   |
| **🧭 GPS for Notes**   | Jump between todo/journal entries easily   |
| **🔍 Universal Search**   | Find anything instantly with integrated pickers (Telescope/fzf-lua/snacks/mini.pick)   |
| **📦 Inbox Zero**   | Single-file brain dump with `inbox.md`   |
| **⚙️ Fully Configurable**   | Change directories, templates, splits - make it yours   |

<!-- panvimdoc-ignore-start -->

## 📕 Contents

- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [Quick Start](#-quick-start)
- [How It Works](#-how-it-works)
- [Template Example](#-template-example)
- [API](#-api)
- [Goodies](#-goodies)
- [Contributing](#-contributing)

<!-- panvimdoc-ignore-end -->

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- dotmd.lua
return {
 "y3owk1n/dotmd.nvim",
 version = "*", -- remove this if you want to use the `main` branch
 opts = {
  -- your configuration comes here
  -- or leave it empty to use the default settings
  -- refer to the configuration section below
 }
}
```

If you are using other package managers you need to call `setup`:

```lua
require("dotmd").setup({
  -- your configuration
})
```

### Requirements

- Neovim 0.9+ with Lua support
- The following CLI tools must be available in your $PATH:
  - `find`: for listing files across note directories
  - `grep`: for searching files across note directories
- (Optional but recommended) One of the following picker for better picking files and grepping:
  - [snacks.nvim](https://github.com/folke/snacks.nvim)
  - [fzf-lua](https://github.com/ibhagwan/fzf-lua)
  - [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
  - [mini.pick](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pick.md)

## ⚙️ Configuration

> [!important]
> Make sure to run `:checkhealth dotmd` if something isn't working properly.

**dotmd.nvim** is highly configurable. And the default configurations are as below.

### Default Options

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "none" Split direction
---@alias DotMd.PickerType "telescope" | "fzf" | "snacks" | "mini" Picker type

---@class DotMd.Config
---@field root_dir? string Root directory of dotmd, default is `~/dotmd`
---@field default_split? DotMd.Split Split direction for new or existing files, default is `none`
---@field picker? DotMd.PickerType Picker type, default is `nil`
---@field rollover_todo? DotMd.Config.RolloverTodo
---@field dir_names? DotMd.Config.DirNames
---@field templates? Dotmd.Config.Templates

---@class DotMd.Config.RolloverTodo
---@field enabled? boolean Rollover the nearest previous unchecked todos to today's date, default is `false`
---@field heading? string Heading to search for in your todos template to rollover, default is "Tasks"

---@class DotMd.Config.DirNames
---@field notes? string Directory name for notes, default is "notes"
---@field todos? string Todo directory name, default is "todos"
---@field journals? string Journal directory name, default is "journals"

---@class Dotmd.Config.Templates
---@field notes? fun(name: string): string[]
---@field todos? fun(date: string): string[]
---@field journals? fun(date: string): string[]
---@field inbox? fun(date: string): string[]
{
 root_dir = "~/dotmd",
 default_split = "none",
 rollover_todo = {
  enabled = false,
  heading = "Tasks",
 },
 picker = nil,
 dir_names = {
  notes = "notes",
  todos = "todos",
  journals = "journals",
 },
 templates = {
  notes = function(title)
   return {
    "---",
    "title: " .. title,
    "created: " .. os.date("%Y-%m-%d %H:%M"),
    "---",
    "",
    "# " .. title,
    "",
   }
  end,
  todos = function(date)
   return {
    "---",
    "type: todo",
    "date: " .. date,
    "---",
    "",
    "# Todo for " .. date,
    "",
    "## Tasks",
    "",
   }
  end,
  journals = function(date)
   return {
    "---",
    "type: journal",
    "date: " .. date,
    "---",
    "",
    "# Journal Entry for " .. date,
    "",
    "## Highlights",
    "",
    "## Thoughts",
    "",
    "## Tasks",
    "",
   }
  end,
  inbox = function()
   return {
    "---",
    "type: inbox",
    "---",
    "",
    "# Inbox",
    "",
    "## Quick Notes",
    "",
    "## Tasks",
    "",
    "## References",
    "",
   }
  end,
 },
}
```

## 🚀 Quick Start

See the example below for how to configure **dotmd.nvim**.

```lua
{
 "y3owk1n/dotmd.nvim",
 cmd = {
  "DotMdCreateNote",
  "DotMdCreateTodoToday",
  "DotMdCreateJournal",
  "DotMdInbox",
  "DotMdNavigate",
  "DotMdPick",
  "DotMdOpen",
 },
 event = "VeryLazy",
 ---@type DotMd.Config
 opts = {
  root_dir = "~/dotmd" -- set it to your desired directory or remain at it is
  default_split = "none" -- or "vertical" or "horizontal" based on your preference
  rollover_todo = {
   enabled = true, -- enable rollover
  },
  picker = "snacks" -- or "fzf" or "telescope" or "mini" based on your preference
 },
 keys = {
  {
   "<leader>nc",
   function()
    require("dotmd").create_note()
   end,
   mode = "n",
   desc = "[DotMd] Create new note",
   noremap = true,
  },
  {
   "<leader>nt",
   function()
    require("dotmd").create_todo_today()
   end,
   mode = "n",
   desc = "[DotMd] Create todo for today",
   noremap = true,
  },
  {
   "<leader>ni",
   function()
    require("dotmd").inbox()
   end,
   mode = "n",
   desc = "[DotMd] Inbox",
   noremap = true,
  },
  {
   "<leader>nj",
   function()
    require("dotmd").create_journal()
   end,
   mode = "n",
   desc = "[DotMd] Create journal",
   noremap = true,
  },
  {
   "<leader>np",
   function()
    require("dotmd").navigate("previous")
   end,
   mode = "n",
   desc = "[DotMd] Navigate to previous todo",
   noremap = true,
  },
  {
   "<leader>nn",
   function()
    require("dotmd").navigate("next")
   end,
   mode = "n",
   desc = "[DotMd] Navigate to next todo",
   noremap = true,
  },
  {
   "<leader>no",
   function()
    require("dotmd").open({
     pluralise_query = true, -- recommended
    })
   end,
   mode = "n",
   desc = "[DotMd] Open",
   noremap = true,
  },
  {
   "<leader>sna",
   function()
    require("dotmd").pick()
   end,
   mode = "n",
   desc = "[DotMd] Everything",
   noremap = true,
  },
  {
   "<leader>snA",
   function()
    require("dotmd").pick({
     grep = true,
    })
   end,
   mode = "n",
   desc = "[DotMd] Search everything grep",
   noremap = true,
  },
  {
   "<leader>snn",
   function()
    require("dotmd").pick({
     type = "notes",
    })
   end,
   mode = "n",
   desc = "[DotMd] Search notes",
   noremap = true,
  },
  {
   "<leader>snN",
   function()
    require("dotmd").pick({
     type = "notes",
     grep = true,
    })
   end,
   mode = "n",
   desc = "[DotMd] Search notes grep",
   noremap = true,
  },
  {
   "<leader>snt",
   function()
    require("dotmd").pick({
     type = "todos",
    })
   end,
   mode = "n",
   desc = "[DotMd] Search todos",
   noremap = true,
  },
  {
   "<leader>snT",
   function()
    require("dotmd").pick({
     type = "todos",
     grep = true,
    })
   end,
   mode = "n",
   desc = "[DotMd] Search todos grep",
   noremap = true,
  },
  {
   "<leader>snj",
   function()
    require("dotmd").pick({
     type = "journals",
    })
   end,
   mode = "n",
   desc = "[DotMd] Search journal",
   noremap = true,
  },
  {
   "<leader>snJ",
   function()
    require("dotmd").pick({
     type = "journals",
     grep = true,
    })
   end,
   mode = "n",
   desc = "[DotMd] Search journal grep",
   noremap = true,
  },
 },
},
```

## 📦 How It Works

**dotmd.nvim** is built around the idea of managing lightweight Markdown files organized by category. Here's how each feature works:

### Directory Structure

**dotmd.nvim** uses a root directory with the following substructure (customizable):

```bash
dotmd/
├── inbox.md # single file for brain dump
├── notes/
│   └── project-idea.md
│   └── meetings
│       └── 2025-04-08.md
├── todos/
│   └── 2025-04-08.md # yesterday
│   └── 2025-04-09.md # today (auto-created when called)
└── journals/
    └── 2025-04-09.md # today's reflections
```

### Note Creation

When you create a new note, **dotmd.nvim**:

1. Prompts for select/create a subdirectory or use the base directory.
2. Prompts for a file name or path. (See [Input patterns](#input-patterns))
3. Generates a file path inside the configured notes folder.
4. Optionally applies a notes template.
5. Opens the file in a vertical/horizontal split or current window.

#### Input patterns

- If the file name is not a path, it will be transformed and used as a file name and title.
  - Input: `Amazing Idea`
  - Output path: `amazing-idea.md`
  - Output h1 heading: `# Amazing Idea`
- If the file name is a path, it will be used as a file path and the title will be transformed from the file name.
  - Input: `amazing-idea.md`
  - Output path: `amazing-idea.md`
  - Output h1 heading: `# Amazing Idea`
- Support also nested directories during file creation (e.g. `project/idea.md`)
  - Input: `project/idea.md`
  - Output path: `project/idea.md`
  - Output h1 heading: `# Idea`
- Weird enough, something like this will work too
  - `project/Amazing Idea` -> `project/amazing-idea.md`
  - `project/amazing-idea` -> `project/amazing-idea.md`

### Todo Files

When you create a new todo file, **dotmd.nvim**:

1. Checks if today's todo file exists (e.g. `todos/2025-04-09.md`).
2. If the file doesn't exist, prompt for create confirmation.
3. If confirm, rolls over unfinished `- [ ] tasks from the previous file` from the nearest previous todo file (if any and enabled).
4. Applies the todo template.
5. Opens the file for editing.

### Inbox

The inbox is a special file that is used to dump thoughts, tasks, and references.

### Journal Files

When you create a new journal file, **dotmd.nvim**:

1. Checks if today's journal file exists (e.g. `journals/2025-04-09.md`).
2. If the file doesn't exist, prompt for create confirmation.
2. If confirm, creates it using the journal template.
3. Opens it for editing.

### Picker

1. Uses `vim.ui.select` for file list or grep as fallback or default.
2. You can choose to use `snacks.nvim`, `fzf-lua`, or `telescope.nvim` for the picker based on your preference.
3. Can filter by file type (notes, todo, journal, or all).

### Open

1. Smart fuzzy-match query and open if single match or prompt `vim.ui.select` for multiple matches.
2. Can filter by file type (notes, todo, journal, or all).

## 🧠 Custom Template Example

To create a template, just concatenate the template strings into a function that returns a list of strings.

```lua
journals = function(date)
  return {
    "---",
    "type: journal",
    "date: " .. date,
    "---",
    "# " .. date,
    "",
    "## What happened today?",
    "## Reflections",
    "## TODOs",
  }
end
```

## 🌎 API

**dotmd.nvim** provides the following api functions that you can use to map to your own keybindings:

### Create Note

Prompt to create and open a new markdown note.

> [!note]
> This cannot be used to open a note, it will create a new file with prefix if the file exists.
> To open a note, use the `pick` command instead.

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_note(opts)
```

You can also use the command `:DotMdCreateNote` to create a new note. And it supports the same options.

### Create or open Todo for Today Date

Open/create today’s todo and roll over tasks.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_todo_today(opts)
```

You can also use the command `:DotMdCreateTodoToday` to create a new todo for today. And it supports the same options.

### Create or open Journal for Today Date

Open/create a journal entry for today.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts)
```

You can also use the command `:DotMdCreateJournal` to create a new journal entry. And it supports the same options.

### Open Inbox

Open the central `inbox.md`.

> [!note]
> Inbox is a single file that won't be recreated if exists and meant to just be there for you to dump thoughts, tasks, and references.

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts)
```

You can also use the command `:DotMdInbox` to open the central `inbox.md`. And it supports the same options.

### Pick

Pick or search files in **dotmd.nvim** directories by `type`.

> [!note]
> Recommended to any of the pickers `snacks.nvim`, `fzf-lua`, or `telescope.nvim` for enhanced UX, else will fallback to `vim.ui.select`.

> [!warning]
> `grep` option is not supported and will do nothing for the fallback.

```lua
---@alias DotMd.PickType "notes" | "todos" | "journals" | "all" Pick type
---@alias DotMd.PickerType "telescope" | "fzf" | "snacks" | "mini" Picker type

---@class DotMd.PickOpts
---@field picker? DotMd.PickerType Picker type, default is based on `picker` in config
---@field type? DotMd.PickType Pick type, default is `all`
---@field grep? boolean Grep the selected type directory for a string, default is false

---@param opts? DotMd.PickOpts
require("dotmd").pick(opts)
```

You can also use the command `:DotMdPick` to pick or search files in **dotmd.nvim** directories by `type`. And it supports the same options.

### Navigate to Previous/Next Nearest `journals` or `todos` File

Go to nearest previous/next date-based file.

```lua
---@param direction "previous"|"next"
require("dotmd").navigate(direction)
```

You can also use the command `:DotMdNavigate` to navigate to the nearest previous/next date-based file. And it supports the same options.

### Open

Open a files intelligently in **dotmd.nvim** directories by `type`. You can either provide a `query` or it will prompt for the search query.

> [!note]
> The query are matched by splitted tokens in a case-insensitive way.
> If you want to have the behavior to get matches by plurals, you can set `pluralise_query` to `true`.
> For example, if you search for `todo` it will match `todos` and `todo`.

```lua
---@alias DotMd.PickType "notes" | "todos" | "journals" | "all" Pick type

---@class DotMd.OpenOpts
---@field type? DotMd.PickType Open type, default is `all`
---@field query? string Query to filter the files
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config
---@field pluralise_query? boolean Pluralise the query, default is `false`

---@param opts? DotMd.OpenOpts Options for opening the file
require("dotmd").open(opts)
```

You can also use the command `:DotMdOpen` to open files in **dotmd.nvim** directories.

> [!note]
> I'm still not entirely sure about the existence of this API. After the supports for `snacks.nvim`, `fzf-lua`, and `telescope.nvim` are added, this API seems like not entirely useful anymore, but let's see.

## 🎁 Goodies

### Summon your notes anywhere within a tmux session

You can summon your notes anywhere within a `tmux session` in a floating/popup pane by adding the following to your `~/.tmux.conf`:

> [!note]
> Change `~/dotmd` to your dotmd root directory.

```bash
# create a new tmux keytable for dotmd
bind-key C-n switch-client -T dotmd

# bind keys with dotmd commands in popup
bind-key -T dotmd t run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Todo' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdCreateTodoToday split=none\\\"\"'"
bind-key -T dotmd n run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Note' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdCreateNote split=none\\\"\"'"
bind-key -T dotmd i run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Inbox' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdInbox split=none\\\"\"'"
bind-key -T dotmd j run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Journal' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdCreateJournal split=none\\\"\"'"
bind-key -T dotmd o run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Open' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdOpen split=none pluralise_query=true\\\"\"'"
bind-key -T dotmd p run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Pick' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdPick\\\"\"'"
bind-key -T dotmd r run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Root' 'sh -c \"cd ~/dotmd && nvim\"'"

# switch back to root keytable with escape
bind-key -T dotmd Escape switch-client -T root
```

1. Press your tmux prefix key and then `ctrl-n` to switch to the `dotmd` keytable. And then followed by:

- Press `t` to create a new or open existing todo file for today.
- Press `n` to create a note.
- Press `i` to open the inbox for quick thoughts dumping.
- Press `j` to create a new or open existing journal file for today.
- Press `o` to open a files intelligently.
- Press `p` to pick a file.
- Press `r` to open the root directory, and you can do anything just like you would in a regular vim session.

2. Do whatever you want to do in the popup pane.
3. Quit with just `:wq` just like you would in a regular vim session.

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
