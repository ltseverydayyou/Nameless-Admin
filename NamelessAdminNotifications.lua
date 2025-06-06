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
	NotifGui.DisplayOrder = 999999999
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
	Frame.BackgroundTransparency = 0.5
	Frame.BorderSizePixel = 0

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = NOTIFICATION_COLORS.Stroke
	Stroke.Thickness = 1.5
	Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	Stroke.Transparency = 0
	Stroke.Parent = Frame

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = Frame

	local AccentBar = Instance.new("Frame")
	AccentBar.Name = "AccentBar"
	AccentBar.Size = UDim2.new(1, 0, 0, 4)
	AccentBar.Position = UDim2.new(0, 0, 1, -4)
	AccentBar.BackgroundColor3 = NOTIFICATION_COLORS.Accent
	AccentBar.BorderSizePixel = 0
	AccentBar.Parent = Frame

	local UICornerAccent = Instance.new("UICorner")
	UICornerAccent.CornerRadius = UDim.new(0, 8)
	UICornerAccent.Parent = AccentBar

	local Shadow = Instance.new("Frame")
	Shadow.Size = UDim2.new(1, 10, 1, 10)
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundTransparency = 0.5
	Shadow.BackgroundColor3 = NOTIFICATION_COLORS.Shadow
	Shadow.BorderSizePixel = 0
	Shadow.ZIndex = -1
	Shadow.Parent = Frame

	local ShadowUICorner = Instance.new("UICorner")
	ShadowUICorner.CornerRadius = UDim.new(0, 10)
	ShadowUICorner.Parent = Shadow

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

		local fadeTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

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

		task.wait(0.4)
		local index = FindIndexByDependency(InstructionObjects, Object)
		if index then
			table.remove(InstructionObjects, index)
			ResetObjects()
		end
		local aIndex = FindIndexByDependency(AnnouncementObjects, Object)
		if aIndex then
			table.remove(AnnouncementObjects, aIndex)
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

