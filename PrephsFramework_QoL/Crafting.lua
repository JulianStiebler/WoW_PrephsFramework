--[[
    <PrephsFramework_QoL/CraftingEnhancer.lua>
    Copyright (C) <2026> <JulianStiebler / Prephmage>
    License: GNU Affero General Public License v3
--]]
---@meta _
local addonName, ns = ...

---@type PrephsFramework
local Core = LibStub("PrephsFramework_Core-0.0.1")
local logger = Core.Logger

local MOD_ID = "Quality_Of_Life"
local FEATURE_NAME = "CraftingEnhancer"

-- Initialize namespace
ns.CraftingEnhancer = {}

-- ============================================================================
-- State & DB Handling
-- ============================================================================
local searchString = ""
local highlightedRecipes = {} -- [recipeName] = {r, g, b}
local filteredIndices = {}
local isHooked = false

local function GetHighlightDB()
    local db = Core:GetModuleDB(MOD_ID)
    if not db then return nil end
    if not db.features then db.features = {} end
    if not db.features[FEATURE_NAME] then db.features[FEATURE_NAME] = {} end
    if not db.features[FEATURE_NAME].highlights then
        db.features[FEATURE_NAME].highlights = {}
    end
    return db.features[FEATURE_NAME].highlights
end

local function SyncFromDB()
    wipe(highlightedRecipes)
    local dbHighlights = GetHighlightDB()
    if dbHighlights then
        for name, color in pairs(dbHighlights) do
            highlightedRecipes[name] = color
        end
    end
end

-- ============================================================================
-- Filtering Logic
-- ============================================================================
local function UpdateFilteredList()
    wipe(filteredIndices)
    local realNumSkills = GetNumTradeSkills()
    
    if searchString == "" then
        for i = 1, realNumSkills do table.insert(filteredIndices, i) end
    else
        for i = 1, realNumSkills do
            local name, skillType = GetTradeSkillInfo(i)
            if name then
                -- Match name OR if it's a header, we keep it to maintain list structure
                if skillType == "header" or name:lower():find(searchString, 1, true) then
                    table.insert(filteredIndices, i)
                end
            end
        end
    end
end

-- ============================================================================
-- Data Interception (The "Secret Sauce")
-- ============================================================================
-- We store the original functions to call them for the actual data
local _GetNumTradeSkills = GetNumTradeSkills
local _GetTradeSkillInfo = GetTradeSkillInfo

-- Overwrite global functions (Blizzard UI uses these to draw the list)
_G.GetNumTradeSkills = function()
    if searchString ~= "" and Core:ShouldFeatureBeActive(MOD_ID, FEATURE_NAME) then
        return #filteredIndices
    end
    return _GetNumTradeSkills()
end

_G.GetTradeSkillInfo = function(index)
    if searchString ~= "" and Core:ShouldFeatureBeActive(MOD_ID, FEATURE_NAME) then
        local realIndex = filteredIndices[index]
        if realIndex then
            return _GetTradeSkillInfo(realIndex)
        end
    end
    return _GetTradeSkillInfo(index)
end

-- ============================================================================
-- UI logic: Search & Highlighting
-- ============================================================================
local searchBox
local function CreateSearchBox()
    if searchBox then return end
    
    searchBox = CreateFrame("EditBox", "PrephsProfessionSearch", TradeSkillFrame, "SearchBoxTemplate")
    searchBox:SetSize(120, 20)
    searchBox:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -70, -36)
    searchBox:SetFrameLevel(TradeSkillFrame:GetFrameLevel() + 10)
    
    searchBox:SetScript("OnTextChanged", function(self)
        searchString = self:GetText():lower()
        UpdateFilteredList()
        TradeSkillFrame_Update() -- Redraw with the intercepted data
    end)
end

local function ApplyBackgroundHighlight(button, color)
    if not button.PF_Highlight then
        button.PF_Highlight = button:CreateTexture(nil, "BACKGROUND")
        button.PF_Highlight:SetTexture("Interface\\Buttons\\White8x8")
        button.PF_Highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
        button.PF_Highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
    end

    if color then
        button.PF_Highlight:SetVertexColor(color.r, color.g, color.b, 0.3)
        button.PF_Highlight:Show()
    else
        button.PF_Highlight:Hide()
    end
end

-- ============================================================================
-- Color Picker
-- ============================================================================
function ns.CraftingEnhancer.OpenColorPicker(recipeName)
    local color = highlightedRecipes[recipeName] or {r = 1, g = 1, b = 1}
    ColorPickerFrame:SetupColorPickerAndShow({
        swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            highlightedRecipes[recipeName] = {r = r, g = g, b = b}
            local db = GetHighlightDB()
            if db then db[recipeName] = {r = r, g = g, b = b} end
            TradeSkillFrame_Update()
        end,
        hasOpacity = false,
        r = color.r, g = color.g, b = color.b,
    })
end

-- ============================================================================
-- Hooking Visuals
-- ============================================================================
local function HookTradeSkillUI()
    if isHooked then return end

    hooksecurefunc("TradeSkillFrame_Update", function()
        if not Core:ShouldFeatureBeActive(MOD_ID, FEATURE_NAME) then return end
        
        local numSkills = GetNumTradeSkills() -- This will call our intercepted function
        for i = 1, TRADE_SKILLS_DISPLAYED do
            local skillButton = _G["TradeSkillSkill"..i]
            if skillButton and skillButton:IsShown() then
                local skillIndex = skillButton:GetID()
                if skillIndex > 0 and skillIndex <= numSkills then
                    local name = GetTradeSkillInfo(skillIndex)
                    ApplyBackgroundHighlight(skillButton, highlightedRecipes[name])
                end
            end
        end
    end)

    hooksecurefunc("TradeSkillFrame_SetSelection", function(id)
        if not Core:ShouldFeatureBeActive(MOD_ID, FEATURE_NAME) then return end
        
        local name = GetTradeSkillInfo(id)
        if not name then return end

        if TradeSkillSkillIcon then
            TradeSkillSkillIcon:EnableMouse(true)
            TradeSkillSkillIcon:SetScript("OnMouseDown", function(_, button)
                if button == "RightButton" then
                    ns.CraftingEnhancer.OpenColorPicker(name)
                elseif button == "MiddleButton" then
                    highlightedRecipes[name] = nil
                    local db = GetHighlightDB()
                    if db then db[name] = nil end
                    TradeSkillFrame_Update()
                end
            end)
        end
    end)

    isHooked = true
end

-- ============================================================================
-- Feature Lifecycle
-- ============================================================================
local function OnTradeSkillShow()
    SyncFromDB()
    HookTradeSkillUI()
    UpdateFilteredList()
    CreateSearchBox()
    if searchBox then searchBox:Show() end
end

local function Activate()
    SyncFromDB()
    if TradeSkillFrame and TradeSkillFrame:IsVisible() then
        OnTradeSkillShow()
    end
end

local function Deactivate()
    if searchBox then searchBox:Hide() end
    searchString = ""
    if TradeSkillFrame and TradeSkillFrame:IsVisible() then 
        TradeSkillFrame_Update() 
    end
end

ns.CraftingEnhancer.Activate = Activate
ns.CraftingEnhancer.Deactivate = Deactivate
ns.CraftingEnhancer.feature = {
    name = "Profession Search & Highlights",
    uiGroup = "General QOL",
    priority = 35,
    defaultEnabled = true,
    events = {
        TRADE_SKILL_SHOW = OnTradeSkillShow,
    },
}