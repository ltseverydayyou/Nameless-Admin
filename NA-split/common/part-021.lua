NAmanage.Commands_UpdateExpandedMetrics = function(state)
	if type(state) ~= "table" then
		return
	end
	state.expandedIndex = nil
	state.expandedExtra = 0
	const expandedName = tostring(state.expandedName or "")
	if expandedName == "" then
		state.expandedName = nil
		return
	end
	for index, entry in state.filteredEntries or {} do
		if entry and tostring(entry.name or "") == expandedName then
			state.expandedIndex = index
			state.expandedExtra = 44
			return
		end
	end
	state.expandedName = nil
end

NAStuff.CommandInlineTweens = type(NAStuff.CommandInlineTweens) == "table" and NAStuff.CommandInlineTweens or setmetatable({}, { __mode = "k" })

NAmanage.Commands_StopInlineTween = function(object)
	if not object then
		return
	end
	const tween = NAStuff.CommandInlineTweens and NAStuff.CommandInlineTweens[object]
	if tween then
		pcall(function()
			tween:Cancel()
		end)
		NAStuff.CommandInlineTweens[object] = nil
	end
end

NAmanage.Commands_TweenInline = function(object, goals, duration)
	if not (object and type(goals) == "table") then
		return false
	end
	NAmanage.Commands_StopInlineTween(object)
	if not Services.TweenService then
		for property, value in goals do
			pcall(function()
				object[property] = value
			end)
		end
		return false
	end
	local ok, tween = pcall(function()
		return Services.TweenService:Create(
			object,
			TweenInfo.new(tonumber(duration) or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			goals
		)
	end)
	if not (ok and tween) then
		for property, value in goals do
			pcall(function()
				object[property] = value
			end)
		end
		return false
	end
	NAStuff.CommandInlineTweens[object] = tween
	tween:Play()
	return true
end

NAmanage.Commands_SetInlineExpanded = function(state, commandName, expanded)
	if type(state) ~= "table" then
		return false
	end
	commandName = tostring(commandName or "")
	if commandName == "" then
		return false
	end
	const previousName = state.expandedName
	local nextName = previousName
	if expanded == true then
		nextName = commandName
	elseif expanded == false then
		if tostring(previousName or "") == commandName then
			nextName = nil
		end
	else
		if tostring(previousName or "") == commandName then
			nextName = nil
		else
			nextName = commandName
		end
	end
	if previousName == nextName then
		return false
	end
	state.expandedName = nextName
	state.commandExpansionAnimation = {
		openingName = nextName and tostring(nextName) ~= tostring(previousName or "") and tostring(nextName) or nil;
		closingName = previousName and tostring(previousName) ~= tostring(nextName or "") and tostring(previousName) or nil;
		duration = 0.25;
		started = false;
	}
	NAmanage.Commands_UpdateExpandedMetrics(state)
	if NAUIMANAGER.description then
		NAUIMANAGER.description.Visible = false
		NAUIMANAGER.description.Text = ""
	end
	if type(NAmanage.syncVisibleCommandRows) == "function" then
		NAmanage.syncVisibleCommandRows(state)
	end
	return true
end

function createCommandListLabel(state)
	const label = NAUIMANAGER.commandExample:Clone()
	label.ClipsDescendants = true

	const title = InstanceNew("TextLabel", label)
	title.Name = "CommandTitle"
	title.BackgroundTransparency = 1
	title.BorderSizePixel = 0
	title.Position = UDim2.fromOffset(0, 0)
	title.Size = UDim2.new(1, 0, 0, state.templateHeight or 32)
	title.FontFace = label.FontFace
	title.TextSize = label.TextSize
	title.TextScaled = label.TextScaled
	title.TextWrapped = label.TextWrapped
	title.TextXAlignment = label.TextXAlignment
	title.TextYAlignment = label.TextYAlignment
	title.TextTruncate = label.TextTruncate
	title.RichText = label.RichText
	title.TextColor3 = label.TextColor3
	title.TextStrokeColor3 = label.TextStrokeColor3
	title.TextStrokeTransparency = label.TextStrokeTransparency
	title.ZIndex = label.ZIndex + 1
	label.TextTransparency = 1

	const clickTarget = InstanceNew("TextButton", label)
	clickTarget.Name = "CommandClickTarget"
	clickTarget.BackgroundTransparency = 1
	clickTarget.BorderSizePixel = 0
	clickTarget.AutoButtonColor = false
	clickTarget.Active = true
	clickTarget.Text = ""
	clickTarget.Position = UDim2.fromOffset(0, 0)
	clickTarget.Size = UDim2.new(1, 0, 0, state.templateHeight or 32)
	clickTarget.ZIndex = label.ZIndex + 3

	const expansion = InstanceNew("Frame", label)
	expansion.Name = "CommandExpansion"
	expansion.BackgroundTransparency = 1
	expansion.BorderSizePixel = 0
	expansion.ClipsDescendants = true
	expansion.Position = UDim2.new(0, 8, 0, (state.templateHeight or 32) + 4)
	expansion.Size = UDim2.new(1, -16, 0, 36)
	expansion.Visible = false
	expansion.ZIndex = label.ZIndex + 2

	const divider = InstanceNew("Frame", expansion)
	divider.Name = "Divider"
	divider.BorderSizePixel = 0
	divider.BackgroundColor3 = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	divider.BackgroundTransparency = 0.45
	divider.Position = UDim2.new(0, 0, 0, 0)
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.ZIndex = expansion.ZIndex

	const argsBox = InstanceNew("TextBox", expansion)
	argsBox.Name = "Arguments"
	argsBox.BorderSizePixel = 0
	argsBox.BackgroundColor3 = Color3.fromRGB(24, 25, 33)
	argsBox.BackgroundTransparency = 0.08
	argsBox.ClearTextOnFocus = false
	argsBox.PlaceholderText = "Enter arguments..."
	argsBox.PlaceholderColor3 = Color3.fromRGB(145, 148, 162)
	argsBox.Text = ""
	argsBox.TextColor3 = Color3.fromRGB(235, 237, 244)
	argsBox.TextSize = 14
	argsBox.TextXAlignment = Enum.TextXAlignment.Left
	argsBox.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	argsBox.Position = UDim2.new(0, 0, 0, 7)
	argsBox.Size = UDim2.new(1, -78, 0, 28)
	argsBox.ZIndex = expansion.ZIndex + 1
	InstanceNew("UICorner", argsBox).CornerRadius = UDim.new(0, 5)
	const argsStroke = InstanceNew("UIStroke", argsBox)
	argsStroke.Name = "UIStroker"
	argsStroke.Thickness = 1
	argsStroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	argsStroke.Transparency = 0.38
	argsStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	const argsPadding = InstanceNew("UIPadding", argsBox)
	argsPadding.PaddingLeft = UDim.new(0, 8)
	argsPadding.PaddingRight = UDim.new(0, 8)

	const runButton = InstanceNew("TextButton", expansion)
	runButton.Name = "Run"
	runButton.BorderSizePixel = 0
	runButton.BackgroundColor3 = Color3.fromRGB(48, 42, 68)
	runButton.BackgroundTransparency = 0.08
	runButton.AutoButtonColor = false
	runButton.Active = true
	runButton.Text = "Run"
	runButton.TextColor3 = Color3.fromRGB(242, 243, 248)
	runButton.TextSize = 14
	runButton.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	runButton.AnchorPoint = Vector2.new(1, 0)
	runButton.Position = UDim2.new(1, 0, 0, 7)
	runButton.Size = UDim2.new(0, 70, 0, 28)
	runButton.ZIndex = expansion.ZIndex + 1
	InstanceNew("UICorner", runButton).CornerRadius = UDim.new(0, 5)
	const runStroke = InstanceNew("UIStroke", runButton)
	runStroke.Name = "UIStroker"
	runStroke.Thickness = 1
	runStroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	runStroke.Transparency = 0.28
	runStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	argsBox:GetPropertyChangedSignal("Text"):Connect(function()
		state.inlineArguments = state.inlineArguments or {}
		const commandName = tostring(NAmanage.GetAttr(label, "CmdName") or "")
		if commandName ~= "" then
			state.inlineArguments[commandName] = argsBox.Text
		end
	end)

	runButton.Activated:Connect(function()
		const commandName = tostring(NAmanage.GetAttr(label, "CmdName") or label.Name or "")
		const requiresArguments = NAmanage.GetAttr(label, "CmdRequiresArguments") == true
		if commandName ~= "" and tostring(state.expandedName or "") == commandName then
			NAmanage.Commands_SetInlineExpanded(state, commandName, false)
		end
		NAmanage.Commands_RunInline(commandName, requiresArguments and argsBox.Text or "")
	end)

	clickTarget.Activated:Connect(function()
		if NAmanage.Commands_SyncHiddenState and not NAmanage.Commands_SyncHiddenState({ responsive = false; syncRows = false }) then
			return
		end
		const commandName = tostring(NAmanage.GetAttr(label, "CmdName") or label.Name or "")
		if commandName == "" then
			return
		end
		NAmanage.Commands_SetInlineExpanded(state, commandName, tostring(state.expandedName or "") ~= commandName)
	end)

	clickTarget.MouseEnter:Connect(function()
		if NAmanage.Commands_SyncHiddenState and not NAmanage.Commands_SyncHiddenState({ responsive = false; syncRows = false }) then
			return
		end
		const desc = NAmanage.GetAttr(label, "CmdDesc")
		if type(desc) == "string" and desc ~= "" then
			NAUIMANAGER.description.Visible = true
			NAUIMANAGER.description.Text = desc
		else
			NAUIMANAGER.description.Visible = false
			NAUIMANAGER.description.Text = ""
		end
	end)
	clickTarget.MouseLeave:Connect(function()
		NAUIMANAGER.description.Visible = false
		NAUIMANAGER.description.Text = ""
	end)
	return label
end

function releaseCommandListLabel(state, label)
	if not label then
		return
	end
	NAmanage.Commands_StopInlineTween(label)
	const expansion = label:FindFirstChild("CommandExpansion")
	if expansion then
		NAmanage.Commands_StopInlineTween(expansion)
	end
	label.Visible = false
	label.Parent = nil
	Insert(state.pooledLabels, label)
end

function acquireCommandListLabel(state)
	local label = table.remove(state.pooledLabels)
	while label do
		if typeof(label) == "Instance" and label.Parent ~= state.virtualCanvas then
			const ok = pcall(function()
				label.Parent = state.virtualCanvas
			end)
			if ok then
				return label
			end
		end
		label = table.remove(state.pooledLabels)
	end

	label = createCommandListLabel(state)
	label.Parent = state.virtualCanvas
	return label
end

function applyCommandListEntry(state, label, entry, index, animation)
	const meta = entry.meta or {}
	const cmdName = entry.name
	const finalText = meta.displayText or entry.display or cmdName
	const isPatched = meta.patched == true
	const isCmdIntegration = meta.origin == "cmd"
	const isIYIntegration = meta.origin == "iy"
	const isPluginCmd = meta.pluginType ~= nil
	const isExpanded = state.expandedName ~= nil and tostring(state.expandedName) == tostring(cmdName or "")
	const previousCmdName = tostring(NAmanage.GetAttr(label, "CmdName") or "")
	const sameEntryBefore = previousCmdName ~= "" and previousCmdName == tostring(cmdName or "")
	const animationRunning = type(animation) == "table"
	const animationFirstPass = animationRunning and animation.started ~= true
	const animationOngoing = animationRunning and animation.started == true
	const animationDuration = animationRunning and (tonumber(animation.duration) or 0.25) or 0.25
	const openingThis = animationRunning and tostring(animation.openingName or "") == tostring(cmdName or "")
	const closingThis = animationRunning and tostring(animation.closingName or "") == tostring(cmdName or "")

	if isPatched then
		label.TextColor3 = patchedCommandColor
	elseif isCmdIntegration then
		label.TextColor3 = cmdIntegrationColor
	elseif isIYIntegration then
		label.TextColor3 = iyIntegrationColor
	elseif isPluginCmd then
		label.TextColor3 = pluginCommandColor
	elseif state.defaultCmdColor then
		label.TextColor3 = state.defaultCmdColor
	end

	local desc = meta.desc
	if desc ~= nil then
		desc = tostring(desc)
	end
	desc = desc or ""
	if desc ~= "" and isAprilFools() then
		desc = maybeMock(desc)
	end

	if label.SetAttribute then
		NAmanage.SetAttr(label, "CmdName", tostring(cmdName or ""))
		NAmanage.SetAttr(label, "CmdUsage", tostring(meta.usage or meta.displayText or entry.display or cmdName or ""))
		NAmanage.SetAttr(label, "CmdDesc", desc)
		NAmanage.SetAttr(label, "CmdRequiresArguments", meta.requiresArguments == true)
		NAmanage.SetAttr(label, "IsPluginCommand", isPluginCmd)
		NAmanage.SetAttr(label, "IsPatchedCommand", isPatched)
		NAmanage.SetAttr(label, "IsCmdIntegration", isCmdIntegration)
	end

	label.Name = cmdName
	label.Text = " "..finalText
	const baseSize = state.templateSize or label.Size
	const targetSize = UDim2.new(baseSize.X.Scale, baseSize.X.Offset, baseSize.Y.Scale, baseSize.Y.Offset + (isExpanded and 44 or 0))
	local targetPosition
	if state.staticMode then
		label.LayoutOrder = index
		targetPosition = UDim2.new(0, 0, 0, 0)
	else
		const rowStep = state.rowStep or 20
		const extraBefore = state.expandedIndex and index > state.expandedIndex and (state.expandedExtra or 0) or 0
		targetPosition = UDim2.new(0, 0, 0, COMMAND_LIST_TOP_PADDING + ((index - 1) * rowStep) + extraBefore)
	end

	if animationOngoing and sameEntryBefore then
	elseif animationFirstPass and sameEntryBefore then
		NAmanage.Commands_TweenInline(label, {
			Size = targetSize;
			Position = targetPosition;
		}, animationDuration)
	else
		NAmanage.Commands_StopInlineTween(label)
		label.Size = targetSize
		label.Position = targetPosition
	end

	const title = label:FindFirstChild("CommandTitle")
	if title and title:IsA("TextLabel") then
		title.Text = " "..finalText
		title.TextColor3 = label.TextColor3
		title.Size = UDim2.new(1, 0, 0, state.templateHeight or 32)
	end
	const clickTarget = label:FindFirstChild("CommandClickTarget")
	if clickTarget and clickTarget:IsA("GuiObject") then
		clickTarget.Size = UDim2.new(1, 0, 0, state.templateHeight or 32)
	end
	const expansion = label:FindFirstChild("CommandExpansion")
	if expansion and expansion:IsA("Frame") then
		expansion.Position = UDim2.new(0, 8, 0, (state.templateHeight or 32) + 4)
		const argsBox = expansion:FindFirstChild("Arguments")
		const runButton = expansion:FindFirstChild("Run")
		if argsBox and argsBox:IsA("TextBox") then
			const requiresArguments = meta.requiresArguments == true
			argsBox.Visible = requiresArguments
			if requiresArguments then
				local hint = tostring(meta.argumentHint or "")
				if hint == "" then
					const usage = tostring(meta.usage or "")
					const usageLower = Lower(usage)
					hint = usage:match("^%S+%s+(.+)$") or "Enter arguments..."
					hint = hint:gsub("%s+%([^)]*%)$", "")
					if usageLower:find("npc:", 1, true) then
						hint = hint:gsub("<player|npc:filter>", "player / me / others / nearest / npc:name / npcs")
						hint = hint:gsub("<target|npc:filter>", "player / me / others / nearest / npc:name / npcs")
					elseif usageLower:find("<player>", 1, true) then
						hint = hint:gsub("<[Pp][Ll][Aa][Yy][Ee][Rr]>", "player / me / others / nearest")
					end
				end
				argsBox.PlaceholderText = hint ~= "" and hint or "Enter arguments..."
				state.inlineArguments = state.inlineArguments or {}
				const savedText = tostring(state.inlineArguments[tostring(cmdName or "")] or "")
				if argsBox.Text ~= savedText then
					argsBox.Text = savedText
				end
			end
		end
		if runButton and runButton:IsA("TextButton") then
			if meta.requiresArguments == true then
				runButton.Size = UDim2.new(0, 70, 0, 28)
			else
				runButton.Size = UDim2.new(1, 0, 0, 28)
			end
		end

		if animationOngoing and sameEntryBefore and (openingThis or closingThis) then
		elseif animationFirstPass and sameEntryBefore and openingThis then
			NAmanage.Commands_StopInlineTween(expansion)
			expansion.Visible = true
			expansion.Size = UDim2.new(1, -16, 0, 0)
			NAmanage.Commands_TweenInline(expansion, { Size = UDim2.new(1, -16, 0, 36) }, animationDuration)
		elseif animationFirstPass and sameEntryBefore and closingThis then
			expansion.Visible = true
			NAmanage.Commands_TweenInline(expansion, { Size = UDim2.new(1, -16, 0, 0) }, animationDuration)
			const closingName = tostring(cmdName or "")
			Delay(animationDuration, function()
				if expansion.Parent == label and tostring(NAmanage.GetAttr(label, "CmdName") or "") == closingName and tostring(state.expandedName or "") ~= closingName then
					expansion.Visible = false
				end
			end)
		else
			NAmanage.Commands_StopInlineTween(expansion)
			expansion.Size = UDim2.new(1, -16, 0, 36)
			expansion.Visible = isExpanded
		end
	end
	label.Visible = true
end

function clearStaticCommandLabels(state)
	if type(state.staticLabels) ~= "table" then
		state.staticLabels = {}
		return
	end
	for i = 1, #state.staticLabels do
		const label = state.staticLabels[i]
		if typeof(label) == "Instance" then
			pcall(function()
				label:Destroy()
			end)
		end
	end
	state.staticLabels = {}
end

function rebuildStaticCommandLabels(state)
	if not state then
		return
	end
	const cList = state.list
	if not cList then
		return
	end

	if state.virtualCanvas and state.virtualCanvas.Parent == cList then
		state.virtualCanvas.Parent = nil
	end
	while #state.visibleLabels > 0 do
		releaseCommandListLabel(state, table.remove(state.visibleLabels))
	end
	clearStaticCommandLabels(state)

	const entries = state.entries or {}
	state.staticLabels = state.staticLabels or {}
	for i = 1, #entries do
		const entry = entries[i]
		const label = createCommandListLabel(state)
		label.Parent = cList
		applyCommandListEntry(state, label, entry, i)
		state.staticLabels[i] = label
	end

	updateCanvasSize(cList, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
	if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
		NAmanage.CustomScroll.refreshByTarget(cList)
	end
end

function requestCommandListSync(state)
	if not state or state.syncQueued == true then
		return
	end
	state.syncQueued = true
	Defer(function()
		if not state then
			return
		end
		state.syncQueued = false
		if type(NAmanage.syncVisibleCommandRows) == "function" then
			NAmanage.syncVisibleCommandRows(state)
		end
	end)
end

function getCommandTemplateHeight()
	const template = NAUIMANAGER and NAUIMANAGER.commandExample
	if not template then
		return 18
	end

	const size = template.Size
	if size and size.Y then
		const offset = tonumber(size.Y.Offset) or 0
		if offset > 0 then
			return offset
		end
	end

	const logicalSize = NAmanage.GetLogicalAbsoluteSize and NAmanage.GetLogicalAbsoluteSize(template) or nil
	const absY = logicalSize and logicalSize.Y or (template.AbsoluteSize and template.AbsoluteSize.Y or 0)
	if absY and absY > 0 then
		return math.floor(absY + 0.5)
	end

	return 18
end

NAmanage.ensureCommandListState=function()
	const cList = NAUIMANAGER and NAUIMANAGER.commandsList
	if not (cList and NAUIMANAGER and NAUIMANAGER.commandExample) then
		return nil
	end
	const staticMode = NAmanage.cmdStatic and NAmanage.cmdStatic() or false
	pcall(function()
		NAmanage.SetAttr(cList, "NAManualCanvasSize", staticMode ~= true)
	end)
	const listLayout = cList:FindFirstChildOfClass("UIListLayout")
	if listLayout then
		pcall(function()
			listLayout.Enabled = staticMode == true
		end)
	end

	local state = NAStuff.CommandListState
	if type(state) == "table" and state.list == cList and state.staticMode == staticMode then
		if staticMode then
			return state
		end
		if state.virtualCanvas and state.virtualCanvas.Parent == cList then
			return state
		end
	end

	if type(state) == "table" and state.list == cList and state.staticMode ~= staticMode then
		clearStaticCommandLabels(state)
		while #state.visibleLabels > 0 do
			releaseCommandListLabel(state, table.remove(state.visibleLabels))
		end
		if state.virtualCanvas then
			pcall(function()
				state.virtualCanvas:Destroy()
			end)
		end
		NAStuff.CommandListState = nil
		state = nil
	end

	local virtualCanvas = nil
	if not staticMode then
		virtualCanvas = cList:FindFirstChild("VirtualCanvas")
		if not virtualCanvas then
			virtualCanvas = InstanceNew("Frame")
			virtualCanvas.Name = "VirtualCanvas"
			virtualCanvas.BackgroundTransparency = 1
			virtualCanvas.BorderSizePixel = 0
			virtualCanvas.Size = UDim2.new(1, 0, 0, 0)
			virtualCanvas.Position = UDim2.new(0, 0, 0, 0)
			virtualCanvas.AnchorPoint = Vector2.new(0, 0)
			virtualCanvas.Parent = cList
		else
			virtualCanvas.AnchorPoint = Vector2.new(0, 0)
			virtualCanvas.Position = UDim2.new(0, 0, 0, 0)
		end
	else
		virtualCanvas = cList:FindFirstChild("VirtualCanvas")
		if virtualCanvas then
			virtualCanvas.Parent = nil
		end
	end

	if type(state) == "table" and state.list == cList and state.staticMode == staticMode then
		return state
	end

	const pooled = {}
	for _, label in NAStuff.CommandLabelPool or {} do
		if typeof(label) == "Instance" then
			Insert(pooled, label)
		end
	end
	NAStuff.CommandLabelPool = pooled

	const templateHeight = getCommandTemplateHeight()
	const rowGap = math.max(2, math.floor(templateHeight * 0.15 + 0.5))
	const rowStep = templateHeight + rowGap

	state = {
		list = cList;
		virtualCanvas = virtualCanvas;
		entries = {};
		filteredEntries = {};
		visibleLabels = {};
		pooledLabels = pooled;
		defaultCmdColor = NAUIMANAGER.commandExample.TextColor3;
		templateSize = NAUIMANAGER.commandExample.Size;
		templateHeight = templateHeight;
		rowGap = rowGap;
		rowStep = rowStep;
		syncQueued = false;
		staticMode = staticMode;
		staticLabels = {};
		listLayout = listLayout;
		expandedName = nil;
		expandedIndex = nil;
		expandedExtra = 0;
		inlineArguments = {};
		commandExpansionAnimation = nil;
	}
	NAStuff.CommandListState = state

	if NAUIMANAGER.description then
		NAUIMANAGER.description.Visible = false
		NAUIMANAGER.description.Text = ""
	end

	NAlib.disconnect("NA_CommandListCanvasPos")
	NAlib.disconnect("NA_CommandListAbsSize")
	if not staticMode then
		NAlib.connect("NA_CommandListCanvasPos", cList:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			requestCommandListSync(state)
		end))
		NAlib.connect("NA_CommandListAbsSize", cList:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			requestCommandListSync(state)
		end))
	end

	return state
end

