local function Svc(n)
    local g = game.GetService
    local rf = cloneref or function(v) return v end
    return rf(g(game, n))
end

local rq = request or http_request or (syn and syn.request) or function() end
local tw = Svc("TweenService")
local ui = Svc("UserInputService")
local hs = Svc("HttpService")
local rs = Svc("RunService")
local eng = "ScriptBlox"

local col = {
    bg = Color3.fromRGB(20,22,26),
    ac = Color3.fromRGB(30,144,255),
    sc = Color3.fromRGB(32,34,40),
    tx = Color3.fromRGB(255,255,255),
    td = Color3.fromRGB(186,192,205),
    su = Color3.fromRGB(52,211,153),
    wa = Color3.fromRGB(255,179,71),
    er = Color3.fromRGB(244,63,94)
}

local function Protect(g)
    if g:IsA("ScreenGui") then
        g.ZIndexBehavior = Enum.ZIndexBehavior.Global
        g.DisplayOrder = 999999999
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
    end
    local cg = Svc("CoreGui")
    local lp = Svc("Players").LocalPlayer
    local function NA(x,v)
        if x then
            if v then x[v] = "\0" x.Archivable = false else x.Name = "\0" x.Archivable = false end
        end
    end
    if gethui then NA(g) g.Parent = gethui()
    elseif cg and cg:FindFirstChild("RobloxGui") then NA(g) g.Parent = cg:FindFirstChild("RobloxGui")
    elseif cg then NA(g) g.Parent = cg
    elseif lp and lp:FindFirstChildWhichIsA("PlayerGui") then NA(g) g.Parent = lp:FindFirstChildWhichIsA("PlayerGui") g.ResetOnSpawn=false end
    return g
end

local sg = Instance.new("ScreenGui")
sg.Name = "SBX"
Protect(sg)

local fr = Instance.new("Frame")
fr.Size = UDim2.new(0, 580, 0, 500)
fr.Position = UDim2.new(0.5, -290, 0.5, -250)
fr.BackgroundColor3 = col.bg
fr.BorderSizePixel = 0
fr.Active = true
fr.ClipsDescendants = true
fr.Parent = sg

local frc = Instance.new("UICorner")
frc.CornerRadius = UDim.new(0, 14)
frc.Parent = fr

local fst = Instance.new("UIStroke")
fst.Thickness = 1
fst.Color = Color3.fromRGB(70,75,85)
fst.Transparency = 0.35
fst.Parent = fr

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 56)
top.BackgroundColor3 = col.sc
top.BorderSizePixel = 0
top.Parent = fr

local topc = Instance.new("UICorner")
topc.CornerRadius = UDim.new(0, 14)
topc.Parent = top

local tgrad = Instance.new("UIGradient")
tgrad.Color = ColorSequence.new(Color3.fromRGB(45,49,58), col.sc)
tgrad.Rotation = 90
tgrad.Parent = top
task.spawn(function()
    while top.Parent do
        tw:Create(tgrad, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {Offset = Vector2.new(0,0.07)}):Play()
        task.wait(1.8)
    end
end)

local ttl = Instance.new("TextLabel")
ttl.Size = UDim2.new(1, -260, 1, 0)
ttl.Position = UDim2.new(0, 16, 0, 0)
ttl.BackgroundTransparency = 1
ttl.Font = Enum.Font.GothamBold
ttl.Text = "Script Hub • by @ltseverydayyou"
ttl.TextColor3 = col.tx
ttl.TextSize = 18
ttl.TextXAlignment = Enum.TextXAlignment.Left
ttl.Parent = top

local tr = Instance.new("Frame")
tr.BackgroundTransparency = 1
tr.Size = UDim2.new(0, 0, 1, -12)
tr.Position = UDim2.new(1, -12, 0, 6)
tr.AnchorPoint = Vector2.new(1,0)
tr.AutomaticSize = Enum.AutomaticSize.X
tr.Parent = top

local trl = Instance.new("UIListLayout")
trl.FillDirection = Enum.FillDirection.Horizontal
trl.HorizontalAlignment = Enum.HorizontalAlignment.Right
trl.VerticalAlignment = Enum.VerticalAlignment.Center
trl.Padding = UDim.new(0, 8)
trl.Parent = tr

