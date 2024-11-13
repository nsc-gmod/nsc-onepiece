---@class NSCOP.SQL
NSCOP.SQL = NSCOP.SQL or {}

---@class NSCOP.SQL
local SQL = NSCOP.SQL

---@enum NSCOP.SQLTable
NSCOP.SQLTable = {
	PlayerTable = "nscop_player",
	CharacterTable = "nscop_character",
	InventoryTable = "nscop_character_inventory",
	SkillTable = "nscop_character_skill",
	ObjectTable = "nscop_object"
}

---Prints the query to the console, with an optional error message
---<br>REALM: SERVER
---@param query string The query to print
---@param isError boolean Whether the query is an error
function SQL.DebugPrintQuery(query, isError)
	NSCOP.PrintDebug("Query: ", query)

	if isError then
		NSCOP.PrintDebug("Error: ", sql.LastError())
	end
end

---Returns the SQL escaped string
---<br>REALM: SERVER
---@param value any The value to escape
function SQL.Str(value)
	local finalValue = value

	if istable(finalValue) then
		finalValue = util.TableToJSON(finalValue)
	end

	return SQLStr(finalValue)
end

---Enables foreign keys in the database
---<br>REALM: SERVER
function SQL.EnableForeignKeys()
	sql.Query("PRAGMA foreign_keys = ON;")
end

---Creates the database if it doesn't exist
---<br>REALM: SERVER
function SQL.CreateDB()
	if sql.TableExists(NSCOP.SQLTable.PlayerTable) then
		NSCOP.PrintDebug("DATABASE ALREADY EXISTS")
		return
	end

	sql.Begin()
	SQL.EnableForeignKeys()

	sql.Query([[
		CREATE TABLE IF NOT EXISTS nscop_player (
			"id"	INTEGER NOT NULL,
			"steam_id"	INTEGER UNIQUE,
			PRIMARY KEY("id" AUTOINCREMENT)
		)
	]])
	sql.Query([[
		CREATE TABLE IF NOT EXISTS "nscop_character" (
			"id"	INTEGER NOT NULL,
			"player_id"	INTEGER NOT NULL,
			"name"	TEXT NOT NULL,
			"hair_type"	INTEGER NOT NULL,
			"nose_type"	INTEGER NOT NULL,
			"eye_type"	INTEGER NOT NULL,
			"eyebrow_type"	INTEGER NOT NULL,
			"mouth_type"	INTEGER NOT NULL,
			"skin_color"	INTEGER NOT NULL,
			"hair_color"	INTEGER NOT NULL,
			"eye_color"	INTEGER NOT NULL,
			"size"	INTEGER NOT NULL,
			"outfit"	INTEGER NOT NULL,
			"race"	INTEGER NOT NULL,
			"profession"	INTEGER NOT NULL,
			"class"	INTEGER NOT NULL,
			"level"	INTEGER NOT NULL,
			"experience"	NUMERIC NOT NULL,
			"skill_points"	INTEGER NOT NULL,
			"money"	INTEGER NOT NULL,
			"active_skills"	TEXT NOT NULL,
			PRIMARY KEY("id" AUTOINCREMENT),
			FOREIGN KEY("player_id") REFERENCES "nscop_player"("id") ON DELETE CASCADE
		)
	]])

	sql.Query([[
		CREATE TABLE "nscop_character_inventory" (
			"id"	INTEGER NOT NULL,
			"character_id"	INTEGER NOT NULL,
			"object_id"	INTEGER NOT NULL,
			"order"	INTEGER NOT NULL,
			PRIMARY KEY("id" AUTOINCREMENT),
			FOREIGN KEY("character_id") REFERENCES "nscop_character"("id"),
		)
	]])

	sql.Query([[
		CREATE TABLE IF NOT EXISTS "nscop_character_skill" (
			"id"	INTEGER NOT NULL,
			"character_id"	INTEGER NOT NULL,
			"skill_id"	INTEGER NOT NULL,
			PRIMARY KEY("id" AUTOINCREMENT),
			FOREIGN KEY("character_id") REFERENCES "nscop_character"("id") ON DELETE CASCADE
		)
	]])

	sql.Query([[
		CREATE TABLE IF NOT EXISTS "nscop_object" (
			"id"	INTEGER NOT NULL,
			"type"	INTEGER NOT NULL,
			"rarity"	INTEGER NOT NULL,
			"x"	INTEGER NULL,
			"y"	INTEGER NULL,
			"z"	INTEGER NULL,
			PRIMARY KEY("id" AUTOINCREMENT)
		)
	]])
	sql.Commit()

	NSCOP.PrintDebug("DATABASE CREATED")
