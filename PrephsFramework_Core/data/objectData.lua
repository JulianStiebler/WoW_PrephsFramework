--[[
    <PrephsFramework_Core/data/objectData.lua>
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

---@class PrephsFramework.data.objData
local objData = Core.data.objData
local objFlags = Core.Constants.Bitmasks.objFlags
objData.keys = {
    ['name'] = 1, -- string
    ['subName'] = 2, -- string, The title or function of the NPC, e.g. "Weapon Vendor"
    ['spawns'] = 3, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['waypoints'] = 4, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...} or nil
    ['friendlyToFaction'] = 5, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    ['objFlags'] = 6, -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
                      -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
    ['metaData'] = 7, -- table {questStarts, questEnds, factionID} or nil
                      -- questStarts: table {questID(int),...} or nil
                      -- questEnds: table {questID(int),...} or nil
                      -- factionID: int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
}
objData.entries = {
        [objFlags.DUNGEON] = {
        [179596] = {"Meeting Stone","Ragefire Chasm (13-18)",{[1454]={{51.44,48.7}}},nil,"AH", objFlags.DUNGEON, nil},
        [178884] = {"Meeting Stone","Wailing Caverns (17-24)",{[1413]={{46.96,35.61}}},nil,"AH", objFlags.DUNGEON, nil},
        [178834] = {"Meeting Stone","The Deadmines (17-26)",{[1436]={{41.59,72.4}}},nil,"AH", objFlags.DUNGEON, nil},
        [178828] = {"Meeting Stone","Blackfathom Depths (20-30)",{[1440]={{15.36,15.55}}},nil,"AH", objFlags.DUNGEON, nil},
        [178845] = {"Meeting Stone","Shadowfang Keep (22-30)",{[1421]={{46.21,68.35}}},nil,"AH", objFlags.DUNGEON, nil},
        [179595] = {"Meeting Stone","The Stockades (24-32)",{[1453]={{43.36,59.31}}},nil,"AH", objFlags.DUNGEON, nil},
        [178844] = {"Meeting Stone","Scarlet Monastery (26-45)\nGraveyard (26-26)\nLibrary (29-39)\nArmory (32-42)\nCathedral (35-45)",{[1420]={{82.14,39.22}}},nil,"AH", objFlags.DUNGEON, nil},
        [179555] = {"Meeting Stone","Gnomeregan (29-38)",{[1426]={{24.27,40.4}}},nil,"AH", objFlags.DUNGEON, nil},
        [178825] = {"Meeting Stone","Razorfen Kraul (30-40)",{[1413]={{43.72,89.96}}},nil,"AH", objFlags.DUNGEON, nil},
        [178824] = {"Meeting Stone","Razorfen Downs (37-46)",{[1413]={{45.16,88.61}}},nil,"AH", objFlags.DUNGEON, nil},
        [178833] = {"Meeting Stone","Uldaman (41-51)",{[1418]={{49.06,13.68}}},nil,"AH", objFlags.DUNGEON, nil},
        [178829] = {"Meeting Stone","Zul'Farrak (44-54)",{[1446]={{38.49,20.74}}},nil,"AH", objFlags.DUNGEON, nil},
        [178827] = {"Meeting Stone","Maraudon (46-55)",{[1443]={{31.5,62.36}}},nil,"AH", objFlags.DUNGEON, nil},
        [179554] = {"Meeting Stone","Sunken Temple (50-60)",{[1435]={{69.1, 54.7}}},nil,"AH", objFlags.DUNGEON, nil},
        [179585] = {"Meeting Stone","Blackrock Depths (52-60)",{[1428]={{32.77,30.43}}},nil,"AH", objFlags.DUNGEON, nil},
        [179584] = {"Meeting Stone","LBRS (55-60)\nUBRS (55-60)",{[1428]={{29.8, 28.7}}},nil,"AH", objFlags.DUNGEON, nil},
        [178826] = {"Meeting Stone","Dire Maul\nEast (55-60)\nWest (58-60)\nNorth (58-60)",{[1444]={{57.97,44.48}}},nil,"AH", objFlags.DUNGEON, nil},
        [178832] = {"Meeting Stone","Scholomance (58-60)",{[1422]={{69.5,74.46}}},nil,"AH", objFlags.DUNGEON, nil},
        [178831] = {"Meeting Stone","Strathholme (58-60)",{[1423]={{30.85,16.56}}},nil,"AH", objFlags.DUNGEON, nil},
        [1788300] = {"Dungeon Entrance","Srvice Entrance\nStrathholme (58-60)",{[1423]={{47.81,22.83}}},nil,"AH", objFlags.DUNGEON, nil},

        [1788301] = {"Dungeon Entrance","Karazhan Crypts (60)",{[1430]={{39.41, 73.66}}},nil,"AH", objFlags.DUNGEON, nil},
        [1788302] = {"Dungeon Entrance","Demonfall Canyon (60)",{[1440]={{84.56, 75.29}}},nil,"AH", objFlags.DUNGEON, nil},
    },
    [objFlags.RAID] = {
        [1788311] = {"Raid Entrance","Onyxia's Lair",{[1445]={{51.01,77.71}}},nil,"AH", objFlags.RAID, nil},
        [1788312] = {"Raid Entrance","Blackwing Lair\nMolten Core",{[1428]={{27.17, 30.44}}},nil,"AH", objFlags.RAID, nil},
        [1788313] = {"Raid Entrance","Zul'Gurub",{[1434]={{50.52, 17.53}}},nil,"AH", objFlags.RAID, nil},
        [1788314] = {"Raid Entrance","Ahn Qiraj",{[1451]={{29.09, 96.96}}},nil,"AH", objFlags.RAID, nil},
        [1788315] = {"Raid Entrance","Naxxramas",{[1423]={{43.00, 26.00}}},nil,"AH", objFlags.RAID, nil},
        [1788316] = {"Raid Entrance","Scarlet Enclave",{[1423]={{71.25, 87.00}}},nil,"AH", objFlags.RAID, nil},
        [1788317] = {"Raid Entrance","Thunderaan",{[1451]={{21.89, 10.52}}},nil,"AH", objFlags.RAID, nil},

        -- SoD Exclusive
        [1788331] = {"Raid Entrance","Azuregos",{[1447]={{33.00, 81.00}}},nil,"AH", objFlags.RAID, nil},
        [1788332] = {"Raid Entrance","Kazzak",{[1419]={{43.96, 55.27}}},nil,"AH", objFlags.RAID, nil},
        [1788333] = {"Raid Entrance","Nightmare Dragons",{[1431]={{46.55, 37.69}}},nil,"AH", objFlags.RAID, nil},

    },
    [objFlags.MAILBOX] = {
        [180451] = {"Mailbox",nil,{[230]={{51.75,37.97}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Uldaman
        [143981] = {"Mailbox",nil,{[1411]={{51.9,42.15}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Durotar
        [143984] = {"Mailbox",nil,{[1412]={{47.01,60.3}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Mulgore
        [143982] = {"Mailbox",nil,{[1413]={{52.03,30.43}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- The Barrens
        [153578] = {"Mailbox",nil,{[1413]={{45.08,58.67}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- The Barrens
        [144125] = {"Mailbox",nil,{[1413]={{62.16,39.19}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- The Barrens
        [164840] = {"Mailbox",nil,{[1417]={{73.86,33.11}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Arathi Highlands
        [163313] = {"Mailbox",nil,{[1418]={{3.83,47.3}}},nil,"AH", objFlags.MAILBOX, nil},                                    -- Badlands                 
        [164618] = {"Mailbox",nil,{[1419]={{64.06,19.22}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Blasted Lands
        [143990] = {"Mailbox",nil,{[1420]={{61.5,53.08}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Tirisfal
        [143989] = {"Mailbox",nil,{[1421]={{43.41,41.52}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Silverpine Forest
        [181236] = {"Mailbox",nil,{[1423]={{80.94,58.52}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Eastern Plaguelands LHC
        [143988] = {"Mailbox",nil,{[1424]={{62.38,19.71}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Hillsbrad Foothills
        [143987] = {"Mailbox",nil,{[1424]={{50.42,58.7}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Hillsbrad Foothills
        [179895] = {"Mailbox",nil,{[1425]={{78.84,80.5}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- The Hinterlands
        [144011] = {"Mailbox",nil,{[1425]={{14.04,45.7}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- The Hinterlands
        [142102] = {"Mailbox",nil,{[1426]={{47.02,52.58}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Dun Morogh
        [142075] = {"Mailbox",nil,{[1429]={{42.92,65.52}},[1453]={{22.13,57.81}}},nil,"AH", objFlags.MAILBOX, nil},           -- Elwynn Forrest & Stormwind City
        [142089] = {"Mailbox",nil,{[1431]={{73.73,46.1}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Duskwood
        [142103] = {"Mailbox",nil,{[1432]={{34.82,47.73}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Loch Modan
        [142093] = {"Mailbox",nil,{[1433]={{26.41,46.51}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Redridge Mountains
        [144126] = {"Mailbox",nil,{[1434]={{26.7,76.36}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Stranglethorn Vale
        [144127] = {"Mailbox",nil,{[1434]={{27.28,77.41}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Stranglethorn Vale
        [163645] = {"Mailbox",nil,{[1434]={{32.52,28.65}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Stranglethorn Vale
        [157637] = {"Mailbox",nil,{[1435]={{45.44,55.14}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Swamp of Sorrows
        [153716] = {"Mailbox",nil,{[1436]={{53.1,53.34}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Westfall
        [142094] = {"Mailbox",nil,{[1437]={{10.86,59.72}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Wetlands
        [142109] = {"Mailbox",nil,{[1438]={{56.12,58.43}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Teldrassil
        [142111] = {"Mailbox",nil,{[1439]={{37.32,43.73}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Darkshore
        [178864] = {"Mailbox",nil,{[1440]={{73.63,60.89}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Ashenvale
        [142117] = {"Mailbox",nil,{[1440]={{36.33,50.22}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Ashenvale
        [176324] = {"Mailbox",nil,{[1441]={{45.85,51.06}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Thousand Needles
        [143983] = {"Mailbox",nil,{[1442]={{48.01,61.14}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Stonetalon Mountains
        [181639] = {"Mailbox",nil,{[1442]={{36.02,7.21}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Stonetalon Mountains
        [179896] = {"Mailbox",nil,{[1443]={{24.79,68.76}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Desolace
        [176319] = {"Mailbox",nil,{[1443]={{65.43,6.8}}},nil,"AH", objFlags.MAILBOX, nil},                                    -- Dseolace
        [142119] = {"Mailbox",nil,{[1444]={{31.26,43.8}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Feralas
        [143986] = {"Mailbox",nil,{[1444]={{74.88,44.0}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Feralas
        [142095] = {"Mailbox",nil,{[1445]={{65.96,45.29}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Dustwallow
        [144112] = {"Mailbox",nil,{[1446]={{52.33,27.81}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Tanaris
        [187260] = {"Mailbox",nil,{[1448]={{34.82,52.95}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Felwood
        [176404] = {"Mailbox",nil,{[1452]={{61.28,38.62}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Winterspring
        [144128] = {"Mailbox",nil,{[1453]={{70.91,40.01}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Stormwind City
        [144129] = {"Mailbox",nil,{[1453]={{39.94,84.4}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Stormwind City
        [144131] = {"Mailbox",nil,{[1453]={{54.23,66.73}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Stormwind City
        [173047] = {"Mailbox",nil,{[1454]={{62.26,40.51}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Orgrimmar
        [173221] = {"Mailbox",nil,{[1454]={{50.69,70.37}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Orgrimmar
        [32349] = {"Mailbox",nil,{[1455]={{20.96,52.41}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Ironforge
        [171556] = {"Mailbox",nil,{[1455]={{71.31,72.13}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Ironforge
        [171699] = {"Mailbox",nil,{[1455]={{33.22,64.66}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Ironforge
        [171752] = {"Mailbox",nil,{[1455]={{72.28,49.1}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Ironforge
        [143985] = {"Mailbox",nil,{[1456]={{45.23,59.4}}},nil,"AH", objFlags.MAILBOX, nil},                                   -- Thunder Bluff
        [188123] = {"Mailbox",nil,{[1457]={{67.18,16.47}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Darnassus
        [142110] = {"Mailbox",nil,{[1457]={{41.63,41.85}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Darnassus
        [177044] = {"Mailbox",nil,{[1458]={{68.16,38.26}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Undercity

        -- SoD Exclusive
        [529383] = {"Mailbox",nil,{[1423]={{90.32,81.98}}},nil,"AH", objFlags.MAILBOX, nil},                                  -- Eastern Plaguelands New Avalon
    }
}
