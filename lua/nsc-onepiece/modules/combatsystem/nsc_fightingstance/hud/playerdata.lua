---@class NSCOP.FightingStance: SWEP

local outlineColor = Color(97, 89, 73)
local hudLeftPartX, hudLeftPartH

local matNull = Material("null")

local avatarBorderTopPiece = Material("nsc-onepiece/hud/avatarBorderPiece02.vmt")
local avatarBorderBottomPiece = Material("nsc-onepiece/hud/avatarBorderPiece01.vmt")
local borderDeco = Material("nsc-onepiece/hud/hudDecoration01")

local barFrame01 = Material("nsc-onepiece/hud/barFrame01.vmt")
local barFrame02 = Material("nsc-onepiece/hud/barFrame02.vmt")
local barFrame03 = Material("nsc-onepiece/hud/barFrame03.vmt")
local healthBar01 = Material("nsc-onepiece/hud/healthBar01.vmt")
local manaBar01 = Material("nsc-onepiece/hud/manaBar01.vmt")
local hungerBar01 = Material("nsc-onepiece/hud/hungerBar01.vmt")

local f2, f4, f6 = Material("nsc-onepiece/hud/btn_F2.vmt"), Material("nsc-onepiece/hud/btn_F4.vmt"), Material("nsc-onepiece/hud/btn_F6.vmt")

local skillRect = Material("nsc-onepiece/hud/skillRect.vmt")
local skillRectActive = Material("nsc-onepiece/hud/skillRect_Active.vmt")
local skillRectCooldown = Material("nsc-onepiece/hud/skillRect_Cooldown.vmt")
local skillRectActiveCooldown = Material("nsc-onepiece/hud/skillRect_Active_Cooldown.vmt")

local buffBorder = Material("nsc-onepiece/hud/buffBorder.vmt")

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

function NSCOP.FightingStance:DrawPlayerData()
    hudLeftPartX = 20
    hudLeftPartH = ScrH() - 270

    self:DrawAvatarBorderTopPiece()
	self:DrawAvatar()
	self:DrawAvatarBorderBottomPiece()
	self:DrawBorderDecoration()
	self:DrawBars()
	self:DrawNickname()
    self:DrawHelperButtons()
end

---#region Bars

function NSCOP.FightingStance:DrawBars()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local x, h = hudLeftPartX, hudLeftPartH

	self:DrawHealthBar( screenScaleW(hudLeftPartX + 110), h + screenScaleH(20) )
    self:DrawManaBar( screenScaleW(hudLeftPartX + 90), h + screenScaleH(59) )
    self:DrawHungerBar( screenScaleW(hudLeftPartX + 70), h + screenScaleH(98) )
end

function NSCOP.FightingStance:DrawNickname()
	local nickX = screenScaleW(hudLeftPartX + 180)
	local nickY = hudLeftPartH + screenScaleH(32)

	local nickname = string.sub( self:GetOwner():GetName(), 0, NSCOP.Config.HUD.NicknameCharacterLimit )

	NSCOP.Utils.DrawRotatedText(nickname, "NSCOP_Main_Small", nickX, nickY, color_white, -5, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, outlineColor)
end

local oldHp = 0

function NSCOP.FightingStance:DrawHealthBar(x, y)
	local owner = self:GetOwner()
	--

    
    surface.SetDrawColor(0, 0, 0, 200)
	surface.SetMaterial(healthBar01)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))

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

	local maskWidth = screenScaleW(412)

	local newHp = Lerp( FrameTime() * 10, oldHp, ( hp / maxHp ) * maskWidth )
    oldHp = newHp

    draw.NoTexture()
	surface.SetMaterial(matNull) -- We need to use this, so the mask becomes transparent. I didn't find another solution
	surface.DrawTexturedRect(x + screenScaleW(50), y, math.Clamp( newHp, 24, maskWidth ), screenScaleH(100))
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

local oldMana = 0

function NSCOP.FightingStance:DrawManaBar(x, y)
	local owner = self:GetOwner()
	--

    
    surface.SetDrawColor(0, 0, 0, 200)
	surface.SetMaterial(manaBar01)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))

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
    if ( oldMana == 0 ) then
        oldMana = hp
    end

	local maskWidth = screenScaleW(412)

	local newMana = Lerp( FrameTime() * 10, oldMana, ( hp / maxHp ) * maskWidth )
    oldMana = newMana

    draw.NoTexture()
	surface.SetMaterial(matNull) -- We need to use this, so the mask becomes transparent. I didn't find another solution
	surface.DrawTexturedRect(x + screenScaleW(50), y, math.Clamp( newMana, 24, maskWidth ), screenScaleH(100))
	draw.NoTexture()

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(manaBar01)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))

	render.SetStencilEnable(false)
	--

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(barFrame02)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))
end

local oldHunger = 0

