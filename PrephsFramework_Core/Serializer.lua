--[[
    <PrephsFramework_Core/Serializer.lua>
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

---@class PrephsFramework.Serializer
Core.Serializer = {}

local LibDeflate = Core.LibDeflate

local type = type
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local table_concat = table.concat
local string_sub = string.sub
local string_byte = string.byte
local string_find = string.find
local string_gsub = string.gsub

-- Header prefix for identifying packed data and versioning the format.
local PACK_HEADER = "!PF1!"
local HEADER_LEN = #PACK_HEADER

-- Delimiters: ASCII control characters that won't appear in normal addon data.
local RS  = "\030" -- Record Separator: token delimiter
local ESC = "\031" -- Unit Separator:   escape character

-- Byte values for fast tag comparison during deserialization.
local BYTE_N     = string_byte("N")  -- 78  number
local BYTE_S     = string_byte("S")  -- 83  string
local BYTE_TRUE  = string_byte("B")  -- 66  boolean true
local BYTE_FALSE = string_byte("b")  -- 98  boolean false
local BYTE_OPEN  = string_byte("{")  -- 123 table open
local BYTE_CLOSE = string_byte("}")  -- 125 table close

-- ============================================================================
-- Escape / Unescape
-- String payloads may contain RS or ESC bytes; these must be escaped so the
-- token boundary (RS) is never ambiguous.
-- Order matters: escape ESC first, then RS. Unescape in reverse order.
-- ============================================================================

local function escape(s)
    s = string_gsub(s, ESC, ESC .. "U")
    s = string_gsub(s, RS,  ESC .. "R")
    return s
end

local function unescape(s)
    s = string_gsub(s, ESC .. "R", RS)
    s = string_gsub(s, ESC .. "U", ESC)
    return s
end

-- ============================================================================
-- Serialization  (value → string)
-- ============================================================================

local function serializeValue(value, parts)
    local vtype = type(value)

    if vtype == "number" then
        parts[#parts + 1] = "N" .. tostring(value)

    elseif vtype == "string" then
        parts[#parts + 1] = "S" .. escape(value)

    elseif vtype == "boolean" then
        parts[#parts + 1] = value and "B" or "b"

    elseif vtype == "table" then
        parts[#parts + 1] = "{"
        for k, v in pairs(value) do
            serializeValue(k, parts)
            serializeValue(v, parts)
        end
        parts[#parts + 1] = "}"
    end
    -- nil is skipped; it cannot exist as a table value or key.
end

local function serialize(data)
    local parts = {}
    serializeValue(data, parts)
    return table_concat(parts, RS)
end

-- ============================================================================
-- Deserialization  (string → value)
-- ============================================================================

local function deserialize(str)
    local pos = 1
    local len = #str

    local function readToken()
        local nextRS = string_find(str, RS, pos, true)
        local token
        if nextRS then
            token = string_sub(str, pos, nextRS - 1)
            pos = nextRS + 1
        else
            token = string_sub(str, pos)
            pos = len + 1
        end
        return token
    end

    local readValue -- forward declaration for recursion

    readValue = function()
        if pos > len then return nil end

        local token = readToken()
        if not token or token == "" then return nil end

        local tag = string_byte(token, 1)

        if tag == BYTE_N then
            return tonumber(string_sub(token, 2))

        elseif tag == BYTE_S then
            return unescape(string_sub(token, 2))

        elseif tag == BYTE_TRUE then
            return true

        elseif tag == BYTE_FALSE then
            return false

        elseif tag == BYTE_OPEN then
            local tbl = {}
            while pos <= len and string_byte(str, pos) ~= BYTE_CLOSE do
                local k = readValue()
                if k == nil then break end
                local v = readValue()
                tbl[k] = v
            end
            if pos <= len then
                readToken() -- consume the "}" token
            end
            return tbl
        end

        return nil
    end

    return readValue()
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Serialize and compress a Lua value into a compact, encoded string.
--- The result is a single printable string safe for SavedVariables storage,
--- collapsing an entire table hierarchy into one key.
---
--- Usage:
---   local packed = Core.Serializer:Pack(myBigTable)
---   MyAddonDB.cachedData = packed  -- single SV key instead of thousands
---
---@param data any  The value to pack (table, number, string, boolean)
---@param level number?  Compression level 1-9 (default 6; higher = smaller but slower)
---@return string|nil encoded  The packed string, or nil on failure
---@return string|nil error    Error message on failure
function Core.Serializer:Pack(data, level)
    if not LibDeflate then
        return nil, "LibDeflate not available"
    end

    local serialized = serialize(data)

    local compressed = LibDeflate:CompressDeflate(serialized, { level = level or 6 })
    if not compressed then
        return nil, "Compression failed"
    end

    local encoded = LibDeflate:EncodeForPrint(compressed)
    return PACK_HEADER .. encoded
end

--- Decode, decompress, and deserialize a packed string back into a Lua value.
---
---@param encoded string  The packed string produced by Pack()
---@return any|nil data   The original value, or nil on failure
---@return string|nil error  Error message on failure
function Core.Serializer:Unpack(encoded)
    if not LibDeflate then
        return nil, "LibDeflate not available"
    end

    if type(encoded) ~= "string" then
        return nil, "Expected string"
    end

    if string_sub(encoded, 1, HEADER_LEN) ~= PACK_HEADER then
        return nil, "Invalid packed data (missing header)"
    end

    local payload = string_sub(encoded, HEADER_LEN + 1)

    local decoded = LibDeflate:DecodeForPrint(payload)
    if not decoded then
        return nil, "Decode failed"
    end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then
        return nil, "Decompression failed"
    end

    return deserialize(decompressed)
end

--- Check whether a value looks like data produced by Pack().
--- Useful for migration: detect whether a SavedVariable entry is raw or packed.
---
---@param value any
---@return boolean
function Core.Serializer:IsPacked(value)
    return type(value) == "string" and string_sub(value, 1, HEADER_LEN) == PACK_HEADER
end

-- ============================================================================
-- Addon Channel Encoding
-- ============================================================================
-- Like Pack/Unpack but uses EncodeForWoWAddonChannel instead of EncodeForPrint,
-- producing strings safe for C_ChatInfo.SendAddonMessage.
-- ============================================================================

--- Serialize, compress, and encode for WoW addon channel transmission.
---@param data any
---@param level number?  Compression level 1-9 (default 4)
---@return string|nil encoded
---@return string|nil error
function Core.Serializer:PackForChannel(data, level)
    if not LibDeflate then return nil, "LibDeflate not available" end

    local serialized = serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized, { level = level or 4 })
    if not compressed then return nil, "Compression failed" end

    local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
    if not encoded then return nil, "Channel encode failed" end
    return encoded
end

--- Decode and decompress a string produced by PackForChannel.
---@param encoded string
---@return any|nil data
---@return string|nil error
function Core.Serializer:UnpackFromChannel(encoded)
    if not LibDeflate then return nil, "LibDeflate not available" end
    if type(encoded) ~= "string" then return nil, "Expected string" end

    local decoded = LibDeflate:DecodeForWoWAddonChannel(encoded)
    if not decoded then return nil, "Channel decode failed" end

    local decompressed = LibDeflate:DecompressDeflate(decoded)
    if not decompressed then return nil, "Decompression failed" end

    return deserialize(decompressed)
end
