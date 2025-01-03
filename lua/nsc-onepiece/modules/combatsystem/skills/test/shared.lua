---@class Test : NSCOP.Skill
local Test = NSCOP.Skill.RegisterSkill({
	SkillId = 1000,
	SkillName = "Test Skill",
	SkillCD = 1
})

if not Test then return end

function Test:UseSkill()
	if not self:CanUseSkill() then return end

	local weapon = self.Weapon

	local owner = weapon:GetOwner()

	print(self.SkillName)
	print('original crazy shit')

	if SERVER then
		local damageInfo = DamageInfo()
		damageInfo:SetDamageCustom(NSCOP.Utils.FlagAdd(NSCOP.DamageType.IgnoreIFrames, NSCOP.DamageType.IgnoreBlock))
		damageInfo:SetDamage(1)

		owner:TakeDamageInfo(damageInfo)
	end

	self:StartCooldown()
end

---@class Test : NSCOP.SkillInstance
local instance = Test:CreateInstance()
