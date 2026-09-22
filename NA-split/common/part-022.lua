NAgui.addDropdown = function(label, values, defaultValue, callback, opts)
	local settingsList, settingsTabName = NAgui.getSettingsTarget()
	if not settingsList then return end
	if NAgui.SettingsBuildStep then NAgui.SettingsBuildStep("dropdown") end
	if not (templates and templates.Dropdown) then return end

	local DropdownSettings
	if type(label) == "table" and values == nil then
		DropdownSettings = label
	else
		opts = opts or {}
		if type(defaultValue) == "function" and callback == nil then
			callback = defaultValue
			defaultValue = nil
		end
		DropdownSettings = {
			Name = tostring(label or "Dropdown"),
			Options = values,
			CurrentOption = defaultValue,
			MultipleOptions = opts.MultipleOptions == true or opts.multipleOptions == true,
			Callback = callback,
			Ext = opts.Ext,
			Flag = opts.Flag,
		}
	end

	DropdownSettings = DropdownSettings or {}
	DropdownSettings.Name = tostring(DropdownSettings.Name or label or "Dropdown")
	DropdownSettings.Options = DropdownSettings.Options or {}
	DropdownSettings.Callback = type(DropdownSettings.Callback) == "function" and DropdownSettings.Callback or function() end
	DropdownSettings.MultipleOptions = DropdownSettings.MultipleOptions == true
	NAgui._dropdownConnCounter = (NAgui._dropdownConnCounter or 0) + 1
	const connKey = "NAgui_dropdown:"..DropdownSettings.Name..":"..tostring(NAgui._dropdownConnCounter)

	const function normalizeOption(option)
		if type(option) == "table" then
			local rawValue = option.value
			if rawValue == nil then
				rawValue = option.id or option.key or option.name or option[1]
			end
			const value = tostring(rawValue or "")
			local rawDisplay = option.display
			if rawDisplay == nil then
				rawDisplay = option.text or option.label or rawValue or value
			end
			return {
				value = value,
				display = tostring(rawDisplay or value),
				selectedDisplay = tostring(option.selectedDisplay or option.SelectedDisplay or rawDisplay or value),
				richText = option.richText == true or option.RichText == true,
			}
		end
		const text = tostring(option)
		return {
			value = text,
			display = text,
			selectedDisplay = text,
			richText = false,
		}
	end

	const function normalizeOptions(raw)
		const out = {}
		if type(raw) ~= "table" then
			return out
		end
		const n = #raw
		if n > 0 then
			for i = 1, n do
				out[#out + 1] = normalizeOption(raw[i])
			end
		else
			for _, v in raw do
				out[#out + 1] = normalizeOption(v)
			end
		end
		return out
	end

	DropdownSettings.Options = normalizeOptions(DropdownSettings.Options)

	const function getOptionRecordByValue(value)
		const wanted = tostring(value or "")
		for _, option in DropdownSettings.Options do
			if option.value == wanted then
				return option
			end
		end
		return nil
	end

	const function getOptionDisplay(value)
		const option = getOptionRecordByValue(value)
		if option then
			return option.display
		end
		return tostring(value or "")
	end

	const function getOptionSelectedDisplay(value)
		const option = getOptionRecordByValue(value)
		if option then
			return option.selectedDisplay or option.display
		end
		return tostring(value or "")
	end

	const function hasOptionValue(value)
		return getOptionRecordByValue(value) ~= nil
	end

	const function dropdownUsesRichText()
		if opts and (opts.RichText == true or opts.richText == true) then
			return true
		end
		for _, option in DropdownSettings.Options do
			if option.richText == true then
				return true
			end
		end
		return false
	end

	local dropdown, title, selected, toggle
	local collapsedHeight, openHeight

	const function resizeSelectedLabel()
		if NAgui.isSettingsLayoutSuspended and NAgui.isSettingsLayoutSuspended() then
			return
		end
		if not (dropdown and selected and selected:IsA("TextLabel")) then
			return
		end
		const rowWidth = dropdown.AbsoluteSize.X
		if not rowWidth or rowWidth <= 0 then
			return
		end

		local titleWidth = 0
		if title and title:IsA("TextLabel") then
			titleWidth = title.TextBounds.X
		end

		local toggleWidth = 26
		if toggle and toggle:IsA("GuiObject") then
			const abs = toggle.AbsoluteSize.X
			if abs and abs > 0 then
				toggleWidth = abs
			end
		end

		const leftInset = 12
		const gap = 10
		const rightInset = 10
		local selectedLeft = leftInset
		if title and title:IsA("TextLabel") then
			local titleStart = title.AbsolutePosition.X - dropdown.AbsolutePosition.X
			if not titleStart or titleStart < 0 then
				titleStart = leftInset
			end
			selectedLeft = math.max(selectedLeft, math.floor(titleStart + titleWidth + gap + 0.5))
		end
		const rightLimit = rowWidth - toggleWidth - rightInset
		const available = math.max(72, rightLimit - selectedLeft)
		const selectedHeight = math.max(16, selected.TextBounds.Y > 0 and selected.TextBounds.Y or selected.AbsoluteSize.Y > 0 and selected.AbsoluteSize.Y or 18)
		const headerYOffset = math.max(0, math.floor((collapsedHeight - selectedHeight) * 0.5))

		selected.AnchorPoint = Vector2.new(1, 0)
		selected.Position = UDim2.new(0, rightLimit, 0, headerYOffset)
		selected.Size = UDim2.new(0, available, 0, selectedHeight)
		selected.TextScaled = false
		selected.TextWrapped = false
		selected.TextTruncate = Enum.TextTruncate.AtEnd
		selected.TextXAlignment = Enum.TextXAlignment.Right
	end

	dropdown = templates.Dropdown:Clone()
	if Find(DropdownSettings.Name, "closed") then
		dropdown.Name = "Dropdown"
	else
		dropdown.Name = DropdownSettings.Name
	end
	dropdown.Visible = true
	dropdown.ClipsDescendants = true
	dropdown.Parent = settingsList
	dropdown.LayoutOrder = NAgui._nextLayoutOrder(settingsTabName)
	NAmanage.registerElementForCurrentTab(dropdown, settingsTabName)
	NAmanage.SetSearch.tag(dropdown, DropdownSettings.Name)
	if NAgui.RegisterStrokesFrom then
		NAgui.RegisterStrokesFromAsync(dropdown)
	end

	title = dropdown:FindFirstChild("Title")
	selected = dropdown:FindFirstChild("Selected")
	toggle = dropdown:FindFirstChild("Toggle")
	local interact = dropdown:FindFirstChild("Interact")
	local list = dropdown:FindFirstChild("List")
	local listLayout = list and list:FindFirstChildWhichIsA("UIListLayout")
	const optionTemplate = list and list:FindFirstChild("Template")
	const uiStroke = dropdown:FindFirstChild("UIStroke")

	if title and title:IsA("TextLabel") then
		title.Text = DropdownSettings.Name
	end

	if not (interact and interact:IsA("GuiButton")) then
		interact = InstanceNew("TextButton")
		interact.Name = "Interact"
		interact.BackgroundTransparency = 1
		interact.Text = ""
		interact.AutoButtonColor = false
		interact.Parent = dropdown
	end

	if not (list and list:IsA("ScrollingFrame")) then
		list = InstanceNew("ScrollingFrame")
		list.Name = "List"
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.ScrollBarThickness = 3
		list.Parent = dropdown
	end

	if not listLayout then
		listLayout = InstanceNew("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		listLayout.Padding = UDim.new(0, 5)
		listLayout.Parent = list
	end

	collapsedHeight = tonumber((opts and opts.CollapsedHeight) or (opts and opts.collapsedHeight)) or 45
	openHeight = tonumber((opts and opts.OpenHeight) or (opts and opts.openHeight)) or 180
	collapsedHeight = math.max(36, math.floor(collapsedHeight + 0.5))
	openHeight = math.max(collapsedHeight + 20, math.floor(openHeight + 0.5))

	list.Visible = false
	list.Position = UDim2.new(0, 5, 0, 38)
	list.Size = UDim2.new(1, -10, 1, -42)
	list.ScrollBarImageTransparency = 1
	dropdown.Size = UDim2.new(1, -10, 0, collapsedHeight)
	interact.AnchorPoint = Vector2.new(0, 0)
	interact.Position = UDim2.new(0, 0, 0, 0)
	interact.Size = UDim2.new(1, 0, 0, collapsedHeight)

	const selectedColor = (opts and (opts.DropdownSelected or opts.selectedColor)) or Color3.fromRGB(40, 40, 40)
	const unselectedColor = (opts and (opts.DropdownUnselected or opts.unselectedColor)) or Color3.fromRGB(30, 30, 30)
	const hoverColor = (opts and (opts.HoverColor or opts.hoverColor)) or Color3.fromRGB(55, 55, 60)
	const baseColor = dropdown.BackgroundColor3
	local busy = false

	if DropdownSettings.CurrentOption then
		if type(DropdownSettings.CurrentOption) == "string" then
			DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
		end
		if not DropdownSettings.MultipleOptions and type(DropdownSettings.CurrentOption) == "table" then
			DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
		end
	else
		DropdownSettings.CurrentOption = {}
	end

	const function updateSelectedText()
		if not (selected and selected:IsA("TextLabel")) then
			return
		end
		selected.RichText = dropdownUsesRichText()
		if DropdownSettings.MultipleOptions then
			if #DropdownSettings.CurrentOption == 1 then
				selected.Text = getOptionSelectedDisplay(DropdownSettings.CurrentOption[1])
			elseif #DropdownSettings.CurrentOption == 0 then
				selected.Text = "None"
			else
				selected.Text = "Various"
			end
		else
			selected.Text = getOptionSelectedDisplay(DropdownSettings.CurrentOption[1] or "None")
		end
		resizeSelectedLabel()
	end

	const function eachOptionRow(fn)
		for _, child in list:GetChildren() do
			if child:IsA("Frame") and child.Name ~= "Placeholder" and child.Name ~= "Template" then
				fn(child)
			end
		end
	end

	const function applySelectionColors()
		eachOptionRow(function(row)
			const optionValue = row:GetAttribute("DropdownValue") or row.Name
			const on = Discover(DropdownSettings.CurrentOption, optionValue) ~= nil
			row.BackgroundColor3 = on and selectedColor or unselectedColor
			const rowStroke = row:FindFirstChild("UIStroke")
			if rowStroke and rowStroke:IsA("UIStroke") then
				rowStroke.Transparency = on and 1 or 0
			end
		end)
	end

	const function syncOptionRowVisualState(isOpen)
		eachOptionRow(function(row)
			const rowStroke = row:FindFirstChild("UIStroke")
			const rowTitle = row:FindFirstChild("Title")
			const optionValue = row:GetAttribute("DropdownValue") or row.Name
			const isSelected = Discover(DropdownSettings.CurrentOption, optionValue) ~= nil
			row.BackgroundTransparency = isOpen and 0 or 1
			if rowTitle and rowTitle:IsA("TextLabel") then
				rowTitle.TextTransparency = isOpen and 0 or 1
			end
			if rowStroke and rowStroke:IsA("UIStroke") then
				if isOpen then
					rowStroke.Transparency = isSelected and 1 or 0
				else
					rowStroke.Transparency = 1
				end
			end
		end)
	end

	const function openDropdown()
		if busy then return end
		busy = true
		list.Visible = true
		__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, openHeight)}):Play()
		__lt.cm("TweenService", "Create", list, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 0.7}):Play()
		if toggle then
			__lt.cm("TweenService", "Create", toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 0}):Play()
		end
		eachOptionRow(function(row)
			const rowStroke = row:FindFirstChild("UIStroke")
			const rowTitle = row:FindFirstChild("Title")
			const optionValue = row:GetAttribute("DropdownValue") or row.Name
			if rowStroke and rowStroke:IsA("UIStroke") then
				if not Discover(DropdownSettings.CurrentOption, optionValue) then
					__lt.cm("TweenService", "Create", rowStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
				end
			end
			__lt.cm("TweenService", "Create", row, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 0}):Play()
			if rowTitle and rowTitle:IsA("TextLabel") then
				__lt.cm("TweenService", "Create", rowTitle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 0}):Play()
			end
		end)
		Wait(0.05)
		busy = false
	end

	const function closeDropdown()
		if busy then return end
		busy = true
		__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, -10, 0, collapsedHeight)}):Play()
		eachOptionRow(function(row)
			const rowStroke = row:FindFirstChild("UIStroke")
			const rowTitle = row:FindFirstChild("Title")
			__lt.cm("TweenService", "Create", row, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundTransparency = 1}):Play()
			if rowStroke and rowStroke:IsA("UIStroke") then
				__lt.cm("TweenService", "Create", rowStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			end
			if rowTitle and rowTitle:IsA("TextLabel") then
				__lt.cm("TweenService", "Create", rowTitle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {TextTransparency = 1}):Play()
			end
		end)
		__lt.cm("TweenService", "Create", list, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {ScrollBarImageTransparency = 1}):Play()
		if toggle then
			__lt.cm("TweenService", "Create", toggle, TweenInfo.new(0.7, Enum.EasingStyle.Exponential), {Rotation = 180}):Play()
		end
		Wait(0.35)
		list.Visible = false
		busy = false
	end

	const function toggleDropdown()
		__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {BackgroundColor3 = hoverColor}):Play()
		if uiStroke and uiStroke:IsA("UIStroke") then
			__lt.cm("TweenService", "Create", uiStroke, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
		end
		Wait(0.08)
		__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {BackgroundColor3 = baseColor}):Play()
		if uiStroke and uiStroke:IsA("UIStroke") then
			__lt.cm("TweenService", "Create", uiStroke, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
		end
		if list.Visible then
			closeDropdown()
		else
			openDropdown()
		end
	end

	const function clearOptionRows()
		eachOptionRow(function(row)
			row:Destroy()
		end)
	end

	const function makeFallbackTemplate()
		const row = InstanceNew("Frame")
		row.Size = UDim2.new(1, -8, 0, 32)
		row.BackgroundColor3 = unselectedColor
		row.BorderSizePixel = 0
		const c = InstanceNew("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = row
		const st = InstanceNew("UIStroke")
		st.Color = Color3.fromRGB(70, 70, 70)
		st.Parent = row
		const txt = InstanceNew("TextLabel")
		txt.Name = "Title"
		txt.AnchorPoint = Vector2.new(0, 0.5)
		txt.Position = UDim2.new(0, 10, 0.5, 0)
		txt.Size = UDim2.new(1, -20, 0, 14)
		txt.BackgroundTransparency = 1
		txt.TextXAlignment = Enum.TextXAlignment.Left
		txt.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		txt.TextColor3 = Color3.fromRGB(245, 245, 250)
		txt.Parent = row
		const btn = InstanceNew("TextButton")
		btn.Name = "Interact"
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.ZIndex = 50
		btn.Parent = row
		return row
	end

	const function fireCallback(payload)
		local ok, err = pcall(function()
			DropdownSettings.Callback(payload)
		end)
		if not ok then
			__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = Color3.fromRGB(85, 0, 0)}):Play()
			if uiStroke and uiStroke:IsA("UIStroke") then
				__lt.cm("TweenService", "Create", uiStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 1}):Play()
			end
			if title and title:IsA("TextLabel") then
				title.Text = "Callback Error"
			end
			warn("[NA] Dropdown callback error:", err)
			Wait(0.4)
			if title and title:IsA("TextLabel") then
				title.Text = DropdownSettings.Name
			end
			__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = baseColor}):Play()
			if uiStroke and uiStroke:IsA("UIStroke") then
				__lt.cm("TweenService", "Create", uiStroke, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Transparency = 0}):Play()
			end
		end
	end

	const function setDropdownOptions()
		clearOptionRows()
		const templateRow = optionTemplate
		if templateRow and templateRow:IsA("GuiObject") then
			templateRow.Visible = false
		end
		for index, option in DropdownSettings.Options do
			if NAgui.SettingsBuildStep and index % 16 == 0 then NAgui.SettingsBuildStep("dropdownOption") end
			const optionValue = tostring(option.value or "")
			const optionDisplay = tostring(option.display or optionValue)
			const optionRichText = option.richText == true or (opts and (opts.RichText == true or opts.richText == true))
			const row = (templateRow and templateRow:Clone()) or makeFallbackTemplate()
			row.Name = "Option_"..tostring(index)
			row:SetAttribute("DropdownValue", optionValue)
			row.Visible = true
			row.Parent = list
			const rowTitle = row:FindFirstChild("Title")
			local rowInteract = row:FindFirstChild("Interact")
			const rowStroke = row:FindFirstChild("UIStroke")
			if rowTitle and rowTitle:IsA("TextLabel") then
				rowTitle.Text = optionDisplay
				rowTitle.RichText = optionRichText
				rowTitle.TextTransparency = 1
			end
			if rowStroke and rowStroke:IsA("UIStroke") then
				rowStroke.Transparency = 1
			end
			row.BackgroundTransparency = 1

			if not (rowInteract and rowInteract:IsA("GuiButton")) then
				rowInteract = InstanceNew("TextButton")
				rowInteract.Name = "Interact"
				rowInteract.BackgroundTransparency = 1
				rowInteract.Text = ""
				rowInteract.Size = UDim2.new(1, 0, 1, 0)
				rowInteract.Parent = row
			end
			rowInteract.ZIndex = 50

			MouseButtonFix(rowInteract, function()
				const idx = Discover(DropdownSettings.CurrentOption, optionValue)
				if not DropdownSettings.MultipleOptions and idx then
					updateSelectedText()
					applySelectionColors()
					fireCallback(DropdownSettings.CurrentOption)
					if list.Visible then
						Wait(0.1)
						closeDropdown()
					end
					return
				end

				if idx then
					table.remove(DropdownSettings.CurrentOption, idx)
				else
					if not DropdownSettings.MultipleOptions then
						table.clear(DropdownSettings.CurrentOption)
					end
					Insert(DropdownSettings.CurrentOption, optionValue)
				end

				updateSelectedText()
				applySelectionColors()
				fireCallback(DropdownSettings.CurrentOption)

				if not DropdownSettings.MultipleOptions and list.Visible then
					Wait(0.1)
					closeDropdown()
				end
			end)
		end
		applySelectionColors()
		syncOptionRowVisualState(list.Visible == true)
	end

	updateSelectedText()
	setDropdownOptions()
	if toggle and toggle:IsA("GuiObject") then
		toggle.Rotation = 180
	end

	pcall(function()
		NAlib.connect(connKey, dropdown:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeSelectedLabel))
	end)
	if title and title:IsA("TextLabel") then
		pcall(function()
			NAlib.connect(connKey, title:GetPropertyChangedSignal("TextBounds"):Connect(resizeSelectedLabel))
		end)
	end
	if selected and selected:IsA("TextLabel") then
		pcall(function()
			NAlib.connect(connKey, selected:GetPropertyChangedSignal("TextBounds"):Connect(resizeSelectedLabel))
		end)
	end
	resizeSelectedLabel()

	MouseButtonFix(interact, toggleDropdown)
	if toggle and toggle:IsA("GuiButton") then
		MouseButtonFix(toggle, toggleDropdown)
	end

	NAlib.connect(connKey, dropdown.MouseEnter:Connect(function()
		if not list.Visible then
			__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = hoverColor}):Play()
		end
	end))
	NAlib.connect(connKey, dropdown.MouseLeave:Connect(function()
		__lt.cm("TweenService", "Create", dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {BackgroundColor3 = baseColor}):Play()
	end))

	function DropdownSettings:Set(NewOption)
		DropdownSettings.CurrentOption = NewOption
		if typeof(DropdownSettings.CurrentOption) == "string" then
			DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption}
		end
		if type(DropdownSettings.CurrentOption) ~= "table" then
			DropdownSettings.CurrentOption = {}
		end
		if not DropdownSettings.MultipleOptions then
			DropdownSettings.CurrentOption = {DropdownSettings.CurrentOption[1]}
		end
		updateSelectedText()
		applySelectionColors()
		fireCallback(NewOption)
	end

	function DropdownSettings:Refresh(optionsTable)
		DropdownSettings.Options = normalizeOptions(optionsTable)
		for i = #DropdownSettings.CurrentOption, 1, -1 do
			const val = DropdownSettings.CurrentOption[i]
			if not hasOptionValue(val) then
				table.remove(DropdownSettings.CurrentOption, i)
			end
		end
		updateSelectedText()
		setDropdownOptions()
	end

	DropdownSettings.Instance = dropdown

	const regKey = DropdownSettings.Name
	const entry = {
		get = function()
			return DropdownSettings.CurrentOption
		end;
		set = function(value, setOpts)
			setOpts = setOpts or {}
			if setOpts.fire == false then
				const prev = DropdownSettings.Callback
				DropdownSettings.Callback = function() end
				DropdownSettings:Set(value)
				DropdownSettings.Callback = prev
				return
			end
			DropdownSettings:Set(value)
		end;
		setOptions = function(newOptions)
			DropdownSettings:Refresh(newOptions)
		end;
		api = DropdownSettings;
	}
	NAgui._dropdownRegistry[regKey] = entry

	NAlib.connect(connKey, dropdown:GetPropertyChangedSignal("Parent"):Connect(function()
		if not dropdown.Parent and NAgui._dropdownRegistry[regKey] == entry then
			NAgui._dropdownRegistry[regKey] = nil
			Defer(function()
				NAlib.disconnect(connKey)
			end)
		end
	end))

	return DropdownSettings
end

NAgui.setDropdownValue = function(label, value, opts)
	const entry = NAgui._dropdownRegistry and NAgui._dropdownRegistry[label]
	if not entry then return end
	entry.set(value, opts or { fire = false, context = "set" })
end

NAgui.setDropdownOptions = function(label, options, opts)
	const entry = NAgui._dropdownRegistry and NAgui._dropdownRegistry[label]
	if not entry then return end
	entry.setOptions(options, opts or {})
end

NAmanage.Topbar_SanitizeButtonShape=function(shape)
	const raw = Lower(tostring(shape or ""))
	if raw == "square" then
		return "Square"
	elseif raw == "rounded" or raw == "round" then
		return "Rounded"
	elseif raw == "squircle" then
		return "Squircle"
	elseif raw == "circle" then
		return "Circle"
	end
	return "Circle"
end

NAmanage.Topbar_GetButtonShapeOptions=function()
	return { "Square", "Rounded", "Squircle", "Circle" }
end

NAmanage.Topbar_GetButtonCornerRadius=function(shape)
	const normalized = NAmanage.Topbar_SanitizeButtonShape(shape)
	if normalized == "Square" then
		return UDim.new(0, 0)
	elseif normalized == "Rounded" then
		return UDim.new(0.18, 0)
	elseif normalized == "Squircle" then
		return UDim.new(0.3, 0)
	end
	return UDim.new(1, 0)
end

NAmanage.Topbar_ApplyButtonShape=function(shape, opts)
	opts = opts or {}
	const normalized = NAmanage.Topbar_SanitizeButtonShape(shape)
	NAStuff.TopbarButtonShape = normalized
	const glass = TopBarApp and TopBarApp.tGlass
	if glass then
		local corner = glass:FindFirstChildOfClass("UICorner")
		if not corner then
			corner = InstanceNew("UICorner", glass)
		end
		corner.CornerRadius = NAmanage.Topbar_GetButtonCornerRadius(normalized)
	end
	if opts.save ~= false and NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("topbarButtonShape", normalized)
	end
	return normalized
end

NAStuff.TopbarButtonShape = NAmanage.Topbar_SanitizeButtonShape(NAStuff.TopbarButtonShape)

NAmanage.Topbar_PlayTween=function(key,instance,info,props)
	NAmanage._tweens=NAmanage._tweens or {}
	if NAmanage._tweens[key] then NAmanage._tweens[key]:Cancel() end
	const t=__lt.cm("TweenService", "Create", instance,info,props)
	NAmanage._tweens[key]=t
	t:Play()
	return t
end

NAmanage.Topbar_ButtonCount=function()
	local n=0
	for _ in TopBarApp.buttonDefs do n+=1 end
	return n
end

NAmanage.Topbar_ComputedSize=function()
	const pad=8
	const count=NAmanage.Topbar_ButtonCount()
	const cam=Services.Workspace.CurrentCamera
	const vpX=cam and cam.ViewportSize.X or 1280
	const margin=8
	if TopBarApp.mode=="bottom" then
		const tile=44
		const cols=math.max(1, math.min(5, count))
		const rows=math.max(1, math.min(5, math.ceil(count/5)))
		local w=cols*tile+(cols-1)*pad+12
		const h=rows*tile+(rows-1)*pad+12
		w=math.min(w, vpX - margin*2)
		return w,h
	else
		const tile = 48
		const visible = math.max(1, math.min(4, count))
		local w = visible*tile + (visible-1)*pad + 12
		const h = tile + 12
		const maxW = vpX - margin*2
		if w > maxW then
			w = maxW
		end
		return w,h
	end
end

function Topbar_GetMaxOffset()
	if not (TopBarApp and TopBarApp.frame and TopBarApp.toggle) then
		return nil
	end
	const fw = TopBarApp.frame.AbsoluteSize.X
	const bw = TopBarApp.toggle.AbsoluteSize.X
	if fw <= 0 then
		return nil
	end
	local maxOffset = (fw - bw) * 0.5
	if maxOffset < 0 then
		maxOffset = 0
	end
	return maxOffset
end

NAmanage.Topbar_SavePositionPreference=function(opts)
	opts = opts or {}
	if not NATopbarKeepPosition and not opts.force then
		return
	end
	const maxOffset = Topbar_GetMaxOffset()
	if not maxOffset then
		return
	end
	local offset = opts.offset
	if type(offset) ~= "number" then
		if not (TopBarApp and TopBarApp.toggle) then
			return
		end
		offset = TopBarApp.toggle.Position.X.Offset
	end
	local ratio = 0
	if maxOffset > 0 then
		ratio = math.clamp(offset / maxOffset, -1, 1)
	end
	NATopbarPositionRatio = ratio
	NAmanage.NASettingsSet("topbarPositionRatio", ratio)
end

NAmanage.Topbar_ResetPositionPreference=function()
	NATopbarPositionRatio = 0
	NAmanage.NASettingsSet("topbarPositionRatio", 0)
	if TopBarApp and TopBarApp.toggle then
		const pos = TopBarApp.toggle.Position
		TopBarApp.toggle.Position = UDim2.new(0.5, 0, pos.Y.Scale, pos.Y.Offset)
		if TopBarApp.isOpen then
			NAmanage.Topbar_PositionPanel()
		end
	end
end

NAmanage.Topbar_ApplySavedPosition=function()
	if not NATopbarKeepPosition then
		return
	end
	const maxOffset = Topbar_GetMaxOffset()
	if not maxOffset then
		return
	end
	const ratio = math.clamp(NATopbarPositionRatio or 0, -1, 1)
	const offset = ratio * maxOffset
	if TopBarApp and TopBarApp.toggle then
		const pos = TopBarApp.toggle.Position
		TopBarApp.toggle.Position = UDim2.new(0.5, offset, pos.Y.Scale, pos.Y.Offset)
		if TopBarApp.isOpen then
			NAmanage.Topbar_PositionPanel()
		end
	end
end

NAmanage.Topbar_ApplyDock=function(dock, opts)
	opts = opts or {}
	dock = dock == "bottom" and "bottom" or "top"
	NATopbarDock = dock
	TopBarApp.dock = dock
	if opts.save ~= false then
		NAmanage.topbar_writeDock(dock)
	end
	if TopBarApp.frame then
		TopBarApp.frame.AnchorPoint = Vector2.new(0, dock == "bottom" and 1 or 0)
		TopBarApp.frame.Position = dock == "bottom" and UDim2.new(0,0,1,0) or UDim2.new(0,0,0,0)
	end
	if TopBarApp.toggle then
		const currentX = TopBarApp.toggle.Position.X.Offset
		const anchor = dock == "bottom" and Vector2.new(0.5,1) or Vector2.new(0.5,0)
		const yScale = dock == "bottom" and 1 or 0
		const yOffset = dock == "bottom" and -10 or 10
		TopBarApp.toggle.AnchorPoint = anchor
		TopBarApp.toggle.Position = UDim2.new(0.5, currentX, yScale, yOffset)
	end
	if NATopbarKeepPosition then
		NAmanage.Topbar_ApplySavedPosition()
	else
		NAmanage.Topbar_ClampToggle()
	end
	if TopBarApp.isOpen then
		NAmanage.Topbar_PositionPanel()
	end
end

