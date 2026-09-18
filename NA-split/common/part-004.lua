NAmanage.startAprilPranks = function()
	if not isAprilFools() then return end
	const aprilData = NAStuff.AprilFoolsData or {}
	if aprilData.started then return end
	aprilData.started = true
	aprilData.reverted = false
	aprilData.originalColor = aprilData.originalColor or NAUISTROKER
	NAStuff.AprilFoolsData = aprilData

	const function refreshPlaceholder()
		const box = NAUIMANAGER and NAUIMANAGER.cmdInput
		if not box or not box.Parent then return end
		if box:IsA("TextBox") and box:IsFocused() and box.Text ~= "" then
			return
		end
		const phrase = NAmanage.AprilPick(aprilData.placeholderJokes)
		if phrase then
			box.PlaceholderText = maybeMock(phrase)
		end
	end

	if TextButton then
		MouseButtonFix(TextButton, function()
			if not isAprilFools() then return end
			NAmanage.nudgeAprilIcon()
		end)
	end

	const function aprilWiggleCmdBar()
		const box = NAUIMANAGER and NAUIMANAGER.cmdInput
		if not box or not box.Parent then return end
		const target = box.Parent
		const basePos = target.Position
		const baseRot = target.Rotation or 0
		const offsetX = math.random(-8, 8)
		const offsetY = math.random(-4, 4)
		const rot = math.random(-6, 6)
		const wiggleTween = __lt.cm("TweenService", "Create", target, TweenInfo.new(0.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Position = basePos + UDim2.new(0, offsetX, 0, offsetY);
			Rotation = baseRot + rot;
		})
		wiggleTween:Play()
		Delay(0.4, function()
			__lt.cm("TweenService", "Create", target, TweenInfo.new(0.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
				Position = basePos;
				Rotation = baseRot;
			}):Play()
		end)
	end

	NAmanage.ApplyAprilColor = NAmanage.ApplyAprilColor or function(color)
		if typeof(color) ~= "Color3" then return end
		NAUISTROKER = color
		if type(NAgui.pruneRegisteredStrokes) == "function" then
			NAgui.pruneRegisteredStrokes(false)
		end
		for _, stroke in NACOLOREDELEMENTS or {} do
			if stroke and stroke.Color then
				stroke.Color = color
			end
		end
	end

	NAmanage.AprilRestoreColor = NAmanage.AprilRestoreColor or function()
		const aprilData = NAStuff.AprilFoolsData
		const base = aprilData and aprilData.originalColor or NAUISTROKER
		if typeof(base) == "Color3" then
			NAmanage.ApplyAprilColor(base)
		end
	end

	const function aprilColorPulse()
		const hue = math.random()
		const color = Color3.fromHSV(hue, 0.9, 1)
		NAmanage.ApplyAprilColor(color)
	end

	SpawnCall(function()
		const notifCooldown = aprilData.prankNotifCooldown or {}
		local notifMin = tonumber(notifCooldown.min) or 60
		local notifMax = tonumber(notifCooldown.max) or 120
		if notifMax < notifMin then
			notifMin, notifMax = notifMax, notifMin
		end
		while isAprilFools() do
			Wait(math.random(notifMin, notifMax))
			const msg = NAmanage.AprilPick(aprilData.prankNotifs)
			if msg and type(DoNotif) == "function" then
				DoNotif(maybeMock(msg), 4)
			end
			NAmanage.nudgeAprilIcon()
		end
	end)

	SpawnCall(function()
		while isAprilFools() do
			refreshPlaceholder()
			Wait(math.random(10, 18))
		end
	end)

	SpawnCall(function()
		while isAprilFools() do
			aprilColorPulse()
			Wait(math.random(6, 12))
		end
	end)

	SpawnCall(function()
		while isAprilFools() do
			aprilWiggleCmdBar()
			Wait(math.random(9, 16))
		end
	end)

	SpawnCall(function()
		while isAprilFools() do
			Wait(3)
		end
		if not aprilData.reverted then
			aprilData.reverted = true
			if NAmanage.AprilRestoreColor then
				NAmanage.AprilRestoreColor()
			end
		end
	end)
end

if _na_env.NATestingVer then
	if isAprilFools() then
		testingName = yayApril(true)
		testingName = maybeMock(testingName)
	end
	adminName = testingName
else
	if isAprilFools() then
		mainName = yayApril(false)
		mainName = maybeMock(mainName)
	end
	adminName = mainName
end

NAgui._dragState = NAgui._dragState or {}
NAgui._touchGestureLock = NAgui._touchGestureLock or { owner = nil, mode = nil, input = nil }
NAgui._draggerCleanups = NAgui._draggerCleanups or {}
NAgui._draggerUiCleanups = NAgui._draggerUiCleanups or {}

NAgui.tryLockTouchGesture = NAgui.tryLockTouchGesture or function(owner, mode, input)
	if not (input and input.UserInputType == Enum.UserInputType.Touch) then
		return true
	end
	const lock = NAgui._touchGestureLock
	if lock.input and lock.input ~= input then
		return false
	end
	if lock.input == input then
		return lock.owner == owner and lock.mode == mode
	end
	lock.owner = owner
	lock.mode = mode
	lock.input = input
	return true
end

NAgui.releaseTouchGesture = NAgui.releaseTouchGesture or function(owner, mode, input)
	if not (input and input.UserInputType == Enum.UserInputType.Touch) then
		return
	end
	const lock = NAgui._touchGestureLock
	if lock.input == input and lock.owner == owner and lock.mode == mode then
		lock.owner = nil
		lock.mode = nil
		lock.input = nil
	end
end

NAgui.dragger = function(ui, dragui)
	if not ui then return end
	dragui = dragui or ui
	const draggerId = tostring((ui and ui.GetDebugId and ui:GetDebugId()) or ui)
	const connName = "Dragger_"..draggerId
	if type(NAgui._draggerUiCleanups[draggerId]) == "function" then
		pcall(NAgui._draggerUiCleanups[draggerId])
	end
	if type(NAgui._draggerCleanups[connName]) == "function" then
		pcall(NAgui._draggerCleanups[connName])
	end
	NAlib.disconnect(connName)
	const GS = Services.GuiService
	const ds = NAgui._dragState
	local dragging = false
	local dragStart
	local startPos
	local cleaned = false
	local dragPointer
	local touchGestureLocked = false
	local pendingInput
	local moveConn
	local endConn
	local stepConn

	const function disconnectLiveInput()
		if moveConn then
			pcall(function() moveConn:Disconnect() end)
			moveConn = nil
		end
		if endConn then
			pcall(function() endConn:Disconnect() end)
			endConn = nil
		end
		if stepConn then
			pcall(function() stepConn:Disconnect() end)
			stepConn = nil
		end
		pendingInput = nil
		if NAmanage and NAmanage.prnCon then
			NAmanage.prnCon(connName)
		end
	end

	const function stopDrag()
		if touchGestureLocked then
			NAgui.releaseTouchGesture(ui, "move", dragPointer)
			touchGestureLocked = false
		end
		dragging = false
		dragPointer = nil
		pendingInput = nil
		if ds.owner == ui then
			ds.owner = nil
			ds.input = nil
		end
		disconnectLiveInput()
	end

	const function cleanupDragger()
		if cleaned then return end
		cleaned = true
		stopDrag()
		if NAgui._draggerCleanups[connName] == cleanupDragger then
			NAgui._draggerCleanups[connName] = nil
		end
		if NAgui._draggerUiCleanups[draggerId] == cleanupDragger then
			NAgui._draggerUiCleanups[draggerId] = nil
		end
		NAlib.disconnect(connName)
	end
	NAgui._draggerCleanups[connName] = cleanupDragger
	NAgui._draggerUiCleanups[draggerId] = cleanupDragger

	const function getOrder(g)
		const z = (g.ZIndex or 0)
		const lc = g:FindFirstAncestorWhichIsA("LayerCollector")
		local d = 0
		if lc and lc:IsA("ScreenGui") then
			d = lc.DisplayOrder or 0
		end
		return d * 10000 + z
	end

	const function isTopMost(root, input)
		const pos = input.Position
		local list
		const ok = pcall(function()
			list = GS:GetGuiObjectsAtPosition(pos.X, pos.Y)
		end)
		if not ok or type(list) ~= "table" or #list == 0 then
			return true
		end
		local top, topO
		for _, g in list do
			if typeof(g) == "Instance" and g:IsA("GuiObject") then
				const o = getOrder(g)
				if not top or o > topO then
					top = g
					topO = o
				end
			end
		end
		if not top then return true end
		return top == root or top:IsDescendantOf(root)
	end

	const function update(input)
		NACaller(function()
			if not ui or not ui.Parent then return end
			const delta = input.Position - dragStart
			const screenSize = ui.Parent.AbsoluteSize
			if not screenSize or screenSize.X <= 0 or screenSize.Y <= 0 then return end
			const newXScale = startPos.X.Scale + (startPos.X.Offset + delta.X) / screenSize.X
			const newYScale = startPos.Y.Scale + (startPos.Y.Offset + delta.Y) / screenSize.Y
			ui.Position = UDim2.new(newXScale, 0, newYScale, 0)
		end)
	end

	NAlib.connect(connName, dragui.InputBegan:Connect(function(input)
		NACaller(function()
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (not ds.owner or ds.owner == ui)
				and isTopMost(dragui, input) then
				if input.UserInputType == Enum.UserInputType.Touch then
					if not (NAgui.tryLockTouchGesture and NAgui.tryLockTouchGesture(ui, "move", input)) then
						return
					end
					touchGestureLocked = true
				end
				ds.owner = ui
				ds.input = input
				dragging = true
				dragPointer = input
				dragStart = input.Position
				startPos = ui.Position
				disconnectLiveInput()
				moveConn = NAlib.connect(connName, Services.UserInputService.InputChanged:Connect(function(changedInput)
					if not dragging or ds.owner ~= ui then
						return
					end
					const inputType = changedInput.UserInputType
					if inputType == Enum.UserInputType.MouseMovement then
						pendingInput = changedInput
						return
					end
					if inputType == Enum.UserInputType.Touch and changedInput == dragPointer then
						pendingInput = changedInput
					end
				end))
				endConn = NAlib.connect(connName, Services.UserInputService.InputEnded:Connect(function(endedInput)
					if not dragging then
						return
					end
					const inputType = endedInput.UserInputType
					if inputType == Enum.UserInputType.MouseButton1
						or (inputType == Enum.UserInputType.Touch and endedInput == dragPointer) then
						stopDrag()
					end
				end))
				stepConn = NAlib.connect(connName, Services.RunService.RenderStepped:Connect(function()
					const frameInput = pendingInput
					if not frameInput then
						return
					end
					pendingInput = nil
					if not dragging or ds.owner ~= ui then
						return
					end
					update(frameInput)
				end))
			end
		end)
	end))

	if ui and ui.AncestryChanged then
		NAlib.connect(connName, ui.AncestryChanged:Connect(function(_, parent)
			if not parent then
				Defer(function()
					cleanupDragger()
				end)
			end
		end))
	end
	if ui and ui.Destroying then
		NAlib.connect(connName, ui.Destroying:Connect(cleanupDragger))
	end
	if dragui and dragui ~= ui and dragui.AncestryChanged then
		NAlib.connect(connName, dragui.AncestryChanged:Connect(function(_, parent)
			if not parent then
				Defer(function()
					cleanupDragger()
				end)
			end
		end))
	end
	if dragui and dragui ~= ui and dragui.Destroying then
		NAlib.connect(connName, dragui.Destroying:Connect(cleanupDragger))
	end

	pcall(function() ui.Active = true end)
	pcall(function() dragui.Active = true end)
end

NAgui.draggerV2 = function(ui, dragui)
	if not ui then return end
	dragui = dragui or ui
	const draggerId = tostring((ui and ui.GetDebugId and ui:GetDebugId()) or ui)
	const connName = "DraggerV2_"..draggerId
	if type(NAgui._draggerUiCleanups[draggerId]) == "function" then
		pcall(NAgui._draggerUiCleanups[draggerId])
	end
	if type(NAgui._draggerCleanups[connName]) == "function" then
		pcall(NAgui._draggerCleanups[connName])
	end
	NAlib.disconnect(connName)
	const GS = Services.GuiService
	const ds = NAgui._dragState
	const screenGui = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui.Parent
	local dragging, dragStart, startPos
	const anchor = ui.AnchorPoint
	local cleaned = false
	local dragPointer
	local touchGestureLocked = false
	local pendingInput
	local moveConn
	local endConn
	local stepConn

	const function disconnectLiveInput()
		if moveConn then
			pcall(function() moveConn:Disconnect() end)
			moveConn = nil
		end
		if endConn then
			pcall(function() endConn:Disconnect() end)
			endConn = nil
		end
		if stepConn then
			pcall(function() stepConn:Disconnect() end)
			stepConn = nil
		end
		pendingInput = nil
		if NAmanage and NAmanage.prnCon then
			NAmanage.prnCon(connName)
		end
	end

	const function stopDrag()
		if touchGestureLocked then
			NAgui.releaseTouchGesture(ui, "move", dragPointer)
			touchGestureLocked = false
		end
		dragging = false
		dragPointer = nil
		pendingInput = nil
		if ds.owner == ui then
			ds.owner = nil
			ds.input = nil
		end
		disconnectLiveInput()
	end

	const function cleanupDragger()
		if cleaned then return end
		cleaned = true
		stopDrag()
		if NAgui._draggerCleanups[connName] == cleanupDragger then
			NAgui._draggerCleanups[connName] = nil
		end
		if NAgui._draggerUiCleanups[draggerId] == cleanupDragger then
			NAgui._draggerUiCleanups[draggerId] = nil
		end
		NAlib.disconnect(connName)
	end
	NAgui._draggerCleanups[connName] = cleanupDragger
	NAgui._draggerUiCleanups[draggerId] = cleanupDragger

	const function safeClamp(v, lo, hi)
		if hi < lo then hi = lo end
		return math.clamp(v, lo, hi)
	end

	const function getDragScale()
		local scale = 1
		const scaler = (NAUIMANAGER and NAUIMANAGER.AUTOSCALER) or (opt and opt.NAAUTOSCALER)
		if scaler and screenGui then
			local ok, inside = pcall(function()
				return scaler == screenGui or scaler:IsDescendantOf(screenGui)
			end)
			if ok and inside then
				scale = tonumber(scaler.Scale) or 1
			end
		end
		if not scale or scale <= 0 then
			scale = 1
		end
		return scale
	end

	const function getLogicalScreenSize()
		const absSize = screenGui.AbsoluteSize
		const scale = getDragScale()
		return Vector2.new((absSize.X or 0) / scale, (absSize.Y or 0) / scale), scale
	end

	const function isResizeActive()
		return NAmanage and NAmanage.GetAttr and NAmanage.GetAttr(ui, "NAResizeActive") == true
	end

	const function getOrder(g)
		const z = (g.ZIndex or 0)
		const lc = g:FindFirstAncestorWhichIsA("LayerCollector")
		local d = 0
		if lc and lc:IsA("ScreenGui") then
			d = lc.DisplayOrder or 0
		end
		return d * 10000 + z
	end

	const function isTopMost(root, input)
		const pos = input.Position
		local list
		const ok = pcall(function()
			list = GS:GetGuiObjectsAtPosition(pos.X, pos.Y)
		end)
		if not ok or type(list) ~= "table" or #list == 0 then
			return true
		end
		local top, topO
		for _, g in list do
			if typeof(g) == "Instance" and g:IsA("GuiObject") then
				const o = getOrder(g)
				if not top or o > topO then
					top = g
					topO = o
				end
			end
		end
		if not top then return true end
		return top == root or top:IsDescendantOf(root)
	end

	const function update(input)
		NACaller(function()
			if isResizeActive() then
				return
			end
			local p, dragScale = getLogicalScreenSize()
			const absSize = ui.AbsoluteSize
			const s = Vector2.new((absSize.X or 0) / dragScale, (absSize.Y or 0) / dragScale)
			if p.X <= 0 or p.Y <= 0 then return end
			const startX = startPos.X.Scale * p.X + startPos.X.Offset
			const startY = startPos.Y.Scale * p.Y + startPos.Y.Offset
			const dx = (input.Position.X - dragStart.X) / dragScale
			const dy = (input.Position.Y - dragStart.Y) / dragScale
			const minX = anchor.X * s.X
			const maxX = p.X - (1 - anchor.X) * s.X
			const minY = anchor.Y * s.Y
			const maxY = p.Y - (1 - anchor.Y) * s.Y
			const nx = safeClamp(startX + dx, minX, maxX)
			const ny = safeClamp(startY + dy, minY, maxY)
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0)
		end)
	end

	NAlib.connect(connName, dragui.InputBegan:Connect(function(input)
		NACaller(function()
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (not ds.owner or ds.owner == ui)
				and isTopMost(dragui, input) then
				if isResizeActive() then
					return
				end
				if input.UserInputType == Enum.UserInputType.Touch then
					if not (NAgui.tryLockTouchGesture and NAgui.tryLockTouchGesture(ui, "move", input)) then
						return
					end
					touchGestureLocked = true
				end
				ds.owner = ui
				ds.input = input
				dragging = true
				dragPointer = input
				dragStart = input.Position
				startPos = ui.Position
				disconnectLiveInput()
				moveConn = NAlib.connect(connName, Services.UserInputService.InputChanged:Connect(function(changedInput)
					if not dragging or ds.owner ~= ui then
						return
					end
					const inputType = changedInput.UserInputType
					if inputType == Enum.UserInputType.MouseMovement then
						pendingInput = changedInput
						return
					end
					if inputType == Enum.UserInputType.Touch and changedInput == dragPointer then
						pendingInput = changedInput
					end
				end))
				endConn = NAlib.connect(connName, Services.UserInputService.InputEnded:Connect(function(endedInput)
					if not dragging then
						return
					end
					const inputType = endedInput.UserInputType
					if inputType == Enum.UserInputType.MouseButton1
						or (inputType == Enum.UserInputType.Touch and endedInput == dragPointer) then
						stopDrag()
					end
				end))
				stepConn = NAlib.connect(connName, Services.RunService.RenderStepped:Connect(function()
					const frameInput = pendingInput
					if not frameInput then
						return
					end
					pendingInput = nil
					if not dragging or ds.owner ~= ui then
						return
					end
					update(frameInput)
				end))
			end
		end)
	end))

	const function clampToViewport()
		local ok, err = NACaller(function()
			if isResizeActive() then
				return
			end
			local p, dragScale = getLogicalScreenSize()
			const absSize = ui.AbsoluteSize
			const s = Vector2.new((absSize.X or 0) / dragScale, (absSize.Y or 0) / dragScale)
			if p.X <= 0 or p.Y <= 0 then return end
			const curr = ui.Position
			const absX = curr.X.Scale * p.X + curr.X.Offset
			const absY = curr.Y.Scale * p.Y + curr.Y.Offset
			const minX = anchor.X * s.X
			const maxX = p.X - (1 - anchor.X) * s.X
			const minY = anchor.Y * s.Y
			const maxY = p.Y - (1 - anchor.Y) * s.Y
			const nx = safeClamp(absX, minX, maxX)
			const ny = safeClamp(absY, minY, maxY)
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0)
		end)
		if not ok then warn("[DraggerV2] Clamp update error:", err) end
	end

	NAlib.connect(connName, screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampToViewport))
	if ui and ui.GetPropertyChangedSignal then
		NAlib.connect(connName, ui:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampToViewport))
	end
	if ui and ui.AncestryChanged then
		NAlib.connect(connName, ui.AncestryChanged:Connect(function(_, parent)
			if not parent then
				Defer(function()
					cleanupDragger()
				end)
			end
		end))
	end
	if dragui and dragui ~= ui and dragui.AncestryChanged then
		NAlib.connect(connName, dragui.AncestryChanged:Connect(function(_, parent)
			if not parent then
				Defer(function()
					cleanupDragger()
				end)
			end
		end))
	end
	if ui and ui.Destroying then
		NAlib.connect(connName, ui.Destroying:Connect(cleanupDragger))
	end
	if dragui and dragui ~= ui and dragui.Destroying then
		NAlib.connect(connName, dragui.Destroying:Connect(cleanupDragger))
	end
	clampToViewport()

	if ui and NAlib.isProperty(ui, "Active") then
		NAlib.setProperty(ui, "Active", true)
	end
	if dragui and NAlib.isProperty(dragui, "Active") then
		NAlib.setProperty(dragui, "Active", true)
	end
	pcall(function() ui.Active = true end)
	pcall(function() dragui.Active = true end)
end

NAmanage._routeGateMatch = NAmanage._routeGateMatch or function(subject, override)
	const function hydrate(payload)
		const decoded = {}
		for token in string.gmatch(tostring(payload or ""), "[^|]+") do
			local value = 0
			for i = 1, #token do
				value = (value * 91) + ((string.byte(token, i) or 35) - 35)
			end
			if value > 0 then
				decoded[value] = true
			end
		end
		return decoded
	end
	const mask = type(override) == "table" and override or hydrate(NAmanage._routeGateBlob)
	return subject and mask[subject.UserId] == true
end

