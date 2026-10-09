local __NA_SPLIT_SOURCE_TAG = "NA testing.lua"
local __NA_SPLIT_CONFIG = {
	testing = true;
	sourceTag = __NA_SPLIT_SOURCE_TAG;
}

--!nonstrict
-- © 2026 Nameless Admin. All rights reserved. Do not copy, paste, redistribute, or claim as your own.

local __NARootHost = (getgenv and getgenv()) or _G or {}
local __naPrev = type(__NARootHost) == "table" and rawget(__NARootHost, "_na_boot") or nil
if type(__naPrev) == "table" and rawget(__naPrev, "runtimeEnv") == __NARootHost and type(rawget(__naPrev, "hostEnv")) == "table" then
	__NARootHost = __naPrev.hostEnv
end
local __NARootPreviousNACaller = type(__NARootHost) == "table" and rawget(__NARootHost, "NACaller") or nil
local __NARootErrorState = type(__NARootHost) == "table" and rawget(__NARootHost, "__NAErrorLogState") or nil
if type(__NARootErrorState) ~= "table" then
	__NARootErrorState = { lastIndex = 0; rootCount = 0 }
	if type(__NARootHost) == "table" then
		pcall(rawset, __NARootHost, "__NAErrorLogState", __NARootErrorState)
	end
end

local function __NARootExecutorInfo()
	local name = "Unknown"
	local versionValue = "Unknown"
	if type(identifyexecutor) == "function" then
		local ok, a, b = pcall(identifyexecutor)
		if ok then
			if a ~= nil and tostring(a) ~= "" then name = tostring(a) end
			if b ~= nil and tostring(b) ~= "" then versionValue = tostring(b) end
		end
	end
	if name == "Unknown" and type(getexecutorname) == "function" then
		local ok, value = pcall(getexecutorname)
		if ok and value ~= nil and tostring(value) ~= "" then name = tostring(value) end
	end
	if versionValue == "Unknown" and type(getexecutorversion) == "function" then
		local ok, value = pcall(getexecutorversion)
		if ok and value ~= nil and tostring(value) ~= "" then versionValue = tostring(value) end
	end
	return name, versionValue
end

local function __NARootDebugInfo(fn)
	local source = "Unknown"
	local line = 0
	local name = "anonymous"
	if type(debug) == "table" and type(debug.info) == "function" and type(fn) == "function" then
		pcall(function()
			local s, l, n = debug.info(fn, "sln")
			if s ~= nil and tostring(s) ~= "" then source = tostring(s) end
			if tonumber(l) then line = tonumber(l) end
			if n ~= nil and tostring(n) ~= "" then name = tostring(n) end
		end)
	end
	return source, line, name
end

local function __NARootNextErrorPath()
	local root = "Nameless-Admin"
	local dir = root.."/ErrorLogs"
	local maxIndex = tonumber(__NARootErrorState.lastIndex) or 0
	if type(makefolder) == "function" then
		pcall(function()
			if type(isfolder) ~= "function" or not isfolder(root) then makefolder(root) end
		end)
		pcall(function()
			if type(isfolder) ~= "function" or not isfolder(dir) then makefolder(dir) end
		end)
	end
	if type(listfiles) == "function" then
		local ok, entries = pcall(listfiles, dir)
		if ok and type(entries) == "table" then
			for _, entry in entries do
				local normalized = tostring(entry):gsub("\\", "/")
				local index = tonumber(normalized:match("NA_Error#(%d+)%.txt$"))
				if index and index > maxIndex then maxIndex = index end
			end
		end
	end
	local nextIndex = maxIndex + 1
	local path = dir.."/NA_Error#"..tostring(nextIndex)..".txt"
	if type(isfile) == "function" then
		while isfile(path) do
			nextIndex += 1
			path = dir.."/NA_Error#"..tostring(nextIndex)..".txt"
		end
	end
	__NARootErrorState.lastIndex = nextIndex
	return path, nextIndex
end

