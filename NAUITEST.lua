local AdminUI = Instance.new("ScreenGui")
local AdminScale = Instance.new("UIScale")
local CmdBar = Instance.new("Frame")
local CenterBar = Instance.new("Frame")
local Horizontal = Instance.new("Frame")
local UIGradient = Instance.new("UIGradient")
local UICorner = Instance.new("UICorner")
local Input = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local LeftFill = Instance.new("Frame")
local Frame = Instance.new("Frame")
local UIGradient_2 = Instance.new("UIGradient")
local UICorner_3 = Instance.new("UICorner")
local Horizontal_2 = Instance.new("Frame")
local UIGradient_3 = Instance.new("UIGradient")
local UICorner_4 = Instance.new("UICorner")
local Edge = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local Edge_2 = Instance.new("ImageLabel")
local RightFill = Instance.new("Frame")
local Frame_2 = Instance.new("Frame")
local UIGradient_4 = Instance.new("UIGradient")
local UICorner_5 = Instance.new("UICorner")
local Horizontal_3 = Instance.new("Frame")
local UIGradient_5 = Instance.new("UIGradient")
local UICorner_6 = Instance.new("UICorner")
local Edge_3 = Instance.new("Frame")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local Edge_4 = Instance.new("ImageLabel")
local Autofill = Instance.new("Frame")
local UICorner_7 = Instance.new("UICorner")
local UIGradient_6 = Instance.new("UIGradient")
local Cmd = Instance.new("Frame")
local UICorner_8 = Instance.new("UICorner")
local Input_2 = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")
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
local UICorner_9 = Instance.new("UICorner")
local Modal = Instance.new("ImageButton")
local ChatLogs = Instance.new("Frame")
local UICorner_10 = Instance.new("UICorner")
local Topbar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Minimize = Instance.new("TextButton")
local UICorner_11 = Instance.new("UICorner")
local Exit = Instance.new("TextButton")
local UICorner_12 = Instance.new("UICorner")
local Clear = Instance.new("TextButton")
local UICorner_13 = Instance.new("UICorner")
local Container = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local Logs = Instance.new("ScrollingFrame")
local UIListLayout_3 = Instance.new("UIListLayout")
local TextLabel = Instance.new("TextLabel")
local UICorner_14 = Instance.new("UICorner")
local UIGradient_7 = Instance.new("UIGradient")
local UICorner_15 = Instance.new("UICorner")
local UIGradient_8 = Instance.new("UIGradient")
local Commands = Instance.new("Frame")
local UICorner_16 = Instance.new("UICorner")
local Topbar_2 = Instance.new("Frame")
local Title_2 = Instance.new("TextLabel")
local Minimize_2 = Instance.new("TextButton")
local UICorner_17 = Instance.new("UICorner")
local Exit_2 = Instance.new("TextButton")
local UICorner_18 = Instance.new("UICorner")
local Clear_2 = Instance.new("TextButton")
local UICorner_19 = Instance.new("UICorner")
local Container_2 = Instance.new("Frame")
local UIListLayout_4 = Instance.new("UIListLayout")
local List = Instance.new("ScrollingFrame")
local UIListLayout_5 = Instance.new("UIListLayout")
local TextLabel_2 = Instance.new("TextLabel")
local Filter = Instance.new("TextBox")
local UICorner_20 = Instance.new("UICorner")
local UICorner_21 = Instance.new("UICorner")
local UIGradient_9 = Instance.new("UIGradient")
local UICorner_22 = Instance.new("UICorner")
local UIGradient_10 = Instance.new("UIGradient")
local UpdLog = Instance.new("Frame")
local UICorner_23 = Instance.new("UICorner")
local Topbar_3 = Instance.new("Frame")
local Title_3 = Instance.new("TextLabel")
local Minimize_3 = Instance.new("TextButton")
local UICorner_24 = Instance.new("UICorner")
local Exit_3 = Instance.new("TextButton")
local UICorner_25 = Instance.new("UICorner")
local Clear_3 = Instance.new("TextButton")
local UICorner_26 = Instance.new("UICorner")
local Container_3 = Instance.new("Frame")
local UIListLayout_6 = Instance.new("UIListLayout")
local List_2 = Instance.new("ScrollingFrame")
local UIListLayout_7 = Instance.new("UIListLayout")
local TextLabel_3 = Instance.new("TextLabel")
local UICorner_27 = Instance.new("UICorner")
local UIGradient_11 = Instance.new("UIGradient")
local UICorner_28 = Instance.new("UICorner")
local UIGradient_12 = Instance.new("UIGradient")
local soRealConsole = Instance.new("Frame")
local UICorner_29 = Instance.new("UICorner")
local Topbar_4 = Instance.new("Frame")
local Title_4 = Instance.new("TextLabel")
local Minimize_4 = Instance.new("TextButton")
local UICorner_30 = Instance.new("UICorner")
local Exit_4 = Instance.new("TextButton")
local UICorner_31 = Instance.new("UICorner")
local Clear_4 = Instance.new("TextButton")
local UICorner_32 = Instance.new("UICorner")
local Container_4 = Instance.new("Frame")
local UIListLayout_8 = Instance.new("UIListLayout")
local Logs_2 = Instance.new("ScrollingFrame")
local UIListLayout_9 = Instance.new("UIListLayout")
local TextLabel_4 = Instance.new("TextLabel")
local UICorner_33 = Instance.new("UICorner")
local UIGradient_13 = Instance.new("UIGradient")
local Filter_2 = Instance.new("TextBox")
local UICorner_34 = Instance.new("UICorner")
local UICorner_35 = Instance.new("UICorner")
local UIGradient_14 = Instance.new("UIGradient")

