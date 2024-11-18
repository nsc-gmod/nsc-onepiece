--#region Modules

-- Configure if you want to disable certain modules. True - Enabled, False - Disabled
NSCOP.Config.Main.ModulesEnabled[NSCOP.Modules.CombatSystem] = true -- The Combat System
NSCOP.Config.Main.ModulesEnabled[NSCOP.Modules.DataManager] = true  -- The DataManager System

--#endregion

--#region General

-- TODO: Should be probably moved to NSCOP.Config.DataManager

NSCOP.Config.Main.MaxLevel = 100 -- The maximum level a player can reach
NSCOP.Config.Main.XpMultiplier = 1 -- The multiplier for the XP gained
NSCOP.Config.Main.InitialXpToLevel = 100 -- The initial XP needed to level up
NSCOP.Config.Main.XpPerLevel = 100 -- The XP needed to level up for each level after the initial one. This adds up per level
NSCOP.Config.Main.SkillPointsPerLevel = 1 -- The amount of skill points a player gets per level

NSCOP.Config.Main.AutosaveEnabled = true -- Enable or disable the autosave feature
NSCOP.Config.Main.AutosaveInterval = 300 -- The interval in seconds between each autosave
NSCOP.Config.Main.AutosaveQueueTime = 0.01 -- Time to wait before saving each player's data. Helps with performance and does not save every player in the same frame


--#endregion

NSCOP.PrintDebug("CONFIG LOADED")