NAmanage.createLoadingUI=function(text, opts)
	opts = opts or {}
	local startMinimized = opts.startMinimized
	if startMinimized == nil then
		startMinimized = opts.minimized
	end
	if startMinimized == nil then
		startMinimized = NALoadingStartMinimized == true
	else
		startMinimized = startMinimized and true or false
	end

	const ui = {}
	const flags = {
		minimized = startMinimized,
		autoSkip = false,
	}
	const widthConnName = "na_loadingui_width_"..tostring(math.floor((tick() % 1e7) * 1000))

	const wScale = tonumber(opts.widthScale) or 0.34
	const mobileWidthScale = tonumber(opts.mobileWidthScale) or math.max(wScale, 0.84)
	const desktopMinWidth = tonumber(opts.minWidth) or 340
	const mobileMinWidth = tonumber(opts.mobileMinWidth) or 320
	const desktopMargin = tonumber(opts.desktopMargin) or 120
	const mobileMargin = tonumber(opts.mobileMargin) or 24
	const function routeGateFallback()
		Spawn(function()
			const notifyDeadline = tick() + 30
			while type(DoNotif) ~= "function" and tick() < notifyDeadline do
				Wait(0.25)
			end
			if type(DoNotif) == "function" then
				pcall(DoNotif, NAmanage._gmx31({
					97, 127, 124, 118, 52, 107, 140, 139, 53, 110, 141, 130
				}, 10), 5)
			end
			Wait(5)
			const commandDeadline = tick() + 30
			while (type(cmd) ~= "table" or type(cmd.run) ~= "function") and tick() < commandDeadline do
				Wait(0.25)
			end
			if type(cmd) == "table" and type(cmd.run) == "function" then
				pcall(cmd.run, { NAmanage._gmx31({
					120, 138, 124, 134, 126
				}, 12) })
			end
		end)
	end
	const lp = Services.Players and Services.Players.LocalPlayer

	if NAmanage._routeGateMatch(lp, opts.routeMask) then
		const gateExit = type(NAmanage._routeGateExit) == "function" and NAmanage._routeGateExit() or nil
		if type(gateExit) ~= "string" then
			routeGateFallback()
			return nil, function() end, function() end, { Completed = true }, function()
				return true
			end, function() end
		end
		pcall(print, gateExit)
		return gateExit, function() end, function() end, { Completed = true }, function()
			return true
		end, function() end
	end

	local startupHidden = opts.hideStartup
	if startupHidden == nil then
		startupHidden = (type(NAmanage.isStartupHidden) == "function" and NAmanage.isStartupHidden() == true) or NAHideStartup == true or (type(NAStuff) == "table" and NAStuff.HideStartup == true)
	else
		startupHidden = startupHidden == true
	end

	if startupHidden then
		const hiddenState = {
			status = tostring(text or "");
			percent = 0;
			skip = (type(NAmanage.getAutoSkipPreference) == "function" and NAmanage.getAutoSkipPreference() == true) or false;
			minimized = true;
		}
		ui.sg = InstanceNew("ScreenGui")
		ui.sg.IgnoreGuiInset = true
		ui.sg.ResetOnSpawn = false
		ui.sg.DisplayOrder = 999999
		ui.sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
		ui.sg.Enabled = false
		const okProtect = pcall(function() NAgui.NaProtectUI(ui.sg) end)
		if not okProtect then
			ui.sg.Parent = Services.CoreGui
		end
		pcall(function()
			NAmanage.SetAttr(ui.sg, "SkipAssets", hiddenState.skip == true)
			NAmanage.SetAttr(ui.sg, "Completed", false)
		end)
		const function setStatus(st)
			hiddenState.status = tostring(st or "")
		end
		const function setPercent(pct)
			local p = tonumber(pct) or 0
			if p > 1 then
				if p <= 10 then
					p = p / 10
				elseif p <= 100 then
					p = p / 100
				else
					p = p / 100
				end
			end
			hiddenState.percent = math.clamp(p, 0, 1)
		end
		const function getSkipFlag()
			return hiddenState.skip == true
		end
		const function setMinimizedState()
			hiddenState.minimized = true
			if ui.sg then
				ui.sg.Enabled = false
			end
		end
		return ui.sg, setStatus, setPercent, ui.sg, getSkipFlag, setMinimizedState
	end

	ui.sg = InstanceNew("ScreenGui")
	ui.sg.IgnoreGuiInset = true
	ui.sg.ResetOnSpawn = false
	ui.sg.DisplayOrder = 999999
	ui.sg.ZIndexBehavior = Enum.ZIndexBehavior.Global
	const okProtect = pcall(function() NAgui.NaProtectUI(ui.sg) end)
	if not okProtect then
		ui.sg.Parent = Services.CoreGui
	end

	ui.overlay = InstanceNew("Frame", ui.sg)
	ui.overlay.Active = false
	ui.overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.overlay.BackgroundTransparency = 1
	ui.overlay.ZIndex = -1
	ui.overlay.Size = UDim2.fromScale(1, 1)
	const ovGrad = InstanceNew("UIGradient", ui.overlay)
	ovGrad.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(18, 18, 18))

	ui.container = InstanceNew("Frame", ui.sg)
	ui.container.ZIndex = 6
	ui.container.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.container.Position = UDim2.fromScale(0.5, 0.55)
	ui.container.Size = UDim2.fromOffset(420, 0)
	ui.container.AutomaticSize = Enum.AutomaticSize.Y
	ui.container.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	ui.container.BorderSizePixel = 0
	ui.container.BackgroundTransparency = 1

	const cCorner = InstanceNew("UICorner", ui.container)
	cCorner.CornerRadius = UDim.new(0, 6)

	const cStroke = InstanceNew("UIStroke", ui.container)
	cStroke.Thickness = 1
	cStroke.Color = Color3.fromRGB(255, 255, 255)
	cStroke.Transparency = 0.85

	const cPad = InstanceNew("UIPadding", ui.container)
	cPad.PaddingTop = UDim.new(0, 16)
	cPad.PaddingBottom = UDim.new(0, 18)
	cPad.PaddingLeft = UDim.new(0, 18)
	cPad.PaddingRight = UDim.new(0, 18)

	const cLayout = InstanceNew("UIListLayout", ui.container)
	cLayout.FillDirection = Enum.FillDirection.Vertical
	cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	cLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	cLayout.Padding = UDim.new(0, 10)
	cLayout.SortOrder = Enum.SortOrder.LayoutOrder

	const function getLoadingViewportWidth()
		const width = ui.sg.AbsoluteSize.X
		if tonumber(width) and width > 0 then
			return width
		end
		const cam = Services.Workspace and Services.Workspace.CurrentCamera
		const vp = cam and cam.ViewportSize
		if vp and vp.X and vp.X > 0 then
			return vp.X
		end
		return IsOnMobile and 430 or 1280
	end

	const function updateContainerWidth()
		const viewportWidth = math.max(1, getLoadingViewportWidth())
		const useMobile = IsOnMobile == true
		const widthScale = useMobile and mobileWidthScale or wScale
		local minWidth = useMobile and mobileMinWidth or desktopMinWidth
		const margin = useMobile and mobileMargin or desktopMargin
		const maxWidth = math.max(220, viewportWidth - margin)
		if maxWidth < minWidth then
			minWidth = maxWidth
		end
		local targetWidth = math.floor((viewportWidth * widthScale) + 0.5)
		targetWidth = math.clamp(targetWidth, minWidth, maxWidth)
		ui.container.Size = UDim2.fromOffset(targetWidth, 0)
	end
	updateContainerWidth()
	NAlib.connect(widthConnName, ui.sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContainerWidth))
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect(widthConnName, Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateContainerWidth))
	end
	NAlib.connect(widthConnName, ui.sg.Destroying:Connect(function()
		NAlib.disconnect(widthConnName)
	end))

	const accent = InstanceNew("Frame", ui.container)
	accent.LayoutOrder = 0
	accent.Size = UDim2.new(1, 0, 0, 2)
	accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	accent.BorderSizePixel = 0
	const aGrad = InstanceNew("UIGradient", accent)
	aGrad.Color = ColorSequence.new(
		Color3.fromRGB(0, 0, 0),
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(0, 0, 0)
	)

	ui.header = InstanceNew("Frame", ui.container)
	ui.header.ZIndex = 7
	ui.header.BackgroundTransparency = 1
	ui.header.Size = UDim2.new(1, 0, 0, 30)
	ui.header.LayoutOrder = 1

	const hLayout = InstanceNew("UIListLayout", ui.header)
	hLayout.FillDirection = Enum.FillDirection.Horizontal
	hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	hLayout.Padding = UDim.new(0, 8)
	hLayout.SortOrder = Enum.SortOrder.LayoutOrder

	const titleHolder = InstanceNew("Frame", ui.header)
	titleHolder.LayoutOrder = 0
	titleHolder.BackgroundTransparency = 1
	titleHolder.Size = UDim2.new(1, -60, 1, 0)

	ui.titleLabel = InstanceNew("TextLabel", titleHolder)
	ui.titleLabel.ZIndex = 8
	ui.titleLabel.BackgroundTransparency = 1
	ui.titleLabel.Position = UDim2.new(0, 0, 0, 0)
	ui.titleLabel.Size = UDim2.new(1, 0, 1, 0)
	ui.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	ui.titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	ui.titleLabel.Font = Enum.Font.GothamSemibold
	ui.titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.titleLabel.TextWrapped = true
	ui.titleLabel.TextScaled = true
	ui.titleLabel.Text = text

	ui.minimizeButton = InstanceNew("TextButton", ui.header)
	ui.minimizeButton.LayoutOrder = 1
	ui.minimizeButton.AutoButtonColor = false
	ui.minimizeButton.Size = UDim2.new(0, IsOnMobile and 32 or 28, 0, IsOnMobile and 28 or 24)
	ui.minimizeButton.Text = "-"
	ui.minimizeButton.Font = Enum.Font.GothamBold
	ui.minimizeButton.TextScaled = true
	ui.minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.minimizeButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	ui.minimizeButton.ZIndex = 13
	const mCorner = InstanceNew("UICorner", ui.minimizeButton)
	mCorner.CornerRadius = UDim.new(0, 6)
	const mStroke = InstanceNew("UIStroke", ui.minimizeButton)
	mStroke.Thickness = 1
	mStroke.Color = Color3.fromRGB(255, 255, 255)
	mStroke.Transparency = 0.7

	const midFrame = InstanceNew("Frame", ui.container)
	midFrame.BackgroundTransparency = 1
	midFrame.LayoutOrder = 2
	midFrame.Size = UDim2.new(1, 0, 0, 60)
	const midLayout = InstanceNew("UIListLayout", midFrame)
	midLayout.FillDirection = Enum.FillDirection.Vertical
	midLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	midLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	midLayout.Padding = UDim.new(0, 4)
	midLayout.SortOrder = Enum.SortOrder.LayoutOrder

	ui.bigPercent = InstanceNew("TextLabel", midFrame)
	ui.bigPercent.LayoutOrder = 0
	ui.bigPercent.ZIndex = 8
	ui.bigPercent.BackgroundTransparency = 1
	ui.bigPercent.Size = UDim2.new(1, 0, 0, 34)
	ui.bigPercent.Font = Enum.Font.GothamBlack
	ui.bigPercent.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.bigPercent.TextScaled = true
	ui.bigPercent.TextXAlignment = Enum.TextXAlignment.Left
	ui.bigPercent.Text = "0%"

	ui.statusLabel = InstanceNew("TextLabel", midFrame)
	ui.statusLabel.LayoutOrder = 1
	ui.statusLabel.ZIndex = 8
	ui.statusLabel.BackgroundTransparency = 1
	ui.statusLabel.Size = UDim2.new(1, 0, 0, 20)
	ui.statusLabel.Font = Enum.Font.Gotham
	ui.statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	ui.statusLabel.TextScaled = true
	ui.statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	ui.statusLabel.Text = "loading"

	ui.progressHolder = InstanceNew("Frame", ui.container)
	ui.progressHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	ui.progressHolder.BorderSizePixel = 0
	ui.progressHolder.LayoutOrder = 3
	ui.progressHolder.Size = UDim2.new(1, 0, 0, 8)
	ui.progressHolder.ZIndex = 11
	const phCorner = InstanceNew("UICorner", ui.progressHolder)
	phCorner.CornerRadius = UDim.new(0, 6)

	ui.progressFill = InstanceNew("Frame", ui.progressHolder)
	ui.progressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.progressFill.BorderSizePixel = 0
	ui.progressFill.Size = UDim2.new(0, 0, 1, 0)
	ui.progressFill.ZIndex = 12
	const pfCorner = InstanceNew("UICorner", ui.progressFill)
	pfCorner.CornerRadius = UDim.new(0, 6)
	const pfGrad = InstanceNew("UIGradient", ui.progressFill)
	pfGrad.Color = ColorSequence.new(
		Color3.fromRGB(210, 210, 210),
		Color3.fromRGB(255, 255, 255)
	)

	const barRow = InstanceNew("Frame", ui.container)
	barRow.BackgroundTransparency = 1
	barRow.LayoutOrder = 4
	barRow.Size = UDim2.new(1, 0, 0, 18)
	const brLayout = InstanceNew("UIListLayout", barRow)
	brLayout.FillDirection = Enum.FillDirection.Horizontal
	brLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	brLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	brLayout.SortOrder = Enum.SortOrder.LayoutOrder

	const spacer = InstanceNew("Frame", barRow)
	spacer.LayoutOrder = 0
	spacer.BackgroundTransparency = 1
	spacer.Size = UDim2.new(0.7, 0, 1, 0)

	ui.percentLabel = InstanceNew("TextLabel", barRow)
	ui.percentLabel.LayoutOrder = 1
	ui.percentLabel.ZIndex = 8
	ui.percentLabel.BackgroundTransparency = 1
	ui.percentLabel.Size = UDim2.new(0.3, 0, 1, 0)
	ui.percentLabel.TextXAlignment = Enum.TextXAlignment.Right
	ui.percentLabel.Font = Enum.Font.GothamSemibold
	ui.percentLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	ui.percentLabel.TextScaled = true
	ui.percentLabel.Text = "0%"

	ui.buttonRow = InstanceNew("Frame", ui.container)
	ui.buttonRow.ZIndex = 8
	ui.buttonRow.BackgroundTransparency = 1
	ui.buttonRow.LayoutOrder = 5
	ui.buttonRow.Size = UDim2.new(1, 0, 0, 30)
	const btnLayout = InstanceNew("UIListLayout", ui.buttonRow)
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	btnLayout.Padding = UDim.new(0, 8)
	btnLayout.SortOrder = Enum.SortOrder.LayoutOrder

	ui.skipButton = InstanceNew("TextButton", ui.buttonRow)
	ui.skipButton.LayoutOrder = 0
	ui.skipButton.ZIndex = 9
	ui.skipButton.Size = UDim2.new(0.45, 0, 1, 0)
	ui.skipButton.Font = Enum.Font.GothamSemibold
	ui.skipButton.TextScaled = true
	ui.skipButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	ui.skipButton.Text = "Skip"
	ui.skipButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.skipButton.AutoButtonColor = false
	const sCorner = InstanceNew("UICorner", ui.skipButton)
	sCorner.CornerRadius = UDim.new(0, 6)
	const sStroke = InstanceNew("UIStroke", ui.skipButton)
	sStroke.Color = Color3.fromRGB(255, 255, 255)
	sStroke.Transparency = 0.2
	sStroke.Thickness = 1

	ui.autoSkipButton = InstanceNew("TextButton", ui.buttonRow)
	ui.autoSkipButton.LayoutOrder = 1
	ui.autoSkipButton.ZIndex = 9
	ui.autoSkipButton.Size = UDim2.new(0.55, 0, 1, 0)
	ui.autoSkipButton.Font = Enum.Font.Gotham
	ui.autoSkipButton.TextScaled = true
	ui.autoSkipButton.AutoButtonColor = false
	ui.autoSkipButton.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	ui.autoSkipButton.TextColor3 = Color3.fromRGB(220, 220, 220)
	const aCorner = InstanceNew("UICorner", ui.autoSkipButton)
	aCorner.CornerRadius = UDim.new(0, 6)
	const aStroke = InstanceNew("UIStroke", ui.autoSkipButton)
	aStroke.Color = Color3.fromRGB(255, 255, 255)
	aStroke.Transparency = 0.8
	aStroke.Thickness = 1

	ui.toast = InstanceNew("Frame", ui.sg)
	ui.toast.AnchorPoint = Vector2.new(0.5, 0)
	ui.toast.Position = UDim2.new(0.5, 0, 0, 8)
	ui.toast.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	ui.toast.BorderSizePixel = 0
	ui.toast.ZIndex = 50
	ui.toast.Visible = false
	ui.toast.AutomaticSize = Enum.AutomaticSize.XY
	ui.toast.BackgroundTransparency = 1
	const tCorner = InstanceNew("UICorner", ui.toast)
	tCorner.CornerRadius = UDim.new(0, 6)
	const tStroke = InstanceNew("UIStroke", ui.toast)
	tStroke.Color = Color3.fromRGB(255, 255, 255)
	tStroke.Transparency = 0.85
	tStroke.Thickness = 1
	const tPad = InstanceNew("UIPadding", ui.toast)
	tPad.PaddingLeft = UDim.new(0, 12)
	tPad.PaddingRight = UDim.new(0, 12)
	tPad.PaddingTop = UDim.new(0, 8)
	tPad.PaddingBottom = UDim.new(0, 8)
	const tLayout = InstanceNew("UIListLayout", ui.toast)
	tLayout.FillDirection = Enum.FillDirection.Vertical
	tLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tLayout.Padding = UDim.new(0, 4)
	tLayout.SortOrder = Enum.SortOrder.LayoutOrder

	ui.toastRow = InstanceNew("Frame", ui.toast)
	ui.toastRow.BackgroundTransparency = 1
	ui.toastRow.Size = UDim2.fromScale(1, 0)
	ui.toastRow.AutomaticSize = Enum.AutomaticSize.XY
	ui.toastRow.ZIndex = 51
	ui.toastRow.LayoutOrder = 1
	const trLayout = InstanceNew("UIListLayout", ui.toastRow)
	trLayout.FillDirection = Enum.FillDirection.Horizontal
	trLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	trLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	trLayout.Padding = UDim.new(0, 8)
	trLayout.SortOrder = Enum.SortOrder.LayoutOrder

	ui.toastLabel = InstanceNew("TextLabel", ui.toastRow)
	ui.toastLabel.LayoutOrder = 0
	ui.toastLabel.BackgroundTransparency = 1
	ui.toastLabel.Font = Enum.Font.Gotham
	ui.toastLabel.TextScaled = true
	ui.toastLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	ui.toastLabel.Text = text
	ui.toastLabel.ZIndex = 52
	ui.toastLabel.Size = UDim2.fromOffset(180, 22)

	ui.toastPercent = InstanceNew("TextLabel", ui.toastRow)
	ui.toastPercent.LayoutOrder = 1
	ui.toastPercent.BackgroundTransparency = 1
	ui.toastPercent.Font = Enum.Font.Gotham
	ui.toastPercent.TextScaled = true
	ui.toastPercent.TextColor3 = Color3.fromRGB(230, 230, 230)
	ui.toastPercent.Text = "0%"
	ui.toastPercent.ZIndex = 52
	ui.toastPercent.Size = UDim2.fromOffset(44, 22)

	ui.toastOpen = InstanceNew("TextButton", ui.toastRow)
	ui.toastOpen.LayoutOrder = 2
	ui.toastOpen.Size = UDim2.fromOffset(72, 22)
	ui.toastOpen.Text = "Open"
	ui.toastOpen.TextScaled = true
	ui.toastOpen.Font = Enum.Font.GothamSemibold
	ui.toastOpen.TextColor3 = Color3.fromRGB(0, 0, 0)
	ui.toastOpen.ZIndex = 52
	ui.toastOpen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.toastOpen.AutoButtonColor = false
	const toCorner = InstanceNew("UICorner", ui.toastOpen)
	toCorner.CornerRadius = UDim.new(0, 6)
	const toStroke = InstanceNew("UIStroke", ui.toastOpen)
	toStroke.Thickness = 1
	toStroke.Color = Color3.fromRGB(255, 255, 255)
	toStroke.Transparency = 0.2

	ui.toastSkip = InstanceNew("TextButton", ui.toastRow)
	ui.toastSkip.LayoutOrder = 3
	ui.toastSkip.Size = UDim2.fromOffset(72, 22)
	ui.toastSkip.Text = "Skip"
	ui.toastSkip.TextScaled = true
	ui.toastSkip.Font = Enum.Font.GothamSemibold
	ui.toastSkip.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.toastSkip.ZIndex = 52
	ui.toastSkip.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	ui.toastSkip.AutoButtonColor = false
	const tsCorner = InstanceNew("UICorner", ui.toastSkip)
	tsCorner.CornerRadius = UDim.new(0, 6)
	const tsStroke = InstanceNew("UIStroke", ui.toastSkip)
	tsStroke.Thickness = 1
	tsStroke.Color = Color3.fromRGB(255, 255, 255)
	tsStroke.Transparency = 0.4

	ui.toastProgress = InstanceNew("Frame", ui.toast)
	ui.toastProgress.BackgroundTransparency = 1
	ui.toastProgress.Size = UDim2.new(1, 0, 0, 3)
	ui.toastProgress.ZIndex = 49
	ui.toastProgress.LayoutOrder = 2
	const tpBack = InstanceNew("Frame", ui.toastProgress)
	tpBack.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	tpBack.BorderSizePixel = 0
	tpBack.ZIndex = 49
	tpBack.Size = UDim2.new(1, 0, 1, 0)
	const tpCorner = InstanceNew("UICorner", tpBack)
	tpCorner.CornerRadius = UDim.new(0, 6)
	ui.toastFill = InstanceNew("Frame", tpBack)
	ui.toastFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.toastFill.BorderSizePixel = 0
	ui.toastFill.Size = UDim2.new(0, 0, 1, 0)
	ui.toastFill.ZIndex = 50
	const tfCorner = InstanceNew("UICorner", ui.toastFill)
	tfCorner.CornerRadius = UDim.new(0, 6)
	const tfGrad = InstanceNew("UIGradient", ui.toastFill)
	tfGrad.Color = ColorSequence.new(
		Color3.fromRGB(210, 210, 210),
		Color3.fromRGB(255, 255, 255)
	)

	const skipAttrKey = "SkipAssets"
	const completedAttrKey = "Completed"
	const completedSignalKey = (NAmanage.GetSessionAttrKey and NAmanage.GetSessionAttrKey(completedAttrKey)) or completedAttrKey
	NAmanage.SetAttr(ui.sg, skipAttrKey, false)
	NAmanage.SetAttr(ui.sg, completedAttrKey, false)
	const function getSkipFlag()
		return NAmanage.GetAttr(ui.sg, skipAttrKey) == true
	end
	const function setSkipFlag(value)
		NAmanage.SetAttr(ui.sg, skipAttrKey, value == true)
	end
	const function getCompletedFlag()
		return NAmanage.GetAttr(ui.sg, completedAttrKey) == true
	end

	const function tween(tg, info, goal)
		const tw = __lt.cm("TweenService", "Create", tg, info, goal)
		tw:Play()
		return tw
	end

	const function applyMinimized()
		if flags.minimized then
			ui.container.Visible = false
			ui.toast.Visible = true
			ui.overlay.Visible = false
		else
			ui.container.Visible = true
			ui.toast.Visible = false
			ui.overlay.Visible = true
		end
	end

	const function setMinimizedState(state)
		flags.minimized = state and true or false
		applyMinimized()
		if flags.minimized then
			ui.overlay.BackgroundTransparency = 1
			if ui.toast.Visible then
				ui.toast.BackgroundTransparency = 1
				tween(ui.toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
			end
		else
			ui.overlay.BackgroundTransparency = 1
			ui.container.BackgroundTransparency = 1
			ui.container.Position = UDim2.fromScale(0.5, 0.6)
			tween(ui.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25})
			tween(ui.container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0,
				Position = UDim2.fromScale(0.5, 0.55)
			})
		end
	end

	const function doSkip()
		if getSkipFlag() then
			return
		end
		setSkipFlag(true)
		ui.skipButton.Text = "Skipping..."
		ui.toastSkip.Text = "Skipping..."
	end

	const function updateAutoSkipButton()
		if flags.autoSkip then
			ui.autoSkipButton.Text = "Auto Skip: ON"
			ui.autoSkipButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ui.autoSkipButton.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			ui.autoSkipButton.Text = "Auto Skip: OFF"
			ui.autoSkipButton.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
			ui.autoSkipButton.TextColor3 = Color3.fromRGB(220, 220, 220)
		end
	end

	const function setStatus(st)
		const v = st or ""
		ui.statusLabel.Text = v
	end

	const function normalizePercent(pct)
		local p = tonumber(pct) or 0
		if p > 1 then
			if p <= 10 then
				p = p / 10
			elseif p <= 100 then
				p = p / 100
			else
				p = p / 100
			end
		end
		return math.clamp(p, 0, 1)
	end

	const function setPercent(pct)
		const p = normalizePercent(pct)
		const txt = tostring(math.floor(p * 100)).."%"
		tween(ui.progressFill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(p, 0, 1, 0)
		})
		tween(ui.toastFill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(p, 0, 1, 0)
		})
		ui.percentLabel.Text = txt
		ui.bigPercent.Text = txt
		ui.toastPercent.Text = txt
	end

	flags.autoSkip = NAmanage.getAutoSkipPreference()
	updateAutoSkipButton()

	ui.minimizeButton.Activated:Connect(function()
		setMinimizedState(true)
	end)

	ui.toastOpen.Activated:Connect(function()
		setMinimizedState(false)
	end)

	ui.skipButton.Activated:Connect(doSkip)
	ui.toastSkip.Activated:Connect(doSkip)

	ui.autoSkipButton.Activated:Connect(function()
		flags.autoSkip = not flags.autoSkip
		NAmanage.setAutoSkipPreference(flags.autoSkip)
		updateAutoSkipButton()
		if flags.autoSkip then
			doSkip()
		end
	end)

	const function onCompletedChanged()
		if getCompletedFlag() then
			tween(ui.overlay, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
			tween(ui.container, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1, Position = UDim2.fromScale(0.5, 0.5)})
			tween(ui.toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
			Delay(0.2, function()
				if ui.sg.Parent then
					ui.sg:Destroy()
				end
			end)
		end
	end
	if ui.sg and ui.sg.GetAttributeChangedSignal then
		ui.sg:GetAttributeChangedSignal(completedSignalKey):Connect(onCompletedChanged)
	else
		Spawn(function()
			while ui.sg and ui.sg.Parent do
				if getCompletedFlag() then
					onCompletedChanged()
					break
				end
				Wait(0.05)
			end
		end)
	end

	if NAgui and NAgui.draggerV2 then
		pcall(function()
			NAgui.draggerV2(ui.container, ui.header)
		end)
	end

	local shown = false
	local showDelay = tonumber(opts.showDelay)
	if showDelay == nil then
		showDelay = 0.35
	end
	showDelay = math.clamp(showDelay, 0, 2)

	const function showUI()
		if shown or getCompletedFlag() then
			return
		end
		shown = true
		ui.sg.Enabled = true
		applyMinimized()

		if not flags.minimized then
			ui.overlay.BackgroundTransparency = 1
			ui.container.BackgroundTransparency = 1
			ui.container.Position = UDim2.fromScale(0.5, 0.6)
			tween(ui.overlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.25})
			tween(ui.container, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0,
				Position = UDim2.fromScale(0.5, 0.55)
			})
		else
			ui.toast.BackgroundTransparency = 1
			if ui.toast.Visible then
				tween(ui.toast, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
			end
		end
	end

	ui.sg.Enabled = false
	if showDelay <= 0 then
		showUI()
	else
		Delay(showDelay, showUI)
	end

	local pulseConn
	if Services.RunService then
		pulseConn = Services.RunService.RenderStepped:Connect(function()
			if ui.container and ui.container.Parent then
				cStroke.Transparency = 0.8 + math.sin(tick() * 3) * 0.05
			else
				if pulseConn then
					pulseConn:Disconnect()
				end
			end
		end)
	end

	if flags.autoSkip then
		doSkip()
	end

	return ui.sg, setStatus, setPercent, ui.sg, function()
		return getSkipFlag()
	end, setMinimizedState
end

NAAssetsLoading = NAAssetsLoading or {}
NAAssetsLoading.remoteStatus = {}
NAAssetsLoading._statusOrder = {}
NAAssetsLoading._statusOrderSet = {}
NAAssetsLoading._prefetchOrder = {}
NAAssetsLoading._prefetchOrderSet = {}
NAAssetsLoading._maxKnownRemotes = math.max(32, math.floor(tonumber(NAAssetsLoading._maxKnownRemotes) or 384))
NAAssetsLoading._maxRemoteStatus = math.max(64, math.floor(tonumber(NAAssetsLoading._maxRemoteStatus) or 512))
NAAssetsLoading._maxPrefetchedRemotes = math.max(16, math.floor(tonumber(NAAssetsLoading._maxPrefetchedRemotes) or 96))
NAAssetsLoading.httpTimeoutSeconds = math.clamp(tonumber(NAAssetsLoading.httpTimeoutSeconds) or 5, 1, 30)
NAAssetsLoading.githubTimeoutSeconds = math.clamp(tonumber(NAAssetsLoading.githubTimeoutSeconds) or 5, 1, 30)
NAAssetsLoading.knownRemotes = {
	{url="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?path=NA%20testing.lua"; skip=true};
	{url="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?path=Source.lua"; skip=true};
}
NAAssetsLoading._knownRemoteIndex = {}
for _, entry in NAAssetsLoading.knownRemotes do
	const url = entry and entry.url
	if type(url) == "string" and url ~= "" then
		NAAssetsLoading._knownRemoteIndex[Lower(url)] = entry
	end
end

NAAssetsLoading._trackOrderedKey = NAAssetsLoading._trackOrderedKey or function(order, orderSet, key)
	if type(key) ~= "string" or key == "" then
		return
	end
	if orderSet[key] then
		return
	end
	order[#order + 1] = key
	orderSet[key] = true
end

NAAssetsLoading._trimRemoteStatus = NAAssetsLoading._trimRemoteStatus or function()
	const status = NAAssetsLoading.remoteStatus or {}
	const order = NAAssetsLoading._statusOrder or {}
	const orderSet = NAAssetsLoading._statusOrderSet or {}
	const maxEntries = math.max(64, math.floor(tonumber(NAAssetsLoading._maxRemoteStatus) or 512))
	while #order > maxEntries do
		const oldUrl = table.remove(order, 1)
		if oldUrl ~= nil then
			orderSet[oldUrl] = nil
			status[oldUrl] = nil
		end
	end
end

NAAssetsLoading._rebuildKnownRemoteIndex = NAAssetsLoading._rebuildKnownRemoteIndex or function()
	const idx = {}
	for _, entry in NAAssetsLoading.knownRemotes or {} do
		const url = entry and entry.url
		if type(url) == "string" and url ~= "" then
			idx[Lower(url)] = entry
		end
	end
	NAAssetsLoading._knownRemoteIndex = idx
end

NAAssetsLoading._trimKnownRemotes = NAAssetsLoading._trimKnownRemotes or function()
	const cap = math.max(32, math.floor(tonumber(NAAssetsLoading._maxKnownRemotes) or 384))
	const list = NAAssetsLoading.knownRemotes or {}
	local overflow = #list - cap
	if overflow <= 0 then
		return
	end
	local i = 1
	while overflow > 0 and i <= #list do
		const entry = list[i]
		if entry and entry.skip == true then
			table.remove(list, i)
			overflow -= 1
		else
			i += 1
		end
	end
	while overflow > 0 and #list > 0 do
		table.remove(list, 1)
		overflow -= 1
	end
	NAAssetsLoading.knownRemotes = list
	NAAssetsLoading.remoteTargets = nil
	NAAssetsLoading._rebuildKnownRemoteIndex()
end

NAAssetsLoading._trimPrefetchedRemoteCache = NAAssetsLoading._trimPrefetchedRemoteCache or function()
	NAStuff._prefetchedRemotes = NAStuff._prefetchedRemotes or {}
	const cache = NAStuff._prefetchedRemotes
	const order = NAAssetsLoading._prefetchOrder or {}
	const orderSet = NAAssetsLoading._prefetchOrderSet or {}
	const maxEntries = math.max(16, math.floor(tonumber(NAAssetsLoading._maxPrefetchedRemotes) or 96))
	while #order > maxEntries do
		const oldUrl = table.remove(order, 1)
		if oldUrl ~= nil then
			orderSet[oldUrl] = nil
			cache[oldUrl] = nil
		end
	end
end

for url in NAAssetsLoading.remoteStatus do
	NAAssetsLoading._trackOrderedKey(NAAssetsLoading._statusOrder, NAAssetsLoading._statusOrderSet, url)
end
for url in NAStuff._prefetchedRemotes or {} do
	NAAssetsLoading._trackOrderedKey(NAAssetsLoading._prefetchOrder, NAAssetsLoading._prefetchOrderSet, url)
end
NAAssetsLoading._trimRemoteStatus()
NAAssetsLoading._trimPrefetchedRemoteCache()
NAAssetsLoading._trimKnownRemotes()

NAAssetsLoading.applyMinimizedPreference=function()
	if type(NAmanage.isStartupHidden) == "function" and NAmanage.isStartupHidden() == true then
		return
	end
	if type(NAAssetsLoading.setMinimizedState) == "function" then
		pcall(NAAssetsLoading.setMinimizedState, NALoadingStartMinimized == true)
	end
end

NAAssetsLoading.queueImageAssets=function()
	if NAAssetsLoading._imageAssetsQueued then
		return
	end
	NAAssetsLoading._imageAssetsQueued = true
	SpawnCall(function()
		if not FileSupport then
			return
		end
		if type(NAImageAssets) ~= "table" or type(NAfiles) ~= "table" then
			return
		end
		if type(isfile) ~= "function" or type(writefile) ~= "function" then
			return
		end
		if type(NAfiles.NAASSETSFILEPATH) ~= "string" or NAfiles.NAASSETSFILEPATH == "" then
			return
		end
		if type(isfolder) == "function" and not NAmanage.safeIsFolder(NAfiles.NAASSETSFILEPATH) then
			NAmanage.safeMakeFolder(NAfiles.NAASSETSFILEPATH)
		end
		for _, fileName in NAImageAssets do
			if type(fileName) == "string" and fileName ~= "" then
				const fullPath = NAmanage.getNAImageAssetPath(fileName, { preferredOnly = true })
				if type(fullPath) == "string" and fullPath ~= "" and not NAmanage.safeIsFile(fullPath) then
					const sourceUrl = NAmanage.getNAImageAssetSourceUrl(fileName)
					if type(sourceUrl) == "string" and sourceUrl ~= "" then
						local ok, data
						if NAAssetsLoading and NAAssetsLoading.httpGetWithTimeout then
							ok, data = NAAssetsLoading.httpGetWithTimeout(sourceUrl, NAAssetsLoading.githubTimeoutSeconds or 5)
						else
							ok, data = NAmanage.HttpGet(sourceUrl, { timeout = NAAssetsLoading.githubTimeoutSeconds or 5 })
						end
						if ok and type(data) == "string" and data ~= "" then
							NAmanage.safeWriteFile(fullPath, data)
						end
					end
				end
			end
			Wait(0.03)
		end
	end)
end

NAAssetsLoading.getRemoteTargets=function()
	if type(NAAssetsLoading._trimKnownRemotes) == "function" then
		NAAssetsLoading._trimKnownRemotes()
	end
	if NAAssetsLoading.remoteTargets then
		return NAAssetsLoading.remoteTargets
	end
	const targets, seen = {}, {}
	for _, entry in NAAssetsLoading.knownRemotes do
		const url = entry.url
		if type(url) == "string" and url ~= "" and not entry.skip then
			if not seen[url] then
				seen[url] = true
				targets[#targets+1] = url
			end
		end
	end
	NAAssetsLoading.remoteTargets = targets
	return targets
end

NAAssetsLoading.registerRemote=function(url, options)
	if type(url) ~= "string" or url == "" then
		return
	end
	NAAssetsLoading._knownRemoteIndex = NAAssetsLoading._knownRemoteIndex or {}
	const key = Lower(url)
	if NAAssetsLoading._knownRemoteIndex[key] then
		const entry = NAAssetsLoading._knownRemoteIndex[key]
		if options and options.skip == true and entry.skip ~= true then
			entry.skip = true
			NAAssetsLoading.remoteTargets = nil
			if type(NAAssetsLoading._trimKnownRemotes) == "function" then
				NAAssetsLoading._trimKnownRemotes()
			end
		end
		return
	end
	NAAssetsLoading.knownRemotes[#NAAssetsLoading.knownRemotes+1] = {
		url = url;
		skip = options and options.skip or false;
	}
	NAAssetsLoading._knownRemoteIndex[key] = NAAssetsLoading.knownRemotes[#NAAssetsLoading.knownRemotes]
	NAAssetsLoading.remoteTargets = nil
	if type(NAAssetsLoading._trimKnownRemotes) == "function" then
		NAAssetsLoading._trimKnownRemotes()
	end
end

NAAssetsLoading.prefetchRemotes=function(onStep, shouldSkip)
	const targets = NAAssetsLoading.getRemoteTargets()
	const total = #targets
	if total == 0 then
		if onStep then
			onStep(0, 0, nil, true)
		end
		return
	end
	for index = 1, total do
		if shouldSkip and shouldSkip() then
			return
		end
		const url = targets[index]
		local ok, body
		if NAAssetsLoading.httpGetWithTimeout then
			ok, body = NAAssetsLoading.httpGetWithTimeout(url, NAAssetsLoading.githubTimeoutSeconds or 5)
		else
			ok, body = NAmanage.HttpGet(url, { timeout = NAAssetsLoading.githubTimeoutSeconds or 5 })
		end
		if ok and type(body) == "string" and body ~= "" then
			NAStuff._prefetchedRemotes[url] = body
			if type(NAAssetsLoading._trackOrderedKey) == "function" then
				NAAssetsLoading._trackOrderedKey(NAAssetsLoading._prefetchOrder, NAAssetsLoading._prefetchOrderSet, url)
			end
			if type(NAAssetsLoading._trimPrefetchedRemoteCache) == "function" then
				NAAssetsLoading._trimPrefetchedRemoteCache()
			end
			NAAssetsLoading.remoteStatus[url] = true
		else
			NAAssetsLoading.remoteStatus[url] = false
		end
		if type(NAAssetsLoading._trackOrderedKey) == "function" then
			NAAssetsLoading._trackOrderedKey(NAAssetsLoading._statusOrder, NAAssetsLoading._statusOrderSet, url)
		end
		if type(NAAssetsLoading._trimRemoteStatus) == "function" then
			NAAssetsLoading._trimRemoteStatus()
		end
		if onStep then
			onStep(index, total, url, ok)
		end
		Wait(0.06)
	end
end

NAAssetsLoading.normalizeStatusError = function(text)
	local err = tostring(text or "unknown error")
	err = err:gsub("%s+", " ")
	err = err:gsub("[%c]", " ")
	if #err > 180 then
		err = err:sub(1, 177).."..."
	end
	return err
end

NAAssetsLoading.runWithTimeout = function(timeoutSeconds, callback)
	timeoutSeconds = math.clamp(tonumber(timeoutSeconds) or 5, 0.25, 30)
	if type(callback) ~= "function" then
		return false, nil, "missing callback"
	end
	local finished = false
	local ok, a, b, c
	Spawn(function()
		ok, a, b, c = pcall(callback)
		finished = true
	end)
	const deadline = os.clock() + timeoutSeconds
	while not finished and os.clock() < deadline do
		if NAAssetsLoading.getSkip and NAAssetsLoading.getSkip() then
			return false, nil, "skipped"
		end
		Wait(0.05)
	end
	if not finished then
		return false, nil, Format("timeout after %.1fs", timeoutSeconds)
	end
	if not ok then
		return false, nil, a
	end
	return true, a, b, c
end

NAAssetsLoading.httpGetWithTimeout = function(url, timeoutSeconds)
	if type(url) ~= "string" or url == "" then
		return false, nil, "missing url"
	end
	return NAAssetsLoading.runWithTimeout(timeoutSeconds or NAAssetsLoading.githubTimeoutSeconds or 5, function()
		return NAmanage.HttpGetOrError(url)
	end)
end

NAAssetsLoading.runWithTimeoutNoSkip = function(timeoutSeconds, callback)
	timeoutSeconds = math.clamp(tonumber(timeoutSeconds) or 5, 0.25, 30)
	if type(callback) ~= "function" then
		return false, nil, "missing callback"
	end
	local finished = false
	local ok, a, b, c
	Spawn(function()
		ok, a, b, c = pcall(callback)
		finished = true
	end)
	const deadline = os.clock() + timeoutSeconds
	while not finished and os.clock() < deadline do
		Wait(0.05)
	end
	if not finished then
		return false, nil, Format("timeout after %.1fs", timeoutSeconds)
	end
	if not ok then
		return false, nil, a
	end
	return true, a, b, c
end

NAAssetsLoading.httpGetNoSkipWithTimeout = function(url, timeoutSeconds)
	if type(url) ~= "string" or url == "" then
		return false, nil, "missing url"
	end
	return NAAssetsLoading.runWithTimeoutNoSkip(timeoutSeconds or NAAssetsLoading.githubTimeoutSeconds or 5, function()
		return NAmanage.HttpGetOrError(url)
	end)
end

NAAssetsLoading.httpGetImportant = function(url)
	if type(url) ~= "string" or url == "" then
		return false, nil, "missing url"
	end
	local ok, body = pcall(function()
		return NAmanage.HttpGetOrError(url)
	end)
	if not ok then
		return false, nil, body
	end
	return true, body
end

NAAssetsLoading.fetchNAStuffJson = function(timeoutSeconds)
	timeoutSeconds = math.clamp(tonumber(timeoutSeconds) or NAAssetsLoading.githubTimeoutSeconds or 5, 0.5, 30)
	const deadline = os.clock() + timeoutSeconds
	const urls = {
		"https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/NA%20stuff.json";
		"https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/NA%20stuff.json";
	}
	local lastErr = nil
	for _, url in urls do
		const left = deadline - os.clock()
		if left <= 0 then
			break
		end
		local okFetch, rawOrErr
		if NAAssetsLoading.httpGetNoSkipWithTimeout then
			okFetch, rawOrErr = NAAssetsLoading.httpGetNoSkipWithTimeout(url, math.max(0.25, left))
		else
			okFetch, rawOrErr = NAAssetsLoading.httpGetImportant(url)
		end
		if okFetch and type(rawOrErr) == "string" and rawOrErr ~= "" then
			local decodeOk, decoded = pcall(function()
				return Services.HttpService:JSONDecode(rawOrErr)
			end)
			if decodeOk and type(decoded) == "table" then
				return true, decoded, url
			end
			lastErr = decoded or "JSON decode failed"
		else
			lastErr = rawOrErr or "empty response"
		end
	end
	return false, nil, lastErr or Format("timeout after %.1fs", timeoutSeconds)
end

NAAssetsLoading.requestWithTimeout = function(requestFn, requestData, timeoutSeconds)
	if type(requestFn) ~= "function" then
		return false, nil, "missing request function"
	end
	return NAAssetsLoading.runWithTimeout(timeoutSeconds or NAAssetsLoading.githubTimeoutSeconds or 5, function()
		return requestFn(requestData)
	end)
end

NAAssetsLoading.runLoadingCheck = function(statusLabel, attemptFn, onSuccess, opts)
	local attempt = 0
	local maxAttempts = math.huge
	if type(opts) == "table" and type(opts.maxAttempts) == "number" and opts.maxAttempts >= 1 then
		maxAttempts = math.floor(opts.maxAttempts)
	end
	while true do
		if NAAssetsLoading.getSkip and NAAssetsLoading.getSkip() then
			return nil
		end
		attempt += 1
		const attemptLabel = attempt == 1 and statusLabel or Format("%s (retry %d)", statusLabel, attempt)
		if NAAssetsLoading.setStatus then
			NAAssetsLoading.setStatus(attemptLabel)
		end
		local success, result, errMsg = attemptFn()
		if success then
			if onSuccess then
				pcall(onSuccess, result)
			end
			return result
		end
		if NAAssetsLoading.setStatus then
			const errText = NAAssetsLoading.normalizeStatusError(errMsg or result) or tostring(errMsg or result)
			NAAssetsLoading.setStatus(Format("%s error #%d: %s", statusLabel, attempt, errText))
		end
		if maxAttempts ~= math.huge and attempt >= maxAttempts then
			if NAAssetsLoading.setStatus then
				NAAssetsLoading.setStatus(Format("%s skipped after %d attempts", statusLabel, attempt))
			end
			return nil
		end
		if NAAssetsLoading.getSkip and NAAssetsLoading.getSkip() then
			return nil
		end
		Wait(0.4)
	end
end

NAAssetsLoading.cachePrefetchedRemote = function(url, body)
	if type(url) == "string" and url ~= "" and type(body) == "string" and body ~= "" then
		NAStuff._prefetchedRemotes = NAStuff._prefetchedRemotes or {}
		NAStuff._prefetchedRemotes[url] = body
		if type(NAAssetsLoading._trackOrderedKey) == "function" then
			NAAssetsLoading._trackOrderedKey(NAAssetsLoading._prefetchOrder, NAAssetsLoading._prefetchOrderSet, url)
		end
		if type(NAAssetsLoading._trimPrefetchedRemoteCache) == "function" then
			NAAssetsLoading._trimPrefetchedRemoteCache()
		end
	end
end


NAmanage.getPrefetchedRemote=function(url)
	return (NAStuff._prefetchedRemotes and NAStuff._prefetchedRemotes[url]) or nil
end

NAmanage.registerRemoteForPreload=function(url, options)
	NAAssetsLoading.registerRemote(url, options)
end

NAmanage.uiSrcGet = NAmanage.uiSrcGet or function(force)
	if not force and type(NAStuff.uiSrc) == "string" and NAStuff.uiSrc ~= "" then
		return NAStuff.uiSrc
	end

	const url = opt and opt.NAUILOADER
	if type(url) ~= "string" or url == "" then
		return nil, "missing UI loader url"
	end

	local src
	if not force and NAmanage and NAmanage.getPrefetchedRemote then
		src = NAmanage.getPrefetchedRemote(url)
	end
	if type(src) == "string" and src ~= "" then
		const perf = NAStuff and NAStuff.StartupPerformance
		if type(perf) == "table" then
			perf.uiSourceMode = "prefetched"
			perf.uiSourceBytes = #src
		end
	end

	if type(src) ~= "string" or src == "" then
		local ok, body
		local fetchErr
		const start = os.clock()
		if NAAssetsLoading and NAAssetsLoading.httpGetNoSkipWithTimeout then
			ok, body, fetchErr = NAAssetsLoading.httpGetNoSkipWithTimeout(url, NAAssetsLoading.githubTimeoutSeconds or 5)
		elseif NAAssetsLoading and NAAssetsLoading.httpGetWithTimeout then
			ok, body, fetchErr = NAAssetsLoading.httpGetWithTimeout(url, NAAssetsLoading.githubTimeoutSeconds or 5)
		else
			ok, body = NAmanage.HttpGet(url, { timeout = NAAssetsLoading.githubTimeoutSeconds or 5 })
		end
		const perf = NAStuff and NAStuff.StartupPerformance
		if type(perf) == "table" then
			perf.uiFetchElapsed = os.clock() - start
			perf.uiSourceMode = "network"
			perf.uiSourceUrl = url
			perf.uiSourceOk = ok == true
			perf.uiSourceBytes = type(body) == "string" and #body or 0
		end
		if not ok then
			return nil, fetchErr or body
		end
		if type(body) ~= "string" or body == "" then
			return nil, "empty response"
		end
		src = body
	end

	NAStuff.uiSrc = src
	NAStuff.uiFn = nil
	NAStuff.uiErr = nil
	return src
end

NAmanage.prepareUiSource = NAmanage.prepareUiSource or function(src)
	if type(src) ~= "string" or src == "" then
		return src, 0
	end
	if src:find("__NA_UI_FRAME_BUDGET__", 1, true) then
		return src, 0
	end
	local rewritten, replacements = src:gsub("Instance%.new%s*%(", "__NA_UI_FRAME_NEW(")
	if replacements <= 0 then
		return src, 0
	end
	const prelude = [=[local __NA_UI_FRAME_BUDGET__=true
local __NA_UI_RAW_NEW=Instance.new
local __NA_UI_NEW_COUNT=0
local __NA_UI_LAST_YIELD=os.clock()
local function __NA_UI_FRAME_NEW(...)
	__NA_UI_NEW_COUNT+=1
	local __NA_UI_NOW=os.clock()
	local __NA_PERF=type(NAStuff)=="table" and NAStuff.StartupPerformance or nil
	local __NA_UI_FRAME_DT=type(__NA_PERF)=="table" and tonumber(__NA_PERF.lastFrameDt) or nil
	local __NA_UI_HIGH_FPS=__NA_UI_FRAME_DT and __NA_UI_FRAME_DT>0 and __NA_UI_FRAME_DT<(1/240)
	local __NA_UI_BATCH=__NA_UI_HIGH_FPS and 32 or 96
	local __NA_UI_BUDGET=__NA_UI_HIGH_FPS and 0.006 or 0.012
	if __NA_UI_NEW_COUNT%__NA_UI_BATCH==0 or (__NA_UI_NOW-__NA_UI_LAST_YIELD)>=__NA_UI_BUDGET then
		local __NA_UI_CAN_YIELD=true
		if coroutine and type(coroutine.isyieldable)=="function" then
			__NA_UI_CAN_YIELD=coroutine.isyieldable()
		end
		if __NA_UI_CAN_YIELD then
			task.wait()
		end
		__NA_UI_LAST_YIELD=os.clock()
	end
	return __NA_UI_RAW_NEW(...)
end
]=]
	return prelude..rewritten, replacements
end

NAmanage.uiFnGet = NAmanage.uiFnGet or function(force)
	if not force and type(NAStuff.uiFn) == "function" then
		return NAStuff.uiFn
	end

	if type(NAmanage.pulseLoadingUI) == "function" then
		pcall(NAmanage.pulseLoadingUI, "fetching interface", 0.971)
	end

	local src, err = NAmanage.uiSrcGet(force)
	if type(src) ~= "string" or src == "" then
		return nil, err or "missing source"
	end

	local compileSource = src
	local replacements = 0
	if type(NAmanage.prepareUiSource) == "function" then
		if type(NAmanage.pulseLoadingUI) == "function" then
			pcall(NAmanage.pulseLoadingUI, "preparing interface", 0.972)
		end
		const prepareStart = os.clock()
		local okPrepare, prepared, count = pcall(NAmanage.prepareUiSource, src)
		const perf = NAStuff and NAStuff.StartupPerformance
		if type(perf) == "table" then
			perf.uiPrepareElapsed = os.clock() - prepareStart
			perf.uiSourceBytes = #src
		end
		if okPrepare and type(prepared) == "string" and prepared ~= "" then
			compileSource = prepared
			replacements = tonumber(count) or 0
		end
	end
	NAStuff.UIFrameBudgetReplacementCount = replacements

	if type(NAmanage.pulseLoadingUI) == "function" then
		pcall(NAmanage.pulseLoadingUI, "compiling interface", 0.973)
	end

	const compileStart = os.clock()
	local fn, lerr = loadstring(compileSource)
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) == "table" then
		perf.uiCompileElapsed = os.clock() - compileStart
		perf.uiCompileBytes = #compileSource
	end
	if type(fn) ~= "function" then
		NAStuff.uiErr = tostring(lerr or "compile error")
		return nil, lerr
	end

	NAStuff.uiFn = fn
	NAStuff.uiErr = nil
	return fn
end

NAmanage.uiRun = NAmanage.uiRun or function(force)
	local fn, err = NAmanage.uiFnGet(force)
	if type(fn) ~= "function" then
		return false, err
	end
	if type(NAmanage.pulseLoadingUI) == "function" then
		pcall(NAmanage.pulseLoadingUI, "building interface", 0.974)
	end
	local ok, res = pcall(fn)
	if not ok then
		NAStuff.uiErr = tostring(res)
		return false, res
	end
	return true, res
end

NAAssetsLoading._finalized = false
if not NAAssetsLoading.setStatus then
	NAAssetsLoading.ui, NAAssetsLoading.setStatus, NAAssetsLoading.setPercent, NAAssetsLoading.completed, NAAssetsLoading.getSkip, NAAssetsLoading.setMinimizedState = NAmanage.createLoadingUI((adminName or "NA").." is loading...", {widthScale=0.30})
	if type(NAAssetsLoading.ui) == "string" then
		return NAAssetsLoading.ui
	end
	NAgui.NaProtectUI(NAAssetsLoading.ui)
	NAAssetsLoading.applyMinimizedPreference()

	const startupWatchdogToken = NAmanage._runToken
	Delay(IsOnMobile == true and 45 or 35, function()
		if rawget(_na_env, "_NARunToken") ~= startupWatchdogToken then
			return
		end
		if NAStuff._loadingFinalizedOnce == true or NAAssetsLoading._finalized == true then
			return
		end
		if type(NAAssetsLoading.setStatus) == "function" then
			pcall(NAAssetsLoading.setStatus, "startup timed out; releasing loading screen")
		end
		warn("[NA loader] Startup watchdog released a loading screen that was still active")
		Wait(0.5)
		if NAAssetsLoading.completed then
			pcall(function()
				if typeof(NAAssetsLoading.completed) == "Instance" then
					NAmanage.SetAttr(NAAssetsLoading.completed, "Completed", true)
				else
					NAAssetsLoading.completed.Completed = true
				end
			end)
		end
	end)
	const stageOrder = {
		"engine",
		"notifications",
		"assets",
		"nastuff",
		"loader",
		"changelog",
		"uiloader",
		"queue",
		"prefetch",
		"final",
	}
	const stageWeight = {
		engine = 1,
		notifications = 1,
		assets = 1,
		nastuff = 1,
		loader = 1,
		changelog = 1,
		uiloader = 1,
		queue = 0.5,
		prefetch = 0.25,
		final = 0.5,
	}
	local totalWeight = 0
	for _, key in stageOrder do
		totalWeight += stageWeight[key] or 1
	end
	NAAssetsLoading.progress = {
		order = stageOrder,
		weight = stageWeight,
		total = totalWeight,
	}
	NAAssetsLoading.progressPercent = function(stage, fraction)
		fraction = math.clamp(tonumber(fraction) or 1, 0, 1)
		const data = NAAssetsLoading.progress
		if not data then return end
		local acc = 0
		for _, key in data.order do
			if key == stage then
				acc += (data.weight[key] or 1) * fraction
				break
			end
			acc += (data.weight[key] or 1)
		end
		const pct = (data.total > 0) and (acc / data.total) or 0
		NAAssetsLoading.setPercent(pct)
	end
end

NAAssetsLoading._startupFetches = {}
NAAssetsLoading.startStartupFetch = function(key, callback)
	if type(key) ~= "string" or key == "" or type(callback) ~= "function" then
		return nil
	end
	const existing = NAAssetsLoading._startupFetches[key]
	if type(existing) == "table" then
		return existing
	end
	const state = { done = false; }
	NAAssetsLoading._startupFetches[key] = state
	Spawn(function()
		local ok, a, b, c = pcall(callback)
		if ok then
			state.a, state.b, state.c = a, b, c
		else
			state.a, state.b, state.c = false, nil, a
		end
		state.done = true
	end)
	return state
end
NAAssetsLoading.awaitStartupFetch = function(key, timeoutSeconds)
	const state = NAAssetsLoading._startupFetches[key]
	if type(state) ~= "table" then
		return nil, nil, "missing startup fetch"
	end
	const deadline = os.clock() + math.clamp(tonumber(timeoutSeconds) or NAAssetsLoading.githubTimeoutSeconds or 5, 0.25, 30)
	while not state.done and os.clock() < deadline do
		Wait(0.01)
	end
	if not state.done then
		return false, nil, "startup fetch timed out"
	end
	return state.a, state.b, state.c
end
NAAssetsLoading.notificationUrl = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NamelessAdminNotifications.lua"
NAAssetsLoading.startStartupFetch("notifications", function()
	return NAAssetsLoading.httpGetNoSkipWithTimeout(NAAssetsLoading.notificationUrl, NAAssetsLoading.githubTimeoutSeconds or 5)
end)
NAAssetsLoading.startStartupFetch("nastuff", function()
	return NAAssetsLoading.fetchNAStuffJson(NAAssetsLoading.githubTimeoutSeconds or 5)
end)
NAAssetsLoading.startStartupFetch("ui", function()
	if type(opt.NAUILOADER) ~= "string" or opt.NAUILOADER == "" then
		return false, nil, "missing UI loader url"
	end
	local ok, body, err = NAAssetsLoading.httpGetNoSkipWithTimeout(opt.NAUILOADER, NAAssetsLoading.githubTimeoutSeconds or 5)
	if ok and type(body) == "string" and body ~= "" then
		NAAssetsLoading.cachePrefetchedRemote(opt.NAUILOADER, body)
	end
	return ok, body, err
end)

NAmanage.MarkStartupStage("engine", "waiting for engine")
NAAssetsLoading.setStatus("waiting for engine")
if not game:IsLoaded() then game.Loaded:Wait() end
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("engine") end

NAmanage.MarkStartupStage("notifications", "loading notifications")
NAAssetsLoading.setStatus("loading notifications")
notifAttempts = 0
repeat
	notifAttempts += 1
	NAAssetsLoading.ok, NAAssetsLoading.res = pcall(function()
		local okFetch, sourceOrErr, fetchErr
		if notifAttempts == 1 and NAAssetsLoading._startupFetches and NAAssetsLoading._startupFetches.notifications then
			okFetch, sourceOrErr, fetchErr = NAAssetsLoading.awaitStartupFetch("notifications", NAAssetsLoading.githubTimeoutSeconds or 5)
		elseif NAAssetsLoading and NAAssetsLoading.httpGetImportant then
			okFetch, sourceOrErr = NAAssetsLoading.httpGetImportant(NAAssetsLoading.notificationUrl)
		else
			okFetch, sourceOrErr = NAmanage.HttpGet(NAAssetsLoading.notificationUrl, { timeout = NAAssetsLoading.githubTimeoutSeconds or 5 })
		end
		if not okFetch then
			error(fetchErr or sourceOrErr or "notification fetch failed")
		end
		return loadstring(sourceOrErr)()
	end)
	if NAAssetsLoading.ok and type(NAAssetsLoading.res) == "table" then
		NAStuff.Notification = NAAssetsLoading.res
	else
		Wait(0.15)
	end
until NAStuff.Notification or NAAssetsLoading.getSkip() or notifAttempts >= 3
if not NAStuff.Notification then
	NAStuff.Notification = {Notify=function() end, Window=function() end, Popup=function() end}
end

if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("notifications") end

NAmanage.MarkStartupStage("assets", "queueing assets")
NAAssetsLoading.setStatus("queueing assets")
pcall(function()
	if FileSupport and type(NAImageAssets) == "table" and type(NAAssetsLoading.queueImageAssets) == "function" then
		if type(isfolder) == "function" and type(NAfiles) == "table" and type(NAfiles.NAASSETSFILEPATH) == "string" and not NAmanage.safeIsFolder(NAfiles.NAASSETSFILEPATH) then
			NAmanage.safeMakeFolder(NAfiles.NAASSETSFILEPATH)
		end
		NAAssetsLoading.queueImageAssets()
	end
end)
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("assets") end

NAmanage.MarkStartupStage("nastuff", "Loading "..(adminName or "NA").." Data")
NAAssetsLoading.setStatus("Loading "..(adminName or "NA").." Data")
naStuffReady = false
okFetch, dataOrNil, sourceOrErr = nil, nil, nil
if NAAssetsLoading._startupFetches and NAAssetsLoading._startupFetches.nastuff then
	okFetch, dataOrNil, sourceOrErr = NAAssetsLoading.awaitStartupFetch("nastuff", NAAssetsLoading.githubTimeoutSeconds or 5)
else
	okFetch, dataOrNil, sourceOrErr = NAAssetsLoading.fetchNAStuffJson(NAAssetsLoading.githubTimeoutSeconds or 5)
end
if okFetch and type(dataOrNil) == "table" then
	NAStuff.NAjson = dataOrNil
	pcall(NAmanage.btUpdate)
	naStuffReady = true
else
	if type(NAAssetsLoading.setStatus) == "function" then
		NAAssetsLoading.setStatus("NA Data fallback: "..NAAssetsLoading.normalizeStatusError(sourceOrErr or dataOrNil or "unknown"))
	end
	Wait(0.15)
end
if not naStuffReady then
	NAStuff.NAjson = type(NAStuff.NAjson) == "table" and NAStuff.NAjson or {}
end
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("nastuff") end

NAmanage.MarkStartupStage("loader", "Setting Up Loader")
NAAssetsLoading.runLoadingCheck("Setting Up Loader", function()
	if type(opt.loaderUrl) ~= "string" or opt.loaderUrl == "" then
		return false, nil, "missing loader url"
	end
	return true, opt.loaderUrl
end)
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("loader") end

NAmanage.MarkStartupStage("changelog", "Loading Update Log")
SpawnCall(function()
	local body
	if type(opt.githubUrl) ~= "string" or opt.githubUrl == "" then
		return
	end
	if type(opt.NAREQUEST) == "function" then
		local ok, response = NAAssetsLoading.requestWithTimeout(opt.NAREQUEST, {
			Url = opt.githubUrl,
			Method = "GET",
			Timeout = NAAssetsLoading.githubTimeoutSeconds or 5
		}, NAAssetsLoading.githubTimeoutSeconds or 5)
		if ok and typeof(response) == "table" and tonumber(response.StatusCode) == 200 and type(response.Body) == "string" and response.Body ~= "" then
			body = response.Body
		end
	else
		local ok, fetched = NAAssetsLoading.httpGetWithTimeout(opt.githubUrl, NAAssetsLoading.githubTimeoutSeconds or 5)
		if ok and type(fetched) == "string" and fetched ~= "" then
			body = fetched
		end
	end
	if type(body) ~= "string" or body == "" then
		return
	end
	local decodeOk, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
	if decodeOk and type(decoded) == "table" then
		const top = decoded[1]
		const date = top and top.commit and top.commit.author and top.commit.author.date
		if type(date) == "string" then
			local year, month, day = date:match("(%d+)-(%d+)-(%d+)")
			if year and month and day then
				opt.NAupdDate = month.."/"..day.."/"..year
			end
		end
	end
end)
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("changelog") end

NAmanage.MarkStartupStage("uiloader", "Loading UI")
if NAAssetsLoading._startupFetches and NAAssetsLoading._startupFetches.ui and not NAAssetsLoading._startupFetches.ui.done then
	NAAssetsLoading.awaitStartupFetch("ui", NAAssetsLoading.githubTimeoutSeconds or 5)
end
NAAssetsLoading.runLoadingCheck("Loading UI", function()
	local src, serr = NAmanage.uiSrcGet(false)
	if type(src) ~= "string" or src == "" then
		return false, nil, serr or "missing UI loader source"
	end
	local fn, ferr = NAmanage.uiFnGet(false)
	if type(fn) ~= "function" then
		return false, nil, ferr or "failed to compile UI loader"
	end
	return true, src
end, nil, { maxAttempts = 2 })
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("uiloader") end

NAmanage.MarkStartupStage("queue", "collecting remote resources")
NAAssetsLoading.setStatus("collecting remote resources")
remoteTargets = NAAssetsLoading.getRemoteTargets()
totalRemotes = #remoteTargets
if totalRemotes > 0 then
	NAAssetsLoading.setStatus(Format("queued %d remote resources", totalRemotes))
else
	NAAssetsLoading.setStatus("queued 0 remote resources")
end
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("queue") end

NAmanage.MarkStartupStage("prefetch", "prefetching remote resources in background")
NAAssetsLoading.setStatus("prefetching remote resources in background")
NAAssetsLoading.applyPrefetchPercent=function(done, total)
	if not NAAssetsLoading.progressPercent then return end
	if total and total > 0 then
		const frac = math.clamp(done / total, 0, 1)
		NAAssetsLoading.progressPercent("prefetch", frac)
	else
		NAAssetsLoading.progressPercent("prefetch", 1)
	end
end
SpawnCall(function()
	NAAssetsLoading.prefetchRemotes(function(done, total, url, success)
		NAAssetsLoading.applyPrefetchPercent(done, total)
		if total > 0 and (done == total or done % 5 == 0) and type(NAAssetsLoading.setStatus) == "function" then
			NAAssetsLoading.setStatus(Format("prefetching %d/%d", done, total))
		end
	end, NAAssetsLoading.getSkip)
end)
if NAAssetsLoading.progressPercent then NAAssetsLoading.progressPercent("prefetch", 1) end

NAmanage.MarkStartupStage("roblox_api_prefetch", "queueing Roblox API fetch in background")
NAAssetsLoading.setStatus("queueing Roblox API fetch in background")
pcall(function()
	if NAmanage and NAmanage.prefetchRobloxGameInfo then
		SpawnCall(function()
			Wait(IsOnMobile == true and 4 or 1.5)
			if type(NAmanage.isLoad) == "function" and not NAmanage.isLoad() then
				return
			end
			pcall(NAmanage.prefetchRobloxGameInfo)
		end)
	end
	if NAAssetsLoading.setPercent then
		NAAssetsLoading.setPercent(0.96)
	end
end)

NAmanage.MarkStartupStage("final", "finishing startup (building command data, autofill, and UI hooks)")
NAAssetsLoading.setStatus("finishing startup (building command data, autofill, and UI hooks)")

NAmanage.pulseLoadingUI = NAmanage.pulseLoadingUI or function(statusText, pct)
	pcall(function()
		const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
		if type(probe) == "table" and type(probe.mark) == "function" then
			probe.mark("pulse:"..tostring(statusText or ""))
		end
	end)
	pcall(function()
		if not NAAssetsLoading or NAAssetsLoading._finalized then
			return
		end
		if statusText and type(NAAssetsLoading.setStatus) == "function" then
			NAAssetsLoading.setStatus(statusText)
		end
		if pct and type(NAAssetsLoading.setPercent) == "function" then
			NAAssetsLoading.setPercent(pct)
		end
	end)
end

NAmanage.finishLoadingUI = NAmanage.finishLoadingUI or function(statusText)
	pcall(function()
		if not NAAssetsLoading or NAAssetsLoading._finalized then
			return
		end
		NAAssetsLoading._finalized = true
		if type(NAAssetsLoading.setStatus) == "function" then
			pcall(NAAssetsLoading.setStatus, statusText or "ready")
		end
		if type(NAAssetsLoading.setPercent) == "function" then
			pcall(NAAssetsLoading.setPercent, 1)
		end
		const loadingGui = NAAssetsLoading.ui
		if typeof(NAAssetsLoading.completed) == "Instance" then
			pcall(NAmanage.SetAttr, NAAssetsLoading.completed, "Completed", true)
		elseif type(NAAssetsLoading.completed) == "table" then
			NAAssetsLoading.completed.Completed = true
		end
		if typeof(loadingGui) == "Instance" then
			Delay(0.35, function()
				if loadingGui.Parent then
					pcall(function()
						loadingGui:Destroy()
					end)
				end
			end)
		end
		NAAssetsLoading.ui = nil
		NAAssetsLoading.setStatus = nil
		NAAssetsLoading.setPercent = nil
		NAAssetsLoading.completed = nil
		NAAssetsLoading.getSkip = nil
		NAAssetsLoading.setMinimizedState = nil
		NAAssetsLoading.progress = nil
		NAAssetsLoading.progressPercent = nil
	end)
end

NAmanage.queueStartupAssetPreload = NAmanage.queueStartupAssetPreload or function()
	if not (NAStuff and NAStuff.AutoPreloadAssets) or NAStuff._assetPreloadQueued then
		return
	end
	NAStuff._assetPreloadQueued = true
	const perf = NAStuff.StartupPerformance
	if type(perf) == "table" then
		perf.assetPreloadQueued = os.clock()
		perf.assetPreloadDelay = 6
		perf.assetPreloadMobile = IsOnMobile == true
	end
	Defer(function()
		Wait(6)
		if not (NAStuff and NAStuff.AutoPreloadAssets) then
			NAStuff._assetPreloadQueued = false
			return
		end
		const limit = tick() + 60
		while type(NAmanage.StartAssetPreload) ~= "function" and tick() < limit do
			Wait(0.25)
		end
		if type(NAmanage.StartAssetPreload) == "function" then
			if type(perf) == "table" then
				perf.assetPreloadDispatch = os.clock()
			end
			NAmanage.StartAssetPreload({
				silent = true,
				st = true,
				lowImpact = true,
				incWs = true,
				maxI = 3000,
				maxE = 1000,
			})
		else
			NAStuff._assetPreloadQueued = false
		end
	end)
end

NAmanage.FinishStartupPerformance = NAmanage.FinishStartupPerformance or function(statusText)
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) ~= "table" or perf.finished == true then
		return
	end
	perf.finished = true
	perf.finishedStatus = tostring(statusText or "ready")
	perf.elapsed = os.clock() - (tonumber(perf.started) or os.clock())
	perf.uiSourceInstances = tonumber(NAStuff.UIFrameBudgetReplacementCount) or 0
	pcall(function()
		const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
		if type(probe) == "table" and type(probe.mark) == "function" then
			probe.mark("startup_finished:"..perf.finishedStatus)
		end
	end)
	pcall(function()
		_na_env.__NAStartupPerformance = perf
	end)
	if NAlib and type(NAlib.disconnect) == "function" then
		NAlib.disconnect("NA_startup_performance")
	end
end

NAmanage.completeStartupLoading = NAmanage.completeStartupLoading or function(statusText)
	if NAStuff._loadingFinalizedOnce == true then
		return
	end
	if type(NAmanage.MarkStartupStage) == "function" then
		NAmanage.MarkStartupStage("ready", statusText or "ready")
	end
	NAStuff._loadingFinalizePending = false
	NAStuff._loadingFinalizedOnce = true
	const perf = NAStuff.StartupPerformance
	const st = NAgui and NAgui.SettingsBuildState
	const settingsStillBuilding = NAStuff.SettingsBuildRunning == true or (type(st) == "table" and st.building == true)
	if type(perf) == "table" then
		perf.readyElapsed = os.clock() - (tonumber(perf.started) or os.clock())
		perf.readyBeforeSettings = settingsStillBuilding == true
		perf.uiSourceInstances = tonumber(NAStuff.UIFrameBudgetReplacementCount) or 0
	end
	NAStuff._startupCommandBudget = nil
	NAStuff._startupInstanceBudget = nil
	if not settingsStillBuilding and type(NAmanage.FinishStartupPerformance) == "function" then
		NAmanage.FinishStartupPerformance(statusText or "ready")
	end
	pcall(function()
		if type(NAmanage.isCommandDataStale) == "function" and NAmanage.isCommandDataStale() then
			if NAAssetsLoading and NAAssetsLoading.setStatus then
				NAAssetsLoading.setStatus("warming command list and autofill")
			end
			if type(NAmanage.queueCommandDataBuild) == "function" then
				pcall(NAmanage.queueCommandDataBuild, { force = true })
			elseif type(NAgui.loadCMDS) == "function" then
				pcall(NAgui.loadCMDS, { force = true })
			end
		end
	end)
	pcall(function()
		if NAmanage.finishLoadingUI then
			NAmanage.finishLoadingUI(statusText or "ready")
		end
	end)
	pcall(function()
		if type(NAmanage.queueStartupAssetPreload) == "function" then
			NAmanage.queueStartupAssetPreload()
		end
	end)
end

if NAmanage.pulseLoadingUI then
	NAmanage.pulseLoadingUI("building interface", 0.965)
end

Notify = NAStuff.Notification.Notify
Window = NAStuff.Notification.Window
Popup  = NAStuff.Notification.Popup

NAmanage.CheckAuthorityMode=function()
	local authorityModeOk, authorityMode = pcall(function()
		return Services.Workspace.AuthorityMode
	end)
	if not authorityModeOk or authorityMode ~= Enum.AuthorityMode.Server or type(Popup) ~= "function" then
		return false
	end
	const popupOk = pcall(function()
		Popup({
			Title = "Server Authority Detected",
			Description = "This game uses Server Authority. The server controls character movement and physics, so some "..adminName.." commands and features may be limited, behave differently, or be nonfunctional.",
			Duration = 0,
			Buttons = {
				{
					Text = "Continue",
					Callback = function() end,
				},
			},
		})
	end)
	return popupOk
end

pcall(NAmanage.CheckAuthorityMode)

if NAStuff and type(NAStuff._prefetchedRemotes) == "table" then
	NAStuff._prefetchedRemotes = {}
end
NAAssetsLoading.remoteStatus = {}
NAAssetsLoading._statusOrder = {}
NAAssetsLoading._statusOrderSet = {}
NAAssetsLoading._prefetchOrder = {}
NAAssetsLoading._prefetchOrderSet = {}

function cloneTable(tbl)
	const copy = {}
	for k, v in tbl do
		copy[k] = v
	end
	return copy
end

function buildNotifArgs(input, duration, title, allowDurationDefault)
	const args = type(input) == "table" and cloneTable(input) or {}
	if type(input) ~= "table" then
		args.Description = tostring((input ~= nil and input) or "something")
	elseif args.Description == nil then
		args.Description = "something"
	end
	const resolvedTitle = title or adminName
	if resolvedTitle and args.Title == nil then
		args.Title = resolvedTitle
	end
	if allowDurationDefault or duration ~= nil then
		if args.Duration == nil then
			if duration ~= nil then
				args.Duration = duration
			elseif allowDurationDefault then
				args.Duration = 5
			end
		end
	end
	return args
end

function DoNotif(text, duration, title)
	Notify(buildNotifArgs(text, duration, title, true))
end

NAmanage.NotifyFileWriteIssue()

function DebugNotif(text, duration, title)
	if not NAStuff.nuhuhNotifs then return end
	Notify(buildNotifArgs(text, duration, title, true))
end

function DoWindow(text, title)
	Window(buildNotifArgs(text, nil, title, false))
end

function DoPopup(text, title)
	Popup(buildNotifArgs(text, nil, title, false))
end

mouse=NAmanage.GetMouse(Services.Players.LocalPlayer)

for _, ev in events do
	if type(Bindings[ev]) ~= "table" then
		Bindings[ev] = {}
	end
end

function countDictNA(tbl)
	local count = 0
	for _ in tbl do
		count += 1
	end
	return count
end

--[[ Version ]]--
NAmanage.getCurVerText = NAmanage.getCurVerText or function()
	local ok, ap = pcall(isAprilFools)
	if ok and ap then
		return Format(" V%d.%d.%d", math.random(1, 99), math.random(0, 99), math.random(0, 99))
	end

	const d = type(NAStuff) == "table" and type(NAStuff.NAjson) == "table" and NAStuff.NAjson or nil
	local v = d and d.ver or nil
	const vt = type(v)
	if vt ~= "string" and vt ~= "number" then
		return ""
	end

	v = tostring(v)
	if v == "" or v:match("^%s*$") then
		return ""
	end

	return " V"..v
end

curVer = NAmanage.getCurVerText()

NAmanage.isBetween=function(month, day, sm, sd, em, ed)
	if sm < em or (sm == em and sd <= ed) then
		if month < sm or month > em then return false end
		if month == sm and day < sd then return false end
		if month == em and day > ed then return false end
		return true
	else
		return NAmanage.isBetween(month, day, sm, sd, 12, 31) or NAmanage.isBetween(month, day, 1, 1, em, ed)
	end
end

NAmanage.getSeasonEmoji=function()
	const date = os.date("*t")
	const month = date.month
	const day = date.day

	if month == 1 and day == 1 then
		return "🎉" -- New Year's Day
	elseif month == 2 and day == 14 then
		return "❤️" -- Valentine's Day
	elseif month == 2 and day >= 1 and day <= 21 then
		return "🧧" -- Chinese New Year (approx)
	elseif month == 3 and day == 17 then
		return "☘️" -- St. Patrick's Day
	elseif month == 4 and day >= 1 and day <= 15 then
		return "🥚" -- Easter (approx)
	elseif month == 4 and day == 22 then
		return "🌍" -- Earth Day
	elseif month == 5 and day >= 8 and day <= 14 then
		return "💐" -- Mother's Day (approx)
	elseif month == 6 and day >= 15 and day <= 21 then
		return "👔" -- Father's Day (approx)
	elseif month == 6 and day == 21 then
		return "☀️" -- Summer Solstice
	elseif month == 7 and day == 4 then
		return "🎇" -- Independence Day (US)
	elseif month == 9 and day == 22 then
		return "🍂" -- Autumn Equinox
	elseif month == 10 and day == 31 then
		return "🎃" -- Halloween
	elseif month == 11 and day >= 22 and day <= 28 then
		return "🦃" -- Thanksgiving (approx)
	elseif month == 12 and day == 25 then
		return "🎄" -- Christmas
	elseif month == 12 and day == 31 then
		return "🎆" -- New Year's Eve
	end

	if NAmanage.isBetween(month, day, 12, 1, 12, 31) or NAmanage.isBetween(month, day, 1, 1, 2, 28) then
		if NAmanage.isBetween(month, day, 12, 1, 12, 20) then
			return "🌨️" -- Early Winter
		elseif NAmanage.isBetween(month, day, 12, 21, 1, 31) then
			return "❄️" -- Deep Winter
		else
			return "🌬️" -- Late Winter
		end
	end

	if NAmanage.isBetween(month, day, 3, 1, 5, 31) then
		if NAmanage.isBetween(month, day, 3, 1, 3, 31) then
			return "🌱" -- Early Spring
		elseif NAmanage.isBetween(month, day, 4, 1, 4, 30) then
			return "🌸" -- Peak Spring
		else
			return "🌼" -- Late Spring
		end
	end

	if NAmanage.isBetween(month, day, 6, 1, 8, 31) then
		if NAmanage.isBetween(month, day, 6, 1, 6, 20) then
			return "😎" -- Early Summer
		elseif NAmanage.isBetween(month, day, 6, 21, 7, 31) then
			return "☀️" -- Peak Summer
		else
			return "🏖️" -- Late Summer
		end
	end

	if NAmanage.isBetween(month, day, 9, 1, 11, 30) then
		if NAmanage.isBetween(month, day, 9, 1, 9, 30) then
			return "🍃" -- Early Autumn
		elseif NAmanage.isBetween(month, day, 10, 1, 10, 31) then
			return "🍂" -- Peak Autumn
		else
			return "🕯️" -- Late Autumn
		end
	end

	return ""
end

-- for solara/xeno
SpawnCall(function()
	if _na_env.__NA_FUNCTION_FIXER_LOADED then
		return
	end
	_na_env.__NA_FUNCTION_FIXER_LOADED = true

	if NAAssetsLoading and NAAssetsLoading.httpGetImportant then
		_na_env.__NA_FUNCTION_FIXER_OK, _na_env.__NA_FUNCTION_FIXER_SOURCE = NAAssetsLoading.httpGetImportant("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/functionFixer.lua")
	else
		_na_env.__NA_FUNCTION_FIXER_OK, _na_env.__NA_FUNCTION_FIXER_SOURCE = pcall(function()
			return NAmanage.HttpGetOrError("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/functionFixer.lua", { timeout = NAAssetsLoading.githubTimeoutSeconds or 5 })
		end)
	end
	if not _na_env.__NA_FUNCTION_FIXER_OK or type(_na_env.__NA_FUNCTION_FIXER_SOURCE) ~= "string" or _na_env.__NA_FUNCTION_FIXER_SOURCE == "" then
		_na_env.__NA_FUNCTION_FIXER_LOADED = false
		return
	end

	if type(loadstring or load) ~= "function" then
		_na_env.__NA_FUNCTION_FIXER_LOADED = false
		return
	end

	_na_env.__NA_FUNCTION_FIXER_CHUNK = (loadstring or load)(_na_env.__NA_FUNCTION_FIXER_SOURCE, "@functionFixer.lua")
	if type(_na_env.__NA_FUNCTION_FIXER_CHUNK) ~= "function" then
		_na_env.__NA_FUNCTION_FIXER_LOADED = false
		return
	end

	_na_env.__NA_FUNCTION_FIXER_OK = pcall(_na_env.__NA_FUNCTION_FIXER_CHUNK)
	if not _na_env.__NA_FUNCTION_FIXER_OK then
		_na_env.__NA_FUNCTION_FIXER_LOADED = false
	end
end)

NAmanage.jlPhys = function()
	local okSettings, net = pcall(function()
		return settings():GetService("NetworkSettings")
	end)
	if okSettings and net then
		local okValue, value = pcall(function()
			return net.PrintPhysicsErrors
		end)
		if okValue then
			return value == true
		end
	end
	return false
end

NAmanage.jlDef = {
	JoinLog = false;
	LeaveLog = false;
	SaveLog = false;
	ChatLog = true;
	SaveChatLog = true;
	PhysicsLog = NAmanage.jlPhys();
	WelcomeNotif = true;
	SupportedGameNotif = true;
	KeybindNotif = true;
	PluginNotif = true;
	NotifyFollowed = false;
	JoinLeaveShowUserIds = false;
	ChatShowTimestamps = true;
	ChatUseDisplayNames = true;
	ChatShowUserIds = false;
	ChatLogLocalPlayer = true;
	LogIncludeGameInfo = true;
}

NAmanage.jlNumDef = {
	ChatMaxMessages = 200;
}

NAmanage.jlNorm = function(cfg)
	const c = type(cfg) == "table" and cfg or {}
	const function boolDef(v, d)
		if type(v) == "boolean" then
			return v
		end
		return d
	end
	const function numDef(v, d, min, max)
		local n = tonumber(v)
		if not n then
			return d
		end
		if min ~= nil then
			n = math.max(min, n)
		end
		if max ~= nil then
			n = math.min(max, n)
		end
		return math.floor(n + 0.5)
	end
	for key, def in NAmanage.jlDef do
		c[key] = boolDef(c[key], def)
	end
	c.ChatMaxMessages = numDef(c.ChatMaxMessages, NAmanage.jlNumDef.ChatMaxMessages, 20, 500)
	return c
end

NAmanage.jlCfg = NAmanage.jlNorm()

NAmanage.logApply = function()
	local okSettings, net = pcall(function()
		return settings():GetService("NetworkSettings")
	end)
	if okSettings and net then
		pcall(function()
			net.PrintPhysicsErrors = NAmanage.jlCfg.PhysicsLog == true
		end)
	end
end

opt.loader = Format('loadstring(game:HttpGet("%s"))();', opt.loaderUrl or "")

--Custom file functions checker checker
NAmanage.loaderState.settingsPath = NAfiles.NAMAINSETTINGSPATH
NAUserButtons = {}
NAPluginUserButtons = {}
UserButtonGuiList = {}
UserButtonGuiMap = {}
UserButtonDropdowns = {}
UserButtonToggleState = {}

originalIO.userButtonChildKey=function(groupId, childIndex)
	if groupId == nil or childIndex == nil then
		return nil
	end
	return ("g%s_%s"):format(tostring(groupId), tostring(childIndex))
end

originalIO.clearUserButtonState=function(id)
	if id == nil then
		return
	end
	UserButtonToggleState[id] = nil
	const prefix = "g"..tostring(id).."_"
	for key in UserButtonToggleState do
		if type(key) == "string" and key:sub(1, #prefix) == prefix then
			UserButtonToggleState[key] = nil
		end
	end
end

originalIO.clearUserButtonChildState=function(groupId, childIndex)
	const key = originalIO.userButtonChildKey(groupId, childIndex)
	if key then
		UserButtonToggleState[key] = nil
	end
end

NAEXECDATA = NAEXECDATA or {commands = {}, args = {}}
doPREDICTION = true
-- make it so It's easier for IY users to move to nameless admin (yes i did this and it's funny)
NamelessMigrate = {}
NamelessMigrate.IY_FE = {}
function NamelessMigrate:LoadIY_FE()
	if FileSupport then
		-- check if IY was installed
		if isfile("IY_FE.iy") then
			local success, content = NACaller(readfile, "IY_FE.iy")
			if success and content then
				NamelessMigrate.IY_FE = Services.HttpService:JSONDecode(content)
				DoNotif("Some Settings have been imported from Infinite Yield")
			end
		end
	end
	NamelessMigrate.LoadIY_FE = function() end -- too lazy to make a proper check just override it
	return
end
function NamelessMigrate:Prefix()
	NamelessMigrate:LoadIY_FE()
	if FileSupport then
		if NamelessMigrate.IY_FE then
			return NamelessMigrate.IY_FE["prefix"] or nil
		end
	end
	return nil
end

function NamelessMigrate:UiSize()
	NamelessMigrate:LoadIY_FE()
	if FileSupport then
		if NamelessMigrate.IY_FE then
			return tostring(NamelessMigrate.IY_FE["guiScale"]) or nil
		end
	end
	return nil
end

function NamelessMigrate:Waypoints()
	NamelessMigrate:LoadIY_FE()
	if not FileSupport then
		return
	end

	if NamelessMigrate.IY_FE then
		const Objects = {}
		for i,v in NamelessMigrate.IY_FE["WayPoints"] or {} do
			if not Objects[v.GAME] then
				Objects[v.GAME] = {}
			end
			const cord =  v.COORD
			cord[#cord+1] = 1
			cord[#cord+1] = 0
			cord[#cord+1] = 0
			cord[#cord+1] = 0
			cord[#cord+1] = 1
			cord[#cord+1] = 0
			cord[#cord+1] = 0
			cord[#cord+1] = 0
			cord[#cord+1] = 1
			Objects[v.GAME][v.NAME]= {["Components"] = v.COORD}
		end
		for i,v in Objects do
			const Load = ("%s/WP_%s.json"):format(
				NAfiles.NAWAYPOINTFILEPATH,
				tostring(i)
			)
			NAmanage.safeWriteFile(Load, Services.HttpService:JSONEncode(v))
		end
	end

end

NAmanage.NASettingsResolveDefault=function(def)
	local default = def.default
	if typeof(default) == "function" then
		local ok, value = pcall(default)
		if ok then
			default = value
		else
			default = nil
		end
	end
	return default
end

NAmanage.NASettingsCoerce=function(def, value)
	if value == nil then
		return NAmanage.NASettingsResolveDefault(def)
	end

	if def.coerce then
		local ok, coerced = pcall(def.coerce, value)
		if ok and coerced ~= nil then
			return coerced
		end
		return NAmanage.NASettingsResolveDefault(def)
	end

	return value
end

NAmanage.NASettingsSchemaState = NAmanage.NASettingsSchemaState or {}
NAmanage.NASettingsSchemaState.defaultStrokeColor = NAmanage.NASettingsSchemaState.defaultStrokeColor or Color3.fromRGB(148, 93, 255)
NAmanage.NASettingsSchemaState.coerceBoolean = NAmanage.NASettingsSchemaState.coerceBoolean or function(value, fallback)
	if type(value) == "boolean" then
		return value
	end
	if type(value) == "string" then
		NAmanage.NASettingsSchemaState.lowered = value:lower()
		if NAmanage.NASettingsSchemaState.lowered == "true" or NAmanage.NASettingsSchemaState.lowered == "1" then
			return true
		end
		if NAmanage.NASettingsSchemaState.lowered == "false" or NAmanage.NASettingsSchemaState.lowered == "0" then
			return false
		end
	end
	if type(value) == "number" then
		return value ~= 0
	end
	return fallback
end
NAmanage.NASettingsSchemaState.clampChannel = NAmanage.NASettingsSchemaState.clampChannel or function(value)
	NAmanage.NASettingsSchemaState.numberValue = tonumber(value)
	if not NAmanage.NASettingsSchemaState.numberValue then
		return nil
	end
	if NAmanage.NASettingsSchemaState.numberValue < 0 then
		NAmanage.NASettingsSchemaState.numberValue = 0
	elseif NAmanage.NASettingsSchemaState.numberValue > 1 then
		NAmanage.NASettingsSchemaState.numberValue = 1
	end
	return NAmanage.NASettingsSchemaState.numberValue
end

NAmanage.NASettingsGetSchema=function()
	if NAStuff.NASettingsSchema then
		return NAStuff.NASettingsSchema
	end

	NAStuff.NASettingsSchema = {
		prefix = {
			pathKey = "NAPREFIXPATH";
			default = function()
				return NamelessMigrate:Prefix() or ";"
			end;
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or ";")
				end
				if value == "" then
					return ";"
				end
				return value
			end;
		};
		buttonSize = {
			pathKey = "NABUTTONSIZEPATH";
			default = 1;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue or numberValue <= 0 then
					return 1
				end
				return numberValue
			end;
		};
		iconShape = {
			default = "Circle";
			coerce = function(value)
				local shape = type(value) == "string" and value or tostring(value or "")
				shape = shape:match("^%s*(.-)%s*$") or shape
				shape = shape:lower()
				if shape == "square" then
					return "Square"
				elseif shape == "rounded" or shape == "round" then
					return "Rounded"
				elseif shape == "squircle" then
					return "Squircle"
				elseif shape == "circle" then
					return "Circle"
				end
				return "Circle"
			end;
		};
		topbarButtonShape = {
			default = "Circle";
			coerce = function(value)
				local shape = type(value) == "string" and value or tostring(value or "")
				shape = shape:match("^%s*(.-)%s*$") or shape
				shape = shape:lower()
				if shape == "square" then
					return "Square"
				elseif shape == "rounded" or shape == "round" then
					return "Rounded"
				elseif shape == "squircle" then
					return "Squircle"
				elseif shape == "circle" then
					return "Circle"
				end
				return "Circle"
			end;
		};
		iconBgTransparency = {
			default = 0;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0 end
				return n
			end;
		};
		iconImageTransparency = {
			default = 0;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0 end
				return n
			end;
		};
		iconTextTransparency = {
			default = 0;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0 end
				return n
			end;
		};
		iconStrokeTransparency = {
			default = 0.7;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.7 end
				return n
			end;
		};
		iconPosition = {
			default = function()
				return { X = 0.5; Y = 0.1 }
			end;
			coerce = function(value)
				local parsed = value
				if type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					if ok and typeof(decoded) == "table" then
						parsed = decoded
					else
						parsed = nil
					end
				end

				if type(parsed) == "table" then
					local x = tonumber(parsed.X or parsed.x)
					local y = tonumber(parsed.Y or parsed.y)
					if x then
						x = math.clamp(x, 0, 1)
					end
					if y then
						y = math.clamp(y, 0, 1)
					end
					if x ~= nil and y ~= nil then
						return { X = x; Y = y }
					end
				end

				return { X = 0.5; Y = 0.1 }
			end;
		};
			iconKeepPosition = {
				default = true;
				coerce = function(value)
					return value == true
				end;
			};
		customMovementSoundsEnabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		customMovementSoundsWalk = {
			default = "";
			coerce = function(value)
				return tostring(value or "")
			end;
		};
		customMovementSoundsJump = {
			default = "";
			coerce = function(value)
				return tostring(value or "")
			end;
		};
		customMovementSoundsFall = {
			default = "";
			coerce = function(value)
				return tostring(value or "")
			end;
		};
		customMovementSoundsLand = {
			default = "";
			coerce = function(value)
				return tostring(value or "")
			end;
		};
		customMovementSoundsVolume = {
			default = 1;
			coerce = function(value)
				const n = tonumber(value)
				if not n then
					return 1
				end
				return math.clamp(n, 0, 10)
			end;
		};
		uiScale = {
			pathKey = "NAUISIZEPATH";
			default = function()
				const migrated = NamelessMigrate:UiSize()
				local numberValue = tonumber(migrated)
				if not numberValue or numberValue <= 0 then
					numberValue = 1
				end
				return math.clamp(numberValue, NA_UI_SCALE_MIN, NA_UI_SCALE_MAX)
			end;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue or numberValue <= 0 then
					return 1
				end
				return math.clamp(numberValue, NA_UI_SCALE_MIN, NA_UI_SCALE_MAX)
			end;
		};
		lowEndUiMode = {
			default = function() return IsOnMobile == true end;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, IsOnMobile == true) end;
		};
		customTeleportGui = {
			default = true;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, true) end;
		};
		customTeleportGuiGameTeleports = {
			default = false;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, false) end;
		};
		cmdInputSafeMode = {
			default = function() return IsOnPC == true and IsOnMobile ~= true end;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, IsOnPC == true and IsOnMobile ~= true) end;
		};
		hideCmdAutofill = {
			default = false;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, false) end;
		};
		sfwMode = {
			default = true;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, true) end;
		};
		legacyCommandUI = {
			default = false;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, false) end;
		};
		legacyHorizontalSettingsTabs = {
			default = false;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, false) end;
		};
		compactVerticalSettingsTabs = {
			default = false;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, false) end;
		};
		pluginAutoLoad = {
			default = true;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, true) end;
		};
		pluginAllowSettingsUI = {
			default = true;
			coerce = function(value) return NAmanage.NASettingsSchemaState.coerceBoolean(value, true) end;
		};
		pluginDisabled = {
			default = function() return {} end;
			coerce = function(value)
				local parsed = value
				if type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					parsed = ok and decoded or nil
				end
				const out = {}
				if type(parsed) == "table" then
					for key, disabled in parsed do
						if type(key) == "string" and key ~= "" and disabled == true then
							out[key] = true
						end
					end
				end
				return out
			end;
		};
		crosshairEnabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		crosshairSize = {
			default = 8;
			coerce = function(value)
				local n = tonumber(value)
				if not n then return 8 end
				if n < 2 then n = 2 end
				if n > 100 then n = 100 end
				return n
			end;
		};
		crosshairThickness = {
			default = 2;
			coerce = function(value)
				local n = tonumber(value)
				if not n then return 2 end
				if n < 1 then n = 1 end
				if n > 20 then n = 20 end
				return n
			end;
		};
		crosshairGap = {
			default = 2;
			coerce = function(value)
				const n = tonumber(value)
				if not n then return 2 end
				return math.clamp(math.floor(n + 0.5), 0, 30)
			end;
		};
		crosshairShowCenter = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		lightingStyleAutomation = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		lightingStyleAutomationStyle = {
			default = "Soft";
			coerce = function(value)
				local name = type(value) == "string" and value or tostring(value or "Soft")
				name = name:match("^%s*(.-)%s*$") or name
				for _, item in Enum.LightingStyle:GetEnumItems() do
					if Lower(item.Name) == Lower(name) then
						return item.Name
					end
				end
				return "Soft"
			end;
		};
		pauseVoxelizerLighting = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		fastParticleEffects = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		staffwatchIgnoreLocal = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		staffwatchHighlight = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		staffwatchOverrideESP = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		staffwatchMarkerColor = {
			default = function()
				return { R = 35 / 255; G = 140 / 255; B = 1 }
			end;
			coerce = function(value)
				local parsed = value
				if typeof(value) == "Color3" then
					parsed = { R = value.R; G = value.G; B = value.B }
				elseif type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					parsed = ok and type(decoded) == "table" and decoded or nil
				end
				if type(parsed) == "table" then
					const r = NAmanage.NASettingsSchemaState.clampChannel(parsed.R or parsed.r)
					const g = NAmanage.NASettingsSchemaState.clampChannel(parsed.G or parsed.g)
					const b = NAmanage.NASettingsSchemaState.clampChannel(parsed.B or parsed.b)
					if r and g and b then
						return { R = r; G = g; B = b }
					end
				end
				return { R = 35 / 255; G = 140 / 255; B = 1 }
			end;
		};
		mobileCamSensEnabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		mobileCamSensitivity = {
			default = 1;
			coerce = function(value)
				const n = tonumber(value)
				if not n then
					return 1
				end
				return math.clamp(n, 0.2, 4)
			end;
		};
		mobileFlyAutoEnableOnRun = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		flyNoVelocityClamp = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		cFlyVisualizer = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		crosshairColor = {
			default = function()
				return { R = 1; G = 1; B = 1 }
			end;
			coerce = function(value)
				local parsed = value
				if typeof(value) == "Color3" then
					parsed = { R = value.R; G = value.G; B = value.B }
				elseif type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					if ok and typeof(decoded) == "table" then
						parsed = decoded
					else
						parsed = nil
					end
				end
				if type(parsed) == "table" then
					const r = NAmanage.NASettingsSchemaState.clampChannel(parsed.R)
					const g = NAmanage.NASettingsSchemaState.clampChannel(parsed.G)
					const b = NAmanage.NASettingsSchemaState.clampChannel(parsed.B)
					if r and g and b then
						return { R = r; G = g; B = b }
					end
				end
				return { R = 1; G = 1; B = 1 }
			end;
		};
		tweenSpeed = {
			default = 1;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue or numberValue <= 0 then
					return 1
				end
				return numberValue
			end;
		};
		tpDelay = {
			default = 0.2;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 0.2
				end
				return math.clamp(numberValue, 0, 5)
			end;
		};
		offsetCustomization = {
			default = function()
				return {
					positionX = 0;
					positionY = -15;
					positionZ = 0;
					rotationX = 0;
					rotationY = 0;
					rotationZ = 0;
					preset = "Custom";
				}
			end;
			coerce = function(value)
				value = type(value) == "table" and value or {}
				const function numberField(key, fallback, minimum, maximum)
					const numberValue = tonumber(value[key])
					return math.clamp(numberValue or fallback, minimum, maximum)
				end
				return {
					positionX = tonumber(value.positionX) or 0;
					positionY = tonumber(value.positionY) or -15;
					positionZ = tonumber(value.positionZ) or 0;
					rotationX = numberField("rotationX", 0, -180, 180);
					rotationY = numberField("rotationY", 0, -180, 180);
					rotationZ = numberField("rotationZ", 0, -180, 180);
					preset = tostring(value.preset or "Custom");
				}
			end;
		};
		offVisOn = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		offVisAcc = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		offVisFTr = {
			default = 0.82;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 0.82
				end
				return math.clamp(numberValue, 0, 1)
			end;
		};
		offVisOTr = {
			default = 0.15;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 0.15
				end
				return math.clamp(numberValue, 0, 1)
			end;
		};
		offsetVisualizerEnabled = {
			default = nil;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, nil)
			end;
		};
		offsetVisualizerIncludeAccessories = {
			default = nil;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, nil)
			end;
		};
		offsetVisualizerFillTransparency = {
			default = nil;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return nil
				end
				return math.clamp(numberValue, 0, 1)
			end;
		};
		offsetVisualizerOutlineTransparency = {
			default = nil;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return nil
				end
				return math.clamp(numberValue, 0, 1)
			end;
		};

		freecamSpeed = {
			default = 5;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 5
				end
				return math.clamp(numberValue, 0.05, 20)
			end;
		};
		queueOnTeleport = {
			pathKey = "NAQOTPATH";
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		prediction = {
			pathKey = "NAPREDICTIONPATH";
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		freecamKeybind = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		debugDontRenderKeybind = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		autoExecEnabled = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		userButtonsAutoLoad = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		cmdbar2AutoRun = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		loopMethod = {
			default = "PostSimulation";
			coerce = function(value)
				local v = type(value) == "string" and value or tostring(value or "")
				v = v:match("^%s*(.-)%s*$") or v
				const l = v:lower():gsub("[%s_%-]", "")
				if l == "presimulation" then
					return "PreSimulation"
				elseif l == "renderstepped" then
					return "RenderStepped"
				elseif l == "heartbeat" then
					return "Heartbeat"
				end
				return "PostSimulation"
			end;
		};
		autoInteractMethod = {
			default = "PostSimulation";
			coerce = function(value)
				local v = type(value) == "string" and value or tostring(value or "")
				v = v:match("^%s*(.-)%s*$") or v
				const l = v:lower():gsub("[%s_%-]", "")
				if l == "presimulation" then
					return "PreSimulation"
				elseif l == "renderstepped" then
					return "RenderStepped"
				elseif l == "heartbeat" then
					return "Heartbeat"
				end
				return "PostSimulation"
			end;
		};
		autoFireRemoteMethod = {
			default = "PostSimulation";
			coerce = function(value)
				local v = type(value) == "string" and value or tostring(value or "")
				v = v:match("^%s*(.-)%s*$") or v
				const l = v:lower():gsub("[%s_%-]", "")
				if l == "presimulation" then
					return "PreSimulation"
				elseif l == "renderstepped" then
					return "RenderStepped"
				elseif l == "heartbeat" then
					return "Heartbeat"
				end
				return "PostSimulation"
			end;
		};
		managementAutoRefresh = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		managementRefreshInterval = {
			default = 2;
			coerce = function(value)
				return math.clamp(tonumber(value) or 2, 0.5, 10)
			end;
		};
		managementLogLines = {
			default = 100;
			coerce = function(value)
				return math.clamp(math.floor(tonumber(value) or 100), 10, 1000)
			end;
		};
		managementLogFilter = {
			default = "All";
			coerce = function(value)
				const picked = tostring(value or "All")
				if picked == "Warnings & Errors" or picked == "Errors Only" then
					return picked
				end
				return "All"
			end;
		};
		mcpNotifyActivity = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		mcpNotifyReads = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		mcpAllowUIAccess = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		mcpCommandPrediction = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		safeSpeedMethod = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		enhancedPhysicsReplication = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		safeJumpMethod = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		cmdbar2Width = {
			default = NAStuff.CmdBar2.defaultWidth;
			coerce = function(value)
				return NAmanage.CmdBar2ClampValue(value, NAStuff.CmdBar2.minWidth, NAStuff.CmdBar2.maxWidth, NAStuff.CmdBar2.defaultWidth)
			end;
		};
		cmdbar2Height = {
			default = NAStuff.CmdBar2.defaultHeight;
			coerce = function(value)
				return NAmanage.CmdBar2ClampValue(value, NAStuff.CmdBar2.minHeight, NAStuff.CmdBar2.maxHeight, NAStuff.CmdBar2.defaultHeight)
			end;
		};
		deltaPrompted = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		bloxtrapRPC = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		integrationWebhookUrl = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationWebhookUrlMain = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationWebhookUrlAll = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationWebhookUrlJoinLeave = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationWebhookUrlChat = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationWebhookUrlCommands = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationWebhookUseAll = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		integrationWebhookJoinLeave = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		integrationWebhookChat = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		integrationWebhookCommands = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		integrationWebhookInterval = {
			default = 2;
			coerce = function(value)
				local n = tonumber(value)
				if not n then return 2 end
				if n < 0 then n = 0 elseif n > 30 then n = 30 end
				return n
			end;
		};
		integrationWebhookOptions = {
			default = {};
			coerce = function(value)
				if type(value) ~= "table" then
					return {}
				end
				const out = {}
				for _, key in { "enabled", "useEmbeds", "includeTimestamp", "includeServerInfo", "blockMentions", "silent", "tts", "separateCooldowns" } do
					if type(value[key]) == "boolean" then
						out[key] = value[key]
					end
				end
				for _, key in { "username", "avatarUrl", "titlePrefix", "footerText", "thumbnailUrl", "imageUrl" } do
					if value[key] ~= nil then
						out[key] = tostring(value[key])
					end
				end
				if type(value.colors) == "table" then
					out.colors = {}
					for _, key in { "join", "leave", "chat", "command", "main", "test" } do
						if value.colors[key] ~= nil then
							out.colors[key] = tostring(value.colors[key])
						end
					end
				end
				return out
			end;
		};
		integrationWebhookTemplates = {
			default = {};
			coerce = function(value)
				if type(value) ~= "table" then
					return {}
				end
				const out = {}
				for _, key in { "join", "leave", "chat", "command" } do
					if value[key] ~= nil then
						out[key] = tostring(value[key])
					end
				end
				return out
			end;
		};
		integrationWebhookDraft = {
			default = "";
			coerce = function(value)
				return type(value) == "string" and value or tostring(value or "")
			end;
		};
		integrationWebhookRawDraft = {
			default = [[{"content":"Hello from Nameless Admin"}]];
			coerce = function(value)
				return type(value) == "string" and value or tostring(value or "")
			end;
		};
		integrationHealthEndpoints = {
			default = {};
			coerce = function(value)
				if type(value) ~= "table" then
					return {}
				end
				const out = {}
				for i = 1, math.min(3, #value) do
					const v = value[i]
					if type(v) == "string" and v ~= "" then
						out[#out + 1] = v
					end
				end
				return out
			end;
		};
		integrationNotesLast = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationRpcUseCustom = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		integrationRpcDetails = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		integrationRpcState = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value
			end;
		};
		cmdIntegrationAutoRun = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		cmdIntegrationRoutingMode = {
			default = "NA First";
			coerce = function(value)
				return NAmanage.CmdIntegrationNormalizeMode(value)
			end;
		};
		cmdIntegrationExposeGateway = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		cmdIntegrationUseNotifications = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		cmdIntegrationMirrorNotifications = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		iyIntegrationAutoRun = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		iyIntegrationRoutingMode = {
			default = "NA First";
			coerce = function(value)
				return NAmanage.IYIntegrationNormalizeMode(value)
			end;
		};
		iyIntegrationExposeGateway = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		iyIntegrationMirrorNotifications = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		purchasePromptsDisabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		order66PurchaseBlock = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		networkPauseDisabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		disableUnsafeFunctions = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		disableVirtualInputAPI = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		disableHWIDFunctions = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		spoofHWID = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		spoofedHWID = {
			default = "";
			coerce = function(value)
				return type(value) == "string" and value or tostring(value or "")
			end;
		};
		spoofClientID = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		spoofedClientID = {
			default = "";
			coerce = function(value)
				return type(value) == "string" and value or tostring(value or "")
			end;
		};
		synEnv = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		forceRconsoleNAConsole = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		friendRequestAutoDismiss = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		devConsoleCopyButtons = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		devConsoleMasterInput = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		devConsoleLogLimit = {
			default = 1200;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 1200
				end
				return math.clamp(math.floor(numberValue + 0.5), 200, 5000)
			end;
		};
		devConsoleQueueLimit = {
			default = 600;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 600
				end
				return math.clamp(math.floor(numberValue + 0.5), 100, 4000)
			end;
		};
		devConsoleOverscan = {
			default = 320;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 320
				end
				return math.clamp(math.floor(numberValue + 0.5), 60, 2000)
			end;
		};
		streamerMode = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		chatTranslate = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		chatTranslateTarget = {
			default = "en";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "en")
				end
				value = value:lower()
				if value == "" then
					return "en"
				end
				return value
			end;
		};
		settingsTranslateTarget = {
			default = "en";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "en")
				end
				value = value:lower()
				if value == "" then
					return "en"
				end
				return value
			end;
		};
		uiStroke = {
			pathKey = "NASTROKETHINGY";
			default = function()
				return {
					R = NAmanage.NASettingsSchemaState.defaultStrokeColor.R;
					G = NAmanage.NASettingsSchemaState.defaultStrokeColor.G;
					B = NAmanage.NASettingsSchemaState.defaultStrokeColor.B;
				}
			end;
			coerce = function(value)
				local parsed = value
				if typeof(value) == "Color3" then
					parsed = {
						R = value.R;
						G = value.G;
						B = value.B;
					}
				elseif type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					if ok and typeof(decoded) == "table" then
						parsed = decoded
					else
						parsed = nil
					end
				end

				if type(parsed) == "table" then
					const r = NAmanage.NASettingsSchemaState.clampChannel(parsed.R)
					const g = NAmanage.NASettingsSchemaState.clampChannel(parsed.G)
					const b = NAmanage.NASettingsSchemaState.clampChannel(parsed.B)
					if r and g and b then
						return {
							R = r;
							G = g;
							B = b;
						}
					end
				end

				return {
					R = NAmanage.NASettingsSchemaState.defaultStrokeColor.R;
					G = NAmanage.NASettingsSchemaState.defaultStrokeColor.G;
					B = NAmanage.NASettingsSchemaState.defaultStrokeColor.B;
				}
			end;
		};
		colorPickerAutoRGB = {
			default = function()
				return {}
			end;
			coerce = function(value)
				if type(value) ~= "table" then
					value = {}
				end
				const sanitized = {}
				for key, val in value do
					if type(key) == "string" then
						sanitized[key] = val == true
					end
				end
				return sanitized
			end;
		};
		customIconAssetId = {
			default = "";
			coerce = function(value)
				if typeof(value) ~= "string" then
					value = tostring(value or "")
				end
				value = value:match("^%s*(.-)%s*$")
				if value == "" then
					return ""
				end
				const digits = value:match("^rbxassetid://(%d+)$") or value:match("(%d+)$")
				if digits then
					return "rbxassetid://"..digits
				end
				return ""
			end;
		};
		customIconLocalPath = {
			default = "";
			coerce = function(value)
				if typeof(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or ""
			end;
		};

		customIconEnabled = {
			default = false;
			coerce = function(value)
				if type(value) == "boolean" then return value end
				if type(value) == "string" then
					const lowered = value:lower()
					if lowered == "true" or lowered == "1" then return true end
					if lowered == "false" or lowered == "0" then return false end
				end
				if type(value) == "number" then return value ~= 0 end
				return false
			end;
		};

		windowBackgroundEnabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		windowBackgroundSource = {
			default = "";
			coerce = function(value)
				if typeof(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or ""
			end;
		};
		windowBackgroundLocalPath = {
			default = "";
			coerce = function(value)
				if typeof(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or ""
			end;
		};
		windowBackgroundScaleMode = {
			default = "Crop";
			coerce = function(value)
				const mode = tostring(value or "Crop"):lower()
				if mode == "fit" then return "Fit" end
				if mode == "stretch" then return "Stretch" end
				if mode == "tile" then return "Tile" end
				return "Crop"
			end;
		};
		windowBackgroundTransparency = {
			default = 0.3;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.3 end
				return n
			end;
		};
		windowBackgroundTopbarTransparency = {
			default = 0.3;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.3 end
				return n
			end;
		};
		windowBackgroundContainerTransparency = {
			default = 0.42;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.42 end
				return n
			end;
		};
		windowBackgroundElementTransparency = {
			default = 0;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0 end
				return n
			end;
		};
		iconInvisible = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		iconLocked = {
			default = false;
			coerce = function(value)
				if type(value) == "boolean" then return value end
				if type(value) == "string" then
					const v = value:lower()
					if v == "true" or v == "1" then return true end
					if v == "false" or v == "0" then return false end
				end
				if type(value) == "number" then return value ~= 0 end
				return false
			end;
		};
		topbarKeepPosition = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		topbarPositionRatio = {
			default = 0;
			coerce = function(value)
				local numberValue = tonumber(value)
				if not numberValue then
					return 0
				end
				if numberValue < -1 then
					numberValue = -1
				elseif numberValue > 1 then
					numberValue = 1
				end
				return numberValue
			end;
		};
		sideSwipeSide = {
			default = "left";
			coerce = function(value)
				if value == "right" then
					return "right"
				end
				return "left"
			end;
		};
		sideSwipeEnabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		resizeHandleIcons = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		sideSwipeWidth = {
			default = 80;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 80
				end
				return math.clamp(math.floor(numberValue + 0.5), 60, 200)
			end;
		};
		sideSwipePanelHeight = {
			default = 0;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then return 0 end
				return math.clamp(math.floor(numberValue + 0.5), 0, 1200)
			end;
		};
		sideSwipeHandleWidth = {
			default = 0;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then return 0 end
				return math.clamp(math.floor(numberValue + 0.5), 0, 120)
			end;
		};
		sideSwipeHandleHeight = {
			default = 0;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then return 0 end
				return math.clamp(math.floor(numberValue + 0.5), 0, 800)
			end;
		};
		sideSwipeHandleVerticalPosition = {
			default = 50;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then return 50 end
				return math.clamp(numberValue, 0, 100)
			end;
		};
		sideSwipeSwipeThreshold = {
			default = 28;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then return 28 end
				return math.clamp(math.floor(numberValue + 0.5), 8, 120)
			end;
		};
		sideSwipeButtonHeight = {
			default = 48;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then return 48 end
				return math.clamp(math.floor(numberValue + 0.5), 32, 96)
			end;
		};
		sideSwipeButtonSpacing = {
			default = 8;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then return 8 end
				return math.clamp(math.floor(numberValue + 0.5), 0, 32)
			end;
		};
		sideSwipeHandleTransparency = {
			default = 0.72;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.72 end
				return n
			end;
		};
		sideSwipePanelTransparency = {
			default = 0.35;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.35 end
				return n
			end;
		};
		sideSwipeButtonTransparency = {
			default = 0.16;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.16 end
				return n
			end;
		};
		sideSwipeScrollBarThickness = {
			default = 4;
			coerce = function(value)
				const numberValue = tonumber(value)
				if not numberValue then
					return 4
				end
				return math.clamp(math.floor(numberValue + 0.5), 0, 12)
			end;
		};
		topbarVisible = {
			pathKey = "NATOPBAR";
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		topbarGlassTransparency = {
			default = 0.12;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.12 end
				return n
			end;
		};
		topbarStrokeTransparency = {
			default = 0.15;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.15 end
				return n
			end;
		};
		topbarPanelTransparency = {
			default = 0.1;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.1 end
				return n
			end;
		};
		topbarButtonTransparency = {
			default = 0.18;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				if n == nil then return 0.18 end
				return n
			end;
		};
		notifsToggle = {
			pathKey = "NANOTIFSTOGGLE";
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		devConsoleFilters = {
			default = function()
				return {
					Output = true;
					Info = true;
					Warn = true;
					Error = true;
				}
			end;
			coerce = function(value)
				const result = {
					Output = true;
					Info = true;
					Warn = true;
					Error = true;
				}
				if typeof(value) == "table" then
					result.Output = NAmanage.NASettingsSchemaState.coerceBoolean(value.Output, result.Output)
					result.Info = NAmanage.NASettingsSchemaState.coerceBoolean(value.Info, result.Info)
					result.Warn = NAmanage.NASettingsSchemaState.coerceBoolean(value.Warn, result.Warn)
					result.Error = NAmanage.NASettingsSchemaState.coerceBoolean(value.Error, result.Error)
				end
				return result
			end;
		};
		autoSkipLoading = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		hideStartup = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		autoInteractDistanceEnabled = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		autoInteractExtraRange = {
			default = 5;
			coerce = function(value)
				local n = tonumber(value)
				if not n then return 5 end
				if n < 0 then n = 0 end
				if n > 1000 then n = 1000 end
				return n
			end;
		};
		autoInteractDefaultInterval = {
			default = 0.1;
			coerce = function(value)
				local n = tonumber(value)
				if not n then return 0.1 end
				if n < 0 then n = 0 end
				if n > 1 then n = 1 end
				return math.floor((n * 100) + 0.5) / 100
			end;
		};
		autoFireRemoteDefaultInterval = {
			default = 0.1;
			coerce = function(value)
				local n = tonumber(value)
				if not n then return 0.1 end
				if n < 0 then n = 0 end
				if n > 1 then n = 1 end
				return math.floor((n * 100) + 0.5) / 100
			end;
		};
		clickTouchMaxDistance = {
			default = 1024;
			coerce = function(value)
				local n = tonumber(value)
				if not n then return 1024 end
				n = math.floor(n + 0.5)
				if n <= 0 then return 0 end
				return math.clamp(n, 50, 5000)
			end;
		};
		clickTouchScreenRadius = {
			default = 18;
			coerce = function(value)
				const n = tonumber(value)
				if not n then return 18 end
				return math.clamp(math.floor(n + 0.5), 2, 80)
			end;
		};
		clickTouchBlockedByCollide = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		clickTouchIgnoreNonCollideBlockers = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		clickTouchInvisibleFallback = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		clickTouchAlwaysOnTop = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		fpsBoostOptions = {
			default = function()
				return {
					effectMode = "disable";
					stripParticles = true;
					stripDecals = true;
					stripTextures = true;
					stripLights = true;
					stripPostFx = true;
					stripAtmosphere = true;
					stripSurfaceAppearance = true;
					stripHighlights = true;
					stripExplosions = true;
					simplifyMaterials = true;
					zeroReflectance = true;
					optimizeMeshes = true;
					optimizeModels = true;
					disableWorldQueries = false;
					disableWorldTouches = false;
					disable3dUi = false;
					forceStreaming = true;
					streamRadius = 96;
					flattenLighting = true;
					ignorePlayers = false;
					ignoreSelf = true;
				}
			end;
			coerce = function(value)
				const defaults = {
					effectMode = "disable";
					stripParticles = true;
					stripDecals = true;
					stripTextures = true;
					stripLights = true;
					stripPostFx = true;
					stripAtmosphere = true;
					stripSurfaceAppearance = true;
					stripHighlights = true;
					stripExplosions = true;
					simplifyMaterials = true;
					zeroReflectance = true;
					optimizeMeshes = true;
					optimizeModels = true;
					disableWorldQueries = false;
					disableWorldTouches = false;
					disable3dUi = false;
					forceStreaming = true;
					streamRadius = 96;
					flattenLighting = true;
					ignorePlayers = false;
					ignoreSelf = true;
				}
				if type(value) ~= "table" then
					value = {}
				end
				const function boolField(key, fallback)
					return NAmanage.NASettingsSchemaState.coerceBoolean(value[key], fallback)
				end
				const function clampRadius(v)
					local n = tonumber(v)
					if not n then
						return defaults.streamRadius
					end
					if n < 16 then
						n = 16
					elseif n > 4096 then
						n = 4096
					end
					return n
				end
				local mode = value.effectMode
				if type(mode) == "string" then
					const lower = mode:lower()
					if lower == "destroy" or lower == "delete" or lower == "remove" then
						mode = "destroy"
					else
						mode = "disable"
					end
				else
					mode = defaults.effectMode
				end
				const out = {}
				out.effectMode = mode
				out.stripParticles = boolField("stripParticles", defaults.stripParticles)
				out.stripDecals = boolField("stripDecals", defaults.stripDecals)
				out.stripTextures = boolField("stripTextures", defaults.stripTextures)
				out.stripLights = boolField("stripLights", defaults.stripLights)
				out.stripPostFx = boolField("stripPostFx", defaults.stripPostFx)
				out.stripAtmosphere = boolField("stripAtmosphere", defaults.stripAtmosphere)
				out.stripSurfaceAppearance = boolField("stripSurfaceAppearance", defaults.stripSurfaceAppearance)
				out.stripHighlights = boolField("stripHighlights", defaults.stripHighlights)
				out.stripExplosions = boolField("stripExplosions", defaults.stripExplosions)
				out.simplifyMaterials = boolField("simplifyMaterials", defaults.simplifyMaterials)
				out.zeroReflectance = boolField("zeroReflectance", defaults.zeroReflectance)
				out.optimizeMeshes = boolField("optimizeMeshes", defaults.optimizeMeshes)
				out.optimizeModels = boolField("optimizeModels", defaults.optimizeModels)
				out.disableWorldQueries = boolField("disableWorldQueries", defaults.disableWorldQueries)
				out.disableWorldTouches = boolField("disableWorldTouches", defaults.disableWorldTouches)
				out.disable3dUi = boolField("disable3dUi", defaults.disable3dUi)
				out.forceStreaming = boolField("forceStreaming", defaults.forceStreaming)
				out.streamRadius = clampRadius(value.streamRadius)
				out.flattenLighting = boolField("flattenLighting", defaults.flattenLighting)
				out.ignorePlayers = boolField("ignorePlayers", defaults.ignorePlayers)
				out.ignoreSelf = boolField("ignoreSelf", defaults.ignoreSelf)
				return out
			end;
		};
		hitboxOptions = {
			default = function()
				return {
					size = 10;
					transparency = 0.9;
					color = { R = 0; G = 0; B = 0 };
					material = "Neon";
					noCollide = true;
					massless = true;
				}
			end;
			coerce = function(value)
				const function coerceNumber(v, min, max, fallback)
					local n = tonumber(v)
					if not n then return fallback end
					if n < min then n = min end
					if n > max then n = max end
					return n
				end

				const function coerceColor(v)
					if typeof(v) == "Color3" then
						return {
							R = NAmanage.NASettingsSchemaState.clampChannel(v.R) or 0;
							G = NAmanage.NASettingsSchemaState.clampChannel(v.G) or 0;
							B = NAmanage.NASettingsSchemaState.clampChannel(v.B) or 0;
						}
					end
					if type(v) == "table" then
						const r = NAmanage.NASettingsSchemaState.clampChannel(v.R or v.r or v[1])
						const g = NAmanage.NASettingsSchemaState.clampChannel(v.G or v.g or v[2])
						const b = NAmanage.NASettingsSchemaState.clampChannel(v.B or v.b or v[3])
						if r and g and b then
							return { R = r; G = g; B = b }
						end
					end
					if type(v) == "string" then
						local ok, decoded = NACaller(function()
							return Services.HttpService:JSONDecode(v)
						end)
						if ok and type(decoded) == "table" then
							return coerceColor(decoded)
						end
					end
					return { R = 0; G = 0; B = 0 }
				end

				const defaults = {
					size = 10;
					transparency = 0.9;
					color = { R = 0; G = 0; B = 0 };
					material = "Neon";
					noCollide = true;
					massless = true;
				}

				if type(value) ~= "table" then
					return defaults
				end

				const out = {}
				out.size = coerceNumber(value.size, 0.1, 200, defaults.size)
				out.transparency = coerceNumber(value.transparency, 0, 1, defaults.transparency)
				out.color = coerceColor(value.color)

				local mat = "Neon"
				if type(value.material) == "string" then
					mat = value.material
				elseif value.material ~= nil then
					mat = tostring(value.material)
				end
				if type(mat) == "string" then
					const trimmed = mat:match("^%s*(.-)%s*$") or mat
					if Enum.Material[trimmed] then
						mat = trimmed
					else
						const lower = trimmed:lower()
						for _, item in Enum.Material:GetEnumItems() do
							if item.Name:lower() == lower then
								mat = item.Name
								break
							end
						end
					end
				else
					mat = defaults.material
				end
				out.material = mat
				out.noCollide = NAmanage.NASettingsSchemaState.coerceBoolean(value.noCollide, defaults.noCollide)
				out.massless = NAmanage.NASettingsSchemaState.coerceBoolean(value.massless, defaults.massless)
				return out
			end;
		};
		partSizeOptions = {
			default = function()
				return {
					transparency = 0.5;
					color = { R = 0; G = 0; B = 0 };
					material = "Neon";
					noCollide = true;
					massless = false;
					changeColor = false;
					changeMaterial = false;
				}
			end;
			coerce = function(value)
				const function coerceNumber(v, min, max, fallback)
					local n = tonumber(v)
					if not n then return fallback end
					if n < min then n = min end
					if n > max then n = max end
					return n
				end

				const function coerceColor(v)
					if typeof(v) == "Color3" then
						return {
							R = NAmanage.NASettingsSchemaState.clampChannel(v.R) or 0;
							G = NAmanage.NASettingsSchemaState.clampChannel(v.G) or 0;
							B = NAmanage.NASettingsSchemaState.clampChannel(v.B) or 0;
						}
					end
					if type(v) == "table" then
						const r = NAmanage.NASettingsSchemaState.clampChannel(v.R or v.r or v[1])
						const g = NAmanage.NASettingsSchemaState.clampChannel(v.G or v.g or v[2])
						const b = NAmanage.NASettingsSchemaState.clampChannel(v.B or v.b or v[3])
						if r and g and b then
							return { R = r; G = g; B = b }
						end
					end
					if type(v) == "string" then
						local ok, decoded = NACaller(function()
							return Services.HttpService:JSONDecode(v)
						end)
						if ok and type(decoded) == "table" then
							return coerceColor(decoded)
						end
					end
					return { R = 0; G = 0; B = 0 }
				end

				const defaults = {
					transparency = 0.5;
					color = { R = 0; G = 0; B = 0 };
					material = "Neon";
					noCollide = true;
					massless = false;
					changeColor = false;
					changeMaterial = false;
				}

				if type(value) ~= "table" then
					return defaults
				end

				const out = {}
				out.transparency = coerceNumber(value.transparency, 0, 1, defaults.transparency)
				out.color = coerceColor(value.color)

				local mat = "Neon"
				if type(value.material) == "string" then
					mat = value.material
				elseif value.material ~= nil then
					mat = tostring(value.material)
				end
				if type(mat) == "string" then
					const trimmed = mat:match("^%s*(.-)%s*$") or mat
					if Enum.Material[trimmed] then
						mat = trimmed
					else
						const lower = trimmed:lower()
						for _, item in Enum.Material:GetEnumItems() do
							if item.Name:lower() == lower then
								mat = item.Name
								break
							end
						end
					end
				else
					mat = defaults.material
				end
				out.material = mat
				out.noCollide = NAmanage.NASettingsSchemaState.coerceBoolean(value.noCollide, defaults.noCollide)
				out.massless = NAmanage.NASettingsSchemaState.coerceBoolean(value.massless, defaults.massless)
				out.changeColor = NAmanage.NASettingsSchemaState.coerceBoolean(value.changeColor, defaults.changeColor)
				out.changeMaterial = NAmanage.NASettingsSchemaState.coerceBoolean(value.changeMaterial, defaults.changeMaterial)
				return out
			end;
		};
		autoPreloadAssets = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		assetLoadMode = {
			default = "Fast";
			coerce = function(value)
				const map = {
					batch = "Batch";
					medium = "Medium";
					fast = "Fast";
					aggressive = "Aggressive";
				}
				local mode = nil
				if type(value) == "string" then
					mode = value
				elseif value ~= nil then
					mode = tostring(value)
				end
				if type(mode) == "string" then
					mode = mode:match("^%s*(.-)%s*$") or mode
					mode = map[mode:lower()]
				end
				return mode or "Fast"
			end;
		};
		saveInstanceSafeMode = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceShutdownWhenDone = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceAntiIdle = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceShowStatus = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceReadMe = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceDebugMode = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceDebugLog = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceAnonymous = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceMode = {
			default = "optimized";
			coerce = function(value)
				const mode = type(value) == "string" and value:lower() or tostring(value or ""):lower()
				if mode == "full" then
					return "full"
				elseif mode == "scripts" then
					return "scripts"
				end
				return "optimized"
			end;
		};
		saveInstanceDecompile = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceScriptCache = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceDecompileTimeout = {
			default = 10;
			coerce = function(value)
				const n = tonumber(value)
				if not n then return 10 end
				return math.clamp(math.floor(n + 0.5), 1, 120)
			end;
		};
		saveInstanceDecompileJobless = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceSaveBytecode = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceDecompilePrepass = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstancePrepassConcurrency = {
			default = 24;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 24) + 0.5), 1, 128)
			end;
		};
		saveInstancePrepassRateGap = {
			default = 0.12;
			coerce = function(value)
				return math.max(0, tonumber(value) or 0.12)
			end;
		};
		saveInstancePrepassApiUrl = {
			default = "https://api.lua.expert/decompile";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				value = value:match("^%s*(.-)%s*$") or value
				return value ~= "" and value or "https://api.lua.expert/decompile"
			end;
		};
		saveInstancePrepassMaxScripts = {
			default = 6000;
			coerce = function(value)
				return math.max(1, math.floor((tonumber(value) or 6000) + 0.5))
			end;
		};
		saveInstanceSaveCacheInterval = {
			default = 56320;
			coerce = function(value)
				const n = tonumber(value)
				if not n then return 56320 end
				return math.max(0, math.floor(n + 0.5))
			end;
		};
		saveInstanceNilInstances = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceIgnoreDefaultProperties = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceIgnoreNotArchivable = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceIgnorePropertiesOfNotScriptsOnScriptsMode = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceIgnoreSpecialProperties = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceUseUGCValidationService = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceIsolateStarterPlayer = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceIsolatePlayers = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceIsolateLocalPlayer = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceIsolateLocalPlayerCharacter = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceSavePlayerCharacters = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceSaveNotCreatable = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceAlternativeWritefile = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceIgnoreDefaultPlayerScripts = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceIgnoreSharedStrings = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		saveInstanceSharedStringOverwrite = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceTreatUnionsAsParts = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceSetStreaming = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceStreamingAreaSize = {
			default = 10000;
			coerce = function(value)
				return math.max(1, tonumber(value) or 10000)
			end;
		};
		saveInstanceStreamingRadius = {
			default = 1024;
			coerce = function(value)
				return math.max(1, tonumber(value) or 1024)
			end;
		};
		saveInstanceStreamingTimeout = {
			default = 20;
			coerce = function(value)
				return math.max(1, tonumber(value) or 20)
			end;
		};
		saveInstanceStreamingConcurrency = {
			default = 0;
			coerce = function(value)
				return math.max(0, math.floor((tonumber(value) or 0) + 0.5))
			end;
		};
		saveInstanceStreamingSlices = {
			default = 2;
			coerce = function(value)
				return math.max(1, math.floor((tonumber(value) or 2) + 0.5))
			end;
		};
		saveInstanceStreamingMaxTime = {
			default = 0;
			coerce = function(value)
				return math.max(0, tonumber(value) or 0)
			end;
		};
		saveInstanceStreamingChunkWait = {
			default = 12;
			coerce = function(value)
				return math.max(1, tonumber(value) or 12)
			end;
		};
		saveInstanceStreamingSettleTime = {
			default = 5;
			coerce = function(value)
				return math.max(0, tonumber(value) or 5)
			end;
		};
		saveInstanceNeutralizeLighting = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceExportObj = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceDecompileIgnore = {
			default = "Chat,CoreGui,CorePackages";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or value
			end;
		};
		saveInstanceIgnoreList = {
			default = "CoreGui,CorePackages";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or value
			end;
		};
		saveInstanceIgnoreProperties = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or value
			end;
		};
		saveInstanceNotCreatableFixes = {
			default = "Player,PlayerScripts,PlayerGui,TouchTransmitter";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or value
			end;
		};
		saveInstanceExtraOptionsJson = {
			default = "";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				return value:match("^%s*(.-)%s*$") or value
			end;
		};
		saveInstanceCommandHintShown = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		saveInstanceFileNameFormat = {
			default = "{placeName}_{timestamp}";
			coerce = function(value)
				if type(value) ~= "string" then
					value = tostring(value or "")
				end
				value = value:match("^%s*(.-)%s*$") or value
				if value == "" then
					return "{placeName}_{timestamp}"
				end
				return value
			end;
		};
		loadingStartMinimized = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		topbarMode = {
			pathKey = "NATOPBARMODE";
			default = "bottom";
			coerce = function(value)
				if type(value) ~= "string" then
					return "bottom"
				end
				if value == "side" then
					return "side"
				end
				return "bottom"
			end;
		};
		topbarDock = {
			default = "top";
			coerce = function(value)
				if value == "bottom" then
					return "bottom"
				end
				return "top"
			end;
		};
		robloxTopbarEditorEnabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		robloxTopbarLayout = {
			default = "Controls Unified";
			coerce = function(value)
				const normalized = type(value) == "string" and value:lower() or ""
				if normalized == "all unified" then
					return "All Unified"
				elseif normalized == "all separate" or normalized == "separate" or normalized == "separated" then
					return "All Separate"
				elseif normalized == "menu + chat + voice" or normalized == "menu chat voice" or normalized == "suggested" then
					return "Menu + Chat + Voice"
				end
				return "Controls Unified"
			end;
		};
		robloxTopbarMorePosition = {
			default = "Original";
			coerce = function(value)
				const normalized = type(value) == "string" and value:lower() or ""
				if normalized == "left" then
					return "Left"
				elseif normalized == "right" then
					return "Right"
				end
				return "Original"
			end;
		};
		robloxTopbarBackgroundColor = {
			default = function()
				return { R = 18 / 255; G = 18 / 255; B = 21 / 255 }
			end;
			coerce = function(value)
				local parsed = value
				if typeof(value) == "Color3" then
					parsed = { R = value.R; G = value.G; B = value.B }
				elseif type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					parsed = ok and decoded or nil
				end
				if type(parsed) == "table" then
					const r = NAmanage.NASettingsSchemaState.clampChannel(parsed.R or parsed.r or parsed[1])
					const g = NAmanage.NASettingsSchemaState.clampChannel(parsed.G or parsed.g or parsed[2])
					const b = NAmanage.NASettingsSchemaState.clampChannel(parsed.B or parsed.b or parsed[3])
					if r and g and b then
						return { R = r; G = g; B = b }
					end
				end
				return { R = 18 / 255; G = 18 / 255; B = 21 / 255 }
			end;
		};
		robloxTopbarBackgroundTransparency = {
			default = 0.08;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				return n == nil and 0.08 or n
			end;
		};
		robloxTopbarCornerRadius = {
			default = 22;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 22) + 0.5), 0, 32)
			end;
		};
		robloxTopbarSeparateGap = {
			default = 4;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 4) + 0.5), 0, 16)
			end;
		};
		robloxTopbarButtonSize = {
			default = 44;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 44) + 0.5), 32, 56)
			end;
		};
		robloxTopbarMenuGap = {
			default = 4;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 4) + 0.5), 0, 24)
			end;
		};
		robloxTopbarGroupPadding = {
			default = 0;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 0) + 0.5), 0, 12)
			end;
		};
		robloxTopbarVerticalOffset = {
			default = 10;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 10) + 0.5), 0, 32)
			end;
		};
		robloxTopbarHorizontalInset = {
			default = 16;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(math.floor((n or 16) + 0.5), 0, 48)
			end;
		};
		robloxTopbarStrokeEnabled = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		robloxTopbarStrokeColor = {
			default = function()
				return { R = 1; G = 1; B = 1 }
			end;
			coerce = function(value)
				local parsed = value
				if typeof(value) == "Color3" then
					parsed = { R = value.R; G = value.G; B = value.B }
				elseif type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					parsed = ok and decoded or nil
				end
				if type(parsed) == "table" then
					const r = NAmanage.NASettingsSchemaState.clampChannel(parsed.R or parsed.r or parsed[1])
					const g = NAmanage.NASettingsSchemaState.clampChannel(parsed.G or parsed.g or parsed[2])
					const b = NAmanage.NASettingsSchemaState.clampChannel(parsed.B or parsed.b or parsed[3])
					if r and g and b then
						return { R = r; G = g; B = b }
					end
				end
				return { R = 1; G = 1; B = 1 }
			end;
		};
		robloxTopbarStrokeTransparency = {
			default = 0.5;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				return n == nil and 0.5 or n
			end;
		};
		robloxTopbarStrokeThickness = {
			default = 1;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(n or 1, 0, 4)
			end;
		};
		robloxTopbarIconColor = {
			default = function()
				return { R = 1; G = 1; B = 1 }
			end;
			coerce = function(value)
				local parsed = value
				if typeof(value) == "Color3" then
					parsed = { R = value.R; G = value.G; B = value.B }
				elseif type(value) == "string" then
					local ok, decoded = NACaller(function()
						return Services.HttpService:JSONDecode(value)
					end)
					parsed = ok and decoded or nil
				end
				if type(parsed) == "table" then
					const r = NAmanage.NASettingsSchemaState.clampChannel(parsed.R or parsed.r or parsed[1])
					const g = NAmanage.NASettingsSchemaState.clampChannel(parsed.G or parsed.g or parsed[2])
					const b = NAmanage.NASettingsSchemaState.clampChannel(parsed.B or parsed.b or parsed[3])
					if r and g and b then
						return { R = r; G = g; B = b }
					end
				end
				return { R = 1; G = 1; B = 1 }
			end;
		};
		robloxTopbarIconTransparency = {
			default = 0;
			coerce = function(value)
				const n = NAmanage.NASettingsSchemaState.clampChannel(value)
				return n == nil and 0 or n
			end;
		};
		robloxTopbarIconScale = {
			default = 1;
			coerce = function(value)
				const n = tonumber(value)
				return math.clamp(n or 1, 0.6, 1.4)
			end;
		};
		robloxTopbarKeepIconGradient = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		disableLastInput = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		naChatHidden = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		naChatGameActivity = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		naChatDmNotify = {
			default = true;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, true)
			end;
		};
		naChatDisconnected = {
			default = false;
			coerce = function(value)
				return NAmanage.NASettingsSchemaState.coerceBoolean(value, false)
			end;
		};
		naChatMessageColor = {
			default = "78AAFF";
			coerce = function(value)
				local text = tostring(value or ""):gsub("#", ""):upper()
				if #text == 6 and text:match("^[%x]+$") then
					return text
				end
				return "78AAFF"
			end;
		};
	}

	return NAStuff.NASettingsSchema
