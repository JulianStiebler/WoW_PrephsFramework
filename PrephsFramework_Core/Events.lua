--[[
    <PrephsFramework_Core/Events.lua>
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

local EventFrame = Core.EventFrame

--- Set of WoW frame events currently registered on EventFrame.
---@type table<string, boolean>
local ActiveEvents = {}

--- True when at least one CLEU handler will fire during combat (used for short-circuit).
local HasCombatCLEUHandlers = false

-- Localize frequently used functions for performance
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local pairs = pairs
local tostring = tostring
local table = table
local bit_band = bit.band
local COMBATLOG_OBJECT_AFFILIATION_MASK = COMBATLOG_OBJECT_AFFILIATION_MASK
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local next = next
local pcall = pcall

local logger = Core.Logger

-- States upvalue: resolved lazily after State.lua loads (Events.lua loads first).
-- Set by the OnEvent handler on first event fire; all closures share this upvalue.
local States

local wipe = wipe
local select = select
local type = type
local CreateFrame = CreateFrame
local sort = table.sort

-- Scratch locals for CLEU prefix arg caching — written once per CLEU
-- dispatch, read by prefix-arg filter closures (zero C-call cost).
local cleu_arg12, cleu_arg13, cleu_arg14

-- ============================================================================
-- Registry Entry Types
-- ============================================================================

--- Entry for a single frame event handler in the EventRegistry.
---@class EventHandlerEntry
---@field modId string Registration key (e.g. "MyModule:FeatureName" or "_CoreInit")
---@field callback function Handler: function(eventName, ...) end
---@field checkFn function? Compiled filter chain (nil = passthrough / no checks)
---@field wantsUnique boolean? true if handler opts into per-frame dedup

--- Top-level registry bucket for a single WoW frame event.
---@class EventRegistryEntry
---@field byId table<string, EventHandlerEntry> Handlers keyed by modId (for O(1) unregister)
---@field list EventHandlerEntry[] Flat dispatch list rebuilt on register/unregister
---@field n number Current handler count in list
---@field dedupCount number Number of handlers that want unique/dedup filtering

--- Entry for a single CLEU subevent handler in the CombatLogRegistry.
---@class CLEUHandlerEntry
---@field modId string Registration key
---@field callback function Handler: function(timestamp, subevent, ...) end
---@field checkFn function? Compiled CLEU filter chain (nil = passthrough)
---@field skipInCombat boolean? true if handler should never fire in combat

--- Top-level registry bucket for a single CLEU subevent.
---@class CLEURegistryEntry
---@field byId table<string, CLEUHandlerEntry> Handlers keyed by modId
---@field list CLEUHandlerEntry[] Flat dispatch list
---@field n number Current handler count in list

-- ============================================================================
-- Internal Event Management
-- ============================================================================

-- ============================================================================
-- Unified Filter Definition System
-- ============================================================================
--
-- Central definition tables for filterable parameters on both WoW frame events
-- and CLEU (Combat Log Event Unfiltered) subevents.
--
-- The compiler reads these at registration time (cold path) and produces flat,
-- priority-ordered check arrays for the hot-path dispatchers.
--
-- Each entry declares:
--   argIndex  : position in the event payload (1-based vararg for frame events,
--               absolute CombatLogGetCurrentEventInfo() position for CLEU).
--   priority  : sort key for the check chain — lower = checked first (cheapest).
--   type      : filter behaviour (omit for value match/set auto-detection):
--       (omit)   — value filter: single value → exact equality ("match"),
--                   table → O(1) set-membership lookup ("set").
--       "dedup"  — fire callback once per unique value at argIndex per frame.
--       "state"  — compare against a States field (zero C-boundary cost).
--       "flags"  — bitwise: bit.band(arg, flagMask) <= flagMax.
--       "gte"    — numeric: arg >= supplied threshold.
--
-- Modules attach filters at registration time:
--   events = {
--       UNIT_SPELLCAST_SUCCEEDED = {
--           callback = fn,
--           filters  = { spellID = 12345, unique = true },
--       },
--   }
--
-- CLEU subevents:
--   events = {
--       SPELL_CAST_SUCCESS = {
--           callback = fn,
--           filters  = { spellId = { 123, 456 }, sourceIsPlayer = true },
--       },
--   }
-- ============================================================================

-- ============================================================================
-- Frame Event Filter Definitions
-- ============================================================================

---@class FilterDef
---@field argIndex?   number   Position in event varargs / CLEU args (1-based)
---@field type?       "dedup"|"state"|"flags"|"gte"  Filter behaviour
---@field priority    number   Lower = checked first (cheaper checks first)
---@field stateField? string   For "state": States field name to read
---@field compareArg? number   For "state": CLEU base argIndex to compare against
---@field flagMask?   number   For "flags": bitmask to apply with bit.band
---@field flagMax?    number   For "flags": result must be <= this value

---@type table<string, table<string, FilterDef>>
local EventFilterDefinitions = {
    -- UNIT_SPELLCAST_SUCCEEDED fires (unitTarget, castGUID, spellID)
    UNIT_SPELLCAST_SUCCEEDED = {
        spellID = { argIndex = 3, priority = 5 },
        unique  = { argIndex = 2, type = "dedup", priority = 10 },
    },
    -- UNIT_SPELLCAST_CHANNEL_START fires (unitTarget, castGUID, spellID)
    UNIT_SPELLCAST_CHANNEL_START = {
        spellID = { argIndex = 3, priority = 5 },
        unique  = { argIndex = 2, type = "dedup", priority = 10 },
    },
    -- UNIT_SPELLCAST_START fires (unitTarget, castGUID, spellID)
    UNIT_SPELLCAST_START = {
        spellID = { argIndex = 3, priority = 5 },
        unique  = { argIndex = 2, type = "dedup", priority = 10 },
    },
}

-- ============================================================================
-- Combat Log Event Filter Definitions
-- ============================================================================
--
-- CombatLogGetCurrentEventInfo() returns:
--
--  Arg  Name              Notes
--  ───  ────              ─────
--   1   timestamp
--   2   subevent          Routing key — extracted once by dispatcher
--   3   hideCaster
--   4   sourceGUID        ┐
--   5   sourceName        │  Dispatcher pre-extracts these 8 locals
--   6   sourceFlags       │  (zero additional cost for base-arg filters)
--   7   sourceRaidFlags   │
--   8   destGUID          │
--   9   destName          │
--  10   destFlags         │
--  11   destRaidFlags     ┘
--
--  Prefix args (12+) — vary by prefix:
--      SPELL / RANGE / SPELL_PERIODIC:  12=spellId  13=spellName  14=spellSchool
--      ENVIRONMENTAL:                   12=environmentalType
--      SWING:                           (none)
--
--  Suffix args — start after prefix, vary by suffix type.
--
-- The CLEU dispatcher pre-extracts base args 4-11 into locals and passes them
-- to each handler's compiled check function.  Prefix and suffix arg checks use
-- select() from CombatLogGetCurrentEventInfo() — one C boundary crossing per
-- check, but only reached if cheaper filters already passed.
-- ============================================================================

---@type table<string, FilterDef>
local CombatEventFilterDefinitions = {
    -- ── State-derived (zero C cost, read from States flat table) ────────
    inCombat            = { type = "state", stateField = "inCombat",          priority = 5  },
    sourceIsPlayer      = { type = "state", stateField = "playerGUID",
                            compareArg = 4,                                   priority = 10 },
    destIsPlayer        = { type = "state", stateField = "playerGUID",
                            compareArg = 8,                                   priority = 10 },

    -- ── Base-arg flag checks (bitmask on already-extracted locals) ──────────
    sourceIsGroupMember = { argIndex = 6,  type = "flags",
                            flagMask = COMBATLOG_OBJECT_AFFILIATION_MASK,
                            flagMax  = COMBATLOG_OBJECT_AFFILIATION_RAID,     priority = 15 },
    destIsGroupMember   = { argIndex = 10, type = "flags",
                            flagMask = COMBATLOG_OBJECT_AFFILIATION_MASK,
                            flagMax  = COMBATLOG_OBJECT_AFFILIATION_RAID,     priority = 15 },

    -- ── Base-arg value filters (direct equality / set on extracted locals) ──
    sourceGUID          = { argIndex = 4,                                     priority = 20 },
    destGUID            = { argIndex = 8,                                     priority = 20 },
    sourceName          = { argIndex = 5,                                     priority = 25 },
    destName            = { argIndex = 9,                                     priority = 25 },

    -- ── Prefix-arg value filters (one select() C call per check) ───────────
    spellId             = { argIndex = 12,                                    priority = 6 },
    spellName           = { argIndex = 13,                                    priority = 45 },
    spellSchool         = { argIndex = 14,                                    priority = 45 },
    environmentalType   = { argIndex = 12,                                    priority = 40 },

    -- ── Suffix-arg filters (select() from CLEU, position resolved per
    --    subevent at compile time — see CLEUSuffixLayout) ───────────────────
    amount              = { type = "gte",                                     priority = 60 },
    auraType            = {                                                   priority = 50 },
    critical            = {                                                   priority = 55 },
    missType            = {                                                   priority = 50 },
    failedType          = {                                                   priority = 50 },
    powerType           = {                                                   priority = 55 },
    extraSpellId        = {                                                   priority = 55 },
}

-- ============================================================================
-- CLEU Prefix / Suffix Resolution (cold-path metadata)
-- ============================================================================

--- Returns the number of prefix args for a given CLEU subevent.
--- Determined by parsing the subevent name prefix.
---@param subevent string  e.g. "SPELL_DAMAGE", "SWING_MISSED"
---@return number prefixArgCount
local function GetPrefixArgCount(subevent)
    -- Order matters: check longer prefixes first to avoid partial matches
    if subevent:find("^SPELL_PERIODIC") then return 3
    elseif subevent:find("^SPELL_BUILDING") then return 3
    elseif subevent:find("^SPELL_EMPOWER") then return 3
    elseif subevent:find("^SPELL")  then return 3
    elseif subevent:find("^RANGE")  then return 3
    elseif subevent:find("^SWING")  then return 0
    elseif subevent:find("^ENVIRONMENTAL") then return 1
    else return 0 -- special events: UNIT_DIED, PARTY_KILL, ENCHANT_*, etc.
    end
end

--- Suffix param layouts: maps param name → 1-based offset from suffix start.
--- The absolute CLEU arg position is: 11 + prefixArgCount + offset.
---@type table<string, table<string, number>>
local CLEUSuffixLayout = {
    _DAMAGE = {
        amount = 1, overkill = 2, school = 3, resisted = 4,
        blocked = 5, absorbed = 6, critical = 7, glancing = 8,
        crushing = 9, isOffHand = 10,
    },
    _MISSED = {
        missType = 1, isOffHand = 2, amountMissed = 3, critical = 4,
    },
    _HEAL = {
        amount = 1, overhealing = 2, absorbed = 3, critical = 4,
    },
    _HEAL_ABSORBED = {
        extraGUID = 1, extraName = 2, extraFlags = 3, extraRaidFlags = 4,
        extraSpellID = 5, extraSpellName = 6, extraSchool = 7,
        absorbedAmount = 8,
    },
    _ENERGIZE = {
        amount = 1, overEnergize = 2, powerType = 3,
    },
    _DRAIN = {
        amount = 1, powerType = 2, extraAmount = 3,
    },
    _LEECH = {
        amount = 1, powerType = 2, extraAmount = 3,
    },
    _INTERRUPT = {
        extraSpellId = 1, extraSpellName = 2, extraSchool = 3,
    },
    _DISPEL = {
        extraSpellId = 1, extraSpellName = 2, extraSchool = 3, auraType = 4,
    },
    _DISPEL_FAILED = {
        extraSpellId = 1, extraSpellName = 2, extraSchool = 3,
    },
    _STOLEN = {
        extraSpellId = 1, extraSpellName = 2, extraSchool = 3, auraType = 4,
    },
    _EXTRA_ATTACKS = {
        amount = 1,
    },
    _AURA_APPLIED      = { auraType = 1, amount = 2 },
    _AURA_REMOVED       = { auraType = 1, amount = 2 },
    _AURA_APPLIED_DOSE  = { auraType = 1, amount = 2 },
    _AURA_REMOVED_DOSE  = { auraType = 1, amount = 2 },
    _AURA_REFRESH       = { auraType = 1 },
    _AURA_BROKEN        = { auraType = 1 },
    _AURA_BROKEN_SPELL  = { extraSpellId = 1, extraSpellName = 2, extraSchool = 3, auraType = 4 },
    _CAST_START         = {},
    _CAST_SUCCESS       = {},
    _CAST_FAILED        = { failedType = 1 },
    _INSTAKILL          = {},
    _DURABILITY_DAMAGE  = {},
    _DURABILITY_DAMAGE_ALL = {},
    _CREATE             = {},
    _SUMMON             = {},
    _RESURRECT          = {},
    _SHIELD             = {},
    _ABSORBED           = {},
}

--- Extracts the suffix portion of a CLEU subevent name.
--- e.g. "SPELL_DAMAGE" → "_DAMAGE", "SWING_MISSED" → "_MISSED"
---@param subevent string
---@return string|nil suffix  The suffix key into CLEUSuffixLayout, or nil
local function GetSubeventSuffix(subevent)
    if subevent:find("^SWING_")            then return subevent:sub(6)
    elseif subevent:find("^RANGE_")        then return subevent:sub(6)
    elseif subevent:find("^SPELL_PERIODIC_") then return subevent:sub(16)
    elseif subevent:find("^SPELL_BUILDING_") then return subevent:sub(16)
    elseif subevent:find("^SPELL_EMPOWER_")  then return subevent:sub(14)
    elseif subevent:find("^ENVIRONMENTAL_")  then return subevent:sub(14)
    elseif subevent:find("^SPELL_")        then return subevent:sub(6)
    else return nil -- special events have no standard suffix
    end
end

--- Resolves the absolute CLEU arg position for a suffix parameter.
---@param subevent string  The CLEU subevent (e.g. "SPELL_DAMAGE")
---@param paramName string The suffix param name (e.g. "amount")
---@return number|nil argIndex  Absolute position in CombatLogGetCurrentEventInfo()
local function ResolveSuffixArgIndex(subevent, paramName)
    local suffix = GetSubeventSuffix(subevent)
    if not suffix then return nil end
    local layout = CLEUSuffixLayout[suffix]
    if not layout then return nil end
    local offset = layout[paramName]
    if not offset then return nil end
    -- 11 base args + prefix args + suffix offset
    return 11 + GetPrefixArgCount(subevent) + offset
end

-- ============================================================================
-- Pre-compute per-event metadata for the frame event dispatcher
-- ============================================================================

--- Stores dedup arg index so it can be extracted once per event firing.
---@type table<string, { dedupArgIndex?: number }>
local FilteredEventMeta = {}
for eventName, filterDefs in pairs(EventFilterDefinitions) do
    local meta = {}
    for _, def in pairs(filterDefs) do
        if def.type == "dedup" then
            meta.dedupArgIndex = def.argIndex
        end
    end
    FilteredEventMeta[eventName] = meta
end

-- ============================================================================
-- Dedup System — Generation Counter (no per-frame wipe)
-- ============================================================================
-- Instead of wiping seen tables each frame, we bump a generation counter.
-- A value is "duplicate" only if its stored generation matches the current one.
-- Stale entries become irrelevant at zero cost — no wipe() ever needed.
-- ============================================================================

local dedupGeneration = 0
local dedupSeen = {} -- [eventName] = { [value] = lastSeenGeneration }

local DedupFrame = CreateFrame("Frame")
DedupFrame:SetScript("OnUpdate", function()
    dedupGeneration = dedupGeneration + 1
end)

-- ============================================================================
-- Unified Filter Compilation — Frame Events (cold path)
-- ============================================================================
--
-- Compiles a handler's filter table + options into a single compiled struct:
--   { wantsUnique?: boolean, checkFn?: function(...) -> boolean }
--
-- The checkFn embeds ALL gating logic: option checks (skipInCombat,
-- requiresInstance) + value filters, sorted by priority (cheapest first).
-- This eliminates ShouldProcessEvent from the hot path entirely.
-- ============================================================================

---@class CompiledFilter
---@field wantsUnique?   boolean  Handler opts into per-frame dedup
---@field checkFn?       function Composed check function (nil = no checks / passthrough)
---@field skipInCombat?  boolean  Handler will never fire in combat (for HasCombatCLEUHandlers)

--- Compiles frame event filters + options into a CompiledFilter.
---@param eventName string
---@param filters?  table<string, any>  User-supplied filter values
---@param options?  table               Handler options (skipInCombat, requiresInstance, …)
---@return CompiledFilter|nil  nil when no checks / no dedup needed
local function CompileFrameEventFilters(eventName, filters, options)
    ---@type { priority: number, fn: function }[]
    local checks = {}
    local n = 0
    local wantsUnique = false

    -- ── Fold options into the check chain (lowest priority = checked first) ──
    if options then
        if options.skipInCombat then
            n = n + 1
            checks[n] = { priority = 1, fn = function()
                return not States.inCombat
            end }
        end
        if options.requiresInstance then
            n = n + 1
            checks[n] = { priority = 2, fn = function()
                return States.inInstance
            end }
        end
    end

    -- ── Compile user-supplied filters against the event's definitions ──
    if filters then
        local defs = EventFilterDefinitions[eventName]
        if defs then
            for filterName, filterValue in pairs(filters) do
                local def = defs[filterName]
                if not def then
                    logger:warning("Unknown filter '%s' for event '%s' (ignored)",
                                   filterName, eventName)
                elseif def.type == "dedup" then
                    wantsUnique = true
                elseif type(filterValue) == "table" then
                    -- Table of values → compile into a set for O(1) lookup
                    local set = {}
                    for i = 1, #filterValue do set[filterValue[i]] = true end
                    local argIdx = def.argIndex
                    n = n + 1
                    checks[n] = { priority = def.priority, fn = function(...)
                        return set[select(argIdx, ...)] ~= nil
                    end }
                else
                    -- Single value → exact equality (cheapest value check)
                    local argIdx = def.argIndex
                    local val = filterValue
                    n = n + 1
                    checks[n] = { priority = def.priority, fn = function(...)
                        return select(argIdx, ...) == val
                    end }
                end
            end
        end
    end

    if n == 0 and not wantsUnique then return nil end

    -- ── Sort by priority (lower = checked first = cheapest) ──
    if n > 1 then
        sort(checks, function(a, b) return a.priority < b.priority end)
    end

    -- ── Compose sorted check functions into a single callable ──
    local checkFn = nil
    if n > 0 then
        if n == 1 then
            checkFn = checks[1].fn
        elseif n == 2 then
            local c1, c2 = checks[1].fn, checks[2].fn
            checkFn = function(...)
                return c1(...) and c2(...)
            end
        elseif n == 3 then
            local c1, c2, c3 = checks[1].fn, checks[2].fn, checks[3].fn
            checkFn = function(...)
                return c1(...) and c2(...) and c3(...)
            end
        else
            -- 4+ filters: iterate (rare)
            local fns = {}
            for i = 1, n do fns[i] = checks[i].fn end
            local count = n
            checkFn = function(...)
                for i = 1, count do
                    if not fns[i](...) then return false end
                end
                return true
            end
        end
    end

    return {
        wantsUnique = wantsUnique or nil,
        checkFn = checkFn,
    }
end

-- ============================================================================
-- CLEU Check Builders (cold path — each returns a closure for the hot path)
-- ============================================================================
--
-- Every generated closure has the dispatcher's base-arg signature:
--   function(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
--            destGUID, destName, destFlags, destRaidFlags) -> boolean
--
-- Closures capture constants / State references at build time.
-- Hot-path cost per check: 1 Lua comparison (state/base-arg) or
-- 1 select() C call + 1 comparison (prefix/suffix-arg).
-- ============================================================================

--- Builders indexed by CombatEventFilterDefinitions key.
--- Each builder: (filterValue) -> checkFunction
---@type table<string, fun(value: any): function>
local CLEUCheckBuilders = {}

-- ── State-derived builders (zero C cost) ────────────────────────────────────

--- inCombat: read State.inCombat; true = only in combat, false = only out
CLEUCheckBuilders.inCombat = function(value)
    if value then
        return function() return States.inCombat end
    else
        return function() return not States.inCombat end
    end
end

--- sourceIsPlayer: compare sourceGUID (arg 1) against State.playerGUID
CLEUCheckBuilders.sourceIsPlayer = function(value)
    if value then
        return function(sourceGUID) return sourceGUID == States.playerGUID end
    else
        return function(sourceGUID) return sourceGUID ~= States.playerGUID end
    end
end

--- destIsPlayer: compare destGUID (arg 5) against State.playerGUID
CLEUCheckBuilders.destIsPlayer = function(value)
    if value then
        return function(_, _, _, _, destGUID) return destGUID == States.playerGUID end
    else
        return function(_, _, _, _, destGUID) return destGUID ~= States.playerGUID end
    end
end

-- ── Base-arg flag builders (bitmask on pre-extracted locals) ─────────────────

--- sourceIsGroupMember: bit.band(sourceFlags, AFFILIATION_MASK) <= AFFILIATION_RAID
CLEUCheckBuilders.sourceIsGroupMember = function(value)
    if value then
        return function(_, _, sourceFlags)
            return bit_band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK)
                   <= COMBATLOG_OBJECT_AFFILIATION_RAID
        end
    else
        return function(_, _, sourceFlags)
            return bit_band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK)
                   > COMBATLOG_OBJECT_AFFILIATION_RAID
        end
    end
