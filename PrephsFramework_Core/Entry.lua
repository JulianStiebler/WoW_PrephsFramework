--[[
    <PrephsFramework_Core/Entry.lua>
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
local versionString = GetAddOnMetadata(addonName, "Version") or "1.0.0"
local LibStub = LibStub
local string = string
local CreateFrame = CreateFrame

---@class PrephsFramework
---@field DB PrephsFrameworkDB Persisted account-wide SavedVariable database
ns.PF = LibStub:NewLibrary(string.format("%s-%s", addonName, versionString), 1) or LibStub:GetLibrary(string.format("%s-%s", addonName, versionString))
if not ns.PF then return end


---@alias PrephsFrameworkVersion string Version string following SemVer2

---@type PrephsFramework
local Core = ns.PF


---@class PrephsFramework.DEV
ns.PF.DEV = Core.DEV or {}
ns.PF.DEV.profiling = false
ns.PF.DEV.pcalls = false
ns.PF.DEV.testing = false
ns.PF.DEV.isDebugBuild = false

-- ============================================================================
-- Implement and expose third party libraries
-- ============================================================================

-- RegisterCallback, UnregisterCallback, and UnregisterAllCallbacks are embedded by CallbackHandler
---@class CallbackHandler-1.0 : CallbackHandlerTarget
ns.PF.Callbacks = Core.Callbacks or {}
local callbackRegistry = LibStub("CallbackHandler-1.0"):New(Core.Callbacks)
ns.PF.Callbacks.Fire = function(self, ...) return callbackRegistry:Fire(...) end


-- Strictly not a third party library we still house it in this section.
-- It needs to be initalized after CallbackHandler as it uses it for callback management for logMask.
---@class PrephsFramework.Logger
ns.PF.Logger = LibStub("PrephsFramework-Logger-1.0"):Embed(Core.Logger or {}, "PrephsFramework")

---@class HereBeDragons-2.0
ns.PF.HBD = LibStub("HereBeDragons-2.0", true)

---@class HereBeDragons-Pins-2.0
ns.PF.HBDPins = LibStub("HereBeDragons-Pins-2.0", true)

---@class LibButtonGlow-1.0
ns.PF.LibBtnGlow = LibStub("LibButtonGlow-1.0", true)

---@class LibSharedMedia-3.0
ns.PF.SharedMedia = LibStub("LibSharedMedia-3.0", true)

---@class LibDeflate
ns.PF.LibDeflate = LibStub("LibDeflate", true)

-- ============================================================================
-- Core Data Structure Initialization
-- ============================================================================

ns.PF.SystemPages = Core.SystemPages or {}

---@class PrephsFramework.data
ns.PF.data = Core.data or {}
---@class PrephsFramework.data.npcData
ns.PF.data.npcData = Core.data.npcData or {}
---@class PrephsFramework.data.mapData
ns.PF.data.mapData = Core.data.mapData or {}
---@class PrephsFramework.data.questData
ns.PF.data.questData = Core.data.questData or {}
---@class PrephsFramework.data.charData
ns.PF.data.charData = Core.data.charData or {}
---@class PrephsFramework.data.objData
ns.PF.data.objData = Core.data.objData or {}

---@class ConstantTable
ns.PF.Constants = Core.Constants or {}

-- Module registries
ns.PF.Modules = Core.Modules or {}
ns.PF.DiscoveredModules = Core.DiscoveredModules or {}
ns.PF.RegisteredModules = Core.RegisteredModules or {}


---@class PrephsFramework.UI
ns.PF.UI = Core.UI or {}
---@class PrephsFramework.UI.Factory
ns.PF.UI.Factory = Core.UI.Factory or {}
ns.PF.UI.expandedModules = Core.UI.expandedModules or {}
ns.PF.UI.CustomFrames = Core.UI.CustomFrames or {}
ns.PF.UI.elementSequence = Core.UI.elementSequence or 0

--- Default main frame size/position/resize config (same shape as ModuleFrameSize)
---@type ModuleFrameSize
ns.PF.MainFrameSize = { w = 900, h = 700, resizable = true }

ns.PF.EventRegistry = Core.EventRegistry or {}
ns.PF.CombatLogRegistry = Core.CombatLogRegistry or {}
ns.PF.EventFrame = Core.EventFrame or CreateFrame("Frame", "PrephsFramework_EventFrame")
ns.PF.DB = nil
ns.PF.ActiveFeatures = Core.ActiveFeatures or {}

---@class PrephsFramework.Util
ns.PF.Util = Core.Util or {}

---@class PrephsFramework.Indexer
ns.PF.Indexer = Core.Indexer or {}

---@class PrephsFramework.CommLink
ns.PF.CommLink = Core.CommLink or {}

--- Per-character live data table (initialised by Database:InitializeCharDataDB)
---@type PFCharacterSnapshot|nil
ns.PF.CharData = nil