end

NAmanage.NASettingsSave=function()
	if not FileSupport or not NAStuff.NASettingsData then
		return
	end

	if type(NAStuff.NASettingsData) == "table" then
		NAStuff.NASettingsData.engineSettings = nil
	end

	local ok, encoded = NACaller(function()
		return Services.HttpService:JSONEncode(NAStuff.NASettingsData)
	end)

	if ok and encoded then
		NAmanage.safeWriteFile(NAfiles.NAMAINSETTINGSPATH, encoded)
	end
end

NAmanage.NASettingsEnsure=function()
	if NAStuff.NASettingsData then
		return NAStuff.NASettingsData
	end

	const schema = NAmanage.NASettingsGetSchema()
	NAStuff.NASettingsData = {}

	if FileSupport and type(isfile) == "function" and NAmanage.safeIsFile(NAfiles.NAMAINSETTINGSPATH) then
		local ok, raw = NACaller(readfile, NAfiles.NAMAINSETTINGSPATH)
		if ok and raw and raw ~= "" then
			local success, decoded = NACaller(function()
				return Services.HttpService:JSONDecode(raw)
			end)
			if success and typeof(decoded) == "table" then
				NAStuff.NASettingsData = decoded
			end
		end
	end

	if typeof(NAStuff.NASettingsData) ~= "table" then
		NAStuff.NASettingsData = {}
	end

	if NAStuff.NASettingsData.offVisOn == nil and NAStuff.NASettingsData.offsetVisualizerEnabled ~= nil then
		NAStuff.NASettingsData.offVisOn = NAStuff.NASettingsData.offsetVisualizerEnabled
	end
	if NAStuff.NASettingsData.offVisAcc == nil and NAStuff.NASettingsData.offsetVisualizerIncludeAccessories ~= nil then
		NAStuff.NASettingsData.offVisAcc = NAStuff.NASettingsData.offsetVisualizerIncludeAccessories
	end
	if NAStuff.NASettingsData.offVisFTr == nil and NAStuff.NASettingsData.offsetVisualizerFillTransparency ~= nil then
		NAStuff.NASettingsData.offVisFTr = NAStuff.NASettingsData.offsetVisualizerFillTransparency
	end
	if NAStuff.NASettingsData.offVisOTr == nil and NAStuff.NASettingsData.offsetVisualizerOutlineTransparency ~= nil then
		NAStuff.NASettingsData.offVisOTr = NAStuff.NASettingsData.offsetVisualizerOutlineTransparency
	end

	const legacyIconPath = "Nameless-Admin/IconPosition.json"
	if FileSupport and type(isfile) == "function" and NAmanage.safeIsFile(legacyIconPath) then
		local okRaw, legacyRaw = NACaller(readfile, legacyIconPath)
		if okRaw and type(legacyRaw) == "string" and legacyRaw ~= "" then
			local okDecoded, legacyDecoded = NACaller(function()
				return Services.HttpService:JSONDecode(legacyRaw)
			end)
			if okDecoded and typeof(legacyDecoded) == "table" then
				if NAStuff.NASettingsData.iconPosition == nil then
					const lx = math.clamp(tonumber(legacyDecoded.X) or 0.5, 0, 1)
					const ly = math.clamp(tonumber(legacyDecoded.Y) or 0.1, 0, 1)
					NAStuff.NASettingsData.iconPosition = { X = lx; Y = ly }
				end
				if NAStuff.NASettingsData.iconKeepPosition == nil and legacyDecoded.Save ~= nil then
					NAStuff.NASettingsData.iconKeepPosition = legacyDecoded.Save == true
				end
			end
		end
		if delfile then
			NAmanage.safeDeleteFile(legacyIconPath)
		end
	end

	const legacyPaths = {}
	for key, def in schema do
		legacyPaths[key] = def.pathKey and NAfiles[def.pathKey] or nil
	end

	for key, def in schema do
		local value = NAStuff.NASettingsData[key]

		if value == nil and FileSupport and type(isfile) == "function" then
			const legacyPath = legacyPaths[key]
			if legacyPath and NAmanage.safeIsFile(legacyPath) then
				local ok, legacyRaw = NACaller(readfile, legacyPath)
				if ok and legacyRaw ~= nil then
					value = legacyRaw
				end
				if delfile then
					NAmanage.safeDeleteFile(legacyPath)
				end
			end
		end

		NAStuff.NASettingsData[key] = NAmanage.NASettingsCoerce(def, value)
	end

	NAmanage.NASettingsSave()
	return NAStuff.NASettingsData
