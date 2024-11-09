NSCOP.Utils.AddHook("PlayerButtonDown", "NSCOP.CombatSystem.PlayerButtonDown", function(ply, button)
	if not ply:IsValid() then return end

	local weapon = ply:GetActiveWeapon()
	if not weapon:IsValid() then return end
	if not weapon:NSCOP_IsCombatSWEP() then return end
	---@cast weapon FightingStance

	-- TODO: Pretty experimental, I'm not sure if its going to be like this
	if button == KEY_1 then
		weapon:SetSelectedSkill(1)
	elseif button == KEY_2 then
		weapon:SetSelectedSkill(2)
	elseif button == KEY_3 then
		weapon:SetSelectedSkill(3)
	elseif button == KEY_4 then
		weapon:SetSelectedSkill(4)
	elseif button == KEY_5 then
		weapon:SetSelectedSkill(5)
	elseif button == KEY_6 then
		weapon:SetSelectedSkill(6)
	end

	ply:ChatPrint("Selected skill: " .. weapon:GetSelectedSkill())
end)