NAmanage.Topbar_ChooseSide=function()
	const cam=Services.Workspace.CurrentCamera
	if not cam then return end
	const vp=cam.ViewportSize
	const ap,sz=TopBarApp.toggle.AbsolutePosition,TopBarApp.toggle.AbsoluteSize
	const w=NAmanage.Topbar_ComputedSize()
	const canRight=(ap.X+sz.X+8+w)<= (vp.X-8)
	const canLeft=(ap.X-8-w)>=8
	if TopBarApp.sidePref=="right" and not canRight and canLeft then
		TopBarApp.sidePref="left"
	elseif TopBarApp.sidePref=="left" and not canLeft and canRight then
		TopBarApp.sidePref="right"
	elseif not canRight and canLeft then
		TopBarApp.sidePref="left"
	elseif canRight and not canLeft then
		TopBarApp.sidePref="right"
	end
end

NAmanage.Topbar_PositionPanel=function()
	if not (TopBarApp.panel and TopBarApp.toggle) then return end

	const cam = Services.Workspace.CurrentCamera
	if not cam then return end

	const vp = cam.ViewportSize
	const tap, tsz = TopBarApp.toggle.AbsolutePosition, TopBarApp.toggle.AbsoluteSize
	local w, h = NAmanage.Topbar_ComputedSize()
	const marginX, gap = 8, 10
	const dock = TopBarApp.dock or NATopbarDock or "top"

	if TopBarApp.mode == "bottom" then
		TopBarApp.panel.Parent = TopBarApp.toggle
		TopBarApp.panel.Size = UDim2.new(0, w, 0, TopBarApp.isOpen and h or 0)

		const openDown = dock ~= "bottom"
		TopBarApp.panel.AnchorPoint = openDown and Vector2.new(0.5, 0) or Vector2.new(0.5, 1)
		TopBarApp.panel.Position = openDown
			and UDim2.new(0.5, 0, 1, gap)
			or  UDim2.new(0.5, 0, 0, -gap)

		const ap = TopBarApp.panel.AbsolutePosition
		const aw = TopBarApp.panel.AbsoluteSize.X
		local dx = 0

		if ap.X < marginX then
			dx = marginX - ap.X
		end
		if ap.X + aw > vp.X - marginX then
			dx = (vp.X - marginX) - (ap.X + aw)
		end

		if dx ~= 0 then
			if openDown then
				TopBarApp.panel.Position = UDim2.new(0.5, dx, 1, gap)
			else
				TopBarApp.panel.Position = UDim2.new(0.5, dx, 0, -gap)
			end
		end
	else
		TopBarApp.panel.Parent = TopBarApp.top
		TopBarApp.panel.Size = UDim2.new(0, w, 0, TopBarApp.isOpen and h or 0)

		const canRight = (tap.X + tsz.X + gap + w) <= vp.X - marginX
		const canLeft  = (tap.X - gap - w) >= marginX

		if TopBarApp.sidePref == "right" and not canRight and canLeft then
			TopBarApp.sidePref = "left"
		elseif TopBarApp.sidePref == "left" and not canLeft and canRight then
			TopBarApp.sidePref = "right"
		elseif not canRight and not canLeft then
			TopBarApp.sidePref = ((vp.X - (tap.X + tsz.X)) >= tap.X) and "right" or "left"
		end

		const dock  = TopBarApp.dock or NATopbarDock or "top"
		const baseY = tap.Y + tsz.Y*0.5
		local y

		if dock == "bottom" then
			y = math.max(baseY + 55, h*0.5 + 4)
		else
			y = math.clamp(baseY, h*0.5 + 8, vp.Y - h*0.5 - 8)
		end

		if TopBarApp.sidePref == "right" then
			TopBarApp.panel.AnchorPoint = Vector2.new(0, 0.5)
			const x = math.min(tap.X + tsz.X + gap, vp.X - marginX - w)
			TopBarApp.panel.Position = UDim2.new(0, x, 0, y)
		else
			TopBarApp.panel.AnchorPoint = Vector2.new(1, 0.5)
			const x = math.max(tap.X - gap, marginX + w)
			TopBarApp.panel.Position = UDim2.new(0, x, 0, y)
		end
	end
end

NAmanage.Topbar_AnimateIcon=function(iconText)
	const ti=TweenInfo.new(0.1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	const ti2=TweenInfo.new(0.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
	NAmanage.Topbar_PlayTween("icon_shrink",TopBarApp.icon,ti,{TextSize=0}).Completed:Wait()
	TopBarApp.icon.Text=iconText or ""
	TopBarApp.icon.TextSize=0
	NAmanage.Topbar_PlayTween("icon_grow",TopBarApp.icon,ti2,{TextSize=24})
end

NAmanage.Topbar_UpdateToggleVisual=function(open, opts)
	opts = opts or {}
	const ti=TweenInfo.new(0.1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
	const function clamp01(v, fallback)
		local n = tonumber(v)
		if n == nil then return fallback end
		if n < 0 then n = 0 elseif n > 1 then n = 1 end
		return n
	end
	const baseGlass = clamp01(NAStuff.TopbarGlassTransparency or 0.12, 0.12)
	const baseStroke = clamp01(NAStuff.TopbarStrokeTransparency or 0.15, 0.15)
	const bgTarget=open and math.max(0, baseGlass - 0.06) or baseGlass
	const strokeT=open and math.max(0, baseStroke - 0.1) or baseStroke
	if opts.instant == true then
		if TopBarApp.tGlass then
			TopBarApp.tGlass.BackgroundTransparency = bgTarget
		end
		if TopBarApp.tStroke then
			TopBarApp.tStroke.Transparency = strokeT
		end
	else
		if TopBarApp.tGlass then NAmanage.Topbar_PlayTween("tglass_bg",TopBarApp.tGlass,ti,{BackgroundTransparency=bgTarget}) end
		if TopBarApp.tStroke then NAmanage.Topbar_PlayTween("tglass_stroke",TopBarApp.tStroke,ti,{Transparency=strokeT}) end
	end
	const CLOSED_ICON="three-bars-horizontal"
	const OPENED_ICON="twitter"
	if not opts.skipIcon then
		if opts.instant == true then
			if TopBarApp.icon then
				TopBarApp.icon.Text = open and OPENED_ICON or CLOSED_ICON
				TopBarApp.icon.TextSize = 24
			end
		elseif open then
			NAmanage.Topbar_AnimateIcon(OPENED_ICON)
		else
			NAmanage.Topbar_AnimateIcon(CLOSED_ICON)
		end
	end
end

NAmanage.Topbar_SetOpen=function(state, opts)
	opts = opts or {}
	if not TopBarApp.panel then return end
	if state == true and not TopBarApp.scroll and NAmanage.Topbar_Rebuild then
		NAmanage.Topbar_Rebuild(IsOnMobile == true and { skipWatch = true, skipVisual = true } or nil)
	end
	if state == true and not TopBarApp.scroll then
		NAmanage.MarkExternalLagProbe("topbar_open_missing_scroll")
		return false
	end
	TopBarApp.isOpen=state
	local w,h=NAmanage.Topbar_ComputedSize()
	TopBarApp.panel.Visible=true
	TopBarApp.underlay.Visible = state
	if TopBarApp.scroll then
		TopBarApp.scroll.Visible = state
	end
	TopBarApp.underlay.ZIndex=201
	if TopBarApp.scroll then
		TopBarApp.scroll.ZIndex=202
	end
	NAlib.disconnect("tb_follow")
	TopBarApp.animating=true
	NAmanage.Topbar_PositionPanel()
	if opts.instant == true then
		TopBarApp.panel.Size = UDim2.new(0, w, 0, state and h or 0)
		TopBarApp.panel.Visible = state == true
		TopBarApp.animating = false
		NAmanage.Topbar_UpdateToggleVisual(state, { instant = true, skipIcon = opts.skipIcon == true })
		if NAmanage.Topbar_UpdateButtonVisuals and opts.skipVisual ~= true then
			NAmanage.Topbar_UpdateButtonVisuals()
		end
		return
	end
	const ts=Services.TweenService
	const dur=0.18
	const ease=TweenInfo.new(dur,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
	if state then
		TopBarApp.panel.Size=UDim2.new(0,w,0,0)
		const tween=ts:Create(TopBarApp.panel,ease,{Size=UDim2.new(0,w,0,h)})
		tween:Play()
		tween.Completed:Connect(function()
			TopBarApp.animating=false
		end)
		NAlib.connect("tb_follow",Services.RunService.RenderStepped:Connect(function()
			NAmanage.Topbar_PositionPanel()
		end))
	else
		const tween=ts:Create(TopBarApp.panel,ease,{Size=UDim2.new(0,w,0,0)})
		tween:Play()
		tween.Completed:Connect(function()
			if not TopBarApp.isOpen then TopBarApp.panel.Visible=false end
			TopBarApp.animating=false
		end)
	end
	NAmanage.Topbar_UpdateToggleVisual(state)
	if NAmanage.Topbar_UpdateButtonVisuals then
		NAmanage.Topbar_UpdateButtonVisuals()
	end
end

NAmanage.Topbar_Toggle=function()
	NAmanage.Topbar_SetOpen(not TopBarApp.isOpen)
end

NAmanage.Topbar_ButtonIconFont = function(active)
	const path = BUILDER_ICON_FONT_PATH or "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
	const weight = active and Enum.FontWeight.Bold or Enum.FontWeight.Regular
	const cache = type(NAStuff.BuilderIconFontCache) == "table" and NAStuff.BuilderIconFontCache or {}
	NAStuff.BuilderIconFontCache = cache
	const key = path.."|"..tostring(weight)
	if cache[key] then
		return cache[key]
	end
	local ok, font = pcall(Font.new, path, weight, Enum.FontStyle.Normal)
	if ok and font then
		cache[key] = font
		return font
	end
	return TopBarApp and TopBarApp.icon and TopBarApp.icon.FontFace or nil
end

NAmanage.Topbar_DefFrame = function(def)
	if type(def) ~= "table" then
		return nil
	end
	const value = def.activeFrame
	if type(value) == "function" then
		local ok, frame = pcall(value, def)
		if ok then
			return frame
		end
		return nil
	end
	if type(value) == "string" and NAUIMANAGER then
		return NAUIMANAGER[value]
	end
	if typeof(value) == "Instance" then
		return value
	end
	return nil
end

NAmanage.Topbar_FrameOpen = function(frame)
	if typeof(frame) ~= "Instance" or not frame:IsA("GuiObject") then
		return false
	end
	if frame.Visible ~= true then
		return false
	end
	if NAmanage.GetAttr and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
		return false
	end
	return true
end

NAmanage.Topbar_ButtonActive = function(def)
	if type(def) ~= "table" then
		return false
	end
	if type(def.active) == "function" then
		local ok, active = pcall(def.active, def)
		if ok then
			return active == true
		end
	end
	const frame = NAmanage.Topbar_DefFrame(def)
	return NAmanage.Topbar_FrameOpen(frame)
end

NAmanage.Topbar_UpdateButtonVisuals = function(opts)
	opts = opts or {}
	if not TopBarApp or type(TopBarApp.childIcons) ~= "table" then
		return
	end
	const base = tonumber(NAStuff.TopbarButtonTransparency) or 0.18
	local i = 0
	for btn, icon in TopBarApp.childIcons do
		i += 1
		const def = TopBarApp.childDefs and TopBarApp.childDefs[btn]
		const active = NAmanage.Topbar_ButtonActive(def)
		if typeof(icon) == "Instance" then
			if opts.skipFont ~= true then
				const font = NAmanage.Topbar_ButtonIconFont(active)
				if font then
					pcall(function()
						icon.FontFace = font
					end)
				end
			end
			pcall(function()
				icon.TextTransparency = active and 0 or 0.08
			end)
		end
		const bg = TopBarApp.childBacks and TopBarApp.childBacks[btn]
		if typeof(bg) == "Instance" then
			pcall(function()
				bg.BackgroundTransparency = active and math.max(0, base - 0.08) or base
			end)
		end
		if opts.chunked == true and IsOnMobile == true and i % 2 == 0 then
			Wait()
		end
	end
end

NAmanage.Topbar_WatchButtonState = function(def)
	const frame = NAmanage.Topbar_DefFrame(def)
	if typeof(frame) ~= "Instance" or not frame:IsA("GuiObject") then
		return
	end
	NAlib.connect("tb_button_active", frame:GetPropertyChangedSignal("Visible"):Connect(function()
		Defer(function()
			if NAmanage.Topbar_UpdateButtonVisuals then
				NAmanage.Topbar_UpdateButtonVisuals()
			end
		end)
	end))
	pcall(function()
		NAlib.connect("tb_button_active", frame:GetAttributeChangedSignal("NAMenuMinimized"):Connect(function()
			Defer(function()
				if NAmanage.Topbar_UpdateButtonVisuals then
					NAmanage.Topbar_UpdateButtonVisuals()
				end
			end)
		end))
	end)
end

NAmanage.SideSwipe_ButtonIconFont = function(active)
	if NAmanage.Topbar_ButtonIconFont then
		const font = NAmanage.Topbar_ButtonIconFont(active)
		if font then
			return font
		end
	end
	const path = BUILDER_ICON_FONT_PATH or "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
	const weight = active and Enum.FontWeight.Bold or Enum.FontWeight.Regular
	local ok, font = pcall(Font.new, path, weight, Enum.FontStyle.Normal)
	if ok and font then
		return font
	end
	return TopBarApp and TopBarApp.icon and TopBarApp.icon.FontFace or nil
end

NAmanage.SideSwipe_ButtonActive = function(def)
	if NAmanage.Topbar_ButtonActive then
		return NAmanage.Topbar_ButtonActive(def) == true
	end
	return false
end

NAmanage.SideSwipe_UpdateButtonVisuals = function(opts)
	opts = opts or {}
	if not SideSwipeApp or type(SideSwipeApp.childIcons) ~= "table" then
		return
	end
	const base = tonumber(NAStuff.SideSwipeButtonTransparency) or 0.16
	local i = 0
	for btn, icon in SideSwipeApp.childIcons do
		i += 1
		const def = SideSwipeApp.childDefs and SideSwipeApp.childDefs[btn]
		const active = NAmanage.SideSwipe_ButtonActive(def)
		if typeof(icon) == "Instance" then
			if opts.skipFont ~= true then
				const font = NAmanage.SideSwipe_ButtonIconFont(active)
				if font then
					pcall(function()
						icon.FontFace = font
					end)
				end
			end
			pcall(function()
				icon.TextTransparency = active and 0 or 0.08
			end)
		end
		const bg = SideSwipeApp.childBacks and SideSwipeApp.childBacks[btn]
		if typeof(bg) == "Instance" then
			pcall(function()
				bg.BackgroundTransparency = active and math.max(0, base - 0.08) or base
			end)
		end
		if opts.chunked == true and IsOnMobile == true and i % 2 == 0 then
			Wait()
		end
	end
end

NAmanage.SideSwipe_SyncButtonVisuals = function()
	Defer(function()
		if NAmanage.Topbar_UpdateButtonVisuals then
			NAmanage.Topbar_UpdateButtonVisuals()
		end
		if NAmanage.SideSwipe_UpdateButtonVisuals then
			NAmanage.SideSwipe_UpdateButtonVisuals()
		end
	end)
end

NAmanage.SideSwipe_WatchButtonState = function(def)
	const frame = NAmanage.Topbar_DefFrame and NAmanage.Topbar_DefFrame(def) or nil
	if typeof(frame) ~= "Instance" or not frame:IsA("GuiObject") then
		return
	end
	NAlib.connect("ss_button_active", frame:GetPropertyChangedSignal("Visible"):Connect(function()
		if NAmanage.SideSwipe_SyncButtonVisuals then
			NAmanage.SideSwipe_SyncButtonVisuals()
		end
	end))
	pcall(function()
		NAlib.connect("ss_button_active", frame:GetAttributeChangedSignal("NAMenuMinimized"):Connect(function()
			if NAmanage.SideSwipe_SyncButtonVisuals then
				NAmanage.SideSwipe_SyncButtonVisuals()
			end
		end))
	end)
end

NAmanage.Topbar_Rebuild=function(opts)
	opts = opts or {}
	NAmanage.MarkExternalLagProbe("topbar_rebuild_start")
	TopBarApp.childIcons = NAmanage.ensureWeakTable(nil, "k")
	TopBarApp.childBacks = NAmanage.ensureWeakTable(nil, "k")
	TopBarApp.childDefs = NAmanage.ensureWeakTable(nil, "k")
	NAlib.disconnect("tb_button_active")
	if TopBarApp.scroll then TopBarApp.scroll:Destroy() TopBarApp.scroll=nil end
	TopBarApp.scroll=InstanceNew("ScrollingFrame",TopBarApp.panel)
	TopBarApp.scroll.BackgroundTransparency=1
	TopBarApp.scroll.BorderSizePixel=0
	TopBarApp.scroll.Size=UDim2.new(1,0,1,0)
	TopBarApp.scroll.ZIndex=202
	TopBarApp.scroll.ScrollBarThickness=4
	for _,c in TopBarApp.scroll:GetChildren() do c:Destroy() end
	for btn,_ in TopBarApp.childButtons do TopBarApp.childButtons[btn]=nil end
	const pad=InstanceNew("UIPadding",TopBarApp.scroll)
	pad.PaddingTop=UDim.new(0,6)
	pad.PaddingBottom=UDim.new(0,6)
	pad.PaddingLeft=UDim.new(0,6)
	pad.PaddingRight=UDim.new(0,6)
	if TopBarApp.layout then TopBarApp.layout:Destroy() TopBarApp.layout=nil end
	const tileBottom=44
	const tileSide=48
	if TopBarApp.mode=="bottom" then
		TopBarApp.scroll.ScrollingDirection=Enum.ScrollingDirection.Y
		const grid=InstanceNew("UIGridLayout",TopBarApp.scroll)
		grid.CellSize=UDim2.new(0,tileBottom,0,tileBottom)
		grid.CellPadding=UDim2.new(0,8,0,8)
		grid.HorizontalAlignment=Enum.HorizontalAlignment.Center
		grid.VerticalAlignment=Enum.VerticalAlignment.Top
		grid.SortOrder=Enum.SortOrder.LayoutOrder
		TopBarApp.layout=grid
	else
		TopBarApp.scroll.ScrollingDirection = Enum.ScrollingDirection.X
		const list = InstanceNew("UIListLayout", TopBarApp.scroll)
		list.FillDirection = Enum.FillDirection.Horizontal
		list.HorizontalAlignment = Enum.HorizontalAlignment.Left
		list.VerticalAlignment = Enum.VerticalAlignment.Center
		list.Padding = UDim.new(0,8)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		TopBarApp.layout = list
	end
	local i=0
	for _,def in TopBarApp.buttonDefs do
		i+=1
		NAmanage.MarkExternalLagProbe("topbar_rebuild_button:"..tostring(def.name or i))
		const btn=InstanceNew("TextButton",TopBarApp.scroll)
		btn.Name=def.name.."Btn"
		btn.Size=UDim2.new(0, TopBarApp.mode=="bottom" and tileBottom or tileSide, 0, TopBarApp.mode=="bottom" and tileBottom or tileSide)
		btn.BackgroundTransparency=1
		btn.BorderSizePixel=0
		btn.LayoutOrder=i
		btn.Text=''
		btn.TextTransparency=1
		btn.ZIndex=205
		const bg=InstanceNew("Frame",btn)
		bg.ZIndex=203
		bg.Size=UDim2.new(1,0,1,0)
		bg.BackgroundColor3=Color3.fromRGB(25,25,28)
		bg.BackgroundTransparency=NAStuff.TopbarButtonTransparency or 0.18
		bg.BorderSizePixel=0
		const cr=InstanceNew("UICorner",bg); cr.CornerRadius=UDim.new(0, 6)
		const stroke=InstanceNew("UIStroke",bg)
		stroke.Thickness=1
		stroke.Color=NAUISTROKER or Color3.fromRGB(148,93,255)
		stroke.Transparency=0.15
		NAgui.RegisterColoredStroke(stroke)
		const ic=InstanceNew("TextLabel",bg)
		ic.ZIndex=204
		ic.BackgroundTransparency=1
		ic.Size=UDim2.new(0.65,0,0.65,0)
		ic.Position=UDim2.new(0.5,0,0.5,0)
		ic.AnchorPoint=Vector2.new(0.5,0.5)
		local iconFont = nil
		if opts.skipFont == true then
			iconFont = TopBarApp.icon and TopBarApp.icon.FontFace or nil
		else
			iconFont = NAmanage.Topbar_ButtonIconFont(false) or TopBarApp.icon.FontFace
		end
		if iconFont then
			ic.FontFace=iconFont
		else
			ic.Font=Enum.Font.GothamBold
		end
		ic.Text=def.icon or def.name or ""
		ic.TextColor3=Color3.new(1,1,1)
		ic.TextScaled=false
		ic.TextSize=24
		TopBarApp.childIcons[btn] = ic
		TopBarApp.childBacks[btn] = bg
		TopBarApp.childDefs[btn] = def
		if opts.skipWatch ~= true then
			NAmanage.Topbar_WatchButtonState(def)
		end
		const function fireTopbarButton()
			if type(def.func) == "function" then
				def.func()
			end
			Defer(function()
				if NAmanage.Topbar_UpdateButtonVisuals then
					NAmanage.Topbar_UpdateButtonVisuals()
				end
			end)
		end
		TopBarApp.childButtons[btn]=fireTopbarButton
		MouseButtonFix(btn,fireTopbarButton)
	end
	const function updateCanvas()
		if TopBarApp.mode == "bottom" then
			TopBarApp.scroll.CanvasSize = UDim2.new(0,0,0,TopBarApp.layout.AbsoluteContentSize.Y+12)
		else
			TopBarApp.scroll.CanvasSize = UDim2.new(0,TopBarApp.layout.AbsoluteContentSize.X+12,0,0)
		end
		if not TopBarApp.animating then
			NAmanage.Topbar_PositionPanel()
		end
	end
	NAlib.disconnect("tb_canvas")
	NAlib.connect("tb_canvas",TopBarApp.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas))
	updateCanvas()
	if opts.skipVisual ~= true then
		NAmanage.Topbar_UpdateButtonVisuals()
	end
	NAmanage.MarkExternalLagProbe("topbar_rebuild_done")
end

NAmanage.Topbar_DeferActiveRefresh = NAmanage.Topbar_DeferActiveRefresh or function()
	if IsOnMobile == true then
		NAmanage.MarkExternalLagProbe("topbar_active_refresh_not_scheduled_mobile")
		return
	end
	Defer(function()
		Wait(0.5)
		if not (TopBarApp and TopBarApp.top and TopBarApp.top.Parent and type(TopBarApp.buttonDefs) == "table") then
			return
		end
		NAmanage.MarkExternalLagProbe("topbar_active_refresh_start")
		NAlib.disconnect("tb_button_active")
		for i, def in TopBarApp.buttonDefs do
			NAmanage.MarkExternalLagProbe("topbar_active_watch:"..tostring(def.name or i))
			NAmanage.Topbar_WatchButtonState(def)
		end
		if NAmanage.Topbar_UpdateButtonVisuals then
			NAmanage.MarkExternalLagProbe("topbar_active_visuals_start")
			NAmanage.Topbar_UpdateButtonVisuals({ chunked = true })
			NAmanage.MarkExternalLagProbe("topbar_active_visuals_done")
		end
		NAmanage.MarkExternalLagProbe("topbar_active_refresh_done")
	end)
end

NAmanage.Topbar_AddButton=function(def)
	TopBarApp.buttonDefs[#TopBarApp.buttonDefs+1]=def
	NAmanage.Topbar_Rebuild()
	NAmanage.SideSwipe_Rebuild()
	if TopBarApp.isOpen then NAmanage.Topbar_PositionPanel() end
end

NAmanage.Topbar_ClampToggle=function()
	if not (TopBarApp and TopBarApp.frame and TopBarApp.toggle) then
		return
	end
	if NATopbarKeepPosition then
		NAmanage.Topbar_ApplySavedPosition()
		return
	end
	const fw=TopBarApp.frame.AbsoluteSize.X
	const bw=TopBarApp.toggle.AbsoluteSize.X
	const maxOffset=math.max((fw-bw)*0.5,0)
	const off=math.clamp(TopBarApp.toggle.Position.X.Offset,-maxOffset,maxOffset)
	const pos=TopBarApp.toggle.Position
	TopBarApp.toggle.Position=UDim2.new(0.5,off,pos.Y.Scale,pos.Y.Offset)
	if TopBarApp.isOpen then
		NAmanage.Topbar_PositionPanel()
	end
end

NAmanage.Topbar_MakeDraggableHorizontal=function(ui)
	const key = "tb_drag_ui"
	NAlib.disconnect(key)
	local dragging=false
	local dragInput,dragStart,startPos

	NAlib.connect(key, ui.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true
			dragStart=input.Position
			startPos=ui.Position
			local endConn
			endConn=NAlib.connect(key, input.Changed:Connect(function()
				if input.UserInputState==Enum.UserInputState.End then
					dragging=false
					if NATopbarKeepPosition then
						NAmanage.Topbar_SavePositionPreference()
					end
					if endConn then
						endConn:Disconnect()
						endConn=nil
						if NAmanage and NAmanage.prnCon then
							NAmanage.prnCon(key)
						end
					end
				end
			end))
		end
	end))

	NAlib.connect(key, ui.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			dragInput=input
		end
	end))

	local lastStep=0
	NAlib.disconnect("tb_drag_input")
	NAlib.connect("tb_drag_input",Services.UserInputService.InputChanged:Connect(function(input)
		if input==dragInput and dragging then
			const now=os.clock()
			if now-lastStep<(1/60) then return end
			lastStep=now
			const delta=input.Position-dragStart
			const fw=TopBarApp.frame.AbsoluteSize.X
			const bw=ui.AbsoluteSize.X
			const base=startPos.X.Offset
			const newX=math.clamp(base+delta.X,-(fw-bw)/2,(fw-bw)/2)
			ui.Position=UDim2.new(0.5,newX,startPos.Y.Scale,startPos.Y.Offset)
			if TopBarApp.isOpen then
				NAmanage.Topbar_PositionPanel()
			end
		end
	end))

	ui.Active=true
end

NAmanage.Topbar_SetMode=function(mode)
	if mode~="bottom" and mode~="side" then return end
	TopBarApp.mode=mode
	NAmanage.topbar_writeMode(mode)
	NAmanage.Topbar_Rebuild()
	if TopBarApp.isOpen then NAmanage.Topbar_PositionPanel() end
end

NAmanage.Topbar_SetDock=function(dock)
	dock = dock == "bottom" and "bottom" or "top"
	NATopbarDock = dock
	TopBarApp.dock = dock
	NAmanage.topbar_writeDock(dock)
	NAmanage.Topbar_ApplyDock(dock)
end

NAmanage.Topbar_SetVisible=function(visible, opts)
	opts = opts or {}
	NATOPBARVISIBLE = visible == true
	if TopBarApp and TopBarApp.top then
		TopBarApp.top.Visible = NATOPBARVISIBLE
		if not NATOPBARVISIBLE and TopBarApp.isOpen and NAmanage.Topbar_SetOpen then
			NAmanage.Topbar_SetOpen(false)
		end
	elseif NATOPBARVISIBLE and NAmanage.Topbar_Init then
		pcall(NAmanage.Topbar_Init)
	end
	NAmanage.NASettingsSet("topbarVisible", NATOPBARVISIBLE)
	if NAmanage.RunUIAutoSync then
		pcall(NAmanage.RunUIAutoSync)
	end
	if opts.notify ~= false then
		DebugNotif("Topbar "..(NATOPBARVISIBLE and "shown" or "hidden"), 2)
	end
	return NATOPBARVISIBLE
end

NAmanage.Commands_IsFrame = function(frame)
	return NAUIMANAGER and frame ~= nil and frame == NAUIMANAGER.commandsFrame
end

NAmanage.Commands_IsMinimized = function(frame)
	frame = frame or (NAUIMANAGER and NAUIMANAGER.commandsFrame)
	return frame ~= nil and NAmanage.GetAttr and NAmanage.GetAttr(frame, "NAMenuMinimized") == true
end

NAmanage.Commands_SyncHiddenState = function(opts)
	opts = opts or {}
	const frame = NAUIMANAGER and NAUIMANAGER.commandsFrame
	if not frame then
		return false
	end
	const shown = frame.Visible == true
	const minimized = NAmanage.Commands_IsMinimized(frame)
	const body = frame:FindFirstChild("Container")
	if body and body:IsA("GuiObject") then
		body.Visible = shown and not minimized
	end
	if NAUIMANAGER.description and (not shown or minimized) then
		NAUIMANAGER.description.Visible = false
		NAUIMANAGER.description.Text = ""
	end
	if shown and not minimized then
		if opts.center == true and NAmanage.centerFrame then
			NAmanage.centerFrame(frame)
		end
		if opts.responsive ~= false and type(NAmanage.cmdResp) == "function" then
			pcall(NAmanage.cmdResp, opts.center == true)
		end
		if opts.syncRows ~= false and type(NAmanage.syncVisibleCommandRows) == "function" then
			pcall(NAmanage.syncVisibleCommandRows)
		end
	end
	return shown and not minimized
end

NAmanage.Commands_SetVisible = function(visible, opts)
	opts = opts or {}
	const frame = NAUIMANAGER and NAUIMANAGER.commandsFrame
	if not frame then
		return false
	end
	visible = visible == true
	frame.Visible = visible
	if visible then
		if opts.resetCanvas ~= false and NAUIMANAGER.commandsList then
			NAUIMANAGER.commandsList.CanvasSize = UDim2.new(0, 0, 0, 0)
		end
		if type(NAgui) == "table" and type(NAgui.commands) == "function" and opts.refresh ~= false then
			pcall(NAgui.commands, {
				fromToggle = true;
				center = opts.center ~= false;
			})
		else
			NAmanage.Commands_SyncHiddenState({
				center = opts.center ~= false;
				syncRows = opts.syncRows ~= false;
			})
		end
	else
		NAmanage.Commands_SyncHiddenState({
			responsive = false;
			syncRows = false;
		})
	end
	return true
end

NAmanage.Commands_Toggle = function()
	const frame = NAUIMANAGER and NAUIMANAGER.commandsFrame
	if not frame then
		return false
	end
	if frame.Visible then
		return NAmanage.Commands_SetVisible(false, { refresh = false })
	end
	return NAmanage.Commands_SetVisible(true, { refresh = true; center = true; resetCanvas = true })
end

NAmanage.Topbar_BuildBaseButtons=function()
	return {
		{name="settings",icon="gear",activeFrame="SettingsFrame",func=function()
			if NAUIMANAGER.SettingsFrame then
				NAUIMANAGER.SettingsFrame.Visible=not NAUIMANAGER.SettingsFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.SettingsFrame)
			end
		end},
		{name="cmds",icon="list-bulleted",activeFrame="commandsFrame",func=function()
			if NAmanage.Commands_Toggle then
				NAmanage.Commands_Toggle()
			elseif NAgui and NAgui.commands then
				NAgui.commands()
			end
		end},
		{name="chatlogs",icon="speech-bubble-align-center",activeFrame="chatLogsFrame",func=function()
			if NAUIMANAGER.chatLogsFrame then
				NAUIMANAGER.chatLogsFrame.Visible=not NAUIMANAGER.chatLogsFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.chatLogsFrame)
			end
		end},
		{name="nachat",icon="we-chat",activeFrame="NAchatFrame",func=function()
			local frame = NAUIMANAGER and NAUIMANAGER.NAchatFrame
			if not frame then
				return
			end
			if frame.Visible then
				frame.Visible = false
			elseif NAgui and type(NAgui.nachat) == "function" then
				NAgui.nachat()
			else
				frame.Visible = true
				NAmanage.centerFrame(frame)
			end
		end},
		{name="console",icon="pencil-square",activeFrame="NAconsoleFrame",func=function()
			if NAUIMANAGER.NAconsoleFrame then
				NAUIMANAGER.NAconsoleFrame.Visible=not NAUIMANAGER.NAconsoleFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.NAconsoleFrame)
			end
		end},
		{name="waypp",icon="location-pin",activeFrame="WaypointFrame",func=function()
			if NAUIMANAGER.WaypointFrame then
				NAUIMANAGER.WaypointFrame.Visible=not NAUIMANAGER.WaypointFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.WaypointFrame)
			end
		end},
		{name="bindd",icon="hammer-code",activeFrame="BindersFrame",func=function()
			if NAUIMANAGER.BindersFrame then
				NAUIMANAGER.BindersFrame.Visible=not NAUIMANAGER.BindersFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.BindersFrame)
			end
		end},
		{name="executor",icon="code",activeFrame="ExecutorFrame",func=function()
			NAmanage.Executor_Toggle()
		end},
		{name="notepad",icon="three-ring-note",activeFrame="NotepadFrame",func=function()
			if NAmanage.Notepad_Toggle then
				NAmanage.Notepad_Toggle()
			else
				DoNotif("Notepad UI unavailable.", 3)
			end
		end},
		{name="ckeybinds",icon="xbox-a",activeFrame="CommandKeybindsFrame",func=function()
			const frame = NAUIMANAGER and NAUIMANAGER.CommandKeybindsFrame
			if frame then
				if frame.Visible then
					frame.Visible = false
				else
					NAgui.commandkeybinds()
				end
			end
		end},
		{name="plugins",icon="nebula",activeFrame="PluginsFrame",func=function()
			if NAmanage and NAmanage.PluginsWindow_Toggle then
				NAmanage.PluginsWindow_Toggle()
			elseif NAgui and NAgui.plugins then
				NAgui.plugins()
			end
		end},
		{name="music",icon="music-note",activeFrame="MusicFrame",func=function()
			if NAmanage and NAmanage.MusicWindow_Toggle then
				NAmanage.MusicWindow_Toggle()
			else
				DoNotif("Music player UI unavailable.", 3, "Music")
			end
		end},
		{name="scripthub",icon="cloud",activeFrame="ScriptHubFrame",func=function()
			if NAmanage and NAmanage.ScriptHub_Toggle then
				NAmanage.ScriptHub_Toggle()
			else
				DoNotif("Script Hub UI unavailable.", 3, "Script Hub")
			end
		end},
		{name="tpui",icon="globe-detailed",activeFrame="SubplaceViewerFrame",func=function()
			if NAmanage and NAmanage.SubplaceViewer_Toggle then
				NAmanage.SubplaceViewer_Toggle()
			else
				DoNotif("Subplace Viewer UI unavailable.", 3, "Subplace Viewer")
			end
		end},
		{name="serverlist",icon="grid",activeFrame="ServerListFrame",func=function()
			if NAmanage and NAmanage.ServerList_Toggle then
				NAmanage.ServerList_Toggle()
			else
				DoNotif("Server List UI unavailable.", 3, "Server List")
			end
		end},
	}
