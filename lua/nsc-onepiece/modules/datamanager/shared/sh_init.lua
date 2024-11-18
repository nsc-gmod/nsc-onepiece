---@class NSCOP.DataManager
NSCOP.DataManager = NSCOP.DataManager or {}

---@class NSCOP.DataManager
local DataManager = NSCOP.DataManager

---@enum NSCOP.DataManager.NetworkMessage
NSCOP.DataManager.NetworkMessage = {
	SV_InitData = "NSCOP.DataManager.SV.InitData",
	SV_SyncData = "NSCOP.DataManager.SV.SyncData",
	SV_LevelUp = "NSCOP.DataManager.SV.LevelUp",
	CL_ClientReady = "NSCOP.DataManager.CL.ClientReady",
	CL_InitControls = "NSCOP.DataManager.CL.InitControls",
	CL_SyncControls = "NSCOP.DataManager.CL.SyncControls",
	CL_UpdateControlsKey = "NSCOP.DataManager.CL.UpdateControlsKey",
	CL_SpendPoint = "NSCOP.DataManager.CL.SpendPoint",
}

---@enum NSCOP.Race
NSCOP.Race = {
	None = 0,
	Human = 1,
	Skypiea = 2,
	Fishmen = 3
}

---@enum NSCOP.Profession
NSCOP.Profession = {
	None = 0,
	Pirate = 1,
	Marine = 2,
	Civil = 3
}

---@enum NSCOP.Class
NSCOP.Class = {
	None = 0,
	Swordsman = 1,
	Gunman = 2,
	Brawler = 3,
	Doctor = 4,
}

---@enum NSCOP.ButtonType
NSCOP.ButtonType = {
	SelectSkillOne = 1,
	SelectSkillTwo = 2,
	SelectSkillThree = 3,
	SelectSkillFour = 4,
	SelectSkillFive = 5,
	SelectSkillSix = 6,
	SkillDodge = 7,
	SkillUse = 8, -- Uses the selected skill 1 - 6
	InventoryMenu = 9,
	CharacterMenu = 10,
	MainMenu = 11,
	RadialMenu = 12,
	SkillMenu = 13,
	EmoteMenu = 14,
	ToggleCameraMode = 15,
}

---@enum NSCOP.ButtonState
NSCOP.KeyState = {
	Up = 0,
	Down = 1,
	Pressed = 2,
	Released = 3
}

---@enum NSCOP.BodyGroup
NSCOP.BodyGroup = {
	Hair = 0,
	Nose = 1,
	Eye = 2,
	Eyebrow = 3,
	Mouth = 4,
	Outfit = 5
}

---@class NSCOP.ButtonData
---@field Button NSCOP.ButtonValue
---@field State NSCOP.ButtonState
---@field StateTime number Time when the state changed

---@alias NSCOP.ButtonValue  MOUSE | KEY | JOYSTICK | integer
---@alias NSCOP.Controls {[NSCOP.ButtonType]:  NSCOP.ButtonData}

---@class NSCOP.CharacterData
---@field Name string
---@field HairType integer
---@field NoseType integer
---@field EyeType integer
---@field EyebrowType integer
---@field MouthType integer
---@field SkinColor integer
---@field HairColor integer
---@field EyeColor integer
---@field Size number
---@field Outfit integer
---@field Race NSCOP.Race
---@field Profession NSCOP.Profession
---@field Class NSCOP.Class
---@field Level integer
---@field Experience number
---@field SkillPoints integer
---@field Money integer
---@field RingId integer
---@field NecklaceId integer
---@field ChestId integer
---@field GlovesId integer
---@field LegsId integer
---@field BootsId integer
---@field WeaponId integer
---@field HatId integer
---@field Inventory integer[]
---@field Skills integer[]
---@field ActiveSkills integer[]

---@class NSCOP.PlayerData
---@field PlayerId integer
---@field CharacterId integer
---@field CharacterData NSCOP.CharacterData

---@class Player.NSCOP
---@field PlayerData? NSCOP.PlayerData
---@field Controls? NSCOP.Controls
---@field IFramesTime? number Invincibility frames time

---@class Player
---@field NSCOP? Player.NSCOP

