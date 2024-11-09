---The purpose of this class is to handle and manage all the skill related stuff. The idea is to make the skills modular as possible.
---@class NSCOP.Skill
NSCOP.Skill = NSCOP.Skill or {}
NSCOP.Skill.__index = NSCOP.Skill

---@enum NSCOP.Skills
NSCOP.Skill.SkillIDs = {
	BasicAttack = 1,
	MoonStepDodge = 2,
	MoonStepAerial = 3,
}

---Creates a Skill class object using the data
---@param skillData table
---@return NSCOP.Skill Created Skill object
function NSCOP.Skill.RegisterSkill(skillData)
	local self = setmetatable(NSCOP.Skill, {})

	self.SkillID = skillData.SkillID
	self.SkillName = skillData.SkillName
	self.SkillDescription = skillData.SkillDescription
	self.SkillIcon = skillData.SkillIcon

	return self
end
