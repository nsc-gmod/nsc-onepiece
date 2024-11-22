---A class created for managing all the configurable settings
---@class NSCOP.Config
NSCOP.Config = NSCOP.Config or {}

---@type string
NSCOP.Config.PathToConfigs = "nsc-configuration/"

NSCOP.Config.Main = {}
NSCOP.Config.Main.ModulesEnabled = {}

NSCOP.Config.HUD = {}

---@alias NSCOP.ConfigKey "ModulesEnabled" | "AutosaveEnabled" | "AutosaveInterval"

---Returns if the module is enabled or not
---@param module NSCOP.ModuleType
---@nodiscard
---@return boolean moduleEnabled Is the module enabled, or is it disabled via config?
function NSCOP.Config.IsModuleEnabled(module)
	return NSCOP.Config.Main.ModulesEnabled[module]
end

---Includes and loads the config
---@param path string
function NSCOP.Config.IncludeConfig(path)
	NSCOP.IncludeShared(NSCOP.Config.PathToConfigs .. path)
end

---#region Including the Configs
NSCOP.Config.IncludeConfig("main.lua")
NSCOP.Config.IncludeConfig("hud.lua")
---#endregion
