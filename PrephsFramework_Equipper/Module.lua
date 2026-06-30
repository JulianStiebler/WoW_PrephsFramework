--[[
    <PrephsFramework_Core/Callbacks.lua>
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

local unpack = unpack
local select = select
local pairs = pairs
local ipairs = ipairs
local next = next
local type = type
local tonumber = tonumber
local tostring = tostring
local math_random = math.random
local math_floor = math.floor
local print = print
local tinsert = table.insert
local tsort = table.sort
local tremove = table.remove
local tconcat = table.concat
local print = print
local C_Container = C_Container
local C_Item = C_Item
local C_Spell = C_Spell
local C_Engraving = C_Engraving
local GetContainerItemGUID = GetContainerItemGUID
local GetInventoryItemGUID = GetInventoryItemGUID
local GetInventoryItemLink = GetInventoryItemLink
local GetItemIcon = GetItemIcon
local GetInventoryItemID = GetInventoryItemID
local GetContainerNumSlots = GetContainerNumSlots
local GetInventoryItemTexture = GetInventoryItemTexture
local CreateFrame = CreateFrame
local UIParent = UIParent
local IsShiftKeyDown = IsShiftKeyDown
local IsModifiedClick = IsModifiedClick
local InCombatLockdown = InCombatLockdown
local UseInventoryItem = UseInventoryItem
local IsMounted = IsMounted
local UIDropDownMenu_Initialize = UIDropDownMenu_Initialize
local UIDropDownMenu_CreateInfo = UIDropDownMenu_CreateInfo
local UIDropDownMenu_SetSelectedValue = UIDropDownMenu_SetSelectedValue
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local UIDropDownMenu_SetWidth = UIDropDownMenu_SetWidth
local CharacterGuildText = CharacterGuildText
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide
local RuneFrameControlButton = RuneFrameControlButton
local StaticPopup_Show = StaticPopup_Show
local ItemRefTooltip = ItemRefTooltip
local GetCursorPosition = GetCursorPosition
local UIDropDownMenu_SetText = UIDropDownMenu_SetText 


---@class PFEquipperDB
---@field sets table<string, PFEquipperSet>
---@field bankCache table<number, boolean>
---@field barLocked boolean
---@field learnedIcons number[]
---@field barDirection string
---@field showBar boolean
---@field barPoint? FramePoint
---@field barRelPoint? FramePoint
---@field barX? number
---@field barY? number

---@class PFEquipperSet
---@field items table<number, PFEquipperItem> # Keyed by slotID (1-18)
---@field color table # {r, g, b}
---@field trigger? string

---@class PFEquipperItem
---@field id number
---@field guid string
---@field link? string
---@field enchant? string
---@field rune? string
---@field savedRuneID? number
---@field name? string
---@field icon? number

PFEquipperDB = PFEquipperDB or { sets = {}, bankCache = {}, barLocked = false, learnedIcons = {}, barDirection = "right", showBar = true }

local dumbFlyoutItems = {
    5956, -- Blacksmith Hammer
    6219, -- Arclight Spanner
    7005, -- Skinning Knife
    19901, -- Zulian Slicer
    2901, -- Mining Pick
}

local randomIcons = {
    132273, 132333, 135321, 132444, 132626, 132641, 132642, 132633, 
    132627, 135906, 134951, 132341, 132402, 132456, 132457, 132146,
    -- MAGE
    626001, -- MAGE
    135812, -- Fire
    135846, -- Frost
    135932, -- Arcane
    
    -- WARRIOR
    626008, -- WARRIOR
    132355, -- Arms
    132347, -- Fury
    132341, -- Protection
    
    -- PALADIN
    626003, -- PALADIN
    135920, -- Holy
    135893, -- Protectio
    135873, -- Retribution 
    135902, -- Wrathlike
    135972, -- Shcokadin
    135903, -- Exodin
    
    -- ROGUE
    626005, -- ROGUE
    132292, -- Assassination
    132090, -- Combat 
    132320, -- Subtlety
    
    -- PRIEST
    626004, -- PRIEST
    135940, -- Disciplin
    237542, -- Holy
    136207, -- Shadow
    
    -- SHAMAN
    626006, -- SHAMAN
    136048, -- Elemental
    132314, -- Enhancement
    136052, -- Restoration
    
    -- DRUID
    625999, -- DRUID
    136096, -- Balance
    132115, -- Feral
    132276, -- Tank
    136041, -- Restoration
    
    -- WARLOCK
    626007, -- WARLOCK
    136145, -- Affliction
    136172, -- Demonology 
    136186, -- Destruction
    
    -- HUNTER
    626000, -- HUNTER
    132164, -- Beast Mastery
    236179, -- Marksmanship 
    132215, -- Survival

    -- PRIMARY PROFESSIONS
    136240, -- Alchemy
    136241, -- Blacksmithing
    136244, -- Enchanting
    136243, -- Engineering
    237171, -- Inscription
    134071, -- Jewelcrafting
    133611, -- Leatherworking
    136249, -- Tailoring
    136246, -- Herbalism
    136248, -- Mining
    136242, -- Brew Poison
    133971, -- Cooking
    135966, -- First Aid
    136245, -- Fishing

    -- Utility
    132226, -- Mount Speed
    135788, -- Burning Boots
    136047, -- Dodge
}


local scannerTip = CreateFrame("GameTooltip", "PFEquipperScanner", nil, "GameTooltipTemplate")
scannerTip:SetOwner(WorldFrame, "ANCHOR_NONE")

local function GetContainerItemGUIDSafe(bag, slot)
    if C_Container and C_Container.GetContainerItemGUID then
        local guid = C_Container.GetContainerItemGUID(bag, slot)
        if guid then return guid end
    end
    if GetContainerItemGUID then
        return GetContainerItemGUID(bag, slot)
    end
    return nil
end

local function NormalizeItemData(itemData)
    if type(itemData) ~= "table" then
        return itemData and { id = itemData } or nil
    end

    local normalized = {
        id = itemData.id,
        guid = itemData.guid,
        link = itemData.link or itemData.itemLink,
        enchant = itemData.enchant,
        rune = itemData.rune,
        savedRuneID = itemData.savedRuneID,
        name = itemData.name,
        icon = itemData.icon,
    }

    if not normalized.id and normalized.link then
        normalized.id = C_Item.GetItemInfoInstant(normalized.link)
    end

    return normalized
end

local function FindContainerItemLocation(itemData)
    local entry = NormalizeItemData(itemData)
    if not entry or not entry.guid then return nil end

    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            if GetContainerItemGUIDSafe(bag, slot) == entry.guid then
                return "bag", bag, slot
            end
        end
    end

    for bag = -1, 11 do
        if bag == -1 or (bag >= 5 and bag <= 11) then
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                if GetContainerItemGUIDSafe(bag, slot) == entry.guid then
                    return "bank", bag, slot
                end
            end
        end
    end

    return nil
end

local function GetInventoryItemGUIDSafe(unit, slot)
    if GetInventoryItemGUID then
        return GetInventoryItemGUID(unit, slot)
    end
    return nil
end

local function GetInventoryItemMatch(itemData, slotID)
    local entry = NormalizeItemData(itemData)
    if not entry then return false end

    local currentGUID = GetInventoryItemGUIDSafe("player", slotID)
    if entry.guid and currentGUID and currentGUID ~= "" then
        return currentGUID == entry.guid
    end

    local currentLink = GetInventoryItemLink("player", slotID)
    if entry.link and currentLink and currentLink ~= "" then
        return currentLink == entry.link
    end

    local currentID = GetInventoryItemID("player", slotID)
    if entry.id and currentID then
        return currentID == entry.id
    end

    return false
end

local function AddTooltipLine(tooltip, text, r, g, b, wrap)
    tooltip:AddLine(text, r, g, b, wrap)
end

local function GetItemAvailabilityState(itemData, slotID)
    local entry = NormalizeItemData(itemData)
    if not entry then
        return "missing"
    end

    if slotID and GetInventoryItemMatch(itemData, slotID) then
        return "available"
    end

    local itemID = entry.id
    if itemID then
        if C_Item.GetItemCount(itemID) > 0 then
            return "available"
        end
        if PFEquipperDB.bankCache[itemID] then
            return "banked"
        end
    end

    if entry.guid then
        local location = FindContainerItemLocation(entry)
        if location == "bank" then
            return "banked"
        elseif location == "bag" then
            return "available"
        end
    end

    return "missing"
end

local function GetSetAvailabilityState(data)
    if not data or not data.items then
        return "available"
    end

    local hasItems = false
    local hasMissing = false
    local hasBanked = false

    for slotID, itemData in pairs(data.items) do
        if itemData then
            hasItems = true
            local state = GetItemAvailabilityState(itemData, slotID)
            if state == "missing" then
                hasMissing = true
            elseif state == "banked" then
                hasBanked = true
            end
        end
    end

    if not hasItems then
        return "available"
    end
    if hasMissing then
        return "missing"
    end
    if hasBanked then
        return "banked"
    end
    return "available"
end

local function ApplySetIconState(btn, state)
    if not btn or not btn.icon then return end

    if not btn.iconOverlay then
        btn.iconOverlay = btn:CreateTexture(nil, "OVERLAY")
        btn.iconOverlay:SetAllPoints(btn.icon)
        btn.iconOverlay:SetTexture("Interface\\Buttons\\White8x8")
        btn.iconOverlay:SetBlendMode("ADD")
    end

    if state == "banked" then
        btn.icon:SetVertexColor(1, 0.86, 0.2)
        btn.icon:SetDesaturated(false)
        btn.iconOverlay:SetVertexColor(1, 0.82, 0.05)
        btn.iconOverlay:SetAlpha(0.35)
        btn.iconOverlay:Show()
    elseif state == "missing" then
        btn.icon:SetVertexColor(1, 0.22, 0.22)
        btn.icon:SetDesaturated(true)
        btn.iconOverlay:SetVertexColor(1, 0.12, 0.12)
        btn.iconOverlay:SetAlpha(0.45)
        btn.iconOverlay:Show()
    else
        btn.icon:SetVertexColor(1, 1, 1)
        btn.icon:SetDesaturated(false)
        btn.iconOverlay:Hide()
    end
end

local function ResolveItemIcon(entry)
    if not entry then return nil end

    if entry.icon then
        return entry.icon
    end

    local function GetIconForItemID(itemID)
        if not itemID then return nil end
        if GetItemIcon then
            local icon = GetItemIcon(itemID)
            if icon and icon ~= 0 then return icon end
        end
        local itemInfo = { C_Item.GetItemInfo(itemID) }
        local icon = select(10, unpack(itemInfo))
        return icon
    end

    local resolvedID = entry.id or (entry.link and C_Item.GetItemInfoInstant(entry.link))
    if resolvedID then
        local icon = GetIconForItemID(resolvedID)
        if icon then return icon end
    end

    if entry.guid then
        for slotID = 1, 18 do
            local currentGUID = GetInventoryItemGUIDSafe("player", slotID)
            if currentGUID and currentGUID == entry.guid then
                local itemID = GetInventoryItemID("player", slotID)
                local icon = itemID and GetItemIcon(itemID)
                if icon then 
                    return icon 
                end
            end
        end

        local function TryContainerScan(bagStart, bagEnd, label)
            for bag = bagStart, bagEnd do
                local numSlots = (C_Container and C_Container.GetContainerNumSlots) and C_Container.GetContainerNumSlots(bag) or GetContainerNumSlots(bag)
                if numSlots then
                    for slot = 1, numSlots do
                        if GetContainerItemGUIDSafe(bag, slot) == entry.guid then
                            local itemID = (C_Container and C_Container.GetContainerItemID) and C_Container.GetContainerItemID(bag, slot) or GetContainerItemID(bag, slot)
                            if itemID then
                                local icon = GetItemIcon(itemID)
                                if icon then 
                                    return icon 
                                end
                            end
                        end
                    end
                end
            end
            return nil
        end

        local icon = TryContainerScan(0, 4, "Bags") or TryContainerScan(-1, -1, "Backpack") or TryContainerScan(5, 11, "Bank")
        if icon then return icon end
    end
    return nil
end

local function GetEnchantName(itemLink)
    if not itemLink then return nil end
    local _, _, enchantID = string.find(itemLink, "item:%d+:(%d+)")
    if not enchantID or enchantID == "0" or enchantID == "" then return nil end

    scannerTip:ClearLines()
    scannerTip:SetHyperlink(itemLink)
    
    local equipPrefix = "Equip:"
    local usePrefix = "Use:"
    local setPrefix = "^Set:"

    for i = 2, 10 do
        local line = _G["PFEquipperScannerTextLeft"..i]
        if line then
            local text = line:GetText()
            local r, g, b = line:GetTextColor()
            if text and r < 0.3 and g > 0.8 and b < 0.3 then
                local isEquip = text:find(equipPrefix)
                local isUse = text:find(usePrefix)
                local isSet = text:find(setPrefix)
                local isClass = text:find("Classes:")
                if not (isEquip or isUse or isSet or isClass) then return text end
            end
        end
    end
    return nil
end

local function LearnCurrentIcons()
    PFEquipperDB.learnedIcons = PFEquipperDB.learnedIcons or {}
    for i = 1, 18 do
        local icon = GetInventoryItemTexture("player", i)
        if icon then
            local alreadyKnown = false
            for _, id in ipairs(randomIcons) do
                if id == icon then alreadyKnown = true break end
            end
            if not alreadyKnown then
                for _, id in ipairs(PFEquipperDB.learnedIcons) do
                    if id == icon then alreadyKnown = true break end
                end
            end
            if not alreadyKnown then
                tinsert(PFEquipperDB.learnedIcons, icon)
            end
        end
    end
end


local function UpdateBankCache()
    PFEquipperDB.bankCache = {} 
    for bag = -1, 11 do
        if bag == -1 or (bag >= 5 and bag <= 11) then
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local id = C_Container.GetContainerItemID(bag, slot)
                if id then PFEquipperDB.bankCache[id] = true end
            end
        end
    end
end

local function GetItemLocationText(itemData)
    local entry = NormalizeItemData(itemData)
    if entry and entry.guid then
        for slot = 1, 18 do
            if GetInventoryItemGUIDSafe("player", slot) == entry.guid then
                return "|cff00ffff(Equipped)|r"
            end
        end

        local location = FindContainerItemLocation(entry)
        if location then
            if location == "bag" then return "|cff00ff00(Bag)|r" end
            if location == "bank" then return "|cffffff00(Bank)|r" end
        end
    end

    local itemID = entry and entry.id or itemData
    if itemID and C_Item.GetItemCount(itemID) > 0 then return "|cff00ff00(Bag)|r"
    elseif itemID and PFEquipperDB.bankCache[itemID] then return "|cffffff00(Bank)|r"
    else return "|cffff0000(Missing)|r" end
end


local flyout = CreateFrame("Frame", "PF_EquipperFlyout", UIParent, "BackdropTemplate")
flyout:SetSize(40, 40)
flyout:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14, insets = {left=3,right=3,top=3,bottom=3}})
flyout:SetBackdropColor(0, 0, 0, 0.9)
flyout:SetFrameStrata("HIGH")
flyout:Hide()

