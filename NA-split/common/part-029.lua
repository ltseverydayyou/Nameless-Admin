NAmanage.UG_cframeNear = function(a, b, distance, angleTolerance)
	if typeof(a) ~= "CFrame" or typeof(b) ~= "CFrame" then
		return false
	end
	if (a.Position - b.Position).Magnitude > (distance or 0.05) then
		return false
	end
	local relative = a:ToObjectSpace(b)
	local _, angle = relative:ToAxisAngle()
	return math.abs(angle) <= (angleTolerance or math.rad(0.5))
end

NAStuff.NASpoofState = type(NAStuff.NASpoofState) == "table" and NAStuff.NASpoofState or {
	Started = false;
	RenderName = "NA_SpoofScheduler_Render";
	Connections = {};
	CharacterTransform = {
		Enabled = false;
		Offset = Vector3.new(0, 0, 0);
		Rotation = CFrame.new();
		LocalCFrame = nil;
		SpoofedCFrame = nil;
	};
	Velocity = {
		Enabled = false;
		Linear = Vector3.new(0, 0, 0);
		Angular = Vector3.new(0, 0, 0);
		MaskLinear = Vector3.new(0, 0, 0);
		MaskAngular = Vector3.new(0, 0, 0);
	};
	PartTransform = {
		Enabled = false;
		Root = nil;
		Offset = Vector3.new(0, 0, 0);
		Rotation = CFrame.new();
		LocalCFrame = nil;
		SpoofedCFrame = nil;
	};
	Pose = {
		Enabled = false;
		Character = nil;
		Motors = {};
	};
	HumanoidMasks = {};
	HumanoidOriginal = setmetatable({}, {__mode = "k"});
}

NAmanage.Spoof_parseNumbers = function(...)
	const out = {}
	for i = 1, select("#", ...) do
		const value = select(i, ...)
		for token in tostring(value or ""):gmatch("[^,%s]+") do
			const numberValue = tonumber(token)
			if numberValue then
				Insert(out, numberValue)
			end
		end
	end
	return out
end

NAmanage.Spoof_parseBoolean = function(value)
	if type(value) == "boolean" then
		return value
	end
	const text = Lower(tostring(value or ""))
	if text == "true" or text == "1" or text == "yes" or text == "on" then
		return true
	end
	if text == "false" or text == "0" or text == "no" or text == "off" then
		return false
	end
	return nil
end

NAmanage.Spoof_serverCFrame = function(localCFrame, offset, rotation)
	return (localCFrame * rotation) + offset
end

NAmanage.Spoof_capturePose = function(state)
	const char = getChar()
	state.Pose.Character = char
	table.clear(state.Pose.Motors)
	if not char then
		return
	end
	for _, obj in char:GetDescendants() do
		if obj:IsA("Motor6D") then
			state.Pose.Motors[obj] = obj.Transform
		end
	end
end

NAStuff.NASpoofHumanoidAllowed = NAStuff.NASpoofHumanoidAllowed or {
	WalkSpeed = "number";
	JumpPower = "number";
	JumpHeight = "number";
	HipHeight = "number";
	MaxSlopeAngle = "number";
	AutoRotate = "boolean";
	PlatformStand = "boolean";
	Sit = "boolean";
	UseJumpPower = "boolean";
}

NAmanage.Spoof_parseHumanoidValue = function(property, value)
	const kind = NAStuff.NASpoofHumanoidAllowed[property]
	if kind == "number" then
		return tonumber(value)
	end
	if kind == "boolean" then
		return NAmanage.Spoof_parseBoolean(value)
	end
	return nil
end

NAmanage.Spoof_rememberHumanoidOriginal = function(state, hum, property)
	if not hum then
		return
	end
	local bucket = state.HumanoidOriginal[hum]
	if not bucket then
		bucket = {}
		state.HumanoidOriginal[hum] = bucket
	end
	if bucket[property] == nil then
		local ok, value = pcall(function()
			return hum[property]
		end)
		if ok then
			bucket[property] = value
		end
	end
end

NAmanage.Spoof_setHumanoidProperty = function(hum, property, value)
	if not hum or value == nil then
		return
	end
	pcall(function()
		hum[property] = value
	end)
end

