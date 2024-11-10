util.AddNetworkString("NSCOP.DataManager.CL.ClientReady")
util.AddNetworkString("NSCOP.DataManager.CL.InitControls")
util.AddNetworkString("NSCOP.DataManager.CL.SyncControls")
util.AddNetworkString("NSCOP.DataManager.CL.UpdateControlsKey")

util.AddNetworkString("NSCOP.DataManager.SV.InitData")
util.AddNetworkString("NSCOP.DataManager.SV.SyncData")

---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}
NSCOP.DataManager.AutosaveEnabled = NSCOP.Utils.GetConfigValue("AutosaveEnabled", true)
NSCOP.DataManager.AutosaveInterval = NSCOP.Utils.GetConfigValue("AutosaveInterval", 60)

---@class NSCOP.DataManager
local DataManager = NSCOP.DataManager

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
---@param characterData NSCOP.CharacterData
function DataManager:NetWriteCharacterData(characterData)
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
---@param inventoryData integer[]
function DataManager:NetWriteInventoryData(inventoryData)
	local inventoryLength = #inventoryData

	net.WriteUInt(inventoryLength, 16)
	for i = 1, inventoryLength do
		net.WriteUInt(inventoryData[i], 16)
	end

	NSCOP.PrintDebug("Inventory data size", net.BytesWritten())
end

---Writes the skills data of the player to the current net message
---@param skillsData integer[]
function DataManager:NetWriteSkillsData(skillsData)
	local skillsLength = #skillsData

	net.WriteUInt(skillsLength, 16)
	for i = 1, skillsLength do
		net.WriteUInt(skillsData[i], 8)
	end

	NSCOP.PrintDebug("Skills data size", net.BytesWritten())
end

---Loads the data of the player and sends it to the client. This won't work if the client already has loaded data for performance reasons
---<br>REALM: SERVER
---@param ply Player
function DataManager:LoadData(ply)
	local data = DataManager:GetDefaultData()

	if ply.NSCOP then
		NSCOP.PrintDebug("Player already has data: ", ply, "avoiding loading data for performance reasons")
		return
	end

	local playerExists = ply:GetPData("NSCOP_CharacterId", false)

	-- Don't load data if the player already has data
	if not playerExists then
		ply.NSCOP = {
			PlayerData = data,
		}

		net.Start("NSCOP.DataManager.SV.InitData")
		net.Send(ply)

		NSCOP.PrintDebug("Initialized data for player: ", ply)
		return
	end

	data.CharacterId = ply:NSCOP_GetPlayerDbNumber("NSCOP_CharacterId", data.CharacterId)
	data.CharacterData = ply:NSCOP_GetPlayerDbTable("NSCOP_CharacterData", data.CharacterData)
	data.Profession = ply:NSCOP_GetPlayerDbNumber("NSCOP_Profession", data.Profession)
	data.Level = ply:NSCOP_GetPlayerDbNumber("NSCOP_Level", data.Level)
	data.Experience = ply:NSCOP_GetPlayerDbNumber("NSCOP_Experience", data.Experience)
	data.SkillPoints = ply:NSCOP_GetPlayerDbNumber("NSCOP_SkillPoints", data.SkillPoints)
	data.Money = ply:NSCOP_GetPlayerDbNumber("NSCOP_Money", data.Money)
	data.Inventory = ply:NSCOP_GetPlayerDbTable("NSCOP_Inventory", data.Inventory)
	data.Skills = ply:NSCOP_GetPlayerDbTable("NSCOP_Skills", data.Skills)

	ply.NSCOP = {
		PlayerData = data,
	}

	NSCOP.PrintDebug("Loaded data for player: ", ply)

	net.Start("NSCOP.DataManager.SV.SyncData")
	net.WriteUInt(data.CharacterId, 2)
	net.WriteString(data.CharacterName)
	DataManager:NetWriteCharacterData(data.CharacterData)
	net.WriteUInt(data.Race, 2)
	net.WriteUInt(data.Profession, 2)
	net.WriteUInt(data.Class, 3)
	net.WriteUInt(data.Level, 10)
	net.WriteFloat(data.Experience)
	net.WriteUInt(data.SkillPoints, 8)
	net.WriteUInt(data.Money, 32)
	DataManager:NetWriteInventoryData(data.Inventory)
	DataManager:NetWriteSkillsData(data.Skills)
	net.Send(ply)
end

---Saves the data of the player to the database
---@param ply Player
function DataManager:SaveData(ply)

end

local connectedPlayers = {}

NSCOP.Utils.AddHook("NSCOP.PlayerLoaded", "NSCOP.DataManager.PlayerLoaded", function(ply)
	local steamId64 = ply:SteamID64()
	if connectedPlayers[steamId64] then return end

	connectedPlayers[steamId64] = true

	NSCOP.PrintDebug("Player loaded: ", ply)

	DataManager:LoadData(ply)
end)

NSCOP.Utils.AddHook("PlayerDisconnected", "NSCOP.DataManager.PlayerDisconnected", function(ply)
	if not ply:IsValid() then return end

	connectedPlayers[ply:SteamID64()] = nil
end)

net.Receive("NSCOP.DataManager.CL.ClientReady", function(len, ply)
	if not ply:IsValid() then return end

	NSCOP.Utils.RunHook("NSCOP.PlayerLoaded", ply)
end)

net.Receive("NSCOP.DataManager.CL.InitControls", function(len, ply)
	if not ply:IsValid() then return end

	-- Do not initialize controls if the player already has them
	if ply.NSCOP and ply.NSCOP.Controls then return end

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = DataManager:GetDefaultControls()

	NSCOP.PrintDebug("Initialized controls for player: ", ply)
end)

net.Receive("NSCOP.DataManager.CL.SyncControls", function(len, ply)
	if not ply:IsValid() then return end

	-- Do not sync controls if the player already has them
	if ply.NSCOP and ply.NSCOP.Controls then return end

	ply.NSCOP = ply.NSCOP or {}
	ply.NSCOP.Controls = DataManager:NetReadControls()

	NSCOP.PrintDebug("Synced controls for player: ", ply)
end)

net.Receive("NSCOP.DataManager.CL.UpdateControlsKey", function(len, ply)
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
