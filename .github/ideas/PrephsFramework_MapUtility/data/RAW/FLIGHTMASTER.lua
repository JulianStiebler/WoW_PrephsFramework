local npcKeys = {
    ['name'] = 1, -- string
    ['minLevelHealth'] = 2, -- int
    ['maxLevelHealth'] = 3, -- int
    ['minLevel'] = 4, -- int
    ['maxLevel'] = 5, -- int
    ['rank'] = 6, -- int, see https://github.com/cmangos/issues/wiki/creature_template#rank
    ['spawns'] = 7, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['waypoints'] = 8, -- table {[zoneID(int)] = {coordPair(floatVector2D),...},...}
    ['zoneID'] = 9, -- guess as to where this NPC is most common
    ['questStarts'] = 10, -- table {questID(int),...}
    ['questEnds'] = 11, -- table {questID(int),...}
    ['factionID'] = 12, -- int, see https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
    ['friendlyToFaction'] = 13, -- string, Contains "A" and/or "H" depending on NPC being friendly towards those factions. nil if hostile to both.
    ['subName'] = 14, -- string, The title or function of the NPC, e.g. "Weapon Vendor"
    ['npcFlags'] = 15, -- int, Bitmask containing various flags about the NPCs function (Vendor, Trainer, Flight Master, etc.).
                       -- For flag values see https://github.com/cmangos/mangos-classic/blob/172c005b0a69e342e908f4589b24a6f18246c95e/src/game/Entities/Unit.h#L536
}

