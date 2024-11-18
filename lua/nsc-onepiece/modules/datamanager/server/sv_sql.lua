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
	ActiveSkillTable = "nscop_character_active_skill",
	ItemTable = "nscop_item",
}

-- TODO: Start using enum table keys
-- TODO: Add more types

---Creates the database if it doesn't exist
---<br>REALM: SERVER
---@param shouldDropFirst? boolean Whether to drop the database first
function SQL.CreateDB(shouldDropFirst)
	if sql.TableExists(NSCOP.SQLTable.PlayerTable) then
		-- Drop all tables if we want to, so that we don't have to manually delete the database and forget stuff
		if NSCOP.DebugMode() and shouldDropFirst then
			sql.Query("DROP TABLE IF EXISTS nscop_player")
			sql.Query("DROP TABLE IF EXISTS nscop_character")
			sql.Query("DROP TABLE IF EXISTS nscop_character_inventory")
			sql.Query("DROP TABLE IF EXISTS nscop_character_skill")
			sql.Query("DROP TABLE IF EXISTS nscop_item")
			sql.Query("DROP TABLE IF EXISTS nscop_character_active_skill")

			NSCOP.PrintDebug("DATABASE DROPPED")
		end

		if not shouldDropFirst then
			NSCOP.PrintDebug("DATABASE ALREADY EXISTS")
			return;
		end
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
			"ring_id"	INTEGER,
			"necklace_id"	INTEGER,
			"chest_id"	INTEGER,
			"gloves_id"	INTEGER,
			"legs_id"	INTEGER,
			"boots_id"	INTEGER,
			"weapon_id"	INTEGER,
			"hat_id"	INTEGER,
			PRIMARY KEY("id" AUTOINCREMENT),
			FOREIGN KEY("player_id") REFERENCES "nscop_player"("id") ON DELETE CASCADE
		)
	]])

	sql.Query([[
		CREATE TABLE "nscop_character_inventory" (
			"id"	INTEGER NOT NULL,
			"character_id"	INTEGER NOT NULL,
			"item_id"	INTEGER NOT NULL,
			"slot"	INTEGER NOT NULL,
			PRIMARY KEY("id" AUTOINCREMENT),
			FOREIGN KEY("character_id") REFERENCES "nscop_character"("id") ON DELETE CASCADE
		)
	]])

	sql.Query([[
		CREATE TABLE IF NOT EXISTS "nscop_character_skill" (
			"id"	INTEGER NOT NULL,
			"character_id"	INTEGER NOT NULL,
			"skill_id"	INTEGER NOT NULL UNIQUE,
			PRIMARY KEY("id" AUTOINCREMENT),
			FOREIGN KEY("character_id") REFERENCES "nscop_character"("id") ON DELETE CASCADE
		)
	]])

	sql.Query([[
		CREATE TABLE IF NOT EXISTS "nscop_item" (
			"id"	INTEGER NOT NULL,
			"type"	INTEGER NOT NULL,
			"rarity"	INTEGER NOT NULL,
			"amount"	INTEGER NOT NULL,
			"x"	INTEGER NULL,
			"y"	INTEGER NULL,
			"z"	INTEGER NULL,
			"character_bound" INTEGER NOT NULL,
			PRIMARY KEY("id" AUTOINCREMENT)
		)
	]])

	sql.Query([[
		CREATE TABLE "nscop_character_active_skill" (
			"id"	INTEGER NOT NULL,
			"character_id"	INTEGER NOT NULL,
			"skill_id"	INTEGER NOT NULL,
			"button_type"	INTEGER NOT NULL,
			PRIMARY KEY("id" AUTOINCREMENT),
			FOREIGN KEY("character_id") REFERENCES "nscop_character"("id") ON DELETE CASCADE
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
		NSCOP.Error("Failed to get player id for steam id: ", steamId64)
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
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to get character ids for player id: ", playerId)
	end

	if result == nil then
		NSCOP.PrintDebug("No character ids found for player id: ", playerId)
		return
	end

	local characterIds = {}
	for _, row in ipairs(result) do
		table.insert(characterIds, tonumber(row.id))
	end

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
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to get character data for character id: ", characterId)
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
		RingId = dbData.ring_id,
		NecklaceId = dbData.necklace_id,
		ChestId = dbData.chest_id,
		GlovesId = dbData.gloves_id,
		LegsId = dbData.legs_id,
		BootsId = dbData.boots_id,
		WeaponId = dbData.weapon_id,
		HatId = dbData.hat_id,
		Inventory = {},
		Skills = {},
		ActiveSkills = {}
	}

	return characterData
end

---Gets the inventory data from the player
---<br>REALM: SERVER
---@param characterId integer The character id to get the inventory data from
---@return integer[]? inventoryData The inventory data or nil if not found
function SQL.GetCharacterInventoryData(characterId)
	SQL.EnableForeignKeys()

	local query = "SELECT item_id FROM nscop_character_inventory WHERE character_id = " .. SQL.Str(characterId)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to get inventory data for character id: ", characterId)
	end

	if result == nil then
		NSCOP.PrintDebug("No inventory data found for character id: ", characterId)
		return {}
	end

	local inventoryData = {}
	for _, row in ipairs(result) do
		table.insert(inventoryData, tonumber(row.item_id))
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
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to get skills data for character id: ", characterId)
	end

	if result == nil then
		NSCOP.PrintDebug("No skills data found for character id: ", characterId)
		return {}
	end

	local skillsData = {}
	for _, row in ipairs(result) do
		table.insert(skillsData, tonumber(row.skill_id))
	end

	return skillsData
end

function SQL.GetCharacterActiveSkillsData(characterId)
	SQL.EnableForeignKeys()

	local query = "SELECT skill_id, button_type FROM nscop_character_active_skill WHERE character_id = " .. SQL.Str(characterId)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to get active skills data for character id: ", characterId)
	end

	if result == nil then
		NSCOP.PrintDebug("No active skills data found for character id: ", characterId)
		return {}
	end

	local activeSkillsData = {}
	for _, row in ipairs(result) do
		table.insert(activeSkillsData, tonumber(row.skill_id))
	end

	return activeSkillsData
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
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to update player id for steam id: ", steamId64)
	end

	local newPlayerId = tonumber(sql.Query("SELECT last_insert_rowid() AS last_id")[1].last_id)

	return newPlayerId
end

---Updates the character data for the player's current character
---<br>REALM: SERVER
---@param ply Player The player to update the data for
---@return integer? newCharacterId The character id, nil if failed
function SQL.UpdateCharacter(ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.Error("Failed updating character, player does not have player data: ", ply)
	end

	local playerId = ply.NSCOP.PlayerData.PlayerId
	if not playerId then return end

	local characterId = ply.NSCOP.PlayerData.CharacterId
	if not characterId then return end

	SQL.EnableForeignKeys()

	if characterId <= 0 then
		local query = string.format([[
				INSERT INTO nscop_character (player_id, name, hair_type, nose_type, eye_type, eyebrow_type, mouth_type, skin_color, hair_color, eye_color, size, outfit, race, profession, class, level, experience, skill_points, money, ring_id, necklace_id, chest_id, gloves_id, legs_id, boots_id, weapon_id, hat_id)
				VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
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
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.RingId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.NecklaceId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.ChestId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.GlovesId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.LegsId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.BootsId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.WeaponId),
			SQL.Str(ply.NSCOP.PlayerData.CharacterData.HatId)
		)

		local result = sql.Query(query)

		if result == false then
			SQL.DebugPrintQuery(query, true)
			NSCOP.Error("Failed to insert character data for player id: ", playerId)
		end

		-- Gets the last inserted row id, which is the character id, because we just inserted a new character
		local newCharacterId = tonumber(sql.Query("SELECT last_insert_rowid() AS last_id")[1].last_id)

		return newCharacterId
	end

	local query = string.format([[
		REPLACE INTO nscop_character (id, player_id, name, hair_type, nose_type, eye_type, eyebrow_type, mouth_type, skin_color, hair_color, eye_color, size, outfit, race, profession, class, level, experience, skill_points, money, ring_id, necklace_id, chest_id, gloves_id, legs_id, boots_id, weapon_id, hat_id)
		VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
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
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.RingId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.NecklaceId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.ChestId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.GlovesId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.LegsId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.BootsId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.WeaponId),
		SQL.Str(ply.NSCOP.PlayerData.CharacterData.HatId)
	)

	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to update character data for player id: ", playerId)
	end
end

-- TODO: Optimize
---Updates the inventory for the player's current character. Note this is slow, because it deletes all the inventory and reinserts it.
---<br>REALM: SERVER
---@param ply Player The player to update the inventory for
function SQL.UpdateInventory(ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.Error("Failed updating inventory, player does not have player data: ", ply)
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
		SQL.DebugPrintQuery(deleteQuery, true)
		NSCOP.Error("Failed to delete inventory for player id: ", playerId)
	end

	local insertResult = nil

	-- Insert new inventory items
	for slot, item in ipairs(inventory) do
		local query = string.format([[
				INSERT INTO nscop_character_inventory (character_id, item_id, slot)
				VALUES (%s, %s, %s)
			]],
			SQL.Str(characterId),
			SQL.Str(slot), -- TODO: Finish item system
			SQL.Str(slot) -- TODO: Not sure if this should be the index of the item in the inventory
		)
		insertResult = sql.Query(query)
	end

	if insertResult == false then
		SQL.DebugPrintQuery([[
				INSERT INTO nscop_character_inventory (character_id, item_id, slot)
				VALUES (%s, %s, %s)
		]], true)
		NSCOP.Error("Failed to update inventory for player id: ", playerId)
		return
	end

	sql.Commit()
end

---Adds an item to the player's current character's inventory
---<br>REALM: SERVER
---@param characterId integer The character id to add the item for
---@param itemId integer The item id to add
---@param slot integer The slot to add the item to
function SQL.AddInventoryItem(characterId, itemId, slot)
	SQL.EnableForeignKeys()

	local query = string.format([[
		INSERT INTO nscop_character_inventory (character_id, item_id, slot)
		VALUES (%s, %s, %s)
	]],
		SQL.Str(characterId),
		SQL.Str(itemId),
		SQL.Str(slot)
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to add inventory item for character id: ", characterId)
	end
end

---Removes an item from the player's current character inventory
---<br>REALM: SERVER
---@param characterId integer The character id to remove the item for
---@param itemId integer The item id to remove
---@return boolean success Whether the item was removed successfully
function SQL.RemoveInventoryItem(characterId, itemId)
	SQL.EnableForeignKeys()

	local query = string.format([[
		DELETE FROM nscop_character_inventory
		WHERE character_id = %s AND item_id = %s
	]],
		SQL.Str(characterId),
		SQL.Str(itemId)
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to remove inventory item for character id: ", characterId)
		return false
	end

	return true
end

-- TODO: Optimize
---Updates the skills for the player's current character. Note this is slow, because it deletes all the skills and reinserts them.
---<br>REALM: SERVER
function SQL.UpdateSkills(ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.Error("Failed updating skills, player does not have player data: ", ply)
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
		SQL.DebugPrintQuery(deleteQuery, true)
		NSCOP.Error("Failed to delete skills for player id: ", playerId)
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
		SQL.DebugPrintQuery([[
			INSERT INTO nscop_character_skill (character_id, skill_id)
			VALUES (%d, %d)
		]], true)
		NSCOP.Error("Failed to update skills for player id: ", playerId)
	end

	sql.Commit()
end

---Adds a skill for the player's current character
---<br>REALM: SERVER
---@param characterId integer The character id to add the skill for
---@param skillId integer The skill id to add
function SQL.AddSkill(characterId, skillId)
	SQL.EnableForeignKeys()

	local query = string.format([[
		INSERT INTO nscop_character_skill (character_id, skill_id)
		VALUES (%d, %d)
	]],
		characterId,
		skillId
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to add skill for character id: ", characterId)
	end
end

---Removes a skill for the player's current character
---<br>REALM: SERVER
---@param characterId integer The character id to remove the skill for
---@param skillId integer The skill id to remove
---@return boolean success Whether the skill was removed successfully
function SQL.RemoveSkill(characterId, skillId)
	SQL.EnableForeignKeys()

	-- Active skills and skills are not connected by a foreign key as skill ids are not stored in the db, so we need to remove the skill from both tables
	SQL.RemoveSkillFromActiveBySkillId(characterId, skillId)

	local query = string.format([[
		DELETE FROM nscop_character_skill
		WHERE character_id = %d AND skill_id = %d
	]],
		characterId,
		skillId
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to remove skill for character id: ", characterId)
		return false
	end

	return true
end

---Updates the active skills for the player's current character. Note, this is slow as it deletes all the active skills and reinserts them.
---<br>REALM: SERVER
---@param characterId integer The character id to update the active skills for
---@param activeSkills integer[] The active skills to set
function SQL.UpdateActiveSkills(characterId, activeSkills)
	SQL.EnableForeignKeys()

	sql.Begin()

	-- Delete existing active skills for the character
	local deleteQuery = string.format([[DELETE FROM nscop_character_active_skill WHERE character_id = %s]], SQL.Str(characterId))
	local deleteResult = sql.Query(deleteQuery)

	if deleteResult == false then
		SQL.DebugPrintQuery(deleteQuery, true)
		NSCOP.Error("Failed to delete active skills for character id: ", characterId)
	end

	local insertResult = nil

	-- Insert new active skills
	for buttonType, skillId in pairs(activeSkills) do
		local query = string.format([[INSERT INTO nscop_character_active_skill (character_id, skill_id, button_type) VALUES (%s, %s, %s)]],
			SQL.Str(characterId),
			SQL.Str(skillId),
			SQL.Str(buttonType)
		)
		insertResult = sql.Query(query)
	end

	if insertResult == false then
		SQL.DebugPrintQuery([[INSERT INTO nscop_character_active_skill (character_id, skill_id, button_type) VALUES (%s, %s, %s)]], true)
		NSCOP.Error("Failed to update active skills for character id: ", characterId)
	end

	sql.Commit()
end

---Adds a skill to the player's current character's active skills and replaces the old skill on the buttonType
---<br>REALM: SERVER
---@param skillId integer The skill id to add
---@param characterId integer The character id to add the skill for
---@param buttonType NSCOP.ButtonType The button type to add the skill to
function SQL.AddSkillToActive(skillId, characterId, buttonType)
	SQL.EnableForeignKeys()

	local deleteQuery = string.format([[
		DELETE FROM nscop_character_active_skill WHERE character_id = %s AND button_type = %s
	]],
		SQL.Str(characterId),
		SQL.Str(buttonType)
	)

	local deleteResult = sql.Query(deleteQuery)

	if deleteResult == false then
		SQL.DebugPrintQuery(deleteQuery, true)
		NSCOP.Error("Failed to delete skill from active for character id: ", characterId)
	end

	local query = string.format([[
		INSERT INTO nscop_character_active_skill (skill_id, character_id, button_type)
		VALUES (%s, %s, %s)
	]],
		SQL.Str(skillId),
		SQL.Str(characterId),
		SQL.Str(buttonType)
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to add skill to active for character id: ", characterId)
	end
end

---Removes a skill from the player's current character's active skills by skill id
---<br>REALM: SERVER
---@param characterId integer The character id to remove the skill for
---@param skillId integer The skill id to remove
---@return boolean success Whether the skill was removed successfully
function SQL.RemoveSkillFromActiveBySkillId(characterId, skillId)
	SQL.EnableForeignKeys()

	local query = string.format([[
		DELETE FROM nscop_character_active_skill
		WHERE character_id = %s AND skill_id = %s
	]],
		SQL.Str(characterId),
		SQL.Str(skillId)
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to remove skill from active for character id: ", characterId)
		return false
	end

	return true
end

---Removes a skill from the player's current character's active skills by button type
---<br>REALM: SERVER
---@param characterId integer The character id to remove the skill for
---@param buttonType NSCOP.ButtonType The button type to remove the skill from
---@return boolean success Whether the skill was removed successfully
function SQL.RemoveSkillFromActiveByButton(characterId, buttonType)
	SQL.EnableForeignKeys()

	local query = string.format([[
		DELETE FROM nscop_character_active_skill
		WHERE character_id = %s AND button_type = %s
	]],
		SQL.Str(characterId),
		SQL.Str(buttonType)
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to remove skill from active for character id: ", characterId)
		return false
	end

	return true
end

---Updates the money for the player's current character
---<br>REALM: SERVER
---@param characterId integer The character id to update the money for
---@param money integer The money to set
function SQL.UpdateMoney(characterId, money)
	SQL.EnableForeignKeys()

	if characterId <= 0 then
		NSCOP.Error("Failed updating money, character id is invalid: ", characterId)
	end

	local query = string.format([[
		UPDATE nscop_character
		SET money = %s
		WHERE id = %s
	]],
		SQL.Str(money),
		SQL.Str(characterId)
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to update money for character id: ", characterId)
		return
	end
end

function SQL.UpdateExperience(characterId, experience)
	SQL.EnableForeignKeys()

	if characterId <= 0 then
		NSCOP.PrintDebug("Character id is invalid: ", characterId)
	end

	local query = string.format([[
		UPDATE nscop_character
		SET experience = %s
		WHERE id = %s
	]],
		SQL.Str(experience),
		SQL.Str(characterId)
	)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Failed to update experience for character id: ", characterId)
		return
	end
end

--#endregion

-- Create the server database
SQL.CreateDB();
