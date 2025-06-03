local AdminUI = Instance.new("ScreenGui")
local AutoScale = Instance.new("UIScale")
local CmdBar = Instance.new("Frame")
local CenterBar = Instance.new("Frame")
local Horizontal = Instance.new("Frame")
local UICorners = Instance.new("UICorner")
local UIGradients = Instance.new("UIGradient")
local Input = Instance.new("TextBox")
local LeftFill = Instance.new("Frame")
local Horizontal_2 = Instance.new("Frame")
local UICorners_2 = Instance.new("UICorner")
local UIGradients_2 = Instance.new("UIGradient")
local RightFill = Instance.new("Frame")
local Horizontal_3 = Instance.new("Frame")
local UICorners_3 = Instance.new("UICorner")
local UIGradients_3 = Instance.new("UIGradient")
local Autofill = Instance.new("ScrollingFrame")
local Cmd = Instance.new("Frame")
local Input_2 = Instance.new("TextLabel")
local Background = Instance.new("Frame")
local Horizontal_4 = Instance.new("Frame")
local UICorners_4 = Instance.new("UICorner")
local UIGradients_4 = Instance.new("UIGradient")
local UIListLayout = Instance.new("UIListLayout")
local Commands = Instance.new("Frame")
local Container = Instance.new("Frame")
local List = Instance.new("ScrollingFrame")
local UIListLayout_2 = Instance.new("UIListLayout")
local TextLabel = Instance.new("TextLabel")
local Filter = Instance.new("TextBox")
local UICorner = Instance.new("UICorner")
local UICorner_2 = Instance.new("UICorner")
local UIGradient = Instance.new("UIGradient")
local Topbar = Instance.new("Frame")
local Exit = Instance.new("TextButton")
local UICorners_5 = Instance.new("UICorner")
local Minimize = Instance.new("TextButton")
local UICorners_6 = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local UICorners_7 = Instance.new("UICorner")
local UIGradients_5 = Instance.new("UIGradient")
local Resizeable = Instance.new("Frame")
local Left = Instance.new("Frame")
local Right = Instance.new("Frame")
local Top = Instance.new("Frame")
local Bottom = Instance.new("Frame")
local TopLeft = Instance.new("Frame")
local TopRight = Instance.new("Frame")
local BottomLeft = Instance.new("Frame")
local BottomRight = Instance.new("Frame")
local Description = Instance.new("TextLabel")
local UICorner_3 = Instance.new("UICorner")
local UpdLog = Instance.new("Frame")
local Container_2 = Instance.new("Frame")
local List_2 = Instance.new("ScrollingFrame")
local UIListLayout_3 = Instance.new("UIListLayout")
local TextLabel_2 = Instance.new("TextLabel")
local UICorner_4 = Instance.new("UICorner")
local UIGradient_2 = Instance.new("UIGradient")
local Topbar_2 = Instance.new("Frame")
local Exit_2 = Instance.new("TextButton")
local UICorners_8 = Instance.new("UICorner")
local Minimize_2 = Instance.new("TextButton")
local UICorners_9 = Instance.new("UICorner")
local Title_2 = Instance.new("TextLabel")
local UICorners_10 = Instance.new("UICorner")
local UIGradients_6 = Instance.new("UIGradient")
local ChatLogs = Instance.new("Frame")
local Container_3 = Instance.new("Frame")
local Logs = Instance.new("ScrollingFrame")
local UIListLayout_4 = Instance.new("UIListLayout")
local TextLabel_3 = Instance.new("TextLabel")
local UICorner_5 = Instance.new("UICorner")
local UIGradient_3 = Instance.new("UIGradient")
local Topbar_3 = Instance.new("Frame")
local Exit_3 = Instance.new("TextButton")
local UICorners_11 = Instance.new("UICorner")
local Minimize_3 = Instance.new("TextButton")
local UICorners_12 = Instance.new("UICorner")
local Clear = Instance.new("TextButton")
local UICorners_13 = Instance.new("UICorner")
local Title_3 = Instance.new("TextLabel")
local UICorners_14 = Instance.new("UICorner")
local UIGradients_7 = Instance.new("UIGradient")
local soRealConsole = Instance.new("Frame")
local Container_4 = Instance.new("Frame")
local Logs_2 = Instance.new("ScrollingFrame")
local UIListLayout_5 = Instance.new("UIListLayout")
local TextLabel_4 = Instance.new("TextLabel")
local UICorner_6 = Instance.new("UICorner")
local UIGradient_4 = Instance.new("UIGradient")
local Filter_2 = Instance.new("TextBox")
local UICorner_7 = Instance.new("UICorner")
local Topbar_4 = Instance.new("Frame")
local Exit_4 = Instance.new("TextButton")
local UICorners_15 = Instance.new("UICorner")
local Minimize_4 = Instance.new("TextButton")
local UICorners_16 = Instance.new("UICorner")
local Clear_2 = Instance.new("TextButton")
local UICorners_17 = Instance.new("UICorner")
local Title_4 = Instance.new("TextLabel")
local UICorners_18 = Instance.new("UICorner")
local UIGradients_8 = Instance.new("UIGradient")
local Modal = Instance.new("ImageButton")

