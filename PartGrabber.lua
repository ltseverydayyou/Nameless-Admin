if getgenv().prtGrabLoaded then return print('Part Grabber is already running') end
getgenv().prtGrabLoaded = true

local function SafeGetService(name)
    local Service = (game.GetService)
    local Reference = (cloneref) or function(reference) return reference end
    return Reference(Service(game, name))
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
    elseif lPlr and lPlr:FindFirstChildWhichIsA("PlayerGui") then
        NAProtection(sGui)
        sGui.Parent = lPlr:FindFirstChildWhichIsA("PlayerGui")
        sGui.ResetOnSpawn = false
        return sGui
    else
        return nil
    end
end

local TweenService = SafeGetService("TweenService")
local UIS = SafeGetService("UserInputService")
local GuiService = SafeGetService("GuiService")
local Players = SafeGetService("Players")
local plr = Players.LocalPlayer

local function createButton(text, color, parent, h)
    local b = Instance.new("TextButton")
    b.Name = text:gsub("%s+", "")
    b.Text = text
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(235,235,255)
    b.BackgroundColor3 = color
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Size = UDim2.new(1, 0, 0, h or 38)
    b.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = b
    b.MouseEnter:Connect(function()
        if UIS.TouchEnabled then return end
        TweenService:Create(b, TweenInfo.new(0.16), {BackgroundTransparency = 0}):Play()
        TweenService:Create(b, TweenInfo.new(0.16), {Size = UDim2.new(1, 0, 0, (h or 38)+2)}):Play()
    end)
    b.MouseLeave:Connect(function()
        if UIS.TouchEnabled then return end
        TweenService:Create(b, TweenInfo.new(0.16), {BackgroundTransparency = 0.2}):Play()
        TweenService:Create(b, TweenInfo.new(0.16), {Size = UDim2.new(1, 0, 0, (h or 38))}):Play()
    end)
    return b
end

local function ripple(btn, screenPos)
    local inset = GuiService:GetGuiInset()
    local localPos = Vector2.new(screenPos.X - inset.X - btn.AbsolutePosition.X, screenPos.Y - inset.Y - btn.AbsolutePosition.Y)
    local r = Instance.new("Frame")
    r.BackgroundColor3 = Color3.fromRGB(255,255,255)
    r.BackgroundTransparency = 0.8
    r.BorderSizePixel = 0
    r.ZIndex = btn.ZIndex + 1
    r.Size = UDim2.new(0, 0, 0, 0)
    r.AnchorPoint = Vector2.new(0.5, 0.5)
    r.Position = UDim2.fromOffset(localPos.X, localPos.Y)
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(1, 0)
    rc.Parent = r
    r.Parent = btn
    local max = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 1.8
    TweenService:Create(r, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(max, max)}):Play()
    TweenService:Create(r, TweenInfo.new(0.35), {BackgroundTransparency = 1}):Play()
    task.delay(0.4, function() r:Destroy() end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PartGrabberX"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protectUI(screenGui)

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 520, 0, 304)
Window.Position = UDim2.new(0.5, -260, 0.5, -162)
Window.BackgroundColor3 = Color3.fromRGB(16,16,24)
Window.BorderSizePixel = 0
Window.Parent = screenGui

local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.ImageTransparency = 0.35
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.ZIndex = 0
shadow.Parent = Window

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 16)
winCorner.Parent = Window

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 2
winStroke.Color = Color3.fromRGB(90, 120, 255)
winStroke.Transparency = 0.3
winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
winStroke.Parent = Window

local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 48)
Topbar.BackgroundColor3 = Color3.fromRGB(12,12,20)
Topbar.BorderSizePixel = 0
Topbar.Parent = Window
Topbar.Active = true
Topbar.Selectable = true

local tbCorner = Instance.new("UICorner")
tbCorner.CornerRadius = UDim.new(0, 16)
tbCorner.Parent = Topbar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "Part Grabber X"
Title.Font = Enum.Font.GothamBlack
Title.TextColor3 = Color3.fromRGB(225,225,255)
Title.TextSize = 18
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -170, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Topbar

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140,160,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220,220,255))
}
titleGrad.Rotation = 0
titleGrad.Parent = Title

local TopBtns = Instance.new("Frame")
TopBtns.Name = "TopBtns"
TopBtns.BackgroundTransparency = 1
TopBtns.Size = UDim2.new(0, 136, 1, -10)
TopBtns.Position = UDim2.new(1, -142, 0, 5)
TopBtns.Parent = Topbar