end

NAmanage.GetManagedUIRoot = NAmanage.GetManagedUIRoot or function(key, visible, z)
	const gui = (NAmanage.waitForScreenGui and NAmanage.waitForScreenGui(5)) or (NAStuff and NAStuff.NASCREENGUI)
	if not (gui and typeof(gui) == "Instance" and gui:IsA("ScreenGui")) then
		return nil
	end
	pcall(function()
		if NAgui and type(NAgui.NaProtectUI) == "function" then
			NAgui.NaProtectUI(gui)
		end
	end)
	pcall(function()
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	end)

	const name = NAmanage.GetSessionInstanceName(key)
	const old = Services.CoreGui and Services.CoreGui:FindFirstChild(name)
	if old and old ~= gui and old:IsA("ScreenGui") then
		pcall(function()
			old:Destroy()
		end)
	end

	local root
	for _, child in gui:GetChildren() do
		if child.Name == name then
			if child:IsA("Frame") and not root then
				root = child
			else
				child:Destroy()
			end
		end
	end

	if not root then
		root = InstanceNew("Frame")
		root.Name = name
		root.Parent = gui
	end

	root.BackgroundTransparency = 1
	root.BorderSizePixel = 0
	root.ClipsDescendants = false
	root.Active = false
	root.Position = UDim2.fromScale(0, 0)
	root.Size = UDim2.fromScale(1, 1)
	root.ZIndex = tonumber(z) or root.ZIndex
	root.Visible = visible ~= false
	return root
end

NAmanage.Topbar_Init=function(opts)
	opts = opts or {}
	NAmanage.MarkExternalLagProbe("topbar_init_start")
	if TopBarApp.top and TopBarApp.top.Parent and opts.force ~= true then
		const topbarRoot = TopBarApp.top
		for _, sibling in topbarRoot.Parent:GetChildren() do
			if sibling ~= topbarRoot and sibling.Name == topbarRoot.Name then
				sibling:Destroy()
			end
		end
		NAmanage.MarkExternalLagProbe("topbar_init_skip_existing")
		return true
	end
	if NAmanage._topbarInitRunning then
		return TopBarApp.top ~= nil and TopBarApp.top.Parent ~= nil
	end
	NAmanage._topbarInitRunning = true
	local ok, result = pcall(function()
		if TopBarApp.top and TopBarApp.top.Parent then TopBarApp.top:Destroy() end
		NATopbarDock = NAmanage.topbar_readDock()
		TopBarApp.top = NAmanage.GetManagedUIRoot("TopbarStyled", NATOPBARVISIBLE, 900)
		if not TopBarApp.top then return false end
		NAmanage.MarkExternalLagProbe("topbar_root_ready")
		for _, child in TopBarApp.top:GetChildren() do
			child:Destroy()
		end
		TopBarApp.top.Visible = NATOPBARVISIBLE
		TopBarApp.frame=InstanceNew("Frame")
		TopBarApp.frame.Size=UDim2.new(1,0,0,36)
		TopBarApp.frame.Position=UDim2.new(0,0,0,0)
		TopBarApp.frame.BackgroundTransparency=1
		TopBarApp.frame.Parent=TopBarApp.top
		TopBarApp.toggle=InstanceNew("TextButton",TopBarApp.frame)
		TopBarApp.toggle.Name="TopbarToggle"
		TopBarApp.toggle.Size=UDim2.new(0,42,0,42)
		TopBarApp.toggle.Position=UDim2.new(0.5,0,0,10)
		TopBarApp.toggle.AnchorPoint=Vector2.new(0.5,0)
		TopBarApp.toggle.BackgroundTransparency=1
		TopBarApp.toggle.BorderSizePixel=0
		TopBarApp.toggle.ClipsDescendants=false
		TopBarApp.toggle.ZIndex=110
		TopBarApp.toggle.Text=''
		TopBarApp.toggle.TextTransparency=1
		TopBarApp.tGlass=InstanceNew("Frame",TopBarApp.toggle)
		TopBarApp.tGlass.Size=UDim2.new(1,0,1,0)
		TopBarApp.tGlass.BackgroundColor3=Color3.fromRGB(20,20,24)
		TopBarApp.tGlass.BackgroundTransparency=NAStuff.TopbarGlassTransparency or 0.12
		TopBarApp.tGlass.ZIndex=111
		const tCorner=InstanceNew("UICorner",TopBarApp.tGlass); tCorner.CornerRadius=NAmanage.Topbar_GetButtonCornerRadius(NAStuff.TopbarButtonShape)
		TopBarApp.tStroke=InstanceNew("UIStroke",TopBarApp.tGlass)
		TopBarApp.tStroke.Thickness=1.25
		TopBarApp.tStroke.Color=NAUISTROKER or Color3.fromRGB(148,93,255)
		TopBarApp.tStroke.Transparency=NAStuff.TopbarStrokeTransparency or 0.15
		NAgui.RegisterColoredStroke(TopBarApp.tStroke)
		TopBarApp.icon=InstanceNew("TextLabel",TopBarApp.toggle)
		TopBarApp.icon.AnchorPoint=Vector2.new(0.5,0.5)
		TopBarApp.icon.Position=UDim2.new(0.5,0,0.5,0)
		TopBarApp.icon.Size=UDim2.new(0.8,0,0.8,0)
		TopBarApp.icon.BackgroundTransparency=1
		TopBarApp.icon.ZIndex=112
		const startupLite = type(NAmanage.IsStartupBuilding) == "function" and NAmanage.IsStartupBuilding()
		NAmanage.MarkExternalLagProbe("topbar_icon_font_start")
		TopBarApp.icon.FontFace=Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",Enum.FontWeight.Bold,Enum.FontStyle.Normal)
		TopBarApp.icon.Text = "three-bars-horizontal"
		NAmanage.MarkExternalLagProbe("topbar_icon_font_done")
		TopBarApp.icon.TextColor3=Color3.new(1,1,1)
		TopBarApp.icon.TextScaled=false
		TopBarApp.icon.TextSize=24
		TopBarApp.dock = NATopbarDock or TopBarApp.dock or "top"
		NAmanage.MarkExternalLagProbe("topbar_apply_dock_start")
		NAmanage.Topbar_ApplyDock(TopBarApp.dock, { save = false })
		NAmanage.MarkExternalLagProbe("topbar_apply_dock_done")
		TopBarApp.panel=InstanceNew("Frame",TopBarApp.top)
		TopBarApp.panel.Visible=false
		TopBarApp.panel.ClipsDescendants=true
		TopBarApp.panel.BackgroundTransparency=1
		TopBarApp.panel.ZIndex=200
		TopBarApp.underlay=InstanceNew("Frame",TopBarApp.panel)
		TopBarApp.underlay.Size=UDim2.new(1,0,1,0)
		TopBarApp.underlay.BackgroundColor3=Color3.fromRGB(18,18,22)
		TopBarApp.underlay.BackgroundTransparency=NAStuff.TopbarPanelTransparency or 0.1
		TopBarApp.underlay.ZIndex=201
		const pCorner=InstanceNew("UICorner",TopBarApp.underlay); pCorner.CornerRadius=UDim.new(0, 6)
		const pStroke=InstanceNew("UIStroke",TopBarApp.underlay)
		pStroke.Thickness=1
		pStroke.Color=NAUISTROKER or Color3.fromRGB(148,93,255)
		pStroke.Transparency=0.2
		NAgui.RegisterColoredStroke(pStroke)
		TopBarApp.buttonDefs=NAmanage.Topbar_BuildBaseButtons()
		NAmanage.MarkExternalLagProbe("topbar_rebuild_call")
		NAmanage.Topbar_Rebuild(startupLite and { skipWatch = true, skipVisual = true } or nil)
		NAmanage.MarkExternalLagProbe("topbar_setopen_start")
		NAmanage.Topbar_SetOpen(false, startupLite and { instant = true, skipIcon = true, skipVisual = true } or nil)
		NAmanage.MarkExternalLagProbe("topbar_setopen_done")
		NAmanage.MarkExternalLagProbe("topbar_mousefix_start")
		MouseButtonFix(TopBarApp.toggle,NAmanage.Topbar_Toggle)
		NAmanage.MarkExternalLagProbe("topbar_mousefix_done")
		NAmanage.MarkExternalLagProbe("topbar_drag_start")
		NAmanage.Topbar_MakeDraggableHorizontal(TopBarApp.toggle)
		NAmanage.MarkExternalLagProbe("topbar_drag_done")
		NAmanage.Topbar_ClampToggle()
		NAlib.connect("tb_repos_frame",TopBarApp.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			NAmanage.Topbar_ClampToggle()
			if TopBarApp.isOpen then NAmanage.Topbar_PositionPanel() end
		end))
		if Services.Workspace.CurrentCamera then
			NAlib.connect("tb_repos_vp",Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				NAmanage.Topbar_ClampToggle()
				if TopBarApp.isOpen then NAmanage.Topbar_PositionPanel() end
			end))
		end
		if startupLite then
			NAmanage.Topbar_DeferActiveRefresh()
		end
		NAmanage.MarkExternalLagProbe("topbar_init_done")
		return true
	end)
	NAmanage._topbarInitRunning = false
	if not ok then
		error(result, 0)
	end
	return result
end
NAmanage.Topbar_Destroy=function()
	NAlib.disconnect("tb_canvas")
	NAlib.disconnect("tb_repos_frame")
	NAlib.disconnect("tb_repos_vp")
	NAlib.disconnect("tb_follow")
	NAlib.disconnect("tb_drag_ui")
	NAlib.disconnect("tb_drag_input")
	if TopBarApp and TopBarApp.top then TopBarApp.top:Destroy() end
	TopBarApp={ top=nil; frame=nil; toggle=nil; tGlass=nil; tStroke=nil; icon=nil; panel=nil; underlay=nil; scroll=nil; layout=nil; isOpen=false; childButtons=NAmanage.ensureWeakTable(nil, "k"); buttonDefs={}, mode=NAmanage.topbar_readMode(), sidePref="right", dock=NAmanage.topbar_readDock() }
end

NAmanage.SideSwipe_GetButtons=function()
	if TopBarApp and TopBarApp.buttonDefs and #TopBarApp.buttonDefs > 0 then
		return TopBarApp.buttonDefs
	end
	return NAmanage.Topbar_BuildBaseButtons()
end

NAmanage.SideSwipe_PositionHandles=function()
	if not (SideSwipeApp.gui and (SideSwipeApp.handles.left or SideSwipeApp.handles.right)) then return end
	const cam = Services.Workspace.CurrentCamera
	const vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	const panelW = math.clamp(tonumber(NAStuff.SideSwipeWidth) or 80, 60, 200)
	const configuredW = math.clamp(math.floor((tonumber(NAStuff.SideSwipeHandleWidth) or 0) + 0.5), 0, 120)
	const configuredH = math.clamp(math.floor((tonumber(NAStuff.SideSwipeHandleHeight) or 0) + 0.5), 0, 800)
	const handleW = configuredW > 0 and math.clamp(configuredW, 8, math.max(8, math.floor(vp.X * 0.35))) or math.clamp(math.floor(panelW * 0.22 + 0.5), 16, 44)
	const handleH = configuredH > 0 and math.clamp(configuredH, 24, math.max(24, vp.Y - 8)) or math.clamp(vp.Y * 0.22, 90, 180)
	const inset = math.max(4, math.floor(handleW * 0.4 + 0.5))
	const vertical = math.clamp(tonumber(NAStuff.SideSwipeHandleVerticalPosition) or 50, 0, 100) / 100
	const y = math.clamp(vp.Y * vertical, handleH * 0.5 + 4, math.max(handleH * 0.5 + 4, vp.Y - handleH * 0.5 - 4))
	const hideHandles = SideSwipeApp.handlesHidden == true or SideSwipeApp.isOpen == true
	if SideSwipeApp.handles.left then
		if hideHandles then
			SideSwipeApp.handles.left.Position = UDim2.new(0, -handleW - 12, 0, y)
			SideSwipeApp.handles.left.Active = false
		else
			SideSwipeApp.handles.left.Position = UDim2.new(0, inset, 0, y)
		end
		SideSwipeApp.handles.left.Size = UDim2.new(0, handleW, 0, handleH)
	end
	if SideSwipeApp.handles.right then
		if hideHandles then
			SideSwipeApp.handles.right.Position = UDim2.new(1, handleW + 12, 0, y)
			SideSwipeApp.handles.right.Active = false
		else
			SideSwipeApp.handles.right.Position = UDim2.new(1, -inset, 0, y)
		end
		SideSwipeApp.handles.right.Size = UDim2.new(0, handleW, 0, handleH)
	end
end

NAmanage.SideSwipe_UpdateHandleColors=function(color)
	const mainColor = typeof(color) == "Color3" and color or NAUISTROKER or DEFAULT_UI_STROKE_COLOR or Color3.fromRGB(148,93,255)
	if SideSwipeApp.handles.left then
		SideSwipeApp.handles.left.BackgroundColor3 = mainColor
	end
	if SideSwipeApp.handles.right then
		SideSwipeApp.handles.right.BackgroundColor3 = mainColor
	end
end

NAmanage.SideSwipe_UpdateHandleSide=function()
	const side = SideSwipeApp.side or "left"
	if SideSwipeApp.handles.left then
		SideSwipeApp.handles.left.Visible = side == "left"
		SideSwipeApp.handles.left.Active = side == "left"
	end
	if SideSwipeApp.handles.right then
		SideSwipeApp.handles.right.Visible = side == "right"
		SideSwipeApp.handles.right.Active = side == "right"
	end
	NAmanage.SideSwipe_PositionHandles()
end

NAmanage.SideSwipe_PointInside=function(gui, point)
	if not (gui and gui.Visible) then return false end
	const pos = gui.AbsolutePosition
	const size = gui.AbsoluteSize
	return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

NAmanage.SideSwipe_GetPanelY=function(vp, size, margin)
	vp = vp or Vector2.new(1280, 720)
	size = size or Vector2.new(0, 0)
	margin = tonumber(margin) or 10
	const centerY = vp.Y * 0.5
	const minY = size.Y * 0.5 + margin
	const maxY = vp.Y - size.Y * 0.5 - margin
	if maxY < minY then
		return centerY
	end
	return math.clamp(centerY, minY, maxY)
end

NAmanage.SideSwipe_ShouldCloseFrom=function(point)
	if NAmanage.SideSwipe_PointInside(SideSwipeApp.panel, point)
		or NAmanage.SideSwipe_PointInside(SideSwipeApp.underlay, point)
		or NAmanage.SideSwipe_PointInside(SideSwipeApp.scroll, point) then
		return false
	end
	if NAmanage.SideSwipe_PointInside(SideSwipeApp.handles.left, point) or NAmanage.SideSwipe_PointInside(SideSwipeApp.handles.right, point) then
		return false
	end
	return true
end

NAmanage.SideSwipe_PositionPanel=function(opts)
	opts = opts or {}
	if not SideSwipeApp.panel then return end
	const cam = Services.Workspace.CurrentCamera
	const vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	const size = SideSwipeApp.panel.AbsoluteSize
	const margin = 10
	local xOn, xOff
	const side = SideSwipeApp.side or "left"
	local anchor = Vector2.new(0, 0.5)
	if side == "right" then
		anchor = Vector2.new(1, 0.5)
		xOn = vp.X - margin
		xOff = vp.X + size.X + margin
	else
		xOn = margin
		xOff = -size.X - margin
	end
	const targetY = NAmanage.SideSwipe_GetPanelY(vp, size, margin)
	if opts.state == false then
		SideSwipeApp.panel.AnchorPoint = anchor
		SideSwipeApp.panel.Position = UDim2.new(0, xOff, 0, targetY)
	else
		SideSwipeApp.panel.AnchorPoint = anchor
		SideSwipeApp.panel.Position = UDim2.new(0, xOn, 0, targetY)
	end
end

NAmanage.SideSwipe_UpdateCanvas=function()
	if not (SideSwipeApp.scroll and SideSwipeApp.layout and SideSwipeApp.panel and SideSwipeApp.underlay) then return end
	const content = SideSwipeApp.layout.AbsoluteContentSize
	const totalH = content.Y + 16
	const cam = Services.Workspace.CurrentCamera
	const vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	const maxH = math.max(120, vp.Y - 40)
	const configuredHeight = math.clamp(math.floor((tonumber(NAStuff.SideSwipePanelHeight) or 0) + 0.5), 0, 1200)
	const autoHeight = math.min(totalH + 16, maxH)
	const height = configuredHeight > 0 and math.min(math.max(configuredHeight, 120), maxH) or autoHeight
	const width = math.clamp(tonumber(NAStuff.SideSwipeWidth) or 80, 60, 200)
	SideSwipeApp.panel.Size = UDim2.new(0, width, 0, height)
	SideSwipeApp.underlay.Size = UDim2.new(1, 0, 1, 0)
	SideSwipeApp.scroll.CanvasSize = UDim2.new(0, 0, 0, totalH)
	if not SideSwipeApp.animating then
		NAmanage.SideSwipe_PositionPanel({ state = SideSwipeApp.isOpen })
	end
end

NAmanage.SideSwipe_Rebuild=function(opts)
	opts = opts or {}
	NAmanage.MarkExternalLagProbe("sideswipe_rebuild_start")
	if not (SideSwipeApp.panel and SideSwipeApp.underlay) then return end
	SideSwipeApp.childIcons = NAmanage.ensureWeakTable(nil, "k")
	SideSwipeApp.childBacks = NAmanage.ensureWeakTable(nil, "k")
	SideSwipeApp.childDefs = NAmanage.ensureWeakTable(nil, "k")
	NAlib.disconnect("ss_button_active")
	if SideSwipeApp.scroll then SideSwipeApp.scroll:Destroy() end
	for _, c in SideSwipeApp.underlay:GetChildren() do
		const keep = c:IsA("UIStroke") or c:IsA("UICorner")
		if not keep then
			c:Destroy()
		end
	end
	SideSwipeApp.scroll = InstanceNew("ScrollingFrame", SideSwipeApp.underlay)
	SideSwipeApp.scroll.BackgroundTransparency = 1
	SideSwipeApp.scroll.BorderSizePixel = 0
	SideSwipeApp.scroll.Size = UDim2.new(1, 0, 1, 0)
	SideSwipeApp.scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	SideSwipeApp.scroll.ScrollBarThickness = math.clamp(math.floor((tonumber(NAStuff.SideSwipeScrollBarThickness) or 4) + 0.5), 0, 12)
	SideSwipeApp.scroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
	SideSwipeApp.scroll.Active = true
	const pad = InstanceNew("UIPadding", SideSwipeApp.scroll)
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	if SideSwipeApp.layout then SideSwipeApp.layout:Destroy() end
	const list = InstanceNew("UIListLayout", SideSwipeApp.scroll)
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.Padding = UDim.new(0, math.clamp(math.floor((tonumber(NAStuff.SideSwipeButtonSpacing) or 8) + 0.5), 0, 32))
	list.SortOrder = Enum.SortOrder.LayoutOrder
	SideSwipeApp.layout = list
	const tile = math.clamp(math.floor((tonumber(NAStuff.SideSwipeButtonHeight) or 48) + 0.5), 32, 96)
	const buttons = NAmanage.SideSwipe_GetButtons()
	for i, def in buttons do
		NAmanage.MarkExternalLagProbe("sideswipe_rebuild_button:"..tostring(def.name or i))
		const btn = InstanceNew("TextButton", SideSwipeApp.scroll)
		btn.Name = (def.name or ("btn"..i)).."Swipe"
		btn.Size = UDim2.new(1, -6, 0, tile)
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.LayoutOrder = i
		btn.Text = ""
		btn.TextTransparency = 1
		btn.AutoButtonColor = false
		btn.ZIndex = 520
		const bg = InstanceNew("Frame", btn)
		bg.ZIndex = 518
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(25,25,28)
		bg.BackgroundTransparency = NAStuff.SideSwipeButtonTransparency or 0.16
		bg.BorderSizePixel = 0
		const cr = InstanceNew("UICorner", bg)
		cr.CornerRadius = UDim.new(0, 6)
		const stroke = InstanceNew("UIStroke", bg)
		stroke.Thickness = 1
		stroke.Color = NAUISTROKER or Color3.fromRGB(148,93,255)
		stroke.Transparency = 0.15
		NAgui.RegisterColoredStroke(stroke)
		const ic = InstanceNew("TextLabel", bg)
		ic.ZIndex = 519
		ic.BackgroundTransparency = 1
		ic.Size = UDim2.new(0.65, 0, 0.65, 0)
		ic.Position = UDim2.new(0.5, 0, 0.5, 0)
		ic.AnchorPoint = Vector2.new(0.5, 0.5)
		local iconFont = nil
		if opts.skipFont == true then
			iconFont = TopBarApp and TopBarApp.icon and TopBarApp.icon.FontFace or nil
		else
			iconFont = (NAmanage.SideSwipe_ButtonIconFont and NAmanage.SideSwipe_ButtonIconFont(false)) or (TopBarApp.icon and TopBarApp.icon.FontFace)
			if not iconFont then
				local okFont, fallbackFont = pcall(Font.new, "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				if okFont then
					iconFont = fallbackFont
				end
			end
		end
		if iconFont then
			ic.FontFace = iconFont
		else
			ic.Font = Enum.Font.GothamBold
		end
		ic.Text = def.icon or def.name or ""
		ic.TextColor3 = Color3.new(1,1,1)
		ic.TextScaled = false
		ic.TextSize = 24
		SideSwipeApp.childIcons[btn] = ic
		SideSwipeApp.childBacks[btn] = bg
		SideSwipeApp.childDefs[btn] = def
		if opts.skipWatch ~= true and NAmanage.SideSwipe_WatchButtonState then
			NAmanage.SideSwipe_WatchButtonState(def)
		end
		const function fireSideSwipeButton()
			if type(def.func) == "function" then
				def.func()
			end
			if NAmanage.SideSwipe_SyncButtonVisuals then
				NAmanage.SideSwipe_SyncButtonVisuals()
			end
		end
		MouseButtonFix(btn, fireSideSwipeButton)
	end
	const function update()
		NAmanage.SideSwipe_UpdateCanvas()
	end
	NAlib.disconnect("ss_canvas")
	NAlib.connect("ss_canvas", SideSwipeApp.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update))
	update()
	if opts.skipVisual ~= true and NAmanage.SideSwipe_UpdateButtonVisuals then
		NAmanage.SideSwipe_UpdateButtonVisuals()
	end
	NAmanage.MarkExternalLagProbe("sideswipe_rebuild_done")
end

