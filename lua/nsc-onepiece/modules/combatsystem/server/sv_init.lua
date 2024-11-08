---@class NSCOP.Utils
local Utils = NSCOP.Utils
local net = net


---@param onClient boolean True - Client, False - Server
---@param module NSCOP.ModuleType The module
---@param networkString string The net name
---@return string WrappedNet
function NSCOP.WrapNet(onClient, module, networkString)
	---@type string WrappedNet
	local wrappedNet = "ESC." .. (onClient and "Cl" or "Sv") .. "." .. module .. "." .. networkString
	table.insert(NSCOP.NetworkMessages, wrappedNet)
	return wrappedNet
end

local msg = NSCOP.WrapNet(true, NSCOP.Modules.Utils, "StupidShit")
util.AddNetworkString(msg)
print(msg)
