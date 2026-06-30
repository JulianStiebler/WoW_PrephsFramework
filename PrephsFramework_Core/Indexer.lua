--[[
    <PrephsFramework_Core/Indexer.lua>
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

---@type PrephsFramework.Logger
local logger = Core.Logger
local Util = Core.Util

-- ============================================================================
-- Core.Indexer — Dual-track item & profession indexing subsystem
-- ============================================================================
--
-- Two parallel data structures live inside Core.CharData:
--
--   itemCounts[itemID]       → PFItemCount   (aggregate stack counts per location)
--   equippables[slotKey]     → PFEquippableItem (individual gear instances with
--                              enchant, rune, gem, suffix, uniqueID)
--
-- itemCounts is the fast-path for "how many of X do I own?" queries (Tooltipper,
-- recipe mat checks, cross-character totals).
--
-- equippables is the per-instance detail path for the Equipper / gear manager.
-- Each physical equippable item is keyed by its current location:
--   "e:<slotID>"         — worn equipment slot (1-19)
--   "b:<bagID>:<bagSlot>"  — player bag (0-4)
--   "k:<bagID>:<bagSlot>"  — bank bag (-1, 5-11)
--
-- On logout both structures are serialised + compressed via Serializer:Pack
-- into PrephsFrameworkCharDataDB, and a snapshot is written to the account-wide
-- DB for cross-character access (see Database.lua).
-- ============================================================================

---@class PrephsFramework.Indexer
local Indexer = Core.Indexer

-- Lazy activation flag — events are only registered when a consumer needs them
local _active = false

-- ============================================================================
-- Scan Throttle
-- ============================================================================
-- Each scan category uses a throttle (not a trailing-edge debounce):
-- the first event in a category schedules a scan after SCAN_THROTTLE seconds;
-- subsequent events within that window are silently batched and do NOT reset
-- the timer.  This ensures periodic updates during sustained bursts (e.g.
-- mailbox "Open All") instead of postponing the scan indefinitely.
--
-- After the scan function runs, registered callbacks are fired so consumers
-- (e.g. Tooltipper sync, tooltip cache) can react to fresh data.
-- ============================================================================

local SCAN_THROTTLE = 1.0    -- seconds; first event → scan fires after this
local _scanPending  = {}     -- category → true when a scan is already scheduled
local C_Timer       = C_Timer

-- ============================================================================
-- Scan Callbacks
-- ============================================================================
-- Consumers register a callback via Indexer:RegisterScanCallback(fn).
-- fn(category) is called after each throttled scan completes, with the
-- category string ("bags", "mail", "equip", "prof", etc.).
-- ============================================================================

local _scanCallbacks = {}

--- Register a function to be called after any throttled scan completes.
---@param fn fun(category: string)
function Indexer:RegisterScanCallback(fn)
    _scanCallbacks[#_scanCallbacks + 1] = fn
end

--- Unregister a previously registered scan callback.
---@param fn function
function Indexer:UnregisterScanCallback(fn)
    for i = #_scanCallbacks, 1, -1 do
        if _scanCallbacks[i] == fn then
            table.remove(_scanCallbacks, i)
            return
        end
    end
end

local function FireScanCallbacks(category)
    for _, fn in ipairs(_scanCallbacks) do
        fn(category)
    end
end

--- Schedule a throttled scan.  `category` is an arbitrary string key;
--- `scanFn` is the function to call when the timer fires.
--- First event in a category starts the timer; subsequent events within
--- the window are silently batched (the timer is NOT reset).
local function DebounceScan(category, scanFn)
    if _scanPending[category] then return end
    _scanPending[category] = true
    C_Timer.After(Core.DB.shared.updateInterval or 0.5, function()
        _scanPending[category] = nil
        scanFn()
        FireScanCallbacks(category)
    end)
end

-- ============================================================================
-- Localise WoW API
-- ============================================================================

local C_Container               = C_Container
local GetContainerNumSlots      = C_Container and C_Container.GetContainerNumSlots
local GetContainerItemInfo      = C_Container and C_Container.GetContainerItemInfo
local C_Item                    = C_Item
local GetInventoryItemLink      = GetInventoryItemLink
local GetInventoryItemID        = GetInventoryItemID
local GetInventoryItemTexture   = GetInventoryItemTexture
local GetItemInfo               = GetItemInfo
local GetItemCount              = GetItemCount
local GetInboxNumItems          = GetInboxNumItems
local GetInboxHeaderInfo        = GetInboxHeaderInfo
local GetInboxItemLink          = GetInboxItemLink
local GetInboxItem              = GetInboxItem
local GetTradeSkillLine         = GetTradeSkillLine
local GetNumTradeSkills         = GetNumTradeSkills
local GetTradeSkillInfo         = GetTradeSkillInfo
local GetTradeSkillItemLink     = GetTradeSkillItemLink
local GetCraftDisplaySkillLine  = GetCraftDisplaySkillLine
local GetNumCrafts              = GetNumCrafts
local GetCraftInfo              = GetCraftInfo
local GetCraftItemLink          = GetCraftItemLink
local GetInventoryItemsForSlot  = GetInventoryItemsForSlot
local GetNumSkillLines          = GetNumSkillLines
local GetSkillLineInfo          = GetSkillLineInfo
local GetBindLocation           = GetBindLocation
local GetMoney                  = GetMoney
local GetNumSavedInstances      = GetNumSavedInstances
local GetSavedInstanceInfo      = GetSavedInstanceInfo
local GetNumAuctionItems        = GetNumAuctionItems
local GetAuctionItemInfo        = GetAuctionItemInfo
local GetAuctionItemTimeLeft    = GetAuctionItemTimeLeft
local GetAuctionItemLink        = GetAuctionItemLink
local SendMail                  = SendMail
local IsQuestFlaggedCompleted   = C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted
local GetSpellCooldown          = GetSpellCooldown
local GetSpellInfo              = GetSpellInfo
local wipe                      = wipe
local pairs                     = pairs
local ipairs                    = ipairs
local select                    = select
local tonumber                  = tonumber
local time                      = time
local type                      = type
local pcall                     = pcall
local string_format             = string.format
local string_match              = string.match
local string_find               = string.find
local table_insert              = table.insert

-- Detect SoD rune API availability (Season of Discovery)
local C_Engraving = C_Engraving
local isSoD = Core.Constants.Version.IsSoD

-- ============================================================================
-- SoD Rune resolver
-- ============================================================================
-- In Season of Discovery, engravings are per-equipment-slot.
-- C_Engraving.GetRuneForEquipmentSlot(slotID) → runeSpellID | nil

---@param equipSlotID number  Equipment slot 1-19
---@return number|nil runeSpellID
local function GetRuneForSlot(equipSlotID)
    if not isSoD then return nil end
    local ok, result = pcall(C_Engraving.GetRuneForEquipmentSlot, equipSlotID)
    if not ok or not result then return nil end

    -- The API returns a table with skillLineAbilityID, itemEnchantmentID, etc.
    if type(result) == "table" then
        return result.skillLineAbilityID or result.itemEnchantmentID
    end

    -- Fallback: if ever a plain number
    if type(result) == "number" and result > 0 then
        return result
    end
    return nil
end

-- ============================================================================
-- Difficulty label helper (Classic profession UI)
-- ============================================================================

---@param skillType string  "optimal"|"medium"|"easy"|"trivial"
---@return string difficultyName
local function GetDifficultyLabel(skillType)
    if skillType == "optimal" then return "Orange"
    elseif skillType == "medium" then return "Yellow"
    elseif skillType == "easy"   then return "Green"
    elseif skillType == "trivial" then return "Grey"
    end
    return "Unknown"
end

-- ============================================================================
-- Internal: itemCounts helpers
-- ============================================================================

--- Ensure a PFItemCount row exists for the given itemID, creating it from
--- GetItemInfo when first seen.  Returns the row (never nil).
---@param counts table<number, PFItemCount>
---@param itemID number
---@param link string|nil
---@param quality number|nil
---@param icon number|string|nil
---@return PFItemCount
local function EnsureCountRow(counts, itemID, link, quality, icon)
    local row = counts[itemID]
    if row then
        -- Keep freshest link / icon
        if link then row.itemLink = link end
        if icon then row.icon = icon end
        return row
    end

    local name, _, iq, _, _, iType, iSubType, _, equipLoc, iIcon, sellPrice =
        GetItemInfo(link or itemID)

    row = {
        itemID       = itemID,
        name         = name or "",
        itemLink     = link or "",
        quality      = quality or iq or 0,
        icon         = icon or iIcon or 0,
        bags         = 0,
        bank         = 0,
        mail         = 0,
        ah           = 0,
        equipped     = 0,
        total        = 0,
        bagsCharges  = 0,   -- sum of charges on items in bags
        bankCharges  = 0,   -- sum of charges on items in bank
        totalCharges = 0,   -- bagsCharges + bankCharges
        itemType     = iType,
        itemSubType  = iSubType,
        equipLoc     = equipLoc,
        sellPrice    = sellPrice or 0,
        isEquippable = (equipLoc ~= nil and equipLoc ~= ""),
    }
    counts[itemID] = row
    return row
end

--- Add `count` items to a specific location field and refresh the total.
---@param row PFItemCount
---@param location "bags"|"bank"|"mail"|"equipped"|"ah"
---@param count number
local function AddCount(row, location, count)
    row[location] = row[location] + count
    row.total = row.bags + row.bank + row.mail + (row.ah or 0) + row.equipped
end

--- Zero out one location field across all rows; prune rows that hit zero.
---@param counts table<number, PFItemCount>
---@param field "bags"|"bank"|"mail"|"equipped"|"ah"
local function ResetLocationCounts(counts, field)
    for id, row in pairs(counts) do
        row[field] = 0
        -- Reset the parallel charges field if it exists (bags / bank only)
        local cf = field .. "Charges"
        if row[cf] then
            row[cf] = 0
            row.totalCharges = (row.bagsCharges or 0) + (row.bankCharges or 0)
        end
        row.total = row.bags + row.bank + row.mail + (row.ah or 0) + row.equipped
        if row.total == 0 then
            counts[id] = nil
        end
    end
end

-- ============================================================================
-- Internal: equippables helpers
-- ============================================================================

--- Wipe all equippable entries whose slotKey starts with a given prefix.
---@param equippables table<string, PFEquippableItem>
---@param prefix string  e.g. "e:", "b:", "k:"
local function WipeEquippablesByPrefix(equippables, prefix)
    local toRemove = {}
    for key in pairs(equippables) do
        if string_find(key, prefix, 1, true) == 1 then
            toRemove[#toRemove + 1] = key
        end
    end
    for _, key in ipairs(toRemove) do
        equippables[key] = nil
    end
end

--- Build a PFEquippableItem from an item link and location metadata.
---@param itemLink string
---@param slotKey string
---@param equipSlotID number|nil
---@param bagID number|nil
---@param bagSlot number|nil
---@param quality number|nil
---@param icon number|nil
---@param runeSpellID number|nil
---@return PFEquippableItem
local function BuildEquippableEntry(itemLink, slotKey, equipSlotID, bagID, bagSlot, quality, icon, runeSpellID)
    local parsedID, enchant, g1, g2, g3, g4, suffix, uid = Util:ParseItemLink(itemLink)
    local name, _, iq, _, _, _, iSubType, _, equipLoc, iIcon =
        GetItemInfo(itemLink)

    return {
        itemID      = parsedID,
        itemLink    = itemLink,
        name        = name or "",
        quality     = quality or iq or 0,
        icon        = icon or iIcon or 0,
        equipLoc    = equipLoc or "",
        itemSubType = iSubType,
        slotKey     = slotKey,
        equipSlotID = equipSlotID,
        bagID       = bagID,
        bagSlot     = bagSlot,
        enchantID   = enchant,
        gem1        = g1,
        gem2        = g2,
        gem3        = g3,
        gem4        = g4,
        suffixID    = suffix,
        uniqueID    = uid,
        runeSpellID = runeSpellID,
    }
end

-- ============================================================================
-- Location Scanners
-- ============================================================================

--- Scan player bags (0-4).
function Indexer:ScanBags()
    local cd = Core.CharData
    if not cd then return end

    local counts = cd.itemCounts
    local equips = cd.equippables

    -- Reset bag counts & bag-located equippables
    ResetLocationCounts(counts, "bags")
    WipeEquippablesByPrefix(equips, "b:")

    for bag = 0, 4 do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots and numSlots > 0 then
            for slot = 1, numSlots do
                local info = GetContainerItemInfo(bag, slot)
                if info and info.itemID then
                    local row = EnsureCountRow(counts, info.itemID, info.hyperlink, info.quality, info.iconFileID)
                    AddCount(row, "bags", info.stackCount or 1)

                    -- Track individual equippable instances in bags
                    if row.isEquippable and info.hyperlink then
                        local sk = string_format("b:%d:%d", bag, slot)
                        equips[sk] = BuildEquippableEntry(
                            info.hyperlink, sk, nil, bag, slot, info.quality, info.iconFileID, nil
                        )
                    end
                end
            end
        end
    end

    -- Scan keyring (bag -2)
    local keyringSlots = GetContainerNumSlots(-2)
    if keyringSlots and keyringSlots > 0 then
        for slot = 1, keyringSlots do
            local info = GetContainerItemInfo(-2, slot)
            if info and info.itemID then
                local row = EnsureCountRow(counts, info.itemID, info.hyperlink, info.quality, info.iconFileID)
                AddCount(row, "bags", info.stackCount or 1)
            end
        end
    end

    -- Resolve charges via GetItemCount (info.charges is not available in Classic)
    for itemID, row in pairs(counts) do
        if row.bags > 0 or row.equipped > 0 then
            local normalCount  = GetItemCount(itemID, false, false)
            local chargeCount  = GetItemCount(itemID, false, true)
            if chargeCount ~= normalCount and chargeCount > 0 then
                row.bagsCharges = chargeCount
            else
                row.bagsCharges = 0
            end
            row.totalCharges = row.bagsCharges + row.bankCharges
        end
    end

    logger:debug("Indexer: Bags scanned")
end

--- Scan equipped gear (slots 1-19).
function Indexer:ScanEquipment()
    local cd = Core.CharData
    if not cd then return end

    local counts = cd.itemCounts
    local equips = cd.equippables

    ResetLocationCounts(counts, "equipped")
    WipeEquippablesByPrefix(equips, "e:")

    for slot = 1, 19 do
        local itemLink = GetInventoryItemLink("player", slot)
        if itemLink then
            local itemID  = GetInventoryItemID("player", slot)
            local texture = GetInventoryItemTexture("player", slot)
            local _, _, quality = GetItemInfo(itemLink)

            local row = EnsureCountRow(counts, itemID, itemLink, quality, texture)
            AddCount(row, "equipped", 1)

            local sk = string_format("e:%d", slot)
            local rune = GetRuneForSlot(slot)
            equips[sk] = BuildEquippableEntry(
                itemLink, sk, slot, nil, nil, quality, texture, rune
            )
        end
    end

    logger:debug("Indexer: Equipment scanned")
end

--- Scan bank bags (-1 main bank, 5-11 bank bag slots).
function Indexer:ScanBank()
    local cd = Core.CharData
    if not cd then return end

    local counts = cd.itemCounts
    local equips = cd.equippables

    ResetLocationCounts(counts, "bank")
    WipeEquippablesByPrefix(equips, "k:")

    local bankBags = { -1, 5, 6, 7, 8, 9, 10, 11 }
    for _, bag in ipairs(bankBags) do
        local numSlots = GetContainerNumSlots(bag)
        if numSlots and numSlots > 0 then
            for slot = 1, numSlots do
                local info = GetContainerItemInfo(bag, slot)
                if info and info.itemID then
                    local row = EnsureCountRow(counts, info.itemID, info.hyperlink, info.quality, info.iconFileID)
                    AddCount(row, "bank", info.stackCount or 1)

                    if row.isEquippable and info.hyperlink then
                        local sk = string_format("k:%d:%d", bag, slot)
                        equips[sk] = BuildEquippableEntry(
                            info.hyperlink, sk, nil, bag, slot, info.quality, info.iconFileID, nil
                        )
                    end
                end
            end
        end
    end

    -- Resolve bank charges via GetItemCount
    for itemID, row in pairs(counts) do
        if row.bank > 0 then
            local totalCharges = GetItemCount(itemID, true, true)
            local totalNormal  = GetItemCount(itemID, true, false)
            if totalCharges ~= totalNormal and totalCharges > 0 then
                row.bankCharges = totalCharges - row.bagsCharges
                if row.bankCharges < 0 then row.bankCharges = 0 end
            else
                row.bankCharges = 0
            end
            row.totalCharges = row.bagsCharges + row.bankCharges
        end
    end

    cd.bankAvailable = true
    logger:debug("Indexer: Bank scanned")
end

--- Scan mailbox items (counts only — mail items are not equippable in-place).
--- Clears any pending mail forecasts for the current character since the
--- real inbox data is now authoritative.
function Indexer:ScanMail()
    local cd = Core.CharData
    if not cd then return end

    -- Real mail data supersedes forecasts
    self:ClearMailForecasts()

    local counts = cd.itemCounts
    ResetLocationCounts(counts, "mail")

    local totalMailCopper = 0
    local numMails = GetInboxNumItems()
    for i = 1, numMails do
        local _, _, _, _, money, _, _, attachCount = GetInboxHeaderInfo(i)
        if money and money > 0 then
            totalMailCopper = totalMailCopper + money
        end
        attachCount = attachCount or 0
        if attachCount > 0 then
            for j = 1, attachCount do
                local itemLink = GetInboxItemLink(i, j)
                local _, itemID, texture, count, quality = GetInboxItem(i, j)
                if itemID then
                    if not itemLink then
                        itemLink = select(2, GetItemInfo(itemID))
                    end
                    local row = EnsureCountRow(counts, itemID, itemLink, quality, texture)
                    AddCount(row, "mail", count or 1)
                end
            end
        end
    end

    cd.mailCopper = totalMailCopper
    logger:debug("Indexer: Mail scanned (%d copper in mail)", totalMailCopper)
end

-- ============================================================================
-- Auction House Scanner
-- ============================================================================

--- Scan the player's owned auction house listings (counts + expiry).
--- Only available while the AH UI is open (AUCTION_OWNED_LIST_UPDATE).
---
--- Captures GetAuctionItemTimeLeft per listing and stores the per-item
--- earliest expiry epoch on the PFItemCount row (ahExpiry) as well as
--- a global CharData.ahNextExpiry for cheap "has anything expired?" checks.
function Indexer:ScanAuctionHouse()
    local cd = Core.CharData
    if not cd then return end
    if not GetNumAuctionItems then return end

    local counts = cd.itemCounts
    ResetLocationCounts(counts, "ah")

    -- Clear per-row ahExpiry before rebuilding
    for _, row in pairs(counts) do
        row.ahExpiry = nil
    end

    local _, numOwned = GetNumAuctionItems("owner")
    if not numOwned or numOwned == 0 then
        cd.ahNextExpiry = 0
        logger:debug("Indexer: AH scanned (0 owned auctions)")
        return
    end

    -- Pessimistic upper-bound durations (seconds) for each time-left tier.
    -- Using upper bounds so forecasts don't fire prematurely.
    local AH_TIER_SECONDS = { [1] = 1800, [2] = 7200, [3] = 43200, [4] = 172800 }

    local now = time()
    local globalEarliest = 0  -- 0 = none

    for i = 1, numOwned do
        local name, texture, stackCount, quality, _, _, _, _, _, _, _, _,
              _, _, _, _, itemID = GetAuctionItemInfo("owner", i)
        if itemID and itemID > 0 then
            local link = GetAuctionItemLink("owner", i)
            local row = EnsureCountRow(counts, itemID, link, quality, texture)
            AddCount(row, "ah", stackCount or 1)

            -- Capture expiry
            local tier = GetAuctionItemTimeLeft and GetAuctionItemTimeLeft("owner", i) or 4
            local expiresAt = now + (AH_TIER_SECONDS[tier] or 172800)
            if not row.ahExpiry or expiresAt < row.ahExpiry then
                row.ahExpiry = expiresAt
            end
            if globalEarliest == 0 or expiresAt < globalEarliest then
                globalEarliest = expiresAt
            end
        end
    end

    cd.ahNextExpiry = globalEarliest
    logger:debug("Indexer: AH scanned (%d owned auctions, next expiry in %ds)",
        numOwned, globalEarliest > 0 and (globalEarliest - now) or 0)
end

-- ============================================================================
-- AH → Mail Forecast Processor
-- ============================================================================
-- Called on BAG_UPDATE_DELAYED (piggybacks on the bags scan — no timers).
-- If ahNextExpiry has passed, move expired AH rows into mailForecasts and
-- zero the AH counts.  This is intentionally pessimistic: the actual mail
-- arrival may lag a few minutes behind, but the forecast gives the user
-- early visibility.

--- Check whether any AH listings have expired and convert them to mail
--- forecasts.  Designed to run cheaply inside the bag-scan path.
function Indexer:ProcessAhExpiry()
    local cd = Core.CharData
    if not cd then return end

    local expiry = cd.ahNextExpiry or 0
    if expiry == 0 or time() < expiry then return end  -- nothing due yet

    local counts = cd.itemCounts
    if not counts then return end

    cd.mailForecasts = cd.mailForecasts or {}
    local forecasts = cd.mailForecasts
    local movedAny = false
    local newEarliest = 0

    for itemID, row in pairs(counts) do
        if (row.ah or 0) > 0 then
            local rowExpiry = row.ahExpiry or 0
            if rowExpiry > 0 and time() >= rowExpiry then
                -- Move AH count → mail forecast
                local fc = forecasts[itemID]
                if fc then
                    fc.count = fc.count + row.ah
                else
                    forecasts[itemID] = {
                        count     = row.ah,
                        source    = "ah",
                        expiresAt = nil,  -- cleared when real mail scan runs
                    }
                end
                row.ah = 0
                row.ahExpiry = nil
                row.total = row.bags + row.bank + row.mail + row.equipped
                if row.total == 0 and not next(forecasts[itemID] and {} or {}) then
                    -- keep row alive if forecast exists
                end
                movedAny = true
            else
                -- This row hasn't expired yet — track the next earliest
                if rowExpiry > 0 and (newEarliest == 0 or rowExpiry < newEarliest) then
                    newEarliest = rowExpiry
                end
            end
        end
    end

    cd.ahNextExpiry = newEarliest
    if movedAny then
        logger:debug("Indexer: AH items moved to mail forecasts (next expiry: %d)", newEarliest)
        FireScanCallbacks("forecast")
    end
end

-- ============================================================================
-- Mail Forecast API
-- ============================================================================
-- Called by Tooltipper when the player sends mail to one of their own
-- characters.  Creates a forecast entry on the target character's snapshot
-- so item counts appear immediately.

--- Record an incoming-mail forecast on a target character's snapshot.
--- Works for local snapshots, remote synced snapshots, and the live CharData.
---@param targetCharKey string  "Name-Realm" of the recipient
---@param itemID number
---@param count number
function Indexer:RecordMailForecast(targetCharKey, itemID, count)
    if not itemID or not count or count <= 0 then return end

    local data
    local currentKey = Core:GetCharKey()
    if targetCharKey == currentKey then
        data = Core.CharData
    else
        data = Core:GetCharSnapshot(targetCharKey)
            or Core:GetSyncedSnapshot(targetCharKey)
    end
    if not data then return end

    data.mailForecasts = data.mailForecasts or {}
    local fc = data.mailForecasts[itemID]
    if fc then
        fc.count = fc.count + count
    else
        data.mailForecasts[itemID] = {
            count     = count,
            source    = "sent",
            expiresAt = nil,
        }
    end

    logger:debug("Indexer: Mail forecast +%d of item %d for '%s'", count, itemID, targetCharKey)
    FireScanCallbacks("forecast")
end

--- Clear mail forecasts for a character when a real mail scan provides
--- authoritative data.  Called automatically at the start of ScanMail.
---@param charKey string|nil  Defaults to current character
function Indexer:ClearMailForecasts(charKey)
    local data
    if not charKey or charKey == Core:GetCharKey() then
        data = Core.CharData
    else
        data = Core:GetCharSnapshot(charKey)
            or Core:GetSyncedSnapshot(charKey)
    end
    if not data then return end
    if data.mailForecasts and next(data.mailForecasts) then
        wipe(data.mailForecasts)
        logger:debug("Indexer: Mail forecasts cleared for '%s'", charKey or Core:GetCharKey())
    end
end

--- Handle auction cancellation: move the cancelled listing to a mail forecast
--- for the current character, since cancelled items are returned via mail.
--- Called from a hooksecurefunc on CancelAuction — the auction data is still
--- readable because the cancel is a server request (list updates on response).
---@param index number  Auction index in the "owner" list
function Indexer:OnAuctionCancelled(index)
    local cd = Core.CharData
    if not cd then return end
    if not GetAuctionItemLink or not GetAuctionItemInfo then return end

    local link = GetAuctionItemLink("owner", index)
    if not link then return end

    local itemID = tonumber(link:match("item:(%d+)"))
    if not itemID then return end

    local _, _, stackCount = GetAuctionItemInfo("owner", index)
    if not stackCount or stackCount <= 0 then stackCount = 1 end

    -- Record mail forecast for self
    local charKey = Core:GetCharKey()
    self:RecordMailForecast(charKey, itemID, stackCount)

    -- Reduce AH counts immediately
    if cd.itemCounts and cd.itemCounts[itemID] then
        local row = cd.itemCounts[itemID]
        row.ah = (row.ah or 0) - stackCount
        if row.ah < 0 then row.ah = 0 end
        row.total = row.bags + row.bank + row.mail + (row.ah or 0) + row.equipped
    end
end

-- ============================================================================
-- Instance Lockout Scanner
-- ============================================================================

--- Scan current saved-instance lockouts and store them in CharData.
--- Only locked instances are recorded; unlocked ones are omitted.
function Indexer:ScanInstances()
    local cd = Core.CharData
    if not cd then return end

    cd.savedInstances = cd.savedInstances or {}
    -- Wipe and rebuild
    for k in pairs(cd.savedInstances) do cd.savedInstances[k] = nil end

    if not GetNumSavedInstances then return end
    local count = GetNumSavedInstances()
    for i = 1, count do
        local name, id, reset, difficultyID, locked, extended,
              _, isRaid, maxPlayers, difficultyName,
              numEncounters, encounterProgress = GetSavedInstanceInfo(i)
        if locked then
            cd.savedInstances[#cd.savedInstances + 1] = {
                name              = name or "",
                id                = id or 0,
                resetSeconds      = reset or 0,
                difficultyID      = difficultyID or 0,
                difficultyName    = difficultyName or "",
                locked            = true,
                extended          = extended or false,
                isRaid            = isRaid or false,
                maxPlayers        = maxPlayers or 0,
                numEncounters     = numEncounters or 0,
                encounterProgress = encounterProgress or 0,
            }
        end
    end

    logger:debug("Indexer: Instances scanned (%d locked)", #cd.savedInstances)
end

-- ============================================================================
-- Weekly Quest Scanner
-- ============================================================================

--- Scan known weekly quest IDs (from Core.data.weeklyQuestDefs) and record
--- whether each one is flagged completed this reset cycle.
function Indexer:ScanWeeklyQuests()
    local cd = Core.CharData
    if not cd then return end

    cd.weeklyQuests = cd.weeklyQuests or {}
    for k in pairs(cd.weeklyQuests) do cd.weeklyQuests[k] = nil end

    if not IsQuestFlaggedCompleted then return end
    local defs = Core.data.weeklyQuestDefs
    if not defs or #defs == 0 then return end

    local factionMap = { Horde = 0, Alliance = 1 }
    local myFaction  = factionMap[cd.faction]

    for i, def in ipairs(defs) do
        if def.faction == nil or def.faction == myFaction then
            local done = false
            local matchedIdx = 1
            for j, qid in ipairs(def.ids) do
                if IsQuestFlaggedCompleted(qid) then
                    done = true
                    matchedIdx = j
                    break
                end
            end
            cd.weeklyQuests[i] = { done = done, nameIdx = matchedIdx }
        end
    end

    logger:debug("Indexer: Weekly quests scanned (%d checked)", #defs)
end

-- ============================================================================
-- Daily Quest Scanner
-- ============================================================================

--- Scan known daily quest IDs (from Core.data.dailyQuestDefs) and record
--- whether each one is flagged completed this reset cycle.
function Indexer:ScanDailyQuests()
    local cd = Core.CharData
    if not cd then return end

    cd.dailyQuests = cd.dailyQuests or {}
    for k in pairs(cd.dailyQuests) do cd.dailyQuests[k] = nil end

    if not IsQuestFlaggedCompleted then return end
    local defs = Core.data.dailyQuestDefs
    if not defs or #defs == 0 then return end

    local factionMap = { Horde = 0, Alliance = 1 }
    local myFaction  = factionMap[cd.faction]

    for i, def in ipairs(defs) do
        if def.faction == nil or def.faction == myFaction then
            local done = false
            local matchedIdx = 1
            for j, qid in ipairs(def.ids) do
                if IsQuestFlaggedCompleted(qid) then
                    done = true
                    matchedIdx = j
                    break
                end
            end
            cd.dailyQuests[i] = { done = done, nameIdx = matchedIdx }
        end
    end

    logger:debug("Indexer: Daily quests scanned (%d checked)", #defs)
end

-- ============================================================================
-- Profession Scanner
-- ============================================================================

--- Scan the currently open trade-skill / craft window into professions data.
function Indexer:ScanProfessions()
    local cd = Core.CharData
    if not cd then return end

    if not cd.professions then
        cd.professions = {}
    end

    -- A. Standard Trade Skills (Alchemy, Blacksmithing, …)
    local tradeName, currentRank, maxRank = GetTradeSkillLine()
    if tradeName and tradeName ~= "UNKNOWN" then
        local prof = {
            name     = tradeName,
            level    = currentRank,
            maxLevel = maxRank,
            recipes  = {},
        }

        local numSkills = GetNumTradeSkills()
        for i = 1, numSkills do
            local skillName, skillType = GetTradeSkillInfo(i)
            if skillName and skillType ~= "header" then
                local link = GetTradeSkillItemLink(i)
                local diffName = GetDifficultyLabel(skillType)

                local recipeQuality = 1
                if link then
                    local _, _, q = GetItemInfo(link)
                    if q then recipeQuality = q end
                end

                prof.recipes[#prof.recipes + 1] = {
                    name       = skillName,
                    link       = link or skillName,
                    difficulty = diffName,
                    quality    = recipeQuality,
                }
            end
        end

        cd.professions[tradeName] = prof
        logger:debug("Indexer: %s (%d/%d, %d recipes) indexed", tradeName, currentRank, maxRank, #prof.recipes)
        return
    end

    -- B. Craft-style skills (Enchanting in Classic)
    local craftName, cRank, cMax = GetCraftDisplaySkillLine()
    if craftName and craftName ~= "UNKNOWN" then
        local prof = {
            name     = craftName,
            level    = cRank,
            maxLevel = cMax,
            recipes  = {},
        }

        local numCrafts = GetNumCrafts()
        for i = 1, numCrafts do
            local craftItemName, _, craftType = GetCraftInfo(i)
            if craftItemName and craftType ~= "header" then
                local diffName = GetDifficultyLabel(craftType)
                local link = GetCraftItemLink(i)

                prof.recipes[#prof.recipes + 1] = {
                    name       = craftItemName,
                    link       = link or craftItemName,
                    difficulty = diffName,
                    quality    = 1,
                }
            end
        end

        cd.professions[craftName] = prof
        logger:debug("Indexer: %s (%d/%d, %d recipes) indexed", craftName, cRank, cMax, #prof.recipes)
    end
end

--- Scan the character's skill lines (Skills tab) to pick up professions that
--- have no trade window (Fishing, Riding, etc.) as well as secondary skills.
--- This only creates/updates the name + level fields — it will NOT overwrite
--- recipes that ScanProfessions already recorded from the trade window.
function Indexer:ScanSkillLines()
    local cd = Core.CharData
    if not cd then return end
    if not GetNumSkillLines then return end

    if not cd.professions then
        cd.professions = {}
    end

    -- Allowlist derived from the Professions enum (Names table).
    -- Every profession name in the enum is recognised by the skill-line scanner.
    local ProfNames = Core.Constants.ENUM.Professions.Names
    local KNOWN_PROFESSIONS = {}
    for _, name in pairs(ProfNames) do
        KNOWN_PROFESSIONS[name] = true
    end

    local numLines = GetNumSkillLines()
    local scanned = 0

    for i = 1, numLines do
        local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
        if not skillName then break end

        if not isHeader and KNOWN_PROFESSIONS[skillName] then
            local existing = cd.professions[skillName]
            if existing then
                -- Update level but keep recipes intact
                existing.level    = skillRank  or existing.level
                existing.maxLevel = skillMaxRank or existing.maxLevel
            else
                cd.professions[skillName] = {
                    name     = skillName,
                    level    = skillRank  or 0,
                    maxLevel = skillMaxRank or 0,
                    recipes  = {},
                }
            end
            scanned = scanned + 1
        end
    end

    logger:debug("Indexer: Skill lines scanned (%d professions found)", scanned)
end

-- ============================================================================
-- Profession Cooldown Scanner
-- ============================================================================

--- Scan known profession cooldown groups (from Core.data.profCooldownDefs).
--- Each group is a set of spells sharing a single cooldown.  When any spell
--- in the group is on CD, one entry is stored per group (not per spell).
function Indexer:ScanProfessionCooldowns()
    local cd = Core.CharData
    if not cd then return end

    cd.profCooldowns = cd.profCooldowns or {}
    for k in pairs(cd.profCooldowns) do cd.profCooldowns[k] = nil end

    if not GetSpellCooldown then return end
    local defs = Core.data.profCooldownDefs
    if not defs or #defs == 0 then return end

    local now = time()
    local scanned = 0

    for gi, group in ipairs(defs) do
        local profName = group.profession
        if profName and cd.professions and cd.professions[profName] then
            -- Check each spell in the group; first one on CD wins.
            for _, spell in ipairs(group) do
                local start, duration, enabled = GetSpellCooldown(spell.spellID)
                if start and start > 0 and duration and duration > 1.5 then
                    local remaining = (start + duration) - GetTime()
                    if remaining > 0 then
                        cd.profCooldowns[gi] = {
                            label      = group.label,
                            profession = profName,
                            spellID    = spell.spellID,
                            name       = (GetSpellInfo and select(1, GetSpellInfo(spell.spellID))) or spell.name,
                            expiresAt  = now + remaining,
                        }
                        scanned = scanned + 1
                        break  -- shared CD — one hit is enough for the group
                    end
                end
            end
        end
    end

    logger:debug("Indexer: Profession cooldowns scanned (%d groups on CD)", scanned)
end

-- ============================================================================
-- Full Scan  (called on PLAYER_ENTERING_WORLD)
-- ============================================================================

--- Run a complete rescan of bags and equipment.  Bank and mail are only
--- scanned when their respective UI is open (guarded by event handlers).
function Indexer:FullScan()
    self:ScanBags()
    self:ScanEquipment()
    self:ScanInstances()
    self:ScanWeeklyQuests()
    self:ScanDailyQuests()
    self:ScanSkillLines()
    self:ScanProfessionCooldowns()
    logger:debug("Indexer: Full scan complete")
end

-- ============================================================================
-- Identity Stamp  (fills name/realm/class from Core.States)
-- ============================================================================

--- Copy identity fields from Core.States into CharData so the snapshot
--- identifies the character.  Called on login and on logout.
function Indexer:StampIdentity()
    local cd = Core.CharData
    local st = Core.States
    if not cd or not st then return end

    cd.name         = st.playerName or ""
    cd.realm         = st.playerRealm or ""
    cd.classFile     = st.playerClassFile or ""
    cd.level         = st.playerLevel or 0
    cd.faction       = st.playerFaction or ""
    cd.bindLocation  = GetBindLocation() or ""
    -- Only overwrite copper when the API returns a positive value; at
    -- PLAYER_LOGOUT GetMoney() may return 0 even when the character has
    -- gold.  The PLAYER_MONEY event keeps cd.copper accurate during the
    -- session, so we must not clobber it with a stale 0.
    local money = GetMoney()
    if money and money > 0 then
        cd.copper = money
    elseif not cd.copper then
        cd.copper = 0
    end
    cd.zoneName      = st.zoneName    or ""
    cd.subZoneName   = st.subZoneName or ""
    cd.accountGUID   = st.accountGUID or ""
end

-- ============================================================================
-- Public Query API
-- ============================================================================

--- Get aggregate item counts for a given itemID on the current character.
---@param itemID number
---@return PFItemCount|nil  nil if the item is not indexed
function Indexer:GetItemCount(itemID)
    if not _active then self:Activate() end
    local cd = Core.CharData
    if not cd or not cd.itemCounts then return nil end
    return cd.itemCounts[itemID]
end

--- Get the total count of an item across all locations.
--- Returns 0 if the item is not indexed (safe for arithmetic).
---@param itemID number
---@return number total
function Indexer:GetItemTotal(itemID)
    if not _active then self:Activate() end
    local row = self:GetItemCount(itemID)
    return row and row.total or 0
end

--- Get the total count of an item across ALL characters (current + snapshots).
--- Decompresses each snapshot on demand; callers should cache the result.
---@param itemID number
---@return number grandTotal, table<string, number> perChar  charKey → count
function Indexer:GetItemTotalAllChars(itemID)
    if not _active then self:Activate() end
    local grandTotal = 0
    local perChar = {}

    -- Current character (live data)
    local currentKey = Core:GetCharKey()
    local currentCount = self:GetItemTotal(itemID)
    if currentCount > 0 then
        perChar[currentKey] = currentCount
        grandTotal = grandTotal + currentCount
    end

    -- Other characters (snapshots)
    local keys = Core:GetAllCharKeys()
    for _, charKey in ipairs(keys) do
        if charKey ~= currentKey then
            local snapshot = Core:GetCharSnapshot(charKey)
            if snapshot and snapshot.itemCounts then
                local row = snapshot.itemCounts[itemID]
                if row and row.total > 0 then
                    perChar[charKey] = row.total
                    grandTotal = grandTotal + row.total
                end
            end
        end
    end

    return grandTotal, perChar
end

--- Return all equippable item instances on the current character.
--- The returned table is the live reference — do not wipe it.
---@return table<slotKey, PFEquippableItem>
function Indexer:GetAllEquippables()
    if not _active then self:Activate() end
    local cd = Core.CharData
    if not cd then return {} end
    return cd.equippables
end

--- Return all equippable instances of a specific itemID.
---@param itemID number
---@return PFEquippableItem[]
function Indexer:GetEquippablesByItemID(itemID)
    if not _active then self:Activate() end
    local results = {}
    local cd = Core.CharData
    if not cd then return results end

    for _, entry in pairs(cd.equippables) do
        if entry.itemID == itemID then
            results[#results + 1] = entry
        end
    end
    return results
end

--- Return the equippable currently worn in a specific equipment slot (1-19).
---@param equipSlotID number
---@return PFEquippableItem|nil
function Indexer:GetEquippedInSlot(equipSlotID)
    if not _active then self:Activate() end
    local cd = Core.CharData
    if not cd then return nil end
    return cd.equippables[string_format("e:%d", equipSlotID)]
end

--- Return all equippable instances that can go into a given inventory type.
--- Supports INVTYPE_HEAD, INVTYPE_FINGER (rings), INVTYPE_TRINKET, INVTYPE_WEAPON, etc.
---@param invType string  INVTYPE_* token
---@return PFEquippableItem[]
function Indexer:GetEquippablesForInvType(invType)
    if not _active then self:Activate() end
    local results = {}
    local cd = Core.CharData
    if not cd then return results end

    for _, entry in pairs(cd.equippables) do
        if entry.equipLoc == invType then
            results[#results + 1] = entry
        end
    end
    return results
end

--- Find which characters can craft a recipe (by recipe name, substring match).
--- Searches the current character's live data and all snapshots.
---@param searchName string  Substring to match against recipe names (case-insensitive)
---@return table<string, PFRecipe[]>  charKey → list of matching recipes
function Indexer:FindRecipeAcrossChars(searchName)
    if not _active then self:Activate() end
    local results = {}
    local needle = searchName:lower()

    local function SearchProfessions(professions, charKey)
        if not professions then return end
        for _, prof in pairs(professions) do
            if prof.recipes then
                for _, recipe in ipairs(prof.recipes) do
                    if recipe.name and recipe.name:lower():find(needle, 1, true) then
                        if not results[charKey] then results[charKey] = {} end
                        results[charKey][#results[charKey] + 1] = recipe
                    end
                end
            end
        end
    end

    -- Current character
    local currentKey = Core:GetCharKey()
    local cd = Core.CharData
    if cd then
        SearchProfessions(cd.professions, currentKey)
    end

    -- Snapshots (same account)
    local seenKeys = { [currentKey] = true }
    for _, charKey in ipairs(Core:GetAllCharKeys()) do
        if not seenKeys[charKey] then
            seenKeys[charKey] = true
            local snapshot = Core:GetCharSnapshot(charKey)
            if snapshot then
                SearchProfessions(snapshot.professions, charKey)
            end
        end
    end

    -- Synced snapshots (remote accounts via CommLink)
    for _, charKey in ipairs(Core:GetAllSyncedCharKeys()) do
        if not seenKeys[charKey] then
            seenKeys[charKey] = true
            local snapshot = Core:GetSyncedSnapshot(charKey)
            if snapshot then
                SearchProfessions(snapshot.professions, charKey)
            end
        end
    end

    return results
end

-- ============================================================================
-- Lazy Activation  (on-demand event registration + initial scan)
-- ============================================================================

--- Returns true if the Indexer is currently active (events registered,
--- scanning live data on inventory changes).
---@return boolean
function Indexer:IsActive()
    return _active
end

--- Activate the Indexer: register all inventory / profession events and run
--- an initial full scan.  Called automatically the first time any query API
--- is used, or explicitly by a consuming module (e.g. Tooltipper).
--- Calling Activate() more than once is a safe no-op.
function Indexer:Activate()
    if _active then return end
    _active = true

    -- Event Registrations  (internal prefix "_Indexer")

    Core:RegisterEvent("_Indexer", "BAG_UPDATE_DELAYED", function()
        DebounceScan("bags", function() Indexer:ScanBags() end)
        -- Piggyback: check if any AH listings have expired
        Indexer:ProcessAhExpiry()
    end)

    Core:RegisterEvent("_Indexer", "PLAYER_EQUIPMENT_CHANGED", function()
        DebounceScan("equip", function() Indexer:ScanEquipment() end)
    end)

    Core:RegisterEvent("_Indexer", "BANKFRAME_OPENED", function()
        DebounceScan("bank", function() Indexer:ScanBank() end)
    end)

    Core:RegisterEvent("_Indexer", "PLAYERBANKSLOTS_CHANGED", function()
        DebounceScan("bank", function() Indexer:ScanBank() end)
    end)

    Core:RegisterEvent("_Indexer", "PLAYERBANKBAGSLOTS_CHANGED", function()
        DebounceScan("bank", function() Indexer:ScanBank() end)
    end)

    Core:RegisterEvent("_Indexer", "MAIL_INBOX_UPDATE", function()
        DebounceScan("mail", function() Indexer:ScanMail() end)
    end)

    Core:RegisterEvent("_Indexer", "TRADE_SKILL_SHOW", function()
        DebounceScan("prof", function() Indexer:ScanProfessions(); Indexer:ScanProfessionCooldowns() end)
    end)

    Core:RegisterEvent("_Indexer", "TRADE_SKILL_UPDATE", function()
        DebounceScan("prof", function() Indexer:ScanProfessions(); Indexer:ScanProfessionCooldowns() end)
    end)

    Core:RegisterEvent("_Indexer", "CRAFT_SHOW", function()
        DebounceScan("prof", function() Indexer:ScanProfessions(); Indexer:ScanProfessionCooldowns() end)
    end)

    Core:RegisterEvent("_Indexer", "CRAFT_UPDATE", function()
        DebounceScan("prof", function() Indexer:ScanProfessions(); Indexer:ScanProfessionCooldowns() end)
    end)

    Core:RegisterEvent("_Indexer", "UPDATE_INSTANCE_INFO", function()
        DebounceScan("inst", function() Indexer:ScanInstances() end)
    end)

    Core:RegisterEvent("_Indexer", "INSTANCE_LOCK_START", function()
        DebounceScan("inst", function() Indexer:ScanInstances() end)
    end)

    Core:RegisterEvent("_Indexer", "QUEST_LOG_UPDATE", function()
        DebounceScan("quest", function() Indexer:ScanWeeklyQuests() end)
    end)

    Core:RegisterEvent("_Indexer", "AUCTION_HOUSE_SHOW", function()
        DebounceScan("ah", function() Indexer:ScanAuctionHouse() end)
    end)

    Core:RegisterEvent("_Indexer", "AUCTION_OWNED_LIST_UPDATE", function()
        DebounceScan("ah", function() Indexer:ScanAuctionHouse() end)
    end)

    -- Mail sending: capture outgoing items for forecast on the recipient
    Core:RegisterEvent("_Indexer", "MAIL_SEND_SUCCESS", function()
        FireScanCallbacks("forecast")
    end)

    -- Initial scan if CharData is already available
    if Core.CharData then
        self:StampIdentity()
        self:FullScan()
    end

    logger:debug("Indexer: Activated (events registered, initial scan complete)")
end

local _indexerEvents = {
    "BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED",
    "BANKFRAME_OPENED",
    "PLAYERBANKSLOTS_CHANGED", "PLAYERBANKBAGSLOTS_CHANGED",
    "MAIL_INBOX_UPDATE", "MAIL_SEND_SUCCESS",
    "AUCTION_HOUSE_SHOW", "AUCTION_OWNED_LIST_UPDATE",
    "TRADE_SKILL_SHOW", "TRADE_SKILL_UPDATE",
    "CRAFT_SHOW", "CRAFT_UPDATE",
    "UPDATE_INSTANCE_INFO", "INSTANCE_LOCK_START",
    "QUEST_LOG_UPDATE",
}

--- Deactivate the Indexer: unregister all inventory / profession events.
--- Does NOT wipe existing CharData — snapshots and counts remain intact for
--- the current session (and will still be saved on logout).
--- Calling Deactivate() when already inactive is a safe no-op.
function Indexer:Deactivate()
    if not _active then return end
    _active = false

    for _, eventName in ipairs(_indexerEvents) do
        Core:UnregisterEvent("_Indexer", eventName)
    end

    logger:debug("Indexer: Deactivated (events unregistered)")
end

-- ============================================================================
-- Bind Location Query API
-- ============================================================================

--- Get the current character's bind location (hearthstone destination).
---@return string bindLocation  Zone name, or "" if unknown
function Indexer:GetBindLocation()
    if not _active then self:Activate() end
    local cd = Core.CharData
    if not cd then return "" end
    return cd.bindLocation or ""
end

--- Get bind locations across ALL characters (current + snapshots).
---@return table<string, {name: string, classFile: string, bindLocation: string}>
function Indexer:GetBindLocationAllChars()
    if not _active then self:Activate() end
    local results = {}

    local currentKey = Core:GetCharKey()
    local cd = Core.CharData
    if cd and cd.bindLocation and cd.bindLocation ~= "" then
        results[currentKey] = {
            name         = cd.name or "",
            classFile    = cd.classFile or "",
            bindLocation = cd.bindLocation,
        }
    end

    for _, charKey in ipairs(Core:GetAllCharKeys()) do
        if charKey ~= currentKey then
            local snapshot = Core:GetCharSnapshot(charKey)
            if snapshot and snapshot.bindLocation and snapshot.bindLocation ~= "" then
                results[charKey] = {
                    name         = snapshot.name or "",
                    classFile    = snapshot.classFile or "",
                    bindLocation = snapshot.bindLocation,
                }
            end
        end
    end

    return results
end