local flyoutButtons = {}
local flyoutMode = "items" 

local function IsShiftDown()
    return IsShiftKeyDown() or (IsModifiedClick and IsModifiedClick("SHIFT"))
end

local function CreateFlyoutButton()
    local btn = CreateFrame("Button", nil, flyout)
    btn:SetSize(30, 30)
    btn:EnableMouse(true)
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetAllPoints()
    btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.runeInfo then
            local spellID = self.runeInfo.learnedAbilitySpellIDs and self.runeInfo.learnedAbilitySpellIDs[1]
            if spellID then
                GameTooltip:SetSpellByID(spellID)
                GameTooltip:Show()
            else
                GameTooltip:ClearLines()
                GameTooltip:AddLine(self.runeInfo.name or "Unknown Rune", 1, 1, 1)
                if self.runeInfo.description then
                    GameTooltip:AddLine(self.runeInfo.description, 0.8, 0.8, 0.8, true)
                end
                GameTooltip:Show()
            end
        elseif self.link then
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    btn:SetScript("OnClick", function(self)
        local isWeaponSlot = (flyout.currentSlotID == 16 or flyout.currentSlotID == 17 or flyout.currentSlotID == 18)
        if InCombatLockdown() and not isWeaponSlot then return end
        if flyoutMode == "runes" and self.runeInfo then
            if self.runeInfo.skillLineAbilityID then
                C_Engraving.CastRune(self.runeInfo.skillLineAbilityID)
                UseInventoryItem(flyout.currentSlotID)
                if StaticPopup1Button1 and StaticPopup1Button1:IsShown() then StaticPopup1Button1:Click() end
                flyout:Hide()
            else
                print("No skillLineAbilityID for rune: "..(self.runeInfo.name or "unknown"))
            end
        elseif self.link then
            C_Item.EquipItemByName(self.link, flyout.currentSlotID)
            flyout:Hide()
        end
    end)
    return btn
