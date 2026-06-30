--[[
    <PrephsFramework_Core/data/constants.lua>
    Copyright (C) <2026> <JulianStiebler / Prephmage>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    -- Additional Metadata --
    Author:  <JulianStiebler / Prephmage>
    Contact: <Discord: stiebulator>
    GitHub: https://github.com/JulianStiebler/PrephsFramework
--]]
---@meta _
local addonName, ns = ...

---@class PrephsFramework
local Core = ns.PF

---@class ConstantTable
local Constants = Core.Constants or {}

--[[
=============================================================================
Initialize empty tables for constants. These will be populated in the following sections.
=============================================================================
]]
---@type VersionTable
Constants.Version = Constants.Version or {}

---@type ENUMTable
Constants.ENUM = Constants.ENUM or {}

---@alias Bitmask integer
---@type Bitmask

---@type BitmaskTable
Constants.Bitmasks = Constants.Bitmasks or {}


--[[
=============================================================================
Local references to constant tables for more performant access at callsite.
=============================================================================
]]

---@class VersionTable
---@field IsClassic boolean True if running on Classic Era (non-seasonal)
---@field IsEra boolean True if running on Classic Era
---@field IsSoD boolean True if running on Season of Discovery
---@field IsSoM boolean True if running on Season of Mastery
---@field IsHC boolean True if running on Hardcore Classic
---@field IsTBC boolean True if running on TBC Classic
---@field IsWotlk boolean True if running on WotLK Classic
---@field IsCata boolean True if running on Cataclysm Classic
---@field IsMOP boolean True if running on Mists of Pandaria Classic
---@field IsWOD boolean True if running on Warlords of Draenor
---@field IsRetail boolean True if running on Retail (mainline)
---@field IsLegion boolean True if running on Legion expansion
---@field IsBFA boolean True if running on Battle for Azeroth
---@field IsShadowlands boolean True if running on Shadowlands
---@field IsDragonflight boolean True if running on Dragonflight
---@field IsWarWithin boolean True if running on The War Within
---@field IsMidnight boolean True if running on Midnight or newer
local Version = Constants.Version

---@class ENUMTable
local pfENUM = Constants.ENUM

---@class BitmaskTable
---@field SpellMask table<string, SpellMaskEntry> Spell school bitmask definitions
local bitmasks = Constants.Bitmasks

-- ===========================================================================
-- Version Utility 
-- ===========================================================================


local expansionLevel = (GetExpansionLevel and GetExpansionLevel() or LE_EXPANSION_LEVEL_CURRENT) or 0
local isMainline = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local isClassicProject = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

---@type boolean
Version.IsClassic, Version.IsEra, Version.IsSoD, Version.IsSoM, Version.IsHC = false, false, false, false, false
Version.IsTBC, Version.IsWotlk, Version.IsCata, Version.IsMOP, Version.IsWOD = false, false, false, false, false
Version.IsRetail, Version.IsLegion, Version.IsBFA, Version.IsShadowlands, Version.IsDragonflight, Version.IsWarWithin, Version.IsMidnight = false, false, false, false, false, false, false

if isMainline then
    Version.IsRetail = true
    if expansionLevel >= 11 then Version.IsMidnight = true
    elseif expansionLevel == 10 then Version.IsWarWithin = true
    elseif expansionLevel == 9 then Version.IsDragonflight = true
    elseif expansionLevel == 8 then Version.IsShadowlands = true
    elseif expansionLevel == 7 then Version.IsBFA = true
    elseif expansionLevel == 6 then Version.IsLegion = true
    end

elseif isClassicProject then
    -- Detect Season of Discovery, Era, or Hardcore
    local season = C_Seasons and C_Seasons.HasActiveSeason and C_Seasons.HasActiveSeason() and C_Seasons.GetActiveSeason()
    if season == 1 then
        Version.IsSoM = true
    end
    if season == 2 then -- Season of Discovery
        Version.IsSoD = true
    elseif C_GameRules and C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive() then
        Version.IsHC = true
    else
        Version.IsEra = true
        Version.IsClassic = true
    end
elseif WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5) then
    Version.IsTBC = true
elseif WOW_PROJECT_ID == (WOW_PROJECT_CATACLYSM_CLASSIC or 14) then
    Version.IsCata = true
elseif WOW_PROJECT_ID == (WOW_PROJECT_MISTS_CLASSIC or 19) then
    Version.IsMOP = true
end

---@alias keyRef string Modifier key identifier (e.g. "Shift", "Alt", "Ctrl")

