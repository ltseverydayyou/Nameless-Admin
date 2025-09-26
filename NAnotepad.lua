if getgenv().npadLoaded then return end
getgenv().npadLoaded = true

local function Svc(n)
    local g = game.GetService
    local cref = cloneref or function(r) return r end
    return cref(g(game, n))
end

local function ProtectGui(g)
    if g:IsA("ScreenGui") then
        g.ZIndexBehavior = Enum.ZIndexBehavior.Global
        g.DisplayOrder = 999999999
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
    end
    local cg = Svc("CoreGui")
    local lp = Svc("Players").LocalPlayer
    local function NAP(i, v)
        if i then
            if v then i[v] = "\0" i.Archivable = false else i.Name = "\0" i.Archivable = false end
        end
    end
    if gethui then NAP(g) g.Parent = gethui() return g end
    if cg and cg:FindFirstChild("RobloxGui") then NAP(g) g.Parent = cg:FindFirstChild("RobloxGui") return g end
    if cg then NAP(g) g.Parent = cg return g end
    if lp and lp:FindFirstChildWhichIsA("PlayerGui") then NAP(g) g.Parent = lp:FindFirstChildWhichIsA("PlayerGui") g.ResetOnSpawn = false return g end
    return nil
end

local ts = Svc("TweenService")
local uis = Svc("UserInputService")
local gsv = Svc("GuiService")
local txtsvc = Svc("TextService")

local IsOnMobile=(function()
	local platform=uis:GetPlatform()
	if platform==Enum.Platform.IOS or platform==Enum.Platform.Android or platform==Enum.Platform.AndroidTV or platform==Enum.Platform.Chromecast or platform==Enum.Platform.MetaOS then
		return true
	end
	if platform==Enum.Platform.None then
		return uis.TouchEnabled and not (uis.KeyboardEnabled or uis.MouseEnabled)
	end
	return false
end)()

local gui = Instance.new("ScreenGui")
gui.Name = "NotepadX"
ProtectGui(gui)

local win = Instance.new("Frame")
win.Name = "Win"
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.Position = UDim2.fromScale(0.5, 0.5)
win.Size = UDim2.fromScale(0.6, 0.86)
win.BackgroundColor3 = Color3.fromRGB(16,16,24)
win.BorderSizePixel = 0
win.Parent = gui

local uiScale = Instance.new("UIScale")
uiScale.Parent = win

local sizeCons = Instance.new("UISizeConstraint")
sizeCons.MinSize = Vector2.new(380, 360)
sizeCons.MaxSize = Vector2.new(980, 740)
sizeCons.Parent = win

local BASE_MIN = Vector2.new(380, 360)

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 14)
winCorner.Parent = win

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 2
winStroke.Color = Color3.fromRGB(90,120,255)
winStroke.Transparency = 0.35
winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
winStroke.Parent = win

local top = Instance.new("Frame")
top.Name = "Top"
top.BackgroundColor3 = Color3.fromRGB(12,12,20)
top.BorderSizePixel = 0
top.Size = UDim2.new(1, 0, 0, 48)
top.Parent = win
top.Active = true
top.Selectable = true

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = top

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -170, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Notepad X"
title.TextColor3 = Color3.fromRGB(230,230,255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local topBtns = Instance.new("Frame")
topBtns.BackgroundTransparency = 1
topBtns.Size = UDim2.new(0, 150, 1, -10)
topBtns.Position = UDim2.new(1, -156, 0, 5)
topBtns.Parent = top

local topList = Instance.new("UIListLayout")
topList.FillDirection = Enum.FillDirection.Horizontal
topList.HorizontalAlignment = Enum.HorizontalAlignment.Right
topList.VerticalAlignment = Enum.VerticalAlignment.Center
topList.Padding = UDim.new(0, 8)
topList.Parent = topBtns

local function mkBtn(txt, col, par, h)
    local b = Instance.new("TextButton")
    b.Name = txt:gsub("%s+","")
    b.Text = txt
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(235,235,255)
    b.BackgroundColor3 = col
    b.BackgroundTransparency = 0.16
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Size = UDim2.new(0, 64, 0, h or 32)
    b.Parent = par
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = b
    b.MouseEnter:Connect(function() if not IsOnMobile then ts:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play() end end)
    b.MouseLeave:Connect(function() if not IsOnMobile then ts:Create(b, TweenInfo.new(0.12), {BackgroundTransparency = 0.16}):Play() end end)
    return b
end

local btnMin = mkBtn("-", Color3.fromRGB(90,140,255), topBtns, 34)
btnMin.Size = UDim2.new(0, 56, 0, 34)

local btnExit = mkBtn("×", Color3.fromRGB(230,70,80), topBtns, 34)
btnExit.Size = UDim2.new(0, 56, 0, 34)

local body = Instance.new("Frame")
body.Name = "Body"
body.BackgroundColor3 = Color3.fromRGB(22,22,32)
body.BorderSizePixel = 0
body.Size = UDim2.new(1, -16, 1, -64)
body.Position = UDim2.new(0, 8, 0, 56)
body.Parent = win

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0, 12)
bodyCorner.Parent = body

