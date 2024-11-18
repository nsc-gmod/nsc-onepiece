--#region Modules

-- Configure if you want to disable certain modules. True - Enabled, False - Disabled
NSCOP.Config.Main.ModulesEnabled[NSCOP.Modules.CombatSystem] = true -- The Combat System
NSCOP.Config.Main.ModulesEnabled[NSCOP.Modules.DataManager] = true  -- The DataManager System

--#endregion

--#region General

-- TODO: Should be probably moved to NSCOP.Config.DataManager

NSCOP.Config.Main.MaxLevel = 100
NSCOP.Config.Main.XpMultiplier = 1
NSCOP.Config.Main.InitialXpToLevel = 100
NSCOP.Config.Main.XpPerLevel = 100
NSCOP.Config.Main.SkillPointsPerLevel = 1

NSCOP.Config.Main.AutosaveEnabled = true
NSCOP.Config.Main.AutosaveInterval = 300
NSCOP.Config.Main.AutosaveQueueTime = 0.01 -- Time to wait before saving each player's data. Helps with performance and does not save every player in the same frame
--// Put the configurations you consider the main ones there

--#endregion

NSCOP.PrintDebug("CONFIG LOADED")
