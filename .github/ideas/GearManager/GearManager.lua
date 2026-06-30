-- 1. PERSISTENT DATA & STATE
GearManagerSets = GearManagerSets or {}
GearManagerCache = GearManagerCache or {} 
GearManagerSettings = GearManagerSettings or { showBar = true, locked = false, direction = "Right" }

local VirtualEquipment = {} 
local scannedItems = {}
local sideButtons = {} 
local learnedIcons = {}
local randomIcons = {
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


local filterQuality, filterSlot, filterSearch = -1, "All", ""
local showBank = true
local selectedSetName = "[Current]"

local _, playerClass = UnitClass("player")
local isRelicClass = { ["PALADIN"] = true, ["SHAMAN"] = true, ["DRUID"] = true }

-------------------------------------------------------------------
-- MASTER SLOT DATA
-------------------------------------------------------------------
local SLOT_DATA = {
    ["INVTYPE_HEAD"] = { id = 1, priority = 13, tex = 136516, label = "Head" },
    ["INVTYPE_NECK"] = { id = 2, priority = 14, tex = 136519, label = "Neck" },
    ["INVTYPE_SHOULDER"] = { id = 3, priority = 15, tex = 136526, label = "Shoulder" },
    ["INVTYPE_BODY"] = { id = 4, priority = 18, tex = 136525, label = "Shirt" },
    ["INVTYPE_CHEST"] = { id = 5, priority = 17, tex = 136512, label = "Chest" },
    ["INVTYPE_ROBE"] = { id = 5, priority = 17, tex = 136512, label = "Chest" },
    ["INVTYPE_WAIST"] = { id = 6, priority = 22, tex = 136529, label = "Waist" },
    ["INVTYPE_LEGS"] = { id = 7, priority = 23, tex = 136517, label = "Legs" },
    ["INVTYPE_FEET"] = { id = 8, priority = 24, tex = 136513, label = "Feet" },
    ["INVTYPE_WRIST"] = { id = 9, priority = 20, tex = 136530, label = "Wrist" },
    ["INVTYPE_HAND"] = { id = 10, priority = 21, tex = 136515, label = "Hands" },
    ["INVTYPE_FINGER"] = { id = 11, priority = 11, tex = 136514, label = "Finger" },
    ["INVTYPE_TRINKET"] = { id = 13, priority = 12, tex = 136528, label = "Trinket" },
    ["INVTYPE_CLOAK"] = { id = 15, priority = 16, tex = 136512, label = "Back" },
    ["INVTYPE_WEAPON"] = { id = 16, priority = 1, tex = 136518, label = "Main Hand" },
    ["INVTYPE_2HWEAPON"] = { id = 16, priority = 2, tex = 136518, label = "Main Hand" },
    ["INVTYPE_WEAPONMAINHAND"] = { id = 16, priority = 3, tex = 136518, label = "Main Hand" },
    ["INVTYPE_WEAPONOFFHAND"] = { id = 17, priority = 4, tex = 136524, label = "Off Hand" },
    ["INVTYPE_SHIELD"] = { id = 17, priority = 5, tex = 136524, label = "Off Hand" },
    ["INVTYPE_HOLDABLE"] = { id = 17, priority = 6, tex = 136524, label = "Off Hand" },
    ["INVTYPE_RANGED"] = { id = 18, priority = 7, tex = 136520, label = "Ranged" },
    ["INVTYPE_RANGEDRIGHT"] = { id = 18, priority = 8, tex = 136520, label = "Ranged" },
    ["INVTYPE_THROWN"] = { id = 18, priority = 9, tex = 136520, label = "Ranged" },
    ["INVTYPE_RELIC"] = { id = 18, priority = 10, tex = 136522, label = "Ranged" },
    ["INVTYPE_TABARD"] = { id = 19, priority = 19, tex = 136527, label = "Tabard" },
}

local ID_TEXTURES = {}
for _, data in pairs(SLOT_DATA) do ID_TEXTURES[data.id] = data.tex end
if isRelicClass[playerClass] then ID_TEXTURES[18] = 136522 end

-- 2. MAIN FRAME SETUP
local frame = CreateFrame("Frame", "GearManagerFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(450, 520); frame:SetPoint("CENTER"); frame:Hide()
frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving); frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame.TitleText:SetText("Gear Manager")

local gearTab = CreateFrame("Frame", nil, frame); gearTab:SetAllPoints()
local quickBarTab = CreateFrame("Frame", nil, frame); quickBarTab:SetAllPoints(); quickBarTab:Hide()

local function Tab_OnClick(self)
    PanelTemplates_SetTab(frame, self:GetID())
    if self:GetID() == 1 then gearTab:Show(); quickBarTab:Hide() else gearTab:Hide(); quickBarTab:Show() end
end

frame.numTabs = 2
for i = 1, 2 do
    local t = CreateFrame("Button", "$parentTab"..i, frame, "CharacterFrameTabButtonTemplate")
    t:SetID(i); t:SetText(i == 1 and "Gear" or "Quick Bar")
    t:SetScript("OnClick", Tab_OnClick)
    t:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", (i - 1) * 85 + 10, 2)
end
PanelTemplates_SetNumTabs(frame, 2); PanelTemplates_UpdateTabs(frame)

-- 3. ICON PICKER UI
local picker = CreateFrame("Frame", "GMIconPicker", UIParent, "BasicFrameTemplateWithInset")
picker:SetSize(240, 300); picker:SetPoint("LEFT", frame, "RIGHT", 10, 0); picker:Hide()
picker.TitleText:SetText("Select Icon")

local pScroll = CreateFrame("ScrollFrame", "GMIconScroll", picker, "UIPanelScrollFrameTemplate")
pScroll:SetSize(200, 250); pScroll:SetPoint("TOPLEFT", 10, -30)
local pContent = CreateFrame("Frame", nil, pScroll); pContent:SetSize(180, 1); pScroll:SetScrollChild(pContent)
picker.buttons = {}


local function UpdatePicker()
    local allIcons = {}
    local seen = {}
    for _, id in ipairs(randomIcons) do if not seen[id] then table.insert(allIcons, id); seen[id] = true end end
    for id, _ in pairs(learnedIcons) do if not seen[id] then table.insert(allIcons, id); seen[id] = true end end

    for i = 1, math.max(#allIcons, #picker.buttons) do
        local b = picker.buttons[i]
        if not b and allIcons[i] then
            b = CreateFrame("Button", nil, pContent)
            b:SetSize(34, 34); b.tex = b:CreateTexture(nil, "ARTWORK"); b.tex:SetAllPoints()
            b:SetScript("OnClick", function(self) 
                gearTab.iconEdit:SetText(self.iconID)
                if selectedSetName ~= "[Current]" then GearManagerSets[selectedSetName].icon = self.iconID; if GMQuickBar then GMQuickBar:Update() end end
                picker:Hide() 
            end)
            picker.buttons[i] = b
        end
        if allIcons[i] then
            b.iconID = allIcons[i]; b.tex:SetTexture(allIcons[i])
            b:SetPoint("TOPLEFT", ((i-1)%5)*36, -math.floor((i-1)/5)*36)
            b:Show()
        elseif b then b:Hide() end
    end
end

-- 4. CORE LOGIC
local function UpdateCurrentState()
    wipe(VirtualEquipment)
    for i = 1, 19 do
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(i)
        if C_Item.DoesItemExist(itemLoc) then VirtualEquipment[i] = C_Item.GetItemGUID(itemLoc) end
    end
end

local function LoadSet(name)
    selectedSetName = name
    if name == "[Current]" then
        UpdateCurrentState()
        gearTab.setLabel:SetText("Editing: |cff00ffff[Current]|r")
        gearTab.iconEdit:SetText("134400")
    elseif GearManagerSets[name] then
        wipe(VirtualEquipment)
        if GearManagerSets[name].items then
            for slot, guid in pairs(GearManagerSets[name].items) do VirtualEquipment[slot] = guid end
        end
        local icon = GearManagerSets[name].icon or 134400
        gearTab.iconEdit:SetText(icon)
        GMQuickShowCheck:SetChecked(GearManagerSets[name].showInBar or false)
        gearTab.setLabel:SetText("Editing: |cff00ff00"..name.."|r")
    end
    UIDropDownMenu_SetText(GMSetSelect, name)
    if GearManagerFrame:IsShown() then GearManagerFrame:UpdateGrid() end
end

local function SaveSet(name)
    if not name or name == "[Current]" then return end
    GearManagerSets[name] = { 
        items = {}, 
        showInBar = GMQuickShowCheck:GetChecked(),
        icon = tonumber(gearTab.iconEdit:GetText()) or 134400 
    }
    for slot, guid in pairs(VirtualEquipment) do GearManagerSets[name].items[slot] = guid end
    if GMQuickBar then GMQuickBar:Update() end
end

local function GetCacheInfo(guid)
    local data = GearManagerCache[guid]
    if not data then return end
    local name, link, quality, _, _, _, _, _, equipLoc = C_Item.GetItemInfo(data.link)
    if not link then return end
    return name, link, equipLoc, tonumber(link:match("item:(%d+)")), quality
end

local function VirtualEquipItem(guid)
    local name, link, equipLoc, itemID = GetCacheInfo(guid)
    if not link then return end
    for slot, eGuid in pairs(VirtualEquipment) do
        if eGuid and select(4, GetCacheInfo(eGuid)) == itemID then VirtualEquipment[slot] = nil end
    end
    if equipLoc == "INVTYPE_FINGER" then
        if not VirtualEquipment[11] then VirtualEquipment[11] = guid elseif not VirtualEquipment[12] then VirtualEquipment[12] = guid else VirtualEquipment[11] = guid end
    elseif equipLoc == "INVTYPE_TRINKET" then
        if not VirtualEquipment[13] then VirtualEquipment[13] = guid elseif not VirtualEquipment[14] then VirtualEquipment[14] = guid else VirtualEquipment[13] = guid end
    elseif equipLoc == "INVTYPE_2HWEAPON" then
        VirtualEquipment[16], VirtualEquipment[17] = guid, nil
    elseif equipLoc == "INVTYPE_WEAPONMAINHAND" then
        if VirtualEquipment[17] and select(3, GetCacheInfo(VirtualEquipment[17])) == "INVTYPE_2HWEAPON" then VirtualEquipment[17] = nil end
        VirtualEquipment[16] = guid
    elseif equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_SHIELD" or equipLoc == "INVTYPE_HOLDABLE" then
        if VirtualEquipment[16] and select(3, GetCacheInfo(VirtualEquipment[16])) == "INVTYPE_2HWEAPON" then VirtualEquipment[16] = nil end
        VirtualEquipment[17] = guid
    elseif equipLoc == "INVTYPE_WEAPON" then
        if not VirtualEquipment[16] then VirtualEquipment[16] = guid elseif not VirtualEquipment[17] then VirtualEquipment[17] = guid else VirtualEquipment[16] = guid end
    else
        local data = SLOT_DATA[equipLoc]
        if data then VirtualEquipment[data.id] = guid end
    end
end

-- 5. STREAMLINED UI LAYOUT
local function CreateSideSlot(slotID, anchor, x, y)
    local btn = CreateFrame("Button", "GMSlot"..slotID, gearTab, "ItemButtonTemplate")
    btn:SetPoint(anchor, x, y); btn:SetID(slotID); btn:SetScale(0.85)
    btn.icon = _G[btn:GetName().."IconTexture"]
    btn:RegisterForClicks("RightButtonUp")
    btn:SetScript("OnClick", function(self) VirtualEquipment[self:GetID()] = nil; GearManagerFrame:UpdateGrid() end)
    btn:SetScript("OnEnter", function(self) 
        local guid = VirtualEquipment[self:GetID()]; if guid and GearManagerCache[guid] then GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetHyperlink(GearManagerCache[guid].link); GameTooltip:Show() end 
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    sideButtons[slotID] = btn
end

local LAYOUT_CONFIG = {
    { ids = {1, 2, 3, 15, 5, 4, 19, 9},    anchor = "TOPLEFT",  x = 12,  yBase = -75, spacing = 38, vertical = true },
    { ids = {10, 6, 7, 8, 11, 12, 13, 14}, anchor = "TOPRIGHT", x = -12, yBase = -75, spacing = 38, vertical = true },
    { ids = {16, 17, 18},                  anchor = "BOTTOM",   y = 80,  xBase = 0,   spacing = 45, vertical = false },
}

for _, section in ipairs(LAYOUT_CONFIG) do
    for i, id in ipairs(section.ids) do
        local x = section.vertical and section.x or (i - 2) * section.spacing
        local y = section.vertical and (section.yBase - (i * section.spacing)) or section.y
        CreateSideSlot(id, section.anchor, x, y)
    end
end

-- 6. GRID & FILTERS
local scrollFrame = CreateFrame("ScrollFrame", "GMGridScroll", gearTab, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(270, 260); scrollFrame:SetPoint("TOP", 0, -115)
local content = CreateFrame("Frame", nil, scrollFrame); content:SetSize(252, 1); scrollFrame:SetScrollChild(content)
frame.gridButtons = {}

function frame:UpdateGrid()
    for slotID, btn in pairs(sideButtons) do
        local guid = VirtualEquipment[slotID]
        if guid and GearManagerCache[guid] then btn.icon:SetTexture(GearManagerCache[guid].icon); btn.icon:SetVertexColor(1,1,1,1)
        else btn.icon:SetTexture(ID_TEXTURES[slotID] or 136511); btn.icon:SetVertexColor(1,1,1,0.3) end
    end
    wipe(scannedItems)
    for guid, data in pairs(GearManagerCache) do
        local name, link, quality, _, _, _, _, _, loc = C_Item.GetItemInfo(data.link)
        local sData = SLOT_DATA[loc]; local slotLabel = sData and sData.label or "Other"
        if (filterSearch == "" or (name and name:lower():find(filterSearch))) and (filterQuality == -1 or quality == filterQuality) and (filterSlot == "All" or slotLabel == filterSlot) and (showBank or data.locLabel ~= "Bank") then
            table.insert(scannedItems, { guid = guid, link = data.link, icon = data.icon, quality = quality or 1, name = name or "", priority = sData and sData.priority or 99 })
        end
    end
    table.sort(scannedItems, function(a, b) if a.priority ~= b.priority then return a.priority < b.priority end if a.quality ~= b.quality then return a.quality > b.quality end return a.name < b.name end)
    for i = 1, math.max(#scannedItems, #frame.gridButtons) do
        local btn = frame.gridButtons[i]
        if not btn and i <= #scannedItems then
            btn = CreateFrame("Button", "GMGridBtn"..i, content, "ItemButtonTemplate"); btn:SetPoint("TOPLEFT", ((i-1)%6)*42, -math.floor((i-1)/6)*42); btn:SetScale(0.9)
            btn:SetScript("OnClick", function(s) VirtualEquipItem(s.guid); GearManagerFrame:UpdateGrid() end)
            btn:SetScript("OnEnter", function(s) if s.guid and GearManagerCache[s.guid] then GameTooltip:SetOwner(s, "ANCHOR_RIGHT"); GameTooltip:SetHyperlink(GearManagerCache[s.guid].link); GameTooltip:Show() end end)
            btn:SetScript("OnLeave", GameTooltip_Hide)
            btn.IconBorder = _G[btn:GetName().."IconBorder"]; btn.equippedHighlight = btn:CreateTexture(nil, "OVERLAY"); btn.equippedHighlight:SetAllPoints(); btn.equippedHighlight:SetColorTexture(0, 1, 0, 0.25); frame.gridButtons[i] = btn
        end
        if scannedItems[i] then
            btn.guid = scannedItems[i].guid; _G[btn:GetName().."IconTexture"]:SetTexture(scannedItems[i].icon); btn:Show()
            local isEquipped = false; for _, vGuid in pairs(VirtualEquipment) do if vGuid == btn.guid then isEquipped = true break end end
            btn.equippedHighlight:SetShown(isEquipped)
            if btn.IconBorder then 
                if scannedItems[i].quality > 1 then 
                    local r, g, b = C_Item.GetItemQualityColor(scannedItems[i].quality)
                    btn.IconBorder:SetVertexColor(r, g, b); btn.IconBorder:Show() 
                else btn.IconBorder:Hide() end 
            end
        elseif btn then btn:Hide() end
    end
end

-- 7. REORGANIZED HEADER (Icon Preview Beside Title)
gearTab.iconPreview = gearTab:CreateTexture(nil, "OVERLAY")
gearTab.iconPreview:SetSize(36, 36); gearTab.iconPreview:SetPoint("TOPLEFT", 110, -25); gearTab.iconPreview:SetTexture(134400)
local iconBorder = gearTab:CreateTexture(nil, "BACKGROUND"); iconBorder:SetSize(42, 42); iconBorder:SetPoint("CENTER", gearTab.iconPreview, "CENTER"); iconBorder:SetTexture("Interface\\Buttons\\UI-EmptySlot-White")

gearTab.setLabel = gearTab:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge"); gearTab.setLabel:SetPoint("LEFT", gearTab.iconPreview, "RIGHT", 10, 0)

-- Icon Control Row
local showInQuickCheck = CreateFrame("CheckButton", "GMQuickShowCheck", gearTab, "ChatConfigCheckButtonTemplate"); showInQuickCheck:SetPoint("TOPLEFT", 110, -60); showInQuickCheck:SetScale(0.85); _G[showInQuickCheck:GetName().."Text"]:SetText("Show in Bar")
showInQuickCheck:SetScript("OnClick", function(self)
    if selectedSetName ~= "[Current]" then SaveSet(selectedSetName) end
end)

gearTab.iconEdit = CreateFrame("EditBox", nil, gearTab, "InputBoxTemplate")
gearTab.iconEdit:SetSize(60, 20); gearTab.iconEdit:SetPoint("LEFT", _G[showInQuickCheck:GetName().."Text"], "RIGHT", 15, 0); gearTab.iconEdit:SetAutoFocus(false)
gearTab.iconEdit:SetScript("OnTextChanged", function(self) gearTab.iconPreview:SetTexture(tonumber(self:GetText()) or 134400) end)

local iconPickBtn = CreateFrame("Button", nil, gearTab, "UIPanelButtonTemplate")
iconPickBtn:SetSize(25, 20); iconPickBtn:SetPoint("LEFT", gearTab.iconEdit, "RIGHT", 2, 0); iconPickBtn:SetText("..")
iconPickBtn:SetScript("OnClick", function() if picker:IsShown() then picker:Hide() else UpdatePicker(); picker:Show() end end)

-- Other Controls
local qualDrop = CreateFrame("Frame", "GMQualDrop", gearTab, "UIDropDownMenuTemplate"); qualDrop:SetPoint("TOPLEFT", 45, -75); UIDropDownMenu_SetWidth(qualDrop, 70); UIDropDownMenu_SetText(qualDrop, "Quality")
local slotDrop = CreateFrame("Frame", "GMSlotDrop", gearTab, "UIDropDownMenuTemplate"); slotDrop:SetPoint("LEFT", qualDrop, "RIGHT", -25, 0); UIDropDownMenu_SetWidth(slotDrop, 70); UIDropDownMenu_SetText(slotDrop, "Slot")
local searchBox = CreateFrame("EditBox", nil, gearTab, "SearchBoxTemplate"); searchBox:SetSize(100, 20); searchBox:SetPoint("TOPRIGHT", -60, -82); searchBox:SetAutoFocus(false)
searchBox:SetScript("OnTextChanged", function(self) filterSearch = self:GetText():lower(); GearManagerFrame:UpdateGrid() end)

UIDropDownMenu_Initialize(qualDrop, function()
    local quals = { [-1] = "All", [0] = "Poor", [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Legendary" }
    for i = -1, 5 do local info = UIDropDownMenu_CreateInfo(); info.text = quals[i]; info.func = function() filterQuality = i; UIDropDownMenu_SetText(qualDrop, quals[i]); GearManagerFrame:UpdateGrid() end; UIDropDownMenu_AddButton(info) end
end)

UIDropDownMenu_Initialize(slotDrop, function()
    local slots = {"All", "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist", "Hands", "Waist", "Legs", "Feet", "Finger", "Trinket", "Main Hand", "Off Hand", "Ranged"}
    for _, s in ipairs(slots) do local info = UIDropDownMenu_CreateInfo(); info.text = s; info.func = function() filterSlot = s; UIDropDownMenu_SetText(slotDrop, s); GearManagerFrame:UpdateGrid() end; UIDropDownMenu_AddButton(info) end
end)

local setSelectDrop = CreateFrame("Frame", "GMSetSelect", gearTab, "UIDropDownMenuTemplate"); setSelectDrop:SetPoint("BOTTOMLEFT", -10, 25); UIDropDownMenu_SetWidth(setSelectDrop, 90)
UIDropDownMenu_Initialize(setSelectDrop, function()
    local info = UIDropDownMenu_CreateInfo(); info.text = "[Current]"; info.func = function() LoadSet("[Current]") end; UIDropDownMenu_AddButton(info)
    for name in pairs(GearManagerSets) do info = UIDropDownMenu_CreateInfo(); info.text = name; info.func = function() LoadSet(name) end; UIDropDownMenu_AddButton(info) end
end)

local renameBtn = CreateFrame("Button", nil, gearTab, "UIPanelButtonTemplate"); renameBtn:SetSize(55, 22); renameBtn:SetPoint("LEFT", setSelectDrop, "RIGHT", -15, 2); renameBtn:SetText("Rename")
renameBtn:SetScript("OnClick", function() if selectedSetName ~= "[Current]" then StaticPopup_Show("GM_RENAME_SET") end end)
local deleteBtn = CreateFrame("Button", nil, gearTab, "UIPanelButtonTemplate"); deleteBtn:SetSize(45, 22); deleteBtn:SetPoint("LEFT", renameBtn, "RIGHT", 2, 0); deleteBtn:SetText("Del")
deleteBtn:SetScript("OnClick", function() if selectedSetName ~= "[Current]" then StaticPopup_Show("GM_DELETE_CONFIRM", selectedSetName) end end)
local bankToggle = CreateFrame("CheckButton", "GMBankToggle", gearTab, "ChatConfigCheckButtonTemplate"); bankToggle:SetPoint("LEFT", deleteBtn, "RIGHT", 5, 0); bankToggle:SetChecked(true); bankToggle:SetScale(0.8); _G[bankToggle:GetName().."Text"]:SetText("Bank")
bankToggle:SetScript("OnClick", function(s) showBank = s:GetChecked(); GearManagerFrame:UpdateGrid() end)
local saveBtn = CreateFrame("Button", nil, gearTab, "UIPanelButtonTemplate"); saveBtn:SetSize(75, 22); saveBtn:SetPoint("BOTTOMRIGHT", -10, 27); saveBtn:SetText("Save Set")
saveBtn:SetScript("OnClick", function() if selectedSetName ~= "[Current]" then SaveSet(selectedSetName) else StaticPopup_Show("GM_SAVE_SET") end end)

-- 8. POPUPS
StaticPopupDialogs["GM_SAVE_SET"] = {
    text = "Enter name for new gear set:", button1 = "Save", button2 = "Cancel", hasEditBox = true,
    OnAccept = function(s) local n = s.EditBox:GetText(); if n ~= "" and n ~= "[Current]" then SaveSet(n); LoadSet(n) end end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}
StaticPopupDialogs["GM_RENAME_SET"] = {
    text = "Rename set to:", button1 = "Rename", button2 = "Cancel", hasEditBox = true,
    OnAccept = function(s) local n = s.EditBox:GetText(); if n ~= "" and not GearManagerSets[n] and n ~= "[Current]" then GearManagerSets[n] = GearManagerSets[selectedSetName]; GearManagerSets[selectedSetName] = nil; LoadSet(n) end end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}
StaticPopupDialogs["GM_DELETE_CONFIRM"] = {
    text = "Delete set |cffff0000%s|r?", button1 = "Yes", button2 = "No",
    OnAccept = function() GearManagerSets[selectedSetName] = nil; LoadSet("[Current]"); if GMQuickBar then GMQuickBar:Update() end end,
    timeout = 0, whileDead = true,
}

-- 9. QUICK BAR (Now with Background Panel)
local QuickBar = CreateFrame("Frame", "GMQuickBar", UIParent, "BackdropTemplate")
QuickBar:SetSize(40, 40); QuickBar:SetPoint("BOTTOM", 0, 200); QuickBar:SetMovable(true); QuickBar:EnableMouse(true); QuickBar:RegisterForDrag("LeftButton")
QuickBar:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
QuickBar:SetBackdropColor(0, 0, 0, 0.6)
QuickBar:SetScript("OnDragStart", function(self) if not GearManagerSettings.locked then self:StartMoving() end end)
QuickBar:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
QuickBar.buttons = {}

function QuickBar:Update()
    for _, btn in ipairs(self.buttons) do btn:Hide() end
    local count = 0
    for name, data in pairs(GearManagerSets) do
        if data.showInBar then
            count = count + 1; local btn = self.buttons[count] or CreateFrame("Button", nil, self)
            btn:SetSize(30, 30); btn:SetNormalTexture(data.icon or 134400); btn:SetScript("OnClick", function() LoadSet(name) end)
            btn:SetScript("OnEnter", function(s) GameTooltip:SetOwner(s, "ANCHOR_TOP"); GameTooltip:SetText(name); GameTooltip:Show() end)
            btn:SetScript("OnLeave", GameTooltip_Hide)
            self.buttons[count] = btn; btn:ClearAllPoints()
            local dir = GearManagerSettings.direction
            if dir == "Right" then btn:SetPoint("LEFT", 8 + (count-1)*34, 0) elseif dir == "Left" then btn:SetPoint("RIGHT", -8 - (count-1)*34, 0) elseif dir == "Up" then btn:SetPoint("BOTTOM", 0, 8 + (count-1)*34) elseif dir == "Down" then btn:SetPoint("TOP", 0, -8 - (count-1)*34) end
            btn:Show()
        end
    end
    if count > 0 then
        if GearManagerSettings.direction == "Right" or GearManagerSettings.direction == "Left" then self:SetSize(count * 34 + 10, 40) else self:SetSize(40, count * 34 + 10) end
        if GearManagerSettings.showBar then self:Show() else self:Hide() end
    else self:Hide() end
end

-- Settings Tab
local qShowCheck = CreateFrame("CheckButton", "GMQuickBarShow", quickBarTab, "ChatConfigCheckButtonTemplate"); qShowCheck:SetPoint("TOPLEFT", 25, -80); _G[qShowCheck:GetName().."Text"]:SetText("Show Quickbar"); qShowCheck:SetChecked(GearManagerSettings.showBar)
qShowCheck:SetScript("OnClick", function(self) GearManagerSettings.showBar = self:GetChecked(); if self:GetChecked() then QuickBar:Show() else QuickBar:Hide() end end)
local qLockCheck = CreateFrame("CheckButton", "GMQuickBarLock", quickBarTab, "ChatConfigCheckButtonTemplate"); qLockCheck:SetPoint("TOPLEFT", 25, -110); _G[qLockCheck:GetName().."Text"]:SetText("Lock Position"); qLockCheck:SetChecked(GearManagerSettings.locked)
qLockCheck:SetScript("OnClick", function(self) GearManagerSettings.locked = self:GetChecked() end)
local growDrop = CreateFrame("Frame", "GMGrowDrop", quickBarTab, "UIDropDownMenuTemplate"); growDrop:SetPoint("TOPLEFT", 15, -165); UIDropDownMenu_SetWidth(growDrop, 100); UIDropDownMenu_SetText(growDrop, GearManagerSettings.direction)
UIDropDownMenu_Initialize(growDrop, function()
    for _, d in ipairs({"Up", "Down", "Left", "Right"}) do local info = UIDropDownMenu_CreateInfo(); info.text = d; info.func = function() GearManagerSettings.direction = d; UIDropDownMenu_SetText(growDrop, d); QuickBar:Update() end; UIDropDownMenu_AddButton(info) end
end)

-- 10. EVENTS & SCANNING
local function ScanStorage(isBank)
    local bags = isBank and {-1, 5, 6, 7, 8, 9, 10, 11} or {0, 1, 2, 3, 4}
    for _, bagID in ipairs(bags) do for slotID = 1, (C_Container.GetContainerNumSlots(bagID) or 0) do
        local link = C_Container.GetContainerItemLink(bagID, slotID)
        if link and IsEquippableItem(link) then 
            local guid = C_Item.GetItemGUID(ItemLocation:CreateFromBagAndSlot(bagID, slotID))
            local info = C_Container.GetContainerItemInfo(bagID, slotID)
            GearManagerCache[guid] = { link = link, icon = info.iconFileID, locLabel = isBank and "Bank" or "Bag" }
            learnedIcons[info.iconFileID] = true
        end
    end end
end

local function ScanEquipped()
    for i = 1, 19 do
        local itemLoc = ItemLocation:CreateFromEquipmentSlot(i)
        if C_Item.DoesItemExist(itemLoc) then 
            local guid = C_Item.GetItemGUID(itemLoc); local link = GetInventoryItemLink("player", i)
            if guid and link then 
                local tex = GetInventoryItemTexture("player", i)
                GearManagerCache[guid] = { link = link, icon = tex, locLabel = "Equipped" }
                learnedIcons[tex] = true
            end 
        end
    end
end

frame:RegisterEvent("BANKFRAME_OPENED"); frame:RegisterEvent("PLAYER_ENTERING_WORLD"); frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", function(self, event)
    if event == "BANKFRAME_OPENED" then ScanStorage(true) elseif event == "PLAYER_ENTERING_WORLD" then ScanEquipped(); ScanStorage(false); QuickBar:Update(); LoadSet("[Current]") elseif event == "PLAYER_LOGOUT" then UpdateCurrentState() end
    if self:IsShown() then self:UpdateGrid() end
end)

SLASH_GEAR1 = "/gear"
SlashCmdList["GEAR"] = function() if GearManagerFrame:IsShown() then GearManagerFrame:Hide() else ScanEquipped(); ScanStorage(false); LoadSet("[Current]"); GearManagerFrame:Show() end end