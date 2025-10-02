if getgenv().prtGrabLoaded then return print("Part Grabber is already running") end
getgenv().prtGrabLoaded = true

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
            if v then
                i[v] = "\0"
                i.Archivable = false
            else
                i.Name = "\0"
                i.Archivable = false
            end
        end
    end
    if gethui then
        NAP(g)
        g.Parent = gethui()
        return g
    elseif cg and cg:FindFirstChild("RobloxGui") then
        NAP(g)
        g.Parent = cg:FindFirstChild("RobloxGui")
        return g
    elseif cg then
        NAP(g)
        g.Parent = cg
        return g
    else
        local lp = Svc("Players").LocalPlayer
        if lp and lp:FindFirstChildWhichIsA("PlayerGui") then
            NAP(g)
            g.Parent = lp:FindFirstChildWhichIsA("PlayerGui")
            g.ResetOnSpawn = false
            return g
        end
    end
    return nil
end

local ts = Svc("TweenService")
local uis = Svc("UserInputService")
local gsv = Svc("GuiService")
local plrs = Svc("Players")
local lp = plrs.LocalPlayer

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

local BTN_H = IsOnMobile and 28 or 34
local BTN_TEXT = IsOnMobile and 12 or 13

local _conns = {}
local function track(c) if c then table.insert(_conns, c) end return c end
local function discAll() for i=#_conns,1,-1 do local c=_conns[i] if c and c.Disconnect then pcall(function() c:Disconnect() end) end _conns[i]=nil end end
local mouseConn, tapConn, uisChangedConn, tbBeganConn, tbChangedConn = nil, nil, nil, nil, nil

local function mkBtn(txt, col, parent, h)
    local b = Instance.new("TextButton")
    b.Name = txt:gsub("%s+","")
    b.Text = txt
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = BTN_TEXT
    b.TextColor3 = Color3.fromRGB(235,235,255)
    b.BackgroundColor3 = col
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Size = UDim2.new(1,0,0,h or BTN_H)
    b.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = b
    return b
end

local sg = Instance.new("ScreenGui")
sg.Name = "PartGrabberX"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ProtectGui(sg)

local TOPH = 40

local win = Instance.new("Frame")
win.Name = "Win"
win.Size = UDim2.new(0,420,0,300)
win.Position = UDim2.new(0.5,-210,0.5,-150)
win.BackgroundColor3 = Color3.fromRGB(16,16,24)
win.BorderSizePixel = 0
win.Parent = sg

local sh = Instance.new("ImageLabel")
sh.Name = "Shadow"
sh.BackgroundTransparency = 1
sh.Image = "rbxassetid://5028857084"
sh.ScaleType = Enum.ScaleType.Slice
sh.SliceCenter = Rect.new(24,24,276,276)
sh.ImageTransparency = 0.35
sh.Size = UDim2.new(1,40,1,40)
sh.Position = UDim2.new(0,-20,0,-20)
sh.ZIndex = 0
sh.Parent = win

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0,12)
winCorner.Parent = win

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 2
winStroke.Color = Color3.fromRGB(90,120,255)
winStroke.Transparency = 0.3
winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
winStroke.Parent = win

local top = Instance.new("Frame")
top.Name = "Top"
top.Size = UDim2.new(1,0,0,TOPH)
top.BackgroundColor3 = Color3.fromRGB(12,12,20)
top.BorderSizePixel = 0
top.Parent = win
top.Active = true
top.Selectable = true

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0,12)
topCorner.Parent = top

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Text = "Part Grabber X"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(225,225,255)
title.TextSize = 16
title.BackgroundTransparency = 1
title.Size = UDim2.new(1,-120,1,0)
title.Position = UDim2.new(0,14,0,0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(140,160,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220,220,255))
}
titleGrad.Rotation = 0
titleGrad.Parent = title

local topBtns = Instance.new("Frame")
topBtns.Name = "TopBtns"
topBtns.BackgroundTransparency = 1
topBtns.Size = UDim2.new(0,100,1,-6)
topBtns.Position = UDim2.new(1,-106,0,3)
topBtns.Parent = top