NAmanage.Spoof_restoreHumanoidProperty = function(state, property)
	for hum, bucket in state.HumanoidOriginal do
		if hum and hum.Parent and bucket[property] ~= nil then
			NAmanage.Spoof_setHumanoidProperty(hum, property, bucket[property])
		end
		bucket[property] = nil
	end
	state.HumanoidMasks[property] = nil
end

NAmanage.Spoof_restoreAllHumanoid = function(state)
	for hum, bucket in state.HumanoidOriginal do
		if hum and hum.Parent then
			for property, value in bucket do
				NAmanage.Spoof_setHumanoidProperty(hum, property, value)
			end
		end
	end
	table.clear(state.HumanoidMasks)
	state.HumanoidOriginal = setmetatable({}, {__mode = "k"})
end

NAmanage.Spoof_restoreTransforms = function(state)
	const root = getRoot(getChar())
	if root and typeof(state.CharacterTransform.LocalCFrame) == "CFrame" then
		pcall(function()
			root.CFrame = state.CharacterTransform.LocalCFrame
		end)
	end
	const partState = state.PartTransform
	if partState.Root and partState.Root.Parent and typeof(partState.LocalCFrame) == "CFrame" then
		pcall(function()
			partState.Root.CFrame = partState.LocalCFrame
		end)
	end
end

NAmanage.Spoof_restoreVelocity = function(state)
	const root = getRoot(getChar())
	if root and state.Velocity.Enabled then
		pcall(function()
			root.AssemblyLinearVelocity = state.Velocity.Linear
			root.AssemblyAngularVelocity = state.Velocity.Angular
		end)
	end
end

NAmanage.Spoof_stop = function(message)
	const state = NAStuff.NASpoofState
	NAmanage.Spoof_restoreTransforms(state)
	NAmanage.Spoof_restoreVelocity(state)
	NAmanage.Spoof_restoreAllHumanoid(state)
	for key, connection in state.Connections do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
		state.Connections[key] = nil
	end
	if Services.RunService and Services.RunService.UnbindFromRenderStep then
		pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, state.RenderName)
	end
	state.CharacterTransform.Enabled = false
	state.CharacterTransform.SpoofedCFrame = nil
	state.Velocity.Enabled = false
	state.PartTransform.Enabled = false
	state.PartTransform.Root = nil
	state.PartTransform.SpoofedCFrame = nil
	state.Pose.Enabled = false
	table.clear(state.Pose.Motors)
	state.Started = false
	if message and type(DoNotif) == "function" then
		DoNotif(message, 3)
	end
end

