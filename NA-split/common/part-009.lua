NAmanage.RenderUserButtons = function()
	const screenGui = NAmanage.waitForScreenGui(5)
	if not screenGui then
		NAmanage.loaderWarn('RenderUserButtons', 'aborted: interface not ready')
		return false
	end
	if NAmanage._renderUserButtonsRunning then
		return true
	end
	NAmanage._renderUserButtonsRunning = true

	local success, err = pcall(function()
		NAStuff.NASCREENGUI = screenGui
		if NAStuff.KeybindConnection then
		end
		for _, drop in UserButtonDropdowns do
			if type(drop) == "table" then
				if drop.conn then
					pcall(function() drop.conn:Disconnect() end)
				end
				if drop.container then
					pcall(function() drop.container:Destroy() end)
				end
			elseif typeof(drop) == "Instance" then
				pcall(function() drop:Destroy() end)
			end
		end
		table.clear(UserButtonDropdowns)
		for _, btn in UserButtonGuiList do
			btn:Destroy()
		end
		table.clear(UserButtonGuiList)
		table.clear(UserButtonGuiMap)

		const UIS = Services.UserInputService
		const SavedArgs       = {}
		const ActivePrompts   = {}
		const ActiveKeyBinding= {}
		const ActionBindings  = {}
		const tSize = 28
		const DOUBLE_CLICK_WINDOW = 0.35
		const activeDropdowns = {}
		const dropdownPos = {
			gap = 10,
			downOffset = 55,
			upOffset = -60,
			sideYOffset = 6,
		}
		const function sessionInstanceName(key)
			if NAmanage and type(NAmanage.GetSessionInstanceName) == "function" then
				local ok, name = pcall(NAmanage.GetSessionInstanceName, tostring(key or "UserButtonGui"))
				if ok and type(name) == "string" and name ~= "" then
					return name
				end
			end
			return tostring(key or "UserButtonGui")
		end

		const function placeGroupContainer(mode, btn, dropSize)
			dropSize = dropSize or Vector2.new(0, 0)
			const tap = btn.AbsolutePosition
			const tsz = btn.AbsoluteSize
			const cam = Services.Workspace.CurrentCamera
			const vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
			const margin = 8
			const gapDown = (dropdownPos.gap or 0) + (dropdownPos.downOffset or 0)
			const gapUp = (dropdownPos.gap or 0) + (dropdownPos.upOffset or 0)
			const sideYOffset = dropdownPos.sideYOffset or 0

			if mode == "side" then
				const canRight = (tap.X + tsz.X + dropdownPos.gap + dropSize.X) <= (vp.X - margin)
				const canLeft = (tap.X - dropdownPos.gap - dropSize.X) >= margin
				local openRight = canRight
				if not canRight and canLeft then
					openRight = false
				elseif not canLeft and not canRight then
					openRight = ((vp.X - (tap.X + tsz.X)) >= tap.X)
				end

				const anchor = Vector2.new(openRight and 0 or 1, 0.5)
				local x
				if openRight then
					x = math.min(tap.X + tsz.X + dropdownPos.gap, vp.X - margin - dropSize.X)
					x = math.max(x, margin)
				else
					x = math.max(tap.X - dropdownPos.gap, margin + dropSize.X)
					x = math.min(x, vp.X - margin)
				end

				const halfH = dropSize.Y * 0.5
				const y = math.clamp(tap.Y + tsz.Y * 1.25 + sideYOffset, margin + halfH, vp.Y - margin - halfH)
				return UDim2.fromOffset(x, y), anchor
			end

			const canDown = (tap.Y + tsz.Y + gapDown + dropSize.Y) <= (vp.Y - margin)
			const canUp = (tap.Y - gapUp - dropSize.Y) >= margin
			local openDown = canDown
			if not canDown and canUp then
				openDown = false
			elseif not canUp and not canDown then
				openDown = ((vp.Y - (tap.Y + tsz.Y)) >= tap.Y)
			end

			const anchor = Vector2.new(0.5, openDown and 0 or 1)
			const halfW = dropSize.X * 0.5
			const x = math.clamp(tap.X + tsz.X * 0.5, margin + halfW, vp.X - margin - halfW)

			local y
			if openDown then
				y = tap.Y + tsz.Y + gapDown
				if canDown then
					y = math.min(y, vp.Y - margin - dropSize.Y)
					y = math.max(y, margin)
				end
			else
				y = tap.Y - gapUp
				if canUp then
					y = math.max(y, margin + dropSize.Y)
					y = math.min(y, vp.Y - margin)
				end
			end

			return UDim2.fromOffset(x, y), anchor
		end

		const function clearDropdownEntry(id)
			const entry = activeDropdowns[id]
			if not entry then
				return
			end
			if entry.close then
				entry.close()
			elseif entry.container then
				entry.container:Destroy()
			end
			if entry.conn then
				entry.conn:Disconnect()
			end
			if entry.posConn then
				entry.posConn:Disconnect()
			end
			if entry.sizeConn then
				entry.sizeConn:Disconnect()
			end
			activeDropdowns[id] = nil
			UserButtonDropdowns[id] = nil
		end

		const function closeAllDropdowns()
			for id in activeDropdowns do
				clearDropdownEntry(id)
			end
		end

		const function updateDropdownPosition(id)
			const entry = activeDropdowns[id]
			if not entry or not entry.container or not entry.btn then
				return
			end
			const mode = entry.mode or "dropdown"
			const size = entry.container.AbsoluteSize
			local pos, anchor = placeGroupContainer(mode, entry.btn, size)
			entry.container.AnchorPoint = anchor
			entry.container.Position = pos
		end

		const function udim2ToArray(u)
			return {u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset}
		end

		const function positionsChanged(a, b)
			if type(a) ~= "table" or type(b) ~= "table" then
				return true
			end
			const dx = math.abs((a[1] or 0) - (b[1] or 0))
			const dy = math.abs((a[3] or 0) - (b[3] or 0))
			const ox = math.abs((a[2] or 0) - (b[2] or 0))
			const oy = math.abs((a[4] or 0) - (b[4] or 0))
			return dx > 0.0005 or dy > 0.0005 or ox > 1.5 or oy > 1.5
		end

		function ButtonInputPrompt(cmdName, cb)
			const gui = InstanceNew("ScreenGui")
			gui.Name = sessionInstanceName("UserButtonArgPromptGui_"..tostring(cmdName or "Command"))
			gui.IgnoreGuiInset = true
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			gui.Parent = screenGui

			const f = InstanceNew("Frame")
			f.Name = sessionInstanceName("UserButtonArgPromptFrame")
			f.Size = UDim2.new(0,260,0,140)
			f.Position = UDim2.new(0.5,-130,0.5,-70)
			f.BackgroundColor3 = Color3.fromRGB(30,30,30)
			f.BorderSizePixel = 0
			f.Parent = gui

			const u = InstanceNew("UICorner")
			u.CornerRadius = UDim.new(0, 6)
			u.Parent = f

			const t = InstanceNew("TextLabel")
			t.Name = sessionInstanceName("UserButtonArgPromptTitle")
			t.Size = UDim2.new(1,-20,0,30)
			t.Position = UDim2.new(0,10,0,10)
			t.BackgroundTransparency = 1
			t.Text = "Arguments for: "..cmdName
			t.TextColor3 = Color3.fromRGB(255,255,255)
			t.Font = Enum.Font.GothamBold
			t.TextSize = 16
			t.TextWrapped = true
			t.Parent = f

			const tb = InstanceNew("TextBox")
			tb.Name = sessionInstanceName("UserButtonArgPromptInput")
			tb.Size = UDim2.new(1,-20,0,30)
			tb.Position = UDim2.new(0,10,0,50)
			tb.BackgroundColor3 = Color3.fromRGB(50,50,50)
			tb.TextColor3 = Color3.fromRGB(255,255,255)
			tb.PlaceholderText = "Type arguments here"
			tb.Text=""
			tb.TextSize = 16
			tb.Font = Enum.Font.Gotham
			tb.ClearTextOnFocus = false
			tb.Parent = f

			const s = InstanceNew("TextButton")
			s.Name = sessionInstanceName("UserButtonArgPromptSubmit")
			s.Size = UDim2.new(0.5,-15,0,30)
			s.Position = UDim2.new(0,10,1,-40)
			s.BackgroundColor3 = Color3.fromRGB(0,170,255)
			s.Text = "Submit"
			s.TextColor3 = Color3.fromRGB(255,255,255)
			s.Font = Enum.Font.GothamBold
			s.TextSize = 14
			s.Parent = f

			const c = InstanceNew("TextButton")
			c.Name = sessionInstanceName("UserButtonArgPromptCancel")
			c.Size = UDim2.new(0.5,-15,0,30)
			c.Position = UDim2.new(0.5,5,1,-40)
			c.BackgroundColor3 = Color3.fromRGB(255,0,0)
			c.Text = "Cancel"
			c.TextColor3 = Color3.fromRGB(255,255,255)
			c.Font = Enum.Font.GothamBold
			c.TextSize = 14
			c.Parent = f

			MouseButtonFix(s, function()
				cb(tb.Text)
				ActivePrompts[cmdName] = nil
				gui:Destroy()
			end)
			MouseButtonFix(c, function()
				ActivePrompts[cmdName] = nil
				gui:Destroy()
			end)
			NAgui.draggerV2(f)
		end

		const renderButtons = {}
		local total = 0
		for id, data in NAUserButtons do
			if type(id) == "number" and type(data) == "table" then
				renderButtons[id] = data
				total += 1
			end
		end
		if type(NAPluginUserButtons) == "table" then
			const pluginKeys = {}
			for key in NAPluginUserButtons do
				Insert(pluginKeys, key)
			end
			table.sort(pluginKeys)
			local pluginId = -1
			for _, key in pluginKeys do
				const bucket = NAPluginUserButtons[key]
				const items = type(bucket) == "table" and bucket.items or nil
				if type(items) == "table" then
					for _, data in items do
						if type(data) == "table" then
							renderButtons[pluginId] = data
							total += 1
							pluginId -= 1
						end
					end
				end
			end
		end
		const totalW  = total * 110
		const screenWidth = math.max(screenGui.AbsoluteSize.X, 1)
		const startX  = 0.5 - (totalW/2)/screenWidth
		const spacing = 110
		const ON = Color3.fromRGB(0,170,0)

		const function pointInsideGui(gui, point)
			if not (gui and gui.AbsolutePosition) then return false end
			const pos = gui.AbsolutePosition
			const size = gui.AbsoluteSize
			return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
		end

		local idx = 0
		for id, data in renderButtons do
			if type(id) == "number" and type(data) == "table" then

				const btn = InstanceNew("TextButton")
				btn.Name                 = sessionInstanceName("UserButton_"..tostring(id))
				if NAmanage and type(NAmanage.SetAttr) == "function" then
					pcall(NAmanage.SetAttr, btn, "UserButtonId", id)
				end
				btn.Text                 = data.Label or ("Button "..id)
				btn.Size                 = UDim2.new(0,60, 0,60)
				btn.AnchorPoint          = Vector2.new(0.5,1)
				btn.Position             = data.Pos and UDim2.new(data.Pos[1], data.Pos[2], data.Pos[3], data.Pos[4]) or UDim2.new(startX + (spacing*idx)/screenWidth, 0, 0.9, 0)
				btn.Parent               = screenGui
				btn.BackgroundColor3     = Color3.fromRGB(0,0,0)
				btn.TextColor3           = Color3.fromRGB(255,255,255)
				btn.TextScaled           = true
				btn.Font                 = Enum.Font.GothamBold
				btn.BorderSizePixel      = 0
				btn.ZIndex               = 9999
				btn.AutoButtonColor      = true
				btn.BackgroundTransparency = 0
				btn.TextTransparency       = 0

				const btnCorner = InstanceNew("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 6)
				btnCorner.Parent       = btn

				const baseBgColor = NAmanage.UserButtonColorFromTable(data.BgColor, Color3.fromRGB(0,0,0))
				btn.BackgroundColor3 = baseBgColor

				UserButtonGuiMap[id] = btn

				local dragStart = udim2ToArray(btn.Position)
				if not data.Locked then
					NAgui.draggerV2(btn)
				end

				btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragStart = udim2ToArray(btn.Position)
					end
				end)

				btn.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						const p = btn.Position
						const newPos = {p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset}
						const moved = positionsChanged(dragStart or newPos, newPos)
						data.Pos = newPos
						if data.PluginButton ~= true then
							NAmanage.UserButtonsSave("update position")
						end
						if moved and not data.Locked and data.PluginButton ~= true then
							NAmanage.UserButtons_CheckCombine(id, btn)
						end
					end
				end)

				const isGroup = data.Type == "group"
				const isHidden = (data.Hidden) and true or false
				const isInteractable = not (data.Interactable == false)

				if isGroup then
					const children = (type(data.Children) == "table") and data.Children or {}
					const label = tostring(data.Label or ("Group "..id))
					if #children > 0 then
						btn.Text = ("%s (%d)"):format(label, #children)
					else
						btn.Text = label
					end
					const childHeight = 32
					const mode = (data.GroupMode == "side") and "side" or "dropdown"

					const function openDropdown()
						if #children == 0 then
							DoNotif("Add buttons to this group before opening it", 2)
							return
						end

						closeAllDropdowns()
						const container = InstanceNew("ScrollingFrame")
						container.Name = sessionInstanceName("UserButtonDropdown_"..tostring(id))
						container.BackgroundColor3 = Color3.fromRGB(18,18,22)
						container.BackgroundTransparency = 0.1
						container.BorderSizePixel = 0
						container.ZIndex = 10000
						container.ClipsDescendants = true
						container.ScrollingDirection = Enum.ScrollingDirection.Y
						container.VerticalScrollBarInset = Enum.ScrollBarInset.Always
						container.ScrollBarThickness = 5
						container.Parent = screenGui

						const layout = InstanceNew("UIListLayout")
						layout.SortOrder = Enum.SortOrder.LayoutOrder
						layout.Padding = UDim.new(0, 6)
						layout.FillDirection = Enum.FillDirection.Vertical
						layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
						layout.VerticalAlignment = Enum.VerticalAlignment.Top
						layout.Parent = container

						const pad = InstanceNew("UIPadding", container)
						pad.PaddingTop = UDim.new(0, 6)
						pad.PaddingBottom = UDim.new(0, 6)
						pad.PaddingLeft = UDim.new(0, 6)
						pad.PaddingRight = UDim.new(0, 6)

						const dropCorner = InstanceNew("UICorner")
						dropCorner.CornerRadius = UDim.new(0, 6)
						dropCorner.Parent = container

						const dropStroke = InstanceNew("UIStroke")
						dropStroke.Thickness = 1
						dropStroke.Color = NAUISTROKER or Color3.fromRGB(148,93,255)
						dropStroke.Transparency = 0.15
						dropStroke.Parent = container
						NAgui.RegisterColoredStroke(dropStroke)

						const cam = Services.Workspace.CurrentCamera
						const vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
						const margin = 8
						const dropWidth = math.max(btn.AbsoluteSize.X + 40, 140)
						const maxHeight = math.max(120, (vp.Y - margin * 2) * 0.8)
						const maxRows = math.max(1, math.floor((maxHeight - 12) / (childHeight + 6)))
						const visibleCount = math.min(#children, maxRows)
						const dropHeight = (visibleCount * (childHeight + 6)) + 12
						const finalHeight = math.min(dropHeight, maxHeight)
						local posUDim, anchor = placeGroupContainer(mode, btn, Vector2.new(dropWidth, finalHeight))
						container.AnchorPoint = anchor
						container.Position = posUDim
						container.Size = UDim2.new(0, dropWidth, 0, finalHeight)

						const function refreshCanvas()
							const content = layout.AbsoluteContentSize
							const top = pad.PaddingTop.Offset
							const bottom = pad.PaddingBottom.Offset
							container.CanvasSize = UDim2.new(0, 0, 0, content.Y + top + bottom)
							container.ScrollBarThickness = (content.Y + top + bottom > finalHeight) and 5 or 0
						end
						layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshCanvas)
						refreshCanvas()

						Insert(UserButtonGuiList, container)

						for childIndex, child in children do
							const cBtn = InstanceNew("TextButton")
							cBtn.Name = sessionInstanceName("UserButtonChild_"..tostring(id).."_"..tostring(childIndex))
							if NAmanage and type(NAmanage.SetAttr) == "function" then
								pcall(NAmanage.SetAttr, cBtn, "UserButtonId", id)
								pcall(NAmanage.SetAttr, cBtn, "UserButtonChildIndex", childIndex)
							end
							cBtn.Size = UDim2.new(1, 0, 0, childHeight)
							const childBaseBg = NAmanage.UserButtonColorFromTable(child.BgColor, Color3.fromRGB(0,0,0))
							cBtn.BackgroundColor3 = childBaseBg
							cBtn.TextColor3 = NAmanage.UserButtonColorFromTable(child.TextColor, Color3.fromRGB(255,255,255))
							cBtn.TextScaled = false
							cBtn.Font = Enum.Font.GothamBold
							cBtn.TextSize = 14
							cBtn.Text = tostring(child.Label or ("Action "..childIndex))
							cBtn.ZIndex = container.ZIndex + 1
							cBtn.AutoButtonColor = true
							cBtn.BorderSizePixel = 0
							cBtn.Parent = container

							const cbCorner = InstanceNew("UICorner")
							cbCorner.CornerRadius = UDim.new(0, 6)
							cbCorner.Parent = cBtn

							const childKey = originalIO.userButtonChildKey(id, childIndex)
							SavedArgs[childKey] = child.Args or SavedArgs[childKey] or {}
							local childToggled = childKey and UserButtonToggleState[childKey] == true or false
							local childSaveEnabled = child.RunMode == "S"
							if child.ArgsSaved == nil and type(child.Args) == "table" then
								child.ArgsSaved = true
							end
							const childCmd1 = child.Cmd1
							const childCd1 = childCmd1 and (cmds.Commands[childCmd1:lower()] or cmds.Aliases[childCmd1:lower()])
							const childNeedsArgs = childCd1 and childCd1[3]

							if not child.Cmd2 and childKey then
								UserButtonToggleState[childKey] = nil
								childToggled = false
							elseif child.Cmd2 then
								cBtn.BackgroundColor3 = childToggled and ON or childBaseBg
							end

							if childNeedsArgs then
								const childToggleSize = math.max(14, math.min(tSize, childHeight - 6))
								const saveToggle = InstanceNew("TextButton")
								saveToggle.Name                   = sessionInstanceName("UserButtonChildSaveToggle_"..tostring(id).."_"..tostring(childIndex))
								saveToggle.Size                   = UDim2.new(0, childToggleSize, 0, childToggleSize)
								saveToggle.AnchorPoint            = Vector2.new(1, 0)
								saveToggle.Position               = UDim2.new(1, -4, 0, 4)
								saveToggle.BackgroundColor3       = Color3.fromRGB(50,50,50)
								saveToggle.TextColor3             = Color3.fromRGB(255,255,255)
								saveToggle.TextScaled             = true
								saveToggle.Font                   = Enum.Font.Gotham
								saveToggle.Text                   = childSaveEnabled and "S" or "N"
								saveToggle.ZIndex                 = cBtn.ZIndex + 1
								saveToggle.BackgroundTransparency = 0
								saveToggle.TextTransparency       = 0
								saveToggle.Parent                 = cBtn

								const stCorner = InstanceNew("UICorner")
								stCorner.CornerRadius = UDim.new(0, 6)
								stCorner.Parent       = saveToggle

								MouseButtonFix(saveToggle, function()
									childSaveEnabled = not childSaveEnabled
									saveToggle.Text = childSaveEnabled and "S" or "N"
									child.RunMode = childSaveEnabled and "S" or "N"
									NAmanage.UserButtonsSave("group child save toggle")
								end)
							end

							const function runChild(args)
								const toRun = (not childToggled or not child.Cmd2) and child.Cmd1 or child.Cmd2
								if not toRun then return end
								const arr = {toRun}
								if args then for _, v in args do Insert(arr, v) end end
								cmd.run(arr)
								if child.Cmd2 then
									childToggled = not childToggled
									if childKey then
										UserButtonToggleState[childKey] = childToggled or nil
									end
									cBtn.BackgroundColor3 = childToggled and ON or childBaseBg
								end
							end

							MouseButtonFix(cBtn, function()
								const now = (not childToggled or not child.Cmd2) and child.Cmd1 or child.Cmd2
								if not now then
									return
								end
								const nd = cmds.Commands[now:lower()] or cmds.Aliases[now:lower()]
								const needsArgs = nd and nd[3]
								if needsArgs then
									if childSaveEnabled then
										if child.ArgsSaved then
											runChild(child.Args)
										else
											if ActivePrompts[now] then return end
											ActivePrompts[now] = true
											ButtonInputPrompt(now, function(input)
												ActivePrompts[now] = nil
												const parsed = ParseArguments(input)
												if parsed then
													SavedArgs[childKey] = parsed
													child.Args = parsed
													child.ArgsSaved = true
													NAmanage.UserButtonsSave("group child args")
													runChild(parsed)
												elseif type(input) == "string" then
													SavedArgs[childKey] = {}
													child.Args = {}
													child.ArgsSaved = true
													NAmanage.UserButtonsSave("group child args empty")
													runChild(nil)
												else
													runChild(nil)
												end
											end)
										end
									else
										if ActivePrompts[now] then return end
										ActivePrompts[now] = true
										ButtonInputPrompt(now, function(input)
											ActivePrompts[now] = nil
											const parsed = ParseArguments(input)
											if parsed then
												SavedArgs[childKey] = parsed
												child.Args = parsed
												child.ArgsSaved = true
												NAmanage.UserButtonsSave("group child args")
												runChild(parsed)
											else
												runChild(nil)
											end
										end)
									end
								else
									runChild(nil)
								end
							end)
						end

						const conn = UIS.InputBegan:Connect(function(input, gpe)
							if gpe then return end
							if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
								const posNow = __lt.cm("UserInputService", "GetMouseLocation")
								if not (pointInsideGui(container, posNow) or pointInsideGui(btn, posNow)) then
									clearDropdownEntry(id)
								end
							end
						end)

						activeDropdowns[id] = {
							container = container,
							conn = conn,
							btn = btn,
							mode = mode,
							posConn = btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
								updateDropdownPosition(id)
							end),
							sizeConn = btn:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
								updateDropdownPosition(id)
							end),
							close = function()
								if conn then conn:Disconnect() end
								if activeDropdowns[id] and activeDropdowns[id].posConn then activeDropdowns[id].posConn:Disconnect() end
								if activeDropdowns[id] and activeDropdowns[id].sizeConn then activeDropdowns[id].sizeConn:Disconnect() end
								if container then container:Destroy() end
								activeDropdowns[id] = nil
							end
						}
						UserButtonDropdowns[id] = { container = container, conn = conn }
						updateDropdownPosition(id)
					end

					MouseButtonFix(btn, function()
						if activeDropdowns[id] then
							clearDropdownEntry(id)
						else
							openDropdown()
						end
					end)
				else
					local toggled     = UserButtonToggleState[id] == true
					local saveEnabled = data.RunMode == "S"
					SavedArgs[id]     = data.Args or {}
					if data.ArgsSaved == nil and type(data.Args) == "table" then
						data.ArgsSaved = true
					end

					const cmd1      = data.Cmd1
					const cd1       = cmd1 and (cmds.Commands[cmd1:lower()] or cmds.Aliases[cmd1:lower()])
					const needsArgs = cd1 and cd1[3]

					if not data.Cmd2 then
						UserButtonToggleState[id] = nil
						toggled = false
						btn.BackgroundColor3 = baseBgColor
					else
						btn.BackgroundColor3 = toggled and ON or baseBgColor
					end

					if needsArgs then
						const saveToggle = InstanceNew("TextButton")
						saveToggle.Name                   = sessionInstanceName("UserButtonSaveToggle_"..tostring(id))
						saveToggle.Size                   = UDim2.new(0,tSize,0,tSize)
						saveToggle.AnchorPoint            = Vector2.new(1,1)
						saveToggle.Position               = UDim2.new(1,0,0,0)
						saveToggle.BackgroundColor3       = Color3.fromRGB(50,50,50)
						saveToggle.TextColor3             = Color3.fromRGB(255,255,255)
						saveToggle.TextScaled             = true
						saveToggle.Font                   = Enum.Font.Gotham
						saveToggle.Text                   = saveEnabled and "S" or "N"
						saveToggle.ZIndex                 = 10000
						saveToggle.BackgroundTransparency = 0
						saveToggle.TextTransparency       = 0
						saveToggle.Parent                 = btn

						const stCorner = InstanceNew("UICorner")
						stCorner.CornerRadius = UDim.new(0, 6)
						stCorner.Parent       = saveToggle

						MouseButtonFix(saveToggle, function()
							saveEnabled = not saveEnabled
							saveToggle.Text = saveEnabled and "S" or "N"
							data.RunMode = saveEnabled and "S" or "N"
							if data.PluginButton ~= true then
								NAmanage.UserButtonsSave("button save toggle")
							end
						end)
					end

					const function runCmd(args)
						const toRun = (not toggled or not data.Cmd2) and data.Cmd1 or data.Cmd2
						if not toRun then return end
						const arr   = {toRun}
						if args then for _,v in args do Insert(arr, v) end end
						cmd.run(arr)
						if data.Cmd2 then
							toggled = not toggled
							UserButtonToggleState[id] = toggled or nil
							btn.BackgroundColor3 = toggled and ON or baseBgColor
						end
					end

					MouseButtonFix(btn, function()
						const now     = (not toggled or not data.Cmd2) and data.Cmd1 or data.Cmd2
						if not now then
							return
						end
						const nd      = cmds.Commands[now:lower()] or cmds.Aliases[now:lower()]
						const na      = nd and nd[3]
						if na then
							if saveEnabled and data.ArgsSaved then
								runCmd(data.Args)
							else
								if ActivePrompts[now] then return end
								ActivePrompts[now] = true
								ButtonInputPrompt(now, function(input)
									ActivePrompts[now] = nil
									const parsed = ParseArguments(input)
									if parsed then
										SavedArgs[id] = parsed
										data.Args     = parsed
										data.ArgsSaved = true
										if data.PluginButton ~= true then
											NAmanage.UserButtonsSave("button args")
										end
										runCmd(parsed)
									elseif saveEnabled and type(input) == "string" then
										SavedArgs[id] = {}
										data.Args = {}
										data.ArgsSaved = true
										if data.PluginButton ~= true then
											NAmanage.UserButtonsSave("button args empty")
										end
										runCmd(nil)
									else
										runCmd(nil)
									end
								end)
							end
						else
							runCmd(nil)
						end
					end)
				end

				if not isInteractable then
					btn.Visible = false
				elseif isHidden then
					btn.Visible = true
					btn.BackgroundTransparency = 1
					btn.TextTransparency = 1
					if btn:FindFirstChildOfClass("TextButton") then
						for _, child in btn:GetChildren() do
							if child:IsA("TextButton") then
								child.BackgroundTransparency = 1
								child.TextTransparency = 1
							end
						end
					end
				else
					btn.Visible = true
				end

				if IsOnPC then
				end

				Insert(UserButtonGuiList, btn)
				idx = idx + 1
			end
		end

	end)

	NAmanage._renderUserButtonsRunning = nil

	if not success then
		error(err)
	end
	return true
