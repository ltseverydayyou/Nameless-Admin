import argparse
import json
import re


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


def parse_commands(filecontent: str, func_name: str):
	pattern = re.compile(
		rf"{re.escape(func_name)}\s*\(\s*\{{([\s\S]*?)\}}\s*,\s*\{{([\s\S]*?)\}}",
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
			prefix_pattern = re.compile(rf"^\s*{re.escape(first_alias)}\b", re.IGNORECASE)
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

	clean = strip_lua_comments(filecontent)

	commands = parse_commands(clean, "cmd.add")
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
