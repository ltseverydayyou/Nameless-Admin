NAmanage.UG_disable = function(state, message)
	if type(state) ~= "table" then
		return
	end

	const function fetchRoot()
		local _, root = NAmanage.UG_fetchCharPieces()
		return root
	end

	for _ = 1, 10 do
		const root = fetchRoot()
		if root then
			root.CFrame = state.UndergroundCurrent or root.CFrame
		end
		Wait()
	end

	state.UndergroundCurrent = nil
	state.UndergroundServerCFrame = nil
	state.UndergroundTransform = nil
	state.UndergroundMirrorGround = nil
	state.UndergroundOffsetActive = nil
	state.UndergroundUpsideDown = nil
	state.UndergroundResolvedOffset = nil

	const hb = state.heartbeatConnection
	if hb then
		pcall(function()
			hb:Disconnect()
		end)
		state.heartbeatConnection = nil
	end
	NAlib.disconnect("underground_heartbeat")

	state.UndergroundOffset = nil
	state.PendingTranslation = nil
	state.Underground = false
	NAmanage.ovClr(state)

	if state.UndergroundBind then
		state.UndergroundBind = false
		if Services.RunService and Services.RunService.UnbindFromRenderStep then
			pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, NAStuff.NA_UNDERGROUND_BIND_NAME)
		end
	end

	if message and type(DoNotif) == "function" then
		DoNotif(message, 2)
	end
end

NAmanage.UG_cframeNear = function(a, b, distance)
	return typeof(a) == "CFrame" and typeof(b) == "CFrame"
		and (a.Position - b.Position).Magnitude <= (distance or 0.05)
end

NAmanage.UG_adoptExternalCFrame = function(st, observed)
	if type(st) ~= "table" or typeof(observed) ~= "CFrame" then
		return false
	end
	local current = st.UndergroundCurrent
	if typeof(current) ~= "CFrame" then
		st.UndergroundCurrent = observed
		st.UndergroundServerCFrame = nil
		st.PendingTranslation = nil
		return true
	end
	if NAmanage.UG_cframeNear(observed, st.UndergroundServerCFrame) then
		return false
	end
	if (observed.Position - current.Position).Magnitude < (tonumber(NAStuff.NA_UNDERGROUND_EXTERNAL_TELEPORT_DISTANCE) or 4) then
		return false
	end
	st.UndergroundCurrent = observed
	st.UndergroundServerCFrame = nil
	st.PendingTranslation = nil
	return true
end

NAmanage.UG_enable = function(state, rootPart)
	if state.Underground then
		NAmanage.UG_updateVisualizer(state, rootPart, state.UndergroundCurrent or (rootPart and rootPart.CFrame), true)
		return
	end

	state.Underground = true
	state.UndergroundCurrent = rootPart.CFrame
	state.UndergroundServerCFrame = nil
	state.PendingTranslation = nil

	const prevHB = state.heartbeatConnection
	if prevHB then
		pcall(function() prevHB:Disconnect() end)
	end

	state.heartbeatConnection = NAlib.reconnect("underground_heartbeat", Services.RunService.Heartbeat:Connect(function()
		if not state.Underground then
			return
		end

		local _, currentRoot, hum = NAmanage.UG_fetchCharPieces()
		if not currentRoot then
			return
		end

		local observed = currentRoot.CFrame
		if not NAmanage.UG_cframeNear(observed, state.UndergroundServerCFrame) then
			if not NAmanage.UG_adoptExternalCFrame(state, observed) then
				state.UndergroundCurrent = observed
			end
		end
		local baseCFrame = state.UndergroundCurrent or observed
		const pendingTranslation = state.PendingTranslation
		if typeof(pendingTranslation) == "Vector3" and pendingTranslation.Magnitude > 0 then
			baseCFrame += pendingTranslation
			state.PendingTranslation = nil
		end

		state.UndergroundCurrent = baseCFrame
		if hum then
			hum.Sit = false
		end

		const activeTransform = NAmanage.UG_getTransform(state)
		const activeOffset = NAmanage.UG_getActiveOffset(state, currentRoot, hum)
		state.UndergroundResolvedOffset = activeOffset
		state.UndergroundServerCFrame = (baseCFrame * activeTransform) + activeOffset
		currentRoot.CFrame = state.UndergroundServerCFrame
	end))

	if Services.RunService and Services.RunService.UnbindFromRenderStep then
		pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, NAStuff.NA_UNDERGROUND_BIND_NAME)
	end
	state.UndergroundBind = true
	__lt.cm("RunService", "BindToRenderStep", NAStuff.NA_UNDERGROUND_BIND_NAME, Enum.RenderPriority.First.Value, function()
		local _, root = NAmanage.UG_fetchCharPieces()
		if root then
			local observed = root.CFrame
			if not NAmanage.UG_cframeNear(observed, state.UndergroundServerCFrame) then
				NAmanage.UG_adoptExternalCFrame(state, observed)
			end
		end
		const current = state.UndergroundCurrent
		if state.Underground and current then
			if root then
				root.CFrame = current
				NAmanage.UG_updateVisualizer(state, root, current)
			end
		end
	end)

	NAmanage.UG_updateVisualizer(state, rootPart, state.UndergroundCurrent or rootPart.CFrame, true)
end

cmd.add({"offset","offpos","off"},{"offset [x y z|y]","Offsets and rotates your character for others using the Character-tab customization"},function(...)
	local character, rootPart, humanoid = NAmanage.UG_fetchCharPieces()
	if not (character and rootPart and humanoid) then
		if type(DoNotif) == "function" then
			DoNotif("Character is not ready yet", 2)
		end
		return
	end

	const raw = Concat({...}, " ")
	const nums = {}
	for token in tostring(raw):gmatch("[^,%s]+") do
		const numberValue = tonumber(token)
		if numberValue then
			Insert(nums, numberValue)
		end
	end

	local offsetVec = nil
	if #nums >= 3 then
		offsetVec = Vector3.new(nums[1], nums[2], nums[3])
	elseif #nums == 2 then
		offsetVec = Vector3.new(nums[1], nums[2], 0)
	elseif #nums == 1 then
		offsetVec = Vector3.new(0, nums[1], 0)
	end

	const wasActive = NAStuff.NAundergroundState.Underground == true and NAStuff.NAundergroundState.UndergroundOffsetActive == true
	if not NAmanage.UG_enableConfiguredOffset(offsetVec) then
		if type(DoNotif) == "function" then
			DoNotif("Unable to enable offset", 2)
		end
		return
	end
	if type(DoNotif) == "function" then
		DoNotif(wasActive and "Offset customization updated" or "Offset customization enabled (replicates for others)", 2)
	end
end)

cmd.add({"upsidedown","flipchar"},{"upsidedown","Flips your character upside down for others using the offset replication method"},function()
	const state = NAStuff.NAundergroundState
	local character, rootPart, humanoid = NAmanage.UG_fetchCharPieces()
	if not (character and rootPart and humanoid) then
		if type(DoNotif) == "function" then
			DoNotif("Character is not ready yet", 2)
		end
		return
	end

	state.UndergroundUpsideDown = true
	state.UndergroundMirrorGround = true
	NAmanage.UG_refreshTransform(state)
	if not state.Underground then
		state.UndergroundOffset = state.UndergroundOffsetActive == true and NAmanage.UG_getConfiguredOffset() or Vector3.new(0, 0, 0)
		state.PendingTranslation = nil
		NAmanage.UG_enable(state, rootPart)
		if type(DoNotif) == "function" then
			DoNotif("Upsidedown enabled (replicates for others)", 2)
		end
		return
	end

	state.UndergroundResolvedOffset = NAmanage.UG_getActiveOffset(state, rootPart, humanoid)
	NAmanage.UG_updateVisualizer(state, rootPart, state.UndergroundCurrent or rootPart.CFrame, true)
	if type(DoNotif) == "function" then
		DoNotif("Upsidedown updated", 2)
	end
end)

cmd.add({"unoffset","unoffpos","unoff"},{"unoffset","Disables offset customization and restores your character"},function()
	const state = NAStuff.NAundergroundState
	if type(state) ~= "table" then
		return
	end
	if state.Underground ~= true or state.UndergroundOffsetActive ~= true then
		if type(DoNotif) == "function" then
			DoNotif("Offset is already disabled", 2)
		end
		return
	end

	state.UndergroundOffsetActive = nil
	state.UndergroundOffset = nil
	NAmanage.UG_refreshTransform(state)
	if state.UndergroundUpsideDown == true then
		local _, root, hum = NAmanage.UG_fetchCharPieces()
		state.UndergroundResolvedOffset = NAmanage.UG_getActiveOffset(state, root, hum)
		NAmanage.UG_updateVisualizer(state, root, state.UndergroundCurrent or (root and root.CFrame), true)
		if type(DoNotif) == "function" then
			DoNotif("Offset disabled, upside down is still active", 2)
		end
		return
	end

	NAmanage.UG_disable(state, "Offset disabled, you're back to normal")
end)

cmd.add({"unupsidedown","unflipchar"},{"unupsidedown","Disables the upside down replication and restores your character"},function()
	const state = NAStuff.NAundergroundState
	if type(state) ~= "table" or state.Underground ~= true or state.UndergroundUpsideDown ~= true then
		if type(DoNotif) == "function" then
			DoNotif("Upsidedown is already disabled", 2)
		end
		return
	end

	state.UndergroundUpsideDown = nil
	state.UndergroundMirrorGround = nil
	NAmanage.UG_refreshTransform(state)
	if state.UndergroundOffsetActive == true then
		state.UndergroundOffset = NAmanage.UG_getConfiguredOffset()
		state.UndergroundResolvedOffset = state.UndergroundOffset
		local _, root = NAmanage.UG_fetchCharPieces()
		NAmanage.UG_updateVisualizer(state, root, state.UndergroundCurrent or (root and root.CFrame), true)
		if type(DoNotif) == "function" then
			DoNotif("Upsidedown disabled, offset customization is still active", 2)
		end
		return
	end

	NAmanage.UG_disable(state, "Upsidedown disabled, you're back to normal")
end)

clickscareUI = nil
clickscareEnabled = true

cmd.add({"clickscare","clickspook"},{"clickscare (clickspook)","Teleports next to a clicked player for a few seconds"},function()
	clickscareEnabled = true
	if clickscareUI then clickscareUI:Destroy() end
	NAlib.disconnect("clickscare_mouse")

	const Mouse = NAmanage.GetMouse(player)
	clickscareUI = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(clickscareUI)

	const toggleButton = InstanceNew("TextButton")
	toggleButton.Size = UDim2.new(0,120,0,40)
	toggleButton.Text = "ClickScare: ON"
	toggleButton.Position = UDim2.new(0.5,-60,0,10)
	toggleButton.TextScaled = 16
	toggleButton.TextColor3 = Color3.new(1,1,1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
	toggleButton.BackgroundTransparency = 0.2
	toggleButton.Parent = clickscareUI

	const uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = toggleButton

	NAgui.draggerV2(toggleButton)

	MouseButtonFix(toggleButton,function()
		clickscareEnabled = not clickscareEnabled
		toggleButton.Text = clickscareEnabled and "ClickScare: ON" or "ClickScare: OFF"
	end)

	const conn = Mouse.Button1Down:Connect(function()
		if not clickscareEnabled then return end
		const target = NAmanage.GetMouseTargetPart(Mouse, { player and player.Character }, 1024)
		const targetCharacter = NAmanage.ResolveHumanoidModelFromPart(target)
		if not targetCharacter then return end
		const clickedPlayer = __lt.cm("Players", "GetPlayerFromCharacter", targetCharacter)
		if not clickedPlayer or not getPlrHum(clickedPlayer) then return end

		const char = getChar()
		const root = getRoot(char)
		const oldCF = NAmanage.UG_clientCFrame(root) or root.CFrame
		const distancepl = 2
		const targetRoot = getRoot(clickedPlayer.Character)
		if targetRoot then
			const nextCF = targetRoot.CFrame + targetRoot.CFrame.LookVector * distancepl
			NAmanage.UG_setClientCFrame(root, nextCF)
			NAmanage.UG_setClientCFrame(root, CFrame.new(nextCF.Position, targetRoot.Position))
			Wait(0.5)
			NAmanage.UG_setClientCFrame(root, oldCF)
		end
	end)

	NAlib.connect("clickscare_mouse",conn)
end)

cmd.add({"unclickscare","unclickspook"},{"unclickscare (unclickspook)","Disables clickscare"},function()
	clickscareEnabled = false
	if clickscareUI then clickscareUI:Destroy() end
	NAlib.disconnect("clickscare_mouse")
end)

hoverNameGui = nil
hoverNameLabel = nil
hoverNameSelection = nil

NAmanage.cleanupHoverName=function()
	NAlib.disconnect("hovername_track")
	if hoverNameLabel then
		hoverNameLabel:Destroy()
		hoverNameLabel = nil
	end
	if hoverNameGui then
		hoverNameGui:Destroy()
		hoverNameGui = nil
	end
	if hoverNameSelection then
		hoverNameSelection.Adornee = nil
		hoverNameSelection.Parent = nil
		hoverNameSelection:Destroy()
		hoverNameSelection = nil
	end
end

cmd.add({"hovername","namehover"}, {"hovername", "Shows player's username on hover"}, function()
	NAmanage.cleanupHoverName()

	hoverNameGui = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(hoverNameGui)

	hoverNameLabel = InstanceNew("TextLabel")
	hoverNameLabel.BackgroundTransparency = 1
	hoverNameLabel.Size = UDim2.new(0,200,0,30)
	hoverNameLabel.Font = Enum.Font.GothamBold
	hoverNameLabel.TextSize = 16
	hoverNameLabel.Text = ""
	hoverNameLabel.TextColor3 = Color3.new(1,1,1)
	hoverNameLabel.TextStrokeTransparency = 0
	hoverNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	hoverNameLabel.Visible = false
	hoverNameLabel.ZIndex = 10
	hoverNameLabel.Parent = hoverNameGui

	hoverNameSelection = InstanceNew("SelectionBox")
	NAgui.NAProtection(hoverNameSelection)
	hoverNameSelection.LineThickness = 0.03
	hoverNameSelection.Color3 = Color3.new(1,1,1)
	hoverNameSelection.Adornee = nil
	hoverNameSelection.Parent = nil

	const mouse = player and NAmanage.GetMouse(player)
	if not mouse then
		NAmanage.cleanupHoverName()
		return
	end

	local lastTarget = nil
	local lastCharacter = nil
	local lastResolvedAt = 0
	local lastHoverText = ""
	local lastHoverAlignRight = nil

	const function resolveHoverCharacter(target)
		if not target then
			return nil
		end
		const parent = target.Parent
		if not parent then
			return nil
		end
		local humanoid = parent:FindFirstChildOfClass("Humanoid")
		if not humanoid and parent.Parent then
			humanoid = parent.Parent:FindFirstChildOfClass("Humanoid")
		end
		if humanoid then
			return humanoid.Parent
		end
		return nil
	end

	const function updateHoverName(x, y, now)
		now = tonumber(now) or os.clock()
		x = tonumber(x) or mouse.X or 0
		y = tonumber(y) or mouse.Y or 0

		const target = NAmanage.GetMouseTargetPart(mouse, { player and player.Character }, 1024)
		const shouldResolve = target ~= lastTarget or (now - lastResolvedAt) >= 0.08
		if shouldResolve then
			lastTarget = target
			lastResolvedAt = now
			lastCharacter = resolveHoverCharacter(target)
		end

		const character = lastCharacter
		if character and character:IsA("Model") and character.Parent then
			const alignRight = x > 200
			local xPos
			if alignRight then
				xPos = x - 205
			else
				xPos = x + 25
			end
			hoverNameLabel.Position = UDim2.new(0, xPos, 0, y)
			if lastHoverAlignRight ~= alignRight then
				hoverNameLabel.TextXAlignment = alignRight and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
				lastHoverAlignRight = alignRight
			end
			if shouldResolve then
				const isPlr = __lt.cm("Players", "GetPlayerFromCharacter", character)
				const text = nameChecker(isPlr or character)
				if text ~= lastHoverText then
					hoverNameLabel.Text = text
					lastHoverText = text
				end
				if hoverNameSelection.Adornee ~= character then
					hoverNameSelection.Adornee = character
				end
				if hoverNameSelection.Parent ~= character then
					hoverNameSelection.Parent = character
				end
			end
			if not hoverNameLabel.Visible then
				hoverNameLabel.Visible = true
			end
		else
			lastCharacter = nil
			lastHoverText = ""
			if hoverNameLabel.Visible then
				hoverNameLabel.Visible = false
			end
			if hoverNameSelection.Adornee ~= nil then
				hoverNameSelection.Adornee = nil
			end
			if hoverNameSelection.Parent ~= nil then
				hoverNameSelection.Parent = nil
			end
		end
	end

	NAlib.disconnect("hovername_track")
	NAlib.connect("hovername_track", NAmanage.mouseMoveSub(mouse, {
		fn = updateHoverName,
		minInterval = 0.02,
		minDelta = 1,
	}))
	updateHoverName(mouse.X, mouse.Y, os.clock())
end)

cmd.add({"unhovername","unnamehover"}, {"unhovername", "Disables hovername"}, function()
	NAmanage.cleanupHoverName()
end)

hoverInventoryGui = nil
hoverInventoryFrame = nil
hoverInventoryLabel = nil
hoverInventorySelection = nil

NAmanage.cleanupHoverInventory=function()
	NAlib.disconnect("hoverinventory_track")
	if hoverInventoryLabel then
		hoverInventoryLabel:Destroy()
		hoverInventoryLabel = nil
	end
	if hoverInventoryFrame then
		hoverInventoryFrame:Destroy()
		hoverInventoryFrame = nil
	end
	if hoverInventoryGui then
		hoverInventoryGui:Destroy()
		hoverInventoryGui = nil
	end
	if hoverInventorySelection then
		hoverInventorySelection.Adornee = nil
		hoverInventorySelection.Parent = nil
		hoverInventorySelection:Destroy()
		hoverInventorySelection = nil
	end
end

cmd.add({"hoverinventory","hoverinv"}, {"hoverinventory (hoverinv)", "Shows a player's inventory on hover"}, function()
	NAmanage.cleanupHoverInventory()

	const T = NAstatsUI and NAstatsUI.Theme
	const colors = T and T.Colors or {}
	hoverInventoryGui = InstanceNew("ScreenGui")
	hoverInventoryGui.Name = "NAHoverInventory"
	NAgui.NaProtectUI(hoverInventoryGui)

	hoverInventoryFrame = InstanceNew("Frame")
	hoverInventoryFrame.BackgroundColor3 = colors.Primary or Color3.fromRGB(20, 23, 34)
	hoverInventoryFrame.BackgroundTransparency = 0.08
	hoverInventoryFrame.BorderSizePixel = 0
	hoverInventoryFrame.Size = UDim2.new(0, 270, 0, 42)
	hoverInventoryFrame.Visible = false
	hoverInventoryFrame.ZIndex = 10
	hoverInventoryFrame.Parent = hoverInventoryGui
	InstanceNew("UICorner", hoverInventoryFrame).CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke")
	stroke.Color = NAUISTROKER or colors.Border or Color3.fromRGB(70, 75, 95)
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = hoverInventoryFrame

	const padding = InstanceNew("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = hoverInventoryFrame

	hoverInventoryLabel = InstanceNew("TextLabel")
	hoverInventoryLabel.BackgroundTransparency = 1
	hoverInventoryLabel.Size = UDim2.new(1, 0, 1, 0)
	hoverInventoryLabel.Font = (T and T.Fonts and T.Fonts.BodySemibold) or Enum.Font.GothamSemibold
	hoverInventoryLabel.TextSize = 13
	hoverInventoryLabel.Text = ""
	hoverInventoryLabel.TextColor3 = colors.Text or Color3.fromRGB(235, 238, 250)
	hoverInventoryLabel.TextStrokeTransparency = 1
	hoverInventoryLabel.TextXAlignment = Enum.TextXAlignment.Left
	hoverInventoryLabel.TextYAlignment = Enum.TextYAlignment.Top
	hoverInventoryLabel.TextWrapped = false
	hoverInventoryLabel.TextTruncate = Enum.TextTruncate.AtEnd
	hoverInventoryLabel.ZIndex = 11
	hoverInventoryLabel.Parent = hoverInventoryFrame

	hoverInventorySelection = InstanceNew("SelectionBox")
	NAgui.NAProtection(hoverInventorySelection)
	hoverInventorySelection.LineThickness = 0.03
	hoverInventorySelection.Color3 = NAUISTROKER or colors.Accent or Color3.fromRGB(90, 190, 255)
	hoverInventorySelection.Adornee = nil
	hoverInventorySelection.Parent = nil

	const mouse = player and NAmanage.GetMouse(player)
	if not mouse then
		NAmanage.cleanupHoverInventory()
		return
	end

	local lastTarget = nil
	local lastCharacter = nil
	local lastResolvedAt = 0
	local lastInventoryText = ""
	local lastTextAt = 0
	local lastAlignRight = nil

	const function resolveHoverCharacter(target)
		if not target then
			return nil
		end
		const parent = target.Parent
		if not parent then
			return nil
		end
		local humanoid = parent:FindFirstChildOfClass("Humanoid")
		if not humanoid and parent.Parent then
			humanoid = parent.Parent:FindFirstChildOfClass("Humanoid")
		end
		if humanoid then
			return humanoid.Parent
		end
		return nil
	end

	const function getInventoryText(plr, character)
		const equipped = {}
		const backpack = {}
		if character then
			for _, item in character:GetChildren() do
				if item:IsA("Tool") then
					Insert(equipped, item.Name)
				end
			end
		end
		const bp = plr and (plr:FindFirstChildOfClass("Backpack") or plr:FindFirstChild("Backpack"))
		if bp then
			for _, item in bp:GetChildren() do
				if item:IsA("Tool") then
					Insert(backpack, item.Name)
				end
			end
		end
		table.sort(equipped)
		table.sort(backpack)

		const lines = {}
		for _, name in equipped do
			Insert(lines, "* "..name)
		end
		for _, name in backpack do
			Insert(lines, name)
		end
		if #lines == 0 then
			return "No tools"
		end
		return Concat(lines, "\n")
	end

	const function fitBox(text)
		local lines = 1
		for _ in tostring(text or ""):gmatch("\n") do
			lines += 1
		end
		const height = math.clamp((lines * 17) + 18, 42, 220)
		hoverInventoryFrame.Size = UDim2.new(0, 270, 0, height)
	end

	const function updateHoverInventory(x, y, now)
		now = tonumber(now) or os.clock()
		x = tonumber(x) or mouse.X or 0
		y = tonumber(y) or mouse.Y or 0

		const target = NAmanage.GetMouseTargetPart(mouse, { player and player.Character }, 1024)
		const shouldResolve = target ~= lastTarget or (now - lastResolvedAt) >= 0.08
		if shouldResolve then
			lastTarget = target
			lastResolvedAt = now
			lastCharacter = resolveHoverCharacter(target)
		end

		const character = lastCharacter
		if character and character:IsA("Model") and character.Parent then
			const plr = __lt.cm("Players", "GetPlayerFromCharacter", character)
			const refreshText = shouldResolve or (now - lastTextAt) >= 0.25
			if refreshText then
				const text = getInventoryText(plr, character)
				if text ~= lastInventoryText then
					hoverInventoryLabel.Text = text
					lastInventoryText = text
					fitBox(text)
				end
				lastTextAt = now
			end

			const width = hoverInventoryFrame.AbsoluteSize.X > 0 and hoverInventoryFrame.AbsoluteSize.X or 270
			const camera = Services.Workspace and Services.Workspace.CurrentCamera
			const viewportX = camera and camera.ViewportSize.X or 0
			const alignRight = (viewportX > 0 and (x + width + 30) > viewportX) or x > 300
			const xPos = alignRight and (x - width - 15) or (x + 25)
			hoverInventoryFrame.Position = UDim2.new(0, xPos, 0, y)
			if lastAlignRight ~= alignRight then
				hoverInventoryLabel.TextXAlignment = alignRight and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
				lastAlignRight = alignRight
			end

			if hoverInventorySelection.Adornee ~= character then
				hoverInventorySelection.Adornee = character
			end
			if hoverInventorySelection.Parent ~= character then
				hoverInventorySelection.Parent = character
			end
			if not hoverInventoryFrame.Visible then
				hoverInventoryFrame.Visible = true
			end
		else
			lastCharacter = nil
			lastInventoryText = ""
			if hoverInventoryFrame.Visible then
				hoverInventoryFrame.Visible = false
			end
			if hoverInventorySelection.Adornee ~= nil then
				hoverInventorySelection.Adornee = nil
			end
			if hoverInventorySelection.Parent ~= nil then
				hoverInventorySelection.Parent = nil
			end
		end
	end

	NAlib.disconnect("hoverinventory_track")
	NAlib.connect("hoverinventory_track", NAmanage.mouseMoveSub(mouse, {
		fn = updateHoverInventory,
		minInterval = 0.02,
		minDelta = 1,
	}))
	updateHoverInventory(mouse.X, mouse.Y, os.clock())
end)

cmd.add({"unhoverinventory","unhoverinv","nohoverinventory"}, {"unhoverinventory (unhoverinv)", "Disables hoverinventory"}, function()
	NAmanage.cleanupHoverInventory()
end)

cmd.add({"resetfilter", "ref"}, {"resetfilter","If Pedoblox keeps tagging your messages, run this to reset the filter"}, function()
	for Index = 1, 3 do
		__lt.cm("Players", "Chat", Format("/e hi"))
	end
	return "Filter", "Reset"
end)

NAstatsUI = {}
windowCounter = (windowCounter or 0)
windowRegistry = windowRegistry or {}

NAstatsUI.Theme = {
	Colors = {
		Background = Color3.fromRGB(8, 8, 9),
		Primary = Color3.fromRGB(18, 18, 20),
		Secondary = Color3.fromRGB(35, 35, 39),
		Border = Color3.fromRGB(222, 222, 224),
		Accent = Color3.fromRGB(245, 245, 245),
		Text = Color3.fromRGB(255, 255, 255),
		TextMuted = Color3.fromRGB(205, 205, 210),
		TextSubtle = Color3.fromRGB(238, 238, 242),
		Close = Color3.fromRGB(190, 45, 42),
		Minimize = Color3.fromRGB(110, 130, 255),
		Good = Color3.fromRGB(0, 255, 140),
		Warn = Color3.fromRGB(255, 210, 0),
		Bad = Color3.fromRGB(255, 90, 90),
	},
	Fonts = {
		Title = Enum.Font.GothamSemibold,
		Body = Enum.Font.Gotham,
		BodySemibold = Enum.Font.GothamSemibold,
		BodyBold = Enum.Font.GothamBold,
	},
	Radius = {
		Window = UDim.new(0, 16),
		Container = UDim.new(0, 8),
		Button = UDim.new(1, 0),
	},
	Sizes = {
		TopBarHeight = IsOnMobile and 42 or 36,
		ActionButton = IsOnMobile and 30 or 28,
	}
}

NAstatsUI.createInstance = function(className, properties, parent)
	const inst = InstanceNew(className)
	for prop, value in properties do
		inst[prop] = value
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

function NAstatsUI.colorToHex(c)
	return Format("#%02X%02X%02X", math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255))
end

function NAstatsUI.ensureSingle(key, buildFn)
	const existing = windowRegistry[key]
	if existing and existing.screenGui and existing.screenGui.Parent then
		existing.bringToFront()
		return existing
	end

	const newUi = buildFn()
	windowRegistry[key] = newUi

	const originalCloseFunction = newUi.closeFunction
	MouseButtonFix(newUi.closeButton, function()
		if windowRegistry[key] == newUi then
			windowRegistry[key] = nil
		end
		if originalCloseFunction then
			originalCloseFunction()
		end
		newUi.screenGui:Destroy()
	end)
	return newUi
end

function NAstatsUI.createWindow(position, baseSize, titleText)
	windowCounter += 1
	const T = NAstatsUI.Theme

	const screenGui = NAstatsUI.createInstance("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100 + windowCounter,
	})
	NAgui.NaProtectUI(screenGui)

	const holder = NAstatsUI.createInstance("Frame", {
		Name = "Holder",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position or UDim2.new(0.5, 0, 0.3, 0),
		Size = baseSize,
		Parent = screenGui,
	})

	const window = NAstatsUI.createInstance("Frame", {
		Name = "Window",
		BackgroundColor3 = T.Colors.Primary,
		BackgroundTransparency = 0.46,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = holder
	})
	NAstatsUI.createInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, window)
	NAstatsUI.createInstance("UIStroke", {
		Color = T.Colors.Border,
		Thickness = 4,
		Transparency = 0.05,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, window)
	NAstatsUI.createInstance("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 11)),
			ColorSequenceKeypoint.new(1, T.Colors.Primary),
		}),
		Rotation = 90,
	}, window)

	const topBar = NAstatsUI.createInstance("Frame", {
		Name = "TopBar",
		BackgroundColor3 = T.Colors.Primary,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, T.Sizes.TopBarHeight),
		ZIndex = 2,
		Parent = window,
	})
	NAstatsUI.createInstance("UICorner", {
		CornerRadius = UDim.new(0, 6),
	}, topBar)

	NAstatsUI.createInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 9),
		PaddingRight = UDim.new(0, 7),
	}, topBar)

	const title = NAstatsUI.createInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, -(T.Sizes.ActionButton * 2 + 28), 1, 0),
		Font = T.Fonts.BodyBold,
		Text = titleText,
		TextColor3 = T.Colors.Text,
		TextSize = IsOnMobile and 20 or 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		ZIndex = 3,
		Parent = topBar,
	})

	const function createActionButton(name, text, color, order)
		const btn = NAstatsUI.createInstance("TextButton", {
			Name = name,
			BackgroundColor3 = color,
			BackgroundTransparency = 0.08,
			AutoButtonColor = true,
			Size = UDim2.fromOffset(T.Sizes.ActionButton, T.Sizes.ActionButton),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -(2 + (order - 1) * (T.Sizes.ActionButton + 6)), 0.5, 0),
			Font = T.Fonts.BodyBold,
			Text = text,
			TextScaled = false,
			TextSize = IsOnMobile and 20 or 17,
			TextColor3 = Color3.new(1, 1, 1),
			ZIndex = 3,
			RichText = true,
			Parent = topBar,
		})
		NAstatsUI.createInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)
		NAstatsUI.createInstance("UIStroke", {
			Color = T.Colors.Border,
			Thickness = 2,
			Transparency = 0.18,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}, btn)
		return btn
	end

	const minimizeButton = createActionButton("Minimize", "-", T.Colors.Minimize, 2)
	const closeButton = createActionButton("Close", "X", T.Colors.Close, 1)

	const content = NAstatsUI.createInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, T.Sizes.TopBarHeight),
		Size = UDim2.new(1, -16, 1, -(T.Sizes.TopBarHeight + 8)),
		ZIndex = 2,
		Parent = window
	})
	NAstatsUI.createInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 4),
	}, content)

	NAgui.draggerV2(holder, topBar)
	local collapsed = false
	local baseTitleText = titleText
	local collapsedTitleText = titleText
	local storedSize = baseSize

	MouseButtonFix(minimizeButton, function()
		collapsed = not collapsed
		content.Visible = not collapsed
		if collapsed then
			storedSize = holder.Size
			holder.Size = UDim2.fromOffset(holder.AbsoluteSize.X, T.Sizes.TopBarHeight + 6)
			title.Text = collapsedTitleText
		else
			holder.Size = storedSize
			title.Text = baseTitleText
		end
	end)

	return {
		screenGui = screenGui,
		holder = holder,
		window = window,
		title = title,
		content = content,
		closeButton = closeButton,
		minimizeButton = minimizeButton,
		setBaseTitle = function(t)
			baseTitleText = t
			if not collapsed then
				title.Text = t
			end
		end,
		setCollapsedTitle = function(t)
			collapsedTitleText = t
			if collapsed then
				title.Text = t
			end
		end,
		bringToFront = function()
			windowCounter += 1
			screenGui.DisplayOrder = 100 + windowCounter
		end,
	}