AdminUI.Name = "AdminUI"
AdminUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AdminUI.ResetOnSpawn = false

AdminScale.Name = "AutoScale"
AdminScale.Parent = AdminUI

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
Horizontal.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
Horizontal.BackgroundTransparency = 0.140
Horizontal.BorderColor3 = Color3.fromRGB(27, 27, 27)
Horizontal.BorderSizePixel = 0
Horizontal.Size = UDim2.new(1, 0, 1, 0)

UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient.Parent = Horizontal

UICorner.CornerRadius = UDim.new(0, 9)
UICorner.Parent = Horizontal

Input.Name = "Input"
Input.Parent = CenterBar
Input.Active = false
Input.AnchorPoint = Vector2.new(0.5, 0.5)
Input.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
Input.BackgroundTransparency = 0.300
Input.ClipsDescendants = true
Input.Position = UDim2.new(0.5, 0, 0.5, 0)
Input.Size = UDim2.new(1, -10, 0.699999988, 0)
Input.ZIndex = 3
Input.Font = Enum.Font.SourceSans
Input.PlaceholderText = "placeholder"
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(225, 225, 225)
Input.TextScaled = true
Input.TextSize = 24.000
Input.TextWrapped = true

UICorner_2.CornerRadius = UDim.new(0, 6)
UICorner_2.Parent = Input

LeftFill.Name = "LeftFill"
LeftFill.Parent = CmdBar
LeftFill.AnchorPoint = Vector2.new(0, 0.5)
LeftFill.BackgroundTransparency = 1.000
LeftFill.Position = UDim2.new(0, 0, 0.5, 0)
LeftFill.Size = UDim2.new(0.5, -125, 1, 0)

Frame.Parent = LeftFill
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.BackgroundTransparency = 0.140
Frame.Size = UDim2.new(1, 0, 1, 0)

UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(4, 4, 4))}
UIGradient_2.Parent = Frame

UICorner_3.CornerRadius = UDim.new(0, 9)
UICorner_3.Parent = Frame

Horizontal_2.Name = "Horizontal"
Horizontal_2.Parent = LeftFill
Horizontal_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Horizontal_2.BackgroundTransparency = 0.140
Horizontal_2.BorderColor3 = Color3.fromRGB(27, 27, 27)
Horizontal_2.BorderSizePixel = 0
Horizontal_2.Size = UDim2.new(1.005988, 0, 1, 0)

UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.05, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.49, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(4, 4, 4))}
UIGradient_3.Parent = Horizontal_2

UICorner_4.Parent = Horizontal_2

