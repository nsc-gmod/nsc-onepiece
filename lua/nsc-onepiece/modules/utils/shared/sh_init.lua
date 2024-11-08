---The purpose of this module called "Utils" is to include and store most of the utils that cant be really categorized
---@class NSCOP.Utils
NSCOP.Utils = NSCOP.Utils or {}

---@class NSCOP.Utils
local Utils = NSCOP.Utils

---@alias NSCOP.NetworkVarType "Int"|"Float"|"Bool"|"String"|"Entity"|"Vector"|"Angle"

---Type safe way to add a network var to an entity
---<br>REALM: SHARED
---@param entity Entity Entity to set the network var on
---@param type NSCOP.NetworkVarType Type of the network var
---@param name string A unique name for the network var
function Utils.NetworkVar(entity, type, name)
	-- We need to disable the diagnostic, because there is no other way to get around this, this should be fixed in the gmod type definitions
	---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
	entity:NetworkVar(type, name)
end