end

function NAstatsUI.createStatDisplay(parent, titleText, subtitleText)
	const T = NAstatsUI.Theme
	const container = NAstatsUI.createInstance("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = parent,
	})

	NAstatsUI.createInstance("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
		PaddingLeft = UDim.new(0, 4),
		PaddingRight = UDim.new(0, 4),
	}, container)

	const titleHeight = IsOnMobile and 16 or 14
	const valueHeight = IsOnMobile and 26 or 24

	const titleLabel = NAstatsUI.createInstance("TextLabel", {
		Name = "TitleLabel",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, titleHeight),
		Font = T.Fonts.BodySemibold,
		Text = titleText,
		TextSize = IsOnMobile and 13 or 12,
		TextColor3 = T.Colors.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Parent = container,
	})

	const valueLabel = NAstatsUI.createInstance("TextLabel", {
		Name = "ValueLabel",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, titleHeight + 2),
		Size = UDim2.new(1, 0, 0, valueHeight),
		Font = T.Fonts.BodyBold,
		Text = "—",
		TextSize = IsOnMobile and 23 or 21,
		TextColor3 = T.Colors.TextSubtle,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Parent = container,
	})

	const subtitleLabel = NAstatsUI.createInstance("TextLabel", {
		Name = "SubtitleLabel",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, titleHeight + valueHeight + 4),
		Size = UDim2.new(1, 0, 0, IsOnMobile and 16 or 14),
		Font = T.Fonts.Body,
		Text = subtitleText,
		TextSize = IsOnMobile and 12 or 12,
		TextColor3 = T.Colors.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Parent = container,
	})

	return { value = valueLabel, subtitle = subtitleLabel, title = titleLabel }
end

function NAstatsUI.createStatCommand(config)
	return NAstatsUI.ensureSingle(config.key, function()
		const baseHeight = IsOnMobile and 112 or 98
		const baseWidth = IsOnMobile and 270 or 220
		const ui = NAstatsUI.createWindow(config.position, UDim2.new(0, baseWidth, 0, baseHeight), config.title)
		const statDisplay = NAstatsUI.createStatDisplay(ui.content, config.title, config.subtitle)
		local lastUpdate = 0
		const updateInterval = 0.5

		NAlib.reconnect("UI:"..config.key, Services.RunService.RenderStepped:Connect(function(dt)
			const now = os.clock()
			if now - lastUpdate < updateInterval then
				return
			end

			local value, rawValue = config.updateFn(dt)
			const color = config.colorFn(rawValue)

			statDisplay.value.Text = "<b>"..value.."</b>"
			statDisplay.value.TextColor3 = color

			const collapsedText = Format("<b>%s:</b> <font color='%s'>%s</font>", config.title, NAstatsUI.colorToHex(color), value)
			ui.setBaseTitle(collapsedText)
			ui.setCollapsedTitle(collapsedText)

			lastUpdate = now
		end))
		ui.closeFunction = function()
			NAlib.disconnect("UI:"..config.key)
		end

		return ui
	end)
end

function NAstatsUI.createStatBox(parent, titleText)
	const T = NAstatsUI.Theme
	const boxHeight = IsOnMobile and 76 or 68
	const boxWidthScale = IsOnMobile and 1 or 0.5
	const boxWidthOffset = IsOnMobile and 0 or -6

	const box = NAstatsUI.createInstance("Frame", {
		BackgroundColor3 = T.Colors.Secondary,
		BackgroundTransparency = 0.48,
		Size = UDim2.new(boxWidthScale, boxWidthOffset, 0, boxHeight),
		Parent = parent,
	})
	NAstatsUI.createInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, box)
	NAstatsUI.createInstance("UIStroke", {
		Color = T.Colors.Border,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}, box)

	NAstatsUI.createInstance("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
	}, box)

	const titleHeight = IsOnMobile and 18 or 16
	const valueHeight = IsOnMobile and 22 or 20

	const title = NAstatsUI.createInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, titleHeight),
		Font = T.Fonts.BodySemibold,
		Text = titleText,
		TextSize = IsOnMobile and 14 or 13,
		TextColor3 = T.Colors.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Parent = box,
	})

	const valueLabel = NAstatsUI.createInstance("TextLabel", {
		Name = "Value",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, titleHeight + 2),
		Size = UDim2.new(1, 0, 0, valueHeight),
		Font = T.Fonts.BodyBold,
		Text = "—",
		TextSize = IsOnMobile and 18 or 16,
		TextColor3 = T.Colors.TextSubtle,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Parent = box,
	})

	const barBg = NAstatsUI.createInstance("Frame", {
		Name = "BarBg",
		BackgroundColor3 = Color3.fromRGB(18, 20, 30),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 3),
		Parent = box,
	})
	NAstatsUI.createInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, barBg)

	const bar = NAstatsUI.createInstance("Frame", {
		Name = "Bar",
		BackgroundColor3 = T.Colors.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = barBg,
	})
	NAstatsUI.createInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, bar)

	return box, valueLabel, bar
end

NAmanage._fpsTracker = NAmanage._fpsTracker or nil
NAmanage._hbTracker = NAmanage._hbTracker or nil
NAmanage._statCache = NAmanage._statCache or {}
NAmanage._statScan = NAmanage._statScan or {}

NAmanage._makeFpsTracker = NAmanage._makeFpsTracker or function(key, signal)
	const tr = {
		times = {},
		head = 1,
		tail = 0,
		value = 0,
		conn = nil,
	}
	tr.conn = NAlib.reconnect(key, signal:Connect(function()
		const now = os.clock()
		tr.tail += 1
		tr.times[tr.tail] = now
		const cut = now - 1
		while tr.head <= tr.tail and tr.times[tr.head] < cut do
			tr.times[tr.head] = nil
			tr.head += 1
		end
		const cnt = tr.tail - tr.head + 1
		if cnt <= 1 then
			tr.value = cnt
		else
			const first = tr.times[tr.head]
			const span = now - (tonumber(first) or now)
			if span > 0 then
				tr.value = (cnt - 1) / span
			else
				tr.value = cnt
			end
		end
		if tr.head > 2048 then
			const compact = {}
			local n = 0
			for i = tr.head, tr.tail do
				n += 1
				compact[n] = tr.times[i]
			end
			tr.times = compact
			tr.head = 1
			tr.tail = n
		end
	end))
	return tr
end

NAmanage.getRealFPS = NAmanage.getRealFPS or function()
	local tr = NAmanage._fpsTracker
	if not tr then
		tr = NAmanage._makeFpsTracker("UI:FPS_TRACKER", Services.RunService.RenderStepped)
		NAmanage._fpsTracker = tr
	end
	return math.max(0, math.floor((tonumber(tr.value) or 0) + 0.5))
end

NAmanage.getHeartbeatFPS = NAmanage.getHeartbeatFPS or function()
	local tr = NAmanage._hbTracker
	if not tr then
		tr = NAmanage._makeFpsTracker("UI:HB_FPS_TRACKER", Services.RunService.Heartbeat)
		NAmanage._hbTracker = tr
	end
	return math.max(0, math.floor((tonumber(tr.value) or 0) + 0.5))
end

NAmanage._statNorm = NAmanage._statNorm or function(v)
	return tostring(v or ""):lower():gsub("[%s_%-/]+", "")
end

NAmanage.getStatsItem = NAmanage.getStatsItem or function(names)
	if not Services.Stats then
		return nil
	end
	if type(names) == "string" then
		names = { names }
	end
	if type(names) ~= "table" then
		return nil
	end
	const key = Concat(names, "|")
	const cache = NAmanage._statCache
	const old = cache[key]
	if old and old.Parent then
		return old
	end
	const now = os.clock()
	const scan = NAmanage._statScan
	if scan[key] and now - scan[key] < 3 then
		return nil
	end
	scan[key] = now
	const want = {}
	for _, n in names do
		want[NAmanage._statNorm(n)] = true
	end
	const roots = { Services.Stats }
	const net = Services.Stats:FindFirstChild("Network")
	if net then
		roots[#roots + 1] = net
		const srv = net:FindFirstChild("ServerStatsItem")
		if srv then
			roots[#roots + 1] = srv
		end
	end
	for _, root in roots do
		if root and root.Parent and want[NAmanage._statNorm(root.Name)] then
			cache[key] = root
			return root
		end
		local found = nil
		NAmanage.ForEachDescendantYield(root, function(obj)
			if obj and want[NAmanage._statNorm(obj.Name)] then
				found = obj
				return true
			end
		end, {
			maxItems = 500,
			stopOnResult = true,
			yieldEvery = 120,
			delayTime = 0,
		})
		if found then
			cache[key] = found
			return found
		end
	end
	return nil
end

NAmanage.getStatsNumber = NAmanage.getStatsNumber or function(names)
	const item = NAmanage.getStatsItem(names)
	if not item then
		return nil
	end
	local ok, val = pcall(function()
		if item.GetValue then
			return item:GetValue()
		end
		return nil
	end)
	if ok and type(val) == "number" then
		return val
	end
	ok, val = pcall(function()
		if item.GetValueString then
			return item:GetValueString()
		end
		return nil
	end)
	if ok and type(val) == "string" then
		const num = tonumber((val:gsub("[^%d%.%-]", "")))
		if num then
			return num
		end
	end
	return nil
end

NAmanage.getStatsText = NAmanage.getStatsText or function(names, suf, digs)
	const val = NAmanage.getStatsNumber(names)
	if not val then
		return "—", nil
	end
	digs = tonumber(digs) or 0
	const fmt = digs > 0 and ("%."..tostring(digs).."f") or "%.0f"
	local txt = Format(fmt, val)
	if suf and suf ~= "" then
		txt = txt.." "..suf
	end
	return txt, val
end

NAmanage.getMemoryMb = NAmanage.getMemoryMb or function()
	local ok, val = pcall(function()
		return Services.Stats and Services.Stats:GetTotalMemoryUsageMb() or nil
	end)
	if ok and type(val) == "number" then
		return val
	end
	return nil
end

NAmanage.getRealPhysicsFPS = NAmanage.getRealPhysicsFPS or function()
	local ok, val = pcall(function()
		return Services.Workspace:GetRealPhysicsFPS()
	end)
	if ok and type(val) == "number" then
		return val
	end
	return nil
end

NAmanage.countInstances = NAmanage.countInstances or function()
	local state = NAmanage._instanceCountState
	if type(state) ~= "table" then
		state = {
			count = nil,
			scanning = false,
			lastScan = 0,
		}
		NAmanage._instanceCountState = state
	end
	const now = os.clock()
	if not state.scanning and (not state.count or now - (tonumber(state.lastScan) or 0) > 10) then
		state.scanning = true
		Spawn(function()
			local scanned = 0
			NAmanage.ForEachDescendantYield(game, function()
				scanned += 1
			end, {
				yieldEvery = 800,
				delayTime = 0.02,
			})
			state.count = math.max(0, scanned)
			state.lastScan = os.clock()
			state.scanning = false
		end)
	end
	return state.count
end

cmd.add({ "ping" }, { "ping", "Shows your network latency" }, function()
	const T = NAstatsUI.Theme
	NAstatsUI.createStatCommand({
		key = "Ping",
		title = "Ping",
		subtitle = "Network latency",
		position = UDim2.new(0.5, 0, 0.22, 0),
		updateFn = function()
			const rawPing = tonumber(NAmanage.GetDataPingMs and NAmanage.GetDataPingMs()) or 0
			return tostring(rawPing).." ms", rawPing
		end,
		colorFn = function(ping)
			if ping <= 50 then
				return T.Colors.Good
			end
			if ping <= 100 then
				return T.Colors.Warn
			end
			return T.Colors.Bad
		end,
	})
end)

cmd.add({ "fps" }, { "fps", "Shows your frames per second" }, function()
	const T = NAstatsUI.Theme

	NAstatsUI.createStatCommand({
		key = "FPS",
		title = "FPS",
		subtitle = "Frames per second",
		position = UDim2.new(0.5, 0, 0.36, 0),
		updateFn = function()
			const fps = NAmanage.getRealFPS()
			return tostring(fps), fps
		end,
		colorFn = function(fps)
			if fps >= 55 then
				return T.Colors.Good
			end
			if fps >= 30 then
				return T.Colors.Warn
			end
			return T.Colors.Bad
		end,
	})
end)

cmd.add({ "fpsping", "pingfps", "fpsp", "pfps" }, { "fpsping (pingfps)", "Shows the legacy FPS and ping panel" }, function()
	const existing = windowRegistry["FPSPing"]
	if existing and existing.screenGui and existing.screenGui.Parent then
		NAlib.disconnect("UI:FPSPing")
		existing.screenGui:Destroy()
		windowRegistry["FPSPing"] = nil
	end

	const T = NAstatsUI.Theme
	const height = IsOnMobile and 86 or 74
	const width = IsOnMobile and 310 or 330
	const ui = NAstatsUI.createWindow(UDim2.new(0.5, 0, 0.32, 0), UDim2.new(0, width, 0, height), "FPS / Ping")

	windowRegistry["FPSPing"] = ui

	const detail = NAstatsUI.createInstance("TextLabel", {
		Name = "Detail",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = T.Fonts.BodyBold,
		Text = "",
		TextColor3 = T.Colors.TextMuted,
		TextSize = IsOnMobile and 13 or 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextTruncate = Enum.TextTruncate.AtEnd,
		RichText = true,
		Parent = ui.content
	})

	local lastUpdate = 0
	const updateInterval = 0.5

	const pingColorFn = function(p)
		if p <= 50 then
			return T.Colors.Good
		end
		if p <= 100 then
			return T.Colors.Warn
		end
		return T.Colors.Bad
	end

	const fpsColorFn = function(f)
		if f >= 55 then
			return T.Colors.Good
		end
		if f >= 30 then
			return T.Colors.Warn
		end
		return T.Colors.Bad
	end

	NAlib.reconnect("UI:FPSPing", Services.RunService.RenderStepped:Connect(function()
		const t = os.clock()
		if t - lastUpdate < updateInterval then
			return
		end

		const fps = NAmanage.getRealFPS()
		const p = tonumber(NAmanage.GetDataPingMs and NAmanage.GetDataPingMs()) or 0

		const titleText = Format(
			"<b>Ping:</b> <font color='%s'>%d ms</font> | <b>FPS:</b> <font color='%s'>%d</font>",
			NAstatsUI.colorToHex(pingColorFn(p)),
			p,
			NAstatsUI.colorToHex(fpsColorFn(fps)),
			fps
		)
		ui.setBaseTitle(titleText)
		ui.setCollapsedTitle(titleText)
		detail.Text = Format("latency %s  |  render %s fps", p <= 100 and "stable" or "high", fps >= 55 and "smooth" or "low")
		lastUpdate = t
	end))

	MouseButtonFix(ui.closeButton, function()
		NAlib.disconnect("UI:FPSPing")
		if windowRegistry["FPSPing"] == ui then
			windowRegistry["FPSPing"] = nil
		end
		ui.screenGui:Destroy()
	end)
end)

cmd.add({ "stats", "devstats", "loadstats" }, { "stats (devstats, loadstats)", "Shows FPS, physics, network and memory stats" }, function()
	const existing = windowRegistry["Stats"]
	if existing and existing.screenGui and existing.screenGui.Parent then
		NAlib.disconnect("UI:Stats")
		existing.screenGui:Destroy()
		windowRegistry["Stats"] = nil
	end

	const T = NAstatsUI.Theme
	const height = IsOnMobile and 430 or 410
	const width = IsOnMobile and 330 or 430
	const ui = NAstatsUI.createWindow(UDim2.new(0.5, 0, 0.38, 0), UDim2.new(0, width, 0, height), "Stats")
	windowRegistry["Stats"] = ui

	const scroll = NAstatsUI.createInstance("ScrollingFrame", {
		Name = "StatsScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = IsOnMobile and 4 or 5,
		Parent = ui.content,
	})

	const grid = NAstatsUI.createInstance("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -(IsOnMobile and 4 or 6), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = scroll,
	})

	NAstatsUI.createInstance("UIGridLayout", {
		CellSize = IsOnMobile and UDim2.new(1, 0, 0, 62) or UDim2.new(0.5, -6, 0, 62),
		CellPadding = UDim2.new(0, 8, 0, 8),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})

	const function pingColor(p)
		if p <= 50 then return T.Colors.Good end
		if p <= 100 then return T.Colors.Warn end
		return T.Colors.Bad
	end

	const function fpsColor(f)
		if f >= 55 then return T.Colors.Good end
		if f >= 30 then return T.Colors.Warn end
		return T.Colors.Bad
	end

	const function neutralColor()
		return T.Colors.Accent
	end

	local instCount = nil
	local instTime = 0
	const statList = {
		{ t = "FPS", fn = function() const v = NAmanage.getHeartbeatFPS() return tostring(v), v end, col = fpsColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 120, 0, 1) end },
		{ t = "Render FPS", fn = function() const v = NAmanage.getRealFPS() return tostring(v), v end, col = fpsColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 120, 0, 1) end },
		{ t = "Physics FPS", fn = function() const v = NAmanage.getRealPhysicsFPS() return v and tostring(math.floor(v + 0.5)) or "—", v end, col = fpsColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 240, 0, 1) end },
		{ t = "Ping", fn = function() const v = tonumber(NAmanage.GetDataPingMs and NAmanage.GetDataPingMs()) or 0 return tostring(v).." ms", v end, col = pingColor, ratio = function(v) return math.clamp(1 - ((tonumber(v) or 0) / 300), 0, 1) end },
		{ t = "Receive", fn = function() return NAmanage.getStatsText({"Data Receive Kbps", "DataReceiveKbps", "Receive Kbps"}, "Kbps", 1) end, col = neutralColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 512, 0, 1) end },
		{ t = "Send", fn = function() return NAmanage.getStatsText({"Data Send Kbps", "DataSendKbps", "Send Kbps"}, "Kbps", 1) end, col = neutralColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 256, 0, 1) end },
		{ t = "Memory", fn = function() const v = NAmanage.getMemoryMb() return v and Format("%.1f MB", v) or "—", v end, col = neutralColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 2500, 0, 1) end },
		{ t = "Instances", fn = function() const now = os.clock() if not instCount or now - instTime > 2 then instCount = NAmanage.countInstances() instTime = now end return instCount and tostring(instCount) or "—", instCount end, col = neutralColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 100000, 0, 1) end },
		{ t = "Speed", fn = function() const c = getChar() const r = c and getRoot(c) const v = r and (r.AssemblyLinearVelocity or r.Velocity) const sp = v and Vector3.new(v.X, 0, v.Z).Magnitude or 0 return Format("%.1f", sp), sp end, col = neutralColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 120, 0, 1) end },
		{ t = "Velocity", fn = function() const c = getChar() const r = c and getRoot(c) const v = r and (r.AssemblyLinearVelocity or r.Velocity) const mag = v and v.Magnitude or 0 return Format("%.1f", mag), mag end, col = neutralColor, ratio = function(v) return math.clamp((tonumber(v) or 0) / 200, 0, 1) end },
		{ t = "Humanoid", fn = function() const h = getHum() const st = h and h:GetState() return st and tostring(st.Name) or "—", 1 end, col = neutralColor, ratio = function() return 1 end },
	}

	const cells = {}
	for i, data in statList do
		local box, val, bar = NAstatsUI.createStatBox(grid, data.t)
		box.LayoutOrder = i
		cells[i] = { data = data, val = val, bar = bar }
	end

	local lastUpdate = 0
	const updateInterval = 0.5

	NAlib.reconnect("UI:Stats", Services.RunService.RenderStepped:Connect(function()
		const now = os.clock()
		if now - lastUpdate < updateInterval then
			return
		end
		lastUpdate = now
		const mem = NAmanage.getMemoryMb()
		const ping = tonumber(NAmanage.GetDataPingMs and NAmanage.GetDataPingMs()) or 0
		const char = getChar()
		const root = char and getRoot(char)
		const velocity = root and (NAlib.isProperty(root, "AssemblyLinearVelocity") or root.Velocity)
		const velocityMag = typeof(velocity) == "Vector3" and velocity.Magnitude or 0
		const memTxt = mem and Format("%.0f MB", mem) or "— MB"
		const velocityTxt = Format("%.1f", velocityMag)
		for _, cell in cells do
			const data = cell.data
			local text, raw = data.fn()
			const color = data.col(raw or 0)
			cell.val.Text = "<b>"..tostring(text or "—").."</b>"
			cell.val.TextColor3 = color
			cell.bar.Size = UDim2.new(data.ratio(raw or 0), 0, 1, 0)
			cell.bar.BackgroundColor3 = color
		end
		ui.setCollapsedTitle(Format("Stats: <font color='%s'>%s</font> | <font color='%s'>%d ms</font> | <font color='%s'>%s vel</font>", NAstatsUI.colorToHex(neutralColor()), memTxt, NAstatsUI.colorToHex(pingColor(ping)), ping, NAstatsUI.colorToHex(neutralColor()), velocityTxt))
	end))

	MouseButtonFix(ui.closeButton, function()
		NAlib.disconnect("UI:Stats")
		if windowRegistry["Stats"] == ui then
			windowRegistry["Stats"] = nil
		end
		ui.screenGui:Destroy()
	end)
end)

NAmanage.CloseSpeedometerUI = NAmanage.CloseSpeedometerUI or function()
	const existing = windowRegistry["Speedometer"]
	NAlib.disconnect("UI:Speedometer")
	if existing and existing.screenGui then
		existing.screenGui:Destroy()
	end
	windowRegistry["Speedometer"] = nil
end

cmd.add({"speedometer", "sps", "speedo"}, {"speedometer (sps,speedo)", "Toggles a NA-themed speedometer"}, function()
	const existing = windowRegistry["Speedometer"]
	if existing and existing.screenGui and existing.screenGui.Parent then
		NAmanage.CloseSpeedometerUI()
		return
	end

	const T = NAstatsUI.Theme
	const ui = NAstatsUI.createWindow(UDim2.new(0.5, 0, 0.82, 0), UDim2.new(0, IsOnMobile and 230 or 210, 0, IsOnMobile and 120 or 110), "Speedometer")
	windowRegistry["Speedometer"] = ui

	const statDisplay = NAstatsUI.createStatDisplay(ui.content, "Speed", "Studs / sec")
	local lastUpdate = 0
	const updateInterval = 0.08

	const function speedColor(speed)
		if speed >= 100 then
			return T.Colors.Bad
		end
		if speed >= 50 then
			return T.Colors.Warn
		end
		return T.Colors.Accent
	end

	NAlib.reconnect("UI:Speedometer", Services.RunService.RenderStepped:Connect(function()
		const now = os.clock()
		if now - lastUpdate < updateInterval then
			return
		end
		lastUpdate = now

		const char = getChar()
		const root = char and getRoot(char)
		const velocity = root and (root.AssemblyLinearVelocity or root.Velocity)
		const speed = velocity and Vector3.new(velocity.X, 0, velocity.Z).Magnitude or 0
		const text = Format("%.2f", speed)
		const color = speedColor(speed)

		statDisplay.value.Text = "<b>"..text.."</b>"
		statDisplay.value.TextColor3 = color
		ui.setCollapsedTitle(Format("Speed: <font color='%s'>%s</font>", NAstatsUI.colorToHex(color), text))
	end))

	MouseButtonFix(ui.closeButton, function()
		NAmanage.CloseSpeedometerUI()
	end)
end)