local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.Padding = UDim.new(0, 8)
btnLayout.Parent = TopBtns

local Minimize = createButton("-", Color3.fromRGB(70,130,255), TopBtns, 36)
Minimize.Size = UDim2.new(0, 56, 0, 36)
Minimize.TextScaled = true

local Exit = createButton("×", Color3.fromRGB(230,70,70), TopBtns, 36)
Exit.Size = UDim2.new(0, 56, 0, 36)
Exit.TextScaled = true

local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, -20, 1, -70)
Body.Position = UDim2.new(0, 10, 0, 58)
Body.BackgroundColor3 = Color3.fromRGB(22,22,32)
Body.BorderSizePixel = 0
Body.Parent = Window

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0, 14)
bodyCorner.Parent = Body

local bodyStroke = Instance.new("UIStroke")
bodyStroke.Thickness = 1
bodyStroke.Color = Color3.fromRGB(80, 90, 160)
bodyStroke.Transparency = 0.6
bodyStroke.Parent = Body

local bodyGrad = Instance.new("UIGradient")
bodyGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(26,26,40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30,30,50))
}
bodyGrad.Rotation = 0
bodyGrad.Parent = Body

local bodyPad = Instance.new("UIPadding")
bodyPad.PaddingTop = UDim.new(0, 14)
bodyPad.PaddingLeft = UDim.new(0, 14)
bodyPad.PaddingRight = UDim.new(0, 14)
bodyPad.PaddingBottom = UDim.new(0, 14)
bodyPad.Parent = Body

local bodyList = Instance.new("UIListLayout")
bodyList.SortOrder = Enum.SortOrder.LayoutOrder
bodyList.Padding = UDim.new(0, 12)
bodyList.Parent = Body

local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Text = "Tap/Click a 3D part to select"
Status.Font = Enum.Font.GothamSemibold
Status.Size = UDim2.new(1, 0, 0, 22)
Status.TextColor3 = Color3.fromRGB(170, 170, 255)
Status.TextSize = 13
Status.BackgroundTransparency = 1
Status.LayoutOrder = 1
Status.Parent = Body

local PathFrame = Instance.new("Frame")
PathFrame.Name = "PathFrame"
PathFrame.Size = UDim2.new(1, 0, 0, 44)
PathFrame.BackgroundColor3 = Color3.fromRGB(30,30,44)
PathFrame.BorderSizePixel = 0
PathFrame.LayoutOrder = 2
PathFrame.Parent = Body

local pfCorner = Instance.new("UICorner")
pfCorner.CornerRadius = UDim.new(0, 12)
pfCorner.Parent = PathFrame

local PathText = Instance.new("TextLabel")
PathText.Name = "PathText"
PathText.Text = ". . ."
PathText.Font = Enum.Font.Code
PathText.TextWrapped = true
PathText.TextXAlignment = Enum.TextXAlignment.Center
PathText.TextYAlignment = Enum.TextYAlignment.Center
PathText.TextSize = 14
PathText.TextColor3 = Color3.fromRGB(230,230,255)
PathText.BackgroundTransparency = 1
PathText.Size = UDim2.new(1, -10, 1, -8)
PathText.Position = UDim2.new(0, 5, 0, 4)
PathText.Parent = PathFrame

local Row1 = Instance.new("Frame")
Row1.BackgroundTransparency = 1
Row1.Size = UDim2.new(1, 0, 0, 38)
Row1.LayoutOrder = 3
Row1.Parent = Body

local Grid1 = Instance.new("UIGridLayout")
Grid1.CellPadding = UDim2.new(0, 12, 0, 0)
Grid1.CellSize = UDim2.new(0.5, -6, 1, 0)
Grid1.Parent = Row1

local CopyPath = createButton("Copy Path", Color3.fromRGB(70,130,255), Row1)
local SelectToggle = createButton("Selection: On", Color3.fromRGB(90,140,220), Row1)

local Row2 = Instance.new("Frame")
Row2.BackgroundTransparency = 1
Row2.Size = UDim2.new(1, 0, 0, 38)
Row2.LayoutOrder = 4
Row2.Parent = Body

local Grid2 = Instance.new("UIGridLayout")
Grid2.CellPadding = UDim2.new(0, 12, 0, 0)
Grid2.CellSize = UDim2.new(0.5, -6, 1, 0)
Grid2.Parent = Row2

local Rename = createButton("Rename Part", Color3.fromRGB(90,90,150), Row2)
local Bring = createButton("Bring Part", Color3.fromRGB(90,90,150), Row2)

