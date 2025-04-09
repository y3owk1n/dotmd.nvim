---@class DotMd.Config
---@field root_dir? string @default "~/notes/"
---@field default_split? "vertical" | "horizontal" | "none" @default "vertical"
---@field dir_names? DotMd.Config.DirNames
---@field templates? Dotmd.Config.Templates

---@alias DotMd.Config.DirNameKeys "notes" | "todo" | "journal"

---@class DotMd.Config.DirNames
---@field notes? string @default "notes"
---@field todo? string @default "todo"
---@field journal? string @default "journal"

---@class Dotmd.Config.Templates
---@field notes? fun(name: string): string[]
---@field todo? fun(date: string): string[]
---@field journal? fun(date: string): string[]
---@field inbox? fun(date: string): string[]

---@class DotMd.CreateFileOpts
---@field open? boolean @default true
---@field split? "vertical" | "horizontal" | "none" @default config.default_split

---@class DotMd.PickOpts
---@field type? "notes" | "todos" | "journal" | "all" @default "notes"
---@field grep? boolean @default false