Edge.Name = "Edge"
Edge.Parent = LeftFill
Edge.AnchorPoint = Vector2.new(0, 0.5)
Edge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Edge.BackgroundTransparency = 1.000
Edge.BorderSizePixel = 0
Edge.ClipsDescendants = true
Edge.Position = UDim2.new(1, 0, 0.5, 0)
Edge.Size = UDim2.new(0.185000002, 0, 1, 0)

UIAspectRatioConstraint.Parent = Edge

Edge_2.Name = "Edge"
Edge_2.Parent = Edge
Edge_2.AnchorPoint = Vector2.new(0.5, 0.5)
Edge_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Edge_2.BackgroundTransparency = 1.000
Edge_2.BorderSizePixel = 0
Edge_2.Position = UDim2.new(0, 0, 0.5, 0)
Edge_2.Size = UDim2.new(1, 12, 1, 0)
Edge_2.Image = "rbxassetid://483281072"
Edge_2.ImageColor3 = Color3.fromRGB(4, 4, 4)
Edge_2.ImageTransparency = 0.140

RightFill.Name = "RightFill"
RightFill.Parent = CmdBar
RightFill.AnchorPoint = Vector2.new(1, 0.5)
RightFill.BackgroundTransparency = 1.000
RightFill.Position = UDim2.new(1, 0, 0.5, 0)
RightFill.Size = UDim2.new(0.5, -125, 1, 0)

Frame_2.Parent = RightFill
Frame_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame_2.BackgroundTransparency = 0.140
Frame_2.Size = UDim2.new(1, 0, 1, 0)

UIGradient_4.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_4.Parent = Frame_2

UICorner_5.CornerRadius = UDim.new(0, 9)
UICorner_5.Parent = Frame_2

Horizontal_3.Name = "Horizontal"
Horizontal_3.Parent = RightFill
Horizontal_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Horizontal_3.BackgroundTransparency = 0.140
Horizontal_3.BorderColor3 = Color3.fromRGB(27, 27, 27)
Horizontal_3.BorderSizePixel = 0
Horizontal_3.Position = UDim2.new(-0.00798403192, 0, 0, 0)
Horizontal_3.Size = UDim2.new(1.00798404, 0, 1, 0)

UIGradient_5.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.49, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_5.Parent = Horizontal_3

UICorner_6.Parent = Horizontal_3

Edge_3.Name = "Edge"
Edge_3.Parent = RightFill
Edge_3.AnchorPoint = Vector2.new(1, 0.5)
Edge_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Edge_3.BackgroundTransparency = 1.000
Edge_3.BorderSizePixel = 0
Edge_3.ClipsDescendants = true
Edge_3.Position = UDim2.new(0, 0, 0.5, 0)
Edge_3.Size = UDim2.new(0.185000002, 0, 1, 0)

UIAspectRatioConstraint_2.Parent = Edge_3

Edge_4.Name = "Edge"
Edge_4.Parent = Edge_3
Edge_4.AnchorPoint = Vector2.new(0.5, 0.5)
Edge_4.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Edge_4.BackgroundTransparency = 1.000
Edge_4.BorderSizePixel = 0
Edge_4.Position = UDim2.new(1, 0, 0.5, 0)
Edge_4.Size = UDim2.new(1, 12, 1, 0)
Edge_4.Image = "rbxassetid://483281072"
Edge_4.ImageColor3 = Color3.fromRGB(4, 4, 4)
Edge_4.ImageTransparency = 0.140

Autofill.Name = "Autofill"
Autofill.Parent = CmdBar
Autofill.AnchorPoint = Vector2.new(0.5, 1)
Autofill.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Autofill.BackgroundTransparency = 1.000
Autofill.BorderSizePixel = 0
Autofill.ClipsDescendants = false
Autofill.Position = UDim2.new(0.5, 0, 0, -10)
Autofill.Size = UDim2.new(0, 400, 0, 150)
Autofill.ZIndex = 4

UICorner_7.CornerRadius = UDim.new(0, 9)
UICorner_7.Parent = Autofill

UIGradient_6.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(4, 4, 4))}
UIGradient_6.Rotation = 90
UIGradient_6.Parent = Autofill

