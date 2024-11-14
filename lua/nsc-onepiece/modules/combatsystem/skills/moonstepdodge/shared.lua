---@class NSCOP.FightingStance.MoonStepDodge : NSCOP.Skill
NSCOP.FightingStance.MoonStepDodge = NSCOP.Skill.RegisterSkill({
	SkillId = NSCOP.Skill.SkillIDs.MoonStepDodge,
	SkillName = "Moonstep Dodge Directional",
})

if !NSCOP.FightingStance.MoonStepDodge then return end

---@class NSCOP.FightingStance.MoonStepDodge
local moonStepDodge = NSCOP.FightingStance.MoonStepDodge

local dodgeSpeed = 30

---@param aerial? boolean
function moonStepDodge:UseSkill( aerial )
    ---@type NSCOP.FightingStance
    local weapon = self.Weapon

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
    local endPos = owner:GetPos() + moveDirection * ( finalForce )
    local oldLagMovementValue = owner:GetLaggedMovementValue()

    local maxs, mins = owner:OBBMaxs(), owner:OBBMins()
    maxs = Vector( maxs.x * 1.25, maxs.y * 1.25, maxs.z )
    mins = Vector( mins.x * 1.25, mins.y * 1.25, mins.z + ( !owner:Crouching() and 5 or 0 ) )

    local traceHull = util.TraceHull( {
        start = initialPos,
        endpos = endPos,
        maxs = maxs,
        mins = mins,
        filter = { weapon, owner }
    } )

    local finalPos = traceHull.HitPos
    debugoverlay.Box( finalPos, maxs, mins )

    if SERVER then
        owner:SetLaggedMovementValue(0)
    end

    weapon.IsMidDodge = true

    owner:NSCOP_SetIFrames(100)

    --FIXME: Sometimes the hook does not get removed on the client and keeps handling logic. A pretty big issue
    local hookName = "NSCOP.Skill.MoonStepDodge.HandleDodge." .. self.InstanceId
    NSCOP.Utils.AddHook("Think", hookName, function()
        --Logic for stopping the dodge handling
        if !IsValid(owner) or !IsValid(weapon) or owner:GetPos() == finalPos then
            hook.Remove("Think", hookName) 
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
        local pos = owner:GetPos()
        local newPos = NSCOP.Utils.NSCOP_ApproachVector(pos, finalPos, dodgeSpeed)

        print( owner:GetPos() == finalPos )

        owner:SetPos(newPos)
        owner:SetLocalVelocity(vector_origin)
    end)

	NSCOP.Print("Player dodged", owner)

	weapon:SetNextDodge(CurTime() + weapon.DodgeCD)
end