NAmanage.SideSwipe_DeferActiveRefresh = NAmanage.SideSwipe_DeferActiveRefresh or function()
	if IsOnMobile == true then
		NAmanage.MarkExternalLagProbe("sideswipe_active_refresh_not_scheduled_mobile")
		return
	end
	Defer(function()
		Wait(0.75)
		if not (SideSwipeApp and SideSwipeApp.gui and SideSwipeApp.gui.Parent and SideSwipeApp.panel and type(SideSwipeApp.childDefs) == "table") then
			return
		end
		NAmanage.MarkExternalLagProbe("sideswipe_active_refresh_start")
		NAlib.disconnect("ss_button_active")
		for btn, def in SideSwipeApp.childDefs do
			NAmanage.MarkExternalLagProbe("sideswipe_active_watch:"..tostring(def and def.name or btn))
			if NAmanage.SideSwipe_WatchButtonState then
				NAmanage.SideSwipe_WatchButtonState(def)
			end
		end
		if NAmanage.SideSwipe_UpdateButtonVisuals then
			NAmanage.MarkExternalLagProbe("sideswipe_active_visuals_start")
			NAmanage.SideSwipe_UpdateButtonVisuals({ chunked = true })
			NAmanage.MarkExternalLagProbe("sideswipe_active_visuals_done")
		end
		NAmanage.MarkExternalLagProbe("sideswipe_active_refresh_done")
	end)
end

NAmanage.SideSwipe_SetOpen=function(state)
	if not SideSwipeApp.panel then return end
	if state == true and not SideSwipeApp.scroll and NAmanage.SideSwipe_Rebuild then
		NAmanage.SideSwipe_Rebuild(IsOnMobile == true and { skipWatch = true, skipVisual = true } or nil)
	end
	if SideSwipeApp.animating then return end
	const wasOpen = SideSwipeApp.isOpen
	SideSwipeApp.isOpen = state and true or false
	if SideSwipeApp.isOpen then
		SideSwipeApp.handlesHidden = true
	elseif wasOpen then
		SideSwipeApp.handlesHidden = true
	end
	NAmanage.SideSwipe_PositionHandles()
	SideSwipeApp.animating = true
	SideSwipeApp.panel.Visible = true
	NAmanage.SideSwipe_UpdateCanvas()
	const cam = Services.Workspace.CurrentCamera
	const vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	const size = SideSwipeApp.panel.AbsoluteSize
	const margin = 10
	const side = SideSwipeApp.side or "left"
	const anchor = side == "right" and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
	const xOn = side == "right" and (vp.X - margin) or margin
	const xOff = side == "right" and (vp.X + size.X + margin) or (-size.X - margin)
	const y = NAmanage.SideSwipe_GetPanelY(vp, size, margin)
	local startX = SideSwipeApp.isOpen and xOff or xOn
	if wasOpen == SideSwipeApp.isOpen then
		startX = SideSwipeApp.panel.Position.X.Offset
	end
	const targetX = SideSwipeApp.isOpen and xOn or xOff
	SideSwipeApp.panel.AnchorPoint = anchor
	SideSwipeApp.panel.Position = UDim2.new(0, startX, 0, y)
	const ease = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	const tween = __lt.cm("TweenService", "Create", SideSwipeApp.panel, ease, { Position = UDim2.new(0, targetX, 0, y) })
	if SideSwipeApp.underlay then
		const basePanelTransparency = math.clamp(tonumber(NAStuff.SideSwipePanelTransparency) or 0.35, 0, 1)
		const underGoal = SideSwipeApp.isOpen and math.max(0, basePanelTransparency - 0.27) or basePanelTransparency
		__lt.cm("TweenService", "Create", SideSwipeApp.underlay, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = underGoal }):Play()
	end
	tween:Play()
	local completedConn
	completedConn = tween.Completed:Connect(function()
		if completedConn then
			pcall(function() completedConn:Disconnect() end)
			completedConn = nil
		end
		if not SideSwipeApp.isOpen then
			SideSwipeApp.panel.Visible = false
			SideSwipeApp.handlesHidden = false
			NAmanage.SideSwipe_UpdateHandleSide()
		else
			SideSwipeApp.handlesHidden = true
			NAmanage.SideSwipe_PositionHandles()
		end
		SideSwipeApp.animating = false
	end)
end

NAmanage.SideSwipe_SetSide=function(side, opts)
	opts = opts or {}
	const resolved = side == "right" and "right" or "left"
	if SideSwipeApp.side == resolved and not opts.force then
		NAmanage.SideSwipe_UpdateHandleSide()
		return
	end
	SideSwipeApp.side = resolved
	NASideSwipeSide = resolved
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("sideSwipeSide", resolved)
	end
	NAmanage.SideSwipe_UpdateHandleSide()
	if opts.skipAnimate then
		NAmanage.SideSwipe_PositionPanel({ state = SideSwipeApp.isOpen })
	else
		NAmanage.SideSwipe_SetOpen(SideSwipeApp.isOpen)
	end
end

NAmanage.SideSwipe_WireHandle=function(btn, side)
	if not btn then return end
	const key=side=="right" and "ss_swipe_right" or "ss_swipe_left"
	NAlib.disconnect(key)
	local dragging=false
	local dragStart
	local dragInput

	const function resetDrag()
		dragging=false
		dragStart=nil
		dragInput=nil
	end

	NAlib.connect(key, btn.MouseButton1Down:Connect(function()
		NAmanage.SideSwipe_SetSide(side,{skipAnimate=true})
	end))

	NAlib.connect(key, btn.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			NAmanage.SideSwipe_SetSide(side,{skipAnimate=true})
			dragging=true
			dragStart=input.Position
			dragInput=input
			local endConn
			endConn=NAlib.connect(key, input.Changed:Connect(function()
				if input.UserInputState==Enum.UserInputState.End or input.UserInputState==Enum.UserInputState.Cancel then
					resetDrag()
					if endConn then
						endConn:Disconnect()
						endConn=nil
						if NAmanage and NAmanage.prnCon then
							NAmanage.prnCon(key)
						end
					end
				end
			end))
		end
	end))

	NAlib.connect(key, btn.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
			dragInput=input
		end
	end))

	NAlib.connect(key,Services.UserInputService.InputChanged:Connect(function(input)
		if input==dragInput and dragging and dragStart then
			const delta=input.Position-dragStart
			const swipeThreshold = math.clamp(math.floor((tonumber(NAStuff.SideSwipeSwipeThreshold) or 28) + 0.5), 8, 120)
			if side=="left" and delta.X>swipeThreshold then
				resetDrag()
				NAmanage.SideSwipe_SetOpen(true)
			elseif side=="right" and delta.X<-swipeThreshold then
				resetDrag()
				NAmanage.SideSwipe_SetOpen(true)
			elseif SideSwipeApp.isOpen then
				if side=="left" and delta.X<-swipeThreshold then
					resetDrag()
					NAmanage.SideSwipe_SetOpen(false)
				elseif side=="right" and delta.X>swipeThreshold then
					resetDrag()
					NAmanage.SideSwipe_SetOpen(false)
				end
			end
		end
	end))
end

NAmanage.SideSwipe_Init=function(opts)
	opts = opts or {}
	NAmanage.MarkExternalLagProbe("sideswipe_init_start")
	if SideSwipeApp.gui and SideSwipeApp.gui.Parent and opts.force ~= true then
		SideSwipeApp.gui.Visible = NASideSwipeEnabled
		if NAmanage.SideSwipe_PositionHandles then
			pcall(NAmanage.SideSwipe_PositionHandles)
		end
		NAmanage.MarkExternalLagProbe("sideswipe_init_skip_existing")
		return true
	end
	SideSwipeApp.gui = NAmanage.GetManagedUIRoot("SideSwipe", NASideSwipeEnabled, 950)
	if not SideSwipeApp.gui then return false end
	NAmanage.MarkExternalLagProbe("sideswipe_root_ready")
	for _, child in SideSwipeApp.gui:GetChildren() do
		child:Destroy()
	end
	const startupLite = type(NAmanage.IsStartupBuilding) == "function" and NAmanage.IsStartupBuilding()
	SideSwipeApp.gui.Visible = NASideSwipeEnabled
	SideSwipeApp.panel = InstanceNew("Frame", SideSwipeApp.gui)
	SideSwipeApp.panel.BackgroundTransparency = 1
	SideSwipeApp.panel.ClipsDescendants = true
	SideSwipeApp.panel.Visible = false
	SideSwipeApp.panel.ZIndex = 510
	SideSwipeApp.underlay = InstanceNew("Frame", SideSwipeApp.panel)
	SideSwipeApp.underlay.Size = UDim2.new(1,0,1,0)
	SideSwipeApp.underlay.BackgroundColor3 = Color3.fromRGB(18,18,22)
	SideSwipeApp.underlay.BackgroundTransparency = NAStuff.SideSwipePanelTransparency or 0.35
	SideSwipeApp.underlay.ZIndex = 511
	const uCorner = InstanceNew("UICorner", SideSwipeApp.underlay); uCorner.CornerRadius = UDim.new(0, 6)
	const uStroke = InstanceNew("UIStroke", SideSwipeApp.underlay)
	uStroke.Thickness = 1
	uStroke.Color = NAUISTROKER or Color3.fromRGB(148,93,255)
	uStroke.Transparency = 0.18
	NAgui.RegisterColoredStroke(uStroke)
	NAmanage.MarkExternalLagProbe("sideswipe_rebuild_call")
	NAmanage.SideSwipe_Rebuild(startupLite and { skipWatch = true, skipVisual = true, skipFont = IsOnMobile == true } or nil)
	const mainColor = NAUISTROKER or DEFAULT_UI_STROKE_COLOR or Color3.fromRGB(148,93,255)
	SideSwipeApp.handles.left = InstanceNew("TextButton", SideSwipeApp.gui)
	SideSwipeApp.handles.left.BackgroundColor3 = mainColor
	SideSwipeApp.handles.left.BackgroundTransparency = NAStuff.SideSwipeHandleTransparency or 0.72
	SideSwipeApp.handles.left.BorderSizePixel = 0
	SideSwipeApp.handles.left.AutoButtonColor = false
	SideSwipeApp.handles.left.Text = ""
	SideSwipeApp.handles.left.AnchorPoint = Vector2.new(0,0.5)
	SideSwipeApp.handles.left.ZIndex = 470
	const lCorner = InstanceNew("UICorner", SideSwipeApp.handles.left); lCorner.CornerRadius = UDim.new(0, 6)
	NAmanage.SideSwipe_WireHandle(SideSwipeApp.handles.left, "left")
	SideSwipeApp.handles.right = InstanceNew("TextButton", SideSwipeApp.gui)
	SideSwipeApp.handles.right.BackgroundColor3 = mainColor
	SideSwipeApp.handles.right.BackgroundTransparency = NAStuff.SideSwipeHandleTransparency or 0.72
	SideSwipeApp.handles.right.BorderSizePixel = 0
	SideSwipeApp.handles.right.AutoButtonColor = false
	SideSwipeApp.handles.right.Text = ""
	SideSwipeApp.handles.right.AnchorPoint = Vector2.new(1,0.5)
	SideSwipeApp.handles.right.ZIndex = 470
	const rCorner = InstanceNew("UICorner", SideSwipeApp.handles.right); rCorner.CornerRadius = UDim.new(0, 6)
	NAmanage.SideSwipe_WireHandle(SideSwipeApp.handles.right, "right")
	NAmanage.SideSwipe_UpdateHandleColors(mainColor)
	SideSwipeApp.side = NASideSwipeSide or SideSwipeApp.side
	NAmanage.SideSwipe_SetSide(SideSwipeApp.side, { skipAnimate = true, force = true })
	NAmanage.SideSwipe_PositionHandles()
	if Services.Workspace.CurrentCamera then
		NAlib.connect("ss_vp", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			NAmanage.SideSwipe_PositionHandles()
			NAmanage.SideSwipe_UpdateCanvas()
		end))
	end
	const function SideSwipe_HookOutsideClose()
		NAlib.disconnect("ss_click")

		const function onInputBegan(input)
			if not SideSwipeApp.isOpen then return end

			if input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			const pos = input.Position
			const p = typeof(pos) == "Vector2" and pos or Vector2.new(pos.X, pos.Y)

			if NAmanage.SideSwipe_ShouldCloseFrom(p) then
				NAmanage.SideSwipe_SetOpen(false)
			end
		end

		NAlib.connect("ss_click", Services.UserInputService.InputBegan:Connect(onInputBegan))
	end
	SideSwipe_HookOutsideClose()
	if startupLite and NAmanage.SideSwipe_DeferActiveRefresh then
		NAmanage.SideSwipe_DeferActiveRefresh()
	end
	NAmanage.MarkExternalLagProbe("sideswipe_init_done")
	return true
end

NAmanage.SideSwipe_Destroy=function()
	NAlib.disconnect("ss_canvas")
	NAlib.disconnect("ss_button_active")
	NAlib.disconnect("ss_vp")
	NAlib.disconnect("ss_click")
	NAlib.disconnect("ss_swipe_left")
	NAlib.disconnect("ss_swipe_right")
	if SideSwipeApp.gui then SideSwipeApp.gui:Destroy() end
	SideSwipeApp={ gui=nil; panel=nil; underlay=nil; scroll=nil; layout=nil; handles={left=nil,right=nil}; isOpen=false; animating=false; handlesHidden=false; side=NASideSwipeSide or "left" }
end

NAgui._menuCleanups = NAgui._menuCleanups or {}

NAgui._getMenuCleanupKey = NAgui._getMenuCleanupKey or function(menu)
	return "NAMenu_"..tostring((menu and menu.GetDebugId and menu:GetDebugId()) or menu)
end

NAgui.cleanupMenu = NAgui.cleanupMenu or function(menu)
	if not menu then return end
	const key = NAgui._getMenuCleanupKey(menu)
	const cleanup = NAgui._menuCleanups[key]
	if type(cleanup) == "function" then
		pcall(cleanup)
	end
	NAlib.disconnect(key)
end

NAgui._bindMenuCleanup = NAgui._bindMenuCleanup or function(menu)
	const key = NAgui._getMenuCleanupKey(menu)
	NAgui.cleanupMenu(menu)
	local cleaned = false
	const function cleanup()
		if cleaned then return end
		cleaned = true
		if NAgui._menuCleanups[key] == cleanup then
			NAgui._menuCleanups[key] = nil
		end
		NAlib.disconnect(key)
	end
	NAgui._menuCleanups[key] = cleanup
	if menu and menu.AncestryChanged then
		NAlib.connect(key, menu.AncestryChanged:Connect(function(_, parent)
			if not parent then
				Defer(cleanup)
			end
		end))
	end
	if menu and menu.Destroying then
		NAlib.connect(key, menu.Destroying:Connect(cleanup))
	end
	return key, cleanup
end

NAgui._menuCompleted = NAgui._menuCompleted or function(key, tween, callback)
	if not (key and tween and tween.Completed) then
		if type(callback) == "function" then
			callback()
		end
		return nil
	end
	local conn
	conn = NAlib.connect(key, tween.Completed:Connect(function()
		if conn then
			pcall(function() conn:Disconnect() end)
			conn = nil
		end
		if NAmanage and NAmanage.prnCon then
			NAmanage.prnCon(key)
		end
		if type(callback) == "function" then
			callback()
		end
	end))
	return conn
end

NAgui._bindMenuMaximize = function(menu, menuConnName, options)
	options = type(options) == "table" and options or {}
	const button = menu and menu:FindFirstChild("Maximize", true)
	if not (button and button:IsA("GuiButton")) then return nil end
	local maximized = NAmanage.GetAttr(menu, "NAMenuMaximized") == true
	local busy = false
	const geometryAttributes = {
		"NAMenuRestorePositionXScale";
		"NAMenuRestorePositionXOffset";
		"NAMenuRestorePositionYScale";
		"NAMenuRestorePositionYOffset";
		"NAMenuRestoreSizeXScale";
		"NAMenuRestoreSizeXOffset";
		"NAMenuRestoreSizeYScale";
		"NAMenuRestoreSizeYOffset";
	}

	const function setGlyph()
		pcall(function()
			const iconWeight = maximized and Enum.FontWeight.Bold or Enum.FontWeight.Regular
			button.FontFace = Font.new(BUILDER_ICON_FONT_PATH or "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", iconWeight, Enum.FontStyle.Normal)
			button.Text = "square-corner-line"
		end)
	end
	const function saveRestoreGeometry()
		const position = menu.Position
		const size = menu.Size
		const values = {
			position.X.Scale; position.X.Offset; position.Y.Scale; position.Y.Offset;
			size.X.Scale; size.X.Offset; size.Y.Scale; size.Y.Offset;
		}
		for index, attribute in geometryAttributes do
			NAmanage.SetAttr(menu, attribute, values[index])
		end
	end
	const function getRestoreGeometry()
		const values = {}
		for index, attribute in geometryAttributes do
			values[index] = tonumber(NAmanage.GetAttr(menu, attribute))
			if values[index] == nil then return nil, nil end
		end
		return UDim2.new(values[1], values[2], values[3], values[4]), UDim2.new(values[5], values[6], values[7], values[8])
	end
	const function getScale()
		if type(options.getScale) == "function" then
			local ok, value = pcall(options.getScale)
			if ok and tonumber(value) and tonumber(value) > 0 then return tonumber(value) end
		end
		local value = NAUIMANAGER and NAUIMANAGER.AUTOSCALER and tonumber(NAUIMANAGER.AUTOSCALER.Scale) or 1
		return value and value > 0 and value or 1
	end
	const function getMaximizedGeometry()
		local absolute = menu.Parent and menu.Parent.AbsoluteSize
		if not absolute or absolute.X <= 0 or absolute.Y <= 0 then
			absolute = Services.Workspace and Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		end
		const scale = getScale()
		const pad = 10
		const width = math.max(240, math.floor((absolute.X / scale) - (pad * 2) + 0.5))
		const height = math.max(120, math.floor((absolute.Y / scale) - (pad * 2) + 0.5))
		return UDim2.fromOffset(pad, pad), UDim2.fromOffset(width, height)
	end
	const function isBusy()
		if busy then return true end
		if type(options.isBusy) == "function" then
			local ok, value = pcall(options.isBusy)
			if ok and value == true then return true end
		end
		return false
	end
	const function setBusy(value)
		busy = value == true
		if type(options.setBusy) == "function" then pcall(options.setBusy, busy) end
	end
	const function applyMaximizedGeometry()
		if not maximized or not menu.Parent then return end
		local position, size = getMaximizedGeometry()
		menu.Position = position
		menu.Size = size
	end
	const function toggleMaximize()
		if isBusy() then return end
		const nextState = not maximized
		if nextState then
			if type(options.prepareMaximize) == "function" then pcall(options.prepareMaximize) end
			saveRestoreGeometry()
		end
		local targetPosition, targetSize
		if nextState then
			targetPosition, targetSize = getMaximizedGeometry()
		else
			targetPosition, targetSize = getRestoreGeometry()
			if not (targetPosition and targetSize) then return end
		end
		maximized = nextState
		NAmanage.SetAttr(menu, "NAMenuMaximized", maximized)
		setGlyph()
		setBusy(true)
		NAgui._menuCompleted(menuConnName, NAgui.tween(menu, "Quart", "Out", 0.35, {
			Position = targetPosition;
			Size = targetSize;
		}), function()
			setBusy(false)
			if type(options.onComplete) == "function" then pcall(options.onComplete, maximized) end
		end)
	end

	if maximized then
		local restorePosition, restoreSize = getRestoreGeometry()
		if restorePosition and restoreSize then
			applyMaximizedGeometry()
		else
			maximized = false
			NAmanage.SetAttr(menu, "NAMenuMaximized", false)
		end
	end
	setGlyph()
	NAlib.connect(menuConnName, MouseButtonFix(button, toggleMaximize))
	if menu.Parent and menu.Parent.GetPropertyChangedSignal then
		NAlib.connect(menuConnName, menu.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if maximized and not isBusy() then applyMaximizedGeometry() end
		end))
	end
	return {
		Toggle = toggleMaximize;
		IsMaximized = function() return maximized end;
	}
end

NAgui.menu = function(menu)
	if not menu then return end
	const menuConnName = NAgui._bindMenuCleanup(menu)
	if menu:IsA("Frame") then menu.AnchorPoint = Vector2.new(0, 0) end
	pcall(function()
		if menu:IsA("GuiObject") then
			menu.ClipsDescendants = true
		end
	end)
	const exitButton = menu:FindFirstChild("Exit", true)
	const minimizeButton = menu:FindFirstChild("Minimize", true)
	local minimized = false
	local isAnimating = false
	const sizeXAttr = "NAMenuStoredSizeX"
	const sizeYAttr = "NAMenuStoredSizeY"
	const function setStoredSize(x, y)
		if menu and menu.SetAttribute then
			NAmanage.SetAttr(menu, sizeXAttr, tonumber(x) or 0)
			NAmanage.SetAttr(menu, sizeYAttr, tonumber(y) or 0)
		end
	end
	const function getStoredSize()
		local storedX, storedY
		if menu and menu.GetAttribute then
			storedX = tonumber(NAmanage.GetAttr(menu, sizeXAttr))
			storedY = tonumber(NAmanage.GetAttr(menu, sizeYAttr))
		end
		storedX = storedX or menu.Size.X.Offset
		storedY = storedY or menu.Size.Y.Offset
		return math.max(1, storedX), math.max(1, storedY)
	end
	const function getScale()
		local s = (NAUIMANAGER and NAUIMANAGER.AUTOSCALER and tonumber(NAUIMANAGER.AUTOSCALER.Scale)) or 1
		if not s or s <= 0 then
			s = 1
		end
		return s
	end
	const function getMenuSize()
		local x = tonumber(menu.Size.X.Offset) or 0
		local y = tonumber(menu.Size.Y.Offset) or 0
		if x <= 0 or y <= 0 then
			const s = getScale()
			const abs = menu.AbsoluteSize
			if x <= 0 then
				x = math.floor(((abs and abs.X) or 1) / s + 0.5)
			end
			if y <= 0 then
				y = math.floor(((abs and abs.Y) or 1) / s + 0.5)
			end
		end
		return math.max(1, x), math.max(1, y)
	end
	const function getMiniHeight()
		if menu.Name == "ServerList" then return 35 end
		local h = 35
		const top = menu:FindFirstChild("Topbar")
		if top and top:IsA("GuiObject") then
			const y = tonumber(top.Size.Y.Offset) or 0
			if y > 0 then
				h = y
			elseif top.AbsoluteSize and top.AbsoluteSize.Y > 0 then
				h = math.floor((top.AbsoluteSize.Y / getScale()) + 0.5)
			end
		end
		return math.max(30, h)
	end
	const function setBodyVisible(value)
		const body = menu:FindFirstChild("Container")
		if body and body:IsA("GuiObject") then
			body.Visible = value == true
		end
	end
	const minimizedConstraintSizes = {}
	const function setMinimizeConstraints(value)
		for _, child in menu:GetChildren() do
			if child:IsA("UISizeConstraint") then
				if value == true then
					if minimizedConstraintSizes[child] == nil then
						minimizedConstraintSizes[child] = child.MinSize
					end
					const original = minimizedConstraintSizes[child]
					child.MinSize = Vector2.new(original.X, math.min(original.Y, getMiniHeight()))
				elseif minimizedConstraintSizes[child] ~= nil then
					child.MinSize = minimizedConstraintSizes[child]
					minimizedConstraintSizes[child] = nil
				end
			end
		end
	end
	const function setMinAtt(value)
		minimized = value
		if menu and menu.SetAttribute then
			NAmanage.SetAttr(menu, "NAMenuMinimized", value)
		end
	end
	setMinAtt(false)
	setBodyVisible(true)

	const function toggleMinimize()
		if isAnimating then return end
		const nextState = not minimized
		setMinAtt(nextState)
		isAnimating = true

		if nextState then
			local currentX, currentY = getMenuSize()
			setStoredSize(currentX, currentY)
			setMinimizeConstraints(true)
			if NAgui._setHeavyResizeSuspended then
				NAgui._setHeavyResizeSuspended(menu, true)
			end
			setBodyVisible(false)
			NAgui._menuCompleted(menuConnName, NAgui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, currentX, 0, getMiniHeight())}), function()
					isAnimating = false
					if NAmanage.Commands_IsFrame and NAmanage.Commands_IsFrame(menu) and NAmanage.Commands_SyncHiddenState then
						NAmanage.Commands_SyncHiddenState({ responsive = false; syncRows = false })
					end
					if NAgui._setHeavyResizeSuspended then
						NAgui._setHeavyResizeSuspended(menu, false)
					end
				end)
		else
			local restoreX, restoreY = getStoredSize()
			setMinimizeConstraints(false)
			setBodyVisible(false)
			NAgui._menuCompleted(menuConnName, NAgui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, restoreX, 0, restoreY)}), function()
					isAnimating = false
					setBodyVisible(true)
					if NAmanage.Commands_IsFrame and NAmanage.Commands_IsFrame(menu) and NAmanage.Commands_SyncHiddenState then
						NAmanage.Commands_SyncHiddenState({ center = false; syncRows = true })
					end
					if menu == (NAUIMANAGER and NAUIMANAGER.SettingsFrame) and NAUIMANAGER.SettingsList then
						Defer(function()
							updateCanvasSize(NAUIMANAGER.SettingsList, NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
						end)
					end
				end)
		end
	end
	NAgui._bindMenuMaximize(menu, menuConnName, {
		isBusy = function() return isAnimating end;
		setBusy = function(value) isAnimating = value == true end;
		getScale = getScale;
		prepareMaximize = function()
			if minimized then
				local restoreX, restoreY = getStoredSize()
				setMinimizeConstraints(false)
				menu.Size = UDim2.fromOffset(restoreX, restoreY)
				setMinAtt(false)
			end
			setBodyVisible(true)
		end;
		onComplete = function()
			setBodyVisible(true)
		end;
	})

	NAlib.connect(menuConnName, MouseButtonFix(minimizeButton, toggleMinimize))
	NAlib.connect(menuConnName, MouseButtonFix(exitButton, function()
		menu.Visible = false
	end))
	NAgui.draggerV2(menu, menu.Topbar)
	menu.Visible = false
end

