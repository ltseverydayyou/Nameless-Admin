NAmanage.GetPhysVals = function(part)
	local props
	pcall(function()
		props = part.CurrentPhysicalProperties
	end)
	local d = 0.7
	local f = 0.3
	local e = 0.5
	local fw = 1
	local ew = 1
	if props then
		d = tonumber(props.Density) or d
		f = tonumber(props.Friction) or f
		e = tonumber(props.Elasticity) or e
		fw = tonumber(props.FrictionWeight) or fw
		ew = tonumber(props.ElasticityWeight) or ew
	end
	return d, f, e, fw, ew
end

NAmanage.GetCharParts = function()
	const char = getChar()
	if not char then
		return {}
	end
	return char:QueryDescendants("BasePart")
end

NAmanage.SetCharDensity = function(density)
	local n = 0
	density = math.clamp(tonumber(density) or 0.7, 0.01, 100)
	for _, part in NAmanage.GetCharParts() do
		pcall(function()
			local _, f, e, fw, ew = NAmanage.GetPhysVals(part)
			part.CustomPhysicalProperties = PhysicalProperties.new(density, f, e, fw, ew)
			n += 1
		end)
	end
	if NAmanage.RebuildVelocityWalkSpeedHelper then
		NAmanage.RebuildVelocityWalkSpeedHelper()
	end
	return n, density
end

NAmanage.GetCharMassInfo = function()
	local total = 0
	local vol = 0
	local n = 0
	for _, part in NAmanage.GetCharParts() do
		local ok, mass = pcall(function()
			return part.Mass
		end)
		if ok and type(mass) == "number" then
			const d = NAmanage.GetPhysVals(part)
			const v = mass / math.max(d, 0.01)
			if v > 0 then
				vol += v
			else
				vol += math.max(part.Size.X * part.Size.Y * part.Size.Z, 0.01)
			end
			total += mass
			n += 1
		end
	end
	return total, vol, n
end

cmd.add({"setmass","mass"},{"setmass <mass>","Sets your character mass as close as Roblox allows"},function(...)
	const args = {...}
	local target = tonumber(args[1])
	if not target then
		DebugNotif("Usage: setmass <mass>", 3)
		return
	end
	target = math.max(target, 0.01)
	local _, vol, n = NAmanage.GetCharMassInfo()
	if n <= 0 or vol <= 0 then
		DebugNotif("No valid character parts found", 3)
		return
	end
	const density = math.clamp(target / vol, 0.01, 100)
	NAmanage.SetCharDensity(density)
	const newMass = select(1, NAmanage.GetCharMassInfo())
	DebugNotif("Mass approx: "..tostring(math.floor(newMass * 100 + 0.5) / 100).." / "..tostring(target).." (density "..tostring(math.floor(density * 100 + 0.5) / 100)..")", 4)
end,true)

cmd.add({"seat"}, {"seat", "Finds a seat and automatically sits on it"}, function()
	const character = getChar()
	const humanoid = getHum()
	const root = character and getRoot(character)

	if not humanoid or not root then
		DoNotif("Your character or humanoid is invalid", 3)
		return
	end

	const seats = {}
	for _, v in NAmanage.QueryDescendants(Services.Workspace, "Seat") do
		if not v.Occupant then
			Insert(seats, v)
		end
	end

	if #seats == 0 then
		DebugNotif("No available seats found in the game", 3)
		return
	end

	table.sort(seats, function(a, b)
		return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
	end)

	const seat = seats[1]
	if seat then
		seat:Sit(humanoid)
		DebugNotif("Sat in the nearest seat", 2)
	else
		DebugNotif("Failed to sit in a seat", 3)
	end
end)

cmd.add({"vehicleseat", "vseat"}, {"vehicleseat (vseat)", "Sits you in a vehicle seat, useful for trying to find cars in games"}, function()
	const character = getChar()
	const humanoid = getHum()
	const root = character and getRoot(character)

	if not humanoid or not root then
		DoNotif("Your character or humanoid is invalid", 3)
		return
	end

	const vehicleSeats = {}
	for _, v in NAmanage.QueryDescendants(Services.Workspace, "VehicleSeat") do
		if not v.Occupant then
			Insert(vehicleSeats, v)
		end
	end

	if #vehicleSeats == 0 then
		DebugNotif("No available VehicleSeats found in the game", 3)
		return
	end

	table.sort(vehicleSeats, function(a, b)
		return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
	end)

	const vseat = vehicleSeats[1]
	if vseat then
		vseat:Sit(humanoid)
		DebugNotif("Sat in the nearest VehicleSeat", 2)
	else
		DebugNotif("Failed to sit in a VehicleSeat", 3)
	end
end)
cmd.add({"copytools","ctools"},{"copytools <player> (ctools)","Copies the tools the given player has"},function(...)
	const targets = getPlr(NAmanage.PlayerQueryFromArgs(...))
	const lp = Services.Players.LocalPlayer
	if not lp then return end
	const backpack = lp:FindFirstChildOfClass("Backpack")
	if not backpack then return end
	for _,plr in targets do
		const tBackpack = plr:FindFirstChildOfClass("Backpack")
		if tBackpack then
			for _,tool in tBackpack:GetChildren() do
				if tool:IsA("Tool") or tool:IsA("HopperBin") then
					tool:Clone().Parent = backpack
				end
			end
		end
	end
end,true)
cmd.add({"localtime", "yourtime"}, {"localtime (yourtime)", "Shows your current time"}, function()
	const time = os.date("*t")
	const clock = Format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	DoNotif("Your Local Time Is: "..clock)
end)
cmd.add({"localdate", "yourdate"}, {"localdate (yourdate)", "Shows your current date"}, function()
	const time = os.date("*t")
	const dateStr = Format("%02d/%02d/%04d", time.day, time.month, time.year)
	DoNotif("Your Local Date Is: "..dateStr)
end)
cmd.add({"servertime", "svtime"}, {"servertime (svtime)", "Shows the server's current time"}, function()
	const time = os.date("!*t")
	const clock = Format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	DoNotif("Server (UTC) Time Is: "..clock)
end)
cmd.add({"serverdate", "svdate"}, {"serverdate (svdate)", "Shows the server's current date"}, function()
	const time = os.date("!*t")
	const dateStr = Format("%02d/%02d/%04d", time.day, time.month, time.year)
	DoNotif("Server (UTC) Date Is: "..dateStr)
end)
cmd.add({"datetime", "localdatetime"}, {"datetime (localdatetime)", "Shows your full local date and time"}, function()
	const time = os.date("*t")
	const dateTime = Format("%02d/%02d/%04d %02d:%02d:%02d", time.day, time.month, time.year, time.hour, time.min, time.sec)
	DoNotif("Your Local Date & Time: "..dateTime)
end)
cmd.add({"uptime"}, {"uptime", "Shows how long the game/session has been running"}, function()
	const uptime = os.clock() - NASESSIONSTARTEDIDK
	const hours = math.floor(uptime / 3600)
	const minutes = math.floor((uptime % 3600) / 60)
	const seconds = math.floor(uptime % 60)
	const uptimeStr = Format("%02d:%02d:%02d", hours, minutes, seconds)
	DoNotif("Uptime: "..uptimeStr)
end)
cmd.add({"timestamp", "epoch"}, {"timestamp (epoch)", "Shows current Unix timestamp"}, function()
	const timestamp = os.time()
	DoNotif("Current Unix Timestamp: "..timestamp)
end)
cmd.add({"cartornado", "ctornado"}, {"cartornado (ctornado)", "Tornados a car just sit in the car"}, function()
	NAStuff = NAStuff or {}
	const CONN_KEY = "cartornado"
	const ACTIVE_KEY = "cartornado_active"
	NAlib.disconnect(CONN_KEY)
	NAlib.disconnect(ACTIVE_KEY)
	if NAStuff._cartornadoPart then
		pcall(function() NAStuff._cartornadoPart:Destroy() end)
		NAStuff._cartornadoPart = nil
	end
	if NAStuff._cartornadoHelper then
		pcall(function() NAStuff._cartornadoHelper:Destroy() end)
		NAStuff._cartornadoHelper = nil
	end

	const Player = Services.Players.LocalPlayer

	repeat Services.RunService.RenderStepped:Wait() until Player.Character
	const Character = Player.Character

	const SPart = InstanceNew("Part")
	SPart.Anchored = true
	SPart.CanCollide = true
	SPart.Size = Vector3.new(1, 100, 1)
	SPart.Transparency = 0.4
	SPart.Parent = Services.Workspace
	NAStuff._cartornadoPart = SPart
	NAlib.connect(CONN_KEY, SPart.AncestryChanged:Connect(function(_, parent)
		if not parent then
			NAStuff._cartornadoPart = nil
			Defer(function()
				NAlib.disconnect(CONN_KEY)
			end)
		end
	end))

	const rayParams = RaycastParams.new()
	NAmanage._raycastFilterType(rayParams)
	rayParams.FilterDescendantsInstances = { Character }

	NAlib.connect(CONN_KEY, Services.RunService.PreSimulation:Connect(function()
		if not SPart or not SPart.Parent then return end
		const hum = Character and getHum()
		if hum and Character.PrimaryPart then
			const rayOrigin = Character.PrimaryPart.Position + Character.PrimaryPart.CFrame.LookVector * 6
			const rayDir = Vector3.new(0, -4, 0)
			const result = Services.Workspace:Raycast(rayOrigin, rayDir, rayParams)
			if result then
				SPart.CFrame = Character.PrimaryPart.CFrame + Character.PrimaryPart.CFrame.LookVector * 6
			end
		end
	end))

	NAlib.connect(CONN_KEY, SPart.Touched:Connect(function(hit)
		if not hit:IsA("Seat") then return end
		NAlib.disconnect(CONN_KEY)
		NAStuff._cartornadoPart = nil

		const torso = getTorso(Character)
		if not torso then
			SPart:Destroy()
			return
		end

		const hum = getHum()
		if not hum then
			SPart:Destroy()
			return
		end

		const motionBase = Character.PrimaryPart or torso
		if not motionBase then
			SPart:Destroy()
			return
		end

		local helperPart = InstanceNew("Part")
		helperPart.Anchored = false
		helperPart.CanCollide = false
		helperPart.Transparency = 1
		helperPart.Size = Vector3.new(1, 1, 1)
		helperPart.CFrame = motionBase.CFrame
		helperPart.Parent = Services.Workspace
		NAStuff._cartornadoHelper = helperPart

		const helperWeld = InstanceNew("WeldConstraint")
		helperWeld.Part0 = helperPart
		helperWeld.Part1 = motionBase
		helperWeld.Parent = helperPart

		local isFlying = true
		const function cleanupHelperPart()
			isFlying = false
			if helperPart then
				helperPart:Destroy()
				helperPart = nil
			end
			if NAStuff._cartornadoHelper then
				NAStuff._cartornadoHelper = nil
			end
			NAlib.disconnect(ACTIVE_KEY)
		end

		const flyv = InstanceNew("BodyVelocity")
		const flyg = InstanceNew("BodyGyro")
		local speed = 50
		local lastSpeed = speed
		const maxSpeed = 100
		local isRunning = false
		local f = 0

		flyv.Parent = helperPart
		flyv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

		flyg.Parent = helperPart
		flyg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		flyg.P = 1000
		flyg.D = 50

		hum.PlatformStand = true

		NAlib.connect(ACTIVE_KEY, hum.Changed:Connect(function()
			isRunning = hum.MoveDirection.Magnitude > 0
		end))
		NAlib.connect(ACTIVE_KEY, hum.Died:Connect(cleanupHelperPart))
		NAlib.connect(ACTIVE_KEY, Character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cleanupHelperPart()
			end
		end))
		NAlib.connect(ACTIVE_KEY, helperPart.AncestryChanged:Connect(function(_, parent)
			if not parent then
				isFlying = false
				if NAStuff._cartornadoHelper then
					NAStuff._cartornadoHelper = nil
				end
				Defer(function()
					NAlib.disconnect(ACTIVE_KEY)
				end)
			end
		end))

		SpawnCall(function()
			while isFlying do
				flyg.CFrame = Services.Workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad(f * 50 * speed / maxSpeed), 0, 0)
				flyv.Velocity = Services.Workspace.CurrentCamera.CFrame.LookVector * speed
				Wait(0.1)

				if speed < 0 then
					speed = 0
					f = 0
				end

				if isRunning then
					speed = lastSpeed
				else
					if speed ~= 0 then
						lastSpeed = speed
					end
					speed = 0
				end
			end
		end)

		Wait(0.3)
		hit:Sit(hum)
		SPart:Destroy()

		const seat = hum.SeatPart
		if not seat then
			cleanupHelperPart()
			return
		end

		local vehicleModel = seat.Parent
		while vehicleModel and not vehicleModel:IsA("Model") do
			vehicleModel = vehicleModel.Parent
		end

		if vehicleModel then
			for _, v in NAmanage.QueryDescendants(vehicleModel, "BasePart") do
				if v.CanCollide then
					v.CanCollide = false
				end
			end
		end

		Wait(0.2)
		speed = 80

		const spin = InstanceNew("BodyAngularVelocity")
		spin.MaxTorque = Vector3.new(0, math.huge, 0)
		spin.AngularVelocity = Vector3.new(0, 2000, 0)
		spin.Parent = helperPart
	end))
end)

cmd.add({"unspam","unlag","unchatspam","unanimlag","unremotespam"},{"unspam","Stop all attempts to lag/spam"},function()
	NAlib.disconnect("spam")
end)