---@class PrephsFramework.KeyRef
---@field ALT_KEY keyRef
---@field RALT_KEY keyRef
---@field CTRL_KEY keyRef
---@field RCTRL_KEY keyRef
---@field SHIFT_KEY keyRef
---@field RSHIFT_KEY keyRef
pfENUM.KeyRef = {
    ALT_KEY = "Alt",
    RALT_KEY = "Right Alt",
    CTRL_KEY = "Ctrl",
    RCTRL_KEY = "Right Ctrl",
    SHIFT_KEY = "Shift",
    RSHIFT_KEY = "Right Shift",
}


-- https://warcraft.wiki.gg/wiki/InventorySlotID
---@type table<string, InvSlotID>
---@alias InvSlotID number
pfENUM.InvSlotIDs = {
    AMMO         = 0,
    HEAD         = 1,
    NECK         = 2,
    SHOULDER     = 3,
    SHIRT        = 4,
    CHEST        = 5,
    WAIST        = 6,
    LEGS         = 7,
    FEET         = 8,
    WRIST        = 9,
    HANDS        = 10,
    FINGER1      = 11,
    FINGER2      = 12,
    TRINKET1     = 13,
    TRINKET2     = 14,
    BACK		 = 15,
    MAINHAND	 = 16,
    OFFHAND		 = 17,
    RANGED		 = 18,
    TABARD		 = 19,
}


-- https://trinitycore.info/files/DBC/335/gtcombatratings
---@type table<string, CRID>
---@alias CRID number
pfENUM.CRatings = {
    CR_WEAPON_SKILL             = 0,
    CR_DEFENSE_SKILL            = 1,
    CR_DODGE                    = 2,
    CR_PARRY                    = 3,
    CR_BLOCK                    = 4,
    CR_HIT_MELEE                = 5,
    CR_HIT_RANGED               = 6,
    CR_HIT_SPELL                = 7,
    CR_CRIT_MELEE               = 8,
    CR_CRIT_RANGED              = 9,
    CR_CRIT_SPELL               = 10,
    CR_HIT_TAKEN_MELEE          = 11,
    CR_HIT_TAKEN_RANGED         = 12,
    CR_HIT_TAKEN_SPELL          = 13,
    CR_CRIT_TAKEN_MELEE         = 14,
    CR_CRIT_TAKEN_RANGED        = 15,
    CR_CRIT_TAKEN_SPELL         = 16,
    CR_HASTE_MELEE              = 17,
    CR_HASTE_RANGED             = 18,
    CR_HASTE_SPELL              = 19,
    CR_WEAPON_SKILL_MAINHAND    = 20,
    CR_WEAPON_SKILL_OFFHAND     = 21,
    CR_WEAPON_SKILL_RANGED      = 22,
    CR_EXPERTISE                = 23,
    CR_ARMOR_PENETRATION        = 24
}


