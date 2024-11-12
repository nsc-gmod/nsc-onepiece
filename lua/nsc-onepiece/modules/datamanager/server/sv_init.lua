---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}
NSCOP.DataManager.AutosaveEnabled = NSCOP.Utils.GetConfigValue("AutosaveEnabled", true)
NSCOP.DataManager.AutosaveInterval = NSCOP.Utils.GetConfigValue("AutosaveInterval", 300)
NSCOP.DataManager.NextAutoSave = CurTime() + NSCOP.DataManager.AutosaveInterval

---@class NSCOP.DataManager
local DataManager = NSCOP.DataManager

util.AddNetworkString(DataManager.NetworkMessage.CL_ClientReady)
util.AddNetworkString(DataManager.NetworkMessage.CL_InitControls)
util.AddNetworkString(DataManager.NetworkMessage.CL_SyncControls)
util.AddNetworkString(DataManager.NetworkMessage.CL_UpdateControlsKey)

util.AddNetworkString(DataManager.NetworkMessage.SV_InitData)
util.AddNetworkString(DataManager.NetworkMessage.SV_SyncData)

-- TODO: Might be better to switch to raw SQL in the future, but I'm not sure how well its going to be handled

---@alias NSCOP.DbDataKey
---| "NSCOP_CharacterId"
---| "NSCOP_CharacterName"
---| "NSCOP_CharacterData"
---| "NSCOP_Profession"
---| "NSCOP_Level"
---| "NSCOP_Experience"
---| "NSCOP_SkillPoints"
---| "NSCOP_Money"
---| "NSCOP_Inventory"
---| "NSCOP_Skills"
---| "NSCOP_Controls"

---Writes the data of the player to the current net message
---<br>REALM: SERVER
---@param characterData NSCOP.CharacterData
function DataManager.NetWriteCharacterData(characterData)
	net.WriteUInt(characterData.HairType, 4)
	net.WriteUInt(characterData.NoseType, 4)
	net.WriteUInt(characterData.EyeType, 4)
	net.WriteUInt(characterData.EyebrowType, 4)
	net.WriteUInt(characterData.MouthType, 4)
	net.WriteUInt(characterData.SkinColor, 4)
	net.WriteUInt(characterData.HairColor, 4)
	net.WriteUInt(characterData.EyeColor, 4)
	net.WriteFloat(characterData.Size)
	net.WriteUInt(characterData.Outfit, 5)
	NSCOP.PrintDebug("Character data size", net.BytesWritten())
end

---Writes the inventory data of the player to the current net message
---<br>REALM: SERVER
---@param inventoryData integer[]
function DataManager.NetWriteInventoryData(inventoryData)
	DataManager.NetWriteSequentialTable(inventoryData, 16, 16)

	NSCOP.PrintDebug("Inventory data size", net.BytesWritten())
end

---Writes the skills data of the player to the current net message
---<br>REALM: SERVER
---@param skillsData integer[]
function DataManager.NetWriteSkillsData(skillsData)
	DataManager.NetWriteSequentialTable(skillsData, 16, 8)

	NSCOP.PrintDebug("Skills data size", net.BytesWritten())
end

function DataManager.InitData(ply)
	NSCOP.SQL.UpdatePlayerId(ply)


	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.PlayerData = DataManager.GetDefaultData()

	net.Start(DataManager.NetworkMessage.SV_InitData)
	net.Send(ply)

	ply:NSCOP_LoadAppearance()

	NSCOP.PrintDebug("Initialized data for player: ", ply)
end

---Loads the data of the player and sends it to the client. This won't work if the client already has loaded data for performance reasons
---<br>REALM: SERVER
---@param ply Player
function DataManager.LoadData(ply)
	local data = DataManager.GetDefaultData()

	if ply.NSCOP then
		NSCOP.PrintDebug("Player already has data: ", ply, "avoiding loading data for performance reasons")
		return
	end

	local playerId = NSCOP.SQL.GetPlayerId(ply)

	-- TODO: Export to its own function
	-- Don't load data if the player already has them
	if not playerId then
		DataManager.InitData(ply)
		return
	end

	data.PlayerId = playerId
	data.CharacterId = ply:NSCOP_GetPlayerDbNumber("NSCOP_CharacterId", data.CharacterId)
	data.CharacterData = ply:NSCOP_GetPlayerDbTable("NSCOP_CharacterData", data.CharacterData)
	data.Profession = ply:NSCOP_GetPlayerDbNumber("NSCOP_Profession", data.Profession)
	data.Level = ply:NSCOP_GetPlayerDbNumber("NSCOP_Level", data.Level)
	data.Experience = ply:NSCOP_GetPlayerDbNumber("NSCOP_Experience", data.Experience)
	data.SkillPoints = ply:NSCOP_GetPlayerDbNumber("NSCOP_SkillPoints", data.SkillPoints)
	data.Money = ply:NSCOP_GetPlayerDbNumber("NSCOP_Money", data.Money)
	data.Inventory = ply:NSCOP_GetPlayerDbTable("NSCOP_Inventory", data.Inventory)
	data.Skills = ply:NSCOP_GetPlayerDbTable("NSCOP_Skills", data.Skills)

	ply.NSCOP = {}
	ply.NSCOP.PlayerData = data

	net.Start(DataManager.NetworkMessage.SV_SyncData)
	net.WriteUInt(data.CharacterId, 2)
	net.WriteString(data.CharacterName)
	DataManager.NetWriteCharacterData(data.CharacterData)
	net.WriteUInt(data.Race, 2)
	net.WriteUInt(data.Profession, 2)
	net.WriteUInt(data.Class, 3)
	net.WriteUInt(data.Level, 10)
	net.WriteFloat(data.Experience)
	net.WriteUInt(data.SkillPoints, 8)
	net.WriteUInt(data.Money, 32)
	DataManager.NetWriteInventoryData(data.Inventory)
	DataManager.NetWriteSkillsData(data.Skills)
	net.Send(ply)

	ply:NSCOP_LoadAppearance()

	NSCOP.PrintDebug("Loaded data for player: ", ply)
