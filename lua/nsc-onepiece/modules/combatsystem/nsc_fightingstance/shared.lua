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
---@
---@field GetSkillSlot1 fun(): NSCOP.SkillId Gets the skill in the slot
---@field SetSkillSlot1 fun(self: NSCOP.FightingStance, newValue: NSCOP.SkillId) Sets the skill to the slot
---@
---@field GetSkillSlot2 fun(): NSCOP.SkillId Gets the skill in the slot
---@field SetSkillSlot2 fun(self: NSCOP.FightingStance, newValue: NSCOP.SkillId) Sets the skill to the slot
---@
---@field GetSkillSlot3 fun(): NSCOP.SkillId Gets the skill in the slot
---@field SetSkillSlot3 fun(self: NSCOP.FightingStance, newValue: NSCOP.SkillId) Sets the skill to the slot
---@
---@field GetSkillSlot4 fun(): NSCOP.SkillId Gets the skill in the slot
---@field SetSkillSlot4 fun(self: NSCOP.FightingStance, newValue: NSCOP.SkillId) Sets the skill to the slot
---@
---@field GetSkillSlot5 fun(): NSCOP.SkillId Gets the skill in the slot
---@field SetSkillSlot5 fun(self: NSCOP.FightingStance, newValue: NSCOP.SkillId) Sets the skill to the slot
---@
---@field GetSkillSlot6 fun(): NSCOP.SkillId Gets the skill in the slot
---@field SetSkillSlot6 fun(self: NSCOP.FightingStance, newValue: NSCOP.SkillId) Sets the skill to the slot

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

NSCOP.FightingStance.ViewModel = ""
NSCOP.FightingStance.WorldModel = ""

NSCOP.FightingStance.Primary = {
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false,
}

NSCOP.FightingStance.Secondary = {
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = false,
}

NSCOP.FightingStance.MaxCombo = 5

NSCOP.FightingStance.PrimaryCD = 0.1
NSCOP.FightingStance.SecondaryCD = 0.1

NSCOP.FightingStance.CanDodge = true
NSCOP.FightingStance.DodgeForce = 100
NSCOP.FightingStance.DodgeCD = 0.25

NSCOP.FightingStance.IsMidDodge = false

function NSCOP.FightingStance:SetupDataTables()
	NSCOP.Utils.NetworkVar(self, "Bool", "CombatStance")
	NSCOP.Utils.NetworkVar(self, "Int", "CombatStyle")
	NSCOP.Utils.NetworkVar(self, "Int", "CurrentCombo")
	NSCOP.Utils.NetworkVar(self, "Int", "SelectedSkill")

	NSCOP.Utils.NetworkVar(self, "Int", "SkillSlot1")
	NSCOP.Utils.NetworkVar(self, "Int", "SkillSlot2")
	NSCOP.Utils.NetworkVar(self, "Int", "SkillSlot3")
	NSCOP.Utils.NetworkVar(self, "Int", "SkillSlot4")
	NSCOP.Utils.NetworkVar(self, "Int", "SkillSlot5")
	NSCOP.Utils.NetworkVar(self, "Int", "SkillSlot6")

	NSCOP.Utils.NetworkVar(self, "Float", "NextDodge")
end

function NSCOP.FightingStance:Initialize()
	self:ResetCooldowns()
	self:ResetVars()
	self:SetCombatStance(true)

	self:SetHoldType("normal")

	if SERVER then
		timer.Simple(0, function()
			if not self:IsValid() then return end

			local owner = self:GetOwner()
			if not owner:IsValid() then return end
			if not owner:IsPlayer() then return end
			---@cast owner Player

			owner:NSCOP_InitValues()
		end)
	end
end

function NSCOP.FightingStance:Deploy()

end

function NSCOP.FightingStance:Holster()
	self:ResetVars()
	return true
end

function NSCOP.FightingStance:InitialSkillSetup()
	self.InitialSkillSetupDone = true

	self:SetSkillIntoSlot(1, 1000)
	self:SetSkillIntoSlot(2, 1000)
	self:SetSkillIntoSlot(3, 1000)
	self:SetSkillIntoSlot(4, 1000)
	self:SetSkillIntoSlot(5, 1000)
	self:SetSkillIntoSlot(6, 1000)

	---@type NSCOP.SkillInstance
	self:CreateSkillInstance(NSCOP.Skill.SkillId.MoonStepDodge)
