--[[
    <PrephsFramework_Core/CoreAPI.lua>
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
local keyRef = Core.Constants.ENUM.KeyRef

--[[
Check if the configured backup/modifier key is currently pressed.

https://warcraft.wiki.gg/wiki/API_IsModifierKeyDown
]]
---@return boolean True if the backup key is pressed, false otherwise
function Core:IsBackupKeyPressed()
    local backupKey = (self.DB.shared and self.DB.shared.backupKey) or keyRef.SHIFT_KEY
    
    if backupKey == keyRef.ALT_KEY then
        return IsLeftAltKeyDown()
    elseif backupKey == keyRef.CTRL_KEY then
        return IsLeftControlKeyDown()
    elseif backupKey == keyRef.SHIFT_KEY then
        return IsLeftShiftKeyDown()
    elseif backupKey == keyRef.RALT_KEY then
        return IsRightAltKeyDown()
    elseif backupKey == keyRef.RCTRL_KEY then
        return IsRightControlKeyDown()
    elseif backupKey == keyRef.RSHIFT_KEY then
        return IsRightShiftKeyDown()
    end
    
    return false
end

---@return boolean True if the extra modifier key is currently pressed
function Core:IsExtraKeyPressed()
    local extraKey = (self.DB.shared and self.DB.shared.extraKey) or keyRef.ALT_KEY
    local backupKey = (self.DB.shared and self.DB.shared.backupKey) or keyRef.SHIFT_KEY

    -- Guard: extra key must differ from backup key; fall back to Alt (or Ctrl if Alt is taken)
    if extraKey == backupKey then
        extraKey = (backupKey ~= keyRef.ALT_KEY) and keyRef.ALT_KEY or keyRef.CTRL_KEY
    end

    if extraKey == keyRef.ALT_KEY then
        return IsLeftAltKeyDown()
    elseif extraKey == keyRef.CTRL_KEY then
        return IsLeftControlKeyDown()
    elseif extraKey == keyRef.RALT_KEY then
        return IsRightAltKeyDown()
    elseif extraKey == keyRef.RCTRL_KEY then
        return IsRightControlKeyDown()
    end

    return false
end

---@alias mapType number
---@return uiMapID|nil, mapType|nil The current zone's UI Map ID and mapType, or nil if undetermined
function Core:GetCurrentZoneID()
    if Core.HBD then
        local uiMapID, mapType = Core.HBD:GetPlayerZone()
        return uiMapID, mapType
    end
    
    -- Fallback to C_Map API (no mapType available)
    if C_Map and C_Map.GetBestMapForUnit then
        local uiMapID = C_Map.GetBestMapForUnit("player")
        return uiMapID, nil
    end
    
    return nil, nil
end