NAmanage.syncVisibleCommandRows=function(state)
	state = state or NAmanage.ensureCommandListState()
	if not state then
		return
	end

	const cList = state.list
	const virtualCanvas = state.virtualCanvas
	const filteredEntries = state.filteredEntries or {}
	const count = #filteredEntries
	NAmanage.Commands_UpdateExpandedMetrics(state)
	local expansionAnimation = state.commandExpansionAnimation
	if type(expansionAnimation) == "table" and expansionAnimation.started == true then
		const expiresAt = tonumber(expansionAnimation.expiresAt) or 0
		if expiresAt > 0 and os.clock() >= expiresAt then
			state.commandExpansionAnimation = nil
			expansionAnimation = nil
		end
	end

	if state.staticMode then
		if type(state.staticLabels) == "table" then
			for i = 1, #state.staticLabels do
				const label = state.staticLabels[i]
				const entry = filteredEntries[i] or state.entries[i]
				if label and entry then
					applyCommandListEntry(state, label, entry, i, expansionAnimation)
				end
			end
		end
		updateCanvasSize(cList, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
		if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
			NAmanage.CustomScroll.refreshByTarget(cList)
		end
		if type(expansionAnimation) == "table" and expansionAnimation.started ~= true then
			expansionAnimation.started = true
			const duration = tonumber(expansionAnimation.duration) or 0.25
			expansionAnimation.expiresAt = os.clock() + duration + 0.04
			Delay(duration + 0.04, function()
				if state.commandExpansionAnimation == expansionAnimation then
					state.commandExpansionAnimation = nil
					NAmanage.syncVisibleCommandRows(state)
				end
			end)
		end
		return
	end

	if NAUIMANAGER.description then
		NAUIMANAGER.description.Visible = false
		NAUIMANAGER.description.Text = ""
	end

	if count <= 0 then
		state.commandExpansionAnimation = nil
		while #state.visibleLabels > 0 do
			releaseCommandListLabel(state, table.remove(state.visibleLabels))
		end
		if virtualCanvas then
			virtualCanvas.Size = UDim2.new(1, 0, 0, 0)
		end
		cList.CanvasSize = UDim2.new(0, 0, 0, 0)
		if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
			NAmanage.CustomScroll.refreshByTarget(cList)
		end
		return
	end

	const rowStep = state.rowStep or 20
	const totalHeight = COMMAND_LIST_TOP_PADDING + (count * rowStep) + (state.expandedExtra or 0)
	virtualCanvas.Size = UDim2.new(1, 0, 0, totalHeight)
	cList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

	local logicalListSize = nil
	if NAmanage.GetLogicalWindowSize then
		logicalListSize = NAmanage.GetLogicalWindowSize(cList)
	elseif NAmanage.GetLogicalAbsoluteSize then
		logicalListSize = NAmanage.GetLogicalAbsoluteSize(cList)
	end
	local viewHeight = logicalListSize and logicalListSize.Y or cList.AbsoluteSize.Y
	const scrollPos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(cList) or cList.CanvasPosition
	local scrollY = scrollPos.Y
	if NAmanage.virtView then
		viewHeight, scrollY = NAmanage.virtView(cList, viewHeight, totalHeight, rowStep * 3)
	end
	if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
		NAmanage.CustomScroll.refreshByTarget(cList)
	end
	const viewRows = math.max(COMMAND_MIN_VISIBLE_ROWS, math.ceil(math.max(viewHeight, rowStep) / rowStep) + 2)
	const overscanPx = math.max(COMMAND_OVERSCAN_ROWS * rowStep, viewHeight, rowStep * 10)
	const firstY = math.max(0, scrollY - COMMAND_LIST_TOP_PADDING - overscanPx)
	const lastY = math.max(firstY + rowStep, scrollY + viewHeight - COMMAND_LIST_TOP_PADDING + overscanPx)
	local firstIndex = math.min(count, math.max(1, math.floor(firstY / rowStep) + 1))
	local lastIndex = math.min(count, math.max(firstIndex, math.ceil(lastY / rowStep) + 1))
	const minNeeded = math.min(count, viewRows)
	if (lastIndex - firstIndex + 1) < minNeeded then
		lastIndex = math.min(count, firstIndex + minNeeded - 1)
		firstIndex = math.max(1, math.min(firstIndex, lastIndex - minNeeded + 1))
	end

	const needed = math.max(0, lastIndex - firstIndex + 1)
	while #state.visibleLabels > needed do
		releaseCommandListLabel(state, table.remove(state.visibleLabels))
	end

	for offset = 1, needed do
		const entryIndex = firstIndex + offset - 1
		const entry = filteredEntries[entryIndex]
		if entry then
			local label = state.visibleLabels[offset]
			if not label then
				label = acquireCommandListLabel(state)
				state.visibleLabels[offset] = label
			elseif label.Parent ~= virtualCanvas then
				label.Parent = virtualCanvas
			end
			applyCommandListEntry(state, label, entry, entryIndex, expansionAnimation)
		end
	end

	if type(expansionAnimation) == "table" and expansionAnimation.started ~= true then
		expansionAnimation.started = true
		const duration = tonumber(expansionAnimation.duration) or 0.25
		expansionAnimation.expiresAt = os.clock() + duration + 0.04
		Delay(duration + 0.04, function()
			if state.commandExpansionAnimation == expansionAnimation then
				state.commandExpansionAnimation = nil
				NAmanage.syncVisibleCommandRows(state)
			end
		end)
	end
end

NAgui.commands = function(opts)
	opts = type(opts) == "table" and opts or {}
	const cFrame, cList = NAUIMANAGER.commandsFrame, NAUIMANAGER.commandsList
	if not (cFrame and cList and NAUIMANAGER.commandExample) then
		return
	end

	if opts.toggle == true and cFrame.Visible then
		if NAmanage.Commands_SetVisible then
			NAmanage.Commands_SetVisible(false, { refresh = false })
		else
			cFrame.Visible = false
		end
		return
	end

	if not cFrame.Visible then
		cFrame.Visible = true
		cList.CanvasSize = UDim2.new(0, 0, 0, 0)
	end

	local expanded = true
	if NAmanage.Commands_SyncHiddenState then
		expanded = NAmanage.Commands_SyncHiddenState({
			center = opts.center ~= false;
			responsive = true;
			syncRows = false;
		})
	else
		if NAmanage.cmdResp then
			NAmanage.cmdResp(false)
		end
		NAmanage.centerFrame(cFrame)
	end

	const state = NAmanage.ensureCommandListState()
	if not state then
		return
	end

	local entries = NAStuff.AutofillEntries
	if type(entries) ~= "table" then
		entries = {}
	end
	if type(NAmanage.isCommandDataStale) == "function" and NAmanage.isCommandDataStale() then
		if type(NAmanage.queueCommandDataBuild) == "function" then
			pcall(NAmanage.queueCommandDataBuild, { force = (#entries <= 0) })
		elseif type(NAgui.loadCMDS) == "function" then
			pcall(NAgui.loadCMDS, { force = (#entries <= 0) })
		end
		if type(NAStuff.AutofillEntries) == "table" then
			entries = NAStuff.AutofillEntries
		end
	end
	state.entries = entries
	state.filteredEntries = entries
	NAStuff.CommandFilterEntries = nil

	if not expanded then
		return
	end

	if NAgui.filterCommandList then
		NAgui.filterCommandList(NAUIMANAGER.commandsFilter and NAUIMANAGER.commandsFilter.Text or "")
	else
		NAmanage.syncVisibleCommandRows(state)
	end
end
NAgui.chatlogs = function()
	if NAUIMANAGER.chatLogsFrame then
		if not NAUIMANAGER.chatLogsFrame.Visible then
			NAUIMANAGER.chatLogsFrame.Visible = true
		end
		--NAUIMANAGER.chatLogsFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.chatLogsFrame)
	end
end
NAgui.doModal = function(v)
	NAUIMANAGER.ModalFixer.Modal = v
end
NAgui.consoleeee = function()
	if NAUIMANAGER.NAconsoleFrame then
		if not NAUIMANAGER.NAconsoleFrame.Visible then
			NAUIMANAGER.NAconsoleFrame.Visible = true
		end
		--NAUIMANAGER.NAconsoleFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.NAconsoleFrame)
	end
end

NAmanage.MusicWindowInit = NAmanage.MusicWindowInit or function()
	const frame = NAUIMANAGER and NAUIMANAGER.MusicFrame
	if not frame then return false end
	local st = NAStuff.MusicPlayer
	if type(st) ~= "table" then
		st = {}
		NAStuff.MusicPlayer = st
	end
	if st.ready == true and st.frame == frame then return true end
	NAlib.disconnect("NA_MusicPlayer")
	NAlib.disconnect("NA_MusicPlayerSound")
	NAlib.disconnect("NA_MusicRows")
	st.ready = true
	st.frame = frame
	st.root = "Nameless-Admin/Music"
	st.cfgPath = st.root.."/_config.json"
	st.exts = {mp3=true,ogg=true,flac=true,wav=true}
	st.mode = st.mode or "off"
	st.loop = st.loop == true
	st.vol = math.clamp(tonumber(st.vol) or 1, 0, 10)
	st.spd = math.clamp(tonumber(st.spd) or 1, 0.25, 4)
	const c = frame:FindFirstChild("Container")
	if not c then return false end
	const inp = c:FindFirstChild("TrackInput")
	const load = c:FindFirstChild("Load")
	const now = c:FindFirstChild("NowPlaying")
	const stat = c:FindFirstChild("Status")
	const time = c:FindFirstChild("Time")
	const prog = c:FindFirstChild("Progress")
	const fill = prog and prog:FindFirstChild("Fill")
	const list = c:FindFirstChild("LocalList")
	const mix = c:FindFirstChild("Mix")
	const volBox = mix and mix:FindFirstChild("VolumeBox")
	const spdBox = mix and mix:FindFirstChild("SpeedBox")
	const ctrls = c:FindFirstChild("Controls")
	const btns = {}
	if ctrls then
		for _, ch in ctrls:GetChildren() do
			if ch:IsA("TextButton") then btns[ch.Name] = ch end
		end
	end
	const function trim(v)
		return tostring(v or ""):gsub("^%s*(.-)%s*$", "%1")
	end
	const function bn(p)
		return tostring(p or ""):match("[^/\\]+$") or tostring(p or "")
	end
	const function noext(p)
		return tostring(p or ""):gsub("%.[^%.]+$", "")
	end
	const function ext(p)
		const clean = tostring(p or ""):match("([^?#]+)") or tostring(p or "")
		local e = clean:match("%.([%w]+)$")
		e = e and e:lower() or nil
		return e and st.exts[e] and e or nil
	end
	const function hsh(s)
		local h = 0
		for i = 1, #s do h = (h * 31 + (string.byte(s, i) or 0)) % 4294967296 end
		return Format("%08x", h)
	end
	const function safeFolder()
		if type(isfolder) ~= "function" or type(makefolder) ~= "function" then return false end
		local ok, ex = pcall(isfolder, st.root)
		if ok and ex then return true end
		return pcall(makefolder, st.root) == true
	end
	const function saveCfg()
		if not (Services.HttpService and type(writefile) == "function" and safeFolder()) then return false end
		local ok, data = pcall(Services.HttpService.JSONEncode, Services.HttpService, {
			last = st.last or "",
			vol = st.vol,
			spd = st.spd,
			loop = st.loop == true,
			mode = st.mode or "off"
		})
		if ok and type(data) == "string" then return pcall(writefile, st.cfgPath, data) == true end
		return false
	end
	const function loadCfg()
		if not (Services.HttpService and type(isfile) == "function" and type(readfile) == "function") then return end
		local okFile, has = pcall(isfile, st.cfgPath)
		if not (okFile and has) then return end
		local okRead, raw = pcall(readfile, st.cfgPath)
		if not (okRead and type(raw) == "string" and raw ~= "") then return end
		local okDec, cfg = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if not (okDec and type(cfg) == "table") then return end
		st.last = tostring(cfg.last or st.last or "")
		st.vol = math.clamp(tonumber(cfg.vol) or st.vol or 1, 0, 10)
		st.spd = math.clamp(tonumber(cfg.spd) or st.spd or 1, 0.25, 4)
		st.loop = cfg.loop == true
		st.mode = (cfg.mode == "order" or cfg.mode == "random") and cfg.mode or "off"
	end
	const function fmt(sec)
		sec = math.max(0, math.floor((tonumber(sec) or 0) + 0.5))
		return Format("%02d:%02d", math.floor(sec / 60), sec % 60)
	end
	const function setStat(txt, col)
		if stat then
			stat.Text = tostring(txt or "Stopped")
			if col then stat.BackgroundColor3 = col end
		end
	end
	const function setNow(txt)
		if now then now.Text = tostring(txt or "No track loaded") end
	end
	const function setProg(pos, len)
		pos = tonumber(pos) or 0
		len = tonumber(len) or 0
		const a = len > 0 and math.clamp(pos / len, 0, 1) or 0
		if fill then fill.Size = UDim2.new(a, 0, 1, 0) end
		if time then time.Text = fmt(pos).." / "..fmt(len) end
	end
	const function syncMix()
		if volBox then volBox.Text = tostring(math.floor((st.vol or 1) * 100 + 0.5) / 100) end
		if spdBox then spdBox.Text = tostring(math.floor((st.spd or 1) * 100 + 0.5) / 100) end
		if btns.Loop then btns.Loop.Text = st.loop and "Loop On" or "Loop" end
		if btns.Mode then btns.Mode.Text = st.mode == "order" and "Order" or st.mode == "random" and "Random" or "Mode" end
		if st.snd then
			pcall(function()
				st.snd.Volume = st.vol
				st.snd.PlaybackSpeed = st.spd
				st.snd.Looped = st.loop == true
			end)
		end
	end
	const function scan()
		const out = {}
		if type(listfiles) ~= "function" or type(getcustomasset) ~= "function" or not safeFolder() then return out end
		local ok, files = pcall(listfiles, st.root)
		if not (ok and type(files) == "table") then return out end
		for _, path in files do
			if type(path) == "string" and ext(path) then
				local okAsset, asset = pcall(getcustomasset, path)
				if okAsset and type(asset) == "string" and asset ~= "" then
					out[#out + 1] = {path = path, name = bn(path), asset = asset}
				end
			end
		end
		table.sort(out, function(a, b) return tostring(a.name):lower() < tostring(b.name):lower() end)
		st.tracks = out
		return out
	end
	const function rowButton(txt)
		const b = InstanceNew("TextButton")
		b.Name = "Track"
		b.BorderSizePixel = 0
		b.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
		b.BackgroundTransparency = 0.15
		b.TextColor3 = Color3.fromRGB(235, 235, 245)
		b.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		b.TextSize = 13
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.TextTruncate = Enum.TextTruncate.AtEnd
		b.Text = "  "..tostring(txt or "")
		b.Size = UDim2.new(1, -4, 0, 28)
		const cr = InstanceNew("UICorner", b)
		cr.CornerRadius = UDim.new(0, 6)
		const stt = InstanceNew("UIStroke", b)
		stt.Thickness = 1
		stt.Color = Color3.fromRGB(155, 100, 255)
		stt.Transparency = 0.45
		stt.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stt.Name = "UIStroker"
		return b
	end
	local loadTrack
	const function rebuildList()
		NAlib.disconnect("NA_MusicRows")
		if not list then return end
		for _, ch in list:GetChildren() do
			if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then ch:Destroy() end
		end
		const items = scan()
		if #items == 0 then
			const empty = InstanceNew("TextLabel")
			empty.Name = "Empty"
			empty.BackgroundTransparency = 1
			empty.TextXAlignment = Enum.TextXAlignment.Left
			empty.TextSize = 13
			empty.TextColor3 = Color3.fromRGB(170, 170, 185)
			empty.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			empty.TextWrapped = true
			empty.TextYAlignment = Enum.TextYAlignment.Top
			empty.Text = "Drop mp3/ogg/flac/wav files into Nameless-Admin/Music, or paste an asset id/URL above."
			empty.Size = UDim2.new(1, -4, 0, 52)
			empty.Parent = list
			return
		end
		for _, item in items do
			const b = rowButton(item.name)
			b.Parent = list
			NAlib.connect("NA_MusicRows", MouseButtonFix(b, function()
				if inp then inp.Text = item.name end
				if loadTrack then loadTrack(item.name, true) end
			end))
		end
	end
	const function findLocal(q)
		q = trim(q):lower()
		if q == "" then return nil end
		local best
		for _, item in scan() do
			const nm = tostring(item.name or ""):lower()
			const base = noext(nm)
			if q == nm or q == base then return item end
			if not best and nm:find(q, 1, true) then best = item end
		end
		return best
	end
	const function normUrl(u)
		u = trim(u)
		if u:match("^www%.") then u = "https://"..u end
		u = u:gsub(" ", "%%20")
		u = u:gsub("^https://github%.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$", "https://raw.githubusercontent.com/%1/%2/%3/%4")
		return u
	end
	const function fileNameFor(u, e)
		local n = bn((u:match("([^?#]+)") or u)):gsub("%.[^%.]+$", "")
		n = n:gsub("[^%w%._%-]", "_")
		if n == "" then n = "track" end
		return n.."_"..hsh(u).."."..e
	end
	const function reqBody(u)
		local body
		const rq = opt and opt.NAREQUEST
		if type(rq) == "function" then
			local ok, res = pcall(rq, {Url = u, Method = "GET", Headers = { ["Accept"] = "*/*" }})
			if ok and type(res) == "table" then body = res.Body or res.body end
		end
		if type(body) ~= "string" or body == "" then
			local ok, res = NAmanage.HttpGet(u, { timeout = 10, Headers = { ["Accept"] = "*/*" } })
			if ok and type(res) == "string" and res ~= "" then body = res end
		end
		return body
	end
	const function dl(u)
		if type(writefile) ~= "function" or type(getcustomasset) ~= "function" or not safeFolder() then
			return nil, "File support and getcustomasset are required for URL audio."
		end
		u = normUrl(u)
		const e = ext(u)
		if not e then return nil, "URL must end in mp3, ogg, flac, or wav." end
		const dst = st.root.."/"..fileNameFor(u, e)
		if type(isfile) == "function" then
			local okFile, has = pcall(isfile, dst)
			if okFile and has then
				local okAsset, asset = pcall(getcustomasset, dst)
				if okAsset and asset then return {path = dst, name = bn(dst), asset = asset} end
			end
		end
		const body = reqBody(u)
		if type(body) ~= "string" or body == "" then return nil, "Failed to download audio." end
		const okWrite = pcall(writefile, dst, body)
		if not okWrite then return nil, "Failed to save audio." end
		local okAsset, asset = pcall(getcustomasset, dst)
		if not (okAsset and type(asset) == "string" and asset ~= "") then return nil, "Failed to load local audio asset." end
		return {path = dst, name = bn(dst), asset = asset}
	end
	const function idOf(q)
		q = trim(q)
		const n = q:match("^rbxassetid://(%d+)$") or q:match("[?&]id=(%d+)") or q:match("^(%d+)$") or q:match("/library/(%d+)") or q:match("/catalog/(%d+)")
		if n then return "rbxassetid://"..n, n end
		return nil
	end
	const function resolve(q)
		q = trim(q)
		if q == "" then return nil, nil, "Enter an asset id, URL, or local filename." end
		const loc = findLocal(q)
		if loc and loc.asset then return loc.asset, loc.name end
		local sid, raw = idOf(q)
		if sid then return sid, raw end
		if q:match("^https?://") or q:match("^www%.") then
			local item, err = dl(q)
			if item and item.asset then return item.asset, item.name end
			return nil, nil, err or "Failed to load URL."
		end
		if ext(q) then return nil, nil, "Local audio file not found in Nameless-Admin/Music." end
		return nil, nil, "Enter a valid asset id, URL, or local filename."
	end
	const function nextTrack()
		const tracks = scan()
		if #tracks == 0 then return nil end
		const cur = trim(st.raw or st.last or ""):lower()
		local idx
		for i, it in tracks do
			const nm = tostring(it.name or ""):lower()
			if cur == nm or cur == noext(nm) then idx = i break end
		end
		if st.mode == "random" then
			if #tracks == 1 then return tracks[1] end
			local n = math.random(1, #tracks)
			if n == idx then n = (n % #tracks) + 1 end
			return tracks[n]
		end
		return tracks[((idx or 0) % #tracks) + 1]
	end
	const function protRoot()
		local root
		if __NAUIProtector and type(__NAUIProtector.parent) == "function" then
			local ok, res = pcall(__NAUIProtector.parent)
			if ok and typeof(res) == "Instance" then root = res end
		end
		if not root and NAlib and type(NAlib.huiGrabber) == "function" then
			local ok, res = pcall(NAlib.huiGrabber)
			if ok and typeof(res) == "Instance" then root = res end
		end
		if not root and NAStuff and typeof(NAStuff.NASCREENGUI) == "Instance" then root = NAStuff.NASCREENGUI end
		if not root and typeof(frame) == "Instance" then root = frame end
		return root
	end
	const function safeParent(obj)
		if typeof(obj) ~= "Instance" then return nil end
		local ok, par = pcall(function() return obj.Parent end)
		if ok then return par end
		return nil
	end
	const function ensureHost()
		const root = protRoot()
		if not root then return frame end
		local host = st.host
		if typeof(host) == "Instance" then
			local par = safeParent(host)
			if par ~= root then
				const ok = pcall(function() host.Parent = root end)
				par = safeParent(host)
				if not ok or par ~= root then host = nil end
			end
		else
			host = nil
		end
		if not host then
			host = InstanceNew("Folder")
			host.Name = NAmanage.GetSessionInstanceName and NAmanage.GetSessionInstanceName("MusicHost") or "NA_MusicHost"
			host.Parent = root
			st.host = host
			if NAmanage and type(NAmanage.ProtectInstance) == "function" then
				pcall(NAmanage.ProtectInstance, host, {
					register = true,
					enforceParent = true,
					parent = root,
					renameRoot = true,
					nameKey = "MusicHost",
				})
			end
		end
		return host
	end
	const function clearSound()
		NAlib.disconnect("NA_MusicPlayerSound")
		if st.snd then
			pcall(function() st.snd:Destroy() end)
			st.snd = nil
		end
	end
	const function mkSound(id, raw, auto, seek, repair)
		clearSound()
		const par = ensureHost() or frame
		const s = InstanceNew("Sound")
		s.Name = NAmanage.GetSessionInstanceName and NAmanage.GetSessionInstanceName("MusicPlayerSound") or "NA_MusicPlayerSound"
		s.SoundId = id
		s.Volume = st.vol
		s.PlaybackSpeed = st.spd
		s.Looped = st.loop == true
		s.Parent = par
		st.snd = s
		st.sid = id
		st.raw = tostring(raw or "")
		st.last = st.raw
		st.wasPlaying = auto == true
		st.repairing = false
		if NAmanage and type(NAmanage.ProtectInstance) == "function" then
			pcall(NAmanage.ProtectInstance, s, {
				register = true,
				enforceParent = true,
				parent = par,
				renameRoot = true,
				nameKey = "MusicPlayerSound",
			})
		end
		if not repair then setNow("Loaded: "..st.raw) end
		setStat(repair and "Restored" or "Loaded", Color3.fromRGB(55, 55, 75))
		setProg(tonumber(seek) or 0, s.TimeLength or 0)
		syncMix()
		saveCfg()
		const function clearGroup()
			if st.snd == s and safeParent(s) then pcall(function() s.SoundGroup = nil end) end
		end
		const function markRepair()
			if st.snd ~= s then return end
			local pos = 0
			pcall(function() pos = s.TimePosition or 0 end)
			st.repairPos = pos
			st.needsRepair = true
		end
		clearGroup()
		NAlib.connect("NA_MusicPlayerSound", s:GetPropertyChangedSignal("SoundGroup"):Connect(function() Defer(clearGroup) end))
		NAlib.connect("NA_MusicPlayerSound", s.AncestryChanged:Connect(function(_, parent)
			if st.snd == s and parent == nil then markRepair() end
		end))
		pcall(function()
			NAlib.connect("NA_MusicPlayerSound", s.Destroying:Connect(markRepair))
		end)
		NAlib.connect("NA_MusicPlayerSound", s.Loaded:Connect(function()
			if st.snd ~= s then return end
			const pos = tonumber(seek) or 0
			if pos > 0 then pcall(function() s.TimePosition = math.clamp(pos, 0, math.max(s.TimeLength or 0, pos)) end) end
			setStat("Loaded", Color3.fromRGB(55, 55, 75))
			setProg(s.TimePosition or 0, s.TimeLength or 0)
		end))
		NAlib.connect("NA_MusicPlayerSound", s.Played:Connect(function()
			if st.snd ~= s then return end
			st.wasPlaying = true
			setStat("Playing", Color3.fromRGB(35, 90, 70))
		end))
		NAlib.connect("NA_MusicPlayerSound", s.Paused:Connect(function()
			if st.snd ~= s then return end
			st.wasPlaying = false
			setStat("Paused", Color3.fromRGB(65, 65, 82))
		end))
		NAlib.connect("NA_MusicPlayerSound", s.Stopped:Connect(function()
			if st.snd ~= s then return end
			st.wasPlaying = false
			setStat("Stopped", Color3.fromRGB(55, 55, 65))
			setProg(0, s.TimeLength or 0)
		end))
		NAlib.connect("NA_MusicPlayerSound", s.Ended:Connect(function()
			if st.snd ~= s then return end
			st.wasPlaying = false
			setStat("Ended", Color3.fromRGB(86, 62, 45))
			if st.mode == "order" or st.mode == "random" then
				const nxt = nextTrack()
				if nxt then loadTrack(nxt.name, true, true) end
			end
		end))
		if auto then
			Defer(function()
				if st.snd ~= s then return end
				pcall(function() s:Play() end)
				const pos = tonumber(seek) or 0
				if pos > 0 then pcall(function() s.TimePosition = pos end) end
			end)
		elseif tonumber(seek) and seek > 0 then
			pcall(function() s.TimePosition = seek end)
		end
		return true
	end
	const function repairSound(force)
		if not st.sid or st.repairing then return false end
		const nowTick = tick()
		if not force and nowTick - (tonumber(st.lastRepair) or 0) < 0.75 then return false end
		st.lastRepair = nowTick
		st.repairing = true
		local pos = tonumber(st.repairPos) or 0
		local play = st.wasPlaying == true
		if st.snd then
			pcall(function() pos = st.snd.TimePosition or pos end)
			pcall(function() play = st.snd.IsPlaying == true or st.snd.Playing == true or play end)
		end
		return mkSound(st.sid, st.raw or st.last or "", play, pos, true)
	end
	function loadTrack(raw, auto, quiet)
		raw = raw or (inp and inp.Text) or st.last or ""
		local id, display, err = resolve(raw)
		if not id then
			if not quiet then DoNotif(err or "Failed to load track.", 3, "Music") end
			setStat("Error", Color3.fromRGB(95, 45, 55))
			return false
		end
		if inp then inp.Text = tostring(display or raw or "") end
		return mkSound(id, display or raw, auto)
	end
	loadCfg()
	if inp and trim(inp.Text) == "" then inp.Text = st.last or "" end
	syncMix()
	rebuildList()
	if st.last and st.last ~= "" then setNow("Last: "..st.last) end
	if load then NAlib.connect("NA_MusicPlayer", MouseButtonFix(load, function() loadTrack(nil, false) end)) end
	if inp then NAlib.connect("NA_MusicPlayer", inp.FocusLost:Connect(function(ok) if ok then loadTrack(nil, false) end end)) end
	if btns.Refresh then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Refresh, rebuildList)) end
	if btns.Play then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Play, function()
		if not st.snd then if not loadTrack(nil, true) then return end else pcall(function() st.snd:Play() end) end
	end)) end
	if btns.Pause then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Pause, function() if st.snd then pcall(function() st.snd:Pause() end) end end)) end
	if btns.Resume then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Resume, function()
		if st.snd then const ok = pcall(function() st.snd:Resume() end); if not ok then pcall(function() st.snd:Play() end) end end
	end)) end
	if btns.Stop then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Stop, function() if st.snd then pcall(function() st.snd:Stop() end) end end)) end
	if btns.Loop then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Loop, function()
		st.loop = not st.loop
		syncMix()
		saveCfg()
	end)) end
	if btns.Mode then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Mode, function()
		st.mode = st.mode == "off" and "order" or st.mode == "order" and "random" or "off"
		syncMix()
		saveCfg()
	end)) end
	if btns.Next then NAlib.connect("NA_MusicPlayer", MouseButtonFix(btns.Next, function()
		const nxt = nextTrack()
		if not nxt then DoNotif("No local music files found.", 3, "Music") return end
		loadTrack(nxt.name, true)
	end)) end
	if volBox then NAlib.connect("NA_MusicPlayer", volBox.FocusLost:Connect(function()
		st.vol = math.clamp(tonumber(volBox.Text) or st.vol or 1, 0, 10)
		syncMix()
		saveCfg()
	end)) end
	if spdBox then NAlib.connect("NA_MusicPlayer", spdBox.FocusLost:Connect(function()
		st.spd = math.clamp(tonumber(spdBox.Text) or st.spd or 1, 0.25, 4)
		syncMix()
		saveCfg()
	end)) end
	if prog then
		prog.Active = true
		NAlib.connect("NA_MusicPlayer", prog.InputBegan:Connect(function(i)
			if not (st.snd and ((i.UserInputType == Enum.UserInputType.MouseButton1) or (i.UserInputType == Enum.UserInputType.Touch))) then return end
			const len = tonumber(st.snd.TimeLength) or 0
			if len <= 0 then return end
			const a = math.clamp((i.Position.X - prog.AbsolutePosition.X) / math.max(prog.AbsoluteSize.X, 1), 0, 1)
			pcall(function() st.snd.TimePosition = len * a end)
			setProg(len * a, len)
		end))
	end
	NAlib.connect("NA_MusicPlayer", Services.RunService.Heartbeat:Connect(function(dt)
		st.tick = (tonumber(st.tick) or 0) + (tonumber(dt) or 0)
		if st.tick < 0.18 then return end
		st.tick = 0
		if st.host and safeParent(st.host) == nil then st.host = nil end
		if st.snd then
			const par = safeParent(st.snd)
			const want = ensureHost()
			if st.needsRepair or par == nil then
				st.needsRepair = false
				repairSound(false)
				return
			elseif want and par ~= want then
				const ok = pcall(function() st.snd.Parent = want end)
				if not ok or safeParent(st.snd) ~= want then
					repairSound(false)
					return
				end
			end
			pcall(function()
				st.repairPos = st.snd.TimePosition or st.repairPos or 0
				st.wasPlaying = st.snd.IsPlaying == true or st.snd.Playing == true
			end)
		end
		if not (frame and frame.Parent and frame.Visible and st.snd) then return end
		setProg(st.snd.TimePosition or 0, st.snd.TimeLength or 0)
	end))
	return true
