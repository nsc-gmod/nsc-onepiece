---A class created for managing all the configurable settings
---@class NSCOP.Config
NSCOP.Config = NSCOP.Config or {}

NSCOP.Config.Main = {}
NSCOP.Config.Main.ModulesEnabled = {}

---@alias NSCOP.ConfigKey "ModulesEnabled" | "AutosaveEnabled" | "AutosaveInterval"

---Returns if the module is enabled or not
---@param module NSCOP.ModuleType
---@nodiscard
---@return boolean moduleEnabled Is the module enabled, or is it disabled via config?
function NSCOP.Config.IsModuleEnabled(module)
    return NSCOP.Config.Main.ModulesEnabled[module]
end
