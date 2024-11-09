---@class NSCOP.DataManager

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

---@enum NSCOP.KeyActionType
NSCOP.KeyActionType = {
	SelectSkillOne = 1,
	SelectSkillTwo = 2,
	SelectSkillThree = 3,
	SelectSkillFour = 4,
	SelectSkillFive = 5,
	SelectSkillSix = 6,
	SkillDodge = 7,
	SkillUse = 8,
}

---@alias NSCOP.Controls {[NSCOP.KeyActionType]: BUTTON_CODE | MOUSE | KEY | JOYSTICK | integer | number}

---@class NSCOP.CharacterData
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

---@class NSCOP.PlayerData
---@field CharacterId integer
---@field CharacterData NSCOP.CharacterData
---@field Profession NSCOP.Profession
---@field Level integer
---@field Experience number
---@field Money integer
---@field Inventory integer[]
---@field Skills integer[]

---@class Player.NSCOP
---@field PlayerData NSCOP.PlayerData
---@field Controls NSCOP.Controls

---@class Player
---@field NSCOP? Player.NSCOP

---@class Player
local MPlayer = FindMetaTable("Player")

---Type safe way to get the player's string data
---@param storeName NSCOP.DbDataKey
---@param defaultValue string
---@nodiscard
---@return string
function MPlayer:NSCOP_GetPlayerDbString(storeName, defaultValue)
	return self:GetPData(storeName, defaultValue)
end

---Type safe way to get the player's number data
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
