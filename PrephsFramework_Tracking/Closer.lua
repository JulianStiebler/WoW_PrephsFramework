--[[
    <PrephsFramework_Tracking/Closer.lua>
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

-- Get Core reference
---@type PrephsFramework
local Core = ns.PF

local MOD_ID = "Tracking"
local logger = Core.Logger
local LIP = ns.LipTracker
local WTP = ns.WorldTrackingPins

-- ============================================================================
-- Module Definition
-- ============================================================================

---@type ModuleData
local TrackingModule = {
    features = {
        LipTracker         = LIP.feature,
        WorldTrackingPins  = WTP.feature,
    },

    frames = {
        lipboard = LIP.frame,
    },

    OnInitialize = function()
        if not PrephsFramework_TrackingDB then
            PrephsFramework_TrackingDB = {}
        end
        LIP.InitDB(PrephsFramework_TrackingDB)

        -- LoadOnDemand modules are loaded after PLAYER_ENTERING_WORLD has fired,
        -- so the feature's registered PEW handler never runs on the initial login.
        -- Manually activate WTP here if the feature should be active.
        if Core:ShouldFeatureBeActive(MOD_ID, "WorldTrackingPins") then
            WTP.Activate()
        end

        logger:init("Tracking module initialized")
    end,

    OnFeatureStateChanged = function(featureName, enabled)
        logger:features("Feature '%s' %s", featureName, enabled and "enabled" or "disabled")
        if featureName == "WorldTrackingPins" then
            if enabled then
                WTP.Activate()
            else
                WTP.Deactivate()
            end
        end
    end,

    OnSettingChanged = function(featureName, key, value)
        WTP.OnSettingChanged(featureName, key, value)
    end,
}

-- Register — moduleID must match X-PrephsFramework-ModuleID (spaces become underscores)
Core:RegisterModule(MOD_ID, TrackingModule)

