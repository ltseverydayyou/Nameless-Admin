NAmanage.RewindCreateMobileButton = function()
	if not IsOnMobile then
		return
	end
	NAmanage.RewindDestroyMobileButton()
	const state = NAmanage.RewindState()
	const gui = InstanceNew("ScreenGui")
	const button = InstanceNew("TextButton")
	const corner = InstanceNew("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	const aspect = InstanceNew("UIAspectRatioConstraint")

	NAgui.NaProtectUI(gui)
	gui.Name = "NARewindMobile"
	gui.ResetOnSpawn = false

	button.Name = "RewindMainButton"
	button.Parent = gui
	button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	button.BackgroundTransparency = 0.1
	button.Position = UDim2.new(0.8, 0, 0.5, 0)
	button.Size = UDim2.new(0.08, 0, 0.1, 0)
	button.Font = Enum.Font.GothamBold
	button.Text = "REW"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.TextWrapped = true
	button.Active = true
	button.TextScaled = true

	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	aspect.Parent = button
	aspect.AspectRatio = 1

	state.MobileGui = gui
	state.MobileButton = button

	MouseButtonFix(button, function()
		if state.Enabled ~= true then
			return
		end
		NAmanage.RewindSetMobileActive(state.MobileActive ~= true)
	end)

	NAgui.draggerV2(button)
	NAmanage.RewindSyncMobileButton()
end

NAmanage.RewindClearHistory = function()
	const state = NAmanage.RewindState()
	if type(state.History) == "table" then
		table.clear(state.History)
	else
		state.History = {}
	end
end

NAmanage.RewindSetAnimate = function(char, disabled)
	const state = NAmanage.RewindState()
	const animate = char and char:FindFirstChild("Animate")
	if not animate then
		return
	end
	if disabled then
		if state.AnimateOriginalDisabled == nil then
			local ok, value = pcall(function()
				return animate.Disabled
			end)
			state.AnimateOriginalDisabled = ok and value or false
		end
		pcall(function()
			if animate.Disabled ~= true then
				animate.Disabled = true
			end
		end)
		return
	end
	local restoreValue = state.AnimateOriginalDisabled
	state.AnimateOriginalDisabled = nil
	if restoreValue == nil then
		restoreValue = false
	end
	pcall(function()
		if animate.Disabled ~= restoreValue then
			animate.Disabled = restoreValue
		end
	end)
end

NAmanage.RewindStopPlayback = function(char, hum)
	const state = NAmanage.RewindState()
	state.IsRewinding = false
	NAmanage.RewindSetAnimate(char or getChar(), false)
	if hum then
		local ok, tracks = pcall(function()
			return hum:GetPlayingAnimationTracks()
		end)
		if ok and type(tracks) == "table" then
			for _, track in tracks do
				pcall(function()
					track:AdjustSpeed(1)
				end)
				pcall(function()
					track:Stop(0.1)
				end)
			end
		end
	end
end

NAmanage.RewindCaptureAnimations = function(hum)
	const currentAnims = {}
	if not hum then
		return currentAnims
	end
	local ok, tracks = pcall(function()
		return hum:GetPlayingAnimationTracks()
	end)
	if not (ok and type(tracks) == "table") then
		return currentAnims
	end
	for _, track in tracks do
		local weight = 0
		pcall(function()
			weight = tonumber(track.WeightCurrent) or 0
		end)
		if weight > 0 then
			Insert(currentAnims, {
				Track = track;
				Position = track.TimePosition;
				Weight = weight;
			})
		end
	end
	return currentAnims
end

NAmanage.RewindApplySnapshot = function(state, char, root, snapshot)
	if type(snapshot) ~= "table" or typeof(snapshot.CFrame) ~= "CFrame" then
		return
	end
	local currentCF
	local okPivot, pivot = pcall(function()
		return char:GetPivot()
	end)
	if okPivot and typeof(pivot) == "CFrame" then
		currentCF = pivot
	else
		currentCF = root and root.CFrame or snapshot.CFrame
	end
	const targetCF = currentCF:Lerp(snapshot.CFrame, 0.5)
	if NAmanage.UG_pivotModel then
		NAmanage.UG_pivotModel(char, targetCF)
	elseif root then
		pcall(function()
			root.CFrame = targetCF
		end)
	end
	if root then
		pcall(function()
			if root.AssemblyLinearVelocity ~= Vector3.zero then
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end)
		pcall(function()
			if root.AssemblyAngularVelocity ~= Vector3.zero then
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end
	if type(snapshot.Anims) == "table" then
		for _, animData in snapshot.Anims do
			const track = type(animData) == "table" and animData.Track or nil
			if track then
				pcall(function()
					if not track.IsPlaying then
						track:Play(0)
					end
				end)
				pcall(function()
					track.TimePosition = animData.Position or 0
				end)
				pcall(function()
					track:AdjustSpeed(0)
				end)
				pcall(function()
					track:AdjustWeight(animData.Weight or 1)
				end)
			end
		end
	end
end

NAmanage.RewindStep = function()
	const state = NAmanage.RewindState()
	if state.Enabled ~= true then
		NAlib.disconnect("NARewind")
		return
	end

	const char = getChar()
	const root = char and getRoot(char)
	const hum = char and getHum(char)

	if char ~= state.LastCharacter then
		NAmanage.RewindStopPlayback(state.LastCharacter, nil)
		NAmanage.RewindSetMobileActive(false)
		state.LastCharacter = char
		state.IsRewinding = false
		state.AnimateOriginalDisabled = nil
		NAmanage.RewindClearHistory()
	end

	local dead = false
	if hum and hum:IsA("Humanoid") then
		local okHealth, health = pcall(function()
			return hum.Health
		end)
		dead = okHealth and tonumber(health) and health <= 0
	end

	if not (char and root and hum) or dead then
		if state.IsRewinding then
			NAmanage.RewindStopPlayback(char, hum)
		end
		NAmanage.RewindSetMobileActive(false)
		NAmanage.RewindClearHistory()
		return
	end

	const inputActive = NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive()
	local keyDown = state.MobileActive == true
	if not keyDown and not inputActive then
		local okKey, down = pcall(function()
			return __lt.cm("UserInputService", "IsKeyDown", state.Key)
		end)
		keyDown = okKey and down == true
	end

	if keyDown then
		state.IsRewinding = true
		NAmanage.RewindSetAnimate(char, true)
		local foundSnapshot = false
		for i = 1, state.Speed do
			const snapshot = table.remove(state.History, #state.History)
			if not snapshot then
				break
			end
			foundSnapshot = true
			if i == state.Speed or #state.History == 0 then
				NAmanage.RewindApplySnapshot(state, char, root, snapshot)
			end
		end
		if not foundSnapshot and state.MobileActive == true then
			NAmanage.RewindSetMobileActive(false)
			NAmanage.RewindStopPlayback(char, hum)
		end
		return
	end

	if state.IsRewinding then
		NAmanage.RewindStopPlayback(char, hum)
	end

	local cf
	local okPivot, pivot = pcall(function()
		return char:GetPivot()
	end)
	if okPivot and typeof(pivot) == "CFrame" then
		cf = pivot
	else
		cf = root.CFrame
	end

	Insert(state.History, {
		CFrame = cf;
		Anims = NAmanage.RewindCaptureAnimations(hum);
	})

	const maxStored = math.max(1, state.Seconds * 60)
	while #state.History > maxStored do
		table.remove(state.History, 1)
	end
end

NAmanage.RewindStart = function(secondsArg)
	const state = NAmanage.RewindState()
	const seconds = tonumber(secondsArg)
	if seconds then
		state.Seconds = math.max(1, math.min(600, math.floor(seconds)))
	end
	state.Enabled = true
	state.IsRewinding = false
	state.AnimateOriginalDisabled = nil
	state.MobileActive = false
	NAmanage.RewindClearHistory()
	NAlib.reconnect("NARewind", Services.RunService.Heartbeat:Connect(NAmanage.RewindStep))
	if IsOnMobile then
		NAmanage.RewindCreateMobileButton()
		DebugNotif(("Rewind enabled. Tap REW to start or stop rewinding. Capture: %ds. Speed: %dx."):format(state.Seconds, state.Speed), 4, "Rewind")
	else
		NAmanage.RewindDestroyMobileButton()
		DebugNotif(("Rewind enabled. Hold %s to rewind. Capture: %ds. Speed: %dx."):format(state.Key.Name, state.Seconds, state.Speed), 4, "Rewind")
	end
end

NAmanage.RewindStop = function(showNotif)
	const state = NAmanage.RewindState()
	state.Enabled = false
	NAmanage.RewindSetMobileActive(false)
	NAmanage.RewindStopPlayback(getChar(), getHum())
	NAmanage.RewindClearHistory()
	NAmanage.RewindDestroyMobileButton()
	NAlib.disconnect("NARewind")
	if showNotif ~= false then
		DebugNotif("Rewind disabled.", 3, "Rewind")
	end
end

cmd.add({"rewind"}, {"rewind [seconds]", "Enable rewind with hold-R on PC or a draggable mobile button"}, function(secondsArg)
	NAmanage.RewindStart(secondsArg)
end)

cmd.add({"unrewind", "stoprewind"}, {"unrewind (stoprewind)", "Disable rewind and clear its saved frames"}, function()
	NAmanage.RewindStop(true)
end)

cmd.add({"rewindspeed"}, {"rewindspeed <frames>", "Set rewind frames skipped per heartbeat"}, function(speedArg)
	const speed = tonumber(speedArg)
	if not speed then
		DoNotif("Usage: rewindspeed <1-60>", 3, "Rewind")
		return
	end
	const state = NAmanage.RewindState()
	state.Speed = math.max(1, math.min(60, math.floor(speed)))
	DebugNotif(("Rewind speed set to %dx."):format(state.Speed), 3, "Rewind")
end, true)

cmd.add({"rewindtime", "rewindseconds"}, {"rewindtime <seconds>", "Set how many seconds rewind stores"}, function(secondsArg)
	const seconds = tonumber(secondsArg)
	if not seconds then
		DoNotif("Usage: rewindtime <1-600>", 3, "Rewind")
		return
	end
	const state = NAmanage.RewindState()
	state.Seconds = math.max(1, math.min(600, math.floor(seconds)))
	NAmanage.RewindClearHistory()
	DebugNotif(("Rewind capture set to %d seconds."):format(state.Seconds), 3, "Rewind")
end, true)

NAStuff.WFCP = NAStuff.WFCP or {
	MouseUnlocked = false;
	AccessoriesHidden = false;
	AccessoryOriginals = {};
	RearViewActive = false;
	PrevMouseLock = nil;
	PrevMinZoom = nil;
	PrevMovementMode = nil;
	WMActive = false;
	WMYaw = 0;
	WMPitch = 0;
	WMCurrentZ = -0.1;
	PrevCameraType = nil;
	PrevMouseBehavior = nil;
	PrevMouseIconEnabled = nil;
	LastHead = nil;
	HeadOriginalLTM = nil;
}

NAmanage.WFCPState = function()
	local state = NAStuff.WFCP
	if type(state) ~= "table" then
		state = {}
		NAStuff.WFCP = state
	end
	state.MouseUnlocked = state.MouseUnlocked == true
	state.AccessoriesHidden = state.AccessoriesHidden == true
	state.RearViewActive = state.RearViewActive == true
	state.WMActive = state.WMActive == true
	state.WMYaw = tonumber(state.WMYaw) or 0
	state.WMPitch = tonumber(state.WMPitch) or 0
	state.WMCurrentZ = tonumber(state.WMCurrentZ) or -0.1
	if type(state.AccessoryOriginals) ~= "table" then
		state.AccessoryOriginals = {}
	end
	if NAmanage.ensureWeakKeyTable then
		state.AccessoryOriginals = NAmanage.ensureWeakKeyTable(state.AccessoryOriginals)
	end
	return state
end

NAmanage.WFCPLocalPlayer = function()
	return LocalPlayer or Player or (Services.Players and Services.Players.LocalPlayer) or nil
end

NAmanage.WFCPGetCamera = function()
	return Services.Workspace and Services.Workspace.CurrentCamera or camera
end

NAmanage.WFCPSafeSet = function(inst, prop, value)
	if typeof(inst) ~= "Instance" then
		return false
	end
	local okCurrent, current = pcall(function()
		return inst[prop]
	end)
	if okCurrent and current == value then
		return true
	end
	const ok = pcall(function()
		inst[prop] = value
	end)
	return ok == true
end

NAmanage.WFCPSetMouseBehavior = function(value)
	if not Services.UserInputService then
		return false
	end
	local okCurrent, current = pcall(function()
		return Services.UserInputService.MouseBehavior
	end)
	if okCurrent and current == value then
		return true
	end
	const ok = pcall(function()
		Services.UserInputService.MouseBehavior = value
	end)
	return ok == true
end

NAmanage.WFCPForEachAccessoryPart = function(char, callback)
	if typeof(char) ~= "Instance" or type(callback) ~= "function" then
		return
	end
	for _, item in char:GetChildren() do
		if item:IsA("Accessory") then
			const handle = item:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				callback(handle)
			end
			for _, desc in NAmanage.QueryDescendants(item, "BasePart") do
				if desc ~= handle then
					callback(desc)
				end
			end
		end
	end
end

NAmanage.WFCPSetAccessoryPartHidden = function(part, hidden)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return
	end

	const state = NAmanage.WFCPState()
	const originals = state.AccessoryOriginals

	if hidden then
		if originals[part] == nil then
			local okLTM, ltm = pcall(function()
				return part.LocalTransparencyModifier
			end)
			local okTransparency, transparency = pcall(function()
				return part.Transparency
			end)
			originals[part] = {
				LocalTransparencyModifier = okLTM and ltm or 0;
				Transparency = okTransparency and transparency or 0;
			}
		end
		NAmanage.WFCPSafeSet(part, "LocalTransparencyModifier", 1)
		NAmanage.WFCPSafeSet(part, "Transparency", 1)
		return
	end

	const rec = originals[part]
	if type(rec) == "table" then
		NAmanage.WFCPSafeSet(part, "LocalTransparencyModifier", rec.LocalTransparencyModifier or 0)
		NAmanage.WFCPSafeSet(part, "Transparency", rec.Transparency or 0)
		originals[part] = nil
	else
		NAmanage.WFCPSafeSet(part, "LocalTransparencyModifier", 0)
	end
end

NAmanage.WFCPAccessoriesStep = function()
	const state = NAmanage.WFCPState()
	if state.AccessoriesHidden ~= true then
		NAlib.disconnect("NAWFCPAccessories")
		return
	end
	const char = getChar()
	if not char then
		return
	end
	NAmanage.WFCPForEachAccessoryPart(char, function(part)
		NAmanage.WFCPSetAccessoryPartHidden(part, true)
	end)
end

NAmanage.WFCPRestoreAccessories = function()
	const state = NAmanage.WFCPState()
	const originals = state.AccessoryOriginals
	if type(originals) ~= "table" then
		return
	end
	for part in originals do
		NAmanage.WFCPSetAccessoryPartHidden(part, false)
	end
end

NAmanage.WFCPSetAccessoriesHidden = function(value, showNotif)
	const state = NAmanage.WFCPState()
	if value == nil then
		value = not state.AccessoriesHidden
	end
	state.AccessoriesHidden = value == true

	if state.AccessoriesHidden then
		NAlib.reconnect("NAWFCPAccessories", Services.RunService.RenderStepped:Connect(NAmanage.WFCPAccessoriesStep))
		NAmanage.WFCPAccessoriesStep()
		if showNotif ~= false then
			DebugNotif("Accessory hiding enabled.", 3, "WFCP")
		end
	else
		NAlib.disconnect("NAWFCPAccessories")
		NAmanage.WFCPRestoreAccessories()
		if showNotif ~= false then
			DebugNotif("Accessory hiding disabled.", 3, "WFCP")
		end
	end
end

NAmanage.WFCPCameraFlip180 = function()
	const cam = NAmanage.WFCPGetCamera()
	if not cam then
		return false
	end

	const ok = pcall(function()
		const focusCF = cam.Focus
		const focus = focusCF and focusCF.Position or (cam.CFrame.Position + cam.CFrame.LookVector)
		local offset = cam.CFrame.Position - focus
		if offset.Magnitude < 0.01 then
			offset = -cam.CFrame.LookVector * 12
		end
		const rotatedOffset = CFrame.Angles(0, math.pi, 0) * offset
		cam.CFrame = CFrame.lookAt(focus + rotatedOffset, focus)
	end)

	return ok == true
end

NAmanage.WFCPStopRearView = function(showNotif, flipCameraBack)
	const state = NAmanage.WFCPState()
	const wasActive = state.RearViewActive == true
	state.RearViewActive = false
	NAlib.disconnect("NAWFCPRearView")

	const playerObj = NAmanage.WFCPLocalPlayer()
	if playerObj then
		if state.PrevMouseLock ~= nil then
			pcall(function()
				playerObj.DevEnableMouseLock = state.PrevMouseLock
			end)
		end
		if state.PrevMinZoom ~= nil then
			pcall(function()
				playerObj.CameraMinZoomDistance = state.PrevMinZoom
			end)
		end
		pcall(function()
			playerObj.DevComputerMovementMode = state.PrevMovementMode or Enum.DevComputerMovementMode.UserChoice
		end)
	end

	state.PrevMouseLock = nil
	state.PrevMinZoom = nil
	state.PrevMovementMode = nil

	if wasActive and flipCameraBack ~= false then
		NAmanage.WFCPCameraFlip180()
	end

	if showNotif ~= false and wasActive then
		DebugNotif("Rear view disabled.", 3, "WFCP")
	end
end

NAmanage.WFCPRearViewStep = function()
	const state = NAmanage.WFCPState()
	if state.RearViewActive ~= true then
		NAmanage.WFCPStopRearView(false, false)
		return
	end

	const playerObj = NAmanage.WFCPLocalPlayer()
	const char = getChar()
	const hum = char and getHum(char)
	const root = char and getRoot(char)

	if not (playerObj and char and hum and root) then
		NAmanage.WFCPStopRearView(false, false)
		return
	end

	if hum:IsA("Humanoid") then
		local okHealth, health = pcall(function()
			return hum.Health
		end)
		if okHealth and tonumber(health) and health <= 0 then
			NAmanage.WFCPStopRearView(false, false)
			return
		end
	end

	pcall(function()
		playerObj.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
	end)

	local moveVec = Vector3.zero
	const inputActive = NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive()
	if not inputActive and Services.UserInputService then
		if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec += Vector3.new(0, 0, -1) end
		if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += Vector3.new(0, 0, 1) end
		if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += Vector3.new(-1, 0, 0) end
		if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec += Vector3.new(1, 0, 0) end
	end

	pcall(function()
		hum:Move(moveVec, true)
	end)
end

NAmanage.WFCPStartRearView = function()
	const state = NAmanage.WFCPState()
	if state.WMActive then
		NAmanage.WFCPStopWorldModelFP(false)
	end

	const playerObj = NAmanage.WFCPLocalPlayer()
	if not playerObj then
		DoNotif("Unable to get local player.", 3, "WFCP")
		return
	end

	state.PrevMouseLock = playerObj.DevEnableMouseLock
	state.PrevMinZoom = playerObj.CameraMinZoomDistance
	state.PrevMovementMode = playerObj.DevComputerMovementMode
	state.RearViewActive = true

	pcall(function()
		playerObj.DevEnableMouseLock = false
	end)
	pcall(function()
		playerObj.CameraMinZoomDistance = 5
	end)

	NAmanage.WFCPCameraFlip180()
	NAlib.reconnect("NAWFCPRearView", Services.RunService.RenderStepped:Connect(NAmanage.WFCPRearViewStep))
	DebugNotif("Rear view enabled. Run backview again to disable.", 4, "WFCP")
end

NAmanage.WFCPRestoreWorldModelHead = function()
	const state = NAmanage.WFCPState()
	const head = state.LastHead
	if typeof(head) == "Instance" and head:IsA("BasePart") then
		local restore = state.HeadOriginalLTM
		if restore == nil then
			restore = 0
		end
		NAmanage.WFCPSafeSet(head, "LocalTransparencyModifier", restore)
	end
	state.LastHead = nil
	state.HeadOriginalLTM = nil
end

NAmanage.WFCPStopWorldModelFP = function(showNotif)
	const state = NAmanage.WFCPState()
	const wasActive = state.WMActive == true
	state.WMActive = false
	state.MouseUnlocked = false
	NAlib.disconnect("NAWFCPWorldModelFP")

	const cam = NAmanage.WFCPGetCamera()
	if cam then
		NAmanage.WFCPSafeSet(cam, "CameraType", state.PrevCameraType or Enum.CameraType.Custom)
	end
	if Services.UserInputService then
		NAmanage.WFCPSetMouseBehavior(state.PrevMouseBehavior or Enum.MouseBehavior.Default)
		if state.PrevMouseIconEnabled ~= nil then
			local okIcon, currentIcon = pcall(function()
				return Services.UserInputService.MouseIconEnabled
			end)
			if (not okIcon) or currentIcon ~= state.PrevMouseIconEnabled then
				pcall(function()
					Services.UserInputService.MouseIconEnabled = state.PrevMouseIconEnabled
				end)
			end
		end
	end

	NAmanage.WFCPRestoreWorldModelHead()

	state.PrevCameraType = nil
	state.PrevMouseBehavior = nil
	state.PrevMouseIconEnabled = nil
	state.WMCurrentZ = -0.1

	if showNotif ~= false and wasActive then
		DebugNotif("World model first person disabled.", 3, "WFCP")
	end
end

NAmanage.WFCPWorldModelFPStep = function()
	const state = NAmanage.WFCPState()
	const cam = NAmanage.WFCPGetCamera()

	if state.WMActive ~= true then
		NAmanage.WFCPStopWorldModelFP(false)
		return
	end

	const char = getChar()
	const root = char and getRoot(char)
	const head = char and getHead(char)

	if not (cam and char and root and head) then
		if cam then
			NAmanage.WFCPSafeSet(cam, "CameraType", Enum.CameraType.Custom)
		end
		NAmanage.WFCPSetMouseBehavior(Enum.MouseBehavior.Default)
		return
	end

	if cam.CameraType ~= Enum.CameraType.Scriptable then
		NAmanage.WFCPSafeSet(cam, "CameraType", Enum.CameraType.Scriptable)
	end

	const inputActive = NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive()
	const allowLook = not inputActive

	if Services.UserInputService then
		local rightMouseDown = false
		pcall(function()
			rightMouseDown = Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		end)

		if state.MouseUnlocked and not rightMouseDown then
			NAmanage.WFCPSetMouseBehavior(Enum.MouseBehavior.Default)
		else
			NAmanage.WFCPSetMouseBehavior(Enum.MouseBehavior.LockCenter)
			if allowLook then
				const delta = Services.UserInputService:GetMouseDelta()
				state.WMYaw -= delta.X * 0.008
				state.WMPitch = math.clamp(state.WMPitch - (delta.Y * 0.008), -1.48, 1.48)
			end
		end
	end

	const targetRootCF = CFrame.new(root.Position) * CFrame.Angles(0, state.WMYaw, 0)
	if NAmanage.UG_setRootCFrame then
		NAmanage.UG_setRootCFrame(root, targetRootCF)
	else
		NAmanage.WFCPSafeSet(root, "CFrame", targetRootCF)
	end

	local _, _, roll = (head.CFrame - head.Position):ToEulerAnglesYXZ()
	if math.abs(state.WMPitch) > 1.4 then
		roll *= (1.5 - math.abs(state.WMPitch)) * 10
	end

	const pitchFactor = math.clamp(-state.WMPitch, 0, 1.48) / 1.48
	const targetZ = -0.1 - (pitchFactor * 0.25)
	state.WMCurrentZ += (targetZ - state.WMCurrentZ) * 0.1

	const finalRot = CFrame.Angles(0, state.WMYaw, 0) * CFrame.Angles(state.WMPitch, 0, roll)
	NAmanage.WFCPSafeSet(cam, "CFrame", CFrame.new(head.Position) * finalRot * CFrame.new(0, 0.25, state.WMCurrentZ))

	if state.LastHead ~= head then
		NAmanage.WFCPRestoreWorldModelHead()
		state.LastHead = head
		local okLTM, ltm = pcall(function()
			return head.LocalTransparencyModifier
		end)
		state.HeadOriginalLTM = okLTM and ltm or 0
	end
	NAmanage.WFCPSafeSet(head, "LocalTransparencyModifier", 1)
end

NAmanage.WFCPStartWorldModelFP = function()
	const state = NAmanage.WFCPState()
	if state.RearViewActive then
		NAmanage.WFCPStopRearView(false, false)
	end

	const cam = NAmanage.WFCPGetCamera()
	if not cam then
		DoNotif("Unable to get current camera.", 3, "WFCP")
		return
	end

	const char = getChar()
	const root = char and getRoot(char)
	if root then
		local _, yaw = root.CFrame:ToOrientation()
		state.WMYaw = yaw or 0
	else
		state.WMYaw = 0
	end
	state.WMPitch = 0
	state.WMCurrentZ = -0.1
	state.WMActive = true
	state.MouseUnlocked = false

	state.PrevCameraType = cam.CameraType
	if Services.UserInputService then
		state.PrevMouseBehavior = Services.UserInputService.MouseBehavior
		state.PrevMouseIconEnabled = Services.UserInputService.MouseIconEnabled
	end

	NAlib.reconnect("NAWFCPWorldModelFP", Services.RunService.RenderStepped:Connect(NAmanage.WFCPWorldModelFPStep))
	NAmanage.WFCPWorldModelFPStep()
	DebugNotif("World model first person enabled. Use freemouse to toggle cursor unlock.", 4, "WFCP")
end

NAmanage.WFCPFrontViewReset = function()
	const state = NAmanage.WFCPState()
	state.MouseUnlocked = false
	NAmanage.WFCPStopWorldModelFP(false)
	NAmanage.WFCPStopRearView(false, false)

	const playerObj = NAmanage.WFCPLocalPlayer()
	if playerObj then
		pcall(function()
			playerObj.DevComputerMovementMode = Enum.DevComputerMovementMode.UserChoice
		end)
		pcall(function()
			playerObj.DevEnableMouseLock = true
		end)
		pcall(function()
			playerObj.CameraMinZoomDistance = 0.5
		end)
	end

	const cam = NAmanage.WFCPGetCamera()
	if cam then
		NAmanage.WFCPSafeSet(cam, "CameraType", Enum.CameraType.Custom)
	end
	NAmanage.WFCPSetMouseBehavior(Enum.MouseBehavior.Default)

	const char = getChar()
	const root = char and getRoot(char)
	if cam and root then
		const lookPos = root.CFrame:PointToWorldSpace(Vector3.new(0, 2, -15))
		const camPos = root.CFrame:PointToWorldSpace(Vector3.new(0, 2, 12))
		NAmanage.WFCPSafeSet(cam, "CFrame", CFrame.new(camPos, lookPos))
	end

	DebugNotif("Camera reset.", 3, "WFCP")
end

cmd.add({"freemouse", "togglefreemouse", "wfcpfreemouse"}, {"freemouse", "Toggle cursor unlock while world model first person is active"}, function()
	const state = NAmanage.WFCPState()
	state.MouseUnlocked = not state.MouseUnlocked
	if state.MouseUnlocked then
		NAmanage.WFCPSetMouseBehavior(Enum.MouseBehavior.Default)
	end
	DebugNotif("WFCP free mouse "..(state.MouseUnlocked and "enabled." or "disabled."), 3, "WFCP")
end)

cmd.add({"hideacc", "accessories"}, {"hideacc (accessories)", "Hide or restore local accessory parts"}, function()
	const state = NAmanage.WFCPState()
	NAmanage.WFCPSetAccessoriesHidden(not state.AccessoriesHidden, true)
end)

cmd.add({"backview", "rearview", "rear", "f5"}, {"backview (rearview, rear, f5)", "Flip the camera behind you and invert movement controls"}, function()
	const state = NAmanage.WFCPState()
	if state.RearViewActive then
		NAmanage.WFCPStopRearView(true, true)
	else
		NAmanage.WFCPStartRearView()
	end
end)

cmd.add({"worldmodelfp", "wfcpfp", "realfirstperson", "fpmodel"}, {"worldmodelfp (wfcpfp, realfirstperson, fpmodel)", "WFCP world-model first person camera"}, function()
	const state = NAmanage.WFCPState()
	if state.WMActive then
		NAmanage.WFCPStopWorldModelFP(true)
	else
		NAmanage.WFCPStartWorldModelFP()
	end
end)

cmd.add({"frontview", "resetcam"}, {"frontview (resetcam)", "Reset WFCP camera state and return to a normal front view"}, function()
	NAmanage.WFCPFrontViewReset()
end)

cmd.add({"deletevelocity", "dv", "removevelocity", "removeforces"}, {"deletevelocity (dv, removevelocity, removeforces)", "removes any velocity/force instanceson your character"}, function()
	for _, className in { "BodyVelocity", "BodyGyro", "RocketPropulsion", "BodyThrust", "BodyAngularVelocity", "AngularVelocity", "BodyForce", "VectorForce", "LineForce" } do
		for _, vel in NAmanage.QueryDescendants(LocalPlayer.Character, className) do
			vel:Destroy()
		end
	end
end)

--Mobile Commands for the screen
if IsOnMobile then
	originalIO.setScreenOrientation=function(target)
		if target == "Default" then
			PlrGui.ScreenOrientation = Services.StarterGui.ScreenOrientation
			return "Default"
		end
		if typeof(target) == "EnumItem" then
			PlrGui.ScreenOrientation = target
			return target.Name
		end
	end

	originalIO.screenOrientationButtons=function()
		const buttons = {}
		Insert(buttons, {
			Text = "Default",
			Callback = function()
				originalIO.setScreenOrientation("Default")
			end
		})
		for _, so in Enum.ScreenOrientation:GetEnumItems() do
			Insert(buttons, {
				Text = so.Name,
				Callback = function()
					originalIO.setScreenOrientation(so)
				end
			})
		end
		return buttons
	end

	originalIO.screenOrientationCommand=function(...)
		const args = {...}
		const target = args[1]
		const buttons = originalIO.screenOrientationButtons()
		if target and target ~= "" then
			const q = Lower(tostring(target))
			local hit
			const hits = {}
			for _, btn in buttons do
				if Lower(btn.Text) == q then
					hit = btn
					break
				end
				if Find(Lower(btn.Text), q, 1, true) then
					Insert(hits, btn)
				end
			end
			if not hit and #hits == 1 then
				hit = hits[1]
			end
			if hit then
				hit.Callback()
				DebugNotif("ScreenOrientation set to "..hit.Text, 3)
			elseif #hits > 1 then
				const names = {}
				for i = 1, #hits do
					names[i] = hits[i].Text
				end
				DebugNotif("Multiple ScreenOrientation matches: "..Concat(names, ", "), 3)
			else
				DebugNotif("No matching ScreenOrientation for: "..tostring(target), 3)
			end
		else
			Window({
				Title = "Screen Orientation Options",
				Buttons = buttons
			})
		end
	end

	cmd.add({"screenorientation","screenorient","scrorientation","scrorient","screenrotation","scrrotation","scrrot","so"},{"screenorientation [type]","Manage ScreenOrientation"},originalIO.screenOrientationCommand)

	cmd.add({"sensorrotationscreen","sensorscreen","senscreen"},{"sensorrotationscreen","Changes ScreenOrientation to Sensor"},function()
		originalIO.screenOrientationCommand("Sensor")
	end)

	cmd.add({"landscaperotationscreen","landscapescreen","landscreen"},{"landscaperotationscreen","Changes ScreenOrientation to Landscape Sensor"},function()
		originalIO.screenOrientationCommand("LandscapeSensor")
	end)

	cmd.add({"portraitrotationscreen","portraitscreen","portscreen"},{"portraitrotationscreen","Changes ScreenOrientation to Portrait"},function()
		originalIO.screenOrientationCommand("Portrait")
	end)

	cmd.add({"defaultrotationscreen","defaultrotaionscreen","defaultscreen","defscreen"},{"defaultrotationscreen","Changes ScreenOrientation to Default"},function()
		originalIO.screenOrientationCommand("Default")
	end)
end

NAmanage.NACommandCount=function()
	local total = 0
	for _ in cmds.Commands do
		total += 1
	end

	local pluginTotal, naPluginCount, iyPluginCount = 0, 0, 0
	const pluginRecords = NAmanage and NAmanage._pluginCommandRecords
	if type(pluginRecords) == "table" then
		const seenData = {}
		for pluginKey, record in pluginRecords do
			const aliases = type(record) == "table" and record.aliases
			if type(aliases) == "table" then
				for alias, data in aliases do
					if data and not seenData[data] and cmds.Commands[alias] == data then
						seenData[data] = true
						pluginTotal += 1
						if type(pluginKey) == "string" then
							if pluginKey:match("%.na$") then
								naPluginCount += 1
							elseif pluginKey:match("%.iy$") then
								iyPluginCount += 1
							end
						end
					end
				end
			end
		end
	end

	local core = total - pluginTotal
	if core < 0 then
		core = total
	end

	return total, core, naPluginCount, iyPluginCount, pluginTotal
end

cmd.add({"commandcount","cc"},{"commandcount (cc)","Counts how many commands NA has"},function()
	local total, core, naPlugins, iyPlugins, pluginTotal = NAmanage.NACommandCount()
	local msg = adminName.." currently has "..core.." core command"..((core == 1) and "" or "s")
	if pluginTotal > 0 then
		const pluginParts = {}
		if naPlugins > 0 then
			Insert(pluginParts, naPlugins.." from .na plugins")
		end
		if iyPlugins > 0 then
			Insert(pluginParts, iyPlugins.." from .iy plugins")
		end
		msg = msg.." + "..pluginTotal.." plugin command"..((pluginTotal == 1) and "" or "s")
		if #pluginParts > 0 then
			msg = msg.." ("..Concat(pluginParts, ", ")..")"
		end
		msg = msg.." = "..total.." total"
	end
	DoNotif(msg)
end)

cmd.add({"flyfling","ff"}, {"flyfling (ff)", "makes you fly and fling"}, function()
	cmd.run({"unwalkfling"})
	cmd.run({"unvfly", ''})
	cmd.run({"walkfling"})
	cmd.run({"vfly"})
end)

cmd.add({"unflyfling","unff"}, {"unflyfling (unff)", "stops fly and fling"}, function()
	cmd.run({"unwalkfling"})
	cmd.run({"unvfly", ''})
end)

hiddenfling = false
hiddenflingspeed = hiddenflingspeed or 10000

NAmanage.ParseFlingSpeed = NAmanage.ParseFlingSpeed or function(value)
	local speed = tonumber(value)
	if not flingManager.IsFiniteNumber(speed) or speed <= 0 then
		speed = 10000
	end
	return math.clamp(speed, 1, 1000000000)
end

NAmanage.WalkFlingBurst = function(root, speed)
	if not (root and root.Parent) then return end
	speed = NAmanage.ParseFlingSpeed(speed)
	const movel = 0.1
	local ok, v = pcall(function()
		return root.Velocity
	end)
	if not ok or typeof(v) ~= "Vector3" then
		v = select(1, flingManager.GetPartVelocity(root))
	end
	pcall(function()
		root.Velocity = v * speed + Vector3.new(0, speed, 0)
	end)

	Services.RunService.RenderStepped:Wait()
	if root and root.Parent then
		pcall(function()
			root.Velocity = v
		end)
	end

	Services.RunService.Stepped:Wait()
	if root and root.Parent then
		pcall(function()
			root.Velocity = v + Vector3.new(0, movel, 0)
		end)
	end
end

cmd.add({"walkfling","wfling","wf"},{"walkfling (wfling,wf) <speed>","probably the best fling lol"},function(speed)
	hiddenflingspeed = NAmanage.ParseFlingSpeed(speed)
	if hiddenfling then
		DebugNotif("Walkfling speed: "..tostring(hiddenflingspeed),2)
		return
	end

	DebugNotif("Walkfling enabled",2)
	hiddenfling = true

	NAlib.disconnect("walkflinger")
	NAlib.connect("walkflinger",Services.RunService.Heartbeat:Connect(function()
		if not hiddenfling then return end

		const lp = Services.Players.LocalPlayer
		if not lp then return end

		const m = getChar()
		const r = m and getRoot(m)
		if r then
			NAmanage.WalkFlingBurst(r, hiddenflingspeed)
		end
	end))
end)

cmd.add({"unwalkfling","unwfling","unwf"},{"unwalkfling (unwfling,unwf)","stop the walkfling command"},function()
	if not hiddenfling then return end

	DebugNotif("Walkfling disabled",2)
	hiddenfling = false

	NAlib.disconnect("walkflinger")
end)

touchfling = false
NAStuff.TouchFling = NAStuff.TouchFling or {
	busy = false;
	range = 3.35;
	speed = 10000;
	dirs = {};
	origins = {};
	ignore = {};
	params = nil;
}

NAmanage.TouchFlingFilterType = NAmanage.TouchFlingFilterType or function()
	local ok, item = pcall(function()
		return Enum.RaycastFilterType.Exclude
	end)
	if ok and item then
		return item
	end
	return Enum.RaycastFilterType.Blacklist
end

NAmanage.TouchFlingPlayer = NAmanage.TouchFlingPlayer or function(model)
	if not (model and model:IsA("Model")) then
		return nil
	end
	local ok, plr = pcall(function()
		return __lt.cm("Players", "GetPlayerFromCharacter", model)
	end)
	if ok and plr then
		return plr
	end
	return nil
end

NAmanage.TouchFlingHum = NAmanage.TouchFlingHum or function(model)
	const plr = NAmanage.TouchFlingPlayer(model)
	local hum
	if plr then
		hum = getPlrHum(plr)
	else
		hum = getHum(model)
	end
	if not (hum and hum:IsA("Humanoid") and hum.Parent and hum.Health > 0) then
		return nil, plr
	end
	return hum, plr
end

NAmanage.TouchFlingParts = NAmanage.TouchFlingParts or function(model, hum)
	if not (model and model:IsA("Model")) then
		return nil, nil, nil
	end
	const root = (hum and hum.RootPart) or getRoot(model)
	const torso = getTorso(model)
	const head = getHead(model)
	return root, torso, head
end

NAmanage.TouchFlingModel = NAmanage.TouchFlingModel or function(part)
	const RawWorkspace = __lt.gs("Workspace")
	local cur = part
	while cur and cur ~= RawWorkspace do
		if cur:IsA("Model") then
			const hum = NAmanage.TouchFlingHum(cur)
			local root, torso, head = NAmanage.TouchFlingParts(cur, hum)
			if hum and (root or torso or head) then
				return cur
			end
		end
		cur = cur.Parent
	end
	return nil
end

NAmanage.TouchFlingTarget = NAmanage.TouchFlingTarget or function(model, char)
	if not (model and model:IsA("Model") and model.Parent) then
		return false
	end
	if char and (model == char or model:IsDescendantOf(char) or char:IsDescendantOf(model)) then
		return false
	end
	local hum, plr = NAmanage.TouchFlingHum(model)
	if not hum then
		return false
	end
	local root, torso, head = NAmanage.TouchFlingParts(model, hum)
	if not (root or torso or head) then
		return false
	end
	if plr then
		return plr ~= Services.Players.LocalPlayer
	end
	if CheckIfNPC then
		local ok, isNpc = pcall(CheckIfNPC, model)
		if ok and isNpc then
			return true
		end
	end
	return true
end

NAmanage.TouchFlingDetect = NAmanage.TouchFlingDetect or function(char, root, hum)
	if not (char and root and root.Parent and Services.Workspace and Services.Workspace.Raycast) then
		return nil
	end

	const st = NAStuff.TouchFling
	st.params = st.params or RaycastParams.new()
	st.params.FilterType = NAmanage.TouchFlingFilterType()
	st.params.IgnoreWater = true
	st.ignore[1] = char
	for i = 2, #st.ignore do
		st.ignore[i] = nil
	end
	st.params.FilterDescendantsInstances = st.ignore

	const cf = root.CFrame
	const dirs = st.dirs
	dirs[1] = cf.LookVector
	dirs[2] = -cf.LookVector
	dirs[3] = cf.RightVector
	dirs[4] = -cf.RightVector
	dirs[5] = Vector3.new(0, 1, 0)
	dirs[6] = Vector3.new(0, -1, 0)
	dirs[7] = (cf.LookVector + cf.RightVector).Unit
	dirs[8] = (cf.LookVector - cf.RightVector).Unit
	dirs[9] = (-cf.LookVector + cf.RightVector).Unit
	dirs[10] = (-cf.LookVector - cf.RightVector).Unit
	local dCount = 10
	const mv = hum and hum.MoveDirection or Vector3.zero
	if mv.Magnitude > 0.05 then
		dCount += 1
		dirs[dCount] = mv.Unit
	end

	const origins = st.origins
	local oCount = 1
	origins[1] = root.Position
	const torso = getTorso(char)
	if torso and torso ~= root then
		oCount += 1
		origins[oCount] = torso.Position
	end
	const head = getHead(char)
	if head and head ~= root and head ~= torso then
		oCount += 1
		origins[oCount] = head.Position
	end
	for i = oCount + 1, #origins do
		origins[i] = nil
	end

	const dist = tonumber(st.range) or 3.35
	for o = 1, oCount do
		const origin = origins[o]
		for d = 1, dCount do
			const dir = dirs[d]
			if dir and dir.Magnitude > 0 then
				local ok, result = pcall(function()
					return Services.Workspace:Raycast(origin, dir * dist, st.params)
				end)
				const inst = ok and result and result.Instance or nil
				const model = inst and NAmanage.TouchFlingModel(inst) or nil
				if NAmanage.TouchFlingTarget(model, char) then
					st.last = model
					return model
				end
			end
		end
	end

	st.last = nil
	return nil
end

NAmanage.TouchFlingBurst = function(root)
	const st = NAStuff.TouchFling
	if st.busy or not (root and root.Parent) then
		return
	end
	st.busy = true
	NAmanage.WalkFlingBurst(root, st.speed)
	st.busy = false
end

cmd.add({"touchfling","tfling","tf"},{"touchfling (tfling,tf) <speed>","walkfling only when touching a player or NPC"},function(speed)
	NAStuff.TouchFling.speed = NAmanage.ParseFlingSpeed(speed)
	if touchfling then
		DebugNotif("Touchfling speed: "..tostring(NAStuff.TouchFling.speed),2)
		return
	end
	if hiddenfling then
		cmd.run({"unwalkfling"})
	end

	DebugNotif("Touchfling enabled",2)
	touchfling = true

	NAlib.disconnect("touchflinger")
	NAlib.connect("touchflinger",Services.RunService.Heartbeat:Connect(function()
		if not touchfling then return end
		const ch = getChar()
		const h = getPlrHum(Services.Players.LocalPlayer) or (ch and getHum(ch))
		const r = ch and ((h and h.RootPart) or getRoot(ch))
		if r and h and NAmanage.TouchFlingDetect(ch, r, h) then
			NAmanage.TouchFlingBurst(r)
		end
	end))
end)

cmd.add({"untouchfling","untfling","untf"},{"untouchfling (untfling,untf)","stop the touchfling command"},function()
	if not touchfling then return end

	DebugNotif("Touchfling disabled",2)
	touchfling = false
	if NAStuff.TouchFling then
		NAStuff.TouchFling.busy = false
		NAStuff.TouchFling.last = nil
	end

	NAlib.disconnect("touchflinger")
end)

NAmanage.IsStartupTeleportUnsafe = NAmanage.IsStartupTeleportUnsafe or function()
	const st = NAgui and NAgui.SettingsBuildState
	if NAStuff.SettingsBuildRunning == true or NAStuff._loadingFinalizePending == true then
		return true
	end
	if type(st) == "table" and st.building == true then
		return true
	end
	if NAAssetsLoading and NAAssetsLoading._finalized ~= true then
		return true
	end
	return false
end

cmd.add({"rjre","rejoinrefresh"},{"rjre (rejoinrefresh)","Rejoins and teleports you to your previous position"},function()
	if not DONE then
		DONE = true

		const ch = getChar()
		const hrp = ch and getRoot(ch) or getRoot(LocalPlayer)
		const keepCF = hrp and (NAmanage.UG_clientCFrame(hrp) or hrp.CFrame) or nil
		if keepCF then
			const tpScript = Format([[
local s,err = pcall(function()
	repeat Wait() until game:IsLoaded()
	local function naPrivateRoot()
		local env = (getgenv and getgenv()) or _G or {}
		local dbg = rawget(env, "debug") or debug
		local registry
		if type(getreg) == "function" then
			pcall(function()
				registry = getreg()
			end)
		end
		if type(registry) ~= "table" and type(dbg) == "table" and type(dbg.getregistry) == "function" then
			pcall(function()
				registry = dbg.getregistry()
			end)
		end
		if type(registry) ~= "table" then
			registry = env
		end
		local root = type(registry) == "table" and rawget(registry, "__nameless_admin_private") or nil
		return type(root) == "table" and root or nil
	end
	local function resolveService(name)
		local svc = game:FindService(name)
		if svc then
			return svc
		end
		local okNew, newSvc = pcall(Instance.new, name)
		if okNew and newSvc then
			return newSvc
		end
	end
	local plrs
	if type(cloneref) == "function" then
		local okRef, ref = pcall(function()
			return cloneref(resolveService("Players"))
		end)
		if okRef and ref then
			plrs = ref
		end
	end
	plrs = plrs or resolveService("Players")
	if not plrs then return end
	local lp = plrs.LocalPlayer
	if not lp then return end

	local gb
	local ok,env = pcall(function()
		local root = naPrivateRoot()
		local scope = root and root.testing
		if type(scope) == "table" then
			return scope.runtime or scope
		end
		return getgenv and getgenv() or _G
	end)
	if ok and env then
		gb = rawget(env,"NA_GRAB_BODY")
	end

	local rec, mdl
	if gb and gb.ensure then
		rec, mdl = gb.ensure(lp)
	end

	local char = mdl or lp.Character or lp.CharacterAdded:Wait()
	if not char then return end

	local root

	if gb and gb.ensure then
		rec, mdl = gb.ensure(char)
		if rec then
			root = rec.root
			if not root and gb.firstPart and mdl then
				root = gb.firstPart(mdl)
			end
		end
	end

	if not root then
		local t0 = tick()
		repeat
			root = char:FindFirstChild("HumanoidRootPart")
			if not root then
				for _,d in char:QueryDescendants("BasePart") do
					root = d
					break
				end
			end
			if root then break end
			Wait(0.1)
		until tick() - t0 > 10
	end

	if not root then return end

	local targetPos = Vector3.new(%s)
	local targetCFrame = CFrame.new(%s)

	local t1 = tick()
	repeat
		root.CFrame = targetCFrame
		Wait(0.1)
	until (root.Position - targetPos).Magnitude < 10 or (tick() - t1 > 5)
end)
]], tostring(keepCF.Position), tostring(keepCF))

			opt.queueteleport(tpScript)
		end

		NAStuff.RjreWaitingForTeleport = true
		cmd.run({"rj"})
	end
end)

cmd.add({"cancelteleport","canceltp"},{"cancelteleport","Cancel an in-progress teleport"},function()
	local ok,err=pcall(function()
		__lt.cm("TeleportService", "TeleportCancel")
	end)
	if ok then
		DoNotif("Cancelled pending teleports.",2)
	else
		DoNotif("Failed to cancel teleport: "..tostring(err),3)
	end
end)

cmd.add({"cancelteleportloop","canceltploop","loopcancelteleport","loopcanceltp"},{"cancelteleportloop [interval]","Repeatedly cancels in-progress teleport"},function(interval)
	local tickRate = tonumber(interval)
	if not tickRate then
		tickRate = 0
	end
	tickRate = math.clamp(tickRate, 0, 2)

	NAlib.disconnect("cancelteleport_loop")
	local elapsed = tickRate
	NAlib.connect("cancelteleport_loop", Services.RunService.Heartbeat:Connect(function(dt)
		elapsed += (tonumber(dt) or 0)
		if elapsed < tickRate then
			return
		end
		elapsed = 0
		pcall(function()
			__lt.cm("TeleportService", "TeleportCancel")
		end)
	end))

	DoNotif("CancelTeleport loop enabled ("..tostring(tickRate).."s interval).",2)
end,true)

cmd.add({"uncancelteleportloop","uncanceltploop","unloopcancelteleport","unloopcanceltp"},{"uncancelteleportloop","Disable cancelteleport loop"},function()
	if NAlib.isConnected("cancelteleport_loop") then
		NAlib.disconnect("cancelteleport_loop")
		DoNotif("CancelTeleport loop disabled.",2)
	else
		DoNotif("CancelTeleport loop is already disabled.",2)
	end
end)

cmd.add({"rejoin","rj"},{"rejoin (rj)","Rejoin the game"},function()
	const plrs=Services.Players
	const tp=Services.TeleportService
	const lp=plrs and plrs.LocalPlayer
	const nowTick = tick()
	if not (plrs and tp and lp) then
		if NAStuff.RjreWaitingForTeleport == true then
			NAStuff.RjreWaitingForTeleport = false
			DONE = false
		end
		DoNotif("Teleport service is unavailable.")
		return
	end
	if NAStuff.teleportTransition == true then
		const startedAt = tonumber(NAStuff.teleportTransitionSince) or 0
		if startedAt > 0 and (nowTick - startedAt) > 20 then
			NAStuff.teleportTransition = false
			NAStuff.teleportTransitionSince = nil
		else
			if NAStuff.RjreWaitingForTeleport == true then
				NAStuff.RjreWaitingForTeleport = false
				DONE = false
			end
			DoNotif("Teleport already in progress.",2)
			return
		end
	end

	const function resolveRejoinJobId()
		const live = tostring((game and game.JobId) or "")
		if live ~= "" then
			return live
		end
		const cached = tostring(JobId or "")
		if cached ~= "" then
			return cached
		end
		return nil
	end

	const transitionToken = tostring(os.clock())..":"..tostring(math.random(1, 1e6))
	local pauseToken
	if NAmanage.PauseSettingsBuildForTeleport then
		pauseToken = NAmanage.PauseSettingsBuildForTeleport("rejoin")
	end
	NAStuff.teleportTransition = true
	NAStuff.teleportTransitionSince = nowTick
	NAStuff.teleportTransitionToken = transitionToken
	if NAStuff.RjreWaitingForTeleport == true then
		NAStuff.RjreWaitingForTeleport = transitionToken
	end

	if tp and tp.TeleportInitFailed then
		NAlib.disconnect("rejoin_tperr")
		NAlib.connect("rejoin_tperr",tp.TeleportInitFailed:Connect(function(player,result,errMsg)
			const currentLp = Services.Players and Services.Players.LocalPlayer
			if currentLp and player == currentLp and NAStuff.teleportTransitionToken == transitionToken then
				if type(NAmanage.TeleportGui_Clear) == "function" then pcall(NAmanage.TeleportGui_Clear) end
				NAStuff.teleportTransition = false
				NAStuff.teleportTransitionSince = nil
				NAStuff.teleportTransitionToken = nil
				if pauseToken and NAmanage.ResumeSettingsBuildAfterTeleport then
					pcall(NAmanage.ResumeSettingsBuildAfterTeleport, pauseToken, "failed")
				end
				if NAStuff.RjreWaitingForTeleport == transitionToken then
					NAStuff.RjreWaitingForTeleport = false
					DONE = false
				end
			end
			DoNotif(("Teleport failed [%s]: %s"):format(tostring(result),tostring(errMsg)))
		end))
	end

	const function markTeleportFailed(msg)
		if NAStuff.teleportTransitionToken == transitionToken then
			if type(NAmanage.TeleportGui_Clear) == "function" then pcall(NAmanage.TeleportGui_Clear) end
			NAStuff.teleportTransition = false
			NAStuff.teleportTransitionSince = nil
			NAStuff.teleportTransitionToken = nil
		end
		if pauseToken and NAmanage.ResumeSettingsBuildAfterTeleport then
			pcall(NAmanage.ResumeSettingsBuildAfterTeleport, pauseToken, "failed")
		end
		if NAStuff.RjreWaitingForTeleport == transitionToken then
			NAStuff.RjreWaitingForTeleport = false
			DONE = false
		end
		if msg then
			DoNotif(msg)
		end
	end

	const function watchTeleportTimeout()
		const watchToken = transitionToken
		Spawn(function()
			Wait(30)
			if NAStuff.teleportTransitionToken == watchToken then
				if type(NAmanage.TeleportGui_Clear) == "function" then pcall(NAmanage.TeleportGui_Clear) end
				NAStuff.teleportTransition = false
				NAStuff.teleportTransitionSince = nil
				NAStuff.teleportTransitionToken = nil
				if pauseToken and NAmanage.ResumeSettingsBuildAfterTeleport then
					pcall(NAmanage.ResumeSettingsBuildAfterTeleport, pauseToken, "timeout")
				end
				if NAStuff.RjreWaitingForTeleport == watchToken then
					NAStuff.RjreWaitingForTeleport = false
					DONE = false
				end
				DoNotif("Teleport timed out. Resumed settings build.",4)
			end
		end)
	end

	if #__lt.cm("Players", "GetPlayers")<=1 then
		local ok,err=NAmanage.TeleportServiceCall("Teleport", { PlaceId, lp }, {
			placeId = PlaceId;
			placeName = game.Name;
			action = "REJOINING";
			detail = "Finding a fresh server";
		})
		if not ok then
			markTeleportFailed("Teleport error: "..tostring(err))
			return
		end
	else
		const targetJobId = resolveRejoinJobId()
		if targetJobId then
			local ok,err=NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { PlaceId, targetJobId, lp }, {
				placeId = PlaceId;
				placeName = game.Name;
				action = "REJOINING SERVER";
				detail = "Returning to the current server";
			})
			if not ok then
				DoNotif("TeleportToPlaceInstance error: "..tostring(err))
				local ok2, err2 = NAmanage.TeleportServiceCall("Teleport", { PlaceId, lp }, {
					placeId = PlaceId;
					placeName = game.Name;
					action = "REJOINING";
					detail = "Current server unavailable, finding another server";
				})
				if not ok2 then
					markTeleportFailed("Teleport fallback error: "..tostring(err2))
					return
				end
			end
		else
			local ok, err = NAmanage.TeleportServiceCall("Teleport", { PlaceId, lp }, {
				placeId = PlaceId;
				placeName = game.Name;
				action = "REJOINING";
				detail = "Finding a server";
			})
			if not ok then
				markTeleportFailed("Teleport error: "..tostring(err))
				return
			end
		end
	end

	watchTeleportTimeout()
	DoNotif("Rejoining...")
end)

cmd.add({"teleporttoplace","toplace","ttp", "gametp"},{"teleporttoplace <id>","Teleports you using PlaceId"},function(...)
	args={...}
	pId=tonumber(args[1])
	local ok, err = NAmanage.TeleportServiceCall("Teleport", { pId, Services.Players and Services.Players.LocalPlayer }, {
		placeId = pId;
		action = "TELEPORTING TO PLACE";
		detail = "Place ID "..tostring(pId);
	})
	if not ok then
		DoNotif("Teleport error: "..tostring(err))
	end
end,true)

--made by the_king.78
cmd.add({"adonisbypass","bypassadonis","badonis","adonisb"},{"adonisbypass (bypassadonis,badonis,adonisb)","bypasses adonis admin detection"},function()
	--[[local DebugFunc = getinfo or debug.getinfo
	local IsDebug = false
	local hooks = {}

	local DetectedMeth, KillMeth

	for index, value in getgc(true) do
		if typeof(value) == "table" then
			local detected = rawget(value, "Detected")
			local kill = rawget(value, "Kill")

			if typeof(detected) == "function" and not DetectedMeth then
				DetectedMeth = detected

				local hook
				hook = hookfunction(DetectedMeth, function(methodName, methodFunc, methodInfo)
					if methodName ~= "_" then
						if IsDebug then
							--DoNotif("Adonis Detected\nMethod: "..tostring(methodName).."\nInfo: "..tostring(methodFunc))
						end
					end

					return true
				end)

				Insert(hooks, DetectedMeth)
			end

			if rawget(value, "Variables") and rawget(value, "Process") and typeof(kill) == "function" and not KillMeth then
				KillMeth = kill
				local hook
				hook = hookfunction(KillMeth, function(killFunc)
					if IsDebug then
						--DoNotif("Adonis tried to detect: "..tostring(killFunc))
					end
				end)

				Insert(hooks, KillMeth)
			end
		end
	end

	local hook
	hook = hookfunction(getrenv().debug.info, newcclosure(function(...)
		local functionName, functionDetails = ...

		if DetectedMeth and functionName == DetectedMeth then
			if IsDebug or not IsDebug then
				--DoNotif("Adonis was bypassed by the_king.78")
			end

			return coroutine.yield(coroutine.running())
		end

		return hook(...)
	end))]]
	SpawnCall(function()
		const getgc = getgc or debug.getgc
		const hookfunction = hookfunction
		const getrenv = getrenv
		const debugInfo = (getrenv and getrenv().debug and getrenv().debug.info) or debug.info
		const newcclosure = newcclosure or function(f) return f end

		if not (getgc and hookfunction and getrenv and debugInfo) then
			DoNotif("Required exploit functions not available. Skipping Adonis bypass.",3,"Adonis Bypasser")
			return
		end

		const IsDebug = false
		const hooks = {}
		local DetectedMeth, KillMeth
		local AdonisFound = false

		for _, value in getgc(true) do
			if typeof(value) == "table" then
				const hasDetected = typeof(rawget(value, "Detected")) == "function"
				const hasKill = typeof(rawget(value, "Kill")) == "function"
				const hasVars = rawget(value, "Variables") ~= nil
				const hasProcess = rawget(value, "Process") ~= nil

				if hasDetected or (hasKill and hasVars and hasProcess) then
					AdonisFound = true
					break
				end
			end
		end

		if not AdonisFound then
			DoNotif("Adonis not found. Bypass skipped.",3,"Adonis Bypasser")
			return
		end

		for _, value in getgc(true) do
			if typeof(value) == "table" then
				const detected = rawget(value, "Detected")
				const kill = rawget(value, "Kill")

				if typeof(detected) == "function" and not DetectedMeth then
					DetectedMeth = detected
					local hook
					hook = hookfunction(DetectedMeth, function(methodName, methodFunc)
						if methodName ~= "_" and IsDebug then
							DoNotif("Adonis Detected\nMethod: "..methodName.."\nInfo: "..methodFunc,3,"Adonis Bypasser")
						end
						return true
					end)
					Insert(hooks, DetectedMeth)
					DoNotif("Hooked Adonis 'Detected' method.",3,"Adonis Bypasser")
				end

				if rawget(value, "Variables") and rawget(value, "Process") and typeof(kill) == "function" and not KillMeth then
					KillMeth = kill
					local hook
					hook = hookfunction(KillMeth, function(killFunc)
						if IsDebug then
							DoNotif("Adonis tried to kill function: "..killFunc,3,"Adonis Bypasser")
						end
					end)
					Insert(hooks, KillMeth)
					DoNotif("Hooked Adonis 'Kill' method.",3,"Adonis Bypasser")
				end
			end
		end

		if DetectedMeth and debugInfo then
			local hook
			hook = hookfunction(debugInfo, newcclosure(function(...)
				const functionName = ...
				if functionName == DetectedMeth then
					-- warn("Adonis detection intercepted. Bypassed by the_king.78.",3,"Adonis Bypasser")
					return coroutine.yield(coroutine.running())
				end
				return hook(...)
			end))
		end
	end)
end)

--[ LOCALPLAYER ]--
NAmanage.AntiNilCharState = NAmanage.AntiNilCharState or {
	enabled = false;
	char = nil;
	lastParent = nil;
	lastCheck = 0;
	restoreWarned = false;
}

NAmanage.AntiNilChar_GetRestoreParent = function()
	const state = NAmanage.AntiNilCharState
	if state and typeof(state.lastParent) == "Instance" then
		return state.lastParent
	end
	return Services.Workspace
end

NAmanage.AntiNilChar_Restore = function(char)
	const state = NAmanage.AntiNilCharState
	if not (state and state.enabled) or NAStuff.NilCharActive == true then
		return false
	end
	if typeof(char) ~= "Instance" then
		return false
	end
	if char.Parent ~= nil then
		state.lastParent = char.Parent
		state.restoreWarned = false
		return true
	end
	const parent = NAmanage.AntiNilChar_GetRestoreParent()
	const ok = pcall(function()
		char.Parent = parent
	end)
	if ok and char.Parent ~= nil then
		state.lastParent = char.Parent
		state.restoreWarned = false
		return true
	end
	if not state.restoreWarned then
		state.restoreWarned = true
		DebugNotif("Character was destroyed; anti nil cannot restore it.", 3)
	end
	return false
end

NAmanage.AntiNilChar_Attach = function(char)
	const state = NAmanage.AntiNilCharState
	if not state or typeof(char) ~= "Instance" then
		return false
	end
	state.char = char
	if char.Parent ~= nil then
		state.lastParent = char.Parent
		state.restoreWarned = false
	end
	NAlib.disconnect("AntiNilChar_Character")
	NAlib.connect("AntiNilChar_Character", char.AncestryChanged:Connect(function(_, parent)
		if parent ~= nil then
			state.lastParent = parent
			state.restoreWarned = false
			return
		end
		Defer(function()
			NAmanage.AntiNilChar_Restore(char)
		end)
	end))
	return true
end

NAmanage.AntiNilChar_SetEnabled = function(enabled)
	const state = NAmanage.AntiNilCharState
	state.enabled = enabled == true
	NAStuff.AntiNilCharEnabled = state.enabled
	if not state.enabled then
		NAlib.disconnect("AntiNilChar")
		NAlib.disconnect("AntiNilChar_Character")
		DebugNotif("Anti nil character disabled.", 2)
		return false
	end

	const lp = Services.Players.LocalPlayer
	const char = lp and (lp.Character or getChar()) or nil
	if char then
		NAmanage.AntiNilChar_Attach(char)
	end

	NAlib.disconnect("AntiNilChar")
	if lp then
		NAlib.connect("AntiNilChar", lp.CharacterAdded:Connect(function(newChar)
			NAmanage.AntiNilChar_Attach(newChar)
		end))
	end
	NAlib.connect("AntiNilChar", Services.RunService.Heartbeat:Connect(function()
		if not state.enabled then return end
		const now = os.clock()
		if now - (state.lastCheck or 0) < 0.25 then
			return
		end
		state.lastCheck = now
		const current = lp and lp.Character or nil
		if current and current ~= state.char then
			NAmanage.AntiNilChar_Attach(current)
		end
		NAmanage.AntiNilChar_Restore(current or state.char)
	end))
	DebugNotif("Anti nil character enabled.", 2)
	return true
end

NAmanage.NilChar_SetEnabled = function(enabled)
	const lp = Services.Players.LocalPlayer
	const char = (lp and lp.Character) or getChar() or NAStuff.NilCharCharacter
	if enabled == true then
		if typeof(char) ~= "Instance" then
			DebugNotif("No character found to nil.", 2)
			return false
		end
		NAStuff.NilCharActive = true
		NAStuff.NilCharCharacter = char
		NAStuff.NilCharParent = char.Parent or NAStuff.NilCharParent or Services.Workspace
		const ok = pcall(function()
			char.Parent = nil
		end)
		if ok and char.Parent == nil then
			DebugNotif("Character parented to nil.", 2)
			return true
		end
		NAStuff.NilCharActive = false
		DebugNotif("Failed to parent character to nil.", 3)
		return false
	end

	NAStuff.NilCharActive = false
	if typeof(char) ~= "Instance" then
		NAStuff.NilCharCharacter = nil
		DebugNotif("No nil character found to restore.", 2)
		return false
	end
	if char.Parent ~= nil then
		NAStuff.NilCharParent = char.Parent
		NAStuff.NilCharCharacter = nil
		DebugNotif("Character is already restored.", 2)
		return true
	end
	const parent = typeof(NAStuff.NilCharParent) == "Instance" and NAStuff.NilCharParent or Services.Workspace
	const ok = pcall(function()
		char.Parent = parent
	end)
	if ok and char.Parent ~= nil then
		NAStuff.NilCharParent = char.Parent
		NAStuff.NilCharCharacter = nil
		DebugNotif("Character restored from nil.", 2)
		return true
	end
	DebugNotif("Character was destroyed; cannot restore it.", 3)
	return false
end

function respawn()
	const oldChar = getChar()
	local rootPart = getRoot(oldChar)
	while not rootPart do Wait(.1) rootPart=getRoot(oldChar) end

	const respawnCFrame = NAmanage.UG_clientCFrame(rootPart) or rootPart.CFrame

	local humanoid = getPlrHum(oldChar)
	while not humanoid do Wait(.1) humanoid=getPlrHum(oldChar) end
	humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	humanoid.Health = 0

	const newChar = player.CharacterAdded:Wait()
	while not getRoot(newChar) do Wait(.1) getRoot(newChar) end

	const newRoot = getRoot(newChar)
	if newRoot then
		local startTime = tick()
		const teleportThreshold = 15

		while tick() - startTime < 0.4 do
			const newPos = NAmanage.UG_clientPosition(newRoot) or newRoot.Position
			if (newPos - respawnCFrame.Position).Magnitude > teleportThreshold then
				NAmanage.UG_setClientCFrame(newRoot, respawnCFrame)
				startTime = tick()
			end
			Wait(0.1)
		end
	end
end

cmd.add({"antinil","anticharnil","antinilchar","charantinil","keepchar"},{"antinil (anticharnil, antinilchar, charantinil, keepchar)","Prevents your character from being parented to nil"},function()
	NAmanage.AntiNilChar_SetEnabled(true)
end)

cmd.add({"unantinil","unanticharnil","unantinilchar","allowcharnil","unkeepchar"},{"unantinil (unanticharnil, unantinilchar, allowcharnil, unkeepchar)","Stops preventing your character from being parented to nil"},function()
	NAmanage.AntiNilChar_SetEnabled(false)
end)

cmd.add({"nilchar","nilcharacter","charnil","nchar"},{"nilchar (nilcharacter, charnil, nchar)","Parents your character to nil"},function()
	NAmanage.NilChar_SetEnabled(true)
end)

cmd.add({"unnilchar","unnilcharacter","uncharnil","nonilchar","restorechar","bringchar"},{"unnilchar (unnilcharacter, uncharnil, nonilchar, restorechar, bringchar)","Restores your nil-parented character"},function()
	NAmanage.NilChar_SetEnabled(false)
end)

cmd.add({"accountage","accage"},{"accountage <player> (accage)","Tells the account age of a player in the server"},function(...)
	Username=(...)

	target=getPlr(Username)
	for _, plr in next, target do
		teller=plr.AccountAge
		accountage="The account age of "..nameChecker(plr).." is "..teller

		Wait();

		DoNotif(accountage)
	end
end,true)

cmd.add({"hitboxes"},{"hitboxes","shows all the hitboxes"},function()
	NAmanage.EngineSettings.setAndSave("RenderSettings", "ShowBoundingBoxes", true, "Render Bounding Boxes")
end)

cmd.add({"unhitboxes"},{"unhitboxes","removes the hitboxes outline"},function()
	NAmanage.EngineSettings.setAndSave("RenderSettings", "ShowBoundingBoxes", false, "Render Bounding Boxes")
end)

cmd.add({"vfly","vehiclefly"},{"vehiclefly (vfly)","be able to fly vehicles"},function(...)
	const arg=(...) or nil
	flyVariables.vFlySpeed=tonumber(arg) or flyVariables.vFlySpeed or 1
	NAmanage.connectVFlyKey()
	NAmanage.activateFlightModeFromCommand("vfly")
	if not IsOnMobile then
		Wait()
		DebugNotif("Vehicle fly enabled. Press '"..string.upper(flyVariables.vToggleKey).."' to vfly/unvfly.")
	end
end,true)

cmd.add({"unvfly","unvehiclefly"},{"unvfly","disable vehicle fly"},function()
	NAmanage.deactivateMode("vfly")
end)

cmd.add({"equiptools","equipall"},{"equiptools","Equip all of your tools"},function()
	const backpack=getBp()
	if backpack then
		for _,tool in backpack:GetChildren() do
			if tool:IsA("Tool") then
				tool.Parent=character
			end
		end
	end
end)

cmd.add({"usetools","uset"},{"usetools (uset)","Equips all tools, uses them, and unequips them"},function()
	const backpack = getBp()
	const character = Services.Players.LocalPlayer.Character
	const equippedTools = {}

	if not backpack or not character then
		DebugNotif("Could not find backpack or character.")
		return
	end

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") then
			Insert(equippedTools, tool)
		end
	end

	for _, tool in backpack:GetChildren() do
		if tool:IsA("Tool") and not Discover(equippedTools, tool) then
			tool.Parent = character
		end
	end

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") then
			NACaller(function()
				tool:Activate()
			end)
		end
	end

	Wait(1);

	for _, tool in character:GetChildren() do
		if tool:IsA("Tool") and not Discover(equippedTools, tool) then
			tool.Parent = backpack
		end
	end

	for _, tool in equippedTools do
		tool.Parent = character
	end
end)

cmd.add({"settweenspeed","tweenspeed"},{"tweenspeed [seconds]","Set how long tween teleport commands take"},function(seconds)
	if not seconds or seconds == "" then
		const current = tonumber(NAStuff.tweenSpeed) or 1
		DoNotif(("Current tween speed: %.2f seconds."):format(current))
		return
	end
	local value = tonumber(seconds)
	if not value then
		DoNotif("Please provide a numeric tween speed (seconds).")
		return
	end
	if value <= 0 then
		DoNotif("Tween speed must be greater than zero.")
		return
	end
	value = math.max(0.05, value)
	NAStuff.tweenSpeed = value
	NAmanage.NASettingsSet("tweenSpeed", value)
	DoNotif(("Tween speed set to %.2f seconds."):format(value))
	if not FileSupport then
		DebugNotif("Tween speed will reset when Pedoblox closes (no file support detected)")
	end
end)

NAmanage.verticalSelfTeleport=function(amount, direction)
	local studs = tonumber(amount)
	if not studs then
		DoNotif("Please provide a numeric stud amount.")
		return
	end
	studs = math.clamp(studs, 0, 1000000)
	if studs <= 0 then
		DoNotif("Stud amount must be greater than zero.")
		return
	end
	const character = getChar()
	const root = character and getRoot(character)
	if not (character and character.Parent and root and root.Parent) then
		DoNotif("Character root not found.")
		return
	end
	const baseCF = NAmanage.UG_clientCFrame(root) or character:GetPivot()
	NAmanage.UG_pivotModel(character, baseCF + Vector3.new(0, studs * direction, 0))
end

cmd.add({"tpup","up"},{"tpup <studs>","Teleports you up by the given amount of studs"},function(amount)
	NAmanage.verticalSelfTeleport(amount, 1)
end)

cmd.add({"tpdown","down"},{"tpdown <studs>","Teleports you down by the given amount of studs"},function(amount)
	NAmanage.verticalSelfTeleport(amount, -1)
end)

cmd.add({"tweento","tweengoto","tgoto"},{"tweengoto <player|npc:filter>","Teleportation method that bypasses some anticheats"},function(name)
	const char = getChar()
	for _,plr in getPlr(name) do
		const tchar = NAmanage.PlayerArgChar(plr)
		const targetPivot = NAmanage.PlayerArgPivot(plr)
		if not (char and char.Parent and tchar and tchar.Parent and targetPivot) then
			continue
		end
		const root = getRoot(char)
		const startPivot = (root and NAmanage.UG_clientCFrame(root)) or char:GetPivot()
		const duration = math.max(0.01, tonumber(NAmanage.resolveTweenDuration()) or 1)
		const startTick = os.clock()
		NAmanage.SetAttr(char, "NATweenToActive", true)
		NAmanage.SetAttr(char, "NATweenToStartCF", startPivot)
		NAmanage.SetAttr(char, "NATweenToTargetCF", targetPivot)
		local hbConn
		hbConn = Services.RunService.Heartbeat:Connect(function()
			if not (char and char.Parent) then
				NAmanage.SetAttr(char, "NATweenToActive", false)
				NAmanage.SetAttr(char, "NATweenToCurrentCF", nil)
				if hbConn then
					hbConn:Disconnect()
					hbConn = nil
				end
				return
			end
			const alpha = math.clamp((os.clock() - startTick) / duration, 0, 1)
			local eased = alpha
			local okEase, easedValue = pcall(function()
				return __lt.cm("TweenService", "GetValue", alpha, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			end)
			if okEase and type(easedValue) == "number" then
				eased = easedValue
			end
			const currentCF = startPivot:Lerp(targetPivot, eased)
			NAmanage.SetAttr(char, "NATweenToCurrentCF", currentCF)
			NAmanage.UG_pivotModel(char, currentCF)
			if alpha >= 1 then
				NAmanage.SetAttr(char, "NATweenToCurrentCF", nil)
				NAmanage.SetAttr(char, "NATweenToActive", false)
				if hbConn then
					hbConn:Disconnect()
					hbConn = nil
				end
			end
		end)
	end
end,true)


NAStuff.reachOrigSize = NAStuff.reachOrigSize or "NAReachOriginalSize"
NAmanage.cacheReachOrig=function(part)
	if not part then
		return
	end
	const existing = NAmanage.GetAttr(part, NAStuff.reachOrigSize)
	if typeof(existing) ~= "Vector3" then
		NAmanage.SetAttr(part, NAStuff.reachOrigSize, part.Size)
	end
end

cmd.add({"reach", "swordreach"}, {"reach [number] (swordreach)", "Extends sword reach in one direction"}, function(reachsize)
	reachsize = tonumber(reachsize) or 15

	const char = getChar()
	const bp = getBp()
	const Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")
	if not Tool then return end

	const partSet = {}
	for _, p in NAmanage.QueryDescendants(Tool, "BasePart") do
		partSet[p.Name] = true
	end

	const btns = {}
	for partName in partSet do
		Insert(btns, {
			Text = partName,
			Callback = function()
				const toolPart = Tool:FindFirstChild(partName)
				if not toolPart then return end

				NAmanage.cacheReachOrig(toolPart)

				if toolPart:FindFirstChild("FunTIMES") then
					toolPart.FunTIMES:Destroy()
				end

				const sb = InstanceNew("SelectionBox")
				sb.Adornee = toolPart
				sb.Name = "FunTIMES"
				sb.LineThickness = 0.01
				sb.Color3 = Color3.fromRGB(255, 0, 0)
				sb.Transparency = 0.7
				sb.Parent = toolPart

				toolPart.Massless = true
				toolPart.Size = Vector3.new(toolPart.Size.X, toolPart.Size.Y, reachsize)
			end
		})
	end

	Window({
		Title = "Reach Menu",
		Description = "Choose part to extend reach",
		Buttons = btns
	})
end, true)

cmd.add({"boxreach"}, {"boxreach [number]", "Creates a box-shaped hitbox around your tool"}, function(reachsize)
	reachsize = tonumber(reachsize) or 15

	const char = getChar()
	const bp = getBp()
	const Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")
	if not Tool then return end

	const partSet = {}
	for _, p in NAmanage.QueryDescendants(Tool, "BasePart") do
		partSet[p.Name] = true
	end

	const btns = {}
	for partName in partSet do
		Insert(btns, {
			Text = partName,
			Callback = function()
				const toolPart = Tool:FindFirstChild(partName)
				if not toolPart then return end

				NAmanage.cacheReachOrig(toolPart)

				if toolPart:FindFirstChild("FunTIMES") then
					toolPart.FunTIMES:Destroy()
				end

				const sb = InstanceNew("SelectionBox")
				sb.Adornee = toolPart
				sb.Name = "FunTIMES"
				sb.LineThickness = 0.01
				sb.Color3 = Color3.fromRGB(0, 0, 255)
				sb.Transparency = 0.7
				sb.Parent = toolPart

				toolPart.Massless = true
				toolPart.Size = Vector3.new(reachsize, reachsize, reachsize)
			end
		})
	end

	Window({
		Title = "Box Reach Menu",
		Description = "Choose part to extend box reach",
		Buttons = btns
	})
end, true)

cmd.add({"resetreach", "normalreach", "unreach"}, {"resetreach (normalreach, unreach)", "Resets tool to normal size"}, function()
	const char = getChar()
	const bp = getBp()
	const Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")
	if not Tool then return end

	for _, p in NAmanage.QueryDescendants(Tool, "BasePart") do
		const originalSize = NAmanage.GetAttr(p, NAStuff.reachOrigSize)
		if typeof(originalSize) == "Vector3" then
			p.Size = originalSize
			NAmanage.SetAttr(p, NAStuff.reachOrigSize, nil)
		else
			const legacySize = p:FindFirstChild("OGSize3")
			if legacySize and legacySize:IsA("Vector3Value") then
				p.Size = legacySize.Value
				legacySize:Destroy()
			end
		end
		if p:FindFirstChild("FunTIMES") then
			p.FunTIMES:Destroy()
		end
	end
end)

NAmanage.GetWorldRoot = NAmanage.GetWorldRoot or function(inst)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	local current = inst
	while current do
		if current:IsA("WorldRoot") then
			return current
		end
		current = current.Parent
	end
	return nil
end

NAmanage.SafeFireTouchInterest = NAmanage.SafeFireTouchInterest or function(part0, part1, state)
	if type(firetouchinterest) ~= "function" then
		return false
	end
	if typeof(part0) ~= "Instance" or typeof(part1) ~= "Instance" or not part0:IsA("BasePart") or not part1:IsA("BasePart") then
		return false
	end
	if not part0.Parent or not part1.Parent then
		return false
	end
	const world0 = NAmanage.GetWorldRoot(part0)
	const world1 = NAmanage.GetWorldRoot(part1)
	if not world0 or world0 ~= world1 then
		return false
	end
	return pcall(firetouchinterest, part0, part1, state)
end

NAmanage.MakeAuraVisualizer = NAmanage.MakeAuraVisualizer or function(name, color, radius)
	const root = getRoot(getChar())
	if not root then
		return nil
	end
	const viz = InstanceNew("SphereHandleAdornment")
	viz.Name = name
	viz.Adornee = root
	viz.Radius = math.max(1, tonumber(radius) or 1)
	viz.AlwaysOnTop = true
	viz.Transparency = 0.55
	viz.Color3 = color
	viz.ZIndex = 1
	viz.Parent = root
	return viz
end

NAStuff.auraConn = NAStuff.auraConn or nil
NAStuff.auraViz = NAStuff.auraViz or nil

cmd.add({"aura"},{"aura [distance]","Continuously damages all nearby humanoid targets with equipped tool"},function(dist)
	dist=tonumber(dist) or 20
	if not firetouchinterest then return DoNotif("firetouchinterest unsupported",2) end
	if NAStuff.auraConn then NAStuff.auraConn:Disconnect() NAStuff.auraConn=nil end
	NAlib.disconnect("aura_loop")
	if NAStuff.auraViz then NAStuff.auraViz:Destroy() NAStuff.auraViz=nil end
	NAStuff.auraViz=NAmanage.MakeAuraVisualizer("NA_AuraRadius",Color3.fromRGB(255,0,0),dist)

	const rawWorkspace=__lt.gs("Workspace")
	const overlap=OverlapParams.new()
	overlap.FilterType=Enum.RaycastFilterType.Exclude
	overlap.MaxParts=0
	pcall(function()
		overlap.RespectCanCollide=false
	end)

	const state={
		pending={},
		acc=1,
		interval=0.08,
		lastQueryParts=0,
		lastTargets=0,
		lastTouches=0,
	}
	NAStuff.auraState=state

	const function getDamagePart()
		const character=getChar()
		if not character then return end
		const tool=character:FindFirstChildWhichIsA("Tool")
		if not tool then return end
		for _,desc in NAmanage.QueryDescendants(tool,"TouchTransmitter") do
			const parent=desc.Parent
			if parent and parent:IsA("BasePart") then
				return parent
			end
		end
		const handle=tool:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			return handle
		end
		return tool:FindFirstChildWhichIsA("BasePart")
	end

	const function releaseTouches()
		for i=1,#state.pending do
			const pair=state.pending[i]
			const damagePart=pair[1]
			const targetPart=pair[2]
			const world=pair[3]
			if NAmanage.GetWorldRoot(damagePart)==world and NAmanage.GetWorldRoot(targetPart)==world then
				NAmanage.SafeFireTouchInterest(damagePart,targetPart,1)
			end
			state.pending[i]=nil
		end
	end

	const function resolveHumanoidModel(part)
		local current=part and part.Parent
		while current and current~=rawWorkspace do
			if current:IsA("Model") then
				const humanoid=current:FindFirstChildOfClass("Humanoid")
				if humanoid then
					return current,humanoid
				end
			end
			current=current.Parent
		end
		return nil,nil
	end

	NAStuff.auraConn=NAlib.reconnect("aura_loop",Services.RunService.Heartbeat:Connect(function(dt)
		if NAStuff.auraState~=state then return end
		releaseTouches()
		state.acc += tonumber(dt) or 0

		const character=getChar()
		const root=getRoot(character)
		if root and ((not NAStuff.auraViz) or (not NAStuff.auraViz.Parent) or NAStuff.auraViz.Adornee~=root) then
			if NAStuff.auraViz then NAStuff.auraViz:Destroy() end
			NAStuff.auraViz=NAmanage.MakeAuraVisualizer("NA_AuraRadius",Color3.fromRGB(255,0,0),dist)
		end
		if not root or not character or state.acc<state.interval then return end
		state.acc=0

		const damagePart=getDamagePart()
		if not damagePart then
			state.lastQueryParts=0
			state.lastTargets=0
			state.lastTouches=0
			return
		end
		pcall(function()
			if damagePart.CanTouch==false then damagePart.CanTouch=true end
		end)

		overlap.FilterDescendantsInstances={character}
		local ok,parts=pcall(function()
			return Services.Workspace:GetPartBoundsInRadius(root.Position,dist,overlap)
		end)
		if not ok or type(parts)~="table" then
			state.lastQueryParts=0
			state.lastTargets=0
			state.lastTouches=0
			return
		end

		const targets={}
		local targetCount=0
		for i=1,#parts do
			const part=parts[i]
			if part and part:IsA("BasePart") and part.Parent then
				const model,humanoid=resolveHumanoidModel(part)
				if model and model~=character and humanoid and humanoid.Health>0 and not targets[model] then
					targets[model]=true
					targetCount += 1
				end
			end
		end

		const touchWorld=NAmanage.GetWorldRoot(damagePart)
		local touchCount=0
		if touchWorld then
			for model in targets do
				if model.Parent then
					const humanoid=model:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.Health>0 then
						for _,targetPart in model:GetChildren() do
							if targetPart:IsA("BasePart") and NAmanage.GetWorldRoot(targetPart)==touchWorld then
								if NAmanage.SafeFireTouchInterest(damagePart,targetPart,0) then
									Insert(state.pending,{damagePart,targetPart,touchWorld})
									touchCount += 1
								end
							end
						end
					end
				end
			end
		end
		state.lastQueryParts=#parts
		state.lastTargets=targetCount
		state.lastTouches=touchCount
	end))
	DebugNotif("Aura enabled at "..dist,1.2)
end,true)

cmd.add({"unaura"},{"unaura","Stops aura loop and removes visualizer"},function()
	const state=NAStuff.auraState
	if state and type(state.pending)=="table" then
		for _,pair in state.pending do
			if NAmanage.GetWorldRoot(pair[1])==pair[3] and NAmanage.GetWorldRoot(pair[2])==pair[3] then
				NAmanage.SafeFireTouchInterest(pair[1],pair[2],1)
			end
		end
	end
	NAStuff.auraState=nil
	if NAStuff.auraConn then NAStuff.auraConn:Disconnect() NAStuff.auraConn=nil end
	NAlib.disconnect("aura_loop")
	if NAStuff.auraViz then NAStuff.auraViz:Destroy() NAStuff.auraViz=nil end
	DebugNotif("Aura disabled",1.2)
end,true)

NAStuff.npcauraConn = NAStuff.npcauraConn or nil
NAStuff.npcauraViz = NAStuff.npcauraViz or nil
NAStuff.npcauraState = NAStuff.npcauraState or nil

NAmanage.StopNPCAura = function()
	const state = NAStuff.npcauraState
	if state and state.pending then
		for _, pair in state.pending do
			if pair[1] and pair[1].Parent and pair[2] and pair[2].Parent then
				pcall(firetouchinterest, pair[1], pair[2], 1)
			end
		end
	end
	NAStuff.npcauraState = nil
	if NAStuff.npcauraConn then
		NAStuff.npcauraConn:Disconnect()
		NAStuff.npcauraConn = nil
	end
	NAlib.disconnect("npcaura_loop")
	if NAStuff.npcauraViz then
		NAStuff.npcauraViz:Destroy()
		NAStuff.npcauraViz = nil
	end
end

cmd.add({"npcaura"},{"npcaura [distance]","Continuously damages nearby NPCs with equipped tool"},function(dist)
	const RawWorkspace = __lt.gs("Workspace")
	dist = tonumber(dist) or 20
	if not firetouchinterest then return DoNotif("firetouchinterest unsupported",2) end
	NAmanage.StopNPCAura()
	NAStuff.npcauraViz = NAmanage.MakeAuraVisualizer("NA_NPCAuraRadius", Color3.fromRGB(255,85,0), dist)

	const state = {
		targets = {},
		pending = {},
		cursor = 1,
		scanAcc = 1,
		hitAcc = 0,
		scanInterval = 0.35,
		hitInterval = 0.08,
		maxTargetsPerHit = 3,
	}
	NAStuff.npcauraState = state

	const overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.MaxParts = 384

	const function getDamagePart()
		const character = getChar()
		if not character then return end
		const tool = character:FindFirstChildWhichIsA("Tool")
		if not tool then return end
		for _, transmitter in NAmanage.QueryDescendants(tool, "TouchTransmitter") do
			const parent = transmitter.Parent
			if parent and parent:IsA("BasePart") then
				return parent
			end
		end
		const handle = tool:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			return handle
		end
		return tool:FindFirstChildWhichIsA("BasePart")
	end

	const function getTargetPart(model)
		local part = getRoot(model)
		if not part then
			const humanoid = getPlrHum(model)
			part = humanoid and humanoid.RootPart or nil
		end
		if not part then
			part = model:FindFirstChildWhichIsA("BasePart", true)
		end
		return part
	end

	const function addTarget(out, seen, model, root)
		if not (model and model:IsA("Model") and model.Parent and not seen[model]) then
			return
		end
		seen[model] = true
		if not CheckIfNPC(model) then
			return
		end
		const humanoid = getPlrHum(model)
		const part = getTargetPart(model)
		if not (humanoid and humanoid.Health > 0 and part and part.Parent) then
			return
		end
		if (part.Position - root.Position).Magnitude > dist then
			return
		end
		Insert(out, model)
	end

	const function refreshTargets(root)
		const out = {}
		const seen = {}
		overlap.FilterDescendantsInstances = { getChar() }
		local ok, parts = pcall(function()
			return Services.Workspace:GetPartBoundsInRadius(root.Position, dist, overlap)
		end)
		if ok and type(parts) == "table" then
			for _, part in parts do
				local current = part.Parent
				while current and current ~= RawWorkspace do
					if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
						addTarget(out, seen, current, root)
						break
					end
					current = current.Parent
				end
			end
		else
			for _, npc in getPlr("npc") do
				addTarget(out, seen, npc, root)
			end
		end
		state.targets = out
		if state.cursor > #out then
			state.cursor = 1
		end
	end

	const function releaseTouches()
		for _, pair in state.pending do
			if pair[1] and pair[1].Parent and pair[2] and pair[2].Parent then
				pcall(firetouchinterest, pair[1], pair[2], 1)
			end
		end
		table.clear(state.pending)
	end

	const function beginTouch(damagePart, targetPart)
		if not (damagePart and damagePart.Parent and targetPart and targetPart.Parent) then
			return false
		end
		local touchOk, canTouch = pcall(function()
			return targetPart.CanTouch
		end)
		if touchOk and canTouch == false then return false end
		pcall(function()
			if damagePart.CanTouch == false then damagePart.CanTouch = true end
		end)
		const ok = pcall(firetouchinterest, damagePart, targetPart, 0)
		if ok then
			Insert(state.pending, { damagePart, targetPart })
		end
		return ok
	end

	NAStuff.npcauraConn = NAlib.reconnect("npcaura_loop", Services.RunService.Heartbeat:Connect(function(dt)
		if NAStuff.npcauraState ~= state then return end
		releaseTouches()
		state.scanAcc += tonumber(dt) or 0
		state.hitAcc += tonumber(dt) or 0

		const root = getRoot(getChar())
		if root and ((not NAStuff.npcauraViz) or (not NAStuff.npcauraViz.Parent) or NAStuff.npcauraViz.Adornee ~= root) then
			if NAStuff.npcauraViz then NAStuff.npcauraViz:Destroy() end
			NAStuff.npcauraViz = NAmanage.MakeAuraVisualizer("NA_NPCAuraRadius", Color3.fromRGB(255,85,0), dist)
		end
		if not root then return end

		if state.scanAcc >= state.scanInterval then
			state.scanAcc = 0
			refreshTargets(root)
		end
		if state.hitAcc < state.hitInterval then return end
		state.hitAcc = 0

		const damagePart = getDamagePart()
		if not damagePart or #state.targets == 0 then return end

		local processed = 0
		local checked = 0
		while processed < state.maxTargetsPerHit and checked < #state.targets do
			if state.cursor > #state.targets then state.cursor = 1 end
			const npc = state.targets[state.cursor]
			state.cursor += 1
			checked += 1
			if npc and npc.Parent then
				const humanoid = getPlrHum(npc)
				const targetPart = getTargetPart(npc)
				if humanoid and humanoid.Health > 0 and targetPart and targetPart.Parent and (targetPart.Position - root.Position).Magnitude <= dist then
					if beginTouch(damagePart, targetPart) then
						processed += 1
					end
				end
			end
		end
	end))
	DebugNotif("NPCAura enabled at "..dist,1.2)
end,true)

cmd.add({"unnpcaura"},{"unnpcaura","Stops NPC aura loop and removes visualizer"},function()
	NAmanage.StopNPCAura()
	DebugNotif("NPCAura disabled",1.2)
end,true)

cmd.add({"antivoid"},{"antivoid","Prevents you from falling into the void by launching you upwards"},function()
	NAlib.disconnect("antivoid")

	NAlib.connect("antivoid", Services.RunService.RenderStepped:Connect(function()
		const character = getChar()
		const root = character and getRoot(character)
		if root and root.Position.Y <= OrgDestroyHeight + 25 then
			root.Velocity = Vector3.new(root.Velocity.X, root.Velocity.Y + 250, root.Velocity.Z)
		end
	end))

	DebugNotif("AntiVoid Enabled", 3)
end)

cmd.add({"unantivoid"},{"unantivoid","Disables antivoid"},function()
	NAlib.disconnect("antivoid")
	DebugNotif("AntiVoid Disabled", 3)
end)

cmd.add({"nofall","nofalldamage","antifall","nofalldmg"},{"nofall [limit] [slow]","Prevents fall damage by slowing falls and cancelling landing velocity (STILL IN BETA)"},function(limitArg, slowArg)
	local lim = tonumber(limitArg) or 70
	local slow = tonumber(slowArg) or 20

	lim = math.clamp(lim, 10, 500)
	slow = math.clamp(slow, 4, 80)

	NAlib.disconnect("nofall")
	NAlib.disconnect("nofall_char")

	const rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.IgnoreWater = true

	const st = {
		lim = lim,
		slow = slow,
		char = nil,
		hum = nil,
		root = nil,
		last = 0,
		pulse = 0,
		hard = 0,
		peak = 0,
		dead = false,
		ray = rp,
	}

	NAStuff._noFall = st

	const plr = LocalPlayer or (Services.Players and Services.Players.LocalPlayer) or game:GetService("Players").LocalPlayer

	const function getv(root)
		local ok, v = pcall(function()
			return root.AssemblyLinearVelocity
		end)

		if ok and typeof(v) == "Vector3" then
			return v
		end

		return root.Velocity
	end

	const function setv(root, v)
		if not root or not root.Parent then return end

		pcall(function()
			root.AssemblyLinearVelocity = v
		end)

		pcall(function()
			root.Velocity = v
		end)
	end

	const function reset(char)
		if NAStuff._noFall ~= st or st.dead then return end

		st.char = char
		st.hum = char and getHum(char)
		st.root = char and getRoot(char)
		st.last = 0
		st.pulse = 0
		st.hard = 0
		st.peak = st.root and st.root.Position.Y or 0
		st.ray.FilterDescendantsInstances = char and {char} or {}
	end

	const function refresh(char)
		if NAStuff._noFall ~= st or st.dead then return end
		if not char or st.char ~= char then return end

		st.hum = getHum(char)
		st.root = getRoot(char)

		if st.root then
			st.peak = st.root.Position.Y
		end

		st.ray.FilterDescendantsInstances = {char}
	end

	const function refs()
		const char = getChar()

		if st.char ~= char then
			reset(char)
		end

		if st.char and (not st.hum or not st.hum.Parent) then
			st.hum = getHum(st.char)
		end

		if st.char and (not st.root or not st.root.Parent) then
			st.root = getRoot(st.char)
		end

		return st.char, st.hum, st.root
	end

	const function isair(hum)
		const s = hum:GetState()

		return hum.FloorMaterial == Enum.Material.Air
			or s == Enum.HumanoidStateType.Freefall
			or s == Enum.HumanoidStateType.FallingDown
	end

	const function ground(root, spd)
		const len = math.clamp((spd * 0.1) + 10, 12, 70)
		const hit = Services.Workspace:Raycast(root.Position, Vector3.new(0, -len, 0), st.ray)

		if not hit or not hit.Instance then
			return nil, math.huge
		end

		return hit, root.Position.Y - hit.Position.Y
	end

	const function pulse(hum)
		if not hum or not hum.Parent or hum.Health <= 0 then return end

		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Climbing)
		end)

		Defer(function()
			if NAStuff._noFall ~= st or st.dead then return end
			if not hum or not hum.Parent or hum.Health <= 0 then return end

			pcall(function()
				hum:ChangeState(Enum.HumanoidStateType.Freefall)
			end)
		end)
	end

	const function land(hum, root, v)
		if not hum or not root then return end
		if not hum.Parent or not root.Parent or hum.Health <= 0 then return end

		const nv = Vector3.new(v.X, -1, v.Z)

		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Climbing)
		end)

		setv(root, nv)

		Delay(0.04, function()
			if NAStuff._noFall ~= st or st.dead then return end
			if not hum or not root then return end
			if not hum.Parent or not root.Parent or hum.Health <= 0 then return end

			const cv = getv(root)

			if hum.FloorMaterial == Enum.Material.Air and cv.Y < 2 then
				pcall(function()
					hum:ChangeState(Enum.HumanoidStateType.Freefall)
				end)
			else
				pcall(function()
					hum:ChangeState(Enum.HumanoidStateType.Running)
				end)
			end
		end)
	end

	NAlib.connect("nofall_char", plr.CharacterAdded:Connect(function(char)
		if NAStuff._noFall ~= st or st.dead then return end

		reset(char)

		Defer(function()
			if NAStuff._noFall ~= st or st.dead then return end
			refresh(char)
		end)

		Delay(0.25, function()
			if NAStuff._noFall ~= st or st.dead then return end
			refresh(char)
		end)

		Delay(1, function()
			if NAStuff._noFall ~= st or st.dead then return end
			refresh(char)
		end)
	end))

	if plr.Character then
		reset(plr.Character)
	end

	NAlib.connect("nofall", Services.RunService.Heartbeat:Connect(function(dt)
		if NAStuff._noFall ~= st or st.dead then return end

		local char, hum, root = refs()
		if not char or not hum or not root then return end
		if not char.Parent or not hum.Parent or not root.Parent then return end
		if hum.Health <= 0 then return end

		const v = getv(root)
		const y = v.Y
		const now = os.clock()
		const pos = root.Position

		if pos.Y > st.peak then
			st.peak = pos.Y
		end

		if not isair(hum) then
			st.peak = pos.Y
			st.hard = 0

			if y < -st.slow then
				setv(root, Vector3.new(v.X, -2, v.Z))
			end

			return
		end

		if y >= -2 then return end

		const spd = -y
		const drop = st.peak - pos.Y

		if spd < st.lim and drop < 18 then return end

		local hit, dst = ground(root, spd)
		const near = hit and dst <= math.clamp((spd * 0.07) + 5, 6, 24)

		if y < -st.slow then
			local xz = Vector3.new(v.X, 0, v.Z)
			const mx = math.max(30, st.slow * 2.5)

			if xz.Magnitude > mx then
				xz = xz.Unit * mx
			end

			setv(root, Vector3.new(xz.X, -st.slow, xz.Z))
		end

		if now - st.pulse >= 0.24 then
			st.pulse = now
			pulse(hum)
		end

		if near then
			st.hard = now + 0.22
		end

		if near or now <= st.hard then
			if now - st.last >= 0.025 then
				st.last = now
				land(hum, root, getv(root))
			end
		end
	end))

	DebugNotif("NoFall enabled | limit: "..tostring(lim).." | slow: "..tostring(slow), 2)
