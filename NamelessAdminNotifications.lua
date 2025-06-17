local function ClonedService(name)
	local Service = (game.GetService);
	local Reference = (cloneref) or function(reference) return reference end
	return Reference(Service(game, name));
end

local function GETTHEUI()
	return (gethui and gethui()) or SafeGetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or SafeGetService("CoreGui") or SafeGetService("Players").LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
end

local TweenService = ClonedService("TweenService")
local RunService = ClonedService("RunService")
local TextService = ClonedService("TextService")
local UserInputService = ClonedService("UserInputService")

local PADDING = 10
local TWEEN_TIME = 0.8
local CLOSE_MARGIN, SPACING = 6, 6
local TWEEN_STYLE = Enum.EasingStyle.Quint
local TWEEN_DIRECTION = Enum.EasingDirection.Out
local BUTTON_COLORS = {
	Default = Color3.fromRGB(45, 45, 45),
	Hover = Color3.fromRGB(60, 60, 60),
	Click = Color3.fromRGB(30, 30, 30)
}
local NOTIFICATION_COLORS = {
	Background = Color3.fromRGB(28, 28, 28),
	Shadow = Color3.fromRGB(10, 10, 10),
	Text = Color3.fromRGB(240, 240, 240),
	Title = Color3.fromRGB(255, 255, 255),
	CloseButton = Color3.fromRGB(200, 60, 60),
	Accent = Color3.fromRGB(200, 200, 200),
	Stroke = Color3.fromRGB(255, 255, 255)
}

local Player = ClonedService("Players").LocalPlayer
local search = RunService:IsStudio() and Player.PlayerGui or GETTHEUI()
local NotifGui, Container
local AnnouncementObjects = {}

if search:FindFirstChild("EnhancedNotif") and _G.EnhancedNotifs then
	return _G.EnhancedNotifs
else
	NotifGui = Instance.new("ScreenGui")
	NotifGui.Name = "EnhancedNotif"
	NotifGui.Parent = search
	NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	NotifGui.DisplayOrder = 0x7FFFFFFF
	NotifGui.ResetOnSpawn = false
	NotifGui.IgnoreGuiInset = true

	Container = Instance.new("Frame")
	Container.Name = "Container"
	Container.Position = UDim2.new(1, -320, 1, -20)
	Container.Size = UDim2.new(0, 300, 0.5, 0)
	Container.AnchorPoint = Vector2.new(0, 1)
	Container.BackgroundTransparency = 1
	Container.Parent = NotifGui
end

local InstructionObjects = {}
local CachedObjects = {}
local LastTick = tick()

local function CreateNotificationFrame(Y)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0, 300, 0, Y)
	Frame.BackgroundColor3 = NOTIFICATION_COLORS.Background
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0

	local Stroke = Instance.new("UIStroke", Frame)
	Stroke.Color = NOTIFICATION_COLORS.Stroke
	Stroke.Thickness = 1.5
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Transparency = 0

	Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

	local AccentBar = Instance.new("Frame", Frame)
	AccentBar.Name = "AccentBar"
	AccentBar.Size = UDim2.new(1, 0, 0, 4)
	AccentBar.Position = UDim2.new(0, 0, 1, -4)
	AccentBar.BackgroundColor3 = NOTIFICATION_COLORS.Accent
	Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 8)

	local Shadow = Instance.new("Frame", Frame)
	Shadow.Name = "Shadow"
	Shadow.Size = UDim2.new(1, 10, 1, 10)
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundColor3 = NOTIFICATION_COLORS.Shadow
	Shadow.BackgroundTransparency = 0.5
	Shadow.ZIndex = -1
	Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 10)

	return Frame
end

local function CreateTitle(Text, Parent)
	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -50, 0, 26)
	Title.Position = UDim2.new(0, 15, 0, 5)
	Title.BackgroundTransparency = 1
	Title.Text = Text
	Title.TextColor3 = NOTIFICATION_COLORS.Title
	Title.TextSize = 16
	Title.TextScaled = true
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextYAlignment = Enum.TextYAlignment.Center
	Title.Parent = Parent
	return Title
end

