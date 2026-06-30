--[[
    <PrephsFramework_Core/Module.lua>
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

local logger = Core.Logger
-- ============================================================================
-- Module Discovery & Registration
-- ============================================================================

local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local IsAddOnLoadOnDemand = IsAddOnLoadOnDemand
local GetNumAddOns = GetNumAddOns
local pairs = pairs
local LoadAddOn = LoadAddOn
local time = time
local tostring = tostring
local pcall = pcall


local slashListEntrys = {}

function Core:DiscoverModules()

    Core.DiscoveredModules = {}
    
    local numAddons = GetNumAddOns()
    local discoveredCount = 0
    
    for i = 1, numAddons do
        local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(i)
        local moduleIDRaw = GetAddOnMetadata(name, "X-PrephsFramework-ModuleID")
        
        if moduleIDRaw then
            -- Store display name (with spaces) and convert to internal ID (spaces to underscores)
            local displayName = moduleIDRaw
            local moduleID = moduleIDRaw:gsub(" ", "_")
            
            
            -- Check for duplicate module IDs
            if Core.DiscoveredModules[moduleID] then
                logger:error("Duplicate module ID '%s' found in addon '%s'. This module will be skipped. Ensure each module has a unique X-PrephsFramework-ModuleID in its .toc file.", moduleID, name)
            else
                local loadOnDemand = IsAddOnLoadOnDemand(i)
                
                Core.DiscoveredModules[moduleID] = {
                    folderName = name,
                    moduleID = moduleID,
                    displayName = displayName,
                    title = GetAddOnMetadata(name, "X-PrephsFramework-Title") or title or name,
                    version = GetAddOnMetadata(name, "Version") or "1.0.0",
                    loadOnDemand = loadOnDemand,
                    alwaysLoad = GetAddOnMetadata(name, "X-PrephsFramework-AlwaysLoad") == "1",
                    useProfile = GetAddOnMetadata(name, "X-PrephsFramework-UseProfile") == "1",
                    discovered = true,
                    loaded = false,
                    registered = false
                }
                discoveredCount = discoveredCount + 1

            end
        end
    end
    

end

---@alias frameName string Unique name for a custom frame within a module, will be PrephsFramework_Custom_[FrameName]

---@class CustomFrame : Frame
---@field moduleID moduleID
---@field frameName frameName
---@field frameConfig ModuleFrameConfig
---@field ScrollFrame ScrollFrame
---@field ScrollChild Frame
---@field resizeGrip Button? Resize grip button (present when size.resizable is true)
---@field [string] any Custom fields set by module code via OnInitialize/AfterInitialize

---@class UIElementBase
---@field showSeparator boolean? Whether to show a separator after this element in the UI
---@field description string? Description text rendered below the widget
---@field default any? Default value used when no stored value exists (used by Slider, etc.)

---@class UIElement.Label : UIElementBase
---@field type "Label"
---@field label string|fun():string Display text (string or function returning string)
---@field font string? FontObject name (e.g. "GameFontNormalLarge")
---@field fontSize "large"|"small"|nil Font size shorthand (resolved to font if font is nil)
---@field color number[]? RGB color e.g. {0.7, 0.7, 0.7}

---@class UIElement.Checkbox : UIElementBase
---@field type "Checkbox"
---@field label string Display label
---@field key string? DB key to store/retrieve value
---@field get fun():boolean|nil
---@field set fun(value:boolean)|nil
---@field onUpdate fun(value:boolean)|nil

---@class UIElement.EditBox : UIElementBase
---@field type "EditBox"
---@field label string Display label
---@field key string? DB key to store/retrieve value
---@field get fun():string|nil
---@field set fun(value:string)|nil
---@field onUpdate fun(value:string)|nil

---@class UIElement.Slider : UIElementBase
---@field type "Slider"
---@field label string Display label
---@field key string? DB key to store/retrieve value
---@field get fun():number|nil
---@field set fun(value:number)|nil
---@field onUpdate fun(value:number)|nil
---@field min number? Minimum value
---@field max number? Maximum value
---@field step number? Step size

---@class UIElement.Dropdown : UIElementBase
---@field type "Dropdown"
---@field label string Display label
---@field key string? DB key to store/retrieve value
---@field get fun():string|nil
---@field set fun(value:string)|nil
---@field onUpdate fun(value:string)|nil
---@field options string[] Options list

---@class UIElement.DependentDropdown : UIElement.Dropdown
---@field type "DependentDropdown"
---@field isOptionDisabled fun(option: string): string|nil  Called per option when dropdown opens. Return nil to enable, or a reason string to grey it out.

---@class UIElement.ColorPicker : UIElementBase
---@field type "ColorPicker"
---@field label string Display label
---@field key string? DB key to store/retrieve value
---@field get fun():number, number, number|nil
---@field set fun(r:number, g:number, b:number)|nil
---@field onUpdate fun(r:number, g:number, b:number)|nil

---@class UIElement.Button : UIElementBase
---@field type "Button"
---@field label string? Button text
---@field text string? Button text (alias for label)
---@field callback fun()? Click handler
---@field onClick fun()? Click handler (alias for callback)

---@class UIElement.Spacer
---@field type "Spacer"
---@field height number? Height in pixels

---@class UIElement.EditableList : UIElementBase
---@field type "EditableList"
---@field label string Display label
---@field key string? DB key to store/retrieve the list (stored as {id, displayText}[])
---@field get fun():table|nil Custom getter returning the current list
---@field set fun(value:table)|nil Custom setter receiving the updated list
---@field onUpdate fun(value:table)|nil
---@field resolveFunc fun(input: string): (number|string|nil), (string|nil) Resolves raw input to (id, displayName). Return nil,nil if invalid.
---@field inputHint string? Placeholder text shown in the input box (e.g. "Enter Spell ID...")

---@class UIElement.CheckboxGroup : UIElementBase
---@field type "CheckboxGroup"
---@field label string Main checkbox label
---@field key string? DB key to store/retrieve states table ({_enabled=bool, [childKey]=bool, ...})
---@field get fun():table|nil Custom getter returning states table
---@field set fun(value:table)|nil Custom setter receiving updated states table
---@field onUpdate fun(value:table)|nil
---@field children CheckboxGroupChildConfig[] Child checkbox definitions
---@field collapsible boolean? Whether the group starts collapsed with an expand/collapse toggle
---@field onMainChanged fun(checked: boolean)|nil Extra callback when main toggle changes
---@field onChildChanged fun(key: string, checked: boolean)|nil Extra callback when a child toggle changes

---@class CheckboxGroupChildConfig
---@field key string Unique key for this child checkbox (used in states table)
---@field label string Display label for this child checkbox
---@field default boolean? Default checked state for this child checkbox

---@alias UIElement UIElement.Label|UIElement.Checkbox|UIElement.EditBox|UIElement.Slider|UIElement.Dropdown|UIElement.ColorPicker|UIElement.Button|UIElement.Spacer|UIElement.EditableList|UIElement.CheckboxGroup|UIElement.DependentDropdown

---@class SuppressionFlags
---@field inRaid boolean? Suppress feature while in a raid
---@field inGroup boolean? Suppress feature while in a dungeon group
---@field inInstance boolean? Suppress feature while in any instance
---@field inZones table<string, boolean>? Suppress feature in specific zones

---@alias callback function
---@alias filters table<string, any>

--- A feature event handler can be a plain callback function,
--- or a table with callback + optional filters/options for the event system.
---@class FeatureEventHandler
---@field callback function Handler: function(eventName, ...) end
---@field options EventHandlerOptions? Gating options (skipInCombat, requiresInstance, etc.)
---@field filters table<string, any>? Filter values keyed by FilterDef names

---@alias FeatureEventDef FeatureEventHandler|function

--- Options that gate when an event handler is allowed to fire.
---@class EventHandlerOptions
---@field skipInCombat boolean? Never fire this handler while in combat
---@field requiresInstance boolean? Only fire this handler while inside an instance

--- Callback-based hook entry (dict-style hooks in ModuleFeatureConfig.hooks).
---@class HookCallbackEntry
---@field callback function Hook handler function

--- Flexible hook configuration (array-style hooks in ModuleFeatureConfig.hooks).
--- Supports frame script hooks, hooksecurefunc on globals, and hooksecurefunc on table methods.
---@class FlexibleHookConfig
---@field id string? Unique hook identifier (auto-generated from type+target if omitted)
---@field type "script"|"function"|"secure"|"method" Hook type
---@field callback function Hook handler function
---@field frame Frame|string? Target frame or global frame name (type="script")
---@field script string? Frame script name, e.g. "OnShow" (type="script")
---@field func string? Global function name (type="function"|"secure")
---@field table table? Target table for method hooks (type="method")
---@field method string? Method name on the target table (type="method")

---@class ModuleFeatureConfig
---@field name string? Display name of the feature
---@field default boolean? Whether the feature is enabled by default
---@field defaultEnabled boolean? Alias for default (used in DB init)
---@field events table<string, FeatureEventHandler>? WoW events / CLEU subevents to register when feature is active
---@field hooks FlexibleHookConfig[]|table<string, HookCallbackEntry>? Hook definitions (array = flexible hooks, dict = callback hooks)
---@field uiGroup string? Sidebar group name, defaults to "General"
---@field priority integer? Sort order within the group, higher = first
---@field uiElements UIElement[]? UI widgets rendered when feature is enabled
---@field suppressionFlags SuppressionFlags? If set, shows cog button with suppression options
---@field showSeparator boolean? Whether to show a separator after this feature in the UI
---@field AfterInitialize fun(parent: Frame, moduleID: moduleID, featureName: string)? Called after uiElements are rendered. Use for custom dynamic content.

---@class ModuleFrameSize
---@field w number? Frame width in pixels
---@field h number? Frame height in pixels
---@field x number? Frame X offset from TOPLEFT (enables position persistence)
---@field y number? Frame Y offset from TOPLEFT (enables position persistence)
---@field resizable boolean? Whether the frame can be user-resized

---@class ModuleFrameConfig
---@field title string? Frame title displayed in title bar
---@field slashListEntry string Command name displayed in /pf list
---@field size ModuleFrameSize? Size/position/resize config. Enables geometry persistence in PrephsFrameworkDB.
---@field noEsc boolean? If true, frame is not closed by the Escape key (useful for overlays)
---@field alpha number? Frame opacity 0.0–1.0 (default 1.0). Affects entire frame including content.
---@field uiElements UIElement[]? UI widgets rendered using framework components (Label, Checkbox, Slider, etc.)
---@field OnInitialize fun(frame: CustomFrame)? Called when frame is first created, before uiElements are rendered
---@field AfterInitialize fun(frame: CustomFrame)? Called after frame creation and uiElements rendering. Use for custom dynamic content (e.g. row-based lists)
---@field OnShow fun()? Called when frame is shown
---@field OnHide fun()? Called when frame is hidden

---@class ModuleProfileConfig
---@field defaults table<string, any>? Default profile values

---@class ModuleData
---@field features table<string, ModuleFeatureConfig>? Feature definitions keyed by feature name
---@field frames table<string, ModuleFrameConfig>? Frame definitions keyed by frame name
---@field profileConfig ModuleProfileConfig? Profile/SavedVariables configuration
---@field OnInitialize fun()? Called after module is registered and DB is initialized
---@field OnFeatureStateChanged fun(featureName: string, enabled: boolean)? Called when a feature is toggled
---@field OnSettingChanged fun(featureName: string, settingKey: string, value: any)? Called when a setting changes
---@field OnProfileChanged fun(newProfile: string)? Called when the active profile changes

---@class moduleID : string Unique identifier for a module, derived from X-PrephsFramework-ModuleID in .toc (spaces replaced with underscores)

---@class DiscoveredModule
---@field folderName string Addon folder name (for LoadAddOn)
---@field moduleID moduleID Internal module identifier
---@field displayName string Human-readable display name (with spaces)
---@field title string Module title from .toc metadata
---@field version string Module version string
---@field loadOnDemand boolean Whether the addon is LoadOnDemand
---@field alwaysLoad boolean Whether the module should always be loaded regardless of feature state
---@field useProfile boolean Whether this module uses per-profile settings
---@field discovered boolean Always true once discovered
---@field loaded boolean Whether the addon has been loaded (LoadAddOn called)
---@field registered boolean Whether RegisterModule has been called

---@class RegisteredModule
---@field moduleID moduleID
---@field features table<string, ModuleFeatureConfig> Feature definitions keyed by feature name
---@field frames table<string, ModuleFrameConfig> Frame definitions keyed by frame name
---@field profileConfig ModuleProfileConfig Profile/SavedVariables configuration
---@field needIndexer boolean Whether this module requires the character indexer
---@field callbacks RegisteredModuleCallbacks Module lifecycle callbacks
---@field registeredAt number time() when the module was registered

---@class RegisteredModuleCallbacks
---@field OnInitialize fun()? Called after module is registered and DB is initialized
---@field OnFeatureStateChanged fun(featureName: string, enabled: boolean)? Called when a feature is toggled
---@field OnSettingChanged fun(featureName: string, settingKey: string, value: any)? Called when a setting changes
---@field OnProfileChanged fun(newProfile: string)? Called when the active profile changes

---@class ActiveFeatureEntry
---@field moduleID moduleID Module that owns this feature
---@field featureName string Feature name within the module
---@field config ModuleFeatureConfig Feature configuration at activation time
---@field _hookTarget table? Registration key table for callback-based hooks (cleanup handle)

---@param moduleID moduleID
---@param moduleData ModuleData
---@param needIndexer boolean? Whether this module needs the character indexer. 
---@return boolean
function Core:RegisterModule(moduleID, moduleData, needIndexer)
    if not moduleID or not moduleData then
        logger:error("RegisterModule called with invalid parameters")
        return false
    end
    
    logger:debug("Attempting to register module: %s", moduleID)
    
    -- Check if module was discovered
    if not self.DiscoveredModules[moduleID] then
        logger:error("Module %s not found in registry. Ensure X-PrephsFramework-ModuleID is set in .toc file", moduleID)
        return false
    end
    
    -- Check if already registered
    if self.RegisteredModules[moduleID] then
        logger:warning("Module %s is already registered", moduleID)
        return false
    end
    
    -- Store registration
    self.RegisteredModules[moduleID] = {
        moduleID = moduleID,
        features = moduleData.features or {},
        frames = moduleData.frames or {},
        profileConfig = moduleData.profileConfig or {},
        needIndexer = needIndexer or false,
        callbacks = {
            OnInitialize = moduleData.OnInitialize,
            OnFeatureStateChanged = moduleData.OnFeatureStateChanged,
            OnSettingChanged = moduleData.OnSettingChanged,
            OnProfileChanged = moduleData.OnProfileChanged
        },
        registeredAt = time()
    }
    
    -- Update registry if discovered
    if self.DiscoveredModules[moduleID] then
        self.DiscoveredModules[moduleID].registered = true
        self.DiscoveredModules[moduleID].loaded = true
        logger:debug("Updated discovery registry for module: %s", moduleID)
    end
    
    logger:init("Module %s registered successfully", moduleID)
    
    -- Initialize module database
    logger:debug("Initializing database for module: %s", moduleID)
    self:InitializeModuleDB(moduleID, moduleData)
    
    -- Initialize features (register events/hooks for enabled features)
    logger:debug("Initializing features for module: %s", moduleID)
    self:InitializeModuleFeatures(moduleID)

    -- Evaluate whether the Indexer should be active after this module's features are set up
    self:EvaluateIndexer()
    
    -- Call OnInitialize if provided
    if moduleData.OnInitialize then
        logger:debug("Calling OnInitialize for module: %s", moduleID)
        local success, err = pcall(moduleData.OnInitialize)
        if not success then
            logger:error("Module %s OnInitialize failed: %s", moduleID, tostring(err))
        end
    end
    
    return true
end


---@return table<moduleID, DiscoveredModule>
function Core:GetDiscoveredModules()
    return self.DiscoveredModules
end

---@return table<moduleID, RegisteredModule>
function Core:GetRegisteredModules()
    return self.RegisteredModules
end

---@param moduleID moduleID
---@return boolean success
function Core:LoadModule(moduleID)
    local moduleData = self.DiscoveredModules[moduleID]
    if not moduleData then
        logger:error("Module %s not found", moduleID)
        return false
    end
    
    if moduleData.loaded then
        logger:debug("Module %s already loaded", moduleID)
        return true
    end
    
    -- Load the module (WoW handles dependencies via ## Dependencies in .toc)
    logger:init("Loading module %s...", moduleID)
    local loaded, reason = LoadAddOn(moduleData.folderName)
    
    if not loaded then
        logger:error("Failed to load module %s: %s", moduleID, reason or "unknown")
        return false
    end
    
    moduleData.loaded = true
    logger:init("Module %s loaded successfully", moduleID)
    return true
end

---@param moduleID moduleID
---@return boolean hasActive True if at least one feature is enabled in the DB
function Core:ModuleHasActiveFeatures(moduleID)
    if not self.DB or not self.DB.modules then
        logger:warning("DB not initialized or no modules in DB")
        return false
    end 
    
    local moduleDB = self.DB.modules[moduleID]
    if not moduleDB then
        logger:warning("No DB entry for module %s", moduleID)
        return false
    end
    
    if not moduleDB.features then
        logger:warning("Module %s has no features in DB", moduleID)
        return false
    end
    
    -- Check if any feature is enabled
    local enabledCount = 0
    for featureName, featureData in pairs(moduleDB.features) do
        if featureData.enabled then
            enabledCount = enabledCount + 1
            logger:init("Found enabled feature: %s", featureName)
        end
    end
    
    if enabledCount > 0 then
        logger:debug("Module %s has %d enabled feature(s)", moduleID, enabledCount)
        return true
    end
    
    logger:info("No enabled features found for module %s", moduleID)
    return false
end

-- Auto-load LoadOnDemand modules that have active features
function Core:AutoLoadModulesWithActiveFeatures()
    local autoLoadedCount = 0
    local checkedCount = 0
    
    local registryCount = 0
    for _ in pairs(self.DiscoveredModules) do
        registryCount = registryCount + 1
    end
    logger:debug("Found %d modules in registry", registryCount)
    
    for moduleID, moduleData in pairs(self.DiscoveredModules) do
        logger:debug("Module %s: loadOnDemand=%s, loaded=%s, alwaysLoad=%s", moduleID, tostring(moduleData.loadOnDemand), tostring(moduleData.loaded), tostring(moduleData.alwaysLoad))
        
        -- Only check LoadOnDemand modules that aren't already loaded
        if moduleData.loadOnDemand and not moduleData.loaded and not moduleData.alwaysLoad then
            checkedCount = checkedCount + 1
            logger:debug("Checking %s (LoadOnDemand)...", moduleData.displayName or moduleID)
            
            -- Check if this module has any enabled features in the database
            local hasActiveFeatures = self:ModuleHasActiveFeatures(moduleID)
            logger:debug("Has active features: %s", tostring(hasActiveFeatures))
            
            if hasActiveFeatures then
                logger:init("Auto-loading %s...", moduleData.displayName or moduleID)
                if self:LoadModule(moduleID) then
                    autoLoadedCount = autoLoadedCount + 1
                end
            end
        end
    end
    
    if checkedCount == 0 then
        logger:warning("No LoadOnDemand modules found to check")
    elseif autoLoadedCount > 0 then
        logger:info("Auto-loaded %d module(s) with active features", autoLoadedCount)
    else
        logger:info("No modules needed auto-loading")
    end
end

