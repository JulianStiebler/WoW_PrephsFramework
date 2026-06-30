local ModuleID = "Media"
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")

local MediaType_BACKGROUND = LSM.MediaType.BACKGROUND
local MediaType_BORDER = LSM.MediaType.BORDER
local MediaType_STATUSBAR = LSM.MediaType.STATUSBAR 
local MediaType_SOUND = LSM.MediaType.SOUND
local MediaType_TEXTURE = LSM.MediaType.STATUSBAR

-- ============================================================================
-- BACKGROUNDS
-- ============================================================================
local function RegisterBackgrounds()
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edMoo",                            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\moo.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edBricks",                         [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\bricks.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edBrushed Metal",                  [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\brushedmetal.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edCopper",                         [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\copper.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edSmoke",                          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\smoke.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edGlow",                           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\Glow.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edArrow",                          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\Arrow.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edArrow Left",                     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\ArrowLeft.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edArrow Right",                    [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\ArrowRight.tga]])
    LSM:Register(MediaType_BACKGROUND,  "|cff0091edArrow Glow",                     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\background\arrow_glow.tga]])
end

-- ============================================================================
-- BORDERS
-- ============================================================================
local function RegisterBorders()
    LSM:Register(MediaType_BORDER,      "|cff0091edRothSquare",                     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\border\roth.tga]])
    LSM:Register(MediaType_BORDER,      "|cff0091edSeerahScalloped",                [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\border\SeerahScalloped.blp]])
    LSM:Register(MediaType_BORDER,      "|cff0091edBorder1",                        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\border\border1.tga]])
    LSM:Register(MediaType_BORDER,      "|cff0091edBorder2",                        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\border\border2.tga]])
    LSM:Register(MediaType_BORDER,      "|cff0091edBorder3",                        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\border\border3.tga]])
end

-- ============================================================================
-- STATUS BARS
-- ============================================================================
local function RegisterStatusBars()
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edAluminium",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Aluminium]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edArmory",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Armory]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edBantoBar",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\BantoBar]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edBars",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Bars]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edBumps",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Bumps]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edButton",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Button]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edCharcoal",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Charcoal]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edCilo",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Cilo]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edCloud",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Cloud]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edComet",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Comet]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edDabs",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Dabs]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edDarkBottom",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\DarkBottom]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edDiagonal",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Diagonal]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edEmpty",			                [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Empty]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edFalumn",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Falumn]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edFifths",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Fifths]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edFlat",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Flat]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edFourths",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Fourths]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edFrost",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Frost]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlamour",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glamour]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlamour2",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glamour2]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlamour3",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glamour3]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlamour4",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glamour4]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlamour5",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glamour5]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlamour6",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glamour6]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlamour7",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glamour7]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlass",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glass]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlaze",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glaze]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGlaze v2",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Glaze2]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGloss",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Gloss]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGraphite",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Graphite]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edGrid",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Grid]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edHatched",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Hatched]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edHealbot",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Healbot]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edLyfe",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Lyfe]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edLiteStep",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\LiteStep]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edLiteStepLite",		            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\LiteStepLite]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edMelli",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Melli]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edMelli Dark",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\MelliDark]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edMelli Dark Rough",	            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\MelliDarkRough]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edMinimalist",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Minimalist]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edOtravi",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Otravi]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edOutline",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Outline]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edPerl",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Perl]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edPerl v2",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Perl2]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edPill",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Pill]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edRain",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Rain]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edRocks",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Rocks]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edRound",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Round]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edRuben",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Ruben]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edRunes",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Runes]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edSkewed",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Skewed]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edSmooth",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Smooth]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edSmooth v2",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Smoothv2]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edSmudge",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Smudge]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edSteel",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Steel]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edStriped",			            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Striped]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edTube",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Tube]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edWater",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Water]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edWglass",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Wglass]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edWisps",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Wisps]])
    LSM:Register(MediaType_STATUSBAR,   "|cff0091edXeon",				            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\statusbar\Xeon]])
end

