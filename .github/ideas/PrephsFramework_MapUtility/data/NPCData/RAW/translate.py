import re
import os

# Configuration
INPUTS = [
    "AUCTIONEER", "BANKER", "BATTLEMASTER", "FLIGHTMASTER", "INNKEEPER",
    "REPAIR", "SPIRITHEALER", "SPIRITGUIDE", "STABLEMASTER",
    "TRAINER", "VENDOR"
]
MAPPING_FILE = 'uiMapIdToAreaId.lua'

def parse_mapping(filename):
    """Parses the uiMapIDToAreaID table into a reverse lookup dictionary."""
    area_to_ui = {}
    mapping_pattern = re.compile(r'\[(\d+)\]\s*=\s*(\d+),\s*--\s*(.*)')
    
    if not os.path.exists(filename):
        print(f"Error: Mapping file {filename} not found.")
        return None

    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            match = mapping_pattern.search(line)
            if match:
                ui_id, area_id, name = match.groups()
                if int(area_id) not in area_to_ui:
                    area_to_ui[int(area_id)] = (ui_id, name.strip())
    return area_to_ui

def process_file(file_prefix, area_map):
    """Processes a single .lua file based on its prefix."""
    input_file = f"{file_prefix}.lua"
    output_file = f"{file_prefix}_Updated.lua"
    
    if not os.path.exists(input_file):
        print(f"Skipping: {input_file} (File not found)")
        return

    updated_lines = []
    npc_line_pattern = re.compile(r'^(\s*\[\d+\]\s*=\s*\{)(.*)(\},.*)$')

    with open(input_file, 'r', encoding='utf-8') as f:
        for line in f:
            match = npc_line_pattern.match(line)
            if not match:
                updated_lines.append(line)
                continue

            prefix, content, suffix = match.groups()
            
            # Split outer table elements
            parts = []
            bracket_level = 0
            current_part = ""
            for char in content:
                if char == '{': bracket_level += 1
                elif char == '}': bracket_level -= 1
                
                if char == ',' and bracket_level == 0:
                    parts.append(current_part.strip())
                    current_part = ""
                else:
                    current_part += char
            parts.append(current_part.strip())

            zone_name_found = ""
            try:
                # Index 9 (zoneID) is parts[8]
                old_zone_id = int(parts[8])
                if old_zone_id in area_map:
                    ui_id, zone_name = area_map[old_zone_id]
                    parts[8] = ui_id
                    zone_name_found = zone_name
                    
                    # Update spawns (parts[6]) and waypoints (parts[7])
                    parts[6] = parts[6].replace(f'[{old_zone_id}]', f'[{ui_id}]')
                    parts[7] = parts[7].replace(f'[{old_zone_id}]', f'[{ui_id}]')
            except (ValueError, IndexError):
                pass

            new_content = ",".join(parts)
            comment = f" -- {zone_name_found}" if zone_name_found else ""
            clean_suffix = suffix.split('--')[0].rstrip()
            updated_lines.append(f"{prefix}{new_content}{clean_suffix}{comment}\n")

    with open(output_file, 'w', encoding='utf-8') as f:
        f.writelines(updated_lines)
    print(f"Successfully processed: {input_file} -> {output_file}")

def translate_all_npcs():
    area_map = parse_mapping(MAPPING_FILE)
    if area_map is None:
        return

    for npc_type in INPUTS:
        process_file(npc_type, area_map)

if __name__ == "__main__":
    translate_all_npcs()