local AddonName, ns = ...

-- ============================================================================
-- 1. CONFIG & DEFAULTS
-- ============================================================================
local defaults = {
    settings = {
        -- Display settings
        showDeaths = true,
        showPulls = true,
        showFishing = true,
        showConsumables = true,
        showKills = true,
        showCrafts = true, -- NEW: Toggle for crafting tracking
        fallbackToVendor = true,
        showHerbalism = true,
        showOnlyMe = false,
        
        -- Conditional Tracking Settings (New)
        trackDistance = false,
        trackMana = false,
        trackHPLost = false,

        -- Reporting
        reportChannel = "SAY", 
        reportTarget = "",    
        sortMethod = "DATE",   
    },
    sessions = {}, 
    current = nil, 
    
    -- UI State
    point = { "CENTER", nil, "CENTER", 0, 0 },
    size = { 240, 380 }, -- Width, Height
    isVisible = true,
}

local emptySession = {
    startTime = 0,
    endTime = 0,
    isActive = false,
    isPaused = false,
    accumulatedTime = 0,
    loot = {},
    crafts = {}, -- NEW: Separate table for crafted items
    timestamp = "New Session",
    
    -- Standard Stats
    pulls = 0,
    deaths = 0,
    unitsKilled = 0,
    fishCasts = 0,
    foodUsed = 0,
    waterUsed = 0,
    healthPots = 0,
    
    -- New Stats
    distanceTraveled = 0, -- in yards
    manaSpent = 0,
    damageTaken = 0,
    herbAttempts = 0,
    herbSuccesses = 0,

    -- Internal flags
    wasDrinking = false,
    wasEating = false,
    lastPos = nil -- {x, y, mapID} for distance calc
}

-- Global reference
local DB
local historyRowCache = {}

-- ============================================================================
-- 2. HELPERS
-- ============================================================================
local function GetMoneyString(amount, channelType)
    if amount == 0 then return "0g" end
    if channelType == "PRINT" or channelType == "CHAT" then 
        local gold = math.floor(amount / 10000)
        local silver = math.floor((amount % 10000) / 100)
        local copper = amount % 100
        if channelType == "PRINT" then
            return GetCoinTextureString(amount)
        else
            return string.format("%dg %ds %dc", gold, silver, copper)
        end
    end
    return GetCoinTextureString(amount)
end

local function GetPrice(itemLink, itemID)
    local price = 0
    local source = "None"
    
    if Auctionator and Auctionator.API and Auctionator.API.v1 then
        local aucPrice = Auctionator.API.v1.GetAuctionPriceByItemID("PrephsFramework", itemID)
        if aucPrice and aucPrice > 0 then return aucPrice, "AH" end
    end

    if DB and DB.settings.fallbackToVendor then 
        local _, _, _, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(itemLink)
        if vendorPrice and vendorPrice > 0 then return vendorPrice, "Vendor" end
    end

    return 0, "None"
end

local function GetSessionTotalValue(session)
    local total = 0
    for _, item in pairs(session.loot) do
        total = total + (GetPrice(item.link, item.id) * item.count)
    end
    -- Also include crafts in total value
    for _, item in pairs(session.crafts or {}) do
        total = total + (GetPrice(item.link, item.id) * item.count)
    end
    return total
end

local function GetSessionDuration(session)
    local current = 0
    if session.isActive and not session.isPaused then
        current = GetTime() - session.startTime
    end
    return session.accumulatedTime + current
end

local function FormatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    return string.format("%dm %ds", m, s)
end