end

--- destIsGroupMember: bit.band(destFlags, AFFILIATION_MASK) <= AFFILIATION_RAID
CLEUCheckBuilders.destIsGroupMember = function(value)
    if value then
        return function(_, _, _, _, _, _, destFlags)
            return bit_band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MASK)
                   <= COMBATLOG_OBJECT_AFFILIATION_RAID
        end
    else
        return function(_, _, _, _, _, _, destFlags)
            return bit_band(destFlags, COMBATLOG_OBJECT_AFFILIATION_MASK)
                   > COMBATLOG_OBJECT_AFFILIATION_RAID
        end
    end
end

-- ── Base-arg value builders (direct equality / set on extracted locals) ──────

--- sourceGUID: match or set on arg 1
CLEUCheckBuilders.sourceGUID = function(value)
    if type(value) == "table" then
        return function(sourceGUID) return value[sourceGUID] end
    else
        return function(sourceGUID) return sourceGUID == value end
    end
end

--- destGUID: match or set on arg 5
CLEUCheckBuilders.destGUID = function(value)
    if type(value) == "table" then
        return function(_, _, _, _, destGUID) return value[destGUID] end
    else
        return function(_, _, _, _, destGUID) return destGUID == value end
    end
end

--- sourceName: match on arg 2
CLEUCheckBuilders.sourceName = function(value)
    if type(value) == "table" then
        return function(_, sourceName) return value[sourceName] end
    else
        return function(_, sourceName) return sourceName == value end
    end
