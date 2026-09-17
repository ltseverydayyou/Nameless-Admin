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

do
	local __NAChatHost = (type(getgenv) == "function" and getgenv()) or _G or {}
	local __NAChatGlobal = _G
	if type(__NAChatGlobal) == "table" and type(rawget(__NAChatGlobal, "NAChatGameActivityEnabled")) ~= "function" then
		rawset(__NAChatGlobal, "NAChatGameActivityEnabled", function()
			local enabled = true
			if NAmanage and type(NAmanage.NASettingsEnsure) == "function" then
				local ok, settings = pcall(NAmanage.NASettingsEnsure)
				if ok and type(settings) == "table" and type(settings.naChatGameActivity) == "boolean" then
					enabled = settings.naChatGameActivity
				end
			end
			return enabled
		end)
	end
end

NAgui.nachat = function()
	local frame = NAUIMANAGER and NAUIMANAGER.NAchatFrame
	if not frame then
		return
	end
	frame.Visible = true
	if NAmanage and type(NAmanage.NAChat_ApplyResponsive) == "function" then
		pcall(NAmanage.NAChat_ApplyResponsive, true)
	elseif NAmanage and type(NAmanage.centerFrame) == "function" then
		frame.AnchorPoint = Vector2.new(0, 0)
		pcall(NAmanage.centerFrame, frame)
	end
	if NAmanage and NAmanage.CustomScroll and NAmanage.CustomScroll.refreshAll then
		pcall(NAmanage.CustomScroll.refreshAll)
	end
end

if cmd and type(cmd.add) == "function" then
	cmd.add({"nachat", "nachatui", "nachatbox"}, {"nachat", "Open the Nameless Admin chat UI"}, function()
		NAgui.nachat()
	end)