-- https://wowdev.wiki/Spell.dbc/SchoolMask
---@class SpellMaskEntry
---@field id number
---@field mask Bitmask
---@field string string
---@type table<string, SpellMaskEntry>
bitmasks.SpellMask = {
    -- Base Schools (Single Bits)
    PHYSICAL     = { id = 1,   mask = 0x01, string = "SPELL_SCHOOL_NORMAL" },
    HOLY         = { id = 2,   mask = 0x02, string = "SPELL_SCHOOL_HOLY" },
    FIRE         = { id = 4,   mask = 0x04, string = "SPELL_SCHOOL_FIRE" },
    NATURE       = { id = 8,   mask = 0x08, string = "SPELL_SCHOOL_NATURE" },
    FROST        = { id = 16,  mask = 0x10, string = "SPELL_SCHOOL_FROST" },
    SHADOW       = { id = 32,  mask = 0x20, string = "SPELL_SCHOOL_SHADOW" },
    ARCANE       = { id = 64,  mask = 0x40, string = "SPELL_SCHOOL_ARCANE" },

    -- Multi-Schools (Combined Bits)
    HOLYSTRIKE   = { id = 3,   mask = 0x03, string = "SPELL_SCHOOL_HOLYSTRIKE" },   -- Holy + Physical
    FLAMESTRIKE  = { id = 5,   mask = 0x05, string = "SPELL_SCHOOL_FLAMESTRIKE" },  -- Fire + Physical
    HOLYFIRE     = { id = 6,   mask = 0x06, string = "SPELL_SCHOOL_HOLYFIRE" },    -- Fire + Holy
    STORMSTRIKE  = { id = 9,   mask = 0x09, string = "SPELL_SCHOOL_STORMSTRIKE" }, -- Nature + Physical
    HOLYSTORM    = { id = 10,  mask = 0x0A, string = "SPELL_SCHOOL_HOLYSTORM" },   -- Nature + Holy
    FIRESTORM   = { id = 12,  mask = 0x0C, string = "SPELL_SCHOOL_FIRESTORM" },   -- Nature + Fire
    FROSTSTRIKE  = { id = 17,  mask = 0x11, string = "SPELL_SCHOOL_FROSTSTRIKE" }, -- Frost + Physical
    FROSTFIRE    = { id = 20,  mask = 0x14, string = "SPELL_SCHOOL_FROSTFIRE" },   -- Frost + Fire
    FROSTSTORM   = { id = 24,  mask = 0x18, string = "SPELL_SCHOOL_FROSTSTORM" },  -- Frost + Nature
    ELEMENTAL    = { id = 28,  mask = 0x1C, string = "SPELL_SCHOOL_ELEMENTAL" },   -- Frost + Fire + Nature
    SHADOWSTRIKE = { id = 33,  mask = 0x21, string = "SPELL_SCHOOL_SHADOWSTRIKE" },-- Shadow + Physical
    TWILIGHT     = { id = 34,  mask = 0x22, string = "SPELL_SCHOOL_TWILIGHT" },    -- Shadow + Holy
    SHADOWFLAME  = { id = 36,  mask = 0x24, string = "SPELL_SCHOOL_SHADOWFLAME" }, -- Shadow + Fire
    PLAGUE       = { id = 40,  mask = 0x28, string = "SPELL_SCHOOL_PLAGUE" },      -- Shadow + Nature
    SHADOWFROST  = { id = 49,  mask = 0x31, string = "SPELL_SCHOOL_SHADOWFROST" }, -- Shadow + Frost
    DIVINE       = { id = 66,  mask = 0x42, string = "SPELL_SCHOOL_DIVINE" },      -- Arcane + Holy
    SPELLFIRE    = { id = 68,  mask = 0x44, string = "SPELL_SCHOOL_SPELLFIRE" },   -- Arcane + Fire
    SPELLSTORM   = { id = 72,  mask = 0x48, string = "SPELL_SCHOOL_SPELLSTORM" },  -- Arcane + Nature
    SPELLFROST   = { id = 80,  mask = 0x50, string = "SPELL_SCHOOL_SPELLFROST" },  -- Arcane + Frost
    SPELLSHADOW  = { id = 96,  mask = 0x60, string = "SPELL_SCHOOL_SPELLSHADOW" }, -- Arcane + Shadow
    MAGIC        = { id = 126, mask = 0x7E, string = "SPELL_SCHOOL_MAGIC" },       -- All except Physical
    CHAOS        = { id = 127, mask = 0x7F, string = "SPELL_SCHOOL_CHAOS" },       -- All including Physical
}

-- ===========================================================================
-- Bitmasks
-- ===========================================================================

-- https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
---@type table<string, Bitmask>
bitmasks.NpcFlags = {
    NONE                  = 0x00000000,
    GOSSIP                = 0x00000001,       -- 100%
    QUESTGIVER            = 0x00000002,       -- guessed, probably ok
    VENDOR                = 0x00000004,       -- 100%
    FLIGHTMASTER          = 0x00000008,       -- 100%
    TRAINER               = 0x00000010,       -- 100%
    SPIRITHEALER          = 0x00000020,       -- guessed
    SPIRITGUIDE           = 0x00000040,       -- guessed
    INNKEEPER             = 0x00000080,       -- 100%
    BANKER                = 0x00000100,       -- 100%
    PETITIONER            = 0x00000200,       -- 100% 0xC0000 = guild petitions
    TABARDDESIGNER        = 0x00000400,       -- 100%
    BATTLEMASTER          = 0x00000800,       -- 100%
    AUCTIONEER            = 0x00001000,       -- 100%
    STABLEMASTER          = 0x00002000,       -- 100%
    REPAIR                = 0x00004000,       -- 100%
    OUTDOORPVP            = 0x20000000,       -- custom flag for outdoor pvp creatures || Custom flag
}

---@class PrephsFramework.Enum.PvPFactions
pfENUM.PvPFaction = {
    HORDE = 0,
    ALLIANCE = 1,
    NEUTRAL = 2,
}