end, true)

cmd.add({"unnofall","unnofalldamage","unantifall","unnofalldmg"},{"unnofall","Disables nofall"},function()
	const st = NAStuff._noFall

	if st then
		st.dead = true
		st.char = nil
		st.hum = nil
		st.root = nil

		if st.ray then
			st.ray.FilterDescendantsInstances = {}
		end
	end

	NAStuff._noFall = nil
	NAlib.disconnect("nofall")
	NAlib.disconnect("nofall_char")
	DebugNotif("NoFall disabled", 2)
end)

cmd.add({"fakeout"}, {"fakeout", "tp to void and back"}, function()
	const character = getChar()
	const root = character and getRoot(character)
	if not root then
		DebugNotif("Fakeout failed: unable to find character root", 2)
		return
	end
	const antivoidWasActive = (NAlib and NAlib.isConnected and NAlib.isConnected("antivoid")) or false
	if antivoidWasActive then
		NAlib.disconnect("antivoid")
	end
	const originalDestroyHeight = Services.Workspace.FallenPartsDestroyHeight
	const originalCFrame = NAmanage.UG_clientCFrame(root) or root.CFrame
	const dropHeight = OrgDestroyHeight or originalDestroyHeight or 0
	Services.Workspace.FallenPartsDestroyHeight = 0/1/0
	NAmanage.UG_setRootCFrame(root, CFrame.new(Vector3.new(0, dropHeight - 25, 0)))
	Wait(1)
	NAmanage.UG_setRootCFrame(root, originalCFrame)
	Services.Workspace.FallenPartsDestroyHeight = originalDestroyHeight
	if antivoidWasActive then
		const antivoidCommand = cmds.Commands["antivoid"]
		if antivoidCommand and antivoidCommand[1] then
			antivoidCommand[1]()
		end
	end
end)