-- ============================================================================
-- SPELL PROC TEXTURES (SAO)
-- ============================================================================
local function RegisterSpellProcs()
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Arcane Missiles",          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\arcane_missiles]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Arcane Missiles 1",        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\arcane_missiles_1]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Arcane Missiles 2",        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\arcane_missiles_2]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Arcane Missiles 3",        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\arcane_missiles_3]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Art Of War",               [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\art_of_war]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Backlash",                 [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\backlash]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Backlash Green",           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\backlash_green]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Bandits Guile",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\bandits_guile]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Berserk",                  [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\berserk]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Blood Boil",               [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\blood_boil]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Blood Surge",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\blood_surge]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Brain Freeze",             [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\brain_freeze]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Dark Tiger",               [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\dark_tiger]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Dark Transformation",      [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\dark_transformation]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Daybreak",                 [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\daybreak]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Demonic Core",             [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\demonic_core]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Demonic Core Vertical",    [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\demonic_core_vertical]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Denounce",                 [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\denounce]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Echo Of The Elements",     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\echo_of_the_elements]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Eclipse Moon",             [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\eclipse_moon]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Eclipse Sun",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\eclipse_sun]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Feral Omenofclarity",      [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\feral_omenofclarity]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Focus Fire",               [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\focus_fire]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Frozen Fingers",           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\frozen_fingers]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Fulmination",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\fulmination]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Fury Of Stormrage",        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\fury_of_stormrage]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Genericarc 01",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\genericarc_01]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Genericarc 02",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\genericarc_02]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Genericarc 03",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\genericarc_03]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Genericarc 04",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\genericarc_04]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Genericarc 05",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\genericarc_05]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Genericarc 06",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\genericarc_06]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Generictop 01",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\generictop_01]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Generictop 02",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\generictop_02]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Grand Crusader",           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\grand_crusader]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Hand Of Light",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\hand_of_light]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - High Tide",                [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\high_tide]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Hot Streak",               [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\hot_streak]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Impact",                   [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\impact]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Imp Empowerment",          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\imp_empowerment]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Imp Empowerment Green",    [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\imp_empowerment_green]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Killing Machine",          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\killing_machine]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Lock And Load",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\lock_and_load]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Maelstrom Weapon",         [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\maelstrom_weapon]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Maelstrom Weapon 1",       [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\maelstrom_weapon_1]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Maelstrom Weapon 2",       [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\maelstrom_weapon_2]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Maelstrom Weapon 3",       [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\maelstrom_weapon_3]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Maelstrom Weapon 4",       [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\maelstrom_weapon_4]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Master Marksman",          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\master_marksman]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Molten Core",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\molten_core]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Molten Core Green",        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\molten_core_green]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Monk Blackoutkick",        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\monk_blackoutkick]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Monk Ox",                  [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\monk_ox]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Monk Ox 2",                [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\monk_ox_2]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Monk Ox 3",                [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\monk_ox_3]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Monk Serpent",             [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\monk_serpent]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Monk Tiger",               [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\monk_tiger]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Monk Tigerpalm",           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\monk_tigerpalm]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Natures Grace",            [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\natures_grace]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Necropolis",               [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\necropolis]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Nightfall",                [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\nightfall]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Predatory Swiftness",      [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\predatory_swiftness]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Predatory Swiftness Green",[[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\predatory_swiftness_green]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Raging Blow",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\raging_blow]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Rime",                     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\rime]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Serendipity",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\serendipity]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Shadow Of Death",          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\shadow_of_death]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Shadow Word Insanity",     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\shadow_word_insanity]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Shooting Stars",           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\shooting_stars]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Slice And Dice",           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\slice_and_dice]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Spellactivationoverlay 0", [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\spellactivationoverlay_0]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Sudden Death",             [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\sudden_death]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Sudden Doom",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\sudden_doom]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Surge Of Darkness",        [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\surge_of_darkness]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Surge Of Light",           [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\surge_of_light]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Sword And Board",          [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\sword_and_board]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Thrill Of The Hunt 1",     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\thrill_of_the_hunt_1]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Thrill Of The Hunt 2",     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\thrill_of_the_hunt_2]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Thrill Of The Hunt 3",     [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\thrill_of_the_hunt_3]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - Ultimatum",                [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\ultimatum]])
    LSM:Register(MediaType_TEXTURE,     "|cff0091edSAO - White Tiger",              [[Interface\AddOns\PrephsFramework_Media\media\LSM_registered\textures\retail_sao\white_tiger]])
end


