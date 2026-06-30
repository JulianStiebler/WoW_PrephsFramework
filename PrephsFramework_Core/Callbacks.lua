--[[
    <PrephsFramework_Core/Callbacks.lua>
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

---@class PrephsFramework.Logger
local logger = Core.Logger


local type = type
local hooksecurefunc = hooksecurefunc
local pcall = pcall
local tostring = tostring
local pairs = pairs


local invokeHook
if Core.DEV.pcalls then
    invokeHook = function(callback, hookID, modId, ...)
        local success, err = pcall(callback, ...)
        if not success then
            logger:error("Hook '%s' in '%s' failed: %s", hookID, modId, tostring(err))
        end
    end
else
    invokeHook = function(callback, _, _, ...)
        callback(...)
    end
end

-- Registry of hook installers: callbackName -> { install = func, installed = bool }
local HookInstallers = {}

--- Define a hook type that auto-installs when first listener registers.
--- The install function is called once and should set up whatever hooks are
--- needed (frame scripts, hooksecurefunc, event registration, etc.) and
--- fire callbacks via Core.callbacks:Fire(callbackName, ...).
---
---@param callbackName string The callback name to associate with this hook
---@param installFunc fun() Function that installs the underlying hook
function Core:DefineHookType(callbackName, installFunc)
    if not callbackName or not installFunc then
        logger:error("DefineHookType requires callbackName and installFunc")
        return false
    end
    
    if HookInstallers[callbackName] then
        logger:warning("Hook type '%s' already defined (overwriting)", callbackName)
    end
    
    HookInstallers[callbackName] = {
        install = installFunc,
        installed = false,
    }
    
    return true
end

--- Register a callback, auto-installing the hook system if one is defined.
--- This wraps CallbackHandler's RegisterCallback to add hook auto-install.
---
--- Usage:
---   Core:RegisterHook(myTable, "OnTooltipSetItem", function(event, tooltip, link, name) ... end)
---   Core:RegisterHook(myTable, "OnTooltipSetItem", "MyMethod")  -- calls myTable:MyMethod(event, ...)
---
---@param target table The object registering (used as key for unregister)
---@param callbackName string The callback/hook name
---@param method function|string Callback function or method name on target
function Core:RegisterHook(target, callbackName, method)
    if not target or not callbackName then
        logger:error("RegisterHook called with invalid parameters")
        return false
    end
    
    -- Auto-install hook system if one is defined for this callback name
    local installer = HookInstallers[callbackName]
    if installer and not installer.installed then
        installer.install()
        installer.installed = true
    end
    
    -- Delegate to CallbackHandler
    Core.Callbacks:RegisterCallback(target, callbackName, method)
    
    return true
end

--- Unregister a hook callback.
---@param target table The object that registered
---@param callbackName string The callback/hook name
function Core:UnregisterHook(target, callbackName)
    if not target or not callbackName then
        return false
    end
    
    Core.Callbacks:UnregisterCallback(target, callbackName)
    return true
end

--- Unregister all hooks for a target.
---@param target table The object that registered
function Core:UnregisterAllHooks(target)
    if not target then return false end
    Core.Callbacks:UnregisterAllCallbacks(target)
    return true
end

-- ============================================================================
-- Flexible Hook System (Frame Scripts, hooksecurefunc)
-- ============================================================================
-- For features that need to hook specific frames or global functions
-- at activation time and "unhook" at deactivation time.
--
-- Note: WoW's HookScript and hooksecurefunc cannot truly be unhooked.
-- Instead we use a guard flag to disable the callback.
-- ============================================================================

--- Track flexible hooks: { [modId] = { [hookID] = { active = bool, ... } } }
---@type table<string, table<string, FlexibleHookEntry>>
local FlexibleHooks = {}

---@class FlexibleHookEntry
---@field active boolean Whether the hook is currently enabled (guard flag)
---@field type "script"|"function"|"secure"|"method" Hook type

---@param modId string Registration key (e.g. "MyModule:FeatureName")
---@param hookID string Unique identifier for this hook within the module
---@param hookConfig FlexibleHookConfig
---@return boolean success
function Core:RegisterFlexibleHook(modId, hookID, hookConfig)
    if not modId or not hookID or not hookConfig then
        logger:error("RegisterFlexibleHook called with invalid parameters")
        return false
    end
    
    if not FlexibleHooks[modId] then
        FlexibleHooks[modId] = {}
    end
    
    -- If already registered (re-activation), just set active
    if FlexibleHooks[modId][hookID] then
        FlexibleHooks[modId][hookID].active = true
        return true
    end
    
    local hookType = hookConfig.type
    local entry = { active = true, type = hookType }
    
    if hookType == "script" then
        local frame = hookConfig.frame
        if type(frame) == "string" then
            frame = _G[frame]
        end
        
        if not frame then
            logger:error("Frame not found for hook '%s' in '%s'", hookID, modId)
            return false
        end
        
        -- HookScript with guard
        frame:HookScript(hookConfig.script, function(...)
            if entry.active then
                invokeHook(hookConfig.callback, hookID, modId, ...)
            end
        end)
        
    elseif hookType == "function" or hookType == "secure" then
        local funcName = hookConfig.func
        if type(funcName) ~= "string" or not _G[funcName] then
            logger:error("Function '%s' not found for hook '%s' in '%s'", tostring(funcName), hookID, modId)
            return false
        end
        
        hooksecurefunc(funcName, function(...)
            if entry.active then
                invokeHook(hookConfig.callback, hookID, modId, ...)
            end
        end)

    elseif hookType == "method" then
        local tbl = hookConfig.table
        local method = hookConfig.method
        if type(tbl) ~= "table" or type(method) ~= "string" or not tbl[method] then
            logger:error("Table method '%s' not found for hook '%s' in '%s'", tostring(method), hookID, modId)
            return false
        end

        hooksecurefunc(tbl, method, function(...)
            if entry.active then
                invokeHook(hookConfig.callback, hookID, modId, ...)
            end
        end)
        
    else
        logger:error("Unknown hook type '%s' for hook '%s' in '%s'", tostring(hookType), hookID, modId)
        return false
    end
    
    FlexibleHooks[modId][hookID] = entry
    return true
end

---@param modId string Registration key
---@param hookID string Hook identifier to deactivate
---@return boolean success
function Core:UnregisterFlexibleHook(modId, hookID)
    if not modId or not hookID then return false end
    if not FlexibleHooks[modId] or not FlexibleHooks[modId][hookID] then return false end
    
    -- Deactivate the guard flag (hook remains installed but does nothing)
    FlexibleHooks[modId][hookID].active = false
    return true
end

---@param modId string Registration key
---@return number count Number of hooks deactivated
function Core:UnregisterAllFlexibleHooks(modId)
    if not modId or not FlexibleHooks[modId] then return 0 end
    
    local count = 0
    for hookID, entry in pairs(FlexibleHooks[modId]) do
        if entry.active then
            entry.active = false
            count = count + 1
        end
    end
    
    return count
end

---@param modId string Registration key to fully clean up
function Core:CleanupModuleCallbacks(modId)
    if not modId then return end
    
    local cleaned = 0
    
    -- Clean up WoW events
    cleaned = cleaned + (self:UnregisterAllEvents(modId) or 0)
    
    -- Clean up flexible hooks
    cleaned = cleaned + (self:UnregisterAllFlexibleHooks(modId) or 0)
    
    -- Note: CallbackHandler callbacks keyed by modId string won't auto-clean.
    -- Features should use a table as the registration key for proper cleanup.
    
    if cleaned > 0 then
        logger:debug("Cleaned up %d registrations for '%s'", cleaned, modId)
    end
end