AdminUI.Name = "AdminUI"
AdminUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AdminUI.ResetOnSpawn = false

AutoScale.Name = "AutoScale"
AutoScale.Parent = AdminUI

CmdBar.Name = "CmdBar"
CmdBar.Parent = AdminUI
CmdBar.AnchorPoint = Vector2.new(0.5, 0.5)
CmdBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CmdBar.BackgroundTransparency = 1.000
CmdBar.Position = UDim2.new(0.5, 0, 0.5, -20)
CmdBar.Size = UDim2.new(1, 0, 0, 25)

CenterBar.Name = "CenterBar"
CenterBar.Parent = CmdBar
CenterBar.AnchorPoint = Vector2.new(0.5, 0.5)
CenterBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CenterBar.BackgroundTransparency = 1.000
CenterBar.Position = UDim2.new(0.5, 0, 0.5, 0)
CenterBar.Size = UDim2.new(0, 250, 1, 15)
CenterBar.ZIndex = 2

Horizontal.Name = "Horizontal"
Horizontal.Parent = CenterBar
Horizontal.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
Horizontal.BackgroundTransparency = 0.140
Horizontal.BorderColor3 = Color3.fromRGB(27, 27, 27)
Horizontal.BorderSizePixel = 0
Horizontal.Size = UDim2.new(1, 0, 1, 0)

UICorners.Name = "UICorners"
UICorners.Parent = Horizontal

UIGradients.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients.Name = "UIGradients"
UIGradients.Parent = Horizontal

Input.Name = "Input"
Input.Parent = CenterBar
Input.Active = false
Input.AnchorPoint = Vector2.new(0.5, 0.5)
Input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Input.BackgroundTransparency = 1.000
Input.ClipsDescendants = true
Input.Position = UDim2.new(0.5, 0, 0.5, 0)
Input.Size = UDim2.new(1, -5, 0.699999988, 0)
Input.ZIndex = 2
Input.Font = Enum.Font.GothamMedium
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(241, 241, 241)
Input.TextScaled = true
Input.TextSize = 24.000
Input.TextWrapped = true
Input.TextXAlignment = Enum.TextXAlignment.Left

LeftFill.Name = "LeftFill"
LeftFill.Parent = CmdBar
LeftFill.AnchorPoint = Vector2.new(0, 0.5)
LeftFill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LeftFill.BackgroundTransparency = 1.000
LeftFill.Position = UDim2.new(0, 0, 0.5, 0)
LeftFill.Size = UDim2.new(0.5, -125, 1, 0)

Horizontal_2.Name = "Horizontal"
Horizontal_2.Parent = LeftFill
Horizontal_2.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
Horizontal_2.BackgroundTransparency = 0.140
Horizontal_2.BorderColor3 = Color3.fromRGB(27, 27, 27)
Horizontal_2.BorderSizePixel = 0
Horizontal_2.Size = UDim2.new(1.005988, 0, 1, 0)

UICorners_2.Name = "UICorners"
UICorners_2.Parent = Horizontal_2

UIGradients_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients_2.Name = "UIGradients"
UIGradients_2.Parent = Horizontal_2

RightFill.Name = "RightFill"
RightFill.Parent = CmdBar
RightFill.AnchorPoint = Vector2.new(1, 0.5)
RightFill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
RightFill.BackgroundTransparency = 1.000
RightFill.Position = UDim2.new(1, 0, 0.5, 0)
RightFill.Size = UDim2.new(0.5, -125, 1, 0)

Horizontal_3.Name = "Horizontal"
Horizontal_3.Parent = RightFill
Horizontal_3.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
Horizontal_3.BackgroundTransparency = 0.140
Horizontal_3.BorderColor3 = Color3.fromRGB(27, 27, 27)
Horizontal_3.BorderSizePixel = 0
Horizontal_3.Position = UDim2.new(-0.00798403192, 0, 0, 0)
Horizontal_3.Size = UDim2.new(1.00798404, 0, 1, 0)

UICorners_3.Name = "UICorners"
UICorners_3.Parent = Horizontal_3

UIGradients_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients_3.Name = "UIGradients"
UIGradients_3.Parent = Horizontal_3

Autofill.Name = "Autofill"
Autofill.Parent = CmdBar
Autofill.AnchorPoint = Vector2.new(0.5, 0)
Autofill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Autofill.BackgroundTransparency = 1.000
Autofill.Position = UDim2.new(0.5, 0, -6.51999998, 10)
Autofill.Selectable = false
Autofill.Size = UDim2.new(1, 0, 0, 138)
Autofill.CanvasSize = UDim2.new(0, 0, 5, 0)
Autofill.ScrollingEnabled = false