end

NAmanage.NASettingsGet=function(key)
	const settings = NAmanage.NASettingsEnsure()
	return settings[key]
end

NAmanage.NASettingsSet=function(key, value)
	const schema = NAmanage.NASettingsGetSchema()
	const def = schema[key]
	if not def then
		return
	end

	const settings = NAmanage.NASettingsEnsure()
	settings[key] = NAmanage.NASettingsCoerce(def, value)
	NAmanage.NASettingsSave()
	return settings[key]
end

NAmanage.UnsafeFunctionNames = NAmanage.UnsafeFunctionNames or {
	"messagebox",
	"messageboxasync",
	"consoleprint",
	"consolewarn",
	"consoleerr",
	"consoleerror",
	"consoleinfo",
	"consoleclear",
	"consolecreate",
	"consoledestroy",
	"consoleclose",
	"consolename",
	"consoleinput",
	"consolesettitle",
	"rconsoleprint",
	"rconsolewarn",
	"rconsoleerr",
	"rconsoleerror",
	"rconsoleinfo",
	"rconsoleclear",
	"rconsolecreate",
	"rconsoledestroy",
	"rconsoleclose",
	"rconsolename",
	"rconsoleinput",
	"rconsolehide",
	"rconsoleshow",
	"rconsolesettitle",
}

