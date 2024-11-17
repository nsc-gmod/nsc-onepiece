---@alias NSCOP.Font "NSCOP_Main" | "NSCOP_Main_Big" | "NSCOP_Main_Small" | "NSCOP_Main_VerySmall"

local isLinux = system.IsLinux()

surface.CreateFont("NSCOP_Main", {
	font = isLinux and "fantaisie_artistique.ttf" or "FantaisieArtistique",
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

surface.CreateFont("NSCOP_Main_Big", {
	font = isLinux and "fantaisie_artistique.ttf" or "FantaisieArtistique",
	extended = false,
	size = ScreenScale(16),
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
	font = isLinux and "fantaisie_artistique.ttf" or "FantaisieArtistique",
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

surface.CreateFont("NSCOP_Main_VerySmall", {
	font = isLinux and "fantaisie_artistique.ttf" or "FantaisieArtistique",
	extended = false,
	size = ScreenScale(4),
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