Cmd.Name = "Cmd"
Cmd.Parent = Autofill
Cmd.AnchorPoint = Vector2.new(0.5, 0)
Cmd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Cmd.BackgroundTransparency = 1.000
Cmd.Position = UDim2.new(0.5, 0, 0.818840563, 0)
Cmd.Size = UDim2.new(0.5, 0, 0, 25)

Input_2.Name = "Input"
Input_2.Parent = Cmd
Input_2.Active = true
Input_2.AnchorPoint = Vector2.new(0, 0.5)
Input_2.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
Input_2.BackgroundTransparency = 1.000
Input_2.ClipsDescendants = true
Input_2.Position = UDim2.new(0, 0, 0.5, 0)
Input_2.Selectable = true
Input_2.Size = UDim2.new(1, 0, 1, -5)
Input_2.ZIndex = 2
Input_2.Font = Enum.Font.GothamMedium
Input_2.Text = "example <player> <text>"
Input_2.TextColor3 = Color3.fromRGB(241, 241, 241)
Input_2.TextScaled = true
Input_2.TextSize = 24.000
Input_2.TextWrapped = true

Background.Name = "Background"
Background.Parent = Cmd
Background.AnchorPoint = Vector2.new(0.5, 0)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 1.000
Background.Position = UDim2.new(0.5, 0, 0, 0)
Background.Size = UDim2.new(1, 0, 1, 0)

Horizontal_4.Name = "Horizontal"
Horizontal_4.Parent = Background
Horizontal_4.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
Horizontal_4.BackgroundTransparency = 0.140
Horizontal_4.BorderSizePixel = 0
Horizontal_4.Size = UDim2.new(1, 0, 1, 0)

UICorners_4.Name = "UICorners"
UICorners_4.Parent = Horizontal_4

UIGradients_4.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients_4.Name = "UIGradients"
UIGradients_4.Parent = Horizontal_4

UIListLayout.Parent = Autofill
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, 3)

Commands.Name = "Commands"
Commands.Parent = AdminUI
Commands.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
Commands.BackgroundTransparency = 0.140
Commands.BorderColor3 = Color3.fromRGB(139, 139, 139)
Commands.BorderSizePixel = 0
Commands.Position = UDim2.new(0.0185509454, 0, 0.524926484, 0)
Commands.Size = UDim2.new(0, 283, 0, 286)

Container.Name = "Container"
Container.Parent = Commands
Container.AnchorPoint = Vector2.new(0.5, 1)
Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Container.BackgroundTransparency = 0.500
Container.BorderColor3 = Color3.fromRGB(255, 255, 255)
Container.BorderSizePixel = 0
Container.ClipsDescendants = true
Container.Position = UDim2.new(0.5, 0, 1, -5)
Container.Size = UDim2.new(1, -10, 1.01153851, -30)

List.Name = "List"
List.Parent = Container
List.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
List.BackgroundTransparency = 1.000
List.BorderColor3 = Color3.fromRGB(16, 16, 16)
List.BorderSizePixel = 0
List.Position = UDim2.new(0, 6, 0, 27)
List.Size = UDim2.new(1, -10, 1, -27)
List.BottomImage = "rbxgameasset://Images/scrollBottom (1)"
List.MidImage = "rbxgameasset://Images/scrollMid"
List.ScrollBarThickness = 4
List.TopImage = "rbxgameasset://Images/scrollTop"

UIListLayout_2.Parent = List
UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_2.Padding = UDim.new(0, 2)

TextLabel.Parent = List
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.Position = UDim2.new(0, 0, 0.0173913036, 0)
TextLabel.Size = UDim2.new(1, 0, 0, 20)
TextLabel.Font = Enum.Font.GothamMedium
TextLabel.Text = "example <player> <text>"
TextLabel.TextColor3 = Color3.fromRGB(241, 241, 241)
TextLabel.TextScaled = true
TextLabel.TextSize = 15.000
TextLabel.TextWrapped = true

Filter.Name = "Filter"
Filter.Parent = Container
Filter.AnchorPoint = Vector2.new(0.5, 0)
Filter.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
Filter.BackgroundTransparency = 0.700
Filter.BorderSizePixel = 0
Filter.Position = UDim2.new(0.5, 0, 0, 5)
Filter.Size = UDim2.new(1, -10, 0, 20)
Filter.Font = Enum.Font.GothamMedium
Filter.PlaceholderColor3 = Color3.fromRGB(124, 124, 124)
Filter.PlaceholderText = "Filter commands..."
Filter.Text = ""
Filter.TextColor3 = Color3.fromRGB(241, 241, 241)
Filter.TextSize = 18.000

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = Filter

