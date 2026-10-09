const cases = {
	{ "Block Robux Purchases", "Order66", "Order66PurchaseBlock", "order66PurchaseBlock", "true", "false" },
	{ "Fast Particle Effects", "DebugRenderingSetDeterministic", "FastParticleEffects", "fastParticleEffects", "true", "false" },
	{ "Freeze Dynamic Lighting Updates", "DebugPauseVoxelizer", "PauseVoxelizerLighting", "pauseVoxelizerLighting", "true", "false" },
	{ "Enhanced Physics Replication", "S2PhysicsSenderRate", "EnhancedPhysicsReplication", "enhancedPhysicsReplication", "64", "15" },
}

const function setup(saved)
	const env = setmetatable({}, { __index = getfenv() })
	const state = { flags = {}, writes = {}, fail = {}, saved = {}, notes = {}, conns = {}, cleanups = {}, toggles = {}, sync = {} }
	const token = {}
	state.token = token
	env.NAStuff = table.clone(saved or {})
	env.NAgui = {}
	env.NAmanage = { _runToken = token }
	const function write(name, value)
		state.writes[name] = (state.writes[name] or 0) + 1
		if state.fail[name] then error("setter rejected "..name) end
		state.flags[name] = value
	end
	env.setfflag = write
	env.getfflag = function(name)
		if state.readFail then error("getter failed") end
		return state.flags[name]
	end
	env.game = { DefineFastFlag = function(_, name, value) write(name, value) end }
	env.NAmanage.IsActiveRun = function(run) return state.token == run end
	env.NAmanage.RegisterUnloadCleanup = function(key, fn) state.cleanups[key] = fn end
	env.NAmanage.RegisterToggleAutoSync = function(key, fn) state.sync[key] = fn end
	env.NAmanage.NASettingsSet = function(key, value) state.saved[key] = value end
	env.NAgui.addToggle = function(key, _, fn) state.toggles[key] = fn end
	env.DoNotif = function(msg) table.insert(state.notes, msg) end
	const hb = {}
	function hb:Connect(fn)
		const conn = { Connected = true, fn = fn }
		function conn:Disconnect() self.Connected = false end
		table.insert(state.conns, conn)
		return conn
	end
	state.beat = function(dt)
		for _, conn in table.clone(state.conns) do
			if conn.Connected then conn.fn(dt) end
		end
	end
	state.count = function()
		local count = 0
		for _, conn in state.conns do
			if conn.Connected then count += 1 end
		end
		return count
	end
	env.Services = { RunService = { Heartbeat = hb } }
	const buckets = {}
	env.NAlib = {
		disconnect = function(key)
			if buckets[key] then buckets[key]:Disconnect() end
			buckets[key] = nil
		end,
		isConnected = function(key) return buckets[key] ~= nil and buckets[key].Connected end,
		reconnect = function(key, conn)
			if buckets[key] then buckets[key]:Disconnect() end
			buckets[key] = conn
		end,
	}
	state.load = function()
		for _, name in { "helper", "purchases", "particles", "lighting", "screen", "physics" } do
			const fn = assert(loadstring(snippets[name], name))
			setfenv(fn, env)
			fn()
		end
	end
	state.load()
	return env, state
end

const function eq(actual, expected, msg)
	assert(actual == expected, msg..": expected "..tostring(expected)..", got "..tostring(actual))
end

for _, case in cases do
	const name, flag, field, key, onValue, offValue = unpack(case)
	const env, state = setup()
	eq(state.count(), 0, name.." starts idle")
	state.toggles[name](true)
	eq(state.flags[flag], onValue, name.." applies immediately")
	eq(state.saved[key], true, name.." saves enabled state")
	eq(state.sync[name](), true, name.." syncs enabled state")
	eq(state.count(), 1, name.." starts one connection")
	const writes = state.writes[flag]
	state.beat(0.2)
	eq(state.writes[flag], writes, name.." skips unchanged values")
	state.flags[flag] = offValue
	state.beat(0.02)
	eq(state.flags[flag], offValue, name.." throttles maintenance")
	state.beat(0.1)
	eq(state.flags[flag], onValue, name.." repairs an engine reset")
	for _ = 1, 4 do state.toggles[name](true) end
	eq(state.count(), 1, name.." does not duplicate connections")
	state.toggles[name](false)
	eq(state.flags[flag], offValue, name.." restores disabled value")
	eq(state.saved[key], false, name.." saves disabled state")
	eq(state.count(), 0, name.." disconnects when disabled")
	state.flags[flag] = "external"
	state.beat(1)
	eq(state.flags[flag], "external", name.." stops enforcing when disabled")
	for _ = 1, 3 do
		state.toggles[name](true)
		state.toggles[name](false)
	end
	eq(state.count(), 0, name.." cleans up after rapid toggles")
	const saved = { [field] = true }
	const loaded, resumed = setup(saved)
	resumed.flags[flag] = offValue
	resumed.beat(0.2)
	eq(resumed.flags[flag], onValue, name.." maintains saved startup settings")
	resumed.load()
	eq(resumed.count(), 1, name.." replaces old connections on reload")
	resumed.flags[flag] = offValue
	resumed.beat(0.2)
	eq(resumed.flags[flag], onValue, name.." maintains flags after reload")
