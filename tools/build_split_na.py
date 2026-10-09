#!/usr/bin/env python3
"""Build the chunked Nameless Admin distribution.

The original files are one large lexical scope.  This builder keeps their
execution order, turns declarations at that scope's top level into shared
environment fields, and cuts only at complete top-level statements.  Each
chunk can therefore be compiled independently without losing the names that
the next chunk needs.
"""

from __future__ import annotations

import re
import shutil
import argparse
import hashlib
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "NA-split"
COMMON = OUT / "common"
IDENTIFIER_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


@dataclass(frozen=True)
class Token:
    value: str
    line: int
    column: int


def _long_bracket_end(text: str, start: int) -> int | None:
    match = re.match(r"\[(=*)\[", text[start:])
    if not match:
        return None
    close = "]" + match.group(1) + "]"
    end = text.find(close, start + len(match.group(0)))
    return len(text) if end < 0 else end + len(close)


def tokenize(lines: list[str]) -> list[Token]:
    """Tokenize enough Lua/Luau syntax to find lexical block boundaries."""

    tokens: list[Token] = []
    source = "\n".join(lines) + "\n"
    i = 0
    line = 1
    column = 1
    length = len(source)

    def advance(fragment: str) -> None:
        nonlocal line, column
        newlines = fragment.count("\n")
        if newlines:
            line += newlines
            column = len(fragment.rsplit("\n", 1)[1]) + 1
        else:
            column += len(fragment)

    while i < length:
        char = source[i]
        if char.isspace():
            advance(char)
            i += 1
            continue

        if source.startswith("--", i):
            long_end = _long_bracket_end(source, i + 2)
            if long_end is not None:
                fragment = source[i:long_end]
                advance(fragment)
                i = long_end
                continue
            end = source.find("\n", i)
            end = length if end < 0 else end
            fragment = source[i:end]
            advance(fragment)
            i = end
            continue

        if char in "'\"`":
            quote = char
            start_line, start_column = line, column
            j = i + 1
            escaped = False
            while j < length:
                current = source[j]
                if escaped:
                    escaped = False
                elif current == "\\":
                    escaped = True
                elif current == quote:
                    j += 1
                    break
                j += 1
            fragment = source[i:j]
            tokens.append(Token("<string>", start_line, start_column))
            advance(fragment)
            i = j
            continue

        long_end = _long_bracket_end(source, i) if char == "[" else None
        if long_end is not None:
            fragment = source[i:long_end]
            tokens.append(Token("<string>", line, column))
            advance(fragment)
            i = long_end
            continue

        identifier = IDENTIFIER_RE.match(source, i)
        if identifier:
            value = identifier.group(0)
            tokens.append(Token(value, line, column))
            advance(value)
            i += len(value)
            continue

        # Multi-character operators matter only for delimiter scanning, but
        # consuming them as one token keeps columns useful in diagnostics.
        operator = next(
            (candidate for candidate in ("...", "::", "+=", "-=", "*=", "/=", "..", "==", "~=", "<=", ">=", "->")
             if source.startswith(candidate, i)),
            None,
        )
        fragment = operator or char
        tokens.append(Token(fragment, line, column))
        advance(fragment)
        i += len(fragment)

    return tokens


def line_depths(lines: list[str]) -> tuple[dict[int, int], set[int]]:
    """Return block depth at each line and lines safe for a chunk boundary."""

    tokens = tokenize(lines)
    by_line: dict[int, list[str]] = {}
    for token in tokens:
        by_line.setdefault(token.line, []).append(token.value)

    depths: dict[int, int] = {}
    safe: set[int] = set()
    depth = 0
    paren = bracket = brace = 0
    pending_loop_do = 0
    last_token = None

    for line_number in range(1, len(lines) + 1):
        depths[line_number] = depth
        for value in by_line.get(line_number, []):
            if value in {"(", "[", "{"}:
                if value == "(":
                    paren += 1
                elif value == "[":
                    bracket += 1
                else:
                    brace += 1
            elif value in {")",
                "]",
                "}",
            }:
                if value == ")":
                    paren = max(0, paren - 1)
                elif value == "]":
                    bracket = max(0, bracket - 1)
                else:
                    brace = max(0, brace - 1)
            elif value == "function":
                depth += 1
            elif value in {"if", "for", "while"}:
                depth += 1
                if value in {"for", "while"}:
                    pending_loop_do += 1
            elif value == "do":
                if pending_loop_do:
                    pending_loop_do -= 1
                else:
                    depth += 1
            elif value == "repeat":
                depth += 1
            elif value == "end":
                depth = max(0, depth - 1)
            elif value == "until":
                depth = max(0, depth - 1)
            last_token = value

        if depth == 0 and paren == 0 and bracket == 0 and brace == 0:
            safe.add(line_number)

    if depth != 0:
        raise ValueError(f"unbalanced Lua blocks after line {len(lines)} (depth {depth})")
    return depths, safe


def transform_shared_declarations(lines: list[str], depths: dict[int, int]) -> list[str]:
    """Make root-scope declarations visible to independently loaded chunks."""

    result = list(lines)
    unsupported: list[tuple[int, str]] = []
    declaration = re.compile(r"^(?P<indent>\s*)(?P<keyword>local|const)\s+(?P<rest>.*)$")

    for index, original in enumerate(lines, start=1):
        if depths.get(index) != 0:
            continue
        match = declaration.match(original)
        if not match:
            continue

        rest = match.group("rest")
        indent = match.group("indent")
        if rest.startswith("function "):
            result[index - 1] = indent + rest
            continue

        # A declaration with an initializer can become an ordinary assignment.
        # The source uses simple identifier lists at this scope.
        if "=" in rest:
            result[index - 1] = indent + rest
            continue

        names = rest.rstrip().rstrip(";")
        if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*(?:\s*,\s*[A-Za-z_][A-Za-z0-9_]*)*", names):
            count = len([name for name in names.split(",") if name.strip()])
            result[index - 1] = indent + names + " = " + ", ".join(["nil"] * count)
        else:
            unsupported.append((index, original))

    if unsupported:
        details = "\n".join(f"  line {line}: {text}" for line, text in unsupported[:12])
        raise ValueError("unsupported root declaration(s):\n" + details)
    return result


