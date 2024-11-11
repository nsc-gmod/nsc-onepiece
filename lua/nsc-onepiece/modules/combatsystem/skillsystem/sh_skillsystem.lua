---The purpose of this class is to handle and manage all the skill related stuff. The idea is to make the skills modular as possible.
---@class NSCOP.Skill
NSCOP.Skill = NSCOP.Skill or {}
NSCOP.Skill.__index = NSCOP.Skill
NSCOP.Skill.RegisteredSkills = NSCOP.Skill.RegisteredSkills or {}

---@class NSCOP.SkillInstance : NSCOP.Skill
NSCOP.SkillInstance = NSCOP.SkillInstance or {}
NSCOP.SkillInstance.__index = NSCOP.SkillInstance
NSCOP.SkillInstance.Instances = NSCOP.SkillInstance.Instances or {}

---@class NSCOP.SkillData
---@field SkillId integer
---@field SkillName string | nil
---@field SkillDescription string | nil
---@field SkillIcon string | nil
---@field SkillFunctionalData table | nil

---@enum NSCOP.Skills
NSCOP.Skill.SkillIDs = {
	BasicAttack = 1,
	MoonStepDodge = 2,
	MoonStepAerial = 3,
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
	elseif NSCOP.Skill.GetAllSkills()[skillId] then
		NSCOP.Print("Trying to create a skill with an already occupied id! (ID: " .. (skillId or "n/a") .. ", SKILLNAME: " .. (skillData.SkillName or "n/a") .. ")")
		return
	end

	---The skill's ID that will be used in code. Using an id of already existing skill may cause serious issues
	---@type NSCOP.Skills | integer
	self.SkillID = skillId

	---The skill's name that will be displayed anywhere
	---@type string | nil
	self.SkillName = skillData.SkillName

	if CLIENT then
		---<br> REALM: CLIENT
		---The skill's description that will be displayed in UI's
		---@type string | nil
		self.SkillDescription = skillData.SkillDescription

		---<br> REALM: CLIENT
		---The skill icon which will be displayed in the UI's
		---@type string | nil
		self.SkillIcon = skillData.SkillIcon
	end

	---The table with all data that may be used in skill's functionality. You can put any data in here that you want to use later
	self.SkillFunctionalData = skillData.SkillFunctionalData

	NSCOP.Skill.RegisteredSkills[skillId] = self

	return self
end

---Creates all registered skills
---@return table | nil All registered skills
function NSCOP.Skill.GetAllSkills()
	return NSCOP.Skill.RegisteredSkills
end

---<br> REALM: SHARED
---Creates an instance of a Skill
---@return NSCOP.SkillInstance | nil Created Skill instance
function NSCOP.Skill:CreateInstance()
	---@class NSCOP.SkillInstance
	local instance = {}
	setmetatable(instance, self)

	---@type NSCOP.Skill
	instance.Skill = self
	instance.RegisteredSkills = nil
	instance.RegisterSkill = nil
	instance.CreateInstance = nil
	instance.GetAllSkills = nil

	---@type integer
	instance.InstanceId = table.insert( NSCOP.SkillInstance.AllInstances(), instance )

	return instance --- SkillInstance object
end

-----@return table All existing Skill instances
function NSCOP.SkillInstance.AllInstances()
	return NSCOP.SkillInstance.Instances
end

-----@return NSCOP.Skill The Skill that the instance is derived from
function NSCOP.SkillInstance:GetSkill()
	return self.Skill
end
