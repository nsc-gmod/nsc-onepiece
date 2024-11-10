--#region Modules

-- Configure if you want to disable certain modules. True - Enabled, False - Disabled
NSCOP.Config.Main.ModulesEnabled[NSCOP.Modules.CombatSystem] = true -- The Combat System
NSCOP.Config.Main.ModulesEnabled[NSCOP.Modules.DataManager] = true  -- The DataManager System

--#endregion

--#region General

-- TODO: Should be probably moved to NSCOP.Config.DataManager
NSCOP.Config.Main.AutosaveEnabled = true
NSCOP.Config.Main.AutosaveInterval = 60
--// Put the configurations you consider the main ones there

--#endregion

NSCOP.PrintDebug("CONFIG LOADED")