local bodyStroke = Instance.new("UIStroke")
bodyStroke.Thickness = 1
bodyStroke.Color = Color3.fromRGB(80,90,160)
bodyStroke.Transparency = 0.6
bodyStroke.Parent = body

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 12)
pad.PaddingBottom = UDim.new(0, 12)
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingRight = UDim.new(0, 12)
pad.Parent = body

local vlist = Instance.new("UIListLayout")
vlist.SortOrder = Enum.SortOrder.LayoutOrder
vlist.Padding = UDim.new(0, 10)
vlist.Parent = body

local fileRow = Instance.new("Frame")
fileRow.BackgroundTransparency = 1
fileRow.Size = UDim2.new(1, 0, 0, 36)
fileRow.LayoutOrder = 1
fileRow.Parent = body

local fileList = Instance.new("UIListLayout")
fileList.FillDirection = Enum.FillDirection.Horizontal
fileList.HorizontalAlignment = Enum.HorizontalAlignment.Left
fileList.VerticalAlignment = Enum.VerticalAlignment.Center
fileList.Padding = UDim.new(0, 8)
fileList.Parent = fileRow

local nameBox = Instance.new("TextBox")
nameBox.Size = UDim2.new(0.6, 0, 1, 0)
nameBox.Text = "file"
nameBox.ClearTextOnFocus = false
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 14
nameBox.TextColor3 = Color3.fromRGB(235,235,255)
nameBox.PlaceholderText = "file name"
nameBox.BackgroundColor3 = Color3.fromRGB(34,34,46)
nameBox.BorderSizePixel = 0
nameBox.Parent = fileRow
local nameCorner = Instance.new("UICorner")
nameCorner.CornerRadius = UDim.new(0, 10)
nameCorner.Parent = nameBox

local dotLbl = Instance.new("TextLabel")
dotLbl.BackgroundTransparency = 1
dotLbl.Size = UDim2.new(0.04, 0, 1, 0)
dotLbl.Text = "."
dotLbl.Font = Enum.Font.GothamBold
dotLbl.TextSize = 16
dotLbl.TextColor3 = Color3.fromRGB(210,210,240)
dotLbl.TextXAlignment = Enum.TextXAlignment.Center
dotLbl.Parent = fileRow

local extBox = Instance.new("TextBox")
extBox.Size = UDim2.new(0.2, 0, 1, 0)
extBox.Text = "txt"
extBox.ClearTextOnFocus = false
extBox.Font = Enum.Font.Gotham
extBox.TextSize = 14
extBox.TextColor3 = Color3.fromRGB(235,235,255)
extBox.PlaceholderText = "ext"
extBox.BackgroundColor3 = Color3.fromRGB(34,34,46)
extBox.BorderSizePixel = 0
extBox.Parent = fileRow
local extCorner = Instance.new("UICorner")
extCorner.CornerRadius = UDim.new(0, 10)
extCorner.Parent = extBox

local extBtn = mkBtn("Ext ▼", Color3.fromRGB(120,90,160), fileRow, 30)
extBtn.Size = UDim2.new(0.16, 0, 0, 30)