local Row3 = Instance.new("Frame")
Row3.BackgroundTransparency = 1
Row3.Size = UDim2.new(1, 0, 0, 38)
Row3.LayoutOrder = 5
Row3.Parent = Body

local Grid3 = Instance.new("UIGridLayout")
Grid3.CellPadding = UDim2.new(0, 12, 0, 0)
Grid3.CellSize = UDim2.new(0.5, -6, 1, 0)
Grid3.Parent = Row3

local CanCollideBtn = createButton("CanCollide: ?", Color3.fromRGB(70,180,110), Row3)
local Delete = createButton("Delete Part", Color3.fromRGB(230,70,70), Row3)

local Modal = Instance.new("Frame")
Modal.Visible = false
Modal.BackgroundColor3 = Color3.fromRGB(10,10,16)
Modal.BackgroundTransparency = 0.45
Modal.BorderSizePixel = 0
Modal.Size = UDim2.new(1, 0, 1, 0)
Modal.Position = UDim2.new(0, 0, 0, 0)
Modal.Parent = Window
Modal.ZIndex = 50

local RenameBox = Instance.new("Frame")
RenameBox.Size = UDim2.new(0, 360, 0, 140)
RenameBox.Position = UDim2.new(0.5, -180, 0.5, -70)
RenameBox.BackgroundColor3 = Color3.fromRGB(24,24,34)
RenameBox.BorderSizePixel = 0
RenameBox.Parent = Modal
RenameBox.ZIndex = 51

local rbCorner = Instance.new("UICorner")
rbCorner.CornerRadius = UDim.new(0, 12)
rbCorner.Parent = RenameBox

local rbStroke = Instance.new("UIStroke")
rbStroke.Thickness = 2
rbStroke.Color = Color3.fromRGB(90,120,255)
rbStroke.Transparency = 0.3
rbStroke.Parent = RenameBox

local RBTitle = Instance.new("TextLabel")
RBTitle.BackgroundTransparency = 1
RBTitle.Text = "Rename Part"
RBTitle.Font = Enum.Font.GothamBold
RBTitle.TextSize = 16
RBTitle.TextColor3 = Color3.fromRGB(220,220,255)
RBTitle.Size = UDim2.new(1, -20, 0, 28)
RBTitle.Position = UDim2.new(0, 10, 0, 10)
RBTitle.ZIndex = 51
RBTitle.Parent = RenameBox

local RBInput = Instance.new("TextBox")
RBInput.Size = UDim2.new(1, -20, 0, 36)
RBInput.Position = UDim2.new(0, 10, 0, 50)
RBInput.Font = Enum.Font.Gotham
RBInput.TextSize = 14
RBInput.Text = ""
RBInput.ClearTextOnFocus = false
RBInput.TextColor3 = Color3.fromRGB(230,230,255)
RBInput.PlaceholderText = "Enter new name"
RBInput.BackgroundColor3 = Color3.fromRGB(34,34,46)
RBInput.BorderSizePixel = 0
RBInput.Parent = RenameBox
RBInput.ZIndex = 51
local rbInputCorner = Instance.new("UICorner")
rbInputCorner.CornerRadius = UDim.new(0, 10)
rbInputCorner.Parent = RBInput

local RBRow = Instance.new("Frame")
RBRow.BackgroundTransparency = 1
RBRow.Size = UDim2.new(1, -20, 0, 34)
RBRow.Position = UDim2.new(0, 10, 1, -44)
RBRow.ZIndex = 51
RBRow.Parent = RenameBox

local RBGrid = Instance.new("UIGridLayout")
RBGrid.CellPadding = UDim2.new(0, 10, 0, 0)
RBGrid.CellSize = UDim2.new(0.5, -6, 1, 0)
RBGrid.Parent = RBRow

local SaveName = createButton("Save", Color3.fromRGB(70,190,100), RBRow, 34)
SaveName.ZIndex = 51
local CancelName = createButton("Cancel", Color3.fromRGB(90,90,140), RBRow, 34)
CancelName.ZIndex = 51

local selectedPart = nil
local selectionAdornment = nil
local selectionEnabled = true
local minimized = false
local draggingUI = false
local dragInput = nil
local dragStart, startPos = nil, nil
local mouseConn = nil

