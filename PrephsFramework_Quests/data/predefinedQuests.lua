---@meta _
-- Namespace for sharing data across addon files
local addonName, ns = ...

if not ns.data then
    ns.data = {}
end

---@class PrephsFramework.AutoQuest.PredefinedType
local PredefinedTypes = {
    AQWarEffort       = 1,
    AQCommendations   = 2,
    GnomereganSalvage = 3,
    ReputationTurnins = 4,
}

ns.data.PredefinedAutoTurnins = {
    Types = PredefinedTypes,

    [PredefinedTypes.AQWarEffort] = {
        label = "AQ War Effort (Alliance)",
        key = "AQWarEffortQuests",
        collapsible = true,
        children = {
            { label = "Copper Bar",           key = "CopperBar",          quests = {8492, 8493} },
            { label = "Iron Bar",             key = "IronBar",            quests = {8494, 8495} },
            { label = "Thorium Bar",          key = "ThoriumBar",         quests = {8499, 8500} },
            { label = "Stranglekelp",         key = "Stranglekelp",       quests = {8503, 8504} },
            { label = "Purple Lotus",         key = "PurpleLotus",        quests = {8505, 8506} },
            { label = "Arthas' Tears",        key = "ArthasTears",        quests = {8509, 8510} },
            { label = "Light Leather",        key = "LightLeather",       quests = {8511, 8512} },
            { label = "Medium Leather",       key = "MediumLeather",      quests = {8513, 8514} },
            { label = "Thick Leather",        key = "ThickLeather",       quests = {8515, 8516} },
            { label = "Linen Bandage",        key = "LinenBandage",       quests = {8517, 8518} },
            { label = "Silk Bandage",         key = "SilkBandage",        quests = {8520, 8521} },
            { label = "Runecloth Bandage",    key = "RuneclothBandage",   quests = {8522, 8523} },
            { label = "Roast Raptor",         key = "RoastRaptor",        quests = {8526, 8527} },
            { label = "Rainbow Fin Albacore", key = "RainbowFinAlbacore", quests = {8524, 8525} },
            { label = "Spotted Yellowtail",   key = "SpottedYellowtail",  quests = {8528, 8529} },
        },
    },

    [PredefinedTypes.AQCommendations] = {
        label = "Commendation Signet Turn-ins",
        key = "CommendationQuests",
        collapsible = true,
        showSeparator = true,
        children = {
            { label = "Gnomeregan - One",           key = "Gnomeregan_one",          quests = {8812, 8838} },
            { label = "Gnomeregan - Bulk",          key = "Gnomeregan_ten",          quests = {8839, 8820} },
            { label = "Stormwind - One",            key = "Stormwind_one",           quests = {8836, 8814} },
            { label = "Stormwind - Ten",            key = "Stormwind_ten",           quests = {8837, 8822} },
            { label = "Darnassus - One",            key = "Darnassus_one",           quests = {8811, 8830} },
            { label = "Darnassus - Ten",            key = "Darnassus_ten",           quests = {8819, 8831} },
            { label = "Ironforge - One",            key = "Ironforge_one",           quests = {8813, 8834} },
            { label = "Ironforge - Ten",            key = "Ironforge_ten",           quests = {8821, 8835} },
            { label = "Steamwheedle - One",         key = "SteamwheedleCartel_one",  quests = {85979} },
            { label = "Steamwheedle - Ten",         key = "SteamwheedleCartel_ten",  quests = {85982} },
            { label = "Argent Dawn - One",          key = "ArgentDawn_one",          quests = {85963} },
            { label = "Argent Dawn - Ten",          key = "ArgentDawn_ten",          quests = {85964} },
            { label = "Cenarion Circle - One",      key = "CenarionCircle_one",      quests = {85970} },
            { label = "Cenarion Circle - Ten",      key = "CenarionCircle_ten",      quests = {85969} },
            { label = "Zandalar Tribe - One",       key = "ZandalerTribe_one",       quests = {85983} },
            { label = "Zandalar Tribe - Ten",       key = "ZandalerTribe_ten",       quests = {85985} },
            { label = "Timbermaw Hold - One",       key = "TimbermawHold_one",       quests = {85987} },
            { label = "Timbermaw Hold - Ten",       key = "TimbermawHold_ten",       quests = {86160} },
            { label = "Hydraxian Waterlords - One", key = "HydraxianWaterlords_one", quests = {85971} },
            { label = "Hydraxian Waterlords - Ten", key = "HydraxianWaterlords_ten", quests = {85973} },
            { label = "Thorium Brotherhood - One",  key = "ThoriumBrotherhood_one",  quests = {85975} },
            { label = "Thorium Brotherhood - Ten",  key = "ThoriumBrotherhood_ten",  quests = {85976} },
        },
    },

    [PredefinedTypes.GnomereganSalvage] = {
        label = "Gnomeregan Salvage",
        key = "GnomereganSalvage",
        collapsible = true,
        children = {
            { label = "Sparklematic Action", key = "Sparklematic", quests = {2953, 4603, 4604, 80155, 80160} },
            { label = "Salvagematic 9000",   key = "Salvagematic", quests = {79626, 79704} },
        },
    },

    [PredefinedTypes.ReputationTurnins] = {
        label = "Reputation Turn-ins",
        key = "ReputationTurnins",
        collapsible = true,
        children = {
            { label = "Mortal Champions", key = "MortalChampions", quests = {8595} },
        },
    },
}