cmd.add({"UNCTest","UNC"},{"UNCTest (UNC)","Test how many functions your executor supports"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/UNC%20test")
end)

cmd.add({"vulnerabilitytest","vulntest"},{"vulnerabilitytest (vulntest)","Test if your executor is Vulnerable"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/VulnTest.lua")
end)

cmd.add({"respawn", "re"}, {"respawn (re)", "Respawn your character"}, function()
	respawn()
end)

cmd.add({"antisit"},{"antisit","Prevents the player from sitting"},function()
	const function noSit(character)
		local humanoid = getPlrHum(character)
		while not humanoid do Wait(.1) humanoid = getPlrHum(character) end
		humanoid.Sit = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	end

	if LocalPlayer.Character then
		noSit(LocalPlayer.Character)
	end

	NAlib.disconnect("antisit_conn")
	NAlib.connect("antisit_conn", LocalPlayer.CharacterAdded:Connect(noSit))

	DebugNotif("Anti sit enabled", 3)
end)

cmd.add({"unantisit"},{"unantisit","Allows the player to sit again"},function()
	const character = LocalPlayer.Character
	local humanoid = getHum()
	while not humanoid do Wait(.1) humanoid = getHum() end
	humanoid.Sit = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

	NAlib.disconnect("antisit_conn")
	DebugNotif("Anti sit disabled", 3)
end)

NAmanage.AntiKick_EnsureHook = function()
	if NAStuff.AntiKickHooked then return end
	const getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	const setReadOnly = setreadonly or (make_writeable and function(t, ro) if ro then make_readonly(t) else make_writeable(t) end end)
	if not getRawMetatable or not setReadOnly or not newcclosure or not hookfunction then return end
	const meta = getRawMetatable(game)
	if not meta then return end
	const player = Services.Players.LocalPlayer
	if not player then return end
	NAStuff.AntiKickOrig.namecall = meta.__namecall
	NAStuff.AntiKickOrig.index = meta.__index
	NAStuff.AntiKickOrig.newindex = meta.__newindex
	for _, Kick in next, { player.Kick, player.kick } do
		if Kick and type(Kick)=="function" then
			local originalKick
			originalKick = hookfunction(Kick, newcclosure(function(self, ...)
				if self==player then
					const msg = tostring((select(1, ...)) or "No message")
					Defer(DebugNotif, "Kick blocked (hook)", 2)
					if NAStuff.AntiKickMode=="error" then
						error("Kick blocked: "..msg, 0)
					else
						return
					end
				end
				return originalKick(self, ...)
			end))
			NAStuff.AntiKickOrig.kicks[Kick] = originalKick
		end
	end
	setReadOnly(meta, false)
	meta.__namecall = newcclosure(function(self, ...)
		const method = getnamecallmethod()
		if self==player and method and method:lower()=="kick" then
			const msg = tostring((select(1, ...)) or "No message")
			Defer(DebugNotif, "Kick blocked (__namecall)", 2)
			if NAStuff.AntiKickMode=="error" then
				error("Kick blocked: "..msg, 0)
			else
				return
			end
		end
		return NAStuff.AntiKickOrig.namecall(self, ...)
	end)
	meta.__index = newcclosure(function(self, key)
		if self==player then
			const k=tostring(key):lower()
			if k:find("kick") or k:find("destroy") then
				Defer(DebugNotif, "Blocked access: "..tostring(key), 2)
				if NAStuff.AntiKickMode=="error" then
					return function() error("Blocked method: "..tostring(key),0) end
				else
					return function() end
				end
			end
		end
		return NAStuff.AntiKickOrig.index(self, key)
	end)
	meta.__newindex = newcclosure(function(self, key, value)
		if self==player then
			const k=tostring(key):lower()
			if k:find("kick") or k:find("destroy") then
				Defer(DebugNotif, "Blocked overwrite: "..tostring(key), 2)
				return
			end
		end
		return NAStuff.AntiKickOrig.newindex(self, key, value)
	end)
	setReadOnly(meta, true)
	NAStuff.AntiKickHooked = true
	Defer(DebugNotif, "Anti-Kick active", 2)
end

NAmanage.AntiTeleport_EnsureHook = function()
	const RawTeleportService = __lt.gs("TeleportService")
	if NAStuff.AntiTeleportHooked then return end
	const getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	const setReadOnly = setreadonly or (make_writeable and function(t, ro) if ro then make_readonly(t) else make_writeable(t) end end)
	if not getRawMetatable or not setReadOnly or not newcclosure or not hookfunction then return end
	const meta = getRawMetatable(game)
	if not meta then return end
	if not Services.TeleportService then return end
	NAStuff.AntiTeleportOrig.namecall = meta.__namecall
	NAStuff.AntiTeleportOrig.index = meta.__index
	NAStuff.AntiTeleportOrig.newindex = meta.__newindex
	const methods = {"Teleport","TeleportToPlaceInstance","TeleportAsync","TeleportPartyAsync","TeleportToPrivateServer"}
	for _,m in methods do
		const fn = Services.TeleportService[m]
		if typeof(fn)=="function" then
			local orig
			orig = hookfunction(fn, newcclosure(function(self, ...)
				if self==Services.TeleportService or self==RawTeleportService then
					Defer(DebugNotif, "Teleport blocked (hook)", 2)
					if NAStuff.AntiTeleportMode=="error" then
						error("Teleport blocked",0)
					else
						return nil
					end
				end
				return orig(self,...)
			end))
			NAStuff.AntiTeleportOrig.funcs[m] = orig
		end
	end
	setReadOnly(meta,false)
	meta.__namecall = newcclosure(function(self, ...)
		const method = getnamecallmethod()
		if (self==Services.TeleportService or self==RawTeleportService) and typeof(method)=="string" and Lower(method):find("teleport") then
			Defer(DebugNotif, "Teleport blocked (__namecall)", 2)
			if NAStuff.AntiTeleportMode=="error" then
				error("Teleport blocked",0)
			else
				return nil
			end
		end
		return NAStuff.AntiTeleportOrig.namecall(self,...)
	end)
	meta.__index = newcclosure(function(self, key)
		if self==Services.TeleportService or self==RawTeleportService then
			const k = Lower(tostring(key))
			if k:find("teleport") then
				Defer(DebugNotif, "Blocked access: "..tostring(key), 2)
				if NAStuff.AntiTeleportMode=="error" then
					return function() error("Blocked method: "..tostring(key),0) end
				else
					return function() end
				end
			end
		end
		return NAStuff.AntiTeleportOrig.index(self,key)
	end)
	meta.__newindex = newcclosure(function(self, key, value)
		if self==Services.TeleportService or self==RawTeleportService then
			const k = Lower(tostring(key))
			if k:find("teleport") then
				Defer(DebugNotif, "Blocked overwrite: "..tostring(key), 2)
				return
			end
		end
		return NAStuff.AntiTeleportOrig.newindex(self,key,value)
	end)
	setReadOnly(meta,true)
	NAStuff.AntiTeleportHooked = true
	Defer(DebugNotif, "Anti-Teleport active", 2)
end

cmd.add({"antikick","nokick","bypasskick","bk"},{"antikick (nokick, bypasskick, bk)","Bypass Kick on Most Games"},function(mode)
	const m = mode and Lower(tostring(mode)) or nil
	const function apply()
		NAmanage.AntiKick_EnsureHook()
		DebugNotif("Anti-Kick: "..(NAStuff.AntiKickMode=="error" and "Error" or "Fake Success"),2)
	end
	if m=="error" or m=="fail" then
		NAStuff.AntiKickMode = "error"
		apply()
	elseif m=="success" or m=="ok" or m=="fake" then
		NAStuff.AntiKickMode = "fakeok"
		apply()
	else
		Window({
			Title = "Anti-Kick Mode",
			Buttons = {
				{ Text = "Fake Success", Callback = function() NAStuff.AntiKickMode="fakeok"; apply() end },
				{ Text = "Error",        Callback = function() NAStuff.AntiKickMode="error";  apply() end }
			}
		})
	end
end,true)

cmd.add({"antiteleport","noteleport","blocktp"},{"antiteleport (noteleport, blocktp)","Prevents TeleportService from moving you to another place"},function(mode)
	const m = mode and Lower(tostring(mode)) or nil
	const function apply()
		NAmanage.AntiTeleport_EnsureHook()
		DebugNotif("Anti-Teleport: "..(NAStuff.AntiTeleportMode=="error" and "Error" or "Fake Success"),2)
	end
	if m=="error" or m=="fail" then
		NAStuff.AntiTeleportMode = "error"
		apply()
	elseif m=="success" or m=="ok" or m=="fake" then
		NAStuff.AntiTeleportMode = "fakeok"
		apply()
	else
		Window({
			Title = "Anti-Teleport Mode",
			Buttons = {
				{ Text = "Fake Success", Callback = function() NAStuff.AntiTeleportMode="fakeok"; apply() end },
				{ Text = "Error",        Callback = function() NAStuff.AntiTeleportMode="error";  apply() end }
			}
		})
	end
end,true)

cmd.add({"unantikick","unnokick","unbypasskick","unbk"},{"unantikick","Disables Anti-Kick protection"},function()
	const getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	const setReadOnly = setreadonly or (make_writeable and function(t, ro) if ro then make_readonly(t) else make_writeable(t) end end)
	const meta = getRawMetatable(game)
	if not meta or not NAStuff.AntiKickOrig or not NAStuff.AntiKickOrig.namecall then
		DoNotif("Anti-Kick not active or missing references",3)
		return
	end
	const player = Services.Players.LocalPlayer
	for k,orig in NAStuff.AntiKickOrig.kicks or {} do
		pcall(function() hookfunction(k, orig) end)
	end
	setReadOnly(meta,false)
	meta.__namecall = NAStuff.AntiKickOrig.namecall
	meta.__index = NAStuff.AntiKickOrig.index
	meta.__newindex = NAStuff.AntiKickOrig.newindex
	setReadOnly(meta,true)
	NAStuff.AntiKickHooked = false
	DebugNotif("Anti-Kick Disabled",2)
end)

cmd.add({"unantiteleport","unnoteleport","unblocktp"},{"unantiteleport","Disables Anti-Teleport protection"},function()
	const getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	const setReadOnly = setreadonly or (make_writeable and function(t, ro) if ro then make_readonly(t) else make_writeable(t) end end)
	const meta = getRawMetatable(game)
	if not meta or not NAStuff.AntiTeleportOrig or not NAStuff.AntiTeleportOrig.namecall then
		DoNotif("Anti-Teleport not active or missing references",3)
		return
	end
	for name,orig in NAStuff.AntiTeleportOrig.funcs or {} do
		const fn = Services.TeleportService[name]
		if typeof(fn)=="function" and orig then
			pcall(function() hookfunction(fn, orig) end)
		end
	end
	setReadOnly(meta,false)
	meta.__namecall = NAStuff.AntiTeleportOrig.namecall
	meta.__index = NAStuff.AntiTeleportOrig.index
	meta.__newindex = NAStuff.AntiTeleportOrig.newindex
	setReadOnly(meta,true)
	NAStuff.AntiTeleportHooked = false
	DebugNotif("Anti-Teleport Disabled",2)
end)

NAStuff.ATPC = {
	state = false,
	plr = Services.Players.LocalPlayer,
	gui = nil,
	btn = nil,
	allowed = {},
	old = {},
	parts = {}
}

function AntiOn()
	if type(Get) == "function" then
		local ok, v = pcall(Get, "AntiCFrame")
		if ok then return v end
	end
	return NAStuff.ATPC.state
end

NAStuff.ATPC._syncBtn = function()
	const b = NAStuff.ATPC.btn
	if not b then return end
	if NAStuff.ATPC.state then
		b.Text = "UNACFTP"
		b.BackgroundColor3 = Color3.fromRGB(0,170,0)
	else
		b.Text = "ACFTP"
		b.BackgroundColor3 = Color3.fromRGB(170,0,0)
	end
end

NAStuff.ATPC._buildGUI = function()
	if not IsOnMobile then return end
	if NAStuff.ATPC.gui then
		NAStuff.ATPC.gui:Destroy()
		NAStuff.ATPC.gui = nil
		NAStuff.ATPC.btn = nil
	end

	const g = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(g)
	g.ResetOnSpawn = false

	const b = InstanceNew("TextButton")
	const c = InstanceNew("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	const a = InstanceNew("UIAspectRatioConstraint")

	b.Parent = g
	b.BackgroundTransparency = 0.1
	b.Position = UDim2.new(0.9,0,0.4,0)
	b.Size = UDim2.new(0.08,0,0.1,0)
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextScaled = true
	b.TextWrapped = true
	b.Active = true

	c.CornerRadius = UDim.new(0, 6)
	c.Parent = b

	a.Parent = b
	a.AspectRatio = 1

	NAStuff.ATPC.gui = g
	NAStuff.ATPC.btn = b
	NAStuff.ATPC._syncBtn()

	MouseButtonFix(b, function()
		if NAStuff.ATPC.state then
			NAStuff.ATPC.Disable()
		else
			NAStuff.ATPC.Enable()
		end
	end)

	NAgui.draggerV2(b)
end

NAStuff.ATPC._hookChar = function(char)
	const allowed = NAStuff.ATPC.allowed
	const old = NAStuff.ATPC.old
	const parts = NAStuff.ATPC.parts

	const function hookPart(p)
		if not p or not p.Parent or not p:IsA("BasePart") then return end
		if allowed[p] ~= nil then return end

		allowed[p] = false
		old[p] = p.CFrame
		Insert(parts, p)

		const sig = p:GetPropertyChangedSignal("CFrame")
		const con = sig:Connect(function()
			if not NAStuff.ATPC.state then return end
			if not NAlib.isConnected("AntiCFrame") then return end
			if not AntiOn() then return end
			if not p.Parent then return end
			if allowed[p] then return end

			const o = old[p]
			if not o then return end

			allowed[p] = true
			p.CFrame = o
			Wait()
			allowed[p] = false
		end)

		NAlib.connect("AntiCFrame", con)
	end

	for _, d in char:QueryDescendants("BasePart") do
		hookPart(d)
	end

	const addCon = NAmanage.descAdd(char, function(d)
		if not NAStuff.ATPC.state then return end
		if d:IsA("BasePart") then
			hookPart(d)
		end
	end, function(d)
		return d and d:IsA("BasePart")
	end)
	NAlib.connect("AntiCFrame", addCon)

	Spawn(function()
		while NAStuff.ATPC.state and NAlib.isConnected("AntiCFrame") and char and char.Parent do
			for _, p in parts do
				if p and p.Parent and not allowed[p] then
					old[p] = p.CFrame
				end
			end
			Wait()
		end
	end)
end

NAStuff.ATPC.Enable = function()
	if NAStuff.ATPC.state then return end

	const plr = Services.Players.LocalPlayer
	if not plr then
		DoNotif("Anti CFrame Teleport failed (no player)")
		return
	end

	const char = getChar() or plr.Character
	if not char or not char.Parent then
		DoNotif("Anti CFrame Teleport failed (no character)")
		return
	end

	NAStuff.ATPC.state = true
	NAStuff.ATPC.plr = plr
	NAStuff.ATPC.allowed = {}
	NAStuff.ATPC.old = {}
	NAStuff.ATPC.parts = {}

	if type(Refresh) == "function" then
		pcall(Refresh, "AntiCFrame", true)
	end

	NAlib.disconnect("AntiCFrame")
	NAlib.disconnect("AntiCFrame_charAdded")

	NAStuff.ATPC._hookChar(char)

	NAlib.connect("AntiCFrame_charAdded", plr.CharacterAdded:Connect(function(newChar)
		if not NAStuff.ATPC.state then return end
		if not newChar or not newChar.Parent then return end
		NAStuff.ATPC.allowed = {}
		NAStuff.ATPC.old = {}
		NAStuff.ATPC.parts = {}
		NAlib.disconnect("AntiCFrame")
		NAStuff.ATPC._hookChar(newChar)
	end))

	NAStuff.ATPC._syncBtn()
	DoNotif("Anti CFrame Teleport has been enabled")
end

NAStuff.ATPC.Disable = function()
	if not NAStuff.ATPC.state then return end

	NAStuff.ATPC.state = false

	if type(Add) == "function" then
		pcall(Add, "AntiCFrame", false)
	end

	NAlib.disconnect("AntiCFrame")
	NAlib.disconnect("AntiCFrame_charAdded")

	NAStuff.ATPC.allowed = {}
	NAStuff.ATPC.old = {}
	NAStuff.ATPC.parts = {}

	NAStuff.ATPC._syncBtn()
	DoNotif("Anti CFrame Teleport has been disabled")
end

cmd.add({ "anticframeteleport","acframetp","acftp" }, { "anticframeteleport (acframetp,acftp)","Prevents client teleports" }, function()
	NAStuff.ATPC.Enable()
	if IsOnMobile then
		if not NAStuff.ATPC.gui then
			NAStuff.ATPC._buildGUI()
		end
	end
end)

cmd.add({ "unanticframeteleport","unacframetp","unacftp" }, { "unanticframeteleport (unacframetp,unacftp)","Disables Anti CFrame Teleport" }, function()
	NAStuff.ATPC.Disable()
	if NAStuff.ATPC.gui then
		NAStuff.ATPC.gui:Destroy()
		NAStuff.ATPC.gui = nil
		NAStuff.ATPC.btn = nil
	end
end)

cmd.add({"lay"},{"lay","zzzzzzzz"},function()
	const Human=getHum()
	if not Human then return end
	Human.Sit=true
	Wait(.1)
	NAmanage.UG_setRootCFrame(Human.RootPart, (NAmanage.UG_clientCFrame(Human.RootPart) or Human.RootPart.CFrame)*CFrame.Angles(math.pi*.5,0,0))
	for _,v in Human:GetPlayingAnimationTracks() do
		v:Stop()
	end
end)

cmd.add({"trip"},{"trip","get up NOW"},function()
	getHum():ChangeState(0)
	getRoot(getChar()).Velocity=getRoot(getChar()).CFrame.LookVector*25
end)

cmd.add({"permtrip","ptrip"},{"permtrip (ptrip)","Permanent trip that keeps you down"},function()
	NAStuff.permtrip = true
	shared.__permtrip = shared.__permtrip or {saved = {}}
	const STORE = shared.__permtrip

	const function cacheAndDisableGettingUp(hum)
		if not hum then return end
		if STORE.saved[hum] == nil then
			local ok, was = pcall(function()
				return hum:GetStateEnabled(Enum.HumanoidStateType.GettingUp)
			end)
			if ok then
				STORE.saved[hum] = was
			end
		end
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		end)
	end

	const function applyPermTrip()
		if not NAStuff.permtrip then return end
		const char = getChar()
		const hum = char and getPlrHum(char)
		const root = char and getRoot(char)
		if not (hum and root) then return end

		cacheAndDisableGettingUp(hum)
		pcall(function()
			if hum:GetState() ~= Enum.HumanoidStateType.FallingDown then
				hum:ChangeState(Enum.HumanoidStateType.FallingDown)
			end
		end)
		const look = root.CFrame.LookVector
		pcall(function()
			root.AssemblyLinearVelocity = Vector3.new(look.X * 25, -35, look.Z * 25)
		end)
	end

	NAlib.disconnect("permtrip_step")
	NAlib.disconnect("permtrip_char")
	applyPermTrip()

	NAlib.connect("permtrip_step", Services.RunService.RenderStepped:Connect(function()
		applyPermTrip()
	end))
	NAlib.connect("permtrip_char", Services.Players.LocalPlayer.CharacterAdded:Connect(function()
		if not NAStuff.permtrip then return end
		Wait(0.2)
		applyPermTrip()
	end))
end)

cmd.add({"unpermtrip","unptrip"},{"unpermtrip (unptrip)","Disable permanent trip"},function()
	NAStuff.permtrip = false
	NAlib.disconnect("permtrip_step")
	NAlib.disconnect("permtrip_char")

	const STORE = shared.__permtrip
	if STORE and STORE.saved then
		for hum, was in STORE.saved do
			if hum and hum.Parent then
				pcall(function()
					hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, was)
				end)
			end
		end
		STORE.saved = {}
	end
end)

cmd.add({"antitrip", "antiragdoll"}, {"antitrip", "no tripping today bruh"}, function()
	const LocalPlayer=Services.Players.LocalPlayer
	const states={Enum.HumanoidStateType.FallingDown,Enum.HumanoidStateType.Ragdoll,Enum.HumanoidStateType.PlatformStanding}
	shared.__antitrip=shared.__antitrip or {saved={}}
	const STORE=shared.__antitrip
	const function saveAndDisableStates(h)
		const saved={}
		for _,st in states do
			local ok,was=pcall(function() return h:GetStateEnabled(st) end)
			if ok then
				saved[st]=was
				pcall(function() h:SetStateEnabled(st,false) end)
			end
		end
		STORE.saved[h]=saved
	end
	const function recover(hum,root)
		pcall(function() root.AssemblyLinearVelocity=Vector3.zero end)
		pcall(function() hum.PlatformStand=false end)
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
	end
	const function doTRIPPER(char)
		local hum=getPlrHum(char)
		local root=getRoot(char)
		while not (hum and root) do Wait(0.1) hum=getPlrHum(char) root=getRoot(char) end
		saveAndDisableStates(hum)
		NAlib.disconnect("trip_fall")
		NAlib.connect("trip_fall",hum.FallingDown:Connect(function()
			recover(hum,root)
		end))
		NAlib.disconnect("trip_state")
		NAlib.connect("trip_state",hum.StateChanged:Connect(function(_,new)
			if new==Enum.HumanoidStateType.FallingDown or new==Enum.HumanoidStateType.Ragdoll or new==Enum.HumanoidStateType.PlatformStanding then
				recover(hum,root)
			end
		end))
		NAlib.disconnect("trip_step")
		NAlib.connect("trip_step",Services.RunService.RenderStepped:Connect(function()
			const s=hum:GetState()
			if s==Enum.HumanoidStateType.FallingDown or s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.PlatformStanding then
				recover(hum,root)
			end
		end))
		hum.Destroying:Connect(function() STORE.saved[hum]=nil end)
	end
	if LocalPlayer and LocalPlayer.Character then
		doTRIPPER(LocalPlayer.Character)
	end
	NAlib.disconnect("trip_char")
	NAlib.connect("trip_char",(LocalPlayer and LocalPlayer.CharacterAdded):Connect(function(char)
		doTRIPPER(char)
	end))
	DebugNotif("Antitrip Enabled",2)
end)

cmd.add({"unantitrip"}, {"unantitrip", "tripping allowed now"}, function()
	NAlib.disconnect("trip_fall")
	NAlib.disconnect("trip_state")
	NAlib.disconnect("trip_step")
	NAlib.disconnect("trip_char")
	const STORE=shared.__antitrip
	if STORE and STORE.saved then
		for hum,saved in STORE.saved do
			if hum and hum.Parent and saved then
				for st,was in saved do
					pcall(function() hum:SetStateEnabled(st,was) end)
				end
			end
		end
		STORE.saved={}
	end
	const char=getChar()
	if char then
		const hum=getPlrHum(char)
		if hum then
			pcall(function() hum.PlatformStand=false end)
		end
	end
	DebugNotif("Antitrip Disabled",2)
end)

NAmanage.getHumState = function()
	if NAStuff.AllHumanoidStatesExceptNone then
		return NAStuff.AllHumanoidStatesExceptNone
	end

	const states = {}
	for _, state in Enum.HumanoidStateType:GetEnumItems() do
		if state ~= Enum.HumanoidStateType.None then
			Insert(states, state)
		end
	end
	NAStuff.AllHumanoidStatesExceptNone = states
	return states
end

NAmanage.cleanHumStateName = function(name)
	name = tostring(name or "")
	name = name:gsub("^Enum%.HumanoidStateType%.", "")
	name = name:gsub("[%s_%-%./]", "")
	return Lower(name)
end

NAmanage.getHumStateMap = function()
	if NAStuff.HumanoidStateNameMap then
		return NAStuff.HumanoidStateNameMap
	end
	const map = {}
	for _, state in NAmanage.getHumState() do
		map[NAmanage.cleanHumStateName(state.Name)] = state
		map[NAmanage.cleanHumStateName(tostring(state))] = state
		map[tostring(state.Value)] = state
	end
	NAStuff.HumanoidStateNameMap = map
	return map
end

NAmanage.parseHumStates = function(args)
	args = type(args) == "table" and args or {}
	const map = NAmanage.getHumStateMap()
	local states = {}
	const seen = {}
	local bad = {}
	local all = #args == 0
	for _, raw in args do
		for tok in tostring(raw or ""):gmatch("[^,%s]+") do
			const key = NAmanage.cleanHumStateName(tok)
			if key == "" or key == "state" then
			elseif key == "all" or key == "any" or key == "everything" then
				all = true
			else
				const state = map[key]
				if state and not seen[state] then
					seen[state] = true
					Insert(states, state)
				elseif not state then
					Insert(bad, tok)
				end
			end
		end
	end
	if all then
		states = NAmanage.getHumState()
		bad = {}
	end
	return states, bad
end

NAmanage.HumanoidStateLockHas = function(state)
	if not state then return false end
	const states = NAStuff.HumanoidStateLockStates
	if type(states) ~= "table" then return false end
	for _, v in states do
		if v == state then
			return true
		end
	end
	return false
end

NAStuff.HumanoidStateLockSignals = NAStuff.HumanoidStateLockSignals or {}

NAmanage.HumanoidStateLockClearSignals = function(hum)
	const sigs = NAStuff.HumanoidStateLockSignals
	if type(sigs) ~= "table" then
		NAStuff.HumanoidStateLockSignals = {}
		return
	end
	const function clearOne(h)
		const arr = sigs[h]
		if arr then
			for _, c in arr do
				pcall(function()
					if c and type(c.Disconnect) == "function" then
						c:Disconnect()
					end
				end)
			end
			sigs[h] = nil
		end
	end
	if hum then
		clearOne(hum)
		return
	end
	for h in sigs do
		clearOne(h)
	end
end

NAmanage.HumanoidStateLockFallbackState = function()
	const pref = {
		Enum.HumanoidStateType.Running,
		Enum.HumanoidStateType.Freefall,
		Enum.HumanoidStateType.GettingUp,
		Enum.HumanoidStateType.Physics,
	}
	for _, state in pref do
		if state and not NAmanage.HumanoidStateLockHas(state) then
			return state
		end
	end
	return nil
end

NAmanage.HumanoidStateLockWire = function(hum)
	if not hum then return end
	NAStuff.HumanoidStateLockSignals = NAStuff.HumanoidStateLockSignals or {}
	if NAStuff.HumanoidStateLockSignals[hum] then return end
	const arr = {}
	NAStuff.HumanoidStateLockSignals[hum] = arr
	const function add(sig, fn)
		if not sig then return end
		local ok, c = pcall(function()
			return sig:Connect(fn)
		end)
		if ok and c then
			Insert(arr, c)
		end
	end
	add(hum.StateChanged, function(_, state)
		if not NAStuff.HumanoidStateLockEnabled then return end
		if typeof(state) == "EnumItem" and state.EnumType == Enum.HumanoidStateType and NAmanage.HumanoidStateLockHas(state) then
			pcall(function()
				hum:SetStateEnabled(state, false)
			end)
			const alt = NAmanage.HumanoidStateLockFallbackState()
			if alt then
				pcall(function()
					hum:ChangeState(alt)
				end)
			end
		end
	end)
	add(hum.Destroying, function()
		const store = shared.__disablehumanoidstate
		if store and store.saved then
			store.saved[hum] = nil
		end
		NAmanage.HumanoidStateLockClearSignals(hum)
		if NAStuff.HumanoidStateLockHumanoid == hum then
			NAStuff.HumanoidStateLockHumanoid = nil
		end
	end)
end

NAmanage.HumanoidStateLockApply = function(hum)
	if not hum then return 0 end

	shared.__disablehumanoidstate = shared.__disablehumanoidstate or {saved = {}}
	const store = shared.__disablehumanoidstate
	local saved = store.saved[hum]
	if not saved then
		saved = {}
		store.saved[hum] = saved
	end

	local disabled = 0
	const states = NAStuff.HumanoidStateLockStates or NAmanage.getHumState()
	for _, state in states do
		if saved[state] == nil then
			local okEnabled, wasEnabled = pcall(function()
				return hum:GetStateEnabled(state)
			end)
			if okEnabled then
				saved[state] = wasEnabled
			end
		end

		const okSet = pcall(function()
			hum:SetStateEnabled(state, false)
		end)
		if okSet then
			disabled += 1
		end
	end

	local okState, cur = pcall(function()
		return hum:GetState()
	end)
	if okState and NAmanage.HumanoidStateLockHas(cur) then
		const alt = NAmanage.HumanoidStateLockFallbackState()
		if alt then
			pcall(function()
				hum:ChangeState(alt)
			end)
		end
	end

	NAStuff.HumanoidStateLockHumanoid = hum
	NAmanage.HumanoidStateLockWire(hum)
	return disabled
end

NAmanage.HumanoidStateLockRestore = function(hum, states)
	if not hum then return 0 end

	const store = shared.__disablehumanoidstate
	const saved = store and store.saved and store.saved[hum] or nil
	local restored = 0

	if saved then
		const list = states or {}
		const restoreAll = #list == 0
		if restoreAll then
			for state, wasEnabled in saved do
				const okSet = pcall(function()
					hum:SetStateEnabled(state, wasEnabled)
				end)
				if okSet then
					restored += 1
				end
			end
			store.saved[hum] = nil
		else
			for _, state in list do
				const wasEnabled = saved[state]
				if wasEnabled ~= nil then
					const okSet = pcall(function()
						hum:SetStateEnabled(state, wasEnabled)
					end)
					if okSet then
						restored += 1
					end
					saved[state] = nil
				else
					const okSet = pcall(function()
						hum:SetStateEnabled(state, true)
					end)
					if okSet then
						restored += 1
					end
				end
			end
			local empty = true
			for _ in saved do
				empty = false
				break
			end
			if empty then
				store.saved[hum] = nil
			end
		end
	else
		for _, state in states or NAmanage.getHumState() do
			const okSet = pcall(function()
				hum:SetStateEnabled(state, true)
			end)
			if okSet then
				restored += 1
			end
		end
	end

	if (not states or #states == 0) and NAStuff.HumanoidStateLockHumanoid == hum then
		NAStuff.HumanoidStateLockHumanoid = nil
		NAmanage.HumanoidStateLockClearSignals(hum)
	end
	return restored
end

NAmanage.HumanoidStateLockEnsureHook = function()
	if NAStuff.HumanoidStateLockHooked then
		return true
	end
	if not (typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" and typeof(newcclosure) == "function" and typeof(checkcaller) == "function") then
		NAStuff.HumanoidStateLockNoHook = true
		return false
	end

	NAStuff.HumanoidStateLockHooked = true
	NAStuff.HumanoidStateLockNoHook = false
	NAStuff.HumanoidStateLockOldNC = NAStuff.HumanoidStateLockOldNC or hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		if not checkcaller() and NAStuff.HumanoidStateLockEnabled and typeof(self) == "Instance" then
			const hum = NAStuff.HumanoidStateLockHumanoid
			if hum and self == hum then
				local method = getnamecallmethod()
				if type(method) == "string" then
					method = Lower(method)
				end
				if method == "setstateenabled" then
					local state, enabled = ...
					if typeof(state) == "EnumItem" and state.EnumType == Enum.HumanoidStateType and enabled == true and NAmanage.HumanoidStateLockHas(state) then
						return
					end
				elseif method == "changestate" then
					const state = ...
					if typeof(state) == "EnumItem" and state.EnumType == Enum.HumanoidStateType and NAmanage.HumanoidStateLockHas(state) then
						return
					end
				end
			end
		end
		return NAStuff.HumanoidStateLockOldNC(self, ...)
	end))

	return true
end

NAmanage.HumanoidStateLockStartLoops = function()
	NAlib.disconnect("humstate_lock_step")
	const function pulse()
		if not NAStuff.HumanoidStateLockEnabled then return end
		const activeHum = getHum()
		if activeHum then
			NAmanage.HumanoidStateLockApply(activeHum)
		end
	end
	pcall(function()
		NAlib.connect("humstate_lock_step", Services.RunService.RenderStepped:Connect(pulse))
	end)
	pcall(function()
		NAlib.connect("humstate_lock_step", Services.RunService.PreSimulation:Connect(pulse))
	end)
	pcall(function()
		NAlib.connect("humstate_lock_step", Services.RunService.Heartbeat:Connect(pulse))
	end)
end

NAmanage.HumanoidStateLockStart = function(states)
	NAStuff.HumanoidStateLockEnabled = true
	NAStuff.HumanoidStateLockStates = type(states) == "table" and #states > 0 and states or NAmanage.getHumState()
	const hooked = NAmanage.HumanoidStateLockEnsureHook()
	NAStuff.HumanoidStateLockFallback = not hooked

	const hum = getHum()
	if hum then
		NAmanage.HumanoidStateLockApply(hum)
	end

	NAmanage.HumanoidStateLockStartLoops()

	NAlib.disconnect("humstate_lock_char")
	const lp = Services.Players.LocalPlayer
	if lp then
		NAlib.connect("humstate_lock_char", lp.CharacterAdded:Connect(function(char)
			if not NAStuff.HumanoidStateLockEnabled then return end
			const hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 10)
			if hum then
				NAmanage.HumanoidStateLockApply(hum)
			end
		end))
	end
end

NAmanage.HumanoidStateLockStop = function(states)
	const hum = getHum()
	const restored = hum and NAmanage.HumanoidStateLockRestore(hum, states) or 0
	if not states or #states == 0 then
		NAStuff.HumanoidStateLockEnabled = false
		NAStuff.HumanoidStateLockStates = nil
		NAlib.disconnect("humstate_lock_step")
		NAlib.disconnect("humstate_lock_char")
		NAmanage.HumanoidStateLockClearSignals()
	else
		const keep = {}
		const rem = {}
		for _, state in states do
			rem[state] = true
		end
		for _, state in NAStuff.HumanoidStateLockStates or {} do
			if not rem[state] then
				Insert(keep, state)
			end
		end
		NAStuff.HumanoidStateLockStates = #keep > 0 and keep or nil
		if #keep == 0 then
			NAStuff.HumanoidStateLockEnabled = false
			NAlib.disconnect("humstate_lock_step")
			NAlib.disconnect("humstate_lock_char")
			NAmanage.HumanoidStateLockClearSignals()
		elseif hum then
			NAmanage.HumanoidStateLockApply(hum)
		end
	end
	return restored
end