local function GetInstancePath(obj)
    local path = {}
    local function isService(o)
        return o.Parent == game and o ~= game
    end
    if not obj then return "" end
    if isService(obj) then
        table.insert(path, string.format('game:GetService("%s")', obj.ClassName))
    else
        while obj and obj.Parent do
            local name = obj.Name
            if name:match("^[%a_][%w_]*$") then
                table.insert(path, 1, "." .. name)
            else
                table.insert(path, 1, string.format(':FindFirstChild("%s")', name:gsub('"', '\\"')))
            end
            if isService(obj.Parent) then
                table.insert(path, 1, string.format('game:GetService("%s")', obj.Parent.ClassName))
                break
            end
            obj = obj.Parent
        end
    end
    return (table.concat(path):gsub("^%.", ""))
end

local function setStatus(t, good)
    Status.Text = t
    local c = good == nil and Color3.fromRGB(170,170,255) or (good and Color3.fromRGB(100,255,120) or Color3.fromRGB(255,120,120))
    TweenService:Create(Status, TweenInfo.new(0.12), {TextColor3 = c}):Play()
end

local function clearAdornment()
    if selectionAdornment then selectionAdornment:Destroy() selectionAdornment = nil end
end

local function highlight(part)
    clearAdornment()
    local h = Instance.new("Highlight")
    h.Name = "PartGrabber_Highlight"
    h.Adornee = part
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency = 0.7
    h.OutlineTransparency = 0
    h.FillColor = Color3.fromRGB(70,120,255)
    h.OutlineColor = Color3.fromRGB(140,170,255)
    h.Parent = part
    selectionAdornment = h
    TweenService:Create(h, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {FillTransparency = 0.5}):Play()
end

local function updateCanCollideButton()
    if selectedPart and selectedPart:IsA("BasePart") then
        if selectedPart.CanCollide then
            CanCollideBtn.Text = "CanCollide: On"
            TweenService:Create(CanCollideBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70,180,110)}):Play()
        else
            CanCollideBtn.Text = "CanCollide: Off"
            TweenService:Create(CanCollideBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180,120,80)}):Play()
        end
    else
        CanCollideBtn.Text = "CanCollide: ?"
        TweenService:Create(CanCollideBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(90,90,120)}):Play()
    end
end

local function setSelected(p)
    selectedPart = p
    if p then
        PathText.Text = " " .. GetInstancePath(p)
        setStatus("Part selected: "..p.Name, true)
        highlight(p)
        updateCanCollideButton()
        TweenService:Create(PathFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36,36,50)}):Play()
    else
        PathText.Text = ". . ."
        setStatus("No part selected", false)
        clearAdornment()
        updateCanCollideButton()
        TweenService:Create(PathFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30,30,44)}):Play()
    end
end

local function isOnWindow(screenPos)
    local inset = GuiService:GetGuiInset()
    local p = Vector2.new(screenPos.X - inset.X, screenPos.Y - inset.Y)
    local a = Window.AbsolutePosition
    local s = Window.AbsoluteSize
    return p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y
end

local function selectWithMouse()
    if not selectionEnabled then return end
    if draggingUI then return end
    local pos = UIS:GetMouseLocation()
    if isOnWindow(pos) then return end
    local mouse = plr:GetMouse()
    local t = mouse.Target
    if t and t:IsA("BasePart") then
        setSelected(t)
    else
        setSelected(nil)
    end
end

local function bindMouseSelect()
    if mouseConn then mouseConn:Disconnect() end
    local mouse = plr:GetMouse()
    mouseConn = mouse.Button1Down:Connect(selectWithMouse)
    UIS.TouchTap:Connect(function(touches, processed)
        if processed then return end
        local p = touches and touches[1]
        if p and isOnWindow(p) then return end
        selectWithMouse()
    end)
end

local function showRenameModal(defaultText)
    RBInput.Text = defaultText or ""
    Modal.Visible = true
    RenameBox.Size = UDim2.new(0, 320, 0, 110)
    TweenService:Create(Modal, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    TweenService:Create(RenameBox, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 360, 0, 140)}):Play()
    RBInput:CaptureFocus()
end

local function hideRenameModal()
    TweenService:Create(Modal, TweenInfo.new(0.15), {BackgroundTransparency = 0.45}):Play()
    Modal.Visible = false
end

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Body.Visible = false
        TweenService:Create(Window, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 64)}):Play()
        Minimize.Text = "+"
    else
        TweenService:Create(Window, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 520, 0, 304)}):Play()
        task.delay(0.05, function() Body.Visible = true end)
        Minimize.Text = "-"
    end
end)

Exit.MouseButton1Click:Connect(function()
    if mouseConn then mouseConn:Disconnect() end
    clearAdornment()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "PartGrabber_Highlight" then v:Destroy() end
    end
    screenGui:Destroy()
    selectedPart = nil
    getgenv().prtGrabLoaded = false
end)

