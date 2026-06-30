--[[
    <PrephsFramework_Core/Closer.lua>
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

---@type PrephsFramework.Logger
local logger = Core.Logger

local function OnCoreLoaded()
    Core:InitializeDatabase()
    Core:DiscoverModules()
    
    -- Register slash commands
    SLASH_PREPHSFRAMEWORK1 = "/pf"
    SLASH_PREPHSFRAMEWORK2 = "/preph"
    SlashCmdList["PREPHSFRAMEWORK"] = function(msg)
        local cmd, arg = msg:match("^(%S*)%s*(.-)$")
        cmd = cmd:lower()
        
        if cmd == "menu" or cmd == "" then
            if Core.UI and Core.UI.ToggleMainFrame then
                Core.UI:ToggleMainFrame()
            else
                logger:error("UI system not loaded")
            end
        else
            -- Check for custom frame slash commands
            if Core.UI and Core.UI.FindCustomFrameBySlashCommand then
                local moduleID, frameName = Core.UI:FindCustomFrameBySlashCommand(cmd)
                if moduleID and frameName then
                    Core.UI:ToggleCustomFrame(moduleID, frameName)
                    return
                end
            end
            
            -- Unknown command
            logger:warning("Unknown command '%s'. Available commands are:", cmd)
            logger:warning("  menu - Open the settings UI")
            if Core.UI and Core.UI.GetAllSlashListEntries then
                for slashCmd, title in pairs(Core.UI:GetAllSlashListEntries()) do
                    logger:warning("  %s - %s", slashCmd, title)
                end
            end
            
        end
    end
end

-- Event Handler
local isInitialized = false

local function InitializePlayerState()
    Core:RefreshFullState()
end

---@param event string
---@param loadedAddon string
local function OnAddonLoaded(event, loadedAddon)
    if loadedAddon == "PrephsFramework_Core" and not isInitialized then
        OnCoreLoaded()
        isInitialized = true
    end
end

---@param event string
---@param isLogin boolean
---@param isReload boolean
local function OnPlayerEnteringWorld(event, isLogin, isReload)
    if isInitialized then
        InitializePlayerState()

        -- Stamp character identity (always — needed for logout snapshot)
        Core.Indexer:StampIdentity()

        -- Only run full item scan if the indexer has been activated by a consumer
        if Core.Indexer:IsActive() then
            Core.Indexer:FullScan()
        end

        -- Initialize CommLink (requires DB + identity to be ready)
        if Core.CommLink and Core.CommLink.Initialize then
            Core.CommLink:Initialize()
        end

        -- Auto-load check happens here when chat is ready
        C_Timer.After(0.5, function()
            Core:AutoLoadModulesWithActiveFeatures()
        end)
        -- Unregister after first call
        Core:UnregisterEvent("_CoreInit", "PLAYER_ENTERING_WORLD")
    end
end

--- On logout: pack the live CharData into the per-character SV and save
--- a compressed snapshot into the account-wide DB for cross-character access.
local function OnPlayerLogout()
    if Core.CharData then
        -- Update identity one final time (level may have changed)
        Core.Indexer:StampIdentity()

        -- Flush any deferred CommLink snapshot packing before logout
        if Core.CommLink and Core.CommLink.FlushDirtySnapshots then
            Core.CommLink:FlushDirtySnapshots()
        end

        -- Save compressed snapshot for other characters
        Core:SaveCharSnapshot()


        -- Pack live data into per-character SavedVariable
        local packed, err = Core.Serializer:Pack(Core.CharData)
        if packed then
            PrephsFrameworkCharDataDB = packed
        else
            -- Fallback: store raw table (less optimal but functional)
            PrephsFrameworkCharDataDB = Core.CharData
            logger:error("Failed to pack CharData on logout: %s", err or "unknown")
        end
    end
end

Core:RegisterEvent("_CoreInit", "ADDON_LOADED", OnAddonLoaded)
Core:RegisterEvent("_CoreInit", "PLAYER_ENTERING_WORLD", OnPlayerEnteringWorld)
Core:RegisterEvent("_CoreInit", "PLAYER_LOGOUT", OnPlayerLogout)
-- Keep cd.copper up to date throughout the session; StampIdentity only fires
-- at login and logout, so gold spent or earned mid-session would otherwise
-- not be reflected until the next reload.
Core:RegisterEvent("_CoreInit", "PLAYER_MONEY", function()
    if Core.CharData then
        Core.CharData.copper = GetMoney()
    end
end)