cmd.add({"invisfling"}, {"invisfling", "Enables invisible fling (the invis part is patched, try using the god command before using this)"}, function()
	const player = Services.Players.LocalPlayer
	local character = getChar()
	const humanoid = getHum()
	if not (player and character and humanoid) then
		DebugNotif("Invisfling failed: missing character", 2)
		return
	end

	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

	const proxyModel = InstanceNew("Model")
	proxyModel.Name = NAmanage.GetSessionInstanceName("InvisFlingProxy")
	proxyModel.Parent = character

	const torso = InstanceNew("Part")
	torso.Name = "Torso"
	torso.CanCollide = false
	torso.Anchored = true
	torso.Position = Vector3.new(0, 9999, 0)
	torso.Parent = proxyModel

	const head = InstanceNew("Part")
	head.Name = "Head"
	head.CanCollide = false
	head.Anchored = true
	head.Parent = proxyModel

	const proxyHumanoid = InstanceNew("Humanoid")
	proxyHumanoid.Name = "Humanoid"
	proxyHumanoid.Parent = proxyModel

	player.Character = proxyModel
	Wait(3)
	player.Character = character
	Wait(3)

	character = getChar()
	if not character then
		DebugNotif("Invisfling aborted: character missing", 2)
		return
	end

	local activeHumanoid = getHum()
	if not activeHumanoid then
		activeHumanoid = InstanceNew("Humanoid")
		activeHumanoid.Name = "Humanoid"
		activeHumanoid.Parent = character
	end

	const root = getRoot(character)
	if not root then
		DebugNotif("Invisfling failed: missing root", 2)
		return
	end

	for _, child in character:GetChildren() do
		if child ~= root and child.Name ~= "Humanoid" then
			child:Destroy()
		end
	end

	root.Transparency = 0
	root.Color = Color3.new(1, 1, 1)

	local invisflingStepped
	invisflingStepped = NAlib.reconnect("invisfling_nocollide", Services.RunService.PreSimulation:Connect(function()
		const currentChar = getChar()
		const currentRoot = currentChar and getRoot(currentChar)
		if currentRoot then
			currentRoot.CanCollide = false
		else
			invisflingStepped:Disconnect()
			NAlib.disconnect("invisfling_nocollide")
		end
	end))

	NAmanage.activateMode("fly")
	Services.Workspace.CurrentCamera.CameraSubject = root

	const thrust = InstanceNew("BodyThrust")
	thrust.Parent = root
	thrust.Force = Vector3.new(99999, 99999 * 10, 99999)
	thrust.Location = root.Position
end)

