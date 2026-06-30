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

-- Generated table for flag: BANKER (256)
BANKER_Table = {
    [2455] = {'Olivia Burnside',5544,5544,45,45,0,{[1519]={{57.66,72.78}}},nil,1519,nil,nil,12,"A","Banker",257},
    [2456] = {'Newton Burnside',5544,5544,45,45,0,{[1519]={{57.12,73.23}}},nil,1519,nil,nil,12,"A","Banker",257},
    [2457] = {'John Burnside',5544,5544,45,45,0,{[1519]={{56.57,73.68}}},nil,1519,nil,nil,12,"A","Banker",257},
    [2458] = {'Randolph Montague',5544,5544,45,45,0,{[1497]={{65.93,43.43}}},nil,1497,nil,nil,68,"H","Banker",256},
    [2459] = {'Mortimer Montague',5544,5544,45,45,0,{[1497]={{66.41,44.06}}},nil,1497,nil,nil,68,"H","Banker",256},
    [2460] = {'Barnum Stonemantle',5544,5544,45,45,0,{[1537]={{34.97,58.41}}},nil,1537,nil,nil,55,"A","Banker",256},
    [2461] = {'Bailey Stonemantle',5544,5544,45,45,0,{[1537]={{35.92,60.14}}},nil,1537,nil,nil,55,"A","Banker",256},
    [2625] = {'Viznik Goldgrubber',7842,7842,55,55,0,{[33]={{26.54,76.57}}},nil,33,nil,nil,120,"AH","Banker",256},
    [2996] = {'Torn',5544,5544,45,45,0,{[1638]={{47.63,58.58}}},nil,1638,nil,nil,104,"H","Banker",256},
    [3309] = {'Karus',5544,5544,45,45,0,{[1637]={{49.58,69.12}}},nil,1637,nil,{4511},29,"H","Banker",259},
    [3318] = {'Koma',5544,5544,45,45,0,{[1637]={{50.0,68.58}}},nil,1637,nil,nil,29,"H","Banker",257},
    [3320] = {'Soran',5544,5544,45,45,0,{[1637]={{49.08,69.59}}},nil,1637,nil,nil,29,"H","Banker",257},
    [3496] = {'Fuzruckle',5544,5544,45,45,0,{[17]={{62.64,37.42}}},nil,17,nil,nil,69,"AH","Banker",256},
    [4155] = {'Idriana',5544,5544,45,45,0,{[1657]={{39.39,42.44}}},nil,1657,nil,{4510},80,"A","Banker",259},
    [4208] = {'Lairn',5544,5544,45,45,0,{[1657]={{39.68,41.54}}},nil,1657,nil,nil,80,"A","Banker",256},
    [4209] = {'Garryeth',5544,5544,45,45,0,{[1657]={{39.6,41.98}}},nil,1657,nil,nil,80,"A","Banker",256},
    [4549] = {'William Montague',5544,5544,45,45,0,{[1497]={{65.97,44.75}}},nil,1497,nil,nil,68,"H","Banker",256},
    [4550] = {'Ophelia Montague',5544,5544,45,45,0,{[1497]={{65.56,44.07}}},nil,1497,nil,nil,68,"H","Banker",256},
    [5099] = {'Soleil Stonemantle',5544,5544,45,45,0,{[1537]={{36.82,61.86}}},nil,1537,nil,nil,55,"A","Banker",256},
    [7799] = {'Gimblethorn',5544,5544,45,45,0,{[440]={{52.3,28.91}}},nil,440,nil,nil,474,"AH","Banker",256},
    [8119] = {'Zikkel',5544,5544,45,45,0,{[17]={{62.68,37.4}}},nil,17,nil,nil,69,"AH","Banker",256},
    [8123] = {'Rickle Goldgrubber',7842,7842,55,55,0,{[33]={{26.51,76.47}}},nil,33,nil,nil,120,"AH","Banker",256},
    [8124] = {'Qizzik',5544,5544,45,45,0,{[440]={{52.38,28.95}}},nil,440,nil,nil,474,"AH","Banker",258},
    [8356] = {'Chesmu',5544,5544,45,45,0,{[1638]={{47.13,57.89}}},nil,1638,nil,nil,104,"H","Banker",256},
    [8357] = {'Atepa',5544,5544,45,45,0,{[1638]={{47.2,59.32}}},nil,1638,nil,nil,104,"H","Banker",256},
    [13917] = {'Izzy Coppergrab',7842,7842,55,55,0,{[618]={{61.45,36.98}}},nil,618,nil,nil,855,"AH","Banker",256},
}
