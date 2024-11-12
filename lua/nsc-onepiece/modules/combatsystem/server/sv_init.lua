---@class Player
local MPlayer = FindMetaTable("Player")

---@enum NSCOP.DamageType
NSCOP.DamageType = {
	Physical = 1,
	Cut = 2,
	IgnoreBlock = 4, -- Ignores the player's block
	IgnoreArmor = 8, -- Does full damage to the player's health
	IgnoreIFrames = 16, -- Ignores players invincibility frames
}

---Initializes the player's values
function MPlayer:NSCOP_InitValues()
	self.NSCOP = self.NSCOP or {}
	self.NSCOP.IFramesTime = 0
end

---Resets the player's values to the default ones
---<br>REALM: Server
function MPlayer:NSCOP_ResetValues()
	if not self:IsValid() then return end

	-- Base ones
	self:SetHealth(100)
	self:SetMaxHealth(100)
	self:SetArmor(0)
	self:SetWalkSpeed(200)
	self:SetRunSpeed(400)
	self:SetJumpPower(200)

	-- Custom ones
	self:NSCOP_LoadAppearance()
	self:NSCOP_InitValues()
end

---Returns the player's invincibility frames
---<br>REALM: Server
---@return number
function MPlayer:NSCOP_GetIFrames()
	return self.NSCOP.IFramesTime - FrameNumber()
end

---Returns if the player has invincibility frames
---<br>REALM: Server
---@return boolean
function MPlayer:NSCOP_HasIFrames()
	return self:NSCOP_GetIFrames() > 0
end

---Sets the player's invincibility frames
---<br>REALM: Server
---@param framesAmount number
function MPlayer:NSCOP_SetIFrames(framesAmount)
	self.NSCOP.IFramesTime = FrameNumber() + framesAmount
end

NSCOP.Utils.AddHook("PlayerSpawn", "NSCOP.CombatSystem.PlayerSpawn", function(ply)
	ply:NSCOP_ResetValues()
end)

NSCOP.Utils.AddHook("EntityTakeDamage", "NSCOP.CombatSystem.EntityTakeDamage", function(target, dmgInfo)
	print(dmgInfo:GetDamageCustom())
	if not target:IsPlayer() then return end
	---@cast target Player

	local damage = dmgInfo:GetDamage()
	local damageType = dmgInfo:GetDamageType()
	local customDamageType = dmgInfo:GetDamageCustom()

	if target:NSCOP_HasIFrames() and ! NSCOP.Utils.FlagHas(customDamageType, NSCOP.DamageType.IgnoreIFrames) then
		dmgInfo:SetDamage(0)
		return
	end

	if NSCOP.Utils.FlagHas(customDamageType, NSCOP.DamageType.IgnoreBlock) then
		-- TODO:
	end

	if bit.band(customDamageType, NSCOP.DamageType.IgnoreArmor) == 0 then
		-- TODO:
	end
end)