NAgui.menuv2 = function(menu)
	if not menu then return end
	const menuConnName = NAgui._bindMenuCleanup(menu)
	NACaller(function()
		if menu:IsA("Frame") then
			menu.AnchorPoint = Vector2.new(0, 0)
		end
	end)

	const exitButton = menu:FindFirstChild("Exit", true)
	const minimizeButton = menu:FindFirstChild("Minimize", true)
	const clearButton = menu:FindFirstChild("Clear", true)

	local minimized = false
	local isAnimating = false
	const isNAChat = menu == (NAUIMANAGER and NAUIMANAGER.NAchatFrame) or menu.Name == "NAChatUI"
	const compactMinimize = isNAChat or menu == (NAUIMANAGER and NAUIMANAGER.chatLogsFrame) or menu.Name == "ChatLogs"
	const sizeXAttr = "NAMenuStoredSizeX"
	const sizeYAttr = "NAMenuStoredSizeY"
	const function setStoredSize(x, y)
		if menu and menu.SetAttribute then
			NAmanage.SetAttr(menu, sizeXAttr, tonumber(x) or 0)
			NAmanage.SetAttr(menu, sizeYAttr, tonumber(y) or 0)
		end
	end
	const function getStoredSize()
		local storedX, storedY
		if menu and menu.GetAttribute then
			storedX = tonumber(NAmanage.GetAttr(menu, sizeXAttr))
			storedY = tonumber(NAmanage.GetAttr(menu, sizeYAttr))
		end
		storedX = storedX or menu.Size.X.Offset
		storedY = storedY or menu.Size.Y.Offset
		return storedX, storedY
	end
	const minimizedConstraintSizes = {}
	const compactTopbarState = {}
	const compactBodyState = {}
	const function getMiniHeight()
		if isNAChat then
			const topbar = menu:FindFirstChild("Topbar")
			if topbar and topbar:IsA("GuiObject") then
				const offset = tonumber(topbar.Size.Y.Offset) or 0
				if offset > 0 then
					return math.max(30, offset)
				end
			end
			return 40
		end
		return 35
	end
	const function setBodyVisible(value)
		if not compactMinimize then return end
		if isNAChat then
			if value == true then
				for item, wasVisible in compactBodyState do
					if typeof(item) == "Instance" and item:IsA("GuiObject") and item.Parent == menu then
						item.Visible = wasVisible == true
					end
					compactBodyState[item] = nil
				end
			else
				const topbar = menu:FindFirstChild("Topbar")
				for _, item in menu:GetChildren() do
					if item ~= topbar and item:IsA("GuiObject") then
						if compactBodyState[item] == nil then
							compactBodyState[item] = item.Visible
						end
						item.Visible = false
					end
				end
			end
			return
		end
		const body = menu:FindFirstChild("Container")
		if body and body:IsA("GuiObject") then body.Visible = value == true end
	end
	const function setCompactTopbar(value)
		if not compactMinimize then return end
		const topbar = menu:FindFirstChild("Topbar")
		if not (topbar and topbar:IsA("GuiObject")) then return end
		if value == true then
			if compactTopbarState.size == nil then compactTopbarState.size = topbar.Size end
			topbar.Size = UDim2.new(topbar.Size.X.Scale, topbar.Size.X.Offset, 0, getMiniHeight())
			for _, name in {"Translate", "TranslateInput", "Clear", "ToolsBar", "HeaderAccent", "HeaderDivider"} do
				const item = topbar:FindFirstChild(name)
				if item and item:IsA("GuiObject") then
					if compactTopbarState[item] == nil then compactTopbarState[item] = item.Visible end
					item.Visible = false
				end
			end
		else
			if compactTopbarState.size ~= nil then
				topbar.Size = compactTopbarState.size
				compactTopbarState.size = nil
			end
			for item, wasVisible in compactTopbarState do
				if typeof(item) == "Instance" and item:IsA("GuiObject") and item.Parent then item.Visible = wasVisible == true end
				compactTopbarState[item] = nil
			end
		end
	end
	const function setMinimizeConstraints(value)
		if not compactMinimize then return end
		for _, child in menu:GetChildren() do
			if child:IsA("UISizeConstraint") then
				if value == true then
					if minimizedConstraintSizes[child] == nil then minimizedConstraintSizes[child] = { min = child.MinSize; max = child.MaxSize } end
					const original = minimizedConstraintSizes[child]
					const h = getMiniHeight()
					child.MinSize = Vector2.new(original.min.X, h)
					child.MaxSize = Vector2.new(original.max.X, h)
				else
					const original = minimizedConstraintSizes[child]
					if original then child.MinSize = original.min child.MaxSize = original.max minimizedConstraintSizes[child] = nil end
				end
			end
		end
	end
	const function setMinAtt(value)
		minimized = value
		if menu and menu.SetAttribute then
			NAmanage.SetAttr(menu, "NAMenuMinimized", value)
		end
	end
	setMinAtt(false)

	const function toggleMinimize()
		local success, err = NACaller(function()
			if isAnimating then return end
			const nextState = not minimized
			setMinAtt(nextState)
			isAnimating = true

			if nextState then
				const currentX = menu.Size.X.Offset
				const currentY = menu.Size.Y.Offset
				setStoredSize(currentX, currentY)
				setMinimizeConstraints(true)
				setCompactTopbar(true)
				setBodyVisible(false)
				menu.ClipsDescendants = true
				NAgui._menuCompleted(menuConnName, NAgui.tween(menu, "Quart", "Out", 0.5, {
					Size = UDim2.new(0, currentX, 0, getMiniHeight())
				}), function()
					menu.Size = UDim2.new(0, currentX, 0, getMiniHeight())
					setMinimizeConstraints(true)
					setCompactTopbar(true)
					isAnimating = false
				end)
			else
				local restoreX, restoreY = getStoredSize()
				setMinimizeConstraints(false)
				setCompactTopbar(false)
				setBodyVisible(false)
				NAgui._menuCompleted(menuConnName, NAgui.tween(menu, "Quart", "Out", 0.5, {
					Size = UDim2.new(0, restoreX, 0, restoreY)
				}), function()
					isAnimating = false
					setCompactTopbar(false)
					setBodyVisible(true)
				end)
			end
		end)
		if not success then warn("menuv2 toggleMinimize error:", err) end
	end

	NAgui._bindMenuMaximize(menu, menuConnName, {
		isBusy = function() return isAnimating end;
		setBusy = function(value) isAnimating = value == true end;
		prepareMaximize = function()
			if minimized then
				local restoreX, restoreY = getStoredSize()
				setMinimizeConstraints(false)
				setCompactTopbar(false)
				menu.Size = UDim2.fromOffset(restoreX, restoreY)
				setMinAtt(false)
			end
			setCompactTopbar(false)
			setBodyVisible(true)
		end;
	})

	NACaller(function()
		NAlib.connect(menuConnName, MouseButtonFix(minimizeButton, toggleMinimize))
	end)

	NACaller(function()
		NAlib.connect(menuConnName, MouseButtonFix(exitButton, function()
			local ok, err = NACaller(function()
				menu.Visible = false
			end)
			if not ok then warn("menuv2 exit button error:", err) end
		end))
	end)

	if clearButton then
		NACaller(function()
			clearButton.Visible = true
			NAlib.connect(menuConnName, MouseButtonFix(clearButton, function()
				local ok, err = NACaller(function()
					const customHandlers = NAmanage and NAmanage._menuClearHandlers
					const customClear = customHandlers and customHandlers[menu]
					if type(customClear) == "function" then
						customClear()
						return
					end
					const container = menu:FindFirstChild("Container", true)
					if container then
						const scrollingFrame = container:FindFirstChildOfClass("ScrollingFrame")
						if scrollingFrame then
							const layout = scrollingFrame:FindFirstChildOfClass("UIListLayout", true)
							if layout then
								for _, v in layout.Parent:GetChildren() do
									if v:IsA("TextLabel") then
										v:Destroy()
									end
								end
							end
						end
					end
				end)
				if not ok then warn("menuv2 clear button error:", err) end
			end))
		end)
	end

	const chatTranslator = NAStuff.ChatTranslator
	if translateButton and chatTranslator and type(chatTranslator.registerButton) == "function" then
		NACaller(function()
			chatTranslator:registerButton(translateButton)
		end)
	end

	NACaller(function()
		NAgui.draggerV2(menu, menu.Topbar)
	end)

	NACaller(function()
		menu.Visible = false
	end)
end

NAgui.menuv3 = function(menu)
	if not menu then return end
	NAgui.menuv2(menu)
	const translator = NAStuff.ChatTranslator
	const translateButton = menu:FindFirstChild("Translate", true)
	const translateInput = menu:FindFirstChild("TranslateInput", true)

	if translator and type(translator.attachControls) == "function" then
		translator:attachControls(translateButton, translateInput)
		const menuConnName = NAgui._getMenuCleanupKey(menu)
		NAlib.connect(menuConnName, {
			Connected = true,
			Disconnect = function(self)
				self.Connected = false
				if translator.button == translateButton then
					translator._buttonConn = NAmanage.tryDisconnect(translator._buttonConn)
					translator.button = nil
				end
				if translator.input == translateInput then
					translator._inputConn = NAmanage.tryDisconnect(translator._inputConn)
					translator.input = nil
				end
			end
		})
	elseif translator and type(translator.tryAttach) == "function" then
		Defer(function()
			if type(translator.tryAttach) == "function" then
				translator:tryAttach()
			end
		end)
	end
end

NAmanage.setCmdAutofillItemInteractivity = function(frame, enabled)
	if not (frame and frame.Parent and frame:IsA("GuiObject")) then
		return
	end
	const isEnabled = enabled == true
	pcall(function()
		frame.Active = isEnabled
	end)
	pcall(function()
		frame.Selectable = isEnabled
	end)
	if frame:IsA("GuiButton") then
		pcall(function()
			frame.AutoButtonColor = isEnabled
		end)
	end

	const inputObj = frame:FindFirstChild("Input")
	if inputObj and inputObj:IsA("GuiObject") then
		pcall(function()
			inputObj.Active = isEnabled
		end)
		pcall(function()
			inputObj.Selectable = isEnabled
		end)
		if inputObj:IsA("GuiButton") then
			pcall(function()
				inputObj.AutoButtonColor = isEnabled
			end)
		end
	end
end

NAgui.hideFill = function()
	NAStuff.cmdAutofillVisibleCount = 0
	for i = 1, #prevVisible do
		const v = prevVisible[i]
		if v and v.Parent and v:IsA("GuiObject") then
			v.Visible = false
		end
	end
	table.clear(prevVisible)
	const pool = NAStuff and NAStuff.CmdAutofillPool
	if type(pool) == "table" then
		for i = 1, #pool do
			const frame = pool[i]
			if frame and frame.Parent and frame:IsA("GuiObject") then
				frame.Visible = false
				NAmanage.setCmdAutofillItemInteractivity(frame, false)
			end
		end
	end
	const host = NAUIMANAGER and NAUIMANAGER.cmdAutofill
	if host then
		for _, child in host:GetChildren() do
			if child:IsA("GuiObject") then
				child.Visible = false
				NAmanage.setCmdAutofillItemInteractivity(child, false)
			end
		end
		if not (NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI()) then
			host.Visible = false
		end
	end
end

NAmanage.IsCmdAutofillHidden = function()
	return type(NAStuff) == "table" and NAStuff.HideCmdAutofill == true
end

NAmanage.ApplyCmdAutofillVisibility = function(opts)
	opts = type(opts) == "table" and opts or {}
	const hidden = NAmanage.IsCmdAutofillHidden()
	const host = NAUIMANAGER and NAUIMANAGER.cmdAutofill
	if host and host:IsA("GuiObject") then
		const active = NAmanage.isCmdBarActive and NAmanage.isCmdBarActive() == true
		const legacy = NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() == true
		host.Visible = not hidden and (legacy or active)
	end
	if hidden then
		NAgui.hideFill()
		NAmanage.setCmdAutofillClickable(false)
	elseif NAmanage.isCmdBarActive and NAmanage.isCmdBarActive() then
		NAmanage.setCmdAutofillClickable(true)
		if opts.refresh == false then
			return
		end
		Delay(0, function()
			if type(NAgui.autoFILLLL) == "function" then
				NAgui.autoFILLLL()
			end
		end)
	end
end

NAmanage.SetCmdAutofillHidden = function(hidden, opts)
	opts = type(opts) == "table" and opts or {}
	NAStuff.HideCmdAutofill = hidden == true
	if opts.save ~= false and type(NAmanage.NASettingsSet) == "function" then
		pcall(NAmanage.NASettingsSet, "hideCmdAutofill", NAStuff.HideCmdAutofill)
	end
	NAmanage.ApplyCmdAutofillVisibility({ refresh = opts.refresh ~= false })
	if opts.notify == true then
		DoNotif("Command autofill list "..(NAStuff.HideCmdAutofill and "hidden" or "shown"), 2)
	end
	return NAStuff.HideCmdAutofill
end

NAmanage.isCmdBarActive = function()
	if NAStuff and NAStuff.cmdBarSelected == true then
		return true
	end
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	local ok, focused = pcall(function()
		return box:IsFocused()
	end)
	return ok and focused == true
end

NAmanage.setCmdAutofillClickable = function(enabled)
	const isEnabled = enabled == true and not (NAmanage.IsCmdAutofillHidden and NAmanage.IsCmdAutofillHidden())
	NAStuff.cmdAutofillClickable = isEnabled

	for i = 1, #prevVisible do
		NAmanage.setCmdAutofillItemInteractivity(prevVisible[i], isEnabled)
	end
end

NAmanage.applyCmdAutofillFill = function(frame)
	if NAmanage.IsCmdAutofillHidden and NAmanage.IsCmdAutofillHidden() then
		return
	end
	if not NAStuff.cmdAutofillClickable or not NAStuff.cmdBarSelected then
		return
	end
	if not (frame and NAUIMANAGER and NAUIMANAGER.cmdInput) then
		return
	end
	if NAStuff.defaultCmdClear == nil then
		NAStuff.defaultCmdClear = NAUIMANAGER.cmdInput.ClearTextOnFocus
	end
	local raw = (NAmanage.GetAttr and NAmanage.GetAttr(frame, "NA_FillText")) or ""
	if raw == "" then
		const inputObj = frame:FindFirstChild("Input")
		raw = (inputObj and inputObj.Text) or frame.Text or ""
	end
	const cmdText = NAUIMANAGER.cmdInput.Text or ""
	const ctx = NAmanage.getCmdAutofillContext and NAmanage.getCmdAutofillContext(cmdText) or nil
	local sanitizedText
	if NAmanage.composeCmdAutofillText then
		sanitizedText = NAmanage.composeCmdAutofillText(ctx, raw)
	else
		sanitizedText = NAmanage.stripChar(raw)
	end
	sanitizedText = NAmanage.stripChar(sanitizedText)
	NAStuff.lastCmdAutofillCompletion = sanitizedText
	Defer(function()
		if IsOnMobile then
			NAStuff.cmdFocusGuardUntil = os.clock() + 0.45
			NAStuff.autofillRefocusGuard = os.clock() + 0.25
		else
			NAStuff.cmdFocusGuardUntil = 0
			NAStuff.autofillRefocusGuard = 0
		end
		NAUIMANAGER.cmdInput.Text = sanitizedText
		const caret = #sanitizedText + 1
		NAUIMANAGER.cmdInput.CursorPosition = caret
		if NAUIMANAGER.cmdInput.ClearTextOnFocus ~= false then
			NAUIMANAGER.cmdInput.ClearTextOnFocus = false
		end
		if NAUIMANAGER.cmdInput.SelectionStart then
			pcall(function()
				NAUIMANAGER.cmdInput.SelectionStart = caret
				NAUIMANAGER.cmdInput.SelectionEnd = caret
			end)
		end
		if predictionInput then
			predictionInput.Text = ""
		end
		if NAmanage.CmdInputUseSoftFocus and NAmanage.CmdInputUseSoftFocus() then
			NAmanage.CmdSoftInputStart()
			NAStuff.autofillSelecting = false
		elseif not IsOnMobile then
			NAgui.ensureCmdFocus(true)
			NAStuff.autofillSelecting = false
		else
			NAStuff.autofillSelecting = true
			NAUIMANAGER.cmdInput:ReleaseFocus()
			Delay(0.2, function()
				if NAUIMANAGER and NAUIMANAGER.cmdInput then
					NAUIMANAGER.cmdInput:CaptureFocus()
					NAUIMANAGER.cmdInput.ClearTextOnFocus = NAStuff.defaultCmdClear or false
				end
				NAStuff.autofillRefocusGuard = 0
				NAStuff.autofillSelecting = false
			end)
		end
		if IsOnMobile then
			Delay(0.5, function()
				NAStuff.cmdFocusGuardUntil = 0
				NAStuff.autofillRefocusGuard = 0
			end)
		end
	end)
end

NAmanage.bindCmdAutofillFrame = function(frame)
	if not frame or NAmanage.GetAttr(frame, "NA_AutofillBound") == true then
		return
	end

	const function bind(obj)
		if not obj then
			return
		end
		if obj:IsA("TextButton") or obj:IsA("ImageButton") then
			obj.MouseButton1Click:Connect(function()
				NAmanage.applyCmdAutofillFill(frame)
			end)
		end
		if obj.InputBegan then
			obj.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					NAmanage.applyCmdAutofillFill(frame)
				end
			end)
		end
	end

	bind(frame)
	const inputObj = frame:FindFirstChild("Input")
	bind(inputObj)
	local visual = frame:FindFirstChild("Background")
	visual = visual and visual:FindFirstChild("Horizontal")
	const outline = visual and visual:FindFirstChild("ItemOutline")
	const line = visual and visual:FindFirstChild("SelectionLine")
	const function applyHover(hovered)
		if NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() then
			return
		end
		const active = hovered == true and NAStuff.cmdAutofillClickable == true and NAStuff.cmdBarSelected == true
		if visual then
			NAgui.tween(visual, "Sine", "Out", 0.12, {
				BackgroundColor3 = active and Color3.fromRGB(38, 38, 43) or Color3.fromRGB(24, 24, 27);
				BackgroundTransparency = active and 0.08 or 0.2;
			})
		end
		if outline then
			NAgui.tween(outline, "Sine", "Out", 0.12, {
				Transparency = active and 0.28 or 0.76;
			})
		end
		if line then
			NAgui.tween(line, "Sine", "Out", 0.12, {
				BackgroundTransparency = active and 0.05 or 0.42;
			})
		end
	end
	if inputObj and inputObj.MouseEnter then
		inputObj.MouseEnter:Connect(function() applyHover(true) end)
		inputObj.MouseLeave:Connect(function() applyHover(false) end)
	end
	NAmanage.SetAttr(frame, "NA_AutofillBound", true)
end

NAmanage.ensureCmdAutofillSuggestionPool = function(requiredCount)
	requiredCount = math.max(5, tonumber(requiredCount) or 5)
	const host = NAUIMANAGER and NAUIMANAGER.cmdAutofill
	const template = NAUIMANAGER and NAUIMANAGER.cmdExample
	if not (host and template) then
		return {}
	end

	local pool = NAStuff.CmdAutofillPool
	if type(pool) ~= "table" then
		pool = {}
		NAStuff.CmdAutofillPool = pool
	end

	if NAStuff.CmdAutofillPoolInitialized ~= true then
		for _, child in host:GetChildren() do
			if child:IsA("GuiObject") and child ~= template and not child:IsA("UIListLayout") then
				child:Destroy()
			end
		end
		table.clear(pool)
		NAStuff.CmdAutofillPoolInitialized = true
	end

	for i = 1, requiredCount do
		local frame = pool[i]
		if not (frame and frame.Parent) then
			frame = template:Clone()
			frame.Visible = false
			frame.Parent = host
			pool[i] = frame
			NAmanage.bindCmdAutofillFrame(frame)
		end
		frame.LayoutOrder = i
	end

	for i = requiredCount + 1, #pool do
		const frame = pool[i]
		if frame then
			frame.Visible = false
			frame.LayoutOrder = i
		end
	end

	CMDAUTOFILL = pool
	return pool
end

NAmanage.applyCmdAutofillEntryToFrame = function(frame, entry)
	if not (frame and entry) then
		return
	end

	const meta = entry.meta or {}
	const name = entry.name or frame.Name
	local finalDisplay = meta.displayText or entry.display or name
	const isPatched = meta.patched == true
	const isCmdIntegration = meta.origin == "cmd"
	const isIYIntegration = meta.origin == "iy"
	const isPluginCmd = meta.pluginType ~= nil
	const inputObj = frame:FindFirstChild("Input")
	const defaultInputColor = NAStuff.defaultCmdAutofillInputColor

	if inputObj then
		if isPatched then
			inputObj.TextColor3 = patchedCommandColor
			finalDisplay = NAgui.addPatchedLabel(finalDisplay)
		elseif isCmdIntegration then
			inputObj.TextColor3 = cmdIntegrationColor
		elseif isIYIntegration then
			inputObj.TextColor3 = iyIntegrationColor
		elseif isPluginCmd then
			inputObj.TextColor3 = pluginCommandColor
		elseif defaultInputColor then
			inputObj.TextColor3 = defaultInputColor
		end
		inputObj.Text = finalDisplay
	else
		frame.Text = finalDisplay
	end

	frame.Name = tostring(name)
	NAmanage.SetAttr(frame, "NA_FillText", tostring(name))
	NAmanage.SetAttr(frame, "IsCmdIntegration", isCmdIntegration)
	NAmanage.SetAttr(frame, "IsIYIntegration", isIYIntegration)
	NAmanage.SetAttr(frame, "IsPluginCommand", isPluginCmd)
	NAmanage.SetAttr(frame, "IsPatchedCommand", isPatched)
end

NAgui.loadCMDS = function(opts)
	opts = opts or {}
	local targetSignature = opts.signature
	if targetSignature == nil and type(NAmanage.getCommandBuildSignature) == "function" then
		targetSignature = NAmanage.getCommandBuildSignature()
	end
	const cachedEntries = NAStuff.AutofillEntries
	if not opts.force
		and type(cachedEntries) == "table"
		and targetSignature ~= nil
		and targetSignature == NAStuff.CommandBuildSignatureApplied then
		cmdNAnum = NAmanage.totalCommandCount and NAmanage.totalCommandCount() or #cachedEntries
		return cachedEntries
	end
	if NAStuff.cmdAutofillLoading == true then
		NAStuff.cmdAutofillLoadRequested = true
		return cachedEntries
	end
	NAStuff.cmdAutofillLoadRequested = false
	NAStuff.cmdAutofillLoading = true
	NAmanage.setCmdAutofillClickable(false)
	table.clear(prevVisible)
	NAmanage.ensureCmdAutofillSuggestionPool(5)
	local layout = NAStuff.cmdAutofillLayout
	if not (layout and layout.Parent == NAUIMANAGER.cmdAutofill) then
		layout = NAUIMANAGER.cmdAutofill and NAUIMANAGER.cmdAutofill:FindFirstChildOfClass("UIListLayout")
		NAStuff.cmdAutofillLayout = layout
	end
	if layout then
		layout.SortOrder = Enum.SortOrder.LayoutOrder
	end
	const templateInput = NAUIMANAGER.cmdExample and NAUIMANAGER.cmdExample:FindFirstChild("Input")
	NAStuff.defaultCmdAutofillInputColor = templateInput and templateInput.TextColor3
	NAStuff.defaultCmdClear = nil
	NAStuff.autofillSelecting = false
	NAStuff.cmdFocusGuardUntil = 0
	NAStuff.autofillRefocusGuard = 0
	local okBuild, packageOrErr = pcall(function()
		const package = NAmanage.buildCommandDataPackage and NAmanage.buildCommandDataPackage() or nil
		if type(package) == "table" and type(NAmanage.applyCommandDataPackage) == "function" then
			NAmanage.applyCommandDataPackage(package)
		end
		return package
	end)
	if not okBuild then
		NAStuff.cmdAutofillLoading = false
		warn("[NA] Command build failed:", packageOrErr)
		return cachedEntries
	end
	const package = packageOrErr
	const entries = NAStuff.AutofillEntries or {}
	const pool = NAmanage.ensureCmdAutofillSuggestionPool(5)
	for i = 1, #pool do
		const btn = pool[i]
		if btn then
			btn.Visible = false
			NAmanage.setCmdAutofillItemInteractivity(btn, false)
		end
	end
	NAmanage.setCmdAutofillClickable(NAStuff.cmdBarSelected == true)
	NAgui.hideFill()
	NAStuff.cmdAutofillLoading = false
	if NAUIMANAGER and NAUIMANAGER.commandsFrame and NAUIMANAGER.commandsFrame.Visible and type(NAgui.filterCommandList) == "function" then
		if NAUIMANAGER and NAUIMANAGER.commandsFilter then
			NAgui.filterCommandList(NAUIMANAGER.commandsFilter.Text)
		end
	end
	if type(NAgui.autoFILLLL) == "function" then
		const box = NAUIMANAGER and NAUIMANAGER.cmdInput
		if box then
			local focused = false
			pcall(function()
				focused = box:IsFocused()
			end)
			if focused or NAmanage.isCmdBarActive() then
				NAgui.autoFILLLL()
			else
				NAgui.hideFill()
			end
		end
	end
	if NAStuff.cmdAutofillLoadRequested == true then
		NAStuff.cmdAutofillLoadRequested = false
		if type(NAgui.loadCMDS) == "function" then
			local ok, err = pcall(NAgui.loadCMDS, { force = true })
			if not ok then
				warn("[NA] Queued command rebuild failed:", err)
			end
		end
	end
	return entries
end

NAmanage.queueCommandDataBuild = NAmanage.queueCommandDataBuild or function(opts)
	opts = opts or {}
	local signature = opts.signature
	if signature == nil and type(NAmanage.getCommandBuildSignature) == "function" then
		signature = NAmanage.getCommandBuildSignature()
	end
	if not opts.force
		and signature ~= nil
		and signature == NAStuff.CommandBuildSignatureApplied
		and type(NAStuff.AutofillEntries) == "table" then
		return false
	end
	if NAStuff.cmdAutofillLoading == true or NAStuff.CommandBuildWorkerQueued == true then
		NAStuff.cmdAutofillLoadRequested = true
		return false
	end
	NAStuff.CommandBuildWorkerQueued = true
	local ok, err = pcall(NAgui.loadCMDS, {
		force = opts.force,
		signature = signature,
		background = false,
	})
	NAStuff.CommandBuildWorkerQueued = false
	if not ok then
		warn("[NA] Command rebuild failed:", err)
		return false
	end
	return true
end

SpawnCall(function() -- plugin tester
	NAStuff._pluginTesterLoop = true
	local waitTime = 2
	local stableStreak = 0
	while NAStuff._pluginTesterLoop do
		Wait(waitTime)
		if NAmanage.isLoad and NAmanage.isLoad() then
			waitTime = 4
			stableStreak = 0
		elseif not (NAUIMANAGER and NAUIMANAGER.cmdAutofill and NAUIMANAGER.cmdAutofill.Parent) then
			waitTime = math.min(8, waitTime + 1)
		else
			if NAStuff.cmdAutofillLoading ~= true
				and type(NAmanage.isCommandDataStale) == "function"
				and NAmanage.isCommandDataStale() then
				local ok, err = pcall(function()
					if type(NAmanage.queueCommandDataBuild) == "function" then
						return NAmanage.queueCommandDataBuild()
					end
					return NAgui.loadCMDS({ force = true })
				end)
				if not ok then
					warn("[NA] Command refresh loop failed:", err)
				end
				waitTime = 2
				stableStreak = 0
			else
				stableStreak = math.min(stableStreak + 1, 20)
				waitTime = math.min(12, 2 + stableStreak * 0.5)
			end
		end
	end
end)

if NAmanage.pulseLoadingUI then
	NAmanage.pulseLoadingUI("initializing topbar and edge swipe gesture", 0.985)
end

SpawnCall(function()
	if NAmanage.Topbar_Init then
		if not (TopBarApp and TopBarApp.top and TopBarApp.top.Parent) then
			pcall(NAmanage.Topbar_Init)
		elseif NAmanage.Topbar_ClampToggle then
			pcall(NAmanage.Topbar_ClampToggle)
		end
	end
end)

SpawnCall(function()
	Wait(0.25)
	if NAmanage.SideSwipe_Init then
		if not (SideSwipeApp and SideSwipeApp.gui and SideSwipeApp.gui.Parent) then
			pcall(NAmanage.SideSwipe_Init)
		elseif NAmanage.SideSwipe_PositionHandles then
			pcall(NAmanage.SideSwipe_PositionHandles)
		end
	end
end)

cmdDefaultClear = nil
NAStuff.cmdInputSoftFocus = false
NAStuff.cmdInputSoftSelectAll = false
NAStuff.cmdInputSoftPrevTextEditable = nil
NAStuff.cmdInputSoftSinkBound = false
NAStuff.cmdInputSoftSelectionAnchor = nil
NAStuff.cmdInputSoftVisualBound = false
NAStuff.cmdInputSoftOutsideBound = false
NAStuff.cmdInputSoftCaretBlinkToken = 0
NAStuff.cmdInputSoftRepeatToken = 0
NAStuff.cmdInputSoftRepeatKey = nil
NAStuff.cmdInputSoftRepeatInput = nil
NAStuff.cmdInputSoftCursor = nil

NAmanage.CmdInputUseSoftFocus = function()
	return type(NAStuff) == "table" and NAStuff.CmdInputSafeMode ~= false
end

if type(NAStuff.CmdInputSafeMode) ~= "boolean" then
	NAStuff.CmdInputSafeMode = IsOnPC == true and IsOnMobile ~= true
end
NAStuff.MobileCmdSafeInput = NAStuff.CmdInputSafeMode ~= false
NAStuff.cmdMobileKeyboardShift = NAStuff.cmdMobileKeyboardShift == true
NAStuff.cmdMobileSelectMode = NAStuff.cmdMobileSelectMode == true

NAmanage.CmdInputGetCursor = function(box, fallback)
	box = box or (NAUIMANAGER and NAUIMANAGER.cmdInput)
	if not box then
		return 1
	end
	const text = tostring(box.Text or "")
	const len = #text
	const active = NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive()
	local cursor = nil
	if active then
		cursor = tonumber(NAStuff.cmdInputSoftCursor)
	end
	cursor = cursor or tonumber(fallback)
	if not cursor then
		pcall(function()
			cursor = tonumber(box.CursorPosition)
		end)
	end
	cursor = math.clamp(tonumber(cursor) or (len + 1), 1, len + 1)
	if active then
		NAStuff.cmdInputSoftCursor = cursor
	end
	return cursor
end

NAmanage.CmdInputActualFocused = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	local ok, focused = pcall(function()
		return box:IsFocused()
	end)
	return ok and focused == true
end

NAmanage.isCmdSoftInputActive = function()
	return NAStuff and NAStuff.cmdInputSoftFocus == true and NAStuff.cmdBarSelected == true
end

NAmanage.isAnyNAInputActive = function()
	if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
		return true
	end
	if NAmanage.CmdInputActualFocused and NAmanage.CmdInputActualFocused() then
		return true
	end
	if Services.UserInputService and Services.UserInputService.GetFocusedTextBox then
		local ok, focusedBox = pcall(function()
			return __lt.cm("UserInputService", "GetFocusedTextBox")
		end)
		if ok and focusedBox then
			return true
		end
	end
	return false
end


NAmanage.CmdInputStopKeyRepeat = function()
	if type(NAStuff) ~= "table" then
		return
	end
	NAStuff.cmdInputSoftRepeatToken = (tonumber(NAStuff.cmdInputSoftRepeatToken) or 0) + 1
	NAStuff.cmdInputSoftRepeatKey = nil
	NAStuff.cmdInputSoftRepeatInput = nil