---Reads sequential table data to the current net message
---<br>REALM: SHARED
---@param lengthBits integer
---@param keyBits integer
---@return integer[]
function DataManager.NetReadSequentialTable(lengthBits, keyBits)
	local length = net.ReadUInt(lengthBits)
	local data = {}

	for i = 1, length do
		data[i] = net.ReadUInt(keyBits)
	end

	return data
end

---Writes sequential table data to the current net message
---<br>REALM: SHARED
---@generic T : integer[]
---@param data T
---@param lengthBits integer
---@param keyBits integer
function DataManager.NetWriteSequentialTable(data, lengthBits, keyBits)
	local length = #data

	net.WriteUInt(length, lengthBits)
	for i = 1, length do
		net.WriteUInt(data[i], keyBits)
	end
end

---Gets the default data for the player
---<br>REALM: SHARED
---@nodiscard
---@return NSCOP.PlayerData
function DataManager.GetDefaultData()
	---@type NSCOP.PlayerData
	local playerData = {
		PlayerId = 0,
		CharacterId = 0,
		CharacterData = {
			Name = "",
			HairType = 0,
			NoseType = 0,
			EyeType = 0,
			EyebrowType = 0,
			MouthType = 0,
			SkinColor = 0,
			HairColor = 0,
			EyeColor = 0,
			Size = 1,
			Outfit = 0,
			Race = NSCOP.Race.None,
			Profession = NSCOP.Profession.None,
			Class = NSCOP.Class.None,
			Level = 1,
			Experience = 0,
			SkillPoints = 0,
			Money = 0,
			RingId = 0,
			NecklaceId = 0,
			ChestId = 0,
			GlovesId = 0,
			LegsId = 0,
			BootsId = 0,
			WeaponId = 0,
			HatId = 0,
			Inventory = {},
			Skills = {},
			ActiveSkills = {}
		},
	}

	-- Dummy data
	playerData.CharacterData.Name =
	"This is a supper super long dummy name which should never happen, but Lets test how heavy this can get "
	for i = 1, 200 do
		table.insert(playerData.CharacterData.Inventory, i)
	end

	for i = 1, 200 do
		table.insert(playerData.CharacterData.Skills, i)
	end

	for i = 1, 10 do
		table.insert(playerData.CharacterData.ActiveSkills, i)
	end

	return playerData
end

---Gets the defaulty mapped controls
---<br>REALM: SHARED
---@nodiscard
---@return NSCOP.Controls
function DataManager.GetDefaultControls()
	---@type NSCOP.Controls
	local controls = {
		[NSCOP.ButtonType.SelectSkillOne] = { Button = KEY_1, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.SelectSkillTwo] = { Button = KEY_2, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.SelectSkillThree] = { Button = KEY_3, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.SelectSkillFour] = { Button = KEY_4, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.SelectSkillFive] = { Button = KEY_5, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.SelectSkillSix] = { Button = KEY_6, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.SkillDodge] = { Button = KEY_LALT, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.SkillUse] = { Button = MOUSE_RIGHT, State = NSCOP.KeyState.Up, StateTime = 0 },
		[NSCOP.ButtonType.ToggleCameraMode] = { Button = KEY_BACKSLASH, State = NSCOP.KeyState.Up, StateTime = 0 },
	}

	return controls
end

---@class Player
local MPlayer = FindMetaTable("Player")

---Type safe way to get the player's string data
---<br>REALM: SHARED
---@param storeName NSCOP.DbDataKey
---@param defaultValue string
---@nodiscard
---@return string
function MPlayer:NSCOP_GetPlayerDbString(storeName, defaultValue)
	return self:GetPData(storeName, defaultValue)
end

---Type safe way to get the player's number data
---<br>REALM: SHARED
---@param storeName NSCOP.DbDataKey
---@param defaultValue number
---@nodiscard
---@return number
function MPlayer:NSCOP_GetPlayerDbNumber(storeName, defaultValue)
	local convertedDbData = tonumber(self:GetPData(storeName, defaultValue))

	if not convertedDbData then
		return defaultValue
	end

	return convertedDbData
end

---Type safe way to get the player's table data
---<br>REALM: SHARED
---@generic T : table
---@param storeName NSCOP.DbDataKey
---@param defaultValue T
---@nodiscard
---@return T
function MPlayer:NSCOP_GetPlayerDbTable(storeName, defaultValue)
	local dbData = self:GetPData(storeName)

	if not dbData then
		return defaultValue
	end

	return util.JSONToTable(dbData)
end

