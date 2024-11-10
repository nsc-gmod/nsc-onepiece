---@class FightingStance: SWEP

local skillRect = Material("nsc-onepiece/hud/skillRect.vmt")
local skillRectActive = Material("nsc-onepiece/hud/skillRect_Active.vmt")

local screenScaleW = NSCOP.Utils.ScreenScaleW
local screenScaleH = NSCOP.Utils.ScreenScaleH

function FightingStance:DrawHUD()
	self:DrawSkills()

	surface.DrawLine(ScrW() / 2, ScrH(), ScrW() / 2, 0)
end

---Draws the skills on the HUD
function FightingStance:DrawSkills()
	local selectedSkill = self:GetSelectedSkill()

	for i = 1, 6, 1 do
		local margin = 70
		self:DrawSkill(screenScaleW(852.5, true) + screenScaleW((i - 1) * margin), screenScaleH(1050, true),
			i == selectedSkill)
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
