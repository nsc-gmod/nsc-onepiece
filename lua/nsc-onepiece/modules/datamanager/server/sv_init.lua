---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}
NSCOP.DataManager.AutosaveEnabled = NSCOP.Utils.GetConfigValue("AutosaveEnabled", true)
NSCOP.DataManager.AutosaveInterval = NSCOP.Utils.GetConfigValue("AutosaveInterval", 300)
NSCOP.DataManager.AutosaveQueueTime = NSCOP.Utils.GetConfigValue("AutosaveQueueTime", 0.01)
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

---Writes the data of the player's character to the current net message
---<br>REALM: SERVER
---@param characterData NSCOP.CharacterData
function DataManager.NetWriteCharacterData(characterData)
	net.WriteString(characterData.Name)
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
	net.WriteUInt(characterData.Race, 2)
	net.WriteUInt(characterData.Profession, 2)
	net.WriteUInt(characterData.Class, 3)
	net.WriteUInt(characterData.Level, 10)
	net.WriteFloat(characterData.Experience)
	net.WriteUInt(characterData.SkillPoints, 8)
	net.WriteUInt(characterData.Money, 32)
	DataManager.NetWriteInventoryData(characterData.Inventory)
	DataManager.NetWriteSkillsData(characterData.Skills)

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
	local playerId = NSCOP.SQL.UpdatePlayerId(ply)

	if not playerId then
		NSCOP.PrintDebug("Failed to initialize data for player: ", ply)
		return
	end

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.PlayerData = DataManager.GetDefaultData()
	ply.NSCOP.PlayerData.PlayerId = playerId

	DataManager.SaveData(ply)

	net.Start(DataManager.NetworkMessage.SV_InitData)
	net.Send(ply)

	NSCOP.PrintDebug("Initialized data for player: ", ply)

	ply:NSCOP_LoadAppearance()
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

	-- Don't load data if the player already has them
	if not playerId then
		DataManager.InitData(ply)
		return
	end

	local characterId = NSCOP.SQL.GetCharacterIds(playerId)[1]
	local characterData = NSCOP.SQL.GetCharacterData(characterId)

	if not characterData then
		NSCOP.PrintDebug("Failed to load data for player: ", ply)
		return
	end

	local inventoryData = NSCOP.SQL.GetCharacterInventoryData(characterId)

	if not inventoryData then
		NSCOP.PrintDebug("Failed to load inventory data for player: ", ply)
		return
	end

	local skillsData = NSCOP.SQL.GetCharacterSkillsData(characterId)

	if not skillsData then
		NSCOP.PrintDebug("Failed to load skills data for player: ", ply)
		return
	end

	data.PlayerId = playerId
	data.CharacterId = characterId
	data.CharacterData = characterData

	ply.NSCOP = {}
	ply.NSCOP.PlayerData = data
	ply.NSCOP.PlayerData.CharacterData.Inventory = inventoryData
	ply.NSCOP.PlayerData.CharacterData.Skills = skillsData

	net.Start(DataManager.NetworkMessage.SV_SyncData)
	net.WriteUInt(data.CharacterId, 2)
	DataManager.NetWriteCharacterData(data.CharacterData)
	net.Send(ply)

	ply:NSCOP_LoadAppearance()

	NSCOP.PrintDebug("Loaded data for player: ", ply)
end

---Saves the data of the player to the database
---<br>REALM: SERVER
---@param ply Player
function DataManager.SaveData(ply)
	local newCharacterId = NSCOP.SQL.UpdateCharacter(ply)

	-- Updates the character id if a new character was created and saves inventory and skills
	if newCharacterId then
		ply.NSCOP.PlayerData.CharacterId = newCharacterId
	end

	if ply.NSCOP.PlayerData.CharacterId then
		NSCOP.SQL.UpdateInventory(ply)
		NSCOP.SQL.UpdateSkills(ply)

		NSCOP.PrintDebug("Updated inventory and skills for player: ", ply)
	end

	NSCOP.PrintDebug("Saved data for player: ", ply)
end

---Levels up the player
---<br>REALM: SERVER
---@param ply Player
---@param continuedLevelUp boolean? True if if the level up is a continuation of a previous level up. Should always be false when calling manually
function DataManager.LevelUp(ply, continuedLevelUp)
	if not ply.NSCOP then return end

	local playerXp = ply.NSCOP.PlayerData.CharacterData.Experience
	local xpToNextLevel = DataManager.GetXpToNextLevel(ply)

	if not playerXp then
		NSCOP.Error("Failed to level up, player does not have experience data")
	end

	if playerXp < xpToNextLevel then
		NSCOP.PrintDebug("Player does not have enough experience to level up")
		return
	end

	local skillPointPerLevel = NSCOP.Config.Main.SkillPointsPerLevel or 1

	ply.NSCOP.PlayerData.CharacterData.Level = ply.NSCOP.PlayerData.CharacterData.Level + 1
	ply.NSCOP.PlayerData.CharacterData.Experience = playerXp - xpToNextLevel
	ply.NSCOP.PlayerData.CharacterData.SkillPoints = ply.NSCOP.PlayerData.CharacterData.SkillPoints + skillPointPerLevel

	--- TODO: Simulate how heavy it would be for 100 players to level up every second, so we can determine if we should save to db right after levelling up

	net.Start(DataManager.NetworkMessage.SV_LevelUp)
	net.Send(ply)

	NSCOP.Utils.RunHook("NSCOP.PlayerLeveledUp", ply, ply.NSCOP.PlayerData.CharacterData.Level)

	NSCOP.PrintDebug("Player leveled up: ", ply)

	-- Level up again if player has enough experience
	DataManager.LevelUp(ply, true)
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
	-- print(DataManager.NextAutoSave - CurTime())
	if CurTime() < DataManager.NextAutoSave then return end

	local saveQueueTime = 0

	for _, ply in player.Iterator() do
		---@cast ply Player
		if not ply:IsValid() then continue end

		timer.Simple(saveQueueTime, function()
			if not ply:IsValid() then return end
			DataManager.SaveData(ply)
		end)

		saveQueueTime = saveQueueTime + DataManager.AutosaveQueueTime
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

	local oldValue = ply.NSCOP.Controls[key].Button
	ply.NSCOP.Controls[key].Button = newValue

	NSCOP.Utils.RunHook("NSCOP.ControlsUpdated", ply, key, oldValue, newValue)

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
