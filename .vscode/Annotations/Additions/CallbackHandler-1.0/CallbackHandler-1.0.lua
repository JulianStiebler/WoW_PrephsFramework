---@meta _

-- ----------------------------------------------------------------------------
-- CallbackHandler-1.0
-- ----------------------------------------------------------------------------
---@class CallbackHandler-1.0
local CallbackHandler = {}

---Creates a new CallbackHandler registry and embeds the registration APIs into the target table.
---@param target table The target object to embed RegisterCallback, UnregisterCallback, and UnregisterAllCallbacks into.
---@param RegisterName? string The name of the registration method to embed. Defaults to "RegisterCallback".
---@param UnregisterName? string The name of the unregistration method to embed. Defaults to "UnregisterCallback".
---@param UnregisterAllName? string|false The name of the unregister-all method to embed. Set to false to disable. Defaults to "UnregisterAllCallbacks".
---@return CallbackHandlerRegistry registry The registry object used to fire events.
function CallbackHandler:New(target, RegisterName, UnregisterName, UnregisterAllName) end

-- ----------------------------------------------------------------------------
-- CallbackHandlerRegistry (internal, only has Fire method)
-- ----------------------------------------------------------------------------
---@class CallbackHandlerRegistry
---@field OnUnused? fun(registry: CallbackHandlerRegistry, target: table, eventName: string) Optional. Called when the last listener for an event unregisters.
---@field OnUsed? fun(registry: CallbackHandlerRegistry, target: table, eventName: string) Optional. Called when the first listener for an event registers.
local CallbackHandlerRegistry = {}

---Fires an event into the registry, calling all registered callbacks for the given event name.
---@param eventname string The name of the event to fire.
---@param ... unknown Arguments to pass to each registered callback.
function CallbackHandlerRegistry:Fire(eventname, ...) end

-- ----------------------------------------------------------------------------
-- CallbackHandlerTarget (methods embedded into target by New())
-- ----------------------------------------------------------------------------
---@class CallbackHandlerTarget
local CallbackHandlerTarget = {}

---Registers a callback for the given event. This method is embedded into your target object.
---@param self table|string The object registering the callback (used as the key for unregistering).
---@param eventname string The name of the event to listen for.
---@param method string|function The callback function, or a method name string on `self`.
---@param ... any Optional argument passed as the first parameter to the callback.
function CallbackHandlerTarget:RegisterCallback(self, eventname, method, ...) end

---Unregisters a previously registered callback for the given event.
---@param self table|string The object that registered the callback.
---@param eventname string The name of the event to stop listening for.
function CallbackHandlerTarget:UnregisterCallback(self, eventname) end

---Unregisters all callbacks registered by the given object(s).
---@param ... table|string The object(s) to unregister all callbacks for.
function CallbackHandlerTarget:UnregisterAllCallbacks(...) end