end
originalIO.runNACHAT=function()
	local Players = (Services and Services.Players) or (SafeGetService and SafeGetService("Players"))
	local RunService = (Services and Services.RunService) or (SafeGetService and SafeGetService("RunService"))
	if not Players then
		warn("[NA Chat] Players service unavailable; chat startup skipped")
		return
	end
	local chatFrame = NAUIMANAGER and NAUIMANAGER.NAchatFrame
	local chatScroll = NAUIMANAGER and NAUIMANAGER.NAchatChatScroll
	local chatLayout = NAUIMANAGER and NAUIMANAGER.NAchatListLayout
	local usersScroll = NAUIMANAGER and NAUIMANAGER.NAchatUsersScroll
	local usersLayout = NAUIMANAGER and NAUIMANAGER.NAchatUserListLayout
	local usersSearchBox = NAUIMANAGER and NAUIMANAGER.NAchatUsersSearch
	local inputBox = NAUIMANAGER and NAUIMANAGER.NAchatInput
	local sendBtn = NAUIMANAGER and NAUIMANAGER.NAchatSendButton
	local clearBtn = NAUIMANAGER and NAUIMANAGER.NAchatClearButton
	local statusLabel = NAUIMANAGER and NAUIMANAGER.NAchatStatusLabel
	local reconnectBtn = NAUIMANAGER and NAUIMANAGER.NAchatReconnectButton
	local chatTab = NAUIMANAGER and NAUIMANAGER.NAchatChatTab
	local usersTab = NAUIMANAGER and NAUIMANAGER.NAchatUsersTab
	local adminTab = nil
	local adminFrame = nil
	local adminFrameUpdateBanList = nil
	local refreshAdminTabUI = nil
	local adminTabBound = false
	local adminListTickerActive = false
	local visibilityBtn = NAUIMANAGER and NAUIMANAGER.NAchatVisibility
	local gameActivityBtn = NAUIMANAGER and NAUIMANAGER.NAchatGameActivity
	local dmNotifBtn = NAUIMANAGER and NAUIMANAGER.NAchatDmNotifyButton

	local function syncAdminFrameLayout()
		if adminFrame and chatScroll then
			adminFrame.AnchorPoint = chatScroll.AnchorPoint or Vector2.new(0.5, 0)
			adminFrame.Size = chatScroll.Size
			adminFrame.Position = chatScroll.Position
		end
	end

	local function refreshChatResponsive(center)
		Defer(function()
			if chatFrame and chatFrame.Parent and NAmanage and type(NAmanage.NAChat_ApplyResponsive) == "function" then
				pcall(NAmanage.NAChat_ApplyResponsive, center == true)
			end
			syncAdminFrameLayout()
		end)
	end

	refreshChatResponsive(false)
	NAlib.disconnect("NAChatResponsive")
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect("NAChatResponsive", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			refreshChatResponsive(true)
		end))
	end
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NAChatResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			refreshChatResponsive(true)
		end))
	end
	if NAUIMANAGER and NAUIMANAGER.AUTOSCALER then
		NAlib.connect("NAChatResponsive", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(function()
			refreshChatResponsive(true)
		end))
	end

	if NAmanage and type(NAmanage.NAChatNormalizeZIndex) == "function" then
		pcall(NAmanage.NAChatNormalizeZIndex)
	end

	local CHAT_ACCENT = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	local CHAT_SURFACE = Color3.fromRGB(29, 31, 42)
	local CHAT_SURFACE_MUTED = Color3.fromRGB(37, 39, 51)
	local CHAT_ON = Color3.fromRGB(36, 111, 83)
	local CHAT_OFF = Color3.fromRGB(38, 40, 52)
	local CHAT_WARN = Color3.fromRGB(133, 78, 42)
	local CHAT_DANGER = Color3.fromRGB(126, 52, 66)

	local function ensureChatStroke(item, color, transparency)
		if not item then return nil end
		local stroke = item:FindFirstChild("NAChatStroke")
		if not stroke then
			stroke = InstanceNew("UIStroke", item)
			stroke.Name = "NAChatStroke"
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		end
		stroke.Thickness = 1
		stroke.Color = color or CHAT_ACCENT
		stroke.Transparency = transparency == nil and 0.48 or transparency
		if NAgui and type(NAgui.RegisterColoredStroke) == "function" then
			pcall(NAgui.RegisterColoredStroke, stroke)
		end
		return stroke
	end

	local function styleChatTab(button, selected)
		if not button then return end
		button.AutoButtonColor = false
		button.BackgroundColor3 = selected and Color3.fromRGB(72, 54, 126) or CHAT_OFF
		button.BackgroundTransparency = selected and 0.04 or 0.08
		button.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(196, 199, 214)
		button.TextSize = 12
		local corner = button:FindFirstChildOfClass("UICorner")
		if corner then corner.CornerRadius = UDim.new(0, 7) end
		ensureChatStroke(button, selected and CHAT_ACCENT or Color3.fromRGB(83, 85, 105), selected and 0.12 or 0.6)
	end

	local function styleChatToggle(button, enabled, onText, offText)
		if not button then return end
		button.AutoButtonColor = false
		button.BackgroundColor3 = enabled and CHAT_ON or CHAT_OFF
		button.BackgroundTransparency = 0.04
		button.TextColor3 = enabled and Color3.fromRGB(220, 255, 238) or Color3.fromRGB(194, 197, 211)
		button.Text = enabled and onText or offText
		button.TextSize = 12
		ensureChatStroke(button, enabled and Color3.fromRGB(89, 210, 151) or Color3.fromRGB(83, 85, 105), enabled and 0.12 or 0.58)
	end

	if chatFrame then
		local NAChat = {
			service = nil,
			connecting = false,
			wired = false,
			isHidden = false,
			serverIsAdmin = false,
			activeTab = "chat",
			users = {},
			currentDMTarget = nil,
			activeConversation = "public",
			activeGroupId = nil,
		}
		local conversationHistory = { public = {} }
		local groupRecords = {}
		local groupButton = nil
		local groupPopup = nil
		local groupListFrame = nil
		local groupNameInput = nil
		local groupInviteInput = nil
		local groupInviteButton = nil
		local groupLeaveButton = nil
		local switchConversation
		local refreshGroupPicker
		local function isChatUiSuppressed()
			return NAChat.isHidden and not NAChat.serverIsAdmin
		end

		local function getUIScale()
			local scaleObj = NAUIMANAGER and NAUIMANAGER.AUTOSCALER
			local scale = (scaleObj and tonumber(scaleObj.Scale)) or 1
			if not scale or scale <= 0 then
				scale = 1
			end
			return scale
		end

		local function scrollMetrics(scrollFrame)
			if not scrollFrame then
				return 0, 0, 0, getUIScale()
			end

			local scale = getUIScale()

			local canvasY = 0
			pcall(function()
				local cs = scrollFrame.CanvasSize
				canvasY = (cs and cs.Y and cs.Y.Offset) or 0
			end)
			if canvasY <= 0 then
				pcall(function()
					local absCanvas = scrollFrame.AbsoluteCanvasSize
					if typeof(absCanvas) == "Vector2" then
						canvasY = absCanvas.Y / scale
					end
				end)
			end

			local windowY = 0
			pcall(function()
				local absWindow = scrollFrame.AbsoluteWindowSize
				if typeof(absWindow) == "Vector2" then
					windowY = absWindow.Y / scale
				end
			end)
			if windowY <= 0 then
				pcall(function()
					local absSize = scrollFrame.AbsoluteSize
					if typeof(absSize) == "Vector2" then
						windowY = absSize.Y / scale
					end
				end)
			end

			local currentY = 0
			pcall(function()
				currentY = (scrollFrame.CanvasPosition and scrollFrame.CanvasPosition.Y) or 0
			end)

			return canvasY, windowY, currentY, scale
		end

		local function shouldAutoScroll(scrollFrame)
			local canvasY, windowY, currentY, scale = scrollMetrics(scrollFrame)
			if canvasY <= 0 or windowY <= 0 then
				return true
			end

			local threshold = 8 / scale
			if canvasY <= windowY + (1 / scale) then
				return true
			end

			local distanceFromBottom = canvasY - (currentY + windowY)
			return distanceFromBottom <= threshold
		end

		local scrollSt = setmetatable({}, { __mode = "k" })
		local scrollToBottomSoon

		local function bindAutoScroll(sf, layout)
			if not sf or not layout or sf:GetAttribute("NAChatAutoBound") then
				return
			end
			sf:SetAttribute("NAChatAutoBound", true)

			scrollSt[sf] = { locked = false, pending = false, prog = false }

			local function upd()
				if not (sf and sf.Parent and layout and layout.Parent) then
					return
				end
				local y = 0
				pcall(function()
					y = layout.AbsoluteContentSize.Y
				end)
				sf.CanvasSize = UDim2.new(0, 0, 0, y + 8)
				if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
					NAmanage.CustomScroll.refreshByTarget(sf)
				end
				local st = scrollSt[sf]
				if st and not st.locked and scrollToBottomSoon then
					scrollToBottomSoon(sf)
				end
			end

			upd()
			layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)

			sf:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				local st = scrollSt[sf]
				if not st or st.prog then
					return
				end

				local canvasY, windowY, currentY, scale = scrollMetrics(sf)
				if canvasY <= 0 or windowY <= 0 then
					st.locked = false
					return
				end

				local th = 14 / (scale > 0 and scale or 1)
				local dist = canvasY - (currentY + windowY)
				st.locked = dist > th
			end)
		end

		local function canAutoScroll(sf)
			local st = sf and scrollSt[sf]
			return not (st and st.locked)
		end

		local function scrollToBottom(scrollFrame)
			if not scrollFrame or not canAutoScroll(scrollFrame) then
				return
			end

			local st = scrollSt[scrollFrame]
			if st then
				st.prog = true
			end

			local canvasY, windowY = scrollMetrics(scrollFrame)
			local targetY = math.max(0, canvasY - windowY)
			scrollFrame.CanvasPosition = Vector2.new(0, targetY)

			if st then
				Defer(function()
					Wait()
					if scrollFrame and scrollFrame.Parent then
						st.prog = false
					end
				end)
			end
		end

		scrollToBottomSoon = function(scrollFrame)
			if not scrollFrame or not canAutoScroll(scrollFrame) then
				return
			end

			local st = scrollSt[scrollFrame]
			if st and st.pending then
				return
			end
			if st then
				st.pending = true
			end

			local scheduledY = 0
			pcall(function()
				scheduledY = (scrollFrame.CanvasPosition and scrollFrame.CanvasPosition.Y) or 0
			end)

			Defer(function()
				if not (scrollFrame and scrollFrame.Parent) then
					if st then st.pending = false end
					return
				end
				Wait()
				Wait()
				if not (scrollFrame and scrollFrame.Parent) then
					if st then st.pending = false end
					return
				end
				if not canAutoScroll(scrollFrame) then
					if st then st.pending = false end
					return
				end

				local currentY = 0
				pcall(function()
					currentY = (scrollFrame.CanvasPosition and scrollFrame.CanvasPosition.Y) or 0
				end)

				local _, _, _, scale = scrollMetrics(scrollFrame)
				local cancelDelta = 6 / (scale > 0 and scale or 1)
				if currentY < (scheduledY - cancelDelta) then
					if st then st.pending = false end
					return
				end

				scrollToBottom(scrollFrame)
				if st then st.pending = false end
			end)
		end
		originalIO.NAChatAuto = originalIO.NAChatAuto or {}
		originalIO.NAChatAuto.botSoon = scrollToBottomSoon
		local permanentFailureReason = nil
		local usersUpdateGeneration = 0
		local usersFetchInFlight = false
		local userSearchTerm = ""
		local serverUsers = {}
		local serverUsersInit = false
		local lastUserSig = nil
		local userFrames = {}

		local STATUS_COLORS = {
			ok = Color3.fromRGB(120, 200, 140),
			err = Color3.fromRGB(200, 120, 120),
			info = Color3.fromRGB(200, 200, 210),
			blue = Color3.fromRGB(120, 170, 255)
		}

		local typingUsersByName = {}
		local typingUsersById = {}
		local verifiedNameCache = {}
		local verifiedNameFetchInFlight = {}
		local queuedUsersRefresh = false
		local queuedStatusRefresh = false
		local mutedUsers = {}
		local clearDMTarget
		local mentionCooldowns = {}
		local bannedFromChat = false
		local banNoticeShown = false
		local muteUntil = nil
		local muteReason = nil
		local muteCountdownActive = false

		local function formatDurationSeconds(seconds)
			local s = math.max(0, math.floor(tonumber(seconds) or 0))
			if s < 60 then
				return ("%ds"):format(s)
			end
			local m = math.floor(s / 60)
			s = s % 60
			if m < 60 then
				return ("%dm%02ds"):format(m, s)
			end
			local h = math.floor(m / 60)
			m = m % 60
			return ("%dh%02dm%02ds"):format(h, m, s)
		end

		local function getMuteRemainingSeconds()
			if type(muteUntil) ~= "number" then
				return nil
			end
			local now = os.time()
			if now >= muteUntil then
				muteUntil = nil
				muteReason = nil
				return nil
			end
			return muteUntil - now
		end

		local function isMuteMessage(text)
			local normalized = tostring(text or ""):lower()
			return normalized ~= "" and normalized:find("muted") ~= nil and normalized:find("na chat") ~= nil
		end

		local function ensureMuteCountdown()
			if muteCountdownActive then
				return
			end
			if not getMuteRemainingSeconds() then
				return
			end
			muteCountdownActive = true
			Spawn(function()
				while true do
					local left = getMuteRemainingSeconds()
					if not left then
						break
					end
					refreshStatus()
					Wait(1)
				end
				muteCountdownActive = false
				refreshStatus()
			end)
		end

		local function isBanMessage(text)
			local normalized = tostring(text or ""):lower()
			if normalized == "" then
				return false
			end
			return normalized:find("you are banned") ~= nil
				or normalized:find("banned from na chat") ~= nil
				or (normalized:find("banned") and normalized:find("na chat"))
		end

		local function markBannedState()
			if bannedFromChat then
				return
			end
			bannedFromChat = true
			NAChat.bannedFromChat = true
			originalIO.setStatus("NA Chat: Banned", STATUS_COLORS.err)
		end
		local MENTION_COOLDOWN_SECONDS = 10
		local adminState = {
			banned = {},
			muted = {},
		}
		local baseStatusText = "NA Chat: Connecting..."
		local baseStatusColor = STATUS_COLORS.info
		local updateStatusLabel
		local updateUsersList
		local refreshStatus

		local function isDmNotifyEnabled()
			local ok, settings = pcall(NAmanage.NASettingsEnsure)
			if ok and settings then
				local val = settings.naChatDmNotify
				if type(val) == "boolean" then
					return val
				end
			end
			return true
		end

		local function queueUsersListRefresh()
			if queuedUsersRefresh then
				return
			end
			queuedUsersRefresh = true
			Delay(0.15, function()
				queuedUsersRefresh = false
				if type(updateUsersList) == "function" and (not isChatUiSuppressed()) and NAChat.activeTab == "users" then
					updateUsersList(NAChat.users or {})
				end
			end)
		end

		local function queueStatusLabelRefresh()
			if queuedStatusRefresh then
				return
			end
			queuedStatusRefresh = true
			Delay(0.1, function()
				queuedStatusRefresh = false
				if type(updateStatusLabel) == "function" then
					updateStatusLabel()
				end
			end)
		end

		local function getVerifiedUsernameCached(userId)
			if type(userId) ~= "number" then
				return nil
			end
			local cached = verifiedNameCache[userId]
			if type(cached) == "string" and cached ~= "" then
				return cached
			end
			return nil
		end

		local function fetchVerifiedUsernameAsync(userId)
			if type(userId) ~= "number" or userId <= 0 then
				return
			end
			if getVerifiedUsernameCached(userId) then
				return
			end
			if verifiedNameFetchInFlight[userId] then
				return
			end
			verifiedNameFetchInFlight[userId] = true
			Spawn(function()
				local ok, name = pcall(function()
					return Players:GetNameFromUserIdAsync(userId)
				end)
				if ok and type(name) == "string" and name ~= "" then
					verifiedNameCache[userId] = name
				end
				verifiedNameFetchInFlight[userId] = nil
				queueUsersListRefresh()
				queueStatusLabelRefresh()
			end)
		end

		local function getVerifiedUsername(userId, fallback)
			local cached = getVerifiedUsernameCached(userId)
			if cached then
				return cached
			end
			if type(userId) == "number" then
				fetchVerifiedUsernameAsync(userId)
			end
			return fallback
		end

		local function getVerifiedUsernameBlocking(userId, fallback)
			local cached = getVerifiedUsernameCached(userId)
			if cached then
				return cached
			end
			if type(userId) ~= "number" or userId <= 0 then
				return fallback
			end
			local ok, name = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			if ok and type(name) == "string" and name ~= "" then
				verifiedNameCache[userId] = name
				return name
			end
			return fallback
		end

		updateStatusLabel = function()
			if not statusLabel then
				return
			end

			local now = os.clock()
			local names = {}

			local seen = {}

			for name, expires in pairs(typingUsersByName) do
				if type(expires) ~= "number" or expires <= now then
					typingUsersByName[name] = nil
				else
					local display = tostring(name)
					if display ~= "" and not seen[display] then
						seen[display] = true
						Insert(names, display)
					end
				end
			end

			for userId, expires in pairs(typingUsersById) do
				if type(expires) ~= "number" or expires <= now then
					typingUsersById[userId] = nil
				else
					local display = getVerifiedUsername(userId, tostring(userId))
					if display ~= "" and not seen[display] then
						seen[display] = true
						Insert(names, display)
					end
				end
			end

			local text = baseStatusText or ""
			if #names > 0 then
				local who
				if #names == 1 then
					who = names[1]
				elseif #names == 2 then
					who = names[1].." and "..names[2]
				else
					who = names[1].." and others"
				end
				if text ~= "" then
					text = text.."  •  "
				end
				text = text..who.." is typing..."
			end

			statusLabel.Text = text
			statusLabel.TextColor3 = baseStatusColor or statusLabel.TextColor3
		end

		local function normalizeRichTextEntities(text)
			text = tostring(text or "")
			if text == "" then
				return text
			end
			text = text:gsub("&amp;lt;", "&lt;")
			text = text:gsub("&amp;gt;", "&gt;")
			text = text:gsub("&amp;quot;", "&quot;")
			text = text:gsub("&amp;apos;", "&apos;")
			text = text:gsub("&amp;amp;", "&amp;")
			return text
		end

		local function formatMessageWithMentions(rawText)
			local plain = tostring(rawText or "")
			if plain == "" then
				return "", false
			end

			local safe = originalIO.escapeRichTextText and originalIO.escapeRichTextText(plain) or plain
			safe = normalizeRichTextEntities(safe)

			local lp = Players.LocalPlayer
			if not lp then
				return safe, false
			end

			local lowerNames = {}
			lowerNames[Lower(lp.Name)] = true
			local disp = lp.DisplayName
			if disp and disp ~= "" then
				lowerNames[Lower(disp)] = true
			end

			local wasMentioned = false

			local function repl(token)
				local namePart = token:sub(2)
				if lowerNames[Lower(namePart)] then
					wasMentioned = true
					return '<font color="#FFD966">'..token..'</font>'
				end
				return token
			end

			local withMarkup = safe:gsub("(@[%w_]+)", repl)
			return withMarkup, wasMentioned
		end

		local __NAChatEnv = (type(getgenv) == "function" and getgenv()) or _G or {}
		local INTEGRATION_URL = (type(__NAChatEnv) == "table" and rawget(__NAChatEnv, "NAChatIntegrationUrl")) or "https://raw.githubusercontent.com/ltseverydayyou/Open-Cheating-Network/refs/heads/main/Client/NewClient.luau"
		local connect

		originalIO.setStatus = function(t, c)
			if t then
				baseStatusText = t
			end
			if c then
				baseStatusColor = c
			end
			updateStatusLabel()
		end

		refreshStatus = function()
			if not statusLabel then
				return
			end
			local function applyStatus(text, color)
				baseStatusText = text or baseStatusText
				baseStatusColor = color or baseStatusColor
				if type(updateStatusLabel) == "function" then
					updateStatusLabel()
				end
			end

			local svc = NAChat.service
			local isConn = false

			if svc and svc.IsConnected then
				local ok, res = pcall(svc.IsConnected)
				if ok and res then
					isConn = true
				end
			end

			local muteLeft = getMuteRemainingSeconds()
			local muteSuffix = ""
			if muteLeft then
				muteSuffix = " (muted "..formatDurationSeconds(muteLeft).." left)"
				if type(muteReason) == "string" and muteReason ~= "" then
					muteSuffix = muteSuffix.." - "..muteReason
				end
			end

			if isConn then
				local ct = #NAChat.users
				if NAChat.isHidden then
					applyStatus(Format("NA Chat: %d online (hidden)%s", ct, muteSuffix), STATUS_COLORS.ok)
				else
					applyStatus(Format("NA Chat: %d online%s", ct, muteSuffix), STATUS_COLORS.ok)
				end
			elseif NAChat.isHidden then
				applyStatus("NA Chat: Hidden"..muteSuffix, STATUS_COLORS.info)
			elseif NAChat.connecting then
				applyStatus("NA Chat: Connecting...", STATUS_COLORS.info)
			else
				applyStatus("NA Chat: Disconnected", STATUS_COLORS.err)
			end
		end

		local chatMessageOrder = 0

		local function makeChatLabel(t, c, rawMessage)
			local doAutoScroll = chatScroll and canAutoScroll(chatScroll) and shouldAutoScroll(chatScroll) or false

			local lbl = InstanceNew("TextButton", chatScroll)
			lbl.Size = UDim2.new(1, -6, 0, 24)
			lbl.BackgroundColor3 = CHAT_SURFACE
			lbl.BackgroundTransparency = 0.05
			lbl.TextColor3 = c or Color3.fromRGB(224, 224, 234)
			lbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			lbl.TextSize = 14
			lbl.TextWrapped = true
			lbl.RichText = true
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextYAlignment = Enum.TextYAlignment.Center
			chatMessageOrder += 1
			lbl.LayoutOrder = chatMessageOrder
			lbl.AutoButtonColor = false
			lbl.Text = t

			local cr = InstanceNew("UICorner", lbl)
			cr.CornerRadius = UDim.new(0, 7)
			local pad = InstanceNew("UIPadding", lbl)
			pad.PaddingLeft = UDim.new(0, 10)
			pad.PaddingRight = UDim.new(0, 10)
			pad.PaddingTop = UDim.new(0, 4)
			pad.PaddingBottom = UDim.new(0, 4)
			ensureChatStroke(lbl, Color3.fromRGB(69, 72, 96), 0.7)

			local sz = NAgui.txtSize(lbl, lbl.AbsoluteSize.X, 200)
			lbl.Size = UDim2.new(1, -6, 0, sz.Y + 6)

			local tr = NAStuff.ChatTranslator
			if tr then
				tr:registerMessage(lbl, t, rawMessage or t)
			end

			if rawMessage and NAmanage.AttachMessageCopy then
				NAmanage.AttachMessageCopy(lbl, tostring(rawMessage))
			end

			local MAX_MSG = 500
			local list = {}
			for _, v in ipairs(chatScroll:GetChildren()) do
				if v:IsA("TextLabel") or v:IsA("TextButton") then
					Insert(list, v)
				end
			end
			table.sort(list, function(a, b)
				return a.LayoutOrder < b.LayoutOrder
			end)
			if #list > MAX_MSG then
				for i = 1, #list - MAX_MSG do
					list[i]:Destroy()
				end
			end

			if chatScroll and doAutoScroll then
				scrollToBottomSoon(chatScroll)
			end

			return lbl
		end

		local function conversationKey(groupId)
			return groupId and ("group:"..tostring(groupId)) or "public"
		end

		local function clearConversationView()
			if not chatScroll then
				return
			end
			for _, child in ipairs(chatScroll:GetChildren()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") then
					child:Destroy()
				end
			end
			chatMessageOrder = 0
		end

		local function renderConversation()
			clearConversationView()
			local history = conversationHistory[NAChat.activeConversation] or {}
			for _, entry in ipairs(history) do
				makeChatLabel(entry.text, entry.color, entry.raw)
			end
			if chatScroll then
				scrollToBottomSoon(chatScroll)
			end
		end

		local function appendConversationMessage(key, text, color, rawMessage)
			local history = conversationHistory[key]
			if not history then
				history = {}
				conversationHistory[key] = history
			end
			history[#history + 1] = {
				text = text,
				color = color,
				raw = rawMessage,
			}
			if #history > 500 then
				table.remove(history, 1)
			end
			if key == NAChat.activeConversation then
				return makeChatLabel(text, color, rawMessage)
			end
			return nil
		end

		local function syncGroupHistory(group)
			if type(group) ~= "table" or not group.id then
				return
			end
			local key = conversationKey(group.id)
			local history = {}
			for _, entry in ipairs(group.messages or {}) do
				if type(entry) == "table" then
					local sender = tostring(entry.from or "?")
					local message = tostring(entry.message or "")
					if message ~= "" then
						history[#history + 1] = {
							text = ("[%s]: %s"):format(sender, message),
							color = STATUS_COLORS.blue,
							raw = message,
						}
					end
				end
			end
			conversationHistory[key] = history
		end

		local function makeConversationButton(parent, text, selected)
			local button = InstanceNew("TextButton", parent)
			button.Size = UDim2.new(1, -4, 0, 30)
			button.BackgroundColor3 = selected and Color3.fromRGB(72, 54, 126) or CHAT_OFF
			button.BackgroundTransparency = 0.04
			button.TextColor3 = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(224, 226, 238)
			button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
			button.TextSize = 12
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.Text = text
			button.AutoButtonColor = false
			button.ZIndex = (tonumber(parent.ZIndex) or 1) + 1
			local corner = InstanceNew("UICorner", button)
			corner.CornerRadius = UDim.new(0, 7)
			local padding = InstanceNew("UIPadding", button)
			padding.PaddingLeft = UDim.new(0, 10)
			ensureChatStroke(button, selected and CHAT_ACCENT or Color3.fromRGB(83, 85, 105), selected and 0.12 or 0.58)
			return button
		end

		local function updateGroupButton()
			if not groupButton then
				return
			end
			if NAChat.activeGroupId and groupRecords[tostring(NAChat.activeGroupId)] then
				local group = groupRecords[tostring(NAChat.activeGroupId)]
				groupButton.Text = "# "..tostring(group.name or "Group")
			else
				groupButton.Text = "Public Chat"
			end
		end

		refreshGroupPicker = function()
			if not groupListFrame then
				return
			end
			for _, child in ipairs(groupListFrame:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end

			local publicButton = makeConversationButton(groupListFrame, "Public Chat", not NAChat.activeGroupId)
			MouseButtonFix(publicButton, function()
				if switchConversation then
					switchConversation(nil)
				end
			end)

			local ids = {}
			for id in pairs(groupRecords) do
				Insert(ids, id)
			end
			table.sort(ids, function(a, b)
				return tostring(groupRecords[a].name or "") < tostring(groupRecords[b].name or "")
			end)
			for _, id in ipairs(ids) do
				local group = groupRecords[id]
				local count = type(group.members) == "table" and #group.members or 0
				local label = ("# %s  (%d)"):format(tostring(group.name or "Group"), count)
				local button = makeConversationButton(groupListFrame, label, tostring(NAChat.activeGroupId or "") == tostring(id))
				MouseButtonFix(button, function()
					if switchConversation then
						switchConversation(id)
					end
				end)
			end
			updateGroupButton()
		end

		switchConversation = function(groupId)
			local normalized = groupId and tostring(groupId) or nil
			if normalized and not groupRecords[normalized] then
				return
			end
			NAChat.activeGroupId = normalized
			NAChat.activeConversation = conversationKey(normalized)
			NAChat.currentDMTarget = nil
			if inputBox then
				if normalized and groupRecords[normalized] then
					inputBox.PlaceholderText = "Message #"..tostring(groupRecords[normalized].name or "group").."..."
				else
					inputBox.PlaceholderText = "Send a message (/w name)..."
				end
			end
			if groupInviteInput then
				groupInviteInput.Visible = normalized ~= nil
			end
			if groupInviteButton then
				groupInviteButton.Visible = normalized ~= nil
			end
			if groupLeaveButton then
				groupLeaveButton.Visible = normalized ~= nil
			end
			updateGroupButton()
			if groupPopup then
				groupPopup.Visible = false
			end
			if NAChat.activeTab ~= "chat" then
				NAChat.activeTab = "chat"
				if chatTab then
					styleChatTab(chatTab, true)
				end
				if usersTab then
					styleChatTab(usersTab, false)
				end
				if adminTab then
					styleChatTab(adminTab, false)
				end
				if chatScroll then chatScroll.Visible = true end
				if usersScroll then usersScroll.Visible = false end
				if adminFrame then adminFrame.Visible = false end
				if usersSearchBox then usersSearchBox.Visible = false end
			end
			renderConversation()
			if refreshGroupPicker then
				refreshGroupPicker()
			end
		end

		local function buildGroupUi()
			if type(MouseButtonFix) ~= "function" then
				return
			end
			local parent = NAChatToolsBar or NAChatTabs or chatFrame
			if not parent then
				return
			end
			groupButton = parent:FindFirstChild("NAChatGroups")
			if not groupButton then
				groupButton = InstanceNew("TextButton", parent)
				groupButton.Name = "NAChatGroups"
				groupButton.Size = UDim2.new(0, 88, 0, 30)
				groupButton.BackgroundColor3 = CHAT_OFF
				groupButton.BackgroundTransparency = 0.04
				groupButton.TextColor3 = Color3.fromRGB(224, 226, 238)
				groupButton.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
				groupButton.TextSize = 12
				groupButton.Text = "Public Chat"
				groupButton.AutoButtonColor = false
				local corner = InstanceNew("UICorner", groupButton)
				corner.CornerRadius = UDim.new(0, 7)
				ensureChatStroke(groupButton, CHAT_ACCENT, 0.22)
			end

			groupPopup = chatFrame:FindFirstChild("NAChatGroupPopup")
			if not groupPopup then
				groupPopup = InstanceNew("Frame", chatFrame)
				groupPopup.Name = "NAChatGroupPopup"
				groupPopup.Size = UDim2.new(0, 250, 0, 270)
				groupPopup.Position = UDim2.new(0, 8, 0, 82)
				groupPopup.BackgroundColor3 = CHAT_SURFACE
				groupPopup.BackgroundTransparency = 0.02
				groupPopup.Visible = false
				groupPopup.ZIndex = 200
				local popupCorner = InstanceNew("UICorner", groupPopup)
				popupCorner.CornerRadius = UDim.new(0, 9)
				ensureChatStroke(groupPopup, CHAT_ACCENT, 0.08)

				local title = InstanceNew("TextLabel", groupPopup)
				title.Size = UDim2.new(1, -20, 0, 24)
				title.Position = UDim2.new(0, 10, 0, 8)
				title.BackgroundTransparency = 1
				title.Text = "Conversations"
				title.TextColor3 = Color3.fromRGB(238, 239, 250)
				title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
				title.TextSize = 14
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.ZIndex = 201

				groupListFrame = InstanceNew("ScrollingFrame", groupPopup)
				groupListFrame.Name = "GroupList"
				groupListFrame.Size = UDim2.new(1, -20, 0, 112)
				groupListFrame.Position = UDim2.new(0, 10, 0, 36)
				groupListFrame.BackgroundTransparency = 1
				groupListFrame.BorderSizePixel = 0
				groupListFrame.ScrollBarThickness = 4
				groupListFrame.ScrollBarImageColor3 = CHAT_ACCENT
				groupListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
				groupListFrame.ZIndex = 201
				local groupLayout = InstanceNew("UIListLayout", groupListFrame)
				groupLayout.Padding = UDim.new(0, 5)
				groupLayout.SortOrder = Enum.SortOrder.LayoutOrder
				groupLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					groupListFrame.CanvasSize = UDim2.new(0, 0, 0, groupLayout.AbsoluteContentSize.Y + 4)
				end)

				groupNameInput = InstanceNew("TextBox", groupPopup)
				groupNameInput.Name = "GroupNameInput"
				groupNameInput.Size = UDim2.new(1, -86, 0, 30)
				groupNameInput.Position = UDim2.new(0, 10, 0, 154)
				groupNameInput.BackgroundColor3 = CHAT_OFF
				groupNameInput.BackgroundTransparency = 0.04
				groupNameInput.TextColor3 = Color3.fromRGB(232, 234, 244)
				groupNameInput.PlaceholderColor3 = Color3.fromRGB(150, 153, 173)
				groupNameInput.PlaceholderText = "New group name"
				groupNameInput.Text = ""
				groupNameInput.TextSize = 12
				groupNameInput.ClearTextOnFocus = false
				groupNameInput.ZIndex = 201
				local nameCorner = InstanceNew("UICorner", groupNameInput)
				nameCorner.CornerRadius = UDim.new(0, 7)
				ensureChatStroke(groupNameInput, Color3.fromRGB(83, 85, 105), 0.45)

				local createButton = makeConversationButton(groupPopup, "Create", false)
				createButton.Name = "CreateGroup"
				createButton.Size = UDim2.new(0, 66, 0, 30)
				createButton.Position = UDim2.new(1, -76, 0, 154)
				createButton.ZIndex = 202
				MouseButtonFix(createButton, function()
					local name = tostring(groupNameInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
					local svc = NAChat.service
					if name == "" then
						return
					end
					if svc and svc.CreateGroup then
						local ok, result = pcall(svc.CreateGroup, name, {})
						if ok and result ~= false then
							groupNameInput.Text = ""
						else
							originalIO.setStatus("NA Chat: group creation failed", STATUS_COLORS.err)
						end
					else
						originalIO.setStatus("NA Chat: group support unavailable", STATUS_COLORS.err)
					end
				end)

				groupInviteInput = InstanceNew("TextBox", groupPopup)
				groupInviteInput.Name = "GroupInviteInput"
				groupInviteInput.Size = UDim2.new(1, -86, 0, 30)
				groupInviteInput.Position = UDim2.new(0, 10, 0, 194)
				groupInviteInput.BackgroundColor3 = CHAT_OFF
				groupInviteInput.BackgroundTransparency = 0.04
				groupInviteInput.TextColor3 = Color3.fromRGB(232, 234, 244)
				groupInviteInput.PlaceholderColor3 = Color3.fromRGB(150, 153, 173)
				groupInviteInput.PlaceholderText = "Invite username"
				groupInviteInput.Text = ""
				groupInviteInput.TextSize = 12
				groupInviteInput.ClearTextOnFocus = false
				groupInviteInput.Visible = false
				groupInviteInput.ZIndex = 201
				local inviteCorner = InstanceNew("UICorner", groupInviteInput)
				inviteCorner.CornerRadius = UDim.new(0, 7)
				ensureChatStroke(groupInviteInput, Color3.fromRGB(83, 85, 105), 0.45)

				groupInviteButton = makeConversationButton(groupPopup, "Invite", false)
				groupInviteButton.Name = "InviteGroup"
				groupInviteButton.Size = UDim2.new(0, 66, 0, 30)
				groupInviteButton.Position = UDim2.new(1, -76, 0, 194)
				groupInviteButton.Visible = false
				groupInviteButton.ZIndex = 202
				MouseButtonFix(groupInviteButton, function()
					local svc = NAChat.service
					local target = tostring(groupInviteInput.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
					if svc and svc.InviteToGroup and NAChat.activeGroupId and target ~= "" then
						local ok, result = pcall(svc.InviteToGroup, NAChat.activeGroupId, target)
						if ok and result ~= false then
							groupInviteInput.Text = ""
						else
							originalIO.setStatus("NA Chat: invite failed", STATUS_COLORS.err)
						end
					end
				end)

				groupLeaveButton = makeConversationButton(groupPopup, "Leave", false)
				groupLeaveButton.Name = "LeaveGroup"
				groupLeaveButton.Size = UDim2.new(0, 66, 0, 30)
				groupLeaveButton.Position = UDim2.new(1, -76, 0, 234)
				groupLeaveButton.Visible = false
				groupLeaveButton.ZIndex = 202
				MouseButtonFix(groupLeaveButton, function()
					local svc = NAChat.service
					if svc and svc.LeaveGroup and NAChat.activeGroupId then
						local ok, result = pcall(svc.LeaveGroup, NAChat.activeGroupId)
						if not ok or result == false then
							originalIO.setStatus("NA Chat: leave failed", STATUS_COLORS.err)
						end
					end
				end)
			end

			updateGroupButton()
			refreshGroupPicker()
			MouseButtonFix(groupButton, function()
				if groupPopup then
					groupPopup.Visible = not groupPopup.Visible
					if groupPopup.Visible then
						refreshGroupPicker()
					end
				end
			end)
		end

		buildGroupUi()

		local function buildServerSet(list)
			local set = {}
			if type(list) ~= "table" then
				return set
			end

			local lp = Players.LocalPlayer
			local myJob = tostring(game.JobId or "")
			local myPlace = game.PlaceId

			for _, info in ipairs(list) do
				if type(info) == "table" then
					local uid = tonumber(info.userId)
					local pid = tonumber(info.placeId)
					local jid = tostring(info.jobId or "")
					local name = getVerifiedUsername(uid, tostring(info.username or "Unknown"))

					if uid and pid == myPlace and jid ~= "" and jid == myJob then
						if not (lp and uid == lp.UserId) then
							set[uid] = name
						end
					end
				end
			end

			return set
		end

		local function makeUserSignature(list)
			if type(list) ~= "table" then
				return ""
			end
			local tmp = {}
			for _, info in ipairs(list) do
				if type(info) == "table" then
					local uid = tonumber(info.userId) or 0
					local uname = tostring(info.username or "")
					local hiddenFlag = (info.hidden == true) and 1 or 0
					local activityFlag = ((info.activityHidden == true) or (info.activity_hidden == true)) and 1 or 0
					local pid = tonumber(info.placeId) or 0
					local jid = tostring(info.jobId or "")
					local adminFlag = (info.admin == true) and 1 or 0
					local gameStr = tostring(info.game or "")
					tmp[#tmp+1] = uid.."|"..uname.."|"..hiddenFlag.."|"..activityFlag.."|"..pid.."|"..jid.."|"..adminFlag.."|"..gameStr
				end
			end
			table.sort(tmp)
			return Concat(tmp, ";")
		end

		local function requestUsersList()
			if isChatUiSuppressed() or not NAChat.service or usersFetchInFlight then
				return
			end

			local svc = NAChat.service
			usersFetchInFlight = true

			local ok, res = false, nil
			if NAChat.serverIsAdmin and svc.GetUsersAdmin then
				ok, res = pcall(svc.GetUsersAdmin)
			elseif svc.GetUsers then
				ok, res = pcall(svc.GetUsers)
			else
				usersFetchInFlight = false
				return
			end

			if not ok or res == false then
				usersFetchInFlight = false
			end
		end

		updateUsersList = function(list)
			if not usersScroll then
				return
			end

			for _, child in ipairs(usersScroll:GetChildren()) do
				if child:IsA("Frame") and child:GetAttribute("NAChatHiddenNotice") == true then
					child:Destroy()
				end
			end

			usersUpdateGeneration += 1
			local myGeneration = usersUpdateGeneration

			local doAutoScroll = usersScroll and shouldAutoScroll(usersScroll) or false

			if isChatUiSuppressed() then
				for _, v in ipairs(usersScroll:GetChildren()) do
					if v:IsA("Frame") then
						v:Destroy()
					end
				end
				userFrames = {}

				local fr = InstanceNew("Frame", usersScroll)
				fr.Name = "NAChatHiddenNotice"
				fr:SetAttribute("NAChatHiddenNotice", true)
				fr.BackgroundTransparency = 1
				fr.Size = UDim2.new(1, -6, 0, 40)
				local lbl = InstanceNew("TextLabel", fr)
				lbl.BackgroundTransparency = 1
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.Text = "Hidden mode - user list disabled"
				lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
				lbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				lbl.TextSize = 14
				lbl.TextWrapped = true
				return
			end

			if type(list) ~= "table" then
				return
			end

			local avatarQueue = {}
			local seen = {}
			local alive = {}
			local idx = 0
			local detachedLayoutParent = nil
			if usersLayout and usersLayout.Parent == usersScroll then
				detachedLayoutParent = usersLayout.Parent
				usersLayout.Parent = nil
			end

			for _, info in ipairs(list) do
				local serverUsername = (type(info) == "table" and info.username) or tostring(info)
				local userId = type(info) == "table" and tonumber(info.userId) or nil
				local displayName = type(info) == "table" and tostring(info.displayName or "") or ""
				local fallbackUsername = tostring(serverUsername or "")
				local verifiedUsername = getVerifiedUsernameCached(userId)
				if not verifiedUsername and userId and fallbackUsername == "" then
					fetchVerifiedUsernameAsync(userId)
				end
				local canonicalUsername = verifiedUsername or fallbackUsername
				local isAdmin = type(info) == "table" and (info.admin == true) or false
				local gameStatus = type(info) == "table" and tostring(info.game or "") or ""
				local placeId = type(info) == "table" and info.placeId or nil
				local jobId = type(info) == "table" and info.jobId or nil
				local isHiddenUser = type(info) == "table" and (info.hidden == true) or false
				local activityHidden = type(info) == "table" and ((info.activityHidden == true) or (info.activity_hidden == true)) or false

				if userSearchTerm ~= "" then
					local needle = userSearchTerm
					local haystack = Lower(tostring(canonicalUsername or "").." "..tostring(displayName or "").." "..tostring(serverUsername or "").." "..tostring(gameStatus or ""))
					if not Find(haystack, needle, 1, true) then
						continue
					end
				end

				local keyBase = Lower(tostring(canonicalUsername or ""))
				local uidKey
				if userId then
					uidKey = "id:"..tostring(userId)
				else
					uidKey = "n:"..keyBase
				end

				if seen[uidKey] then
					continue
				end
				seen[uidKey] = true
				alive[uidKey] = true
				idx += 1

				local fr = userFrames[uidKey]
				if not (fr and fr.Parent) then
					fr = InstanceNew("Frame", usersScroll)
					userFrames[uidKey] = fr
					local cr = InstanceNew("UICorner", fr)
					cr.CornerRadius = UDim.new(0, 9)
					ensureChatStroke(fr, Color3.fromRGB(72, 75, 99), 0.58)
					local avatar = InstanceNew("ImageLabel", fr)
					avatar.Name = "Avatar"
					avatar.BackgroundTransparency = 1
					avatar.Size = UDim2.new(0, 38, 0, 38)
					avatar.Position = UDim2.new(0, 8, 0.5, -19)
					avatar.Image = ""
					local avatarCorner = InstanceNew("UICorner", avatar)
					avatarCorner.CornerRadius = UDim.new(1, 0)
					ensureChatStroke(avatar, CHAT_ACCENT, 0.35)
					local nameLbl = InstanceNew("TextLabel", fr)
					nameLbl.Name = "NameLabel"
					nameLbl.BackgroundTransparency = 1
					nameLbl.Size = UDim2.new(1, -190, 0, 20)
					nameLbl.Position = UDim2.new(0, 58, 0, 6)
					nameLbl.TextXAlignment = Enum.TextXAlignment.Left
					nameLbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					nameLbl.TextSize = 14
					local gameLbl = InstanceNew("TextLabel", fr)
					gameLbl.Name = "GameLabel"
					gameLbl.BackgroundTransparency = 1
					gameLbl.Size = UDim2.new(1, -190, 0, 16)
					gameLbl.Position = UDim2.new(0, 58, 0, 27)
					gameLbl.TextXAlignment = Enum.TextXAlignment.Left
					gameLbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					gameLbl.TextSize = 12
				end

				fr.Name = keyBase
				fr.BackgroundColor3 = CHAT_SURFACE
				fr.Size = UDim2.new(1, -6, 0, 52)
				fr.BackgroundTransparency = 0.03
				fr.LayoutOrder = idx

				local avatar = fr:FindFirstChild("Avatar")
				local nameLbl = fr:FindFirstChild("NameLabel")
				local gameLbl = fr:FindFirstChild("GameLabel")

				local isOwner = userId == 11761417 or userId == 530829101

				if nameLbl then
					local prefix = ""
					if isHiddenUser then
						prefix = prefix.."[HIDDEN] "
					end
					if isOwner then
						prefix = prefix.."[OWNER] "
					elseif isAdmin then
						prefix = prefix.."[ADMIN] "
					end

					nameLbl.TextColor3 = (isAdmin or isOwner) and Color3.fromRGB(255, 214, 126) or Color3.fromRGB(235, 236, 246)
					if isHiddenUser then
						nameLbl.TextColor3 = Color3.fromRGB(200, 200, 210)
					end
					local display = tostring(canonicalUsername or "")
					if displayName ~= "" and canonicalUsername ~= "" and displayName ~= canonicalUsername then
						display = ("%s (@%s)"):format(displayName, canonicalUsername)
					end
					nameLbl.Text = prefix..display
				end

				if gameLbl then
					gameLbl.TextColor3 = Color3.fromRGB(156, 160, 181)
					local line = (gameStatus ~= "" and gameStatus) or "Game: Unknown"
					if activityHidden then
						line = line.." (activity hidden)"
					end
					if isHiddenUser then
						line = line.." (invisible)"
					end
					gameLbl.Text = line
				end

				local pidNum = tonumber(placeId)
				local jobStr = tostring(jobId or "")
				local canJoin = (pidNum ~= nil and pidNum > 0) and jobStr ~= ""
				local isSelf = userId and Players.LocalPlayer and (userId == Players.LocalPlayer.UserId)

				local joinBtn = fr:FindFirstChild("JoinButton")
				if not canJoin or isSelf then
					if joinBtn then
						joinBtn:Destroy()
						joinBtn = nil
					end
				else
					if not joinBtn then
						joinBtn = InstanceNew("TextButton", fr)
						joinBtn.Name = "JoinButton"
						joinBtn.Size = UDim2.new(0, 76, 0, 26)
						joinBtn.Position = UDim2.new(1, -82, 0.5, -13)
						joinBtn.BackgroundColor3 = CHAT_ON
						joinBtn.BackgroundTransparency = 0.04
						joinBtn.TextColor3 = Color3.fromRGB(220, 255, 238)
						joinBtn.AutoButtonColor = false
						joinBtn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						joinBtn.TextSize = 13
						joinBtn.Text = "Join"
						local jbCorner = InstanceNew("UICorner", joinBtn)
						jbCorner.CornerRadius = UDim.new(0, 7)
						ensureChatStroke(joinBtn, Color3.fromRGB(89, 210, 151), 0.22)
						MouseButtonFix(joinBtn, function()
							local pid = pidNum
							local jid = jobStr
							if not (pid and jid ~= "") then
								return
							end
							local lp = Players.LocalPlayer
							if not (lp and TeleportService) then
								return
							end
							local ok, err = pcall(function()
								TeleportService:TeleportToPlaceInstance(pid, jid, lp)
							end)
							if not ok then
								if DoNotif then
									DoNotif("Failed to join "..tostring(canonicalUsername)..": "..tostring(err), 4)
								end
							end
						end)
					end
				end
				local hasJoin = joinBtn ~= nil

				local dmBtn = fr:FindFirstChild("DMButton")
				if isSelf then
					if dmBtn then
						dmBtn:Destroy()
					end
				else
					if not dmBtn then
						dmBtn = InstanceNew("TextButton", fr)
						dmBtn.Name = "DMButton"
						dmBtn.Size = UDim2.new(0, 58, 0, 26)
						dmBtn.Position = UDim2.new(1, -148, 0.5, -13)
						dmBtn.BackgroundColor3 = Color3.fromRGB(63, 55, 108)
						dmBtn.BackgroundTransparency = 0.04
						dmBtn.TextColor3 = Color3.fromRGB(236, 230, 255)
						dmBtn.AutoButtonColor = false
						dmBtn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						dmBtn.TextSize = 13
						dmBtn.Text = "DM"
						local dmCorner = InstanceNew("UICorner", dmBtn)
						dmCorner.CornerRadius = UDim.new(0, 7)
						ensureChatStroke(dmBtn, CHAT_ACCENT, 0.22)
						MouseButtonFix(dmBtn, function()
							local uname = tostring(canonicalUsername or "")
							if NAChat.currentDMTarget == uname then
								clearDMTarget("NA Chat: DM cleared")
							else
								NAChat.currentDMTarget = uname
								if inputBox then
									inputBox.PlaceholderText = ("DM to %s..."):format(uname)
								end
								originalIO.setStatus(("NA Chat: DM -> %s"):format(uname), STATUS_COLORS.blue)
							end
						end)
					end
					if hasJoin then
						dmBtn.Position = UDim2.new(1, -148, 0.5, -13)
					else
						dmBtn.Position = UDim2.new(1, -64, 0.5, -13)
					end
				end

				if avatar and userId and (avatar.Image == nil or avatar.Image == "") then
					avatar.Image = ""
					Insert(avatarQueue, { avatar = avatar, userId = userId })
				end
			end

			for key, fr in pairs(userFrames) do
				if not alive[key] or not (fr and fr.Parent) then
					if fr and fr.Parent then
						fr:Destroy()
					end
					userFrames[key] = nil
				end
			end
			if detachedLayoutParent and usersLayout then
				usersLayout.Parent = detachedLayoutParent
			end
			if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
				NAmanage.CustomScroll.refreshByTarget(usersScroll)
			end

			if usersScroll and doAutoScroll then
				scrollToBottomSoon(usersScroll)
			end

			if #avatarQueue > 0 then
				Spawn(function()
					for _, taskInfo in ipairs(avatarQueue) do
						if usersUpdateGeneration ~= myGeneration then
							break
						end
						local avatar = taskInfo.avatar
						local userId = taskInfo.userId
						if avatar and avatar.Parent and userId then
							local ok, image = pcall(function()
								return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
							end)
							if ok and image and image ~= "" then
								avatar.Image = image
							else
								avatar.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=420&h=420"):format(userId)
							end
						end
						Wait(0.03)
					end
				end)
			end
		end

		originalIO.setHiddenState = function(newHidden, skipRemote)
			NAChat.isHidden = newHidden
			local freezeUI = isChatUiSuppressed()
			if NAmanage and type(NAmanage.NASettingsSet) == "function" then
				pcall(NAmanage.NASettingsSet, "naChatHidden", newHidden)
			end
			if visibilityBtn then
				styleChatToggle(visibilityBtn, not newHidden, "Visibility  •  Visible", "Visibility  •  Hidden")
			end
			if inputBox then
				inputBox.TextEditable = not freezeUI
				inputBox.TextTransparency = freezeUI and 0.5 or 0
			end
			if usersSearchBox then
				usersSearchBox.TextEditable = not freezeUI
				usersSearchBox.TextTransparency = freezeUI and 0.5 or 0
				if freezeUI then
					usersSearchBox.Text = ""
					userSearchTerm = ""
				end
			end
			if sendBtn then
				sendBtn.AutoButtonColor = not freezeUI
				sendBtn.TextTransparency = freezeUI and 0.5 or 0
			end
			if freezeUI then
				updateUsersList({})
			elseif NAChat.activeTab == "users" then
				requestUsersList()
			end
			if not newHidden and usersScroll then
				for _, child in ipairs(usersScroll:GetChildren()) do
					if child:IsA("Frame") and child:GetAttribute("NAChatHiddenNotice") == true then
						child:Destroy()
					end
				end
			end
			if not skipRemote and NAChat.service and NAChat.service.SetHidden then
				NAChat.service.SetHidden(newHidden)
			end
			refreshStatus()
		end

		local function switchTab(tab)
			NAChat.activeTab = tab

			styleChatTab(chatTab, tab == "chat")
			styleChatTab(usersTab, tab == "users")
			styleChatTab(adminTab, tab == "admin")
			styleChatToggle(dmNotifBtn, isDmNotifyEnabled(), "DM Notifications  •  On", "DM Notifications  •  Off")
			local activityEnabled = _G.NAChatGameActivityEnabled and _G.NAChatGameActivityEnabled() or true
			styleChatToggle(gameActivityBtn, activityEnabled, "Activity  •  On", "Activity  •  Off")

			if chatScroll then
				chatScroll.Visible = (tab == "chat")
			end
			if usersScroll then
				usersScroll.Visible = (tab == "users")
			end
			if adminFrame then
				adminFrame.Visible = (tab == "admin")
			end
			if groupButton then
				groupButton.Visible = (tab == "chat")
			end
			if groupPopup and tab ~= "chat" then
				groupPopup.Visible = false
			end

			if usersSearchBox then
				usersSearchBox.Visible = (tab == "users") and not isChatUiSuppressed()
			end
			if NAmanage and NAmanage.NAChatMessagesScroll and NAmanage.NAChatMessagesScroll.scheduleRefresh then
				NAmanage.NAChatMessagesScroll.scheduleRefresh()
			end
			if NAmanage and NAmanage.NAChatUsersScroll and NAmanage.NAChatUsersScroll.scheduleRefresh then
				NAmanage.NAChatUsersScroll.scheduleRefresh()
			end

			if tab == "users" then
				if isChatUiSuppressed() then
					updateUsersList({})
				else
					if type(NAChat.users) == "table" and #NAChat.users > 0 then
						updateUsersList(NAChat.users)
					end
					requestUsersList()
				end
			end

			if tab == "chat" then
				renderConversation()
			end

			if tab == "admin" then
				local svc = NAChat.service
				if svc and svc.SendAdminAction then
					svc.SendAdminAction("refresh", "")
				end
			end
		end

		local function fetchIntegrationBody()
			local body
			local rq = request or http_request or (syn and syn.request) or opt.NAREQUEST

			if type(rq) == "function" then
				local ok, res = pcall(rq, {
					Url = INTEGRATION_URL,
					Method = "GET"
				})
				if ok and type(res) == "table" then
					body = res.Body or res.body
				end
			end

			if type(body) ~= "string" or body == "" then
				local ok, fb = pcall(game.HttpGet, game, INTEGRATION_URL)
				if ok and type(fb) == "string" and fb ~= "" then
					body = fb
				end
			end

			if type(body) == "string" and body ~= "" then
				return true, body
			end

			return false, "failed to fetch IntegrationService script"
		end

		local function loadService()
			if NAChat.service then
				return true
			end

			local ok, payload = fetchIntegrationBody()
			if not ok then
				originalIO.setStatus("NA Chat unavailable", STATUS_COLORS.err)
				return false
			end

			local okLoad, res = pcall(function()
				local chunk, err = loadstring(payload)
				assert(chunk, err or "loadstring failed")
				return chunk()
			end)

			if okLoad and type(res) == "table" then
				NAChat.service = res
				return true
			end

			originalIO.setStatus("NA Chat unavailable", STATUS_COLORS.err)
			return false
		end

		local reconnectBackoff = {3, 8, 15, 30}
		local reconnectAttempts = 0
		local reconnectToken = 0

		local function resetReconnectBackoff()
			reconnectAttempts = 0
			reconnectToken = reconnectToken + 1
		end

		local function queueReconnect()
			if reconnectAttempts >= #reconnectBackoff then
				originalIO.setStatus("NA Chat: offline (auto-reconnect paused)", STATUS_COLORS.err)
				if DoNotif then
					DoNotif("NA Chat reconnect paused. Press Reconnect to try again.", 3)
				end
				return
			end

			reconnectAttempts = reconnectAttempts + 1
			local token = reconnectToken
			local delaySeconds = reconnectBackoff[math.min(reconnectAttempts, #reconnectBackoff)]

			Delay(delaySeconds, function()
				if token ~= reconnectToken then
					return
				end
				if NAChat.connecting then
					return
				end
				if NAChat.service and NAChat.service.IsConnected and NAChat.service.IsConnected() then
					resetReconnectBackoff()
					return
				end
				connect()
			end)
		end

		local lastSysText, lastSysTime = nil, 0
		local lastErrText, lastErrTime = nil, 0

		local function wireEvents()
			if NAChat.wired or not NAChat.service then
				return
			end
			NAChat.wired = true

			if usersSearchBox then
				usersSearchBox.ClearTextOnFocus = false
				usersSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
					local nextTerm = Lower(usersSearchBox.Text or "")
					if nextTerm ~= userSearchTerm then
						userSearchTerm = nextTerm
						if not isChatUiSuppressed() then
							queueUsersListRefresh()
						end
					end
				end)
			end

			bindAutoScroll(chatScroll, chatLayout)
			bindAutoScroll(usersScroll, usersLayout)

			NAChat.service.OnChatMessage.Event:Connect(function(name, msg, _, userId, isAdmin, gameStatus)
				local rawSenderName = tostring(name or "?")
				local messageText = tostring(msg or "")
				local senderId = tonumber(userId)
				local senderName = getVerifiedUsername(senderId, rawSenderName)

				local isOwner = senderId == 11761417 or senderId == 530829101
				local isNAadmin = (isAdmin == true)

				local displayText, mentioned = formatMessageWithMentions(messageText)

				if (isOwner or isNAadmin) and messageText:find("@everyone", 1, true) then
					mentioned = true
					displayText = displayText:gsub("@everyone", '<font color="#FFD966">@everyone</font>')
				end
				if displayText == "" then
					displayText = messageText
				end

				local labelText
				if isOwner then
					labelText = ("[OWNER] %s: %s"):format(senderName, displayText)
				elseif isNAadmin then
					labelText = ("[ADMIN] %s: %s"):format(senderName, displayText)
				else
					labelText = ("[%s]: %s"):format(senderName, displayText)
				end

				if mutedUsers[Lower(senderName)] or mutedUsers[Lower(rawSenderName)] then
					return
				end

				local lbl = appendConversationMessage("public", labelText, STATUS_COLORS.blue, messageText)

				if mentioned and DoNotif then
					local now = os.clock()
					local canNotify = true
					if not (isOwner or isNAadmin) then
						local key = senderId and ("id:"..tostring(senderId)) or senderName
						local last = mentionCooldowns[key] or 0
						if (now - last) < MENTION_COOLDOWN_SECONDS then
							canNotify = false
						else
							mentionCooldowns[key] = now
						end
					end

					if canNotify then
						DoNotif(("%s mentioned you in NA Chat."):format(senderName), 3)
					end
				end

				if (isNAadmin or isOwner) and lbl then
					local conn
					conn = RunService.Heartbeat:Connect(function()
						if not (lbl and lbl.Parent) then
							if conn then
								conn:Disconnect()
							end
							return
						end

						local t = tick()
						local r = math.sin(t * 0.5) * 127 + 128
						local g = math.sin(t * 0.5 + 2 * math.pi / 3) * 127 + 128
						local b = math.sin(t * 0.5 + 4 * math.pi / 3) * 127 + 128
						lbl.TextColor3 = Color3.fromRGB(r, g, b)
					end)
				end
			end)

			NAChat.service.OnSystemMessage.Event:Connect(function(msg)
				local m = tostring(msg or "System message")
				local isBan = isBanMessage(m)
				if isBan then
					markBannedState()
					if banNoticeShown then
						return
					end
				end
				local now = os.clock()
				if lastSysText == m and (now - lastSysTime) < 2 then
					return
				end
				lastSysText, lastSysTime = m, now
				appendConversationMessage("public", ("[System]: %s"):format(m), STATUS_COLORS.info, m)
				if isBan then
					banNoticeShown = true
				end
			end)

			if NAChat.service.OnTyping then
				NAChat.service.OnTyping.Event:Connect(function(fromName, isTyping)
					fromName = tostring(fromName or "")
					if fromName == "" then
						return
					end
					local lp = Players.LocalPlayer
					local fromId = tonumber(fromName)
					if lp then
						if fromId and fromId == lp.UserId then
							return
						end
						if (not fromId) and fromName == lp.Name then
							return
						end
					end
					if fromId then
						if isTyping then
							typingUsersById[fromId] = os.clock() + 6
						else
							typingUsersById[fromId] = nil
						end
					else
						if isTyping then
							typingUsersByName[fromName] = os.clock() + 6
						else
							typingUsersByName[fromName] = nil
						end
					end
					updateStatusLabel()
				end)
			end

			if NAChat.service.OnAdminState then
				NAChat.service.OnAdminState.Event:Connect(function(state)
					if type(state) ~= "table" then
						return
					end

					local banned = {}
					if type(state.banned) == "table" then
						for _, name in ipairs(state.banned) do
							if type(name) == "string" and name ~= "" then
								Insert(banned, name)
							end
						end
					end
					adminState.banned = banned

					local muted = {}
					if type(state.muted) == "table" then
						for _, entry in ipairs(state.muted) do
							if type(entry) == "table" then
								local uname = tostring(entry.username or entry.user or entry.name or "")
								local untilEpoch = tonumber(entry["until"] or entry.muted_until or entry.mutedUntil or entry.expires or entry.expiresAt)
								local reason = tostring(entry.reason or "")
								if uname ~= "" then
									Insert(muted, { username = uname, untilEpoch = untilEpoch, reason = reason })
								end
							elseif type(entry) == "string" and entry ~= "" then
								Insert(muted, { username = entry, untilEpoch = nil, reason = "" })
							end
						end
					end
					adminState.muted = muted

					if adminFrame and adminFrameUpdateBanList then
						adminFrameUpdateBanList()
					end
				end)
			end

			if NAChat.service.OnPrivateMessage then
				NAChat.service.OnPrivateMessage.Event:Connect(function(fromName, toName, text)
					local lp = Players.LocalPlayer
					local me = lp and lp.Name or ""
					fromName = tostring(fromName or "?")
					toName = tostring(toName or "?")
					local msgText = tostring(text or "")

					local base, mentioned = formatMessageWithMentions(msgText)
					if base == "" then base = msgText end

					local label
					if toName == me then
						label = ("[DM FROM %s]: %s"):format(fromName, base)
						local chatVisible = chatFrame and chatFrame.Visible
						if not chatVisible and isDmNotifyEnabled() then
							local function openChatView()
								if chatTab then
									switchTab("chat")
								end
								if type(NAgui) == "table" and type(NAgui.nachat) == "function" then
									pcall(NAgui.nachat)
								end
							end

							local payload = {
								Title = adminName,
								Description = ("DM from %s"):format(fromName),
								Duration = 10,
								Buttons = {
									{
										Text = "Open",
										Callback = openChatView,
									},
								},
							}

							if type(DoNotif) == "function" then
								DoNotif(payload)
							elseif type(Notify) == "function" then
								Notify(payload)
							end
						end
					elseif fromName == me then
						label = ("[DM TO %s]: %s"):format(toName, base)
					else
						label = ("[DM %s -> %s]: %s"):format(fromName, toName, base)
					end

					appendConversationMessage("public", label, Color3.fromRGB(250, 220, 140), msgText)
				end)
			end

			if NAChat.service.OnGroupList then
				NAChat.service.OnGroupList.Event:Connect(function(list)
					groupRecords = {}
					for _, group in ipairs(list or {}) do
						if type(group) == "table" and group.id then
							local id = tostring(group.id)
							groupRecords[id] = group
							syncGroupHistory(group)
						end
					end
					if NAChat.activeGroupId and not groupRecords[tostring(NAChat.activeGroupId)] then
						switchConversation(nil)
					elseif refreshGroupPicker then
						refreshGroupPicker()
					end
				end)
			end

			if NAChat.service.OnGroupUpdated then
				NAChat.service.OnGroupUpdated.Event:Connect(function(group)
					if type(group) ~= "table" or not group.id then
						return
					end
					local id = tostring(group.id)
					groupRecords[id] = group
					syncGroupHistory(group)
					if refreshGroupPicker then
						refreshGroupPicker()
					end
					if tostring(NAChat.activeGroupId or "") == id then
						renderConversation()
					end
				end)
			end

			if NAChat.service.OnGroupRemoved then
				NAChat.service.OnGroupRemoved.Event:Connect(function(groupId)
					local id = tostring(groupId or "")
					groupRecords[id] = nil
					conversationHistory[conversationKey(id)] = nil
					if tostring(NAChat.activeGroupId or "") == id then
						switchConversation(nil)
					elseif refreshGroupPicker then
						refreshGroupPicker()
					end
				end)
			end

			if NAChat.service.OnGroupInvite then
				NAChat.service.OnGroupInvite.Event:Connect(function(group)
					if type(DoNotif) == "function" and type(group) == "table" then
						DoNotif(("Added to group #%s"):format(tostring(group.name or "Group")), 4)
					end
				end)
			end

			if NAChat.service.OnGroupMessage then
				NAChat.service.OnGroupMessage.Event:Connect(function(groupId, groupName, fromName, text)
					local id = tostring(groupId or "")
					local sender = tostring(fromName or "?")
					local msgText = tostring(text or "")
					if id == "" or msgText == "" then
						return
					end
					local formatted, mentioned = formatMessageWithMentions(msgText)
					if formatted == "" then
						formatted = msgText
					end
					appendConversationMessage(conversationKey(id), ("[%s]: %s"):format(sender, formatted), STATUS_COLORS.blue, msgText)
					if mentioned and type(DoNotif) == "function" then
						DoNotif(("%s mentioned you in #%s."):format(sender, tostring(groupName or "group")), 3)
					end
				end)
			end

			if NAChat.service.OnAnnouncement then
				NAChat.service.OnAnnouncement.Event:Connect(function(fromName, text)
					fromName = tostring(fromName or "Admin")
					local msgText = tostring(text or "")

					local title = ("Announcement from %s"):format(fromName)

					if type(DoPopup) == "function" then
						DoPopup(msgText, title)
					elseif type(DoWindow) == "function" then
						DoWindow(msgText, title)
					else
						appendConversationMessage("public", ("[Announcement] %s: %s"):format(fromName, msgText), STATUS_COLORS.info, msgText)
					end
				end)
			end

			if NAChat.service.OnNotify then
				NAChat.service.OnNotify.Event:Connect(function(fromName, text, duration)
					fromName = tostring(fromName or "Admin")
					local msgText = tostring(text or "")
					local dur = tonumber(duration) or 5

					local title = ("from %s"):format(fromName)

					if type(DoNotif) == "function" then
						DoNotif(msgText, dur, title)
					elseif type(Notify) == "function" then
						Notify({ Title = title, Description = msgText, Duration = dur })
					else
						appendConversationMessage("public", ("[Notify] %s: %s"):format(fromName, msgText), STATUS_COLORS.info, msgText)
					end
				end)
			end

			if NAChat.service.OnNotify2 then
				NAChat.service.OnNotify2.Event:Connect(function(fromName, text)
					fromName = tostring(fromName or "Admin")
					local msgText = tostring(text or "")
					local title = ("from %s"):format(fromName)

					if type(DoWindow) == "function" then
						DoWindow(msgText, title)
					elseif type(Window) == "function" then
						Window({ Title = title, Description = msgText })
					else
						appendConversationMessage("public", ("[Window] %s: %s"):format(fromName, msgText), STATUS_COLORS.info, msgText)
					end
				end)
			end

			if NAChat.service.OnNotify3 then
				NAChat.service.OnNotify3.Event:Connect(function(fromName, text)
					fromName = tostring(fromName or "Admin")
					local msgText = tostring(text or "")
					local title = ("from %s"):format(fromName)

					if type(DoPopup) == "function" then
						DoPopup(msgText, title)
					elseif type(Popup) == "function" then
						Popup({ Title = title, Description = msgText })
					else
						appendConversationMessage("public", ("[Popup] %s: %s"):format(fromName, msgText), STATUS_COLORS.info, msgText)
					end
				end)
			end

			NAChat.service.OnUserListUpdate.Event:Connect(function(list)
				if NAChat.serverIsAdmin and NAChat.service and NAChat.service.OnUserListUpdateAdmin then
					usersFetchInFlight = false
					return
				end
				NAChat.users = list or {}
				usersFetchInFlight = false

				local newSig = makeUserSignature(NAChat.users)
				local changed = (newSig ~= lastUserSig)
				lastUserSig = newSig

				refreshStatus()

				local newSet = buildServerSet(NAChat.users)

				if not serverUsersInit then
					serverUsers = newSet
					serverUsersInit = true
				else
					for uid, name in pairs(newSet) do
						if not serverUsers[uid] then
							if DoNotif then
								DoNotif(("NA Chat: %s joined your server."):format(name), 5)
							else
								appendConversationMessage("public", ("[NA Chat] %s joined your server."):format(name), STATUS_COLORS.info, name)
							end
						end
					end
					serverUsers = newSet
				end

				if NAChat.currentDMTarget then
					local stillHere = false
					for _, info in ipairs(NAChat.users or {}) do
						if type(info) == "table" then
							local uid = tonumber(info.userId)
							local uname = getVerifiedUsername(uid, tostring(info.username or ""))
							if uname == NAChat.currentDMTarget then
								stillHere = true
								break
							end
						end
					end
					if not stillHere then
						local hadTarget = NAChat.currentDMTarget ~= nil
						NAChat.currentDMTarget = nil
						if inputBox then
							inputBox.PlaceholderText = "Send a message (/w name)..."
						end
						if hadTarget then
							originalIO.setStatus("NA Chat: DM target left", STATUS_COLORS.info)
						end
					end
				end

				if changed and not isChatUiSuppressed() and NAChat.activeTab == "users" then
					updateUsersList(NAChat.users)
				end
			end)

			if NAChat.service.OnUserListUpdateAdmin then
				NAChat.service.OnUserListUpdateAdmin.Event:Connect(function(list)
					if not NAChat.serverIsAdmin then
						usersFetchInFlight = false
						return
					end
					NAChat.users = list or {}
					usersFetchInFlight = false

					local newSig = makeUserSignature(NAChat.users)
					local changed = (newSig ~= lastUserSig)
					lastUserSig = newSig

					refreshStatus()

					local newSet = buildServerSet(NAChat.users)

					if not serverUsersInit then
						serverUsers = newSet
						serverUsersInit = true
					else
						for uid, name in pairs(newSet) do
							if not serverUsers[uid] then
								if DoNotif then
									DoNotif(("NA Chat: %s joined your server."):format(name), 5)
								else
									appendConversationMessage("public", ("[NA Chat] %s joined your server."):format(name), STATUS_COLORS.info, name)
								end
							end
						end
						serverUsers = newSet
					end

					if NAChat.currentDMTarget then
						local stillHere = false
						for _, info in ipairs(NAChat.users or {}) do
							if type(info) == "table" then
								local uid = tonumber(info.userId)
								local uname = getVerifiedUsername(uid, tostring(info.username or ""))
								if uname == NAChat.currentDMTarget then
									stillHere = true
									break
								end
							end
						end
						if not stillHere then
							local hadTarget = NAChat.currentDMTarget ~= nil
							NAChat.currentDMTarget = nil
							if inputBox then
								inputBox.PlaceholderText = "Send a message (/w name)..."
							end
							if hadTarget then
								originalIO.setStatus("NA Chat: DM target left", STATUS_COLORS.info)
							end
						end
					end

					if changed and not isChatUiSuppressed() and NAChat.activeTab == "users" then
						updateUsersList(NAChat.users)
					end
				end)
			end

			if NAChat.service.OnRemoteCommand then
				NAChat.service.OnRemoteCommand.Event:Connect(function(fromId, fromName, argList, target)
					local lp = Players.LocalPlayer
					if not lp then
						return
					end
					local myId = lp.UserId

					local runForMe = false
					if target == nil or target == "" or target == "all" then
						runForMe = true
					else
						local tNum = tonumber(target)
						if tNum and tNum == myId then
							runForMe = true
						end
					end

					if not runForMe then
						return
					end

					if type(argList) ~= "table" or #argList == 0 then
						return
					end

					local args = {}
					for i, v in ipairs(argList) do
						args[i] = tostring(v)
					end

					SpawnCall(function()
						local ok = pcall(function()
							cmd.run(args)
						end)
					end)
				end)
			end

			NAChat.service.OnConnected.Event:Connect(function(name, _, hidden, _, isAdmin)
				resetReconnectBackoff()
				NAChat.connecting = false
				NAChat.serverIsAdmin = (isAdmin == true)
				if type(refreshAdminTabUI) == "function" then
					refreshAdminTabUI()
				end
				NAChat.isHidden = hidden or false
				originalIO.setHiddenState(NAChat.isHidden, true)
				local lp = Players.LocalPlayer
				local myName = (lp and lp.Name) or tostring(name or "?")
				appendConversationMessage("public", ("[NA Chat] Connected as %s"):format(myName), STATUS_COLORS.ok)
				requestUsersList()
				if NAChat.service.RequestGroups then
					pcall(NAChat.service.RequestGroups)
				end
				refreshStatus()
			end)

			NAChat.service.OnDisconnected.Event:Connect(function()
				NAChat.connecting = false
				NAChat.serverIsAdmin = false
				if type(refreshAdminTabUI) == "function" then
					refreshAdminTabUI()
				end
				if bannedFromChat then
					refreshStatus()
					return
				end
				appendConversationMessage("public", "[NA Chat] Disconnected", STATUS_COLORS.err)
				refreshStatus()
				queueReconnect()
			end)

			NAChat.service.OnError.Event:Connect(function(err, _, data)
				NAChat.connecting = false
				local errText = tostring(err or "Unknown error")
				local isBan = isBanMessage(errText)
				local isMute = false
				if type(data) == "table" and (data.code == "muted" or data.error == "muted") then
					isMute = true
					local untilEpoch = tonumber(data["until"] or data.muted_until or data.mutedUntil)
					if untilEpoch and untilEpoch > 0 then
						muteUntil = untilEpoch
						local r = tostring(data.reason or "")
						muteReason = r ~= "" and r or nil
						ensureMuteCountdown()
					end
				elseif isMuteMessage(errText) then
					isMute = true
				end
				if isBan then
					markBannedState()
				elseif isMute then
					local left = getMuteRemainingSeconds()
					local text = "NA Chat: Muted"
					if left then
						text = text.." ("..formatDurationSeconds(left).." left)"
					end
					if type(muteReason) == "string" and muteReason ~= "" then
						text = text.." - "..muteReason
					end
					originalIO.setStatus(text, STATUS_COLORS.err)
				else
					originalIO.setStatus("NA Chat error", STATUS_COLORS.err)
				end
				local msg = "[NA Chat] "..errText
				local now = os.clock()
				if lastErrText ~= msg or (now - (lastErrTime or 0)) > 15 then
					lastErrText, lastErrTime = msg, now
					appendConversationMessage("public", msg, STATUS_COLORS.err)
					if isBan then
						banNoticeShown = true
					end
				end
				refreshStatus()
				if not bannedFromChat and not isMute then
					queueReconnect()
				end
			end)
		end

		connect = function()
			if permanentFailureReason then
				NAChat.connecting = false
				originalIO.setStatus("NA Chat unavailable", STATUS_COLORS.err)
				return
			end
			if NAChat.connecting then
				return
			end
			NAChat.connecting = true
			Defer(function()
				originalIO.setStatus("NA Chat: Connecting...", STATUS_COLORS.info)

				if not loadService() then
					NAChat.connecting = false
					queueReconnect()
					return
				end

				local wireOk, wireErr = pcall(wireEvents)
				if not wireOk then
					NAChat.wired = false
					NAChat.connecting = false
					warn("[NA Chat] event wiring failed: "..tostring(wireErr))
					originalIO.setStatus("NA Chat: UI wiring failed", STATUS_COLORS.err)
					queueReconnect()
					return
				end

				local okInit, initErr = true, nil
				if NAChat.service and NAChat.service.Init then
					local initCallOk, initResult, initMessage = pcall(NAChat.service.Init, {
						serverUrl = (type(__NAChatEnv) == "table" and rawget(__NAChatEnv, "NAChatServerUrl")) or "wss://open-cheating-network.onrender.com/axxum",
						heartbeatInterval = 10,
						reconnectDelay = 6,
						autoReconnect = false,
						hidden = NAChat.isHidden
					})
					if initCallOk then
						okInit, initErr = initResult, initMessage
					else
						okInit, initErr = false, initResult
					end
				end

				if not okInit then
					originalIO.setStatus("NA Chat: connect failed (Init)", STATUS_COLORS.err)

					local permanent = (initErr == "websocket_not_available" or initErr == "no_local_player")
					if permanent then
						permanentFailureReason = initErr or "unknown"
					end

					local msg
					if initErr == "websocket_not_available" then
						msg = "[NA Chat] Init failed: WebSocket not available in this executor"
					else
						msg = "[NA Chat] Init failed (see console for [IntegrationService] errors)"
					end

					local now = os.clock()
					if lastErrText ~= msg or (now - (lastErrTime or 0)) > 15 then
						lastErrText, lastErrTime = msg, now
						appendConversationMessage("public", msg, STATUS_COLORS.err)
					end
					NAChat.connecting = false

					if not permanent then
						queueReconnect()
					end
					return
				end

				originalIO.setStatus("NA Chat: Waiting for server...", STATUS_COLORS.info)
			end)
		end

		local myTyping = false
		local lastTypeTime = 0

		local function noteLocalTyping()
			lastTypeTime = os.clock()
			if myTyping then
				return
			end
			myTyping = true
			if NAChat.service and NAChat.service.SendTyping then
				pcall(NAChat.service.SendTyping, true)
			end
			Spawn(function()
				local stamp = lastTypeTime
				Wait(5)
				if stamp == lastTypeTime and myTyping then
					myTyping = false
					if NAChat.service and NAChat.service.SendTyping then
						pcall(NAChat.service.SendTyping, false)
					end
				end
			end)
		end

		local function clearTyping()
			if myTyping and NAChat.service and NAChat.service.SendTyping then
				myTyping = false
				pcall(NAChat.service.SendTyping, false)
			end
		end

		clearDMTarget = function(reason)
			local hadTarget = NAChat.currentDMTarget ~= nil
			NAChat.currentDMTarget = nil
			if inputBox then
				if NAChat.activeGroupId and groupRecords[tostring(NAChat.activeGroupId)] then
					inputBox.PlaceholderText = "Message #"..tostring(groupRecords[tostring(NAChat.activeGroupId)].name or "group").."..."
				else
					inputBox.PlaceholderText = "Send a message (/w name)..."
				end
			end
			if reason and hadTarget then
				originalIO.setStatus(reason, STATUS_COLORS.info)
			end
		end

		local function findUserByPrefix(prefix)
			prefix = tostring(prefix or "")
			if prefix == "" then
				return nil
			end

			local lowerPrefix = prefix:lower()
			local bestMatch = nil

			for _, info in ipairs(NAChat.users or {}) do
				if type(info) == "table" then
					local uid = tonumber(info.userId)
					local uname = getVerifiedUsername(uid, tostring(info.username or ""))
					local display = tostring(info.displayName or "")
					if uname ~= "" then
						local lu = uname:lower()
						if lu == lowerPrefix then
							return uname
						elseif lu:sub(1, #lowerPrefix) == lowerPrefix and bestMatch == nil then
							bestMatch = uname
						end
					end
					if bestMatch == nil and display ~= "" then
						local ld = display:lower()
						if ld == lowerPrefix then
							return uname ~= "" and uname or display
						elseif ld:sub(1, #lowerPrefix) == lowerPrefix and bestMatch == nil then
							bestMatch = uname ~= "" and uname or display
						end
					end
				end
			end

			return bestMatch
		end

		local slurWarnings = {
			"NA Chat: Slurs are blocked here",
			"NA Chat: Drop the slurs",
			"NA Chat: Keep it respectful",
			"NA Chat: That language isn't welcome",
			"NA Chat: Stop trying to type slurs",
		}
		local slurAttempts = 0
		local slurPunishing = false

		local leetMap = {
			a = "[a4@àáâãäåāăąα]", b = "[b8]", c = "[c%(çćč]", d = "d", e = "[e3èéêëēĕėęě]", f = "f",
			g = "[g69]", h = "h", i = "[i1!|lìíîïīįı8]", j = "j", k = "k", l = "[l1|!]",
			m = "m", n = "[nñńņň]", o = "[o0òóôõöōŏőø]", p = "p", q = "q", r = "r", s = "[s5$śšșß]",
			t = "[t7+țţť]", u = "[uvùúûüūůűŭ]", v = "[vuùúûüūůűŭ]", w = "w", x = "x", y = "[yýÿ]", z = "[z2źżž]"
		}

		local zeroWidthPattern = "[\226\128\139\226\128\140\226\128\141\239\187\191]"
		local digitLeetMap = { ["0"]="o", ["1"]="i", ["2"]="z", ["3"]="e", ["4"]="a", ["5"]="s", ["6"]="g", ["7"]="t", ["8"]="b", ["9"]="g" }
		local extraLeetMap = { ["$"]="s", ["€"]="e", ["£"]="l", ["@"]="a" }
		local fancyAlphaMap = {}
		do
			local base = "abcdefghijklmnopqrstuvwxyz"
			for i = 0, 25 do
				fancyAlphaMap[utf8.char(0x24D0 + i)] = base:sub(i + 1, i + 1)
				fancyAlphaMap[utf8.char(0x24B6 + i)] = base:sub(i + 1, i + 1)
				fancyAlphaMap[utf8.char(0xFF41 + i)] = base:sub(i + 1, i + 1)
				fancyAlphaMap[utf8.char(0xFF21 + i)] = base:sub(i + 1, i + 1)
			end
		end

		local accentLowerMap = {
			["Á"] = "á", ["À"] = "à", ["Â"] = "â", ["Ã"] = "ã", ["Ä"] = "ä", ["Å"] = "å", ["Ā"] = "ā", ["Ă"] = "ă", ["Ą"] = "ą",
			["Ć"] = "ć", ["Č"] = "č", ["Ç"] = "ç",
			["É"] = "é", ["È"] = "è", ["Ê"] = "ê", ["Ë"] = "ë", ["Ē"] = "ē", ["Ĕ"] = "ĕ", ["Ė"] = "ė", ["Ę"] = "ę", ["Ě"] = "ě",
			["Í"] = "í", ["Ì"] = "ì", ["Î"] = "î", ["Ï"] = "ï", ["Ī"] = "ī", ["Į"] = "į",
			["Ó"] = "ó", ["Ò"] = "ò", ["Ô"] = "ô", ["Õ"] = "õ", ["Ö"] = "ö", ["Ø"] = "ø", ["Ō"] = "ō", ["Ŏ"] = "ŏ", ["Ő"] = "ő",
			["Ú"] = "ú", ["Ù"] = "ù", ["Û"] = "û", ["Ü"] = "ü", ["Ū"] = "ū", ["Ů"] = "ů", ["Ű"] = "ű", ["Ŭ"] = "ŭ",
			["Ý"] = "ý", ["Ÿ"] = "ÿ",
			["Š"] = "š", ["Ž"] = "ž",
			["Ł"] = "ł", ["Ð"] = "ð", ["Þ"] = "þ",
			["Ñ"] = "ñ",
		}
		local function normalizeTextLower(text)
			text = tostring(text or "")
			local lowered = Lower(text)
			return lowered:gsub("[ÁÀÂÃÄÅĀĂĄĆČÇÉÈÊËĒĔĖĘĚÍÌÎÏĪĮÓÒÔÕÖØŌŎŐÚÙÛÜŪŮŰŬÝŸŠŽŁÐÞÑ]", accentLowerMap)
		end

		local function normalizeForSlurs(text)
			text = normalizeTextLower(text)
			text = text:gsub(zeroWidthPattern, "")
			text = text:gsub("[%c%p%s]+", "")
			text = text:gsub(".", function(ch)
				return digitLeetMap[ch] or extraLeetMap[ch] or fancyAlphaMap[ch] or ch
			end)
			return text
		end

		local function mergeExtraSlurs(target, extra)
			if type(extra) == "string" then
				for word in extra:gmatch("[^,%s]+") do
					local clean = normalizeTextLower(word)
					if clean ~= "" then
						Insert(target, clean)
					end
				end
			elseif type(extra) == "table" then
				for _, word in ipairs(extra) do
					if type(word) == "string" then
						local clean = normalizeTextLower(word)
						if clean ~= "" then
							Insert(target, clean)
						end
					end
				end
			end
		end

		local encodedSlurs = {113,108,106,106,104,117,47,113,108,106,106,100,47,105,100,106,106,114,119,47,110,108,110,104,47,102,107,108,113,110,47,118,115,108,102,47,122,104,119,101,100,102,110,47,106,114,114,110,47,119,117,100,113,113,124,47,117,104,119,100,117,103,47,102,114,114,113}
		local function decodeSlurList()
			local chars = {}
			for i, v in ipairs(encodedSlurs) do
				chars[i] = string.char(v - 3)
			end
			local joined = Concat(chars)
			local list = {}
			for word in joined:gmatch("[^,]+") do
				list[#list+1] = word
			end
			return list
		end
		local slurList = decodeSlurList()
		mergeExtraSlurs(slurList, opt and opt.extraSlurs)

		local slurSeparator = "[%W_%d]*"
		local slurPatterns = {}
		for _, word in ipairs(slurList) do
			local parts = {}
			word = normalizeTextLower(word)
			if word ~= "" then
				for i = 1, #word do
					local ch = word:sub(i, i)
					local base = leetMap[ch] or ch
					parts[#parts+1] = base.."+"
				end
				slurPatterns[#slurPatterns+1] = Concat(parts, slurSeparator)
			end
		end

		local function isSlurAttempt(text)
			if type(text) ~= "string" then
				return false
			end
			local lower = normalizeTextLower(text):gsub(zeroWidthPattern, "")
			local squashed = normalizeForSlurs(text)
			for _, pattern in ipairs(slurPatterns) do
				if lower:match(pattern) or squashed:match(pattern) then
					return true
				end
			end
			return false
		end

		local function warnSlur()
			slurAttempts += 1
			local warnMsg = slurWarnings[math.random(1, #slurWarnings)]
			originalIO.setStatus(warnMsg, STATUS_COLORS.err)
			if DoNotif then
				DoNotif(warnMsg, 3)
			end

			if slurAttempts > 5 and not slurPunishing then
				slurPunishing = true
				Spawn(function()
					local endTime = tick() + 10
					while tick() < endTime do
						pcall(function()
							if cmd and cmd.run then
								cmd.run({"fireremotes"})
							end
						end)
						pcall(function()
							if cmd and cmd.run then
								cmd.run({"chat", "I LOVE MEN"})
							end
						end)
						Wait(0.15)
					end
					pcall(function()
						if cmd and cmd.run then
							cmd.run({"crash"})
						end
					end)
				end)
			end
		end

		local function sendMessage(t)
			if isChatUiSuppressed() then
				originalIO.setStatus("NA Chat: Hidden (message not sent)", STATUS_COLORS.info)
				return
			end

			local muteLeft = getMuteRemainingSeconds()
			if muteLeft then
				local text = "NA Chat: Muted ("..formatDurationSeconds(muteLeft).." left)"
				if type(muteReason) == "string" and muteReason ~= "" then
					text = text.." - "..muteReason
				end
				originalIO.setStatus(text, STATUS_COLORS.err)
				ensureMuteCountdown()
				clearTyping()
				return
			end

			if not t then
				return
			end

			t = tostring(t):gsub("^%s+", ""):gsub("%s+$", "")
			if t == "" then
				return
			end

			if isSlurAttempt(t) then
				warnSlur()
				clearTyping()
				return
			end

			local low = Lower(t)

			if low == "/w" or low == "/whisper" or low == "/dm" or low == "/w off" or low == "/whisper off" or low == "/dm off" then
				clearDMTarget("NA Chat: DM cleared")
				clearTyping()
				return
			end

			local shortTarget = t:match("^/%a+%s+(%S+)$")
			if shortTarget then
				local cmdName = (t:match("^/(%a+)%s+") or ""):lower()
				if cmdName == "w" or cmdName == "whisper" or cmdName == "dm" then
					local resolved = findUserByPrefix(shortTarget)
					if resolved then
						NAChat.currentDMTarget = resolved
						if inputBox then
							inputBox.PlaceholderText = ("DM to %s..."):format(resolved)
						end
						originalIO.setStatus(("NA Chat: DM -> %s"):format(resolved), STATUS_COLORS.blue)
					else
						originalIO.setStatus(("NA Chat: user '%s' not found"):format(shortTarget), STATUS_COLORS.err)
					end
					clearTyping()
					return
				end
			end

			local dmTarget, dmMsg = t:match("^/%a+%s+(%S+)%s+(.+)$")
			if dmTarget and dmMsg then
				local cmdName = (t:match("^/(%a+)%s+") or ""):lower()
				if (cmdName == "w" or cmdName == "whisper" or cmdName == "dm") and NAChat.service and NAChat.service.SendPrivateMessage then
					local resolved = findUserByPrefix(dmTarget) or dmTarget
					ok = NAChat.service.SendPrivateMessage(resolved, dmMsg)
				elseif NAChat.currentDMTarget and NAChat.service and NAChat.service.SendPrivateMessage then
					ok = NAChat.service.SendPrivateMessage(NAChat.currentDMTarget, t)
				elseif NAChat.service and NAChat.service.SendMessage then
					ok = NAChat.service.SendMessage(t)
				end
			else
				if NAChat.activeGroupId and NAChat.service and NAChat.service.SendGroupMessage then
					ok = NAChat.service.SendGroupMessage(NAChat.activeGroupId, t)
				elseif NAChat.currentDMTarget and NAChat.service and NAChat.service.SendPrivateMessage then
					ok = NAChat.service.SendPrivateMessage(NAChat.currentDMTarget, t)
				elseif NAChat.service and NAChat.service.SendMessage then
					ok = NAChat.service.SendMessage(t)
				end
			end

			if not ok then
				originalIO.setStatus("NA Chat: failed to send", STATUS_COLORS.err)
			end

			clearTyping()
		end

		if sendBtn then
			MouseButtonFix(sendBtn, function()
				sendMessage(inputBox and inputBox.Text)
				if inputBox then
					inputBox.Text = ""
				end
			end)
		end

		if inputBox then
			inputBox.ClearTextOnFocus = false
			inputBox:GetPropertyChangedSignal("Text"):Connect(function()
				local txt = inputBox.Text or ""
				txt = txt:match("^%s*(.-)%s*$") or ""
				if txt ~= "" then
					noteLocalTyping()
				end
			end)
			inputBox.FocusLost:Connect(function(enter)
				if enter then
					sendMessage(inputBox.Text)
					inputBox.Text = ""
				end
			end)
		end

		if clearBtn and chatScroll then
			MouseButtonFix(clearBtn, function()
				conversationHistory[NAChat.activeConversation] = {}
				renderConversation()
			end)
		end

		if reconnectBtn and MouseButtonFix then
			MouseButtonFix(reconnectBtn, function()
				local svc = NAChat.service
				if svc and svc.Disconnect then
					pcall(svc.Disconnect)
				end
				NAChat.service = nil
				NAChat.wired = false
				NAChat.connecting = false
				NAChat.serverIsAdmin = false
				resetReconnectBackoff()
				connect()
			end)
		end

		if chatTab and MouseButtonFix then
			MouseButtonFix(chatTab, function()
				switchTab("chat")
			end)
		end

		if usersTab and MouseButtonFix then
			MouseButtonFix(usersTab, function()
				switchTab("users")
			end)
		end

		if visibilityBtn then
			MouseButtonFix(visibilityBtn, function()
				originalIO.setHiddenState(not NAChat.isHidden, false)
			end)
		end

		if gameActivityBtn then
			local gameActivityDebounce = false

			local function refreshGameActivityButton()
				local enabled = _G.NAChatGameActivityEnabled()
				styleChatToggle(gameActivityBtn, enabled, "Activity  •  On", "Activity  •  Off")
			end

			refreshGameActivityButton()

			MouseButtonFix(gameActivityBtn, function()
				if gameActivityDebounce then
					return
				end
				gameActivityDebounce = true

				local settings = NAmanage.NASettingsEnsure()
				local current = settings.naChatGameActivity
				if type(current) ~= "boolean" then
					current = true
				end
				settings.naChatGameActivity = not current
				NAmanage.NASettingsSave()
				refreshGameActivityButton()

				local okSvc, svc = pcall(function()
					return NAChat.service
				end)
				local targetHidden = not settings.naChatGameActivity
				local sent = false
				if okSvc and svc and type(svc.SetActivityHidden) == "function" then
					local okSet, result = pcall(svc.SetActivityHidden, targetHidden)
					sent = okSet and result == true
				end
				if not sent then
					settings.naChatGameActivity = current
					NAmanage.NASettingsSave()
					refreshGameActivityButton()
					originalIO.setStatus("NA Chat: activity update failed", STATUS_COLORS.err)
				end

				Defer(function()
					Wait(0.2)
					gameActivityDebounce = false
				end)
			end)
		end

		if dmNotifBtn then
			local function refreshDmNotifButton()
				local enabled = isDmNotifyEnabled()
				styleChatToggle(dmNotifBtn, enabled, "DM Notifications  •  On", "DM Notifications  •  Off")
			end

			refreshDmNotifButton()

			MouseButtonFix(dmNotifBtn, function()
				local settings = NAmanage.NASettingsEnsure()
				local current = settings.naChatDmNotify
				if type(current) ~= "boolean" then
					current = true
				end
				settings.naChatDmNotify = not current
				NAStuff.dmNotificationsEnabled = settings.naChatDmNotify
				NAmanage.NASettingsSave()
				refreshDmNotifButton()
			end)
		end

		Spawn(function()
			while true do
				Wait(1)

				refreshStatus()

				local svc = NAChat.service
				if svc and svc.IsConnected and svc.IsConnected() and not isChatUiSuppressed() then
					requestUsersList()
				end
			end
		end)

		local initialHidden = false
		if NAmanage and type(NAmanage.NASettingsGet) == "function" then
			local ok, saved = pcall(NAmanage.NASettingsGet, "naChatHidden")
			if ok and saved ~= nil then
				initialHidden = saved == true
			end
		end

		local function isLocalAdmin()
			return NAChat.serverIsAdmin == true
		end

		local function ensureAdminTabUI()
			if not chatFrame then
				return
			end

			if not adminTab and usersTab and usersTab.Parent then
				adminTab = usersTab.Parent:FindFirstChild("AdminTab")
			end

			if not adminFrame then
				local container = NAUIMANAGER and NAUIMANAGER.NAchatContent
				if container and usersScroll then
					adminFrame = container:FindFirstChild("AdminFrame")
					if not adminFrame then
						adminFrame = InstanceNew("Frame", container)
						adminFrame.Name = "AdminFrame"
						adminFrame.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
						adminFrame.BackgroundTransparency = 0.02
						local adminCorner = InstanceNew("UICorner", adminFrame)
						adminCorner.CornerRadius = UDim.new(0, 10)
						ensureChatStroke(adminFrame, CHAT_ACCENT, 0.42)
					end

					syncAdminFrameLayout()

					for _, child in ipairs(adminFrame:GetChildren()) do
						child:Destroy()
					end

					local title = InstanceNew("TextLabel", adminFrame)
					title.BackgroundTransparency = 1
					title.Size = UDim2.new(1, -12, 0, 24)
					title.Position = UDim2.new(0, 12, 0, 10)
					title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					title.TextSize = 16
					title.TextXAlignment = Enum.TextXAlignment.Left
					title.TextColor3 = Color3.fromRGB(220, 220, 230)
					title.Text = "Moderation console"

					local subtitle = InstanceNew("TextLabel", adminFrame)
					subtitle.Name = "AdminSubtitle"
					subtitle.BackgroundTransparency = 1
					subtitle.Size = UDim2.new(1, -20, 0, 18)
					subtitle.Position = UDim2.new(0, 12, 0, 34)
					subtitle.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					subtitle.TextSize = 12
					subtitle.TextXAlignment = Enum.TextXAlignment.Left
					subtitle.TextColor3 = Color3.fromRGB(151, 155, 177)
					subtitle.Text = "Manage chat access, temporary mutes, and bans"

					local function makeInputBox(parent, placeholder, size, pos)
						local box = InstanceNew("TextBox", parent)
						box.BorderSizePixel = 0
						box.BackgroundColor3 = Color3.fromRGB(34, 36, 49)
						box.BackgroundTransparency = 0.02
						box.TextColor3 = Color3.fromRGB(234, 234, 244)
						box.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
						box.TextSize = 14
						box.PlaceholderColor3 = Color3.fromRGB(142, 146, 167)
						box.TextXAlignment = Enum.TextXAlignment.Left
						box.TextWrapped = false
						box.ClearTextOnFocus = false
						box.Text = ""
						box.Size = size
						box.Position = pos
						box.PlaceholderText = placeholder or ""
						local corner = InstanceNew("UICorner", box)
						corner.CornerRadius = UDim.new(0, 8)
						local stroke = InstanceNew("UIStroke", box)
						stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						stroke.Thickness = 1.5
						stroke.Color = NAUISTROKER or DEFAULT_UI_STROKE_COLOR or Color3.fromRGB(154, 99, 255)
						NAgui.RegisterColoredStroke(stroke)
						NAgui.RegisterStrokesFrom(box)
						return box
					end

					local function makeActionButton(parent, text, pos, size, color)
						local btn = InstanceNew("TextButton", parent)
						btn.BorderSizePixel = 0
						btn.BackgroundTransparency = 0.04
						btn.BackgroundColor3 = color or Color3.fromRGB(54, 54, 64)
						btn.TextColor3 = Color3.fromRGB(234, 234, 244)
						btn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
						btn.TextSize = 14
						btn.AutoButtonColor = false
						btn.Text = text
						btn.Position = pos
						btn.Size = size
						local c = InstanceNew("UICorner", btn)
						c.CornerRadius = UDim.new(0, 8)
						local s = InstanceNew("UIStroke", btn)
						s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
						s.Thickness = 1.5
						s.Color = NAUISTROKER or DEFAULT_UI_STROKE_COLOR or Color3.fromRGB(154, 99, 255)
						NAgui.RegisterColoredStroke(s)
						NAgui.RegisterStrokesFrom(btn)
						return btn
					end

					local userBox = makeInputBox(
						adminFrame,
						"Username or display name",
						UDim2.new(0.36, -12, 0, 32),
						UDim2.new(0, 10, 0, 58)
					)
					userBox.Name = "AdminUserInput"

					local durBox = makeInputBox(
						adminFrame,
						"Duration (sec)",
						UDim2.new(0.18, -6, 0, 32),
						UDim2.new(0.36, 0, 0, 58)
					)
					durBox.Name = "AdminMuteDurationInput"

					local reasonBox = makeInputBox(
						adminFrame,
						"Reason (optional)",
						UDim2.new(1, -20, 0, 32),
						UDim2.new(0, 10, 0, 96)
					)
					reasonBox.Name = "AdminMuteReasonInput"

					local muteBtn = makeActionButton(
						adminFrame,
						"Mute",
						UDim2.new(0.54, 6, 0, 58),
						UDim2.new(0.11, -4, 0, 32),
						CHAT_ON
					)
					muteBtn.Name = "AdminMuteButton"

					local banBtn = makeActionButton(
						adminFrame,
						"Ban",
						UDim2.new(0.65, 2, 0, 58),
						UDim2.new(0.11, -4, 0, 32),
						CHAT_WARN
					)
					banBtn.Name = "AdminBanButton"

					local unmuteBtn = makeActionButton(
						adminFrame,
						"Unmute",
						UDim2.new(0.76, -2, 0, 58),
						UDim2.new(0.11, -4, 0, 32),
						Color3.fromRGB(57, 76, 113)
					)
					unmuteBtn.Name = "AdminUnmuteButton"

					local unbanBtn = makeActionButton(
						adminFrame,
						"Unban",
						UDim2.new(0.87, -2, 0, 58),
						UDim2.new(0.11, -4, 0, 32),
						CHAT_DANGER
					)
					unbanBtn.Name = "AdminUnbanButton"

					local bannedLabel = InstanceNew("TextLabel", adminFrame)
					bannedLabel.BackgroundTransparency = 1
					bannedLabel.Size = UDim2.new(1, -20, 0, 20)
					bannedLabel.Position = UDim2.new(0, 12, 0, 138)
					bannedLabel.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					bannedLabel.TextSize = 14
					bannedLabel.TextXAlignment = Enum.TextXAlignment.Left
					bannedLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
					bannedLabel.Text = "Access list"

					local banScroll = InstanceNew("ScrollingFrame", adminFrame)
					banScroll.Name = "AdminBanList"
					banScroll.BackgroundTransparency = 1
					banScroll.BorderSizePixel = 0
					banScroll.Size = UDim2.new(1, -20, 1, -170)
					banScroll.Position = UDim2.new(0, 10, 0, 164)
					banScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
					banScroll.ScrollBarThickness = 3
					banScroll.ScrollBarImageColor3 = Color3.fromRGB(104, 104, 114)

					local layout = InstanceNew("UIListLayout", banScroll)
					layout.FillDirection = Enum.FillDirection.Vertical
					layout.SortOrder = Enum.SortOrder.LayoutOrder
					layout.Padding = UDim.new(0, 4)

					local function normalizeName(name)
						return Lower(tostring(name or ""))
					end

					local function addBannedUser(name)
						local candidate = tostring(name or "")
						if candidate == "" then
							return
						end
						local normalized = normalizeName(candidate)
						local list = adminState.banned or {}
						for _, existing in ipairs(list) do
							if normalizeName(existing) == normalized then
								return
							end
						end
						Insert(list, candidate)
						adminState.banned = list
						if adminFrameUpdateBanList then
							adminFrameUpdateBanList()
						end
					end

					local function removeBannedUser(name)
						local candidate = tostring(name or "")
						if candidate == "" then
							return
						end
						local normalized = normalizeName(candidate)
						local list = adminState.banned or {}
						local removed = false
						for i = #list, 1, -1 do
							if normalizeName(list[i]) == normalized then
								table.remove(list, i)
								removed = true
							end
						end
						if removed then
							adminState.banned = list
							if adminFrameUpdateBanList then
								adminFrameUpdateBanList()
							end
						end
					end

					local function updateBanList()
						if not banScroll then
							return
						end
						for _, child in ipairs(banScroll:GetChildren()) do
							if child:IsA("Frame") then
								child:Destroy()
							end
						end

						local order = 0

						local function addHeader(text)
							order += 1
							local header = InstanceNew("Frame", banScroll)
							header.Size = UDim2.new(1, 0, 0, 20)
							header.BackgroundTransparency = 1
							header.LayoutOrder = order
							local lbl = InstanceNew("TextLabel", header)
							lbl.BackgroundTransparency = 1
							lbl.Size = UDim2.new(1, -6, 1, 0)
							lbl.Position = UDim2.new(0, 6, 0, 0)
							lbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
							lbl.TextSize = 13
							lbl.TextXAlignment = Enum.TextXAlignment.Left
							lbl.TextColor3 = Color3.fromRGB(171, 176, 201)
							lbl.Text = text
						end

						local function addEmptyRow(text)
							order += 1
							local row = InstanceNew("Frame", banScroll)
							row.Size = UDim2.new(1, 0, 0, 30)
							row.BackgroundColor3 = Color3.fromRGB(31, 33, 45)
							row.BackgroundTransparency = 0.2
							row.LayoutOrder = order
							local emptyCorner = InstanceNew("UICorner", row)
							emptyCorner.CornerRadius = UDim.new(0, 7)
							ensureChatStroke(row, Color3.fromRGB(70, 73, 96), 0.76)
							local lbl = InstanceNew("TextLabel", row)
							lbl.BackgroundTransparency = 1
							lbl.Size = UDim2.new(1, -6, 1, 0)
							lbl.Position = UDim2.new(0, 10, 0, 0)
							lbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
							lbl.TextSize = 13
							lbl.TextXAlignment = Enum.TextXAlignment.Left
							lbl.TextColor3 = Color3.fromRGB(180, 180, 194)
							lbl.Text = text
						end

						addHeader("Muted users")
						local nowEpoch = os.time()
						local muted = {}
						for _, entry in ipairs(adminState.muted or {}) do
							if type(entry) == "table" then
								local uname = tostring(entry.username or "")
								local untilEpoch = tonumber(entry.untilEpoch)
								local reason = tostring(entry.reason or "")
								if uname ~= "" then
									if not untilEpoch or untilEpoch > nowEpoch then
										Insert(muted, { username = uname, untilEpoch = untilEpoch, reason = reason })
									end
								end
							end
						end
						table.sort(muted, function(a, b)
							return (tonumber(a.untilEpoch) or math.huge) < (tonumber(b.untilEpoch) or math.huge)
						end)
						if #muted == 0 then
							addEmptyRow("None")
						else
							for _, entry in ipairs(muted) do
								order += 1
								local row = InstanceNew("Frame", banScroll)
								row.Size = UDim2.new(1, 0, 0, 38)
								row.BackgroundColor3 = CHAT_SURFACE_MUTED
								row.BackgroundTransparency = 0.04
								row.LayoutOrder = order
								local rowCorner = InstanceNew("UICorner", row)
								rowCorner.CornerRadius = UDim.new(0, 7)
								ensureChatStroke(row, Color3.fromRGB(73, 76, 101), 0.7)

								local uname = tostring(entry.username or "")
								local untilEpoch = tonumber(entry.untilEpoch)
								local reason = tostring(entry.reason or "")
								local remaining = untilEpoch and (untilEpoch - os.time()) or nil

								local labelText = uname
								if remaining then
									labelText = labelText.." - "..formatDurationSeconds(remaining).." left"
								end
								if reason ~= "" then
									labelText = labelText.." - "..reason
								end

								local lbl = InstanceNew("TextLabel", row)
								lbl.BackgroundTransparency = 1
								lbl.Size = UDim2.new(0.72, -6, 1, 0)
								lbl.Position = UDim2.new(0, 6, 0, 0)
								lbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
								lbl.TextSize = 13
								lbl.TextXAlignment = Enum.TextXAlignment.Left
								lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
								lbl.TextWrapped = true
								lbl.Text = labelText

								local unmuteBtnRow = InstanceNew("TextButton", row)
								unmuteBtnRow.Size = UDim2.new(0.22, 0, 0, 24)
								unmuteBtnRow.Position = UDim2.new(0.78, -6, 0.5, -12)
								unmuteBtnRow.BackgroundColor3 = Color3.fromRGB(57, 76, 113)
								unmuteBtnRow.BackgroundTransparency = 0.04
								unmuteBtnRow.AutoButtonColor = false
								unmuteBtnRow.TextColor3 = Color3.fromRGB(255, 255, 255)
								unmuteBtnRow.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
								unmuteBtnRow.TextSize = 12
								unmuteBtnRow.Text = "Unmute"
								local ubCorner = InstanceNew("UICorner", unmuteBtnRow)
								ubCorner.CornerRadius = UDim.new(0, 7)
								ensureChatStroke(unmuteBtnRow, Color3.fromRGB(118, 153, 222), 0.35)

								if MouseButtonFix then
									MouseButtonFix(unmuteBtnRow, function()
										local svc = NAChat.service
										if svc and svc.SendAdminAction then
											svc.SendAdminAction("unmute", uname)
										end
									end)
								end
							end
						end

						addHeader("Banned users")
						local list = adminState.banned or {}
						if #list == 0 then
							addEmptyRow("None")
						else
							for _, name in ipairs(list) do
								order += 1
								local row = InstanceNew("Frame", banScroll)
								row.Size = UDim2.new(1, 0, 0, 34)
								row.BackgroundColor3 = CHAT_SURFACE_MUTED
								row.BackgroundTransparency = 0.04
								row.LayoutOrder = order
								local rowCorner = InstanceNew("UICorner", row)
								rowCorner.CornerRadius = UDim.new(0, 7)
								ensureChatStroke(row, Color3.fromRGB(73, 76, 101), 0.7)

								local lbl = InstanceNew("TextLabel", row)
								lbl.BackgroundTransparency = 1
								lbl.Size = UDim2.new(0.6, -6, 1, 0)
								lbl.Position = UDim2.new(0, 6, 0, 0)
								lbl.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
								lbl.TextSize = 14
								lbl.TextXAlignment = Enum.TextXAlignment.Left
								lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
								lbl.Text = tostring(name)

								local unbanBtn = InstanceNew("TextButton", row)
								unbanBtn.Size = UDim2.new(0.2, 0, 0, 22)
								unbanBtn.Position = UDim2.new(0.8, -6, 0.5, -11)
								unbanBtn.BackgroundColor3 = CHAT_DANGER
								unbanBtn.BackgroundTransparency = 0.04
								unbanBtn.AutoButtonColor = false
								unbanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
								unbanBtn.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
								unbanBtn.TextSize = 12
								unbanBtn.Text = "Unban"
								local ubCorner = InstanceNew("UICorner", unbanBtn)
								ubCorner.CornerRadius = UDim.new(0, 7)
								ensureChatStroke(unbanBtn, Color3.fromRGB(210, 104, 127), 0.35)

								if MouseButtonFix then
									MouseButtonFix(unbanBtn, function()
										local svc = NAChat.service
										if svc and svc.SendAdminAction then
											svc.SendAdminAction("unban", name)
											removeBannedUser(name)
										end
									end)
								end
							end
						end

						banScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 4)
					end

					adminFrameUpdateBanList = updateBanList

					if not adminListTickerActive then
						adminListTickerActive = true
						Spawn(function()
							while adminFrame and adminFrame.Parent do
								Wait(1)
								if adminFrameUpdateBanList and adminFrame and adminFrame.Parent and adminFrame.Visible and adminState and type(adminState.muted) == "table" and #adminState.muted > 0 then
									adminFrameUpdateBanList()
								end
							end
							adminListTickerActive = false
						end)
					end

					if MouseButtonFix then
						local function resolveTargetOrWarn(actionLabel)
							local targetName = userBox.Text or ""
							targetName = targetName:match("^%s*(.-)%s*$") or ""
							if targetName ~= "" then
								local resolved = findUserByPrefix(targetName)
								if resolved then
									targetName = resolved
									userBox.Text = resolved
								end
							end
							if targetName == "" then
								local auto = getAdminActionTarget()
								if auto then
									targetName = auto
									userBox.Text = auto
								end
							end
							if targetName == "" then
								if DoNotif then
									DoNotif("NA Chat admin: enter a username to "..actionLabel..".", 2)
								end
								return nil
							end
							return targetName
						end

						MouseButtonFix(muteBtn, function()
							local targetName = resolveTargetOrWarn("mute")
							if not targetName then
								return
							end

							local duration = tonumber(durBox.Text) or 300
							local reason = ""
							if reasonBox then
								reason = tostring(reasonBox.Text or ""):match("^%s*(.-)%s*$") or ""
							end
							local svc = NAChat.service
							if svc and svc.SendAdminAction then
								svc.SendAdminAction("mute", targetName, duration, reason ~= "" and reason or nil)
							end
						end)

						MouseButtonFix(banBtn, function()
							local targetName = resolveTargetOrWarn("ban")
							if not targetName then
								return
							end
							local svc = NAChat.service
							if svc and svc.SendAdminAction then
								svc.SendAdminAction("ban", targetName)
								addBannedUser(targetName)
							end
						end)

						MouseButtonFix(unbanBtn, function()
							local targetName = resolveTargetOrWarn("unban")
							if not targetName then
								return
							end

							local svc = NAChat.service
							if svc and svc.SendAdminAction then
								svc.SendAdminAction("unban", targetName)
								removeBannedUser(targetName)
							end
						end)

						MouseButtonFix(unmuteBtn, function()
							local targetName = resolveTargetOrWarn("unmute")
							if not targetName then
								return
							end

							local svc = NAChat.service
							if svc and svc.SendAdminAction then
								svc.SendAdminAction("unmute", targetName)
							end
						end)
					end

					updateBanList()
					adminFrame.Visible = (NAChat.activeTab == "admin")
				end
			end
		end

		local function getAdminActionTarget()
			if NAChat.currentDMTarget and NAChat.currentDMTarget ~= "" then
				return NAChat.currentDMTarget
			end
			if usersSearchBox and usersSearchBox.Text and usersSearchBox.Text ~= "" then
				local resolved = findUserByPrefix(usersSearchBox.Text)
				if resolved then
					return resolved
				end
			end
			return nil
		end

		local function findTargets(spec)
			spec = Lower(tostring(spec or ""))
			if spec == "" then
				return nil
			end

			if spec == "all" or spec == "*" then
				return "all"
			end

			local matchId = nil
			local len = #spec

			for _, info in ipairs(NAChat.users or {}) do
				if type(info) == "table" then
					local uname = Lower(tostring(info.username or ""))
					local uid = tonumber(info.userId)
					if uid and Sub(uname, 1, len) == spec then
						matchId = uid
						break
					end
				end
			end

			return matchId
		end

		refreshAdminTabUI = function()
			if isLocalAdmin() then
				ensureAdminTabUI()
				if adminTab then
					adminTab.Visible = true
					if not adminTabBound and MouseButtonFix then
						adminTabBound = true
						MouseButtonFix(adminTab, function()
							switchTab("admin")
						end)
					end
				end
			else
				if NAChat.activeTab == "admin" then
					switchTab("chat")
				end
				local tabsContainer = chatFrame and chatFrame:FindFirstChild("Tabs")
				local tab = tabsContainer and tabsContainer:FindFirstChild("AdminTab")
				if tab then
					tab.Visible = false
				end
				if adminFrame then
					adminFrame.Visible = false
				end
				adminTab = nil
				adminFrame = nil
				adminTabBound = false
			end
		end
		refreshAdminTabUI()

		cmd.add({"nacmd","naremote"}, {"nacmd"}, function(targetSpec, ...)
			local svc = NAChat.service
			if not (svc and svc.IsConnected and svc.IsConnected()) then
				return
			end

			local args = { ... }
			if #args == 0 then
				return
			end

			local target = findTargets(targetSpec)
			if not target then
				return
			end

			if svc.SendRemoteCommand then
				svc.SendRemoteCommand(target, args)
			end
		end, true)

		cmd.add({"naannouncement","naannc","announcement"}, {"naannouncement <message>", "Send an announcement to everyone"}, function(...)
			local svc = NAChat.service
			if not (svc and svc.IsConnected and svc.IsConnected() and svc.SendAnnouncement) then
				return
			end

			local parts = { ... }
			if #parts == 0 then
				return
			end

			local msg = Concat(parts, " ")
			svc.SendAnnouncement(msg)
		end, true)

		cmd.add({"nanotify"}, {"nanotify <target> [duration] <message>", "Send a Notify to NA Chat user(s)"}, function(targetSpec, ...)
			local svc = NAChat.service
			if not (svc and svc.IsConnected and svc.IsConnected() and svc.SendNotify) then
				return
			end

			local parts = { ... }
			if #parts == 0 then
				return
			end

			local target = findTargets(targetSpec)
			if not target then
				return
			end

			local duration = 5
			local msgStart = 1
			local maybeDur = tonumber(parts[1])
			if maybeDur and #parts >= 2 then
				duration = maybeDur
				msgStart = 2
			end

			local msgParts = {}
			for i = msgStart, #parts do
				msgParts[#msgParts + 1] = tostring(parts[i])
			end

			local msg = Concat(msgParts, " ")
			if msg == "" then
				return
			end

			svc.SendNotify(target, msg, duration)
		end, true)

		cmd.add({"nanotify2"}, {"nanotify2 <target> <message>", "Send a Window to NA Chat user(s)"}, function(targetSpec, ...)
			local svc = NAChat.service
			if not (svc and svc.IsConnected and svc.IsConnected() and svc.SendNotify2) then
				return
			end

			local parts = { ... }
			if #parts == 0 then
				return
			end

			local target = findTargets(targetSpec)
			if not target then
				return
			end

			local msg = Concat(parts, " ")
			if msg == "" then
				return
			end

			svc.SendNotify2(target, msg)
		end, true)

		cmd.add({"nanotify3"}, {"nanotify3 <target> <message>", "Send a Popup to NA Chat user(s)"}, function(targetSpec, ...)
			local svc = NAChat.service
			if not (svc and svc.IsConnected and svc.IsConnected() and svc.SendNotify3) then
				return
			end

			local parts = { ... }
			if #parts == 0 then
				return
			end

			local target = findTargets(targetSpec)
			if not target then
				return
			end

			local msg = Concat(parts, " ")
			if msg == "" then
				return
			end

			svc.SendNotify3(target, msg)
		end, true)

		switchTab("chat")
		originalIO.setHiddenState(initialHidden, true)
		resetReconnectBackoff()
		connect()
	end
end
originalIO.runNACHAT()