---Writes the controls data to the current net message
---<br>REALM: SHARED
---@param controlsData NSCOP.Controls
function DataManager.NetWriteControls(controlsData)
	local controlsLength = #controlsData

	net.WriteUInt(controlsLength, 6)
	for i = 1, controlsLength do
		---@type NSCOP.ButtonData
		local buttonData = controlsData[i]
		---@diagnostic disable-next-line: param-type-mismatch
		net.WriteUInt(buttonData.Button, 8)
	end

	NSCOP.PrintDebug("Controls data size", net.BytesWritten())
end

---Reads the controls data from the net message and returns it as controls table
---<br>REALM: SHARED
---@nodiscard
---@return NSCOP.Controls controls
function DataManager.NetReadControls()
	local controlsLength = net.ReadUInt(6)
	---@type NSCOP.Controls
	local controlsData = DataManager.GetDefaultControls()

	for i = 1, controlsLength do
		controlsData[i].Button = net.ReadUInt(8)
	end

	return controlsData
end

---Gets the experience required to level up
---<br>REALM: SHARED
---@param ply Player
---@return number xpToNextLevel
function DataManager.GetXpToNextLevel(ply)
	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.Error("Could not get xp to next level for player, player has no NSCOP data")
	end

	local initialXp = NSCOP.Config.Main.InitialXpToLevel or 100
	local xpPerLevel = NSCOP.Config.Main.XpPerLevel or 100
	local level = ply.NSCOP.PlayerData.CharacterData.Level or 1

	return initialXp + (xpPerLevel * (level - 1))
end

---Adds the xp to the player and levels up if the player has enough xp
---<br>REALM: SHARED
---@param ply Player
---@param xp number
function DataManager.AddXp(ply, xp)
	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.Error("Could not gain xp for player, player has no NSCOP data")
	end

	local xpToNextLevel = DataManager.GetXpToNextLevel(ply)
	local playerXp = ply.NSCOP.PlayerData.CharacterData.Experience
	local newXp = playerXp + xp

	ply.NSCOP.PlayerData.CharacterData.Experience = newXp

	if SERVER and newXp >= xpToNextLevel then
		DataManager.LevelUp(ply)
	end
end

---Substracts the xp from the player
---<br>REALM: SHARED
---@param ply Player
---@param xp number
function DataManager.SubstractXp(ply, xp)
	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.Error("Could not substract xp for player, player has no NSCOP data")
	end

	local playerXp = ply.NSCOP.PlayerData.CharacterData.Experience
	local newXp = math.max(playerXp - xp, 0)

	ply.NSCOP.PlayerData.CharacterData.Experience = newXp
end

--#region ConCommands

concommand.Add("nscop_nscopdata_" .. (SERVER and "sv" or "cl"), function(ply, cmd, args, argStr)
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

	if not ply.NSCOP then
		NSCOP.Error("Could not display data, player has no NSCOP data")
	end

	NSCOP.Print("NSCOP data for: ", ply:GetName())
	PrintTable(ply.NSCOP)
end, function(cmd, argStr, args)
	return NSCOP.Utils.GetPlayersAutocomplete("nscop_nscopdata_" .. (SERVER and "sv" or "cl"), cmd, argStr, args)
end)

concommand.Add("nscop_playerdata_" .. (SERVER and "sv" or "cl"), function(ply, cmd, args, argStr)
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

	if not ply.NSCOP then
		NSCOP.Error("Could not display data, player has no NSCOP data")
	end

	NSCOP.Print("Player data for: ", ply:GetName())
	PrintTable(ply.NSCOP.PlayerData)
end, function(cmd, argStr, args)
	return NSCOP.Utils.GetPlayersAutocomplete("nscop_playerdata_" .. (SERVER and "sv" or "cl"), cmd, argStr, args)
end)

concommand.Add("nscop_controls_" .. (SERVER and "sv" or "cl"), function(ply, cmd, args, argStr)
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

	if not ply.NSCOP then
		NSCOP.Error("Could not display data, player has no NSCOP data")
	end

	NSCOP.Print("Player controls for: ", ply:GetName())
	PrintTable(ply.NSCOP.Controls)
end, function(cmd, argStr, args)
	return NSCOP.Utils.GetPlayersAutocomplete("nscop_controls_" .. (SERVER and "sv" or "cl"), cmd, argStr, args)
end)

--#endregion
