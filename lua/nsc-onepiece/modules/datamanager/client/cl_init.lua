---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}

---@class NSCOP.DataManager
local DataManager = NSCOP.DataManager

function DataManager:LoadControls()
	local ply = LocalPlayer()
	local defaultControls = self:GetDefaultControls()

	if ply.NSCOP then
		NSCOP.PrintDebug("Player already has controls: ", ply, "avoiding loading controls for performance reasons")
		return
	end

	local controlsExits = ply:GetPData("NSCOP_Controls", false)

	if not controlsExits then
		ply.NSCOP = ply.NSCOP or {}
		ply.NSCOP.Controls = defaultControls

		net.Start("NSCOP.DataManager.CL.InitControls")
		net.SendToServer()
		NSCOP.PrintDebug("Initialized controls for player: ", ply)
		return
	end

	---@type NSCOP.Controls
	local data = ply:NSCOP_GetPlayerDbTable("NSCOP_Controls", defaultControls)

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = data

	net.Start("NSCOP.DataManager.CL.SyncControls")
	DataManager:NetWriteControls(data)
	net.SendToServer()

	NSCOP.PrintDebug("Loaded controls for player: ", ply)
	PrintTable(data)
end

function DataManager:SaveControls()
	local ply = LocalPlayer()

	ply:SetPData("NSCOP_Controls", util.TableToJSON(ply.NSCOP.Controls))
end

---Updates the controls key with the new value
---<br>REALM: CLIENT
---@param key NSCOP.ButtonType?
---@param newValue NSCOP.ButtonValue?
function DataManager:UpdateControlsKey(key, newValue)
	local ply = LocalPlayer()

	if not key or key > 255 or key < 0 then
		NSCOP.PrintDebug("Key is invalid", key)
		return
	end

	if not newValue or newValue > 255 or newValue < 0 then
		NSCOP.PrintDebug("Value is invalid", newValue)
		return
	end

	if not ply.NSCOP or not ply.NSCOP.Controls then
		NSCOP.PrintDebug("Player has no controls data")
		return
	end

	if not ply.NSCOP.Controls[key] then
		NSCOP.PrintDebug("Invalid controls key: ", key)
		return
	end

	if ply.NSCOP.Controls[key] == newValue then
		NSCOP.PrintDebug("New value is the same as the old value")
		return
	end

	ply.NSCOP.Controls[key].Button = newValue

	net.Start("NSCOP.DataManager.CL.UpdateControlsKey")
	net.WriteUInt(key, 8)
	---@diagnostic disable-next-line: param-type-mismatch
	net.WriteUInt(newValue, 8)
	net.SendToServer()
end

---Reads the character data from the net message and returns it as characterData table
---<br>REALM: CLIENT
---@nodiscard
---@return NSCOP.CharacterData
function DataManager:NetReadCharacterData()
	---@type NSCOP.CharacterData
	local characterData = {
		HairType = net.ReadUInt(4),
		NoseType = net.ReadUInt(4),
		EyeType = net.ReadUInt(4),
		EyebrowType = net.ReadUInt(4),
		MouthType = net.ReadUInt(4),
		SkinColor = net.ReadUInt(4),
		HairColor = net.ReadUInt(4),
		EyeColor = net.ReadUInt(4),
		Size = net.ReadFloat(),
		Outfit = net.ReadUInt(5)
	}

	return characterData
end

---Reads the inventory data from the net message and returns an integer array
---<br>REALM: CLIENT
---@nodiscard
---@return integer[]
function DataManager:NetReadInventoryData()
	local inventoryLength = net.ReadUInt(16)
	local inventoryData = {}

	for i = 1, inventoryLength do
		inventoryData[i] = net.ReadUInt(16)
	end

	return inventoryData
end

---Reads the skills data from the net message and returns an integer array
---<br>REALM: CLIENT
---@nodiscard
---@return integer[]
function DataManager:NetReadSkillsData()
	local skillsLength = net.ReadUInt(16)
	local skillsData = {}

	for i = 1, skillsLength do
		skillsData[i] = net.ReadUInt(8)
	end

	return skillsData
end

---Reads the player data from the net message and returns it as playerData table
---<br>REALM: CLIENT
---@nodiscard
---@return NSCOP.PlayerData
function DataManager:NetReadPlayerData()
	---@type NSCOP.PlayerData
	local playerData = {
		CharacterId = net.ReadUInt(2),
		CharacterName = net.ReadString(),
		CharacterData = self:NetReadCharacterData(),
		Race = net.ReadUInt(2),
		Profession = net.ReadUInt(2),
		Class = net.ReadUInt(3),
		Level = net.ReadUInt(10),
		Experience = net.ReadFloat(),
		SkillPoints = net.ReadUInt(8),
		Money = net.ReadUInt(32),
		Inventory = self:NetReadInventoryData(),
		Skills = self:NetReadSkillsData(),
	}

	return playerData
end

NSCOP.Utils.AddHook("ClientSignOnStateChanged", "NSCOP.DataManager.ClientReady", function(userId, oldState, newState)
	if newState == SIGNONSTATE_FULL then
		NSCOP.Utils.RunHook("NSCOP.PlayerLoaded", LocalPlayer())
	end
end)

NSCOP.Utils.AddHook("NSCOP.PlayerLoaded", "NSCOP.DataManager.PlayerLoaded", function(ply)
	net.Start("NSCOP.DataManager.CL.ClientReady")
	net.SendToServer()

	DataManager:LoadControls()
end)

net.Receive("NSCOP.DataManager.SV.InitData", function()
	local ply = LocalPlayer()

	local defaultData = DataManager:GetDefaultData()
	local defaultControls = DataManager:GetDefaultControls()

	ply.NSCOP = {
		PlayerData = defaultData,
		Controls = defaultControls
	}

	NSCOP.PrintDebug("Initialized and loaded default data for player: ", ply:GetName())
end)

net.Receive("NSCOP.DataManager.SV.SyncData", function(len)
	---@type NSCOP.PlayerData
	local data = DataManager:NetReadPlayerData()

	NSCOP.PrintDebug("Net message size for key:", "NSCOP.DataManager.SyncData", len, "bits,", len / 8, "bytes",
		len / 8 / 1024, "KB")
	NSCOP.PrintDebug("Received data from server:")

	local ply = LocalPlayer()

	ply.NSCOP = {
		PlayerData = data,
		Controls = {}
	}
end)

--#region ConCommands

concommand.Add("nscop_update_controls_key_cl", function(ply, cmd, args, argStr)
	---@type NSCOP.ButtonType?
	local key = tonumber(args[1])
	---@type NSCOP.ButtonValue?
	local value = tonumber(args[2])

	if not ply:IsValid() then
		NSCOP.PrintDebug("You can only run this command as a player")
		return
	end

	if not ply:IsAdmin() then
		NSCOP.PrintDebug("You need to be an admin to run this command")
		return
	end

	DataManager:UpdateControlsKey(key, value)
end)

--#endregion
