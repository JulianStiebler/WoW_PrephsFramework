--[[
    <PrephsFramework_Tracking/WorldTrackingPins.lua>
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

---@type PrephsFramework
local Core = ns.PF

local HBDPins = Core.HBDPins
local logger = Core.Logger

-- ============================================================================
-- Constants & Lookups
-- ============================================================================

local NpcFlags = Core.Constants.Bitmasks.NpcFlags
local objFlags = Core.Constants.Bitmasks.objFlags

local npcData = Core.data.npcData
local objData = Core.data.objData
local mapData = Core.data.mapData

local bit_band = bit.band
local pairs = pairs
local ipairs = ipairs
local tremove = tremove
local wipe = wipe
local CreateFrame = CreateFrame
local string_find = string.find

local MOD_ID = "Tracking"
local FEATURE_NAME = "WorldTrackingPins"

-- Icons for each pin category
local POI_ICONS = {
    ["AUCTIONEER"]   = 136452, -- Interface\Minimap\Tracking\Auctioneer
    ["BANKER"]       = 136453, -- Interface\Minimap\Tracking\Banker
    ["BATTLEMASTER"] = 136454, -- Interface\Minimap\Tracking\Battlemaster
    ["FLIGHTMASTER"] = 136456, -- Interface\Minimap\Tracking\Flightmaster
    ["INNKEEPER"]    = 136458, -- Interface\Minimap\Tracking\Innkeeper
    ["MAILBOX"]      = 136459, -- Interface\Minimap\Tracking\Mailbox
    ["REPAIR"]       = 136465, -- Interface\Minimap\Tracking\Repair
    ["SPIRITHEALER"] = "Interface\\AddOns\\PrephsFramework_Tracking\\textures\\grave",
    ["STABLEMASTER"] = 136466, -- Interface\Minimap\Tracking\Stablemaster
    ["TRAINER"]      = 136463, -- Interface\Minimap\Tracking\Profession
    ["VENDOR"]       = 132060, -- Interface\gossipframe\vendorgossipicon
    ["DUNGEON"]      = 1502543, -- Interface\Minimap\Dungeon
    ["RAID"]         = 1502548, -- Interface\Minimap\Raid
}

-- Map NPC flag bits to category keys (REPAIR before VENDOR — order matters)
local NPC_FLAG_CATEGORIES = {
    { flag = NpcFlags.AUCTIONEER,   key = "AUCTIONEER" },
    { flag = NpcFlags.BANKER,       key = "BANKER" },
    { flag = NpcFlags.BATTLEMASTER, key = "BATTLEMASTER" },
    { flag = NpcFlags.FLIGHTMASTER, key = "FLIGHTMASTER" },
    { flag = NpcFlags.INNKEEPER,    key = "INNKEEPER" },
    { flag = NpcFlags.REPAIR,       key = "REPAIR" },
    { flag = NpcFlags.SPIRITHEALER, key = "SPIRITHEALER" },
    { flag = NpcFlags.STABLEMASTER, key = "STABLEMASTER" },
    { flag = NpcFlags.TRAINER,      key = "TRAINER" },
    { flag = NpcFlags.VENDOR,       key = "VENDOR" }, -- Must come after REPAIR
}

-- Object flag categories
local OBJ_FLAG_CATEGORIES = {
    { flag = objFlags.DUNGEON, key = "DUNGEON" },
    { flag = objFlags.RAID,    key = "RAID" },
    { flag = objFlags.MAILBOX, key = "MAILBOX" },
}

-- ============================================================================
-- Runtime State
-- ============================================================================

local playerFaction -- "A" or "H", set on load
local FlattenedData = {} -- [mapID][catKey] = { {name, desc, x, y, faction}, ... }
local mmPinPool = {}
local wmPinPool = {}
local activePins = { Minimap = {}, WorldMap = {} }

-- ============================================================================
-- Data Flattening — run once to build zone-indexed lookup
-- ============================================================================

local function IsFriendly(factionStr)
    if not factionStr then return true end
    if string_find(factionStr, playerFaction, 1, true) then return true end
    return false
end

local function AddToFlattened(catKey, name, desc, spawns, factionStr, translateAreaID)
    if not spawns then return end
    for rawMapID, coords in pairs(spawns) do
        local mapID = rawMapID
        if translateAreaID then
            mapID = mapData:GetZoneByAreaID(rawMapID)
            if not mapID then
                -- no mapping found, skip this zone
                -- logger:debug("[WTP] No uiMapID for areaID %d (NPC: %s)", rawMapID, name)
            end
        end
        if mapID then
            if not FlattenedData[mapID] then
                FlattenedData[mapID] = {}
            end
            if not FlattenedData[mapID][catKey] then
                FlattenedData[mapID][catKey] = {}
            end
            local bucket = FlattenedData[mapID][catKey]
            for _, coord in ipairs(coords) do
                bucket[#bucket + 1] = {
                    name = name,
                    desc = desc,
                    x = coord[1],
                    y = coord[2],
                    faction = factionStr,
                }
            end
        end
    end
end

local function FlattenPOI()
    wipe(FlattenedData)
    logger:debug("[WTP] FlattenPOI started — npcData.entries type: %s, objData.entries type: %s", type(npcData.entries), type(objData.entries))

    local npcCount, objCount = 0, 0

    -- Flatten NPC data by flag categories
    for npcID, entry in pairs(npcData.entries) do
        local name       = entry[1]
        local desc       = entry[2]
        local spawns     = entry[3]
        local factionStr = entry[5]
        local flags      = entry[6] or 0

        if IsFriendly(factionStr) then
            local isRepair = bit_band(flags, NpcFlags.REPAIR) ~= 0
            for _, catDef in ipairs(NPC_FLAG_CATEGORIES) do
                if bit_band(flags, catDef.flag) ~= 0 then
                    -- VENDOR: skip if this NPC also has REPAIR flag
                    if catDef.key == "VENDOR" and isRepair then
                        -- already categorized under REPAIR
                    else
                        AddToFlattened(catDef.key, name, desc, spawns, factionStr, true)
                        npcCount = npcCount + 1
                    end
                end
            end
        end
    end

    logger:debug("[WTP] NPC entries added: %d", npcCount)

    -- Flatten Object data by flag categories
    for flagKey, entries in pairs(objData.entries) do
        for _, catDef in ipairs(OBJ_FLAG_CATEGORIES) do
            if flagKey == catDef.flag then
                for objID, entry in pairs(entries) do
                    local name       = entry[1]
                    local desc       = entry[2]
                    local spawns     = entry[3]
                    local factionStr = entry[5]

                    if IsFriendly(factionStr) then
                        AddToFlattened(catDef.key, name, desc, spawns, factionStr)
                        objCount = objCount + 1
                    end
                end
            end
        end
    end

    -- Count total flattened entries across all zones
    local zoneCount, totalEntries = 0, 0
    for mapID, cats in pairs(FlattenedData) do
        zoneCount = zoneCount + 1
        for catKey, entries in pairs(cats) do
            totalEntries = totalEntries + #entries
        end
    end
    logger:debug("[WTP] FlattenPOI done — OBJ entries: %d, zones: %d, total pin entries: %d", objCount, zoneCount, totalEntries)
end

-- ============================================================================
-- Pin Pool & Tooltip
-- ============================================================================

local function OnPinEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:AddDoubleLine(self.pinTitle or "POI", self.pinFaction or "", 1, 1, 1)
    if self.pinDesc and self.pinDesc ~= "" then
        GameTooltip:AddLine(self.pinDesc, 1, 0.82, 0, true)
    end
    GameTooltip:Show()
end

local function OnPinLeave(self)
    GameTooltip:Hide()
end

local function AcquirePin(pinType)
    local pool = (pinType == "Minimap") and mmPinPool or wmPinPool
    local pin = tremove(pool)
    
    if not pin then
        pin = CreateFrame("Frame", nil, nil)
        pin.texture = pin:CreateTexture(nil, "OVERLAY")
        pin.texture:SetAllPoints()
        pin:SetScript("OnEnter", OnPinEnter)
        pin:SetScript("OnLeave", OnPinLeave)
    end
    
    pin:ClearAllPoints() -- CRITICAL: Reset anchors before reuse!
    pin:Show()
    return pin
end

local function ReleaseAllPins()
    for pinType, categories in pairs(activePins) do
        for catKey, pins in pairs(categories) do
            for i = 1, #pins do
                local pin = pins[i]
                pin:Hide()
                pin:ClearAllPoints()
                if pinType == "Minimap" then
                    HBDPins:RemoveMinimapIcon(FEATURE_NAME, pin)
                    mmPinPool[#mmPinPool + 1] = pin
                else
                    HBDPins:RemoveWorldMapIcon(FEATURE_NAME, pin)
                    wmPinPool[#wmPinPool + 1] = pin
                end
            end
            wipe(pins)
        end
    end
end

-- ============================================================================
-- Pin Placement
-- ============================================================================

local function GetSettings()
    local mmSize = Core:GetSetting(MOD_ID, FEATURE_NAME, "minimapIconSize") or 12
    local wmSize = Core:GetSetting(MOD_ID, FEATURE_NAME, "worldmapIconSize") or 16
    logger:debug("[WTP] GetSettings — mmSize: %s, wmSize: %s", tostring(mmSize), tostring(wmSize))
    return mmSize, wmSize
end

local function GetEnabledCategories()
    local db = Core:GetModuleDB(MOD_ID)
    logger:debug("[WTP] GetEnabledCategories — moduleDB exists: %s", tostring(db ~= nil))
    if not db or not db.features or not db.features[FEATURE_NAME] then
        logger:debug("[WTP] GetEnabledCategories — EARLY EXIT: db=%s, features=%s, featureEntry=%s",
            tostring(db ~= nil),
            tostring(db and db.features ~= nil),
            tostring(db and db.features and db.features[FEATURE_NAME] ~= nil))
        return {}
    end
    local featureDB = db.features[FEATURE_NAME]

    local enabled = {}
    local catGroup = featureDB["enabledCategories"]
    if not catGroup then
        catGroup = {}
        featureDB["enabledCategories"] = catGroup
    end
    logger:debug("[WTP] GetEnabledCategories — catGroup type: %s", type(catGroup))
    if catGroup then
        local enabledCount, disabledCount = 0, 0
        for k, v in pairs(catGroup) do
            if k ~= "_enabled" then
                enabled[k] = v
                if v then enabledCount = enabledCount + 1 else disabledCount = disabledCount + 1 end
            end
        end
        logger:debug("[WTP] GetEnabledCategories — enabled: %d, disabled: %d", enabledCount, disabledCount)
    else
        logger:debug("[WTP] GetEnabledCategories — catGroup is nil! Dumping featureDB keys:")
        for k, v in pairs(featureDB) do
            logger:debug("[WTP]   featureDB['%s'] = %s (%s)", tostring(k), tostring(v), type(v))
        end
    end
    return enabled
end

local function AddCategoryPins(catKey)
    local showOnFullMap = Core:GetSetting(MOD_ID, FEATURE_NAME, "showOnFullMap")
    if showOnFullMap == nil then showOnFullMap = true end -- Fallback to default
    
    -- Determine the HBD flag: 
    -- HBD_PINS_WORLDMAP_SHOW_WORLD (2) shows everywhere.
    -- 0 shows only on the specific mapID provided (the zone).
    local hbdFlag = showOnFullMap and HBD_PINS_WORLDMAP_SHOW_WORLD or 0
    
    local mmSize, wmSize = GetSettings()
    local icon = POI_ICONS[catKey]
    if not icon then
        logger:debug("[WTP] AddCategoryPins('%s') — NO ICON, skipping", catKey)
        return
    end
    

    -- Diagnostic: check FlattenedData state
    local mapCount = 0
    local sampleKeys
    for mapID, categories in pairs(FlattenedData) do
        mapCount = mapCount + 1
        if mapCount == 1 and not sampleKeys then
            sampleKeys = ""
            for k in pairs(categories) do
                sampleKeys = sampleKeys .. k .. ","
            end
        end
    end
    logger:debug("[WTP] AddCategoryPins('%s') — FlattenedData has %d maps, sampleKeys: %s", catKey, mapCount, tostring(sampleKeys))

    local pinCount = 0
    local mmPins = {}
    local wmPins = {}
    activePins.Minimap[catKey] = mmPins
    activePins.WorldMap[catKey] = wmPins

    for mapID, categories in pairs(FlattenedData) do
        local entries = categories[catKey]
        if entries then
            for _, entry in ipairs(entries) do
                -- Minimap pin
                local mmPin = AcquirePin()
                mmPin.texture:SetTexture(icon)
                mmPin:SetSize(mmSize, mmSize)
                mmPin.pinTitle = entry.name
                mmPin.pinDesc = entry.desc
                mmPin.pinFaction = entry.faction
                HBDPins:AddMinimapIconMap(FEATURE_NAME, mmPin, mapID, entry.x / 100, entry.y / 100, false, false)
                mmPins[#mmPins + 1] = mmPin

                -- Worldmap pin
                local wmPin = AcquirePin()
                wmPin.texture:SetTexture(icon)
                wmPin:SetSize(wmSize, wmSize)
                wmPin.pinTitle = entry.name
                wmPin.pinDesc = entry.desc
                wmPin.pinFaction = entry.faction
                HBDPins:AddWorldMapIconMap(FEATURE_NAME, wmPin, mapID, entry.x / 100, entry.y / 100, hbdFlag)
                wmPins[#wmPins + 1] = wmPin
                pinCount = pinCount + 1
            end
        end
    end
    logger:debug("[WTP] AddCategoryPins('%s') — placed %d pin pairs (mm+wm)", catKey, pinCount)
end

local function RemoveCategoryPins(catKey)
    local mmPins = activePins.Minimap[catKey]
    local wmPins = activePins.WorldMap[catKey]

    if mmPins then
        for i = 1, #mmPins do
            local mPin = mmPins[i]
            mPin:Hide()
            mPin:ClearAllPoints()
            HBDPins:RemoveMinimapIcon(FEATURE_NAME, mPin)
            mmPinPool[#mmPinPool + 1] = mPin
        end
        wipe(mmPins)
    end

    if wmPins then
        for i = 1, #wmPins do
            local wPin = wmPins[i]
            wPin:Hide()
            wPin:ClearAllPoints()
            HBDPins:RemoveWorldMapIcon(FEATURE_NAME, wPin)
            wmPinPool[#wmPinPool + 1] = wPin
        end
        wipe(wmPins)
    end
end

local function RefreshPins()
    logger:debug("[WTP] RefreshPins called")
    ReleaseAllPins()

    local enabled = GetEnabledCategories()
    local catCount = 0
    for catKey, isEnabled in pairs(enabled) do
        if isEnabled then
            catCount = catCount + 1
            AddCategoryPins(catKey)
        end
    end
    logger:debug("[WTP] RefreshPins done — %d categories processed", catCount)
end

-- ============================================================================
-- Initialization Helper
-- ============================================================================

local function EnsureInitialized()
    if not playerFaction then
        playerFaction = UnitFactionGroup("player")
        logger:debug("[WTP] UnitFactionGroup returned: %s", tostring(playerFaction))
        if playerFaction then
            playerFaction = playerFaction:sub(1, 1)
        else
            playerFaction = "A"
        end
        logger:debug("[WTP] Resolved faction: %s — calling FlattenPOI", playerFaction)
        FlattenPOI()
    end
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

local function OnPlayerEnteringWorld()
    logger:debug("[WTP] PLAYER_ENTERING_WORLD fired — playerFaction: %s", tostring(playerFaction))
    EnsureInitialized()
    RefreshPins()
end

-- ============================================================================
-- Setting Changed Handler
-- ============================================================================

local function OnSettingChanged(featureName, key, value)
    if featureName ~= FEATURE_NAME then return end

    if key == "minimapIconSize" or key == "worldmapIconSize" or key == "enabledCategories" or key == "showOnFullMap" then
        RefreshPins()
    end
end

-- ============================================================================
-- Minimap Tracking Button
-- ============================================================================

-- Labels for the dropdown menu (sorted alphabetically)
local CATEGORY_LABELS = {
    AUCTIONEER   = "Auctioneers",
    BANKER       = "Bankers",
    BATTLEMASTER = "Battlemasters",
    DUNGEON      = "Dungeons",
    FLIGHTMASTER = "Flight Masters",
    INNKEEPER    = "Innkeepers",
    MAILBOX      = "Mailboxes",
    RAID         = "Raids",
    REPAIR       = "Repair",
    SPIRITHEALER = "Spirit Healers",
    STABLEMASTER = "Stable Masters",
    TRAINER      = "Trainers",
    VENDOR       = "Vendors",
}

local TrackingBtn

local function CreateTrackingButton()
    if TrackingBtn then return end

    TrackingBtn = CreateFrame("Button", "WTPTrackingButton", Minimap)
    TrackingBtn:SetSize(32, 32)
    TrackingBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -5, -15)
    TrackingBtn:SetFrameLevel(Minimap:GetFrameLevel() + 5)

    local background = TrackingBtn:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetSize(25, 25)
    background:SetPoint("CENTER", 0, 0)

    local icon = TrackingBtn:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Minimap\\Tracking\\None")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)

    local border = TrackingBtn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", 0, 0)

    TrackingBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    TrackingBtn:SetScript("OnClick", function(self)
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
            rootDescription:CreateTitle("World Tracking Pins")

            local sortedKeys = {}
            for k in pairs(CATEGORY_LABELS) do
                sortedKeys[#sortedKeys + 1] = k
            end
            table.sort(sortedKeys, function(a, b) return CATEGORY_LABELS[a] < CATEGORY_LABELS[b] end)

            local enabled = GetEnabledCategories()

            for _, key in ipairs(sortedKeys) do
                rootDescription:CreateCheckbox(
                    CATEGORY_LABELS[key],
                    function() return enabled[key] end,
                    function()
                        local catGroup = Core:GetSetting(MOD_ID, FEATURE_NAME, "enabledCategories")
                        if not catGroup then
                            catGroup = {}
                            local featureDB = Core:GetModuleDB(MOD_ID).features[FEATURE_NAME]
                            featureDB["enabledCategories"] = catGroup
                        end
                        catGroup[key] = not catGroup[key]
                        enabled[key] = catGroup[key]
                        if catGroup[key] then
                            AddCategoryPins(key)
                        else
                            RemoveCategoryPins(key)
                        end
                    end
                )
            end
        end)
    end)

    TrackingBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("World Tracking Pins", 1, 1, 1)
        GameTooltip:AddLine("Click to toggle categories", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    TrackingBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

-- ============================================================================
-- Public API (via addon namespace)
-- ============================================================================

local function Activate()
    logger:debug("[WTP] Activate called (feature toggled ON)")
    EnsureInitialized()
    CreateTrackingButton()
    if TrackingBtn then TrackingBtn:Show() end
    RefreshPins()
end

local function Deactivate()
    logger:debug("[WTP] Deactivate called (feature toggled OFF)")
    ReleaseAllPins()
    if TrackingBtn then TrackingBtn:Hide() end
end

ns.WorldTrackingPins = {
    OnSettingChanged = OnSettingChanged,
    RefreshPins = RefreshPins,
    Activate = Activate,
    Deactivate = Deactivate,

    feature = {
        name = "World Tracking Pins",
        uiGroup = "Pins",
        priority = 20,
        needsReload = false,
        defaultEnabled = true,
        events = {
            PLAYER_ENTERING_WORLD = OnPlayerEnteringWorld,
        },
        uiElements = {
            {
                type = "Slider",
                label = "Minimap Icon Size",
                key = "minimapIconSize",
                min = 6,
                max = 32,
                step = 1,
                default = 12,
            },
            {
                type = "Slider",
                label = "World Map Icon Size",
                key = "worldmapIconSize",
                min = 8,
                max = 40,
                step = 1,
                default = 16,
            },
            {
                type = "Checkbox",
                label = "Show Pins on Full Map",
                key = "showOnFullMap",
                default = true,
            },
        },
    },
}