end

NAmanage.MusicWindow_Open = NAmanage.MusicWindow_Open or function()
	if not NAmanage.MusicWindowInit() then
		DoNotif("Music player UI unavailable.", 3, "Music")
		return false
	end
	const frame = NAUIMANAGER and NAUIMANAGER.MusicFrame
	if frame then
		frame.Visible = true
		NAmanage.centerFrame(frame)
		if NAmanage.OnUIWindowShown then pcall(NAmanage.OnUIWindowShown, frame) end
		return true
	end
	return false
end

NAmanage.MusicWindow_Toggle = NAmanage.MusicWindow_Toggle or function()
	const frame = NAUIMANAGER and NAUIMANAGER.MusicFrame
	if frame and frame.Visible then
		frame.Visible = false
		return true
	end
	return NAmanage.MusicWindow_Open()
end

NAgui.musicplayer = NAgui.musicplayer or function()
	return NAmanage.MusicWindow_Open()
end

NAgui.settingss = function()
	if NAUIMANAGER.SettingsFrame then
		const settingsFrame = NAUIMANAGER.SettingsFrame
		if NAmanage.InstallUIVisibilityOptimizer then pcall(NAmanage.InstallUIVisibilityOptimizer) end
		if not settingsFrame.Visible then
			settingsFrame.Visible = true
		end
		if NAmanage.OnUIWindowShown then pcall(NAmanage.OnUIWindowShown, settingsFrame) end
		NAmanage.centerFrame(settingsFrame)
		Defer(function()
			if not (settingsFrame and settingsFrame.Parent and settingsFrame.Visible) then
				return
			end
			if NAmanage.SettingsTabLayout then
				if type(NAmanage.SettingsTabLayout.FitFrameToViewport) == "function" then
					NAmanage.SettingsTabLayout.FitFrameToViewport()
				end
				if type(NAmanage.SettingsTabLayout.Apply) == "function" then
					NAmanage.SettingsTabLayout.Apply()
				end
			end
			NAmanage.centerFrame(settingsFrame)
		end)
	end
end
NAgui.commandkeybinds = function()
	const frame = NAUIMANAGER and NAUIMANAGER.CommandKeybindsFrame
	if not frame then
		return
	end
	if not NAmanage.CanUseCommandKeybinds(true) then
		frame.Visible = false
		return
	end
	if type(NAmanage.CommandKeybindsUIInit) == "function" then
		NAmanage.CommandKeybindsUIInit()
	end
	if type(NAmanage.CommandKeybindsUIWire) == "function" then
		NAmanage.CommandKeybindsUIWire()
	end
	if not frame.Visible then
		frame.Visible = true
	end
	NAmanage.centerFrame(frame)
	if type(NAmanage.CommandKeybindsUIRefresh) == "function" then
		NAmanage.CommandKeybindsUIRefresh()
	end
end
NAgui.waypointers = function()
	if NAUIMANAGER.WaypointFrame then
		if not NAUIMANAGER.WaypointFrame.Visible then
			NAUIMANAGER.WaypointFrame.Visible = true
		end
		--NAUIMANAGER.WaypointFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.WaypointFrame)
	end
end
NAgui.eventbinders = function()
	if NAUIMANAGER.BindersFrame then
		if not NAUIMANAGER.BindersFrame.Visible then
			NAUIMANAGER.BindersFrame.Visible = true
		end
		--NAUIMANAGER.BindersFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.BindersFrame)
	end
end
NAgui.tween = function(obj, style, direction, duration, goal, callback)
	style = style or "Sine"
	direction = direction or "Out"
	const tweenInfo = TweenInfo.new(duration, Enum.EasingStyle[style], Enum.EasingDirection[direction])
	const tween = __lt.cm("TweenService", "Create", obj, tweenInfo, goal)
	if callback then
		local completedConn
		completedConn = tween.Completed:Connect(function(...)
			if completedConn then
				pcall(function() completedConn:Disconnect() end)
				completedConn = nil
			end
			callback(...)
		end)
	end
	tween:Play()
	return tween
end

NAmanage.PluginsWindow_Clear = NAmanage.PluginsWindow_Clear or function()
	const list = NAUIMANAGER and NAUIMANAGER.PluginsList
	if not list then
		return
	end
	for _, child in list:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	if not list:FindFirstChildWhichIsA("UIListLayout") then
		const layout = InstanceNew("UIListLayout", list)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 6)
	end
end

NAmanage.PluginsWindow_Row = NAmanage.PluginsWindow_Row or function(height)
	const list = NAUIMANAGER and NAUIMANAGER.PluginsList
	if not list then
		return nil
	end
	const row = InstanceNew("Frame")
	row.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	row.BackgroundTransparency = 0.08
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, -6, 0, height or 42)
	row.Parent = list
	InstanceNew("UICorner", row).CornerRadius = UDim.new(0, 6)
	return row
end

NAmanage.PluginsWindow_AddSection = NAmanage.PluginsWindow_AddSection or function(text)
	const row = NAmanage.PluginsWindow_Row(28)
	if not row then return end
	row.BackgroundTransparency = 1
	const label = InstanceNew("TextLabel", row)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Size = UDim2.new(1, -16, 1, 0)
	label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	label.Text = tostring(text or "")
	label.TextColor3 = Color3.fromRGB(220, 220, 235)
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	NAmanage.SetAttr(row, "NAPluginSearch", tostring(text or ""))
	return row
end

NAmanage.PluginsWindow_AddInfo = NAmanage.PluginsWindow_AddInfo or function(text)
	const row = NAmanage.PluginsWindow_Row(46)
	if not row then return end
	row.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
	row.BackgroundTransparency = 0.18
	const label = InstanceNew("TextLabel", row)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 4)
	label.Size = UDim2.new(1, -24, 1, -8)
	label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	label.Text = tostring(text or "")
	label.TextColor3 = Color3.fromRGB(205, 205, 220)
	label.TextSize = 12
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	NAmanage.SetAttr(row, "NAPluginSearch", tostring(text or ""))
	return row
end

NAmanage.PluginsWindow_AddButton = NAmanage.PluginsWindow_AddButton or function(text, callback)
	const row = NAmanage.PluginsWindow_Row(38)
	if not row then return end
	const label = InstanceNew("TextLabel", row)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(1, -130, 1, 0)
	label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	label.Text = tostring(text or "")
	label.TextColor3 = Color3.fromRGB(245, 245, 250)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left

	const button = InstanceNew("TextButton", row)
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -10, 0.5, 0)
	button.Size = UDim2.new(0, 96, 0, 26)
	button.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	button.BackgroundTransparency = 0.15
	button.BorderSizePixel = 0
	button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	button.Text = "Run"
	button.TextColor3 = Color3.fromRGB(245, 245, 250)
	button.TextSize = 13
	InstanceNew("UICorner", button).CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke", button)
	stroke.Name = "UIStroker"
	stroke.Thickness = 1.4
	stroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MouseButtonFix(button, function()
		if type(callback) == "function" then
			pcall(callback)
		end
	end)
	NAmanage.SetAttr(row, "NAPluginSearch", tostring(text or ""))
	return row
end

NAmanage.PluginsWindow_AddToggle = NAmanage.PluginsWindow_AddToggle or function(text, enabled, callback)
	const row = NAmanage.PluginsWindow_Row(42)
	if not row then return end
	const label = InstanceNew("TextLabel", row)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(1, -78, 1, 0)
	label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	label.Text = tostring(text or "")
	label.TextColor3 = Color3.fromRGB(245, 245, 250)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left

	const switch = InstanceNew("Frame", row)
	switch.Name = "Switch"
	switch.AnchorPoint = Vector2.new(1, 0.5)
	switch.Position = UDim2.new(1, -12, 0.5, 0)
	switch.Size = UDim2.new(0, 45, 0, 22)
	switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	switch.BorderSizePixel = 0
	InstanceNew("UICorner", switch).CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke", switch)
	stroke.Thickness = 1
	stroke.Color = Color3.fromRGB(72, 72, 72)

	const knob = InstanceNew("Frame", switch)
	knob.Name = "Indicator"
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.BorderSizePixel = 0
	InstanceNew("UICorner", knob).CornerRadius = UDim.new(0, 6)
	local state = enabled == true
	const function paint()
		stroke.Color = state and (NAUISTROKER or Color3.fromRGB(155, 100, 255)) or Color3.fromRGB(72, 72, 72)
		knob.BackgroundColor3 = state and (NAUISTROKER or Color3.fromRGB(155, 100, 255)) or Color3.fromRGB(115, 115, 125)
		knob.Position = UDim2.new(0, state and 24 or 3, 0.5, 0)
	end
	paint()

	const hit = InstanceNew("TextButton", row)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.Size = UDim2.new(1, 0, 1, 0)
	hit.ZIndex = 10
	MouseButtonFix(hit, function()
		state = not state
		paint()
		if type(callback) == "function" then
			pcall(callback, state)
		end
	end)
	NAmanage.SetAttr(row, "NAPluginSearch", tostring(text or ""))
	return row
end

NAmanage.PluginsWindow_AddInput = NAmanage.PluginsWindow_AddInput or function(text, placeholder, defaultText, callback)
	const row = NAmanage.PluginsWindow_Row(42)
	if not row then return end
	const label = InstanceNew("TextLabel", row)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(0.45, -20, 1, 0)
	label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	label.Text = tostring(text or "")
	label.TextColor3 = Color3.fromRGB(245, 245, 250)
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd

	const box = InstanceNew("TextBox", row)
	box.AnchorPoint = Vector2.new(1, 0.5)
	box.Position = UDim2.new(1, -10, 0.5, 0)
	box.Size = UDim2.new(0.48, 0, 0, 28)
	box.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	box.BackgroundTransparency = 0.15
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	box.Text = tostring(defaultText or "")
	box.PlaceholderText = tostring(placeholder or "")
	box.PlaceholderColor3 = Color3.fromRGB(130, 130, 140)
	box.TextColor3 = Color3.fromRGB(245, 245, 250)
	box.TextSize = 13
	box.TextXAlignment = Enum.TextXAlignment.Left
	InstanceNew("UICorner", box).CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke", box)
	stroke.Name = "UIStroker"
	stroke.Thickness = 1.2
	stroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	const pad = InstanceNew("UIPadding", box)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	box.FocusLost:Connect(function()
		if type(callback) == "function" then
			pcall(callback, box.Text)
		end
	end)
	NAmanage.SetAttr(row, "NAPluginSearch", tostring(text or ""))
	return row
end

NAmanage.PluginsWindow_AddPlugin = NAmanage.PluginsWindow_AddPlugin or function(entry)
	const row = NAmanage.PluginsWindow_Row(108)
	if not row or type(entry) ~= "table" then return end
	row.BackgroundTransparency = 0.03
	row.ClipsDescendants = true
	const rowStroke = InstanceNew("UIStroke", row)
	rowStroke.Thickness = 1
	rowStroke.Transparency = 0.75
	rowStroke.Color = Color3.fromRGB(95, 95, 110)
	const name = tostring(entry.name or "Plugin")
	local kind = tostring(entry.kind or "")
	const commands = type(entry.commands) == "table" and entry.commands or {}
	local displayName = name:gsub("%.[nN][aA]$", ""):gsub("%.[iI][yY]$", "")
	if displayName == "" then displayName = name end
	if kind == "" then kind = name:match("(%.%w+)$") or "" end
	const statusText = entry.enabled and (entry.loaded and "Loaded" or "Enabled") or "Disabled"
	const statusColor = entry.enabled and (entry.loaded and Color3.fromRGB(130, 220, 150) or Color3.fromRGB(210, 190, 135)) or Color3.fromRGB(220, 120, 120)
	const preview = {}
	for i = 1, math.min(#commands, 5) do
		preview[#preview + 1] = tostring(commands[i])
	end
	local commandText
	if #commands > 0 then
		commandText = tostring(#commands).." command"..(#commands == 1 and "" or "s")..": "..Concat(preview, ", ")
		if #commands > #preview then
			commandText = commandText.." +"..tostring(#commands - #preview)
		end
	elseif entry.enabled then
		commandText = entry.loaded and "Loaded without commands" or "Not loaded yet"
	else
		commandText = "Plugin is disabled"
	end

	const stripe = InstanceNew("Frame", row)
	stripe.BackgroundColor3 = statusColor
	stripe.BorderSizePixel = 0
	stripe.Size = UDim2.new(0, 3, 1, -14)
	stripe.Position = UDim2.new(0, 0, 0, 7)
	InstanceNew("UICorner", stripe).CornerRadius = UDim.new(0, 6)

	const title = InstanceNew("TextLabel", row)
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 14, 0, 8)
	title.Size = UDim2.new(1, -245, 0, 20)
	title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	title.Text = displayName
	title.TextColor3 = Color3.fromRGB(250, 250, 255)
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd

	const ext = InstanceNew("TextLabel", row)
	ext.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	ext.BackgroundTransparency = 0.08
	ext.BorderSizePixel = 0
	ext.Position = UDim2.new(0, 14, 0, 32)
	ext.Size = UDim2.new(0, 42, 0, 18)
	ext.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	ext.Text = kind ~= "" and kind or "file"
	ext.TextColor3 = Color3.fromRGB(210, 200, 245)
	ext.TextSize = 11
	InstanceNew("UICorner", ext).CornerRadius = UDim.new(0, 6)

	const status = InstanceNew("TextLabel", row)
	status.BackgroundTransparency = 1
	status.Position = UDim2.new(0, 62, 0, 32)
	status.Size = UDim2.new(0, 92, 0, 18)
	status.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	status.Text = statusText
	status.TextColor3 = statusColor
	status.TextSize = 12
	status.TextXAlignment = Enum.TextXAlignment.Left

	const detail = InstanceNew("TextLabel", row)
	detail.BackgroundTransparency = 1
	detail.Position = UDim2.new(0, 14, 0, 56)
	detail.Size = UDim2.new(1, -170, 0, 18)
	detail.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	detail.Text = commandText
	detail.TextColor3 = Color3.fromRGB(180, 180, 195)
	detail.TextSize = 12
	detail.TextXAlignment = Enum.TextXAlignment.Left
	detail.TextTruncate = Enum.TextTruncate.AtEnd

	const function actionButton(text, x, width, callback)
		const button = InstanceNew("TextButton", row)
		button.Position = UDim2.new(0, x, 0, 79)
		button.Size = UDim2.new(0, width, 0, 22)
		button.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
		button.BackgroundTransparency = 0.12
		button.BorderSizePixel = 0
		button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		button.Text = text
		button.TextColor3 = Color3.fromRGB(245, 245, 250)
		button.TextSize = 12
		InstanceNew("UICorner", button).CornerRadius = UDim.new(0, 6)
		MouseButtonFix(button, callback)
		return button
	end

	actionButton("Reload", 14, 72, function()
		if NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ forceNotify = true })
		end
		NAmanage.PluginsWindow_RequestRebuild()
	end)

	actionButton("Uninstall", 92, 72, function()
		local ok, msg = NAmanage.PluginMoveToWorkspace(entry.path)
		DoNotif(ok and ("Uninstalled "..name) or ("Uninstall failed: "..tostring(msg)), 3)
		if NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ silent = true })
		end
		NAmanage.PluginsWindow_RequestRebuild()
	end)

	const switch = InstanceNew("Frame", row)
	switch.Name = "Switch"
	switch.AnchorPoint = Vector2.new(1, 0)
	switch.Position = UDim2.new(1, -14, 0, 18)
	switch.Size = UDim2.new(0, 45, 0, 22)
	switch.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	switch.BorderSizePixel = 0
	InstanceNew("UICorner", switch).CornerRadius = UDim.new(0, 6)
	const switchStroke = InstanceNew("UIStroke", switch)
	switchStroke.Thickness = 1
	const knob = InstanceNew("Frame", switch)
	knob.Name = "Indicator"
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.BorderSizePixel = 0
	InstanceNew("UICorner", knob).CornerRadius = UDim.new(0, 6)
	local on = entry.enabled == true
	const function paint()
		switchStroke.Color = on and (NAUISTROKER or Color3.fromRGB(155, 100, 255)) or Color3.fromRGB(72, 72, 72)
		knob.BackgroundColor3 = on and (NAUISTROKER or Color3.fromRGB(155, 100, 255)) or Color3.fromRGB(115, 115, 125)
		knob.Position = UDim2.new(0, on and 24 or 3, 0.5, 0)
	end
	paint()
	const toggleHit = InstanceNew("TextButton", row)
	toggleHit.AnchorPoint = Vector2.new(1, 0)
	toggleHit.Position = UDim2.new(1, -8, 0, 11)
	toggleHit.Size = UDim2.new(0, 56, 0, 36)
	toggleHit.BackgroundTransparency = 1
	toggleHit.Text = ""
	toggleHit.ZIndex = 10
	MouseButtonFix(toggleHit, function()
		on = not on
		paint()
		NAmanage.PluginSetEnabled(entry.path, on == true)
		if NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ silent = true })
		end
		DoNotif(name.." "..(on and "enabled" or "disabled"), 2)
		NAmanage.PluginsWindow_RequestRebuild()
	end)
	NAmanage.SetAttr(row, "NAPluginSearch", (name.." "..displayName.." "..kind.." "..commandText):lower())
	return row
end

NAmanage.PluginsWindow_AddAvailablePlugin = NAmanage.PluginsWindow_AddAvailablePlugin or function(entry)
	const row = NAmanage.PluginsWindow_Row(70)
	if not row or type(entry) ~= "table" then return end
	row.BackgroundTransparency = 0.08
	row.ClipsDescendants = true
	const name = tostring(entry.name or "Plugin")
	const kind = tostring(entry.kind or "")
	local displayName = name:gsub("%.[nN][aA]$", ""):gsub("%.[iI][yY]$", "")
	if displayName == "" then displayName = name end
	const path = tostring(entry.path or "")

	const title = InstanceNew("TextLabel", row)
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 12, 0, 7)
	title.Size = UDim2.new(1, -150, 0, 20)
	title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	title.Text = displayName
	title.TextColor3 = Color3.fromRGB(245, 245, 250)
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd

	const ext = InstanceNew("TextLabel", row)
	ext.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	ext.BackgroundTransparency = 0.08
	ext.BorderSizePixel = 0
	ext.Position = UDim2.new(0, 12, 0, 33)
	ext.Size = UDim2.new(0, 42, 0, 18)
	ext.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	ext.Text = kind ~= "" and kind or "file"
	ext.TextColor3 = Color3.fromRGB(210, 200, 245)
	ext.TextSize = 11
	InstanceNew("UICorner", ext).CornerRadius = UDim.new(0, 6)

	const detail = InstanceNew("TextLabel", row)
	detail.BackgroundTransparency = 1
	detail.Position = UDim2.new(0, 62, 0, 33)
	detail.Size = UDim2.new(1, -210, 0, 18)
	detail.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	detail.Text = path
	detail.TextColor3 = Color3.fromRGB(170, 170, 185)
	detail.TextSize = 12
	detail.TextXAlignment = Enum.TextXAlignment.Left
	detail.TextTruncate = Enum.TextTruncate.AtEnd

	const install = InstanceNew("TextButton", row)
	install.AnchorPoint = Vector2.new(1, 0.5)
	install.Position = UDim2.new(1, -12, 0.5, 0)
	install.Size = UDim2.new(0, 92, 0, 26)
	install.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
	install.BackgroundTransparency = 0.12
	install.BorderSizePixel = 0
	install.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	install.Text = "Install"
	install.TextColor3 = Color3.fromRGB(245, 245, 250)
	install.TextSize = 12
	InstanceNew("UICorner", install).CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke", install)
	stroke.Name = "UIStroker"
	stroke.Thickness = 1.2
	stroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MouseButtonFix(install, function()
		local ok, msg = NAmanage.PluginInstallFromWorkspace(entry.path)
		DoNotif(ok and ("Installed "..name) or ("Install failed: "..tostring(msg)), 3)
		if ok and NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ silent = true })
		end
		NAmanage.PluginsWindow_RequestRebuild()
	end)
	NAmanage.SetAttr(row, "NAPluginSearch", (name.." "..displayName.." "..kind.." "..path.." available install"):lower())
	return row