def find_body(lines: list[str]) -> list[str]:
    start = next((i for i, line in enumerate(lines) if line.strip() == "}, function()"), None)
    if start is None:
        raise ValueError("could not find the NACaller body start")

    end = None
    for i in range(start + 1, len(lines)):
        if lines[i].strip() != "end))":
            continue
        next_code = next((line.strip() for line in lines[i + 1:] if line.strip()), "")
        if next_code.startswith("if not __NARootResult"):
            end = i
            break
    if end is None:
        raise ValueError("could not find the NACaller body end")
    return lines[start + 1:end]


def split_body(body: list[str], target_lines: int = 6000) -> list[list[str]]:
    for index, line in enumerate(body):
        if line.strip() != "const function naAlreadyLoaded()":
            continue
        end = next(
            (candidate for candidate in range(index + 1, len(body)) if body[candidate].strip() == "return false"),
            None,
        )
        if end is not None:
            body[end:end] = [
                '\tif _na_boot.hostEnv and (_na_boot.hostEnv.ltseverydayyou_NA or _na_boot.hostEnv.NA_LOADED) then',
                '\t\treturn true',
                '\tend',
            ]
        break
    depths, safe = line_depths(body)
    body = transform_shared_declarations(body, depths)
    # Recalculate line metadata is unnecessary: transformation preserves lines.
    chunks: list[list[str]] = []
    start = 0
    while start < len(body):
        desired = min(len(body), start + target_lines)
        candidates = [line for line in safe if start < line <= desired]
        if not candidates:
            candidates = [line for line in safe if line > desired]
        if not candidates:
            raise ValueError(f"no safe split point after body line {desired}")
        end = max(candidates) if max(candidates) <= desired else min(candidates)
        chunks.append(body[start:end])
        start = end
    return chunks


def _git_blob_sha(data: bytes) -> str:
    header = f"blob {len(data)}\0".encode("ascii")
    return hashlib.sha1(header + data).hexdigest()


def write_manifest(parts: list[tuple[str, bytes]], loader_version: str) -> None:
    digest = hashlib.sha256()
    fingerprints: dict[str, str] = {}
    for name, data in parts:
        digest.update(f"{name}\0".encode("utf-8"))
        digest.update(data)
        fingerprints[name] = _git_blob_sha(data)
    manifest = [
        "local meta = {",
        f'\tversion = "{digest.hexdigest()[:16]}";',
        f"\tcount = {len(parts)};",
        '\tdirectory = "common";',
        f'\tloader_version = "{loader_version}";',
        "\tparts = {",
    ]
    for name, fingerprint in fingerprints.items():
        manifest.append(f'\t\t["{name}"] = "{fingerprint}";')
    manifest.extend(["\t};", "}", "", "return meta", ""])
    (COMMON / "manifest.lua").write_bytes("\r\n".join(manifest).encode("utf-8"))


def loader_digest() -> str:
    digest = hashlib.sha256()
    for name in ("Source.lua", "NA testing.lua"):
        digest.update(name.encode("utf-8"))
        digest.update(b"\0")
        digest.update((ROOT / name).read_bytes())
    return "loader-" + digest.hexdigest()[:16]


def refresh_metadata() -> None:
    paths = sorted(COMMON.glob("part-*.lua"))
    if not paths or [path.name for path in paths] != [f"part-{i:03d}.lua" for i in range(1, len(paths) + 1)]:
        raise ValueError("split chunks must be nonempty and numbered consecutively")
    write_manifest([(path.name, path.read_bytes()) for path in paths], loader_digest())


def write_chunks(chunks: list[list[str]], loader_version: str) -> None:
    if COMMON.exists():
        shutil.rmtree(COMMON)
    COMMON.mkdir(parents=True)
    parts: list[tuple[str, bytes]] = []
    for index, chunk in enumerate(chunks, start=1):
        name = f"part-{index:03d}.lua"
        data = ("\r\n".join(chunk).rstrip() + "\r\n").encode("utf-8")
        (COMMON / name).write_bytes(data)
        parts.append((name, data))
    write_manifest(parts, loader_version)