end

NAmanage.CmdInputStartKeyRepeat = function(keyCode, callback, opts)
	if type(NAStuff) ~= "table" or type(callback) ~= "function" then
		return false
	end
	opts = type(opts) == "table" and opts or {}
	NAmanage.CmdInputStopKeyRepeat()
	NAStuff.cmdInputSoftRepeatToken = (tonumber(NAStuff.cmdInputSoftRepeatToken) or 0) + 1
	const token = NAStuff.cmdInputSoftRepeatToken
	NAStuff.cmdInputSoftRepeatKey = keyCode
	NAStuff.cmdInputSoftRepeatInput = opts.input
	const delayTime = tonumber(opts.delay) or 0.34
	const interval = tonumber(opts.interval) or 0.045
	Spawn(function()
		Wait(delayTime)
		while type(NAStuff) == "table"
			and NAStuff.cmdInputSoftRepeatToken == token
			and NAmanage.isCmdSoftInputActive
			and NAmanage.isCmdSoftInputActive() do
			local keepGoing = true
			if keyCode ~= nil then
				local ok, isDown = pcall(function()
					return Services.UserInputService:IsKeyDown(keyCode)
				end)
				keepGoing = ok and isDown == true
			end
			if not keepGoing then
				break
			end
			const ok = pcall(callback)
			if not ok then
				break
			end
			if type(NAgui) == "table" and type(NAgui.autoFILLLL) == "function" then
				Delay(0, NAgui.autoFILLLL)
			end
			Wait(interval)
		end
		if type(NAStuff) == "table" and NAStuff.cmdInputSoftRepeatToken == token then
			NAmanage.CmdInputStopKeyRepeat()
		end
	end)
	return true
end