end

local slotToInvType = {
    [1] = "INVTYPE_HEAD",
    [5] = "INVTYPE_CHEST",
    [6] = "INVTYPE_WAIST",
    [7] = "INVTYPE_LEGS",
    [8] = "INVTYPE_FEET",
    [9] = "INVTYPE_WRIST",
    [10] = "INVTYPE_HAND",
    [15] = "INVTYPE_CLOAK",
}

local function GetRuneCategoryForSlot(slotID)
    local cat = nil
    if slotID == 15 then cat = 16 
    elseif slotID == 16 then cat = nil
    elseif slotID == 12 then cat = 11
    else cat = slotID end
    return cat
end

local function ShowFlyout(owner, slotID, mode)
    local isWeaponSlot = (slotID == 16 or slotID == 17 or slotID == 18)
    if InCombatLockdown() and not isWeaponSlot then return end
    flyout.owner, flyout.currentSlotID = owner, slotID
    flyout.timer = 0 
    local requestedMode = mode or (IsShiftDown() and "runes" or "items")
    local items = {}
    if requestedMode == "runes" then
        local cat = GetRuneCategoryForSlot(slotID)
        local runes = cat and C_Engraving.GetRunesForCategory(cat, true) or nil
        if runes and #runes > 0 then
            flyoutMode = "runes"
            for _, rune in ipairs(runes) do
                table.insert(items, rune)
            end
        else
            flyoutMode = "items"
        end
    else
        flyoutMode = "items"
    end
    for _, b in ipairs(flyoutButtons) do b:Hide() end
    if flyoutMode == "items" then
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local link = C_Container.GetContainerItemLink(bag, slot)
                if link then
                    local isDumb = false
                    local itemID = C_Container.GetContainerItemID(bag, slot)
                    if not itemID then break end
                    local _, _, itemQuality, _, _, _, _, _, itemEquipLoc = C_Item.GetItemInfo(link)
                    for _, dumbID in ipairs(dumbFlyoutItems) do
                        if itemID == dumbID then
                            isDumb = true
                            break
                        end
                    end
                    if itemQuality and itemQuality <= 1 then isDumb = true end
                    if not isDumb then
                        local canEquip = false
                        if slotID == 1 and itemEquipLoc == "INVTYPE_HEAD" then canEquip = true
                        elseif slotID == 2 and itemEquipLoc == "INVTYPE_NECK" then canEquip = true
                        elseif slotID == 3 and itemEquipLoc == "INVTYPE_SHOULDER" then canEquip = true
                        elseif slotID == 4 and itemEquipLoc == "INVTYPE_BODY" then canEquip = true
                        elseif slotID == 5 and (itemEquipLoc == "INVTYPE_CHEST" or itemEquipLoc == "INVTYPE_ROBE") then canEquip = true
                        elseif slotID == 6 and itemEquipLoc == "INVTYPE_WAIST" then canEquip = true
                        elseif slotID == 7 and itemEquipLoc == "INVTYPE_LEGS" then canEquip = true
                        elseif slotID == 8 and itemEquipLoc == "INVTYPE_FEET" then canEquip = true
                        elseif slotID == 9 and itemEquipLoc == "INVTYPE_WRIST" then canEquip = true
                        elseif slotID == 10 and itemEquipLoc == "INVTYPE_HAND" then canEquip = true
                        elseif (slotID == 11 or slotID == 12) and itemEquipLoc == "INVTYPE_FINGER" then canEquip = true
                        elseif (slotID == 13 or slotID == 14) and itemEquipLoc == "INVTYPE_TRINKET" then canEquip = true
                        elseif slotID == 15 and itemEquipLoc == "INVTYPE_CLOAK" then canEquip = true
                        elseif slotID == 16 and (itemEquipLoc == "INVTYPE_WEAPON" or itemEquipLoc == "INVTYPE_2HWEAPON" or itemEquipLoc == "INVTYPE_WEAPONMAINHAND") then canEquip = true
                        elseif slotID == 17 and (itemEquipLoc == "INVTYPE_WEAPON" or itemEquipLoc == "INVTYPE_SHIELD" or itemEquipLoc == "INVTYPE_WEAPONOFFHAND" or itemEquipLoc == "INVTYPE_HOLDABLE") then canEquip = true
                        elseif slotID == 18 and (itemEquipLoc == "INVTYPE_RANGED" or itemEquipLoc == "INVTYPE_RANGEDRIGHT" or itemEquipLoc == "INVTYPE_THROWN" or itemEquipLoc == "INVTYPE_RELIC") then canEquip = true
                        elseif slotID == 19 and itemEquipLoc == "INVTYPE_TABARD" then canEquip = true
                        end
                        if canEquip then tinsert(items, link) end
                    end
                end
            end
        end
    end
    if #items == 0 then flyout:Hide() return end
    for i, entry in ipairs(items) do
        local btn = flyoutButtons[i] or CreateFlyoutButton()
        flyoutButtons[i] = btn
        if flyoutMode == "runes" then
            local spellID = entry.learnedAbilitySpellIDs and entry.learnedAbilitySpellIDs[1]
            local spellInfo = spellID and C_Spell.GetSpellInfo(spellID)
            local icon = (spellInfo and spellInfo.iconID) or entry.iconTexture or 134400
            btn.icon:SetTexture(icon)
            btn.runeInfo = entry
            btn.link = nil
        else
            local itemIcon = select(10, C_Item.GetItemInfo(entry))
            btn.icon:SetTexture(itemIcon or 134400)
            btn.link = entry
            btn.runeInfo = nil
        end
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", flyout, "LEFT", 7 + ((i-1) * 33), 0)
        btn:Show()
    end
    flyout:SetSize((#items * 33) + 10, 40)

    if slotID == 16 or slotID == 17 or slotID == 18 then
        flyout:ClearAllPoints()
        flyout:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -5)
    else
        flyout:ClearAllPoints()
        flyout:SetPoint("LEFT", owner, "RIGHT", 5, 0)
    end
    flyout:Show()
end

flyout:SetScript("OnUpdate", function(self, elapsed)
    if self.switching then return end
    local isOver = self:IsMouseOver(2, -2, -2, 2) or (self.owner and self.owner:IsMouseOver())
    if not isOver then
        self.timer = (self.timer or 0) + elapsed
        if self.timer > 0.6 then self:Hide() self.timer = 0 end
    else self.timer = 0 end
end)


local function GetCurrentSet()
    local set = {}
    for i = 1, 18 do
        local link = GetInventoryItemLink("player", i)
        if link then
            local itemName = C_Item.GetItemInfo(link)
            local icon = select(10, C_Item.GetItemInfo(link))
            
            local runeInfo = nil
            if C_Engraving and C_Engraving.GetRuneForEquipmentSlot then
                runeInfo = C_Engraving.GetRuneForEquipmentSlot(i)
            end

            set[i] = {
                id = C_Item.GetItemInfoInstant(link),
                guid = GetInventoryItemGUIDSafe("player", i),
                link = link,
                enchant = GetEnchantName(link),
                rune = runeInfo and runeInfo.name,
                savedRuneID = runeInfo and runeInfo.skillLineAbilityID,
                name = itemName,
                icon = icon,
            }
        end
    end
    return set
end

local PFEquipper_LastMountedSetName = nil
local PFEquipper_MountedTriggerSetName = nil
local PFEquipper_IsMounted = false

local function GetCurrentSetName()
    for name, data in pairs(PFEquipperDB.sets) do
        local matches = true
        for slot, itemData in pairs(data.items) do
            if not GetInventoryItemMatch(itemData, slot) then
                matches = false
                break
            end
        end
        if matches then
            return name
        end
    end
    return nil
end

local function RememberCurrentSetName()
    local setName = GetCurrentSetName()
    if setName and setName ~= PFEquipper_MountedTriggerSetName then
        PFEquipper_LastMountedSetName = setName
    end
    return setName
end

local function UpdateMountedSetMemory()
    if not PFEquipper_IsMounted then return end
    local currentSetName = GetCurrentSetName()
    if currentSetName and currentSetName ~= PFEquipper_MountedTriggerSetName then
        PFEquipper_LastMountedSetName = currentSetName
    end
end

local UpdateQuickBar

local function EquipSet(setName)
    local data = PFEquipperDB.sets[setName]
    if not data then return end

    if data.trigger == "DroppedCombat" and InCombatLockdown() then
        PFEquipper_QueuedSet = setName
        print("|cffffd200[INFO][Equipper]: Set '"..setName.."' queued for after combat.|r")
        return
    end

    if InCombatLockdown() then return end
    local isBankOpen = BankFrame:IsShown()

    local itemsWithdrawn = 0

    for slot, itemData in pairs(data.items) do
        local entry = NormalizeItemData(itemData)
        if entry and not GetInventoryItemMatch(entry, slot) then
            local location = entry.guid and FindContainerItemLocation(entry) or nil
            if location == "bag" then
                local link = entry.link or entry.id
                if link then
                    C_Item.EquipItemByName(link, slot)
                end
            elseif entry.id and C_Item.GetItemCount(entry.id) > 0 then
                local link = entry.link or entry.id
                if not isBankOpen then
                    C_Item.EquipItemByName(link, slot)
                end
            elseif isBankOpen then
                local bankLocation = nil
                if entry.guid then
                    local _, bag, slotIdx = FindContainerItemLocation(entry)
                    if bag and slotIdx then
                        bankLocation = { bag = bag, slot = slotIdx }
                    end
                end
                if not bankLocation and entry.id then
                    for bag = -1, 11 do
                        if bag == -1 or (bag >= 5 and bag <= 11) then
                            for s = 1, C_Container.GetContainerNumSlots(bag) do
                                if C_Container.GetContainerItemID(bag, s) == entry.id then
                                    bankLocation = { bag = bag, slot = s }
                                    break
                                end
                            end
                        end
                        if bankLocation then break end
                    end
                end
                if bankLocation then
                    C_Container.UseContainerItem(bankLocation.bag, bankLocation.slot)
                    itemsWithdrawn = itemsWithdrawn + 1
                end
            end
        end
    end

    if itemsWithdrawn > 0 then
        UpdateBankCache()
        UpdateQuickBar()
        UpdateSetList()
        if GameTooltip and GameTooltip:IsShown() and PFEquipper_ActiveTooltipOwner and PFEquipper_ActiveTooltipSetName then
            GameTooltip:Hide()
            ShowSetTooltip(PFEquipper_ActiveTooltipOwner, PFEquipper_ActiveTooltipSetName)
        end
        print("|cff00ff00[Equipper]: Pulled " .. itemsWithdrawn .. " item(s) for set '" .. setName .. "' from bank.|r")
    end
end

local function HandleMountedTrigger()
    local mountedSetName = nil
    for name, data in pairs(PFEquipperDB.sets) do
        if data.trigger == "Mounted" then
            mountedSetName = name
            break
        end
    end
    if not mountedSetName then return end

    PFEquipper_MountedTriggerSetName = mountedSetName
    RememberCurrentSetName()

    if InCombatLockdown() then
        PFEquipper_QueuedSet = mountedSetName
        print("|cffffd200[INFO][Equipper]: Mount set '" .. mountedSetName .. "' queued for after combat.|r")
    else
        print("|cffffd200[INFO][Equipper]: Mount set '" .. mountedSetName .. "' equipped.|r")
        EquipSet(mountedSetName)
    end
end

local function HandleUnmountTrigger()
    local restoreSetName = PFEquipper_LastMountedSetName
    PFEquipper_MountedTriggerSetName = nil

    if restoreSetName and PFEquipperDB.sets[restoreSetName] then
        if InCombatLockdown() then
            PFEquipper_QueuedSet = restoreSetName
            print("|cffffd200[INFO][Equipper]: Restore set '" .. restoreSetName .. "' queued for after combat.|r")
        else
            EquipSet(restoreSetName)
            print("|cffffd200[INFO][Equipper]: Mount set swapped back to '" .. restoreSetName .. "'.|r")
        end
    end
end

local function SyncMountedTriggerState()
    local mounted = IsMounted() or false
    if mounted and not PFEquipper_IsMounted then
        PFEquipper_IsMounted = true
        HandleMountedTrigger()
    elseif not mounted and PFEquipper_IsMounted then
        PFEquipper_IsMounted = false
        HandleUnmountTrigger()
    end
end


local bar = CreateFrame("Frame", "PFEquipper_QuickBar", UIParent, "BackdropTemplate")
bar:SetSize(40, 40)
bar:SetPoint("CENTER", 200, 0)
bar:SetMovable(true)
bar:EnableMouse(true)
bar:RegisterForDrag("LeftButton")
bar:SetBackdrop({bgFile = "Interface\\Buttons\\White8x8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = {left=2,right=2,top=2,bottom=2}})
bar:SetBackdropColor(0,0,0,0.5)
bar:SetScript("OnDragStart", function(self) if not PFEquipperDB.barLocked then self:StartMoving() end end)
bar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    PFEquipperDB.barPoint = point
    PFEquipperDB.barRelPoint = relPoint
    PFEquipperDB.barX = x
    PFEquipperDB.barY = y
end)

local barButtons = {}

local function AddBankedItemsToTooltip(tooltip, data)
    if not data or not data.items then return end

    local bankedItems = {}
    for slotID, itemData in pairs(data.items) do
        if itemData then
            local state = GetItemAvailabilityState(itemData, slotID)
            if state == "banked" then
                local entry = NormalizeItemData(itemData)
                local itemID = entry and entry.id
                local itemLink = entry and entry.link
                local itemInfo = { C_Item.GetItemInfo(itemLink or itemID) }
                local name = itemInfo[1] or (entry and entry.name) or "Unknown item"
                tinsert(bankedItems, name)
            end
        end
    end

    if #bankedItems > 0 then
        tooltip:AddLine(" ", 0.7, 0.7, 0.7)
        tooltip:AddLine("|cffffd200Banked items:|r", 0.7, 0.7, 0.7)
        for _, name in ipairs(bankedItems) do
            tooltip:AddLine("- " .. name, 0.8, 0.8, 0.8)
        end
    end
end

function UpdateQuickBar()
    if InCombatLockdown() then return end
    if not PFEquipperDB.showBar or not next(PFEquipperDB.sets) then 
        bar:Hide() 
        return 
    end

    for _, btn in ipairs(barButtons) do btn:Hide() end
    
    local sortedNames = {}
    for name, data in pairs(PFEquipperDB.sets) do
        if data.showInBar ~= false then tinsert(sortedNames, name) end
    end
    tsort(sortedNames)

    local direction = PFEquipperDB.barDirection or "right"
    local btnSize, spacing = 34, 38
    local total = #sortedNames

    for i, name in ipairs(sortedNames) do
        local data = PFEquipperDB.sets[name]
        local btn = barButtons[i] or CreateFrame("Button", nil, bar, "SecureActionButtonTemplate, BackdropTemplate")
        barButtons[i] = btn
        btn:SetSize(btnSize, btnSize)
        btn:Show()
        
        btn:SetScript("OnEnter", function(self)
            ShowSetTooltip(self, name) 
        end)
        btn:SetScript("OnLeave", function() 
            GameTooltip:Hide() 
        end)

        btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
        btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

        btn.icon = btn.icon or btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetAllPoints()
        btn.icon:SetTexture(data.icon or 134400)
        ApplySetIconState(btn, GetSetAvailabilityState(data))

        btn:SetScript("OnClick", function()
            local setData = PFEquipperDB.sets[name]
            if setData and setData.trigger == "DroppedCombat" and InCombatLockdown() then
                PFEquipper_QueuedSet = name
                print("|cffffd200[INFO][Equipper]: Set '"..name.."' queued for after combat.|r")
            else
                EquipSet(name) 
            end
        end)

        btn:SetScript("OnEnter", function(self)
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(name, unpack(data.color or {1, 0.82, 0}))
            if data.trigger then
                GameTooltip:AddLine("|cffb0b0ffTrigger:|r " .. data.trigger)
            end
            AddBankedItemsToTooltip(GameTooltip, data)
            GameTooltip:AddLine("|cff00ff00Click:|r Equip Set|r", 0.7, 0.7, 0.7)
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btn:ClearAllPoints()
        if direction == "up" then
            btn:SetPoint("BOTTOM", bar, "BOTTOM", 0, ((i-1) * spacing) + 5)
        elseif direction == "down" then
            btn:SetPoint("TOP", bar, "TOP", 0, -((i-1) * spacing) - 5)
        elseif direction == "left" then
            btn:SetPoint("RIGHT", bar, "RIGHT", -((i-1) * spacing) - 5, 0)
        elseif direction == "right" then
            btn:SetPoint("LEFT", bar, "LEFT", 5 + ((i-1) * spacing), 0)
        elseif direction == "centered_h" then
            local offset = ((i-1) - (total-1)/2) * spacing
            btn:SetPoint("CENTER", bar, "CENTER", offset, 0)
        elseif direction == "centered_v" then
            local offset = -(((i-1) - (total-1)/2) * spacing) 
            btn:SetPoint("CENTER", bar, "CENTER", 0, offset)
        end
    end

    if direction == "up" or direction == "down" or direction == "centered_v" then
        bar:SetSize(btnSize + 10, (total * spacing) + 6)
    else
        bar:SetSize((total * spacing) + 6, btnSize + 10)
    end

    if total == 0 then bar:Hide() else bar:Show() end
end

local frame = CreateFrame("Frame", "PF_EquipperFrame", CharacterFrame, "BasicFrameTemplateWithInset")
frame:SetSize(200, 420) 
frame:Hide()
frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.title:SetPoint("TOPLEFT", 15, -5)
frame.title:SetText("Gear Sets")

local gearsetLabel = CharacterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
if CharacterGuildText then
    gearsetLabel:SetPoint("TOP", CharacterGuildText, "BOTTOM", 0, -2)
else
    gearsetLabel:SetPoint("TOP", CharacterFrame, "TOP", 0, -72)
end
gearsetLabel:SetText("")
gearsetLabel:Hide()

local function UpdateEquippedGearsetLabel()
    local equippedSetName = nil
    for name, data in pairs(PFEquipperDB.sets) do
        local matches = true
        for slot, itemData in pairs(data.items) do
            if not GetInventoryItemMatch(itemData, slot) then
                matches = false
                break
            end
        end
        if matches then
            equippedSetName = name
            break
        end
    end
    if equippedSetName then
        gearsetLabel:SetText("Gearset: |cff00ff00" .. equippedSetName .. "|r")
        gearsetLabel:Show()
    else
        gearsetLabel:SetText("")
        gearsetLabel:Hide()
    end
end

CharacterFrame:HookScript("OnShow", function()
    UpdateEquippedGearsetLabel()
end)

local gearUpdateFrame = CreateFrame("Frame")
gearUpdateFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
gearUpdateFrame:SetScript("OnEvent", function()
    if CharacterFrame:IsShown() then
        UpdateEquippedGearsetLabel()
    end

    if IsMounted() then
        UpdateMountedSetMemory()
    end
end)

local function CreateMainCB(label, dbKey, tooltip)
    local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb:SetSize(22, 22)
    cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 0, 1)
    cb.text:SetText(label)
    cb:SetScript("OnClick", function(self) 
        PFEquipperDB[dbKey] = self:GetChecked() 
        UpdateQuickBar() 
    end)
    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltip)
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", GameTooltip_Hide)
    return cb
end

local showBarCB = CreateMainCB("Show Bar", "showBar", "Toggle the Quick-Access gear bar visibility.")
showBarCB:SetPoint("TOPLEFT", 10, -28)

local lockBarCB = CreateMainCB("Lock", "barLocked", "Lock the Quick-Access bar position.")
lockBarCB:SetPoint("LEFT", showBarCB.text, "RIGHT", 5, 0)

local barDirectionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
barDirectionLabel:SetPoint("TOPLEFT", showBarCB, "BOTTOMLEFT", 0, -5)
barDirectionLabel:SetText("Bar Direction:")

local barDirectionDropdown = CreateFrame("Frame", "PFEquipper_BarDirectionDropdown", frame, "UIDropDownMenuTemplate")
barDirectionDropdown:SetPoint("TOPLEFT", barDirectionLabel, "BOTTOMLEFT", -15, -2)

local scrollFrame = CreateFrame("ScrollFrame", "PFEquipper_SetListScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -110) 
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -34, 45) 

local scrollChild = CreateFrame("Frame", "PFEquipper_SetListScrollChild", scrollFrame)
scrollChild:SetSize(125, 1) 
scrollFrame:SetScrollChild(scrollChild)

local barDirections = {
    { text = "Up", value = "up" },
    { text = "Down", value = "down" },
    { text = "Left", value = "left" },
    { text = "Right", value = "right" },
    { text = "Centered Horizontal", value = "centered_h" },
    { text = "Centered Vertical", value = "centered_v" },
}

UIDropDownMenu_Initialize(barDirectionDropdown, function(self, level, menuList)
    for _, dir in ipairs(barDirections) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = dir.text
        info.value = dir.value
        info.func = function()
            PFEquipperDB.barDirection = dir.value
            UIDropDownMenu_SetSelectedValue(barDirectionDropdown, dir.value)
            UpdateQuickBar()
        end
        UIDropDownMenu_AddButton(info)
    end
end)
UIDropDownMenu_SetWidth(barDirectionDropdown, 120)


local function AdjustGearFramePosition()
    if not frame:IsShown() then return end
    frame:ClearAllPoints()
    if EngravingFrame and EngravingFrame:IsShown() then
        frame:SetPoint("TOP", CharacterFrame, "TOP", 0, -12)
        frame:SetPoint("LEFT", EngravingFrame, "RIGHT", -5, 0)
    else
        frame:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", -30, -12)
    end
end

local toggleBtn = CreateFrame("Button", "PF_EquipperToggleButton", PaperDollFrame, "UIPanelButtonTemplate")
toggleBtn:SetSize(22, 22)
toggleBtn:SetText("G")

local function SnapToggleButton()
    if RuneFrameControlButton then
        toggleBtn:ClearAllPoints()
        toggleBtn:SetPoint("RIGHT", RuneFrameControlButton, "LEFT", -2, 0)
    else
        toggleBtn:ClearAllPoints()
        toggleBtn:SetPoint("TOPRIGHT", PaperDollFrame, "TOPRIGHT", -35, -38)
    end
end

toggleBtn:SetScript("OnClick", function()
    if frame:IsShown() then frame:Hide() else frame:Show() AdjustGearFramePosition() end
end)


local saveFrame = CreateFrame("Frame", "PFEquipper_SaveFrame", UIParent, "BasicFrameTemplateWithInset")
saveFrame:SetSize(220, 470)
saveFrame:SetPoint("CENTER")
saveFrame:SetFrameStrata("DIALOG")
saveFrame:Hide()

saveFrame:SetMovable(true)
saveFrame:EnableMouse(true)
saveFrame:RegisterForDrag("LeftButton")
saveFrame:SetScript("OnDragStart", saveFrame.StartMoving)
saveFrame:SetScript("OnDragStop", saveFrame.StopMovingOrSizing)

tinsert(UISpecialFrames, "PFEquipper_SaveFrame")

saveFrame.title = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
saveFrame.title:SetPoint("TOP", 0, -5)
saveFrame.title:SetText("Gear Set Details")
saveFrame:HookScript("OnHide", function()
    if PF_EquipperIconPicker then
        PF_EquipperIconPicker:Hide()
    end
end)

local nameBox = CreateFrame("EditBox", nil, saveFrame, "InputBoxTemplate")
nameBox:SetSize(180, 20)
nameBox:SetPoint("TOP", 0, -45)
nameBox:SetScript("OnEscapePressed", function(self)
    PF_EquipperIconPicker:Hide() 
    saveFrame:Hide()            
    self:ClearFocus()           
end)
local l1 = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
l1:SetPoint("BOTTOMLEFT", nameBox, "TOPLEFT", 0, 5)
l1:SetText("Set Name:")

local iconBox = CreateFrame("EditBox", "PFEquipper_IconBox", saveFrame, "InputBoxTemplate")
iconBox:SetSize(100, 20)
iconBox:SetPoint("TOPLEFT", 20, -95)
iconBox:SetScript("OnEscapePressed", function(self)
    PF_EquipperIconPicker:Hide() 
    saveFrame:Hide()            
    self:ClearFocus()           
end)
local l2 = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
l2:SetPoint("BOTTOMLEFT", iconBox, "TOPLEFT", 0, 5)
l2:SetText("Icon ID:")

local pickIconBtn = CreateFrame("Button", nil, saveFrame, "UIPanelButtonTemplate")
pickIconBtn:SetSize(30, 22)
pickIconBtn:SetPoint("LEFT", iconBox, "RIGHT", 5, 0)
pickIconBtn:SetText("...")
pickIconBtn:SetScript("OnClick", function() PF_EquipperIconPicker:Show() end)

local iconPreview = saveFrame:CreateTexture(nil, "OVERLAY")
iconPreview:SetSize(30, 30)
iconPreview:SetPoint("LEFT", pickIconBtn, "RIGHT", 10, 0)
iconPreview:SetTexture(134400)

iconBox:SetScript("OnTextChanged", function(self)
    local iconID = tonumber(self:GetText())
    iconPreview:SetTexture(iconID or 134400)
end)

local showInBarCB = CreateFrame("CheckButton", nil, saveFrame, "UICheckButtonTemplate")
showInBarCB:SetSize(22, 22)
showInBarCB.text = showInBarCB:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
showInBarCB.text:SetPoint("LEFT", showInBarCB, "RIGHT", 0, 1)
showInBarCB.text:SetText("Show in Quick Bar")
showInBarCB:SetPoint("TOPLEFT", iconBox, "BOTTOMLEFT", 0, -55)
showInBarCB:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("If checked, this set will appear in the Quick Bar.")
    GameTooltip:Show()
end)
showInBarCB:SetScript("OnLeave", GameTooltip_Hide)