end

--- destName: match on arg 6
CLEUCheckBuilders.destName = function(value)
    if type(value) == "table" then
        return function(_, _, _, _, _, destName) return value[destName] end
    else
        return function(_, _, _, _, _, destName) return destName == value end
    end
end

-- ── Prefix-arg builders (one select() C call per check) ─────────────────────

--- spellId: O(1) set lookup — value is already a set (preprocessed)
CLEUCheckBuilders.spellId = function(value)
    return function()
        return value[cleu_arg12]
    end
end

--- spellName: match on cached arg 13
CLEUCheckBuilders.spellName = function(value)
    if type(value) == "table" then
        return function()
            return value[cleu_arg13]
        end
    else
        return function()
            return cleu_arg13 == value
        end
    end
end

--- spellSchool: match or bitmask on cached arg 14
CLEUCheckBuilders.spellSchool = function(value)
    if type(value) == "table" then
        return function()
            return value[cleu_arg14]
        end
    else
        return function()
            return cleu_arg14 == value
        end
    end
end

--- environmentalType: match on cached arg 12 (ENVIRONMENTAL prefix only)
CLEUCheckBuilders.environmentalType = function(value)
    if type(value) == "table" then
        return function()
            return value[cleu_arg12]
        end
    else
        return function()
            return cleu_arg12 == value
        end
    end