cmd.add({"split"}, {"split", "Destroys waist joint"}, function()
	if not IsR15() then
		DoNotif("This command requires the R15 rig type.", 3, "split")
		return
	end

	const character = getChar()
	if not character then
		DebugNotif("Split failed: no character", 2)
		return
	end

	const upperTorso = getTorso(character)
	const waist = upperTorso and upperTorso:FindFirstChild("Waist")
	if waist then
		waist:Destroy()
		DebugNotif("Waist joint removed.", 2)
	else
		DebugNotif("Split failed: waist joint not found.", 2)
	end
end)
originalFPDH = nil

cmd.add({"antivoid2"}, {"antivoid2", "sets FallenPartsDestroyHeight to -inf"}, function()
	if not originalFPDH then
		originalFPDH = Services.Workspace.FallenPartsDestroyHeight
	end

	Services.Workspace.FallenPartsDestroyHeight = -9e9
end)

cmd.add({"unantivoid2"}, {"unantivoid2", "reverts FallenPartsDestroyHeight"}, function()
	if originalFPDH ~= nil then
		Services.Workspace.FallenPartsDestroyHeight = originalFPDH
		DebugNotif("FallenPartsDestroyHeight reverted to original value | Antivoid2 Disabled",2)
	else
		DebugNotif("Original value was not stored. Cannot revert.",2)
	end
end)

