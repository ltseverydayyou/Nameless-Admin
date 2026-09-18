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


def write_chunks(chunks: list[list[str]]) -> None:
    previous_manifest = (COMMON / "manifest.lua").read_text(encoding="utf-8") if (COMMON / "manifest.lua").exists() else ""
    loader_version_match = re.search(r'loader_version\s*=\s*"([^"]+)"', previous_manifest)
    loader_version = loader_version_match.group(1) if loader_version_match else None
    cache_loader_start = previous_manifest.find("local function cacheLoader()")
    cache_loader_suffix = previous_manifest[cache_loader_start:] if cache_loader_start >= 0 else ""

    if COMMON.exists():
        shutil.rmtree(COMMON)
    COMMON.mkdir(parents=True)
    digest = hashlib.sha256()
    fingerprints: dict[str, str] = {}
    for index, chunk in enumerate(chunks, start=1):
        part_name = f"part-{index:03d}.lua"
        path = COMMON / part_name
        data = ("\n".join(chunk).rstrip() + "\n").encode("utf-8")
        path.write_bytes(data)
        digest.update(f"{part_name}\0".encode("utf-8"))
        digest.update(data)
        fingerprints[part_name] = _git_blob_sha(data)
    version = digest.hexdigest()[:16]

    manifest = [
        "local meta = {",
        f'\tversion = "{version}";',
        f"\tcount = {len(chunks)};",
        '\tdirectory = "common";',
    ]
    if loader_version:
        manifest.append(f'\tloader_version = "{loader_version}";')
    manifest.append("\tparts = {")
    for part_name, fingerprint in fingerprints.items():
        manifest.append(f'\t\t["{part_name}"] = "{fingerprint}";')
    manifest.extend(["\t};", "}", ""])
    if cache_loader_suffix:
        manifest.append(cache_loader_suffix.rstrip())
    else:
        manifest.append("return meta")
    manifest.append("")
    (COMMON / "manifest.lua").write_text("\n".join(manifest), encoding="utf-8", newline="\n")

