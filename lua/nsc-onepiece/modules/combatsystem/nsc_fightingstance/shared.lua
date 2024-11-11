---@class NSCOP.FightingStance: SWEP
---@
---@field GetCombatStance fun(): boolean Gets the current combat stance
---@field SetCombatStance fun(self: NSCOP.FightingStance, newValue: boolean) Sets the combat stance
---@
---@field GetCombatStyle fun(): boolean Gets the current combat style
---@field SetCombatStyle fun(self: NSCOP.FightingStance, newValue: boolean) Sets the combat style. Probably shouldnt be used during combat
---@
---@field GetCurrentCombo fun(): integer Gets the current combo
---@field SetCurrentCombo fun(self: NSCOP.FightingStance, newValue: integer) Sets the current combo
---@
---@field GetNextDodge fun(): number Gets the time when the player can dodge again
---@field SetNextDodge fun(self: NSCOP.FightingStance, newValue: number) Sets the time when the player can dodge again (Should be used with CurTime)
---@
---@field GetSelectedSkill fun(): integer Gets the selected skill, -1 means no skill selected
---@field SetSelectedSkill fun(self: NSCOP.FightingStance, newValue: integer) Sets the selected skill, -1 means no skill selected

---@class NSCOP.FightingStance: SWEP
NSCOP.FightingStance = {}

NSCOP.FightingStance.PrintName = "Fighting Stance"
NSCOP.FightingStance.Author = "NSC One Piece RP"
NSCOP.FightingStance.Contact = "Your Contact"
NSCOP.FightingStance.Purpose = "Combat"
NSCOP.FightingStance.Instructions = "Left click to attack, right click to block"
NSCOP.FightingStance.Category = "NSC One Piece RP"

NSCOP.FightingStance.SkillInstances = NSCOP.FightingStance.SkillInstances or {}

NSCOP.FightingStance.Spawnable = true
NSCOP.FightingStance.AdminOnly = false

NSCOP.FightingStance.MaxCombo = 5

NSCOP.FightingStance.PrimaryCD = 0.1
NSCOP.FightingStance.SecondaryCD = 0.1

NSCOP.FightingStance.CanDodge = true
NSCOP.FightingStance.DodgeForce = 600
NSCOP.FightingStance.DodgeCD = 0.25

function NSCOP.FightingStance:SetupDataTables()
	NSCOP.Utils.NetworkVar(self, "Bool", "CombatStance")
	NSCOP.Utils.NetworkVar(self, "Int", "CombatStyle")
	NSCOP.Utils.NetworkVar(self, "Int", "CurrentCombo")
	NSCOP.Utils.NetworkVar(self, "Int", "SelectedSkill")
	NSCOP.Utils.NetworkVar(self, "Float", "NextDodge")
end

function NSCOP.FightingStance:CreateSkillInstance(skillId)
	local skill = NSCOP.Skill.GetSkillByID(skillId)

	if ! skill then
		NSCOP.Print("Invalid Skill ID! id " .. skillId)
		return
	end

	local newInstance = skill:CreateInstance()
	newInstance:AssignWeapon(self)

	self.SkillInstances[newInstance.SkillID] = newInstance
end

function NSCOP.FightingStance:GetSkillInstance(skillId)
	return self.SkillInstances[skillId]
end

function NSCOP.FightingStance:Initialize()
	self:ResetCooldowns()
	self:ResetVars()
	self:SetCombatStance(true)
end

function NSCOP.FightingStance:Deploy()

end

function NSCOP.FightingStance:Holster()
	self:ResetVars()
	return true
end

function NSCOP.FightingStance:PrimaryAttack()
	if not self:GetCombatStance() then return end

	NSCOP.Print("Primary Attack")
	local testInstance = self:GetSkillInstance(1000)
	testInstance:DoCrazyShit()

	self:IncreaseCombo()
	self:SetNextPrimaryFire(CurTime() + self.PrimaryCD)
end

function NSCOP.FightingStance:SecondaryAttack()
	if not self:GetCombatStance() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if not owner:IsPlayer() then return end
	---@cast owner Player

	if self:GetSelectedSkill() == -1 then
		if CLIENT then
			owner:ChatPrint("No skill selected!")
		end
		NSCOP.PrintDebug("No skill selected!")
		return
	end

	NSCOP.Print("Secondary Attack")

	self:SetNextSecondaryFire(CurTime() + self.SecondaryCD)
end

function NSCOP.FightingStance:Reload()
	self:SetCombatStance(not self:GetCombatStance())
end

function NSCOP.FightingStance:Think()
	local owner = self:GetOwner()

	if ! self:GetSkillInstance(1000) then
		self:CreateSkillInstance(1000)
	end
end

-- TODO: Once skill system is implemented, this should be moved to a separate module, where it would have its own skill specification
---@param aerial? boolean If the dodge is aerial, if so, then the player will dodge upwards
function NSCOP.FightingStance:Dodge(aerial)
	if CurTime() < self:GetNextDodge() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if not owner:IsPlayer() then return end
	---@cast owner Player

	local moveDirection = owner:NSCOP_GetMoveDirection(true)

	if aerial then
		moveDirection = vector_up
	end

	-- Fixes an issue where there is a velocity hickup when the player is in air
	if (moveDirection == vector_origin) then return end

	local finalForce = self.DodgeForce

	if owner:OnGround() and not aerial then
		finalForce = finalForce * 3
	end

	-- I'm using SetLocalVelocity instead of SetVelocity, because SetVelocity is causing prediction errors
	-- FIXME: For some reason, sometimes the player dodges a bit to the side, even though the moveDirection is correct
	owner:SetLocalVelocity(owner:GetVelocity() + moveDirection * finalForce)
	NSCOP.Print("Player dodged", owner)

	self:SetNextDodge(CurTime() + self.DodgeCD)
end

--#region Helpers

---Increases the current combo until it reaches the max combo, then resets it
function NSCOP.FightingStance:IncreaseCombo()
	local currentCombo = self:GetCurrentCombo()

	if currentCombo >= self.MaxCombo then
		self:SetCurrentCombo(0)
	else
		self:SetCurrentCombo(currentCombo + 1)
	end
end

---Resets all variables to their default values
function NSCOP.FightingStance:ResetVars()
	self:SetCombatStance(false)
	self:SetCurrentCombo(0)

	self:SetSelectedSkill(-1)
end

---Resets and starts all cooldowns. This is called upon Initialization, so that players can't spam actions right after gaining the swep
function NSCOP.FightingStance:ResetCooldowns()
	local curTime = CurTime()

	self:SetNextPrimaryFire(curTime + self.PrimaryCD)
	self:SetNextSecondaryFire(curTime + self.SecondaryCD)
	self:SetNextDodge(curTime + self.DodgeCD)
end

--#endregion

-- Before we add the weapon, we load the client and server files for them to change the properties
NSCOP.IncludeServer("sv_init.lua")
NSCOP.IncludeClient("cl_init.lua")

weapons.Register(NSCOP.FightingStance, "nsc_fightingstance")