_G.EnhancedNotifs = {
	Notify = function(Properties)
		local Properties = typeof(Properties) == "table" and Properties or {}
		local Title = Properties.Title
		local Description = Properties.Description
		local Duration = Properties.Duration or 5
		local Buttons = Properties.Buttons or {}
		local InputFieldEnabled = Properties.InputField or false
		local ButtonCount = #Buttons

		local Y = 10
		if Title then Y += 30 end

		local NewNotif = CreateNotificationFrame(0)
		local finalHeight = Y
		local finalPos = UDim2.new(1, -320, 1, -CalculateBounds(CachedObjects) - finalHeight)

		NewNotif.Position = finalPos
		NewNotif.Size = UDim2.new(0, 300, 0, 0)
		NewNotif.BackgroundTransparency = 1
		NewNotif.Parent = Container

		local YPosition = 10
		if Title then
			CreateTitle(Title, NewNotif)
			YPosition += 30
		end

		if Description then
			local DescLabel, TextHeight = CreateDescription(Description, NewNotif, YPosition)
			finalHeight += TextHeight + 10
			YPosition += TextHeight + 10
		end

		local InputField
		if InputFieldEnabled then
			InputField = CreateInputField(NewNotif, YPosition)
			finalHeight += 40
			YPosition += 40
		end

		local CloseBtn = CreateCloseButton(NewNotif)
		CloseBtn.MouseButton1Click:Connect(function()
			FadeOutAfter(NewNotif, 0)
		end)

		if ButtonCount > 0 then
			local ScrollingFrame = Instance.new("ScrollingFrame")
			ScrollingFrame.Size = UDim2.new(1, -30, 0, 100)
			ScrollingFrame.Position = UDim2.new(0, 15, 0, YPosition)
			ScrollingFrame.BackgroundTransparency = 1
			ScrollingFrame.BorderSizePixel = 0
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			ScrollingFrame.ScrollBarThickness = 6
			ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
			ScrollingFrame.Parent = NewNotif

			local buttonsPerRow = ButtonCount <= 3 and ButtonCount or 3
			local rows = math.ceil(ButtonCount / buttonsPerRow)
			local totalHeight = rows * 35 + (rows - 1) * 5 + 5
			ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

			for row = 1, rows do
				local buttonsInThisRow = math.min(buttonsPerRow, ButtonCount - (row - 1) * buttonsPerRow)
				local buttonWidth = (270 - ((buttonsInThisRow - 1) * 10)) / buttonsInThisRow

				for col = 1, buttonsInThisRow do
					local buttonIndex = (row - 1) * buttonsPerRow + col
					local ButtonInfo = Buttons[buttonIndex]

					if ButtonInfo then
						local xPos = (col - 1) * (buttonWidth + 10)
						local yPos = (row - 1) * 40

						local Button = CreateSquircleButton(
							ButtonInfo.Text,
							buttonWidth,
							30,
							ScrollingFrame,
							UDim2.new(0, xPos, 0, yPos)
						)

						Button.MouseButton1Click:Connect(function()
							if ButtonInfo.Callback then
								if InputFieldEnabled then
									ButtonInfo.Callback(InputField.Text)
								else
									ButtonInfo.Callback()
								end
							end
							FadeOutAfter(NewNotif, 0)
						end)
					end
				end
			end

			finalHeight += 100
		end

		NewNotif.Size = UDim2.new(0, 300, 0, 0)
		NewNotif.BackgroundTransparency = 1

		TweenService:Create(NewNotif, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 300, 0, finalHeight),
			BackgroundTransparency = 0.4
		}):Play()

		for _, desc in NewNotif:GetDescendants() do
			local prop = PropertyTweenOut[string.sub(desc.ClassName, 1, 4)]
			if prop then
				desc[prop] = 1
				TweenService:Create(desc, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					[prop] = 0
				}):Play()
			end
		end

		table.insert(InstructionObjects, {NewNotif, 0, false})

		if ButtonCount == 0 then
			local accent = NewNotif:FindFirstChild("AccentBar")
			if accent then
				TweenService:Create(accent, TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, 0, 0, 4)
				}):Play()
			end
			FadeOutAfter(NewNotif, Duration)
		end
	end,

	Window = function(Properties)
		local Properties = typeof(Properties) == "table" and Properties or {}
		local Title = Properties.Title or "Untitled"
		local Description = Properties.Description or ""
		local Duration = Properties.Duration or 0
		local Buttons = Properties.Buttons or {}
		local InputFieldEnabled = Properties.InputField or false
		local ButtonCount = #Buttons

		local Gui = Instance.new("ScreenGui")
		Gui.Name = "EnhancedWindow"
		Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		Gui.ResetOnSpawn = false
		Gui.IgnoreGuiInset = true
		Gui.DisplayOrder = 999999998
		Gui.Parent = GETTHEUI()

		local WindowFrame = Instance.new("Frame")
		WindowFrame.Size = UDim2.new(0, 400, 0, 0)
		WindowFrame.Position = UDim2.new(0.5, 0, 0, -100)
		WindowFrame.AnchorPoint = Vector2.new(0.5, 0)
		WindowFrame.BackgroundColor3 = NOTIFICATION_COLORS.Background
		WindowFrame.BackgroundTransparency = 1
		WindowFrame.BorderSizePixel = 0
		WindowFrame.Parent = Gui

		local UICorner = Instance.new("UICorner", WindowFrame)
		UICorner.CornerRadius = UDim.new(0, 8)

		local Stroke = Instance.new("UIStroke", WindowFrame)
		Stroke.Color = NOTIFICATION_COLORS.Stroke
		Stroke.Thickness = 1.5
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.Transparency = 0

		local YPosition = 10
		local Height = 0

		if Title then
			CreateTitle(Title, WindowFrame)
			YPosition += 30
			Height += 30
		end

		if Description ~= "" then
			local Desc, DescHeight = CreateDescription(Description, WindowFrame, YPosition)
			YPosition += DescHeight + 10
			Height += DescHeight + 10
		end

		local InputField
		if InputFieldEnabled then
			InputField = CreateInputField(WindowFrame, YPosition)
			YPosition += 40
			Height += 40
		end

		if ButtonCount > 0 then
			local ButtonPadding = 10
			local TotalWidth = 370
			local ButtonWidth = (TotalWidth - ((ButtonCount - 1) * ButtonPadding)) / ButtonCount
			for i, ButtonInfo in ipairs(Buttons) do
				local Button = CreateSquircleButton(
					ButtonInfo.Text,
					ButtonWidth,
					30,
					WindowFrame,
					UDim2.new(0, 15 + (i - 1) * (ButtonWidth + ButtonPadding), 0, YPosition)
				)
				Button.MouseButton1Click:Connect(function()
					if ButtonInfo.Callback then
						if InputFieldEnabled then
							ButtonInfo.Callback(InputField.Text)
						else
							ButtonInfo.Callback()
						end
					end
					FadeOutAfter(WindowFrame, 0)
				end)
			end
			YPosition += 40
			Height += 40
		end

		local CloseBtn = CreateCloseButton(WindowFrame)
		CloseBtn.MouseButton1Click:Connect(function()
			FadeOutAfter(WindowFrame, 0)
		end)

		WindowFrame.Size = UDim2.new(0, 400, 0, Height + 20)
		WindowFrame.BackgroundTransparency = 1
		WindowFrame.Position = UDim2.new(0.5, 0, 0, -100)

		TweenService:Create(WindowFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.4
		}):Play()

		for _, desc in WindowFrame:GetDescendants() do
			local prop = PropertyTweenOut[string.sub(desc.ClassName, 1, 4)]
			if prop then
				desc[prop] = 1
				TweenService:Create(desc, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					[prop] = 0
				}):Play()
			end
		end

		table.insert(AnnouncementObjects, {WindowFrame, 0, false})

		if ButtonCount == 0 and Duration > 0 then
			task.delay(Duration, function()
				if WindowFrame then
					FadeOutAfter(WindowFrame, 0)
				end
			end)
		end
	end
}

return _G.EnhancedNotifs