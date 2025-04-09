# 📓 dotmd

An opinionated, and fast Neovim plugin for managing markdown notes, todos, and journal entries — powered by Lua.

## ✨ Features

- 📁 **Structured Note Directories:** Organize your notes into notes/, todo/, journal/, and an inbox.md file — all configurable.
- 📄 **Smart File Creation:** Easily create note files with optional templates and unique file naming.
- 📝 **Daily Todos:** Auto-generate daily todo files and rollover unchecked tasks from the previous day.
- 📅 **Daily Journals:** Quickly generate a markdown journal entry for the current date.
- 🔍 **Note Picker:** Search or grep your notes across all categories using vim.ui.select or the snacks.nvim plugin if available.
- 📌 **Inbox:** Quick dump zone for thoughts, tasks, and references.
- 🧭 **Todo Navigation:** Move to the previous/next daily todo entry.
- 🔧 **Fully Configurable:** Customize directories, templates, and behavior.

<!-- panvimdoc-ignore-start -->

## 📕 Contents

- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [How It Works](#-how-it-works)
- [Template Example](#-template-example)
- [Commands](#-commands)
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
  - `grep`: for searching content (used in pick({ grep = true }))
- Optional but recommended:
  - [snacks.nvim](https://github.com/folke/snacks.nvim): For better note picking and grepping

## ⚙️ Configuration

> [!important]
> Make sure to run `:checkhealth dotmd` if something isn't working properly.

**dotmd.nvim** is highly configurable. And the default configurations are as below.

### Default Options

```lua
---@class DotMd.Config
---@field root_dir? string @default "~/notes/"
---@field default_split? "vertical" | "horizontal" | "none" @default "vertical"
---@field dir_names? DotMd.Config.DirNames
---@field templates? Dotmd.Config.Templates

---@class DotMd.Config.DirNames
---@field notes? string @default "notes"
---@field todo? string @default "todo"
---@field journal? string @default "journal"

---@class Dotmd.Config.Templates
---@field notes? fun(name: string): string[]
---@field todo? fun(date: string): string[]
---@field journal? fun(date: string): string[]
---@field inbox? fun(date: string): string[]
{
 root_dir = "~/notes/",
 default_split = "vertical",
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

1. Prompts for a file name or path.
2. Generates a file path inside the configured notes folder.
3. Optionally applies a notes template.
4. Opens the file in a vertical/horizontal split or current window.

### Todo Files

When you create a new todo file, **dotmd.nvim**:

1. Checks if today's todo file exists (e.g. todo/2025-04-09.md).
2. If not, rolls over unfinished `- [ ] tasks from the previous file` (if any).
3. Applies the todo template.
4. Opens the file for editing.

### Inbox

The inbox is a special file that is used to dump thoughts, tasks, and references.

### Journal Files

When you create a new journal file, **dotmd.nvim**:

1. Builds today's journal path (e.g. journal/2025-04-09.md).
2. If the file doesn’t exist, creates it using the journal template.
3. Opens it for editing.

### Picker

1. Uses `vim.ui.select` for file list or grep.
2. If `snacks.nvim` is installed, uses snacks.picker() or snacks.grep() for enhanced UX.
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

## 🛠 Commands

**dotmd.nvim** provides the following commands that you can use to map to your own keybindings:

| Functions   | Description    |
|--------------- | --------------- |
| `create_note()`   | Prompt to create and open a new markdown note   |
| `create_todo_today()`   | Open/create today’s todo and roll over tasks   |
| `create_journal()`   | Open/create a journal entry for today   |
| `inbox()`   | Open the central `inbox.md`   |
| `pick({ type, grep })`   | Pick or search notes by type   |
| `todo_navigate("next")`   | Go to next day's todo   |
| `todo_navigate("previous")`   | Go to previous day's todo   |

## 🤝 Contributing

Read the documentation carefully before submitting any issue.

Feature and pull requests are welcome.