local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.Padding = UDim.new(0,6)
btnLayout.Parent = topBtns

local btnMin = mkBtn("-", Color3.fromRGB(70,130,255), topBtns, 30)
btnMin.Size = UDim2.new(0,40,0,30)
btnMin.TextScaled = true

local btnExit = mkBtn("×", Color3.fromRGB(230,70,70), topBtns, 30)
btnExit.Size = UDim2.new(0,40,0,30)
btnExit.TextScaled = true

local body = Instance.new("Frame")
body.Name = "Body"
body.Size = UDim2.new(1,-20,1,-(TOPH+26))
body.Position = UDim2.new(0,10,0,TOPH+10)
body.BackgroundColor3 = Color3.fromRGB(22,22,32)
body.BorderSizePixel = 0
body.ClipsDescendants = true
body.Parent = win

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0,10)
bodyCorner.Parent = body

local bodyStroke = Instance.new("UIStroke")
bodyStroke.Thickness = 1
bodyStroke.Color = Color3.fromRGB(80,90,160)
bodyStroke.Transparency = 0.6
bodyStroke.Parent = body

local bodyGrad = Instance.new("UIGradient")
bodyGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(26,26,40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30,30,50))
}
bodyGrad.Rotation = 0
bodyGrad.Parent = body

local bodyPad = Instance.new("UIPadding")
bodyPad.PaddingTop = UDim.new(0,12)
bodyPad.PaddingLeft = UDim.new(0,12)
bodyPad.PaddingRight = UDim.new(0,12)
bodyPad.PaddingBottom = UDim.new(0,12)
bodyPad.Parent = body

local bodyList = Instance.new("UIListLayout")
bodyList.SortOrder = Enum.SortOrder.LayoutOrder
bodyList.Padding = UDim.new(0,10)
bodyList.Parent = body

local lbl = Instance.new("TextLabel")
lbl.Name = "Status"
lbl.Text = "Tap/Click a 3D part to select"
lbl.Font = Enum.Font.GothamSemibold
lbl.Size = UDim2.new(1,0,0,20)
lbl.TextColor3 = Color3.fromRGB(170,170,255)
lbl.TextSize = 12
lbl.BackgroundTransparency = 1
lbl.LayoutOrder = 1
lbl.Parent = body

local pathFrame = Instance.new("Frame")
pathFrame.Name = "PathFrame"
pathFrame.AutomaticSize = Enum.AutomaticSize.Y
pathFrame.Size = UDim2.new(1,0,0,0)
pathFrame.BackgroundColor3 = Color3.fromRGB(30,30,44)
pathFrame.BorderSizePixel = 0
pathFrame.LayoutOrder = 2
pathFrame.Parent = body

local pfCorner = Instance.new("UICorner")
pfCorner.CornerRadius = UDim.new(0,10)
pfCorner.Parent = pathFrame

local pathTxt = Instance.new("TextLabel")
pathTxt.Name = "PathText"
pathTxt.Text = "..."
pathTxt.Font = Enum.Font.Code
pathTxt.TextWrapped = true
pathTxt.TextXAlignment = Enum.TextXAlignment.Center
pathTxt.TextYAlignment = Enum.TextYAlignment.Top
pathTxt.TextSize = 13
pathTxt.AutomaticSize = Enum.AutomaticSize.Y
pathTxt.TextColor3 = Color3.fromRGB(230,230,255)
pathTxt.BackgroundTransparency = 1
pathTxt.Size = UDim2.new(1,-8,0,0)
pathTxt.Position = UDim2.new(0,4,0,6)
pathTxt.Parent = pathFrame

local row1 = Instance.new("Frame")
row1.BackgroundTransparency = 1
row1.Size = UDim2.new(1,0,0,BTN_H)
row1.LayoutOrder = 3
row1.Parent = body

local grid1 = Instance.new("UIGridLayout")
grid1.CellPadding = UDim2.new(0,10,0,0)
grid1.CellSize = UDim2.new(0.5,-5,1,0)
grid1.Parent = row1

