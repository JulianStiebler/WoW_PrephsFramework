---@meta _
-- PrephsFramework Logging Library
-- 
-- This is free and unencumbered software released into the public domain.
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any means.
-- 
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
local table = table

-- Noop function for disabled log levels (zero overhead)
local function noop() end

-- Log level definitions with bitmasks, colors, and labels
---@class LogLevelDefinition
---@field mask Bitmask The bitmask value
---@field color string The WoW color code
---@field label string The display label
---@type table<string, LogLevelDefinition>
local LogLevel = {
    -- CATEGORIES (Bits 0-9)
    FEATURES     = { mask = 0x00000001, color = "|cFF00FF00", label = "FEATURES" },
    EVENTS       = { mask = 0x00000002, color = "|cFF00FF00", label = "EVENTS" },
    -- SEVERITIES (Bits 10-16)
    ERROR        = { mask = 0x00000400, color = "|cFFFF0000", label = "ERROR" },
    WARNING      = { mask = 0x00000800, color = "|cFFFFFF00", label = "WARN" },
    INFO         = { mask = 0x00001000, color = "|cFF00FF00", label = "INFO" },
    DEBUG        = { mask = 0x00002000, color = "|cFF00FFFF", label = "DEBUG" },
    TRACE        = { mask = 0x00004000, color = "|cFF888888", label = "TRACE" },
    FATAL        = { mask = 0x00008000, color = "|cFFFF00FF", label = "FATAL" },
}

-- Export LogLevel constants to library
LoggerLib.LogLevel = LogLevel

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
            return table.concat(parts, " ")
        end
    else
        if numArgs == 1 then
            return tostring(firstArg)
        end

        local parts = {}
        for i = 1, numArgs do
            parts[i] = tostring(select(i, ...))
        end
        return table.concat(parts, " ")
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

-- Mapping of method names to their bitmasks
local MethodToMask = {
    features = LogLevel.FEATURES.mask,
    events = LogLevel.EVENTS.mask,
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
---@field features fun(...) Log at FEATURES level
---@field events fun(...) Log at EVENTS level
---@field error fun(...) Log at ERROR level
---@field warning fun(...) Log at WARNING level
---@field info fun(...) Log at INFO level
---@field debug fun(...) Log at DEBUG level
---@field trace fun(...) Log at TRACE level
---@field fatal fun(...) Log at FATAL level
---@field print fun(...) Direct print without bitmask logic
---@field enabledMask number Current enabled log mask
local loggerMixin = {}

--- Embed Logger functionality into a target object
---@param target table The target object to embed into
---@param prefix? string Optional prefix for log messages (defaults to target name)
function LoggerLib:Embed(target, prefix)
    prefix = prefix or "PrephsFramework"
    
    -- Initialize enabled mask (default: ERROR, WARNING, INFO, FEATURES, EVENTS)
    target.enabledMask = bit_bor(
        LogLevel.ERROR.mask,
        LogLevel.WARNING.mask,
        LogLevel.INFO.mask,
        LogLevel.FEATURES.mask,
        LogLevel.EVENTS.mask
    )
    
    -- Build prefix-specific implementations
    local LogImplementations = {
        features = function(self, ...) logMessage(LogLevel.FEATURES.mask, prefix, ...) end,
        events   = function(self, ...) logMessage(LogLevel.EVENTS.mask,   prefix, ...) end,
        error    = function(self, ...) logMessage(LogLevel.ERROR.mask,    prefix, ...) end,
        warning  = function(self, ...) logMessage(LogLevel.WARNING.mask,  prefix, ...) end,
        info     = function(self, ...) logMessage(LogLevel.INFO.mask,     prefix, ...) end,
        debug    = function(self, ...) logMessage(LogLevel.DEBUG.mask,    prefix, ...) end,
        trace    = function(self, ...) logMessage(LogLevel.TRACE.mask,    prefix, ...) end,
        fatal    = function(self, ...) logMessage(LogLevel.FATAL.mask,    prefix, ...) end,
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
        self.enabledMask = mask
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