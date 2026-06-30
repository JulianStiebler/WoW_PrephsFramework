-- https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT
-- https://wowpedia.fandom.com/wiki/COMBAT_LOG_EVENT_UNFILTERED

---@meta _

-- ============================================================================
-- Subevent Alias
-- ============================================================================

---@alias CombatLogSubevent
---| "ENVIRONMENTAL_DAMAGE"
---| "RANGE_DAMAGE"
---| "RANGE_MISSED"
---| "SPELL_ABSORBED"
---| "SPELL_AURA_APPLIED"
---| "SPELL_AURA_APPLIED_DOSE"
---| "SPELL_AURA_BROKEN"
---| "SPELL_AURA_BROKEN_SPELL"
---| "SPELL_AURA_REFRESH"
---| "SPELL_AURA_REMOVED"
---| "SPELL_AURA_REMOVED_DOSE"
---| "SPELL_CAST_FAILED"
---| "SPELL_CAST_START"
---| "SPELL_CAST_SUCCESS"
---| "SPELL_CREATE"
---| "SPELL_DAMAGE"
---| "SPELL_DRAIN"
---| "SPELL_DURABILITY_DAMAGE"
---| "SPELL_DURABILITY_DAMAGE_ALL"
---| "SPELL_EMPOWER_INTERRUPT"
---| "SPELL_EMPOWER_START"
---| "SPELL_EMPOWER_END"
---| "SPELL_ENERGIZE"
---| "SPELL_EXTRA_ATTACKS"
---| "SPELL_HEAL"
---| "SPELL_HEAL_ABSORBED"
---| "SPELL_INSTAKILL"
---| "SPELL_INTERRUPT"
---| "SPELL_LEECH"
---| "SPELL_MISSED"
---| "SPELL_PERIODIC_DAMAGE"
---| "SPELL_PERIODIC_DRAIN"
---| "SPELL_PERIODIC_ENERGIZE"
---| "SPELL_PERIODIC_HEAL"
---| "SPELL_PERIODIC_LEECH"
---| "SPELL_PERIODIC_MISSED"
---| "SPELL_RESURRECT"
---| "SPELL_SHIELD"
---| "SPELL_STOLEN"
---| "SPELL_SUMMON"
---| "SWING_DAMAGE"
---| "SWING_DAMAGE_LANDED"
---| "SWING_MISSED"
---| "UNIT_DIED"
---| "UNIT_DESTROYED"
---| "UNIT_DISSIPATES"
---| "UNIT_SPELLCAST_INTERRUPTED"
---| "UNIT_SPELLCAST_START"
---| "UNIT_SPELLCAST_SUCCEEDED"
---| "PARTY_KILL"
---| "ENCHANT_APPLIED"
---| "ENCHANT_REMOVED"

-- ============================================================================
-- Shared Base Params (positions 1-11, always present)
-- ============================================================================

---@class CLEU_BaseParams
---@field timestamp number
---@field subevent CombatLogSubevent
---@field hideCaster boolean
---@field sourceGUID string
---@field sourceName string?
---@field sourceFlags number
---@field sourceRaidFlags number
---@field destGUID string
---@field destName string?
---@field destFlags number
---@field destRaidFlags number

-- ============================================================================
-- Prefix Param Groups (positions 12+, depending on subevent prefix)
-- ============================================================================

--- SPELL / SPELL_PERIODIC prefix (spellId, spellName, spellSchool)
---@class CLEU_SpellPrefix
---@field spellId number
---@field spellName string
---@field spellSchool number

--- RANGE prefix — same shape as SPELL
---@class CLEU_RangePrefix : CLEU_SpellPrefix

--- ENVIRONMENTAL prefix
---@class CLEU_EnvironmentalPrefix
---@field environmentalType string "Falling"|"Drowning"|"Fatigue"|"Fire"|"Lava"|"Slime"

-- ============================================================================
-- Suffix Param Groups
-- ============================================================================

--- _DAMAGE suffix
---@class CLEU_DamageSuffix
---@field amount number
---@field overkill number -1 if not an overkill
---@field school number
---@field resisted number?
---@field blocked number?
---@field absorbed number?
---@field critical boolean?
---@field glancing boolean?
---@field crushing boolean?
---@field isOffHand boolean?

