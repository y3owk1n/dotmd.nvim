---@class DotMd.Config
---@field root_dir? string Root directory of dotmd, default is `~/notes/`
---@field default_split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is `vertical`
---@field dir_names? DotMd.Config.DirNames
---@field templates? Dotmd.Config.Templates

---@alias DotMd.Config.DirNameKeys "notes" | "todo" | "journal"

---@class DotMd.Config.DirNames
---@field notes? string Directory name for notes, default is "notes"
---@field todo? string Todo directory name, default is "todo"
---@field journal? string Journal directory name, default is "journal"

---@class Dotmd.Config.Templates
---@field notes? fun(name: string): string[]
---@field todo? fun(date: string): string[]
---@field journal? fun(date: string): string[]
---@field inbox? fun(date: string): string[]

---@class DotMd.CreateFileOpts
---@field open? boolean Open the file after creation, default is true
---@field split? "vertical" | "horizontal" | "none" Split direction for new or existing files, default is `vertical`

---@class DotMd.PickOpts
---@field type? "notes" | "todos" | "journal" | "all" Pick type, default is `notes`
---@field grep? boolean Grep the notes directory for a string, default is false