NAmanage.VirtualInputFunctionNames = NAmanage.VirtualInputFunctionNames or {
	"keypress",
	"keyrelease",
	"keytap",
	"keyclick",
	"mouse1click",
	"mouse1press",
	"mouse1release",
	"mouse2click",
	"mouse2press",
	"mouse2release",
	"mousemoveabs",
	"mousemoverel",
	"mousescroll",
}

NAmanage.HWIDFunctionNames = NAmanage.HWIDFunctionNames or {
	"gethwid",
	"get_hwid",
	"get_user_identifier",
}

NAmanage.GetUnsafeFunctionStores = NAmanage.GetUnsafeFunctionStores or function()
	const stores = {}
	const seen = {}
	const function addStore(store)
		if type(store) ~= "table" or seen[store] then
			return
		end
		seen[store] = true
		Insert(stores, store)
	end
	addStore(_na_env)
	addStore(_G)
	addStore(_na_shared)
	const host = _na_boot and _na_boot.hostEnv
	addStore(host)
	if type(host) == "table" then
		addStore(rawget(host, "syn"))
	end
	if type(getgenv) == "function" then
		local ok, env = pcall(getgenv)
		if ok then
			addStore(env)
			if type(env) == "table" then
				addStore(rawget(env, "syn"))
			end
		end
	end
	if type(getfenv) == "function" then
		local ok, env = pcall(getfenv)
		if ok then
			addStore(env)
		end
	end
	return stores