local engb = Instance.new("TextButton")
engb.Size = UDim2.new(0, 184, 1, 0)
engb.BackgroundColor3 = col.bg
engb.Text = "Engine: ScriptBlox"
engb.TextColor3 = col.tx
engb.TextSize = 14
engb.Font = Enum.Font.GothamSemibold
engb.AutoButtonColor = false
engb.Parent = tr

local engbc = Instance.new("UICorner")
engbc.CornerRadius = UDim.new(0, 8)
engbc.Parent = engb

local engbs = Instance.new("UIStroke")
engbs.Thickness = 1
engbs.Color = Color3.fromRGB(70,75,85)
engbs.Transparency = 0.25
engbs.Parent = engb

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 40, 1, 0)
mini.BackgroundColor3 = Color3.fromRGB(45,49,58)
mini.Text = "V"
mini.TextColor3 = col.tx
mini.TextScaled = true
mini.Font = Enum.Font.GothamBold
mini.AutoButtonColor = false
mini.Rotation = 0
mini.Parent = tr
local minic = Instance.new("UICorner"); minic.CornerRadius=UDim.new(0,8); minic.Parent=mini

local cls = Instance.new("TextButton")
cls.Size = UDim2.new(0, 40, 1, 0)
cls.BackgroundColor3 = Color3.fromRGB(45,49,58)
cls.Text = "X"
cls.TextColor3 = col.tx
cls.TextScaled = true
cls.Font = Enum.Font.GothamBold
cls.AutoButtonColor = false
cls.Parent = tr
local clsc = Instance.new("UICorner"); clsc.CornerRadius=UDim.new(0,8); clsc.Parent=cls

local sr = Instance.new("Frame")
sr.Size = UDim2.new(1, -32, 0, 64)
sr.Position = UDim2.new(0, 16, 0, 72)
sr.BackgroundColor3 = col.sc
sr.BorderSizePixel = 0
sr.Parent = fr

local src = Instance.new("UICorner")
src.CornerRadius = UDim.new(0, 12)
src.Parent = sr

local srs = Instance.new("UIStroke")
srs.Thickness = 1
srs.Color = Color3.fromRGB(70,75,85)
srs.Transparency = 0.25
srs.Parent = sr

local sPad = Instance.new("UIPadding")
sPad.PaddingLeft = UDim.new(0, 12)
sPad.PaddingRight = UDim.new(0, 12)
sPad.Parent = sr

local sLbl = Instance.new("TextLabel")
sLbl.Size = UDim2.new(0, 32, 1, 0)
sLbl.BackgroundTransparency = 1
sLbl.Font = Enum.Font.GothamBold
sLbl.Text = "🔎"
sLbl.TextColor3 = col.td
sLbl.TextScaled = true
sLbl.Parent = sr

local sbox = Instance.new("TextBox")
sbox.Size = UDim2.new(1, -260, 1, -16)
sbox.Position = UDim2.new(0, 40, 0, 8)
sbox.BackgroundTransparency = 1
sbox.Font = Enum.Font.Gotham
sbox.PlaceholderText = "Search for scripts…"
sbox.Text = ""
sbox.TextColor3 = col.tx
sbox.PlaceholderColor3 = Color3.fromRGB(140,146,160)
sbox.TextSize = 16
sbox.TextXAlignment = Enum.TextXAlignment.Left
sbox.ClearTextOnFocus = false
sbox.Parent = sr

local go = Instance.new("TextButton")
go.Size = UDim2.new(0, 148, 0, 40)
go.Position = UDim2.new(1, -160, 0.5, -20)
go.BackgroundColor3 = col.ac
go.BorderSizePixel = 0
go.Font = Enum.Font.GothamSemibold
go.Text = "Search"
go.TextColor3 = col.tx
go.TextSize = 16
go.AutoButtonColor = false
go.Parent = sr

local goc = Instance.new("UICorner")
goc.CornerRadius = UDim.new(0, 10)
goc.Parent = go

local goGrad = Instance.new("UIGradient")
goGrad.Color = ColorSequence.new(col.ac, Color3.fromRGB(58,160,255))
goGrad.Rotation = 0
goGrad.Offset = Vector2.new(-1,0)
goGrad.Parent = go
task.spawn(function()
    while go.Parent do
        tw:Create(goGrad, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(1,0)}):Play()
        task.wait(2.2)
        goGrad.Offset = Vector2.new(-1,0)
    end
end)

local ub = Instance.new("Frame")
ub.AnchorPoint = Vector2.new(0,1)
ub.Position = UDim2.new(0, 12, 1, -6)
ub.Size = UDim2.new(0, 0, 0, 2)
ub.BackgroundColor3 = col.ac
ub.BorderSizePixel = 0
ub.Parent = sr

