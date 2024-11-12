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
---@overload fun(eventName: "PlayerButtonDown", identifier: string, func: fun(ply: Player, button: NSCOP.ButtonValue))
---@overload fun(eventName: "PlayerButtonUp", identifier: string, func: fun(ply: Player, button: NSCOP.ButtonValue))
---@overload fun(eventName: "PlayerCanHearPlayersVoice", identifier: string, func: fun(listener: Player, talker: Player): boolean)
---@overload fun(eventName: "PlayerCanSeePlayersChat", identifier: string, func: fun(text: string, teamOnly: boolean, listener: Player, speaker: Player): boolean)
---@overload fun(eventName: "PlayerFootstep", identifier: string, func: fun(ply: Player, pos: Vector, foot: number, sound: string, volume: number, filter: CRecipientFilter): boolean)
---@overload fun(eventName: "PlayerDeathSound", identifier: string, func: fun(ply: Player): string)
---@overload fun(eventName: "PlayerHurt", identifier: string, func: fun(ply: Player, attacker: Entity, healthRemaining: number, damageTaken: number))
---@overload fun(eventName: "PlayerSpawn", identifier: string, func: fun(ply: Player))
---@overload fun(eventName: "PlayerDisconnected", identifier: string, func: fun(ply: Player))
---@overload fun(eventName: "HUDShouldDraw", identifier: string, func: fun(element: NSCOP.HUDBaseElement): boolean)
---@overload fun(eventName: "OnScreenSizeChanged", identifier: string, func: fun(oldWidth: number, oldHeight: number, newWidth: number, newHeight: number))
---@overload fun(eventName: "Tick", identifier: string, func: fun())
---@overload fun(eventName: "ClientSignOnStateChanged", identifier: string, func: fun(userId: number, oldState: number, newState: number))
---@overload fun(eventName: "NSCOP.PlayerLoaded", identifier: string, func: fun(ply: Player))
---@overload fun(eventName: "NSCOP.ButtonStateChanged", identifier: string, func: fun(buttonData: NSCOP.ButtonData, lastState: NSCOP.ButtonState, newState: NSCOP.ButtonState))
function Utils.AddHook(eventName, identifier, func)
	hook.Add(eventName, identifier, func)
end

---Type safe way to run a hook
---<br>REALM: SHARED
---@param eventName string The name of the event to run
---@vararg any The arguments to pass to the hook. Maximum of 6 arguments
---@overload fun(eventName: "NSCOP.PlayerLoaded", ply: Player)
---@overload fun(eventName: "NSCOP.ButtonStateChanged", identifier: string, func: fun(buttonData: NSCOP.ButtonData, lastState: NSCOP.ButtonState, newState: NSCOP.ButtonState))
function Utils.RunHook(eventName, ...)
	hook.Run(eventName, ...)
end

-- TODO: Not sure if this should be in config module, or here
---Returns the value of the config, or the default value if the config is not set
---<br>REALM: SHARED
---@generic T
---@param key NSCOP.ConfigKey The key to check in the config
---@param defaultValue T The default value to return if config value does not exist or config is not loaded
---@return T
function Utils.GetConfigValue(key, defaultValue)
	if not NSCOP.Config then return defaultValue end

	return NSCOP.Config[key] or defaultValue
end

--TODO: Refactor this in the future
---Returns players for the console command autocomplete
---<br>REALM: SHARED
---@param commandName string The name of the command
---@param cmd string The command string
---@param argStr string The current argument string
---@param args table The arguments table
---@return string[] playersAutocomplete
function Utils.GetPlayersAutocomplete(commandName, cmd, argStr, args)
	local playersAutocomplete = {}

	for _, currentPly in player.Iterator() do
		if not currentPly:GetName():lower():StartsWith(argStr:Trim():lower()) then continue end

		---@cast currentPly Player
		table.insert(playersAutocomplete, commandName .. " " .. currentPly:GetName())
	end

	return playersAutocomplete
end

--#region MEntity extensions
---@class Entity
local MEntity = FindMetaTable("Entity")

---Returns the direction the entity is moving in based on its velocity
---<br>REALM: SHARED
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

--Loads the character data for the player entity
---<br>REALM: SHARED
function MPlayer:NSCOP_LoadAppearance()
	if not self:IsValid() then return end

	if not self.NSCOP then
		NSCOP.PrintDebug("Player has no NSCOP table")
		return
	end

	if not self.NSCOP.PlayerData then
		NSCOP.PrintDebug("Player has no PlayerData table")
		return
	end

	local characterData = self.NSCOP.PlayerData.CharacterData

	-- self:SetModel("OUR CUSTOM MODEL")
	-- self:SetSkin(characterData.SkinColor)
	-- self:SetBodygroup(NSCOP.BodyGroup.Hair, characterData.HairType)
	-- self:SetBodygroup(NSCOP.BodyGroup.Nose, characterData.NoseType)
	-- self:SetBodygroup(NSCOP.BodyGroup.Eye, characterData.EyeType)
	-- self:SetBodygroup(NSCOP.BodyGroup.Eyebrow, characterData.EyebrowType)
	-- self:SetBodygroup(NSCOP.BodyGroup.Mouth, characterData.MouthType)
	-- self:SetBodygroup(NSCOP.BodyGroup.Outfit, characterData.Outfit)
	-- self:SetPlayerColor(Vector(characterData.HairColor / 255, characterData.EyeColor / 255, 0))
	self:SetModelScale(characterData.Size, 0.000001) -- 0.000001 to avoid a bug with SetModelScale

	NSCOP.PrintDebug("Loaded character appearance for", self:GetName())
end

--#endregion

--#region MWeapon extensions
---@class Weapon
local MWeapon = FindMetaTable("Weapon")

---Returns whether the weapon is a combat swep
---<br>REALM: SHARED
---@nodiscard
---@return boolean isCombatSWEP
function MWeapon:NSCOP_IsCombatSWEP()
	return self:GetClass() == "nsc_fightingstance"
end

--#endregion
