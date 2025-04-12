---@alias DotMd.Config.DirNameKeys "notes" | "todo" | "journal"
---@alias DotMd.Split "vertical" | "horizontal" | "none" Split direction
---@alias DotMd.PickType "notes" | "todos" | "journal" | "all" Pick type

---@class DotMd.Config
---@field root_dir? string Root directory of dotmd, default is `~/dotmd`
---@field default_split? DotMd.Split Split direction for new or existing files, default is `none`
---@field rollover_todo? boolean Rollover the nearest previous unchecked todos to today's date, default is `true`
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

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@class DotMd.PickOpts
---@field type? DotMd.PickType Pick type, default is `notes`
---@field grep? boolean Grep the selected type directory for a string, default is false

---@class DotMd.OpenOpts
---@field type? DotMd.PickType Open type, default is `all`
---@field query? string Query to filter the files
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config
---@field pluralise_query? boolean Pluralise the query, default is `false`