local triggerLabel = saveFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
triggerLabel:SetPoint("TOPLEFT", iconBox, "BOTTOMLEFT", 0, -8)
triggerLabel:SetText("Trigger:")

local triggerDropdown = CreateFrame("Frame", "PFEquipper_TriggerDropdown", saveFrame, "UIDropDownMenuTemplate")
triggerDropdown:SetPoint("TOPLEFT", triggerLabel, "BOTTOMLEFT", -15, -2)

local availableTriggers = {
    { text = "None", value = "None" },
    { text = "DroppedCombat", value = "DroppedCombat" },
    { text = "Mounted", value = "Mounted" },
}

local selectedTrigger = "None"

UIDropDownMenu_Initialize(triggerDropdown, function(self, level, menuList)
    for _, trigger in ipairs(availableTriggers) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = trigger.text
        info.value = trigger.value
        info.func = function()
            selectedTrigger = trigger.value
            UIDropDownMenu_SetSelectedValue(triggerDropdown, trigger.value)
        end
        UIDropDownMenu_AddButton(info)
    end
end)
UIDropDownMenu_SetWidth(triggerDropdown, 120)
UIDropDownMenu_SetSelectedValue(triggerDropdown, "None")

local slotButtons = {}
local ignoredSlots = {}

local gridOrder = {
    1, 2, 3, 15, 5, 4, 19, 9,  
    10, 6, 7, 8, 11, 12, 13, 14, 
    16, 17, 18 
}