cmd.add({"antivelocity","antivelo","av","velcap"}, {"antivelocity [limit]", "Limits your character's velocity to the provided value"}, function(limitArg)
	const limit = tonumber(limitArg)
	if not limit then
		DebugNotif("Please provide a number for antivelocity.", 3)
		return
	end
	if limit <= 0 then
		DebugNotif("Antivelocity requires a value greater than zero.", 3)
		return
	end

	AntiVelocityLimit = limit
	NAlib.disconnect("antivelocity_limit")

	NAlib.connect("antivelocity_limit", Services.RunService.Heartbeat:Connect(function()
		if not AntiVelocityLimit then
			return
		end

		const character = getChar()
		const root = character and getRoot(character)
		if not root then
			return
		end

		const velocity = root.AssemblyLinearVelocity
		const speed = velocity.Magnitude
		if speed > AntiVelocityLimit then
			if speed > 0 then
				root.AssemblyLinearVelocity = velocity.Unit * AntiVelocityLimit
			else
				root.AssemblyLinearVelocity = Vector3.zero
			end
		end
	end))

	DebugNotif(("Velocity capped at %s studs/sec."):format(tostring(limit)), 3)
end, true)

cmd.add({"unantivelocity","unantivelo","unav","unvelcap"}, {"unantivelocity", "Disables the antivelocity limiter"}, function()
	AntiVelocityLimit = nil
	NAlib.disconnect("antivelocity_limit")
	DebugNotif("Antivelocity disabled.", 2)
end)

NAStuff.AVCls = NAStuff.AVCls or {
	BodyAngularVelocity = true;
	BodyForce = true;
	BodyGyro = true;
	BodyPosition = true;
	BodyThrust = true;
	BodyVelocity = true;
	RocketPropulsion = true;
	LinearVelocity = true;
	AngularVelocity = true;
	VectorForce = true;
	Torque = true;
	LineForce = true;
	AlignPosition = true;
	AlignOrientation = true;
}

NAmanage.IsMover = function(obj)
	if typeof(obj) ~= "Instance" then
		return false
	end

	if NAStuff.AVCls[obj.ClassName] then
		return true
	end

	local ok, isBM = pcall(obj.IsA, obj, "BodyMover")
	return ok and isBM == true
end

NAmanage.KillMover = function(state, obj)
	if state ~= NAStuff._avState or state.enabled ~= true then
		return false
	end

	const char = state.char
	if not NAmanage.IsMover(obj) or typeof(char) ~= "Instance" or not obj:IsDescendantOf(char) then
		return false
	end

	const ok = pcall(function()
		obj:Destroy()
	end)
	if ok then
		state.removed = (tonumber(state.removed) or 0) + 1
	end
	return ok
end

NAmanage.BindMover = function(char, state)
	NAlib.disconnect("avm_desc")
	state.char = char

	if typeof(char) ~= "Instance" then
		return
	end

	for _, obj in NAmanage.QueryDescendants(char, "Instance") do
		NAmanage.KillMover(state, obj)
	end

	NAlib.connect("avm_desc", NAmanage.descAdd(char, function(obj)
		NAmanage.KillMover(state, obj)
	end, NAmanage.IsMover))
end

cmd.add({"antivelocityinstances","antivelocityobjects","antimovers","avinstances","avi"}, {"antivelocityinstances (antimovers)", "Continuously destroys force, torque, position, orientation, and velocity mover instances inside your character"}, function()
	NAlib.disconnect("avm_add")
	NAlib.disconnect("avm_desc")

	const old = NAStuff._avState
	if type(old) == "table" then
		old.enabled = false
		old.char = nil
	end

	const state = {
		enabled = true;
		char = nil;
		removed = 0;
	}
	NAStuff._avState = state

	NAmanage.BindMover(getChar(), state)
	NAlib.connect("avm_add", Services.Players.LocalPlayer.CharacterAdded:Connect(function(char)
		if state ~= NAStuff._avState or state.enabled ~= true then
			return
		end
		NAmanage.BindMover(char, state)
	end))

	DebugNotif(("Anti velocity instances enabled. Removed %d existing mover(s). This will break fly and other character force systems."):format(state.removed), 4)
end)

cmd.add({"unantivelocityinstances","unantivelocityobjects","unantimovers","unavinstances","unavi"}, {"unantivelocityinstances (unantimovers)", "Stops removing force and velocity mover instances from your character"}, function()
	NAlib.disconnect("avm_add")
	NAlib.disconnect("avm_desc")

	const state = NAStuff._avState
	if type(state) == "table" then
		state.enabled = false
		state.char = nil
	end
	NAStuff._avState = nil

	DebugNotif("Anti velocity instances disabled. Previously destroyed movers cannot be restored.", 3)
end)

NAStuff.AntiKBForceProps = NAStuff.AntiKBForceProps or {
	BodyVelocity = {
		Velocity = Vector3.zero,
		MaxForce = Vector3.zero,
		P = 0,
	};
	BodyForce = {
		Force = Vector3.zero,
	};
	BodyThrust = {
		Force = Vector3.zero,
		Location = Vector3.zero,
	};
	BodyGyro = {
		MaxTorque = Vector3.zero,
		P = 0,
		D = 0,
	};
	BodyAngularVelocity = {
		AngularVelocity = Vector3.zero,
		MaxTorque = Vector3.zero,
		P = 0,
	};
	LinearVelocity = {
		MaxForce = 0,
	};
	VectorForce = {
		Force = Vector3.zero,
	};
	AlignPosition = {
		MaxForce = 0,
		Responsiveness = 0,
	};
	AlignOrientation = {
		MaxTorque = 0,
		Responsiveness = 0,
		MaxAngularVelocity = 0,
	};
	BodyPosition = {
		MaxForce = Vector3.zero,
		P = 0,
		D = 0,
	};
}

NAmanage.antiKBInChar=function(obj, char)
	if not obj or not char then
		return false
	end
	local p = obj
	while p do
		if p == char then
			return true
		end
		p = p.Parent
	end
	return false
end

NAmanage.antiKBDropObj=function(state, obj)
	if not state or not obj then
		return
	end
	const conns = state.objConns and state.objConns[obj]
	if conns then
		for i = 1, #conns do
			const c = conns[i]
			if c and c.Connected then
				c:Disconnect()
			end
		end
		state.objConns[obj] = nil
	end
	if state.forces then
		state.forces[obj] = nil
	end
	if state.deferQ then
		state.deferQ[obj] = nil
	end
end

NAmanage.antiKBApplyObj=function(state, obj)
	if state ~= NAStuff._antiKnockbackState then
		return
	end
	const char = state and state.char
	if not char or not obj or not obj.Parent or not NAmanage.antiKBInChar(obj, char) then
		NAmanage.antiKBDropObj(state, obj)
		return
	end
	const cfg = NAStuff.AntiKBForceProps[obj.ClassName]
	if not cfg then
		NAmanage.antiKBDropObj(state, obj)
		return
	end

	for prop, value in cfg do
		NAlib.setProperty(obj, prop, value)
	end

	local root = state.root
	if (not root) or root.Parent ~= char then
		root = getRoot(char)
		state.root = root
	end
	if root then
		if obj:IsA("BodyGyro") or obj:IsA("AlignOrientation") then
			NAlib.setProperty(obj, "CFrame", root.CFrame)
		elseif obj:IsA("BodyPosition") or obj:IsA("AlignPosition") then
			NAlib.setProperty(obj, "Position", root.Position)
		end
	end
end

NAmanage.antiKBQueueObj=function(state, obj)
	if not state or not obj or state ~= NAStuff._antiKnockbackState then
		return
	end
	if not state.deferQ then
		state.deferQ = {}
	end
	if state.deferQ[obj] then
		return
	end
	state.deferQ[obj] = true
	Defer(function()
		if state.deferQ then
			state.deferQ[obj] = nil
		end
		NAmanage.antiKBApplyObj(state, obj)
	end)
end

NAmanage.antiKBBindObj=function(state, obj)
	if state ~= NAStuff._antiKnockbackState then
		return
	end
	const cfg = obj and NAStuff.AntiKBForceProps[obj.ClassName]
	if not cfg then
		return
	end
	if state.forces[obj] then
		NAmanage.antiKBQueueObj(state, obj)
		return
	end

	state.forces[obj] = true
	const conns = {}
	state.objConns[obj] = conns

	for prop in cfg do
		if NAlib.isProperty(obj, prop) ~= nil then
			conns[#conns + 1] = obj:GetPropertyChangedSignal(prop):Connect(function()
				NAmanage.antiKBQueueObj(state, obj)
			end)
		end
	end

	conns[#conns + 1] = obj.AncestryChanged:Connect(function(_, parent)
		if state ~= NAStuff._antiKnockbackState then
			return
		end
		if (not parent) or (not state.char) or (not NAmanage.antiKBInChar(obj, state.char)) then
			NAmanage.antiKBDropObj(state, obj)
		end
	end)

	NAmanage.antiKBQueueObj(state, obj)
end

NAmanage.antiKBClearState=function(state)
	if not state then
		return
	end
	if state.objConns then
		for obj in state.objConns do
			NAmanage.antiKBDropObj(state, obj)
		end
	end
	if state.forces then
		table.clear(state.forces)
	end
	if state.deferQ then
		table.clear(state.deferQ)
	end
	state.root = nil
	state.char = nil
	state.rootSyncPend = nil
end

NAmanage.AntiKnockBack=function(char, state)
	NAlib.disconnect("antiknockback_char_desc")
	NAlib.disconnect("antiknockback_char_rem")
	NAlib.disconnect("antiknockback_hum_ps")
	NAlib.disconnect("antiknockback_root_cf")
	NAlib.disconnect("antiknockback_root_pos")

	NAmanage.antiKBClearState(state)
	if not char or not state then
		return
	end

	state.char = char
	state.root = getRoot(char)

	const function queueRootSync()
		if state ~= NAStuff._antiKnockbackState then
			return
		end
		if state.rootSyncPend then
			return
		end
		state.rootSyncPend = true
		Defer(function()
			state.rootSyncPend = nil
			if state ~= NAStuff._antiKnockbackState then
				return
			end
			for obj in state.forces do
				const cn = obj and obj.ClassName
				if cn == "BodyGyro" or cn == "AlignOrientation" or cn == "BodyPosition" or cn == "AlignPosition" then
					NAmanage.antiKBQueueObj(state, obj)
				end
			end
		end)
	end

	const function bindRoot()
		NAlib.disconnect("antiknockback_root_cf")
		NAlib.disconnect("antiknockback_root_pos")
		const root = getRoot(char)
		state.root = root
		if not root then
			return
		end
		NAlib.connect("antiknockback_root_cf", root:GetPropertyChangedSignal("CFrame"):Connect(queueRootSync))
		NAlib.connect("antiknockback_root_pos", root:GetPropertyChangedSignal("Position"):Connect(queueRootSync))
	end

	const function bindHum()
		NAlib.disconnect("antiknockback_hum_ps")
		const hum = getHum(char)
		if hum and NAlib.isProperty(hum, "PlatformStand") ~= nil then
			NAlib.setProperty(hum, "PlatformStand", false)
			NAlib.connect("antiknockback_hum_ps", hum:GetPropertyChangedSignal("PlatformStand"):Connect(function()
				if state ~= NAStuff._antiKnockbackState then
					return
				end
				if hum.PlatformStand then
					Defer(function()
						if state == NAStuff._antiKnockbackState and hum and hum.Parent and hum.PlatformStand then
							NAlib.setProperty(hum, "PlatformStand", false)
						end
					end)
				end
			end))
		end
	end

	for _, obj in NAmanage.QueryDescendants(char, "Instance") do
		NAmanage.antiKBBindObj(state, obj)
	end
	bindRoot()
	bindHum()

	NAlib.connect("antiknockback_char_desc", NAmanage.descAdd(char, function(obj)
		if state ~= NAStuff._antiKnockbackState then
			return
		end
		if obj:IsA("Humanoid") then
			bindHum()
		elseif obj.Name == "HumanoidRootPart" then
			bindRoot()
		end
		NAmanage.antiKBBindObj(state, obj)
	end, function(desc)
		return desc and desc:IsA("BasePart")
	end))

	NAlib.connect("antiknockback_char_rem", NAmanage.descRem(char, function(obj)
		if state ~= NAStuff._antiKnockbackState then
			return
		end
		NAmanage.antiKBDropObj(state, obj)
		if obj == state.root then
			state.root = nil
			NAlib.disconnect("antiknockback_root_cf")
			NAlib.disconnect("antiknockback_root_pos")
		end
	end))
end

cmd.add({"antiknockback","akb"}, {"antiknockback (akb)", "Disables knockback"}, function()
	NAlib.disconnect("antiknockback_char_add")
	NAlib.disconnect("antiknockback_char_desc")
	NAlib.disconnect("antiknockback_char_rem")
	NAlib.disconnect("antiknockback_hum_ps")
	NAlib.disconnect("antiknockback_root_cf")
	NAlib.disconnect("antiknockback_root_pos")
	NAmanage.antiKBClearState(NAStuff._antiKnockbackState)

	const state = {
		forces = {};
		objConns = {};
		deferQ = {};
		char = nil;
		root = nil;
		rootSyncPend = nil;
	}
	NAStuff._antiKnockback = true
	NAStuff._antiKnockbackState = state

	NAmanage.AntiKnockBack(getChar(), state)
	NAlib.connect("antiknockback_char_add", Services.Players.LocalPlayer.CharacterAdded:Connect(function(char)
		if state ~= NAStuff._antiKnockbackState then
			return
		end
		NAmanage.AntiKnockBack(char, state)
	end))

	DebugNotif("AntiKnockback enabled. This may break fly.", 3)
end)

cmd.add({"unantiknockback","unakb"}, {"unantiknockback (unakb)", "Disables antiknockback"}, function()
	NAlib.disconnect("antiknockback_char_add")
	NAlib.disconnect("antiknockback_char_desc")
	NAlib.disconnect("antiknockback_char_rem")
	NAlib.disconnect("antiknockback_hum_ps")
	NAlib.disconnect("antiknockback_root_cf")
	NAlib.disconnect("antiknockback_root_pos")

	const state = NAStuff._antiKnockbackState
	NAmanage.antiKBClearState(state)

	NAStuff._antiKnockbackState = nil
	NAStuff._antiKnockback = nil

	const char = getChar()
	const root = char and getRoot(char)
	if root and NAlib.isProperty(root, "Anchored") ~= nil then
		NAlib.setProperty(root, "Anchored", false)
	end

	DebugNotif("AntiKnockback disabled.", 2)
end)

comPart, comHL, comConn, comRadius = nil,nil,nil,nil

NAStuff.PredictionConfig = NAStuff.PredictionConfig or {
	color = Color3.fromRGB(255, 255, 0);
	radius = 0.35;
	defaultLead = 0.25;
	maxOffset = 40;
}

NAStuff.PredictionState = NAStuff.PredictionState or {
	conn = nil;
	cleanupConn = nil;
	folder = nil;
	lead = nil;
	tracks = {};
	lastRuntimeErrorAt = 0;
	stats = {
		tracked = 0;
		visible = 0;
		missingCharacter = 0;
		missingRoot = 0;
	};
}

cmd.add({"showcom","centerofmass","com"},{"showcom [radiusStuds]","Create a glass sphere with a Highlight at your center of mass"},function(...)
	comRadius = tonumber(({...})[1]) or 0.35
	if comConn then comConn:Disconnect() comConn=nil end
	NAlib.disconnect("com_track")

	const function ensureParts()
		if not comPart or not comPart.Parent then
			if comPart then pcall(function() comPart:Destroy() end) end
			comPart = InstanceNew("Part")
			comPart.Shape = Enum.PartType.Ball
			comPart.Anchored = true
			comPart.CanCollide = false
			comPart.CanQuery = false
			comPart.CanTouch = false
			comPart.Massless = true
			comPart.CastShadow = false
			comPart.Material = Enum.Material.Glass
			comPart.Transparency = 0
			const sz = comRadius*2
			comPart.Size = Vector3.new(sz, sz, sz)
			comPart.Parent = Services.Workspace
		end
		if not comHL or not comHL.Parent or comHL.Adornee ~= comPart then
			if comHL then pcall(function() comHL:Destroy() end) end
			comHL = InstanceNew("Highlight")
			comHL.Adornee = comPart
			comHL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			comHL.FillTransparency = 0.25
			comHL.OutlineTransparency = 0
			comHL.FillColor = Color3.fromRGB(255, 255, 0)
			comHL.OutlineColor = Color3.fromRGB(255, 255, 0)
			comHL.Parent = comPart
		end
	end

	comConn = NAlib.reconnect("com_track", Services.RunService.Heartbeat:Connect(function()
		ensureParts()
		const char = getChar()
		const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		if root and root:IsDescendantOf(Services.Workspace) and comPart and comPart.Parent then
			const pos = root.AssemblyCenterOfMass or root.Position
			comPart.Anchored = true
			comPart.CanCollide = false
			comPart.Material = Enum.Material.Glass
			comPart.Transparency = 0
			const sz = comRadius*2
			if comPart.Size.X ~= sz then comPart.Size = Vector3.new(sz, sz, sz) end
			comPart.CFrame = CFrame.new(pos)
		end
	end))

end,true)

NAmanage.PredictionEnsureState = function()
	NAStuff.PredictionConfig = NAStuff.PredictionConfig or {
		color = Color3.fromRGB(255, 255, 0);
		radius = 0.35;
		defaultLead = 0.25;
		maxOffset = 40;
	}
	const state = NAStuff.PredictionState or {}
	NAStuff.PredictionState = state
	state.tracks = state.tracks or {}
	state.lastRuntimeErrorAt = tonumber(state.lastRuntimeErrorAt) or 0
	state.stats = state.stats or {}
	state.stats.tracked = tonumber(state.stats.tracked) or 0
	state.stats.visible = tonumber(state.stats.visible) or 0
	state.stats.missingCharacter = tonumber(state.stats.missingCharacter) or 0
	state.stats.missingRoot = tonumber(state.stats.missingRoot) or 0
	return state, NAStuff.PredictionConfig
end

NAmanage.PredictionOrbSize = function()
	local _, cfg = NAmanage.PredictionEnsureState()
	const radius = tonumber(cfg.radius) or 0.35
	const diameter = radius * 2
	return Vector3.new(diameter, diameter, diameter)
end