local function CreateDescription(Text, Parent, YPosition)
	local Description = Instance.new("TextLabel")
	Description.Size = UDim2.new(1, -30, 0, 0)
	Description.Position = UDim2.new(0, 15, 0, YPosition)
	Description.BackgroundTransparency = 1
	Description.Text = Text
	Description.TextColor3 = NOTIFICATION_COLORS.Text
	Description.TextSize = 14
	Description.TextScaled = true
	Description.Font = Enum.Font.Gotham
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top
	Description.TextWrapped = true
	Description.Parent = Parent

	local textSize = TextService:GetTextSize(
		Text,
		14,
		Enum.Font.Gotham,
		Vector2.new(Description.AbsoluteSize.X, math.huge)
	)

	Description.Size = UDim2.new(1, -30, 0, textSize.Y)

	return Description, textSize.Y
end

local function CreateCloseButton(Parent)
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size = UDim2.new(0, 24, 0, 24)
	CloseButton.Position = UDim2.new(1, -30, 0, 6)
	CloseButton.BackgroundColor3 = NOTIFICATION_COLORS.CloseButton
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextSize = 18
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = Parent

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = CloseButton

	CloseButton.MouseEnter:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
	end)

	CloseButton.MouseLeave:Connect(function()
		TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = NOTIFICATION_COLORS.CloseButton}):Play()
	end)

	return CloseButton
end

local function CreateSquircleButton(Text, Width, Height, Parent, Position)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, Width, 0, Height)
	Button.Position = Position
	Button.Text = Text
	Button.TextScaled = true
	Button.BackgroundColor3 = BUTTON_COLORS.Default
	Button.TextColor3 = NOTIFICATION_COLORS.Text
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 14
	Button.Parent = Parent

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.3, 0)
	UICorner.Parent = Button

	Button.MouseEnter:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = BUTTON_COLORS.Hover}):Play()
	end)

	Button.MouseLeave:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = BUTTON_COLORS.Default}):Play()
	end)

	Button.MouseButton1Down:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = BUTTON_COLORS.Click}):Play()
	end)

	Button.MouseButton1Up:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = BUTTON_COLORS.Hover}):Play()
	end)

	return Button
end

local function CalculateBounds(TableOfObjects)
	local Y = 0
	for _, Object in next, TableOfObjects do
		Y = Y + Object.AbsoluteSize.Y + PADDING
	end
	return Y
end

local function Update()
	local DeltaTime = tick() - LastTick
	local PreviousObjects = {}

	for _, Object in next, InstructionObjects do
		local Label, Delta, Done = Object[1], Object[2], Object[3]

		if not Done then
			if Delta < TWEEN_TIME then
				Object[2] = math.clamp(Delta + DeltaTime, 0, TWEEN_TIME)
				Delta = Object[2]
			else
				Object[3] = true
			end
		end

		local NewValue = TweenService:GetValue(Delta / TWEEN_TIME, TWEEN_STYLE, TWEEN_DIRECTION)
		local CurrentPos = Label.Position
		local TargetPos = UDim2.new(0, 0, 1, -CalculateBounds(PreviousObjects) - Label.AbsoluteSize.Y)

		Label.Position = TargetPos
		table.insert(PreviousObjects, Label)
	end

	CachedObjects = PreviousObjects
	LastTick = tick()
end

local function UpdateAnnouncements()
	local PreviousObjects = {}
	for _, Object in ipairs(AnnouncementObjects) do
		local Frame, Delta, Done = Object[1], Object[2], Object[3]
		if not Done then
			Object[2] = math.clamp(Delta + (tick() - LastTick), 0, TWEEN_TIME)
			if Object[2] >= TWEEN_TIME then
				Object[3] = true
			end
		end
		local OffsetY = CalculateBounds(PreviousObjects)
		local TargetPos = UDim2.new(0.5, 0, 0, OffsetY + 20)
		Frame.Position = TargetPos
		table.insert(PreviousObjects, Frame)
	end
	LastTick = tick()
end

RunService:BindToRenderStep("UpdateNotifications", 0, Update)
RunService:BindToRenderStep("UpdateAnnouncements", 1, UpdateAnnouncements)

local PropertyTweenOut = {
	Text = "TextTransparency",
	Fram = "BackgroundTransparency",
	Imag = "ImageTransparency"
}

