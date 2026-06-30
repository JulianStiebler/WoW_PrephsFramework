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

-- Generated table for flag: SPIRITGUIDE (64)
SPIRITGUIDE_Table = {
    [8923] = {'Panzor the Invincible',13920,13920,57,57,2,{[1585]={{-1,-1}}},nil,1585,nil,nil,54,nil,nil,32832},
    [13116] = {'Alliance Spirit Guide',24420,24420,60,60,1,{[3277]={{42.49,27.7}},[2597]={{41.0,15.66},{50.86,14.49},{53.75,35.82},{41.3,43.99},{51.6,57.23},{48.01,77.02},{49.9,91.38},{53.63,7.52}},[3358]={{39.13,26.33},{51.12,41.93},{60.66,57.68},{37.12,62.62},{61.0,25.7},{32.92,12.91}}},nil,2597,nil,nil,84,"A",nil,64},
    [13117] = {'Horde Spirit Guide',24420,24420,60,60,1,{[3277]={{57.09,78.21}},[2597]={{41.0,15.66},{50.86,14.49},{53.75,35.82},{41.3,43.99},{51.6,57.23},{48.01,77.02},{49.9,91.38},{56.65,67.4}},[3358]={{39.13,26.33},{51.12,41.93},{60.66,57.68},{37.12,62.62},{61.0,25.7},{69.02,67.79}}},nil,2597,nil,nil,83,"H",nil,64},
}