-- ============================================================================
-- 3. REPORTING LOGIC
-- ============================================================================
local function SendReport(session, isHistory)
    local chan = DB.settings.reportChannel or "SAY"
    local target = DB.settings.reportTarget or ""
    
    if chan == "WHISPER" and (not target or target:gsub(" ", "") == "") then
        print("|cffFF0000Error: Select a Whisper Target in Options.|r")
        return
    end

    local function Send(msg)
        SendChatMessage(msg, chan, nil, target)
    end

    print("|cff3FC7EB[Sending Report to " .. chan .. "]|r")
    
    -- 1. Header
    local dateStr = isHistory and session.timestamp or date("%Y-%m-%d")
    local durStr = FormatTime(GetSessionDuration(session))
    Send(string.format("Session from %s with Duration %s", dateStr, durStr))
    Send("-----")

    -- 2. Items (Loot + Crafts)
    local sorted = {}
    for _, v in pairs(session.loot) do table.insert(sorted, v) end
    if session.crafts then
        for _, v in pairs(session.crafts) do table.insert(sorted, v) end
    end
    table.sort(sorted, function(a,b) return (a.name or "") < (b.name or "") end)

    local totalVal = 0
    if #sorted == 0 then
        Send("(No Items)")
    else
        for _, item in ipairs(sorted) do
            local unitPrice = GetPrice(item.link, item.id)
            local lineVal = unitPrice * item.count
            totalVal = totalVal + lineVal
            local prefix = session.crafts and session.crafts[item.name] and "[C] " or ""
            local msg = prefix .. item.link .. " (" .. item.count .. "x) - " .. GetMoneyString(lineVal, "CHAT")
            Send(msg)
        end
    end
    
    Send("---")
    
    -- 3. Total Value
    Send("Total Value: " .. GetMoneyString(totalVal, "CHAT"))

    -- 4. Stats
    local statEntries = {}
    local sets = DB.settings
    
    if session.pulls > 0 and sets.showPulls then table.insert(statEntries, "Pulls: "..session.pulls) end
    if session.unitsKilled > 0 and sets.showKills then table.insert(statEntries, "Kills: "..session.unitsKilled) end
    if session.deaths > 0 and sets.showDeaths then table.insert(statEntries, "Deaths: "..session.deaths) end
    if session.fishCasts > 0 and sets.showFishing then table.insert(statEntries, "Fished: "..session.fishCasts) end
    
    -- New Stats
    if sets.trackDistance and session.distanceTraveled > 0 then 
        table.insert(statEntries, string.format("Travel: %d yds", math.floor(session.distanceTraveled))) 
    end
    if sets.trackMana and session.manaSpent > 0 then 
        table.insert(statEntries, string.format("Mana: %dk", math.floor(session.manaSpent/1000))) 
    end
    if sets.trackHPLost and session.damageTaken > 0 then 
        table.insert(statEntries, string.format("Dmg Taken: %dk", math.floor(session.damageTaken/1000))) 
    end

    if sets.showConsumables then
        if session.foodUsed > 0 or session.waterUsed > 0 then table.insert(statEntries, "F/W: "..session.foodUsed.."/"..session.waterUsed) end
        if session.healthPots > 0 then table.insert(statEntries, "Pots: "..session.healthPots) end
    end

    if #statEntries > 0 then
        Send(table.concat(statEntries, " | "))
    end
end

-- ============================================================================
-- 4. MAIN UI FRAME
-- ============================================================================
local MainFrame = CreateFrame("Frame", "PF_SLT_MainFrame", UIParent, "BackdropTemplate")
MainFrame:SetSize(240, 380) 
MainFrame:SetMovable(true)
MainFrame:SetResizable(true) -- Enable Resizing
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")

-- *** FIX: CONDITIONAL RESIZE API FOR MODERN/OLD WOW ***
if MainFrame.SetResizeBounds then
    MainFrame:SetResizeBounds(200, 200, 500, 800) -- Modern API
else
    MainFrame:SetMinResize(200, 200) -- Legacy API
    MainFrame:SetMaxResize(500, 800)
end

MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
MainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relativePoint, x, y = self:GetPoint()
    DB.point = { point, nil, relativePoint, x, y }
end)
MainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

-- Resize Grip
local ResizeGrip = CreateFrame("Button", nil, MainFrame)
ResizeGrip:SetPoint("BOTTOMRIGHT", -6, 6)
ResizeGrip:SetSize(16, 16)
ResizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
ResizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
ResizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
ResizeGrip:SetScript("OnMouseDown", function() MainFrame:StartSizing("BOTTOMRIGHT") end)
ResizeGrip:SetScript("OnMouseUp", function() 
    MainFrame:StopMovingOrSizing() 
    DB.size = { MainFrame:GetWidth(), MainFrame:GetHeight() }
end)

-- *** NEW: OPTION COGWHEEL BUTTON ***
local btnOpt = CreateFrame("Button", nil, MainFrame)
btnOpt:SetSize(16, 16)
btnOpt:SetPoint("TOPRIGHT", -10, -10)
btnOpt:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
btnOpt:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
btnOpt:SetScript("OnClick", function()
    local f = _G["PF_SLT_Options"]
    if f then
        if f:IsShown() then f:Hide() else f:Show() end
    end
end)

local ScrollFrame = CreateFrame("ScrollFrame", nil, MainFrame, "UIPanelScrollFrameTemplate")
ScrollFrame:SetPoint("TOPLEFT", 10, -30) 
ScrollFrame:SetPoint("BOTTOMRIGHT", -30, 95) 