local function FadeProperty(Object)
	local Prop = PropertyTweenOut[string.sub(Object.ClassName, 1, 4)]
	if Prop then
		TweenService:Create(Object, TweenInfo.new(0.25, TWEEN_STYLE, TWEEN_DIRECTION), {
			[Prop] = 1
		}):Play()
	end
end

local function FindIndexByDependency(Table, Dependency)
	for Index, Object in next, Table do
		if typeof(Object) == "table" then
			for _, v in next, Object do
				if v == Dependency then
					return Index
				end
			end
		else
			if Object == Dependency then
				return Index
			end
		end
	end
	return nil
end

local function ResetObjects()
	for _, Object in next, InstructionObjects do
		Object[2] = 0
		Object[3] = false
	end
end

local function FadeOutAfter(Object, Seconds)
	task.spawn(function()
		task.wait(Seconds)
		local fadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local originalSize = Object.Size
		local originalPosition = Object.Position
		local anchor = Object.AnchorPoint
		local centerShrinkPos = UDim2.new(
			originalPosition.X.Scale,
			originalPosition.X.Offset + (originalSize.X.Offset * (0.5 - anchor.X)),
			originalPosition.Y.Scale,
			originalPosition.Y.Offset + (originalSize.Y.Offset * (0.5 - anchor.Y))
		)
		TweenService:Create(Object, fadeTweenInfo, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = centerShrinkPos,
			BackgroundTransparency = 1
		}):Play()
		local stroke = Object:FindFirstChildWhichIsA("UIStroke", true)
		if stroke then
			TweenService:Create(stroke, fadeTweenInfo, {
				Transparency = 1
			}):Play()
		end
		for _, SubObj in ipairs(Object:GetDescendants()) do
			local class = SubObj.ClassName
			if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
				TweenService:Create(SubObj, fadeTweenInfo, {
					TextTransparency = 1,
					BackgroundTransparency = 1
				}):Play()
			elseif class == "Frame" or class == "ImageLabel" then
				TweenService:Create(SubObj, fadeTweenInfo, {
					BackgroundTransparency = 1
				}):Play()
			elseif class == "UIStroke" then
				TweenService:Create(SubObj, fadeTweenInfo, {
					Transparency = 1
				}):Play()
			end
		end
		task.wait(0.5)
		local idx = FindIndexByDependency(InstructionObjects, Object)
		if idx then
			table.remove(InstructionObjects, idx)
			ResetObjects()
		end
		local aIdx = FindIndexByDependency(AnnouncementObjects, Object)
		if aIdx then
			table.remove(AnnouncementObjects, aIdx)
		end
		Object:Destroy()
	end)
end

local function CreateInputField(Parent, YPosition)
	local InputField = Instance.new("TextBox")
	InputField.Size = UDim2.new(1, -30, 0, 30)
	InputField.Position = UDim2.new(0, 15, 0, YPosition)
	InputField.BackgroundColor3 = BUTTON_COLORS.Default
	InputField.TextColor3 = NOTIFICATION_COLORS.Text
	InputField.TextSize = 14
	InputField.Font = Enum.Font.Gotham
	InputField.TextXAlignment = Enum.TextXAlignment.Left
	InputField.TextYAlignment = Enum.TextYAlignment.Center
	InputField.PlaceholderText = "Enter your input here..."
	InputField.Text = ""
	InputField.Parent = Parent

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.3, 0)
	UICorner.Parent = InputField

	InputField.MouseEnter:Connect(function()
		TweenService:Create(InputField, TweenInfo.new(0.2), {BackgroundColor3 = BUTTON_COLORS.Hover}):Play()
	end)

	InputField.MouseLeave:Connect(function()
		TweenService:Create(InputField, TweenInfo.new(0.2), {BackgroundColor3 = BUTTON_COLORS.Default}):Play()
	end)

	return InputField
end