Cmd.Name = "Cmd"
Cmd.Parent = Autofill
Cmd.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Cmd.BackgroundTransparency = 0.100
Cmd.BorderSizePixel = 0
Cmd.ClipsDescendants = true
Cmd.Size = UDim2.new(0.899999976, 0, 0, 30)

UICorner_8.CornerRadius = UDim.new(0, 6)
UICorner_8.Parent = Cmd

Input_2.Name = "Input"
Input_2.Parent = Cmd
Input_2.BackgroundTransparency = 1.000
Input_2.Position = UDim2.new(0, 5, 0, 0)
Input_2.Size = UDim2.new(1, -10, 1, 0)
Input_2.Font = Enum.Font.SourceSans
Input_2.Text = "example <player> <text>"
Input_2.TextColor3 = Color3.fromRGB(240, 240, 240)
Input_2.TextScaled = true
Input_2.TextSize = 24.000
Input_2.TextWrapped = true

UIListLayout.Parent = Autofill
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout.Padding = UDim.new(0, 3)

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
Description.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
Description.BackgroundTransparency = 0.300
Description.BorderColor3 = Color3.fromRGB(53, 53, 53)
Description.Size = UDim2.new(0, 191, 0, 26)
Description.Visible = false
Description.Font = Enum.Font.SourceSansItalic
Description.Text = "Name"
Description.TextColor3 = Color3.fromRGB(255, 255, 255)
Description.TextSize = 13.000
Description.TextWrapped = true
Description.ZIndex = 99

UICorner_9.Parent = Description

Modal.Name = "Modal"
Modal.Parent = AdminUI
Modal.BackgroundTransparency = 1.000

ChatLogs.Name = "ChatLogs"
ChatLogs.Parent = AdminUI
ChatLogs.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
ChatLogs.BackgroundTransparency = 0.400
ChatLogs.BorderSizePixel = 0
ChatLogs.ClipsDescendants = false
ChatLogs.Position = UDim2.new(0.654038072, 0, 0.596248388, 0)
ChatLogs.Size = UDim2.new(0, 400, 0, 300)

UICorner_10.Parent = ChatLogs

Topbar.Name = "Topbar"
Topbar.Parent = ChatLogs
Topbar.BackgroundTransparency = 1.000
Topbar.BorderSizePixel = 0
Topbar.Size = UDim2.new(1, 0, 0, 30)
Topbar.ZIndex = 10

Title.Name = "Title"
Title.Parent = Topbar
Title.BackgroundTransparency = 1.000
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Chat Logs"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextScaled = true
Title.TextSize = 20.000
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Left

Minimize.Name = "Minimize"
Minimize.Parent = Topbar
Minimize.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Minimize.BackgroundTransparency = 0.300
Minimize.Position = UDim2.new(1, -70, 0, 0)
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Font = Enum.Font.GothamBold
Minimize.Text = "-"
Minimize.TextColor3 = Color3.fromRGB(10, 10, 10)
Minimize.TextSize = 18.000

UICorner_11.CornerRadius = UDim.new(0, 6)
UICorner_11.Parent = Minimize

Exit.Name = "Exit"
Exit.Parent = Topbar
Exit.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Exit.BackgroundTransparency = 0.300
Exit.Position = UDim2.new(1, -35, 0, 0)
Exit.Size = UDim2.new(0, 30, 0, 30)
Exit.Font = Enum.Font.GothamBold
Exit.Text = "X"
Exit.TextColor3 = Color3.fromRGB(10, 10, 10)
Exit.TextSize = 18.000

UICorner_12.CornerRadius = UDim.new(0, 6)
UICorner_12.Parent = Exit

Clear.Name = "Clear"
Clear.Parent = Topbar
Clear.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Clear.BackgroundTransparency = 0.300
Clear.Position = UDim2.new(1, -105, 0, 0)
Clear.Size = UDim2.new(0, 30, 0, 30)
Clear.Visible = false
Clear.Font = Enum.Font.GothamBold
Clear.Text = "C"
Clear.TextColor3 = Color3.fromRGB(10, 10, 10)
Clear.TextSize = 18.000

UICorner_13.CornerRadius = UDim.new(0, 6)
UICorner_13.Parent = Clear