-- Generated table for flag: FLIGHTMASTER (8)
FLIGHTMASTER_Table = {
    [352] = {'Dungar Longdrink',7842,7842,55,55,1,{[1519]={{66.27,62.13}}},nil,1519,{6285},{6261},12,"A","Gryphon Master",11},
    [523] = {'Thor',7842,7842,55,55,1,{[40]={{56.55,52.64}}},nil,40,{6281},{6181},12,"A","Gryphon Master",11},
    [931] = {'Ariena Stormfeather',7842,7842,55,55,1,{[44]={{30.59,59.41}}},nil,44,nil,nil,12,"A","Gryphon Master",11},
    [1387] = {'Thysta',7842,7842,55,55,1,{[33]={{32.54,29.35}}},nil,33,nil,nil,29,"H","Wind Rider Master",11},
    [1571] = {'Shellei Brondir',7842,7842,55,55,1,{[11]={{9.49,59.69}}},nil,11,nil,nil,12,"A","Gryphon Master",11},
    [1572] = {'Thorgrum Borrelson',7842,7842,55,55,1,{[38]={{33.94,50.95}}},nil,38,{6391},{6387},55,"A","Gryphon Master",11},
    [1573] = {'Gryth Thurden',7842,7842,55,55,1,{[1537]={{55.5,47.74}}},nil,1537,{6392},{6388},55,"A","Gryphon Master",11},
    [2226] = {'Karos Razok',7842,7842,55,55,1,{[130]={{45.62,42.6}}},nil,130,{6323},{6321},68,"H","Bat Handler",11},
    [2299] = {'Borgus Stoutarm',7842,7842,55,55,1,{[46]={{84.33,68.33}}},nil,46,nil,nil,55,"A","Gryphon Master",11},
    [2389] = {'Zarise',7842,7842,55,55,1,{[267]={{60.14,18.62}}},nil,267,nil,nil,68,"H","Bat Handler",11},
    [2409] = {'Felicia Maline',7842,7842,55,55,1,{[10]={{77.49,44.29}}},nil,10,nil,nil,12,"A","Gryphon Master",11},
    [2432] = {'Darla Harris',7842,7842,55,55,1,{[267]={{49.34,52.27}}},nil,267,nil,nil,12,"A","Gryphon Master",11},
    [2835] = {'Cedrik Prose',7842,7842,55,55,1,{[45]={{45.73,46.1}}},nil,45,nil,nil,12,"A","Gryphon Master",11},
    [2851] = {'Urda',7842,7842,55,55,1,{[45]={{73.02,32.7}}},nil,45,nil,nil,29,"H","Wind Rider Master",11},
    [2858] = {'Gringer',7842,7842,55,55,1,{[33]={{26.87,77.1}}},nil,33,nil,nil,29,"H","Wind Rider Master",11},
    [2859] = {'Gyll',7842,7842,55,55,1,{[33]={{27.53,77.79}}},nil,33,nil,nil,55,"A","Gryphon Master",11},
    [2861] = {'Gorrik',7842,7842,55,55,1,{[3]={{3.99,44.78}}},nil,3,nil,nil,29,"H","Wind Rider Master",11},
    [2941] = {'Lanie Reed',7842,7842,55,55,1,{[51]={{37.94,30.86}}},nil,51,nil,nil,55,"A","Gryphon Master",11},
    [2995] = {'Tal',7842,7842,55,55,1,{[1638]={{47.0,49.83}}},nil,1638,{6364},{6363},104,"H","Wind Rider Master",11},
    [3305] = {'Grisha',7842,7842,55,55,1,{[51]={{34.84,30.87}}},nil,51,nil,nil,29,"H","Wind Rider Master",11},
    [3310] = {'Doras',7842,7842,55,55,1,{[1637]={{45.12,63.89}}},nil,1637,{6386},{6385},29,"H","Wind Rider Master",11},
    [3615] = {'Devrak',7842,7842,55,55,1,{[17]={{51.5,30.34}}},nil,17,{6362,6384},{6361,6365},29,"H","Wind Rider Master",11},
    [3838] = {'Vesprystus',7842,7842,55,55,1,{[141]={{58.4,94.02}}},nil,141,{6342},{6341},80,"A","Hippogryph Master",11},
    [3841] = {'Caylais Moonfeather',7842,7842,55,55,1,{[148]={{36.34,45.58}}},nil,148,nil,nil,80,"A","Hippogryph Master",11},
    [4267] = {'Daelyshia',7842,7842,55,55,1,{[331]={{34.41,47.99}}},nil,331,nil,nil,80,"A","Hippogryph Master",11},
    [4312] = {'Tharm',7842,7842,55,55,1,{[406]={{45.12,59.84}}},nil,406,nil,nil,104,"H","Wind Rider Master",11},
    [4314] = {'Gorkas',7842,7842,55,55,1,{[47]={{81.7,81.76}}},nil,47,nil,nil,29,"H","Wind Rider Master",11},
    [4317] = {'Nyse',7842,7842,55,55,1,{[400]={{45.14,49.11}}},nil,400,nil,nil,104,"H","Wind Rider Master",11},
    [4319] = {'Thyssiana',7842,7842,55,55,1,{[357]={{89.5,45.85}}},nil,357,nil,nil,80,"A","Hippogryph Master",11},
    [4321] = {'Baldruc',7842,7842,55,55,1,{[15]={{67.48,51.3}}},nil,15,nil,nil,894,"A","Gryphon Master",11},
    [4407] = {'Teloren',7842,7842,55,55,1,{[406]={{36.44,7.18}}},nil,406,nil,nil,80,"A","Hippogryph Master",11},
    [4551] = {'Michael Garrett',7842,7842,55,55,1,{[1497]={{63.25,48.56}}},nil,1497,{6324},{6322},68,"H","Bat Handler",11},
    [6026] = {'Breyk',7842,7842,55,55,1,{[8]={{46.07,54.83}}},nil,8,nil,nil,29,"H","Wind Rider Master",11},
    [6706] = {'Baritanas Skyriver',7842,7842,55,55,1,{[405]={{64.66,10.54}}},nil,405,nil,nil,80,"A","Hippogryph Master",11},
    [6726] = {'Thalon',7842,7842,55,55,1,{[405]={{21.6,74.13}}},nil,405,nil,nil,104,"H","Wind Rider Master",11},
    [7823] = {'Bera Stonehammer',7842,7842,55,55,1,{[440]={{51.01,29.34}}},nil,440,nil,nil,12,"A","Gryphon Master",11},
    [7824] = {'Bulkrek Ragefist',7842,7842,55,55,1,{[440]={{51.6,25.44}}},nil,440,nil,nil,29,"H","Wind Rider Master",11},
    [8018] = {'Guthrum Thunderfist',7842,7842,55,55,1,{[47]={{11.07,46.15}}},nil,47,nil,nil,694,"A","Gryphon Master",11},
    [8019] = {'Fyldren Moonfeather',7842,7842,55,55,1,{[357]={{30.24,43.25}}},nil,357,nil,nil,80,"A","Hippogryph Master",11},
    [8020] = {'Shyn',7842,7842,55,55,1,{[357]={{75.45,44.36}}},nil,357,nil,nil,104,"H","Wind Rider Master",11},
    [8609] = {'Alexandra Constantine',7842,7842,55,55,1,{[4]={{65.54,24.34}}},nil,4,nil,nil,12,"A","Gryphon Master",11},
    [8610] = {'Kroum',7842,7842,55,55,1,{[16]={{21.96,49.62}}},nil,16,nil,nil,29,"H","Wind Rider Master",11},
    [10378] = {'Omusa Thunderhorn',7842,7842,55,55,1,{[17]={{44.45,59.15}}},nil,17,nil,nil,104,"H","Wind Rider Master",11},
    [10583] = {'Gryfe',7842,7842,55,55,1,{[490]={{45.23,5.83}}},nil,490,nil,nil,474,"AH","Flight Master",11},
    [10897] = {'Sindrayl',7842,7842,55,55,1,{[493]={{48.1,67.34}}},nil,493,nil,nil,80,"A","Hippogryph Master",11},
    [11138] = {'Maethrya',7842,7842,55,55,1,{[618]={{62.33,36.61}}},nil,618,nil,nil,80,"A","Hippogryph Master",11},
    [11139] = {'Yugrek',7842,7842,55,55,1,{[618]={{60.47,36.3}}},nil,618,nil,nil,29,"H","Wind Rider Master",11},
    [11899] = {'Shardi',7842,7842,55,55,1,{[15]={{35.56,31.88}}},nil,15,nil,nil,29,"H","Wind Rider Master",11},
    [11900] = {'Brakkar',7842,7842,55,55,1,{[361]={{34.44,53.96}}},nil,361,nil,nil,29,"H","Wind Rider Master",11},
    [11901] = {'Andruk',7842,7842,55,55,1,{[331]={{12.24,33.8}}},nil,331,nil,nil,29,"H","Wind Rider Master",11},
    [12577] = {'Jarrodenus',7842,7842,55,55,1,{[16]={{11.9,77.59}}},nil,16,nil,nil,80,"A","Hippogryph Master",11},
    [12578] = {'Mishellena',7842,7842,55,55,1,{[361]={{62.49,24.24}}},nil,361,nil,nil,80,"A","Hippogryph Master",11},
    [12596] = {'Bibilfaz Featherwhistle',7842,7842,55,55,1,{[28]={{42.92,85.06}}},nil,28,nil,nil,12,"A","Gryphon Master",11},
    [12616] = {'Vhulgra',7842,7842,55,55,1,{[331]={{73.18,61.59}}},nil,331,nil,nil,29,"H","Wind Rider Master",11},
    [12617] = {'Khaelyn Steelwing',7842,7842,55,55,1,{[139]={{81.64,59.28}}},nil,139,nil,nil,55,"A","Gryphon Master",11},
    [12636] = {'Georgia',7842,7842,55,55,1,{[139]={{80.22,57.01}}},nil,139,nil,nil,68,"H","Bat Handler",11},
    [12740] = {'Faustron',7842,7842,55,55,1,{[493]={{32.09,66.61}}},nil,493,nil,nil,29,"H","Wind Rider Master",11},
    [13177] = {'Vahgruk',7842,7842,55,55,1,{[46]={{65.69,24.22}}},nil,46,nil,nil,29,"H","Wind Rider Master",11},
    [15177] = {'Cloud Skydancer',7842,7842,55,55,1,{[1377]={{50.58,34.45}}},nil,1377,nil,nil,80,"A","Hippogryph Master",11},
    [15178] = {'Runk Windtamer',7842,7842,55,55,1,{[1377]={{48.68,36.67}}},nil,1377,nil,nil,104,"H","Wind Rider Master",11},
    [16227] = {'Bragok',7842,7842,55,55,1,{[17]={{63.08,37.16}}},nil,17,nil,nil,69,"AH","Flight Master",11},
}