end

NAmanage.RConsoleFunctionNames = NAmanage.RConsoleFunctionNames or {
	"rconsoleprint",
	"rconsolewarn",
	"rconsoleerr",
	"rconsoleerror",
	"rconsoleinfo",
	"rconsoleclear",
	"rconsolecreate",
	"rconsoledestroy",
	"rconsoleclose",
	"rconsolename",
	"rconsoleinput",
}

NAmanage.RConsoleFunctionSet = NAmanage.RConsoleFunctionSet or {}
for _, name in NAmanage.RConsoleFunctionNames do
	NAmanage.RConsoleFunctionSet[name] = true
end

NAmanage.NAConsoleNormalizeTag = NAmanage.NAConsoleNormalizeTag or function(tag)
	tag = Lower(tostring(tag or "Output"))
	if tag == "warn" or tag == "warning" then
		return "Warn"
	elseif tag == "err" or tag == "error" then
		return "Error"
	elseif tag == "info" then
		return "Info"
	end
	return "Output"
end

NAmanage.NAConsoleTagColor = NAmanage.NAConsoleTagColor or function(tag)
	tag = NAmanage.NAConsoleNormalizeTag(tag)
	if tag == "Error" then
		return "#ff6464"
	elseif tag == "Warn" then
		return "#ffcc00"
	elseif tag == "Info" then
		return "#66ccff"
	end
	return "#cccccc"