local ScrollChild = CreateFrame("Frame")
ScrollChild:SetSize(200, 500) 
ScrollFrame:SetScrollChild(ScrollChild)

local DisplayText = ScrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
DisplayText:SetPoint("TOPLEFT", ScrollChild, "TOPLEFT", 5, 0)
DisplayText:SetWidth(190) 
DisplayText:SetJustifyH("LEFT")
DisplayText:SetJustifyV("TOP")

MainFrame:SetScript("OnSizeChanged", function(self, w, h)
    ScrollChild:SetWidth(w - 40)
    DisplayText:SetWidth(w - 50)
end)

local btnStart, btnPause, btnReset, btnLiveReport

local function CreateBtn(parent, text, w, h, func)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(w, h)
    btn:SetText(text)
    btn:SetScript("OnClick", func)
    return btn
end

-- ============================================================================
-- 5. DISPLAY UPDATE LOGIC
-- ============================================================================
local function UpdateDisplay()
    if not DB or not DB.current then return end
    local s = DB.current
    local settings = DB.settings
    
    local totalSeconds = GetSessionDuration(s)
    local timeStr = FormatTime(totalSeconds)
    
    local status = "|cffFF0000Stopped|r"
    if s.isActive then
        status = s.isPaused and "|cffFFFF00Paused|r" or "|cff00FF00Running|r"
    end

    if btnStart then btnStart:SetText(s.isActive and "End" or "Start") end
    if btnPause then
        if not s.isActive then btnPause:SetText("Pause"); btnPause:Disable()
        else btnPause:Enable(); btnPause:SetText(s.isPaused and "Resume" or "Pause") end
    end
    if btnReset then btnReset:SetEnabled(not s.isActive or s.isPaused) end

    local text = string.format("Time: |cffffffff%s|r (%s)\n", timeStr, status)
    text = text .. "----------------------\n"

    if settings.showPulls then text = text .. string.format("Pulls: |cffffffff%d|r\n", s.pulls) end
    if settings.showKills then text = text .. string.format("Kills: |cffffffff%d|r\n", s.unitsKilled) end
    if settings.showDeaths then text = text .. string.format("Deaths: |cffff0000%d|r\n", s.deaths) end
    if settings.showFishing then text = text .. string.format("Fished: |cff00ccff%d|r\n", s.fishCasts) end
    if settings.showHerbalism then
        text = text .. string.format("Herbalism: |cff40ff40%d|r Att / |cff40ff40%d|r Succ / |cffff4040%d|r Fail\n", 
            s.herbAttempts, s.herbSuccesses, s.herbFails)
    end
    if settings.trackDistance then 
        text = text .. string.format("Travel: |cff00ff00%d yds|r\n", math.floor(s.distanceTraveled)) 
    end
    if settings.trackMana then 
        text = text .. string.format("Mana Spent: |cff3333ff%d|r\n", s.manaSpent) 
    end
    if settings.trackHPLost then 
        text = text .. string.format("Dmg Taken: |cffff0000%d|r\n", s.damageTaken) 
    end

    if settings.showConsumables then 
        text = text .. string.format("F/W: |cffffffff%d|r / |cffffffff%d|r - Pots: |cffffffff%d|r\n", s.foodUsed, s.waterUsed, s.healthPots)
    end
    text = text .. "----------------------\n"

    -- Combine Loot and Crafts for Display
    local sortedItems = {}
    for _, item in pairs(s.loot) do table.insert(sortedItems, item) end
    if settings.showCrafts and s.crafts then
        for _, item in pairs(s.crafts) do table.insert(sortedItems, item) end
    end
    table.sort(sortedItems, function(a,b) return (a.name or "") < (b.name or "") end)

    local totalVal = 0
    if #sortedItems == 0 then
        text = text .. "(No Items)"
    else
        for _, item in ipairs(sortedItems) do
            local unitPrice, source = GetPrice(item.link, item.id)
            local lineVal = unitPrice * item.count
            totalVal = totalVal + lineVal
            local priceStr = (unitPrice > 0) and GetCoinTextureString(lineVal) or "|cff808080(N/A)|r"
            if source == "Vendor" and unitPrice > 0 then priceStr = priceStr.."|cffaaaaaa(V)|r" end
            
            local prefix = (s.crafts and s.crafts[item.name]) and "|cff00ff00[C]|r " or ""
            text = text .. string.format("%s%dx %s %s\n", prefix, item.count, item.link, priceStr)
        end
    end
    
    if totalVal > 0 then
        text = text .. "\n----------------------\n"
        text = text .. "Total: " .. GetCoinTextureString(totalVal)
    end

    DisplayText:SetText(text)
    ScrollChild:SetHeight(DisplayText:GetStringHeight() + 20)
