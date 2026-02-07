import argparse
import json
import re
from collections import defaultdict


def parse_commands(filecontent: str, func_name: str):
    """Parse commands defined by the given function name (cmd.add or cmd.addPatched).

    Returns a list of dictionaries with fields: name, aliases, usage,
    args, desc.
    """
    pattern = re.compile(
        rf'{re.escape(func_name)}\s*\(\s*\{{([\s\S]*?)\}}\s*,\s*\{{([\s\S]*?)\}}',
        re.MULTILINE,
    )
    commands = []
    for match in pattern.finditer(filecontent):
        alias_text = match.group(1)
        info_text = match.group(2)
        alias_strings = []
        for part in re.findall(
            r'"([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\'',
            alias_text,
        ):
            alias_strings.append(part[0] or part[1])
        info_strings = []
        for part in re.findall(
            r'"([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\'',
            info_text,
        ):
            info_strings.append(part[0] or part[1])
        if not alias_strings:
            continue
        name = alias_strings[0].lower()
        usage = info_strings[0] if len(info_strings) > 0 else ''
        desc = info_strings[1] if len(info_strings) > 1 else ''
        args = ''
        parts = usage.split(' ', 1)
        if len(parts) > 1:
            args = parts[1]
        commands.append(
            {
                'name': name,
                'aliases': [a.lower() for a in alias_strings],
                'usage': usage,
                'args': args,
                'desc': desc,
            }
        )
    return commands


def assign_category(cmd_name: str, aliases, desc: str):
    """Assign a simple category based on keywords in the name, aliases or description."""
    movement_keywords = [
        'fly', 'vfly', 'speed', 'walk', 'jump', 'noclip', 'unclip', 'clip',
        'gravity', 'spinwalk', 'jumppower', 'nofall', 'ws'
    ]
    camera_keywords = [
        'view', 'camera', 'cam', 'spectate', 'spec', 'fixcam', 'freecam',
        'camlock', 'camunlock', 'firstperson', 'thirdperson', 'zoom', 'fov',
        'fpsmode', 'unview'
    ]
    teleport_keywords = [
        'tp', 'teleport', 'bring', 'goto', 'serverhop', 'hop', 'rejoin',
        'respawn', 'tptool', 'warp', 'void', 'to', 'come', 'spawn'
    ]
    visual_keywords = [
        'chams', 'xray', 'fullbright', 'esp', 'shader', 'outline', 'highlight',
        'glow', 'tracer', 'tracers', 'box', 'boxes', 'nametag', 'nameesp',
        'bright', 'night', 'fog', 'lighting', 'range', 'distance', 'visual',
        'shaders', 'hd', 'rtx'
    ]
    trolling_keywords = [
        'fling', 'loopfling', 'spin', 'sit', 'kill', 'dance', 'float',
        'bighead', 'small', 'size', 'resize', 'shrink', 'giant', 'clown',
        'orbit', 'hover', 'ragdoll', 'annoy', 'push', 'yeet', 'troll',
        'spinhead'
    ]
    search_terms = [cmd_name] + aliases
    lower_desc = desc.lower()
    for kw in movement_keywords:
        if any(kw in alias for alias in search_terms):
            return 'Movement & Physics'
    for kw in camera_keywords:
        if any(kw in alias for alias in search_terms):
            return 'Camera & View'
    for kw in teleport_keywords:
        if any(kw in alias for alias in search_terms):
            return 'Teleport & Tools'
    for kw in visual_keywords:
        if any(kw in alias for alias in search_terms):
            return 'Visuals / ESP / Environment'
    for kw in trolling_keywords:
        if any(kw in alias for alias in search_terms):
            return 'Trolling / Fun'
    if any(w in lower_desc for w in ['speed', 'fly', 'noclip', 'jump']):
        return 'Movement & Physics'
    if any(w in lower_desc for w in ['view', 'camera', 'spectate']):
        return 'Camera & View'
    if any(w in lower_desc for w in ['teleport', 'server', 'bring']):
        return 'Teleport & Tools'
    if any(w in lower_desc for w in ['visual', 'esp', 'shader', 'fullbright']):
        return 'Visuals / ESP / Environment'
    if any(w in lower_desc for w in ['fling', 'troll', 'spin']):
        return 'Trolling / Fun'
    return 'Server & Utility'


def main():
    parser = argparse.ArgumentParser(description='Extract commands from Nameless Admin Source.lua')
    parser.add_argument('--source', default='Source.lua', help='Path to Source.lua')
    parser.add_argument('--output', default='commands.json', help='Output JSON file')
    args = parser.parse_args()
    with open(args.source, 'r', encoding='utf-8') as f:
        filecontent = f.read()
    commands = parse_commands(filecontent, 'cmd.add')
    patched_commands = parse_commands(filecontent, 'cmd.addPatched')
    for cmd in commands:
        cmd['category'] = assign_category(cmd['name'], cmd['aliases'], cmd['desc'])
    for cmd in patched_commands:
        cmd['category'] = assign_category(cmd['name'], cmd['aliases'], cmd['desc'])
    result = {
        'commands': commands,
        'patched_commands': patched_commands
    }
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2)
    print(f'Extracted {len(commands)} commands and {len(patched_commands)} patched commands.')


if __name__ == '__main__':
    main()