local dragger = function(ui, dragui)
	dragui = dragui or ui
	local UserInputService = ClonedService("UserInputService")
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local success, err = pcall(function()
			local delta = input.Position - dragStart
			local screenSize = ui.Parent.AbsoluteSize
			local newXScale = startPos.X.Scale + (startPos.X.Offset + delta.X) / screenSize.X
			local newYScale = startPos.Y.Scale + (startPos.Y.Offset + delta.Y) / screenSize.Y
			ui.Position = UDim2.new(newXScale, 0, newYScale, 0)
		end)
		if not success then
			warn("[Dragger] update error:", err)
		end
	end

	pcall(function()
		dragui.InputBegan:Connect(function(input)
			local success, err = pcall(function()
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = ui.Position

					pcall(function()
						input.Changed:Connect(function()
							local ok, innerErr = pcall(function()
								if input.UserInputState == Enum.UserInputState.End then
									dragging = false
								end
							end)
							if not ok then warn("[Dragger] input.Changed error:", innerErr) end
						end)
					end)
				end
			end)
			if not success then warn("[Dragger] InputBegan error:", err) end
		end)
	end)

	pcall(function()
		dragui.InputChanged:Connect(function(input)
			local success, err = pcall(function()
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)
			if not success then warn("[Dragger] InputChanged error:", err) end
		end)
	end)

	pcall(function()
		UserInputService.InputChanged:Connect(function(input)
			local success, err = pcall(function()
				if input == dragInput and dragging then
					update(input)
				end
			end)
			if not success then warn("[Dragger] UserInputService.InputChanged error:", err) end
		end)
	end)

	local success, err = pcall(function()
		ui.Active = true
	end)
	if not success then warn("[Dragger] Set Active error:", err) end
end

