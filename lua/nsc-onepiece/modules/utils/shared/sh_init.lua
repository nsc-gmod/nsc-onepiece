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

---Type safe way to add a hook
---<br>REALM: SHARED
---@param eventName string The name of the event to hook
---@param identifier string | Entity  A unique identifier for the hook
---@param func function The function to call when the event is triggered
---@overload fun(eventName: "PlayerInitialSpawn", identifier: string, func: fun(ply: Player))
---@overload fun(eventName: "PlayerDisconnected", identifier: string, func: fun(ply: Player))
---@overload fun(eventName: "PlayerSay", identifier: string, func: fun(ply: Player, text: string, teamOnly: boolean): string)
---@overload fun(eventName: "PlayerDeath", identifier: string, func: fun(victim: Player, inflictor: Entity, attacker: Player))
---@overload fun(eventName: "EntityTakeDamage", identifier: string, func: fun(target: Entity, dmginfo: CTakeDamageInfo))
---@overload fun(eventName: "KeyPress", identifier: string, func: fun(ply: Player, key: IN))
---@overload fun(eventName: "KeyRelease", identifier: string, func: fun(ply: Player, key: IN))
---@overload fun(eventName: "PlayerButtonDown", identifier: string, func: fun(ply: Player, button: BUTTON_CODE | KEY | MOUSE | JOYSTICK))
---@overload fun(eventName: "PlayerButtonUp", identifier: string, func: fun(ply: Player, button: BUTTON_CODE | KEY | MOUSE | JOYSTICK))
---@overload fun(eventName: "PlayerCanHearPlayersVoice", identifier: string, func: fun(listener: Player, talker: Player): boolean)
---@overload fun(eventName: "PlayerCanSeePlayersChat", identifier: string, func: fun(text: string, teamOnly: boolean, listener: Player, speaker: Player): boolean)
---@overload fun(eventName: "PlayerFootstep", identifier: string, func: fun(ply: Player, pos: Vector, foot: number, sound: string, volume: number, filter: CRecipientFilter): boolean)
---@overload fun(eventName: "PlayerDeathSound", identifier: string, func: fun(ply: Player): string)
---@overload fun(eventName: "PlayerHurt", identifier: string, func: fun(ply: Player, attacker: Entity, healthRemaining: number, damageTaken: number))
---@overload fun(eventName: "PlayerSpawn", identifier: string, func: fun(ply: Player))
---@overload fun(eventName: "PlayerDisconnected", identifier: string, func: fun(ply: Player))
---@overload fun(eventName: "HUDShouldDraw", identifier: string, func: fun(element: NSCOP.HUDBaseElement): boolean)
---@overload fun(eventName: "OnScreenSizeChanged", identifier: string, func: fun(oldWidth: number, oldHeight: number, newWidth: number, newHeight: number))
function Utils.AddHook(eventName, identifier, func)
	hook.Add(eventName, identifier, func)
end

--#region MEntity extensions
-- TODO: This should be moved to a more appropriate place, for example a module called MetaExtensions
---@class Entity
local MEntity = FindMetaTable("Entity")

---Returns the direction the entity is moving in based on its velocity
---@param ignoreZAxis? boolean If true, the Z axis (up) will be ignored
---@nodiscard
---@return Vector direction The normalized direction vector the entity is moving in
function MEntity:NSCOP_GetVelocityDirection(ignoreZAxis)
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
function MPlayer:NSCOP_GetMoveDirection(ignoreZAxis)
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

--#region MWeapon extensions
---@class Weapon
local MWeapon = FindMetaTable("Weapon")

---Returns whether the weapon is a combat swep
---@nodiscard
---@return boolean isCombatSWEP
function MWeapon:NSCOP_IsCombatSWEP()
	return self:GetClass() == "nsc_fightingstance"
end

--#endregion
