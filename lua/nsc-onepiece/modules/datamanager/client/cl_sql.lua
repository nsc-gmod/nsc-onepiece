---@class NSCOP.SQL
NSCOP.SQL = NSCOP.SQL or {}

---@class NSCOP.SQL
local SQL = NSCOP.SQL


---@enum NSCOP.SQLTableCL
NSCOP.SQLTable = {
	ControlsTable = "nscop_controls"
}

---Creates the database if it doesn't exist
---<br>REALM: CLIENT
---@param shouldDropFirst? boolean Whether to drop the database first
function SQL.CreateDB(shouldDropFirst)
	if sql.TableExists(NSCOP.SQLTable.PlayerTable) then
		-- Drop all tables if we want to, so that we don't have to manually delete the database and forget stuff
		if NSCOP.DebugMode() and shouldDropFirst then
			sql.Query("DROP TABLE IF EXISTS nscop_controls")

			NSCOP.PrintDebug("DATABASE DROPPED")
		end

		if not shouldDropFirst then
			NSCOP.PrintDebug("DATABASE ALREADY EXISTS")
			return;
		end
	end

	SQL.EnableForeignKeys()

	sql.Query([[
		CREATE TABLE "nscop_controls" (
			"id"	INTEGER NOT NULL,
			"steam_id"	INTEGER NOT NULL,
			"button_type"	INTEGER NOT NULL,
			"button_value"	INTEGER,
			PRIMARY KEY("id" AUTOINCREMENT)
		)
	]])

	NSCOP.PrintDebug("DATABASE CREATED")
end

--#region Gets

---Returns the controls for the player by steamId64
---<br>REALM: CLIENT
---@param steamId SteamID64 The steamId64 of the player
---@return NSCOP.Controls playerControls The controls for the player
function SQL.GetControls(steamId)
	local query = "SELECT button_type, button_value FROM nscop_controls WHERE steam_id = " .. SQL.Str(steamId)
	local result = sql.Query(query)

	if result == false then
		SQL.DebugPrintQuery(query, true)
		NSCOP.Error("Error getting controls for player: ", steamId)
	end

	if result == nil then
		NSCOP.PrintDebug("No controls found for player: ", steamId)
		return {}
	end

	---@type NSCOP.Controls
	local controls = {}

	for _, row in ipairs(result) do
		controls[row.button_type] = {
			Button = row.button_value,
			State = NSCOP.ButtonState.Up,
			StateTime = 0
		}
	end

	return controls
end

--#endregion

-- Create the client database
SQL.CreateDB()
