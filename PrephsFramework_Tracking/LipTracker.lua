--[[
    <PrephsFramework_Tracking/lip.lua>
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
local Core = ns.PF

local SKIP_INSTANCE_CHECK = Core.DEV.testing
local logger = Core.Logger
local States = Core.States

-- Localize frequently used globals
local GetInstanceInfo = GetInstanceInfo
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetUnitName = GetUnitName
local UnitClass = UnitClass
local SendChatMessage = SendChatMessage
local pairs = pairs
local ipairs = ipairs
local table = table
local math = math
local time = time
local date = date
local CreateFrame = CreateFrame
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- ============================================================================
-- LIP Tracker Constants
-- ============================================================================
local LIP_SPELL_ID = 3169
local MAX_HISTORY = 3
local ROW_HEIGHT = 18
local ROW_PADDING = 2

-- Final boss encounter IDs that trigger auto-report
local FINAL_BOSS_IDS = {
    [3189] = true, [1114] = true, [723] = true,
    [717] = true, [617] = true, [672] = true,
}

-- ============================================================================
-- Runtime State
-- ============================================================================
local db                    -- PrephsFramework_TrackingDB reference, set via InitLipDB
local currentRunData = nil  ---@type table|nil
local currentInstanceName = nil ---@type string|nil
local leaderboardRows = {}  -- Reusable row frames for the UI
local leaderboardFrame = nil ---@type CustomFrame|nil
local sessionLabel = nil    ---@type FontString|nil

-- ============================================================================
-- Run / Instance Management
-- ============================================================================

local function GetOrCreateRunData()
    local name, instanceType = GetInstanceInfo()
    if not SKIP_INSTANCE_CHECK then
        if instanceType == "none" or instanceType == "pvp" then
            currentInstanceName, currentRunData = nil, nil
            return
        end
    end

    if not db then return end

    -- Try to find a locked saved-instance ID for this instance name
    local savedID = nil
    for i = 1, GetNumSavedInstances() do
        local n, id, _, _, locked = GetSavedInstanceInfo(i)
        if n == name and locked then savedID = id; break end
    end

    local sessionKey = "Sess-" .. (UnitName("player") or "Unknown") .. "-" .. date("%m%d")
    local resolvedID = savedID or sessionKey
    currentInstanceName = name

    db.lipTracker = db.lipTracker or {}
    db.lipTracker[name] = db.lipTracker[name] or {}

    local runs = db.lipTracker[name]

    -- If we now have a real saved ID, migrate any orphaned session-keyed runs
    if savedID then
        for idx = #runs, 1, -1 do
            local e = runs[idx]
            if type(e.id) == "string" and e.id:sub(1, 5) == "Sess-" then
                local existing = nil
                for _, r in ipairs(runs) do
                    if r.id == savedID then existing = r; break end
                end

                if existing then
                    logger:info("Merging session '%s' into saved-ID run '%s'", e.id, savedID)
                    for pName, pData in pairs(e.usages) do
                        if not existing.usages[pName] then
                            existing.usages[pName] = pData
                        else
                            existing.usages[pName].count = existing.usages[pName].count + pData.count
                        end
                    end
                    table.remove(runs, idx)
                else
                    logger:info("Promoting session '%s' to saved instance ID '%s'", e.id, savedID)
                    e.id = savedID
                end
            end
        end
    end

    -- Find existing run or create new
    local run = nil
    for _, e in ipairs(runs) do
        if e.id == resolvedID then run = e; break end
    end

    if not run then
        run = { id = resolvedID, usages = {}, timestamp = time() }
        table.insert(runs, run)
        -- Trim oldest runs beyond MAX_HISTORY
        while #runs > MAX_HISTORY do
            table.remove(runs, 1)
        end
    end

    currentRunData = run
end

-- ============================================================================
-- Sorted Leaderboard Data
-- ============================================================================

local function GetSortedLeaderboard()
    local sorted = {}
    if not currentRunData then return sorted end
    for name, data in pairs(currentRunData.usages) do
        table.insert(sorted, { name = name, count = data.count, class = data.class })
    end
    table.sort(sorted, function(a, b) return a.count > b.count end)
    return sorted
end

-- ============================================================================
-- Leaderboard UI
-- ============================================================================

local function GetOrCreateRow(parent, index)
    if leaderboardRows[index] then return leaderboardRows[index] end

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint("LEFT", 0, 0)
    row:SetPoint("RIGHT", 0, 0)

    row.rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.rank:SetPoint("LEFT", 5, 0)
    row.rank:SetWidth(25)
    row.rank:SetJustifyH("LEFT")

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.name:SetPoint("LEFT", row.rank, "RIGHT", 5, 0)
    row.name:SetWidth(180)
    row.name:SetJustifyH("LEFT")

    row.count = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    row.count:SetPoint("RIGHT", -10, 0)
    row.count:SetWidth(40)
    row.count:SetJustifyH("RIGHT")

    leaderboardRows[index] = row
    return row
end

local function UpdateLeaderboardUI()
    if not leaderboardFrame then return end

    -- Update session ID label
    if sessionLabel then
        local id = currentRunData and currentRunData.id or "No active session"
        sessionLabel:SetText("Session: " .. id)
    end

    local scrollChild = leaderboardFrame.ScrollChild
    local sorted = GetSortedLeaderboard()
    local headerOffset = leaderboardFrame._headerHeight or 0

    for i, entry in ipairs(sorted) do
        local row = GetOrCreateRow(scrollChild, i)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(headerOffset + (i - 1) * (ROW_HEIGHT + ROW_PADDING)))
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)

        row.rank:SetText(i .. ".")

        -- Class-color the player name
        local classColor = RAID_CLASS_COLORS[entry.class]
        if classColor then
            row.name:SetText(classColor:WrapTextInColorCode(entry.name))
        else
            row.name:SetText(entry.name)
        end

        row.count:SetText(tostring(entry.count))
        row:Show()
    end

    -- Hide unused rows
    for i = #sorted + 1, #leaderboardRows do
        leaderboardRows[i]:Hide()
    end

    -- Update scroll child height
    local totalH = headerOffset + #sorted * (ROW_HEIGHT + ROW_PADDING) + 10
    scrollChild:SetHeight(math.max(totalH, 1))