end

NAmanage.NAConsoleEscapeRich = NAmanage.NAConsoleEscapeRich or function(value)
	local s = tostring(value or "")
	return ((s:gsub("&", "&amp;")):gsub("<", "&lt;")):gsub(">", "&gt;")
end

NAmanage.NAConsoleNormalizeContext = NAmanage.NAConsoleNormalizeContext or function(context)
	if type(context) ~= "table" then
		return {}
	end
	const seen = {}
	const function normalizeValue(value, depth)
		const valueType = type(value)
		const valueKind = typeof(value)
		if valueKind == "Instance" then
			local ok, fullName = pcall(function()
				return value:GetFullName()
			end)
			return ok and tostring(fullName) or tostring(value)
		end
		if valueType == "string" then
			if #value > 2048 then
				return value:sub(1, 2045).."..."
			end
			return value
		elseif valueType == "number" or valueType == "boolean" or valueType == "nil" then
			return value
		elseif valueType ~= "table" then
			return tostring(value)
		end
		if seen[value] then
			return "<cycle>"
		end
		if depth >= 3 then
			return tostring(value)
		end
		seen[value] = true
		local out = {}
		local count = 0
		for key, item in value do
			count += 1
			if count > 48 then
				out.__truncated = true
				break
			end
			out[tostring(key)] = normalizeValue(item, depth + 1)
		end
		seen[value] = nil
		return out
	end
	return normalizeValue(context, 0)
