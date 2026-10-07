const run = cloneref(game:GetService("RunService"))
const world = cloneref(game:GetService("Workspace"))
local tag = "NAOffsetWalkSpec_"..tostring(math.floor(os.clock() * 1000000))
local folder = Instance.new("Folder")
folder.Name = tag
folder.Parent = world
local chars = {}
local links = {}
local char
local move = Vector3.zero
local checks = 0
local cases = 0
local speedRuns = 0
local helper
local TPWalk = false
local _na_env = {}
local NAStuff = {SafeSpeedMethod = true, NA_UNDERGROUND_BIND_NAME = tag.."UG"}
local NAmanage = {}
local NAlib = {}
local Services = {Workspace = world, RunService = run}
const LocalPlayer = cloneref(game:GetService("Players")).LocalPlayer
const realos = os
local tick = 0
const os = {clock = function() return tick or realos.clock() end}
local Wait = task.wait
local __lt = {cm = function(_, method, ...) return run[method](run, ...) end}
local function getChar() return char end
local function getHum(model)
	model = model or char
	return model and model:FindFirstChildOfClass("Humanoid")
end
local function getRoot(model)
	model = model or char
	return model and model:FindFirstChild("HumanoidRootPart")
end
local function DoNotif() end
local function makeChar(pos, speed)
	for _, old in chars do
		local root = getRoot(old)
		if root then root.CanCollide = false end
	end
	local model = Instance.new("Model")
	model.Name = "Fixture"..tostring(#chars + 1)
	local hum = Instance.new("Humanoid")
	hum.RequiresNeck = false
	hum.WalkSpeed = speed or 16
	hum.Parent = model
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Anchored = true
	root.CFrame = CFrame.new(pos)
	root.Parent = model
	model.PrimaryPart = root
	model.Parent = folder
	chars[#chars + 1] = model
	return model
end
local function check(ok, msg)
	checks += 1
	assert(ok, msg)
end
local function near(a, b, msg)
	check((a - b).Magnitude < 0.002, msg)
end
local function case(name, fn)
	fn()
	cases += 1
end
NAlib.disconnect = function(key)
	local link = links[key]
	if link then link:Disconnect() end
	links[key] = nil
end
NAlib.connect = function(key, link)
	NAlib.disconnect(key)
	links[key] = link
	return link
end
NAlib.reconnect = NAlib.connect
NAlib.isConnected = function(key)
	return links[key] and links[key].Connected == true
end
NAlib.isProperty = function(obj, key)
	local ok, val = pcall(function() return obj[key] end)
	return ok and val or nil
end
NAmanage.StopVelocityWalkSpeed = function()
	NAlib.disconnect("na_velocityws_apply")
	if helper then helper:Destroy() end
	helper = nil
end
NAmanage.RefreshVelocityWalkSpeed = function()
	speedRuns += 1
	if NAlib.isConnected("na_velocityws_apply") then return end
	NAlib.connect("na_velocityws_apply", run.PreSimulation:Connect(function()
		local root = getRoot()
		local speed = NAmanage.GetVelocityWalkSpeedValue()
		if not root or not speed then return end
		if not helper or helper.Parent ~= root then
			if helper then helper:Destroy() end
			helper = Instance.new("BodyVelocity")
			helper.Name = tag.."Driver"
			helper.P = 100000
			helper.MaxForce = Vector3.new(1e9, 0, 1e9)
			helper.Parent = root
		end
		helper.Velocity = move * speed
	end))
end
NAmanage.StopLegacyLoopWalkSpeed = function()
	NAlib.disconnect("loopws_apply")
	NAlib.disconnect("loopws_char")
end
NAmanage.ApplyWalkSpeed = function(val) getHum().WalkSpeed = val end
NAmanage.UG_fetchCharPieces = function() return char, getRoot(), getHum() end
NAmanage.UG_isLocalRoot = function(root) return root == getRoot() end
NAmanage.UG_getTransform = function(state) return state.UndergroundTransform or CFrame.new() end
NAmanage.UG_getActiveOffset = function(state) return state.UndergroundOffset or Vector3.zero end
NAmanage.UG_updateVisualizer = function() end
NAmanage.ovClr = function() end
char = makeChar(Vector3.new(5000, 5000, 5000), 16)
NAStuff.OffsetWalkState = {bindName = tag.."Walk"}
local injected = "__NA_OFFSETWALK_SOURCE__"
local function fresh(pos, speed)
	move = Vector3.zero
	if NAStuff.NAundergroundState and NAStuff.NAundergroundState.Underground then
		NAmanage.UG_disable(NAStuff.NAundergroundState)
	end
	NAmanage.StopOffsetWalk(true)
	char = makeChar(pos or Vector3.new(5000, 5000, 5000), speed or 16)
	if tick then tick = 0 end
	check(NAmanage.StartOffsetWalk(60), "start failed")
	return NAStuff.OffsetWalkState, getRoot(), getHum()
end
local function physics(state, cf, vel, dt)
	const root = getRoot()
	state.writing = true
	root.CFrame = cf
	root.AssemblyLinearVelocity = vel
	state.writing = false
	tick += dt or 0
end
local function frame(state, dt)
	NAmanage.OffsetWalkRender(state)
	const root = getRoot()
	physics(state, root.CFrame + move * state.speed * dt, move * state.speed + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0), dt)
	NAmanage.OffsetWalkStep(state)
	NAmanage.OffsetWalkStep(state)
	NAmanage.OffsetWalkRender(state)
end
local function enableOffset(state, root)
	local ug = {UndergroundOffset = Vector3.new(0, -3, 0), UndergroundTransform = CFrame.Angles(0, 0, math.pi), UndergroundOffsetActive = true}
	NAStuff.NAundergroundState = ug
	NAmanage.UG_enable(ug, root)
	return ug
end
local ok, err = xpcall(function()
	case("replication holds for 0.1 seconds and immediately refreezes", function()
		local state, root, hum = fresh()
		local start = root.Position
		move = Vector3.new(1, 0, 0)
		NAmanage.OffsetWalkRender(state)
		physics(state, root.CFrame + Vector3.new(1, 0, 0), Vector3.new(60, 0, 0), 1 / 60)
		NAmanage.OffsetWalkStep(state)
		near(root.Position, start, "replication moved before the hold expired")
		near(state.localCFrame.Position, start + Vector3.new(1, 0, 0), "local movement was lost")
		near(root.AssemblyLinearVelocity, Vector3.zero, "replicated velocity must be zero")
		check(state.holdDuration == 0.1 and state.interval == 0.1, "wrong hold interval")
		check(not NAlib.isConnected("na_offsetwalk_pre"), "per-frame simulation release remains")
		check(hum.WalkSpeed == 16, "safe speed changed the original WalkSpeed")
		check(NAmanage.GetVelocityWalkSpeedValue() == 60 and NAlib.isConnected("na_velocityws_apply"), "speed driver disabled")
		check(state.phase == "frozen", "character not frozen after simulation")
		NAmanage.OffsetWalkRender(state)
		near(root.AssemblyLinearVelocity, Vector3.new(60, 0, 0), "local speed not restored during release")
		near(root.Position, start + Vector3.new(1, 0, 0), "local movement was held")
		tick = 0.099
		NAmanage.OffsetWalkStep(state)
		near(root.Position, start, "replication released early")
		tick = 0.101
		NAmanage.OffsetWalkStep(state)
		near(root.Position, start + Vector3.new(1, 0, 0), "replication did not jump after 0.1 seconds")
		near(root.AssemblyLinearVelocity, Vector3.zero, "replication was not instantly refrozen")
	end)
	case("freeze and release sample physics without adding CFrame walking", function()
		local state, root = fresh()
		local start = root.CFrame
		move = Vector3.new(1, 0, 0)
		NAmanage.OffsetWalkRender(state)
		physics(state, start + Vector3.new(0.3, 0.2, -0.4), Vector3.new(18, 12, -24), 1 / 60)
		NAmanage.OffsetWalkStep(state)
		near(root.Position, start.Position, "held replication followed local physics")
		near(state.localCFrame.Position, (start + Vector3.new(0.3, 0.2, -0.4)).Position, "movement changed beyond the physics result")
		near(root.AssemblyLinearVelocity, Vector3.zero, "freeze did not clear velocity")
		NAmanage.OffsetWalkRender(state)
		near(root.AssemblyLinearVelocity, Vector3.new(18, 12, -24), "release did not restore the complete speed vector")
		NAmanage.OffsetWalkStep(state)
		near(root.AssemblyLinearVelocity, Vector3.zero, "character not immediately frozen again")
	end)
	case("Heartbeat and rendering never move twice", function()
		local state, root = fresh()
		move = Vector3.new(1, 0, 0)
		local start = root.Position
		frame(state, 1 / 60)
		for _ = 1, 5 do
			NAmanage.OffsetWalkStep(state)
			NAmanage.OffsetWalkRender(state)
		end
		near(root.Position, start + Vector3.new(1, 0, 0), "duplicate movement in callbacks")
	end)
	case("manual teleports reset the held position immediately", function()
		local state, root = fresh()
		tick = 0.06
		root.CFrame = CFrame.new(5300, 5000, 5000)
		NAmanage.OffsetWalkRender(state)
		near(state.serverCFrame.Position, Vector3.new(5300, 5000, 5000), "teleport did not move the held pose")
		check(state.lastAnchorUpdate == tick, "teleport did not restart the hold")
		physics(state, root.CFrame + Vector3.new(1, 0, 0), Vector3.new(60, 0, 0), 0.02)
		NAmanage.OffsetWalkStep(state)
		tick = 0.159
		NAmanage.OffsetWalkStep(state)
		near(root.Position, Vector3.new(5300, 5000, 5000), "teleport shortened the next hold")
		tick = 0.161
		NAmanage.OffsetWalkStep(state)
		near(root.Position, Vector3.new(5301, 5000, 5000), "movement did not resume after teleport")
	end)
	case("stopping during a hold keeps the local pose and velocity", function()
		local state, root = fresh()
		move = Vector3.new(1, 0, 0)
		frame(state, 0.04)
		const dest = state.localCFrame
		NAmanage.OffsetWalkStep(state)
		check(not NAmanage.OffsetWalkCFrameNear(root.CFrame, dest), "fixture never held the replicated pose")
		NAmanage.StopOffsetWalk(true)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, dest), "stop returned to the frozen pose")
		near(root.AssemblyLinearVelocity, Vector3.new(60, 0, 0), "stop lost local velocity")
	end)
	case("consistent speed at 30, 60, and 144 FPS", function()
		for _, fps in {30, 60, 144} do
			local state, root = fresh(Vector3.new(5100, 5000, 5000))
			local start = root.Position
			move = Vector3.new(1, 0, 0)
			local bursts = 0
			local last = state.lastAnchorUpdate
			for _ = 1, fps do
				frame(state, 1 / fps)
				if state.lastAnchorUpdate ~= last then
					check(state.lastAnchorUpdate - last >= 0.1 - 0.000001, "replication released early at "..fps.." FPS")
					last = state.lastAnchorUpdate
					bursts += 1
				end
			end
			check(math.abs(root.Position.X - start.X - 60) < 0.06, "frame-rate dependent speed: "..fps)
			check(bursts >= 7 and bursts <= 10, "replication did not use timed jumps at "..fps.." FPS")
		end
	end)
	case("direct CFrame teleports before render, simulation, and stop", function()
		for _, phase in {"render", "pre", "post", "stop"} do
			local state, root = fresh()
			local dest = CFrame.new(5000.02, 5000.01, 5000.03) * CFrame.Angles(0.2, 0.4, 0.1)
			root.CFrame = dest
			if phase == "render" then NAmanage.OffsetWalkRender(state)
			elseif phase == "pre" then NAmanage.OffsetWalkRender(state)
			elseif phase == "post" then NAmanage.OffsetWalkStep(state)
			else NAmanage.StopOffsetWalk(true) end
			near(root.Position, dest.Position, "short teleport lost before "..phase)
			check(NAmanage.OffsetWalkCFrameNear(root.CFrame, dest), "teleport orientation lost before "..phase)
		end
	end)
	case("rotation-only writes are preserved", function()
		local state, root = fresh()
		local dest = root.CFrame * CFrame.Angles(0, math.pi / 2, 0)
		root.CFrame = dest
		NAmanage.OffsetWalkRender(state)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, dest), "rotation reverted")
	end)
	case("direct speed still drives movement when safe speed is disabled", function()
		NAStuff.SafeSpeedMethod = false
		local state, root, hum = fresh()
		check(hum.WalkSpeed == 60, "direct WalkSpeed driver not restored")
		check(not NAlib.isConnected("na_velocityws_apply"), "safe driver remained active in direct mode")
		hum.WalkSpeed = 120
		NAmanage.OffsetWalkStep(state)
		check(hum.WalkSpeed == 60, "selected direct speed not maintained")
		NAmanage.StopOffsetWalk(true)
		check(hum.WalkSpeed == 16, "original WalkSpeed not restored")
		NAStuff.SafeSpeedMethod = true
	end)
	case("Model PivotTo supports short and long moves", function()
		for _, dist in {0.02, 100} do
			local state, root = fresh()
			local dest = char:GetPivot() + Vector3.new(dist, 1, 2)
			char:PivotTo(dest)
			local expected = root.CFrame
			NAmanage.OffsetWalkRender(state)
			check(NAmanage.OffsetWalkCFrameNear(root.CFrame, expected), "PivotTo reverted")
			frame(state, 1 / 60)
			check(NAmanage.OffsetWalkCFrameNear(root.CFrame, expected), "PivotTo reverted next frame")
		end
	end)
	case("movement resumes at the new destination", function()
		local state, root = fresh()
		root.CFrame = CFrame.new(5500, 5000, 5000)
		move = Vector3.new(1, 0, 0)
		frame(state, 1 / 60)
		near(root.Position, Vector3.new(5501, 5000, 5000), "old cached position used after teleport")
	end)
	case("offset transform does not accumulate", function()
		local state, root = fresh()
		local base = root.CFrame
		local ug = enableOffset(state, root)
		for _ = 1, 12 do
			NAmanage.OffsetWalkRender(state)
			NAmanage.OffsetWalkStep(state)
			local expected = (base * ug.UndergroundTransform) + ug.UndergroundOffset
			check(NAmanage.OffsetWalkCFrameNear(root.CFrame, expected), "replicated offset drifted")
			NAmanage.OffsetWalkRender(state)
			check(NAmanage.OffsetWalkCFrameNear(root.CFrame, base), "client received its replicated offset")
		end
	end)
	case("offset uses the held position while local movement continues", function()
		local state, root = fresh()
		const base = root.CFrame
		const ug = enableOffset(state, root)
		NAmanage.OffsetWalkRender(state)
		physics(state, base + Vector3.new(2, 0, 0), Vector3.new(60, 0, 0), 0.03)
		NAmanage.OffsetWalkStep(state)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, (base * ug.UndergroundTransform) + ug.UndergroundOffset), "offset moved before the hold expired")
		NAmanage.OffsetWalkRender(state)
		near(root.Position, base.Position + Vector3.new(2, 0, 0), "offset held local movement")
		tick = 0.101
		NAmanage.OffsetWalkStep(state)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, ((base + Vector3.new(2, 0, 0)) * ug.UndergroundTransform) + ug.UndergroundOffset), "offset jump lost its transform")
		NAmanage.UG_disable(ug)
		near(root.Position, base.Position + Vector3.new(2, 0, 0), "unoffset returned to the held pose")
	end)
	case("CFrame and PivotTo while offset is active", function()
		for _, pivot in {false, true} do
			local state, root = fresh()
			enableOffset(state, root)
			NAmanage.OffsetWalkStep(state)
			local dest = CFrame.new(5000.03, 5000.02, 5000.01) * CFrame.Angles(0.1, 0.2, 0.3)
			if pivot then char:PivotTo(dest) else root.CFrame = dest end
			local expected = root.CFrame
			NAmanage.OffsetWalkRender(state)
			check(NAmanage.OffsetWalkCFrameNear(root.CFrame, expected), "teleport lost with offset")
			frame(state, 1 / 60)
			check(NAmanage.OffsetWalkCFrameNear(root.CFrame, expected), "offset reapplied to client teleport")
		end
	end)
	case("unoffset preserves the client pose and immediate later teleports", function()
		local state, root = fresh()
		local base = root.CFrame
		local ug = enableOffset(state, root)
		NAmanage.OffsetWalkStep(state)
		NAmanage.UG_disable(ug)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, base), "unoffset kept the spoofed pose")
		root.CFrame = base + Vector3.new(0.02, 0, 0)
		local expected = root.CFrame
		frame(state, 1 / 60)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, expected), "unoffset grace period ignored a teleport")
	end)
	case("teleport immediately before unoffset", function()
		local state, root = fresh()
		local ug = enableOffset(state, root)
		NAmanage.OffsetWalkStep(state)
		root.CFrame = CFrame.new(5010, 5010, 5010)
		NAmanage.UG_disable(ug)
		near(root.Position, Vector3.new(5010, 5010, 5010), "unoffset discarded a pending teleport")
	end)
	case("the complete movement and jump velocity is restored locally", function()
		local state, root = fresh()
		NAmanage.OffsetWalkRender(state)
		physics(state, root.CFrame + Vector3.new(0, 0.7, 0), Vector3.new(80, 30, 60), 1 / 60)
		NAmanage.OffsetWalkStep(state)
		near(root.AssemblyLinearVelocity, Vector3.zero, "jump velocity leaked into replication")
		NAmanage.OffsetWalkRender(state)
		near(root.AssemblyLinearVelocity, Vector3.new(80, 30, 60), "local movement or jump velocity lost")
		near(root.Position, Vector3.new(5000, 5000.7, 5000), "vertical physics displacement lost")
	end)
	case("restart keeps the original WalkSpeed and replaces callbacks", function()
		local state, root, hum = fresh(nil, 23)
		local old = links.na_offsetwalk_post
		local dest = root.CFrame + Vector3.new(0.02, 0, 0)
		root.CFrame = dest
		check(NAmanage.StartOffsetWalk(90), "restart failed")
		check(not old.Connected, "old PostSimulation callback leaked")
		check(state.originalWalkSpeed == 23, "restart saved suppressed WalkSpeed")
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, dest), "restart lost pending teleport")
		NAmanage.StopOffsetWalk(true)
		check(hum.WalkSpeed == 23, "WalkSpeed not restored")
		check(next(links) == nil, "callbacks remained after stop")
	end)
	case("respawn rebinds the root and restores each humanoid independently", function()
		local state, oldRoot, oldHum = fresh(nil, 21)
		local old = links.na_offsetwalk_cframe
		char = makeChar(Vector3.new(6400, 5100, 5000), 27)
		NAmanage.OffsetWalkRender(state)
		check(not old.Connected, "old root CFrame connection leaked")
		check(oldHum.WalkSpeed == 21, "old humanoid speed remained zero")
		check(state.originalWalkSpeed == 27, "new humanoid inherited old restore speed")
		near(getRoot().Position, Vector3.new(6400, 5100, 5000), "new root inherited old cached pose")
		NAmanage.StopOffsetWalk(true)
		check(getHum().WalkSpeed == 27, "new humanoid restore failed")
	end)
	case("stopping before a respawn callback never restores the old root pose", function()
		local state = fresh(nil, 19)
		char = makeChar(Vector3.new(6600, 5100, 5000), 31)
		NAmanage.StopOffsetWalk(true)
		near(getRoot().Position, Vector3.new(6600, 5100, 5000), "stop teleported a new character")
		check(getHum().WalkSpeed == 31, "stop changed an unbound humanoid")
	end)
	case("respawning with offset active does not reuse the old client pose", function()
		local state, root = fresh()
		enableOffset(state, root)
		NAmanage.OffsetWalkStep(state)
		char = makeChar(Vector3.new(6700, 5100, 5000), 29)
		NAmanage.OffsetWalkRender(state)
		near(getRoot().Position, Vector3.new(6700, 5100, 5000), "offset respawn reused the old character position")
		NAmanage.UG_disable(NAStuff.NAundergroundState)
		NAmanage.StopOffsetWalk(true)
		check(getHum().WalkSpeed == 29, "offset respawn lost the new WalkSpeed")
	end)
	case("other speed settings keep the chosen offsetspeed driver", function()
		local state, root, hum = fresh()
		_na_env.NamelessSpeed = 80
		check(NAmanage.GetVelocityWalkSpeedValue() == 60, "offsetspeed not supplied to its speed driver")
		NAStuff.SafeSpeedMethod = false
		NAStuff.loopws = true
		_na_env.NamelessWs = 75
		NAmanage.StartLegacyLoopWalkSpeed(75)
		check(not NAlib.isConnected("loopws_apply"), "legacy walking restarted during offsetspeed")
		NAmanage.SyncSpeedMethodState()
		check(hum.WalkSpeed == 60, "direct speed toggle did not select offsetspeed")
		NAmanage.StopOffsetWalk(true)
		check(hum.WalkSpeed == 75, "saved direct speed not restored")
		NAmanage.StopLegacyLoopWalkSpeed()
		NAStuff.SafeSpeedMethod = true
		NAStuff.loopws = false
		_na_env.NamelessSpeed = nil
		_na_env.NamelessWs = nil
	end)
	case("unoffset immediately after respawn preserves the new root", function()
		local state, root = fresh()
		local ug = enableOffset(state, root)
		NAmanage.OffsetWalkStep(state)
		char = makeChar(Vector3.new(6750, 5100, 5000), 31)
		NAmanage.UG_disable(ug)
		near(getRoot().Position, Vector3.new(6750, 5100, 5000), "unoffset restored the previous character pose")
		NAmanage.StopOffsetWalk(true)
		check(getHum().WalkSpeed == 31, "unoffset lost the new humanoid speed")
	end)
	case("invalid speeds stop cleanly", function()
		local state = fresh()
		for _, val in {0, -1, math.huge, 0 / 0} do
			check(not NAmanage.StartOffsetWalk(val), "invalid speed accepted")
			check(next(links) == nil, "invalid-speed stop leaked callbacks")
		end
	end)
	case("safe-speed toggling keeps the saved speed configuration", function()
		local state, root, hum = fresh()
		NAStuff.SafeSpeedMethod = false
		NAStuff.loopws = true
		_na_env.NamelessWs = 72
		NAStuff.SafeSpeedMethod = true
		NAmanage.SyncSpeedMethodState()
		check(hum.WalkSpeed == state.originalWalkSpeed, "safe-speed toggle lost the original WalkSpeed")
		check(_na_env.NamelessSpeed == 72 and _na_env.NamelessWs == nil and not NAStuff.loopws, "saved loop speed not converted")
		NAmanage.StopOffsetWalk(true)
		check(NAmanage.GetVelocityWalkSpeedValue() == 72, "saved speed not available after stop")
		_na_env.NamelessSpeed = nil
		NAmanage.StopVelocityWalkSpeed()
	end)
	case("real scheduler uses timed jumps and preserves deferred teleports", function()
		tick = nil
		local state, root = fresh(Vector3.new(6800, 5200, 5000))
		root.Anchored = false
		move = Vector3.new(1, 0, 0)
		const start = state.localCFrame.Position
		local sum = 0
		local count = 0
		local frozen = true
		local released = true
		local releases = 0
		local bursts = {}
		const step = NAmanage.OffsetWalkStep
		const render = NAmanage.OffsetWalkRender
		NAmanage.OffsetWalkStep = function(current)
			const before = current.serverCFrame
			step(current)
			if current == state then
				frozen = frozen and state.phase == "frozen" and root.AssemblyLinearVelocity.Magnitude < 0.01
				if not NAmanage.OffsetWalkCFrameNear(before, current.serverCFrame) then
					bursts[#bursts + 1] = state.lastAnchorUpdate
				end
			end
		end
		NAmanage.OffsetWalkRender = function(current)
			render(current)
			if current == state then
				released = released and state.phase == "local" and NAmanage.OffsetWalkCFrameNear(root.CFrame, state.localCFrame)
					and (root.AssemblyLinearVelocity - state.localLinearVelocity).Magnitude < 0.01
				releases += 1
			end
		end
		NAlib.connect("spec_sample", run.PostSimulation:Connect(function(dt)
			sum += dt
			count += 1
		end))
		const at = realos.clock()
		while realos.clock() - at < 0.45 and count < 600 do run.Heartbeat:Wait() end
		NAlib.disconnect("spec_sample")
		NAmanage.OffsetWalkStep = step
		NAmanage.OffsetWalkRender = render
		check(state.localCFrame.Position.X > start.X, "real scheduler never advanced local movement")
		check(math.abs(state.localCFrame.Position.X - start.X - 60 * sum) < 2, "timed replication held local movement")
		check(frozen and released and releases >= 6, "real scheduler lost its freeze or render release")
		check(#bursts >= 2 and #bursts < count / 2, "replication still updates every frame")
		for i = 2, #bursts do check(bursts[i] - bursts[i - 1] >= 0.099, "replication released before 0.1 seconds") end
		move = Vector3.zero
		if helper then helper.Velocity = Vector3.zero end
		root.Anchored = true
		root.CFrame = CFrame.new(6900.02, 5200, 5000) * CFrame.Angles(0, 0.4, 0)
		local dest = root.CFrame
		run.Heartbeat:Wait()
		NAmanage.OffsetWalkRender(state)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, dest), "deferred CFrame signal lost teleport")
		char:PivotTo(CFrame.new(6950, 5200, 5000))
		dest = root.CFrame
		run.Heartbeat:Wait()
		NAmanage.OffsetWalkRender(state)
		check(NAmanage.OffsetWalkCFrameNear(root.CFrame, dest), "deferred PivotTo signal lost teleport")
	end)
end, function(err) return tostring(err).."\n"..debug.traceback() end)
move = Vector3.zero
NAStuff._unloading = true
pcall(function()
	if NAStuff.NAundergroundState and NAStuff.NAundergroundState.Underground then
		NAmanage.UG_disable(NAStuff.NAundergroundState)
	end
	NAmanage.StopOffsetWalk(true)
end)
for key in links do NAlib.disconnect(key) end
run:UnbindFromRenderStep(tag.."UG")
run:UnbindFromRenderStep(tag.."Walk")
folder:Destroy()
if not ok then
	error("NA_OFFSETWALK_SPEC: failed after "..cases.." scenarios, "..checks.." assertions: "..err)
end
print("NA_OFFSETWALK_SPEC: passed "..cases.." scenarios, "..checks.." assertions; fixtures and callbacks removed")