end

-- ── Suffix-arg builder factory (resolved per subevent at compile time) ──────

--- Builds a check closure for a suffix parameter whose absolute arg position
--- was resolved at compile time via ResolveSuffixArgIndex.
---@param absArgIdx number  Absolute position in CombatLogGetCurrentEventInfo()
---@param value     any     User-supplied filter value
---@param defType?  string  FilterDef.type ("gte" for threshold, nil for value)
---@return function checkFn
local function BuildSuffixCheck(absArgIdx, value, defType)
    if defType == "gte" then
        return function()
            return (select(absArgIdx, CombatLogGetCurrentEventInfo()) or 0) >= value
        end
    elseif type(value) == "table" then
        return function()
            return value[select(absArgIdx, CombatLogGetCurrentEventInfo())]
        end
    else
        return function()
            return select(absArgIdx, CombatLogGetCurrentEventInfo()) == value
        end
    end
end

-- ============================================================================
-- Unified Filter Compilation — CLEU (cold path)
-- ============================================================================
--
-- Preprocess: normalise spellId to set, resolve suffix arg positions.
-- Compile: build priority-ordered check chain from CombatEventFilterDefinitions.
-- Output: { checkFn?: function, skipInCombat?: boolean }
-- ============================================================================

--- Normalises user-supplied CLEU filters before compilation.
--- - Converts spellId (single value or array) into a set for O(1) hot-path lookup.
---@param filters? table  Raw filter table from the module
---@return table|nil processed  Shallow copy with normalised values, or nil
local function PreprocessCLEUFilters(filters)
    if not filters then return nil end

    local processed = {}
    for k, v in pairs(filters) do
        processed[k] = v
    end

    -- spellId → set
    if processed.spellId then
        local raw = processed.spellId
        if type(raw) ~= "table" then
            processed.spellId = { [raw] = true }
        else
            local set = {}
            for i = 1, #raw do set[raw[i]] = true end
            processed.spellId = set
        end
    end

    return processed