NAmanage.PredictionEnsureFolder = function()
	const RawWorkspace = __lt.gs("Workspace")
	const state = NAmanage.PredictionEnsureState()
	if state.folder and state.folder.Parent == RawWorkspace then
		return state.folder
	end
	if state.folder then
		pcall(function() state.folder:Destroy() end)
	end
	state.folder = InstanceNew("Folder")
	state.folder.Parent = Services.Workspace
	return state.folder
end

NAmanage.PredictionCreateOrb = function()
	local _, cfg = NAmanage.PredictionEnsureState()
	const orb = InstanceNew("Part")
	orb.Shape = Enum.PartType.Ball
	orb.Size = NAmanage.PredictionOrbSize()
	orb.Color = cfg.color
	orb.Material = Enum.Material.Glass
	orb.Transparency = 0
	orb.Anchored = true
	NAlib.setProperty(orb, "CanCollide", false)
	NAlib.setProperty(orb, "CanTouch", false)
	NAlib.setProperty(orb, "CanQuery", false)
	NAlib.setProperty(orb, "Massless", true)
	NAlib.setProperty(orb, "CastShadow", false)
	orb.Parent = NAmanage.PredictionEnsureFolder()

	const hl = InstanceNew("Highlight")
	hl.Adornee = orb
	hl.DepthMode = Enum.HighlightDepthMode.Occluded
	hl.FillTransparency = 0.25
	hl.OutlineTransparency = 0
	hl.FillColor = cfg.color
	hl.OutlineColor = cfg.color
	hl.Parent = orb

	return orb, hl
end

NAmanage.PredictionRootFromPlayer = function(plr)
	if not plr then
		return nil
	end
	const tchar = plr.Character
	if not tchar then
		return nil
	end
	local root = tchar:FindFirstChild("HumanoidRootPart")
		or getRoot(tchar)
		or tchar.PrimaryPart
		or tchar:FindFirstChildWhichIsA("BasePart")
	if not root then
		for _, inst in tchar:QueryDescendants("BasePart") do
			root = inst
			break
		end
	end
	if root and root:IsDescendantOf(Services.Workspace) then
		return root
	end
	return nil
end

NAmanage.PredictionResolvePlayer = function(userId, fallbackPlayer)
	const plr = fallbackPlayer
	if plr and plr.Parent and plr:IsDescendantOf(game) then
		return plr
	end
	const numericId = tonumber(userId) or (plr and tonumber(plr.UserId))
	if numericId then
		local ok, resolved = pcall(Services.Players.GetPlayerByUserId, Services.Players, numericId)
		if ok and resolved and resolved.Parent and resolved:IsDescendantOf(game) then
			return resolved
		end
	end
	return nil
end

NAmanage.PredictionEnsureEntry = function(userId, plr, lead)
	if userId == nil then
		return nil
	end
	local state, cfg = NAmanage.PredictionEnsureState()
	state.tracks = state.tracks or {}
	local entry = state.tracks[userId]
	if not entry then
		entry = {}
		state.tracks[userId] = entry
	end
	entry.player = plr
	entry.lead = tonumber(lead) or entry.lead or cfg.defaultLead
	if not entry.part or not entry.part.Parent then
		if entry.part then pcall(function() entry.part:Destroy() end) end
		if entry.hl then pcall(function() entry.hl:Destroy() end) end
		entry.part, entry.hl = NAmanage.PredictionCreateOrb()
	end
	return entry
end

NAmanage.PredictionDestroyEntry = function(userId)
	if userId == nil then return end
	const state = NAmanage.PredictionEnsureState()
	const entry = state.tracks and state.tracks[userId]
	if not entry then return end
	if entry.hl then pcall(function() entry.hl:Destroy() end) end
	if entry.part then pcall(function() entry.part:Destroy() end) end
	state.tracks[userId] = nil
end

NAmanage.PredictionStopIfEmpty = function()
	const state = NAmanage.PredictionEnsureState()
	if state.tracks and next(state.tracks) ~= nil then
		return
	end
	NAlib.disconnect("prediction_track")
	if state.conn then state.conn:Disconnect() state.conn=nil end
	if state.cleanupConn then state.cleanupConn:Disconnect() state.cleanupConn=nil end
	if state.folder and state.folder.Parent then
		pcall(function() state.folder:Destroy() end)
	end
	state.folder = nil
end

NAmanage.PredictionHeartbeatImpl = function()
	local state, cfg = NAmanage.PredictionEnsureState()
	const stale = {}
	local visible = 0
	local tracked = 0
	local missingCharacter = 0
	local missingRoot = 0
	for userId, entry in state.tracks do
		tracked += 1
		const plr = NAmanage.PredictionResolvePlayer(userId, entry and entry.player)
		if not plr then
			Insert(stale, userId)
		else
			entry.player = plr
			const refreshed = NAmanage.PredictionEnsureEntry(userId, plr, entry.lead)
			const troot = NAmanage.PredictionRootFromPlayer(plr)
			if refreshed and troot and refreshed.part and refreshed.part.Parent then
				const velocity = troot.AssemblyLinearVelocity or troot.Velocity or Vector3.new(0, 0, 0)
				const lead = tonumber(refreshed.lead) or cfg.defaultLead
				local offset = velocity * lead
				const maxOffset = tonumber(cfg.maxOffset) or 40
				if offset.Magnitude > maxOffset then
					offset = offset.Unit * maxOffset
				end
				const basePos = troot.AssemblyCenterOfMass or troot.Position
				const predicted = basePos + offset
				refreshed.part.CFrame = CFrame.new(predicted)
				refreshed.part.Transparency = 0
				if refreshed.hl then
					NAlib.setProperty(refreshed.hl, "Enabled", true)
				end
				visible += 1
			elseif refreshed and refreshed.part then
				refreshed.part.Transparency = 1
				if refreshed.hl then
					NAlib.setProperty(refreshed.hl, "Enabled", false)
				end
				if not plr.Character then
					missingCharacter += 1
				else
					missingRoot += 1
				end
			end
		end
	end

	for _, userId in stale do
		NAmanage.PredictionDestroyEntry(userId)
	end

	NAmanage.PredictionStopIfEmpty()
	state.stats.tracked = tracked
	state.stats.visible = visible
	state.stats.missingCharacter = missingCharacter
	state.stats.missingRoot = missingRoot
	return visible
end

NAmanage.PredictionHeartbeatSafe = function()
	const state = NAmanage.PredictionEnsureState()
	local ok, resultOrErr = pcall(NAmanage.PredictionHeartbeatImpl)
	if ok then
		return resultOrErr
	end
	const now = tick()
	if now - state.lastRuntimeErrorAt >= 2 then
		state.lastRuntimeErrorAt = now
		warn("[NA predict] "..tostring(resultOrErr))
		DoNotif("Predict runtime error (see console).", 2, "Prediction")
	end
	return 0
end

NAmanage.PredictionEnsureLoop = function()
	const state = NAmanage.PredictionEnsureState()
	if not state.cleanupConn then
		state.cleanupConn = Services.Players.PlayerRemoving:Connect(function(plr)
			NAmanage.PredictionDestroyEntry(plr.UserId)
			NAmanage.PredictionStopIfEmpty()
		end)
	end
	if not state.conn then
		state.conn = NAlib.reconnect("prediction_track", Services.RunService.Heartbeat:Connect(NAmanage.PredictionHeartbeatSafe))
	end
end

cmd.add({"predict"},{"predict <player> [leadSeconds]","Visualize predicted player movement"},function(target, leadSeconds)
	local state, cfg = NAmanage.PredictionEnsureState()
	local resolvedTarget = target
	local resolvedLead = tonumber(leadSeconds)
	if resolvedLead == nil and type(target) == "string" and tonumber(target) and (leadSeconds == nil or leadSeconds == "") then
		resolvedLead = tonumber(target)
		resolvedTarget = nil
	end

	state.lead = math.clamp(resolvedLead or state.lead or cfg.defaultLead, 0, 3)

	const targets = (not resolvedTarget or resolvedTarget == "") and getPlr("others") or getPlr(resolvedTarget)
	if not targets or #targets == 0 then
		DoNotif("Player not found.", 2, "Prediction")
		return
	end

	local added = 0
	for _, plr in targets do
		if plr and plr ~= Services.Players.LocalPlayer then
			const entry = NAmanage.PredictionEnsureEntry(plr.UserId, plr, state.lead)
			if entry then
				added += 1
			end
		end
	end

	if added == 0 then
		DoNotif("No valid targets to predict.", 2, "Prediction")
		return
	end

	NAmanage.PredictionEnsureLoop()
	const visible = NAmanage.PredictionHeartbeatSafe() or 0
	local tracked = state.stats.tracked or 0
	if tracked <= 0 then
		tracked = state.tracks and (function()
			local count = 0
			for _ in state.tracks do
				count += 1
			end
			return count
		end)() or 0
	end
	if visible <= 0 and tracked > 0 then
		DoNotif(
			Format(
				"Movement visualizer active: %d target(s), %d visible predicted orb(s). (no char: %d, no root: %d)",
				tracked,
				visible,
				state.stats.missingCharacter or 0,
				state.stats.missingRoot or 0
			),
			3,
			"Prediction"
		)
	else
		DoNotif(Format("Movement visualizer active: %d target(s), %d visible predicted orb(s).", tracked, visible), 2, "Prediction")
	end
end)

cmd.add({"unpredict"},{"unpredict <player>","Remove prediction orb"},function(target)
	const state = NAmanage.PredictionEnsureState()
	state.tracks = state.tracks or {}
	local removed = 0

	if target and target ~= "" then
		const list = getPlr(target)
		if not list or #list == 0 then
			DoNotif("Player not found.", 2, "Prediction")
			return
		end
		for _, plr in list do
			const userId = plr and plr.UserId
			if userId and state.tracks[userId] then
				removed += 1
			end
			NAmanage.PredictionDestroyEntry(userId)
		end
	else
		for userId in state.tracks do
			removed += 1
			NAmanage.PredictionDestroyEntry(userId)
		end
	end

	NAmanage.PredictionStopIfEmpty()
	DoNotif(Format("Removed %d prediction orb(s).", removed), 2, "Prediction")
end)

cmd.add({"hidecom","unshowcom","uncom"},{"hidecom","Remove COM tracker"},function()
	NAlib.disconnect("com_track")
	if comConn then comConn:Disconnect() comConn=nil end
	if comHL then pcall(function() comHL:Destroy() end) comHL=nil end
	if comPart then pcall(function() comPart:Destroy() end) comPart=nil end
end)

NAmanage.canDropTool=function(tool)
	if not (tool and tool:IsA("Tool")) then
		return false
	end

	local ok, val = pcall(function()
		return tool.CanBeDropped
	end)

	return ok and val == true
end

NAmanage.waitToolParent=function(tool, parent, tries, step)
	tries = tonumber(tries) or 10
	step = tonumber(step) or 0.035

	for _ = 1, tries do
		if tool and tool.Parent == parent then
			return true
		end
		Wait(step)
	end

	return tool and tool.Parent == parent
end

NAmanage.waitDropParent=function(tool, parent, tries, step)
	tries = tries or 20
	step = step or 0.045

	for _ = 1, tries do
		if not (tool and tool.Parent) then
			return false
		end

		if tool.Parent == parent then
			return true
		end

		Wait(step)
	end

	return tool and tool.Parent == parent
end

NAmanage.dropToolStep=function(tool, character, backpack, done)
	const RawWorkspace = __lt.gs("Workspace")
	if type(done) ~= "function" then
		done = function() end
	end

	character = character or getChar()
	backpack = backpack or getBp()

	if not (tool and tool.Parent and character) then
		done(false)
		return false
	end

	if not NAmanage.canDropTool(tool) then
		done(false)
		return false
	end

	if tool.Parent ~= character and not (backpack and tool.Parent == backpack) then
		done(false)
		return false
	end

	if tool.Parent ~= character then
		NACaller(function()
			tool.Parent = character
		end)
		Wait()
	end

	NACaller(function()
		tool.Parent = Services.Workspace
	end)

	const dropped = tool.Parent == RawWorkspace
	done(dropped)
	return dropped
end

NAmanage.dropToolFast=function(tool, character, backpack)
	return NAmanage.dropToolStep(tool, character, backpack, function() end)
end

NAmanage.dropToolSafe=function(tool, character, backpack)
	return NAmanage.dropToolStep(tool, character or getChar(), backpack or getBp(), function() end)
end

NAmanage.collectDropTools=function(from, queue, seen, skip)
	if not from then
		return
	end

	for _, tool in from:GetChildren() do
		if NAmanage.canDropTool(tool) and not seen[tool] and not (skip and skip[tool]) then
			seen[tool] = true
			Insert(queue, tool)
		end
	end
end

NAmanage.buildDropQueue=function(character, backpack, skip)
	const seen = {}
	const queue = {}

	NAmanage.collectDropTools(character, queue, seen, skip)
	NAmanage.collectDropTools(backpack, queue, seen, skip)

	return queue
end

NAmanage.findNextDropTool=function(character, backpack, skip)
	const queue = NAmanage.buildDropQueue(character, backpack, skip)
	return queue[1]
end

NAmanage.isToolDropReady=function(tool, character, backpack)
	if not (tool and tool.Parent and character) then
		return false
	end

	if not NAmanage.canDropTool(tool) then
		return false
	end

	return tool.Parent == character or tool.Parent == backpack
end

NAmanage.dropOneTool=function(skip, done)
	const backpack = getBp()
	const character = getChar()
	if not character then
		if type(done) == "function" then done(false) end
		return false, "Character not available"
	end

	const tool = NAmanage.findNextDropTool(character, backpack, skip)
	if tool then
		return NAmanage.dropToolStep(tool, character, backpack, done), tool.Name, tool
	end

	if type(done) == "function" then done(false) end
	return false, "No droppable tool found"
end

NAmanage.dropQueueStep=function(queue, index, state)
	state = state or {}
	index = index or 1

	const tool = queue and queue[index]
	if not tool then
		state.done = true
		if type(state.doneFn) == "function" then
			state.doneFn(state)
		end
		return
	end

	const character = getChar()
	const backpack = getBp()

	if character and NAmanage.isToolDropReady(tool, character, backpack) then
		NAmanage.dropToolStep(tool, character, backpack, function(ok)
			if ok then
				state.dropped = (state.dropped or 0) + 1
			else
				state.failed = (state.failed or 0) + 1
			end

			Defer(function()
				NAmanage.dropQueueStep(queue, index + 1, state)
			end)
		end)
	else
		state.failed = (state.failed or 0) + 1
		Defer(function()
			NAmanage.dropQueueStep(queue, index + 1, state)
		end)
	end
end

NAmanage.dropAllToolsSafe=function(done)
	const RawWorkspace = __lt.gs("Workspace")
	const backpack = getBp()
	const character = getChar()
	if not character then
		if type(done) == "function" then done({dropped = 0, failed = 0, done = true}) end
		return 0, "Character not available"
	end

	const queue = NAmanage.buildDropQueue(character, backpack)
	if #queue == 0 then
		if type(done) == "function" then done({dropped = 0, failed = 0, done = true}) end
		return 0, "No droppable tools found"
	end

	const hum = getHum(character)
	if hum and hum:IsA("Humanoid") then
		pcall(function()
			hum:UnequipTools()
		end)
	end

	local dropped = 0
	local failed = 0
	for _, tool in queue do
		if tool and tool.Parent and tool.Parent ~= RawWorkspace and NAmanage.canDropTool(tool) then
			if tool.Parent ~= character then
				NACaller(function()
					tool.Parent = character
				end)
				Wait()
			end

			NACaller(function()
				tool.Parent = Services.Workspace
			end)

			if tool.Parent == RawWorkspace then
				dropped += 1
			else
				failed += 1
			end
		else
			failed += 1
		end
	end

	const state = {
		dropped = dropped,
		failed = failed,
		done = true
	}

	if type(done) == "function" then
		done(state)
	end

	if dropped > 0 then
		return dropped
	end

	return 0, "No droppable tools found"
end
cmd.add({"droptool","dropatool","dtool"}, {"droptool", "Drop one of your tools"}, function()
	local ok, info = NAmanage.dropOneTool()
	if ok then
		DebugNotif("Dropped: "..tostring(info), 4)
	else
		DebugNotif(tostring(info or "No droppable tool found"), 4)
	end
end)

cmd.add({"droptools"}, {"dropalltools", "Drop all of your tools"}, function()
	local dropped, err = NAmanage.dropAllToolsSafe()
	if dropped and dropped > 0 then
		DebugNotif("Dropped "..dropped.." tool(s)", 4)
	else
		DebugNotif(err or "No droppable tools found", 4)
	end
end)

cmd.add({"loopdroptools","loopdrop","ldtools","ldtls"}, {"loopdroptools", "Loop drops your tools"}, function()
	if loopdrop then
		DebugNotif("Loop drop already running", 2)
		return
	end

	loopdrop = true
	DebugNotif("Started loop dropping tools", 2)
	SpawnCall(function()
		while loopdrop do
			if not NAmanage.dropBusy then
				NAmanage.dropBusy = true
				local ok, count = pcall(function()
					return NAmanage.dropAllToolsSafe(function()
						NAmanage.dropBusy = false
					end)
				end)

				if not ok or not count or count <= 0 then
					NAmanage.dropBusy = false
				end
			end
			Wait(0.2)
		end
		NAmanage.dropBusy = false
		DebugNotif("Stopped loop dropping tools", 2)
	end)
end)

cmd.add({"unloopdroptools","unloopdrop","unldtools","unldtls"}, {"unloopdroptools", "Stops loop dropping tools"}, function()
	if not loopdrop then
		DebugNotif("Loop drop is not running", 2)
		return
	end
	loopdrop = false
end)

cmd.add({"notools"},{"notools","Remove your tools"},function()
	for _,tool in NAmanage.QueryDescendants(getChar(), "Tool") do
		tool:Destroy()
	end
	for _,tool in NAmanage.QueryDescendants(getBp(), "Tool") do
		tool:Destroy()
	end
end)

-- leg resize sureeee
cmd.addPatched({"breaklayeredclothing","blc"},{"breaklayeredclothing (blc)","Streches your layered clothing"},function()
	Wait();

	DoNotif("Break layered clothing executed,if you havent already equip shirt,jacket,pants and shoes (Layered Clothing ones)")
	local swimming=false
	oldgrav=Services.Workspace.Gravity
	Services.Workspace.Gravity=0
	const char=getChar()
	const swimDied=function()
		Services.Workspace.Gravity=oldgrav
		swimming=false
	end
	Humanoid=char:FindFirstChildWhichIsA("Humanoid")
	gravReset=NAmanage.ConnectHumanoidDeath(Humanoid, swimDied)
	enums=Enum.HumanoidStateType:GetEnumItems()
	table.remove(enums,Discover(enums,Enum.HumanoidStateType.None))
	for i,v in enums do
		Humanoid:SetStateEnabled(v,false)
	end
	Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	swimbeat=NAlib.reconnect("breaklayeredclothing_swimbeat", Services.RunService.Heartbeat:Connect(function()
		pcall(function()
			getRoot(char).Velocity=((Humanoid.MoveDirection~=Vector3.new(0, 0, 0) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.Space)) and getRoot(char).Velocity or Vector3.new(0, 0, 0))
		end)
	end))
	swimming=true
	Clip=false
	Wait(0.1)
	function NoclipLoop()
		if Clip==false and char~=nil then
			for _,child in char:QueryDescendants("BasePart") do
				if child.CanCollide==true then
					child.CanCollide=false
				end
			end
		end
	end
	Noclipping=NAlib.reconnect("breaklayeredclothing_noclip", Services.RunService.PreSimulation:Connect(NoclipLoop))
	NAmanage.RunURL('https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/leg%20resize')
end)

