# 📓 dotmd.nvim

Organize. Navigate. Create. Markdown.
Keep all your notes, todos, and journals inside Neovim without ever leaving the editor.

<!-- panvimdoc-ignore-start -->

<https://github.com/user-attachments/assets/509f19d9-4172-4708-ad48-6a31735e6a6b>

## 🤔 Why **dotmd.nvim**?

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

- 🚀 **Zero Context-Switching:** Stay in Neovim.
- 🗂 **Effortless Organization:** Auto-created directories for notes, todos, journals, plus an inbox file.
- 🎩 **Smart File Creation:** Use adaptive templates.
- ⏪ **Todo Time Machine:** Automatically roll over unfinished tasks.
- 🧭 **Rapid Navigation:** Jump between entries with ease.
- 🔍 **Universal Search:** Fuzzy-match files with Telescope, fzf-lua, snacks.nvim, or mini.pick.
- ⚙️ **Complete Customizability:** Tweak directories, templates, split directions, and more.

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
---@alias DotMd.Split "vertical" | "horizontal" | "float" | "none" Split direction
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
---@field headings? string[] H2 Headings to search for in your todos template to rollover, default is { "Tasks" }

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
  heading = { "Tasks" },
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
  default_split = "none" -- or "vertical" or "horizontal" or "float" based on your preference
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
   desc = "[DotMd] Create new note",
  },
  {
   "<leader>nt",
   function()
    require("dotmd").create_todo_today()
   end,
   desc = "[DotMd] Create todo for today",
  },
  {
   "<leader>ni",
   function()
    require("dotmd").inbox()
   end,
   desc = "[DotMd] Inbox",
  },
  {
   "<leader>nj",
   function()
    require("dotmd").create_journal()
   end,
   desc = "[DotMd] Create journal",
  },
  {
   "<leader>np",
   function()
    require("dotmd").navigate("previous")
   end,
   desc = "[DotMd] Navigate to previous todo",
  },
  {
   "<leader>nn",
   function()
    require("dotmd").navigate("next")
   end,
   desc = "[DotMd] Navigate to next todo",
  },
  {
   "<leader>no",
   function()
    require("dotmd").open({
     pluralise_query = true, -- recommended
    })
   end,
   desc = "[DotMd] Open",
  },
  {
   "<leader>sna",
   function()
    require("dotmd").pick()
   end,
   desc = "[DotMd] Everything",
  },
  {
   "<leader>snA",
   function()
    require("dotmd").pick({
     grep = true,
    })
   end,
   desc = "[DotMd] Search everything grep",
  },
  {
   "<leader>snn",
   function()
    require("dotmd").pick({
     type = "notes",
    })
   end,
   desc = "[DotMd] Search notes",
  },
  {
   "<leader>snN",
   function()
    require("dotmd").pick({
     type = "notes",
     grep = true,
    })
   end,
   desc = "[DotMd] Search notes grep",
  },
  {
   "<leader>snt",
   function()
    require("dotmd").pick({
     type = "todos",
    })
   end,
   desc = "[DotMd] Search todos",
  },
  {
   "<leader>snT",
   function()
    require("dotmd").pick({
     type = "todos",
     grep = true,
    })
   end,
   desc = "[DotMd] Search todos grep",
  },
  {
   "<leader>snj",
   function()
    require("dotmd").pick({
     type = "journals",
    })
   end,
   desc = "[DotMd] Search journal",
  },
  {
   "<leader>snJ",
   function()
    require("dotmd").pick({
     type = "journals",
     grep = true,
    })
   end,
   desc = "[DotMd] Search journal grep",
  },
 },
},
```

## 📦 How It Works

**dotmd.nvim** organizes your Markdown files as follows:

```bash
dotmd/
├── inbox.md         # Brain dump file
├── notes/           # Organized Markdown notes
├── todos/           # Date-based todo files (with rollover support)
└── journals/        # Date-based journal entries
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

> [!note]
>
> - You can configure the headings to search for in your todos template to rollover by setting `rollover_todo.headings` in the config.
> - Note that only `h2` or `##` is supported for now.
> - Make sure it actually matches the headings in your template.
> - If a heading does not exist in previous todo, it will get ignored.
> - For today's todo file, if a heading doesn't exist in the template, it will append the section at the end of the file (if there's any rollover).

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
---@alias DotMd.Split "vertical" | "horizontal" | "float" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_note(opts) # or :DotMdCreateNote
```

### Create or open Todo for Today Date

Open/create today’s todo and roll over tasks.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "float" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_todo_today(opts) # or :DotMdCreateTodoToday
```

### Create or open Journal for Today Date

Open/create a journal entry for today.

> [!note]
> Can be used to open the current todo file, if it exists, else it creates a new one.

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "float" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts) # or :DotMdCreateJournal
```

### Open Inbox

Open the central `inbox.md`.

> [!note]
> Inbox is a single file that won't be recreated if exists and meant to just be there for you to dump thoughts, tasks, and references.

```lua
---@alias DotMd.Split "vertical" | "horizontal" | "float" | "none" Split direction

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@param opts? DotMd.CreateFileOpts
require("dotmd").create_journal(opts) # or :DotMdInbox
```

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
require("dotmd").pick(opts) # or :DotMdPick
```

### Navigate to Previous/Next Nearest `journals` or `todos` File

Go to nearest previous/next date-based file.

```lua
---@param direction "previous"|"next"
require("dotmd").navigate(direction) # or :DotMdNavigate
```

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
require("dotmd").open(opts) # or :DotMdOpen
```

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