local function __NARootReportError(rawError, tracebackText, context, fn, options)
	options = type(options) == "table" and options or {}
	__NARootErrorState.rootCount = (tonumber(__NARootErrorState.rootCount) or 0) + 1
	local logPath, fileIndex = __NARootNextErrorPath()
	local execName, execVersion = __NARootExecutorInfo()
	local fnSource, fnLine, fnName = __NARootDebugInfo(fn)
	local clientVersion = "Unknown"
	if type(version) == "function" then
		local ok, value = pcall(version)
		if ok and value ~= nil and tostring(value) ~= "" then clientVersion = tostring(value) end
	end
	local timestamp = tostring(os.time and os.time() or "Unknown")
	if type(os.date) == "function" then
		local ok, value = pcall(os.date, "!%Y-%m-%dT%H:%M:%SZ")
		if ok and value then timestamp = tostring(value) end
	end
	local placeName = "Unknown"
	local placeId = "Unknown"
	local gameId = "Unknown"
	local jobId = "Unknown"
	pcall(function()
		placeName = tostring(game.Name or "Unknown")
		placeId = tostring(game.PlaceId or "Unknown")
		gameId = tostring(game.GameId or "Unknown")
		jobId = tostring(game.JobId or "Unknown")
	end)
	local platform = "Unknown"
	pcall(function()
		local uis = game:GetService("UserInputService")
		if uis and type(uis.GetPlatform) == "function" then
			platform = tostring(uis:GetPlatform())
		end
	end)
	local errorId = "NAE-ROOT-"..string.format("%06d", tonumber(fileIndex) or tonumber(__NARootErrorState.rootCount) or 1)
	local lines = {
		"[Nameless Admin Root Error Report]";
		"Error ID: "..errorId;
		"Error File: NA_Error#"..tostring(fileIndex or "Unknown")..".txt";
		"Time (UTC): "..timestamp;
		"Context: "..tostring(context or options.context or "Nameless Admin Main Runtime");
		"Severity: "..string.upper(tostring(options.severity or "fatal"));
		"";
		"Runtime";
		"Executor: "..execName;
		"Executor Version: "..execVersion;
		"Roblox Client: "..clientVersion;
		"Platform: "..platform;
		"NA Source: "..__NA_SPLIT_SOURCE_TAG;
		"Coverage: Root NACaller";
		"";
		"Session";
		"Place: "..placeName;
		"PlaceId: "..placeId;
		"GameId: "..gameId;
		"JobId: "..jobId;
		"";
		"Callback";
		"Function: "..fnName;
		"Defined At: "..fnSource..":"..tostring(fnLine);
		"";
		"Error";
		tostring(rawError or "Unknown error");
		"";
		"Traceback";
		tostring(tracebackText or rawError or "Unavailable");
	}
	if type(options.details) == "table" then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Additional Context"
		for key, value in options.details do
			lines[#lines + 1] = tostring(key)..": "..tostring(value)
		end
	end
	local report = table.concat(lines, "\n")
	local writer = type(writefile) == "function" and writefile or (type(appendfile) == "function" and appendfile or nil)
	local saved = false
	if options.log ~= false and type(writer) == "function" then
		pcall(function()
			writer(logPath, report.."\n")
			saved = true
		end)
	end
	if options.warn ~= false and type(warn) == "function" then
		pcall(warn, report..(saved and ("\nSaved: "..logPath) or ""))
	end
	return report, saved and logPath or nil, errorId
end

local function __NARootNACaller(fnOrOptions, ...)
	local options = {}
	local fn
	local args
	if type(fnOrOptions) == "table" and type(select(1, ...)) == "function" then
		for key, value in fnOrOptions do options[key] = value end
		fn = select(1, ...)
		args = table.pack(select(2, ...))
	else
		fn = fnOrOptions
		args = table.pack(...)
	end
	if type(fn) ~= "function" then
		local message = "NACaller expected a function, got "..type(fn)
		__NARootReportError(message, message, options.context or "NACaller bootstrap", nil, options)
		return false, message
	end
	local rawError
	local results = table.pack(xpcall(function()
		return fn(table.unpack(args, 1, args.n))
	end, function(message)
		rawError = tostring(message or "Unknown error")
		if type(debug) == "table" and type(debug.traceback) == "function" then
			local ok, trace = pcall(debug.traceback, rawError, 2)
			if ok and type(trace) == "string" and trace ~= "" then return trace end
		end
		return rawError
	end))
	if not results[1] then
		local trace = tostring(results[2] or rawError or "Unknown error")
		__NARootReportError(rawError or trace, trace, options.context or "Nameless Admin Main Runtime", fn, options)
		if options.rethrow == true then error(trace, 0) end
	end
	return table.unpack(results, 1, results.n)
end

local __NA_SPLIT_LOAD_TOKEN = {}
local __NA_GLOBAL_ENV = __NARootHost
local __NA_GLOBAL_STATE_KEY = "__NamelessAdminRuntimeState"
local __NA_SPLIT_SESSION = tostring(game.PlaceId).."_"..tostring(game.JobId)
local __NA_GLOBAL_PREVIOUS_STATE = type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) or nil
local function __NA_SPLIT_ACTIVE(state)
	if type(state) ~= "table" then return false end
	if state.loaded == true and state.session == nil then return true end
	if state.session ~= __NA_SPLIT_SESSION then return false end
	if state.loaded == true then
		return true
	end
	if state.loading == true then
		if type(state.thread) == "thread" then
			local ok, status = pcall(coroutine.status, state.thread)
			if ok and status == "dead" then return false end
		end
		local updated = tonumber(state.updated or state.started)
		return not updated or os.clock() - updated < 180
	end
	return false