NAmanage.CmdInputGetSoftSinkInputs = function()
	if type(NAStuff.cmdInputSoftSinkInputs) == "table" then
		return NAStuff.cmdInputSoftSinkInputs
	end
	const inputs = {}
	const seen = {}
	const function add(value)
		if value == nil or seen[value] then
			return
		end
		seen[value] = true
		inputs[#inputs + 1] = value
	end
	pcall(function()
		for _, keyCode in Enum.KeyCode:GetEnumItems() do
			if keyCode ~= Enum.KeyCode.Unknown then
				add(keyCode)
			end
		end
	end)
	add(Enum.UserInputType.Keyboard)
	NAStuff.cmdInputSoftSinkInputs = inputs
	return inputs
end

NAmanage.CmdInputBindSoftSink = function(enabled)
	if not Services.ContextActionService then
		return
	end
	const priority = 2147483647
	const chunkSize = 45
	local actions = NAStuff.cmdInputSoftSinkActions
	const function sinkInput(_, state, input)
		if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end
	const function unbindAll()
		if type(actions) == "table" then
			for _, rec in actions do
				if type(rec) == "table" and type(rec.name) == "string" then
					if rec.core == true and type(Services.ContextActionService.UnbindCoreAction) == "function" then
						pcall(function()
							Services.ContextActionService:UnbindCoreAction(rec.name)
						end)
					else
						pcall(function()
							Services.ContextActionService:UnbindAction(rec.name)
						end)
					end
				end
			end
		end
		pcall(function() Services.ContextActionService:UnbindAction("NA_CMD_SOFT_INPUT_SINK") end)
		if type(Services.ContextActionService.UnbindCoreAction) == "function" then
			pcall(function() Services.ContextActionService:UnbindCoreAction("NA_CMD_SOFT_INPUT_CORE_SINK") end)
		end
		NAStuff.cmdInputSoftSinkActions = {}
		NAStuff.cmdInputSoftSinkBound = false
	end
	if not enabled then
		unbindAll()
		return
	end
	if NAStuff.cmdInputSoftSinkBound then
		return
	end
	unbindAll()
	actions = {}
	const inputs = (NAmanage.CmdInputGetSoftSinkInputs and NAmanage.CmdInputGetSoftSinkInputs()) or { Enum.UserInputType.Keyboard }
	const function bindChunks(methodName, prefix, isCore)
		const fn = Services.ContextActionService[methodName]
		if type(fn) ~= "function" then
			return
		end
		local idx = 1
		for startIndex = 1, #inputs, chunkSize do
			const actionName = prefix..tostring(idx)
			const args = { actionName, sinkInput, false, priority }
			for j = startIndex, math.min(#inputs, startIndex + chunkSize - 1) do
				args[#args + 1] = inputs[j]
			end
			const ok = pcall(function()
				fn(Services.ContextActionService, table.unpack(args))
			end)
			if ok then
				actions[#actions + 1] = { name = actionName, core = isCore == true }
			end
			idx += 1
		end
	end
	bindChunks("BindActionAtPriority", "NA_CMD_SOFT_INPUT_SINK_", false)
	bindChunks("BindCoreActionAtPriority", "NA_CMD_SOFT_INPUT_CORE_SINK_", true)
	NAStuff.cmdInputSoftSinkActions = actions
	NAStuff.cmdInputSoftSinkBound = #actions > 0
end

NAgui.CmdMobileKeyboardHide = function()
	const gui = NAStuff and NAStuff.cmdMobileKeyboardGui
	if gui and gui.Parent then
		pcall(function()
			gui.Enabled = false
		end)
	end
	NAStuff.cmdMobileKeyboardVisible = false
end

NAgui.CmdMobileKeyboardGetRows = function()
	const mode = (NAStuff and NAStuff.cmdMobileKeyboardMode) or "abc"
	const shift = NAStuff and NAStuff.cmdMobileKeyboardShift == true
	const function key(label, action, value, weight)
		return { label = label, action = action or "char", value = value or label, weight = tonumber(weight) or 1 }
	end
	const function charRow(str)
		const out = {}
		for c in str:gmatch(".") do
			local label = c
			if shift and c:match("%a") then
				label = c:upper()
			end
			out[#out + 1] = key(label, "char", c, 1)
		end
		return out
	end
	const function spacer(weight)
		return { label = "", action = "spacer", value = nil, weight = tonumber(weight) or 1 }
	end
	const function dims()
		local viewY = 720
		pcall(function()
			const cam = Services.Workspace and Services.Workspace.CurrentCamera
			if cam then
				viewY = cam.ViewportSize.Y
			end
		end)
		const rowH = math.clamp(math.floor(viewY * 0.041), 28, 34)
		const bottomH = math.clamp(math.floor(viewY * 0.045), 30, 38)
		return rowH, bottomH
	end
	local rowH, bottomH = dims()

	if mode == "sym" then
		return {
			{ h = rowH, keys = { key("1"), key("2"), key("3"), key("4"), key("5"), key("6"), key("7"), key("8"), key("9"), key("0") } },
			{ h = rowH, keys = { key("@"), key("#"), key("$"), key("_"), key("&"), key("-"), key("+"), key("("), key(")"), key("/") } },
			{ h = rowH, keys = { key("=<", "mode", "more", 1.15), key("*"), key('"'), key("'"), key(":"), key(";"), key("!"), key("?"), key("Back", "back", nil, 1.3) } },
			{ h = bottomH, keys = { key("ABC", "mode", "abc", 1.2), key(",", "char", ",", 0.8), key("12/34", "mode", "more", 1.05), key("Space", "space", nil, 4.35), key(".", "char", ".", 0.8), key("Enter", "enter", nil, 1.25) } },
		}
	elseif mode == "more" then
		return {
			{ h = rowH, keys = { key("~"), key("`"), key("|"), key("\\"), key("<"), key(">"), key("="), key("["), key("]") } },
			{ h = rowH, keys = { key("{") , key("}"), key("^") , key("%"), key("&"), key("-"), key("+"), key("("), key(")") } },
			{ h = rowH, keys = { key("?123", "mode", "sym", 1.15), key("*"), key('"'), key("'"), key(":"), key(";"), key("!"), key("?"), key("Back", "back", nil, 1.3) } },
			{ h = bottomH, keys = { key("ABC", "mode", "abc", 1.2), key(",", "char", ",", 0.8), key("123", "mode", "num", 1.0), key("Space", "space", nil, 4.45), key(".", "char", ".", 0.8), key("Enter", "enter", nil, 1.25) } },
		}
	elseif mode == "num" then
		return {
			{ h = rowH, keys = { key("1", "char", "1", 1.5), key("2", "char", "2", 1.5), key("3", "char", "3", 1.5), key("+", "char", "+", 0.9), key("-", "char", "-", 0.9) } },
			{ h = rowH, keys = { key("4", "char", "4", 1.5), key("5", "char", "5", 1.5), key("6", "char", "6", 1.5), key("*", "char", "*", 0.9), key("/", "char", "/", 0.9) } },
			{ h = rowH, keys = { key("7", "char", "7", 1.5), key("8", "char", "8", 1.5), key("9", "char", "9", 1.5), key("=", "char", "=", 0.9), key("Back", "back", nil, 1.15) } },
			{ h = bottomH, keys = { key("ABC", "mode", "abc", 1.15), key(",", "char", ",", 0.75), key("?123", "mode", "sym", 1.05), key("0", "char", "0", 1.5), key(".", "char", ".", 0.75), key("Enter", "enter", nil, 1.2) } },
		}
	end

	return {
		{ h = rowH, keys = charRow("1234567890") },
		{ h = rowH, keys = charRow("qwertyuiop") },
		{ h = rowH, keys = (function()
			const r = { spacer(0.52) }
			for _, item in charRow("asdfghjkl") do
				r[#r + 1] = item
			end
			r[#r + 1] = spacer(0.52)
			return r
		end)() },
		{ h = rowH, keys = (function()
			const r = { key("Shift", "shift", nil, 1.25) }
			for _, item in charRow("zxcvbnm") do
				r[#r + 1] = item
			end
			r[#r + 1] = key("Back", "back", nil, 1.35)
			return r
		end)() },
		{ h = bottomH, keys = { key("?123", "mode", "sym", 1.25), key(",", "char", ",", 0.75), key("Space", "space", nil, 4.4), key(".", "char", ".", 0.75), key("Enter", "enter", nil, 1.25) } },
	}
end
NAgui.CmdMobileKeyboardRefresh = function()
	const root = NAStuff and NAStuff.cmdMobileKeyboardFrame
	if not root then
		return
	end
	if NAgui.CmdMobileKeyboardBuild then
		NAgui.CmdMobileKeyboardBuild(root)
	end
end

NAgui.CmdMobileKeyboardShow = function()
	if not IsOnMobile or NAStuff.MobileCmdSafeInput == false then
		return false
	end
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end

	const function moveMobileCursor(delta, selecting)
		const text = tostring(box.Text or "")
		const current = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (#text + 1), 1, #text + 1)
		const newPos = math.clamp(current + (tonumber(delta) or 0), 1, #text + 1)
		if selecting then
			if tonumber(NAStuff.cmdInputSoftSelectionAnchor) == nil then
				NAStuff.cmdInputSoftSelectionAnchor = current
			end
			NAStuff.cmdInputSoftSelectAll = false
			NAmanage.CmdInputSetCursor(box, newPos, true)
		else
			NAmanage.CmdInputSetCursor(box, newPos, false)
		end
	end

	const function press(action, value)
		action = tostring(action or "")
		if action == "char" then
			local ch = tostring(value or "")
			if #ch == 1 and ch:match("%a") and NAStuff.cmdMobileKeyboardShift then
				ch = ch:upper()
			end
			NAmanage.CmdInputInsertText(ch)
		elseif action == "space" then
			NAmanage.CmdInputInsertText(" ")
		elseif action == "back" then
			NAmanage.CmdInputDeleteBack()
		elseif action == "clear" then
			box.Text = ""
			NAmanage.CmdInputClearSoftSelection(false)
			NAmanage.CmdInputSetCursor(box, 1)
		elseif action == "tab" then
			NAmanage.CmdInputApplyPrediction()
		elseif action == "enter" then
			NAmanage.CmdInputSubmit()
		elseif action == "close" then
			NAgui.barDeselect(0.18)
		elseif action == "left" then
			moveMobileCursor(-1, NAStuff.cmdMobileSelectMode == true)
		elseif action == "right" then
			moveMobileCursor(1, NAStuff.cmdMobileSelectMode == true)
		elseif action == "select" then
			NAStuff.cmdMobileSelectMode = not NAStuff.cmdMobileSelectMode
			if NAStuff.cmdMobileSelectMode then
				NAStuff.cmdInputSoftSelectionAnchor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (#(box.Text or "") + 1), 1, #(box.Text or "") + 1)
				NAStuff.cmdInputSoftSelectAll = false
			else
				NAmanage.CmdInputClearSoftSelection(false)
			end
			if NAmanage.CmdInputUpdateSoftVisual then
				NAmanage.CmdInputUpdateSoftVisual()
			end
		elseif action == "selectall" then
			NAStuff.cmdMobileSelectMode = false
			NAStuff.cmdInputSoftSelectAll = true
			NAStuff.cmdInputSoftSelectionAnchor = 1
			NAmanage.CmdInputSetCursor(box, #(box.Text or "") + 1, true)
		elseif action == "copy" then
			NAmanage.CmdInputCopySelection()
		elseif action == "paste" then
			NAmanage.CmdInputPasteClipboard()
		elseif action == "cut" then
			NAmanage.CmdInputCutSelection()
		elseif action == "undo" then
			if NAmanage.CmdInputUndo then NAmanage.CmdInputUndo() end
		elseif action == "redo" then
			if NAmanage.CmdInputRedo then NAmanage.CmdInputRedo() end
		elseif action == "shift" then
			NAStuff.cmdMobileKeyboardShift = not NAStuff.cmdMobileKeyboardShift
			if NAgui.CmdMobileKeyboardRefresh then
				NAgui.CmdMobileKeyboardRefresh()
			end
		elseif action == "mode" then
			NAStuff.cmdMobileKeyboardMode = tostring(value or "abc")
			if NAStuff.cmdMobileKeyboardMode ~= "sym" and NAStuff.cmdMobileKeyboardMode ~= "num" and NAStuff.cmdMobileKeyboardMode ~= "more" then
				NAStuff.cmdMobileKeyboardMode = "abc"
			end
			if NAgui.CmdMobileKeyboardRefresh then
				NAgui.CmdMobileKeyboardRefresh()
			end
		end
		if type(NAgui.autoFILLLL) == "function" and action ~= "enter" and action ~= "close" and action ~= "mode" and action ~= "shift" and action ~= "left" and action ~= "right" and action ~= "select" and action ~= "selectall" and action ~= "copy" and action ~= "paste" and action ~= "cut" and action ~= "undo" and action ~= "redo" then
			Delay(0, NAgui.autoFILLLL)
		end
	end

	const function makeButton(parent, spec, rootZ)
		const action = tostring(spec.action or "char")
		const b = InstanceNew("TextButton")
		b.Name = "\0"
		b.AutoButtonColor = action ~= "spacer"
		b.Text = tostring(spec.label or "")
		b.TextScaled = false
		b.TextColor3 = Color3.fromRGB(248, 248, 252)
		b.Font = Enum.Font.GothamMedium
		local viewY = 720
		pcall(function()
			const cam = Services.Workspace and Services.Workspace.CurrentCamera
			if cam then
				viewY = cam.ViewportSize.Y
			end
		end)
		b.TextSize = math.clamp(math.floor(viewY * 0.029), 17, 23)
		b.BackgroundColor3 = Color3.fromRGB(64, 64, 70)
		b.BackgroundTransparency = 0.18
		b.BorderSizePixel = 0
		b.ZIndex = rootZ + 2
		b.LayoutOrder = #parent:GetChildren() + 1
		b:SetAttribute("NA_Weight", tonumber(spec.weight) or 1)
		if action == "spacer" then
			b.Text = ""
			b.Active = false
			b.Selectable = false
			b.AutoButtonColor = false
			b.BackgroundTransparency = 1
		elseif action == "left" or action == "right" or action == "select" or action == "selectall" or action == "copy" or action == "paste" or action == "cut" or action == "undo" or action == "redo" then
			b.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
			b.BackgroundTransparency = 0.08
			b.TextSize = math.clamp(math.floor(viewY * 0.019), 12, 16)
		elseif action == "shift" or action == "mode" or action == "back" then
			b.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
			b.BackgroundTransparency = 0.08
			b.TextSize = math.clamp(math.floor(viewY * 0.022), 13, 18)
		elseif action == "enter" then
			b.BackgroundColor3 = Color3.fromRGB(84, 148, 255)
			b.BackgroundTransparency = 0
			b.TextSize = math.clamp(math.floor(viewY * 0.022), 13, 18)
		elseif action == "space" then
			b.BackgroundColor3 = Color3.fromRGB(88, 88, 92)
			b.TextSize = math.clamp(math.floor(viewY * 0.018), 11, 15)
		end
		b.Parent = parent
		const bc = InstanceNew("UICorner")
		bc.CornerRadius = UDim.new(0, 6)
		bc.Parent = b
		if action ~= "spacer" then
			const function cb()
				press(action, spec.value)
			end
			if action == "back" or action == "left" or action == "right" then
				local down = false
				b.InputBegan:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end
					down = true
					cb()
					if NAmanage.CmdInputStartKeyRepeat then
						NAmanage.CmdInputStartKeyRepeat(nil, function()
							if down then
								cb()
							end
						end, { delay = 0.34, interval = 0.045 })
					end
				end)
				b.InputEnded:Connect(function(input)
					if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
						return
					end
					down = false
					if NAmanage.CmdInputStopKeyRepeat then
						NAmanage.CmdInputStopKeyRepeat()
					end
				end)
			elseif b.Activated then
				b.Activated:Connect(cb)
			elseif type(MouseButtonFix) == "function" then
				MouseButtonFix(b, cb)
			else
				b.MouseButton1Click:Connect(cb)
			end
		end
		return b
	end


	const function getMobileToolbarRows()
		const function toolkey(label, action, value, weight)
			return { label = label, action = action or "char", value = value or label, weight = tonumber(weight) or 1 }
		end
		local viewY = 720
		pcall(function()
			const cam = Services.Workspace and Services.Workspace.CurrentCamera
			if cam then
				viewY = cam.ViewportSize.Y
			end
		end)
		const toolbarH = math.clamp(math.floor(viewY * 0.04), 28, 34)
		return {
			{ h = toolbarH, toolbar = true, keys = {
				toolkey("Undo", "undo", nil, 0.8),
				toolkey("Redo", "redo", nil, 0.8),
				toolkey("Left", "left", nil, 0.75),
				toolkey("Right", "right", nil, 0.75),
				toolkey("Select", "select", nil, 0.95),
				toolkey("All", "selectall", nil, 0.7),
				toolkey("Copy", "copy", nil, 0.8),
				toolkey("Paste", "paste", nil, 0.9),
				toolkey("Cut", "cut", nil, 0.7),
			} }
		}
	end

	NAgui.CmdMobileKeyboardBuild = function(root)
		if not root then
			return
		end
		for _, child in root:GetChildren() do
			if not child:IsA("UIPadding") then
				child:Destroy()
			end
		end
		const rootZ = root.ZIndex or 1
		const rows = {}
		const toolbarRows = getMobileToolbarRows()
		for _, row in toolbarRows or {} do
			rows[#rows + 1] = row
		end
		for _, row in (NAgui.CmdMobileKeyboardGetRows and NAgui.CmdMobileKeyboardGetRows()) or {} do
			rows[#rows + 1] = row
		end
		local y = 0
		for rowIndex, rowData in rows do
			const h = tonumber(rowData.h) or 48
			const r = InstanceNew("Frame")
			r.Name = "\0"
			r.BackgroundTransparency = 1
			r.BorderSizePixel = 0
			r.Position = UDim2.new(0, 0, 0, y)
			r.Size = UDim2.new(1, 0, 0, h)
			r.LayoutOrder = rowIndex
			r.ZIndex = rootZ + 1
			r.Parent = root
			const layout = InstanceNew("UIListLayout")
			layout.FillDirection = Enum.FillDirection.Horizontal
			layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			layout.VerticalAlignment = Enum.VerticalAlignment.Center
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Padding = UDim.new(0, 2)
			layout.Parent = r
			local total = 0
			for _, spec in rowData.keys or {} do
				total += tonumber(spec.weight) or 1
			end
			for _, spec in rowData.keys or {} do
				const weight = tonumber(spec.weight) or 1
				const b = makeButton(r, spec, rootZ)
				b.Size = UDim2.new(weight / math.max(total, 1), -2, 1, -2)
			end
			y += h + 2
		end
		const finalHeight = math.max(0, y - 2) + 5
		pcall(function()
			root.Size = UDim2.new(0.94, 0, 0, finalHeight)
		end)
	end

	local gui = NAStuff.cmdMobileKeyboardGui
	if not (gui and gui.Parent) then
		gui = InstanceNew("ScreenGui")
		pcall(function()
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
			gui.DisplayOrder = 2147483647
		end)
		NAgui.NaProtectUI(gui)
		NAStuff.cmdMobileKeyboardGui = gui

		const root = InstanceNew("Frame")
		root.Name = "\0"
		root.AnchorPoint = Vector2.new(0.5, 1)
		root.Position = UDim2.new(0.5, 0, 1, -4)
		root.Size = UDim2.new(0.94, 0, 0, 210)
		root.BackgroundTransparency = 1
		root.BorderSizePixel = 0
		root.ZIndex = 2147483600
		root.Parent = gui
		NAStuff.cmdMobileKeyboardFrame = root

		const padding = InstanceNew("UIPadding")
		padding.PaddingTop = UDim.new(0, 2)
		padding.PaddingBottom = UDim.new(0, 2)
		padding.PaddingLeft = UDim.new(0, 2)
		padding.PaddingRight = UDim.new(0, 2)
		padding.Parent = root
	end

	if NAStuff.cmdMobileKeyboardMode == nil then
		NAStuff.cmdMobileKeyboardMode = "abc"
	end
	gui.Enabled = true
	NAStuff.cmdMobileKeyboardVisible = true
	NAgui.CmdMobileKeyboardRefresh()
	return true
end

NAmanage.GuiPointInside = NAmanage.GuiPointInside or function(obj, pos)
	if not (obj and obj.Parent and obj:IsA("GuiObject") and pos) then
		return false
	end
	const x = tonumber(pos.X) or 0
	const y = tonumber(pos.Y) or 0
	const p = obj.AbsolutePosition
	const s = obj.AbsoluteSize
	return x >= p.X and y >= p.Y and x <= (p.X + s.X) and y <= (p.Y + s.Y)
end

NAmanage.CmdInputPointInsideSafeArea = function(pos)
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if NAmanage.GuiPointInside(box, pos) then
		return true
	end
	const overlay = NAStuff and NAStuff.cmdInputSoftOverlay
	if NAmanage.GuiPointInside(overlay, pos) then
		return true
	end
	const keyboard = NAStuff and NAStuff.cmdMobileKeyboardFrame
	if NAmanage.GuiPointInside(keyboard, pos) then
		return true
	end
	const autofill = NAUIMANAGER and NAUIMANAGER.cmdAutofill
	if autofill and autofill.Visible and NAmanage.GuiPointInside(autofill, pos) then
		return true
	end
	const centerBar = NAUIMANAGER and NAUIMANAGER.centerBar
	if centerBar and centerBar.Visible and NAmanage.GuiPointInside(centerBar, pos) then
		return true
	end
	return false
end

NAmanage.CmdInputClearSoftSelection = function(updateVisual)
	NAStuff.cmdInputSoftSelectAll = false
	NAStuff.cmdInputSoftSelectionAnchor = nil
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if box then
		pcall(function()
			box.SelectionStart = -1
		end)
	end
	if updateVisual ~= false and NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
end

NAmanage.CmdInputGetSelectionRange = function(box)
	box = box or (NAUIMANAGER and NAUIMANAGER.cmdInput)
	if not box then
		return nil, nil
	end
	const text = tostring(box.Text or "")
	const len = #text
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (len + 1), 1, len + 1)
	if NAStuff.cmdInputSoftSelectAll == true then
		return 1, len + 1
	end
	local anchor = tonumber(NAStuff.cmdInputSoftSelectionAnchor)
	if not anchor then
		return nil, nil
	end
	anchor = math.clamp(anchor, 1, len + 1)
	if anchor == cursor then
		return nil, nil
	end
	return math.min(anchor, cursor), math.max(anchor, cursor)
end

NAmanage.CmdInputDeleteSelection = function(box, recordUndo)
	box = box or (NAUIMANAGER and NAUIMANAGER.cmdInput)
	if not box then
		return false
	end
	local s, e = NAmanage.CmdInputGetSelectionRange(box)
	if not s then
		return false
	end
	const text = tostring(box.Text or "")
	if recordUndo ~= false and NAmanage.CmdInputPushUndo then
		NAmanage.CmdInputPushUndo(box)
	end
	box.Text = text:sub(1, s - 1)..text:sub(e)
	NAmanage.CmdInputClearSoftSelection(false)
	NAmanage.CmdInputSetCursor(box, s, false)
	return true
end

NAmanage.CmdInputMeasureTextWidth = function(box, value)
	if not box then
		return 0
	end
	value = tostring(value or "")
	if value == "" then
		return 0
	end
	local service = nil
	pcall(function()
		service = __lt.cloneref and __lt.cloneref(game:GetService("TextService")) or game:GetService("TextService")
	end)
	if service and service.GetTextSize then
		local ok, size = pcall(function()
			return service:GetTextSize(value, math.max(1, tonumber(box.TextSize) or 14), box.Font, Vector2.new(100000, math.max(1, box.AbsoluteSize.Y)))
		end)
		if ok and size then
			return tonumber(size.X) or 0
		end
	end
	return #value * math.max(7, (tonumber(box.TextSize) or 14) * 0.55)
end

NAmanage.CmdInputEnsureSoftVisual = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	const overlay = NAStuff and NAStuff.cmdInputSoftOverlay
	if not (box and box.Parent and overlay and overlay.Parent) then
		return nil
	end
	local visual = NAStuff.cmdInputSoftVisual
	if not (visual and visual.Parent == overlay) then
		visual = InstanceNew("Frame")
		visual.Name = "\0"
		visual.BackgroundTransparency = 1
		visual.BorderSizePixel = 0
		visual.ClipsDescendants = true
		visual.Size = UDim2.new(1, 0, 1, 0)
		visual.ZIndex = (overlay.ZIndex or 1) + 1
		visual.Parent = overlay
		NAStuff.cmdInputSoftVisual = visual

		const selection = InstanceNew("Frame")
		selection.Name = "\0"
		selection.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
		selection.BackgroundTransparency = 0.45
		selection.BorderSizePixel = 0
		selection.Visible = false
		selection.ZIndex = visual.ZIndex + 1
		selection.Parent = visual
		NAStuff.cmdInputSoftSelectionFrame = selection

		const textLabel = InstanceNew("TextLabel")
		textLabel.Name = "\0"
		textLabel.BackgroundTransparency = 1
		textLabel.BorderSizePixel = 0
		textLabel.ClipsDescendants = true
		textLabel.RichText = false
		textLabel.Text = ""
		textLabel.Visible = false
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.ZIndex = visual.ZIndex + 2
		textLabel.Parent = visual
		NAStuff.cmdInputSoftTextLabel = textLabel

		const caret = InstanceNew("Frame")
		caret.Name = "\0"
		caret.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		caret.BackgroundTransparency = 0
		caret.BorderSizePixel = 0
		caret.Visible = false
		caret.ZIndex = visual.ZIndex + 3
		caret.Parent = visual
		NAStuff.cmdInputSoftCaretFrame = caret
	end
	return visual
end

NAmanage.CmdInputUpdateSoftVisual = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	const overlay = NAStuff and NAStuff.cmdInputSoftOverlay
	if not (box and overlay) then
		return
	end
	local caret = NAStuff.cmdInputSoftCaretFrame
	local selection = NAStuff.cmdInputSoftSelectionFrame
	local textLabel = NAStuff.cmdInputSoftTextLabel
	if not (NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive()) then
		if caret then caret.Visible = false end
		if selection then selection.Visible = false end
		if textLabel then textLabel.Visible = false end
		return
	end
	NAmanage.CmdInputEnsureSoftVisual()
	caret = NAStuff.cmdInputSoftCaretFrame
	selection = NAStuff.cmdInputSoftSelectionFrame
	textLabel = NAStuff.cmdInputSoftTextLabel
	if not caret then
		return
	end
	const text = tostring(box.Text or "")
	const len = #text
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (len + 1), 1, len + 1)
	local displayText = text
	local showingPlaceholder = false
	if displayText == "" then
		const placeholder = tostring(box.PlaceholderText or "")
		if placeholder ~= "" then
			displayText = placeholder
			showingPlaceholder = true
		end
	end
	const textWidth = NAmanage.CmdInputMeasureTextWidth(box, text)
	const displayWidth = NAmanage.CmdInputMeasureTextWidth(box, displayText)
	const pad = 8
	const boxWidth = math.max(1, box.AbsoluteSize.X)
	const align = box.TextXAlignment
	const alignWidth = showingPlaceholder and displayWidth or textWidth
	local baseX = pad
	if align == Enum.TextXAlignment.Center then
		baseX = math.max(pad, (boxWidth - alignWidth) * 0.5)
	elseif align == Enum.TextXAlignment.Right then
		baseX = math.max(pad, boxWidth - alignWidth - pad)
	end
	baseX = math.floor(baseX + 0.5)
	if textLabel then
		pcall(function()
			textLabel.Font = box.Font
			textLabel.FontFace = box.FontFace
			textLabel.TextSize = box.TextSize
			textLabel.TextScaled = false
			textLabel.TextWrapped = false
			textLabel.TextColor3 = showingPlaceholder and (box.PlaceholderColor3 or Color3.fromRGB(178, 178, 178)) or box.TextColor3
			textLabel.TextTransparency = showingPlaceholder and 0.15 or (box.TextTransparency ~= nil and math.min(0.98, tonumber(NAStuff.cmdInputSoftPrevTextTransparency) or 0) or 0)
			textLabel.TextStrokeColor3 = box.TextStrokeColor3
			textLabel.TextStrokeTransparency = showingPlaceholder and 1 or box.TextStrokeTransparency
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.TextYAlignment = box.TextYAlignment
			textLabel.Position = UDim2.new(0, baseX, 0, 0)
			textLabel.Size = UDim2.new(1, -(baseX + pad), 1, 0)
			textLabel.Text = displayText
			textLabel.Visible = displayText ~= ""
		end)
	end
	const before = text:sub(1, math.max(0, cursor - 1))
	const caretOffset = before ~= "" and 1 or 0
	const caretX = math.clamp(math.floor(baseX + NAmanage.CmdInputMeasureTextWidth(box, before) + caretOffset + 0.5), 1, boxWidth - 2)
	const caretHeight = math.clamp((tonumber(box.TextSize) or 14) + 6, 12, math.max(12, box.AbsoluteSize.Y - 2))
	caret.Position = UDim2.new(0, caretX, 0.5, 0)
	caret.AnchorPoint = Vector2.new(0, 0.5)
	caret.Size = UDim2.new(0, 2, 0, caretHeight)
	caret.Visible = true

	local s, e = NAmanage.CmdInputGetSelectionRange(box)
	if selection and s and e and e > s then
		const leftText = text:sub(1, s - 1)
		const selectedText = text:sub(1, e - 1)
		const x1 = math.clamp(baseX + NAmanage.CmdInputMeasureTextWidth(box, leftText), 0, boxWidth)
		const x2 = math.clamp(baseX + NAmanage.CmdInputMeasureTextWidth(box, selectedText), 0, boxWidth)
		selection.Position = UDim2.new(0, math.min(x1, x2), 0.5, 0)
		selection.AnchorPoint = Vector2.new(0, 0.5)
		selection.Size = UDim2.new(0, math.max(2, math.abs(x2 - x1)), 0, caretHeight)
		selection.Visible = true
	elseif selection then
		selection.Visible = false
	end
end

NAmanage.CmdInputStartCaretBlink = function()
	NAStuff.cmdInputSoftCaretBlinkToken = (tonumber(NAStuff.cmdInputSoftCaretBlinkToken) or 0) + 1
	const token = NAStuff.cmdInputSoftCaretBlinkToken
	Spawn(function()
		while NAStuff and NAStuff.cmdInputSoftCaretBlinkToken == token and NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() do
			const caret = NAStuff.cmdInputSoftCaretFrame
			if caret then
				caret.Visible = not caret.Visible
			end
			Wait(0.5)
			if NAmanage.CmdInputUpdateSoftVisual then
				NAmanage.CmdInputUpdateSoftVisual()
			end
		end
	end)
end

NAmanage.CmdInputBindOutsideSoftBlur = function(enabled)
	const key = "cmdbar_soft_outside_blur"
	if enabled then
		if NAStuff.cmdInputSoftOutsideBound then
			return
		end
		NAlib.disconnect(key)
		const function outsideBlurAt(pos)
			if not (NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive()) then
				return
			end
			if pos and not NAmanage.CmdInputPointInsideSafeArea(pos) then
				NAStuff.cmdInputForceDeselect = true
				NAgui.barDeselect(0.18)
			end
		end
		NAlib.connect(key, Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not input or not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				return
			end
			outsideBlurAt(input.Position)
		end))
		NAlib.connect(key .. "_tap", Services.UserInputService.TouchTap:Connect(function(positions, gameProcessed)
			const pos = type(positions) == "table" and positions[1] or nil
			outsideBlurAt(pos)
		end))
		NAStuff.cmdInputSoftOutsideBound = true
	else
		NAlib.disconnect(key)
		NAlib.disconnect(key .. "_tap")
		NAStuff.cmdInputSoftOutsideBound = false
	end
end

NAgui.CmdInputSoftOverlaySet = function(enabled)
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	local overlay = NAStuff and NAStuff.cmdInputSoftOverlay
	if not enabled then
		if NAStuff then
			const caret = NAStuff.cmdInputSoftCaretFrame
			const selection = NAStuff.cmdInputSoftSelectionFrame
			const textLabel = NAStuff.cmdInputSoftTextLabel
			if caret then caret.Visible = false end
			if selection then selection.Visible = false end
			if textLabel then textLabel.Visible = false end
		end
		if overlay and overlay.Parent then
			overlay.Visible = false
		end
		return
	end
	if not (box and box.Parent) then
		return
	end
	if not (overlay and overlay.Parent == box.Parent) then
		overlay = InstanceNew("TextButton")
		overlay.Name = "\0"
		overlay.Text = ""
		overlay.AutoButtonColor = false
		overlay.BackgroundTransparency = 1
		overlay.BorderSizePixel = 0
		overlay.Parent = box.Parent
		NAStuff.cmdInputSoftOverlay = overlay
		const function activate()
			if NAmanage.CmdInputUseSoftFocus and NAmanage.CmdInputUseSoftFocus() then
				NAgui.barSelect(0.12)
				NAmanage.CmdSoftInputStart()
			end
		end
		overlay.MouseButton1Click:Connect(activate)
		overlay.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				activate()
			end
		end)
	end
	pcall(function()
		overlay.AnchorPoint = box.AnchorPoint
		overlay.Position = box.Position
		overlay.Size = box.Size
		overlay.Rotation = box.Rotation
		overlay.ZIndex = (box.ZIndex or 1) + 5
		overlay.Visible = true
		overlay.Active = true
		overlay.Selectable = false
	end)
	if NAmanage.CmdInputEnsureSoftVisual then
		NAmanage.CmdInputEnsureSoftVisual()
	end
	if NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
end

NAmanage.CmdInputSetRealTextHidden = function(enabled)
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return
	end
	if enabled then
		if NAStuff.cmdInputSoftPrevTextTransparency == nil then
			pcall(function()
				NAStuff.cmdInputSoftPrevTextTransparency = box.TextTransparency
			end)
		end
		if NAStuff.cmdInputSoftPrevTextStrokeTransparency == nil then
			pcall(function()
				NAStuff.cmdInputSoftPrevTextStrokeTransparency = box.TextStrokeTransparency
			end)
		end
		pcall(function()
			box.TextTransparency = 1
			box.TextStrokeTransparency = 1
		end)
	else
		pcall(function()
			if NAStuff.cmdInputSoftPrevTextTransparency ~= nil then
				box.TextTransparency = NAStuff.cmdInputSoftPrevTextTransparency
			end
			if NAStuff.cmdInputSoftPrevTextStrokeTransparency ~= nil then
				box.TextStrokeTransparency = NAStuff.cmdInputSoftPrevTextStrokeTransparency
			end
		end)
		NAStuff.cmdInputSoftPrevTextTransparency = nil
		NAStuff.cmdInputSoftPrevTextStrokeTransparency = nil
	end
end

NAmanage.CmdSoftInputStart = function()
	if not (NAmanage.CmdInputUseSoftFocus and NAmanage.CmdInputUseSoftFocus()) then
		return false
	end
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	NAStuff.cmdInputSoftFocus = true
	NAStuff.cmdBarSelected = true
	NAStuff.cmdSearchSuspendUntil = 0
	if NAStuff.cmdInputSoftPrevTextEditable == nil then
		NAStuff.cmdInputSoftPrevTextEditable = box.TextEditable
	end
	NAStuff.cmdInputSoftCursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box, #(box.Text or "") + 1)) or (#(box.Text or "") + 1)
	pcall(function()
		box.TextEditable = false
		box.ClearTextOnFocus = false
		box.CursorPosition = NAStuff.cmdInputSoftCursor
		box.SelectionStart = -1
	end)
	if NAmanage.CmdInputResetHistory and type(NAStuff.cmdInputUndoStack) ~= "table" then
		NAmanage.CmdInputResetHistory(box)
	end
	if NAmanage.CmdInputSetRealTextHidden then
		NAmanage.CmdInputSetRealTextHidden(true)
	end
	if NAgui.CmdInputSoftOverlaySet then
		NAgui.CmdInputSoftOverlaySet(true)
	end
	if NAmanage.CmdInputActualFocused and NAmanage.CmdInputActualFocused() then
		pcall(function()
			box:ReleaseFocus()
		end)
	end
	NAmanage.CmdInputBindSoftSink(true)
	if NAmanage.CmdInputBindOutsideSoftBlur then
		NAmanage.CmdInputBindOutsideSoftBlur(true)
	end
	if NAmanage.CmdInputStartCaretBlink then
		NAmanage.CmdInputStartCaretBlink()
	end
	if NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
	if IsOnMobile and NAgui.CmdMobileKeyboardShow then
		NAgui.CmdMobileKeyboardShow()
	end
	if type(NAgui.autoFILLLL) == "function" then
		Delay(0, NAgui.autoFILLLL)
	end
	return true
end

NAmanage.CmdSoftInputStop = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	NAStuff.cmdInputSoftFocus = false
	NAStuff.cmdInputSoftSelectAll = false
	NAStuff.cmdInputSoftSelectionAnchor = nil
	NAStuff.cmdInputSoftCursor = nil
	NAStuff.cmdInputSoftCaretBlinkToken = (tonumber(NAStuff.cmdInputSoftCaretBlinkToken) or 0) + 1
	if NAmanage.CmdInputStopKeyRepeat then
		NAmanage.CmdInputStopKeyRepeat()
	end
	NAmanage.CmdInputBindSoftSink(false)
	if NAmanage.CmdInputBindOutsideSoftBlur then
		NAmanage.CmdInputBindOutsideSoftBlur(false)
	end
	if NAmanage.CmdInputSetRealTextHidden then
		NAmanage.CmdInputSetRealTextHidden(false)
	end
	if NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
	if NAgui.CmdInputSoftOverlaySet then
		NAgui.CmdInputSoftOverlaySet(false)
	end
	if NAgui.CmdMobileKeyboardHide then
		NAgui.CmdMobileKeyboardHide()
	end
	if box and NAStuff.cmdInputSoftPrevTextEditable ~= nil then
		pcall(function()
			box.TextEditable = NAStuff.cmdInputSoftPrevTextEditable
		end)
	end
	NAStuff.cmdInputSoftPrevTextEditable = nil
end

NAmanage.SetCmdInputSafeMode = function(enabled, opts)
	enabled = enabled ~= false
	opts = type(opts) == "table" and opts or {}
	NAStuff.CmdInputSafeMode = enabled
	NAStuff.MobileCmdSafeInput = enabled
	if opts.save ~= false then
		pcall(NAmanage.NASettingsSet, "cmdInputSafeMode", enabled)
	end
	if not enabled then
		if NAmanage.CmdSoftInputStop then
			pcall(NAmanage.CmdSoftInputStop)
		end
		if NAgui and NAgui.CmdInputSoftOverlaySet then
			pcall(NAgui.CmdInputSoftOverlaySet, false)
		end
		if NAgui and NAgui.CmdMobileKeyboardHide then
			pcall(NAgui.CmdMobileKeyboardHide)
		end
		const box = NAUIMANAGER and NAUIMANAGER.cmdInput
		if box then
			pcall(function()
				box.TextEditable = true
				if NAStuff.cmdInputSoftPrevTextTransparency ~= nil then
					box.TextTransparency = NAStuff.cmdInputSoftPrevTextTransparency
				end
				if NAStuff.cmdInputSoftPrevTextStrokeTransparency ~= nil then
					box.TextStrokeTransparency = NAStuff.cmdInputSoftPrevTextStrokeTransparency
				end
			end)
		end
	else
		const box = NAUIMANAGER and NAUIMANAGER.cmdInput
		if box and NAStuff.cmdBarSelected == true and NAmanage.CmdSoftInputStart then
			pcall(NAmanage.CmdSoftInputStart)
			Defer(function()
				if NAStuff and NAStuff.CmdInputSafeMode ~= false and NAStuff.cmdBarSelected == true and NAmanage.CmdSoftInputStart then
					pcall(NAmanage.CmdSoftInputStart)
				end
			end)
		end
	end
	if opts.notify ~= false and type(DoNotif) == "function" then
		DoNotif("Command input method: "..(enabled and "Safe" or "Default"), 2)
	end
	return enabled
end

NAmanage.CmdInputSetCursor = function(box, pos, keepSelection)
	box = box or (NAUIMANAGER and NAUIMANAGER.cmdInput)
	if not box then
		return 1
	end
	const len = #(box.Text or "")
	local fallback = nil
	if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
		fallback = tonumber(NAStuff.cmdInputSoftCursor)
	end
	const cursor = math.clamp(tonumber(pos) or fallback or (len + 1), 1, len + 1)
	if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
		NAStuff.cmdInputSoftCursor = cursor
	end
	pcall(function()
		box.CursorPosition = cursor
	end)
	if keepSelection == true then
		local anchor = tonumber(NAStuff.cmdInputSoftSelectionAnchor)
		if anchor then
			anchor = math.clamp(anchor, 1, len + 1)
			pcall(function()
				box.SelectionStart = anchor
			end)
		end
	else
		NAmanage.CmdInputClearSoftSelection(false)
	end
	if NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
	return cursor
end
NAmanage.CmdInputCaptureState = function(box)
	box = box or (NAUIMANAGER and NAUIMANAGER.cmdInput)
	if not box then
		return nil
	end
	const text = tostring(box.Text or "")
	const len = #text
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (len + 1), 1, len + 1)
	local anchor = tonumber(NAStuff and NAStuff.cmdInputSoftSelectionAnchor)
	if anchor then
		anchor = math.clamp(anchor, 1, len + 1)
	end
	return {
		text = text;
		cursor = cursor;
		anchor = anchor;
		selectAll = NAStuff and NAStuff.cmdInputSoftSelectAll == true or false;
	}
end

NAmanage.CmdInputStatesEqual = function(a, b)
	return type(a) == "table"
		and type(b) == "table"
		and tostring(a.text or "") == tostring(b.text or "")
		and tonumber(a.cursor) == tonumber(b.cursor)
		and tonumber(a.anchor) == tonumber(b.anchor)
		and (a.selectAll == true) == (b.selectAll == true)
end

NAmanage.CmdInputResetHistory = function(box)
	const state = NAmanage.CmdInputCaptureState(box)
	NAStuff.cmdInputUndoStack = state and { state } or {}
	NAStuff.cmdInputRedoStack = {}
end

NAmanage.CmdInputPushUndo = function(box)
	box = box or (NAUIMANAGER and NAUIMANAGER.cmdInput)
	if not box then
		return
	end
	const state = NAmanage.CmdInputCaptureState(box)
	if not state then
		return
	end
	const stack = type(NAStuff.cmdInputUndoStack) == "table" and NAStuff.cmdInputUndoStack or {}
	const last = stack[#stack]
	if not NAmanage.CmdInputStatesEqual(last, state) then
		stack[#stack + 1] = state
		const max = 100
		while #stack > max do
			table.remove(stack, 1)
		end
	end
	NAStuff.cmdInputUndoStack = stack
	NAStuff.cmdInputRedoStack = {}
end

NAmanage.CmdInputApplyState = function(state)
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box or type(state) ~= "table" then
		return false
	end
	const text = tostring(state.text or "")
	box.Text = text
	NAStuff.cmdInputSoftSelectAll = state.selectAll == true
	NAStuff.cmdInputSoftSelectionAnchor = tonumber(state.anchor)
	const cursor = math.clamp(tonumber(state.cursor) or (#text + 1), 1, #text + 1)
	NAStuff.cmdInputSoftCursor = cursor
	pcall(function()
		box.CursorPosition = cursor
		box.SelectionStart = tonumber(NAStuff.cmdInputSoftSelectionAnchor) or -1
	end)
	if NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
	return true
end

NAmanage.CmdInputUndo = function()
	const stack = type(NAStuff.cmdInputUndoStack) == "table" and NAStuff.cmdInputUndoStack or {}
	if #stack <= 1 then
		return true
	end
	const current = NAmanage.CmdInputCaptureState()
	const redo = type(NAStuff.cmdInputRedoStack) == "table" and NAStuff.cmdInputRedoStack or {}
	if current then
		redo[#redo + 1] = current
	end
	const prev = stack[#stack - 1]
	stack[#stack] = nil
	NAStuff.cmdInputUndoStack = stack
	NAStuff.cmdInputRedoStack = redo
	NAmanage.CmdInputApplyState(prev)
	return true
end

NAmanage.CmdInputRedo = function()
	const redo = type(NAStuff.cmdInputRedoStack) == "table" and NAStuff.cmdInputRedoStack or {}
	const state = redo[#redo]
	if not state then
		return true
	end
	redo[#redo] = nil
	const stack = type(NAStuff.cmdInputUndoStack) == "table" and NAStuff.cmdInputUndoStack or {}
	const current = NAmanage.CmdInputCaptureState()
	if current then
		stack[#stack + 1] = current
	end
	NAStuff.cmdInputUndoStack = stack
	NAStuff.cmdInputRedoStack = redo
	NAmanage.CmdInputApplyState(state)
	return true
end

NAmanage.CmdInputIsWordChar = function(ch)
	return type(ch) == "string" and ch:match("[%w_]") ~= nil
end

NAmanage.CmdInputFindWordLeft = function(text, cursor)
	text = tostring(text or "")
	cursor = math.clamp(tonumber(cursor) or (#text + 1), 1, #text + 1)
	local i = cursor - 1
	while i > 1 and text:sub(i - 1, i - 1):match("%s") do
		i -= 1
	end
	while i > 1 and NAmanage.CmdInputIsWordChar(text:sub(i - 1, i - 1)) do
		i -= 1
	end
	return math.clamp(i, 1, #text + 1)
end

NAmanage.CmdInputFindWordRight = function(text, cursor)
	text = tostring(text or "")
	cursor = math.clamp(tonumber(cursor) or (#text + 1), 1, #text + 1)
	local i = cursor
	const len = #text
	while i <= len and text:sub(i, i):match("%s") do
		i += 1
	end
	while i <= len and NAmanage.CmdInputIsWordChar(text:sub(i, i)) do
		i += 1
	end
	return math.clamp(i, 1, len + 1)
end

NAmanage.CmdInputDeleteWordBack = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	if NAmanage.CmdInputDeleteSelection and NAmanage.CmdInputDeleteSelection(box) then
		return true
	end
	const text = tostring(box.Text or "")
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (#text + 1), 1, #text + 1)
	if cursor <= 1 then
		return true
	end
	local startPos = NAmanage.CmdInputFindWordLeft(text, cursor)
	if startPos == cursor then
		startPos = math.max(1, cursor - 1)
	end
	NAmanage.CmdInputPushUndo(box)
	box.Text = text:sub(1, startPos - 1)..text:sub(cursor)
	NAmanage.CmdInputSetCursor(box, startPos)
	return true
end

NAmanage.CmdInputDeleteWordForward = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	if NAmanage.CmdInputDeleteSelection and NAmanage.CmdInputDeleteSelection(box) then
		return true
	end
	const text = tostring(box.Text or "")
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (#text + 1), 1, #text + 1)
	if cursor > #text then
		return true
	end
	local endPos = NAmanage.CmdInputFindWordRight(text, cursor)
	if endPos == cursor then
		endPos = math.min(#text + 1, cursor + 1)
	end
	NAmanage.CmdInputPushUndo(box)
	box.Text = text:sub(1, cursor - 1)..text:sub(endPos)
	NAmanage.CmdInputSetCursor(box, cursor)
	return true
end

NAmanage.CmdInputInsertText = function(value)
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	local insert = tostring(value or "")
	if insert == "" then
		return true
	end
	insert = insert:gsub("\r\n", " "):gsub("[\r\n]", " ")
	local text = tostring(box.Text or "")
	if NAmanage.CmdInputPushUndo then
		NAmanage.CmdInputPushUndo(box)
	end
	if NAmanage.CmdInputDeleteSelection and NAmanage.CmdInputDeleteSelection(box, false) then
		text = tostring(box.Text or "")
	end
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or NAmanage.CmdInputSetCursor(box, box.CursorPosition)
	box.Text = text:sub(1, cursor - 1)..insert..text:sub(cursor)
	NAmanage.CmdInputSetCursor(box, cursor + #insert)
	return true
end

NAmanage.CmdInputDeleteBack = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	const text = tostring(box.Text or "")
	if NAmanage.CmdInputDeleteSelection and NAmanage.CmdInputDeleteSelection(box) then
		return true
	end
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or NAmanage.CmdInputSetCursor(box, box.CursorPosition)
	if cursor <= 1 then
		return true
	end
	if NAmanage.CmdInputPushUndo then
		NAmanage.CmdInputPushUndo(box)
	end
	box.Text = text:sub(1, cursor - 2)..text:sub(cursor)
	NAmanage.CmdInputSetCursor(box, cursor - 1)
	return true
end

NAmanage.CmdInputDeleteForward = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	const text = tostring(box.Text or "")
	if NAmanage.CmdInputDeleteSelection and NAmanage.CmdInputDeleteSelection(box) then
		return true
	end
	const cursor = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or NAmanage.CmdInputSetCursor(box, box.CursorPosition)
	if cursor > #text then
		return true
	end
	if NAmanage.CmdInputPushUndo then
		NAmanage.CmdInputPushUndo(box)
	end
	box.Text = text:sub(1, cursor - 1)..text:sub(cursor + 1)
	NAmanage.CmdInputSetCursor(box, cursor)
	return true
end

NAmanage.CmdInputKeyToChar = function(input)
	if not input or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return nil
	end
	const key = input.KeyCode
	const name = key and key.Name or ""
	local shift = false
	pcall(function()
		shift = Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	end)
	if #name == 1 and name:match("%a") then
		return shift and name:upper() or name:lower()
	end
	const normal = {
		[Enum.KeyCode.Zero] = "0", [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3", [Enum.KeyCode.Four] = "4",
		[Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6", [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
		[Enum.KeyCode.KeypadZero] = "0", [Enum.KeyCode.KeypadOne] = "1", [Enum.KeyCode.KeypadTwo] = "2", [Enum.KeyCode.KeypadThree] = "3", [Enum.KeyCode.KeypadFour] = "4",
		[Enum.KeyCode.KeypadFive] = "5", [Enum.KeyCode.KeypadSix] = "6", [Enum.KeyCode.KeypadSeven] = "7", [Enum.KeyCode.KeypadEight] = "8", [Enum.KeyCode.KeypadNine] = "9",
		[Enum.KeyCode.Space] = " ", [Enum.KeyCode.Semicolon] = ";", [Enum.KeyCode.Comma] = ",", [Enum.KeyCode.Period] = ".", [Enum.KeyCode.Slash] = "/",
		[Enum.KeyCode.BackSlash] = "\\", [Enum.KeyCode.Quote] = "'", [Enum.KeyCode.Minus] = "-", [Enum.KeyCode.Equals] = "=", [Enum.KeyCode.LeftBracket] = "[",
		[Enum.KeyCode.RightBracket] = "]", [Enum.KeyCode.Backquote] = "`", [Enum.KeyCode.KeypadPlus] = "+", [Enum.KeyCode.KeypadMinus] = "-", [Enum.KeyCode.KeypadMultiply] = "*",
		[Enum.KeyCode.KeypadDivide] = "/", [Enum.KeyCode.KeypadPeriod] = ".",
	}
	const shifted = {
		[Enum.KeyCode.Zero] = ")", [Enum.KeyCode.One] = "!", [Enum.KeyCode.Two] = "@", [Enum.KeyCode.Three] = "#", [Enum.KeyCode.Four] = "$",
		[Enum.KeyCode.Five] = "%", [Enum.KeyCode.Six] = "^", [Enum.KeyCode.Seven] = "&", [Enum.KeyCode.Eight] = "*", [Enum.KeyCode.Nine] = "(",
		[Enum.KeyCode.Semicolon] = ":", [Enum.KeyCode.Comma] = "<", [Enum.KeyCode.Period] = ">", [Enum.KeyCode.Slash] = "?", [Enum.KeyCode.BackSlash] = "|",
		[Enum.KeyCode.Quote] = "\"", [Enum.KeyCode.Minus] = "_", [Enum.KeyCode.Equals] = "+", [Enum.KeyCode.LeftBracket] = "{", [Enum.KeyCode.RightBracket] = "}",
		[Enum.KeyCode.Backquote] = "~",
	}
	return (shift and shifted[key]) or normal[key]
end


NAmanage.CmdInputGetSelectedText = function(box)
	box = box or (NAUIMANAGER and NAUIMANAGER.cmdInput)
	if not box then
		return ""
	end
	local s, e = NAmanage.CmdInputGetSelectionRange(box)
	if not s or not e or e <= s then
		return ""
	end
	const text = tostring(box.Text or "")
	return text:sub(s, e - 1)
end

NAmanage.CmdInputGetClipboardSet = function()
	for _, fn in { "setclipboard", "toclipboard", "set_clipboard" } do
		local value = rawget(_na_boot.hostEnv, fn)
		if type(value) == "function" then
			return value
		end
		if type(_G) == "table" then
			value = rawget(_G, fn)
			if type(value) == "function" then
				return value
			end
		end
	end
	if type(setclipboard) == "function" then
		return setclipboard
	end
	if type(toclipboard) == "function" then
		return toclipboard
	end
	return nil
end

NAmanage.CmdInputGetClipboardGet = function()
	for _, fn in { "getclipboard", "get_clipboard", "readclipboard" } do
		local value = rawget(_na_boot.hostEnv, fn)
		if type(value) == "function" then
			return value
		end
		if type(_G) == "table" then
			value = rawget(_G, fn)
			if type(value) == "function" then
				return value
			end
		end
	end
	if type(getclipboard) == "function" then
		return getclipboard
	end
	if type(readclipboard) == "function" then
		return readclipboard
	end
	return nil
end

NAmanage.CmdInputCopySelection = function()
	const selected = NAmanage.CmdInputGetSelectedText()
	if selected == "" then
		return true
	end
	const setter = NAmanage.CmdInputGetClipboardSet and NAmanage.CmdInputGetClipboardSet()
	if type(setter) == "function" then
		pcall(setter, selected)
	end
	return true
end

NAmanage.CmdInputCutSelection = function()
	const selected = NAmanage.CmdInputGetSelectedText()
	if selected ~= "" then
		const setter = NAmanage.CmdInputGetClipboardSet and NAmanage.CmdInputGetClipboardSet()
		if type(setter) == "function" then
			pcall(setter, selected)
		end
		NAmanage.CmdInputDeleteSelection()
	end
	return true
end

NAmanage.CmdInputNotifyMissingClipboardGet = function()
	const now = os.clock()
	if tonumber(NAStuff.cmdInputClipboardGetWarnAt) and now - NAStuff.cmdInputClipboardGetWarnAt < 1.25 then
		return
	end
	NAStuff.cmdInputClipboardGetWarnAt = now
	if type(DoNotif) == "function" then
		DoNotif("Your executor does not support getclipboard, so Ctrl+V cannot paste in Safe Command Input.", 2)
	end
end

NAmanage.CmdInputPasteClipboard = function()
	const getter = NAmanage.CmdInputGetClipboardGet and NAmanage.CmdInputGetClipboardGet()
	if type(getter) ~= "function" then
		if NAmanage.CmdInputNotifyMissingClipboardGet then
			NAmanage.CmdInputNotifyMissingClipboardGet()
		end
		return true
	end
	local ok, value = pcall(getter)
	if not ok or value == nil then
		return true
	end
	value = tostring(value):gsub("\r\n", " "):gsub("[\r\n]", " ")
	if value ~= "" then
		NAmanage.CmdInputInsertText(value)
	end
	return true
end

NAmanage.CmdInputRefreshPredictionNow = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	if not (NAmanage.isCmdBarActive and NAmanage.isCmdBarActive()) then
		return false
	end
	if #searchIndex <= 0 and type(NAmanage.queueCommandDataBuild) == "function" then
		pcall(NAmanage.queueCommandDataBuild, { force = true })
	end
	const ctx = NAmanage.getCmdAutofillContext(box.Text or "")
	const query = ctx.query or ""
	lastSearchText = query
	gen += 1
	NAStuff.lastCmdAutofillPendingQuery = nil
	NAStuff.lastCmdAutofillQuery = query
	NAmanage.performSearch(query, ctx)
	return true
end

NAmanage.CmdInputApplyPrediction = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return true
	end
	NAStuff.lastCmdAutofillCompletion = ""
	NAStuff.lastCmdAutofillPendingQuery = nil
	if predictionInput then
		predictionInput.Text = ""
	end
	if NAmanage.CmdInputRefreshPredictionNow then
		pcall(NAmanage.CmdInputRefreshPredictionNow)
	end
	const predictionText = (NAStuff and NAStuff.lastCmdAutofillCompletion) or (predictionInput and predictionInput.Text) or ""
	if predictionText == "" then
		return true
	end
	const sanitizedText = NAmanage.stripChar(predictionText)
	box.Text = sanitizedText
	NAmanage.CmdInputClearSoftSelection(false)
	NAmanage.CmdInputSetCursor(box, #sanitizedText + 1)
	NAStuff.lastCmdAutofillCompletion = ""
	NAStuff.lastCmdAutofillQuery = ""
	NAStuff.lastCmdAutofillPendingQuery = nil
	if predictionInput then
		predictionInput.Text = ""
	end
	return true
end

NAmanage.CmdInputSubmit = function()
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	NAStuff.cmdSearchSuspendUntil = os.clock() + 0.35
	gen += 1
	local txt = NAmanage.stripChar(box.Text or "")
	if txt and #txt > 0 then
		const prefix = tostring(opt.prefix or "")
		if prefix ~= "" then
			const escapedPrefix = (NAmanage.StreamerEscapePattern and NAmanage.StreamerEscapePattern(prefix)) or prefix:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
			txt = txt:gsub("^%s*"..escapedPrefix.."+%s*", "")
		end
		if txt ~= "" then
			Defer(function()
				NAlib.parseCommand(prefix..txt)
			end)
		end
	end
	if predictionInput then
		predictionInput.Text = ""
	end
	NAgui.barDeselect(0.18)
	return true
end

NAmanage.HandleCmdSoftInput = function(input, gameProcessed)
	if not (NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive()) then
		return false
	end
	if not input or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return true
	end
	const key = input.KeyCode
	local ctrl = false
	local shift = false
	pcall(function()
		ctrl = Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
		shift = Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
	end)
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return true
	end
	const function moveCursor(newPos)
		const current = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or math.clamp(tonumber(box.CursorPosition) or (#(box.Text or "") + 1), 1, #(box.Text or "") + 1)
		if shift then
			if tonumber(NAStuff.cmdInputSoftSelectionAnchor) == nil then
				NAStuff.cmdInputSoftSelectionAnchor = current
			end
			NAStuff.cmdInputSoftSelectAll = false
			NAmanage.CmdInputSetCursor(box, newPos, true)
		else
			NAmanage.CmdInputSetCursor(box, newPos, false)
		end
	end
	if key == Enum.KeyCode.Escape then
		NAgui.barDeselect(0.18)
		return true
	elseif key == Enum.KeyCode.Return or key == Enum.KeyCode.KeypadEnter then
		return NAmanage.CmdInputSubmit()
	elseif key == Enum.KeyCode.Tab then
		return NAmanage.CmdInputApplyPrediction()
	elseif ctrl and key == Enum.KeyCode.A then
		NAStuff.cmdInputSoftSelectAll = true
		NAStuff.cmdInputSoftSelectionAnchor = 1
		NAmanage.CmdInputSetCursor(box, #(box.Text or "") + 1, true)
		return true
	elseif ctrl and key == Enum.KeyCode.C then
		return NAmanage.CmdInputCopySelection()
	elseif ctrl and key == Enum.KeyCode.X then
		return NAmanage.CmdInputCutSelection()
	elseif ctrl and key == Enum.KeyCode.V then
		return NAmanage.CmdInputPasteClipboard()
	elseif ctrl and key == Enum.KeyCode.Z then
		if shift and NAmanage.CmdInputRedo then
			return NAmanage.CmdInputRedo()
		end
		return NAmanage.CmdInputUndo and NAmanage.CmdInputUndo() or true
	elseif ctrl and key == Enum.KeyCode.Y then
		return NAmanage.CmdInputRedo and NAmanage.CmdInputRedo() or true
	elseif (shift and key == Enum.KeyCode.Delete) then
		return NAmanage.CmdInputCutSelection()
	elseif (ctrl and key == Enum.KeyCode.Insert) then
		return NAmanage.CmdInputCopySelection()
	elseif (shift and key == Enum.KeyCode.Insert) then
		return NAmanage.CmdInputPasteClipboard()
	elseif key == Enum.KeyCode.Backspace then
		const fn = ctrl and NAmanage.CmdInputDeleteWordBack or NAmanage.CmdInputDeleteBack
		fn()
		if NAmanage.CmdInputStartKeyRepeat then
			NAmanage.CmdInputStartKeyRepeat(Enum.KeyCode.Backspace, fn, { delay = 0.34, interval = 0.045 })
		end
		return true
	elseif key == Enum.KeyCode.Delete then
		const fn = ctrl and NAmanage.CmdInputDeleteWordForward or NAmanage.CmdInputDeleteForward
		fn()
		if NAmanage.CmdInputStartKeyRepeat then
			NAmanage.CmdInputStartKeyRepeat(Enum.KeyCode.Delete, fn, { delay = 0.34, interval = 0.045 })
		end
		return true
	elseif key == Enum.KeyCode.Left then
		const text = tostring(box.Text or "")
		const current = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or tonumber(box.CursorPosition) or (#text + 1)
		moveCursor(ctrl and NAmanage.CmdInputFindWordLeft(text, current) or (current - 1))
		return true
	elseif key == Enum.KeyCode.Right then
		const text = tostring(box.Text or "")
		const current = (NAmanage.CmdInputGetCursor and NAmanage.CmdInputGetCursor(box)) or tonumber(box.CursorPosition) or (#text + 1)
		moveCursor(ctrl and NAmanage.CmdInputFindWordRight(text, current) or (current + 1))
		return true
	elseif key == Enum.KeyCode.Home then
		moveCursor(1)
		return true
	elseif key == Enum.KeyCode.End then
		moveCursor(#(box.Text or "") + 1)
		return true
	elseif ctrl then
		return true
	end
	const char = NAmanage.CmdInputKeyToChar(input)
	if char then
		const inserted = NAmanage.CmdInputInsertText(char)
		if inserted and NAmanage.CmdInputStartKeyRepeat then
			NAmanage.CmdInputStartKeyRepeat(key, function()
				const repeatChar = NAmanage.CmdInputKeyToChar(input)
				if repeatChar then
					NAmanage.CmdInputInsertText(repeatChar)
				end
			end, { delay = 0.34, interval = 0.045, input = input })
		end
		return inserted
	end
	return true
end

NAgui.ensureCmdFocus = function()
	if not (NAUIMANAGER and NAUIMANAGER.cmdInput) then return end
	if NAmanage.CmdSoftInputStart and NAmanage.CmdSoftInputStart() then
		return
	end
	const box = NAUIMANAGER.cmdInput
	cmdDefaultClear = NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() == true
	box.ClearTextOnFocus = false
	box:CaptureFocus()
	const deadline = os.clock() + 0.35
	Spawn(function()
		while box and box.Parent and not box:IsFocused() and os.clock() < deadline do
			box:CaptureFocus()
			Wait(0.03)
		end
		if box then
			box.ClearTextOnFocus = cmdDefaultClear
		end
	end)
end

NAgui.barSelect = function(speed)
	speed = speed or 0.18
	shouldShowDefaultAutofill = true
	NAStuff.cmdBarSelected = true
	NAmanage.setCmdAutofillClickable(true)

	const legacy = NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() == true
	const targetSize = legacy and UDim2.new(0, 280, 1, 10) or (cmdBarExpandedSize or UDim2.new(0, 520, 1, 0))
	const startSize = legacy and UDim2.new(0, 250, 1, 8) or UDim2.new(
		targetSize.X.Scale,
		math.max(0, targetSize.X.Offset - 36),
		targetSize.Y.Scale,
		targetSize.Y.Offset - 2
	)
	NAUIMANAGER.centerBar.Size = startSize
	NAUIMANAGER.centerBar.Visible = true
	if legacy then
		NAUIMANAGER.leftFill.Visible = true
		NAUIMANAGER.rightFill.Visible = true
	else
		const shell = NAUIMANAGER.centerBar:FindFirstChild("Horizontal")
		const outline = shell and shell:FindFirstChild("CmdOutline")
		if outline then
			NAgui.tween(outline, "Sine", "Out", math.max(speed * 0.6, 0.05), {Transparency = 0.18})
		end
		const enterHint = NAUIMANAGER.centerBar:FindFirstChild("EnterHint")
		if enterHint then
			NAgui.tween(enterHint, "Sine", "Out", math.max(speed * 0.6, 0.05), {
				TextColor3 = Color3.fromRGB(245, 245, 248);
				BackgroundColor3 = Color3.fromRGB(40, 40, 45);
			})
		end
	end
	if speed > 0 then
		NAgui.tween(NAUIMANAGER.centerBar, "Back", "Out", speed * 0.6, {
			Size = targetSize
		})
	else
		NAUIMANAGER.centerBar.Size = targetSize
	end

	NAUIMANAGER.leftFill.Position = UDim2.new(0.5, 0, 0.5, 0)
	NAUIMANAGER.rightFill.Position = UDim2.new(0.5, 0, 0.5, 0)
	NAUIMANAGER.leftFill.Size = UDim2.new(0, 0, fillSizes.left.Y.Scale, fillSizes.left.Y.Offset)
	NAUIMANAGER.rightFill.Size = UDim2.new(0, 0, fillSizes.right.Y.Scale, fillSizes.right.Y.Offset)

	Wait(speed * 0.05)
	NAgui.tween(NAUIMANAGER.leftFill, "Quart", "Out", math.max(speed * 1.2, 0.05), {
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = fillSizes.left
	})
	NAgui.tween(NAUIMANAGER.rightFill, "Quart", "Out", math.max(speed * 1.2, 0.05), {
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = fillSizes.right
	})
	if NAmanage.CmdInputUseSoftFocus and NAmanage.CmdInputUseSoftFocus() then
		Delay(speed * 0.4, function()
			if NAStuff.cmdBarSelected and NAmanage.CmdSoftInputStart then
				NAmanage.CmdSoftInputStart()
			end
		end)
	elseif not IsOnMobile then
		Delay(speed * 0.4, NAgui.ensureCmdFocus)
	end
end

NAgui.activateCmdInput = function(opts)
	opts = opts or {}
	const box = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not box then
		return false
	end
	const prefixChar = tostring(opts.prefixChar or (opt and opt.prefix) or ""):sub(1, 1)
	if NAmanage.CmdInputUseSoftFocus and NAmanage.CmdInputUseSoftFocus() then
		NAgui.barSelect(opts.speed)
		if opts.clear ~= false then
			box.Text = ""
			NAmanage.CmdInputSetCursor(box, 1)
			if predictionInput then
				predictionInput.Text = ""
			end
		end
		NAmanage.CmdSoftInputStart()
		return true
	end
	local alreadyFocused = false
	if Services.UserInputService.GetFocusedTextBox then
		alreadyFocused = __lt.cm("UserInputService", "GetFocusedTextBox") == box
	end
	if not alreadyFocused then
		alreadyFocused = box:IsFocused()
	end
	NAgui.barSelect(opts.speed)
	if not alreadyFocused and opts.clear ~= false then
		box.Text = ""
		if predictionInput then
			predictionInput.Text = ""
		end
	end
	if alreadyFocused then
		return true
	end
	local focused = false
	for _ = 1, 6 do
		box:CaptureFocus()
		Wait(0.01)
		if box:IsFocused() then
			focused = true
			break
		end
	end
	if focused and prefixChar ~= "" then
		const current = box.Text or ""
		if Sub(current, 1, #prefixChar) == prefixChar then
			const trimmed = current:sub(#prefixChar + 1)
			box.Text = trimmed
			box.CursorPosition = #trimmed + 1
		end
	end
	return focused
end

NAgui.barDeselect = function(speed)
	const forceDeselect = NAStuff and NAStuff.cmdInputForceDeselect == true
	if forceDeselect and NAStuff then
		NAStuff.cmdInputForceDeselect = false
	end
	if IsOnMobile and not forceDeselect and NAStuff.autofillRefocusGuard > 0 and os.clock() < NAStuff.autofillRefocusGuard then
		return
	end
	speed = speed or 0.4

	shouldShowDefaultAutofill = false
	NAStuff.cmdBarSelected = false
	NAmanage.setCmdAutofillClickable(false)
	NAStuff.cmdSearchSuspendUntil = math.max(tonumber(NAStuff.cmdSearchSuspendUntil) or 0, os.clock() + 0.15)
	gen += 1
	const legacy = NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() == true
	if not legacy then
		const shell = NAUIMANAGER.centerBar and NAUIMANAGER.centerBar:FindFirstChild("Horizontal")
		const outline = shell and shell:FindFirstChild("CmdOutline")
		if outline then
			NAgui.tween(outline, "Sine", "Out", math.max(speed * 0.45, 0.05), {Transparency = 0.58})
		end
		const enterHint = NAUIMANAGER.centerBar and NAUIMANAGER.centerBar:FindFirstChild("EnterHint")
		if enterHint then
			NAgui.tween(enterHint, "Sine", "Out", math.max(speed * 0.45, 0.05), {
				TextColor3 = Color3.fromRGB(196, 196, 204);
				BackgroundColor3 = Color3.fromRGB(31, 31, 35);
			})
		end
	end

	NAgui.tween(NAUIMANAGER.centerBar, "Back", "InOut", speed, {
		Size = UDim2.new(0, 0, 0, 0)
	})

	NAgui.tween(NAUIMANAGER.leftFill, "Quart", "In", speed * 0.9, {
		Position = UDim2.new(-0.5, -125, 0.5, 0),
		Size = UDim2.new(0, 0, fillSizes.left.Y.Scale, fillSizes.left.Y.Offset)
	})
	NAgui.tween(NAUIMANAGER.rightFill, "Quart", "In", speed * 0.9, {
		Position = UDim2.new(1.5, 125, 0.5, 0),
		Size = UDim2.new(0, 0, fillSizes.right.Y.Scale, fillSizes.right.Y.Offset)
	})

	local hadVisible = false
	const toHide = {}
	for i = 1, #prevVisible do
		const v = prevVisible[i]
		if v and v.Parent and v:IsA("Frame") then
			hadVisible = true
			toHide[#toHide + 1] = v
			NAgui.tween(v, "Exponential", "In", 0.12, {
				Size = legacy and UDim2.new(0, 0, 0, 25) or UDim2.new(0.96, -16, 0, 34)
			})
		end
	end
	table.clear(prevVisible)
	Delay(0.14, function()
		for i = 1, #toHide do
			const frame = toHide[i]
			if frame and frame.Parent and frame:IsA("GuiObject") then
				frame.Visible = false
			end
		end
		if not NAmanage.isCmdBarActive() then
			NAgui.hideFill()
		end
	end)
	if not hadVisible then
		NAgui.hideFill()
	end
	if NAmanage.CmdSoftInputStop then
		NAmanage.CmdSoftInputStop()
	end
	if NAUIMANAGER and NAUIMANAGER.cmdInput then
		pcall(function()
			NAUIMANAGER.cmdInput:ReleaseFocus()
		end)
		if cmdDefaultClear ~= nil then
			NAUIMANAGER.cmdInput.ClearTextOnFocus = cmdDefaultClear
		end
	end
end

--[[ AUTOFILL SEARCHER ]]--
function fixStupidSearchGoober(cmdName, command)
	const dInfo = command and command[2] and command[2][1] or ""
	const func = command and command[1]

	const aliasSet = {}
	for alias, data in cmds.Aliases do
		if data[1] == func then
			aliasSet[Lower(alias)] = true
		end
	end

	const main = cmdName and Lower(cmdName)
	const existingAliases = {}
	local prefix, aliasBlock = dInfo:match("^(.-)%s*%((.-)%)$")

	if aliasBlock then
		for a in aliasBlock:gmatch("[^,%s]+") do
			aliasSet[Lower(a)] = true
		end
	end

	const final = {}
	for alias in aliasSet do
		if alias ~= main then
			Insert(final, alias)
		end
	end
	table.sort(final)

	local updTxt
	if prefix then
		updTxt = prefix.." ("..Concat(final, ", ")..")"
	else
		updTxt = dInfo
		if #final > 0 then
			updTxt = updTxt.." ("..Concat(final, ", ")..")"
		end
	end

	return updTxt, final
end

NAmanage.computeScore=function(entry,term,len,aliasExact,savedExact,aliasPrefix,savedPrefix)
	if not entry or not entry.name or not entry.lowerName then return end
	const cmdEntry = cmds.Commands and cmds.Commands[entry.name] or nil
	const meta = entry.meta or (NAStuff.AutofillMetaByName and NAStuff.AutofillMetaByName[entry.name]) or nil

	if entry.lowerName == term then return 1,entry.name end
	if Sub(entry.lowerName,1,len) == term then return 2,entry.name end

	if cmdEntry then
		const exactAlias = aliasExact[entry.name]
		if exactAlias then
			return 3, exactAlias
		end
	end
	if savedExact[entry.name] then
		return 3, savedExact[entry.name]
	end

	if cmdEntry then
		const prefixAlias = aliasPrefix[entry.name]
		if prefixAlias then
			return 4, prefixAlias
		end
	end
	if savedPrefix[entry.name] then
		return 4, savedPrefix[entry.name]
	end

	if meta and meta.aliases then
		for _, alias in meta.aliases do
			if alias == term then
				return 3, entry.name
			end
			if Sub(alias, 1, len) == term then
				return 4, entry.name
			end
			if len >= 2 and Find(alias, term, 1, true) then
				return 5, entry.name
			end
		end
	end

	const extraAliases = entry.extraAliases or {}
	for _,a in extraAliases do
		if a == term then return 3,entry.name end
		if Sub(a,1,len) == term then return 4,entry.name end
		if Find(a,term,1,true) then return 5,entry.name end
	end
	if len >= 2 then
		if Find(entry.lowerName,term,1,true) then return 6,entry.name end
		if entry.searchable and Find(entry.searchable,term,1,true) then
			local displayName = entry.name
			if meta and meta.displayText then
				displayName = meta.displayText
			elseif cmdEntry and type(cmdEntry[2]) == "table" and cmdEntry[2][1] then
				displayName = cmdEntry[2][1]
			end
			return 7,displayName
		end
	end
end

NAmanage.performSearch = function(term, ctx)
	ctx = ctx or NAmanage.getCmdAutofillContext((NAUIMANAGER and NAUIMANAGER.cmdInput and NAUIMANAGER.cmdInput.Text) or term or "")
	if not NAmanage.isCmdBarActive() then
		if predictionInput then
			predictionInput.Text = ""
		end
		NAStuff.lastCmdAutofillCompletion = ""
		NAgui.hideFill()
		return
	end
	const listHidden = NAmanage.IsCmdAutofillHidden and NAmanage.IsCmdAutofillHidden() or false
	const autofillHost = NAUIMANAGER and NAUIMANAGER.cmdAutofill
	if autofillHost and autofillHost:IsA("GuiObject") then
		autofillHost.Visible = not listHidden
	end
	if listHidden then
		NAgui.hideFill()
	end
	for _, f in prevVisible do f.Visible = false end
	table.clear(prevVisible)
	table.clear(results)
	if #searchIndex <= 0 and type(NAmanage.queueCommandDataBuild) == "function" then
		pcall(NAmanage.queueCommandDataBuild, { force = true })
	end
	const legacy = NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() == true
	const suggestionLimit = legacy and 5 or math.clamp(tonumber(NAStuff.cmdAutofillLimit) or 5, 1, 5)
	const suggestionRowHeight = legacy and 28 or math.max(34, tonumber(NAStuff.cmdAutofillRowHeight) or 38)
	const suggestionPool = NAmanage.ensureCmdAutofillSuggestionPool and NAmanage.ensureCmdAutofillSuggestionPool(5) or {}
	local visibleSuggestionCount = 0
	const function finishSuggestionLayout()
		NAStuff.cmdAutofillVisibleCount = visibleSuggestionCount
		if not (autofillHost and autofillHost:IsA("GuiObject")) then
			return
		end
		if legacy then
			autofillHost.Visible = not listHidden
			return
		end
		if listHidden or visibleSuggestionCount <= 0 then
			autofillHost.Visible = false
			return
		end
		const height = 16 + (visibleSuggestionCount * suggestionRowHeight) + ((visibleSuggestionCount - 1) * 6)
		const targetSize = UDim2.new(autofillHost.Size.X.Scale, autofillHost.Size.X.Offset, 0, height)
		autofillHost.Visible = true
		if canTween then
			NAgui.tween(autofillHost, "Quint", "Out", 0.16, {Size = targetSize})
		else
			autofillHost.Size = targetSize
		end
	end
	const function pushTop(candidate)
		local insertAt = #results + 1
		for idx = 1, #results do
			const existing = results[idx]
			if candidate.score < existing.score or (candidate.score == existing.score and candidate.name < existing.name) then
				insertAt = idx
				break
			end
		end
		Insert(results, insertAt, candidate)
		if #results > suggestionLimit then
			table.remove(results)
		end
	end

	const function revealEntry(entry, index)
		if listHidden then
			return
		end
		const frame = suggestionPool[index]
		if not frame then return end
		NAmanage.applyCmdAutofillEntryToFrame(frame, entry)
		Insert(prevVisible, frame)
		frame.Visible = true
		visibleSuggestionCount = math.max(visibleSuggestionCount, index)
		NAmanage.setCmdAutofillItemInteractivity(frame, NAStuff.cmdAutofillClickable == true and NAStuff.cmdBarSelected == true)
		if legacy then
			NAmanage.ApplyCmdAutofillFrameMode(frame, true)
			const w = math.sqrt(index) * 125
			const y = (index - 1) * 28
			const pos = UDim2.new(0.5, w, 0, y)
			const size = UDim2.new(0.5, w, 0, 25)
			if canTween then
				NAgui.tween(frame, "Quint", "Out", 0.2, {Size = size, Position = pos})
			else
				frame.Size = size
				frame.Position = pos
			end
			return
		end
		local visual = frame:FindFirstChild("Background")
		visual = visual and visual:FindFirstChild("Horizontal")
		if visual then
			visual.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
			visual.BackgroundTransparency = 0.2
			const outline = visual:FindFirstChild("ItemOutline")
			if outline then outline.Transparency = 0.76 end
			const line = visual:FindFirstChild("SelectionLine")
			if line then line.BackgroundTransparency = 0.42 end
		end
		const size = UDim2.new(1, -16, 0, suggestionRowHeight)
		if canTween then
			frame.Size = UDim2.new(0.96, -16, 0, suggestionRowHeight - 2)
			NAgui.tween(frame, "Quint", "Out", 0.18, {Size = size})
		else
			frame.Size = size
		end
	end

	if term == "" or Match(term, "^%s*$") then
		predictionInput.Text = ""
		NAStuff.lastCmdAutofillCompletion = ""
		shouldShowDefaultAutofill = false
		local displayed = 0
		for _, cmdName in defaultBarCommands do
			if displayed >= suggestionLimit then
				break
			end
			const target = Lower(cmdName)
			local entry = type(NAStuff.DefaultBarAutofillEntries) == "table" and NAStuff.DefaultBarAutofillEntries[target] or nil
			if not entry then
				for _, searchEntry in searchIndex do
					if NAmanage.defaultCommandMatches(searchEntry, target) then
						entry = searchEntry
						break
					end
				end
			end
			if entry then
				displayed += 1
				revealEntry(entry, displayed)
			end
		end
		finishSuggestionLayout()
		return
	end

	local lockedTerm
	if Match(term, "%s") then
		const first = term:match("^%s*(%S+)")
		if not first or first == "" then
			predictionInput.Text = ""
			finishSuggestionLayout()
			return
		end
		lockedTerm = first
		term = first
	end

	const len = #term
	table.clear(aliasExactCache)
	table.clear(savedExactCache)
	table.clear(aliasPrefixCache)
	table.clear(savedPrefixCache)
	if next(aliasOwnerByAlias) == nil and next(cmds.Aliases or {}) ~= nil then
		NAmanage.rebuildSearchAliasCache()
	end
	for alias, targetName in aliasOwnerByAlias do
		if alias == term then
			aliasExactCache[targetName] = alias
		end
		if Sub(alias,1,len) == term then
			aliasPrefixCache[targetName] = alias
		end
	end
	for alias, original in savedOwnerByAlias do
		if alias == term then
			savedExactCache[original] = alias
		end
		if Sub(alias,1,len) == term then
			savedPrefixCache[original] = alias
		end
	end
	const function matchesLockedEntry(entry)
		if not lockedTerm then
			return true
		end
		if entry.lowerName == lockedTerm then
			return true
		end
		if aliasExactCache[entry.name] or savedExactCache[entry.name] then
			return true
		end
		const meta = entry.meta
		if meta and meta.aliases then
			for _, alias in meta.aliases do
				if alias and Lower(alias) == lockedTerm then
					return true
				end
			end
		end
		if entry.extraAliases then
			for _, alias in entry.extraAliases do
				if alias and Lower(alias) == lockedTerm then
					return true
				end
			end
		end
		return false
	end

	local lockedHasMatch = false
	if lockedTerm then
		for _, entry in searchIndex do
			if matchesLockedEntry(entry) then
				lockedHasMatch = true
				break
			end
		end
	end

	for _, entry in searchIndex do
		if not lockedTerm or not lockedHasMatch or matchesLockedEntry(entry) then
			local sc, txt = NAmanage.computeScore(entry, term, len, aliasExactCache, savedExactCache, aliasPrefixCache, savedPrefixCache)
			if sc then
				pushTop({entry = entry, score = sc, text = txt, name = entry.name})
			end
		end
	end

	const topText = (results[1] and results[1].text) or ""
	const fullText = NAmanage.composeCmdAutofillText(ctx, topText)
	NAStuff.lastCmdAutofillCompletion = fullText
	NAStuff.lastCmdAutofillQuery = term or ""
	NAStuff.lastCmdAutofillPendingQuery = nil
	predictionInput.Text = NAmanage.stripChar(fullText)

	for i = 1, #results do
		const r = results[i]
		revealEntry(r.entry, i)
	end
	finishSuggestionLayout()
end

NAgui.searchCommands = function()
	if not NAUIMANAGER.cmdInput then return end
	if searchInputTarget == NAUIMANAGER.cmdInput and NAlib.isConnected("SearchInput") then
		return
	end
	if NAlib.isConnected("SearchInput") then NAlib.disconnect("SearchInput") end
	searchInputTarget = NAUIMANAGER.cmdInput
	NAlib.connect("SearchInput",NAUIMANAGER.cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
		const suspendedUntil = tonumber(NAStuff.cmdSearchSuspendUntil) or 0
		if suspendedUntil > 0 and os.clock() < suspendedUntil then
			return
		end
		const ctx = NAmanage.getCmdAutofillContext(NAUIMANAGER.cmdInput.Text)
		const query = ctx.query or ""
		const cleaned = Lower(GSub(NAUIMANAGER.cmdInput.Text,";",""))
		shouldShowDefaultAutofill = cleaned == ""
		if query == lastSearchText then
			return
		end
		NAStuff.lastCmdAutofillCompletion = ""
		NAStuff.lastCmdAutofillPendingQuery = query
		if predictionInput then
			predictionInput.Text = ""
		end
		lastSearchText = query
		gen += 1
		const thisGen = gen
		Delay(0,function()
			if thisGen ~= gen then return end
			const now = os.clock()
			const suspendedUntil = tonumber(NAStuff.cmdSearchSuspendUntil) or 0
			if suspendedUntil > 0 and now < suspendedUntil then
				return
			end
			const box = NAUIMANAGER and NAUIMANAGER.cmdInput
			if not box then
				return
			end
			local focused = false
			local okFocused, isFocusedNow = pcall(function()
				return box:IsFocused()
			end)
			if okFocused and isFocusedNow then
				focused = true
			end
			if not focused and NAStuff.cmdBarSelected ~= true then
				return
			end
			NAmanage.performSearch(query, ctx)
		end)
	end))
end
