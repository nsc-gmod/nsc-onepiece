---@class FightingStance: SWEP
---@field GetCombatStance fun(): boolean Gets the current combat stance
---@field SetCombatStance fun(self: FightingStance, newValue: boolean) Sets the combat stance
---@field GetCurrentCombo fun(): integer Gets the current combo
---@field SetCurrentCombo fun(self: FightingStance, newValue: integer) Sets the current combo

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

function FightingStance:SetupDataTables()
	NSCOP.Utils.NetworkVar(self, "Bool", "CombatStance")
	NSCOP.Utils.NetworkVar(self, "Int", "CurrentCombo")
end

function FightingStance:Initialize()
end

function FightingStance:Deploy()

end

function FightingStance:Holster()
	self:SetCombatStance(false)
	self:SetCurrentCombo(0)
end

function FightingStance:PrimaryAttack()
	if not self:GetCombatStance() then return end

	self:IncreaseCombo()
end

function FightingStance:IncreaseCombo()
	local currentCombo = self:GetCurrentCombo()

	if currentCombo >= self.MaxCombo then
		self:SetCurrentCombo(0)
	else
		self:SetCurrentCombo(currentCombo + 1)
	end
end

-- Before we add the weapon, we load the client and server files for them to change the properties
NSCOP.IncludeServer("sv_init.lua")
NSCOP.IncludeClient("cl_init.lua")

weapons.Register(FightingStance, "nsc_fightingstance")
