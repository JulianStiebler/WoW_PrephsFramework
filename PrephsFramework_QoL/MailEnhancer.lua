--[[
    <PrephsFramework_QoL/MailEnhancer.lua>
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
local Core = LibStub("PrephsFramework_Core-0.0.1")
local logger = Core.Logger

local MOD_ID = "Quality_Of_Life"
local FEATURE_NAME = "EnhancedOpenAll"

-- Localize
local GetInboxNumItems = GetInboxNumItems
local GetInboxHeaderInfo = GetInboxHeaderInfo
local AutoLootMailItem = AutoLootMailItem
local TakeInboxMoney = TakeInboxMoney
local pairs = pairs
local tostring = tostring
local string_format = string.format
local wipe = wipe
local CreateFrame = CreateFrame
local C_Timer = C_Timer

-- ============================================================================
-- Mail Hashing — builds a composite key from mail metadata
-- ============================================================================

local function GetMailHash(index)
    local _, stationeryIcon, sender, subject, money, CODAmount,
          daysLeft, itemCount, wasRead, wasReturned, textCreated,
          canReply, isGM = GetInboxHeaderInfo(index)
    -- Composite key: sender + subject + money + COD + daysLeft(floored) + itemCount
    -- daysLeft is a float, floor it to avoid drift within the same session
    local daysKey = math.floor((daysLeft or 0) * 10) -- 0.1 day precision
    return string_format("%s|%s|%d|%d|%d|%d",
        sender or "?",
        subject or "",
        money or 0,
        CODAmount or 0,
        daysKey,
        itemCount or 0
    )
end

-- ============================================================================
-- Lock State — persisted per-character in module DB
-- ============================================================================

local lockedMails = {} -- [hash] = true, mirrors DB for fast lookups

local function GetLockedDB()
    local db = Core:GetModuleDB(MOD_ID)
    if not db then return nil end
    if not db.features then db.features = {} end
    if not db.features[FEATURE_NAME] then db.features[FEATURE_NAME] = {} end
    if not db.features[FEATURE_NAME].lockedMails then
        db.features[FEATURE_NAME].lockedMails = {}
    end
    return db.features[FEATURE_NAME].lockedMails
end

local function SyncFromDB()
    wipe(lockedMails)
    local dbLocked = GetLockedDB()
    if dbLocked then
        for hash, v in pairs(dbLocked) do
            lockedMails[hash] = v
        end
    end
end

local function SetMailLocked(hash, locked)
    lockedMails[hash] = locked or nil
    local dbLocked = GetLockedDB()
    if dbLocked then
        dbLocked[hash] = locked or nil
    end
end

local function IsMailLocked(hash)
    return lockedMails[hash] == true
end

-- ============================================================================
-- Inbox UI Overlays — lock buttons and gray overlays per mail row
-- ============================================================================

local NUM_INBOX_ITEMS = 7 -- Blizzard shows 7 mail items per page
local lockButtons = {}
local grayOverlays = {}

local function UpdateMailRow(index, mailIndex)
    local btn = lockButtons[index]
    local overlay = grayOverlays[index]
    if not btn then return end

    if mailIndex and mailIndex <= GetInboxNumItems() then
        local hash = GetMailHash(mailIndex)
        local locked = IsMailLocked(hash)

        btn.mailIndex = mailIndex
        btn.mailHash = hash
        btn:Show()

        if locked then
            btn.lockIcon:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
            btn.lockIcon:SetDesaturated(false)
            overlay:Show()
        else
            btn.lockIcon:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
            btn.lockIcon:SetDesaturated(true)
            overlay:Hide()
        end
    else
        btn:Hide()
        overlay:Hide()
    end
end

local function CreateLockButton(index)
    local itemName = "MailItem" .. index
    local parent = _G[itemName]
    if not parent then return end

    -- Lock toggle button
    local btn = CreateFrame("Button", "WTP_MailLock" .. index, parent)
    btn:SetSize(18, 18)
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -2)
    btn:SetFrameLevel(parent:GetFrameLevel() + 5)

    local lockIcon = btn:CreateTexture(nil, "ARTWORK")
    lockIcon:SetAllPoints()
    lockIcon:SetTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
    lockIcon:SetDesaturated(true)
    btn.lockIcon = lockIcon

    btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")

    btn:SetScript("OnClick", function(self)
        if not self.mailHash then return end
        local locked = IsMailLocked(self.mailHash)
        SetMailLocked(self.mailHash, not locked)
        -- Refresh the row to update visuals
        UpdateMailRow(index, self.mailIndex)
        logger:debug("[MailEnhancer] %s mail: %s", locked and "Unlocked" or "Locked", self.mailHash)
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if self.mailHash and IsMailLocked(self.mailHash) then
            GameTooltip:AddLine("Locked — skipped by Open All", 1, 0.3, 0.3)
            GameTooltip:AddLine("Click to unlock", 0.7, 0.7, 0.7)
        else
            GameTooltip:AddLine("Click to lock", 0.7, 0.7, 0.7)
            GameTooltip:AddLine("Locked mail is skipped by Open All", 0.5, 0.5, 0.5)
        end
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    lockButtons[index] = btn

    -- Gray desaturation overlay on the mail icon
    local iconName = itemName .. "Button"
    local iconBtn = _G[iconName]
    if iconBtn then
        local overlay = iconBtn:CreateTexture(nil, "OVERLAY")
        overlay:SetAllPoints()
        overlay:SetColorTexture(0.2, 0.2, 0.2, 0.6)
        overlay:Hide()
        grayOverlays[index] = overlay
    else
        -- Fallback: overlay on parent
        local overlay = parent:CreateTexture(nil, "OVERLAY")
        overlay:SetSize(40, 40)
        overlay:SetPoint("LEFT", parent, "LEFT", 8, 0)
        overlay:SetColorTexture(0.2, 0.2, 0.2, 0.6)
        overlay:Hide()
        grayOverlays[index] = overlay
    end
end

local function RefreshInboxOverlays()
    local numItems = GetInboxNumItems()
    -- InboxFrame.pageNum is 0-based in Classic
    local page = InboxFrame.page or 0
    local startIndex = page * NUM_INBOX_ITEMS

    for i = 1, NUM_INBOX_ITEMS do
        local mailIndex = startIndex + i
        if mailIndex <= numItems then
            UpdateMailRow(i, mailIndex)
        else
            UpdateMailRow(i, nil)
        end
    end
end

-- ============================================================================
-- Enhanced Open All — skips locked mails
-- ============================================================================

local isProcessing = false
local processingIndex = 0

local function ProcessNextMail()
    if not isProcessing then return end

    while processingIndex >= 1 do
        local idx = processingIndex
        processingIndex = processingIndex - 1

        local hash = GetMailHash(idx)
        if IsMailLocked(hash) then
            logger:debug("[MailEnhancer] Skipping locked mail #%d: %s", idx, hash)
        else
            local _, _, sender, subject, money, CODAmount, _, itemCount = GetInboxHeaderInfo(idx)
            -- Skip COD mail (standard behavior)
            if (CODAmount or 0) > 0 then
                logger:debug("[MailEnhancer] Skipping COD mail #%d", idx)
            else
                if (money or 0) > 0 then
                    TakeInboxMoney(idx)
                end
                if (itemCount or 0) > 0 then
                    AutoLootMailItem(idx)
                end
                -- Wait for MAIL_INBOX_UPDATE before processing next
                C_Timer.After(0.15, ProcessNextMail)
                return
            end
        end
    end

    -- Done processing
    isProcessing = false
    logger:info("Enhanced Open All complete.")
end

local function EnhancedOpenAll()
    if isProcessing then
        logger:info("Already processing mail.")
        return
    end

    local numItems = GetInboxNumItems()
    if numItems == 0 then
        logger:info("No mail to open.")
        return
    end

    local lockedCount = 0
    for i = 1, numItems do
        if IsMailLocked(GetMailHash(i)) then
            lockedCount = lockedCount + 1
        end
    end

    logger:info("Opening %d mail(s), skipping %d locked.", numItems - lockedCount, lockedCount)

    isProcessing = true
    processingIndex = numItems -- Process from highest index down
    ProcessNextMail()
end

-- ============================================================================
-- Open All Button Override
-- ============================================================================

local originalOpenAllOnClick
local enhancedOpenAllBtn

local function CreateOpenAllButton()
    if enhancedOpenAllBtn then return end

    -- The default "Open All" button in Classic is OpenAllMail (if it exists)
    -- or we create our own next to the existing mail UI
    local anchor = OpenAllMail or InboxFrame

    enhancedOpenAllBtn = CreateFrame("Button", "WTP_EnhancedOpenAll", InboxFrame, "UIPanelButtonTemplate")
    enhancedOpenAllBtn:SetSize(120, 22)
    enhancedOpenAllBtn:SetText("Open All")

    if OpenAllMail then
        -- Replace the existing button position
        enhancedOpenAllBtn:SetPoint("CENTER", OpenAllMail, "CENTER", 0, 0)
        enhancedOpenAllBtn:SetSize(OpenAllMail:GetWidth(), OpenAllMail:GetHeight())
        OpenAllMail:Hide()
        -- Re-hide on every show since Blizz may re-show it
        OpenAllMail:SetScript("OnShow", function(self) self:Hide() end)
    else
        -- No native Open All — place ours at the bottom of the inbox
        enhancedOpenAllBtn:SetPoint("BOTTOM", InboxFrame, "BOTTOM", -10, 100)
    end

    enhancedOpenAllBtn:SetScript("OnClick", function()
        EnhancedOpenAll()
    end)

    enhancedOpenAllBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Enhanced Open All", 1, 1, 1)
        GameTooltip:AddLine("Opens all mail except locked items.", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    enhancedOpenAllBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- ============================================================================
-- Activation / Deactivation
-- ============================================================================

local initialized = false

local function InitUI()
    if initialized then return end
    initialized = true

    -- Create lock buttons for each inbox row
    for i = 1, NUM_INBOX_ITEMS do
        CreateLockButton(i)
    end

    CreateOpenAllButton()

    -- Hook inbox updates to refresh our overlays
    hooksecurefunc("InboxFrame_Update", RefreshInboxOverlays)
end

local function OnMailShow()
    SyncFromDB()
    InitUI()
    RefreshInboxOverlays()
end

local function OnMailInboxUpdate()
    if initialized then
        RefreshInboxOverlays()
    end
end

local function OnMailClosed()
    if isProcessing then
        isProcessing = false
    end
end

local function Activate()
    logger:debug("[MailEnhancer] Activate called")
    SyncFromDB()
end

local function Deactivate()
    logger:debug("[MailEnhancer] Deactivate called")
    if isProcessing then
        isProcessing = false
    end
    -- Hide UI elements
    for i = 1, NUM_INBOX_ITEMS do
        if lockButtons[i] then lockButtons[i]:Hide() end
        if grayOverlays[i] then grayOverlays[i]:Hide() end
    end
    if enhancedOpenAllBtn then enhancedOpenAllBtn:Hide() end
    if OpenAllMail then
        OpenAllMail:SetScript("OnShow", nil)
        OpenAllMail:Show()
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

ns.MailEnhancer = {
    Activate = Activate,
    Deactivate = Deactivate,

    feature = {
        name = "Enhanced Mailbox 'Open All'",
        uiGroup = "General QOL",
        priority = 30,
        needsReload = false,
        defaultEnabled = false,
        events = {
            MAIL_SHOW = OnMailShow,
            MAIL_INBOX_UPDATE = OnMailInboxUpdate,
            MAIL_CLOSED = OnMailClosed,
        },
    },
}
