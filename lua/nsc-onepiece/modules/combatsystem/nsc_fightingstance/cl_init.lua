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

local hudLeftPartX, hudLeftPartH = 20, 820

local matNull = Material("null")

local avatarBorderTopPiece = Material("nsc-onepiece/hud/avatarBorderPiece02.vmt")
local avatarBorderBottomPiece = Material("nsc-onepiece/hud/avatarBorderPiece01.vmt")
local borderDeco = Material("nsc-onepiece/hud/hudDecoration01")

local barFrame01 = Material("nsc-onepiece/hud/barFrame01.vmt")
local healthBar01 = Material("nsc-onepiece/hud/healthBar01.vmt")

local skillRect = Material("nsc-onepiece/hud/skillRect.vmt")
local skillRectActive = Material("nsc-onepiece/hud/skillRect_Active.vmt")
local skillRectCooldown = Material("nsc-onepiece/hud/skillRect_Cooldown.vmt")
local skillRectActiveCooldown = Material("nsc-onepiece/hud/skillRect_Active_Cooldown.vmt")

local buffBorder = Material("nsc-onepiece/hud/buffBorder.vmt")

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

-- TODO: Optimize everything here in the future
-- TODOOO: The fucking HUD is for some reason broken on resolutions lower than 2K. im frustrated

function NSCOP.FightingStance:DrawHUD()
	self:DrawPlayerHUD()

	self:DrawSkills()
end

function NSCOP.FightingStance:DrawPlayerHUD()
	self:DrawAvatarBorderTopPiece()
	self:DrawAvatar()
	self:DrawAvatarBorderBottomPiece()
	self:DrawBorderDecoration()
	self:DrawBars()
	self:DrawNickname()
end

function NSCOP.FightingStance:DrawNickname()
	local nickX = screenScaleW(hudLeftPartX + 260, true)
	local nickY = screenScaleH(hudLeftPartH - 8, true)

	local nickname = string.sub( self:GetOwner():GetName(), 0, NSCOP.Config.HUD.NicknameCharacterLimit )

	-- Rotates the text, so it appears tilted. Found it on some forum: https://www.unknowncheats.me/forum/garry-s-mod/383202-glua-draw-draw-simpletextoutlined-rotation.html
	local mat = Matrix()

	mat:Translate(Vector(NSCOP.Utils.ScreenW/2, NSCOP.Utils.ScreenH/2))
	mat:Rotate(Angle(0,-5,0))
	mat:Scale(Vector(1,1,1))
	mat:Translate(-Vector(NSCOP.Utils.ScreenW/2, NSCOP.Utils.ScreenH/2))
 
	cam.PushModelMatrix(mat)
	draw.SimpleTextOutlined(nickname, "NSCOP_Main_Small", nickX, nickY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(97, 89, 73))
	cam.PopModelMatrix()	

end

local oldHp = 0

function NSCOP.FightingStance:DrawHealthBar(x, y)
	local owner = self:GetOwner()
	--
	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilReferenceValue(1)

	local hp = owner:Health()
    local maxHp = owner:GetMaxHealth()
    if ( oldHp == 0 ) then
        oldHp = hp
    end

	local maskWidth = screenScaleW(400)

	local newHp = Lerp( FrameTime() * 10, oldHp, ( hp / maxHp ) * maskWidth )
    oldHp = newHp

	surface.SetMaterial(matNull) -- We need to use this, so the mask becomes transparent. I didn't find another solution
	surface.DrawTexturedRect(x + 56, y, newHp, screenScaleH(100))
	draw.NoTexture()

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(healthBar01)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))

	render.SetStencilEnable(false)
	--

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(barFrame01)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))
end

function NSCOP.FightingStance:DrawBars()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local x, h = hudLeftPartX, hudLeftPartH

	self:DrawHealthBar( screenScaleW(x + 87), screenScaleH(h + 20, true) )
end

function NSCOP.FightingStance:DrawAvatarBorderBottomPiece()
	local avatarSize = screenScaleW(256)
	local avatarX = screenScaleW(hudLeftPartX, true)
	local avatarY = screenScaleH(hudLeftPartH, true)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(avatarBorderBottomPiece)
	surface.DrawTexturedRect(avatarX, avatarY, avatarSize, avatarSize)
end

function NSCOP.FightingStance:DrawAvatarBorderTopPiece()
	local avatarSize = screenScaleW(256)
	local avatarX = screenScaleW(hudLeftPartX, true)
	local avatarY = screenScaleH(hudLeftPartH, true)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(avatarBorderTopPiece)
	surface.DrawTexturedRect(avatarX, avatarY, avatarSize, avatarSize)
end


function NSCOP.FightingStance:DrawBorderDecoration()
	local width, height = screenScaleW(512), screenScaleH(128)
	local decoX = screenScaleW(hudLeftPartX + 115)
	local decoY = screenScaleH(hudLeftPartH - 12, true)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(borderDeco)
	surface.DrawTexturedRect(decoX, decoY, width, height)
end

local avatarCamPos = Vector(40, 0, 0)
local avatarLookAt = Vector(0, 0, 40)
function NSCOP.FightingStance:DrawAvatar()
	local owner = self:GetOwner()

	if not IsValid(owner) then return end
	---@cast owner Player

	local baseAvatarRadius = 256
	local avatarRadius = ScreenScale(baseAvatarRadius / 2)
	local avatarX = screenScaleW(25 + (avatarRadius / 2), true)
	local avatarY = screenScaleH(875 + (avatarRadius / 2), true)

	draw.NoTexture()

	if ! IsValid(self.PlayerAvatar) then
		self.PlayerAvatar = vgui.Create("DModelPanel")
		self.PlayerAvatar:SetModel(owner:GetModel())
		self.PlayerAvatar:SetFOV(25)
		self.PlayerAvatar:SetCamPos(avatarCamPos)
		self.PlayerAvatar:SetLookAt(avatarLookAt)
		self.PlayerAvatar:SetPos(avatarX - avatarRadius, avatarY - avatarRadius * 4)
		self.PlayerAvatar:SetSize(avatarRadius * 2, avatarRadius * 6)
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

		surface.SetMaterial(matNull) -- We need to use this, so the mask becomes transparent. I didn't find another solution
		NSCOP.Utils.DrawCircle(avatarX, avatarY, avatarRadius, 30)
		surface.DrawTexturedRect(avatarX / 2.5, avatarY - avatarRadius * 2, avatarRadius * 2, avatarRadius * 2)
		draw.NoTexture()

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