cmd.add({"fpsbooster","lowgraphics","boostfps","lowg","antilag","boostfps"}, {"fpsbooster","Enables maximum-performance low graphics mode, run again to restore"}, function()
	if _na_env.NA_FPS_ACTIVE then
		_na_env.NA_FPS_ACTIVE = false;
		if _na_env.NA_FPS_UNHOOK then
			_na_env.NA_FPS_UNHOOK();
		end;
		return;
	end;
	const w = Services.Workspace;
	const st = NAmanage and NAmanage._ensureL and NAmanage._ensureL() or {
		safeGet = function(i, p)
			local ok, v = pcall(function()
				return i[p];
			end);
			return ok and v or nil;
		end,
		safeSet = function(i, p, v)
			NAlib.setProperty(i, p, v);
		end
	};
	const opt = opt or {
		hiddenprop = function()
		end
	};
	const fpsOpt = NAStuff.FPSBoostOptions or {};
	const function boolOpt(v, default)
		if v == nil then
			return default;
		end;
		if type(v) == "boolean" then
			return v;
		end;
		if type(v) == "string" then
			const l = v:lower();
			if l == "false" or l == "0" or l == "off" or l == "nil" then
				return false;
			end;
			if l == "true" or l == "1" or l == "on" then
				return true;
			end;
		end;
		if type(v) == "number" then
			return v ~= 0;
		end;
		return v ~= false;
	end;
	const effectDestroy = type(fpsOpt.effectMode) == "string" and fpsOpt.effectMode:lower() == "destroy";
	const stripParticles = boolOpt(fpsOpt.stripParticles, true);
	const stripDecals = boolOpt(fpsOpt.stripDecals, true);
	const stripTextures = boolOpt(fpsOpt.stripTextures, true);
	const stripLights = boolOpt(fpsOpt.stripLights, true);
	const stripPostFx = boolOpt(fpsOpt.stripPostFx, true);
	const stripAtmosphere = boolOpt(fpsOpt.stripAtmosphere, true);
	const stripSurfaceAppearance = boolOpt(fpsOpt.stripSurfaceAppearance, true);
	const stripHighlights = boolOpt(fpsOpt.stripHighlights, true);
	const stripExplosions = boolOpt(fpsOpt.stripExplosions, true);
	const simplifyMaterials = boolOpt(fpsOpt.simplifyMaterials, true);
	const zeroReflectance = boolOpt(fpsOpt.zeroReflectance, true);
	const forceStreaming = boolOpt(fpsOpt.forceStreaming, true);
	const flattenLighting = boolOpt(fpsOpt.flattenLighting, true);
	const streamRadius = math.clamp(tonumber(fpsOpt.streamRadius) or 96, 16, 4096);
	const ignorePlayers = boolOpt(fpsOpt.ignorePlayers, true);
	const ignoreSelf = boolOpt(fpsOpt.ignoreSelf, true);
	const function setHiddenOrNormal(inst, prop, val)
		local ok = false;
		if opt and opt.hiddenprop then
			ok = pcall(function()
				opt.hiddenprop(inst, prop, val);
			end);
		end;
		if not ok then
			st.safeSet(inst, prop, val);
		end;
	end;
	local active = false;
	local cons = {};
	local watchers = {};
	const function connect(sig, fn)
		const c = fn and sig:Connect(fn) or sig;
		if c then
			Insert(cons, c);
		end;
		return c;
	end;
	const function disconnectAll()
		for _, c in cons do
			pcall(function()
				c:Disconnect();
			end);
		end;
		cons = {};
		watchers = {};
	end;
	const function forceProperty(inst, prop, desired)
		if not inst then
			return;
		end;
		if not active then
			return;
		end;
		const current = st.safeGet(inst, prop);
		if current ~= nil and current ~= desired then
			st.safeSet(inst, prop, desired);
		end;
	end;
	const A = "NA_FPS_";
	const function remember(inst, prop, val)
		const key = A .. prop;
		if NAmanage.GetAttr(inst, key) == nil then
			if typeof(val) == "EnumItem" then
				NAmanage.SetAttr(inst, key, val.Name);
			else
				NAmanage.SetAttr(inst, key, val);
			end;
		end;
	end;
	const function recall(inst, prop)
		return NAmanage.GetAttr(inst, A .. prop);
	end;
	const function clearAttr(inst, prop)
		NAmanage.SetAttr(inst, A .. prop, nil);
	end;
	const function getCharacterModel(inst)
		local a = inst;
		while a do
			if a:IsA("Model") and a:FindFirstChildOfClass("Humanoid") then
				return a;
			end;
			a = a.Parent;
		end;
		return nil;
	end;
	const function playerFromCharacter(model)
		local ok, plr = pcall(function()
			return __lt.cm("Players", "GetPlayerFromCharacter", model);
		end);
		if ok then
			return plr;
		end;
		return nil;
	end;
	const function isClothingLike(inst)
		return inst:IsA("Shirt") or inst:IsA("Pants") or inst:IsA("ShirtGraphic") or inst:IsA("Accessory") or inst:IsA("Clothing") or inst:IsA("HumanoidDescription");
	end;
	const originals = {
		quality = nil,
		lighting = {},
		terrain = {},
		Workspace = {},
		postFx = {},
		postFxCam = {}
	};
	const function snapshotEnv()
		if originals.quality == nil then
			pcall(function()
				originals.quality = (settings()).Rendering.QualityLevel;
			end);
		end;
		for _, p in {
			"GlobalShadows",
			"FogEnd",
			"Brightness",
			"Ambient",
			"OutdoorAmbient",
			"LightingStyle",
			"Technology"
			} do
			if originals.lighting[p] == nil then
				originals.lighting[p] = st.safeGet(Services.Lighting, p);
			end;
		end;
		for _, e in __lt.cm("Lighting", "GetChildren") do
			if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("Atmosphere") then
				if originals.postFx[e] == nil then
					const en = st.safeGet(e, "Enabled");
					originals.postFx[e] = en == nil and true or en;
				end;
			end;
		end;
		const cam = w.CurrentCamera;
		if cam then
			for _, e in cam:GetChildren() do
				if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") or e:IsA("Atmosphere") then
					if originals.postFxCam[e] == nil then
						const en = st.safeGet(e, "Enabled");
						originals.postFxCam[e] = en == nil and true or en;
					end;
				end;
			end;
		end;
		const T = w:FindFirstChildOfClass("Terrain");
		if T then
			for _, p in {
				"Decoration",
				"WaterWaveSize",
				"WaterWaveSpeed",
				"WaterReflectance",
				"WaterTransparency"
				} do
				if originals.terrain[p] == nil then
					originals.terrain[p] = st.safeGet(T, p);
				end;
			end;
		end;
		for _, p in {
			"StreamingEnabled",
			"StreamingPauseMode",
			"StreamOutBehavior",
			"TargetRadius"
			} do
			if originals.Workspace[p] == nil then
				originals.Workspace[p] = st.safeGet(w, p);
			end;
		end;
	end;
	const function applyEnv()
		if flattenLighting or simplifyMaterials then
			pcall(function()
				(settings()).Rendering.QualityLevel = Enum.QualityLevel.Level01;
			end);
		end;
		if flattenLighting then
			st.safeSet(Services.Lighting, "GlobalShadows", false);
			st.safeSet(Services.Lighting, "FogEnd", math.huge);
			st.safeSet(Services.Lighting, "Brightness", 0);
			st.safeSet(Services.Lighting, "Ambient", Color3.new(0.4, 0.4, 0.4));
			st.safeSet(Services.Lighting, "OutdoorAmbient", Color3.new(0.4, 0.4, 0.4));
			setHiddenOrNormal(Services.Lighting, "LightingStyle", Enum.LightingStyle.Soft);
			setHiddenOrNormal(Services.Lighting, "Technology", Enum.Technology.Compatibility);
		end;
		const T = w:FindFirstChildOfClass("Terrain");
		if T and simplifyMaterials then
			st.safeSet(T, "Decoration", false);
			st.safeSet(T, "WaterWaveSize", 0);
			st.safeSet(T, "WaterWaveSpeed", 0);
			st.safeSet(T, "WaterReflectance", 0);
			st.safeSet(T, "WaterTransparency", 0);
		end;
		if forceStreaming then
			st.safeSet(w, "StreamingEnabled", true);
			pcall(function()
				w.StreamOutBehavior = Enum.StreamOutBehavior.LowMemory or Enum.StreamOutBehavior.Default;
			end);
			st.safeSet(w, "StreamingPauseMode", Enum.StreamingPauseMode.Default);
			st.safeSet(w, "TargetRadius", streamRadius);
		end;
		if stripPostFx then
			for _, e in __lt.cm("Lighting", "GetChildren") do
				if e:IsA("PostEffect") then
					st.safeSet(e, "Enabled", false);
				end;
			end;
			const cam = w.CurrentCamera;
			if cam then
				for _, e in cam:GetChildren() do
					if e:IsA("PostEffect") then
						st.safeSet(e, "Enabled", false);
					end;
				end;
			end;
		end;
	end;
	const function restoreEnv()
		pcall(function()
			if originals.quality ~= nil then
				(settings()).Rendering.QualityLevel = originals.quality;
			end;
		end);
		for p, v in originals.lighting do
			if v ~= nil then
				if p == "LightingStyle" then
					setHiddenOrNormal(Services.Lighting, p, typeof(v) == "EnumItem" and v or Enum.LightingStyle[v] or Enum.LightingStyle.Soft);
				elseif p == "Technology" then
					setHiddenOrNormal(Services.Lighting, p, typeof(v) == "EnumItem" and v or Enum.Technology[v] or Enum.Technology.Compatibility);
				else
					st.safeSet(Services.Lighting, p, v);
				end;
			end;
		end;
		for e, wasEnabled in originals.postFx do
			if e and e.Parent and st.safeGet(e, "Enabled") ~= nil then
				st.safeSet(e, "Enabled", wasEnabled);
			end;
		end;
		for e, wasEnabled in originals.postFxCam do
			if e and e.Parent and st.safeGet(e, "Enabled") ~= nil then
				st.safeSet(e, "Enabled", wasEnabled);
			end;
		end;
		const T = w:FindFirstChildOfClass("Terrain");
		if T then
			for p, v in originals.terrain do
				if v ~= nil then
					st.safeSet(T, p, v);
				end;
			end;
		end;
		for p, v in originals.Workspace do
			if v ~= nil then
				st.safeSet(w, p, v);
			end;
		end;
	end;
	const function optimizeInstance(inst)
		if not active then
			return
		end

		const cm = getCharacterModel(inst)
		if cm then
			local isNPC = false
			if CheckIfNPC then
				local ok, r = pcall(CheckIfNPC, cm)
				if ok and r then
					isNPC = true
				end
			end
			if not isNPC then
				const pl = playerFromCharacter(cm)
				if pl then
					if ignoreSelf and pl == Services.Players.LocalPlayer then
						return
					end
					if ignorePlayers and pl ~= Services.Players.LocalPlayer then
						return
					end
				end
			end
		end

		if isClothingLike(inst) then
			return
		end

		const isParticle = inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") or inst:IsA("Beam")
		const isLight = inst:IsA("PointLight") or inst:IsA("SurfaceLight") or inst:IsA("SpotLight")
		const isSurfApp = inst:IsA("SurfaceAppearance")
		const isHighlight = inst:IsA("Highlight")
		const isPost = inst:IsA("PostEffect")
		const isAtmos = inst:IsA("Atmosphere")
		const isExplosion = inst:IsA("Explosion")

		if inst:IsA("BasePart") and simplifyMaterials then
			remember(inst, "Material", inst.Material)
			remember(inst, "MaterialVariant", st.safeGet(inst, "MaterialVariant"))
			remember(inst, "Reflectance", inst.Reflectance)
			remember(inst, "CastShadow", inst.CastShadow)

			const dMat = Enum.Material.Plastic
			const cMat = inst.Material
			const cVar = st.safeGet(inst, "MaterialVariant")
			const matChanged = cMat ~= dMat
			const varChanged = cVar ~= "" and cVar ~= nil

			st.safeSet(inst, "Material", dMat)
			st.safeSet(inst, "MaterialVariant", "")

			if zeroReflectance then
				st.safeSet(inst, "Reflectance", 0)
				forceProperty(inst, "Reflectance", 0)
			end

			st.safeSet(inst, "CastShadow", false)
			forceProperty(inst, "CastShadow", false)

			if matChanged then
				forceProperty(inst, "Material", dMat)
			end
			if varChanged then
				forceProperty(inst, "MaterialVariant", "")
			end
		end

		if stripTextures and inst:IsA("MeshPart") then
			const tx = st.safeGet(inst, "TextureID")
			if tx ~= nil and tx ~= "" then
				remember(inst, "TextureID", tx)
				st.safeSet(inst, "TextureID", "")
				forceProperty(inst, "TextureID", "")
			end
		end

		if stripTextures and inst:IsA("SpecialMesh") then
			const tx = st.safeGet(inst, "TextureId")
			if tx ~= nil and tx ~= "" then
				remember(inst, "TextureId", tx)
				st.safeSet(inst, "TextureId", "")
				forceProperty(inst, "TextureId", "")
			end
		end

		if stripDecals and inst:IsA("Decal") then
			const t = inst.Transparency
			remember(inst, "Transparency", t)
			st.safeSet(inst, "Transparency", 1)
			forceProperty(inst, "Transparency", 1)
		end

		if stripTextures and inst:IsA("Texture") then
			const t = inst.Transparency
			remember(inst, "Transparency", t)
			st.safeSet(inst, "Transparency", 1)
			forceProperty(inst, "Transparency", 1)
		end

		if stripParticles and isParticle then
			if effectDestroy then
				pcall(function()
					inst:Destroy()
				end)
				return
			end
			const en = st.safeGet(inst, "Enabled")
			if en ~= nil then
				remember(inst, "Enabled", en)
				st.safeSet(inst, "Enabled", false)
				forceProperty(inst, "Enabled", false)
			end
			if inst:IsA("ParticleEmitter") then
				const rate = st.safeGet(inst, "Rate")
				if rate ~= nil then
					remember(inst, "Rate", rate)
					st.safeSet(inst, "Rate", 0)
					forceProperty(inst, "Rate", 0)
				end
				pcall(function()
					inst:Clear()
				end)
			elseif inst:IsA("Trail") then
				pcall(function()
					if inst.Clear then
						inst:Clear()
					end
				end)
			end
		end

		if stripLights and isLight then
			if effectDestroy then
				pcall(function()
					inst:Destroy()
				end)
				return
			end
			const en = st.safeGet(inst, "Enabled")
			if en ~= nil then
				remember(inst, "Enabled", en)
				st.safeSet(inst, "Enabled", false)
				forceProperty(inst, "Enabled", false)
			end
		end

		if stripSurfaceAppearance and isSurfApp then
			if effectDestroy then
				pcall(function()
					inst:Destroy()
				end)
				return
			end
			const en = st.safeGet(inst, "Enabled")
			if en ~= nil then
				remember(inst, "Enabled", en)
				st.safeSet(inst, "Enabled", false)
				forceProperty(inst, "Enabled", false)
			end
		end

		if stripHighlights and isHighlight then
			if effectDestroy then
				pcall(function()
					inst:Destroy()
				end)
				return
			end
			const en = st.safeGet(inst, "Enabled")
			if en ~= nil then
				remember(inst, "Enabled", en)
				st.safeSet(inst, "Enabled", false)
				forceProperty(inst, "Enabled", false)
			end
		end

		if stripPostFx and isPost then
			if effectDestroy then
				pcall(function()
					inst:Destroy()
				end)
				return
			end
			const en = st.safeGet(inst, "Enabled")
			if en ~= nil then
				remember(inst, "Enabled", en)
				forceProperty(inst, "Enabled", false)
			end
		end

		if stripAtmosphere and isAtmos then
			if effectDestroy then
				pcall(function()
					inst:Destroy()
				end)
				return
			end
			const d = st.safeGet(inst, "Density")
			if d ~= nil then
				remember(inst, "Density", d)
				forceProperty(inst, "Density", 0)
			end
			const h = st.safeGet(inst, "Haze")
			if h ~= nil then
				remember(inst, "Haze", h)
				forceProperty(inst, "Haze", 0)
			end
			const g = st.safeGet(inst, "Glare")
			if g ~= nil then
				remember(inst, "Glare", g)
				forceProperty(inst, "Glare", 0)
			end
		end

		if stripExplosions and isExplosion then
			if effectDestroy then
				pcall(function()
					inst:Destroy()
				end)
				return
			end
			remember(inst, "BlastPressure", inst.BlastPressure)
			remember(inst, "BlastRadius", inst.BlastRadius)
			st.safeSet(inst, "BlastPressure", 1)
			st.safeSet(inst, "BlastRadius", 1)
			forceProperty(inst, "BlastPressure", 1)
			forceProperty(inst, "BlastRadius", 1)
		end
	end
	const function restoreInstance(inst)
		if inst:IsA("BasePart") then
			const m = recall(inst, "Material");
			if m ~= nil then
				st.safeSet(inst, "Material", Enum.Material[m] or inst.Material);
				clearAttr(inst, "Material");
			end;
			const mv = recall(inst, "MaterialVariant");
			if mv ~= nil then
				st.safeSet(inst, "MaterialVariant", mv);
				clearAttr(inst, "MaterialVariant");
			end;
			const r = recall(inst, "Reflectance");
			if r ~= nil then
				st.safeSet(inst, "Reflectance", r);
				clearAttr(inst, "Reflectance");
			end;
			const cs = recall(inst, "CastShadow");
			if cs ~= nil then
				st.safeSet(inst, "CastShadow", cs);
				clearAttr(inst, "CastShadow");
			end;
			if inst:IsA("MeshPart") then
				const tx = recall(inst, "TextureID");
				if tx ~= nil then
					st.safeSet(inst, "TextureID", tx);
					clearAttr(inst, "TextureID");
				end;
			end;
		end;
		if inst:IsA("SpecialMesh") then
			const t = recall(inst, "TextureId");
			if t ~= nil then
				st.safeSet(inst, "TextureId", t);
				clearAttr(inst, "TextureId");
			end;
		end;
		if inst:IsA("Decal") or inst:IsA("Texture") then
			const t = recall(inst, "Transparency");
			if t ~= nil then
				st.safeSet(inst, "Transparency", t);
				clearAttr(inst, "Transparency");
			end;
		end;
		if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
			const e = recall(inst, "Enabled");
			if e ~= nil then
				st.safeSet(inst, "Enabled", e);
				clearAttr(inst, "Enabled");
			end;
		end;
		if inst:IsA("ParticleEmitter") then
			const r = recall(inst, "Rate");
			if r ~= nil then
				st.safeSet(inst, "Rate", r);
				clearAttr(inst, "Rate");
			end;
		end;
		if inst:IsA("Beam") then
			const e = recall(inst, "Enabled");
			if e ~= nil then
				st.safeSet(inst, "Enabled", e);
				clearAttr(inst, "Enabled");
			end;
		end;
		if inst:IsA("PointLight") or inst:IsA("SurfaceLight") or inst:IsA("SpotLight") then
			const e = recall(inst, "Enabled");
			if e ~= nil then
				st.safeSet(inst, "Enabled", e);
				clearAttr(inst, "Enabled");
			end;
		end;
		if inst:IsA("SurfaceAppearance") or inst:IsA("Highlight") then
			const e = recall(inst, "Enabled");
			if e ~= nil then
				st.safeSet(inst, "Enabled", e);
				clearAttr(inst, "Enabled");
			end;
		end;
		if inst:IsA("PostEffect") then
			const e = recall(inst, "Enabled");
			if e ~= nil then
				st.safeSet(inst, "Enabled", e);
				clearAttr(inst, "Enabled");
			end;
		end;
		if inst:IsA("Atmosphere") then
			const d = recall(inst, "Density");
			if d ~= nil then
				st.safeSet(inst, "Density", d);
				clearAttr(inst, "Density");
			end;
			const h = recall(inst, "Haze");
			if h ~= nil then
				st.safeSet(inst, "Haze", h);
				clearAttr(inst, "Haze");
			end;
			const g = recall(inst, "Glare");
			if g ~= nil then
				st.safeSet(inst, "Glare", g);
				clearAttr(inst, "Glare");
			end;
		end;
		if inst:IsA("Explosion") then
			const bp = recall(inst, "BlastPressure");
			if bp ~= nil then
				st.safeSet(inst, "BlastPressure", bp);
				clearAttr(inst, "BlastPressure");
			end;
			const br = recall(inst, "BlastRadius");
			if br ~= nil then
				st.safeSet(inst, "BlastRadius", br);
				clearAttr(inst, "BlastRadius");
			end;
		end;
	end;

	const function getChildrenSafe(inst)
		local ok, ch = pcall(inst.GetChildren, inst);
		return ok and ch or {};
	end;

	const function safeOptimize(inst)
		pcall(optimizeInstance, inst);
	end;

	const function safeRestore(inst)
		pcall(restoreInstance, inst);
	end;

	const function optimizeSubtree(root)
		const q = getChildrenSafe(root);
		local qi, qn = 1, #q;
		const step = 256;
		local n = 0;
		while qi <= qn do
			const inst = q[qi];
			qi = qi + 1;
			const ch = getChildrenSafe(inst);
			safeOptimize(inst);
			for i = 1, #ch do
				qn = qn + 1;
				q[qn] = ch[i];
			end;
			n = n + 1;
			if n >= step then
				n = 0;
				Wait();
			end;
		end;
	end;

	const function handleAdded(inst)
		if not inst then
			return;
		end;
		safeOptimize(inst);
		if inst:IsA("Attachment") or inst:IsA("BasePart") then
			optimizeSubtree(inst);
		end;
	end;

	const function sweepAll()
		const root = w;
		if not root then
			return;
		end;
		const q = {
			root
		};
		local qi, qn = 1, 1;
		const step = 256;
		local n = 0;
		while qi <= qn do
			const inst = q[qi];
			qi = qi + 1;
			const ch = getChildrenSafe(inst);
			safeOptimize(inst);
			for i = 1, #ch do
				qn = qn + 1;
				q[qn] = ch[i];
			end;
			n = n + 1;
			if n >= step then
				n = 0;
				Wait();
			end;
		end;
	end;
	const function restoreAll()
		const root = w;
		if not root then
			return;
		end;
		const q = {
			root
		};
		local qi, qn = 1, 1;
		const step = 256;
		local n = 0;
		while qi <= qn do
			const inst = q[qi];
			qi = qi + 1;
			const ch = getChildrenSafe(inst);
			safeRestore(inst);
			for i = 1, #ch do
				qn = qn + 1;
				q[qn] = ch[i];
			end;
			n = n + 1;
			if n >= step then
				n = 0;
				Wait();
			end;
		end;
	end;
	const function enable()
		if active then
			return;
		end;
		active = true;
		snapshotEnv();

		connect(NAmanage.descAdd(w, handleAdded));
		connect(NAmanage.descAdd(Services.Lighting, handleAdded));

		const camSeen = {};
		const function hookCamera(cam)
			if not cam or camSeen[cam] then
				return;
			end;
			camSeen[cam] = true;
			for _, e in getChildrenSafe(cam) do
				handleAdded(e);
			end;
			connect(cam.ChildAdded, function(e)
				handleAdded(e);
			end);
		end;
		connect(w:GetPropertyChangedSignal("CurrentCamera"), function()
			hookCamera(w.CurrentCamera);
		end);
		hookCamera(w.CurrentCamera);

		applyEnv();

		if effectDestroy then
			DoNotif("FPSBooster destroy mode: effects are removed until you rejoin", 3);
		end;

		for _, v in NAmanage.QueryDescendants(Services.Lighting, "Instance") do
			safeOptimize(v);
		end;
		sweepAll();
	end;
	const function disable()
		if not active then
			return;
		end;
		active = false;
		disconnectAll();
		restoreAll();
		restoreEnv();
	end;
	_na_env.NA_FPS_UNHOOK = function()
		disable();
		_na_env.NA_FPS_UNHOOK = nil;
	end;
	enable();
	_na_env.NA_FPS_ACTIVE = true;
end);

NAStuff.annoyLoop = false

cmd.add({"annoy"}, {"annoy <player|npc:filter>", "Annoys the given player or NPC"}, function(...)
	if NAStuff.annoyLoop then
		DoNotif("Already annoying someone. Use :unannoy first.", 3)
		return
	end

	NAStuff.annoyLoop = false
	Wait(0.2)
	NAStuff.annoyLoop = true

	const user = ...
	const targets = getPlr(user)

	if #targets == 0 then
		DoNotif("No target found.", 3)
		return
	end

	const target = targets[1]
	const initialTargetChar = NAmanage.PlayerArgChar(target)
	if not initialTargetChar or not getRoot(initialTargetChar) then
		DoNotif("Target has no character or root part.", 3)
		annoyLoop = false
		return
	end

	local myChar = getChar()
	local myRoot = myChar and getRoot(myChar)
	const originalCFrame = myRoot and (NAmanage.UG_clientCFrame(myRoot) or myRoot.CFrame)

	if not myRoot then
		DoNotif("Your character has no root part.", 3)
		annoyLoop = false
		return
	end

	math.randomseed(tick())

	repeat
		Wait(0.05)

		const targetChar = NAmanage.PlayerArgChar(target)
		const targetRoot = targetChar and getRoot(targetChar)
		myChar = getChar()
		myRoot = myChar and getRoot(myChar)

		if not targetRoot or not myRoot then
			break
		end

		const offset = Vector3.new(math.random(-3,3), math.random(0,2), math.random(-3,3))
		NAmanage.UG_setClientCFrame(myRoot, targetRoot.CFrame + offset)

		Services.RunService.RenderStepped:Wait()
	until not NAStuff.annoyLoop

	if myRoot and originalCFrame then
		NAmanage.UG_setClientCFrame(myRoot, originalCFrame)
	end
end, true)

cmd.add({"unannoy"}, {"unannoy", "Stops the annoy command"}, function()
	NAStuff.annoyLoop = false
end)

NAmanage.IsPlayerOrNPCPart = NAmanage.IsPlayerOrNPCPart or function(inst)
	const RawWorkspace = __lt.gs("Workspace")
	if typeof(inst) ~= "Instance" then
		return false, nil, nil
	end

	local model, humanoid
	if type(NAmanage.ResolveHumanoidModelFromPart) == "function" then
		model, humanoid = NAmanage.ResolveHumanoidModelFromPart(inst)
	else
		local current = inst
		while current and current ~= RawWorkspace do
			if current:IsA("Model") then
				const hum = current:FindFirstChildOfClass("Humanoid")
				if hum then
					model, humanoid = current, hum
					break
				end
			end
			current = current.Parent
		end
	end

	if not (model and model:IsA("Model") and humanoid) then
		return false, nil, nil
	end

	local okPlayer, plr = pcall(function()
		return __lt.cm("Players", "GetPlayerFromCharacter", model)
	end)
	if okPlayer and plr then
		return true, "player", model
	end

	if type(CheckIfNPC) == "function" then
		local okNPC, isNPC = pcall(CheckIfNPC, model)
		if okNPC and isNPC then
			return true, "npc", model
		end
	end

	return true, "humanoid", model
end

cmd.add({"deleteinvisparts","deleteinvisibleparts","dip"},{"deleteinvisparts","Deletes invisible parts"},function()
	local deleted = 0
	local skippedPlayers = 0
	local skippedNPCs = 0
	local skippedHumanoids = 0

	for _, v in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do
		if v.Transparency == 1 and v.CanCollide then
			local skip, kind = NAmanage.IsPlayerOrNPCPart(v)
			if skip then
				if kind == "player" then
					skippedPlayers += 1
				elseif kind == "npc" then
					skippedNPCs += 1
				else
					skippedHumanoids += 1
				end
			else
				v:Destroy()
				deleted += 1
			end
		end
	end

	DoNotif(
		"Deleted "..tostring(deleted).." invisible part(s). Skipped "..
		tostring(skippedPlayers).." player, "..
		tostring(skippedNPCs).." NPC, "..
		tostring(skippedHumanoids).." humanoid part(s).",
		4
	)
end)

NAStuff.shownParts = {}

cmd.add({"invisibleparts","invisparts"},{"invisibleparts","Shows invisible parts"},function()
	for _, v in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do
		if v.Transparency == 1 then
			local alreadyShown = false
			for _, p in NAStuff.shownParts do
				if p == v then
					alreadyShown = true
					break
				end
			end
			if not alreadyShown then
				Insert(NAStuff.shownParts, v)
			end
			v.Transparency = 0
		end
	end
end)

cmd.add({"uninvisibleparts","uninvisparts"},{"uninvisibleparts","Makes parts affected by invisparts return to normal"},function()
	for _, v in NAStuff.shownParts do
		if v and v:IsA("BasePart") then
			v.Transparency = 1
		end
	end
	table.clear(NAStuff.shownParts)
end)

