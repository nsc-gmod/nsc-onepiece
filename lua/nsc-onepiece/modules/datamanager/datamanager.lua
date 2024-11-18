-- The purpose of this module called "DataManger" is to manage all the player data

NSCOP.IncludeShared("shared/sh_sql.lua")
NSCOP.IncludeShared("shared/sh_init.lua")
NSCOP.IncludeServer("server/sv_sql.lua")
NSCOP.IncludeServer("server/sv_init.lua")
NSCOP.IncludeServer("client/cl_sql.lua")
NSCOP.IncludeClient("client/cl_init.lua")

NSCOP.PrintFileLoaded()
