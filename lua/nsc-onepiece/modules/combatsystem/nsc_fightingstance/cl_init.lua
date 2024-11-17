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

local buffBorder = Material("nsc-onepiece/hud/buffBorder.vmt")

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

function NSCOP.FightingStance:DrawHUD()
	self:DrawPlayerHUD()

	self:DrawSkills()
end

function NSCOP.FightingStance:DrawPlayerHUD()
	self:DrawAvatar()
	self:DrawAvatarBorder()
	self:DrawBars()
end

function NSCOP.FightingStance:DrawBars()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local health = ply:Health()
	local maxHealth = ply:GetMaxHealth()
	local healthPercentage = math.Clamp(health / maxHealth, 0, 1)

	local barWidth = screenScaleW(300)
	local barHeight = screenScaleH(25, true)
	local barX = screenScaleW(160, true)
	local barY = screenScaleH(940, true)

	-- Draw background
	draw.RoundedBox(8, barX, barY, barWidth, barHeight, Color(50, 50, 50, 200))
	-- Draw health bar
	draw.RoundedBox(8, barX, barY, barWidth * healthPercentage, barHeight, Color(192, 0, 59, 255))

	-- Draw background
	draw.RoundedBox(8, barX - 20, barY + 25, barWidth, barHeight, Color(50, 50, 50, 200))
	-- Draw energy bar
	draw.RoundedBox(8, barX - 20, barY + 25, barWidth * healthPercentage, barHeight, Color(183, 227, 249, 255))

	-- Draw background
	draw.RoundedBox(8, barX - 40, barY + 50, barWidth, barHeight, Color(50, 50, 50, 400))
	-- Draw stamina bar
	draw.RoundedBox(8, barX - 40, barY + 50, barWidth * healthPercentage, barHeight, Color(249, 211, 139, 255))

	local xpBarX = screenScaleW(775, true)
	local xpBarY = screenScaleH(990, true)
	local xpBarWidth = screenScaleW(450)
	local xpBarHeight = screenScaleH(30, true)
	local experiencePercentage = math.Clamp(ply.NSCOP.PlayerData.CharacterData.Experience / 1000, 0, 1)

	-- Draw background
	draw.RoundedBox(8, xpBarX, xpBarY, xpBarWidth, xpBarHeight, Color(50, 50, 50, 400))
	-- Draw experience bar
	draw.RoundedBox(8, xpBarX, xpBarY, xpBarWidth * experiencePercentage, xpBarHeight, Color(208, 104, 160, 255))
	--Draw xp text
	draw.SimpleTextOutlined(
		string.format("%d / %d", ply.NSCOP.PlayerData.CharacterData.Experience, 1000),
		"NSCOP_Main_Small",
		xpBarX + xpBarWidth / 2,
		xpBarY + xpBarHeight / 2,
		color_white,
		TEXT_ALIGN_CENTER,
		TEXT_ALIGN_CENTER,
		2,
		Color(0, 0, 0, 255))


	-- -- Draw health text
	-- draw.SimpleTextOutlined(
	-- 	string.format("%d / %d", health, maxHealth),
	-- 	"NSCOP_Main_Small",
	-- 	barX + barWidth / 2,
	-- 	barY + barHeight / 2,
	-- 	color_white,
	-- 	TEXT_ALIGN_CENTER,
	-- 	TEXT_ALIGN_CENTER,
	-- 	2,
	-- 	Color(0, 0, 0, 200))
end

function NSCOP.FightingStance:DrawAvatarBorder()
	local avatarSize = screenScaleW(150)
	local avatarX = screenScaleW(50, true)
	local avatarY = screenScaleH(900, true)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(avatarBorder)
	surface.DrawTexturedRect(avatarX, avatarY, avatarSize, avatarSize)

	local ply = LocalPlayer()
	if not IsValid(ply) then return end
end

