--[[
    <PrephsFramework_QoL/Entry.lua>
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
local Core = LibStub("PrephsFramework_Core-0.0.1")
if not Core then
    print("|cffFF0000PrephsFrameworkError:|r Core framework not found")
    return
end

local MOD_ID = "Quality_Of_Life"
local ME = ns.MailEnhancer
local AS = ns.AutoSell

local GetTime = GetTime
local GetCVarBool = GetCVarBool
local IsModifiedClick = IsModifiedClick
local GetNumLootItems = GetNumLootItems
local LootSlot = LootSlot
local SendChatMessage = C_ChatInfo.SendChatMessage
local string = string
local logger = Core.Logger
local States = Core.States

-- NPC tables for intelligent gossip skipping
local npcTable = {
    -- Stable masters
    10060, 10063, 9984, 11119, 9985, 11104, 10062, 10085, 9978, 10051, 9988, 10054, 9989, 9981, 10056, 13616, 14741, 10045, 10052, 10047, 10055, 9986, 15722, 6749, 10061, 15131, 9979, 13617, 11105, 10053, 9983, 9982, 10050, 9980, 11117, 10046, 10059, 16094, 10058, 9987, 10048, 9977, 10057, 10049, 11069, 9976,
    -- Banker
    8356, 2456, 4549, 7799, 4209, 4155, 8123, 3318, 3309, 2455, 2625, 2457, 3320, 2461, 2460, 4208, 8124, 5099, 8119, 8357, 3496, 2459, 4550, 2996, 13917, 2458, 5060,
    -- Flightmaster
    10583, 352, 8019, 3838, 10897, 3615, 3310, 2299, 12578, 4312, 4267, 1571, 1572, 12616, 16227, 2409, 3841, 2432, 2861, 12740, 12636, 4321, 11900, 1573, 2859, 11138, 11901, 6706, 6726, 8610, 11899, 1387, 931, 12596, 3305, 8609, 2858, 8018, 4407, 15177, 12577, 2995, 523, 4319, 7823, 10378, 2851, 2835, 2226, 4317, 7824, 12617, 2941, 4551, 13177, 11139, 6026, 8020, 2389, 4314, 15178,
    -- Trainer (partial list)
    11073, 11865, 2836, 7948, 5482, 11867, 11052, 11097, 8736, 5159, 11072, 4160, 11869, 11870, 7406, 1386, 8126, 2327, 3399, 11098, 1346, 5513, 11868, 11557, 2704, 6287, 4165, 4732, 5567, 11866, 5174, 2399,
    -- Vendor (partial list)
    2805, 13476, 3955, 12919, 844, 2664, 2685, 8125, 8137, 1312, 8139, 3323, 66, 12944, 12022, 1448, 1257, 2626, 12033, 7947, 11189, 2480, 340, 14921, 10667, 4561, 1243, 4229, 4169, 15734, 16376, 15443,
    -- Gossip NPCs
    243757, -- Scarlet Enclave Portal Opener https://www.wowhead.com/classic/npc=243757/angela-dosantos
    16434, -- Argent Dawn Champion for Mark https://www.wowhead.com/classic/npc=16434/argent-dawn-champion
    15443, -- Field Duty NPC https://www.wowhead.com/classic/npc=15443/janela-stouthammer

}

local raidUtilitySpells = {
    [1225906] = "Specklefin Feast",
    [1225907] = "Lobster Banquet",
    [473466] = "Firewater Cauldron",
    [1213955] = "G00 DV-1B3 Generator",
    [22700] = "Field Repair Bot 74A",
    [429961] = "Sleeping Bag",
}
if Core.DEV.testing then
    raidUtilitySpells[22783] = "Test Spell"
end

local raidUtilityIds = {}
for id, _ in pairs(raidUtilitySpells) do
    table.insert(raidUtilityIds, id)
end
local SPELL_ID_SUMMON = 23598

local tDelay = 0

local function FastLoot()
    if GetTime() - tDelay >= 0.3 then
        tDelay = GetTime()
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            for i = GetNumLootItems(), 1, -1 do LootSlot(i) end
            tDelay = GetTime()
        end
    end
end

local function SkipGossip()
    -- Check if bypass key is pressed
    if Core:IsBackupKeyPressed() then
        return
    end
    
    -- Intelligent gossip skipping
    local npcGuid = UnitGUID("npc")
    local skipAutomatically = false
    
    if npcGuid then
        local _, _, _, _, _, npcID = strsplit("-", npcGuid)
        if npcID then
            -- Check if this NPC is in our auto-skip table (stable master, banker, trainer, vendor, flightmaster)
            for _, id in ipairs(npcTable) do
                if tonumber(npcID) == id then
                    skipAutomatically = true
                    break
                end
            end
        end
    end
    
    -- Process gossip
    local gossipInfoTable = C_GossipInfo.GetOptions()
    if gossipInfoTable and gossipInfoTable[1] and gossipInfoTable[1].gossipOptionID then
        -- Check for vendor/banker options even if quests are available
        for _, option in ipairs(gossipInfoTable) do
            if option.name then
                local nameLower = option.name:lower()
                
                -- Check for specific text patterns to auto-skip
                if option.name:find("token of my love", 1, true) then
                    C_GossipInfo.SelectOption(option.gossipOptionID)
                    return
                end
                
                -- Check for vendor phrases
                if nameLower:find("buy") or nameLower:find("browse") or nameLower:find("vendor") or 
                   nameLower:find("trade") or nameLower:find("goods") or nameLower:find("wares") or
                   nameLower:find("bank") or nameLower:find("access") then
                    if skipAutomatically then
                        C_GossipInfo.SelectOption(option.gossipOptionID)
                        return
                    end
                end
            end
        end
        
        -- Original logic: single option with no quests
        if #gossipInfoTable == 1 and C_GossipInfo.GetNumAvailableQuests() == 0 and C_GossipInfo.GetNumActiveQuests() == 0 then
            -- Only skip if it's an auto-skip NPC or if it's a taxi option
            if skipAutomatically then
                C_GossipInfo.SelectOption(gossipInfoTable[1].gossipOptionID)
                return
            end
            
            -- Also skip flight options specifically
            local option = gossipInfoTable[1]
            if (option.icon == 132060) or (option.name and (option.name:lower():find("ride") or option.name:lower():find("fly") or option.name:lower():find("taxi"))) then
                C_GossipInfo.SelectOption(gossipInfoTable[1].gossipOptionID)
            end
        end
    end
end

local function OnGossipShow()
    if QuestFrameProgressPanel:IsVisible() == false and QuestFrameRewardPanel:IsVisible() == false then
        SkipGossip()
    end
end

local function AnnounceSummons(event, unit)
    if unit ~= "player" then return end

    local inRaid = States.inRaid
    local inGroup = States.inGroup
    if not (inRaid or inGroup) then return end

    local targetName = UnitName("target")
    local groupIndex = inRaid and 0 or 1
    local chatType = inRaid and "RAID" or "PARTY"

    if inRaid then
        local raidIndex = UnitInRaid("target")
        groupIndex = raidIndex and select(3, GetRaidRosterInfo(raidIndex)) or 0
    end

    local locationText = (States.subZoneName ~= "" and States.subZoneName ~= States.zoneName) 
                     and (States.subZoneName .. ", " .. States.zoneName) 
                     or States.zoneName
    local groupText = groupIndex > 0 and (" [Group " .. groupIndex .. "]") or ""

    C_ChatInfo.SendChatMessage(string.format("Summoning %s%s to %s!", targetName, groupText, locationText), chatType)
end

local function AnnounceRaidUtility(...)
    local _, _, _, _, sourceName, _, _,
          _, _, _, _,
          spellID, _, _ = ...

    if not States.inGroup then return end

    SendChatMessage(
        string.format("%s dropped a %s!", sourceName, raidUtilitySpells[spellID]), 
        States.inRaid and "RAID" or "PARTY"
    )
end

local function DisableLootWarningsFrame()
    local frame = CreateFrame("FRAME")
    frame:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
        -- Disable warnings for attempting to roll Need on loot
        if event == "CONFIRM_LOOT_ROLL" then
            ConfirmLootRoll(arg1, arg2)
            StaticPopup_Hide("CONFIRM_LOOT_ROLL")
            return
        end

        -- Disable warning for attempting to loot a Bind on Pickup item
        if event == "LOOT_BIND_CONFIRM" then
            ConfirmLootSlot(arg1)
            StaticPopup_Hide("LOOT_BIND", arg1)
            -- Re-attempt remaining loot items on next frame if FastLoot is enabled
            if Core:ShouldFeatureBeActive("Quality_Of_Life", "FastLoot") and GetNumLootItems() > 0 then
                tDelay = 0
                C_Timer.After(0, FastLoot)
            end
            return
        end

        -- Disable warning for attempting to vendor an item within its refund window
        if event == "MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL" then
            SellCursorItem()
            return
        end

        -- Disable warning for attempting to mail an item within its refund window
        if event == "MAIL_LOCK_SEND_ITEMS" then
            RespondMailLockSendItem(arg1, true)
            return
        end
    end)
    return frame
end

local lootWarningsFrame = DisableLootWarningsFrame()

-- Single handler for all loot warning events
local function HandleLootWarningEvent(event, ...)
    lootWarningsFrame:GetScript("OnEvent")(lootWarningsFrame, event, ...)
end

-- Makes the URL text "Clickable" in the chat frame
local function URLChatFilter(self, event, msg, ...)
    if not msg:find("://", 1, true) then
        return false, msg, ...
    end
    -- Split concatenated URLs (e.g. "https://a.comhttps://b.com") by inserting
    -- a space before any protocol that directly follows a non-space character.
    msg = msg:gsub("(%S)(https?://)", "%1 %2")
    msg = msg:gsub("(%a+://[^ |\"<>]*[%w/=])", function(url)
        return "|cffffffff|Hurl:" .. url .. "|h[" .. url .. "]|h|r"
    end)
    return false, msg, ...
end
-- Handles the click event on the custom "url:" hyperlink
local function HookHyperlinkClick(self, link, text, button)
    if link:sub(1, 4) == "url:" then
        local url = link:sub(5)
        
        -- Open the default chat input box
        local editBox = ChatEdit_ChooseBoxForSend()
        ChatEdit_ActivateChat(editBox)
        
        -- Insert the URL and mark it for copying
        editBox:SetText(url)
        editBox:HighlightText()
        
        return true -- Tells the game we handled this link
    end
end
local LINKS_MOD_ID = "Quality_Of_Life_ClickableLinks"
local chatFilterChannels = {
    "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER",
    "CHAT_MSG_BN_WHISPER", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY", "CHAT_MSG_RAID", "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_COMMUNITIES_CHANNEL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_BN_WHISPER_INFORM"
}

local function EnableClickableLinks()
    for _, event in ipairs(chatFilterChannels) do
        ChatFrame_AddMessageEventFilter(event, URLChatFilter)
    end
    Core:RegisterFlexibleHook(LINKS_MOD_ID, "HyperlinkClick", {
        type = "function",
        func = "ChatFrame_OnHyperlinkShow",
        callback = HookHyperlinkClick,
    })
end

local function DisableClickableLinks()
    for _, event in ipairs(chatFilterChannels) do
        ChatFrame_RemoveMessageEventFilter(event, URLChatFilter)
    end
    Core:UnregisterFlexibleHook(LINKS_MOD_ID, "HyperlinkClick")
end

local function AutoRepair()
    if CanMerchantRepair() then
        local repairCost, canRepair = GetRepairAllCost()
        if not canRepair then
            logger:info("No items need repairing.")
        end
        if canRepair and repairCost > 0 then
            if GetMoney() >= repairCost then
                RepairAllItems()
                -- Optional: Print cost to chat. Remove the line below if you want it silent.
                logger:info("Items repaired for: %s", C_CurrencyInfo.GetCoinTextureString(repairCost))
            else
                logger:info("Not enough gold to auto-repair!")
            end
        end
    end
end

local function ApplyCameraDistance()
    local moduleDB = Core:GetModuleDB(MOD_ID)
    local value = moduleDB and moduleDB.features
        and moduleDB.features["CameraDistance"]
        and moduleDB.features["CameraDistance"].cameraDistanceMax
        or 3.4
    SetCVar("cameraDistanceMaxZoomFactor", value)
end

-- ============================================================================
-- Module Registration
-- ============================================================================

local QOLUIGroups = {
    GENERAL = "General QOL",
    LOOT    = "Loot Features",
    GROUP   = "Group Announcements",
}
local CE = ns.CraftingEnhancer
---@type ModuleData
local QoLModule = {
    features = {
        FastLoot = {
            name = "Faster Looting",
            uiGroup = QOLUIGroups.LOOT,
            priority = 10,
            needsReload = false,
            defaultEnabled = true,
            events = {
                LOOT_READY = FastLoot,
                LOOT_BIND_CONFIRM = DisableLootWarningsFrame,
            }
        },
        SkipGossips = {
            name = "Skip Gossips",
            priority = 5,
            needsReload = false,
            defaultEnabled = false,
            uiGroup = QOLUIGroups.GENERAL,
            suppressionFlags = {
                inRaid = false,
                inGroup = false,
                inInstance = false,
                inZones = {}
            },
            events = {
                GOSSIP_SHOW = OnGossipShow
            }
        },
        AutoRepair = {
            name = "Auto Repair",
            uiGroup = QOLUIGroups.GENERAL,
            priority = 15,
            needsReload = false,
            defaultEnabled = true,
            events = {
                MERCHANT_SHOW = AutoRepair
            }
        },
        AnnounceSummons = {
            name = "Announce Summons",
            uiGroup = QOLUIGroups.GROUP,
            priority = 8,
            needsReload = false,
            defaultEnabled = true,
            suppressionFlags = {
                inRaid = false,
                inGroup = false,
                inInstance = false,
            },
            events = {
                UNIT_SPELLCAST_CHANNEL_START = {
                    callback = AnnounceSummons,
                    filters = {
                        spellID = SPELL_ID_SUMMON,
                    },
                },
            },
        },
        AnnounceFeastCauldron = {
            name = "Announce Feasts & Cauldrons",
            uiGroup = QOLUIGroups.GROUP,
            priority = 9,
            needsReload = false,
            defaultEnabled = false,
            suppressionFlags = {
                inRaid = false,
                inGroup = false,
                inInstance = false,
                inZones = {},
            },
            -- TODO important to add annotates to events
            events = {
                SPELL_CAST_SUCCESS = {
                    filters = {
                        spellId = raidUtilityIds,
                        sourceIsGroupMember = true,
                        inCombat = false,  -- Only announce when not in combat
                    },
                    callback = AnnounceRaidUtility,
                }
            }
        },
        ClickableLinks = {
            name = "Clickable Chat Links",
            uiGroup = QOLUIGroups.GENERAL,
            priority = 20,
            needsReload = false,
            defaultEnabled = false
        },
        DisableLootWarnings = {
            name = "Disable Loot Warnings",
            uiGroup = QOLUIGroups.LOOT,
            priority = 7,
            needsReload = false,
            suppressionFlags = {
                inRaid = false,
                inGroup = false,
                inInstance = false,
            },
            events = {
                CONFIRM_LOOT_ROLL = HandleLootWarningEvent,
                LOOT_BIND_CONFIRM = HandleLootWarningEvent,
                MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL = HandleLootWarningEvent,
                MAIL_LOCK_SEND_ITEMS = HandleLootWarningEvent
            }
        },
        CameraDistance = {
            name = "Camera Distance",
            uiGroup = QOLUIGroups.GENERAL,
            priority = 25,
            defaultEnabled = true,
            uiElements = {
                {
                    type = "Slider",
                    label = "Max Camera Distance",
                    key = "cameraDistanceMax",
                    default = 3.4,
                    min = 1.0,
                    max = 4.0,
                    step = 0.1,
                    description = "Sets the maximum camera zoom-out distance factor.",
                    onUpdate = function(value)
                        SetCVar("cameraDistanceMaxZoomFactor", value)
                    end,
                },
            },
        },
        EnhancedOpenAll = ME.feature,
        AutoSell = AS.feature,
        CraftingEnhancer = ns.CraftingEnhancer.feature,
    },

    
    -- Module Callbacks
    OnInitialize = function()
        logger:init("Quality of Life module initialized")
        if Core:ShouldFeatureBeActive("Quality_Of_Life", "ClickableLinks") then
            EnableClickableLinks()
        else
            DisableClickableLinks()
        end
        if Core:ShouldFeatureBeActive("Quality_Of_Life", "CameraDistance") then
            ApplyCameraDistance()
        end
    end,
    
    OnFeatureStateChanged = function(featureName, enabled)
        logger:features("Feature '%s' %s", featureName, enabled and "enabled" or "disabled")

        if featureName == "ClickableLinks" then
            if enabled then
                EnableClickableLinks()
            else
                DisableClickableLinks()
            end
        elseif featureName == "CameraDistance" then
            if enabled then
                ApplyCameraDistance()
            else
                SetCVar("cameraDistanceMaxZoomFactor", 1.0)
            end
        elseif featureName == "EnhancedOpenAll" then
            if enabled then
                ME.Activate()
            else
                ME.Deactivate()
            end
        elseif featureName == "CraftingEnhancer" then
            if enabled then
                ns.CraftingEnhancer.Activate()
            else
                ns.CraftingEnhancer.Deactivate()
            end
        end
    end,
    
}

-- Register the module (use underscores to match converted ModuleID from .toc)
local success = Core:RegisterModule(MOD_ID, QoLModule)
if not success then
    logger:error("Failed to register module")
end
