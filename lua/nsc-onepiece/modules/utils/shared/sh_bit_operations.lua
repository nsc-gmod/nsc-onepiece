---@class NSCOP.Utils
local Utils = NSCOP.Utils or {}

---Checks if the flag has the specified value
---<br>REALM: SHARED
---@param flag integer The flag to check
---@param value integer The value to check for
---@return boolean hasValue If the flag has the value
function Utils.FlagHas(flag, value)
	return bit.band(flag, value) == value
end

---Adds a value to the flag
---<br>REALM: SHARED
---@param flag integer The flag to add the value to
---@param value integer The value to add
---@return integer newFlag The new flag with the value added
function Utils.FlagAdd(flag, value)
	return bit.bor(flag, value)
end

---Removes a value from the flag
---<br>REALM: SHARED
---@param flag integer The flag to remove the value from
---@param value integer The value to remove
---@return integer newFlag The new flag with the value removed
function Utils.FlagRemove(flag, value)
	return bit.band(flag, bit.bnot(value))
end
