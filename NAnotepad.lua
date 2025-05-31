local Notepad = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Container = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local ScrollingFrame = Instance.new("ScrollingFrame")
local TextBox = Instance.new("TextBox")
local Topbar = Instance.new("Frame")
local Icon = Instance.new("ImageLabel")
local Exit = Instance.new("TextButton")
local Minimize = Instance.new("TextButton")
local TopBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UICorner_2 = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")
local ButtonsFrame = Instance.new("Frame")
local ClearButton = Instance.new("TextButton")
local CopyButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local CharCount = Instance.new("TextLabel")

local function SafeGetService(name)
    local service = (cloneref and cloneref(game:GetService(name))) or game:GetService(name)
    return service
end

local function protectUI(sGui)
    if sGui:IsA("ScreenGui") then
        sGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		sGui.DisplayOrder = 999999999
		sGui.ResetOnSpawn = false
		sGui.IgnoreGuiInset = true
    end
    local cGUI = SafeGetService("CoreGui")
    local lPlr = SafeGetService("Players").LocalPlayer

    local function NAProtection(inst, var)
        if inst then
            if var then
                inst[var] = "\0"
                inst.Archivable = false
            else
                inst.Name = "\0"
                inst.Archivable = false
            end
        end
    end

    if gethui then
		NAProtection(sGui)
		sGui.Parent = gethui()
		return sGui
	elseif cGUI and cGUI:FindFirstChild("RobloxGui") then
		NAProtection(sGui)
		sGui.Parent = cGUI:FindFirstChild("RobloxGui")
		return sGui
	elseif cGUI then
		NAProtection(sGui)
		sGui.Parent = cGUI
		return sGui
	elseif lPlr and lPlr:FindFirstChild("PlayerGui") then
		NAProtection(sGui)
		sGui.Parent = lPlr:FindFirstChild("PlayerGui")
		sGui.ResetOnSpawn = false
		return sGui
	else
		return nil
	end
end

Notepad.Name = "Notepad"
protectUI(Notepad)
Notepad.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Notepad.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = Notepad
Main.BackgroundColor3 = Color3.fromRGB(20, 21, 30)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Position = UDim2.new(0.308, 0, 1.262, 0)
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Active = true
Main.Draggable = true

UIStroke.Parent = Main
UIStroke.Color = Color3.fromRGB(85, 85, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.1
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

Container.Name = "Container"
Container.Parent = Main
Container.AnchorPoint = Vector2.new(0.5, 1)
Container.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Container.BorderSizePixel = 0
Container.ClipsDescendants = true
Container.Position = UDim2.new(0.5, 0, 0.996, -5)
Container.Size = UDim2.new(1, -10, 0.9, -30)

UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Container

UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 42)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 37, 52))
}
UIGradient.Parent = Container

ScrollingFrame.Parent = Container
ScrollingFrame.Active = true
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)

TextBox.Parent = ScrollingFrame
TextBox.BackgroundTransparency = 1
TextBox.Position = UDim2.new(0, 5, 0, 0)
TextBox.Size = UDim2.new(1, -15, 0, 200)
TextBox.ClearTextOnFocus = false
TextBox.Font = Enum.Font.SourceSans
TextBox.MultiLine = true
TextBox.PlaceholderText = "Enter your text here..."
TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(230, 230, 240)
TextBox.TextSize = 18
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top
TextBox.TextWrapped = true

ButtonsFrame.Name = "ButtonsFrame"
ButtonsFrame.Parent = Container
ButtonsFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 48)
ButtonsFrame.BackgroundTransparency = 0
ButtonsFrame.BorderSizePixel = 0
ButtonsFrame.Position = UDim2.new(0, 5, 1, -35)
ButtonsFrame.Size = UDim2.new(1, -10, 0, 34)

ClearButton.Name = "ClearButton"
ClearButton.Parent = ButtonsFrame
ClearButton.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
ClearButton.BorderSizePixel = 0
ClearButton.Position = UDim2.new(0, 5, 0, 2)
ClearButton.Size = UDim2.new(0, 80, 0, 26)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Text = "Clear"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 16

CopyButton.Name = "CopyButton"
CopyButton.Parent = ButtonsFrame
CopyButton.BackgroundColor3 = Color3.fromRGB(90, 220, 90)
CopyButton.BorderSizePixel = 0
CopyButton.Position = UDim2.new(0, 95, 0, 2)
CopyButton.Size = UDim2.new(0, 80, 0, 26)
CopyButton.Font = Enum.Font.GothamBold
CopyButton.Text = "Copy"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.TextSize = 16

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = ButtonsFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 185, 0, 2)
StatusLabel.Size = UDim2.new(1, -190, 0, 26)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
StatusLabel.TextSize = 14