end

-- ============================================================================
-- 6. TRACKING LOGIC
-- ============================================================================
local Tracker = CreateFrame("Frame")
Tracker:RegisterEvent("ADDON_LOADED")
Tracker:RegisterEvent("CHAT_MSG_LOOT")
Tracker:RegisterEvent("PLAYER_REGEN_DISABLED") 
Tracker:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
Tracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Tracker:RegisterEvent("UNIT_AURA")
Tracker:RegisterEvent("UNIT_SPELLCAST_SENT")
Tracker:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
Tracker:RegisterEvent("UI_ERROR_MESSAGE")

Tracker:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == AddonName then
        if not PrephsFrameworkSessionLootDB then 
            PrephsFrameworkSessionLootDB = CopyTable(defaults) 
            PrephsFrameworkSessionLootDB.current = CopyTable(emptySession)
        end
        DB = PrephsFrameworkSessionLootDB
        
        if DB.settings.showCrafts == nil then DB.settings.showCrafts = true end
        if DB.settings.trackDistance == nil then DB.settings.trackDistance = false end
        if DB.settings.trackMana == nil then DB.settings.trackMana = false end
        if DB.settings.trackHPLost == nil then DB.settings.trackHPLost = false end
        if not DB.size then DB.size = {240, 380} end

        ns.InitializeOptionsGUI() 
        
        if DB.point then MainFrame:SetPoint(unpack(DB.point)) end
        if DB.size then MainFrame:SetSize(unpack(DB.size)) end
        if DB.isVisible then MainFrame:Show() else MainFrame:Hide() end
        return
    end

    if not DB or not DB.current or not DB.current.isActive or DB.current.isPaused then return end
    local s = DB.current

    if event == "CHAT_MSG_LOOT" then
        local msg = arg1
        
        -- Patterns for First Person (You)
        local isMyCraft = string.find(msg, "You create")
        local isMyLoot = string.find(msg, "You receive") or string.find(msg, "You loot")
        
        -- Patterns for Others (Buddy)
        -- WoW uses: "Player creates: [Item]" or "Player receives loot: [Item]"
        local isOtherCraft = string.find(msg, " creates: ")
        local isOtherLoot = string.find(msg, " receives loot: ") or string.find(msg, " loots: ")

        -- Check "Only Me" Setting
        local shouldTrack = false
        if isMyCraft or isMyLoot then
            shouldTrack = true
        elseif not DB.settings.showOnlyMe then
            if isOtherCraft or isOtherLoot then
                shouldTrack = true
            end
        end

        if not shouldTrack then return end
        
        -- Extract Item Link and Count
        local fullLink = string.match(msg, "(|c.-|Hitem:.-|h.-|h|r)")
        local count = tonumber(string.match(msg, "x(%d+)\.") or 1)
        if not fullLink then fullLink = string.match(msg, "(|Hitem:.-|h.-|h)") end
        
        if fullLink then
            local itemName = GetItemInfo(fullLink)
            local itemID = tonumber(fullLink:match("|Hitem:(%d+):"))
            if itemName and itemID then 
                -- Logic to determine which table to put it in
                local isCraftAction = isMyCraft or isOtherCraft
                local targetTable = (isCraftAction and DB.settings.showCrafts) and s.crafts or s.loot
                
                if not targetTable[itemName] then 
                    targetTable[itemName] = { name = itemName, count = 0, link = fullLink, id = itemID } 
                end
                targetTable[itemName].count = targetTable[itemName].count + count
                UpdateDisplay()
            end
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if DB.settings.showPulls then
            s.pulls = s.pulls + 1
            UpdateDisplay()
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = arg1, arg2, arg3
        if unit == "player" then
            local fishingSpells = { [7620] = true, [7731] = true, [7732] = true, [18248] = true }
            if (fishingSpells[spellID] or GetSpellInfo(spellID) == "Fishing") then
                s.fishCasts = s.fishCasts + 1
                UpdateDisplay()
            end
            
            if DB.settings.trackMana then
                local costs = GetSpellPowerCost(spellID)
                if costs then
                    for _, costInfo in pairs(costs) do
                        if costInfo.type == 0 then 
                            s.manaSpent = s.manaSpent + costInfo.cost
                            UpdateDisplay()
                        end
                    end
                end
            end
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, _, _, destGUID, destName, destFlags, _, param12, param13, param14, param15 = CombatLogGetCurrentEventInfo()
        
        if subEvent == "UNIT_DIED" and destGUID == UnitGUID("player") then
            s.deaths = s.deaths + 1
            UpdateDisplay()
        elseif subEvent == "UNIT_DIED" then
            local unitType = strsplit("-", destGUID)
            if unitType == "Creature" or unitType == "Vehicle" then
                local isHostile = bit.band(destFlags, 0x40) == 0x40
                if isHostile then
                    s.unitsKilled = s.unitsKilled + 1
                    UpdateDisplay()
                end
            end
        elseif subEvent == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("player") then
            local spellID, spellName = param12, param13
            local potSpells = { [17548] = true, [10900] = true } 
            if potSpells[spellID] or string.find(spellName or "", "Healing Potion") then
                s.healthPots = s.healthPots + 1
                UpdateDisplay()
            end
        elseif DB.settings.trackHPLost and destGUID == UnitGUID("player") then
            local amount = 0
            if subEvent == "SWING_DAMAGE" then amount = param12
            elseif subEvent == "SPELL_DAMAGE" or subEvent == "RANGE_DAMAGE" then amount = param15
            elseif subEvent == "ENVIRONMENTAL_DAMAGE" then amount = param13
            end
            
            if amount and amount > 0 then
                s.damageTaken = s.damageTaken + amount
                UpdateDisplay()
            end
        end
    elseif event == "UNIT_AURA" and arg1 == "player" then
        local i = 1
        local foundDrink, foundFood = false, false
        while true do
            local name = UnitBuff("player", i)
            if not name then break end
            if name == "Drink" then 
                foundDrink = true
                if not s.wasDrinking then s.waterUsed = s.waterUsed + 1; s.wasDrinking = true; UpdateDisplay() end
            elseif name == "Food" then 
                foundFood = true
                if not s.wasEating then s.foodUsed = s.foodUsed + 1; s.wasEating = true; UpdateDisplay() end
            end
            i = i + 1
        end
        if not foundDrink then s.wasDrinking = false end
        if not foundFood then s.wasEating = false end
    end

        -- 1. Track the Attempt
    if event == "UNIT_SPELLCAST_SENT" then
        local unit, target, _, spellID = arg1, arg2, arg3, arg4
        -- Herbalism Spell ID is 2366
        if unit == "player" and (spellID == 2366 or (target and (target:find("Herb") or target:find("Flower")))) then
            s.herbAttempts = s.herbAttempts + 1
            UpdateDisplay()
        end

    -- 2. Track the Fail (The "Yellow Text" error at the top of your screen)
    elseif event == "UI_ERROR_MESSAGE" then
        local msg = arg1 or arg2 -- Depending on WoW version arg index
        if msg == "You failed to perform that action" or msg == "Skill required to perform that action" then
            s.herbFails = s.herbFails + 1
            UpdateDisplay()
        end

    -- 3. Track the Success
    -- At 300 skill, we look for the Success event following an attempt.
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = arg1, arg2, arg3
        if unit == "player" and spellID == 2366 then
            -- Note: If UI_ERROR_MESSAGE didn't fire right before this, it's a success.
            -- A more robust way is checking CHAT_MSG_LOOT for items, but this works for the "Interaction"
            s.herbSuccesses = s.herbSuccesses + 1
            UpdateDisplay()
        end
    end