BOOT_LOADER = r'''local __NA_SPLIT_SOURCE_TAG = "{source_tag}"
local __NA_SPLIT_CONFIG = {{
	testing = {testing};
	sourceTag = __NA_SPLIT_SOURCE_TAG;
}}

{prefix}

local __NA_SPLIT_LOAD_TOKEN = {{}}
local __NA_GLOBAL_ENV = __NARootHost
local __NA_GLOBAL_STATE_KEY = "__NamelessAdminRuntimeState"
local __NA_GLOBAL_PREVIOUS_STATE = type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) or nil
if type(__NA_GLOBAL_PREVIOUS_STATE) == "table" and (__NA_GLOBAL_PREVIOUS_STATE.loading == true or __NA_GLOBAL_PREVIOUS_STATE.loaded == true) then
	return
end
local __NA_GLOBAL_STATE = {{ loading = true; source = __NA_SPLIT_SOURCE_TAG; token = __NA_SPLIT_LOAD_TOKEN; }}
if type(__NA_GLOBAL_ENV) == "table" then
	rawset(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY, __NA_GLOBAL_STATE)
	if rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) ~= __NA_GLOBAL_STATE then
		return
	end
end
local __NA_SPLIT_HOST_LOADING = type(__NARootHost) == "table" and rawget(__NARootHost, "__NA_SPLIT_LOADING") or nil
local __NA_SPLIT_HOST_LOADED = type(__NARootHost) == "table" and (rawget(__NARootHost, "ltseverydayyou_NA") or rawget(__NARootHost, "NA_LOADED"))
if __NA_SPLIT_HOST_LOADING or __NA_SPLIT_HOST_LOADED then
	if type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) == __NA_GLOBAL_STATE then
		rawset(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY, nil)
	end
	return
end
if type(__NARootHost) == "table" then
	rawset(__NARootHost, "__NA_SPLIT_LOADING", __NA_SPLIT_LOAD_TOKEN)
	if rawget(__NARootHost, "__NA_SPLIT_LOADING") ~= __NA_SPLIT_LOAD_TOKEN then
		return
	end
end
local function __NA_SPLIT_CLEAR_LOADING()
	if type(__NARootHost) == "table" and rawget(__NARootHost, "__NA_SPLIT_LOADING") == __NA_SPLIT_LOAD_TOKEN then
		rawset(__NARootHost, "__NA_SPLIT_LOADING", nil)
	end
end

local __NA_SPLIT_FS_LOCK_OWNED = false
local __NA_SPLIT_FS_LOCK_PATH = nil
local function __NA_SPLIT_CLAIM_FS_LOCK()
	if type(isfile) ~= "function" or type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return true
	end
	local placeId = "unknown"
	local jobId = "unknown"
	pcall(function()
		placeId = tostring(game.PlaceId or "unknown")
		jobId = tostring(game.JobId or "unknown")
	end)
	if jobId == "" or jobId == "unknown" then
		return true
	end
	local key = (placeId.."_"..jobId):gsub("[^%w_%-]", "_")
	local stateRoot = "Nameless-Admin/.na-split-runtime"
	__NA_SPLIT_FS_LOCK_PATH = stateRoot.."/lock-"..key
	pcall(makefolder, "Nameless-Admin")
	pcall(makefolder, stateRoot)
	if isfolder(__NA_SPLIT_FS_LOCK_PATH) then
		return false
	end
	local created = pcall(makefolder, __NA_SPLIT_FS_LOCK_PATH)
	__NA_SPLIT_FS_LOCK_OWNED = created
	local ok, exists = pcall(isfolder, __NA_SPLIT_FS_LOCK_PATH)
	if not created or not ok or not exists then
		return false
	end
	return true
end
local __NA_SPLIT_LOCK_OK, __NA_SPLIT_LOCKED = pcall(__NA_SPLIT_CLAIM_FS_LOCK)
if not __NA_SPLIT_LOCK_OK or not __NA_SPLIT_LOCKED then
	if __NA_SPLIT_FS_LOCK_OWNED and type(delfolder) == "function" then
		pcall(delfolder, __NA_SPLIT_FS_LOCK_PATH)
		__NA_SPLIT_FS_LOCK_OWNED = false
	end
	__NA_SPLIT_CLEAR_LOADING()
	if type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) == __NA_GLOBAL_STATE then
		rawset(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY, nil)
	end
	return
end
if type(__NARootHost) == "table" then
	pcall(rawset, __NARootHost, "NACaller", __NARootNACaller)
end

local function __NA_SPLIT_RELEASE(success)
	if __NA_SPLIT_FS_LOCK_OWNED then
		if type(delfolder) == "function" and __NA_SPLIT_FS_LOCK_PATH then
			pcall(delfolder, __NA_SPLIT_FS_LOCK_PATH)
		end
		__NA_SPLIT_FS_LOCK_OWNED = false
	end
	if type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) == __NA_GLOBAL_STATE then
		if success then
			__NA_GLOBAL_STATE.loading = false
			__NA_GLOBAL_STATE.loaded = true
			__NA_GLOBAL_STATE.token = nil
		else
			rawset(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY, nil)
			if type(__NARootHost) == "table" then
				rawset(__NARootHost, "NA_LOADED", nil)
				rawset(__NARootHost, "ltseverydayyou_NA", nil)
			end
		end
	end
	__NA_SPLIT_CLEAR_LOADING()
end

local __NA_SPLIT_REMOTE_ROOT = rawget(__NARootHost, "__NA_SPLIT_BASE_URL")
if type(__NA_SPLIT_REMOTE_ROOT) ~= "string" or __NA_SPLIT_REMOTE_ROOT == "" then
	__NA_SPLIT_REMOTE_ROOT = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA-split/common/"
end
if __NA_SPLIT_REMOTE_ROOT:sub(-1) ~= "/" then
	__NA_SPLIT_REMOTE_ROOT ..= "/"
end

local __NA_SPLIT_LOCAL_ROOTS = {{
	"NA-split/common/";
	"Nameless-Admin/NA-split/common/";
	"Nameless Admin/NA-split/common/";
}}
local __NA_SPLIT_REMOTE_QUERY = ""

local function __NA_SPLIT_READ_LOCAL(root, name)
	if type(readfile) ~= "function" then
		return nil
	end
	local ok, data = pcall(readfile, root..name)
	return ok and type(data) == "string" and data ~= "" and data or nil
end

local function __NA_SPLIT_READ_REMOTE(name)
	local url = __NA_SPLIT_REMOTE_ROOT..name..__NA_SPLIT_REMOTE_QUERY
	local requestFn = rawget(__NARootHost, "request")
		or rawget(__NARootHost, "http_request")
		or (type(syn) == "table" and syn.request)
	if type(requestFn) == "function" then
		local ok, response = pcall(requestFn, {{ Method = "GET"; Url = url; }})
		local status = type(response) == "table" and tonumber(response.StatusCode or response.statusCode or response.Status) or nil
		local body = type(response) == "table" and (response.Body or response.body) or nil
		if ok and type(body) == "string" and body ~= "" and (not status or status < 400) then
			return body
		end
	end
	if type(game) ~= "userdata" and type(game) ~= "table" then
		return nil
	end
	local ok, data = pcall(function()
		return game:HttpGet(url)
	end)
	return ok and type(data) == "string" and data ~= "" and data or nil
end

local function __NA_SPLIT_LOAD_MANIFEST(source, name)
	if type(source) ~= "string" then
		return nil
	end
	local loader = rawget(__NARootHost, "loadstring") or loadstring or load
	if type(loader) ~= "function" then
		return nil
	end
	local okCompile, chunk = pcall(loader, source, "@"..name)
	if not okCompile or type(chunk) ~= "function" then
		return nil
	end
	local okRun, manifest = pcall(chunk)
	local count = type(manifest) == "table" and tonumber(manifest.count)
	if okRun and count and count >= 1 and count <= 256 and count % 1 == 0 then
		manifest.count = count
		return manifest
	end
	return nil
end

local function __NA_SPLIT_YIELD()
	if type(task) == "table" and type(task.wait) == "function" then
		task.wait()
	end
end

local function __NA_SPLIT_PART_FINGERPRINT(meta, partName)
	local parts = type(meta) == "table" and meta.parts or nil
	local value = type(parts) == "table" and parts[partName] or nil
	if type(value) == "string" and #value == 40 and value:match("^%x+$") then
		return value
	end
	return nil
end

local function __NA_SPLIT_LOCAL_PART(root, meta, name)
	local fingerprint = __NA_SPLIT_PART_FINGERPRINT(meta, name)
	if fingerprint then
		local path = root..".parts/"..fingerprint..".lua"
		local exists = true
		if type(isfile) == "function" then
			local ok, value = pcall(isfile, path)
			exists = ok and value
		end
		if exists then
			local source = __NA_SPLIT_READ_LOCAL(root..".parts/", fingerprint..".lua")
			if source then return source end
		end
	end
	return __NA_SPLIT_READ_LOCAL(root, name)
end

local __NA_SPLIT_LOCAL_ROOT = nil
local __NA_SPLIT_LOCAL_META = nil
local __NA_SPLIT_FALLBACK_ROOT = nil
local __NA_SPLIT_FALLBACK_META = nil
for _, root in __NA_SPLIT_LOCAL_ROOTS do
	local manifest = __NA_SPLIT_LOAD_MANIFEST(__NA_SPLIT_READ_LOCAL(root, "manifest.lua"), root.."manifest.lua")
	if manifest then
		local complete = true
		if type(isfile) == "function" then
			for index = 1, manifest.count do
				local name = string.format("part-%03d.lua", index)
				local fingerprint = __NA_SPLIT_PART_FINGERPRINT(manifest, name)
				local ok, exists = false, false
				if fingerprint then ok, exists = pcall(isfile, root..".parts/"..fingerprint..".lua") end
				if not (ok and exists) then ok, exists = pcall(isfile, root..name) end
				if not (ok and exists) then complete = false; break end
			end
		end
		if complete then
			__NA_SPLIT_LOCAL_ROOT = root
			__NA_SPLIT_LOCAL_META = manifest
			break
		elseif not __NA_SPLIT_FALLBACK_ROOT then
			__NA_SPLIT_FALLBACK_ROOT = root
			__NA_SPLIT_FALLBACK_META = manifest
		end
	end
end
if not __NA_SPLIT_LOCAL_ROOT then
	__NA_SPLIT_LOCAL_ROOT = __NA_SPLIT_FALLBACK_ROOT
	__NA_SPLIT_LOCAL_META = __NA_SPLIT_FALLBACK_META
end

local __NA_SPLIT_REMOTE_MANIFEST_SOURCE = __NA_SPLIT_READ_REMOTE("manifest.lua?na_manifest="..tostring(os.time()))
local __NA_SPLIT_REMOTE_META = __NA_SPLIT_LOAD_MANIFEST(__NA_SPLIT_REMOTE_MANIFEST_SOURCE, "NA-split/common/manifest.lua")
if __NA_SPLIT_REMOTE_META and type(__NA_SPLIT_REMOTE_META.version) == "string" and __NA_SPLIT_REMOTE_META.version ~= "" then
	__NA_SPLIT_REMOTE_QUERY = "?na_build="..__NA_SPLIT_REMOTE_META.version
end
local __NA_SPLIT_REMOTE_CHANGED = __NA_SPLIT_REMOTE_META ~= nil
	and (__NA_SPLIT_LOCAL_META == nil or __NA_SPLIT_REMOTE_META.version ~= __NA_SPLIT_LOCAL_META.version)
local __NA_SPLIT_COUNT = math.max(0, math.floor(tonumber(
	(__NA_SPLIT_REMOTE_META and __NA_SPLIT_REMOTE_META.count)
		or (__NA_SPLIT_LOCAL_META and __NA_SPLIT_LOCAL_META.count)
		or {chunk_count}
) or 0))
local __NA_SPLIT_CACHE_ROOT = __NA_SPLIT_LOCAL_ROOT or __NA_SPLIT_LOCAL_ROOTS[1]
local __NA_SPLIT_PENDING_CACHE = {{}}
local __NA_SPLIT_CACHE_OK = type(writefile) == "function"
local __NA_SPLIT_CACHE_READY = false
local __NA_SPLIT_CACHE_MANIFEST = __NA_SPLIT_REMOTE_META ~= nil and (
	__NA_SPLIT_LOCAL_META == nil
	or __NA_SPLIT_REMOTE_CHANGED
	or type(__NA_SPLIT_LOCAL_META.parts) ~= "table"
	or __NA_SPLIT_LOCAL_META.loader_version ~= __NA_SPLIT_REMOTE_META.loader_version
)

local function __NA_SPLIT_READ_PART(partName)
	if not __NA_SPLIT_REMOTE_META then
		local source = __NA_SPLIT_LOCAL_ROOT and __NA_SPLIT_LOCAL_PART(__NA_SPLIT_LOCAL_ROOT, __NA_SPLIT_LOCAL_META, partName)
		if source then return source end
		error("Nameless Admin chunk unavailable: "..partName, 0)
	end

	local remoteFingerprint = __NA_SPLIT_PART_FINGERPRINT(__NA_SPLIT_REMOTE_META, partName)
	local localFingerprint = __NA_SPLIT_PART_FINGERPRINT(__NA_SPLIT_LOCAL_META, partName)
	if __NA_SPLIT_LOCAL_ROOT and ((remoteFingerprint and remoteFingerprint == localFingerprint)
		or (not __NA_SPLIT_REMOTE_CHANGED and not localFingerprint)) then
		local source = __NA_SPLIT_LOCAL_PART(__NA_SPLIT_LOCAL_ROOT, __NA_SPLIT_LOCAL_META, partName)
		if source then return source end
	end

	local source = __NA_SPLIT_READ_REMOTE(partName)
	if source then
		__NA_SPLIT_PENDING_CACHE[partName] = source
		return source
	end
	error("Nameless Admin chunk unavailable: "..partName, 0)
end

local function __NA_SPLIT_CACHE_PART(partName)
	local source = __NA_SPLIT_PENDING_CACHE[partName]
	__NA_SPLIT_PENDING_CACHE[partName] = nil
	if not source then return end
	__NA_SPLIT_CACHE_MANIFEST = true
	local fingerprint = __NA_SPLIT_PART_FINGERPRINT(__NA_SPLIT_REMOTE_META, partName)
	if not __NA_SPLIT_CACHE_OK or not fingerprint then
		__NA_SPLIT_CACHE_OK = false
		return
	end
	if not __NA_SPLIT_CACHE_READY then
		if type(makefolder) == "function" then
			local current = ""
			for segment in (__NA_SPLIT_CACHE_ROOT..".parts"):gmatch("[^/]+") do
				current = current == "" and segment or current.."/"..segment
				pcall(makefolder, current)
			end
		end
		__NA_SPLIT_CACHE_READY = true
	end
	if not pcall(writefile, __NA_SPLIT_CACHE_ROOT..".parts/"..fingerprint..".lua", source) then
		__NA_SPLIT_CACHE_OK = false
	end
end

local function __NA_SPLIT_CACHE_REMOTE()
	if not __NA_SPLIT_CACHE_OK or not __NA_SPLIT_CACHE_MANIFEST or not __NA_SPLIT_REMOTE_MANIFEST_SOURCE then return end
	if not pcall(writefile, __NA_SPLIT_CACHE_ROOT.."manifest.lua", __NA_SPLIT_REMOTE_MANIFEST_SOURCE) then return end
	if type(listfiles) ~= "function" or type(delfile) ~= "function" then return end
	local ok, files = pcall(listfiles, __NA_SPLIT_CACHE_ROOT..".parts")
	if not ok or type(files) ~= "table" then return end
	local keep = {{}}
	for _, value in __NA_SPLIT_REMOTE_META.parts or {{}} do keep[value] = true end
	for _, path in files do
		local name = tostring(path):gsub("\\", "/"):match("/([%x]+)%.lua$")
		if name and #name == 40 and not keep[name] then pcall(delfile, path) end
		__NA_SPLIT_YIELD()
	end
end

local function __NA_SPLIT_LOAD_PART(source, chunkName, environment)
	local loader = rawget(__NARootHost, "loadstring") or loadstring or load
	if type(loader) ~= "function" then
		error("Nameless Admin requires loadstring/load", 0)
	end
	local okCompile, chunk, compileError = pcall(loader, source, "@"..chunkName)
	if not okCompile or type(chunk) ~= "function" then
		error(tostring(compileError or chunk or "chunk compilation failed"), 0)
	end
	local setter = rawget(__NARootHost, "setfenv") or setfenv
	if type(setter) ~= "function" then
		error("Nameless Admin requires setfenv for split chunks", 0)
	end
	local okEnv, envError = pcall(setter, chunk, environment)
	if not okEnv then
		error(tostring(envError), 0)
	end
	return chunk
end

local function __NA_SPLIT_FORMAT_ERROR(value)
	local text = tostring(value)
	if type(debug) == "table" and type(debug.traceback) == "function" then
		local ok, trace = pcall(debug.traceback, text, 2)
		if ok and type(trace) == "string" and trace ~= "" then
			return trace
		end
	end
	return text
end

local function __NA_SPLIT_CACHE_LOADER(meta)
	if type(meta) ~= "table" or type(meta.loader_version) ~= "string" then return end
	if type(writefile) ~= "function" then
		return
	end

	local host = (type(getgenv) == "function" and getgenv()) or _G or {{}}
	local state = type(host) == "table" and rawget(host, "__NamelessAdminRuntimeState") or nil
	local sourceTag = type(state) == "table" and state.source or nil
	if sourceTag ~= "Source.lua" and sourceTag ~= "NA testing.lua" then
		return
	end

	local roots = {{
		"NA-split/";
		"Nameless-Admin/NA-split/";
		"Nameless Admin/NA-split/";
	}}
	local root = roots[1]
	if type(isfile) == "function" then
		for _, candidate in roots do
			local ok, exists = pcall(isfile, candidate.."common/manifest.lua")
			if ok and exists then
				root = candidate
				break
			end
		end
	end

	local cachePath = root..sourceTag
	local versionPath = root.."."..sourceTag:gsub("[^%w]+", "_")..".version"
	if type(readfile) == "function" then
		local okVersion, cachedVersion = pcall(readfile, versionPath)
		local okLoader, exists = false, false
		if type(isfile) == "function" then okLoader, exists = pcall(isfile, cachePath) end
		if okVersion and cachedVersion == meta.loader_version and okLoader and exists then
			return
		end
	end

	local remoteName = sourceTag:gsub(" ", "%%20")
	local loaderRoot = __NA_SPLIT_REMOTE_ROOT:gsub("NA%-split/common/$", "")
	if loaderRoot == __NA_SPLIT_REMOTE_ROOT then return end
	local url = loaderRoot..remoteName.."?na_loader="..meta.loader_version
	local requestFn = type(host) == "table" and (rawget(host, "request") or rawget(host, "http_request")) or nil
	local synTable = type(host) == "table" and rawget(host, "syn") or nil
	if type(requestFn) ~= "function" and type(synTable) == "table" then
		requestFn = synTable.request
	end

	local source
	if type(requestFn) == "function" then
		local ok, response = pcall(requestFn, {{ Method = "GET"; Url = url; }})
		local status = type(response) == "table" and tonumber(response.StatusCode or response.statusCode or response.Status) or nil
		local body = type(response) == "table" and (response.Body or response.body) or nil
		if ok and type(body) == "string" and body ~= "" and (not status or status < 400) then
			source = body
		end
	end

	if not source and (type(game) == "userdata" or type(game) == "table") then
		local ok, body = pcall(function()
			return game:HttpGet(url)
		end)
		if ok and type(body) == "string" and body ~= "" then
			source = body
		end
	end
	if not source then
		return
	end

	local loader = type(host) == "table" and rawget(host, "loadstring") or nil
	loader = loader or loadstring or load
	if type(loader) ~= "function" then
		return
	end
	local okCompile, chunk = pcall(loader, source, "@"..sourceTag)
	if not okCompile or type(chunk) ~= "function" then
		return
	end

	if type(makefolder) == "function" then
		local parent = root:gsub("/$", "")
		local current = ""
		for segment in parent:gmatch("[^/]+") do
			current = current == "" and segment or current.."/"..segment
			pcall(makefolder, current)
		end
	end
	if pcall(writefile, cachePath, source) then
		pcall(writefile, versionPath, meta.loader_version)
	end
end


local function __NA_SPLIT_MODULE_PATH(key)
	if type(key) ~= "string" or not key:match("^[%w_-]+$") then return nil end
	return __NA_SPLIT_CACHE_ROOT..".modules/"..key..".cache"
end

local function __NA_SPLIT_MODULE_SOURCE(data, url)
	if type(data) ~= "string" or type(url) ~= "string" or url == "" or url:find("[\r\n]") then return nil end
	local prefix = url.."\n"
	if data:sub(1, #prefix) ~= prefix then return nil end
	local source = data:sub(#prefix + 1)
	if source == "" then return nil end
	local loader = rawget(__NARootHost, "loadstring") or loadstring or load
	if type(loader) ~= "function" then return nil end
	local ok, chunk = pcall(loader, source, "@"..url)
	return ok and type(chunk) == "function" and source or nil
end

local function __NA_SPLIT_READ_MODULE(key, url)
	local path = __NA_SPLIT_MODULE_PATH(key)
	if not path or type(readfile) ~= "function" then return nil end
	for _, name in {{ path, path..".backup" }} do
		local ok, data = pcall(readfile, name)
		local source = ok and __NA_SPLIT_MODULE_SOURCE(data, url)
		if source then return source end
	end
	return nil
end

local function __NA_SPLIT_SAVE_MODULE(key, url, source)
	local path = __NA_SPLIT_MODULE_PATH(key)
	if not path or type(readfile) ~= "function" or type(writefile) ~= "function" or type(source) ~= "string" then return false end
	if type(url) ~= "string" or url == "" or url:find("[\r\n]") then return false end
	local data = url.."\n"..source
	if not __NA_SPLIT_MODULE_SOURCE(data, url) then return false end
	local okOld, old = pcall(readfile, path)
	if okOld and old == data then return true end
	if type(makefolder) == "function" then
		local current = ""
		for segment in (__NA_SPLIT_CACHE_ROOT..".modules"):gmatch("[^/]+") do
			current = current == "" and segment or current.."/"..segment
			pcall(makefolder, current)
		end
	end
	if okOld and __NA_SPLIT_MODULE_SOURCE(old, url) then
		if not pcall(writefile, path..".backup", old) then return false end
		local okBackup, backup = pcall(readfile, path..".backup")
		if not okBackup or backup ~= old then return false end
	end
	if not pcall(writefile, path, data) then return false end
	local okRead, written = pcall(readfile, path)
	return okRead and written == data
end

local __NA_SPLIT_ENV
local function __NA_SPLIT_RUN()
	__NA_SPLIT_CONFIG.state = __NA_GLOBAL_STATE
	__NA_SPLIT_CONFIG.cacheRoot = __NA_SPLIT_CACHE_ROOT
	__NA_SPLIT_CONFIG.offline = __NA_SPLIT_REMOTE_META == nil
	__NA_SPLIT_CONFIG.moduleRead = __NA_SPLIT_READ_MODULE
	__NA_SPLIT_CONFIG.moduleWrite = __NA_SPLIT_SAVE_MODULE
	local environment = setmetatable({{
		__NA_SPLIT_CONFIG = __NA_SPLIT_CONFIG;
		NACaller = __NARootNACaller;
		__NARootHost = __NARootHost;
		__NARootPreviousNACaller = __NARootPreviousNACaller;
		__NARootErrorState = __NARootErrorState;
		__NARootExecutorInfo = __NARootExecutorInfo;
		__NARootDebugInfo = __NARootDebugInfo;
		__NARootNextErrorPath = __NARootNextErrorPath;
		__NARootReportError = __NARootReportError;
		__NARootNACaller = __NARootNACaller;
	}}, {{
		__index = function(target, key)
			local boot = rawget(target, "_na_boot")
			local runtime = type(boot) == "table" and boot.runtimeEnv
			if type(runtime) == "table" then
				local value = rawget(runtime, key)
				if value ~= nil then
					return value
				end
			end
			return __NARootHost[key]
		end;
		__newindex = function(target, key, value)
			local boot = rawget(target, "_na_boot")
			local runtime = type(boot) == "table" and boot.runtimeEnv
			if type(runtime) == "table" and key ~= "_na_boot" and key ~= "_na_env" and key ~= "_na_shared" then
				rawset(runtime, key, value)
			else
				rawset(target, key, value)
			end
		end;
	}})
	__NA_SPLIT_ENV = environment
	for index = 1, __NA_SPLIT_COUNT do
		if rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) ~= __NA_GLOBAL_STATE then
			error("Nameless Admin loading was cancelled", 0)
		end
		local partName = string.format("part-%03d.lua", index)
		local source = __NA_SPLIT_READ_PART(partName)
		local chunk = __NA_SPLIT_LOAD_PART(source, "NA-split/common/"..partName, environment)
		local okRun, runError = xpcall(chunk, __NA_SPLIT_FORMAT_ERROR)
		chunk = nil
		source = nil
		if not okRun then
			error(__NA_SPLIT_FORMAT_ERROR(runError), 0)
		end
		if index == 1 then
			local boot = rawget(environment, "_na_boot")
			if type(boot) ~= "table" or type(boot.runtimeEnv) ~= "table" then
				error("Nameless Admin split bootstrap did not initialize", 0)
			end
			local migrated = {{}}
			for key, value in environment do
				if key ~= "__NA_SPLIT_CONFIG" and key ~= "NACaller" and key ~= "_na_boot" and key ~= "_na_env" and key ~= "_na_shared" then
					migrated[key] = value
				end
			end
			for key, value in migrated do
				rawset(boot.runtimeEnv, key, value)
				rawset(environment, key, nil)
			end
			environment = boot.runtimeEnv
			__NA_SPLIT_ENV = environment
		end
		__NA_SPLIT_CACHE_PART(partName)
		__NA_SPLIT_YIELD()
	end
	if rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) ~= __NA_GLOBAL_STATE then
		error("Nameless Admin loading was cancelled", 0)
	end
	__NA_SPLIT_CACHE_REMOTE()
	pcall(__NA_SPLIT_CACHE_LOADER, __NA_SPLIT_REMOTE_META or __NA_SPLIT_LOCAL_META)
end

local function __NA_SPLIT_ABORT()
	local environment = __NA_SPLIT_ENV
	if type(environment) ~= "table" then return end
	local boot = rawget(environment, "_na_boot")
	local runtime = type(boot) == "table" and boot.runtimeEnv or environment
	local manage = rawget(runtime, "NAmanage")
	local unload = type(manage) == "table" and rawget(manage, "Unload")
	if type(unload) == "function" then
		local ok, done = pcall(unload, {{ silent = true }})
		if ok and done ~= false then return end
	end
	if type(manage) == "table" and type(manage._runtimeState) == "table" then
		manage._runtimeState.unloading = true
		manage._runtimeState.runToken = nil
	end
	local seen = {{}}
	local current = coroutine.running()
	local function clean(value)
		if type(value) ~= "table" or seen[value] then return end
		if type(boot) == "table" and (value == boot or value == boot.hostEnv
			or value == boot.privateRegistry or value == boot.privateRoot or value == runtime) then return end
		seen[value] = true
		if rawget(value, "Connected") ~= nil and type(rawget(value, "Disconnect")) == "function" then
			pcall(rawget(value, "Disconnect"), value)
		end
		for key, child in next, value do
			if typeof(child) == "RBXScriptConnection" then
				pcall(function() child:Disconnect() end)
			elseif type(child) == "thread" and child ~= current and coroutine.status(child) ~= "dead" and type(task) == "table" then
				pcall(task.cancel, child)
			elseif type(child) == "table" then
				clean(child)
			end
			if type(key) == "thread" and key ~= current and coroutine.status(key) ~= "dead" and type(task) == "table" then pcall(task.cancel, key) end
		end
	end
	for _, name in {{ "NAmanage", "NAStuff", "NAjobs", "NAgui", "NAUIMANAGER", "NAindex", "NAAssetsLoading" }} do clean(rawget(runtime, name)) end
	local stuff = rawget(runtime, "NAStuff")
	if type(stuff) == "table" and typeof(stuff.NASCREENGUI) == "Instance" then
		pcall(function() stuff.NASCREENGUI:Destroy() end)
	end
	local assets = rawget(runtime, "NAAssetsLoading")
	if type(assets) == "table" and typeof(assets.ui) == "Instance" then
		pcall(function() assets.ui:Destroy() end)
	end
	if type(boot) == "table" and type(boot.privateRoot) == "table" then
		local root = boot.privateRoot
		local owned = rawget(runtime, "_na_env")
		local ownsRoot = type(owned) == "table" and root.testing == owned
		local protector = rawget(runtime, "__NAUIProtector")
		if type(protector) ~= "table" and ownsRoot then protector = root.uiProtector end
		if type(protector) == "table" and (ownsRoot or root.uiProtector ~= protector) then
			if type(protector.destroy) == "function" then pcall(protector.destroy) end
			if root.uiProtector == protector then root.uiProtector = nil end
		end
		if ownsRoot then
			root.testing = nil
			root.naRuns = nil
		end
	end
end

local __NARootResult = table.pack(__NARootNACaller({{
	context = "Nameless Admin Main Runtime";
	severity = "fatal";
	warn = true;
	log = true;
}}, __NA_SPLIT_RUN))

if not __NARootResult[1] then pcall(__NA_SPLIT_ABORT) end

if not __NARootResult[1] and type(__NARootHost) == "table" then
	pcall(function()
		if __NARootPreviousNACaller ~= nil then
			rawset(__NARootHost, "NACaller", __NARootPreviousNACaller)
		else
			rawset(__NARootHost, "NACaller", nil)
		end
	end)
end

if __NARootResult[1] then
	__NA_SPLIT_RELEASE(true)
	return table.unpack(__NARootResult, 2, __NARootResult.n)
end

__NA_SPLIT_RELEASE(false)
'''