end

NAmanage.PluginsWindow_Filter = NAmanage.PluginsWindow_Filter or function()
	const list = NAUIMANAGER and NAUIMANAGER.PluginsList
	const filter = NAUIMANAGER and NAUIMANAGER.PluginsFilter
	if not list then return end
	const query = Lower(tostring(filter and filter.Text or ""))
	for _, child in list:GetChildren() do
		if child:IsA("GuiObject") then
			if query == "" then
				child.Visible = true
			else
				const hay = tostring(NAmanage.GetAttr(child, "NAPluginSearch") or child.Name or ""):lower()
				child.Visible = hay:find(query, 1, true) ~= nil
			end
		end
	end
	if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
		NAmanage.CustomScroll.refreshByTarget(list)
	end
end

NAmanage.PluginsWindow_Rebuild = NAmanage.PluginsWindow_Rebuild or function(opts)
	opts = opts or {}
	const frame = NAmanage.EnsurePluginsWindow()
	NAmanage.PluginsWindow_Clear()
	const entries = NAmanage.PluginListFiles and NAmanage.PluginListFiles() or {}
	local builtRows = 0
	const function pulse()
		builtRows += 1
		if builtRows % 8 == 0 then
			Wait()
		end
	end
	NAmanage.PluginsWindow_AddSection("Manager")
	NAmanage.PluginsWindow_AddToggle("Load plugins on startup", NAStuff.PluginAutoLoad ~= false, function(on)
		NAStuff.PluginAutoLoad = on == true
		pcall(NAmanage.NASettingsSet, "pluginAutoLoad", NAStuff.PluginAutoLoad)
		DoNotif("Plugin startup loading "..(on and "enabled" or "disabled"), 2)
	end)
	NAmanage.PluginsWindow_AddToggle("Allow plugin UI controls", NAStuff.PluginSettingsUIEnabled ~= false, function(on)
		NAStuff.PluginSettingsUIEnabled = on == true
		pcall(NAmanage.NASettingsSet, "pluginAllowSettingsUI", NAStuff.PluginSettingsUIEnabled)
		DoNotif("Plugin UI controls "..(on and "enabled" or "disabled"), 2)
	end)
	NAmanage.PluginsWindow_AddButton("Create plugin with Plugin Maker", function()
		if type(NAmanage.PluginMaker_Open) == "function" then
			NAmanage.PluginMaker_Open()
		elseif cmd and cmd.run then
			cmd.run({"pluginmaker"})
		end
	end)
	NAmanage.PluginsWindow_AddButton("Reload enabled plugins", function()
		if NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ forceNotify = true })
		end
		NAmanage.PluginsWindow_RequestRebuild()
	end)
	NAmanage.PluginsWindow_AddInput("Install plugin from URL", "https://.../plugin.na", "", function(text)
		const url = tostring(text or ""):match("^%s*(.-)%s*$") or ""
		if url == "" then return end
		local ok, msg = NAmanage.PluginInstallFromUrl(url)
		DoNotif(ok and ("Installed "..NAmanage.PluginBaseName(msg)) or ("Install failed: "..tostring(msg)), 3)
		if ok and NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ silent = true })
		end
		NAmanage.PluginsWindow_RequestRebuild()
	end)
	NAmanage.PluginsWindow_AddButton("Move all workspace plugins into plugin folders", function()
		if cmd and cmd.run then
			cmd.run({"addallplugins"})
		end
		if NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ silent = true })
		end
		NAmanage.PluginsWindow_RequestRebuild()
	end)
	NAmanage.PluginsWindow_AddButton("Enable all installed plugins", function()
		for _, entry in entries do
			NAmanage.PluginSetEnabled(entry.path, true)
		end
		if NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ silent = true })
		end
		DoNotif("Enabled all installed plugins", 2)
		NAmanage.PluginsWindow_RequestRebuild()
	end)
	NAmanage.PluginsWindow_AddButton("Disable all installed plugins", function()
		for _, entry in entries do
			NAmanage.PluginSetEnabled(entry.path, false)
		end
		if NAmanage.LoadPlugins then
			NAmanage.LoadPlugins({ silent = true })
		end
		DoNotif("Disabled all installed plugins", 2)
		NAmanage.PluginsWindow_RequestRebuild()
	end)
	NAmanage.PluginsWindow_AddSection("Installed Plugins")
	if #entries == 0 then
		NAmanage.PluginsWindow_AddButton("No plugins found in Plugins or PluginsIY", function()
			if cmd and cmd.run then
				cmd.run({"addplugin"})
			end
		end)
	else
		for _, entry in entries do
			NAmanage.PluginsWindow_AddPlugin(entry)
			pulse()
		end
	end
	local available = type(opts.availableEntries) == "table" and opts.availableEntries or nil
	local availablePending = false
	if not available then
		const cachedAvailable = NAmanage.PluginAvailableCacheGet and NAmanage.PluginAvailableCacheGet(30) or nil
		available = cachedAvailable or {}
		availablePending = cachedAvailable == nil
		if availablePending and opts.scanAvailable ~= false and NAmanage.PluginScanAvailableAsync then
			const token = NAStuff.PluginsWindowRebuildRequestToken
			NAmanage.PluginScanAvailableAsync(opts.forceScan == true, function(fresh)
				if frame and frame.Visible == true and token == NAStuff.PluginsWindowRebuildRequestToken and NAmanage.PluginsWindow_RequestRebuild then
					NAmanage.PluginsWindow_RequestRebuild({
						availableEntries = fresh,
						scanAvailable = false,
						placeholder = false,
					})
				end
			end)
		end
	end
	NAmanage.PluginsWindow_AddSection("Available Plugins")
	if #available == 0 then
		NAmanage.PluginsWindow_AddButton(availablePending and "Scanning workspace plugins..." or "No workspace plugins outside Plugins or PluginsIY", function()
			if cmd and cmd.run then
				cmd.run({"addplugin"})
			end
		end)
	else
		for _, entry in available do
			NAmanage.PluginsWindow_AddAvailablePlugin(entry)
			pulse()
		end
	end
	if NAStuff.PluginSettingsUIEnabled ~= false and type(NAmanage._pluginControlSpecs) == "table" then
		const controlGroups = {}
		for _, group in NAmanage._pluginControlSpecs do
			if type(group) == "table" and type(group.items) == "table" and #group.items > 0 then
				Insert(controlGroups, group)
			end
		end
		table.sort(controlGroups, function(a, b)
			return tostring(a.name or "") < tostring(b.name or "")
		end)
		if #controlGroups > 0 then
			NAmanage.PluginsWindow_AddSection("Plugin UI")
			for _, group in controlGroups do
				local lastTab
				for _, item in group.items do
					const tabName = tostring(item.tabName or "Controls")
					if tabName ~= lastTab then
						lastTab = tabName
						NAmanage.PluginsWindow_AddSection(tostring(group.name or "Plugin").." / "..tabName)
					end
					if item.kind == "section" then
						NAmanage.PluginsWindow_AddSection(item.label)
					elseif item.kind == "button" then
						NAmanage.PluginsWindow_AddButton(item.label, item.callback)
					elseif item.kind == "input" then
						NAmanage.PluginsWindow_AddInput(item.label, item.placeholder, item.defaultText, item.callback)
					elseif item.kind == "toggle" then
						NAmanage.PluginsWindow_AddToggle(item.label, item.defaultValue == true, item.callback)
					end
					pulse()
				end
			end
		end
	end
	NAmanage.PluginsWindow_Filter()
	const filter = NAUIMANAGER and NAUIMANAGER.PluginsFilter
	if filter and not NAStuff.PluginsFilterConnected then
		NAStuff.PluginsFilterConnected = true
		filter:GetPropertyChangedSignal("Text"):Connect(NAmanage.PluginsWindow_Filter)
	end
	NAStuff.PluginsWindowHasContent = true
	if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
		NAmanage.CustomScroll.refreshByTarget(NAUIMANAGER and NAUIMANAGER.PluginsList)
	end
end

NAmanage.PluginsWindow_RequestRebuild = NAmanage.PluginsWindow_RequestRebuild or function(opts)
	opts = opts or {}
	const frame = NAmanage.EnsurePluginsWindow and NAmanage.EnsurePluginsWindow()
	if not frame then
		return false
	end
	NAStuff.PluginsWindowRebuildRequestToken = (tonumber(NAStuff.PluginsWindowRebuildRequestToken) or 0) + 1
	const token = NAStuff.PluginsWindowRebuildRequestToken
	if opts.placeholder ~= false and not NAStuff.PluginsWindowHasContent then
		NAmanage.PluginsWindow_Clear()
		NAmanage.PluginsWindow_AddSection("Loading plugins...")
	end
	SpawnCall(function()
		Wait()
		if token ~= NAStuff.PluginsWindowRebuildRequestToken or frame.Visible ~= true then
			return
		end
		if NAmanage.PluginsWindow_Rebuild then
			NAmanage.PluginsWindow_Rebuild(opts)
		end
	end)
	return true
end

NAgui.plugins = function()
	if NAmanage.PluginsWindow_Toggle then
		return NAmanage.PluginsWindow_Toggle()
	end
	const frame = NAmanage.EnsurePluginsWindow and NAmanage.EnsurePluginsWindow()
	if not frame then
		DoNotif("Plugins UI unavailable.", 3)
		return false
	end
	frame.Visible = not frame.Visible
	return true
end

NAmanage.PluginsWindow_Bind = NAmanage.PluginsWindow_Bind or function()
	const frame = NAmanage.EnsurePluginsWindow and NAmanage.EnsurePluginsWindow()
	if not frame then
		return false
	end
	const wasVisible = frame.Visible == true
	if NAgui and type(NAgui.menu) == "function" and NAStuff.PluginsWindowMenuBound ~= frame then
		NAgui.menu(frame)
		NAStuff.PluginsWindowMenuBound = frame
		frame.Visible = wasVisible
	end
	if NAgui and type(NAgui.resizeable) == "function" and NAStuff.PluginsWindowResizeBound ~= frame then
		NAgui.resizeable(frame, Vector2.new(340, 260), Vector2.new(5000, 5000))
		NAStuff.PluginsWindowResizeBound = frame
	end
	if NAmanage.PluginsScroll and NAmanage.PluginsScroll.install then
		NAmanage.PluginsScroll.install()
	end
	if NAmanage.PluginsHorizontalScroll and NAmanage.PluginsHorizontalScroll.install then
		NAmanage.PluginsHorizontalScroll.install()
	end
	return true
end

NAmanage.PluginsWindow_SetVisible = NAmanage.PluginsWindow_SetVisible or function(visible, opts)
	opts = opts or {}
	const frame = NAmanage.EnsurePluginsWindow and NAmanage.EnsurePluginsWindow()
	if not frame then
		DoNotif("Plugins UI unavailable.", 3)
		return false
	end
	if NAmanage.PluginsWindow_Bind then
		NAmanage.PluginsWindow_Bind()
	end
	visible = visible == true
	frame.Visible = visible
	if visible then
		if NAmanage.PluginsScroll and NAmanage.PluginsScroll.scheduleRefresh then
			NAmanage.PluginsScroll.scheduleRefresh()
		end
		if NAmanage.PluginsHorizontalScroll and NAmanage.PluginsHorizontalScroll.scheduleRefresh then
			NAmanage.PluginsHorizontalScroll.scheduleRefresh()
		end
		if opts.refresh ~= false and NAmanage.PluginsWindow_RequestRebuild then
			NAmanage.PluginsWindow_RequestRebuild(opts)
		end
		if opts.center ~= false and NAmanage.centerFrame then
			NAmanage.centerFrame(frame)
		end
	end
	return true
end

NAmanage.PluginsWindow_Toggle = NAmanage.PluginsWindow_Toggle or function(forceState, opts)
	const frame = NAmanage.EnsurePluginsWindow and NAmanage.EnsurePluginsWindow()
	if not frame then
		DoNotif("Plugins UI unavailable.", 3)
		return false
	end
	local nextState = forceState
	if type(nextState) ~= "boolean" then
		nextState = not frame.Visible
	end
	return NAmanage.PluginsWindow_SetVisible(nextState, opts)
end

NAgui._resizeCleanup = NAmanage.ensureWeakTable(NAgui._resizeCleanup, "k")
NAgui.isSettingsLayoutSuspended = NAgui.isSettingsLayoutSuspended or function()
	return NAUIMANAGER
		and NAUIMANAGER.SettingsFrame
		and NAmanage.GetAttr
		and NAmanage.GetAttr(NAUIMANAGER.SettingsFrame, "NAHeavyResizeSuspended") == true
end

NAgui._setHeavyResizeSuspended = NAgui._setHeavyResizeSuspended or function(ui, suspended)
	if not (ui and NAUIMANAGER and ui == NAUIMANAGER.SettingsFrame) then
		return
	end
	const body = ui:FindFirstChild("Container")
	if not (body and body:IsA("GuiObject")) then
		return
	end
	if suspended then
		if NAmanage.GetAttr and NAmanage.GetAttr(ui, "NAResizeBodyWasVisible") == nil then
			NAmanage.SetAttr(ui, "NAResizeBodyWasVisible", body.Visible == true)
		end
		NAmanage.SetAttr(ui, "NAHeavyResizeSuspended", true)
		body.Visible = false
		return
	end
	local wasVisible = true
	if NAmanage.GetAttr then
		const stored = NAmanage.GetAttr(ui, "NAResizeBodyWasVisible")
		if stored ~= nil then
			wasVisible = stored == true
		end
	end
	NAmanage.SetAttr(ui, "NAResizeBodyWasVisible", nil)
	NAmanage.SetAttr(ui, "NAHeavyResizeSuspended", nil)
	if NAmanage.GetAttr and NAmanage.GetAttr(ui, "NAMenuMinimized") == true then
		body.Visible = false
	else
		body.Visible = wasVisible
	end
	if wasVisible and NAUIMANAGER.SettingsList then
		Defer(function()
			if NAUIMANAGER and NAUIMANAGER.SettingsList then
				updateCanvasSize(NAUIMANAGER.SettingsList, NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
			end
		end)
	end
end

NAgui.resizeable = function(ui, min, max)
	if not ui or not ui:IsA("GuiObject") then return function() end end
	const prevCleanup = NAgui._resizeCleanup[ui]
	if prevCleanup then
		pcall(prevCleanup)
		NAgui._resizeCleanup[ui] = nil
	end
	pcall(function()
		NAmanage.SetAttr(ui, "NAResizeActive", nil)
	end)
	const function getUiScale()
		local s = (NAUIMANAGER and NAUIMANAGER.AUTOSCALER and tonumber(NAUIMANAGER.AUTOSCALER.Scale)) or 1
		if not s or s <= 0 then
			s = 1
		end
		return s
	end
	const function getLogicalSize()
		const size = ui.Size
		local lx = tonumber(size.X.Offset) or 0
		local ly = tonumber(size.Y.Offset) or 0
		if size.X.Scale ~= 0 or size.Y.Scale ~= 0 then
			const s = getUiScale()
			const abs = ui.AbsoluteSize
			if size.X.Scale ~= 0 then
				lx = (abs.X or 0) / s
			end
			if size.Y.Scale ~= 0 then
				ly = (abs.Y or 0) / s
			end
		end
		return Vector2.new(lx, ly)
	end

	if not min then
		const baseMin = getLogicalSize()
		min = Vector2.new(
			math.max(1, math.floor(baseMin.X * 0.5 + 0.5)),
			math.max(1, math.floor(baseMin.Y * 0.5 + 0.5))
		)
	end
	max = max or Vector2.new(5000, 5000)

	const screenGui = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui:FindFirstAncestorWhichIsA("LayerCollector") or ui.Parent
	local mouse
	pcall(function()
		if Services.Players and Services.Players.LocalPlayer then
			mouse = NAmanage.GetMouse(Services.Players.LocalPlayer)
		end
	end)

	const rgui = NAUIMANAGER.resizeFrame and NAUIMANAGER.resizeFrame:Clone()
	if not rgui then return function() end end
	rgui.Parent = screenGui
	rgui.BackgroundTransparency = 1
	rgui.ClipsDescendants = false
	NAgui.NAProtection(rgui)

	if NAStuff.ResizeHandleIconsEnabled == true then
		const function resizeIconSpec(name)
			if name == "Left" then return "arrow-medium-left", 0 end
			if name == "Right" then return "arrow-medium-right", 0 end
			if name == "Top" then return "arrow-medium-up", 0 end
			if name == "Bottom" then return "arrow-medium-down", 0 end
			if name == "TopRight" then return "arrow-medium-up", 45 end
			if name == "TopLeft" then return "arrow-medium-up", -45 end
			if name == "BottomLeft" then return "arrow-medium-up", -135 end
			if name == "BottomRight" then return "arrow-medium-up", 135 end
			return nil, 0
		end
		local iconFont
		pcall(function()
			iconFont = Font.new(BUILDER_ICON_FONT_PATH or "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		end)
		for _, handle in rgui:GetChildren() do
			if handle:IsA("GuiObject") then
				local iconText, rotation = resizeIconSpec(handle.Name)
				if iconText then
					handle.Active = true
					handle.Visible = true
					handle.ClipsDescendants = false
					handle.BackgroundTransparency = 1
					local icon = handle:FindFirstChild("NAResizeHandleIcon")
					if not (icon and icon:IsA("TextLabel")) then
						if icon then
							icon:Destroy()
						end
						icon = InstanceNew("TextLabel", handle)
						icon.Name = "NAResizeHandleIcon"
						icon.BackgroundTransparency = 1
						icon.BorderSizePixel = 0
						icon.Active = false
					end
					icon.AnchorPoint = Vector2.new(0.5, 0.5)
					icon.Position = UDim2.fromScale(0.5, 0.5)
					icon.Size = UDim2.new(0, 28, 0, 28)
					icon.ZIndex = math.max(handle.ZIndex + 1, 121)
					icon.FontFace = iconFont or icon.FontFace
					icon.Text = iconText
					icon.TextColor3 = NAUISTROKER or Color3.fromRGB(148, 93, 255)
					icon.TextTransparency = 0
					icon.TextStrokeTransparency = 0.35
					icon.TextStrokeColor3 = Color3.fromRGB(8, 8, 10)
					icon.TextScaled = false
					icon.TextSize = 22
					icon.Rotation = rotation or 0
					icon.Visible = true
				end
			end
		end
	end

	const function updateOverlay()
		const ok = pcall(function()
			if not ui or not ui.Parent or not rgui or not rgui.Parent or not screenGui then
				return
			end
			const s = getUiScale()
			const absPos = ui.AbsolutePosition
			const absSize = ui.AbsoluteSize
			const rootPos = screenGui.AbsolutePosition or Vector2.new(0, 0)
			const relPos = absPos - rootPos
			rgui.Position = UDim2.new(0, math.floor((relPos.X / s) + 0.5), 0, math.floor((relPos.Y / s) + 0.5))
			rgui.Size = UDim2.new(0, math.floor((absSize.X / s) + 0.5), 0, math.floor((absSize.Y / s) + 0.5))
		end)
		if not ok then end
	end

	const function updateVisibility()
		const ok = pcall(function()
			if not ui or not ui.Parent or not rgui or not rgui.Parent then
				return
			end
			rgui.Visible = ui.Visible
		end)
		if not ok then end
	end

	updateOverlay()
	updateVisibility()

	const overlayConns = {}
	pcall(function()
		Insert(overlayConns, ui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateOverlay))
	end)
	pcall(function()
		Insert(overlayConns, ui:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateOverlay))
	end)
	pcall(function()
		Insert(overlayConns, ui:GetPropertyChangedSignal("Visible"):Connect(updateVisibility))
	end)
	pcall(function()
		if NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.GetPropertyChangedSignal then
			Insert(overlayConns, NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(updateOverlay))
		end
	end)

	local dragging = false
	local mode
	local UIPos
	local lastSize
	local lastPos = Vector2.new()
	local dragInput
	local dragEndedConn
	local cursorSaved
	local cursorActive = false
	local touchGestureLocked = false
	local lastResizeUpdate = 0
	local updateResize

	const function isMenuMinimized()
		return ui and ui.GetAttribute and NAmanage.GetAttr(ui, "NAMenuMinimized") == true
	end

	const function ensureMouse()
		if mouse then return mouse end
		pcall(function()
			if Services.Players and Services.Players.LocalPlayer then
				mouse = NAmanage.GetMouse(Services.Players.LocalPlayer)
			end
		end)
		return mouse
	end

	const function setCursor(icon)
		if not ensureMouse() then return end
		if not mouse then return end
		if not cursorActive then
			cursorSaved = mouse.Icon
			cursorActive = true
		end
		mouse.Icon = icon or ""
	end

	const function restoreCursor()
		if not mouse then return end
		if cursorActive then
			mouse.Icon = cursorSaved or ""
			cursorSaved = nil
			cursorActive = false
		elseif mouse.Icon ~= "" then
			mouse.Icon = ""
		end
	end

	const function endDrag()
		if dragging and dragInput and dragInput.Position then
			const p = dragInput.Position
			updateResize(Vector2.new(p.X, p.Y), true)
		end
		if touchGestureLocked then
			NAgui.releaseTouchGesture(ui, "resize", dragInput)
			touchGestureLocked = false
		end
		pcall(function()
			if ui then
				NAmanage.SetAttr(ui, "NAResizeActive", nil)
			end
		end)
		dragging = false
		mode = nil
		dragInput = nil
		if dragEndedConn then dragEndedConn:Disconnect() dragEndedConn = nil end
		restoreCursor()
		if NAgui._setHeavyResizeSuspended then
			NAgui._setHeavyResizeSuspended(ui, false)
		end
	end

	updateResize = function(currentPos, force)
		if ui == (NAUIMANAGER and NAUIMANAGER.SettingsFrame) then
			const now = os.clock()
			if force ~= true and now - lastResizeUpdate < 0.033 then
				return
			end
			lastResizeUpdate = now
		end
		local ok, err = pcall(function()
			if isMenuMinimized() then return end
			if not dragging or not mode or not screenGui or not screenGui.AbsoluteSize then return end
			const map = resizeXY and resizeXY[mode.Name]
			if not map then return end

			const s = getUiScale()
			const delta = (currentPos - lastPos) / s

			const resizeDelta = Vector2.new(delta.X * map[1].X, delta.Y * map[1].Y)
			const newSize = Vector2.new(
				math.clamp(lastSize.X + resizeDelta.X, min.X, max.X),
				math.clamp(lastSize.Y + resizeDelta.Y, min.Y, max.Y)
			)

			ui.Size = UDim2.new(0, newSize.X, 0, newSize.Y)

			local ox = UIPos.X.Offset
			local oy = UIPos.Y.Offset
			if map[1].X < 0 then
				ox = ox + (lastSize.X - newSize.X)
			end
			if map[1].Y < 0 then
				oy = oy + (lastSize.Y - newSize.Y)
			end

			ui.Position = UDim2.new(UIPos.X.Scale, ox, UIPos.Y.Scale, oy)
		end)
		if not ok then warn("Resize update failed:", err) end
	end

	local uisChangedConn, uisEndedConn
	pcall(function()
		uisChangedConn = Services.UserInputService.InputChanged:Connect(function(input)
			pcall(function()
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then
						return
					end
					updateResize(Vector2.new(input.Position.X, input.Position.Y))
				end
			end)
		end)
	end)

	pcall(function()
		uisEndedConn = Services.UserInputService.InputEnded:Connect(function(input)
			pcall(function()
				if not dragging then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					endDrag()
				elseif input.UserInputType == Enum.UserInputType.Touch and input == dragInput then
					endDrag()
				end
			end)
		end)
	end)

	for _, button in rgui:GetChildren() do
		if button:IsA("GuiObject") then
			button.Active = true
			pcall(function()
				Insert(overlayConns, button.InputBegan:Connect(function(input)
					pcall(function()
						if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
							if input.UserInputType == Enum.UserInputType.Touch then
								if not (NAgui.tryLockTouchGesture and NAgui.tryLockTouchGesture(ui, "resize", input)) then
									return
								end
								touchGestureLocked = true
							end
							mode = button
							dragging = true
							pcall(function()
								if ui then
									NAmanage.SetAttr(ui, "NAResizeActive", true)
								end
							end)
							if NAgui._setHeavyResizeSuspended then
								NAgui._setHeavyResizeSuspended(ui, true)
							end
							const p = input.Position
							lastPos = Vector2.new(p.X, p.Y)
							lastSize = getLogicalSize()
							UIPos = ui.Position
							dragInput = input
							if dragEndedConn then dragEndedConn:Disconnect() end
							dragEndedConn = input.Changed:Connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									endDrag()
								end
							end)
						end
					end)
				end))
			end)

			pcall(function()
				Insert(overlayConns, button.InputEnded:Connect(function(input)
					pcall(function()
						if not dragging or mode ~= button or input.UserInputState ~= Enum.UserInputState.End then return end
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							endDrag()
						elseif input.UserInputType == Enum.UserInputType.Touch and input == dragInput then
							endDrag()
						end
					end)
				end))
			end)

			pcall(function()
				Insert(overlayConns, button.MouseEnter:Connect(function()
					pcall(function()
						const map = resizeXY and resizeXY[button.Name]
						if map then setCursor(map[3]) end
					end)
				end))
			end)

			pcall(function()
				Insert(overlayConns, button.MouseLeave:Connect(function()
					pcall(function()
						if not dragging then restoreCursor() end
					end)
				end))
			end)
		end
	end

	local cleaned = false
	local ancestryConn
	pcall(function()
		ancestryConn = ui.AncestryChanged:Connect(function(_, parent)
			if not parent then
				pcall(function()
					if NAgui._resizeCleanup[ui] then
						NAgui._resizeCleanup[ui]()
					end
				end)
			end
		end)
	end)

	const function cleanup()
		if cleaned then return end
		cleaned = true
		NAgui._resizeCleanup[ui] = nil
		pcall(endDrag)
		for _, conn in overlayConns do
			pcall(function() conn:Disconnect() end)
		end
		pcall(function() if ancestryConn then ancestryConn:Disconnect() end end)
		pcall(function() if uisChangedConn then uisChangedConn:Disconnect() end end)
		pcall(function() if uisEndedConn then uisEndedConn:Disconnect() end end)
		pcall(function() if dragEndedConn then dragEndedConn:Disconnect() end end)
		pcall(restoreCursor)
		pcall(function() rgui:Destroy() end)
	end
	NAgui._resizeCleanup[ui] = cleanup
	return cleanup
