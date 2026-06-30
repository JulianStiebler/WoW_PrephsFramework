---@meta _

--- Returns the number of addons in the addon list.
---@return number count
function GetNumAddOns() end

--- Returns information about an addon.
---@param index number|string Addon index or name
---@return string name The name of the addon folder
---@return string title The title of the addon
---@return string notes The notes/description of the addon
---@return boolean loadable Whether the addon can be loaded
---@return string? reason Why the addon cannot be loaded (MISSING, DISABLED, etc.), nil if loadable
---@return string security INSECURE or SECURE
---@return boolean newVersion Whether a newer version is available
function GetAddOnInfo(index) end

--- Returns metadata from an addon's .toc file.
---@param addonName string The name of the addon folder
---@param field string The metadata field name (e.g. "Version", "X-MyField")
---@return string? value The value of the field, or nil if not found
function GetAddOnMetadata(addonName, field) end

--- Returns whether an addon is LoadOnDemand.
---@param index number|string Addon index or name
---@return boolean loadOnDemand
function IsAddOnLoadOnDemand(index) end

--- Loads a LoadOnDemand addon.
---@param index number|string Addon index or name
---@return boolean loaded Whether the addon was successfully loaded
---@return string? reason Why the addon failed to load, nil if successful
function LoadAddOn(index) end