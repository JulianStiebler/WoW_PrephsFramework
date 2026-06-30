# PrephsFramework-Logger-1.0

A lightweight, high-performance logging utility designed for World of Warcraft addons. Built on the standard `LibStub` system, this library embeds seamlessly into your addon tables to provide a robust, zero-overhead logging solution.

## Key Features

* **Zero-Overhead Toggling:** When a log level is disabled, the logger completely replaces the logging function with a `noop` (no-operation) function. This ensures that leaving debug prints in your production code costs virtually zero CPU cycles during gameplay.
* **Bitmask Filtering:** Easily control which log levels are active using bitwise masks (e.g., Features, Events, Error, Info, Debug, Trace). Combine multiple masks to tailor your console output exactly to your current debugging needs.
* **Safe String Formatting:** Intelligently detects `%` formatters and wraps `string.format` in a protected call (`pcall`). If a formatting error occurs (like a missing argument), it gracefully falls back to string concatenation instead of throwing a hard Lua error that would break your addon.
* **Callback Handler Support:** Automatically fires a `LogMaskChanged` callback when logging levels are updated, allowing your UI or other addon modules to react dynamically.
* **Custom Sub-Loggers:** Spawn child logger instances with unique prefixes using `:CreateLogger("ModuleName")`. These sub-loggers automatically inherit the main logger's enabled bitmasks.

## Usage Example

```lua
-- Embed the logger into your addon table
local MyAddon = {}
LibStub("PrephsFramework-Logger-1.0"):Embed(MyAddon, "MyAddonName")

-- Standard logging (safely handles string.format syntax)
MyAddon:info("Addon loaded successfully!")
MyAddon:error("Failed to load module: %s", "Inventory")

-- Create a sub-logger for a specific module
local DBLogger = MyAddon:CreateLogger("MyAddon_DB")
DBLogger:debug("Database initialized.")

-- Adjust log levels on the fly
MyAddon:EnableLevels(MyAddon.LogLevel.DEBUG.mask)
MyAddon:DisableLevels(MyAddon.LogLevel.TRACE.mask)