--- _MISSED suffix
---@class CLEU_MissedSuffix
---@field missType string "ABSORB"|"BLOCK"|"DEFLECT"|"DODGE"|"EVADE"|"IMMUNE"|"MISS"|"PARRY"|"REFLECT"|"RESIST"
---@field isOffHand boolean?
---@field amountMissed number?
---@field critical boolean?

--- _HEAL suffix
---@class CLEU_HealSuffix
---@field amount number
---@field overhealing number
---@field absorbed number
---@field critical boolean?

--- _HEAL_ABSORBED suffix
---@class CLEU_HealAbsorbedSuffix
---@field extraGUID string
---@field extraName string?
---@field extraFlags number
---@field extraRaidFlags number
---@field extraSpellId number
---@field extraSpellName string
---@field extraSpellSchool number
---@field absorbedAmount number

--- _ENERGIZE suffix
---@class CLEU_EnergizeSuffix
---@field amount number
---@field overEnergize number
---@field powerType number
---@field alternatePowerType number?

--- _DRAIN / _LEECH suffix
---@class CLEU_DrainLeechSuffix
---@field amount number
---@field powerType number
---@field extraAmount number

--- _INTERRUPT / _STOLEN / _DISPEL / _DISPEL_FAILED suffix
---@class CLEU_SpellExtraSuffix
---@field extraSpellId number
---@field extraSpellName string
---@field extraSpellSchool number

--- _AURA_APPLIED / _AURA_REMOVED / _AURA_REFRESH suffix
---@class CLEU_AuraSuffix
---@field auraType string "BUFF"|"DEBUFF"

--- _AURA_APPLIED_DOSE / _AURA_REMOVED_DOSE suffix
---@class CLEU_AuraDoseSuffix : CLEU_AuraSuffix
---@field amount number

--- _AURA_BROKEN suffix
---@class CLEU_AuraBrokenSuffix : CLEU_AuraSuffix

--- _AURA_BROKEN_SPELL suffix
---@class CLEU_AuraBrokenSpellSuffix : CLEU_AuraSuffix
---@field extraSpellId number
---@field extraSpellName string
---@field extraSpellSchool number

--- _CAST_FAILED suffix
---@class CLEU_CastFailedSuffix
---@field failedType string

--- _ABSORBED suffix
---@class CLEU_AbsorbedSuffix
---@field casterGUID string
---@field casterName string?
---@field casterFlags number
---@field casterRaidFlags number
---@field absorbSpellId number
---@field absorbSpellName string
---@field absorbSpellSchool number
---@field amount number
---@field critical boolean?

--- _EXTRA_ATTACKS suffix
---@class CLEU_ExtraAttacksSuffix
---@field amount number

--- ENCHANT_APPLIED / ENCHANT_REMOVED (no spell prefix, uses item info instead)
---@class CLEU_EnchantSuffix
---@field spellName string
---@field itemId number
---@field itemName string

--- UNIT_DIED / UNIT_DESTROYED / UNIT_DISSIPATES / PARTY_KILL
---@class CLEU_UnitSuffix
---@field recapId number?
---@field unconsciousOnDeath boolean?

-- ============================================================================
-- Full per-subevent payload classes (base + prefix + suffix combined)
-- ============================================================================

---@class CLEU_SwingDamage        : CLEU_BaseParams, CLEU_DamageSuffix
---@class CLEU_SwingDamageLanded  : CLEU_BaseParams, CLEU_DamageSuffix
---@class CLEU_SwingMissed        : CLEU_BaseParams, CLEU_MissedSuffix

---@class CLEU_RangeDamage        : CLEU_BaseParams, CLEU_RangePrefix, CLEU_DamageSuffix
---@class CLEU_RangeMissed        : CLEU_BaseParams, CLEU_RangePrefix, CLEU_MissedSuffix