end

if __NA_SPLIT_ACTIVE(__NA_GLOBAL_PREVIOUS_STATE) then
	return
end

local function __NA_SPLIT_WAIT_READY()
	if type(task) ~= "table" or type(task.wait) ~= "function" then
		return false, "task.wait unavailable during startup"
	end
	local deadline = os.clock() + 90
	local function waitFor(check, stage)
		while os.clock() < deadline do
			local ok, ready = pcall(check)
			if ok and ready then return true end
			task.wait(0.15)
		end
		return false, stage.." readiness timed out"
	end
	local ready, err = waitFor(function() return game:IsLoaded() end, "game")
	if not ready then return false, err end
	local players = game:GetService("Players")
	ready, err = waitFor(function() return players.LocalPlayer end, "LocalPlayer")
	if not ready then return false, err end
	ready, err = waitFor(function() return players.LocalPlayer:FindFirstChildOfClass("PlayerGui") end, "PlayerGui")
	if not ready then return false, err end
	ready, err = waitFor(function() return workspace.CurrentCamera end, "CurrentCamera")
	if not ready then return false, err end
	return true
end

local __NA_SPLIT_READY, __NA_SPLIT_READY_ERR = __NA_SPLIT_WAIT_READY()
if not __NA_SPLIT_READY then
	__NARootReportError(__NA_SPLIT_READY_ERR, __NA_SPLIT_READY_ERR, "Nameless Admin Autoexecute Readiness", nil, { severity = "error" })
	return
end

__NA_SPLIT_SESSION = tostring(game.PlaceId).."_"..tostring(game.JobId)
__NA_GLOBAL_PREVIOUS_STATE = type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) or nil
if __NA_SPLIT_ACTIVE(__NA_GLOBAL_PREVIOUS_STATE) then
	return
end

local __NA_SPLIT_STALE = type(__NA_GLOBAL_PREVIOUS_STATE) == "table"
if __NA_SPLIT_STALE and type(warn) == "function" then
	pcall(warn, "[Nameless Admin] Recovering abandoned startup ("..tostring(__NA_GLOBAL_PREVIOUS_STATE.stage or "unknown")..").")
end
if __NA_SPLIT_STALE and type(__NARootHost) == "table" then
	rawset(__NARootHost, "__NA_SPLIT_LOADING", nil)
	if __NA_GLOBAL_PREVIOUS_STATE.loaded ~= true then
		rawset(__NARootHost, "NA_LOADED", nil)
		rawset(__NARootHost, "ltseverydayyou_NA", nil)
	end
end

local __NA_GLOBAL_STATE = {
	loading = true;
	loaded = false;
	source = __NA_SPLIT_SOURCE_TAG;
	token = __NA_SPLIT_LOAD_TOKEN;
	session = __NA_SPLIT_SESSION;
	started = os.clock();
	thread = coroutine.running();
	stage = "bootstrap";
}
__NA_GLOBAL_STATE.updated = __NA_GLOBAL_STATE.started
if type(__NA_GLOBAL_ENV) == "table" then
	rawset(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY, __NA_GLOBAL_STATE)
	if rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) ~= __NA_GLOBAL_STATE then
		return
	end
end

local function __NA_SPLIT_SET_STAGE(stage)
	__NA_GLOBAL_STATE.stage = stage
	__NA_GLOBAL_STATE.updated = os.clock()
end

if type(__NARootHost) == "table" and not __NA_SPLIT_ACTIVE(__NA_GLOBAL_PREVIOUS_STATE) then
	if rawget(__NARootHost, "__NA_SPLIT_LOADING") ~= nil and __NA_GLOBAL_PREVIOUS_STATE == nil then
		rawset(__NARootHost, "__NA_SPLIT_LOADING", nil)
		rawset(__NARootHost, "NA_LOADED", nil)
		rawset(__NARootHost, "ltseverydayyou_NA", nil)
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