local function ToggleSlot(btn, slotID)
    ignoredSlots[slotID] = not ignoredSlots[slotID]
    btn.icon:SetDesaturated(ignoredSlots[slotID])
    btn.check:SetShown(not ignoredSlots[slotID])
    btn:SetAlpha(ignoredSlots[slotID] and 0.5 or 1.0)
end

for i, slotID in ipairs(gridOrder) do
    local btn = CreateFrame("Button", nil, saveFrame, "BackdropTemplate")
    btn:SetSize(34, 34)
    btn.slotID = slotID

    btn:SetBackdrop({edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 8})
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetAllPoints()

    btn.check = btn:CreateTexture(nil, "OVERLAY")
    btn.check:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
    btn.check:SetSize(14, 14)
    btn.check:SetPoint("BOTTOMRIGHT", 2, -2)

    local col = (i-1) % 4
    local row = math_floor((i-1) / 4)
    btn:SetPoint("TOPLEFT", 25 + (col * 43), -225 - (row * 40))

    btn:SetScript("OnClick", function(self) ToggleSlot(self, self.slotID) end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local link = GetInventoryItemLink("player", self.slotID)
        if link then GameTooltip:SetHyperlink(link) else GameTooltip:SetText("Empty Slot") end
        GameTooltip:AddLine("\n|cff00ff00Click to toggle saving this slot|r", 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)

    slotButtons[slotID] = btn
end

local function SaveAction()
    local name = nameBox:GetText():trim()
    if name == "" then 
        print("|[cffff0000INFO][Equipper]: Please enter a set name.|r")
        return 
    end
    local isUpdatingSameName = (saveFrame.mode == "UPDATE" and name == saveFrame.originalName)
    if PFEquipperDB.sets[name] and not isUpdatingSameName then
        StaticPopup_Show("PFEQUIPPER_OVERWRITE_CONFIRM", name)
        return
    end
    local manualID = tonumber(iconBox:GetText())
    local finalIcon = manualID or randomIcons[math_random(#randomIcons)]
    local currentItems = GetCurrentSet()
    local filteredItems = {}
    for slotID, data in pairs(currentItems) do
        if not ignoredSlots[slotID] then
            filteredItems[slotID] = data
        end
    end
    if saveFrame.mode == "UPDATE" and saveFrame.originalName ~= name then
        PFEquipperDB.sets[saveFrame.originalName] = nil
    end
    PFEquipperDB.sets[name] = {
        items = filteredItems,
        icon = finalIcon,
        color = PFEquipperDB.sets[name] and PFEquipperDB.sets[name].color or {math_random(5,10)/10, math_random(5,10)/10, math_random(5,10)/10},
        trigger = (selectedTrigger ~= "None") and selectedTrigger or nil,
        showInBar = showInBarCB:GetChecked() and true or false
    }
    UpdateSetList() 
    UpdateQuickBar() 
    saveFrame:Hide()
end

StaticPopupDialogs["PFEQUIPPER_OVERWRITE_CONFIRM"] = {
    text = "A gear set named '%s' already exists. Do you want to overwrite it?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function(self)
        local name = nameBox:GetText():trim()
        saveFrame.originalName = name 
        saveFrame.mode = "UPDATE"
        SaveAction()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local confirmSave = CreateFrame("Button", nil, saveFrame, "UIPanelButtonTemplate")
confirmSave:SetSize(80, 22) confirmSave:SetPoint("BOTTOMLEFT", 15, 15)
confirmSave:SetText("Save") confirmSave:SetScript("OnClick", SaveAction)

local cancelSave = CreateFrame("Button", nil, saveFrame, "UIPanelButtonTemplate")
cancelSave:SetSize(80, 22) cancelSave:SetPoint("BOTTOMRIGHT", -15, 15)
cancelSave:SetText("Cancel") cancelSave:SetScript("OnClick", function() saveFrame:Hide() end)

function OpenGearDialog(name, icon)
    nameBox:SetText(name or "")
    iconBox:SetText(icon or "")
    ignoredSlots = {}
    saveFrame.mode = (name ~= "" and name ~= nil) and "UPDATE" or "NEW"
    saveFrame.originalName = name or ""
    local existingSet = PFEquipperDB.sets[name]
    for slotID, btn in pairs(slotButtons) do
        local texture = GetInventoryItemTexture("player", slotID)
        btn.icon:SetTexture(texture or 134400)
        if existingSet then
            ignoredSlots[slotID] = (existingSet.items[slotID] == nil)
        else
            ignoredSlots[slotID] = (texture == nil)
        end
        btn.icon:SetDesaturated(ignoredSlots[slotID])
        btn.check:SetShown(not ignoredSlots[slotID])
        btn:SetAlpha(ignoredSlots[slotID] and 0.5 or 1.0)
    end
    if existingSet and existingSet.trigger then
        selectedTrigger = existingSet.trigger
        UIDropDownMenu_SetSelectedValue(triggerDropdown, existingSet.trigger)
    else
        selectedTrigger = "None"
        UIDropDownMenu_SetSelectedValue(triggerDropdown, "None")
    end
    if existingSet and existingSet.showInBar ~= nil then
        showInBarCB:SetChecked(existingSet.showInBar)
    else
        showInBarCB:SetChecked(true)
    end
    if _G[triggerDropdown:GetName() .. "Text"] then
        local text = "Custom"
        for _, t in ipairs(availableTriggers) do
            if t.value == selectedTrigger then text = t.text break end
        end
        _G[triggerDropdown:GetName() .. "Text"]:SetText(text)
    end
    saveFrame:Show()
end


local optFrame = CreateFrame("Frame", "PFEquipper_Options", UIParent, "BasicFrameTemplateWithInset")
optFrame:SetSize(160, 110) 
optFrame:SetFrameStrata("DIALOG")
optFrame:Hide()
optFrame.title = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
optFrame.title:SetPoint("TOPLEFT", 10, -5)
optFrame.title:SetText("Manage Set")

optFrame:SetScript("OnUpdate", function(self)
    if (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")) and not self:IsMouseOver() then
        self:Hide()
    end
end)

local updateBtn = CreateFrame("Button", nil, optFrame, "UIPanelButtonTemplate")
updateBtn:SetSize(135, 22)
updateBtn:SetPoint("TOP", 0, -35)
updateBtn:SetText("Update / Edit")

local deleteBtn = CreateFrame("Button", nil, optFrame, "UIPanelButtonTemplate")
deleteBtn:SetSize(135, 22)
deleteBtn:SetPoint("TOP", updateBtn, "BOTTOM", 0, -5)
deleteBtn:SetText("Delete Set")

local bankBtn = CreateFrame("Button", nil, optFrame, "UIPanelButtonTemplate")
bankBtn:SetSize(135, 22)
bankBtn:SetPoint("TOP", deleteBtn, "BOTTOM", 0, -5)
bankBtn:SetText("Bank Set")
bankBtn:Hide()


local moveQueue = {}
local moveTimer = 0

local BankWorker = CreateFrame("Frame")
BankWorker:Hide() 

local function ProcessBankQueue(self, elapsed)
    if #moveQueue == 0 then 
        UpdateBankCache()
        UpdateQuickBar()
        UpdateSetList()
        if GameTooltip and GameTooltip:IsShown() and PFEquipper_ActiveTooltipOwner and PFEquipper_ActiveTooltipSetName then
            GameTooltip:Hide()
            ShowSetTooltip(PFEquipper_ActiveTooltipOwner, PFEquipper_ActiveTooltipSetName)
        end
        if ItemRefTooltip and ItemRefTooltip:IsShown() then ItemRefTooltip:Hide() end
        self:Hide() 
        return 
    end

    moveTimer = moveTimer + elapsed
    if moveTimer > 0.15 then 
        moveTimer = 0
        local task = tremove(moveQueue, 1)
        
        local sourceItemID = C_Container.GetContainerItemID(task.fromBag, task.fromSlot)
        if sourceItemID then
            C_Container.PickupContainerItem(task.fromBag, task.fromSlot)
            C_Container.PickupContainerItem(task.toBag, task.toSlot)

            if CursorHasItem() then
                ClearCursor() 
            end
        end
    end
end

BankWorker:SetScript("OnUpdate", ProcessBankQueue)

local function BankSet(setName)
    local data = PFEquipperDB.sets[setName]
    if not data or not BankFrame:IsShown() then return end

    moveQueue = {} 
    
    local freeBankSlots = {}
    for bag = -1, 11 do
        if bag == -1 or (bag >= 5 and bag <= 11) then
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                if not C_Container.GetContainerItemID(bag, slot) then
                    tinsert(freeBankSlots, {bag = bag, slot = slot})
                end
            end
        end
    end

    for slot, itemData in pairs(data.items) do
        local entry = NormalizeItemData(itemData)
        local itemID = entry and entry.id

        for bag = 0, 4 do
            for slotIdx = 1, C_Container.GetContainerNumSlots(bag) do
                local containerGUID = GetContainerItemGUIDSafe(bag, slotIdx)
                local containerItemID = C_Container.GetContainerItemID(bag, slotIdx)
                local matchesByGUID = entry and entry.guid and containerGUID and entry.guid == containerGUID
                local matchesByID = itemID and containerItemID and containerItemID == itemID
                if matchesByGUID or matchesByID then
                    if #freeBankSlots > 0 then
                        local dest = tremove(freeBankSlots, 1)
                        tinsert(moveQueue, {
                            fromBag = bag, fromSlot = slotIdx,
                            toBag = dest.bag, toSlot = dest.slot
                        })
                    end
                end
            end
        end
    end

    if #moveQueue > 0 then
        print("|cff00ff00[INFO][Equipper]: Banking " .. #moveQueue .. " items...|r")
        moveTimer = 0
        BankWorker:Show() 
    else
        print("|cffff0000[INFO][Equipper]: No items found in bags to bank.|r")
    end
end

local targetSetName = ""
function ShowManagementMenu(setName)
    targetSetName = setName
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    optFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (x/scale) + 5, (y/scale) - 5)
    if BankFrame and BankFrame:IsShown() then
        bankBtn:Show()
    else
        bankBtn:Hide()
    end
    optFrame:Show()
end

updateBtn:SetScript("OnClick", function()
    local data = PFEquipperDB.sets[targetSetName]
    if data then
        optFrame:Hide()
        OpenGearDialog(targetSetName, tostring(data.icon))
    end
end)

deleteBtn:SetScript("OnClick", function()
    PFEquipperDB.sets[targetSetName] = nil
    UpdateSetList() 
    UpdateQuickBar() 
    optFrame:Hide() 
end)

bankBtn:SetScript("OnClick", function()
    optFrame:Hide()
    BankSet(targetSetName)
end)

local picker = CreateFrame("Frame", "PF_EquipperIconPicker", UIParent, "BasicFrameTemplateWithInset")
picker:SetSize(210, 260)
picker:SetPoint("LEFT", PFEquipper_SaveFrame, "RIGHT", 10, 0)
picker:SetFrameStrata("DIALOG")
picker:Hide()
tinsert(UISpecialFrames, "PF_EquipperIconPicker")

local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", picker, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -30)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 45)
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(160, 1)
scrollFrame:SetScrollChild(content)

local pickerButtons = {}
local function RefreshIconPicker()
    for _, btn in ipairs(pickerButtons) do btn:Hide() end
    local displayList = {}
    for _, id in ipairs(randomIcons) do tinsert(displayList, id) end
    for _, id in ipairs(PFEquipperDB.learnedIcons or {}) do tinsert(displayList, id) end

    for i, iconID in ipairs(displayList) do
        local btn = pickerButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, content)
            btn:SetSize(36, 36)
            btn.tex = btn:CreateTexture(nil, "ARTWORK")
            btn.tex:SetAllPoints()
            btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
            pickerButtons[i] = btn
        end
        local col = (i - 1) % 4
        local row = math_floor((i - 1) / 4)
        btn:SetPoint("TOPLEFT", col * 40, -(row * 40))
        btn.tex:SetTexture(iconID)
        btn:SetScript("OnClick", function() 
            PFEquipper_IconBox:SetText(iconID) 
        end)
        btn:Show()
    end
    content:SetHeight(math.ceil(#displayList / 4) * 40)
end
picker:SetScript("OnShow", RefreshIconPicker)

local closePicker = CreateFrame("Button", nil, picker, "UIPanelButtonTemplate")
closePicker:SetSize(120, 22)
closePicker:SetPoint("BOTTOM", 0, 12)
closePicker:SetText("Done")
closePicker:SetScript("OnClick", function() picker:Hide() end)

local PFEquipper_ActiveTooltipOwner = nil
local PFEquipper_ActiveTooltipSetName = nil

local function ShowSetTooltip(self, setName)
    local data = PFEquipperDB.sets[setName]
    if not data then return end
    PFEquipper_ActiveTooltipOwner = self
    PFEquipper_ActiveTooltipSetName = setName
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local r, g, b = unpack(data.color or {1, 0.82, 0})
    AddTooltipLine(GameTooltip, setName, r, g, b)
    if data.trigger then
        AddTooltipLine(GameTooltip, "|cffb0b0ffTrigger:|r " .. data.trigger, 0.7, 0.7, 0.7)
    end
    for slot = 1, 18 do
        local itemData = data.items[slot]
        if itemData then
            local entry = NormalizeItemData(itemData)
            local itemID = entry and entry.id
            local itemLink = entry and entry.link
            local itemInfo = { C_Item.GetItemInfo(itemLink or itemID) }
            local name, _, quality, _, _, _, _, _, _, icon = unpack(itemInfo)
            if name then
                local _, _, _, hex = C_Item.GetItemQualityColor(quality)
                local location = GetItemLocationText(entry or itemID)
                local iconTexture = ResolveItemIcon(entry) or icon
                local iconText = iconTexture and ("|T" .. iconTexture .. ":16:16:0:0|t ") or ""
                local lineText = iconText .. "|c" .. hex .. name .. "|r " .. location
                AddTooltipLine(GameTooltip, lineText, 1, 1, 1, true)
                if entry and (entry.rune or entry.enchant) then
                    local rLine = entry.rune and ("|c159cd100" .. entry.rune .. "|r")
                    local eLine = entry.enchant and ("|cff00ff00" .. entry.enchant .. "|r")
                    local text = (rLine and eLine) and (rLine .. " / " .. eLine) or (rLine or eLine)
                    AddTooltipLine(GameTooltip, "   (" .. text .. ")", 0.75, 0.75, 0.75, true)
                end
            end
        end
    end
    GameTooltip:Show()
end

local setButtons = {}
function UpdateSetList()
    for _, btn in ipairs(setButtons) do btn:Hide() end
    
    local sorted = {}
    for name in pairs(PFEquipperDB.sets) do tinsert(sorted, name) end
    tsort(sorted)

    local btnHeight = 28
    for i, name in ipairs(sorted) do
        local data = PFEquipperDB.sets[name]
        local btn = setButtons[i] or CreateFrame("Button", nil, scrollChild, "UIPanelButtonTemplate")
        setButtons[i] = btn
        
        btn:SetSize(160, 26) 
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -((i-1) * btnHeight))
        
        btn.icon = btn.icon or btn:CreateTexture(nil, "OVERLAY")
        btn.icon:SetSize(20, 20)
        btn.icon:SetPoint("LEFT", btn, "LEFT", 6, 0)
        btn.icon:SetTexture(data.icon or 134400)
        ApplySetIconState(btn, GetSetAvailabilityState(data))
        
        local fs = btn:GetFontString()
        fs:ClearAllPoints()
        fs:SetPoint("LEFT", btn.icon, "RIGHT", 5, 0)
        fs:SetPoint("RIGHT", btn, "RIGHT", -5, 0)
        fs:SetJustifyH("LEFT")
        
        if data.color then
            fs:SetTextColor(unpack(data.color))
        else
            fs:SetTextColor(1, 0.82, 0)
        end
        
        btn:SetText(name)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(_, b) 
            if b == "LeftButton" then EquipSet(name) else ShowManagementMenu(name) end 
        end)
        btn:SetScript("OnEnter", function(self) ShowSetTooltip(self, name) end)
        btn:SetScript("OnLeave", function()
            PFEquipper_ActiveTooltipOwner = nil
            PFEquipper_ActiveTooltipSetName = nil
            GameTooltip:Hide()
        end)
        btn:Show()
    end

    scrollChild:SetHeight(math.max(1, #sorted * btnHeight))
end

local saveBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
saveBtn:SetSize(130, 25)
saveBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
saveBtn:SetText("+ Save Current")
saveBtn:SetScript("OnClick", function() 
    LearnCurrentIcons()
    OpenGearDialog("", "") 
end)

local eFrame = CreateFrame("Frame")
eFrame:RegisterEvent("ADDON_LOADED")
eFrame:RegisterEvent("BANKFRAME_OPENED")
eFrame:RegisterEvent("BANKFRAME_CLOSED")
eFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eFrame:RegisterEvent("PLAYER_LOGIN")
eFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
eFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
eFrame:RegisterEvent("BAG_UPDATE")
eFrame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
eFrame:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")
eFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Blizzard_EngravingUI" then
        if EngravingFrame then
            EngravingFrame:HookScript("OnShow", AdjustGearFramePosition)
            EngravingFrame:HookScript("OnHide", AdjustGearFramePosition)
        end
    elseif event == "BANKFRAME_OPENED" then 
        UpdateBankCache()
        UpdateQuickBar()
        UpdateSetList()
    elseif event == "BANKFRAME_CLOSED" then
        UpdateQuickBar()
        UpdateSetList()
    elseif event == "PLAYER_LOGIN" then
        showBarCB:SetChecked(PFEquipperDB.showBar)
        lockBarCB:SetChecked(PFEquipperDB.barLocked)

        if PFEquipperDB.barX and PFEquipperDB.barY then
            bar:ClearAllPoints()
            bar:SetPoint(
                PFEquipperDB.barPoint or "CENTER", 
                UIParent, 
                PFEquipperDB.barRelPoint or "CENTER", 
                PFEquipperDB.barX, 
                PFEquipperDB.barY
            )
        end


        UIDropDownMenu_SetSelectedValue(barDirectionDropdown, PFEquipperDB.barDirection or "right")
        UIDropDownMenu_SetText(barDirectionDropdown, PFEquipperDB.barDirection or "Right")
        
        SyncMountedTriggerState()
        UpdateQuickBar()
        UpdateSetList()
    elseif event == "PLAYER_REGEN_ENABLED" then 
        UpdateQuickBar()
        if PFEquipper_QueuedSet then
            local queued = PFEquipper_QueuedSet
            PFEquipper_QueuedSet = nil
            EquipSet(queued)
            print("|cff00ff00[Info][Equipper]: Equipped queued set '"..queued.."' after combat.|r")
        end
    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        SyncMountedTriggerState()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE" or event == "PLAYERBANKSLOTS_CHANGED" or event == "PLAYERBANKBAGSLOTS_CHANGED" then
        UpdateQuickBar()
        UpdateSetList()
        if CharacterFrame:IsShown() then
            UpdateEquippedGearsetLabel()
        end
    end
end)

CharacterFrame:HookScript("OnShow", function() SnapToggleButton() AdjustGearFramePosition() end)
CharacterFrame:HookScript("OnHide", function() flyout:Hide() end)

local hoveredSlotFrame = nil

local slotNames = {"HeadSlot","NeckSlot","ShoulderSlot","BackSlot","ChestSlot","ShirtSlot","TabardSlot","WristSlot","HandsSlot","WaistSlot","LegsSlot","FeetSlot","Finger0Slot","Finger1Slot","Trinket0Slot","Trinket1Slot","MainHandSlot","SecondaryHandSlot","RangedSlot"}
for _, name in ipairs(slotNames) do
    local slot = _G["Character"..name]
    if slot then
        slot:HookScript("OnEnter", function(self)
            hoveredSlotFrame = self
            ShowFlyout(self, self:GetID(), IsShiftDown() and "runes" or "items")
        end)
        slot:HookScript("OnLeave", function(self)
            hoveredSlotFrame = nil
        end)
    end
end

local shiftWatcher = CreateFrame("Frame")
shiftWatcher:RegisterEvent("MODIFIER_STATE_CHANGED")
shiftWatcher:SetScript("OnEvent", function(_, event, key, state)
    if key == "LSHIFT" or key == "RSHIFT" then
        local mode = (state == 1) and "runes" or "items"
        
        if flyout:IsShown() and flyout.owner then
            flyout.switching = true
            flyout.timer = 0
            ShowFlyout(flyout.owner, flyout.currentSlotID, mode)
            flyout.switching = false
        elseif hoveredSlotFrame and hoveredSlotFrame:IsMouseOver() then
            ShowFlyout(hoveredSlotFrame, hoveredSlotFrame:GetID(), mode)
        else
        end
    end
end)

function PF_Equipper_SetEngraveActive(active)
    engraveActive = active
end

local function OnTooltipSetItem(tooltip)
    local _, link = tooltip:GetItem()
    if not link then return end

    local itemID = C_Item.GetItemInfoInstant(link)
    if not itemID then return end

    local foundInSets = {}

    for setName, data in pairs(PFEquipperDB.sets) do
        for slotID, itemData in pairs(data.items) do
            local entry = NormalizeItemData(itemData)
            local savedLink = entry and entry.link
            local savedID = entry and entry.id
            local sameByLink = savedLink and savedLink == link
            local sameByID = savedID and savedID == itemID
            if sameByLink or sameByID then
                local r, g, b = unpack(data.color)
                local hex = string.format("ff%02x%02x%02x", r*255, g*255, b*255)
                tinsert(foundInSets, "|c" .. hex .. setName .. "|r")
                break 
            end
        end
    end

    if #foundInSets > 0 then
        tooltip:AddLine(" ") 
        tooltip:AddLine("Gearset: " .. tconcat(foundInSets, ", "))
        tooltip:Show()
    end
end

GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ItemRefTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip1:HookScript("OnTooltipSetItem", OnTooltipSetItem)
ShoppingTooltip2:HookScript("OnTooltipSetItem", OnTooltipSetItem)