local btnCopy = mkBtn("Copy Path", Color3.fromRGB(70,130,255), row1, BTN_H)
local btnToggle = mkBtn("Selection: On", Color3.fromRGB(90,140,220), row1, BTN_H)

local row2 = Instance.new("Frame")
row2.BackgroundTransparency = 1
row2.Size = UDim2.new(1,0,0,BTN_H)
row2.LayoutOrder = 4
row2.Parent = body

local grid2 = Instance.new("UIGridLayout")
grid2.CellPadding = UDim2.new(0,10,0,0)
grid2.CellSize = UDim2.new(0.5,-5,1,0)
grid2.Parent = row2

local btnRen = mkBtn("Rename Part", Color3.fromRGB(90,90,150), row2, BTN_H)
local btnBring = mkBtn("Bring Part", Color3.fromRGB(90,90,150), row2, BTN_H)

local row3 = Instance.new("Frame")
row3.BackgroundTransparency = 1
row3.Size = UDim2.new(1,0,0,BTN_H)
row3.LayoutOrder = 5
row3.Parent = body

local grid3 = Instance.new("UIGridLayout")
grid3.CellPadding = UDim2.new(0,10,0,0)
grid3.CellSize = UDim2.new(0.5,-5,1,0)
grid3.Parent = row3

local btnColl = mkBtn("CanCollide: ?", Color3.fromRGB(70,180,110), row3, BTN_H)
local btnDel = mkBtn("Delete Part", Color3.fromRGB(230,70,70), row3, BTN_H)

local modal = Instance.new("Frame")
modal.Visible = false
modal.BackgroundColor3 = Color3.fromRGB(10,10,16)
modal.BackgroundTransparency = 0.45
modal.BorderSizePixel = 0
modal.Size = UDim2.new(1,0,1,0)
modal.Position = UDim2.new(0,0,0,0)
modal.Parent = win
modal.ZIndex = 50

local renBox = Instance.new("Frame")
renBox.Size = UDim2.new(0,340,0,120)
renBox.Position = UDim2.new(0.5,-170,0.5,-60)
renBox.BackgroundColor3 = Color3.fromRGB(24,24,34)
renBox.BorderSizePixel = 0
renBox.Parent = modal
renBox.ZIndex = 51

local rbCorner = Instance.new("UICorner")
rbCorner.CornerRadius = UDim.new(0,10)
rbCorner.Parent = renBox

local rbStroke = Instance.new("UIStroke")
rbStroke.Thickness = 2
rbStroke.Color = Color3.fromRGB(90,120,255)
rbStroke.Transparency = 0.3
rbStroke.Parent = renBox

local rbTitle = Instance.new("TextLabel")
rbTitle.BackgroundTransparency = 1
rbTitle.Text = "Rename Part"
rbTitle.Font = Enum.Font.GothamBold
rbTitle.TextSize = 15
rbTitle.TextColor3 = Color3.fromRGB(220,220,255)
rbTitle.Size = UDim2.new(1,-20,0,24)
rbTitle.Position = UDim2.new(0,10,0,8)
rbTitle.ZIndex = 51
rbTitle.Parent = renBox

local rbInput = Instance.new("TextBox")
rbInput.Size = UDim2.new(1,-20,0,32)
rbInput.Position = UDim2.new(0,10,0,40)
rbInput.Font = Enum.Font.Gotham
rbInput.TextSize = 14
rbInput.Text = ""
rbInput.ClearTextOnFocus = false
rbInput.TextColor3 = Color3.fromRGB(230,230,255)
rbInput.PlaceholderText = "Enter new name"
rbInput.BackgroundColor3 = Color3.fromRGB(34,34,46)
rbInput.BorderSizePixel = 0
rbInput.Parent = renBox
rbInput.ZIndex = 51
local rbInputCorner = Instance.new("UICorner")
rbInputCorner.CornerRadius = UDim.new(0,8)
rbInputCorner.Parent = rbInput

local rbRow = Instance.new("Frame")
rbRow.BackgroundTransparency = 1
rbRow.Size = UDim2.new(1,-20,0,32)
rbRow.Position = UDim2.new(0,10,1,-40)
rbRow.ZIndex = 51
rbRow.Parent = renBox

