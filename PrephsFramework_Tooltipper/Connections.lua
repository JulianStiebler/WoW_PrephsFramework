--[[
    <PrephsFramework_Tooltipper/Connections.lua>
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

local defGrpName = "Default"
---@class PrephsFramework.CommLink
local CommLink = Core.CommLink

local pairs    = pairs
local ipairs   = ipairs
local table    = table
local date     = date
local CreateFrame     = CreateFrame
local StaticPopup_Show = StaticPopup_Show

-- ============================================================================
-- Helpers
-- ============================================================================

local COLOR_HEADER = "|cff3FC7EB"
local COLOR_GREEN  = "|cff00FF00"
local COLOR_RED    = "|cffFF4444"
local COLOR_GRAY   = "|cff808080"
local COLOR_YELLOW = "|cffFFFF00"
local COLOR_WHITE  = "|cffFFFFFF"
local COLOR_RESET  = "|r"

--- Append the player's realm if the input has no dash (Name → Name-Realm).
local function NormalizeCharKey(text)
    if not text or text == "" then return text end
    if not text:find("-") then
        local realm = GetNormalizedRealmName and GetNormalizedRealmName() or (GetRealmName() or ""):gsub("%s+", "")
        text = text .. "-" .. realm
    end
    return text
end

-- ============================================================================
-- Static Popup Dialogs
-- ============================================================================

StaticPopupDialogs["PF_CONN_ADD_TARGET"] = {
    text = "Enter the character name to add (Name-Realm).\nRealm is optional — defaults to your current realm.",
    button1 = "Add",
    button2 = "Cancel",
    hasEditBox = true,
    editBoxWidth = 250,
    OnAccept = function(self)
        local text = NormalizeCharKey(self.EditBox:GetText())
        if text and text ~= "" then
            local groupName = self.data or defGrpName
            CommLink:AddSyncTarget(text, groupName)
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        local text = NormalizeCharKey(self:GetText())
        if text and text ~= "" then
            local groupName = parent.data or defGrpName
            CommLink:AddSyncTarget(text, groupName)
        end
        parent:Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["PF_CONN_NEW_GROUP"] = {
    text = "Enter a name for the new sync account:",
    button1 = "Create",
    button2 = "Cancel",
    hasEditBox = true,
    editBoxWidth = 250,
    OnAccept = function(self)
        local text = self.EditBox:GetText()
        if text and text ~= "" then
            CommLink:CreateSyncGroup(text)
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        local text = self:GetText()
        if text and text ~= "" then
            CommLink:CreateSyncGroup(text)
        end
        parent:Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["PF_CONN_RENAME_GROUP"] = {
    text = "Enter a new name for account '%s':",
    button1 = "Rename",
    button2 = "Cancel",
    hasEditBox = true,
    editBoxWidth = 250,
    OnAccept = function(self)
        local newName = self.EditBox:GetText()
        if newName and newName ~= "" and self.data then
            CommLink:RenameSyncGroup(self.data, newName)
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        local newName = self:GetText()
        if newName and newName ~= "" and parent.data then
            CommLink:RenameSyncGroup(parent.data, newName)
        end
        parent:Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["PF_CONN_DELETE_GROUP"] = {
    text = "Delete account '%s' and all its connections?\n\nThis cannot be undone.",
    button1 = "Delete",
    button2 = "Cancel",
    OnAccept = function(self)
        if self.data then
            CommLink:DeleteSyncGroup(self.data)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["PF_CONN_REMOVE_TARGET"] = {
    text = "Remove '%s' from your connections?\n\nSynced data for this character will be deleted.",
    button1 = "Remove",
    button2 = "Cancel",
    OnAccept = function(self)
        if self.data then
            CommLink:RemoveSyncTarget(self.data)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["PF_CONN_BLOCK_USER"] = {
    text = "Block '%s'?\n\nThis will decline any pending request and ignore all future pairing attempts from this user.",
    button1 = "Block",
    button2 = "Cancel",
    OnAccept = function(self)
        if self.data then
            CommLink:BlockUser(self.data)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["PF_CONN_UNBLOCK_USER"] = {
    text = "Unblock '%s'?\n\nThey will be able to send pairing requests again.",
    button1 = "Unblock",
    button2 = "Cancel",
    OnAccept = function(self)
        if self.data then
            CommLink:UnblockUser(self.data)
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- PF_CONN_ACCEPT_REQ removed — acceptance now uses an inline EditBox
-- in the pending request row itself (see AfterInitialize).


--- Generate a unique account name.  If `base` already exists, appends
--- "-1", "-2", etc. until a free name is found.
---@param base string
---@return string uniqueName
local function UniqueAccountName(base)
    if not base or base == "" then base = defGrpName end
    local groups = CommLink:GetAllSyncGroups()
    if not groups[base] then return base end
    local i = 1
    while groups[base .. "-" .. i] do
        i = i + 1
    end
    return base .. "-" .. i
end


--- Helper: create a managed row frame for the layout system.
---@param parent Frame
---@param height number
---@param offset number|nil  layoutOffset override
---@return Frame row
local function CreateManagedRow(parent, height, offset)
    local UI = Core.UI
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(600, height)
    row.inUse = true
    row.frameType = "Spacer"
    UI.elementSequence = UI.elementSequence + 1
    row.sequence = UI.elementSequence
    row.isLayoutManaged = true
    row.layoutOffset = offset or -2
    return row
end


-- ============================================================================
-- Connections Frame Definition
-- ============================================================================

---@type ModuleFrameConfig
local ConnectionsFrame = {
    title = "Connections",
    slashListEntry = "sync",
    size = {
        w = 650,
        h = 550,
        resizable = true,
    },

    AfterInitialize = function(frame)
        local Factory = Core.UI.Factory
        local UI      = Core.UI
        local content = frame.ScrollChild

        -- =================================================================
        -- Refresh: tears down and rebuilds the entire content area
        -- =================================================================
        local function Refresh()
            -- Clear existing content
            local regions = {content:GetRegions()}
            for _, region in ipairs(regions) do
                if region.inUse then Factory:ReleaseFrame(region) end
            end
            local children = {content:GetChildren()}
            for _, child in ipairs(children) do
                if child.inUse then Factory:ReleaseFrame(child) end
                child:Hide()
                child:ClearAllPoints()
                child:SetParent(nil)
            end
            UI.elementSequence = 0

            -- ── Title ──
            local title = Factory:CreateLabel(content, COLOR_HEADER .. "Sync Accounts" .. COLOR_RESET, "GameFontNormalLarge")
            if title then title:Show() end

            local desc = Factory:CreateLabel(
                content,
                "Manage cross-account sync connections. Each account groups characters from one remote Battle.net account.\n"
                .. "When you add someone, they receive a pairing request and must accept before data syncs.\n"
                .. "Enable 'Whole Account Sync' to automatically discover and sync all characters on that account.",
                "GameFontNormalSmall",
                {0.6, 0.6, 0.6}
            )
            if desc then desc:Show() end

            -- ── New Account button ──
            local newGroupBtn = Factory:CreateButton(content, "New Account", function()
                StaticPopup_Show("PF_CONN_NEW_GROUP")
            end)
            if newGroupBtn then newGroupBtn:Show() end

            local sep1 = Factory:CreateSeparator(content)
            if sep1 then sep1:Show() end

            -- ── Sync Accounts ──
            local groups = CommLink:GetAllSyncGroups()
            local sortedGroupNames = {}
            for gn in pairs(groups) do
                sortedGroupNames[#sortedGroupNames + 1] = gn
            end
            table.sort(sortedGroupNames)

            for _, groupName in ipairs(sortedGroupNames) do
                local group = groups[groupName]

                -- Account header
                local groupLabel = Factory:CreateLabel(
                    content,
                    COLOR_HEADER .. groupName .. COLOR_RESET
                    .. (group.syncWholeDB and ("  " .. COLOR_GREEN .. "[Whole Account Sync]" .. COLOR_RESET) or ""),
                    "GameFontNormal"
                )
                if groupLabel then
                    groupLabel.layoutOffset = -16
                    groupLabel:Show()
                end

                -- Account action buttons row
                local actionRow = CreateManagedRow(content, 24, -2)

                local xOff = 0

                -- Toggle whole-account button:
                -- "Disable" always visible when already enabled.
                -- "Enable" only visible once pairing is confirmed
                -- (at least one target has synced data back to us).
                local showWholeDB = group.syncWholeDB
                if not showWholeDB then
                    for ck in pairs(group.targets) do
                        if Core:GetSyncedSnapshot(ck) or CommLink:IsPeerOnline(ck) then
                            showWholeDB = true
                            break
                        end
                    end
                end
                if showWholeDB then
                    local wholeDBBtn = CreateFrame("Button", nil, actionRow, "UIPanelButtonTemplate")
                    wholeDBBtn:SetSize(145, 22)
                    wholeDBBtn:SetPoint("LEFT", xOff, 0)
                    wholeDBBtn:SetText(group.syncWholeDB and "Disable Whole Acc" or "Enable Whole Acc")
                    wholeDBBtn:SetScript("OnClick", function()
                        CommLink:SetGroupOption(groupName, "syncWholeDB", not group.syncWholeDB)
                    end)
                    xOff = xOff + 150
                end

                -- Rename button
                local renameBtn = CreateFrame("Button", nil, actionRow, "UIPanelButtonTemplate")
                renameBtn:SetSize(70, 22)
                renameBtn:SetPoint("LEFT", xOff, 0)
                renameBtn:SetText("Rename")
                renameBtn:SetScript("OnClick", function()
                    local dialog = StaticPopup_Show("PF_CONN_RENAME_GROUP", groupName)
                    if dialog then dialog.data = groupName end
                end)
                xOff = xOff + 75

                -- Delete button
                local deleteBtn = CreateFrame("Button", nil, actionRow, "UIPanelButtonTemplate")
                deleteBtn:SetSize(70, 22)
                deleteBtn:SetPoint("LEFT", xOff, 0)
                deleteBtn:SetText("Delete")
                deleteBtn:SetScript("OnClick", function()
                    local dialog = StaticPopup_Show("PF_CONN_DELETE_GROUP", groupName)
                    if dialog then dialog.data = groupName end
                end)
                xOff = xOff + 75

                -- Add target button
                local addBtn = CreateFrame("Button", nil, actionRow, "UIPanelButtonTemplate")
                addBtn:SetSize(100, 22)
                addBtn:SetPoint("LEFT", xOff, 0)
                addBtn:SetText("Add Target")
                addBtn:SetScript("OnClick", function()
                    local dialog = StaticPopup_Show("PF_CONN_ADD_TARGET")
                    if dialog then dialog.data = groupName end
                end)

                actionRow:Show()

                -- Target rows
                local targets = CommLink:GetGroupTargets(groupName)
                table.sort(targets)

                if #targets == 0 then
                    local emptyLabel = Factory:CreateLabel(
                        content,
                        COLOR_GRAY .. "  No connections in this account." .. COLOR_RESET,
                        "GameFontNormalSmall"
                    )
                    if emptyLabel then emptyLabel:Show() end
                else
                    for _, charKey in ipairs(targets) do
                        local isOnline = CommLink:IsPeerOnline(charKey)
                        local statusIcon = isOnline
                            and (COLOR_GREEN .. "●" .. COLOR_RESET)
                            or  (COLOR_RED   .. "●" .. COLOR_RESET)

                        local targetRow = CreateManagedRow(content, 22, -2)

                        local nameText = targetRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        nameText:SetPoint("LEFT", 10, 0)
                        nameText:SetText(statusIcon .. "  " .. COLOR_WHITE .. charKey .. COLOR_RESET)

                        -- Remove button
                        local removeBtn = CreateFrame("Button", nil, targetRow, "UIPanelButtonTemplate")
                        removeBtn:SetSize(60, 20)
                        removeBtn:SetPoint("LEFT", nameText, "RIGHT", 10, 0)
                        removeBtn:SetText("Remove")
                        removeBtn:SetScript("OnClick", function()
                            local dlg = StaticPopup_Show("PF_CONN_REMOVE_TARGET", charKey)
                            if dlg then dlg.data = charKey end
                        end)

                        -- Block button
                        local blockBtn = CreateFrame("Button", nil, targetRow, "UIPanelButtonTemplate")
                        blockBtn:SetSize(50, 20)
                        blockBtn:SetPoint("LEFT", removeBtn, "RIGHT", 5, 0)
                        blockBtn:SetText("Block")
                        blockBtn:SetScript("OnClick", function()
                            local dlg = StaticPopup_Show("PF_CONN_BLOCK_USER", charKey)
                            if dlg then dlg.data = charKey end
                        end)

                        targetRow:Show()
                    end
                end

            end

            if #sortedGroupNames == 0 then
                local noGroups = Factory:CreateLabel(
                    content,
                    COLOR_GRAY .. "No sync accounts yet. Create one to start syncing!" .. COLOR_RESET,
                    "GameFontNormal"
                )
                if noGroups then noGroups:Show() end
            end

            -- ── Pending Requests Section ──
            local sep2 = Factory:CreateSeparator(content)
            if sep2 then sep2:Show() end

            local pendingHeader = Factory:CreateLabel(
                content,
                COLOR_YELLOW .. "Pending Requests" .. COLOR_RESET,
                "GameFontNormalLarge"
            )
            if pendingHeader then
                pendingHeader.layoutOffset = -10
                pendingHeader:Show()
            end

            local pendingDesc = Factory:CreateLabel(
                content,
                "Characters who want to sync with you. Accept to add them to an account.",
                "GameFontNormalSmall",
                {0.6, 0.6, 0.6}
            )
            if pendingDesc then pendingDesc:Show() end

            local pending = CommLink:GetPendingRequests()
            local hasPending = false

            local sortedPending = {}
            for ck, info in pairs(pending) do
                sortedPending[#sortedPending + 1] = { charKey = ck, time = info.time or 0 }
            end
            table.sort(sortedPending, function(a, b) return a.time > b.time end)

            for _, entry in ipairs(sortedPending) do
                hasPending = true
                local ck = entry.charKey
                local ts = entry.time > 0 and date("%Y-%m-%d %H:%M", entry.time) or "unknown"

                -- Info row: name + timestamp
                local infoRow = CreateManagedRow(content, 20, -4)
                local reqText = infoRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                reqText:SetPoint("LEFT", 10, 0)
                reqText:SetText(COLOR_WHITE .. ck .. COLOR_RESET .. "  " .. COLOR_GRAY .. "(" .. ts .. ")" .. COLOR_RESET)
                infoRow:Show()

                -- Accept row: EditBox for account name + Accept / Accept+Whole / Decline / Block
                local acceptRow = CreateManagedRow(content, 26, -2)

                local nameBox = CreateFrame("EditBox", nil, acceptRow, "InputBoxTemplate")
                nameBox:SetSize(130, 20)
                nameBox:SetPoint("LEFT", 10, 0)
                nameBox:SetAutoFocus(false)
                nameBox:SetText(defGrpName)
                nameBox:SetCursorPosition(0)

                local acceptBtn = CreateFrame("Button", nil, acceptRow, "UIPanelButtonTemplate")
                acceptBtn:SetSize(60, 20)
                acceptBtn:SetPoint("LEFT", nameBox, "RIGHT", 5, 0)
                acceptBtn:SetText("Accept")
                acceptBtn:SetScript("OnClick", function()
                    local grp = nameBox:GetText()
                    if not grp or grp == "" then grp = defGrpName end
                    grp = UniqueAccountName(grp)
                    CommLink:AcceptPairRequest(ck, grp, false)
                end)

                local declineBtn = CreateFrame("Button", nil, acceptRow, "UIPanelButtonTemplate")
                declineBtn:SetSize(60, 20)
                declineBtn:SetPoint("LEFT", acceptBtn, "RIGHT", 5, 0)
                declineBtn:SetText("Decline")
                declineBtn:SetScript("OnClick", function()
                    CommLink:DeclinePairRequest(ck)
                end)

                local blockReqBtn = CreateFrame("Button", nil, acceptRow, "UIPanelButtonTemplate")
                blockReqBtn:SetSize(50, 20)
                blockReqBtn:SetPoint("LEFT", declineBtn, "RIGHT", 5, 0)
                blockReqBtn:SetText("Block")
                blockReqBtn:SetScript("OnClick", function()
                    local dlg = StaticPopup_Show("PF_CONN_BLOCK_USER", ck)
                    if dlg then dlg.data = ck end
                end)

                -- Enter in the EditBox also accepts
                nameBox:SetScript("OnEnterPressed", function(self)
                    self:ClearFocus()
                    local grp = self:GetText()
                    if not grp or grp == "" then grp = defGrpName end
                    grp = UniqueAccountName(grp)
                    CommLink:AcceptPairRequest(ck, grp, false)
                end)

                acceptRow:Show()
            end

            if not hasPending then
                local noPending = Factory:CreateLabel(
                    content,
                    COLOR_GRAY .. "No pending requests." .. COLOR_RESET,
                    "GameFontNormalSmall"
                )
                if noPending then noPending:Show() end
            end

            -- ── Whole-Account Sync Requests ──
            local wdbPending = CommLink:GetPendingWDBRequests()
            local hasWDB = false
            local sortedWDB = {}
            for ck, info in pairs(wdbPending) do
                sortedWDB[#sortedWDB + 1] = { charKey = ck, time = info.time or 0 }
            end
            table.sort(sortedWDB, function(a, b) return a.time > b.time end)

            if #sortedWDB > 0 then
                local wdbSep = Factory:CreateSeparator(content)
                if wdbSep then wdbSep:Show() end

                local wdbHeader = Factory:CreateLabel(
                    content,
                    COLOR_YELLOW .. "Whole-Account Sync Requests" .. COLOR_RESET,
                    "GameFontNormal"
                )
                if wdbHeader then
                    wdbHeader.layoutOffset = -10
                    wdbHeader:Show()
                end

                for _, entry in ipairs(sortedWDB) do
                    hasWDB = true
                    local ck = entry.charKey
                    local ts = entry.time > 0 and date("%Y-%m-%d %H:%M", entry.time) or "unknown"

                    local wdbInfoRow = CreateManagedRow(content, 20, -4)
                    local wdbText = wdbInfoRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    wdbText:SetPoint("LEFT", 10, 0)
                    wdbText:SetText(COLOR_WHITE .. ck .. COLOR_RESET
                        .. "  " .. COLOR_GRAY .. "wants to share their whole account DB" .. COLOR_RESET
                        .. "  " .. COLOR_GRAY .. "(" .. ts .. ")" .. COLOR_RESET)
                    wdbInfoRow:Show()

                    local wdbBtnRow = CreateManagedRow(content, 26, -2)

                    local receiveBtn = CreateFrame("Button", nil, wdbBtnRow, "UIPanelButtonTemplate")
                    receiveBtn:SetSize(120, 20)
                    receiveBtn:SetPoint("LEFT", 10, 0)
                    receiveBtn:SetText("Only Receive")
                    receiveBtn:SetScript("OnClick", function()
                        CommLink:AcceptWDBRequest(ck, "receive")
                    end)

                    local bothBtn = CreateFrame("Button", nil, wdbBtnRow, "UIPanelButtonTemplate")
                    bothBtn:SetSize(140, 20)
                    bothBtn:SetPoint("LEFT", receiveBtn, "RIGHT", 5, 0)
                    bothBtn:SetText("Also Share My DB")
                    bothBtn:SetScript("OnClick", function()
                        CommLink:AcceptWDBRequest(ck, "both")
                    end)

                    local wdbDeclineBtn = CreateFrame("Button", nil, wdbBtnRow, "UIPanelButtonTemplate")
                    wdbDeclineBtn:SetSize(60, 20)
                    wdbDeclineBtn:SetPoint("LEFT", bothBtn, "RIGHT", 5, 0)
                    wdbDeclineBtn:SetText("Decline")
                    wdbDeclineBtn:SetScript("OnClick", function()
                        CommLink:DeclineWDBRequest(ck)
                    end)

                    wdbBtnRow:Show()
                end
            end

            -- ── Blocked Users Section ──
            local sep3 = Factory:CreateSeparator(content)
            if sep3 then sep3:Show() end

            local blockedHeader = Factory:CreateLabel(
                content,
                COLOR_RED .. "Blocked Users" .. COLOR_RESET,
                "GameFontNormalLarge"
            )
            if blockedHeader then
                blockedHeader.layoutOffset = -10
                blockedHeader:Show()
            end

            local blocked = CommLink:GetBlockedUsers()
            local hasBlocked = false

            local sortedBlocked = {}
            for ck in pairs(blocked) do
                sortedBlocked[#sortedBlocked + 1] = ck
            end
            table.sort(sortedBlocked)

            for _, ck in ipairs(sortedBlocked) do
                hasBlocked = true

                local blockRow = CreateManagedRow(content, 22, -2)

                local blockText = blockRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                blockText:SetPoint("LEFT", 10, 0)
                blockText:SetText(COLOR_GRAY .. ck .. COLOR_RESET)

                local unblockBtn = CreateFrame("Button", nil, blockRow, "UIPanelButtonTemplate")
                unblockBtn:SetSize(60, 20)
                unblockBtn:SetPoint("LEFT", blockText, "RIGHT", 10, 0)
                unblockBtn:SetText("Unblock")
                unblockBtn:SetScript("OnClick", function()
                    local dlg = StaticPopup_Show("PF_CONN_UNBLOCK_USER", ck)
                    if dlg then dlg.data = ck end
                end)

                blockRow:Show()
            end

            if not hasBlocked then
                local noBlocked = Factory:CreateLabel(
                    content,
                    COLOR_GRAY .. "No blocked users." .. COLOR_RESET,
                    "GameFontNormalSmall"
                )
                if noBlocked then noBlocked:Show() end
            end

            -- Finalize layout
            UI:RefreshLayout(content)
        end

        -- Initial build
        Refresh()

        -- Store the refresh function on the frame so OnShow can call it
        frame._refreshConnections = Refresh

        -- Register for CommLink change events so the UI updates reactively
        CommLink:RegisterChangeListener(function()
            -- Only refresh if the frame is visible
            if frame:IsShown() then
                Refresh()
            end
        end)
    end,

    OnShow = function()
        -- Refresh content every time the frame is shown
        local frameKey = "Tooltipper_Connections"
        local f = Core.UI.CustomFrames[frameKey]
        if f and f._refreshConnections then
            f._refreshConnections()
        end
    end,
}

-- Export so we can reference it
if not ns.ToolipperFrames then ns.ToolipperFrames = {} end
ns.ToolipperFrames.Connections = ConnectionsFrame