local btnRow = Instance.new("Frame")
btnRow.BackgroundTransparency = 1
btnRow.Size = UDim2.new(1, 0, 0, 36)
btnRow.LayoutOrder = 2
btnRow.Parent = body

local btnGrid = Instance.new("UIGridLayout")
btnGrid.FillDirection = Enum.FillDirection.Horizontal
btnGrid.CellPadding = UDim2.new(0, 8, 0, 0)
btnGrid.CellSize = UDim2.new(0.333, -6, 1, 0)
btnGrid.FillDirectionMaxCells = 3
btnGrid.Parent = btnRow

local btnNew = mkBtn("New", Color3.fromRGB(90,90,150), btnRow, 32)
local btnOpen = mkBtn("Open", Color3.fromRGB(90,140,220), btnRow, 32)
local btnSave = mkBtn("Save", Color3.fromRGB(70,180,110), btnRow, 32)

local txtFrame = Instance.new("Frame")
txtFrame.BackgroundColor3 = Color3.fromRGB(30,30,44)
txtFrame.BorderSizePixel = 0
txtFrame.Size = UDim2.new(1, 0, 1, -(36+10+36+10+36+10+26))
txtFrame.LayoutOrder = 3
txtFrame.Parent = body
local tfCorner = Instance.new("UICorner")
tfCorner.CornerRadius = UDim.new(0, 10)
tfCorner.Parent = txtFrame
local tfStroke = Instance.new("UIStroke")
tfStroke.Thickness = 1
tfStroke.Color = Color3.fromRGB(90,100,170)
tfStroke.Transparency = 0.4
tfStroke.Parent = txtFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Active = true
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 6, 0, 6)
scroll.Size = UDim2.new(1, -12, 1, -12)
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(120,120,220)
scroll.ScrollingDirection = Enum.ScrollingDirection.XY
scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
scroll.Parent = txtFrame

local box = Instance.new("TextBox")
box.BackgroundTransparency = 1
box.Position = UDim2.new(0, 2, 0, 0)
box.Size = UDim2.new(0, 200, 0, 200)
box.ClearTextOnFocus = false
box.Font = Enum.Font.Code
box.TextSize = 24
box.TextScaled = false
box.MultiLine = true
box.PlaceholderText = "Type here..."
box.PlaceholderColor3 = Color3.fromRGB(160,160,190)
box.Text = ""
box.TextColor3 = Color3.fromRGB(230,230,245)
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextWrapped = false
box.RichText = false
box.MaxVisibleGraphemes = -1
box.Parent = scroll

local utilRow = Instance.new("Frame")
utilRow.BackgroundTransparency = 1
utilRow.Size = UDim2.new(1, 0, 0, 36)
utilRow.LayoutOrder = 4
utilRow.Parent = body

local utilGrid = Instance.new("UIGridLayout")
utilGrid.FillDirection = Enum.FillDirection.Horizontal
utilGrid.CellPadding = UDim2.new(0, 8, 0, 0)
utilGrid.CellSize = UDim2.new(0.333, -6, 1, 0)
utilGrid.Parent = utilRow

local btnCopy = mkBtn("Copy", Color3.fromRGB(70,140,240), utilRow, 32)
local btnClear = mkBtn("Clear", Color3.fromRGB(230,90,90), utilRow, 32)
local btnDelete = mkBtn("Delete", Color3.fromRGB(210,120,70), utilRow, 32)

local statusRow = Instance.new("Frame")
statusRow.BackgroundTransparency = 1
statusRow.Size = UDim2.new(1, 0, 0, 26)
statusRow.LayoutOrder = 5
statusRow.Parent = body

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(0.6, 0, 1, 0)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(180,180,220)
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = false
status.TextTruncate = Enum.TextTruncate.AtEnd
status.Parent = statusRow

local counts = Instance.new("TextLabel")
counts.BackgroundTransparency = 1
counts.Size = UDim2.new(0.4, 0, 1, 0)
counts.Position = UDim2.new(0.6, 0, 0, 0)
counts.Text = "Chars: 0 | Lines: 0"
counts.Font = Enum.Font.Gotham
counts.TextSize = 14
counts.TextColor3 = Color3.fromRGB(170,170,190)
counts.TextXAlignment = Enum.TextXAlignment.Right
counts.TextWrapped = false
counts.TextTruncate = Enum.TextTruncate.AtEnd
counts.Parent = statusRow