end

NAmanage.UserButtonColorFromTable = function(t, defaultColor)
	if typeof(t) == "Color3" then
		return t
	end
	if type(t) ~= "table" then
		return defaultColor
	end
	const r = t.R or t[1]
	const g = t.G or t[2]
	const b = t.B or t[3]
	if r == nil or g == nil or b == nil then
		return defaultColor
	end
	return Color3.fromRGB(tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0)
end

NAmanage.UserButtonColorToTable = function(c)
	return {
		math.floor(c.R * 255 + 0.5),
		math.floor(c.G * 255 + 0.5),
		math.floor(c.B * 255 + 0.5),
	}
end

NAmanage.ApplyUserButtonStyles = function()
	local ok, err = pcall(function()
		for _, btn in UserButtonGuiList do
			if typeof(btn) == "Instance" and btn:IsA("TextButton") then
				local id = nil
				if NAmanage and type(NAmanage.GetAttr) == "function" then
					id = tonumber(NAmanage.GetAttr(btn, "UserButtonId"))
				end
				if not id then
					const idStr = btn.Name:match("^NAUserButton_(%d+)$")
					id = idStr and tonumber(idStr) or nil
				end
				if id then
					const data = NAUserButtons[id]
					if type(data) == "table" then
						const width = tonumber(data.Width)
						const height = tonumber(data.Height)
						if width or height then
							const currentSize = btn.Size
							const w = width or currentSize.X.Offset
							const h = height or currentSize.Y.Offset
							btn.Size = UDim2.new(0, w, 0, h)
						end

						if data.BgColor then
							const bg = NAmanage.UserButtonColorFromTable(data.BgColor, btn.BackgroundColor3)
							btn.BackgroundColor3 = bg
						end

						if data.TextColor then
							const tc = NAmanage.UserButtonColorFromTable(data.TextColor, btn.TextColor3)
							btn.TextColor3 = tc
						end

						if data.CornerRadius ~= nil then
							const radius = tonumber(data.CornerRadius)
							if radius and radius >= 0 and radius <= 1 then
								const corner = btn:FindFirstChildOfClass("UICorner")
								if corner then
									corner.CornerRadius = UDim.new(radius, 0)
								end
							end
						end
					end
				end
			end
		end
	end)
	if not ok then
		warn("[UserButtons] style apply failed: "..tostring(err))
	end
end

do
	const _renderUserButtons = NAmanage.RenderUserButtons
	NAmanage.RenderUserButtons = function(...)
		local ok, result = pcall(_renderUserButtons, ...)
		if ok then
			if type(NAmanage.ApplyUserButtonStyles) == "function" then
				pcall(NAmanage.ApplyUserButtonStyles)
			end
			if type(NAmanage.RefreshUserButtonEditor) == "function" then
				pcall(NAmanage.RefreshUserButtonEditor, { preserveSelection = true })
			end
			return result
		else
			error(result)
		end
	end
end

lp=Services.Players.LocalPlayer
NAStuff.ChatLocalIdentity = NAStuff.ChatLocalIdentity or {}
if lp then
	if type(NAStuff.ChatLocalIdentity.realName) ~= "string" or NAStuff.ChatLocalIdentity.realName == "" then
		NAStuff.ChatLocalIdentity.realName = tostring(lp.Name or "")
	end
	if type(NAStuff.ChatLocalIdentity.realUserId) ~= "number" or NAStuff.ChatLocalIdentity.realUserId <= 0 then
		const uid = tonumber(lp.UserId)
		if uid and uid > 0 then
			NAStuff.ChatLocalIdentity.realUserId = uid
		end
	end
end

--[[ LIB FUNCTIONS ]]--
chatmsgshooks = chatmsgshooks or {}
Playerchats = Playerchats or {}
oldChat = false--TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService and __lt.cm("ReplicatedStorage", "FindFirstChild", "DefaultChatSystemChatEvents") and  ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

if oldChat then
	NAlib.LocalPlayerChat=function(...)
		const args={...}
		if args[2] and args[2]~="All" then
			Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..args[2].." "..args[1] or "","All")
		else
			Services.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(args[1] or "","All")
		end
	end