end
NAmanage.RefreshResizeHandles=function()
	if not (NAgui and type(NAgui.resizeable) == "function" and NAUIMANAGER) then
		return
	end
	local ok, err = pcall(function()
		if NAUIMANAGER.chatLogsFrame then
			NAgui.resizeable(NAUIMANAGER.chatLogsFrame)
		end
		if NAUIMANAGER.NAconsoleFrame then
			NAgui.resizeable(NAUIMANAGER.NAconsoleFrame)
		end
		if NAUIMANAGER.commandsFrame then
			NAgui.resizeable(NAUIMANAGER.commandsFrame, Vector2.new(180, 118), Vector2.new(5000, 5000))
		end
		if NAUIMANAGER.CommandKeybindsFrame then
			NAgui.resizeable(NAUIMANAGER.CommandKeybindsFrame, Vector2.new(520, 360), Vector2.new(1400, 920))
		end
		if NAUIMANAGER.SettingsFrame then
			NAgui.resizeable(NAUIMANAGER.SettingsFrame, NAmanage.GetSettingsResizeMin and NAmanage.GetSettingsResizeMin() or nil, Vector2.new(5000, 5000))
		end
		if NAUIMANAGER.WaypointFrame then
			NAgui.resizeable(NAUIMANAGER.WaypointFrame)
		end
		if NAUIMANAGER.BindersFrame then
			NAgui.resizeable(NAUIMANAGER.BindersFrame)
		end
		if NAUIMANAGER.MusicFrame then
			NAgui.resizeable(NAUIMANAGER.MusicFrame, Vector2.new(380, 280), Vector2.new(1100, 820))
		end
		if NAUIMANAGER.ScriptHubFrame then
			NAgui.resizeable(NAUIMANAGER.ScriptHubFrame, IsOnMobile and Vector2.new(340, 280) or Vector2.new(680, 420), Vector2.new(5000, 5000))
		end
		if NAUIMANAGER.SubplaceViewerFrame then
			NAgui.resizeable(NAUIMANAGER.SubplaceViewerFrame, IsOnMobile and Vector2.new(340, 280) or Vector2.new(680, 420), Vector2.new(5000, 5000))
		end
		if NAUIMANAGER.ServerListFrame then
			NAgui.resizeable(NAUIMANAGER.ServerListFrame, IsOnMobile and Vector2.new(340, 300) or Vector2.new(620, 420), Vector2.new(5000, 5000))
		end
		if NAUIMANAGER.ExecutorFrame then
			const exMin = IsOnMobile and Vector2.new(340, 280) or Vector2.new(680, 420)
			NAgui.resizeable(NAUIMANAGER.ExecutorFrame, exMin, Vector2.new(5000, 5000))
		end
		if NAUIMANAGER.NotepadFrame then
			const npVp = Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
			const npSmall = IsOnMobile or npVp.X < 720 or npVp.Y < 520
			const npMin = npSmall and Vector2.new(280, 230) or Vector2.new(460, 340)
			NAgui.resizeable(NAUIMANAGER.NotepadFrame, npMin, Vector2.new(5000, 5000))
		end
		if NAmanage.PluginsWindow_Bind then
			NAmanage.PluginsWindow_Bind()
		end
	end)
	if not ok then
		warn("RefreshResizeHandles failed:", err)
	end
end
NAmanage.UpdateWaypointList=function()
	const list = NAUIMANAGER.WaypointList
	if not list then
		return
	end
	const rawFilter = NAUIMANAGER.filterBox and NAUIMANAGER.filterBox.Text or ""
	const filterText = rawFilter:lower()
	NAmanage._waypointBuildGen = (tonumber(NAmanage._waypointBuildGen) or 0) + 1
	const buildGen = NAmanage._waypointBuildGen
	local built = 0
	for _, child in list:GetChildren() do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	for name, entry in Waypoints do
		if filterText == "" or name:lower():find(filterText, 1, true) then
			const row = NAUIMANAGER.WPFrame:Clone()
			row.Name = name
			row.Parent = list
			const nameBtn = row:FindFirstChildWhichIsA("TextButton")
			if nameBtn then
				nameBtn.Text = name
			end
			const actionFrame = row:FindFirstChildWhichIsA("Frame")
			if actionFrame then
				const copyBtn = actionFrame:FindFirstChild("CopyBtn")
				const delBtn = actionFrame:FindFirstChild("DelBtn")
				const tpBtn = actionFrame:FindFirstChild("TPBtn")
				const editBtn = actionFrame:FindFirstChild("EditBtn")
				const renameBtn = actionFrame:FindFirstChild("RenameBtn")
				const pathBtn = actionFrame:FindFirstChild("PathBtn")
				if renameBtn then
					MouseButtonFix(renameBtn, function()
						Window({
							Title = "Rename Waypoint",
							Description = "Enter a new name for '"..name.."'.",
							InputField = true,
							Buttons = {
								{
									Text = "Rename",
									Callback = function(input)
										const newName = NAmanage.waypointNameFromArgs(input)
										if not newName or newName == "" then
											return DoNotif("Waypoint name cannot be empty.", 3)
										end
										if newName == name then
											return DebugNotif("Waypoint name unchanged.", 2)
										end
										if Waypoints[newName] then
											return DoNotif(("Waypoint '%s' already exists."):format(newName), 3)
										end
										if not Waypoints[name] then
											return DoNotif(("Waypoint '%s' no longer exists."):format(name), 3)
										end
										Waypoints[newName] = Waypoints[name]
										Waypoints[name] = nil
										const pathState = NAmanage.WaypointPathGetState and NAmanage.WaypointPathGetState()
										local restartLoopPath = false
										if pathState then
											restartLoopPath = pathState.looping == true and pathState.loopTarget == name
											if restartLoopPath and type(NAmanage.WaypointPathStop) == "function" then
												NAmanage.WaypointPathStop(true)
											elseif pathState.followTarget == name then
												pathState.followTarget = newName
											end
											if pathState.lastName == name then
												pathState.lastName = newName
											end
										end
										NAmanage.SaveWaypoints()
										NAmanage.UpdateWaypointList()
										if restartLoopPath and type(NAmanage.WaypointPathLoopStart) == "function" then
											Delay(0, function()
												NAmanage.WaypointPathLoopStart(newName)
											end)
										end
										DebugNotif(("Renamed waypoint '%s' to '%s'."):format(name, newName))
									end
								}
							}
						})
					end)
				end
				if editBtn then
					MouseButtonFix(editBtn, function()
						NAmanage.WaypointOpenCoordinateEditor(name)
					end)
				end
				if pathBtn then
					const pathState = NAmanage.WaypointPathGetState and NAmanage.WaypointPathGetState()
					const followingThis = pathState and pathState.following == true and pathState.followTarget == name
					const loopingThis = pathState and pathState.looping == true and pathState.loopTarget == name
					pathBtn.Text = (followingThis or loopingThis) and "Stop" or "Path"
					pathBtn.BackgroundColor3 = (followingThis or loopingThis) and Color3.fromRGB(185, 55, 55) or Color3.fromRGB(55, 125, 215)
					MouseButtonFix(pathBtn, function()
						if type(NAmanage.WaypointPathToggle) == "function" then
							NAmanage.WaypointPathToggle(name)
						elseif type(NAmanage.WaypointPathFollow) == "function" then
							NAmanage.WaypointPathFollow(name)
						end
					end)
				end
				if copyBtn then
					MouseButtonFix(copyBtn, function()
						const cf = NAmanage.WaypointEntryToCFrame(entry)
						if typeof(cf) ~= "CFrame" then
							return DebugNotif("Waypoint position is invalid", 3)
						end
						const copyText = NAmanage.WaypointFormatCFramePosition(cf)
						if setclipboard then
							pcall(setclipboard, copyText)
							DebugNotif("Copied "..name)
						else
							DebugNotif("Copy not supported")
						end
					end)
				end
				if delBtn then
					MouseButtonFix(delBtn, function()
						const pathState = NAmanage.WaypointPathGetState and NAmanage.WaypointPathGetState()
						if pathState and (pathState.followTarget == name or pathState.loopTarget == name or pathState.lastName == name) and type(NAmanage.WaypointPathStop) == "function" then
							NAmanage.WaypointPathStop(true)
						end
						Waypoints[name] = nil
						NAmanage.SaveWaypoints()
						NAmanage.UpdateWaypointList()
						DebugNotif("Removed '"..name.."'")
					end)
				end
				if tpBtn then
					MouseButtonFix(tpBtn, function()
						const cf = NAmanage.WaypointEntryToCFrame(entry)
						if typeof(cf) ~= "CFrame" then
							return DoNotif(("Waypoint '%s' is invalid."):format(name), 3)
						end
						const char = getChar()
						if char then
							NAmanage.UG_pivotModel(char, cf)
						end
					end)
				end
			end
		end
		built += 1
		if built % 12 == 0 then
			Wait()
			if buildGen ~= NAmanage._waypointBuildGen then
				return
			end
		end
	end
	updateCanvasSize(list, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
end

NAgui.atchSettings = function(row, hoverKey, strength)
	if not (row and row:IsA("GuiObject")) then
		return
	end
	if not (Services.TweenService and NAlib and NAlib.connect and NAlib.disconnect) then
		return
	end

	const key = "NAgui_row_hover:"..tostring(hoverKey or row.Name or "row")
	const baseRowColor = row.BackgroundColor3
	const hoverRowColor = baseRowColor:Lerp(Color3.new(1, 1, 1), strength or 0.08)

	const function tw(color)
		pcall(function()
			__lt.cm("TweenService", "Create", row, TweenInfo.new(0.22, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = color
			}):Play()
		end)
	end

	NAlib.disconnect(key)
	NAlib.connect(key, row.MouseEnter:Connect(function()
		tw(hoverRowColor)
	end))
	NAlib.connect(key, row.MouseLeave:Connect(function()
		tw(baseRowColor)
	end))
	NAlib.connect(key, row:GetPropertyChangedSignal("Parent"):Connect(function()
		if not row.Parent then
			Defer(function()
				NAlib.disconnect(key)
			end)
		end
	end))
end

NAgui.SettingsBuildState = NAgui.SettingsBuildState or {
	count = 0;
	lastYield = 0;
	batch = 10;
	budget = 0.012;
	building = false;
	background = false;
	userInteracted = false;
	userSelectedTab = nil;
}

NAgui.SettingsBuildStep = NAgui.SettingsBuildStep or function()
	const settingsTarget = NAgui.getSettingsTarget and select(1, NAgui.getSettingsTarget()) or (NAUIMANAGER and NAUIMANAGER.SettingsList)
	if not settingsTarget then return end
	NAgui.SettingsBuildState = NAgui.SettingsBuildState or {}
	const state = NAgui.SettingsBuildState
	state.count = (tonumber(state.count) or 0) + 1
	state.building = true
	while NAmanage and type(NAmanage.IsSettingsBuildTeleportPaused) == "function" and NAmanage.IsSettingsBuildTeleportPaused() do
		Wait(0.1)
	end
end

NAgui.SettingsBuildDone = NAgui.SettingsBuildDone or function()
	if type(NAgui.SettingsBuildState) ~= "table" then
		return
	end
	if NAgui.setSettingsTabContext then
		NAgui.setSettingsTabContext(nil)
	end
	NAgui.SettingsBuildState.building = false
	NAgui.SettingsBuildState.background = false
	NAgui.SettingsBuildState.lastYield = 0
end

NAmanage.SettingsBuildTeleportPause = NAmanage.SettingsBuildTeleportPause or {
	active = false;
	token = nil;
	started = 0;
	timeout = 30;
	reason = nil;
}

NAmanage.PauseSettingsBuildForTeleport = function(reason)
	const token = tostring(os.clock())..":"..tostring(math.random(1, 1000000))
	const st = NAmanage.SettingsBuildTeleportPause or {}
	st.active = true
	st.token = token
	st.started = tick()
	st.timeout = 30
	st.reason = tostring(reason or "teleport")
	NAmanage.SettingsBuildTeleportPause = st
	NAStuff.SettingsBuildPausedForTeleport = true
	NAStuff.SettingsBuildPauseToken = token
	if NAAssetsLoading and type(NAAssetsLoading.setStatus) == "function" then
		pcall(NAAssetsLoading.setStatus, "rejoining")
	end
	return token
end

NAmanage.ResumeSettingsBuildAfterTeleport = function(token, reason)
	const st = NAmanage.SettingsBuildTeleportPause
	if type(st) ~= "table" then
		return false
	end
	if token and st.token and token ~= st.token then
		return false
	end
	st.active = false
	st.token = nil
	st.started = 0
	st.reason = nil
	NAStuff.SettingsBuildPausedForTeleport = false
	NAStuff.SettingsBuildPauseToken = nil
	if NAStuff.SettingsBuildRunning == true and NAAssetsLoading and type(NAAssetsLoading.setStatus) == "function" then
		pcall(NAAssetsLoading.setStatus, "building settings")
	end
	return true
end

NAmanage.IsSettingsBuildTeleportPaused = function()
	const st = NAmanage.SettingsBuildTeleportPause
	if type(st) ~= "table" or st.active ~= true then
		return false
	end
	const started = tonumber(st.started) or 0
	const timeout = tonumber(st.timeout) or 30
	if started > 0 and timeout > 0 and tick() - started > timeout then
		NAmanage.ResumeSettingsBuildAfterTeleport(st.token, "timeout")
		return false
	end
	return true
end

NAgui.addButton = function(label, callback)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("button") end
	const button = templates.Button:Clone()
	button.Title.Text = label
	NAmanage.SetSearch.tag(button, label)
	button.Parent = settingsList
	button.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	NAmanage.registerElementForCurrentTab(button, settingsTabName)
	if NAgui.RegisterStrokesFrom then
		NAgui.RegisterStrokesFromAsync(button)
	end
	NAgui.atchSettings(button, "button:"..tostring(label)..":"..tostring(button.LayoutOrder), 0.08)

	MouseButtonFix(button.Interact,function()
		pcall(callback)
	end)
	return button
end

NAgui.addSection = function(titleText)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if type(NAgui.SettingsBuildState) == "table" and NAgui.SettingsBuildState.background == true then
		NAmanage.MarkExternalLagProbe("settings_section:"..tostring(settingsTabName or "?")..":"..tostring(titleText or ""))
	end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("section") end
	const section = templates.SectionTitle:Clone()
	section.Title.Text = titleText
	pcall(function()
		NAmanage.SetAttr(section, "NASettingsSection", true)
	end)
	NAmanage.SetSearch.tag(section, titleText)
	section.Parent = settingsList
	section.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	NAmanage.registerElementForCurrentTab(section, settingsTabName)
	if NAgui.RegisterStrokesFrom then
		NAgui.RegisterStrokesFromAsync(section)
	end
end

NAgui.getInputMinWidth=function(frame, fallback)
	fallback = fallback or 32
	if not (frame and frame.GetAttribute) then
		return fallback
	end
	local ok, attr = pcall(function()
		return NAmanage.GetAttr(frame, "NAMinWidth")
	end)
	const minAttr = tonumber(ok and attr or nil)
	if not minAttr then
		return fallback
	end
	return math.max(fallback, minAttr)
end

NAgui.getInputMeasureText=function(box)
	if not box then
		return ""
	end

	local text = tostring(box.Text or "")
	local okContent, contentText = pcall(function()
		return box.ContentText
	end)
	if okContent and type(contentText) == "string" and contentText ~= "" then
		local focused = false
		local okFocused, isFocused = pcall(function()
			return box:IsFocused()
		end)
		if okFocused and isFocused == true then
			focused = true
		end
		if focused or text == "" then
			text = contentText
		end
	end

	return text
end

NAgui.getInputTextWidth=function(box, padding)
	padding = padding or 24
	if not box then
		return padding
	end
	const measureText = NAgui.getInputMeasureText(box)

	if box.TextScaled and Services.TextService then
		local okScaled, sizeScaled = pcall(function()
			const fontSize = tonumber(box.TextSize) or 14
			return __lt.cm("TextService", "GetTextSize", measureText, fontSize, box.Font or Enum.Font.SourceSans, Vector2.new(1e4, 1e3))
		end)
		if okScaled and sizeScaled and type(sizeScaled.X) == "number" then
			return sizeScaled.X + padding
		end
	end

	local okBounds, bounds = pcall(function()
		return box.TextBounds
	end)
	if okBounds and bounds and type(bounds.X) == "number" then
		return bounds.X + padding
	end

	if Services.TextService then
		local okSize, size = pcall(function()
			return __lt.cm("TextService", "GetTextSize", measureText, box.TextSize or 14, box.Font or Enum.Font.SourceSans, Vector2.new(1e4, 1e3))
		end)
		if okSize and size and type(size.X) == "number" then
			return size.X + padding
		end
	end

	return 56
end

NAgui.addInfo = function(label, value, opts)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return nil end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("info") end
	opts = type(opts) == "table" and opts or {}

	const info = templates.Input:Clone()
	info.Name = "Info"
	info.Title.Text = label
	NAmanage.SetSearch.tag(info, label)

	info.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	info.Parent = settingsList
	NAmanage.registerElementForCurrentTab(info, settingsTabName)
	if NAgui.RegisterStrokesFrom then
		NAgui.RegisterStrokesFromAsync(info)
	end
	NAgui.atchSettings(info, "info:"..tostring(label)..":"..tostring(info.LayoutOrder), 0.06)

	const frame = info.InputFrame
	if not frame then
		return nil
	end

	const box = frame.InputBox
	if not box then
		return nil
	end

	box.Text = value or ""
	box.PlaceholderText = ""
	box.ClearTextOnFocus = false
	pcall(function()
		box.TextEditable = false
	end)
	pcall(function()
		box.Interactable = false
	end)
	box.Active = false
	box.Selectable = false

	local sideChip, sideBtn
	local sideChipWidth = 0
	if opts.sideChip then
		const tgl = templates.Toggle:Clone()
		const sw = tgl:FindFirstChild("Switch")
		if sw then
			sideChip = sw:Clone()
			sideChip.Name = "SideButton"
			sideChip.Parent = info
			tgl:Destroy()

			sideChipWidth = sideChip.Size.X.Offset
			if sideChipWidth <= 0 then
				sideChipWidth = 45
			end

			local sideChipHeight = sideChip.Size.Y.Offset
			if sideChipHeight <= 0 then
				sideChipHeight = 22
			end

			sideChip.AnchorPoint = Vector2.new(1, 0.5)
			sideChip.Position = UDim2.new(1, -15, 0.5, 0)
			sideChip.Size = UDim2.new(0, sideChipWidth, 0, sideChipHeight)

			frame.AnchorPoint = Vector2.new(1, 0.5)
			frame.Position = UDim2.new(1, -15 - sideChipWidth - 6, 0.5, 0)

			const chipInd = sideChip:FindFirstChild("Indicator")
			if chipInd then
				chipInd.Visible = false
			end

			sideBtn = InstanceNew("TextButton")
			sideBtn.Name = "ChipInteract"
			sideBtn.BackgroundTransparency = 1
			sideBtn.Text = tostring(opts.sideText or "Copy")
			sideBtn.TextColor3 = Color3.new(1, 1, 1)
			sideBtn.TextSize = 12
			sideBtn.Font = Enum.Font.GothamSemibold
			sideBtn.AutoButtonColor = false
			sideBtn.Size = UDim2.new(1, 0, 1, 0)
			sideBtn.ZIndex = (sideChip.ZIndex or 1) + 1
			sideBtn.Parent = sideChip

			NAgui.deferSettingsWork(function()
				if not sideChip.Parent then
					return
				end
				for _, d in NAmanage.QueryDescendants(sideChip, "GuiObject") do
					d.ZIndex = math.max(d.ZIndex or 1, sideBtn.ZIndex or 1)
				end
			end)

			local sideBusy = false
			MouseButtonFix(sideBtn, function()
				if sideBusy then
					return
				end
				sideBusy = true

				const oldText = sideBtn.Text
				local ok, result = true, true

				if type(opts.sideClick) == "function" then
					ok, result = pcall(opts.sideClick, box, info, sideBtn)
				elseif type(opts.sideSet) == "function" then
					ok, result = pcall(opts.sideSet, box.Text, box, info, sideBtn)
				end

				if ok and result ~= false then
					sideBtn.Text = tostring(opts.sideDoneText or "Copied")
					Delay(0.7, function()
						if sideBtn and sideBtn.Parent then
							sideBtn.Text = oldText
						end
						sideBusy = false
					end)
				else
					sideBusy = false
				end
			end)
		else
			tgl:Destroy()
		end
	end

	box.TextXAlignment = Enum.TextXAlignment.Center
	box.TextWrapped = opts.textWrapped == true
	box.MultiLine = opts.textWrapped == true
	if opts.textWrapped == true then
		box.Size = UDim2.new(box.Size.X.Scale, box.Size.X.Offset, 1, -12)
	end
	box.TextYAlignment = opts.textYAlignment == "Top" and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
	box.TextTruncate = Enum.TextTruncate.None
	const textScaledEnabled = opts.textScaled ~= false
	box.TextScaled = textScaledEnabled
	box.ClipsDescendants = true
	frame.ClipsDescendants = true
	const inputHeight = math.max(30, math.floor(tonumber(opts.inputHeight) or 30))
	const rowHeight = math.max(56, math.floor(tonumber(opts.rowHeight) or 56))
	const fillWidth = opts.fillWidth == true
	const autoHeight = opts.autoHeight == true
	const minInputHeight = math.max(30, math.floor(tonumber(opts.minInputHeight) or 30))
	const maxInputHeight = math.max(minInputHeight, math.floor(tonumber(opts.maxInputHeight) or 96))
	if autoHeight then
		frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, inputHeight)
		info.Size = UDim2.new(info.Size.X.Scale, info.Size.X.Offset, 0, math.max(56, inputHeight + 16))
	elseif opts.rowHeight ~= nil then
		info.Size = UDim2.new(info.Size.X.Scale, info.Size.X.Offset, 0, rowHeight)
	end
	const baseTextSize = tonumber(opts.textSize) or tonumber(box.TextSize) or 14
	local minTextSize = tonumber(opts.minTextSize) or 10
	if minTextSize > baseTextSize then
		minTextSize = baseTextSize
	end
	const clampAlignLeft = opts.clampAlignLeft ~= false
	const autoShrink = opts.autoShrink ~= false

	local lastW
	local lastH
	local resizeBusy = false
	local resizeQueued = false
	local resizePending = false
	local resize
	local requestResize

	requestResize = function()
		if resizeBusy then
			resizePending = true
			return
		end
		if resizeQueued then
			return
		end
		resizeQueued = true
		Delay(0.03, function()
			resizeQueued = false
			if resize and info and info.Parent then
				resize()
			end
		end)
	end

	const function finishResize()
		resizeBusy = false
		if resizePending then
			resizePending = false
			requestResize()
		end
	end

	resize = function()
		if resizeBusy then
			resizePending = true
			return
		end
		if NAgui.isSettingsLayoutSuspended and NAgui.isSettingsLayoutSuspended() then
			resizePending = true
			Delay(0.08, function()
				if info and info.Parent then
					requestResize()
				end
			end)
			return
		end
		if not (info and info.Parent and frame and frame.Parent and box and box.Parent) then
			return
		end

		resizeBusy = true

		const textW = NAgui.getInputTextWidth(box)
		const minW = NAgui.getInputMinWidth(frame)
		local maxW

		local cw = info.AbsoluteSize.X
		if (not cw or cw <= 0) and info.Parent then
			cw = info.Parent.AbsoluteSize.X
		end
		if (not cw or cw <= 0) and settingsList then
			cw = settingsList.AbsoluteSize.X
		end

		if cw and cw > 0 then
			const tw = (info.Title and info.Title.TextBounds.X or 0)
			local gap = 32
			if sideChip then
				local extra = sideChipWidth
				if extra <= 0 then
					extra = 45
				end
				gap = gap + extra + 6
			end
			maxW = cw - tw - gap
		end

		local w = math.max(textW, minW)
		local hit = false
		if maxW then
			if fillWidth then
				w = math.max(minW, maxW)
				hit = true
			else
				const clamped = math.max(minW, math.min(w, maxW))
				hit = clamped >= (maxW - 0.5)
				w = clamped
			end
		end

		const targetAlignment = ((fillWidth or hit) and clampAlignLeft) and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
		if box.TextXAlignment ~= targetAlignment then
			box.TextXAlignment = targetAlignment
		end

		if not textScaledEnabled then
			local targetTextSize = baseTextSize
			if hit and autoShrink then
				const avail = math.max(1, w - 14)
				const rawWidth = math.max(1, NAgui.getInputTextWidth(box, 0))
				if rawWidth > avail then
					targetTextSize = math.max(minTextSize, math.floor(baseTextSize * (avail / rawWidth)))
				end
			end
			if box.TextSize ~= targetTextSize then
				box.TextSize = targetTextSize
			end
		end

		if type(w) ~= "number" then
			finishResize()
			return
		end

		local targetInputHeight = inputHeight
		if autoHeight and box.TextWrapped then
			local measuredHeight = baseTextSize
			const textService = Services.TextService
			if textService then
				local font = box.Font
				if font == nil or font == Enum.Font.Unknown then
					font = Enum.Font.SourceSans
				end
				local okMeasure, measured = pcall(textService.GetTextSize, textService, tostring(box.Text or ""), tonumber(box.TextSize) or baseTextSize, font, Vector2.new(math.max(1, w - 16), 10000))
				if okMeasure and measured then
					measuredHeight = measured.Y
				end
			end
			targetInputHeight = math.clamp(math.ceil(measuredHeight + 12), minInputHeight, maxInputHeight)
			const targetRowHeight = math.max(56, targetInputHeight + 16)
			const targetInfoSize = UDim2.new(info.Size.X.Scale, info.Size.X.Offset, 0, targetRowHeight)
			if info.Size ~= targetInfoSize then
				info.Size = targetInfoSize
			end
		end

		if not lastW or not lastH or math.abs(lastW - w) > 0.5 or math.abs(lastH - targetInputHeight) > 0.5 then
			lastW = w
			lastH = targetInputHeight
			const targetSize = UDim2.new(0, w, 0, targetInputHeight)
			if frame.Size ~= targetSize then
				frame.Size = targetSize
			end
			if sideChip then
				const targetChipPosition = UDim2.new(1, -15, 0.5, 0)
				const targetFramePosition = UDim2.new(1, -15 - sideChipWidth - 6, 0.5, 0)
				if sideChip.Position ~= targetChipPosition then
					sideChip.Position = targetChipPosition
				end
				if frame.Position ~= targetFramePosition then
					frame.Position = targetFramePosition
				end
			end
		end

		finishResize()
	end

	box:GetPropertyChangedSignal("TextBounds"):Connect(requestResize)
	box:GetPropertyChangedSignal("Text"):Connect(requestResize)
	info:GetPropertyChangedSignal("AbsoluteSize"):Connect(requestResize)
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(requestResize)
	if settingsList and settingsList:IsA("GuiObject") then
		settingsList:GetPropertyChangedSignal("AbsoluteSize"):Connect(requestResize)
		settingsList:GetPropertyChangedSignal("Visible"):Connect(requestResize)
	end
	resize()
	Defer(function() requestResize() end)
	Delay(0.12, function() requestResize() end)
	Delay(0.35, function() requestResize() end)

	const interact = frame:FindFirstChild("Interact")
	if interact then
		interact.Visible = false
	end

	return box, info