local extList = Instance.new("Frame")
extList.Visible = false
extList.BackgroundColor3 = Color3.fromRGB(28,28,40)
extList.BorderSizePixel = 0
extList.Size = UDim2.new(0, 180, 0, 160)
extList.ZIndex = 50
extList.Parent = gui
local extCorner2 = Instance.new("UICorner")
extCorner2.CornerRadius = UDim.new(0, 10)
extCorner2.Parent = extList
local extStroke = Instance.new("UIStroke")
extStroke.Thickness = 1
extStroke.Color = Color3.fromRGB(100,110,180)
extStroke.Transparency = 0.4
extStroke.Parent = extList
local extScroll = Instance.new("ScrollingFrame")
extScroll.BackgroundTransparency = 1
extScroll.BorderSizePixel = 0
extScroll.Size = UDim2.new(1, -10, 1, -10)
extScroll.Position = UDim2.new(0, 5, 0, 5)
extScroll.ScrollBarThickness = 4
extScroll.ZIndex = 51
extScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
extScroll.CanvasSize = UDim2.new()
extScroll.Parent = extList
local extLayout = Instance.new("UIListLayout")
extLayout.Padding = UDim.new(0, 6)
extLayout.Parent = extScroll

local exts = {"txt","lua","json","md","log","cfg","csv","xml","ini","html"}
local function mkExtButton(t)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.Text = t
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 14
    b.BackgroundColor3 = Color3.fromRGB(38,38,56)
    b.TextColor3 = Color3.fromRGB(230,230,255)
    b.BorderSizePixel = 0
    b.ZIndex = 52
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b
    b.Parent = extScroll
    b.MouseEnter:Connect(function() ts:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(46,46,66)}):Play() end)
    b.MouseLeave:Connect(function() ts:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(38,38,56)}):Play() end)
    b.MouseButton1Click:Connect(function()
        extBox.Text = t
        extList.Visible = false
    end)
end
for _, e2 in ipairs(exts) do mkExtButton(e2) end

local minimized = false
local dock = Instance.new("TextButton")
dock.Name = "NP_Dock"
dock.Text = "📝"
dock.Font = Enum.Font.GothamBold
dock.TextScaled = true
dock.BackgroundColor3 = Color3.fromRGB(32,34,52)
dock.TextColor3 = Color3.fromRGB(220,230,255)
dock.BorderSizePixel = 0
dock.Size = UDim2.fromOffset(56,56)
dock.Visible = false
dock.AnchorPoint = Vector2.new(0.5,0.5)
dock.Parent = gui
local dockC = Instance.new("UICorner")
dockC.CornerRadius = UDim.new(1,0)
dockC.Parent = dock
local dockS = Instance.new("UIStroke")
dockS.Thickness = 1
dockS.Color = Color3.fromRGB(90,120,255)
dockS.Transparency = 0.3
dockS.Parent = dock

local function setStatus(msg, good)
    status.Text = msg
    ts:Create(status, TweenInfo.new(0.1), {TextColor3 = good == false and Color3.fromRGB(255,120,120) or Color3.fromRGB(160,200,255)}):Play()
    task.delay(2.2, function() if status then status.Text = "" end end)
end

local function trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end
local function safeName(s)
    s = trim(s or "")
    if s == "" then return "file" end
    s = s:gsub("[%c%z<>:\"/\\|%?%*]", "_")
    s = s:gsub("^%.*", "")
    if s == "" then s = "file" end
    return s
end
local function normExt(e)
    e = trim(e or ""):lower():gsub("^%.","")
    if e == "" then return "txt" end
    if not e:match("^[%w]+$") then return "txt" end
    if #e > 16 then return "txt" end
    return e
end
local function fullName()
    return safeName(nameBox.Text) .. "." .. normExt(extBox.Text)
end

local function countLines(s)
    if s == "" then return 0 end
    return select(2, s:gsub("\n","")) + 1