-- ============================================================================
-- SOUNDS
-- ============================================================================
local function RegisterSounds()
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 1",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 1.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 2",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 2.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 3",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 3.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 4",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 4.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 5",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 5.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 6",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 6.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 7",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 7.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 8",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 8.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 9",                     [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 9.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - 10",                    [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - 10.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Add",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Add.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Adds",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Adds.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - AoE",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - AoE.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Avoid",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Avoid.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Bait",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Bait.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Behind",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Behind.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Bloodlust",             [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Bloodlust.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Buff",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Buff.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - CC",                    [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - CC.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Clear In",              [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Clear In.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Clear",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Clear.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Collect",               [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Collect.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Combat",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Combat.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Dance",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Dance.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Debuff",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Debuff.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Dispell",               [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Dispell.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Dodge Inc",             [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Dodge Inc.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Dodge",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Dodge.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Dot",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Dot.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Fixate",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Fixate.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Frontal",               [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Frontal.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Hide",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Hide.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - High Stacks",           [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - High Stacks.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Immune",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Immune.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - In",                    [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - In.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Inc",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Inc.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Inside",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Inside.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Intermission",          [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Intermission.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Kick",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Kick.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Knock",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Knock.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Left",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Left.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Linked",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Linked.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - LoS",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - LoS.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Melee",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Melee.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Move",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Move.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Next",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Next.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Nuke",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Nuke.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Orb",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Orb.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Out",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Out.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Personal",              [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Personal.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Pot",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Pot.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Pull",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Pull.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Push",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Push.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Ranged",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Ranged.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Ready",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Ready.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Reflect",               [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Reflect.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Right",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Right.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Run",                   [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Run.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Shield",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Shield.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Soak",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Soak.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Spread",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Spread.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Stack",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Stack.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Stop",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Stop.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Stopcast",              [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Stopcast.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Switch",                [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Switch.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Taunt",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Taunt.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Totem",                 [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Totem.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Trap",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Trap.ogg]])
    LSM:Register(MediaType_SOUND,       "|cff0091edFemale - Turn",                  [[Interface\Addons\PrephsFramework_Media\media\LSM_registered\sounds\Female - Turn.ogg]])
end

-- ============================================================================
-- FEATURE REGISTRATION HANDLERS
-- ============================================================================

local function InitBackgrounds(featureId, moduleDB)
    RegisterBackgrounds()
    PrephsFramework_Core.Logger:Info("Media", "Backgrounds registered (10 textures)")
end

local function InitBorders(featureId, moduleDB)
    RegisterBorders()
    PrephsFramework_Core.Logger:Info("Media", "Borders registered (5 textures)")
end

local function InitStatusBars(featureId, moduleDB)
    RegisterStatusBars()
    PrephsFramework_Core.Logger:Info("Media", "StatusBars registered (60 textures)")
end

local function InitSpellProcs(featureId, moduleDB)
    RegisterSpellProcs()
    PrephsFramework_Core.Logger:Info("Media", "Spell Proc Overlays registered (85 textures)")
end

local function InitSounds(featureId, moduleDB)
    RegisterSounds()
    PrephsFramework_Core.Logger:Info("Media", "Sounds registered (70 sounds)")
end

-- ============================================================================
-- MODULE CONFIGURATION
-- ============================================================================
local ModuleConfig = {
    folder = "PrephsFramework_Media",
    title = "Media Assets",
    alwaysLoad = true,  -- Load immediately for LibSharedMedia registration
    features = {
        ["Backgrounds"] = {
            name = "Background Textures",
            description = "Register background textures for UI elements. Includes arrows, glows, and decorative backgrounds.",
            priority = 100,
            defaultEnabled = false,
            uiGroup = "Texture Assets",
            init = InitBackgrounds,
            uiElements = {
                {
                    type = "Checkbox",
                    key = "Backgrounds_enabled",
                    label = "Enable Background Textures (10 textures)",
                    default = true
                }
            }
        },
        ["Borders"] = {
            name = "Border Textures",
            description = "Register border textures for frames and UI panels.",
            defaultEnabled = false,
            priority = 95,
            uiGroup = "Texture Assets",
            init = InitBorders,
            uiElements = {
                {
                    type = "Checkbox",
                    key = "Borders_enabled",
                    label = "Enable Border Textures (5 styles)",
                    default = true
                }
            }
        },
        ["StatusBars"] = {
            name = "StatusBar Textures",
            description = "Register statusbar textures for health/mana bars and progress indicators.",
            defaultEnabled = true,
            priority = 90,
            uiGroup = "Texture Assets",
            init = InitStatusBars,
            uiElements = {
                {
                    type = "Checkbox",
                    key = "StatusBars_enabled",
                    label = "Enable StatusBar Textures (60 styles)",
                    default = true
                }
            }
        },
        ["SpellProcs"] = {
            name = "Spell Proc Overlays",
            description = "Register SAO (SpellActivationOverlay) textures for proc indicators.",
            defaultEnabled = false,
            priority = 85,
            uiGroup = "Texture Assets",
            init = InitSpellProcs,
            uiElements = {
                {
                    type = "Checkbox",
                    key = "SpellProcs_enabled",
                    label = "Enable Spell Proc Overlays (85 textures)",
                    default = true
                }
            }
        },
        ["Sounds"] = {
            name = "Sound Effects",
            description = "Register sound files for notifications and alerts.",
            defaultEnabled = true,
            priority = 75,
            uiGroup = "Audio Assets",
            init = InitSounds,
            uiElements = {
                {
                    type = "Checkbox",
                    key = "Sounds_enabled",
                    label = "Enable Sound Effects (70 voice notifications)",
                    default = true
                }
            }
        }
    }
}

PrephsFramework_Core:RegisterModule(ModuleID, ModuleConfig)
    
-- Register media assets for enabled features
local db = PrephsFramework_Core:GetModuleDatabase(ModuleID)
for featureName, featureCfg in pairs(ModuleConfig.features) do
    if db and db[featureName .. "_enabled"] and featureCfg.init then
        PrephsFramework_Core.Logger:Info("Media", "Registering %s assets", featureName)
        featureCfg.init(featureName, db)
    end
end

PrephsFramework_Core.Logger:Info("Media", "Module initialized successfully!")