NAmanage.Spoof_start = function()
	const state = NAStuff.NASpoofState
	if state.Started then
		return true
	end
	const runService = Services.RunService
	if not runService then
		return false
	end
	state.Started = true
	const preSignal = runService.PreSimulation or runService.Stepped
	state.Connections.PreSimulation = preSignal:Connect(function()
		const root = getRoot(getChar())
		const hum = getHum(getChar())
		if root and state.Velocity.Enabled then
			pcall(function()
				root.AssemblyLinearVelocity = state.Velocity.Linear
				root.AssemblyAngularVelocity = state.Velocity.Angular
			end)
		end
		if hum then
			for property, entry in state.HumanoidMasks do
				NAmanage.Spoof_rememberHumanoidOriginal(state, hum, property)
				NAmanage.Spoof_setHumanoidProperty(hum, property, entry.Real)
			end
		end
	end)
	state.Connections.Heartbeat = runService.Heartbeat:Connect(function()
		const char = getChar()
		const root = getRoot(char)
		if root and state.Velocity.Enabled then
			local okLinear, linear = pcall(function()
				return root.AssemblyLinearVelocity
			end)
			local okAngular, angular = pcall(function()
				return root.AssemblyAngularVelocity
			end)
			if okLinear then
				state.Velocity.Linear = linear
			end
			if okAngular then
				state.Velocity.Angular = angular
			end
		end
		if root and state.CharacterTransform.Enabled then
			const observed = root.CFrame
			if not NAmanage.UG_cframeNear(observed, state.CharacterTransform.SpoofedCFrame, 0.08) then
				state.CharacterTransform.LocalCFrame = observed
			end
			const base = state.CharacterTransform.LocalCFrame or observed
			const spoofed = NAmanage.Spoof_serverCFrame(base, state.CharacterTransform.Offset, state.CharacterTransform.Rotation)
			state.CharacterTransform.SpoofedCFrame = spoofed
			root.CFrame = spoofed
		end
		const partState = state.PartTransform
		if partState.Enabled and partState.Root and partState.Root.Parent then
			const observed = partState.Root.CFrame
			if not NAmanage.UG_cframeNear(observed, partState.SpoofedCFrame, 0.08) then
				partState.LocalCFrame = observed
			end
			const base = partState.LocalCFrame or observed
			const spoofed = NAmanage.Spoof_serverCFrame(base, partState.Offset, partState.Rotation)
			partState.SpoofedCFrame = spoofed
			partState.Root.CFrame = spoofed
		end
		if root and state.Velocity.Enabled then
			pcall(function()
				root.AssemblyLinearVelocity = state.Velocity.MaskLinear
				root.AssemblyAngularVelocity = state.Velocity.MaskAngular
			end)
		end
		const hum = getHum(char)
		if hum then
			for property, entry in state.HumanoidMasks do
				NAmanage.Spoof_rememberHumanoidOriginal(state, hum, property)
				NAmanage.Spoof_setHumanoidProperty(hum, property, entry.Mask)
			end
		end
	end)
	if runService.UnbindFromRenderStep then
		pcall(runService.UnbindFromRenderStep, runService, state.RenderName)
	end
	__lt.cm("RunService", "BindToRenderStep", state.RenderName, Enum.RenderPriority.First.Value, function()
		const char = getChar()
		const root = getRoot(char)
		if root and state.CharacterTransform.Enabled and typeof(state.CharacterTransform.LocalCFrame) == "CFrame" then
			root.CFrame = state.CharacterTransform.LocalCFrame
		end
		const partState = state.PartTransform
		if partState.Enabled and partState.Root and partState.Root.Parent and typeof(partState.LocalCFrame) == "CFrame" then
			partState.Root.CFrame = partState.LocalCFrame
		end
		if root and state.Velocity.Enabled then
			pcall(function()
				root.AssemblyLinearVelocity = state.Velocity.Linear
				root.AssemblyAngularVelocity = state.Velocity.Angular
			end)
		end
		const hum = getHum(char)
		if hum then
			for property, entry in state.HumanoidMasks do
				NAmanage.Spoof_rememberHumanoidOriginal(state, hum, property)
				NAmanage.Spoof_setHumanoidProperty(hum, property, entry.Real)
			end
		end
		if state.Pose.Enabled then
			if char ~= state.Pose.Character then
				NAmanage.Spoof_capturePose(state)
			end
			for motor, transform in state.Pose.Motors do
				if motor and motor.Parent then
					motor.Transform = transform
				else
					state.Pose.Motors[motor] = nil
				end
			end
		end
	end)
	return true
end

NAmanage.Spoof_transformFromNumbers = function(values)
	const x = values[1] or 0
	const y = values[2] or 0
	const z = values[3] or 0
	const pitch = math.rad(values[4] or 0)
	const yaw = math.rad(values[5] or 0)
	const roll = math.rad(values[6] or 0)
	return Vector3.new(x, y, z), CFrame.Angles(pitch, yaw, roll)
end

cmd.add({"spooftransform","stf"},{"spooftransform [x y z pitch yaw roll]","Spoofs replicated character position/rotation while restoring the local render transform"},function(...)
	if not NAmanage.Spoof_start() then
		DoNotif("Unable to start spoof scheduler", 2)
		return
	end
	const values = NAmanage.Spoof_parseNumbers(...)
	if #values < 3 then
		DoNotif("Usage: spooftransform x y z [pitch yaw roll]", 3)
		return
	end
	const root = getRoot(getChar())
	if not root then
		DoNotif("Character root unavailable", 2)
		return
	end
	const state = NAStuff.NASpoofState
	local offset, rotation = NAmanage.Spoof_transformFromNumbers(values)
	state.CharacterTransform.Offset = offset
	state.CharacterTransform.Rotation = rotation
	state.CharacterTransform.LocalCFrame = root.CFrame
	state.CharacterTransform.SpoofedCFrame = nil
	state.CharacterTransform.Enabled = true
	DoNotif("Character transform spoof enabled", 2)
end,true)

