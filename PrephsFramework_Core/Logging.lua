--[[
    <PrephsFramework_Core/Logging.lua>
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
-- PrephsFramework Logging Library
-- Standalone LibStub library that embeds into target objects
-- Usage: LibStub("PrephsFramework-Logger-1.0"):Embed(target, prefix)

local MAJOR, MINOR = "PrephsFramework-Logger-1.0", 1
local LoggerLib = LibStub:NewLibrary(MAJOR, MINOR)
if not LoggerLib then return end

-- Mage blue color for Preph prefix
local PREFIX_COLOR = "|cff3FC7EB"
local COLOR_RESET = "|r"

-- Localize for performance
local format = string.format
local select = select
local tostring = tostring
local type = type
local bit_band = bit.band
local bit_bor = bit.bor
local pairs = pairs
local pcall = pcall
local concat = table.concat
local print = print
local bit = bit

-- Noop function for disabled log levels (zero overhead)
local function noop() end

-- Log level definitions with bitmasks, colors, and labels
---@class LogLevelDefinition
---@field mask Bitmask The bitmask value
---@field color string The WoW color code
---@field label string The display label


---@type table<PrephsFramework.LogLevels, LogLevelDefinition>
local LogLevel = {
    -- CATEGORIES (Bits 0-9)
    FEATURES     = { mask = 0x00000001, color = "|cFF00FF00", label = "FEATURES" },
    EVENTS       = { mask = 0x00000002, color = "|cFF00FF00", label = "EVENTS" },
    INIT         = { mask = 0x00000004, color = "|cFF00FF00", label = "INIT" },
    PROFILING    = { mask = 0x00000008, color = "|cFF00FF00", label = "PROFILING" },
    CLEANUP      = { mask = 0x00000010, color = "|cFF00FF00", label = "CLEANUP" },
    COMMLINK     = { mask = 0x00000020, color = "|cFF00FF00", label = "COMMLINK" },


    -- SEVERITIES (Bits 10-16)
    ERROR        = { mask = 0x00000400, color = "|cFFFF0000", label = "ERROR" },
    WARNING      = { mask = 0x00000800, color = "|cFFFFFF00", label = "WARNING" },
    INFO         = { mask = 0x00001000, color = "|cFF00FF00", label = "INFO" },
    DEBUG        = { mask = 0x00002000, color = "|cFF00FFFF", label = "DEBUG" },
    TRACE        = { mask = 0x00004000, color = "|cFF888888", label = "TRACE" },
    FATAL        = { mask = 0x00008000, color = "|cFFFF00FF", label = "FATAL" },
}
local MINIMUM_MASK = bit_bor(LogLevel.ERROR.mask, LogLevel.WARNING.mask, LogLevel.TRACE.mask)

-- Build reverse lookup: mask -> definition (for fast logging)
local MaskToDefinition = {}
for _, def in pairs(LogLevel) do
    MaskToDefinition[def.mask] = def
end

-- Helper: Build message from varargs, handling format strings
local function buildMessage(...)
    local numArgs = select("#", ...)
    if numArgs == 0 then return "" end

    local firstArg = select(1, ...)

    -- Check if first arg is a format string (contains % formatters)
    if type(firstArg) == "string" and firstArg:find("%%") and numArgs > 1 then
        local success, result = pcall(format, ...)
        if success then
            return result
        else
            -- Fallback if format fails
            local parts = {}
            for i = 1, numArgs do
                parts[i] = tostring(select(i, ...))
            end
            return concat(parts, " ")
        end
    else
        if numArgs == 1 then
            return tostring(firstArg)
        end

        local parts = {}
        for i = 1, numArgs do
            parts[i] = tostring(select(i, ...))
        end
        return concat(parts, " ")
    end
end

-- Core logging function (no bitmask check - caller handles it)
local function wrap(text, color)
    if not text or text == "" then return "" end
    return color .. text .. "|r"
end

local function logMessage(level, prefix, ...)
    local def = MaskToDefinition[level]

    if not def then
        print(format("%s |cFFFF0000[LOGGER ERROR]:|r Unknown log level %s",
            wrap("[" .. prefix .. "]", PREFIX_COLOR), tostring(level)))
        return
    end

    local msg = buildMessage(...)
    local mainTag = wrap("[" .. prefix .. "]", PREFIX_COLOR)
    local levelLabel = wrap("[" .. def.label .. "]:", def.color)

    print(format("%s%s %s", mainTag, levelLabel, msg))
end


---@class PrephsFramework.LogLevels
---@field FEATURES  LogLevelDefinition
---@field EVENTS    LogLevelDefinition
---@field INIT      LogLevelDefinition
---@field PROFILING LogLevelDefinition
---@field CLEANUP   LogLevelDefinition
---@field COMMLINK   LogLevelDefinition
---@field ERROR     LogLevelDefinition
---@field WARNING   LogLevelDefinition
---@field INFO      LogLevelDefinition
---@field DEBUG     LogLevelDefinition
---@field TRACE     LogLevelDefinition
---@field FATAL     LogLevelDefinition
-- Mapping of method names to their bitmasks
local MethodToMask = {
    features = LogLevel.FEATURES.mask,
    events = LogLevel.EVENTS.mask,
    init      = LogLevel.INIT.mask,
    profiling = LogLevel.PROFILING.mask,
    cleanup   = LogLevel.CLEANUP.mask,
    commlink  = LogLevel.COMMLINK.mask,

    error = LogLevel.ERROR.mask,
    warning = LogLevel.WARNING.mask,
    info = LogLevel.INFO.mask,
    debug = LogLevel.DEBUG.mask,
    trace = LogLevel.TRACE.mask,
    fatal = LogLevel.FATAL.mask,
}

-- ============================================================================
-- Logger Embedding (CallbackHandler-style)
-- ============================================================================



---@class PrephsFramework.Logger
---@field features      fun(self: PrephsFramework.Logger, ...)                      Log at FEATURES level
---@field events        fun(self: PrephsFramework.Logger, ...)                      Log at EVENTS level
---@field init          fun(self: PrephsFramework.Logger, ...)                      Log at INIT level
---@field profiling     fun(self: PrephsFramework.Logger, ...)                      Log at PROFILING level
---@field cleanup       fun(self: PrephsFramework.Logger, ...)                      Log at CLEANUP level
---@field commlink      fun(self: PrephsFramework.Logger, ...)                      Log at COMMLINK level
---@field error         fun(self: PrephsFramework.Logger, ...)                      Log at ERROR level
---@field warning       fun(self: PrephsFramework.Logger, ...)                      Log at WARNING level
---@field info          fun(self: PrephsFramework.Logger, ...)                      Log at INFO level
---@field debug         fun(self: PrephsFramework.Logger, ...)                      Log at DEBUG level
---@field trace         fun(self: PrephsFramework.Logger, ...)                      Log at TRACE level
---@field fatal         fun(self: PrephsFramework.Logger, ...)                      Log at FATAL level
---@field SetLogMask    fun(self: PrephsFramework.Logger, mask: number)             Set the log mask
---@field IsEnabled     fun(self: PrephsFramework.Logger, level: number): boolean   Check if a log level is enabled
---@field EnableLevels  fun(self: PrephsFramework.Logger, ...)                      Enable specific log levels
---@field DisableLevels fun(self: PrephsFramework.Logger, ...)                      Disable specific log levels
---@field Print         fun(self: PrephsFramework.Logger, ...)                      Direct print without bitmask logic
---@field Log           fun(self: PrephsFramework.Logger, level: number, ...)       Generic log with bitmask check
---@field CreateLogger  fun(self: PrephsFramework.Logger, prefix?: string): PrephsFramework.Logger Create a new logger instance with custom prefix
---@field Initialize    fun(self: PrephsFramework.Logger)                           Initialize logger functions
---@field enabledMask number Current enabled log mask
---@field LogLevel      PrephsFramework.LogLevels
local loggerMixin = {}

--- Embed Logger functionality into a target object
---@param target table The target object to embed into
---@param prefix? string Optional prefix for log messages (defaults to target name)
---@return PrephsFramework.Logger target The target with logger methods embedded
function LoggerLib:Embed(target, prefix)
    prefix = prefix or "PrephsFramework"
    
    target.enabledMask = MINIMUM_MASK
    target.LogLevel = LogLevel  -- Expose LogLevel constants on target
    -- Build prefix-specific implementations
    local LogImplementations = {
        features  = function(self, ...) logMessage(LogLevel.FEATURES.mask, prefix, ...) end,
        events    = function(self, ...) logMessage(LogLevel.EVENTS.mask,   prefix, ...) end,
        init      = function(self, ...) logMessage(LogLevel.INFO.mask,     prefix, ...) end,
        profiling = function(self, ...) logMessage(LogLevel.PROFILING.mask,prefix, ...) end,
        cleanup   = function(self, ...) logMessage(LogLevel.INFO.mask,     prefix, ...) end,
        commlink  = function(self, ...) logMessage(LogLevel.COMMLINK.mask, prefix, ...) end,

        error     = function(self, ...) logMessage(LogLevel.ERROR.mask,    prefix, ...) end,
        warning   = function(self, ...) logMessage(LogLevel.WARNING.mask,  prefix, ...) end,
        info      = function(self, ...) logMessage(LogLevel.INFO.mask,     prefix, ...) end,
        debug     = function(self, ...) logMessage(LogLevel.DEBUG.mask,    prefix, ...) end,
        trace     = function(self, ...) logMessage(LogLevel.TRACE.mask,    prefix, ...) end,
        fatal     = function(self, ...) logMessage(LogLevel.FATAL.mask,    prefix, ...) end,
    }
    
    -- Function to rebuild logger methods based on mask
    local function rebuildLoggerFunctions()
        for methodName, mask in pairs(MethodToMask) do
            if bit_band(target.enabledMask, mask) ~= 0 then
                target[methodName] = LogImplementations[methodName]
            else
                target[methodName] = noop
            end
        end
    end
    
    -- Public API Methods
    
    function target:SetLogMask(mask)
        self.enabledMask = bit_bor(mask, MINIMUM_MASK)
        rebuildLoggerFunctions()
        
        -- Fire callback if available (for CallbackHandler integration)
        if self.Fire then
            self.Fire(self, "LogMaskChanged", mask)
        end
    end
    
    function target:IsEnabled(level)
        return bit_band(self.enabledMask, level) ~= 0
    end
    
    function target:EnableLevels(...)
        local mask = self.enabledMask
        for i = 1, select("#", ...) do
            local level = select(i, ...)
            mask = bit_bor(mask, level)
        end
        self:SetLogMask(mask)
    end
    
    function target:DisableLevels(...)
        local mask = self.enabledMask
        for i = 1, select("#", ...) do
            local level = select(i, ...)
            mask = bit.band(mask, bit.bnot(level))
        end
        self:SetLogMask(mask)
    end
    
    function target:Print(...)
        local msg = buildMessage(...)
        print(format("%s %s", PREFIX_COLOR .. "[" .. prefix .. "]" .. COLOR_RESET, msg))
    end
    
    function target:Log(level, ...)
        if bit_band(self.enabledMask, level) ~= 0 then
            logMessage(level, prefix, ...)
        end
    end
    
    function target:CreateLogger(customPrefix)
        local logPrefix = customPrefix or prefix
        
        local instance = {}
        
        -- Build instance-specific implementations
        local instanceImpls = {}
        for methodName, mask in pairs(MethodToMask) do
            instanceImpls[methodName] = function(self, ...)
                logMessage(mask, logPrefix, ...)
            end
        end
        
        -- Initial function assignment based on current mask
        for methodName, mask in pairs(MethodToMask) do
            if bit_band(target.enabledMask, mask) ~= 0 then
                instance[methodName] = instanceImpls[methodName]
            else
                instance[methodName] = noop
            end
        end
        
        -- Listen for mask changes (if target has callback support)
        if target.RegisterCallback then
            target.RegisterCallback(instance, "LogMaskChanged", function(event, newMask)
                for methodName, mask in pairs(MethodToMask) do
                    if bit_band(newMask, mask) ~= 0 then
                        instance[methodName] = instanceImpls[methodName]
                    else
                        instance[methodName] = noop
                    end
                end
            end)
        end
        
        -- Direct print (bypasses bitmask)
        instance.print = function(self, ...)
            local msg = buildMessage(...)
            print(format("%s %s", PREFIX_COLOR .. "[" .. logPrefix .. "]" .. COLOR_RESET, msg))
        end
        
        -- Generic log with bitmask check
        instance.Log = function(self, level, ...)
            if bit_band(target.enabledMask, level) ~= 0 then
                logMessage(level, logPrefix, ...)
            end
        end
        
        return instance
    end
    
    function target:Initialize()
        rebuildLoggerFunctions()
    end
    
    -- Initial setup
    rebuildLoggerFunctions()
    
    return target
end