local avatarCamPos = Vector(35, 0, 30)
local avatarLookAt = Vector(0, 0, 40)
function NSCOP.FightingStance:DrawAvatar()
	local owner = self:GetOwner()

	if not IsValid(owner) then return end
	---@cast owner Player

	local baseAvatarRadius = 150
	local avatarRadius = screenScaleW(baseAvatarRadius / 2)
	local avatarX = screenScaleW(50 + (baseAvatarRadius / 2), true)
	local avatarY = screenScaleH(900 + (baseAvatarRadius / 2), true)

	draw.NoTexture()

	if ! IsValid(self.PlayerAvatar) then
		self.PlayerAvatar = vgui.Create("DModelPanel")
		self.PlayerAvatar:SetModel(owner:GetModel())
		self.PlayerAvatar:SetFOV(25)
		self.PlayerAvatar:SetCamPos(avatarCamPos)
		self.PlayerAvatar:SetLookAt(avatarLookAt)
		self.PlayerAvatar:SetPos(avatarX - avatarRadius, avatarY - avatarRadius * 1.15)
		self.PlayerAvatar:SetSize(avatarRadius * 2, avatarRadius * 2)
		self.PlayerAvatar:SetVisible(true)

		function self.PlayerAvatar.Entity:GetPlayerColor() return owner:GetPlayerColor() end

		function self.PlayerAvatar.Entity:GetSkin() return owner:GetSkin() end

		self.PlayerAvatar.Think = function()
			if ! IsValid(self) then
				self.PlayerAvatar:Remove()
				return
			end

			self.PlayerAvatar:SetModel(owner:GetModel())
			local PlayerModelBGroup = ""
			local PlayerModelSkin = owner:GetSkin() or 0

			for n = 0, owner:GetNumBodyGroups() do
				PlayerModelBGroup = PlayerModelBGroup .. owner:GetBodygroup(n)
			end

			local ent = self.PlayerAvatar.Entity
			ent:SetBodyGroups(PlayerModelBGroup)
			ent:SetSkin(PlayerModelSkin)
		end

		self.PlayerAvatar.LayoutEntity = function(ent)
			local layoutEnt = self.PlayerAvatar:GetEntity()
			if IsValid(layoutEnt) and layoutEnt.LookupBone and layoutEnt:LookupBone("ValveBiped.Bip01_Head1") and layoutEnt:LookupBone("ValveBiped.Bip01_Head1") != -1 then
				local headPos = math.Round(layoutEnt:GetBonePosition(layoutEnt:LookupBone("ValveBiped.Bip01_Head1")).z) + 2
				if avatarCamPos.z != headPos then
					avatarCamPos.z = headPos
					avatarLookAt.z = headPos
				end
				self.PlayerAvatar:SetCamPos(avatarCamPos)
				self.PlayerAvatar:SetLookAt(avatarLookAt)
			end

			return
		end
		self.PlayerAvatar:SetPaintedManually(true)
	else
		render.ClearStencil()
		render.SetStencilEnable(true)

		render.SetStencilWriteMask(1)
		render.SetStencilTestMask(1)

		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetStencilReferenceValue(1)

		surface.SetDrawColor(255, 255, 255, 1)
		draw.NoTexture()
		NSCOP.Utils.DrawCircle(avatarX, avatarY, avatarRadius, 30)
		surface.DrawRect(50, 900 - avatarRadius * 4, avatarRadius * 2, avatarRadius * 5)

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		surface.SetDrawColor(255, 255, 255, 255)
		self.PlayerAvatar:SetPaintedManually(false)
		self.PlayerAvatar:PaintManual()
		self.PlayerAvatar:SetPaintedManually(true)
		render.SetStencilEnable(false)
	end
end

---Draws the skills on the HUD
function NSCOP.FightingStance:DrawSkills()
	local selectedSkill = self:GetSelectedSkill()

	for i = 1, 6, 1 do
		local margin = 70
		self:DrawSkill(screenScaleW(852.5, true) + screenScaleW((i - 1) * margin), screenScaleH(975, true), i, i == selectedSkill)
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