---@alias factionID number
---@class PrephsFramework.Enums.NPCFactionEntry
---@field faction PrephsFramework.Enum.PvPFactions|nil The major faction this faction belongs to, if any. 0 = Horde, 1 = Alliance, nil = Neutral/Other
---@field name string The localized name of the faction
---@field parentID number|nil The ID of the parent faction, if any.

---@class PrephsFramework.Enums.NPCFactions
---@field factionID PrephsFramework.Enums.NPCFactionEntry
pfENUM.Factions = {
    [21]    = {nil,     "Booty Bay" 	                        ,169},
    [47]    = {1,       "Ironforge" 	                        ,469},
    [54]    = {1,       "Gnomeregan Exiles" 	                ,469},
    [59]    = {nil,     "Thorium Brotherhood" 	                ,1118},
    [67]    = {0,       "Horde" 	                            ,1118},
    [68]    = {0,       "Undercity" 	                        ,67},
    [69]    = {1,       "Darnassus" 	                        ,469},
    [70]    = {nil,     "Syndicate"                             ,nil},
    [72]    = {1,       "Stormwind" 	                        ,469},
    [76]    = {0,       "Orgrimmar" 	                        ,67},
    [81]    = {0,       "Thunder Bluff"	                        ,67},
    [92]    = {nil,     "Gelkis Clan Centaur" 	                ,1118},
    [93]    = {nil,     "Magram Clan Centaur" 	                ,1118},
    [169]   = {nil,     "Steamwheedle Cartel" 	                ,1118},
    [270]   = {nil,     "Zandalar Tribe" 	                    ,1118},
    [349]   = {nil,     "Ravenholdt" 	                        ,1118},
    [369]   = {nil,     "Gadgetzan" 	                        ,169},
    [469]   = {1,       "Alliance" 	                            ,1118},
    [470]   = {nil,     "Ratchet" 	                            ,169},
    [471]   = {1,       "Wildhammer Clan"                       ,nil},
    [509]   = {1,       "The League of Arathor "	            ,891},
    [510]   = {0,       "The Defilers" 	                        ,892},
    [529]   = {nil,     "Argent Dawn"	                        ,1118},
    [530]   = {0,       "Darkspear Trolls "	                    ,67},
    [576]   = {nil,     "Timbermaw Hold" 	                    ,1118},
    [577]   = {nil,     "Everlook" 	                            ,169},
    [589]   = {1,       "Wintersaber Trainer"                   ,nil},
    [609]   = {nil,     "Cenarion Circle"                       ,1118},
    [729]   = {0,       "Frostwolf Clan" 	                    ,892},
    [730]   = {1,       "Stormpike Guard" 	                    ,891},
    [749]   = {nil,     "Hydraxian Waterlords" 	                ,1118},
    [809]   = {1,       "Shen'dralar" 	                        ,1118},
    [889]   = {0,       "Warsong Outriders" 	                ,892},
    [890]   = {1,       "Silverwing Sentinels "	                ,891},
    [891]   = {1,       "Alliance Forces" 	                    ,1118},
    [892]   = {0,       "Horde Forces" 	                        ,1118},
    [909]   = {nil,     "Darkmoon Faire" 	                    ,1118},
    [910]   = {nil,     "Brood of Nozdormu" 	                ,1118},
    [911]   = {0,       "Silvermoon City" 	                    ,67},
    [922]   = {0,       "Tranquillien" 	                        ,1118},
    [930]   = {nil,     "Exodar" 	                            ,469},
    [932]   = {nil,     "The Aldor" 	                        ,936},
    [934]   = {nil,     "The Scryers "	                        ,936},
    [933]   = {nil,     "The Consortium" 	                    ,980},
    [935]   = {nil,     "The Sha'tar" 	                        ,936},
    [936]   = {nil,     "Shattrath City "	                    ,980},
    [941]   = {0,       "The Mag'har" 	                        ,980},
    [942]   = {nil,     "Cenarion Expedition" 	                ,980},
    [946]   = {1,       "Honor Hold" 	                        ,980},
    [947]   = {0,       "Thrallmar" 	                        ,980},
    [948]   = {nil,     "Test Faction 2" 	                    ,949},
    [949]   = {nil,     "Test Faction"                          ,nil},
    [952]   = {nil,     "Test Faction 3" 	                    ,948},
    [967]   = {nil,     "The Violet Eye" 	                    ,980},
    [970]   = {nil,     "Sporeggar" 	                        ,980},
    [978]   = {1,       "Kurenai" 	                            ,980},
    [980]   = {nil,     "The Burning Crusade"                   ,nil},
    [989]   = {nil,     "Keepers of Time" 	                    ,980},
    [990]   = {nil,     "The Scale of the Sands" 	            ,980},
    [1011]  = {nil,     "Lower City"                            ,936},
    [1012]  = {nil,     "Ashtongue Deathsworn"	                ,980},
    [1015]  = {nil,     "Netherwing" 	                        ,980},
    [1031]  = {nil,     "Sha'tari Skyguard" 	                ,936},
    [1037]  = {1,       "Alliance Vanguard"	                    ,1097},
    [1038]  = {nil,     "Ogri'la" 	                            ,980},
    [1050]  = {1,       "Valiance Expedition" 	                ,1037},
    [1052]  = {0,       "Horde Expedition "	                    ,1097},
    [1064]  = {0,       "The Taunka" 	                        ,1052},
    [1067]  = {0,       "The Hand of Vengeance" 	            ,1052},
    [1068]  = {1,       "Explorers' League" 	                ,1037},
    [1073]  = {nil,     "The Kalu'ak" 	                        ,1097},
    [1077]  = {nil,     "Shattered Sun Offensive"               ,936},
    [1085]  = {0,       "Warsong Offensive" 	                ,1052},
    [1090]  = {nil,     "Kirin Tor" 	                        ,1097},
    [1091]  = {nil,     "The Wyrmrest Accord" 	                ,1097},
    [1094]  = {1,       "The Silver Covenant" 	                ,1037},
    [1097]  = {nil,     "Wrath of the Lich King"                ,nil},
    [1098]  = {nil,     "Knights of the Ebon Blade" 	        ,1097},
    [1104]  = {nil,     "Frenzyheart Tribe" 	                ,1117},
    [1105]  = {nil,     "The Oracles" 	                        ,1117},
    [1106]  = {nil,     "Argent Crusade" 	                    ,1097},
    [1117]  = {nil,     "Sholazar Basin" 	                    ,1097},
    [1118]  = {nil,     "Classic"                               ,nil},
    [1119]  = {nil,     "The Sons of Hodir" 	                ,1097},
    [1124]  = {0,       "The Sunreavers"	                    ,1052},
    [1126]  = {1,       "The Frostborn"	                        ,1037},
    [1156]  = {nil,     "The Ashen Verdict "	                ,1097},
}