end

--- Compiles CLEU filters + options into a CompiledFilter.
---@param subevent string
---@param filters? table<string, any>  Preprocessed filter values
---@param options? table               Handler options
---@return CompiledFilter|nil
local function CompileCLEUFilters(subevent, filters, options)
    ---@type { priority: number, fn: function }[]
    local checks = {}
    local n = 0
    local skipInCombat = false

    -- ── Fold options into the check chain ───────────────────────────────────
    if options then
        if options.skipInCombat then
            skipInCombat = true
            n = n + 1
            checks[n] = { priority = 1, fn = function()
                return not States.inCombat
            end }
        end
        if options.requiresInstance then
            n = n + 1
            checks[n] = { priority = 2, fn = function()
                return States.inInstance
            end }
        end
    end

    -- ── Compile user-supplied filters against CombatEventFilterDefinitions ──
    if filters then
        for filterName, filterValue in pairs(filters) do
            local def = CombatEventFilterDefinitions[filterName]
            if not def then
                logger:warning("Unknown CLEU filter '%s' for subevent '%s' (ignored)",
                               filterName, subevent)
            else
                local checkFn

                -- Check for a dedicated builder first (base / prefix args)
                local builder = CLEUCheckBuilders[filterName]
                if builder then
                    checkFn = builder(filterValue)
                else
                    -- Suffix param — resolve absolute arg position
                    local absIdx = ResolveSuffixArgIndex(subevent, filterName)
                    if absIdx then
                        checkFn = BuildSuffixCheck(absIdx, filterValue, def.type)
                    else
                        logger:warning(
                            "Cannot resolve suffix filter '%s' for subevent '%s' (ignored)",
                            filterName, subevent)
                    end
                end

                if checkFn then
                    n = n + 1
                    checks[n] = { priority = def.priority, fn = checkFn }
                end
            end
        end

        -- Detect inCombat=false filter (also means handler skips combat)
        if filters.inCombat == false then
            skipInCombat = true
        end
    end

    if n == 0 then return nil end

    -- ── Sort by priority (lower = checked first = cheapest) ──
    if n > 1 then
        sort(checks, function(a, b) return a.priority < b.priority end)
    end

    -- ── Compose sorted check functions into a single callable ──
    local composedFn
    if n == 1 then
        composedFn = checks[1].fn
    elseif n == 2 then
        local c1, c2 = checks[1].fn, checks[2].fn
        composedFn = function(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                              destGUID, destName, destFlags, destRaidFlags)
            return c1(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                      destGUID, destName, destFlags, destRaidFlags)
               and c2(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                      destGUID, destName, destFlags, destRaidFlags)
        end
    elseif n == 3 then
        local c1, c2, c3 = checks[1].fn, checks[2].fn, checks[3].fn
        composedFn = function(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                              destGUID, destName, destFlags, destRaidFlags)
            return c1(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                      destGUID, destName, destFlags, destRaidFlags)
               and c2(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                      destGUID, destName, destFlags, destRaidFlags)
               and c3(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                      destGUID, destName, destFlags, destRaidFlags)
        end
    else
        -- 4+ filters: iterate (rare case, negligible overhead)
        local fns = {}
        for i = 1, n do fns[i] = checks[i].fn end
        local count = n
        composedFn = function(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                              destGUID, destName, destFlags, destRaidFlags)
            for i = 1, count do
                if not fns[i](sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                              destGUID, destName, destFlags, destRaidFlags) then
                    return false
                end
            end
            return true
        end
    end

    return {
        checkFn = composedFn,
        skipInCombat = skipInCombat or nil,
    }
end

-- ============================================================================
-- CLEU Subevent Registry
-- ============================================================================

