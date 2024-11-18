---@param path string
function NSCOP.LoadSkill(path)
	NSCOP.IncludeShared(path .. "/shared.lua")
	NSCOP.IncludeServer(path .. "/server.lua")
	NSCOP.IncludeClient(path .. "/client.lua")
end

---@class Player
local MPlayer = FindMetaTable("Player")

-- TODO: Not the fastest way to get it, since it loops through all the controls, maybe this should be cached, or the controls should be a dictionary
---Gets the button type of the player from the button value
---<br>REALM: SHARED
---@param button NSCOP.ButtonValue
---@return NSCOP.ButtonType?
function MPlayer:GetButtonType(button)
	if not self.NSCOP or not self.NSCOP.Controls then
		NSCOP.PrintDebug("Player has no controls data")
		return
	end

	for key, value in ipairs(self.NSCOP.Controls) do
		---@cast key NSCOP.ButtonType
		---@cast value NSCOP.ButtonData
		if value.Button == button then
			return key
		end
	end
end

NSCOP.Utils.AddHook("PlayerButtonDown", "NSCOP.CombatSystem.PlayerButtonDown", function(ply, button)
	if not ply:IsValid() then return end

	local weapon = ply:GetActiveWeapon()
	if not weapon:IsValid() then return end
	if not weapon:NSCOP_IsCombatSWEP() then return end
	---@cast weapon NSCOP.FightingStance

	local actionType = ply:GetButtonType(button)
	---@type NSCOP.ButtonData?
	local buttonData = ply.NSCOP.Controls[actionType]

	if buttonData then
		local oldState = buttonData.State
		buttonData.State = NSCOP.ButtonState.Pressed
		buttonData.StateTime = CurTime()

		NSCOP.Utils.RunHook("NSCOP.ButtonStateChanged", buttonData, oldState, buttonData.State)
		oldState = buttonData.State

		timer.Simple(0, function()
			if not ply:IsValid() then return end
			if buttonData.State != NSCOP.ButtonState.Pressed then return end

			if buttonData then
				buttonData.State = NSCOP.ButtonState.Down
				buttonData.StateTime = CurTime()

				NSCOP.Utils.RunHook("NSCOP.ButtonStateChanged", buttonData, oldState, buttonData.State)
			end
		end)
	end

	if actionType == NSCOP.ButtonType.SelectSkillOne then
		weapon:SetSelectedSkill(1)
	elseif actionType == NSCOP.ButtonType.SelectSkillTwo then
		weapon:SetSelectedSkill(2)
	elseif actionType == NSCOP.ButtonType.SelectSkillThree then
		weapon:SetSelectedSkill(3)
	elseif actionType == NSCOP.ButtonType.SelectSkillFour then
		weapon:SetSelectedSkill(4)
	elseif actionType == NSCOP.ButtonType.SelectSkillFive then
		weapon:SetSelectedSkill(5)
	elseif actionType == NSCOP.ButtonType.SelectSkillSix then
		weapon:SetSelectedSkill(6)
	end

	local dodgeButton = ply.NSCOP.Controls[NSCOP.ButtonType.SkillDodge]

	if button == KEY_SPACE and (dodgeButton.State == NSCOP.ButtonState.Down or dodgeButton.State == NSCOP.ButtonState.Pressed) then
		weapon:Dodge(true)
	end
end)

NSCOP.Utils.AddHook("PlayerButtonUp", "NSCOP.CombatSystem.PlayerButtonUp", function(ply, button)
	if not ply:IsValid() then return end

	local weapon = ply:GetActiveWeapon()
	if not weapon:IsValid() then return end
	if not weapon:NSCOP_IsCombatSWEP() then return end
	---@cast weapon NSCOP.FightingStance

	local actionType = ply:GetButtonType(button)
	---@type NSCOP.ButtonData?
	local buttonData = ply.NSCOP.Controls[actionType]

	if buttonData then
		local oldState = buttonData.State
		buttonData.State = NSCOP.ButtonState.Released
		buttonData.StateTime = CurTime()

		NSCOP.Utils.RunHook("NSCOP.ButtonStateChanged", buttonData, oldState, buttonData.State)
		oldState = buttonData.State

		timer.Simple(0, function()
			if not ply:IsValid() then return end
			if buttonData.State != NSCOP.ButtonState.Released then return end

			if buttonData then
				buttonData.State = NSCOP.ButtonState.Up
				buttonData.StateTime = CurTime()

				NSCOP.Utils.RunHook("NSCOP.ButtonStateChanged", buttonData, oldState, buttonData.State)
			end
		end)
	end

	if actionType == NSCOP.ButtonType.SkillDodge and not ply:KeyDown(IN_JUMP) then
		weapon:Dodge()
	end
end)

NSCOP.Utils.AddHook("NSCOP.ButtonStateChanged", "NSCOP.CombatSystem.ButtonStateChanged", function(buttonData, oldState, newState)
	if not buttonData then return end

	local oldStateName = ""
	local newStateName = ""

	for key, value in pairs(NSCOP.ButtonState) do
		if value == oldState then
			oldStateName = key
			break
		end
	end

	for key, value in pairs(NSCOP.ButtonState) do
		if value == newState then
			newStateName = key
			break
		end
	end

	NSCOP.PrintDebug("Button state changed: " .. " from " .. oldStateName .. " to " .. newStateName)
end)
