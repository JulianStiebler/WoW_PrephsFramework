---@meta _

-- https://warcraft.wiki.gg/wiki/Special:PrefixIndex/API_C_Engraving

---@class EngravingData
---@field skillLineAbilityID number
---@field itemEnchantmentID number
---@field name string
---@field iconTexture number
---@field equipmentSlot number
---@field level number
---@field learnedAbilitySpellIDs number[]

C_Engraving = {}

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.AddCategoryFilter)
---@param category number
function C_Engraving.AddCategoryFilter(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.AddExclusiveCategoryFilter)
---@param category number
function C_Engraving.AddExclusiveCategoryFilter(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.CastRune)
---@param skillLineAbilityID number
function C_Engraving.CastRune(skillLineAbilityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.ClearAllCategoryFilters)
function C_Engraving.ClearAllCategoryFilters() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.ClearCategoryFilter)
---@param category number
function C_Engraving.ClearCategoryFilter(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.ClearExclusiveCategoryFilter)
function C_Engraving.ClearExclusiveCategoryFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.EnableEquippedFilter)
---@param enabled boolean
function C_Engraving.EnableEquippedFilter(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetCurrentRuneCast)
---@return EngravingData? engravingInfo
function C_Engraving.GetCurrentRuneCast() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetEngravingModeEnabled)
---@return boolean enabled
function C_Engraving.GetEngravingModeEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetExclusiveCategoryFilter)
---@return number? category
function C_Engraving.GetExclusiveCategoryFilter() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetNumRunesKnown)
---@param equipmentSlot? number
---@return number known
---@return number max
function C_Engraving.GetNumRunesKnown(equipmentSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetRuneCategories)
---@param shouldFilter boolean
---@param ownedOnly boolean
---@return number[] categories
function C_Engraving.GetRuneCategories(shouldFilter, ownedOnly) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetRuneForEquipmentSlot)
---@param equipmentSlot number
---@return EngravingData? engravingInfo
function C_Engraving.GetRuneForEquipmentSlot(equipmentSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetRuneForInventorySlot)
---@param containerIndex number
---@param slotIndex number
---@return EngravingData? engravingInfo
function C_Engraving.GetRuneForInventorySlot(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.GetRunesForCategory)
---@param category number
---@param ownedOnly boolean
---@return EngravingData[] engravingInfo
function C_Engraving.GetRunesForCategory(category, ownedOnly) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.HasCategoryFilter)
---@param category number
---@return boolean result
function C_Engraving.HasCategoryFilter(category) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.IsEngravingEnabled)
---@return boolean value
function C_Engraving.IsEngravingEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.IsEquipmentSlotEngravable)
---@param equipmentSlot number
---@return boolean result
function C_Engraving.IsEquipmentSlotEngravable(equipmentSlot) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.IsEquippedFilterEnabled)
---@return boolean enabled
function C_Engraving.IsEquippedFilterEnabled() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.IsInventorySlotEngravable)
---@param containerIndex number
---@param slotIndex number
---@return boolean result
function C_Engraving.IsInventorySlotEngravable(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.IsInventorySlotEngravableByCurrentRuneCast)
---@param containerIndex number
---@param slotIndex number
---@return boolean result
function C_Engraving.IsInventorySlotEngravableByCurrentRuneCast(containerIndex, slotIndex) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.IsKnownRuneSpell)
---@param spellID number
---@return boolean result
function C_Engraving.IsKnownRuneSpell(spellID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.IsRuneEquipped)
---@param skillLineAbilityID number
---@return boolean result
function C_Engraving.IsRuneEquipped(skillLineAbilityID) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.RefreshRunesList)
function C_Engraving.RefreshRunesList() end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.SetEngravingModeEnabled)
---@param enabled boolean
function C_Engraving.SetEngravingModeEnabled(enabled) end

---[Documentation](https://warcraft.wiki.gg/wiki/API_C_Engraving.SetSearchFilter)
---@param filter string
function C_Engraving.SetSearchFilter(filter) end

