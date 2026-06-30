--[[
    <PrephsFramework_Core/Profiling.lua>
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

---@class PrephsFramework.Profiling
Core.Profiling = {}

local logger = Core.Logger

--- Active profiling timers tracking start times
---@type table<string, number>
local activeTimers = {}

local debugprofilestop = debugprofilestop
local unpack = unpack

--- Start a profiling timer
---@param name string Unique identifier for the timer
---@return number startTime The start time in milliseconds
function Core.Profiling:Start(name)
    local startTime = debugprofilestop()
    activeTimers[name] = startTime
    return startTime
end

--- Stop a profiling timer and return elapsed time
---@param name string Timer identifier
---@param printResult? boolean Whether to print the result (default: false)
---@return number|nil elapsed Elapsed time in milliseconds, or nil if timer not found
function Core.Profiling:Stop(name, printResult)
    local startTime = activeTimers[name]
    if not startTime then
        logger:profiling("Timer '%s' not found", name)
        return nil
    end
    
    local elapsed = debugprofilestop() - startTime
    activeTimers[name] = nil
    
    if printResult then
        logger:profiling("Timer '%s' took %.3f ms", name, elapsed)
    end
    
    return elapsed
end

--- Profile a function execution
---@param name string Identifier for the profiling session
---@param func function Function to profile
---@param printResult? boolean Whether to print the result (default: true)
---@return any ... Function return values
function Core.Profiling:Profile(name, func, printResult)
    if printResult == nil then printResult = true end
    
    local startTime = debugprofilestop()
    local results = {func()}
    local elapsed = debugprofilestop() - startTime
    
    if printResult then
        logger:profiling("Function '%s' took %.3f ms", name, elapsed)
    end
    
    return unpack(results)
end

--- Wrap a function with automatic profiling
---@param name string Identifier for the function
---@param func function Function to wrap
---@param printResult? boolean Whether to print results on each call (default: false)
---@return function wrappedFunc The wrapped function
function Core.Profiling:Wrap(name, func, printResult)
    return function(...)
        local startTime = debugprofilestop()
        local results = {func(...)}
        local elapsed = debugprofilestop() - startTime
        
        if printResult then
            logger:profiling("Wrapped function '%s' took %.3f ms", name, elapsed)
        end
        
        return unpack(results)
    end
end

--- Clear all active timers
function Core.Profiling:Clear()
    activeTimers = {}
end