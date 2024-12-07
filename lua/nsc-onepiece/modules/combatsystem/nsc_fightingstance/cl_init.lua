---@class NSCOP.FightingStance: SWEP

function NSCOP.FightingStance:Think()
	local owner = self:GetOwner()

	if ! self.InitialSkillSetupDone then
		self:InitialSkillSetup()
	end
end

local defaultCamSmoothSpeed = 35
local defaultFov = 80
local defaultCamOffset = -10
local defaultUpOffset = -5

local camFov = defaultFov
local camOffset = defaultCamOffset
local upOffset = defaultUpOffset
local camSmoothSpeed = defaultCamSmoothSpeed

local vectorOrigin = vector_origin
local angleZero = angle_zero

local viewPos = vectorOrigin
local viewAngle = angleZero

NSCOP.Utils.AddHook("CalcView", "NSCOP.FightingStance.ThirdPerson", function(ply, pos, angles, fov, znear, zfar)
	if not ply:NSCOP_IsUsingCombatSWEP() then return end
	if camFov < 10 then return end

	local frameTime = FrameTime()

	camFov = defaultFov

	---@type TraceResult?
	local trace = util.TraceLine({
		start = pos,
		endpos = pos - (angles:Forward() * camFov + angles:Right() * camOffset + angles:Up() * upOffset),
		collisiongroup = COLLISION_GROUP_DEBRIS,
	})

	if not trace then return end

	viewPos = LerpVector(camSmoothSpeed * frameTime, viewPos, trace.HitPos)
	viewAngle = LerpAngle(camSmoothSpeed * frameTime, viewAngle, angles)

	---@type CamData
	local view = {
		origin = viewPos,
		angles = viewAngle,
		fov = fov,
		drawviewer = true
	}

	return view
end)

local hudLeftPartX, hudLeftPartH
local hudRightPartX, hudRightPartH

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

local arrow = Material("gui/point.png")
local skillRect = Material("nsc-onepiece/hud/skillRect.vmt")
local skillRectActive = Material("nsc-onepiece/hud/skillRect_Active.vmt")
local skillRectCooldown = Material("nsc-onepiece/hud/skillRect_Cooldown.vmt")
local skillRectActiveCooldown = Material("nsc-onepiece/hud/skillRect_Active_Cooldown.vmt")

---Draws the skills on the HUD
function NSCOP.FightingStance:DrawSkills()
	local selectedSkill = self:GetSelectedSkill()

    local center = ScrW()/2
	for i = 1, 6, 1 do
		local margin = screenScaleW(70)
		self:DrawSkill( ( center - margin * 3 ) + ( margin * i ), hudLeftPartH + screenScaleH(140), i, i == selectedSkill)
	end
end

---Draws a skill slot on the HUD
---<br>REALM: CLIENT
---@param x number
---@param y number
---@param skillIndex integer
---@param active boolean If the skill is active
function NSCOP.FightingStance:DrawSkill(x, y, skillIndex, active)
	local finalMat = skillRect
	local skillSize = !active and screenScaleW(64) or screenScaleW(128)

	local finalX = x - (!active and skillSize or screenScaleW(96))
	local finalY = y - (!active and skillSize or screenScaleW(96))

	---@type integer
	local skillId = self["GetSkillSlot" .. tostring(skillIndex)](self)
	local skillInstance = self:GetSkillInstance(skillId)

	if not skillInstance then return end

	local skillCooldown = skillInstance:GetSkillTime()

	if skillCooldown > 0 then
		local cooldown = skillCooldown
		local cooldownPercentage = math.Clamp(cooldown / skillInstance.SkillCD, 0, 1)

		draw.NoTexture()
		surface.SetDrawColor(0, 0, 0, 200)

		local cooldownMat = skillRectCooldown

		if active then
			cooldownMat = skillRectActiveCooldown
		end

		surface.SetMaterial(cooldownMat)
		local cooldownSize = !active and skillSize * cooldownPercentage or screenScaleW(70) * cooldownPercentage
		local cooldownX = finalX + (skillSize - cooldownSize) / 2
		local cooldownY = finalY + (skillSize - cooldownSize) / 2
		surface.DrawTexturedRect(cooldownX, cooldownY, cooldownSize, cooldownSize)
		-- NSCOP.Utils.DrawCircle(x - (skillSize / 2), y - (skillSize / 2), (skillSize / 2.5) * cooldownPercentage, 32)
	end

	if active then
        surface.SetMaterial(arrow)
        surface.SetDrawColor(255, 255, 255, 128)
		surface.DrawTexturedRect(finalX + screenScaleW(56), finalY + screenScaleH(8), screenScaleW(16), screenScaleH(8))

		finalMat = skillRectActive
	end
	surface.SetMaterial(finalMat)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(finalX, finalY, skillSize, skillSize)

	local skillButton = self:GetSkillButton(skillIndex)

	if not skillButton then return end
	---@cast skillButton integer

	-- local keyName = input.GetKeyName(skillButton)
	-- draw.SimpleTextOutlined(keyName, "NSCOP_Main", x - skillSize / 2, y - skillSize / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(97, 89, 73))
end

function NSCOP.FightingStance:DrawHUD()
	hudLeftPartX = screenScaleW(20)
    hudLeftPartH = ScrH() - screenScaleH(270)
    hudRightPartX = ScrW() - screenScaleW(20)
    hudRightPartH = ScrH() - screenScaleH(270)

	self:DrawSkills()
end

---@type {[NSCOP.HUDBaseElement]: boolean}
local disabledHud = {
	["CHudWeaponSelection"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudHealth"] = true
}

---@type {[NSCOP.HUDBaseElement]: boolean}
local combatDisabledHud = {
	["CHudWeaponSelection"] = true,
}

---@param element NSCOP.HUDBaseElement
function NSCOP.FightingStance:HUDShouldDraw(element)
	local isInCombatStance = self:GetCombatStance()

	if disabledHud[element] then
		return false
	end

	if isInCombatStance and combatDisabledHud[element] then
		return false
	end

	return true
end

function NSCOP.FightingStance:OnRemove()
	if IsValid(self.PlayerAvatar) then
		self.PlayerAvatar:Remove()
	end
end