end)

local ticker = 0
local distTicker = 0
MainFrame:SetScript("OnUpdate", function(self, elapsed)
    if not DB or not DB.current or not DB.current.isActive or DB.current.isPaused then return end
    local s = DB.current

    ticker = ticker + elapsed
    if ticker >= 1 then UpdateDisplay(); ticker = 0 end

    if DB.settings.trackDistance then
        distTicker = distTicker + elapsed
        if distTicker >= 0.25 then
            local y, x, z, mapID = UnitPosition("player")
            if x and y and mapID then
                if s.lastPos and s.lastPos.mapID == mapID then
                    local dx = x - s.lastPos.x
                    local dy = y - s.lastPos.y
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist > 0 then
                        s.distanceTraveled = s.distanceTraveled + dist
                    end
                end
                s.lastPos = {x=x, y=y, mapID=mapID}
            else
                s.lastPos = nil
            end
            distTicker = 0
        end
    end
end)

-- ============================================================================
-- 7. SESSION BUTTONS (LIVE WINDOW)
-- ============================================================================

btnStart = CreateBtn(MainFrame, "Start", 80, 25, function(self)
    local s = DB.current
    if s.isActive then
        s.isActive = false
        s.isPaused = true 
        s.endTime = time()
        if not s.isPaused and s.startTime > 0 then 
             s.accumulatedTime = s.accumulatedTime + (GetTime() - s.startTime)
        end
        local archived = CopyTable(s)
        archived.lastPos = nil 
        archived.timestamp = date("%Y-%m-%d %H:%M:%S")
        table.insert(DB.sessions, 1, archived) 
        DB.current = CopyTable(emptySession)
        print("|cffFF0000Session Ended and Saved.|r")
    else
        DB.current = CopyTable(emptySession)
        DB.current.isActive = true
        DB.current.startTime = GetTime()
        print("|cff00FF00Session Started!|r")
    end
    UpdateDisplay()
end)
btnStart:SetPoint("BOTTOMLEFT", 10, 10)

