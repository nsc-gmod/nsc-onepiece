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

--#region MEntity extensions
-- TODO: This should be moved to a more appropriate place, for example a module called MetaExtensions
---@class Entity
local MEntity = FindMetaTable("Entity")

---Returns the direction the entity is moving in based on its velocity
---@param ignoreZAxis? boolean If true, the Z axis (up) will be ignored
---@nodiscard
---@return Vector direction The normalized direction vector the entity is moving in
function MEntity:GetVelocityDirection(ignoreZAxis)
	local velocity = self:GetVelocity()
	local direction = velocity:GetNormalized()

	if ignoreZAxis then
		direction.z = 0
	end

	return direction
end

--#endregion

--#region MPlayer extensions
---@class Player
local MPlayer = FindMetaTable("Player")

---Returns the direction the player is moving in based on held movement keys
---<br>REALM: SHARED
---@param ignoreZAxis? boolean If true, the Z axis (up) will be ignored
---@nodiscard
---@return Vector direction The normalized direction vector the player is moving in
function MPlayer:GetMoveDirection(ignoreZAxis)
	local eyeAngles = self:EyeAngles()

	local forward = eyeAngles:Forward()
	local right = eyeAngles:Right()

	local moveDirection = vector_origin

	if self:KeyDown(IN_FORWARD) then
		moveDirection = moveDirection + forward
	end

	if self:KeyDown(IN_BACK) then
		moveDirection = moveDirection - forward
	end

	if self:KeyDown(IN_MOVELEFT) then
		moveDirection = moveDirection - right
	end

	if self:KeyDown(IN_MOVERIGHT) then
		moveDirection = moveDirection + right
	end

	if ignoreZAxis then
		moveDirection.z = 0
	end

	return moveDirection:GetNormalized()
end

--#endregion
