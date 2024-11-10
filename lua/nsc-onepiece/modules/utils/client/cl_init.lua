---@class NSCOP.Utils
local Utils = NSCOP.Utils or {}

Utils.DefaultScreenW = 1920
Utils.DefaultScreenH = 1080

Utils.ScreenW = ScrW()
Utils.ScreenH = ScrH()

---Scales a value based on users screen width
---<br>REALM: CLIENT
---@param value number The value to scale
---@param scaleForHigherRes boolean | nil Should it also scale for resolutions higher than FullHD
---@nodiscard
---@return number The scaled value
function Utils.ScreenScaleW(value, scaleForHigherRes)
	---@type boolean
	local isHigherRes = Utils.ScreenW > Utils.DefaultScreenW
	return (! isHigherRes or scaleForHigherRes) and value * Utils.ScreenW / Utils.DefaultScreenW or value
end

---Scales a value based on users screen height
---<br>REALM: CLIENT
---@param value number The value to scale
---@param scaleForHigherRes boolean Should it also scale for resolutions higher than FullHD
---@nodiscard
---@return number The scaled value
function Utils.ScreenScaleH(value, scaleForHigherRes)
	---@type boolean
	local isHigherRes = Utils.ScreenH > Utils.DefaultScreenH
	return (! isHigherRes or scaleForHigherRes) and value * Utils.ScreenH / Utils.DefaultScreenH or value
end

Utils.AddHook("OnScreenSizeChanged", "NSCOP.Utils.SyncScreenSize", function(oldWidth, oldHeight, newWidth, newHeight)
	Utils.ScreenW = newWidth
	Utils.ScreenH = newHeight

	NSCOP.PrintDebug("Screen width changed to", newWidth)
	NSCOP.PrintDebug("Screen height changed to", newHeight)
end)