---@alias CLEUSubevent
---| "ENVIRONMENTAL_DAMAGE"
---| "RANGE_DAMAGE"
---| "RANGE_MISSED"
---| "SPELL_ABSORBED"
---| "SPELL_AURA_APPLIED"
---| "SPELL_AURA_APPLIED_DOSE"
---| "SPELL_AURA_BROKEN"
---| "SPELL_AURA_BROKEN_SPELL"
---| "SPELL_AURA_REFRESH"
---| "SPELL_AURA_REMOVED"
---| "SPELL_AURA_REMOVED_DOSE"
---| "SPELL_CAST_FAILED"
---| "SPELL_CAST_START"
---| "SPELL_CAST_SUCCESS"
---| "SPELL_CREATE"
---| "SPELL_DAMAGE"
---| "SPELL_DRAIN"
---| "SPELL_DURABILITY_DAMAGE"
---| "SPELL_DURABILITY_DAMAGE_ALL"
---| "SPELL_EMPOWER_INTERRUPT"
---| "SPELL_EMPOWER_START"
---| "SPELL_EMPOWER_END"
---| "SPELL_ENERGIZE"
---| "SPELL_EXTRA_ATTACKS"
---| "SPELL_HEAL"
---| "SPELL_HEAL_ABSORBED"
---| "SPELL_INSTAKILL"
---| "SPELL_INTERRUPT"
---| "SPELL_LEECH"
---| "SPELL_MISSED"
---| "SPELL_PERIODIC_DAMAGE"
---| "SPELL_PERIODIC_DRAIN"
---| "SPELL_PERIODIC_ENERGIZE"
---| "SPELL_PERIODIC_HEAL"
---| "SPELL_PERIODIC_LEECH"
---| "SPELL_PERIODIC_MISSED"
---| "SPELL_RESURRECT"
---| "SPELL_SHIELD"
---| "SPELL_STOLEN"
---| "SPELL_SUMMON"
---| "SWING_DAMAGE"
---| "SWING_MISSED"
---| "UNIT_DIED"
---| "UNIT_DESTROYED"
---| "UNIT_DISSIPATES"
---| "PARTY_KILL"
---| "ENCHANT_APPLIED"
---| "ENCHANT_REMOVED"
local CLEU_SUBEVENTS = {
    ENVIRONMENTAL_DAMAGE = true,
    RANGE_DAMAGE = true,
    RANGE_MISSED = true,
    SPELL_ABSORBED = true,
    SPELL_AURA_APPLIED = true,
    SPELL_AURA_APPLIED_DOSE = true,
    SPELL_AURA_BROKEN = true,
    SPELL_AURA_BROKEN_SPELL = true,
    SPELL_AURA_REFRESH = true,
    SPELL_AURA_REMOVED = true,
    SPELL_AURA_REMOVED_DOSE = true,
    SPELL_CAST_FAILED = true,
    SPELL_CAST_START = true,
    SPELL_CAST_SUCCESS = true,
    SPELL_CREATE = true,
    SPELL_DAMAGE = true,
    SPELL_DRAIN = true,
    SPELL_DURABILITY_DAMAGE = true,
    SPELL_DURABILITY_DAMAGE_ALL = true,
    SPELL_EMPOWER_INTERRUPT = true,
    SPELL_EMPOWER_START = true,
    SPELL_EMPOWER_END = true,
    SPELL_ENERGIZE = true,
    SPELL_EXTRA_ATTACKS = true,
    SPELL_HEAL = true,
    SPELL_HEAL_ABSORBED = true,
    SPELL_INSTAKILL = true,
    SPELL_INTERRUPT = true,
    SPELL_LEECH = true,
    SPELL_MISSED = true,
    SPELL_PERIODIC_DAMAGE = true,
    SPELL_PERIODIC_DRAIN = true,
    SPELL_PERIODIC_ENERGIZE = true,
    SPELL_PERIODIC_HEAL = true,
    SPELL_PERIODIC_LEECH = true,
    SPELL_PERIODIC_MISSED = true,
    SPELL_RESURRECT = true,
    SPELL_SHIELD = true,
    SPELL_STOLEN = true,
    SPELL_SUMMON = true,
    SWING_DAMAGE = true,
    SWING_MISSED = true,
    UNIT_DIED = true,
    UNIT_DESTROYED = true,
    UNIT_DISSIPATES = true,
    PARTY_KILL = true,
    ENCHANT_APPLIED = true,
    ENCHANT_REMOVED = true
}

--- Public function to check if an event is a CLEU subevent.
---@param eventName CLEUSubevent The CLEU subevent name to check
---@return boolean
function Core:IsCombatLogSubevent(eventName)
    return CLEU_SUBEVENTS[eventName] == true
end

-- ============================================================================
-- Internal Frame-Event Helpers
-- ============================================================================

---@param eventName FrameEvent
local function RegisterFrameEvent(eventName)
    if not ActiveEvents[eventName] then
        EventFrame:RegisterEvent(eventName)
        ActiveEvents[eventName] = true
    end
end

---@param eventName FrameEvent
local function UnregisterFrameEvent(eventName)
    if ActiveEvents[eventName] then
        EventFrame:UnregisterEvent(eventName)
        ActiveEvents[eventName] = nil
    end
end

-- ============================================================================
-- Combat CLEU Handler Tracking
-- ============================================================================

--- Recalculates whether ANY CLEU handler should run during combat.
--- Checked once per CLEU dispatch to short-circuit when none would fire.
local function UpdateCombatCLEUHandlers()
    HasCombatCLEUHandlers = false

    for _, reg in pairs(Core.CombatLogRegistry) do
        local list = reg.list
        for i = 1, reg.n do
            if not list[i].skipInCombat then
                HasCombatCLEUHandlers = true
                return
            end
        end
    end
end

--- Rebuilds the flat dispatch list from the keyed byId map.
--- Called on register/unregister (cold path) to keep the hot-path list current.
---@param reg table  Registry entry with byId, list, n fields
local function RebuildList(reg)
    local list = reg.list
    local n = 0
    for _, entry in pairs(reg.byId) do
        n = n + 1
        list[n] = entry
    end
    -- Clear trailing stale entries
    for i = n + 1, #list do
        list[i] = nil
    end
    reg.n = n
end

-- ============================================================================
-- Public Event API
-- ============================================================================

--- Registers a frame event handler for a module/feature.
---@param modId    string             Unique registration key (e.g. "MyModule:FeatureName")
---@param eventName FrameEvent        WoW frame event name
---@param callback function           Handler: function(eventName, ...) end
---@param options? table              { skipInCombat?: boolean, requiresInstance?: boolean }
---@param filters? table<string, any> Filter values keyed by EventFilterDefinitions names
---@return boolean success
function Core:RegisterEvent(modId, eventName, callback, options, filters)
    if not modId or not eventName or not callback then
        logger:error("RegisterEvent called with invalid parameters")
        return false
    end

    local reg = self.EventRegistry[eventName]
    if not reg then
        reg = { byId = {}, list = {}, n = 0, dedupCount = 0 }
        self.EventRegistry[eventName] = reg
    end

    -- Track dedup count changes on overwrite
    local old = reg.byId[modId]
    if old then
        logger:warning(
            "Feature '%s' already registered for event '%s' (overwriting)",
            modId, eventName
        )
        if old.wantsUnique then
            reg.dedupCount = reg.dedupCount - 1
        end
    end

    -- Compile unified filter (options + user filters → single check chain)
    local compiled = CompileFrameEventFilters(eventName, filters, options)

    -- Flatten compiled into the handler entry (eliminates nested table dereference in hot path)
    local entry = {
        modId = modId,
        callback = callback,
        checkFn = compiled and compiled.checkFn or nil,
        wantsUnique = compiled and compiled.wantsUnique or nil,
    }

    reg.byId[modId] = entry
    if entry.wantsUnique then
        reg.dedupCount = reg.dedupCount + 1
    end
    RebuildList(reg)

    -- Register event on frame if not already registered
    RegisterFrameEvent(eventName)
    local componentType = (modId:sub(1, 1) == "_") and "Component" or "Feature"
    logger:events(
        "%s '%s' registered for event '%s'%s",
        componentType, modId, eventName,
        compiled and " (with filters)" or ""
    )

    return true
