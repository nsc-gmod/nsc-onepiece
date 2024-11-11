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

function SQL.CreateDB()
	if sql.TableExists(NSCOP.SQLTable.PlayerTable) then
		NSCOP.PrintDebug("DATABASE ALREADY EXISTS")
		return
	end

	sql.Query("PRAGMA foreign_keys = ON;")

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
			FOREIGN KEY("object_id") REFERENCES "nscop_object"("id") ON DELETE CASCADE
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

	NSCOP.PrintDebug("DATABASE CREATED")
end

--#region Gets

---Gets the player id from the player
---@param ply Player The player to get the id from
---@return integer? playerId The player id, 0 if not found, nil if failed
function SQL.GetPlayerId(ply)
	if not ply:IsValid() then return end
	local steamId64 = ply:SteamID64()

	local query = "SELECT id FROM nscop_player WHERE steam_id = " .. SQLStr(steamId64) .. ""
	local result = sql.Query(query)

	if not result then
		NSCOP.PrintDebug("Failed to get player id for steam id: ", steamId64)
		return
	end

	if #result == 0 then
		NSCOP.PrintDebug("Player id not found for steam id: ", steamId64)
		return
	end

	return tonumber(result[1].id)
end

---Gets the character ids from the player
---@param ply Player The player to get the data from
---@return integer[]? characterIds The charaterIds or nil if not found
function SQL.GetCharacterIds(ply)
	if not ply:IsValid() then return end

	if not ply.NSCOP or not ply.NSCOP.PlayerData then
		NSCOP.PrintDebug("Player does not have player data: ", ply)
		return
	end

	local playerId = ply.NSCOP.PlayerData.PlayerId
	if not playerId then return end

	local query = "SELECT id FROM nscop_character WHERE player_id = " .. SQLStr(tostring(playerId))
	local result = sql.Query(query)

	if result == false then
		NSCOP.PrintDebug("Failed to get character ids for player id: ", playerId)
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

	return characterIds
end

--#endregion

--#region Updates

function SQL.UpdatePlayerId(ply)
	if not ply:IsValid() then return end
	local steamId64 = ply:SteamID64()

	local query = "REPLACE INTO nscop_player (steam_id) VALUES (" .. SQLStr(steamId64) .. ")"
	sql.Query(query)
end

function SQL.UpdateCharacter(ply, characterData)
	if not ply:IsValid() then return end
end

--#endregion

SQL.CreateDB();
