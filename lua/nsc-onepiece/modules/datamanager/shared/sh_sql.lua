---@class NSCOP.SQL
NSCOP.SQL = NSCOP.SQL or {}

---@class NSCOP.SQL
local SQL = NSCOP.SQL

---Prints the query to the console, with an optional error message
---<br>REALM: SERVER
---@param query string The query to print
---@param isError boolean Whether the query is an error
function SQL.DebugPrintQuery(query, isError)
	NSCOP.PrintDebug("Query: ", query)

	if isError then
		NSCOP.Error("Error: ", sql.LastError())
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
