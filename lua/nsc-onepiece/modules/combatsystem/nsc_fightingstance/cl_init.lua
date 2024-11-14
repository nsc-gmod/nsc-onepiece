---@class NSCOP.FightingStance: SWEP

local defaultFov = 80
local defaultCamOffset = -0

local camFov = defaultFov
local camOffset = defaultCamOffset

local vectorOrigin = vector_origin
local angleZero = angle_zero

local viewPos   = vectorOrigin
local viewAngle = angleZero

NSCOP.Utils.AddHook( "CalcView", "NSCOP.FightingStance.ThirdPerson", function( ply, pos, angles, fov, znear, zfar )
    if ply:NSCOP_IsUsingCombatSWEP() then
        if camFov < 10 then return end

        local frameTime = FrameTime()

        camFov = defaultFov
        
        local tr = util.TraceLine( {
            start = pos,
            endpos = pos - ( angles:Forward() * camFov + angles:Right() * camOffset ),
            collisiongroup = COLLISION_GROUP_DEBRIS,
        } )
                
        viewPos = LerpVector( 25 * frameTime, viewPos, tr.HitPos )
        viewAngle = LerpAngle( 25 * frameTime, viewAngle, angles )
        
        local view = {
            origin = viewPos,
            angles = viewAngle,
            fov = fov,
            drawviewer = true
        }
        
        return view
    end       
end)

local skillRect = Material("nsc-onepiece/hud/skillRect.vmt")
local skillRectActive = Material("nsc-onepiece/hud/skillRect_Active.vmt")

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

function NSCOP.FightingStance:DrawHUD()
	self:DrawSkills()

	surface.DrawLine(ScrW() / 2, ScrH(), ScrW() / 2, 0)
end

---Draws the skills on the HUD
function NSCOP.FightingStance:DrawSkills()
	local selectedSkill = self:GetSelectedSkill()

	for i = 1, 6, 1 do
		local margin = 70
		self:DrawSkill(screenScaleW(852.5, true) + screenScaleW((i - 1) * margin), screenScaleH(1050, true),
			i == selectedSkill)
	end
end

function NSCOP.FightingStance:DrawSkill(x, y, active)
	local finalMat = skillRect
	local skillSize = screenScaleW(64)

	if active then
		finalMat = skillRectActive
	end

	surface.SetMaterial(finalMat)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(x - skillSize, y - skillSize, skillSize, skillSize)
end

---@param element NSCOP.HUDBaseElement
function NSCOP.FightingStance:HUDShouldDraw(element)
	local isInCombatStance = self:GetCombatStance()

	if isInCombatStance and element == "CHudWeaponSelection" then
		return false
	end

	return true
end
