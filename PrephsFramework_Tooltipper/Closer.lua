--[[
    <PrephsFramework_Tooltipper/Closer.lua>
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

-- Get Core reference
---@type PrephsFramework
local Core = ns.PF

local MOD_ID = "Tooltipper"
local logger = Core.Logger
local Indexer = Core.Indexer
local CommLink = Core.CommLink
local Util = Core.Util


-- ============================================================================
-- Setting Helpers
-- ============================================================================

local DEFAULTS = {
    showNone              = false,
    showGold              = false,
    fontSize              = 12,
    iconSize              = 12,
    ignoreFactionTotals   = false,
    hideFaction           = false,
}

--- Read a persisted setting, falling back to the built-in default.
local function GetOpt(key)
    local v = Core:GetSetting(MOD_ID, MOD_ID, key)
    if v ~= nil then return v end
    return DEFAULTS[key]
end

--- Read a CheckboxGroup sub-option from the ExtendTooltips feature.
--- Returns false when the group is disabled or the child is unchecked.
--- Omit childKey to test the group master toggle only.
local function GetGroupOpt(groupKey, childKey)
    local group = Core:GetSetting(MOD_ID, "ExtendTooltips", groupKey)
    if not group or not group._enabled then return false end
    if childKey then return group[childKey] or false end
    return true
end

-- ============================================================================
-- Constants
-- ============================================================================

local HEARTHSTONE_ID = 6948

local COLOR_HEADER  = "|cff3FC7EB"
local COLOR_LABEL   = "|cffAAAAAA"
local COLOR_COUNT   = "|cffFFD100"
local COLOR_SYNCED  = "|cffFF8800"
local COLOR_HORDE   = "|cffFF4444"
local COLOR_ALLIANCE = "|cff4488FF"

-- The current character's faction, resolved once at load time.
local myFaction = (Core.CharData and Core.CharData.faction) or ""

--- Format a character's name for tooltip lines, with a synced indicator
--- when the entry came from a CommLink remote peer and a cross-faction
--- tag when the entry belongs to the opposite faction.
local function FormatCharName(entry)
    local prefix = entry._synced and (COLOR_SYNCED .. "~ |r") or ""
    -- Show [H] or [A] if the entry is cross-faction
    if entry._faction and entry._faction ~= "" and myFaction ~= "" and entry._faction ~= myFaction then
        if entry._faction == "Horde" then
            prefix = prefix .. COLOR_HORDE .. "[H]|r "
        elseif entry._faction == "Alliance" then
            prefix = prefix .. COLOR_ALLIANCE .. "[A]|r "
        end
    end
    return "  " .. prefix .. Util:ColoredCharName(entry.name, entry.classFile)
end

local GetItemInfo  = GetItemInfo
local pairs        = pairs
local ipairs       = ipairs
local tblsort      = table.sort
local strformat    = string.format
local tblconcat    = table.concat
local tonumber     = tonumber
local mathfloor    = math.floor
local type         = type
local C_Timer      = C_Timer
local GetMoney     = GetMoney
local GetItemSpell = GetItemSpell
local UnitBuff     = UnitBuff
local UnitDebuff   = UnitDebuff
local UnitName     = UnitName
local UnitGUID     = UnitGUID
local wipe         = wipe
local GetSendMailItem        = GetSendMailItem
local GetSendMailItemLink    = GetSendMailItemLink
local GetNormalizedRealmName = GetNormalizedRealmName
local GetRealmName           = GetRealmName
local GetActionInfo    = GetActionInfo
local GetActionTexture = GetActionTexture
local GetSpellInfo     = GetSpellInfo
local HasAction        = HasAction

-- ============================================================================
-- Helpers
-- ============================================================================

--- Walk current character + all snapshots, calling `processor(data, charKey)`.
--- When includeAll is true every known character gets an entry (processor may
--- return nil for characters without data — they are included with a fallback).
---@param processor fun(data: PFCharacterSnapshot, charKey: string): table|nil
---@param includeAll boolean?  When true, characters where processor returns nil get a stub entry
---@return table[]
local function CollectSorted(processor, includeAll)
    local entries = {}
    local currentKey = Core:GetCharKey()

    -- Refresh myFaction in case it wasn't available at load time
    if myFaction == "" and Core.CharData then
        myFaction = Core.CharData.faction or ""
    end

    -- Current character (live data)
    local cd = Core.CharData
    if cd then
        local entry = processor(cd, currentKey)
        if entry then
            entry._sortName = (cd.name or ""):lower()
            entry._faction  = cd.faction or ""
            entries[#entries + 1] = entry
        elseif includeAll then
            entries[#entries + 1] = {
                name      = cd.name or "",
                classFile = cd.classFile or "",
                _sortName = (cd.name or ""):lower(),
                _faction  = cd.faction or "",
                _empty    = true,
            }
        end
    end

    -- Other characters (snapshots from this account)
    for _, charKey in ipairs(Core:GetAllCharKeys()) do
        if charKey ~= currentKey then
            local snapshot = Core:GetCharSnapshot(charKey)
            if snapshot then
                local entry = processor(snapshot, charKey)
                if entry then
                    entry._sortName = (snapshot.name or ""):lower()
                    entry._faction  = snapshot.faction or ""
                    entries[#entries + 1] = entry
                elseif includeAll then
                    entries[#entries + 1] = {
                        name      = snapshot.name or "",
                        classFile = snapshot.classFile or "",
                        _sortName = (snapshot.name or ""):lower(),
                        _faction  = snapshot.faction or "",
                        _empty    = true,
                    }
                end
            end
        end
    end

    -- Synced characters (remote accounts via CommLink)
    local seenKeys = { [currentKey] = true }
    for _, charKey in ipairs(Core:GetAllCharKeys()) do seenKeys[charKey] = true end

    for _, charKey in ipairs(Core:GetAllSyncedCharKeys()) do
        if not seenKeys[charKey] then
            seenKeys[charKey] = true
            local snapshot = Core:GetSyncedSnapshot(charKey)
            if snapshot then
                local entry = processor(snapshot, charKey)
                if entry then
                    entry._sortName = (snapshot.name or ""):lower()
                    entry._faction  = snapshot.faction or ""
                    entry._synced   = true
                    entries[#entries + 1] = entry
                elseif includeAll then
                    entries[#entries + 1] = {
                        name      = snapshot.name or "",
                        classFile = snapshot.classFile or "",
                        _sortName = (snapshot.name or ""):lower(),
                        _faction  = snapshot.faction or "",
                        _empty    = true,
                        _synced   = true,
                    }
                end
            end
        end
    end

    tblsort(entries, function(a, b) return a._sortName < b._sortName end)
    return entries
end

-- ============================================================================
-- Tooltip Line Cache
-- ============================================================================
-- Pre-built tooltip line data is cached per itemID so that repeated
-- OnTooltipSetItem calls (which fire every frame while hovering) only
-- replay cheap AddLine calls instead of re-iterating all snapshots.
--
-- Line format: { left }            → tooltip:AddLine(left)
--              { left, right }     → tooltip:AddDoubleLine(left, right)
-- ============================================================================

local _lineCache  = {}   -- [itemID] = { lines = {...}, v = number }
local _cacheVer   = 0    -- bumped when underlying data changes

local function InvalidateLineCache()
    _cacheVer = _cacheVer + 1
    -- If ItemRefTooltip is open (clicked item link), force it to re-render
    -- so it picks up the new cache data immediately.
    if ItemRefTooltip and ItemRefTooltip:IsShown() then
        local _, itemLink = ItemRefTooltip:GetItem()
        if itemLink then
            ItemRefTooltip._prephsItemID = nil
            ItemRefTooltip._prephsCacheVer = nil
            ItemRefTooltip:SetHyperlink(itemLink)
        end
    end
end

local function ReplayLines(tooltip, lines)
    local fontSize = GetOpt("fontSize")
    for i = 1, #lines do
        local l = lines[i]
        if l[2] then
            tooltip:AddDoubleLine(l[1], l[2], nil, nil, nil, nil, nil, nil)
        else
            tooltip:AddLine(l[1], nil, nil, nil, false)
        end
    end
    -- Apply font size to the lines we just added
    local tooltipName = tooltip:GetName()
    for i = tooltip:NumLines(), tooltip:NumLines() - #lines + 1, -1 do
        local left = _G[tooltipName .. "TextLeft" .. i]
        local right = _G[tooltipName .. "TextRight" .. i]
        if left then
            local font, _, flags = left:GetFont()
            left:SetFont(font, fontSize, flags)
        end
        if right and right:GetText() then
            local font, _, flags = right:GetFont()
            right:SetFont(font, fontSize, flags)
        end
    end
end

-- ============================================================================
-- Helpers: cross-faction filtering
-- ============================================================================

--- Returns true when `entry` belongs to the opposing faction.
local function IsCrossFaction(entry)
    local f = entry._faction
    return f and f ~= "" and myFaction ~= "" and f ~= myFaction
end

-- ============================================================================
-- Tooltip Section: Hearthstone (bind locations + optional gold)
-- ============================================================================

local function BuildHearthstoneLines()
    local showGold            = GetOpt("showGold")
    local showNone            = GetOpt("showNone")
    local iconSize            = GetOpt("iconSize")
    local hideFaction         = GetOpt("hideFaction")
    local ignoreFactionTotals = GetOpt("ignoreFactionTotals")

    local entries = CollectSorted(function(data)
        local loc = data.bindLocation
        if not showNone and (not loc or loc == "") then return nil end
        return {
            name         = data.name or "",
            classFile    = data.classFile or "",
            bindLocation = loc or "",
            copper       = data.copper or 0,
            mailCopper   = data.mailCopper or 0,
        }
    end, showNone)

    -- Remove opposing-faction entries when hideFaction is enabled
    if hideFaction then
        local kept = {}
        for _, e in ipairs(entries) do
            if not IsCrossFaction(e) then kept[#kept + 1] = e end
        end
        entries = kept
    end

    if #entries == 0 then return {} end

    -- Compute total gold across all listed characters (on-hand + mail)
    local totalCopper = 0
    for _, e in ipairs(entries) do
        if not (ignoreFactionTotals and IsCrossFaction(e)) then
            totalCopper = totalCopper + e.copper + e.mailCopper
        end
    end

    local lines = {}
    lines[#lines + 1] = { " " }

    local headerRight = (showGold and totalCopper > 0)
        and (COLOR_LABEL .. "Total: |r" .. Util:FormatMoney(totalCopper, iconSize))
        or nil
    lines[#lines + 1] = { COLOR_HEADER .. "Bind Locations|r", headerRight }

    local ICON_BAG  = Util:IconStr("Interface\\Icons\\INV_Misc_Bag_07_Green", iconSize)
    local ICON_MAIL = Util:IconStr("Interface\\Icons\\INV_Letter_15", iconSize)

    for _, e in ipairs(entries) do
        local loc = e.bindLocation ~= "" and (COLOR_LABEL .. e.bindLocation .. "|r") or (COLOR_LABEL .. "—|r")

        if showGold then
            if e.mailCopper > 0 then
                -- Two-line: name + hearth, then gold breakdown with bag & mail icons
                lines[#lines + 1] = { FormatCharName(e), loc }
                local goldParts = "    " .. ICON_BAG .. " " .. Util:FormatMoney(e.copper, iconSize)
                    .. "   " .. ICON_MAIL .. " " .. Util:FormatMoney(e.mailCopper, iconSize)
                lines[#lines + 1] = { goldParts }
            else
                -- Single line: name — hearth + gold
                lines[#lines + 1] = { FormatCharName(e), loc .. "  " .. Util:FormatMoney(e.copper, iconSize) }
            end
        else
            lines[#lines + 1] = { FormatCharName(e), loc }
        end
    end

    return lines
end

-- ============================================================================
-- Tooltip Section: Item Counts
-- ============================================================================

local function BuildItemCountLines(itemID)
    local showNone            = GetOpt("showNone")
    local iconSize            = GetOpt("iconSize")
    local hideFaction         = GetOpt("hideFaction")
    local ignoreFactionTotals = GetOpt("ignoreFactionTotals")
    local ICON_BAG  = Util:IconStr("Interface\\Icons\\INV_Misc_Bag_07_Green", iconSize)
    local ICON_BANK = Util:IconStr("Interface\\Icons\\INV_Box_02", iconSize)
    local ICON_MAIL = Util:IconStr("Interface\\Icons\\INV_Letter_15", iconSize)
    local ICON_AH   = Util:IconStr("Interface\\Icons\\INV_Hammer_15", iconSize)

    local entries = CollectSorted(function(data)
        local row = data.itemCounts and data.itemCounts[itemID]
        local fc  = data.mailForecasts and data.mailForecasts[itemID]
        local forecastCount = fc and fc.count or 0
        local hasData = (row and row.total > 0) or forecastCount > 0
        if not showNone and not hasData then return nil end
        return {
            name        = data.name or "",
            classFile   = data.classFile or "",
            bags        = row and ((row.bags or 0) + (row.equipped or 0)) or 0,
            bank        = row and (row.bank or 0) or 0,
            mail        = (row and (row.mail or 0) or 0) + forecastCount,
            ah          = row and (row.ah or 0) or 0,
            bagsCharges = row and (row.bagsCharges or 0) or 0,
            bankCharges = row and (row.bankCharges or 0) or 0,
        }
    end, showNone)

    -- Remove opposing-faction entries when hideFaction is enabled
    if hideFaction then
        local kept = {}
        for _, e in ipairs(entries) do
            if not IsCrossFaction(e) then kept[#kept + 1] = e end
        end
        entries = kept
    end

    if #entries == 0 then return {} end

    -- Compute combined total across all characters
    local grandTotal        = 0
    local grandTotalCharges = 0
    for _, e in ipairs(entries) do
        if not (ignoreFactionTotals and IsCrossFaction(e)) then
            grandTotal        = grandTotal        + e.bags + e.bank + e.mail + e.ah
            grandTotalCharges = grandTotalCharges + (e.bagsCharges or 0) + (e.bankCharges or 0)
        end
    end

    local lines = {}
    lines[#lines + 1] = { " " }

    local totalStr = COLOR_COUNT .. grandTotal .. "|r"
    if grandTotalCharges > 0 then
        totalStr = totalStr .. COLOR_LABEL .. ":" .. grandTotalCharges .. "|r"
    end
    local headerRight = grandTotal > 0
        and (COLOR_LABEL .. "Total: |r" .. totalStr)
        or nil
    lines[#lines + 1] = { COLOR_HEADER .. "Character Inventory|r", headerRight }

    for _, e in ipairs(entries) do
        local parts = {}
        if e.bags > 0 then
            local cs = COLOR_COUNT .. e.bags .. "|r"
            if e.bagsCharges > 0 then cs = cs .. COLOR_LABEL .. ":" .. e.bagsCharges .. "|r" end
            parts[#parts + 1] = ICON_BAG .. " " .. cs
        end
        if e.bank > 0 then
            local cs = COLOR_COUNT .. e.bank .. "|r"
            if e.bankCharges > 0 then cs = cs .. COLOR_LABEL .. ":" .. e.bankCharges .. "|r" end
            parts[#parts + 1] = ICON_BANK .. " " .. cs
        end
        if e.mail > 0 then
            parts[#parts + 1] = ICON_MAIL .. " " .. COLOR_COUNT .. e.mail .. "|r"
        end
        if e.ah > 0 then
            parts[#parts + 1] = ICON_AH .. " " .. COLOR_COUNT .. e.ah .. "|r"
        end

        local right = #parts > 0 and tblconcat(parts, "  ") or (COLOR_LABEL .. "None|r")
        lines[#lines + 1] = {
            FormatCharName(e),
            right,
        }
    end

    return lines
end

-- ============================================================================
-- Tooltip Section: Recipe (merged knowledge + item counts)
-- ============================================================================

local function BuildRecipeLines(itemLink, itemID)
    local itemName, _, _, _, _, itemType, itemSubType = GetItemInfo(itemLink)
    if not itemName or itemType ~= "Recipe" then return {} end

    local professionName = itemSubType
    local recipeName     = itemName:match("^%a+:%s*(.+)$") or itemName
    local known          = Indexer:FindRecipeAcrossChars(recipeName)
    local showNone       = GetOpt("showNone")
    local iconSize       = GetOpt("iconSize")
    local ICON_BAG       = Util:IconStr("Interface\\Icons\\INV_Misc_Bag_07_Green", iconSize)
    local ICON_BANK      = Util:IconStr("Interface\\Icons\\INV_Box_02",             iconSize)
    local ICON_MAIL      = Util:IconStr("Interface\\Icons\\INV_Letter_15",           iconSize)
    local ICON_AH        = Util:IconStr("Interface\\Icons\\INV_Hammer_15",           iconSize)

    local entries = CollectSorted(function(data, charKey)
        local prof    = data.professions and data.professions[professionName]
        local row     = data.itemCounts  and data.itemCounts[itemID]
        local hasProf  = prof ~= nil
        local hasItems = row and row.total > 0

        -- Always skip if character has neither the profession nor the item
        -- (unless showNone is on, in which case only include if prof exists —
        -- showing a '-' for a character with a different class is unhelpful)
        if not hasProf and not hasItems then return nil end

        return {
            name      = data.name or "",
            classFile = data.classFile or "",
            hasProf   = hasProf,
            learned   = hasProf and (known[charKey] ~= nil),
            level     = hasProf and (prof.level    or 0) or 0,
            maxLevel  = hasProf and (prof.maxLevel or 0) or 0,
            bags      = row and ((row.bags or 0) + (row.equipped or 0)) or 0,
            bank      = row and (row.bank or 0) or 0,
            mail      = row and (row.mail or 0) or 0,
            ah        = row and (row.ah or 0) or 0,
        }
    end, false)

    if #entries == 0 then return {} end

    -- Learned first, then alphabetical within each group
    tblsort(entries, function(a, b)
        if a.learned ~= b.learned then return a.learned end
        return a._sortName < b._sortName
    end)

    local lines = {}
    lines[#lines + 1] = { " " }
    lines[#lines + 1] = { COLOR_HEADER .. "Recipe: " .. professionName .. "|r" }

    for _, e in ipairs(entries) do
        local right = {}

        -- +/- indicator and skill level only when the char has the profession
        if e.hasProf then
            if e.learned then
                right[#right + 1] = "|cff00FF00+|r"
            else
                right[#right + 1] = "|cffFF4444-|r"
            end
            right[#right + 1] = COLOR_LABEL .. strformat("%d/%d", e.level, e.maxLevel) .. "|r"
        end

        if e.bags  > 0 then right[#right + 1] = ICON_BAG  .. " " .. COLOR_COUNT .. e.bags  .. "|r" end
        if e.bank  > 0 then right[#right + 1] = ICON_BANK .. " " .. COLOR_COUNT .. e.bank  .. "|r" end
        if e.mail  > 0 then right[#right + 1] = ICON_MAIL .. " " .. COLOR_COUNT .. e.mail  .. "|r" end
        if e.ah    > 0 then right[#right + 1] = ICON_AH   .. " " .. COLOR_COUNT .. e.ah    .. "|r" end

        lines[#lines + 1] = {
            FormatCharName(e),
            tblconcat(right, "  "),
        }
    end

    return lines
end

-- ============================================================================
-- Tooltip Section: Item Info (ID, Vendor Price, Spell ID)
-- ============================================================================

local function BuildItemInfoLines(itemLink, itemID)
    if not GetGroupOpt("itemInfo") then return {} end

    local lines = {}

    if GetGroupOpt("itemInfo", "showItemID") then
        lines[#lines + 1] = { COLOR_LABEL .. "Item ID: |r" .. COLOR_COUNT .. itemID .. "|r" }
    end

    if GetGroupOpt("itemInfo", "showVendorPrice") then
        local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemLink)
        if sellPrice and sellPrice > 0 then
            local iconSize = GetOpt("iconSize")
            lines[#lines + 1] = { COLOR_LABEL .. "Vendor: |r" .. Util:FormatMoney(sellPrice, iconSize) }
        end
    end

    if GetGroupOpt("itemInfo", "showSpellID") then
        local _, spellID = GetItemSpell(itemID)
        if spellID then
            lines[#lines + 1] = { COLOR_LABEL .. "Spell ID: |r" .. COLOR_COUNT .. spellID .. "|r" }
        end
    end

    if GetGroupOpt("itemInfo", "showIconID") then
        local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemLink)
        if icon then
            lines[#lines + 1] = { COLOR_LABEL .. "Icon ID: |r" .. COLOR_COUNT .. tostring(icon) .. "|r" }
        end
    end

    if #lines > 0 then
        table.insert(lines, 1, { " " })
    end

    return lines
end

-- ============================================================================
-- Mail Forecast: intercept outgoing SendMail
-- ============================================================================
-- We capture the arguments of SendMail (recipient, subject, body) before it
-- fires, then on MAIL_SEND_SUCCESS we read attachment slots and create
-- forecast entries on the target character's snapshot via Indexer.
--
-- In Classic, mail attachments are placed via ClickSendMailItemButton /
-- SetSendMailItem before SendMail is called, and the attachment info is
-- available via GetSendMailItem(slot) for slots 1..ATTACHMENTS_MAX_SEND (7).

local _pendingMailRecipient = nil

--- Normalize a mail recipient into a charKey ("Name-Realm").
--- Appends the current realm (with spaces) when no realm is specified.
local function NormalizeRecipient(recipient)
    if not recipient or recipient == "" then return nil end
    if not recipient:find("-") then
        local realm = GetRealmName() or ""
        recipient = recipient .. "-" .. realm
    end
    return recipient
end

--- Strip spaces from the realm part of a charKey to match the format
--- used by synced snapshots (CommLink's NormalizeCK).
local function StripRealmSpaces(charKey)
    local name, realm = charKey:match("^(.+)-(.+)$")
    if not name then return charKey end
    return name .. "-" .. realm:gsub("%s+", "")
end

--- Find the DB-format charKey for one of our own characters.
--- Returns the matched key in the format used by its snapshot store,
--- or nil if the recipient is not a known character.
local function ResolveOwnCharacter(charKey)
    if charKey == Core:GetCharKey() then return charKey end
    for _, ck in ipairs(Core:GetAllCharKeys()) do
        if ck == charKey then return ck end
    end
    -- Synced keys have spaces stripped from the realm (CommLink.NormalizeCK),
    -- so compare with a stripped version of the input.
    local stripped = StripRealmSpaces(charKey)
    for _, ck in ipairs(Core:GetAllSyncedCharKeys()) do
        if ck == charKey or ck == stripped then return ck end
    end
    return nil
end

--- Pre-hook capture: scan attachment slots before SendMail fires.
--- This is called from a hooksecurefunc on SendMail — it runs after
--- the original executes, but we need the attachment info BEFORE.
--- We solve this by hooking the function to capture at call time.
local _pendingMailItems = {}
local _sendMailPreHookInstalled = false

local function PreCaptureSendMail(recipient)
    wipe(_pendingMailItems)
    local charKey = NormalizeRecipient(recipient)
    local matchedKey = charKey and ResolveOwnCharacter(charKey)
    if not matchedKey then return end

    _pendingMailRecipient = matchedKey

    -- Capture attachment slots (Classic: 1-7)
    -- GetSendMailItem returns: name, itemID, texture, count, quality
    if not GetSendMailItemLink then return end
    for slot = 1, 7 do  -- ATTACHMENTS_MAX_SEND
        local link = GetSendMailItemLink(slot)
        if link then
            local itemID = tonumber(link:match("item:(%d+)"))
            local _, _, _, count = GetSendMailItem(slot)  -- name, itemID, texture, count
            if itemID and count and count > 0 then
                _pendingMailItems[#_pendingMailItems + 1] = { itemID = itemID, count = count }
            end
        end
    end
end

--- Install a raw pre-hook on SendMail so we can read attachment slots
--- BEFORE the C implementation clears them.  hooksecurefunc is a post-hook
--- and slots are empty by the time it fires.
local function InstallSendMailPreHook()
    if _sendMailPreHookInstalled then return end
    _sendMailPreHookInstalled = true

    local origSendMail = SendMail
    SendMail = function(recipient, subject, body, ...)
        PreCaptureSendMail(recipient)
        return origSendMail(recipient, subject, body, ...)
    end
end

local function PostMailSendSuccess()
    local recipient = _pendingMailRecipient
    _pendingMailRecipient = nil
    if not recipient or #_pendingMailItems == 0 then return end

    for _, item in ipairs(_pendingMailItems) do
        Indexer:RecordMailForecast(recipient, item.itemID, item.count)
    end
    wipe(_pendingMailItems)
    InvalidateLineCache()
end

-- ============================================================================
-- Main Tooltip Hook
-- ============================================================================

local function OnTooltipCleared(tooltip)
    tooltip._prephsItemID = nil
    tooltip._prephsCacheVer = nil
end

local function OnTooltipSetItem(tooltip)
    local _, itemLink = tooltip:GetItem()
    if not itemLink then return end

    local itemID = tonumber(itemLink:match("item:(%d+)"))
    if not itemID then return end

    -- Guard: prevent adding lines twice to the same tooltip instance.
    -- OnTooltipSetItem can fire multiple times per hover; without this
    -- the same lines would be appended each fire.  Allow re-render if the
    -- underlying data changed (cache version bumped by sync/index events).
    if tooltip._prephsItemID == itemID and tooltip._prephsCacheVer == _cacheVer then return end

    -- Check the line cache — if we already built lines for this item
    -- at the current cache version, just replay them (very fast).
    local cached = _lineCache[itemID]
    if cached and cached.v == _cacheVer then
        ReplayLines(tooltip, cached.lines)
        tooltip._prephsItemID = itemID
        tooltip._prephsCacheVer = _cacheVer
        return
    end

    -- Cache miss — build the line data and store it.
    local lines = {}

    -- Item info lines (ID, vendor price, spell ID)
    local infoLines = BuildItemInfoLines(itemLink, itemID)
    for i = 1, #infoLines do lines[#lines + 1] = infoLines[i] end

    -- Character data lines
    local charLines
    if itemID == HEARTHSTONE_ID then
        charLines = BuildHearthstoneLines()
    else
        local _, _, _, _, _, itemType = GetItemInfo(itemLink)
        if not itemType then
            -- GetItemInfo data not loaded yet; skip this fire and let the
            -- next OnTooltipSetItem retry once the client has the info.
            return
        end
        if itemType == "Recipe" then
            charLines = BuildRecipeLines(itemLink, itemID)
        else
            charLines = BuildItemCountLines(itemID)
        end
    end
    for i = 1, #charLines do lines[#lines + 1] = charLines[i] end

    _lineCache[itemID] = { lines = lines, v = _cacheVer }
    ReplayLines(tooltip, lines)
    tooltip._prephsItemID = itemID
    tooltip._prephsCacheVer = _cacheVer
end

-- ============================================================================
-- Tooltip Hook: Buff / Debuff Auras
-- ============================================================================

local function OnSetUnitAura(tooltip, unit, index, filter, isBuff)
    if not GetGroupOpt("auraInfo") then return end

    local name, icon, _, _, _, _, source, _, _, spellId
    if isBuff then
        name, icon, _, _, _, _, source, _, _, spellId = UnitBuff(unit, index, filter)
    else
        name, icon, _, _, _, _, source, _, _, spellId = UnitDebuff(unit, index, filter)
    end

    if not name then return end

    local fontSize = GetOpt("fontSize")
    local tooltipName = tooltip:GetName()
    local added = 0

    if GetGroupOpt("auraInfo", "showAuraSpellID") and spellId then
        tooltip:AddLine(COLOR_LABEL .. "Spell ID: |r" .. COLOR_COUNT .. spellId .. "|r", nil, nil, nil, false)
        added = added + 1
    end

    if GetGroupOpt("auraInfo", "showSourceName") and source then
        local sourceName = UnitName(source)
        if sourceName then
            tooltip:AddLine(COLOR_LABEL .. "Source: |r" .. sourceName, nil, nil, nil, false)
            added = added + 1
        end
    end

    if GetGroupOpt("auraInfo", "showSourceID") and source then
        local guid = UnitGUID(source)
        if guid then
            local npcID = guid:match("Creature%-.-%-.-%-.-%-.-%-(%d+)%-")
            if npcID then
                tooltip:AddLine(COLOR_LABEL .. "NPC ID: |r" .. COLOR_COUNT .. npcID .. "|r", nil, nil, nil, false)
                added = added + 1
            end
        end
    end

    if GetGroupOpt("auraInfo", "showIconID") and icon then
        tooltip:AddLine(COLOR_LABEL .. "Icon ID: |r" .. COLOR_COUNT .. tostring(icon) .. "|r", nil, nil, nil, false)
        added = added + 1
    end

    if added > 0 then
        for i = tooltip:NumLines(), tooltip:NumLines() - added + 1, -1 do
            local left = _G[tooltipName .. "TextLeft" .. i]
            if left then
                local font, _, flags = left:GetFont()
                left:SetFont(font, fontSize, flags)
            end
        end
        tooltip:Show()
    end
end

-- ============================================================================
-- Tooltip Hook: Actionbar Tooltips
-- ============================================================================

local function OnSetAction(tooltip, slot)
    if not GetGroupOpt("actionbarInfo") then return end
    if not slot or not HasAction(slot) then return end

    local actionType, id = GetActionInfo(slot)
    local spellID = (actionType == "spell") and id or nil

    local fontSize = GetOpt("fontSize")
    local tooltipName = tooltip:GetName()
    local added = 0

    if GetGroupOpt("actionbarInfo", "showActionSpellID") and spellID then
        tooltip:AddLine(COLOR_LABEL .. "Spell ID: |r" .. COLOR_COUNT .. spellID .. "|r", nil, nil, nil, false)
        added = added + 1
    end

    if GetGroupOpt("actionbarInfo", "showActionAuraID") and spellID then
        -- Check if this spell is active as a buff or debuff on the player
        local auraSpellID
        for i = 1, 40 do
            local _, _, _, _, _, _, _, _, _, sid = UnitBuff("player", i)
            if not sid then break end
            if sid == spellID then auraSpellID = sid; break end
        end
        if not auraSpellID then
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, sid = UnitDebuff("player", i)
                if not sid then break end
                if sid == spellID then auraSpellID = sid; break end
            end
        end
        if auraSpellID then
            tooltip:AddLine(COLOR_LABEL .. "Aura ID: |r" .. COLOR_COUNT .. auraSpellID .. "|r", nil, nil, nil, false)
            added = added + 1
        end
    end

    if GetGroupOpt("actionbarInfo", "showActionIconID") then
        local iconID = GetActionTexture(slot)
        if iconID then
            tooltip:AddLine(COLOR_LABEL .. "Icon ID: |r" .. COLOR_COUNT .. tostring(iconID) .. "|r", nil, nil, nil, false)
            added = added + 1
        end
    end

    if added > 0 then
        for i = tooltip:NumLines(), tooltip:NumLines() - added + 1, -1 do
            local left = _G[tooltipName .. "TextLeft" .. i]
            if left then
                local font, _, flags = left:GetFont()
                left:SetFont(font, fontSize, flags)
            end
        end
        tooltip:Show()
    end
end

-- ============================================================================
-- Character Overview (rendered via AfterInitialize on the module page)
-- ============================================================================

local COLOR_OK    = "|cff00FF00"
local COLOR_FAIL  = "|cffFF4444"
local COLOR_WHITE = "|cffFFFFFF"
local COLOR_DIM   = "|cff888888"

local function FormatReset(seconds)
    if not seconds or seconds <= 0 then return "" end
    local d = mathfloor(seconds / 86400)
    local h = mathfloor((seconds % 86400) / 3600)
    if d > 0 then return strformat("%dd %dh", d, h) end
    return strformat("%dh", h)
end

local function CollectOverviewSections()
    -- Refresh current character's gold
    if Core.CharData and GetMoney then
        Core.CharData.copper = GetMoney() or 0
    end

    local localEntries = {}
    local currentKey = Core:GetCharKey()

    local cd = Core.CharData
    if cd then
        localEntries[#localEntries + 1] = {
            _key       = currentKey,
            _highlight = true,
            _sortName  = (cd.name or ""):lower(),
            data       = cd,
        }
    end

    local seenKeys = { [currentKey] = true }
    for _, charKey in ipairs(Core:GetAllCharKeys()) do
        if charKey ~= currentKey then
            seenKeys[charKey] = true
            local snap = Core:GetCharSnapshot(charKey)
            if snap then
                localEntries[#localEntries + 1] = {
                    _key       = charKey,
                    _highlight = false,
                    _sortName  = (snap.name or ""):lower(),
                    data       = snap,
                }
            end
        end
    end

    tblsort(localEntries, function(a, b) return a._sortName < b._sortName end)

    -- Group synced characters by their sync account
    local accountChars = {}  -- accountName → { entries }
    local ungrouped    = {}  -- synced chars not in any account

    for _, charKey in ipairs(Core:GetAllSyncedCharKeys()) do
        if not seenKeys[charKey] then
            seenKeys[charKey] = true
            local snap = Core:GetSyncedSnapshot(charKey)
            if snap then
                local accountName = CommLink:GetTargetGroup(charKey)
                local entry = {
                    _key       = charKey,
                    _highlight = false,
                    _synced    = true,
                    _sortName  = (snap.name or ""):lower(),
                    data       = snap,
                }
                if accountName then
                    accountChars[accountName] = accountChars[accountName] or {}
                    accountChars[accountName][#accountChars[accountName] + 1] = entry
                else
                    ungrouped[#ungrouped + 1] = entry
                end
            end
        end
    end

    -- Sort each account's entries
    local sortedAccounts = {}
    for accountName, chars in pairs(accountChars) do
        tblsort(chars, function(a, b) return a._sortName < b._sortName end)
        sortedAccounts[#sortedAccounts + 1] = accountName
    end
    tblsort(sortedAccounts)
    tblsort(ungrouped, function(a, b) return a._sortName < b._sortName end)

    -- Build sections array
    local sections = {}

    -- Local characters section (no collapsible header)
    sections[#sections + 1] = {
        _key         = "_local",
        _entries     = localEntries,
        _collapsible = false,
    }

    -- One section per sync account
    for _, accountName in ipairs(sortedAccounts) do
        local group = CommLink:GetSyncGroup(accountName)
        local onlineCount = 0
        local chars = accountChars[accountName]
        for _, e in ipairs(chars) do
            if CommLink:IsPeerOnline(e._key) then onlineCount = onlineCount + 1 end
        end

        sections[#sections + 1] = {
            _key         = "_acct:" .. accountName,
            _header      = {
                accountName   = accountName,
                accountOnline = onlineCount,
                accountTotal  = #chars,
                accountWholeDB = group and group.syncWholeDB or false,
            },
            _entries     = chars,
            _collapsible = true,
        }
    end

    -- Ungrouped synced characters
    if #ungrouped > 0 then
        sections[#sections + 1] = {
            _key         = "_ungrouped",
            _header      = { accountName = "Other Synced", accountTotal = #ungrouped, accountOnline = 0 },
            _entries     = ungrouped,
            _collapsible = true,
        }
    end

    return sections
end

local function ConfigureSectionHeader(card, headerData, isSectionCollapsed)
    local arrow = isSectionCollapsed and (COLOR_DIM .. "[+] ") or (COLOR_DIM .. "[-] ")
    local statusParts = {}
    statusParts[#statusParts + 1] = COLOR_DIM .. headerData.accountTotal .. " chars|r"
    if headerData.accountOnline > 0 then
        statusParts[#statusParts + 1] = COLOR_OK .. headerData.accountOnline .. " online|r"
    end
    if headerData.accountWholeDB then
        statusParts[#statusParts + 1] = COLOR_SYNCED .. "whole-acc|r"
    end
    card:NextLine(arrow .. "|r" .. COLOR_HEADER .. headerData.accountName .. "|r  "
        .. COLOR_DIM .. "(" .. table.concat(statusParts, ", ") .. ")|r", "GameFontNormal")
end

local function ConfigureOverviewCard(card, entry, isCollapsed)
    local data       = entry.data
    local weeklyDefs = Core.data.weeklyQuestDefs
    local dailyDefs  = Core.data.dailyQuestDefs

    -- Header line (always visible)
    local arrow      = isCollapsed and (COLOR_DIM .. "[+] ") or (COLOR_DIM .. "[-] ")
    local classColor = Util:ColorClass(data.name or "?", data.classFile)
    local levelStr   = data.level and data.level > 0 and (COLOR_DIM .. " (" .. data.level .. ")|r") or ""

    local statusTag  = ""
    if entry._highlight then
        statusTag = " |cff00FF00[online]|r"
    elseif entry._synced then
        if CommLink:IsPeerOnline(entry._key) then
            statusTag = " |cff00FF00[synced]|r"
        else
            statusTag = " |cffFF8800[synced — offline]|r"
        end
    end
    card:NextLine(arrow .. "|r" .. classColor .. levelStr .. statusTag, "GameFontNormal")

    if isCollapsed then return end

    -- Zone
    local zone    = (data.zoneName    and data.zoneName    ~= "") and data.zoneName    or nil
    local subzone = (data.subZoneName and data.subZoneName ~= "") and data.subZoneName or nil
    if zone then
        local locText = COLOR_LABEL .. zone
        if subzone and subzone ~= zone then
            locText = locText .. " — " .. subzone
        end
        card:NextLine("  " .. locText .. "|r")
    end

    -- Gold + Hearth
    local hearthStr = (data.bindLocation and data.bindLocation ~= "")
        and (COLOR_LABEL .. "Hearth: |r" .. COLOR_WHITE .. data.bindLocation .. "|r")
        or  (COLOR_DIM .. "Hearth: —|r")
    local goldStr = Util:FormatMoney(data.copper, 14)
    if (data.mailCopper or 0) > 0 then
        local mailIcon = Util:IconStr("Interface\\Icons\\INV_Letter_15", 14)
        goldStr = goldStr .. "  " .. mailIcon .. " " .. Util:FormatMoney(data.mailCopper, 14)
    end
    card:NextLine("  " .. goldStr)
    card:NextLine("  " .. hearthStr)

    -- Saved Instances
    local instances = data.savedInstances
    if instances and #instances > 0 then
        card:NextLine(COLOR_HEADER .. "  Instances:|r")
        for _, inst in ipairs(instances) do
            local prog     = strformat("%d/%d", inst.encounterProgress, inst.numEncounters)
            local resetStr = inst.resetSeconds > 0
                and (COLOR_DIM .. " (" .. FormatReset(inst.resetSeconds) .. ")|r")
                or ""
            local idStr    = (inst.id and inst.id > 0)
                and (COLOR_DIM .. " [#" .. inst.id .. "]|r")
                or ""
            card:NextLine("    " .. COLOR_COUNT .. inst.name .. "|r" .. idStr
                .. "  " .. COLOR_LABEL .. prog .. "|r" .. resetStr)
        end
    end

    -- Weekly Quests
    local showWeekly = Core:GetSetting(MOD_ID, "CharOverview", "showWeekly")
    if showWeekly == nil then showWeekly = true end
    local weeklyData = data.weeklyQuests
    if showWeekly and weeklyDefs and #weeklyDefs > 0 and weeklyData then
        local factionMap = { Horde = 0, Alliance = 1 }
        local charFaction = factionMap[data.faction]
        local hasAny = false
        for i, def in ipairs(weeklyDefs) do
            if (def.faction == nil or def.faction == charFaction) and weeklyData[i] then
                hasAny = true; break
            end
        end
        if hasAny then
            card:NextLine(COLOR_HEADER .. "  Weekly:|r")
            for i, def in ipairs(weeklyDefs) do
                if def.faction == nil or def.faction == charFaction then
                    local slot = weeklyData[i]
                    if slot then
                        local nameIdx = slot.nameIdx or 1
                        local qid     = def.ids[nameIdx] or def.ids[1]
                        local label   = (def.names and (def.names[nameIdx] or def.names[1]))
                                     or Core.data.questData:GetQuestName(qid)
                                     or ("Quest #" .. qid)
                        local status  = slot.done and (COLOR_OK .. "[Done]|r") or (COLOR_FAIL .. "[MISSING]|r")
                        card:NextLine("    " .. status .. " " .. label)
                    end
                end
            end
        end
    end

    -- Daily Quests
    local showDaily = Core:GetSetting(MOD_ID, "CharOverview", "showDaily")
    if showDaily == nil then showDaily = true end
    local dailyData = data.dailyQuests
    if showDaily and dailyDefs and #dailyDefs > 0 and dailyData then
        local factionMap = { Horde = 0, Alliance = 1 }
        local charFaction = factionMap[data.faction]
        local hasAny = false
        for i, def in ipairs(dailyDefs) do
            if (def.faction == nil or def.faction == charFaction) and dailyData[i] then
                hasAny = true; break
            end
        end
        if hasAny then
            card:NextLine(COLOR_HEADER .. "  Daily:|r")
            for i, def in ipairs(dailyDefs) do
                if def.faction == nil or def.faction == charFaction then
                    local slot = dailyData[i]
                    if slot then
                        local nameIdx = slot.nameIdx or 1
                        local qid     = def.ids[nameIdx] or def.ids[1]
                        local label   = (def.names and (def.names[nameIdx] or def.names[1]))
                                     or Core.data.questData:GetQuestName(qid)
                                     or ("Quest #" .. qid)
                        local status  = slot.done and (COLOR_OK .. "[Done]|r") or (COLOR_FAIL .. "[MISSING]|r")
                        card:NextLine("    " .. status .. " " .. label)
                    end
                end
            end
        end
    end

    -- Professions
    local profs = data.professions
    if profs then
        local profCDDefs = Core.data.profCooldownDefs
        local profCDs    = data.profCooldowns
        local now        = time()

        -- Build a lookup: profession name → list of active group CDs
        -- Each group stores one entry with its label + remaining time.
        local cdByProf = {}
        if profCDDefs and profCDs then
            for gi, group in ipairs(profCDDefs) do
                local entry = profCDs[gi]
                if entry and entry.expiresAt then
                    local remaining = entry.expiresAt - now
                    if remaining > 0 then
                        local profName = group.profession or entry.profession
                        cdByProf[profName] = cdByProf[profName] or {}
                        cdByProf[profName][#cdByProf[profName] + 1] = {
                            label     = entry.label or group.label,
                            remaining = remaining,
                        }
                    end
                end
            end
        end

        local primary, secondary = {}, {}
        local SECONDARY_NAMES = { ["Cooking"] = true, ["First Aid"] = true, ["Fishing"] = true }
        for profName, prof in pairs(profs) do
            local line = strformat("    %s%s|r %s%d/%d|r",
                COLOR_WHITE, profName, COLOR_LABEL, prof.level or 0, prof.maxLevel or 0)

            -- Append inline cooldown info (one entry per group label)
            local cds = cdByProf[profName]
            if cds then
                local cdParts = {}
                for _, c in ipairs(cds) do
                    cdParts[#cdParts + 1] = COLOR_FAIL .. c.label .. "|r " .. COLOR_DIM .. "(" .. FormatReset(c.remaining) .. ")|r"
                end
                line = line .. "  " .. tblconcat(cdParts, ", ")
            end

            if SECONDARY_NAMES[profName] then
                secondary[#secondary + 1] = line
            else
                primary[#primary + 1] = line
            end
        end
        tblsort(primary)
        tblsort(secondary)
        if #primary > 0 or #secondary > 0 then
            card:NextLine(COLOR_HEADER .. "  Professions:|r")
            for _, line in ipairs(primary)   do card:NextLine(line) end
            for _, line in ipairs(secondary) do card:NextLine(line) end
        end
    end

    -- Notes
    local charNotes = Core.DB.shared.charNotes
    if charNotes then
        card:NextLine(COLOR_HEADER .. "  Notes:|r")
        card:AddEditBox("Add a note...", charNotes[entry._key] or "", nil, 22, function(text)
            Core.DB.shared.charNotes[entry._key] = (text ~= "") and text or nil
        end)
    end
end

-- ============================================================================
-- CommLink Sync — cross-account character data sharing
-- ============================================================================

--- Build a stripped-down snapshot suitable for network sync.
--- Includes only the data Tooltipper needs (identity, itemCounts, professions).
-- ============================================================================
-- Sync Section Definitions
-- ============================================================================
-- Maps a section name to the CharData keys it covers.  Delta syncs only
-- transmit the sections that actually changed, keeping traffic minimal.

local SYNC_SECTIONS = {
    items       = { "itemCounts" },
    identity    = { "copper", "mailCopper", "zoneName", "subZoneName", "bindLocation", "level", "faction", "bankAvailable" },
    professions = { "professions", "profCooldowns" },
    instances   = { "savedInstances" },
    quests      = { "weeklyQuests", "dailyQuests" },
    forecasts   = { "mailForecasts", "ahNextExpiry" },
}

-- ============================================================================
-- Delta Tracking  (uses Core.Util generic delta)
-- ============================================================================
-- Each section that supports delta sync keeps a snapshot of what was last
-- sent.  On flush we compute the diff and only transmit changes.

local ITEM_DELTA_FIELDS = { "bags", "bank", "mail", "equipped", "total", "ah" }
local PROF_DELTA_FIELDS = { "level", "maxLevel" }

local _lastSentItems = {}   -- snapshot from Util:SnapshotTable
local _lastSentProfs = {}

local function UpdateLastSentItems()
    local cd = Core.CharData
    if not cd or not cd.itemCounts then return end
    _lastSentItems = Util:SnapshotTable(cd.itemCounts, ITEM_DELTA_FIELDS)
end

local function UpdateLastSentProfs()
    local cd = Core.CharData
    if not cd or not cd.professions then return end
    -- For professions we also track recipe count for change detection
    local snap = {}
    for profName, prof in pairs(cd.professions) do
        snap[profName] = {
            level       = prof.level    or 0,
            maxLevel    = prof.maxLevel or 0,
            recipeCount = prof.recipes and #prof.recipes or 0,
        }
    end
    _lastSentProfs = snap
end

--- Build a full snapshot for the initial handshake (PING/PONG).
local function BuildSyncPayload()
    local cd = Core.CharData
    if not cd then return nil end

    -- Capture the baseline so future deltas only send changes
    UpdateLastSentItems()
    UpdateLastSentProfs()

    return {
        _sections       = "full",
        name            = cd.name,
        realm           = cd.realm,
        classFile       = cd.classFile,
        level           = cd.level,
        faction         = cd.faction,
        copper          = cd.copper,
        mailCopper      = cd.mailCopper,
        bindLocation    = cd.bindLocation,
        zoneName        = cd.zoneName,
        subZoneName     = cd.subZoneName,
        bankAvailable   = cd.bankAvailable,
        itemCounts      = cd.itemCounts,
        professions     = cd.professions,
        profCooldowns   = cd.profCooldowns,
        savedInstances  = cd.savedInstances,
        weeklyQuests    = cd.weeklyQuests,
        dailyQuests     = cd.dailyQuests,
        mailForecasts   = cd.mailForecasts,
        ahNextExpiry    = cd.ahNextExpiry,
    }
end

--- Handle incoming synced data from a remote peer.
--- Supports full snapshots, section deltas, and item/profession-level deltas.
local function OnSyncDataReceived(charKey, data)
    if not data or type(data) ~= "table" then return end

    local sections = data._sections

    if sections == "full" or not sections then
        -- Full snapshot (initial sync or legacy sender)
        if not data.name or not data.realm then return end
        data._sections = nil
        CommLink:StoreSyncedSnapshot(charKey, data)
        logger:debug("Tooltipper: full sync from '%s'", charKey)

    else
        -- Delta merge
        local existing = Core:GetSyncedSnapshot(charKey)
        if not existing then return end

        for _, sectionName in ipairs(sections) do
            if sectionName == "items" and data._itemsDelta then
                existing.itemCounts = existing.itemCounts or {}
                Util:ApplyTableDelta(existing.itemCounts, data.itemCounts, data._itemsRemoved)
            elseif sectionName == "professions" and data._profsDelta then
                existing.professions = existing.professions or {}
                Util:ApplyTableDelta(existing.professions, data.professions, data._profsRemoved)
            else
                -- Standard section merge (identity, instances, quests)
                local keys = SYNC_SECTIONS[sectionName]
                if keys then
                    for _, key in ipairs(keys) do
                        existing[key] = data[key]
                    end
                end
            end
        end

        CommLink:StoreSyncedSnapshot(charKey, existing)
        logger:debug("Tooltipper: delta [%s] from '%s'", tblconcat(sections, ","), charKey)
    end

    InvalidateLineCache()
end

-- ============================================================================
-- Section-aware Dirty Tracking & Flush
-- ============================================================================
-- Events mark specific sections dirty. A debounce timer fires after 2 seconds
-- and transmits only the dirty sections as a compact delta payload.

local _dirtySections = {}
local _syncGeneration = 0   -- bumped on every restart; stale callbacks become no-ops

local function FlushDirtySections()
    if Core.States and Core.States.inCombat then
        local gen = _syncGeneration
        C_Timer.After(Core.DB.shared.updateInterval or 0.5, function() if _syncGeneration == gen then FlushDirtySections() end end)
        return
    end

    local cd = Core.CharData
    if not cd then
        for k in pairs(_dirtySections) do _dirtySections[k] = nil end
        return
    end

    -- Build a delta containing only the fields from dirty sections
    local payload  = { _sections = {} }
    local hasDirty = false

    for sec in pairs(_dirtySections) do
        if sec == "items" then
            local changed, removed = Util:ComputeTableDelta(
                _lastSentItems, cd.itemCounts, ITEM_DELTA_FIELDS)
            if changed or removed then
                payload._sections[#payload._sections + 1] = "items"
                payload._itemsDelta   = true
                payload.itemCounts    = changed
                payload._itemsRemoved = removed
                UpdateLastSentItems()
                hasDirty = true
            end
        elseif sec == "professions" then
            -- Build a comparable snapshot of current profs
            local currentSnap = {}
            if cd.professions then
                for profName, prof in pairs(cd.professions) do
                    currentSnap[profName] = {
                        level       = prof.level    or 0,
                        maxLevel    = prof.maxLevel or 0,
                        recipeCount = prof.recipes and #prof.recipes or 0,
                    }
                end
            end
            local changed, removed = Util:ComputeTableDelta(
                _lastSentProfs, currentSnap, PROF_DELTA_FIELDS)
            if changed or removed then
                -- Send the full profession objects for changed entries (not
                -- the snapshot — the receiver needs recipes too)
                local fullChanged
                if changed then
                    fullChanged = {}
                    for profName in pairs(changed) do
                        fullChanged[profName] = cd.professions[profName]
                    end
                end
                payload._sections[#payload._sections + 1] = "professions"
                payload._profsDelta   = true
                payload.professions   = fullChanged
                payload._profsRemoved = removed
                UpdateLastSentProfs()
                hasDirty = true
            end
        else
            local keys = SYNC_SECTIONS[sec]
            if keys then
                payload._sections[#payload._sections + 1] = sec
                for _, key in ipairs(keys) do
                    payload[key] = cd[key]
                end
                hasDirty = true
            end
        end
    end

    for k in pairs(_dirtySections) do _dirtySections[k] = nil end

    if hasDirty then
        CommLink:BroadcastData(MOD_ID, payload)
    end
end

local function MarkSectionDirty(section)
    _dirtySections[section] = true
    -- Restart the debounce window: bump generation so any pending timer is ignored
    _syncGeneration = _syncGeneration + 1
    local gen = _syncGeneration
    C_Timer.After(Core.DB.shared.updateInterval or 0.5, function()
        if _syncGeneration == gen then FlushDirtySections() end
    end)
end

--- Combined handler: invalidate tooltip cache AND mark a section for sync.
--- Used only for non-Indexer events (identity changes like gold, zone, level).
local function OnIndexerEvent(section)
    InvalidateLineCache()
    if section then
        MarkSectionDirty(section)
    end
end

-- ============================================================================
-- Post-Scan Immediate Flush  (Indexer callback → sync)
-- ============================================================================
-- After the Indexer completes a throttled scan, dirty sections are flushed on
-- the next frame.  This ensures sync happens immediately with fresh data
-- rather than waiting for an extra debounce timer.

local INDEXER_CATEGORY_MAP = {
    bags     = "items",
    equip    = "items",
    bank     = "items",
    mail     = "items",
    ah       = "items",
    prof     = "professions",
    inst     = "instances",
    quest    = "quests",
    forecast = "forecasts",
}

local _postScanFlushPending = false

--- Flush dirty sections on the next frame, batching multiple scan callbacks.
local function SchedulePostScanFlush()
    if _postScanFlushPending then return end
    _postScanFlushPending = true
    C_Timer.After(0, function()
        _postScanFlushPending = false
        FlushDirtySections()
    end)
end

--- Called by the Indexer after each throttled scan completes.
local function OnIndexerScanComplete(category)
    InvalidateLineCache()
    local section = INDEXER_CATEGORY_MAP[category]
    if section then
        _dirtySections[section] = true
        -- Mail scans also affect identity (mailCopper)
        if category == "mail" then
            _dirtySections["identity"] = true
        end
        SchedulePostScanFlush()
    end
end

--- Register Tooltipper with CommLink.
local function InitializeSync()
    CommLink:RegisterModule(MOD_ID, {
        GetSyncData    = BuildSyncPayload,
        OnDataReceived = OnSyncDataReceived,
        OnPeerOnline   = function(charKey)
            logger:debug("Tooltipper: peer online '%s'", charKey)
            -- Invalidate cache so cards refresh the online indicator
            InvalidateLineCache()
        end,
        OnPeerOffline  = function(charKey)
            logger:debug("Tooltipper: peer offline '%s'", charKey)
            -- Invalidate cache so cards refresh the online indicator
            InvalidateLineCache()
        end,
        OnSyncedSnapshot = function(charKey, snapshot)
            -- New synced data arrived — refresh tooltip lines immediately
            InvalidateLineCache()
        end,
    })

    -- React to Indexer scan completions: refresh cache & sync immediately
    Indexer:RegisterScanCallback(OnIndexerScanComplete)
end


local TooltipperModule = {
    features = {
        -- ----------------------------------------------------------------
        -- Feature 1: Extend Tooltips  (item info, aura info, actionbar info)
        -- ----------------------------------------------------------------
        ExtendTooltips = {
            name = "Extend Tooltips",
            uiGroup = "Extend Tooltips",
            priority = 30,
            needsReload = false,
            defaultEnabled = true,
            uiElements = {
                {
                    type = "CheckboxGroup",
                    label = "Extend Item Tooltips",
                    key = "itemInfo",
                    collapsible = true,
                    children = {
                        { label = "Item ID", key = "showItemID", default = true },
                        { label = "Vendor Price", key = "showVendorPrice", default = true },
                        { label = "Spell ID (if available)", key = "showSpellID", default = true },
                        { label = "Icon ID", key = "showIconID", default = true },
                    },
                },
                {
                    type = "CheckboxGroup",
                    label = "Extend Buff/Debuff Tooltips",
                    key = "auraInfo",
                    collapsible = true,
                    children = {
                        { label = "Spell ID", key = "showAuraSpellID", default = true },
                        { label = "Source Name", key = "showSourceName", default = true },
                        { label = "Source ID (if available)", key = "showSourceID", default = true },
                        { label = "Icon ID", key = "showIconID", default = true },
                    },
                },
                {
                    type = "CheckboxGroup",
                    label = "Extend Actionbar Tooltips",
                    key = "actionbarInfo",
                    collapsible = true,
                    children = {
                        { label = "Spell ID", key = "showActionSpellID", default = true },
                        { label = "Aura ID (if active)", key = "showActionAuraID", default = true },
                        { label = "Icon ID", key = "showActionIconID", default = true },
                    },
                },
            },
            hooks = {
                -- Buff / Debuff aura tooltips
                {
                    id = "SetUnitBuff",
                    type = "method",
                    table = GameTooltip,
                    method = "SetUnitBuff",
                    callback = function(tooltip, unit, index, filter)
                        OnSetUnitAura(tooltip, unit, index, filter, true)
                    end,
                },
                {
                    id = "SetUnitDebuff",
                    type = "method",
                    table = GameTooltip,
                    method = "SetUnitDebuff",
                    callback = function(tooltip, unit, index, filter)
                        OnSetUnitAura(tooltip, unit, index, filter, false)
                    end,
                },
                {
                    id = "SetUnitAura",
                    type = "method",
                    table = GameTooltip,
                    method = "SetUnitAura",
                    callback = function(tooltip, unit, index, filter)
                        local isBuff = (filter == "HELPFUL")
                        OnSetUnitAura(tooltip, unit, index, filter, isBuff)
                    end,
                },
                -- Actionbar tooltips
                {
                    id = "SetAction",
                    type = "method",
                    table = GameTooltip,
                    method = "SetAction",
                    callback = OnSetAction,
                },
            },
        },

        -- ----------------------------------------------------------------
        -- Feature 2: Character Indexes  (item counts, recipe tracking, sync)
        -- ----------------------------------------------------------------
        [MOD_ID] = {
            name = "Character Indexes",
            uiGroup = "Character Indexes",
            priority = 20,
            needsReload = false,
            defaultEnabled = true,
            suppressionFlags = {
                inRaid = true,
                inInstance = true,
                inGroup = true,
            },
            uiElements = {
                {
                    type = "Checkbox",
                    label = "Show Characters with None",
                    key = "showNone",
                    default = false,
                    description = "Always list every known character, even when they have none of the hovered item.",
                },
                {
                    type = "Checkbox",
                    label = "Show Gold on Hearthstone",
                    key = "showGold",
                    default = false,
                    description = "Display each character's gold next to their bind location on the Hearthstone tooltip.",
                },
                {
                    type = "Checkbox",
                    label = "Hide Opposing Faction in Item Counts",
                    key = "hideFaction",
                    default = false,
                    description = "Completely hide characters of the opposing faction from tooltip item counts.",
                },
                {
                    type = "Checkbox",
                    label = "Ignore Opposing Faction in Totals",
                    key = "ignoreFactionTotals",
                    default = false,
                    description = "Exclude opposing-faction characters from the total count shown in the header, while still listing them individually.",
                },
                {
                    type = "Slider",
                    label = "Font Size",
                    key = "fontSize",
                    min = 8,
                    max = 20,
                    step = 1,
                    default = 14,
                },
                {
                    type = "Slider",
                    label = "Icon Size",
                    key = "iconSize",
                    min = 8,
                    max = 24,
                    step = 1,
                    default = 12,
                },
            },
            hooks = {
                {
                    id = "TooltipSetItem",
                    type = "script",
                    frame = "GameTooltip",
                    script = "OnTooltipSetItem",
                    callback = OnTooltipSetItem,
                },
                {
                    id = "TooltipCleared",
                    type = "script",
                    frame = "GameTooltip",
                    script = "OnTooltipCleared",
                    callback = OnTooltipCleared,
                },
                -- Item links opened in chat (ItemRefTooltip)
                {
                    id = "ItemRefSetItem",
                    type = "script",
                    frame = "ItemRefTooltip",
                    script = "OnTooltipSetItem",
                    callback = OnTooltipSetItem,
                },
                {
                    id = "ItemRefCleared",
                    type = "script",
                    frame = "ItemRefTooltip",
                    script = "OnTooltipCleared",
                    callback = OnTooltipCleared,
                },
                -- AH cancellation: item returns to mailbox
                {
                    id = "CancelAuctionCapture",
                    type = "function",
                    func = "CancelAuction",
                    callback = function(index)
                        Indexer:OnAuctionCancelled(index)
                        InvalidateLineCache()
                    end,
                },
            },
            events = {
                -- Items / professions / instances / quests:
                -- Cache invalidation only; sync is driven by Indexer scan callbacks
                -- (OnIndexerScanComplete) which fire after the throttled scan completes.
                BAG_UPDATE_DELAYED            = InvalidateLineCache,
                PLAYER_EQUIPMENT_CHANGED      = InvalidateLineCache,
                BANKFRAME_OPENED              = InvalidateLineCache,
                PLAYERBANKSLOTS_CHANGED       = InvalidateLineCache,
                PLAYERBANKBAGSLOTS_CHANGED    = InvalidateLineCache,
                MAIL_INBOX_UPDATE             = InvalidateLineCache,
                TRADE_SKILL_SHOW              = InvalidateLineCache,
                TRADE_SKILL_UPDATE            = InvalidateLineCache,
                CRAFT_SHOW                    = InvalidateLineCache,
                CRAFT_UPDATE                  = InvalidateLineCache,
                UPDATE_INSTANCE_INFO          = InvalidateLineCache,
                INSTANCE_LOCK_START           = InvalidateLineCache,
                QUEST_LOG_UPDATE              = InvalidateLineCache,
                -- Mail forecast: commit pending forecast on successful send
                MAIL_SEND_SUCCESS             = PostMailSendSuccess,
                -- Identity (gold, zone, level, bind location) — not Indexer-covered
                PLAYER_MONEY                  = function() OnIndexerEvent("identity") end,
                ZONE_CHANGED_NEW_AREA         = function() OnIndexerEvent("identity") end,
                ZONE_CHANGED                  = function() OnIndexerEvent("identity") end,
                PLAYER_LEVEL_UP               = function() OnIndexerEvent("identity") end,
                PLAYER_LEAVING_WORLD          = function() OnIndexerEvent("identity") end,
            },
            AfterInitialize = function(parent)
                -- Ensure persistence tables exist
                -- Quick-open Connections frame button
                local Factory = Core.UI.Factory
                local connBtn = Factory:CreateButton(parent, "Manage Connections", function()
                    if Core.UI.MainFrame and Core.UI.MainFrame:IsShown() then
                        Core.UI.MainFrame:Hide()
                    end
                    Core.UI:ToggleCustomFrame("Tooltipper", "Connections")
                end)
                if connBtn then connBtn:Show() end
            end,
        },

        -- ----------------------------------------------------------------
        -- Feature 3: Character Overview  (card display, connections)
        -- ----------------------------------------------------------------
        CharOverview = {
            name = "Character Overview",
            uiGroup = "Character Overview",
            priority = 10,
            needsReload = false,
            defaultEnabled = true,
            uiElements = {
                {
                    type = "Checkbox",
                    label = "Display Weekly Quests",
                    key = "showWeekly",
                    default = true,
                    description = "Show weekly quest completion status in the overview cards.",
                },
                {
                    type = "Checkbox",
                    label = "Display Daily Quests",
                    key = "showDaily",
                    default = true,
                    description = "Show daily quest completion status in the overview cards.",
                },
            },
            AfterInitialize = function(parent)
                local Factory = Core.UI.Factory

                local sep = Factory:CreateSeparator(parent)
                if sep then sep:Show() end

                local container = Factory:CreateCardContainer(parent, {
                    persistCollapsed        = Core.DB.shared.overviewCollapsed,
                    persistOrder            = Core.DB.shared.overviewOrder,
                    persistSectionCollapsed = Core.DB.shared.overviewSectionCollapsed,
                    persistSectionOrder     = Core.DB.shared.overviewSectionOrder,
                })

                local sections = CollectOverviewSections()
                container:Populate(sections, {
                    header = ConfigureSectionHeader,
                    card   = ConfigureOverviewCard,
                })
            end,
        },
    },

    frames = ns.ToolipperFrames or {},
    OnInitialize = function()
        -- Install raw pre-hook on SendMail so we can read attachment
        -- slots before the C implementation clears them.
        InstallSendMailPreHook()

        -- Register with CommLink for cross-account sync
        InitializeSync()

        logger:init("Tooltipper module initialized")
    end,

    OnFeatureStateChanged = function(featureName, enabled)
        InvalidateLineCache()
        logger:features("Feature '%s' %s", featureName, enabled and "enabled" or "disabled")
    end,

    OnSettingChanged = function(featureName, key, value)
        InvalidateLineCache()
    end,
}

-- needIndexer = true — the Indexer activates/deactivates based on this module's feature state
Core:RegisterModule(MOD_ID, TooltipperModule, true)

