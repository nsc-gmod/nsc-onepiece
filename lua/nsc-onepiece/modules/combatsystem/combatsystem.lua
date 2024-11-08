-- The purpose of this module called "CombatSystem" is to include and store most of the utils that cant be really categorized into separate classes

NSCOP.IncludeShared("shared/sh_init.lua")
NSCOP.IncludeServer("server/sv_init.lua")
NSCOP.IncludeClient("client/cl_init.lua")

-- Include the combat swep
NSCOP.IncludeShared("nsc_fightingstance/shared.lua")

NSCOP.PrintFileLoaded()