CharCount.Name = "CharCount"
CharCount.Parent = Container
CharCount.BackgroundTransparency = 1
CharCount.Position = UDim2.new(0, 5, 1, -55)
CharCount.Size = UDim2.new(1, -10, 0, 20)
CharCount.Font = Enum.Font.Gotham
CharCount.Text = "Characters: 0"
CharCount.TextColor3 = Color3.fromRGB(170, 170, 190)
CharCount.TextSize = 14
CharCount.TextXAlignment = Enum.TextXAlignment.Right

Topbar.Name = "Topbar"
Topbar.Parent = Main
Topbar.BackgroundColor3 = Color3.fromRGB(26, 27, 38)
Topbar.BorderSizePixel = 0
Topbar.Size = UDim2.new(1, 0, 0, 30)

Icon.Name = "Icon"
Icon.Parent = Topbar
Icon.AnchorPoint = Vector2.new(0, 0.5)
Icon.BackgroundTransparency = 1
Icon.Position = UDim2.new(0, 10, 0.5, 0)
Icon.Size = UDim2.new(0, 18, 0, 18)
Icon.Image = "rbxassetid://7733658504"

Exit.Name = "Exit"
Exit.Parent = Topbar
Exit.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
Exit.BorderSizePixel = 0
Exit.Position = UDim2.new(1, -30, 0, 5)
Exit.Size = UDim2.new(0, 20, 0, 20)
Exit.Font = Enum.Font.GothamBold
Exit.Text = "X"
Exit.TextColor3 = Color3.fromRGB(255, 255, 255)
Exit.TextSize = 14

Minimize.Name = "Minimize"
Minimize.Parent = Topbar
Minimize.BackgroundColor3 = Color3.fromRGB(70, 70, 255)
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(1, -60, 0, 5)
Minimize.Size = UDim2.new(0, 20, 0, 20)
Minimize.Font = Enum.Font.GothamBold
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
Minimize.TextSize = 18

TopBar.Name = "TopBar"
TopBar.Parent = Topbar
TopBar.BackgroundTransparency = 1
TopBar.Position = UDim2.new(0, 30, 0, 0)
TopBar.Size = UDim2.new(1, -100, 1, 0)

Title.Name = "Title"
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Font = Enum.Font.GothamSemibold
Title.Text = "Nameless Admin Notepad"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.TextSize = 17

UICorner_2.CornerRadius = UDim.new(0, 12)
UICorner_2.Parent = Main

local isMinimized = false

local function updateCharCount()
    CharCount.Text = "Characters: " .. string.len(TextBox.Text)
end

local function showStatus(message, color)
    StatusLabel.Text = message
    StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    task.delay(3, function()
        StatusLabel.Text = ""
    end)
end

local function updateTextBoxSize()
    local textBounds = SafeGetService("TextService"):GetTextSize(
        TextBox.Text,
        TextBox.TextSize,
        TextBox.Font,
        Vector2.new(TextBox.AbsoluteSize.X, math.huge)
    )
    
    local minHeight = ScrollingFrame.AbsoluteSize.Y
    local newHeight = math.max(minHeight, textBounds.Y + 50)
    
    TextBox.Size = UDim2.new(1, -15, 0, newHeight)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, newHeight)
end

Exit.MouseButton1Click:Connect(function()
    Notepad:Destroy()
end)

Minimize.MouseButton1Click:Connect(function()
    if not isMinimized then
        Main:TweenSize(UDim2.new(0, 450, 0, 30), "Out", "Quint", 0.5, true)
    else
        Main:TweenSize(UDim2.new(0, 450, 0, 300), "Out", "Quint", 0.5, true)
    end
    isMinimized = not isMinimized
end)

ClearButton.MouseButton1Click:Connect(function()
    TextBox.Text = ""
    updateCharCount()
    updateTextBoxSize()
    showStatus("Text cleared!", Color3.fromRGB(255, 100, 100))
end)

CopyButton.MouseButton1Click:Connect(function()
    setclipboard(TextBox.Text)
    showStatus("Text copied to clipboard!", Color3.fromRGB(60, 180, 255))
end)

TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    updateCharCount()
    updateTextBoxSize()
end)

ScrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTextBoxSize)

Main:TweenPosition(UDim2.new(0.308, 0, 0.262, 0), "Out", "Quint", 1, true)

for _, button in pairs({ClearButton, CopyButton}) do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button

	button.MouseEnter:Connect(function()
		button.BackgroundTransparency = 0.1
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundTransparency = 0
	end)
end

updateTextBoxSize()