local rbGrid = Instance.new("UIGridLayout")
rbGrid.CellPadding = UDim2.new(0,8,0,0)
rbGrid.CellSize = UDim2.new(0.5,-4,1,0)
rbGrid.Parent = rbRow

local btnSave = mkBtn("Save", Color3.fromRGB(70,190,100), rbRow, 32)
btnSave.ZIndex = 51
local btnCancel = mkBtn("Cancel", Color3.fromRGB(90,90,140), rbRow, 32)
btnCancel.ZIndex = 51

local selObj = nil
local adorn = nil
local selOn = true
local minimized = false
local dragging = false
local dragInput = nil
local dragStart, startPos = nil, nil
local currentPath = nil

local uiScale = Instance.new("UIScale")
uiScale.Parent = win

local function instPath(o)
    local p = {}
    local function isSvc(x) return x.Parent == game and x ~= game end
    if not o then return "" end
    if isSvc(o) then
        table.insert(p, string.format('game:GetService("%s")', o.ClassName))
    else
        while o and o.Parent do
            local n = o.Name
            if n:match("^[%a_][%w_]*$") then
                table.insert(p, 1, "."..n)
            else
                table.insert(p, 1, string.format(':FindFirstChild("%s")', n:gsub('"','\\"')))
            end
            if isSvc(o.Parent) then
                table.insert(p, 1, string.format('game:GetService("%s")', o.Parent.ClassName))
                break
            end
            o = o.Parent
        end
    end
    return (table.concat(p):gsub("^%.",""))
end

local function setStatus(t, ok)
    lbl.Text = t
    local c = ok == nil and Color3.fromRGB(170,170,255) or (ok and Color3.fromRGB(100,255,120) or Color3.fromRGB(255,120,120))
    ts:Create(lbl, TweenInfo.new(0.12), {TextColor3 = c}):Play()
end

local function clearAdorn()
    if adorn then adorn:Destroy() adorn = nil end
end

local function showAdorn(pv)
    clearAdorn()
    local f = Instance.new("Folder")
    f.Name = "PGX_Adorn"
    local h = Instance.new("Highlight")
    h.Name = "PGX_Highlight"
    h.Adornee = pv
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = Color3.fromRGB(70,120,255)
    h.OutlineColor = Color3.fromRGB(140,170,255)
    h.FillTransparency = 0.35
    h.OutlineTransparency = 0
    h.Parent = f
    local sb = Instance.new("SelectionBox")
    sb.Name = "PGX_Select"
    sb.LineThickness = 0.05
    sb.Color3 = Color3.fromRGB(200,220,255)
    sb.Adornee = pv
    sb.Parent = f
    local bha = Instance.new("BoxHandleAdornment")
    bha.Name = "PGX_Box"
    bha.AlwaysOnTop = true
    bha.ZIndex = 10
    bha.Adornee = pv
    bha.Color3 = Color3.fromRGB(140,170,255)
    bha.Transparency = 0.85
    if pv:IsA("BasePart") then
        bha.Size = pv.Size
    end
    bha.Parent = f
    f.Parent = pv
    adorn = f
end

local function updCollBtn()
    if selObj and selObj:IsA("BasePart") then
        if selObj.CanCollide then
            btnColl.Text = "CanCollide: On"
            ts:Create(btnColl, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70,180,110)}):Play()
        else
            btnColl.Text = "CanCollide: Off"
            ts:Create(btnColl, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180,120,80)}):Play()
        end
    else
        btnColl.Text = "CanCollide: ?"
        ts:Create(btnColl, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(90,90,120)}):Play()
    end
end

local function setSel(p)
    selObj = p
    if p then
        currentPath = instPath(p)
        pathTxt.Text = currentPath
        setStatus("Part selected: "..p.Name, true)
        showAdorn(p)
        updCollBtn()
        ts:Create(pathFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36,36,50)}):Play()
    else
        currentPath = nil
        pathTxt.Text = "..."
        setStatus("No part selected", false)
        clearAdorn()
        updCollBtn()
        ts:Create(pathFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30,30,44)}):Play()
    end