end

--#region Gets

---Gets the player id from the player
---<br>REALM: SERVER
---@param ply Player The player to get the id from
---@return integer? playerId The player id, 0 if not found, nil if failed
function SQL.GetPlayerId(ply)
	if not ply:IsValid() then return end
	local steamId64 = ply:SteamID64()

	if ply.NSCOP and ply.NSCOP.PlayerData and ply.NSCOP.PlayerData.PlayerId > 0 then
		return ply.NSCOP.PlayerData.PlayerId
	end

	SQL.EnableForeignKeys()

	local query = "SELECT * FROM nscop_player WHERE steam_id = " .. SQL.Str(steamId64)
	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to get player id for steam id: ", steamId64)
		return
	end

	if not result then
		NSCOP.PrintDebug("Player id not found for steam id: ", steamId64)
		return
	end

	return tonumber(result[1].id)
end

---Gets the character ids from the player
---<br>REALM: SERVER
---@param playerId integer The player id to get the character ids from
---@return integer[]? characterIds The charaterIds or nil if not found
function SQL.GetCharacterIds(playerId)
	local query = "SELECT id FROM nscop_character WHERE player_id = " .. SQL.Str(playerId)
	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to get character ids for player id: ", playerId)
		SQL.DebugPrintQuery(query, true)
		return
	end

	if result == nil then
		NSCOP.PrintDebug("No character ids found for player id: ", playerId)
		return
	end

	local characterIds = {}
	for _, row in ipairs(result) do
		table.insert(characterIds, tonumber(row.id))
	end

	PrintTable(characterIds)
	return characterIds
end

---Gets the character data from the player
---<br>REALM: SERVER
---@param characterId integer
---@return NSCOP.CharacterData? characterData The character data or nil if not found
function SQL.GetCharacterData(characterId)
	local query = "SELECT * FROM nscop_character WHERE id = " .. SQL.Str(characterId)
	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to get character data for character id: ", characterId)
		SQL.DebugPrintQuery(query, true)
		return
	end

	if result == nil then
		NSCOP.PrintDebug("No character data found for character id: ", characterId)
		return
	end
	local dbData = result[1]

	---@type NSCOP.CharacterData
	local characterData = {
		Name = dbData.name,
		HairType = dbData.hair_type,
		NoseType = dbData.nose_type,
		EyeType = dbData.eye_type,
		EyebrowType = dbData.eyebrow_type,
		MouthType = dbData.mouth_type,
		SkinColor = dbData.skin_color,
		HairColor = dbData.hair_color,
		EyeColor = dbData.eye_color,
		Size = dbData.size,
		Outfit = dbData.outfit,
		Race = dbData.race,
		Profession = dbData.profession,
		Class = dbData.class,
		Level = dbData.level,
		Experience = dbData.experience,
		SkillPoints = dbData.skill_points,
		Money = dbData.money,
		Inventory = {},
		Skills = {}
	}

	return characterData
end

