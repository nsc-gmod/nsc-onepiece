---The purpose of this class is to handle and manage all the skill related stuff. The idea is to make the skills modular as possible.
---@class NSCOP.Skill
NSCOP.Skill = NSCOP.Skill or {}
NSCOP.Skill.__index = NSCOP.Skill
NSCOP.Skill.RegisteredSkills = NSCOP.Skill.RegisteredSkills or {}

---@class NSCOP.SkillInstance
NSCOP.SkillInstance = NSCOP.SkillInstance or {}
NSCOP.SkillInstance.__index = NSCOP.SkillInstance
NSCOP.SkillInstance.Instances = NSCOP.SkillInstance.Instances or {}

---@class NSCOP.Skill
---The skill's ID that will be used in code. Using an id of already existing skill may cause serious issues
---@field SkillId NSCOP.SkillId
---The skill's name that will be displayed anywhere
---@field SkillName string | nil
---REALM: CLIENT
---<br>The skill's description that will be displayed in UI's
---@field SkillDescription string | nil
---REALM: CLIENT
---<br>The skill icon which will be displayed in the UI's
---@field SkillIcon string | nil Path to the icon
---The table with all data that may be used in skill's functionality. You can put any data in here that you want to use later
---@field SkillFunctionalData table | nil
---@field SkillCD number

---@class NSCOP.SkillInstance
---@field Skill NSCOP.Skill
---@field InstanceIndex integer
---@field Weapon NSCOP.FightingStance | InvalidEntity
---@field NextSkillUse number

---@class NSCOP.SkillData
---@field SkillId integer
---@field SkillName string | nil
---@field SkillDescription string | nil
---@field SkillIcon string | nil
---@field SkillFunctionalData table | nil
---@field SkillCD number | nil

---@enum NSCOP.SkillId
NSCOP.Skill.SkillId = {
	BasicAttack = 1,
	MoonStepDodge = 2,
}

---Creates a Skill class object using the data
---@param skillData NSCOP.SkillData
---@return NSCOP.Skill | nil Created Skill object
function NSCOP.Skill.RegisterSkill(skillData)
	---@class NSCOP.Skill
	local self = setmetatable({}, NSCOP.Skill)

	local skillId = skillData.SkillId
	if ! skillId then
		NSCOP.Print("Trying to create a skill without an id! (ID: " .. (skillId or "n/a") .. ", SKILLNAME: " .. (skillData.SkillName or "n/a") .. ")")
		return
		-- elseif NSCOP.Skill.GetAllSkills()[skillId] then
		-- 	NSCOP.Print("Trying to create a skill with an already occupied id! (ID: " .. (skillId or "n/a") .. ", SKILLNAME: " .. (skillData.SkillName or "n/a") .. ")")
		-- 	return
	end

	self.SkillId = skillId
	self.SkillName = skillData.SkillName

	if CLIENT then
		self.SkillDescription = skillData.SkillDescription
		self.SkillIcon = skillData.SkillIcon
	end

	self.SkillFunctionalData = skillData.SkillFunctionalData
	self.SkillCD = skillData.SkillCD or 0

	NSCOP.Skill.RegisteredSkills[skillId] = self

	return self
end

---Returns all registered skills
---@return table | nil All registered skills
function NSCOP.Skill.GetAllSkills()
	return NSCOP.Skill.RegisteredSkills
end

---Looks for the existing Skill by an Id
---@param id integer
---@return NSCOP.Skill | nil Skill with the matched Id
function NSCOP.Skill.GetSkillByID(id)
	return NSCOP.Skill.GetAllSkills()[id]
end

---Creates an instance of a Skill
---<br> REALM: SHARED
---@return NSCOP.SkillInstance skillInstance Created Skill instance
function NSCOP.Skill:CreateInstance()
	---@class NSCOP.SkillInstance : NSCOP.Skill
	local instance = table.Copy(self)
	setmetatable(instance, NSCOP.SkillInstance)

	---@type NSCOP.Skill
	instance.Skill = self
	instance.RegisteredSkills = nil
	instance.RegisterSkill = nil
	instance.CreateInstance = nil
	instance.GetAllSkills = nil

	instance.InstanceIndex = table.insert(NSCOP.SkillInstance.AllInstances(), instance)
	instance.NextSkillUse = CurTime() + self.SkillCD

	return instance --- SkillInstance object
end

---Returns all existing Skill instances
---@return table allInstances All existing Skill instances
function NSCOP.SkillInstance.AllInstances()
	return NSCOP.SkillInstance.Instances
end

---Returns the Skill that the instance is derived from
---@return NSCOP.Skill The Skill that the instance is derived from
function NSCOP.SkillInstance:GetSkill()
	return self.Skill
end

---Assigns a weapon to the Skill instance
---@param weapon? NSCOP.FightingStance | InvalidEntity
function NSCOP.SkillInstance:AssignWeapon(weapon)
	if weapon == nil then
		weapon = NULL
	end

	self.Weapon = weapon
end

---Removes the Skill instance
function NSCOP.SkillInstance:Remove()
	NSCOP.SkillInstance.AllInstances()[self.InstanceIndex] = nil
	setmetatable(self, nil)

	self = nil
end

---Returns the time left in seconds until the skill can be used
function NSCOP.SkillInstance:GetSkillTime()
	return self.NextSkillUse - CurTime()
end

---Returns if the skill can be used
---@return boolean
function NSCOP.SkillInstance:CanUseSkill()
	return self:GetSkillTime() < 0
end

function NSCOP.SkillInstance:StartCooldown()
	self.NextSkillUse = CurTime() + self.SkillCD
end

---Uses the skill
function NSCOP.SkillInstance:UseSkill()

end
