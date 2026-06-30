--[[
    <PrephsFramework_Core/UI/UI_ModulePages.lua>
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

---@class PrephsFramework
local Core = ns.PF
---@class PrephsFramework.UI
local UI = Core.UI
---@class PrephsFramework.UI.Factory
local Factory = UI.Factory

---@type PrephsFramework.Logger
local logger = Core.Logger

local ipairs = ipairs
local pairs = pairs
local C_Timer = C_Timer

---@class PrephsFramework.SystemPage
---@field moduleName string Display name for the page
---@field features PrephsFramework.SystemPageFeature[] Feature sections on the page

---@class PrephsFramework.SystemPageFeature
---@field name string Section header text
---@field description string? Description shown below header
---@field elements UIElement[] UI elements to render
---@field showSeparator boolean? Whether to show separator after section

---@param moduleID moduleID
function UI:ShowModulePage(moduleID)
    self:ClearContent()
    self.currentPage = "module_" .. moduleID
    
    -- Close any open suppression popup when changing pages
    if self.currentSuppressionPopup and self.currentSuppressionPopup:IsShown() then
        self.currentSuppressionPopup:Hide()
    end
    
    local module = Core.RegisteredModules[moduleID]
    local wasLoaded = false
    
    -- If module not registered, try to load it first
    if not module then
        local moduleData = Core.DiscoveredModules[moduleID]
        if moduleData and not moduleData.loaded then
            -- Module exists but not loaded - load it now
            local success = Core:LoadModule(moduleID)
            if success then
                -- Check if it's registered now
                module = Core.RegisteredModules[moduleID]
                if module then
                    wasLoaded = true
                end
            end
        end
    end
    
    -- If still not registered, show placeholder
    if not module then
        local moduleData = Core.DiscoveredModules[moduleID]
        local displayName = (moduleData and moduleData.displayName) or moduleID
        self:ShowModulePlaceholder(moduleID, displayName)
        return
    end
    
    -- Refresh sidebar if module was just loaded
    if wasLoaded then
        self:RebuildSidebar()
    end
    
    local content = self.ScrollChild
    local moduleData = Core.DiscoveredModules[moduleID]
    local moduleDB = Core:GetModuleDB(moduleID)
    
    -- Title (use displayName which supports spaces)
    local title = Factory:CreateLabel(content, moduleData.displayName or moduleData.title or moduleID, "GameFontNormalLarge")
    if title then title:Show() end
    
    -- Version
    if moduleData.version then
        local version = Factory:CreateLabel(content, "Version: " .. moduleData.version, "GameFontNormalSmall", {0.7, 0.7, 0.7})
        if version then version:Show() end
    end
    
    -- Render features by group (sorted by highest feature priority in each group)
    local groups = self:GetFeatureGroups(module.features)
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
        -- Group header
        local groupHeader = Factory:CreateLabel(content, "|cff3FC7EB" .. groupName .. "|r", "GameFontNormal")
        groupHeader.layoutOffset = -20
        groupHeader.groupName = groupName  -- Store group name for scrolling
        if groupHeader then groupHeader:Show() end
        
        -- Render each feature in the group
        for _, featureData in ipairs(features) do
            self:RenderFeature(content, moduleID, featureData.name, featureData.config, moduleDB)
        end
    end
    
    self:RefreshLayout()
end

---@param moduleID moduleID
---@param groupName string Feature group name to scroll to
---@param features PrephsFramework.UI.FeatureGroupEntry[]
function UI:ScrollToFeatureGroup(moduleID, groupName, features)
    -- First, show the full module page
    self:ShowModulePage(moduleID)
    
    -- After one frame, scroll to the group header.
    -- Group headers are FontStrings (regions), not Frames (children),
    -- so we must search GetRegions() to find them.
    C_Timer.After(0.05, function()
        if not self.ScrollChild or not self.ScrollFrame then return end
        
        -- Find the group header among regions (FontStrings created by CreateLabel)
        local regions = {self.ScrollChild:GetRegions()}
        for _, region in ipairs(regions) do
            if region.IsShown and region:IsShown() and region.inUse and region.groupName == groupName then
                local childTop = region:GetTop()
                local parentTop = self.ScrollChild:GetTop()
                
                if childTop and parentTop then
                    local offset = parentTop - childTop
                    self.ScrollFrame:SetVerticalScroll(math.max(0, offset))
                end
                return
            end
        end

        -- Fallback: also check child frames in case the header is a Frame
        local children = {self.ScrollChild:GetChildren()}
        for _, child in ipairs(children) do
            if child:IsShown() and child.inUse and child.groupName == groupName then
                local childTop = child:GetTop()
                local parentTop = self.ScrollChild:GetTop()
                
                if childTop and parentTop then
                    local offset = parentTop - childTop
                    self.ScrollFrame:SetVerticalScroll(math.max(0, offset))
                end
                return
            end
        end
    end)
end

---@param parent Frame Parent frame for the feature widgets
---@param moduleID moduleID
---@param featureName string
---@param featureConfig ModuleFeatureConfig
---@param moduleDB table Module database table
function UI:RenderFeature(parent, moduleID, featureName, featureConfig, moduleDB)
    local featureDB = moduleDB.features[featureName]
    
    -- Feature name label
    local nameLabel = Factory:CreateLabel(parent, featureConfig.name or featureName, "GameFontNormal")
    if nameLabel then nameLabel:Show() end
    
    -- Main feature toggle with optional cog for suppression
    if featureConfig.suppressionFlags then
        local checkbox = Factory:CreateCheckboxWithCog(
            parent,
            (featureConfig.name or featureName),
            featureDB.enabled,
            function(checked)
                featureDB.enabled = checked
                Core:OnFeatureStateChanged(moduleID, featureName, checked)
                -- Refresh the page to show/hide UI elements
                C_Timer.After(0.01, function()
                    UI:ShowModulePage(moduleID)
                end)
            end,
            function(frame, cogBtn)
                -- Check if we already have a popup open for this cog button
                if UI.currentSuppressionPopup and UI.currentSuppressionPopup:IsShown() and UI.currentSuppressionPopup.cogBtn == cogBtn then
                    -- Same cog clicked - just close the popup
                    UI.currentSuppressionPopup:Hide()
                    return
                end
                
                -- Create/show suppression popup
                local popup = Factory:CreateSuppressionPopup(
                    cogBtn,
                    moduleID,
                    featureName,
                    featureConfig.suppressionFlags,
                    featureDB
                )
                
                -- Store which cog this popup belongs to
                popup.cogBtn = cogBtn
                popup:Show()
            end
        )
        if checkbox then checkbox:Show() end
    else
        local checkbox = Factory:CreateCheckbox(
            parent,
            "Enable " .. (featureConfig.name or featureName),
            featureDB.enabled,
            function(checked)
                featureDB.enabled = checked
                Core:OnFeatureStateChanged(moduleID, featureName, checked)
                -- Refresh the page to show/hide UI elements
                C_Timer.After(0.01, function()
                    UI:ShowModulePage(moduleID)
                end)
            end
        )
        checkbox.layoutOffset = -5
        if checkbox then checkbox:Show() end
    end
    
    -- Render UI elements if feature is enabled
    if featureDB.enabled and featureConfig.uiElements then
        for i, element in ipairs(featureConfig.uiElements) do
            local widget = self:RenderUIElement(parent, moduleID, featureName, element, featureDB)
            -- Add extra spacing after the last element
            if i == #featureConfig.uiElements and widget then
                widget.layoutOffset = -10
            end
        end
    end

    -- Call AfterInitialize if provided (after uiElements, for custom dynamic content)
    if featureDB.enabled and featureConfig.AfterInitialize then
        local success, err = pcall(featureConfig.AfterInitialize, parent, moduleID, featureName)
        if not success then
            logger:error("Feature AfterInitialize failed for %s:%s: %s", moduleID, featureName, tostring(err))
        end
    end

    if featureConfig.showSeparator then
        local sep = Factory:CreateSeparator(parent)
        if sep then sep:Show() end
    end
end

---@param parent Frame Parent frame for the element widget
---@param moduleID moduleID
---@param featureName string
---@param element UIElement
---@param featureDB table Feature database table
---@return ManagedFrame|ManagedFontString|nil
function UI:RenderUIElement(parent, moduleID, featureName, element, featureDB)
    -- ColorPicker with split-key storage needs special wrapping for backward compat
    if element.type == "ColorPicker" and not element.get and not element.set and element.key then
        local wrappedElement = {}
        for k, v in pairs(element) do wrappedElement[k] = v end
        wrappedElement.get = function()
            return featureDB[element.key .. "_r"] or 1,
                   featureDB[element.key .. "_g"] or 1,
                   featureDB[element.key .. "_b"] or 1
        end
        wrappedElement.set = function(newR, newG, newB)
            featureDB[element.key .. "_r"] = newR
            featureDB[element.key .. "_g"] = newG
            featureDB[element.key .. "_b"] = newB
            Core:SetSetting(moduleID, featureName, element.key .. "_r", newR)
            Core:SetSetting(moduleID, featureName, element.key .. "_g", newG)
            Core:SetSetting(moduleID, featureName, element.key .. "_b", newB)
        end
        return Factory:RenderElement(parent, wrappedElement, featureDB)
    end

    -- All other types: delegate with a persistFn that calls Core:SetSetting
    local function persistFn(key, value)
        Core:SetSetting(moduleID, featureName, key, value)
    end

    return Factory:RenderElement(parent, element, featureDB, persistFn)
end

---@param pageID string System page identifier (e.g. "general", "info")
function UI:RenderSystemPage(pageID)
    self:ClearContent()
    self.currentPage = "system_" .. pageID
    
    -- Close any open suppression popup when changing pages
    if self.currentSuppressionPopup and self.currentSuppressionPopup:IsShown() then
        self.currentSuppressionPopup:Hide()
    end
    
    local pageData = Core.SystemPages[pageID]
    if not pageData then
        logger:error("System page not found: %s", pageID)
        return
    end
    
    local content = self.ScrollChild
    
    -- Title
    local title = Factory:CreateLabel(content, pageData.moduleName or pageID, "GameFontNormalLarge")
    title.layoutOffset = -20
    if title then title:Show() end
    
    -- Render features
    for i, feature in ipairs(pageData.features) do
        -- Feature name
        local nameLabel = Factory:CreateLabel(content, "|cff3FC7EB" .. feature.name .. "|r", "GameFontNormal")
        if nameLabel then nameLabel:Show() end
        
        -- Feature description
        if feature.description then
            local desc = Factory:CreateLabel(content, feature.description, "GameFontNormalSmall", {0.7, 0.7, 0.7})
            desc.layoutOffset = -5
            if desc then desc:Show() end
        end
        
        -- Render elements
        local lastWidget = nil
        if feature.elements then
            for j, element in ipairs(feature.elements) do
                if element.type == "Spacer" then
                    if lastWidget then
                        lastWidget.layoutOffset = -(element.height or 10)
                    end
                else
                    lastWidget = Factory:RenderElement(content, element)
                end
            end
        end
        
        -- Add extra spacing after feature if not the last one
        if i < #pageData.features and lastWidget then
            lastWidget.layoutOffset = -15
        end

        if feature.showSeparator then
            local sep = Factory:CreateSeparator(content)
            if sep then sep:Show() end
        end
    end
    
    self:RefreshLayout()
end