---Gets the inventory data from the player
---<br>REALM: SERVER
---@param characterId integer The character id to get the inventory data from
---@return integer[]? inventoryData The inventory data or nil if not found
function SQL.GetCharacterInventoryData(characterId)
	SQL.EnableForeignKeys()

	local query = "SELECT object_id FROM nscop_character_inventory WHERE character_id = " .. SQL.Str(characterId)
	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to get inventory data for character id: ", characterId)
		SQL.DebugPrintQuery(query, true)
		return
	end

	if result == nil then
		NSCOP.PrintDebug("No inventory data found for character id: ", characterId)
		return
	end

	local inventoryData = {}
	for _, row in ipairs(result) do
		table.insert(inventoryData, tonumber(row.object_id))
	end

	return inventoryData
end

---Gets the skills data from the player
---<br>REALM: SERVER
---@param characterId integer The character id to get the skills data from
---@return integer[]? skillsData The skills data or nil if not found
function SQL.GetCharacterSkillsData(characterId)
	SQL.EnableForeignKeys()

	local query = "SELECT skill_id FROM nscop_character_skill WHERE character_id = " .. SQL.Str(characterId)
	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to get skills data for character id: ", characterId)
		SQL.DebugPrintQuery(query, true)
		return
	end

	if result == nil then
		NSCOP.PrintDebug("No skills data found for character id: ", characterId)
		return
	end

	local skillsData = {}
	for _, row in ipairs(result) do
		table.insert(skillsData, tonumber(row.skill_id))
	end

	return skillsData
end

--#endregion

--#region Updates

---Updates the player id for the player
---<br>REALM: SERVER
---@param ply Player The player to update the id for
---@return integer? newPlayerId The player id, nil if failed
function SQL.UpdatePlayerId(ply)
	if not ply:IsValid() then return end
	local steamId64 = ply:SteamID64()

	SQL.EnableForeignKeys()

	local query = "REPLACE INTO nscop_player (steam_id) VALUES (" .. SQL.Str(steamId64) .. ")"
	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to update player id for steam id: ", steamId64)
		SQL.DebugPrintQuery(query, true)
		return
	end

	local newPlayerId = tonumber(sql.Query("SELECT last_insert_rowid() AS last_id")[1].last_id)
	print(newPlayerId)

	return newPlayerId
end

---Updates the character data for the player's current character
---<br>REALM: SERVER
---@param ply Player The player to update the data for
---@return integer? newCharacterId The character id, nil if failed
function SQL.UpdateCharacter(ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.PrintDebug("Player does not have player data: ", ply)
		return
	end

	local playerId = ply.NSCOP.PlayerData.PlayerId
	if not playerId then return end

	local characterId = ply.NSCOP.PlayerData.CharacterId
	if not characterId then return end

	SQL.EnableForeignKeys()

	if characterId <= 0 then
		local query = string.format([[
				INSERT INTO nscop_character (player_id, name, hair_type, nose_type, eye_type, eyebrow_type, mouth_type, skin_color, hair_color, eye_color, size, outfit, race, profession, class, level, experience, skill_points, money, active_skills)
				VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
			]],
			SQL.Str(playerId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Name),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.HairType),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.NoseType),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.EyeType),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.EyebrowType),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.MouthType),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.SkinColor),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.HairColor),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.EyeColor),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Size),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Outfit),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Race),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Profession),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Class),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Level),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Experience),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.SkillPoints),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.Money),
			SQL.Str("") -- TODO: Finish active skills
		)

		local result = sql.Query(query)

		if result == false then
			NSCOP.PrintDebug("Failed to insert character data for player id: ", playerId)
			SQL.DebugPrintQuery(query, true)
			return
		end

		-- Gets the last inserted row id, which is the character id, because we just inserted a new character
		local newCharacterId = tonumber(sql.Query("SELECT last_insert_rowid() AS last_id")[1].last_id)

		return newCharacterId
	end

	local query = string.format([[
		REPLACE INTO nscop_character (id, player_id, name, hair_type, nose_type, eye_type, eyebrow_type, mouth_type, skin_color, hair_color, eye_color, size, outfit, race, profession, class, level, experience, skill_points, money, active_skills)
		VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
	]],
		SQL.Str(characterId),
		SQL.Str(playerId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Name),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.HairType),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.NoseType),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.EyeType),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.EyebrowType),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.MouthType),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.SkinColor),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.HairColor),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.EyeColor),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Size),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Outfit),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Race),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Profession),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Class),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Level),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Experience),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.SkillPoints),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.Money),
		SQL.Str("") -- TODO: Finish active skills
	)

	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to update character data for player id: ", playerId)
		SQL.DebugPrintQuery(query, true)
		return
	end