UICorner_2.CornerRadius = UDim.new(0, 9)
UICorner_2.Parent = Container

UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient.Parent = Container

Topbar.Name = "Topbar"
Topbar.Parent = Commands
Topbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Topbar.BackgroundTransparency = 1.000
Topbar.Size = UDim2.new(1, 0, 0, 25)

Exit.Name = "Exit"
Exit.Parent = Topbar
Exit.AnchorPoint = Vector2.new(1, 0.5)
Exit.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Exit.BackgroundTransparency = 0.500
Exit.BorderSizePixel = 0
Exit.Position = UDim2.new(1, -4, 0.5, 0)
Exit.Size = UDim2.new(0, 32, 1, -8)
Exit.Font = Enum.Font.GothamMedium
Exit.Text = "X"
Exit.TextColor3 = Color3.fromRGB(241, 241, 241)
Exit.TextScaled = true
Exit.TextSize = 13.000
Exit.TextWrapped = true

UICorners_5.Name = "UICorners"
UICorners_5.Parent = Exit

Minimize.Name = "Minimize"
Minimize.Parent = Topbar
Minimize.AnchorPoint = Vector2.new(1, 0.5)
Minimize.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Minimize.BackgroundTransparency = 0.500
Minimize.BorderSizePixel = 0
Minimize.Position = UDim2.new(1, -40, 0.5, 0)
Minimize.Size = UDim2.new(0, 28, 1, -8)
Minimize.Font = Enum.Font.GothamMedium
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(241, 241, 241)
Minimize.TextScaled = true
Minimize.TextSize = 13.000
Minimize.TextWrapped = true

UICorners_6.Name = "UICorners"
UICorners_6.Parent = Minimize

Title.Name = "Title"
Title.Parent = Topbar
Title.AnchorPoint = Vector2.new(0.5, 0.5)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.5, 0, 0.5, 0)
Title.Size = UDim2.new(0.5, 0, 1, -8)
Title.Font = Enum.Font.GothamMedium
Title.Text = "Commands"
Title.TextColor3 = Color3.fromRGB(241, 241, 241)
Title.TextScaled = true
Title.TextSize = 17.000
Title.TextWrapped = true

UICorners_7.Name = "UICorners"
UICorners_7.Parent = Commands

UIGradients_5.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients_5.Name = "UIGradients"
UIGradients_5.Parent = Commands

Resizeable.Name = "Resizeable"
Resizeable.Parent = AdminUI
Resizeable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Resizeable.BackgroundTransparency = 1.000
Resizeable.Size = UDim2.new(1, 0, 1, 0)

Left.Name = "Left"
Left.Parent = Resizeable
Left.AnchorPoint = Vector2.new(1, 0.5)
Left.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Left.BackgroundTransparency = 1.000
Left.BorderSizePixel = 0
Left.Position = UDim2.new(0, 0, 0.5, 0)
Left.Size = UDim2.new(0, 8, 1, -8)

Right.Name = "Right"
Right.Parent = Resizeable
Right.AnchorPoint = Vector2.new(0, 0.5)
Right.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Right.BackgroundTransparency = 1.000
Right.BorderSizePixel = 0
Right.Position = UDim2.new(1, 0, 0.5, 0)
Right.Size = UDim2.new(0, 8, 1, -8)

Top.Name = "Top"
Top.Parent = Resizeable
Top.AnchorPoint = Vector2.new(0.5, 1)
Top.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Top.BackgroundTransparency = 1.000
Top.BorderSizePixel = 0
Top.Position = UDim2.new(0.5, 0, 0, 0)
Top.Size = UDim2.new(1, -8, 0, 8)

Bottom.Name = "Bottom"
Bottom.Parent = Resizeable
Bottom.AnchorPoint = Vector2.new(0.5, 0)
Bottom.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
Bottom.BackgroundTransparency = 1.000
Bottom.BorderSizePixel = 0
Bottom.Position = UDim2.new(0.5, 0, 1, 0)
Bottom.Size = UDim2.new(1, -8, 0, 8)

TopLeft.Name = "TopLeft"
TopLeft.Parent = Resizeable
TopLeft.AnchorPoint = Vector2.new(1, 1)
TopLeft.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TopLeft.BackgroundTransparency = 1.000
TopLeft.BorderSizePixel = 0
TopLeft.Position = UDim2.new(0, 4, 0, 4)
TopLeft.Size = UDim2.new(0, 12, 0, 12)

TopRight.Name = "TopRight"
TopRight.Parent = Resizeable
TopRight.AnchorPoint = Vector2.new(0, 1)
TopRight.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
TopRight.BackgroundTransparency = 1.000
TopRight.BorderSizePixel = 0
TopRight.Position = UDim2.new(1, -4, 0, 4)
TopRight.Size = UDim2.new(0, 12, 0, 12)