cmd.add({"unspooftransform","unstf"},{"unspooftransform","Disables character transform spoofing"},function()
	const state = NAStuff.NASpoofState
	const root = getRoot(getChar())
	if root and typeof(state.CharacterTransform.LocalCFrame) == "CFrame" then
		root.CFrame = state.CharacterTransform.LocalCFrame
	end
	state.CharacterTransform.Enabled = false
	state.CharacterTransform.SpoofedCFrame = nil
	DoNotif("Character transform spoof disabled", 2)
end)

cmd.add({"spoofwalk","swalk"},{"spoofwalk [realSpeed maskedSpeed]","Uses one WalkSpeed for local simulation while exposing another around replication"},function(...)
	if not NAmanage.Spoof_start() then
		DoNotif("Unable to start spoof scheduler", 2)
		return
	end
	const values = NAmanage.Spoof_parseNumbers(...)
	const real = values[1]
	if not real then
		DoNotif("Usage: spoofwalk realSpeed [maskedSpeed]", 3)
		return
	end
	const hum = getHum(getChar())
	if not hum then
		DoNotif("Humanoid unavailable", 2)
		return
	end
	const state = NAStuff.NASpoofState
	NAmanage.Spoof_rememberHumanoidOriginal(state, hum, "WalkSpeed")
	const bucket = state.HumanoidOriginal[hum]
	const mask = values[2] == nil and ((bucket and bucket.WalkSpeed) or hum.WalkSpeed) or values[2]
	state.HumanoidMasks.WalkSpeed = {Real = real; Mask = mask;}
	DoNotif(("WalkSpeed spoof: simulation %.3f / masked %.3f"):format(real, mask), 3)
end,true)

cmd.add({"unspoofwalk","unswalk"},{"unspoofwalk","Disables WalkSpeed masking and restores the original value"},function()
	NAmanage.Spoof_restoreHumanoidProperty(NAStuff.NASpoofState, "WalkSpeed")
	DoNotif("WalkSpeed spoof disabled", 2)
end)

cmd.add({"spoofvelocity","svel"},{"spoofvelocity [linX linY linZ angX angY angZ]","Preserves local simulation velocity while exposing masked linear/angular assembly velocity"},function(...)
	if not NAmanage.Spoof_start() then
		DoNotif("Unable to start spoof scheduler", 2)
		return
	end
	const root = getRoot(getChar())
	if not root then
		DoNotif("Character root unavailable", 2)
		return
	end
	const values = NAmanage.Spoof_parseNumbers(...)
	const state = NAStuff.NASpoofState
	state.Velocity.Linear = root.AssemblyLinearVelocity
	state.Velocity.Angular = root.AssemblyAngularVelocity
	state.Velocity.MaskLinear = Vector3.new(values[1] or 0, values[2] or 0, values[3] or 0)
	state.Velocity.MaskAngular = Vector3.new(values[4] or 0, values[5] or 0, values[6] or 0)
	state.Velocity.Enabled = true
	DoNotif("Velocity spoof enabled", 2)
end)

cmd.add({"unspoofvelocity","unsvel"},{"unspoofvelocity","Disables linear/angular velocity spoofing"},function()
	const state = NAStuff.NASpoofState
	NAmanage.Spoof_restoreVelocity(state)
	state.Velocity.Enabled = false
	DoNotif("Velocity spoof disabled", 2)
end)

cmd.add({"spoofpart","spart","spoofvehicle"},{"spoofpart [x y z pitch yaw roll]","Spoofs the unanchored assembly under your cursor while restoring it locally"},function(...)
	if not NAmanage.Spoof_start() then
		DoNotif("Unable to start spoof scheduler", 2)
		return
	end
	const values = NAmanage.Spoof_parseNumbers(...)
	if #values < 3 then
		DoNotif("Usage: spoofpart x y z [pitch yaw roll]", 3)
		return
	end
	const mouse = NAmanage.GetMouse(player)
	const target = mouse and mouse.Target
	if not target or not target:IsA("BasePart") then
		DoNotif("Point at an unanchored part or vehicle first", 3)
		return
	end
	const char = getChar()
	if char and target:IsDescendantOf(char) then
		DoNotif("Target must not be your character", 2)
		return
	end
	const assemblyRoot = target.AssemblyRootPart or target
	if assemblyRoot.Anchored then
		DoNotif("Target assembly is anchored", 2)
		return
	end
	const state = NAStuff.NASpoofState
	local offset, rotation = NAmanage.Spoof_transformFromNumbers(values)
	state.PartTransform.Root = assemblyRoot
	state.PartTransform.Offset = offset
	state.PartTransform.Rotation = rotation
	state.PartTransform.LocalCFrame = assemblyRoot.CFrame
	state.PartTransform.SpoofedCFrame = nil
	state.PartTransform.Enabled = true
	DoNotif("Part/vehicle transform spoof enabled", 2)
end,true)