---@class CLEU_SpellDamage          : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_DamageSuffix
---@class CLEU_SpellMissed          : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_MissedSuffix
---@class CLEU_SpellHeal            : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_HealSuffix
---@class CLEU_SpellHealAbsorbed    : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_HealAbsorbedSuffix
---@class CLEU_SpellAbsorbed        : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AbsorbedSuffix
---@class CLEU_SpellEnergize        : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_EnergizeSuffix
---@class CLEU_SpellDrain           : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_DrainLeechSuffix
---@class CLEU_SpellLeech           : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_DrainLeechSuffix
---@class CLEU_SpellExtraAttacks    : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_ExtraAttacksSuffix
---@class CLEU_SpellInterrupt       : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_SpellExtraSuffix
---@class CLEU_SpellStolen          : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_SpellExtraSuffix
---@class CLEU_SpellAuraApplied     : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AuraSuffix
---@class CLEU_SpellAuraRemoved     : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AuraSuffix
---@class CLEU_SpellAuraRefresh     : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AuraSuffix
---@class CLEU_SpellAuraAppliedDose : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AuraDoseSuffix
---@class CLEU_SpellAuraRemovedDose : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AuraDoseSuffix
---@class CLEU_SpellAuraBroken      : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AuraBrokenSuffix
---@class CLEU_SpellAuraBrokenSpell : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_AuraBrokenSpellSuffix
---@class CLEU_SpellCastStart       : CLEU_BaseParams, CLEU_SpellPrefix
---@class CLEU_SpellCastSuccess     : CLEU_BaseParams, CLEU_SpellPrefix
---@class CLEU_SpellCastFailed      : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_CastFailedSuffix
---@class CLEU_SpellInstakill       : CLEU_BaseParams, CLEU_SpellPrefix
---@class CLEU_SpellDurabilityDamage   : CLEU_BaseParams, CLEU_SpellPrefix
---@class CLEU_SpellDurabilityDamageAll: CLEU_BaseParams, CLEU_SpellPrefix
---@class CLEU_SpellCreate          : CLEU_BaseParams, CLEU_SpellPrefix
---@class CLEU_SpellSummon          : CLEU_BaseParams, CLEU_SpellPrefix
---@class CLEU_SpellResurrect       : CLEU_BaseParams, CLEU_SpellPrefix

---@class CLEU_SpellPeriodicDamage   : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_DamageSuffix
---@class CLEU_SpellPeriodicMissed   : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_MissedSuffix
---@class CLEU_SpellPeriodicHeal     : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_HealSuffix
---@class CLEU_SpellPeriodicEnergize : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_EnergizeSuffix
---@class CLEU_SpellPeriodicDrain    : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_DrainLeechSuffix
---@class CLEU_SpellPeriodicLeech    : CLEU_BaseParams, CLEU_SpellPrefix, CLEU_DrainLeechSuffix

---@class CLEU_EnvironmentalDamage   : CLEU_BaseParams, CLEU_EnvironmentalPrefix, CLEU_DamageSuffix

---@class CLEU_EnchantApplied : CLEU_BaseParams, CLEU_EnchantSuffix
---@class CLEU_EnchantRemoved : CLEU_BaseParams, CLEU_EnchantSuffix

---@class CLEU_UnitDied       : CLEU_BaseParams, CLEU_UnitSuffix
---@class CLEU_UnitDestroyed  : CLEU_BaseParams, CLEU_UnitSuffix
---@class CLEU_UnitDissipates : CLEU_BaseParams, CLEU_UnitSuffix
---@class CLEU_PartyKill      : CLEU_BaseParams, CLEU_UnitSuffix

-- ============================================================================
-- CombatLogGetCurrentEventInfo
-- ============================================================================

--- Returns the combat log event info for the current COMBAT_LOG_EVENT_UNFILTERED event.
--- Must be called from within a COMBAT_LOG_EVENT_UNFILTERED handler.
--- Positions 12+ vary by subevent — cast with the appropriate CLEU_* class after checking subevent.
---@return number timestamp Unix time of the event
---@return CombatLogSubevent subevent The combat log subevent type
---@return boolean hideCaster Whether the caster is hidden
---@return string sourceGUID GUID of the source unit
---@return string? sourceName Name of the source unit
---@return number sourceFlags Combat log flags of the source unit
---@return number sourceRaidFlags Raid flags of the source unit
---@return string destGUID GUID of the destination unit
---@return string? destName Name of the destination unit
---@return number destFlags Combat log flags of the destination unit
---@return number destRaidFlags Raid flags of the destination unit
---@return any ... Subevent-specific parameters (see CLEU_* classes)
function CombatLogGetCurrentEventInfo() end

