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

-- Generated table for flag: STABLEMASTER (8192)
STABLEMASTER_Table = {
    [6749] = {'Erma',950,950,29,29,0,{[12]={{42.85,65.95}}},nil,12,nil,nil,12,"A","Stable Master",8193},
    [9976] = {'Tharlidun',1002,1002,30,30,0,{[45]={{73.93,33.13}}},nil,45,nil,nil,29,"H","Stable Master",8193},
    [9977] = {'Sylista',1002,1002,30,30,0,{[1519]={{29.59,51.22}}},nil,1519,nil,nil,12,"A","Stable Master",8193},
    [9978] = {'Wesley',1002,1002,30,30,0,{[267]={{50.42,58.8}}},nil,267,nil,nil,12,"A","Stable Master",8193},
    [9979] = {'Sarah Goode',1002,1002,30,30,0,{[130]={{43.45,41.18}}},nil,130,nil,nil,68,"H","Stable Master",8193},
    [9980] = {'Shelby Stoneflint',1002,1002,30,30,0,{[1]={{47.01,52.66}}},nil,1,nil,nil,55,"A","Stable Master",8193},
    [9981] = {'Sikwa',1002,1002,30,30,0,{[17]={{51.74,29.66}}},nil,17,nil,nil,29,"H","Stable Master",8193},
    [9982] = {'Penny',1002,1002,30,30,0,{[44]={{26.8,46.56}}},nil,44,nil,nil,12,"A","Stable Master",8193},
    [9983] = {'Kelsuwa',1002,1002,30,30,0,{[17]={{45.3,58.66}}},nil,17,nil,nil,104,"H","Stable Master",8193},
    [9984] = {'Ulbrek Firehand',1002,1002,30,30,0,{[1537]={{69.3,83.58}}},nil,1537,nil,nil,55,"A","Stable Master",8193},
    [9985] = {'Laziphus',1002,1002,30,30,0,{[440]={{52.25,28.0}}},nil,440,nil,nil,474,"AH","Stable Master",8193},
    [9986] = {'Shyrka Wolfrunner',1002,1002,30,30,0,{[357]={{74.49,43.27}}},nil,357,nil,nil,29,"H","Stable Master",8193},
    [9989] = {'Lina Hearthstove',1002,1002,30,30,0,{[38]={{34.64,48.09}}},nil,38,nil,nil,55,"A","Stable Master",8193},
    [10045] = {'Kirk Maxwell',1002,1002,30,30,0,{[40]={{52.94,53.07}}},nil,40,nil,nil,12,"A","Stable Master",8193},
    [10046] = {'Bethaine Flinthammer',1002,1002,30,30,0,{[11]={{10.53,59.73}}},nil,11,nil,nil,55,"A","Stable Master",8193},
    [10047] = {'Michael',1002,1002,30,30,0,{[15]={{66.01,45.5}}},nil,15,nil,nil,894,"A","Stable Master",8193},
    [10048] = {'Gereck',3014,3014,58,58,0,{[406]={{47.93,61.39}}},nil,406,nil,nil,29,"H","Stable Master",8193},
    [10049] = {'Hekkru',1002,1002,30,30,0,{[8]={{45.56,55.15}}},nil,8,nil,nil,29,"H","Stable Master",8193},
    [10050] = {'Seikwa',1002,1002,30,30,0,{[215]={{46.76,60.36}}},nil,215,nil,nil,29,"H","Stable Master",8193},
    [10051] = {'Seriadne',1002,1002,30,30,0,{[141]={{56.63,59.62}}},nil,141,nil,nil,80,"A","Stable Master",8193},
    [10052] = {'Maluressian',1002,1002,30,30,0,{[331]={{36.51,50.36}}},nil,331,nil,nil,80,"A","Stable Master",8193},
    [10053] = {'Anya Maulray',1002,1002,30,30,0,{[1497]={{67.42,37.59}}},nil,1497,nil,nil,68,"H","Stable Master",8193},
    [10054] = {'Bulrug',1002,1002,30,30,0,{[1638]={{45.09,60.23}}},nil,1638,nil,nil,29,"H","Stable Master",8193},
    [10055] = {'Morganus',1002,1002,30,30,0,{[85]={{60.03,52.16}}},nil,85,nil,nil,68,"H","Stable Master",8193},
    [10056] = {'Alassin',1002,1002,30,30,0,{[1657]={{39.27,10.05}}},nil,1657,nil,nil,80,"A","Stable Master",8193},
    [10057] = {'Theodore Mont Claire',1002,1002,30,30,0,{[267]={{62.31,19.7}}},nil,267,nil,nil,68,"H","Stable Master",8193},
    [10058] = {'Greth',1002,1002,30,30,0,{[3]={{3.66,47.58}}},nil,3,nil,nil,29,"H","Stable Master",8193},
    [10059] = {'Antarius',1002,1002,30,30,0,{[357]={{31.47,43.15}}},nil,357,nil,nil,80,"A","Stable Master",8193},
    [10060] = {'Grimestack',2398,2398,46,46,0,{[33]={{27.29,77.22}}},nil,33,nil,nil,120,"AH","Stable Master",8193},
    [10061] = {'Killium Bouldertoe',1002,1002,30,30,0,{[47]={{14.41,45.22}}},nil,47,nil,nil,694,"A","Stable Master",8193},
    [10062] = {'Steven Black',1002,1002,30,30,0,{[10]={{74.02,46.11}}},nil,10,nil,nil,12,"A","Stable Master",8193},
    [10063] = {'Reggifuz',1342,1342,35,35,0,{[17]={{62.18,39.21}}},nil,17,nil,nil,69,"AH","Stable Master",8193},
    [10085] = {'Jaelysia',1002,1002,30,30,0,{[148]={{37.4,44.28}}},nil,148,nil,nil,80,"A","Stable Master",8193},
    [11069] = {'Jenova Stoneshield',3014,3014,58,58,0,{[1519]={{61.47,17.17}}},nil,1519,nil,nil,12,"A","Stable Master",8193},
    [11104] = {'Shelgrayn',1002,1002,30,30,0,{[405]={{65.61,7.84}}},nil,405,nil,nil,80,"A","Stable Master",8193},
    [11105] = {'Aboda',950,950,29,29,0,{[405]={{24.9,68.67}}},nil,405,nil,nil,104,"H","Stable Master",8193},
    [11117] = {'Awenasa',1002,1002,30,30,0,{[400]={{45.77,51.07}}},nil,400,nil,nil,104,"H","Stable Master",8193},
    [11119] = {'Azzleby',3014,3014,58,58,0,{[618]={{60.39,37.92}}},nil,618,nil,nil,855,"AH","Stable Master",8193},
    [13616] = {'Frostwolf Stable Master',45780,45780,60,60,1,{[2597]={{57.16,82.45}}},nil,2597,{7001},{7001},1214,"H","Stable Master",8195},
    [13617] = {'Stormpike Stable Master',45780,45780,60,60,1,{[2597]={{42.55,16.82}}},nil,2597,{7027},{7027},1216,"A","Stable Master",8195},
    [14741] = {'Huntsman Markhor',1848,1848,45,45,0,{[47]={{79.16,79.53}}},nil,47,{7828,7829,7830,7849},{7828,7829,7830,7849},1494,"H","Stable Master",8195},
    [15131] = {'Qeeju',1848,1848,45,45,0,{[331]={{73.38,61.02}}},nil,331,nil,nil,29,"H","Stable Master",8193},
    [16094] = {'Durik',1002,1002,30,30,0,{[33]={{31.87,29.5}}},nil,33,nil,nil,29,"H","Stable Master",8193},
}