local sp = Instance.new("TextLabel")
sp.Size = UDim2.new(0, 30, 0, 30)
sp.Position = UDim2.new(1, -200, 0.5, -15)
sp.BackgroundTransparency = 1
sp.Font = Enum.Font.Code
sp.Text = ""
sp.TextColor3 = col.tx
sp.TextScaled = true
sp.ZIndex = 2
sp.Parent = sr

local rc = Instance.new("Frame")
rc.Size = UDim2.new(1, -32, 1, -152)
rc.Position = UDim2.new(0, 16, 0, 144)
rc.BackgroundColor3 = col.sc
rc.BorderSizePixel = 0
rc.Parent = fr

local rcc = Instance.new("UICorner")
rcc.CornerRadius = UDim.new(0, 12)
rcc.Parent = rc

local rcs = Instance.new("UIStroke")
rcs.Color = Color3.fromRGB(70,75,85)
rcs.Transparency = 0.3
rcs.Thickness = 1
rcs.Parent = rc

local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, -16, 1, -16)
sf.Position = UDim2.new(0, 8, 0, 8)
sf.BackgroundTransparency = 1
sf.BorderSizePixel = 0
sf.ScrollBarThickness = 6
sf.ScrollBarImageColor3 = col.ac
sf.CanvasSize = UDim2.new(0, 0, 0, 0)
sf.Parent = rc

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 10)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = sf

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.PaddingLeft = UDim.new(0, 2)
pad.PaddingRight = UDim.new(0, 2)
pad.PaddingBottom = UDim.new(0, 8)
pad.Parent = sf

local tn = Instance.new("Frame")
tn.AnchorPoint = Vector2.new(1,0)
tn.BackgroundTransparency = 1
tn.Size = UDim2.new(0, 320, 1, 0)
tn.Position = UDim2.new(1, -16, 0, 72)
tn.ZIndex = 10
tn.Parent = fr

local tnl = Instance.new("UIListLayout")
tnl.VerticalAlignment = Enum.VerticalAlignment.Top
tnl.HorizontalAlignment = Enum.HorizontalAlignment.Right
tnl.Padding = UDim.new(0, 8)
tnl.Parent = tn

local function btnAnim(b, baseCol, hoverCol)
    local base = b.Size
    local hover = UDim2.new(base.X.Scale, base.X.Offset+4, base.Y.Scale, base.Y.Offset+2)
    local press = UDim2.new(base.X.Scale, base.X.Offset-2, base.Y.Scale, base.Y.Offset-1)
    local hovering = false
    b.MouseEnter:Connect(function()
        hovering = true
        tw:Create(b, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = hoverCol, Size = hover}):Play()
    end)
    b.MouseLeave:Connect(function()
        hovering = false
        tw:Create(b, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = baseCol, Size = base}):Play()
    end)
    b.MouseButton1Down:Connect(function()
        tw:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = press}):Play()
    end)
    b.MouseButton1Up:Connect(function()
        tw:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = hovering and hover or base}):Play()
    end)
end
btnAnim(engb, col.bg, Color3.fromRGB(45,49,58))
btnAnim(go, col.ac, Color3.fromRGB(58,160,255))
btnAnim(mini, mini.BackgroundColor3, Color3.fromRGB(60,64,72))
btnAnim(cls, cls.BackgroundColor3, Color3.fromRGB(72,24,32))

local function sizeCanvas()
    sf.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 12)
end
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(sizeCanvas)

local function clearAll(anim)
    for _,v in ipairs(sf:GetChildren()) do
        if v:IsA("Frame") and (v.Name:find("^Card") or v.Name=="Msg" or v.Name=="Skel") then
            if anim then
                tw:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = v.Position + UDim2.new(0,0,0,6)}):Play()
                task.delay(0.2, function() if v then v:Destroy() end end)
            else
                v:Destroy()
            end
        end
    end
    sizeCanvas()
end