BOOT_LOADER = r'''local __NA_SPLIT_SOURCE_TAG = "{source_tag}"
local __NA_SPLIT_CONFIG = {{
	testing = {testing};
	sourceTag = __NA_SPLIT_SOURCE_TAG;
}}

{prefix}

local __NA_SPLIT_LOAD_TOKEN = {{}}
local __NA_GLOBAL_ENV = (type(getgenv) == "function" and getgenv()) or _G or {{}}
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
local __NA_SPLIT_HOST_LOADED = type(__NARootHost) == "table" and (rawget(__NARootHost, "ltseverydayyou_NA") ~= nil or rawget(__NARootHost, "NA_LOADED") ~= nil)
if __NA_SPLIT_HOST_LOADING ~= nil or __NA_SPLIT_HOST_LOADED then
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
local __NA_SPLIT_FS_LOCK_VALUE = nil
local function __NA_SPLIT_REFRESH_FS_LOCK()
	if not __NA_SPLIT_FS_LOCK_OWNED then
		return
	end
	local path = __NA_SPLIT_FS_LOCK_PATH.."/lease"
	local okRead, current = pcall(readfile, path)
	if not okRead or current ~= __NA_SPLIT_FS_LOCK_VALUE then
		return
	end
	local value = tostring(os.time()).."\n"..tostring(__NA_SPLIT_LOAD_TOKEN)
	local okWrite = pcall(writefile, path, value)
	if okWrite then
		__NA_SPLIT_FS_LOCK_VALUE = value
	end
end
local function __NA_SPLIT_CLAIM_FS_LOCK()
	if type(readfile) ~= "function" or type(writefile) ~= "function" or type(makefolder) ~= "function" then
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
	local path = __NA_SPLIT_FS_LOCK_PATH.."/lease"
	local okRead, current = pcall(readfile, path)
	local timestamp = okRead and type(current) == "string" and tonumber(current:match("^(%d+)\n")) or nil
	local age = timestamp and (os.time() - timestamp) or nil
	if age and age >= 0 and age < 120 then
		return false
	end
	pcall(makefolder, "Nameless-Admin")
	pcall(makefolder, stateRoot)
	pcall(makefolder, __NA_SPLIT_FS_LOCK_PATH)
	local value = tostring(os.time()).."\n"..tostring(__NA_SPLIT_LOAD_TOKEN)
	local written = pcall(writefile, path, value)
	if not written then
		return true
	end
	local verified, stored = pcall(readfile, path)
	if not verified or stored ~= value then
		return false
	end
	__NA_SPLIT_FS_LOCK_VALUE = value
	__NA_SPLIT_FS_LOCK_OWNED = true
	return true
end
if not __NA_SPLIT_CLAIM_FS_LOCK() then
	__NA_SPLIT_CLEAR_LOADING()
	if type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) == __NA_GLOBAL_STATE then
		rawset(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY, nil)
	end
	return
end
local function __NA_SPLIT_RELEASE(success)
	if __NA_SPLIT_FS_LOCK_OWNED then
		local path = __NA_SPLIT_FS_LOCK_PATH.."/lease"
		local okRead, current = pcall(readfile, path)
		if okRead and current == __NA_SPLIT_FS_LOCK_VALUE then
			pcall(writefile, path, "")
			if type(delfile) == "function" then
				pcall(delfile, path)
			end
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
	if okRun and type(manifest) == "table" and tonumber(manifest.count) then
		return manifest
	end
	return nil
end

local __NA_SPLIT_LOCAL_ROOT = nil
local __NA_SPLIT_LOCAL_META = nil
for _, root in __NA_SPLIT_LOCAL_ROOTS do
	local manifest = __NA_SPLIT_LOAD_MANIFEST(__NA_SPLIT_READ_LOCAL(root, "manifest.lua"), root.."manifest.lua")
	if manifest then
		local complete = true
		for index = 1, math.max(0, math.floor(tonumber(manifest.count) or 0)) do
			if not __NA_SPLIT_READ_LOCAL(root, string.format("part-%03d.lua", index)) then
				complete = false
				break
			end
		end
		if complete then
			__NA_SPLIT_LOCAL_ROOT = root
			__NA_SPLIT_LOCAL_META = manifest
			break
		end
	end
end

local __NA_SPLIT_REMOTE_MANIFEST_SOURCE = __NA_SPLIT_READ_REMOTE("manifest.lua")
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
local __NA_SPLIT_CACHE_MANIFEST = __NA_SPLIT_REMOTE_META ~= nil and (
	__NA_SPLIT_LOCAL_META == nil
	or __NA_SPLIT_REMOTE_CHANGED
	or type(__NA_SPLIT_LOCAL_META.parts) ~= "table"
	or __NA_SPLIT_LOCAL_META.loader_version ~= __NA_SPLIT_REMOTE_META.loader_version
)

local function __NA_SPLIT_PART_FINGERPRINT(meta, partName)
	local parts = type(meta) == "table" and meta.parts or nil
	local fingerprint = type(parts) == "table" and parts[partName] or nil
	return type(fingerprint) == "string" and fingerprint ~= "" and fingerprint or nil
end

local function __NA_SPLIT_READ_PART(partName)
	local localSource = __NA_SPLIT_LOCAL_ROOT and __NA_SPLIT_READ_LOCAL(__NA_SPLIT_LOCAL_ROOT, partName) or nil
	if not __NA_SPLIT_REMOTE_META then
		if localSource then
			return localSource
		end
		error("Nameless Admin chunk unavailable: "..partName, 0)
	end

	if localSource then
		local remoteFingerprint = __NA_SPLIT_PART_FINGERPRINT(__NA_SPLIT_REMOTE_META, partName)
		local localFingerprint = __NA_SPLIT_PART_FINGERPRINT(__NA_SPLIT_LOCAL_META, partName)
		if remoteFingerprint and localFingerprint and remoteFingerprint == localFingerprint then
			return localSource
		end
		if not __NA_SPLIT_REMOTE_CHANGED and not localFingerprint then
			return localSource
		end
	end

	local remote = __NA_SPLIT_READ_REMOTE(partName)
	if remote then
		__NA_SPLIT_PENDING_CACHE[partName] = remote
		return remote
	end
	error("Nameless Admin chunk unavailable: "..partName, 0)
end

local function __NA_SPLIT_CACHE_REMOTE()
	if not __NA_SPLIT_CACHE_MANIFEST or not __NA_SPLIT_REMOTE_MANIFEST_SOURCE or type(writefile) ~= "function" then
		return
	end
	if type(makefolder) == "function" then
		local parent = __NA_SPLIT_CACHE_ROOT:gsub("/$", "")
		local current = ""
		for segment in parent:gmatch("[^/]+") do
			current = current == "" and segment or current.."/"..segment
			pcall(makefolder, current)
		end
	end
	for partName, source in __NA_SPLIT_PENDING_CACHE do
		pcall(writefile, __NA_SPLIT_CACHE_ROOT..partName, source)
	end
	pcall(writefile, __NA_SPLIT_CACHE_ROOT.."manifest.lua", __NA_SPLIT_REMOTE_MANIFEST_SOURCE)
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

local function __NA_SPLIT_RUN()
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
	for index = 1, __NA_SPLIT_COUNT do
		__NA_SPLIT_REFRESH_FS_LOCK()
		local partName = string.format("part-%03d.lua", index)
		local source = __NA_SPLIT_READ_PART(partName)
		local chunk = __NA_SPLIT_LOAD_PART(source, "NA-split/common/"..partName, environment)
		local okRun, runError = xpcall(chunk, __NA_SPLIT_FORMAT_ERROR)
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
		end
	end
	__NA_SPLIT_CACHE_REMOTE()
end

local __NARootResult = table.pack(NACaller({{
	context = "Nameless Admin Main Runtime";
	severity = "fatal";
	warn = true;
	log = true;
}}, __NA_SPLIT_RUN))

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


def write_boots(source_lines: list[str], chunk_count: int) -> None:
    marker = next(i for i, line in enumerate(source_lines) if line.strip() == "local __NARootResult = table.pack(NACaller({")
    prefix = "\n".join(source_lines[:marker]).replace(
        '"NA Source: NA testing.lua"',
        '"NA Source: "..__NA_SPLIT_SOURCE_TAG',
    )
    for name, testing in (("Source.lua", "false"), ("NA testing.lua", "true")):
        boot = BOOT_LOADER.format(
            source_tag=name,
            testing=testing,
            prefix=prefix if name == "Source.lua" else prefix,
            chunk_count=chunk_count,
        )
        (ROOT / name).write_text(boot, encoding="utf-8", newline="\n")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        default="Source.lua",
        help="monolithic source file to split (default: Source.lua)",
    )
    args = parser.parse_args()
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
        rebuilt.append(piece.splitlines())
    write_chunks(rebuilt)
    write_boots(source, len(rebuilt))
    print(f"wrote {len(rebuilt)} chunks to {COMMON}")
    print(f"source body: {len(body):,} lines; largest chunk: {max(map(len, rebuilt)):,} lines")


if __name__ == "__main__":
    main()