cmd.add({"unspoofpart","unspart","unspoofvehicle"},{"unspoofpart","Disables the current part/vehicle transform spoof"},function()
	const state = NAStuff.NASpoofState
	const partState = state.PartTransform
	if partState.Root and partState.Root.Parent and typeof(partState.LocalCFrame) == "CFrame" then
		partState.Root.CFrame = partState.LocalCFrame
	end
	partState.Enabled = false
	partState.Root = nil
	partState.LocalCFrame = nil
	partState.SpoofedCFrame = nil
	DoNotif("Part/vehicle spoof disabled", 2)
end)

cmd.add({"posesplit","spose"},{"posesplit","Freezes the locally rendered Motor6D pose while animation tracks continue"},function()
	if not NAmanage.Spoof_start() then
		DoNotif("Unable to start spoof scheduler", 2)
		return
	end
	const state = NAStuff.NASpoofState
	NAmanage.Spoof_capturePose(state)
	state.Pose.Enabled = true
	DoNotif("Local pose split enabled", 2)
end)

cmd.add({"unposesplit","unspose"},{"unposesplit","Disables the local pose split"},function()
	const state = NAStuff.NASpoofState
	state.Pose.Enabled = false
	table.clear(state.Pose.Motors)
	DoNotif("Local pose split disabled", 2)
end)

cmd.add({"humspoof","shum"},{"humspoof [property realValue maskValue]","Masks selected Humanoid physics properties between simulation and replication"},function(property, realValue, maskValue)
	if not NAmanage.Spoof_start() then
		DoNotif("Unable to start spoof scheduler", 2)
		return
	end
	property = tostring(property or "")
	if not NAStuff.NASpoofHumanoidAllowed[property] then
		DoNotif("Unsupported Humanoid property", 3)
		return
	end
	const real = NAmanage.Spoof_parseHumanoidValue(property, realValue)
	const mask = NAmanage.Spoof_parseHumanoidValue(property, maskValue)
	if real == nil or mask == nil then
		DoNotif("Invalid values for "..property, 3)
		return
	end
	const hum = getHum(getChar())
	if not hum then
		DoNotif("Humanoid unavailable", 2)
		return
	end
	const state = NAStuff.NASpoofState
	NAmanage.Spoof_rememberHumanoidOriginal(state, hum, property)
	state.HumanoidMasks[property] = {Real = real; Mask = mask;}
	DoNotif(property.." masking enabled", 2)
end,true)

cmd.add({"unhumspoof","unshum"},{"unhumspoof [property|all]","Disables one Humanoid property mask or all masks"},function(property)
	property = tostring(property or "all")
	const state = NAStuff.NASpoofState
	if property == "" or Lower(property) == "all" then
		NAmanage.Spoof_restoreAllHumanoid(state)
		DoNotif("All Humanoid masks disabled", 2)
		return
	end
	if not NAStuff.NASpoofHumanoidAllowed[property] then
		DoNotif("Unsupported Humanoid property", 3)
		return
	end
	NAmanage.Spoof_restoreHumanoidProperty(state, property)
	DoNotif(property.." masking disabled", 2)
end)

cmd.add({"spoofstatus","sstatus"},{"spoofstatus","Shows currently enabled spoof features"},function()
	const state = NAStuff.NASpoofState
	const hum = {}
	for property in state.HumanoidMasks do
		Insert(hum, property)
	end
	table.sort(hum)
	DoNotif(("transform=%s | velocity=%s | part=%s | pose=%s | hum=%s"):format(
		tostring(state.CharacterTransform.Enabled),
		tostring(state.Velocity.Enabled),
		tostring(state.PartTransform.Enabled),
		tostring(state.Pose.Enabled),
		#hum > 0 and Concat(hum, ",") or "none"
	), 6)
end)

cmd.add({"unloadspoofs","unspoofall"},{"unloadspoofs","Stops every spoof feature and restores saved state"},function()
	NAmanage.Spoof_stop("Spoof state restored")
end)