end

--- Unregisters a frame event handler.
---@param modId    string
---@param eventName FrameEvent
---@return boolean success
function Core:UnregisterEvent(modId, eventName)
    if not modId or not eventName then
        return false
    end

    local reg = self.EventRegistry[eventName]
    if not reg then
        return false
    end

    local old = reg.byId[modId]
    if not old then
        return false
    end

    -- Track dedup count
    if old.wantsUnique then
        reg.dedupCount = reg.dedupCount - 1
    end

    reg.byId[modId] = nil
    RebuildList(reg)

    -- Unregister from frame if no more listeners
    if reg.n == 0 then
        UnregisterFrameEvent(eventName)
        self.EventRegistry[eventName] = nil
    end

    local componentType = (modId:sub(1, 1) == "_") and "Component" or "Feature"
    logger:events(
        "%s '%s' unregistered from event '%s'",
        componentType, modId, eventName
    )

    return true
end

--- Unregisters all frame (and CLEU) events for a module.
---@param modId string
---@return number|boolean unregisteredCount
function Core:UnregisterAllEvents(modId)
    if not modId then return false end

    local unregisteredCount = 0

    for eventName, reg in pairs(self.EventRegistry) do
        if reg.byId[modId] then
            self:UnregisterEvent(modId, eventName)
            unregisteredCount = unregisteredCount + 1
        end
    end

    -- Also clean up combat log events
    self:UnregisterAllCombatLogEvents(modId)

    return unregisteredCount
end

-- ============================================================================
-- Combat Log Event System (CLEU) — Public API
-- ============================================================================

--- Registers a CLEU subevent handler.
---@param modId    string
---@param subevent CLEUSubevent
---@param callback function           Handler: function(CombatLogGetCurrentEventInfo()) end
---@param options? table              { skipInCombat?: boolean, requiresInstance?: boolean }
---@param filters? table<string, any> Filter values keyed by CombatEventFilterDefinitions names
---@return boolean success
function Core:RegisterCombatLogEvent(modId, subevent, callback, options, filters)
    if not modId or not subevent or not callback then
        logger:error("RegisterCombatLogEvent called with invalid parameters")
        return false
    end

    local reg = self.CombatLogRegistry[subevent]
    if not reg then
        reg = { byId = {}, list = {}, n = 0 }
        self.CombatLogRegistry[subevent] = reg
    end

    if reg.byId[modId] then
        logger:warning(
            "Feature '%s' already registered for CLEU subevent '%s' (overwriting)",
            modId, subevent
        )
    end

    -- Preprocess (spellId → set) and compile
    local processed = PreprocessCLEUFilters(filters)
    local compiled = CompileCLEUFilters(subevent, processed, options)

    -- Flatten compiled into the handler entry
    local entry = {
        modId = modId,
        callback = callback,
        checkFn = compiled and compiled.checkFn or nil,
        skipInCombat = compiled and compiled.skipInCombat or nil,
    }

    reg.byId[modId] = entry
    RebuildList(reg)

    logger:events(
        "Feature '%s' registered for CLEU subevent '%s'%s",
        modId, subevent, filters and " (with filters)" or ""
    )

    -- Register COMBAT_LOG_EVENT_UNFILTERED if not already registered
    RegisterFrameEvent("COMBAT_LOG_EVENT_UNFILTERED")

    -- Update combat handler tracking
    UpdateCombatCLEUHandlers()

    return true
end

--- Unregisters a CLEU subevent handler.
---@param modId    string
---@param subevent CLEUSubevent
---@return boolean success
function Core:UnregisterCombatLogEvent(modId, subevent)
    if not modId or not subevent then
        return false
    end

    local reg = self.CombatLogRegistry[subevent]
    if not reg or not reg.byId[modId] then
        return false
    end

    reg.byId[modId] = nil
    RebuildList(reg)

    if reg.n == 0 then
        self.CombatLogRegistry[subevent] = nil

        -- Check if ANY subevent still has listeners
        if next(self.CombatLogRegistry) == nil then
            UnregisterFrameEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    end

    -- Update combat handler tracking
    UpdateCombatCLEUHandlers()

    logger:events(
        "Feature '%s' unregistered from CLEU subevent '%s'",
        modId, subevent
    )

    return true
end

--- Unregisters all CLEU subevent handlers for a module.
---@param modId string
---@return boolean success
function Core:UnregisterAllCombatLogEvents(modId)
    if not modId then
        return false
    end

    for subevent, reg in pairs(self.CombatLogRegistry) do
        if reg.byId[modId] then
            self:UnregisterCombatLogEvent(modId, subevent)
        end
    end

    return true
end

-- ============================================================================
-- Event Dispatchers (selected once at load time based on DEV.pcalls)
-- ============================================================================
-- Two variants per dispatcher: pcall-wrapped (dev/debug) and direct (production).
-- Selected at load time — zero runtime branching in the hot path.
-- All dispatchers use numeric for loops over flat lists for maximum throughput.
-- ============================================================================

local DispatchEvent, DispatchFilteredEvent, DispatchCombatLogEvent

