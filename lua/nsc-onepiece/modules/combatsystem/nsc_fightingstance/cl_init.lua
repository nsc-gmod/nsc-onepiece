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

local hudLeftPartX, hudLeftPartH = 20, 820

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

-- TODO: Optimize everything here in the future
-- TODOOO: The fucking HUD is for some reason broken on resolutions lower than 2K. im frustrated

function NSCOP.FightingStance:DrawHUD()
	self:DrawPlayerData()

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