end

NAgui._toggleRegistry = NAgui._toggleRegistry or {}
NAgui._colorPickerRegistry = NAgui._colorPickerRegistry or {}
NAgui._sliderRegistry = NAgui._sliderRegistry or {}
NAgui._inputRegistry = NAgui._inputRegistry or {}
NAgui._dropdownRegistry = NAgui._dropdownRegistry or {}
NAgui._keybindRegistry = NAgui._keybindRegistry or {}

NAgui.addToggle = function(lbl, def, cb, opt)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("toggle") end
	opt = opt or {}
	cb = type(cb) == "function" and cb or function() end

	const tgl = templates.Toggle:Clone()
	const sw = tgl:FindFirstChild("Switch")
	const ind = sw and sw:FindFirstChild("Indicator")
	const st = ind and ind:FindFirstChildWhichIsA("UIStroke")
	const swStroke = sw and sw:FindFirstChildWhichIsA("UIStroke")
	const rowStroke = tgl:FindFirstChild("UIStroke")
	const title = tgl:FindFirstChild("Title")

	if sw then
		pcall(function() sw.Active = false end)
		pcall(function() sw.Selectable = false end)
	end

	local it = tgl:FindFirstChild("Interact")
	if it then
		it:Destroy()
	end

	it = InstanceNew("ImageButton")
	it.Name = "Interact"
	it.BackgroundTransparency = 1
	it.ImageTransparency = 1
	it.AutoButtonColor = false
	it.Active = true
	it.Selectable = false
	it.ZIndex = 999999
	it.AnchorPoint = Vector2.new(1, 0.5)
	it.Position = UDim2.new(1, -15, 0.5, 0)
	it.Size = UDim2.new(0, 45, 0, 22)
	it.Parent = tgl

	local cbtn
	if opt.sideChip and sw then
		const chip = sw:Clone()
		chip.Name = "SideSwitch"
		chip.Parent = tgl

		local w = sw.Size.X.Offset
		if w <= 0 then w = 45 end

		sw.AnchorPoint = Vector2.new(1, 0.5)
		sw.Position = UDim2.new(1, -15, 0.5, 0)

		chip.AnchorPoint = Vector2.new(1, 0.5)
		chip.Position = UDim2.new(1, -15 - w - 6, 0.5, 0)
		chip.Size = UDim2.new(0, w, 0, sw.Size.Y.Offset)

		it.AnchorPoint = Vector2.new(1, 0.5)
		it.Position = UDim2.new(1, -15, 0.5, 0)
		it.Size = UDim2.new(0, 45, 0, 22)

		const cind = chip:FindFirstChild("Indicator")
		const cst = chip:FindFirstChildWhichIsA("UIStroke", true)
		local con = false

		const function cupd()
			if cind then
				const onx = chip.AbsoluteSize.X - cind.AbsoluteSize.X - 4
				const offx = 2
				const toPos = UDim2.new(0, con and onx or offx, 0.5, 0)
				pcall(function()
					__lt.cm("TweenService", "Create", cind, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
						Position = toPos
					}):Play()
				end)
				cind.Visible = false
			end
			if cst then
				pcall(function()
					__lt.cm("TweenService", "Create", cst, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						Color = con and Color3.fromRGB(155, 100, 255) or Color3.fromRGB(72, 72, 72)
					}):Play()
				end)
			end
		end

		if type(opt.sideGet) == "function" then
			local ok, v = pcall(opt.sideGet)
			if ok then con = v and true or false end
		end
		cupd()

		cbtn = InstanceNew("TextButton")
		cbtn.Name = "ChipInteract"
		cbtn.BackgroundTransparency = 1
		cbtn.Text = "Use"
		cbtn.TextColor3 = Color3.new(1, 1, 1)
		cbtn.AutoButtonColor = false
		cbtn.Size = UDim2.new(1, 0, 1, 0)
		cbtn.Parent = chip

		chip.ZIndex = it.ZIndex + 1
		NAgui.deferSettingsWork(function()
			if not chip.Parent then
				return
			end
			for _, d in NAmanage.QueryDescendants(chip, "GuiObject") do
				d.ZIndex = it.ZIndex + 2
			end
		end)
		cbtn.ZIndex = it.ZIndex + 3

		MouseButtonFix(cbtn, function()
			con = not con
			cupd()
			if type(opt.sideSet) == "function" then
				pcall(opt.sideSet, con)
			end
		end)
	end

	tgl.Title.Text = lbl
	NAmanage.SetSearch.tag(tgl, lbl)
	tgl.Parent = settingsList
	tgl.ZIndex = 1
	NAgui.deferSettingsWork(function()
		if not tgl.Parent then
			return
		end
		for _, d in NAmanage.QueryDescendants(tgl, "GuiObject") do
			d.ZIndex = d == it and 999999 or d.ZIndex
		end
	end)
	tgl.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	NAmanage.registerElementForCurrentTab(tgl, settingsTabName)

	const baseRowColor = tgl.BackgroundColor3
	const hoverRowColor = baseRowColor:Lerp(Color3.new(1, 1, 1), 0.08)
	local on = def and true or false
	local busy = false

	const function tw(obj, info, goal)
		if not obj then return nil end
		local ok, tween = pcall(function()
			return __lt.cm("TweenService", "Create", obj, info, goal)
		end)
		if ok and tween then
			tween:Play()
			return tween
		end
		return nil
	end

	const function animateRowHover(show)
		const rowColor = show and hoverRowColor or baseRowColor
		tw(tgl, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = rowColor
		})
	end

	const function applyToggleVisual(state, opts2)
		opts2 = opts2 or {}
		const animate = opts2.animate ~= false
		const pulse = opts2.pulse == true

		if not ind then
			return
		end

		const onPos = UDim2.new(1, -20, 0.5, 0)
		const offPos = UDim2.new(1, -40, 0.5, 0)
		const toPos = state and onPos or offPos
		const toColor = state and Color3.fromRGB(60, 200, 80) or Color3.fromRGB(111, 111, 121)
		const toStroke = state and Color3.fromRGB(50, 255, 80) or Color3.fromRGB(80, 80, 80)
		const toOuterStroke = state and Color3.fromRGB(84, 208, 102) or Color3.fromRGB(72, 72, 72)

		if animate then
			animateRowHover(true)
			if rowStroke then
				tw(rowStroke, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 1
				})
			end
			tw(ind, TweenInfo.new(state and 0.5 or 0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = toPos
			})
			tw(ind, TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = toColor
			})
			if st then
				tw(st, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color = toStroke
				})
			end
			if swStroke then
				tw(swStroke, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Color = toOuterStroke
				})
			end
			if pulse then
				const mini = UDim2.new(0, 12, 0, 12)
				const resetSize = UDim2.new(0, 17, 0, 17)
				const down = tw(ind, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = mini })
				if down then
					pcall(function()
						down.Completed:Connect(function()
							tw(ind, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = resetSize })
						end)
					end)
				else
					ind.Size = resetSize
				end
			end
			Delay(0.05, function()
				animateRowHover(false)
				if rowStroke then
					tw(rowStroke, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						Transparency = 0
					})
				end
			end)
		else
			ind.Position = toPos
			ind.BackgroundColor3 = toColor
			if st then st.Color = toStroke end
			if swStroke then swStroke.Color = toOuterStroke end
		end
	end

	const function flashToggleError(message)
		tw(tgl, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(85, 0, 0)
		})
		if rowStroke then
			tw(rowStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			})
		end
		const prevTitle = title and title.Text or nil
		if title then
			title.Text = "Callback Error"
		end
		warn("[NA] Toggle callback error ("..tostring(lbl).."): "..tostring(message))
		Delay(0.5, function()
			if not tgl.Parent then
				return
			end
			if title and prevTitle ~= nil then
				title.Text = prevTitle
			end
			tw(tgl, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = baseRowColor
			})
			if rowStroke then
				tw(rowStroke, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 0
				})
			end
		end)
	end

	const function set(v, o)
		o = o or {}
		const want = v and true or false
		if not o.force and on == want then
			if o.fire then
				local ok, err = pcall(cb, on)
				if not ok then
					flashToggleError(err)
				end
			end
			return
		end
		on = want
		applyToggleVisual(on, {
			animate = o.animate ~= false,
			pulse = o.pulse == true
		})
		if o.fire ~= false then
			local ok, err = pcall(cb, on)
			if not ok then
				flashToggleError(err)
			end
		end
	end

	if rowStroke then
		rowStroke.Transparency = 1
		tw(rowStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Transparency = 0 })
	end
	if title then
		title.TextTransparency = 1
		tw(title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { TextTransparency = 0 })
	end
	tgl.BackgroundTransparency = 1
	tw(tgl, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })

	set(on, { force = true, fire = false, animate = false, pulse = false })

	NAlib.connect("NAgui_toggle_hover:"..tostring(lbl)..":"..tostring(tgl.LayoutOrder), tgl.MouseEnter:Connect(function()
		animateRowHover(true)
	end))
	NAlib.connect("NAgui_toggle_hover:"..tostring(lbl)..":"..tostring(tgl.LayoutOrder), tgl.MouseLeave:Connect(function()
		animateRowHover(false)
	end))

	const function clk()
		if busy then return end
		busy = true
		set(not on, { force = true, fire = true, animate = true, pulse = true })
		Defer(function()
			busy = false
		end)
	end

	MouseButtonFix(it, clk)

	const ent = {
		button = tgl;
		get = function() return on end;
		set = function(v, o)
			o = o or {}
			if o.force == nil then o.force = true end
			if o.animate == nil then o.animate = true end
			set(v, o)
		end;
	}
	NAgui._toggleRegistry[lbl] = ent

	tgl:GetPropertyChangedSignal("Parent"):Connect(function()
		if not tgl.Parent and NAgui._toggleRegistry[lbl] == ent then
			NAgui._toggleRegistry[lbl] = nil
		end
	end)

	return tgl
end

NAgui.setToggleState = function(label, value, opts)
	const entry = NAgui._toggleRegistry and NAgui._toggleRegistry[label]
	if not entry then return end
	entry.set(value, opts)
end

