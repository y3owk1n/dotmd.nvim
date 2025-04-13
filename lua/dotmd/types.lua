---@alias DotMd.Config.DirNameKeys "notes" | "todos" | "journals"
---@alias DotMd.Split "vertical" | "horizontal" | "none" Split direction
---@alias DotMd.PickType "notes" | "todos" | "journals" | "all" Pick type
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

---@class DotMd.CreateFileOpts
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config

---@class DotMd.PickOpts
---@field picker? DotMd.PickerType Picker type, default is based on `picker` in config
---@field type? DotMd.PickType Pick type, default is `all`
---@field grep? boolean Grep the selected type directory for a string, default is false

---@class DotMd.OpenOpts
---@field type? DotMd.PickType Open type, default is `all`
---@field query? string Query to filter the files
---@field split? DotMd.Split Split direction for new or existing files, default is based on `default_split` in config
---@field pluralise_query? boolean Pluralise the query, default is `false`