def write_boots(source_lines: list[str], chunk_count: int) -> str:
    marker = next(i for i, line in enumerate(source_lines) if line.strip() == "local __NARootResult = table.pack(NACaller({")
    prefix = "\n".join(source_lines[:marker]).replace(
        '"NA Source: NA testing.lua"',
        '"NA Source: "..__NA_SPLIT_SOURCE_TAG',
    )
    host_line = 'local __NARootHost = (getgenv and getgenv()) or _G or {}'
    unwrap = (
        'local __naPrev = type(__NARootHost) == "table" and rawget(__NARootHost, "_na_boot") or nil\n'
        'if type(__naPrev) == "table" and rawget(__naPrev, "runtimeEnv") == __NARootHost and type(rawget(__naPrev, "hostEnv")) == "table" then\n'
        '\t__NARootHost = __naPrev.hostEnv\n'
        'end'
    )
    if host_line in prefix and 'local __naPrev = ' not in prefix:
        prefix = prefix.replace(host_line, host_line + '\n' + unwrap, 1)
    prefix = prefix.replace('if type(__NARootHost) == "table" then\n\tpcall(rawset, __NARootHost, "NACaller", __NARootNACaller)\nend', "").rstrip()
    for name, testing in (("Source.lua", "false"), ("NA testing.lua", "true")):
        boot = BOOT_LOADER.format(
            source_tag=name,
            testing=testing,
            prefix=prefix if name == "Source.lua" else prefix,
            chunk_count=chunk_count,
        )
        data = boot.replace("\n", "\r\n").encode("utf-8")
        (ROOT / name).write_bytes(data)
    return loader_digest()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        default="Source.lua",
        help="monolithic source file to split (default: Source.lua)",
    )
    parser.add_argument("--refresh-metadata", action="store_true", help="refresh fingerprints after editing split chunks")
    args = parser.parse_args()
    if args.refresh_metadata:
        refresh_metadata()
        print(f"refreshed metadata for {len(list(COMMON.glob('part-*.lua')))} chunks")
        return
    input_path = Path(args.input)
    if not input_path.is_absolute():
        input_path = ROOT / input_path
    source = input_path.read_text(encoding="utf-8").splitlines()
    body = find_body(source)
    chunks = split_body(body)
    # Keep the two binaries identical apart from the two intentional build
    # values.  The launcher supplies these through _na_boot.splitConfig.
    rebuilt: list[list[str]] = []
    for chunk in chunks:
        piece = "\n".join(chunk)
        if not rebuilt:
            piece = piece.replace("_na_boot = {", "_na_boot = { splitConfig = __NA_SPLIT_CONFIG;", 1)
            piece = piece.replace(
                '_na_boot.runtimeEnv = _na_boot.ensureTable(_na_env, "runtime")',
                '_na_boot.runtimeEnv = _na_boot.ensureTable(_na_env, "runtime")\n'
                '_na_boot.runtimeEnv._na_boot = _na_boot\n'
                '_na_boot.runtimeEnv._na_env = _na_env\n'
                '_na_boot.runtimeEnv._na_shared = _na_shared',
                1,
            )
        piece = piece.replace("NATestingVer = false", "NATestingVer = _na_boot.splitConfig.testing")
        piece = piece.replace('__NAKeySource = "Source.lua"', "__NAKeySource = _na_boot.splitConfig.sourceTag")
        piece = piece.replace(
            '\t\tor text:find("timeout", 1, true) ~= nil',
            '\t\tor text:find("timeout", 1, true) ~= nil\n'
            '\t\tor text:find("connectfail", 1, true) ~= nil\n'
            '\t\tor text:find("connect fail", 1, true) ~= nil\n'
            '\t\tor text:find("connection failed", 1, true) ~= nil\n'
            '\t\tor text:find("connection reset", 1, true) ~= nil\n'
            '\t\tor text:find("network is unreachable", 1, true) ~= nil\n'
            '\t\tor text:find("temporary failure", 1, true) ~= nil',
            1,
        )
        rebuilt.append(piece.splitlines())
    loader_version = write_boots(source, len(rebuilt))
    write_chunks(rebuilt, loader_version)
    print(f"wrote {len(rebuilt)} chunks to {COMMON}")
    print(f"source body: {len(body):,} lines; largest chunk: {max(map(len, rebuilt)):,} lines")


if __name__ == "__main__":
    main()
