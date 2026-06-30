--[[
    <PrephsFramework_Core/data/weeklyQuests.lua>
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

---@class PrephsFramework.data
local data = Core.data
local Constants = Core.Constants
local Version   = Constants.Version


-- ============================================================================
-- Weekly Quest Definitions — per version of WoW
-- ============================================================================
-- Each entry: { id = questID, name = "Display Name" }
-- Checked by Indexer:ScanWeeklyQuests() via IsQuestFlaggedCompleted().
-- Reset timing follows the server's weekly reset cadence.
--
-- *** Extend these tables with additional quest IDs as needed. ***
-- ============================================================================

---@class PFWeeklyQuestDef
---@field ids   number[]  Quest IDs (any completing marks the slot done)
---@field names string[]?  Optional display names matching each id; resolved from questData when absent
---@field faction number?  0 = Horde, 1 = Alliance, nil = both

---@class PrephsFramework.data.weeklyQuestDefs
---@field active PFWeeklyQuestDef[] Quest defs active for the current version

local allDefs = {}

-- ---------------------------------------------------------------------------
-- Classic Era  (1.12, Hardcore, Season of Mastery)
-- ---------------------------------------------------------------------------
-- Head turn-in quests reset with the weekly server reset.
allDefs.Classic = {
}

-- ---------------------------------------------------------------------------
-- Season of Discovery
-- ---------------------------------------------------------------------------
allDefs.SoD = {  -- SoD uses the same weekly quests as Classic Era, but may add more later.
    { ids = {89255, 89256, 89257, 89258, 89259, 89260, 89261, 89262} },
}

-- ---------------------------------------------------------------------------
-- The Burning Crusade Classic
-- ---------------------------------------------------------------------------
allDefs.TBC = {
    -- TBC had very few formally weekly-flagged quests.
    -- Add any known repeating weekly IDs here.
}

-- ---------------------------------------------------------------------------
-- Wrath of the Lich King Classic
-- ---------------------------------------------------------------------------
-- "Proof of Demise" quests rotated weekly from the Dungeon Finder / notice board.
allDefs.WotLK = {
}

-- ---------------------------------------------------------------------------
-- Cataclysm Classic / Mists
-- ---------------------------------------------------------------------------
allDefs.Cata = {}
allDefs.MOP  = {}

-- ---------------------------------------------------------------------------
-- Retail fallback (Retail uses C_QuestLog differently — update as needed)
-- ---------------------------------------------------------------------------
allDefs.Retail = {}

-- ============================================================================
-- Version resolution — pick the active list
-- ============================================================================

local active
if Version.IsSoD then
    active = allDefs.SoD
elseif Version.IsClassic or Version.IsEra or Version.IsHC or Version.IsSoM then
    active = allDefs.Classic
elseif Version.IsTBC then
    active = allDefs.TBC
elseif Version.IsWotlk then
    active = allDefs.WotLK
elseif Version.IsCata then
    active = allDefs.Cata
elseif Version.IsMOP then
    active = allDefs.MOP
else
    active = allDefs.Retail
end

data.weeklyQuestDefs        = active   -- active list for this version
if Core.DEV.testing then
    data.allWeeklyQuestDefs     = allDefs
end
