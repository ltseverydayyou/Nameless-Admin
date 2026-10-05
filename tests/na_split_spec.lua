local checks = 0
local function check(value, message)
	assert(value, message)
	checks += 1
end
local function load(text, env)
	local fn, err = loadstring(text)
	assert(fn, err)
	setfenv(fn, env)
	return fn()
end
local function scheduler()
	local jobs, now, yields = {}, 0, 0
	local api = {}
	local function resume(thread, ...)
		local ok, err = coroutine.resume(thread, ...)
		assert(ok, err)
	end
	function api.spawn(fn, ...)
		local thread = coroutine.create(fn)
		resume(thread, ...)
		return thread
	end
	function api.defer(fn, ...)
		local thread = coroutine.create(fn)
		jobs[#jobs + 1] = { thread, now, table.pack(...) }
		return thread
	end
	function api.delay(delay, fn, ...)
		local thread = coroutine.create(fn)
		jobs[#jobs + 1] = { thread, now + delay, table.pack(...) }
		return thread
	end
	function api.wait(delay)
		yields += 1
		jobs[#jobs + 1] = { coroutine.running(), now + math.max(delay or 0, 1 / 60), table.pack(1 / 60) }
		return coroutine.yield()
	end
	function api.cancel(thread)
		for i = #jobs, 1, -1 do if jobs[i][1] == thread then table.remove(jobs, i) end end
		if coroutine.status(thread) ~= "dead" then coroutine.close(thread) end
	end
	function api.step()
		if #jobs == 0 then return false end
		local at = 1
		for i = 2, #jobs do if jobs[i][2] < jobs[at][2] then at = i end end
		local job = table.remove(jobs, at)
		now = math.max(now, job[2])
		if coroutine.status(job[1]) ~= "dead" then resume(job[1], table.unpack(job[3], 1, job[3].n)) end
		return true
	end
	function api.drain(limit)
		local steps = 0
		while api.step() do
			steps += 1
			assert(steps <= (limit or 10000), "scheduler did not settle")
		end
	end
	function api.clock() return now end
	function api.yields() return yields end
	function api.pending() return #jobs end
	function api.advance(seconds) now += seconds end
	return api
end
local function signal()
	local records = {}
	local sig = {}
	function sig:Connect(fn)
		local conn = { Connected = true; _kind = "RBXScriptConnection"; }
		function conn:Disconnect() self.Connected = false end
		records[#records + 1] = { fn, conn }
		return conn
	end
	function sig:Fire(...)
		for _, rec in records do if rec[2].Connected then rec[1](...) end end
	end
	return sig
end
local function instance(class, parent)
	local obj = { ClassName = class; Parent = parent; _kind = "Instance"; kids = {}; AncestryChanged = signal(); DescendantAdded = signal(); DescendantRemoving = signal(); queries = 0; }
	function obj:IsA(wanted)
		return wanted == "Instance" or wanted == self.ClassName or (wanted == "BasePart" and self.ClassName == "Part")
			or (wanted == "PostEffect" and self.ClassName == "BloomEffect")
			or (wanted == "GuiObject" and (self.ClassName == "Frame" or self.ClassName == "TextLabel"))
	end
	function obj:IsDescendantOf(root)
		local current = self.Parent
		while current do if current == root then return true end; current = current.Parent end
		return false
	end
	function obj:FindFirstChildOfClass(wanted)
		for _, child in self.kids do if child:IsA(wanted) then return child end end
	end
	local props = {}
	function obj:GetPropertyChangedSignal(name)
		props[name] = props[name] or signal()
		return props[name]
	end
	function obj:GetChildren() return table.clone(self.kids) end
	function obj:QueryDescendants(wanted)
		self.queries += 1
		local list = {}
		local function scan(node)
			for _, child in node.kids do
				if child:IsA(wanted) then list[#list + 1] = child end
				scan(child)
			end
		end
		scan(self)
		return list
	end
	function obj:FindFirstChild(name)
		for _, child in self.kids do if child.Name == name then return child end end
	end
	function obj:FindFirstAncestor(name)
		local current = self.Parent
		while current do if current.Name == name then return current end; current = current.Parent end
	end
	function obj:GetAttribute(name) return self[name] end
	function obj:Destroy() self.Parent = nil; self.destroyed = true end
	if parent then parent.kids[#parent.kids + 1] = obj end
	return obj
end
local function environment()
	local api = scheduler()
	local env = setmetatable({ NAmanage = {}; NAlib = {}; NAStuff = { conns = {} }; NAgui = {}; task = api; _na_env = {}; IsOnMobile = false; }, { __index = getfenv() })
	env.os = { clock = api.clock; time = os.time; date = os.date; }
	env.typeof = function(value) return type(value) == "table" and value._kind or typeof(value) end
	env.Insert = table.insert
	env.Spawn, env.Defer, env.Delay, env.Wait = api.spawn, api.defer, api.delay, api.wait
	env.NAmanage.safeConnect = function(sig, fn) return sig and sig:Connect(fn) end
	env.NAmanage.QueryDescendants = function(root, wanted) return root and root:QueryDescendants(wanted) or {} end
	load(source.weak, env)
	return env, api
end
local function test(name, fn)
	fn()
	print("PASS: "..name)
end

test("tracked task completion, cancellation, and wait values", function()
	local env, api = environment()
	local token = {}
	env.NAmanage._runToken = token
	env._na_env._NARunToken = token
	env.NAmanage._runtimeState = { spawnActive = {}; waitingThreads = {}; }
	env._naRawTaskSpawn, env._naRawTaskDefer = api.spawn, api.defer
	env._naRawTaskDelay, env._naRawTaskWait = api.delay, api.wait
	env.__NARootReportError = error
	load(source.tasks, env)
	local ran, elapsed = 0, nil
	local done = env.Spawn(function() ran += 1 end)
	check(coroutine.status(done) == "dead" and next(env.NAmanage._runtimeState.spawnActive) == nil, "completed task was retained")
	env.Spawn(function() elapsed = env.Wait(); ran += 1 end)
	api.drain()
	check(elapsed == 1 / 60 and ran == 2, "Wait return changed")
	check(next(env.NAmanage._runtimeState.waitingThreads) == nil, "wait thread retained")
	env.Defer(function() ran += 1 end)
	env._na_env._NARunToken = {}
	api.drain()
	check(ran == 2 and next(env.NAmanage._runtimeState.spawnActive) == nil, "old deferred task ran after cancellation")
end)

test("connection maintenance scales without revisiting buckets", function()
	local env = environment()
	local inspected = 0
	env.NAmanage.isLiveConnection = function(conn) inspected += 1; return conn.Connected end
	env.NAStuff.prCnt = 0
	load(source.prune, env)
	load(source.pruneAll, env)
	for i = 1, 2000 do env.NAlib.connect("large", { Connected = true; Disconnect = function(self) self.Connected = false end }) end
	check(inspected < 20000, "connection appends grew quadratically")
	local patched = inspected
	local old = environment()
	local oldInspected = 0
	old.NAmanage.isLiveConnection = function(conn) oldInspected += 1; return conn.Connected end
	old.NAStuff.prCnt = 0
	load(source.baselinePrune, old)
	for i = 1, 2000 do old.NAlib.connect("large", { Connected = true; Disconnect = function(self) self.Connected = false end }) end
	check(patched < oldInspected / 20, "connection append improvement regressed")
	print(string.format("MEASURE: 2,000 connection appends inspected %d records before and %d after", oldInspected, patched))
	inspected = 0
	check(env.NAmanage.prnAllCon(128) == 1 and inspected == 2000, "maintenance revisited the same bucket")
	for i = 1, 2000, 2 do env.NAStuff.conns.large[i].Connected = false end
	env.NAmanage.prnAllCon(128)
	check(#env.NAStuff.conns.large == 1000, "dead connections were not pruned")
	env.NAlib.disconnect("large")
	check(next(env.NAStuff.conns) == nil, "bucket was not released")
end)

test("descendant burst filtering, batching, order, and disposal", function()
	local env, api = environment()
	load(source.tasks:sub((source.tasks:find("NAmanage.WorkBudgetStep", 1, true))), env)
	load(source.dispatch..source.classes..source.events, env)
	local hub = env.NAmanage._evtHubInit({})
	hub.refresh = function() end
	hub.dispose = function() hub.alive = false; env.NAmanage._evtHubClear(hub) end
	local seen = {}
	local conn = env.NAmanage._evtHubSub(hub, { classAdded = "BasePart"; classRemoving = "Instance"; added = function(obj) seen[#seen + 1] = obj.id end; removing = function() end; })
	for i = 1, 1000 do
		local obj = instance(i % 2 == 0 and "Part" or "Folder")
		obj.id = i
		env.NAmanage._evtHubDeferFire(hub, "add", obj)
	end
	check(api.pending() == 1 and hub.evtTail == 500, "irrelevant descendants were queued or a task was created per event")
	api.drain()
	check(#seen == 500 and api.yields() >= 7, "burst did not yield or lost events")
	for i = 1, #seen do check(seen[i] == i * 2, "event order changed") end
	check(next(hub.events) == nil and not hub.evtRunning, "event instances were retained")
	local extra = instance("Part"); extra.id = 1002
	env.NAmanage._evtHubDeferFire(hub, "add", extra)
	conn:Disconnect()
	api.drain()
	check(#seen == 500 and next(hub.events) == nil, "disposed handler fired")
end)

test("yielding descendant callbacks keep later events moving", function()
	local env, api = environment()
	load(source.tasks:sub((source.tasks:find("NAmanage.WorkBudgetStep", 1, true))), env)
	load(source.dispatch..source.classes..source.events, env)
	local hub = env.NAmanage._evtHubInit({})
	local done = {}
	env.NAmanage._evtHubSub(hub, { added = function(obj) if obj.id == 1 then api.wait(0.3) end; done[#done + 1] = obj.id end })
	for i = 1, 2 do local obj = instance("Part"); obj.id = i; env.NAmanage._evtHubDeferFire(hub, "add", obj) end
	api.drain()
	check(done[1] == 2 and done[2] == 1, "yielding callback blocked subsequent events")
end)

test("character caches track additions, removals, respawns, and destruction", function()
	local env = environment()
	local subs = {}
	env.NAmanage.descSub = function(root, spec)
		local conn = { Connected = true; Disconnect = function(self) self.Connected = false end; }
		subs[root] = { spec = spec; conn = conn }
		return conn
	end
	load(source.parts, env)
	local world = instance("Workspace")
	local char = instance("Model", world)
	local part = instance("Part", char)
	for i = 1, 600 do check(env.NAmanage.GetCharacterParts(char)[part] == true, "cached part missing") end
	check(char.queries == 1, "character was scanned per frame")
	local added = instance("Part", char)
	subs[char].spec.added(added)
	check(env.NAmanage.GetCharacterParts(char)[added], "new part not tracked")
	subs[char].spec.removing(part)
	check(env.NAmanage.GetCharacterParts(char)[part] == nil, "removed part retained")
	local nextChar = instance("Model", world)
	local nextPart = instance("Part", nextChar)
	check(env.NAmanage.GetCharacterParts(nextChar)[nextPart] and not subs[char].conn.Connected, "respawn did not release old subscription")
	check(env.NAmanage._charPartCache.root == nextChar, "respawn cache mismatch")
	nextChar.Parent = nil
	nextChar.AncestryChanged:Fire(nextChar, nil)
	check(not subs[nextChar].conn.Connected and next(env.NAmanage._charPartCache.parts) == nil, "destroyed character retained")
end)

test("startup queue preserves jobs added by its final running job", function()
	local env, api = environment()
	env.NAmanage.runLoader = function(_, callback) return callback() end
	env.NAStuff.StartupInitializersReady = false
	load(source.queue, env)
	local ran = {}
	env.NAmanage.scheduleLoader("parent", function()
		api.wait(0.2)
		ran[#ran + 1] = "parent"
		env.NAmanage.scheduleLoader("child", function() ran[#ran + 1] = "child" end)
	end)
	check(#ran == 0 and api.pending() == 0, "startup gate ignored")
	env.NAStuff.StartupInitializersReady = true
	env.NAmanage.pumpLoaderQueue()
	api.drain()
	check(table.concat(ran, ",") == "parent,child", "newly scheduled job lost")
	check(env.NAmanage._loaderQueueTail == 0 and env.NAmanage._loaderQueueRunning == 0 and not env.NAmanage._loaderQueuePumping, "queue state retained")
end)

test("startup queue limits concurrency and pauses heavy work for settings", function()
	local env, api = environment()
	env.NAmanage.runLoader = function(_, callback) return callback() end
	env.IsOnMobile = true
	env.NAStuff.StartupInitializersReady = false
	env.NAStuff.SettingsBuildRunning = true
	load(source.queue, env)
	local active, peak, heavyAt = 0, 0, nil
	for i = 1, 8 do env.NAmanage.scheduleLoader("light", function() active += 1; peak = math.max(peak, active); api.wait(0.1); active -= 1 end) end
	env.NAmanage.scheduleLoader("heavy", function() heavyAt = api.clock() end, { heavy = true })
	env.NAStuff.StartupInitializersReady = true
	env.NAmanage.pumpLoaderQueue()
	api.delay(1.5, function() env.NAStuff.SettingsBuildRunning = false end)
	api.drain()
	check(peak == 1 and heavyAt >= 1.5, "settings overlapped heavy startup jobs")
	local maxRunning = env.NAmanage._loaderQueueProfile()
	check(maxRunning == 2, "mobile concurrency was not limited")
end)

test("startup callback errors release the queue", function()
	local env, api = environment()
	env.NAmanage.runLoader = function(_, callback) return callback() end
	load(source.queue, env)
	local ran = false
	env.NAmanage.scheduleLoader("bad", function() error("expected failure") end)
	env.NAmanage.scheduleLoader("good", function() ran = true end)
	api.drain()
	check(ran and env.NAmanage._loaderQueueRunning == 0 and not env.NAmanage._loaderQueuePumping, "failed callback stranded queue")
end)

test("streaming traversal yields and honors cancellation, limits, and subtree skips", function()
	local env, api = environment()
	load(source.tasks:sub((source.tasks:find("NAmanage.WorkBudgetStep", 1, true))), env)
	load(source.traversal, env)
	local world = instance("Workspace")
	env.Services = { Workspace = world }
	local root = instance("Model", world)
	for i = 1, 500 do instance("Part", root) end
	local total
	api.spawn(function() total = env.NAmanage.ForEachDescendantYield(root, function() end) end)
	api.drain()
	check(total == 500 and api.yields() >= 5 and root.queries == 0, "default traversal allocated a full query or did not yield")
	local cancel = {}
	api.spawn(function() total = env.NAmanage.ForEachDescendantYield(root, function() end, { yieldEvery = 10; cancelToken = cancel }) end)
	cancel.cancelled = true
	api.drain()
	check(total == 10, "traversal continued after cancellation")
	api.spawn(function() total = env.NAmanage.ForEachDescendantYield(root, function() end, { maxItems = 7 }) end)
	api.drain()
	check(total == 7, "traversal exceeded item limit")
	api.spawn(function() total = env.NAmanage.ForEachDescendantYield(root, function() end, { includeRoot = true; skipChildren = function(obj) return obj == root end }) end)
	api.drain()
	check(total == 1, "subtree skip ignored")
end)

test("UI traversal uses native snapshots and one wait per count or time budget", function()
	local env, api = environment()
	load(source.tasks:sub((source.tasks:find("NAmanage.WorkBudgetStep", 1, true))), env)
	load(source.traversal, env)
	local gui = instance("ScreenGui")
	for i = 1, 120 do instance("Frame", gui) end
	local waits, total = {}, 0
	env.Wait = function(delay) waits[#waits + 1] = delay or 0; return api.wait(delay) end
	api.spawn(function() total = env.NAmanage.ForEachDescendantYield(gui, function() end, { yieldEvery = 40; delayTime = 0.02 }) end)
	api.drain()
	check(gui.queries == 1 and total == 120 and #waits == 3, "UI snapshot performed per-instance walks or double waits")
	for _, delay in waits do check(delay == 0.02, "count boundary lost configured delay") end
	table.clear(waits)
	api.spawn(function() total = env.NAmanage.ForEachDescendantYield(gui, function() api.advance(0.004) end, { yieldEvery = 40; delayTime = 0.02 }) end)
	api.drain()
	check(total == 120 and #waits >= 60 and #waits <= 120, "slow handlers bypassed time budgets or waited twice")
	for _, delay in waits do check(delay == 0, "time boundary added the count-boundary sleep") end
end)

test("network pause startup is deferred, coalesced, selective, cancellable, and restored", function()
	local env, api = environment()
	load(source.tasks:sub((source.tasks:find("NAmanage.WorkBudgetStep", 1, true))), env)
	load(source.cancelTokens, env)
	local core = instance("CoreGui")
	local roblox = instance("Frame", core); roblox.Name = "RobloxGui"
	for i = 1, 10000 do instance("ModuleScript", roblox) end
	local off = instance("ScreenGui", core); off.Name = "RobloxNetworkPauseNotification"; off.Enabled = false
	local on = instance("ScreenGui", core); on.Name = "NetworkPauseOverlay"; on.Enabled = true
	local other = instance("ScreenGui", core); other.Name = "Other"; other.Enabled = true
	env.LocalPlayer = instance("Player"); env.LocalPlayer.GameplayPaused = false
	env.Services = { CoreGui = core; RunService = { SetRobloxGuiFocused = function() end } }
	env.Lower, env.NACaller = string.lower, function(fn) return fn() end
	local watches, spec, cleanup = 0, nil, nil
	env.NAmanage.descSub = function(root, current)
		check(root == core, "network pause scanned a duplicate root")
		watches += 1; spec = current
		return signal():Connect(function() end)
	end
	env.NAmanage.tryDisconnect = function(conn) conn:Disconnect() end
	env.NAmanage.RegisterUnloadCleanup = function(_, fn) cleanup = fn end
	load(source.networkPause, env)
	env.NAmanage.setNetworkPauseBlocked(true)
	check(watches == 1 and spec and core.queries == 0 and api.pending() == 1, "network pause blocked startup or installed watchers too late")
	env.NAmanage.setNetworkPauseBlocked(true)
	check(api.pending() == 1 and watches == 1, "repeated requests duplicated scans or watchers")
	api.drain()
	check(core.queries == 2 and not off.Enabled and not on.Enabled and other.Enabled, "network pause scanned unrelated descendants or missed overlays")
	check(env.networkPauseBlock.guiEnabled[off] == false, "disabled overlay baseline became enabled")
	local added = instance("ScreenGui", core); added.Name = "NetworkPauseAdded"; added.Enabled = true
	if spec.filterAdded(added) then spec.added(added) end
	check(not added.Enabled, "overlay added after startup was missed")
	spec.removing(added)
	check(env.networkPauseBlock.guiConns[added] == nil and env.networkPauseBlock.guiEnabled[added] == nil, "removed overlay retained a connection or baseline")
	cleanup()
	check(not env.networkPauseBlock.blocking and not off.Enabled and on.Enabled, "cleanup did not restore original overlay states")
	local queries = core.queries
	env.NAmanage.setNetworkPauseBlocked(true)
	local cancelled = env.networkPauseBlock.scanToken
	env.NAmanage.setNetworkPauseBlocked(false)
	env.NAmanage.setNetworkPauseBlocked(true)
	local current = env.networkPauseBlock.scanToken
	api.drain()
	check(cancelled.cancelled and cancelled ~= current and core.queries == queries + 2, "cancelled scan ran or replaced its successor")
	check(env.networkPauseBlock.scanToken == nil, "finished network pause scan was retained")
	cleanup()
end)

test("settings construction yields within mobile and desktop batches", function()
	for _, mobile in { false, true } do
		local env, api = environment()
		env.IsOnMobile = mobile
		env.NAgui.getSettingsTarget = function() return true end
		load(source.settings, env)
		api.spawn(function() for i = 1, 30 do env.NAgui.SettingsBuildStep() end end)
		api.drain()
		check(api.yields() == (mobile and 10 or 5), "settings batch budget not applied")
		env.NAgui.SettingsBuildDone()
		check(not env.NAgui.SettingsBuildState.building, "settings stayed in building state")
	end
end)

test("incremental chat normalization avoids whole-frame queries", function()
	local env = environment()
	env.NAmanage.WorkBudgetStep = function() end
	local world = instance("ScreenGui")
	local frame = instance("Frame", world)
	local container = instance("Frame", frame); container.Name = "Container"
	local popup = instance("Frame", frame); popup.Name = "NAChatMessageMenu"
	env.NAUIMANAGER = { NAchatFrame = frame }
	load(source.zindex, env)
	for i = 1, 1000 do
		local obj = instance("TextLabel", i % 2 == 0 and container or popup)
		env.NAmanage.NAChatNormalizeZIndex(obj)
		check(obj.ZIndex == (i % 2 == 0 and 30 or 90), "chat layer changed")
	end
	check(frame.queries == 0, "added chat object triggered full-frame query")
	env.NAmanage.NAChatNormalizeZIndex()
	check(frame.queries == 1 and frame.ZIndex == 0, "initial normalization failed")
end)

test("cleanup reaches owned connections and suspended tasks through cyclic tables", function()
	local env, api = environment()
	load(source.cleanup, env)
	local conn = signal():Connect(function() end)
	local thread = api.spawn(function() api.wait(10) end)
	local root = { nested = { conn = conn; thread = thread }; }
	root.nested.owner = root
	local summary = { connections = 0; threads = 0; }
	env.NAmanage.UnloadDisconnectTree(root, summary)
	check(not conn.Connected and api.pending() == 0 and root.nested.conn == nil and root.nested.thread == nil, "cyclic cleanup retained resources")
	check(summary.connections == 1 and summary.threads == 1, "cleanup accounting mismatch")
	local waiting = api.spawn(function() api.wait(10) end)
	local state = { waitingThreads = { [waiting] = true }; spawnActive = { [waiting] = true }; }
	env.NAmanage.UnloadCancelRuntimeTasks(state, summary)
	check(next(state.waitingThreads) == nil and next(state.spawnActive) == nil and api.pending() == 0, "tracked task retained")
end)

test("cancelled workspace cache workers cannot complete or overwrite a newer build", function()
	local env, api = environment()
	local world = instance("Workspace")
	for i = 1, 5 do instance("Part", world) end
	env.Services = { Workspace = world }
	env.__lt = { gs = function() return world end }
	env.NAmanage._evtHubBudget = function() return 2, 0 end
	env.NAmanage._wsCacheConnect = function() end
	env.NAmanage._evtHubDisc = function() return nil end
	env.NAmanage._wsCacheAdd = function(hub, obj) hub.cache[#hub.cache + 1] = obj end
	load(source.wsBuild..source.wsRelease, env)
	local hub = { root = world; alive = true }
	env.NAmanage._wsCacheBuildAsync(hub)
	env.NAmanage.wsReleaseCache(hub)
	api.drain()
	check(#hub.cache == 0 and not hub.cacheLive and hub.cacheBuiltAt == nil, "cancelled cache was marked ready")
	env.NAmanage._wsCacheBuildAsync(hub)
	env.NAmanage.wsReleaseCache(hub)
	env.NAmanage._wsCacheBuildAsync(hub)
	local token = hub.cacheToken
	api.drain()
	check(#hub.cache == 5 and hub.cacheToken == token and not hub.cacheBuilding, "old worker contaminated new cache build")
end)

test("final settings mount preserves selection and releases the build gate", function()
	local env, api = environment()
	env.NA_TABS = { TAB_GENERAL = "General" }
	env.TabManager = { tabs = { General = {}; Other = {} } }
	env.NAStuff.SettingsBuildRunning = true
	env.NAStuff._loadingFinalizePending = true
	env.NAgui.getSettingsTarget = function() return true end
	load(source.settings, env)
	env.NAgui.SettingsBuildState.userSelectedTab = "Other"
	local mounts, selected, finalized = 0, nil, false
	env.NAgui.setTab = function(tab)
		mounts += 1
		selected = tab
		for i = 1, 12 do env.NAgui.SettingsBuildStep() end
	end
	env.NAmanage.finalizeLoadingState = function() finalized = true end
	env.okBuild = true
	api.spawn(function() load(source.settingsFinish, env) end)
	api.drain()
	check(mounts == 1 and selected == "Other", "settings mounted repeatedly or lost user selection")
	check(finalized and not env.NAStuff.SettingsBuildRunning and not env.NAgui.SettingsBuildState.building and env.NAStuff.SettingsBuildReady, "final mount left settings in a building state")
end)

test("effect enforcement handles new objects and camera changes without frame scans", function()
	local env = environment()
	local world, lighting = instance("Workspace"), instance("Lighting")
	lighting.FogStart, lighting.FogEnd = 100, 1000
	local camera = instance("Camera", world); world.CurrentCamera = camera
	local effect = instance("BloomEffect", lighting); effect.Enabled = true
	local cameraEffect = instance("BloomEffect", camera); cameraEffect.Enabled = true
	local heartbeat = signal()
	env.Services = { Workspace = world; Lighting = lighting; RunService = { Heartbeat = heartbeat } }
	env.__lt = { cm = function(_, _, prop) return lighting:GetPropertyChangedSignal(prop) end }
	local commands, hooks, writes = {}, {}, 0
	env.cmd = { add = function(aliases, _, fn) commands[aliases[1]] = fn end }
	local st = { safeGet = function(obj, prop) return obj[prop] end; safeSet = function(obj, prop, value) obj[prop] = value; writes += 1 end }
	st.hook = function(name, fn) if not hooks[name] then hooks[name] = fn() end end
	env.NAmanage._ensureL = function() env._na_env._LState = st; return st end
	env.NAmanage.descSub = function(root, spec) return root.DescendantAdded:Connect(spec.added) end
	env.NAmanage.descAdd = function(root, fn) return root.DescendantAdded:Connect(fn) end
	load(source.lighting, env)
	commands.loopnoeffect()
	check(effect.Enabled == false and cameraEffect.Enabled == false, "initial effects were not disabled")
	local scans = lighting.queries + camera.queries
	for i = 1, 120 do heartbeat:Fire(1 / 60) end
	check(lighting.queries + camera.queries == scans, "effect loop queried descendants each frame")
	local added = instance("BloomEffect", lighting); added.Enabled = true
	lighting.DescendantAdded:Fire(added)
	check(added.Enabled == false, "new lighting effect was missed")
	local nextCamera = instance("Camera", world)
	local nextEffect = instance("BloomEffect", nextCamera); nextEffect.Enabled = true
	world.CurrentCamera = nextCamera
	world:GetPropertyChangedSignal("CurrentCamera"):Fire()
	check(nextEffect.Enabled == false and nextCamera.queries == 1, "new camera was not initialized")
	effect.Enabled = true
	for i = 1, 12 do heartbeat:Fire(1 / 60) end
	check(effect.Enabled == false, "changed cached effect was not enforced")
	commands.unloopnoeffect()
	check(effect.Enabled and cameraEffect.Enabled and nextEffect.Enabled and added.Enabled, "effect baselines were not restored")
	commands.loopnofog()
	check(lighting.FogEnd == 786543 and lighting.FogStart == 0, "no-fog settings were not applied")
	local count = lighting.queries
	local atmosphere = instance("Atmosphere", lighting)
	atmosphere.Density, atmosphere.Haze, atmosphere.Glare = 0.5, 1, 2
	lighting.DescendantAdded:Fire(atmosphere)
	check(atmosphere.Density == 0 and atmosphere.Haze == 0, "new atmosphere missed")
	local previousWrites = writes
	for i = 1, 120 do heartbeat:Fire(1 / 60) end
	check(lighting.queries == count and writes == previousWrites, "no-fog loop rescanned or rewrote unchanged properties")
	commands.unloopnofog()
	check(lighting.FogEnd == 1000 and lighting.FogStart == 100 and atmosphere.Density == 0.5, "no-fog baseline was not restored")
end)

test("flashback connections are owned and delayed character binds stop after unload", function()
	local env, api = environment()
	load(source.prune..source.pruneAll, env)
	local active = {}
	env.NAmanage._runToken = active
	env.NAmanage.IsActiveRun = function(token) return token == active end
	local cleanups = {}
	env.NAmanage.RegisterUnloadCleanup = function(name, fn) cleanups[name] = fn end
	env.NAmanage.startWatcher = function() end
	env.NAmanage.ConnectHumanoidDeath = function(hum, fn) return hum.Died:Connect(fn) end
	env.SpawnCall = api.spawn
	local world = instance("Workspace")
	local char = instance("Model", world)
	local hum = instance("Humanoid", char)
	hum.Health, hum.HealthChanged, hum.Died = 100, signal(), signal()
	env.LocalPlayer = { Character = char; CharacterAdded = signal(); CharacterRemoving = signal() }
	env.Services = { RunService = { Heartbeat = signal() } }
	load(source.flashback, env)
	check(#env.NAStuff.conns.flashback_character == 3, "flashback connections were not tracked")
	cleanups.flashback_character()
	check(env.NAStuff.conns.flashback_character == nil, "flashback cleanup retained connections")
	local nextChar = instance("Model", world)
	local nextHum = instance("Humanoid")
	nextHum.Health, nextHum.HealthChanged, nextHum.Died = 100, signal(), signal()
	function nextChar:WaitForChild() api.wait(0.1); return nextHum end
	api.spawn(function() env.LocalPlayer.CharacterAdded:Fire(nextChar) end)
	active = {}
	api.drain()
	check(env.NAStuff.conns.flashback_character == nil, "character bind created connections after unload")
end)

test("cleanup helpers preserve the designated unload thread", function()
	local env, api = environment()
	load(source.cleanup, env)
	local owner = api.spawn(function() api.wait(100) end)
	env.NAmanage._runtimeState = { unloadThread = owner }
	local summary = { connections = 0; threads = 0 }
	api.defer(function() env.NAmanage.UnloadDisconnectTree({ owner = owner }, summary) end)
	api.step()
	check(coroutine.status(owner) == "suspended" and summary.threads == 0, "cleanup helper cancelled the unload caller")
	api.cancel(owner)
end)

test("full unload releases runtime resources, preserves external resources, and tolerates quick reload", function()
	local env, api = environment()
	local state, token = {}, {}
	local external = signal():Connect(function() end)
	local previous, caller = function() end, function() end
	local host = { __NamelessAdminRuntimeState = state; NACaller = caller; external = external }
	env._G, env._na_shared = env, {}
	env.shared = env._na_shared
	env.getgenv = function() return host end
	env._na_boot = { hostEnv = host; privateRegistry = host; privateRoot = {}; runtimeEnv = env; splitConfig = { state = state } }
	env._na_boot.privateRoot.testing = env._na_env
	env.NACaller, env.__NARootNACaller, env.__NARootPreviousNACaller = caller, caller, previous
	env.NAmanage._runToken = token
	env.NAmanage._runtimeState = { spawnActive = {}; waitingThreads = {} }
	local owned = signal():Connect(function() end)
	local extra = signal():Connect(function() end)
	env.NAmanage.nested = { owned = owned; external = host }
	env.otherConnection = extra
	local bridgeThread = api.spawn(function() api.wait(100) end)
	env.borrowedBridge = { connection = external; thread = bridgeThread }
	local thread = api.spawn(function() api.wait(100) end)
	env.NAmanage._runtimeState.spawnActive[thread] = true
	local summary
	load(source.prune..source.pruneAll..source.cleanup..source.unload, env)
	for _, name in { "UnloadLegacySharedStates", "UnloadRuntimeFlags", "UnloadLegacySignalConnections", "UnloadLegacyEditorConnections", "RunUnloadCleanups" } do env.NAmanage[name] = function() end end
	local sweeps = 0
	env.NAmanage.RemovePlexityGradients = function() sweeps += 1 end
	api.spawn(function() local ok; ok, summary = env.NAmanage.Unload(); check(ok, "full unload failed") end)
	check(not owned.Connected and not extra.Connected and external.Connected and coroutine.status(bridgeThread) == "suspended", "unload leaked runtime connections or touched borrowed resources")
	check(host.__NamelessAdminRuntimeState == nil and host.NACaller == previous and coroutine.status(thread) == "dead", "unload retained runtime state, caller, or task")
	local replacement = {}
	local newCaller = function() end
	host.__NamelessAdminRuntimeState, host.NA_LOADED, host.NACaller = replacement, true, newCaller
	local atReload = sweeps
	api.drain()
	check(host.__NamelessAdminRuntimeState == replacement and host.NA_LOADED == true and host.NACaller == newCaller, "delayed old cleanup erased new runtime")
	check(sweeps == atReload and summary.connections >= 2, "old gradient cleanup continued after reload")
end)

test("timed-out and skipped workers are cancelled and release task tracking", function()
	for _, mode in { "timeout", "noSkip", "skip" } do
		local env, api = environment()
		local token = {}
		env.NAmanage._runToken = token
		env._na_env._NARunToken = token
		env.NAmanage._runtimeState = { spawnActive = {}; waitingThreads = {} }
		env._naRawTaskSpawn, env._naRawTaskDefer = api.spawn, api.defer
		env._naRawTaskDelay, env._naRawTaskWait = api.delay, api.wait
		env.__NARootReportError = error
		env.NAAssetsLoading = { getSkip = function() return mode == "skip" end }
		env.Format = string.format
		load(source.tasks..source.timeout, env)
		local result, late = nil, false
		env.Spawn(function()
			local run = mode == "noSkip" and env.NAAssetsLoading.runWithTimeoutNoSkip or env.NAAssetsLoading.runWithTimeout
			result = table.pack(run(0.25, function() env.Wait(10); late = true end))
		end)
		api.drain()
		check(not result[1] and result[2] == nil and not late and api.clock() < 1, "expired worker continued")
		check(next(env.NAmanage._runtimeState.spawnActive) == nil and next(env.NAmanage._runtimeState.waitingThreads) == nil, "cancelled worker remained tracked")
		local success
		env.NAAssetsLoading.getSkip = function() return false end
		env.Spawn(function() success = table.pack(env.NAAssetsLoading.runWithTimeout(0.25, function() return false, nil, 7 end)) end)
		api.drain()
		check(success.n == 4 and success[1] and success[2] == false and success[3] == nil and success[4] == 7, "successful callback return values changed")
	end
end)

test("post-load instance budgets remain active until background startup settles", function()
	local env, api = environment()
	env.NAStuff.StartupPerformance = { finished = false }
	env.NAStuff._loadingFinalizedOnce = true
	load(source.instanceBudget, env)
	check(env.NAmanage.IsStartupBuilding(), "startup naming stopped before background loaders")
	api.spawn(function() for i = 1, 40 do env.NAmanage.StartupInstanceBudgetStep() end end)
	api.drain()
	check(api.yields() == 2, "background instances were not budgeted after loading screen closed")
	local yields = api.yields()
	env.NAStuff.StartupPerformance.finished = true
	api.spawn(function() for i = 1, 40 do env.NAmanage.StartupInstanceBudgetStep() end end)
	api.drain()
	check(api.yields() == yields and not env.NAmanage.IsStartupBuilding(), "startup budget stayed active after completion")
end)

test("startup frame monitoring includes queued work after settings finish", function()
	local env, api = environment()
	env.NAStuff.StartupPerformance = { finished = false }
	env.NAmanage._loaderQueuePumping = true
	env.NAStuff.CommandBuildWorkerQueued = true
	local finishes, at = 0, nil
	env.NAmanage.FinishStartupPerformance = function() finishes += 1; at = api.clock(); env.NAStuff.StartupPerformance.finished = true end
	load(source.finishIdle, env)
	env.NAmanage.FinishStartupPerformanceWhenIdle("ready")
	env.NAmanage.FinishStartupPerformanceWhenIdle("ready")
	api.delay(0.2, function() env.NAmanage._loaderQueuePumping = false end)
	api.delay(0.3, function() env.NAStuff.CommandBuildWorkerQueued = false end)
	api.drain()
	check(finishes == 1 and at >= 0.55, "frame monitoring ended before background work or finalized twice")
end)

test("plugin maker rebinding and drag completion release input connections", function()
	local env = environment()
	load(source.prune..source.pruneAll..source.pluginDrag, env)
	local began, moved = signal(), signal()
	env.Enum = { UserInputType = { MouseButton1 = 1; Touch = 2; MouseMovement = 3 }; UserInputState = { End = 4 } }
	env.Services = { UserInputService = { InputChanged = moved } }
	local pm = { Frame = { Position = {} }; Topbar = { InputBegan = began } }
	env.NAStuff.PluginMaker = pm
	env.NAmanage.PluginMaker_BindDrag()
	local old = env.NAStuff.conns.plugin_maker_drag_move[1]
	env.NAmanage.PluginMaker_BindDrag()
	check(not old.Connected and #env.NAStuff.conns.plugin_maker_drag_move == 1, "plugin maker retained old service connection")
	local first = { UserInputType = 1; Position = {}; Changed = signal() }
	local second = { UserInputType = 1; Position = {}; Changed = signal() }
	began:Fire(first); began:Fire(second)
	first.UserInputState = 4; first.Changed:Fire()
	check(pm.dragging, "old input ended the new drag")
	second.UserInputState = 4; second.Changed:Fire()
	check(not pm.dragging and env.NAStuff.conns.plugin_maker_drag_end == nil, "ended drag retained input connection")
end)

local function manifest(version, stamps, loaderVersion)
	local lines = { 'return { count = 3; version = "'..version..'"; loader_version = "'..(loaderVersion or "fixture")..'"; parts = {' }
	for i = 1, 3 do lines[#lines + 1] = '["part-'..string.format("%03d", i)..'.lua"] = "'..stamps[i]..'";' end
	lines[#lines + 1] = '} }'
	return table.concat(lines, "\n")
end
local function loaderFixture(options)
	options = options or {}
	local env, api = environment()
	local files, remote, reads, requests, writes = {}, {}, {}, {}, {}
	local stamps = { string.rep("a", 40), string.rep("b", 40), string.rep("c", 40) }
	local oldStamps = table.clone(stamps)
	oldStamps[2] = string.rep("d", 40)
	local root = "NA-split/common/"
	local host = setmetatable({}, { __index = getfenv() })
	host.loadstring = loadstring
	host.setfenv = setfenv
	host.task = api
	host.warn = function() end
	host.getgenv = function() return host end
	host.game = { PlaceId = 1; JobId = ""; HttpGet = function() error("offline") end; }
	host.os = env.os
	host.typeof = env.typeof
	host.stats = { ran = {}; aborted = 0; cancelled = 0; disconnected = 0; protectorDestroyed = 0; }
	host.request = function(req)
		local name = req.Url:match("/([^/]+)%%?[^/]*$") or req.Url:match("/([^/]+)$")
		name = name and name:match("^[^?]+")
		requests[name] = (requests[name] or 0) + 1
		local body = remote[name]
		return { StatusCode = body and 200 or 404; Body = body or "" }
	end
	host.isfile = function(path) return files[path] ~= nil end
	host.readfile = function(path)
		reads[path] = (reads[path] or 0) + 1
		assert(files[path], "missing "..path)
		return files[path]
	end
	host.writefile = function(path, data)
		writes[path] = (writes[path] or 0) + 1
		if options.failWrite and path:find(".parts/", 1, true) and path:find(stamps[2], 1, true) then error("write failure") end
		files[path] = data
	end
	host.makefolder = function() end
	host.listfiles = function(path)
		local list = {}
		for name in files do if name:sub(1, #path + 1) == path.."/" then list[#list + 1] = name end end
		return list
	end
	host.delfile = function(path) files[path] = nil end
	local first = [[
_na_boot = { runtimeEnv = setmetatable({}, { __index = __NARootHost }); privateRoot = {}; splitConfig = __NA_SPLIT_CONFIG; }
_na_boot.runtimeEnv._na_boot = _na_boot
_na_boot.runtimeEnv._na_env = {}
local protector = { destroy = function() stats.protectorDestroyed += 1 end }
_na_boot.runtimeEnv.__NAUIProtector = protector
_na_boot.privateRoot.uiProtector = protector
_na_boot.privateRoot.testing = _na_boot.runtimeEnv._na_env
stats.root = _na_boot.privateRoot
stats.protector = protector
NAmanage = { _runtimeState = { spawnActive = {}; waitingThreads = {} }; }
NAStuff = { conns = {} }
if not fixtureEarlyFailure then
NAmanage.Unload = function()
	stats.aborted += 1
	NAmanage._runtimeState.unloading = true
	for thread in NAmanage._runtimeState.spawnActive do task.cancel(thread) end
	for _, conn in NAStuff.conns do conn:Disconnect() end
end
end
local conn = { _kind = "RBXScriptConnection"; Disconnect = function() stats.disconnected += 1 end; }
NAStuff.conns[1] = conn
local thread = task.spawn(function() task.wait(5); stats.late = true end)
NAmanage._runtimeState.spawnActive[thread] = true
stats.ran[#stats.ran + 1] = 1
]]
	local sources = { first, options.failRun and 'error("fixture runtime failure")' or 'stats.ran[#stats.ran + 1] = 2', options.failCompile and 'local =' or 'stats.ran[#stats.ran + 1] = 3' }
	if options.replaceProtector then
		sources[2] = '_na_boot.privateRoot.testing = {}; _na_boot.privateRoot.uiProtector = { ready = true }; error("replacement fixture")'
	elseif options.shareProtector then
		sources[2] = '_na_boot.privateRoot.testing = {}; error("shared fixture")'
	end
	host.fixtureEarlyFailure = options.earlyFailure
	remote["manifest.lua"] = manifest("new", stamps)
	for i = 1, 3 do remote[string.format("part-%03d.lua", i)] = sources[i] end
	if options.localMode then
		local changed = options.localMode == "changed"
		files[root.."manifest.lua"] = manifest(changed and "old" or "new", changed and oldStamps or stamps)
		for i = 1, 3 do
			if not (options.missingPart and i == 2) then files[root..string.format("part-%03d.lua", i)] = changed and i == 2 and 'error("stale chunk executed")' or sources[i] end
		end
	end
	if options.offline then table.clear(remote) end
	local function run()
		local fn = assert(loadstring(source.loader))
		setfenv(fn, host)
		api.spawn(fn)
	end
	return { host = host; api = api; files = files; reads = reads; requests = requests; writes = writes; remote = remote; stamps = stamps; root = root; run = run; }
end

test("cold, warm, offline, changed, and incomplete split loads", function()
	for _, options in { {}, { localMode = "warm" }, { localMode = "warm"; offline = true }, { localMode = "changed" }, { localMode = "warm"; missingPart = true } } do
		local fixture = loaderFixture(options)
		fixture.run(); fixture.api.drain()
		check(table.concat(fixture.host.stats.ran, ",") == "1,2,3", "split execution order changed")
		check(fixture.host.__NamelessAdminRuntimeState.loaded == true and fixture.api.yields() >= 3, "loader did not mark ready or yield")
		if options.localMode == "warm" and not options.missingPart then
			for i = 1, 3 do
				local name = string.format("part-%03d.lua", i)
				check((fixture.requests[name] or 0) == 0 and fixture.reads[fixture.root..name] == 1, "warm chunks were downloaded or read twice")
			end
		elseif options.localMode == "changed" then
			check((fixture.requests["part-001.lua"] or 0) == 0 and fixture.requests["part-002.lua"] == 1 and (fixture.requests["part-003.lua"] or 0) == 0, "delta update downloaded unchanged chunks")
		end
	end
end)

test("offline root fallback and content-addressed warm caches", function()
	local fixture = loaderFixture({ localMode = "warm"; missingPart = true; offline = true })
	local fallback = "Nameless-Admin/NA-split/common/"
	fixture.files[fallback.."manifest.lua"] = fixture.files[fixture.root.."manifest.lua"]
	fixture.files[fallback.."part-001.lua"] = fixture.files[fixture.root.."part-001.lua"]
	fixture.files[fallback.."part-002.lua"] = 'stats.ran[#stats.ran + 1] = 2'
	fixture.files[fallback.."part-003.lua"] = fixture.files[fixture.root.."part-003.lua"]
	fixture.run(); fixture.api.drain()
	check(fixture.host.__NamelessAdminRuntimeState.loaded and #fixture.host.stats.ran == 3, "complete fallback root was ignored offline")
	local cold = loaderFixture()
	cold.run(); cold.api.drain()
	cold.host.__NamelessAdminRuntimeState = nil
	table.clear(cold.requests); table.clear(cold.reads); table.clear(cold.host.stats.ran)
	cold.run(); cold.api.drain()
	check(cold.host.__NamelessAdminRuntimeState.loaded, "content cache could not be loaded")
	for i = 1, 3 do
		local name = string.format("part-%03d.lua", i)
		check((cold.requests[name] or 0) == 0 and cold.reads[cold.root..".parts/"..cold.stamps[i]..".lua"] == 1, "content cache redownloaded or reread a chunk")
	end
end)

test("filesystem lock failures release ownership without replacing NACaller", function()
	local fixture = loaderFixture()
	fixture.host.game.JobId = "lock-fixture"
	local checksAtPath, created, removed = 0, false, false
	fixture.host.isfolder = function(path)
		if path:find("lock-", 1, true) then
			checksAtPath += 1
			if checksAtPath == 2 then error("filesystem check failure") end
		end
		return false
	end
	fixture.host.makefolder = function(path) if path:find("lock-", 1, true) then created = true end end
	fixture.host.delfolder = function() removed = true end
	local caller = function() end
	fixture.host.NACaller = caller
	fixture.run(); fixture.api.drain()
	check(created and removed and fixture.host.NACaller == caller, "lock failure retained folder or changed caller")
	check(fixture.host.__NamelessAdminRuntimeState == nil and fixture.host.__NA_SPLIT_LOADING == nil, "lock failure retained load state")
end)

test("false legacy flags do not prevent a fresh load", function()
	local fixture = loaderFixture({ localMode = "warm" })
	fixture.host.NA_LOADED, fixture.host.ltseverydayyou_NA, fixture.host.__NA_SPLIT_LOADING = false, false, false
	fixture.run(); fixture.api.drain()
	check(fixture.host.__NamelessAdminRuntimeState and fixture.host.__NamelessAdminRuntimeState.loaded and #fixture.host.stats.ran == 3, "false legacy flags blocked initialization")
end)

test("duplicate load preserves NACaller and does not restart", function()
	local fixture = loaderFixture({ localMode = "warm" })
	fixture.run()
	local caller = fixture.host.NACaller
	fixture.run()
	check(fixture.host.NACaller == caller and #fixture.host.stats.ran == 1, "loading guard changed active caller")
	fixture.api.drain()
	fixture.run()
	check(#fixture.host.stats.ran == 3 and fixture.host.NACaller == caller, "loaded guard was ignored")
end)

test("failed cache writes keep the previous build coherent", function()
	local fixture = loaderFixture({ localMode = "changed"; failWrite = true })
	local previous = fixture.files[fixture.root.."manifest.lua"]
	fixture.run(); fixture.api.drain()
	check(fixture.files[fixture.root.."manifest.lua"] == previous, "manifest published after cache failure")
	check(fixture.files[fixture.root.."part-002.lua"] == 'error("stale chunk executed")', "old build was overwritten before cache commit")
	check(fixture.host.__NamelessAdminRuntimeState.loaded, "cache failure prevented successful runtime")
end)

test("failed chunks clean partial runtimes and allow retries", function()
	for _, options in { { failCompile = true }, { failRun = true }, { failRun = true; earlyFailure = true }, { earlyFailure = true; replaceProtector = true }, { earlyFailure = true; shareProtector = true } } do
		local fixture = loaderFixture(options)
		fixture.run(); fixture.api.drain()
		check(fixture.host.__NamelessAdminRuntimeState == nil and fixture.host.__NA_SPLIT_LOADING == nil, "failed load kept its lock")
		check(fixture.host.stats.disconnected == 1 and not fixture.host.stats.late, "partial runtime leaked a connection or task")
		if not options.earlyFailure then check(fixture.host.stats.aborted == 1, "full runtime cleanup was skipped") end
		if options.earlyFailure then
			local stats = fixture.host.stats
			check(stats.protectorDestroyed == (options.shareProtector and 0 or 1), "protector ownership cleanup failed")
			if options.shareProtector then
				check(stats.root.uiProtector == stats.protector, "shared protector was invalidated")
			elseif options.replaceProtector then
				check(stats.root.uiProtector.ready == true, "replacement protector was invalidated")
			else
				check(stats.root.uiProtector == nil and stats.root.testing == nil, "destroyed protector was retained for retry")
			end
		end
		fixture.remote["part-002.lua"] = 'stats.ran[#stats.ran + 1] = 2'
		fixture.remote["part-003.lua"] = 'stats.ran[#stats.ran + 1] = 3'
		fixture.run(); fixture.api.drain()
		check(fixture.host.__NamelessAdminRuntimeState and fixture.host.__NamelessAdminRuntimeState.loaded, "failed load could not be retried")
	end
end)

test("unload cancels remaining split initialization", function()
	local fixture = loaderFixture({ localMode = "warm" })
	fixture.run()
	fixture.host.__NamelessAdminRuntimeState = nil
	fixture.api.drain()
	check(#fixture.host.stats.ran == 1 and fixture.host.stats.aborted == 1 and not fixture.host.stats.late, "loader continued after unload")
end)

test("executor data is lazy, complete, and reused", function()
	local env = environment()
	load(source.lsp..source.lspIndex, env)
	check(env.NAStuff.ExecutorLSPData == nil, "executor data was allocated during startup")
	collectgarbage("collect")
	local before = gcinfo()
	local data = env.NAmanage.ExecutorLSP_GetData()
	collectgarbage("collect")
	local allocated = gcinfo() - before
	check(allocated > 0, "executor allocation measurement was invalid")
	check(type(data) == "table" and next(data) ~= nil and env.NAmanage.ExecutorLSP_GetData() == data, "executor data missing or rebuilt")
	local old = environment()
	load(source.baselineLsp, old)
	local function compare(a, b)
		if type(a) ~= "table" then check(a == b, "executor data changed"); return end
		check(type(b) == "table", "executor subtree missing")
		for key, value in a do compare(value, b[key]) end
		for key in b do check(a[key] ~= nil, "executor gained unexpected data") end
	end
	compare(old.NAStuff.ExecutorLSPData, data)
	local index = env.NAmanage.ExecutorLSP_EnsureIndex()
	check(type(index) == "table" and env.NAmanage.ExecutorLSP_EnsureIndex() == index, "executor index not reused")
	print(string.format("MEASURE: executor table construction added %.1f KiB in this Luau CLI run", allocated))
end)

print(string.format("PASS: %d assertions", checks))