else
	local RBXGeneral = nil

	const function getTextChannelsContainer()
		if typeof(Services.TextChatService) ~= "Instance" then
			return nil
		end
		local container
		local ok = pcall(function()
			container = Services.TextChatService:FindFirstChild("TextChannels")
		end)
		if ok and typeof(container) == "Instance" then
			return container
		end
		return nil
	end

	const function getTextChannels()
		const container = getTextChannelsContainer()
		const channels = {}
		local children

		if container then
			local ok, result = pcall(container.GetChildren, container)
			if ok then
				children = result
			end
		else
			local ok, result = pcall(Services.TextChatService.GetChildren, Services.TextChatService)
			if ok then
				children = result
			end
		end

		if children then
			for i = 1, #children do
				const inst = children[i]
				if inst and inst:IsA("TextChannel") then
					channels[#channels + 1] = inst
				end
			end
		end

		return channels, container
	end

	const function getTextSource(channel, playerName)
		if not channel or type(playerName) ~= "string" then
			return nil
		end
		const src = channel:FindFirstChild(playerName)
		if src and src:IsA("TextSource") then
			return src
		end
		return nil
	end

	const function getStableLocalUserId()
		const cached = NAStuff and NAStuff.ChatLocalIdentity and tonumber(NAStuff.ChatLocalIdentity.realUserId)
		if cached and cached > 0 then
			return cached
		end
		const uid = lp and tonumber(lp.UserId)
		if uid and uid > 0 then
			return uid
		end
		return nil
	end

	const function getLocalNameCandidates()
		const out = {}
		const seen = {}
		const function add(value)
			const v = tostring(value or "")
			if v ~= "" and not seen[v] then
				seen[v] = true
				out[#out + 1] = v
			end
		end
		add(lp and lp.Name)
		add(NAStuff and NAStuff.ChatLocalIdentity and NAStuff.ChatLocalIdentity.realName)
		return out
	end

	const function getLocalTextSource(channel)
		if not channel then
			return nil
		end

		const candidates = getLocalNameCandidates()
		for i = 1, #candidates do
			const src = getTextSource(channel, candidates[i])
			if src then
				return src
			end
		end

		const stableUid = getStableLocalUserId()
		if stableUid then
			const children = channel:GetChildren()
			for i = 1, #children do
				const child = children[i]
				if child and child:IsA("TextSource") and tonumber(child.UserId) == stableUid then
					return child
				end
			end
		end

		const children = channel:GetChildren()
		for i = 1, #children do
			const child = children[i]
			if child and child:IsA("TextSource") and child.CanSend == true then
				return child
			end
		end

		return nil
	end

	const function localCanSend(channel)
		const src = getLocalTextSource(channel)
		return src and src.CanSend
	end

	const function resolveGeneralChannel()
		local channels, container = getTextChannels()

		if Services.TextChatService.CreateDefaultTextChannels and container then
			const ch = container:FindFirstChild("RBXGeneral")
			if ch and ch:IsA("TextChannel") and localCanSend(ch) then
				return ch
			end
		end

		for i = 1, #channels do
			const ch = channels[i]
			if ch and ch:IsA("TextChannel") and ch.Name == "RBXGeneral" and localCanSend(ch) then
				return ch
			end
		end

		for i = 1, #channels do
			const ch = channels[i]
			if localCanSend(ch) then
				return ch
			end
		end

		return nil
	end

	const function ensureGeneralChannel()
		if RBXGeneral and RBXGeneral.Parent ~= nil and localCanSend(RBXGeneral) then
			return RBXGeneral
		end
		RBXGeneral = resolveGeneralChannel()
		return RBXGeneral
	end

	const function findWhisperChannel(targetName)
		if type(targetName) ~= "string" or targetName == "" then
			return nil
		end
		const channels = getTextChannels()
		for i = 1, #channels do
			const ch = channels[i]
			if ch and ch:IsA("TextChannel") and Find(ch.Name, "RBXWhisper:") then
				if ch:FindFirstChild(targetName) then
					const src = getLocalTextSource(ch)
					if src and src.CanSend ~= false then
						return ch
					end
				end
			end
		end
		return nil
	end

	NACaller({ context = "TextChat / Channel Resolver" }, function()
		RBXGeneral = resolveGeneralChannel()

		NAlib.LocalPlayerChat=function(...)
			const args={...}
			const message = tostring(args[1] or "")
			local target = args[2]
			if target ~= nil and target ~= "All" then
				target = tostring(target)
			end

			local general = ensureGeneralChannel()
			if not general then
				local channels, container = getTextChannels()
				if container then
					const fallback = container:FindFirstChild("RBXGeneral")
					if fallback and fallback:IsA("TextChannel") then
						general = fallback
					end
				end
				if not general and channels and channels[1] and channels[1]:IsA("TextChannel") then
					general = channels[1]
				end
				if not general then
					pcall(function()
						DebugNotif("unable to get the chat system for the game", 3)
					end)
					return nil
				end
			end

			local sendto = general
			if target ~= nil and target ~= "All" then
				const cached = Playerchats[target]
				if cached and cached.Parent ~= nil then
					const src = getLocalTextSource(cached)
					if src and src.CanSend ~= false then
						sendto = cached
					else
						Playerchats[target] = nil
					end
				end

				if sendto == general then
					const whisper = findWhisperChannel(target)
					if whisper then
						Playerchats[target] = whisper
						sendto = whisper
					else
						const entry = { msg = message, ts = tick() }
						chatmsgshooks[target] = entry
						SpawnCall(function()
							pcall(function()
								general:SendAsync("/w @"..tostring(target))
							end)
						end)
						Delay(15, function()
							if chatmsgshooks[target] == entry then
								chatmsgshooks[target] = nil
							end
						end)
						return "Hooking"
					end
				end
			end

			const okSend = pcall(function()
				sendto:SendAsync(message or "")
			end)
			if not okSend and sendto ~= general then
				pcall(function()
					general:SendAsync(message or "")
				end)
			end

		end
	end)

	const textChannelsContainer = getTextChannelsContainer()
	if textChannelsContainer then
		NAmanage.childAdd(textChannelsContainer, function(v)
			if  v:IsA("TextChannel") and Find(v.Name,"RBXWhisper:") then
				Wait(0.25)
				for target, entry in chatmsgshooks do
					if type(target) == "string" and type(entry) == "table" and v:FindFirstChild(target) then
						const src = getLocalTextSource(v)
						if src and src.CanSend ~= false then
							Playerchats[target] = v
							chatmsgshooks[target] = nil
							pcall(function()
								v:SendAsync(entry.msg or "")
							end)
						end
					end
				end
			end
		end, function(v)
			return v and v:IsA("TextChannel") and Find(v.Name,"RBXWhisper:")
		end)
	end
end

NAlib.lpchat=NAlib.LocalPlayerChat

NAlib.find=function(t,v)	--mmmmmm
	for i,e in t do
		if i==v or e==v then
			return i
		end
	end
	return nil
end

NAlib.parseText = function(text, watch, rPlr)
	const function stripRichText(str)
		if type(str) ~= "string" then
			return ""
		end

		local cleaned = str
		repeat
			const before = cleaned
			cleaned = cleaned:gsub("^%s*<(%w+)[^>]->(.-)</%1>%s*$", "%2")
		until cleaned == before

		cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
		cleaned = cleaned
			:gsub("&lt;", "<")
			:gsub("&gt;", ">")
			:gsub("&amp;", "&")
			:gsub("&quot;", "\"")
			:gsub("&#x27;", "'")
			:gsub("&#x60;", "`")
			:gsub("&#59;", ";")
			:gsub("&#x3b;", ";")

		return cleaned
	end

	const function FIIIX(str)
		const chatPrefix = str:match("^/(%a+)%s")
		if chatPrefix then
			str = str:gsub("^/%a+%s*", "")
		end
		return str
	end

	if not text then return nil end
	text = stripRichText(text)
	if text == "" then return nil end

	local prefix
	if rPlr then
		if isRelAdmin(rPlr) and isRelAdmin(Services.Players.LocalPlayer) then
			return nil
		elseif not isRelAdmin(rPlr) then
			prefix = ";"
		else
			prefix = watch
		end
		watch = prefix
	else
		prefix = watch
	end

	text = FIIIX(text)
	if text == "" then return nil end

	if text:sub(1, #prefix) ~= prefix then
		return nil
	end

	text = text:sub(#prefix + 1)

	const commands = {}
	local position = 1
	const textLength = #text

	while position <= textLength do
		const nextSlash = text:find("\\", position, true)
		const segment = nextSlash and text:sub(position, nextSlash - 1) or text:sub(position)
		const trimmed = segment:gsub("^%s+", ""):gsub("%s+$", "")
		if #trimmed > 0 then
			const parsed = {}
			for arg in trimmed:gmatch("[^ ]+") do
				Insert(parsed, arg)
			end
			if #parsed > 0 then
				const cmdName = parsed[1]:lower()
				if LoadstringCommandAliases[cmdName] then
					const commandStart = (segment:find(parsed[1], 1, true) or 1) + #parsed[1]
					const afterCommand = segment:sub(commandStart + 1)
					local remainder = afterCommand:gsub("^%s+", "")
					if nextSlash then
						remainder = remainder.."\\"..text:sub(nextSlash + 1)
					end
					Insert(commands, {parsed[1], remainder})
					break
				end
				Insert(commands, parsed)
			end
		end
		if not nextSlash then
			break
		end
		position = nextSlash + 1
	end

	return commands
end

NAlib.parseCommand = function(text, rPlr)
	wrap(function()
		const prefix = rPlr and (isRelAdmin(rPlr) and not isRelAdmin(Services.Players.LocalPlayer) and ";" or nil) or opt.prefix
		if not prefix then return end
		const commands = NAlib.parseText(text, prefix, rPlr)
		if not commands then return end
		for _, parsed in commands do
			const args = {}
			for _, arg in parsed do
				Insert(args, arg)
			end
			cmd.run(args)
		end
	end)
end

--prepare for annoying and unnecessary tool grip math
rad=math.rad
clamp=math.clamp
tan=math.tan

NAmanage.CmdBar2ApplySize = function(opts)
	opts = opts or {}
	const width = NAmanage.CmdBar2ClampValue(opts.width or NAStuff.CmdBar2Width, NAStuff.CmdBar2.minWidth, NAStuff.CmdBar2.maxWidth, NAStuff.CmdBar2.defaultWidth)
	const height = NAmanage.CmdBar2ClampValue(opts.height or NAStuff.CmdBar2Height, NAStuff.CmdBar2.minHeight, NAStuff.CmdBar2.maxHeight, NAStuff.CmdBar2.defaultHeight)
	const previousBase = NAmanage._cb2BaseSize
	const previousWidth = (typeof(previousBase) == "Vector2" and previousBase.X) or nil
	const prevDefaultOffset = previousWidth and -math.floor(previousWidth / 2 + 0.5) or nil
	const newDefaultOffset = -math.floor(width / 2 + 0.5)

	NAStuff.CmdBar2Width = width
	NAStuff.CmdBar2Height = height

	NAmanage._cb2BaseSize = Vector2.new(width, height)
	NAmanage._cb2sz = UDim2.new(0, width, 0, height)

	if prevDefaultOffset and NAmanage._cb2p and NAmanage._cb2p.X.Scale == 0.5 and math.floor(NAmanage._cb2p.X.Offset + 0.5) == prevDefaultOffset then
		const pos = NAmanage._cb2p
		NAmanage._cb2p = UDim2.new(pos.X.Scale, newDefaultOffset, pos.Y.Scale, pos.Y.Offset)
	end

	const frame = NAmanage._cb2f
	if frame then
		if prevDefaultOffset and frame.Position.X.Scale == 0.5 and math.floor(frame.Position.X.Offset + 0.5) == prevDefaultOffset then
			frame.Position = UDim2.new(frame.Position.X.Scale, newDefaultOffset, frame.Position.Y.Scale, frame.Position.Y.Offset)
		end
		if NAmanage._cb2Min == true then
			frame.Size = UDim2.new(0, width, 0, 28)
		else
			frame.Size = NAmanage._cb2sz
		end
	end

	const body = NAmanage._cb2Body
	if body then
		const bodyHeight = NAmanage.CmdBar2ComputeBodyHeight(height)
		body.Size = UDim2.new(body.Size.X.Scale, body.Size.X.Offset, 0, bodyHeight)
	end

	if opts.syncUI ~= false and NAgui and NAgui.setSliderValue then
		NAgui.setSliderValue("cmdbar2 Width", width, { fire = false })
		NAgui.setSliderValue("cmdbar2 Height", height, { fire = false })
	end

	if opts.persist ~= false then
		pcall(NAmanage.NASettingsSet, "cmdbar2Width", width)
		pcall(NAmanage.NASettingsSet, "cmdbar2Height", height)
	end

	return width, height
end

--[[ COMMANDS ]]--

cmd.add({"cmdbar2","cbar2"},{"cmdbar2 (cbar2)","Opens a HD-Admin style cmdbar (black & white)"},function()
	local gui = NAmanage._cb2
	local fr = NAmanage._cb2f
	local bx = NAmanage._cb2bx
	const hist = NAmanage._cb2h or {}
	NAmanage._cb2h = hist
	const initialWidth = NAmanage.CmdBar2ClampValue(NAStuff.CmdBar2Width, NAStuff.CmdBar2.minWidth, NAStuff.CmdBar2.maxWidth, NAStuff.CmdBar2.defaultWidth)
	const initialHeight = NAmanage.CmdBar2ClampValue(NAStuff.CmdBar2Height, NAStuff.CmdBar2.minHeight, NAStuff.CmdBar2.maxHeight, NAStuff.CmdBar2.defaultHeight)

	const function tw(o,t,p)
		const ti = TweenInfo.new(t or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		const tr = __lt.cm("TweenService", "Create", o, ti, p)
		tr:Play()
		return tr
	end

	const function trim(s)
		s = tostring(s or "")
		s = GSub(s, "^%s+", "")
		s = GSub(s, "%s+$", "")
		return s
	end

	const function parse(s)
		s = trim(s)
		s = GSub(s, "^[;:/!]+%s*", "")
		if s == "" then return nil end

		if type(ParseArguments) == "function" then
			local ok, a = pcall(ParseArguments, s)
			if ok and type(a) == "table" and #a > 0 then
				return a
			end
		end

		local a, q, cur = {}, false, ""
		local i = 1
		while i <= #s do
			const ch = Sub(s, i, i)
			if ch == '"' then
				q = not q
			elseif not q and (ch == " " or ch == "\t" or ch == "\n" or ch == "\r") then
				if cur ~= "" then
					Insert(a, cur)
					cur = ""
				end
			else
				cur ..= ch
			end
			i += 1
		end
		if cur ~= "" then Insert(a, cur) end
		if #a == 0 then return nil end
		return a
	end

	const function run()
		if not bx then return end
		const s = trim(bx.Text)
		if s == "" then return end
		const a = parse(s)
		if not a then return end
		pcall(function() cmd.run(a) end)
	end

	const function getDefaultCmdBar2Position()
		const width = NAmanage.CmdBar2ClampValue(NAStuff.CmdBar2Width, NAStuff.CmdBar2.minWidth, NAStuff.CmdBar2.maxWidth, NAStuff.CmdBar2.defaultWidth)
		return UDim2.new(0.5, -math.floor(width / 2), 0, 70)
	end

	const function show(v)
		if not gui or not fr then return end
		gui.Enabled = v and true or false
		if v then
			fr.Visible = true
			fr.BackgroundTransparency = 1
			const p = NAmanage._cb2p or getDefaultCmdBar2Position()
			fr.Position = p
			tw(fr, 0.14, {BackgroundTransparency = 0})
		else
			NAmanage._cb2p = fr.Position
			const tr = tw(fr, 0.12, {BackgroundTransparency = 1})
			tr.Completed:Connect(function()
				if fr then fr.Visible = false end
			end)
		end
	end

	if gui and gui.Parent and fr and bx then
		show(not gui.Enabled)
		return
	end

	const o1 = Color3.fromRGB(0, 0, 0)
	const o2 = Color3.fromRGB(18, 18, 18)
	const o3 = Color3.fromRGB(28, 28, 28)
	const tx = Color3.fromRGB(245, 245, 245)
	const tx2 = Color3.fromRGB(210, 210, 210)
	const st1 = Color3.fromRGB(255, 255, 255)
	const st2 = Color3.fromRGB(60, 60, 60)

	gui = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(gui)

	fr = InstanceNew("Frame", gui)
	fr.Position = NAmanage._cb2p or getDefaultCmdBar2Position()
	fr.Size = UDim2.new(0, initialWidth, 0, initialHeight)
	fr.BackgroundColor3 = o2
	fr.BorderSizePixel = 0
	fr.Visible = true
	fr.ClipsDescendants = false

	const cr = InstanceNew("UICorner", fr)
	cr.CornerRadius = UDim.new(0, 6)

	const st = InstanceNew("UIStroke", fr)
	st.Thickness = 1
	st.Color = st2
	st.Transparency = 0.2

	const top = InstanceNew("Frame", fr)
	top.Position = UDim2.new(0, 0, 0, 0)
	top.Size = UDim2.new(1, 0, 0, 26)
	top.BackgroundColor3 = o1
	top.BorderSizePixel = 0

	const tcr = InstanceNew("UICorner", top)
	tcr.CornerRadius = UDim.new(0, 6)

	const tfix = InstanceNew("Frame", top)
	tfix.Position = UDim2.new(0, 0, 1, -6)
	tfix.Size = UDim2.new(1, 0, 0, 6)
	tfix.BackgroundColor3 = o1
	tfix.BorderSizePixel = 0

	const ttl = InstanceNew("TextLabel", top)
	ttl.BackgroundTransparency = 1
	ttl.Position = UDim2.new(0, 10, 0, 0)
	ttl.Size = UDim2.new(1, -120, 1, 0)
	ttl.Font = Enum.Font.SourceSansBold
	ttl.TextSize = 16
	ttl.TextXAlignment = Enum.TextXAlignment.Left
	ttl.TextColor3 = tx
	ttl.Text = "CMDBAR2"

	const mini = InstanceNew("TextButton", top)
	mini.BackgroundTransparency = 1
	mini.Position = UDim2.new(1, -68, 0, 0)
	mini.Size = UDim2.new(0, 28, 1, 0)
	mini.Font = Enum.Font.SourceSansBold
	mini.TextSize = 18
	mini.TextColor3 = tx2
	mini.Text = "-"
	mini.AutoButtonColor = false

	const cls = InstanceNew("TextButton", top)
	cls.BackgroundTransparency = 1
	cls.Position = UDim2.new(1, -36, 0, 0)
	cls.Size = UDim2.new(0, 36, 1, 0)
	cls.Font = Enum.Font.SourceSansBold
	cls.TextSize = 18
	cls.TextColor3 = tx2
	cls.Text = "X"
	cls.AutoButtonColor = false

	const body = InstanceNew("Frame", fr)
	body.Position = UDim2.new(0, 8, 0, 34)
	body.Size = UDim2.new(1, -16, 0, NAmanage.CmdBar2ComputeBodyHeight(initialHeight))
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0

	const ibg = InstanceNew("Frame", body)
	ibg.Position = UDim2.new(0, 0, 0, 0)
	ibg.Size = UDim2.new(1, -98, 1, 0)
	ibg.BackgroundColor3 = o3
	ibg.BorderSizePixel = 0

	const icr = InstanceNew("UICorner", ibg)
	icr.CornerRadius = UDim.new(0, 6)

	const ist = InstanceNew("UIStroke", ibg)
	ist.Thickness = 1
	ist.Color = st1
	ist.Transparency = 0.85

	bx = InstanceNew("TextBox", ibg)
	bx.BackgroundTransparency = 1
	bx.Position = UDim2.new(0, 10, 0, 0)
	bx.Size = UDim2.new(1, -20, 1, 0)
	bx.ClearTextOnFocus = false
	bx.Font = Enum.Font.Code
	bx.TextSize = 15
	bx.TextColor3 = tx
	bx.TextXAlignment = Enum.TextXAlignment.Left
	bx.PlaceholderText = ":cmd args"
	bx.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
	bx.Text = ""

	const exe = InstanceNew("TextButton", body)
	exe.Position = UDim2.new(1, -90, 0, 0)
	exe.Size = UDim2.new(0, 90, 1, 0)
	exe.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
	exe.BorderSizePixel = 0
	exe.Font = Enum.Font.SourceSansBold
	exe.TextSize = 16
	exe.TextColor3 = Color3.fromRGB(0, 0, 0)
	exe.Text = "EXECUTE"
	exe.AutoButtonColor = false

	const ecr = InstanceNew("UICorner", exe)
	ecr.CornerRadius = UDim.new(0, 6)

	const est = InstanceNew("UIStroke", exe)
	est.Thickness = 1
	est.Color = st1
	est.Transparency = 0.7

	NAgui.draggerV2(fr, top)

	local min = false
	NAmanage._cb2Min = false
	NAmanage._cb2 = gui
	NAmanage._cb2f = fr
	NAmanage._cb2bx = bx
	NAmanage._cb2Body = body
	NAmanage.CmdBar2ApplySize({ persist = false })

	const function setMin(v)
		min = v and true or false
		NAmanage._cb2Min = min
		if min then
			body.Visible = false
			tw(fr, 0.14, {Size = UDim2.new(NAmanage._cb2sz.X.Scale, NAmanage._cb2sz.X.Offset, 0, 28)})
		else
			body.Visible = true
			tw(fr, 0.14, {Size = NAmanage._cb2sz})
		end
	end

	MouseButtonFix(exe, function()
		run()
	end)

	MouseButtonFix(cls, function()
		show(false)
	end)

	MouseButtonFix(mini, function()
		setMin(not min)
	end)

	exe.MouseEnter:Connect(function()
		tw(exe, 0.08, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	exe.MouseLeave:Connect(function()
		tw(exe, 0.10, {BackgroundColor3 = Color3.fromRGB(235, 235, 235)})
	end)

	cls.MouseEnter:Connect(function()
		tw(cls, 0.08, {TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	cls.MouseLeave:Connect(function()
		tw(cls, 0.10, {TextColor3 = tx2})
	end)

	mini.MouseEnter:Connect(function()
		tw(mini, 0.08, {TextColor3 = Color3.fromRGB(255, 255, 255)})
	end)
	mini.MouseLeave:Connect(function()
		tw(mini, 0.10, {TextColor3 = tx2})
	end)

	show(true)
end)

cmd.add({"url"}, {"url <link>", "Run the script using URL"}, function(...)
	const args = {...}
	const link = Concat(args, " ")

	if not link or link == "" then
		return DoNotif("no link provided", 2)
	end

	local okRun, errRun = NAmanage.RunURL(link, "@NAUrlCommand")
	if not okRun then
		warn(errRun)
	end
end, true)

cmd.add({"loadstring", "ls", "lstring", "loads", "execute"}, {"loadstring <code> (ls, lstring, loads, execute)", "Run code using loadstring"}, function(...)
	const args = {...}
	const code = Concat(args, " ")

	if not code or code == "" then
		return DoNotif("no code provided", 2)
	end

	local runSource = NAmanage._loopDispatchDepth and NAmanage._loopDispatchDepth > 0 and NAmanage.RunLoopSource or NAmanage.RunSource
	local okRun, errRun = runSource(code, "@NALoadstringCommand")
	if not okRun then
		warn(errRun)
	end
end, true)


NAmanage.GetNoCooldownState = function()
	const host = _na_boot.hostEnv
	local state = type(host) == "table" and rawget(host, "__NA_NoCooldownState") or nil
	if type(state) ~= "table" then
		state = {
			enabled = false;
			seconds = 0;
			waitCapEnabled = false;
			waitCapSeconds = 0;
			hooks = {};
			failures = {};
			clockContexts = {};
			generation = 0;
		}
		if type(host) == "table" then
			pcall(rawset, host, "__NA_NoCooldownState", state)
		end
	end
	state.seconds = math.max(0, tonumber(state.seconds) or 0)
	state.waitCapEnabled = state.waitCapEnabled == true
	state.waitCapSeconds = math.max(0, tonumber(state.waitCapSeconds) or 0)
	state.hooks = type(state.hooks) == "table" and state.hooks or {}
	state.failures = type(state.failures) == "table" and state.failures or {}
	state.clockContexts = type(state.clockContexts) == "table" and state.clockContexts or {}
	state.generation = tonumber(state.generation) or 0
	return state
end

NAmanage.RestoreNoCooldownHooks = function()
	const state = NAmanage.GetNoCooldownState()
	const host = _na_boot.hostEnv
	const hook = type(host) == "table" and rawget(host, "hookfunction") or hookfunction
	if type(hook) ~= "function" then
		return false
	end

	local targets = {
		["wait"] = wait;
		["task.wait"] = task and task.wait;
		["delay"] = delay;
		["task.delay"] = task and task.delay;
		["tick"] = tick;
		["os.clock"] = os and os.clock;
	}

	for key, target in targets do
		local original = state.hooks[key]
		if type(target) == "function" and type(original) == "function" then
			pcall(hook, target, original)
		end
	end

	state.hooks = {}
	state.failures = {}
	state.installed = false
	return true
end

NAmanage.InstallNoCooldownHooks = function()
	local state = NAmanage.GetNoCooldownState()
	const host = _na_boot.hostEnv
	const hook = type(host) == "table" and rawget(host, "hookfunction") or hookfunction
	const callerCheck = type(host) == "table" and rawget(host, "checkcaller") or checkcaller
	const callingScript = type(host) == "table" and rawget(host, "getcallingscript") or getcallingscript
	const hookVersion = 5
	const CLOCK_JUMP = 1000000000

	if type(hook) ~= "function" then
		return false, 0, "hookfunction is unavailable"
	end
	if type(callerCheck) ~= "function" and type(callingScript) ~= "function" then
		return false, 0, "checkcaller/getcallingscript is unavailable"
	end

	if state.version ~= hookVersion then
		NAmanage.RestoreNoCooldownHooks()
		state = NAmanage.GetNoCooldownState()
		state.version = hookVersion
		state.clockContexts = {}
		state.generation = (tonumber(state.generation) or 0) + 1
	end

	local function getGameCallerKey()
		if type(callerCheck) == "function" then
			local ok, isExecutorCaller = pcall(callerCheck)
			if ok and isExecutorCaller then
				return false, nil
			end
		end

		if type(callingScript) == "function" then
			local ok, sourceScript = pcall(callingScript)
			if ok and sourceScript ~= nil then
				return true, sourceScript
			end
		end

		if type(callerCheck) == "function" then
			local ok, isExecutorCaller = pcall(callerCheck)
			if ok and not isExecutorCaller then
				return true, coroutine.running() or state
			end
		end

		return false, nil
	end

	local function shouldInterceptDuration()
		if not state.enabled and not state.waitCapEnabled then
			return false
		end
		local isGameCaller = getGameCallerKey()
		return isGameCaller == true
	end

	local function overrideDuration(seconds)
		local value = seconds
		if state.enabled then
			value = math.max(0, tonumber(state.seconds) or 0)
		end
		if state.waitCapEnabled then
			local numeric = tonumber(value)
			if numeric ~= nil then
				value = math.min(math.max(0, numeric), math.max(0, tonumber(state.waitCapSeconds) or 0))
			end
		end
		return value
	end

	local function getClockContext(clockKey, callerKey, realNow)
		local callerContexts = state.clockContexts[callerKey]
		if type(callerContexts) ~= "table" then
			callerContexts = {}
			state.clockContexts[callerKey] = callerContexts
		end

		local ctx = callerContexts[clockKey]
		if type(ctx) ~= "table" then
			ctx = {
				realStart = realNow;
				realLast = realNow;
				virtualStart = realNow;
				lastValue = realNow;
				generation = state.generation;
			}
			callerContexts[clockKey] = ctx
		end
		return ctx
	end

	local function readVirtualClock(clockKey, original)
		local realNow = original()
		local isGameCaller, callerKey = getGameCallerKey()
		if not isGameCaller then
			return realNow
		end

		local callerContexts = state.clockContexts[callerKey]
		local ctx = type(callerContexts) == "table" and callerContexts[clockKey] or nil

		if not state.enabled then
			if type(ctx) ~= "table" then
				return realNow
			end

			local realDelta = math.max(0, realNow - (tonumber(ctx.realLast) or realNow))
			ctx.lastValue = math.max(tonumber(ctx.lastValue) or realNow, realNow) + realDelta
			ctx.realLast = realNow
			return ctx.lastValue
		end

		ctx = getClockContext(clockKey, callerKey, realNow)
		if ctx.generation ~= state.generation then
			ctx.realStart = realNow
			ctx.virtualStart = math.max(tonumber(ctx.lastValue) or realNow, realNow)
			ctx.realLast = realNow
			ctx.generation = state.generation
		end

		local seconds = math.max(0, tonumber(state.seconds) or 0)
		local value
		if seconds <= 0 then
			value = math.max(tonumber(ctx.lastValue) or realNow, realNow) + CLOCK_JUMP
		else
			local elapsed = math.max(0, realNow - (tonumber(ctx.realStart) or realNow))
			local bucket = math.floor(elapsed / seconds)
			value = (tonumber(ctx.virtualStart) or realNow) + bucket * CLOCK_JUMP
			if value < (tonumber(ctx.lastValue) or value) then
				value = ctx.lastValue
			end
		end

		ctx.lastValue = value
		ctx.realLast = realNow
		return value
	end

	local function installDurationHook(key, target)
		if type(state.hooks[key]) == "function" then
			return true
		end
		if type(target) ~= "function" then
			state.failures[key] = "function unavailable"
			return false
		end

		local original
		local ok, err = pcall(function()
			original = hook(target, function(seconds, ...)
				if shouldInterceptDuration() then
					return original(overrideDuration(seconds), ...)
				end
				return original(seconds, ...)
			end)
		end)

		if ok and type(original) == "function" then
			state.hooks[key] = original
			state.failures[key] = nil
			return true
		end

		state.failures[key] = tostring(err or "hook failed")
		return false
	end

	local function installClockHook(key, target)
		if type(state.hooks[key]) == "function" then
			return true
		end
		if type(target) ~= "function" then
			state.failures[key] = "function unavailable"
			return false
		end

		local original
		local ok, err = pcall(function()
			original = hook(target, function(...)
				return readVirtualClock(key, original)
			end)
		end)

		if ok and type(original) == "function" then
			state.hooks[key] = original
			state.failures[key] = nil
			return true
		end

		state.failures[key] = tostring(err or "hook failed")
		return false
	end

	installDurationHook("wait", wait)
	installDurationHook("task.wait", task and task.wait)
	installDurationHook("delay", delay)
	installDurationHook("task.delay", task and task.delay)
	if state.enabled then
		installClockHook("tick", tick)
		installClockHook("os.clock", os and os.clock)
	end

	local durationCount = 0
	for _, key in {"wait", "task.wait", "delay", "task.delay"} do
		if type(state.hooks[key]) == "function" then
			durationCount += 1
		end
	end

	local clockCount = 0
	for _, key in {"tick", "os.clock"} do
		if type(state.hooks[key]) == "function" then
			clockCount += 1
		end
	end

	const count = durationCount + clockCount
	state.installed = durationCount == 4 and (not state.enabled or clockCount == 2)
	return durationCount > 0 and (not state.enabled or clockCount > 0), count, state
end

cmd.add({"nocooldown", "ncd"}, {"nocooldown <number> (ncd)", "Override game-script cooldown timing with the chosen number of seconds; defaults to 0 when omitted"}, function(value)
	const state = NAmanage.GetNoCooldownState()
	const rawValue = value == nil and "" or tostring(value)
	const seconds = rawValue:match("%S") and tonumber(rawValue) or 0

	if seconds == nil or seconds < 0 or seconds ~= seconds or seconds == math.huge then
		return DoNotif("Usage: nocooldown <number>", 3, "No Cooldown")
	end

	state.seconds = seconds
	state.enabled = true
	state.generation = (tonumber(state.generation) or 0) + 1

	local okInstall, count, detail = NAmanage.InstallNoCooldownHooks()
	if not okInstall then
		state.enabled = false
		return DoNotif("No Cooldown failed: "..tostring(detail), 4, "No Cooldown")
	end

	DoNotif("Game-script cooldown timing set to "..tostring(seconds).."s ("..tostring(count).."/6 hooks active).", 3, "No Cooldown")
end)

cmd.add({"unnocooldown", "unncd"}, {"unnocooldown (unncd)", "Disable the game-script cooldown timing override"}, function()
	const state = NAmanage.GetNoCooldownState()
	state.enabled = false
	state.generation = (tonumber(state.generation) or 0) + 1
	DoNotif("Cooldown override disabled.", 2, "No Cooldown")
end)

cmd.add({"waitcap", "maxwait"}, {"waitcap <seconds> (maxwait)", "Caps game-script wait/delay durations without shortening waits already below the cap"}, function(value)
	const seconds = tonumber(value)
	if seconds == nil or seconds < 0 or seconds ~= seconds or seconds == math.huge then
		return DoNotif("Usage: waitcap <seconds>", 3, "Wait Cap")
	end

	const state = NAmanage.GetNoCooldownState()
	state.waitCapSeconds = seconds
	state.waitCapEnabled = true

	local okInstall, count, detail = NAmanage.InstallNoCooldownHooks()
	if not okInstall then
		state.waitCapEnabled = false
		return DoNotif("Wait Cap failed: "..tostring(detail), 4, "Wait Cap")
	end

	local durationCount = 0
	for _, key in {"wait", "task.wait", "delay", "task.delay"} do
		if type(state.hooks[key]) == "function" then durationCount += 1 end
	end
	DoNotif("Game-script waits/delays capped at "..tostring(seconds).."s ("..tostring(durationCount).."/4 wait hooks active).", 3, "Wait Cap")
end, true)

cmd.add({"unwaitcap", "unmaxwait"}, {"unwaitcap (unmaxwait)", "Disables the game-script wait/delay cap"}, function()
	const state = NAmanage.GetNoCooldownState()
	state.waitCapEnabled = false
	DoNotif("Wait/delay cap disabled.", 2, "Wait Cap")
end)

NAmanage.GetNoTweenState = function()
	const host = _na_boot.hostEnv
	local state = type(host) == "table" and rawget(host, "__NA_NoTweenState") or nil
	if type(state) ~= "table" then
		state = {
			enabled = false;
			seconds = 0;
			original = nil;
			installed = false;
			failure = nil;
		}
		if type(host) == "table" then
			pcall(rawset, host, "__NA_NoTweenState", state)
		end
	end
	state.enabled = state.enabled == true
	state.seconds = math.max(0, tonumber(state.seconds) or 0)
	return state
end

NAmanage.InstallNoTweenHook = function()
	local state = NAmanage.GetNoTweenState()
	const host = _na_boot.hostEnv
	const hook = type(host) == "table" and rawget(host, "hookfunction") or hookfunction
	const hookMeta = type(host) == "table" and rawget(host, "hookmetamethod") or hookmetamethod
	const getNamecall = type(host) == "table" and rawget(host, "getnamecallmethod") or getnamecallmethod
	const makeClosure = type(host) == "table" and rawget(host, "newcclosure") or newcclosure
	local tweenService
	pcall(function() tweenService = game:GetService("TweenService") end)
	tweenService = tweenService or Services.TweenService
	const target = tweenService and tweenService.Create
	const hookVersion = 4

	if not tweenService then
		state.failure = "TweenService unavailable"
		return false, state.failure
	end
	if type(hook) ~= "function" and (type(hookMeta) ~= "function" or type(getNamecall) ~= "function") then
		state.failure = "TweenService hook APIs unavailable"
		return false, state.failure
	end

	if state.version ~= hookVersion then
		if type(hook) == "function" and type(target) == "function" then
			const oldCreate = state.originalCreate or state.original
			if type(oldCreate) == "function" then
				pcall(hook, target, oldCreate)
			end
		end
		if type(hookMeta) == "function" and type(state.originalNamecall) == "function" then
			pcall(hookMeta, game, "__namecall", state.originalNamecall)
		end
		state.original = nil
		state.originalCreate = nil
		state.originalNamecall = nil
		state.createInstalled = false
		state.namecallInstalled = false
		state.installed = false
		state.version = hookVersion
	end

	local function overrideInfo(info)
		local repeatCount = tonumber(info.RepeatCount) or 0
		if repeatCount < 0 then
			repeatCount = 0
		end
		return TweenInfo.new(
			math.max(0, tonumber(state.seconds) or 0),
			info.EasingStyle,
			info.EasingDirection,
			repeatCount,
			info.Reverses,
			0
		)
	end

	if not state.createInstalled and type(hook) == "function" and type(target) == "function" then
		local originalCreate
		local replacement = function(self, instance, info, properties)
			if state.enabled and typeof(info) == "TweenInfo" then
				return originalCreate(self, instance, overrideInfo(info), properties)
			end
			return originalCreate(self, instance, info, properties)
		end
		if type(makeClosure) == "function" then
			replacement = makeClosure(replacement)
		end
		local ok, err = pcall(function()
			originalCreate = hook(target, replacement)
		end)
		if ok and type(originalCreate) == "function" then
			state.original = originalCreate
			state.originalCreate = originalCreate
			state.createInstalled = true
		else
			state.createFailure = tostring(err or "TweenService.Create hook failed")
		end
	end

	if not state.namecallInstalled and type(hookMeta) == "function" and type(getNamecall) == "function" then
		local originalNamecall
		local replacement = function(self, ...)
			local method = Lower(tostring(getNamecall() or ""))
			if state.enabled and self == tweenService and method == "create" then
				local args = table.pack(...)
				if typeof(args[2]) == "TweenInfo" then
					args[2] = overrideInfo(args[2])
				end
				return originalNamecall(self, table.unpack(args, 1, args.n))
			end
			return originalNamecall(self, ...)
		end
		if type(makeClosure) == "function" then
			replacement = makeClosure(replacement)
		end
		local ok, err = pcall(function()
			originalNamecall = hookMeta(game, "__namecall", replacement)
		end)
		if ok and type(originalNamecall) == "function" then
			state.originalNamecall = originalNamecall
			state.namecallInstalled = true
		else
			state.namecallFailure = tostring(err or "__namecall hook failed")
		end
	end

	state.installed = state.createInstalled == true or state.namecallInstalled == true
	if not state.installed then
		state.failure = state.namecallFailure or state.createFailure or "TweenService hooks failed"
		return false, state.failure
	end
	state.failure = nil
	return true
end

cmd.add({"notween", "instanttween"}, {"notween [seconds] (instanttween)", "Forces all TweenService-created tweens, including NA/executor UI tweens, to the chosen duration; defaults to 0"}, function(value)
	const rawValue = value == nil and "" or tostring(value)
	const seconds = rawValue:match("%S") and tonumber(rawValue) or 0
	if seconds == nil or seconds < 0 or seconds ~= seconds or seconds == math.huge then
		return DoNotif("Usage: notween [seconds]", 3, "No Tween")
	end
	const state = NAmanage.GetNoTweenState()
	state.seconds = seconds
	state.enabled = true
	local ok, err = NAmanage.InstallNoTweenHook()
	if not ok then
		state.enabled = false
		return DoNotif("No Tween failed: "..tostring(err), 4, "No Tween")
	end
	DoNotif(seconds <= 0 and "All TweenService-created tweens are now instant." or ("All TweenService-created tweens forced to "..tostring(seconds).."s."), 3, "No Tween")
end)

cmd.add({"unnotween", "uninstanttween"}, {"unnotween (uninstanttween)", "Stops overriding game-created tween durations"}, function()
	const state = NAmanage.GetNoTweenState()
	state.enabled = false
	DoNotif("Tween override disabled.", 2, "No Tween")
end)

NAmanage.GCSearch = function(query, resultLimit)
	query = tostring(query or "")
	const needle = Lower(query)
	if needle == "" then
		return false, "missing query", {}
	end

	const host = _na_boot.hostEnv
	const gc = type(host) == "table" and rawget(host, "getgc") or getgc
	if type(gc) ~= "function" then
		return false, "getgc is unavailable", {}
	end

	const dbg = type(host) == "table" and rawget(host, "debug") or debug
	const getConstants = (type(dbg) == "table" and dbg.getconstants) or (type(host) == "table" and rawget(host, "getconstants")) or getconstants
	const getUpvalues = (type(dbg) == "table" and dbg.getupvalues) or (type(host) == "table" and rawget(host, "getupvalues")) or getupvalues
	const debugInfo = type(dbg) == "table" and dbg.info or nil
	const isCClosure = type(host) == "table" and rawget(host, "iscclosure") or iscclosure
	resultLimit = math.clamp(math.floor(tonumber(resultLimit) or 30), 1, 100)

	local okGC, objects = pcall(gc, true)
	if not okGC or type(objects) ~= "table" then
		return false, tostring(objects or "getgc failed"), {}
	end

	const results = {}
	const functions = {}
	local scanned = 0
	local deepScanned = 0
	local truncated = false
	const startedAt = DateTime.now().UnixTimestampMillis
	const deadline = startedAt + 3500

	local function outOfTime()
		return DateTime.now().UnixTimestampMillis >= deadline
	end

	local function hit(value)
		return Lower(tostring(value or "")):find(needle, 1, true) ~= nil
	end

	local function add(kind, object, where, value)
		if #results >= resultLimit then return end
		results[#results + 1] = {
			kind = kind;
			object = object;
			where = tostring(where or "");
			value = value;
		}
	end

	for index = 1, #objects do
		if #results >= resultLimit then break end
		if index % 128 == 0 and outOfTime() then
			truncated = true
			break
		end

		const object = objects[index]
		scanned += 1
		const objectType = type(object)
		if objectType == "table" then
			pcall(function()
				local checked = 0
				for key, value in next, object do
					checked += 1
					if hit(key) then
						add("table", object, "key", key)
					elseif type(value) ~= "table" and type(value) ~= "function" and hit(value) then
						add("table", object, "value:"..tostring(key), value)
					end
					if #results >= resultLimit or checked >= 96 then break end
				end
			end)
		elseif objectType == "function" then
			local source, name = "?", "?"
			if type(debugInfo) == "function" then
				pcall(function()
					source, name = debugInfo(object, "sn")
				end)
			end
			if hit(source) or hit(name) then
				add("function", object, "debug", tostring(source).." :: "..tostring(name))
			end
			if #functions < 6000 then
				functions[#functions + 1] = object
			end
		end

		if scanned % 256 == 0 then
			Wait()
		end
	end

	if #results < resultLimit and not outOfTime() then
		for index = 1, #functions do
			if #results >= resultLimit then break end
			if index % 32 == 0 and outOfTime() then
				truncated = true
				break
			end

			const object = functions[index]
			local inspect = true
			if type(isCClosure) == "function" then
				local okC, isC = pcall(isCClosure, object)
				if okC and isC then inspect = false end
			end

			if inspect then
				deepScanned += 1
				if type(getConstants) == "function" then
					local okConstants, constants = pcall(getConstants, object)
					if okConstants and type(constants) == "table" then
						for constantIndex, constantValue in next, constants do
							if hit(constantValue) then
								add("function", object, "constant:"..tostring(constantIndex), constantValue)
								break
							end
						end
					end
				end

				if #results < resultLimit and type(getUpvalues) == "function" then
					local okUpvalues, upvalues = pcall(getUpvalues, object)
					if okUpvalues and type(upvalues) == "table" then
						local checked = 0
						for upvalueKey, upvalueValue in next, upvalues do
							checked += 1
							if hit(upvalueKey) or (type(upvalueValue) ~= "table" and type(upvalueValue) ~= "function" and hit(upvalueValue)) then
								add("function", object, "upvalue:"..tostring(upvalueKey), upvalueValue)
								break
							end
							if checked >= 48 then break end
						end
					end
				end
			end

			if index % 64 == 0 then
				Wait()
			end
		end
	elseif outOfTime() then
		truncated = true
	end

	NAStuff.GCSearchResults = results
	NAStuff.GCSearchQuery = query
	NAStuff.GCSearchStats = {
		scanned = scanned;
		deepScanned = deepScanned;
		truncated = truncated;
		elapsedMs = DateTime.now().UnixTimestampMillis - startedAt;
	}
	return true, scanned, results
end

cmd.add({"gcsearch", "gcs"}, {"gcsearch <text> (gcs)", "Searches getgc tables, function metadata, constants, and upvalues for text"}, function(...)
	const args = {...}
	const query = Concat(args, " ")
	if query == "" then
		return DoNotif("Usage: gcsearch <text>", 3, "GC Search")
	end

	SpawnCall(function()
		local ok, detail, results = NAmanage.GCSearch(query, 30)
		if not ok then
			return DoNotif("GC Search failed: "..tostring(detail), 4, "GC Search")
		end
		print(("[NA GC Search] query=%q scanned=%d matches=%d"):format(query, tonumber(detail) or 0, #results))
		for index, result in ipairs(results) do
			print(("[NA GC Search #%d] %s | %s | %s"):format(index, tostring(result.kind), tostring(result.where), tostring(result.value)))
		end
		local stats = NAStuff.GCSearchStats or {}
		DoNotif(("GC Search found %d match%s in %dms%s. Results printed to console and saved in NAStuff.GCSearchResults."):format(#results, #results == 1 and "" or "es", tonumber(stats.elapsedMs) or 0, stats.truncated and " (scan budget reached)" or ""), 4, "GC Search")
	end)
end, true)

NAmanage.GetAutoPatchToolState = function()
	const host = _na_boot.hostEnv
	local state = type(host) == "table" and rawget(host, "__NA_AutoPatchToolState") or nil
	if type(state) ~= "table" then
		state = {
			enabled = false;
			all = false;
			records = {};
			seenTables = setmetatable({}, { __mode = "k" });
			seenInstances = setmetatable({}, { __mode = "k" });
			connections = {};
			guardConnections = setmetatable({}, { __mode = "k" });
			patchedTools = setmetatable({}, { __mode = "k" });
		}
		if type(host) == "table" then
			pcall(rawset, host, "__NA_AutoPatchToolState", state)
		end
	end
	state.records = type(state.records) == "table" and state.records or {}
	state.seenTables = type(state.seenTables) == "table" and state.seenTables or setmetatable({}, { __mode = "k" })
	state.seenInstances = type(state.seenInstances) == "table" and state.seenInstances or setmetatable({}, { __mode = "k" })
	state.connections = type(state.connections) == "table" and state.connections or {}
	state.guardConnections = type(state.guardConnections) == "table" and state.guardConnections or setmetatable({}, { __mode = "k" })
	state.patchedTools = type(state.patchedTools) == "table" and state.patchedTools or setmetatable({}, { __mode = "k" })
	return state
end

NAmanage.AutoPatchToolKey = function(key, value)
	const compact = Lower(tostring(key or "")):gsub("[^%w]", "")
	if compact == "" then return nil end

	const zeroKeys = {
		cooldown=true; cooldowntime=true; cooldownseconds=true; firedelay=true; shotdelay=true; fireinterval=true; attackdelay=true;
		reloadtime=true; reloadduration=true; equiptime=true; equipdelay=true; chargetime=true; winduptime=true; windup=true;
		spread=true; maxspread=true; minspread=true; bloom=true; recoil=true; recoilx=true; recoily=true; recoilz=true;
		kick=true; kickback=true; sway=true; deviation=true; inaccuracy=true; heatperbullet=true; recoverydelay=true;
	}
	const highKeys = {
		ammo=true; currentammo=true; maxammo=true; ammocount=true; reserveammo=true; maxreserveammo=true; magazine=true;
		magsize=true; magazinesize=true; clipsize=true; clip=true; capacity=true; range=true; maxrange=true; projectilerange=true;
		firerate=true; rateoffire=true; rpm=true; reloadspeed=true; bulletspeed=true; projectilespeed=true; velocity=true;
		damage=true; basedamage=true; bulletdamage=true; hitdamage=true;
	}
	const trueKeys = {
		automatic=true; auto=true; fullauto=true; canfire=true; canshoot=true; enabled=true; infiniteammo=true; unlimitedammo=true;
	}
	const falseKeys = {
		reloading=true; isreloading=true; coolingdown=true; oncooldown=true; jammed=true; isjammed=true; overheated=true; isoverheated=true;
	}

	if type(value) == "number" then
		if zeroKeys[compact] then return 0, "zero" end
		if highKeys[compact] then return 1000000, "high" end
	elseif type(value) == "boolean" then
		if trueKeys[compact] then return true, "true" end
		if falseKeys[compact] then return false, "false" end
	end
	return nil
end

NAmanage.AutoPatchToolRememberTable = function(state, tbl, key, oldValue)
	local seen = state.seenTables[tbl]
	if type(seen) ~= "table" then
		seen = {}
		state.seenTables[tbl] = seen
	end
	if seen[key] then return end
	seen[key] = true
	state.records[#state.records + 1] = { kind="table"; target=tbl; key=key; old=oldValue; }
end

NAmanage.AutoPatchToolRememberInstance = function(state, inst, key, oldValue, kind)
	local seen = state.seenInstances[inst]
	if type(seen) ~= "table" then
		seen = {}
		state.seenInstances[inst] = seen
	end
	const token = tostring(kind)..":"..tostring(key)
	if seen[token] then return end
	seen[token] = true
	state.records[#state.records + 1] = { kind=kind; target=inst; key=key; old=oldValue; }
end

NAmanage.AutoPatchToolTable = function(state, tbl, stats, depth, visited)
	if type(tbl) ~= "table" then return end
	depth = tonumber(depth) or 0
	if depth > 3 then return end
	visited = visited or setmetatable({}, { __mode = "k" })
	if visited[tbl] then return end
	visited[tbl] = true

	local checked = 0
	for key, value in next, tbl do
		checked += 1
		local replacement = NAmanage.AutoPatchToolKey(key, value)
		if replacement ~= nil and replacement ~= value then
			NAmanage.AutoPatchToolRememberTable(state, tbl, key, value)
			local ok = pcall(function() tbl[key] = replacement end)
			if ok then stats.tables += 1 end
		elseif type(value) == "table" and depth < 3 then
			NAmanage.AutoPatchToolTable(state, value, stats, depth + 1, visited)
		end
		if checked >= 900 then break end
	end
end

NAmanage.AutoPatchToolValue = function(state, inst, stats)
	if not (inst and inst.Parent and inst:IsA("ValueBase")) then return end
	local okValue, oldValue = pcall(function() return inst.Value end)
	if not okValue then return end
	local replacement = NAmanage.AutoPatchToolKey(inst.Name, oldValue)
	if replacement == nil or replacement == oldValue then return end
	NAmanage.AutoPatchToolRememberInstance(state, inst, "Value", oldValue, "value")
	if pcall(function() inst.Value = replacement end) then
		stats.values += 1
	end
	if not state.guardConnections[inst] then
		local conn
		conn = inst.Changed:Connect(function()
			if not state.enabled or not inst.Parent then return end
			local current = inst.Value
			local nextValue = NAmanage.AutoPatchToolKey(inst.Name, current)
			if nextValue ~= nil and current ~= nextValue then
				pcall(function() inst.Value = nextValue end)
			end
		end)
		state.guardConnections[inst] = conn
	end
end

NAmanage.AutoPatchToolAttributes = function(state, inst, stats)
	if typeof(inst) ~= "Instance" then return end
	local okAttributes, attributes = pcall(inst.GetAttributes, inst)
	if not okAttributes or type(attributes) ~= "table" then return end
	for key, oldValue in next, attributes do
		local replacement = NAmanage.AutoPatchToolKey(key, oldValue)
		if replacement ~= nil and replacement ~= oldValue then
			NAmanage.AutoPatchToolRememberInstance(state, inst, key, oldValue, "attribute")
			if pcall(inst.SetAttribute, inst, key, replacement) then
				stats.attributes += 1
			end
			local guardKey = tostring(inst:GetDebugId())..":"..tostring(key)
			if not state.guardConnections[guardKey] then
				local conn = inst:GetAttributeChangedSignal(key):Connect(function()
					if not state.enabled or not inst.Parent then return end
					local current = inst:GetAttribute(key)
					local nextValue = NAmanage.AutoPatchToolKey(key, current)
					if nextValue ~= nil and current ~= nextValue then
						pcall(inst.SetAttribute, inst, key, nextValue)
					end
				end)
				state.guardConnections[guardKey] = conn
			end
		end
	end
end

NAmanage.AutoPatchToolObject = function(state, inst, stats)
	if typeof(inst) ~= "Instance" then return end
	NAmanage.AutoPatchToolAttributes(state, inst, stats)
	if inst:IsA("ValueBase") then
		NAmanage.AutoPatchToolValue(state, inst, stats)
	elseif inst:IsA("ModuleScript") then
		local okModule, exported = pcall(require, inst)
		if okModule and type(exported) == "table" then
			stats.modules += 1
			NAmanage.AutoPatchToolTable(state, exported, stats, 0)
		end
	elseif inst:IsA("LocalScript") then
		local host = _na_boot.hostEnv
		local getEnv = type(host) == "table" and rawget(host, "getsenv") or getsenv
		if type(getEnv) == "function" then
			local okEnv, env = pcall(getEnv, inst)
			if okEnv and type(env) == "table" then
				NAmanage.AutoPatchToolTable(state, env, stats, 0)
			end
		end
	end
end

NAmanage.AutoPatchToolRuntimeTables = function(state, tool, stats)
	const host = _na_boot.hostEnv
	const gc = type(host) == "table" and rawget(host, "getgc") or getgc
	const getEnv = type(host) == "table" and rawget(host, "getfenv") or getfenv
	const dbg = type(host) == "table" and rawget(host, "debug") or debug
	const getUpvalues = (type(dbg) == "table" and dbg.getupvalues) or (type(host) == "table" and rawget(host, "getupvalues")) or getupvalues
	const isCClosure = type(host) == "table" and rawget(host, "iscclosure") or iscclosure
	if type(gc) ~= "function" then return end

	local okGC, objects = pcall(gc, true)
	if not okGC or type(objects) ~= "table" then return end

	const toolName = Lower(tool.Name)
	const refs = setmetatable({ [tool] = true }, { __mode = "k" })
	for _, descendant in ipairs(tool:GetDescendants()) do
		refs[descendant] = true
	end

	const instanceKeys = {
		"tool", "Tool", "weapon", "Weapon", "item", "Item", "instance", "Instance",
		"currentTool", "CurrentTool", "equippedTool", "EquippedTool", "weaponTool", "WeaponTool";
	}
	const nameKeys = { "name", "Name", "weaponName", "WeaponName", "toolName", "ToolName", "itemName", "ItemName" }
	const functions = {}
	const startedAt = DateTime.now().UnixTimestampMillis
	const deadline = startedAt + 2200
	local scanned = 0
	local truncated = false

	local function outOfTime()
		return DateTime.now().UnixTimestampMillis >= deadline
	end

	local function isRelatedInstance(value)
		if typeof(value) ~= "Instance" then return false end
		if refs[value] then return true end
		local ok, related = pcall(value.IsDescendantOf, value, tool)
		return ok and related == true
	end

	local function tableIsRelated(tbl)
		for index = 1, #instanceKeys do
			local value = rawget(tbl, instanceKeys[index])
			if value ~= nil and isRelatedInstance(value) then
				return true
			end
		end
		for index = 1, #nameKeys do
			local value = rawget(tbl, nameKeys[index])
			if value ~= nil and Lower(tostring(value)) == toolName then
				return true
			end
		end
		return false
	end

	for index = 1, #objects do
		if index % 256 == 0 and outOfTime() then
			truncated = true
			break
		end
		const object = objects[index]
		if type(object) == "table" then
			local okRelated, related = pcall(tableIsRelated, object)
			if okRelated and related then
				stats.gcTables += 1
				NAmanage.AutoPatchToolTable(state, object, stats, 0)
			end
		elseif type(object) == "function" and #functions < 5000 then
			functions[#functions + 1] = object
		end
		scanned += 1
		if scanned % 512 == 0 then Wait() end
	end

	if type(getEnv) == "function" and not outOfTime() then
		for index = 1, #functions do
			if index % 32 == 0 and outOfTime() then
				truncated = true
				break
			end

			const object = functions[index]
			local inspect = true
			if type(isCClosure) == "function" then
				local okC, isC = pcall(isCClosure, object)
				if okC and isC then inspect = false end
			end

			if inspect then
				local relatedFunction = false
				local okEnv, env = pcall(getEnv, object)
				if okEnv and type(env) == "table" then
					local sourceScript = rawget(env, "script")
					if isRelatedInstance(sourceScript) then
						relatedFunction = true
						NAmanage.AutoPatchToolTable(state, env, stats, 0)
					end
				end

				if relatedFunction and type(getUpvalues) == "function" then
					local okUpvalues, upvalues = pcall(getUpvalues, object)
					if okUpvalues and type(upvalues) == "table" then
						local checked = 0
						for _, upvalue in next, upvalues do
							checked += 1
							if type(upvalue) == "table" then
								stats.gcTables += 1
								NAmanage.AutoPatchToolTable(state, upvalue, stats, 0)
							end
							if checked >= 64 then break end
						end
					end
				end
			end

			if index % 64 == 0 then Wait() end
		end
	elseif outOfTime() then
		truncated = true
	end

	stats.runtimeScanned = scanned
	stats.runtimeTruncated = truncated
	stats.runtimeElapsedMs = DateTime.now().UnixTimestampMillis - startedAt
end

NAmanage.AutoPatchToolApply = function(tool)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return nil, "tool unavailable"
	end
	const state = NAmanage.GetAutoPatchToolState()
	const stats = { values=0; attributes=0; tables=0; modules=0; gcTables=0; }
	state.patchedTools[tool] = true
	state.lastTool = tool

	NAmanage.AutoPatchToolObject(state, tool, stats)
	local descendants = tool:GetDescendants()
	for index = 1, #descendants do
		NAmanage.AutoPatchToolObject(state, descendants[index], stats)
		if index % 150 == 0 then Wait() end
	end
	NAmanage.AutoPatchToolRuntimeTables(state, tool, stats)

	if not state.guardConnections[tool] then
		local conn = tool.DescendantAdded:Connect(function(inst)
			if not state.enabled or not tool.Parent then return end
			Defer(function()
				local liveStats = { values=0; attributes=0; tables=0; modules=0; gcTables=0; }
				NAmanage.AutoPatchToolObject(state, inst, liveStats)
			end)
		end)
		state.guardConnections[tool] = conn
	end

	return stats
end

NAmanage.AutoPatchToolFind = function(query)
	const char = getChar()
	const backpack = getBp()
	query = tostring(query or "")
	if query == "" then
		const equipped = char and char:FindFirstChildOfClass("Tool")
		if equipped then return { equipped } end
		return {}
	end
	const needle = Lower(query)
	const results = {}
	local function scan(parent)
		if not parent then return end
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("Tool") and (needle == "all" or Lower(child.Name):find(needle, 1, true)) then
				results[#results + 1] = child
			end
		end
	end
	scan(char)
	scan(backpack)
	return results
end

NAmanage.AutoPatchToolDisconnect = function(state)
	for key, conn in next, state.connections do
		if conn and type(conn.Disconnect) == "function" then pcall(conn.Disconnect, conn) end
		state.connections[key] = nil
	end
	for key, conn in next, state.guardConnections do
		if conn and type(conn.Disconnect) == "function" then pcall(conn.Disconnect, conn) end
		state.guardConnections[key] = nil
	end
end

NAmanage.AutoPatchToolRestore = function()
	const state = NAmanage.GetAutoPatchToolState()
	state.enabled = false
	state.all = false
	NAmanage.AutoPatchToolDisconnect(state)
	local restored = 0
	for index = #state.records, 1, -1 do
		const record = state.records[index]
		if type(record) == "table" then
			if record.kind == "table" and type(record.target) == "table" then
				if pcall(function() record.target[record.key] = record.old end) then restored += 1 end
			elseif record.kind == "value" and typeof(record.target) == "Instance" and record.target.Parent then
				if pcall(function() record.target.Value = record.old end) then restored += 1 end
			elseif record.kind == "attribute" and typeof(record.target) == "Instance" and record.target.Parent then
				if pcall(record.target.SetAttribute, record.target, record.key, record.old) then restored += 1 end
			end
		end
		state.records[index] = nil
	end
	state.seenTables = setmetatable({}, { __mode = "k" })
	state.seenInstances = setmetatable({}, { __mode = "k" })
	state.patchedTools = setmetatable({}, { __mode = "k" })
	state.guardConnections = setmetatable({}, { __mode = "k" })
	return restored
end

NAmanage.AutoPatchToolEnableAll = function(state)
	state.all = true
	const function patch(inst)
		if not state.enabled or typeof(inst) ~= "Instance" or not inst:IsA("Tool") then return end
		SpawnCall(function()
			NAmanage.AutoPatchToolApply(inst)
		end)
	end
	const function bindCharacter(char)
		if state.connections.char then
			pcall(state.connections.char.Disconnect, state.connections.char)
			state.connections.char = nil
		end
		if char then
			state.connections.char = char.ChildAdded:Connect(patch)
		end
	end
	const function bindBackpack(backpack)
		if state.connections.backpack then
			pcall(state.connections.backpack.Disconnect, state.connections.backpack)
			state.connections.backpack = nil
		end
		if backpack then
			state.connections.backpack = backpack.ChildAdded:Connect(patch)
		end
	end

	const player = Services.Players.LocalPlayer
	bindCharacter(getChar())
	bindBackpack(getBp())
	if player then
		state.connections.characterAdded = player.CharacterAdded:Connect(function(char)
			if state.enabled and state.all then bindCharacter(char) end
		end)
		state.connections.playerChildAdded = player.ChildAdded:Connect(function(child)
			if state.enabled and state.all and child:IsA("Backpack") then bindBackpack(child) end
		end)
	end
end

cmd.add({"autopatchtool", "apt"}, {"autopatchtool [tool|all] (apt)", "Aggressively patches common cooldown, reload, recoil, spread, ammo, fire-rate, range, and damage settings for a tool"}, function(...)
	const query = Concat({...}, " ")
	local state = NAmanage.GetAutoPatchToolState()
	if state.enabled or #state.records > 0 then
		NAmanage.AutoPatchToolRestore()
		state = NAmanage.GetAutoPatchToolState()
	end
	state.enabled = true
	state.guardConnections = setmetatable({}, { __mode = "k" })

	const allMode = Lower(query) == "all"
	local tools = NAmanage.AutoPatchToolFind(query)
	if #tools == 0 and not allMode then
		state.enabled = false
		return DoNotif(query == "" and "Equip a tool first, or use autopatchtool all / autopatchtool <name>." or ("No tool matched '"..query.."'."), 4, "Auto Patch Tool")
	end

	if allMode then
		NAmanage.AutoPatchToolEnableAll(state)
		tools = NAmanage.AutoPatchToolFind("all")
	end

	SpawnCall(function()
		local totals = { values=0; attributes=0; tables=0; modules=0; gcTables=0; }
		for _, tool in ipairs(tools) do
			local stats = NAmanage.AutoPatchToolApply(tool)
			if stats then
				for key, value in next, stats do totals[key] = (totals[key] or 0) + (tonumber(value) or 0) end
			end
		end
		DoNotif(("Patched %d tool%s | values %d | attributes %d | table fields %d | modules %d | runtime tables %d"):format(#tools, #tools == 1 and "" or "s", totals.values, totals.attributes, totals.tables, totals.modules, totals.gcTables), 5, "Auto Patch Tool")
	end)
end)

cmd.add({"unautopatchtool", "unapt"}, {"unautopatchtool (unapt)", "Restores values changed by Auto Patch Tool and disables its guards"}, function()
	const restored = NAmanage.AutoPatchToolRestore()
	DoNotif("Auto Patch Tool disabled. Restored "..tostring(restored).." recorded value(s).", 4, "Auto Patch Tool")
end)

NAStuff.TailSwayURL = "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/TailSway.luau"

cmd.add({"tailsway", "tailwag", "tailwagging", "tailswaying"}, {"tailsway (tailwag, tailwagging, tailswaying)", "Load the TailSway physics/wagging script"}, function()
	local okRun, errRun = NAmanage.RunURL(NAStuff.TailSwayURL, true, "@TailSway.luau")
	if not okRun then
		return DoNotif("Failed to queue TailSway: "..tostring(errRun), 4, "Tail Sway")
	end
	DoNotif("TailSway queued.", 2, "Tail Sway")
end)

NAStuff.SecureScriptsLoggerUrl = "https://sirmemegithub.com/RealSlimShady2000/SecureScriptsLogger/raw/branch/main/logger.lua"

NAmanage.IsSecureScriptsLoggerActive = function()
	if rawget(_na_env, "__NA_SS_LOGGER_LOADED") == true then
		return true
	end
	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" and rawget(target, "__SS_LOGGER_ACTIVE") == true then
			return true
		end
	end
	return false
end

NAmanage.ClearSecureScriptsLoggerConfig = function()
	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" then
			pcall(function()
				target.SS_LOGGER_CONFIG = nil
			end)
		end
	end
end

NAmanage.LoadSecureScriptsLogger = function(mode)
	mode = Lower(tostring(mode or ""))
	if mode == "" then
		mode = "gui"
	end
	if mode ~= "gui" and mode ~= "console" and mode ~= "both" then
		return false, "Usage: scriptlogger [gui/console/both]"
	end
	if NAmanage.IsSecureScriptsLoggerActive() then
		return false, "SecureScripts Logger is already active."
	end

	const config = {
		mode = mode;
		toggleKey = "RightShift";
		blockRPC = true;
	}
	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" then
			pcall(function()
				target.SS_LOGGER_CONFIG = config
			end)
		end
	end

	local okSource, source = pcall(_na_boot.httpGet, NAStuff.SecureScriptsLoggerUrl, {
		maxAttempts = 5;
		timeout = 12;
	})
	if not okSource or type(source) ~= "string" or source == "" then
		NAmanage.ClearSecureScriptsLoggerConfig()
		return false, "Failed to download SecureScripts Logger: "..tostring(source)
	end

	const loader = loadstring or load
	if type(loader) ~= "function" then
		NAmanage.ClearSecureScriptsLoggerConfig()
		return false, "loadstring is unavailable."
	end

	local compiled, compileErr = loader(source, "@SecureScriptsLogger.lua")
	source = nil
	if type(compiled) ~= "function" then
		NAmanage.ClearSecureScriptsLoggerConfig()
		return false, "Failed to compile SecureScripts Logger: "..tostring(compileErr)
	end

	local okRun, runErr = pcall(compiled)
	NAmanage.ClearSecureScriptsLoggerConfig()
	if not okRun then
		return false, "SecureScripts Logger failed: "..tostring(runErr)
	end

	_na_env.__NA_SS_LOGGER_LOADED = true
	return true, mode
end

cmd.add({"scriptlogger", "sslogger", "securescriptslogger", "securelogger"}, {"scriptlogger [gui/console/both] (sslogger, securescriptslogger, securelogger)", "Load SecureScripts Logger before running a suspicious script"}, function(mode)
	local ok, result = NAmanage.LoadSecureScriptsLogger(mode)
	if not ok then
		return DoNotif(result, 4, "SecureScripts Logger")
	end

	local message = "SecureScripts Logger is active in "..result.." mode. Its hooks remain active until you rejoin."
	if result ~= "console" then
		message ..= " Press RightShift to toggle its GUI."
	end
	DoNotif(message, 6, "SecureScripts Logger")
end)

NAStuff.TASCreatorUrl = "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/TAS.luau"

NAmanage.RunTASCreator = function(fileName, opts)
	opts = type(opts) == "table" and opts or {}
	fileName = tostring(fileName or ""):gsub("^%s+", ""):gsub("%s+$", "")

	_na_boot.syncRuntimeGlobals({
		AutoLoadAndPlayFile = fileName;
		ExtremeSmoothing = opts.smoothing == true;
		TargetSmoothingFPS = tonumber(opts.fps) or 24;
		ShowVelocityDuringPlayback = opts.velocity == true;
		ShowTASPathDuringPlayback = opts.path == true;
		PlaybackCamera = opts.camera ~= false;
	})

	local okSource, source, sourceErr = NAmanage.HttpGet(NAStuff.TASCreatorUrl, {
		noCache = true,
		timeout = 10,
	})
	if not okSource then
		return false, tostring(sourceErr or "failed to download TAS")
	end

	return NAmanage.RunSource(source, "@TAS.luau")
end

cmd.add({"tas", "tascreator", "toolassistedspeedrun", "toolassistantspeedrun"}, {"tas [file] [smooth] [fps] [path] [velocity] [nocamera]", "Launch TAS Recorder Redux; optionally auto-load and play a saved run"}, function(...)
	const rawArgs = {...}
	local fileParts = {}
	local opts = {
		camera = true;
		fps = 24;
		path = false;
		smoothing = false;
		velocity = false;
	}

	for _, rawArg in rawArgs do
		const arg = tostring(rawArg or "")
		const token = Lower(arg)
		const fpsToken = token:match("^fps=(%d+)$")
			or token:match("^targetfps=(%d+)$")
			or token:match("^smoothfps=(%d+)$")

		if token == "smooth" or token == "smoothing" or token == "cinematic" or token == "extreme" then
			opts.smoothing = true
		elseif fpsToken then
			opts.smoothing = true
			opts.fps = math.clamp(math.floor(tonumber(fpsToken) or opts.fps), 1, 240)
		elseif tonumber(token) and opts.smoothing == true then
			opts.fps = math.clamp(math.floor(tonumber(token) or opts.fps), 1, 240)
		elseif token == "path" or token == "paths" or token == "taspath" then
			opts.path = true
		elseif token == "velocity" or token == "vel" or token == "traj" or token == "trajectory" then
			opts.velocity = true
		elseif token == "nocamera" or token == "cameraoff" or token == "no-camera" then
			opts.camera = false
		elseif token == "camera" or token == "cam" then
			opts.camera = true
		elseif arg ~= "" then
			fileParts[#fileParts + 1] = arg
		end
	end

	const fileName = Concat(fileParts, " "):gsub("^%s+", ""):gsub("%s+$", "")
	local okRun, errRun = NAmanage.RunTASCreator(fileName, opts)
	if okRun then
		if fileName ~= "" then
			DoNotif("Launching TAS playback: "..fileName, 3)
		else
			DoNotif("Launching TAS", 3)
		end
	else
		DoNotif(tostring(errRun or "TAS failed to launch"), 3)
		warn(errRun)
	end
end, true)


cmd.add({"scriptload", "sload", "loadscript", "runsavedscript"}, {"scriptload <name> (sload, loadscript)", "Run a saved script from the NA executor saved scripts folder"}, function(...)
	const args = {...}
	local name = Concat(args, " ")
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		return DoNotif("usage: scriptload <name>", 3)
	end
	local ok, err = NAmanage.RunExecutorSavedScript(name)
	if not ok then
		DoNotif(tostring(err), 3)
		warn(err)
	end
end, true)

NA_SHADER_EFFECT_NAMES = {
	"NAShaderBloom",
	"NAShaderTropic",
	"NAShaderSky",
	"NAShaderBlur",
	"NAShaderEfecto",
	"NAShaderInari",
	"NAShaderNormal",
	"NAShaderSunRays",
	"NAShaderSunset",
	"NAShaderTakayama",
}

NAmanage.NAremoveShaderEffects=function(lighting)
	for _, name in NA_SHADER_EFFECT_NAMES do
		const inst = lighting:FindFirstChild(name)
		if inst then
			inst:Destroy()
		end
	end
end

cmd.add({"shaders", "shader", "rtx", "hd"}, {"shaders (shader, rtx, hd)", "Enable a shader preset for Lighting"}, function()
	const lighting = Services.Lighting
	const RawLighting = __lt.gs("Lighting")
	if not lighting then
		DoNotif("Lighting service unavailable", 3)
		return
	end

	const st = NAmanage._ensureL()
	st.shader = st.shader or {enabled=false, baseline={}, target={}}
	const shader = st.shader

	st.cancelFor("shader")

	const shaderTarget = {
		Brightness = 2.14;
		ColorShift_Bottom = Color3.fromRGB(11, 0, 20);
		ColorShift_Top = Color3.fromRGB(240, 127, 14);
		OutdoorAmbient = Color3.fromRGB(34, 0, 49);
		ClockTime = 6.7;
		FogColor = Color3.fromRGB(94, 76, 106);
		FogEnd = 1000;
		FogStart = 0;
		ExposureCompensation = 0.24;
		ShadowSoftness = 0;
		Ambient = Color3.fromRGB(59, 33, 27);
	}

	shader.target = shader.target or {}
	for prop, val in shaderTarget do
		shader.target[prop] = val
	end
	shader.baseline = shader.baseline or {}

	const shaderEffects = {
		{className="BloomEffect", name="NAShaderBloom", props={Intensity=0.1, Threshold=0, Size=100}},
		{className="Sky", name="NAShaderTropic", props={
			SkyboxUp="http://www.roblox.com/asset/?id=169210149",
			SkyboxLf="http://www.roblox.com/asset/?id=169210133",
			SkyboxBk="http://www.roblox.com/asset/?id=169210090",
			SkyboxFt="http://www.roblox.com/asset/?id=169210121",
			SkyboxDn="http://www.roblox.com/asset/?id=169210108",
			SkyboxRt="http://www.roblox.com/asset/?id=169210143",
			StarCount=100,
		}},
		{className="Sky", name="NAShaderSky", props={
			SkyboxUp="http://www.roblox.com/asset/?id=196263782",
			SkyboxLf="http://www.roblox.com/asset/?id=196263721",
			SkyboxBk="http://www.roblox.com/asset/?id=196263721",
			SkyboxFt="http://www.roblox.com/asset/?id=196263721",
			SkyboxDn="http://www.roblox.com/asset/?id=196263643",
			SkyboxRt="http://www.roblox.com/asset/?id=196263721",
			CelestialBodiesShown=false,
		}},
		{className="BlurEffect", name="NAShaderBlur", props={Size=2}},
		{className="BlurEffect", name="NAShaderEfecto", props={Size=2, Enabled=false}},
		{className="ColorCorrectionEffect", name="NAShaderInari", props={Saturation=0.05, TintColor=Color3.fromRGB(255, 224, 219)}},
		{className="ColorCorrectionEffect", name="NAShaderNormal", props={Enabled=false, Saturation=-0.2, TintColor=Color3.fromRGB(255, 232, 215)}},
		{className="SunRaysEffect", name="NAShaderSunRays", props={Intensity=0.05}},
		{className="Sky", name="NAShaderSunset", props={
			SkyboxUp="rbxassetid://323493360",
			SkyboxLf="rbxassetid://323494252",
			SkyboxBk="rbxassetid://323494035",
			SkyboxFt="rbxassetid://323494130",
			SkyboxDn="rbxassetid://323494368",
			SkyboxRt="rbxassetid://323494067",
			SunAngularSize=14,
		}},
		{className="ColorCorrectionEffect", name="NAShaderTakayama", props={Enabled=false, Saturation=-0.3, Contrast=0.1, TintColor=Color3.fromRGB(235, 214, 204)}},
	}

	const function ensureEffects()
		for _, def in shaderEffects do
			local inst = lighting:FindFirstChild(def.name)
			if not inst or not inst:IsA(def.className) then
				if inst then pcall(function() inst:Destroy() end) end
				inst = InstanceNew(def.className)
				inst.Name = def.name
				inst.Parent = lighting
			elseif inst.Parent ~= RawLighting then
				pcall(function() inst.Parent = lighting end)
			end
			for prop, val in def.props do
				st.safeSet(inst, prop, val)
			end
		end
	end

	const function captureBaseline()
		for prop, _ in shader.target do
			if shader.baseline[prop] == nil then
				shader.baseline[prop] = st.safeGet(lighting, prop)
			end
		end
		NAmanage._shaderSettingsBackup = shader.baseline
	end

	if not shader.apply then
		shader.apply = function()
			for prop, val in shader.target do
				st.safeSet(lighting, prop, val)
			end
		end
	end

	if not shader.restore then
		shader.restore = function()
			for prop, val in shader.baseline or {} do
				if val ~= nil then st.safeSet(lighting, prop, val) end
			end
			NAmanage._shaderSettingsBackup = nil
		end
	end

	if not shader.init then
		shader.init = true
		for prop, _ in shader.target do
			const connName = "shader_prop_"..Lower(prop)
			st.hook(connName, function() return lighting:GetPropertyChangedSignal(prop):Connect(function()
					if st.shader and st.shader.enabled then
						if st.safeGet(lighting, prop) ~= st.shader.target[prop] then
							st.safeSet(lighting, prop, st.shader.target[prop])
						end
					else
						if st.shader and st.shader.baseline then
							st.shader.baseline[prop] = st.safeGet(lighting, prop)
							NAmanage._shaderSettingsBackup = st.shader.baseline
						end
					end
				end) end)
		end

		st.hook("shader_effects_loop", function() return Services.RunService.RenderStepped:Connect(function()
				if not (st.shader and st.shader.enabled) then return end
				ensureEffects()
				shader.apply()
			end) end)

		st.hook("shader_effects_removed", function() return NAmanage.descRem(lighting, function(inst)
				if not (st.shader and st.shader.enabled) or not inst then return end
				for _, name in NA_SHADER_EFFECT_NAMES do
					if inst.Name == name then
						Delay(0, ensureEffects)
						break
					end
				end
			end) end)
	end

	captureBaseline()
	shader.enabled = true
	ensureEffects()
	shader.apply()

	DoNotif("Shader preset applied.", 3)
end)

cmd.add({"unshaders", "shadersoff", "rtxoff"}, {"unshaders (shadersoff, rtxoff)", "Disable the shader preset and restore Lighting"}, function()
	const lighting = Services.Lighting
	if not lighting then
		DoNotif("Lighting service unavailable", 3)
		return
	end

	const st = NAmanage._ensureL()
	if st.shader then
		st.shader.enabled = false
	end

	if st.shader and st.shader.restore then
		st.shader.restore()
	else
		const backup = NAmanage._shaderSettingsBackup
		if backup then
			for prop, value in backup do
				st.safeSet(lighting, prop, value)
			end
		end
		NAmanage._shaderSettingsBackup = nil
	end

	NAmanage.NAremoveShaderEffects(lighting)

	DoNotif("Shader preset removed.", 3)
end)

NAmanage.NAibtoolsVectorString=function(vec)
	return Format("Vector3.new(%s,%s,%s)", tostring(vec.X), tostring(vec.Y), tostring(vec.Z))
end

NAmanage.NAibtoolsCreateUI=function(state, actions)
	const gui = InstanceNew("ScreenGui")
	gui.Name = "iBToolsUI"
	NAgui.NaProtectUI(gui)

	const frame = InstanceNew("Frame", gui)
	frame.Name = "Panel"
	frame.Size = UDim2.new(0, 240, 0, 260)
	frame.Position = UDim2.new(0.05, 0, 0.4, 0)
	frame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	frame.BorderSizePixel = 0

	const frameCorner = InstanceNew("UICorner", frame)
	frameCorner.CornerRadius = UDim.new(0, 6)

	const header = InstanceNew("Frame", frame)
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	header.BorderSizePixel = 0
	header.Active = true

	const title = InstanceNew("TextLabel", header)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamSemibold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "iBuild Tools"
	title.Size = UDim2.new(1, -40, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)

	const statusLabel = InstanceNew("TextLabel", frame)
	statusLabel.Name = "Status"
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 14
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.Position = UDim2.new(0, 12, 0, 46)
	statusLabel.Size = UDim2.new(1, -24, 0, 20)
	statusLabel.Text = "Target: none"

	const buttonHolder = InstanceNew("Frame", frame)
	buttonHolder.BackgroundTransparency = 1
	buttonHolder.Position = UDim2.new(0, 12, 0, 72)
	buttonHolder.Size = UDim2.new(1, -24, 1, -84)

	const layout = InstanceNew("UIListLayout", buttonHolder)
	layout.Padding = UDim.new(0, 6)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	const DEFAULT_COLOR = Color3.fromRGB(52, 52, 52)
	const HOVER_COLOR = Color3.fromRGB(66, 66, 66)
	const ACTIVE_COLOR = Color3.fromRGB(80, 110, 255)

	const function makeButton(text)
		const btn = InstanceNew("TextButton", buttonHolder)
		btn.Name = text
		btn.Size = UDim2.new(1, 0, 0, 34)
		btn.BackgroundColor3 = DEFAULT_COLOR
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 14
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = text
		const corner = InstanceNew("UICorner", btn)
		corner.CornerRadius = UDim.new(0, 6)
		btn.MouseEnter:Connect(function()
			if btn.BackgroundColor3 ~= ACTIVE_COLOR then
				btn.BackgroundColor3 = HOVER_COLOR
			end
		end)
		btn.MouseLeave:Connect(function()
			if btn.BackgroundColor3 ~= ACTIVE_COLOR then
				btn.BackgroundColor3 = DEFAULT_COLOR
			end
		end)
		return btn
	end

	const modeButtons = {}

	const function refreshModeButtons()
		const selected = actions.getMode and actions.getMode() or nil
		for mode, btn in modeButtons do
			if selected == mode then
				btn.BackgroundColor3 = ACTIVE_COLOR
			else
				btn.BackgroundColor3 = DEFAULT_COLOR
			end
		end
	end

	const function createModeButton(label, mode)
		const btn = makeButton(label)
		modeButtons[mode] = btn
		MouseButtonFix(btn, function()
			if actions.setMode then
				actions.setMode(mode)
			end
			refreshModeButtons()
		end)
		return btn
	end

	createModeButton("Delete", "delete")
	createModeButton("Toggle Anchor", "anchor")
	createModeButton("Toggle CanCollide", "collide")

	const undoButton = makeButton("Undo Delete")
	MouseButtonFix(undoButton, function()
		if actions.undo then
			actions.undo()
		end
	end)

	const copyButton = makeButton("Copy Delete Script")
	MouseButtonFix(copyButton, function()
		if actions.copy then
			actions.copy()
		end
	end)

	NAgui.dragger(frame, header)

	state.statusLabel = statusLabel
	state.frame = frame
	state.refreshModeButtons = refreshModeButtons
	refreshModeButtons()

	return gui
end

NAmanage.NAibtoolsCleanup=function(state)
	if not state then
		return
	end
	if state.connections then
		for _, conn in state.connections do
			if conn and conn.Disconnect then
				conn:Disconnect()
			end
		end
		table.clear(state.connections)
	end
	if state.highlight then
		pcall(function()
			state.highlight:Destroy()
		end)
		state.highlight = nil
	end
	if state.gui then
		pcall(function()
			state.gui:Destroy()
		end)
		state.gui = nil
	end
	state.statusLabel = nil
	state.frame = nil
	state.currentPart = nil
	state.refreshModeButtons = nil
end

cmd.add({"ibtools"}, {"ibtools", "Load the iBuild Tools helper tool"}, function()
	if not LocalPlayer then
		DoNotif("Local player not ready.", 3)
		return
	end

	local backpack = getBp()
	if not backpack then
		backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack", 3)
	end
	if not backpack then
		DoNotif("Backpack not available.", 3)
		return
	end

	local state = NAmanage._ibtools
	if state and state.tool and state.tool.Parent then
		DoNotif("iBTools is already loaded.", 3)
		return
	end

	const tool = InstanceNew("Tool", backpack)
	tool.Name = "iBTools"
	tool.RequiresHandle = false

	state = {
		tool = tool,
		history = {},
		saveHistory = {},
		connections = {},
		toolConnections = {},
		currentPart = nil,
		currentMode = "delete",
	}
	NAmanage._ibtools = state

	const function modeLabel()
		const mode = state.currentMode
		if not mode then
			return "none"
		end
		return mode
	end

	const function updateStatus(part)
		if not state.statusLabel then
			return
		end
		local targetText = "none"
		if part then
			if not part.Parent then
				targetText = part.Name.." (stored)"
			else
				local ok, fullName = pcall(part.GetFullName, part)
				targetText = ok and fullName or part.Name
			end
		end
		state.statusLabel.Text = Format("Mode: %s | Target: %s", modeLabel():upper(), targetText)
	end

	const function setTarget(part)
		if part and not part:IsA("BasePart") then
			part = nil
		end
		state.currentPart = part
		if state.highlight then
			state.highlight.Adornee = part
		end
		updateStatus(part)
	end

	const function onEquipped(mouse)
		NAmanage.NAibtoolsCleanup(state)

		const highlight = InstanceNew("SelectionBox")
		highlight.Name = "iBToolsSelection"
		highlight.LineThickness = 0.04
		highlight.Color3 = Color3.fromRGB(0, 170, 255)
		highlight.Adornee = nil
		highlight.Parent = Services.Workspace.CurrentCamera or Services.Workspace
		state.highlight = highlight

		const function undoLast()
			const record = table.remove(state.history)
			if not record then
				DoNotif("Nothing to undo.", 2)
				return
			end
			const part = record.part
			if part then
				part.Parent = record.parent
				if record.cframe then
					pcall(function()
						part.CFrame = record.cframe
					end)
				end
				setTarget(part)
				const saved = record.data
				if saved then
					for i = #state.saveHistory, 1, -1 do
						if state.saveHistory[i] == saved then
							table.remove(state.saveHistory, i)
							break
						end
					end
				end
				DoNotif("Restored '"..part.Name.."'", 2)
			end
		end

		const function copyScript()
			if #state.saveHistory == 0 then
				DoNotif("No deleted parts to export.", 3)
				return
			end
			const lines = { 'local Workspace = game:GetService("Workspace")' }
			for _, data in state.saveHistory do
				const pos = data.position
				const vec = NAmanage.NAibtoolsVectorString(pos)
				lines[#lines + 1] = Format(
					"for _,v in Workspace:FindPartsInRegion3(Region3.new(%s, %s), nil, math.huge) do if v.Name == %q then v:Destroy() end end",
					vec,
					vec,
					data.name
				)
			end
			const scriptText = Concat(lines, "\n")
			if setclipboard then
				setclipboard(scriptText)
				DoNotif("Copied delete script to clipboard.", 3)
			else
				DoWindow("Copy this script:\n\n"..scriptText)
			end
		end

		const function applyDelete(part)
			if not part or not part.Parent then
				DoNotif("Selected part is no longer available.", 3)
				setTarget(nil)
				return
			end
			const record = {
				part = part,
				parent = part.Parent,
				cframe = part.CFrame,
			}
			const data = {
				name = part.Name,
				position = part.Position,
			}
			record.data = data
			Insert(state.history, record)
			Insert(state.saveHistory, data)
			part.Parent = nil
			setTarget(nil)
			DoNotif("Deleted '"..part.Name.."'", 2)
		end

		const function applyAnchor(part)
			if not part or not part.Parent then
				DoNotif("Selected part is no longer available.", 3)
				setTarget(nil)
				return
			end
			part.Anchored = not part.Anchored
			updateStatus(part)
			DoNotif(Format("%s anchored %s", part.Name, part.Anchored and "enabled" or "disabled"), 2)
		end

		const function applyCollide(part)
			if not part or not part.Parent then
				DoNotif("Selected part is no longer available.", 3)
				setTarget(nil)
				return
			end
			part.CanCollide = not part.CanCollide
			updateStatus(part)
			DoNotif(Format("%s CanCollide %s", part.Name, part.CanCollide and "enabled" or "disabled"), 2)
		end

		const modeHandlers = {
			delete = applyDelete,
			anchor = applyAnchor,
			collide = applyCollide,
		}

		const function setMode(mode)
			if not modeHandlers[mode] then
				return
			end
			state.currentMode = mode
			if state.refreshModeButtons then
				state.refreshModeButtons()
			end
			updateStatus(state.currentPart)
		end

		const function applyMode(part)
			if not part or not part:IsA("BasePart") then
				DoNotif("Aim at a part first.", 3)
				return
			end
			setTarget(part)
			const handler = modeHandlers[state.currentMode or ""]
			if not handler then
				DoNotif("Select a mode first.", 3)
				return
			end
			handler(part)
		end

		const uiActions = {
			setMode = setMode,
			getMode = function()
				return state.currentMode
			end,
			undo = undoLast,
			copy = copyScript,
		}

		state.gui = NAmanage.NAibtoolsCreateUI(state, uiActions)
		if not modeHandlers[state.currentMode or ""] then
			state.currentMode = "delete"
		end
		setMode(state.currentMode)
		updateStatus(state.currentPart)

		const function refreshTarget()
			const target = NAmanage.GetMouseTargetPart(mouse, nil, 2048)
			if not (target and target:IsA("BasePart")) then
				if state.currentPart ~= nil then
					setTarget(nil)
				end
				return
			end
			if target ~= state.currentPart then
				setTarget(target)
			end
		end

		refreshTarget()

		Insert(state.connections, NAmanage.mouseMoveSub(mouse, {
			fn = refreshTarget,
			minInterval = 0.03,
			minDelta = 1,
		}))
		Insert(state.connections, mouse.Button1Down:Connect(function()
			const target = NAmanage.GetMouseTargetPart(mouse, nil, 2048)
			if target and target:IsA("BasePart") then
				applyMode(target)
			end
		end))
	end

	Insert(state.toolConnections, tool.Equipped:Connect(onEquipped))
	Insert(state.toolConnections, tool.Unequipped:Connect(function()
		NAmanage.NAibtoolsCleanup(state)
	end))
	Insert(state.toolConnections, tool.AncestryChanged:Connect(function(_, parent)
		if not parent then
			NAmanage.NAibtoolsCleanup(state)
			if NAmanage._ibtools == state then
				NAmanage._ibtools = nil
			end
		end
	end))

	DoNotif("iBTools loaded. Equip the tool to use it.", 3)
end)

cmd.add({"unibtools"}, {"unibtools", "Remove the iBuild Tools helper tool"}, function()
	const state = NAmanage._ibtools
	if not state then
		DoNotif("iBTools is not active.", 3)
		return
	end
	if state.tool then
		pcall(function()
			state.tool:Destroy()
		end)
	end
	NAmanage.NAibtoolsCleanup(state)
	if state.toolConnections then
		for _, conn in state.toolConnections do
			if conn and conn.Disconnect then
				conn:Disconnect()
			end
		end
		state.toolConnections = nil
	end
	NAmanage._ibtools = nil
	DoNotif("iBTools removed.", 3)
end)

cmd.add({"setfflag", "setff"}, {"setfflag <flag> <value> [save] (setff)", "Set a fast flag (use 'save' to store it)"}, function(flag, value, maybeSave)
	const title = "Set Fast Flag"
	if not flag or flag == "" then
		DoNotif("Usage: setfflag <flag> <value> [save]", 3, title)
		return
	end
	if value == nil then
		DoNotif("Please provide a fast flag value", 3, title)
		return
	end
	const parsedValue = NAFFlags.parseCustomValue and NAFFlags.parseCustomValue(value) or value
	local ok, err = NAFFlags.apply(flag, parsedValue, { allowDisabled = true, silent = true })
	if ok then
		local saveRequested = false
		if type(maybeSave) == "string" then
			const lowerSave = Lower(maybeSave)
			saveRequested = lowerSave == "save" or lowerSave == "persist" or lowerSave == "keep"
		end
		local suffix = ""
		if saveRequested then
			local savedOk, saveErr = NAFFlags.setCustomFlag(flag, parsedValue)
			if not savedOk then
				DoNotif(Format("Applied %s but could not save: %s", tostring(flag), tostring(saveErr or "unknown error")), 4, title)
			else
				suffix = " (saved)"
			end
		end
		DoNotif(Format("Set %s to %s%s", tostring(flag), tostring(parsedValue), suffix), 3, title)
	else
		DoNotif(Format("Failed to set %s: %s", tostring(flag), tostring(err or "unknown error")), 4, title)
	end
end, true)

NAgui.refAliasesCmds=function()
	if type(NAmanage.invalidateCommandBuild) == "function" then
		NAmanage.invalidateCommandBuild()
	end
	if type(NAmanage.queueCommandDataBuild) == "function" then
		pcall(NAmanage.queueCommandDataBuild, { force = true })
	elseif type(NAgui) == "table" and type(NAgui.loadCMDS) == "function" then
		pcall(NAgui.loadCMDS, { force = true })
	else
		pcall(NAmanage.rebuildSearchAliasCache)
	end
	if type(NAgui) == "table"
		and type(NAgui.commands) == "function"
		and NAUIMANAGER
		and NAUIMANAGER.commandsFrame
		and NAUIMANAGER.commandsFrame.Visible then
		pcall(NAgui.commands)
	end
end

cmd.add({"addalias"}, {"addalias <command> <alias>", "Adds a persistent alias for an existing command"}, function(original, alias)
	if not original or not alias then
		DoNotif("Usage: addalias <command> <alias>", 2)
		return
	end

	original, alias = original:lower(), alias:lower()
	const resolvedOriginal = NAmanage.resolveCommandName and NAmanage.resolveCommandName(original) or nil
	if resolvedOriginal then
		original = resolvedOriginal
	end

	if not cmds.Commands[original] then
		DoNotif("Command '"..original.."' does not exist", 2)
		return
	end

	if cmds.Commands[alias] or cmds.Aliases[alias] then
		DoNotif("The name '"..alias.."' is already used by another command or alias", 2)
		return
	end

	const command = cmds.Commands[original]
	cmds.Aliases[alias] = command
	cmds.NASAVEDALIASES[alias] = original

	if FileSupport then
		const aliasMap = NAmanage.readAliasFile()
		aliasMap[alias] = original
		writefile(NAfiles.NAALIASPATH, Services.HttpService:JSONEncode(aliasMap))
	end

	DoNotif("Alias '"..alias.."' has been added for command '"..original.."'", 2)
	if not FileSupport then
		DebugNotif("Alias stored for this session only (no file support detected).")
	end
	NAgui.refAliasesCmds()
end, true)

cmd.add({"removealias"}, {"removealias", "Select and remove a saved alias"}, function()
	const combined = {}

	if FileSupport then
		for alias, original in NAmanage.readAliasFile() do
			if type(alias) == "string" and type(original) == "string" then
				combined[alias:lower()] = original:lower()
			end
		end
	end

	for alias, original in cmds.NASAVEDALIASES do
		if type(alias) == "string" and type(original) == "string" then
			combined[alias:lower()] = original:lower()
		end
	end

	if next(combined) == nil then
		DoNotif("No saved aliases to remove", 2)
		return
	end

	const buttons = {}
	for alias, original in combined do
		Insert(buttons, {
			Text = 'Alias: '..alias.." | Command: "..original,
			Callback = function()
				cmds.Aliases[alias] = nil
				cmds.NASAVEDALIASES[alias] = nil
				combined[alias] = nil
				if FileSupport then
					writefile(NAfiles.NAALIASPATH, Services.HttpService:JSONEncode(combined))
				end
				DoNotif(("Removed alias '%s'"):format(alias), 2)
				NAgui.refAliasesCmds()
			end
		})
	end

	Window({
		Title = "Remove Alias",
		Description = "Select an alias to remove:",
		Buttons = buttons
	})
end)

cmd.add({"clearaliases"}, {"clearaliases", "Removes all aliases created using addalias."}, function()
	if next(cmds.NASAVEDALIASES) == nil then
		DoNotif("No saved aliases to clear", 2)
		return
	end

	for alias in cmds.NASAVEDALIASES do
		cmds.Aliases[alias] = nil
	end

	cmds.NASAVEDALIASES = {}

	if FileSupport then
		writefile(NAfiles.NAALIASPATH, "{}")
	else
		DebugNotif("Aliases cleared for this session (no file support).")
	end

	DoNotif("All aliases have been removed", 2)
	NAgui.refAliasesCmds()
end)

cmd.add({"addbutton", "ab"}, {"addbutton <command> <label> [<command2>] (ab)", "Add a mobile button"}, function(arg1, arg2, arg3)
	if not arg1 or not arg2 then
		DoNotif("Usage: ;addbutton <command> <label> [<command2>]", 2)
		return
	end

	const id = NAUserButtonNextId()
	NAUserButtons[id] = {
		Cmd1 = arg1,
		Label = arg2,
		Cmd2 = arg3
	}

	NAmanage.UserButtonsSave("add button")

	NAmanage.RenderUserButtons()

	DoNotif("Added button with id "..id, 2)
end,true)

cmd.add({"removebutton", "rb"}, {"removebutton (rb)", "Remove a user button"}, function()
	if not next(NAUserButtons) then
		DoNotif("No user buttons to remove", 2)
		return
	end

	const function saveAndRender()
		NAmanage.UserButtonsSave("remove button")
		if type(NAmanage.RenderUserButtons) == "function" then
			NAmanage.RenderUserButtons()
		end
	end

	const function getLabel(data, fallback)
		local label = data and data.Label
		if type(label) ~= "string" or label == "" then
			label = fallback
		end
		return label
	end

	const function getCmdDisplay(cmd1, cmd2)
		local cmdDisplay = cmd1 or "?"
		if cmd2 then
			cmdDisplay = cmdDisplay.." / "..cmd2
		end
		return cmdDisplay
	end

	const function removeEntry(id, label)
		NAUserButtons[id] = nil
		originalIO.clearUserButtonState(id)
		saveAndRender()
		DoNotif("Removed user button: ["..id.."] "..label, 2)
	end

	const function removeGroup(id, label)
		NAUserButtons[id] = nil
		originalIO.clearUserButtonState(id)
		saveAndRender()
		DoNotif("Removed group: ["..id.."] "..label, 2)
	end

	const function openGroupChildRemove(groupId)
		const group = NAUserButtons[groupId]
		if not (type(group) == "table" and group.Type == "group") then
			DoNotif("Group not found", 2)
			return
		end

		const children = (type(group.Children) == "table") and group.Children or {}
		if #children == 0 then
			DoNotif("Group has no children", 2)
			return
		end

		const groupLabel = getLabel(group, "Group "..groupId)
		const options = {}

		for childIndex, child in children do
			const childLabel = getLabel(child, "Action "..childIndex)
			const cmdDisplay = getCmdDisplay(child.Cmd1, child.Cmd2)
			const index = childIndex
			Insert(options, {
				Text = "["..index.."] "..childLabel.." ("..cmdDisplay..")",
				Callback = function()
					const groupNow = NAUserButtons[groupId]
					if not (type(groupNow) == "table" and groupNow.Type == "group") then
						DoNotif("Group not found", 2)
						return
					end
					const childrenNow = (type(groupNow.Children) == "table") and groupNow.Children or {}
					if index < 1 or index > #childrenNow then
						DoNotif("Child not found", 2)
						return
					end
					const removed = table.remove(childrenNow, index)
					if #childrenNow == 0 then
						NAUserButtons[groupId] = nil
						originalIO.clearUserButtonState(groupId)
						saveAndRender()
						DoNotif("Removed group: ["..groupId.."] "..groupLabel, 2)
						return
					end
					groupNow.Children = childrenNow
					originalIO.clearUserButtonChildState(groupId, index)
					saveAndRender()
					const removedLabel = (removed and removed.Label) or childLabel
					DoNotif("Removed child: "..tostring(removedLabel), 2)
				end
			})
		end

		Window({
			Title = "Remove Group Child",
			Description = "Select a child to remove from ["..groupId.."] "..groupLabel..":",
			Buttons = options
		})
	end

	const function openGroupMenu(groupId)
		const group = NAUserButtons[groupId]
		if not (type(group) == "table" and group.Type == "group") then
			return
		end

		const groupLabel = getLabel(group, "Group "..groupId)
		const children = (type(group.Children) == "table") and group.Children or {}
		const count = #children
		const options = {}

		Insert(options, {
			Text = "Remove Group (delete all children)",
			Callback = function()
				removeGroup(groupId, groupLabel)
			end
		})

		if count > 0 then
			Insert(options, {
				Text = "Remove Child",
				Callback = function()
					openGroupChildRemove(groupId)
				end
			})

			Insert(options, {
				Text = "Ungroup (keep children)",
				Callback = function()
					local ok, msg = NAmanage.UserButtons_Ungroup(groupId)
					if ok then
						if type(NAmanage.RenderUserButtons) == "function" then
							NAmanage.RenderUserButtons()
						end
						DoNotif(msg or "Ungrouped", 2)
					else
						DoNotif(msg or "Failed to ungroup", 3)
					end
				end
			})
		end

		Window({
			Title = "Manage Group",
			Description = Format("Group [%d] %s (%d child%s)", groupId, groupLabel, count, count == 1 and "" or "ren"),
			Buttons = options
		})
	end

	const ids = {}
	for id, data in NAUserButtons do
		if type(id) == "number" and type(data) == "table" then
			Insert(ids, id)
		end
	end
	table.sort(ids)

	const options = {}
	for _, id in ids do
		const data = NAUserButtons[id]
		if data.Type == "group" then
			const label = getLabel(data, "Group "..id)
			const count = (type(data.Children) == "table") and #data.Children or 0
			const mode = (data.GroupMode == "side") and "side" or "dropdown"
			Insert(options, {
				Text = Format("[%d] %s (group: %d, %s)", id, label, count, mode),
				Callback = function()
					openGroupMenu(id)
				end
			})
		else
			const label = getLabel(data, "Button "..id)
			const cmdDisplay = getCmdDisplay(data.Cmd1, data.Cmd2)
			Insert(options, {
				Text = Format("[%d] %s (%s)", id, label, cmdDisplay),
				Callback = function()
					removeEntry(id, label)
				end
			})
		end
	end

	Window({
		Title = "Remove User Button",
		Description = "Select a button or group to manage:",
		Buttons = options
	})
end)

cmd.add({"clearbuttons", "clearbtns", "cb"}, {"clearbuttons (clearbtns, cb)", "Clear all user buttons"}, function()
	if not next(NAUserButtons) then
		DoNotif("No user buttons to clear", 2)
		return
	end

	Window({
		Title = "Clear All Buttons",
		Description = "Are you sure you want to clear all user buttons?",
		Buttons = {
			{
				Text = "Yes",
				Callback = function()
					table.clear(NAUserButtons)
					table.clear(UserButtonToggleState)

					NAmanage.UserButtonsSave("clear buttons")

					NAmanage.RenderUserButtons()

					DoNotif("Cleared all user buttons", 2)
				end
			}
		}
	})
end)

NAmanage.EnsureAEX = function()
	NAEXECDATA = NAEXECDATA or { commands = {}, args = {} }
	if type(NAEXECDATA.commands) ~= "table" then
		NAEXECDATA.commands = {}
	end
	if type(NAEXECDATA.args) ~= "table" then
		NAEXECDATA.args = {}
	end
	return NAEXECDATA
end

NAmanage.FmtAExec = function(cmdName, argTxt)
	const argsTxt = type(argTxt) == "string" and argTxt or tostring(argTxt or "")
	return argsTxt ~= "" and (tostring(cmdName).." "..argsTxt) or tostring(cmdName)
end

NAmanage.GetAExec = function()
	const data = NAmanage.EnsureAEX()
	const entries = {}

	for i = 1, #data.commands do
		const it = data.commands[i]
		local cmdName, argStr

		if type(it) == "table" then
			cmdName = it.c
			argStr = it.a or ""
		elseif type(it) == "string" then
			cmdName = NAmanage.resolveCommandName(it:lower()) or it:lower()
			argStr = (data.args and (data.args[it] or data.args[cmdName])) or ""
		end

		if type(cmdName) == "string" then
			if type(argStr) ~= "string" then
				argStr = tostring(argStr or "")
			end
			Insert(entries, {
				index = i,
				command = cmdName,
				args = argStr,
				display = NAmanage.FmtAExec(cmdName, argStr),
			})
		end
	end

	return entries
end

NAmanage.FindAEX = function(tCmd, tArgs)
	tArgs = type(tArgs) == "string" and tArgs or tostring(tArgs or "")
	const entries = NAmanage.GetAExec()
	for i = 1, #entries do
		const entry = entries[i]
		if entry.command == tCmd and entry.args == tArgs then
			return entry.index
		end
	end
end

NAmanage.AddAEX = function(arg1, ...)
	if not arg1 then
		return false, "Usage: ;addautoexec <command> [arguments...]"
	end

	const rawName = Lower(tostring(arg1))
	const canonical = NAmanage.resolveCommandName(rawName)
	if not canonical then
		return false, "Command ["..rawName.."] does not exist"
	end
	if NAStuff.AutoExecBlockedCommands[canonical] then
		return false, "Command ["..canonical.."] is blocked."
	end

	const args = { ... }
	const argStr = (#args > 0) and Concat(args, " ") or ""
	const data = NAmanage.EnsureAEX()

	if NAmanage.FindAEX(canonical, argStr) then
		return false, "Already in AutoExec: "..NAmanage.FmtAExec(canonical, argStr)
	end

	Insert(data.commands, { c = canonical, a = argStr })

	if not NAmanage.AutoExecSave(data) then
		DebugNotif("Failed to save AutoExec changes; they will reset after this session.")
	end

	return true, NAmanage.FmtAExec(canonical, argStr)
end

NAmanage.AddAEXTxt = function(rawTxt)
	const parsed = ParseArguments(tostring(rawTxt or ""))
	if type(parsed) ~= "table" or not parsed[1] then
		return false, "Enter a command to add."
	end

	const cmdName = parsed[1]
	table.remove(parsed, 1)

	return NAmanage.AddAEX(cmdName, Unpack(parsed))
end

NAmanage.DelAEX = function(tCmd, tArgs)
	const data = NAmanage.EnsureAEX()
	const eidx = NAmanage.FindAEX(tCmd, tArgs)
	if not eidx then
		return false, "Unable to remove AutoExec command."
	end

	const removed = table.remove(data.commands, eidx)
	if not removed then
		return false, "Unable to remove AutoExec command."
	end

	if not NAmanage.AutoExecSave(data) then
		DebugNotif("Failed to save AutoExec changes; they will reset after this session.")
	end

	return true, NAmanage.FmtAExec(tCmd, tArgs)
end

NAmanage.ClrAEX = function()
	const data = NAmanage.EnsureAEX()
	if #data.commands == 0 then
		return false, "No AutoExec commands to clear"
	end

	const clearedCount = #data.commands
	table.clear(data.commands)
	data.args = {}

	if not NAmanage.AutoExecSave(data) then
		DebugNotif("Failed to save AutoExec changes; they will reset after this session.")
	end

	return true, clearedCount
end

cmd.add({"addautoexec", "aaexec", "addae", "addauto", "aexecadd"}, {"addautoexec <command> [arguments] (aaexec, addae, addauto, aexecadd)", "Add a command to autoexecute"}, function(arg1, ...)
	local ok, message = NAmanage.AddAEX(arg1, ...)
	if not ok then
		DoNotif(message, 2)
		return
	end

	DoNotif("Added to AutoExec: "..message, 2)
end, true)

cmd.add({"removeautoexec", "raexec", "removeae", "removeauto", "aexecremove"}, {"removeautoexec (raexec, removeae, removeauto, aexecremove)", "Remove a command from autoexecute"}, function()
	const entries = NAmanage.GetAExec()
	if #entries == 0 then
		DoNotif("No AutoExec commands to remove", 2)
		return
	end

	const options = {}
	for i = 1, #entries do
		const entry = entries[i]
		Insert(options, {
			Text = entry.display,
			Callback = function()
				local ok, message = NAmanage.DelAEX(entry.command, entry.args)
				if not ok then
					DoNotif(message, 2)
					return
				end
				DoNotif("Removed AutoExec command: "..message, 2)
			end
		})
	end

	Window({
		Title = "Remove AutoExec Command",
		Description = "Select which AutoExec to remove:",
		Buttons = options
	})
end)

cmd.add({"clearautoexec", "caexec", "clearauto", "autoexecclear", "aexecclear", "aeclear"}, {"clearautoexec (caexec, clearauto, autoexecclear, aexecclear, aeclear)", "Clear all AutoExec commands"}, function()
	const entries = NAmanage.GetAExec()
	if #entries == 0 then
		DoNotif("No AutoExec commands to clear", 2)
		return
	end

	Window({
		Title = "Clear AutoExec Commands",
		Description = "Are you sure you want to clear all AutoExec commands?",
		Buttons = {
			{
				Text = "Yes",
				Callback = function()
					local ok, message = NAmanage.ClrAEX()
					if not ok then
						DoNotif(message, 2)
						return
					end
					DoNotif("Cleared all AutoExec commands", 2)
				end
			}
		}
	})
end)

cmd.add({"executor","exec"},{"executor (exec)","Toggle the integrated executor UI"},function()
	NAmanage.Executor_Toggle()
end)

cmd.add({"lastcommand","lastcmd"},{"lastcommand (lastcmd)","Re-run your previously executed command"},function()
	local last=NAStuff._lastCommand
	local first = last and last[1]
	local lowerFirst = (type(first) == "string") and Lower(first) or nil
	if not lowerFirst or lowerFirst == "lastcommand" or lowerFirst == "lastcmd" then
		last = NAStuff._prevCommand
		first = last and last[1]
		lowerFirst = (type(first) == "string") and Lower(first) or nil
	end
	if type(last) ~= "table" or not lowerFirst or #last==0 then
		DoNotif("No previous command recorded",2)
		return
	end
	const replay=NAmanage.cloneArgsArray(last)
	if #replay == 0 then
		DoNotif("No previous command recorded",2)
		return
	end
	SpawnCall(function()
		cmd.run(replay)
	end)
end)

cmd.add({"ifundone","ifnotdone","ifnew"},{"ifundone <command> [arguments]","Runs a command only if that exact command has not been done this session"},function(...)
	const targetArgs = {...}
	const targetName = targetArgs[1]
	if type(targetName) ~= "string" or targetName == "" then
		DoNotif("Usage: ifundone <command> [arguments]", 3)
		return
	end

	const lowerTarget = Lower(targetName)
	if lowerTarget == "ifundone" or lowerTarget == "ifnotdone" or lowerTarget == "ifnew" then
		DoNotif("ifundone cannot target itself.", 3)
		return
	end

	if not (cmds.Commands[lowerTarget] or cmds.Aliases[lowerTarget]) then
		DoNotif("Command '"..targetName.."' does not exist.", 3)
		return
	end

	if NAmanage.commandWasDone(targetArgs) then
		DebugNotif("Skipped already-done command: "..Concat(targetArgs, " "), 2)
		return
	end

	cmd.run(targetArgs)
end,true)

cmd.add({"commandloop", "cmdloop"}, {"commandloop <command> {arguments} (cmdloop)", "Run a command on loop"}, function(...)
	const args = {...}
	const commandName = args[1]
	table.remove(args, 1)

	if not commandName then
		DoNotif("Command name is required.",3)
		return
	end

	cmd.loop(commandName, args)
end,true)

cmd.add({"stoploop", "uncmdloop", "sloop", "stopl"}, {"stoploop", "Stop a running loop"}, function()
	cmd.stopLoop()
end)

cmd.add({"scripthub","hub"},{"scripthub (hub)","Open the built-in Script Hub using RScripts, RobloxScripts, HaxHell, and ScriptBlox"},function()
	if NAmanage.ScriptHub_Toggle then
		NAmanage.ScriptHub_Toggle()
	else
		DoNotif("Script Hub UI unavailable.", 3, "Script Hub")
	end
end)

cmd.add({"gamescripts", "supportedscripts", "gamesupport"}, {"gamescripts [refresh/on/off] (supportedscripts, gamesupport)", "Show scripts listed for the current game"}, function(mode)
	mode = Lower(tostring(mode or ""))
	if mode == "on" or mode == "enable" then
		NAmanage.jlCfg.SupportedGameNotif = true
		NAmanage.jlSave()
		DoNotif("Supported game alerts enabled.", 3, "Supported Game Scripts")
		return NAmanage.NotifySupportedGameScripts({ force = true })
	elseif mode == "off" or mode == "disable" then
		NAmanage.jlCfg.SupportedGameNotif = false
		NAmanage.jlSave()
		DoNotif("Supported game alerts disabled.", 3, "Supported Game Scripts")
		return
	end
	NAmanage.ShowSupportedGameScripts({ refresh = mode == "refresh" })
end)

scaleFrame = nil
cmd.add({"uiscale", "uscale", "guiscale", "gscale"}, {"uiscale (uscale)", "Adjust the scale of the "..adminName.." UI"}, function()
	NAlib.disconnect("uiscale_ui")
	if scaleFrame then
		pcall(function()
			scaleFrame:Destroy()
		end)
		scaleFrame = nil
	end

	const gui = InstanceNew("ScreenGui")
	const frame = InstanceNew("Frame")
	const frameCorner = InstanceNew("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 6)
	const frameStroke = InstanceNew("UIStroke")
	const sizeConstraint = InstanceNew("UISizeConstraint")
	const dragHandle = InstanceNew("Frame")
	const title = InstanceNew("TextLabel")
	const closeButton = InstanceNew("TextButton")
	const closeCorner = InstanceNew("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	const valueLabel = InstanceNew("TextLabel")
	const slider = InstanceNew("TextButton")
	const sliderCorner = InstanceNew("UICorner")
	sliderCorner.CornerRadius = UDim.new(0, 6)
	const progress = InstanceNew("Frame")
	const progressCorner = InstanceNew("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 6)
	const knob = InstanceNew("TextButton")
	const knobCorner = InstanceNew("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 6)
	const knobStroke = InstanceNew("UIStroke")
	const minLabel = InstanceNew("TextLabel")
	const maxLabel = InstanceNew("TextLabel")
	const decreaseButton = InstanceNew("TextButton")
	const decreaseCorner = InstanceNew("UICorner")
	decreaseCorner.CornerRadius = UDim.new(0, 6)
	const resetButton = InstanceNew("TextButton")
	const resetCorner = InstanceNew("UICorner")
	resetCorner.CornerRadius = UDim.new(0, 6)
	const increaseButton = InstanceNew("TextButton")
	const increaseCorner = InstanceNew("UICorner")
	increaseCorner.CornerRadius = UDim.new(0, 6)

	const minSize, maxSize = NA_UI_SCALE_MIN, NA_UI_SCALE_MAX
	const increment = 0.05
	const range = maxSize - minSize
	local dragging = false
	local activeDragInput = nil
	local activeDragType = nil
	local cleaning = false

	scaleFrame = gui
	NAgui.NaProtectUI(gui)

	frame.Parent = gui
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0.88, 0, 0, 170)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.03
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = false
	frame.Active = true

	frameCorner.CornerRadius = UDim.new(0, 6)
	frameCorner.Parent = frame

	frameStroke.Parent = frame
	frameStroke.Color = Color3.fromRGB(85, 85, 85)
	frameStroke.Thickness = 1
	frameStroke.Transparency = 0.15

	sizeConstraint.Parent = frame
	sizeConstraint.MinSize = Vector2.new(280, 170)
	sizeConstraint.MaxSize = Vector2.new(440, 170)

	dragHandle.Parent = frame
	dragHandle.Size = UDim2.new(1, -54, 0, 42)
	dragHandle.Position = UDim2.new(0, 0, 0, 0)
	dragHandle.BackgroundTransparency = 1
	dragHandle.Active = true

	title.Parent = dragHandle
	title.Size = UDim2.new(1, -16, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "UI Scale"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamSemibold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left

	closeButton.Parent = frame
	closeButton.AnchorPoint = Vector2.new(1, 0)
	closeButton.Position = UDim2.new(1, -10, 0, 10)
	closeButton.Size = UDim2.new(0, 32, 0, 32)
	closeButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
	closeButton.Text = "×"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.BorderSizePixel = 0
	closeButton.AutoButtonColor = false
	closeButton.ZIndex = 8

	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton

	valueLabel.Parent = frame
	valueLabel.AnchorPoint = Vector2.new(0.5, 0)
	valueLabel.Position = UDim2.new(0.5, 0, 0, 43)
	valueLabel.Size = UDim2.new(1, -40, 0, 25)
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueLabel.Font = Enum.Font.GothamMedium
	valueLabel.TextSize = 18
	valueLabel.TextXAlignment = Enum.TextXAlignment.Center

	slider.Parent = frame
	slider.AnchorPoint = Vector2.new(0.5, 0.5)
	slider.Position = UDim2.new(0.5, 0, 0, 84)
	slider.Size = UDim2.new(1, -64, 0, 12)
	slider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	slider.Text = ""
	slider.BorderSizePixel = 0
	slider.AutoButtonColor = false
	slider.Active = true
	slider.ClipsDescendants = false
	slider.ZIndex = 3

	sliderCorner.CornerRadius = UDim.new(0, 6)
	sliderCorner.Parent = slider

	progress.Parent = slider
	progress.AnchorPoint = Vector2.new(0, 0.5)
	progress.Position = UDim2.new(0, 0, 0.5, 0)
	progress.Size = UDim2.new(0, 0, 1, 0)
	progress.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	progress.BorderSizePixel = 0
	progress.ZIndex = 4

	progressCorner.CornerRadius = UDim.new(0, 6)
	progressCorner.Parent = progress

	knob.Parent = slider
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.Position = UDim2.new(0, 0, 0.5, 0)
	knob.Size = UDim2.new(0, 24, 0, 24)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = false
	knob.Active = true
	knob.ZIndex = 6

	knobCorner.CornerRadius = UDim.new(0, 6)
	knobCorner.Parent = knob

	knobStroke.Parent = knob
	knobStroke.Color = Color3.fromRGB(20, 20, 20)
	knobStroke.Thickness = 2
	knobStroke.Transparency = 0

	minLabel.Parent = frame
	minLabel.Position = UDim2.new(0, 32, 0, 96)
	minLabel.Size = UDim2.new(0, 70, 0, 18)
	minLabel.BackgroundTransparency = 1
	minLabel.Text = Format("%.2f", minSize)
	minLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
	minLabel.Font = Enum.Font.Gotham
	minLabel.TextSize = 12
	minLabel.TextXAlignment = Enum.TextXAlignment.Left

	maxLabel.Parent = frame
	maxLabel.AnchorPoint = Vector2.new(1, 0)
	maxLabel.Position = UDim2.new(1, -32, 0, 96)
	maxLabel.Size = UDim2.new(0, 70, 0, 18)
	maxLabel.BackgroundTransparency = 1
	maxLabel.Text = Format("%.2f", maxSize)
	maxLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
	maxLabel.Font = Enum.Font.Gotham
	maxLabel.TextSize = 12
	maxLabel.TextXAlignment = Enum.TextXAlignment.Right

	const function styleControl(button, corner, text, width)
		button.Parent = frame
		button.AnchorPoint = Vector2.new(0.5, 0)
		button.Size = UDim2.new(0, width, 0, 32)
		button.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Font = Enum.Font.GothamSemibold
		button.TextSize = 14
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.ZIndex = 5
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = button
	end

	styleControl(decreaseButton, decreaseCorner, "−", 48)
	decreaseButton.Position = UDim2.new(0.5, -92, 0, 126)
	decreaseButton.TextSize = 20

	styleControl(resetButton, resetCorner, "Reset", 112)
	resetButton.Position = UDim2.new(0.5, 0, 0, 126)

	styleControl(increaseButton, increaseCorner, "+", 48)
	increaseButton.Position = UDim2.new(0.5, 92, 0, 126)
	increaseButton.TextSize = 20

	const function quantize(value)
		const clamped = math.clamp(tonumber(value) or NAUIScale, minSize, maxSize)
		const steps = math.floor(((clamped - minSize) / increment) + 0.5)
		return math.clamp(minSize + steps * increment, minSize, maxSize)
	end

	const function update(scale)
		const clamped = NAmanage.ApplyUIScale(quantize(scale), { save = false, syncUI = false })
		const percent = range > 0 and math.clamp((clamped - minSize) / range, 0, 1) or 0
		progress.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, 0, 0.5, 0)
		valueLabel.Text = "Scale: "..Format("%.2f", clamped).."×"
		return clamped
	end

	const function commit(scale)
		const clamped = update(scale)
		NAmanage.ApplyUIScale(clamped, { save = true, syncUI = true })
		return clamped
	end

	const function updateFromPointerX(pointerX)
		const width = slider.AbsoluteSize.X
		if width <= 0 then
			return
		end
		const percent = math.clamp((pointerX - slider.AbsolutePosition.X) / width, 0, 1)
		update(minSize + range * percent)
	end

	const function beginDrag(input)
		const inputType = input.UserInputType
		if inputType ~= Enum.UserInputType.MouseButton1 and inputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		activeDragInput = input
		activeDragType = inputType
		updateFromPointerX(input.Position.X)
	end

	const function endDrag()
		if not dragging then
			return
		end
		dragging = false
		activeDragInput = nil
		activeDragType = nil
		NAmanage.ApplyUIScale(NAUIScale, { save = true, syncUI = true })
	end

	const function cleanup(destroyGui)
		if cleaning then
			return
		end
		cleaning = true
		dragging = false
		activeDragInput = nil
		activeDragType = nil
		NAlib.disconnect("uiscale_ui")
		if scaleFrame == gui then
			scaleFrame = nil
		end
		if destroyGui and gui then
			pcall(function()
				gui:Destroy()
			end)
		end
	end

	update(NAUIScale)

	NAlib.connect("uiscale_ui", slider.InputBegan:Connect(beginDrag))
	NAlib.connect("uiscale_ui", knob.InputBegan:Connect(beginDrag))
	NAlib.connect("uiscale_ui", Services.UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if activeDragType == Enum.UserInputType.Touch then
			if input == activeDragInput then
				updateFromPointerX(input.Position.X)
			end
		elseif activeDragType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromPointerX(input.Position.X)
		end
	end))
	NAlib.connect("uiscale_ui", Services.UserInputService.InputEnded:Connect(function(input)
		if not dragging then
			return
		end
		if activeDragType == Enum.UserInputType.Touch then
			if input == activeDragInput then
				endDrag()
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			endDrag()
		end
	end))
	NAlib.connect("uiscale_ui", gui.AncestryChanged:Connect(function(_, parent)
		if not parent then
			cleanup(false)
		end
	end))
	NAlib.connect("uiscale_ui", MouseButtonFix(decreaseButton, function()
		commit(NAUIScale - increment)
	end))
	NAlib.connect("uiscale_ui", MouseButtonFix(resetButton, function()
		commit(1)
	end))
	NAlib.connect("uiscale_ui", MouseButtonFix(increaseButton, function()
		commit(NAUIScale + increment)
	end))
	NAlib.connect("uiscale_ui", MouseButtonFix(closeButton, function()
		commit(NAUIScale)
		cleanup(true)
	end))

	NAgui.draggerV2(frame, dragHandle)
end)

cmd.add({"prefix"}, {"prefix <symbol>", "Changes the admin prefix"}, function(...)
	const newPrefix = (...)
	if not newPrefix or newPrefix == "" then
		DoNotif("Please enter a valid prefix")
	elseif utf8.len(newPrefix) > 1 then
		DoNotif("Prefix must be a single character (e.g. ; . !)")
	elseif newPrefix:match("[%w]") then
		DoNotif("Prefix cannot contain letters or numbers")
	elseif newPrefix:match("[%[%]%(%)%*%^%$%%{}<>]") then
		DoNotif("That symbol is not allowed as a prefix")
	elseif newPrefix:match("&amp;") or newPrefix:match("&lt;") or newPrefix:match("&gt;") or newPrefix:match("&quot;") or newPrefix:match("&#x27;") or newPrefix:match("&#x60;") then
		DoNotif("Encoded/HTML characters are not allowed as a prefix")
	else
		opt.prefix = newPrefix
		DoNotif("Prefix set to: "..newPrefix)
		if NAmanage.SyncPrefixUI then
			NAmanage.SyncPrefixUI()
		end
	end
end, true)

cmd.add({"saveprefix"}, {"saveprefix <symbol>", "Saves the prefix to a file and applies it"}, function(...)
	const newPrefix = (...)
	if not newPrefix or newPrefix == "" then
		DoNotif("Please enter a valid prefix")
	elseif utf8.len(newPrefix) > 1 then
		DoNotif("Prefix must be a single character (e.g. ; . !)")
	elseif newPrefix:match("[%w]") then
		DoNotif("Prefix cannot contain letters or numbers")
	elseif newPrefix:match("[%[%]%(%)%*%^%$%%{}<>]") then
		DoNotif("That symbol is not allowed as a prefix")
	elseif newPrefix:match("&amp;") or newPrefix:match("&lt;") or newPrefix:match("&gt;") or newPrefix:match("&quot;") or newPrefix:match("&#x27;") or newPrefix:match("&#x60;") then
		DoNotif("Encoded/HTML characters are not allowed as a prefix")
	else
		NAmanage.NASettingsSet("prefix", newPrefix)
		opt.prefix = newPrefix
		DoNotif("Prefix saved to: "..newPrefix)
		if not FileSupport then
			DebugNotif("Prefix will reset when Roblox closes (no file support detected).")
		end
		if NAmanage.SyncPrefixUI then
			NAmanage.SyncPrefixUI()
		end
	end
end, true)

--[ UTILITY ]--

cmd.add({"chatlogs","clogs"},{"chatlogs (clogs)","Open the chat logs"},function()
	NAgui.chatlogs()
end)
cmd.add({"music","musicplayer","songplayer"},{"music (musicplayer)","Open the NA music player"},function()
	if NAmanage and NAmanage.MusicWindow_Open then
		NAmanage.MusicWindow_Open()
	else
		DoNotif("Music player UI unavailable.", 3, "Music")
	end
end)


cmd.add({"gotocampos","tocampos","tcp"},{"gotocampos (tocampos,tcp)","Teleports you to your camera position works with free cam but freezes you"},function()
	const player=Services.Players.LocalPlayer
	function teleportPlayer()
		const character=player.Character or player.CharacterAdded:wait(1)
		const camera=Services.Workspace.CurrentCamera
		const cameraPosition=camera.CFrame.Position
		NAmanage.UG_pivotModel(character, CFrame.new(cameraPosition))
	end
	const camera=Services.Workspace.CurrentCamera
	repeat Wait() until camera.CFrame~=CFrame.new()

	teleportPlayer()
end)

cmd.add({"teleportgui","tpui","universeviewer","uviewer"},{"teleportgui","Open the universe subplace and public-server viewer"},function()
	if NAmanage.SubplaceViewer_Toggle then
		NAmanage.SubplaceViewer_Toggle()
	else
		DoNotif("Subplace Viewer UI unavailable.", 3, "Subplace Viewer")
	end
end)

cmd.add({"imagescanner","imgscanner","imgscan","imgs","images"},{"imagescanner","Gives an UI that grabs all images on the game"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/ImageScanner.lua");
end)

cmd.add({"audiologger","alogger","audiol","alog","al"},{"audiologger","Gives an UI that grabs all audios on the game"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/AudioLogger.luau");
end)

cmd.add({"serverremotespy","srs","sremotespy"},{"serverremotespy (srs,sremotespy)","Gives an UI that logs all the remotes being called from the server (thanks SolSpy lol)"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Server%20Spy.lua")
end)

NAmanage.RunSmokeRepo = NAmanage.RunSmokeRepo or function(fileName)
	const clean = tostring(fileName or "")
	if clean == "" then
		return
	end
	if type(IsR6) == "function" and not IsR6() then
		DoNotif("Smoke commands require R6.", 3)
		return
	end
	const char = LocalPlayer and LocalPlayer.Character
	const hum = char and char:FindFirstChildOfClass("Humanoid",true)
	const torso = char and char:FindFirstChild("Torso",true)
	if hum and torso and (not torso:FindFirstChild("Left Shoulder",true) or not torso:FindFirstChild("Right Shoulder",true)) then
		pcall(function()
			hum:UnequipTools()
		end)
		const deadline = os.clock() + 1.5
		repeat
			Wait()
		until (torso:FindFirstChild("Left Shoulder",true) and torso:FindFirstChild("Right Shoulder",true)) or os.clock() >= deadline
	end
	if torso and (not torso:FindFirstChild("Left Shoulder",true) or not torso:FindFirstChild("Right Shoulder",true)) then
		DoNotif("Wait for your current smoke tool to unequip, then try again.", 3)
		return
	end
	const url = "https://raw.githubusercontent.com/ltseverydayyou/NA-Plugins/main/"..clean
	local ok, err = pcall(function()
		NAmanage.RunURL(url)
	end)
	if not ok then
		DoNotif("Failed to load smoke script: "..tostring(err), 3)
	end
end

cmd.add({"cig", "givecig", "cigarette"}, {"cig (givecig,cigarette)", "Gives a cigarette pack (client R6)"}, function()
	NAmanage.RunSmokeRepo("Cigs.lua")
end)

cmd.add({"cigar", "givecigar"}, {"cigar (givecigar)", "Gives a cigar (client R6)"}, function()
	NAmanage.RunSmokeRepo("cigar.lua")
end)

cmd.add({"pipe", "givepipe"}, {"pipe (givepipe)", "Gives a smoking pipe (client R6)"}, function()
	NAmanage.RunSmokeRepo("Pipe.lua")
end)

cmd.add({"discord", "invite", "support", "help"}, {"discord", "Copy an invite link"}, function()
	const inviteLink = NAmanage._sourceGlyph(NAStuff.inviteLink)
	if setclipboard then
		Window({
			Title = "Discord",
			Description = inviteLink,
			Buttons = {
				{Text = "Copy Link", Callback = function() setclipboard(inviteLink) end},
				{Text = "Close", Callback = function() end}
			}
		})
	else
		Window({
			Title = "Discord",
			Description = "Your exploit does not support setclipboard.\nPlease manually type the invite link: "..inviteLink,
			Buttons = {
				{Text = "Close", Callback = function() end}
			}
		})
	end
	--DoNotif("not available yet", 2)
end)

clickflingUI = nil
clickflingEnabled = true

cmd.add({"clickfling","mousefling"},{"clickfling (mousefling)","Fling a player by clicking them"},function()
	clickflingEnabled = true
	if clickflingUI then clickflingUI:Destroy() end
	NAlib.disconnect("clickfling_mouse")

	const Mouse = NAmanage.GetMouse(player)
	clickflingUI = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(clickflingUI)

	const toggleButton = InstanceNew("TextButton")
	toggleButton.Size = UDim2.new(0,120,0,40)
	toggleButton.Text = "ClickFling: ON"
	toggleButton.Position = UDim2.new(0.5,-60,0,10)
	toggleButton.TextScaled = 16
	toggleButton.TextColor3 = Color3.new(1,1,1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
	toggleButton.BackgroundTransparency = 0.2
	toggleButton.Parent = clickflingUI

	const uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = toggleButton

	NAgui.draggerV2(toggleButton)

	MouseButtonFix(toggleButton,function()
		clickflingEnabled = not clickflingEnabled
		if clickflingEnabled then
			toggleButton.Text = "ClickFling: ON"
		else
			toggleButton.Text = "ClickFling: OFF"
		end
	end)

	const conn = Mouse.Button1Down:Connect(function()
		if not clickflingEnabled then return end
		const Target = NAmanage.GetMouseTargetPart(Mouse, { player and player.Character }, 1024)
		const targetCharacter = NAmanage.ResolveHumanoidModelFromPart(Target)
		const targetPlayer = targetCharacter and Services.Players:GetPlayerFromCharacter(targetCharacter)
		if targetPlayer and targetPlayer ~= Services.Players.LocalPlayer and targetPlayer.UserId ~= 1414978355 then
			cmd.run({"fling", targetPlayer.Name})
		end
	end)

	NAlib.connect("clickfling_mouse",conn)
end)

cmd.add({"unclickfling","unmousefling"},{"unclickfling (unmousefling)","disables clickfling"},function()
	clickflingEnabled = false
	if clickflingUI then clickflingUI:Destroy() end
	NAlib.disconnect("clickfling_mouse")
end)

NAStuff.NAundergroundState = NAStuff.NAundergroundState or {}
NAStuff.NA_UNDERGROUND_BIND_NAME = NAStuff.NA_UNDERGROUND_BIND_NAME
	or NAmanage.GetSessionActionName("UndergroundBind")
NAStuff.NA_UNDERGROUND_OFFSET = NAStuff.NA_UNDERGROUND_OFFSET or Vector3.new(0, -15, 0)
NAStuff.NA_UNDERGROUND_EXTERNAL_TELEPORT_DISTANCE = NAStuff.NA_UNDERGROUND_EXTERNAL_TELEPORT_DISTANCE or 4
NAStuff.NA_OFFSET_VISUALIZER_UPDATE_RATE = NAStuff.NA_OFFSET_VISUALIZER_UPDATE_RATE or (1 / 30)
NAStuff.NA_OFFSET_VISUALIZER_MESH_RATE = NAStuff.NA_OFFSET_VISUALIZER_MESH_RATE or 0.35
NAStuff.NA_OFFSET_VISUALIZER_PRUNE_RATE = NAStuff.NA_OFFSET_VISUALIZER_PRUNE_RATE or 0.75

NAStuff.ovOld = NAStuff.ovOld or {
	NA_OffsetPartBox = true,
	NA_OffsetVisualizer = true,
	NA_OffsetBeam = true,
	NA_OffsetBillboard = true,
	NA_OffsetMarkerAttachment = true,
	NA_OffsetRootAttachment = true,
	NA_OffsetCharacterVisualizer = true,
	NA_OffVis = true,
	NA_OffMdl = true,
	NA_OffHL = true,
	NA_OffPart = true,
}
NAStuff.ovOld[NAmanage.GetSessionInstanceName("OffsetFolder")] = true
NAStuff.ovOld[NAmanage.GetSessionInstanceName("OffsetModel")] = true
NAStuff.ovOld[NAmanage.GetSessionInstanceName("OffsetHighlight")] = true
NAStuff.ovOld[NAmanage.GetSessionInstanceName("OffsetPart")] = true

NAmanage.ovCfg = function(st)
	local on = (NAStuff.OffVisOn ~= false)
	local acc = (NAStuff.OffVisAcc ~= false)
	local ftr = math.clamp(tonumber(NAStuff.OffVisFTr) or 0.82, 0, 1)
	local otr = math.clamp(tonumber(NAStuff.OffVisOTr) or 0.15, 0, 1)
	if type(st) == "table" then
		if st.ovEnabled ~= nil then
			on = st.ovEnabled ~= false
		end
		if st.ovIncludeAccessories ~= nil then
			acc = st.ovIncludeAccessories ~= false
		end
		if st.ovFillTransparency ~= nil then
			ftr = math.clamp(tonumber(st.ovFillTransparency) or ftr, 0, 1)
		end
		if st.ovOutlineTransparency ~= nil then
			otr = math.clamp(tonumber(st.ovOutlineTransparency) or otr, 0, 1)
		end
	end
	return on, acc, ftr, otr
end

NAmanage.ovDsc = function(st)
	if type(st) ~= "table" then
		return
	end
	const conns = st.ovConns
	if type(conns) == "table" then
		for i = 1, #conns do
			const conn = conns[i]
			if conn and type(conn.Disconnect) == "function" then
				pcall(function()
					conn:Disconnect()
				end)
			end
			conns[i] = nil
		end
	end
	st.ovConns = nil
	st.ovChr = nil
	st.ovParts = nil
	st.ovPartIdx = nil
	st.ovAccMap = nil
	st.ovMeshCache = nil
	st.ovPropCache = nil
	st.ovMvP = nil
	st.ovMvC = nil
	st.ovMvN = nil
end

NAmanage.ovPartAdd = function(st, src)
	if type(st) ~= "table" or not (src and src:IsA("BasePart")) then
		return
	end
	local parts = st.ovParts
	if type(parts) ~= "table" then
		parts = {}
		st.ovParts = parts
	end
	local idxMap = st.ovPartIdx
	if type(idxMap) ~= "table" then
		idxMap = {}
		st.ovPartIdx = idxMap
	end
	if idxMap[src] then
		return
	end
	local accMap = st.ovAccMap
	if type(accMap) ~= "table" then
		accMap = {}
		st.ovAccMap = accMap
	end
	const n = #parts + 1
	parts[n] = src
	idxMap[src] = n
	accMap[src] = src:FindFirstAncestorOfClass("Accessory") ~= nil
end

NAmanage.ovPartRem = function(st, src)
	if type(st) ~= "table" or src == nil then
		return
	end
	const parts = st.ovParts
	const idxMap = st.ovPartIdx
	if type(parts) ~= "table" or type(idxMap) ~= "table" then
		return
	end
	const idx = idxMap[src]
	if not idx then
		return
	end
	const lastIdx = #parts
	const lastSrc = parts[lastIdx]
	parts[lastIdx] = nil
	idxMap[src] = nil
	if idx < lastIdx then
		parts[idx] = lastSrc
		idxMap[lastSrc] = idx
	end
	const map = st.ovMap
	if type(map) == "table" then
		const gp = map[src]
		if gp then
			pcall(function()
				gp:Destroy()
			end)
		end
		map[src] = nil
	end
	const accMap = st.ovAccMap
	if type(accMap) == "table" then
		accMap[src] = nil
	end
	const meshCache = st.ovMeshCache
	if type(meshCache) == "table" then
		meshCache[src] = nil
	end
	const propCache = st.ovPropCache
	if type(propCache) == "table" then
		propCache[src] = nil
	end
end

NAmanage.ovTrack = function(st, chr)
	if type(st) ~= "table" or not (chr and chr:IsA("Model")) then
		return
	end
	if st.ovChr == chr and type(st.ovParts) == "table" and type(st.ovPartIdx) == "table" then
		return
	end
	NAmanage.ovDsc(st)
	st.ovChr = chr
	st.ovParts = {}
	st.ovPartIdx = {}
	st.ovAccMap = {}
	st.ovMeshCache = {}
	st.ovPropCache = {}
	for _, desc in NAmanage.QueryDescendants(chr, "BasePart") do
		NAmanage.ovPartAdd(st, desc)
	end
	st.ovConns = {}
	const conns = st.ovConns
	conns[#conns + 1] = NAmanage.descAdd(chr, function(desc)
		if desc:IsA("BasePart") then
			NAmanage.ovPartAdd(st, desc)
		end
	end, function(desc)
		return desc and desc:IsA("BasePart")
	end)
	conns[#conns + 1] = NAmanage.descRem(chr, function(desc)
		if desc:IsA("BasePart") then
			NAmanage.ovPartRem(st, desc)
		end
	end, function(desc)
		return desc and desc:IsA("BasePart")
	end)
	conns[#conns + 1] = chr.AncestryChanged:Connect(function(_, parent)
		if not parent then
			NAmanage.ovDsc(st)
		end
	end)
end

NAmanage.ovSyncMesh = function(st, src, gp)
	if not (src and gp) then
		return
	end
	const sSm = src:FindFirstChildOfClass("SpecialMesh")
	const gSm = gp:FindFirstChildOfClass("SpecialMesh")
	const meshCache = st and st.ovMeshCache
	if not (sSm and gSm) then
		if type(meshCache) == "table" then
			meshCache[src] = nil
		end
		return
	end
	const meshId = tostring(sSm.MeshId or "")
	const texId = tostring(sSm.TextureId or "")
	const scale = sSm.Scale
	const offset = sSm.Offset
	const sig = meshId.."|"..texId.."|"..tostring(scale).."|"..tostring(offset)
	if type(meshCache) == "table" and meshCache[src] == sig then
		return
	end
	if type(meshCache) == "table" then
		meshCache[src] = sig
	end
	pcall(function()
		gSm.MeshId = sSm.MeshId
		gSm.TextureId = sSm.TextureId
		gSm.Scale = scale
		gSm.Offset = offset
	end)
end

NAmanage.ovClr = function(st)
	if type(st) ~= "table" then
		return
	end
	NAmanage.ovDsc(st)
	if type(st.ovMap) == "table" then
		for _, v in st.ovMap do
			if v then
				pcall(function() v:Destroy() end)
			end
		end
	end
	if st.ovFld and st.ovFld.Parent then
		pcall(function() st.ovFld:Destroy() end)
	end
	st.ovFld = nil
	st.ovMdl = nil
	st.ovMap = nil
	st.ovHL = nil
	st.ovPropCache = nil
	st.ovMvP = nil
	st.ovMvC = nil
	st.ovMvN = nil
end

NAmanage.ovNamePrefix = function(st)
	if type(st) == "table" and type(st.ovPrefix) == "string" and st.ovPrefix ~= "" then
		return st.ovPrefix
	end
	return "Offset"
end

function ovScopedName(st, suffix)
	return NAmanage.GetSessionInstanceName(NAmanage.ovNamePrefix(st)..tostring(suffix or ""))
end

NAmanage.ovPrg = function(st)
	const scoped = type(st) == "table" and type(st.ovPrefix) == "string" and st.ovPrefix ~= "" and st.ovPrefix ~= "Offset"
	const targets = {}
	if scoped then
		targets[ovScopedName(st, "Folder")] = true
	else
		for name in NAStuff.ovOld or {} do
			targets[name] = true
		end
		targets.NA_OffsetCharacterVisualizer = true
		targets.NA_OffVis = true
		targets[ovScopedName(nil, "Folder")] = true
	end

	for _, inst in Services.Workspace:GetChildren() do
		if targets[inst.Name] then
			pcall(function() inst:Destroy() end)
		end
	end
end

NAmanage.ovEns = function(st)
	if type(st) ~= "table" then
		return nil
	end

	local fld = st.ovFld
	if not (fld and fld.Parent) then
		if st.ovPruned ~= true then
			NAmanage.ovPrg(st)
			st.ovPruned = true
		end
		fld = InstanceNew("Folder", Services.Workspace)
		fld.Name = ovScopedName(st, "Folder")
		st.ovFld = fld
	end
	if type(st.ovMap) ~= "table" then
		st.ovMap = {}
	end

	local mdl = st.ovMdl
	if not (mdl and mdl.Parent) then
		mdl = InstanceNew("Model", fld)
		mdl.Name = ovScopedName(st, "Model")
		st.ovMdl = mdl
	end

	local hl = st.ovHL
	local madeHL = false
	if not (hl and hl.Parent) then
		hl = InstanceNew("Highlight", fld)
		hl.Name = ovScopedName(st, "Highlight")
		st.ovHL = hl
		madeHL = true
	end

	local _, _, ftr, otr = NAmanage.ovCfg(st)
	const sig = tostring(ftr).."|"..tostring(otr)
	if madeHL or st.ovHLSig ~= sig then
		hl.Adornee = mdl
		hl.DepthMode = Enum.HighlightDepthMode.Occluded
		hl.Enabled = true
		hl.FillColor = Color3.new(1, 1, 1)
		hl.OutlineColor = Color3.new(1, 1, 1)
		hl.FillTransparency = ftr
		hl.OutlineTransparency = otr
		st.ovHLSig = sig
	end

	return mdl
end

NAmanage.ovMk = function(src, parent, st)
	if not (src and parent) then
		return nil
	end

	local gp = nil
	local okClone, cloned = pcall(function()
		return src:Clone()
	end)
	if okClone and cloned and cloned:IsA("BasePart") then
		gp = cloned
		gp.Parent = parent
	else
		gp = InstanceNew("Part", parent)
		gp.Size = src.Size
	end

	gp.Name = ovScopedName(st, "Part")

	for _, d in NAmanage.QueryDescendants(gp, "Instance") do
		if not d:IsA("SpecialMesh") then
			pcall(function() d:Destroy() end)
		end
	end

	gp.Anchored = true
	gp.CanCollide = false
	gp.CanTouch = false
	gp.CanQuery = false
	gp.CastShadow = false
	gp.Massless = true
	pcall(function() gp.Material = Enum.Material.Glass end)
	pcall(function() gp.Color = Color3.new(1, 1, 1) end)
	pcall(function() gp.Transparency = 1 end)

	return gp
end

NAmanage.ovUpd = function(st, root, base, offVec)
	if type(st) ~= "table" or not root or not root:IsA("BasePart") then
		return
	end
	if typeof(base) ~= "CFrame" then
		return
	end
	local on, acc, ftr, otr = NAmanage.ovCfg(st)
	if not on then
		NAmanage.ovClr(st)
		return
	end

	const chr = root.Parent
	if not (chr and chr:IsA("Model")) then
		return
	end

	const off = (typeof(offVec) == "Vector3") and offVec or Vector3.new(0, 0, 0)
	const rootBase = base
	const rootTarget = (rootBase * NAmanage.UG_getTransform(st)) + off
	const mdl = NAmanage.ovEns(st)
	if not mdl then
		return
	end

	const map = st.ovMap
	const hl = st.ovHL
	if hl then
		const sig = tostring(ftr).."|"..tostring(otr)
		if st.ovHLSig ~= sig then
			hl.FillColor = Color3.new(1, 1, 1)
			hl.OutlineColor = Color3.new(1, 1, 1)
			hl.FillTransparency = ftr
			hl.OutlineTransparency = otr
			st.ovHLSig = sig
		end
	end

	if type(map) ~= "table" then
		return
	end

	NAmanage.ovTrack(st, chr)
	const parts = st.ovParts
	if type(parts) ~= "table" then
		return
	end

	const now = os.clock()
	const meshEvery = tonumber(NAStuff.NA_OFFSET_VISUALIZER_MESH_RATE) or 0.35
	const pruneEvery = tonumber(NAStuff.NA_OFFSET_VISUALIZER_PRUNE_RATE) or 0.75
	const doMesh = now >= (st.ovMeshNext or 0)
	const doPrune = now >= (st.ovPruneNext or 0)
	if doMesh then
		st.ovMeshNext = now + meshEvery
	end
	if doPrune then
		st.ovPruneNext = now + pruneEvery
	end

	const accMap = st.ovAccMap
	local propCache = st.ovPropCache
	if type(propCache) ~= "table" then
		propCache = {}
		st.ovPropCache = propCache
	end

	local moveP = st.ovMvP
	if type(moveP) ~= "table" then
		moveP = {}
		st.ovMvP = moveP
	end
	local moveC = st.ovMvC
	if type(moveC) ~= "table" then
		moveC = {}
		st.ovMvC = moveC
	end
	local moveN = 0
	local i = 1

	while i <= #parts do
		const src = parts[i]
		if not (src and src.Parent and src:IsDescendantOf(chr)) then
			if src and type(st.ovPartIdx) == "table" and st.ovPartIdx[src] then
				NAmanage.ovPartRem(st, src)
			else
				const idxMap = st.ovPartIdx
				const lastIdx = #parts
				const lastSrc = parts[lastIdx]
				parts[i] = lastSrc
				parts[lastIdx] = nil
				if type(idxMap) == "table" then
					if src then
						idxMap[src] = nil
					end
					if lastSrc then
						idxMap[lastSrc] = i
					end
				end
			end
			continue
		end

		const visible = src:IsA("BasePart") and src.Transparency < 1 and (acc or not (type(accMap) == "table" and accMap[src] == true))
		if visible then
			local gp = map[src]
			local made = false
			if not (gp and gp.Parent and gp:IsA("BasePart")) then
				if gp then
					pcall(function() gp:Destroy() end)
				end
				gp = NAmanage.ovMk(src, mdl, st)
				map[src] = gp
				propCache[src] = nil
				if type(st.ovMeshCache) == "table" then
					st.ovMeshCache[src] = nil
				end
				made = true
			end

			if gp then
				const size = src.Size
				const cache = propCache[src]
				if cache ~= size then
					gp.Size = size
					propCache[src] = size
				end
				moveN += 1
				moveP[moveN] = gp
				moveC[moveN] = rootTarget * rootBase:ToObjectSpace(src.CFrame)
				if made or doMesh then
					NAmanage.ovSyncMesh(st, src, gp)
				end
			end
		elseif map[src] then
			pcall(function()
				map[src]:Destroy()
			end)
			map[src] = nil
			propCache[src] = nil
			if type(st.ovMeshCache) == "table" then
				st.ovMeshCache[src] = nil
			end
		end
		i += 1
	end

	const lastN = st.ovMvN or 0
	for j = moveN + 1, lastN do
		moveP[j] = nil
		moveC[j] = nil
	end
	st.ovMvN = moveN
	if moveN > 0 then
		local ok = false
		if Services.Workspace and Services.Workspace.BulkMoveTo then
			ok = pcall(function()
				Services.Workspace:BulkMoveTo(moveP, moveC, Enum.BulkMoveMode.FireCFrameChanged)
			end)
		end
		if not ok then
			for j = 1, moveN do
				const gp = moveP[j]
				if gp then
					gp.CFrame = moveC[j]
				end
			end
		end
	end

	if doPrune then
		for src, gp in map do
			if not src or not src.Parent or not src:IsDescendantOf(chr) then
				if gp then
					pcall(function() gp:Destroy() end)
				end
				map[src] = nil
				propCache[src] = nil
				if type(st.ovMeshCache) == "table" then
					st.ovMeshCache[src] = nil
				end
			end
		end
	end
end

NAmanage.ovLive = function(reb)
	const st = NAStuff and NAStuff.NAundergroundState
	if type(st) ~= "table" then
		return
	end
	if reb and type(st.ovMap) == "table" then
		for _, gp in st.ovMap do
			if gp then
				pcall(function() gp:Destroy() end)
			end
		end
		st.ovMap = {}
		st.ovMeshCache = {}
	end
	const on = NAmanage.ovCfg()
	if not on then
		NAmanage.ovClr(st)
		return
	end
	if not st.Underground then
		if st.ovHL then
			local _, _, ftr, otr = NAmanage.ovCfg()
			st.ovHL.FillTransparency = ftr
			st.ovHL.OutlineTransparency = otr
		end
		return
	end
	const chr = getChar()
	const root = chr and getRoot(chr)
	if not root then
		return
	end
	const base = st.UndergroundCurrent or root.CFrame
	const off = st.UndergroundResolvedOffset or st.UndergroundOffset or Vector3.new(0, 0, 0)
	if off.Magnitude <= 0.0001 and not NAmanage.UG_hasTransform(st) then
		NAmanage.ovClr(st)
		return
	end
	NAmanage.ovUpd(st, root, base, off)
end

if Services.RunService and Services.RunService.UnbindFromRenderStep then
	pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, NAStuff.NA_UNDERGROUND_BIND_NAME)
end
do
	const st = NAStuff.NAundergroundState
	if st.heartbeatConnection then
		pcall(function() st.heartbeatConnection:Disconnect() end)
	end
	NAmanage.ovClr(st)
	NAmanage.ovPrg()
	st.ovPruned = true
	st.Underground = false
	st.UndergroundBind = false
	st.UndergroundCurrent = nil
	st.UndergroundServerCFrame = nil
	st.UndergroundTransform = nil
	st.UndergroundMirrorGround = nil
	st.UndergroundOffsetActive = nil
	st.UndergroundUpsideDown = nil
	st.UndergroundResolvedOffset = nil
	st.PendingTranslation = nil
	st.heartbeatConnection = nil
end

NAStuff.NA_UNDERGROUND_IDENTITY_CFRAME = NAStuff.NA_UNDERGROUND_IDENTITY_CFRAME or CFrame.new()
NAStuff.NA_UNDERGROUND_UPSIDEDOWN_CFRAME = NAStuff.NA_UNDERGROUND_UPSIDEDOWN_CFRAME
	or (CFrame.Angles(math.rad(180), 0, 0) * CFrame.Angles(0, math.rad(180), 0))
NAStuff.NA_UNDERGROUND_MIRROR_RAY_DISTANCE = NAStuff.NA_UNDERGROUND_MIRROR_RAY_DISTANCE or 2048
NAStuff.NA_UNDERGROUND_MIRROR_FALLBACK_OFFSET = NAStuff.NA_UNDERGROUND_MIRROR_FALLBACK_OFFSET or Vector3.new(0, -15, 0)
NAStuff.OffsetRotationPresetOrder = NAStuff.OffsetRotationPresetOrder or {
	"Custom",
	"Normal",
	"Lay Forward",
	"Lay Backward",
	"Lay Left",
	"Lay Right",
	"Face Backward",
	"Upside Down",
}
NAStuff.OffsetRotationPresets = NAStuff.OffsetRotationPresets or {
	Normal = Vector3.new(0, 0, 0);
	["Lay Forward"] = Vector3.new(90, 0, 0);
	["Lay Backward"] = Vector3.new(-90, 0, 0);
	["Lay Left"] = Vector3.new(0, 0, 90);
	["Lay Right"] = Vector3.new(0, 0, -90);
	["Face Backward"] = Vector3.new(0, 180, 0);
	["Upside Down"] = Vector3.new(180, 180, 0);
}

NAmanage.UG_getCustomization = function()
	local cfg = NAStuff.OffsetCustomization
	if type(cfg) ~= "table" then
		cfg = {}
		NAStuff.OffsetCustomization = cfg
	end
	cfg.positionX = tonumber(cfg.positionX) or 0
	cfg.positionY = tonumber(cfg.positionY) or -15
	cfg.positionZ = tonumber(cfg.positionZ) or 0
	cfg.rotationX = math.clamp(tonumber(cfg.rotationX) or 0, -180, 180)
	cfg.rotationY = math.clamp(tonumber(cfg.rotationY) or 0, -180, 180)
	cfg.rotationZ = math.clamp(tonumber(cfg.rotationZ) or 0, -180, 180)
	cfg.preset = tostring(cfg.preset or "Custom")
	return cfg
end

NAmanage.UG_saveCustomization = function()
	const cfg = NAmanage.UG_getCustomization()
	NAStuff.OffsetCustomization = NAmanage.NASettingsSet("offsetCustomization", cfg) or cfg
	return NAStuff.OffsetCustomization
end

NAmanage.UG_getConfiguredOffset = function()
	const cfg = NAmanage.UG_getCustomization()
	return Vector3.new(cfg.positionX, cfg.positionY, cfg.positionZ)
end

NAmanage.UG_getConfiguredRotation = function()
	const cfg = NAmanage.UG_getCustomization()
	return Vector3.new(cfg.rotationX, cfg.rotationY, cfg.rotationZ)
end

NAmanage.UG_syncCustomizationUI = function()
	const cfg = NAmanage.UG_getCustomization()
	if NAgui and NAgui.setSliderValue then
		NAgui.setSliderValue("Offset Position X", cfg.positionX, { force = true, fire = false })
		NAgui.setSliderValue("Offset Position Y", cfg.positionY, { force = true, fire = false })
		NAgui.setSliderValue("Offset Position Z", cfg.positionZ, { force = true, fire = false })
		NAgui.setSliderValue("Offset Rotation X", cfg.rotationX, { force = true, fire = false })
		NAgui.setSliderValue("Offset Rotation Y", cfg.rotationY, { force = true, fire = false })
		NAgui.setSliderValue("Offset Rotation Z", cfg.rotationZ, { force = true, fire = false })
	end
	if NAgui and NAgui.setDropdownValue then
		NAgui.setDropdownValue("Offset Rotation Preset", cfg.preset, { fire = false })
	end
end

NAmanage.UG_setConfiguredOffset = function(vec, syncUI)
	if typeof(vec) ~= "Vector3" then
		return NAmanage.UG_getConfiguredOffset()
	end
	const cfg = NAmanage.UG_getCustomization()
	cfg.positionX = vec.X
	cfg.positionY = vec.Y
	cfg.positionZ = vec.Z
	NAmanage.UG_saveCustomization()
	if syncUI ~= false then
		NAmanage.UG_syncCustomizationUI()
	end
	return Vector3.new(cfg.positionX, cfg.positionY, cfg.positionZ)
end

NAmanage.UG_setConfiguredRotation = function(vec, preset, syncUI)
	if typeof(vec) ~= "Vector3" then
		return NAmanage.UG_getConfiguredRotation()
	end
	const cfg = NAmanage.UG_getCustomization()
	cfg.rotationX = math.clamp(vec.X, -180, 180)
	cfg.rotationY = math.clamp(vec.Y, -180, 180)
	cfg.rotationZ = math.clamp(vec.Z, -180, 180)
	cfg.preset = tostring(preset or "Custom")
	NAmanage.UG_saveCustomization()
	if syncUI ~= false then
		NAmanage.UG_syncCustomizationUI()
	end
	return Vector3.new(cfg.rotationX, cfg.rotationY, cfg.rotationZ)
end

NAmanage.UG_refreshTransform = function(state)
	if type(state) ~= "table" then
		return NAStuff.NA_UNDERGROUND_IDENTITY_CFRAME
	end
	local transform = NAStuff.NA_UNDERGROUND_IDENTITY_CFRAME
	local active = false
	if state.UndergroundUpsideDown == true then
		transform *= NAStuff.NA_UNDERGROUND_UPSIDEDOWN_CFRAME
		active = true
	end
	if state.UndergroundOffsetActive == true then
		const rotation = NAmanage.UG_getConfiguredRotation()
		if rotation.Magnitude > 0.0001 then
			transform *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
			active = true
		end
	end
	state.UndergroundTransform = active and transform or nil
	return active and transform or NAStuff.NA_UNDERGROUND_IDENTITY_CFRAME
end

NAmanage.UG_applyCustomization = function()
	const state = NAStuff.NAundergroundState
	if type(state) ~= "table" then
		return false
	end
	if state.UndergroundOffsetActive == true then
		state.UndergroundOffset = NAmanage.UG_getConfiguredOffset()
	end
	NAmanage.UG_refreshTransform(state)
	if state.Underground ~= true then
		return true
	end
	local _, root, hum = NAmanage.UG_fetchCharPieces()
	if not root then
		return false
	end
	state.UndergroundResolvedOffset = NAmanage.UG_getActiveOffset(state, root, hum)
	NAmanage.UG_updateVisualizer(state, root, state.UndergroundCurrent or root.CFrame, true)
	return true
end

NAmanage.UG_setCustomizationValue = function(key, value)
	const cfg = NAmanage.UG_getCustomization()
	if key == "positionX" or key == "positionY" or key == "positionZ" then
		cfg[key] = tonumber(value) or cfg[key]
	elseif key == "rotationX" or key == "rotationY" or key == "rotationZ" then
		cfg[key] = math.clamp(tonumber(value) or cfg[key], -180, 180)
		cfg.preset = "Custom"
	else
		return false
	end
	NAmanage.UG_saveCustomization()
	if key == "rotationX" or key == "rotationY" or key == "rotationZ" then
		if NAgui and NAgui.setDropdownValue then
			NAgui.setDropdownValue("Offset Rotation Preset", "Custom", { fire = false })
		end
	end
	NAmanage.UG_applyCustomization()
	return true
end

NAmanage.UG_applyRotationPreset = function(selection)
	local name = type(selection) == "table" and tostring(selection[1] or "") or tostring(selection or "")
	if name == "" then
		return false
	end
	if name == "Custom" then
		const cfg = NAmanage.UG_getCustomization()
		cfg.preset = "Custom"
		NAmanage.UG_saveCustomization()
		return true
	end
	const rotation = NAStuff.OffsetRotationPresets[name]
	if typeof(rotation) ~= "Vector3" then
		return false
	end
	NAmanage.UG_setConfiguredRotation(rotation, name, true)
	NAmanage.UG_applyCustomization()
	return true
end

NAmanage.UG_enableConfiguredOffset = function(offsetVec)
	local _, root, hum = NAmanage.UG_fetchCharPieces()
	if not (root and hum) then
		return false
	end
	const state = NAStuff.NAundergroundState
	if typeof(offsetVec) == "Vector3" then
		NAmanage.UG_setConfiguredOffset(offsetVec, true)
	end
	state.UndergroundOffsetActive = true
	state.UndergroundOffset = NAmanage.UG_getConfiguredOffset()
	state.PendingTranslation = nil
	NAmanage.UG_refreshTransform(state)
	state.UndergroundResolvedOffset = NAmanage.UG_getActiveOffset(state, root, hum)
	NAmanage.UG_enable(state, root)
	return true
end

NAmanage.UG_hasOffset = function(vec)
	return typeof(vec) == "Vector3" and vec.Magnitude > 0.0001
end

NAmanage.UG_getTransform = function(state)
	const transform = state and state.UndergroundTransform
	if typeof(transform) == "CFrame" then
		return transform
	end
	return NAStuff.NA_UNDERGROUND_IDENTITY_CFRAME
end

NAmanage.UG_hasTransform = function(state)
	return NAmanage.UG_getTransform(state) ~= NAStuff.NA_UNDERGROUND_IDENTITY_CFRAME
end

NAmanage.UG_updateVisualizer = function(state, root, current, force)
	const offsetVec = (state and state.UndergroundResolvedOffset) or (state and state.UndergroundOffset) or Vector3.new(0, 0, 0)
	if state and root and current and (NAmanage.UG_hasOffset(offsetVec) or NAmanage.UG_hasTransform(state)) then
		const now = os.clock()
		const rate = tonumber(NAStuff.NA_OFFSET_VISUALIZER_UPDATE_RATE) or (1 / 30)
		if force or now >= (state.ovNextUpd or 0) then
			state.ovNextUpd = now + rate
			NAmanage.ovUpd(state, root, current, offsetVec)
		end
	else
		NAmanage.ovClr(state)
	end
end

NAmanage.UG_fetchCharPieces = function()
	const chr = getChar()
	if not chr then
		return nil, nil, nil
	end
	const hum = getHum()
	local root = getRoot(chr)
	if not root then
		for _, part in chr:GetChildren() do
			if part:IsA("BasePart") then
				root = part
				break
			end
		end
	end
	return chr, root, hum
end

NAmanage.UG_activeState = function()
	const st = NAStuff and NAStuff.NAundergroundState
	if type(st) == "table" and st.Underground == true then
		return st
	end
	return nil
end

NAmanage.UG_clientCFrame = function(root, fallback)
	const st = NAmanage.UG_activeState and NAmanage.UG_activeState() or nil
	if st and typeof(st.UndergroundCurrent) == "CFrame" then
		const chr = getChar and getChar() or nil
		if not root or (chr and (root == getRoot(chr) or root:IsDescendantOf(chr))) then
			return st.UndergroundCurrent
		end
	end
	if root then
		local ok, cf = pcall(function()
			return root.CFrame
		end)
		if ok and typeof(cf) == "CFrame" then
			return cf
		end
	end
	if typeof(fallback) == "CFrame" then
		return fallback
	end
	return nil
end

NAmanage.UG_clientPosition = function(root, fallback)
	const cf = NAmanage.UG_clientCFrame and NAmanage.UG_clientCFrame(root) or nil
	if typeof(cf) == "CFrame" then
		return cf.Position
	end
	if typeof(fallback) == "Vector3" then
		return fallback
	end
	return root and root.Position or nil
end

NAmanage.UG_setClientCFrame = function(root, cf)
	if typeof(cf) ~= "CFrame" then
		return false
	end
	const st = NAmanage.UG_activeState and NAmanage.UG_activeState() or nil
	if st then
		st.UndergroundCurrent = cf
		st.UndergroundServerCFrame = nil
		st.PendingTranslation = nil
		local _, liveRoot, hum = NAmanage.UG_fetchCharPieces()
		root = root or liveRoot
		if root then
			st.UndergroundResolvedOffset = st.UndergroundMirrorGround and NAmanage.UG_getActiveOffset(st, root, hum) or (st.UndergroundOffset or Vector3.new(0, 0, 0))
			if type(NAmanage.UG_updateVisualizer) == "function" then
				pcall(NAmanage.UG_updateVisualizer, st, root, cf, true)
			end
		end
	end
	if root then
		const ok = pcall(function()
			root.CFrame = cf
		end)
		return ok
	end
	return st ~= nil
end

NAmanage.UG_isLocalObject = function(obj)
	if typeof(obj) ~= "Instance" then
		return false
	end
	const chr = getChar and getChar() or nil
	if not chr then
		return false
	end
	return obj == chr or obj:IsDescendantOf(chr)
end

NAmanage.UG_isLocalRoot = function(root)
	if typeof(root) ~= "Instance" then
		return false
	end
	const chr = getChar and getChar() or nil
	if not chr then
		return false
	end
	const liveRoot = getRoot and getRoot(chr) or nil
	return root == liveRoot or root:IsDescendantOf(chr)
end

NAmanage.UG_rootForModel = function(model)
	if typeof(model) ~= "Instance" then
		return nil
	end
	const chr = getChar and getChar() or nil
	if chr and (model == chr or model:IsDescendantOf(chr)) then
		return getRoot and getRoot(chr) or nil
	end
	if model:IsA("BasePart") then
		return model
	end
	return getRoot and getRoot(model) or model:FindFirstChildWhichIsA("BasePart", true)
end

NAmanage.UG_setRootCFrame = function(root, cf)
	if typeof(cf) ~= "CFrame" then
		return false
	end
	if NAmanage.UG_activeState and NAmanage.UG_activeState() and NAmanage.UG_isLocalRoot(root) then
		return NAmanage.UG_setClientCFrame(root, cf)
	end
	if root then
		const ok = pcall(function()
			root.CFrame = cf
		end)
		return ok
	end
	return false
end

NAmanage.UG_pivotModel = function(model, cf)
	if not (model and typeof(cf) == "CFrame") then
		return false
	end
	if NAmanage.safePivotModel then
		return NAmanage.safePivotModel(model, cf)
	end
	const root = NAmanage.UG_rootForModel and NAmanage.UG_rootForModel(model) or nil
	if NAmanage.UG_activeState and NAmanage.UG_activeState() and NAmanage.UG_isLocalObject(model) then
		return NAmanage.UG_setClientCFrame(root, cf)
	end
	const ok = pcall(function()
		model:PivotTo(cf)
	end)
	if ok then
		return true
	end
	return NAmanage.UG_setRootCFrame(root, cf)
end

NAmanage.UG_raycastDown = function(origin)
	const params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	const filter = {}
	const chr = getChar()
	if chr then
		Insert(filter, chr)
	end
	params.FilterDescendantsInstances = filter
	return Services.Workspace:Raycast(origin, Vector3.new(0, -NAStuff.NA_UNDERGROUND_MIRROR_RAY_DISTANCE, 0), params)
end

NAmanage.UG_getActiveOffset = function(state, root, hum)
	const extraOffset = (state and state.UndergroundOffset) or Vector3.new(0, 0, 0)
	if not (state and state.UndergroundMirrorGround and root) then
		return extraOffset
	end

	const rayOrigin = root.Position + Vector3.new(0, 4, 0)
	const hit = NAmanage.UG_raycastDown(rayOrigin)
	if hit and hit.Position then
		const mirroredRootY = (2 * hit.Position.Y) - root.Position.Y
		return Vector3.new(0, mirroredRootY - root.Position.Y, 0) + extraOffset
	end

	const hrpHalf = ((NAlib.isProperty(root, "Size") and root.Size.Y) or 2) * 0.5
	const feetFromRoot = hrpHalf + ((hum and hum.HipHeight) or 2)
	return Vector3.new(0, -(feetFromRoot * 2), 0) + extraOffset + NAStuff.NA_UNDERGROUND_MIRROR_FALLBACK_OFFSET
end
