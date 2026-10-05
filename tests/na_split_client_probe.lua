local host = getgenv()
local cfg = host.__NA_AUDIT_CONFIG
assert(type(cfg) == "table" and type(cfg.ref) == "string" and cfg.ref:match("^%x+$") and #cfg.ref == 40, "Set __NA_AUDIT_CONFIG.ref to a pinned commit")
assert(not host.NA_LOADED and not host.__NamelessAdminRuntimeState, "Unload NA before starting a capture")
local previous = host.__NA_AUDIT_CAPTURE
if type(previous) == "table" and previous.conn then previous.conn:Disconnect() end

local stats = game:GetService("Stats")
local rs = game:GetService("RunService")
local registry = getreg()
local start = os.clock()
local record = {
	label = cfg.label or cfg.ref;
	ref = cfg.ref;
	started = start;
	running = true;
	frames = { {}, {}, {} };
	samples = {};
	spikes = {};
	cache = {};
	chunks = {};
	segments = {};
	thread = setmetatable({}, { __mode = "v" });
}
host.__NA_AUDIT_CAPTURE = record

local function memory()
	return {
		elapsed = os.clock() - start;
		totalMb = stats:GetTotalMemoryUsageMb();
		engineLuaMb = stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.LuaHeap);
		executorLuaKb = gcinfo();
		instances = stats.InstanceCount;
	}
end

local function runtime()
	local root = rawget(registry, "__nameless_admin_private")
	local env = type(root) == "table" and rawget(root, "testing")
	return type(env) == "table" and rawget(env, "runtime") or nil
end

local function count(tab)
	local n = 0
	if type(tab) == "table" then for _ in tab do n += 1 end end
	return n
end

local function frames(values)
	local n, sum, max, over16, over33, over100 = #values, 0, 0, 0, 0, 0
	for _, dt in values do
		sum += dt
		max = math.max(max, dt)
		if dt > 1 / 60 then over16 += 1 end
		if dt > 1 / 30 then over33 += 1 end
		if dt > 0.1 then over100 += 1 end
	end
	table.sort(values)
	return {
		frames = n;
		fps = sum > 0 and n / sum or 0;
		maxMs = max * 1000;
		p95Ms = n > 0 and values[math.max(1, math.ceil(n * 0.95))] * 1000 or 0;
		p99Ms = n > 0 and values[math.max(1, math.ceil(n * 0.99))] * 1000 or 0;
		over16Ms = over16;
		over33Ms = over33;
		over100Ms = over100;
	}
end

