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

-- Generated table for flag: INNKEEPER (128)
INNKEEPER_Table = {
    [295] = {'Innkeeper Farley',1002,1002,30,30,0,{[12]={{43.77,65.8}}},nil,12,{70},{69,2158},12,"A","Innkeeper",135},
    [384] = {'Katie Hunter',198,198,10,10,0,{[12]={{84.15,65.49}}},nil,12,{7677,7678},{7677,7678},12,"A","Horse Breeder",135},
    [1247] = {'Innkeeper Belm',1002,1002,30,30,0,{[1]={{47.38,52.52}}},nil,1,nil,nil,55,"A","Innkeeper",135},
    [1261] = {'Veron Amberstill',198,198,10,10,0,{[1]={{63.47,50.56}}},{[1]={{{63.47,50.56},{63.46,50.63}}}},1,{7673,7674},{7673,7674},55,"A","Ram Breeder",135},
    [1464] = {'Innkeeper Helbrek',1002,1002,30,30,0,{[11]={{10.7,60.95}}},nil,11,nil,nil,55,"A","Innkeeper",135},
    [2352] = {'Innkeeper Anderson',1002,1002,30,30,0,{[267]={{51.17,58.93}}},nil,267,nil,nil,12,"A","Innkeeper",135},
    [2388] = {'Innkeeper Shay',1002,1002,30,30,0,{[267]={{62.78,19.03}}},nil,267,nil,nil,68,"H","Innkeeper",135},
    [3362] = {'Ogunaro Wolfrunner',2217,2217,45,45,0,{[1637]={{69.38,12.24}}},nil,1637,{7660,7661},{7660,7661},29,"H","Kennel Master",135},
    [3685] = {'Harb Clawhoof',2217,2217,45,45,0,{[215]={{47.49,58.6}}},nil,215,{7662,7663},{7662,7663},104,"H","Kodo Mounts",135},
    [3934] = {'Innkeeper Boorand Plainswind',1002,1002,30,30,0,{[17]={{51.99,29.89}}},nil,17,nil,nil,29,"H","Innkeeper",135},
    [4730] = {'Lelanai',1342,1342,35,35,0,{[1657]={{38.28,15.36}}},nil,1657,{7671,7672},{7671,7672},80,"A","Saber Handler",135},
    [4731] = {'Zachariah Post',1002,1002,30,30,0,{[85]={{59.87,52.68}}},nil,85,nil,nil,68,"H","Undead Horse Merchant",133},
    [5111] = {'Innkeeper Firebrew',1002,1002,30,30,0,{[1537]={{18.15,51.45}}},nil,1537,{3790,8353},{8353},55,"A","Innkeeper",135},
    [5688] = {'Innkeeper Renee',1002,1002,30,30,0,{[85]={{61.71,52.05}}},nil,85,nil,{8},68,"H","Innkeeper",135},
    [5814] = {'Innkeeper Thulbek',895,895,28,28,0,{[33]={{31.49,29.75}}},nil,33,nil,nil,29,"H","Innkeeper",135},
    [6272] = {'Innkeeper Janene',1002,1002,30,30,0,{[15]={{66.59,45.22}}},nil,15,nil,nil,894,"A","Innkeeper",135},
    [6727] = {'Innkeeper Brianna',1002,1002,30,30,0,{[44]={{27.01,44.82}}},nil,44,nil,nil,12,"A","Innkeeper",135},
    [6734] = {'Innkeeper Hearthstove',1002,1002,30,30,0,{[38]={{35.53,48.4}}},nil,38,nil,nil,55,"A","Innkeeper",135},
    [6735] = {'Innkeeper Saelienne',1002,1002,30,30,0,{[1657]={{67.42,15.65}}},nil,1657,{3763,8357},{8357},80,"A","Innkeeper",135},
    [6736] = {'Innkeeper Keldamyr',1002,1002,30,30,0,{[141]={{55.62,59.79}}},nil,141,nil,{2159},80,"A","Innkeeper",135},
    [6737] = {'Innkeeper Shaussiy',1002,1002,30,30,0,{[148]={{37.04,44.13}}},nil,148,nil,nil,80,"A","Innkeeper",135},
    [6738] = {'Innkeeper Kimlya',1002,1002,30,30,0,{[331]={{36.99,49.22}}},nil,331,nil,nil,80,"A","Innkeeper",135},
    [6739] = {'Innkeeper Bates',1002,1002,30,30,0,{[130]={{43.18,41.28}}},nil,130,nil,nil,68,"H","Innkeeper",135},
    [6740] = {'Innkeeper Allison',1002,1002,30,30,0,{[1519]={{52.62,65.7}}},nil,1519,{3789,8356,9027},{8356,8860,9026},12,"A","Innkeeper",135},
    [6741] = {'Innkeeper Norman',1002,1002,30,30,0,{[1497]={{67.74,37.89}}},nil,1497,{3784,8354,8983},{8354,8982},68,"H","Innkeeper",135},
    [6746] = {'Innkeeper Pala',1002,1002,30,30,0,{[1638]={{45.81,64.71}}},nil,1638,{3762,5928,8360},{8360,8861},104,"H","Innkeeper",135},
    [6747] = {'Innkeeper Kauth',1002,1002,30,30,0,{[215]={{46.62,61.09}}},nil,215,nil,{1656},29,"H","Innkeeper",135},
    [6790] = {'Innkeeper Trelayne',1002,1002,30,30,0,{[10]={{73.87,44.41}}},nil,10,nil,nil,12,"A","Innkeeper",135},
    [6791] = {'Innkeeper Wiley',1342,1342,35,35,0,{[17]={{62.05,39.41}}},nil,17,nil,nil,69,"AH","Innkeeper",135},
    [6807] = {'Innkeeper Skindle',2398,2398,46,46,0,{[33]={{27.04,77.31}}},nil,33,nil,nil,120,"AH","Innkeeper",135},
    [6928] = {'Innkeeper Grosk',1002,1002,30,30,0,{[14]={{51.51,41.64}}},nil,14,nil,{2161},29,"H","Innkeeper",135},
    [6929] = {'Innkeeper Gryshka',1002,1002,30,30,0,{[1637]={{54.1,68.41}}},nil,1637,{936,6385,8359},{6384,8359},29,"H","Innkeeper",135},
    [6930] = {'Innkeeper Karakul',1002,1002,30,30,0,{[8]={{45.16,56.66}}},nil,8,nil,nil,29,"H","Innkeeper",135},
    [7714] = {'Innkeeper Byula',1002,1002,30,30,0,{[17]={{45.58,59.04}}},nil,17,nil,nil,29,"H","Innkeeper",135},
    [7731] = {'Innkeeper Jayka',1002,1002,30,30,0,{[406]={{47.47,62.13}}},nil,406,nil,nil,29,"H","Innkeeper",135},
    [7733] = {'Innkeeper Fizzgrimble',1002,1002,30,30,0,{[440]={{52.51,27.91}}},nil,440,nil,nil,474,"AH","Innkeeper",135},
    [7736] = {'Innkeeper Shyria',1002,1002,30,30,0,{[357]={{30.97,43.49}}},nil,357,{3788},nil,80,"A","Innkeeper",135},
    [7737] = {'Innkeeper Greul',1002,1002,30,30,0,{[357]={{74.8,45.18}}},nil,357,nil,nil,29,"H","Innkeeper",135},
    [7744] = {'Innkeeper Thulfram',1002,1002,30,30,0,{[47]={{14.15,41.57}}},{[47]={{{14.15,41.57},{13.66,41.73},{13.4,41.83},{13.15,41.91},{13.4,41.83},{13.66,41.73}}}},47,nil,nil,694,"A","Innkeeper",135},
    [7952] = {'Zjolnir',2217,2217,45,45,0,{[14]={{55.23,75.65}}},nil,14,{7664,7665},{7664,7665},126,"H","Raptor Handler",135},
    [7955] = {'Milli Featherwhistle',2768,2768,50,50,0,{[1]={{49.13,47.95}}},nil,1,{7675,7676},{7675,7676},875,"A","Mechanostrider Merchant",135},
    [8931] = {'Innkeeper Heather',1002,1002,30,30,0,{[40]={{52.86,53.71}}},nil,40,nil,nil,12,"A","Innkeeper",135},
    [9087] = {'Bashana Runetotem',1342,1342,35,35,0,{[1638]={{71.06,34.19}}},nil,1638,{3786,3804},{3782,3786,3804,6561},104,"H",nil,135},
    [9501] = {'Innkeeper Adegwa',1002,1002,30,30,0,{[45]={{73.84,32.46}}},nil,45,nil,nil,29,"H","Innkeeper",135},
    [11103] = {'Innkeeper Lyshaerya',1002,1002,30,30,0,{[405]={{66.27,6.55}}},nil,405,nil,nil,80,"A","Innkeeper",135},
    [11106] = {'Innkeeper Sikewa',1002,1002,30,30,0,{[405]={{24.09,68.21}}},nil,405,nil,nil,104,"H","Innkeeper",135},
    [11116] = {'Innkeeper Abeqwa',1002,1002,30,30,0,{[400]={{46.07,51.52}}},nil,400,nil,nil,104,"H","Innkeeper",135},
    [11118] = {'Innkeeper Vizzie',1002,1002,30,30,0,{[618]={{61.36,38.83}}},nil,618,nil,nil,855,"AH","Innkeeper",135},
    [12196] = {'Innkeeper Kaylisk',1002,1002,30,30,0,{[331]={{73.99,60.65}}},nil,331,nil,nil,29,"H","Innkeeper",135},
    [12777] = {'Captain Dirgehammer',5228,5228,55,55,0,nil,nil,0,nil,nil,35,"AH","Armor Quartermaster",4224},
    [14731] = {'Lard',2062,2062,48,48,0,{[47]={{78.14,81.38}}},nil,47,{7840},{7840},1494,"H","Innkeeper",135},
    [15174] = {'Calandrath',2533,2533,54,54,0,{[1377]={{51.89,39.16}}},nil,1377,{8307,8317},{8313,8317,8497,8804},994,"AH","Innkeeper",135},
    [16256] = {'Jessica Chambers',2489,2489,52,52,0,{[139]={{81.63,58.08}}},{[139]={{{81.63,58.08},{81.63,58.08},{81.52,58.09},{81.52,58.09}}}},139,nil,nil,794,"AH","Innkeeper",133},
    [16458] = {'Innkeeper Faralia',1002,1002,30,30,0,{[406]={{35.79,5.74}}},nil,406,nil,nil,80,"A","Innkeeper",135},
}