end

-- ============================================================================
-- Chat Report
-- ============================================================================

local function ReportToRaid()
    if not currentRunData then return end
    local sorted = GetSortedLeaderboard()
    local chat = States.inRaid and "RAID" or "PARTY"

    if #sorted == 0 then
        return
    end

    SendChatMessage("--- LIP Leaderboard: " .. (currentInstanceName or "Unknown") .. " ---", chat)
    for i = 1, math.min(10, #sorted) do
        SendChatMessage(i .. ". " .. sorted[i].name .. " used " .. sorted[i].count .. " LIPs", chat)
    end
end

-- ============================================================================
-- Event Handlers
-- ============================================================================

local function TrackLiPs(_, unit, castGUID, spellID)
    if not currentRunData then return end
    logger:trace("Tracking LIP usage: unit=%s, spellID=%d, castGUID=%s", tostring(unit), spellID, tostring(castGUID))
    local name = GetUnitName(unit, true)
    local _, class = UnitClass(unit)
    if not name then return end

    currentRunData.usages[name] = currentRunData.usages[name] or { count = 0, class = class }
    currentRunData.usages[name].count = currentRunData.usages[name].count + 1

    UpdateLeaderboardUI()
end

local MOD_ID = "Tracking"

local function OnEncounterEnd(_, id, _, _, _, success)
    if FINAL_BOSS_IDS[id] and success == 1 then
        local moduleDB = Core:GetModuleDB(MOD_ID)
        local autoReport = moduleDB and moduleDB.features
            and moduleDB.features["LipTracker"]
            and moduleDB.features["LipTracker"].autoReport
        if autoReport then
            C_Timer.After(5, ReportToRaid)
        end
    end
end

local function OnZoneChanged()
    GetOrCreateRunData()
    UpdateLeaderboardUI()
end

-- ============================================================================
-- Public API (via addon namespace)
-- ============================================================================

ns.LipTracker = {
    LIP_SPELL_ID = LIP_SPELL_ID,

    -- Called from Entry.lua OnInitialize to bind the saved variable
    InitDB = function(savedDB)
        db = savedDB
        GetOrCreateRunData()
    end,

    -- Feature definition consumed by Entry.lua
    feature = {
        name = "LIP Tracker",
        uiGroup = "LIP Tracker",
        priority = 10,
        needsReload = false,
        defaultEnabled = true,
        suppressionFlags = {
            inRaid = false,
            inGroup = false,
            inInstance = false,
        },
        uiElements = {
            {
                type = "Checkbox",
                label = "Auto-report on final boss kill",
                key = "autoReport",
                description = "Automatically post the LIP leaderboard to raid/party chat after the last boss is defeated.",
            },
        },
        events = {
            UNIT_SPELLCAST_SUCCEEDED = {
                callback = TrackLiPs,
                filters = {
                    unique  = true,
                    spellID = LIP_SPELL_ID,
                },
            },
            ENCOUNTER_END = OnEncounterEnd,
            ZONE_CHANGED_NEW_AREA = OnZoneChanged,
            PLAYER_ENTERING_WORLD = OnZoneChanged,
            UPDATE_INSTANCE_INFO = OnZoneChanged,
        },
    },

    -- Frame definition consumed by Entry.lua
    frame = {
        slashListEntry = "lips",
        title = "LIP Leaderboard",
        size = { w = 300, h = 350, resizable = true },
        noEsc = true,
        alpha = 0.8,
        AfterInitialize = function(frame)
            leaderboardFrame = frame
            local scrollChild = frame.ScrollChild

            -- Shrink scroll area to make room for button bar at the bottom
            frame.content:SetPoint("BOTTOMRIGHT", -8, 38)

            -- Session ID label above leaderboard header
            local sessLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            sessLabel:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, 0)
            sessLabel:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
            sessLabel:SetJustifyH("LEFT")
            sessLabel:SetTextColor(0.6, 0.6, 0.6)
            sessionLabel = sessLabel
            local SESSION_LABEL_HEIGHT = 16

            -- Header row
            local header = CreateFrame("Frame", nil, scrollChild)
            header:SetHeight(ROW_HEIGHT + 4)
            header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -SESSION_LABEL_HEIGHT)
            header:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)

            local hRank = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            hRank:SetPoint("LEFT", 5, 0)
            hRank:SetText("#")

            local hName = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            hName:SetPoint("LEFT", hRank, "RIGHT", 5, 0)
            hName:SetText("Player")

            local hCount = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            hCount:SetPoint("RIGHT", -10, 0)
            hCount:SetText("LIPs")

            -- Separator line below header
            local sep = header:CreateTexture(nil, "ARTWORK")
            sep:SetHeight(1)
            sep:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
            sep:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
            sep:SetColorTexture(0.4, 0.4, 0.4, 0.8)

            frame._headerHeight = SESSION_LABEL_HEIGHT + ROW_HEIGHT + 6

            -- Button bar at the bottom of the frame
            local btnBar = CreateFrame("Frame", nil, frame)
            btnBar:SetHeight(28)
            btnBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 6)
            btnBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 6)

            local reportBtn = CreateFrame("Button", nil, btnBar, "UIPanelButtonTemplate")
            reportBtn:SetSize(120, 24)
            reportBtn:SetPoint("LEFT", 0, 0)
            reportBtn:SetText("Report to Chat")
            reportBtn:SetScript("OnClick", function() ReportToRaid() end)

            local resetBtn = CreateFrame("Button", nil, btnBar, "UIPanelButtonTemplate")
            resetBtn:SetSize(80, 24)
            resetBtn:SetPoint("RIGHT", 0, 0)
            resetBtn:SetText("Reset")
            resetBtn:SetScript("OnClick", function()
                if currentRunData then
                    currentRunData.usages = {}
                    UpdateLeaderboardUI()
                end
            end)

            UpdateLeaderboardUI()
        end,
        OnShow = function()
            GetOrCreateRunData()
            UpdateLeaderboardUI()
        end,
    },
}