NAgui.addColorPicker = function(label, defaultColor, callback, opts)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("color") end
	callback = type(callback) == "function" and callback or function() end

	const cfg = opts or {}

	const picker = templates.ColorPicker:Clone()
	picker.Title.Text = label
	NAmanage.SetSearch.tag(picker, label)
	picker.Parent = settingsList
	picker.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	NAmanage.registerElementForCurrentTab(picker, settingsTabName)

	const bg = picker.CPBackground
	const disp = bg.Display
	const main = bg.MainCP
	const sl = picker.ColorSlider
	const rgb = picker.RGB
	const hex = picker.HexInput
	const rowStroke = picker:FindFirstChild("UIStroke")
	const title = picker:FindFirstChild("Title")
	local interact = picker:FindFirstChild("Interact")
	const baseRowColor = picker.BackgroundColor3
	const hoverRowColor = baseRowColor:Lerp(Color3.new(1, 1, 1), 0.08)
	local opened = false

	local rgbTog = picker:FindFirstChild("RGBToggle")
	local rgbBtn, rgbSw, rgbDot, rgbTit

	if rgbTog and rgbTog:IsA("GuiObject") then
		rgbBtn = rgbTog:FindFirstChild("Interact")
		rgbSw = rgbTog:FindFirstChild("Switch")
		if rgbSw then
			rgbDot = rgbSw:FindFirstChild("Indicator")
		end
		rgbTit = rgbTog:FindFirstChild("Title")
	end

	if not (rgbTog and rgbBtn and rgbSw and rgbDot and rgbTit) then
		rgbTog, rgbBtn, rgbSw, rgbDot, rgbTit = NAgui.MakeSwitchRow(picker, "RGBToggle", "RGB Cycle")
	end

	if not (interact and interact:IsA("GuiButton")) then
		interact = InstanceNew("TextButton")
		interact.Name = "Interact"
		interact.BackgroundTransparency = 1
		interact.BorderSizePixel = 0
		interact.Text = ""
		interact.AutoButtonColor = false
		interact.AnchorPoint = Vector2.new(0.5, 0.5)
		interact.Position = UDim2.new(0.5, 0, 0.5, 0)
		interact.Size = UDim2.new(1, 0, 1, 0)
		interact.Parent = picker
	end

	const function tw(obj, info, goal)
		if not obj then return nil end
		local ok, tween = pcall(function()
			return __lt.cm("TweenService", "Create", obj, info, goal)
		end)
		if ok and tween then
			tween:Play()
			return tween
		end
		return nil
	end

	const function flashColorPickerError(message)
		tw(picker, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(85, 0, 0)
		})
		if rowStroke then
			tw(rowStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			})
		end
		const prevTitle = title and title.Text or nil
		if title then
			title.Text = "Callback Error"
		end
		warn("[NA] ColorPicker callback error ("..tostring(label).."): "..tostring(message))
		Delay(0.5, function()
			if not picker.Parent then
				return
			end
			if title and prevTitle ~= nil then
				title.Text = prevTitle
			end
			tw(picker, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = baseRowColor
			})
			if rowStroke then
				tw(rowStroke, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 0
				})
			end
		end)
	end

	const function runColorCallback(col, optPack)
		local ok, err = pcall(callback, col, optPack)
		if not ok then
			flashColorPickerError(err)
		end
	end

	const function getSaved()
		if type(label) ~= "string" then return nil end
		if not (NAmanage and type(NAmanage.NASettingsGet) == "function") then return nil end
		const st = NAmanage.NASettingsGet("colorPickerAutoRGB")
		if type(st) ~= "table" then return nil end
		const v = st[label]
		if type(v) == "boolean" then return v end
		return nil
	end

	const function saveState(sta)
		if type(label) ~= "string" then return end
		if not (NAmanage and type(NAmanage.NASettingsGet) == "function" and type(NAmanage.NASettingsSet) == "function") then return end
		local st = NAmanage.NASettingsGet("colorPickerAutoRGB")
		if type(st) ~= "table" then st = {} end
		const nxt = {}
		for k,v in st do nxt[k] = v end
		nxt[label] = sta and true or false
		NAmanage.NASettingsSet("colorPickerAutoRGB", nxt)
	end

	rgbTit = rgbTog:FindFirstChild("Title")

	rgbBtn = rgbTog:FindFirstChild("Interact")
	if not (rgbBtn and rgbBtn:IsA("GuiButton")) then
		rgbBtn = InstanceNew("TextButton")
		rgbBtn.Name = "Interact"
		rgbBtn.BackgroundTransparency = 1
		rgbBtn.AutoButtonColor = false
		rgbBtn.BorderSizePixel = 0
		rgbBtn.Text = ""
		rgbBtn.Size = UDim2.new(1, 0, 1, 0)
		rgbBtn.ZIndex = (rgbTog.ZIndex or 1) + 1
		rgbBtn.Parent = rgbTog
	end

	rgbSw = rgbTog:FindFirstChild("Switch")
	if not (rgbSw and rgbSw:IsA("GuiObject")) then
		rgbSw = InstanceNew("Frame")
		rgbSw.Name = "Switch"
		rgbSw.BorderSizePixel = 0
		rgbSw.AnchorPoint = Vector2.new(1, 0.5)
		rgbSw.Position = UDim2.new(1, -12, 0.5, 0)
		rgbSw.Size = UDim2.new(0, 45, 0, 22)
		rgbSw.BackgroundColor3 = Color3.fromRGB(49, 49, 54)
		rgbSw.Parent = rgbTog

		const c = InstanceNew("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = rgbSw

		const st = InstanceNew("UIStroke")
		st.Color = Color3.fromRGB(71, 71, 71)
		st.Parent = rgbSw
	end

	rgbDot = rgbSw:FindFirstChild("Indicator")
	if not (rgbDot and rgbDot:IsA("GuiObject")) then
		rgbDot = InstanceNew("Frame")
		rgbDot.Name = "Indicator"
		rgbDot.BorderSizePixel = 0
		rgbDot.AnchorPoint = Vector2.new(0, 0.5)
		rgbDot.Position = UDim2.new(0, 2, 0.5, 0)
		rgbDot.Size = UDim2.new(0, 18, 0, 18)
		rgbDot.BackgroundColor3 = Color3.fromRGB(114, 114, 124)
		rgbDot.Parent = rgbSw

		const c = InstanceNew("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = rgbDot

		const st = InstanceNew("UIStroke")
		st.Color = Color3.fromRGB(83, 83, 83)
		st.Parent = rgbDot
	end

	const pickerConns = {}
	local pickerDestroyed = false
	local rgbLoopConn = nil
	local startRgbLoop = nil
	local dM, dS = false, false
	local inM, inS
	local dragChangedConn, dragEndedConn = nil, nil

	const function trackPickerConn(conn)
		if conn then
			Insert(pickerConns, conn)
		end
		return conn
	end

	const function stopRgbLoop()
		if rgbLoopConn then
			rgbLoopConn:Disconnect()
			rgbLoopConn = nil
		end
	end

	const function stopDragListeners()
		if dragChangedConn then
			dragChangedConn:Disconnect()
			dragChangedConn = nil
		end
		if dragEndedConn then
			dragEndedConn:Disconnect()
			dragEndedConn = nil
		end
	end

	const function cleanupPickerConnections()
		if pickerDestroyed then
			return
		end
		pickerDestroyed = true
		stopRgbLoop()
		stopDragListeners()
		for i = 1, #pickerConns do
			const conn = pickerConns[i]
			if conn then
				pcall(function()
					conn:Disconnect()
				end)
			end
		end
		for i = #pickerConns, 1, -1 do
			pickerConns[i] = nil
		end
		dM, dS = false, false
		inM, inS = nil, nil
	end

	const pickerOpenSize = picker.Size
	const bgOpenSize = bg.Size
	const bgOpenTr = bg.BackgroundTransparency
	const dispOpenTr = 1
	const interactOpenSize = interact.Size
	const interactOpenPos = interact.Position
	const bgOpenPos = UDim2.new(1, -15, bg.Position.Y.Scale, bg.Position.Y.Offset)
	const slOpenPos = UDim2.new(1, -15, sl.Position.Y.Scale, sl.Position.Y.Offset)
	const rgbOpenPos = rgb.Position
	const hexOpenPos = hex.Position
	const mainOpenTr = main.ImageTransparency
	const pointOpenTr = main.MainPoint.ImageTransparency
	const sliderPointOpenTr = sl.SliderPoint.ImageTransparency

	const pickerClosedSize = UDim2.new(pickerOpenSize.X.Scale, pickerOpenSize.X.Offset, pickerOpenSize.Y.Scale, 45)
	const bgClosedSize = UDim2.new(0, 39, 0, 22)
	const bgClosedTr = 1
	const dispClosedTr = disp.BackgroundTransparency
	const interactClosedSize = UDim2.new(1, 0, 1, 0)
	const interactClosedPos = UDim2.new(0.5, 0, 0.5, 0)
	const rgbClosedPos = UDim2.new(rgbOpenPos.X.Scale, rgbOpenPos.X.Offset, rgbOpenPos.Y.Scale, rgbOpenPos.Y.Offset + 30)
	const hexClosedPos = UDim2.new(hexOpenPos.X.Scale, hexOpenPos.X.Offset, hexOpenPos.Y.Scale, hexOpenPos.Y.Offset + 17)
	const mainClosedTr = 1
	const pointClosedTr = 1
	const sliderPointClosedTr = 1

	bg.Position = bgOpenPos
	sl.Position = slOpenPos

	const function animateRowHover(show)
		tw(picker, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = show and hoverRowColor or baseRowColor
		})
	end

	const function setPickerOpen(state, animate)
		opened = state == true
		const fast = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		const mid = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		const bgInfo = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
		const useAnim = animate ~= false

		const pickerSize = opened and pickerOpenSize or pickerClosedSize
		const bgSize = opened and bgOpenSize or bgClosedSize
		const displayTr = opened and dispOpenTr or dispClosedTr
		const interactSize = opened and interactOpenSize or interactClosedSize
		const interactPos = opened and interactOpenPos or interactClosedPos
		const rgbPos = opened and rgbOpenPos or rgbClosedPos
		const hexPos = opened and hexOpenPos or hexClosedPos
		const mainTr = opened and mainOpenTr or mainClosedTr
		const pointTr = opened and pointOpenTr or pointClosedTr
		const sliderPointTr = opened and sliderPointOpenTr or sliderPointClosedTr
		const bgTr = opened and bgOpenTr or bgClosedTr

		pcall(function() sl.Visible = opened end)
		pcall(function() main.MainPoint.Visible = opened end)
		pcall(function() sl.SliderPoint.Visible = opened end)

		if useAnim then
			tw(picker, mid, { Size = pickerSize })
			tw(bg, bgInfo, { Size = bgSize, BackgroundTransparency = bgTr, Position = bgOpenPos })
			tw(disp, mid, { BackgroundTransparency = displayTr })
			tw(interact, mid, { Size = interactSize, Position = interactPos })
			tw(rgb, mid, { Position = rgbPos })
			tw(hex, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = hexPos })
			pcall(function()
				tw(main.MainPoint, fast, { ImageTransparency = pointTr })
			end)
			pcall(function()
				tw(sl.SliderPoint, fast, { ImageTransparency = sliderPointTr })
			end)
			pcall(function()
				tw(main, fast, { ImageTransparency = mainTr })
			end)
		else
			picker.Size = pickerSize
			bg.Size = bgSize
			bg.BackgroundTransparency = bgTr
			bg.Position = bgOpenPos
			disp.BackgroundTransparency = displayTr
			interact.Size = interactSize
			interact.Position = interactPos
			sl.Position = slOpenPos
			rgb.Position = rgbPos
			hex.Position = hexPos
			pcall(function() main.MainPoint.ImageTransparency = pointTr end)
			pcall(function() sl.SliderPoint.ImageTransparency = sliderPointTr end)
			pcall(function() main.ImageTransparency = mainTr end)
		end
	end

	picker.ClipsDescendants = true
	if rowStroke then
		rowStroke.Transparency = 1
		tw(rowStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Transparency = 0 })
	end
	if title then
		title.TextTransparency = 1
		tw(title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { TextTransparency = 0 })
	end
	picker.BackgroundTransparency = 1
	tw(picker, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })

	trackPickerConn(picker.MouseEnter:Connect(function()
		animateRowHover(true)
	end))
	trackPickerConn(picker.MouseLeave:Connect(function()
		animateRowHover(false)
	end))
	trackPickerConn(interact.MouseButton1Click:Connect(function()
		animateRowHover(true)
		if rowStroke then
			tw(rowStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Transparency = 1 })
		end
		Delay(0.2, function()
			if picker.Parent then
				animateRowHover(false)
				if rowStroke then
					tw(rowStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Transparency = 0 })
				end
			end
		end)
		setPickerOpen(not opened, true)
	end))

	setPickerOpen(false, false)

	local rgbOn = false
	const rgbSpd = 0.1

	const function updTog()
		if rgbSw then
			rgbSw.BackgroundColor3 = rgbOn and Color3.fromRGB(70, 49, 104) or Color3.fromRGB(49, 49, 54)
		end
		if rgbDot then
			local w = rgbDot.Size.X.Offset
			if w == 0 then w = math.max(rgbDot.AbsoluteSize.X, 18) end
			const pad = 2
			rgbDot.Position = rgbOn and UDim2.new(1, -w - pad, 0.5, 0) or UDim2.new(0, pad, 0.5, 0)
			rgbDot.BackgroundColor3 = rgbOn and Color3.fromRGB(154, 99, 255) or Color3.fromRGB(114, 114, 124)
		end
		if rgbTit and rgbTit:IsA("TextLabel") then
			rgbTit.Text = rgbOn and "RGB Cycle (ON)" or "RGB Cycle"
			rgbTit.TextColor3 = rgbOn and Color3.fromRGB(194, 194, 255) or Color3.fromRGB(244, 244, 249)
		end
	end

	const function setRGB(sta, opt)
		opt = opt or {}
		const ns = sta and true or false
		if rgbOn == ns then
			if not opt.skipVis then updTog() end
			return
		end
		rgbOn = ns
		if not opt.skipSave then
			saveState(rgbOn)
		end
		updTog()
		if rgbOn then
			if startRgbLoop then
				startRgbLoop()
			end
		else
			stopRgbLoop()
		end
	end

	const sv = getSaved()
	if type(sv) == "boolean" then
		setRGB(sv, { skipVis = true, skipSave = true })
	end
	updTog()

	if rgbBtn then
		MouseButtonFix(rgbBtn, function()
			setRGB(not rgbOn)
		end)
	end

	if typeof(defaultColor) ~= "Color3" then
		defaultColor = Color3.fromRGB(255, 255, 255)
	end

	local h, s, v = defaultColor:ToHSV()

	const function updUI(push, opt)
		opt = opt or {}
		const col = Color3.fromHSV(h, s, v)
		disp.BackgroundColor3 = col
		bg.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		main.MainPoint.Position = UDim2.new(s, 0, 1 - v, 0)
		sl.SliderPoint.Position = UDim2.new(h, 0, 0.5, 0)

		const r = math.floor(col.R * 255 + 0.5)
		const g = math.floor(col.G * 255 + 0.5)
		const b = math.floor(col.B * 255 + 0.5)

		if push then
			rgb.RInput.InputBox.Text = tostring(r)
			rgb.GInput.InputBox.Text = tostring(g)
			rgb.BInput.InputBox.Text = tostring(b)
			hex.InputBox.Text = Format("#%02X%02X%02X", r, g, b)
		end

		if opt.fire ~= false then
			runColorCallback(col, opt)
		end
	end

	const function parseRGB()
		setRGB(false)
		local r = tonumber(rgb.RInput.InputBox.Text) or 0
		local g = tonumber(rgb.GInput.InputBox.Text) or 0
		local b = tonumber(rgb.BInput.InputBox.Text) or 0
		r = math.clamp(r, 0, 255)
		g = math.clamp(g, 0, 255)
		b = math.clamp(b, 0, 255)
		h, s, v = Color3.fromRGB(r, g, b):ToHSV()
		updUI(false)
	end

	trackPickerConn(rgb.RInput.InputBox.FocusLost:Connect(parseRGB))
	trackPickerConn(rgb.GInput.InputBox.FocusLost:Connect(parseRGB))
	trackPickerConn(rgb.BInput.InputBox.FocusLost:Connect(parseRGB))

	trackPickerConn(hex.InputBox.FocusLost:Connect(function()
		setRGB(false)
		const txt = (hex.InputBox.Text or ""):gsub("#", ""):upper()
		if txt:match("^[0-9A-F]+$") and #txt == 6 then
			const r = tonumber(txt:sub(1, 2), 16)
			const g = tonumber(txt:sub(3, 4), 16)
			const b = tonumber(txt:sub(5, 6), 16)
			if r and g and b then
				h, s, v = Color3.fromRGB(r, g, b):ToHSV()
				updUI(true)
				return
			end
		end
		const col = Color3.fromHSV(h, s, v)
		hex.InputBox.Text = Format("#%02X%02X%02X",
			math.floor(col.R * 255 + 0.5),
			math.floor(col.G * 255 + 0.5),
			math.floor(col.B * 255 + 0.5)
		)
	end))

	pcall(function() main.MainPoint.AnchorPoint = Vector2.new(0.5, 0.5) end)
	pcall(function() sl.SliderPoint.AnchorPoint = Vector2.new(0.5, 0.5) end)

	const UIS = SafeGetService("UserInputService")
	const RS = SafeGetService("RunService")

	startRgbLoop = function()
		if pickerDestroyed or rgbLoopConn or not RS then
			return
		end
		rgbLoopConn = trackPickerConn(RS.RenderStepped:Connect(function(dt)
			if pickerDestroyed then
				return
			end
			local visible = opened
			if visible and NAmanage and NAmanage.IsUIWindowVisible then visible = NAmanage.IsUIWindowVisible("SettingsFrame") end
			if visible and picker and NAmanage and NAmanage.IsGuiActuallyVisible then visible = NAmanage.IsGuiActuallyVisible(picker) end
			if rgbOn and visible and not dM and not dS then
				const step = math.clamp(dt or 0.016, 0.001, 0.1)
				h = (h + step * rgbSpd) % 1
				updUI(true)
			end
		end))
	end
	if rgbOn then
		startRgbLoop()
	end

	const function v2(p)
		if typeof(p) == "Vector2" then return p end
		if typeof(p) == "Vector3" then return Vector2.new(p.X, p.Y) end
		return UIS and __lt.cm("UserInputService", "GetMouseLocation") or Vector2.new(0, 0)
	end

	const function updMain(pos)
		const sz = main.AbsoluteSize
		if sz.X <= 0 or sz.Y <= 0 then return end
		const ap = main.AbsolutePosition
		const rx = math.clamp(pos.X - ap.X, 0, sz.X)
		const ry = math.clamp(pos.Y - ap.Y, 0, sz.Y)
		s = rx / sz.X
		v = 1 - (ry / sz.Y)
		updUI(true)
	end

	const function updSl(pos)
		const sz = sl.AbsoluteSize
		if sz.X <= 0 then return end
		const ap = sl.AbsolutePosition
		const rx = math.clamp(pos.X - ap.X, 0, sz.X)
		h = rx / sz.X
		updUI(true)
	end

	const function startDragListeners()
		if not UIS or pickerDestroyed then
			return
		end
		if dragChangedConn or dragEndedConn then
			return
		end

		dragChangedConn = UIS.InputChanged:Connect(function(input)
			if not dM and not dS then
				return
			end
			if dM then
				if inM and inM.UserInputType == Enum.UserInputType.Touch then
					if input == inM then
						updMain(v2(input.Position))
					end
				elseif input.UserInputType == Enum.UserInputType.MouseMovement then
					updMain(v2(input.Position))
				end
			end
			if dS then
				if inS and inS.UserInputType == Enum.UserInputType.Touch then
					if input == inS then
						updSl(v2(input.Position))
					end
				elseif input.UserInputType == Enum.UserInputType.MouseMovement then
					updSl(v2(input.Position))
				end
			end
		end)

		dragEndedConn = UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dM, dS = false, false
				inM, inS = nil, nil
				stopDragListeners()
				return
			end
			if input.UserInputType == Enum.UserInputType.Touch then
				if inM == input then dM, inM = false, nil end
				if inS == input then dS, inS = false, nil end
				if not dM and not dS then
					stopDragListeners()
				end
			end
		end)
	end

	const function hit(obj)
		if obj:IsA("GuiButton") then
			pcall(function() obj.Active = true end)
			return obj
		end
		pcall(function() obj.Active = true end)
		local b = obj:FindFirstChild("__Hit")
		if not (b and b:IsA("TextButton")) then
			b = InstanceNew("TextButton")
			b.Name = "__Hit"
			b.BackgroundTransparency = 1
			b.AutoButtonColor = false
			b.BorderSizePixel = 0
			b.Text = ""
			b.Size = UDim2.new(1, 0, 1, 0)
			b.ZIndex = (obj.ZIndex or 1) + 20
			b.Parent = obj
		end
		return b
	end

	const mHit = hit(main)
	const sHit = hit(sl)
	pcall(function() main.MainPoint.Interactable = false end)
	pcall(function() sl.SliderPoint.Interactable = false end)
	pcall(function() interact.Interactable = true end)

	const function beg(t, input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if not opened then
			return
		end
		setRGB(false)
		if t == "m" then
			dM = true
			inM = input
			updMain(v2(input.Position))
		else
			dS = true
			inS = input
			updSl(v2(input.Position))
		end
		startDragListeners()
	end

	trackPickerConn(mHit.InputBegan:Connect(function(i) beg("m", i) end))
	trackPickerConn(sHit.InputBegan:Connect(function(i) beg("s", i) end))

	const entry = {
		get = function()
			return Color3.fromHSV(h, s, v)
		end,
		set = function(col, opt)
			if typeof(col) ~= "Color3" then return end
			h, s, v = col:ToHSV()
			updUI(true, opt or {})
		end,
		getAutoRGB = function()
			return rgbOn
		end,
		setAutoRGB = function(sta)
			setRGB(sta)
		end,
	}

	NAgui._colorPickerRegistry[label] = entry

	trackPickerConn(picker:GetPropertyChangedSignal("Parent"):Connect(function()
		if not picker.Parent then
			if NAgui._colorPickerRegistry[label] == entry then
				NAgui._colorPickerRegistry[label] = nil
			end
			cleanupPickerConnections()
		end
	end))

	const initOpts = {
		fire = cfg.fireOnInit ~= false;
		context = "init";
	}
	updUI(true, initOpts)

	return picker
end

NAgui.setColorPickerValue = function(label, color, opts)
	const entry = NAgui._colorPickerRegistry and NAgui._colorPickerRegistry[label]
	if not entry then return end
	entry.set(color, opts or { fire = false })
end

NAgui.setColorPickerAutoRGB = function(label, enabled)
	const entry = NAgui._colorPickerRegistry and NAgui._colorPickerRegistry[label]
	if not entry or not entry.setAutoRGB then return end
	entry.setAutoRGB(enabled)
end

NAgui.getColorPickerAutoRGB = function(label)
	const entry = NAgui._colorPickerRegistry and NAgui._colorPickerRegistry[label]
	if not entry or not entry.getAutoRGB then return nil end
	return entry.getAutoRGB()
end

NAgui.addInput = function(label, placeholder, defaultText, callback, opts)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("input") end
	opts = opts or {}

	const input = templates.Input:Clone()
	const frame = input.InputFrame
	const box = frame.InputBox
	local chipRow
	if opts.sideChip then
		const tgl = templates.Toggle:Clone()
		const sw = tgl:FindFirstChild("Switch")
		if sw then
			const chip = sw:Clone()
			chip.Name = "SideSwitch"
			chip.Parent = input
			tgl:Destroy()

			local swW = chip.Size.X.Offset
			if swW <= 0 then
				swW = 45
			end

			chip.AnchorPoint = Vector2.new(1, 0.5)
			chip.Position = UDim2.new(1, -15, 0.5, 0)
			chip.Size = UDim2.new(0, swW, 0, chip.Size.Y.Offset)

			chipRow = chip

			frame.AnchorPoint = Vector2.new(1, 0.5)
			frame.Position = UDim2.new(1, -15, 0.5, 0)

			const chipInd = chip:FindFirstChild("Indicator")
			const chipStroke = chip:FindFirstChildWhichIsA("UIStroke", true)
			local chipOn = false

			const function updChip2()
				if chipInd then
					const onX = chip.AbsoluteSize.X - chipInd.AbsoluteSize.X - 4
					const offX = 2
					chipInd.Position = UDim2.new(0, chipOn and onX or offX, 0.5, 0)
					chipInd.Visible = false
				end
				if chipStroke then
					chipStroke.Color = chipOn and Color3.fromRGB(155, 100, 255) or Color3.fromRGB(72, 72, 72)
				end
			end

			if type(opts.sideGet) == "function" then
				local ok, v = pcall(opts.sideGet)
				if ok then
					chipOn = v and true or false
				end
			end

			updChip2()

			const btn = InstanceNew("TextButton")
			btn.Name = "ChipInteract"
			btn.BackgroundTransparency = 1
			btn.Text = tostring(opts.sideText or "Use")
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Size = UDim2.new(1, 0, 1, 0)
			btn.ZIndex = (chip.ZIndex or 1) + 1
			btn.Parent = chip

			MouseButtonFix(btn, function()
				if type(opts.sideSet) == "function" or type(opts.sideGet) == "function" then
					const nextState = not chipOn
					local ok, result = true, nil
					if type(opts.sideSet) == "function" then
						ok, result = pcall(opts.sideSet, nextState)
					end
					if not ok or result == false then
						return
					end

					chipOn = nextState
					if type(opts.sideGet) == "function" then
						local getOk, currentState = pcall(opts.sideGet)
						if getOk then
							chipOn = currentState and true or false
						end
					end
					updChip2()
				else
					box:CaptureFocus()
				end
			end)
		else
			tgl:Destroy()
		end
	end

	input.Title.Text = label
	NAmanage.SetSearch.tag(input, label)
	box.Text = defaultText or ""
	box.PlaceholderText = placeholder or ""
	box.TextXAlignment = Enum.TextXAlignment.Center
	box.TextTruncate = Enum.TextTruncate.None

	input.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	input.Parent = settingsList
	NAmanage.registerElementForCurrentTab(input, settingsTabName)
	NAgui.atchSettings(input, "input:"..tostring(label)..":"..tostring(input.LayoutOrder), 0.08)

	local lastW
	local mobileInputPollConn
	local resizeBusy = false
	local resizeQueued = false
	local resizePending = false
	local resize
	local requestResize

	requestResize = function()
		if resizeBusy then
			resizePending = true
			return
		end
		if resizeQueued then
			return
		end
		resizeQueued = true
		Delay(0.03, function()
			resizeQueued = false
			if resize and input and input.Parent then
				resize()
			end
		end)
	end

	const function finishResize()
		resizeBusy = false
		if resizePending then
			resizePending = false
			requestResize()
		end
	end

	const function stopMobileInputPoll()
		NAlib.disconnect("NAgui_input_mobile_poll:"..tostring(label)..":"..tostring(input.LayoutOrder))
		if mobileInputPollConn then
			mobileInputPollConn:Disconnect()
			mobileInputPollConn = nil
		end
	end

	const function startMobileInputPoll()
		stopMobileInputPoll()
		if not (Services.RunService and Services.UserInputService and Services.UserInputService.TouchEnabled) then
			return
		end

		local accum = 0
		mobileInputPollConn = NAlib.reconnect("NAgui_input_mobile_poll:"..tostring(label)..":"..tostring(input.LayoutOrder), Services.RunService.Heartbeat:Connect(function(dt)
			if not (input and input.Parent and box and box.Parent) then
				stopMobileInputPoll()
				return
			end
			local okFocused, isFocused = pcall(function()
				return box:IsFocused()
			end)
			if not (okFocused and isFocused == true) then
				stopMobileInputPoll()
				return
			end
			accum += tonumber(dt) or 0
			if accum < 0.05 then
				return
			end
			accum = 0
			resize()
		end))
	end

	resize = function()
		if resizeBusy then
			resizePending = true
			return
		end
		if NAgui.isSettingsLayoutSuspended and NAgui.isSettingsLayoutSuspended() then
			return
		end
		if not (input and input.Parent and frame and frame.Parent and box and box.Parent) then
			return
		end

		resizeBusy = true

		const textW = NAgui.getInputTextWidth(box)
		const minW = NAgui.getInputMinWidth(frame)
		local maxW

		local cw = input.AbsoluteSize.X
		if (not cw or cw <= 0) and input.Parent then
			cw = input.Parent.AbsoluteSize.X
		end
		if (not cw or cw <= 0) and settingsList then
			cw = settingsList.AbsoluteSize.X
		end

		if cw and cw > 0 then
			const tw = (input.Title and input.Title.TextBounds.X or 0)
			local gap = 32
			if chipRow then
				local extra = chipRow.Size.X.Offset
				if extra <= 0 then
					extra = 45
				end
				gap = gap + extra
			end
			maxW = cw - tw - gap
		end

		local w = math.max(textW, minW)
		local hit = false
		if maxW then
			const clamped = math.max(minW, math.min(w, maxW))
			hit = clamped >= (maxW - 0.5)
			w = clamped
		end

		const targetAlignment = hit and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center
		if box.TextXAlignment ~= targetAlignment then
			box.TextXAlignment = targetAlignment
		end

		if type(w) ~= "number" then
			finishResize()
			return
		end

		if not lastW or math.abs(lastW - w) > 0.5 then
			lastW = w
			const targetSize = UDim2.new(0, w, 0, 30)
			if frame.Size ~= targetSize then
				frame.Size = targetSize
			end
			if chipRow then
				local fw = frame.Size.X.Offset
				if fw <= 0 then fw = w end
				const targetChipPosition = UDim2.new(1, -15 - fw - 6, 0.5, 0)
				const targetFramePosition = UDim2.new(1, -15, 0.5, 0)
				if chipRow.Position ~= targetChipPosition then
					chipRow.Position = targetChipPosition
				end
				if frame.Position ~= targetFramePosition then
					frame.Position = targetFramePosition
				end
			end
		end

		finishResize()
	end

	box.Focused:Connect(function()
		startMobileInputPoll()
		resize()
	end)

	box.FocusLost:Connect(function()
		stopMobileInputPoll()
		local commitText = tostring(box.Text or "")
		const measureText = NAgui.getInputMeasureText(box)
		if commitText == "" and measureText ~= "" then
			commitText = measureText
			box.Text = commitText
		end
		resize()
		pcall(callback, commitText)
	end)

	box:GetPropertyChangedSignal("TextBounds"):Connect(requestResize)
	box:GetPropertyChangedSignal("Text"):Connect(requestResize)
	pcall(function()
		box:GetPropertyChangedSignal("ContentText"):Connect(requestResize)
	end)
	input:GetPropertyChangedSignal("AbsoluteSize"):Connect(requestResize)
	input:GetPropertyChangedSignal("Parent"):Connect(function()
		if not input.Parent then
			stopMobileInputPoll()
		end
	end)
	const function setText(newValue, opts)
		opts = opts or {}
		const text = tostring(newValue or "")
		if not opts.force and box.Text == text then
			if opts.fire then
				pcall(callback, text)
			end
			return
		end
		box.Text = text
		resize()
		if opts.fire then
			pcall(callback, text)
		end
	end

	const entry = {
		input = input;
		get = function()
			return box.Text
		end;
		set = function(v, opts)
			setText(v, opts)
		end;
	}

	NAgui._inputRegistry[label] = entry

	input:GetPropertyChangedSignal("Parent"):Connect(function()
		if not input.Parent and NAgui._inputRegistry[label] == entry then
			NAgui._inputRegistry[label] = nil
		end
	end)

	resize()

	return input
end

NAgui.setInputValue = function(label, value, opts)
	const entry = NAgui._inputRegistry and NAgui._inputRegistry[label]
	if not entry then return end
	entry.set(value, opts or { fire = false })
end

NAmanage.SyncPrefixUI = function(opts)
	if not NAgui then return end
	local prefixValue = opt and tostring(opt.prefix or "") or ""
	if prefixValue == "" then
		prefixValue = ";"
	end
	opts = opts or {}
	const setterOpts = {
		force = opts.force == true,
		fire = opts.fire == true,
	}
	if NAgui.setKeybindValue then
		NAgui.setKeybindValue("Prefix", prefixValue, setterOpts)
		return
	end
	if NAgui.setInputValue then
		NAgui.setInputValue("Prefix", prefixValue, setterOpts)
	end
end

NAmanage.SyncUIScaleUI = function(opts)
	if not (NAgui and NAgui.setInputValue) then return end
	opts = opts or {}
	local value = opts.value
	if value == nil then
		value = NAUIScale
	end
	const clamped = NAmanage.ClampUIScale(value, 1)
	const setterOpts = {
		force = opts.force ~= false,
		fire = opts.fire == true,
	}
	NAgui.setInputValue("UI Scale", Format("%.2f", clamped), setterOpts)
end

NAmanage._uiAutoSync = NAmanage._uiAutoSync or { toggles = {} }

NAmanage.RegisterToggleAutoSync = function(label, getter, opts)
	if type(label) ~= "string" or type(getter) ~= "function" then return end
	const store = NAmanage._uiAutoSync
	local entry = store.toggles[label]
	if not entry then
		entry = { getter = getter, last = nil, opts = opts }
		store.toggles[label] = entry
	else
		entry.getter = getter
		entry.opts = opts or entry.opts
	end
end

NAmanage.RunUIAutoSync = function()
	const store = NAmanage._uiAutoSync
	if not store then return end
	const buildState = NAgui and NAgui.SettingsBuildState
	if type(buildState) == "table" and (buildState.background == true or buildState.building == true) then
		return
	end
	const settingsFrame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
	if typeof(settingsFrame) == "Instance" and settingsFrame.Visible ~= true then return end
	const toggleStore = store.toggles
	if toggleStore and NAgui and NAgui.setToggleState then
		const mobile = IsOnMobile == true
		const lowEnd = NAmanage.IsLowEndUI and NAmanage.IsLowEndUI() or false
		local processed = 0
		for label, watcher in toggleStore do
			processed += 1
			local success, rawValue = pcall(watcher.getter)
			if success then
				local normalized = nil
				if watcher.opts and type(watcher.opts.normalize) == "function" then
					local ok, result = pcall(watcher.opts.normalize, rawValue)
					if ok then
						normalized = result
					end
				end
				if normalized == nil then
					normalized = rawValue and true or false
				end
				const registry = NAgui._toggleRegistry
				if registry and registry[label] then
					if watcher.last == nil or watcher.last ~= normalized then
						watcher.last = normalized
						const fireCallback = watcher.opts and watcher.opts.fire == true
						NAgui.setToggleState(label, normalized, {
							force = true,
							fire = fireCallback and true or false,
						})
					end
				else
					watcher.last = nil
				end
			end
			if (mobile or lowEnd) and processed % (mobile and 6 or 12) == 0 then
				Wait(mobile and 0.02 or nil)
			end
		end
	end
end

NAmanage.StartUIAutoSyncLoop = function()
	if NAmanage._uiAutoSyncLoopStarted then return end
	NAmanage._uiAutoSyncLoopStarted = true
	NAmanage._uiAutoSyncLoopAlive = true
	Spawn(function()
		local idleStreak = 0
		while NAmanage._uiAutoSyncLoopAlive do
			const store = NAmanage._uiAutoSync
			const hasToggles = store and store.toggles and next(store.toggles) ~= nil
			if hasToggles then
				local ok, err = pcall(NAmanage.RunUIAutoSync)
				if ok then
					idleStreak = 0
				else
					idleStreak = math.min(idleStreak + 1, 10)
					warn("[NA] UI auto-sync failed:", err)
				end
			else
				idleStreak = math.min(idleStreak + 1, 12)
			end

			const settingsFrame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
			const settingsVisible = not (typeof(settingsFrame) == "Instance") or settingsFrame.Visible == true
			const buildState = NAgui and NAgui.SettingsBuildState
			const settingsBuilding = type(buildState) == "table" and (buildState.background == true or buildState.building == true)
			const lowEnd = NAmanage.IsLowEndUI and NAmanage.IsLowEndUI() or false
			local sleepTime = hasToggles and 1.25 or math.min(8, 2.5 + idleStreak * 0.5)
			if hasToggles then
				if settingsBuilding then sleepTime = lowEnd and 6 or 4
				elseif not settingsVisible then sleepTime = lowEnd and 10 or 6
				elseif NAmanage.isLoad and NAmanage.isLoad() then sleepTime = lowEnd and 2.75 or 1.75
				elseif idleStreak > 0 then sleepTime = math.min(lowEnd and 8 or 5, 1.25 + idleStreak * 0.35)
				elseif lowEnd then sleepTime = 2.5 end
			end
			Wait(sleepTime)
		end
	end)
end

NAmanage.StartUIAutoSyncLoop()
if NAmanage.InstallUIVisibilityOptimizer then pcall(NAmanage.InstallUIVisibilityOptimizer) end

NAgui.addKeybind = function(label, defaultKey, callback)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("keybind") end
	callback = type(callback) == "function" and callback or function() end
	const connKey = "NAgui_keybind:"..tostring(label)
	NAlib.disconnect(connKey)
	const keybind = templates.Keybind:Clone()
	keybind.Title.Text = label
	NAmanage.SetSearch.tag(keybind, label)
	const frame = keybind.KeybindFrame
	const box = frame and frame.KeybindBox
	const rowStroke = keybind:FindFirstChild("UIStroke")
	const frameStroke = frame and frame:FindFirstChildWhichIsA("UIStroke")
	const title = keybind:FindFirstChild("Title")
	local defaultKeyText = tostring(defaultKey or "Unknown")
	if defaultKeyText == "" then
		defaultKeyText = "Unknown"
	end

	const keybindSymbolAliases = {
		["!"] = "One",
		["\""] = "Quote",
		["#"] = "Three",
		["$"] = "Four",
		["%"] = "Five",
		["&"] = "Seven",
		["'"] = "Quote",
		["("] = "Nine",
		[")"] = "Zero",
		["*"] = "Eight",
		["+"] = "Equals",
		[";"] = "Semicolon",
		[":"] = "Semicolon",
		[","] = "Comma",
		["<"] = "Comma",
		["."] = "Period",
		[">"] = "Period",
		["/"] = "Slash",
		["?"] = "Slash",
		["\\"] = "BackSlash",
		["|"] = "BackSlash",
		["`"] = "Backquote",
		["~"] = "Backquote",
		["-"] = "Minus",
		["_"] = "Minus",
		["="] = "Equals",
		["["] = "LeftBracket",
		["{"] = "LeftBracket",
		["]"] = "RightBracket",
		["}"] = "RightBracket",
		["@"] = "Two",
		["^"] = "Six",
	}
	const keybindDigitAliases = {
		["0"] = "Zero",
		["1"] = "One",
		["2"] = "Two",
		["3"] = "Three",
		["4"] = "Four",
		["5"] = "Five",
		["6"] = "Six",
		["7"] = "Seven",
		["8"] = "Eight",
		["9"] = "Nine",
	}

	const function safeKeyCodeLookup(name)
		if type(name) ~= "string" or name == "" then
			return nil
		end
		local ok, code = pcall(function()
			return Enum.KeyCode[name]
		end)
		if ok and code and code ~= Enum.KeyCode.Unknown then
			return code
		end
		return nil
	end

	const function resolveKeyCode(text)
		if type(text) ~= "string" then
			return Enum.KeyCode.Unknown, nil
		end
		local clean = text:match("^%s*(.-)%s*$")
		if not clean or clean == "" then
			return Enum.KeyCode.Unknown, nil
		end
		if #clean == 1 then
			const alias = keybindSymbolAliases[clean] or keybindDigitAliases[clean]
			if alias then
				const aliasCode = safeKeyCodeLookup(alias)
				if aliasCode then
					return aliasCode, aliasCode.Name
				end
			end
		end
		clean = clean:gsub("^Enum%.KeyCode%.", "")
		const direct = safeKeyCodeLookup(clean)
		if direct then
			return direct, direct.Name
		end
		const lower = Lower(clean)
		for _, enumKey in Enum.KeyCode:GetEnumItems() do
			if Lower(enumKey.Name) == lower then
				return enumKey, enumKey.Name
			end
		end
		return Enum.KeyCode.Unknown, clean
	end

	local defaultKeyCode, defaultDisplay = resolveKeyCode(defaultKeyText)
	if defaultDisplay and defaultDisplay ~= "" then
		defaultKeyText = defaultDisplay
	end
	local boundKeyCode = defaultKeyCode
	box.Text = defaultKeyText
	local runCallback
	local tweenFrameWidth

	const function setKeyText(newValue, opts)
		opts = opts or {}
		local text = tostring(newValue or "")
		if text == "" then
			text = defaultKeyText
		end
		local code, normalized = resolveKeyCode(text)
		if normalized and normalized ~= "" then
			text = normalized
		end
		if not opts.force and box.Text == text then
			if opts.fire then
				runCallback(text)
			end
			return
		end
		box.Text = text
		boundKeyCode = code
		tweenFrameWidth()
		if opts.fire then
			runCallback(text)
		end
	end

	keybind.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	keybind.Parent = settingsList
	NAmanage.registerElementForCurrentTab(keybind, settingsTabName)

	local capturing = false
	const baseRowColor = keybind.BackgroundColor3
	const hoverRowColor = baseRowColor:Lerp(Color3.new(1, 1, 1), 0.08)
	const baseFrameColor = frame and frame.BackgroundColor3 or Color3.fromRGB(45, 45, 50)
	const focusFrameColor = baseFrameColor:Lerp(Color3.new(1, 1, 1), 0.1)
	const baseFrameStrokeColor = frameStroke and frameStroke.Color or Color3.fromRGB(72, 72, 72)
	const focusFrameStrokeColor = Color3.fromRGB(155, 100, 255)
	local frameFocused = false
	local lastPulseAt = 0
	const pulseCooldown = 0.09
	const pulseHold = 0.08
	local pulseResetAt = 0
	local pulseResetRunning = false

	const function tw(obj, info, goal)
		if not obj then return nil end
		local same = true
		for prop, target in goal do
			local ok, current = pcall(function()
				return obj[prop]
			end)
			if not ok or current ~= target then
				same = false
				break
			end
		end
		if same then
			return nil
		end
		local ok, tween = pcall(function()
			return __lt.cm("TweenService", "Create", obj, info, goal)
		end)
		if ok and tween then
			tween:Play()
			return tween
		end
		return nil
	end

	const function flashKeybindError(message)
		tw(keybind, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(85, 0, 0)
		})
		if rowStroke then
			tw(rowStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			})
		end
		const prevTitle = title and title.Text or nil
		if title then
			title.Text = "Callback Error"
		end
		warn("[NA] Keybind callback error ("..tostring(label).."): "..tostring(message))
		Delay(0.5, function()
			if not keybind.Parent then
				return
			end
			if title and prevTitle ~= nil then
				title.Text = prevTitle
			end
			tw(keybind, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = baseRowColor
			})
			if rowStroke then
				tw(rowStroke, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 0
				})
			end
		end)
	end

	runCallback = function(...)
		local ok, err = pcall(callback, ...)
		if not ok then
			flashKeybindError(err)
		end
	end

	const function setFrameFocused(focused, force)
		focused = focused == true
		if not force and frameFocused == focused then
			return
		end
		frameFocused = focused
		if frame then
			tw(frame, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = frameFocused and focusFrameColor or baseFrameColor
			})
		end
		if frameStroke then
			tw(frameStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Color = frameFocused and focusFrameStrokeColor or baseFrameStrokeColor
			})
		end
	end

	const function schedulePulseReset()
		pulseResetAt = os.clock() + pulseHold
		if pulseResetRunning then
			return
		end
		pulseResetRunning = true
		Spawn(function()
			while keybind and keybind.Parent do
				const remaining = pulseResetAt - os.clock()
				if remaining > 0 then
					Wait(math.min(remaining, 0.05))
				else
					if not capturing then
						setFrameFocused(false, false)
					end
					break
				end
			end
			pulseResetRunning = false
			pulseResetAt = 0
		end)
	end

	tweenFrameWidth = function()
		if not (frame and box) then
			return
		end
		local width = box.TextBounds.X + 24
		if width < 24 then
			width = 24
		end
		tw(frame, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, width, 0, 30)
		})
	end

	if rowStroke then
		rowStroke.Transparency = 1
		tw(rowStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Transparency = 0 })
	end
	if title then
		title.TextTransparency = 1
		tw(title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { TextTransparency = 0 })
	end
	keybind.BackgroundTransparency = 1
	tw(keybind, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
	tweenFrameWidth()

	NAlib.connect(connKey, keybind.MouseEnter:Connect(function()
		tw(keybind, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverRowColor
		})
	end))
	NAlib.connect(connKey, keybind.MouseLeave:Connect(function()
		tw(keybind, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = baseRowColor
		})
	end))

	NAlib.connect(connKey, box.Focused:Connect(function()
		capturing = true
		pulseResetAt = 0
		box.Text = ""
		setFrameFocused(true, true)
	end))

	NAlib.connect(connKey, box.FocusLost:Connect(function()
		capturing = false
		pulseResetAt = 0
		const typed = box.Text
		if typed == nil or typed == "" then
			box.Text = defaultKeyText
		end
		local code, normalized = resolveKeyCode(box.Text)
		if normalized and normalized ~= "" then
			box.Text = normalized
		end
		boundKeyCode = code
		setFrameFocused(false, true)
		tweenFrameWidth()
	end))

	NAlib.connect(connKey, Services.UserInputService.InputBegan:Connect(function(input, processed)
		if not input or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		const keyCode = input.KeyCode
		if keyCode == Enum.KeyCode.Unknown then
			return
		end
		if capturing and input.KeyCode ~= Enum.KeyCode.Unknown then
			const keyName = keyCode.Name
			box:ReleaseFocus()
			box.Text = keyName
			boundKeyCode = keyCode
			capturing = false
			pulseResetAt = 0
			setFrameFocused(false, true)
			runCallback(keyName)
		elseif not capturing and boundKeyCode ~= Enum.KeyCode.Unknown and not processed and keyCode == boundKeyCode then
			const now = os.clock()
			if now - lastPulseAt >= pulseCooldown then
				lastPulseAt = now
				setFrameFocused(true, false)
				schedulePulseReset()
			end
			runCallback()
		end
	end))

	NAlib.connect(connKey, box:GetPropertyChangedSignal("Text"):Connect(function()
		const code = resolveKeyCode(box.Text)
		boundKeyCode = code
		tweenFrameWidth()
	end))

	const entry = {
		keybind = keybind;
		get = function()
			return box.Text
		end;
		set = function(v, opts)
			setKeyText(v, opts)
		end;
		getKeyCode = function()
			return boundKeyCode
		end;
	}

	NAgui._keybindRegistry[label] = entry
	NAlib.connect(connKey, keybind:GetPropertyChangedSignal("Parent"):Connect(function()
		if keybind.Parent then
			return
		end
		if NAgui._keybindRegistry[label] == entry then
			NAgui._keybindRegistry[label] = nil
		end
		NAlib.disconnect(connKey)
	end))

	return keybind
