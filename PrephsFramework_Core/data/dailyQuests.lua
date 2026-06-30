--[[
    <PrephsFramework_Core/data/dailyQuests.lua>
    Copyright (C) <2026> <Prephmage / Prephalia>

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
    Author:  <Prephmage>
    GitHub: https://github.com/JulianStiebler/WoW_PrephsFramework
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
-- Daily Quest Definitions — per version of WoW
-- ============================================================================
-- Each entry: { ids = {questID, ...}, names = {"Display Name", ...}? }
-- Checked by Indexer:ScanDailyQuests() via IsQuestFlaggedCompleted().
-- Reset timing follows the server's daily reset cadence.
--
-- names is optional — when absent, resolved from questData at display time.
-- ============================================================================

---@class PFDailyQuestDef
---@field ids     number[]   Quest IDs (any completing marks the slot done)
---@field names   string[]?  Optional display names matching each id; resolved from questData when absent
---@field faction number?    0 = Horde, 1 = Alliance, nil = both

---@class PrephsFramework.data.dailyQuestDefs
---@field active PFDailyQuestDef[] Quest defs active for the current version

local allDefs = {}

-- ---------------------------------------------------------------------------
-- Classic Era  (1.12, Hardcore, Season of Mastery)
-- ---------------------------------------------------------------------------
allDefs.Classic = {

}

-- ---------------------------------------------------------------------------
-- Season of Discovery
-- ---------------------------------------------------------------------------
allDefs.SoD = {
    { ids = {90518} }, -- https://www.wowhead.com/classic/quest=90518/an-apple-a-day-keeps-the-undead-at-bay
    { ids = {90519} }, -- https://www.wowhead.com/classic/quest=90519/fish-on-demand
    { ids = {90520} }, -- https://www.wowhead.com/classic/quest=90520/food-safety
}

-- ---------------------------------------------------------------------------
-- The Burning Crusade Classic
-- ---------------------------------------------------------------------------
allDefs.TBC = {
}

-- ---------------------------------------------------------------------------
-- Wrath of the Lich King Classic
-- ---------------------------------------------------------------------------
allDefs.WotLK = {
}

-- ---------------------------------------------------------------------------
-- Cataclysm Classic
-- ---------------------------------------------------------------------------
allDefs.Cata = {}

-- ---------------------------------------------------------------------------
-- Mists of Pandaria Classic
-- ---------------------------------------------------------------------------
allDefs.MOP  = {}

-- ---------------------------------------------------------------------------
-- Retail fallback
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

data.dailyQuestDefs        = active   -- active list for this version
if Core.DEV.testing then
    data.allDailyQuestDefs     = allDefs
end