Container.Name = "Container"
Container.Parent = ChatLogs
Container.BackgroundTransparency = 1.000
Container.Position = UDim2.new(0, 10, 0, 35)
Container.Size = UDim2.new(1, -20, 1, -40)

UIListLayout_2.Parent = Container
UIListLayout_2.Padding = UDim.new(0, 5)

Logs.Name = "Logs"
Logs.Parent = Container
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

UIListLayout_3.Parent = Logs
UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_3.Padding = UDim.new(0, 3)

TextLabel.Parent = Logs
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.Size = UDim2.new(1, 0, 0, 25)
TextLabel.Font = Enum.Font.Arial
TextLabel.Text = "[Roblox]: Hello,World!"
TextLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextStrokeTransparency = 0.800
TextLabel.TextWrapped = true

UICorner_14.CornerRadius = UDim.new(0, 9)
UICorner_14.Parent = Container

UIGradient_7.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_7.Parent = Container

UICorner_15.CornerRadius = UDim.new(0, 9)
UICorner_15.Parent = ChatLogs

UIGradient_8.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.38, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.68, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_8.Parent = ChatLogs

Commands.Name = "Commands"
Commands.Parent = AdminUI
Commands.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Commands.BackgroundTransparency = 0.400
Commands.BorderSizePixel = 0
Commands.ClipsDescendants = false
Commands.Position = UDim2.new(0.0477434583, 0, 0.556921065, 0)
Commands.Size = UDim2.new(0, 280, 0, 320)

UICorner_16.Parent = Commands

Topbar_2.Name = "Topbar"
Topbar_2.Parent = Commands
Topbar_2.BackgroundTransparency = 1.000
Topbar_2.BorderSizePixel = 0
Topbar_2.Size = UDim2.new(1, 0, 0, 30)
Topbar_2.ZIndex = 10

Title_2.Name = "Title"
Title_2.Parent = Topbar_2
Title_2.BackgroundTransparency = 1.000
Title_2.Position = UDim2.new(0, 10, 0, 0)
Title_2.Size = UDim2.new(1, -100, 1, 0)
Title_2.Font = Enum.Font.GothamBold
Title_2.Text = "Commands"
Title_2.TextColor3 = Color3.fromRGB(0, 255, 255)
Title_2.TextScaled = true
Title_2.TextSize = 20.000
Title_2.TextWrapped = true
Title_2.TextXAlignment = Enum.TextXAlignment.Left

Minimize_2.Name = "Minimize"
Minimize_2.Parent = Topbar_2
Minimize_2.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Minimize_2.BackgroundTransparency = 0.300
Minimize_2.Position = UDim2.new(1, -70, 0, 0)
Minimize_2.Size = UDim2.new(0, 30, 0, 30)
Minimize_2.Font = Enum.Font.GothamBold
Minimize_2.Text = "-"
Minimize_2.TextColor3 = Color3.fromRGB(10, 10, 10)
Minimize_2.TextSize = 18.000

UICorner_17.CornerRadius = UDim.new(0, 6)
UICorner_17.Parent = Minimize_2

Exit_2.Name = "Exit"
Exit_2.Parent = Topbar_2
Exit_2.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Exit_2.BackgroundTransparency = 0.300
Exit_2.Position = UDim2.new(1, -35, 0, 0)
Exit_2.Size = UDim2.new(0, 30, 0, 30)
Exit_2.Font = Enum.Font.GothamBold
Exit_2.Text = "X"
Exit_2.TextColor3 = Color3.fromRGB(10, 10, 10)
Exit_2.TextSize = 18.000

UICorner_18.CornerRadius = UDim.new(0, 6)
UICorner_18.Parent = Exit_2

Clear_2.Name = "Clear"
Clear_2.Parent = Topbar_2
Clear_2.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Clear_2.BackgroundTransparency = 0.300
Clear_2.Position = UDim2.new(1, -105, 0, 0)
Clear_2.Size = UDim2.new(0, 30, 0, 30)
Clear_2.Visible = false
Clear_2.Font = Enum.Font.GothamBold
Clear_2.Text = "C"
Clear_2.TextColor3 = Color3.fromRGB(10, 10, 10)
Clear_2.TextSize = 18.000

UICorner_19.CornerRadius = UDim.new(0, 6)
UICorner_19.Parent = Clear_2

