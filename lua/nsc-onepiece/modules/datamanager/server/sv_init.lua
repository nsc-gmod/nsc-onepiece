util.AddNetworkString("NSCOP.DataManager.ClientReady")

---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}
NSCOP.DataManager.AutosaveEnabled = NSCOP.Utils.GetConfigValue("AutosaveEnabled", true)
NSCOP.DataManager.AutosaveInterval = NSCOP.Utils.GetConfigValue("AutosaveInterval", 60)

---@class NSCOP.DataManager
local DataManager = NSCOP.DataManager

-- TODO: Might be better to switch to raw SQL in the future, but I'm not sure how well its going to be handled

---@alias NSCOP.DbDataKey
---| "NSCOP_CharacterId"
---| "NSCOP_CharacterData"
---| "NSCOP_Profession"
---| "NSCOP_Level"
---| "NSCOP_Experience"
---| "NSCOP_Money"
---| "NSCOP_Inventory"
---| "NSCOP_Skills"
---| "NSCOP_Controls"

---Creates the table for the data of the player
---@return NSCOP.PlayerData
function DataManager:GetDefaultData()
	---@type NSCOP.PlayerData
	local playerData = {
		CharacterId = -1,
		CharacterData = {
			HairType = 0,
			NoseType = 0,
			EyeType = 0,
			EyebrowType = 0,
			MouthType = 0,
			SkinColor = 0,
			HairColor = 0,
			EyeColor = 0,
			Size = 0,
			Outfit = 0
		},
		Profession = NSCOP.Profession.None,
		Level = 1,
		Experience = 0,
		Money = 0,
		Inventory = {},
		Skills = {}
	}

	return playerData
end

---Loads the data of the player and sends it to the client
---@param ply Player
function DataManager:LoadData(ply)
	local data = DataManager:GetDefaultData()

	data.CharacterId = ply:NSCOP_GetPlayerDbNumber("CharacterId", data.CharacterId)
	data.CharacterData = ply:NSCOP_GetPlayerDbTable("CharacterData", data.CharacterData)
	data.Profession = ply:NSCOP_GetPlayerDbNumber("Profession", data.Profession)
	data.Level = ply:NSCOP_GetPlayerDbNumber("Level", data.Level)
	data.Experience = ply:NSCOP_GetPlayerDbNumber("Experience", data.Experience)
	data.Money = ply:NSCOP_GetPlayerDbNumber("Money", data.Money)
	data.Inventory = ply:NSCOP_GetPlayerDbTable("Inventory", data.Inventory)
	data.Skills = ply:NSCOP_GetPlayerDbTable("Skills", data.Skills)

	ply.NSCOP = {
		PlayerData = data,
		Controls = {}
	}

	NSCOP.PrintDebug("Loaded data for player: ", ply)
	PrintTable(data)
end

---Saves the data of the player to the database
---@param ply Player
function DataManager:SaveData(ply)

end

local connectedPlayers = {}

NSCOP.Utils.AddHook("PlayerDisconnected", "NSCOP.DataManager.PlayerDisconnected", function(ply)
	if not ply:IsValid() then return end

	connectedPlayers[ply:SteamID64()] = nil
end)

-- TODO: Add custom hook for player joined
net.Receive("NSCOP.DataManager.ClientReady", function(len, ply)
	if not ply:IsValid() then return end

	local steamId64 = ply:SteamID64()
	if connectedPlayers[steamId64] then return end

	connectedPlayers[steamId64] = true

	NSCOP.PrintDebug("Player connected: ", ply)
	DataManager:LoadData(ply)
end)