cmd.add({"closespeedometer", "stopspeedometer", "nosps", "unspeedo"}, {"closespeedometer (nosps,unspeedo)", "Closes the speedometer"}, function()
	NAmanage.CloseSpeedometerUI()
end)

cmd.add({"commands","cmds"},{"commands","Open the command list"},function()
	NAgui.commands()
end)

cmd.add({"settings"},{"settings","Open the settings menu"},function()
	NAgui.settingss()
end)

cmd.add({"commandkeybinds", "cmdkeybinds", "ckeybinds"}, {"commandkeybinds (cmdkeybinds, ckeybinds)", "Open the command keybinds window"}, function()
	NAgui.commandkeybinds()
end)

NAStuff.NAClientPreviewRig = NAStuff.NAClientPreviewRig or nil

NAmanage.NAClientResolveUserId = function(value)
	const text = tostring(value or "")
	if text == "" or Lower(text) == "me" or Lower(text) == "local" then
		return LocalPlayer and LocalPlayer.UserId or nil, LocalPlayer and LocalPlayer.Name or "LocalPlayer"
	end
	const num = tonumber(text)
	if num then
		return math.floor(num), tostring(math.floor(num))
	end
	const targets = getPlr(text)
	const plr = type(targets) == "table" and targets[1] or nil
	if plr then
		return plr.UserId, plr.Name
	end
	local ok, uid = pcall(function()
		return Services.Players:GetUserIdFromNameAsync(text)
	end)
	if ok and uid then
		return uid, text
	end
	if type(NAmanage._resolveHumanoidUserId) == "function" then
		uid = NAmanage._resolveHumanoidUserId(text)
		if uid then
			return uid, text
		end
	end
	return nil, text
end

NAmanage.NAClientGetDescription = function(kind, value)
	kind = Lower(tostring(kind or "user"))
	if kind == "outfit" or kind == "fit" or kind == "o" then
		const id = tonumber(value)
		if not id then
			return nil, "Missing outfit id"
		end
		local ok, desc = pcall(function()
			return Services.Players:GetHumanoidDescriptionFromOutfitIdAsync(math.floor(id))
		end)
		if ok and desc then
			return desc, "Outfit "..math.floor(id)
		end
		return nil, tostring(desc)
	end
	local uid, label = NAmanage.NAClientResolveUserId(value)
	if not uid then
		return nil, "Unable to resolve user"
	end
	if type(NAmanage._resolveHumanoidDescription) == "function" then
		local desc, resolvedUserId = NAmanage._resolveHumanoidDescription(tostring(uid))
		if desc then
			return desc, label or tostring(resolvedUserId or uid)
		end
	end
	local ok, desc = pcall(function()
		return Services.Players:GetHumanoidDescriptionFromUserIdAsync(uid)
	end)
	if ok and desc then
		return desc, label or tostring(uid)
	end
	return nil, tostring(desc)
end

NAmanage.NAClientCreateRigFromDescription = function(desc)
	if not desc then
		return nil, "Missing description"
	end
	local ok, rig = pcall(function()
		if type(Services.Players.CreateHumanoidModelFromDescriptionAsync) == "function" then
			return Services.Players:CreateHumanoidModelFromDescriptionAsync(desc, Enum.HumanoidRigType.R15)
		end
		return Services.Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
	end)
	if ok and rig then
		return rig
	end
	return nil, rig
end

NAmanage.NAClientClearPreview = NAmanage.NAClientClearPreview or function()
	const rig = NAStuff.NAClientPreviewRig
	NAStuff.NAClientPreviewRig = nil
	if typeof(rig) == "Instance" then
		pcall(function()
			rig:Destroy()
		end)
	end
end

NAmanage.NAClientPlacePreview = NAmanage.NAClientPlacePreview or function(rig)
	if typeof(rig) ~= "Instance" then
		return false
	end
	NAmanage.NAClientClearPreview()
	rig.Name = "\0"
	local cf = CFrame.new(0, 5, 0)
	const char = getChar()
	const root = char and getRoot(char)
	if root then
		cf = root.CFrame * CFrame.new(0, 0, -7)
	elseif Services.Workspace.CurrentCamera then
		cf = Services.Workspace.CurrentCamera.CFrame * CFrame.new(0, 0, -10)
	end
	rig:PivotTo(cf)
	rig.Parent = Services.Workspace
	NAStuff.NAClientPreviewRig = rig
	return true
end

NAStuff.NAClientCharState = type(NAStuff.NAClientCharState) == "table" and NAStuff.NAClientCharState or {}

NAmanage.NAClientCharBodyParts = {
	"Head";
	"UpperTorso";
	"LowerTorso";
	"LeftUpperArm";
	"LeftLowerArm";
	"LeftHand";
	"RightUpperArm";
	"RightLowerArm";
	"RightHand";
	"LeftUpperLeg";
	"LeftLowerLeg";
	"LeftFoot";
	"RightUpperLeg";
	"RightLowerLeg";
	"RightFoot";
}

NAmanage.NAClientCharScaleMap = {
	BodyDepthScale = "DepthScale";
	BodyHeightScale = "HeightScale";
	BodyProportionScale = "ProportionScale";
	BodyTypeScale = "BodyTypeScale";
	BodyWidthScale = "WidthScale";
	HeadScale = "HeadScale";
}

NAmanage.NAClientCharacterTarget = function()
	const char = getChar() or (LocalPlayer and LocalPlayer.Character)
	if not char then
		return nil, nil, "Character unavailable"
	end
	const hum = getPlrHum(char) or char:FindFirstChildOfClass("Humanoid")
	if not hum then
		return char, nil, "Humanoid unavailable"
	end
	return char, hum
end

NAmanage.NAClientCharacterSnapshotCurrentAnimations = function(char)
	const animate = char and char:FindFirstChild("Animate")
	if not animate then
		return nil
	end
	const snapshot = {}
	for _, obj in animate:GetDescendants() do
		if obj:IsA("Animation") then
			const parts = {}
			local node = obj
			while node and node ~= animate do
				table.insert(parts, 1, node.Name)
				node = node.Parent
			end
			snapshot[Concat(parts, "/")] = obj.AnimationId
		end
	end
	return snapshot
end

NAmanage.NAClientCharacterRestoreCurrentAnimations = function(char, snapshot)
	const animate = char and char:FindFirstChild("Animate")
	if not animate or type(snapshot) ~= "table" then
		return
	end
	for path, id in snapshot do
		local node = animate
		for name in tostring(path):gmatch("[^/]+") do
			node = node and node:FindFirstChild(name)
		end
		if node and node:IsA("Animation") and node.AnimationId ~= id then
			pcall(function()
				node.AnimationId = id
			end)
		end
	end
end

NAmanage.NAClientCharacterPreserveCurrentAnimations = function(char, snapshot)
	if type(snapshot) ~= "table" then
		return
	end
	NAmanage.NAClientCharacterRestoreCurrentAnimations(char, snapshot)
	const delayFn = type(NAmanage._rawTaskDelay) == "function" and NAmanage._rawTaskDelay or task.delay
	for _, delayTime in {0.15, 0.75} do
		delayFn(delayTime, function()
			if char and char.Parent then
				NAmanage.NAClientCharacterRestoreCurrentAnimations(char, snapshot)
			end
		end)
	end
end

NAmanage.NAClientCharacterClearState = function()
	const state = NAStuff.NAClientCharState
	if typeof(state.originalDescription) == "Instance" then
		pcall(function()
			state.originalDescription:Destroy()
		end)
	end
	state.character = nil
	state.originalDescription = nil
	state.active = false
end

NAmanage.NAClientCharacterCaptureOriginal = function(char, hum)
	const state = NAStuff.NAClientCharState
	if state.active == true and state.character == char and typeof(state.originalDescription) == "Instance" then
		return true
	end
	NAmanage.NAClientCharacterClearState()
	local ok, desc = pcall(function()
		return hum:GetAppliedDescription()
	end)
	if not ok or not desc then
		desc = select(1, NAmanage.NAClientGetDescription("user", "me"))
	end
	if not desc then
		return false, "Unable to save current appearance"
	end
	state.character = char
	state.originalDescription = desc
	state.active = true
	return true
end

NAmanage.NAClientCreateCharRig = function(desc, rigType)
	if not desc then
		return nil, "Missing description"
	end
	rigType = rigType == Enum.HumanoidRigType.R6 and Enum.HumanoidRigType.R6 or Enum.HumanoidRigType.R15
	local ok, rig = pcall(function()
		if type(Services.Players.CreateHumanoidModelFromDescriptionAsync) == "function" then
			return Services.Players:CreateHumanoidModelFromDescriptionAsync(desc, rigType)
		end
		return Services.Players:CreateHumanoidModelFromDescription(desc, rigType)
	end)
	if ok and rig then
		return rig
	end
	return nil, rig
end

NAmanage.NAClientCharacterSetScales = function(hum, desc)
	if not hum or not desc or hum.RigType ~= Enum.HumanoidRigType.R15 then
		return
	end
	for valueName, propertyName in NAmanage.NAClientCharScaleMap do
		const scale = hum:FindFirstChild(valueName)
		local value
		pcall(function()
			value = tonumber(desc[propertyName])
		end)
		if scale and scale:IsA("NumberValue") and value ~= nil then
			pcall(function()
				scale.Value = value
			end)
		end
	end
end

NAmanage.NAClientCharClearVisualChildren = function(part)
	for _, child in part:GetChildren() do
		if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") or child:IsA("FaceControls") then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end

NAmanage.NAClientCharCopyVisualChildren = function(sourcePart, targetPart)
	if not sourcePart or not targetPart then
		return
	end
	NAmanage.NAClientCharClearVisualChildren(targetPart)
	for _, child in sourcePart:GetChildren() do
		if child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance") or child:IsA("FaceControls") then
			pcall(function()
				child:Clone().Parent = targetPart
			end)
		end
	end
end