end

function NSCOP.FightingStance:PrimaryAttack()
	if not self:GetCombatStance() then return end

	NSCOP.Print("Primary Attack")

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
		return
	end

	---@type integer
	local currentSkill = self["GetSkillSlot" .. tostring(self:GetSelectedSkill())](self)
	local skillInstance = self:GetSkillInstance(currentSkill)

	if not skillInstance then return end;

	skillInstance:UseSkill()

	print("Skill Instances")
	PrintTable(self.SkillInstances)
	NSCOP.Print("Secondary Attack")

	self:SetNextSecondaryFire(CurTime() + self.SecondaryCD)
end

function NSCOP.FightingStance:Reload()
	self:SetCombatStance(not self:GetCombatStance())
end

function NSCOP.FightingStance:Think()
	local owner = self:GetOwner()

	if ! self.InitialSkillSetupDone then
		self:InitialSkillSetup()
	end
end

---@param aerial? boolean If the dodge is aerial, if so, then the player will dodge upwards
function NSCOP.FightingStance:Dodge(aerial)
	if CurTime() < self:GetNextDodge() then return end

	local moonStepDodge = self:GetSkillInstance(NSCOP.Skill.SkillId.MoonStepDodge)
	---@cast moonStepDodge NSCOP.FightingStance.MoonStepDodge
	moonStepDodge:UseSkill(aerial)
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

---Returns all equipped skills
---@return integer[] skillIds Skills ids of all equipped skills
function NSCOP.FightingStance:AllSkills()
	local allSkills = {}
	for i = 1, 6 do
		table.insert(allSkills, self["GetSkillSlot" .. tostring(i)](self))
	end

	return allSkills
end

---Sets a skill into a slot. Duplicate skill instances are not supported and only the last instance will be kept
---@param slot integer Slot to set the skill into
---@param skill NSCOP.SkillId Skill Id to set into the slot
---@param shouldCreateInstance? boolean Don't create a skill instance automatically
function NSCOP.FightingStance:SetSkillIntoSlot(slot, skill, shouldCreateInstance)
	if shouldCreateInstance == nil then
		shouldCreateInstance = true
	end

	self["SetSkillSlot" .. tostring(slot)](self, skill)

	if self:GetSkillInstance(skill) then
		local instance = self:GetSkillInstance(skill)

		if instance then
			instance:Remove()
			self.SkillInstances[skill] = nil
		end
	end

	if shouldCreateInstance then
		self:CreateSkillInstance(skill)
	end
end

---Creates an instance of a skill and assigns it to the weapon
---@param skillId NSCOP.SkillId|integer Skill to create instance of
function NSCOP.FightingStance:CreateSkillInstance(skillId)
	local skill = NSCOP.Skill.GetSkillByID(skillId)

	if ! skill then
		NSCOP.Print("Invalid Skill ID! id " .. skillId)
		return
	end

	local newInstance = skill:CreateInstance()
	newInstance:AssignWeapon(self)

	self.SkillInstances[newInstance.Skill.SkillId] = newInstance
end

---Returns an instance of a skill
---@param skillId NSCOP.SkillId|integer Returns an instance of desired skill
---@return NSCOP.SkillInstance | nil
function NSCOP.FightingStance:GetSkillInstance(skillId)
	return self.SkillInstances[skillId]
end

---Returns the key of a skill
---@param skillButtonType NSCOP.ButtonType
---@return NSCOP.ButtonValue | nil
function NSCOP.FightingStance:GetSkillButton(skillButtonType)
	local owner = self:GetOwner()

	if not owner:IsValid() then return end
	if not owner:IsPlayer() then return end
	---@cast owner Player

	if not owner.NSCOP or not owner.NSCOP.Controls then
		NSCOP.PrintDebug("Player has no controls data")
		return
	end

	return owner.NSCOP.Controls[skillButtonType].Button
end

--#endregion

-- Before we add the weapon, we load the client and server files for them to change the properties
NSCOP.IncludeServer("sv_init.lua")
NSCOP.IncludeClient("cl_init.lua")

weapons.Register(NSCOP.FightingStance, "nsc_fightingstance")
