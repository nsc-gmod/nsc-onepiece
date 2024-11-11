---@class Test : NSCOP.Skill
local Test = NSCOP.Skill.RegisterSkill({
	SkillId = 1000,
	SkillName = "Test Skill",
})

if not Test then return end

function Test:DoCrazyShit()
	local weapon = self.Weapon

	local owner = weapon:GetOwner()

	print(self.SkillName)
	print('original crazy shit')

	if SERVER then
		owner:TakeDamage(1)
	end
end

---@class Test : NSCOP.SkillInstance
local instance = Test:CreateInstance()
