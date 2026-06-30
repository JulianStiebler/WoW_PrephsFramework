--[[
    <PrephsFramework_Core/Database.lua>
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


---@type PrephsFramework.KeyRef
local keyRef = Core.Constants.ENUM.KeyRef

---@type PrephsFramework.Logger
local logger = Core.Logger

local wipe = wipe
local ReloadUI = ReloadUI
local pairs = pairs
local string = string
local type = type
local pcall = pcall
local ipairs = ipairs
local GetAddOnMetadata = GetAddOnMetadata

---@type PrephsFrameworkVersion
local versionString = GetAddOnMetadata(addonName, "Version") or "1.0.0"

---@class FeatureDB
---@field enabled boolean? Whether the feature is enabled
---@field _suppressInRaid boolean? Suppress feature in raid
---@field _suppressInGroup boolean? Suppress feature in group
---@field _suppressInInstance boolean? Suppress feature in instance
---@field _suppressInZones table<number, boolean>? Suppress feature in specific zones (keyed by zone ID)

---@class ModuleDB
---@field enabled boolean? Whether the module is enabled
---@field features table<string, FeatureDB> Feature data keyed by feature name
---@field frames table<string, table>? Persisted frame geometry keyed by frame name

---@class SharedDB
---@field backupKey keyRef Modifier key for backup actions (e.g., "Shift", "Alt", "Control")
---@field extraKey keyRef Modifier key for extra actions (must differ from backupKey)
---@field updateInterval number Time between updates in seconds
---@field loggingMask number? Bitmask for enabled log levels
---@field profiling boolean? Whether profiling is enabled
---@field syncAccounts table<string, SyncAccountConfig>? Sync account groups (account name → config)
---@field pendingRequests table<string, PendingPairRequest>? Inbound pairing requests awaiting acceptance
---@field blockedUsers table<string, boolean>? Blocked users (charKey → true)
---@field overviewCollapsed table<string, boolean>? Card collapse states
---@field overviewOrder table<string, string[]>? Child card order within sections
---@field overviewSectionCollapsed table<string, boolean>? Section collapse states
---@field overviewSectionOrder string[]? Flat ordering of cards + section groups
---@field charNotes table<string, string>? Per-character notes

---@class SyncAccountConfig
---@field targets string[] Character keys (Name-Realm) belonging to this remote account
---@field syncWholeDB boolean Whether to sync the entire DB for this account group

---@class SyncMetaEntry
---@field lastSeen number? Epoch timestamp of the last time this character was seen online
---@field lastSynced number? Epoch timestamp of the last successful sync

---@class PendingPairRequest
---@field from string Character key that sent the pairing request
---@field time number Epoch timestamp when the request was received

---@class PrephsFrameworkDB
---@field _schemaVersion number Schema migration version stamp
---@field modules table<string, ModuleDB> Per-module persistent data keyed by moduleID
---@field shared SharedDB Account-wide shared settings
---@field version PrephsFrameworkVersion Addon version at time of DB creation
---@field charSnapshots table<string, string> Packed character snapshots keyed by charKey (Name-Realm)
---@field syncedSnapshots table<string, string> Packed snapshots received from remote accounts keyed by charKey
---@field syncMeta table<string, SyncMetaEntry> Per-character sync metadata (timestamps, etc.)
---@field mainFrame table? Persisted main frame geometry {w, h, x, y}
local DefaultDB = {
    modules = {},
    mainFrame = {},
    shared = {
        backupKey = keyRef.SHIFT_KEY,
        extraKey = keyRef.ALT_KEY,
        updateInterval = 0.5,
        loggingMask = nil,
        profiling = false,
    },
    version = versionString,
    charSnapshots = {},
    syncedSnapshots = {},
    syncMeta = {},
    _schemaVersion = 0,
}

-- ============================================================================
-- Schema Migration System
-- ============================================================================
-- Each migration is a table { version = N, scope = "global"|"char"|"both",
-- migrate = function(db) … end }.  `db` is the table being migrated.
-- Entries MUST be ordered by ascending version.  On load the runner applies
-- every migration whose version is greater than db._schemaVersion, then
-- stamps the new version.
--
-- Add new migrations at the bottom of the list.  Never reorder or remove
-- existing entries — only append.
-- ============================================================================

---@alias MigrationScope "global"|"char"|"both"

---@class MigrationEntry
---@field version number  Target schema version after this migration
---@field scope MigrationScope  Which DB(s) this migration applies to
---@field description string  Human-readable change summary (for logs)
---@field migrate fun(db: table)

---@type MigrationEntry[]
local Migrations = {
    -- v1: Introduce dual-track item model (itemCounts + equippables)
    {
        version     = 1,
        scope       = "char",
        description = "Migrate legacy 'items' table to itemCounts/equippables",
        migrate     = function(db)
            if not db.itemCounts then db.itemCounts = {} end
            if not db.equippables then db.equippables = {} end
            if not db.professions then db.professions = {} end
            db.items = nil -- drop legacy key
        end,
    },
    -- v2: Ensure charSnapshots exists on the global DB
    {
        version     = 2,
        scope       = "global",
        description = "Ensure charSnapshots table exists",
        migrate     = function(db)
            if not db.charSnapshots then db.charSnapshots = {} end
        end,
    },
    -- v3: Add savedInstances, weeklyQuests, zoneName, subZoneName to per-character data
    {
        version     = 3,
        scope       = "char",
        description = "Add savedInstances, weeklyQuests, zoneName and subZoneName fields",
        migrate     = function(db)
            if not db.savedInstances then db.savedInstances = {} end
            if not db.weeklyQuests   then db.weeklyQuests   = {} end
            if db.zoneName    == nil then db.zoneName    = "" end
            if db.subZoneName == nil then db.subZoneName = "" end
        end,
    },
    -- v4: Add dailyQuests to per-character data
    {
        version     = 4,
        scope       = "char",
        description = "Add dailyQuests field",
        migrate     = function(db)
            if not db.dailyQuests then db.dailyQuests = {} end
        end,
    },
    -- v5: Add syncTargets and syncedSnapshots for CommLink
    {
        version     = 5,
        scope       = "global",
        description = "Add syncTargets and syncedSnapshots for cross-account sync",
        migrate     = function(db)
            if not db.shared then db.shared = {} end
            if not db.shared.syncTargets then db.shared.syncTargets = {} end
            if not db.syncedSnapshots then db.syncedSnapshots = {} end
        end,
    },
    -- v6: Add mailCopper to per-character data
    {
        version     = 6,
        scope       = "char",
        description = "Add mailCopper field for tracking gold in mailbox",
        migrate     = function(db)
            if db.mailCopper == nil then db.mailCopper = 0 end
        end,
    },
    -- v7: Add syncGroups and per-table version stamps for efficient sync
    {
        version     = 7,
        scope       = "global",
        description = "Add syncGroups for categorized sync targets",
        migrate     = function(db)
            if not db.shared then db.shared = {} end

            -- Migrate flat syncTargets → default group
            if not db.shared.syncGroups then
                db.shared.syncGroups = {}

                -- If there were existing flat syncTargets, move them into
                -- a "Default" group so nothing is lost.
                local oldTargets = db.shared.syncTargets
                if oldTargets and #oldTargets > 0 then
                    local targets = {}
                    for _, ck in ipairs(oldTargets) do
                        targets[#targets + 1] = ck
                    end
                    db.shared.syncGroups["Default"] = {
                        targets       = targets,
                        syncWholeDB   = false,
                    }
                end
            end

            -- syncTargets is now derived at runtime from groups; keep the
            -- key around for a graceful transition but stop writing to it.
        end,
    },
    -- v8: Add lastSynced stamps per character for efficient negotiation
    {
        version     = 8,
        scope       = "global",
        description = "Add lastSynced timestamps for sync negotiation",
        migrate     = function(db)
            if not db.syncMeta then db.syncMeta = {} end
            -- syncMeta[charKey] = { lastSeen = time(), lastSynced = time() }
        end,
    },
    -- v9: Add pendingRequests and blockedUsers for connection handshake
    {
        version     = 9,
        scope       = "global",
        description = "Add pendingRequests and blockedUsers tables",
        migrate     = function(db)
            if not db.shared then db.shared = {} end
            -- Inbound pairing requests from peers we haven't accepted yet.
            -- shared.pendingRequests[charKey] = { from = charKey, time = epoch }
            if not db.shared.pendingRequests then db.shared.pendingRequests = {} end
            -- Blocked users (we ignore all future pairing attempts from them).
            -- shared.blockedUsers[charKey] = true
            if not db.shared.blockedUsers then db.shared.blockedUsers = {} end
        end,
    },
    -- v10: Add accountGUID to per-character data for same-account detection
    {
        version     = 10,
        scope       = "char",
        description = "Add accountGUID field for same-account detection",
        migrate     = function(db)
            if db.accountGUID == nil then db.accountGUID = "" end
        end,
    },
    -- v11: Rename syncGroups → syncAccounts schema (groups now represent accounts)
    {
        version     = 11,
        scope       = "global",
        description = "Rename syncGroups to syncAccounts (one group = one remote account)",
        migrate     = function(db)
            if not db.shared then db.shared = {} end
            -- Migrate syncGroups → syncAccounts if the old key exists
            if db.shared.syncGroups and not db.shared.syncAccounts then
                db.shared.syncAccounts = db.shared.syncGroups
            end
            db.shared.syncGroups = nil
            if not db.shared.syncAccounts then
                db.shared.syncAccounts = {}
            end
        end,
    },
    -- v12: Add profCooldowns to per-character data
    {
        version     = 12,
        scope       = "char",
        description = "Add profCooldowns table for profession cooldown tracking",
        migrate     = function(db)
            if not db.profCooldowns then db.profCooldowns = {} end
        end,
    },
    -- v13: Add forecast tables for mail/AH predictions
    {
        version     = 13,
        scope       = "char",
        description = "Add mailForecasts and ahNextExpiry for item forecasting",
        migrate     = function(db)
            if not db.mailForecasts then db.mailForecasts = {} end
            if db.ahNextExpiry == nil then db.ahNextExpiry = 0 end
        end,
    },
    -- v14: Ensure CardContainer persistence tables + migrate to flat ordering model
    {
        version     = 14,
        scope       = "global",
        description = "Ensure overview persistence tables and migrate to flat card ordering",
        migrate     = function(db)
            if not db.shared then db.shared = {} end
            if not db.shared.overviewCollapsed       then db.shared.overviewCollapsed       = {} end
            if not db.shared.overviewOrder            then db.shared.overviewOrder            = {} end
            if not db.shared.overviewSectionCollapsed then db.shared.overviewSectionCollapsed = {} end
            if not db.shared.overviewSectionOrder     then db.shared.overviewSectionOrder     = {} end
            if not db.shared.charNotes                then db.shared.charNotes                = {} end

            -- Migrate legacy flat overviewOrder (string[] of card keys) to per-section table
            local oo = db.shared.overviewOrder
            if oo[1] and type(oo[1]) == "string" then
                db.shared.overviewOrder = {}
            end

            -- Migrate legacy section-level ordering to flat ordering model.
            -- Old sectionOrder contained section keys like "_local" which are
            -- no longer valid — individual card keys are used instead.
            local so = db.shared.overviewSectionOrder
            if so and so[1] and type(so[1]) == "string" and so[1]:sub(1, 1) == "_" then
                for k in pairs(so) do so[k] = nil end
            end
        end,
    },
    -- ── append future migrations here ──
}

--- The highest schema version defined in the migration list.
local CURRENT_SCHEMA_VERSION = Migrations[#Migrations] and Migrations[#Migrations].version or 0

--- Run all pending migrations on a database table.
---@param db table  The table to migrate (global DB or CharData)
---@param scope "global"|"char"  Which scope we're running for
local function RunMigrations(db, scope)
    local fromVersion = db._schemaVersion or 0
    if fromVersion >= CURRENT_SCHEMA_VERSION then return end

    for _, entry in ipairs(Migrations) do
        if entry.version > fromVersion and (entry.scope == scope or entry.scope == "both") then
            local ok, err = pcall(entry.migrate, db)
            if ok then
                logger:debug("Migration v%d (%s): %s", entry.version, scope, entry.description)
            else
                logger:error("Migration v%d (%s) FAILED: %s", entry.version, scope, err or "unknown")
            end
        end
    end

    db._schemaVersion = CURRENT_SCHEMA_VERSION
end



-- ============================================================================
-- Database Initialization
-- ============================================================================

function Core:InitializeDatabase()
    -- Initialize global SavedVariable if it doesn't exist
    if not PrephsFrameworkDB then
        PrephsFrameworkDB = Core.Util:DeepCopy(DefaultDB)
        logger:debug("Database initialized with default values")
    end
    
    -- Store reference
    ---@type PrephsFrameworkDB
    self.DB = PrephsFrameworkDB
    
    -- Ensure modules table exists
    if not self.DB.modules then
        self.DB.modules = {}
    end
    
    -- Ensure shared settings table exists
    local sharedDB = self.DB.shared
    if not sharedDB then
        self.DB.shared = Core.Util:DeepCopy(DefaultDB.shared)
        sharedDB = self.DB.shared
    end

    -- Run pending schema migrations on the global DB
    RunMigrations(self.DB, "global")

    -- Default LogLevels and persisted loggingMask
    if sharedDB.loggingMask and logger then
        logger:SetLogMask(sharedDB.loggingMask) 
    end
    if Core.DEV.profiling then
        logger:EnableLevels(logger.LogLevel.PROFILING.mask)
    else 
        logger:DisableLevels(logger.LogLevel.PROFILING.mask) 
    end
    if Core.DEV.isDebugBuild then
        logger:EnableLevels(logger.LogLevel.DEBUG.mask)
    end

    -- ----------------------------------------------------------------
    -- Per-character live DB  (PrephsFrameworkCharDataDB)
    -- ----------------------------------------------------------------
    self:InitializeCharDataDB()
end

--- Initialize the per-character SavedVariable used for live character data.
--- On login the packed string (if any) from PrephsFrameworkCharDataDB is unpacked
--- into Core.CharData for fast runtime access; on logout the reverse happens.
function Core:InitializeCharDataDB()
    local Serializer = self.Serializer

    -- PrephsFrameworkCharDataDB is declared as SavedVariablesPerCharacter in the .toc.
    -- It stores either a raw table or a packed string produced by Serializer:Pack().
    if PrephsFrameworkCharDataDB and Serializer:IsPacked(PrephsFrameworkCharDataDB) then
        local data, err = Serializer:Unpack(PrephsFrameworkCharDataDB)
        if data then
            self.CharData = data
            logger:debug("CharDataDB unpacked successfully")
        else
            logger:error("CharDataDB unpack failed: %s — resetting", err or "unknown")
            self.CharData = self:_NewCharDataTable()
        end
    elseif PrephsFrameworkCharDataDB and type(PrephsFrameworkCharDataDB) == "table" then
        -- Legacy / first-run: raw table
        self.CharData = PrephsFrameworkCharDataDB
    else
        self.CharData = self:_NewCharDataTable()
    end

    -- Run pending schema migrations on the per-character DB
    RunMigrations(self.CharData, "char")

    -- Keep runtime reference live; the global will be written on logout
    PrephsFrameworkCharDataDB = self.CharData
end

--- Create a blank per-character data table with the correct schema.
---@return PFCharacterSnapshot
function Core:_NewCharDataTable()
    return {
        _schemaVersion = CURRENT_SCHEMA_VERSION,
        name           = "",
        realm          = "",
        classFile      = "",
        level          = 0,
        faction        = "",
        lastSeen       = 0,
        copper         = 0,
        mailCopper     = 0,
        bindLocation   = "",
        zoneName       = "",
        subZoneName    = "",
        accountGUID    = "",
        itemCounts     = {},   -- table<itemID, PFItemCount>
        equippables    = {},   -- table<slotKey, PFEquippableItem>
        professions    = {},
        bankAvailable  = false,
        savedInstances = {},   -- PFSavedInstance[]
        weeklyQuests   = {},   -- table<questID, boolean>
        dailyQuests    = {},   -- table<questID, boolean>
        profCooldowns  = {},   -- table<defIndex, PFProfCooldownEntry>
        mailForecasts  = {},   -- table<itemID, PFMailForecast>
        ahNextExpiry   = 0,    -- epoch: earliest AH item expiry (0 = none)
    }
end

-- ============================================================================
-- Module Database Management
-- ============================================================================

---@param moduleID string
---@return ModuleDB|nil
function Core:GetModuleDB(moduleID)
    if not self.DB then
        logger:error("Database not initialized when trying to access module DB for '%s'", moduleID)
        return nil
    end
    
    -- Initialize module entry if it doesn't exist
    if not self.DB.modules[moduleID] then
        self.DB.modules[moduleID] = {
            enabled = true,
            features = {}
        }
    end
    
    return self.DB.modules[moduleID]
end

---@param moduleID string
---@param moduleData ModuleData
---@return boolean success
function Core:InitializeModuleDB(moduleID, moduleData)
    local moduleDB = self:GetModuleDB(moduleID)
    if not moduleDB then return false end
    
    -- Initialize feature settings with defaults
    if moduleData.features then
        for featureName, featureConfig in pairs(moduleData.features) do
            if not moduleDB.features[featureName] then
                moduleDB.features[featureName] = {}
            end
            
            local featureDB = moduleDB.features[featureName]
            
            -- Set default enabled state
            if featureDB.enabled == nil then
                featureDB.enabled = (featureConfig.defaultEnabled ~= false)
            end
            
            -- Initialize suppression flags
            if featureConfig.suppressionFlags then
                for flagName, defaultValue in pairs(featureConfig.suppressionFlags) do
                    local dbKey = "_suppress" .. flagName:gsub("^%l", string.upper)
                    if featureDB[dbKey] == nil then
                        -- Handle table defaults (like inZones) differently
                        if type(defaultValue) == "table" then
                            featureDB[dbKey] = {}
                            for k, v in pairs(defaultValue) do
                                featureDB[dbKey][k] = v
                            end
                        else
                            featureDB[dbKey] = defaultValue
                        end
                    end
                end
            end
            
            -- Initialize UI element defaults from uiElements
            if featureConfig.uiElements then
                for _, element in ipairs(featureConfig.uiElements) do
                    if element.key and featureDB[element.key] == nil then
                        -- Set default value based on element type
                        if element.type == "Checkbox" then
                            featureDB[element.key] = (element.default ~= false)
                        elseif element.type == "EditBox" then
                            featureDB[element.key] = element.default or ""
                        elseif element.type == "Slider" then
                            featureDB[element.key] = element.default or element.min or 0
                        elseif element.type == "Dropdown" then
                            featureDB[element.key] = element.default or (element.options and element.options[1])
                        elseif element.type == "ColorPicker" then
                            featureDB[element.key .. "_r"] = element.default and element.default.r or 1
                            featureDB[element.key .. "_g"] = element.default and element.default.g or 1
                            featureDB[element.key .. "_b"] = element.default and element.default.b or 1
                        elseif element.type == "IDList" then
                            featureDB[element.key] = element.default or {}
                        elseif element.type == "MultiCheckDropdown" then
                            featureDB[element.key] = element.default or {}
                        elseif element.type == "EditableList" then
                            featureDB[element.key] = element.default or {}
                        elseif element.type == "CheckboxGroup" then
                            local states = { _enabled = false }
                            if element.children then
                                for _, child in ipairs(element.children) do
                                    states[child.key] = child.default or false
                                end
                            end
                            featureDB[element.key] = states
                        end
                    end
                    
                    -- Handle ListCheckbox children
                    if element.type == "ListCheckbox" and element.children then
                        for _, child in ipairs(element.children) do
                            if child.key and featureDB[child.key] == nil then
                                featureDB[child.key] = (child.default ~= false)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return true
end

-- ============================================================================
-- Settings Management
-- ============================================================================

function Core:GetSetting(moduleID, featureName, key)
    local moduleDB = self:GetModuleDB(moduleID)
    if not moduleDB or not moduleDB.features[featureName] then
        return nil
    end
    
    return moduleDB.features[featureName][key]
end

function Core:SetSetting(moduleID, featureName, key, value)
    local moduleDB = self:GetModuleDB(moduleID)
    if not moduleDB then return false end
    
    if not moduleDB.features[featureName] then
        moduleDB.features[featureName] = {}
    end
    
    moduleDB.features[featureName][key] = value
    
    -- Fire callback if registered module has OnSettingChanged
    local module = self.RegisteredModules[moduleID]
    if module and module.callbacks.OnSettingChanged then
        local success, err = pcall(module.callbacks.OnSettingChanged, featureName, key, value)
        if not success then
            logger:error("OnSettingChanged failed for module '%s', feature '%s', key '%s': %s", moduleID, featureName, key, err)
        end
    end
    
    return true
end

--- Store a value compressed under a feature setting key.
---@param moduleID string
---@param featureName string
---@param key string
---@param value any  Lua value to pack
---@return boolean success
function Core:SetCompressedSetting(moduleID, featureName, key, value)
    local packed, err = self.Serializer:Pack(value)
    if not packed then
        logger:error("SetCompressedSetting pack failed: %s", err or "unknown")
        return false
    end
    return self:SetSetting(moduleID, featureName, key, packed)
end

--- Retrieve a compressed setting, automatically unpacking it.
---@param moduleID string
---@param featureName string
---@param key string
---@return any|nil value  Unpacked Lua value, or nil
function Core:GetCompressedSetting(moduleID, featureName, key)
    local raw = self:GetSetting(moduleID, featureName, key)
    if raw == nil then return nil end

    if self.Serializer:IsPacked(raw) then
        local data, err = self.Serializer:Unpack(raw)
        if not data then
            logger:error("GetCompressedSetting unpack failed: %s", err or "unknown")
        end
        return data
    end

    return raw
end

-- ============================================================================
-- Utility Functions
-- ============================================================================

function Core:ResetModuleDB(moduleID)
    if not self.DB then return false end
    
    self.DB.modules[moduleID] = {
        enabled = true,
        features = {}
    }
    
    logger:info("Module '%s' settings reset", moduleID)
    return true
end

function Core:ResetAllDB()
    if not self.DB then return false end

    -- Reset global DB
    wipe(PrephsFrameworkDB)
    _G.PrephsFrameworkDB = nil

    -- Reset per-character DB
    if self.CharData then wipe(self.CharData) end
    self.CharData = nil
    _G.PrephsFrameworkCharDataDB = nil

    -- Re-initialize everything (creates fresh tables + runs migrations)
    self:InitializeDatabase()
    Core:DiscoverModules()
    ReloadUI()
end

--- Reset only the per-character data (item counts, equippables, professions).
--- Removes this character's snapshot from the global DB and re-runs a full
--- index scan so live data is immediately repopulated.
function Core:ResetCharDB()
    -- Create fresh per-character data at current schema version
    self.CharData = self:_NewCharDataTable()
    _G.PrephsFrameworkCharDataDB = self.CharData

    -- Remove stale snapshot for this character
    local charKey = self:GetCharKey()
    if charKey ~= "-" then
        self:RemoveCharSnapshot(charKey)
    end

    -- Re-index live data if the Indexer is available
    if self.Indexer and self.Indexer.StampIdentity then
        self.Indexer:StampIdentity()
        self.Indexer:FullScan()
    end

    logger:info("Per-character data reset")
end

-- ============================================================================
-- Compressed Snapshot API  (cross-character item data)
-- ============================================================================
-- PrephsFrameworkDB.charSnapshots[charKey] stores a packed string so that
-- other characters can read item counts and professions without inflating
-- thousands of table keys in SavedVariables.

--- Build a canonical key for the current (or specified) character.
---@param name string?  Character name  (defaults to current)
---@param realm string? Realm name      (defaults to current)
---@return string charKey  "Name-Realm"
function Core:GetCharKey(name, realm)
    name  = name  or (self.CharData and self.CharData.name)  or ""
    realm = realm or (self.CharData and self.CharData.realm) or ""
    return name .. "-" .. realm
end

-- Snapshot decompression cache — avoids re-decompressing the same packed
-- string every time GetCharSnapshot is called (tooltip hooks fire every frame).
local _snapshotCache = {}

--- Persist the current character's live CharData as a compressed snapshot
--- in the account-wide DB so other characters can access it.
--- Called automatically on PLAYER_LOGOUT and can be called manually.
function Core:SaveCharSnapshot()
    if not self.CharData or not self.DB then return end

    local charKey = self:GetCharKey()
    if charKey == "-" then return end -- identity not yet known

    self.CharData.lastSeen = time()

    _snapshotCache[charKey] = nil  -- invalidate decompression cache

    local packed, err = self.Serializer:Pack(self.CharData)
    if packed then
        self.DB.charSnapshots[charKey] = packed
        logger:debug("Char snapshot saved for '%s' (%d bytes)", charKey, #packed)
    else
        logger:error("Failed to save char snapshot for '%s': %s", charKey, err or "unknown")
    end
end

--- Retrieve the snapshot for another character, decompressing on demand.
--- Results are cached until the snapshot is saved or removed.
---@param charKey string  "Name-Realm"
---@return PFCharacterSnapshot|nil data  Unpacked snapshot, or nil on failure
function Core:GetCharSnapshot(charKey)
    local cached = _snapshotCache[charKey]
    if cached then return cached end

    if not self.DB or not self.DB.charSnapshots then return nil end

    local raw = self.DB.charSnapshots[charKey]
    if not raw then return nil end

    if self.Serializer:IsPacked(raw) then
        local data, err = self.Serializer:Unpack(raw)
        if not data then
            logger:error("Failed to unpack snapshot for '%s': %s", charKey, err or "unknown")
            return nil
        end
        _snapshotCache[charKey] = data
        return data
    end

    -- Legacy: raw table stored directly (shouldn't happen but be safe)
    _snapshotCache[charKey] = raw
    return raw
end

--- Return an array of all charKeys that have snapshots stored.
---@return string[]
function Core:GetAllCharKeys()
    local keys = {}
    if self.DB and self.DB.charSnapshots then
        for k in pairs(self.DB.charSnapshots) do
            keys[#keys + 1] = k
        end
    end
    return keys
end

--- Remove the snapshot for a specific character.
---@param charKey string  "Name-Realm"
function Core:RemoveCharSnapshot(charKey)
    _snapshotCache[charKey] = nil  -- invalidate decompression cache
    if self.DB and self.DB.charSnapshots then
        self.DB.charSnapshots[charKey] = nil
        logger:info("Removed char snapshot for '%s'", charKey)
    end
end