CopyPath.MouseButton1Click:Connect(function()
    if PathText.Text ~= ". . ." and setclipboard then
        setclipboard(PathText.Text)
        setStatus("Path copied", true)
        TweenService:Create(CopyPath, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(70,190,110)}):Play()
        task.wait(0.22)
        TweenService:Create(CopyPath, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(70,130,255)}):Play()
    else
        setStatus("No part to copy", false)
    end
end)

SelectToggle.MouseButton1Click:Connect(function()
    selectionEnabled = not selectionEnabled
    if selectionEnabled then
        SelectToggle.Text = "Selection: On"
        TweenService:Create(SelectToggle, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(90,140,220)}):Play()
        setStatus("Selection enabled", true)
    else
        SelectToggle.Text = "Selection: Off"
        TweenService:Create(SelectToggle, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(120,90,140)}):Play()
        setStatus("Selection disabled", false)
    end
end)

Delete.MouseButton1Click:Connect(function()
    if selectedPart then
        local ok, err = pcall(function() selectedPart:Destroy() end)
        if ok then
            setStatus("Part deleted", true)
            setSelected(nil)
        else
            setStatus("Delete failed: "..tostring(err):sub(1,40), false)
        end
    else
        setStatus("No part selected to delete", false)
    end
end)

Rename.MouseButton1Click:Connect(function()
    if selectedPart then
        showRenameModal(selectedPart.Name)
    else
        setStatus("No part selected to rename", false)
    end
end)

SaveName.MouseButton1Click:Connect(function()
    if selectedPart and RBInput.Text ~= "" then
        selectedPart.Name = RBInput.Text
        setStatus("Renamed to "..RBInput.Text, true)
        PathText.Text = " " .. GetInstancePath(selectedPart)
    end
    hideRenameModal()
end)

CancelName.MouseButton1Click:Connect(function()
    hideRenameModal()
end)

Bring.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            selectedPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
            setStatus("Brought part in front", true)
        else
            setStatus("HumanoidRootPart not found", false)
        end
    else
        setStatus("No part selected to bring", false)
    end
end)

CanCollideBtn.MouseButton1Click:Connect(function()
    if selectedPart and selectedPart:IsA("BasePart") then
        selectedPart.CanCollide = not selectedPart.CanCollide
        if selectedPart.CanCollide then
            setStatus("CanCollide enabled", true)
        else
            setStatus("CanCollide disabled", true)
        end
        updateCanCollideButton()
    else
        setStatus("No part selected or invalid", false)
    end
end)

local function beginDragUI(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    draggingUI = true
    dragStart = input.Position
    startPos = Window.Position
    TweenService:Create(Window, TweenInfo.new(0.12), {Size = UDim2.new(0, Window.Size.X.Offset, 0, (minimized and 64 or 304)+2)}):Play()
    TweenService:Create(winStroke, TweenInfo.new(0.12), {Thickness = 3}):Play()
    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            draggingUI = false
            TweenService:Create(Window, TweenInfo.new(0.12), {Size = UDim2.new(0, Window.Size.X.Offset, 0, minimized and 64 or 304)}):Play()
            TweenService:Create(winStroke, TweenInfo.new(0.12), {Thickness = 2}):Play()
        end
    end)
end

local function updateDragUI(input)
    if not draggingUI then return end
    local delta = input.Position - dragStart
    Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Topbar.InputBegan:Connect(function(input)
    beginDragUI(input)
end)

Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput then
        updateDragUI(input)
    end
end)

Window.Position = UDim2.new(0.5, -260, 0.5, -240)
Window.Size = UDim2.new(0, 520, 0, 260)
Window.BackgroundTransparency = 1
TweenService:Create(Window, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -260, 0.5, -162), Size = UDim2.new(0, 520, 0, 304), BackgroundTransparency = 0}):Play()
TweenService:Create(winStroke, TweenInfo.new(0.35), {Transparency = 0.3}):Play()
TweenService:Create(bodyStroke, TweenInfo.new(0.35), {Transparency = 0.6}):Play()
TweenService:Create(titleGrad, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()

bindMouseSelect()

local function bindRipples(btn)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ripple(btn, input.Position)
        end
    end)
end

for _, b in ipairs({CopyPath, SelectToggle, Delete, Rename, Bring, CanCollideBtn, Exit, Minimize, SaveName, CancelName}) do
    bindRipples(b)
end