Container_2.Name = "Container"
Container_2.Parent = Commands
Container_2.BackgroundTransparency = 1.000
Container_2.Position = UDim2.new(0, 10, 0, 35)
Container_2.Size = UDim2.new(1, -20, 1, -40)

UIListLayout_4.Parent = Container_2
UIListLayout_4.Padding = UDim.new(0, 5)

List.Name = "List"
List.Parent = Container_2
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

UIListLayout_5.Parent = List
UIListLayout_5.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_5.Padding = UDim.new(0, 2)

TextLabel_2.Parent = List
TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.BackgroundTransparency = 1.000
TextLabel_2.Position = UDim2.new(0, 0, 0.0173913036, 0)
TextLabel_2.Size = UDim2.new(1, 0, 0, 20)
TextLabel_2.Font = Enum.Font.Arial
TextLabel_2.Text = "example <player> <text>"
TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.TextScaled = true
TextLabel_2.TextSize = 15.000
TextLabel_2.TextStrokeTransparency = 0.800
TextLabel_2.TextWrapped = true

Filter.Name = "Filter"
Filter.Parent = Container_2
Filter.AnchorPoint = Vector2.new(0.5, 0)
Filter.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
Filter.BackgroundTransparency = 0.700
Filter.BorderSizePixel = 0
Filter.Position = UDim2.new(0.5, 0, 0, 5)
Filter.Size = UDim2.new(1, -10, 0, 20)
Filter.Font = Enum.Font.SourceSans
Filter.PlaceholderColor3 = Color3.fromRGB(124, 124, 124)
Filter.PlaceholderText = "Filter commands..."
Filter.Text = ""
Filter.TextColor3 = Color3.fromRGB(229, 229, 229)
Filter.TextSize = 18.000

UICorner_20.CornerRadius = UDim.new(0, 9)
UICorner_20.Parent = Filter

UICorner_21.CornerRadius = UDim.new(0, 9)
UICorner_21.Parent = Container_2

UIGradient_9.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_9.Parent = Container_2

UICorner_22.CornerRadius = UDim.new(0, 9)
UICorner_22.Parent = Commands

UIGradient_10.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.53, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_10.Parent = Commands

UpdLog.Name = "UpdLog"
UpdLog.Parent = AdminUI
UpdLog.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
UpdLog.BackgroundTransparency = 0.400
UpdLog.BorderSizePixel = 0
UpdLog.ClipsDescendants = false
UpdLog.Position = UDim2.new(0.68653208, 0, 0.0209573247, 0)
UpdLog.Size = UDim2.new(0, 280, 0, 320)

UICorner_23.Parent = UpdLog

Topbar_3.Name = "Topbar"
Topbar_3.Parent = UpdLog
Topbar_3.BackgroundTransparency = 1.000
Topbar_3.BorderSizePixel = 0
Topbar_3.Size = UDim2.new(1, 0, 0, 30)
Topbar_3.ZIndex = 10

Title_3.Name = "Title"
Title_3.Parent = Topbar_3
Title_3.BackgroundTransparency = 1.000
Title_3.Position = UDim2.new(0, 10, 0, 0)
Title_3.Size = UDim2.new(1, -100, 1, 0)
Title_3.Font = Enum.Font.GothamBold
Title_3.Text = "Update Log"
Title_3.TextColor3 = Color3.fromRGB(0, 255, 255)
Title_3.TextScaled = true
Title_3.TextSize = 20.000
Title_3.TextWrapped = true
Title_3.TextXAlignment = Enum.TextXAlignment.Left

Minimize_3.Name = "Minimize"
Minimize_3.Parent = Topbar_3
Minimize_3.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Minimize_3.BackgroundTransparency = 0.300
Minimize_3.Position = UDim2.new(1, -70, 0, 0)
Minimize_3.Size = UDim2.new(0, 30, 0, 30)
Minimize_3.Font = Enum.Font.GothamBold
Minimize_3.Text = "-"
Minimize_3.TextColor3 = Color3.fromRGB(10, 10, 10)
Minimize_3.TextSize = 18.000

UICorner_24.CornerRadius = UDim.new(0, 6)
UICorner_24.Parent = Minimize_3

