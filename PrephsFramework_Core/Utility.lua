--[[
    <PrephsFramework_Core/Utility.lua>
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
---@class PrephsFramework.Util
local Util = Core.Util or {}


local math = math
local pairs = pairs
local type = type
local next = next
local setmetatable = setmetatable
local getmetatable = getmetatable
local strmatch = string.match
local tonumber = tonumber

local COLOR_LABEL  = "|cffAAAAAA"
local COLOR_COUNT  = "|cffFFD100"
local concat       = table.concat
local format       = string.format
local CLASS_COLORS = RAID_CLASS_COLORS
 
-- Rounds a number to a specified number of decimal places
---@param num number The number to round
---@param decimalPlaces number The number of decimal places to round to
---@return number rounded The rounded number
function Util:Round(num, decimalPlaces)
    if (not num) then
        return 0
    end
    local mult = 10^(decimalPlaces)
    return math.floor(num * mult + 0.5) / mult
end

-- Gets the size of a table (number of key-value pairs)
---@param table table The table to get the size of
---@return number size  The size of the table
function Util:GetTableSize(table)
    local size = 0
    for _ in pairs(table) do size = size + 1 end
    return size
end

-- Deep copies a table, including nested tables
---@param original table The table to deep copy
---@return table copy The deep copied table
function Util:DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[Util:DeepCopy(key)] = Util:DeepCopy(value)
        end
        setmetatable(copy, Util:DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

---@param tab table The table to count
---@return number count The number of key-value pairs in the table
function Util:tcount(tab)
    local n = 0
    for _ in pairs(tab) do
        n = n + 1
    end
    return n
end

--- Wraps a zero-arg function in a lazy-evaluated, resettable cache.
--- The returned table is callable (via __call); first call invokes `t`,
--- subsequent calls return the cached result until resetCache() is called.
---@param t fun(): any The function to memoize (must accept zero arguments)
---@return table memoized Callable table with .resetCache() method
function Util:memoize(t)
    local cache = nil

    local memoized = {}

    local function get()
        if (cache == nil) then
            cache = t()
        end

        return cache
    end

    memoized.resetCache = function()
        cache = nil
    end

    setmetatable(memoized, {__call = get})

    return memoized
end


--- Build a WoW texture escape sequence string.
---@param path string Texture file path or ID
---@param size number Icon size in pixels
---@return string iconString WoW |T...|t texture string
function Util:IconStr(path, size)
    return "|T" .. path .. ":" .. size .. "|t"
end

--- Format a copper amount into a coloured gold/silver/copper string with icons.
---@param copper number? Total amount in copper
---@param iconSize number Icon pixel size for gold/silver/copper icons
---@return string formatted Coloured money string
function Util:FormatMoney(copper, iconSize)
    local iGold   = Util:IconStr("Interface\\MoneyFrame\\UI-GoldIcon", iconSize)
    local iSilver = Util:IconStr("Interface\\MoneyFrame\\UI-SilverIcon", iconSize)
    local iCopper = Util:IconStr("Interface\\MoneyFrame\\UI-CopperIcon", iconSize)
    if not copper or copper == 0 then return COLOR_LABEL .. "0" .. iCopper .. "|r" end
    local gold   = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local cop    = copper % 100
    local parts  = {}
    if gold > 0   then parts[#parts + 1] = COLOR_COUNT .. gold .. "|r" .. iGold end
    if silver > 0 then parts[#parts + 1] = COLOR_COUNT .. silver .. "|r" .. iSilver end
    if cop > 0    then parts[#parts + 1] = COLOR_COUNT .. cop .. "|r" .. iCopper end
    return concat(parts, " ")
end


--- Wrap a name in its class colour using RAID_CLASS_COLORS.
---@param name string Character name
---@param classFile string? Uppercase class token (e.g. "WARRIOR")
---@return string colouredName The name wrapped in class colour codes, or plain name if no class
function Util:ColorClass(name, classFile)
    if classFile and CLASS_COLORS and CLASS_COLORS[classFile] then
        local c = CLASS_COLORS[classFile]
        return format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, name)
    end
    return name
end

--- Return a class-coloured character name.
---@param name string
---@param classFile string|nil
---@return string
function Util:ColoredCharName(name, classFile)
    if classFile and CLASS_COLORS and CLASS_COLORS[classFile] then
        local c = CLASS_COLORS[classFile]
        return format("|cff%02x%02x%02x%s|r", c.r * 255, c.g * 255, c.b * 255, name)
    end
    return name
end

-- ============================================================================
-- Generic Table Delta — efficient diff / merge for any keyed table
-- ============================================================================
-- Replaces the per-type delta engines (items, professions) in consumer
-- modules with a single reusable implementation.
--
-- Usage:
--   local snap = Util:SnapshotTable(tbl, {"field1","field2"})  -- baseline
--   ... time passes, tbl changes ...
--   local changed, removed = Util:ComputeTableDelta(snap, tbl, {"field1","field2"})
--   -- send changed + removed
--   Util:ApplyTableDelta(remoteTbl, changed, removed)          -- merge on receiver
-- ============================================================================

--- Create a shallow snapshot of a keyed table for later comparison.
--- If `fields` is provided, only those fields are copied per row (cheaper
--- comparison later).  If nil, full shallow copy of each value.
---@param tbl table<any, table>  Source table (e.g. itemCounts, professions)
---@param fields string[]|nil    Optional list of field names to snapshot
---@return table snapshot  { [key] = { field1=v, field2=v, ... } }
function Util:SnapshotTable(tbl, fields)
    local snap = {}
    if not tbl then return snap end
    if fields then
        for k, row in pairs(tbl) do
            local s = {}
            for _, f in ipairs(fields) do
                local v = row[f]
                -- Shallow-copy sub-tables (e.g. array of recipes) so later
                -- comparisons see the value at snapshot time, not a live ref.
                if type(v) == "table" then
                    local copy = {}
                    for sk, sv in pairs(v) do copy[sk] = sv end
                    s[f] = copy
                else
                    s[f] = v
                end
            end
            snap[k] = s
        end
    else
        for k, row in pairs(tbl) do
            if type(row) == "table" then
                local s = {}
                for rk, rv in pairs(row) do s[rk] = rv end
                snap[k] = s
            else
                snap[k] = row
            end
        end
    end
    return snap
end

--- Compare a previous snapshot against the current table and return the
--- rows that changed plus the keys that were removed.
---
--- `fields` controls which fields are compared.  When nil every field in
--- the snapshot row is compared.  Returns nil, nil when nothing changed.
---@param oldSnap table           Previous snapshot from SnapshotTable
---@param current table           Current live table
---@param fields string[]|nil     Fields to compare (nil = all keys in snapshot row)
---@return table|nil changed      Entries that are new or differ (live references)
---@return any[]|nil removed      Keys present in oldSnap but absent in current
function Util:ComputeTableDelta(oldSnap, current, fields)
    if not oldSnap then oldSnap = {} end
    if not current then current = {} end

    local changed, removed
    local hasChanges = false

    -- Detect additions and modifications
    for k, row in pairs(current) do
        local old = oldSnap[k]
        if not old then
            changed = changed or {}
            changed[k] = row
            hasChanges = true
        else
            local differs = false
            if fields then
                for _, f in ipairs(fields) do
                    local ov, nv = old[f], row[f]
                    if type(ov) == "table" or type(nv) == "table" then
                        -- Tables: compare element count + values (one level)
                        if type(ov) ~= type(nv) then
                            differs = true; break
                        end
                        local ot, nt = ov, nv
                        for tk, tv in pairs(nt) do
                            if ot[tk] ~= tv then differs = true; break end
                        end
                        if not differs then
                            for tk in pairs(ot) do
                                if nt[tk] == nil then differs = true; break end
                            end
                        end
                        if differs then break end
                    elseif ov ~= nv then
                        differs = true; break
                    end
                end
            else
                -- Compare all fields in old row
                for f, ov in pairs(old) do
                    if row[f] ~= ov then differs = true; break end
                end
                if not differs then
                    for f in pairs(row) do
                        if old[f] == nil then differs = true; break end
                    end
                end
            end
            if differs then
                changed = changed or {}
                changed[k] = row
                hasChanges = true
            end
        end
    end

    -- Detect removals
    for k in pairs(oldSnap) do
        if current[k] == nil then
            removed = removed or {}
            removed[#removed + 1] = k
            hasChanges = true
        end
    end

    if not hasChanges then return nil, nil end
    return changed, removed
end

--- Merge a delta into a target table: upsert changed entries, delete removed.
---@param target table            The table to patch (modified in-place)
---@param changed table|nil       Key → value entries to add/overwrite
---@param removed any[]|nil       Keys to delete
function Util:ApplyTableDelta(target, changed, removed)
    if changed then
        for k, v in pairs(changed) do
            target[k] = v
        end
    end
    if removed then
        for _, k in ipairs(removed) do
            target[k] = nil
        end
    end
end

---@param link string  Full item hyperlink
---@return number itemID, number enchantID, number gem1, number gem2, number gem3, number gem4, number suffixID, number uniqueID
function Util:ParseItemLink(link)
    if not link then return 0,0,0,0,0,0,0,0 end
    local id, ench, g1, g2, g3, g4, suf, uid =
        strmatch(link, "item:(%d+):(%d*):(%d*):(%d*):(%d*):(%d*):([%-]?%d*):(%d*)")
    return tonumber(id)   or 0,
           tonumber(ench) or 0,
           tonumber(g1)   or 0,
           tonumber(g2)   or 0,
           tonumber(g3)   or 0,
           tonumber(g4)   or 0,
           tonumber(suf)  or 0,
           tonumber(uid)  or 0
end