BottomLeft.Name = "BottomLeft"
BottomLeft.Parent = Resizeable
BottomLeft.AnchorPoint = Vector2.new(1, 0)
BottomLeft.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
BottomLeft.BackgroundTransparency = 1.000
BottomLeft.BorderSizePixel = 0
BottomLeft.Position = UDim2.new(0, 4, 1, -4)
BottomLeft.Size = UDim2.new(0, 12, 0, 12)

BottomRight.Name = "BottomRight"
BottomRight.Parent = Resizeable
BottomRight.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
BottomRight.BackgroundTransparency = 1.000
BottomRight.BorderSizePixel = 0
BottomRight.Position = UDim2.new(1, -4, 1, -4)
BottomRight.Size = UDim2.new(0, 12, 0, 12)

Description.Name = "Description"
Description.Parent = AdminUI
Description.AnchorPoint = Vector2.new(0, 1)
Description.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Description.BackgroundTransparency = 0.300
Description.BorderColor3 = Color3.fromRGB(53, 53, 53)
Description.Size = UDim2.new(0, 191, 0, 26)
Description.Visible = false
Description.Font = Enum.Font.GothamMedium
Description.Text = "Name"
Description.TextColor3 = Color3.fromRGB(241, 241, 241)
Description.TextScaled = true
Description.TextSize = 13.000
Description.TextWrapped = true

UICorner_3.Parent = Description

UpdLog.Name = "UpdLog"
UpdLog.Parent = AdminUI
UpdLog.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
UpdLog.BackgroundTransparency = 0.140
UpdLog.BorderColor3 = Color3.fromRGB(139, 139, 139)
UpdLog.BorderSizePixel = 0
UpdLog.Position = UDim2.new(0.618707478, 0, 0.0371845067, 0)
UpdLog.Size = UDim2.new(0, 283, 0, 286)

Container_2.Name = "Container"
Container_2.Parent = UpdLog
Container_2.AnchorPoint = Vector2.new(0.5, 1)
Container_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Container_2.BackgroundTransparency = 0.500
Container_2.BorderColor3 = Color3.fromRGB(255, 255, 255)
Container_2.BorderSizePixel = 0
Container_2.ClipsDescendants = true
Container_2.Position = UDim2.new(0.5, 0, 1, -5)
Container_2.Size = UDim2.new(1, -10, 1.01153851, -30)

List_2.Name = "List"
List_2.Parent = Container_2
List_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
List_2.BackgroundTransparency = 1.000
List_2.BorderColor3 = Color3.fromRGB(16, 16, 16)
List_2.BorderSizePixel = 0
List_2.Position = UDim2.new(0, 6, 0, 6)
List_2.Size = UDim2.new(1, -10, 1.0801245, -27)
List_2.BottomImage = "rbxgameasset://Images/scrollBottom (1)"
List_2.MidImage = "rbxgameasset://Images/scrollMid"
List_2.ScrollBarThickness = 4
List_2.TopImage = "rbxgameasset://Images/scrollTop"

UIListLayout_3.Parent = List_2
UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_3.Padding = UDim.new(0, 2)

TextLabel_2.Name = ""
TextLabel_2.Parent = List_2
TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.BackgroundTransparency = 1.000
TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_2.BorderSizePixel = 0
TextLabel_2.Size = UDim2.new(1, 0, 0, 35)
TextLabel_2.Font = Enum.Font.GothamMedium
TextLabel_2.Text = "- log 1 thingy"
TextLabel_2.TextColor3 = Color3.fromRGB(241, 241, 241)
TextLabel_2.TextScaled = true
TextLabel_2.TextSize = 14.000
TextLabel_2.TextWrapped = true

UICorner_4.CornerRadius = UDim.new(0, 9)
UICorner_4.Parent = Container_2

UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_2.Parent = Container_2

Topbar_2.Name = "Topbar"
Topbar_2.Parent = UpdLog
Topbar_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Topbar_2.BackgroundTransparency = 1.000
Topbar_2.Size = UDim2.new(1, 0, 0, 25)

Exit_2.Name = "Exit"
Exit_2.Parent = Topbar_2
Exit_2.AnchorPoint = Vector2.new(1, 0.5)
Exit_2.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Exit_2.BackgroundTransparency = 0.500
Exit_2.BorderSizePixel = 0
Exit_2.Position = UDim2.new(1, -4, 0.5, 0)
Exit_2.Size = UDim2.new(0, 32, 1, -8)
Exit_2.Font = Enum.Font.GothamMedium
Exit_2.Text = "X"
Exit_2.TextColor3 = Color3.fromRGB(241, 241, 241)
Exit_2.TextScaled = true
Exit_2.TextSize = 13.000
Exit_2.TextWrapped = true

UICorners_8.Name = "UICorners"
UICorners_8.Parent = Exit_2

