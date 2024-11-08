---The purpose of this module called "Initizalizer" is to create all of the meta shit used by other modules and code
---@class NSCOP
NSCOP = NSCOP or {}

CreateConVar("nsc_debug_debugmode", "0", { FCVAR_CHEAT, FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_PROTECTED },
	"[DEVELOPER] Debug Mode")

---Contains the definition of all modules
---@enum NSCOP.ModuleType
NSCOP.Modules = {
	Initializer = "initializer",
	Utils = "utils",
	CombatSystem = "combatsystem",
}

---Prints a message to the console with a [NSCOP] prefix
---@param ... any Arguments to print
function NSCOP.Print(...)
	print("[NSCOP]", ...)
end

---Prints a message to the console with a [NSCOP] prefix if debug mode is enabled
---@param ...any Arguments to print
function NSCOP.PrintDebug(...)
	if not NSCOP.DebugMode() then return end

	print("[NSCOP Debug]", ...)
end

local debugConVar = GetConVar("nsc_debug_debugmode")
---Returns true if Debug Mode is enabled
---<br>REALM: SHARED
---@return boolean
function NSCOP.DebugMode()
	return debugConVar:GetInt() == 1
end

---Includes a shared file on the server and client
---<br>REALM: SHARED
---@param path string The path to include
function NSCOP.IncludeShared(path)
	if SERVER then
		AddCSLuaFile(path)
	end
	include(path)
	NSCOP.PrintDebug("included: " .. path)
end

---Includes the file on the client realm
---<br>REALM: SHARED
---@param path string The path to include
function NSCOP.IncludeClient(path)
	if CLIENT then
		include(path)
		NSCOP.PrintDebug("included: " .. path)
	else
		AddCSLuaFile(path)
	end
end

---Includes the file on the server realm
---<br>REALM: SHARED
---@param path string The path to include
function NSCOP.IncludeServer(path)
	if SERVER then
		include(path)
		NSCOP.PrintDebug("included: " .. path)
	end
end

---Includes a module, should be used in a shared file
---<br>REALM: SHARED
---@param module NSCOP.ModuleType Module name
function NSCOP.IncludeModule(module)
	NSCOP.IncludeShared("nsc-onepiece/modules/" .. module .. "/" .. module .. ".lua")
end

---Prints the current file in a nicely formatted way
---<br>REALM: SHARED
function NSCOP.PrintFileLoaded()
	local file = debug.getinfo(2, "S").source
	local fileName = string.match(file, "[^/]*.lua$")
	NSCOP.Print("loaded " .. fileName)
end