local function toast(txt, colr)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 300, 0, 44)
    f.BackgroundColor3 = col.sc
    f.BorderSizePixel = 0
    f.ZIndex = 11
    f.Parent = tn
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 10); fc.Parent = f
    local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(80,85,95); fs.Transparency = 0.35; fs.Thickness = 1; fs.Parent = f
    local lb = Instance.new("TextLabel")
    lb.BackgroundTransparency = 1
    lb.Text = txt
    lb.TextWrapped = true
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Font = Enum.Font.Gotham
    lb.TextSize = 14
    lb.TextColor3 = colr or col.tx
    lb.Size = UDim2.new(1, -24, 1, 0)
    lb.Position = UDim2.new(0, 12, 0, 0)
    lb.ZIndex = 12
    lb.Parent = f
    f.AnchorPoint = Vector2.new(1,0)
    f.Position = UDim2.new(1, 24, 0, 0)
    f.BackgroundTransparency = 1
    lb.TextTransparency = 1
    tw:Create(f, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 0}):Play()
    tw:Create(lb, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    task.delay(2.2, function()
        tw:Create(f, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 24, 0, 0), BackgroundTransparency = 1}):Play()
        task.delay(0.24, function() if f then f:Destroy() end end)
    end)
end

local spConn
local spFrames = {"⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"}
local function spin(on)
    if on then
        if spConn then return end
        sp.Text = spFrames[1]
        ub.Size = UDim2.new(0, 0, 0, 2)
        tw:Create(ub, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {Size = UDim2.new(1, -24, 0, 2)}):Play()
        local i,acc = 1,0
        spConn = rs.RenderStepped:Connect(function(dt)
            acc += dt
            if acc > 0.08 then
                acc = 0
                i = (i % #spFrames)+1
                sp.Text = spFrames[i]
            end
        end)
    else
        if spConn then spConn:Disconnect() spConn=nil end
        sp.Text = ""
        tw:Create(ub, TweenInfo.new(0.15), {Size = UDim2.new(0, 0, 0, 2)}):Play()
    end
end

local function skeleton(n)
    for i=1,n do
        local s = Instance.new("Frame")
        s.Name = "Skel"
        s.Size = UDim2.new(1, -8, 0, 120)
        s.BackgroundColor3 = Color3.fromRGB(40,44,52)
        s.BorderSizePixel = 0
        s.Parent = sf
        local sc = Instance.new("UICorner"); sc.CornerRadius=UDim.new(0,10); sc.Parent=s
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new(Color3.fromRGB(50,54,62), Color3.fromRGB(60,64,72), Color3.fromRGB(50,54,62))
        g.Rotation = 0
        g.Offset = Vector2.new(-1,0)
        g.Parent = s
        tw:Create(g, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {Offset = Vector2.new(1,0)}):Play()
    end
    sizeCanvas()
end

local function mkMsg(txt, bg)
    local el = Instance.new("Frame")
    el.Name = "Msg"
    el.Size = UDim2.new(1, -8, 0, 52)
    el.BackgroundColor3 = bg
    el.BackgroundTransparency = 0.15
    el.Parent = sf
    local elc = Instance.new("UICorner"); elc.CornerRadius = UDim.new(0,8); elc.Parent = el
    local lb = Instance.new("TextLabel")
    lb.BackgroundTransparency = 1
    lb.Size = UDim2.new(1, -20, 1, 0)
    lb.Position = UDim2.new(0, 10, 0, 0)
    lb.Font = Enum.Font.Gotham
    lb.Text = txt
    lb.TextSize = 14
    lb.TextColor3 = col.tx
    lb.Parent = el
    local sc = Instance.new("UIScale"); sc.Scale=0.96; sc.Parent=el
    el.BackgroundTransparency = 1
    lb.TextTransparency = 1
    tw:Create(el, TweenInfo.new(0.18), {BackgroundTransparency = 0.15}):Play()
    tw:Create(lb, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
    tw:Create(sc, TweenInfo.new(0.18), {Scale = 1}):Play()
    sizeCanvas()
end

local minimized = false
local fullS = UDim2.new(0, 580, 0, 500)
local miniS = UDim2.new(0, 580, 0, 56)

local function setMin(s)
    minimized = s
    if minimized then
        tw:Create(fr, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = miniS}):Play()
        tw:Create(mini, TweenInfo.new(0.2), {Rotation = 180}):Play()
        tw:Create(rc, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        tw:Create(sr, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    else
        tw:Create(fr, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = fullS}):Play()
        tw:Create(mini, TweenInfo.new(0.2), {Rotation = 0}):Play()
        tw:Create(rc, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
        tw:Create(sr, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
    end
end

mini.MouseButton1Click:Connect(function()
    setMin(not minimized)
end)

cls.MouseButton1Click:Connect(function()
    tw:Create(fr, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, Size = fr.Size - UDim2.new(0,12,0,12)}):Play()
    task.delay(0.2, function() sg:Destroy() end)
end)

sbox.Focused:Connect(function()
    tw:Create(sLbl, TweenInfo.new(0.15), {TextColor3 = col.ac}):Play()
    tw:Create(srs, TweenInfo.new(0.15), {Transparency = 0.1}):Play()
end)

sbox.FocusLost:Connect(function()
    tw:Create(sLbl, TweenInfo.new(0.2), {TextColor3 = col.td}):Play()
    tw:Create(srs, TweenInfo.new(0.2), {Transparency = 0.25}):Play()
end)

local function mkCard(i, d)
    local t = d.title
    local rw = (eng == "ScriptBlox") and d.script or d.rawScript
    local v = d.views
    local k = (eng == "ScriptBlox") and d.key or d.keySystem

    local c = Instance.new("Frame")
    c.Name = "Card"..i
    c.Size = UDim2.new(1, -8, 0, 134)
    c.BackgroundColor3 = col.bg
    c.BorderSizePixel = 0
    c.Parent = sf

    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 10)
    cc.Parent = c

    local cs = Instance.new("UIStroke")
    cs.Color = Color3.fromRGB(70,75,85)
    cs.Transparency = 0.35
    cs.Thickness = 1
    cs.Parent = c

    c.MouseEnter:Connect(function() tw:Create(cs, TweenInfo.new(0.12), {Transparency = 0.15}):Play() end)
    c.MouseLeave:Connect(function() tw:Create(cs, TweenInfo.new(0.12), {Transparency = 0.35}):Play() end)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -20, 0, 32)
    tl.Position = UDim2.new(0, 12, 0, 10)
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.Text = tostring(t)
    tl.TextColor3 = col.tx
    tl.TextSize = 15
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.TextWrapped = true
    tl.Parent = c

    local inf = Instance.new("TextLabel")
    inf.Size = UDim2.new(1, -20, 0, 40)
    inf.Position = UDim2.new(0, 12, 0, 46)
    inf.BackgroundTransparency = 1
    inf.Font = Enum.Font.Gotham
    if eng == "ScriptBlox" then
        inf.Text = "🌐 "..(d.isUniversal and "Universal" or "Game-Specific").."   •   🔑 "..((d.key and "Key") or "No Key").."\n🛠️ "..((d.isPatched and "Patched") or "Working").."   •   👁️ "..tostring(v)
    else
        local dc = d.discord or "N/A"
        inf.Text = "🔑 "..((k and "Key") or "No Key").."   •   👁️ "..tostring(v).."\n💬 "..dc.."   •   📱 "..((d.mobileReady and "Mobile") or "PC Only")
    end
    inf.TextColor3 = col.td
    inf.TextSize = 12
    inf.TextXAlignment = Enum.TextXAlignment.Left
    inf.Parent = c

    local row = Instance.new("Frame")
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, -24, 0, 40)
    row.Position = UDim2.new(0, 12, 1, -50)
    row.Parent = c

    local rl = Instance.new("UIListLayout")
    rl.FillDirection = Enum.FillDirection.Horizontal
    rl.Padding = UDim.new(0, 10)
    rl.SortOrder = Enum.SortOrder.LayoutOrder
    rl.Parent = row

    local function mkB(txt, bg)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 120, 1, 0)
        b.BackgroundColor3 = bg
        b.Text = txt
        b.TextColor3 = col.tx
        b.TextSize = 14
        b.Font = Enum.Font.GothamSemibold
        b.AutoButtonColor = false
        b.Parent = row
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 8); bc.Parent = b
        btnAnim(b, bg, bg:Lerp(Color3.new(1,1,1), 0.12))
        return b
    end

    local ex = mkB("▶ Run", col.su)
    local cp = setclipboard and mkB("📋 Copy", Color3.fromRGB(57,63,75)) or nil
    local dc = (d.discord and setclipboard) and mkB("💬 Discord", Color3.fromRGB(28,116,224)) or nil

    ex.MouseButton1Click:Connect(function()
        pcall(function()
            if eng == "ScriptBlox" then loadstring(rw)() else loadstring(game:HttpGet(rw))() end
        end)
        toast("Executed script", col.tx)
    end)

    if cp then
        cp.MouseButton1Click:Connect(function()
            pcall(function()
                if eng == "ScriptBlox" then setclipboard(rw) else setclipboard(game:HttpGet(rw)) end
            end)
            cp.Text = "✅ Copied"
            tw:Create(cp, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(76,82,96)}):Play()
            task.delay(0.9, function()
                cp.Text = "📋 Copy"
                tw:Create(cp, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(57,63,75)}):Play()
            end)
        end)
    end

    if dc then
        dc.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(d.discord) end)
            dc.Text = "✅ Copied"
            task.delay(0.9, function() dc.Text = "💬 Discord" end)
        end)
    end

    local sca = Instance.new("UIScale")
    sca.Scale = 0.95
    sca.Parent = c
    c.BackgroundTransparency = 1
    c.Position = UDim2.new(c.Position.X.Scale, c.Position.X.Offset, 0, 6)
    tl.TextTransparency = 1
    inf.TextTransparency = 1
    tw:Create(c, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0, Position = UDim2.new(c.Position.X.Scale, c.Position.X.Offset, 0, 0)}):Play()
    tw:Create(sca, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
    tw:Create(tl, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
    tw:Create(inf, TweenInfo.new(0.18), {TextTransparency = 0}):Play()
end

local searching = false

local function fetch(q, empty)
    if searching then return end
    searching = true
    clearAll(true)
    skeleton(4)
    spin(true)
    go.Text = "Searching…"
    go.Active = false
    local u = (eng == "ScriptBlox") and ("https://scriptblox.com/api/script/search?q="..q) or ("https://rscripts.net/api/v2/scripts?page=1&orderBy=date&sort=desc&q="..q)
    if empty and eng == "ScriptBlox" then u = "https://www.scriptblox.com/api/script/fetch" end
    local ok, res = pcall(function() return rq({Url = u, Method = "GET"}) end)
    clearAll(false)
    if not ok or not res or not res.Body then
        mkMsg("Request failed", col.er)
        spin(false) go.Text="Search" go.Active=true searching=false sizeCanvas() return
    end
    local ok2, dec = pcall(function() return hs:JSONDecode(res.Body) end)
    if not ok2 or not dec then
        mkMsg("Invalid response", col.er)
        spin(false) go.Text="Search" go.Active=true searching=false sizeCanvas() return
    end
    local data = (eng == "ScriptBlox") and dec.result and dec.result.scripts or dec.scripts
    if not data or #data == 0 then
        mkMsg("No scripts found", col.wa)
        spin(false) go.Text="Search" go.Active=true searching=false sizeCanvas() return
    end
    for i,d in ipairs(data) do
        mkCard(i, d)
        task.wait(0.02)
    end
    spin(false)
    go.Text = "Search"
    go.Active = true
    searching = false
    sizeCanvas()
end

engb.MouseButton1Click:Connect(function()
    if eng == "ScriptBlox" then
        eng = "RScripts"
        engb.Text = "Engine: RScripts"
        sbox.PlaceholderText = "Search for scripts (rscripts.net)"
        tw:Create(engb, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(45,49,58)}):Play()
        toast("Switched to RScripts", col.tx)
    else
        eng = "ScriptBlox"
        engb.Text = "Engine: ScriptBlox"
        sbox.PlaceholderText = "Search for scripts (scriptblox.com)"
        tw:Create(engb, TweenInfo.new(0.18), {BackgroundColor3 = col.bg}):Play()
        toast("Switched to ScriptBlox", col.tx)
    end
end)

go.MouseButton1Click:Connect(function()
    if searching then return end
    local q = sbox.Text:gsub(" ", "%%20")
    if q ~= "" then
        fetch(q)
    else
        if eng == "ScriptBlox" then
            fetch(q, true)
        else
            clearAll(true)
            mkMsg("Please enter a search query", col.wa)
            sizeCanvas()
        end
    end
end)

local drag, dIn, dStart, start
local function up(i)
    local d = i.Position - dStart
    fr.Position = UDim2.new(start.X.Scale, start.X.Offset + d.X, start.Y.Scale, start.Y.Offset + d.Y)
end
top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dStart = i.Position
        start = fr.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then drag = false end
        end)
    end
end)
top.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dIn = i end
end)
ui.InputChanged:Connect(function(i)
    if i == dIn and drag then up(i) end
end)

local openS = Instance.new("UIScale")
openS.Scale = 0.9
openS.Parent = fr
fr.BackgroundTransparency = 1
tw:Create(openS, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
tw:Create(fr, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()