_G.EnhancedNotifs = {
	Notify = function(Properties)
		local props             = typeof(Properties) == "table" and Properties or {}
		local Title, Description = props.Title, props.Description
		local Duration          = props.Duration or 5
		local Buttons           = props.Buttons or {}
		local InputFieldEnabled = props.InputField or false
		local ButtonCount       = #Buttons

		local multiMode     = false
		local selectedItems = {}
		local optionButtons = {}

		local baseY = 10
		if Title then baseY += 30 end

		local nf = CreateNotificationFrame(0)
		nf.Position = UDim2.new(1, -320, 1, -CalculateBounds(CachedObjects) - baseY)
		nf.Size     = UDim2.new(0, 300, 0, 0)
		nf.Parent   = Container

		local finalHeight, y = baseY, 10
		if Title then
			CreateTitle(Title, nf)
			y += 30
		end
		if Description then
			local _, h = CreateDescription(Description, nf, y)
			y += h + 10
			finalHeight += h + 10
		end

		local inputBox
		if InputFieldEnabled then
			inputBox = CreateInputField(nf, y)
			y += 40
			finalHeight += 40
		end

		local closeBtn = CreateCloseButton(nf)
		closeBtn.AnchorPoint = Vector2.new(1, 0)
		closeBtn.Position    = UDim2.new(1, -CLOSE_MARGIN, 0, CLOSE_MARGIN)
		closeBtn.MouseButton1Click:Connect(function() FadeOutAfter(nf, 0) end)

		local toggleBtn, confirmBtn
		if ButtonCount > 2 then
			toggleBtn = Instance.new("TextButton", nf)
			toggleBtn.Size            = UDim2.new(0, 24, 0, 24)
			toggleBtn.AnchorPoint     = Vector2.new(1, 0)
			toggleBtn.Position        = UDim2.new(1, -(CLOSE_MARGIN + 24), 0, CLOSE_MARGIN)
			toggleBtn.Text            = "M"
			toggleBtn.TextColor3      = NOTIFICATION_COLORS.Text
			toggleBtn.Font            = Enum.Font.GothamBold
			toggleBtn.TextSize        = 18
			toggleBtn.BackgroundColor3= BUTTON_COLORS.Default
			toggleBtn.BorderSizePixel = 0
			toggleBtn.AutoButtonColor = false
			Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

			confirmBtn = Instance.new("TextButton", nf)
			confirmBtn.Size            = UDim2.new(0, 24, 0, 24)
			confirmBtn.AnchorPoint     = Vector2.new(1, 0)
			confirmBtn.Position        = UDim2.new(1, -(CLOSE_MARGIN + 24 + SPACING + 24), 0, CLOSE_MARGIN)
			confirmBtn.Text            = "✅"
			confirmBtn.TextColor3      = NOTIFICATION_COLORS.Text
			confirmBtn.Font            = Enum.Font.GothamBold
			confirmBtn.TextSize        = 18
			confirmBtn.BackgroundColor3= BUTTON_COLORS.Default
			confirmBtn.BorderSizePixel = 0
			confirmBtn.AutoButtonColor = false
			Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(1, 0)
			confirmBtn.Visible = false

			toggleBtn.MouseButton1Click:Connect(function()
				multiMode = not multiMode
				toggleBtn.BackgroundColor3 = multiMode and Color3.fromRGB(0, 200, 0) or BUTTON_COLORS.Default
				if not multiMode then
					selectedItems = {}
					for _, b in ipairs(optionButtons) do
						b.BackgroundColor3 = BUTTON_COLORS.Default
					end
				end
				confirmBtn.Visible = multiMode and #selectedItems > 0
			end)

			confirmBtn.MouseButton1Click:Connect(function()
				for _, info in ipairs(selectedItems) do
					if info.Callback then
						if InputFieldEnabled then info.Callback(inputBox.Text)
						else info.Callback() end
					end
				end
				FadeOutAfter(nf, 0)
			end)
		end

		if ButtonCount > 0 then
			local sf = Instance.new("ScrollingFrame", nf)
			sf.Size, sf.Position           = UDim2.new(1, -30, 0, 100), UDim2.new(0, 15, 0, y)
			sf.BackgroundTransparency      = 1
			sf.BorderSizePixel, sf.ScrollBarThickness = 0, 6

			local perRow = ButtonCount <= 3 and ButtonCount or 3
			local rows   = math.ceil(ButtonCount / perRow)
			local totalH = rows * 35 + (rows - 1) * 5 + 5
			sf.CanvasSize = UDim2.new(0, 0, 0, totalH)

			for row = 1, rows do
				local countInRow = math.min(perRow, ButtonCount - (row - 1) * perRow)
				local btnW = (270 - (countInRow - 1) * 10) / countInRow
				for col = 1, countInRow do
					local idx, info = (row - 1) * perRow + col, Buttons[(row - 1) * perRow + col]
					if info then
						local x = (col - 1) * (btnW + 10)
						local b = Instance.new("TextButton")
						b.Size               = UDim2.new(0, btnW, 0, 30)
						b.Position           = UDim2.new(0, x, 0, (row - 1) * 40)
						b.Text               = info.Text
						b.TextScaled         = true
						b.Font               = Enum.Font.Gotham
						b.TextSize           = 14
						b.TextColor3         = NOTIFICATION_COLORS.Text
						b.BackgroundColor3   = BUTTON_COLORS.Default
						b.BorderSizePixel    = 0
						b.AutoButtonColor    = false
						Instance.new("UICorner", b).CornerRadius = UDim.new(0.3, 0)
						b.Parent             = sf
						table.insert(optionButtons, b)

						b.MouseButton1Click:Connect(function()
							if toggleBtn then
								if multiMode then
									local i = table.find(selectedItems, info)
									if i then
										table.remove(selectedItems, i)
										b.BackgroundColor3 = BUTTON_COLORS.Default
									else
										table.insert(selectedItems, info)
										b.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
									end
									confirmBtn.Visible = #selectedItems > 0
								else
									if info.Callback then
										if InputFieldEnabled then info.Callback(inputBox.Text)
										else info.Callback() end
									end
									FadeOutAfter(nf, 0)
								end
							else
								if info.Callback then
									if InputFieldEnabled then info.Callback(inputBox.Text)
									else info.Callback() end
								end
								FadeOutAfter(nf, 0)
							end
						end)
					end
				end
			end

			finalHeight += totalH + 5
		end

		TweenService:Create(nf,TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, finalHeight)}):Play()

		for _, d in ipairs(nf:GetDescendants()) do
			local p = PropertyTweenOut[string.sub(d.ClassName, 1, 4)]
			if p then
				d[p] = 1
				TweenService:Create(d,
					TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						[p] = 0
					}
				):Play()
			end
		end

		if nf:FindFirstChild("Shadow") then TweenService:Create(nf:FindFirstChild("Shadow"),TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency=0.4}):Play() end

		table.insert(InstructionObjects, {nf, 0, false})

		if ButtonCount == 0 then
			local accent = nf:FindFirstChild("AccentBar")
			if accent then
				TweenService:Create(accent,
					TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 0, 0, 4)
					}
				):Play()
			end
			FadeOutAfter(nf, Duration)
		end
	end,

	Window = function(Properties)
		local props             = typeof(Properties) == "table" and Properties or {}
		local Title             = props.Title or "Untitled"
		local Description       = props.Description or ""
		local Buttons           = props.Buttons or {}
		local InputFieldEnabled = props.InputField or false
		local ButtonCount       = #Buttons

		local multiMode     = false
		local selectedItems = {}
		local optionButtons = {}

		local wf = Instance.new("Frame", NotifGui)
		wf.Name                   = "WindowFrame"
		wf.AnchorPoint            = Vector2.new(0.5, 0)
		wf.Position               = UDim2.new(0.5, 0, 0.5, 0)
		wf.Size                   = UDim2.new(0, 0, 0, 0)
		wf.BackgroundColor3       = NOTIFICATION_COLORS.Background
		wf.BackgroundTransparency = 1
		wf.BorderSizePixel        = 0
		Instance.new("UICorner", wf).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke", wf)
		stroke.Color           = NOTIFICATION_COLORS.Stroke
		stroke.Thickness       = 1.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local y, totalH = 10, 0
		if Title ~= "" then
			CreateTitle(Title, wf)
			y += 30; totalH += 30
		end
		if Description ~= "" then
			local _, dh = CreateDescription(Description, wf, y)
			y += dh + 10; totalH += dh + 10
		end

		local inputBox
		if InputFieldEnabled then
			inputBox = CreateInputField(wf, y)
			y += 40; totalH += 40
		end

		local closeBtn = CreateCloseButton(wf)
		closeBtn.AnchorPoint = Vector2.new(1, 0)
		closeBtn.Position    = UDim2.new(1, -CLOSE_MARGIN, 0, CLOSE_MARGIN)
		closeBtn.MouseButton1Click:Connect(function() FadeOutAfter(wf, 0) end)

		local toggleBtn, confirmBtn
		if ButtonCount > 2 then
			toggleBtn = Instance.new("TextButton", wf)
			toggleBtn.Size            = UDim2.new(0, 24, 0, 24)
			toggleBtn.AnchorPoint     = Vector2.new(1, 0)
			toggleBtn.Position        = UDim2.new(1, -(CLOSE_MARGIN + 24), 0, CLOSE_MARGIN)
			toggleBtn.Text            = "M"
			toggleBtn.TextColor3      = NOTIFICATION_COLORS.Text
			toggleBtn.Font            = Enum.Font.GothamBold
			toggleBtn.TextSize        = 18
			toggleBtn.BackgroundColor3= BUTTON_COLORS.Default
			toggleBtn.BorderSizePixel = 0
			toggleBtn.AutoButtonColor = false
			Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

			confirmBtn = Instance.new("TextButton", wf)
			confirmBtn.Size            = UDim2.new(0, 24, 0, 24)
			confirmBtn.AnchorPoint     = Vector2.new(1, 0)
			confirmBtn.Position        = UDim2.new(1, -(CLOSE_MARGIN + 24 + SPACING + 24), 0, CLOSE_MARGIN)
			confirmBtn.Text            = "✅"
			confirmBtn.TextColor3      = NOTIFICATION_COLORS.Text
			confirmBtn.Font            = Enum.Font.GothamBold
			confirmBtn.TextSize        = 18
			confirmBtn.BackgroundColor3= BUTTON_COLORS.Default
			confirmBtn.BorderSizePixel = 0
			confirmBtn.AutoButtonColor = false
			Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(1, 0)
			confirmBtn.Visible = false

			toggleBtn.MouseButton1Click:Connect(function()
				multiMode = not multiMode
				toggleBtn.BackgroundColor3 = multiMode and Color3.fromRGB(0, 200, 0) or BUTTON_COLORS.Default
				if not multiMode then
					selectedItems = {}
					for _, b in ipairs(optionButtons) do b.BackgroundColor3 = BUTTON_COLORS.Default end
				end
				confirmBtn.Visible = multiMode and #selectedItems > 0
			end)

			confirmBtn.MouseButton1Click:Connect(function()
				for _, info in ipairs(selectedItems) do
					if info.Callback then
						if InputFieldEnabled then
							info.Callback(inputBox.Text)
						else
							info.Callback()
						end
					end
				end
				FadeOutAfter(wf, 0)
			end)
		end

		if ButtonCount > 0 then
			local perRow, rows = 3, math.ceil(ButtonCount / 3)
			local pad, bh      = 10, 30
			local bw           = (370 - (perRow - 1) * pad) / perRow

			for i, info in ipairs(Buttons) do
				local row = math.floor((i - 1) / perRow)
				local col = (i - 1) % perRow
				local x   = 15 + col * (bw + pad)
				local b   = Instance.new("TextButton")
				b.Size             = UDim2.new(0, bw, 0, bh)
				b.Position         = UDim2.new(0, x, 0, y + row * (bh + 10))
				b.Text             = info.Text
				b.TextScaled       = true
				b.Font             = Enum.Font.Gotham
				b.TextSize         = 14
				b.TextColor3       = NOTIFICATION_COLORS.Text
				b.BackgroundColor3 = BUTTON_COLORS.Default
				b.BorderSizePixel  = 0
				b.AutoButtonColor  = false
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
				b.Parent           = wf
				table.insert(optionButtons, b)

				b.MouseButton1Click:Connect(function()
					if multiMode then
						if table.find(selectedItems, info) then
							table.remove(selectedItems, table.find(selectedItems, info))
							b.BackgroundColor3 = BUTTON_COLORS.Default
						else
							table.insert(selectedItems, info)
							b.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
						end
						confirmBtn.Visible = #selectedItems > 0
					else
						if info.Callback then
							if InputFieldEnabled then
								info.Callback(inputBox.Text)
							else
								info.Callback()
							end
						end
						FadeOutAfter(wf, 0)
					end
				end)
			end

			totalH += rows * (bh + 10) - 10
		end

		totalH += 20
		TweenService:Create(wf,
			TweenInfo.new(0.6, TWEEN_STYLE, TWEEN_DIRECTION), {
				Size                   = UDim2.new(0, 400, 0, totalH),
				BackgroundTransparency = 0.4
			}
		):Play()

		for _, d in ipairs(wf:GetDescendants()) do
			local p = PropertyTweenOut[string.sub(d.ClassName, 1, 4)]
			if p then
				d[p] = 1
				TweenService:Create(d,
					TweenInfo.new(0.4, TWEEN_STYLE, TWEEN_DIRECTION), {
						[p] = 0
					}
				):Play()
			end
		end

		table.insert(AnnouncementObjects, {wf, 0, false})
	end,

	Popup = function(Properties)
		local props             = typeof(Properties) == "table" and Properties or {}
		local Title             = props.Title or "Popup"
		local Description       = props.Description or ""
		local Buttons           = props.Buttons or {}
		local InputFieldEnabled = props.InputField or false
		local buttonCount       = #Buttons

		local multiMode     = false
		local selectedItems = {}
		local optionButtons = {}

		local f = Instance.new("Frame", NotifGui)
		f.AnchorPoint           = Vector2.new(0.5, 0.5)
		f.Position              = UDim2.new(0.5, 0, 0.5, 0)
		f.Size                  = UDim2.new(0, 0, 0, 0)
		f.BackgroundColor3      = NOTIFICATION_COLORS.Background
		f.BackgroundTransparency= 1
		f.BorderSizePixel       = 0
		Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke", f)
		stroke.Color     = NOTIFICATION_COLORS.Stroke
		stroke.Thickness = 1.5

		local y, totalH = 10, 10
		if Title ~= "" then
			CreateTitle(Title, f)
			y += 30; totalH += 30
		end
		if Description ~= "" then
			local _, dh = CreateDescription(Description, f, y)
			y += dh + 10; totalH += dh + 10
		end

		local inputBox
		if InputFieldEnabled then
			inputBox = CreateInputField(f, y)
			y += 40; totalH += 40
		end

		local closeBtn = CreateCloseButton(f)
		closeBtn.AnchorPoint = Vector2.new(1, 0)
		closeBtn.Position    = UDim2.new(1, -CLOSE_MARGIN, 0, CLOSE_MARGIN)
		closeBtn.MouseButton1Click:Connect(function() FadeOutAfter(f, 0) end)

		local toggleBtn, confirmBtn
		if buttonCount > 2 then
			toggleBtn = Instance.new("TextButton", f)
			toggleBtn.Size            = UDim2.new(0, 24, 0, 24)
			toggleBtn.AnchorPoint     = Vector2.new(1, 0)
			toggleBtn.Position        = UDim2.new(1, -(CLOSE_MARGIN + 24), 0, CLOSE_MARGIN)
			toggleBtn.Text            = "M"
			toggleBtn.TextColor3      = NOTIFICATION_COLORS.Text
			toggleBtn.Font            = Enum.Font.GothamBold
			toggleBtn.TextSize        = 18
			toggleBtn.BackgroundColor3= BUTTON_COLORS.Default
			toggleBtn.BorderSizePixel = 0
			toggleBtn.AutoButtonColor = false
			Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

			confirmBtn = Instance.new("TextButton", f)
			confirmBtn.Size            = UDim2.new(0, 24, 0, 24)
			confirmBtn.AnchorPoint     = Vector2.new(1, 0)
			confirmBtn.Position        = UDim2.new(1, -(CLOSE_MARGIN + 24 + SPACING + 24), 0, CLOSE_MARGIN)
			confirmBtn.Text            = "✅"
			confirmBtn.TextColor3      = NOTIFICATION_COLORS.Text
			confirmBtn.Font            = Enum.Font.GothamBold
			confirmBtn.TextSize        = 18
			confirmBtn.BackgroundColor3= BUTTON_COLORS.Default
			confirmBtn.BorderSizePixel = 0
			confirmBtn.AutoButtonColor = false
			Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(1, 0)
			confirmBtn.Visible = false

			toggleBtn.MouseButton1Click:Connect(function()
				multiMode = not multiMode
				toggleBtn.BackgroundColor3 = multiMode and Color3.fromRGB(0, 200, 0) or BUTTON_COLORS.Default
				if not multiMode then
					selectedItems = {}
					for _, b in ipairs(optionButtons) do b.BackgroundColor3 = BUTTON_COLORS.Default end
				end
				confirmBtn.Visible = multiMode and #selectedItems > 0
			end)

			confirmBtn.MouseButton1Click:Connect(function()
				for _, info in ipairs(selectedItems) do
					if info.Callback then
						if InputFieldEnabled then
							info.Callback(inputBox.Text)
						else
							info.Callback()
						end
					end
				end
				FadeOutAfter(f, 0)
			end)
		end

		dragger(f)

		if buttonCount > 0 then
			local pad    = 10
			local bw     = (300 - pad * (buttonCount + 1)) / buttonCount
			for i, info in ipairs(Buttons) do
				local x = pad + (i - 1) * (bw + pad)
				local b = Instance.new("TextButton")
				b.Size             = UDim2.new(0, bw, 0, 30)
				b.Position         = UDim2.new(0, x, 0, y)
				b.Text             = info.Text or ""
				b.TextScaled       = true
				b.Font             = Enum.Font.Gotham
				b.TextSize         = 14
				b.TextColor3       = NOTIFICATION_COLORS.Text
				b.BackgroundColor3 = BUTTON_COLORS.Default
				b.BorderSizePixel  = 0
				b.AutoButtonColor  = false
				Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
				b.Parent           = f
				table.insert(optionButtons, b)

				b.MouseButton1Click:Connect(function()
					if multiMode then
						if table.find(selectedItems, info) then
							table.remove(selectedItems, table.find(selectedItems, info))
							b.BackgroundColor3 = BUTTON_COLORS.Default
						else
							table.insert(selectedItems, info)
							b.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
						end
						confirmBtn.Visible = #selectedItems > 0
					else
						if info.Callback then
							if InputFieldEnabled then
								info.Callback(inputBox.Text)
							else
								info.Callback()
							end
						end
						FadeOutAfter(f, 0)
					end
				end)
			end
			totalH += 30 + 10
		end

		TweenService:Create(f,
			TweenInfo.new(0.6, TWEEN_STYLE, TWEEN_DIRECTION), {
				Size                   = UDim2.new(0, 300, 0, totalH + 20),
				BackgroundTransparency = 0.15
			}
		):Play()
	end,
}

return _G.EnhancedNotifs