Exit_3.Name = "Exit"
Exit_3.Parent = Topbar_3
Exit_3.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Exit_3.BackgroundTransparency = 0.300
Exit_3.Position = UDim2.new(1, -35, 0, 0)
Exit_3.Size = UDim2.new(0, 30, 0, 30)
Exit_3.Font = Enum.Font.GothamBold
Exit_3.Text = "X"
Exit_3.TextColor3 = Color3.fromRGB(10, 10, 10)
Exit_3.TextSize = 18.000

UICorner_25.CornerRadius = UDim.new(0, 6)
UICorner_25.Parent = Exit_3

Clear_3.Name = "Clear"
Clear_3.Parent = Topbar_3
Clear_3.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Clear_3.BackgroundTransparency = 0.300
Clear_3.Position = UDim2.new(1, -105, 0, 0)
Clear_3.Size = UDim2.new(0, 30, 0, 30)
Clear_3.Visible = false
Clear_3.Font = Enum.Font.GothamBold
Clear_3.Text = "C"
Clear_3.TextColor3 = Color3.fromRGB(10, 10, 10)
Clear_3.TextSize = 18.000

UICorner_26.CornerRadius = UDim.new(0, 6)
UICorner_26.Parent = Clear_3

Container_3.Name = "Container"
Container_3.Parent = UpdLog
Container_3.BackgroundTransparency = 1.000
Container_3.Position = UDim2.new(0, 10, 0, 35)
Container_3.Size = UDim2.new(1, -20, 1, -40)

UIListLayout_6.Parent = Container_3
UIListLayout_6.Padding = UDim.new(0, 5)

List_2.Name = "List"
List_2.Parent = Container_3
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

UIListLayout_7.Parent = List_2
UIListLayout_7.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_7.Padding = UDim.new(0, 2)

TextLabel_3.Name = ""
TextLabel_3.Parent = List_2
TextLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_3.BackgroundTransparency = 1.000
TextLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel_3.BorderSizePixel = 0
TextLabel_3.Size = UDim2.new(1, 0, 0, 35)
TextLabel_3.Font = Enum.Font.SourceSansBold
TextLabel_3.Text = "- log 1 thingy"
TextLabel_3.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_3.TextScaled = true
TextLabel_3.TextSize = 14.000
TextLabel_3.TextWrapped = true

UICorner_27.CornerRadius = UDim.new(0, 9)
UICorner_27.Parent = Container_3

UIGradient_11.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_11.Parent = Container_3

UICorner_28.CornerRadius = UDim.new(0, 9)
UICorner_28.Parent = UpdLog

UIGradient_12.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.53, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_12.Parent = UpdLog

soRealConsole.Name = "soRealConsole"
soRealConsole.Parent = AdminUI
soRealConsole.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
soRealConsole.BackgroundTransparency = 0.400
soRealConsole.BorderSizePixel = 0
soRealConsole.ClipsDescendants = false
soRealConsole.Position = UDim2.new(0.321694374, 0, 0.570633888, 0)
soRealConsole.Size = UDim2.new(0, 400, 0, 300)

UICorner_29.Parent = soRealConsole

Topbar_4.Name = "Topbar"
Topbar_4.Parent = soRealConsole
Topbar_4.BackgroundTransparency = 1.000
Topbar_4.BorderSizePixel = 0
Topbar_4.Size = UDim2.new(1, 0, 0, 30)
Topbar_4.ZIndex = 10

Title_4.Name = "Title"
Title_4.Parent = Topbar_4
Title_4.BackgroundTransparency = 1.000
Title_4.Position = UDim2.new(0, 10, 0, 0)
Title_4.Size = UDim2.new(1, -100, 1, 0)
Title_4.Font = Enum.Font.GothamBold
Title_4.Text = "Console"
Title_4.TextColor3 = Color3.fromRGB(0, 255, 255)
Title_4.TextScaled = true
Title_4.TextSize = 20.000
Title_4.TextWrapped = true
Title_4.TextXAlignment = Enum.TextXAlignment.Left

