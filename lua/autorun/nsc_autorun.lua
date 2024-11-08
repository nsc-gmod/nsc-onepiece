print("misha belov")

-- Include the "Initializer" module, which will handle most of the including
if SERVER then
	AddCSLuaFile("nsc-onepiece/modules/initializer/initializer.lua")
end
include("nsc-onepiece/modules/initializer/initializer.lua")

NSCOP.PrintFileLoaded()