end

-- TODO: Optimize
---Updates the inventory for the player's current character. Note this is slow, because it deletes all the inventory and reinserts it.
---<br>REALM: SERVER
---@param ply Player The player to update the inventory for
function SQL.UpdateInventory(ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.PrintDebug("Player does not have player data: ", ply)
		return
	end

	local playerId = ply.NSCOP.PlayerData.PlayerId
	if not playerId then return end

	local characterId = ply.NSCOP.PlayerData.CharacterId
	if not characterId then return end

	local inventory = ply.NSCOP.PlayerData.CharacterData.Inventory

	sql.Begin()
	SQL.EnableForeignKeys()

	-- Delete existing inventory for the character
	local deleteQuery = "DELETE FROM nscop_character_inventory WHERE character_id = " .. SQL.Str(characterId)
	local deleteResult = sql.Query(deleteQuery)

	if deleteResult == false then
		NSCOP.PrintDebug("Failed to delete inventory for player id: ", playerId)
		SQL.DebugPrintQuery(deleteQuery, true)
		return
	end

	local insertResult = nil

	-- Insert new inventory items
	for order, item in ipairs(inventory) do
		local query = string.format([[
				INSERT INTO nscop_character_inventory (character_id, object_id, "order")
				VALUES (%d, %d, %d)
			]],
			characterId,
			order, -- TODO: Finish item system
			order -- TODO: Not sure if this should be the index of the item in the inventory
		)
		insertResult = sql.Query(query)
	end

	if insertResult == false then
		NSCOP.PrintDebug("Failed to update inventory for player id: ", playerId)
		SQL.DebugPrintQuery([[
			INSERT INTO nscop_character_inventory (character_id, object_id, "order")
			VALUES (%d, %d, %d)
		]], true)
		return
	end

	sql.Commit()
end

-- TODO: Optimize
---Updates the skills for the player's current character. Note this is slow, because it deletes all the skills and reinserts them.
---<br>REALM: SERVER
function SQL.UpdateSkills(ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.PrintDebug("Player does not have player data: ", ply)
		return
	end

	local playerId = ply.NSCOP.PlayerData.PlayerId
	if not playerId then return end

	local characterId = ply.NSCOP.PlayerData.CharacterId
	if not characterId then return end

	local skills = ply.NSCOP.PlayerData.CharacterData.Skills

	sql.Begin()
	SQL.EnableForeignKeys()

	-- Delete existing skills for the character
	local deleteQuery = "DELETE FROM nscop_character_skill WHERE character_id = " .. sql.SQLStr(characterId)
	local deleteResult = sql.Query(deleteQuery)

	if deleteResult == false then
		NSCOP.PrintDebug("Failed to delete skills for player id: ", playerId)
		SQL.DebugPrintQuery(deleteQuery, true)
		return
	end

	local insertResult = nil

	-- Insert new skills
	for _, skill in ipairs(skills) do
		local query = string.format([[
			INSERT INTO nscop_character_skill (character_id, skill_id)
			VALUES (%d, %d)
		]],
			characterId,
			skill
		)
		insertResult = sql.Query(query)
	end

	if insertResult == false then
		NSCOP.PrintDebug("Failed to update skills for player id: ", playerId)
		SQL.DebugPrintQuery([[
			INSERT INTO nscop_character_skill (character_id, skill_id)
			VALUES (%d, %d)
		]], true)
		return
	end

	sql.Commit()
end

--#endregion

-- Create the server database
SQL.CreateDB();