end

---Saves the data of the player to the database
---<br>REALM: SERVER
---@param ply Player
function DataManager.SaveData(ply)
	if not ply.NSCOP then
		NSCOP.PrintDebug("Player does not have the NSCOP table: ", ply)
		return
	end

	local data = ply.NSCOP.PlayerData

	if not data then
		NSCOP.PrintDebug("Player does not have data to save: ", ply)
		return
	end

	ply:SetPData("NSCOP_CharacterId", data.CharacterId)
	ply:SetPData("NSCOP_CharacterData", util.TableToJSON(data.CharacterData))
	ply:SetPData("NSCOP_Profession", data.Profession)
	ply:SetPData("NSCOP_Level", data.Level)
	ply:SetPData("NSCOP_Experience", data.Experience)
	ply:SetPData("NSCOP_SkillPoints", data.SkillPoints)
	ply:SetPData("NSCOP_Money", data.Money)
	ply:SetPData("NSCOP_Inventory", util.TableToJSON(data.Inventory))
	ply:SetPData("NSCOP_Skills", util.TableToJSON(data.Skills))

	NSCOP.PrintDebug("Saved data for player: ", ply)
end

-- A table of all players that have connected to the server, so we don't need to load data for them again
local loadedPlayers = {}

NSCOP.Utils.AddHook("NSCOP.PlayerLoaded", "NSCOP.DataManager.PlayerLoaded", function(ply)
	local steamId64 = ply:SteamID64()
	if loadedPlayers[steamId64] then return end

	loadedPlayers[steamId64] = true

	NSCOP.PrintDebug("Player loaded: ", ply)

	DataManager.LoadData(ply)
end)

NSCOP.Utils.AddHook("PlayerDisconnected", "NSCOP.DataManager.PlayerDisconnected", function(ply)
	if not ply:IsValid() then return end

	loadedPlayers[ply:SteamID64()] = nil
end)

NSCOP.Utils.AddHook("Tick", "NSCOP.DataManager.Autosave", function()
	if not DataManager.AutosaveEnabled then return end
	if CurTime() < DataManager.NextAutoSave then return end

	for _, ply in player.Iterator() do
		---@cast ply Player
		if not ply:IsValid() then continue end

		DataManager.SaveData(ply)
	end

	NSCOP.PrintDebug("Autosaved all player data")
	DataManager.NextAutoSave = CurTime() + DataManager.AutosaveInterval
end)

--#region NetReceiving

net.Receive(DataManager.NetworkMessage.CL_ClientReady, function(len, ply)
	if not ply:IsValid() then return end

	NSCOP.Utils.RunHook("NSCOP.PlayerLoaded", ply)
end)

net.Receive(DataManager.NetworkMessage.CL_InitControls, function(len, ply)
	if not ply:IsValid() then return end

	-- Do not initialize controls if the player already has them
	if ply.NSCOP and ply.NSCOP.Controls then return end

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = DataManager.GetDefaultControls()

	NSCOP.PrintDebug("Initialized controls for player: ", ply)
end)

net.Receive(DataManager.NetworkMessage.CL_SyncControls, function(len, ply)
	if not ply:IsValid() then return end

	-- Do not sync controls if the player already has them
	if ply.NSCOP and ply.NSCOP.Controls then return end

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = DataManager.NetReadControls()

	NSCOP.PrintDebug("Synced controls for player: ", ply)
end)

net.Receive(DataManager.NetworkMessage.CL_UpdateControlsKey, function(len, ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.Controls then
		NSCOP.PrintDebug("Player has no controls data")
		return
	end

	---@type NSCOP.ButtonType
	local key = net.ReadUInt(8)

	if not ply.NSCOP.Controls[key] then
		NSCOP.PrintDebug("Invalid controls key: ", key)
		return
	end

	---@type NSCOP.ButtonValue
	local newValue = net.ReadUInt(8)

	local oldValue = ply.NSCOP.Controls[key]
	ply.NSCOP.Controls[key].Button = newValue

	NSCOP.PrintDebug("Updated controls key for player: ", ply)
	NSCOP.PrintDebug("Key: ", key, "Old value: ", oldValue, "New value: ", newValue)
end)

--#endregion

--#region ConCommands

concommand.Add("nscop_savedata_sv", function(ply, cmd, args, argStr)
	if not ply:IsValid() then
		NSCOP.PrintDebug("You can only run this command as a player")
		return
	end

	if not ply:IsAdmin() then
		NSCOP.PrintDebug("You need to be an admin to run this command")
		return
	end

	if argStr then
		for _, currentPly in player.Iterator() do
			---@cast currentPly Player
			if currentPly:GetName():lower():StartsWith(argStr:lower()) then
				ply = currentPly
				break
			end
		end
	end

	DataManager.SaveData(ply)
end, function(cmd, argStr, args)
	return NSCOP.Utils.GetPlayersAutocomplete("nscop_savedata_" .. (SERVER and "sv" or "cl"), cmd, argStr, args)
end)

--#endregion