Minimize_4.Name = "Minimize"
Minimize_4.Parent = Topbar_4
Minimize_4.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Minimize_4.BackgroundTransparency = 0.300
Minimize_4.Position = UDim2.new(1, -70, 0, 0)
Minimize_4.Size = UDim2.new(0, 30, 0, 30)
Minimize_4.Font = Enum.Font.GothamBold
Minimize_4.Text = "-"
Minimize_4.TextColor3 = Color3.fromRGB(10, 10, 10)
Minimize_4.TextSize = 18.000

UICorner_30.CornerRadius = UDim.new(0, 6)
UICorner_30.Parent = Minimize_4

Exit_4.Name = "Exit"
Exit_4.Parent = Topbar_4
Exit_4.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Exit_4.BackgroundTransparency = 0.300
Exit_4.Position = UDim2.new(1, -35, 0, 0)
Exit_4.Size = UDim2.new(0, 30, 0, 30)
Exit_4.Font = Enum.Font.GothamBold
Exit_4.Text = "X"
Exit_4.TextColor3 = Color3.fromRGB(10, 10, 10)
Exit_4.TextSize = 18.000

UICorner_31.CornerRadius = UDim.new(0, 6)
UICorner_31.Parent = Exit_4

Clear_4.Name = "Clear"
Clear_4.Parent = Topbar_4
Clear_4.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
Clear_4.BackgroundTransparency = 0.300
Clear_4.Position = UDim2.new(1, -105, 0, 0)
Clear_4.Size = UDim2.new(0, 30, 0, 30)
Clear_4.Visible = false
Clear_4.Font = Enum.Font.GothamBold
Clear_4.Text = "C"
Clear_4.TextColor3 = Color3.fromRGB(10, 10, 10)
Clear_4.TextSize = 18.000

UICorner_32.CornerRadius = UDim.new(0, 6)
UICorner_32.Parent = Clear_4

Container_4.Name = "Container"
Container_4.Parent = soRealConsole
Container_4.BackgroundTransparency = 1.000
Container_4.Position = UDim2.new(0, 10, 0, 35)
Container_4.Size = UDim2.new(1, -20, 1, -40)

UIListLayout_8.Parent = Container_4
UIListLayout_8.Padding = UDim.new(0, 5)

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

UIListLayout_9.Parent = Logs_2
UIListLayout_9.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_9.Padding = UDim.new(0, 3)

TextLabel_4.Parent = Logs_2
TextLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_4.BackgroundTransparency = 1.000
TextLabel_4.Size = UDim2.new(1, 0, 0, 25)
TextLabel_4.Font = Enum.Font.Arial
TextLabel_4.Text = "[Output]: failed print 1"
TextLabel_4.TextColor3 = Color3.fromRGB(240, 240, 240)
TextLabel_4.TextScaled = true
TextLabel_4.TextSize = 14.000
TextLabel_4.TextStrokeTransparency = 0.800
TextLabel_4.TextWrapped = true

UICorner_33.CornerRadius = UDim.new(0, 9)
UICorner_33.Parent = Container_4

UIGradient_13.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_13.Parent = Container_4

Filter_2.Name = "Filter"
Filter_2.Parent = Container_4
Filter_2.AnchorPoint = Vector2.new(0.5, 0)
Filter_2.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
Filter_2.BackgroundTransparency = 0.700
Filter_2.BorderSizePixel = 0
Filter_2.Position = UDim2.new(0.5, 0, 0, 5)
Filter_2.Size = UDim2.new(1, -10, 0, 20)
Filter_2.Font = Enum.Font.SourceSans
Filter_2.PlaceholderColor3 = Color3.fromRGB(124, 124, 124)
Filter_2.PlaceholderText = "Search..."
Filter_2.Text = ""
Filter_2.TextColor3 = Color3.fromRGB(229, 229, 229)
Filter_2.TextSize = 18.000

UICorner_34.CornerRadius = UDim.new(0, 9)
UICorner_34.Parent = Filter_2

UICorner_35.CornerRadius = UDim.new(0, 9)
UICorner_35.Parent = soRealConsole

UIGradient_14.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 4, 20)), ColorSequenceKeypoint.new(0.38, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(0.68, Color3.fromRGB(4, 4, 4)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 4, 20))}
UIGradient_14.Parent = soRealConsole

return AdminUI