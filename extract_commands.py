import argparse
import json
import re


def parse_commands(filecontent: str, func_name: str):
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
        usage = info_strings[0] if len(info_strings) > 0 else ""
        desc = info_strings[1] if len(info_strings) > 1 else ""

        args = ""
        if usage:
            first_alias = alias_strings[0]

            prefix_pattern = re.compile(
                rf"^\s*{re.escape(first_alias)}\b", re.IGNORECASE
            )
            usage_no_cmd = prefix_pattern.sub("", usage, count=1).lstrip()

            arg_tokens = re.findall(r"(<[^>]+>|\[[^\]]+\])", usage_no_cmd)
            if arg_tokens:
                args = " ".join(arg_tokens)

        commands.append(
            {
                "name": name,
                "aliases": [a.lower() for a in alias_strings],
                "usage": usage,
                "args": args,
                "desc": desc,
            }
        )

    return commands


def main():
    parser = argparse.ArgumentParser(
        description="Extract commands from Nameless Admin Source.lua"
    )
    parser.add_argument("--source", default="Source.lua", help="Path to Source.lua")
    parser.add_argument("--output", default="commands.json", help="Output JSON file")

    args = parser.parse_args()

    with open(args.source, "r", encoding="utf-8") as f:
        filecontent = f.read()

    commands = parse_commands(filecontent, "cmd.add")
    patched_commands = parse_commands(filecontent, "cmd.addPatched")

    result = {
        "commands": commands,
        "patched_commands": patched_commands,
    }

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)

    print(
        f"Extracted {len(commands)} commands and {len(patched_commands)} patched commands."
    )


if __name__ == "__main__":
    main()