btnReset = CreateBtn(MainFrame, "Reset", 60, 25, function(self)
    DB.current = CopyTable(emptySession)
    print("|cffffa500Session Reset.|r")
    UpdateDisplay()
end)
btnReset:SetPoint("LEFT", btnStart, "RIGHT", 5, 0)

btnPause = CreateBtn(MainFrame, "Pause", 70, 25, function(self)
    local s = DB.current
    if not s.isActive then return end
    if s.isPaused then
        s.isPaused = false
        s.startTime = GetTime()
    else
        s.isPaused = true
        s.accumulatedTime = s.accumulatedTime + (GetTime() - s.startTime)
    end
    UpdateDisplay()
end)
btnPause:SetPoint("BOTTOMRIGHT", -20, 10) 

btnLiveReport = CreateBtn(MainFrame, "Report", 220, 20, function()
    if not DB.current.isActive then print("No active session."); return end
    SendReport(DB.current, false)
end)
btnLiveReport:SetPoint("BOTTOM", 0, 40)

-- ============================================================================
-- 8. OPTIONS & HISTORY GUI
-- ============================================================================
local OptFrame = CreateFrame("Frame", "PF_SLT_Options", UIParent, "BackdropTemplate")
OptFrame:SetSize(450, 600)
OptFrame:SetPoint("CENTER")
OptFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
    tile = true, tileSize = 32, edgeSize = 16, 
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})
OptFrame:Hide()
OptFrame:SetMovable(true)
OptFrame:EnableMouse(true)
OptFrame:RegisterForDrag("LeftButton")
OptFrame:SetScript("OnDragStart", OptFrame.StartMoving)
OptFrame:SetScript("OnDragStop", OptFrame.StopMovingOrSizing)

local OptTitle = OptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
OptTitle:SetPoint("TOP", 0, -15)
OptTitle:SetText("Session Options & History")

local btnCloseOpt = CreateFrame("Button", nil, OptFrame, "UIPanelCloseButton")
btnCloseOpt:SetPoint("TOPRIGHT", -5, -5)
btnCloseOpt:SetScript("OnClick", function() OptFrame:Hide() end)

local histScroll = CreateFrame("ScrollFrame", nil, OptFrame, "UIPanelScrollFrameTemplate")
histScroll:SetPoint("TOPLEFT", 20, -320) 
histScroll:SetPoint("BOTTOMRIGHT", -35, 20)
local histContent = CreateFrame("Frame")
histContent:SetSize(395, 500)
histScroll:SetScrollChild(histContent)

local expandedSessions = {} 

