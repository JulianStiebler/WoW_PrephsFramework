POI_TYPES = {
    NPC = 1,
    OBJECT = 2,
}

POI_ICONS = {
    ["AMMO"]            = 136451,  -- Interface\Minimap\Tracking\Ammunition
    ["AUCTIONEER"]      = 136452,  -- Interface\Minimap\Tracking\Auctioneer
    ["BANKER"]          = 136453,  -- Interface\Minimap\Tracking\Banker
    ["BATTLEMASTER"]    = 136454,  -- Interface\Minimap\Tracking\Battlemaster
    ["CLASS"]           = 136455,  -- Interface\Minimap\Tracking\Class
    ["FLIGHTMASTER"]    = 136456,  -- Interface\Minimap\Tracking\Flightmaster
    ["FOOD"]            = 136457,  -- Interface\Minimap\Tracking\Food
    ["INNKEEPER"]       = 136458,  -- Interface\Minimap\Tracking\Innkeeper
    ["MAILBOX"]         = 136459,  -- Interface\Minimap\Tracking\Mailbox
    ["POISONS"]         = 136462,  -- Interface\Minimap\Tracking\Poisons
    ["PROFESSION"]      = 136463,  -- Interface\Minimap\Tracking\Profession
    ["REAGENTS"]        = 136464,  -- Interface\Minimap\Tracking\Reagents
    ["REPAIR"]          = 136465,  -- Interface\Minimap\Tracking\Repair
    ["STABLEMASTER"]    = 136466,  -- Interface\Minimap\Tracking\Stablemaster

    ["FOCUS"]           = 524051,  -- Interface\Minimap\Tracking\Focus
    ["TARGET"]          = 524052,  -- Interface\Minimap\Tracking\Target
    ["ARCH_BLOB"]       = 535615,  -- Interface\Minimap\Tracking\ArchBlob
    ["QUEST_BLOB"]      = 535616,  -- Interface\Minimap\Tracking\QuestBlob
    ["PET_BATTLE"]      = 603766,  -- Interface\Minimap\Tracking\WildBattlePet
    ["TRANSMOGRIFIER"]  = 1598183, -- Interface\Minimap\Tracking\Transmogrifier
    ["SPIRITHEALER"]    = "Interface\\AddOns\\PrephsFramework_MapUtility\\data\\textures\\grave",
    ["VENDOR"]          = 132060,  -- Interface\gossipframe\vendorgossipicon,
    ["DUNGEON_ENTRANCE"]= 1502543,  -- Interface\Minimap\Dungeon
    ["RAID_ENTRANCE"]    = 1502548,  -- Interface\Minimap\Raid
}