end

local function onWin(p)
    local inset = gsv:GetGuiInset()
    local v = Vector2.new(p.X - inset.X, p.Y - inset.Y)
    local a = win.AbsolutePosition
    local s = win.AbsoluteSize
    return v.X >= a.X and v.X <= a.X + s.X and v.Y >= a.Y and v.Y <= a.Y + s.Y
end

local function raycastPick()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local pos = uis:GetMouseLocation()
    local ray = cam:ViewportPointToRay(pos.X, pos.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local excl = {}
    local ch = lp.Character
    if ch then table.insert(excl, ch) end
    params.FilterDescendantsInstances = excl
    params.IgnoreWater = false
    local res = workspace:Raycast(ray.Origin, ray.Direction * 10000, params)
    return res and res.Instance or nil
end

local function pick()
    if not selOn then return end
    if dragging then return end
    local pos = uis:GetMouseLocation()
    if onWin(pos) then return end
    local hit = raycastPick()
    if hit and hit:IsA("BasePart") then
        setSel(hit)
    else
        setSel(nil)
    end
end

local function bindPick()
    if mouseConn then mouseConn:Disconnect() mouseConn=nil end
    if tapConn then tapConn:Disconnect() tapConn=nil end
    local m = lp:GetMouse()
    mouseConn = track(m.Button1Down:Connect(pick))
    tapConn = track(uis.TouchTap:Connect(function(touches, processed)
        if processed then return end
        local p = touches and touches[1]
        if p and onWin(p) then return end
        pick()
    end))
end

local function showRen(d)
    rbInput.Text = d or ""
    modal.Visible = true
    renBox.Size = UDim2.new(0,300,0,96)
    ts:Create(modal, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    ts:Create(renBox, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,340,0,120)}):Play()
    rbInput:CaptureFocus()
end

local function hideRen()
    ts:Create(modal, TweenInfo.new(0.15), {BackgroundTransparency = 0.45}):Play()
    modal.Visible = false
end

local function baseSize()
    local bw = IsOnMobile and 390 or 420
    local bh = minimized and 56 or 300
    return bw, bh
end

local function beginDrag(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
    dragging = true
    dragStart = input.Position
    startPos = win.Position
    track(input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end))
end

local function updateDrag(input)
    if not dragging then return end
    local d = input.Position - dragStart
    win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end

tbBeganConn = track(top.InputBegan:Connect(function(i) beginDrag(i) end))
tbChangedConn = track(top.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragInput = i end end))
uisChangedConn = track(uis.InputChanged:Connect(function(i) if i == dragInput then updateDrag(i) end end))

local function applyScale()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280,720)
    local inset = gsv:GetGuiInset()
    local ux = math.max(0, vp.X - inset.X*2)
    local uy = math.max(0, vp.Y - inset.Y*2)
    local bw, bh = baseSize()
    local sc = math.min(ux/(bw+24), uy/(bh+60))
    local minScale = IsOnMobile and 0.75 or 0.6
    uiScale.Scale = math.clamp(sc, minScale, 1)
    win.Size = UDim2.new(0,bw,0,bh)
end

local function hookViewport()
    local function hookCam(c) if not c then return end track(c:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)) end
    track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() hookCam(workspace.CurrentCamera) applyScale() end))
    if workspace.CurrentCamera then hookCam(workspace.CurrentCamera) end
    track(sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyScale))
end

btnMin.MouseButton1Click:Connect(function()
    minimized = not minimized
    local bw, bh = baseSize()
    if minimized then
        local tw = ts:Create(win, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0,bw,0,bh)})
        tw.Completed:Connect(function() body.Visible = false end)
        tw:Play()
        btnMin.Text = "+"
    else
        body.Visible = true
        ts:Create(win, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0,bw,0,bh)}):Play()
        btnMin.Text = "-"
    end
end)