NAmanage.NAClientCharacterApplyBody = function(source, char, hum)
	if hum.RigType == Enum.HumanoidRigType.R15 then
		for _, name in NAmanage.NAClientCharBodyParts do
			const sourcePart = source:FindFirstChild(name)
			const targetPart = char:FindFirstChild(name)
			if sourcePart and targetPart and sourcePart:IsA("BasePart") and targetPart:IsA("BasePart") then
				if sourcePart:IsA("MeshPart") and targetPart:IsA("MeshPart") then
					pcall(function()
						targetPart:ApplyMesh(sourcePart)
					end)
				end
				pcall(function()
					targetPart.Color = sourcePart.Color
					targetPart.Material = sourcePart.Material
					targetPart.MaterialVariant = sourcePart.MaterialVariant
					targetPart.Reflectance = sourcePart.Reflectance
				end)
				NAmanage.NAClientCharCopyVisualChildren(sourcePart, targetPart)
			end
		end
	else
		for _, name in {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"} do
			const sourcePart = source:FindFirstChild(name)
			const targetPart = char:FindFirstChild(name)
			if sourcePart and targetPart and sourcePart:IsA("BasePart") and targetPart:IsA("BasePart") then
				pcall(function()
					targetPart.Color = sourcePart.Color
				end)
				if sourcePart:IsA("MeshPart") and targetPart:IsA("MeshPart") then
					pcall(function()
						targetPart:ApplyMesh(sourcePart)
					end)
				end
				NAmanage.NAClientCharCopyVisualChildren(sourcePart, targetPart)
			end
		end
	end
end

NAmanage.NAClientCharIsAppearanceObject = function(inst)
	return inst:IsA("Accessory")
		or inst:IsA("Clothing")
		or inst:IsA("ShirtGraphic")
		or inst:IsA("BodyColors")
		or inst:IsA("CharacterMesh")
end

NAmanage.NAClientCharacterAttachAccessory = function(sourceAccessory, char)
	local accessory
	local cloned = pcall(function()
		accessory = sourceAccessory:Clone()
	end)
	if not cloned or not accessory then
		return false
	end

	const sourceHandle = sourceAccessory:FindFirstChild("Handle")
	const sourceWeld = sourceHandle and sourceHandle:FindFirstChild("AccessoryWeld")
	const handle = accessory:FindFirstChild("Handle")
	local weld = handle and handle:FindFirstChild("AccessoryWeld")
	local targetPart

	if sourceWeld and sourceWeld.Part1 then
		targetPart = char:FindFirstChild(sourceWeld.Part1.Name)
	end

	if not targetPart and handle then
		const handleAttachment = handle:FindFirstChildOfClass("Attachment")
		if handleAttachment then
			const targetAttachment = char:FindFirstChild(handleAttachment.Name, true)
			if targetAttachment and targetAttachment:IsA("Attachment") and targetAttachment.Parent and targetAttachment.Parent:IsA("BasePart") then
				targetPart = targetAttachment.Parent
				if not weld then
					weld = InstanceNew("Weld")
					weld.Name = "AccessoryWeld"
					weld.C0 = handleAttachment.CFrame
					weld.C1 = targetAttachment.CFrame
					weld.Parent = handle
				end
			end
		end
	end

	if weld and handle and targetPart then
		pcall(function()
			weld.Part0 = handle
			weld.Part1 = targetPart
			handle.CFrame = targetPart.CFrame * weld.C1 * weld.C0:Inverse()
		end)
	end

	accessory.Parent = char
	return accessory.Parent == char
end

NAmanage.NAClientCharacterApplyAppearanceObjects = function(source, char)
	for _, child in char:GetChildren() do
		if NAmanage.NAClientCharIsAppearanceObject(child) then
			pcall(function()
				child:Destroy()
			end)
		end
	end

	for _, child in source:GetChildren() do
		if child:IsA("Accessory") then
			NAmanage.NAClientCharacterAttachAccessory(child, char)
		elseif NAmanage.NAClientCharIsAppearanceObject(child) then
			pcall(function()
				child:Clone().Parent = char
			end)
		end
	end
end

NAmanage.NAClientCharacterApplySource = function(source, char, hum, desc)
	if typeof(source) ~= "Instance" or not char or not hum or not desc then
		return false, "Appearance source unavailable"
	end

	local originalRequiresNeck
	pcall(function()
		originalRequiresNeck = hum.RequiresNeck
		hum.RequiresNeck = false
	end)

	NAmanage.NAClientCharacterSetScales(hum, desc)
	NAmanage.NAClientCharacterApplyBody(source, char, hum)
	NAmanage.NAClientCharacterApplyAppearanceObjects(source, char)

	if originalRequiresNeck ~= nil then
		pcall(function()
			hum.RequiresNeck = originalRequiresNeck
		end)
	end

	if hum.Health <= 0 then
		return false, "Character died while applying appearance"
	end
	return true
end

NAmanage.NAClientCharacterDestroyRigLater = function(rig)
	if typeof(rig) ~= "Instance" then
		return
	end
	const delayFn = type(NAmanage._rawTaskDelay) == "function" and NAmanage._rawTaskDelay or task.delay
	delayFn(1.25, function()
		pcall(function()
			rig:Destroy()
		end)
	end)
end

NAmanage.NAClientCharacterApplyDescription = function(desc)
	const char, hum, targetErr = NAmanage.NAClientCharacterTarget()
	if not hum then
		return false, targetErr
	end

	const currentAnimations = NAmanage.NAClientCharacterSnapshotCurrentAnimations(char)
	local captured, captureErr = NAmanage.NAClientCharacterCaptureOriginal(char, hum)
	if not captured then
		return false, captureErr
	end

	local rig, rigErr = NAmanage.NAClientCreateCharRig(desc, hum.RigType)
	if not rig then
		return false, rigErr
	end

	local ok, err = NAmanage.NAClientCharacterApplySource(rig, char, hum, desc)
	NAmanage.NAClientCharacterPreserveCurrentAnimations(char, currentAnimations)
	NAmanage.NAClientCharacterDestroyRigLater(rig)
	return ok, err
end

NAmanage.NAClientCharacterReset = function()
	const char, hum, targetErr = NAmanage.NAClientCharacterTarget()
	if not hum then
		return false, targetErr
	end

	const state = NAStuff.NAClientCharState
	if state.active ~= true or state.character ~= char or typeof(state.originalDescription) ~= "Instance" then
		NAmanage.NAClientCharacterClearState()
		return false, "No active char transformation"
	end

	const currentAnimations = NAmanage.NAClientCharacterSnapshotCurrentAnimations(char)
	local rig, rigErr = NAmanage.NAClientCreateCharRig(state.originalDescription, hum.RigType)
	if not rig then
		return false, rigErr
	end

	local ok, err = NAmanage.NAClientCharacterApplySource(rig, char, hum, state.originalDescription)
	NAmanage.NAClientCharacterPreserveCurrentAnimations(char, currentAnimations)
	NAmanage.NAClientCharacterDestroyRigLater(rig)
	NAmanage.NAClientCharacterClearState()
	return ok, err
end

cmd.add({"inspectoutfit", "outfitinspect"}, {"inspectoutfit <user/player/userid|outfit:id>", "Open a user's saved outfits and inspect a selected outfit"}, function(arg)
	if not arg or arg == "" then
		DoNotif("Usage: inspectoutfit <user/player/userid|outfit:id>", 3, "InspectOutfit")
		return
	end

	const raw = tostring(arg):gsub("^%s+", ""):gsub("%s+$", "")

	const function getDesc(id)
		id = tonumber(id)
		if not id or id <= 0 then
			return nil, "Invalid outfit id"
		end
		local ok, res = pcall(function()
			if type(Services.Players.GetHumanoidDescriptionFromOutfitIdAsync) == "function" then
				return Services.Players:GetHumanoidDescriptionFromOutfitIdAsync(math.floor(id))
			end
			return Services.Players:GetHumanoidDescriptionFromOutfitId(math.floor(id))
		end)
		if ok and res then
			return res, math.floor(id)
		end
		return nil, tostring(res)
	end

	const function inspectDesc(desc, label)
		if not desc then
			DoNotif("Missing description", 3, "InspectOutfit")
			return false
		end
		const gui = SafeGetService("GuiService")
		if not gui then
			DoNotif("GuiService unavailable", 3, "InspectOutfit")
			return false
		end
		local ok, res = pcall(function()
			gui:InspectPlayerFromHumanoidDescription(desc, tostring(label or "Outfit"))
			return true
		end)
		if ok then
			DebugNotif("Inspect outfit: "..tostring(label or "Outfit"))
			return true
		end
		DoNotif("Inspect outfit failed: "..tostring(res), 3, "InspectOutfit")
		return false
	end

	const function inspectId(id, name, quiet)
		local desc, err = getDesc(id)
		if not desc then
			if not quiet then
				DoNotif("Failed to fetch outfit: "..tostring(err), 3, "InspectOutfit")
			end
			return false
		end
		return inspectDesc(desc, name or ("Outfit #"..tostring(id)))
	end

	local id = nil
	if type(NAmanage._resolveExplicitOutfitId) == "function" then
		id = NAmanage._resolveExplicitOutfitId(raw)
	end
	if not id and raw:match("^%d+$") then
		id = tonumber(raw)
	end
	if id and inspectId(id, "Outfit #"..tostring(id), raw:match("^%d+$") ~= nil) then
		return
	end
	if id and not raw:match("^%d+$") then
		return
	end

	NAStuff = NAStuff or {}
	NAStuff._outfitCache = NAStuff._outfitCache or {}
	NAStuff._httpBackoff = NAStuff._httpBackoff or {}
	NAStuff._httpCooldown = NAStuff._httpCooldown or {}

	const uid = NAmanage.NAClientResolveUserId(raw)
	if not uid then
		DoNotif("Couldn't resolve user", 3, "InspectOutfit")
		return
	end

	const function curBtn()
		return {Text = Format("Current Avatar  (#%d)", uid), Callback = function()
			local desc = nil
			local userId = uid
			if type(NAmanage._resolveHumanoidDescription) == "function" then
				desc, userId = NAmanage._resolveHumanoidDescription(tostring(uid))
			else
				local ok, res = pcall(function()
					return Services.Players:GetHumanoidDescriptionFromUserIdAsync(uid)
				end)
				if ok then
					desc = res
				end
			end
			if not desc then
				DoNotif("Failed to fetch current avatar", 3, "InspectOutfit")
				return
			end
			inspectDesc(desc, Format("Current Avatar #%d", tonumber(userId) or uid))
		end}
	end

	const function makeBtn(o)
		return {Text = Format("%s  (#%d)", tostring(o.name or "Outfit"), tonumber(o.id) or 0), Callback = function()
			inspectId(o.id, tostring(o.name or ("Outfit #"..tostring(o.id))))
		end}
	end

	const function show(list, cache)
		NAmanage._openOutfitPagedWindow({
			titlePrefix = "InspectOutfit",
			arg = raw,
			uid = uid,
			outfits = list,
			cache = cache == true,
			currentAvatarButton = curBtn,
			makeOutfitButton = makeBtn,
		}, 1)
	end

	const cache = NAStuff._outfitCache[uid]
	if cache and (time() - cache.t) < 120 and cache.list and #cache.list > 0 then
		show(cache.list, true)
		return
	end

	local list, fail = NAmanage._fetchUserOutfits(uid)
	if type(list) ~= "table" or #list == 0 then
		if not fail then
			DoNotif("No user-created outfits for that user", 2, "InspectOutfit")
			return
		end
		const buttons = {curBtn()}
		if fail == "cooldown" then
			local retryAt = math.huge
			for _, stamp in NAStuff._httpCooldown or {} do
				if type(stamp) == "number" then
					retryAt = math.min(retryAt, stamp)
				end
			end
			const left = retryAt < math.huge and math.max(0, retryAt - time()) or 0
			if left > 0 then
				DoNotif(Format("Loading outfits… retrying in %.1fs", left), math.max(1.2, left), "InspectOutfit")
			end
		elseif fail == "429" or fail == "5xx" then
			local waitSec = 0
			for _, stamp in NAStuff._httpCooldown or {} do
				if type(stamp) == "number" then
					waitSec = math.max(waitSec, stamp - time())
				end
			end
			waitSec = math.max(waitSec, 1.5)
			DoNotif(Format("Loading outfits… retrying in %.1fs", waitSec), math.max(1.5, waitSec), "InspectOutfit")
			return
		elseif fail then
			DoNotif(tostring(fail), 3, "InspectOutfit")
		end
		Window({Title = Format("InspectOutfit • %s (%d)", raw, uid), Buttons = buttons})
		return
	end

	NAStuff._outfitCache[uid] = {t = time(), list = list}
	show(list, false)
end, true)

cmd.add({"avatarpreview", "apreview", "clientavatar"}, {"avatarpreview <me/player/userId/outfitId>", "Creates a client-only avatar preview rig"}, function(kind, value)
	const text = Lower(tostring(kind or "me"))
	local rig, label
	if text == "outfit" or text == "fit" or text == "o" then
		local desc
		desc, label = NAmanage.NAClientGetDescription("outfit", value)
		if not desc then
			DoNotif("Preview failed: "..tostring(label))
			return
		end
		local res
		rig, res = NAmanage.NAClientCreateRigFromDescription(desc)
		if not rig then
			DoNotif("Preview failed: "..tostring(res))
			return
		end
	else
		local desc
		desc, label = NAmanage.NAClientGetDescription("user", kind)
		if not desc then
			DoNotif("Preview failed: "..tostring(label))
			return
		end
		local res
		rig, res = NAmanage.NAClientCreateRigFromDescription(desc)
		if not rig then
			DoNotif("Preview failed: "..tostring(res))
			return
		end
	end
	if NAmanage.NAClientPlacePreview(rig) then
		DebugNotif("Client avatar preview: "..tostring(label))
	else
		DoNotif("Preview rig placement failed.")
	end
end, true)

cmd.add({"char"}, {"char <me/player/userId> | char outfit <outfitId>", "Transforms your client character to a user's avatar appearance"}, function(kind, value)
	const text = Lower(tostring(kind or ""))
	if text == "" then
		DoNotif("Usage: char <me/player/userId> | char outfit <outfitId>")
		return
	end

	local desc, label
	if text == "outfit" or text == "fit" or text == "o" then
		desc, label = NAmanage.NAClientGetDescription("outfit", value)
	else
		desc, label = NAmanage.NAClientGetDescription("user", kind)
	end

	if not desc then
		DoNotif("Char failed: "..tostring(label))
		return
	end

	local ok, err = NAmanage.NAClientCharacterApplyDescription(desc)
	if not ok then
		DoNotif("Char failed: "..tostring(err))
		return
	end

	DebugNotif("Character changed to "..tostring(label)..".")
end, true)

cmd.add({"unchar", "resetchar", "charreset"}, {"unchar (resetchar, charreset)", "Restores your appearance"}, function()
	local ok, err = NAmanage.NAClientCharacterReset()
	if ok then
		DebugNotif("Character appearance restored.")
	else
		DoNotif("Char reset failed: "..tostring(err))
	end
end)

cmd.add({"clearavatarpreview", "unavatarpreview", "capreview"}, {"clearavatarpreview", "Removes the client-only avatar preview rig"}, function()
	NAmanage.NAClientClearPreview()
	DebugNotif("Client avatar preview cleared.")
end)

cmd.add({"waypoints", "wp"},{"waypoints","Open the waypoints menu"},function()
	NAgui.waypointers()
end)

cmd.add({"binders", "binds"},{"binders","Open the event binder menu"},function()
	NAgui.eventbinders()
end)

NAmanage.waypointNameFromArgs=function(...)
	const args = {...}
	const parts = {}
	for i = 1, #args do
		const part = tostring(args[i] or "")
		if part ~= "" then
			Insert(parts, part)
		end
	end
	return (Concat(parts, " "):match("^%s*(.-)%s*$"))
end

NAmanage.WaypointTrim = NAmanage.WaypointTrim or function(text)
	return tostring(text or ""):match("^%s*(.-)%s*$") or ""
end

NAmanage.WaypointParseCoordinates = NAmanage.WaypointParseCoordinates or function(...)
	local raw = NAmanage.WaypointTrim(Concat({...}, " "))
	if raw == "" then
		return nil
	end
	raw = raw:gsub("Vector3%.new", " "):gsub("CFrame%.new", " ")
	raw = raw:gsub("[,%(%){%}%[%]]", " ")
	const nums = {}
	for numText in raw:gmatch("[-+]?%d*%.?%d+") do
		const num = tonumber(numText)
		if num then
			nums[#nums + 1] = num
			if #nums >= 3 then
				break
			end
		end
	end
	if #nums < 3 then
		return nil
	end
	return nums[1], nums[2], nums[3]
end

NAmanage.WaypointFormatNumber = NAmanage.WaypointFormatNumber or function(value)
	local text = Format("%.3f", tonumber(value) or 0)
	text = text:gsub("0+$", ""):gsub("%.$", "")
	if text == "-0" then
		text = "0"
	end
	return text
end

NAmanage.WaypointFormatCFramePosition = NAmanage.WaypointFormatCFramePosition or function(cf)
	if typeof(cf) ~= "CFrame" then
		return ""
	end
	const pos = cf.Position
	return NAmanage.WaypointFormatNumber(pos.X)..", "..NAmanage.WaypointFormatNumber(pos.Y)..", "..NAmanage.WaypointFormatNumber(pos.Z)
end

NAmanage.WaypointEntryToCFrame = NAmanage.WaypointEntryToCFrame or function(entry)
	if typeof(entry) == "CFrame" then
		return entry
	end
	if type(entry) ~= "table" then
		return nil
	end
	const comps = entry.Components
	if type(comps) == "table" then
		local ok, cf = pcall(function()
			return CFrame.new(unpack(comps))
		end)
		if ok and typeof(cf) == "CFrame" then
			return cf
		end
	end
	const pos = entry.Position or entry.position or entry.Pos or entry.pos
	if typeof(pos) == "Vector3" then
		return CFrame.new(pos)
	elseif type(pos) == "table" then
		const x = tonumber(pos.X or pos.x or pos[1])
		const y = tonumber(pos.Y or pos.y or pos[2])
		const z = tonumber(pos.Z or pos.z or pos[3])
		if x and y and z then
			return CFrame.new(x, y, z)
		end
	end
	const x = tonumber(entry.X or entry.x or entry[1])
	const y = tonumber(entry.Y or entry.y or entry[2])
	const z = tonumber(entry.Z or entry.z or entry[3])
	if x and y and z then
		return CFrame.new(x, y, z)
	end
	return nil
end

NAmanage.WaypointCFrameWithPosition = NAmanage.WaypointCFrameWithPosition or function(x, y, z, baseCf)
	x, y, z = tonumber(x), tonumber(y), tonumber(z)
	if not (x and y and z) then
		return nil
	end
	if typeof(baseCf) == "CFrame" then
		const comps = { baseCf:GetComponents() }
		return CFrame.new(x, y, z, comps[4], comps[5], comps[6], comps[7], comps[8], comps[9], comps[10], comps[11], comps[12])
	end
	return CFrame.new(x, y, z)
end

NAmanage.WaypointMakeEntry = NAmanage.WaypointMakeEntry or function(cf)
	if typeof(cf) ~= "CFrame" then
		return nil
	end
	const pos = cf.Position
	return {
		Components = { cf:GetComponents() };
		Position = {
			X = pos.X;
			Y = pos.Y;
			Z = pos.Z;
		};
	}
end

NAmanage.WaypointGetCurrentCFrame = NAmanage.WaypointGetCurrentCFrame or function()
	local char = getChar() or (LocalPlayer and LocalPlayer.Character)
	if not char and LocalPlayer then
		char = LocalPlayer.CharacterAdded:Wait()
	end
	const root = char and getRoot(char)
	if char then
		return (root and NAmanage.UG_clientCFrame(root)) or char:GetPivot()
	end
	return nil
end

NAmanage.WaypointNameAndCoordinatesFromArgs = NAmanage.WaypointNameAndCoordinatesFromArgs or function(...)
	const args = {...}
	if #args >= 4 then
		const x = tonumber(args[#args - 2])
		const y = tonumber(args[#args - 1])
		const z = tonumber(args[#args])
		if x and y and z then
			const nameParts = {}
			for i = 1, #args - 3 do
				nameParts[#nameParts + 1] = tostring(args[i] or "")
			end
			return NAmanage.waypointNameFromArgs(unpack(nameParts)), x, y, z
		end
	end
	const joined = NAmanage.WaypointTrim(Concat(args, " "))
	local nameText, coordText = joined:match("^(.-)%s*|%s*(.+)$")
	if nameText and coordText then
		local x, y, z = NAmanage.WaypointParseCoordinates(coordText)
		if x and y and z then
			return NAmanage.WaypointTrim(nameText), x, y, z
		end
	end
	const ranges = {}
	local scanAt = 1
	while true do
		local s, e = joined:find("[-+]?%d*%.?%d+", scanAt)
		if not s then
			break
		end
		ranges[#ranges + 1] = { s = s; e = e; text = joined:sub(s, e) }
		scanAt = e + 1
	end
	if #ranges >= 3 then
		const a = ranges[#ranges - 2]
		const b = ranges[#ranges - 1]
		const c = ranges[#ranges]
		const tailName = NAmanage.WaypointTrim((joined:sub(1, a.s - 1):gsub("[%s,;|]+$", "")))
		const x, y, z = tonumber(a.text), tonumber(b.text), tonumber(c.text)
		if tailName ~= "" and x and y and z then
			return tailName, x, y, z
		end
	end
	return joined, nil, nil, nil
end

NAmanage.WaypointSet = NAmanage.WaypointSet or function(name, cf, sourceText)
	name = NAmanage.waypointNameFromArgs(name)
	if not name or name == "" then
		DoNotif("Waypoint name cannot be empty.", 3)
		return false
	end
	if typeof(cf) ~= "CFrame" then
		DoNotif("Waypoint coordinates are invalid.", 3)
		return false
	end
	Waypoints[name] = NAmanage.WaypointMakeEntry(cf)
	NAmanage.SaveWaypoints()
	NAmanage.UpdateWaypointList()
	DebugNotif(("Waypoint '%s' set%s."):format(name, sourceText and (" "..sourceText) or ""))
	return true
end

NAmanage.WaypointSetFromUI = NAmanage.WaypointSetFromUI or function()
	const nameBox = NAUIMANAGER and NAUIMANAGER.WaypointNameBox
	const coordBox = NAUIMANAGER and NAUIMANAGER.WaypointCoordBox
	local name = nameBox and nameBox.Text or ""
	const coordText = coordBox and coordBox.Text or ""
	name = NAmanage.waypointNameFromArgs(name)
	if not name or name == "" then
		return DoNotif("Enter a waypoint name first.", 3)
	end
	local x, y, z = NAmanage.WaypointParseCoordinates(coordText)
	if not (x and y and z) then
		return DoNotif("Enter coordinates as X, Y, Z.", 3)
	end
	const oldCf = NAmanage.WaypointEntryToCFrame(Waypoints[name])
	const cf = NAmanage.WaypointCFrameWithPosition(x, y, z, oldCf)
	if NAmanage.WaypointSet(name, cf, "from custom coordinates") and coordBox then
		coordBox.Text = NAmanage.WaypointFormatCFramePosition(cf)
	end
end

NAmanage.WaypointFillCurrentUI = NAmanage.WaypointFillCurrentUI or function()
	const coordBox = NAUIMANAGER and NAUIMANAGER.WaypointCoordBox
	const cf = NAmanage.WaypointGetCurrentCFrame()
	if not cf then
		return DoNotif("Unable to get your character's position.", 3)
	end
	if coordBox then
		coordBox.Text = NAmanage.WaypointFormatCFramePosition(cf)
	end
	DebugNotif("Current coordinates filled.", 2)
end

NAmanage.WaypointOpenCoordinateEditor = NAmanage.WaypointOpenCoordinateEditor or function(name)
	name = NAmanage.waypointNameFromArgs(name)
	const entry = name and Waypoints[name]
	const cf = NAmanage.WaypointEntryToCFrame(entry)
	if not cf then
		return DoNotif(("Waypoint '%s' is invalid."):format(tostring(name)), 3)
	end
	const currentText = NAmanage.WaypointFormatCFramePosition(cf)
	Window({
		Title = "Edit Waypoint Coordinates",
		Description = "Waypoint: "..name.."\nCurrent: "..currentText.."\nEnter new coordinates as X, Y, Z.",
		InputField = true,
		Buttons = {
			{
				Text = "Save",
				Callback = function(input)
					local x, y, z = NAmanage.WaypointParseCoordinates(input)
					if not (x and y and z) then
						return DoNotif("Enter coordinates as X, Y, Z.", 3)
					end
					const latestCf = NAmanage.WaypointEntryToCFrame(Waypoints[name]) or cf
					const newCf = NAmanage.WaypointCFrameWithPosition(x, y, z, latestCf)
					if NAmanage.WaypointSet(name, newCf, "from edited coordinates") then
						DebugNotif(("Updated '%s' to %s."):format(name, NAmanage.WaypointFormatCFramePosition(newCf)), 3)
					end
				end
			}
		}
	})
end

NAmanage.WaypointESPGetState = NAmanage.WaypointESPGetState or function()
	if type(NAStuff.WaypointESPState) ~= "table" then
		NAStuff.WaypointESPState = {
			enabled = false;
			markerFolder = nil;
			visualFolder = nil;
			distanceConn = nil;
			visuals = {};
		}
	end
	const state = NAStuff.WaypointESPState
	if type(state.visuals) ~= "table" then
		state.visuals = {}
	end
	return state
end

NAmanage.WaypointESPGetColor = NAmanage.WaypointESPGetColor or function()
	const color = NAStuff.WaypointESP_Color
	if typeof(color) == "Color3" then
		return color
	end
	return Color3.fromRGB(75, 155, 255)
end

NAmanage.WaypointESPGetMaxDistance = NAmanage.WaypointESPGetMaxDistance or function()
	const dist = tonumber(NAStuff.WaypointESP_MaxDistance) or 100000
	if dist <= 0 then
		return 100000
	end
	return math.clamp(dist, 50, 100000)
end

NAmanage.WaypointESPGetIconSize = NAmanage.WaypointESPGetIconSize or function()
	return math.clamp(math.floor((tonumber(NAStuff.WaypointESP_IconSize) or 42) + 0.5), 16, 96)
end

NAmanage.WaypointESPGetTextSize = NAmanage.WaypointESPGetTextSize or function()
	return math.clamp(math.floor((tonumber(NAStuff.WaypointESP_TextSize) or 18) + 0.5), 10, 48)
end

NAmanage.WaypointESPGetRootPosition = NAmanage.WaypointESPGetRootPosition or function()
	local hum = nil
	if type(getHum) == "function" then
		hum = getHum()
	end
	const root = hum and hum.RootPart or nil
	if typeof(root) == "Instance" and root:IsA("BasePart") then
		return root.Position
	end
	local char = nil
	if type(getChar) == "function" then
		char = getChar()
	end
	if not char and LocalPlayer then
		char = LocalPlayer.Character
	end
	if char then
		if type(getRoot) == "function" then
			local ok, found = pcall(getRoot, char)
			if ok and typeof(found) == "Instance" and found:IsA("BasePart") then
				return found.Position
			end
		end
		const found = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
		if typeof(found) == "Instance" and found:IsA("BasePart") then
			return found.Position
		end
	end
	const cam = Services.Workspace and Services.Workspace.CurrentCamera or nil
	if cam then
		return cam.CFrame.Position
	end
	return nil
end

NAmanage.WaypointESPBuildLabelText = NAmanage.WaypointESPBuildLabelText or function(name, position, rootPosition)
	const pieces = {}
	if NAStuff.WaypointESP_ShowName ~= false then
		pieces[#pieces + 1] = tostring(name or "Waypoint")
	end
	if NAStuff.WaypointESP_ShowDistance ~= false and typeof(position) == "Vector3" then
		local origin = rootPosition
		if typeof(origin) ~= "Vector3" then
			origin = NAmanage.WaypointESPGetRootPosition()
		end
		if typeof(origin) == "Vector3" then
			pieces[#pieces + 1] = tostring(math.floor((origin - position).Magnitude + 0.5)).." studs"
		end
	end
	return Concat(pieces, " | ")
end

NAmanage.WaypointESPUpdateDistanceLabels = NAmanage.WaypointESPUpdateDistanceLabels or function(force)
	if NAStuff.WaypointESP_ShowDistance == false then
		return
	end
	const state = NAmanage.WaypointESPGetState()
	if state.enabled ~= true or type(state.visuals) ~= "table" then
		return
	end
	const rootPosition = NAmanage.WaypointESPGetRootPosition()
	for name, visual in state.visuals do
		if type(visual) == "table" then
			const label = visual.nameLabel
			const billboard = visual.nameBillboard
			if typeof(label) == "Instance" then
				local position = visual.position
				if typeof(position) ~= "Vector3" and typeof(visual.marker) == "Instance" then
					position = visual.marker.Position
				end
				const text = NAmanage.WaypointESPBuildLabelText(visual.name or name, position, rootPosition)
				if text ~= "" and label.Text ~= text then
					label.Text = text
				end
				if typeof(billboard) == "Instance" and billboard.Enabled ~= (text ~= "") then
					billboard.Enabled = text ~= ""
				end
			end
		end
	end
end

NAmanage.WaypointESPStartDistanceLoop = NAmanage.WaypointESPStartDistanceLoop or function()
	const state = NAmanage.WaypointESPGetState()
	if typeof(state.distanceConn) == "RBXScriptConnection" then
		pcall(function()
			state.distanceConn:Disconnect()
		end)
	end
	state.distanceConn = nil
	if state.enabled ~= true or NAStuff.WaypointESP_ShowDistance == false then
		return
	end
	state.distanceConn = Services.RunService.Heartbeat:Connect(function()
		if NAStuff.WaypointESP_ShowDistance == false or state.enabled ~= true then
			if typeof(state.distanceConn) == "RBXScriptConnection" then
				pcall(function()
					state.distanceConn:Disconnect()
				end)
			end
			state.distanceConn = nil
			return
		end
		NAmanage.WaypointESPUpdateDistanceLabels(false)
	end)
end

NAmanage.WaypointESPGetIconFont = NAmanage.WaypointESPGetIconFont or function()
	const path = BUILDER_ICON_FONT_PATH or "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
	if Font and type(Font.new) == "function" then
		local ok, font = pcall(Font.new, path, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		if ok and font then
			return font
		end
	end
	return nil
end

NAmanage.WaypointESPApplyLabelFont = NAmanage.WaypointESPApplyLabelFont or function(label, bold)
	if typeof(label) ~= "Instance" then
		return
	end
	if Font and type(Font.new) == "function" then
		local ok, font = pcall(Font.new, "rbxasset://fonts/families/BuilderSans.json", bold and Enum.FontWeight.Bold or Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		if ok and font then
			pcall(function()
				label.FontFace = font
			end)
			return
		end
	end
	pcall(function()
		label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	end)
end

NAmanage.WaypointESPSessionName = NAmanage.WaypointESPSessionName or function(key)
	const logicalKey = "WaypointESP_"..tostring(key or "Instance")
	if type(NAmanage.GetSessionInstanceName) == "function" then
		local ok, value = pcall(NAmanage.GetSessionInstanceName, logicalKey)
		if ok and type(value) == "string" and value ~= "" then
			return value
		end
	end
	if type(NAmanage.GenerateOpaqueSessionKey) == "function" then
		local ok, value = pcall(NAmanage.GenerateOpaqueSessionKey)
		if ok and type(value) == "string" and value ~= "" then
			return value
		end
	end
	return "a"..tostring(math.random(100000, 999999)).."_-"..tostring(math.random(100000, 999999))
end

NAmanage.WaypointESPSetSessionName = NAmanage.WaypointESPSetSessionName or function(inst, key)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const name = NAmanage.WaypointESPSessionName(key)
	if type(name) == "string" and name ~= "" then
		pcall(function()
			inst.Name = name
		end)
	end
	return name
end

NAmanage.WaypointESPDestroy = NAmanage.WaypointESPDestroy or function(disable)
	const state = NAmanage.WaypointESPGetState()
	if disable == true then
		state.enabled = false
	end
	if typeof(state.distanceConn) == "RBXScriptConnection" then
		pcall(function()
			state.distanceConn:Disconnect()
		end)
	end
	state.distanceConn = nil
	if type(state.visuals) == "table" then
		for _, visual in state.visuals do
			if type(visual) == "table" then
				for _, key in { "box", "highlight", "nameBillboard", "iconBillboard", "marker" } do
					const inst = visual[key]
					if typeof(inst) == "Instance" then
						pcall(function()
							inst:Destroy()
						end)
					end
				end
			elseif typeof(visual) == "Instance" then
				pcall(function()
					visual:Destroy()
				end)
			end
		end
	end
	state.visuals = {}
	if typeof(state.visualFolder) == "Instance" then
		pcall(function()
			state.visualFolder:Destroy()
		end)
	end
	state.visualFolder = nil
	if typeof(state.markerFolder) == "Instance" then
		pcall(function()
			state.markerFolder:Destroy()
		end)
	end
	state.markerFolder = nil
end

NAmanage.WaypointESPGetMarkerFolder = NAmanage.WaypointESPGetMarkerFolder or function()
	const state = NAmanage.WaypointESPGetState()
	if typeof(state.markerFolder) == "Instance" and state.markerFolder.Parent then
		return state.markerFolder
	end
	const folder = Instance.new("Folder")
	NAmanage.WaypointESPSetSessionName(folder, "MarkerFolder")
	folder.Parent = Services.Workspace
	state.markerFolder = folder
	return folder
end

NAmanage.WaypointESPGetVisualFolder = NAmanage.WaypointESPGetVisualFolder or function()
	const state = NAmanage.WaypointESPGetState()
	local secureContainer = nil
	if type(NAmanage.ESP_EnsureSecureContainer) == "function" then
		secureContainer = NAmanage.ESP_EnsureSecureContainer()
	end
	if not secureContainer and type(NAmanage.ESP_GetSecureHost) == "function" then
		secureContainer = NAmanage.ESP_GetSecureHost()
	end
	if typeof(secureContainer) ~= "Instance" then
		return nil
	end
	if typeof(state.visualFolder) == "Instance" and state.visualFolder.Parent == secureContainer then
		return state.visualFolder
	end
	if typeof(state.visualFolder) == "Instance" then
		pcall(function()
			state.visualFolder:Destroy()
		end)
	end
	const folder = InstanceNew and InstanceNew("Folder") or Instance.new("Folder")
	if NAmanage.ESP_HardenVisual then
		pcall(NAmanage.ESP_HardenVisual, folder)
	end
	NAmanage.WaypointESPSetSessionName(folder, "VisualFolder")
	folder.Parent = secureContainer
	state.visualFolder = folder
	return folder
end

NAmanage.WaypointESPStoreVisual = NAmanage.WaypointESPStoreVisual or function(inst, key)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const folder = NAmanage.WaypointESPGetVisualFolder()
	if typeof(folder) ~= "Instance" then
		const stored = NAmanage.ESP_StoreVisual and NAmanage.ESP_StoreVisual(inst) or nil
		NAmanage.WaypointESPSetSessionName(inst, key or inst.ClassName)
		return stored
	end
	if NAmanage.ESP_HardenVisual then
		pcall(NAmanage.ESP_HardenVisual, inst)
	end
	NAmanage.WaypointESPSetSessionName(inst, key or inst.ClassName)
	if inst.Parent ~= folder then
		pcall(function()
			inst.Parent = folder
		end)
	end
	return folder
end

NAmanage.WaypointESPCreateVisual = NAmanage.WaypointESPCreateVisual or function(name, cf)
	if typeof(cf) ~= "CFrame" then
		return nil
	end
	const markerFolder = NAmanage.WaypointESPGetMarkerFolder()
	if typeof(markerFolder) ~= "Instance" then
		return nil
	end

	const color = NAmanage.WaypointESPGetColor()
	const marker = Instance.new("Part")
	NAmanage.WaypointESPSetSessionName(marker, "Marker_"..tostring(name))
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanTouch = false
	marker.CanQuery = false
	marker.CastShadow = false
	pcall(function()
		marker.Material = Enum.Material.Glass
	end)
	marker.Size = Vector3.new(4, 4, 4)
	marker.Transparency = 1
	marker.CFrame = cf
	marker.Parent = markerFolder

	local box = nil
	if NAStuff.WaypointESP_ShowBox == true then
		box = InstanceNew and InstanceNew("BoxHandleAdornment") or Instance.new("BoxHandleAdornment")
		NAmanage.WaypointESPSetSessionName(box, "Box_"..tostring(name))
		box.Adornee = marker
		box.AlwaysOnTop = true
		box.Color3 = color
		box.Size = marker.Size
		box.Transparency = NAgui and NAgui.sanitizeTransparency and NAgui.sanitizeTransparency(NAStuff.ESP_PartTransparency or 0.45) or 0.35
		box.ZIndex = 10
		NAmanage.WaypointESPStoreVisual(box, "Box_"..tostring(name))
	end

	local highlight = nil
	if NAStuff.WaypointESP_ShowHighlight ~= false then
		local okHighlight, hl = pcall(Instance.new, "Highlight")
		if okHighlight and hl then
			highlight = hl
			NAmanage.WaypointESPSetSessionName(highlight, "Highlight_"..tostring(name))
			highlight.Adornee = marker
			highlight.FillColor = color
			highlight.OutlineColor = color
			highlight.FillTransparency = 0.88
			highlight.OutlineTransparency = 0
			pcall(function()
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			end)
			NAmanage.WaypointESPStoreVisual(highlight, "Highlight_"..tostring(name))
		end
	end

	local nameBillboard = nil
	local nameLabel = nil
	const showNameText = NAStuff.WaypointESP_ShowName ~= false
	const showDistanceText = NAStuff.WaypointESP_ShowDistance ~= false
	if showNameText or showDistanceText then
		const nameTextSize = NAmanage.WaypointESPGetTextSize()
		nameBillboard = InstanceNew and InstanceNew("BillboardGui") or Instance.new("BillboardGui")
		NAmanage.WaypointESPSetSessionName(nameBillboard, "NameBillboard_"..tostring(name))
		nameBillboard.Adornee = marker
		nameBillboard.AlwaysOnTop = true
		nameBillboard.MaxDistance = NAmanage.WaypointESPGetMaxDistance()
		nameBillboard.Size = UDim2.fromOffset(math.max(showDistanceText and 320 or 260, nameTextSize * (showDistanceText and 16 or 12)), math.max(34, nameTextSize + 14))
		nameBillboard.StudsOffsetWorldSpace = Vector3.new(0, 3.65, 0)
		pcall(function()
			nameBillboard.LightInfluence = 0
		end)
		nameBillboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		NAmanage.WaypointESPStoreVisual(nameBillboard, "NameBillboard_"..tostring(name))

		nameLabel = InstanceNew and InstanceNew("TextLabel", nameBillboard) or Instance.new("TextLabel")
		NAmanage.WaypointESPSetSessionName(nameLabel, "NameLabel_"..tostring(name))
		nameLabel.BackgroundTransparency = 1
		nameLabel.Size = UDim2.fromScale(1, 1)
		nameLabel.Text = NAmanage.WaypointESPBuildLabelText(name, marker.Position)
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.TextScaled = false
		nameLabel.TextSize = nameTextSize
		nameLabel.TextWrapped = false
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.ZIndex = 2
		NAmanage.WaypointESPApplyLabelFont(nameLabel, true)
		if nameLabel.Parent ~= nameBillboard then
			nameLabel.Parent = nameBillboard
		end
	end

	local iconBillboard = nil
	local iconLabel = nil
	if NAStuff.WaypointESP_ShowIcon ~= false then
		const iconSize = NAmanage.WaypointESPGetIconSize()
		iconBillboard = InstanceNew and InstanceNew("BillboardGui") or Instance.new("BillboardGui")
		NAmanage.WaypointESPSetSessionName(iconBillboard, "IconBillboard_"..tostring(name))
		iconBillboard.Adornee = marker
		iconBillboard.AlwaysOnTop = true
		iconBillboard.MaxDistance = NAmanage.WaypointESPGetMaxDistance()
		iconBillboard.Size = UDim2.fromOffset(math.max(58, iconSize + 16), math.max(58, iconSize + 16))
		iconBillboard.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
		pcall(function()
			iconBillboard.LightInfluence = 0
		end)
		iconBillboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		NAmanage.WaypointESPStoreVisual(iconBillboard, "IconBillboard_"..tostring(name))

		iconLabel = InstanceNew and InstanceNew("TextLabel", iconBillboard) or Instance.new("TextLabel")
		NAmanage.WaypointESPSetSessionName(iconLabel, "IconLabel_"..tostring(name))
		iconLabel.BackgroundTransparency = 1
		iconLabel.Size = UDim2.fromScale(1, 1)
		iconLabel.Text = "location-pin"
		iconLabel.TextColor3 = color
		iconLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		iconLabel.TextStrokeTransparency = 0.12
		iconLabel.TextSize = iconSize
		iconLabel.TextXAlignment = Enum.TextXAlignment.Center
		iconLabel.TextYAlignment = Enum.TextYAlignment.Center
		iconLabel.ZIndex = 3
		const iconFont = NAmanage.WaypointESPGetIconFont()
		if iconFont then
			pcall(function()
				iconLabel.FontFace = iconFont
			end)
		else
			pcall(function()
				iconLabel.Font = Enum.Font.GothamBold
			end)
		end
		if iconLabel.Parent ~= iconBillboard then
			iconLabel.Parent = iconBillboard
		end
	end

	return {
		marker = marker;
		box = box;
		highlight = highlight;
		nameBillboard = nameBillboard;
		nameLabel = nameLabel;
		iconBillboard = iconBillboard;
		iconLabel = iconLabel;
		name = name;
		position = marker.Position;
	}
end

NAmanage.WaypointESPRefresh = NAmanage.WaypointESPRefresh or function(silent)
	const state = NAmanage.WaypointESPGetState()
	if state.enabled ~= true then
		return 0
	end
	NAmanage.WaypointESPDestroy(false)
	state.enabled = true
	local count = 0
	local invalid = 0
	for name, entry in Waypoints do
		const cf = NAmanage.WaypointEntryToCFrame(entry)
		if typeof(cf) == "CFrame" then
			const visual = NAmanage.WaypointESPCreateVisual(name, cf)
			if visual then
				state.visuals[name] = visual
				count += 1
			end
		else
			invalid += 1
		end
		if (count + invalid) % 24 == 0 then
			Wait()
		end
	end
	NAmanage.WaypointESPUpdateDistanceLabels(true)
	NAmanage.WaypointESPStartDistanceLoop()
	if silent ~= true then
		if count > 0 then
			DebugNotif(("Waypoint ESP showing %d waypoint%s."):format(count, count == 1 and "" or "s"), 3)
		elseif invalid > 0 then
			DoNotif("Waypoint ESP enabled, but saved waypoint coordinates are invalid.", 3)
		else
			DoNotif("Waypoint ESP enabled. No saved waypoints for this place yet.", 3)
		end
	end
	return count
end

NAmanage.WaypointESPApplyOptions = NAmanage.WaypointESPApplyOptions or function()
	const state = NAmanage.WaypointESPGetState()
	if state.enabled == true then
		NAmanage.WaypointESPRefresh(true)
	end
end

NAmanage.WaypointESPSetEnabled = NAmanage.WaypointESPSetEnabled or function(enabled, silent)
	const state = NAmanage.WaypointESPGetState()
	state.enabled = enabled == true
	if state.enabled then
		const count = NAmanage.WaypointESPRefresh(silent)
		if NAgui and NAgui.setToggleState then
			pcall(NAgui.setToggleState, "Waypoint ESP", true, { force = true; fire = false; animate = true })
		end
		return count
	end
	NAmanage.WaypointESPDestroy(true)
	if NAgui and NAgui.setToggleState then
		pcall(NAgui.setToggleState, "Waypoint ESP", false, { force = true; fire = false; animate = true })
	end
	if silent ~= true then
		DebugNotif("Waypoint ESP hidden.", 2)
	end
	return 0
end

cmd.add({"showwaypoints", "showwp", "showwps", "waypointesp", "wpesp"}, {"showwaypoints", "Show saved waypoint ESP markers for this place"}, function()
	NAmanage.WaypointESPSetEnabled(true)
end, true)

cmd.add({"hidewaypoints", "hidewp", "hidewps", "unshowwaypoints", "unwpesp"}, {"hidewaypoints", "Hide saved waypoint ESP markers"}, function()
	NAmanage.WaypointESPSetEnabled(false)
end)

NAmanage.WaypointPathGetState = function()
	if type(NAStuff.WaypointPathState) ~= "table" then
		NAStuff.WaypointPathState = {
			enabled = false;
			following = false;
			followTarget = nil;
			followCharacter = nil;
			lastFollowOutcome = nil;
			looping = false;
			loopTarget = nil;
			loopMode = nil;
			loopToken = 0;
			token = 0;
			pathHeightOffset = 0;
			moveAccumulator = 0;
			moveTarget = nil;
			moveExactTarget = nil;
			markerFolder = nil;
			visualFolder = nil;
			visuals = {};
			lastName = nil;
			lastWaypoints = nil;
		}
	end
	const state = NAStuff.WaypointPathState
	if type(state.visuals) ~= "table" then
		state.visuals = {}
	end
	return state
end

NAmanage.WaypointPathSessionName = NAmanage.WaypointPathSessionName or function(key)
	const logicalKey = "WaypointPath_"..tostring(key or "Instance")
	if type(NAmanage.GetSessionInstanceName) == "function" then
		local ok, value = pcall(NAmanage.GetSessionInstanceName, logicalKey)
		if ok and type(value) == "string" and value ~= "" then
			return value
		end
	end
	if type(NAmanage.GenerateOpaqueSessionKey) == "function" then
		local ok, value = pcall(NAmanage.GenerateOpaqueSessionKey)
		if ok and type(value) == "string" and value ~= "" then
			return value
		end
	end
	return "p"..tostring(math.random(100000, 999999)).."_-"..tostring(math.random(100000, 999999))
end

NAmanage.WaypointPathSetSessionName = NAmanage.WaypointPathSetSessionName or function(inst, key)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const name = NAmanage.WaypointPathSessionName(key)
	if type(name) == "string" and name ~= "" then
		pcall(function()
			inst.Name = name
		end)
	end
	return name
end

NAmanage.WaypointPathDestroy = function(disable)
	const state = NAmanage.WaypointPathGetState()
	if disable == true then
		state.enabled = false
		state.following = false
		state.followTarget = nil
		state.followCharacter = nil
		state.lastFollowOutcome = "stopped"
		state.looping = false
		state.loopTarget = nil
		state.loopMode = nil
		state.lastWaypoints = nil
		state.lastName = nil
		state.pathHeightOffset = 0
		state.moveAccumulator = 0
		state.moveTarget = nil
		state.moveExactTarget = nil
	end
	if type(state.visuals) == "table" then
		for _, visual in state.visuals do
			if type(visual) == "table" then
				for _, key in { "marker", "highlight", "billboard" } do
					const inst = visual[key]
					if typeof(inst) == "Instance" then
						pcall(function()
							inst:Destroy()
						end)
					end
				end
			elseif typeof(visual) == "Instance" then
				pcall(function()
					visual:Destroy()
				end)
			end
		end
	end
	state.visuals = {}
	if typeof(state.visualFolder) == "Instance" then
		pcall(function()
			state.visualFolder:Destroy()
		end)
	end
	state.visualFolder = nil
	if typeof(state.markerFolder) == "Instance" then
		pcall(function()
			state.markerFolder:Destroy()
		end)
	end
	state.markerFolder = nil
end

NAmanage.WaypointPathSyncUI = NAmanage.WaypointPathSyncUI or function()
	if type(NAmanage.UpdateWaypointList) ~= "function" then
		return
	end
	Defer(function()
		if type(NAmanage.UpdateWaypointList) == "function" then
			pcall(NAmanage.UpdateWaypointList)
		end
	end)
end

NAmanage.WaypointPathStop = function(silent)
	const state = NAmanage.WaypointPathGetState()
	state.token = (tonumber(state.token) or 0) + 1
	state.loopToken = (tonumber(state.loopToken) or 0) + 1
	state.following = false
	state.looping = false
	NAmanage.WaypointPathDestroy(true)

	local _, root = NAmanage.WaypointPathGetRoot()
	if root and root.Parent and type(NAmanage.WaypointPathBrakePlanarVelocity) == "function" then
		pcall(NAmanage.WaypointPathBrakePlanarVelocity, root)
	end

	if silent ~= true then
		DebugNotif("Waypoint pathfinding stopped.", 2)
	end
	NAmanage.WaypointPathSyncUI()
end

NAmanage.WaypointPathGetMarkerFolder = NAmanage.WaypointPathGetMarkerFolder or function()
	const state = NAmanage.WaypointPathGetState()
	if typeof(state.markerFolder) == "Instance" and state.markerFolder.Parent then
		return state.markerFolder
	end
	const folder = Instance.new("Folder")
	NAmanage.WaypointPathSetSessionName(folder, "MarkerFolder")
	folder.Parent = Services.Workspace
	state.markerFolder = folder
	return folder
end

NAmanage.WaypointPathGetVisualFolder = NAmanage.WaypointPathGetVisualFolder or function()
	const state = NAmanage.WaypointPathGetState()
	local secureContainer = nil
	if type(NAmanage.ESP_EnsureSecureContainer) == "function" then
		secureContainer = NAmanage.ESP_EnsureSecureContainer()
	end
	if not secureContainer and type(NAmanage.ESP_GetSecureHost) == "function" then
		secureContainer = NAmanage.ESP_GetSecureHost()
	end
	if typeof(secureContainer) ~= "Instance" then
		return nil
	end
	if typeof(state.visualFolder) == "Instance" and state.visualFolder.Parent == secureContainer then
		return state.visualFolder
	end
	if typeof(state.visualFolder) == "Instance" then
		pcall(function()
			state.visualFolder:Destroy()
		end)
	end
	const folder = InstanceNew and InstanceNew("Folder") or Instance.new("Folder")
	if NAmanage.ESP_HardenVisual then
		pcall(NAmanage.ESP_HardenVisual, folder)
	end
	NAmanage.WaypointPathSetSessionName(folder, "VisualFolder")
	folder.Parent = secureContainer
	state.visualFolder = folder
	return folder
end

NAmanage.WaypointPathStoreVisual = NAmanage.WaypointPathStoreVisual or function(inst, key)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const folder = NAmanage.WaypointPathGetVisualFolder()
	if typeof(folder) ~= "Instance" then
		const stored = NAmanage.ESP_StoreVisual and NAmanage.ESP_StoreVisual(inst) or nil
		NAmanage.WaypointPathSetSessionName(inst, key or inst.ClassName)
		return stored
	end
	if NAmanage.ESP_HardenVisual then
		pcall(NAmanage.ESP_HardenVisual, inst)
	end
	NAmanage.WaypointPathSetSessionName(inst, key or inst.ClassName)
	if inst.Parent ~= folder then
		pcall(function()
			inst.Parent = folder
		end)
	end
	return folder
end

NAmanage.WaypointPathGetRoot = NAmanage.WaypointPathGetRoot or function()
	local hum = nil
	if type(getHum) == "function" then
		hum = getHum()
	end
	const root = hum and hum.RootPart or nil
	if typeof(root) == "Instance" and root:IsA("BasePart") then
		return hum, root
	end
	local char = nil
	if type(getChar) == "function" then
		char = getChar()
	end
	if not char and LocalPlayer then
		char = LocalPlayer.Character
	end
	if char and type(getRoot) == "function" then
		local ok, found = pcall(getRoot, char)
		if ok and typeof(found) == "Instance" and found:IsA("BasePart") then
			return hum, found
		end
	end
	return hum, nil
end

NAStuff.WaypointPathRevision = "cframe-walk-v4"
NAStuff.WaypointPathMoveStepRate = 1 / 60
NAStuff.WaypointPathMoveMaxSteps = 4
NAStuff.WaypointPathReachRadius = 1.25

NAmanage.WaypointPathGetClientCFrame = function(root)
	if type(NAmanage.UG_clientCFrame) == "function" then
		local ok, cf = pcall(NAmanage.UG_clientCFrame, root)
		if ok and typeof(cf) == "CFrame" then
			return cf
		end
	end
	if root and root:IsA("BasePart") then
		local ok, cf = pcall(function()
			return root.CFrame
		end)
		if ok and typeof(cf) == "CFrame" then
			return cf
		end
	end
	return nil
end

NAmanage.WaypointPathGetClientPosition = function(root)
	const cf = NAmanage.WaypointPathGetClientCFrame(root)
	return typeof(cf) == "CFrame" and cf.Position or nil
end

NAmanage.WaypointPathGetSpeed = function(hum)
	if NAStuff.SafeSpeedMethod ~= false and type(NAmanage.GetVelocityWalkSpeedValue) == "function" then
		local ok, value = pcall(NAmanage.GetVelocityWalkSpeedValue)
		if ok and tonumber(value) ~= nil then
			return math.max(tonumber(value), 0)
		end
	end

	local speed = nil
	if hum then
		speed = tonumber(NAlib.isProperty(hum, "WalkSpeed"))
		if speed == nil then
			pcall(function()
				speed = tonumber(hum.WalkSpeed)
			end)
		end
	end
	return math.max(speed or 16, 0)
end

NAmanage.WaypointPathGetMoveTarget = function(_, logicalTarget, exactTarget)
	if typeof(exactTarget) == "Vector3" then
		return exactTarget
	end
	if typeof(logicalTarget) ~= "Vector3" then
		return nil
	end
	const state = NAmanage.WaypointPathGetState()
	return logicalTarget + Vector3.new(0, tonumber(state.pathHeightOffset) or 0, 0)
end

NAmanage.WaypointPathBuildStepCFrame = function(currentCF, targetPosition, maxDistance)
	if typeof(currentCF) ~= "CFrame" or typeof(targetPosition) ~= "Vector3" then
		return nil
	end
	const delta = targetPosition - currentCF.Position
	const distance = delta.Magnitude
	if distance <= 0.0001 then
		return CFrame.new(targetPosition) * (currentCF - currentCF.Position)
	end
	const stepDistance = math.min(distance, math.max(tonumber(maxDistance) or 0, 0))
	const nextPosition = currentCF.Position + delta.Unit * stepDistance
	const flatDirection = Vector3.new(delta.X, 0, delta.Z)
	if flatDirection.Magnitude > 0.05 then
		return CFrame.new(nextPosition, nextPosition + flatDirection)
	end
	return CFrame.new(nextPosition) * (currentCF - currentCF.Position)
end

NAmanage.WaypointPathBrakePlanarVelocity = function(root)
	if not (root and root.Parent and root:IsA("BasePart")) then
		return
	end
	const velocity = NAlib.isProperty(root, "AssemblyLinearVelocity") or root.Velocity
	if typeof(velocity) ~= "Vector3" then
		return
	end
	const stopped = Vector3.new(0, velocity.Y, 0)
	if stopped ~= velocity then
		if not NAlib.setProperty(root, "AssemblyLinearVelocity", stopped) then
			root.Velocity = stopped
		end
	end
end

NAmanage.WaypointPathResolve = NAmanage.WaypointPathResolve or function(rawName)
	const name = NAmanage.waypointNameFromArgs(rawName)
	if not name or name == "" then
		return nil, nil, "Usage: pathfindwaypoint <name...>"
	end
	const entry = Waypoints[name]
	if not entry then
		return name, nil, ("No such waypoint '%s'."):format(name)
	end
	const cf = NAmanage.WaypointEntryToCFrame(entry)
	if typeof(cf) ~= "CFrame" then
		return name, nil, ("Waypoint '%s' is invalid."):format(name)
	end
	return name, cf, nil
end

NAmanage.WaypointPathCompute = function(cf)
	if typeof(cf) ~= "CFrame" then
		return nil, "Waypoint coordinates are invalid."
	end
	local hum, root = NAmanage.WaypointPathGetRoot()
	if not (hum and root) then
		return nil, "Unable to get your character root."
	end
	const ps = SafeGetService("PathfindingService")
	if typeof(ps) ~= "Instance" then
		return nil, "PathfindingService is unavailable."
	end
	const startPosition = NAmanage.WaypointPathGetClientPosition(root)
	if typeof(startPosition) ~= "Vector3" then
		return nil, "Unable to resolve your client character position."
	end
	const path = ps:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
	local ok, err = pcall(function()
		path:ComputeAsync(startPosition, cf.Position)
	end)
	if not ok then
		return nil, "Pathfinding failed: "..tostring(err)
	end
	if path.Status ~= Enum.PathStatus.Success then
		return nil, "No path found to that waypoint ("..tostring(path.Status)..")."
	end
	local okWaypoints, waypoints = pcall(function()
		return path:GetWaypoints()
	end)
	if not okWaypoints or type(waypoints) ~= "table" or #waypoints <= 0 then
		return nil, "Pathfinding returned no route nodes."
	end
	return waypoints, nil, path
end

NAmanage.WaypointPathCreateVisual = NAmanage.WaypointPathCreateVisual or function(index, waypoint, total)
	if type(waypoint) ~= "table" and typeof(waypoint) ~= "PathWaypoint" then
		return nil
	end
	const pos = waypoint.Position
	if typeof(pos) ~= "Vector3" then
		return nil
	end
	const folder = NAmanage.WaypointPathGetMarkerFolder()
	if typeof(folder) ~= "Instance" then
		return nil
	end
	const color = NAmanage.WaypointESPGetColor()
	const marker = Instance.new("Part")
	NAmanage.WaypointPathSetSessionName(marker, "Node_"..tostring(index))
	marker.Anchored = true
	marker.CanCollide = false
	marker.CanTouch = false
	marker.CanQuery = false
	marker.CastShadow = false
	pcall(function()
		marker.Material = Enum.Material.Glass
	end)
	marker.Size = Vector3.new(2, 2, 2)
	marker.Transparency = 1
	marker.CFrame = CFrame.new(pos)
	marker.Parent = folder

	local highlight = nil
	local okHighlight, hl = pcall(Instance.new, "Highlight")
	if okHighlight and hl then
		highlight = hl
		NAmanage.WaypointPathSetSessionName(highlight, "Highlight_"..tostring(index))
		highlight.Adornee = marker
		highlight.FillColor = color
		highlight.OutlineColor = color
		highlight.FillTransparency = 0.72
		highlight.OutlineTransparency = 0
		pcall(function()
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		end)
		NAmanage.WaypointPathStoreVisual(highlight, "Highlight_"..tostring(index))
	end

	const billboard = InstanceNew and InstanceNew("BillboardGui") or Instance.new("BillboardGui")
	NAmanage.WaypointPathSetSessionName(billboard, "Billboard_"..tostring(index))
	billboard.Adornee = marker
	billboard.AlwaysOnTop = true
	billboard.Enabled = NAStuff.WaypointPath_ShowText == true
	billboard.MaxDistance = NAmanage.WaypointESPGetMaxDistance()
	billboard.Size = UDim2.fromOffset(96, 30)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.25, 0)
	pcall(function()
		billboard.LightInfluence = 0
	end)
	billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	NAmanage.WaypointPathStoreVisual(billboard, "Billboard_"..tostring(index))

	const label = InstanceNew and InstanceNew("TextLabel", billboard) or Instance.new("TextLabel")
	NAmanage.WaypointPathSetSessionName(label, "Label_"..tostring(index))
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = (waypoint.Action == Enum.PathWaypointAction.Jump and "JUMP " or "")..tostring(index).."/"..tostring(total or index)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextStrokeTransparency = 0
	label.TextScaled = false
	label.TextSize = 14
	label.TextWrapped = false
	label.ZIndex = 2
	NAmanage.WaypointESPApplyLabelFont(label, true)
	if label.Parent ~= billboard then
		label.Parent = billboard
	end

	return {
		marker = marker;
		highlight = highlight;
		billboard = billboard;
		label = label;
		position = pos;
	}
end

NAmanage.WaypointPathApplyTextVisibility = NAmanage.WaypointPathApplyTextVisibility or function()
	const state = NAmanage.WaypointPathGetState()
	const showText = NAStuff.WaypointPath_ShowText == true
	if type(state.visuals) ~= "table" then
		return
	end
	for _, visual in state.visuals do
		if type(visual) == "table" and typeof(visual.billboard) == "Instance" then
			pcall(function()
				visual.billboard.Enabled = showText
			end)
		end
	end
end

NAmanage.WaypointPathDraw = NAmanage.WaypointPathDraw or function(name, waypoints)
	const state = NAmanage.WaypointPathGetState()
	state.lastName = name
	state.lastWaypoints = waypoints
	NAmanage.WaypointPathDestroy(false)
	state.enabled = true
	if NAStuff.WaypointPath_ShowNodes == false then
		return 0
	end
	const total = type(waypoints) == "table" and #waypoints or 0
	local made = 0
	if total <= 0 then
		return 0
	end
	for i, waypoint in waypoints do
		const visual = NAmanage.WaypointPathCreateVisual(i, waypoint, total)
		if visual then
			state.visuals[i] = visual
			made += 1
		end
		if i % 24 == 0 then
			Wait()
		end
	end
	NAmanage.WaypointPathApplyTextVisibility()
	return made
end

NAmanage.WaypointPathRedraw = NAmanage.WaypointPathRedraw or function()
	const state = NAmanage.WaypointPathGetState()
	if state.enabled == true and type(state.lastWaypoints) == "table" then
		return NAmanage.WaypointPathDraw(state.lastName or "Waypoint", state.lastWaypoints)
	end
	return 0
end

NAmanage.WaypointPathShow = NAmanage.WaypointPathShow or function(rawName, silent)
	local name, cf, err = NAmanage.WaypointPathResolve(rawName)
	if err then
		DoNotif(err, 3)
		return nil
	end
	local waypoints, computeErr = NAmanage.WaypointPathCompute(cf)
	if not waypoints then
		DoNotif(computeErr or "Pathfinding failed.", 3)
		return nil
	end
	const count = NAmanage.WaypointPathDraw(name, waypoints)
	if silent ~= true then
		if NAStuff.WaypointPath_ShowNodes == false then
			DebugNotif(("Computed %d path node%s to '%s'. Path node drawing is disabled."):format(#waypoints, #waypoints == 1 and "" or "s", name), 3)
		else
			DebugNotif(("Showing %d path node%s to waypoint '%s'."):format(count, count == 1 and "" or "s", name), 3)
		end
	end
	return waypoints, cf, name
end

NAmanage.WaypointPathCFrameMoveTo = function(hum, position, token, timeoutSeconds, exactTarget)
	if not (hum and hum.Parent and typeof(position) == "Vector3") then
		return false
	end

	const state = NAmanage.WaypointPathGetState()
	local _, firstRoot = NAmanage.WaypointPathGetRoot()
	const firstCF = NAmanage.WaypointPathGetClientCFrame(firstRoot)
	const firstTarget = NAmanage.WaypointPathGetMoveTarget(firstRoot, position, exactTarget)
	local speed = NAmanage.WaypointPathGetSpeed(hum)
	local requestedTimeout = math.max(0.25, tonumber(timeoutSeconds) or 8)
	if typeof(firstCF) == "CFrame" and typeof(firstTarget) == "Vector3" and speed > 0 then
		requestedTimeout = math.max(requestedTimeout, ((firstTarget - firstCF.Position).Magnitude / speed) * 2 + 1)
	end
	const timeoutAt = os.clock() + requestedTimeout
	local reached = false
	const stepRate = tonumber(NAStuff.WaypointPathMoveStepRate) or (1 / 60)
	const maxSteps = math.max(1, math.floor(tonumber(NAStuff.WaypointPathMoveMaxSteps) or 4))
	state.moveAccumulator = 0
	state.moveTarget = position
	state.moveExactTarget = exactTarget

	while os.clock() < timeoutAt do
		if state.token ~= token or not hum.Parent or hum.Health <= 0 then
			break
		end

		local root = hum.RootPart
		if not (root and root.Parent and root:IsA("BasePart")) then
			local _, fallbackRoot = NAmanage.WaypointPathGetRoot()
			root = fallbackRoot
		end
		if not (root and root.Parent and root:IsA("BasePart")) then
			break
		end

		local currentCF = NAmanage.WaypointPathGetClientCFrame(root)
		local moveTarget = NAmanage.WaypointPathGetMoveTarget(root, position, exactTarget)
		if typeof(currentCF) ~= "CFrame" or typeof(moveTarget) ~= "Vector3" then
			break
		end
		if (moveTarget - currentCF.Position).Magnitude <= (tonumber(NAStuff.WaypointPathReachRadius) or 1.25) then
			reached = true
			break
		end

		local deltaTime = 1 / 60
		if Services.RunService and Services.RunService.Heartbeat then
			deltaTime = tonumber(Services.RunService.Heartbeat:Wait()) or deltaTime
		else
			Wait()
		end
		state.moveAccumulator = math.min((tonumber(state.moveAccumulator) or 0) + math.max(deltaTime, 0), stepRate * maxSteps)

		local steps = 0
		local failed = false
		while state.moveAccumulator >= stepRate and steps < maxSteps do
			if state.token ~= token or not hum.Parent or hum.Health <= 0 then
				failed = true
				break
			end

			currentCF = NAmanage.WaypointPathGetClientCFrame(root)
			moveTarget = NAmanage.WaypointPathGetMoveTarget(root, position, exactTarget)
			if typeof(currentCF) ~= "CFrame" or typeof(moveTarget) ~= "Vector3" then
				failed = true
				break
			end

			const remaining = (moveTarget - currentCF.Position).Magnitude
			if remaining <= (tonumber(NAStuff.WaypointPathReachRadius) or 1.25) then
				reached = true
				break
			end

			speed = NAmanage.WaypointPathGetSpeed(hum)
			if speed <= 0 then
				break
			end
			const nextCF = NAmanage.WaypointPathBuildStepCFrame(currentCF, moveTarget, speed * stepRate)
			if typeof(nextCF) ~= "CFrame" then
				failed = true
				break
			end

			local moved = false
			if type(NAmanage.UG_setRootCFrame) == "function" then
				local ok, result = pcall(NAmanage.UG_setRootCFrame, root, nextCF)
				moved = ok and result ~= false
			else
				moved = pcall(function()
					root.CFrame = nextCF
				end)
			end
			if not moved then
				failed = true
				break
			end

			NAmanage.WaypointPathBrakePlanarVelocity(root)
			state.moveAccumulator -= stepRate
			steps += 1
		end

		if reached or failed then
			break
		end
	end

	state.moveAccumulator = 0
	state.moveTarget = nil
	state.moveExactTarget = nil
	return reached
end

NAmanage.WaypointPathNormalizeMode = NAmanage.WaypointPathNormalizeMode or function(mode)
	const m = Lower(tostring(mode or "walk"))
	if m == "walking" or m == "cframe" or m == "cframewalk" or m == "cframe-walk" then
		return "walk"
	elseif m == "tp" or m == "instant" then
		return "teleport"
	elseif m == "tw" then
		return "tween"
	end
	if m == "tween" or m == "teleport" or m == "walk" then
		return m
	end
	return "walk"
end

NAmanage.WaypointPathModeTitle = NAmanage.WaypointPathModeTitle or function(mode)
	mode = NAmanage.WaypointPathNormalizeMode(mode)
	if mode == "tween" then
		return "Tween"
	elseif mode == "teleport" then
		return "Teleport"
	end
	return "Walking"
end

NAmanage.WaypointPathSetRootCFrame = NAmanage.WaypointPathSetRootCFrame or function(root, cf)
	if not (root and root.Parent and typeof(cf) == "CFrame") then
		return false
	end
	if type(NAmanage.UG_setRootCFrame) == "function" then
		local ok, result = pcall(NAmanage.UG_setRootCFrame, root, cf)
		if ok and result ~= false then
			return true
		end
	end
	return pcall(function()
		root.CFrame = cf
	end)
end

NAmanage.WaypointPathTeleportMoveTo = function(hum, position, token, timeoutSeconds, exactTarget)
	if not (hum and hum.Parent and typeof(position) == "Vector3") then
		return false
	end
	const state = NAmanage.WaypointPathGetState()
	if state.token ~= token or hum.Health <= 0 then
		return false
	end
	local _, root = NAmanage.WaypointPathGetRoot()
	const currentCF = NAmanage.WaypointPathGetClientCFrame(root)
	const moveTarget = NAmanage.WaypointPathGetMoveTarget(root, position, exactTarget)
	if typeof(currentCF) ~= "CFrame" or typeof(moveTarget) ~= "Vector3" then
		return false
	end
	const targetCF = CFrame.new(moveTarget) * (currentCF - currentCF.Position)
	if not NAmanage.WaypointPathSetRootCFrame(root, targetCF) then
		return false
	end
	NAmanage.WaypointPathBrakePlanarVelocity(root)
	const delayTime = math.clamp(tonumber(NAStuff.WaypointPath_TeleportDelay) or 0.25, 0, 10)
	if delayTime > 0 then
		const stopAt = os.clock() + math.min(delayTime, math.max(tonumber(timeoutSeconds) or 8, 0.05))
		while os.clock() < stopAt do
			if state.token ~= token or not hum.Parent or hum.Health <= 0 then
				return false
			end
			Wait(math.max(0.01, math.min(0.05, stopAt - os.clock())))
		end
	end
	return state.token == token and hum.Parent ~= nil and hum.Health > 0
end

NAmanage.WaypointPathTweenMoveTo = function(hum, position, token, timeoutSeconds, exactTarget)
	if not (hum and hum.Parent and typeof(position) == "Vector3") then
		return false
	end
	const state = NAmanage.WaypointPathGetState()
	local _, root = NAmanage.WaypointPathGetRoot()
	const currentCF = NAmanage.WaypointPathGetClientCFrame(root)
	const moveTarget = NAmanage.WaypointPathGetMoveTarget(root, position, exactTarget)
	if not (root and root.Parent and typeof(currentCF) == "CFrame" and typeof(moveTarget) == "Vector3") then
		return false
	end
	const speed = math.clamp(tonumber(NAStuff.WaypointPath_TweenSpeed) or 24, 1, 500)
	const distance = (moveTarget - currentCF.Position).Magnitude
	if distance <= (tonumber(NAStuff.WaypointPathReachRadius) or 1.25) then
		return true
	end
	const targetCF = CFrame.new(moveTarget) * (currentCF - currentCF.Position)
	const duration = math.max(distance / speed, 0.03)
	const timeoutAt = os.clock() + math.max(tonumber(timeoutSeconds) or 8, duration + 1)
	local tweenSvc = Services.TweenService
	if not tweenSvc and type(SafeGetService) == "function" then
		tweenSvc = SafeGetService("TweenService")
	end
	if typeof(tweenSvc) ~= "Instance" then
		return NAmanage.WaypointPathCFrameMoveTo(hum, position, token, timeoutSeconds, exactTarget)
	end
	local tween = nil
	const okCreate = pcall(function()
		tween = tweenSvc:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { CFrame = targetCF })
	end)
	if not okCreate or not tween then
		return NAmanage.WaypointPathCFrameMoveTo(hum, position, token, timeoutSeconds, exactTarget)
	end
	local completed = false
	local conn = nil
	pcall(function()
		conn = tween.Completed:Connect(function()
			completed = true
		end)
	end)
	pcall(function()
		tween:Play()
	end)
	while os.clock() < timeoutAt do
		if state.token ~= token or not hum.Parent or hum.Health <= 0 then
			pcall(function() tween:Cancel() end)
			if conn then pcall(function() conn:Disconnect() end) end
			return false
		end
		const cfNow = NAmanage.WaypointPathGetClientCFrame(root)
		if typeof(cfNow) == "CFrame" and (moveTarget - cfNow.Position).Magnitude <= (tonumber(NAStuff.WaypointPathReachRadius) or 1.25) then
			if conn then pcall(function() conn:Disconnect() end) end
			NAmanage.WaypointPathBrakePlanarVelocity(root)
			return true
		end
		if completed then
			break
		end
		if Services.RunService and Services.RunService.Heartbeat then
			Services.RunService.Heartbeat:Wait()
		else
			Wait()
		end
	end
	if conn then pcall(function() conn:Disconnect() end) end
	NAmanage.WaypointPathBrakePlanarVelocity(root)
	const finalCF = NAmanage.WaypointPathGetClientCFrame(root)
	return typeof(finalCF) == "CFrame" and (moveTarget - finalCF.Position).Magnitude <= math.max(2, tonumber(NAStuff.WaypointPathReachRadius) or 1.25)
end

NAmanage.WaypointPathMoveTo = function(hum, position, token, timeoutSeconds, exactTarget, mode)
	mode = NAmanage.WaypointPathNormalizeMode(mode)
	if mode == "tween" then
		return NAmanage.WaypointPathTweenMoveTo(hum, position, token, timeoutSeconds, exactTarget)
	elseif mode == "teleport" then
		return NAmanage.WaypointPathTeleportMoveTo(hum, position, token, timeoutSeconds, exactTarget)
	end
	return NAmanage.WaypointPathCFrameMoveTo(hum, position, token, timeoutSeconds, exactTarget)
end

NAmanage.WaypointPathFollow = function(rawName, opts)
	opts = type(opts) == "table" and opts or {}
	local name, cf, err = NAmanage.WaypointPathResolve(rawName)
	if err then
		if opts.silent ~= true then
			DoNotif(err, 3)
		end
		return false
	end
	const state = NAmanage.WaypointPathGetState()
	const mode = NAmanage.WaypointPathNormalizeMode(opts.mode or (opts.loopOwned == true and state.loopMode) or "walk")
	if opts.loopOwned ~= true and state.looping == true then
		state.loopToken = (tonumber(state.loopToken) or 0) + 1
		state.looping = false
		state.loopTarget = nil
		state.loopMode = nil
	end
	state.token = (tonumber(state.token) or 0) + 1
	const token = state.token
	state.following = true
	state.followTarget = name
	state.followMode = mode
	state.followCharacter = LocalPlayer and LocalPlayer.Character or nil
	state.lastFollowOutcome = "running"
	state.enabled = true
	NAmanage.WaypointPathSyncUI()
	if opts.silent ~= true then
		DebugNotif(("Pathfinding to waypoint '%s' (%s)."):format(name, NAmanage.WaypointPathModeTitle(mode)), 2)
	end
	Spawn(function()
		local attempts = 0
		while attempts < 4 do
			attempts += 1
			if state.token ~= token then
				return
			end
			local waypoints, computeErr = NAmanage.WaypointPathCompute(cf)
			if not waypoints then
				state.following = false
				state.followTarget = nil
				state.lastFollowOutcome = "failed"
				NAmanage.WaypointPathSyncUI()
				if opts.silent ~= true then
					DoNotif(computeErr or "Pathfinding failed.", 3)
				end
				return
			end
			NAmanage.WaypointPathDraw(name, waypoints)
			local _, routeRoot = NAmanage.WaypointPathGetRoot()
			const routePosition = NAmanage.WaypointPathGetClientPosition(routeRoot)
			const firstWaypoint = waypoints[1]
			if typeof(routePosition) == "Vector3" and firstWaypoint and typeof(firstWaypoint.Position) == "Vector3" then
				state.pathHeightOffset = routePosition.Y - firstWaypoint.Position.Y
			else
				state.pathHeightOffset = 0
			end
			local completedRoute = true
			for waypointIndex, waypoint in waypoints do
				if state.token ~= token then
					return
				end
				local hum = nil
				if type(getHum) == "function" then
					hum = getHum()
				end
				if not hum or not hum.Parent or hum.Health <= 0 then
					state.lastFollowOutcome = "interrupted"
					completedRoute = false
					break
				end
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					if hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum.FloorMaterial ~= Enum.Material.Air then
						if type(NAmanage.LaunchHumanoid) == "function" then
							NAmanage.LaunchHumanoid(hum)
						else
							hum.Jump = true
						end
					end
				end
				const exactTarget = waypointIndex == #waypoints and cf.Position or nil
				const reached = NAmanage.WaypointPathMoveTo(hum, waypoint.Position, token, 8, exactTarget, mode)
				if reached == false then
					completedRoute = false
					break
				end
			end
			local _, root = NAmanage.WaypointPathGetRoot()
			if state.token ~= token then
				return
			end
			const clientPosition = NAmanage.WaypointPathGetClientPosition(root)
			if completedRoute and typeof(clientPosition) == "Vector3" and (clientPosition - cf.Position).Magnitude <= 8 then
				state.following = false
				state.followTarget = nil
				state.lastFollowOutcome = "reached"
				NAmanage.WaypointPathSyncUI()
				if opts.silent ~= true then
					DebugNotif(("Reached waypoint '%s'."):format(name), 2)
				end
				return
			end
			Wait()
		end
		if state.token == token then
			state.following = false
			state.followTarget = nil
			if state.lastFollowOutcome ~= "interrupted" then
				state.lastFollowOutcome = "failed"
			end
			NAmanage.WaypointPathSyncUI()
			if opts.silent ~= true then
				DoNotif(("Pathfind to waypoint '%s' stopped; route may be blocked."):format(name), 3)
			end
		end
	end)
	return true
end

NAmanage.WaypointPathLoopStart = NAmanage.WaypointPathLoopStart or function(rawName, mode)
	local name, _, err = NAmanage.WaypointPathResolve(rawName)
	if err then
		DoNotif(err:gsub("pathfindwaypoint", "looppath"), 3)
		return false
	end
	mode = NAmanage.WaypointPathNormalizeMode(mode or NAStuff.WaypointPath_LoopMode or "walk")
	NAmanage.WaypointPathStop(true)
	const state = NAmanage.WaypointPathGetState()
	state.loopToken = (tonumber(state.loopToken) or 0) + 1
	const loopToken = state.loopToken
	state.looping = true
	state.loopTarget = name
	state.loopMode = mode
	NAStuff.WaypointPath_LoopMode = mode
	if type(NAmanage.SaveESPSettings) == "function" then
		pcall(NAmanage.SaveESPSettings)
	end
	state.lastFollowOutcome = "waiting"
	state.enabled = true
	NAmanage.WaypointPathSyncUI()
	DebugNotif(("Loop-pathing to waypoint '%s' with %s. It will resume after respawn."):format(name, NAmanage.WaypointPathModeTitle(mode)), 3)
	Spawn(function()
		local observedCharacter = nil
		local retryAt = 0
		while state.looping == true and state.loopToken == loopToken and state.loopTarget == name do
			if Waypoints[name] == nil then
				state.looping = false
				state.loopTarget = nil
				state.lastFollowOutcome = "stopped"
				NAmanage.WaypointPathSyncUI()
				DoNotif(("Loop path stopped because waypoint '%s' was removed."):format(name), 3)
				break
			end
			const character = LocalPlayer and LocalPlayer.Character or nil
			local hum, root = NAmanage.WaypointPathGetRoot()
			if character ~= observedCharacter then
				observedCharacter = character
				if state.following == true then
					state.token = (tonumber(state.token) or 0) + 1
					state.following = false
					state.followTarget = nil
				end
				state.lastFollowOutcome = "waiting"
				retryAt = 0
			end
			const alive = character ~= nil
				and hum ~= nil
				and hum.Parent ~= nil
				and hum.Health > 0
				and root ~= nil
				and root.Parent ~= nil
			if alive then
				const outcome = state.lastFollowOutcome
				const retryable = outcome == "waiting" or outcome == "failed" or outcome == "interrupted"
				if state.following ~= true and retryable and os.clock() >= retryAt then
					retryAt = os.clock() + 0.75
					NAmanage.WaypointPathFollow(name, { loopOwned = true; silent = true; mode = state.loopMode or mode })
				end
			else
				if state.following == true then
					state.token = (tonumber(state.token) or 0) + 1
					state.following = false
					state.followTarget = nil
				end
				state.lastFollowOutcome = "waiting"
			end
			Wait(0.15)
		end
	end)
	return true
end

NAmanage.WaypointPathLoopStop = NAmanage.WaypointPathLoopStop or function(silent)
	const state = NAmanage.WaypointPathGetState()
	const wasLooping = state.looping == true
	if wasLooping then
		NAmanage.WaypointPathStop(true)
	end
	if silent ~= true then
		DebugNotif(wasLooping and "Loop path stopped." or "No loop path is active.", 2)
	end
	return wasLooping
end

NAmanage.WaypointPathToggle = NAmanage.WaypointPathToggle or function(rawName)
	const name = NAmanage.waypointNameFromArgs(rawName)
	if not name or name == "" then
		DoNotif("Usage: pathfindwaypoint <name...>", 3)
		return
	end
	const state = NAmanage.WaypointPathGetState()
	if (state.following == true and state.followTarget == name)
		or (state.looping == true and state.loopTarget == name) then
		NAmanage.WaypointPathStop(false)
		return
	end
	NAmanage.WaypointPathFollow(name)
end

NAmanage.WaypointPathIsModeToken = NAmanage.WaypointPathIsModeToken or function(value)
	const raw = Lower(tostring(value or ""))
	return raw == "tween" or raw == "tw" or raw == "teleport" or raw == "tp" or raw == "instant"
		or raw == "walk" or raw == "walking" or raw == "cframe" or raw == "cframewalk" or raw == "cframe-walk"
end

NAmanage.WaypointPathParseLoopArgs = NAmanage.WaypointPathParseLoopArgs or function(...)
	const args = {...}
	local mode = nil
	if #args > 0 and NAmanage.WaypointPathIsModeToken(args[1]) then
		mode = NAmanage.WaypointPathNormalizeMode(args[1])
		table.remove(args, 1)
	end
	if #args > 0 and NAmanage.WaypointPathIsModeToken(args[#args]) then
		mode = NAmanage.WaypointPathNormalizeMode(args[#args])
		table.remove(args, #args)
	end
	return NAmanage.waypointNameFromArgs(unpack(args)), mode
end

NAmanage.WaypointPathPromptLoopMode = NAmanage.WaypointPathPromptLoopMode or function(name)
	if not name or name == "" then
		DoNotif("Usage: looppath <waypoint name...>", 3)
		return
	end
	Window({
		Title = "Loop Path Method",
		Description = "Waypoint: "..tostring(name),
		Buttons = {
			{ Text = "Tween", Callback = function() NAmanage.WaypointPathLoopStart(name, "tween") end },
			{ Text = "Teleport", Callback = function() NAmanage.WaypointPathLoopStart(name, "teleport") end },
			{ Text = "Walking", Callback = function() NAmanage.WaypointPathLoopStart(name, "walk") end },
		}
	})
end

cmd.add({"showpathwaypoint", "showpathwp", "pathwaypoint", "pathwp", "showwppath"}, {"showpathwaypoint <name...>", "Show PathfindingService route nodes to a saved waypoint"}, function(...)
	const name = NAmanage.waypointNameFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: showpathwaypoint <name...>", 3)
		return
	end
	NAmanage.WaypointPathShow(name)
end, true)

cmd.add({"hidepathwaypoint", "hidepathwp", "unpathwaypoint", "unpathwp", "stoppathwaypoint", "stoppathwp"}, {"hidepathwaypoint", "Hide waypoint path route nodes and stop waypoint pathfinding"}, function()
	NAmanage.WaypointPathStop(false)
end)

cmd.add({"pathfindwaypoint", "pathfindwp", "pfwaypoint", "pfwp"}, {"pathfindwaypoint <name...>", "Pathfind to a saved waypoint and show the route nodes"}, function(...)
	const name = NAmanage.waypointNameFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: pathfindwaypoint <name...>", 3)
		return
	end
	NAmanage.WaypointPathFollow(name)
end, true)

cmd.add({"looppath", "looppathwaypoint", "loopwaypoint", "loopwp"}, {"looppath [tween|teleport|walk] <waypoint name...>", "Continuously path to a saved waypoint after death or respawn"}, function(...)
	local name, mode = NAmanage.WaypointPathParseLoopArgs(...)
	if not name or name == "" then
		DoNotif("Usage: looppath [tween|teleport|walk] <waypoint name...>", 3)
		return
	end
	if mode then
		NAmanage.WaypointPathLoopStart(name, mode)
	else
		NAmanage.WaypointPathPromptLoopMode(name)
	end
end, true)

cmd.add({"looptweenpath", "looptweenwp", "tweenlooppath"}, {"looptweenpath <waypoint name...>", "Loop path to a waypoint using tween movement"}, function(...)
	const name = NAmanage.waypointNameFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: looptweenpath <waypoint name...>", 3)
		return
	end
	NAmanage.WaypointPathLoopStart(name, "tween")
end, true)

cmd.add({"loopteleportpath", "looptppath", "looptpwp", "tplooppath"}, {"loopteleportpath <waypoint name...>", "Loop path to a waypoint by teleporting between route nodes"}, function(...)
	const name = NAmanage.waypointNameFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: loopteleportpath <waypoint name...>", 3)
		return
	end
	NAmanage.WaypointPathLoopStart(name, "teleport")
end, true)

cmd.add({"loopwalkpath", "loopwalkwp", "walklooppath"}, {"loopwalkpath <waypoint name...>", "Loop path to a waypoint using walking movement"}, function(...)
	const name = NAmanage.waypointNameFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: loopwalkpath <waypoint name...>", 3)
		return
	end
	NAmanage.WaypointPathLoopStart(name, "walk")
end, true)

cmd.add({"unlooppath", "stoplooppath", "nolooppath", "unloopwp"}, {"unlooppath", "Stop persistent waypoint pathfinding"}, function()
	NAmanage.WaypointPathLoopStop(false)
end)

cmd.add({"looppathtweenspeed", "looppathspeed", "pathloopspeed"}, {"looppathtweenspeed <speed>", "Set loop path tween speed in studs per second"}, function(speed)
	const rawValue = tonumber(speed)
	if not rawValue then
		DoNotif("Usage: looppathtweenspeed <1-500>", 3)
		return
	end
	const value = math.clamp(rawValue, 1, 500)
	NAStuff.WaypointPath_TweenSpeed = value
	if type(NAmanage.SaveESPSettings) == "function" then
		pcall(NAmanage.SaveESPSettings)
	end
	DebugNotif(("Loop path tween speed set to %s studs/s."):format(tostring(value)), 2)
end, true)

cmd.add({"looppathteleportdelay", "looppathtpdelay", "pathloopdelay"}, {"looppathteleportdelay <seconds>", "Set loop path teleport delay between route nodes"}, function(delay)
	const rawValue = tonumber(delay)
	if not rawValue then
		DoNotif("Usage: looppathteleportdelay <0-10>", 3)
		return
	end
	const value = math.clamp(rawValue, 0, 10)
	NAStuff.WaypointPath_TeleportDelay = value
	if type(NAmanage.SaveESPSettings) == "function" then
		pcall(NAmanage.SaveESPSettings)
	end
	DebugNotif(("Loop path teleport delay set to %s seconds."):format(tostring(value)), 2)
end, true)

cmd.add({"setwaypoint","setwp"},{"setwaypoint <name...> [x y z]", "Store your current position, or create/update with custom coordinates"},function(...)
	local name, x, y, z = NAmanage.WaypointNameAndCoordinatesFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: setwaypoint <name...> [x y z]")
		return
	end
	local cf
	const usedCustomCoords = x and y and z
	if usedCustomCoords then
		cf = NAmanage.WaypointCFrameWithPosition(x, y, z, NAmanage.WaypointEntryToCFrame(Waypoints[name]))
	else
		cf = NAmanage.WaypointGetCurrentCFrame()
	end
	if not cf then
		DoNotif(usedCustomCoords and "Waypoint coordinates are invalid." or "Unable to get your character's position.")
		return
	end
	NAmanage.WaypointSet(name, cf, usedCustomCoords and "from custom coordinates" or nil)
end,true)

cmd.add({"setwaypointpos","setwppos","waypointpos","wppos","editwaypoint","editwp"},{"setwaypointpos <name...> <x> <y> <z>", "Create or edit a waypoint using custom coordinates"},function(...)
	local name, x, y, z = NAmanage.WaypointNameAndCoordinatesFromArgs(...)
	if not name or name == "" or not (x and y and z) then
		DoNotif("Usage: setwaypointpos <name...> <x> <y> <z>")
		return
	end
	const cf = NAmanage.WaypointCFrameWithPosition(x, y, z, NAmanage.WaypointEntryToCFrame(Waypoints[name]))
	NAmanage.WaypointSet(name, cf, "from custom coordinates")
end,true)

cmd.add({"gotowaypoint","gotowp"},{"gotowaypoint <name...>", "Teleport to a saved waypoint"},function(...)
	const name = NAmanage.waypointNameFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: gotowaypoint <name...>")
		return
	end
	const entry = Waypoints[name]
	if not entry then
		DoNotif(("No such waypoint '%s'."):format(name))
		return
	end
	const cf = NAmanage.WaypointEntryToCFrame(entry)
	if typeof(cf) ~= "CFrame" then
		DoNotif(("Waypoint '%s' is invalid."):format(name))
		return
	end
	local char = getChar()
	if not char then
		char = LocalPlayer and LocalPlayer.Character or nil
		if not char and LocalPlayer then
			char = LocalPlayer.CharacterAdded:Wait()
		end
	end
	if not char then
		DoNotif("Unable to get your character.")
		return
	end
	NAmanage.UG_pivotModel(char, cf)
	DebugNotif(("Teleported to waypoint '%s'."):format(name))
end,true)

cmd.add({"removewaypoint","removewp","rwp"},{"removewaypoint <name...>", "Remove a saved waypoint"},function(...)
	const name = NAmanage.waypointNameFromArgs(...)
	if not name or name == "" then
		DoNotif("Usage: removewaypoint <name...>")
		return
	end

	if Waypoints[name] then
		const pathState = NAmanage.WaypointPathGetState and NAmanage.WaypointPathGetState()
		if pathState and (pathState.followTarget == name or pathState.lastName == name) and type(NAmanage.WaypointPathStop) == "function" then
			NAmanage.WaypointPathStop(true)
		end
		Waypoints[name] = nil
		NAmanage.SaveWaypoints()
		NAmanage.UpdateWaypointList()
		DebugNotif(("Waypoint '%s' removed."):format(name))
	else
		DoNotif(("No such waypoint '%s'."):format(name))
	end
end,true)

debugUI, debugDock, isMinimized = nil, nil, false

cmd.add({"chardebug","cdebug"},{"chardebug (cdebug)","debug your character"},function()
	const CONN_KEY = "CharDebug"
	const RENDER_BIND = "CharDebug"

	const CoreGui = SafeGetService("CoreGui")

	const UI_BASE = Vector2.new(860, 520)
	const HEADER_H = 48
	const TAB_H = 36
	const BG_COLOR = Color3.fromRGB(20, 20, 20)
	const PANEL_BG = Color3.fromRGB(26, 26, 26)
	const ACCENT = Color3.fromRGB(95, 165, 255)
	const UPDATE_RATE = 1/30
	const MAX_LOGS = 600

	const LocalPlayer = Services.Players.LocalPlayer
	local paused = false
	local fps, fpsAlpha, dtAcc = 0, 0, 0
	local lastDt = UPDATE_RATE
	local activeTab = "Overview"
	local logs, errCount, warnCount, infoCount = {}, 0, 0, 0

	const cam = Services.Workspace.CurrentCamera
	const vp = cam and cam.ViewportSize or Vector2.new(1920,1080)
	const w = math.min(UI_BASE.X, vp.X * (IsOnMobile and 0.96 or 0.7))
	const h = math.min(UI_BASE.Y, vp.Y * (IsOnMobile and 0.86 or 0.75))
	const UI_SIZE = Vector2.new(w, h)

	if debugUI then
		if debugDock then
			pcall(function() debugDock:Destroy() end)
			debugDock = nil
		end
		debugUI:Destroy()
		debugUI = nil
		NAlib.disconnect(CONN_KEY)
		__lt.cm("RunService", "UnbindFromRenderStep", RENDER_BIND)
		return
	end

	const function velOf(r)
		if not r then return Vector3.zero end
		local v = NAlib.isProperty(r,"AssemblyLinearVelocity") or Vector3.zero
		if v.Magnitude == 0 and NAlib.isProperty(r,"Velocity") then v = r.Velocity end
		return v
	end
	const function angVelOf(r)
		if not r then return Vector3.zero end
		local v = NAlib.isProperty(r,"AssemblyAngularVelocity") or Vector3.zero
		if NAlib.isProperty(r,"RotVelocity") then v = r.RotVelocity end
		return v
	end
	const function char() return LocalPlayer.Character end
	const function hum() const c=char() return c and getHum() or nil end
	const function root(c)
		c = c or char()
		return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")) or nil
	end
	const function raycastDown(origin, dist)
		const params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		const c = char()
		params.FilterDescendantsInstances = c and {c} or {}
		return Services.Workspace:Raycast(origin, Vector3.new(0,-math.abs(dist or 1000),0), params)
	end
	const function getPingMs()
		local ok,ms = pcall(function()
			if NAmanage.GetDataPingMs then
				return NAmanage.GetDataPingMs()
			end
			return nil
		end)
		if ok then return ms end
		return nil
	end
	const function getMem()
		local ok,total = pcall(function() return __lt.cm("Stats", "GetTotalMemoryUsageMb") end)
		const tags = {"Internal","Instances","Signals","Physics","GraphicsTexture","LuaHeap","HttpCache","Animation","Pathfinding","Sounds","Terrain","Navigation"}
		const map = {}
		if ok then map.Total = total end
		for _,t in tags do
			local ok2,val = pcall(function() return __lt.cm("Stats", "GetMemoryUsageMbForTag", t) end)
			if ok2 then map[t] = val end
		end
		return map
	end
	const function pushLog(msg, t)
		const tag = tostring(t)
		if tag:find("Error") then errCount += 1 elseif tag:find("Warning") then warnCount += 1 else infoCount += 1 end
		Insert(logs, os.date("%X").." | "..tag.." | "..msg)
		if #logs > MAX_LOGS then table.remove(logs,1) end
	end

	const function NewI(c) return InstanceNew(c) end
	const function new(class, props) const inst = NewI(class) for k,v in props do inst[k] = v end return inst end

	debugUI = new("ScreenGui",{Name="CharDebugUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1000})
	pcall(function() NAgui.NaProtectUI(debugUI) end)

	const window = new("Frame",{Name="Window", Size=UDim2.fromOffset(UI_SIZE.X, UI_SIZE.Y), Position=UDim2.new(0.5,-UI_SIZE.X/2,0.5,-UI_SIZE.Y/2), BackgroundColor3=BG_COLOR, BorderSizePixel=0, ClipsDescendants=true, Parent=debugUI, ZIndex=10})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=window})
	new("UIStroke",{Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=Color3.fromRGB(35,35,35),Parent=window})

	const hdr = new("Frame",{Name="Header", Size=UDim2.new(1,0,0,HEADER_H), BackgroundColor3=BG_COLOR, BorderSizePixel=0, Parent=window, ZIndex=50})
	const hdrStroke = new("UIStroke",{Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=Color3.fromRGB(45,45,45),Parent=hdr})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=hdr})

	const title = new("TextLabel",{Name="Title", Size=UDim2.new(0.5,-12,1,0), Position=UDim2.new(0,12,0,0), BackgroundTransparency=1, Font=Enum.Font.Code, TextSize=18, TextColor3=Color3.new(1,1,1), TextXAlignment=Enum.TextXAlignment.Left, Text="Character Debug", Parent=hdr, ZIndex=60})

	const right = new("Frame",{Name="Right", AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-8,0,6), Size=UDim2.new(0,0,1,-12), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X, Parent=hdr, ZIndex=60})
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Right,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,6),Parent=right})

	const platformStr = tostring(__lt.cm("UserInputService", "GetPlatform"))
	const status = new("TextLabel",{Name="Status", Size=UDim2.fromOffset(210,HEADER_H-16), BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(30,30,30), Font=Enum.Font.Code, TextSize=14, TextColor3=Color3.fromRGB(230,230,230), TextXAlignment=Enum.TextXAlignment.Center, Text="FPS: -- | Ping: -- | "..platformStr, Parent=right, ZIndex=61})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=status})
	const btnPause = new("TextButton",{Name="Pause", Size=UDim2.fromOffset(74,HEADER_H-16), BackgroundColor3=ACCENT, AutoButtonColor=true, TextColor3=Color3.new(1,1,1), Text="Pause", Font=Enum.Font.Code, TextSize=16, Parent=right, ZIndex=61})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=btnPause})
	const btnMin = new("TextButton",{Name="Min", Size=UDim2.fromOffset(44,HEADER_H-16), BackgroundColor3=Color3.fromRGB(45,45,45), AutoButtonColor=true, TextColor3=Color3.new(1,1,1), Text="–", Font=Enum.Font.Code, TextSize=20, Parent=right, ZIndex=61})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=btnMin})
	const btnClose = new("TextButton",{Name="Close", Size=UDim2.fromOffset(44,HEADER_H-16), BackgroundColor3=Color3.fromRGB(140,55,55), AutoButtonColor=true, TextColor3=Color3.new(1,1,1), Text="×", Font=Enum.Font.Code, TextSize=20, Parent=right, ZIndex=61})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=btnClose})

	NAgui.draggerV2(window, hdr)

	const tabbar = new("ScrollingFrame",{Name="Tabs", Size=UDim2.new(1,0,0,TAB_H), Position=UDim2.new(0,0,0,HEADER_H), BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0, Parent=window, ScrollingDirection=Enum.ScrollingDirection.X, ScrollBarThickness=IsOnMobile and 10 or 6, Active=true, CanvasSize=UDim2.new(), ZIndex=30})
	const tabsHolder = new("Frame",{Name="Holder", BackgroundTransparency=1, Size=UDim2.new(0,0,1,0), Parent=tabbar, ZIndex=31})
	const uilist = new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),HorizontalAlignment=Enum.HorizontalAlignment.Left,VerticalAlignment=Enum.VerticalAlignment.Center,Parent=tabsHolder})

	const content = new("Frame",{Name="Content", Size=UDim2.new(1,0,1,-(HEADER_H+TAB_H)), Position=UDim2.new(0,0,0,HEADER_H+TAB_H), BackgroundTransparency=1, BorderSizePixel=0, Parent=window, ZIndex=20})
	const cardsScroll = new("ScrollingFrame",{Name="CardsScroll", Active=true, ScrollingDirection=Enum.ScrollingDirection.Y, ScrollBarThickness=IsOnMobile and 10 or 6, BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.fromScale(1,1), Parent=content, ZIndex=21})
	new("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingTop=UDim.new(0,12),Parent=cardsScroll})
	const cardsHolder = new("Frame",{Name="CardsHolder", BackgroundTransparency=1, Size=UDim2.new(1,-24,0,0), Position=UDim2.new(0,12,0,12), Parent=cardsScroll, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=22})
	const grid = new("UIGridLayout",{Parent=cardsHolder, CellPadding=UDim2.new(0,10,0,10), StartCorner=Enum.StartCorner.TopLeft, SortOrder=Enum.SortOrder.LayoutOrder})
	grid.CellSize = IsOnMobile and UDim2.new(1,-10,0,86) or UDim2.new(0.5,-10,0,86)
	cardsScroll.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 24)

	const logsHolder = new("Frame",{Name="LogsHolder", BackgroundTransparency=1, Visible=false, Size=UDim2.fromScale(1,1), Parent=content, ZIndex=21})
	const panel = new("Frame",{Name="LogPanel", BackgroundColor3=PANEL_BG, BorderSizePixel=0, Parent=logsHolder, Size=UDim2.new(1,-24,1,-24), Position=UDim2.new(0,12,0,12), ZIndex=22})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=panel})
	new("UIStroke",{Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=Color3.fromRGB(40,40,40),Parent=panel})
	const counts = new("TextLabel",{Name="Counts", BackgroundTransparency=1, Position=UDim2.new(0,10,0,8), Size=UDim2.new(1,-20,0,18), Font=Enum.Font.Code, TextSize=14, TextColor3=Color3.fromRGB(200,200,200), TextXAlignment=Enum.TextXAlignment.Left, Text="Info:0  Warn:0  Error:0", Parent=panel, ZIndex=23})
	const logScroll = new("ScrollingFrame",{Name="Scroll", Active=true, ScrollBarThickness=IsOnMobile and 10 or 6, ScrollingDirection=Enum.ScrollingDirection.Y, BackgroundTransparency=1, BorderSizePixel=0, Size=UDim2.new(1,-20,1,-40), Position=UDim2.new(0,10,0,30), Parent=panel, ZIndex=23})
	const logText = new("TextLabel",{Name="Text", BackgroundTransparency=1, Size=UDim2.new(1,-4,0,0), Position=UDim2.new(0,2,0,0), Font=Enum.Font.Code, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, TextWrapped=false, TextScaled=false, TextSize=14, TextColor3=Color3.fromRGB(230,230,230), Text="", Parent=logScroll, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=23})
	new("UITextSizeConstraint",{Parent=logText, MaxTextSize=18, MinTextSize=12})

	const tabsList = {"Overview","Movement","Humanoid","Camera","World","Network","Memory","Anim","Tools","Inputs","Physics","Perf","Logs"}
	const tabBtns = {}
	for _, name in tabsList do
		const b = new("TextButton",{Name=name, Size=UDim2.fromOffset(126, TAB_H-10), BackgroundColor3=(name==activeTab) and ACCENT or Color3.fromRGB(45,45,45), AutoButtonColor=true, TextColor3=Color3.new(1,1,1), Text=name, Font=Enum.Font.Code, TextSize=14, Parent=tabsHolder, ZIndex=32})
		new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=b})
		tabBtns[name] = b
	end

	debugDock = new("ScreenGui",{Name="CharDebugDock",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=1100})
	pcall(function() NAgui.NaProtectUI(debugDock) end)
	const dock = new("Frame",{Name="Dock", Size=UDim2.fromOffset(IsOnMobile and 76 or 64,IsOnMobile and 76 or 64), AnchorPoint=Vector2.new(0,1), Position=UDim2.new(0,16,1,-16), BackgroundColor3=ACCENT, Visible=false, Parent=debugDock, ZIndex=100})
	new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=dock})
	const dockLabel = new("TextButton",{Name="Btn", BackgroundTransparency=1, Size=UDim2.fromScale(1,1), Text="CD", Font=Enum.Font.Code, TextSize=20, TextColor3=Color3.new(1,1,1), Parent=dock, ZIndex=101})

	NAgui.draggerV2(dock, dockLabel)

	local cards, values = {}, {}

	const function makeCard(parent, key, height)
		const f = new("Frame",{Name=key, Size=UDim2.fromOffset(400,height or 86), BackgroundColor3=PANEL_BG, BorderSizePixel=0, Parent=parent, ZIndex=22})
		new("UICorner",{CornerRadius=UDim.new(0, 6),Parent=f})
		new("UIStroke",{Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Color=Color3.fromRGB(40,40,40),Parent=f})
		new("TextLabel",{Name="Key", BackgroundTransparency=1, Position=UDim2.new(0,10,0,8), Size=UDim2.new(1,-20,0,16), Font=Enum.Font.Code, TextSize=14, TextColor3=Color3.fromRGB(180,180,180), TextXAlignment=Enum.TextXAlignment.Left, Text=key, Parent=f, ZIndex=23})
		const val = new("TextLabel",{Name="Val", BackgroundTransparency=1, Position=UDim2.new(0,10,0,28), Size=UDim2.new(1,-20,1,-36), Font=Enum.Font.Code, TextSize=16, TextColor3=Color3.new(1,1,1), TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Text="", Parent=f, ZIndex=23})
		return f, val
	end
	const function clearCards() for _,v in cards do v:Destroy() end cards, values = {}, {} end
	const function addCard(key, h)
		local card, val = makeCard(cardsHolder, key, h)
		cards[key] = card
		values[key] = val
		card.BackgroundTransparency = 0.35
		__lt.cm("TweenService", "Create", card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.15}):Play()
	end

	NAlib.connect(CONN_KEY, grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		cardsScroll.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 24)
	end))
	NAlib.connect(CONN_KEY, uilist:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		const w2 = uilist.AbsoluteContentSize.X + 12
		tabsHolder.Size = UDim2.fromOffset(w2, TAB_H)
		tabbar.CanvasSize = UDim2.fromOffset(w2 + 12, TAB_H)
	end))
	NAlib.connect(CONN_KEY, tabbar.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseWheel then
			const x = math.clamp(tabbar.CanvasPosition.X - i.Position.Z*32, 0, math.max(0, tabbar.CanvasSize.X.Offset - tabbar.AbsoluteSize.X))
			tabbar.CanvasPosition = Vector2.new(x, 0)
		end
	end))

	const function setVal(key, text) const lbl=values[key] if lbl then lbl.Text=text end end
	const function getTool() const c=char() return c and c:FindFirstChildOfClass("Tool") or nil end
	const function statsNetKbps() local i,o; local okI,vI=pcall(function() return Services.Stats.DataReceiveKbps end); if okI then i=vI end local okO,vO=pcall(function() return Services.Stats.DataSendKbps end); if okO then o=vO end return i,o end

	const function setTab(name)
		activeTab = name
		for n,b in tabBtns do __lt.cm("TweenService", "Create", b, TweenInfo.new(0.15), {BackgroundColor3 = (n==name) and ACCENT or Color3.fromRGB(45,45,45)}):Play() end
		const showLogs = (name == "Logs")
		cardsScroll.Visible = not showLogs
		logsHolder.Visible = showLogs
		if not showLogs then
			clearCards()
			if name=="Overview" then
				addCard("CharacterStatus")
				addCard("Platform")
				addCard("Username")
				addCard("UserId")
				addCard("Position")
				addCard("Velocity")
				addCard("Speed")
				addCard("AngularVel")
				addCard("Health")
				addCard("State")
				addCard("MoveDirection")
				addCard("FloorMaterial")
				addCard("Tool")
				addCard("FOV")
			elseif name=="Movement" then
				addCard("WalkSpeed")
				addCard("JumpPower")
				addCard("JumpHeight")
				addCard("HipHeight")
				addCard("AutoRotate")
				addCard("AssemblyMass")
				addCard("PlatformStand")
				addCard("Sit")
				addCard("Airborne")
			elseif name=="Humanoid" then
				addCard("RigType")
				addCard("MaxHealth")
				addCard("HealthDisplayType")
				addCard("StatesEnabled",110)
				addCard("SeatPart")
				addCard("MoveTo")
			elseif name=="Camera" then
				addCard("CameraType")
				addCard("Subject")
				addCard("SubjectDistance")
				addCard("CameraCFrame",110)
				addCard("FOV")
			elseif name=="World" then
				addCard("Gravity")
				addCard("ClockTime")
				addCard("Brightness")
				addCard("EnvSpecular")
				addCard("CurrentZone")
			elseif name=="Network" then
				addCard("Ping")
				addCard("DataInKbps")
				addCard("DataOutKbps")
			elseif name=="Memory" then
				addCard("TotalMB")
				addCard("LuaHeapMB")
				addCard("InstancesMB")
				addCard("GraphicsTextureMB")
				addCard("PhysicsMB")
				addCard("TerrainMB")
				addCard("PathfindingMB")
			elseif name=="Anim" then
				addCard("PlayingTracks",130)
			elseif name=="Tools" then
				addCard("EquippedTool")
				addCard("BackpackItems",130)
			elseif name=="Inputs" then
				addCard("KeysDown",130)
				addCard("LastInput")
			elseif name=="Physics" then
				addCard("GroundDist")
				addCard("GroundNormal")
				addCard("SlopeAngle")
				addCard("UnderPart")
				addCard("HumanoidRootCFrame",110)
				addCard("PivotOffset")
			elseif name=="Perf" then
				addCard("HeartbeatDt")
				addCard("ServerTime")
				addCard("TouchingParts")
			end
			cardsScroll.CanvasSize = UDim2.fromOffset(0, grid.AbsoluteContentSize.Y + 24)
		else
			counts.Text = Format("Info:%d  Warn:%d  Error:%d", infoCount, warnCount, errCount)
			logText.Text = (#logs>0) and Concat(logs,"\n") or ""
			const h2 = logText.TextBounds.Y
			logScroll.CanvasSize = UDim2.fromOffset(0, h2)
			logScroll.CanvasPosition = Vector2.new(0, math.max(0, h2 - logScroll.AbsoluteSize.Y))
		end
	end

	for _,b in tabBtns do
		NAlib.connect(CONN_KEY, MouseButtonFix(b, function() setTab(b.Name) end))
		NAlib.connect(CONN_KEY, b.MouseEnter:Connect(function() __lt.cm("TweenService", "Create", b, TweenInfo.new(0.12), {TextTransparency = 0.05}):Play() end))
		NAlib.connect(CONN_KEY, b.MouseLeave:Connect(function() __lt.cm("TweenService", "Create", b, TweenInfo.new(0.12), {TextTransparency = 0}):Play() end))
	end

	local pressed, lastInput = {}, "-"
	NAlib.connect(CONN_KEY, Services.UserInputService.InputBegan:Connect(function(input,gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			pressed[input.KeyCode.Name] = true
			lastInput = input.KeyCode.Name
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then lastInput = "Mouse1"
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then lastInput = "Mouse2"
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then lastInput = "Wheel" end
	end))
	NAlib.connect(CONN_KEY, Services.UserInputService.InputEnded:Connect(function(input,gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then pressed[input.KeyCode.Name] = nil end
	end))
	NAlib.connect(CONN_KEY, Services.LogService.MessageOut:Connect(function(m,t)
		pushLog(m,t)
		if activeTab=="Logs" then
			counts.Text = Format("Info:%d  Warn:%d  Error:%d", infoCount, warnCount, errCount)
			logText.Text = (#logs>0) and Concat(logs,"\n") or ""
			const h2 = logText.TextBounds.Y
			logScroll.CanvasSize = UDim2.fromOffset(0, h2)
			logScroll.CanvasPosition = Vector2.new(0, math.max(0, h2 - logScroll.AbsoluteSize.Y))
		end
	end))

	const function updateOverview(h, r)
		const c = char()
		if not c then
			setVal("CharacterStatus","No character")
		else
			const rr = root(c)
			const hh = hum()
			setVal("CharacterStatus",Format("Char OK | Humanoid:%s | Root:%s", hh and "Yes" or "No", rr and "Yes" or "No"))
		end
		setVal("Platform",platformStr.." | Mobile:"..tostring(IsOnMobile).." | PC:"..tostring(IsOnPC))
		setVal("Username", LocalPlayer and LocalPlayer.Name or "N/A")
		setVal("UserId", LocalPlayer and tostring(LocalPlayer.UserId) or "N/A")
		if r then
			const p = r.Position
			setVal("Position", Format("X: %.2f  Y: %.2f  Z: %.2f", p.X, p.Y, p.Z))
			const v = velOf(r)
			setVal("Velocity", Format("X: %.2f  Y: %.2f  Z: %.2f", v.X, v.Y, v.Z))
			setVal("Speed", Format("%.2f", v.Magnitude))
			const av = angVelOf(r)
			setVal("AngularVel", Format("X: %.2f  Y: %.2f  Z: %.2f", av.X, av.Y, av.Z))
		end
		if h then
			setVal("Health", Format("%.1f / %.1f", h.Health, h.MaxHealth))
			setVal("State", tostring(h:GetState()))
			const md = h.MoveDirection
			setVal("MoveDirection", Format("X: %.2f  Y: %.2f  Z: %.2f", md.X, md.Y, md.Z))
			setVal("FloorMaterial", tostring(h.FloorMaterial))
		end
		const t = getTool()
		setVal("Tool", t and t.Name or "None")
		const cc = Services.Workspace.CurrentCamera
		if cc then setVal("FOV", Format("%.1f", cc.FieldOfView)) end
	end
	const function updateMovement(h, r)
		if h then
			setVal("WalkSpeed", Format("%.2f", h.WalkSpeed))
			setVal("JumpPower", Format("%.2f", h.JumpPower))
			local okJH, jh = pcall(function() return h.JumpHeight end)
			setVal("JumpHeight", okJH and Format("%.2f", jh) or "N/A")
			setVal("HipHeight", Format("%.2f", h.HipHeight))
			setVal("AutoRotate", tostring(h.AutoRotate))
			setVal("PlatformStand", tostring(h.PlatformStand))
			setVal("Sit", tostring(h.Sit))
			const st = h:GetState()
			const airborne = st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Jumping
			setVal("Airborne", tostring(airborne))
		end
		if r then setVal("AssemblyMass", Format("%.2f", r.AssemblyMass)) end
	end
	const function updateHumanoid(h)
		if not h then return end
		setVal("RigType", tostring(h.RigType))
		setVal("MaxHealth", Format("%.1f", h.MaxHealth))
		setVal("HealthDisplayType", tostring(h.HealthDisplayType))
		const states = {"Running","RunningNoPhysics","Jumping","Freefall","Landed","Seated","Climbing","Swimming","FallingDown","Ragdoll","GettingUp","Flying"}
		const list = {}
		for _,s in states do local ok,val=pcall(function() return h:GetStateEnabled(Enum.HumanoidStateType[s]) end) Insert(list, Format("%s:%s", s, ok and tostring(val) or "N/A")) end
		setVal("StatesEnabled", Concat(list,"  "))
		const seat = h.SeatPart
		setVal("SeatPart", seat and seat.Name or "None")
		const mpos = h.WalkToPoint
		setVal("MoveTo", Format("X: %.1f  Y: %.1f  Z: %.1f", mpos.X, mpos.Y, mpos.Z))
	end
	const function updateCamera(_, r)
		const cc = Services.Workspace.CurrentCamera
		if not cc then return end
		setVal("CameraType", tostring(cc.CameraType))
		const subj = cc.CameraSubject
		setVal("Subject", subj and subj.Name or "None")
		if r then setVal("SubjectDistance", Format("%.2f", (cc.CFrame.Position - r.Position).Magnitude)) else setVal("SubjectDistance", "N/A") end
		const cf = cc.CFrame
		local rx,ry,rz = cf:ToOrientation()
		setVal("CameraCFrame", Format("P(%.1f,%.1f,%.1f)  R(%.2f,%.2f,%.2f)", cf.X, cf.Y, cf.Z, rx, ry, rz))
		setVal("FOV", Format("%.1f", cc.FieldOfView))
	end
	const function updateWorld()
		setVal("Gravity", Format("%.1f", Services.Workspace.Gravity))
		setVal("ClockTime", Format("%.2f", Services.Lighting.ClockTime))
		setVal("Brightness", Format("%.2f", Services.Lighting.Brightness))
		local okE, _na_env = pcall(function() return Services.Lighting.EnvironmentSpecularScale end)
		setVal("EnvSpecular", okE and Format("%.2f", _na_env) or "N/A")
		setVal("CurrentZone", "N/A")
	end
	const function updateNetwork()
		const ping = getPingMs()
		setVal("Ping", ping and Format("%.0f ms", ping) or "N/A")
		local inK, outK = statsNetKbps()
		setVal("DataInKbps", inK and Format("%.1f", inK) or "N/A")
		setVal("DataOutKbps", outK and Format("%.1f", outK) or "N/A")
	end
	const function updateMemory()
		const m = getMem()
		setVal("TotalMB", m.Total and Format("%.1f", m.Total) or "N/A")
		setVal("LuaHeapMB", m.LuaHeap and Format("%.1f", m.LuaHeap) or "N/A")
		setVal("InstancesMB", m.Instances and Format("%.1f", m.Instances) or "N/A")
		setVal("GraphicsTextureMB", m.GraphicsTexture and Format("%.1f", m.GraphicsTexture) or "N/A")
		setVal("PhysicsMB", m.Physics and Format("%.1f", m.Physics) or "N/A")
		setVal("TerrainMB", m.Terrain and Format("%.1f", m.Terrain) or "N/A")
		setVal("PathfindingMB", m.Pathfinding and Format("%.1f", m.Pathfinding) or "N/A")
	end
	const function updateAnim(h)
		if not h then setVal("PlayingTracks","None"); return end
		const animator = h:FindFirstChildOfClass("Animator")
		if not animator then setVal("PlayingTracks","None"); return end
		const tracks = animator:GetPlayingAnimationTracks()
		if #tracks == 0 then setVal("PlayingTracks","None"); return end
		const lines = {}
		for _,t in tracks do
			const name = (t.Animation and t.Animation.Name) or t.Name or "Track"
			Insert(lines, Format("%s  w=%.2f  s=%.2f", name, t.WeightCurrent or 0, t.Speed or 1))
		end
		setVal("PlayingTracks", Concat(lines,"  "))
	end
	const function updateTools()
		const t = getTool()
		setVal("EquippedTool", t and t.Name or "None")
		local items, count = {}, 0
		if LocalPlayer.Backpack then
			for _,i in LocalPlayer.Backpack:GetChildren() do
				if i:IsA("Tool") then count += 1; Insert(items, i.Name) end
			end
		end
		setVal("BackpackItems", count > 0 and Concat(items, ", ") or "None")
	end
	const function updateInputs()
		const keys = {} for k,_ in pressed do Insert(keys,k) end table.sort(keys)
		setVal("KeysDown", (#keys>0) and Concat(keys,", ") or "None")
		setVal("LastInput", lastInput or "-")
	end
	const function updatePhysics(_, r)
		if not r then
			setVal("GroundDist","N/A"); setVal("GroundNormal","N/A"); setVal("SlopeAngle","N/A"); setVal("UnderPart","N/A"); setVal("HumanoidRootCFrame","N/A"); setVal("PivotOffset","N/A")
			return
		end
		const res = raycastDown(r.Position, 1000)
		if res then
			const d = (r.Position - res.Position).Magnitude
			setVal("GroundDist", Format("%.2f", d))
			setVal("GroundNormal", Format("X: %.2f Y: %.2f Z: %.2f", res.Normal.X, res.Normal.Y, res.Normal.Z))
			const slope = math.deg(math.acos(math.clamp(res.Normal:Dot(Vector3.new(0,1,0)), -1, 1)))
			setVal("SlopeAngle", Format("%.2f°", slope))
			setVal("UnderPart", res.Instance and (res.Instance.Name.." ["..tostring(res.Material).."]") or "None")
		else
			setVal("GroundDist","--"); setVal("GroundNormal","--"); setVal("SlopeAngle","--"); setVal("UnderPart","--")
		end
		const cf = r.CFrame
		local rx,ry,rz = cf:ToOrientation()
		setVal("HumanoidRootCFrame", Format("P(%.1f,%.1f,%.1f)  R(%.2f,%.2f,%.2f)", cf.X, cf.Y, cf.Z, rx, ry, rz))
		const pv = char() and char():GetPivot() or CFrame.identity
		const d2 = cf.Position - pv.Position
		setVal("PivotOffset", Format("Δ(%.2f, %.2f, %.2f)", d2.X, d2.Y, d2.Z))
	end
	const function updatePerf()
		setVal("HeartbeatDt", Format("%.4f s", lastDt))
		setVal("ServerTime", tostring(os.time()))
		const r = root(); local n=0 if r then for _,p in r:GetTouchingParts() do n+=1 end end
		setVal("TouchingParts", tostring(n))
	end
	const function updateLogs()
		counts.Text = Format("Info:%d  Warn:%d  Error:%d", infoCount, warnCount, errCount)
		logText.Text = (#logs>0) and Concat(logs,"\n") or ""
		const h2 = logText.TextBounds.Y
		logScroll.CanvasSize = UDim2.fromOffset(0, h2)
		logScroll.CanvasPosition = Vector2.new(0, math.max(0, h2 - logScroll.AbsoluteSize.Y))
	end

	const function safeFPS(dt)
		if not dt or dt ~= dt or dt <= 0 or dt > 1 then return end
		const inst = 1/dt
		if inst ~= inst or inst == math.huge then return end
		if fpsAlpha == 0 then fps = inst; fpsAlpha = 1 else fps = fps*0.9 + inst*0.1 end
	end

	const function refresh()
		if paused then return end
		const h = hum()
		const r = root()
		if activeTab=="Overview" then updateOverview(h,r)
		elseif activeTab=="Movement" then updateMovement(h,r)
		elseif activeTab=="Humanoid" then updateHumanoid(h)
		elseif activeTab=="Camera" then updateCamera(h,r)
		elseif activeTab=="World" then updateWorld()
		elseif activeTab=="Network" then updateNetwork()
		elseif activeTab=="Memory" then updateMemory()
		elseif activeTab=="Anim" then updateAnim(h)
		elseif activeTab=="Tools" then updateTools()
		elseif activeTab=="Inputs" then updateInputs()
		elseif activeTab=="Physics" then updatePhysics(h,r)
		elseif activeTab=="Perf" then updatePerf()
		elseif activeTab=="Logs" then updateLogs()
		end
		const p = getPingMs()
		const f = (fps ~= fps or fps == math.huge or fps <= 0) and "--" or tostring(math.clamp(math.floor(fps + 0.5), 1, 999))
		const charOk = char() and "OK" or "None"
		status.Text = Format("FPS: %s | Ping: %s | Char:%s", f, p and Format("%d ms", p) or "--", charOk)
	end

	NAlib.connect(CONN_KEY, MouseButtonFix(btnPause, function()
		paused = not paused
		isMinimized = false
		btnPause.Text = paused and "Resume" or "Pause"
		__lt.cm("TweenService", "Create", btnPause, TweenInfo.new(0.12), {BackgroundColor3 = paused and Color3.fromRGB(120,120,120) or ACCENT}):Play()
	end))

	NAlib.connect(CONN_KEY, MouseButtonFix(btnMin, function()
		if window.Visible then
			isMinimized = true
			const out = __lt.cm("TweenService", "Create", window, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.fromOffset(UI_SIZE.X*0.96, UI_SIZE.Y*0.96), BackgroundTransparency = 0.4})
			out.Completed:Connect(function()
				window.Visible=false
				dock.Visible=true
				__lt.cm("TweenService", "Create", dock, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(IsOnMobile and 80 or 70,IsOnMobile and 80 or 70)}):Play()
			end)
			out:Play()
		end
	end))

	NAlib.connect(CONN_KEY, MouseButtonFix(dockLabel, function()
		if not window.Visible then
			isMinimized = false
			dock.Visible=false
			window.Visible=true
			window.Size = UDim2.fromOffset(UI_SIZE.X*0.96, UI_SIZE.Y*0.96)
			window.BackgroundTransparency = 0.4
			__lt.cm("TweenService", "Create", window, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(UI_SIZE.X, UI_SIZE.Y), BackgroundTransparency = 0}):Play()
			NAmanage.centerFrame(window)
		end
	end))

	NAlib.connect(CONN_KEY, MouseButtonFix(btnClose, function()
		if debugUI then
			debugUI:Destroy()
			debugUI = nil
		end
		if debugDock then
			debugDock:Destroy()
			debugDock = nil
		end
		NAlib.disconnect(CONN_KEY)
		__lt.cm("RunService", "UnbindFromRenderStep", RENDER_BIND)
	end))

	setTab(activeTab)

	__lt.cm("RunService", "BindToRenderStep", RENDER_BIND, Enum.RenderPriority.Last.Value, function(dt)
		lastDt = dt
		safeFPS(dt)
		dtAcc += dt
		if dtAcc < UPDATE_RATE then return end
		dtAcc = 0
		refresh()
	end)

	window.Size = UDim2.fromOffset(UI_SIZE.X*0.96, UI_SIZE.Y*0.96)
	NAmanage.centerFrame(window)
	__lt.cm("TweenService", "Create", window, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(UI_SIZE.X, UI_SIZE.Y)}):Play()
end)

cmd.add({"unchardebug","uncdebug"},{"unchardebug (uncdebug)","disable character debug"},function()
	if debugUI then
		debugUI:Destroy()
		debugUI = nil
	end
	if debugDock then
		debugDock:Destroy()
		debugDock = nil
	end
	isMinimized = false
	NAlib.disconnect("CharDebug")
	__lt.cm("RunService", "UnbindFromRenderStep", "CharDebug")
end)

cmd.add({"naked"}, {"naked", "no clothing gang"}, function()
	for _,clothes in LocalPlayer.Character:GetChildren() do
		if clothes:IsA("Shirt") or clothes:IsA("Pants") or clothes:IsA("ShirtGraphic") then
			clothes:Destroy()
		end
	end
end)

Somersault = {btn=nil, key="x", twopi=math.pi*2, flipping=false}

cmd.add({"somersault", "frontflip"}, {"somersault (frontflip)", "Makes you do a clean front flip"}, function(...)
	const function somersaulter()
		if Somersault.flipping then return end
		const c = getChar() or LocalPlayer.CharacterAdded:Wait()
		const hrp = getRoot(c)
		const hum = getHum()
		if not hrp or not hum then return end
		if hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum.FloorMaterial ~= Enum.Material.Air then
			Somersault.flipping = true
			hum.PlatformStand = true
			const axis = -hrp.CFrame.RightVector
			const angSpeed = 20
			local rotated = 0
			hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * 30 + Vector3.new(0, 30, 0)
			local conn
			conn = Services.RunService.Heartbeat:Connect(function(dt)
				if not hrp.Parent or hum.Health <= 0 then
					if conn then conn:Disconnect() end
					Somersault.flipping = false
					hum.PlatformStand = false
					return
				end
				rotated = rotated + angSpeed * dt
				if rotated >= Somersault.twopi then
					hrp.AssemblyAngularVelocity = Vector3.zero
					hum.PlatformStand = false
					hum:ChangeState(Enum.HumanoidStateType.GettingUp)
					conn:Disconnect()
					Somersault.flipping = false
				else
					hrp.AssemblyAngularVelocity = axis * angSpeed
				end
			end)
		end
	end

	if IsOnMobile then
		if Somersault.btn then
			Somersault.btn:Destroy()
			Somersault.btn = nil
		end

		Somersault.btn = InstanceNew("ScreenGui")
		const flipBtn = InstanceNew("TextButton")
		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		const aspect = InstanceNew("UIAspectRatioConstraint")

		NAgui.NaProtectUI(Somersault.btn)
		Somersault.btn.ResetOnSpawn = false

		flipBtn.Parent = Somersault.btn
		flipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		flipBtn.BackgroundTransparency = 0.1
		flipBtn.Position = UDim2.new(0.85, 0, 0.5, 0)
		flipBtn.Size = UDim2.new(0.08, 0, 0.1, 0)
		flipBtn.Font = Enum.Font.GothamBold
		flipBtn.Text = "Flip"
		flipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		flipBtn.TextSize = 18
		flipBtn.TextWrapped = true
		flipBtn.Active = true
		flipBtn.TextScaled = true

		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = flipBtn

		aspect.Parent = flipBtn
		aspect.AspectRatio = 1.0

		NAmanage.Wrap(function()
			MouseButtonFix(flipBtn, function()
				somersaulter()
			end)
		end)()

		NAgui.draggerV2(flipBtn)
	else
		NAlib.disconnect("somersault_key")
		NAlib.connect("somersault_key", mouse.KeyDown:Connect(function(KEY)
			if KEY:lower() == Somersault.key then
				somersaulter()
			end
		end))

		DoNotif("Press '"..Somersault.key:upper().."' to flip!", 3)
	end
end, false)

cmd.add({"unsomersault", "unfrontflip"}, {"unsomersault (unfrontflip)", "Disable somersault button and keybind"}, function(...)
	if Somersault.btn then
		Somersault.btn:Destroy()
		Somersault.btn = nil
	end
	NAlib.disconnect("somersault_key")
end, false)

StaffRoles = {"owner", "admin", "staff", "mod", "founder", "manager", "dev", "president", "leader", "supervis", "chairman", "executive", "director", "management", "chairwoman", "chairperson"}

function IsStaff(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") or not player.Parent then
		return false, ""
	end
	local role = ""
	local okEmployee, isEmployee = pcall(player.IsInGroup, player, 1200769)
	if okEmployee and isEmployee then
		return true, "Roblox Employee"
	end
	local ok, currentRole = pcall(function()
		if not player.Parent then
			return ""
		end
		return player:GetRoleInGroup(game.CreatorId)
	end)
	if ok and currentRole then
		role = currentRole
	end
	const lowered = Lower(role)
	for _, staffRole in StaffRoles do
		if lowered:find(staffRole) then
			return true, role
		end
	end
	return false, role
end

groupRole = function(player)
	const info = {Role = "Guest", IsStaff = false}
	local isStaff, role = IsStaff(player)
	if role ~= nil and role ~= "" then
		info.Role = role
	end
	info.IsStaff = isStaff
	return info
end
NAmanage.IsStaff = IsStaff

NAStuff.StaffwatchState = NAStuff.StaffwatchState or {
	markers = {};
	charConnections = {};
	notified = {};
	staffPlayers = {};
}
NAStuff.StaffwatchState.staffPlayers = type(NAStuff.StaffwatchState.staffPlayers) == "table" and NAStuff.StaffwatchState.staffPlayers or {}
if NAStuff.StaffwatchIgnoreLocal == nil then
	NAStuff.StaffwatchIgnoreLocal = true
end
if NAStuff.StaffwatchHighlightEnabled == nil then
	NAStuff.StaffwatchHighlightEnabled = true
end
if NAStuff.StaffwatchOverrideESP == nil then
	NAStuff.StaffwatchOverrideESP = true
end

NAmanage.StaffwatchKey = function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return nil
	end
	return tostring(player.UserId)
end

NAmanage.StaffwatchMarkerText = function(info)
	local role = type(info) == "table" and tostring(info.Role or "") or ""
	if role == "" or role == "Guest" then
		role = "Staff"
	end
	return "STAFF\n"..role
end

NAmanage.StaffwatchStoreVisual = function(inst, fallback)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	pcall(function()
		NAmanage.SetAttr(inst, "NA_StaffwatchVisual", true)
	end)
	if type(NAmanage.Helper_StoreInstance) == "function" then
		local ok, parent = pcall(NAmanage.Helper_StoreInstance, inst)
		if ok and parent then
			return parent
		end
	end
	if not inst.Parent then
		inst.Parent = fallback or Services.Workspace.CurrentCamera
	end
	return inst.Parent
end

NAmanage.StaffwatchClearMarker = function(playerOrKey)
	const state = NAStuff.StaffwatchState
	if type(state) ~= "table" then
		return
	end
	const key = typeof(playerOrKey) == "Instance" and NAmanage.StaffwatchKey(playerOrKey) or tostring(playerOrKey or "")
	if key == "" then
		return
	end
	const marker = state.markers and state.markers[key]
	if typeof(marker) == "Instance" then
		pcall(function()
			marker:Destroy()
		end)
	elseif type(marker) == "table" then
		for _, field in { "highlight", "billboard", "label" } do
			const inst = marker[field]
			if typeof(inst) == "Instance" then
				pcall(function()
					inst:Destroy()
				end)
			end
			marker[field] = nil
		end
	end
	if state.markers then
		state.markers[key] = nil
	end
end

NAmanage.StaffwatchClearPlayer = function(playerOrKey)
	const state = NAStuff.StaffwatchState
	if type(state) ~= "table" then
		return
	end
	const directPlayer = typeof(playerOrKey) == "Instance" and playerOrKey:IsA("Player") and playerOrKey or nil
	const key = directPlayer and NAmanage.StaffwatchKey(directPlayer) or tostring(playerOrKey or "")
	if key == "" then
		return
	end
	local player = directPlayer
	if not player then
		const userId = tonumber(key)
		if userId and userId > 0 then
			pcall(function()
				player = Services.Players:GetPlayerByUserId(userId)
			end)
		end
	end
	if type(state.staffPlayers) == "table" then
		state.staffPlayers[key] = nil
	end
	NAmanage.StaffwatchClearMarker(key)
	const conn = state.charConnections and state.charConnections[key]
	if conn then
		pcall(function()
			conn:Disconnect()
		end)
	end
	if state.charConnections then
		state.charConnections[key] = nil
	end
	if state.notified then
		state.notified[key] = nil
	end
	if player and player ~= Services.Players.LocalPlayer and NAStuff.StaffwatchOverrideESP ~= false and (ESPPlayersEnabled or chamsEnabled) then
		Defer(function()
			if not (player and player.Parent) or NAmanage.ESP_IsStaffwatchOwnedPlayer(player) then
				return
			end
			NAmanage.ESP_SetupPlayerWatch(player)
			if NAmanage.ESP_ShouldTrackPlayer(player) then
				NAmanage.ESP_RequestReattachPlayer(player, true)
			end
		end)
	end
end

NAmanage.StaffwatchClearAll = function()
	NAlib.disconnect("staffNotifier")
	NAlib.disconnect("staffNotifierRemoving")
	const state = NAStuff.StaffwatchState
	if type(state) ~= "table" then
		NAStuff.StaffwatchState = { markers = {}, charConnections = {}, notified = {}, staffPlayers = {} }
		return
	end
	state.active = false
	for key in state.markers or {} do
		NAmanage.StaffwatchClearPlayer(key)
	end
	for key in state.charConnections or {} do
		NAmanage.StaffwatchClearPlayer(key)
	end
	state.notified = {}
	state.staffPlayers = {}
end

NAmanage.StaffwatchClearHighlights = function()
	const state = NAStuff.StaffwatchState
	if type(state) ~= "table" then
		return
	end
	for _, marker in state.markers or {} do
		if type(marker) == "table" and typeof(marker.highlight) == "Instance" then
			pcall(function()
				marker.highlight:Destroy()
			end)
			marker.highlight = nil
		end
	end
end

NAmanage.StaffwatchRefreshMarkers = function()
	if not (NAStuff.StaffwatchState and NAStuff.StaffwatchState.active) then
		return
	end
	for _, player in Services.Players:GetPlayers() do
		NAmanage.StaffwatchHandlePlayer(player, false)
	end
end

NAmanage.StaffwatchEnsureMarker = function(player, info)
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		return
	end
	local state = NAStuff.StaffwatchState
	if type(state) ~= "table" then
		state = { markers = {}, charConnections = {}, notified = {}, staffPlayers = {} }
		NAStuff.StaffwatchState = state
	end
	state.markers = type(state.markers) == "table" and state.markers or {}
	state.charConnections = type(state.charConnections) == "table" and state.charConnections or {}
	state.notified = type(state.notified) == "table" and state.notified or {}
	state.staffPlayers = type(state.staffPlayers) == "table" and state.staffPlayers or {}

	const key = NAmanage.StaffwatchKey(player)
	if not key then
		return
	end
	if not state.charConnections[key] then
		state.charConnections[key] = player.CharacterAdded:Connect(function()
			Defer(function()
				if NAStuff.StaffwatchState and NAStuff.StaffwatchState.active then
					NAmanage.StaffwatchHandlePlayer(player, false)
				end
			end)
		end)
	end

	local char, anchor = nil, nil
	local char = player.Character
	local anchor = char and (getHead(char) or getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
	if not (typeof(char) == "Instance" and char.Parent) then
		return
	end
	local marker = state.markers[key]
	if typeof(marker) == "Instance" then
		pcall(function()
			marker:Destroy()
		end)
		marker = nil
	end
	if type(marker) ~= "table" then
		marker = {}
		state.markers[key] = marker
	end
	marker.player = player
	marker.info = info

	local billboard = marker.billboard
	if anchor and not (typeof(billboard) == "Instance" and billboard.Parent) then
		billboard = InstanceNew("BillboardGui")
		marker.billboard = billboard
		billboard.Name = "NA_StaffwatchMarker"
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.new(0, 150, 0, 42)
		billboard.StudsOffset = Vector3.new(0, 3.35, 0)
		billboard.MaxDistance = 250
		NAmanage.StaffwatchStoreVisual(billboard, Services.Workspace.CurrentCamera or char)

		const label = InstanceNew("TextLabel")
		marker.label = label
		label.Name = "Label"
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.GothamBlack
		const markerColor = NAmanage.StaffwatchGetMarkerColor()
		label.TextColor3 = markerColor
		label.TextStrokeColor3 = NAmanage.SpecialMarkerStrokeColor(markerColor)
		label.TextStrokeTransparency = 0
		label.TextSize = 14
		label.TextWrapped = true
		label.Parent = billboard

		const stroke = InstanceNew("UIStroke")
		stroke.Color = NAmanage.StaffwatchGetMarkerColor()
		stroke.Transparency = 1
		stroke.Thickness = 1
		stroke.Parent = label

		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = label
	elseif billboard then
		marker.label = marker.label or billboard:FindFirstChildWhichIsA("TextLabel")
	end
	if billboard and anchor then
		billboard.Adornee = anchor
		NAmanage.StaffwatchStoreVisual(billboard, Services.Workspace.CurrentCamera or char)
	end
	if marker.label then
		marker.label.Text = NAmanage.StaffwatchMarkerText(info)
		marker.label.BackgroundTransparency = 1
		const markerColor = NAmanage.StaffwatchGetMarkerColor()
		marker.label.TextColor3 = markerColor
		marker.label.TextStrokeColor3 = NAmanage.SpecialMarkerStrokeColor(markerColor)
		marker.label.TextStrokeTransparency = 0
		const stroke = marker.label:FindFirstChildWhichIsA("UIStroke")
		if stroke then
			stroke.Color = markerColor
			stroke.Transparency = 1
		end
	end

	if NAStuff.StaffwatchHighlightEnabled == false then
		if typeof(marker.highlight) == "Instance" then
			pcall(function()
				marker.highlight:Destroy()
			end)
			marker.highlight = nil
		end
		return
	end

	local highlight = marker.highlight
	if not (typeof(highlight) == "Instance" and highlight.Parent) then
		local ok, hl = pcall(InstanceNew, "Highlight")
		if ok and hl then
			highlight = hl
			marker.highlight = highlight
			highlight.Name = "NA_StaffwatchHighlight"
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			const markerColor = NAmanage.StaffwatchGetMarkerColor()
			highlight.FillColor = markerColor
			highlight.OutlineColor = NAmanage.SpecialMarkerOutlineColor(markerColor)
			highlight.FillTransparency = 0.72
			highlight.OutlineTransparency = 0
			NAmanage.StaffwatchStoreVisual(highlight, Services.Workspace.CurrentCamera or char)
		end
	end
	if highlight then
		const markerColor = NAmanage.StaffwatchGetMarkerColor()
		highlight.FillColor = markerColor
		highlight.OutlineColor = NAmanage.SpecialMarkerOutlineColor(markerColor)
		highlight.Adornee = char
		highlight.Enabled = true
	end
end

NAmanage.StaffwatchNotify = function(player, info)
	local state = NAStuff.StaffwatchState
	if type(state) ~= "table" then
		state = { markers = {}, charConnections = {}, notified = {}, staffPlayers = {} }
		NAStuff.StaffwatchState = state
	end
	state.notified = type(state.notified) == "table" and state.notified or {}
	const key = NAmanage.StaffwatchKey(player)
	if not key or state.notified[key] then
		return false
	end
	state.notified[key] = true
	local role = type(info) == "table" and tostring(info.Role or "Staff") or "Staff"
	if role == "" or role == "Guest" then
		role = "Staff"
	end
	DoNotif("Staff detected: "..nameChecker(player).." ("..role..")", 6, "Staffwatch")
	return true
end

NAmanage.StaffwatchHandlePlayer = function(player, shouldNotify)
	if player == LocalPlayer and NAStuff.StaffwatchIgnoreLocal ~= false then
		NAmanage.StaffwatchClearPlayer(player)
		return {Role = "LocalPlayer", IsStaff = false, Ignored = true}
	end
	const info = groupRole(player)
	if info.IsStaff then
		local state = NAStuff.StaffwatchState
		if type(state) ~= "table" then
			state = { markers = {}, charConnections = {}, notified = {}, staffPlayers = {} }
			NAStuff.StaffwatchState = state
		end
		state.staffPlayers = type(state.staffPlayers) == "table" and state.staffPlayers or {}
		const key = NAmanage.StaffwatchKey(player)
		if key then
			state.staffPlayers[key] = true
		end
		if NAStuff.StaffwatchOverrideESP ~= false then
			const model = player and player.Character
			if model and espCONS[model] then
				NAmanage.ESP_ClearModel(model)
			end
		end
		NAmanage.StaffwatchEnsureMarker(player, info)
		if shouldNotify then
			NAmanage.StaffwatchNotify(player, info)
		end
	else
		NAmanage.StaffwatchClearPlayer(player)
	end
	return info
end

NAStuff.RolewatchData = NAStuff.RolewatchData or {Group = 0, Role = "", RoleLower = "", Leave = false}
NAStuff.RolewatchConnection = NAStuff.RolewatchConnection or nil

function NAmanage.joinRolewatchName(...)
	const pieces = {}
	for i = 1, select("#", ...) do
		const part = select(i, ...)
		if type(part) == "string" and part ~= "" then
			pieces[#pieces + 1] = part
		end
	end
	if #pieces == 0 then
		return nil
	end
	const combined = Concat(pieces, " "):match("^%s*(.-)%s*$")
	return combined ~= "" and combined or nil
end

function NAmanage.handleRolewatchPlayer(player)
	const data = NAStuff.RolewatchData
	if not player or player == LocalPlayer or not data then
		return
	end
	if data.Group == 0 or data.RoleLower == "" then
		return
	end
	local okGroup, inGroup = pcall(player.IsInGroup, player, data.Group)
	if not (okGroup and inGroup) then
		return
	end
	local okRole, playerRole = pcall(player.GetRoleInGroup, player, data.Group)
	if not (okRole and type(playerRole) == "string") then
		return
	end
	if playerRole:lower() ~= data.RoleLower then
		return
	end
	const message = Format("Player \"%s\" joined with role \"%s\".", player.Name, playerRole)
	if data.Leave then
		DoNotif(message, 4, "Rolewatch")
		local exitSucceeded = false
		if cmd and cmd.run then
			const ok = pcall(function()
				cmd.run({"exit"})
			end)
			exitSucceeded = ok
		end
		if not exitSucceeded and LocalPlayer then
			LocalPlayer:Kick(Format("\n\nRolewatch\n%s\n", message))
		end
		return
	end
	DoNotif(message, 4, "Rolewatch")
end

function NAmanage.ensureRolewatchListener()
	if NAStuff.RolewatchConnection then
		return
	end
	NAStuff.RolewatchConnection = Services.Players.PlayerAdded:Connect(NAmanage.handleRolewatchPlayer)
end

NAmanage.ensureRolewatchListener()

cmd.add({"rolewatch"}, {"rolewatch <groupId> <role name>", "Notify if someone from a watched group joins with a specific role"}, function(groupIdArg, ...)
	const groupId = tonumber(groupIdArg)
	const roleName = NAmanage.joinRolewatchName(...)
	if not groupId or not roleName then
		DoNotif("Usage: rolewatch <groupId> <role name>", 4, "Rolewatch")
		return
	end
	const data = NAStuff.RolewatchData
	data.Group = groupId
	data.Role = roleName
	data.RoleLower = roleName:lower()
	DoNotif(Format("Watching group %d for role \"%s\".", groupId, roleName), 3, "Rolewatch")
end, true)

cmd.add({"rolewatchstop"}, {"rolewatchstop", "Disable Rolewatch monitoring"}, function()
	const data = NAStuff.RolewatchData
	data.Group = 0
	data.Role = ""
	data.RoleLower = ""
	data.Leave = false
	DoNotif("Rolewatch disabled.", 3, "Rolewatch")
end)

cmd.add({"rolewatchleave", "unrolewatch"}, {"rolewatchleave (unrolewatch)", "Toggle leaving the server if the watched role joins"}, function()
	const data = NAStuff.RolewatchData
	data.Leave = not data.Leave
	const stateText = data.Leave and "Leave enabled. You will leave if the watched role joins." or "Leave disabled."
	DoNotif(stateText, 3, "Rolewatch")
end)

cmd.add({"joingroup", "groupjoin"}, {"joingroup [groupId] (groupjoin)", "Open the Pedoblox join prompt for a group"}, function(groupIdArg)
	const supplied = tostring(groupIdArg or "")
	const hasInput = supplied ~= ""
	local targetId = tonumber(groupIdArg)

	if hasInput and (not targetId or targetId <= 0) then
		DoNotif("Please provide a valid numeric group id.", 4)
		return
	end

	if not targetId or targetId <= 0 then
		if game.CreatorType == Enum.CreatorType.Group and tonumber(game.CreatorId) then
			targetId = tonumber(game.CreatorId)
		else
			DoNotif("Provide a group id; this game is not owned by a group.", 4)
			return
		end
	end

	const groupService = SafeGetService("GroupService",false)
	if not groupService or type(groupService.PromptJoinAsync) ~= "function" then
		DoNotif("GroupService.PromptJoinAsync is unavailable.", 4)
		return
	end

	local ok, res = pcall(function()
		return groupService:PromptJoinAsync(targetId)
	end)

	if ok then
		const groupName = res and res.Name or ("group "..tostring(targetId))
		DebugNotif("Join prompt opened for "..groupName, 3)
	else
		DebugNotif("Failed to open join prompt: "..tostring(res), 4)
	end
end)

cmd.add({"trackstaff", "staffwatch"}, {"trackstaff (staffwatch)", "Track, highlight, and notify when a staff member joins the server"}, function()
	NAmanage.StaffwatchClearAll()

	if game.CreatorType == Enum.CreatorType.Group then
		NAStuff.StaffwatchState.active = true
		NAlib.connect("staffNotifier", Services.Players.PlayerAdded:Connect(function(player)
			NAmanage.StaffwatchHandlePlayer(player, true)
		end))
		NAlib.connect("staffNotifierRemoving", Services.Players.PlayerRemoving:Connect(function(player)
			NAmanage.StaffwatchClearPlayer(player)
		end))
		Spawn(function()
			local staffCount = 0
			const scanStart = os.clock()
			const players = Services.Players:GetPlayers()
			for i, player in players do
				if not (NAStuff.StaffwatchState and NAStuff.StaffwatchState.active) then
					return
				end
				local okInfo, info = pcall(NAmanage.StaffwatchHandlePlayer, player, true)
				if okInfo and type(info) == "table" and info.IsStaff then
					staffCount += 1
				end
				if i % 2 == 0 or IsOnMobile == true then
					Wait()
				end
			end
			const perf = NAStuff and NAStuff.StartupPerformance
			if type(perf) == "table" and perf.finished ~= true then
				perf.staffwatchScanElapsed = os.clock() - scanStart
				perf.staffwatchScanPlayers = #players
			end
			if NAStuff.StaffwatchState and NAStuff.StaffwatchState.active then
				const status = staffCount == 0 and "Tracking enabled - no staff detected" or ("Tracking enabled - "..staffCount.." staff detected")
				DoNotif(status, 4, "Staffwatch")
			end
		end)
	else
		DoNotif("Game is not owned by a Group", 4, "Staffwatch")
	end
end)

cmd.add({"stoptrackstaff", "untrackstaff", "unstaffwatch"}, {"stoptrackstaff (untrackstaff, unstaffwatch)", "Stop tracking staff members"}, function()
	NAmanage.StaffwatchClearAll()
	DoNotif("Tracking disabled", 3, "Staffwatch")
end)

NAStuff.AntiStaffState = NAStuff.AntiStaffState or {
	active = false;
	mode = "serverhop";
	triggered = false;
	token = 0;
}

NAmanage.AntiStaffNormalizeMode = function(mode)
	const normalized = Lower(tostring(mode or "")):gsub("[%s_%-%+]+", "")
	if normalized == "" or normalized == "serverhop" or normalized == "hop" or normalized == "shop" or normalized == "advanced" or normalized == "advancedserverhop" then
		return "serverhop"
	end
	if normalized == "leave" or normalized == "exit" or normalized == "shutdown" then
		return "leave"
	end
	return nil
end

NAmanage.AntiStaffStop = function()
	NAlib.disconnect("antiStaffNotifier")
	local state = NAStuff.AntiStaffState
	if type(state) ~= "table" then
		state = { active = false; mode = "serverhop"; triggered = false; token = 0; }
		NAStuff.AntiStaffState = state
	end
	state.active = false
	state.triggered = false
	state.token = (tonumber(state.token) or 0) + 1
end

NAmanage.AntiStaffAct = function(player, info)
	const state = NAStuff.AntiStaffState
	if type(state) ~= "table" or state.active ~= true or state.triggered == true then
		return false
	end

	state.triggered = true
	const token = tonumber(state.token) or 0
	local role = type(info) == "table" and tostring(info.Role or "Staff") or "Staff"
	if role == "" or role == "Guest" then
		role = "Staff"
	end
	const detectedName = nameChecker(player)

	if state.mode == "leave" then
		DoNotif("Staff detected: "..detectedName.." ("..role.."). Leaving server.", 6, "Anti Staff")
		local exited = false
		if cmd and type(cmd.run) == "function" then
			exited = pcall(function()
				cmd.run({"exit"})
			end)
		end
		if not exited then
			exited = pcall(function()
				game:Shutdown()
			end)
		end
		if not exited and LocalPlayer then
			pcall(function()
				LocalPlayer:Kick("\n\nAnti Staff\nStaff detected: "..detectedName.." ("..role..")\n")
			end)
		end
		return true
	end

	DoNotif("Staff detected: "..detectedName.." ("..role.."). Starting advanced serverhop.", 6, "Anti Staff")
	Spawn(function()
		local ok, success, reason = pcall(function()
			if type(NAmanage.ServerhopAdvanced) ~= "function" then
				return false, "advanced serverhop is unavailable"
			end
			return NAmanage.ServerhopAdvanced()
		end)
		if not ok then
			reason = success
			success = false
		end
		if success ~= true and state.active == true and (tonumber(state.token) or 0) == token then
			state.triggered = false
			DoNotif("Advanced serverhop failed"..(reason and (": "..tostring(reason)) or "")..". Monitoring remains enabled.", 5, "Anti Staff")
		end
	end)
	return true
end

NAmanage.AntiStaffHandlePlayer = function(player)
	if typeof(player) ~= "Instance" or not player:IsA("Player") or not player.Parent then
		return false
	end
	if player == LocalPlayer and NAStuff.StaffwatchIgnoreLocal ~= false then
		return false
	end
	local ok, info = pcall(groupRole, player)
	if not ok or type(info) ~= "table" or info.IsStaff ~= true then
		return false
	end
	return NAmanage.AntiStaffAct(player, info)
end

NAmanage.AntiStaffStart = function(mode)
	const normalizedMode = NAmanage.AntiStaffNormalizeMode(mode)
	if not normalizedMode then
		DoNotif("Usage: antistaff [leave/serverhop]", 4, "Anti Staff")
		return false
	end

	NAmanage.AntiStaffStop()
	if game.CreatorType ~= Enum.CreatorType.Group then
		DoNotif("Game is not owned by a Group", 4, "Anti Staff")
		return false
	end

	const state = NAStuff.AntiStaffState
	state.active = true
	state.mode = normalizedMode
	state.triggered = false
	state.token = (tonumber(state.token) or 0) + 1
	const token = state.token

	NAlib.connect("antiStaffNotifier", Services.Players.PlayerAdded:Connect(function(player)
		Spawn(function()
			if state.active == true and state.token == token and state.triggered ~= true then
				NAmanage.AntiStaffHandlePlayer(player)
			end
		end)
	end))

	Spawn(function()
		const players = Services.Players:GetPlayers()
		for index, player in players do
			if state.active ~= true or state.token ~= token or state.triggered == true then
				return
			end
			if NAmanage.AntiStaffHandlePlayer(player) then
				return
			end
			if index % 2 == 0 or IsOnMobile == true then
				Wait()
			end
		end
		if state.active == true and state.token == token and state.triggered ~= true then
			const actionText = normalizedMode == "leave" and "leave" or "advanced serverhop"
			DoNotif("Enabled - will "..actionText.." when staff is detected.", 4, "Anti Staff")
		end
	end)
	return true
end

cmd.add({"antistaff", "staffescape", "staffavoid"}, {"antistaff [leave/serverhop] (staffescape, staffavoid)", "Automatically leave or advanced-serverhop when staff is detected"}, function(mode)
	NAmanage.AntiStaffStart(mode)
end)

cmd.add({"unantistaff", "unstaffescape", "unstaffavoid"}, {"unantistaff (unstaffescape, unstaffavoid)", "Disable automatic staff avoidance"}, function()
	NAmanage.AntiStaffStop()
	DoNotif("Disabled", 3, "Anti Staff")
end)

NAStuff.Rewind = NAStuff.Rewind or {
	Enabled = false;
	Key = Enum.KeyCode.R;
	Seconds = 120;
	Speed = 1;
	History = {};
	IsRewinding = false;
	LastCharacter = nil;
	AnimateOriginalDisabled = nil;
	MobileActive = false;
	MobileGui = nil;
	MobileButton = nil;
}

NAmanage.RewindState = function()
	local state = NAStuff.Rewind
	if type(state) ~= "table" then
		state = {}
		NAStuff.Rewind = state
	end
	state.Key = typeof(state.Key) == "EnumItem" and state.Key or Enum.KeyCode.R
	state.Seconds = math.max(1, math.min(600, math.floor(tonumber(state.Seconds) or 120)))
	state.Speed = math.max(1, math.min(60, math.floor(tonumber(state.Speed) or 1)))
	if type(state.History) ~= "table" then
		state.History = {}
	end
	state.MobileActive = state.MobileActive == true
	if typeof(state.MobileGui) ~= "Instance" then
		state.MobileGui = nil
	end
	if typeof(state.MobileButton) ~= "Instance" then
		state.MobileButton = nil
	end
	return state
end

NAmanage.RewindSyncMobileButton = function()
	const state = NAmanage.RewindState()
	const button = state.MobileButton
	if typeof(button) ~= "Instance" or not button.Parent then
		return
	end
	const active = state.MobileActive == true
	button.Text = active and "STOP" or "REW"
	button.BackgroundColor3 = active and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
end

NAmanage.RewindSetMobileActive = function(active)
	const state = NAmanage.RewindState()
	state.MobileActive = active == true and state.Enabled == true
	NAmanage.RewindSyncMobileButton()
end

NAmanage.RewindDestroyMobileButton = function()
	const state = NAmanage.RewindState()
	state.MobileActive = false
	if typeof(state.MobileGui) == "Instance" then
		pcall(function()
			state.MobileGui:Destroy()
		end)
	end
	state.MobileGui = nil
	state.MobileButton = nil
end
