---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}

---@class NSCOP.DataManager
local DataManager = NSCOP.DataManager

---Gets the defaulty mapped controls
---<br>REALM: CLIENT
---@nodiscard
---@return NSCOP.Controls
function DataManager:GetDefaultControls()
	---@type NSCOP.Controls
	local controls = {
		[NSCOP.KeyActionType.SelectSkillOne] = KEY_0,
		[NSCOP.KeyActionType.SelectSkillTwo] = KEY_2,
		[NSCOP.KeyActionType.SelectSkillThree] = KEY_3,
		[NSCOP.KeyActionType.SelectSkillFour] = KEY_4,
		[NSCOP.KeyActionType.SelectSkillFive] = KEY_5,
		[NSCOP.KeyActionType.SelectSkillSix] = KEY_6,
		[NSCOP.KeyActionType.SkillDodge] = KEY_LALT,
		[NSCOP.KeyActionType.SkillUse] = MOUSE_RIGHT,
	}

	return controls
end

function DataManager:LoadControls()
	local ply = LocalPlayer()

	---@type NSCOP.Controls
	local data = ply:NSCOP_GetPlayerDbTable("NSCOP_Controls", self:GetDefaultControls())

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = data

	NSCOP.PrintDebug("Loaded controls for player: ", ply)
	PrintTable(data)
end

function DataManager:SaveControls()
	local ply = LocalPlayer()

	ply:SetPData("NSCOP_Controls", util.TableToJSON(ply.NSCOP.Controls))
end

NSCOP.Utils.AddHook("ClientSignOnStateChanged", "NSCOP.DataManager.ClientReady", function(userId, oldState, newState)
	if newState == SIGNONSTATE_FULL then
		net.Start("NSCOP.DataManager.ClientReady")
		net.SendToServer()

		DataManager:LoadControls()
	end
end)