btnExit.MouseButton1Click:Connect(function()
    selOn = false
    selObj = nil
    clearAdorn()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Highlight") and v.Name == "PGX_Highlight" then v:Destroy() end
        if v:IsA("SelectionBox") and v.Name == "PGX_Select" then v:Destroy() end
        if v:IsA("BoxHandleAdornment") and v.Name == "PGX_Box" then v:Destroy() end
    end
    discAll()
    if sg then sg:Destroy() end
    getgenv().prtGrabLoaded = false
end)

btnCopy.MouseButton1Click:Connect(function()
    if currentPath and setclipboard then
        setclipboard(currentPath)
        setStatus("Path copied", true)
        task.wait(0.22)
    else
        setStatus("No part to copy", false)
    end
end)

btnToggle.MouseButton1Click:Connect(function()
    selOn = not selOn
    if selOn then
        btnToggle.Text = "Selection: On"
        ts:Create(btnToggle, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(90,140,220)}):Play()
        setStatus("Selection enabled", true)
    else
        btnToggle.Text = "Selection: Off"
        ts:Create(btnToggle, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(120,90,140)}):Play()
        setStatus("Selection disabled", false)
    end
end)

btnDel.MouseButton1Click:Connect(function()
    if selObj then
        local ok, err = pcall(function() selObj:Destroy() end)
        if ok then
            setStatus("Part deleted", true)
            setSel(nil)
        else
            setStatus("Delete failed: "..tostring(err):sub(1,40), false)
        end
    else
        setStatus("No part selected to delete", false)
    end
end)

btnRen.MouseButton1Click:Connect(function()
    if selObj then
        showRen(selObj.Name)
    else
        setStatus("No part selected to rename", false)
    end
end)

btnSave.MouseButton1Click:Connect(function()
    if selObj and rbInput.Text ~= "" then
        selObj.Name = rbInput.Text
        setStatus("Renamed to "..rbInput.Text, true)
        pathTxt.Text = instPath(selObj)
        currentPath = pathTxt.Text
    end
    hideRen()
end)

btnCancel.MouseButton1Click:Connect(function()
    hideRen()
end)

btnBring.MouseButton1Click:Connect(function()
    if selObj and selObj:IsA("PVInstance") then
        local ch = lp.Character
        if ch and ch.PrimaryPart then
            local pivot = ch:GetPivot()
            local tgt = pivot * CFrame.new(0,0,-5)
            selObj:PivotTo(tgt)
            setStatus("Brought part in front", true)
        else
            local cam = workspace.CurrentCamera
            if cam then
                local tgt = cam.CFrame * CFrame.new(0,0,-8)
                selObj:PivotTo(tgt)
                setStatus("Brought part to camera", true)
            else
                setStatus("No pivot reference", false)
            end
        end
    else
        setStatus("No part selected to bring", false)
    end
end)

btnColl.MouseButton1Click:Connect(function()
    if selObj and selObj:IsA("BasePart") then
        selObj.CanCollide = not selObj.CanCollide
        if selObj.CanCollide then
            setStatus("CanCollide enabled", true)
        else
            setStatus("CanCollide disabled", true)
        end
        updCollBtn()
    else
        setStatus("No part selected or invalid", false)
    end
end)

local function bindRipples(b) end

for _, b in ipairs({btnCopy, btnToggle, btnDel, btnRen, btnBring, btnColl, btnExit, btnMin, btnSave, btnCancel}) do
    bindRipples(b)
end

win.BackgroundTransparency = 1
ts:Create(win, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
ts:Create(winStroke, TweenInfo.new(0.35), {Transparency = 0.3}):Play()
ts:Create(bodyStroke, TweenInfo.new(0.35), {Transparency = 0.6}):Play()
ts:Create(titleGrad, TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Rotation = 360}):Play()

local function hookViewport()
    local function hookCam(c) if not c then return end track(c:GetPropertyChangedSignal("ViewportSize"):Connect(applyScale)) end
    track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() hookCam(workspace.CurrentCamera) applyScale() end))
    if workspace.CurrentCamera then hookCam(workspace.CurrentCamera) end
    track(sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyScale))
end

hookViewport()
applyScale()
bindPick()