end

local function lineHeight()
    return txtsvc:GetTextSize("Ag", 24, box.Font, Vector2.new(1e5,1e5)).Y
end

local function maxLineWidth(text)
    local max = 0
    for line in (text.."\n"):gmatch("(.-)\n") do
        local w = txtsvc:GetTextSize(line == "" and " " or line, 24, box.Font, Vector2.new(1e7,1e7)).X
        if w > max then max = w end
    end
    return max + 16
end

local function refreshCanvas()
    box.MaxVisibleGraphemes = -1
    local w = math.max(scroll.AbsoluteSize.X, maxLineWidth(box.Text))
    local h = math.max(scroll.AbsoluteSize.Y, countLines(box.Text) * (lineHeight()+2) + 24)
    box.Size = UDim2.new(0, w - 8, 0, h - 8)
    scroll.CanvasSize = UDim2.new(0, w, 0, h)
end

local function updateCounts()
    local s = box.Text
    local chars = #s
    local lines = (s == "" and 0) or (select(2, s:gsub("\n","")) + 1)
    counts.Text = ("Chars: %d | Lines: %d"):format(chars, lines)
end

local function applyScale()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280,720)
    local inset = gsv:GetGuiInset()
    local ux = math.max(0, vp.X - inset.X*2)
    local uy = math.max(0, vp.Y - inset.Y*2)
    local targetW = math.clamp(ux * 0.6, BASE_MIN.X, sizeCons.MaxSize.X)
    local targetH = math.clamp(uy * 0.86, BASE_MIN.Y, sizeCons.MaxSize.Y)
    win.Size = UDim2.new(0, targetW, 0, targetH)
    local sc = math.min(ux / targetW, uy / targetH)
    uiScale.Scale = math.clamp(sc, 0.65, 1)
end

local function hookViewport()
    local function hookCam(c) if not c then return end c:GetPropertyChangedSignal("ViewportSize"):Connect(function() applyScale() refreshCanvas() end) end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() hookCam(workspace.CurrentCamera) applyScale() refreshCanvas() end)
    if workspace.CurrentCamera then hookCam(workspace.CurrentCamera) end
    gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() applyScale() refreshCanvas() end)
    scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshCanvas)
end

local dragging = false
local dragInput, dragStart, startPos = nil, nil, nil
top.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
    dragging = true
    dragStart = i.Position
    startPos = win.Position
    ts:Create(winStroke, TweenInfo.new(0.08), {Thickness = 3}):Play()
    i.Changed:Connect(function()
        if i.UserInputState == Enum.UserInputState.End then
            dragging = false
            ts:Create(winStroke, TweenInfo.new(0.08), {Thickness = 2}):Play()
        end
    end)
end)
top.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput = i end end)
uis.InputChanged:Connect(function(i)
    if dragging and i == dragInput then
        local d2 = i.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d2.X, startPos.Y.Scale, startPos.Y.Offset + d2.Y)
    end
end)

local lastWinPos, lastWinSize = win.Position, win.Size
local function clampDock(x,y)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280,720)
    local px = math.clamp(x, 36, vp.X-36)
    local py = math.clamp(y, 36, vp.Y-36)
    return px, py
end