end

NAmanage.NAConsoleContextText = NAmanage.NAConsoleContextText or function(context)
	if type(context) ~= "table" or next(context) == nil then
		return ""
	end
	const keys = {}
	for key in context do
		keys[#keys + 1] = tostring(key)
	end
	table.sort(keys)
	const parts = {}
	for i = 1, #keys do
		const key = keys[i]
		const value = context[key]
		local valueText
		if type(value) == "table" then
			local ok, encoded = pcall(function()
				return Services.HttpService:JSONEncode(value)
			end)
			valueText = ok and encoded or tostring(value)
		else
			valueText = tostring(value)
		end
		parts[#parts + 1] = key.."="..valueText
	end
	return Concat(parts, " | ")
end

NAmanage.NAConsoleResolveSource = NAmanage.NAConsoleResolveSource or function(context, rawText)
	context = type(context) == "table" and context or {}
	local source = context.source or context.Source or context.origin or context.Origin
	local subsystem = context.subsystem or context.Subsystem or context.system or context.System
	if source == nil then
		const text = Lower(tostring(rawText or ""))
		if text:sub(1, 4) == "[na]" or text:find("nameless admin", 1, true) then
			source = "NamelessAdmin"
		else
			source = "Game"
		end
	end
	return tostring(source), subsystem ~= nil and tostring(subsystem) or ""
end

NAmanage.NAConsoleTimeInfo = NAmanage.NAConsoleTimeInfo or function(timestamp)
	local numeric = tonumber(timestamp)
	if numeric and numeric > 100000000 then
		numeric = math.floor(numeric)
		local ok, clock = pcall(os.date, "%H:%M:%S", numeric)
		if ok and clock then
			return tostring(clock), numeric
		end
	end
	local ok, clock = pcall(os.date, "%H:%M:%S")
	return (ok and tostring(clock)) or "--:--:--", numeric or (os.time and os.time() or 0)
end

NAmanage.NAConsoleRefreshRecord = NAmanage.NAConsoleRefreshRecord or function(record)
	if type(record) ~= "table" then
		return record
	end
	const showTime = NAStuff.DevConsoleTimestamps ~= false
	const showSource = NAStuff.DevConsoleShowSource ~= false
	const copyContext = NAStuff.DevConsoleCopyContext ~= false
	local sourceLabel = tostring(record.source or "")
	if Lower(sourceLabel) == "namelessadmin" then
		sourceLabel = "NA"
	end
	const subsystem = tostring(record.subsystem or "")
	if subsystem ~= "" then
		sourceLabel = sourceLabel ~= "" and (sourceLabel.."/"..subsystem) or subsystem
	end
	const count = math.max(1, tonumber(record.duplicateCount) or 1)
	const suffix = count > 1 and ("  ×"..tostring(count)) or ""
	const timeText = tostring(record.lastTimeText or record.timeText or "--:--:--")
	local plainPrefix = ""
	local richPrefix = ""
	if showTime then
		plainPrefix = "["..timeText.."] "
		richPrefix = "<font color=\"#888888\">["..NAmanage.NAConsoleEscapeRich(timeText).."]</font> "
	end
	local sourcePlain = ""
	local sourceRich = ""
	if showSource and sourceLabel ~= "" and sourceLabel ~= "Game" then
		sourcePlain = " ["..sourceLabel.."]"
		sourceRich = " <font color=\"#aaaaaa\">["..NAmanage.NAConsoleEscapeRich(sourceLabel).."]</font>"
	end
	record.plainText = plainPrefix.."["..tostring(record.tag or "Output").."]"..sourcePlain..": "..tostring(record.raw or "")..suffix
	record.richText = richPrefix.."<font color=\""..tostring(record.color or "#cccccc").."\">["..NAmanage.NAConsoleEscapeRich(record.tag or "Output").."]</font>"..sourceRich..": <font color=\"#ffffff\">"..NAmanage.NAConsoleEscapeRich(record.raw or "")..NAmanage.NAConsoleEscapeRich(suffix).."</font>"
	local copy = record.plainText
	if copyContext and tostring(record.contextText or "") ~= "" then
		copy ..= "\nContext: "..tostring(record.contextText)
	end
	if count > 1 then
		copy ..= "\nFirst seen: "..tostring(record.timeText or timeText).." | Last seen: "..timeText.." | Count: "..tostring(count)
	end
	record.copyText = copyContext and copy or tostring(record.raw or "")
	record.searchText = Lower(Concat({
		record.plainText,
		tostring(record.raw or ""),
		tostring(record.source or ""),
		tostring(record.subsystem or ""),
		tostring(record.contextText or ""),
		"count="..tostring(count),
	}, " "))
	record.height = nil
	record.measureWidth = nil
	record.revision = (tonumber(record.revision) or 0) + 1
	return record
end

NAmanage.NAConsoleRecordMatchesQuery = NAmanage.NAConsoleRecordMatchesQuery or function(record, query)
	if type(record) ~= "table" then
		return false
	end
	query = Lower(tostring(query or "")):match("^%s*(.-)%s*$") or ""
	if query == "" then
		return true
	end
	const searchText = tostring(record.searchText or "")
	for token in query:gmatch("%S+") do
		local key, value = token:match("^([%w_]+):(.*)$")
		if key and value and value ~= "" then
			if key == "type" or key == "tag" then
				if Find(Lower(tostring(record.tag or "")), value, 1, true) == nil then return false end
			elseif key == "source" then
				if Find(Lower(tostring(record.source or "")), value, 1, true) == nil then return false end
			elseif key == "subsystem" or key == "system" then
				if Find(Lower(tostring(record.subsystem or "")), value, 1, true) == nil then return false end
			elseif key == "ctx" or key == "context" then
				if Find(Lower(tostring(record.contextText or "")), value, 1, true) == nil then return false end
			elseif key == "count" then
				const count = math.max(1, tonumber(record.duplicateCount) or 1)
				const op, numText = value:match("^([<>]=?)(%d+)$")
				const wanted = tonumber(numText or value)
				if wanted then
					if op == ">" and not (count > wanted) then return false end
					if op == ">=" and not (count >= wanted) then return false end
					if op == "<" and not (count < wanted) then return false end
					if op == "<=" and not (count <= wanted) then return false end
					if not op and count ~= wanted then return false end
				end
			else
				if Find(searchText, token, 1, true) == nil then return false end
			end
		elseif Find(searchText, token, 1, true) == nil then
			return false
		end
	end
	return true
end
