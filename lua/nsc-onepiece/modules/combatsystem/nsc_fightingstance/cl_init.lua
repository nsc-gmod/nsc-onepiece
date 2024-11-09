---@class FightingStance: SWEP

local skillRect = Material("nsc-onepiece/hud/skillRect.vmt")
local skillRectActive = Material("nsc-onepiece/hud/skillRect_Active.vmt")

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

function FightingStance:DrawHUD()
	self:DrawSkills()
end

---Draws the skills on the HUD
function FightingStance:DrawSkills()
	local selectedSkill = self:GetSelectedSkill()

	for i = 1, 6, 1 do
		self:DrawSkill(screenScaleW(700 + (i - 1) * 90), screenScaleH(1050), i == selectedSkill)
	end
end

function FightingStance:DrawSkill(x, y, active)
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
function FightingStance:HUDShouldDraw(element)
	local isInCombatStance = self:GetCombatStance()

	if isInCombatStance and element == "CHudWeaponSelection" then
		return false
	end

	return true
end
