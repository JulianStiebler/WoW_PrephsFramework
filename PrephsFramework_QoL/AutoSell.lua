--[[
    <PrephsFramework_QoL/AutoSell.lua>
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

---@type PrephsFramework
local Core = LibStub("PrephsFramework_Core-0.0.1")
local logger = Core.Logger

local MOD_ID = "Quality_Of_Life"
local FEATURE_NAME = "AutoSell"

-- Localize
local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo or C_Container.GetContainerItemInfo
local GetContainerItemID = GetContainerItemID or C_Container.GetContainerItemID
local UseContainerItem = UseContainerItem or C_Container.UseContainerItem
local GetItemInfo = GetItemInfo
local pairs = pairs
local tostring = tostring
local string_format = string.format

-- Number of bag slots (0 = backpack, 1-4 = bags)
local NUM_BAG_SLOTS = NUM_BAG_SLOTS or 4

-- Quality constants (Enum.ItemQuality)
-- 0 = Poor (gray), 1 = Common (white), 2 = Uncommon (green),
-- 3 = Rare (blue), 4 = Epic (purple)
local QUALITY_OPTIONS = {
    { value = 0, label = "|cff9d9d9dPoor (Gray)|r" },
    { value = 1, label = "|cffffffffCommon (White)|r" },
    { value = 2, label = "|cff1eff00Uncommon (Green)|r" },
}

local QUALITY_LABELS = {}
for _, opt in ipairs(QUALITY_OPTIONS) do
    QUALITY_LABELS[#QUALITY_LABELS + 1] = opt.label
end

-- ============================================================================
-- Resolve Function for EditableList — looks up item by name or ID
-- ============================================================================

local function ResolveItem(input)
    if not input or input == "" then return nil, nil end

    -- Try as item ID first
    local numericID = tonumber(input)
    if numericID then
        local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(numericID)
        if itemName then
            return numericID, itemName
        end
        -- Item not in cache yet, return ID as-is
        return numericID, "Item #" .. numericID
    end

    -- Try as item link (shift-clicked)
    local itemID = input:match("item:(%d+)")
    if itemID then
        itemID = tonumber(itemID)
        local itemName = GetItemInfo(itemID)
        return itemID, itemName or ("Item #" .. itemID)
    end

    -- Try as item name (exact match via GetItemInfo)
    local itemName, itemLink = GetItemInfo(input)
    if itemLink then
        local id = itemLink:match("item:(%d+)")
        if id then
            return tonumber(id), itemName
        end
    end

    return nil, nil
end

-- ============================================================================
-- Sell Logic
-- ============================================================================

local function GetSellList()
    local list = Core:GetSetting(MOD_ID, FEATURE_NAME, "sellList") or {}
    local sellIDs = {}
    for _, entry in pairs(list) do
        if type(entry) == "table" and entry.id then
            sellIDs[tonumber(entry.id)] = true
        end
    end
    return sellIDs
end

local function GetMaxQuality()
    local label = Core:GetSetting(MOD_ID, FEATURE_NAME, "sellQuality")
    if not label then return 0 end -- Default: Poor only
    -- Map label back to quality value
    for _, opt in ipairs(QUALITY_OPTIONS) do
        if opt.label == label then
            return opt.value
        end
    end
    return 0
end

local function OnMerchantShow()
    local maxQuality = GetMaxQuality()
    local sellIDs = GetSellList()

    local totalGold = 0
    local soldCount = 0

    for bag = 0, NUM_BAG_SLOTS do
        local numSlots = GetContainerNumSlots(bag)
        for slot = 1, numSlots do
            local itemID = GetContainerItemID(bag, slot)
            if itemID then
                local itemName, _, itemQuality, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(itemID)
                if itemName then
                    local shouldSell = false

                    -- Check: item is in the explicit sell list
                    if sellIDs[itemID] then
                        shouldSell = true
                    end

                    -- Check: item quality is at or below the threshold
                    if itemQuality and itemQuality <= maxQuality then
                        shouldSell = true
                    end

                    if shouldSell and (itemSellPrice or 0) > 0 then
                        -- Get stack count
                        local _, stackCount
                        local containerInfo = GetContainerItemInfo(bag, slot)
                        if type(containerInfo) == "table" then
                            -- Retail/newer API returns a table
                            stackCount = containerInfo.stackCount or 1
                        else
                            -- Classic API returns multiple values
                            _, stackCount = GetContainerItemInfo(bag, slot)
                            stackCount = stackCount or 1
                        end

                        UseContainerItem(bag, slot)
                        totalGold = totalGold + (itemSellPrice * stackCount)
                        soldCount = soldCount + 1
                    end
                end
            end
        end
    end

    if soldCount > 0 then
        logger:info("Auto-sold %d item(s) for %s", soldCount, C_CurrencyInfo.GetCoinTextureString(totalGold))
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

ns.AutoSell = {
    feature = {
        name = "Auto Sell",
        uiGroup = "General QOL",
        priority = 16,
        needsReload = false,
        defaultEnabled = false,
        events = {
            MERCHANT_SHOW = OnMerchantShow,
        },
        uiElements = {
            {
                type = "Dropdown",
                label = "Sell Quality Threshold",
                key = "sellQuality",
                options = QUALITY_LABELS,
                default = QUALITY_LABELS[1], -- Poor (Gray)
            },
            {
                type = "EditableList",
                label = "Always Sell These Items",
                key = "sellList",
                resolveFunc = ResolveItem,
                inputHint = "Item name, ID, or shift-click link",
            },
        },
    },
}