end

do
	const env, state = setup()
	for _, case in cases do state.toggles[case[1]](true) end
	eq(state.count(), 1, "all feature toggles share one connection")
	state.toggles[cases[1][1]](false)
	state.flags.Order66 = "external"
	for i = 2, #cases do state.flags[cases[i][2]] = cases[i][6] end
	state.beat(0.2)
	eq(state.flags.Order66, "external", "disabled flags stay independent")
	for i = 2, #cases do eq(state.flags[cases[i][2]], cases[i][5], "remaining flags are repaired") end
	state.cleanups.standalone_fflags()
	eq(state.count(), 0, "unload disconnects maintenance")
	eq(next(env.NAmanage._standaloneFFlags), nil, "unload clears tracked flags")
	for i = 2, #cases do eq(state.flags[cases[i][2]], cases[i][6], "unload restores disabled values") end
end

do
	const env, state = setup()
	state.toggles[cases[1][1]](true)
	state.flags.Order66 = false
	state.fail.Order66 = true
	const notes = #state.notes
	state.beat(0.2)
	eq(#state.notes, notes, "background failures stay silent")
	state.fail.Order66 = nil
	state.beat(0.2)
	eq(state.flags.Order66, "true", "maintenance recovers from setter failures")
	state.fail.DebugPauseVoxelizer = true
	state.toggles[cases[3][1]](true)
	eq(env.NAStuff.PauseVoxelizerLighting, nil, "failed enable does not update toggle state")
	eq(env.NAmanage._standaloneFFlags.DebugPauseVoxelizer, nil, "failed enable is not maintained")
	state.fail.Order66 = true
	state.toggles[cases[1][1]](false)
	eq(env.NAStuff.Order66PurchaseBlock, true, "failed disable preserves existing enabled state")
	state.fail.Order66 = nil
	state.toggles[cases[1][1]](false)
	eq(state.count(), 0, "successful retry cleans up")
end

do
	const env, state = setup()
	env.setfflag = false
	state.toggles[cases[1][1]](true)
	state.flags.Order66 = false
	state.beat(0.2)
	eq(state.flags.Order66, "true", "DefineFastFlag fallback is maintained")
	env.getfflag = false
	state.flags.Order66 = false
	state.beat(0.2)
	eq(state.flags.Order66, "true", "maintenance works without getfflag")
	env.getfflag = function() error("getter failed") end
	state.flags.Order66 = false
	state.beat(0.2)
	eq(state.flags.Order66, "true", "maintenance tolerates getter failures")
	env.NAmanage.ClearStandaloneFFlags()
	env.game = {}
	state.toggles[cases[1][1]](true)
	eq(state.count(), 0, "unsupported flags never start a loop")
end

do
	const env, state = setup()
	state.flags.Order66 = "True"
	const writes = state.writes.Order66
	state.toggles[cases[1][1]](true)
	state.beat(0.2)
	eq(state.writes.Order66, writes, "boolean casing does not cause redundant writes")
	state.token = {}
	state.flags.Order66 = false
	state.beat(0.2)
	eq(state.flags.Order66, false, "stale runs stop writing")
	eq(state.count(), 0, "stale runs disconnect their own connection")
end

do
	const env, state = setup()
	state.toggles[cases[1][1]](true)
	env.NAStuff._unloading = true
	state.flags.Order66 = false
	state.beat(0.2)
	eq(state.flags.Order66, false, "unloading runs stop writing")
	eq(state.count(), 0, "unloading stops maintenance immediately")
end

do
	const env, state = setup()
	const gui = env.NAgui
	gui.ScreenGuiNoRenderToggle()
	eq(state.flags.DebugDontRenderScreenGui, "true", "screen rendering toggle enables")
	state.flags.DebugDontRenderScreenGui = false
	state.beat(0.2)
	eq(state.flags.DebugDontRenderScreenGui, "true", "screen rendering toggle repairs resets")
	state.flags.DebugDontRenderScreenGui = false
	gui.ScreenGuiNoRenderToggle()
	eq(env.NAStuff._DebugDontRenderScreenGui, false, "screen toggle uses requested state after an engine reset")
	eq(state.count(), 0, "screen rendering toggle disconnects when disabled")
	gui.ScreenGuiNoRenderToggle()
	state.cleanups.standalone_fflags()
	eq(state.flags.DebugDontRenderScreenGui, "false", "unload restores ScreenGui rendering")
end

print("FastFlag toggle regression checks passed")
