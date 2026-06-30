--[[
    <PrephsFramework_Core/UI/UI_MainFrame.lua>
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

---@class PrephsFramework
local Core = ns.PF

---@class PrephsFramework.UI
local UI = Core.UI

local CreateFrame = CreateFrame
local UISpecialFrames = UISpecialFrames
local UIParent = UIParent
local math = math
local pairs = pairs
local table = table

---@class PrephsFramework.UI.MainFrame : Frame
---@field sidebar Frame Sidebar container frame
---@field sidebarScrollFrame ScrollFrame Sidebar scroll frame
---@field sidebarScrollChild Frame Sidebar scroll child for button layout
---@field content Frame Content area container frame
---@field contentScrollFrame ScrollFrame Content area scroll frame
---@field contentScrollChild Frame Content area scroll child for widget layout
---@field TitleText FontString Title bar text

--- Save main frame geometry to the global DB
---@param frame Frame
local function SaveMainFrameGeometry(frame)
    local db = Core.DB
    if not db then return end
    if not db.mainFrame then db.mainFrame = {} end
    local geo = db.mainFrame
    geo.w = frame:GetWidth()
    geo.h = frame:GetHeight()
    geo.x = frame:GetLeft()
    geo.y = frame:GetTop() - UIParent:GetTop()
end

---@return PrephsFramework.UI.MainFrame
function UI:CreateMainFrame()
    if self.MainFrame then
        return self.MainFrame
    end

    local sizeConfig = Core.MainFrameSize or {}
    local saved = Core.DB and Core.DB.mainFrame or nil
    local SIDEBAR_WIDTH = 200

    -- Resolve dimensions: persisted > config > defaults
    local frameW = (saved and saved.w) or sizeConfig.w or 900
    local frameH = (saved and saved.h) or sizeConfig.h or 700

    -- Main Frame
    local f = CreateFrame("Frame", "PrephsFramework_MainFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(frameW, frameH)

    -- Position: persisted > config > CENTER
    if saved and saved.x and saved.y then
        f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", saved.x, saved.y)
    elseif sizeConfig.x ~= nil or sizeConfig.y ~= nil then
        f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", sizeConfig.x or 0, sizeConfig.y or 0)
    else
        f:SetPoint("CENTER")
    end

    f:Hide()
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")

    -- Drag scripts with position persistence
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveMainFrameGeometry(self)
    end)

    f.TitleText:SetText("Prephs Framework")
    
    -- Register for ESC key closure
    tinsert(UISpecialFrames, f:GetName())

    -- Resizable setup
    if sizeConfig.resizable then
        f:SetResizable(true)
        local minW = math.max((sizeConfig.w or 900) * 0.5, 400)
        local minH = math.max((sizeConfig.h or 700) * 0.5, 300)

        if f.SetResizeBounds then
            f:SetResizeBounds(minW, minH, 1920, 1080)
        else
            f:SetMinResize(minW, minH)
            f:SetMaxResize(1920, 1080)
        end

        local resizeGrip = CreateFrame("Button", nil, f)
        resizeGrip:SetSize(16, 16)
        resizeGrip:SetPoint("BOTTOMRIGHT", -2, 2)
        resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

        resizeGrip:SetScript("OnMouseDown", function()
            f:StartSizing("BOTTOMRIGHT")
        end)
        resizeGrip:SetScript("OnMouseUp", function()
            f:StopMovingOrSizing()
            SaveMainFrameGeometry(f)
        end)

        f.resizeGrip = resizeGrip

        -- Adapt content scroll child width on resize
        f:HookScript("OnSizeChanged", function(self, w, h)
            if f.contentScrollChild then
                f.contentScrollChild:SetWidth(math.max(w - SIDEBAR_WIDTH - 43, 100))
            end
        end)
    end

    -- Create Sidebar (anchored to frame edges)
    f.sidebar = CreateFrame("Frame", nil, f)
    f.sidebar:SetPoint("TOPLEFT", 8, -30)
    f.sidebar:SetPoint("BOTTOMLEFT", 8, 8)
    f.sidebar:SetWidth(SIDEBAR_WIDTH)
    
    -- Sidebar Scroll Frame
    f.sidebarScrollFrame = CreateFrame("ScrollFrame", nil, f.sidebar, "UIPanelScrollFrameTemplate")
    f.sidebarScrollFrame:SetPoint("TOPLEFT", 0, 0)
    f.sidebarScrollFrame:SetPoint("BOTTOMRIGHT", -20, 0)
    
    f.sidebarScrollChild = CreateFrame("Frame", nil, f.sidebarScrollFrame)
    f.sidebarScrollChild:SetSize(SIDEBAR_WIDTH - 20, 1)
    f.sidebarScrollFrame:SetScrollChild(f.sidebarScrollChild)
    
    -- Create Content Area (anchored to frame edges)
    f.content = CreateFrame("Frame", nil, f)
    f.content:SetPoint("TOPLEFT", SIDEBAR_WIDTH + 15, -30)
    f.content:SetPoint("BOTTOMRIGHT", -8, 8)
    
    -- Content Scroll Frame
    f.contentScrollFrame = CreateFrame("ScrollFrame", nil, f.content, "UIPanelScrollFrameTemplate")
    f.contentScrollFrame:SetPoint("TOPLEFT", 0, -5)
    f.contentScrollFrame:SetPoint("BOTTOMRIGHT", -27, 5)
    
    f.contentScrollChild = CreateFrame("Frame", nil, f.contentScrollFrame)
    f.contentScrollChild:SetSize(math.max(frameW - SIDEBAR_WIDTH - 43, 100), 1)
    f.contentScrollFrame:SetScrollChild(f.contentScrollChild)
    
    -- Store references
    self.MainFrame = f
    self.ScrollFrame = f.contentScrollFrame
    self.ScrollChild = f.contentScrollChild
    self.SidebarScrollChild = f.sidebarScrollChild
    
    -- Build sidebar
    self:RebuildSidebar()
    
    return f
end

function UI:ToggleMainFrame()
    if not self.MainFrame then
        self:CreateMainFrame()
    end
    
    if self.MainFrame:IsShown() then
        self.MainFrame:Hide()
        -- Close any open suppression popup
        if self.currentSuppressionPopup and self.currentSuppressionPopup:IsShown() then
            self.currentSuppressionPopup:Hide()
        end
    else
        self:RebuildSidebar()  -- Refresh sidebar in case modules changed
        self.MainFrame:Show()
        
        -- Show framework info by default
        if not self.currentPage then
            self:ShowFrameworkInfo()
        end
    end
end

function UI:RebuildSidebar()
    if not self.MainFrame then return end
    
    local sidebar = self.SidebarScrollChild
    if not sidebar then return end
    -- Clear existing buttons
    local children = {sidebar:GetChildren()}

    for _, child in ipairs(children) do
        child:Hide()
        child:SetParent(nil)
    end
    
    local yOffset = 0
    local btnWidth = 180
    local btnHeight = 30
    local spacing = 5
    
    -- Framework Info Button
    local infoBtn = CreateFrame("Button", nil, sidebar, "UIPanelButtonTemplate")
    infoBtn:SetSize(btnWidth, btnHeight)
    infoBtn:SetPoint("TOPLEFT", 0, yOffset)
    infoBtn:SetText("Framework Info")
    infoBtn:SetScript("OnClick", function()
        self:ShowFrameworkInfo()
    end)
    yOffset = yOffset - btnHeight - spacing
    
    -- General Settings Button
    local generalBtn = CreateFrame("Button", nil, sidebar, "UIPanelButtonTemplate")
    generalBtn:SetSize(btnWidth, btnHeight)
    generalBtn:SetPoint("TOPLEFT", 0, yOffset)
    generalBtn:SetText("General Settings")
    generalBtn:SetScript("OnClick", function()
        self:ShowGeneralSettings()
    end)
    yOffset = yOffset - btnHeight - spacing
    
    -- Separator
    yOffset = yOffset - 10
    
    -- Module Sections
    for moduleID, moduleData in pairs(Core.DiscoveredModules) do
        yOffset = self:CreateModuleSidebarEntry(sidebar, moduleID, moduleData, yOffset, btnWidth, btnHeight, spacing)
    end
    
    -- Update sidebar scroll height
    sidebar:SetHeight(math.abs(yOffset) + 20)
end

---@param parent Frame The sidebar scroll child
---@param moduleID moduleID
---@param moduleData table Discovery data for the module
---@param yOffset number Current vertical offset for positioning
---@param btnWidth number Button width in pixels
---@param btnHeight number Button height in pixels
---@param spacing number Vertical spacing between buttons
---@return number yOffset Updated vertical offset after all entries
function UI:CreateModuleSidebarEntry(parent, moduleID, moduleData, yOffset, btnWidth, btnHeight, spacing)
    local module = Core.RegisteredModules[moduleID]
    local isRegistered = (module ~= nil)
    
    -- Container frame for module button and collapse button
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(btnWidth, btnHeight)
    container:SetPoint("TOPLEFT", 0, yOffset)
    
    -- Module Header Button (shorter if collapse button exists)
    local moduleBtnWidth = isRegistered and (btnWidth - btnHeight - 3) or btnWidth
    local moduleBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    moduleBtn:SetSize(moduleBtnWidth, btnHeight)
    moduleBtn:SetPoint("TOPLEFT", 0, 0)
    
    -- Use displayName from moduleData (supports spaces)
    local displayName = moduleData.displayName or moduleData.title or moduleID
    
    -- Color code based on registration status: Green if registered, Yellow if not
    local textColor = isRegistered and "|cff00FF00" or "|cffFFFF00"
    moduleBtn:SetText(textColor .. displayName .. "|r")
    
    -- Store state
    container.isExpanded = false
    container.moduleID = moduleID
    container.featureGroups = {}
    
    -- Click handler for module button - only navigate to page
    moduleBtn:SetScript("OnClick", function()
        -- Always try to show the module page (it will handle loading if needed)
        UI:ShowModulePage(moduleID)
    end)
    
    -- Create collapse/expand button if module is registered
    local collapseBtn = nil
    if isRegistered then
        collapseBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        collapseBtn:SetSize(btnHeight, btnHeight)
        collapseBtn:SetPoint("LEFT", moduleBtn, "RIGHT", 3, 0)
        collapseBtn:SetText(self.expandedModules[moduleID] and "-" or "+")
        
        collapseBtn:SetScript("OnClick", function(self)
            -- Toggle expansion state
            UI.expandedModules[moduleID] = not UI.expandedModules[moduleID]
            
            -- Rebuild entire sidebar to recalculate positions
            UI:RebuildSidebar()
        end)
    end
    
    yOffset = yOffset - btnHeight - spacing
    
    -- Create feature group sub-buttons if registered
    if isRegistered and module.features then
        local groups = self:GetFeatureGroups(module.features)
        
        -- Only create and account for space if module is expanded
        if self.expandedModules[moduleID] then
            -- Sort groups by highest feature priority (descending)
            local sortedGroupNames = {}
            for groupName in pairs(groups) do
                sortedGroupNames[#sortedGroupNames + 1] = groupName
            end
            table.sort(sortedGroupNames, function(a, b)
                local pa = groups[a][1] and groups[a][1].priority or 0
                local pb = groups[b][1] and groups[b][1].priority or 0
                return pa > pb
            end)

            for _, groupName in ipairs(sortedGroupNames) do
                local features = groups[groupName]
                local groupBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
                groupBtn:SetSize(btnWidth - 20, btnHeight - 5)
                groupBtn:SetPoint("TOPLEFT", 10, yOffset)
                groupBtn:SetText("  " .. groupName)
                groupBtn:Show()
                
                groupBtn:SetScript("OnClick", function()
                    UI:ScrollToFeatureGroup(moduleID, groupName, features)
                end)
                
                table.insert(container.featureGroups, groupBtn)
                -- Only adjust yOffset when expanded!
                yOffset = yOffset - (btnHeight - 5) - spacing
            end
        end
    end
    
    return yOffset
end

---@class PrephsFramework.UI.FeatureGroupEntry
---@field name string Feature name key
---@field config ModuleFeatureConfig Feature configuration
---@field priority number Sort priority (higher = first)

---@param features table<string, ModuleFeatureConfig>
---@return table<string, PrephsFramework.UI.FeatureGroupEntry[]>
function UI:GetFeatureGroups(features)
    local groups = {}
    
    for featureName, featureConfig in pairs(features) do
        local groupName = featureConfig.uiGroup or "General"
        
        if not groups[groupName] then
            groups[groupName] = {}
        end
        
        table.insert(groups[groupName], {
            name = featureName,
            config = featureConfig,
            priority = featureConfig.priority or 0
        })
    end
    
    -- Sort features within each group by priority
    for groupName, features in pairs(groups) do
        table.sort(features, function(a, b)
            return a.priority > b.priority
        end)
    end
    
    return groups
end

function UI:ClearContent()
    if not self.ScrollChild then return end
    
    -- Release all pooled frames
    if self.Factory then
        self.Factory:ReleaseAllFrames()
    end
    
    -- Clean up any non-pooled managed frames (EditableList, CheckboxGroup, etc.)
    local children = {self.ScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        if child.inUse and child.frameType then
            child:Hide()
            child:ClearAllPoints()
            -- Recursively hide subframes
            local subChildren = {child:GetChildren()}
            for _, sub in ipairs(subChildren) do
                sub:Hide()
                sub:ClearAllPoints()
                sub:SetParent(nil)
            end
            child:SetParent(nil)
        end
    end
    
    -- Clean up managed font strings (labels)
    local regions = {self.ScrollChild:GetRegions()}
    for _, region in ipairs(regions) do
        if region.inUse then
            region:Hide()
            region:SetParent(nil)
        end
    end
    
    -- Reset sequence counter
    self.elementSequence = 0
end

---@param moduleID moduleID
---@param moduleName string Display name shown as placeholder title
function UI:ShowModulePlaceholder(moduleID, moduleName)
    self:ClearContent()
    self.currentPage = "module_placeholder_" .. moduleID
    
    local Factory = self.Factory
    local content = self.ScrollChild
    local yOffset = -10
    
    -- Title
    local title = Factory:CreateLabel(content, moduleName, "GameFontNormalLarge")
    if not title then return end
    title:SetPoint("TOPLEFT", 10, yOffset)
    yOffset = yOffset - 40
    
    -- Message
    local msg = Factory:CreateLabel(content, "|cffFFFF00This module has not registered its features yet.|r\n\nThe module may need to be loaded or may not have any configurable features.", "GameFontNormal")
    if not msg then return end
    msg:SetPoint("TOPLEFT", 10, yOffset)
    msg:SetWidth(600)
    
    if not content then return end
    content:SetHeight(math.abs(yOffset) + 150)
end

