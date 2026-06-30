--[[
    <PrephsFramework_Core/CommLink.lua>
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

-- NOTE: Core.DB is nil at file-load time; the upvalue is resolved in Initialize().
local coreDB = nil

-- ============================================================================
-- Core.CommLink — Cross-account addon communication system
-- ============================================================================
--
-- General-purpose message passing over WoW's addon channel (WHISPER).
-- Handles serialization, compression, chunking, peer discovery,
-- combat-awareness, and send throttling.
--
-- Usage:
--   CommLink:RegisterModule("MyMod", {
--       GetSyncData     = function() return myData end,
--       OnDataReceived  = function(charKey, data) ... end,
--       OnPeerOnline    = function(charKey) ... end,
--       OnPeerOffline   = function(charKey) ... end,
--   })
--
-- Wire protocol (WHISPER addon messages, prefix "PFSync"):
--   \001<payload>  — single packet (fits in one message)
--   \002<payload>  — first chunk of multi-part
--   \003<payload>  — middle chunk
--   \004<payload>  — final chunk
--
-- Reassembled payload is channel-encoded compressed serialized Lua table:
--   { op = "P"|"A"|"D", mod = moduleID, d = <module_data> }
-- ============================================================================

---@class CommLinkModuleHandler
---@field GetSyncData? fun(): table|nil
---@field OnDataReceived? fun(charKey: string, data: table)
---@field OnPeerOnline? fun(charKey: string)
---@field OnPeerOffline? fun(charKey: string)
---@field OnSyncedSnapshot? fun(charKey: string, snapshot: PFCharacterSnapshot)
---@field OnPairRequest? fun(charKey: string)
---@field OnPairAccepted? fun(charKey: string)
---@field OnPairDeclined? fun(charKey: string)
---@field OnPairBlocked? fun(charKey: string)
---@field OnWDBRequest? fun(charKey: string, siblings: string[])

---@class CommLinkSyncGroup
---@field targets table<string, boolean>
---@field syncWholeDB boolean
---@field remoteWholeDB? boolean

---@class PrephsFramework.CommLink
---@field _snapshotCache? table<string, PFCharacterSnapshot>
---@field _dirtySnapshots? table<string, boolean>
---@field _flushTimer? any
local CommLink = Core.CommLink or {}
Core.CommLink = CommLink

local Serializer  = Core.Serializer

-- WoW API
local C_ChatInfo   = C_ChatInfo
local C_Timer      = C_Timer
local time         = time
local pairs        = pairs
local ipairs       = ipairs
local type         = type
local pcall        = pcall
local string_sub   = string.sub
local string_byte  = string.byte
local string_len   = string.len
local table_concat = table.concat
local table_remove = table.remove
local math_ceil    = math.ceil
local math_min     = math.min

-- ============================================================================
-- Constants
-- ============================================================================

local PREFIX       = "PFSync"
local MAX_CHUNK    = 250      -- usable payload bytes per addon message

-- Control bytes for chunking
local CTL_SINGLE   = "\001"
local CTL_START    = "\002"
local CTL_MID      = "\003"
local CTL_END      = "\004"

-- Protocol operations
local OP_PING      = "P"   -- discovery ping
local OP_PONG      = "A"   -- discovery response
local OP_DATA      = "D"   -- module data payload
local OP_SYNC_REQ  = "R"   -- sync negotiation request (sends charKey → lastSeen map)
local OP_SYNC_RESP = "S"   -- sync negotiation response (sends only needed snapshots)
local OP_DB_PUSH   = "B"   -- whole-DB push (batch of snapshots for whole-DB groups)
local OP_PAIR_REQ  = "Q"   -- pairing request (Target A adds Target B)
local OP_PAIR_ACK  = "K"   -- pairing accepted (Target B confirms)
local OP_PAIR_DEC  = "X"   -- pairing declined
local OP_PAIR_BLK  = "L"   -- pairing blocked (sender is blocked, stop retrying)
local OP_SIB_INTRO = "I"   -- sibling introduction (unknown alt of known peer)
local OP_WDB_REQ   = "W"   -- whole-DB request (ask peer to agree on whole-acc sync)
local OP_WDB_ACK   = "w"   -- whole-DB acknowledgement (peer agrees, with mode)
local OP_WDB_DEC   = "d"   -- whole-DB declined (receiver declined the request)
local OP_WDB_CAN   = "c"   -- whole-DB cancelled (requester withdrew the request)

-- Timing
local PING_INTERVAL     = 30    -- seconds between keepalive pings
local STALE_TIMEOUT     = 120   -- peer offline after no message for this long
local SEND_INTERVAL     = 0.05  -- seconds between outgoing chunks (~20/sec)

-- ============================================================================
-- Internal State
-- ============================================================================

---@type table<string, boolean>
local syncTargets    = {}    -- set: charKey → true  (derived from accounts at init)
---@type table<string, CommLinkSyncGroup>
local syncGroups     = {}    -- accountName → { targets={ck→true}, syncWholeDB=bool }
---@type table<string, { lastSeen: number }>
local onlinePeers    = {}    -- charKey → { lastSeen = time() }
---@type table<string, CommLinkModuleHandler>
local moduleHandlers = {}    -- moduleID → handler table
---@type table<string, { parts: string[], n: number }>
local assemblyBuffer = {}    -- senderCharKey → { parts = {}, n = 0 }
local outQueue       = {}    -- ordered list of { target, data }
local isSending      = false
local _initialized   = false

-- UI change listeners (fired whenever accounts/targets change so the UI can refresh)
local _changeListeners = {}  -- array of callback functions

--- Fire all registered change listeners (e.g. to refresh the Connections UI).
local function FireChangeListeners()
    for _, fn in ipairs(_changeListeners) do
        pcall(fn)
    end
end

--- Register a callback that fires whenever accounts, targets, or requests change.
---@param fn function
function CommLink:RegisterChangeListener(fn)
    _changeListeners[#_changeListeners + 1] = fn
end

--- Unregister a change listener.
---@param fn function
function CommLink:UnregisterChangeListener(fn)
    for i = #_changeListeners, 1, -1 do
        if _changeListeners[i] == fn then
            table_remove(_changeListeners, i)
        end
    end
end

-- ============================================================================
-- Internal: Whisper Target / Sender Normalization
-- ============================================================================

--- Strip spaces from the realm portion of a "Name-Realm" charKey so that
--- keys are consistent regardless of whether they came from GetRealmName()
--- ("Wild Growth") or CHAT_MSG_ADDON ("WildGrowth").
---@param ck string
---@return string
local function NormalizeCK(ck)
    if type(ck) ~= "string" then return tostring(ck) end
    local name, realm = ck:match("^(.+)-(.+)$")
    if not name then return ck end
    return name .. "-" .. realm:gsub("%s+", "")
end

--- Normalize a charKey that may be a plain string or an {id="..."} table
--- (the latter is how EditableList UI stores entries).
---@param raw string|table
---@return string
local function ResolveCharKey(raw)
    if type(raw) == "table" then raw = tostring(raw.id or "")
    else raw = tostring(raw) end
    return NormalizeCK(raw)
end

--- For same-realm peers just the name; for cross-realm "Name-Realm".
local function GetWhisperTarget(charKey)
    local name, realm = charKey:match("^(.+)-(.+)$")
    if not name then return charKey end
    local myRealm = Core.CharData and Core.CharData.realm or ""
    -- Compare normalized (spaceless) realm names
    if realm:gsub("%s+", "") == myRealm:gsub("%s+", "") then return name end
    return charKey
end

--- Normalize a CHAT_MSG_ADDON sender to "Name-Realm" (spaceless realm).
local function NormalizeSender(sender)
    if not sender:find("-", 1, true) then
        local myRealm = Core.CharData and Core.CharData.realm or ""
        return sender .. "-" .. myRealm:gsub("%s+", "")
    end
    return NormalizeCK(sender)
end

-- ============================================================================
-- Internal: Channel Encoding
-- ============================================================================

--- Encode a Lua table for addon channel transmission.
---@param tbl table
---@return string|nil encoded, string|nil err
local function EncodeForChannel(tbl)
    return Serializer:PackForChannel(tbl, 4)
end

--- Decode an addon channel string back to a Lua table.
---@param str string
---@return table|nil data, string|nil err
local function DecodeFromChannel(str)
    return Serializer:UnpackFromChannel(str)
end

-- ============================================================================
-- Internal: Chunked Send Queue
-- ============================================================================

--- Split an encoded string into chunks and queue them for delivery.
local function QueueMessage(targetCharKey, encoded)
    local target = GetWhisperTarget(targetCharKey)
    local len    = string_len(encoded)

    if len + 1 <= MAX_CHUNK then
        outQueue[#outQueue + 1] = { target = target, data = CTL_SINGLE .. encoded }
        return
    end

    -- Multi-part: 1 byte reserved for control
    local chunkSize   = MAX_CHUNK - 1
    local totalChunks = math_ceil(len / chunkSize)
    for i = 1, totalChunks do
        local startPos = (i - 1) * chunkSize + 1
        local endPos   = math_min(i * chunkSize, len)
        local chunk    = string_sub(encoded, startPos, endPos)

        local ctl
        if i == 1 then
            ctl = CTL_START
        elseif i == totalChunks then
            ctl = CTL_END
        else
            ctl = CTL_MID
        end
        outQueue[#outQueue + 1] = { target = target, data = ctl .. chunk }
    end
end

--- Flush one packet at a time from the queue, throttled.
local function ProcessOutQueue()
    if #outQueue == 0 then
        isSending = false
        return
    end

    isSending = true
    local pkt = table_remove(outQueue, 1)

    local ok, err = pcall(C_ChatInfo.SendAddonMessage, PREFIX, pkt.data, "WHISPER", pkt.target)
    if not ok then
        logger:commlink("CommLink: SendAddonMessage failed → '%s': %s", pkt.target, err or "?")
    end

    if #outQueue > 0 then
        C_Timer.After(SEND_INTERVAL, ProcessOutQueue)
    else
        isSending = false
    end
end

local function StartSending()
    if not isSending and #outQueue > 0 then
        ProcessOutQueue()
    end
end

-- ============================================================================
-- Internal: Send Protocol Message
-- ============================================================================

local function SendTo(charKey, msg)
    -- Don't send data in combat (pings are fine)
    if msg.op == OP_DATA and Core.States and Core.States.inCombat then return end

    local encoded, err = EncodeForChannel(msg)
    if not encoded then
        logger:commlink("CommLink: encode failed: %s", err or "?")
        return
    end

    QueueMessage(charKey, encoded)
    StartSending()
end

-- ============================================================================
-- Internal: Notify modules of peer state change
-- ============================================================================

local function NotifyPeerOnline(charKey)
    for _, handlers in pairs(moduleHandlers) do
        if handlers.OnPeerOnline then
            pcall(handlers.OnPeerOnline, charKey)
        end
    end
    FireChangeListeners()
end

local function NotifyPeerOffline(charKey)
    for _, handlers in pairs(moduleHandlers) do
        if handlers.OnPeerOffline then
            pcall(handlers.OnPeerOffline, charKey)
        end
    end
    FireChangeListeners()
end

-- ============================================================================
-- Internal: Send all module data to a peer (initial handshake only)
-- ============================================================================

local function SendAllModuleData(charKey)
    for modID, handlers in pairs(moduleHandlers) do
        if handlers.GetSyncData then
            local ok, data = pcall(handlers.GetSyncData)
            if ok and data then
                SendTo(charKey, { op = OP_DATA, mod = modID, d = data })
            end
        end
    end
end

-- ============================================================================
-- Internal: Sync Negotiation  (efficient login handshake)
-- ============================================================================
-- When a peer comes online we exchange a lightweight manifest:
--   { charKey → lastSeen }  for every character we know about.
-- The responder compares with its own data and only sends snapshots
-- that are newer than what the requester already has, avoiding
-- redundant full-DB transfers on every login.
-- ============================================================================

--- Build a { charKey → lastSeen } map covering our local + synced chars.
--- Keys are normalized so they match the wire format.
local function BuildSyncManifest()
    local manifest = {}

    -- Own characters (local snapshots)
    local myKey = Core:GetCharKey()
    if Core.CharData then
        manifest[NormalizeCK(myKey)] = Core.CharData.lastSeen or time()
    end
    for _, ck in ipairs(Core:GetAllCharKeys()) do
        if ck ~= myKey then
            local snap = Core:GetCharSnapshot(ck)
            if snap then
                manifest[NormalizeCK(ck)] = snap.lastSeen or 0
            end
        end
    end

    -- Include synced remote chars so the peer knows what we already have
    for _, ck in ipairs(Core:GetAllSyncedCharKeys()) do
        local nck = NormalizeCK(ck)
        if not manifest[nck] then
            local snap = Core:GetSyncedSnapshot(ck)
            if snap then
                manifest[nck] = snap.lastSeen or 0
            end
        end
    end

    return manifest
end

--- Determine which snapshots the requester needs based on their manifest.
--- Returns a set of normalized charKeys where we have newer data.
local function ComputeNeededSnapshots(theirManifest)
    local needed = {}

    -- Check our local snapshots
    local myKey = Core:GetCharKey()
    if Core.CharData then
        local myTs = Core.CharData.lastSeen or time()
        local nck  = NormalizeCK(myKey)
        if not theirManifest[nck] or theirManifest[nck] < myTs then
            needed[nck] = true
        end
    end
    for _, ck in ipairs(Core:GetAllCharKeys()) do
        if ck ~= myKey then
            local snap = Core:GetCharSnapshot(ck)
            if snap then
                local myTs = snap.lastSeen or 0
                local nck  = NormalizeCK(ck)
                if not theirManifest[nck] or theirManifest[nck] < myTs then
                    needed[nck] = true
                end
            end
        end
    end

    return needed
end

--- Send snapshots that the peer needs for whole-DB sync groups.
--- neededKeys uses normalized charKeys; we reverse-map to originals for lookups.
local function SendNeededSnapshots(peerCharKey, neededKeys)
    local myKey   = Core:GetCharKey()
    local normMyK = NormalizeCK(myKey)

    -- Build normalized → original mapping for local snapshot lookups
    local normToOrig = {}
    normToOrig[normMyK] = myKey
    for _, ck in ipairs(Core:GetAllCharKeys()) do
        normToOrig[NormalizeCK(ck)] = ck
    end

    for normCK in pairs(neededKeys) do
        local origCK = normToOrig[normCK]
        local snap
        if origCK == myKey and Core.CharData then
            snap = Core.CharData
        elseif origCK then
            snap = Core:GetCharSnapshot(origCK)
        end
        if snap then
            SendTo(peerCharKey, {
                op  = OP_DB_PUSH,
                ck  = normCK,
                d   = snap,
            })
        end
    end
end

--- Check whether a peer belongs to any whole-DB sync group.
local function IsWholeDBPeer(charKey)
    for _, group in pairs(syncGroups) do
        if group.syncWholeDB and group.targets[charKey] then
            return true
        end
    end
    return false
end

-- ============================================================================
-- Internal: Local Character Set
-- ============================================================================

--- Collect all local charKeys (current char + all account-wide snapshots).
--- Keys are realm-normalized so they match CommLink's internal format.
--- These are the characters that belong to "our" Battle.net account.
---@return table<string, boolean> localChars  set of normalized charKeys
local function GetLocalCharSet()
    local localChars = {}
    local myKey = Core:GetCharKey()
    if myKey and myKey ~= "-" then
        localChars[NormalizeCK(myKey)] = true
    end
    for _, ck in ipairs(Core:GetAllCharKeys()) do
        localChars[NormalizeCK(ck)] = true
    end
    return localChars
end

--- Persist accounts back to DB and notify UI listeners.
local function PersistAccounts()
    if not coreDB or not coreDB.shared then return end
    local dbAccounts = {}
    for name, group in pairs(syncGroups) do
        local targets = {}
        for ck in pairs(group.targets) do
            targets[#targets + 1] = ck
        end
        dbAccounts[name] = {
            targets        = targets,
            syncWholeDB    = group.syncWholeDB or false,
            remoteWholeDB  = group.remoteWholeDB or false,
        }
    end
    coreDB.shared.syncAccounts = dbAccounts

    -- Keep legacy syncTargets in sync for any external readers
    local flat = {}
    for ck in pairs(syncTargets) do flat[#flat + 1] = ck end
    coreDB.shared.syncTargets = flat

    FireChangeListeners()
end

--- Push all local character snapshots to a specific peer via DB_PUSH.
--- Uses original (non-normalized) keys for snapshot lookups but sends
--- normalized keys in the message payload.
---@param peerCharKey string
local function PushAllLocalSnapshots(peerCharKey)
    local myKey = Core:GetCharKey()

    -- Current character (live data)
    if myKey and myKey ~= "-" and Core.CharData then
        SendTo(peerCharKey, {
            op = OP_DB_PUSH,
            ck = NormalizeCK(myKey),
            d  = Core.CharData,
        })
    end

    -- Other characters (snapshots from account-wide DB)
    for _, origCK in ipairs(Core:GetAllCharKeys()) do
        if origCK ~= myKey then
            local snap = Core:GetCharSnapshot(origCK)
            if snap then
                SendTo(peerCharKey, {
                    op = OP_DB_PUSH,
                    ck = NormalizeCK(origCK),
                    d  = snap,
                })
            end
        end
    end
end

--- When we receive a DB_PUSH from a peer for a charKey we haven't seen before,
--- auto-add that charKey to the appropriate account if syncWholeDB is enabled.
---@param senderCharKey string  The charKey that sent the push
---@param newCharKey string     The charKey the snapshot belongs to
local function AutoAddToAccount(senderCharKey, newCharKey)
    if not newCharKey or newCharKey == "" then return end
    -- Already a known target?
    if syncTargets[newCharKey] then return end

    for accountName, group in pairs(syncGroups) do
        if group.syncWholeDB and group.targets[senderCharKey] then
            -- The sender belongs to this whole-DB account — add the new
            -- charKey as well so it shows up in the account.
            group.targets[newCharKey] = true
            syncTargets[newCharKey] = true
            logger:commlink("CommLink: auto-added '%s' to account '%s' (whole-DB expand from '%s')",
                newCharKey, accountName, senderCharKey)
            PersistAccounts()
            return
        end
    end
end

-- ============================================================================
-- Internal: Message Receive + Assembly
-- ============================================================================

--- Handle a fully reassembled message payload.
local function OnMessageReceived(senderCharKey, payload)
    -- Lightweight decode to peek at the op for pairing messages from strangers
    local msg, err = DecodeFromChannel(payload)
    if not msg or type(msg) ~= "table" then
        logger:commlink("CommLink: decode failed from '%s': %s", senderCharKey, err or "?")
        return
    end

    local op = msg.op

    -- ── Whole-DB decline: peer declined our WDB request ──
    if op == OP_WDB_DEC then
        C_Timer.After(0, function()
            if not syncTargets[senderCharKey] then return end
            -- Reset syncWholeDB on the account this peer belongs to
            for accountName, group in pairs(syncGroups) do
                if group.targets[senderCharKey] and group.syncWholeDB then
                    group.syncWholeDB = false
                    PersistAccounts()
                    logger:commlink("CommLink: WDB declined by '%s' — disabled on account '%s'", senderCharKey, accountName)
                    break
                end
            end
        end)
        return
    end

    -- ── Whole-DB cancel: requester withdrew their WDB request ──
    if op == OP_WDB_CAN then
        C_Timer.After(0, function()
            if coreDB and coreDB.shared and coreDB.shared.pendingWDBRequests then
                if coreDB.shared.pendingWDBRequests[senderCharKey] then
                    coreDB.shared.pendingWDBRequests[senderCharKey] = nil
                    FireChangeListeners()
                    logger:commlink("CommLink: WDB request from '%s' cancelled by sender", senderCharKey)
                end
            end
        end)
        return
    end

    -- ── Whole-DB request: peer wants to negotiate whole-account sync ──
    if op == OP_WDB_REQ then
        C_Timer.After(0, function()
            -- Blocked?
            if coreDB and coreDB.shared and coreDB.shared.blockedUsers
                and coreDB.shared.blockedUsers[senderCharKey] then
                return
            end

            -- Must be a known sync target
            if not syncTargets[senderCharKey] then
                logger:commlink("CommLink: WDB_REQ from unknown target '%s' — ignored", senderCharKey)
                return
            end

            -- Store as pending WDB request so the UI can show a prompt
            if coreDB and coreDB.shared then
                coreDB.shared.pendingWDBRequests = coreDB.shared.pendingWDBRequests or {}
                coreDB.shared.pendingWDBRequests[senderCharKey] = {
                    from     = senderCharKey,
                    siblings = msg.siblings or {},
                    time     = time(),
                }
            end

            -- Notify modules (UI refresh)
            FireChangeListeners()
            for _, handlers in pairs(moduleHandlers) do
                if handlers.OnWDBRequest then
                    pcall(handlers.OnWDBRequest, senderCharKey, msg.siblings)
                end
            end
            logger:commlink("CommLink: WDB_REQ from '%s' stored as pending", senderCharKey)
        end)
        return
    end

    -- ── Whole-DB acknowledgement: peer agreed to whole-account sync ──
    if op == OP_WDB_ACK then
        C_Timer.After(0, function()
            if not syncTargets[senderCharKey] then return end

            local mode     = msg.mode      -- "receive" or "both"
            local siblings = msg.siblings   -- remote sibling list

            -- Find the account this peer belongs to
            for accountName, group in pairs(syncGroups) do
                if group.targets[senderCharKey] then
                    -- Enable syncWholeDB locally (the user already requested it)
                    group.syncWholeDB = true

                    -- Track remote side's decision
                    if mode == "both" then
                        group.remoteWholeDB = true
                    end

                    -- Extend targets with remote siblings
                    if siblings and type(siblings) == "table" then
                        local localChars = GetLocalCharSet()
                        for _, sibCK in ipairs(siblings) do
                            local nck = NormalizeCK(sibCK)
                            if not localChars[nck] and not group.targets[nck] then
                                group.targets[nck] = true
                                syncTargets[nck]   = true
                                logger:commlink("CommLink: WDB_ACK — added '%s' to account '%s'", nck, accountName)
                            end
                        end
                    end

                    PersistAccounts()

                    -- First-time establishment: push everything once.
                    -- Subsequent reconnects use manifest-based delta only.
                    local localChars = GetLocalCharSet()
                    local localCharList = {}
                    for ck in pairs(localChars) do
                        localCharList[#localCharList + 1] = ck
                    end
                    SendTo(senderCharKey, {
                        op       = OP_SIB_INTRO,
                        siblings = localCharList,
                        wholeDB  = true,
                    })
                    PushAllLocalSnapshots(senderCharKey)

                    StartSending()
                    logger:commlink("CommLink: WDB_ACK from '%s' mode='%s' — reconciliation started", senderCharKey, mode or "?")
                    return
                end
            end
        end)
        return
    end

    -- ── Sibling intro: accepted from ANY sender (unknown alt of known peer) ──
    if op == OP_SIB_INTRO then
        C_Timer.After(0, function()
            local siblings      = msg.siblings  -- array of charKeys on sender's account
            local remoteWholeDB = msg.wholeDB
            local isReply       = msg.reply      -- true if this is a response to our intro

            if not siblings or type(siblings) ~= "table" or #siblings == 0 then
                logger:commlink("CommLink: rejected sibling intro from '%s' (no siblings list)", senderCharKey)
                return
            end

            -- Blocked?
            if coreDB and coreDB.shared and coreDB.shared.blockedUsers
                and coreDB.shared.blockedUsers[senderCharKey] then
                return
            end

            -- Normalize incoming sibling keys (sender may use spaced realm)
            local normSiblings = {}
            for _, sibCK in ipairs(siblings) do
                normSiblings[#normSiblings + 1] = NormalizeCK(sibCK)
            end

            -- Validate: at least one claimed sibling must be in one of our
            -- sync accounts.  Find the matching account.
            for accountName, group in pairs(syncGroups) do
                -- Only process if at least one side has wholeDB
                if not group.syncWholeDB and not remoteWholeDB then
                    -- neither side wants whole-account — skip this group
                else
                    local matchedSibling = nil
                    for _, sibCK in ipairs(normSiblings) do
                        if group.targets[sibCK] then
                            matchedSibling = sibCK
                            break
                        end
                    end

                    if matchedSibling then
                        -- Add the sender plus ALL claimed siblings as targets.
                        -- This lets us reach any character on the remote account
                        -- without waiting for each one to introduce itself.
                        local localChars = GetLocalCharSet()
                        -- Use a set to avoid duplicates from sender + siblings overlap
                        local toAdd = {}
                        toAdd[senderCharKey] = true
                        for _, sibCK in ipairs(normSiblings) do
                            toAdd[sibCK] = true
                        end
                        local addedNew = false
                        for remoteCK in pairs(toAdd) do
                            if not localChars[remoteCK] and not group.targets[remoteCK] then
                                group.targets[remoteCK] = true
                                syncTargets[remoteCK]   = true
                                addedNew = true
                                logger:commlink("CommLink: sibling intro — added '%s' to account '%s' (sibling of '%s')",
                                    remoteCK, accountName, matchedSibling)
                            end
                        end

                        -- Track that the remote side has wholeDB enabled
                        if remoteWholeDB and not group.remoteWholeDB then
                            group.remoteWholeDB = true
                        end

                        PersistAccounts()

                        -- If this is NOT a reply, send our own sibling list back
                        -- so the sender discovers all characters on our account.
                        if not isReply then
                            local ourLocals = GetLocalCharSet()
                            local ourList = {}
                            for ck in pairs(ourLocals) do
                                ourList[#ourList + 1] = ck
                            end
                            SendTo(senderCharKey, {
                                op       = OP_SIB_INTRO,
                                siblings = ourList,
                                wholeDB  = group.syncWholeDB,
                                reply    = true,
                            })
                        end

                        -- If new siblings were discovered, exchange manifests
                        -- with the sender so both sides fill any data gaps
                        -- for the newly added characters.
                        if addedNew and (group.syncWholeDB or remoteWholeDB) then
                            -- Manifest exchange handles delta — only sends
                            -- snapshots the peer doesn't already have
                            SendTo(senderCharKey, {
                                op = OP_SYNC_REQ,
                                m  = BuildSyncManifest(),
                            })
                        end

                        StartSending()
                        return
                    end
                end
            end
            logger:commlink("CommLink: sibling intro from '%s' — no matching whole-DB account", senderCharKey)
        end)
        return
    end

    -- ── Pairing ops are accepted from ANY sender (not just syncTargets) ──
    if op == OP_PAIR_REQ or op == OP_PAIR_ACK or op == OP_PAIR_DEC or op == OP_PAIR_BLK then
        C_Timer.After(0, function()
            if op == OP_PAIR_REQ then
                -- Peer wants to pair with us.
                -- If we already have them as a sync target, auto-accept.
                if syncTargets[senderCharKey] then
                    SendTo(senderCharKey, { op = OP_PAIR_ACK })
                    logger:commlink("CommLink: auto-accepted pairing from '%s' (already a target)", senderCharKey)
                    return
                end
                -- If we blocked them, silently respond with block.
                if coreDB and coreDB.shared and coreDB.shared.blockedUsers
                    and coreDB.shared.blockedUsers[senderCharKey] then
                    SendTo(senderCharKey, { op = OP_PAIR_BLK })
                    logger:commlink("CommLink: blocked pairing from '%s'", senderCharKey)
                    return
                end
                -- Store as pending request
                if coreDB and coreDB.shared then
                    coreDB.shared.pendingRequests = coreDB.shared.pendingRequests or {}
                    coreDB.shared.pendingRequests[senderCharKey] = {
                        from = senderCharKey,
                        time = time(),
                    }
                    FireChangeListeners()
                end
                -- Notify modules of the incoming request
                for _, handlers in pairs(moduleHandlers) do
                    if handlers.OnPairRequest then
                        pcall(handlers.OnPairRequest, senderCharKey)
                    end
                end
                logger:commlink("CommLink: pairing request from '%s' stored as pending", senderCharKey)

            elseif op == OP_PAIR_ACK then
                -- Peer accepted our pairing request.
                -- The target is already in our syncGroups (we added them first),
                -- so just notify modules.
                for _, handlers in pairs(moduleHandlers) do
                    if handlers.OnPairAccepted then
                        pcall(handlers.OnPairAccepted, senderCharKey)
                    end
                end
                FireChangeListeners()
                logger:commlink("CommLink: peer '%s' accepted pairing", senderCharKey)

            elseif op == OP_PAIR_DEC then
                -- Peer declined our request.
                for _, handlers in pairs(moduleHandlers) do
                    if handlers.OnPairDeclined then
                        pcall(handlers.OnPairDeclined, senderCharKey)
                    end
                end
                FireChangeListeners()
                logger:commlink("CommLink: peer '%s' declined pairing", senderCharKey)

            elseif op == OP_PAIR_BLK then
                -- Peer blocked us.
                for _, handlers in pairs(moduleHandlers) do
                    if handlers.OnPairBlocked then
                        pcall(handlers.OnPairBlocked, senderCharKey)
                    end
                end
                FireChangeListeners()
                logger:commlink("CommLink: peer '%s' blocked us", senderCharKey)
            end
        end)
        return
    end

    -- ── All other ops require the sender to be a configured sync target ──
    if not syncTargets[senderCharKey] then return end

    -- Track peer online state (lightweight — runs immediately)
    local isNew = not onlinePeers[senderCharKey]
    onlinePeers[senderCharKey] = { lastSeen = time() }

    if isNew then
        logger:commlink("CommLink: peer '%s' is online", senderCharKey)
        NotifyPeerOnline(senderCharKey)
    end

    -- Defer the heavy work (decompress + deserialize + module callbacks)
    -- to the next frame so it doesn't stutter the CHAT_MSG_ADDON handler.
    C_Timer.After(0, function()
        local msg, err = DecodeFromChannel(payload)
        if not msg or type(msg) ~= "table" then
            logger:commlink("CommLink: decode failed from '%s': %s", senderCharKey, err or "?")
            return
        end

        local op = msg.op

        if op == OP_PING then
            SendTo(senderCharKey, { op = OP_PONG })
            if isNew then
                SendAllModuleData(senderCharKey)
                -- If this peer belongs to a whole-DB account, sync directly.
                -- Only send WDB_REQ for accounts that haven't negotiated yet
                -- (syncWholeDB=true but never got acknowledgement from anyone).
                for _, group in pairs(syncGroups) do
                    if group.targets[senderCharKey] and group.syncWholeDB then
                        if group.remoteWholeDB then
                            -- Already established — manifest exchange handles delta
                            SendTo(senderCharKey, {
                                op = OP_SYNC_REQ,
                                m  = BuildSyncManifest(),
                            })
                        else
                            -- Not yet acknowledged — send negotiation request
                            local localChars = GetLocalCharSet()
                            local localCharList = {}
                            for ck in pairs(localChars) do
                                localCharList[#localCharList + 1] = ck
                            end
                            SendTo(senderCharKey, {
                                op       = OP_WDB_REQ,
                                siblings = localCharList,
                            })
                        end
                        break
                    end
                end
            end

        elseif op == OP_PONG then
            if isNew then
                SendAllModuleData(senderCharKey)
                for _, group in pairs(syncGroups) do
                    if group.targets[senderCharKey] and group.syncWholeDB then
                        if group.remoteWholeDB then
                            -- Already established — manifest exchange handles delta
                            SendTo(senderCharKey, {
                                op = OP_SYNC_REQ,
                                m  = BuildSyncManifest(),
                            })
                        else
                            local localChars = GetLocalCharSet()
                            local localCharList = {}
                            for ck in pairs(localChars) do
                                localCharList[#localCharList + 1] = ck
                            end
                            SendTo(senderCharKey, {
                                op       = OP_WDB_REQ,
                                siblings = localCharList,
                            })
                        end
                        break
                    end
                end
            end

        elseif op == OP_SYNC_REQ then
            -- Peer sent their manifest; respond with chars they need.
            -- Receiving a SYNC_REQ proves the remote side considers us a
            -- whole-DB peer — track that so we know it's bidirectional.
            if msg.m and IsWholeDBPeer(senderCharKey) then
                -- Mark remoteWholeDB on the account
                for _, group in pairs(syncGroups) do
                    if group.targets[senderCharKey] and group.syncWholeDB
                        and not group.remoteWholeDB then
                        group.remoteWholeDB = true
                        PersistAccounts()
                    end
                end

                local needed = ComputeNeededSnapshots(msg.m)
                SendNeededSnapshots(senderCharKey, needed)
                -- Also send our manifest back so they can send us what we need
                SendTo(senderCharKey, {
                    op = OP_SYNC_RESP,
                    m  = BuildSyncManifest(),
                })
            end

        elseif op == OP_SYNC_RESP then
            -- Peer responded with their manifest; send them what they're missing
            if msg.m and IsWholeDBPeer(senderCharKey) then
                local needed = ComputeNeededSnapshots(msg.m)
                SendNeededSnapshots(senderCharKey, needed)
            end

        elseif op == OP_DB_PUSH then
            -- Whole-DB snapshot push for a specific charKey
            local ck = NormalizeCK(msg.ck or "")
            local data = msg.d
            if ck and ck ~= "" and data and type(data) == "table" and data.name and data.realm then
                CommLink:StoreSyncedSnapshot(ck, data)

                -- Update syncMeta
                if coreDB then
                    coreDB.syncMeta = coreDB.syncMeta or {}
                    coreDB.syncMeta[ck] = {
                        lastSeen   = data.lastSeen or time(),
                        lastSynced = time(),
                    }
                end

                -- Auto-expand: if the sender belongs to a whole-DB account,
                -- add this previously-unknown charKey to that account.
                AutoAddToAccount(senderCharKey, ck)

                logger:commlink("CommLink: DB_PUSH received '%s' from '%s'", ck, senderCharKey)
            end

        elseif op == OP_DATA then
            local modID = msg.mod
            if modID and moduleHandlers[modID] and moduleHandlers[modID].OnDataReceived then
                local ok2, err2 = pcall(moduleHandlers[modID].OnDataReceived, senderCharKey, msg.d)
                if not ok2 then
                    logger:commlink("CommLink: OnDataReceived error '%s': %s", modID, err2 or "?")
                end
            end
        end
    end)
end

--- Process an incoming CHAT_MSG_ADDON packet.
local function OnAddonMessage(event, prefix, message, channel, sender)
    if prefix ~= PREFIX then return end
    if channel ~= "WHISPER" then return end

    local senderKey = NormalizeSender(sender)

    -- Ignore self
    -- Ignore self (compare normalized forms)
    local myKey = NormalizeCK(Core:GetCharKey())
    if senderKey == myKey then return end

    -- Blocked users are rejected at the packet level (no assembly, no decode)
    if coreDB and coreDB.shared and coreDB.shared.blockedUsers
        and coreDB.shared.blockedUsers[senderKey] then
        return
    end

    if string_len(message) < 2 then return end

    local ctl     = string_byte(message, 1)
    local payload = string_sub(message, 2)

    if ctl == 1 then       -- CTL_SINGLE
        OnMessageReceived(senderKey, payload)

    elseif ctl == 2 then   -- CTL_START
        assemblyBuffer[senderKey] = { parts = { payload }, n = 1 }

    elseif ctl == 3 then   -- CTL_MID
        local buf = assemblyBuffer[senderKey]
        if buf then
            buf.n = buf.n + 1
            buf.parts[buf.n] = payload
        end

    elseif ctl == 4 then   -- CTL_END
        local buf = assemblyBuffer[senderKey]
        if buf then
            buf.n = buf.n + 1
            buf.parts[buf.n] = payload
            local full = table_concat(buf.parts)
            assemblyBuffer[senderKey] = nil
            OnMessageReceived(senderKey, full)
        end
    end
end

-- ============================================================================
-- Internal: Peer Discovery + Staleness
-- ============================================================================

local function PingAllTargets()
    if Core.States and Core.States.inCombat then return end
    local msg = { op = OP_PING }
    for charKey in pairs(syncTargets) do
        SendTo(charKey, msg)
    end
end

local function CheckStalePeers()
    local now = time()
    for charKey, info in pairs(onlinePeers) do
        if now - info.lastSeen > STALE_TIMEOUT then
            onlinePeers[charKey] = nil
            logger:commlink("CommLink: peer '%s' timed out", charKey)
            NotifyPeerOffline(charKey)
        end
    end
end

-- ============================================================================
-- Public API
-- ============================================================================

--- Register a module for cross-account communication.
---
---@param moduleID string
---@param handlers CommLinkModuleHandler
---@return boolean
function CommLink:RegisterModule(moduleID, handlers)
    if not moduleID or not handlers then return false end
    moduleHandlers[moduleID] = handlers
    logger:commlink("CommLink: module '%s' registered", moduleID)
    return true
end

--- Unregister a module from communication.
---@param moduleID string
function CommLink:UnregisterModule(moduleID)
    moduleHandlers[moduleID] = nil
end

--- Send data to a specific online peer on behalf of a module.
--- Skipped in combat.
---@param moduleID string
---@param targetCharKey string
---@param data table
function CommLink:SendData(moduleID, targetCharKey, data)
    if Core.States and Core.States.inCombat then return end
    if not onlinePeers[targetCharKey] then return end

    SendTo(targetCharKey, { op = OP_DATA, mod = moduleID, d = data })
end

--- Send data to all currently online peers.
---@param moduleID string
---@param data table
function CommLink:BroadcastData(moduleID, data)
    for charKey in pairs(onlinePeers) do
        self:SendData(moduleID, charKey, data)
    end
end

-- ============================================================================
-- Sync Account Management
-- ============================================================================
-- "Accounts" (formerly "Groups") represent a single remote Battle.net account.
-- Each account entry holds a set of known character keys from that account
-- and a flag controlling whether whole-account sync is enabled.
--
-- When syncWholeDB is true the system automatically expands the target list:
--   • On login, the local player checks whether it belongs to an account that
--     has a whole-DB sync account — if so, its charKey is auto-registered.
--   • When a remote peer sends snapshots for characters we haven't seen yet,
--     those characters are auto-added to the account's target set.
--
-- Persisted in coreDB.shared.syncAccounts[accountName] = {
--   targets       = { "Name-Realm", ... },   -- array for persistence
--   syncWholeDB   = false,
-- }
--
-- At runtime, syncGroups[accountName].targets is a set (charKey → true) for
-- fast membership checks.  The flat syncTargets set is derived from all accounts.
-- ============================================================================

--- Rebuild the flat syncTargets set from all accounts.
local function RebuildSyncTargets()
    for k in pairs(syncTargets) do syncTargets[k] = nil end
    for _, group in pairs(syncGroups) do
        for ck in pairs(group.targets) do
            syncTargets[ck] = true
        end
    end
end

--- Check whether the remote side of a whole-DB account also has wholeDB
--- enabled.  We don't know their flag directly, but we track it:
--- when we receive a SYNC_REQ from them for whole-DB data, that means
--- they consider us a whole-DB peer too.  For now, we treat any whole-DB
--- account as bidirectional at the intro level — the data-flow direction
--- is controlled by who responds to SYNC_REQ/SYNC_RESP.
---
--- Returns "both", "local", or "none" indicating who has wholeDB enabled.
---@param accountName string
---@return string side  "both"|"local"|"none"
local function GetWholeDBSide(accountName)
    local group = syncGroups[accountName]
    if not group or not group.syncWholeDB then return "none" end
    -- If the remote side has wholeDB is tracked via remoteWholeDB flag
    -- (set when we receive OP_SIB_INTRO or OP_SYNC_REQ from them).
    if group.remoteWholeDB then return "both" end
    return "local"
end

--- Auto-expand whole-account sync on login / when whole-DB is enabled.
---
--- For every whole-DB account that has at least one remote target:
---   1. Send OP_SIB_INTRO to all remote targets so they discover *this*
---      character even if it wasn't in their target list yet.
---   2. For already-online peers, proactively push all local snapshots
---      and initiate sync negotiation immediately.
---   3. Ping offline targets to trigger discovery when they come online.
---
--- The remote side handles adding us via the OP_SIB_INTRO handler.
--- We do NOT add local chars as sync targets (you don't sync to yourself).
local function AutoExpandWholeAccountSync()
    local myKey = Core:GetCharKey()
    if myKey == "-" then return end

    local localChars = GetLocalCharSet()

    -- Build a flat list of local charKeys for the sibling intro payload.
    local localCharList = {}
    for ck in pairs(localChars) do
        localCharList[#localCharList + 1] = ck
    end

    for accountName, group in pairs(syncGroups) do
        if group.syncWholeDB then
            -- Collect remote targets (chars NOT on our local account).
            local remoteTargets = {}
            for ck in pairs(group.targets) do
                if not localChars[ck] then
                    remoteTargets[#remoteTargets + 1] = ck
                end
            end

            if #remoteTargets > 0 then
                -- Send sibling intro to every remote target.
                -- We include ALL local charKeys so the remote can validate
                -- that at least one is in their target list.
                for _, remoteCK in ipairs(remoteTargets) do
                    SendTo(remoteCK, {
                        op       = OP_SIB_INTRO,
                        siblings = localCharList,
                        wholeDB  = true,
                    })
                    -- Ping to start normal handshake once targets are extended
                    SendTo(remoteCK, { op = OP_PING })
                end
                StartSending()
            end
        end
    end
end

--- Create a sync account.
---@param accountName string
---@param options? { syncWholeDB?: boolean }
---@return boolean created
function CommLink:CreateSyncGroup(accountName, options)
    if not accountName or accountName == "" then return false end
    if syncGroups[accountName] then return false end -- already exists

    syncGroups[accountName] = {
        targets     = {},
        syncWholeDB = options and options.syncWholeDB or false,
    }
    PersistAccounts()
    logger:commlink("CommLink: account '%s' created", accountName)
    return true
end

--- Delete a sync account and all its targets.
---@param accountName string
function CommLink:DeleteSyncGroup(accountName)
    local group = syncGroups[accountName]
    if not group then return end

    -- Clean up online state + synced data for targets in this account
    for ck in pairs(group.targets) do
        onlinePeers[ck]    = nil
        assemblyBuffer[ck] = nil
    end

    syncGroups[accountName] = nil
    RebuildSyncTargets()
    PersistAccounts()
    logger:commlink("CommLink: account '%s' deleted", accountName)
end

--- Rename a sync account.
---@param oldName string
---@param newName string
---@return boolean renamed
function CommLink:RenameSyncGroup(oldName, newName)
    if not syncGroups[oldName] or syncGroups[newName] then return false end
    syncGroups[newName] = syncGroups[oldName]
    syncGroups[oldName] = nil
    PersistAccounts()
    return true
end

--- Set an account option.
---@param accountName string
---@param key string  e.g. "syncWholeDB"
---@param value any
function CommLink:SetGroupOption(accountName, key, value)
    local group = syncGroups[accountName]
    if not group then return end
    group[key] = value
    PersistAccounts()

    -- If we just disabled whole-DB, cancel any pending WDB requests at the remote.
    if key == "syncWholeDB" and not value then
        local localChars = GetLocalCharSet()
        for ck in pairs(group.targets) do
            if not localChars[ck] then
                SendTo(ck, { op = OP_WDB_CAN })
            end
        end
        StartSending()
    end

    -- If we just enabled whole-DB, send a request to the remote side asking
    -- them to agree.  Enable syncWholeDB immediately — the requester obviously
    -- wants it.  If the remote declines (WDB_DEC), it will be reset to false.
    if key == "syncWholeDB" and value then
        group.syncWholeDB = true
        PersistAccounts()

        -- Build sibling list for the request
        local localChars = GetLocalCharSet()
        local localCharList = {}
        for ck in pairs(localChars) do
            localCharList[#localCharList + 1] = ck
        end

        -- Send WDB_REQ to all online remote targets in this group
        local sentAny = false
        for ck in pairs(group.targets) do
            if not localChars[ck] and onlinePeers[ck] then
                SendTo(ck, {
                    op       = OP_WDB_REQ,
                    siblings = localCharList,
                })
                sentAny = true
            end
        end

        if sentAny then
            StartSending()
            logger:commlink("CommLink: sent WDB_REQ for account '%s'", accountName)
        else
            -- No online peers — auto-expand so it activates on next login
            AutoExpandWholeAccountSync()
            logger:commlink("CommLink: no online peers for WDB_REQ, enabled locally for account '%s'", accountName)
        end
    end
end

--- Get account options / info.
---@param accountName string
---@return table|nil  { targets = {ck→true}, syncWholeDB = bool }
function CommLink:GetSyncGroup(accountName)
    return syncGroups[accountName]
end

--- Get all sync accounts.
---@return table<string, table>
function CommLink:GetAllSyncGroups()
    return syncGroups
end

--- Add a sync target to a specific account.  Persisted and immediately pinged.
---@param charKey string  "Name-Realm"
---@param accountName string
---@return boolean added
function CommLink:AddSyncTarget(charKey, accountName)
    charKey = ResolveCharKey(charKey)
    if not charKey or charKey == "" or charKey == "-" then return false end

    -- Default to "Default" account if none specified (backward compat)
    accountName = accountName or "Default"

    -- Auto-create the account if it doesn't exist
    if not syncGroups[accountName] then
        syncGroups[accountName] = {
            targets     = {},
            syncWholeDB = false,
        }
    end

    local group = syncGroups[accountName]
    if group.targets[charKey] then return false end -- already in account

    -- Remove from any other account first (a target belongs to one account)
    for gn, g in pairs(syncGroups) do
        if g.targets[charKey] then
            g.targets[charKey] = nil
        end
    end

    group.targets[charKey] = true
    RebuildSyncTargets()
    PersistAccounts()

    -- Ping immediately + pairing request.
    -- Whole-DB negotiation happens automatically once the peer is online
    -- (see PING/PONG new-peer handler).
    SendTo(charKey, { op = OP_PING })
    SendTo(charKey, { op = OP_PAIR_REQ })
    StartSending()

    logger:commlink("CommLink: sync target '%s' added to account '%s'", charKey, accountName)
    return true
end

--- Remove a sync target from its account and clean up synced data.
---@param charKey string
function CommLink:RemoveSyncTarget(charKey)
    charKey = ResolveCharKey(charKey)

    -- Remove from whichever account it's in
    for _, group in pairs(syncGroups) do
        group.targets[charKey] = nil
    end

    onlinePeers[charKey]    = nil
    assemblyBuffer[charKey] = nil

    -- Remove synced snapshot
    if coreDB and coreDB.syncedSnapshots then
        coreDB.syncedSnapshots[charKey] = nil
    end
    if CommLink._snapshotCache then
        CommLink._snapshotCache[charKey] = nil
    end

    RebuildSyncTargets()
    PersistAccounts()

    logger:commlink("CommLink: sync target removed '%s'", charKey)
end

--- Get configured sync targets (all accounts combined).
---@return string[]
function CommLink:GetSyncTargets()
    local result = {}
    for charKey in pairs(syncTargets) do
        result[#result + 1] = charKey
    end
    return result
end

--- Get sync targets for a specific account.
---@param accountName string
---@return string[]
function CommLink:GetGroupTargets(accountName)
    local group = syncGroups[accountName]
    if not group then return {} end
    local result = {}
    for ck in pairs(group.targets) do
        result[#result + 1] = ck
    end
    return result
end

--- Find which account a target belongs to.
---@param charKey string
---@return string|nil accountName
function CommLink:GetTargetGroup(charKey)
    for gn, group in pairs(syncGroups) do
        if group.targets[charKey] then return gn end
    end
    return nil
end

--- Check if a specific peer is currently online.
---@param charKey string
---@return boolean
function CommLink:IsPeerOnline(charKey)
    return onlinePeers[charKey] ~= nil
end

--- Get all currently online peers as a set.
---@return table<string, boolean>
function CommLink:GetOnlinePeers()
    local result = {}
    for charKey in pairs(onlinePeers) do
        result[charKey] = true
    end
    return result
end

--- Return the number of configured sync targets.
---@return number
function CommLink:GetSyncTargetCount()
    local n = 0
    for _ in pairs(syncTargets) do n = n + 1 end
    return n
end

-- ============================================================================
-- Pairing / Connection Request Management
-- ============================================================================
-- When Target A adds Target B, A sends OP_PAIR_REQ.  Target B sees a
-- "Request Pending" entry and can Accept (into a group), Decline, or Block.
-- ============================================================================

--- Send a pairing request to a peer.  Called automatically when adding a
--- sync target that hasn't accepted us yet.
---@param charKey string
function CommLink:SendPairRequest(charKey)
    charKey = ResolveCharKey(charKey)
    if not charKey or charKey == "" then return end
    SendTo(charKey, { op = OP_PAIR_REQ })
    StartSending()
    logger:commlink("CommLink: sent pairing request to '%s'", charKey)
end

--- Accept a pending pairing request and add the peer to a group.
---@param charKey string  The requester's charKey
---@param groupName? string  Group to put them in (default "Default")
---@param syncWholeDB? boolean  Whether to enable whole-DB sync for the group
function CommLink:AcceptPairRequest(charKey, groupName, syncWholeDB)
    charKey = ResolveCharKey(charKey)

    -- Remove from pending
    if coreDB and coreDB.shared and coreDB.shared.pendingRequests then
        coreDB.shared.pendingRequests[charKey] = nil
    end

    -- Add them as a sync target (creates group if needed)
    groupName = groupName or "Default"
    self:AddSyncTarget(charKey, groupName)

    -- Optionally enable whole-DB on the group
    if syncWholeDB then
        self:SetGroupOption(groupName, "syncWholeDB", true)
    end

    -- Tell the peer we accepted
    SendTo(charKey, { op = OP_PAIR_ACK })
    StartSending()
    logger:commlink("CommLink: accepted pairing from '%s' into group '%s'", charKey, groupName)
end

--- Decline a pending pairing request.
---@param charKey string
function CommLink:DeclinePairRequest(charKey)
    charKey = ResolveCharKey(charKey)

    -- Remove from pending
    if coreDB and coreDB.shared and coreDB.shared.pendingRequests then
        coreDB.shared.pendingRequests[charKey] = nil
    end

    -- Tell the peer
    SendTo(charKey, { op = OP_PAIR_DEC })
    StartSending()
    logger:commlink("CommLink: declined pairing from '%s'", charKey)
end

--- Block a user (removes pending request and ignores all future attempts).
---@param charKey string
function CommLink:BlockUser(charKey)
    charKey = ResolveCharKey(charKey)
    if not coreDB or not coreDB.shared then return end

    -- Remove from pending
    coreDB.shared.pendingRequests = coreDB.shared.pendingRequests or {}
    coreDB.shared.pendingRequests[charKey] = nil

    -- Add to block list
    coreDB.shared.blockedUsers = coreDB.shared.blockedUsers or {}
    coreDB.shared.blockedUsers[charKey] = true

    -- Also remove as sync target if they were one
    self:RemoveSyncTarget(charKey)

    -- Notify the peer
    SendTo(charKey, { op = OP_PAIR_BLK })
    StartSending()
    logger:commlink("CommLink: blocked user '%s'", charKey)
end

--- Unblock a user.
---@param charKey string
function CommLink:UnblockUser(charKey)
    charKey = ResolveCharKey(charKey)
    if coreDB and coreDB.shared and coreDB.shared.blockedUsers then
        coreDB.shared.blockedUsers[charKey] = nil
    end
    logger:commlink("CommLink: unblocked user '%s'", charKey)
end

--- Get all pending pairing requests.
---@return table<string, table>  charKey → { from, time }
function CommLink:GetPendingRequests()
    if coreDB and coreDB.shared and coreDB.shared.pendingRequests then
        return coreDB.shared.pendingRequests
    end
    return {}
end

--- Get the blocked users set.
---@return table<string, boolean>
function CommLink:GetBlockedUsers()
    if coreDB and coreDB.shared and coreDB.shared.blockedUsers then
        return coreDB.shared.blockedUsers
    end
    return {}
end

--- Check whether a charKey has a pending request.
---@param charKey string
---@return boolean
function CommLink:HasPendingRequest(charKey)
    if coreDB and coreDB.shared and coreDB.shared.pendingRequests then
        return coreDB.shared.pendingRequests[charKey] ~= nil
    end
    return false
end

--- Check whether a charKey is blocked.
---@param charKey string
---@return boolean
function CommLink:IsBlocked(charKey)
    if coreDB and coreDB.shared and coreDB.shared.blockedUsers then
        return coreDB.shared.blockedUsers[charKey] == true
    end
    return false
end

-- ============================================================================
-- Whole-DB Request Management
-- ============================================================================
-- When Side A toggles "Enable Whole Acc", a WDB_REQ is sent to online peers.
-- The receiving side sees a prompt: "Only receive" or "Also share my whole DB".
-- The response (WDB_ACK) carries the mode and sibling list.
-- ============================================================================

--- Accept a pending whole-DB request.
---@param charKey string  The requester's charKey
---@param mode string     "receive" (only receive their data) or "both" (share ours too)
function CommLink:AcceptWDBRequest(charKey, mode)
    charKey = ResolveCharKey(charKey)

    -- Remove from pending
    if coreDB and coreDB.shared and coreDB.shared.pendingWDBRequests then
        coreDB.shared.pendingWDBRequests[charKey] = nil
    end

    -- Find the account this peer belongs to
    local accountName = self:GetTargetGroup(charKey)
    if not accountName then
        logger:commlink("CommLink: WDB accept from '%s' but no matching account", charKey)
        return
    end

    local group = syncGroups[accountName]
    if not group then return end

    -- If the receiver chose "also share", enable wholeDB locally
    if mode == "both" then
        group.syncWholeDB = true
    end
    group.remoteWholeDB = true  -- the requester always shares theirs

    -- Extend our targets with their siblings from the request
    local reqData = coreDB and coreDB.shared and coreDB.shared.pendingWDBRequests
        and coreDB.shared.pendingWDBRequests[charKey]
    -- (already removed above, but siblings were in the original request payload)

    PersistAccounts()

    -- Build our sibling list for the ACK
    local localChars = GetLocalCharSet()
    local localCharList = {}
    for ck in pairs(localChars) do
        localCharList[#localCharList + 1] = ck
    end

    -- Send acknowledgement
    SendTo(charKey, {
        op       = OP_WDB_ACK,
        mode     = mode,
        siblings = localCharList,
    })

    -- If we're also sharing, push our DB to the requester.
    -- First-time establishment: push everything once.
    -- Subsequent reconnects use manifest-based delta only.
    if mode == "both" then
        SendTo(charKey, {
            op       = OP_SIB_INTRO,
            siblings = localCharList,
            wholeDB  = true,
        })
        PushAllLocalSnapshots(charKey)
    end

    StartSending()
    FireChangeListeners()
    logger:commlink("CommLink: accepted WDB request from '%s' mode='%s'", charKey, mode)
end

--- Decline a pending whole-DB request and notify the requester.
---@param charKey string
function CommLink:DeclineWDBRequest(charKey)
    charKey = ResolveCharKey(charKey)
    if coreDB and coreDB.shared and coreDB.shared.pendingWDBRequests then
        coreDB.shared.pendingWDBRequests[charKey] = nil
    end
    -- Tell the requester so they reset syncWholeDB
    SendTo(charKey, { op = OP_WDB_DEC })
    StartSending()
    FireChangeListeners()
    logger:commlink("CommLink: declined WDB request from '%s'", charKey)
end

--- Get all pending whole-DB requests.
---@return table<string, table>  charKey → { from, siblings, time }
function CommLink:GetPendingWDBRequests()
    if coreDB and coreDB.shared and coreDB.shared.pendingWDBRequests then
        return coreDB.shared.pendingWDBRequests
    end
    return {}
end

--- Check whether a charKey has a pending WDB request.
---@param charKey string
---@return boolean
function CommLink:HasPendingWDBRequest(charKey)
    if coreDB and coreDB.shared and coreDB.shared.pendingWDBRequests then
        return coreDB.shared.pendingWDBRequests[charKey] ~= nil
    end
    return false
end

-- ============================================================================
-- Synced Snapshot Storage  (Core-level, module-agnostic)
-- ============================================================================
-- Remote character snapshots received via CommLink are stored in
-- PrephsFrameworkDB.syncedSnapshots[charKey].  Any module can read
-- them via Core:GetSyncedSnapshot / Core:GetAllSyncedCharKeys.
-- ============================================================================

--- Store a synced character snapshot received from a remote peer.
--- The snapshot is held in an in-memory cache for fast reads; packing to
--- the SavedVariable DB is deferred so it doesn't stutter the frame.
---@param charKey string  "Name-Realm"
---@param snapshot PFCharacterSnapshot
function CommLink:StoreSyncedSnapshot(charKey, snapshot)
    if not coreDB then return end
    coreDB.syncedSnapshots = coreDB.syncedSnapshots or {}

    snapshot.lastSeen = time()

    -- Fast path: update cache immediately (reads always hit cache first)
    CommLink._snapshotCache = CommLink._snapshotCache or {}
    CommLink._snapshotCache[charKey] = snapshot

    -- Mark dirty — the background flush timer will pack to DB later
    CommLink._dirtySnapshots = CommLink._dirtySnapshots or {}
    CommLink._dirtySnapshots[charKey] = true

    if not CommLink._flushTimer then
        CommLink._flushTimer = C_Timer.After(10, function()
            CommLink._flushTimer = nil
            CommLink:FlushDirtySnapshots()
        end)
    end

    -- Notify registered modules so they can refresh (e.g. tooltip cache)
    for _, handlers in pairs(moduleHandlers) do
        if handlers.OnSyncedSnapshot then
            pcall(handlers.OnSyncedSnapshot, charKey, snapshot)
        end
    end
end

--- Pack all dirty snapshots to the SavedVariable DB.
--- Called on a deferred timer and at PLAYER_LOGOUT.
function CommLink:FlushDirtySnapshots()
    local dirty = CommLink._dirtySnapshots
    if not dirty then return end

    local cache = CommLink._snapshotCache or {}
    for charKey in pairs(dirty) do
        local snap = cache[charKey]
        if snap then
            local packed, err = Serializer:Pack(snap)
            if packed and coreDB then
                coreDB.syncedSnapshots[charKey] = packed
            else
                if coreDB then
                    coreDB.syncedSnapshots[charKey] = snap
                end
                logger:commlink("CommLink: pack snapshot failed '%s': %s", charKey, err or "?")
            end
        end
    end

    CommLink._dirtySnapshots = nil
end

--- Retrieve a synced remote character's snapshot (decompressed, cached).
---@param charKey string
---@return PFCharacterSnapshot|nil
function Core:GetSyncedSnapshot(charKey)
    local cache = CommLink._snapshotCache or {}
    if cache[charKey] then return cache[charKey] end
    if not self.DB or not self.DB.syncedSnapshots then return nil end
    local raw = self.DB.syncedSnapshots[charKey]
    if not raw then return nil end

    if Serializer:IsPacked(raw) then
        local data, err = Serializer:Unpack(raw)
        if not data then
            logger:commlink("CommLink: unpack synced snapshot failed '%s': %s", charKey, err or "?")
            return nil
        end
        CommLink._snapshotCache = CommLink._snapshotCache or {}
        CommLink._snapshotCache[charKey] = data
        return data
    end

    -- Raw table
    CommLink._snapshotCache = CommLink._snapshotCache or {}
    CommLink._snapshotCache[charKey] = raw
    return raw
end

--- Return all charKeys that have synced snapshots.
---@return string[]
function Core:GetAllSyncedCharKeys()
    local seen = {}
    local keys = {}
    -- Include keys from the persisted DB
    if self.DB and self.DB.syncedSnapshots then
        for k in pairs(self.DB.syncedSnapshots) do
            if not seen[k] then
                seen[k] = true
                keys[#keys + 1] = k
            end
        end
    end
    -- Include keys from the in-memory cache (newly received snapshots
    -- that haven't been flushed to the DB yet)
    if CommLink._snapshotCache then
        for k in pairs(CommLink._snapshotCache) do
            if not seen[k] then
                seen[k] = true
                keys[#keys + 1] = k
            end
        end
    end
    return keys
end

--- Remove a synced snapshot.
---@param charKey string
function Core:RemoveSyncedSnapshot(charKey)
    if CommLink._snapshotCache then
        CommLink._snapshotCache[charKey] = nil
    end
    if self.DB and self.DB.syncedSnapshots then
        self.DB.syncedSnapshots[charKey] = nil
    end
end

-- ============================================================================
-- Initialization
-- ============================================================================

--- Called once after the database is ready (from Closer.lua / entry point).
function CommLink:Initialize()
    if _initialized then return end
    _initialized = true

    -- Resolve the DB upvalue now that InitializeDatabase has run
    coreDB = Core.DB

    -- Register addon message prefix
    C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)

    -- Load persisted sync accounts (new schema); fall back to legacy syncGroups/syncTargets
    if coreDB and coreDB.shared then
        local dbAccounts = coreDB.shared.syncAccounts or coreDB.shared.syncGroups
        if dbAccounts and next(dbAccounts) then
            for accountName, gData in pairs(dbAccounts) do
                local targets = {}
                if gData.targets then
                    for _, raw in ipairs(gData.targets) do
                        local ck = ResolveCharKey(raw)
                        if ck ~= "" then targets[ck] = true end
                    end
                end
                syncGroups[accountName] = {
                    targets        = targets,
                    syncWholeDB    = gData.syncWholeDB or false,
                    remoteWholeDB  = gData.remoteWholeDB or false,
                }
            end
        elseif coreDB.shared.syncTargets then
            -- Legacy: flat syncTargets list → migrate into "Default" account
            local targets = {}
            for _, raw in ipairs(coreDB.shared.syncTargets) do
                local ck = ResolveCharKey(raw)
                if ck ~= "" then targets[ck] = true end
            end
            if next(targets) then
                syncGroups["Default"] = {
                    targets     = targets,
                    syncWholeDB = false,
                }
            end
        end
        RebuildSyncTargets()
    end

    -- Ensure syncedSnapshots and syncMeta tables exist
    if coreDB then
        coreDB.syncedSnapshots = coreDB.syncedSnapshots or {}
        coreDB.syncMeta        = coreDB.syncMeta or {}
    end

    -- Ensure pending requests and blocked users tables exist
    if coreDB and coreDB.shared then
        coreDB.shared.pendingRequests    = coreDB.shared.pendingRequests or {}
        coreDB.shared.pendingWDBRequests = coreDB.shared.pendingWDBRequests or {}
        coreDB.shared.blockedUsers       = coreDB.shared.blockedUsers or {}
    end

    -- Listen for addon messages
    Core:RegisterEvent("_CommLink", "CHAT_MSG_ADDON", OnAddonMessage)

    -- Delayed first ping + recurring timers + auto-expand
    C_Timer.After(5, function()
        -- Auto-expand whole-account sync with all local chars
        AutoExpandWholeAccountSync()

        PingAllTargets()

        C_Timer.NewTicker(PING_INTERVAL, function()
            PingAllTargets()
        end)

        C_Timer.NewTicker(STALE_TIMEOUT / 3, function()
            CheckStalePeers()
        end)
    end)

    local n = 0
    for _ in pairs(syncTargets) do n = n + 1 end
    local nAccounts = 0
    for _ in pairs(syncGroups) do nAccounts = nAccounts + 1 end
    logger:commlink("CommLink: initialized (%d targets in %d accounts)", n, nAccounts)
end