if Core.DEV.pcalls then

    -- ── Unfiltered Frame Event Dispatcher (pcall) ───────────────────────────
    DispatchEvent = function(eventName, ...)
        local reg = Core.EventRegistry[eventName]
        if not reg then return end
        local list = reg.list
        for i = 1, reg.n do
            local entry = list[i]
            local checkFn = entry.checkFn
            if not checkFn or checkFn(...) then
                local ok, err = pcall(entry.callback, eventName, ...)
                if not ok then
                    local ct = (entry.modId:sub(1, 1) == "_") and "Component" or "Feature"
                    logger:error("%s '%s' event handler failed for '%s': %s",
                        ct, entry.modId, eventName, tostring(err))
                end
            end
        end
    end

    -- ── Filtered Frame Event Dispatcher (pcall) ─────────────────────────────
    DispatchFilteredEvent = function(eventName, ...)
        local reg = Core.EventRegistry[eventName]
        if not reg then return end

        local meta = FilteredEventMeta[eventName]

        -- Dedup: only extract when at least one handler wants it
        local isDuplicate = false
        if reg.dedupCount > 0 and meta.dedupArgIndex then
            local val = select(meta.dedupArgIndex, ...)
            if val then
                local seen = dedupSeen[eventName]
                if not seen then
                    seen = {}
                    dedupSeen[eventName] = seen
                end
                if seen[val] == dedupGeneration then
                    isDuplicate = true
                else
                    seen[val] = dedupGeneration
                end
            end
        end

        local list = reg.list
        for i = 1, reg.n do
            local entry = list[i]
            if not (entry.wantsUnique and isDuplicate)
               and (not entry.checkFn or entry.checkFn(...)) then
                local ok, err = pcall(entry.callback, eventName, ...)
                if not ok then
                    local ct = (entry.modId:sub(1, 1) == "_") and "Component" or "Feature"
                    logger:error("%s '%s' event handler failed for '%s': %s",
                        ct, entry.modId, eventName, tostring(err))
                end
            end
        end
    end

    -- ── CLEU Dispatcher (pcall) ─────────────────────────────────────────────
    DispatchCombatLogEvent = function()
        if States.inCombat and not HasCombatCLEUHandlers then
            return
        end

        local _, subevent, _,
              sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
              destGUID, destName, destFlags, destRaidFlags,
              arg12, arg13, arg14 = CombatLogGetCurrentEventInfo()

        local reg = Core.CombatLogRegistry[subevent]
        if not reg then return end

        -- Cache prefix args for filter closures (read via upvalue, zero C cost)
        cleu_arg12, cleu_arg13, cleu_arg14 = arg12, arg13, arg14

        local list = reg.list
        for i = 1, reg.n do
            local entry = list[i]
            local checkFn = entry.checkFn
            if not checkFn
               or checkFn(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                          destGUID, destName, destFlags, destRaidFlags) then
                local ok, err = pcall(entry.callback, CombatLogGetCurrentEventInfo())
                if not ok then
                    local ct = (entry.modId:sub(1, 1) == "_") and "Component" or "Feature"
                    logger:error("%s '%s' combat log handler failed for '%s': %s",
                        ct, entry.modId, subevent, tostring(err))
                end
            end
        end
    end

else -- Production path: direct calls, no pcall overhead

    -- ── Unfiltered Frame Event Dispatcher (direct) ──────────────────────────
    DispatchEvent = function(eventName, ...)
        local reg = Core.EventRegistry[eventName]
        if not reg then return end
        local list = reg.list
        for i = 1, reg.n do
            local entry = list[i]
            local checkFn = entry.checkFn
            if not checkFn or checkFn(...) then
                entry.callback(eventName, ...)
            end
        end
    end

    -- ── Filtered Frame Event Dispatcher (direct) ────────────────────────────
    DispatchFilteredEvent = function(eventName, ...)
        local reg = Core.EventRegistry[eventName]
        if not reg then return end

        local meta = FilteredEventMeta[eventName]

        local isDuplicate = false
        if reg.dedupCount > 0 and meta.dedupArgIndex then
            local val = select(meta.dedupArgIndex, ...)
            if val then
                local seen = dedupSeen[eventName]
                if not seen then
                    seen = {}
                    dedupSeen[eventName] = seen
                end
                if seen[val] == dedupGeneration then
                    isDuplicate = true
                else
                    seen[val] = dedupGeneration
                end
            end
        end

        local list = reg.list
        for i = 1, reg.n do
            local entry = list[i]
            if not (entry.wantsUnique and isDuplicate)
               and (not entry.checkFn or entry.checkFn(...)) then
                entry.callback(eventName, ...)
            end
        end
    end

    -- ── CLEU Dispatcher (direct) ────────────────────────────────────────────
    DispatchCombatLogEvent = function()
        if States.inCombat and not HasCombatCLEUHandlers then
            return
        end

        local _, subevent, _,
              sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
              destGUID, destName, destFlags, destRaidFlags,
              arg12, arg13, arg14 = CombatLogGetCurrentEventInfo()

        local reg = Core.CombatLogRegistry[subevent]
        if not reg then return end

        cleu_arg12, cleu_arg13, cleu_arg14 = arg12, arg13, arg14

        local list = reg.list
        for i = 1, reg.n do
            local entry = list[i]
            local checkFn = entry.checkFn
            if not checkFn
               or checkFn(sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                          destGUID, destName, destFlags, destRaidFlags) then
                entry.callback(CombatLogGetCurrentEventInfo())
            end
        end
    end

end -- DEV.pcalls branch

if Core.DEV.profiling then
    DispatchEvent = Core.Profiling:Wrap("DispatchEvent", DispatchEvent, true)
    DispatchCombatLogEvent = Core.Profiling:Wrap("DispatchCombatLogEvent", DispatchCombatLogEvent, true)
end

-- ============================================================================
-- Frame Event Handler
-- ============================================================================

EventFrame:SetScript("OnEvent", function(self, event, ...)
    -- Lazy-resolve States upvalue once (Events.lua loads before State.lua)
    if not States then States = Core.States end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        DispatchCombatLogEvent()
    elseif FilteredEventMeta[event] then
        DispatchFilteredEvent(event, ...)
    else
        DispatchEvent(event, ...)
    end
end)


-- ============================================================================
-- Utility Functions
-- ============================================================================

--- Returns registered frame events for a module, or the full registry.
---@param modId? string
---@return string[]|table
function Core:GetRegisteredEvents(modId)
    if not modId then
        return self.EventRegistry
    end

    local events = {}
    local count = 0
    for eventName, reg in pairs(self.EventRegistry) do
        if reg.byId[modId] then
            count = count + 1
            events[count] = eventName
        end
    end

    return events
end

--- Returns registered CLEU subevents for a module, or the full registry.
---@param modId? string
---@return string[]|table
function Core:GetRegisteredCombatLogEvents(modId)
    if not modId then
        return self.CombatLogRegistry
    end

    local subevents = {}
    local count = 0
    for subevent, reg in pairs(self.CombatLogRegistry) do
        if reg.byId[modId] then
            count = count + 1
            subevents[count] = subevent
        end
    end

    return subevents
end
