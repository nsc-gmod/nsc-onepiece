---@class NSCOP.Utils
local Utils = NSCOP.Utils or {}

Utils.DefaultScreenW = 1920
Utils.DefaultScreenH = 1080

Utils.ScreenW = ScrW()
Utils.ScreenH = ScrH()

---Scales a value based on users screen width
---<br>REALM: CLIENT
---@param value number The value to scale
---@nodiscard
---@return number The scaled value
function Utils.ScreenScaleW(value)
	return value * Utils.ScreenW / Utils.DefaultScreenW
end

---Scales a value based on users screen height
---<br>REALM: CLIENT
---@param value number The value to scale
---@nodiscard
---@return number The scaled value
function Utils.ScreenScaleH(value)
	return value * Utils.ScreenH / Utils.DefaultScreenH
end

Utils.AddHook("OnScreenSizeChanged", "NSCOP.Utils.SyncScreenSize", function(oldWidth, oldHeight, newWidth, newHeight)
	Utils.ScreenW = newWidth
	Utils.ScreenH = newHeight

	NSCOP.PrintDebug("Screen width change to", newWidth)
	NSCOP.PrintDebug("Screen height change to", newHeight)
end)