local POI_DATA = {
    version = 1, -- Increment when POI data changes to invalidate cache
    mMapScale = 1.3, -- Global Minimap fallback
    wMapScale = 0.8, -- Global WorldMap fallback
    POI = {
        -- ====================================================================
        -- ["KEY"] = { 
        --      icon = texturePath, 
        --      type = "NPC" or "OBJECT",
        --      nodes = {
        --          [1] name (string)
        --          [2] description (string) or nil
        --          [3] spawns (table): { [zoneID] = { {x, y}, ... } }              # table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
        --          [4] waypoints (table): { [zoneID] = { {x, y}, ... } } or nil    # table {[zoneID(int)] = {coordPair(floatVector2D),...},...} or nil
        --          [5] friendlyToFaction (string): "A", "H", or "AH"
        --      }
        -- ====================================================================
        ["AUCTIONEER"] = {
            icon = POI_ICONS.AUCTIONEER,
            type = POI_TYPES.NPC,
            nodes = {
                [8669] = {'Auctioneer Tolon',nil,{[1457]={{56.37,51.82}}},nil,"A"},                             -- Darnassus
                [15679] = {'Auctioneer Cazarez',nil,{[1457]={{55.59,52.45}}},nil,"A"},                          -- Darnassus
                [8723] = {'Auctioneer Golothas',nil,{[1457]={{56.24,54.04}}},nil,"A"},                          -- Darnassus
                [8719] = {'Auctioneer Fitch',nil,{[1453]={{53.64,60.54}}},nil,"A"},                             -- Stormwind City
                [15659] = {'Auctioneer Jaxon',nil,{[1453]={{53.61,59.76}}},nil,"A"},                            -- Stormwind City
                [8670] = {'Auctioneer Chilton',nil,{[1453]={{53.21,60.85}}},nil,"A"},                           -- Stormwind City
                [8671] = {'Auctioneer Buckler',nil,{[1455]={{23.77,71.79}}},nil,"A"},                           -- Ironforge
                [8720] = {'Auctioneer Redmuse',nil,{[1455]={{24.16,74.67}}},nil,"A"},                           -- Ironforge
                [9859] = {'Auctioneer Lympkin',nil,{[1455]={{25.81,75.55}}},nil,"A"},                           -- Ironforge
                
                [8672] = {'Auctioneer Leeka',nil,{[1458]={{67.55,52.42}}},nil,"H"},                             -- Undercity
                [8721] = {'Auctioneer Epitwee',nil,{[1458]={{64.42,52.41}}},nil,"H"},                           -- Undercity
                [15675] = {'Auctioneer Stockton',nil,{[1458]={{71.42,46.69}}},nil,"H"},                         -- Undercity
                [15676] = {'Auctioneer Yarly',nil,{[1458]={{71.51,41.9}}},nil,"H"},                             -- Undercity
                [15682] = {'Auctioneer Cain',nil,{[1458]={{67.65,35.9}}},nil,"H"},                              -- Undercity
                [15683] = {'Auctioneer Naxxremis',nil,{[1458]={{64.4,35.81}}},nil,"H"},                         -- Undercity
                [15684] = {'Auctioneer Tricket',nil,{[1458]={{60.49,41.75}}},nil,"H"},                          -- Undercity
                [15686] = {'Auctioneer Rhyker',nil,{[1458]={{60.47,46.44}}},nil,"H"},                           -- Undercity
                [8674] = {'Auctioneer Stampi',nil,{[1456]={{40.41,51.77}}},nil,"H"},                            -- Thunder Bluff
                [8722] = {'Auctioneer Gullem',nil,{[1456]={{38.9,50.19}}},nil,"H"},                             -- Thunder Bluff
                [8673] = {'Auctioneer Thathung',nil,{[1454]={{55.9,62.71}}},nil,"H"},                           -- Orgrimmar
                [8724] = {'Auctioneer Wabang',nil,{[1454]={{55.84,64.81}}},nil,"H"},                            -- Orgrimmar
                [9856] = {'Auctioneer Grimful',nil,{[1454]={{55.25,61.79}}},nil,"H"},                           -- Orgrimmar
                
                [8661] = {'Auctioneer Beardo',"Neutral Auctionhouse",{[1446]={{51.96,29.65}}},nil,"AH"},        -- Tanaris
                [9857] = {'Auctioneer Grizzlin',"Neutral Auctionhouse",{[1452]={{61.45,37.2}}},nil,"AH"},       -- Winterspring
                [9858] = {'Auctioneer Kresky',"Neutral Auctionhouse",{[1434]={{27.78,77.05}}},nil,"AH"},        -- Stranglethorn Vale
                [15677] = {'Auctioneer Graves',"Neutral Auctionhouse",{[1434]={{28.43,75.92}}},nil,"AH"},       -- Stranglethorn Vale
                [242827] = {'Captain Bloodcoin',"Neutral Auctionhouse",{[1413]={{62.84,26.22}}},nil,"AH"},      -- Eastern Kingdoms
            }
        },
        ["DUNGEON"] = {
            wMapScale = 1.4,
            icon = POI_ICONS.DUNGEON_ENTRANCE,
            type = POI_TYPES.OBJECT,
            nodes = {
                [179596] = {"Meeting Stone","Ragefire Chasm (13-18)",{[1454]={{51.44,48.7}}},nil,"AH"},
                [178884] = {"Meeting Stone","Wailing Caverns (17-24)",{[1413]={{46.96,35.61}}},nil,"AH"},
                [178834] = {"Meeting Stone","The Deadmines (17-26)",{[1436]={{41.59,72.4}}},nil,"AH"},
                [178828] = {"Meeting Stone","Blackfathom Depths (20-30)",{[1440]={{15.36,15.55}}},nil,"AH"},
                [178845] = {"Meeting Stone","Shadowfang Keep (22-30)",{[1421]={{46.21,68.35}}},nil,"AH"},
                [179595] = {"Meeting Stone","The Stockades (24-32)",{[1453]={{43.36,59.31}}},nil,"AH"},
                [178844] = {"Meeting Stone","Scarlet Monastery (26-45)\nGraveyard (26-26)\nLibrary (29-39)\nArmory (32-42)\nCathedral (35-45)",{[1420]={{82.14,39.22}}},nil,"AH"},
                [179555] = {"Meeting Stone","Gnomeregan (29-38)",{[1426]={{24.27,40.4}}},nil,"AH"},
                [178825] = {"Meeting Stone","Razorfen Kraul (30-40)",{[1413]={{43.72,89.96}}},nil,"AH"},
                [178824] = {"Meeting Stone","Razorfen Downs (37-46)",{[1413]={{45.16,88.61}}},nil,"AH"},
                [178833] = {"Meeting Stone","Uldaman (41-51)",{[1418]={{49.06,13.68}}},nil,"AH"},
                [178829] = {"Meeting Stone","Zul'Farrak (44-54)",{[1446]={{38.49,20.74}}},nil,"AH"},
                [178827] = {"Meeting Stone","Maraudon (46-55)",{[1443]={{31.5,62.36}}},nil,"AH"},
                [179554] = {"Meeting Stone","Sunken Temple (50-60)",{[1435]={{69.1, 54.7}}},nil,"AH"},
                [179585] = {"Meeting Stone","Blackrock Depths (52-60)",{[1428]={{32.77,30.43}}},nil,"AH"},
                [179584] = {"Meeting Stone","LBRS (55-60)\nUBRS (55-60)",{[1428]={{29.8, 28.7}}},nil,"AH"},
                [178826] = {"Meeting Stone","Dire Maul\nEast (55-60)\nWest (58-60)\nNorth (58-60)",{[1444]={{57.97,44.48}}},nil,"AH"},
                [178832] = {"Meeting Stone","Scholomance (58-60)",{[1422]={{69.5,74.46}}},nil,"AH"},
                [178831] = {"Meeting Stone","Strathholme (58-60)",{[1423]={{30.85,16.56}}},nil,"AH"},
                [1788300] = {"Dungeon Entrance","Srvice Entrance\nStrathholme (58-60)",{[1423]={{47.81,22.83}}},nil,"AH"},

                [1788301] = {"Dungeon Entrance","Karazhan Crypts (60)",{[1430]={{39.41, 73.66}}},nil,"AH"},
                [1788302] = {"Dungeon Entrance","Demonfall Canyon (60)",{[1440]={{84.56, 75.29}}},nil,"AH"},
            }
        },
        ["RAIDS"] = {
            icon = POI_ICONS.RAID_ENTRANCE,
            wMapScale = 1.4,
            type = POI_TYPES.OBJECT,
            nodes = {
                [1788311] = {"Raid Entrance","Onyxia's Lair",{[1445]={{51.01,77.71}}},nil,"AH"},
                [1788312] = {"Raid Entrance","Blackwing Lair\nMolten Core",{[1428]={{27.17, 30.44}}},nil,"AH"},
                [1788313] = {"Raid Entrance","Zul'Gurub",{[1434]={{50.52, 17.53}}},nil,"AH"},
                [1788314] = {"Raid Entrance","Ahn Qiraj",{[1451]={{29.09, 96.96}}},nil,"AH"},
                [1788315] = {"Raid Entrance","Naxxramas",{[1423]={{43.00, 26.00}}},nil,"AH"},
                [1788316] = {"Raid Entrance","Scarlet Enclave",{[1423]={{71.25, 87.00}}},nil,"AH"},
                [1788317] = {"Raid Entrance","Thunderaan",{[1451]={{21.89, 10.52}}},nil,"AH"},

                -- SoD Exclusive
                [1788331] = {"Raid Entrance","Azuregos",{[1447]={{33.00, 81.00}}},nil,"AH"},
                [1788332] = {"Raid Entrance","Kazzak",{[1419]={{43.96, 55.27}}},nil,"AH"},
                [1788333] = {"Raid Entrance","Nightmare Dragons",{[1431]={{46.55, 37.69}}},nil,"AH"},

            }
        },
        ["MAILBOX"] = {
            icon = POI_ICONS.MAILBOX,
            type = POI_TYPES.OBJECT,
            nodes = {
                [180451] = {"Mailbox",nil,{[230]={{51.75,37.97}}},nil,"AH"},                                   -- Uldaman
                [143981] = {"Mailbox",nil,{[1411]={{51.9,42.15}}},nil,"AH"},                                   -- Durotar
                [143984] = {"Mailbox",nil,{[1412]={{47.01,60.3}}},nil,"AH"},                                   -- Mulgore
                [143982] = {"Mailbox",nil,{[1413]={{52.03,30.43}}},nil,"AH"},                                  -- The Barrens
                [153578] = {"Mailbox",nil,{[1413]={{45.08,58.67}}},nil,"AH"},                                  -- The Barrens
                [144125] = {"Mailbox",nil,{[1413]={{62.16,39.19}}},nil,"AH"},                                  -- The Barrens
                [164840] = {"Mailbox",nil,{[1417]={{73.86,33.11}}},nil,"AH"},                                  -- Arathi Highlands
                [163313] = {"Mailbox",nil,{[1418]={{3.83,47.3}}},nil,"AH"},                                    -- Badlands                 
                [164618] = {"Mailbox",nil,{[1419]={{64.06,19.22}}},nil,"AH"},                                  -- Blasted Lands
                [143990] = {"Mailbox",nil,{[1420]={{61.5,53.08}}},nil,"AH"},                                   -- Tirisfal
                [143989] = {"Mailbox",nil,{[1421]={{43.41,41.52}}},nil,"AH"},                                  -- Silverpine Forest
                [181236] = {"Mailbox",nil,{[1423]={{80.94,58.52}}},nil,"AH"},                                  -- Eastern Plaguelands LHC
                [143988] = {"Mailbox",nil,{[1424]={{62.38,19.71}}},nil,"AH"},                                  -- Hillsbrad Foothills
                [143987] = {"Mailbox",nil,{[1424]={{50.42,58.7}}},nil,"AH"},                                   -- Hillsbrad Foothills
                [179895] = {"Mailbox",nil,{[1425]={{78.84,80.5}}},nil,"AH"},                                   -- The Hinterlands
                [144011] = {"Mailbox",nil,{[1425]={{14.04,45.7}}},nil,"AH"},                                   -- The Hinterlands
                [142102] = {"Mailbox",nil,{[1426]={{47.02,52.58}}},nil,"AH"},                                  -- Dun Morogh
                [142075] = {"Mailbox",nil,{[1429]={{42.92,65.52}},[1453]={{22.13,57.81}}},nil,"AH"},           -- Elwynn Forrest & Stormwind City
                [142089] = {"Mailbox",nil,{[1431]={{73.73,46.1}}},nil,"AH"},                                   -- Duskwood
                [142103] = {"Mailbox",nil,{[1432]={{34.82,47.73}}},nil,"AH"},                                  -- Loch Modan
                [142093] = {"Mailbox",nil,{[1433]={{26.41,46.51}}},nil,"AH"},                                  -- Redridge Mountains
                [144126] = {"Mailbox",nil,{[1434]={{26.7,76.36}}},nil,"AH"},                                   -- Stranglethorn Vale
                [144127] = {"Mailbox",nil,{[1434]={{27.28,77.41}}},nil,"AH"},                                  -- Stranglethorn Vale
                [163645] = {"Mailbox",nil,{[1434]={{32.52,28.65}}},nil,"AH"},                                  -- Stranglethorn Vale
                [157637] = {"Mailbox",nil,{[1435]={{45.44,55.14}}},nil,"AH"},                                  -- Swamp of Sorrows
                [153716] = {"Mailbox",nil,{[1436]={{53.1,53.34}}},nil,"AH"},                                   -- Westfall
                [142094] = {"Mailbox",nil,{[1437]={{10.86,59.72}}},nil,"AH"},                                  -- Wetlands
                [142109] = {"Mailbox",nil,{[1438]={{56.12,58.43}}},nil,"AH"},                                  -- Teldrassil
                [142111] = {"Mailbox",nil,{[1439]={{37.32,43.73}}},nil,"AH"},                                  -- Darkshore
                [178864] = {"Mailbox",nil,{[1440]={{73.63,60.89}}},nil,"AH"},                                  -- Ashenvale
                [142117] = {"Mailbox",nil,{[1440]={{36.33,50.22}}},nil,"AH"},                                  -- Ashenvale
                [176324] = {"Mailbox",nil,{[1441]={{45.85,51.06}}},nil,"AH"},                                  -- Thousand Needles
                [143983] = {"Mailbox",nil,{[1442]={{48.01,61.14}}},nil,"AH"},                                  -- Stonetalon Mountains
                [181639] = {"Mailbox",nil,{[1442]={{36.02,7.21}}},nil,"AH"},                                   -- Stonetalon Mountains
                [179896] = {"Mailbox",nil,{[1443]={{24.79,68.76}}},nil,"AH"},                                  -- Desolace
                [176319] = {"Mailbox",nil,{[1443]={{65.43,6.8}}},nil,"AH"},                                    -- Dseolace
                [142119] = {"Mailbox",nil,{[1444]={{31.26,43.8}}},nil,"AH"},                                   -- Feralas
                [143986] = {"Mailbox",nil,{[1444]={{74.88,44.0}}},nil,"AH"},                                   -- Feralas
                [142095] = {"Mailbox",nil,{[1445]={{65.96,45.29}}},nil,"AH"},                                  -- Dustwallow
                [144112] = {"Mailbox",nil,{[1446]={{52.33,27.81}}},nil,"AH"},                                  -- Tanaris
                [187260] = {"Mailbox",nil,{[1448]={{34.82,52.95}}},nil,"AH"},                                  -- Felwood
                [176404] = {"Mailbox",nil,{[1452]={{61.28,38.62}}},nil,"AH"},                                  -- Winterspring
                [144128] = {"Mailbox",nil,{[1453]={{70.91,40.01}}},nil,"AH"},                                  -- Stormwind City
                [144129] = {"Mailbox",nil,{[1453]={{39.94,84.4}}},nil,"AH"},                                   -- Stormwind City
                [144131] = {"Mailbox",nil,{[1453]={{54.23,66.73}}},nil,"AH"},                                  -- Stormwind City
                [173047] = {"Mailbox",nil,{[1454]={{62.26,40.51}}},nil,"AH"},                                  -- Orgrimmar
                [173221] = {"Mailbox",nil,{[1454]={{50.69,70.37}}},nil,"AH"},                                  -- Orgrimmar
                [32349] = {"Mailbox",nil,{[1455]={{20.96,52.41}}},nil,"AH"},                                   -- Ironforge
                [171556] = {"Mailbox",nil,{[1455]={{71.31,72.13}}},nil,"AH"},                                  -- Ironforge
                [171699] = {"Mailbox",nil,{[1455]={{33.22,64.66}}},nil,"AH"},                                  -- Ironforge
                [171752] = {"Mailbox",nil,{[1455]={{72.28,49.1}}},nil,"AH"},                                   -- Ironforge
                [143985] = {"Mailbox",nil,{[1456]={{45.23,59.4}}},nil,"AH"},                                   -- Thunder Bluff
                [188123] = {"Mailbox",nil,{[1457]={{67.18,16.47}}},nil,"AH"},                                  -- Darnassus
                [142110] = {"Mailbox",nil,{[1457]={{41.63,41.85}}},nil,"AH"},                                  -- Darnassus
                [177044] = {"Mailbox",nil,{[1458]={{68.16,38.26}}},nil,"AH"},                                  -- Undercity

                -- SoD Exclusive
                [529383] = {"Mailbox",nil,{[1423]={{90.32,81.98}}},nil,"AH"},                                  -- Eastern Plaguelands New Avalon
            }
        },
        ["BANKER"] = {
            icon = POI_ICONS.BANKER,
            type = POI_TYPES.NPC,
            nodes = {
                [2455] = {'Olivia Burnside',nil,{[1453]={{57.66,72.78}}},nil,"A"}, -- Stormwind City
                [2456] = {'Newton Burnside',nil,{[1453]={{57.12,73.23}}},nil,"A"}, -- Stormwind City
                [2457] = {'John Burnside',nil,{[1453]={{56.57,73.68}}},nil,"A"}, -- Stormwind City
                [4155] = {'Idriana',nil,{[1457]={{39.39,42.44}}},nil,"A"}, -- Darnassus
                [4208] = {'Lairn',nil,{[1457]={{39.68,41.54}}},nil,"A"}, -- Darnassus
                [4209] = {'Garryeth',nil,{[1457]={{39.6,41.98}}},nil,"A"}, -- Darnassus
                [2460] = {'Barnum Stonemantle',nil,{[1455]={{34.97,58.41}}},nil,"A"}, -- Ironforge
                [5099] = {'Soleil Stonemantle',nil,{[1455]={{36.82,61.86}}},nil,"A"}, -- Ironforge
                [2461] = {'Bailey Stonemantle',nil,{[1455]={{35.92,60.14}}},nil,"A"}, -- Ironforge
                [2996] = {'Torn',nil,{[1456]={{47.63,58.58}}},nil,"H"}, -- Thunder Bluff
                [8356] = {'Chesmu',nil,{[1456]={{47.13,57.89}}},nil,"H"}, -- Thunder Bluff
                [8357] = {'Atepa',nil,{[1456]={{47.2,59.32}}},nil,"H"}, -- Thunder Bluff
                [3309] = {'Karus',nil,{[1454]={{49.58,69.12}}},nil,"H"}, -- Orgrimmar
                [3318] = {'Koma',nil,{[1454]={{50.0,68.58}}},nil,"H"}, -- Orgrimmar
                [3320] = {'Soran',nil,{[1454]={{49.08,69.59}}},nil,"H"}, -- Orgrimmar
                [2458] = {'Randolph Montague',nil,{[1458]={{65.93,43.43}}},nil,"H"}, -- Undercity
                [2459] = {'Mortimer Montague',nil,{[1458]={{66.41,44.06}}},nil,"H"}, -- Undercity
                [4549] = {'William Montague',nil,{[1458]={{65.97,44.75}}},nil,"H"}, -- Undercity
                [4550] = {'Ophelia Montague',nil,{[1458]={{65.56,44.07}}},nil,"H"}, -- Undercity
                [3496] = {'Fuzruckle',nil,{[1413]={{62.64,37.42}}},nil,"AH"}, -- The Barrens
                [8119] = {'Zikkel',nil,{[1413]={{62.68,37.4}}},nil,"AH"}, -- The Barrens
                [2625] = {'Viznik Goldgrubber',nil,{[1434]={{26.54,76.57}}},nil,"AH"}, -- Stranglethorn Vale
                [8123] = {'Rickle Goldgrubber',nil,{[1434]={{26.51,76.47}}},nil,"AH"}, -- Stranglethorn Vale
                [8124] = {'Qizzik',nil,{[1446]={{52.38,28.95}}},nil,"AH"}, -- Tanaris
                [7799] = {'Gimblethorn',nil,{[1446]={{52.3,28.91}}},nil,"AH"}, -- Tanaris
                [13917] = {'Izzy Coppergrab',nil,{[1452]={{61.45,36.98}}},nil,"AH"}, -- Winterspring

                -- SoD Exclusive
                [241862] = {'Scarlet Stash',"Bank",{[1423]={{98.75,82.25},{98.51,82.57}}},nil,"AH"}, -- Eastern Plaguelands
            }
        },
        ["REPAIR"] = {
            icon = POI_ICONS.REPAIR,
            type = POI_TYPES.NPC,
            nodes = {
                [3611] = {"Brannol Eaglemoon","Clothier",{[1438]={{56.12,60.25}}},nil,"A"},
                [3612] = {"Sinda","Leather Armor Merchant",{[1438]={{56.33,59.59}}},nil,"A"},
                [8176] = {"Gharash","Blacksmithing Supplies",{[1435]={{45.46,51.41}}},nil,"H"},
                [4600] = {"Geoffrey Hartwell","Weapon Merchant",{[1458]={{58.67,33.06}}},nil,"H"},
                [2046] = {"Andrew Krighton","Armorer & Shieldcrafter",{[1429]={{41.7,65.86}}},{[1429]={{{41.7,65.86},{41.67,65.87},{41.67,65.87}}}},"A"},
                [4602] = {"Benijah Fenner","Weapon Merchant",{[1458]={{58.82,32.82}}},nil,"H"},
                [4603] = {"Nicholas Atwood","Gun Merchant",{[1458]={{62.72,26.76}}},nil,"H"},
                [4604] = {"Abigail Sawyer","Bow Merchant",{[1458]={{54.7,38.76}}},nil,"H"},
                [3073] = {"Marjak Keenblade","Weaponsmith",{[1412]={{44.06,77.47}}},nil,"H"},
                [3074] = {"Varia Hardhide","Leather Armor Merchant",{[1412]={{44.14,77.25}}},nil,"H"},
                [3075] = {"Bronk Steelrage","Armorer and Shieldcrafter",{[1412]={{44.21,77.5}}},nil,"H"},
                [5120] = {"Brenwyn Wintersteel","Blade Merchant",{[1455]={{62.37,88.68}}},nil,"A"},
                [3077] = {"Mahnott Roughwound","Weaponsmith",{[1412]={{45.66,58.6}}},nil,"H"},
                [3078] = {"Kennah Hawkseye","Gunsmith",{[1412]={{45.49,58.47}}},nil,"H"},
                [3079] = {"Varg Windwhisper","Leather Armor Merchant",{[1412]={{45.82,58.7}}},nil,"H"},
                [3080] = {"Harant Ironbrace","Armorer and Shieldcrafter",{[1412]={{45.9,58.73}}},nil,"H"},
                [3592] = {"Andiss","Armorer & Shieldcrafter",{[1438]={{58.68,39.84}}},nil,"A"},
                [5126] = {"Olthran Craghelm","Heavy Armor Merchant",{[1455]={{54.86,87.41}}},nil,"A"},
                [5129] = {"Lissyphus Finespindle","Light Armor Merchant",{[1455]={{54.7,87.97}}},nil,"A"},
                [3088] = {"Henry Chapal","Gunsmith",{[1433]={{23.84,41.32}}},nil,"A"},
                [5133] = {"Harick Boulderdrum","Wands Merchant",{[1455]={{23.13,15.94}}},nil,"A"},
                [16376] = {"Craftsman Wilhelm","Brotherhood of the Light",{[1423]={{81.01,59.62}}},nil,"AH"},
                [3093] = {"Grod","Leather Armor Merchant",{[1456]={{42.66,43.51}}},nil,"H"},
                [3095] = {"Fela","Heavy Armor Merchant",{[1456]={{42.75,44.8}}},nil,"H"},
                [12805] = {"Officer Areyn","Accessories Quartermaster",{[1453]={{73.83,53.67}}},nil,"A"},
                [3097] = {"Bernard Brubaker","Leather Armor Merchant",{[1433]={{88.25,71.02}}},nil,"A"},
                [3609] = {"Shalomon","Weaponsmith",{[1438]={{56.31,59.49}}},nil,"A"},
                [3610] = {"Jeena Featherbow","Bowyer",{[1438]={{55.89,59.21}}},nil,"A"},
                [3613] = {"Meri Ironweave","Armorer & Shieldcrafter",{[1438]={{56.29,59.38}}},nil,"A"},
                [5152] = {"Bingus","Weapon Merchant",{[1455]={{22.77,15.92}}},nil,"A"},
                [5156] = {"Maeva Snowbraid","Robe Merchant",{[1455]={{38.68,5.99}}},nil,"A"},
                [54] = {"Corina Steele","Weaponsmith",{[1429]={{41.53,65.9}}},{[1429]={{{41.32,65.7},{41.53,65.88},{41.53,65.88},{41.53,65.88}}}},"A"},
                [5170] = {"Hjoldir Stoneblade","Blade Merchant",{[1455]={{44.99,6.79}}},nil,"A"},
                [2113] = {"Archibald Kava","Cloth & Leather Armor Merchant",{[1420]={{32.41,65.66}}},nil,"H"},
                [2116] = {"Blacksmith Rand","Apprentice Armorer",{[1420]={{32.38,66.23}}},nil,"H"},
                [2117] = {"Harold Raims","Apprentice Weaponsmith",{[1420]={{32.4,66.43}}},nil,"H"},
                [74] = {"Kurran Steele","Cloth & Leather Armor Merchant",{[1429]={{41.37,65.59}}},nil,"A"},
                [4164] = {"Cylania","Night Elf Armorer",{[1457]={{59.24,46.36}}},nil,"A"},
                [78] = {"Janos Hammerknuckle","Weaponsmith",{[1429]={{47.24,41.9}}},nil,"A"},
                [3658] = {"Lizzarik","Weapon Dealer",{[1413]={{61.76,38.29}}},{[1413]={{{61.78,38.24},{61.57,37.89},{61.43,37.9},{61.18,37.94},{61.01,38.08},{60.81,38.34},{60.47,38.4},{60.32,38.52},{60.19,38.8},{59.89,38.84},{59.62,38.9},{59.42,38.87},{59.02,38.75},{58.84,38.59},{58.46,38.33},{58.06,38.03},{57.77,37.82},{57.54,37.4},{57.21,37.05},{56.84,36.91},{56.43,36.89},{56.29,36.62},{56.21,36.1},{55.98,35.62},{55.81,35.42},{55.46,34.97},{55.27,34.49},{55.06,34.31},{54.91,33.65},{54.68,33.31},{54.38,32.89},{54.15,32.53},{53.73,31.83},{53.4,31.31},{53.21,31.08},{52.87,31.01},{52.5,30.92},{52.48,30.65},{52.46,30.68},{52.4,30.87},{52.57,30.99},{52.96,31.03},{53.29,31.19},{53.79,31.9},{54.09,32.42},{54.32,32.82},{54.93,33.7},{55.05,34.3},{55.26,34.46},{55.42,34.94},{55.73,35.35},{56.0,35.68},{56.21,36.09},{56.33,36.75},{56.49,36.91},{56.95,36.96},{57.46,37.31},{57.63,37.52},{57.74,37.79},{58.03,38.01},{58.4,38.29},{58.71,38.47},{59.0,38.74},{59.33,38.86},{59.69,38.92},{60.0,38.84},{60.12,38.86},{60.36,38.48},{60.61,38.36},{60.83,38.31},{61.12,37.96},{61.53,37.88},{61.7,38.11},{61.8,38.26},{61.74,38.33},{61.75,38.28}}}},"AH"},
                [1104] = {"Grundel Harkin","Armorer",{[1426]={{28.79,67.84}}},nil,"A"},
                [4173] = {"Landria","Bow Merchant",{[1457]={{63.26,66.27}}},nil,"A"},
                [2135] = {"Abe Winters","Apprentice Armorer",{[1420]={{60.22,53.1}}},nil,"H"},
                [2136] = {"Oliver Dwor","Apprentice Weaponsmith",{[1420]={{60.12,53.39}}},nil,"H"},
                [2137] = {"Eliza Callen","Leather Armor Merchant",{[1420]={{60.31,52.82}}},nil,"H"},
                [3160] = {"Huklah","Cloth & Leather Armor Merchant",{[1411]={{40.61,67.8}}},nil,"H"},
                [3161] = {"Rarc","Armorer & Shieldcrafter",{[1411]={{40.48,67.82}}},nil,"H"},
                [3162] = {"Burdrak Harglhelm","Leather Armor Merchant",{[1426]={{30.11,45.28}}},nil,"A"},
                [3163] = {"Uhgar","Weaponsmith",{[1411]={{52.02,40.45}}},nil,"H"},
                [4186] = {"Mavralyn","Leather Armor & Leatherworking Supplies",{[1439]={{37.0,41.2}}},nil,"A"},
                [3165] = {"Ghrawt","Bowyer",{[1411]={{52.98,41.03}}},nil,"H"},
                [3166] = {"Cutac","Cloth & Leather Armor Merchant",{[1411]={{53.11,40.86}}},nil,"H"},
                [3167] = {"Wuark","Armorer & Shieldcrafter",{[1411]={{51.9,41.14}}},nil,"H"},
                [3682] = {"Vrang Wildgore","Weaponsmith & Armorcrafter",{[1413]={{43.8,12.21}}},nil,"H"},
                [3683] = {"Kiknikle","Stylish Clothier",{[1413]={{41.79,38.69}}},nil,"AH"},
                [3684] = {"Pizznukle","Leather Armor Merchant",{[1413]={{41.77,38.62}}},nil,"AH"},
                [3177] = {"Turuk Amberstill","Dwarven Weaponsmith",{[1426]={{62.9,49.89}}},nil,"A"},
                [1645] = {"Quartermaster Hicks","Master Weaponsmith",{[1429]={{25.37,74.0}}},nil,"A"},
                [4203] = {"Ariyell Skyshadow","Weapon Merchant",{[1457]={{58.76,44.5}}},nil,"A"},
                [1146] = {"Vharr","Superior Weaponsmith",{[1434]={{32.36,27.95}}},nil,"H"},
                [1147] = {"Hragran","Cloth & Leather Armor Merchant",{[1434]={{31.61,29.18}}},nil,"H"},
                [10857] = {"Argent Quartermaster Lightspark","The Argent Dawn",{[1422]={{42.84,83.72}}},nil,"AH"},
                [5754] = {"Zane Bradford","Wand Vendor",{[1458]={{69.56,26.94}}},nil,"H"},
                [1668] = {"William MacGregor","Bowyer",{[1436]={{57.71,53.94}}},nil,"A"},
                [1669] = {"Defias Profiteer","Free Wheeling Merchant",{[1436]={{43.47,66.76}}},nil,"AH"},
                [10361] = {"Gruul Darkblade","Weaponsmith",{[1447]={{22.22,51.09}}},nil,"H"},
                [4231] = {"Kieran","Weapon Merchant",{[1457]={{64.99,60.22}}},nil,"A"},
                [10369] = {"Trayexir","Weapon Merchant",{[1411]={{56.47,73.12}}},nil,"H"},
                [4240] = {"Caynrus","Shield Merchant",{[1457]={{56.93,76.33}}},nil,"A"},
                [1686] = {"Irene Sureshot","Gunsmith",{[1432]={{83.15,63.42}}},nil,"A"},
                [1687] = {"Cliff Hadin","Bowyer",{[1432]={{83.02,62.96}}},nil,"A"},
                [1690] = {"Thrawn Boltar","Blacksmithing Supplies",{[1426]={{45.3,51.53}}},nil,"A"},
                [10379] = {"Altsoba Ragetotem","Weapon Merchant",{[1448]={{34.81,53.16}}},nil,"H"},
                [10380] = {"Sanuye Runetotem","Leather Armor Merchant",{[1413]={{45.12,59.01}}},nil,"H"},
                [1695] = {"Rendow","Leather Armor Merchant",{[1444]={{89.35,45.86}}},nil,"A"},
                [1698] = {"Frast Dokner","Apprentice Weaponsmith",{[1426]={{69.0,55.89}}},{[1426]={{{69.0,55.89},{68.95,55.84},{68.88,55.86},{68.86,55.95},{68.88,55.87},{68.95,55.85}}}},"A"},
                [167] = {"Morhan Coppertongue","Metalsmith",{[1432]={{34.02,46.54}}},nil,"A"},
                [6300] = {"Elisa Steelhand","Blacksmithing Supplies",{[1439]={{38.14,41.11}}},nil,"A"},
                [4257] = {"Lana Thunderbrew","Blacksmithing Supplies",{[1459]={{43.41,15.64}}},nil,"A"},
                [4259] = {"Thurgrum Deepforge","Blacksmithing Supplies",{[1455]={{51.74,42.78}}},nil,"A"},
                [1198] = {"Rallic Finn","Bowyer",{[1429]={{83.28,66.09}}},nil,"A"},
                [8359] = {"Ahanu","Leather Armor Merchant",{[1456]={{45.77,55.84}}},nil,"H"},
                [8360] = {"Elki","Mail Armor Merchant",{[1456]={{44.96,56.59}}},nil,"H"},
                [7852] = {"Pratt McGrubben","Leatherworking Supplies",{[1444]={{30.63,42.71}}},nil,"A"},
                [190] = {"Dermot Johns","Cloth & Leather Armor Merchant",{[1429]={{47.56,41.4}}},nil,"A"},
                [1213] = {"Godric Rothgar","Armorer & Shieldcrafter",{[1429]={{47.69,41.42}}},nil,"A"},
                [1214] = {"Aldren Cordon","Clothier",{[1432]={{64.82,66.05}}},nil,"A"},
                [5816] = {"Katis","Wand Merchant",{[1454]={{44.18,48.44}}},nil,"H"},
                [5819] = {"Mirelle Tremayne","Heavy Armor Merchant",{[1458]={{61.64,28.95}}},nil,"H"},
                [5820] = {"Gillian Moore","Leather Armor Merchant",{[1458]={{70.34,58.22}}},nil,"H"},
                [1238] = {"Gamili Frosthide","Cloth & Leather Armor Merchant",{[1426]={{45.18,51.93}}},nil,"A"},
                [1240] = {"Boran Ironclink","Armorer",{[1426]={{45.16,51.75}}},nil,"A"},
                [222] = {"Nillen Andemar","Macecrafter",{[1432]={{42.87,9.89}}},nil,"A"},
                [225] = {"Gavin Gnarltree","Weaponsmith",{[1431]={{73.6,50.04}}},{[1431]={{{73.48,50.0},{73.64,49.6},{73.73,49.37},{73.81,49.09},{73.69,48.86},{73.61,48.9},{73.79,49.17},{73.71,49.41},{73.65,49.61},{73.6,50.04}}}},"A"},
                [226] = {"Morg Gnarltree","Armorer",{[1431]={{73.97,48.89}}},{[1431]={{{73.98,48.87},{73.71,48.55},{73.68,48.55},{73.68,48.53},{73.97,48.89}}}},"A"},
                [1249] = {"Quartermaster Hudson","Armorer & Shieldcrafter",{[1429]={{25.23,74.07}}},nil,"A"},
                [228] = {"Avette Fellwood","Bowyer",{[1431]={{73.03,44.42}}},{[1431]={{{73.27,44.76},{73.27,44.81},{73.03,44.47}}}},"A"},
                [3314] = {"Urtharo","Weapon Merchant",{[1454]={{47.56,68.38}}},nil,"H"},
                [3316] = {"Handor","Cloth & Leather Armor Merchant",{[1454]={{62.88,44.69}}},nil,"H"},
                [1273] = {"Grawn Thromwyn","Weaponsmith",{[1426]={{45.29,52.19}}},nil,"A"},
                [3319] = {"Sana","Mail Armor Merchant",{[1454]={{55.97,72.73}}},nil,"H"},
                [3321] = {"Morgum","Leather Armor Merchant",{[1454]={{56.24,73.21}}},nil,"H"},
                [3322] = {"Kaja","Guns and Ammo Merchant",{[1454]={{52.15,62.13}}},nil,"H"},
                [3330] = {"Muragus","Staff Merchant",{[1454]={{44.35,48.11}}},nil,"H"},
                [1287] = {"Marda Weller","Weapons Merchant",{[1453]={{57.38,56.77}}},nil,"A"},
                [1289] = {"Gunther Weller","Weapons Merchant",{[1453]={{57.55,57.07}}},nil,"A"},
                [12023] = {"Kharedon","Light Armor Merchant",{[1450]={{56.6,29.95}}},nil,"AH"},
                [12024] = {"Meliri","Weaponsmith",{[1450]={{51.18,42.31}}},nil,"AH"},
                [1294] = {"Aldric Moore","Mail Armor Merchant",{[1453]={{54.58,55.24}}},nil,"A"},
                [1295] = {"Lara Moore","Leather Armor Merchant",{[1453]={{54.66,55.62}}},nil,"A"},
                [1296] = {"Felder Stover","Weaponsmith",{[1428]={{85.21,68.39}}},nil,"A"},
                [1297] = {"Lina Stover","Bow & Gun Merchant",{[1453]={{50.46,57.23}}},nil,"A"},
                [1298] = {"Frederick Stover","Bow & Arrow Merchant",{[1453]={{49.98,57.64}}},nil,"A"},
                [1299] = {"Lisbeth Schneider","Clothier",{[1453]={{49.92,55.2}}},nil,"A"},
                [789] = {"Kimberly Hiett","Fletcher",{[1433]={{27.08,45.55}}},nil,"A"},
                [793] = {"Kara Adams","Shield Crafter",{[1433]={{30.57,46.46}}},nil,"A"},
                [2839] = {"Haren Kanmae","Superior Bowyer",{[1434]={{28.31,74.56}}},nil,"AH"},
                [2840] = {"Kizz Bluntstrike","Macecrafter",{[1434]={{28.27,75.22}}},nil,"AH"},
                [1309] = {"Wynne Larson","Robe Merchant",{[1453]={{41.57,76.35}}},nil,"A"},
                [1310] = {"Evan Larson","Hatter",{[1453]={{42.62,76.57}}},nil,"A"},
                [2844] = {"Hurklor","Blacksmithing Supplies",{[1434]={{28.97,75.06}}},nil,"AH"},
                [1312] = {"Ardwyn Cailen","Wand Merchant",{[1453]={{42.88,65.11}}},nil,"A"},
                [4890] = {"Piter Verance","Weaponsmith & Armorer",{[1445]={{67.39,47.86}}},nil,"A"},
                [1314] = {"Duncan Cullen","Light Armor Merchant",{[1453]={{43.3,74.45}}},nil,"A"},
                [1315] = {"Allan Hafgan","Staves Merchant",{[1453]={{43.08,65.22}}},nil,"A"},
                [3361] = {"Shoma","Weapon Vendor",{[1454]={{81.59,18.86}}},nil,"H"},
                [1319] = {"Bryan Cross","Shield Merchant",{[1453]={{63.99,42.91}}},nil,"A"},
                [1320] = {"Seoman Griffith","Leather Armor Merchant",{[1453]={{67.45,48.53}}},nil,"A"},
                [1322] = {"Maxton Strang","Mail Armor Merchant",{[1443]={{67.93,8.31}}},nil,"A"},
                [1323] = {"Osric Strang","Heavy Armor Merchant",{[1453]={{74.31,47.24}}},nil,"A"},
                [1324] = {"Heinrich Stone","Blade Merchant",{[1453]={{74.37,42.56}}},nil,"A"},
                [1339] = {"Mayda Thane","Cobbler",{[1453]={{67.22,43.62}}},nil,"A"},
                [1341] = {"Wilhelm Strang","Mail Armor Merchant",{[1453]={{74.75,47.64}}},nil,"A"},
                [836] = {"Durnan Furcutter","Cloth & Leather Armor Merchant",{[1426]={{28.77,66.37}}},nil,"A"},
                [1348] = {"Gregory Ardus","Staff & Mace Merchant",{[1453]={{36.77,39.65}}},nil,"A"},
                [1349] = {"Agustus Moulaine","Mail Armor Merchant",{[1453]={{43.73,42.81}}},nil,"A"},
                [1350] = {"Theresa Moulaine","Robe Vendor",{[1453]={{43.34,43.29}}},nil,"A"},
                [1362] = {"Gothor Brumn","Armorer",{[1432]={{24.13,18.21}}},nil,"A"},
                [9544] = {"Yuka Screwspigot",nil,{[1428]={{66.06,21.95}}},nil,"AH"},
                [9548] = {"Cawind Trueaim","Gunsmith & Bowyer",{[1444]={{74.94,45.71}}},nil,"H"},
                [9549] = {"Borand","Bowyer",{[1442]={{45.36,59.1}}},nil,"H"},
                [9551] = {"Starn","Gunsmith & Bowyer",{[1441]={{44.89,50.68}}},nil,"H"},
                [9552] = {"Zanara","Bowyer",{[1445]={{35.5,30.09}}},nil,"H"},
                [9553] = {"Nadia Vernon","Bowyer",{[1421]={{45.01,39.3}}},nil,"H"},
                [15176] = {"Vargus","Blacksmith",{[1451]={{51.23,38.86}}},nil,"AH"},
                [1381] = {"Krakk","Superior Armorer",{[1434]={{32.57,27.95}}},nil,"H"},
                [2404] = {"Blacksmith Verringtan",nil,{[1424]={{32.11,44.42}}},nil,"A"},
                [3951] = {"Bhaldaran Ravenshade","Bowyer",{[1440]={{50.27,67.27}}},nil,"A"},
                [3952] = {"Aeolynn","Clothier",{[1440]={{34.47,49.52}}},nil,"A"},
                [3953] = {"Tandaan Lightmane","Leather Armor Merchant",{[1440]={{34.55,49.9}}},nil,"A"},
                [15315] = {"Mylini Frostmoon","Weapon Merchant",{[1448]={{62.41,25.78}}},nil,"A"},
                [5108] = {"Raena Flinthammer","Light Armor Merchant",{[1455]={{32.62,57.39}}},nil,"A"},
                [14301] = {"Brinna Valanaar","Bowyer",{[1447]={{12.0,78.38}}},nil,"A"},
                [896] = {"Veldan Lightfoot","Leather Armor Merchant",{[1429]={{25.18,73.89}}},nil,"A"},
                [13219] = {"Jekyll Flandring","Frostwolf Supply Officer",{[1416]={{62.84,59.27}}},nil,"H"},
                [13218] = {"Grunnda Wolfheart","Frostwolf Supply Officer",{[1459]={{49.33,82.49}}},nil,"H"},
                [13217] = {"Thanthaldis Snowgleam","Stormpike Supply Officer",{[1416]={{39.45,81.65}}},nil,"A"},
                [4889] = {"Torq Ironblast","Gunsmith",{[1445]={{67.51,47.98}}},nil,"A"},
                [12942] = {"Leonard Porter","Leatherworking Supplies",{[1422]={{43.08,84.31}}},nil,"A"},
                [12029] = {"Narianna","Bowyer",{[1450]={{53.34,42.7}}},nil,"AH"},
                [4559] = {"Timothy Weldon","Heavy Armor Merchant",{[1458]={{62.62,39.71}}},nil,"H"},
                [11278] = {"Magnus Frostwake",nil,{[1422]={{68.12,77.57}}},nil,"AH"},
                [4601] = {"Francis Eliot","Weapon Merchant",{[1458]={{59.0,32.58}}},nil,"H"},
                [4883] = {"Krak","Armorer",{[1445]={{36.4,30.85}}},nil,"H"},
                [4884] = {"Zulrg","Weaponsmith",{[1445]={{36.17,31.8}}},nil,"H"},
                [10856] = {"Argent Quartermaster Hasana","The Argent Dawn",{[1420]={{83.26,68.14}}},nil,"AH"},
                [5508] = {"Strumner Flintheel","Armor Crafter",{[1419]={{66.08,17.16}}},nil,"A"},
                [5509] = {"Kathrum Axehand","Axe Merchant",{[1453]={{51.21,12.13}}},nil,"A"},
                [5510] = {"Thulman Flintcrag","Guns Vendor",{[1453]={{54.63,15.67}}},nil,"A"},
                [5512] = {"Kaita Deepforge","Blacksmithing Supplies",{[1453]={{56.33,17.2}}},nil,"A"},
                [9179] = {"Jazzrik","Blacksmithing Supplies",{[1418]={{42.47,52.5}}},nil,"AH"},
                [8878] = {"Muuran","Superior Macecrafter",{[1443]={{55.59,56.5}}},nil,"H"},
                [3530] = {"Pyrewood Tailor",nil,{[1421]={{46.55,72.39}}},nil,"A"},
                [6028] = {"Burkrum","Heavy Armor Merchant",{[1440]={{73.54,60.31}}},nil,"H"},
                [3534] = {"Wallace the Blind","Weaponsmith",{[1421]={{46.5,86.49}}},nil,"AH"},
                [8131] = {"Blizrik Buckshot","Gunsmith",{[1446]={{50.74,27.53}}},nil,"AH"},
                [8129] = {"Wrinkle Goodsteel","Superior Armor Crafter",{[1446]={{50.8,27.71}}},nil,"AH"},
                [3477] = {"Hraq","Blacksmithing Supplier",{[1413]={{51.13,28.96}}},nil,"H"},
                [7976] = {"Thalgus Thunderfist","Weapon Merchant",{[1455]={{61.55,89.43}}},nil,"A"},
                [3479] = {"Nargal Deatheye","Weaponsmith",{[1413]={{51.23,29.15}}},nil,"H"},
                [5812] = {"Tumi","Heavy Armor Merchant",{[1454]={{82.58,23.57}}},nil,"H"},
                [5411] = {"Krinkle Goodsteel","Blacksmithing Supplies",{[1446]={{51.46,28.81}}},nil,"AH"},
                [5125] = {"Dolkin Craghelm","Mail Armor Merchant",{[1455]={{53.85,87.89}}},nil,"A"},
                [3483] = {"Jahan Hawkwing","Leather & Mail Armor Merchant",{[1413]={{51.21,29.05}}},nil,"H"},
                [5123] = {"Bretta Goldfury","Gun Merchant",{[1455]={{72.21,65.24}}},nil,"A"},
                [1441] = {"Brak Durnad","Weaponsmith",{[1437]={{11.44,59.69}}},{[1437]={{{11.44,59.69},{11.58,59.54}}}},"A"},
                [3486] = {"Halija Whitestrider","Clothier",{[1413]={{52.25,31.86}}},nil,"H"},
                [5122] = {"Skolmin Goldfury","Bow Merchant",{[1455]={{71.76,66.7}}},nil,"A"},
                [3488] = {"Uthrok","Bowyer & Gunsmith",{[1413]={{51.11,29.06}}},nil,"H"},
                [5121] = {"Kelomir Ironhand","Maces & Staves",{[1455]={{62.55,88.71}}},nil,"A"},
                [5119] = {"Hegnar Swiftaxe","Axe Merchant",{[1455]={{62.19,88.16}}},nil,"A"},
                [3491] = {"Ironzar","Weaponsmith",{[1413]={{62.24,37.48}}},nil,"AH"},
                [3492] = {"Vexspindle","Cloth & Leather Armor Merchant",{[1413]={{62.16,38.45}}},nil,"AH"},
                [3493] = {"Grazlix","Armorer & Shieldcrafter",{[1413]={{62.21,38.41}}},nil,"AH"},
                [1450] = {"Brahnmar","Armorer",{[1437]={{11.54,59.86}}},{[1437]={{{11.54,59.86},{11.47,59.77}}}},"A"},
                [14737] = {"Smith Slagtree","Blacksmithing Supplies",{[1425]={{77.23,80.13}}},{[1425]={{{77.4,80.2},{77.52,80.35},{77.23,80.13}}}},"H"},
                [5107] = {"Mangorn Flinthammer","Heavy Armor Merchant",{[1455]={{31.95,57.93}}},nil,"A"},
                [2845] = {"Fargon Mortalak","Superior Armorer",{[1434]={{29.04,74.99}}},nil,"AH"},
                [1454] = {"Jennabink Powerseam","Tailoring Supplies & Specialty Goods",{[1437]={{8.12,55.84}}},nil,"A"},
                [5103] = {"Grenil Steelfury","Weapon Merchant",{[1455]={{35.98,65.37}}},nil,"A"},
                [945] = {"Rybrad Coldbank","Weaponsmith",{[1426]={{28.66,67.74}}},nil,"A"},
                [3317] = {"Ollanus","Light Armor Merchant",{[1454]={{56.52,73.77}}},nil,"H"},
                [4892] = {"Jensen Farran","Bowyer",{[1445]={{67.95,49.89}}},nil,"A"},
                [1459] = {"Naela Trance","Bowyer",{[1437]={{11.27,58.43}}},{[1437]={{{11.27,58.43},{11.26,58.41},{11.32,58.31},{11.24,58.16},{11.22,58.18},{11.31,58.27},{11.26,58.41}}}},"A"},
                [2482] = {"Zarena Cromwind","Superior Weaponsmith",{[1434]={{28.34,75.46}}},nil,"AH"},
                [1461] = {"Murndan Derth","Gunsmith",{[1437]={{11.33,59.59}}},nil,"A"},
                [1462] = {"Edwina Monzor","Fletcher",{[1437]={{11.12,58.32}}},nil,"A"},
                [13216] = {"Gaelden Hammersmith","Stormpike Supply Officer",{[1459]={{44.28,18.25}}},nil,"A"},
                [2997] = {"Jyn Stonehoof","Weapons Merchant",{[1456]={{41.42,62.36}}},nil,"H"},
                [954] = {"Kat Sampson","Leather Armor Merchant",{[1432]={{82.65,64.11}}},nil,"A"},
                [2999] = {"Taur Stonehoof","Blacksmithing Supplies",{[1456]={{39.82,55.65}}},nil,"H"},
                [956] = {"Dorin Songblade","Armorer",{[1433]={{30.88,46.44}}},nil,"A"},
                [4888] = {"Marie Holdston","Weaponsmith",{[1445]={{64.61,50.07}}},nil,"A"},
                [1469] = {"Vrok Blunderblast","Gunsmith",{[1432]={{35.83,43.46}}},nil,"A"},
                [959] = {"Morley Eberlein","Clothier",{[1429]={{64.69,69.51}}},nil,"A"},
                [1471] = {"Jannos Ironwill","Superior Macecrafter",{[1417]={{45.98,47.72}}},nil,"A"},
                [4886] = {"Hans Weston","Armorer & Shieldsmith",{[1445]={{64.63,50.42}}},nil,"A"},
                [11182] = {"Nixxrak","Heavy Armor Merchant",{[1452]={{61.62,37.87}}},nil,"AH"},
                [11183] = {"Blixxrak","Light Armor Merchant",{[1452]={{61.67,37.83}}},nil,"AH"},
                [11184] = {"Wixxrak","Weaponsmith & Gunsmith",{[1452]={{61.72,38.03}}},nil,"AH"},
                [4597] = {"Samuel Van Brunt","Blacksmithing Supplier",{[1458]={{61.41,30.08}}},nil,"H"},
                [3159] = {"Kzan Thornslash","Weaponsmith",{[1411]={{40.47,68.0}}},nil,"H"},
                [3522] = {"Constance Brisboise","Apprentice Clothier",{[1420]={{52.6,55.77}}},nil,"H"},
                [3539] = {"Ott","Weaponsmith",{[1424]={{60.43,26.18}}},nil,"H"},
                [2679] = {"Wenna Silkbeard","Special Goods Dealer",{[1437]={{25.61,25.8}}},nil,"A"},
                [4183] = {"Naram Longclaw","Weaponsmith",{[1439]={{37.57,40.35}}},nil,"A"},
                [3015] = {"Kuna Thunderhorn","Bowyer & Fletching Goods",{[1456]={{47.0,45.7}}},nil,"H"},
                [11703] = {"Graw Cornerstone","Mail Armor Merchant",{[1427]={{41.5,74.97}}},nil,"A"},
                [3528] = {"Pyrewood Armorer",nil,{[1421]={{46.4,71.88}}},nil,"A"},
                [3018] = {"Hogor Thunderhoof","Guns Merchant",{[1456]={{55.55,57.07}}},nil,"H"},
                [3019] = {"Delgo Ragetotem","Axe Merchant",{[1456]={{54.07,57.23}}},nil,"H"},
                [3020] = {"Etu Ragetotem","Mace & Staff Merchant",{[1456]={{53.19,58.29}}},nil,"H"},
                [3021] = {"Kard Ragetotem","Sword and Dagger Merchant",{[1456]={{52.98,56.63}}},nil,"H"},
                [3022] = {"Sunn Ragetotem","Staff Merchant",{[1456]={{49.63,48.71}}},nil,"H"},
                [3023] = {"Sura Wildmane","War Harness Vendor",{[1456]={{51.59,55.02}}},nil,"H"},
                [980] = {"Grimnal","Mail & Plate Merchant",{[1435]={{45.08,50.43}}},nil,"H"},
                [981] = {"Hartash","Weapon Merchant",{[1435]={{45.67,50.92}}},nil,"H"},
                [3537] = {"Zixil","Merchant Supreme",{[1424]={{61.97,20.45}}},{[1424]={{{61.97,20.45},{61.53,20.09},{61.36,19.98},{59.48,21.16},{58.42,19.55},{55.8,19.73},{55.61,25.75},{55.92,29.34},{56.9,34.01},{57.6,36.46},{54.61,37.65},{54.31,34.29},{55.62,34.75},{55.58,34.72},{54.51,34.0},{54.37,34.68},{54.75,36.83},{53.86,38.14},{51.64,39.41},{50.8,43.17},{51.07,45.43},{51.33,46.62},{50.85,49.25},{51.1,51.17},{50.91,51.9},{50.5,52.72},{50.28,56.77},{49.99,57.07},{50.28,56.77},{50.5,52.72},{50.91,51.9},{51.1,51.17},{50.85,49.25},{51.33,46.62},{51.07,45.43},{50.8,43.17},{51.64,39.41},{53.86,38.14},{54.75,36.83},{54.37,34.68},{54.51,34.0},{55.58,34.72},{55.62,34.75},{54.31,34.29},{54.61,37.65},{57.6,36.46},{56.9,34.01},{55.92,29.34},{55.61,25.75},{55.8,19.73},{58.42,19.55},{59.48,21.16},{61.36,19.98},{61.53,20.09},{61.99,20.58}}}},"AH"},
                [4560] = {"Walter Ellingson","Heavy Armor Merchant",{[1458]={{62.34,38.67}}},nil,"H"},
                [984] = {"Thralosh","Cloth & Leather Armor Merchant",{[1435]={{45.06,51.4}}},nil,"H"},
                [4558] = {"Lauren Newcomb","Light Armor Merchant",{[1458]={{63.83,37.97}}},nil,"H"},
                [4557] = {"Louis Warren","Weapons Merchant",{[1458]={{61.15,40.88}}},nil,"H"},
                [4556] = {"Gordon Wendham","Weapons Merchant",{[1458]={{61.49,41.79}}},nil,"H"},
                [3543] = {"Robert Aebischer","Superior Armorsmith",{[1424]={{51.21,56.98}}},nil,"A"},
                [4187] = {"Harlon Thornguard","Armorer & Shieldsmith",{[1439]={{37.05,41.34}}},nil,"A"},
                [4184] = {"Geenia Sunshadow","Speciality Dress Maker",{[1450]={{52.0,32.89}}},nil,"AH"},
                [4569] = {"Charles Seaton","Blade Merchant",{[1458]={{77.08,49.4}}},nil,"H"},
                [4570] = {"Sydney Upton","Staff Merchant",{[1458]={{69.46,27.44}}},nil,"H"},
                [2843] = {"Jutak","Blade Trader",{[1434]={{27.46,77.55}}},nil,"AH"},
                [4043] = {"Galthuk","Two-Handed Weapons Merchant",{[1454]={{82.29,18.86}}},nil,"H"},
                [3591] = {"Freja Nightwing","Leather Armor Merchant",{[1438]={{58.99,39.64}}},nil,"A"},
                [3552] = {"Alexandre Lefevre","Leather Armor Merchant",{[1421]={{44.6,39.11}}},nil,"H"},
                [3553] = {"Sebastian Meloche","Armorer",{[1421]={{43.33,41.35}}},nil,"H"},
                [3554] = {"Andrea Boynton","Clothier",{[1421]={{44.8,39.24}}},nil,"H"},
                [3590] = {"Janna Brightmoon","Clothier",{[1438]={{59.46,41.05}}},nil,"A"},
                [3589] = {"Keina","Bowyer",{[1438]={{59.31,41.09}}},nil,"A"},
                [3588] = {"Khardan Proudblade","Weaponsmith",{[1438]={{58.72,39.67}}},nil,"A"},
                [4580] = {"Lucille Castleton","Robe Vendor",{[1458]={{71.18,29.59}}},nil,"H"},
                [3536] = {"Kris Legace","Freewheeling Tradeswoman",{[1424]={{80.14,38.89}}},nil,"AH"},
                [8159] = {"Worb Strongstitch","Light Armor Merchant",{[1444]={{74.71,42.58}}},nil,"H"},
                [3532] = {"Pyrewood Leatherworker",nil,{[1421]={{43.95,74.1}}},nil,"A"},
                [8161] = {"Harggan","Blacksmithing Supplies",{[1425]={{13.42,44.14}}},nil,"A"},
                [3360] = {"Koru","Mace & Staves Vendor",{[1454]={{81.48,18.74}}},nil,"H"},
                [3053] = {"Synge","Gun Merchant",{[1441]={{80.4,77.01}}},nil,"AH"},
                [3359] = {"Kiro","War Harness Maker",{[1454]={{73.26,42.25}}},nil,"H"},
                [3356] = {"Sumi","Blacksmithing Supplier",{[1454]={{82.6,23.96}}},nil,"H"},
                [3343] = {"Grelkor","Blacksmithing Supplies",{[1459]={{49.68,82.46}}},nil,"H"},
                [3331] = {"Kareth","Blade Merchant",{[1454]={{45.65,55.96}}},nil,"H"},
                [5102] = {"Dolman Steelfury","Weapon Merchant",{[1455]={{35.8,65.72}}},nil,"A"},
                [4592] = {"Nathaniel Steenwick","Thrown Weapons Merchant",{[1458]={{77.49,49.63}}},nil,"H"},
                [3000] = {"Gibbert","Weapon Merchant",{[1449]={{44.1,7.19}}},nil,"AH"},
                [2847] = {"Jansen Underwood","Blacksmithing Supplies",{[1434]={{29.07,75.48}}},nil,"AH"},
                [5106] = {"Bromiir Ormsen","Heavy Armor Merchant",{[1455]={{31.72,58.27}}},nil,"A"},
                [4085] = {"Nizzik","Venture Armor Salesman",{[1442]={{62.7,40.18}}},nil,"AH"},
                [4086] = {"Veenix","Venture Co. Merchant",{[1442]={{58.22,51.74}}},nil,"AH"},
                [2483] = {"Jaquilina Dramet","Superior Axecrafter",{[1434]={{35.75,10.66}}},nil,"AH"},
                [1407] = {"Sranda","Light Armor & Weapons Merchant",{[1418]={{2.91,47.25}}},nil,"H"},

                -- Two Handed Weapon Merchant
                [8398] = {"Ohanko","Two Handed Weapon Merchant",{[1456]={{52.89,57.49}}},nil,"H"},
                [1333] = {"Gerik Koen","Two Handed Weapon Merchant",{[1453]={{68.92,42.67}}},nil,"A"},
                [4180] = {"Ealyshia Dewwhisper","Two Handed Weapon Merchant",{[1457]={{60.6,72.09}}},nil,"A"},

                -- Cloth Armor Merchant
                [2849] = {"Qixdi Goodstitch","Cloth Armor and Accessories",{[1434]={{28.15,77.56}}},nil,"AH"},
                [3092] = {"Tagain","Cloth Armor Merchant",{[1456]={{43.44,44.34}}},nil,"H"},
                [5155] = {"Ingrys Stonebrow","Cloth Armor Merchant",{[1455]={{38.25,5.15}}},nil,"A"},
                [8358] = {"Hewa","Cloth Armor Merchant",{[1456]={{45.58,56.6}}},nil,"H"},
                [5821] = {"Sheldon Von Croy","Cloth Armor Merchant",{[1458]={{70.36,28.92}}},nil,"H"},
                [1291] = {"Carla Granger","Cloth Armor Merchant",{[1453]={{54.73,56.03}}},nil,"A"},
                [10293] = {"Dulciea Frostmoon","Cloth Armor Merchant",{[1444]={{30.79,43.15}}},nil,"A"},
                [4188] = {"Illyanie","Cloth Armor Merchant",{[1442]={{35.59,7.35}}},nil,"A"},
                [4175] = {"Vinasia","Cloth Armor Merchant",{[1457]={{60.67,72.48}}},nil,"A"},
                -- SoD Exclusive
                [240633] = {"Smith","Blacksmithing Supplies",{[1423]={{98.60, 77.00}}},nil,"AH"},
                [242954] = {"Anvil","Repair",{[1423]={{99.57,77.84}}},nil,"AH"},
                [240248] = {"Bryon Steelblade","Repair, Weekly & T3.5",{[1423]={{98.48,84.14}}},nil,"AH"},
            }
        },
        ["BATTLEMASTER"] = {
            icon = POI_ICONS.BATTLEMASTER,
            type = POI_TYPES.NPC,
            nodes = {
                [15102] = {"Silverwing Emissary",nil,{[1453]={{62.78,32.37},{62.85,32.54},{54.16,62.67},{54.27,62.47},{62.38,66.71},{62.21,66.34},{58.88,63.8},{59.06,64.06},{81.28,12.3},{81.45,12.09},{59.95,14.84},{59.71,14.53}},[1657]={{80.2,40.69},{80.21,40.5},{55.66,45.58},{56.01,45.6},{55.57,36.09},{56.04,35.96},{42.63,39.13},{42.9,39.52},{71.72,39.28},{72.11,39.03},{37.4,72.44},{37.17,72.85}},[1537]={{58.97,81.84},{58.72,82.98},{17.05,65.8},{17.54,65.84},{27.53,88.04},{26.95,87.89},{34.41,21.13},{34.34,21.65},{69.88,88.06},{69.3,88.67},{57.93,50.72},{57.61,51.2}}},nil,"A"},
                [15105] = {"Warsong Emissary",nil,{[1497]={{54.45,96.04},{54.14,95.71},{66.14,55.75},{65.79,55.52},{58.08,44.4},{58.09,43.96},{73.85,43.82},{73.62,44.48},{72.16,38.21},{71.96,38.31}},[1456]={{50.97,34.52},{51.23,34.74},{43.91,56.84},{44.26,57.16},{36.23,61.5},{36.48,61.19},{55.44,75.83},{55.41,76.35},{27.07,28.62},{26.82,28.94},{57.74,77.82},{57.75,78.2},{57.87,76.85},{57.52,76.87}},[1637]={{73.21,35.99},{73.54,36.02},{20.41,56.67},{20.3,56.27},{47.36,65.0},{47.51,64.81},{50.27,65.56},{50.51,65.75},{74.3,34.16},{74.33,34.37},{52.32,73.35},{51.88,73.35}}},nil,"H"},
                [14982] = {"Lylandris","Warsong Gulch Battlemaster",{[1455]={{70.7,88.96}}},nil,"A"},
                [2804] = {"Kurden Bloodclaw","Warsong Gulch Battlemaster",{[1458]={{54.18,96.07}}},nil,"H"},
                [3890] = {"Brakgul Deathbringer","Warsong Gulch Battlemaster",{[1454]={{79.39,30.3}}},nil,"H"},
                [14981] = {"Elfarran","Warsong Gulch Battlemaster",{[1453]={{79.01,19.61}}},nil,"A"},
                [10360] = {"Kergul Bloodaxe","Warsong Gulch Battlemaster",{[1456]={{56.78,76.45}}},nil,"H"},
                [2302] = {"Aethalas","Warsong Gulch Battlemaster",{[1457]={{59.04,36.94}}},nil,"A"},
                
                [14990] = {"Defilers Emissary",nil,{[1497]={{54.45,96.04},{54.14,95.71},{66.14,55.75},{65.79,55.52},{58.08,44.4},{58.09,43.96},{73.85,43.82},{73.62,44.48},{72.16,38.21},{71.96,38.31}},[1456]={{26.82,28.94},{27.07,28.62},{55.41,76.35},{55.44,75.83},{36.48,61.19},{36.23,61.5},{50.97,34.52},{51.23,34.74},{43.91,56.82},{44.26,57.16},{57.74,77.82},{57.75,78.2},{57.87,76.85},{57.52,76.87}},[1637]={{73.21,35.99},{73.54,36.02},{20.41,56.67},{20.3,56.27},{47.36,65.0},{47.51,64.81},{50.27,65.56},{50.51,65.75},{74.3,34.16},{74.33,34.37},{52.32,73.35},{51.88,73.35}}},nil,"H"},
                [14991] = {"League of Arathor Emissary",nil,{[1455]={{57.61,51.2},{57.93,50.72},{69.3,88.67},{69.88,88.06},{34.34,21.65},{34.4,21.1},{26.95,87.89},{27.53,88.04},{17.54,65.84},{17.05,65.8},{58.72,82.98},{58.97,81.84}},[1657]={{37.17,72.85},{37.4,72.44},{72.11,39.03},{71.72,39.28},{42.63,39.13},{42.9,39.52},{56.04,35.96},{55.57,36.09},{56.01,45.6},{55.66,45.58},{80.21,40.5},{80.2,40.69}},[1519]={{59.72,14.54},{59.95,14.84},{81.45,12.09},{81.28,12.3},{59.06,64.06},{58.88,63.8},{62.21,66.34},{62.38,66.71},{54.27,62.47},{54.16,62.67},{62.85,32.54},{62.78,32.37}}},nil,"A"},
                [15006] = {"Deze Snowbane","Arathi Basin Battlemaster",{[1454]={{79.58,29.04}}},nil,"H"},
                [15008] = {"Lady Hoteshem","Arathi Basin Battlemaster",{[1453]={{78.28,15.8}}},nil,"A"},
                [907] = {"Keras Wolfheart","Arathi Basin Battlemaster",{[1457]={{58.02,37.29}}},nil,"A"},
                [857] = {"Donal Osgood","Arathi Basin Battlemaster",{[1455]={{69.92,88.95}}},nil,"A"},
                [15007] = {"Sir Malory Wheeler","Arathi Basin Battlemaster",{[1458]={{61.35,93.03}}},nil,"H"},
                [12198] = {"Martin Lindsey","Arathi Basin Battlemaster",{[1456]={{28.69,20.86}}},nil,"H"},
                
                [15103] = {"Stormpike Emissary",nil,{[1453]={{62.78,32.37},{62.85,32.54},{54.16,62.67},{54.27,62.47},{62.38,66.71},{62.21,66.34},{58.88,63.8},{59.06,64.06},{81.28,12.29},{81.44,12.1},{59.95,14.84},{59.71,14.53}},[1657]={{80.2,40.69},{80.21,40.5},{56.01,45.6},{55.66,45.58},{55.57,36.09},{56.04,35.96},{37.4,72.44},{37.17,72.85},{42.63,39.13},{42.9,39.54},{71.72,39.28},{72.11,39.03}},[1537]={{58.97,81.84},{58.72,82.98},{17.05,65.8},{17.54,65.84},{27.53,88.04},{26.95,87.89},{34.4,21.1},{34.34,21.65},{69.88,88.06},{69.3,88.67},{57.93,50.72},{57.61,51.2}}},nil,"A"},
                [15106] = {"Frostwolf Emissary",nil,{[1497]={{71.96,38.31},{72.16,38.21},{73.62,44.48},{73.85,43.82},{58.09,43.96},{58.08,44.4},{65.79,55.52},{66.14,55.75},{54.14,95.71},{54.45,96.04}},[1456]={{57.52,76.87},{57.87,76.85},{57.75,78.2},{57.74,77.82},{26.82,28.94},{27.07,28.62},{55.41,76.35},{55.44,75.83},{36.48,61.19},{36.23,61.5},{50.97,34.52},{51.23,34.74},{43.91,56.82},{44.26,57.16}},[1637]={{74.33,34.37},{74.3,34.16},{73.21,35.99},{73.54,36.02},{20.41,56.67},{20.3,56.27},{47.36,65.0},{47.51,64.81},{50.27,65.56},{50.51,65.75},{52.32,73.35},{51.88,73.35}}},nil,"H"},
                [14942] = {"Kartra Bloodsnarl","Alterac Valley Battlemaster",{[1454]={{78.94,31.32}}},nil,"H"},
                [7410] = {"Thelman Slatefist","Alterac Valley Battlemaster",{[1453]={{77.23,16.25}}},nil,"A"},
                [5118] = {"Brogun Stoneshield","Alterac Valley Battlemaster",{[1457]={{58.07,44.57}}},nil,"A"},
                [347] = {"Grizzle Halfmane","Alterac Valley Battlemaster",{[1458]={{56.13,85.3}}},nil,"H"},
                [7427] = {"Taim Ragetotem","Alterac Valley Battlemaster",{[1456]={{56.96,76.52}}},nil,"H"},
                [12197] = {"Glordrum Steelbeard","Alterac Valley Battlemaster",{[1455]={{69.85,90.38}}},nil,"A"},
            }
        },
        ["FLIGHTMASTER"] = {
            icon = POI_ICONS.FLIGHTMASTER,
            type = POI_TYPES.NPC,
            nodes = {
                [16227] = {"Bragok","Flight Master",{[1413]={{63.08,37.16}}},nil,"AH"},
                [10583] = {"Gryfe","Flight Master",{[1449]={{45.23,5.83}}},nil,"AH"},

                [15177] = {"Cloud Skydancer","Hippogryph Master",{[1451]={{50.58,34.45}}},nil,"A"},
                [8019] = {"Fyldren Moonfeather","Hippogryph Master",{[1444]={{30.24,43.25}}},nil,"A"},
                [12578] = {"Mishellena","Hippogryph Master",{[1448]={{62.49,24.24}}},nil,"A"},
                [3838] = {"Vesprystus","Hippogryph Master",{[1438]={{58.4,94.02}}},nil,"A"},
                [3841] = {"Caylais Moonfeather","Hippogryph Master",{[1439]={{36.34,45.58}}},nil,"A"},
                [4319] = {"Thyssiana","Hippogryph Master",{[1444]={{89.5,45.85}}},nil,"A"},
                [12577] = {"Jarrodenus","Hippogryph Master",{[1447]={{11.9,77.59}}},nil,"A"},
                [10897] = {"Sindrayl","Hippogryph Master",{[1450]={{48.1,67.34}}},nil,"A"},
                [4267] = {"Daelyshia","Hippogryph Master",{[1440]={{34.41,47.99}}},nil,"A"},
                [11138] = {"Maethrya","Hippogryph Master",{[1452]={{62.33,36.61}}},nil,"A"},
                [6706] = {"Baritanas Skyriver","Hippogryph Master",{[1443]={{64.66,10.54}}},nil,"A"},
                [4407] = {"Teloren","Hippogryph Master",{[1442]={{36.44,7.18}}},nil,"A"},
                [4551] = {"Michael Garrett","Bat Handler",{[1458]={{63.25,48.56}}},nil,"H"},
                [2389] = {"Zarise","Bat Handler",{[1424]={{60.14,18.62}}},nil,"H"},
                [2226] = {"Karos Razok","Bat Handler",{[1421]={{45.62,42.6}}},nil,"H"},
                [12636] = {"Georgia","Bat Handler",{[1423]={{80.22,57.01}}},nil,"H"},

                [1387] = {"Thysta","Wind Rider Master",{[1434]={{32.54,29.35}}},nil,"H"},
                [15178] = {"Runk Windtamer","Wind Rider Master",{[1451]={{48.68,36.67}}},nil,"H"},
                [12616] = {"Vhulgra","Wind Rider Master",{[1440]={{73.18,61.59}}},nil,"H"},
                [13177] = {"Vahgruk","Wind Rider Master",{[1428]={{65.69,24.22}}},nil,"H"},
                [7824] = {"Bulkrek Ragefist","Wind Rider Master",{[1446]={{51.6,25.44}}},nil,"H"},
                [12740] = {"Faustron","Wind Rider Master",{[1450]={{32.09,66.61}}},nil,"H"},
                [2851] = {"Urda","Wind Rider Master",{[1417]={{73.02,32.7}}},nil,"H"},
                [2858] = {"Gringer","Wind Rider Master",{[1434]={{26.87,77.1}}},nil,"H"},
                [2861] = {"Gorrik","Wind Rider Master",{[1418]={{3.99,44.78}}},nil,"H"},
                [4312] = {"Tharm","Wind Rider Master",{[1442]={{45.12,59.84}}},nil,"H"},
                [3305] = {"Grisha","Wind Rider Master",{[1427]={{34.84,30.87}}},nil,"H"},
                [4314] = {"Gorkas","Wind Rider Master",{[1425]={{81.7,81.76}}},nil,"H"},
                [4317] = {"Nyse","Wind Rider Master",{[1441]={{45.14,49.11}}},nil,"H"},
                [2995] = {"Tal","Wind Rider Master",{[1456]={{47.0,49.83}}},nil,"H"},
                [8020] = {"Shyn","Wind Rider Master",{[1444]={{75.45,44.36}}},nil,"H"},
                [6026] = {"Breyk","Wind Rider Master",{[1435]={{46.07,54.83}}},nil,"H"},
                [8610] = {"Kroum","Wind Rider Master",{[1447]={{21.96,49.62}}},nil,"H"},
                [3615] = {"Devrak","Wind Rider Master",{[1413]={{51.5,30.34}}},nil,"H"},
                [10378] = {"Omusa Thunderhorn","Wind Rider Master",{[1413]={{44.45,59.15}}},nil,"H"},
                [6726] = {"Thalon","Wind Rider Master",{[1443]={{21.6,74.13}}},nil,"H"},
                [11139] = {"Yugrek","Wind Rider Master",{[1452]={{60.47,36.3}}},nil,"H"},
                [11899] = {"Shardi","Wind Rider Master",{[1445]={{35.56,31.88}}},nil,"H"},
                [11900] = {"Brakkar","Wind Rider Master",{[1448]={{34.44,53.96}}},nil,"H"},
                [11901] = {"Andruk","Wind Rider Master",{[1440]={{12.24,33.8}}},nil,"H"},
                [3310] = {"Doras","Wind Rider Master",{[1454]={{45.12,63.89}}},nil,"H"},
                [2835] = {"Cedrik Prose","Gryphon Master",{[1417]={{45.73,46.1}}},nil,"A"},
                [4321] = {"Baldruc","Gryphon Master",{[1445]={{67.48,51.3}}},nil,"A"},
                [7823] = {"Bera Stonehammer","Gryphon Master",{[1446]={{51.01,29.34}}},nil,"A"},
                [12617] = {"Khaelyn Steelwing","Gryphon Master",{[1423]={{81.64,59.28}}},nil,"A"},
                [2409] = {"Felicia Maline","Gryphon Master",{[1431]={{77.49,44.29}}},nil,"A"},
                [8018] = {"Guthrum Thunderfist","Gryphon Master",{[1425]={{11.07,46.15}}},nil,"A"},
                [523] = {"Thor","Gryphon Master",{[1436]={{56.55,52.64}}},nil,"A"},
                [12596] = {"Bibilfaz Featherwhistle","Gryphon Master",{[1422]={{42.92,85.06}}},nil,"A"},
                [2859] = {"Gyll","Gryphon Master",{[1434]={{27.53,77.79}}},nil,"A"},
                [8609] = {"Alexandra Constantine","Gryphon Master",{[1419]={{65.54,24.34}}},nil,"A"},
                [2299] = {"Borgus Stoutarm","Gryphon Master",{[1428]={{84.33,68.33}}},nil,"A"},
                [352] = {"Dungar Longdrink","Gryphon Master",{[1453]={{66.27,62.13}}},nil,"A"},
                [2432] = {"Darla Harris","Gryphon Master",{[1424]={{49.34,52.27}}},nil,"A"},
                [2941] = {"Lanie Reed","Gryphon Master",{[1427]={{37.94,30.86}}},nil,"A"},
                [931] = {"Ariena Stormfeather","Gryphon Master",{[1433]={{30.59,59.41}}},nil,"A"},
                [1571] = {"Shellei Brondir","Gryphon Master",{[1437]={{9.49,59.69}}},nil,"A"},
                [1572] = {"Thorgrum Borrelson","Gryphon Master",{[1432]={{33.94,50.95}}},nil,"A"},
                [1573] = {"Gryth Thurden","Gryphon Master",{[1455]={{55.5,47.74}}},nil,"A"},
            }
        },
        ["SPIRITHEALER"] = {
            mMapScale = 0.6,
            wMapScale = 0.8,
            icon = POI_ICONS.SPIRITHEALER,
            type = POI_TYPES.NPC,
            nodes = {
                [13116] = {"Alliance Spirit Guide",nil,{[3277]={{42.49,27.7}},[3358]={{39.13,26.33},{51.12,41.93},{60.66,57.68},{37.12,62.62},{61.0,25.7},{32.92,12.91}},[1459]={{41.0,15.66},{50.86,14.49},{53.75,35.82},{41.3,43.99},{51.6,57.23},{48.01,77.02},{49.9,91.38},{53.63,7.52}}},nil,"A"},
                [13117] = {"Horde Spirit Guide",nil,{[3277]={{57.09,78.21}},[3358]={{39.13,26.33},{51.12,41.93},{60.66,57.68},{37.12,62.62},{61.0,25.7},{69.02,67.79}},[1459]={{41.0,15.66},{50.86,14.49},{53.75,35.82},{41.3,43.99},{51.6,57.23},{48.01,77.02},{49.9,91.38},{56.65,67.4}}},nil,"H"},
                [6491] = {"Spirit Healer",nil,{[1638]={{56.69,19.11}},[1]={{54.38,39.23},{47.31,54.61},{29.98,69.53}},[3]={{8.44,55.32},{56.66,23.69}},[4]={{51.07,12.06}},[8]={{50.31,62.4}},[10]={{19.99,49.21},{75.09,59.02}},[11]={{11.01,43.79},{49.34,41.76}},[12]={{83.63,69.76},{39.48,60.55},{49.68,42.53}},[14]={{57.22,73.26},{44.17,69.43},{53.49,44.47},{47.37,17.88}},[15]={{46.62,57.08},{63.62,42.42},{39.49,31.45}},[331]={{80.69,58.39},{40.49,52.76}},[17]={{45.31,60.96},{60.22,39.75},{50.7,32.6}},[1657]={{77.67,25.92}},[85]={{82.0,69.64},{30.8,64.9},{56.22,49.42},{78.97,40.98}},[215]={{42.63,78.13},{46.52,55.48}},[405]={{50.41,62.91}},[406]={{36.44,75.24},{40.27,5.58},{57.53,61.34}},[33]={{30.36,73.28},{38.38,8.97}},[36]={{42.93,38.0}},[1423]={{37.85,70.15},{39.15,93.74},{80.44,65.25},{47.27,44.89}},[38]={{32.56,46.99}},[40]={{51.71,49.67}},[41]={{39.99,74.18}},[357]={{31.83,48.2},{54.82,48.05},{72.97,44.51}},[44]={{20.78,56.56}},[45]={{48.84,55.61}},[46]={{64.13,24.06}},[47]={{73.06,68.25},{16.94,44.51}},[1497]={{68.17,9.14}},[490]={{50.0,56.03},{45.3,7.6},{80.33,50.28}},[51]={{35.5,22.79}},[493]={{62.2,70.07}},[141]={{56.22,63.29},{58.71,42.33}},[1377]={{28.16,87.08},{47.22,37.27},{81.17,20.82}},[618]={{61.46,35.41}},[148]={{43.55,92.38},{41.81,36.57}},[361]={{56.76,87.04},{49.51,31.05}},[16]={{14.02,78.62},{54.31,71.49},{70.38,16.07}},[400]={{68.67,53.3},{30.56,23.02}},[28]={{44.97,85.97},{65.83,74.24}},[130]={{44.15,42.52}},[440]={{49.35,59.05},{53.9,28.8}},[267]={{51.83,52.55},{64.46,19.69}}},nil,"AH"},
            }
        },
        ["INNKEEPER"] = {
            icon = POI_ICONS.INNKEEPER,
            type = POI_TYPES.NPC,
            nodes = {
                [6741] = {"Innkeeper Norman","Innkeeper",{[1458]={{67.74,37.89}}},nil,"H"},
                [16256] = {"Jessica Chambers","Innkeeper",{[1423]={{81.63,58.08}}},{[1423]={{{81.63,58.08},{81.63,58.08},{81.52,58.09},{81.52,58.09}}}},"AH"},
                [6807] = {"Innkeeper Skindle","Innkeeper",{[1434]={{27.04,77.31}}},nil,"AH"},
                [5111] = {"Innkeeper Firebrew","Innkeeper",{[1455]={{18.15,51.45}}},nil,"A"},
                [1464] = {"Innkeeper Helbrek","Innkeeper",{[1437]={{10.7,60.95}}},nil,"A"},
                [5688] = {"Innkeeper Renee","Innkeeper",{[1420]={{61.71,52.05}}},nil,"H"},
                [2352] = {"Innkeeper Anderson","Innkeeper",{[1424]={{51.17,58.93}}},nil,"A"},
                [16458] = {"Innkeeper Faralia","Innkeeper",{[1442]={{35.79,5.74}}},nil,"A"},
                [5814] = {"Innkeeper Thulbek","Innkeeper",{[1434]={{31.49,29.75}}},nil,"H"},
                [6747] = {"Innkeeper Kauth","Innkeeper",{[1412]={{46.62,61.09}}},nil,"H"},
                [6791] = {"Innkeeper Wiley","Innkeeper",{[1413]={{62.05,39.41}}},nil,"AH"},
                [3934] = {"Innkeeper Boorand Plainswind","Innkeeper",{[1413]={{51.99,29.89}}},nil,"H"},
                [11116] = {"Innkeeper Abeqwa","Innkeeper",{[1441]={{46.07,51.52}}},nil,"H"},
                [11118] = {"Innkeeper Vizzie","Innkeeper",{[1452]={{61.36,38.83}}},nil,"AH"},
                [11106] = {"Innkeeper Sikewa","Innkeeper",{[1443]={{24.09,68.21}}},nil,"H"},
                [11103] = {"Innkeeper Lyshaerya","Innkeeper",{[1443]={{66.27,6.55}}},nil,"A"},
                [9501] = {"Innkeeper Adegwa","Innkeeper",{[1417]={{73.84,32.46}}},nil,"H"},
                [6272] = {"Innkeeper Janene","Innkeeper",{[1445]={{66.59,45.22}}},nil,"A"},
                [9087] = {"Bashana Runetotem",nil,{[1456]={{71.06,34.19}}},nil,"H"},
                [12196] = {"Innkeeper Kaylisk","Innkeeper",{[1440]={{73.99,60.65}}},nil,"H"},
                [7744] = {"Innkeeper Thulfram","Innkeeper",{[1425]={{14.15,41.57}}},{[1425]={{{14.15,41.57},{13.66,41.73},{13.4,41.83},{13.15,41.91},{13.4,41.83},{13.66,41.73}}}},"A"},
                [6790] = {"Innkeeper Trelayne","Innkeeper",{[1431]={{73.87,44.41}}},nil,"A"},
                [7736] = {"Innkeeper Shyria","Innkeeper",{[1444]={{30.97,43.49}}},nil,"A"},
                [6928] = {"Innkeeper Grosk","Innkeeper",{[1411]={{51.51,41.64}}},nil,"H"},
                [6930] = {"Innkeeper Karakul","Innkeeper",{[1435]={{45.16,56.66}}},nil,"H"},
                [295] = {"Innkeeper Farley","Innkeeper",{[1429]={{43.77,65.8}}},nil,"A"},
                [7714] = {"Innkeeper Byula","Innkeeper",{[1413]={{45.58,59.04}}},nil,"H"},
                [7731] = {"Innkeeper Jayka","Innkeeper",{[1442]={{47.47,62.13}}},nil,"H"},
                [6929] = {"Innkeeper Gryshka","Innkeeper",{[1454]={{54.1,68.41}}},nil,"H"},
                [7733] = {"Innkeeper Fizzgrimble","Innkeeper",{[1446]={{52.51,27.91}}},nil,"AH"},
                [8931] = {"Innkeeper Heather","Innkeeper",{[1436]={{52.86,53.71}}},nil,"A"},
                [6727] = {"Innkeeper Brianna","Innkeeper",{[1433]={{27.01,44.82}}},nil,"A"},
                [1247] = {"Innkeeper Belm","Innkeeper",{[1426]={{47.38,52.52}}},nil,"A"},
                [7737] = {"Innkeeper Greul","Innkeeper",{[1444]={{74.8,45.18}}},nil,"H"},
                [14731] = {"Lard","Innkeeper",{[1425]={{78.14,81.38}}},nil,"H"},
                [6746] = {"Innkeeper Pala","Innkeeper",{[1456]={{45.81,64.71}}},nil,"H"},
                [15174] = {"Calandrath","Innkeeper",{[1451]={{51.89,39.16}}},nil,"AH"},
                [6735] = {"Innkeeper Saelienne","Innkeeper",{[1457]={{67.42,15.65}}},nil,"A"},
                [6734] = {"Innkeeper Hearthstove","Innkeeper",{[1432]={{35.53,48.4}}},nil,"A"},
                [2388] = {"Innkeeper Shay","Innkeeper",{[1424]={{62.78,19.03}}},nil,"H"},
                [6736] = {"Innkeeper Keldamyr","Innkeeper",{[1438]={{55.62,59.79}}},nil,"A"},
                [6737] = {"Innkeeper Shaussiy","Innkeeper",{[1439]={{37.04,44.13}}},nil,"A"},
                [6738] = {"Innkeeper Kimlya","Innkeeper",{[1440]={{36.99,49.22}}},nil,"A"},
                [6739] = {"Innkeeper Bates","Innkeeper",{[1421]={{43.18,41.28}}},nil,"H"},
                [6740] = {"Innkeeper Allison","Innkeeper",{[1453]={{52.62,65.7}}},nil,"A"},
            }
        },
        ["MOUNT"] = {
            icon = POI_ICONS.STABLEMASTER,
            type = POI_TYPES.VENDOR,
            nodes = {
                [3685] = {"Harb Clawhoof","Kodo Mounts",{[1412]={{47.49,58.6}}},nil,"H"},
                [3690] = {"Kar Stormsinger","Kodo Riding Instructor",{[1412]={{47.65,58.47}}},nil,"H"},

                [4885] = {"Gregor MacVince","Horse Breeder",{[1445]={{65.19,51.5}}},nil,"A"},
                [1460] = {"Unger Statforth","Horse Breeder",{[1437]={{8.57,54.34}}},nil,"A"},
                [2357] = {"Merideth Carlson","Horse Breeder",{[1424]={{52.19,55.48}}},nil,"A"},
                [384] = {"Katie Hunter","Horse Breeder",{[1429]={{84.15,65.49}}},nil,"A"},
                [4732] = {"Randal Hunter","Horse Riding Instructor",{[1429]={{84.32,64.87}}},nil,"A"},

                [4731] = {"Zachariah Post","Undead Horse Merchant",{[1420]={{59.87,52.68}}},nil,"H"},
                [4773] = {"Velma Warnam","Undead Horse Riding Instructor",{[1420]={{60.08,52.57}}},nil,"H"},

                [4730] = {"Lelanai","Saber Handler",{[1457]={{38.28,15.36}}},nil,"A"},
                [4753] = {"Jartsam","Nightsaber Riding Instructor",{[1457]={{38.69,15.84}}},nil,"A"},
                [10618] = {"Rivern Frostwind","Wintersaber Trainers",{[1452]={{49.94,9.84}}},nil,"A"},

                [7952] = {"Zjolnir","Raptor Handler",{[1411]={{55.23,75.65}}},nil,"H"},
                [7953] = {"Braagor","Raptor Riding Instructor",{[1411]={{55.2, 75.6}}},nil,"H"},

                [7955] = {"Milli Featherwhistle","Mechanostrider Merchant",{[1426]={{49.13,47.95}}},nil,"A"},
                [7954] = {"Binjy Featherwhistle","Mechanostrider Pilot",{[1426]={{49.15,48.13}}},nil,"A"},

                [1261] = {"Veron Amberstill","Ram Breeder",{[1426]={{63.47,50.56}}},{[1426]={{{63.47,50.56},{63.46,50.63}}}},"A"},
                [4772] = {"Ultham Ironhorn","Ram Riding Instructor",{[1426]={{63.94,50.1},{63.67,50.14}}},nil,"A"},
                
                [4752] = {"Kildar","Wolf Riding Instructor",{[1454]={{69.41,13.1}}},nil,"H"},
                [3362] = {"Ogunaro Wolfrunner","Kennel Master",{[1454]={{69.38,12.24}}},nil,"H"},
            }
        },
        ["STABLEMASTER"] = {
            icon = POI_ICONS.STABLEMASTER,
            type = POI_TYPES.NPC,
            nodes = {
                [10085] = {"Jaelysia","Stable Master",{[1439]={{37.4,44.28}}},nil,"A"},
                [6749] = {"Erma","Stable Master",{[1429]={{42.85,65.95}}},nil,"A"},
                [13617] = {"Stormpike Stable Master","Stable Master",{[1459]={{42.55,16.82}}},nil,"A"},
                [15131] = {"Qeeju","Stable Master",{[1440]={{73.38,61.02}}},nil,"H"},
                [11104] = {"Shelgrayn","Stable Master",{[1443]={{65.61,7.84}}},nil,"A"},
                [11105] = {"Aboda","Stable Master",{[1443]={{24.9,68.67}}},nil,"H"},
                [9976] = {"Tharlidun","Stable Master",{[1417]={{73.93,33.13}}},nil,"H"},
                [9977] = {"Sylista","Stable Master",{[1453]={{29.59,51.22}}},nil,"A"},
                [9978] = {"Wesley","Stable Master",{[1424]={{50.42,58.8}}},nil,"A"},
                [9979] = {"Sarah Goode","Stable Master",{[1421]={{43.45,41.18}}},nil,"H"},
                [9980] = {"Shelby Stoneflint","Stable Master",{[1426]={{47.01,52.66}}},nil,"A"},
                [9981] = {"Sikwa","Stable Master",{[1413]={{51.74,29.66}}},nil,"H"},
                [9982] = {"Penny","Stable Master",{[1433]={{26.8,46.56}}},nil,"A"},
                [9983] = {"Kelsuwa","Stable Master",{[1413]={{45.3,58.66}}},nil,"H"},
                [9984] = {"Ulbrek Firehand","Stable Master",{[1455]={{69.3,83.58}}},nil,"A"},
                [9985] = {"Laziphus","Stable Master",{[1446]={{52.25,28.0}}},nil,"AH"},
                [9986] = {"Shyrka Wolfrunner","Stable Master",{[1444]={{74.49,43.27}}},nil,"H"},
                [10050] = {"Seikwa","Stable Master",{[1412]={{46.76,60.36}}},nil,"H"},
                [10051] = {"Seriadne","Stable Master",{[1438]={{56.63,59.62}}},nil,"A"},
                [9989] = {"Lina Hearthstove","Stable Master",{[1432]={{34.64,48.09}}},nil,"A"},
                [10053] = {"Anya Maulray","Stable Master",{[1458]={{67.42,37.59}}},nil,"H"},
                [10054] = {"Bulrug","Stable Master",{[1456]={{45.09,60.23}}},nil,"H"},
                [10055] = {"Morganus","Stable Master",{[1420]={{60.03,52.16}}},nil,"H"},
                [10056] = {"Alassin","Stable Master",{[1457]={{39.27,10.05}}},nil,"A"},
                [10057] = {"Theodore Mont Claire","Stable Master",{[1424]={{62.31,19.7}}},nil,"H"},
                [10058] = {"Greth","Stable Master",{[1418]={{3.66,47.58}}},nil,"H"},
                [10059] = {"Antarius","Stable Master",{[1444]={{31.47,43.15}}},nil,"A"},
                [10060] = {"Grimestack","Stable Master",{[1434]={{27.29,77.22}}},nil,"AH"},
                [10061] = {"Killium Bouldertoe","Stable Master",{[1425]={{14.41,45.22}}},nil,"A"},
                [10062] = {"Steven Black","Stable Master",{[1431]={{74.02,46.11}}},nil,"A"},
                [10063] = {"Reggifuz","Stable Master",{[1413]={{62.18,39.21}}},nil,"AH"},
                [16094] = {"Durik","Stable Master",{[1434]={{31.87,29.5}}},nil,"H"},
                [10046] = {"Bethaine Flinthammer","Stable Master",{[1437]={{10.53,59.73}}},nil,"A"},
                [13616] = {"Frostwolf Stable Master","Stable Master",{[1459]={{57.16,82.45}}},nil,"H"},
                [11119] = {"Azzleby","Stable Master",{[1452]={{60.39,37.92}}},nil,"AH"},
                [11117] = {"Awenasa","Stable Master",{[1441]={{45.77,51.07}}},nil,"H"},
                [11069] = {"Jenova Stoneshield","Stable Master",{[1453]={{61.47,17.17}}},nil,"A"},
                [10052] = {"Maluressian","Stable Master",{[1440]={{36.51,50.36}}},nil,"A"},
                [10049] = {"Hekkru","Stable Master",{[1435]={{45.56,55.15}}},nil,"H"},
                [10048] = {"Gereck","Stable Master",{[1442]={{47.93,61.39}}},nil,"H"},
                [10047] = {"Michael","Stable Master",{[1445]={{66.01,45.5}}},nil,"A"},
                [14741] = {"Huntsman Markhor","Stable Master",{[1425]={{79.16,79.53}}},nil,"H"},
                [10045] = {"Kirk Maxwell","Stable Master",{[1436]={{52.94,53.07}}},nil,"A"},
            }
        },
        ["VENDOR"] = {
            icon = POI_ICONS.VENDOR,
            type = POI_TYPES.NPC,
            nodes = {
                -- Miscellaneous Vendors
                [4230] = {"Yldan","Bag Merchant",{[1457]={{65.27,53.03}}},nil,"A"},
                [3487] = {"Kalyimah Stormcloud","Bags & Sacks",{[1413]={{52.26,32.02}}},nil,"H"},
                [8305] = {"Kixxle","Potions & Herbs",{[1437]={{50.2,37.74}}},nil,"AH"},
                [15350] = {"Horde Warbringer",nil,{[1638]={{56.05,76.69}},[36]={{63.09,59.87}},[17]={{46.71,8.68}},[1454]={{80.68,30.51}},[1497]={{58.3,97.88}},[45]={{73.5,29.13}}},nil,"H"},
                [15351] = {"Alliance Brigadier General",nil,{[36]={{39.29,82.33}},[331]={{61.94,83.83}},[45]={{45.65,45.75}},[1453]={{79.55,18.17}},[1657]={{58.02,34.52}},[1537]={{70.41,91.12}}},nil,"A"},
                [11287] = {"Baker Masterson",nil,{[1422]={{69.55,79.7}}},nil,"AH"},
                [16543] = {"Garon Hutchins",nil,{[1451]={{52.51,38.65}}},nil,"AH"},
                [2264] = {"Hillsbrad Tailor",nil,{[1424]={{36.82,44.26},{36.76,44.48}}},nil,"A"},
                [3291] = {"Greishan Ironstove","Traveling Merchant",{[1432]={{25.55,11.83}}},{[1432]={{{25.56,10.49},{25.6,12.71},{25.69,13.73},{25.88,14.71},{25.9,15.33},{25.97,16.04},{25.99,18.7},{26.13,20.53},{26.68,22.96},{26.96,23.68},{28.05,25.67},{28.44,27.16},{28.95,28.85},{29.64,30.47},{30.22,32.73},{30.39,33.87},{30.43,34.62},{30.83,37.18},{31.07,38.76},{31.26,39.28},{31.85,40.32},{32.16,41.03},{32.21,41.35},{32.17,42.61},{32.01,43.31},{31.67,44.06},{31.38,45.3},{31.29,46.77},{31.39,47.77},{31.65,48.32},{32.0,48.97},{32.19,49.7},{32.38,49.85},{32.61,49.79},{33.12,49.33},{33.96,48.13},{34.82,47.08},{35.53,46.77},{36.0,46.42},{36.27,46.3},{36.91,46.18},{37.32,45.68},{37.4,44.56},{37.23,42.93},{36.76,41.95},{37.15,42.94},{37.35,44.53},{37.26,45.6},{36.89,46.11},{36.14,46.31},{35.46,46.71},{35.01,46.85},{34.51,47.3},{33.18,49.22},{32.34,50.21},{32.27,51.4},{31.87,53.56},{31.5,56.13},{31.31,57.02},{30.6,58.02},{29.9,58.99},{29.39,60.31},{29.18,60.85},{28.73,62.37},{28.15,64.72},{28.0,65.4},{27.65,65.84},{26.95,66.15},{25.61,67.42},{25.09,67.7},{24.72,68.13},{23.66,69.68},{22.89,70.76},{21.82,72.41},{21.4,72.95},{20.61,74.75},{20.48,75.04},{21.0,75.84},{21.76,76.77},{22.33,77.26},{22.79,77.12},{23.17,76.68},{23.4,76.25},{22.99,76.93},{22.36,77.31},{22.05,77.15},{21.34,76.2},{20.62,75.25},{20.68,74.66},{21.4,73.14},{22.15,72.1},{23.0,70.87},{24.01,69.42},{24.85,68.14},{25.44,67.55},{25.85,67.35},{26.72,66.46},{27.47,65.99},{27.88,65.74},{28.14,65.35},{28.48,63.79},{28.83,62.45},{29.36,60.76},{29.9,59.03},{30.91,57.8},{31.39,57.09},{31.56,56.74},{31.89,54.41},{32.15,52.67},{32.29,50.88},{32.28,49.7},{32.15,49.19},{31.87,48.55},{31.5,47.72},{31.36,46.73},{31.45,45.49},{31.63,44.67},{31.91,43.78},{32.17,43.17},{32.32,42.24},{32.34,41.06},{31.93,40.34},{31.48,39.49},{31.15,38.59},{30.97,37.55},{30.74,35.81},{30.46,33.67},{30.07,31.46},{29.4,29.65},{28.93,28.4},{28.28,26.15},{28.03,25.37},{27.22,23.91},{26.9,23.33},{26.43,21.6},{26.18,19.78},{26.16,18.06},{26.14,15.83},{26.05,15.01},{25.76,13.72},{25.62,11.67}}}},"A"},
                [233] = {"Farmer Saldean",nil,{[1436]={{56.04,31.23}}},nil,"A"},
                [1263] = {"Yarlyn Amberstill",nil,{[1426]={{63.12,50.88}}},nil,"A"},
                [4453] = {"Wizzle Brassbolts",nil,{[1441]={{78.14,77.12}}},nil,"AH"},
                [3443] = {"Grub",nil,{[1413]={{55.31,31.79}}},nil,"H"},
                [7564] = {"Marin Noggenfogger",nil,{[1446]={{51.81,28.66}}},nil,"AH"},
                [6548] = {"Magus Tirth",nil,{[1441]={{78.29,75.7}}},nil,"AH"},
                [3489] = {"Zargh","Butcher",{[1413]={{52.62,29.84}}},nil,"H"},
                [5169] = {"Tynnus Venomsprout","Shady Dealer",{[1455]={{52.95,13.71}}},nil,"A"},
                [3134] = {"Kzixx","Rare Goods",{[1431]={{81.82,19.77}}},nil,"AH"},
                [7231] = {"Kelgruk Bloodaxe","Weapon Crafter",{[1454]={{81.95,18.02}}},nil,"H"},
                [4171] = {"Merelyssa","Blade Merchant",{[1457]={{65.36,59.74}}},nil,"A"},
                [4172] = {"Anadyia","Robe Vendor",{[1457]={{55.68,89.97}}},nil,"A"},
                [4177] = {"Melea","Mail Armor Merchant",{[1457]={{57.13,76.99}}},nil,"A"},
                [4185] = {"Shaldyn","Clothier",{[1439]={{38.2,40.42}}},nil,"A"},
                [3180] = {"Dark Iron Entrepreneur","Speciality Goods",{[1437]={{46.55,18.37}}},nil,"AH"},
                [14437] = {"Gorzeeki Wildeyes",nil,{[1428]={{12.44,31.63}}},nil,"AH"},
                [4232] = {"Glorandiir","Axe Merchant",{[1457]={{64.2,59.08}}},nil,"A"},
                [4233] = {"Mythidan","Mace & Staff Merchant",{[1457]={{65.19,60.72}}},nil,"A"},
                [4234] = {"Andrus","Staff Merchant",{[1457]={{56.13,88.91}}},nil,"A"},
                [4235] = {"Turian","Thrown Weapons Merchant",{[1457]={{62.67,65.59}}},nil,"A"},
                [4236] = {"Cyridan","Leather Armor Merchant",{[1457]={{52.9,80.5}}},nil,"A"},
                [8401] = {"Halpa","Prairie Dog Vendor",{[1456]={{61.98,58.37}}},nil,"H"},
                [2265] = {"Hillsbrad Apprentice Blacksmith",nil,{[1424]={{32.62,45.14},{31.15,46.72},{31.89,46.72},{31.96,45.83},{31.17,43.9},{31.61,44.48}}},nil,"A"},
                [1243] = {"Hegnar Rumbleshot","Gunsmith",{[1426]={{40.68,65.13}}},nil,"A"},
                [1304] = {"Darian Singh","Fireworks Vendor",{[1453]={{29.42,67.83}}},nil,"A"},
                [11536] = {"Quartermaster Miranda Breechlock","The Argent Dawn",{[1423]={{81.62,60.0}}},nil,"AH"},
                [1307] = {"Charys Yserian","Arcane Trinkets Vendor",{[1453]={{32.19,79.9}}},nil,"A"},
                [1316] = {"Adair Gilroy","Librarian",{[1453]={{41.56,65.45}}},nil,"A"},
                [1325] = {"Jasper Fel","Shady Dealer",{[1453]={{78.32,58.98}}},nil,"A"},
                [11557] = {"Meilosh",nil,{[1448]={{65.69,2.81}}},nil,nil},
                [14637] = {"Zorbin Fandazzle",nil,{[1444]={{44.81,43.42}}},nil,"AH"},
                [2383] = {"Lindea Rabonne","Tackle and Bait",{[1424]={{50.63,60.95}}},nil,"A"},
                [14754] = {"Kelm Hargunth","Warsong Supply Officer",{[1413]={{46.65,8.38}}},nil,"H"},
                [1456] = {"Kersok Prond","Tradesman",{[1437]={{10.38,60.62}}},nil,"A"},
                [2393] = {"Christoph Jeffcoat","Tradesman",{[1424]={{62.29,19.04}}},nil,"H"},
                [1457] = {"Samor Festivus","Shady Dealer",{[1437]={{10.5,60.2}}},nil,"A"},
                [1465] = {"Drac Roughcut","Tradesman",{[1432]={{35.57,49.15}}},nil,"A"},
                [5569] = {"Fizzlebang Booms","Fireworks Vendor",{[1455]={{73.56,53.38},{73.57,53.35}}},nil,"A"},
                [4581] = {"Salazar Bloch","Book Dealer",{[1458]={{77.42,39.26}}},nil,"H"},
                [491] = {"Quartermaster Lewis","Quartermaster",{[1436]={{57.0,47.17}}},nil,"A"},
                [5611] = {"Barkeep Morag",nil,{[1454]={{54.64,67.68}}},nil,"H"},
                [3577] = {"Dalaran Brewmaster",nil,{[1421]={{62.61,65.05}}},nil,"AH"},
                [3578] = {"Dalaran Miner",nil,{[1421]={{62.52,62.65}}},nil,"AH"},
                [15864] = {"Valadar Starsong","Coin of Ancestry Collector",{[1450]={{53.65,35.26}}},nil,"AH"},
                [7683] = {"Alessandro Luca","Blue Moon Odds and Ends",{[1458]={{58.61,54.68}}},nil,"H"},
                [14846] = {"Lhara","Darkmoon Faire Exotic Goods",{[1412]={{36.4,38.03}},[12]={{41.2,69.9}}},nil,"AH"},
                [12807] = {"Greshka","Demon Master",{[1435]={{48.58,55.27}}},nil,"H"},
                [14860] = {"Flik",nil,{[1412]={{36.54,37.09}},[12]={{41.76,68.1}}},{[12]={{{41.78,68.04},{42.05,67.42},{42.56,66.06},{42.38,65.56},{42.21,65.53},{42.07,67.29},{41.97,68.98},{41.95,69.74},{41.6,69.96},{41.34,69.43},{41.72,68.63}}}},"AH"},
                [15909] = {"Fariel Starsong","Coin of Ancestry Collector",{[1450]={{53.79,35.32}}},nil,"AH"},
                [2622] = {"Sly Garrett","Shady Goods",{[1434]={{28.41,76.83}}},nil,"AH"},
                [7772] = {"Kalin Windflight",nil,{[1444]={{49.46,19.83}}},nil,"AH"},
                [7775] = {"Gregan Brewspewer",nil,{[1444]={{45.12,25.57}}},nil,"AH"},
                [2663] = {"Narkk","Pirate Supplies",{[1434]={{28.13,74.42}}},nil,"AH"},
                [1650] = {"Terry Palin","Lumberjack",{[1429]={{82.95,63.31}}},nil,"A"},
                [1678] = {"Vernon Hale","Bait and Tackle Supplier",{[1433]={{27.49,47.83}}},nil,"A"},
                [1692] = {"Golorn Frostbeard","Tradesman",{[1426]={{46.67,53.49}}},{[1426]={{{46.66,53.57},{46.72,53.74},{46.77,53.72},{46.72,53.74},{46.68,53.7},{46.66,53.57},{46.67,53.49},{46.67,53.49}}}},"A"},
                [15011] = {"Wagner Hammerstrike",nil,{[1426]={{52.6,36.03}}},nil,"A"},
                [7879] = {"Quintis Jonespyre",nil,{[1444]={{32.45,43.79}}},nil,"A"},
                [734] = {"Corporal Bluth","Camp Trader",{[1434]={{37.96,2.99}}},nil,"A"},
                [2805] = {"Deneb Walker","Scrolls & Potions",{[1417]={{26.97,58.83}}},nil,"A"},
                [2810] = {"Hammon Karwn","Superior Tradesman",{[1417]={{46.49,47.41}}},nil,"A"},
                [777] = {"Amy Davenport","Tradeswoman",{[1433]={{29.13,47.32}}},{[1433]={{{29.13,47.34},{28.96,47.43},{29.17,47.46}}}},"A"},
                [2838] = {"Crazk Sparks","Fireworks Merchant",{[1434]={{28.36,76.66}}},nil,"AH"},
                [11038] = {"Caretaker Alen","The Argent Dawn",{[1423]={{79.55,63.86}}},{[1423]={{{79.54,63.77},{79.54,63.77},{79.63,63.64},{79.73,63.55},{79.73,63.7},{79.73,63.7},{79.72,63.5},{79.57,63.47},{79.53,63.8},{79.52,64.03},{79.59,64.28},{79.59,64.28},{79.5,64.1}}}},"AH"},
                [15898] = {"Lunar Festival Vendor",nil,{[1638]={{70.56,27.83}},[1450]={{36.58,58.1},{36.3,58.53}},[1519]={{22.78,51.19}},[1537]={{29.92,14.21}},[1657]={{31.56,13.69}},[1637]={{41.27,32.36}},[1497]={{66.45,36.02}}},nil,"AH"},
                [11056] = {"Alchemist Arbington",nil,{[1422]={{42.66,83.77}}},nil,"A"},
                [15293] = {"Aendel Windspear",nil,{[1451]={{62.57,49.79}}},nil,"AH"},
                [15165] = {"Haughty Modiste","Fashion Designer",{[1446]={{66.56,22.27}}},nil,"AH"},
                [15127] = {"Samuel Hawke","League of Arathor Supply Officer",{[1417]={{45.97,45.21}}},nil,"A"},
                [15126] = {"Rutherford Twing","Defilers Supply Officer",{[1417]={{73.37,29.67}}},nil,"H"},
                [15012] = {"Javnir Nashak",nil,{[1411]={{46.1,13.77}}},nil,"H"},
                [14847] = {"Professor Thaddeus Paleo","Darkmoon Faire Cards & Exotic Goods",{[1412]={{36.43,38.13}},[12]={{41.25,70.05}}},nil,"AH"},
                [844] = {"Antonio Perelli","Traveling Salesman",{[1429]={{78.12,72.96}}},{[10]={{{7.58,63.81},{8.97,63.76},{10.43,63.3},{12.32,62.45},{13.79,61.68},{15.64,61.25},{17.55,61.03},{19.04,60.9},{19.98,60.54},{21.29,60.25},{23.1,59.64},{23.81,59.24},{24.7,58.62},{25.76,57.77},{26.33,57.6},{27.56,57.61},{28.1,57.7},{29.29,58.3},{30.75,59.22},{31.98,59.75},{33.39,60.38},{35.16,61.37},{35.72,61.64},{36.43,61.99},{36.89,62.19},{37.62,62.5},{38.85,62.96},{40.15,63.32},{41.27,63.74},{42.29,64.32},{43.13,64.85},{43.51,65.08},{44.59,65.91},{45.87,65.99},{46.87,66.02},{47.89,66.27},{49.46,66.36},{50.21,66.52},{51.13,66.86},{52.03,67.5},{52.94,68.52},{54.01,69.03},{54.86,68.91},{56.01,67.74},{57.31,66.63},{58.29,65.66},{59.96,63.2},{61.06,62.14},{62.06,61.41},{63.19,60.73},{64.71,60.07},{65.64,60.09},{66.72,60.6},{67.66,60.61},{68.99,60.53},{69.8,60.18},{70.58,59.57},{72.18,59.1},{73.05,58.21},{74.0,56.41},{74.79,54.36},{75.06,53.01},{75.03,51.89},{74.6,49.24},{74.48,48.2},{74.16,47.64},{73.79,47.01},{73.83,46.12},{73.82,45.56},{74.1,45.46},{74.02,45.14},{74.01,44.87},{73.98,44.5},{73.99,44.74},{74.02,45.13},{74.1,45.47},{73.81,45.53},{73.84,46.2},{74.46,46.71},{74.87,46.43},{74.81,44.55},{74.62,41.72},{74.16,40.05},{73.72,39.47},{72.85,38.8},{72.45,38.11},{72.22,37.3},{72.2,35.42},{72.52,33.95},{73.29,32.47},{73.6,31.21},{73.65,29.15},{73.58,28.21},{73.33,26.72},{73.39,25.07},{73.78,23.81},{74.39,22.91},{74.99,22.64},{75.87,21.84},{77.77,20.66},{78.57,20.46},{79.63,20.34},{81.62,19.99},{82.41,20.35},{83.38,20.41},{85.32,20.31},{85.97,19.86},{86.66,19.39},{87.64,18.05},{88.22,16.99},{89.45,16.02},{90.83,14.91},{92.62,13.04},{93.69,11.62}}},[1429]={{{75.43,72.31},{73.05,72.7},{70.32,70.94},{69.33,71.31},{66.65,74.11},{63.98,73.72},{61.62,72.76},{58.03,71.46},{54.25,72.77},{50.24,71.5},{48.12,69.92},{45.09,68.97},{42.59,67.23}},{{78.12,72.96},{77.74,72.69},{76.81,72.41},{75.5,72.34},{74.77,72.44},{74.61,72.46},{74.33,72.5},{73.94,72.56},{73.21,72.66},{72.63,72.64},{72.1,72.3},{70.94,71.1},{69.88,70.89},{69.14,71.28},{68.01,72.79},{67.15,73.8},{66.81,73.93},{65.6,74.1},{65.12,74.06},{63.69,73.6},{63.16,73.35},{62.73,72.97},{62.21,72.7},{61.09,72.63},{60.01,72.41},{59.05,71.71},{58.39,71.29},{57.81,71.31},{56.61,72.18},{55.87,72.48},{54.33,72.64},{53.02,72.56},{52.59,72.43},{51.94,72.21},{50.98,71.78},{50.3,71.46},{48.93,70.57},{48.27,69.84},{47.69,69.6},{46.31,69.48},{45.29,69.12},{44.01,68.14},{42.97,67.43},{42.58,66.99},{42.42,66.47},{42.48,65.84},{42.71,65.63},{43.19,65.71},{43.18,66.0},{43.36,66.01},{43.5,66.02},{43.68,66.06},{43.79,65.97},{43.7,66.07},{43.55,66.03},{43.37,66.01},{43.2,66.04},{43.19,65.71},{42.77,65.62},{42.5,65.74},{42.25,66.75},{41.94,66.87},{40.88,66.63},{39.68,66.63},{38.97,66.76},{38.11,67.54},{37.45,68.45},{37.11,69.26},{37.02,71.75},{36.86,73.91},{36.44,74.95},{35.87,75.82},{34.98,76.79},{33.95,77.64},{32.61,78.34},{31.53,78.51},{30.28,78.19},{29.42,78.02},{28.71,77.92},{28.26,77.85},{26.85,77.76},{25.17,78.48},{24.65,78.63},{23.84,78.52},{23.27,78.31},{22.46,78.39},{21.4,79.01},{20.79,79.7}},{{93.51,72.14},{92.08,72.68},{91.25,73.5},{90.77,73.72},{89.65,73.68},{88.87,73.74},{87.58,73.92},{86.86,74.06},{85.73,73.89},{84.64,74.29},{83.64,74.46},{82.64,74.25},{81.64,73.88},{80.77,73.85},{79.74,73.95},{79.13,73.88},{78.69,73.58}}},[44]={{{6.45,91.31},{7.13,89.38},{8.36,88.2},{9.73,86.45},{10.67,83.94},{11.99,81.53},{13.32,80.11},{14.2,79.05},{14.78,77.43},{15.14,75.0},{15.49,72.45},{16.65,70.55},{17.81,69.21},{18.9,69.37},{20.14,70.12},{22.41,69.9},{22.77,70.33},{23.12,72.11},{23.71,72.86},{24.48,72.39},{26.19,69.78},{27.21,68.91},{28.69,68.02},{29.19,67.58},{29.73,67.01},{31.14,64.97},{31.7,63.55},{32.38,59.53},{32.45,57.32},{32.59,54.72},{32.71,51.66},{32.8,49.44},{32.6,48.38},{31.44,48.11},{30.97,48.1},{29.37,48.02},{29.12,47.63},{28.58,47.62},{27.8,46.98},{26.83,46.97},{26.62,46.42},{26.62,45.8},{27.0,45.75},{26.93,45.34},{26.92,44.99},{26.91,44.55},{26.85,44.27},{26.91,44.53},{26.92,44.92},{26.92,45.32},{26.99,45.74},{26.62,45.8},{26.61,46.56},{27.01,47.15},{27.97,47.21},{28.58,47.64},{30.92,48.13},{31.96,48.21},{32.57,48.32},{32.84,49.4},{32.71,51.66},{32.56,54.49},{32.41,57.24},{32.24,59.48},{31.85,62.22},{31.13,64.68},{29.52,67.02},{29.23,67.33},{28.75,67.73},{26.65,69.11},{25.76,70.19},{24.21,72.49},{23.73,72.59},{23.39,72.21},{22.85,70.28},{22.39,69.73},{20.17,69.91},{18.57,69.12},{17.65,69.09},{15.7,69.67},{13.14,71.06},{11.98,71.79},{10.34,71.95},{8.61,71.62},{7.88,71.55}}},[40]={{{62.31,17.29},{61.55,18.25},{60.85,18.85},{60.31,19.24},{59.63,20.16},{59.19,20.27},{58.67,20.31},{58.09,21.01},{58.0,21.53},{57.99,22.11},{57.69,23.25},{57.54,23.59},{57.49,24.27},{57.64,25.03},{58.01,26.25},{58.15,27.09},{57.86,27.79},{57.5,28.53},{57.39,29.05},{57.5,29.64},{57.7,30.11},{57.9,30.64},{57.91,31.66},{58.01,33.13},{58.01,34.0},{57.79,35.09},{57.8,36.41},{57.94,36.9},{58.39,37.48},{58.64,38.0},{58.54,38.94},{58.23,39.93},{58.16,41.85},{57.81,42.94},{57.82,43.5},{58.09,44.22},{58.94,45.95},{58.92,47.55},{58.51,49.25},{58.19,50.24},{57.54,52.37},{57.43,53.04},{57.61,53.65},{57.59,53.85},{57.33,53.96},{56.86,54.04},{56.51,53.74},{55.75,52.9},{55.0,52.79},{54.68,52.43},{53.49,52.87},{53.08,53.22},{53.0,53.36},{52.9,53.53},{53.0,53.36},{53.05,53.27},{53.51,52.87},{54.63,52.44},{55.02,52.81},{55.72,52.92},{56.74,54.04},{56.61,56.06},{56.93,57.3},{57.12,57.96},{57.13,60.31},{57.37,61.3},{57.45,62.73},{57.49,63.67},{57.67,64.41},{57.81,65.1},{58.46,65.98},{59.1,66.36},{59.43,66.37},{59.78,65.9},{60.29,64.99},{60.81,64.84},{61.43,65.04},{61.89,65.42},{62.45,65.51},{62.92,65.37},{63.51,64.91},{64.27,63.96},{64.87,63.37},{67.08,62.85}}}},"A"},
                [14845] = {"Stamp Thunderhorn","Darkmoon Faire Food Vendor",{[1412]={{36.6,38.3}},[12]={{42.16,70.2}}},nil,"AH"},
                [14753] = {"Illiyana Moonblaze","Silverwing Supply Officer",{[1440]={{61.49,83.86}}},nil,"A"},
                [14624] = {"Master Smith Burninate","The Thorium Brotherhood",{[1427]={{38.8,28.51}}},nil,"AH"},
                [14450] = {"Orphan Matron Nightingale",nil,{[1453]={{47.35,38.19}}},nil,"A"},
                [12919] = {"Nat Pagle",nil,{[1445]={{58.61,60.06}}},nil,"AH"},
                [12384] = {"Augustus the Touched",nil,{[1423]={{14.45,33.48}}},nil,"AH"},
                [15197] = {"Darkcaller Yanka",nil,{[1420]={{55.58,69.9}}},nil,"H"},
                [12097] = {"Frostwolf Quartermaster",nil,{[1459]={{46.62,84.22}}},nil,"H"},
                [12096] = {"Stormpike Quartermaster",nil,{[1459]={{43.12,17.62}}},nil,"A"},
                [11555] = {"Gorn One Eye",nil,{[1448]={{65.18,2.68}}},nil,nil},
                [3969] = {"Fahran Silentblade","Tools & Supplies",{[1440]={{36.49,49.46}}},nil,"A"},
                [9087] = {"Bashana Runetotem",nil,{[1456]={{71.06,34.19}}},nil,"H"},
                [11057] = {"Apothecary Dithers",nil,{[1420]={{83.28,69.23}}},nil,"H"},
                [10216] = {"Gubber Blump",nil,{[1439]={{36.1,44.93}}},nil,"A"},
                [8666] = {"Lil Timmy","Boy with kittens",{[1453]={{34.86,40.45}}},{[1453]={{{35.84,41.76},{38.2,46.72},{38.89,48.01},{40.46,49.71},{41.73,50.14},{43.36,48.92},{44.16,49.09},{45.49,50.4},{46.49,50.1},{47.39,49.21},{47.83,49.03},{48.28,49.16},{48.98,50.27},{49.59,51.39},{49.87,51.58},{50.23,51.51},{51.26,50.49},{51.92,50.07},{53.85,48.55},{55.08,47.93},{56.65,47.55},{57.9,47.9},{58.48,48.31},{58.76,49.25},{60.45,51.72},{60.78,51.93},{61.21,52.02},{62.31,50.63},{63.79,48.83},{63.92,48.32},{63.29,46.86},{62.04,44.74},{61.82,44.11},{61.6,42.49},{61.81,41.6},{64.26,37.67},{64.4,37.15},{64.35,36.82},{63.62,35.74},{62.73,34.19},{62.3,33.8},{61.58,33.85},{59.94,34.2},{58.67,33.68},{57.32,32.22},{56.87,30.84},{54.79,26.69},{54.22,26.21},{53.76,26.22},{52.95,27.06},{51.93,28.22},{51.59,29.06},{52.44,31.55},{50.01,34.83},{49.71,35.74},{49.91,37.01},{49.85,37.71},{46.07,42.27},{45.56,42.12},{44.25,39.85},{43.04,39.98},{41.3,40.65},{37.85,44.54},{37.35,44.71},{35.68,41.41}}}},"A"},
                [8665] = {"Shylenai","Owl Trainer",{[1457]={{69.64,45.9}}},nil,"A"},
                [8403] = {"Jeremiah Payson","Cockroach Vendor",{[1458]={{67.6,44.16}}},nil,"H"},
                [4981] = {"Ben Trias","Apprentice of Cheese",{[1453]={{60.33,63.42}}},nil,"A"},
                [6367] = {"Donni Anthania","Crazy Cat Lady",{[1429]={{44.22,53.44}}},nil,"A"},
                [955] = {"Sergeant De Vries","Morale Officer",{[1429]={{24.08,73.2}}},nil,"A"},
                [960] = {"Gunder Thornbush","Tradesman",{[1431]={{73.8,45.1}}},nil,"A"},
                [3016] = {"Tand","Basket Weaver",{[1456]={{49.05,34.24}}},nil,"H"},
                [4878] = {"Montarr","Lorekeeper",{[1441]={{45.15,50.79}}},nil,"H"},
                [3362] = {"Ogunaro Wolfrunner","Kennel Master",{[1454]={{69.38,12.24}}},nil,"H"},
                [4083] = {"Jeeda","Apprentice Witch Doctor",{[1442]={{47.61,61.59}}},nil,"H"},
                
                -- Mining Supplies
                [6298] = {"Thelgrum Stonehammer","Mining Supplier",{[1439]={{38.22,41.2}}},nil,"A"},
                [4256] = {"Golnir Bouldertoe","Mining Supplier",{[1455]={{51.52,26.31}}},nil,"A"},
                [3358] = {"Gorina","Mining Supplier",{[1454]={{73.31,26.6}}},nil,"H"},
                [372] = {"Karm Ironquill","Mining Supplies",{[1432]={{37.13,47.16}}},nil,"A"},
                [5514] = {"Brooke Stonebraid","Mining Supplier",{[1453]={{51.02,16.88}}},nil,"A"},
                [4599] = {"Sarah Killian","Mining Supplier",{[1458]={{56.72,36.94}}},nil,"H"},
                [790] = {"Karen Taylor","Mining and Smithing Supplies",{[1433]={{29.9,47.36}}},nil,"A"},
                [11186] = {"Lunnix Sprocketslip","Mining Supplies",{[1452]={{61.79,38.59}}},nil,"AH"},
                [3002] = {"Kurm Stonehoof","Mining Supplier",{[1456]={{34.35,56.56}}},nil,"H"},

                -- Engineering Supplies
                [6777] = {"Zan Shivsproket","Speciality Engineer",{[1416]={{85.95,79.96}}},nil,"AH"},
                [3133] = {"Herble Baubbletump","Engineering and Mining Supplies",{[1431]={{77.99,48.33}}},nil,"A"},
                [3495] = {"Gagsprocket","Engineering Goods",{[1413]={{62.64,36.27}}},nil,"AH"},
                [5175] = {"Gearcutter Cogspinner","Engineering Supplies",{[1455]={{67.84,42.5}}},nil,"A"},
                [3413] = {"Sovik","Engineering Supplies",{[1454]={{75.49,25.36}}},nil,"H"},
                [5519] = {"Billibub Cogspinner","Engineering Supplier",{[1453]={{55.25,7.07}}},nil,"A"},
                [8678] = {"Jubie Gadgetspring","Engineering Supplier",{[1447]={{45.28,90.95}}},nil,"AH"},
                [4587] = {"Elizabeth Van Talen","Engineering Supplier",{[1458]={{75.48,74.34}}},nil,"H"},
                [6730] = {"Jinky Twizzlefixxit","Engineering Supplies",{[1441]={{77.68,77.9}}},nil,"AH"},
                [2682] = {"Fradd Swiftgear","Engineering Supplies",{[1437]={{26.4,25.76}}},nil,"A"},
                [2683] = {"Namdo Bizzfizzle","Engineering Supplies",{[1426]={{21.86,31.86}}},nil,"A"},
                [2684] = {"Rizz Loosebolt","Engineering Supplies",{[1416]={{47.3,35.16}}},nil,"AH"},
                [2685] = {"Mazk Snipeshot","Engineering Supplies",{[1434]={{28.5,75.12}}},nil,"AH"},
                [2687] = {"Gnaz Blunderflame","Engineering Supplies",{[1434]={{50.98,35.21}}},nil,"AH"},
                [2688] = {"Ruppo Zipcoil","Engineering Supplies",{[1425]={{34.33,37.76}}},nil,"AH"},
                [1694] = {"Loslor Rudge","Engineering Supplies",{[1426]={{50.08,49.42}}},nil,"A"},
                [11185] = {"Xizzer Fizzbolt","Engineering Supplies",{[1452]={{60.8,38.6}}},nil,"AH"},
                [8679] = {"Knaz Blunderflame","Engineering Supplies",{[1434]={{51.05,35.23}}},nil,"AH"},

                -- Fishing Supplies
                [8508] = {"Gretta Ganter","Fisherman Supplies",{[1426]={{31.53,44.65}}},nil,"A"},
                [3178] = {"Stuart Fleming","Fisherman",{[1437]={{8.02,58.35}}},nil,"A"},
                [3497] = {"Kilxx","Fisherman",{[1413]={{62.77,38.24}}},nil,"AH"},
                [2834] = {"Myizz Luckycatch","Superior Fisherman",{[1434]={{27.46,77.11}}},nil,"AH"},
                [14740] = {"Katoom the Angler","Fishing Trainer & Supplies",{[1425]={{80.33,81.54}}},nil,"H"},


                -- Herbalism Supplies
                [5138] = {"Gwina Stonebranch","Herbalism Supplier",{[1455]={{55.08,59.51}}},nil,"A"},
                [4216] = {"Chardryn","Herbalism Supplier",{[1457]={{48.52,68.99}}},nil,"A"},
                [1303] = {"Felicia Gump","Herbalism Supplier",{[1453]={{64.19,60.6}}},nil,"A"},
                [5503] = {"Eldraeith","Herbalism Supplier",{[1453]={{46.66,78.65}}},nil,"A"},
                [4615] = {"Katrina Alliestar","Herbalism Supplier",{[1458]={{54.73,48.92}}},nil,"H"},
                [3014] = {"Nida Winterhoof","Herbalism Supplier",{[1456]={{49.57,39.57}}},nil,"H"},


                -- Leatherworking Supplies
                [5128] = {"Bombus Finespindle","Leatherworking Supplies",{[1455]={{39.62,34.49}}},nil,"A"},
                [4225] = {"Saenorion","Leatherworking Supplies",{[1457]={{63.69,22.28}}},nil,"A"},
                [3366] = {"Tamar","Leatherworking Supplies",{[1454]={{63.05,45.53}}},nil,"H"},
                [5565] = {"Jillian Tanner","Leatherworking Supplies",{[1453]={{67.07,49.54}}},nil,"A"},
                [4589] = {"Joseph Moore","Leatherworking Supplies",{[1458]={{70.07,58.44}}},nil,"H"},
                [6731] = {"Harlown Darkweave","Leatherworking Supplies",{[1440]={{18.23,60.04}}},nil,"A"},
                [2697] = {"Clyde Ranthal","Leatherworking Supplies",{[1433]={{89.02,70.87}}},nil,"A"},
                [2698] = {"George Candarte","Leatherworking Supplies",{[1424]={{92.02,38.23}}},nil,"H"},
                [2699] = {"Rikqiz","Leatherworking Supplies",{[1434]={{28.49,76.05}}},nil,"AH"},
                [12943] = {"Werg Thickblade","Leatherworking Supplies",{[1420]={{83.3,69.72}}},nil,"H"},
                [12956] = {"Zannok Hidepiercer","Leatherworking Supplies",{[1451]={{82.0,17.74}}},nil,"AH"},
                [7854] = {"Jangdor Swiftstrider","Leatherworking Supplies",{[1444]={{74.43,42.91}}},nil,"H"},
                [2816] = {"Androd Fadran","Leatherworking Supplies",{[1417]={{45.08,46.83}}},nil,"A"},
                [2819] = {"Tunkk","Leatherworking Supplies",{[1417]={{74.84,34.59}}},nil,"H"},
                [2846] = {"Blixrez Goodstitch","Leatherworking Supplies",{[1434]={{28.25,77.54}}},nil,"AH"},
                [3958] = {"Lardan","Leatherworking Supplies",{[1440]={{34.79,49.84}}},nil,"A"},
                [5944] = {"Yonada","Tailoring & Leatherworking Supplies",{[1413]={{45.01,59.33}}},nil,"H"},
                [5783] = {"Kalldan Felmoon","Specialist Leatherworking Supplies",{[1413]={{45.89,35.7}}},nil,"AH"},
                [8160] = {"Nioma","Leatherworking Supplies",{[1425]={{13.3,43.37}}},nil,"A"},
                
                -- Guild Tabard
                [5188] = {"Garyl","Tabard Vendor",{[1454]={{43.77,74.25}}},nil,"H"},
                [5189] = {"Thrumn","Tabard Vendor",{[1456]={{37.67,63.26}}},nil,"H"},
                [5193] = {"Rebecca Laughlin","Tabard Vendor",{[1453]={{57.26,68.58}}},nil,"A"},
                [5191] = {"Shalumon","Tabard Vendor",{[1457]={{70.4,23.4}}},nil,"A"},
                [5190] = {"Merill Pleasance","Tabard Vendor",{[1458]={{69.33,44.82}}},nil,"H"},
                [5049] = {"Lyesa Steelbrow","Guild Tabard Vendor",{[1455]={{36.31,85.47}}},nil,"A"},
                [5052] = {"Edward Remington","Guild Tabard Designer",{[1458]={{69.81,44.28}}},nil,"H"},
                
                -- Bag Vendor
                [8364] = {"Pakwa","Bag Vendor",{[1456]={{39.31,64.27}}},nil,"H"},
                [1321] = {"Alyssa Griffith","Bag Vendor",{[1453]={{67.22,48.81}}},nil,"A"},
                [3369] = {"Gotri","Bag Vendor",{[1454]={{58.81,52.73}}},nil,"H"},
                [4590] = {"Jonathan Chambers","Bag Vendor",{[1458]={{69.24,61.21}}},nil,"H"},
                [5132] = {"Pithwick","Bag Vendor",{[1455]={{38.02,74.74}}},nil,"A"},
                
                -- Reagents
                [15175] = {"Khur Hornstriker","Reagent Vendor",{[1451]={{48.67,37.0}}},nil,"AH"},
                [4220] = {"Cyroen","Reagent Vendor",{[1457]={{33.85,9.51}}},nil,"A"},
                [8361] = {"Chepi","Reagent Vendor",{[1456]={{36.38,54.85}}},{[1456]={{{36.58,54.95},{36.79,56.2},{37.02,57.61},{37.32,59.21},{37.74,60.98},{38.42,62.07},{39.16,62.83},{39.87,62.87},{40.34,62.29},{40.95,61.47},{41.64,60.54},{42.13,59.62},{42.43,58.64},{42.65,57.85},{42.77,56.68},{42.32,55.79},{41.8,55.06},{41.13,54.09},{40.56,53.28},{40.08,52.64},{39.57,52.14},{38.9,51.62},{38.28,51.22},{37.45,51.71},{37.02,52.35},{36.69,53.05},{36.53,53.82}}}},"H"},
                [1275] = {"Kyra Boucher","Reagent Vendor",{[1453]={{56.13,65.27}}},nil,"A"},
                [1308] = {"Owen Vaughn","Reagent Vendor",{[1453]={{35.88,74.99}}},nil,"A"},
                [1351] = {"Brother Cassius","Reagent Vendor",{[1453]={{43.5,26.97}}},nil,"A"},
                [1463] = {"Falkan Armonis","Reagent Vendor",{[1437]={{8.35,56.47}}},nil,"A"},
                [3562] = {"Alaindia","Reagent Vendor",{[1457]={{38.99,74.25}}},{[1457]={{{38.99,74.25},{40.29,74.37},{41.13,74.65},{41.75,74.94},{42.36,75.36},{43.75,77.11},{48.74,67.87},{43.87,77.04},{43.0,76.09},{41.77,74.96},{41.04,74.52},{39.01,74.26},{37.98,74.42},{37.2,74.68},{36.31,75.1},{35.72,75.57},{34.75,76.86},{34.37,77.4},{29.3,69.0},{34.29,77.36},{35.05,76.45},{35.66,75.77},{36.22,75.15},{37.41,74.53},{38.99,74.29},{38.43,43.95}}}},"A"},
                [3500] = {"Tarhus","Reagent Vendor",{[1444]={{74.64,44.92}}},nil,"H"},
                [4562] = {"Thomas Mordan","Reagent Vendor",{[1458]={{69.69,39.05}}},nil,"H"},
                [3700] = {"Jadenvis Seawatcher","Reagent Vendor",{[1444]={{30.92,42.09}}},nil,"A"},
                [1673] = {"Alyssa Eva","Reagent Vendor",{[1431]={{76.28,45.27}}},nil,"A"},
                [5110] = {"Barim Jurgenstaad","Reagent Vendor",{[1455]={{19.19,56.1}}},nil,"A"},
                [5151] = {"Ginny Longberry","Reagent Vendor",{[1455]={{31.32,27.79}}},nil,"A"},
                [3351] = {"Magenius","Reagents Vendor",{[1454]={{45.74,40.94}}},nil,"H"},
                [3323] = {"Horthus","Reagents Vendor",{[1454]={{45.43,56.55}}},nil,"H"},
                [3335] = {"Hagrus","Reagents Vendor",{[1454]={{45.99,45.68}}},nil,"H"},
                [3970] = {"Llana","Reagent Supplies",{[1440]={{34.98,48.46}}},nil,"A"},
                [4575] = {"Hannah Akeley","Reagent Supplier",{[1458]={{82.78,15.83}}},nil,"H"},
                
                -- Reagents & Poisons
                [5139] = {"Kurdrum Barleybeard","Reagents & Poisons",{[1459]={{42.79,16.56}}},nil,"A"},
                [3542] = {"Jaysin Lanyda","Poisons & Reagents",{[1424]={{50.82,59.02}}},nil,"A"},
                [10364] = {"Yaelika Farclaw","Reagents & Poisons",{[1459]={{48.37,80.32}}},nil,"H"},
                
                -- Poison
                [3090] = {"Gerald Crawley","Poison Supplier",{[1433]={{25.09,41.14}}},nil,"A"},
                [3334] = {"Rekkul","Poison Vendor",{[1454]={{42.09,49.48}}},nil,"H"},
                [1326] = {"Sloan McCoy","Poison Supplier",{[1453]={{76.19,59.99}}},nil,"A"},
                [3551] = {"Patrice Dwyer","Poison Supplies",{[1421]={{42.91,41.81}}},nil,"H"},
                [3561] = {"Kyrai","Poison Vendor",{[1457]={{32.54,19.73}}},nil,"A"},
                [3135] = {"Malissa","Poison Supplier",{[1431]={{79.44,44.33}}},nil,"A"},
                [6779] = {"Smudge Thunderwood","Poison Vendor",{[1416]={{86.12,79.58}}},nil,"AH"},
                [4585] = {"Ezekiel Graves","Poison Vendor",{[1458]={{75.2,51.18}}},nil,"H"},
                [4584] = {"Naram Longclaw","Poison Supplier",{[1458]={{75.48,51.34}}},nil,"H"},
                [5764] = {"Jalane Ayrole","Poison Supplies",{[1458]={{26.18,60.55}}},nil,"H"},
                [7954] = {"Zanara","Poison Supplies",{[1411]={{55.43,75.65}}},nil,"H"},
                
                -- Tailoring Suppliers
                [3091] = {"Franklin Hamar","Tailoring Supplies",{[1433]={{27.18,45.54}}},nil,"A"},
                [3096] = {"Captured Servant of Azora","Specialist Tailoring Supplies",{[1433]={{74.46,79.51}}},nil,"AH"},
                [5154] = {"Poranna Snowbraid","Tailoring Supplies",{[1455]={{42.94,28.31}}},nil,"A"},
                [4168] = {"Elynna","Tailoring Supplies",{[1457]={{64.58,21.58}}},nil,"A"},
                [4189] = {"Valdaron","Tailoring Supplies",{[1439]={{38.15,40.6}}},nil,"A"},
                [1347] = {"Alexandra Bolero","Tailoring Supplies",{[1453]={{43.25,74.08}}},nil,"A"},
                [2394] = {"Mallen Swain","Tailoring Supplies",{[1424]={{61.9,20.98}}},nil,"H"},
                [3485] = {"Wrahk","Tailoring Supplies",{[1413]={{52.25,31.69}}},nil,"H"},
                [6576] = {"Brienna Starglow","Tailoring Supplies",{[1444]={{88.96,45.95}}},nil,"A"},
                [1474] = {"Rann Flamespinner","Tailoring Supplies",{[1432]={{35.95,45.87}}},nil,"A"},
                [4577] = {"Millie Gregorian","Tailoring Supplies",{[1458]={{70.59,30.14}}},nil,"H"},
                [2668] = {"Danielle Zipstitch","Tailoring Supplies",{[1431]={{75.87,45.56}}},nil,"A"},
                [2669] = {"Sheri Zipstitch","Tailoring Supplies",{[1431]={{75.68,45.57}}},nil,"A"},
                [2670] = {"Xizk Goodstitch","Tailoring Supplies",{[1434]={{28.71,76.89}}},nil,"AH"},
                [2672] = {"Cowardly Crosby","Tailoring Supplies",{[1434]={{27.0,82.48}}},nil,"AH"},
                [1672] = {"Lohgan Eva","Tailoring Supplies",{[1431]={{75.71,44.56}}},nil,"A"},
                [7940] = {"Darnall","Tailoring Supplies",{[1450]={{51.47,33.25}}},nil,"AH"},
                [8681] = {"Outfitter Eric","Speciality Tailoring Supplies",{[1455]={{43.37,29.31}}},nil,"A"},
                [6568] = {"Vizzklick","Tailoring Supplies",{[1446]={{51.01,27.36}}},nil,"AH"},
                [3005] = {"Mahu","Leatherworking & Tailoring Supplies",{[1456]={{43.8,45.12}}},nil,"H"},
                [3364] = {"Borya","Tailoring Supplies",{[1454]={{63.08,51.45}}},nil,"H"},
                
                -- Food Vendors
                [4169] = {"Jaeana","Meat Vendor",{[1457]={{64.55,71.66}}},{[1457]={{{64.55,71.66},{65.15,69.08},{65.71,67.0},{66.59,64.89},{67.33,63.24},{67.83,61.59},{68.02,59.82},{67.8,57.5},{66.73,56.29},{65.29,55.51},{63.99,55.09},{62.54,55.13},{62.38,56.78},{62.35,58.23},{62.1,59.87},{61.82,61.54},{61.48,63.4},{60.77,65.5},{60.98,66.79},{61.65,68.1},{62.5,69.32},{63.54,70.57}}}},"A"},
                [6495] = {"Riznek","Drink Vendor",{[1441]={{80.45,76.46}}},nil,"AH"},
                [4963] = {"Mikhail","Bartender",{[1437]={{10.6,60.77}}},nil,"A"},
                [3086] = {"Gretchen Vogel","Waitress",{[1433]={{22.84,44.26}}},nil,"A"},
                [5124] = {"Sognar Cliffbeard","Meat Vendor",{[1455]={{56.56,82.19}}},{[1455]={{{57.01,84.48},{58.71,84.94},{61.0,82.91},{63.42,79.94},{65.75,77.19},{67.79,74.66},{69.26,72.34},{68.9,68.93},{67.26,67.48},{65.88,67.79},{64.1,70.63},{62.2,71.72},{60.66,73.63},{59.49,76.9},{57.61,78.5},{56.56,82.16}}}},"A"},
                [3089] = {"Sherman Femmel","Butcher",{[1433]={{26.73,43.24}}},nil,"A"},
                [4190] = {"Kyndri","Baker",{[1439]={{36.9,44.6}}},nil,"A"},
                [4200] = {"Laird","Fish Vendor",{[1439]={{36.77,44.28}}},nil,"A"},
                [13418] = {"Kaymard Copperpinch","Smokywood Pastures",{[1454]={{53.33,66.49}}},nil,"AH"},
                [8307] = {"Tarban Hearthgrain","Baker",{[1413]={{55.16,32.08}}},nil,"H"},
                [4221] = {"Talaelar","Fish Vendor",{[1457]={{47.47,57.45}}},nil,"A"},
                [13434] = {"Macey Jinglepocket","Smokywood Pastures",{[1455]={{33.6,67.69}}},nil,"AH"},
                [10367] = {"Shrye Ragefist","Food and Drink",{[1459]={{48.53,80.47}}},nil,"H"},
                [14480] = {"Alowicious Czervik","Sweet Treats",{[1454]={{50.65,65.62}}},nil,"H"},
                [14481] = {"Emmithue Smails","Sweet Treats",{[1453]={{53.75,65.33}}},nil,"A"},
                [4255] = {"Brogus Thunderbrew","Food and Drink",{[1459]={{43.05,17.63}}},nil,"A"},
                [3312] = {"Olvia","Meat Vendor",{[1454]={{44.68,70.01}}},nil,"H"},
                [258] = {"Joshua Maclure","Vintner",{[1429]={{42.36,89.38}}},nil,"A"},
                [274] = {"Barkeep Hann","Bartender",{[1431]={{73.66,44.05}}},nil,"A"},
                [277] = {"Roberto Pupellyverbos","Merlot Connoisseur",{[1453]={{52.15,67.75}}},nil,"A"},
                [1301] = {"Julia Gallina","Wine Vendor",{[1453]={{52.02,68.83}}},nil,"A"},
                [1302] = {"Bernard Gump","Florist",{[1453]={{64.06,61.26}}},nil,"A"},
                [1305] = {"Jarel Moor","Bartender",{[1453]={{28.81,75.32}}},nil,"A"},
                [1311] = {"Joachim Brenlow","Bartender",{[1453]={{41.06,90.03}}},nil,"A"},
                [3368] = {"Borstan","Meat Vendor",{[1454]={{57.2,53.32}}},nil,"H"},
                [2364] = {"Neema","Waitress",{[1424]={{51.13,59.24}}},nil,"A"},
                [2365] = {"Bront Coldcleave","Butcher",{[1424]={{48.75,57.2}}},nil,"A"},
                [2366] = {"Barkeep Kelly","Bartender",{[1424]={{51.57,58.57}}},nil,"A"},
                [2397] = {"Derak Nightfall","Cook",{[1424]={{63.09,19.41}}},nil,"H"},
                [340] = {"Kendor Kabonka","Master of Cooking Recipes",{[1453]={{74.69,36.51}}},nil,"A"},
                [6496] = {"Brivelthwerp","Ice Cream Vendor",{[1441]={{77.32,77.02}}},nil,"AH"},
                [3480] = {"Moorane Hearthgrain","Baker",{[1413]={{52.37,30.54}}},nil,"H"},
                [3518] = {"Thomas Miller","Baker",{[1453]={{62.34,61.65}}},{[1453]={{{61.54,60.93},{60.87,59.99},{59.94,59.55},{59.02,57.98},{58.59,56.89},{57.8,55.51},{56.81,53.98},{56.05,53.49},{54.98,53.61},{53.53,54.86},{52.7,55.81},{52.11,56.73},{51.87,58.62},{52.09,59.84},{52.56,61.63},{53.15,63.12},{53.78,64.07},{54.6,63.58},{55.27,62.88},{55.55,62.01},{55.17,60.77},{55.04,60.19},{55.53,59.42},{56.21,59.69},{56.58,61.2},{57.09,62.27},{57.95,63.26},{58.73,64.22},{59.4,65.25},{60.19,66.55},{60.19,67.45},{59.72,68.0},{59.19,68.12},{58.68,67.1},{58.25,65.64},{57.5,63.66},{56.73,62.09},{56.6,61.3},{57.11,60.36},{57.83,59.22},{58.61,58.91},{59.47,59.91},{60.24,60.5},{61.14,61.58},{61.84,61.98},{62.33,61.68}}}},"A"},
                [5570] = {"Bruuk Barleybeard","Bartender",{[1455]={{72.52,76.95}}},nil,"A"},
                [4554] = {"Tawny Grisette","Mushroom Vendor",{[1458]={{65.19,49.84}}},{[1458]={{{66.86,49.85},{68.16,48.89},{69.2,47.29},{69.82,45.64},{69.86,42.5},{69.29,41.06},{67.5,38.46},{65.91,38.18},{64.36,38.78},{62.78,41.0},{62.14,42.71},{62.15,45.72},{63.14,47.82},{64.1,49.3},{65.03,49.84}}}},"H"},
                [465] = {"Barkeep Dobbins","Bartender",{[1429]={{44.0,65.69}}},nil,"A"},
                [3540] = {"Hal McAllister","Fish Merchant",{[1424]={{49.85,62.41}}},nil,"A"},
                [3544] = {"Jason Lemieux","Mushroom Seller",{[1424]={{60.51,19.53}}},{[1424]={{{60.51,19.53},{60.64,19.89},{60.76,20.55},{60.82,20.97},{60.87,21.38},{60.96,21.78},{61.04,22.18},{61.1,22.6},{61.13,22.74},{61.32,23.22},{61.39,23.29},{61.58,23.28},{61.64,23.27},{61.89,23.01},{61.94,22.95},{61.94,22.66},{61.93,22.38},{62.03,21.69},{62.22,21.2},{62.27,20.8},{62.04,20.42},{61.69,20.23},{61.52,20.11},{61.43,20.05},{61.04,20.35},{60.67,20.8},{60.35,21.1},{59.89,21.21},{59.7,21.2},{59.34,21.02},{59.13,20.75},{59.01,20.52},{59.03,20.15},{59.16,19.78},{59.34,19.45},{59.54,19.17},{59.81,19.08},{60.15,19.23}}}},"H"},
                [483] = {"Elaine Trias","Mistress of Cheese",{[1453]={{60.59,63.24}}},nil,"A"},
                [5620] = {"Bartender Wental","Food and Drinks",{[1433]={{26.71,43.91}}},nil,"A"},
                [2664] = {"Kelsey Yance","Cook",{[1434]={{28.23,74.34}}},nil,"AH"},
                [14962] = {"Dillord Copperpinch","Smokywood Pastures",{[1416]={{62.01,58.56}}},nil,"AH"},
                [2814] = {"Narj Deepslice","Butcher",{[1417]={{45.54,47.61}}},nil,"A"},
                [3935] = {"Toddrick","Butcher",{[1429]={{44.24,65.97}}},nil,"A"},
                [4954] = {"Uttnar","Butcher",{[1417]={{74.18,33.96}}},nil,"H"},
                [3959] = {"Nantar","Baker",{[1440]={{37.14,49.9}}},nil,"A"},
                [9099] = {"Sraaz","Pie Vendor",{[1455]={{55.8,35.59}}},{[1455]={{{57.17,38.88},{57.56,41.87},{57.4,46.59},{56.07,50.7},{54.38,53.99},{51.74,56.49},{47.7,57.75},{47.01,56.64},{47.01,49.35},{44.56,46.18},{40.28,45.67},{39.47,43.27},{41.43,36.93},{45.58,31.84},{49.67,31.04},{53.82,32.63},{55.8,35.59}}}},"A"},
                [4571] = {"Morley Bates","Fungus Vendor",{[1458]={{72.93,26.73}}},{[1458]={{{72.51,29.46},{72.92,30.59},{73.25,31.08},{74.85,33.41},{75.25,34.0},{76.18,34.57}},{{77.69,31.53},{77.3,30.35},{76.52,29.15},{76.53,28.65},{77.72,26.91},{78.92,25.19},{79.31,25.35},{80.0,26.27},{81.29,28.19},{82.62,28.61},{83.34,27.77},{84.07,25.64},{82.94,22.64},{81.44,20.89},{80.28,18.87},{78.42,17.74},{77.34,18.48},{76.69,20.3},{77.07,21.4},{77.59,22.49},{78.08,23.4},{78.77,24.49},{78.93,25.13},{77.71,26.82},{76.5,28.72},{76.09,28.43},{75.38,27.54},{74.71,27.68},{72.92,26.75},{72.33,27.61}}},[85]={{{64.25,72.22}}}},"H"},
                [3705] = {"Gahroot","Butcher",{[1413]={{44.74,59.42}}},nil,"H"},
                [4167] = {"Dendrythis","Food & Drink Vendor",{[1457]={{33.62,15.91}}},{[1457]={{{33.62,15.91},{34.46,14.99},{35.24,14.07},{36.54,13.52},{37.07,15.12},{37.57,16.85},{37.78,19.46},{38.6,21.24},{39.85,20.36},{41.58,19.02},{42.92,18.45},{44.2,18.89},{45.12,19.83},{45.72,21.46},{46.26,23.2},{45.53,20.89},{44.88,19.32},{43.27,18.42},{42.04,18.72},{38.67,21.3},{37.93,19.85},{37.46,16.94},{36.65,13.72},{35.32,14.0}}}},"A"},
                [4192] = {"Taldan","Drink Vendor",{[1439]={{36.83,43.91}}},nil,"A"},
                [4195] = {"Tiyani","Food & Drink Vendor",{[1439]={{43.69,76.63}}},nil,"A"},
                [4266] = {"Danlyia","Food & Drink Vendor",{[1438]={{55.38,57.2}}},nil,"A"},
                [1237] = {"Kazan Mogosh","Food & Drink Merchant",{[1426]={{68.61,54.64}}},nil,"A"},
                [3298] = {"Gabrielle Chase","Food & Drink",{[1428]={{84.24,67.78}}},nil,"A"},
                [2303] = {"Lyranne Feathersong","Food & Drink",{[1452]={{51.96,29.29}}},nil,"A"},
                [3546] = {"Bernie Heisten","Food & Drink",{[1419]={{63.51,17.01}}},nil,"A"},
                [3547] = {"Hamlin Atkins","Mushroom Farmer",{[1420]={{58.34,50.7}}},{[1420]={{{58.34,50.7},{58.33,50.3},{58.33,50.03},{58.38,49.78},{58.51,49.61},{58.72,49.39},{58.85,49.21},{59.0,49.1},{59.18,49.07},{59.35,49.03},{59.44,49.0},{59.52,48.93},{59.34,48.94},{59.09,49.07},{58.93,49.17},{58.72,49.41},{58.57,49.55},{58.43,49.71},{58.37,49.81},{58.33,50.2},{58.31,50.6},{58.34,51.0},{58.36,51.26},{58.33,51.52},{58.28,51.62},{57.85,51.79},{56.76,52.23},{56.96,52.16},{57.48,51.96},{57.83,51.85},{58.18,51.74},{58.36,51.68},{58.53,51.63},{58.71,51.6},{58.98,51.58},{59.25,51.57},{59.51,51.62},{59.84,51.81},{60.25,52.08},{60.66,52.36},{60.82,52.49},{61.01,52.76},{61.2,53.06},{61.36,53.38},{61.62,53.93},{61.79,54.4},{61.67,54.14},{61.42,53.59},{61.31,53.37},{61.2,53.16},{61.02,52.86},{60.96,52.76},{60.82,52.59},{60.67,52.45},{60.59,52.39},{60.18,52.1},{59.87,51.85},{59.54,51.64},{59.27,51.58},{59.0,51.58},{58.74,51.58},{58.56,51.61},{58.48,51.59},{58.41,51.5},{58.36,51.25},{58.34,50.85}}}},"H"},
                [3621] = {"Kurll","Food & Drink",{[1447]={{21.82,52.1}}},nil,"H"},
                [3689] = {"Laer Stepperunner","Food & Drink",{[1441]={{21.06,31.87}}},nil,"H"},
                [1671] = {"Lamar Veisilli","Fruit Seller",{[1433]={{21.07,46.25}}},nil,"A"},
                [1697] = {"Keeg Gibn","Ale and Wine",{[1426]={{30.45,46.01}}},nil,"A"},
                [4782] = {"Truk Wildbeard","Bartender",{[1425]={{14.36,42.31}}},nil,"A"},
                [5870] = {"Krond","Butcher",{[1442]={{46.23,58.37}}},nil,"H"},
                [5871] = {"Larhka","Beverage Merchant",{[1413]={{51.95,29.69}}},nil,"H"},
                [5886] = {"Gwyn Farrow","Mushroom Merchant",{[1421]={{44.04,39.77}}},nil,"H"},
                [7941] = {"Mardrack Greenwell","Food & Drink",{[1444]={{31.04,43.12}}},nil,"A"},
                [7943] = {"Harklane","Fish Vendor",{[1444]={{31.03,46.25}}},nil,"A"},
                [4875] = {"Turhaw","Butcher",{[1441]={{45.44,51.17}}},nil,"H"},
                [2832] = {"Nixxrax Fillamug","Food and Drink",{[1434]={{27.04,77.17}}},nil,"AH"},
                [4891] = {"Dwane Wertle","Chef",{[1445]={{68.17,47.35}}},nil,"A"},
                [4893] = {"Bartender Lillian","Bartender",{[1445]={{66.67,45.21}}},nil,"A"},
                [15125] = {"Kosco Copperpinch","Smokywood Pastures",{[1417]={{74.21,29.29}}},nil,"AH"},
                [3881] = {"Grimtak","Butcher",{[1411]={{51.13,42.63}}},nil,"H"},
                [3882] = {"Zlagk","Butcher",{[1411]={{42.64,67.19}}},nil,"H"},
                [3883] = {"Moodan Sungrain","Baker",{[1412]={{44.65,77.9}}},nil,"H"},
                [3884] = {"Jhawna Oatwind","Baker",{[1412]={{47.63,61.49}}},nil,"H"},
                [7978] = {"Bimble Longberry","Fruit Vendor",{[1455]={{26.84,27.74}}},{[1455]={{{24.46,26.27},{23.96,22.53},{25.42,19.4},{27.52,16.43},{30.53,12.77},{33.89,9.91},{36.28,9.17},{37.76,10.92},{38.11,13.73},{35.93,16.76},{34.12,18.62},{32.35,21.32},{29.84,22.79},{28.38,24.66},{26.55,26.88}}}},"A"},
                [13420] = {"Penney Copperpinch","Smokywood Pastures",{[1454]={{53.21,65.89}}},nil,"AH"},
                [13433] = {"Wulmort Jinglepocket","Smokywood Pastures",{[1455]={{33.7,67.23}}},nil,"AH"},
                [13435] = {"Khole Jinglepocket","Smokywood Pastures",{[1453]={{55.01,59.26}}},nil,"AH"},
                [15124] = {"Targot Jinglepocket","Smokywood Pastures",{[1417]={{46.48,45.33}}},nil,"AH"},
                [14964] = {"Hecht Copperpinch","Smokywood Pastures",{[1413]={{46.73,8.32}}},nil,"AH"},
                [14963] = {"Gapp Jinglepocket","Smokywood Pastures",{[1440]={{62.08,82.85}}},nil,"AH"},
                [14961] = {"Mirvyna Jinglepocket","Smokywood Pastures",{[1416]={{40.05,80.15}}},nil,"AH"},
                [14844] = {"Sylannia","Darkmoon Faire Drink Vendor",{[1412]={{36.68,38.32}},[12]={{42.22,70.06}}},nil,"AH"},
                [13436] = {"Guchie Jinglepocket","Smokywood Pastures",{[1453]={{55.47,58.92}}},nil,"AH"},
                [13432] = {"Seersa Copperpinch","Smokywood Pastures",{[1456]={{39.04,61.07}}},nil,"AH"},
                [13430] = {"Jaycrue Copperpinch","Smokywood Pastures",{[1458]={{68.15,38.6}}},nil,"AH"},
                [13429] = {"Nardstrum Copperpinch","Smokywood Pastures",{[1458]={{68.24,38.86}}},nil,"AH"},
                [3937] = {"Kira Songshine","Traveling Baker",{[1429]={{42.46,66.05}}},{[1429]={{{42.32,65.45},{41.74,63.77},{41.53,63.21},{41.21,62.39},{41.02,61.48},{40.65,60.39},{40.32,59.49},{40.11,58.7},{39.88,57.61},{39.65,56.91},{39.22,56.31},{38.87,55.85},{38.37,55.22},{37.9,54.52},{37.41,53.95},{36.87,53.72},{36.31,53.69},{35.56,53.63},{34.93,53.51},{34.56,53.33},{34.24,53.1},{33.76,52.56},{33.41,51.97},{33.0,51.23},{33.39,52.04},{33.56,52.31},{33.9,52.72},{34.23,53.15},{34.55,53.44},{34.9,53.55},{35.29,53.66},{35.62,53.69},{36.0,53.75},{36.76,53.77},{37.33,53.91},{37.66,54.19},{38.35,55.19},{38.72,55.75},{39.01,56.15},{39.61,56.74},{39.84,57.5},{39.9,58.0},{40.12,58.93},{40.39,59.92},{40.6,60.43},{40.93,61.24},{41.19,62.06},{41.36,62.94},{41.64,63.78},{41.95,64.39},{42.25,64.91},{42.45,65.65},{42.4,66.2},{42.54,67.11},{43.06,67.51},{43.78,68.01},{44.13,68.28},{44.48,68.57},{45.04,68.95},{45.78,69.36},{46.67,69.6},{47.52,69.61},{46.57,69.54},{45.76,69.32},{45.12,69.02},{44.67,68.68},{44.37,68.39},{43.98,68.17},{43.42,67.76},{42.79,67.25},{42.3,67.14},{41.65,66.85},{41.29,66.72},{40.6,66.56},{40.05,66.68},{39.41,66.79},{39.05,66.76},{38.56,67.12},{37.95,67.78},{37.26,68.85},{37.54,68.25},{37.68,68.09},{38.0,67.58},{38.41,67.33},{38.95,66.81},{39.45,66.71},{39.9,66.62},{40.25,66.63},{40.81,66.71},{41.35,66.83},{41.88,66.88},{42.17,66.78},{42.3,66.54},{42.47,66.03}}}},"A"},
                [4894] = {"Craig Nollward","Cook",{[1445]={{66.9,45.25}}},nil,"A"},
                [3948] = {"Honni Goldenoat","Baker",{[1432]={{35.32,49.73}}},nil,"A"},
                [12019] = {"Dargon","Food & Drink Merchant",{[1450]={{48.87,39.16}}},nil,"AH"},
                [3960] = {"Ulthaan","Butcher",{[1440]={{50.01,66.64}}},nil,"A"},
                [3961] = {"Maliynn","Food & Drink Vendor",{[1440]={{36.62,49.98}}},nil,"A"},
                [894] = {"Homer Stonefield","Fruit Seller",{[1429]={{33.69,82.9}}},nil,"A"},
                [11187] = {"Himmik","Food & Drink",{[1452]={{61.33,39.16}}},nil,"AH"},
                [8150] = {"Janet Hommers","Food & Drink",{[1443]={{66.19,6.57}}},nil,"A"},
                [8143] = {"Loorana","Food & Drink",{[1444]={{75.5,43.89}}},nil,"H"},
                [8125] = {"Dirge Quikcleave","Butcher",{[1446]={{52.63,28.11}}},nil,"AH"},
                [7485] = {"Nargatt","Food & Drink",{[1434]={{32.2,29.27}}},nil,"H"},
                [3017] = {"Nan Mistrunner","Fruit Vendor",{[1456]={{47.34,42.49}}},nil,"H"},
                [6091] = {"Dellylah","Food & Drink Vendor",{[1438]={{59.6,40.69}}},nil,"A"},
                [3025] = {"Kaga Mistrunner","Meat Vendor",{[1456]={{52.3,47.79}}},nil,"H"},
                [3138] = {"Scott Carevin","Mushroom Seller",{[1431]={{75.83,48.7}}},nil,"A"},
                [982] = {"Thultash","Food & Drink Vendor",{[1435]={{46.53,54.29}}},nil,"H"},
                [3708] = {"Gruna","Food & Drink",{[1428]={{65.71,23.91}}},nil,"H"},
                [8152] = {"Harnor","Food & Drink",{[1443]={{51.2,53.27}}},nil,"H"},
                [4191] = {"Allyndia","Food & Drink Vendor",{[1439]={{37.12,43.62}}},nil,"A"},
                [4181] = {"Fyrenna","Food & Drink Vendor",{[1457]={{69.35,45.02}}},nil,"A"},
                [5109] = {"Myra Tyrngaarde","Bread Vendor",{[1455]={{29.61,67.45}}},{[1455]={{{32.0,70.29},{33.55,73.42},{33.05,75.32},{32.05,77.42},{30.8,77.64},{29.49,75.3},{27.36,71.48},{25.3,67.4},{23.38,63.52},{23.88,62.39},{25.71,61.16},{27.83,63.08},{29.62,67.53}}}},"A"},
                [1670] = {"Mike Miller","Bread Merchant",{[1436]={{57.75,53.71}}},nil,"A"},
                [3003] = {"Fyr Mistrunner","Bread Vendor",{[1456]={{41.44,53.19}}},nil,"H"},
                [5140] = {"Edris Barleybeard","Barmaid",{[1455]={{72.25,75.79}}},nil,"A"},
                [1328] = {"Elly Langston","Barmaid",{[1453]={{73.41,38.6}}},{[1453]={{{73.87,36.93},{74.16,37.5},{74.01,37.99},{73.37,38.59},{73.41,38.9},{73.71,38.93},{74.18,38.35},{74.68,37.76},{74.84,37.57},{74.79,37.09},{73.93,35.83},{73.76,35.79},{73.31,36.33},{72.76,37.06},{72.71,37.54},{72.93,37.58},{73.58,36.83}}}},"A"},
                [5112] = {"Gwenna Firebrew","Barmaid",{[1455]={{18.64,51.76}}},nil,"A"},
                
                -- Alchemy Supplies
                [8177] = {"Rartar","Alchemy Supplies",{[1435]={{45.39,56.87}}},nil,"H"},
                [5178] = {"Soolie Berryfizz","Alchemy Supplies",{[1455]={{66.23,54.52}}},nil,"A"},
                [4226] = {"Ulthir","Alchemy Supplies",{[1457]={{55.84,24.47}}},nil,"A"},
                [1313] = {"Maria Lumere","Alchemy Supplies",{[1453]={{46.81,79.09}}},nil,"A"},
                [2380] = {"Nandar Branson","Alchemy Supplies",{[1424]={{50.93,57.1}}},nil,"A"},
                [1453] = {"Dewin Shimmerdawn","Alchemy Supplies",{[1437]={{7.96,56.34}}},nil,"A"},
                [2481] = {"Bliztik","Alchemy Supplies",{[1431]={{18.04,54.36}}},nil,"AH"},
                [2812] = {"Drovnar Strongbrew","Alchemy Supplies",{[1417]={{46.32,47.04}}},nil,"A"},
                [2848] = {"Glyx Brewright","Alchemy Supplies",{[1434]={{28.14,78.11}}},nil,"AH"},
                [4899] = {"Uma Bartulm","Herbalism & Alchemy Supplies",{[1445]={{64.07,47.67}}},nil,"A"},
                [11188] = {"Evie Whirlbrew","Alchemy Supplies",{[1452]={{60.75,37.78}}},nil,"AH"},
                [4610] = {"Algernon","Alchemy Supplies",{[1458]={{51.71,74.67}}},nil,"H"},
                [3010] = {"Mani Winterhoof","Alchemy Supplies",{[1456]={{47.41,33.74}}},nil,"H"},
                [5594] = {"Alchemist Pestlezugg","Alchemy Supplies",{[1446]={{50.89,26.96}}},nil,"AH"},
                [8157] = {"Logannas","Alchemy Supplies",{[1444]={{32.67,44.03}}},nil,"A"},
                [8158] = {"Bronk","Alchemy Supplies",{[1444]={{76.06,43.28}}},nil,"H"},
                [3956] = {"Harklan Moongrove","Alchemy Supplies",{[1440]={{50.84,67.0}}},nil,"A"},
                [8178] = {"Nina Lightbrew","Alchemy Supplies",{[1419]={{66.87,18.24}}},nil,"A"},
                [3548] = {"Selina Weston","Alchemy & Herbalism Supplies",{[1420]={{61.76,50.03}}},nil,"H"},
                
                
                -- Fishing Supplies
                [5162] = {"Tansy Puddlefizz","Fishing Supplier",{[1455]={{48.18,6.51}}},nil,"A"},
                [4222] = {"Voloren","Fishing Supplier",{[1457]={{46.94,57.0}}},nil,"A"},
                [3333] = {"Shankys","Fishing Supplies",{[1454]={{69.99,29.77}}},nil,"H"},
                [5494] = {"Catherine Leland","Fishing Supplier",{[1453]={{45.77,58.58}}},nil,"A"},
                [3550] = {"Martine Tramblay","Fishing Supplies",{[1420]={{65.86,59.64}}},nil,"H"},
                [1684] = {"Khara Deepwater","Fishing Supplies",{[1432]={{40.28,39.28}}},nil,"A"},
                [5940] = {"Harn Longcast","Fishing Supplies",{[1412]={{47.51,55.06}}},nil,"H"},
                [5942] = {"Zansoa","Fishing Supplies",{[1411]={{56.06,73.39}}},nil,"H"},
                [10118] = {"Nessa Shadowsong","Fishing Supplies",{[1438]={{56.26,92.44}}},nil,"A"},
                [7945] = {"Savanne","Fishing Supplies",{[1444]={{31.08,46.14}}},nil,"A"},
                [4574] = {"Lizbeth Cromwell","Fishing Supplier",{[1458]={{81.04,30.75}}},nil,"H"},
                [3029] = {"Sewa Mistrunner","Fishing Supplier",{[1456]={{55.79,47.02}}},nil,"H"},
                
                -- Enchanting Supplies
                [5158] = {"Tilli Thistlefuzz","Enchanting Supplies",{[1455]={{61.03,44.0}}},nil,"A"},
                [4228] = {"Vaean","Enchanting Supplies",{[1457]={{58.57,14.72}}},nil,"A"},
                [4617] = {"Thaddeus Webb","Enchanting Supplies",{[1458]={{62.38,60.98}}},nil,"H"},
                [5758] = {"Leo Sarn","Enchanting Supplies",{[1421]={{53.89,82.21}}},nil,"H"},
                [15419] = {"Kania","Enchanting Supplier",{[1451]={{51.97,39.7}}},nil,"AH"},
                [3346] = {"Kithas","Enchanting Supplies",{[1454]={{53.88,38.02}}},nil,"H"},
                [3012] = {"Nata Dawnstrider","Enchanting Supplies",{[1456]={{44.99,38.75}}},nil,"H"},
                [5757] = {"Lilly","Enchanting Supplies",{[1421]={{43.02,50.82}}},nil,"H"},
                [1318] = {"Jessara Cordell","Enchanting Supplies",{[1453]={{42.81,64.39}}},nil,"A"},
                
                -- Trade Supplies
                [5163] = {"Burbik Gearspanner","Trade Supplier",{[1455]={{46.4,26.88}}},nil,"A"},
                [66] = {"Tharynn Bouden","Trade Supplies",{[1429]={{41.82,67.16}}},nil,"A"},
                [2118] = {"Abigail Shiel","Trade Supplies",{[1420]={{61.03,52.37}}},nil,"H"},
                [3168] = {"Flakk","Trade Supplies",{[1411]={{52.98,41.97}}},nil,"H"},
                [4194] = {"Ullanna","Trade Supplies",{[1439]={{43.8,76.36}}},nil,"A"},
                [1286] = {"Edna Mullby","Trade Supplier",{[1453]={{58.23,60.51}}},nil,"A"},
                [3614] = {"Narret Shadowgrove","Trade Supplies",{[1438]={{55.27,57.15}}},nil,"A"},
                [12941] = {"Jase Farlane","Trade Supplies",{[1423]={{80.59,57.57}}},nil,"AH"},
                [12957] = {"Blimo Gadgetspring","Trade Supplier",{[1447]={{45.21,90.85}}},nil,"AH"},
                [12958] = {"Gigget Zipcoil","Trade Supplies",{[1425]={{34.46,38.59}}},nil,"AH"},
                [12022] = {"Lorelae Wintersong","Trade Supplies",{[1450]={{48.24,40.14}}},nil,"AH"},
                [4877] = {"Jandia","Trade Supplies",{[1441]={{46.21,51.51}}},nil,"H"},
                [4897] = {"Helenia Olden","Trade Supplies",{[1445]={{66.44,51.46}}},nil,"A"},
                [843] = {"Gina MacGregor","Trade Supplies",{[1436]={{57.64,54.05}}},nil,"A"},
                [12043] = {"Kulwia","Trade Supplies",{[1442]={{45.39,59.33}}},nil,"H"},
                [7947] = {"Vivianna","Trade Supplies",{[1444]={{31.3,43.46}}},nil,"A"},
                [8145] = {"Sheendra Tallgrass","Trade Supplies",{[1444]={{74.49,42.73}}},nil,"H"},
                [5100] = {"Fillius Fizzlespinner","Trade Supplier",{[1455]={{38.14,73.7}}},nil,"A"},
                [3499] = {"Ranik","Trade Supplies",{[1413]={{61.93,38.7}}},nil,"AH"},
                [3081] = {"Wunna Darkmane","Trade Goods",{[1412]={{46.18,58.18}}},nil,"H"},
                [1148] = {"Nerrist","Trade Goods",{[1434]={{32.7,29.23}}},nil,"H"},
                [2225] = {"Zora Guthrek","Trade Goods",{[1459]={{50.08,82.15}}},nil,"H"},
                [2381] = {"Micha Yance","Trade Goods",{[1424]={{48.94,55.03}}},nil,"A"},
                [3556] = {"Andrew Hilbert","Trade Goods",{[1421]={{43.22,40.66}}},nil,"H"},
                [3779] = {"Syurana","Trade Goods Supplies",{[1452]={{51.56,29.81}}},nil,"A"},
                [2821] = {"Keena","Trade Goods",{[1417]={{74.09,32.73}}},nil,"H"},
                [3954] = {"Dalria","Trade Goods",{[1440]={{35.12,52.12}}},nil,"A"},
                [3955] = {"Shandrina","Trade Goods",{[1440]={{49.48,67.09}}},nil,"A"},
                [11189] = {"Qia","Trade Goods Supplies",{[1452]={{61.2,37.21}}},nil,"AH"},
                [9636] = {"Kireena","Trade Goods",{[1443]={{50.98,53.55}}},nil,"H"},
                [8363] = {"Shadi Mistrunner","Trade Goods Supplier",{[1456]={{40.64,64.0}}},nil,"H"},
                [5135] = {"Svalbrad Farmountain","Trade Goods",{[1459]={{42.82,16.88}}},nil,"A"},
                [989] = {"Banalash","Trade Goods",{[1435]={{44.77,56.63}}},nil,"H"},

                -- Arcane Goods
                [983] = {"Thultazor","Arcane Goods Vendor",{[1435]={{45.78,52.82}}},nil,"H"},
                [958] = {"Dawn Brightstar","Arcane Goods",{[1429]={{64.88,69.19}}},nil,"A"},
                [1257] = {"Keldric Boucher","Arcane Goods Vendor",{[1453]={{55.73,65.39}}},nil,"A"},

                -- General Goods
                [8139] = {"Jabbey","General Goods",{[1446]={{67.01,21.99}}},nil,"AH"},
                [3350] = {"Asoran","General Goods Vendor",{[1454]={{46.07,40.87}}},nil,"H"},
                [3367] = {"Felika","General Trade Goods Merchant",{[1454]={{60.6,48.93}}},{[1454]={{{60.62,50.34},{60.71,52.34},{60.4,54.34},{59.38,56.14},{58.02,58.23},{56.89,58.3},{55.16,57.51},{54.01,57.03},{52.88,57.19},{52.06,57.98},{51.44,58.53},{50.83,58.73},{51.33,57.82},{51.9,57.4},{52.62,57.05},{53.71,56.81},{55.2,57.56},{56.5,58.54},{57.98,57.71},{59.31,56.34},{60.39,54.16},{60.51,51.35},{60.35,48.34},{61.09,45.98},{60.62,43.4},{60.36,41.01},{60.03,40.58},{59.14,39.42},{57.52,37.83},{55.53,36.27},{53.95,35.4},{52.04,35.63},{49.82,36.13},{49.08,36.26},{48.34,36.39},{46.51,36.62},{48.22,36.38},{48.96,36.23},{49.7,36.09},{50.52,35.94},{51.26,35.8},{53.33,35.55},{55.45,36.17},{57.24,38.16},{57.4,39.71},{56.75,41.34},{57.11,42.79},{57.42,43.81},{58.63,45.69},{59.29,47.25},{60.63,48.28}}}},"H"},
                [5101] = {"Bryllia Ironbrand","General Goods Vendor",{[1455]={{39.23,74.46}}},nil,"A"},
                [3498] = {"Jazzik","General Supplies",{[1413]={{61.92,38.8}}},nil,"AH"},
                [4082] = {"Grawnal","General Goods",{[1442]={{45.88,58.66}}},nil,"H"},
                [4084] = {"Chylina","General Supplies",{[1442]={{35.49,6.17}}},nil,"A"},
                [3072] = {"Kawnie Softbreeze","General Goods",{[1412]={{45.3,76.52}}},nil,"H"},
                [3076] = {"Moorat Longstride","General Goods",{[1412]={{45.86,57.66}}},nil,"H"},
                [5134] = {"Jonivera Farmountain","General Goods",{[1459]={{43.08,17.49}}},nil,"A"},
                [2084] = {"Natheril Raincaller","General Goods",{[1452]={{51.45,30.83}}},nil,"A"},
                [2115] = {"Joshua Kien","General Supplies",{[1420]={{32.29,65.44}}},nil,"H"},
                [4170] = {"Ellandrieth","General Goods Vendor",{[1457]={{64.73,52.97}}},nil,"A"},
                [2134] = {"Mrs. Winters","General Supplies",{[1420]={{61.16,52.59}}},nil,"H"},
                [3158] = {"Duokna","General Goods",{[1411]={{42.59,67.34}}},nil,"H"},
                [4182] = {"Dalmond","General Goods",{[1439]={{37.45,40.5}}},nil,"A"},
                [2140] = {"Edwin Harly","General Supplies",{[1421]={{43.98,39.9}}},nil,"H"},
                [3164] = {"Jark","General Goods",{[1411]={{54.39,42.18}}},nil,"H"},
                [1149] = {"Uthok","General Supplies",{[1434]={{31.55,27.95}}},nil,"H"},
                [4241] = {"Mydrannul","General Goods Vendor",{[1457]={{70.68,45.38}}},nil,"A"},
                [151] = {"Brog Hamfist","General Supplies",{[1429]={{43.96,65.92}}},nil,"A"},
                [152] = {"Brother Danil","General Supplies",{[1429]={{47.49,41.56}}},nil,"A"},
                [8362] = {"Kuruk","General Goods Vendor",{[1456]={{38.91,64.7}}},nil,"H"},
                [227] = {"Mabel Solaj","General Goods Vendor",{[1431]={{74.21,44.81}}},nil,"A"},
                [1285] = {"Thurman Mullby","General Goods Vendor",{[1453]={{58.37,61.68}}},nil,"A"},
                [2401] = {"Kayren Soothallow","General Goods",{[1424]={{62.56,19.91}}},nil,"H"},
                [3481] = {"Barg","General Supplies",{[1413]={{51.67,29.95}}},nil,"H"},
                [1448] = {"Neal Allen","Engineering & General Goods Supplier",{[1437]={{10.75,56.75}}},nil,"A"},
                [1452] = {"Gruham Rumdnul","General Supplies",{[1437]={{12.07,57.98}}},nil,"A"},
                [4555] = {"Eleanor Rusk","General Goods Vendor",{[1458]={{69.17,48.93}}},nil,"H"},
                [3541] = {"Sarah Raycroft","General Goods",{[1424]={{49.14,55.06}}},nil,"A"},
                [3587] = {"Lyrai","General Supplies",{[1438]={{59.52,40.91}}},nil,"A"},
                [3608] = {"Aldia","General Supplies",{[1438]={{55.51,57.15}}},nil,"A"},
                [3625] = {"Rarck","General Goods",{[1459]={{49.88,82.14}}},nil,"H"},
                [1682] = {"Yanni Stoutheart","General Supplies",{[1432]={{34.76,48.62}}},nil,"A"},
                [1685] = {"Xandar Goodbeard","General Supplies",{[1432]={{82.47,63.35}}},nil,"A"},
                [1691] = {"Kreg Bilmn","General Supplies",{[1426]={{47.19,52.4}}},nil,"A"},
                [4775] = {"Felicia Doan","General Trade Goods Vendor",{[1458]={{64.13,50.56}}},nil,"H"},
                [12960] = {"Christi Galvanis","General Goods",{[1443]={{66.61,6.97}}},nil,"A"},
                [5817] = {"Shimra","General Trade Goods Merchant",{[1454]={{47.91,80.35}}},nil,"H"},
                [8934] = {"Christopher Hewen","General Trade Goods Vendor",{[1436]={{52.23,52.83}}},nil,"A"},
                [2803] = {"Malygen","General Goods",{[1448]={{62.32,25.64}}},nil,"A"},
                [2806] = {"Bale","General Goods",{[1448]={{34.75,53.23}}},nil,"H"},
                [2808] = {"Vikki Lonsav","General Goods",{[1417]={{46.45,47.6}}},nil,"A"},
                [2820] = {"Graud","General Goods",{[1417]={{74.12,32.37}}},nil,"H"},
                [7942] = {"Faralorn","General Supplies",{[1444]={{30.65,43.43}}},nil,"A"},
                [4876] = {"Jawn Highmesa","General Goods",{[1441]={{45.91,51.48}}},nil,"H"},
                [791] = {"Lindsay Ashlock","General Supplies",{[1433]={{28.77,47.33}}},nil,"A"},
                [4896] = {"Charity Mipsy","General Goods",{[1445]={{67.45,51.72}}},nil,"A"},
                [829] = {"Adlin Pridedrift","General Supplies",{[1426]={{30.09,71.52}}},nil,"A"},
                [15179] = {"Mishta","General Trade Goods Vendor",{[1451]={{49.88,36.33}}},nil,"AH"},
                [12959] = {"Nergal","General Goods Vendor",{[1449]={{43.27,7.73}}},nil,"AH"},
                [2908] = {"Grawl","General Goods",{[1418]={{3.12,45.93}}},nil,"H"},
                [12027] = {"Tukk","General Goods Vendor",{[1443]={{24.93,71.84}}},nil,"H"},
                [12021] = {"Daeolyn Summerleaf","General Goods",{[1450]={{45.19,34.74}}},nil,"AH"},
                [3962] = {"Haljan Oakheart","General Goods",{[1440]={{34.85,50.87}}},nil,"A"},

                -- General & Trade 
                [4561] = {"Daniel Bartlett","General Trade Supplier",{[1458]={{64.05,37.37}}},nil,"H"},
                [6301] = {"Gorbold Steelhand","General Trade Supplier",{[1439]={{38.11,41.17}}},nil,"A"},
                [1250] = {"Drake Lindgren","General & Trade Supplies",{[1429]={{83.31,66.69}}},nil,"A"},

                -- Cooking Supplies
                [12033] = {"Wulan","Cooking Supplies",{[1443]={{26.17,69.65}}},nil,"H"},
                [3085] = {"Gloria Femmel","Cooking Supplies",{[1433]={{26.64,43.48}}},nil,"A"},
                [5160] = {"Emrul Riknussun","Cooking Supplier",{[1455]={{59.88,37.37}}},nil,"A"},
                [4223] = {"Fyldan","Cooking Supplier",{[1457]={{48.53,21.6}}},nil,"A"},
                [4265] = {"Nyoma","Cooking Supplies",{[1438]={{57.19,61.26}}},nil,"A"},
                [5483] = {"Erika Tate","Cooking Supplier",{[1453]={{76.06,36.76}}},nil,"A"},
                [4553] = {"Ronald Burch","Cooking Supplier",{[1458]={{62.31,43.09}}},nil,"H"},
                [3027] = {"Naal Mistrunner","Cooking Supplier",{[1456]={{50.99,52.45}}},nil,"H"},

                -- SoD Exclusive
                [240361] = {"Taylor Stitchings", "Tailoring Supplies", {[1423] = {{94.69, 83.54}}}, nil, "AH"},
                [240362] = {"Tanya Hide", "Leatherworking Supplies", {[1423] = {{94.24, 93.38}}}, nil, "AH"},
                [241664] = {"Malorie", "Food & Drink", {[1423] = {{95.29, 78.80}}}, nil, "AH"},
                [240654] = {"Fizzlefuse","Opportunist Engineer",{[1423]={{101.03, 78.99}}},nil,"AH"},
            }
        },
        ["CLASSTRAINER"] = {
            icon = POI_ICONS.CLASS,
            type = POI_TYPES.NPC,
            nodes = {
                -- Warlock Trainer
                [5171] = {"Thistleheart","Warlock Trainer",{[1455]={{51.09,6.61}}},nil,"A"},
                [5172] = {"Briarthorn","Warlock Trainer",{[1455]={{50.35,5.66}}},nil,"A"},
                [5173] = {"Alexander Calder","Warlock Trainer",{[1455]={{50.08,7.45}}},nil,"A"},
                [2126] = {"Maximillion","Warlock Trainer",{[1420]={{30.91,66.34}}},nil,"H"},
                [2127] = {"Rupert Boch","Warlock Trainer",{[1420]={{61.59,52.4}}},nil,"H"},
                [3156] = {"Nartok","Warlock Trainer",{[1411]={{40.65,68.52}}},nil,"H"},
                [3172] = {"Dhugru Gorelust","Warlock Trainer",{[1411]={{54.38,41.2}}},nil,"H"},
                [3325] = {"Mirket","Warlock Trainer",{[1454]={{48.62,46.95}}},nil,"H"},
                [3326] = {"Zevrost","Warlock Trainer",{[1454]={{48.47,45.43}}},nil,"H"},
                [5496] = {"Sandahl","Warlock Trainer",{[1453]={{25.82,79.23}}},nil,"A"},
                [5495] = {"Ursula Deline","Warlock Trainer",{[1453]={{26.12,77.22}}},nil,"A"},
                [906] = {"Maximillian Crowe","Warlock Trainer",{[1429]={{44.39,66.24}}},nil,"A"},
                [4565] = {"Richard Kerwin","Warlock Trainer",{[1458]={{88.91,15.86}}},nil,"H"},
                [4564] = {"Luther Pickman","Warlock Trainer",{[1458]={{86.43,15.25}}},nil,"H"},
                [4563] = {"Kaal Soulreaper","Warlock Trainer",{[1458]={{86.21,15.93}}},nil,"H"},
                [459] = {"Drusilla La Salle","Warlock Trainer",{[1429]={{49.87,42.65}}},nil,"A"},
                [460] = {"Alamar Grimm","Warlock Trainer",{[1426]={{28.65,66.14}}},nil,"A"},
                [461] = {"Demisette Cloyce","Warlock Trainer",{[1453]={{25.28,78.22}}},nil,"A"},
                [988] = {"Kartosh","Warlock Trainer",{[1435]={{48.65,55.64}}},nil,"H"},
                [5612] = {"Gimrizz Shadowcog","Warlock Trainer",{[1426]={{47.33,53.69}}},nil,"A"},
                [5815] = {"Kurgul","Demon Trainer",{[1454]={{47.52,46.72}}},nil,"H"},
                [5749] = {"Kayla Smithe","Demon Trainer",{[1420]={{30.81,66.41}}},nil,"H"},
                [5750] = {"Gina Lang","Demon Trainer",{[1420]={{61.55,52.61}}},nil,"H"},
                [5520] = {"Spackle Thornberry","Demon Trainer",{[1453]={{25.66,77.66}}},nil,"A"},
                [6328] = {"Dannie Fizzwizzle","Demon Trainer",{[1426]={{47.28,53.67}}},nil,"A"},
                [6376] = {"Wren Darkspring","Demon Trainer",{[1426]={{28.8,66.16}}},nil,"A"},
                [5753] = {"Martha Strain","Demon Trainer",{[1458]={{85.7,16.08}}},nil,"H"},
                [6373] = {"Dane Winslow","Demon Trainer",{[1429]={{50.05,42.69}}},nil,"A"},
                [6374] = {"Cylina Darkheart","Demon Trainer",{[1429]={{44.4,65.99}}},nil,"A"},
                [6382] = {"Jubahl Corpseseeker","Demon Trainer",{[1455]={{52.7,6.08}}},nil,"A"},
                [12776] = {"Hraug","Demon Trainer",{[1411]={{40.56,68.44}}},nil,"H"},
                [6027] = {"Kitha","Demon Trainer",{[1411]={{54.71,41.5}}},nil,"H"},
                
                -- Shaman Trainer
                [3157] = {"Shikrik","Shaman Trainer",{[1411]={{42.39,69.0}}},nil,"H"},
                [3173] = {"Swart","Shaman Trainer",{[1411]={{54.42,42.59}}},nil,"H"},
                [13417] = {"Sagorne Creststrider","Shaman Trainer",{[1454]={{38.66,35.92}}},nil,"H"},
                [3031] = {"Tigor Skychaser","Shaman Trainer",{[1456]={{23.64,18.79}}},nil,"H"},
                [3032] = {"Beram Skychaser","Shaman Trainer",{[1456]={{21.99,18.8}}},nil,"H"},
                [3344] = {"Kardris Dreamseeker","Shaman Trainer",{[1454]={{38.8,36.37}}},nil,"H"},
                [986] = {"Haromm","Shaman Trainer",{[1435]={{48.19,57.94}}},nil,"H"},
                [3030] = {"Siln Skychaser","Shaman Trainer",{[1456]={{22.82,21.11}}},nil,"H"},
                [3062] = {"Meela Dawnstrider","Shaman Trainer",{[1412]={{45.01,75.94}}},nil,"H"},
                [3066] = {"Narm Skychaser","Shaman Trainer",{[1412]={{48.38,59.15}}},nil,"H"},

                
                -- Warrior Trainer
                [2119] = {"Dannal Stern","Warrior Trainer",{[1420]={{32.69,65.56}}},nil,"H"},
                [2131] = {"Austil de Mon","Warrior Trainer",{[1420]={{61.85,52.54}}},nil,"H"},
                [3169] = {"Tarshaw Jaggedscar","Warrior Trainer",{[1411]={{54.19,42.47}}},nil,"H"},
                [7315] = {"Darnath Bladesinger","Warrior Trainer",{[1457]={{58.94,35.35}}},nil,"A"},
                [3598] = {"Kyra Windblade","Warrior Trainer",{[1438]={{56.22,59.2}}},nil,"A"},
                [1229] = {"Granis Swiftaxe","Warrior Trainer",{[1426]={{47.36,52.65}}},nil,"A"},
                [4594] = {"Angela Curthas","Warrior Trainer",{[1458]={{48.32,15.96}}},nil,"H"},
                [4593] = {"Christoph Walker","Warrior Trainer",{[1458]={{46.93,15.23}}},nil,"H"},
                [8141] = {"Captain Evencane","Warrior Trainer",{[1445]={{67.88,48.41}}},nil,"A"},
                [3353] = {"Grezz Ragefist","Warrior Trainer",{[1454]={{79.79,31.42}}},nil,"H"},
                [3354] = {"Sorek","Warrior Trainer",{[1454]={{80.39,32.38}}},nil,"H"},
                [5113] = {"Kelv Sternhammer","Warrior Trainer",{[1455]={{70.34,90.65}}},nil,"A"},
                [1901] = {"Kelstrum Stonebreaker","Warrior Trainer",{[1455]={{66.97,90.15}}},nil,"A"},
                [5479] = {"Wu Shen","Warrior Trainer",{[1453]={{78.68,45.79}}},nil,"A"},
                [5480] = {"Ilsa Corbin","Warrior Trainer",{[1453]={{78.5,45.71}}},nil,"A"},
                [5114] = {"Bilban Tosslespanner","Warrior Trainer",{[1455]={{65.9,88.41}}},nil,"A"},
                [4595] = {"Baltus Fowler","Warrior Trainer",{[1458]={{47.4,17.29}}},nil,"H"},
                [911] = {"Llane Beshere","Warrior Trainer",{[1429]={{50.24,42.29}}},nil,"A"},
                [912] = {"Thran Khorman","Warrior Trainer",{[1426]={{28.83,67.24}}},nil,"A"},
                [913] = {"Lyria Du Lac","Warrior Trainer",{[1429]={{41.09,65.77}}},nil,"A"},
                [914] = {"Ander Germaine","Warrior Trainer",{[1453]={{78.21,47.59}}},nil,"A"},
                [3153] = {"Frang","Warrior Trainer",{[1411]={{42.89,69.44}}},nil,"H"},
                [4089] = {"Sildanair","Warrior Trainer",{[1457]={{61.78,42.22}}},nil,"A"},
                [985] = {"Malosh","Warrior Trainer",{[1435]={{44.89,57.62}}},nil,"H"},
                [3041] = {"Torm Ragetotem","Warrior Trainer",{[1456]={{57.24,87.37}}},nil,"H"},
                [3042] = {"Sark Ragetotem","Warrior Trainer",{[1456]={{56.99,89.51}}},nil,"H"},
                [3043] = {"Ker Ragetotem","Warrior Trainer",{[1456]={{57.58,85.5}}},nil,"H"},
                [3059] = {"Harutt Thunderhorn","Warrior Trainer",{[1412]={{44.01,76.13}}},nil,"H"},
                [3063] = {"Krang Stonehoof","Warrior Trainer",{[1412]={{49.52,60.59}}},nil,"H"},
                [3593] = {"Alyissia","Warrior Trainer",{[1438]={{59.64,38.44}}},nil,"A"},
                
                -- Rogue Trainer
                [5165] = {"Hulfdan Blackbeard","Rogue Trainer",{[1455]={{51.96,14.84}}},nil,"A"},
                [5166] = {"Ormyr Flinteye","Rogue Trainer",{[1455]={{52.89,15.01}}},nil,"A"},
                [5167] = {"Fenthwick","Rogue Trainer",{[1455]={{51.5,15.33}}},nil,"A"},
                [2122] = {"David Trias","Rogue Trainer",{[1420]={{32.53,65.65}}},nil,"H"},
                [2130] = {"Marion Call","Rogue Trainer",{[1420]={{61.75,52.0}}},nil,"H"},
                [3155] = {"Rwag","Rogue Trainer",{[1411]={{41.28,68.0}}},nil,"H"},
                [3170] = {"Kaplak","Rogue Trainer",{[1411]={{51.98,43.69}}},nil,"H"},
                [4214] = {"Erion Shadewhisper","Rogue Trainer",{[1457]={{34.52,25.93}}},nil,"A"},
                [13283] = {"Lord Tony Romano","Rogue Trainer",{[1453]={{78.33,57.05}}},nil,"A"},
                [1234] = {"Hogral Bakkan","Rogue Trainer",{[1426]={{47.56,52.61}}},nil,"A"},
                [3327] = {"Gest","Rogue Trainer",{[1454]={{42.69,51.48}}},nil,"H"},
                [3328] = {"Ormok","Rogue Trainer",{[1454]={{43.9,54.63}}},nil,"H"},
                [3401] = {"Shenthul","Rogue Trainer",{[1454]={{43.05,53.74}}},nil,"H"},
                [1411] = {"Ian Strom","Rogue Trainer",{[1434]={{26.82,77.15}}},nil,"AH"},
                [915] = {"Jorik Kerridan","Rogue Trainer",{[1429]={{50.31,39.92}}},nil,"A"},
                [916] = {"Solm Hargrin","Rogue Trainer",{[1426]={{28.37,67.51}}},nil,"A"},
                [917] = {"Keryn Sylvius","Rogue Trainer",{[1429]={{43.87,65.94}}},nil,"A"},
                [918] = {"Osborne the Night Man","Rogue Trainer",{[1453]={{74.64,52.82}}},nil,"A"},
                [4582] = {"Carolyn Ward","Rogue Trainer",{[1458]={{83.86,72.07}}},nil,"H"},
                [4215] = {"Anishar","Rogue Trainer",{[1457]={{37.92,20.92}}},nil,"A"},
                [4163] = {"Syurna","Rogue Trainer",{[1457]={{36.99,21.91}}},nil,"A"},
                [4583] = {"Miles Dexter","Rogue Trainer",{[1458]={{85.21,71.57}}},nil,"H"},
                [4584] = {"Gregory Charles","Rogue Trainer",{[1458]={{84.88,73.53}}},nil,"H"},
                [3594] = {"Frahun Shadewhisper","Rogue Trainer",{[1438]={{59.64,38.66}}},nil,"A"},
                [3599] = {"Jannok Breezesong","Rogue Trainer",{[1438]={{56.38,60.14}}},nil,"A"},
                [6707] = {"Fahrad","Grand Master Rogue",{[1416]={{84.45,80.32}}},nil,"AH"},
                
                -- Druid Trainer
                [4217] = {"Mathrengyl Bearwalker","Druid Trainer",{[1457]={{35.37,8.4}}},nil,"A"},
                [4218] = {"Denatharion","Druid Trainer",{[1457]={{34.77,7.37}}},nil,"A"},
                [4219] = {"Fylerian Nightwing","Druid Trainer",{[1457]={{33.51,8.35}}},nil,"A"},
                [12042] = {"Loganaar","Druid Trainer",{[1450]={{52.53,40.57}}},nil,"AH"},
                [9465] = {"Golhine the Hooded","Druid Trainer",{[1448]={{61.93,24.54}}},nil,"A"},
                [8142] = {"Jannos Lighthoof","Druid Trainer",{[1444]={{75.99,42.28}}},nil,"H"},
                [5505] = {"Theridran","Druid Trainer",{[1453]={{21.24,51.63}}},nil,"A"},
                [5504] = {"Sheldras Moontree","Druid Trainer",{[1453]={{20.89,55.5}}},nil,"A"},
                [5506] = {"Maldryn","Druid Trainer",{[1453]={{19.08,52.66}}},nil,"A"},
                [3033] = {"Turak Runetotem","Druid Trainer",{[1456]={{76.48,27.22}}},nil,"H"},
                [3034] = {"Sheal Runetotem","Druid Trainer",{[1456]={{77.14,27.02}}},nil,"H"},
                [3036] = {"Kym Wildmane","Druid Trainer",{[1456]={{77.15,29.82}}},nil,"H"},
                [3060] = {"Gart Mistrunner","Druid Trainer",{[1412]={{45.09,75.93}}},nil,"H"},
                [3064] = {"Gennia Runetotem","Druid Trainer",{[1412]={{48.48,59.64}}},nil,"H"},
                [3597] = {"Mardant Strongoak","Druid Trainer",{[1438]={{58.63,40.29}}},nil,"A"},
                [3602] = {"Kal","Druid Trainer",{[1438]={{55.95,61.56}}},nil,"A"},
                
                -- Hunter Trainer
                [4146] = {"Jocaste","Hunter Trainer",{[1457]={{40.38,8.55}}},nil,"A"},
                [3171] = {"Thotar","Hunter Trainer",{[1411]={{51.85,43.49}}},nil,"H"},
                [4205] = {"Dorion","Hunter Trainer",{[1457]={{42.21,7.27}}},nil,"A"},
                [8308] = {"Alenndaar Lapidaar","Hunter Trainer",{[1440]={{18.01,59.83}}},nil,"A"},
                [10930] = {"Dargh Trueaim","Hunter Trainer",{[1432]={{82.39,62.4}}},nil,"A"},
                [1231] = {"Grif Wildheart","Hunter Trainer",{[1426]={{45.81,53.04}}},nil,"A"},
                [3352] = {"Ormak Grimshot","Hunter Trainer",{[1454]={{66.05,18.53}}},nil,"H"},
                [5517] = {"Thorfin Stoneshield","Hunter Trainer",{[1453]={{62.46,14.94}}},nil,"A"},
                [5516] = {"Ulfir Ironbeard","Hunter Trainer",{[1453]={{61.92,14.66}}},nil,"A"},
                [5515] = {"Einris Brightspear","Hunter Trainer",{[1453]={{61.62,15.27}}},nil,"A"},
                [5116] = {"Olmin Burningbeard","Hunter Trainer",{[1455]={{70.89,83.61}}},nil,"A"},
                [5117] = {"Regnus Thundergranite","Hunter Trainer",{[1455]={{69.87,82.9}}},nil,"A"},
                [1404] = {"Kragg","Hunter Trainer",{[1434]={{31.23,28.68}}},nil,"H"},
                [895] = {"Thorgas Grimson","Hunter Trainer",{[1426]={{29.18,67.45}}},nil,"A"},
                [3963] = {"Danlaar Nightstride","Hunter Trainer",{[1440]={{50.14,67.95}}},nil,"A"},
                [5501] = {"Kaerbrus","Hunter Trainer",{[1448]={{61.89,23.58}}},nil,"A"},
                [987] = {"Ogromm","Hunter Trainer",{[1435]={{47.26,53.43}}},nil,"H"},
                [3038] = {"Kary Thunderhorn","Hunter Trainer",{[1456]={{58.49,88.33}}},nil,"H"},
                [3039] = {"Holt Thunderhorn","Hunter Trainer",{[1456]={{57.3,89.79}}},nil,"H"},
                [3040] = {"Urek Thunderhorn","Hunter Trainer",{[1456]={{59.13,86.87}}},nil,"H"},
                [3061] = {"Lanka Farshot","Hunter Trainer",{[1412]={{44.26,75.69}}},nil,"H"},
                [3065] = {"Yaw Sharpmane","Hunter Trainer",{[1412]={{47.82,55.69}}},nil,"H"},
                [5115] = {"Daera Brightspear","Hunter Trainer",{[1455]={{70.97,89.8}}},nil,"A"},
                [3596] = {"Ayanna Everstride","Hunter Trainer",{[1438]={{58.66,40.45}}},nil,"A"},
                [3601] = {"Dazalar","Hunter Trainer",{[1438]={{56.68,59.49}}},nil,"A"},
                [3620] = {"Harruk","Pet Trainer",{[1411]={{52.03,43.55}}},nil,"H"},
                [3622] = {"Grokor","Pet Trainer",{[1435]={{47.35,52.89}}},nil,"H"},
                [3624] = {"Zudd","Pet Trainer",{[1434]={{31.11,28.94}}},nil,"H"},
                [3688] = {"Reban Freerunner","Pet Trainer",{[1412]={{47.71,55.73}}},nil,"H"},
                [3698] = {"Bolyun","Pet Trainer",{[1440]={{17.98,60.04}}},nil,"A"},
                [4320] = {"Caelyb","Pet Trainer",{[1440]={{49.72,66.97}}},nil,"A"},
                [3306] = {"Keldas","Pet Trainer",{[1438]={{56.79,59.78}}},nil,"A"},
                [10090] = {"Belia Thundergranite","Pet Trainer",{[1455]={{70.86,85.83}}},nil,"A"},
                [10086] = {"Hesuwa Thunderhorn","Pet Trainer",{[1456]={{54.09,83.99}}},nil,"H"},
                [3545] = {"Claude Erksine","Pet Trainer",{[1432]={{82.22,62.84}}},nil,"A"},
                [10089] = {"Silvaria","Pet Trainer",{[1457]={{42.47,9.17}}},nil,"A"},
                [2878] = {"Peria Lamenur","Pet Trainer",{[1426]={{46.68,54.0},{71.04,38.03}}},nil,"A"},
                [2879] = {"Karrina Mekenda","Pet Trainer",{[1453]={{61.58,15.99}}},nil,"A"},
                [543] = {"Nalesette Wildbringer","Pet Trainer",{[1448]={{62.2,24.37}}},nil,"A"},

                -- Priest Trainer
                [837] = {"Branstock Khalder","Priest Trainer",{[1426]={{28.6,66.39}}},nil,"A"},
                [2123] = {"Dark Cleric Duesten","Priest Trainer",{[1420]={{31.11,66.03}}},nil,"H"},
                [2129] = {"Dark Cleric Beryl","Priest Trainer",{[1420]={{61.57,52.19}}},nil,"H"},
                [11406] = {"High Priest Rohan","Priest Trainer",{[1455]={{24.73,8.16}}},{[1455]={{{24.73,8.15},{24.25,6.44},{23.99,6.36},{23.23,7.19},{23.23,7.19},{24.16,6.14},{24.38,6.22},{25.29,7.46},{26.34,7.76},{26.98,7.28},{26.98,7.28},{24.73,8.15}}}},"A"},
                [11401] = {"Priestess Alathea","Priest Trainer",{[1457]={{39.52,81.2}}},nil,"A"},
                [11397] = {"Nara Meideros","Priest Trainer",{[1453]={{20.68,50.07}}},nil,"A"},
                [5142] = {"Braenna Flintcrag","Priest Trainer",{[1455]={{24.42,9.17}}},nil,"A"},
                [1226] = {"Maxan Anvol","Priest Trainer",{[1426]={{47.34,52.19}}},nil,"A"},
                [5484] = {"Brother Benjamin","Priest Trainer",{[1453]={{42.13,30.0}}},{[1453]={{{42.13,30.0},{41.51,28.79},{40.69,27.21},{39.99,25.94},{40.69,27.25},{41.51,28.81}}}},"A"},
                [375] = {"Priestess Anetta","Priest Trainer",{[1429]={{49.81,39.49}}},nil,"A"},
                [376] = {"High Priestess Laurena","Priest Trainer",{[1453]={{38.58,26.06}}},nil,"A"},
                [377] = {"Priestess Josetta","Priest Trainer",{[1429]={{43.28,65.72}}},nil,"A"},
                [4091] = {"Jandria","Priest Trainer",{[1457]={{37.89,82.74}}},nil,"A"},
                [5489] = {"Brother Joshua","Priest Trainer",{[1453]={{38.54,26.85}}},nil,"A"},
                [3044] = {"Miles Welsh","Priest Trainer",{[1456]={{25.32,15.27}}},nil,"H"},
                [3045] = {"Malakai Cross","Priest Trainer",{[1456]={{24.56,22.57}}},nil,"H"},
                [3046] = {"Father Cobb","Priest Trainer",{[1456]={{25.64,20.7}}},nil,"H"},
                [4090] = {"Astarii Starseeker","Priest Trainer",{[1457]={{38.33,80.95}}},nil,"A"},
                [4092] = {"Lariia","Priest Trainer",{[1457]={{40.35,88.68}}},nil,"A"},
                [4606] = {"Aelthalyste","Priest Trainer",{[1458]={{49.26,17.12}}},nil,"H"},
                [4607] = {"Father Lankester","Priest Trainer",{[1458]={{49.14,14.61}}},nil,"H"},
                [4608] = {"Father Lazarus","Priest Trainer",{[1458]={{47.57,18.9}}},nil,"H"},
                [3595] = {"Shanda","Priest Trainer",{[1438]={{59.17,40.44}}},nil,"A"},
                [3600] = {"Laurna Morninglight","Priest Trainer",{[1438]={{55.56,56.75}}},nil,"A"},
                [5141] = {"Theodrus Frostbeard","Priest Trainer",{[1455]={{24.08,8.41}}},nil,"A"},
                [5143] = {"Toldren Deepiron","Priest Trainer",{[1455]={{25.21,10.76}}},nil,"A"},
                [5994] = {"Zayus","High Priest",{[1454]={{35.72,86.9}}},nil,"H"},

                -- Mage Trainer
                [5885] = {"Deino","Mage Trainer",{[1454]={{38.45,86.13}}},nil,"H"},
                [7312] = {"Dink","Mage Trainer",{[1455]={{27.16,8.57}}},nil,"A"},
                [328] = {"Zaldimar Wefhellt","Mage Trainer",{[1429]={{43.25,66.19}}},nil,"A"},
                [5497] = {"Jennea Cannon","Mage Trainer",{[1453]={{38.62,79.3}}},nil,"A"},
                [4567] = {"Pierce Shackleton","Mage Trainer",{[1458]={{85.45,13.51}}},nil,"H"},
                [4566] = {"Kaelystia Hatebringer","Mage Trainer",{[1458]={{85.02,14.02}}},nil,"H"},
                [944] = {"Marryk Nurribit","Mage Trainer",{[1426]={{28.71,66.37}}},nil,"A"},
                [4568] = {"Anastasia Hartwell","Mage Trainer",{[1458]={{85.14,10.03}}},nil,"H"},
                [3047] = {"Archmage Shymm","Mage Trainer",{[1456]={{22.76,14.53}}},nil,"H"},
                [3048] = {"Ursyn Ghull","Mage Trainer",{[1456]={{25.7,14.19}}},nil,"H"},
                [3049] = {"Thurston Xane","Mage Trainer",{[1456]={{25.18,20.96}}},nil,"H"},
                [5144] = {"Bink","Mage Trainer",{[1455]={{27.25,8.3}}},nil,"A"},
                [5145] = {"Juli Stormkettle","Mage Trainer",{[1455]={{26.3,6.77}}},nil,"A"},
                [5146] = {"Nittlebur Sparkfizzle","Mage Trainer",{[1455]={{25.93,6.17}}},nil,"A"},
                [198] = {"Khelden Bremen","Mage Trainer",{[1429]={{49.66,39.4}}},nil,"A"},
                [2124] = {"Isabella","Mage Trainer",{[1420]={{30.93,66.06}}},nil,"H"},
                [2128] = {"Cain Firesong","Mage Trainer",{[1420]={{61.97,52.47}}},nil,"H"},
                [5498] = {"Elsharin","Mage Trainer",{[1453]={{36.87,81.14}}},nil,"A"},
                [1228] = {"Magis Sparkmantle","Mage Trainer",{[1426]={{47.5,52.08}}},nil,"A"},
                [5883] = {"Enyo","Mage Trainer",{[1454]={{38.78,85.67}}},nil,"H"},
                [5882] = {"Pephredo","Mage Trainer",{[1454]={{38.35,85.56}}},nil,"H"},
                [331] = {"Maginor Dumas","Master Mage",{[1453]={{38.22,81.85}}},nil,"A"},
                [2492] = {"Lexington Mortaim","Portal Trainer",{[1458]={{84.19,15.58}}},nil,"H"},
                [2485] = {"Larimaine Purdue","Portal Trainer",{[1453]={{39.69,79.55}}},nil,"A"},
                [2489] = {"Milstaff Stormeye","Portal Trainer",{[1455]={{25.5,7.07}}},nil,"A"},
                [5957] = {"Birgitte Cranston","Portal Trainer",{[1456]={{22.5,16.91}}},nil,"H"},
                [5958] = {"Thuul","Portal Trainer",{[1454]={{38.68,85.41}}},nil,"H"},
                [4165] = {"Elissa Dumas","Portal Trainer",{[1457]={{40.6,82.13}}},nil,"A"},
                
                
                -- Paladin Trainer
                [5491] = {"Arthur the Faithful","Paladin Trainer",{[1453]={{38.68,32.83}}},nil,"A"},
                [5147] = {"Valgar Highforge","Paladin Trainer",{[1455]={{23.7,5.1}}},nil,"A"},
                [5148] = {"Beldruk Doombrow","Paladin Trainer",{[1455]={{24.55,4.47}}},nil,"A"},
                [5149] = {"Brandur Ironhammer","Paladin Trainer",{[1455]={{23.13,6.14}}},nil,"A"},
                [925] = {"Brother Sammuel","Paladin Trainer",{[1429]={{50.43,42.12}}},nil,"A"},
                [926] = {"Bromos Grummner","Paladin Trainer",{[1426]={{28.83,68.33}}},nil,"A"},
                [927] = {"Brother Wilhelm","Paladin Trainer",{[1429]={{41.1,66.04}}},nil,"A"},
                [928] = {"Lord Grayson Shadowbreaker","Paladin Trainer",{[1453]={{37.16,33.32}}},nil,"A"},
                [5492] = {"Katherine the Pure","Paladin Trainer",{[1453]={{37.22,31.86}}},nil,"A"},
                [8140] = {"Brother Karman","Paladin Trainer",{[1445]={{67.4,47.41}}},nil,"A"},
                [1232] = {"Azar Stronghammer","Paladin Trainer",{[1426]={{47.6,52.07}}},nil,"A"},
            }
        },
        ["PROFFTRAINER"] = {
            icon = POI_ICONS.PROFESSION,
            type = POI_TYPES.NPC,
            nodes = {
                -- Engineering
                [11025] = {"Mukdrak","Journeyman Engineer",{[1411]={{52.18,40.8}}},nil,"H"},
                [2857] = {"Thund","Journeyman Engineer",{[1454]={{75.96,24.15}}},nil,"H"},
                [11037] = {"Jenna Lemkenilli","Journeyman Engineer",{[1439]={{38.3,41.12}}},nil,"A"},
                [3494] = {"Tinkerwiz","Journeyman Engineer",{[1413]={{62.67,36.31}}},nil,"AH"},
                [3290] = {"Deek Fizzlebizz","Journeyman Engineer",{[1432]={{45.91,13.44}}},nil,"A"},
                [4586] = {"Graham Van Talen","Journeyman Engineer",{[1458]={{75.34,73.13}}},nil,"H"},
                [1702] = {"Bronk Guzzlegear","Journeyman Engineer",{[1426]={{50.18,50.38}}},nil,"A"},
                [11028] = {"Jemma Quikswitch","Journeyman Engineer",{[1455]={{67.66,44.21}}},nil,"A"},
                [11026] = {"Sprite Jumpsprocket","Journeyman Engineer",{[1453]={{54.55,7.92}}},nil,"A"},
                [10993] = {"Twizwick Sprocketgrind","Journeyman Engineer",{[1412]={{61.86,31.41}}},nil,"AH"},
                [1676] = {"Finbus Geargrind","Expert Engineer",{[1431]={{77.38,48.82}}},nil,"A"},
                [3412] = {"Nogg","Expert Engineer",{[1454]={{75.99,25.41}}},nil,"H"},
                [11029] = {"Trixie Quikswitch","Expert Engineer",{[1455]={{67.48,42.91}}},nil,"A"},
                [5518] = {"Lilliam Sparkspindle","Expert Engineer",{[1453]={{54.81,7.6}}},nil,"A"},
                [11031] = {"Franklin Lloyd","Expert Engineer",{[1458]={{76.12,74.03}}},nil,"H"},
                [11017] = {"Roxxik","Artisan Engineer",{[1454]={{76.17,25.17}}},nil,"H"},
                [5174] = {"Springspindle Fizzlegear","Artisan Engineer",{[1455]={{68.46,43.54}}},nil,"A"},
                [8736] = {"Buzzek Bracketswing","Master Engineer",{[1446]={{52.34,27.72}}},nil,"AH"},
                [7406] = {"Oglethorpe Obnoticus","Master Gnome Engineer",{[1434]={{28.36,76.35}}},nil,"AH"},
                [7944] = {"Tinkmaster Overspark","Master Gnome Engineer",{[1455]={{69.55,50.33}}},nil,"A"},
                [8738] = {"Vazario Linkgrease","Master Goblin Engineer",{[1413]={{62.69,36.25}}},nil,"AH"},
                [8126] = {"Nixx Sprocketspring","Master Goblin Engineer",{[1446]={{52.48,27.33}}},nil,"AH"},
                
                -- Skinning
                [12030] = {"Malux","Skinning Trainer",{[1443]={{23.24,69.72}}},nil,"H"},
                [7089] = {"Mooranta","Skinning Trainer",{[1456]={{44.44,43.15}}},nil,"H"},
                [7087] = {"Killian Hagey","Skinning Trainer",{[1458]={{70.16,59.18}}},nil,"H"},
                [6295] = {"Wilma Ranthal","Skinning Trainer",{[1433]={{88.83,71.3}}},nil,"A"},
                [6291] = {"Balthus Stoneflayer","Skinning Trainer",{[1455]={{39.86,32.5}}},nil,"A"},
                [6292] = {"Eladriel","Skinning Trainer",{[1457]={{64.14,22.26}}},nil,"A"},
                [7088] = {"Thuwd","Skinning Trainer",{[1454]={{63.36,45.42}}},nil,"H"},
                [8144] = {"Kulleg Stonehorn","Skinning Trainer",{[1444]={{74.47,43.04}}},nil,"H"},
                [1292] = {"Maris Granger","Skinning Trainer",{[1453]={{67.81,48.82}}},nil,"A"},
                [6287] = {"Radnaal Maneweaver","Skinner",{[1438]={{42.09,49.96}}},nil,"A"},
                [6288] = {"Jayla","Skinner",{[1440]={{49.98,67.29}}},nil,"A"},
                [6306] = {"Helene Peltskinner","Skinner",{[1429]={{46.24,62.24}}},nil,"A"},
                [6289] = {"Rand Rhobart","Skinner",{[1420]={{65.58,60.03}}},nil,"H"},
                [6290] = {"Yonn Deepcut","Skinner",{[1412]={{45.48,57.78}}},nil,"H"},
                [6387] = {"Dranh","Skinner",{[1413]={{45.07,59.1}}},nil,"H"},
                
                
                -- Weapon Master
                [13084] = {"Bixi Wobblebonk","Weapon Master",{[1455]={{62.23,89.62}}},{[1455]={{{62.23,89.62},{62.23,89.62},{62.11,89.6},{61.91,89.96},{61.29,90.58},{60.98,90.48},{60.65,89.64},{60.83,89.08},{61.25,88.85},{61.47,89.19},{62.02,88.92},{61.88,88.8},{61.43,88.88},{60.79,89.11},{60.7,89.65},{60.98,90.46},{61.3,90.53},{61.93,89.97},{62.48,89.5},{62.64,89.19},{62.63,88.93},{62.59,89.22},{62.29,89.45},{61.94,89.35},{61.5,89.27},{61.43,89.31},{61.44,88.77},{61.38,88.29},{61.19,87.85},{61.52,88.69},{61.83,89.18}}}},"A"},
                [2704] = {"Hanashi","Weapon Master",{[1454]={{81.53,19.63}}},nil,"H"},
                [11870] = {"Archibald","Weapon Master",{[1458]={{57.31,32.77}}},nil,"H"},
                [11869] = {"Ansekhwa","Weapon Master",{[1456]={{40.93,62.73}}},nil,"H"},
                [11868] = {"Sayoc","Weapon Master",{[1454]={{81.7,19.55}}},nil,"H"},
                [11866] = {"Ilyenia Moonfire","Weapon Master",{[1457]={{57.56,46.73}}},nil,"A"},
                [11867] = {"Woo Ping","Weapon Master",{[1453]={{57.13,57.71}}},nil,"A"},
                [11865] = {"Buliwyf Stonehand","Weapon Master",{[1455]={{61.17,89.52}}},nil,"A"},
                
                -- Fishing
                [3179] = {"Harold Riggs","Fishing Trainer",{[1437]={{8.08,58.59}}},nil,"A"},
                [5493] = {"Arnold Leland","Fishing Trainer",{[1453]={{45.64,58.43}}},nil,"A"},
                [4573] = {"Armand Cromwell","Fishing Trainer",{[1458]={{80.7,31.26}}},nil,"H"},
                [14740] = {"Katoom the Angler","Fishing Trainer & Supplies",{[1425]={{80.33,81.54}}},nil,"H"},
                [3028] = {"Kah Mistrunner","Fishing Trainer",{[1456]={{56.13,46.38}}},nil,"H"},
                [1680] = {"Matthew Hooper","Fishing Trainer",{[1433]={{26.99,51.13}}},{[1433]={{{26.99,51.13},{26.26,50.65},{26.54,51.26}}}},"A"},
                [3332] = {"Lumak","Fishing Trainer",{[1454]={{69.8,29.21}}},nil,"H"},
                [5161] = {"Grimnur Stonebrand","Fishing Trainer",{[1455]={{48.07,6.91}}},nil,"A"},
                [4156] = {"Astaia","Fishing Trainer",{[1457]={{47.89,56.65}}},nil,"A"},
                [4305] = {"Kriggon Talsone","Fisherman",{[1436]={{36.23,90.18}}},nil,"A"},
                [4307] = {"Heldan Galesong","Fisherman",{[1439]={{36.97,56.35}}},nil,"A"},
                [3572] = {"Zizzek","Fisherman",{[1413]={{61.99,39.14}}},nil,"AH"},
                [2626] = {"Old Man Heming","Fisherman",{[1434]={{27.42,77.16}}},nil,"AH"},
                [5748] = {"Killian Sanatha","Fisherman",{[1421]={{33.0,17.85}}},nil,"H"},
                [2842] = {"Wigcik","Superior Fisherman",{[1434]={{28.0,76.99}}},nil,"AH"},
                [8137] = {"Gikkix","Fisherman",{[1446]={{66.64,22.08}}},nil,"AH"},
                [7946] = {"Brannock","Fisherman",{[1444]={{32.25,41.61}}},nil,"A"},
                [5938] = {"Uthan Stillwater","Fisherman",{[1412]={{44.51,60.66}}},nil,"H"},
                [2367] = {"Donald Rabonne","Fisherman",{[1424]={{50.78,61.03}}},nil,"A"},
                [1683] = {"Warg Deepwater","Fisherman",{[1432]={{40.55,39.7}}},nil,"A"},
                [1700] = {"Paxton Ganter","Fisherman",{[1426]={{35.48,40.22}}},nil,"A"},
                [3607] = {"Androl Oakhand","Fisherman",{[1438]={{55.88,93.51}}},nil,"A"},
                [5690] = {"Clyde Kellen","Fisherman",{[1420]={{67.17,50.99}}},nil,"H"},
                [1651] = {"Lee Brown","Fisherman",{[1429]={{47.61,62.32}}},nil,"A"},
                [2834] = {"Myizz Luckycatch","Superior Fisherman",{[1434]={{27.46,77.11}}},nil,"AH"},
                
                -- Enchanting
                [11065] = {"Thonys Pillarstone","Journeyman Enchanter",{[1455]={{60.27,45.37}}},nil,"A"},
                [11070] = {"Lalina Summermoon","Journeyman Enchanter",{[1457]={{58.79,12.74}}},nil,"A"},
                [11071] = {"Mot Dawnstrider","Journeyman Enchanter",{[1456]={{44.61,38.5}}},nil,"H"},
                [11068] = {"Betty Quin","Journeyman Enchanter",{[1453]={{43.11,63.7}}},nil,"A"},
                [11067] = {"Malcomb Wynn","Journeyman Enchanter",{[1458]={{62.54,60.35}}},nil,"H"},
                [11066] = {"Jhag","Journeyman Enchanter",{[1454]={{53.47,38.55}}},nil,"H"},
                [3606] = {"Alanna Raveneye","Journeyman Enchanter",{[1438]={{36.71,34.16}}},nil,"A"},
                [5695] = {"Vance Undergloom","Journeyman Enchanter",{[1420]={{61.77,51.56}}},nil,"H"},
                [7949] = {"Xylinnia Starshine","Expert Enchanter",{[1444]={{31.55,44.25}}},nil,"A"},
                [1317] = {"Lucan Cordell","Expert Enchanter",{[1453]={{42.94,64.65}}},nil,"A"},
                [4616] = {"Lavinia Crowe","Expert Enchanter",{[1458]={{62.47,61.8}}},nil,"H"},
                [5157] = {"Gimble Thistlefuzz","Expert Enchanter",{[1455]={{59.77,45.45}}},nil,"A"},
                [3011] = {"Teg Dawnstrider","Expert Enchanter",{[1456]={{44.91,37.49}}},nil,"H"},
                [3345] = {"Godan","Expert Enchanter",{[1454]={{53.9,38.67}}},nil,"H"},
                [4213] = {"Taladan","Expert Enchanter",{[1457]={{58.4,13.12}}},nil,"A"},
                [11074] = {"Hgarth","Artisan Enchanter",{[1442]={{49.18,57.18}}},nil,"H"},
                [11072] = {"Kitta Firewind","Artisan Enchanter",{[1429]={{64.93,70.71}}},nil,"A"},
                
                -- Leatherwork
                [11096] = {"Randal Worth","Journeyman Leatherworker",{[1453]={{67.81,49.65}}},nil,"A"},
                [3069] = {"Chaw Stronghide","Journeyman Leatherworker",{[1412]={{45.44,57.86}}},nil,"H"},
                [1466] = {"Gretta Finespindle","Journeyman Leatherworker",{[1455]={{38.81,32.88}}},nil,"A"},
                [3549] = {"Shelene Rhobart","Journeyman Leatherworker",{[1420]={{65.43,60.12}}},nil,"H"},
                [223] = {"Dan Golthas","Journeyman Leatherworker",{[1458]={{70.93,58.41}}},nil,"H"},
                [3605] = {"Nadyia Maneweaver","Journeyman Leatherworker",{[1438]={{41.88,49.44}}},nil,"A"},
                [1632] = {"Adele Fielder","Journeyman Leatherworker",{[1429]={{46.38,62.05}}},nil,"A"},
                [3008] = {"Mak","Journeyman Leatherworker",{[1456]={{42.06,43.45}}},nil,"H"},
                [11083] = {"Darianna","Journeyman Leatherworker",{[1457]={{64.44,20.87}}},nil,"A"},
                [5784] = {"Waldor","Journeyman Leatherworker",{[1413]={{45.97,35.85}}},nil,"AH"},
                [5811] = {"Kamari","Journeyman Leatherworker",{[1454]={{63.28,44.75}}},nil,"H"},
                [3365] = {"Karolek","Expert Leatherworker",{[1454]={{62.81,44.15}}},nil,"H"},
                [5564] = {"Simon Tanner","Expert Leatherworker",{[1453]={{67.22,49.84}}},nil,"A"},
                [11081] = {"Faldron","Expert Leatherworker",{[1457]={{64.77,21.82}}},nil,"A"},
                [11084] = {"Tarn","Expert Leatherworker",{[1456]={{42.32,42.61}}},nil,"H"},
                [1385] = {"Brawn","Expert Leatherworker",{[1434]={{31.74,28.9}}},nil,"H"},
                [3967] = {"Aayndia Floralwind","Expert Leatherworker",{[1440]={{35.98,52.1}}},nil,"A"},
                [4588] = {"Arthur Moore","Expert Leatherworker",{[1458]={{70.18,57.42}}},nil,"H"},
                [5127] = {"Fimble Finespindle","Expert Leatherworker",{[1455]={{40.24,33.68}}},nil,"A"},
                [8153] = {"Narv Hidecrafter","Expert Leathercrafter",{[1443]={{55.25,56.34}}},nil,"H"},
                [3703] = {"Krulmoo Fullmoon","Expert Leatherworker",{[1413]={{44.84,59.46}}},nil,"H"},
                [3007] = {"Una","Artisan Leatherworker",{[1456]={{41.5,42.57}}},nil,"H"},
                [4212] = {"Telonis","Artisan Leatherworker",{[1457]={{64.43,21.54}}},nil,"A"},
                
                [11097] = {"Drakk Stonehand","Master Leatherworking Trainer",{[1425]={{13.39,43.49}}},nil,"A"},
                [11098] = {"Hahrana Ironhide","Master Leatherworker",{[1444]={{74.36,43.12}}},nil,"H"},
                
                [7870] = {"Caryssia Moonhunter","Tribal Leatherworking Trainer",{[1444]={{89.42,46.55}}},nil,"A"},
                [7866] = {"Peter Galen","Master Dragonscale Leatherworker",{[1447]={{37.59,65.42}}},nil,"A"},
                [7867] = {"Thorkaf Dragoneye","Master Dragonscale Leatherworker",{[1418]={{62.7,57.4}}},nil,"H"},
                [7869] = {"Brumn Winterhoof","Master Elemental Leatherworker",{[1417]={{28.27,45.09}}},nil,"H"},
                [7868] = {"Sarah Tanner","Master Elemental Leatherworker",{[1427]={{63.56,75.97}}},nil,"A"},
                
                -- Blacksmithing
                [957] = {"Dane Lindgren","Journeyman Blacksmith",{[1453]={{57.44,16.27}}},nil,"A"},
                [3557] = {"Guillaume Sorouy","Journeyman Blacksmith",{[1421]={{43.2,41.08}}},nil,"H"},
                [1241] = {"Tognus Flintfire","Journeyman Blacksmith",{[1426]={{45.34,51.94}}},{[1426]={{{45.34,51.94},{45.32,51.92}}}},"A"},
                [6299] = {"Delfrum Flintbeard","Journeyman Blacksmith",{[1439]={{38.19,40.93}}},nil,"A"},
                [10278] = {"Thrag Stonehoof","Journeyman Blacksmith",{[1456]={{39.43,56.66}}},nil,"H"},
                [10277] = {"Groum Stonebeard","Journeyman Blacksmith",{[1455]={{52.26,41.94}}},nil,"A"},
                [3174] = {"Dwukk","Journeyman Blacksmith",{[1411]={{52.03,40.72}}},nil,"H"},
                [514] = {"Smith Argus","Journeyman Blacksmith",{[1429]={{41.71,65.54}}},nil,"A"},
                [4605] = {"Basil Frye","Journeyman Blacksmith",{[1458]={{60.17,29.09}}},nil,"H"},
                [1383] = {"Snarl","Expert Blacksmith",{[1454]={{79.6,23.31}}},nil,"H"},
                [3478] = {"Traugh","Expert Blacksmith",{[1413]={{51.3,28.91}}},nil,"H"},
                [2998] = {"Karn Stonehoof","Expert Blacksmith",{[1456]={{39.38,55.09}}},nil,"H"},
                [3136] = {"Clarise Gnarltree","Expert Blacksmith",{[1431]={{74.0,48.55}}},nil,"A"},
                [4596] = {"James Van Brunt","Expert Blacksmith",{[1458]={{61.26,30.63}}},nil,"H"},
                [5511] = {"Therum Deepforge","Expert Blacksmith",{[1453]={{56.84,16.25}}},nil,"A"},
                [10276] = {"Rotgath Stonebeard","Expert Blacksmith",{[1455]={{52.36,42.55}}},nil,"A"},
                [2836] = {"Brikk Keencraft","Master Blacksmith",{[1434]={{28.99,75.56}}},nil,"AH"},
                [3355] = {"Saru Steelfury","Artisan Blacksmith",{[1454]={{82.35,22.97}}},nil,"H"},
                [4258] = {"Bengus Deepforge","Artisan Blacksmith",{[1455]={{52.55,41.46}}},nil,"A"},

                [7232] = {"Borgus Steelhand","Weapon Crafter",{[1453]={{51.34,12.7}}},nil,"A"},
                [7231] = {"Kelgruk Bloodaxe","Weapon Crafter",{[1454]={{81.95,18.02}}},nil,"H"},
                [11178] = {"Borgosh Corebender","Weaponsmith",{[1454]={{79.41,23.74}}},nil,"H"},
                [11146] = {"Ironus Coldsteel","Special Weapon Crafter",{[1455]={{50.33,43.56}}},nil,"A"},

                [5164] = {"Grumnus Steelshaper","Armor Crafter",{[1455]={{49.96,42.81}}},nil,"A"},
                [7230] = {"Shayis Steelfury","Armor Crafter",{[1454]={{80.24,23.44}}},nil,"H"},
                [11177] = {"Okothos Ironrager","Armorsmith",{[1454]={{79.8,24.06}}},nil,"H"},
                
                
                -- Alchemy
                [3603] = {"Cyndra Kindwhisper","Journeyman Alchemist",{[1438]={{57.64,60.8}}},nil,"A"},
                [11041] = {"Milla Fairancora","Journeyman Alchemist",{[1457]={{55.39,22.72}}},nil,"A"},
                [11044] = {"Doctor Martin Felben","Journeyman Alchemist Trainer",{[1458]={{46.61,74.09}}},nil,"H"},
                [11046] = {"Whuut","Journeyman Alchemist",{[1454]={{55.79,32.9}}},nil,"H"},
                [11047] = {"Kray","Journeyman Alchemist",{[1456]={{46.68,34.43}}},nil,"H"},
                [1470] = {"Ghak Healtouch","Journeyman Alchemist",{[1432]={{37.07,49.38}}},nil,"A"},
                [2132] = {"Carolai Anise","Journeyman Alchemist",{[1420]={{59.43,52.19}}},nil,"H"},
                [1215] = {"Alchemist Mallory","Journeyman Alchemist",{[1429]={{39.84,48.23}}},nil,"A"},
                [1246] = {"Vosur Brakthel","Journeyman Alchemist",{[1455]={{66.33,55.69}}},nil,"A"},
                [4609] = {"Doctor Marsh","Expert Alchemist",{[1458]={{50.93,74.56}}},nil,"H"},
                [11042] = {"Sylvanna Forestmoon","Expert Alchemist",{[1457]={{56.38,24.23}}},nil,"A"},
                [2391] = {"Serge Hinott","Expert Alchemist",{[1424]={{61.63,19.19}}},nil,"H"},
                [4900] = {"Alchemist Narett","Expert Alchemist",{[1445]={{63.94,47.64}}},nil,"A"},
                [3964] = {"Kylanna","Expert Alchemist",{[1440]={{50.85,67.11}}},nil,"A"},
                [2837] = {"Jaxin Chong","Expert Alchemist",{[1434]={{28.04,77.99}}},nil,"AH"},
                [3009] = {"Bena Winterhoof","Expert Alchemist",{[1456]={{46.62,33.17}}},nil,"H"},
                [3347] = {"Yelmak","Expert Alchemist",{[1454]={{56.84,33.03}}},nil,"H"},
                [5499] = {"Lilyssia Nightbreeze","Expert Alchemist",{[1453]={{46.51,79.68}}},nil,"A"},
                [5177] = {"Tally Berryfizz","Expert Alchemist",{[1455]={{66.62,55.69}}},nil,"A"},
                [4160] = {"Ainethil","Artisan Alchemist",{[1457]={{54.88,24.02}}},nil,"A"},
                [4611] = {"Doctor Herbert Halsey","Artisan Alchemist",{[1458]={{47.77,73.34}}},nil,"H"},
                [7948] = {"Kylanna Windwhisper","Master Alchemist",{[1444]={{32.62,43.78}}},nil,"A"},
                [1386] = {"Rogvar","Master Alchemist",{[1435]={{48.53,55.85}}},nil,"H"},
                
                -- Mining
                [3357] = {"Makaru","Mining Trainer",{[1454]={{73.12,26.08}}},nil,"H"},
                [5513] = {"Gelman Stonehand","Mining Trainer",{[1453]={{51.15,17.31}}},nil,"A"},
                [3001] = {"Brek Stonehoof","Mining Trainer",{[1456]={{34.37,57.9}}},nil,"H"},
                [4254] = {"Geofram Bouldertoe","Mining Trainer",{[1455]={{50.0,26.29}}},nil,"A"},
                [1681] = {"Brock Stoneseeker","Mining Trainer",{[1432]={{37.02,47.81}}},nil,"A"},
                [6297] = {"Kurdram Stonehammer","Mining Trainer",{[1439]={{38.25,41.01}}},nil,"A"},
                [1701] = {"Dank Drizzlecut","Mining Trainer",{[1426]={{69.32,55.46}}},nil,"A"},
                [4598] = {"Brom Killian","Mining Trainer",{[1458]={{56.03,37.45}}},nil,"H"},
                [3137] = {"Matt Johnson","Mining Trainer",{[1431]={{74.05,49.62}}},nil,"A"},
                [5392] = {"Yarr Hammerstone","Mining Trainer",{[1426]={{50.01,50.31}}},nil,"A"},
                [3555] = {"Johan Focht","Miner",{[1421]={{43.41,40.45}}},nil,"H"},
                [8128] = {"Pikkle","Miner",{[1446]={{51.08,28.1}}},nil,"AH"},
                [3175] = {"Krunn","Miner",{[1411]={{51.81,40.88}}},nil,"H"},
                
                -- Herbalism
                [12025] = {"Malvor","Herbalist",{[1450]={{45.42,46.97}}},nil,"AH"},
                [2390] = {"Aranae Venomblood","Herbalist",{[1424]={{61.71,19.52}}},nil,"H"},
                [4898] = {"Brant Jasperbloom","Herbalist",{[1445]={{64.01,47.53}}},nil,"A"},
                [3965] = {"Cylania Rootstalker","Herbalist",{[1440]={{50.69,67.17}}},nil,"A"},
                [2856] = {"Angrun","Superior Herbalist",{[1434]={{32.25,27.43}}},nil,"H"},
                [3185] = {"Mishiki","Herbalist",{[1411]={{55.44,75.08}}},nil,"H"},
                [3604] = {"Malorne Bladeleaf","Herbalist",{[1438]={{57.72,60.64}}},nil,"A"},
                [812] = {"Alma Jainrose","Herbalism Trainer",{[1433]={{21.69,45.77}}},{[1433]={{{21.69,45.77},{21.32,45.53}}}},"A"},
                [3404] = {"Jandi","Herbalism Trainer",{[1454]={{55.62,39.46}}},nil,"H"},
                [5502] = {"Shylamiir","Herbalism Trainer",{[1453]={{15.28,49.33}}},nil,"A"},
                [4204] = {"Firodren Mooncaller","Herbalism Trainer",{[1457]={{47.95,68.03}}},nil,"A"},
                [1458] = {"Telurinon Moonshadow","Herbalism Trainer",{[1437]={{7.99,55.84}}},{[1437]={{{7.99,55.84},{7.86,55.8},{7.96,55.95}}}},"A"},
                [1473] = {"Kali Healtouch","Herbalist",{[1432]={{36.47,48.54}}},nil,"A"},
                [3013] = {"Komin Winterhoof","Herbalism Trainer",{[1456]={{49.95,40.41}}},nil,"H"},
                [5137] = {"Reyna Stonebranch","Herbalism Trainer",{[1455]={{55.9,59.13}}},nil,"A"},
                [1218] = {"Herbalist Pomeroy","Herbalism Trainer",{[1429]={{39.96,48.41}}},nil,"A"},
                [5566] = {"Tannysa","Herbalism Trainer",{[1453]={{44.73,77.11}}},nil,"A"},
                [8146] = {"Ruw","Herbalism Trainer",{[1444]={{75.98,43.33}}},nil,"H"},
                [4614] = {"Martha Alliestar","Herbalism Trainer",{[1458]={{54.0,49.55}}},nil,"H"},
                [2114] = {"Faruza","Apprentice Herbalist",{[1420]={{59.79,52.12}}},nil,"H"},
                [908] = {"Flora Silverwind","Superior Herbalist",{[1434]={{27.72,77.86}}},nil,"AH"},
                
                -- Tailor
                [1300] = {"Lawrence Schneider","Journeyman Tailor",{[1453]={{43.69,73.71}}},nil,"A"},
                [2855] = {"Snang","Journeyman Tailor",{[1454]={{62.93,49.24}}},nil,"H"},
                [11050] = {"Trianna","Journeyman Tailor",{[1457]={{63.55,21.21}}},nil,"A"},
                [4193] = {"Grondal Moonbreeze","Journeyman Tailor",{[1439]={{38.24,40.53}}},nil,"A"},
                [3523] = {"Bowen Brisboise","Journeyman Tailor",{[1420]={{52.59,55.52}}},nil,"H"},
                [1703] = {"Uthrar Threx","Journeyman Tailor",{[1455]={{43.82,27.86}}},nil,"A"},
                [11048] = {"Victor Ward","Journeyman Tailor",{[1458]={{70.08,29.83}}},nil,"H"},
                [1103] = {"Eldrin","Journeyman Tailor",{[1429]={{79.22,69.03}}},nil,"A"},
                [11051] = {"Vhan","Journeyman Tailor",{[1456]={{44.26,44.34}}},nil,"H"},
                [3363] = {"Magar","Expert Tailor",{[1454]={{63.65,49.93}}},nil,"H"},
                [5153] = {"Jormund Stonebrow","Expert Tailor",{[1455]={{43.15,29.36}}},nil,"A"},
                [3004] = {"Tepa","Expert Tailor",{[1456]={{44.52,45.35}}},nil,"H"},
                [5567] = {"Sellandus","Expert Tailor",{[1453]={{42.0,75.86}}},nil,"A"},
                [2627] = {"Grarnik Goodstitch","Expert Tailor",{[1434]={{28.77,76.84}}},nil,"AH"},
                [3704] = {"Mahani","Expert Tailor",{[1413]={{44.93,59.39}}},nil,"H"},
                [11049] = {"Rhiannon Davis","Expert Tailor",{[1458]={{70.04,30.56}}},nil,"H"},
                [1346] = {"Georgio Bolero","Artisan Tailor",{[1453]={{43.17,73.55}}},nil,"A"},
                [4576] = {"Josef Gregorian","Artisan Tailor",{[1458]={{70.76,30.69}}},nil,"H"},
                [11052] = {"Timothy Worthington","Master Tailor",{[1445]={{66.18,51.81}}},nil,"A"},
                [4578] = {"Josephine Lister","Master Shadoweave Tailor",{[1458]={{86.65,22.08}}},nil,"H"},
                [9584] = {"Jalane Ayrole","Master Shadoweave Tailor",{[1453]={{26.72,77.78}}},nil,"A"},
                [2399] = {"Daryl Stack","Master Tailor",{[1424]={{63.75,20.79}}},nil,"H"},
                
                -- Cooking
                [5482] = {"Stephen Ryback","Cooking Trainer",{[1453]={{75.6,37.04}}},nil,"A"},
                [3087] = {"Crystal Boughman","Cooking Trainer",{[1433]={{22.78,43.47}}},nil,"A"},
                [1355] = {"Cook Ghilm","Cooking Trainer",{[1426]={{68.38,54.49}}},{[1426]={{{68.4,54.45},{68.38,54.49}}}},"A"},
                [4552] = {"Eunice Burch","Cooking Trainer",{[1458]={{62.14,44.91}}},nil,"H"},
                [3399] = {"Zamja","Cooking Trainer",{[1454]={{57.4,53.96}}},nil,"H"},
                [3026] = {"Aska Mistrunner","Cooking Trainer",{[1456]={{50.72,53.11}}},nil,"H"},
                [1699] = {"Gremlock Pilsnor","Cooking Trainer",{[1426]={{47.67,52.31}}},nil,"A"},
                [5159] = {"Daryl Riknussun","Cooking Trainer",{[1455]={{60.08,36.43}}},nil,"A"},
                [4210] = {"Alegorn","Cooking Trainer",{[1457]={{49.03,21.24}}},nil,"A"},
                [3067] = {"Pyall Silentstride","Cook",{[1412]={{45.41,58.11}}},nil,"H"},
                [1382] = {"Mudduk","Superior Cook",{[1434]={{31.34,27.97}}},nil,"H"},
                [1430] = {"Tomas","Cook",{[1429]={{44.37,65.99}}},nil,"A"},
                [6286] = {"Zarrin","Cook",{[1438]={{57.12,61.3}}},nil,"A"},
                [8306] = {"Duhng","Cook",{[1413]={{55.29,31.78}}},nil,"H"},
                [2818] = {"Slagg","Superior Butcher",{[1417]={{74.08,33.82}}},nil,"H"},
                
                -- First Aid
                [2326] = {"Thamner Pol","Physician",{[1426]={{47.18,52.61}}},nil,"A"},
                [2327] = {"Shaina Fuller","First Aid Trainer",{[1453]={{43.06,26.16}}},nil,"A"},
                [5759] = {"Nurse Neela","First Aid Trainer",{[1420]={{61.82,52.83}}},nil,"H"},
                [3373] = {"Arnok","First Aid Trainer",{[1454]={{34.18,84.58}}},nil,"H"},
                [5939] = {"Vira Younghoof","First Aid Trainer",{[1412]={{46.8,60.85}}},nil,"H"},
                [5943] = {"Rawrk","First Aid Trainer",{[1411]={{54.17,41.93}}},nil,"H"},
                [6094] = {"Byancie","First Aid Trainer",{[1438]={{55.29,56.82}}},nil,"A"},
                [2798] = {"Pand Stonebinder","First Aid Trainer",{[1456]={{29.69,21.18}}},nil,"H"},
                [5150] = {"Nissa Firestone","First Aid Trainer",{[1455]={{55.09,58.26}}},nil,"A"},
                [3181] = {"Fremal Doohickey","First Aid Trainer",{[1437]={{10.83,61.4}}},nil,"A"},
                [4211] = {"Dannelor","First Aid Trainer",{[1457]={{51.71,12.22}}},nil,"A"},
                [4591] = {"Mary Edras","First Aid Trainer",{[1458]={{73.16,55.15}}},nil,"H"},
                [2329] = {"Michelle Belle","Physician",{[1429]={{43.39,65.55}}},nil,"A"},
                [12920] = {"Doctor Gregory Victor","Trauma Surgeon",{[1417]={{73.41,36.89}}},nil,"H"},
                [12939] = {"Doctor Gustaf VanHowzen","Trauma Surgeon",{[1445]={{67.76,48.97}}},nil,"A"},
            }
        },
    }
}

-- ===== SETTINGS & STATE =====
local ModuleID = "QuickMap"
local HBDPins = LibStub("HereBeDragons-Pins-2.0")
local playerFaction = UnitFactionGroup("player"):sub(1,1) -- "A" or "H"

-- SavedVariables (will be initialized by TOC)
QuickMapDB = QuickMapDB or {}

local MySettings = QuickMapDB.Settings or {
    EnabledCategories = {
        ["AUCTIONEER"] = true,
        ["MAILBOX"] = true,
        ["BANKER"] = true,
        ["REPAIR"] = true,
        ["BATTLEMASTER"] = true,
        ["FLIGHTMASTER"] = true,
        ["SPIRITHEALER"] = true,
        ["INNKEEPER"] = true,
        ["STABLEMASTER"] = true,
        ["VENDOR"] = true,
        ["REAGENTS"] = true,
        ["CLASSTRAINER"] = true,
        ["PROFFTRAINER"] = true,
        ["DUNGEON"] = true,
    }
}
QuickMapDB.Settings = MySettings

-- ===== PIN REFRESH LOGIC =====

local function OnPinEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
    GameTooltip:AddDoubleLine(self.title or "POI", self.faction, 1, 1, 1) -- White Title
    if self.desc and self.desc ~= "" then 
        GameTooltip:AddLine(self.desc, 1, 0.82, 0, true) -- Golden Subtext
    end
    GameTooltip:Show()
end

local function OnPinLeave(self)
    GameTooltip:Hide()
end

-- ===== POOLING & CACHE =====
local pinPool = {}  -- Single pool for all pins
local categoryPins = { Minimap = {}, WorldMap = {} }  -- Separate tracking but created together
local FlattenedData = {}

-- Helper to get a frame from the pool or create one
local function AcquirePin()
    local pin = tremove(pinPool)
    if not pin then
        pin = CreateFrame("Frame", nil, nil)
        pin.tex = pin:CreateTexture(nil, "OVERLAY")
        pin.tex:SetAllPoints()
        pin:SetScript("OnEnter", OnPinEnter)
        pin:SetScript("OnLeave", OnPinLeave)
    end
    pin:Show()
    return pin
end

-- Helper to put all active pins back into the pool
local function ReleaseAllPins()
    for pinType, categories in pairs(categoryPins) do
        for catKey, pins in pairs(categories) do
            for _, pin in ipairs(pins) do
                pin:Hide()
                if pinType == "Minimap" then
                    HBDPins:RemoveMinimapIcon(ModuleID, pin)
                else
                    HBDPins:RemoveWorldMapIcon(ModuleID, pin)
                end
                pinPool[#pinPool + 1] = pin
            end
            wipe(pins)
        end
    end
end

-- ===== DATA FLATTENING (Run this ONCE at load) =====
local function FlattenPOI()
    -- Check if we have valid cached data (account-wide, all factions)
    if QuickMapDB.FlattenedData and 
       QuickMapDB.DataVersion == POI_DATA.version then
        -- Filter cached data by current character's faction
        local startTime = debugprofilestop()
        wipe(FlattenedData)
        for mapID, categories in pairs(QuickMapDB.FlattenedData) do
            for catKey, nodes in pairs(categories) do
                FlattenedData[mapID] = FlattenedData[mapID] or {}
                FlattenedData[mapID][catKey] = {}
                
                local catData = POI_DATA.POI[catKey]
                for _, data in ipairs(nodes) do
                    local npcID = data[3]
                    local npcInfo = catData.nodes[npcID]
                    local faction = npcInfo[5] or "AH"
                    
                    -- Only include if neutral or matches player faction
                    if faction == "AH" or faction == playerFaction then
                        tinsert(FlattenedData[mapID][catKey], data)
                    end
                end
            end
        end
        local duration = debugprofilestop() - startTime
        print(string.format("|cff00ff00[PrephsMapUtility]|r Loaded cached data in |cffffd100%.2fms|r", duration))
        return
    end
    
    local startTime = debugprofilestop() -- Start Timer
    
    -- Flatten ALL factions (account-wide cache)
    local allFactionData = {}
    wipe(FlattenedData)
    
    for catKey, catData in pairs(POI_DATA.POI) do
        for npcID, info in pairs(catData.nodes) do
            -- NIL CHECK: Print which entry has nil spawns
            if not info[3] then
                print(string.format("|cffff0000[PrephsMapUtility]|r NIL spawns table for |cffffd100%s|r -> NPC ID |cffffd100%d|r (|cff00ff00%s|r)", 
                    catKey, npcID, info[1] or "Unknown Name"))
            else
                for mapID, coordsList in pairs(info[3]) do
                    allFactionData[mapID] = allFactionData[mapID] or {}
                    allFactionData[mapID][catKey] = allFactionData[mapID][catKey] or {}
                    
                    for _, coords in ipairs(coordsList) do
                        local data = {
                            coords[1] / 100, 
                            coords[2] / 100, 
                            npcID
                        }
                        tinsert(allFactionData[mapID][catKey], data)
                        
                        -- Also add to current character's faction-filtered data
                        local faction = info[5] or "AH"
                        if faction == "AH" or faction == playerFaction then
                            FlattenedData[mapID] = FlattenedData[mapID] or {}
                            FlattenedData[mapID][catKey] = FlattenedData[mapID][catKey] or {}
                            tinsert(FlattenedData[mapID][catKey], data)
                        end
                    end
                end
            end
        end
    end

    -- Cache ALL faction data (account-wide)
    QuickMapDB.FlattenedData = allFactionData
    QuickMapDB.DataVersion = POI_DATA.version

    local duration = debugprofilestop() - startTime
    print(string.format("|cff00ff00[PrephsMapUtility]|r FlattenPOI took: |cffffd100%.2fms|r", duration))
end

-- ===== ADD/REMOVE SINGLE CATEGORY =====
local function AddCategoryPins(catKey)
    if not MySettings.EnabledCategories[catKey] then return end
    
    local startTime = debugprofilestop()
    
    -- Hoist all lookups outside loops
    local catData = POI_DATA.POI[catKey]
    local mScale = catData.mMapScale or POI_DATA.mMapScale or 1
    local wScale = catData.wMapScale or POI_DATA.wMapScale or 1
    local alpha  = catData.alpha or POI_DATA.alpha or 1
    local mSize, wSize = 12 * mScale, 16 * wScale
    local icon = catData.icon
    local nodes_lookup = catData.nodes
    
    local mmPins = {}
    local wmPins = {}
    categoryPins.Minimap[catKey] = mmPins
    categoryPins.WorldMap[catKey] = wmPins
    
    -- Single pass: create both minimap and worldmap pins together
    for mapID, categories in pairs(FlattenedData) do
        local nodes = categories[catKey]
        if nodes then
            for i = 1, #nodes do
                local data = nodes[i]
                local x, y, npcID = data[1], data[2], data[3]
                local npcInfo = nodes_lookup[npcID]
                local title, desc = npcInfo[1], npcInfo[2]
                local faction = npcInfo[5] or "AH"
                
                -- Minimap pin
                local mPin = AcquirePin()
                mPin:SetSize(mSize, mSize)
                mPin:SetAlpha(alpha)
                mPin.tex:SetTexture(icon)
                mPin.title = title
                mPin.desc = desc
                mPin.faction = faction
                HBDPins:AddMinimapIconMap(ModuleID, mPin, mapID, x, y, true)
                mmPins[#mmPins + 1] = mPin
                
                -- Worldmap pin
                local wPin = AcquirePin()
                wPin:SetSize(wSize, wSize)
                wPin:SetAlpha(alpha)
                wPin.tex:SetTexture(icon)
                wPin.title = title
                wPin.desc = desc
                wPin.faction = faction
                HBDPins:AddWorldMapIconMap(ModuleID, wPin, mapID, x, y, 0)
                wmPins[#wmPins + 1] = wPin
            end
        end
    end
    
    local duration = debugprofilestop() - startTime
    local pinCount = #mmPins
    print(string.format("|cff00ff00[QuickMap]|r Added %s (|cffffd100%d|r pins) in |cffffd100%.2fms|r", catKey, pinCount, duration))
end

local function RemoveCategoryPins(catKey)
    local startTime = debugprofilestop()
    
    local mmPins = categoryPins.Minimap[catKey]
    local wmPins = categoryPins.WorldMap[catKey]
    
    if not mmPins and not wmPins then 
        print(string.format("|cff00ff00[QuickMap]|r Removed %s (0 pins) in 0.00ms", catKey))
        return 
    end
    
    -- Single pass: process both pin types together (same count)
    local pinCount = mmPins and #mmPins or 0
    for i = 1, pinCount do
        -- Minimap pin
        local mPin = mmPins[i]
        mPin:Hide()
        HBDPins:RemoveMinimapIcon(ModuleID, mPin)
        pinPool[#pinPool + 1] = mPin
        
        -- Worldmap pin
        local wPin = wmPins[i]
        wPin:Hide()
        HBDPins:RemoveWorldMapIcon(ModuleID, wPin)
        pinPool[#pinPool + 1] = wPin
    end
    
    if mmPins then wipe(mmPins) end
    if wmPins then wipe(wmPins) end
    
    local duration = debugprofilestop() - startTime
    print(string.format("|cff00ff00[QuickMap]|r Removed %s (|cffffd100%d|r pins) in |cffffd100%.2fms|r", catKey, pinCount, duration))
end

local function ToggleCategory(catKey)
    if MySettings.EnabledCategories[catKey] then
        AddCategoryPins(catKey)
    else
        RemoveCategoryPins(catKey)
    end
end

-- ===== REFRESH MINIMAP PINS ONLY =====
-- ===== REFRESH ALL PINS =====
local function RefreshPins()
    local startTime = debugprofilestop()
    
    ReleaseAllPins()
    wipe(categoryPins.Minimap)
    wipe(categoryPins.WorldMap)
    
    local pinCount = 0
    
    for mapID, categories in pairs(FlattenedData) do
        for catKey, nodes in pairs(categories) do
            if MySettings.EnabledCategories[catKey] then
                categoryPins.Minimap[catKey] = categoryPins.Minimap[catKey] or {}
                categoryPins.WorldMap[catKey] = categoryPins.WorldMap[catKey] or {}
                
                local catData = POI_DATA.POI[catKey]
                local mScale = catData.mMapScale or POI_DATA.mMapScale or 1
                local wScale = catData.wMapScale or POI_DATA.wMapScale or 1
                local alpha  = catData.alpha or POI_DATA.alpha or 1
                local mSize, wSize = 12 * mScale, 16 * wScale
                local icon = catData.icon
                local nodes_lookup = catData.nodes

                for _, data in ipairs(nodes) do
                    local x, y, npcID = data[1], data[2], data[3]
                    local npcInfo = nodes_lookup[npcID]
                    local title, desc = npcInfo[1], npcInfo[2]
                    local faction = npcInfo[5] or "AH"
                    
                    -- Minimap pin
                    local mPin = AcquirePin()
                    mPin:SetSize(mSize, mSize)
                    mPin:SetAlpha(alpha)
                    mPin.tex:SetTexture(icon)
                    mPin.title = title
                    mPin.desc = desc
                    mPin.faction = faction
                    HBDPins:AddMinimapIconMap(ModuleID, mPin, mapID, x, y, true, false)
                    categoryPins.Minimap[catKey][#categoryPins.Minimap[catKey] + 1] = mPin
                    
                    -- Worldmap pin
                    local wPin = AcquirePin()
                    wPin:SetSize(wSize, wSize)
                    wPin:SetAlpha(alpha)
                    wPin.tex:SetTexture(icon)
                    wPin.title = title
                    wPin.desc = desc
                    wPin.faction = faction
                    HBDPins:AddWorldMapIconMap(ModuleID, wPin, mapID, x, y, 0)
                    categoryPins.WorldMap[catKey][#categoryPins.WorldMap[catKey] + 1] = wPin
                    
                    pinCount = pinCount + 1
                end
            end
        end
    end
    
    local duration = debugprofilestop() - startTime
    print(string.format("|cff00ff00[QuickMap]|r RefreshPins (|cffffd100%d|r pins) in |cffffd100%.2fms|r", pinCount, duration))
end
-- 1. CLEANER BUTTON TEXTURES (Fixes the "jagged" look)
local TrackingBtn = CreateFrame("Button", "QuickMapTrackingButton", Minimap)
TrackingBtn:SetSize(32, 32)
TrackingBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -5, -15) 
TrackingBtn:SetFrameLevel(Minimap:GetFrameLevel() + 5)

-- The background circle/border
local background = TrackingBtn:CreateTexture(nil, "BACKGROUND")
background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
background:SetSize(25, 25)
background:SetPoint("CENTER", 0, 0)

-- The actual icon
local icon = TrackingBtn:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\Minimap\\Tracking\\None") -- Default magnifying glass
icon:SetSize(20, 20)
icon:SetPoint("CENTER", 0, 0)

-- The standard Blizzard border
local border = TrackingBtn:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(54, 54)
border:SetPoint("TOPLEFT", 0, 0)

TrackingBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- 2. THE NEW DROPDOWN LOGIC (MenuUtil)
TrackingBtn:SetScript("OnClick", function(self)
    MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
        rootDescription:CreateTitle("QuickMap Tracking")

        -- Alphabetize keys so the menu isn't random
        local sortedKeys = {}
        for k in pairs(POI_DATA.POI) do table.insert(sortedKeys, k) end
        table.sort(sortedKeys)

        for _, key in ipairs(sortedKeys) do
            local label = key:sub(1,1):upper() .. key:sub(2):lower()
            
            -- Create a checkbox entry
            rootDescription:CreateCheckbox(
                label, 
                function() return MySettings.EnabledCategories[key] end, 
                function() 
                    MySettings.EnabledCategories[key] = not MySettings.EnabledCategories[key]
                    ToggleCategory(key)
                end
            )
        end
    end)
end)

-- ===== INITIAL LOAD =====
FlattenPOI()
RefreshPins()