NAmanage.HumanoidStateLockWindow = function()
	const hum = getHum()
	if not hum then
		DebugNotif("No humanoid found", 2)
		return
	end
	if type(Window) ~= "function" then
		NAmanage.HumanoidStateLockStart(NAmanage.getHumState())
		DebugNotif("Window unavailable; disabled all humanoid states", 3)
		return
	end
	const buttons = {}
	Insert(buttons, {
		Text = "All States",
		Callback = function()
			const states = NAmanage.getHumState()
			NAmanage.HumanoidStateLockStart(states)
			DebugNotif("Humanoid state lock enabled ("..tostring(#states).." states)", 2)
		end
	})
	Insert(buttons, {
		Text = "Restore All",
		Callback = function()
			const restored = NAmanage.HumanoidStateLockStop(nil)
			DebugNotif("Humanoid state lock disabled ("..tostring(restored).." states restored)", 2)
		end
	})
	for _, state in NAmanage.getHumState() do
		const st = state
		Insert(buttons, {
			Text = st.Name,
			Callback = function()
				NAmanage.HumanoidStateLockStart({st})
				DebugNotif("Humanoid state lock enabled ("..st.Name..")", 2)
			end
		})
	end
	Insert(buttons, {Text = "Cancel", Callback = function() end})
	Window({
		Title = "Disable Humanoid State",
		Description = "Pick which HumanoidStateType to disable.",
		Buttons = buttons
	})
end

cmd.add({"disablehumanoidstate","disablehumanoidstates","disablehumstates"}, {"disablehumanoidstate", "Opens a picker to disable one humanoid state"}, function(...)
	const args = {...}
	if #args == 0 then
		NAmanage.HumanoidStateLockWindow()
		return
	end
	const hum = getHum()
	if not hum then
		DebugNotif("No humanoid found", 2)
		return
	end
	local states, bad = NAmanage.parseHumStates(args)
	if #bad > 0 then
		DebugNotif("Unknown humanoid state: "..tostring(bad[1]), 3)
		return
	end
	NAmanage.HumanoidStateLockStart(states)
	DebugNotif("Humanoid state lock enabled ("..tostring(#states).." states)", 2)
end)

cmd.add({"enablehumanoidstate","enablehumanoidstates","restorehumanoidstate","restorehumstates"}, {"enablehumanoidstate [state/all]", "Restores one humanoid state or all disabled states"}, function(...)
	const args = {...}
	local states, bad = NAmanage.parseHumStates(args)
	if #bad > 0 then
		DebugNotif("Unknown humanoid state: "..tostring(bad[1]), 3)
		return
	end
	const use = #args > 0 and states or nil
	const restored = NAmanage.HumanoidStateLockStop(use)
	DebugNotif("Humanoid state lock disabled ("..restored.." states restored)", 2)
end)

cmd.add({"checkrfe"},{"checkrfe","Checks if the game has respect filtering enabled off"},function()
	DoNotif(SafeGetService("SoundService").RespectFilteringEnabled and "Respect Filtering Enabled is on" or "Respect Filtering Enabled is off")
end)

cmd.add({"sit"},{"sit","Sit your player"},function()
	const hum=getHum()
	if hum then
		hum.Sit=true
	end
end)

cmd.add({"oldroblox"},{"oldroblox","Old skybox and studs"},function()
	if NAmanage.GetAttr(Services.Lighting, "NAOldRbx_Enabled") then return end
	NAmanage.SetAttr(Services.Lighting, "NAOldRbx_Enabled", true)

	const studTex = NAmanage.getNAImageAsset("Stud", "rbxassetid://48715260")
	const inletTex = NAmanage.getNAImageAsset("Inlet", "rbxassetid://20299774")
	const skyA = {
		bk = NAmanage.getNAImageAsset("bk", "rbxassetid://161781263"),
		dn = NAmanage.getNAImageAsset("dn", "rbxassetid://161781258"),
		ft = NAmanage.getNAImageAsset("ft", "rbxassetid://161781261"),
		lf = NAmanage.getNAImageAsset("lf", "rbxassetid://161781267"),
		rt = NAmanage.getNAImageAsset("rt", "rbxassetid://161781268"),
		up = NAmanage.getNAImageAsset("up", "rbxassetid://161781260"),
	}

	const function ensureSky()
		const s = __lt.cm("Lighting", "FindFirstChild", "NAOldRobloxSky")
		if s then return s end
		const sky = InstanceNew("Sky")
		sky.Name = "NAOldRobloxSky"
		sky.SkyboxBk = skyA.bk
		sky.SkyboxDn = skyA.dn
		sky.SkyboxFt = skyA.ft
		sky.SkyboxLf = skyA.lf
		sky.SkyboxRt = skyA.rt
		sky.SkyboxUp = skyA.up
		sky.Parent = Services.Lighting
		return sky
	end

	const function applyToPart(v)
		if not v or not v.Parent or not v:IsA("BasePart") then return end
		if NAmanage.GetAttr(v, "NAOldRbx_Applied") then return end
		NAmanage.SetAttr(v, "NAOldRbx_Applied", true)
		if NAmanage.GetAttr(v, "NAOldRbx_OrigMatName") == nil then
			local ok, name = pcall(function() return v.Material.Name end)
			if ok then NAmanage.SetAttr(v, "NAOldRbx_OrigMatName", name) end
		end

		local stud = v:FindFirstChild("NAOldRobloxStud")
		if not stud then
			stud = InstanceNew("Texture")
			stud.Name = "NAOldRobloxStud"
			stud.Parent = v
		end
		stud.Texture = studTex
		stud.Face = Enum.NormalId.Top
		stud.StudsPerTileU = 1
		stud.StudsPerTileV = 1
		stud.Transparency = v.Transparency

		local inlet = v:FindFirstChild("NAOldRobloxInlet")
		if not inlet then
			inlet = InstanceNew("Texture")
			inlet.Name = "NAOldRobloxInlet"
			inlet.Parent = v
		end
		inlet.Texture = inletTex
		inlet.Face = Enum.NormalId.Bottom
		inlet.StudsPerTileU = 1
		inlet.StudsPerTileV = 1
		inlet.Transparency = v.Transparency

		v.Material = Enum.Material.Plastic
	end

	NAmanage.SetAttr(Services.Lighting, "NAOldRbx_PrevClockTime", Services.Lighting.ClockTime)
	NAmanage.SetAttr(Services.Lighting, "NAOldRbx_PrevGlobalShadows", Services.Lighting.GlobalShadows)
	local ok,outlines = pcall(function() return Services.Lighting.Outlines end)
	if ok then NAmanage.SetAttr(Services.Lighting, "NAOldRbx_HadOutlines", true) NAmanage.SetAttr(Services.Lighting, "NAOldRbx_PrevOutlines", outlines) end

	const stash = Services.Workspace:FindFirstChild("NAOldRbx_SkyStash") or InstanceNew("Folder")
	stash.Name = "NAOldRbx_SkyStash"
	stash.Parent = Services.Workspace
	for _,v in __lt.cm("Lighting", "GetChildren") do
		if v:IsA("Sky") then
			const c = v:Clone()
			c.Parent = stash
			v:Destroy()
		end
	end

	Services.Lighting.ClockTime = 12
	pcall(function() Services.Lighting.GlobalShadows = false end)
	pcall(function() Services.Lighting.Outlines = false end)
	ensureSky()

	const RS = SafeGetService("RunService")

	const q = {head = 1, tail = 0, data = {}}
	const function qpush(x) q.tail += 1; q.data[q.tail] = x end
	const function qpop() const i = q.head; if i > q.tail then return nil end; const x = q.data[i]; q.data[i] = nil; q.head = i + 1; return x end
	for _,child in Services.Workspace:GetChildren() do qpush(child) end

	NAlib.disconnect("oldrbx_tick")
	NAlib.connect("oldrbx_tick", RS.Heartbeat:Connect(function()
		if not NAmanage.GetAttr(Services.Lighting, "NAOldRbx_Enabled") then return end
		const budgetNodes = 200
		local i = 0
		while i < budgetNodes do
			const node = qpop()
			if not node then break end
			if node.Parent then
				if node:IsA("BasePart") then
					applyToPart(node)
					i += 1
				end
				for _,c in node:GetChildren() do
					qpush(c)
				end
			end
		end
	end))

	NAlib.disconnect("oldrbx_desc")
	NAlib.connect("oldrbx_desc", NAmanage.wsAdd(function(obj)
		if not NAmanage.GetAttr(Services.Lighting, "NAOldRbx_Enabled") then return end
		if obj:IsA("BasePart") then
			qpush(obj)
		end
	end))

	NAlib.disconnect("oldrbx_skywatch")
	NAlib.connect("oldrbx_skywatch", NAmanage.childAdd(Services.Lighting, function(obj)
		if not NAmanage.GetAttr(Services.Lighting, "NAOldRbx_Enabled") then return end
		if obj:IsA("Sky") and obj.Name ~= "NAOldRobloxSky" then
			const c = obj:Clone()
			c.Parent = stash
			obj:Destroy()
			ensureSky()
		end
	end, function(obj)
		return obj and obj:IsA("Sky")
	end))

	NAlib.disconnect("oldrbx_skyguard")
	NAlib.connect("oldrbx_skyguard", NAmanage.childRem(Services.Lighting, function(obj)
		if not NAmanage.GetAttr(Services.Lighting, "NAOldRbx_Enabled") then return end
		if obj:IsA("Sky") and not __lt.cm("Lighting", "FindFirstChild", "NAOldRobloxSky") then
			ensureSky()
		end
	end, function(obj)
		return obj and obj:IsA("Sky")
	end))
end)

cmd.add({"unoldroblox"},{"unoldroblox","Restore skybox and studs"},function()
	if not NAmanage.GetAttr(Services.Lighting, "NAOldRbx_Enabled") then return end

	NAlib.disconnect("oldrbx_desc")
	NAlib.disconnect("oldrbx_skywatch")
	NAlib.disconnect("oldrbx_skyguard")
	NAlib.disconnect("oldrbx_tick")

	const RS = SafeGetService("RunService")

	const rq = {head = 1, tail = 0, data = {}}
	const function rpush(x) rq.tail += 1; rq.data[rq.tail] = x end
	const function rpop() const i = rq.head; if i > rq.tail then return nil end; const x = rq.data[i]; rq.data[i] = nil; rq.head = i + 1; return x end
	for _,child in Services.Workspace:GetChildren() do rpush(child) end

	NAlib.disconnect("oldrbx_untick")
	NAlib.connect("oldrbx_untick", RS.Heartbeat:Connect(function()
		const budgetNodes = 200
		local i = 0
		while i < budgetNodes do
			const node = rpop()
			if not node then break end
			if node.Parent then
				if node:IsA("BasePart") and NAmanage.GetAttr(node, "NAOldRbx_Applied") then
					const a = node:FindFirstChild("NAOldRobloxStud"); if a then a:Destroy() end
					const b = node:FindFirstChild("NAOldRobloxInlet"); if b then b:Destroy() end
					const matName = NAmanage.GetAttr(node, "NAOldRbx_OrigMatName")
					if typeof(matName) == "string" then
						const mat = Enum.Material[matName]
						if mat then pcall(function() node.Material = mat end) end
					end
					NAmanage.SetAttr(node, "NAOldRbx_Applied", nil)
					NAmanage.SetAttr(node, "NAOldRbx_OrigMatName", nil)
					i += 1
				end
				for _,c in node:GetChildren() do
					rpush(c)
				end
			end
		end

		if rq.head > rq.tail then
			NAlib.disconnect("oldrbx_untick")

			for _,v in __lt.cm("Lighting", "GetChildren") do
				if v:IsA("Sky") and v.Name == "NAOldRobloxSky" then
					v:Destroy()
				end
			end
			const stash = Services.Workspace:FindFirstChild("NAOldRbx_SkyStash")
			if stash then
				for _,c in stash:GetChildren() do
					if c:IsA("Sky") then
						c.Parent = Services.Lighting
					end
				end
				stash:Destroy()
			end

			const prevClock = NAmanage.GetAttr(Services.Lighting, "NAOldRbx_PrevClockTime")
			const prevShadows = NAmanage.GetAttr(Services.Lighting, "NAOldRbx_PrevGlobalShadows")
			if typeof(prevClock) == "number" then pcall(function() Services.Lighting.ClockTime = prevClock end) end
			if typeof(prevShadows) == "boolean" then pcall(function() Services.Lighting.GlobalShadows = prevShadows end) end
			if NAmanage.GetAttr(Services.Lighting, "NAOldRbx_HadOutlines") then
				const prevOut = NAmanage.GetAttr(Services.Lighting, "NAOldRbx_PrevOutlines")
				pcall(function() Services.Lighting.Outlines = prevOut end)
			end

			NAmanage.SetAttr(Services.Lighting, "NAOldRbx_Enabled", nil)
			NAmanage.SetAttr(Services.Lighting, "NAOldRbx_PrevClockTime", nil)
			NAmanage.SetAttr(Services.Lighting, "NAOldRbx_PrevGlobalShadows", nil)
			NAmanage.SetAttr(Services.Lighting, "NAOldRbx_HadOutlines", nil)
			NAmanage.SetAttr(Services.Lighting, "NAOldRbx_PrevOutlines", nil)
		end
	end))
end)

NAmanage.LoadLegacyYear = function(year)
	year = math.clamp(math.floor(tonumber(year) or 2016), 2012, 2016)
	_na_boot.hostEnv.LegacySettings = {
		Year = year,
		OldGraphics = true,
		HideDisplayName = true,
	}

	local okBody, body, bodyErr = NAmanage.HttpGet("https://raw.githubusercontent.com/yeku/legacy/refs/heads/main/Source.luau", { timeout = 10 })
	if not okBody then
		DoNotif("Failed to load "..tostring(year).." CoreGui: "..tostring(bodyErr), 3)
		return
	end

	local okRun, runErr = NAmanage.RunSourceInEnv(body, "@Legacy"..tostring(year)..".luau", _na_boot.hostEnv)
	if not okRun then
		DoNotif("Failed to load "..tostring(year).." CoreGui: "..tostring(runErr), 3)
	end
end

cmd.add({"2012"},{"2012","Makes your Pedoblox CoreGui look like the 2012 CoreGui"},function()
	NAmanage.LoadLegacyYear(2012)
end)

cmd.add({"2013"},{"2013","Makes your Pedoblox CoreGui look like the 2013 CoreGui"},function()
	NAmanage.LoadLegacyYear(2013)
end)

cmd.add({"2014"},{"2014","Makes your Pedoblox CoreGui look like the 2014 CoreGui"},function()
	NAmanage.LoadLegacyYear(2014)
end)

cmd.add({"2015"},{"2015","Makes your Pedoblox CoreGui look like the 2015 CoreGui"},function()
	NAmanage.LoadLegacyYear(2015)
end)

cmd.add({"2016"},{"2016","Makes your Pedoblox CoreGui look like the 2016 CoreGui"},function()
	NAmanage.LoadLegacyYear(2016)
end)

cmd.add({"f3x","fex"},{"f3x (fex)","F3X for client"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/F3X.luau", true, "@F3X.luau")
end)

cmd.add({"telekinesis"},{"telekinesis","tool that controls unanchored parts (depending if you have ownership of that part)"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Telekinesis.luau", true, "@Telekinesis.luau")
end)


cmd.add({"triggerbot", "tbot"}, {"triggerbot (tbot)", "Executes a script that automatically clicks the mouse when the mouse is on a player"}, function()
	NAStuff = NAStuff or {}
	const CONN_KEY = "triggerbot"

	if NAlib.isConnected(CONN_KEY) then
		NAlib.disconnect(CONN_KEY)
		if NAStuff._triggerbotGui then
			pcall(function() NAStuff._triggerbotGui:Destroy() end)
			NAStuff._triggerbotGui = nil
		end
		DoNotif("Triggerbot disabled", 2, "TriggerBot")
		return
	end
	NAlib.disconnect(CONN_KEY)
	if NAStuff._triggerbotGui then
		pcall(function() NAStuff._triggerbotGui:Destroy() end)
		NAStuff._triggerbotGui = nil
	end

	const ToggleKey = Enum.KeyCode.Z
	const FieldOfView = 10

	const UIS = Services.UserInputService
	const Camera = Services.Workspace.CurrentCamera

	const Player = Services.Players.LocalPlayer
	const Mouse = NAmanage.GetMouse(Player)
	local Toggled = false
	local Mode = "FFA"
	local LastMode = nil

	const GUI = InstanceNew("ScreenGui")
	const On = InstanceNew("TextLabel")
	const uicorner = InstanceNew("UICorner")
	uicorner.CornerRadius = UDim.new(0, 6)
	NAgui.NaProtectUI(GUI)
	NAStuff._triggerbotGui = GUI
	On.Parent = GUI
	On.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
	On.BackgroundTransparency = 0.14
	On.BorderSizePixel = 0
	On.Position = UDim2.new(0.88, 0, 0.33, 0)
	On.Size = UDim2.new(0, 160, 0, 20)
	On.Font = Enum.Font.SourceSans
	On.Text = "TriggerBot On: false (Key: Q)"
	On.TextColor3 = Color3.new(1, 1, 1)
	On.TextScaled = true
	On.TextSize = 14
	On.TextWrapped = true
	uicorner.Parent = On

	const function IsInFieldOfView(target)
		const targetPosition = target.Position
		local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPosition)
		if onScreen then
			const mousePosition = Vector2.new(Mouse.X, Mouse.Y)
			const targetScreenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
			const distance = (mousePosition - targetScreenPosition).Magnitude
			return distance <= FieldOfView
		end
		return false
	end

	const function IsEnemy(otherPlayer)
		if Mode == "FFA" then
			return true
		else
			return otherPlayer.Team ~= nil and Player.Team ~= nil and otherPlayer.Team ~= Player.Team
		end
	end

	const function GetClosestPlayer()
		for _, otherPlayer in __lt.cm("Players", "GetPlayers") do
			if otherPlayer ~= Player and IsEnemy(otherPlayer) and otherPlayer.Character then
				for _, part in otherPlayer.Character:GetChildren() do
					if part:IsA("BasePart") and IsInFieldOfView(part) then
						return otherPlayer
					end
				end
			end
		end
		return nil
	end

	const function Click()
		mouse1click()
	end

	const function CheckMode()
		if #__lt.cm("Players", "GetPlayers") > 0 and Services.Players.LocalPlayer.Team == nil then
			Mode = "FFA"
		else
			Mode = "Team"
		end

		if Mode ~= LastMode then
			DoNotif("Mode changed to: "..Mode)
			LastMode = Mode
		end
	end

	NAlib.connect(CONN_KEY, UIS.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == ToggleKey then
			Toggled = not Toggled
			On.Text = "TriggerBot On: "..tostring(Toggled).." (Key: "..ToggleKey.Name..")"
		end
	end))

	NAlib.connect(CONN_KEY, Services.RunService.RenderStepped:Connect(function()
		CheckMode()
		if Toggled then
			const targetPlayer = GetClosestPlayer()
			if getPlrHum(targetPlayer) then
				const humanoid = getPlrHum(targetPlayer)
				if humanoid.Health > 0 then
					Click()
				end
			end
		end
	end))

	NAlib.connect(CONN_KEY, GUI.AncestryChanged:Connect(function(_, parent)
		if not parent then
			NAStuff._triggerbotGui = nil
			Defer(function()
				NAlib.disconnect(CONN_KEY)
			end)
		end
	end))

	On.Text = "TriggerBot On: "..tostring(Toggled).." (Key: "..ToggleKey.Name..")"

	DebugNotif("Advanced Trigger Bot Loaded")
end)

NAStuff.stationaryRespawn = NAStuff.stationaryRespawn or false
NAStuff.hasPosition = NAStuff.hasPosition or false
NAStuff.spawnPosition = NAStuff.spawnPosition or CFrame.new()

NAStuff.spawnActive = NAStuff.spawnActive or false
NAStuff.spawnStart = NAStuff.spawnStart or 0
NAStuff.lastChar = NAStuff.lastChar or nil

cmd.add({"setspawn","spawnpoint","ss"},{"setspawn (spawnpoint, ss)","Sets your spawn point to the current character's position"},function()
	if NAlib.isConnected("spawnCONNECTION") and NAlib.isConnected("spawnCHARCON") then
		return DoNotif("spawn point is already running",3)
	end

	const ch = getChar()
	const r = ch and getRoot(ch)
	if not r then
		return DoNotif("failed to get character root",3)
	end

	NAStuff.spawnPosition = NAmanage.UG_clientCFrame(r) or r.CFrame
	NAStuff.hasPosition = true
	NAStuff.stationaryRespawn = true
	DebugNotif("Spawn has been set")

	NAStuff.lastChar = ch
	NAStuff.spawnActive = false
	NAStuff.spawnStart = 0

	const function handleRespawn()
		if not NAStuff.stationaryRespawn or not NAStuff.hasPosition then return end

		const hum = getHum()
		const ch2 = getChar()
		if not hum or not ch2 then return end

		if hum.Health <= 0 then
			NAStuff.spawnActive = false
			NAStuff.spawnStart = 0
			return
		end

		const r2 = getRoot(ch2)
		if not r2 then return end

		if ch2 ~= NAStuff.lastChar then
			NAStuff.lastChar = ch2
			NAStuff.spawnActive = true
			NAStuff.spawnStart = 0
		end

		if not NAStuff.spawnActive then return end

		NAmanage.UG_setClientCFrame(r2, NAStuff.spawnPosition)

		const r2pos = NAmanage.UG_clientPosition(r2) or r2.Position
		const d = (r2pos - NAStuff.spawnPosition.Position).Magnitude
		const now = tick()

		if d < 5 then
			if NAStuff.spawnStart == 0 then
				NAStuff.spawnStart = now
			elseif now - NAStuff.spawnStart >= 1.5 then
				NAStuff.spawnActive = false
				NAStuff.spawnStart = 0
			end
		else
			NAStuff.spawnStart = 0
		end
	end

	NAlib.connect("spawnCONNECTION",Services.RunService.RenderStepped:Connect(handleRespawn))

	NAlib.connect("spawnCHARCON",LocalPlayer.CharacterAdded:Connect(function(ch2)
		NAStuff.lastChar = ch2
		NAStuff.spawnActive = true
		NAStuff.spawnStart = 0
	end))
end)

cmd.add({"disablespawn","unsetspawn","ds"},{"disablespawn (unsetspawn, ds)","Disables the previously set spawn point"},function()
	DebugNotif("Spawn point has been disabled")
	NAlib.disconnect("spawnCONNECTION")
	NAlib.disconnect("spawnCHARCON")
	NAStuff.stationaryRespawn = false
	NAStuff.hasPosition = false
	NAStuff.spawnActive = false
	NAStuff.spawnStart = 0
	NAStuff.lastChar = nil
	NAStuff.spawnPosition = CFrame.new()
end)

NAStuff.adb_on = NAStuff.adb_on or false
NAStuff.adb_done = NAStuff.adb_done or 0

originalIO.adb_try=function()
	if not deathCFrame then return false end
	const t0 = tick()
	local ok0 = 0

	while NAStuff.adb_on and tick() - t0 < 10 do
		const ch = getChar()
		const r = ch and getRoot(ch)
		const h = ch and getHum(ch)

		if r and h and h.Health > 0 then
			NAmanage.UG_setClientCFrame(r, deathCFrame)

			const rpos = NAmanage.UG_clientPosition(r) or r.Position
			const d = (rpos - deathCFrame.Position).Magnitude
			const now = tick()

			if d < 6 then
				if ok0 == 0 then
					ok0 = now
				elseif now - ok0 >= 1.25 then
					return true
				end
			else
				ok0 = 0
			end
		end

		Wait(0.1)
	end

	return false
end

cmd.add({"autoflashback","autodeathpos","deathback","adeath","db"},{"autoflashback","Auto-teleports you to your last death point on respawn"},function()
	if NAlib.isConnected("adb_ca") then
		return DoNotif("auto deathpos is already running",3)
	end

	NAStuff.adb_on = true

	NAlib.connect("adb_ca", LocalPlayer.CharacterAdded:Connect(function()
		if not NAStuff.adb_on then return end
		if tick() < (NAStuff.adb_done or 0) then return end
		if not deathCFrame then return end

		Spawn(function()
			const ok = originalIO.adb_try()
			if ok then
				NAStuff.adb_done = tick() + 4
			end
		end)
	end))

	DebugNotif("Auto deathpos enabled",2)
end)

cmd.add({"unautoflashback","undeathback","unadeath","undb"},{"unautoflashback","Disables auto deathpos"},function()
	DebugNotif("Auto deathpos disabled",2)
	NAlib.disconnect("adb_ca")
	NAStuff.adb_on = false
	NAStuff.adb_done = 0
end)

cmd.add({"flashback", "deathpos", "deathtp", "diedtp"}, {"flashback", "Teleports you to your last death point"}, function()
	if deathCFrame then
		const character = getChar()
		if character and getRoot(character) then
			NAmanage.UG_setClientCFrame(getRoot(character), deathCFrame)
		else
			DebugNotif("Could not teleport, root is missing", 3)
		end
	else
		DebugNotif("No available death location to teleport to! You need to die first", 3)
	end
end)

NAStuff.fba_on = NAStuff.fba_on or false
NAStuff.fba_done = NAStuff.fba_done or 0
NAStuff.fba_cf = NAStuff.fba_cf or nil
NAStuff.fba_safe = NAStuff.fba_safe or nil

NAmanage.fbaSafe = NAmanage.fbaSafe or function(root, hum, char)
	if not root or not hum or hum.Health <= 0 then
		return false
	end
	const state = hum:GetState()
	if state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.Seated then
		return false
	end
	const pos = (NAmanage.UG_clientCFrame and NAmanage.UG_clientCFrame(root) or root.CFrame).Position
	const vel = root.AssemblyLinearVelocity or root.Velocity
	if vel and (vel.Magnitude > 250 or vel.Y < -90) then
		return false
	end
	const fph = tonumber(Services.Workspace.FallenPartsDestroyHeight) or -500
	if pos.Y <= fph + 25 then
		return false
	end
	const params = RaycastParams.new()
	const okType = pcall(function()
		params.FilterType = Enum.RaycastFilterType.Exclude
	end)
	if not okType then
		pcall(function() params.FilterType = Enum.RaycastFilterType.Blacklist end)
	end
	params.FilterDescendantsInstances = char and { char } or {}
	local ok, hit = pcall(function()
		return Services.Workspace:Raycast(pos, Vector3.new(0, -8, 0), params)
	end)
	return ok and hit ~= nil
end

NAmanage.fbaTarget = NAmanage.fbaTarget or function()
	return NAStuff.fba_cf or NAStuff.fba_safe
end

originalIO.fba_try = function()
	const cf = NAmanage.fbaTarget()
	if not cf then return false end
	const t0 = tick()
	local ok0 = 0
	while NAStuff.fba_on and tick() - t0 < 10 do
		const ch = getChar()
		const r = ch and getRoot(ch)
		const h = ch and getHum(ch)
		if r and h and h.Health > 0 then
			NAmanage.UG_setClientCFrame(r, cf)
			const rpos = NAmanage.UG_clientPosition(r) or r.Position
			const d = (rpos - cf.Position).Magnitude
			const now = tick()
			if d < 6 then
				if ok0 == 0 then
					ok0 = now
				elseif now - ok0 >= 1.25 then
					return true
				end
			else
				ok0 = 0
			end
		end
		Wait(0.1)
	end
	return false
end

cmd.add({"flashbackalt", "fba", "safeplace"}, {"flashbackalt (fba)", "Teleports you to the 0 HP flashback point"}, function()
	const cf = NAmanage.fbaTarget()
	if not cf then
		return DebugNotif("No alt flashback point saved yet", 3)
	end
	const character = getChar()
	const root = character and getRoot(character)
	if not root then
		return DebugNotif("Could not teleport, root is missing", 3)
	end
	NAmanage.UG_setClientCFrame(root, cf)
end)

cmd.add({"autoflashbackalt", "autodeathposalt", "deathbackalt", "afba"}, {"autoflashbackalt (afba)", "Auto-teleports you to the 0 HP flashback point on respawn"}, function()
	if NAlib.isConnected("fba_ca") then
		return DoNotif("auto flashback alt is already running", 3)
	end
	NAStuff.fba_on = true
	NAlib.connect("fba_ca", LocalPlayer.CharacterAdded:Connect(function()
		if not NAStuff.fba_on then return end
		if tick() < (NAStuff.fba_done or 0) then return end
		if not NAmanage.fbaTarget() then return end
		Spawn(function()
			const ok = originalIO.fba_try()
			if ok then
				NAStuff.fba_done = tick() + 4
			end
		end)
	end))
	DebugNotif("Auto flashback alt enabled", 2)
end)

cmd.add({"unautoflashbackalt", "unafba", "undeathbackalt"}, {"unautoflashbackalt", "Disables auto flashback alt"}, function()
	DebugNotif("Auto flashback alt disabled", 2)
	NAlib.disconnect("fba_ca")
	NAStuff.fba_on = false
	NAStuff.fba_done = 0
end)

cmd.add({"tospawn", "ts"}, {"tospawn (ts)", "Teleports you to a SpawnLocation"}, function()
	const character = getChar()
	if not character then
		return DebugNotif("Character not found", 3)
	end
	const root = getRoot(character)
	if not root then
		return DebugNotif("Root not found", 3)
	end
	local closestSpawn = nil
	local shortestDistance = math.huge
	const rootPosition = NAmanage.UG_clientPosition(root) or root.Position
	for _, descendant in NAmanage.QueryDescendants(Services.Workspace, "SpawnLocation") do
		const distance = (descendant.Position - rootPosition).Magnitude
		if distance < shortestDistance then
			shortestDistance = distance
			closestSpawn = descendant
		end
	end
	if not closestSpawn then
		return DebugNotif("No SpawnLocation found in workspace", 3)
	end
	NAmanage.UG_setClientCFrame(root, closestSpawn.CFrame * CFrame.new(0, 5, 0))
end)

NAStuff.hamsterState = NAStuff.hamsterState or { active = false }

NAmanage.HamsterCleanup = NAmanage.HamsterCleanup or function(opts)
	opts = opts or {}
	NAlib.disconnect("hamster_render")
	NAlib.disconnect("hamster_jump")
	NAlib.disconnect("hamster_died")

	const state = NAStuff.hamsterState or {}
	const ball = state.ball
	const humanoid = state.humanoid
	const oldCamSubj = state.oldCameraSubject
	const oldCollide = state.oldCollide
	const rootState = state.rootState
	const humanoidState = state.humanoidState

	state.ball = nil
	state.humanoid = nil
	state.oldCameraSubject = nil
	state.oldCollide = nil
	state.rootState = nil
	state.humanoidState = nil
	state.active = false
	NAStuff.hamsterState = state

	if humanoid and humanoid.Parent and type(humanoidState) == "table" then
		if humanoidState.HipHeight ~= nil then
			pcall(function()
				humanoid.HipHeight = humanoidState.HipHeight
			end)
		end
		if humanoidState.PlatformStand ~= nil then
			pcall(function()
				humanoid.PlatformStand = humanoidState.PlatformStand
			end)
		end
		if humanoidState.AutoRotate ~= nil then
			pcall(function()
				humanoid.AutoRotate = humanoidState.AutoRotate
			end)
		end
		if humanoidState.Sit ~= nil then
			pcall(function()
				humanoid.Sit = humanoidState.Sit
			end)
		end
	elseif humanoid and humanoid.Parent then
		pcall(function()
			humanoid.PlatformStand = false
		end)
	end

	if ball and ball.Parent and type(rootState) == "table" then
		if rootState.Shape ~= nil then
			pcall(function()
				ball.Shape = rootState.Shape
			end)
		end
		if rootState.Size ~= nil then
			pcall(function()
				ball.Size = rootState.Size
			end)
		end
		if rootState.Transparency ~= nil then
			pcall(function()
				ball.Transparency = rootState.Transparency
			end)
		end
		if rootState.Material ~= nil then
			pcall(function()
				ball.Material = rootState.Material
			end)
		end
	end

	if oldCamSubj then
		const Camera = Services.Workspace.CurrentCamera
		if Camera then
			pcall(function()
				Camera.CameraSubject = oldCamSubj
			end)
		end
	end

	if oldCollide then
		for part, can in oldCollide do
			if part and part.Parent then
				pcall(function()
					part.CanCollide = can
				end)
			end
		end
	end

	if not opts.silent then
		DebugNotif(opts.message or "Hamster has been disabled")
	end
end

cmd.add({"hamster"}, {"hamster <number>", "Hamster ball"}, function(...)
	if NAStuff.hamsterState.active or NAlib.isConnected("hamster_render") then
		return DebugNotif("Hamster is already enabled")
	end

	const Camera = Services.Workspace.CurrentCamera

	const SPEED_MULTIPLIER = (...) or 30
	const JUMP_POWER = 60
	const JUMP_GAP = 0.3

	const plrs = SafeGetService("Players")
	if not plrs then
		return DebugNotif("Hamster failed: Players service missing")
	end

	const lp = plrs.LocalPlayer
	if not lp then
		return DebugNotif("Hamster failed: LocalPlayer missing")
	end

	const character = lp.Character
	if not character then
		return DebugNotif("Hamster failed: Character missing")
	end

	const humanoid = getHum()
	const ball = getRoot(character)
	if not humanoid or not ball then
		return DebugNotif("Hamster failed: Humanoid or root missing")
	end

	const oldCamSubj = Camera and Camera.CameraSubject or nil
	const oldCollide = {}
	const rootState = {
		Shape = ball.Shape;
		Size = ball.Size;
		Transparency = ball.Transparency;
		Material = ball.Material;
	}
	const humanoidState = {
		HipHeight = humanoid.HipHeight;
		PlatformStand = humanoid.PlatformStand;
		AutoRotate = humanoid.AutoRotate;
		Sit = humanoid.Sit;
	}

	for _, v in character:QueryDescendants("BasePart") do
		oldCollide[v] = v.CanCollide
		v.CanCollide = false
	end

	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(5, 5, 5)

	const params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { character }

	NAStuff.hamsterState.active = true
	NAStuff.hamsterState.ball = ball
	NAStuff.hamsterState.humanoid = humanoid
	NAStuff.hamsterState.oldCameraSubject = oldCamSubj
	NAStuff.hamsterState.oldCollide = oldCollide
	NAStuff.hamsterState.rootState = rootState
	NAStuff.hamsterState.humanoidState = humanoidState

	NAlib.connect("hamster_render", Services.RunService.RenderStepped:Connect(function(delta)
		if not NAStuff.hamsterState.active then
			return
		end
		if not ball or not ball.Parent or not humanoid or not humanoid.Parent then
			return
		end
		ball.CanCollide = true
		humanoid.PlatformStand = true
		if NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive() then
			return
		end

		const moveVec = GetCustomMoveVector()
		if moveVec.Magnitude > 0 then
			const right = Camera.CFrame.RightVector
			const forward = Camera.CFrame.LookVector
			ball.RotVelocity = ball.RotVelocity + (right * moveVec.Z * delta * SPEED_MULTIPLIER)
			ball.RotVelocity = ball.RotVelocity + (forward * moveVec.X * delta * SPEED_MULTIPLIER)
		end
	end))

	NAlib.connect("hamster_jump", Services.UserInputService.JumpRequest:Connect(function()
		if not NAStuff.hamsterState.active then
			return
		end
		if not ball or not ball.Parent then
			return
		end
		const result = Services.Workspace:Raycast(
			ball.Position,
			Vector3.new(0, -((ball.Size.Y / 2) + JUMP_GAP), 0),
			params
		)
		if result then
			ball.Velocity = ball.Velocity + Vector3.new(0, JUMP_POWER, 0)
		end
	end))

	NAlib.connect("hamster_died", NAmanage.ConnectHumanoidDeath(humanoid, function()
		NAmanage.HamsterCleanup({
			silent = true;
		})
	end))

	if Camera then
		Camera.CameraSubject = ball
	end

	DebugNotif("Hamster enabled")
end, true)

cmd.add({"unhamster"}, {"unhamster", "Disable hamster ball"}, function()
	if not NAStuff.hamsterState.active and not NAlib.isConnected("hamster_render") then
		return DebugNotif("Hamster is already disabled")
	end

	NAmanage.HamsterCleanup()
end, true)

NAStuff.antiAFKStored = NAStuff.antiAFKStored or {}
NAStuff.antiAFKVIM = NAStuff.antiAFKVIM or nil

cmd.add({"antiafk","noafk"},{"antiafk (noafk)","Prevents you from being kicked for being AFK"},function()
	if NAlib.isConnected("antiAFK") or NAlib.isConnected("antiAFK_scan") then
		return DebugNotif("Anti AFK is already enabled")
	end

	const antiAFKPlayers = game:GetService("Players")
	local created, antiAFKVIM = pcall(function()
		return Instance.new("VirtualInputManager")
	end)
	if not created or not antiAFKVIM then
		return DebugNotif("Anti AFK failed: VirtualInputManager unavailable")
	end

	const rng = Random.new()
	const KEY = Enum.KeyCode.F15

	const function antiAFKHandler()
		pcall(function()
			antiAFKVIM:SendKeyEvent(true, KEY, false, game)
			Wait(rng:NextNumber(0.04, 0.08))
			antiAFKVIM:SendKeyEvent(false, KEY, false, game)
		end)
	end

	const lp = antiAFKPlayers.LocalPlayer
	if not lp then
		pcall(function()
			antiAFKVIM:Destroy()
		end)
		return DebugNotif("Anti AFK failed: LocalPlayer missing")
	end

	NAStuff.antiAFKVIM = antiAFKVIM
	NAlib.connect("antiAFK", lp.Idled:Connect(antiAFKHandler))
	DebugNotif("Anti AFK enabled")
end)

cmd.add({"unantiafk","unnoafk"},{"unantiafk (unnoafk)","Allows you to be kicked for being AFK"},function()
	local was = false
	if NAlib.isConnected("antiAFK") then
		NAlib.disconnect("antiAFK")
		was = true
	end
	if NAlib.isConnected("antiAFK_scan") then
		NAlib.disconnect("antiAFK_scan")
		was = true
	end

	if NAStuff.antiAFKVIM then
		pcall(function()
			NAStuff.antiAFKVIM:Destroy()
		end)
		NAStuff.antiAFKVIM = nil
		was = true
	end

	if NAStuff.antiAFKStored and #NAStuff.antiAFKStored > 0 then
		for _, info in NAStuff.antiAFKStored do
			const c = info.conn
			const shouldEnable = info.enabled
			if c and shouldEnable ~= false and c.Enable then
				pcall(function()
					c:Enable()
				end)
			end
		end
		NAStuff.antiAFKStored = {}
		was = true
	end

	if was then
		DebugNotif("Anti AFK has been disabled")
	else
		DebugNotif("Anti AFK is already disabled")
	end
end)

NAStuff.tpUI = nil
NAStuff.tpTools = {}

NAmanage._raycastFilterType = NAmanage._raycastFilterType or function(params)
	if not params then
		return
	end
	const ok = pcall(function()
		params.FilterType = Enum.RaycastFilterType.Blacklist
	end)
	if not ok then
		pcall(function()
			params.FilterType = Enum.RaycastFilterType.Exclude
		end)
	end
end

NAmanage._raycastFilterList = NAmanage._raycastFilterList or function(excludeList)
	const filter = {}
	const function add(item)
		if typeof(item) == "Instance" then
			Insert(filter, item)
		elseif type(item) == "table" then
			for _, child in item do
				add(child)
			end
		end
	end
	add(excludeList)
	return filter
end

NAmanage._raycastIsExcluded = NAmanage._raycastIsExcluded or function(inst, excludeList)
	if not (inst and typeof(inst) == "Instance") then
		return false
	end
	const function check(item)
		if typeof(item) == "Instance" then
			return inst == item or inst:IsDescendantOf(item)
		elseif type(item) == "table" then
			for _, child in item do
				if check(child) then
					return true
				end
			end
		end
		return false
	end
	return check(excludeList)
end

NAmanage.GetMouseWorldCFrame = NAmanage.GetMouseWorldCFrame or function(mouse, excludeList, maxDistance)
	if not mouse then
		return nil, nil
	end

	local ok, hit = pcall(function()
		return mouse.Hit
	end)
	if ok and typeof(hit) == "CFrame" then
		return hit, nil
	end
	return nil, nil
end

NAmanage.GetMouseTargetPart = NAmanage.GetMouseTargetPart or function(mouse, excludeList, maxDistance)
	if not mouse then
		return nil, nil
	end

	local ok, target = pcall(function()
		return mouse.Target
	end)
	if ok and target and target:IsA("BasePart") and not NAmanage._raycastIsExcluded(target, excludeList) then
		return target, nil
	end
	return nil, nil
end

NAmanage.ResolveHumanoidModelFromPart = NAmanage.ResolveHumanoidModelFromPart or function(part)
	const RawWorkspace = __lt.gs("Workspace")
	local current = part
	while current and current ~= RawWorkspace do
		if current:IsA("Model") then
			const humanoid = current:FindFirstChildOfClass("Humanoid")
			if humanoid then
				return current, humanoid
			end
		end
		current = current.Parent
	end
	return nil, nil
end

NAmanage._tpTargetFromMouse=function(mouse, char)
	if not mouse then
		return nil
	end

	const hit = NAmanage.GetMouseWorldCFrame(mouse, char and { char } or nil, 1024)
	return hit
end

NAmanage.safePivotModel = function(model, cf)
	if not (model and typeof(cf) == "CFrame") then
		return false
	end

	const st = NAmanage.UG_activeState and NAmanage.UG_activeState() or nil
	if st and NAmanage.UG_isLocalObject and NAmanage.UG_isLocalObject(model) then
		const root = NAmanage.UG_rootForModel and NAmanage.UG_rootForModel(model) or nil
		return NAmanage.UG_setClientCFrame(root, cf)
	end

	const function updateUndergroundState()
		const st = NAStuff and NAStuff.NAundergroundState
		if not (st and st.Underground) then
			return
		end
		const myChar = (typeof(getChar) == "function") and getChar()
		if myChar and typeof(model) == "Instance" and (model == myChar or model:IsDescendantOf(myChar)) then
			st.UndergroundCurrent = cf
		end
	end

	const ok = pcall(function()
		model:PivotTo(cf)
	end)
	if ok then
		updateUndergroundState()
		return true
	end

	local root = model.PrimaryPart or getRoot(model)
	if not root then
		for _, part in NAmanage.QueryDescendants(model, "BasePart") do
			root = part
			break
		end
	end
	if not root then
		return false
	end

	const okRoot = pcall(function()
		root.Anchored = false
		root.CFrame = cf
	end)
	if okRoot then
		updateUndergroundState()
	end
	return okRoot
end

NAmanage.clearAllTP = function()
	if NAStuff.tpUI then
		NAStuff.tpUI:Destroy()
		NAStuff.tpUI = nil
	end
	for _, t in NAStuff.tpTools do
		t:Destroy()
	end
	NAStuff.tpTools = {}
	NAlib.disconnect("tp_down")
	NAlib.disconnect("tp_up")
end

NAmanage.makeClickTweenUI = function()
	NAmanage.clearAllTP()
	const player = Services.Players.LocalPlayer
	const mouse = NAmanage.GetMouse(player)

	NAStuff.tpUI = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(NAStuff.tpUI)

	const clickTpButton = InstanceNew("TextButton")
	clickTpButton.Size = UDim2.new(0,130,0,40)
	clickTpButton.AnchorPoint = Vector2.new(0.5,0)
	clickTpButton.Position = UDim2.new(0.45,0,0.1,0)
	clickTpButton.Text = "Enable Click TP"
	clickTpButton.TextColor3 = Color3.fromRGB(255,255,255)
	clickTpButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
	clickTpButton.BorderSizePixel = 0
	clickTpButton.Parent = NAStuff.tpUI

	const tweenTpButton = clickTpButton:Clone()
	tweenTpButton.Position = UDim2.new(0.55,0,0.1,0)
	tweenTpButton.Text = "Enable Tween TP"
	tweenTpButton.Parent = NAStuff.tpUI

	InstanceNew("UICorner", clickTpButton).CornerRadius = UDim.new(0, 6)
	InstanceNew("UICorner", tweenTpButton).CornerRadius = UDim.new(0, 6)

	local clickEnabled = false
	local tweenEnabled = false
	local initialPos
	const dragThreshold = 10
	const ctTweenState = {
		active = false,
		conn = nil,
		char = nil
	}
	const tweenAttrActive = "NAClickTweenToolActive"
	const tweenAttrStart = "NAClickTweenToolStartCF"
	const tweenAttrTarget = "NAClickTweenToolTargetCF"
	const tweenAttrCurrent = "NAClickTweenToolCurrentCF"

	const function stopActiveTween()
		ctTweenState.active = false
		if ctTweenState.conn then
			ctTweenState.conn:Disconnect()
			ctTweenState.conn = nil
		end
		if ctTweenState.char then
			NAmanage.SetAttr(ctTweenState.char, tweenAttrCurrent, nil)
			NAmanage.SetAttr(ctTweenState.char, tweenAttrActive, false)
		end
		ctTweenState.char = nil
	end

	MouseButtonFix(clickTpButton, function()
		clickEnabled = not clickEnabled
		tweenEnabled = false
		stopActiveTween()
		clickTpButton.Text = clickEnabled and "Disable Click TP" or "Enable Click TP"
		tweenTpButton.Text = "Enable Tween TP"
	end)

	MouseButtonFix(tweenTpButton, function()
		tweenEnabled = not tweenEnabled
		clickEnabled = false
		if not tweenEnabled then
			stopActiveTween()
		end
		tweenTpButton.Text = tweenEnabled and "Disable Tween TP" or "Enable Tween TP"
		clickTpButton.Text = "Enable Click TP"
	end)

	NAlib.connect("tp_down", mouse.Button1Down:Connect(function()
		initialPos = Vector2.new(mouse.X, mouse.Y)
	end))

	NAlib.connect("tp_up", mouse.Button1Up:Connect(function()
		if not initialPos then return end
		const char = player.Character
		if not char then
			initialPos = nil
			return
		end
		const currentPos = Vector2.new(mouse.X, mouse.Y)
		if (currentPos - initialPos).Magnitude <= dragThreshold then
			const hit = NAmanage._tpTargetFromMouse(mouse, char)
			if not hit then
				initialPos = nil
				return
			end
			const target = hit + Vector3.new(0,2.5,0)
			if clickEnabled then
				NAmanage.safePivotModel(char, CFrame.new(target.p))
			elseif tweenEnabled then
				stopActiveTween()
				const duration = math.max(0.01, tonumber(NAmanage.resolveTweenDuration()) or 1)
				const startCF = char:GetPivot()
				const targetCF = CFrame.new(target.p)
				local elapsed = 0
				ctTweenState.active = true
				ctTweenState.char = char
				NAmanage.SetAttr(char, tweenAttrActive, true)
				NAmanage.SetAttr(char, tweenAttrStart, startCF)
				NAmanage.SetAttr(char, tweenAttrTarget, targetCF)
				ctTweenState.conn = Services.RunService.Heartbeat:Connect(function(dt)
					if not ctTweenState.active or not char.Parent then
						stopActiveTween()
						return
					end
					elapsed += dt
					const alpha = math.clamp(elapsed / duration, 0, 1)
					local eased = alpha
					local okEase, easedValue = pcall(function()
						return __lt.cm("TweenService", "GetValue", alpha, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					end)
					if okEase and type(easedValue) == "number" then
						eased = easedValue
					end
					const currentCF = startCF:Lerp(targetCF, eased)
					NAmanage.SetAttr(char, tweenAttrCurrent, currentCF)
					NAmanage.safePivotModel(char, currentCF)
					if alpha >= 1 then
						stopActiveTween()
					end
				end)
			end
		end
		initialPos = nil
	end))

	NAgui.draggerV2(clickTpButton)
	NAgui.draggerV2(tweenTpButton)
end

NAmanage.makeClickTweenTools = function()
	NAmanage.clearAllTP()
	const player = Services.Players.LocalPlayer
	const tweenAttrActive = "NATweenTeleportToolActive"
	const tweenAttrStart = "NATweenTeleportToolStartCF"
	const tweenAttrTarget = "NATweenTeleportToolTargetCF"
	const tweenAttrCurrent = "NATweenTeleportToolCurrentCF"

	const function newTool(name, tween)
		const tool = InstanceNew("Tool")
		tool.Name = name
		tool.RequiresHandle = false
		tool.CanBeDropped = false
		tool.Parent = player.Backpack
		tool.Activated:Connect(function()
			const mouse = NAmanage.GetMouse(player)
			const char = player.Character
			if not (mouse and char) then
				return
			end
			const hit = NAmanage._tpTargetFromMouse(mouse, char)
			if not hit then
				return
			end
			const target = hit + Vector3.new(0,2.5,0)
			if tween then
				const duration = math.max(0.01, tonumber(NAmanage.resolveTweenDuration()) or 1)
				const startCF = char:GetPivot()
				const targetCF = CFrame.new(target.p)
				local elapsed = 0
				NAmanage.SetAttr(char, tweenAttrActive, true)
				NAmanage.SetAttr(char, tweenAttrStart, startCF)
				NAmanage.SetAttr(char, tweenAttrTarget, targetCF)
				local hbConn
				hbConn = Services.RunService.Heartbeat:Connect(function(dt)
					if not char.Parent then
						NAmanage.SetAttr(char, tweenAttrCurrent, nil)
						NAmanage.SetAttr(char, tweenAttrActive, false)
						if hbConn then
							hbConn:Disconnect()
							hbConn = nil
						end
						return
					end
					elapsed += dt
					const alpha = math.clamp(elapsed / duration, 0, 1)
					local eased = alpha
					local okEase, easedValue = pcall(function()
						return __lt.cm("TweenService", "GetValue", alpha, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
					end)
					if okEase and type(easedValue) == "number" then
						eased = easedValue
					end
					const currentCF = startCF:Lerp(targetCF, eased)
					NAmanage.SetAttr(char, tweenAttrCurrent, currentCF)
					NAmanage.safePivotModel(char, currentCF)
					if alpha >= 1 then
						NAmanage.SetAttr(char, tweenAttrCurrent, nil)
						NAmanage.SetAttr(char, tweenAttrActive, false)
						if hbConn then
							hbConn:Disconnect()
							hbConn = nil
						end
					end
				end)
			else
				NAmanage.safePivotModel(char, CFrame.new(target.p))
			end
		end)
		Insert(NAStuff.tpTools, tool)
	end

	newTool("Click TP", false)
	newTool("Tween TP", true)
end

cmd.add({"tptool","clicktptool"},{"tptool","Create click/tween teleport buttons or backpack tools"},function()
	Window({
		Title = "Choose Teleport Mode",
		Description = "Would you like to use on-screen buttons, or equipable Tools in your Backpack?",
		Buttons = {
			{Text="UI Buttons",Callback=NAmanage.makeClickTweenUI},
			{Text="Backpack Tools",Callback=NAmanage.makeClickTweenTools}
		}
	})
end)

cmd.add({"unclicktptool","untptool"},{"unclicktptool","Remove teleport buttons or tools"},function()
	NAmanage.clearAllTP()
end)

if IsOnPC then
	cmd.add({"clickteleport","clicktp"},{"clickteleport","Bind-only click teleport (hold bind + left click)"},function()
		DoNotif("Go to Settings > Command Keybinds and bind clickteleport (or clicktp), then hold that bind and left click.", 4, "Click Teleport")
	end)

	cmd.add({"clickdelete","clickdel"},{"clickdelete","Bind-only click delete (hold bind + left click)"},function()
		DoNotif("Go to Settings > Command Keybinds and bind clickdelete (or clickdel), then hold that bind and left click.", 4, "Click Delete")
	end)
end

cmd.add({"thru"},{"thru <distance>","Move forward by distance"},function(distance)
	const char = getChar()
	const root = char and getRoot(char)
	if not root then
		return DoNotif("Thru failed: character root not found", 2)
	end

	local num = tonumber(distance) or 5
	if num < 1 then
		num = 1
	end
	const rootCF = NAmanage.UG_clientCFrame(root) or root.CFrame
	const look = rootCF.LookVector
	local targetPos = rootCF.Position + (look * num)

	if Services.Workspace and Services.Workspace.Raycast and look.Magnitude > 0 then
		const params = RaycastParams.new()
		NAmanage._raycastFilterType(params)
		params.FilterDescendantsInstances = { char }
		params.IgnoreWater = true

		const rootSize = NAlib.isProperty(root, "Size") or Vector3.new(2, 2, 1)
		const clearance = math.max(3, math.max(math.abs(rootSize.X), math.abs(rootSize.Z)) + 1.5)
		const scanDistance = math.max(num + clearance, clearance + 4)
		const origin = rootCF.Position + Vector3.new(0, math.min(math.max(rootSize.Y * 0.15, 0), 1), 0)
		const hit = Services.Workspace:Raycast(origin, look * scanDistance, params)
		if hit and hit.Position then
			const probeDistance = math.max(num + clearance, clearance + 12)
			const farOrigin = hit.Position + (look * probeDistance)
			const backHit = Services.Workspace:Raycast(farOrigin, -look * (probeDistance + clearance), params)
			if backHit and backHit.Position then
				targetPos = backHit.Position + (look * clearance)
			else
				targetPos = hit.Position + (look * math.max(num, clearance))
			end
		end
	end

	const targetCF = CFrame.new(targetPos, targetPos + look)

	if char and NAmanage.safePivotModel then
		if not NAmanage.safePivotModel(char, targetCF) then
			NAmanage.UG_setRootCFrame(root, targetCF)
		end
	else
		NAmanage.UG_setRootCFrame(root, targetCF)
	end
end)

cmd.add({"olddex"},{"olddex","Using this you can see the parts / guis / scripts etc with this. A really good and helpful script."},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DexByMoonMobile")
end)

cmd.add({"dex"},{"dex","Better version of dex"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DexPlusBackup.luau")
end)

cmd.add({"minimap"},{"minimap","just a minimap lol"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/minimap.luau")
end)

cmd.add({"animationplayer","animplayer", "aplayer","animp"},{"animationplayer","dropdown menu with all the animations the game has to be played"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/AnimPlayer.luau");
end)

cmd.add({"decompiler"},{"decompiler","Choose lua.expert or Luacid to decompile LocalScript/ModuleScript bytecode"},function()
	const function installDecompiler(provider: string)
		Spawn(function()
			assert(getscriptbytecode, "Exploit not supported.")
			assert(opt and type(opt.NAREQUEST) == "function", "HTTP request not supported.")

			const useLuacid = provider == "Luacid"
			const API: string = useLuacid and "https://api.luacid.dev/decompile" or "https://api.lua.expert/decompile"
			const minimumDelay = useLuacid and 1 or .6
			local last_call = 0
			const function encodeBase64(data: string): string
				if type(base64_encode) == "function" then
					return base64_encode(data)
				end
				const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
				return ((data:gsub(".", function(x)
					local bits, byte = "", x:byte()
					for i = 8, 1, -1 do
						bits = bits .. (byte % 2 ^ i - byte % 2 ^ (i - 1) > 0 and "1" or "0")
					end
					return bits
				end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
					if #x < 6 then
						return ""
					end
					local c = 0
					for i = 1, 6 do
						c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
					end
					return chars:sub(c + 1, c + 1)
				end) .. ({ "", "==", "=" })[#data % 3 + 1])
			end
			function decompile(scriptPath: Script | ModuleScript | LocalScript): string
				local success: boolean, bytecode: string = NACaller(getscriptbytecode, scriptPath)

				if (not success) then
					return "-- failed to read script bytecode\n--[[\n" .. tostring(bytecode) .. "\n--]]"
				end
				if type(bytecode) ~= "string" or bytecode == "" then
					return "-- failed to read script bytecode\n--[[\nempty bytecode\n--]]"
				end

				const time_elapsed = os.clock() - last_call
				if time_elapsed <= minimumDelay then
					Wait(minimumDelay - time_elapsed)
				end

				local body = bytecode
				local contentType = "application/octet-stream"
				if not useLuacid then
					body = Services.HttpService:JSONEncode({
						script = encodeBase64(bytecode)
					})
					contentType = "application/json"
				end

				const httpResult = opt.NAREQUEST({
					Url = API,
					Body = body,
					Method = "POST",
					Headers = {
						["content-type"] = contentType
					},
				})
				last_call = os.clock()

				if (not httpResult or httpResult.StatusCode ~= 200) then
					return "-- "..provider.." api request error\n--[[\n" .. tostring(httpResult and httpResult.Body or "no response") .. "\n--]]"
				else
					return httpResult.Body
				end
			end

			function disassemble(scriptPath: Script | ModuleScript | LocalScript): string
				return "-- "..provider.." does not provide a Luau disassemble endpoint."
			end

			_na_env.decompile = decompile
			_na_env.disassemble = disassemble
			DoNotif(provider.." decompiler selected.", 3, "Decompiler")

			-- API docs: https://lua.expert/docs and https://luacid.dev/docs
		end)
	end

	Window({
		Title = "Decompiler";
		Description = "Choose which decompiler should handle decompile(script).";
		Buttons = {
			{
				Text = "lua.expert";
				Callback = function()
					installDecompiler("lua.expert")
				end;
			};
			{
				Text = "Luacid";
				Callback = function()
					installDecompiler("Luacid")
				end;
			};
		};
	})
	--NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/WompWomp.lua")
end)

cmd.add({"getidfromusername","gidu"},{"getidfromusername (gidu)","Copy a user's UserId by Username"}, function(thingy)
	local idd, label = NAmanage.NAClientResolveUserId(thingy)
	if not idd then return DoNotif("err: unable to resolve user") end
	if not setclipboard then return DoNotif("no setclipboard") end
	setclipboard(tostring(idd))
	DebugNotif("Copied "..tostring(label or thingy).."'s UserId: "..tostring(idd))
end,true)

cmd.add({"getuserfromid","guid"},{"getuserfromid (guid)","Copy a user's Username by ID"}, function(thingy)
	local s,naem=NACaller(function()
		return __lt.cm("Players", "GetNameFromUserIdAsync", thingy)
	end)

	if not s then return DoNotif("err: "..tostring(naem)) end

	if not setclipboard then return DoNotif("no setclipboard") end
	setclipboard(tostring(naem))

	DebugNotif("Copied "..tostring(naem).."'s Username with ID of "..tostring(thingy))
end,true)

cmd.add({"ownerid"},{"ownerid","masks you as the game owner's ID and Username"},function()
	local ownerUserId, ownerName
	if game.CreatorType == Enum.CreatorType.User then
		ownerUserId = game.CreatorId
	elseif game.CreatorType == Enum.CreatorType.Group then
		local ok, info = pcall(function() return SafeGetService("GroupService",false):GetGroupInfoAsync(game.CreatorId) end)
		if ok and info then
			if info.Owner and info.Owner.Id then ownerUserId = info.Owner.Id end
			if not ownerUserId and info.OwnerId then ownerUserId = info.OwnerId end
		end
	end
	if not ownerUserId then DebugNotif("Owner not found",3) return end
	local ok2, nameOrErr = pcall(function() return __lt.cm("Players", "GetNameFromUserIdAsync", ownerUserId) end)
	if ok2 and nameOrErr and nameOrErr ~= "" then ownerName = nameOrErr else ownerName = "unknown" end
	opt.hiddenprop(LocalPlayer, "UserId", ownerUserId)
	opt.hiddenprop(LocalPlayer, "Name", ownerName)
end)

cmd.add({"userid"},{"userid <id>","changes your UserId to any ID you enter"},function(...)
	const arg = ({...})[1]
	if not arg or arg == "" then
		DebugNotif("usage: userid <userId|username>",3)
		return nil
	end
	const text = tostring(arg):gsub("^%s+",""):gsub("%s+$","")
	local resolvedId

	const asNum = tonumber(text)
	if asNum then
		if asNum < 1 or asNum ~= math.floor(asNum) then
			DebugNotif("invalid userId",3)
			return nil
		end
		local ok, _ = pcall(function() return __lt.cm("Players", "GetNameFromUserIdAsync", asNum) end)
		if not ok then
			DebugNotif("invalid userId (not found)",3)
			return nil
		end
		resolvedId = asNum
	else
		const uid = NAmanage.NAClientResolveUserId(text)
		if not uid then
			DebugNotif("invalid username or player selector",3)
			return nil
		end
		local ok2, _ = pcall(function() return __lt.cm("Players", "GetNameFromUserIdAsync", uid) end)
		if not ok2 then
			DebugNotif("resolved user invalid",3)
			return nil
		end
		resolvedId = uid
	end

	if resolvedId then
		opt.hiddenprop(LocalPlayer, "UserId", resolvedId)
		return resolvedId
	end

	return nil
end)

cmd.add({"username","name"},{"username <name>","changes your Username to any name you enter"},function(...)
	const arg = ({...})[1]
	if not arg or arg == "" then
		return DebugNotif("missing argument",3)
	end
	opt.hiddenprop(LocalPlayer, "Name", arg)
end)

NAmanage.ClientIdSpoofEnsureHook = function()
	const getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	const setReadOnly = setreadonly or (make_writeable and function(t, ro)
		if ro then
			make_readonly(t)
		else
			make_writeable(t)
		end
	end)
	if type(getRawMetatable) ~= "function" or type(setReadOnly) ~= "function" or type(newcclosure) ~= "function" or type(getnamecallmethod) ~= "function" then
		return false, "executor does not support required hook functions"
	end
	const mt = getRawMetatable(game)
	if not mt or type(mt.__namecall) ~= "function" then
		return false, "unable to access game metatable __namecall"
	end

	if NAStuff.ClientIdSpoofHooked == true and mt.__namecall == NAStuff.ClientIdSpoofHookRef and NAStuff.ClientIdSpoofOldNamecall then
		return true
	end

	NAStuff.ClientIdSpoofOldNamecall = mt.__namecall
	local hookRef
	hookRef = newcclosure(function(self, ...)
		const method = getnamecallmethod()
		if NAStuff.ClientIdSpoofEnabled == true and method == "GetClientId" then
			return NAStuff.ClientIdSpoofValue
		end
		return NAStuff.ClientIdSpoofOldNamecall(self, ...)
	end)
	setReadOnly(mt, false)
	mt.__namecall = hookRef
	setReadOnly(mt, true)
	NAStuff.ClientIdSpoofHookRef = hookRef
	NAStuff.ClientIdSpoofHooked = true
	return true
end

NAmanage.ClientIdSpoofDisable = function()
	NAStuff.ClientIdSpoofEnabled = false
	NAStuff.ClientIdSpoofValue = nil

	const getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	const setReadOnly = setreadonly or (make_writeable and function(t, ro)
		if ro then
			make_readonly(t)
		else
			make_writeable(t)
		end
	end)
	if type(getRawMetatable) ~= "function" or type(setReadOnly) ~= "function" then
		NAStuff.ClientIdSpoofHooked = false
		NAStuff.ClientIdSpoofHookRef = nil
		NAStuff.ClientIdSpoofOldNamecall = nil
		return false, "unable to restore metatable on this executor"
	end

	const mt = getRawMetatable(game)
	if mt and NAStuff.ClientIdSpoofHookRef and NAStuff.ClientIdSpoofOldNamecall and mt.__namecall == NAStuff.ClientIdSpoofHookRef then
		setReadOnly(mt, false)
		mt.__namecall = NAStuff.ClientIdSpoofOldNamecall
		setReadOnly(mt, true)
	end
	NAStuff.ClientIdSpoofHooked = false
	NAStuff.ClientIdSpoofHookRef = nil
	NAStuff.ClientIdSpoofOldNamecall = nil
	return true
end

cmd.add({"spoofclientid","spoofclid"}, {"spoofclientid <value> (spoofclid)", "Spoofs GetClientId() to the value you provide"}, function(value)
	const spoofValue = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if spoofValue == "" then
		DoNotif("Usage: spoofclientid <value>", 2, "ClientID")
		return
	end
	local ok, err = NAmanage.ClientIdSpoofEnsureHook()
	if not ok then
		DoNotif("Failed to spoof ClientID: "..tostring(err), 3, "ClientID")
		return
	end
	NAStuff.ClientIdSpoofValue = spoofValue
	NAStuff.ClientIdSpoofEnabled = true
	DoNotif("ClientID spoofed.", 2, "ClientID")
end, true)

cmd.add({"unspoofclientid","unspoofclid"}, {"unspoofclientid (unspoofclid)", "Restores normal GetClientId() behavior"}, function()
	if NAStuff.ClientIdSpoofEnabled ~= true and NAStuff.ClientIdSpoofHooked ~= true then
		DoNotif("ClientID spoof is not enabled.", 2, "ClientID")
		return
	end
	local ok, err = NAmanage.ClientIdSpoofDisable()
	if ok then
		DoNotif("ClientID spoof disabled.", 2, "ClientID")
	else
		DoNotif("ClientID spoof flag disabled, but restore may be incomplete: "..tostring(err), 3, "ClientID")
	end
end)

cmd.add({"synapsedex","sdex"},{"synapsedex (sdex)","Loads SynapseX's dex explorer"},function()
	const rng=Random.new()

	const charset={}
	for i=48,57 do Insert(charset,string.char(i)) end
	for i=65,90 do Insert(charset,string.char(i)) end
	for i=97,122 do Insert(charset,string.char(i)) end
	function RandomCharacters(length)
		if length>0 then
			return RandomCharacters(length-1)..charset[rng:NextInteger(1,#charset)]
		else
			return ""
		end
	end

	const Dex=game:GetObjects("rbxassetid://9553291002")[1]
	Dex.Name=RandomCharacters(rng:NextInteger(5,20))
	NAgui.NaProtectUI(Dex)

	function Load(Obj,Url)
		function GiveOwnGlobals(Func,Script)
			const Fenv={}
			const RealFenv={script=Script}
			const FenvMt={}
			FenvMt.__index=function(a,b)
				if RealFenv[b]==nil then
					return getfenv()[b]
				else
					return RealFenv[b]
				end
			end
			FenvMt.__newindex=function(a,b,c)
				if RealFenv[b]==nil then
					getfenv()[b]=c
				else
					RealFenv[b]=c
				end
			end
			setmetatable(Fenv,FenvMt)
			setfenv(Func,Fenv)
			return Func
		end

		function LoadScripts(Script)
			if Script.ClassName=="Script" or Script.ClassName=="LocalScript" then
				Spawn(function()
					GiveOwnGlobals(loadstring(Script.Source,"="..Script:GetFullName()),Script)()
				end)
			end
			for i,v in Script:GetChildren() do
				LoadScripts(v)
			end
		end

		LoadScripts(Obj)
	end

	Load(Dex)
end)

cmd.add({"antifling"},{"antifling","makes other players non-collidable with you"},function()
	NAlib.disconnect("antifling")
	NAlib.disconnect("antifling_players")

	NAStuff._afTracked = NAStuff._afTracked or {}
	NAStuff._afOrigCan = NAStuff._afOrigCan or {}
	NAStuff._afSignals = NAStuff._afSignals or {}

	const tracked = NAStuff._afTracked
	const orig = NAStuff._afOrigCan
	const sigs = NAStuff._afSignals

	const lp = Services.Players.LocalPlayer
	if not lp then
		DebugNotif("Antifling: LocalPlayer missing")
		return
	end

	const function clearPart(p)
		if tracked[p] then
			tracked[p] = nil
		end
		if orig[p] ~= nil then
			orig[p] = nil
		end
		if sigs[p] then
			const c = sigs[p]
			sigs[p] = nil
			if c and c.Disconnect then
				c:Disconnect()
			end
		end
	end

	const function apply(p)
		if not (p and typeof(p) == "Instance" and p:IsA("BasePart")) or tracked[p] then
			return
		end
		tracked[p] = true
		if orig[p] == nil then
			orig[p] = NAlib.isProperty(p, "CanCollide")
		end
		if not sigs[p] then
			sigs[p] = p:GetPropertyChangedSignal("CanCollide"):Connect(function()
				if tracked[p] and NAlib.isProperty(p, "CanCollide") ~= false then
					NAlib.setProperty(p, "CanCollide", false)
				end
			end)
		end
		if NAlib.isProperty(p, "CanCollide") ~= false then
			NAlib.setProperty(p, "CanCollide", false)
		end
	end

	const function seedChar(char)
		if not char then
			return
		end
		for _, d in char:QueryDescendants("BasePart") do
			apply(d)
		end
		NAlib.connect("antifling", NAmanage.descAdd(char, function(inst)
			if inst:IsA("BasePart") then
				apply(inst)
			end
		end, function(inst)
			return inst and inst:IsA("BasePart")
		end))
		NAlib.connect("antifling", NAmanage.descRem(char, function(inst)
			if inst:IsA("BasePart") then
				clearPart(inst)
			end
		end, function(inst)
			return inst and inst:IsA("BasePart")
		end))
	end

	const function cleanupChar(char)
		if not char then
			return
		end
		for _, d in NAmanage.QueryDescendants(char, "Instance") do
			if tracked[d] then
				clearPart(d)
			end
		end
	end

	const function hookOther(plr)
		if plr == lp then
			return
		end
		if plr.Character then
			seedChar(plr.Character)
		end
		NAlib.connect("antifling_players", plr.CharacterAdded:Connect(function(char)
			seedChar(char)
		end))
		NAlib.connect("antifling_players", plr.CharacterRemoving:Connect(function(char)
			cleanupChar(char)
		end))
	end

	for _, pl in __lt.cm("Players", "GetPlayers") do
		hookOther(pl)
	end

	NAlib.connect("antifling_players", Services.Players.PlayerAdded:Connect(hookOther))
	NAlib.connect("antifling_players", Services.Players.PlayerRemoving:Connect(function(pl)
		if pl == lp then
			return
		end
		cleanupChar(pl.Character)
	end))

	local lastKey = nil
	const quotaPerStep = 256

	NAlib.connect("antifling", Services.RunService.PreSimulation:Connect(function()
		const t = tracked
		if not t then
			return
		end

		local quota = quotaPerStep

		local k = lastKey
		if k ~= nil and t[k] == nil then
			k = nil
		end

		while quota > 0 do
			k = next(t, k)
			if not k then
				lastKey = nil
				break
			end

			const p = k

			if typeof(p) == "Instance" and p:IsA("BasePart") and p.Parent then
				if NAlib.isProperty(p, "CanCollide") ~= false then
					NAlib.setProperty(p, "CanCollide", false)
				end
				lastKey = p
			else
				clearPart(p)
				lastKey = nil
			end

			quota = quota - 1
		end
	end))

	DebugNotif("Antifling Enabled")
end)

cmd.add({"unantifling"},{"unantifling","restores collision for other players"},function()
	NAlib.disconnect("antifling")
	NAlib.disconnect("antifling_players")

	const tracked = NAStuff._afTracked or {}
	const orig = NAStuff._afOrigCan or {}
	const sigs = NAStuff._afSignals or {}

	for p in tracked do
		if typeof(p) == "Instance" and p:IsA("BasePart") then
			local v = orig[p]
			if v == nil then
				v = true
			end
			NAlib.setProperty(p, "CanCollide", v)
		end
	end

	for _, c in sigs do
		if c and c.Disconnect then
			c:Disconnect()
		end
	end

	for k in sigs do
		sigs[k] = nil
	end
	for k in tracked do
		tracked[k] = nil
	end
	for k in orig do
		orig[k] = nil
	end

	DebugNotif("Antifling Disabled")
end)

cmd.add({"antiflingparts","antiunanchoredfling","afparts"},{"antiflingparts [linearVelocity] [angularVelocity]","Disables collision on nearby unanchored non-player parts above the velocity threshold"},function(...)
	NAlib.disconnect("antifling_parts")
	NAlib.disconnect("antifling_parts_scan")

	const args = {...}
	NAStuff._afpTracked = NAStuff._afpTracked or {}
	NAStuff._afpOrigCan = NAStuff._afpOrigCan or {}
	NAStuff._afpSignals = NAStuff._afpSignals or {}

	const tracked = NAStuff._afpTracked
	const orig = NAStuff._afpOrigCan
	const sigs = NAStuff._afpSignals

	const LINEAR_THREAT = math.max(1, tonumber(args[1]) or 60)
	const ANGULAR_THREAT = math.max(1, tonumber(args[2]) or 40)
	const LINEAR_RELEASE = math.max(1, LINEAR_THREAT * 0.55)
	const ANGULAR_RELEASE = math.max(1, ANGULAR_THREAT * 0.55)
	const DISTANCE_LIMIT = 80
	const NEARBY_SCAN_MAX = 96
	const TRACK_QUOTA = 72
	const LINEAR_THREAT_SQ = LINEAR_THREAT * LINEAR_THREAT
	const ANGULAR_THREAT_SQ = ANGULAR_THREAT * ANGULAR_THREAT
	const LINEAR_RELEASE_SQ = LINEAR_RELEASE * LINEAR_RELEASE
	const ANGULAR_RELEASE_SQ = ANGULAR_RELEASE * ANGULAR_RELEASE
	const DISTANCE_LIMIT_SQ = DISTANCE_LIMIT * DISTANCE_LIMIT
	local overlapParams = nil

	pcall(function()
		const params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.MaxParts = NEARBY_SCAN_MAX
		overlapParams = params
	end)

	const function velocitySquared(part)
		const assemblyVel = NAlib.isProperty(part, "AssemblyLinearVelocity")
		const legacyVel = NAlib.isProperty(part, "Velocity")
		local bestSq = 0
		if typeof(assemblyVel) == "Vector3" then
			bestSq = assemblyVel:Dot(assemblyVel)
		end
		if typeof(legacyVel) == "Vector3" then
			const legacySq = legacyVel:Dot(legacyVel)
			if legacySq > bestSq then
				bestSq = legacySq
			end
		end
		return bestSq
	end

	const function angularVelocitySquared(part)
		const assemblyVel = NAlib.isProperty(part, "AssemblyAngularVelocity")
		const legacyVel = NAlib.isProperty(part, "RotVelocity")
		local bestSq = 0
		if typeof(assemblyVel) == "Vector3" then
			bestSq = assemblyVel:Dot(assemblyVel)
		end
		if typeof(legacyVel) == "Vector3" then
			const legacySq = legacyVel:Dot(legacyVel)
			if legacySq > bestSq then
				bestSq = legacySq
			end
		end
		return bestSq
	end

	const function isThreatPart(part, localRoot)
		if not (part and typeof(part) == "Instance" and part:IsA("BasePart") and part.Parent) then
			return false
		end
		if part.Anchored then
			return false
		end
		if NAlib.isProperty(part, "CanCollide") == nil then
			return false
		end
		const model = part:FindFirstAncestorOfClass("Model")
		if model and __lt.cm("Players", "GetPlayerFromCharacter", model) then
			return false
		end
		if localRoot and localRoot.Parent then
			const offset = part.Position - localRoot.Position
			if offset:Dot(offset) > DISTANCE_LIMIT_SQ then
				return false
			end
		end
		const linearSq = velocitySquared(part)
		const angularSq = angularVelocitySquared(part)
		if tracked[part] then
			return linearSq >= LINEAR_RELEASE_SQ
				or angularSq >= ANGULAR_RELEASE_SQ
		end
		return linearSq >= LINEAR_THREAT_SQ
			or angularSq >= ANGULAR_THREAT_SQ
	end

	const function clearPart(part, restore)
		const originalValue = orig[part]
		const hadState = tracked[part] or originalValue ~= nil
		tracked[part] = nil
		if restore and hadState and originalValue ~= nil and typeof(part) == "Instance" and part:IsA("BasePart") and part.Parent then
			NAlib.setProperty(part, "CanCollide", originalValue)
		end
		orig[part] = nil
		sigs[part] = nil
	end

	const function enforcePart(part, localRoot)
		if not isThreatPart(part, localRoot) then
			if tracked[part] or orig[part] ~= nil then
				clearPart(part, true)
			end
			return false
		end

		const current = NAlib.isProperty(part, "CanCollide")
		if current == nil then
			clearPart(part, false)
			return false
		end
		if orig[part] == nil then
			orig[part] = current
		end

		tracked[part] = true

		if current ~= false then
			NAlib.setProperty(part, "CanCollide", false)
			return true
		end
		return false
	end

	const function scanNearby(root)
		if not (root and root.Parent) then
			return 0
		end

		const character = root.Parent
		local parts

		if overlapParams then
			overlapParams.FilterDescendantsInstances = {character}
			local ok, result = pcall(function()
				return Services.Workspace:GetPartBoundsInRadius(root.Position, DISTANCE_LIMIT, overlapParams)
			end)
			if ok and type(result) == "table" then
				parts = result
			end
		end

		if type(parts) ~= "table" then
			const wsList = NAmanage.QueryDescendants(Services.Workspace, "BasePart")
			parts = {}
			local count = 0
			for i = 1, #wsList do
				const obj = wsList[i]
				if obj and not obj:IsDescendantOf(character) then
					const offset = obj.Position - root.Position
					if offset:Dot(offset) <= DISTANCE_LIMIT_SQ then
						count += 1
						parts[count] = obj
						if count >= NEARBY_SCAN_MAX then
							break
						end
					end
				end
			end
		end

		local changed = 0
		for i = 1, #parts do
			if enforcePart(parts[i], root) then
				changed += 1
			end
		end
		return changed
	end

	const changed = scanNearby(getRoot(getChar()))

	NAlib.connect("antifling_parts", NAmanage.wsAdd(function(inst)
		if inst:IsA("BasePart") then
			enforcePart(inst, getRoot(getChar()))
		end
	end))

	NAlib.connect("antifling_parts", NAmanage.wsRem(function(inst)
		if tracked[inst] then
			clearPart(inst, false)
		end
	end))

	NAlib.connect("antifling_parts_scan", Services.RunService.PreSimulation:Connect(function()
		const localRoot = getRoot(getChar())
		local quota = TRACK_QUOTA
		if not localRoot then
			for part in tracked do
				if quota <= 0 then
					break
				end
				clearPart(part, true)
				quota -= 1
			end
			return
		end

		scanNearby(localRoot)

		for part in tracked do
			if quota <= 0 then
				break
			end
			if isThreatPart(part, localRoot) then
				if NAlib.isProperty(part, "CanCollide") ~= false then
					NAlib.setProperty(part, "CanCollide", false)
				end
			else
				clearPart(part, true)
			end
			quota -= 1
		end
	end))

	if changed > 0 then
		DoNotif(("AntiFling Parts enabled. Disabled collision on %d part(s). Threshold: %.1f / %.1f."):format(changed, LINEAR_THREAT, ANGULAR_THREAT), 3, "AntiFling Parts")
	else
		DoNotif(("AntiFling Parts enabled. Watching unanchored parts above %.1f / %.1f."):format(LINEAR_THREAT, ANGULAR_THREAT), 2, "AntiFling Parts")
	end
end)

cmd.add({"unantiflingparts","unantiunanchoredfling","unafparts"},{"unantiflingparts","Restores collision for unanchored parts changed by antiflingparts"},function()
	NAlib.disconnect("antifling_parts")
	NAlib.disconnect("antifling_parts_scan")

	const tracked = NAStuff._afpTracked or {}
	const orig = NAStuff._afpOrigCan or {}
	const sigs = NAStuff._afpSignals or {}

	for part in tracked do
		const originalValue = orig[part]
		if originalValue ~= nil and typeof(part) == "Instance" and part:IsA("BasePart") and part.Parent then
			NAlib.setProperty(part, "CanCollide", originalValue)
		end
	end

	for _, cons in sigs do
		if type(cons) == "table" then
			for i = 1, #cons do
				const conn = cons[i]
				cons[i] = nil
				if conn and conn.Disconnect then
					conn:Disconnect()
				end
			end
		end
	end

	for key in sigs do
		sigs[key] = nil
	end
	for key in tracked do
		tracked[key] = nil
	end
	for key in orig do
		orig[key] = nil
	end

	DoNotif("AntiFling Parts disabled.", 2, "AntiFling Parts")
end)

cmd.add({"gravitygun"},{"gravitygun","Probably the best gravity gun script thats fe"},function()
	Wait();
	DoNotif("Wait a few seconds for it to load",2.5)
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/gravity%20gun")
end)

originalIO.setWorkspaceLocked=function(flag)
	const root = Services.Workspace
	if not root then
		return
	end

	Spawn(function()
		const q = { root }
		local qi, qn = 1, 1
		const step = 256
		local n = 0

		while qi <= qn do
			const inst = q[qi]
			qi += 1

			if NAlib.isProperty(inst, "Locked") ~= nil then
				NAlib.setProperty(inst, "Locked", flag)
			end

			const ch = inst:GetChildren()
			for i = 1, #ch do
				qn += 1
				q[qn] = ch[i]
			end

			n += 1
			if n >= step then
				n = 0
				Wait()
			end
		end
	end)
end

cmd.add({"lockws","lockworkspace"},{"lockws (lockworkspace)","Locks the whole workspace"},function()
	originalIO.setWorkspaceLocked(true)
end)

cmd.add({"unlockws","unlockworkspace"},{"unlockws (unlockworkspace)","Unlocks everything in Workspace"},function()
	originalIO.setWorkspaceLocked(false)
end)

vspeedBTN = nil

cmd.add({"vehiclespeed", "vspeed"}, {"vehiclespeed <amount> (vspeed)", "Change the vehicle speed"}, function(amount)
	NAlib.disconnect("vehicleloopspeed")

	if vspeedBTN then
		vspeedBTN:Destroy()
		vspeedBTN = nil
	end

	local intens = tonumber(amount) or 1

	NAlib.connect("vehicleloopspeed", Services.RunService.PreSimulation:Connect(function()
		const subject = Services.Workspace.CurrentCamera.CameraSubject
		if subject and subject:IsA("Humanoid") and subject.SeatPart then
			subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
		elseif subject and subject:IsA("BasePart") then
			subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
		end
	end))

	DebugNotif("Vehicle speed set to "..intens)

	Wait()

	vspeedBTN = InstanceNew("ScreenGui")
	const btn = InstanceNew("TextButton")
	const speedBox = InstanceNew("TextBox")
	const toggleBtn = InstanceNew("TextButton")
	const corner = InstanceNew("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	const corner2 = InstanceNew("UICorner")
	corner2.CornerRadius = UDim.new(0, 6)
	const corner3 = InstanceNew("UICorner")
	corner3.CornerRadius = UDim.new(0, 6)
	const aspect = InstanceNew("UIAspectRatioConstraint")
	const vstopBtn = InstanceNew("TextButton")
	const vstopCorner = InstanceNew("UICorner")
	vstopCorner.CornerRadius = UDim.new(0, 6)

	NAgui.NaProtectUI(vspeedBTN)

	btn.Parent = vspeedBTN
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.BackgroundTransparency = 0.1
	btn.Position = UDim2.new(0.9, 0, 0.4, 0)
	btn.Size = UDim2.new(0.08, 0, 0.1, 0)
	btn.Font = Enum.Font.GothamBold
	btn.Text = "vSpeed"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.TextWrapped = true
	btn.Active = true

	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	aspect.Parent = btn
	aspect.AspectRatio = 1.0

	speedBox.Parent = vspeedBTN
	speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	speedBox.BackgroundTransparency = 0.1
	speedBox.AnchorPoint = Vector2.new(0.5, 0)
	speedBox.Position = UDim2.new(0.5, 0, 0, 10)
	speedBox.Size = UDim2.new(0, 75, 0, 35)
	speedBox.Font = Enum.Font.GothamBold
	speedBox.Text = tostring(intens)
	speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBox.TextSize = 18
	speedBox.TextWrapped = true
	speedBox.ClearTextOnFocus = false
	speedBox.PlaceholderText = "Speed"
	speedBox.Visible = false

	corner2.CornerRadius = UDim.new(0, 6)
	corner2.Parent = speedBox

	toggleBtn.Parent = btn
	toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggleBtn.BackgroundTransparency = 0.1
	toggleBtn.Position = UDim2.new(0.8, 0, -0.1, 0)
	toggleBtn.Size = UDim2.new(0.4, 0, 0.4, 0)
	toggleBtn.Font = Enum.Font.SourceSans
	toggleBtn.Text = "+"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextScaled = true
	toggleBtn.TextWrapped = true
	toggleBtn.Active = true
	toggleBtn.AutoButtonColor = true

	corner3.CornerRadius = UDim.new(0, 6)
	corner3.Parent = toggleBtn

	vstopBtn.Parent = vspeedBTN
	vstopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	vstopBtn.BackgroundTransparency = 0.1
	vstopBtn.Position = UDim2.new(0.9, 0, 0.52, 0)
	vstopBtn.Size = UDim2.new(0.08, 0, 0.1, 0)
	vstopBtn.Font = Enum.Font.GothamBold
	vstopBtn.Text = "vSTOP"
	vstopBtn.TextColor3 = Color3.new(1, 1, 1)
	vstopBtn.TextScaled = true
	vstopBtn.TextWrapped = true
	vstopBtn.Active = true
	vstopBtn.AutoButtonColor = true

	vstopCorner.CornerRadius = UDim.new(0, 6)
	vstopCorner.Parent = vstopBtn

	MouseButtonFix(toggleBtn, function()
		speedBox.Visible = not speedBox.Visible
		toggleBtn.Text = speedBox.Visible and "-" or "+"
	end)

	local vSpeedOn = true
	btn.Text = "vSpeed ON"
	btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

	MouseButtonFix(btn, function()
		vSpeedOn = not vSpeedOn

		if vSpeedOn then
			const newIntens = tonumber(speedBox.Text) or 1
			intens = newIntens

			NAlib.disconnect("vehicleloopspeed")
			NAlib.connect("vehicleloopspeed", Services.RunService.PreSimulation:Connect(function()
				const subject = Services.Workspace.CurrentCamera.CameraSubject
				if subject and subject:IsA("Humanoid") and subject.SeatPart then
					subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
				elseif subject and subject:IsA("BasePart") then
					subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
				end
			end))

			btn.Text = "vSpeed ON"
			btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			NAlib.disconnect("vehicleloopspeed")

			const subject = Services.Workspace.CurrentCamera.CameraSubject
			if subject then
				local root
				if subject:IsA("Humanoid") and subject.SeatPart then
					root = subject.SeatPart
				elseif subject:IsA("BasePart") then
					root = subject
				end

				if root then
					SpawnCall(function()
						for i = 1, 10 do
							if root:IsDescendantOf(game) then
								root.AssemblyLinearVelocity=root.AssemblyLinearVelocity * .8
								root.AssemblyAngularVelocity=root.AssemblyAngularVelocity * .8
								Wait(0.05)
							end
						end
					end)
				end
			end

			btn.Text = "vSpeed"
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		end
	end)

	MouseButtonFix(vstopBtn, function()
		const subject = Services.Workspace.CurrentCamera.CameraSubject
		if subject then
			local root
			if subject:IsA("Humanoid") and subject.SeatPart then
				root = subject.SeatPart
			elseif subject:IsA("BasePart") then
				root = subject
			end

			if root then
				const model = root:FindFirstAncestorOfClass("Model")
				if model then
					for _, part in NAmanage.QueryDescendants(model, "BasePart") do
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
						if part:IsA("VehicleSeat") then
							part.Throttle = 0
							part.Steer = 0
						end
					end
				else
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end
			end
		end
	end)

	speedBox.FocusLost:Connect(function()
		if not vSpeedOn then return end
		const newIntens = tonumber(speedBox.Text) or 1
		intens = newIntens

		NAlib.disconnect("vehicleloopspeed")
		NAlib.connect("vehicleloopspeed", Services.RunService.PreSimulation:Connect(function()
			const subject = Services.Workspace.CurrentCamera.CameraSubject
			if subject and subject:IsA("Humanoid") and subject.SeatPart then
				subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
			elseif subject and subject:IsA("BasePart") then
				subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
			end
		end))

		DebugNotif("vSpeed updated to "..intens, 2)
	end)

	NAgui.draggerV2(btn)
	NAgui.draggerV2(speedBox)
	NAgui.draggerV2(vstopBtn)
end, true)

cmd.add({"unvehiclespeed", "unvspeed"}, {"unvehiclespeed (unvspeed)", "Stops the vehiclespeed command"}, function()
	NAlib.disconnect("vehicleloopspeed")

	if vspeedBTN then
		vspeedBTN:Destroy()
		vspeedBTN = nil
	end

	const subject = Services.Workspace.CurrentCamera.CameraSubject
	if subject then
		local root
		if subject:IsA("Humanoid") and subject.SeatPart then
			root = subject.SeatPart
		elseif subject:IsA("BasePart") then
			root = subject
		end

		if root then
			const model = root:FindFirstAncestorOfClass("Model")
			if model then
				for _, part in NAmanage.QueryDescendants(model, "BasePart") do
					part.AssemblyLinearVelocity = Vector3.zero
					part.AssemblyAngularVelocity = Vector3.zero
					if part:IsA("VehicleSeat") then
						part.Throttle = 0
						part.Steer = 0
					end
				end
			else
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	DebugNotif("Vehicle speed disabled")
end)

active=false
players=Services.Players
camera=Services.Workspace.CurrentCamera

uis=Services.UserInputService

active=false
function UpdateAutoRotate(BOOL)
	humanoid.AutoRotate=BOOL
end

GameSettings = UserSettings():GetService("UserGameSettings")

OriginalRotationType = nil
ShiftLockEnabled = false

function EnableShiftLock()
	if ShiftLockEnabled then return end

	local success, currentRotation = NACaller(function()
		return GameSettings.RotationType
	end)

	if success then
		OriginalRotationType = currentRotation
	end

	NAlib.connect("shiftlock_loop", Services.RunService.RenderStepped:Connect(function()
		NACaller(function()
			GameSettings.RotationType = Enum.RotationType.CameraRelative
		end)
	end))

	ShiftLockEnabled = true
	DebugNotif("ShiftLock Enabled", 2)
end

function DisableShiftLock()
	if not ShiftLockEnabled then return end

	NAlib.disconnect("shiftlock_loop")

	NACaller(function()
		GameSettings.RotationType = OriginalRotationType or Enum.RotationType.MovementRelative
	end)

	ShiftLockEnabled = false
	DebugNotif("ShiftLock Disabled", 2)
end

cmd.add({"shiftlock","sl"}, {"shiftlock (sl)", "Toggles shiftlock"}, function()
	if IsOnMobile then
		NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/shiftlock")
	else
		EnableShiftLock()
	end
end)

cmd.add({"unshiftlock","unsl"}, {"unshiftlock (unsl)", "Disables shiftlock"}, function()
	if IsOnPC then
		DisableShiftLock()
	end
end)

-- if you're reading this use the command 'cmdloop enable' to enable the command loop
-- example 'cmdloop enable shiftlock hidden' (hides notification to display) or set hidden to just anything as long as argument 2 is not empty 💀

cmd.add({"enable"}, {"enable", "Enables a specific CoreGui"}, function(...)
	const args = {...}
	const enableName = args[1]
	const hiddenNotif = args[2]
	const buttons = {}

	for _, coreGuiType in Enum.CoreGuiType:GetEnumItems() do
		Insert(buttons, {
			Text = coreGuiType.Name,
			Callback = function()
				__lt.cm("StarterGui", "SetCoreGuiEnabled", coreGuiType, true)
				if coreGuiType == Enum.CoreGuiType.Chat or coreGuiType == Enum.CoreGuiType.All then
					NAStuff.ChatSettings.coreGuiChat = true
					NAStuff.ChatSettingsDirty = true
					NAmanage.SaveTextChatSettings()
					NAmanage.ApplyTextChatSettings(true)
				end
			end
		})
	end

	Insert(buttons, {
		Text = "Shiftlock",
		Callback = function()
			LocalPlayer.DevEnableMouseLock = true
		end
	})

	Insert(buttons, {
		Text = "Reset",
		Callback = function()
			__lt.cm("StarterGui", "SetCore", "ResetButtonCallback", true)
		end
	})

	if enableName and enableName ~= "" then
		local found = false
		for _, button in buttons do
			if Match(button.Text:lower(), enableName:lower()) then
				button.Callback()
				if not hiddenNotif then
					DebugNotif("CoreGui Enabled: "..button.Text.." has been enabled.", 3)
				end
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching CoreGui element found for: "..enableName, 3)
		end
	else
		Window({
			Title = "Enable a Specific Core Gui Element",
			Buttons = buttons
		})
	end
end, true)

cmd.add({"disable"}, {"disable", "Disables a specific CoreGui"}, function(...)
	const args = {...}
	const disableName = args[1]
	const hiddenNotif = args[2] -- scuffed way lmao
	const buttons = {}

	for _, coreGuiType in Enum.CoreGuiType:GetEnumItems() do
		Insert(buttons, {
			Text = coreGuiType.Name,
			Callback = function()
				__lt.cm("StarterGui", "SetCoreGuiEnabled", coreGuiType, false)
				if coreGuiType == Enum.CoreGuiType.Chat or coreGuiType == Enum.CoreGuiType.All then
					NAStuff.ChatSettings.coreGuiChat = false
					NAStuff.ChatSettingsDirty = true
					NAmanage.SaveTextChatSettings()
					NAmanage.ApplyTextChatSettings(true)
				end
			end
		})
	end

	Insert(buttons, {
		Text = "Shiftlock",
		Callback = function()
			LocalPlayer.DevEnableMouseLock = false
		end
	})

	Insert(buttons, {
		Text = "Reset",
		Callback = function()
			__lt.cm("StarterGui", "SetCore", "ResetButtonCallback", false)
		end
	})

	if disableName and disableName ~= "" then
		local found = false
		for _, button in buttons do
			if Match(button.Text:lower(), disableName:lower()) then
				button.Callback()
				if not hiddenNotif then
					DebugNotif("CoreGui Disabled: "..button.Text.." has been disabled.", 3)
				end
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching CoreGui element found for: "..disableName, 3)
		end
	else
		Window({
			Title = "Disable a Specific Core Gui Element",
			Buttons = buttons
		})
	end
end,true)

cmd.add({"reverb","reverbcontrol"},{"reverb (reverbcontrol)","Manage sound reverb settings"},function(...)
	const args = {...}
	const target = args[1]
	const buttons = {}
	for _, rt in Enum.ReverbType:GetEnumItems() do
		Insert(buttons, {
			Text = rt.Name,
			Callback = function()
				SafeGetService("SoundService").AmbientReverb = rt
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in buttons do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				DebugNotif("Reverb set to "..btn.Text, 3)
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching reverb type for: "..target, 3)
		end
	else
		Window({
			Title = "Sound Reverb Options",
			Buttons = buttons
		})
	end
end)

NAStuff.forceReverbState = NAStuff.forceReverbState or { enabled = false, target = nil }

originalIO.stopForceReverb=function()
	NAStuff.forceReverbState.enabled = false
	NAStuff.forceReverbState.target = nil
	NAlib.disconnect("forcereverb_main")
	NAlib.disconnect("forcereverb_prop")
end

originalIO.ensureForceReverb=function()
	if not NAStuff.forceReverbState.enabled or not NAStuff.forceReverbState.target then return end
	const ss = SafeGetService("SoundService")
	if not ss then return end
	if ss.AmbientReverb ~= NAStuff.forceReverbState.target then
		pcall(function() ss.AmbientReverb = NAStuff.forceReverbState.target end)
	end
end

originalIO.bindForceReverbWatcher=function()
	NAlib.disconnect("forcereverb_prop")
	const ss = SafeGetService("SoundService")
	if ss then
		NAlib.connect("forcereverb_prop", __lt.cm("SoundService", "GetPropertyChangedSignal", "AmbientReverb"):Connect(originalIO.ensureForceReverb))
	end
end

originalIO.startForceReverb=function(targetType)
	if not targetType then return end
	NAStuff.forceReverbState.enabled = true
	NAStuff.forceReverbState.target = targetType
	NAlib.disconnect("forcereverb_main")
	NAlib.disconnect("forcereverb_prop")

	originalIO.ensureForceReverb()
	originalIO.bindForceReverbWatcher()

	NAlib.connect("forcereverb_main", __lt.cm("SoundService", "GetPropertyChangedSignal", "AmbientReverb"):Connect(function()
		originalIO.ensureForceReverb()
		originalIO.bindForceReverbWatcher()
	end))

	DoNotif("Reverb locked to "..tostring(targetType.Name or tostring(targetType)), 2)
end

cmd.add({"forcereverb","freverb"},{"forcereverb","Lock ambient reverb and auto-restore if changed"},function(...)
	const args = {...}
	const target = args[1]
	const buttons = {}
	for _, rt in Enum.ReverbType:GetEnumItems() do
		Insert(buttons, {
			Text = rt.Name,
			Callback = function()
				originalIO.startForceReverb(rt)
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in buttons do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching reverb type for: "..target, 3)
		end
	else
		Window({
			Title = "Force Reverb Type",
			Buttons = buttons
		})
	end
end)

cmd.add({"unforcereverb","ufreverb","ufr","stopforcereverb"},{"unforcereverb (ufreverb, ufr)","Stop forcing ambient reverb"},function()
	if NAStuff.forceReverbState.enabled then
		originalIO.stopForceReverb()
		DoNotif("Reverb force disabled", 2)
	else
		DoNotif("Reverb force is already off", 2)
	end
end)

NAStuff.forceCamState = NAStuff.forceCamState or { enabled = false, target = nil }

originalIO.stopForceCam=function()
	NAStuff.forceCamState.enabled = false
	NAStuff.forceCamState.target = nil
	NAlib.disconnect("forcecam_main")
	NAlib.disconnect("forcecam_camprop")
end

originalIO.ensureForceCam=function()
	if not NAStuff.forceCamState.enabled or not NAStuff.forceCamState.target then return end
	const cam = Services.Workspace.CurrentCamera
	if not cam then return end
	if cam.CameraType ~= NAStuff.forceCamState.target then
		pcall(function() cam.CameraType = NAStuff.forceCamState.target end)
	end
end

originalIO.bindForceCamPropWatcher=function()
	NAlib.disconnect("forcecam_camprop")
	const cam = Services.Workspace.CurrentCamera
	if cam then
		NAlib.connect("forcecam_camprop", cam:GetPropertyChangedSignal("CameraType"):Connect(originalIO.ensureForceCam))
	end
end

originalIO.startForceCam=function(targetType)
	if not targetType then return end
	NAStuff.forceCamState.enabled = true
	NAStuff.forceCamState.target = targetType
	NAlib.disconnect("forcecam_main")
	NAlib.disconnect("forcecam_camprop")

	originalIO.ensureForceCam()
	originalIO.bindForceCamPropWatcher()

	NAlib.connect("forcecam_main", Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		originalIO.ensureForceCam()
		originalIO.bindForceCamPropWatcher()
	end))

	DoNotif("Camera type locked to "..tostring(targetType.Name or tostring(targetType)), 2)
end

cmd.add({"cam","camera","cameratype"},{"cam (camera, cameratype)","Manage camera type settings"},function(...)
	const args = {...}
	const target = args[1]
	const buttons = {}
	for _, ct in Enum.CameraType:GetEnumItems() do
		Insert(buttons, {
			Text = ct.Name,
			Callback = function()
				Services.Workspace.CurrentCamera.CameraType = ct
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in buttons do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				DebugNotif("Camera type set to "..btn.Text, 3)
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching camera type for: "..target, 3)
		end
	else
		Window({
			Title = "Camera Type Options",
			Buttons = buttons
		})
	end
end)

cmd.add({"forcecam"},{"forcecam","Lock camera type and auto-restore if changed"},function(...)
	const args = {...}
	const target = args[1]
	const buttons = {}
	for _, ct in Enum.CameraType:GetEnumItems() do
		Insert(buttons, {
			Text = ct.Name,
			Callback = function()
				originalIO.startForceCam(ct)
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in buttons do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching camera type for: "..target, 3)
		end
	else
		Window({
			Title = "Force Camera Type",
			Buttons = buttons
		})
	end
end)

cmd.add({"unforcecam","ufcam","ufc","stopforcecam"},{"unforcecam (ufcam, ufc)","Stop forcing camera type"},function()
	if NAStuff.forceCamState.enabled then
		originalIO.stopForceCam()
		DoNotif("Camera force disabled", 2)
	else
		DoNotif("Camera force is already off", 2)
	end
end)

alignmentButtonsGui = nil

cmd.add({"alignmentkeys","alignkeys","ak"},{"alignmentkeys","Enable alignment keys"}, function()
	const function onInput(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Comma and Services.Workspace.CurrentCamera then
			Services.Workspace.CurrentCamera:PanUnits(-1)
		elseif input.KeyCode == Enum.KeyCode.Period and Services.Workspace.CurrentCamera then
			Services.Workspace.CurrentCamera:PanUnits(1)
		end
	end
	if not NAlib.isConnected("align_input") then
		NAlib.connect("align_input", Services.UserInputService.InputBegan:Connect(onInput))
	end
	if IsOnMobile and not alignmentButtonsGui then
		alignmentButtonsGui = InstanceNew("ScreenGui")
		alignmentButtonsGui.Name = "AlignButtons"
		alignmentButtonsGui.ResetOnSpawn = false
		NAgui.NaProtectUI(alignmentButtonsGui)

		const btnSize = UDim2.new(0.1, 0, 0.1, 0)

		const leftButton = InstanceNew("TextButton")
		leftButton.Name = "PanLeft"
		leftButton.Text = "<"
		leftButton.TextScaled = true
		leftButton.Size = btnSize
		leftButton.Position = UDim2.new(0.45, 0, 0.05, 0)
		leftButton.AnchorPoint = Vector2.new(0.5, 0.5)
		leftButton.BackgroundColor3 = Color3.new(0, 0, 0)
		leftButton.BorderSizePixel = 0
		leftButton.TextColor3 = Color3.new(1, 1, 1)
		leftButton.Parent = alignmentButtonsGui

		const leftUICorner = InstanceNew("UICorner")
		leftUICorner.CornerRadius = UDim.new(0, 6)
		leftUICorner.Parent = leftButton

		const rightButton = InstanceNew("TextButton")
		rightButton.Name = "PanRight"
		rightButton.Text = ">"
		rightButton.TextScaled = true
		rightButton.Size = btnSize
		rightButton.Position = UDim2.new(0.55, 0, 0.05, 0)
		rightButton.AnchorPoint = Vector2.new(0.5, 0.5)
		rightButton.BackgroundColor3 = Color3.new(0, 0, 0)
		rightButton.BorderSizePixel = 0
		rightButton.TextColor3 = Color3.new(1, 1, 1)
		rightButton.Parent = alignmentButtonsGui

		const rightUICorner = InstanceNew("UICorner")
		rightUICorner.CornerRadius = UDim.new(0, 6)
		rightUICorner.Parent = rightButton

		NAgui.draggerV2(leftButton)
		NAgui.draggerV2(rightButton)

		NAlib.connect("align_mobile_left", MouseButtonFix(leftButton,function()
			if Services.Workspace.CurrentCamera then
				Services.Workspace.CurrentCamera:PanUnits(-1)
			end
		end))
		NAlib.connect("align_mobile_right", MouseButtonFix(rightButton,function()
			if Services.Workspace.CurrentCamera then
				Services.Workspace.CurrentCamera:PanUnits(1)
			end
		end))
	end
end)

cmd.add({"disablealignmentkeys","disablealignkeys","dak"},{"disablealignmentkeys","Disable alignment keys"}, function()
	NAlib.disconnect("align_input")
	if IsOnMobile and alignmentButtonsGui then
		NAlib.disconnect("align_mobile_left")
		NAlib.disconnect("align_mobile_right")
		alignmentButtonsGui:Destroy()
		alignmentButtonsGui = nil
		mobileLeftConn = nil
		mobileRightConn = nil
	end
end)

NAmanage.ESP_EnablePlayerMode = function(mode, teamPrefix, useChams, label, opts)
	opts = type(opts) == "table" and opts or {}
	ESPPlayersEnabled = true
	chamsEnabled = useChams == true
	NAmanage.ESP_RecomputeEnabled()
	NAmanage.ESP_ClearPlayerLabelOverrides()
	ESPAutoTrackAll = true
	if type(NAmanage.ESP_SetPlayerTargetMode) == "function" then
		NAmanage.ESP_SetPlayerTargetMode(mode, teamPrefix, {
			forceAll = opts.forceAll == true;
			save = false;
		})
	end
	NAmanage.ESP_ClearPlayers()
	if NAmanage.ESP_StartPlayerRosterWatch then
		NAmanage.ESP_StartPlayerRosterWatch()
	end
	local count = 0
	for _, player in __lt.cm("Players", "GetPlayers") do
		if player ~= Services.Players.LocalPlayer then
			NAmanage.ESP_SetupPlayerWatch(player)
		end
		if NAmanage.ESP_ShouldTrackPlayer(player) then
			count += 1
			NAmanage.ESP_Add(player, true)
		end
	end
	NAmanage.ESP_StartGlobal()
	if label then
		DoNotif((useChams and "Chams" or "ESP").." "..label.." enabled ("..tostring(count)..")", 2, "ESP")
	end
end

cmd.add({"esp", "espplayers", "playeresp"}, {"esp (espplayers, playeresp)","locate where the players are"}, function()
	NAmanage.ESP_EnablePlayerMode("all", "", false, "players")
end)

cmd.add({"espall", "allesp", "espallplayers"}, {"espall (allesp)","ESP all players and clear team filtering"}, function()
	NAmanage.ESP_EnablePlayerMode("all", "", false, "all players", { forceAll = true })
end)

cmd.add({"espenemies", "espenemy", "espnonteam", "espnonteams", "espnoteam", "espnoteams", "enemyesp", "enemiesesp", "nonteamesp", "noteamesp"}, {"espenemies (espnonteam, espnoteam)","ESP players outside your team; no-team games fall back to all others"}, function()
	NAmanage.ESP_EnablePlayerMode("enemies", "", false, "enemies")
end)

cmd.add({"espallies", "espally", "espteammates", "espteamates", "allyesp", "alliesesp", "teammateesp"}, {"espallies (espteammates)","ESP players on your current team"}, function()
	NAmanage.ESP_EnablePlayerMode("allies", "", false, "allies")
end)

cmd.add({"espteam", "teamesp", "espteamname", "espbyteam", "locateteam"}, {"espteam <team prefix>","ESP players in a specific team; no args = current team/allies"}, function(...)
	const args = {...}
	const teamPrefix = NAgui.trimText and NAgui.trimText(Concat(args, " ")) or (Concat(args, " "):match("^%s*(.-)%s*$") or "")
	if teamPrefix == "" then
		NAmanage.ESP_EnablePlayerMode("allies", "", false, "current team")
	else
		NAmanage.ESP_EnablePlayerMode("teamname", teamPrefix, false, "team "..teamPrefix)
	end
end, true)

cmd.add({"chams"}, {"chams","ESP but without the text :shock:"}, function()
	NAmanage.ESP_EnablePlayerMode("all", "", true, "players")
end)

cmd.add({"chamsenemies", "chamsenemy", "chamsnonteam", "enemychams", "nonteamchams"}, {"chamsenemies (chamsnonteam)","Chams players outside your team"}, function()
	NAmanage.ESP_EnablePlayerMode("enemies", "", true, "enemies")
end)

cmd.add({"chamsallies", "chamsally", "chamsteammates", "allychams", "teammatechams"}, {"chamsallies (chamsteammates)","Chams players on your current team"}, function()
	NAmanage.ESP_EnablePlayerMode("allies", "", true, "allies")
end)

cmd.add({"chamsteam", "teamchams", "chamsteamname", "chamsbyteam"}, {"chamsteam <team prefix>","Chams players in a specific team; no args = current team/allies"}, function(...)
	const args = {...}
	const teamPrefix = NAgui.trimText and NAgui.trimText(Concat(args, " ")) or (Concat(args, " "):match("^%s*(.-)%s*$") or "")
	if teamPrefix == "" then
		NAmanage.ESP_EnablePlayerMode("allies", "", true, "current team")
	else
		NAmanage.ESP_EnablePlayerMode("teamname", teamPrefix, true, "team "..teamPrefix)
	end
end, true)

NAStuff.LocatedNPCs = type(NAStuff.LocatedNPCs) == "table" and NAStuff.LocatedNPCs or {}

NAmanage.HasLocatedNPCs = function()
	for npc in NAStuff.LocatedNPCs do
		if typeof(npc) == "Instance" and npc:IsA("Model") and npc.Parent then
			return true
		end
		NAStuff.LocatedNPCs[npc] = nil
	end
	return false
end

cmd.add({"locate"}, {"locate <player|npc:filter> ... (optional)", "Locate specific players or NPCs"}, function(...)
	ESPPlayersEnabled = true
	NAmanage.ESP_RecomputeEnabled()
	local tokens = {...}
	const providedArgCount = select("#", ...)
	if providedArgCount == 0 then tokens = {"all"} end
	local shouldAuto = (providedArgCount == 0)
	const targetUidSet = {}
	if not shouldAuto then
		for _, token in tokens do
			const lower = tostring(token):lower()
			if lower == "all" or lower == "others" then
				shouldAuto = true
				break
			end
		end
	end
	if shouldAuto then
		chamsEnabled = false
		NAmanage.ESP_ClearPlayerLabelOverrides()
		ESPAutoTrackAll = true
		if type(NAmanage.ESP_SetPlayerTargetMode) == "function" then
			NAmanage.ESP_SetPlayerTargetMode("all", "", {
				forceAll = true;
				save = false;
			})
		end
	elseif not chamsEnabled then
		ESPAutoTrackAll = false
	end
	for _, token in tokens do
		for _, target in getPlr(token) do
			if target and target ~= Services.Players.LocalPlayer then
				if target:IsA("Player") then
					const uid = tonumber(target.UserId)
					if uid and uid > 0 then
						targetUidSet[uid] = true
					end
					if not shouldAuto then
						NAmanage.ESP_SetPlayerLabelOverride(target, true)
					end
					NAmanage.ESP_Add(target, true)
				elseif target:IsA("Model") then
					NAStuff.LocatedNPCs[target] = true
					NAmanage.ESP_Add(target, false, true)
				end
			end
		end
	end
	if not shouldAuto and chamsEnabled then
		for _, plr in __lt.cm("Players", "GetPlayers") do
			if plr and plr ~= Services.Players.LocalPlayer then
				const uid = tonumber(plr.UserId)
				if not (uid and targetUidSet[uid]) then
					NAmanage.ESP_SetPlayerLabelOverride(plr, false)
					if plr.Character and espCONS[plr.Character] then
						NAmanage.ESP_DestroyLabel(plr.Character)
					end
				end
			end
		end
	end
	if not shouldAuto and type(NAmanage.ESP_RefreshPlayerTeamFilters) == "function" then
		NAmanage.ESP_RefreshPlayerTeamFilters()
	end
end, true, {argumentHint="Examples: player, me, nearest, npc:name, npcs"})
NAStuff.NPC_SCAN_KEY = NAStuff.NPC_SCAN_KEY or "npc_esp_scan"
NAStuff.npcESPList = NAStuff.npcESPList or _na_env.npcESPList
if not NAStuff.npcESPList then
	NAStuff.npcESPList = {}
else
	if getmetatable(NAStuff.npcESPList) then
		setmetatable(NAStuff.npcESPList, nil)
	end
end
_na_env.npcESPList = NAStuff.npcESPList
NAStuff.npcCandidates = NAStuff.npcCandidates or {}
if getmetatable(NAStuff.npcCandidates) then
	setmetatable(NAStuff.npcCandidates, nil)
end

NAmanage.ClearNpcTables = function()
	for inst in NAStuff.npcCandidates do
		NAStuff.npcCandidates[inst] = nil
	end
	for inst in NAStuff.npcESPList do
		NAStuff.npcESPList[inst] = nil
		NAmanage.ESP_Disconnect(inst)
	end
end

NAmanage.AddNpcCandidate = function(inst)
	if inst and inst:IsA("Model") and CheckIfNPC(inst) then
		NAStuff.npcCandidates[inst] = true
	end
end

NAmanage.RemoveNpcCandidate = function(inst)
	if not inst then
		return
	end
	if inst:IsA("Model") then
		NAStuff.npcCandidates[inst] = nil
	end
	if NAStuff.npcESPList[inst] then
		NAStuff.npcESPList[inst] = nil
		NAmanage.ESP_Disconnect(inst)
	end
end

NAmanage.SeedNpcCandidates = function()
	NAStuff.npcCandidates = {}
	for _, inst in NAmanage.QueryDescendants(Services.Workspace, "Model") do
		NAmanage.AddNpcCandidate(inst)
	end
end

NAStuff.NPC_ESP_Filter = tostring(NAStuff.NPC_ESP_Filter or "")

NAmanage.ResolveNPCESPFilter = function(pool, speaker, raw)
	raw = Lower(NAmanage.NPCArgTrim(raw))
	const parsed = NAmanage.ParseNPCPlayerArg(raw)
	if parsed ~= nil then
		raw = parsed
	end
	const tokens = NAmanage.NPCArgSplit(raw)
	if #tokens == 0 then
		return pool
	end
	const out = {}
	const seen = {}
	for _, token in tokens do
		for _, npc in NAmanage.NPCArgFilter(pool, speaker, token) do
			if not seen[npc] then
				seen[npc] = true
				Insert(out, npc)
			end
		end
	end
	return out
end

cmd.add({"npcesp","espnpc"},{"npcesp [npc:name|filter] (espnpc)","locate all NPCs or only NPCs matching a name/filter"},function(...)
	NAStuff.NPC_ESP_Filter = Concat({...}, " "):match("^%s*(.-)%s*$") or ""
	NPCESPenabled = true
	NAmanage.ESP_RecomputeEnabled()
	chamsEnabled = false
	ESPAutoTrackAll = false
	NAmanage.ClearNpcTables()
	NAmanage.SeedNpcCandidates()
	if not NAlib.isConnected(NAStuff.NPC_SCAN_KEY) then
		local acc = 0
		NAlib.connect(NAStuff.NPC_SCAN_KEY, Services.RunService.Heartbeat:Connect(function(dt)
			if not NPCESPenabled then return end
			acc = acc + dt
			if acc < (NAStuff.NPC_ESP_ScanInterval or 0.6) then return end
			acc = 0

			const plr = Services.Players.LocalPlayer
			const char = plr and plr.Character
			const root = char and getRoot(char)
			const pool = {}

			for inst in NAStuff.npcCandidates do
				if inst and inst.Parent and CheckIfNPC(inst) and NAmanage.IsValidESPModel(inst, true) then
					Insert(pool, inst)
				else
					NAStuff.npcCandidates[inst] = nil
					NAStuff.npcESPList[inst] = nil
					NAmanage.ESP_Disconnect(inst)
				end
			end

			const selected = NAmanage.ResolveNPCESPFilter(pool, plr, NAStuff.NPC_ESP_Filter)
			const found = {}
			local cnt = 0
			const maxCnt = NAStuff.NPC_ESP_MaxCount or 200
			const maxDist = NAStuff.NPC_ESP_MaxDist or 400

			for _, inst in selected do
				const rp = getRoot(inst)
				if rp then
					const d = root and (rp.Position - root.Position).Magnitude or nil
					if NAmanage.ESP_IsWithinDistance(d, maxDist) then
						found[inst] = true
						if not NAStuff.npcESPList[inst] then
							NAStuff.npcESPList[inst] = true
							NAmanage.ESP_Add(inst, false, true)
						end
						cnt += 1
						if cnt >= maxCnt then
							break
						end
					end
				end
			end

			for inst in NAStuff.npcESPList do
				if not found[inst] then
					NAStuff.npcESPList[inst] = nil
					NAmanage.ESP_Disconnect(inst)
				end
			end
		end))
		NAlib.connect(NAStuff.NPC_SCAN_KEY, NAmanage.wsAdd(function(inst)
			if inst:IsA("Model") then
				NAmanage.AddNpcCandidate(inst)
			elseif inst:IsA("Humanoid") then
				const parent = inst.Parent
				if parent and parent:IsA("Model") then
					NAmanage.AddNpcCandidate(parent)
				end
			end
		end))
		NAlib.connect(NAStuff.NPC_SCAN_KEY, NAmanage.wsRem(function(inst)
			if inst:IsA("Model") then
				NAmanage.RemoveNpcCandidate(inst)
			elseif inst:IsA("Humanoid") then
				const parent = inst.Parent
				if parent and parent:IsA("Model") then
					NAmanage.RemoveNpcCandidate(parent)
				end
			end
		end))
	end
	NAmanage.ESP_StartGlobal()
end)

cmd.add({"unnpcesp","unespnpc"},{"unnpcesp (unespnpc)","stop locating npcs"},function()
	NPCESPenabled = false
	NAmanage.ESP_RecomputeEnabled()
	if NAlib.isConnected(NAStuff.NPC_SCAN_KEY) then
		NAlib.disconnect(NAStuff.NPC_SCAN_KEY)
	end
	NAmanage.ClearNpcTables()
	NAStuff.npcESPList = {}
	_na_env.npcESPList = NAStuff.npcESPList
	NAStuff.npcCandidates = {}
	NAStuff.NPC_ESP_Filter = ""
	if not (ESPPlayersEnabled or chamsEnabled or NPCESPenabled) then
		NAmanage.ESP_StopGlobal()
	end
end)

cmd.add({"unesp","unchams","unespteam","unespenemies","unespallies","unespplayers","unchamsteam","unchamsenemies","unchamsallies"},{"unesp (unchams)","Disables esp/chams"},function()
	NAStuff.ESP_PlayerTargetMode = "all"
	NAStuff.ESP_TargetTeam = ""
	ESPPlayersEnabled = false
	NAmanage.ESP_RecomputeEnabled()
	chamsEnabled = false
	NAmanage.ESP_ClearPlayerLabelOverrides()
	ESPAutoTrackAll = false
	NAmanage.ESP_ClearPlayers()
	if not (NPCESPenabled or chamsEnabled) then
		NAmanage.ESP_StopGlobal()
	end
end)

cmd.add({"unlocate"},{"unlocate <player|npc:filter> ..."},function(...)
	const tokens = {...}
	local clearAll = (#tokens == 0)
	for _, name in tokens do
		const lower = tostring(name):lower()
		if lower == "all" or lower == "others" then
			clearAll = true
			break
		end
	end
	if clearAll then
		NAmanage.ESP_ClearPlayerLabelOverrides()
		for npc in NAStuff.LocatedNPCs do
			if typeof(npc) == "Instance" then
				NAmanage.ESP_Disconnect(npc)
			end
			NAStuff.LocatedNPCs[npc] = nil
		end
		if not chamsEnabled then
			ESPAutoTrackAll = false
			ESPPlayersEnabled = false
			NAmanage.ESP_RecomputeEnabled()
			NAmanage.ESP_ClearPlayers()
			if not NPCESPenabled then
				NAmanage.ESP_StopGlobal()
			end
		else
			for _, plr in __lt.cm("Players", "GetPlayers") do
				if plr and plr.Character and espCONS[plr.Character] then
					NAmanage.ESP_DestroyLabel(plr.Character)
				end
			end
		end
		return
	end
	for _, name in tokens do
		for _, target in getPlr(name) do
			if target:IsA("Player") then
				NAmanage.ESP_SetPlayerLabelOverride(target, false)
				if target.Character and espCONS[target.Character] then
					NAmanage.ESP_DestroyLabel(target.Character)
				end
				if not chamsEnabled then
					NAmanage.ESP_Disconnect(target)
				end
			elseif target:IsA("Model") then
				NAStuff.LocatedNPCs[target] = nil
				NAmanage.ESP_Disconnect(target)
			end
		end
	end
	if not chamsEnabled and ESPAutoTrackAll ~= true and not NAmanage.ESP_HasAnyPlayerLabelOverride() and not NAmanage.HasLocatedNPCs() then
		ESPPlayersEnabled = false
		NAmanage.ESP_RecomputeEnabled()
		if not NPCESPenabled then
			NAmanage.ESP_StopGlobal()
		end
	end
end, true, {argumentHint="Examples: player, npc:name, npcs"})
cmd.add({"vehiclenoclip", "vnoclip"}, {"vehiclenoclip (vnoclip)", "Disables vehicle collision"}, function()
	VVVVVVVVVVVCARRR = {}

	const hum = getHum()
	if not hum then return DoNotif("no humanoid found",2) end
	const seat = hum and hum.SeatPart

	local model = seat.Parent
	while model and not model:IsA("Model") do
		model = model.Parent
	end

	Wait(0.1)
	cmd.run({"noclip"})

	for _, pp in NAmanage.QueryDescendants(model, "BasePart") do
		if pp.CanCollide then
			Insert(VVVVVVVVVVVCARRR, pp)
			pp.CanCollide = false
		end
	end
end)

cmd.add({"vehicleclip", "vclip", "unvnoclip", "unvehiclenoclip"}, {"vehicleclip (vclip, unvnoclip, unvehiclenoclip)", "Enables vehicle collision"}, function()
	cmd.run({"clip"})

	for _, pppp in VVVVVVVVVVVCARRR do
		if pppp and pppp:IsA("BasePart") then
			pppp.CanCollide = true
		end
	end

	VVVVVVVVVVVCARRR = {}
end)

cmd.add({"handlekill", "hkill"}, {"handlekill <player|npc:filter> (hkill)", "Kills a player or NPC using a tool that deals damage on touch"}, function(...)
	const LocalPlayer = Services.Players.LocalPlayer

	if not firetouchinterest then
		return DoNotif('Your exploit does not support firetouchinterest to run this command')
	end

	const function zeTOOL()
		const character = LocalPlayer.Character
		if not character then return nil, nil end
		const tool = character:FindFirstChildWhichIsA("Tool")
		if not tool then return nil, nil end
		const handle = tool:FindFirstChild("Handle")
		return tool, handle
	end

	local Tool, Handle = zeTOOL()
	if not Tool then
		return DoNotif('You need to hold a "Tool" that does damage on touch')
	end

	const function findDamagePart(tool)
		local ttPart = nil
		for _, desc in NAmanage.QueryDescendants(tool, "TouchTransmitter") do
			const parent = desc.Parent
			if parent and parent:IsA("BasePart") then
				ttPart = parent
				break
			end
		end
		if ttPart then
			return ttPart, "touchtransmitter"
		end
		const h = tool:FindFirstChild("Handle")
		if h and h:IsA("BasePart") then
			return h, "handle"
		end
		return nil, "none"
	end

	local DamagePart, source = findDamagePart(Tool)
	if not DamagePart then
		if Handle then
			return DoNotif("This tool has no TouchTransmitter; the Handle can't be used for handlekill.", 3)
		end
		return DoNotif("This tool has no TouchTransmitter or Handle - handlekill cannot run with it.", 3)
	end

	const username = ...
	const targets = getPlr(username)
	if #targets == 0 then
		return DoNotif("No target found",2)
	end

	for _, targetPlayer in targets do
		SpawnCall(function()
			while Tool and getPlrChar(LocalPlayer) and getPlrChar(targetPlayer) and Tool.Parent == LocalPlayer.Character do
				const humanoid = getPlrHum(targetPlayer)
				if not humanoid or humanoid.Health <= 0 then
					break
				end

				const targetCharacter = getPlrChar(targetPlayer)
				if not targetCharacter then
					break
				end
				for _, part in targetCharacter:GetChildren() do
					if part:IsA("BasePart") then
						const touchWorld = NAmanage.GetWorldRoot(DamagePart)
						if touchWorld and NAmanage.SafeFireTouchInterest(DamagePart, part, 0) then
							Wait()
							if NAmanage.GetWorldRoot(DamagePart) == touchWorld and NAmanage.GetWorldRoot(part) == touchWorld then
								NAmanage.SafeFireTouchInterest(DamagePart, part, 1)
							end
						end
					end
				end

				Services.RunService.PreSimulation:Wait()
			end
		end)
	end
end, true, {argumentHint="Examples: player, me, nearest, npc:name, npcs"})

cmd.add({"creep"}, {"creep <player|npc:filter>", "Teleports from a player or NPC behind them and under the floor to the top"}, function(...)
	const username = ...
	const targets = getPlr(username)
	if #targets == 0 then
		DoNotif("No target found.", 3)
		return
	end

	const target = targets[1]
	const character = getChar()
	if not character then
		DoNotif("Your character is invalid.", 3)
		return
	end

	const root = getRoot(character)
	if not root then
		DoNotif("Your character's root is invalid.", 3)
		return
	end

	const targetChar = NAmanage.PlayerArgChar(target)
	const targetHum = getPlrHum(target)
	if not targetChar or not targetHum or not targetHum.RootPart then
		DoNotif("Target's character is invalid.", 3)
		return
	end

	NAmanage.UG_setRootCFrame(root, targetHum.RootPart.CFrame * CFrame.new(0, -10, 4))
	Wait()

	if NAlib.isConnected("creep_noclip") then
		NAlib.disconnect("creep_noclip")
	end

	NAlib.connect("creep_noclip", Services.RunService.PreSimulation:Connect(function()
		const char = getChar()
		if not char then return end
		for _, part in char:QueryDescendants("BasePart") do
			part.CanCollide = false
		end
	end))
	Wait()

	root.Anchored = true
	Wait()

	const tweenService = Services.TweenService
	const tweenInfo = TweenInfo.new(1000, Enum.EasingStyle.Linear)
	const tween = tweenService:Create(root, tweenInfo, {CFrame = CFrame.new(0, 10000, 0)})
	tween:Play()
	Wait(1.5)
	tween:Pause()

	root.Anchored = false
	Wait()

	NAlib.disconnect("creep_noclip")
end, true)

cmd.add({"netless","net"},{"netless (net)","Executes netless which makes scripts more stable"},function()
	if NAlib.isConnected("netless") then
		NAlib.disconnect("netless")
		DebugNotif("Netless disabled", 2)
		return
	end

	NAlib.disconnect("netless")
	NAlib.connect("netless", Services.RunService.PreSimulation:Connect(function()
		const c = getChar()
		if not c then return end
		for _, v in NAmanage.QueryDescendants(c, "BasePart") do
			if v.Name ~= "HumanoidRootPart" then
				v.Velocity = Vector3.new(-30, 0, 0)
			end
		end
	end))

	DebugNotif("Netless enabled (run again to disable)", 3)
end)

cmd.add({"reset","die"},{"reset (die)","Makes your health be 0"},function()
	getHum():ChangeState(Enum.HumanoidStateType.Dead)
	getHum().Health=0
end)

cmd.add({"gethealth","currenthealth","hp"},{"gethealth","Shows your current health"},function()
	const char = getChar()
	const hum = char and char:FindFirstChildOfClass("Humanoid") or nil
	if not hum or NAlib.isProperty(hum, "Health") == nil then
		DebugNotif("No humanoid found", 2)
		return
	end
	const health = tonumber(NAlib.isProperty(hum, "Health")) or 0
	const maxHealth = tonumber(NAlib.isProperty(hum, "MaxHealth"))
	const function fmt(n)
		if not n then return "?" end
		if n % 1 == 0 then return tostring(n) end
		return ("%.2f"):format(n)
	end
	local msg = "Health: "..fmt(health)
	if maxHealth then
		msg = msg.." / "..fmt(maxHealth)
	end
	DoNotif(msg, 3)
end)

NAStuff.AntiBreakEnabled = NAStuff.AntiBreakEnabled or false
NAStuff.AntiBreakSignals = NAStuff.AntiBreakSignals or {}
NAStuff.AntiBreakNoHook = NAStuff.AntiBreakNoHook or false
NAStuff.AntiBreakChar = NAStuff.AntiBreakChar or nil
NAStuff.AntiBreakHum = NAStuff.AntiBreakHum or nil

NAmanage.AntiBreakClearSignals = function(hum)
	const sigs = NAStuff.AntiBreakSignals
	if type(sigs) ~= "table" then
		NAStuff.AntiBreakSignals = {}
		return
	end
	const function clearOne(h)
		const arr = sigs[h]
		if arr then
			for _, c in arr do
				pcall(function()
					if c and type(c.Disconnect) == "function" then
						c:Disconnect()
					end
				end)
			end
			sigs[h] = nil
		end
	end
	if hum then
		clearOne(hum)
		return
	end
	for h in sigs do
		clearOne(h)
	end
end

NAmanage.AntiBreakRefreshCache = function(char, hum)
	const plr = Services.Players.LocalPlayer
	const c = char or (plr and plr.Character) or getChar()
	const h = hum or (c and (c:FindFirstChildOfClass("Humanoid") or c:FindFirstChildOfClass("AnimationController"))) or nil
	NAStuff.AntiBreakChar = c
	NAStuff.AntiBreakHum = h
	return c, h
end

NAmanage.AntiBreakPulse = function(hum)
	if not hum then return false end
	pcall(function()
		const breakOnDeath = NAlib.isProperty(hum, "BreakJointsOnDeath")
		if breakOnDeath ~= nil and breakOnDeath ~= false then
			NAlib.setProperty(hum, "BreakJointsOnDeath", false)
		end
	end)
	pcall(function()
		hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	end)
	local ok, st = pcall(function()
		return hum:GetState()
	end)
	if ok and st == Enum.HumanoidStateType.Dead then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Running)
		end)
	end
	return true
end

NAmanage.AntiBreakWire = function(hum)
	if not hum then return end
	NAStuff.AntiBreakSignals = NAStuff.AntiBreakSignals or {}
	if NAStuff.AntiBreakSignals[hum] then return end
	const arr = {}
	NAStuff.AntiBreakSignals[hum] = arr
	const function add(sig, fn)
		if not sig then return end
		local ok, c = pcall(function()
			return sig:Connect(fn)
		end)
		if ok and c then
			Insert(arr, c)
		end
	end
	add(hum:GetPropertyChangedSignal("BreakJointsOnDeath"), function()
		if NAStuff.AntiBreakEnabled then
			NAmanage.AntiBreakPulse(hum)
		end
	end)
	add(hum.StateChanged, function(_, state)
		if NAStuff.AntiBreakEnabled and state == Enum.HumanoidStateType.Dead then
			NAmanage.AntiBreakPulse(hum)
		end
	end)
	add(hum.Died, function()
		if NAStuff.AntiBreakEnabled then
			NAmanage.AntiBreakPulse(hum)
		end
	end)
	add(hum.Destroying, function()
		const st = shared.__antibreakjoints
		if st and st.saved then
			st.saved[hum] = nil
		end
		NAmanage.AntiBreakClearSignals(hum)
	end)
end

NAmanage.AntiBreakApply = function(hum)
	if not hum then return false end
	shared.__antibreakjoints = shared.__antibreakjoints or {saved = {}}
	const st = shared.__antibreakjoints
	if st.saved[hum] == nil then
		local okB, bjd = pcall(function()
			return hum.BreakJointsOnDeath
		end)
		local okD, dead = pcall(function()
			return hum:GetStateEnabled(Enum.HumanoidStateType.Dead)
		end)
		st.saved[hum] = {bjd = okB and bjd or nil, dead = okD and dead or nil}
	end
	NAmanage.AntiBreakWire(hum)
	return NAmanage.AntiBreakPulse(hum)
end

NAmanage.AntiBreakRestore = function(hum)
	if not hum then return 0 end
	const st = shared.__antibreakjoints
	const old = st and st.saved and st.saved[hum]
	NAmanage.AntiBreakClearSignals(hum)
	if old then
		if old.bjd ~= nil then pcall(function() hum.BreakJointsOnDeath = old.bjd end) end
		if old.dead ~= nil then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, old.dead) end) end
		st.saved[hum] = nil
		return 1
	end
	pcall(function() hum.BreakJointsOnDeath = true end)
	pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
	return 0
end

NAmanage.AntiBreakRestoreAll = function()
	const st = shared.__antibreakjoints
	const list = {}
	if st and st.saved then
		for hum in st.saved do
			Insert(list, hum)
		end
	end
	local n = 0
	for _, hum in list do
		n += NAmanage.AntiBreakRestore(hum)
	end
	NAmanage.AntiBreakClearSignals()
	return n
end

NAmanage.AntiBreakHook = function()
	if NAStuff.AntiBreakHooked then
		return true
	end
	if not (typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" and typeof(newcclosure) == "function" and typeof(checkcaller) == "function") then
		NAStuff.AntiBreakNoHook = true
		return false
	end
	NAStuff.AntiBreakHooked = true
	NAStuff.AntiBreakNoHook = false
	NAStuff.AntiBreakOldNC = NAStuff.AntiBreakOldNC or hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
		if NAStuff.AntiBreakEnabled then
			local m = getnamecallmethod()
			if type(m) == "string" then
				m = Lower(m)
			end
			if m ~= "breakjoints" and m ~= "setstateenabled" and m ~= "changestate" and m ~= "destroy" then
				return NAStuff.AntiBreakOldNC(self, ...)
			end
			if checkcaller() or typeof(self) ~= "Instance" then
				return NAStuff.AntiBreakOldNC(self, ...)
			end
			local hum = NAStuff.AntiBreakHum
			local char = NAStuff.AntiBreakChar
			if (not char) or (char.Parent == nil) or (hum and hum.Parent == nil) then
				char, hum = NAmanage.AntiBreakRefreshCache()
			end
			if m == "breakjoints" and char and (self == char or self:IsDescendantOf(char)) then
				return
			elseif hum and self == hum and m == "setstateenabled" then
				local state, enabled = ...
				if state == Enum.HumanoidStateType.Dead and enabled == true then
					return
				end
			elseif hum and self == hum and m == "changestate" then
				const state = ...
				if state == Enum.HumanoidStateType.Dead then
					return
				end
			elseif hum and self == hum and m == "destroy" then
				return
			end
		end
		return NAStuff.AntiBreakOldNC(self, ...)
	end))
	return true
end

NAmanage.AntiBreakStartWatch = function()
	NAlib.disconnect("antibreak_step")
	NAlib.disconnect("antibreak_loops")
	NAlib.connect("antibreak_loops", Services.RunService.PreSimulation:Connect(function()
		if not NAStuff.AntiBreakEnabled then return end
		local h = NAStuff.AntiBreakHum
		if not h or h.Parent == nil then
			local _, refreshedHum = NAmanage.AntiBreakRefreshCache()
			h = refreshedHum
		end
		if h then
			NAmanage.AntiBreakApply(h)
		end
	end))
end

cmd.add({"antibreakjoints","antibjoints","nobreakjoints"},{"antibreakjoints","Prevents local character joints from breaking when possible"},function()
	NAStuff.AntiBreakEnabled = true
	const hooked = NAmanage.AntiBreakHook()
	NAStuff.AntiBreakNoHook = not hooked
	const hum = getHum()
	if hum then
		NAmanage.AntiBreakRefreshCache(nil, hum)
		NAmanage.AntiBreakApply(hum)
	end
	NAmanage.AntiBreakStartWatch()
	NAlib.disconnect("antibreak_char")
	NAlib.connect("antibreak_char", Services.Players.LocalPlayer.CharacterAdded:Connect(function(char)
		if not NAStuff.AntiBreakEnabled then return end
		const h = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 10)
		if h then
			NAmanage.AntiBreakRefreshCache(char, h)
			NAmanage.AntiBreakApply(h)
		end
	end))
	DebugNotif("AntiBreakJoints enabled"..(NAStuff.AntiBreakNoHook and " (loop fallback)" or ""), 2)
end)

cmd.add({"unantibreakjoints","unantibjoints","breakjointsallowed"},{"unantibreakjoints","Disables AntiBreakJoints"},function()
	NAStuff.AntiBreakEnabled = false
	NAlib.disconnect("antibreak_step")
	NAlib.disconnect("antibreak_loops")
	NAlib.disconnect("antibreak_char")
	NAStuff.AntiBreakChar = nil
	NAStuff.AntiBreakHum = nil
	const n = NAmanage.AntiBreakRestoreAll()
	DebugNotif("AntiBreakJoints disabled ("..tostring(n).." humanoids restored)", 2)
end)

cmd.add({"breakjoints","bjoints"},{"breakjoints","Break your character joints and die"},function()
	const char = getChar()
	const hum = getHum()
	if not char then
		DebugNotif("No character found", 2)
		return
	end
	const was = NAStuff.AntiBreakEnabled
	NAStuff.AntiBreakEnabled = false
	if hum then
		pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
		pcall(function() hum.BreakJointsOnDeath = true end)
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
		pcall(function() hum.Health = 0 end)
	end
	pcall(function() char:BreakJoints() end)
	Delay(0.15, function()
		NAStuff.AntiBreakEnabled = was
	end)
end)


-- ts got patched gg
NAStuff.desyncOn = NAStuff.desyncOn or false
NAStuff.raknetDesyncOn = NAStuff.raknetDesyncOn or false

--[[
cmd.addPatched({"desync", "ngrep"},{"desync (ngrep)","Toggle NextGenReplicator desync / sync (run again to disable)"},function()
	if type(setfflag) ~= "function" then
		DoNotif("Your executor does not support setfflag. Cannot toggle desync", 3)
		return
	end

	if not NAStuff.desyncOn then
		ok, err = pcall(function()
			setfflag("NextGenReplicatorEnabledWrite4", "false")
			setfflag("NextGenReplicatorEnabledWrite4", "true")
		end)

		if ok then
			NAStuff.desyncOn = true
			DoNotif("NextGenReplicator desync / server authority enabled. Run the command again to disable it", 4)
		else
			DoNotif("Failed to apply NextGenReplicator flags: "..tostring(err), 4)
		end
	else
		ok, err = pcall(function()
			setfflag("NextGenReplicatorEnabledWrite4", "true")
			setfflag("NextGenReplicatorEnabledWrite4", "false")
		end)

		if ok then
			NAStuff.desyncOn = false
			DoNotif("NextGenReplicator sync restored (desync disabled)", 3)
		else
			DoNotif("Failed to restore NextGenReplicator flags: "..tostring(err), 4)
		end
	end
end)
]]

NAStuff.desyncOffsetAnchor = typeof(NAStuff.desyncOffsetAnchor) == "CFrame" and NAStuff.desyncOffsetAnchor or nil
NAStuff.desyncOffsetChar = nil
NAStuff.desyncOffsetCurrent = nil
NAStuff.desyncOffsetKey = "na_desync_offset_loop"
NAStuff.desyncOffsetPostKey = "na_desync_offset_post"
NAStuff.desyncOffsetRenderKey = "na_desync_offset_render"
NAStuff.desyncOffsetBindName = (NAmanage.GetSessionActionName and NAmanage.GetSessionActionName("DesyncOffsetBind")) or "NA_DesyncOffsetBind"
NAStuff.desyncOffsetEps = 0.05
NAStuff.desyncOffsetVisualState = type(NAStuff.desyncOffsetVisualState) == "table" and NAStuff.desyncOffsetVisualState or {}
NAStuff.desyncOffsetVisualState.ovPrefix = "DesyncOffset"

NAmanage.DesyncGetRoot = function()
	local char = getChar and getChar() or nil
	if not char and LocalPlayer then
		char = LocalPlayer.Character
	end
	const root = char and getRoot(char) or nil
	return char, root
end

NAmanage.DesyncReadRootCFrame = function(root)
	if not (root and root.Parent) then
		return nil
	end
	local ok, cf = pcall(function()
		return root.CFrame
	end)
	if ok and typeof(cf) == "CFrame" then
		return cf
	end
	return nil
end

NAmanage.DesyncIsLocalObject = function(obj)
	if typeof(obj) ~= "Instance" then
		return false
	end
	local char = getChar and getChar() or nil
	if not char and LocalPlayer then
		char = LocalPlayer.Character
	end
	return char ~= nil and (obj == char or obj:IsDescendantOf(char))
end

NAmanage.DesyncIsLocalRoot = function(root)
	if typeof(root) ~= "Instance" then
		return false
	end
	local char, liveRoot = NAmanage.DesyncGetRoot()
	if not char then
		return false
	end
	return root == liveRoot or root:IsDescendantOf(char)
end

NAmanage.DesyncNearAnchor = function(cf)
	const anchor = NAStuff.desyncOffsetAnchor
	if typeof(cf) ~= "CFrame" or typeof(anchor) ~= "CFrame" then
		return false
	end
	return (cf.Position - anchor.Position).Magnitude <= (tonumber(NAStuff.desyncOffsetEps) or 0.05)
end

NAmanage.DesyncVisualState = function()
	local st = NAStuff.desyncOffsetVisualState
	if type(st) ~= "table" then
		st = {}
		NAStuff.desyncOffsetVisualState = st
	end
	st.ovPrefix = "DesyncOffset"
	return st
end

NAmanage.DesyncClearVisualizer = function()
	const st = NAmanage.DesyncVisualState and NAmanage.DesyncVisualState() or nil
	if type(st) == "table" and type(NAmanage.ovClr) == "function" then
		pcall(NAmanage.ovClr, st)
		st.UndergroundTransform = nil
		st.ovNextUpd = nil
	end
end

NAmanage.DesyncUpdateVisualizer = function(force)
	const st = NAmanage.DesyncVisualState and NAmanage.DesyncVisualState() or nil
	if type(st) ~= "table" or type(NAmanage.ovUpd) ~= "function" then
		return
	end

	local char, root = NAmanage.DesyncGetRoot()
	const current = NAStuff.desyncOffsetCurrent
	const anchor = NAStuff.desyncOffsetAnchor
	if not (NAStuff.desyncOn and char and root and root.Parent and typeof(current) == "CFrame" and typeof(anchor) == "CFrame") then
		NAmanage.DesyncClearVisualizer()
		return
	end

	const off = anchor.Position - current.Position
	if off.Magnitude <= 0.0001 then
		NAmanage.DesyncClearVisualizer()
		return
	end

	const now = os.clock()
	const rate = tonumber(NAStuff.NA_OFFSET_VISUALIZER_UPDATE_RATE) or (1 / 30)
	if force or now >= (st.ovNextUpd or 0) then
		st.ovNextUpd = now + rate
		const currentRot = current - current.Position
		const anchorRot = anchor - anchor.Position
		st.UndergroundTransform = currentRot:ToObjectSpace(anchorRot)
		NAmanage.ovUpd(st, root, current, off)
	end
end

NAmanage.DesyncGetClientCFrame = function(root, fallback)
	if NAStuff.desyncOn and NAmanage.DesyncIsLocalRoot(root) then
		const cf = NAStuff.desyncOffsetCurrent
		if typeof(cf) == "CFrame" then
			return cf
		end
	end
	const cf = NAmanage.DesyncReadRootCFrame(root)
	if typeof(cf) == "CFrame" then
		return cf
	end
	if typeof(fallback) == "CFrame" then
		return fallback
	end
	return nil
end

NAmanage.DesyncSetClientCFrame = function(root, cf)
	if typeof(cf) ~= "CFrame" then
		return false
	end
	local char, liveRoot = NAmanage.DesyncGetRoot()
	root = root or liveRoot
	if not (char and root and root.Parent) then
		return false
	end
	if NAStuff.desyncOffsetChar ~= char then
		NAStuff.desyncOffsetChar = char
		NAStuff.desyncOffsetAnchor = NAmanage.DesyncReadRootCFrame(root) or cf
	end
	NAStuff.desyncOffsetCurrent = cf
	const ok = pcall(function()
		root.CFrame = cf
	end)
	if ok and type(NAmanage.DesyncUpdateVisualizer) == "function" then
		pcall(NAmanage.DesyncUpdateVisualizer, true)
	end
	return ok
end

NAmanage.DesyncSetRootCFrame = function(root, cf)
	if not (root and root.Parent and typeof(cf) == "CFrame") then
		return false
	end
	return pcall(function()
		root.CFrame = cf
	end)
end

NAmanage.DesyncOffsetStep = function()
	if not NAStuff.desyncOn then
		return
	end

	local char, root = NAmanage.DesyncGetRoot()
	if not (char and root and root.Parent) then
		return
	end

	const cf = NAmanage.DesyncReadRootCFrame(root)
	if typeof(cf) ~= "CFrame" then
		return
	end

	if NAStuff.desyncOffsetChar ~= char then
		NAStuff.desyncOffsetChar = char
		NAStuff.desyncOffsetAnchor = cf
		NAStuff.desyncOffsetCurrent = cf
	end

	local anchor = NAStuff.desyncOffsetAnchor
	if typeof(anchor) ~= "CFrame" then
		anchor = cf
		NAStuff.desyncOffsetAnchor = anchor
	end

	if typeof(NAStuff.desyncOffsetCurrent) ~= "CFrame" or not NAmanage.DesyncNearAnchor(cf) then
		NAStuff.desyncOffsetCurrent = cf
	end

	NAmanage.DesyncSetRootCFrame(root, anchor)
end

NAmanage.DesyncOffsetRender = function()
	if not NAStuff.desyncOn then
		return
	end

	local _, root = NAmanage.DesyncGetRoot()
	const cf = NAStuff.desyncOffsetCurrent
	if root and root.Parent and typeof(cf) == "CFrame" then
		NAmanage.DesyncSetRootCFrame(root, cf)
		NAmanage.DesyncUpdateVisualizer(false)
	else
		NAmanage.DesyncClearVisualizer()
	end
end

NAmanage.DesyncBindRender = function()
	if Services.RunService and Services.RunService.UnbindFromRenderStep then
		pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, NAStuff.desyncOffsetBindName)
	end
	NAlib.disconnect(NAStuff.desyncOffsetRenderKey)

	if Services.RunService and Services.RunService.BindToRenderStep then
		const ok = pcall(function()
			__lt.cm("RunService", "BindToRenderStep", NAStuff.desyncOffsetBindName, Enum.RenderPriority.First.Value, function()
				NAmanage.DesyncOffsetRender()
			end)
		end)
		if ok then
			return
		end
	end

	NAlib.reconnect(NAStuff.desyncOffsetRenderKey, Services.RunService.RenderStepped:Connect(function()
		NACaller(function()
			NAmanage.DesyncOffsetRender()
		end)
	end))
end

NAmanage.DesyncUnbindRender = function()
	NAlib.disconnect(NAStuff.desyncOffsetRenderKey)
	if Services.RunService and Services.RunService.UnbindFromRenderStep then
		pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, NAStuff.desyncOffsetBindName)
	end
end

do
	const oldClientCf = NAmanage.UG_clientCFrame
	if type(oldClientCf) == "function" then
		NAmanage.UG_clientCFrame = function(root, fallback)
			if NAStuff.desyncOn and NAmanage.DesyncIsLocalRoot(root) then
				const cf = NAmanage.DesyncGetClientCFrame(root, fallback)
				if typeof(cf) == "CFrame" then
					return cf
				end
			end
			return oldClientCf(root, fallback)
		end
	end

	const oldSetClient = NAmanage.UG_setClientCFrame
	if type(oldSetClient) == "function" then
		NAmanage.UG_setClientCFrame = function(root, cf)
			if NAStuff.desyncOn and NAmanage.DesyncIsLocalRoot(root) then
				return NAmanage.DesyncSetClientCFrame(root, cf)
			end
			return oldSetClient(root, cf)
		end
	end

	const oldSetRoot = NAmanage.UG_setRootCFrame
	if type(oldSetRoot) == "function" then
		NAmanage.UG_setRootCFrame = function(root, cf)
			if NAStuff.desyncOn and NAmanage.DesyncIsLocalRoot(root) then
				return NAmanage.DesyncSetClientCFrame(root, cf)
			end
			return oldSetRoot(root, cf)
		end
	end

	const oldPivot = NAmanage.safePivotModel
	if type(oldPivot) == "function" then
		NAmanage.safePivotModel = function(model, cf)
			if NAStuff.desyncOn and NAmanage.DesyncIsLocalObject(model) and typeof(cf) == "CFrame" then
				local root = (NAmanage.UG_rootForModel and NAmanage.UG_rootForModel(model)) or nil
				if not root and model:IsA("BasePart") then
					root = model
			elseif not root and model:IsA("Model") then
					root = model.PrimaryPart or getRoot(model)
			end
				if root then
					return NAmanage.DesyncSetClientCFrame(root, cf)
				end
			end
			return oldPivot(model, cf)
		end
	end
end

NAmanage.SetOffsetDesync = function(enabled)
	if enabled then
		local char, root = NAmanage.DesyncGetRoot()
		if not (char and root) then
			DoNotif("Unable to get your character root. Cannot enable offset desync", 3)
			return false
		end

		const cf = NAmanage.DesyncReadRootCFrame(root)
		if typeof(cf) ~= "CFrame" then
			DoNotif("Unable to read your character position. Cannot enable offset desync", 3)
			return false
		end

		NAlib.disconnect(NAStuff.desyncOffsetKey)
		NAlib.disconnect(NAStuff.desyncOffsetPostKey)
		NAmanage.DesyncUnbindRender()

		NAStuff.desyncOn = true
		NAStuff.desyncOffsetChar = char
		NAStuff.desyncOffsetAnchor = cf
		NAStuff.desyncOffsetCurrent = cf

		if Services.RunService and Services.RunService.PostSimulation then
			NAlib.reconnect(NAStuff.desyncOffsetPostKey, Services.RunService.PostSimulation:Connect(function()
				NACaller(function()
					NAmanage.DesyncOffsetStep()
				end)
			end))
		end

		NAlib.reconnect(NAStuff.desyncOffsetKey, Services.RunService.Heartbeat:Connect(function()
			NACaller(function()
				NAmanage.DesyncOffsetStep()
			end)
		end))

		NAmanage.DesyncBindRender()
		if type(NAmanage.DesyncUpdateVisualizer) == "function" then
			pcall(NAmanage.DesyncUpdateVisualizer, true)
		end
		DoNotif("Offset desync enabled. Server position locked with normal offset restore timing", 4)
		return true
	end

	NAStuff.desyncOn = false
	NAlib.disconnect(NAStuff.desyncOffsetKey)
	NAlib.disconnect(NAStuff.desyncOffsetPostKey)
	NAmanage.DesyncUnbindRender()

	local _, root = NAmanage.DesyncGetRoot()
	if root and typeof(NAStuff.desyncOffsetCurrent) == "CFrame" then
		NAmanage.DesyncSetRootCFrame(root, NAStuff.desyncOffsetCurrent)
	end

	NAStuff.desyncOffsetChar = nil
	NAStuff.desyncOffsetAnchor = nil
	NAStuff.desyncOffsetCurrent = nil
	NAmanage.DesyncClearVisualizer()
	DoNotif("Offset desync disabled", 3)
	return true
end

cmd.add({"desync", "ngrep"},{"desync (ngrep)","Toggle offset desync / sync (run again to disable)"},function()
	NAmanage.SetOffsetDesync(not NAStuff.desyncOn)
end)

cmd.add({"undesync", "undg", "syncdesync"},{"undesync (undg,syncdesync)","Disable offset desync"},function()
	NAmanage.SetOffsetDesync(false)
end)

NAmanage.getRaknet = function()
	local rk
	if type(_na_boot) == "table" and type(_na_boot.hostEnv) == "table" then
		rk = rawget(_na_boot.hostEnv, "raknet")
	end
	if rk == nil then
		pcall(function()
			rk = raknet
		end)
	end
	return rk
end
