--[[
    <PrephsFramework_Core/data/profCD.lua>
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

local Constants = Core.Constants
local Version   = Constants.Version
local pfENUM    = Constants.ENUM
local Prof      = pfENUM.Professions

-- ============================================================================
-- Profession Cooldown Definitions — per version of WoW
-- ============================================================================
-- Each version defines an array of "cooldown groups".  A group represents a
-- set of spells that share a single cooldown (e.g. all Alchemy transmutes).
--
-- Group fields (hash part):
--   profID     — pfENUM.Professions enum value (used for CharData lookup)
--   label      — display name shown in the overview (e.g. "Transmute")
--
-- Group entries (array part):
--   { spellID, name, cdSeconds }  — individual spells in the shared CD
--
-- When ANY spell in a group is on CD, the whole group is on CD and the
-- overview displays a single "label (time)" line instead of every spell.
-- ============================================================================

---@class PFProfCooldownSpell
---@field spellID    number   Spell ID to query via GetSpellCooldown
---@field name       string   Human-readable spell name (fallback if GetSpellInfo unavailable)
---@field cdSeconds  number   Nominal cooldown duration in seconds

---@class PFProfCooldownGroup
---@field profID     number   pfENUM.Professions enum value
---@field label      string   Display label for the group (e.g. "Transmute")
-- Array part contains PFProfCooldownSpell entries

local allDefs = {}

-- ---------------------------------------------------------------------------
-- Classic Era  (1.12, Hardcore, Season of Mastery, Season of Discovery)
-- ---------------------------------------------------------------------------

local classicDefs = {
    {
        profID = Prof.Alchemy,
        label  = "Transmute",
        { spellID = 11479, name = "Iron to Gold",           cdSeconds = 86400  },
        { spellID = 11480, name = "Mithril to Truesilver",  cdSeconds = 86400  },
        { spellID = 17559, name = "Air to Fire",            cdSeconds = 86400  },
        { spellID = 17560, name = "Fire to Earth",          cdSeconds = 86400  },
        { spellID = 17561, name = "Earth to Water",         cdSeconds = 86400  },
        { spellID = 17562, name = "Water to Air",           cdSeconds = 86400  },
        { spellID = 17563, name = "Undeath to Water",       cdSeconds = 86400  },
        { spellID = 17565, name = "Life to Earth",          cdSeconds = 86400  },
        { spellID = 17566, name = "Earth to Life",          cdSeconds = 86400  },
        { spellID = 25146, name = "Elemental Fire",         cdSeconds = 86400  },
        { spellID = 17187, name = "Arcanite Bar",           cdSeconds = 172800 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Mooncloth",
        { spellID = 18560, name = "Mooncloth",              cdSeconds = 345600 },
    },
    {
        profID = Prof.Leatherworking,
        label  = "Salt Shaker",
        { spellID = 19047, name = "Refined Deeprock Salt",  cdSeconds = 259200 },
        { spellID = 20650, name = "Cured Rugged Hide",      cdSeconds = 259200 },
    },
}

allDefs.Classic = classicDefs
allDefs.SoD     = classicDefs   -- SoD shares Classic cooldowns

-- ---------------------------------------------------------------------------
-- The Burning Crusade Classic
-- ---------------------------------------------------------------------------
allDefs.TBC = {
    {
        profID = Prof.Alchemy,
        label  = "Transmute",
        { spellID = 28566, name = "Primal Air to Fire",     cdSeconds = 72000 },
        { spellID = 28567, name = "Primal Earth to Water",  cdSeconds = 72000 },
        { spellID = 28568, name = "Primal Fire to Earth",   cdSeconds = 72000 },
        { spellID = 28569, name = "Primal Water to Air",    cdSeconds = 72000 },
        { spellID = 28580, name = "Primal Shadow to Water", cdSeconds = 72000 },
        { spellID = 28581, name = "Primal Water to Shadow", cdSeconds = 72000 },
        { spellID = 28582, name = "Primal Mana to Fire",    cdSeconds = 72000 },
        { spellID = 28583, name = "Primal Fire to Mana",    cdSeconds = 72000 },
        { spellID = 28584, name = "Primal Life to Earth",   cdSeconds = 72000 },
        { spellID = 28585, name = "Primal Earth to Life",   cdSeconds = 72000 },
        { spellID = 32765, name = "Earthstorm Diamond",     cdSeconds = 72000 },
        { spellID = 32766, name = "Skyfire Diamond",        cdSeconds = 72000 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Primal Mooncloth",
        { spellID = 26751, name = "Primal Mooncloth",       cdSeconds = 345600 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Spellcloth",
        { spellID = 31373, name = "Spellcloth",             cdSeconds = 345600 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Shadowcloth",
        { spellID = 36686, name = "Shadowcloth",            cdSeconds = 345600 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Imbued Netherweave",
        { spellID = 26750, name = "Bolt of Imbued Netherweave", cdSeconds = 345600 },
    },
    {
        profID = Prof.Leatherworking,
        label  = "Salt Shaker",
        { spellID = 19047, name = "Refined Deeprock Salt",  cdSeconds = 259200 },
    },
}

-- ---------------------------------------------------------------------------
-- Wrath of the Lich King Classic
-- ---------------------------------------------------------------------------
allDefs.WotLK = {
    {
        profID = Prof.Alchemy,
        label  = "Transmute",
        { spellID = 53777, name = "Eternal Life to Shadow", cdSeconds = 72000 },
        { spellID = 53776, name = "Eternal Life to Fire",   cdSeconds = 72000 },
        { spellID = 53781, name = "Eternal Shadow to Life", cdSeconds = 72000 },
        { spellID = 53782, name = "Eternal Shadow to Earth",cdSeconds = 72000 },
        { spellID = 53783, name = "Eternal Air to Water",   cdSeconds = 72000 },
        { spellID = 53784, name = "Eternal Air to Earth",   cdSeconds = 72000 },
        { spellID = 54020, name = "Eternal Might",          cdSeconds = 72000 },
        { spellID = 66658, name = "Ametrine",               cdSeconds = 72000 },
        { spellID = 66659, name = "Cardinal Ruby",          cdSeconds = 72000 },
        { spellID = 66660, name = "King's Amber",           cdSeconds = 72000 },
        { spellID = 66662, name = "Dreadstone",             cdSeconds = 72000 },
        { spellID = 66663, name = "Majestic Zircon",        cdSeconds = 72000 },
        { spellID = 66664, name = "Eye of Zul",             cdSeconds = 72000 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Moonshroud",
        { spellID = 56001, name = "Moonshroud",             cdSeconds = 345600 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Ebonweave",
        { spellID = 56002, name = "Ebonweave",              cdSeconds = 345600 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Spellweave",
        { spellID = 56003, name = "Spellweave",             cdSeconds = 345600 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Glacial Bag",
        { spellID = 55900, name = "Glacial Bag",            cdSeconds = 345600 },
    },
    {
        profID = Prof.Leatherworking,
        label  = "Salt Shaker",
        { spellID = 19047, name = "Refined Deeprock Salt",  cdSeconds = 259200 },
    },
}

-- ---------------------------------------------------------------------------
-- Cataclysm Classic
-- ---------------------------------------------------------------------------
allDefs.Cata = {
    {
        profID = Prof.Alchemy,
        label  = "Transmute",
        { spellID = 80243, name = "Truegold",               cdSeconds = 86400 },
        { spellID = 80244, name = "Pyrium Bar",             cdSeconds = 86400 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Dream of Skywall",
        { spellID = 75141, name = "Dream of Skywall",       cdSeconds = 604800 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Dream of Ragnaros",
        { spellID = 75145, name = "Dream of Ragnaros",      cdSeconds = 604800 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Dream of Hyjal",
        { spellID = 75146, name = "Dream of Hyjal",         cdSeconds = 604800 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Dream of Deepholm",
        { spellID = 75142, name = "Dream of Deepholm",      cdSeconds = 604800 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Dream of Azshara",
        { spellID = 75144, name = "Dream of Azshara",       cdSeconds = 604800 },
    },
}

-- ---------------------------------------------------------------------------
-- Mists of Pandaria
-- ---------------------------------------------------------------------------
allDefs.MOP = {
    {
        profID = Prof.Alchemy,
        label  = "Transmute",
        { spellID = 114780, name = "Living Steel",          cdSeconds = 86400 },
        { spellID = 114783, name = "Trillium Bar",          cdSeconds = 86400 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Imperial Silk",
        { spellID = 143011, name = "Imperial Silk",         cdSeconds = 86400 },
    },
    {
        profID = Prof.Tailoring,
        label  = "Celestial Cloth",
        { spellID = 125557, name = "Celestial Cloth",       cdSeconds = 86400 },
    },
}

-- ---------------------------------------------------------------------------
-- Retail fallback (most CDs removed or reworked — extend as needed)
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

-- Resolve profID → profession name on each group for consumer convenience.
local ProfNames = Prof.Names
for _, group in ipairs(active) do
    group.profession = ProfNames[group.profID]
end

Core.data.profCooldownDefs       = active   -- active list for this version
if Core.DEV.testing then
    Core.data.allProfCooldownDefs    = allDefs
end
