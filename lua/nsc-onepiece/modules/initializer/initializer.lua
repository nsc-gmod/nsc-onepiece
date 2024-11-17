-- This file is going to be included by the autorun, and then it will include all of the module. This is probably how it's going to work for every module
-- The purpose of this module called "Initizalizer" is to create all of the meta shit used by other modules and code

if SERVER then
	AddCSLuaFile("shared/sh_init.lua")
end
include("shared/sh_init.lua")

NSCOP.IncludeModule(NSCOP.Modules.Utils)
NSCOP.IncludeModule(NSCOP.Modules.ConfigManager)
NSCOP.IncludeModule(NSCOP.Modules.DataManager)
NSCOP.IncludeModule(NSCOP.Modules.CombatSystem)

NSCOP.PrintFileLoaded()


-- TODO: Dirty, move this away once we know where :)
if CLIENT then
	---@alias NSCOP.Font "NSCOP_Main" | "NSCOP_Main_Small"

	surface.CreateFont("NSCOP_Main", {
		font = system.IsLinux() and "fantaisie_artistique.ttf" or "FantaisieArtistique",
		extended = false,
		size = ScreenScale(12),
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})

	surface.CreateFont("NSCOP_Main_Small", {
		font = system.IsLinux() and "fantaisie_artistique.ttf" or "FantaisieArtistique",
		extended = false,
		size = ScreenScale(8),
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
end
