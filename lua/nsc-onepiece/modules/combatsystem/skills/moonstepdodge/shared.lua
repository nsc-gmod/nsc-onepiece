---@class NSCOP.FightingStance.MoonStepDodge : NSCOP.SkillInstance
NSCOP.FightingStance.MoonStepDodge = NSCOP.Skill.RegisterSkill({
	SkillId = NSCOP.Skill.SkillId.MoonStepDodge,
	SkillName = "Moonstep Dodge Directional",
	SkillCD = 0.5
})

if ! NSCOP.FightingStance.MoonStepDodge then return end

---@class NSCOP.FightingStance.MoonStepDodge
local moonStepDodge = NSCOP.FightingStance.MoonStepDodge

local dodgeSpeed = 30

---@param aerial? boolean
function moonStepDodge:UseSkill(aerial)
	if not self:CanUseSkill() then return end

	local weapon = self.Weapon

	if not weapon:IsValid() then return end
	---@cast weapon NSCOP.FightingStance
	if weapon.IsMidDodge then return end

	local owner = weapon:GetOwner()
	if not owner:IsValid() then return end
	if not owner:IsPlayer() then return end
	---@cast owner Player

	local moveDirection = owner:NSCOP_GetMoveDirection(true)
	if aerial then -- If aerial, the direction is changed to the vertical
		moveDirection = vector_up
	end

	-- Fixes an issue where there is a velocity hickup when the player is in air
	if (moveDirection == vector_origin) then return end

	local finalForce = weapon.DodgeForce

	local initialPos = owner:GetPos()
	local endPos = owner:GetPos() + moveDirection * (finalForce)
	local oldLagMovementValue = owner:GetLaggedMovementValue()

	print("a")

	local maxs, mins = owner:OBBMaxs(), owner:OBBMins()
	maxs = Vector(maxs.x * 1, maxs.y * 1, maxs.z)
	mins = Vector(mins.x * 1, mins.y * 1, mins.z + (! owner:Crouching() and 5 or 0))

	local traceHull = util.TraceHull({
		start = initialPos,
		endpos = endPos,
		maxs = maxs,
		mins = mins,
		filter = { weapon, owner }
	})

	local finalPos = traceHull.HitPos
	debugoverlay.Box(finalPos, maxs, mins)

	if SERVER then
		owner:SetLaggedMovementValue(0)
		owner:NSCOP_SetIFrames(100)
	end

	weapon.IsMidDodge = true

	--FIXME: Sometimes the hook does not get removed on the client and keeps handling logic. A pretty big issue
	local hookName = "NSCOP.Skill.MoonStepDodge.HandleDodge." .. self.InstanceIndex
	NSCOP.Utils.AddHook("PlayerTick", hookName, function()
		--Logic for stopping the dodge handling
		if ! IsValid(owner) or ! IsValid(weapon) or owner:GetPos() == finalPos then
			hook.Remove("PlayerTick", hookName)
			if IsValid(owner) then
				if SERVER then
					owner:SetLaggedMovementValue(oldLagMovementValue)
				end
			end
			if IsValid(weapon) then
				weapon.IsMidDodge = false
			end
			return
		end
		--
		print("a")
		local pos = owner:GetNetworkOrigin()
		local newPos = NSCOP.Utils.NSCOP_ApproachVector(pos, finalPos, dodgeSpeed)

		owner:SetPos(newPos)
		owner:SetLocalVelocity(vector_origin)
	end)

	NSCOP.Print("Player dodged", owner)

	self:StartCooldown()
end