---@class PrephsFramework.Enum.Professions
---@field Alchemy number
---@field Blacksmithing number
---@field Enchanting number
---@field Engineering number
---@field Herbalism number
---@field Inscription number
---@field Jewelcrafting number
---@field Leatherworking number
---@field Mining number
---@field Skinning number
---@field Tailoring number
---@field Cooking number
---@field FirstAid number
---@field Fishing number
---@field Names table<number, string>  Reverse lookup: enum index → profession name as used in CharData.professions
---@field Lookup table<string, number>  Profession name → enum index (includes "First Aid" → FirstAid mapping)
pfENUM.Professions = {
    -- Primary crafting
    Alchemy        = 1,
    Blacksmithing  = 2,
    Enchanting     = 3,
    Engineering    = 4,
    Leatherworking = 5,
    Tailoring      = 6,
    -- Primary gathering
    Herbalism      = 7,
    Mining         = 8,
    Skinning       = 9,
    -- Secondary
    Cooking        = 10,
    FirstAid       = 11,
    Fishing        = 12,
    -- TBC+
    Jewelcrafting  = 13,
    Inscription    = 14,
}

--- Reverse lookup: enum index → profession name (matching CharData.professions keys).
pfENUM.Professions.Names = {
    [1]  = "Alchemy",
    [2]  = "Blacksmithing",
    [3]  = "Enchanting",
    [4]  = "Engineering",
    [5]  = "Leatherworking",
    [6]  = "Tailoring",
    [7]  = "Herbalism",
    [8]  = "Mining",
    [9]  = "Skinning",
    [10] = "Cooking",
    [11] = "First Aid",
    [12] = "Fishing",
    [13] = "Jewelcrafting",
    [14] = "Inscription",
}

bitmasks.objFlags = {
    DUNGEON     = 0x01,
    RAID        = 0x02,
    MAILBOX     = 0x04,
}

--- Name → enum index lookup (includes space-variant "First Aid").
pfENUM.Professions.Lookup = {}
for idx, name in pairs(pfENUM.Professions.Names) do
    pfENUM.Professions.Lookup[name] = idx
end


