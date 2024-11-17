-- This file is going to be included by the autorun, and then it will include all of the module. This is probably how it's going to work for every module
-- The purpose of this module called "Initizalizer" is to create all of the meta shit used by other modules and code

if SERVER then
	AddCSLuaFile("shared/sh_init.lua")
end
include("shared/sh_init.lua")

NSCOP.IncludeModule(NSCOP.Modules.Utils)
NSCOP.IncludeModule(NSCOP.Modules.AssetLoader)
NSCOP.IncludeModule(NSCOP.Modules.ConfigManager)
NSCOP.IncludeModule(NSCOP.Modules.DataManager)
NSCOP.IncludeModule(NSCOP.Modules.CombatSystem)

NSCOP.PrintFileLoaded()