local function snapshot(rt)
	if type(rt) ~= "table" then return nil end
	local stuff = rawget(rt, "NAStuff") or {}
	local manage = rawget(rt, "NAmanage") or {}
	local state = manage._runtimeState or {}
	local perf = stuff.StartupPerformance or {}
	local active, buckets = 0, 0
	for _, bucket in stuff.conns or {} do
		if type(bucket) == "table" then
			buckets += 1
			for _, conn in bucket do
				local ok, live = pcall(function() return conn.Connected end)
				if ok and live then active += 1 end
			end
		end
	end
	local stages = {}
	for i, stage in perf.stages or {} do
		if i > 40 then break end
		stages[#stages + 1] = { name = stage.name; elapsed = stage.elapsed; at = stage.at; }
	end
	return {
		spawnActive = count(state.spawnActive);
		waitingThreads = count(state.waitingThreads);
		connectionBuckets = buckets;
		liveConnections = active;
		queueRunning = manage._loaderQueueRunning;
		queuePumping = manage._loaderQueuePumping;
		settingsReady = stuff.SettingsBuildReady;
		networkPauseDisabled = stuff.NetworkPauseDisabled;
		lowEndMode = stuff.LowEndMode;
		commandRebuilds = stuff.CommandBuildSerial;
		perf = {
			elapsed = perf.elapsed; readyElapsed = perf.readyElapsed;
			settingsBuildElapsed = perf.settingsBuildElapsed; settingsBuildOk = perf.settingsBuildOk;
			maxFrameMs = (perf.maxFrame or 0) * 1000; frames = perf.frames;
			finished = perf.finished; status = perf.finishedStatus;
			instanceYields = perf.instanceYields; commandYields = perf.commandYields;
			uiFetchElapsed = perf.uiFetchElapsed; uiPrepareElapsed = perf.uiPrepareElapsed;
			uiCompileElapsed = perf.uiCompileElapsed; uiSourceMode = perf.uiSourceMode;
			stages = stages;
		};
	}
end

local function finish(reason)
	if not record.running then return end
	record.running = false
	if record.conn then record.conn:Disconnect(); record.conn = nil end
	local all, after = {}, {}
	for phase, values in record.frames do
		for _, dt in values do
			all[#all + 1] = dt
			if phase > 1 then after[#after + 1] = dt end
		end
	end
	record.summary = {
		label = record.label; ref = record.ref; reason = reason;
		elapsed = os.clock() - start; loadingClosed = record.loadingClosed;
		settingsReady = record.settingsReady; splitLoaded = record.splitLoaded;
		loaderReturned = record.loaderReturned; loadError = record.loadError;
		guard = record.guard;
		before = record.before; after = memory(); cache = record.cache;
		all = frames(all); beforeLoadingClose = frames(record.frames[1]);
		afterLoadingClose = frames(after); afterSettingsReady = frames(record.frames[3]);
		spikes = record.spikes; chunks = record.chunks; segments = record.segments; runtime = snapshot(runtime());
	}
	record.frames = nil
end

record.before = memory()
for _, root in { "NA-split/common/", "Nameless-Admin/NA-split/common/", "Nameless Admin/NA-split/common/" } do
	local ok, text = pcall(readfile, root.."manifest.lua")
	if ok and type(text) == "string" then
		record.cache[#record.cache + 1] = { root = root; version = text:match('version%s*=%s*"([^"]+)"'); }
	end
end

local nextSample = start + 1
record.conn = rs.Heartbeat:Connect(function(dt)
	local now = os.clock()
	local rt = runtime()
	local stuff = rt and rawget(rt, "NAStuff")
	local assets = rt and rawget(rt, "NAAssetsLoading")
	local manage = rt and rawget(rt, "NAmanage")
	local globalState = rawget(host, "__NamelessAdminRuntimeState")
	if not record.loadingClosed and ((stuff and stuff._loadingFinalizedOnce) or (assets and assets._finalized)) then
		local perf = stuff and stuff.StartupPerformance
		record.loadingClosed = type(perf) == "table" and perf.readyElapsed and (perf.started + perf.readyElapsed - start) or now - start
	end
	if not record.settingsReady and stuff and stuff.SettingsBuildReady == true and stuff.SettingsBuildRunning ~= true then
		record.settingsReady = now - start
	end
	if not record.splitLoaded and type(globalState) == "table" and globalState.loaded == true then record.splitLoaded = now - start end
	local phase = record.settingsReady and 3 or (record.loadingClosed and 2 or 1)
	local bucket = record.frames[phase]
	if #bucket < 60000 then bucket[#bucket + 1] = dt end
	if dt > 1 / 30 and #record.spikes < 64 then
		record.spikes[#record.spikes + 1] = { elapsed = now - start; ms = dt * 1000; phase = phase; }
	end
	if now >= nextSample then
		record.samples[#record.samples + 1] = memory()
		nextSample = now + 1
	end
	local busy = manage and (manage._loaderQueuePumping == true or (manage._loaderQueueRunning or 0) > 0 or next(manage._startupLoaderThreads or {}) ~= nil)
	busy = busy or (stuff and (stuff.cmdAutofillLoading == true or stuff.CommandBuildWorkerQueued == true or stuff.SettingsBuildRunning == true))
	if record.loadingClosed and record.settingsReady and record.splitLoaded and not busy
		and now - start >= record.loadingClosed + (cfg.postSeconds or 20)
		and now - start >= record.settingsReady + 5 then
		finish("settled")
	elseif record.loadError and now - start > 3 then
		finish("load-error")
	elseif now - start >= (cfg.maxSeconds or 120) then
		finish("deadline")
	end
end)

host.__NA_SPLIT_BASE_URL = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/"..cfg.ref.."/NA-split/common/"
task.defer(function()
	record.thread[1] = coroutine.running()
	local ok, err = pcall(function()
		local text = game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/"..cfg.ref.."/Source.lua")
		local function replace(find, replacement)
			local at = assert(text:find(find, 1, true), "Missing loader anchor: "..find)
			text = text:sub(1, at - 1)..replacement..text:sub(at + #find)
		end
		local guard = 'local __NA_SPLIT_HOST_LOADING ='
		replace(guard, 'local __NAProbe = rawget(__NARootHost, "__NA_AUDIT_CAPTURE"); __NAProbe.guard = { sameHost = __NARootHost == getgenv(); stateWritten = rawget(__NA_GLOBAL_ENV, __NA_GLOBAL_STATE_KEY) == __NA_GLOBAL_STATE; legacy = rawget(__NARootHost, "ltseverydayyou_NA"); loaded = rawget(__NARootHost, "NA_LOADED"); loading = tostring(rawget(__NARootHost, "__NA_SPLIT_LOADING")) };\n'..guard)
		local result = 'if not __NARootResult[1] then pcall(__NA_SPLIT_ABORT) end'
		if text:find(result, 1, true) then
			replace(result, '__NAProbe.guard.ok = __NARootResult[1]; __NAProbe.guard.error = type(__NARootResult[2]) == "string" and __NARootResult[2]:sub(1, 2000) or nil;\n'..result)
		end
		if cfg.traceSegments then
			local migrate = 'environment = boot.runtimeEnv'
			local hook = [[
local audit = rawget(__NARootHost, "__NA_AUDIT_CAPTURE")
local ticks = setmetatable({}, { __mode = "k" })
local oldWait = environment.Wait
environment.Wait = function(...)
	local th = coroutine.running()
	local at = os.clock()
	local previous = ticks[th]
	local trace = debug.traceback(nil, 2):sub(1, 1600)
	if previous and at - previous.at > 0.025 and #audit.segments < 64 then
		audit.segments[#audit.segments + 1] = { elapsed = at - audit.started; ms = (at - previous.at) * 1000; before = previous.trace; after = trace; }
	end
	local elapsed = oldWait(...)
	ticks[th] = { at = os.clock(); trace = trace; }
	return elapsed
end
]]
			replace(migrate, migrate..'\n'..hook)
		end
		replace("local function __NA_SPLIT_RUN()", "local function __NA_SPLIT_RUN()\nlocal __NAAudit = rawget(__NARootHost, \"__NA_AUDIT_CAPTURE\")")
		local name = 'local partName = string.format("part-%03d.lua", index)'
		replace(name, name..'\nlocal __NARow = { part = partName }; __NAAudit.chunks[index] = __NARow; __NAAudit.currentPart = partName; __NAAudit.phase = "fetch"; local __NAAt = os.clock()')
		local read = 'local source = __NA_SPLIT_READ_PART(partName)'
		replace(read, read..'\n__NARow.fetch = os.clock() - __NAAt; __NAAt = os.clock(); __NAAudit.phase = "compile"')
		local compile = 'local chunk = __NA_SPLIT_LOAD_PART(source, "NA-split/common/"..partName, environment)'
		replace(compile, compile..'\n__NARow.compile = os.clock() - __NAAt; __NAAt = os.clock(); __NAAudit.phase = "execute"')
		local run = 'local okRun, runError = xpcall(chunk, __NA_SPLIT_FORMAT_ERROR)'
		replace(run, run..'\n__NARow.execute = os.clock() - __NAAt; __NAAudit.phase = "between-chunks"')
		local fn, compileError = loadstring(text, "@NA-audit-"..record.label)
		assert(fn, compileError)
		fn()
		local state = rawget(host, "__NamelessAdminRuntimeState")
		assert(type(state) == "table" and state.loaded == true, "Loader returned without marking the runtime loaded")
	end)
	record.thread[1] = nil
	record.loaderReturned = os.clock() - start
	if not ok then record.loadError = tostring(err):sub(1, 2000) end
end)
