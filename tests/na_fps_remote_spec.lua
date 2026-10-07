local checks = 0
local function check(value, text)
	assert(value, text)
	checks += 1
end
local function load(text, env)
	local fn, err = loadstring(text)
	assert(fn, err)
	setfenv(fn, env)
	return fn()
end
local function scheduler()
	local jobs, now = {}, 0
	local api = {}
	local function resume(thread, ...)
		local ok, err = coroutine.resume(thread, ...)
		assert(ok, err)
	end
	function api.spawn(fn)
		local thread = coroutine.create(fn)
		resume(thread)
		return thread
	end
	function api.defer(fn)
		jobs[#jobs + 1] = { coroutine.create(fn), now }
	end
	function api.wait(delay)
		jobs[#jobs + 1] = { coroutine.running(), now + math.max(delay or 0, 1 / 60) }
		return coroutine.yield()
	end
	function api.step()
		if #jobs == 0 then return false end
		local at = 1
		for i = 2, #jobs do if jobs[i][2] < jobs[at][2] then at = i end end
		local job = table.remove(jobs, at)
		now = math.max(now, job[2])
		resume(job[1])
		return true
	end
	function api.drain()
		local count = 0
		while api.step() do count += 1; assert(count < 50000, "jobs did not settle") end
	end
	function api.pending() return #jobs end
	function api.clock() return now end
	return api
end

local function engine()
	local e = { hooks = {}; meta = {}; objects = {}; reads = 0; writes = 0; queries = 0; calls = 0; getcons = 0; installs = 0 }
	local methods, signalFns = {}, {}
	function signalFns.Connect(sig, fn)
		local conn = { Enabled = true; Connected = true; LuaConnection = true; ForeignState = false; Function = fn; disables = 0; enables = 0 }
		function conn:Disable() self.Enabled = false; self.disables += 1 end
		function conn:Enable() if self.Connected then self.Enabled = true; self.enables += 1 end end
		function conn:Disconnect() self.Enabled = false; self.Connected = false end
		sig.items[#sig.items + 1] = conn
		return conn
	end
	function signalFns.Once(sig, fn)
		local conn = signalFns.Connect(sig, fn)
		conn.once = true
		return conn
	end
	function signalFns.Wait() return "waited" end
	local function signal()
		local sig = { items = {}; _kind = "RBXScriptSignal" }
		function sig:Fire(...)
			for _, conn in table.clone(self.items) do
				if conn.Connected and conn.Enabled then
					conn.Function(...)
					if conn.once then conn:Disconnect() end
				end
			end
		end
		return setmetatable(sig, { __index = function(_, key)
			local fn = signalFns[key]
			return e.hooks[fn] or fn
		end })
	end
	function methods.IsA(obj, kind)
		local c = obj._data.ClassName
		return c == kind or kind == "Instance"
			or (kind == "BasePart" and (c == "Part" or c == "MeshPart" or c == "PartOperation"))
			or (kind == "Light" and (c == "PointLight" or c == "SpotLight" or c == "SurfaceLight"))
			or (kind == "PostEffect" and c == "BloomEffect")
			or (kind == "Decal" and c == "Texture")
	end
	function methods.IsDescendantOf(obj, root)
		local p = obj.Parent
		while p do if p == root then return true end; p = p.Parent end
		return false
	end
	function methods.GetChildren(obj) return table.clone(obj._data.kids) end
	function methods.GetFullName(obj)
		local names, p = {}, obj
		while p and p ~= e.game do table.insert(names, 1, p.Name); p = p.Parent end
		return table.concat(names, ".")
	end
	function methods.FindFirstChildOfClass(obj, kind)
		for _, c in obj._data.kids do if c.ClassName == kind then return c end end
	end
	function methods.GetPropertyChangedSignal(obj, key)
		if not obj._data.props[key] then obj._data.props[key] = signal() end
		return obj._data.props[key]
	end
	function methods.QueryDescendants(obj, selector)
		e.queries += 1
		if obj._data.badQuery then error("denied") end
		local wanted, list = {}, {}
		for name in selector:gmatch("[%w_]+") do wanted[#wanted + 1] = name end
		local function walk(node)
			for _, c in node._data.kids do
				for _, name in wanted do if c:IsA(name) then list[#list + 1] = c; break end end
				walk(c)
			end
		end
		walk(obj)
		return list
	end
	function methods.Clear(obj) obj._data.clears = (obj._data.clears or 0) + 1 end
	function methods.GetPlayers(obj) return obj._data.players or {} end
	function methods.Destroy(obj)
		obj.Destroying:Fire()
		obj.Parent = nil
		obj._data.dead = true
	end
	local function send() e.calls += 1; return "sent" end
	local function unreliable() e.calls += 1; return "unreliable" end
	local function invoke() e.calls += 1; return "invoked" end
	e.send, e.unreliable, e.invoke = send, unreliable, invoke
	local function rawWrite(obj, key, value)
		if obj._data.dead then error("destroyed") end
		e.writes += 1
		if key == "Parent" then
			local old = obj._data.Parent
			if old == value then return end
			local p = old
			while p do p.DescendantRemoving:Fire(obj); p = p.Parent end
			if old then local at = table.find(old._data.kids, obj); if at then table.remove(old._data.kids, at) end end
			obj._data.Parent = value
			if value then
				value._data.kids[#value._data.kids + 1] = obj
				p = value
				while p do p.DescendantAdded:Fire(obj); p = p.Parent end
			end
		else obj._data[key] = value end
		local sig = obj._data.props[key]
		if sig then sig:Fire() end
	end
	e.meta.__newindex = rawWrite
	function e.object(kind, name, parent, props)
		local data = table.clone(props or {})
		data.ClassName, data.Name = kind, name or kind
		data.kids, data.props = {}, {}
		data.DescendantAdded, data.DescendantRemoving, data.Destroying = signal(), signal(), signal()
		if kind == "Player" then data.CharacterAdded = signal() end
		if kind == "Players" then data.PlayerAdded, data.PlayerRemoving = signal(), signal() end
		if kind == "RemoteEvent" or kind == "UnreliableRemoteEvent" then data.OnClientEvent = signal() end
		local obj = setmetatable({ _data = data; _kind = "Instance" }, {
			__index = function(self, key)
				e.reads += 1
				if key == "OnClientInvoke" then error("write-only callback") end
				local fn = methods[key]
				if key == "FireServer" then fn = if kind == "UnreliableRemoteEvent" then unreliable else send end
				if key == "InvokeServer" then fn = invoke end
				if fn then return e.hooks[fn] or fn end
				return data[key]
			end,
			__newindex = function(self, key, value) return e.meta.__newindex(self, key, value) end,
		})
		e.objects[#e.objects + 1] = obj
		if parent then rawWrite(obj, "Parent", parent) end
		return obj
	end
	e.game = e.object("DataModel", "game")
	e.world = e.object("Workspace", "Workspace", e.game)
	e.light = e.object("Lighting", "Lighting", e.game, { GlobalShadows = true })
	e.players = e.object("Players", "Players", e.game)
	e.core = e.object("CoreGui", "CoreGui", e.game)
	e.storage = e.object("ReplicatedStorage", "ReplicatedStorage", e.game)
	e.localPlayer = e.object("Player", "Me", e.players)
	e.players._data.players = { e.localPlayer }
	e.char = e.object("Model", "Character", e.world)
	e.localPlayer.Character = e.char
	e.render = e.object("Settings", "Rendering", nil, { QualityLevel = "Automatic" })
	e.user = e.object("UserGameSettings", "User", nil, { SavedQualityLevel = "Automatic" })
	e.terrain = e.object("Terrain", "Terrain", e.world, { Decoration = true; WaterWaveSize = 1; WaterWaveSpeed = 5; WaterReflectance = 0.5 })
	e.meta.__namecall = function(obj, ...)
		return obj[e.method](obj, ...)
	end
	e.signal = signal
	return e
end

local function context()
	local e, jobs = engine(), scheduler()
	local commands, windows, messages = {}, {}, {}
	local stuff = { BlockedRemotes = {}; BlockedEventSaved = {}; BlockedInvokeSaved = {}; BlockedRemoteModes = {}; BlockedRemoteReturns = {}; BlockedSignals = {}; RemoteFakeReturn = true; FPSBoostOptions = {} }
	local env = setmetatable({ NAStuff = stuff; NAmanage = {}; _na_env = {}; _na_boot = { hostEnv = {} }; task = jobs; Defer = jobs.defer; Wait = jobs.wait; LocalPlayer = e.localPlayer }, { __index = getfenv() })
	env.game = e.game
	env.typeof = function(obj) return type(obj) == "table" and obj._kind or typeof(obj) end
	env.Services = { Workspace = e.world; Lighting = e.light; Players = e.players; CoreGui = e.core }
	env.cmd = { add = function(names, _, fn) for _, name in names do commands[name] = fn end end }
	env.Window = function(opts) windows[#windows + 1] = opts end
	env.DebugNotif = function(text) messages[#messages + 1] = text end
	env.Discover, env.Insert = table.find, table.insert
	env.settings = function() return { Rendering = e.render } end
	env.UserSettings = function() return { GetService = function() return e.user end } end
	env.Enum = { Material = { Plastic = "Plastic" }; RenderFidelity = { Performance = "Performance" }; QualityLevel = { Level01 = "Level01" }; SavedQualitySetting = { QualityLevel1 = "QualityLevel1" } }
	env.os = { clock = jobs.clock }
	env.Instance = { new = function(kind) return e.object(kind) end }
	env.newcclosure = function(fn) return fn end
	env.hookfunction = function(fn, repl)
		e.installs += 1
		local old = e.hooks[fn] or fn
		e.hooks[fn] = repl
		return old
	end
	env.hookmetamethod = function(_, name, repl)
		e.installs += 1
		local old = e.meta[name]
		e.meta[name] = repl
		return old
	end
	env.getnamecallmethod = function() return e.method end
	env.getconnections = function(sig)
		e.getcons += 1
		if sig.fail then error("getconnections failed") end
		return table.clone(sig.items)
	end
	env.getinstances = function() return table.clone(e.objects) end
	env.getcallbackvalue = function(obj, key) return obj._data[key] end
	function env.NAmanage.descSub(root, spec)
		local cons = {}
		local function pass(obj)
			if not spec.classNames then return true end
			for _, kind in spec.classNames do if obj:IsA(kind) then return true end end
			return false
		end
		if spec.added then cons[#cons + 1] = root.DescendantAdded:Connect(function(obj) if pass(obj) then spec.added(obj) end end) end
		if spec.removing then cons[#cons + 1] = root.DescendantRemoving:Connect(function(obj) if pass(obj) then spec.removing(obj) end end) end
		return { Disconnect = function() for _, conn in cons do conn:Disconnect() end end }
	end
	function env.NAmanage.ForEachDescendantYield(root, fn, opts)
		local function walk(obj)
			for _, child in obj:GetChildren() do
				fn(child)
				if not opts.skipChildren or not opts.skipChildren(child) then walk(child) end
			end
		end
		walk(root)
	end
	return env, e, jobs, commands, windows, messages
end

do
	local env, e, jobs, cmd, windows = context()
	load(source.remote, env)
	local rs = e.object("RemoteEvent", "Kill", e.storage)
	local ws = e.object("UnreliableRemoteEvent", "killPlayer", e.world)
	local backpack = e.object("Backpack", "Backpack", e.localPlayer)
	local tool = e.object("Tool", "Sword", backpack)
	local rf = e.object("RemoteFunction", "KILL", tool)
	local other = e.object("RemoteEvent", "kill", e.storage)
	local nested = e.object("RemoteEvent", "KillExtra", e.object("Folder", "Remotes", e.core))
	local detached = e.object("RemoteEvent", "KillHidden")
	local unrelated = e.object("RemoteEvent", "Heal", e.storage)
	local m = env.NAmanage
	jobs.spawn(function()
		local list = m.ScanRemotes(false)
		check(#list == 6, "all services and all three types are scanned")
		local matches = m.MatchRemotes(list, "KiLl")
		check(#matches == 5, "an exact name does not hide other prefix matches")
		check(#m.MatchRemotes(list, "game.Players.Me.Backpack.Sword.KILL") == 1, "full path resolves remote")
		check(#m.MatchRemotes(list, "#"..m.RemoteId(other)) == 1, "stable ID resolves duplicate")
		check(m.RemoteLabel(rs) ~= m.RemoteLabel(other), "same paths have different IDs")
		local again = m.ScanRemotes(true)
		check(#again == 7 and table.find(again, detached) ~= nil, "unparented remotes are opt-in")
		e.core._data.badQuery = true
		check(#m.ScanRemotes(false) == 6, "protected query failure falls back without losing other roots")
		cmd.blockremote("kill")
	end)
	jobs.drain()
	local pick = windows[#windows]
	check(pick.Title:find("5 matches", 1, true) ~= nil and #env.NAStuff.BlockedRemotes == 0, "ambiguous command blocks nothing before selection")
	check(#pick.Buttons == 8, "picker offers all matches, individual copies, refresh, and unparented discovery")
	local first = pick.Buttons[2]
	first.Callback()
	check(windows[#windows].Title == "Remote Blocking Method", "selecting a copy opens method choice")
	windows[#windows].Buttons[2].Callback()
	windows[#windows].Buttons[1].Callback()
	check(#env.NAStuff.BlockedRemotes == 1, "individual choice blocks only its instance")
	check(env.NAStuff.BlockedRemoteMethods[env.NAStuff.BlockedRemotes[1]] == "hooks", "chosen method is retained")
	m.RemoteBlockUnload()
	jobs.drain()
	print("PASS: remote discovery, names, paths, duplicate IDs, and explicit selection")
end

do
	local env, e, jobs = context()
	load(source.remote, env)
	local m, stuff = env.NAmanage, env.NAStuff
	local rem = e.object("RemoteEvent", "Kill", e.storage)
	local hits = 0
	local normal = rem.OnClientEvent:Connect(function() hits += 1 end)
	local once = rem.OnClientEvent:Once(function() hits += 10 end)
	local off = rem.OnClientEvent:Connect(function() hits += 100 end)
	off:Disable()
	check(m.BlockRemote(rem, "fakeok", "signals"), "signals-only block succeeds")
	check(e.installs == 0 and normal.Enabled == false and once.Enabled == false, "signals-only never installs hooks")
	check(rem:FireServer() == "sent", "signals-only allows outgoing calls")
	rem.OnClientEvent:Fire()
	check(hits == 0, "existing incoming callbacks are paused")
	local late = rem.OnClientEvent:Connect(function() hits += 1000 end)
	jobs.step()
	check(late.Enabled == false, "signals-only detects later connections")
	check(m.BlockRemote(rem, "error", "signals"), "reblocking updates mode without losing saved connections")
	check(m.UnblockRemote(rem), "unblock succeeds")
	jobs.drain()
	check(normal.Enabled and once.Enabled and late.Enabled and not off.Enabled, "only formerly active original connections are restored")
	check(#rem.OnClientEvent.items == 4, "unblocking creates no replacement connections")
	rem.OnClientEvent:Fire()
	rem.OnClientEvent:Fire()
	check(hits == 2012, "Once semantics and callback identities survive unblock")
	local count = e.getcons
	check(jobs.pending() == 0, "signal worker stops after final unblock")
	check(m.BlockRemote(rem, "fakeok", "hooks"), "hooks-only succeeds")
	check(e.getcons == count, "hooks-only does not call getconnections")
	check(normal.Enabled and late.Enabled, "hooks-only leaves preexisting subscriptions enabled")
	check(rem:FireServer() == nil, "direct FireServer is intercepted")
	e.method = "FireServer"
	check(e.meta.__namecall(rem) == nil, "namecall FireServer is intercepted")
	local new = rem.OnClientEvent:Connect(function() hits += 5000 end)
	check(not new.Connected, "hooks-only intercepts new subscriptions")
	check(m.BlockRemote(rem, "fakeok", "both"), "switching hooks to both adds signal blocking")
	check(not normal.Enabled, "both pauses existing connections")
	check(m.BlockRemote(rem, "fakeok", "hooks"), "switching back to hooks succeeds")
	check(normal.Enabled and late.Enabled, "switching to hooks restores original connections")
	m.RemoteBlockUnload()
	jobs.drain()
	check(rem:FireServer() == "sent", "unload removes remote rules")
	print("PASS: independent methods, late connections, reversible pauses, Once, and mode switching")
end

do
	local env, e, jobs = context()
	load(source.remote, env)
	local m, stuff = env.NAmanage, env.NAStuff
	local event = e.object("UnreliableRemoteEvent", "Kill", e.world)
	local fn = e.object("RemoteFunction", "KillFn", e.storage)
	local old = function() return "old" end
	fn.OnClientInvoke = old
	check(m.BlockRemote(fn, "fakeok", "signals") == false, "functions reject event-only method")
	check(e.installs == 0 and fn._data.OnClientInvoke == old, "rejected method has no side effects")
	check(m.BlockRemote(fn, "fakeok", "both"), "function callback is read with getcallbackvalue")
	check(fn:InvokeServer() == true and fn._data.OnClientInvoke() == true, "function hooks block both directions")
	stuff.BlockedRemoteReturns[fn] = false
	check(fn:InvokeServer() == false, "false fake returns are preserved")
	local latest = function() return "latest" end
	fn.OnClientInvoke = latest
	check(fn._data.OnClientInvoke ~= latest and fn._data.OnClientInvoke() == false, "later callback assignments stay blocked")
	check(m.UnblockRemote(fn), "function can be unblocked")
	check(fn._data.OnClientInvoke == latest, "unblock restores most recent callback")
	check(m.BlockRemote(event, "error", "hooks"), "unreliable event can be blocked")
	check(not pcall(function() event:FireServer() end), "error mode raises on direct calls")
	e.method = "FireServer"
	check(not pcall(function() e.meta.__namecall(event) end), "error mode raises through namecall")
	m.UnblockRemote(event)
	local conn = event.OnClientEvent:Connect(function() end)
	conn.Disable = function() error("unsupported") end
	check(m.BlockRemote(event, "fakeok", "signals") == false, "failed connection disable is reported")
	check(not stuff.BlockedRemoteSet[event] and conn.Enabled, "failed block leaves no active rule")
	event.OnClientEvent.fail = true
	check(m.BlockRemote(event, "fakeok", "signals") == false, "getconnections failure is reported")
	event.OnClientEvent.fail = false
	conn.Disable = function(self) self.Enabled = false end
	check(m.BlockRemote(event, "fakeok", "both"), "both works after errors recover")
	event.Parent = nil
	check(m.pruneBlockedRemoteState() == 1, "temporary unparenting preserves blocked state")
	event:Destroy()
	check(#stuff.BlockedRemotes == 0 and conn.Enabled, "destruction releases block resources")
	m.RemoteBlockUnload()
	jobs.drain()
	print("PASS: RemoteFunction callbacks, unreliable remotes, fake returns, failure rollback, and destruction")
end

do
	local env, e = context()
	env.getnamecallmethod = false
	env.hookmetamethod = false
	load(source.remote, env)
	local rem = e.object("RemoteEvent", "Kill", e.storage)
	check(env.NAmanage.BlockRemote(rem, "fakeok", "hooks"), "direct hooks work without namecall APIs")
	check(rem:FireServer() == nil, "direct fallback actually blocks calls")
	env.NAmanage.RemoteBlockUnload()
	check(rem:FireServer() == "sent", "direct fallback is transparent after unblock")
	print("PASS: executor capability fallback does not require every hook API")
end

do
	local env, e, jobs, cmd, windows = context()
	load(source.remote, env)
	local rem = e.object("RemoteEvent", "Kill", e.storage)
	local conn = rem.OnClientEvent:Connect(function() end)
	jobs.spawn(function() cmd.blockremote("kill") end)
	jobs.drain()
	windows[#windows].Buttons[1].Callback()
	local count = #windows
	windows[#windows].Buttons[3].Callback()
	check(#windows == count and not conn.Enabled and e.installs == 0, "signals picker needs no irrelevant return-mode dialog")
	env.NAmanage.RemoteBlockUnload()
	jobs.drain()
	print("PASS: signals picker applies only its chosen method")
end

do
	local env, e, jobs, cmd = context()
	local parts = {}
	for i = 1, 4096 do
		parts[i] = e.object("MeshPart", "Part"..i, e.world, { Material = "Wood"; MaterialVariant = "Custom"; Reflectance = 0.5; CastShadow = true; RenderFidelity = "Automatic"; TextureID = "texture" })
	end
	local own = e.object("Part", "Own", e.char, { Material = "Wood"; CastShadow = true })
	local surf = e.object("SurfaceAppearance", "Surface", parts[1])
	local trail = e.object("Trail", "Trail", parts[1], { Enabled = true })
	local beam = e.object("Beam", "Beam", parts[1], { Enabled = false })
	local light = e.object("PointLight", "Light", parts[1], { Enabled = true; Shadows = true })
	local post = e.object("BloomEffect", "Bloom", e.light, { Enabled = false })
	local boom = e.object("Explosion", "Explosion", e.world, { Visible = true; BlastPressure = 5000; BlastRadius = 20 })
	load(source.fps, env)
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	for _, part in parts do check(part.Material == "Plastic" and part.RenderFidelity == "Performance", "map rendering is simplified") end
	check(own.Material == "Wood" and own.CastShadow, "self is excluded")
	check(not trail.Enabled and not light.Enabled and not light.Shadows, "rendered effects are disabled")
	check(not post.Enabled and not beam.Enabled, "false original values are retained")
	check(surf.Parent == nil, "SurfaceAppearance is actually removed from rendering")
	check(not boom.Visible and boom.BlastPressure == 5000 and boom.BlastRadius == 20, "explosion option changes visuals only")
	check(e.render.QualityLevel == "Level01" and e.user.SavedQualityLevel == "QualityLevel1", "quality setting is applied")
	check(jobs.pending() == 0, "active booster has no steady-state polling task")
	local q = e.queries
	local late = e.object("MeshPart", "Late", e.world, { Material = "Wood"; MaterialVariant = ""; Reflectance = 0; CastShadow = true; RenderFidelity = "Automatic"; TextureID = "late" })
	local emitter = e.object("ParticleEmitter", "Particles", late, { Enabled = true; Rate = 500 })
	jobs.drain()
	check(late.Material == "Plastic" and not emitter.Enabled, "late objects use incremental processing")
	check(e.queries == q, "late objects trigger no subtree scan")
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	for _, part in parts do check(part.Material == "Wood" and part.RenderFidelity == "Automatic", "map rendering restores") end
	check(trail.Enabled and not beam.Enabled and not post.Enabled, "true and false effect states restore correctly")
	check(surf.Parent == parts[1] and light.Enabled and light.Shadows, "surface and light states restore")
	check(e.render.QualityLevel == "Automatic" and e.user.SavedQualityLevel == "Automatic", "quality restores")
	check(emitter.Enabled and boom.Visible and e.terrain.Decoration, "late effects and terrain restore")
	print("PASS: 4096 meshes, no periodic map work, late-object deduplication, and full restoration")
end

do
	local env, e, jobs, cmd = context()
	env.NAStuff.FPSBoostOptions = { stripParticles = false; particleRate = 100; keepEffectsOff = true; lowQuality = false; disableShadows = false }
	local emitter = e.object("ParticleEmitter", "Emitter", e.world, { Enabled = true; Rate = 500 })
	load(source.fps, env)
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	check(emitter.Enabled and emitter.Rate == 100, "rate limit keeps reduced particles visible")
	check(e.render.QualityLevel == "Automatic" and e.light.GlobalShadows, "independent quality and shadow toggles are respected")
	env.NAStuff.FPSBoostOptions.stripParticles = true
	jobs.spawn(env._na_env.NA_FPS_REFRESH)
	jobs.drain()
	check(not emitter.Enabled and emitter.Rate == 500, "live refresh reads new options and removes old rate limit")
	emitter.Enabled = true
	check(not emitter.Enabled, "optional property enforcement corrects actual changes")
	local writes = e.writes
	emitter:GetPropertyChangedSignal("Enabled"):Fire()
	check(e.writes == writes, "enforcement does not write unchanged properties")
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	check(emitter.Enabled and emitter.Rate == 500, "option changes still restore original states")
	jobs.spawn(cmd.fpsbooster)
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	check(not env._na_env.NA_FPS_ACTIVE and emitter.Enabled, "stop cancels queued initial work")
	env.NAStuff.FPSBoostOptions.liveUpdates = false
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	local late = e.object("ParticleEmitter", "Late", e.world, { Enabled = true; Rate = 25 })
	jobs.drain()
	check(late.Enabled, "new-object tracking is optional")
	env.NAStuff._unloading = true
	env._na_env.NA_FPS_UNHOOK()
	check(emitter.Enabled and jobs.pending() == 0, "unload restores without leaving worker tasks")
	print("PASS: useful option independence, particle limiting, live refresh, guarded signals, and cancellation")
end

do
	local env, e, jobs, cmd = context()
	for i = 1, 256 do e.object("Part", "Part"..i, e.world, { Material = "Wood"; MaterialVariant = "Custom"; CastShadow = true; Reflectance = 0.4 }) end
	load(source.fps, env)
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	jobs.spawn(cmd.fpsbooster)
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	check(env._na_env.NA_FPS_ACTIVE, "reenable waits for an in-progress restore")
	local visitor = e.object("Player", "Other", e.players)
	visitor.Character = e.object("Model", "Visitor", e.world)
	e.players.PlayerAdded:Fire(visitor)
	local conn = visitor.CharacterAdded.items[#visitor.CharacterAdded.items]
	e.players.PlayerRemoving:Fire(visitor)
	check(not conn.Connected, "departing players release character watchers")
	jobs.spawn(cmd.fpsbooster)
	jobs.drain()
	for _, obj in e.world:GetChildren() do
		if obj.ClassName == "Part" then check(obj.Material == "Wood", "rapid toggle restores each part") end
	end
	check(not env._na_env.NA_FPS_ACTIVE and jobs.pending() == 0, "rapid toggles settle cleanly")
	print("PASS: overlapping toggles and departing players release their work")
end

print("PASS: "..checks.." focused FPS/remote assertions")