Minimize_2.Name = "Minimize"
Minimize_2.Parent = Topbar_2
Minimize_2.AnchorPoint = Vector2.new(1, 0.5)
Minimize_2.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Minimize_2.BackgroundTransparency = 0.500
Minimize_2.BorderSizePixel = 0
Minimize_2.Position = UDim2.new(1, -40, 0.5, 0)
Minimize_2.Size = UDim2.new(0, 28, 1, -8)
Minimize_2.Font = Enum.Font.GothamMedium
Minimize_2.Text = "-"
Minimize_2.TextColor3 = Color3.fromRGB(241, 241, 241)
Minimize_2.TextScaled = true
Minimize_2.TextSize = 13.000
Minimize_2.TextWrapped = true

UICorners_9.Name = "UICorners"
UICorners_9.Parent = Minimize_2

Title_2.Name = "Title"
Title_2.Parent = Topbar_2
Title_2.AnchorPoint = Vector2.new(0.5, 0.5)
Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_2.BackgroundTransparency = 1.000
Title_2.BorderSizePixel = 0
Title_2.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_2.Size = UDim2.new(0.5, 0, 1, -8)
Title_2.Font = Enum.Font.GothamMedium
Title_2.Text = "Update Log"
Title_2.TextColor3 = Color3.fromRGB(241, 241, 241)
Title_2.TextScaled = true
Title_2.TextSize = 17.000
Title_2.TextWrapped = true

UICorners_10.Name = "UICorners"
UICorners_10.Parent = UpdLog

UIGradients_6.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients_6.Name = "UIGradients"
UIGradients_6.Parent = UpdLog

ChatLogs.Name = "ChatLogs"
ChatLogs.Parent = AdminUI
ChatLogs.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
ChatLogs.BackgroundTransparency = 0.140
ChatLogs.BorderColor3 = Color3.fromRGB(139, 139, 139)
ChatLogs.BorderSizePixel = 0
ChatLogs.Position = UDim2.new(0.651177526, 0, 0.561142266, 0)
ChatLogs.Size = UDim2.new(0, 402, 0, 262)

Container_3.Name = "Container"
Container_3.Parent = ChatLogs
Container_3.AnchorPoint = Vector2.new(0.5, 1)
Container_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Container_3.BackgroundTransparency = 0.500
Container_3.BorderColor3 = Color3.fromRGB(255, 255, 255)
Container_3.BorderSizePixel = 0
Container_3.ClipsDescendants = true
Container_3.Position = UDim2.new(0.49502489, 0, 1.0037874, -5)
Container_3.Size = UDim2.new(1, -10, 1.00769234, -30)

Logs.Name = "Logs"
Logs.Parent = Container_3
Logs.AnchorPoint = Vector2.new(0.5, 0.5)
Logs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Logs.BackgroundTransparency = 1.000
Logs.BorderColor3 = Color3.fromRGB(16, 16, 16)
Logs.BorderSizePixel = 0
Logs.Position = UDim2.new(0.5, 0, 0.5, 0)
Logs.Size = UDim2.new(1, -10, 1, -10)
Logs.BottomImage = "rbxgameasset://Images/scrollBottom (1)"
Logs.MidImage = "rbxgameasset://Images/scrollMid"
Logs.ScrollBarThickness = 4
Logs.TopImage = "rbxgameasset://Images/scrollTop"

UIListLayout_4.Parent = Logs
UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_4.Padding = UDim.new(0, 3)

TextLabel_3.Parent = Logs
TextLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_3.BackgroundTransparency = 1.000
TextLabel_3.Size = UDim2.new(1, 0, 0, 25)
TextLabel_3.Font = Enum.Font.GothamMedium
TextLabel_3.Text = "[Roblox]: Hello,World!"
TextLabel_3.TextColor3 = Color3.fromRGB(241, 241, 241)
TextLabel_3.TextScaled = true
TextLabel_3.TextSize = 14.000
TextLabel_3.TextWrapped = true

UICorner_5.CornerRadius = UDim.new(0, 9)
UICorner_5.Parent = Container_3

UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_3.Parent = Container_3

Topbar_3.Name = "Topbar"
Topbar_3.Parent = ChatLogs
Topbar_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Topbar_3.BackgroundTransparency = 1.000
Topbar_3.Size = UDim2.new(1, 0, 0, 25)

Exit_3.Name = "Exit"
Exit_3.Parent = Topbar_3
Exit_3.AnchorPoint = Vector2.new(1, 0.5)
Exit_3.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Exit_3.BackgroundTransparency = 0.500
Exit_3.BorderSizePixel = 0
Exit_3.Position = UDim2.new(1, -4, 0.5, 0)
Exit_3.Size = UDim2.new(0, 32, 1, -8)
Exit_3.Font = Enum.Font.GothamMedium
Exit_3.Text = "X"
Exit_3.TextColor3 = Color3.fromRGB(241, 241, 241)
Exit_3.TextScaled = true
Exit_3.TextSize = 13.000
Exit_3.TextWrapped = true

