import argparse
import json
import re


STRING_RE = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"|\'([^\'\\]*(?:\\.[^\'\\]*)*)\'')


def strip_lua_comments(src: str) -> str:
	n = len(src)
	i = 0
	out = []

	def is_nl(c: str) -> bool:
		return c == "\n" or c == "\r"

	while i < n:
		c = src[i]

		if c == '"' or c == "'":
			q = c
			out.append(c)
			i += 1
			while i < n:
				ch = src[i]
				out.append(ch)
				if ch == "\\" and i + 1 < n:
					i += 1
					out.append(src[i])
				elif ch == q:
					i += 1
					break
				i += 1
			continue

		if c == "[":
			j = i + 1
			eq = 0
			while j < n and src[j] == "=":
				eq += 1
				j += 1
			if j < n and src[j] == "[":
				out.append(src[i : j + 1])
				i = j + 1
				close = "]" + ("=" * eq) + "]"
				k = src.find(close, i)
				if k == -1:
					out.append(src[i:])
					break
				out.append(src[i:k])
				out.append(close)
				i = k + len(close)
				continue

		if c == "-" and i + 1 < n and src[i + 1] == "-":
			j = i + 2
			if j < n and src[j] == "[":
				k = j + 1
				eq = 0
				while k < n and src[k] == "=":
					eq += 1
					k += 1
				if k < n and src[k] == "[":
					i = k + 1
					close = "]" + ("=" * eq) + "]"
					end = src.find(close, i)
					if end == -1:
						break
					i = end + len(close)
					continue

			i += 2
			while i < n and not is_nl(src[i]):
				i += 1
			if i < n:
				out.append(src[i])
				i += 1
			continue

		out.append(c)
		i += 1

	return "".join(out)


def lua_strings(text: str):
	return [part[0] or part[1] for part in STRING_RE.findall(text or "")]


def command_args(usage: str, first_alias: str):
	if not usage:
		return ""

	prefix_pattern = re.compile(rf"^\s*{re.escape(first_alias)}\b", re.IGNORECASE)
	usage_no_cmd = prefix_pattern.sub("", usage, count=1).lstrip()
	arg_tokens = re.findall(r"(<[^>]+>|\[[^\]]+\])", usage_no_cmd)
	return " ".join(arg_tokens) if arg_tokens else ""


def make_command(alias_strings, usage: str, desc: str):
	if not alias_strings:
		return None

	name = alias_strings[0].lower()
	return {
		"name": name,
		"aliases": [a.lower() for a in alias_strings],
		"usage": usage,
		"args": command_args(usage, alias_strings[0]),
		"desc": desc,
	}


def parse_commands(filecontent: str, func_name: str):
	pattern = re.compile(
		rf"{re.escape(func_name)}\s*\(\s*\{{([\s\S]*?)\}}\s*,\s*\{{([\s\S]*?)\}}",
		re.MULTILINE,
	)
	commands = []
	for match in pattern.finditer(filecontent):
		alias_text = match.group(1)
		info_text = match.group(2)

		alias_strings = lua_strings(alias_text)
		info_strings = lua_strings(info_text)

		if not alias_strings:
			continue

		usage = info_strings[0] if len(info_strings) > 0 else ""
		desc = info_strings[1] if len(info_strings) > 1 else ""
		command = make_command(alias_strings, usage, desc)
		if command:
			commands.append(command)

	return commands


def skip_lua_string(src: str, i: int):
	q = src[i]
	i += 1
	while i < len(src):
		if src[i] == "\\" and i + 1 < len(src):
			i += 2
			continue
		if src[i] == q:
			return i + 1
		i += 1
	return i


def extract_table_body(src: str, assignment: str):
	match = re.search(rf"{re.escape(assignment)}\s*=\s*\{{", src)
	if not match:
		return ""

	start = match.end() - 1
	depth = 0
	i = start
	while i < len(src):
		c = src[i]
		if c == '"' or c == "'":
			i = skip_lua_string(src, i)
			continue
		if c == "{":
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0:
				return src[start + 1 : i]
		i += 1
	return ""


def split_top_level_tables(body: str):
	entries = []
	start = None
	depth = 0
	i = 0
	while i < len(body):
		c = body[i]
		if c == '"' or c == "'":
			i = skip_lua_string(body, i)
			continue
		if c == "{":
			if depth == 0:
				start = i
			depth += 1
		elif c == "}":
			depth -= 1
			if depth == 0 and start is not None:
				entries.append(body[start : i + 1])
				start = None
		i += 1
	return entries


def parse_string_field(entry: str, field: str):
	match = re.search(rf"\b{re.escape(field)}\s*=\s*({STRING_RE.pattern})", entry)
	if not match:
		return ""
	values = lua_strings(match.group(1))
	return values[0] if values else ""


def parse_string_list_field(entry: str, field: str):
	match = re.search(rf"\b{re.escape(field)}\s*=\s*\{{([\s\S]*?)\}}", entry)
	return lua_strings(match.group(1)) if match else []


def parse_engine_settings_commands(filecontent: str):
	commands = []

	bool_body = extract_table_body(filecontent, "NAmanage.EngineSettings.boolCommands")
	for entry in split_top_level_tables(bool_body):
		aliases = parse_string_list_field(entry, "aliases")
		label = parse_string_field(entry, "label") or (aliases[0] if aliases else "")
		usage = parse_string_field(entry, "usage") or ((aliases[0] + " [on/off]") if aliases else "")
		command = make_command(aliases, usage, "Set " + label)
		if command:
			commands.append(command)

		off_aliases = parse_string_list_field(entry, "offAliases")
		command = make_command(off_aliases, off_aliases[0] if off_aliases else "", "Disable " + label)
		if command:
			commands.append(command)

	number_body = extract_table_body(filecontent, "NAmanage.EngineSettings.numberCommands")
	for entry in split_top_level_tables(number_body):
		aliases = parse_string_list_field(entry, "aliases")
		label = parse_string_field(entry, "label") or (aliases[0] if aliases else "")
		usage = parse_string_field(entry, "usage") or ((aliases[0] + " <number>") if aliases else "")
		command = make_command(aliases, usage, "Set " + label)
		if command:
			commands.append(command)

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

	clean = strip_lua_comments(filecontent)

	commands = parse_commands(clean, "cmd.add")
	commands.extend(parse_engine_settings_commands(clean))
	patched_commands = parse_commands(clean, "cmd.addPatched")

	result = {
		"commands": commands,
		"patched_commands": patched_commands,
	}

	with open(args.output, "w", encoding="utf-8") as f:
		json.dump(result, f, indent=2)

	print(f"Extracted {len(commands)} commands and {len(patched_commands)} patched commands.")


if __name__ == "__main__":
	main()
