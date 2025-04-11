# 📓 dotmd.nvim

An opinionated, and fast Neovim plugin for managing markdown notes, todos, and journal entries — powered by Lua.

<!-- panvimdoc-ignore-start -->

## A little bit about why

I’ve been using Apple Notes for a while — mostly because of how effortlessly it syncs across devices. But over time, I started to get frustrated with how mouse-dependent it is. I prefer staying in the keyboard as much as possible, especially when I'm just jotting down thoughts or todos.

I tried [Obsidian](https://obsidian.md/) too. It’s a solid tool, no doubt — but I noticed I wasn’t really using most of its features. What stuck with me was just the simplicity of editing Markdown files.

So I started building dotmd — something small and focused. I wanted a way to work with Markdown notes directly inside Neovim, where I already spend most of my time. Nothing fancy. Just fast navigation, basic organization, and plain files I can sync easily across devices. On iOS, I can still open them with any Markdown viewer if I need to. That’s enough for me.

<!-- panvimdoc-ignore-end -->

## ✨ Features

- 📁 **Structured Note Directories:** Organize your notes into `notes/`, `todo/`, `journal/`, and an `inbox.md` file — all configurable.
- 📄 **Smart File Creation:** Easily create files with optional templates and unique file naming.
- 📝 **Daily Todos:** Auto-generate daily todo files and rollover unchecked tasks from the nearest previous day.
- 📅 **Daily Journals:** Quickly generate a markdown journal entry for the current date.
- 🔍 **Note Picker:** Search or grep your notes across all categories using `vim.ui.select` or the `snacks.nvim` plugin if available.
- 📌 **Inbox:** Quick dump zone for thoughts, tasks, and references.
- 🧭 **Smart Navigation:** Move to the nearest previous/next `todo` or `journal` entry automagically.
- 🔧 **Fully Configurable:** Customize directories, templates, and behavior.

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
- Optional but recommended:
  - [snacks.nvim](https://github.com/folke/snacks.nvim): For better note picking and grepping

## ⚙️ Configuration

> [!important]
> Make sure to run `:checkhealth dotmd` if something isn't working properly.

**dotmd.nvim** is highly configurable. And the default configurations are as below.

### Default Options

```lua
---@class DotMd.Config
---@field root_dir? string Root directory of dotmd, default is `~/dotmd`
---@field default_split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is `none`
---@field dir_names? DotMd.Config.DirNames
---@field templates? Dotmd.Config.Templates

---@class DotMd.Config.DirNames
---@field notes? string Directory name for notes, default is "notes"
---@field todo? string Todo directory name, default is "todo"
---@field journal? string Journal directory name, default is "journal"

---@class Dotmd.Config.Templates
---@field notes? fun(name: string): string[]
---@field todo? fun(date: string): string[]
---@field journal? fun(date: string): string[]
---@field inbox? fun(date: string): string[]
{
 root_dir = "~/dotmd",
 default_split = "none",
 dir_names = {
  notes = "notes",
  todo = "todo",
  journal = "journal",
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
  todo = function(date)
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
  journal = function(date)
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
 },
 event = { "VeryLazy" },
 ---@type DotMd.Config
 opts = {},
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
     type = "journal",
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
     type = "journal",
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
├── inbox.md
├── notes/
│   └── project-idea.md
├── todo/
│   └── 2025-04-09.md
└── journal/
    └── 2025-04-09.md
```

### File Creation

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

1. Checks if today's todo file exists (e.g. `todo/2025-04-09.md`).
2. If the file doesn't exist, prompt for create confirmation.
3. If confirm, rolls over unfinished `- [ ] tasks from the previous file` from the nearest previous todo file (if any).
4. Applies the todo template.
5. Opens the file for editing.

### Inbox

The inbox is a special file that is used to dump thoughts, tasks, and references.

### Journal Files

When you create a new journal file, **dotmd.nvim**:

1. Checks if today's journal file exists (e.g. `journal/2025-04-09.md`).
2. If the file doesn't exist, prompt for create confirmation.
2. If confirm, creates it using the journal template.
3. Opens it for editing.

### Picker

1. Uses `vim.ui.select` for file list or grep.
2. If `snacks.nvim` is installed, uses `snacks.picker.grep()` or `snacks.picker.files()` for enhanced UX.
3. Can filter by file type (notes, todo, journal, or all).

## 🧠 Template Example

To create a template, just concatenate the template strings into a function that returns a list of strings.

```lua
journal = function(date)
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
---@class DotMd.CreateFileOpts
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_note(opts)
```

You can also use the command `:DotMdCreateNote` to create a new note. And it supports the same options.

### Create or open Todo for Today Date

Open/create today’s todo and roll over tasks.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@class DotMd.CreateFileOpts
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_todo_today(opts)
```

You can also use the command `:DotMdCreateTodoToday` to create a new todo for today. And it supports the same options.

### Create or open Journal for Today Date

Open/create a journal entry for today.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@class DotMd.CreateFileOpts
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts)
```

You can also use the command `:DotMdCreateJournal` to create a new journal entry. And it supports the same options.

### Open Inbox

Open the central `inbox.md`.

> [!note]
> Inbox is a single file that won't be recreated if exists and meant to just be there for you to dump thoughts, tasks, and references.

```lua
---@class DotMd.CreateFileOpts
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts)
```

You can also use the command `:DotMdInbox` to open the central `inbox.md`. And it supports the same options.

### Pick

Pick or search files in **dotmd.nvim** directories by `type`.

> [!note]
> Recommended to use `snacks.nvim` for enhanced UX, else will fallback to `vim.ui.select`.

> [!warning]
> `grep` option is not supported and will do nothing for the fallback.

```lua
---@class DotMd.PickOpts
---@field type? "notes" | "todos" | "journal" | "all" Pick type, default is `notes`
---@field grep? boolean Grep the selected type directory for a string, default is false

---@param opts? DotMd.PickOpts
require("dotmd").pick(opts)
```

You can also use the command `:DotMdPick` to pick or search files in **dotmd.nvim** directories by `type`. And it supports the same options.

Since I am exclusively using `snacks.nvim`, if you need some other picker to be integrated, feel free to help out and send in a PR for it.

### Navigate to Previous/Next Nearest `journal` or `todo` File

Go to nearest previous/next date-based file.

```lua
---@param direction "previous"|"next"
require("dotmd").navigate(direction)
```

You can also use the command `:DotMdNavigate` to navigate to the nearest previous/next date-based file. And it supports the same options.

## 🎁 Goodies

### Summon your notes anywhere within a tmux session

You can summon your notes anywhere within a tmux session in a floating pane by adding the following to your `~/.tmux.conf`:

> [!note]
> Change `~/dotmd` to your dotmd root directory.

```bash
# create a new tmux keytable for dotmd
bind-key C-n switch-client -T dotmd

# bind keys with dotmd commands in popup
bind-key -T dotmd t run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Todo' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdCreateTodoToday split=none\\\"\"'"
bind-key -T dotmd n run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Note' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdCreateNote split=none\\\"\"'"
bind-key -T dotmd i run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Inbox' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdInbox split=none\\\"\"'"
bind-key -T dotmd j run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Jornal' 'sh -c \"cd ~/dotmd && nvim +\\\"DotMdCreateJournal split=none\\\"\"'"
bind-key -T dotmd r run-shell "tmux popup -E -w 90% -h 80% -T 'Dotmd Root' 'sh -c \"cd ~/dotmd && nvim\"'"

# switch back to root keytable with escape
bind-key -T dotmd Escape switch-client -T root
```

1. Press your tmux prefix key and then `ctrl-n` to switch to the `dotmd` keytable. And then followed by:

- Press `t` to create a new or open existing todo file for today.
- Press `n` to create a note.
- Press `i` to open the inbox for quick thoughts dumping.
- Press `j` to create a new or open existing journal file for today.
- Press `r` to open the root directory, and you can do anything just like you would in a regular vim session.

2. Do whatever you want to do in the popup pane.
3. Quit with just `:wq` just like you would in a regular vim session.

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