local function __NA_SPLIT_CLEAR_OLD_LOCK()
	if type(isfolder) ~= "function" or type(delfolder) ~= "function" then return end
	local key = __NA_SPLIT_SESSION:gsub("[^%w_%-]", "_")
	local path = "Nameless-Admin/.na-split-runtime/lock-"..key
	local ok, exists = pcall(isfolder, path)
	if ok and exists then
		local removed = pcall(delfolder, path)
		if removed and type(warn) == "function" then
			pcall(warn, "[Nameless Admin] Removed abandoned legacy startup lock: "..path)
		end
	end
end
__NA_SPLIT_CLEAR_OLD_LOCK()
if type(__NARootHost) == "table" then
	pcall(rawset, __NARootHost, "NACaller", __NARootNACaller)
end

local function __NA_SPLIT_RELEASE(success)
	if type(__NA_GLOBAL_ENV) == "table" and rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) == __NA_GLOBAL_STATE then
		if success then
			__NA_GLOBAL_STATE.loading = false
			__NA_GLOBAL_STATE.loaded = true
			__NA_GLOBAL_STATE.thread = nil
			__NA_GLOBAL_STATE.token = nil
			__NA_SPLIT_SET_STAGE("ready")
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

__NA_SPLIT_SET_STAGE("manifest")
local __NA_SPLIT_REMOTE_ROOT = rawget(__NARootHost, "__NA_SPLIT_BASE_URL")
if type(__NA_SPLIT_REMOTE_ROOT) ~= "string" or __NA_SPLIT_REMOTE_ROOT == "" then
	__NA_SPLIT_REMOTE_ROOT = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA-split/common/"
end
if __NA_SPLIT_REMOTE_ROOT:sub(-1) ~= "/" then
	__NA_SPLIT_REMOTE_ROOT ..= "/"
end

local __NA_SPLIT_LOCAL_ROOTS = {
	"NA-split/common/";
	"Nameless-Admin/NA-split/common/";
	"Nameless Admin/NA-split/common/";
}
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
		local ok, response = pcall(requestFn, { Method = "GET"; Url = url; })
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
		or 29
) or 0))
local __NA_SPLIT_CACHE_ROOT = __NA_SPLIT_LOCAL_ROOT or __NA_SPLIT_LOCAL_ROOTS[1]
local __NA_SPLIT_PENDING_CACHE = {}
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
	local keep = {}
	for _, value in __NA_SPLIT_REMOTE_META.parts or {} do keep[value] = true end
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

	local host = (type(getgenv) == "function" and getgenv()) or _G or {}
	local state = type(host) == "table" and rawget(host, "__NamelessAdminRuntimeState") or nil
	local sourceTag = type(state) == "table" and state.source or nil
	if sourceTag ~= "Source.lua" and sourceTag ~= "NA testing.lua" then
		return
	end

	local roots = {
		"NA-split/";
		"Nameless-Admin/NA-split/";
		"Nameless Admin/NA-split/";
	}
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
		local ok, response = pcall(requestFn, { Method = "GET"; Url = url; })
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
	for _, name in { path, path..".backup" } do
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
	local environment = setmetatable({
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
	}, {
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
	})
	__NA_SPLIT_ENV = environment
	for index = 1, __NA_SPLIT_COUNT do
		if rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) ~= __NA_GLOBAL_STATE then
			error("Nameless Admin loading was cancelled", 0)
		end
		local partName = string.format("part-%03d.lua", index)
		__NA_SPLIT_SET_STAGE(partName)
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
			local migrated = {}
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
	__NA_SPLIT_SET_STAGE("cache")
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
		local ok, done = pcall(unload, { silent = true })
		if ok and done ~= false then return end
	end
	if type(manage) == "table" and type(manage._runtimeState) == "table" then
		manage._runtimeState.unloading = true
		manage._runtimeState.runToken = nil
	end
	local seen = {}
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
	for _, name in { "NAmanage", "NAStuff", "NAjobs", "NAgui", "NAUIMANAGER", "NAindex", "NAAssetsLoading" } do clean(rawget(runtime, name)) end
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

local __NARootResult = table.pack(__NARootNACaller({
	context = "Nameless Admin Main Runtime";
	details = { stage = __NA_GLOBAL_STATE.stage; session = __NA_SPLIT_SESSION; };
	severity = "fatal";
	warn = true;
	log = true;
}, __NA_SPLIT_RUN))

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
