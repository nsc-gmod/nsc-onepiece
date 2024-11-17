---@class NSCOP.FightingStance: SWEP

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

	if camFov < 10 then return end
	local frameTime = FrameTime()

	camFov = defaultFov

	---@type TraceResult?
	local tr = util.TraceLine({
		start = pos,
		endpos = pos - (angles:Forward() * camFov + angles:Right() * camOffset + angles:Up() * upOffset),
		collisiongroup = COLLISION_GROUP_DEBRIS,
	})

	if not tr then return end

	viewPos = LerpVector(camSmoothSpeed * frameTime, viewPos, tr.HitPos)
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

local avatarBorder = Material("nsc-onepiece/hud/avatarBorder.vmt")

local skillRect = Material("nsc-onepiece/hud/skillRect.vmt")
local skillRectActive = Material("nsc-onepiece/hud/skillRect_Active.vmt")
local skillRectCooldown = Material("nsc-onepiece/hud/skillRect_Cooldown.vmt")
local skillRectActiveCooldown = Material("nsc-onepiece/hud/skillRect_Active_Cooldown.vmt")

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

function NSCOP.FightingStance:DrawHUD()
	self:DrawPlayerHUD()

	self:DrawSkills()
end

function NSCOP.FightingStance:DrawPlayerHUD()
	self:DrawAvatar()
end

function NSCOP.FightingStance:DrawAvatar()
	local avatarSize = screenScaleW(128)
	local avatarX = screenScaleW(50, true)
	local avatarY = screenScaleH(900, true)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(avatarBorder)
	surface.DrawTexturedRect(avatarX, avatarY, avatarSize, avatarSize)

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	self:DrawPlayerModelInAvatar(ply, avatarX, avatarY, avatarSize)
end

function NSCOP.FightingStance:DrawPlayerModelInAvatar(ply, x, y, size)
	local ang = Angle(0, RealTime() * 10 % 360, 0) -- Rotate the model slowly
	local pos = Vector(0, 0, 60)                -- Position the model

	cam.Start3D(pos, ang, 70, x, y, size, size)
	render.SuppressEngineLighting(true)
	ply:DrawModel()
	render.SuppressEngineLighting(false)
	cam.End3D()
end

---Draws the skills on the HUD
function NSCOP.FightingStance:DrawSkills()
	local selectedSkill = self:GetSelectedSkill()

	for i = 1, 6, 1 do
		local margin = 70
		self:DrawSkill(screenScaleW(852.5, true) + screenScaleW((i - 1) * margin), screenScaleH(1050, true), i, i == selectedSkill)
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
	local skillSize = screenScaleW(64)

	local finalX = x - skillSize
	local finalY = y - skillSize

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
		local cooldownSize = skillSize * cooldownPercentage
		local cooldownX = finalX + (skillSize - cooldownSize) / 2
		local cooldownY = finalY + (skillSize - cooldownSize) / 2
		surface.DrawTexturedRect(cooldownX, cooldownY, cooldownSize, cooldownSize)
		-- NSCOP.Utils.DrawCircle(x - (skillSize / 2), y - (skillSize / 2), (skillSize / 2.5) * cooldownPercentage, 32)
	end

	if active then
		finalMat = skillRectActive
	end
	surface.SetMaterial(finalMat)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(finalX, finalY, skillSize, skillSize)

	local skillButton = self:GetSkillButton(skillIndex)

	if not skillButton then return end
	---@cast skillButton integer

	local keyName = input.GetKeyName(skillButton)
	draw.SimpleTextOutlined(keyName, "NSCOP_Main", x - skillSize / 2, y - skillSize / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(97, 89, 73))
end

---@type {[NSCOP.HUDBaseElement]: boolean}
local disabledHud = {
	["CHudWeaponSelection"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true
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
