---@class FightingStance: SWEP
---@
---@field GetCombatStance fun(): boolean Gets the current combat stance
---@field SetCombatStance fun(self: FightingStance, newValue: boolean) Sets the combat stance
---@
---@field GetCurrentCombo fun(): integer Gets the current combo
---@field SetCurrentCombo fun(self: FightingStance, newValue: integer) Sets the current combo
---@
---@field GetNextDodge fun(): number Gets the time when the player can dodge again
---@field SetNextDodge fun(self: FightingStance, newValue: number) Sets the time when the player can dodge again (Should be used with CurTime)

---@class FightingStance: SWEP
FightingStance = {}

FightingStance.PrintName = "Fighting Stance"
FightingStance.Author = "NSC One Piece RP"
FightingStance.Contact = "Your Contact"
FightingStance.Purpose = "Combat"
FightingStance.Instructions = "Left click to attack, right click to block"
FightingStance.Category = "NSC One Piece RP"

FightingStance.Spawnable = true
FightingStance.AdminOnly = false

FightingStance.MaxCombo = 5

FightingStance.PrimaryCD = 0.1
FightingStance.SecondaryCD = 0.1

FightingStance.CanDodge = true
FightingStance.DodgeForce = 6000
FightingStance.DodgeCD = 0.25

function FightingStance:SetupDataTables()
	NSCOP.Utils.NetworkVar(self, "Bool", "CombatStance")
	NSCOP.Utils.NetworkVar(self, "Int", "CurrentCombo")
	NSCOP.Utils.NetworkVar(self, "Float", "NextDodge")
end

function FightingStance:Initialize()
	self:InitializeCooldowns()
	self:SetCombatStance(true)
end

function FightingStance:Deploy()
end

function FightingStance:Holster()
	self:SetCombatStance(false)
	self:SetCurrentCombo(0)
end

function FightingStance:PrimaryAttack()
	if not self:GetCombatStance() then return end

	NSCOP.Print("Primary Attack")

	self:IncreaseCombo()
	self:SetNextPrimaryFire(CurTime() + self.PrimaryCD)
end

function FightingStance:SecondaryAttack()
	if not self:GetCombatStance() then return end

	NSCOP.Print("Secondary Attack")

	self:SetNextSecondaryFire(CurTime() + self.SecondaryCD)
end

function FightingStance:Reload()
	if not self:GetCombatStance() then return end

	self:Dodge()
end

function FightingStance:Think()

end

function FightingStance:Dodge()
	if CurTime() < self:GetNextDodge() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if not owner:IsPlayer() then return end
	---@cast owner Player

	local moveDirection = owner:GetMoveDirection(true)

	owner:SetVelocity(moveDirection * self.DodgeForce)
	NSCOP.Print("Player dodged", owner)

	self:SetNextDodge(CurTime() + self.DodgeCD)
end

--#region Helpers

---Increases the current combo until it reaches the max combo, then resets it
function FightingStance:IncreaseCombo()
	local currentCombo = self:GetCurrentCombo()

	if currentCombo >= self.MaxCombo then
		self:SetCurrentCombo(0)
	else
		self:SetCurrentCombo(currentCombo + 1)
	end
end

---Resets and starts all cooldowns. This is called upon Initialization, so that players can't spam actions right after gaining the swep
function FightingStance:InitializeCooldowns()
	local curTime = CurTime()

	self:SetNextPrimaryFire(curTime + self.PrimaryCD)
	self:SetNextSecondaryFire(curTime + self.SecondaryCD)
	self:SetNextDodge(curTime + self.DodgeCD)
end

--#endregion

-- Before we add the weapon, we load the client and server files for them to change the properties
NSCOP.IncludeServer("sv_init.lua")
NSCOP.IncludeClient("cl_init.lua")

weapons.Register(FightingStance, "nsc_fightingstance")
