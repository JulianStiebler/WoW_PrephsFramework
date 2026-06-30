--[[
    <PrephsFramework_Quests/Entry.lua>
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

-- Get Core reference
---@type PrephsFramework
local Core = LibStub("PrephsFramework_Core-0.0.1")
if not Core then
    print("|cffFF0000PrephsFrameworkError:|r Core framework not found")
    return
end

local logger = Core.Logger

-- ============================================================================
-- Quest Data (populated by data_quests.lua via addon namespace)
-- ============================================================================

local PredefinedAutoTurnins = ns.data.PredefinedAutoTurnins
---@class PrephsFramework.data.questData
local questDataTable        = Core.data.questData

-- Constants
local MODULE_ID    = "Quests"
local AUTOQ_FEATURE_NAME = "AutoQuest"



-- Localize WoW APIs
local GetOptions           = C_GossipInfo.GetOptions
local GetAvailableQuests   = C_GossipInfo.GetAvailableQuests
local GetActiveQuests      = C_GossipInfo.GetActiveQuests
local GetQuestID           = GetQuestID
local AcceptQuest          = AcceptQuest
local IsQuestCompletable   = IsQuestCompletable
local CompleteQuest        = CompleteQuest
local GetNumQuestChoices   = GetNumQuestChoices
local GetQuestReward       = GetQuestReward
local SelectActiveQuest    = C_GossipInfo.SelectActiveQuest
local SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest
local SelectOption         = C_GossipInfo.SelectOption
                

-- Localize Lua APIs
local ipairs               = ipairs
local tonumber             = tonumber
local tinsert              = table.insert
local type                 = type

-- Localize PrephsFramework APIs
local logger               = Core.Logger

-- ============================================================================
-- Helpers
-- ============================================================================

local function GetSetting(feature, key)
    return Core:GetSetting(MODULE_ID, feature, key)
end

local function NPCHasVendor()
    local options = GetOptions()
    for _, option in ipairs(options) do
        if option.type == "Vendor" then
            return true
        end
    end
    return false
end

-- ============================================================================
-- Collect all enabled quest IDs from the various settings
-- ============================================================================

local function GetEnabledQuestIDs()
    local enabledQuests = {}

    -- 1. Custom quest list  (EditableList stores { {id=..., displayText=...}, ... })
    local questList = GetSetting(AUTOQ_FEATURE_NAME, "CustomQuestIDs") or {}
    for _, entry in ipairs(questList) do
        local qid = type(entry) == "table" and tonumber(entry.id) or tonumber(entry)
        if qid and not questDataTable:QuestIDInTable(qid, enabledQuests) then
            tinsert(enabledQuests, qid)
        end
    end

    -- 2. Predefined groups (driven by PredefinedAutoTurnins data)
    for _, group in ipairs(PredefinedAutoTurnins) do
        local states = GetSetting(AUTOQ_FEATURE_NAME, group.key) or {}
        if states._enabled then
            for _, child in ipairs(group.children) do
                if states[child.key] then
                    for _, qid in ipairs(child.quests) do
                        if not questDataTable:QuestIDInTable(qid, enabledQuests) then
                            tinsert(enabledQuests, qid)
                        end
                    end
                end
            end
        end
    end

    return enabledQuests
end

-- ============================================================================
-- Feature Implementations
-- ============================================================================

-- Handles QUEST_DETAIL, QUEST_PROGRESS, QUEST_COMPLETE
local function AutoQuestOnDialog(event)
    if Core:IsBackupKeyPressed() then return end
    if GetSetting(AUTOQ_FEATURE_NAME, "VendorSafeguard") and NPCHasVendor() then return end

    local qID = GetQuestID()
    local enabledQuests = GetEnabledQuestIDs()
    local qName = questDataTable.entries[qID] or "Unknown Quest"

    if questDataTable:QuestIDInTable(qID, enabledQuests) then
        if event == "QUEST_DETAIL" then
            AcceptQuest()
        elseif event == "QUEST_PROGRESS" then
            if IsQuestCompletable() then
                CompleteQuest()
            end
            logger:info("AutoQuest: Progressed quest '%s' (ID: %d)", qName, qID)
        elseif event == "QUEST_COMPLETE" then
            if GetNumQuestChoices() <= 1 then
                GetQuestReward(1)
            end
            logger:info("AutoQuest: Turned in quest '%s' (ID: %d)", qName, qID)
        end
    end
end

-- Handles GOSSIP_SHOW
local function AutoQuestGossip()
    if Core:IsBackupKeyPressed() then return end
    if GetSetting(AUTOQ_FEATURE_NAME, "VendorSafeguard") and NPCHasVendor() then return end

    local enabledQuests = GetEnabledQuestIDs()
    if #enabledQuests == 0 then return end

    local options         = GetOptions()
    local availableQuests = GetAvailableQuests()
    local activeQuests    = GetActiveQuests()


    -- Turn in active (complete) quests first
    if activeQuests then
        for _, questInfo in ipairs(activeQuests) do
            if questInfo.questID and questDataTable:QuestIDInTable(questInfo.questID, enabledQuests) and questInfo.isComplete then
                SelectActiveQuest(questInfo.questID)
                return
            end
        end
    end

    -- Accept available quests
    if availableQuests then
        for _, questInfo in ipairs(availableQuests) do
            if questInfo.questID and questDataTable:QuestIDInTable(questInfo.questID, enabledQuests) then
                SelectAvailableQuest(questInfo.questID)
                return
            end
        end
    end

    -- Fallback: try gossip options by questID
    if options then
        for _, option in ipairs(options) do
            if option.questID and questDataTable:QuestIDInTable(option.questID, enabledQuests) then
                SelectOption(option.gossipOptionID)
                return
            end
        end
    end
end

-- ============================================================================
-- UI: resolve a typed quest ID to (id, displayName)
-- ============================================================================

local function ResolveQuestID(input)
    local questID = tonumber(input)
    if not questID then return nil, nil end
    local name = questDataTable.entries[questID]
    if name then
        return questID, name
    end
    return questID, "Quest #" .. questID
end

-- ============================================================================
-- Dynamic UI: build CheckboxGroups from PredefinedAutoTurnins
-- ============================================================================

local uiElements = {
    { type = "Checkbox", key = "VendorSafeguard", label = "If Vendor is present, avoid Auto Turn-In", default = true },
    { type = "Checkbox", key = "DebugMode", label = "Debug Mode (print gossip info)", default = false },
    {
        type = "EditableList",
        label = "Custom Quest IDs",
        key = "CustomQuestIDs",
        resolveFunc = ResolveQuestID,
        inputHint = "Enter Quest ID...",
    },
}

for _, group in ipairs(PredefinedAutoTurnins) do
    local children = {}
    for _, child in ipairs(group.children) do
        children[#children + 1] = { label = child.label, key = child.key }
    end
    uiElements[#uiElements + 1] = {
        type = "CheckboxGroup",
        label = group.label,
        key = group.key,
        collapsible = group.collapsible,
        showSeparator = group.showSeparator,
        children = children,
    }
end

-- ============================================================================
-- Module Registration
-- ============================================================================

---@type ModuleData
local AutoQuestModule = {
    features = {
        AutoQuest = {
            name = "Auto Quest Turn-In",
            priority = 100,
            defaultEnabled = false,
            suppressionFlags = {
                inInstance = true,
                inZones = {},
            },
            events = {
                QUEST_DETAIL   = AutoQuestOnDialog,
                QUEST_PROGRESS = AutoQuestOnDialog,
                QUEST_COMPLETE = AutoQuestOnDialog,
                GOSSIP_SHOW    = AutoQuestGossip,
            },
            uiElements = uiElements,
        },
    },

    OnInitialize = function()
        logger:init("Auto Quest module initialized")
    end,

    OnFeatureStateChanged = function(featureName, enabled)
        logger:features("Feature '%s' %s", featureName, enabled and "enabled" or "disabled")
    end,
}

local success = Core:RegisterModule(MODULE_ID, AutoQuestModule)
if not success then
    logger:error("Failed to register Auto Quest module")
end