local function minimizeToDock()
    if minimized then return end
    minimized = true
    lastWinPos, lastWinSize = win.Position, win.Size
    local ax = win.AbsolutePosition.X + win.AbsoluteSize.X*0.5
    local ay = win.AbsolutePosition.Y + 28
    ax, ay = clampDock(ax, ay)
    dock.Position = UDim2.fromOffset(ax, ay)
    dock.Size = UDim2.fromOffset(0,0)
    dock.Visible = true
    ts:Create(win, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
    ts:Create(body, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
    for _,g in ipairs(body:GetDescendants()) do if g:IsA("GuiObject") then g.Visible = false end end
    ts:Create(dock, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(56,56)}):Play()
    task.delay(0.18, function() win.Visible = false end)
end

local function restoreFromDock()
    if not minimized then return end
    minimized = false
    win.Visible = true
    ts:Create(dock, TweenInfo.new(0.16), {Size = UDim2.fromOffset(0,0)}):Play()
    ts:Create(win, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
    task.delay(0.02, function()
        for _,g in ipairs(body:GetDescendants()) do if g:IsA("GuiObject") then g.Visible = true end end
        ts:Create(body, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
        win.Position = lastWinPos
        win.Size = lastWinSize
        dock.Visible = false
        applyScale()
        refreshCanvas()
    end)
end

btnMin.MouseButton1Click:Connect(minimizeToDock)
dock.MouseButton1Click:Connect(restoreFromDock)

btnExit.MouseButton1Click:Connect(function()
    gui:Destroy()
    getgenv().npadLoaded = false
end)

extBtn.MouseButton1Click:Connect(function()
    extList.Visible = not extList.Visible
    local p = extBox.AbsolutePosition
    local s2 = extBox.AbsoluteSize
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920,1080)
    local x = math.clamp(p.X, 8, vp.X - extList.AbsoluteSize.X - 8)
    local y = math.clamp(p.Y + s2.Y + 4, 8, vp.Y - extList.AbsoluteSize.Y - 8)
    extList.Position = UDim2.fromOffset(x, y)
end)

uis.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if not extList.Visible then return end
        local mp = (i.UserInputType == Enum.UserInputType.Touch) and i.Position or uis:GetMouseLocation()
        local pos = Vector2.new(extList.AbsolutePosition.X, extList.AbsolutePosition.Y)
        local size = extList.AbsoluteSize
        if mp.X < pos.X or mp.X > pos.X + size.X or mp.Y < pos.Y or mp.Y > pos.Y + size.Y then
            extList.Visible = false
        end
    end
end)

local function doSave(target)
    if not writefile then setStatus("FS not available", false) return end
    local fn = target or fullName()
    local ok = pcall(writefile, fn, box.Text)
    if ok then setStatus("Saved "..fn, true) else setStatus("Save failed", false) end
end
local function doOpen(fn)
    if not (isfile and readfile) then setStatus("FS not available", false) return end
    if isfile(fn) then
        local ok, data = pcall(readfile, fn)
        if ok then
            box.Text = tostring(data or "")
            setStatus("Opened "..fn, true)
        else
            setStatus("Open failed", false)
        end
    else
        setStatus("No such file", false)
    end
end
local function doDelete(fn)
    if not (isfile and delfile) then setStatus("FS not available", false) return end
    if isfile(fn) then
        local ok = pcall(delfile, fn)
        if ok then setStatus("Deleted "..fn, true) else setStatus("Delete failed", false) end
    else
        setStatus("No such file", false)
    end
end

btnCopy.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(box.Text) setStatus("Copied to clipboard", true) else setStatus("Clipboard not available", false) end
end)
btnClear.MouseButton1Click:Connect(function()
    box.Text = ""
    refreshCanvas()
    updateCounts()
    setStatus("Cleared", true)
end)
btnDelete.MouseButton1Click:Connect(function()
    doDelete(fullName())
end)
btnNew.MouseButton1Click:Connect(function()
    nameBox.Text = "file"
    extBox.Text = "txt"
    box.Text = ""
    refreshCanvas()
    updateCounts()
    setStatus("New document", true)
end)
btnOpen.MouseButton1Click:Connect(function()
    doOpen(fullName())
    refreshCanvas()
    updateCounts()
end)
btnSave.MouseButton1Click:Connect(function()
    nameBox.Text = safeName(nameBox.Text)
    extBox.Text = normExt(extBox.Text)
    doSave()
end)

box:GetPropertyChangedSignal("Text"):Connect(function()
    box.MaxVisibleGraphemes = -1
    refreshCanvas()
    updateCounts()
end)
scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshCanvas)

uis.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.Tab and box:IsFocused() then
        local pos = box.CursorPosition
        if pos and pos > 0 then
            local tx = box.Text
            local pre = tx:sub(1, pos - 1)
            local suf = tx:sub(pos)
            box.Text = pre .. "    " .. suf
            box.CursorPosition = pos + 4
        end
    end
end)

applyScale()
hookViewport()
refreshCanvas()
updateCounts()