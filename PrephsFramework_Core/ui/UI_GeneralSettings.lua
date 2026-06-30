--[[
    <PrephsFramework_Core/UI/UI_GeneralSettings.lua>
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

---@class PrephsFramework.UI
local UI = Core.UI

---@type PrephsFramework.KeyRef
local keyRef = Core.Constants.ENUM.KeyRef

local pairs = pairs
local table = table
local StaticPopup_Show = StaticPopup_Show

-- ============================================================================
-- General Settings Page
-- ============================================================================

-- General Settings Page Definition
---@type PrephsFramework.SystemPage
Core.SystemPages.general = {
    moduleName = "General Settings",
    features = {
        {
            name = "Shared Framework Settings",
            description = "Settings available to all modules",
            elements = {
                {
                    type = "DependentDropdown",
                    label = "Backup Modifier Key",
                    description = "Key modifier used by modules for secondary/backup actions",
                    options = (function()
                        local opts = {}
                        for _, value in pairs(Core.Constants.ENUM.KeyRef) do
                            table.insert(opts, value)
                        end
                        return opts
                    end)(),
                    get = function()
                        return Core.DB.shared.backupKey or keyRef.SHIFT_KEY
                    end,
                    set = function(value)
                        Core.DB.shared.backupKey = value
                    end,
                    isOptionDisabled = function(option)
                        local extraKey = Core.DB.shared.extraKey or keyRef.ALT_KEY
                        if option == extraKey then
                            return "used as Extra key"
                        end
                    end,
                },
                {
                    type = "DependentDropdown",
                    label = "Extra Modifier Key",
                    description = "Secondary modifier key (Alt / Ctrl only, cannot match Backup key)",
                    options = { keyRef.ALT_KEY, keyRef.RALT_KEY, keyRef.CTRL_KEY, keyRef.RCTRL_KEY },
                    get = function()
                        return Core.DB.shared.extraKey or keyRef.ALT_KEY
                    end,
                    set = function(value)
                        Core.DB.shared.extraKey = value
                    end,
                    isOptionDisabled = function(option)
                        local backupKey = Core.DB.shared.backupKey or keyRef.SHIFT_KEY
                        if option == backupKey then
                            return "used as Backup key"
                        end
                    end,
                },
                {
                    type = "Slider",
                    label = "Update Interval",
                    description = "A global numeric value that dictates update frequencys aswell as debounce timers for various modules. Setting this to a higher value can improve performance, but may cause some features to feel less responsive.",
                    min = 0.1,
                    max = 5.0,
                    step = 0.1,
                    get = function()
                        return Core.DB.shared.updateInterval or 0.5
                    end,
                    set = function(value)
                        Core.DB.shared.updateInterval = value
                        if Core.DB and Core.DB.shared then
                            Core.DB.shared.updateInterval = value
                        end
                    end
                }
            },
            showSeparator = true,
        },
        {
            name = "Database Management",
            description = "Reset and manage addon settings",
            elements = {
                {
                    type = "Button",
                    label = "Reset All Settings",
                    description = "This will reset all module settings and reload the UI",
                    callback = function()
                        StaticPopup_Show("PREPHSFRAMEWORK_RESET_CONFIRM")
                    end
                }
            },
            showSeparator = true,
        },
        {
            name = "Logging Configuration",
            description = "Control which types of log messages are displayed",
            elements = (function()
                local logs = {}
                for _, data in pairs(Core.Logger.LogLevel) do
                    if data.label ~= "ERROR" and data.label ~= "WARNING" and data.label ~= "PROFILING" then
                        table.insert(logs, {
                            type = "Checkbox",
                            label = data.label:sub(1, 1):upper() .. data.label:sub(2):lower(),
                            get = function()
                                return Core.Logger:IsEnabled(data.mask)
                            end,
                            set = function(enabled)
                                if enabled then
                                    Core.Logger:EnableLevels(data.mask)
                                else
                                    Core.Logger:DisableLevels(data.mask)
                                end

                                if Core.DB and Core.DB.shared then
                                    Core.DB.shared.loggingMask = Core.Logger.enabledMask
                                end
                            end
                        })
                    end
                end
                return logs
            end)(),
            showSeparator = true,
        },
    }
}

-- ============================================================================
-- Static Popup Dialogs
-- ============================================================================

StaticPopupDialogs["PREPHSFRAMEWORK_RELOAD_UI"] = {
    text = "This change requires a UI reload to take effect. Reload now?",
    button1 = "Reload",
    button2 = "Later",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}


StaticPopupDialogs["PREPHSFRAMEWORK_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset all PrephsFramework settings? This will reload the UI.",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        Core:ResetAllDB()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function UI:ShowGeneralSettings()
    self:RenderSystemPage("general")
end
