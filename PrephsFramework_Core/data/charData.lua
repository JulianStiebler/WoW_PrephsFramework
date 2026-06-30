--[[
    <PrephsFramework_Core/data/charData.lua>
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

-- ============================================================================
-- Type Aliases
-- ============================================================================

---@alias itemID number
---@alias spellID number
---@alias enchantID number
---@alias runeID number
---@alias itemLink string  -- e.g. |Hitem:12345:...|h[Item Name]|h
---@alias itemSlotID number -- 1-19 for equippable gear slots
---@alias slotKey string    -- Location key: "e:slotID", "b:bag:slot", "k:bag:slot" (equipped/bag/bank)

-- ============================================================================
-- Item Count Record — lightweight aggregate per itemID
-- ============================================================================
-- One entry per distinct itemID.  Modules that only care about counts
-- (Tooltipper, recipe mat checks, …) read this table exclusively.

---@class PFItemCount
---@field itemID itemID
---@field name string                    Cached GetItemInfo name
---@field itemLink itemLink              Most-recently-seen hyperlink
---@field quality number                 Enum.ItemQuality (0-8)
---@field icon number                    Texture file ID
---@field bags number                    Stack total across bags 0-4
---@field bank number                    Stack total across bank bags
---@field mail number                    Stack total across mailbox
---@field ah number                      Stack total on the auction house
---@field equipped number                Count currently equipped (usually 0-2)
---@field total number                   Sum of all location counts
---@field itemType string|nil            GetItemInfo type (Armor, Weapon, …)
---@field itemSubType string|nil         GetItemInfo subType
---@field equipLoc string|nil            GetItemInfo equipLoc token (INVTYPE_HEAD, …)
---@field sellPrice number               Vendor sell price in copper
---@field isEquippable boolean           true when equipLoc is non-empty
---@field bagsCharges number             Stack total of temporary enchant charges in bags
---@field bankCharges number             Stack total of temporary enchant charges in bank
---@field totalCharges number            Stack total of temporary enchant charges across all locations
---@field ahExpiry number|nil            Earliest AH-tier expiry epoch for this item (nil = no active auctions)

-- ============================================================================
-- AH Expiry Tier → Duration Mapping (Classic WoW)
-- ============================================================================
-- GetAuctionItemTimeLeft returns 1-4:
--   1 = Short   (< 30 min)
--   2 = Medium  (30 min – 2 hr)
--   3 = Long    (2 hr – 12 hr)
--   4 = Very Long (12 hr – 48 hr)
-- We use pessimistic upper-bound durations so forecasts don't fire too early.

-- ============================================================================
-- Mail Forecast Entry — items expected to arrive
-- ============================================================================
-- Stored in CharData.mailForecasts[itemID] = PFMailForecast

---@class PFMailForecast
---@field count number            Total forecasted stack count
---@field source string           "sent" (player mail) or "ah" (expired/sold auction)
---@field expiresAt number|nil    Epoch when the forecast should auto-expire (nil = permanent until mail scan)

-- ============================================================================
-- Equippable Item Instance — unique per physical item
-- ============================================================================
-- Keyed by slotKey in Core.CharData.equippables.
-- A slotKey encodes where the item currently lives:
--   "e:<equipSlotID>"    — worn gear slot 1-19
--   "b:<bagID>:<bagSlot>"  — player bag (bags 0-4)
--   "k:<bagID>:<bagSlot>"  — bank bag (-1, 5-11)

---@class PFEquippableItem
---@field itemID itemID
---@field itemLink itemLink              Full hyperlink (carries enchant/suffix/gems)
---@field name string                    GetItemInfo name
---@field quality number                 Enum.ItemQuality (0-8)
---@field icon number                    Texture file ID
---@field equipLoc string                INVTYPE_* token
---@field itemSubType string|nil         Armor subtype (Cloth/Leather/Mail/Plate) or weapon type
---@field slotKey slotKey                Location key where this instance lives
---@field equipSlotID itemSlotID|nil     If currently worn: the equipment slot (1-19)
---@field bagID number|nil               If in a bag/bank container
---@field bagSlot number|nil             Slot within that container
---@field enchantID enchantID            Enchant ID parsed from itemLink (0 = none)
---@field gem1 number                    Gem/socket 1 item ID (0 = empty)
---@field gem2 number                    Gem/socket 2 item ID (0 = empty)
---@field gem3 number                    Gem/socket 3 item ID (0 = empty)
---@field gem4 number                    Gem/socket 4 item ID (0 = empty)
---@field suffixID number                Random-enchant suffix ID (0 = none)
---@field uniqueID number                Unique instance ID from the item link
---@field runeSpellID spellID|nil        SoD engraving rune spell ID (nil if none / not SoD)

-- ============================================================================
-- Profession & Recipe Types
-- ============================================================================

---@class PFRecipe
---@field name string                    Recipe display name
---@field link itemLink|string           Result item link, or name as fallback
---@field difficulty string              "Orange" / "Yellow" / "Green" / "Grey"
---@field quality number                 Result item quality (0-8)

---@class PFProfession
---@field name string                    Localized profession name
---@field level number                   Current skill rank
---@field maxLevel number                Maximum skill rank
---@field recipes PFRecipe[]             Ordered list of known recipes

-- ============================================================================
-- Saved Instance Lockout
-- ============================================================================

---@class PFQuestStatus
---@field done boolean             Whether the quest is flagged completed this reset
---@field nameIdx number           1-based index into the quest definition's ids/names array

---@class PFSavedInstance
---@field name string             Instance name (e.g. "Onyxia's Lair")
---@field id number               Internal save ID from GetSavedInstanceInfo
---@field resetSeconds number     Seconds until next reset (as returned by the API)
---@field difficultyID number     Difficulty ID (0 in Classic = Normal)
---@field difficultyName string   Localised difficulty string
---@field locked boolean          true = player is locked to this save
---@field extended boolean        true = lockout has been extended
---@field isRaid boolean          true = it is a raid instance
---@field maxPlayers number       Maximum raid/party size for this lockout
---@field numEncounters number    Total boss encounters in the instance
---@field encounterProgress number  Number of bosses defeated so far

-- ============================================================================
-- Per-Character Data  (live in PrephsFrameworkCharDataDB)
-- ============================================================================
---@alias bagID number  -- 0-4 for player bags, -1 for bank main, -2 for keyring, 5-11 for bank bags
---@alias bagSlot number -- 0-# for slots within a bag

---@class PFCharacterSnapshot
---@field _schemaVersion number           Schema migration version stamp
---@field name string                    Character name
---@field realm string                   Realm name
---@field classFile string               Uppercase class token (e.g. "WARRIOR")
---@field level number                   Character level
---@field faction string                 "Alliance" or "Horde"
---@field bindLocation string             Hearthstone bind location (zone name)
---@field copper number                   Total money in copper (GetMoney())
---@field mailCopper number               Total money in mailbox attachments (copper)
---@field lastSeen number                time() of last logout / snapshot
---@field zoneName string                Last known zone (GetZoneText)
---@field subZoneName string             Last known sub-zone (GetSubZoneText)
---@field accountGUID string              Player GUID used for same-account detection
---@field itemCounts table<itemID, PFItemCount>          Aggregate counts for every item seen
---@field equippables table<slotKey, PFEquippableItem>   Individual equippable instances
---@field professions table<string, PFProfession>        Profession data keyed by profession name
---@field bankAvailable boolean          true if bank was scanned at least once this session
---@field savedInstances PFSavedInstance[]              Active (locked) instance lockouts
---@field weeklyQuests table<number, PFQuestStatus>     index → completion status (this reset)
---@field dailyQuests table<number, PFQuestStatus>      index → completion status (this reset)
-- ============================================================================
-- CharData namespace — attached to Core.data.charData
-- ============================================================================

---@class PrephsFramework.data.charData
local charData = Core.data.charData