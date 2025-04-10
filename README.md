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
- 🧭 **Todo Navigation:** Move to the nearest previous/next daily todo entry.
- 🔧 **Fully Configurable:** Customize directories, templates, and behavior.

<!-- panvimdoc-ignore-start -->

## 📕 Contents

- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [Quick Start](#-quick-start)
- [How It Works](#-how-it-works)
- [Template Example](#-template-example)
- [API](#-api)
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
---@field root_dir? string Root directory of dotmd, default is `~/dotmd/`
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
 root_dir = "~/dotmd/",
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
    require("dotmd").todo_navigate("previous")
   end,
   mode = "n",
   desc = "[DotMd] Navigate to previous todo",
   noremap = true,
  },
  {
   "<leader>nn",
   function()
    require("dotmd").todo_navigate("next")
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

1. Prompts for a file name or path. (See [Input patterns](#input-patterns))
2. Generates a file path inside the configured notes folder.
3. Optionally applies a notes template.
4. Opens the file in a vertical/horizontal split or current window.

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
2. If not, rolls over unfinished `- [ ] tasks from the previous file` from the nearest previous todo file (if any).
3. Applies the todo template.
4. Opens the file for editing.

### Inbox

The inbox is a special file that is used to dump thoughts, tasks, and references.

### Journal Files

When you create a new journal file, **dotmd.nvim**:

1. Builds today's journal path (e.g. `journal/2025-04-09.md`).
2. If the file doesn’t exist, creates it using the journal template.
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
---@field open? boolean Open the file after creation, default is true
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is `vertical`

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_note(opts)
```

### Create Todo for Today Date

Open/create today’s todo and roll over tasks.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@class DotMd.CreateFileOpts
---@field open? boolean Open the file after creation, default is true
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is `vertical`

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_todo_today(opts)
```

### Create Journal for Today Date

Open/create a journal entry for today.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@class DotMd.CreateFileOpts
---@field open? boolean Open the file after creation, default is true
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is `vertical`

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts)
```

### Open Inbox

Open the central `inbox.md`.

> [!note]
> Inbox is a single file that won't be recreated if exists and meant to just be there for you to dump thoughts, tasks, and references.

```lua
---@class DotMd.CreateFileOpts
---@field open? boolean Open the file after creation, default is true
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is `vertical`

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts)
```

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

Since I am exclusively using `snacks.nvim`, if you need some other picker to be integrated, feel free to help out and send in a PR for it.

### Navigate to Previous/Next Nearest Todo File

Go to nearest previous/next todo file.

```lua
---@param direction "previous"|"next"
require("dotmd").pick(direction)
```

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
