--[[
    <PrephsFramework_Core/UI/UI_InfoPage.lua>
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

local string = string
local pairs = pairs

-- ============================================================================
-- Framework Information Page
-- ============================================================================

---@type PrephsFramework.SystemPage
Core.SystemPages.info = {
    moduleName = "Framework Information",
    features = {
        {
            name = "About PrephsFramework",
            description = "Core framework information and statistics",
            elements = {
                {
                    type = "Label",
                    label = function()
                        return "|cff3FC7EBPrephs Framework|r"
                    end,
                    fontSize = "large"
                },
                {
                    type = "Label",
                    label = function()
                        return "Version: " .. (Core.DB and Core.DB.version or "unknown")
                    end
                },
                {
                    type = "Label",
                    label = function()
                        if not Core.DEV then return "Debug Flags: none" end
                        local parts = {}
                        for flag, value in pairs(Core.DEV) do
                            parts[#parts + 1] = flag .. ": " .. (value and "|cff00ff00true|r" or "|cffff4444false|r")
                        end
                        if #parts == 0 then return "Debug Flags: none" end
                        table.sort(parts)
                        return "Debug Flags:\n" .. table.concat(parts, "\n")
                    end
                },
                
                {
                    type = "Label",
                    label = function()
                        local discoveredCount = 0
                        local registeredCount = 0
                        for moduleID, data in pairs(Core.DiscoveredModules) do
                            discoveredCount = discoveredCount + 1
                            if data.registered then
                                registeredCount = registeredCount + 1
                            end
                        end
                        return string.format("Modules: %d discovered, %d registered", discoveredCount, registeredCount)
                    end
                },
                {
                    type = "Label",
                    label = function()
                        local logger = Core.Logger
                        if not logger or not logger.LogLevel then return "Log Levels: unavailable" end
                        local parts = {}
                        for name, def in pairs(logger.LogLevel) do
                            local enabled = logger:IsEnabled(def.mask)
                            parts[#parts + 1] = name .. ": " .. (enabled and "|cff00ff00ON|r" or "|cffff4444OFF|r")
                        end
                        table.sort(parts)
                        return "Log Levels:\n" .. table.concat(parts, "\n")
                    end
                },
                {
                    type = "Label",
                    label = function()
                        local featureCount = 0
                        for _, _ in pairs(Core.ActiveFeatures) do
                            featureCount = featureCount + 1
                        end
                        return string.format("Active Features: %d", featureCount)
                    end
                },
                {
                    type = "Spacer",
                    height = 20
                },
                {
                    type = "Label",
                    label = "PrephsFramework is a modular addon framework that provides core functionality for dynamic module loading, event management, and feature lifecycle management.",
                    fontSize = "small",
                    color = {0.8, 0.8, 0.8}
                }
            }
        }
    }
}

function UI:ShowFrameworkInfo()
    self:RenderSystemPage("info")
end
