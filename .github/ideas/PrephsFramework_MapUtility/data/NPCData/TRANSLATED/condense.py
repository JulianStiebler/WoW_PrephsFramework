import os
from lupa import LuaRuntime

# Configuration
INPUTS = [
    "AUCTIONEER_Updated", "BANKER_Updated", "BATTLEMASTER_Updated", "FLIGHTMASTER_Updated", 
    "INNKEEPER_Updated", "REPAIR_Updated", "SPIRITHEALER_Updated", "SPIRITGUIDE_Updated", 
    "STABLEMASTER_Updated", "TRAINER_Updated", "VENDOR_Updated"
]

LUA_SERIALIZER_SCRIPT = """
local function is_array(t)
    if type(t) ~= "table" then return false end
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    for i = 1, count do if t[i] == nil then return false end end
    return count > 0
end

local function serialize(obj)
    if type(obj) == "number" then return tostring(obj) end
    if type(obj) == "string" then return string.format("%q", obj) end
    if type(obj) == "boolean" then return tostring(obj) end
    if type(obj) == "nil" then return "nil" end
    if type(obj) == "table" then
        local parts = {}
        if is_array(obj) then
            for i = 1, #obj do table.insert(parts, serialize(obj[i])) end
            return "{" .. table.concat(parts, ",") .. "}"
        else
            for k, v in pairs(obj) do
                local key = type(k) == "number" and "["..k.."]" or "['"..k.."']"
                table.insert(parts, key .. "=" .. serialize(v))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end
    return "nil"
end
return serialize
"""

def condense_to_five_indices():
    lua = LuaRuntime(unpack_returned_tuples=True)
    serialize = lua.execute(LUA_SERIALIZER_SCRIPT)

    for name in INPUTS:
        filename = f"{name}.lua"
        output_filename = f"{name}_condensed.lua"
        
        if not os.path.exists(filename):
            continue

        print(f"Processing {filename}...")
        lua.execute("Table = nil") 
        
        with open(filename, 'r', encoding='utf-8') as f:
            try:
                lua.execute(f.read())
            except Exception as e:
                print(f"Error parsing: {e}")
                continue

        lua_table = lua.globals().Table
        if lua_table is None:
            continue

        condensed_lines = ["Table = {\n"]

        for npc_id, row in lua_table.items():
            try:
                # MAP RAW TO CONDENSED
                # 1:Name, 14:Subname, 7:Spawns, 8:Waypoints, 13:Faction
                s_name    = serialize(row[1])
                s_subname = serialize(row[14])
                s_spawns  = serialize(row[7])
                s_wps     = serialize(row[8])
                s_faction = serialize(row[13])

                # Result: [1]=Name, [2]=Sub, [3]=Spawns, [4]=WPs, [5]=Faction
                line = f"    [{npc_id}] = {{{s_name},{s_subname},{s_spawns},{s_wps},{s_faction}}},\n"
                condensed_lines.append(line)
            except Exception as e:
                print(f"  -> Error NPC {npc_id}: {e}")

        condensed_lines.append("}\n")

        with open(output_filename, 'w', encoding='utf-8') as f:
            f.writelines(condensed_lines)

if __name__ == "__main__":
    condense_to_five_indices()