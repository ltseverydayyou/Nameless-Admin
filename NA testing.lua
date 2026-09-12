local __NA_SPLIT_SOURCE_TAG = "NA testing.lua"
local __NA_SPLIT_CONFIG = {
	testing = true;
	sourceTag = __NA_SPLIT_SOURCE_TAG;
}

--!nonstrict
-- © 2026 Nameless Admin. All rights reserved. Do not copy, paste, redistribute, or claim as your own.

local __NARootHost = (getgenv and getgenv()) or _G or {}
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

if type(__NARootHost) == "table" then
	pcall(rawset, __NARootHost, "NACaller", __NARootNACaller)
end


local __NA_SPLIT_LOAD_TOKEN = {}
local __NA_SPLIT_HOST_LOADING = type(__NARootHost) == "table" and rawget(__NARootHost, "__NA_SPLIT_LOADING") or nil
local __NA_SPLIT_HOST_LOADED = type(__NARootHost) == "table" and (rawget(__NARootHost, "ltseverydayyou_NA") ~= nil or rawget(__NARootHost, "NA_LOADED") ~= nil)
if __NA_SPLIT_HOST_LOADING ~= nil or __NA_SPLIT_HOST_LOADED then
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
local __NA_SPLIT_USE_REMOTE = __NA_SPLIT_REMOTE_META ~= nil
	and (__NA_SPLIT_LOCAL_META == nil or __NA_SPLIT_REMOTE_META.version ~= __NA_SPLIT_LOCAL_META.version)
local __NA_SPLIT_COUNT = math.max(0, math.floor(tonumber(
	(__NA_SPLIT_USE_REMOTE and __NA_SPLIT_REMOTE_META and __NA_SPLIT_REMOTE_META.count)
		or (__NA_SPLIT_LOCAL_META and __NA_SPLIT_LOCAL_META.count)
		or 27
) or 0))
local __NA_SPLIT_CACHE_ROOT = __NA_SPLIT_LOCAL_ROOT or __NA_SPLIT_LOCAL_ROOTS[1]
local __NA_SPLIT_PENDING_CACHE = {}

local function __NA_SPLIT_READ_PART(partName)
	if not __NA_SPLIT_USE_REMOTE and __NA_SPLIT_LOCAL_ROOT then
		return __NA_SPLIT_READ_LOCAL(__NA_SPLIT_LOCAL_ROOT, partName)
	end
	local remote = __NA_SPLIT_READ_REMOTE(partName)
	if remote then
		__NA_SPLIT_PENDING_CACHE[partName] = remote
		return remote
	end
	if __NA_SPLIT_LOCAL_ROOT and not __NA_SPLIT_REMOTE_META then
		return __NA_SPLIT_READ_LOCAL(__NA_SPLIT_LOCAL_ROOT, partName)
	end
	error("Nameless Admin chunk unavailable: "..partName, 0)
end

local function __NA_SPLIT_CACHE_REMOTE()
	if not __NA_SPLIT_USE_REMOTE or not __NA_SPLIT_REMOTE_MANIFEST_SOURCE or type(writefile) ~= "function" then
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
	for index = 1, __NA_SPLIT_COUNT do
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
		end
	end
	__NA_SPLIT_CACHE_REMOTE()
end

local __NARootResult = table.pack(NACaller({
	context = "Nameless Admin Main Runtime";
	severity = "fatal";
	warn = true;
	log = true;
}, __NA_SPLIT_RUN))

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
	__NA_SPLIT_CLEAR_LOADING()
	return table.unpack(__NARootResult, 2, __NARootResult.n)
end

__NA_SPLIT_CLEAR_LOADING()
