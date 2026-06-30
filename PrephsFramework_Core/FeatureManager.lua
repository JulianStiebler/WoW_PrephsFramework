--[[
    <PrephsFramework_Core/FeatureManager.lua>
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

---@type PrephsFramework.Logger
local logger = Core.Logger

local invokeCallback
if Core.DEV.pcalls then
    invokeCallback = function(callback, context, ...)
        local success, err = pcall(callback, ...)
        if not success then
            logger:error("Callback failed for %s: %s", context, err)
        end
    end
else
    invokeCallback = function(callback, _, ...)
        callback(...)
    end
end

local pairs = pairs
local CreateFrame = CreateFrame
local ipairs = ipairs
local type = type
local States = Core.States
-- ============================================================================
-- Feature State Evaluation
-- ============================================================================

-- Check if a feature is suppressed based on current player state
---@param moduleID string
---@param featureName string
function Core:IsFeatureSuppressed(moduleID, featureName)
    local moduleDB = self:GetModuleDB(moduleID)
    if not moduleDB or not moduleDB.features[featureName] then
        return false
    end
    
    local featureDB = moduleDB.features[featureName]


    -- Check raid suppression
    if featureDB._suppressInRaid and States.inRaid then
        return true
    end
    
    -- Check group suppression
    if featureDB._suppressInGroup and States.inGroup then
        return true
    end
    
    -- Check instance suppression
    if featureDB._suppressInInstance and States.inInstance then
        return true
    end
    
    -- Check zone suppression
    if featureDB._suppressInZones then
        if States.uiMapID and featureDB._suppressInZones[States.uiMapID] then
            return true
        end
    end
    
    return false
end

---@param moduleID string
---@param featureName string
---@return boolean shouldBeActive
function Core:ShouldFeatureBeActive(moduleID, featureName)
    local moduleDB = self:GetModuleDB(moduleID)
    if not moduleDB or not moduleDB.features[featureName] then
        return false
    end
    
    local featureDB = moduleDB.features[featureName]
    
    -- Feature must be enabled
    if not featureDB.enabled then
        return false
    end
    
    -- Feature must not be suppressed
    if self:IsFeatureSuppressed(moduleID, featureName) then
        return false
    end
    
    return true
end

-- ============================================================================
-- Feature Activation/Deactivation
-- ============================================================================

---@param moduleID string
---@param featureName string
---@param featureConfig ModuleFeatureConfig
---@return boolean success
function Core:ActivateFeature(moduleID, featureName, featureConfig)
    local trackingKey = moduleID .. ":" .. featureName
    
    -- Check if already active
    if self.ActiveFeatures[trackingKey] then
        return true
    end
    
    -- Register events
    if featureConfig.events then
        for eventName, eventData in pairs(featureConfig.events) do
            local callback, options, filters
            
            if type(eventData) == "function" then
                callback = eventData
                options = nil
                filters = nil
            elseif type(eventData) == "table" then
                callback = eventData.callback
                options = eventData.options
                filters = eventData.filters
            end
            
            -- Only register if we have valid callback data
            if callback then
                -- Check if this is a Combat Log event
                if Core:IsCombatLogSubevent(eventName) then
                    self:RegisterCombatLogEvent(trackingKey, eventName, callback, options, filters)
                else
                    self:RegisterEvent(trackingKey, eventName, callback, options, filters)
                end
            else
                logger:error("Invalid event data for %s in %s", eventName, trackingKey)
            end
        end
    end
    
    -- Register hooks
    if featureConfig.hooks then
        -- Check if hooks is an array (flexible hooks) or table (callback hooks)
        if #featureConfig.hooks > 0 then
            -- Array format: flexible hooks (frame scripts, hooksecurefunc)
            for _, hookConfig in ipairs(featureConfig.hooks) do
                local hookID = hookConfig.id or (hookConfig.type .. "_" .. (hookConfig.func or hookConfig.script or "unknown"))
                self:RegisterFlexibleHook(trackingKey, hookID, hookConfig)
            end
        else
            -- Table format: callback-based hooks (via CallbackHandler)
            -- Create a unique registration table for this feature's hooks
            local hookTarget = { _hookOwner = trackingKey }
            
            for hookName, hookData in pairs(featureConfig.hooks) do
                local callback
                if type(hookData) == "function" then
                    callback = hookData
                elseif type(hookData) == "table" then
                    callback = hookData.callback
                end
                
                if callback then
                    Core:RegisterHook(hookTarget, hookName, function(event, ...)
                        callback(...)
                    end)
                end
            end
            
            -- Store hook target for cleanup
            self.ActiveFeatures[trackingKey] = self.ActiveFeatures[trackingKey] or {}
            self.ActiveFeatures[trackingKey]._hookTarget = hookTarget
        end
    end
    
    -- Mark as active
    self.ActiveFeatures[trackingKey] = {
        moduleID = moduleID,
        featureName = featureName,
        config = featureConfig
    }
    
    return true
end

---@param moduleID string
---@param featureName string
---@param featureConfig ModuleFeatureConfig
---@return boolean success
function Core:DeactivateFeature(moduleID, featureName, featureConfig)
    local trackingKey = moduleID .. ":" .. featureName
    
    -- Check if not active
    if not self.ActiveFeatures[trackingKey] then
        return true
    end
    
    -- Unregister events
    if featureConfig.events then
        for eventName, eventData in pairs(featureConfig.events) do
            if Core:IsCombatLogSubevent(eventName) then
                self:UnregisterCombatLogEvent(trackingKey, eventName)
            else
                self:UnregisterEvent(trackingKey, eventName)
            end
        end
    end
    
    -- Unregister hooks
    if featureConfig.hooks then
        if #featureConfig.hooks > 0 then
            -- Array format: flexible hooks
            for _, hookConfig in ipairs(featureConfig.hooks) do
                local hookID = hookConfig.id or (hookConfig.type .. "_" .. (hookConfig.func or hookConfig.script or "unknown"))
                self:UnregisterFlexibleHook(trackingKey, hookID)
            end
        else
            -- Table format: callback-based hooks - unregister via stored target
            local activeData = self.ActiveFeatures[trackingKey]
            if activeData and activeData._hookTarget then
                Core.Callbacks:UnregisterAllCallbacks(activeData._hookTarget)
            end
        end
    end
    
    -- Mark as inactive
    self.ActiveFeatures[trackingKey] = nil
    
    return true
end

-- ============================================================================
-- Feature State Change Handler
-- ============================================================================

---@param moduleID string
---@param featureName string
---@param enabled boolean
function Core:OnFeatureStateChanged(moduleID, featureName, enabled)
    local module = self.RegisteredModules[moduleID]
    if not module then return end
    
    local featureConfig = module.features[featureName]
    if not featureConfig then return end
    
    if enabled then
        -- Check if should be active (not suppressed)
        if self:ShouldFeatureBeActive(moduleID, featureName) then
            self:ActivateFeature(moduleID, featureName, featureConfig)
        end
    else
        self:DeactivateFeature(moduleID, featureName, featureConfig)
    end
    
    -- Re-evaluate Indexer need after feature state change
    self:EvaluateIndexer()
    
    -- Fire module callback
    if module.callbacks.OnFeatureStateChanged then
        invokeCallback(module.callbacks.OnFeatureStateChanged, moduleID, featureName, enabled)
    end
end

-- ============================================================================
-- Suppression Change Handler
-- ============================================================================

---@param moduleID string
---@param featureName string
function Core:OnSuppressionChanged(moduleID, featureName)
    local module = self.RegisteredModules[moduleID]
    if not module then return end
    
    local featureConfig = module.features[featureName]
    if not featureConfig then return end
    
    local moduleDB = self:GetModuleDB(moduleID)
    if not moduleDB or not moduleDB.features[featureName] then return end
    
    local featureDB = moduleDB.features[featureName]
    
    -- Only matters if feature is enabled
    if not featureDB.enabled then return end
    
    -- Check if should be active now
    local shouldBeActive = self:ShouldFeatureBeActive(moduleID, featureName)
    local trackingKey = moduleID .. ":" .. featureName
    local isActive = self.ActiveFeatures[trackingKey] ~= nil
    
    if shouldBeActive and not isActive then
        self:ActivateFeature(moduleID, featureName, featureConfig)
    elseif not shouldBeActive and isActive then
        self:DeactivateFeature(moduleID, featureName, featureConfig)
    end

    -- Re-evaluate Indexer need after suppression change
    self:EvaluateIndexer()
end

-- ============================================================================
-- Zone/Group Change Monitoring
-- ============================================================================

local MonitorFrame = CreateFrame("Frame")

local function OnPlayerStateChanged()
    -- Re-evaluate all active features for suppression
    for moduleID, module in pairs(Core.RegisteredModules) do
        for featureName, featureConfig in pairs(module.features) do
            Core:OnSuppressionChanged(moduleID, featureName)
        end
    end
end

MonitorFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MonitorFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
MonitorFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

MonitorFrame:SetScript("OnEvent", function(self, event, ...)
    OnPlayerStateChanged()
end)

-- ============================================================================
-- Indexer Lifecycle — activate / deactivate based on module demand
-- ============================================================================

--- Checks whether any registered module that declared `needIndexer = true`
--- still has at least one active feature.  Activates or deactivates the
--- Indexer accordingly.
function Core:EvaluateIndexer()
    local needed = false
    for moduleID, module in pairs(self.RegisteredModules) do
        if module.needIndexer then
            for featureName in pairs(module.features) do
                local trackingKey = moduleID .. ":" .. featureName
                if self.ActiveFeatures[trackingKey] then
                    needed = true
                    break
                end
            end
            if needed then break end
        end
    end

    if needed and not self.Indexer:IsActive() then
        self.Indexer:Activate()
    elseif not needed and self.Indexer:IsActive() then
        self.Indexer:Deactivate()
    end
end

-- ============================================================================
-- Initialize All Features for a Module
-- ============================================================================

---@param moduleID string
---@return boolean success
function Core:InitializeModuleFeatures(moduleID)
    local module = self.RegisteredModules[moduleID]
    if not module then return false end
    
    local moduleDB = self:GetModuleDB(moduleID)
    if not moduleDB then return false end
    
    -- Initialize database defaults
    self:InitializeModuleDB(moduleID, module)
    
    -- Activate enabled features
    for featureName, featureConfig in pairs(module.features) do
        if self:ShouldFeatureBeActive(moduleID, featureName) then
            self:ActivateFeature(moduleID, featureName, featureConfig)
        end
    end
    
    return true
end

-- ============================================================================
-- Utility Functions
-- ============================================================================

---@return table<string, ActiveFeatureEntry>
function Core:GetActiveFeatures()
    return self.ActiveFeatures
end
