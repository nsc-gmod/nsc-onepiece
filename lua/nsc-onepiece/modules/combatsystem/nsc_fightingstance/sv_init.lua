---@class NSCOP.FightingStance: SWEP

function NSCOP.FightingStance:Think()
	local owner = self:GetOwner()

	if ! self.InitialSkillSetupDone then
		self:InitialSkillSetup()
	end
end