end

NAgui.setKeybindValue = function(label, value, opts)
	const entry = NAgui._keybindRegistry and NAgui._keybindRegistry[label]
	if not entry then return end
	if not (entry.keybind and entry.keybind.Parent) then
		NAgui._keybindRegistry[label] = nil
		return
	end
	entry.set(value, opts or { fire = false })
end

NAgui.addSlider = function(label, min, max, defaultValue, increment, suffix, callback, opts)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("slider") end
	if type(callback) == "table" and opts == nil then
		opts = callback
		callback = nil
	end
	opts = type(opts) == "table" and opts or {}
	callback = type(callback) == "function" and callback or function() end
	NAgui._sliderConnCounter = (NAgui._sliderConnCounter or 0) + 1
	const connKey = "NAgui_slider:"..tostring(label)..":"..tostring(NAgui._sliderConnCounter)
	const slider = templates.Slider:Clone()
	slider.Title.Text = label
	NAmanage.SetSearch.tag(slider, label)

	slider.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	slider.Parent = settingsList
	NAmanage.registerElementForCurrentTab(slider, settingsTabName)

	const function toCg(o)
		if not o or o:IsA("CanvasGroup") or not o:IsA("GuiObject") then
			if o then pcall(function() o.ClipsDescendants = true end) end
			return o
		end
		const p = o.Parent
		const n = InstanceNew("CanvasGroup")
		n.Name = o.Name
		n.Active = o.Active
		n.AnchorPoint = o.AnchorPoint
		n.AutomaticSize = o.AutomaticSize
		n.BackgroundColor3 = o.BackgroundColor3
		n.BackgroundTransparency = o.BackgroundTransparency
		n.BorderColor3 = o.BorderColor3
		n.BorderSizePixel = o.BorderSizePixel
		n.LayoutOrder = o.LayoutOrder
		n.Position = o.Position
		n.Rotation = o.Rotation
		n.Size = o.Size
		n.Visible = o.Visible
		n.ZIndex = o.ZIndex
		n.ClipsDescendants = true
		for _, v in o:GetChildren() do
			v.Parent = n
		end
		n.Parent = p
		o:Destroy()
		return n
	end

	const main = toCg(slider:FindFirstChild("Main"))
	const interact = main.Interact
	const progress = toCg(main.Progress)
	const infoText = main.Information
	const rowStroke = slider:FindFirstChild("UIStroke")
	const title = slider:FindFirstChild("Title")
	const mainStroke = main and main:FindFirstChildWhichIsA("UIStroke")
	const progressStroke = progress and progress:FindFirstChildWhichIsA("UIStroke")

	local dragging = false
	local dragDirty = false
	local currentValue = defaultValue
	const step = tonumber(increment) or 0
	const range = max - min
	local dragInputChangedConn
	local dragInputEndedConn
	local dragInputStateConn
	local dragStepConn
	local activeDragInput
	local activeDragType
	local pendingPointerX
	const baseRowColor = slider.BackgroundColor3
	const hoverRowColor = baseRowColor:Lerp(Color3.new(1, 1, 1), 0.08)
	const mainStrokeIdleTransparency = (mainStroke and typeof(mainStroke.Transparency) == "number") and mainStroke.Transparency or 0.4
	const progressStrokeIdleTransparency = (progressStroke and typeof(progressStroke.Transparency) == "number") and progressStroke.Transparency or 0.3
	const fireOnRelease = opts.fireOnRelease == true or opts.live == false

	const function tw(obj, info, goal)
		if not obj then return nil end
		local ok, tween = pcall(function()
			return __lt.cm("TweenService", "Create", obj, info, goal)
		end)
		if ok and tween then
			tween:Play()
			return tween
		end
		return nil
	end

	const function flashSliderError(message)
		tw(slider, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(85, 0, 0)
		})
		if rowStroke then
			tw(rowStroke, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			})
		end
		const prevTitle = title and title.Text or nil
		if title then
			title.Text = "Callback Error"
		end
		warn("[NA] Slider callback error ("..tostring(label).."): "..tostring(message))
		Delay(0.5, function()
			if not slider.Parent then
				return
			end
			if title and prevTitle ~= nil then
				title.Text = prevTitle
			end
			tw(slider, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = baseRowColor
			})
			if rowStroke then
				tw(rowStroke, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Transparency = 0
				})
			end
		end)
	end

	const function runCallback(value)
		local ok, err = pcall(callback, value)
		if not ok then
			flashSliderError(err)
		end
	end

	const function quantize(value)
		if step == 0 then
			return math.clamp(value, min, max)
		end
		const scaled = (value - min) / step
		const rounded = math.floor(scaled + 0.5)
		local quantized = min + rounded * step
		if quantized < min then quantized = min end
		if quantized > max then quantized = max end
		return quantized
	end

	const function progressGoalForPercent(percent)
		percent = math.clamp(percent or 0, 0, 1)
		const width = interact and interact.AbsoluteSize.X or 0
		if width > 0 then
			const pixel = math.clamp(width * percent, 0, width)
			return UDim2.new(0, pixel, 1, 0)
		end
		return UDim2.new(percent, 0, 1, 0)
	end

	const function applyValue(value, opts)
		opts = opts or {}
		const quantized = quantize(value)
		const changed = currentValue ~= quantized
		currentValue = quantized
		const percent = (range ~= 0) and ((quantized - min) / range) or 0
		const goalSize = progressGoalForPercent(percent)
		if opts.animate == false then
			progress.Size = goalSize
		else
			tw(progress, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = goalSize
			})
		end
		infoText.Text = Format("%.14g", quantized)..(suffix or "")
		if opts.fire ~= false and (changed or opts.forceFire == true) then
			runCallback(quantized)
		end
		return quantized, changed
	end

	const function updateSliderValueFromPos(x)
		const relX = math.clamp(x - interact.AbsolutePosition.X, 0, interact.AbsoluteSize.X)
		const width = math.max(interact.AbsoluteSize.X, 1)
		const percent = relX / width
		const value = min + range * percent
		local _, changed = applyValue(value, { fire = not (fireOnRelease and dragging) })
		if fireOnRelease and dragging and changed then
			dragDirty = true
		end
	end

	const function disconnectDragListeners()
		if dragInputChangedConn then
			dragInputChangedConn:Disconnect()
			dragInputChangedConn = nil
		end
		if dragInputEndedConn then
			dragInputEndedConn:Disconnect()
			dragInputEndedConn = nil
		end
		if dragInputStateConn then
			dragInputStateConn:Disconnect()
			dragInputStateConn = nil
		end
		if dragStepConn then
			NAlib.disconnect(connKey..":drag_step")
			dragStepConn = nil
		end
		pendingPointerX = nil
	end

	const function stopDrag()
		const shouldFire = dragging and fireOnRelease and dragDirty
		const commitValue = currentValue
		dragging = false
		dragDirty = false
		disconnectDragListeners()
		activeDragInput = nil
		activeDragType = nil
		if mainStroke then
			tw(mainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = mainStrokeIdleTransparency
			})
		end
		if progressStroke then
			tw(progressStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = progressStrokeIdleTransparency
			})
		end
		if shouldFire then
			runCallback(commitValue)
		end
	end

	const function queuePointerX(input)
		if not dragging or not input then
			return
		end
		local ok, position = pcall(function()
			return input.Position
		end)
		if ok and typeof(position) == "Vector3" then
			pendingPointerX = position.X
		end
	end

	const function isActiveDragInput(input)
		if not dragging or not input then
			return false
		end
		if activeDragType == Enum.UserInputType.Touch then
			return input == activeDragInput
		end
		return activeDragType == Enum.UserInputType.MouseButton1
			and input.UserInputType == Enum.UserInputType.MouseButton1
	end

	const function ensureDragListeners()
		disconnectDragListeners()
		dragInputChangedConn = Services.UserInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end
			if activeDragType == Enum.UserInputType.Touch then
				if input == activeDragInput then
					queuePointerX(input)
				end
			elseif activeDragType == Enum.UserInputType.MouseButton1
				and input.UserInputType == Enum.UserInputType.MouseMovement then
				queuePointerX(input)
			end
		end)
		dragInputEndedConn = Services.UserInputService.InputEnded:Connect(function(input)
			if isActiveDragInput(input) then
				stopDrag()
			end
		end)
		if activeDragInput then
			dragInputStateConn = activeDragInput.Changed:Connect(function()
				if not dragging or activeDragInput == nil then
					return
				end
				if activeDragType == Enum.UserInputType.Touch then
					queuePointerX(activeDragInput)
				end
				const state = activeDragInput.UserInputState
				if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
					stopDrag()
				end
			end)
		end
		dragStepConn = NAlib.reconnect(connKey..":drag_step", Services.RunService.RenderStepped:Connect(function()
			const pointerX = pendingPointerX
			if not dragging or pointerX == nil then
				return
			end
			pendingPointerX = nil
			pcall(function()
				updateSliderValueFromPos(pointerX)
			end)
		end))
	end

	NAlib.connect(connKey, interact.InputBegan:Connect(function(input)
		const inputType = input.UserInputType
		if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then
			return
		end
		if dragging then
			return
		end

		dragging = true
		activeDragInput = input
		activeDragType = inputType
		if mainStroke then
			tw(mainStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			})
		end
		if progressStroke then
			tw(progressStroke, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			})
		end
		ensureDragListeners()
		queuePointerX(input)
		pcall(function()
			updateSliderValueFromPos(input.Position.X)
		end)
	end))

	NAlib.connect(connKey, slider.MouseEnter:Connect(function()
		tw(slider, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverRowColor
		})
	end))
	NAlib.connect(connKey, slider.MouseLeave:Connect(function()
		tw(slider, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			BackgroundColor3 = baseRowColor
		})
	end))

	if rowStroke then
		rowStroke.Transparency = 1
		tw(rowStroke, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Transparency = 0 })
	end
	if title then
		title.TextTransparency = 1
		tw(title, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { TextTransparency = 0 })
	end
	slider.BackgroundTransparency = 1
	tw(slider, TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })

	applyValue(defaultValue, { fire = false, animate = false })

	const entry = {
		get = function()
			return currentValue
		end;
		set = function(value, opts)
			opts = opts or {}
			if opts.animate == nil then
				opts.animate = true
			end
			applyValue(value, opts)
		end;
	}
	NAgui._sliderRegistry[label] = entry

	NAlib.connect(connKey, slider:GetPropertyChangedSignal("Parent"):Connect(function()
		if not slider.Parent and NAgui._sliderRegistry[label] == entry then
			stopDrag()
			NAgui._sliderRegistry[label] = nil
			Defer(function()
				NAlib.disconnect(connKey)
			end)
		end
	end))

	return slider
end

NAgui.setSliderValue = function(label, value, opts)
	const entry = NAgui._sliderRegistry and NAgui._sliderRegistry[label]
	if not entry then return end
	entry.set(value, opts or { fire = false })
end