function NSCOP.FightingStance:DrawHungerBar(x, y)
	local owner = self:GetOwner()
	--

    
    surface.SetDrawColor(0, 0, 0, 200)
	surface.SetMaterial(hungerBar01)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))

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
    if ( oldHunger == 0 ) then
        oldHunger = hp
    end

	local maskWidth = screenScaleW(412)

	local newMana = Lerp( FrameTime() * 10, oldHunger, ( hp / maxHp ) * maskWidth )
    oldHunger = newMana

    draw.NoTexture()
	surface.SetMaterial(matNull) -- We need to use this, so the mask becomes transparent. I didn't find another solution
	surface.DrawTexturedRect(x + screenScaleW(50), y, math.Clamp( newMana, 24, maskWidth ), screenScaleH(100))
	draw.NoTexture()

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(hungerBar01)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))

	render.SetStencilEnable(false)
	--

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(barFrame03)
	surface.DrawTexturedRect(x, y, screenScaleW(512), screenScaleH(128))
end

---#endregion

---#region Avatar

function NSCOP.FightingStance:DrawAvatarBorderBottomPiece()
	local avatarSize = screenScaleW(256)
	local avatarX = screenScaleW(hudLeftPartX)
	local avatarY = hudLeftPartH

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(avatarBorderBottomPiece)
	surface.DrawTexturedRect(avatarX, avatarY, avatarSize, avatarSize)
end

function NSCOP.FightingStance:DrawAvatarBorderTopPiece()
	local avatarSize = screenScaleW(256)
	local avatarX = screenScaleW(hudLeftPartX)
	local avatarY = hudLeftPartH

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(avatarBorderTopPiece)
	surface.DrawTexturedRect(avatarX, avatarY, avatarSize, avatarSize)
end

function NSCOP.FightingStance:DrawBorderDecoration()
	local width, height = screenScaleW(512), screenScaleH(128)
	local decoX = screenScaleW(hudLeftPartX + 115)
	local decoY = hudLeftPartH - screenScaleH(12)

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

	local avatarRadius = screenScaleW(90)
	local avatarX = screenScaleW(hudLeftPartX + 40)
	local avatarY = hudLeftPartH + screenScaleH(120)

	if ! IsValid(self.PlayerAvatar) then
		self.PlayerAvatar = vgui.Create("DModelPanel")
		self.PlayerAvatar:SetModel(owner:GetModel())
		self.PlayerAvatar:SetFOV(25)
		self.PlayerAvatar:SetCamPos(avatarCamPos)
		self.PlayerAvatar:SetLookAt(avatarLookAt)
		self.PlayerAvatar:SetPos(avatarX * 0.9, avatarY - avatarRadius * 3)
		self.PlayerAvatar:SetSize(avatarRadius * 2.1, avatarRadius * 4)
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

        draw.NoTexture()
		surface.SetMaterial(matNull) -- We need to use this, so the mask becomes transparent. I didn't find another solution
		NSCOP.Utils.DrawCircle(avatarX + avatarRadius, avatarY, avatarRadius, 32)
		surface.DrawTexturedRect(avatarX, avatarY - avatarRadius * 2, avatarRadius * 2, avatarRadius * 2)
		draw.NoTexture()

		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

		surface.SetDrawColor(255, 255, 255, 255)
		self.PlayerAvatar:SetPaintedManually(false)
		self.PlayerAvatar:PaintManual()
		self.PlayerAvatar:SetPaintedManually(true)

		render.SetStencilEnable(false)
	end
end

---#endregion

---#region Helper Buttons

function NSCOP.FightingStance:DrawHelperButtons()
	local f2helperX, f2helperY = screenScaleW(hudLeftPartX + 210), hudLeftPartH + screenScaleH(188)
    local f4helperX, f4helperY = screenScaleW(hudLeftPartX + 335), hudLeftPartH + screenScaleH(180)
    local f6helperX, f6helperY = screenScaleW(hudLeftPartX + 455), hudLeftPartH + screenScaleH(172.5)

    -- Draw the icons
    local iconW, iconH = screenScaleW(32), screenScaleH(32)
    
    --F2
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(f2)
	surface.DrawTexturedRect(f2helperX, f2helperY, iconW, iconH)
    --F4
    surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(f4)
	surface.DrawTexturedRect(f4helperX, f4helperY, iconW, iconH)
    --F6
    surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(f6)
	surface.DrawTexturedRect(f6helperX, f6helperY, iconW, iconH)

    -- Draw the text
    local tilt = -3

    --F2 Text
	NSCOP.Utils.DrawRotatedText("Inventaire", "NSCOP_Main_VerySmall", f2helperX, f2helperY + screenScaleH(-3), color_white, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, outlineColor)
    --F4 Text
    NSCOP.Utils.DrawRotatedText("Capacités", "NSCOP_Main_VerySmall", f4helperX, f4helperY + screenScaleH(-3), color_white, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, outlineColor)
    --F6 Text
    NSCOP.Utils.DrawRotatedText("Carte", "NSCOP_Main_VerySmall", f6helperX + screenScaleW(16), f6helperY + screenScaleH(-3), color_white, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, outlineColor)
end

---#endregion