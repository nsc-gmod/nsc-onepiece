---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}

---@class NSCOP.DataManager
local DataManager = NSCOP.DataManager

-- TODO: Finish porting controls to sql table

function DataManager.InitControls()
	local ply = LocalPlayer()

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = DataManager.GetDefaultControls()

	net.Start(DataManager.NetworkMessage.CL_InitControls)
	net.SendToServer()

	NSCOP.PrintDebug("Initialized controls for player: ", ply)
end

---Loads the controls for the player and syncs them with the server
---<br>REALM: CLIENT
function DataManager.LoadControls()
	local ply = LocalPlayer()
	local defaultControls = DataManager.GetDefaultControls()

	if ply.NSCOP then
		NSCOP.PrintDebug("Player already has controls: ", ply, "avoiding loading controls for performance reasons")
		return
	end

	local controlsExits = ply:GetPData("NSCOP_Controls", false)

	if not controlsExits then
		DataManager.InitControls()
	end

	---@type NSCOP.Controls
	local data = ply:NSCOP_GetPlayerDbTable("NSCOP_Controls", defaultControls)

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = data

	net.Start(DataManager.NetworkMessage.CL_SyncControls)
	DataManager.NetWriteControls(data)
	net.SendToServer()

	NSCOP.PrintDebug("Loaded controls for player: ", ply)
end

function DataManager.SaveControls()
	local ply = LocalPlayer()

	ply:SetPData("NSCOP_Controls", util.TableToJSON(ply.NSCOP.Controls))
end

---Updates the controls key with the new value
---<br>REALM: CLIENT
---@param key NSCOP.ButtonType?
---@param newValue NSCOP.ButtonValue?
function DataManager.UpdateControlsKey(key, newValue)
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

	if ply.NSCOP.Controls[key].Button == newValue then
		NSCOP.PrintDebug("New value is the same as the old value")
		return
	end

	local oldValue = ply.NSCOP.Controls[key].Button
	ply.NSCOP.Controls[key].Button = newValue

	net.Start(DataManager.NetworkMessage.CL_UpdateControlsKey)
	net.WriteUInt(key, 8)
	---@diagnostic disable-next-line: param-type-mismatch
	net.WriteUInt(newValue, 8)
	net.SendToServer()

	DataManager.SaveControls()

	NSCOP.Utils.RunHook("NSCOP.ControlsUpdated", ply, key, oldValue, newValue)
end

---Reads the character data from the net message and returns it as characterData table
---<br>REALM: CLIENT
---@nodiscard
---@return NSCOP.CharacterData
function DataManager.NetReadCharacterData()
	---@type NSCOP.CharacterData
	local characterData = {
		Name = net.ReadString(),
		HairType = net.ReadUInt(4),
		NoseType = net.ReadUInt(4),
		EyeType = net.ReadUInt(4),
		EyebrowType = net.ReadUInt(4),
		MouthType = net.ReadUInt(4),
		SkinColor = net.ReadUInt(4),
		HairColor = net.ReadUInt(4),
		EyeColor = net.ReadUInt(4),
		Size = net.ReadFloat(),
		Outfit = net.ReadUInt(5),
		Race = net.ReadUInt(2),
		Profession = net.ReadUInt(2),
		Class = net.ReadUInt(3),
		Level = net.ReadUInt(10),
		Experience = net.ReadFloat(),
		SkillPoints = net.ReadUInt(8),
		Money = net.ReadUInt(32),
		RingId = net.ReadUInt(32),
		NecklaceId = net.ReadUInt(32),
		ChestId = net.ReadUInt(32),
		GlovesId = net.ReadUInt(32),
		LegsId = net.ReadUInt(32),
		BootsId = net.ReadUInt(32),
		WeaponId = net.ReadUInt(32),
		HatId = net.ReadUInt(32),
		Inventory = DataManager.NetReadInventoryData(),
		Skills = DataManager.NetReadSkillsData(),
		ActiveSkills = DataManager.NetReadActiveSkillsData(),
	}

	return characterData
end

---Reads the inventory data from the net message and returns an integer array
---<br>REALM: CLIENT
---@nodiscard
---@return integer[]
function DataManager.NetReadInventoryData()
	return DataManager.NetReadSequentialTable(16, 16)
end

---Reads the skills data from the net message and returns an integer array
---<br>REALM: CLIENT
---@nodiscard
---@return integer[]
function DataManager.NetReadSkillsData()
	return DataManager.NetReadSequentialTable(16, 8)
end

---Reads the active skills data from the net message and returns an integer array
---<br>REALM: CLIENT
---@nodiscard
---@return integer[]
function DataManager.NetReadActiveSkillsData()
	return DataManager.NetReadSequentialTable(4, 8)
end

---Reads the player data from the net message and returns it as playerData table
---<br>REALM: CLIENT
---@nodiscard
---@return NSCOP.PlayerData
function DataManager.NetReadPlayerData()
	---@type NSCOP.PlayerData
	local playerData = {
		PlayerId = -1,
		CharacterId = net.ReadUInt(2),
		CharacterData = DataManager.NetReadCharacterData(),
	}

	return playerData
end

NSCOP.Utils.AddHook("ClientSignOnStateChanged", "NSCOP.DataManager.ClientReady", function(userId, oldState, newState)
	if newState == SIGNONSTATE_FULL then
		NSCOP.Utils.RunHook("NSCOP.PlayerLoaded", LocalPlayer())
	end
end)

NSCOP.Utils.AddHook("NSCOP.PlayerLoaded", "NSCOP.DataManager.PlayerLoaded", function(ply)
	net.Start(DataManager.NetworkMessage.CL_ClientReady)
	net.SendToServer()

	DataManager.LoadControls()
end)

net.Receive(DataManager.NetworkMessage.SV_InitData, function()
	local ply = LocalPlayer()

	local defaultData = DataManager.GetDefaultData()
	local defaultControls = DataManager.GetDefaultControls()

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.PlayerData = defaultData
	ply.NSCOP.Controls = defaultControls

	NSCOP.PrintDebug("Initialized and loaded default data for player: ", ply:GetName())

	ply:NSCOP_LoadAppearance()
end)

net.Receive(DataManager.NetworkMessage.SV_SyncData, function(len)
	---@type NSCOP.PlayerData
	local data = DataManager.NetReadPlayerData()

	NSCOP.PrintDebug("Net message size for key:", "NSCOP.DataManager.SyncData", len, "bits,", len / 8, "bytes",
		len / 8 / 1024, "KB")
	NSCOP.PrintDebug("Received data from server:")

	local ply = LocalPlayer()

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.PlayerData = data

	ply:NSCOP_LoadAppearance()
end)

net.Receive(DataManager.NetworkMessage.SV_LevelUp, function(len)
	local ply = LocalPlayer()

	local xpToNextLevel = DataManager.GetXpToNextLevel(ply)
	local playerXp = ply.NSCOP.PlayerData.CharacterData.Experience
	local skillPointPerLevel = NSCOP.Config.Main.SkillPointsPerLevel or 1

	ply.NSCOP.PlayerData.CharacterData.Level = ply.NSCOP.PlayerData.CharacterData.Level + 1
	ply.NSCOP.PlayerData.CharacterData.Experience = playerXp - xpToNextLevel
	ply.NSCOP.PlayerData.CharacterData.SkillPoints = ply.NSCOP.PlayerData.CharacterData.SkillPoints + skillPointPerLevel

	NSCOP.PrintDebug("Player leveled up to level: ", ply.NSCOP.PlayerData.CharacterData.Level)
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

	DataManager.UpdateControlsKey(key, value)
end)

--#endregion