UICorners_11.Name = "UICorners"
UICorners_11.Parent = Exit_3

Minimize_3.Name = "Minimize"
Minimize_3.Parent = Topbar_3
Minimize_3.AnchorPoint = Vector2.new(1, 0.5)
Minimize_3.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Minimize_3.BackgroundTransparency = 0.500
Minimize_3.BorderSizePixel = 0
Minimize_3.Position = UDim2.new(1, -40, 0.5, 0)
Minimize_3.Size = UDim2.new(0, 28, 1, -8)
Minimize_3.Font = Enum.Font.GothamMedium
Minimize_3.Text = "-"
Minimize_3.TextColor3 = Color3.fromRGB(241, 241, 241)
Minimize_3.TextScaled = true
Minimize_3.TextSize = 18.000
Minimize_3.TextWrapped = true

UICorners_12.Name = "UICorners"
UICorners_12.Parent = Minimize_3

Clear.Name = "Clear"
Clear.Parent = Topbar_3
Clear.AnchorPoint = Vector2.new(0, 0.5)
Clear.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Clear.BackgroundTransparency = 0.500
Clear.BorderSizePixel = 0
Clear.Position = UDim2.new(0, 4, 0.5, 0)
Clear.Size = UDim2.new(0, 48, 1, -8)
Clear.Font = Enum.Font.GothamMedium
Clear.Text = "Clear"
Clear.TextColor3 = Color3.fromRGB(241, 241, 241)
Clear.TextScaled = true
Clear.TextSize = 13.000
Clear.TextWrapped = true

UICorners_13.Name = "UICorners"
UICorners_13.Parent = Clear

Title_3.Name = "Title"
Title_3.Parent = Topbar_3
Title_3.AnchorPoint = Vector2.new(0.5, 0.5)
Title_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_3.BackgroundTransparency = 1.000
Title_3.BorderSizePixel = 0
Title_3.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_3.Size = UDim2.new(0.5, 0, 1, -8)
Title_3.Font = Enum.Font.GothamMedium
Title_3.Text = "Chat Logs"
Title_3.TextColor3 = Color3.fromRGB(241, 241, 241)
Title_3.TextScaled = true
Title_3.TextSize = 17.000
Title_3.TextWrapped = true

UICorners_14.Name = "UICorners"
UICorners_14.Parent = ChatLogs

UIGradients_7.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients_7.Name = "UIGradients"
UIGradients_7.Parent = ChatLogs

soRealConsole.Name = "soRealConsole"
soRealConsole.Parent = AdminUI
soRealConsole.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
soRealConsole.BackgroundTransparency = 0.140
soRealConsole.BorderColor3 = Color3.fromRGB(139, 139, 139)
soRealConsole.BorderSizePixel = 0
soRealConsole.Position = UDim2.new(0.317844182, 0, 0.550792933, 0)
soRealConsole.Size = UDim2.new(0, 402, 0, 262)

Container_4.Name = "Container"
Container_4.Parent = soRealConsole
Container_4.AnchorPoint = Vector2.new(0.5, 1)
Container_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Container_4.BackgroundTransparency = 0.500
Container_4.BorderColor3 = Color3.fromRGB(255, 255, 255)
Container_4.BorderSizePixel = 0
Container_4.ClipsDescendants = true
Container_4.Position = UDim2.new(0.49502489, 0, 1.0037874, -5)
Container_4.Size = UDim2.new(1, -10, 1.00769234, -30)

Logs_2.Name = "Logs"
Logs_2.Parent = Container_4
Logs_2.AnchorPoint = Vector2.new(0.5, 0.5)
Logs_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Logs_2.BackgroundTransparency = 1.000
Logs_2.BorderColor3 = Color3.fromRGB(16, 16, 16)
Logs_2.BorderSizePixel = 0
Logs_2.Position = UDim2.new(0.5, 0, 0.620000005, 0)
Logs_2.Size = UDim2.new(1, -10, 0.899999976, -35)
Logs_2.BottomImage = "rbxgameasset://Images/scrollBottom (1)"
Logs_2.MidImage = "rbxgameasset://Images/scrollMid"
Logs_2.ScrollBarThickness = 4
Logs_2.TopImage = "rbxgameasset://Images/scrollTop"

UIListLayout_5.Parent = Logs_2
UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_5.Padding = UDim.new(0, 3)

TextLabel_4.Parent = Logs_2
TextLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_4.BackgroundTransparency = 1.000
TextLabel_4.Size = UDim2.new(1, 0, 0, 25)
TextLabel_4.Font = Enum.Font.GothamMedium
TextLabel_4.Text = "[Output]: failed print 1"
TextLabel_4.TextColor3 = Color3.fromRGB(241, 241, 241)
TextLabel_4.TextScaled = true
TextLabel_4.TextSize = 14.000
TextLabel_4.TextWrapped = true

