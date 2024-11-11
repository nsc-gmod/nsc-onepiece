-- The purpose of this module called "CombatSystem" is to include and store most of the utils that cant be really categorized into separate classes

NSCOP.IncludeShared("shared/sh_init.lua")
NSCOP.IncludeServer("server/sv_init.lua")
NSCOP.IncludeClient("client/cl_init.lua")

-- Skill System
NSCOP.IncludeShared("skillsystem/sh_skillsystem.lua")
NSCOP.IncludeServer("skillsystem/sv_skillsystem.lua")
NSCOP.IncludeClient("skillsystem/cl_skillsystem.lua")

-- Fighting Stance
NSCOP.IncludeShared("nsc_fightingstance/shared.lua")

-- The skills
NSCOP.LoadSkill("skills/test")

NSCOP.PrintFileLoaded()