local function RenderHistory()
    local sortM = DB.settings.sortMethod
    local displayList = {}
    
    for i, sess in ipairs(DB.sessions) do
        table.insert(displayList, { index = i, data = sess })
    end
    
    table.sort(displayList, function(a, b)
        if sortM == "VALUE" then return GetSessionTotalValue(a.data) > GetSessionTotalValue(b.data)
        elseif sortM == "LENGTH" then return GetSessionDuration(a.data) > GetSessionDuration(b.data)
        else return (a.data.timestamp or "") > (b.data.timestamp or "") end
    end)

    local searchStr = _G["PF_SLT_SearchBox"]:GetText():lower()
    local filteredList = {}
    if searchStr == "" then
        filteredList = displayList
    else
        for _, obj in ipairs(displayList) do
            local match = false
            if string.find((obj.data.timestamp or ""):lower(), searchStr) then match = true end
            if not match then
                for _, lootItem in pairs(obj.data.loot) do
                    if string.find((lootItem.name or ""):lower(), searchStr) then match = true; break end
                end
            end
            if match then table.insert(filteredList, obj) end
        end
    end

    for _, f in pairs(historyRowCache) do f:Hide() end
    local yOffset = 0
    
    for i, obj in ipairs(filteredList) do
        local sess = obj.data
        local realIndex = obj.index
        local f = historyRowCache[i]
        if not f then
            f = CreateFrame("Frame", nil, histContent, "BackdropTemplate")
            f:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 }
            })
            f:SetBackdropColor(0,0,0,0.5)
            f.headerBtn = CreateFrame("Button", nil, f)
            f.headerBtn:SetPoint("TOPLEFT", 0,0)
            f.headerBtn:SetPoint("TOPRIGHT", 0,0)
            f.headerBtn:SetHeight(25)
            f.headerBtn.text = f.headerBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLeft")
            f.headerBtn.text:SetPoint("LEFT", 10, 0)
            
            f.details = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            f.details:SetPoint("TOPLEFT", 10, -30)
            f.details:SetWidth(360)
            f.details:SetJustifyH("LEFT")

            f.btnReport = CreateBtn(f, "Report", 60, 20, function() end)
            f.btnReport:SetPoint("BOTTOMLEFT", 10, 10)
            f.btnDelete = CreateBtn(f, "Delete", 60, 20, function() end)
            f.btnDelete:SetPoint("BOTTOMRIGHT", -10, 10)
            table.insert(historyRowCache, f)
        end
        
        f:Show()
        f:SetPoint("TOPLEFT", 0, -yOffset)
        f:SetWidth(395)
        
        local totalV = GetSessionTotalValue(sess)
        local durStr = FormatTime(GetSessionDuration(sess))
        local timeTxt = sess.timestamp or "Unknown"
        f.headerBtn.text:SetText(string.format("%s | %s | %s", timeTxt, durStr, GetMoneyString(totalV, "PRINT")))
        
        f.headerBtn:SetScript("OnClick", function()
            if expandedSessions[realIndex] then expandedSessions[realIndex] = nil else expandedSessions[realIndex] = true end
            RenderHistory()
        end)
        
        f.btnReport:SetScript("OnClick", function() SendReport(sess, true) end)
        f.btnDelete:SetScript("OnClick", function() table.remove(DB.sessions, realIndex); RenderHistory() end)

        if expandedSessions[realIndex] then
            local det = string.format("Loot Types: %d | Pulls: %d | Kills: %d\n", #f.details, sess.pulls, sess.unitsKilled)
            if (sess.distanceTraveled or 0) > 0 then det = det .. string.format("Travel: %d yds | ", sess.distanceTraveled) end
            det = det .. "\nTop Items:\n"
            
            local sl = {}
            for _, v in pairs(sess.loot) do table.insert(sl, v) end
            if sess.crafts then for _, v in pairs(sess.crafts) do table.insert(sl, v) end end
            table.sort(sl, function(a,b) return (GetPrice(a.link, a.id)*a.count) > (GetPrice(b.link, b.id)*b.count) end)
            
            for k=1, math.min(5, #sl) do
                local v = sl[k]
                local p = (sess.crafts and sess.crafts[v.name]) and "[C] " or ""
                det = det .. string.format("- %s%dx %s (%s)\n", p, v.count, v.link, GetMoneyString(GetPrice(v.link,v.id)*v.count, "PRINT"))
            end
            
            f.details:SetText(det)
            f.details:Show()
            f.btnReport:Show(); f.btnDelete:Show()
            f:SetHeight(f.details:GetStringHeight() + 60)
        else
            f.details:Hide()
            f.btnReport:Hide(); f.btnDelete:Hide()
            f:SetHeight(28)
        end
        
        yOffset = yOffset + f:GetHeight() + 5
    end
    histContent:SetHeight(yOffset + 20)
end


function ns.InitializeOptionsGUI()
    local function CreateCheck(label, key, yOffset, xOffset)
        local cb = CreateFrame("CheckButton", nil, OptFrame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", xOffset or 20, yOffset)
        cb.text:SetText(label)
        cb:SetChecked(DB.settings[key])
        cb:SetScript("OnClick", function(self)
            DB.settings[key] = self:GetChecked()
            UpdateDisplay()
        end)
        return cb
    end

    CreateCheck("Show Deaths", "showDeaths", -40)
    CreateCheck("Show Pulls", "showPulls", -65)
    CreateCheck("Show Fishing", "showFishing", -90)
    CreateCheck("Show Consumables", "showConsumables", -115)
    CreateCheck("Show Kills", "showKills", -140)
    CreateCheck("Show Crafts", "showCrafts", -165)
    CreateCheck("Only Me (Loot/Craft)", "showOnlyMe", -190) -- NEW CHECKBOX
    CreateCheck("Fallback to Vendor Price", "fallbackToVendor", -215)
    CreateCheck("Show Herbalism Tracker", "showHerbalism", -240)
    
    local col2 = 240
    local lblTrk = OptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lblTrk:SetPoint("TOPLEFT", col2, -40)
    lblTrk:SetText("Advanced Tracking")
    
    CreateCheck("Track Distance", "trackDistance", -65, col2)
    CreateCheck("Track Mana", "trackMana", -90, col2)
    CreateCheck("Track HP Lost", "trackHPLost", -115, col2)

    local lblRep = OptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lblRep:SetPoint("TOPRIGHT", -150, -45)
    lblRep:SetText("Report To:")
    
    local btnChan = CreateFrame("Button", nil, OptFrame, "UIPanelButtonTemplate")
    btnChan:SetSize(100, 25)
    btnChan:SetPoint("TOPRIGHT", -40, -40)
    
    local whisperBox = CreateFrame("EditBox", "PF_SLT_WhisperBox", OptFrame, "InputBoxTemplate")
    whisperBox:SetSize(100, 20)
    whisperBox:SetPoint("TOP", btnChan, "BOTTOM", 0, -5)
    whisperBox:SetAutoFocus(false)
    whisperBox:SetText(DB.settings.reportTarget or "")
    whisperBox:SetScript("OnTextChanged", function(self) DB.settings.reportTarget = self:GetText() end)
    
    local channels = {"SAY", "PARTY", "RAID", "GUILD", "WHISPER"}
    local function UpdateChanBtn()
        btnChan:SetText(DB.settings.reportChannel)
        if DB.settings.reportChannel == "WHISPER" then whisperBox:Show() else whisperBox:Hide() end
    end
    
    btnChan:SetScript("OnClick", function()
        local curr = DB.settings.reportChannel
        local idx = 1
        for i,v in ipairs(channels) do if v == curr then idx = i break end end
        idx = (idx % #channels) + 1
        DB.settings.reportChannel = channels[idx]
        UpdateChanBtn()
    end)
    UpdateChanBtn()

    local yBase = -240
    local lblSort = OptFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lblSort:SetPoint("TOPLEFT", 20, yBase)
    lblSort:SetText("Sort History By:")

    local function SetSort(m) DB.settings.sortMethod = m; RenderHistory() end
    local btnSortDate = CreateBtn(OptFrame, "Date", 50, 20, function() SetSort("DATE") end)
    btnSortDate:SetPoint("LEFT", lblSort, "RIGHT", 10, 0)
    local btnSortVal = CreateBtn(OptFrame, "Value", 50, 20, function() SetSort("VALUE") end)
    btnSortVal:SetPoint("LEFT", btnSortDate, "RIGHT", 5, 0)
    local btnSortLen = CreateBtn(OptFrame, "Len", 50, 20, function() SetSort("LENGTH") end)
    btnSortLen:SetPoint("LEFT", btnSortVal, "RIGHT", 5, 0)

    local searchBox = CreateFrame("EditBox", "PF_SLT_SearchBox", OptFrame, "InputBoxTemplate")
    searchBox:SetSize(130, 20)
    searchBox:SetPoint("TOPLEFT", 260, yBase + 3)
    searchBox:SetAutoFocus(false)
    searchBox:SetText("")
    searchBox:SetScript("OnTextChanged", RenderHistory)
    
    local lblSearch = OptFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    lblSearch:SetPoint("RIGHT", searchBox, "LEFT", -5, 0)
    lblSearch:SetText("Search:")
    
    OptFrame:SetScript("OnShow", RenderHistory)
end

SLASH_PREPHSLT1 = "/preph"
SlashCmdList["PREPHSLT"] = function(msg)
    local cmd, sub = strsplit(" ", msg, 2)
    if cmd == "slt" then
        if sub == "opt" or sub == "options" then
            if OptFrame:IsShown() then OptFrame:Hide() else OptFrame:Show() end
        else
            if MainFrame:IsShown() then MainFrame:Hide() else MainFrame:Show() end
        end
    end
end