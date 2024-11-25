---@alias NSCOP.Font "NSCOP_Main" | "NSCOP_Main_Big" | "NSCOP_Main_Small" | "NSCOP_Main_VerySmall"

NSCOP.Utils.AddHook("OnScreenSizeChanged", "NSCOP.Utils.SyncScreenSize", function(oldWidth, oldHeight, newWidth, newHeight)
	include()
end)


local isLinux = system.IsLinux()

surface.CreateFont("NSCOP_Main", {
	font = isLinux and "fantaisie_artistique.ttf" or "FantaisieArtistique",
	extended = false,
	size = NSCOP.Utils.ScreenScaleW(43),
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
	size = NSCOP.Utils.ScreenScaleW(58),
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
	size = NSCOP.Utils.ScreenScaleW(29),
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

surface.CreateFont("NSCOP_Main_Smaller", {
	font = isLinux and "fantaisie_artistique.ttf" or "FantaisieArtistique",
	extended = false,
	size = NSCOP.Utils.ScreenScaleW(22),
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
	size = NSCOP.Utils.ScreenScaleW(18),
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

surface.CreateFont("NSCOP_Main_VerySmallSmaller", {
	font = isLinux and "fantaisie_artistique.ttf" or "FantaisieArtistique",
	extended = false,
	size = NSCOP.Utils.ScreenScaleW(16),
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