UICorner_6.CornerRadius = UDim.new(0, 9)
UICorner_6.Parent = Container_4

UIGradient_4.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_4.Parent = Container_4

Filter_2.Name = "Filter"
Filter_2.Parent = Container_4
Filter_2.AnchorPoint = Vector2.new(0.5, 0)
Filter_2.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
Filter_2.BackgroundTransparency = 0.700
Filter_2.BorderSizePixel = 0
Filter_2.Position = UDim2.new(0.5, 0, 0, 5)
Filter_2.Size = UDim2.new(1, -10, 0, 20)
Filter_2.Font = Enum.Font.GothamMedium
Filter_2.PlaceholderColor3 = Color3.fromRGB(124, 124, 124)
Filter_2.PlaceholderText = "Search..."
Filter_2.Text = ""
Filter_2.TextColor3 = Color3.fromRGB(241, 241, 241)
Filter_2.TextSize = 18.000

UICorner_7.CornerRadius = UDim.new(0, 9)
UICorner_7.Parent = Filter_2

Topbar_4.Name = "Topbar"
Topbar_4.Parent = soRealConsole
Topbar_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Topbar_4.BackgroundTransparency = 1.000
Topbar_4.Size = UDim2.new(1, 0, 0, 25)

Exit_4.Name = "Exit"
Exit_4.Parent = Topbar_4
Exit_4.AnchorPoint = Vector2.new(1, 0.5)
Exit_4.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Exit_4.BackgroundTransparency = 0.500
Exit_4.BorderSizePixel = 0
Exit_4.Position = UDim2.new(1, -4, 0.5, 0)
Exit_4.Size = UDim2.new(0, 32, 1, -8)
Exit_4.Font = Enum.Font.GothamMedium
Exit_4.Text = "X"
Exit_4.TextColor3 = Color3.fromRGB(241, 241, 241)
Exit_4.TextScaled = true
Exit_4.TextSize = 13.000
Exit_4.TextWrapped = true

UICorners_15.Name = "UICorners"
UICorners_15.Parent = Exit_4

Minimize_4.Name = "Minimize"
Minimize_4.Parent = Topbar_4
Minimize_4.AnchorPoint = Vector2.new(1, 0.5)
Minimize_4.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Minimize_4.BackgroundTransparency = 0.500
Minimize_4.BorderSizePixel = 0
Minimize_4.Position = UDim2.new(1, -40, 0.5, 0)
Minimize_4.Size = UDim2.new(0, 28, 1, -8)
Minimize_4.Font = Enum.Font.GothamMedium
Minimize_4.Text = "-"
Minimize_4.TextColor3 = Color3.fromRGB(241, 241, 241)
Minimize_4.TextScaled = true
Minimize_4.TextSize = 18.000
Minimize_4.TextWrapped = true

UICorners_16.Name = "UICorners"
UICorners_16.Parent = Minimize_4

Clear_2.Name = "Clear"
Clear_2.Parent = Topbar_4
Clear_2.AnchorPoint = Vector2.new(0, 0.5)
Clear_2.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Clear_2.BackgroundTransparency = 0.500
Clear_2.BorderSizePixel = 0
Clear_2.Position = UDim2.new(0, 4, 0.5, 0)
Clear_2.Size = UDim2.new(0, 48, 1, -8)
Clear_2.Font = Enum.Font.GothamMedium
Clear_2.Text = "Clear"
Clear_2.TextColor3 = Color3.fromRGB(241, 241, 241)
Clear_2.TextScaled = true
Clear_2.TextSize = 13.000
Clear_2.TextWrapped = true

UICorners_17.Name = "UICorners"
UICorners_17.Parent = Clear_2

Title_4.Name = "Title"
Title_4.Parent = Topbar_4
Title_4.AnchorPoint = Vector2.new(0.5, 0.5)
Title_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_4.BackgroundTransparency = 1.000
Title_4.BorderSizePixel = 0
Title_4.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_4.Size = UDim2.new(0.5, 0, 1, -8)
Title_4.Font = Enum.Font.GothamMedium
Title_4.Text = "NA Console"
Title_4.TextColor3 = Color3.fromRGB(241, 241, 241)
Title_4.TextScaled = true
Title_4.TextSize = 17.000
Title_4.TextWrapped = true

UICorners_18.Name = "UICorners"
UICorners_18.Parent = soRealConsole

UIGradients_8.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 46)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 22))}
UIGradients_8.Name = "UIGradients"
UIGradients_8.Parent = soRealConsole

Modal.Name = "Modal"
Modal.Parent = AdminUI
Modal.BackgroundTransparency = 1.000

return AdminUI