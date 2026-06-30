--[[
    <PrephsFramework_Core/State.lua>
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

local logger = Core.Logger

-- Localize C API calls used during event handlers
local InCombatLockdown  = InCombatLockdown
local IsInRaid          = IsInRaid
local IsInGroup         = IsInGroup
local IsInInstance      = IsInInstance
local UnitGUID          = UnitGUID
local UnitLevel         = UnitLevel
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitClass         = UnitClass
local UnitFactionGroup  = UnitFactionGroup
local GetZoneText       = GetZoneText
local GetSubZoneText    = GetSubZoneText
local GetRealmName      = GetRealmName
local GetInstanceInfo   = GetInstanceInfo
local IsResting         = IsResting
local select            = select
local GetUnitName       = GetUnitName

-- ============================================================================
-- Core.State — Flat, event-driven player state
-- ============================================================================
-- Data structure defined in characterData.lua (PFState).
-- This file references it as a flat local for efficient field access
-- and registers events to keep it current.
-- ============================================================================
---@class PFState
---@field inCombat boolean Player is in combat (PLAYER_REGEN_DISABLED / ENABLED)
---@field inInstance boolean Player is inside an instance
---@field instanceType string Instance type: "party", "raid", "arena", "pvp", "scenario", "none"
---@field instanceName string Current instance name (empty when outdoors)
---@field inRaid boolean Player is in a raid group
---@field inGroup boolean Player is in any group (party or raid)
---@field isAlive boolean Player is alive (not dead/ghost)
---@field isResting boolean Player is in a resting area (inn/city)
---@field uiMapID number|nil Current UI map ID (HBD / C_Map.GetBestMapForUnit)
---@field mapType number|nil Enum.UIMapType from HBD (Cosmic/World/Continent/Zone/Dungeon/Micro)
---@field instanceMapID number|nil Continent / instance world map ID (0=EK, 1=Kalimdor, etc.)
---@field zoneName string Current zone name (GetZoneText)
---@field subZoneName string Current sub-zone name (GetSubZoneText)
---@field playerGUID string Player GUID
---@field playerName string Player display name (GetUnitName)
---@field playerLevel number Player level
---@field playerClass string Localized class name (e.g. "Warrior")
---@field playerClassFile string Uppercase class token (e.g. "WARRIOR")
---@field playerRealm string Player's realm name
---@field playerFaction string Player's faction ("Alliance" or "Horde")
---@field accountGUID string Full player GUID used for same-account detection
local States = {
    inCombat       = false,
    inInstance     = false,
    instanceType   = "none",
    instanceName   = "",
    inRaid         = false,
    inGroup        = false,
    isAlive        = true,
    isResting      = false,
    uiMapID        = nil,
    mapType        = nil,
    instanceMapID  = nil,
    zoneName       = "",
    subZoneName    = "",
    playerGUID     = "",
    playerLevel    = 0,
    playerName     = "",
    playerClass    = "",
    playerClassFile = "",
    playerRealm    = "",
    playerFaction  = "",
}

Core.States = States

-- ============================================================================
-- Getters — thin wrappers for consumers who prefer method-call style
-- ============================================================================

---@return boolean
function Core:IsInCombat()      return States.inCombat end
---@return boolean
function Core:IsInInstance()    return States.inInstance end
---@return string
function Core:GetInstanceType() return States.instanceType end
---@return boolean
function Core:IsInRaid()        return States.inRaid end
---@return boolean
function Core:IsInGroup()       return States.inGroup end
---@return boolean
function Core:IsAlive()         return States.isAlive end
---@return number|nil
function Core:GetUIMapID()      return States.uiMapID end
---@return number|nil
function Core:GetMapType()      return States.mapType end
---@return number|nil
function Core:GetInstanceMapID() return States.instanceMapID end
---@return string
function Core:GetZoneName()     return States.zoneName end
---@return string
function Core:GetSubZoneName()  return States.subZoneName end
---@return string
function Core:GetPlayerGUID()   return States.playerGUID end
---@return number
function Core:GetPlayerLevel()  return States.playerLevel end
---@return string
function Core:GetPlayerName()   return States.playerName end
---@return string
function Core:GetPlayerClass()  return States.playerClass end
---@return string
function Core:GetPlayerClassFile() return States.playerClassFile end
---@return string
function Core:GetPlayerRealm()  return States.playerRealm end
---@return string
function Core:GetPlayerFaction() return States.playerFaction end
---@return boolean
function Core:IsResting()       return States.isResting end
---@return string
function Core:GetInstanceName() return States.instanceName end

-- ============================================================================
-- Full snapshot — called once on PLAYER_ENTERING_WORLD and from Closer init
-- ============================================================================

-- Helper: refresh all zone/map fields from current APIs
local function RefreshZoneState()
    local uiMapID, mapType = Core:GetCurrentZoneID()
    States.uiMapID      = uiMapID
    States.mapType       = mapType
    local instanceName, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    States.instanceName  = instanceName or ""
    States.instanceMapID = instanceMapID
    States.zoneName      = GetZoneText() or ""
    States.subZoneName   = GetSubZoneText() or ""
end

function Core:RefreshFullState()
    States.playerGUID  = UnitGUID("player") or ""
    States.playerName  = GetUnitName("player", true) or ""
    States.playerLevel = UnitLevel("player") or 0
    States.isAlive     = not UnitIsDeadOrGhost("player")
    States.inCombat    = InCombatLockdown()
    States.isResting   = IsResting()
    States.inRaid      = IsInRaid()
    States.inGroup     = IsInGroup()

    local className, classFile = UnitClass("player")
    States.playerClass     = className or ""
    States.playerClassFile = classFile or ""
    States.playerRealm     = GetRealmName() or ""
    States.playerFaction   = UnitFactionGroup("player") or ""

    -- Derive account GUID: strip the trailing character-specific portion.
    -- Player GUIDs look like "Player-<serverID>-<charHex>"; the account
    -- relationship is tested via C_AccountInfo.IsGUIDRelatedToLocalAccount.
    -- We store the full GUID and use the API check at runtime.
    States.accountGUID = States.playerGUID

    local inInstance, instanceType = IsInInstance()
    States.inInstance   = inInstance
    States.instanceType = instanceType or "none"

    RefreshZoneState()
end

if Core.DEV.profiling then
    Core.RefreshFullState = Core.Profiling:Wrap("RefreshFullState", Core.RefreshFullState, true)
end

-- ============================================================================
-- Event Registrations — internal component prefix "_State"
-- ============================================================================

-- Combat
Core:RegisterEvent("_State", "PLAYER_REGEN_DISABLED", function()
    States.inCombat = true
end)

Core:RegisterEvent("_State", "PLAYER_REGEN_ENABLED", function()
    States.inCombat = false
end)

-- Alive / Dead
Core:RegisterEvent("_State", "PLAYER_DEAD", function()
    States.isAlive = false
end)

Core:RegisterEvent("_State", "PLAYER_UNGHOST", function()
    States.isAlive = true
end)

-- Group changes
Core:RegisterEvent("_State", "GROUP_ROSTER_UPDATE", function()
    States.inRaid  = IsInRaid()
    States.inGroup = IsInGroup()
end)

-- Zone / instance changes
Core:RegisterEvent("_State", "ZONE_CHANGED_NEW_AREA", function()
    local inInstance, instanceType = IsInInstance()
    States.inInstance   = inInstance
    States.instanceType = instanceType or "none"
    RefreshZoneState()
end)

Core:RegisterEvent("_State", "ZONE_CHANGED", function()
    States.uiMapID      = Core:GetCurrentZoneID()
    States.zoneName     = GetZoneText() or ""
    States.subZoneName  = GetSubZoneText() or ""
end)

Core:RegisterEvent("_State", "ZONE_CHANGED_INDOORS", function()
    States.uiMapID      = Core:GetCurrentZoneID()
    States.subZoneName  = GetSubZoneText() or ""
end)

-- Level up
Core:RegisterEvent("_State", "PLAYER_LEVEL_UP", function(_, newLevel)
    States.playerLevel = newLevel
end)

-- Resting status
Core:RegisterEvent("_State", "PLAYER_UPDATE_RESTING", function()
    States.isResting = IsResting()
end)