cmd.add({"datalimit"},{"datalimit <kbps>","Set outgoing bandwidth limit in KBps"},function(value)
	const limit=tonumber(value)
	if not limit then
		DoNotif("Usage: datalimit <number>",2)
		return
	end
	const networkClient=SafeGetService("NetworkClient")
	if not networkClient then
		DoNotif("NetworkClient unavailable",3)
		return
	end
	local ok,err=pcall(function()
		__lt.cm("NetworkClient", "SetOutgoingKBPSLimit", limit)
	end)
	if ok then
		DoNotif("Outgoing limit set to "..tostring(limit).." kbps",2)
	else
		DoNotif("Failed to set limit: "..tostring(err),3)
	end
end,true)

NAmanage.RemoveAdsCandidate = NAmanage.RemoveAdsCandidate or function(obj)
	if typeof(obj) ~= "Instance" then
		return false
	end
	const parent = obj:IsA("PackageLink") and obj.Parent or obj
	if not (parent and parent.Parent) then
		return false
	end
	local destroyTarget = nil
	if parent:FindFirstChild("ADpart") then
		destroyTarget = parent
	elseif parent:FindFirstChild("AdGuiAdornee") then
		destroyTarget = parent.Parent or parent
	end
	if not (destroyTarget and destroyTarget.Parent) then
		return false
	end
	pcall(function()
		destroyTarget:Destroy()
	end)
	return true
end

NAmanage.RemoveAdsScan = NAmanage.RemoveAdsScan or function()
	local count = 0
	for _, obj in NAmanage.QueryDescendants(Services.Workspace, "PackageLink") do
		if NAmanage.RemoveAdsCandidate(obj) then
			count += 1
		end
	end
	return count
end

cmd.add({"removeads","adblock"},{"removeads (adblock)","Removes billboard advertisements as they appear"},function()
	if NAStuff._removeAdsLoop and NAStuff._removeAdsLoop.active then
		DoNotif("Remove Ads already enabled",2)
		return
	end
	const state={active=true}
	NAStuff._removeAdsLoop=state
	NAmanage.RemoveAdsScan()
	NAlib.disconnect("removeads_added")
	NAlib.connect("removeads_added", NAmanage.wsAdd(function(obj)
		if not (NAStuff._removeAdsLoop and NAStuff._removeAdsLoop.active) then
			NAlib.disconnect("removeads_added")
			return
		end
		if obj and obj:IsA("PackageLink") then
			NAmanage.RemoveAdsCandidate(obj)
		elseif obj and (obj.Name == "ADpart" or obj.Name == "AdGuiAdornee") then
			NAmanage.RemoveAdsCandidate(obj.Parent)
		end
	end))
	DoNotif("Remove Ads enabled",2)
end)

cmd.add({"unremoveads","noadblock","disableads"},{"unremoveads (noadblock,disableads)","Stop removing billboard advertisements"},function()
	const state=NAStuff._removeAdsLoop
	if not state or not state.active then
		DoNotif("Remove Ads is not active",2)
		NAStuff._removeAdsLoop=nil
		return
	end
	state.active=false
	NAStuff._removeAdsLoop=nil
	NAlib.disconnect("removeads_added")
	DoNotif("Remove Ads disabled",2)
end)

NAmanage.EngineSettings = NAmanage.EngineSettings or {}

NAmanage.EngineSettings.key = function(serviceName, propertyName)
	return tostring(serviceName or "").."."..tostring(propertyName or "")
end

NAmanage.EngineSettings.saved = function()
	return {}
end

NAmanage.EngineSettings.saveValue = function(serviceName, propertyName, value)
	return nil
end

NAmanage.EngineSettings.parseBool = function(value, default)
	if type(value) == "boolean" then
		return value
	end
	if value == nil or value == "" then
		return default ~= false
	end
	const text = Lower(tostring(value))
	if text == "true" or text == "1" or text == "on" or text == "yes" or text == "enable" or text == "enabled" then
		return true
	end
	if text == "false" or text == "0" or text == "off" or text == "no" or text == "disable" or text == "disabled" then
		return false
	end
	return default ~= false
end

NAmanage.EngineSettings.getService = function(serviceName)
	NAmanage.EngineSettings._serviceCache = type(NAmanage.EngineSettings._serviceCache) == "table" and NAmanage.EngineSettings._serviceCache or {}
	const key = tostring(serviceName or "")
	if NAmanage.EngineSettings._serviceCache[key] ~= nil then
		return NAmanage.EngineSettings._serviceCache[key] or nil
	end
	local ok, service = pcall(function()
		return settings():GetService(serviceName)
	end)
	if ok and service then
		NAmanage.EngineSettings._serviceCache[key] = service
		return service
	end
	NAmanage.EngineSettings._serviceCache[key] = false
	return nil
end

NAmanage.EngineSettings.get = function(serviceName, propertyName, fallback)
	const service = NAmanage.EngineSettings.getService(serviceName)
	if not service then
		return fallback
	end
	local ok, value = pcall(function()
		return service[propertyName]
	end)
	if ok then
		return value
	end
	return fallback
end

NAmanage.EngineSettings.set = function(serviceName, propertyName, value, label, silent)
	const service = NAmanage.EngineSettings.getService(serviceName)
	label = label or (serviceName.."."..propertyName)
	if not service then
		if not silent then
			DoNotif(serviceName.." unavailable", 3)
		end
		return false
	end
	local ok, err = pcall(function()
		service[propertyName] = value
	end)
	if ok then
		if not silent then
			DoNotif(label.." set to "..tostring(value), 2)
		end
		return true
	end
	if not silent then
		DoNotif("Failed to set "..label..": "..tostring(err), 3)
	end
	return false
end

NAmanage.EngineSettings.setAndSave = function(serviceName, propertyName, value, label, silent)
	return NAmanage.EngineSettings.set(serviceName, propertyName, value, label, silent)
end

NAmanage.EngineSettings.setBool = function(entry, value, silent)
	return NAmanage.EngineSettings.setAndSave(entry.service, entry.property, value == true, entry.label, silent)
end

NAmanage.EngineSettings.setNumber = function(entry, value, silent)
	local n = tonumber(value)
	if not n then
		if not silent then
			DoNotif("Usage: "..entry.usage, 2)
		end
		return false
	end
	if entry.integer then
		n = math.floor(n + 0.5)
	end
	if entry.min ~= nil then
		n = math.max(entry.min, n)
	end
	if entry.max ~= nil then
		n = math.min(entry.max, n)
	end
	return NAmanage.EngineSettings.setAndSave(entry.service, entry.property, n, entry.label, silent)
end

NAmanage.EngineSettings.boolCommands = {
	{ aliases = {"renderstreamedregions","streamedregions"}, offAliases = {"unrenderstreamedregions","nostreamedregions"}, service = "NetworkSettings", property = "RenderStreamedRegions", label = "Render Streamed Regions" },
	{ aliases = {"joinbreakdown","printjoinsize"}, offAliases = {"unjoinbreakdown","noprintjoinsize"}, service = "NetworkSettings", property = "PrintJoinSizeBreakdown", label = "Print Join Size Breakdown" },
	{ aliases = {"streamquota","printstreamquota"}, offAliases = {"unstreamquota","noprintstreamquota"}, service = "NetworkSettings", property = "PrintStreamInstanceQuota", label = "Print Stream Instance Quota" },
	{ aliases = {"animationassetdata","showanimationasset"}, offAliases = {"unanimationassetdata","noanimationasset"}, service = "NetworkSettings", property = "ShowActiveAnimationAsset", label = "Show Active Animation Asset" },
	{ aliases = {"randomizejoinorder","randomjoinorder"}, offAliases = {"unrandomizejoinorder","norandomjoinorder"}, service = "NetworkSettings", property = "RandomizeJoinInstanceOrder", label = "Randomize Join Instance Order" },
	{ aliases = {"physallowsleep","allowsleep"}, offAliases = {"unphysallowsleep","noallowsleep"}, service = "PhysicsSettings", property = "AllowSleep", label = "Physics Allow Sleep" },
	{ aliases = {"physanchors","anchorsshown"}, offAliases = {"unphysanchors","noanchorsshown"}, service = "PhysicsSettings", property = "AreAnchorsShown", label = "Physics Anchors Shown" },
	{ aliases = {"physassemblies","assembliesshown"}, offAliases = {"unphysassemblies","noassembliesshown"}, service = "PhysicsSettings", property = "AreAssembliesShown", label = "Physics Assemblies Shown" },
	{ aliases = {"physbodytypes","bodytypesshown"}, offAliases = {"unphysbodytypes","nobodytypesshown"}, service = "PhysicsSettings", property = "AreBodyTypesShown", label = "Physics Body Types Shown" },
	{ aliases = {"collisioncosts","physcollisioncosts"}, offAliases = {"uncollisioncosts","nophyscollisioncosts"}, service = "PhysicsSettings", property = "AreCollisionCostsShown", label = "Collision Costs Shown" },
	{ aliases = {"jointcoords","physjointcoords"}, offAliases = {"unjointcoords","nophysjointcoords"}, service = "PhysicsSettings", property = "AreJointCoordinatesShown", label = "Joint Coordinates Shown" },
	{ aliases = {"physowners","ownersshown"}, offAliases = {"unphysowners","noownersshown"}, service = "PhysicsSettings", property = "AreOwnersShown", label = "Physics Owners Shown" },
	{ aliases = {"physregions","regionsshown"}, offAliases = {"unphysregions","noregionsshown"}, service = "PhysicsSettings", property = "AreRegionsShown", label = "Physics Regions Shown" },
	{ aliases = {"awakeparts","awakehighlight"}, offAliases = {"unawakeparts","noawakehighlight"}, service = "PhysicsSettings", property = "AreAwakePartsHighlighted", label = "Awake Parts Highlighted" },
	{ aliases = {"contactpoints","physcontactpoints"}, offAliases = {"uncontactpoints","nophyscontactpoints"}, service = "PhysicsSettings", property = "AreContactPointsShown", label = "Contact Points Shown" },
	{ aliases = {"mechanismsshown","physmechanisms"}, offAliases = {"unmechanismsshown","nophysmechanisms"}, service = "PhysicsSettings", property = "AreMechanismsShown", label = "Mechanisms Shown" },
	{ aliases = {"unalignedparts","showunaligned"}, offAliases = {"ununalignedparts","nounalignedparts"}, service = "PhysicsSettings", property = "AreUnalignedPartsShown", label = "Unaligned Parts Shown" },
	{ aliases = {"receiveage","showreceiveage"}, offAliases = {"unreceiveage","noreceiveage"}, service = "PhysicsSettings", property = "IsReceiveAgeShown", label = "Receive Age Shown" },
	{ aliases = {"interpolationthrottle","showinterpolationthrottle"}, offAliases = {"uninterpolationthrottle","nointerpolationthrottle"}, service = "PhysicsSettings", property = "IsInterpolationThrottleShown", label = "Interpolation Throttle Shown" },
	{ aliases = {"phystree","physicstree"}, offAliases = {"unphystree","nophysicstree"}, service = "PhysicsSettings", property = "IsTreeShown", label = "Physics Tree Shown" },
	{ aliases = {"decompositiongeometry","showdecomposition"}, offAliases = {"undecompositiongeometry","nodecomposition"}, service = "PhysicsSettings", property = "ShowDecompositionGeometry", label = "Decomposition Geometry" },
	{ aliases = {"drawcontactsforce","contactsnetforce"}, offAliases = {"undrawcontactsforce","nocontactsnetforce"}, service = "PhysicsSettings", property = "DrawContactsNetForce", label = "Draw Contacts Net Force" },
	{ aliases = {"drawconstraintsforce","constraintsnetforce"}, offAliases = {"undrawconstraintsforce","noconstraintsnetforce"}, service = "PhysicsSettings", property = "DrawConstraintsNetForce", label = "Draw Constraints Net Force" },
	{ aliases = {"drawtotalforce","totalnetforce"}, offAliases = {"undrawtotalforce","nototalnetforce"}, service = "PhysicsSettings", property = "DrawTotalNetForce", label = "Draw Total Net Force" },
	{ aliases = {"forceinstancenames","drawforcenames"}, offAliases = {"unforceinstancenames","noforcenames"}, service = "PhysicsSettings", property = "ShowInstanceNamesForDrawnForcesAndTorques", label = "Force Instance Names" },
	{ aliases = {"renderboundingboxes","showboundingboxes"}, offAliases = {"unrenderboundingboxes","noboundingboxes"}, service = "RenderSettings", property = "ShowBoundingBoxes", label = "Render Bounding Boxes" },
	{ aliases = {"rendercsgtriangles","rendercsgdebug"}, offAliases = {"unrendercsgtriangles","norendercsgdebug"}, service = "RenderSettings", property = "RenderCSGTrianglesDebug", label = "Render CSG Triangles Debug" },
	{ aliases = {"renderfrm","enablefrm"}, offAliases = {"unrenderfrm","disablefrm"}, service = "RenderSettings", property = "EnableFRM", label = "Frame Rate Manager" },
	{ aliases = {"eagerbulkexecution","renderbulk"}, offAliases = {"uneagerbulkexecution","norenderbulk"}, service = "RenderSettings", property = "EagerBulkExecution", label = "Eager Bulk Execution" },
	{ aliases = {"exportmergebymaterial","mergebymaterial"}, offAliases = {"unexportmergebymaterial","nomergebymaterial"}, service = "RenderSettings", property = "ExportMergeByMaterial", label = "Export Merge By Material" },
	{ aliases = {"soundwarnings","reportsoundwarnings"}, offAliases = {"unsoundwarnings","noreportsoundwarnings"}, service = "DebugSettings", property = "ReportSoundWarnings", label = "Report Sound Warnings" },
	{ aliases = {"videocapture","videocaptureenabled"}, offAliases = {"unvideocapture","novideocapture"}, service = "GameSettings", property = "VideoCaptureEnabled", label = "Video Capture Enabled" },
}

NAmanage.EngineSettings.numberCommands = {
	{ aliases = {"forcedrawscale","forcevisualscale"}, service = "PhysicsSettings", property = "ForceDrawScale", label = "Force Draw Scale", usage = "forcedrawscale <number>", min = 0, max = 1000 },
	{ aliases = {"torquedrawscale","torquevisualscale"}, service = "PhysicsSettings", property = "TorqueDrawScale", label = "Torque Draw Scale", usage = "torquedrawscale <number>", min = 0, max = 1000 },
	{ aliases = {"fluidforcedrawscale","fluidforcescale"}, service = "PhysicsSettings", property = "FluidForceDrawScale", label = "Fluid Force Draw Scale", usage = "fluidforcedrawscale <number>", min = 0, max = 1000 },
	{ aliases = {"forcesmoothingsteps","forcevisualsteps"}, service = "PhysicsSettings", property = "ForceVisualizationSmoothingSteps", label = "Force Smoothing Steps", usage = "forcesmoothingsteps <0-100>", min = 0, max = 100, integer = true },
	{ aliases = {"throttleadjusttime","physadjusttime"}, service = "PhysicsSettings", property = "ThrottleAdjustTime", label = "Throttle Adjust Time", usage = "throttleadjusttime <seconds>", min = 0, max = 120 },
	{ aliases = {"renderautofrm","autofrmlevel"}, service = "RenderSettings", property = "AutoFRMLevel", label = "Auto FRM Level", usage = "renderautofrm <number>", min = 0, max = 21, integer = true },
	{ aliases = {"meshcachesize","rendermeshcache"}, service = "RenderSettings", property = "MeshCacheSize", label = "Mesh Cache Size", usage = "meshcachesize <number>", min = 0, integer = true },
}

NAmanage.EngineSettings.extraSavedSettings = {
	{ service = "NetworkSettings", property = "IncomingReplicationLag", label = "Incoming Replication Lag", kind = "number" },
	{ service = "PhysicsSettings", property = "PhysicsEnvironmentalThrottle", label = "Physics Environmental Throttle", kind = "number" },
}

NAmanage.EngineSettings.retiredKeys = {
	"NetworkSettings.NetworkEmulationEnabled",
	"NetworkSettings.InboundNetworkLossPercent",
	"NetworkSettings.OutboundNetworkLossPercent",
	"NetworkSettings.InboundNetworkMinDelayMs",
	"NetworkSettings.InboundNetworkMaxDelayMs",
	"NetworkSettings.OutboundNetworkMinDelayMs",
	"NetworkSettings.OutboundNetworkMaxDelayMs",
}

NAmanage.EngineSettings.cleanupRetired = function()
	return nil
end

NAmanage.EngineSettings.loadSaved = function()
	return nil
end

for _, entry in NAmanage.EngineSettings.boolCommands do
	cmd.add(entry.aliases, {entry.usage or (entry.aliases[1].." [on/off]"), "Set "..entry.label}, function(...)
		const args = {...}
		NAmanage.EngineSettings.setBool(entry, NAmanage.EngineSettings.parseBool(args[1], true))
	end)
	if entry.offAliases then
		cmd.add(entry.offAliases, {entry.offAliases[1], "Disable "..entry.label}, function()
			NAmanage.EngineSettings.setBool(entry, false)
		end)
	end
end

for _, entry in NAmanage.EngineSettings.numberCommands do
	cmd.add(entry.aliases, {entry.usage, "Set "..entry.label}, function(value)
		NAmanage.EngineSettings.setNumber(entry, value)
	end, true)
end

cmd.add({"reloadassets","renderreloadassets"},{"reloadassets","Set RenderSettings.ReloadAssets"},function()
	NAmanage.EngineSettings.set("RenderSettings", "ReloadAssets", true, "Reload Assets")
end)

cmd.add({"enginesettingsinfo","enginedebug","rblxsettingsinfo"},{"enginesettingsinfo","Show Roblox settings service diagnostics"},function()
	const lines = {}
	const debugSettings = NAmanage.EngineSettings.getService("DebugSettings")
	if debugSettings then
		const function addDebug(label, prop)
			local ok, value = pcall(function()
				return debugSettings[prop]
			end)
			if ok and value ~= nil then
				Insert(lines, label..": "..tostring(value))
			end
		end
		addDebug("RobloxVersion", "RobloxVersion")
		addDebug("InstanceCount", "InstanceCount")
		addDebug("JobCount", "JobCount")
		addDebug("PlayerCount", "PlayerCount")
	else
		Insert(lines, "DebugSettings unavailable")
	end
	Insert(lines, "GameSettings: "..(NAmanage.EngineSettings.getService("GameSettings") and "available" or "unavailable"))
	Insert(lines, "LuaSettings: "..(NAmanage.EngineSettings.getService("LuaSettings") and "available" or "unavailable"))
	Insert(lines, "Studio: "..(NAmanage.EngineSettings.getService("Studio") and "available" or "unavailable"))
	DoNotif(Concat(lines, "\n"), 6, "Engine Settings")
end)

cmd.add({"replicationlag", "backtrack"}, {"replicationlag (backtrack)", "Set IncomingReplicationLag"}, function(num)
	NAmanage.EngineSettings.setAndSave("NetworkSettings", "IncomingReplicationLag", tonumber(num) or 0, "Incoming Replication Lag")
end, true)

cmd.add({"animdata"}, {"animdata", "Shows you information about your current animations"}, function(num)
	NAmanage.EngineSettings.setAndSave("NetworkSettings", "ShowActiveAnimationAsset", true, "Show Active Animation Asset")
end, true)

cmd.add({"unanimdata"}, {"unanimdata", ""}, function(num)
	NAmanage.EngineSettings.setAndSave("NetworkSettings", "ShowActiveAnimationAsset", false, "Show Active Animation Asset")
end, true)

cmd.add({"sleepon"}, {"sleepon", "Enable AllowSleep"}, function()
	NAmanage.EngineSettings.setAndSave("PhysicsSettings", "AllowSleep", true, "Physics Allow Sleep")
end)

cmd.add({"unsleepon"}, {"unsleepon", "Disable AllowSleep"}, function()
	NAmanage.EngineSettings.setAndSave("PhysicsSettings", "AllowSleep", false, "Physics Allow Sleep")
end)

cmd.add({"throttle"}, {"throttle", "Set PhysicsEnvironmentalThrottle (1 = default, 2 = disabled)"}, function(num)
	NAmanage.EngineSettings.setAndSave("PhysicsSettings", "PhysicsEnvironmentalThrottle", tonumber(num) or 1, "Physics Environmental Throttle")
end, true)

cmd.add({"quality","qualitylevel"},{"quality <1-21>","Manage rendering quality settings"},function(...)
	const args = {...}
	const target = args[1]
	const buttons = {}
	for _, ql in Enum.QualityLevel:GetEnumItems() do
		Insert(buttons, {
			Text = ql.Name,
			Callback = function()
				settings().Rendering.QualityLevel = ql
			end
		})
	end
	if target and target ~= "" then
		local key = tostring(target)
		local n = tonumber(key)
		if n then
			n = math.clamp(math.floor(n), 1, 21)
			key = Format("Level%02d", n)
		else
			const l = Lower(key)
			if l == "auto" or l == "automatic" then
				key = "Automatic"
			end
		end
		local found = false
		for _, btn in buttons do
			if Match(Lower(btn.Text), Lower(key)) then
				btn.Callback()
				DebugNotif("Quality set to "..btn.Text, 3)
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching quality level for: "..target, 3)
		end
	else
		Window({
			Title = "Rendering Quality Options",
			Buttons = buttons
		})
	end
end)

cmd.add({"logphysics"}, {"logphysics", "Enable Physics Error Logging"}, function()
	settings():GetService("NetworkSettings").PrintPhysicsErrors = true
	NAmanage.jlCfg.PhysicsLog = true
	NAmanage.jlSave()
end)

cmd.add({"nologphysics"}, {"nologphysics", "Disable Physics Error Logging"}, function()
	settings():GetService("NetworkSettings").PrintPhysicsErrors = false
	NAmanage.jlCfg.PhysicsLog = false
	NAmanage.jlSave()
end)

cmd.add({"norender"},{"norender","Disable 3d Rendering to decrease the amount of CPU the client uses"},function()
	__lt.cm("RunService", "Set3dRenderingEnabled", false)
end)

cmd.add({"render"},{"render","Enable 3d Rendering"},function()
	__lt.cm("RunService", "Set3dRenderingEnabled", true)
end)

cmd.add({"noreset","disablereset"},{"noreset","disable reset button"},function()
	__lt.cm("StarterGui", "SetCore", "ResetButtonCallback",false)
end,true)

cmd.add({"resetbtn","enablereset"},{"resetbtn","enable reset button"},function()
	__lt.cm("StarterGui", "SetCore", "ResetButtonCallback",true)
end,true)

oofing = false

cmd.add({"loopoof"},{"loopoof","Loops everyone's character sounds (everyone can hear)"},function()
	oofing = true
	repeat Wait(0.1)
		for _, player in __lt.cm("Players", "GetPlayers") do
			const char = player.Character
			const head = getHead(char)
			if head then
				for _, child in head:GetChildren() do
					if child:IsA("Sound") and not child.Playing then
						child.Playing = true
					end
				end
			end
		end
	until not oofing
end)

cmd.add({"unloopoof"},{"unloopoof","Stops the oof chaos"},function()
	oofing = false
end)

cmd.add({"strengthen"},{"strengthen","Makes your character more dense (CustomPhysicalProperties)"},function(...)
	const args={...}
	const density = math.clamp(tonumber(args[1]) or 100, 0.01, 100)
	for _,child in (getChar() and getChar():QueryDescendants("BasePart") or {}) do
		pcall(function()
			child.CustomPhysicalProperties=PhysicalProperties.new(density,0.3,0.5)
		end)
	end
	if NAmanage.RebuildVelocityWalkSpeedHelper then
		NAmanage.RebuildVelocityWalkSpeedHelper()
	end
end,true)

cmd.add({"unweaken","unstrengthen"},{"unweaken (unstrengthen)","Sets your characters CustomPhysicalProperties to default"},function()
	for _,child in (getChar() and getChar():QueryDescendants("BasePart") or {}) do
		pcall(function()
			child.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5)
		end)
	end
	if NAmanage.RebuildVelocityWalkSpeedHelper then
		NAmanage.RebuildVelocityWalkSpeedHelper()
	end
end)

cmd.add({"weaken"},{"weaken","Makes your character less dense"},function(...)
	const args={...}
	const density = math.clamp(tonumber(args[1]) or 0.01, 0.01, 100)
	for _,child in (getChar() and getChar():QueryDescendants("BasePart") or {}) do
		pcall(function()
			child.CustomPhysicalProperties=PhysicalProperties.new(density,0.3,0.5)
		end)
	end
	if NAmanage.RebuildVelocityWalkSpeedHelper then
		NAmanage.RebuildVelocityWalkSpeedHelper()
	end
end,true)
