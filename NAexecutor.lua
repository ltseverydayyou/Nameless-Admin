local e = Instance.new("ScreenGui")
local m = Instance.new("Frame")
local c1 = Instance.new("UICorner")
local tb = Instance.new("Frame")
local c6 = Instance.new("UICorner")
local tt = Instance.new("TextLabel")
local xt = Instance.new("TextButton")
local mn = Instance.new("TextButton")
local d = Instance.new("Frame")
local c2 = Instance.new("UICorner")
local s = Instance.new("ScrollingFrame")
local ln = Instance.new("TextLabel")
local hl = Instance.new("TextLabel")
local t = Instance.new("TextBox")
local bf = Instance.new("Frame")
local gl = Instance.new("UIGridLayout")
local ex = Instance.new("TextButton")
local cl = Instance.new("TextButton")
local cp = Instance.new("TextButton")
local sb = Instance.new("TextLabel")

local function S(n)
	return (cloneref and cloneref(game:GetService(n))) or game:GetService(n)
end

local ts = S("TweenService")
local uis = S("UserInputService")

local function protectUI(gui)
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.DisplayOrder = 999999999
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	local cg = S("CoreGui")
	local lp = S("Players").LocalPlayer
	local function p(i, v)
		if not i then return end
		if v then i[v] = "\0" else i.Name = "\0" end
		i.Archivable = false
	end
	if cg and cg:FindFirstChild("RobloxGui") then
		p(gui); gui.Parent = cg.RobloxGui; return gui
	elseif cg then
		p(gui); gui.Parent = cg; return gui
	elseif lp and lp:FindFirstChild("PlayerGui") then
		p(gui); gui.Parent = lp.PlayerGui; return gui
	end
end

e.Name = "AdvExec"
protectUI(e)

m.Name = "Main"
m.Parent = e
m.Active = true
m.BackgroundColor3 = Color3.fromRGB(22, 23, 33)
m.ClipsDescendants = true
m.AnchorPoint = Vector2.new(0.5, 0.5)
m.Position = UDim2.fromScale(0.5, 0.5)
m.Size = UDim2.new(0, 560, 0, 400)
c1.CornerRadius = UDim.new(0, 12)
c1.Parent = m

local sc = Instance.new("UIScale", m)
sc.Scale = 0.9
ts:Create(sc, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()

tb.Name = "TopBar"
tb.Parent = m
tb.BackgroundColor3 = Color3.fromRGB(28, 30, 42)
tb.BorderSizePixel = 0
tb.Size = UDim2.new(1, 0, 0, 44)
c6.CornerRadius = UDim.new(0, 12)
c6.Parent = tb

tt.Name = "Title"
tt.Parent = tb
tt.BackgroundTransparency = 1
tt.Position = UDim2.new(0, 16, 0, 0)
tt.Size = UDim2.new(1, -120, 1, 0)
tt.Font = Enum.Font.GothamBold
tt.Text = "Executor"
tt.TextColor3 = Color3.fromRGB(235, 238, 255)
tt.TextSize = 20
tt.TextXAlignment = Enum.TextXAlignment.Left

xt.Name = "Exit"
xt.Parent = tb
xt.BackgroundTransparency = 1
xt.Position = UDim2.new(1, -44, 0, 0)
xt.Size = UDim2.new(0, 44, 1, 0)
xt.Font = Enum.Font.GothamBold
xt.Text = "X"
xt.TextColor3 = Color3.fromRGB(255, 110, 110)
xt.TextSize = 18

mn.Name = "Min"
mn.Parent = tb
mn.BackgroundTransparency = 1
mn.Position = UDim2.new(1, -88, 0, 0)
mn.Size = UDim2.new(0, 44, 1, 0)
mn.Font = Enum.Font.GothamBold
mn.Text = "V"
mn.Rotation = 0
mn.TextColor3 = Color3.fromRGB(140, 160, 255)
mn.TextSize = 18

d.Name = "Sep"
d.Parent = m
d.BackgroundColor3 = Color3.fromRGB(32, 34, 48)
d.Position = UDim2.new(0, 0, 0, 44)
d.Size = UDim2.new(1, 0, 0, 2)
c2.CornerRadius = UDim.new(0, 1)
c2.Parent = d

s.Name = "Scroll"
s.Parent = m
s.Active = true
s.BackgroundColor3 = Color3.fromRGB(26, 27, 39)
s.BorderSizePixel = 0
s.Position = UDim2.new(0, 12, 0, 56)
s.Size = UDim2.new(1, -24, 0, 268)
s.ScrollBarThickness = 6
s.ScrollBarImageColor3 = Color3.fromRGB(110, 115, 180)
s.CanvasSize = UDim2.new(0, 0, 0, 0)
s.ScrollingDirection = Enum.ScrollingDirection.XY
s.ClipsDescendants = true

ln.Name = "LineNum"
ln.Parent = s
ln.BackgroundColor3 = Color3.fromRGB(24, 25, 36)
ln.BorderSizePixel = 0
ln.Position = UDim2.new(0, 0, 0, 0)
ln.Size = UDim2.new(0, 40, 0, 268)
ln.Font = Enum.Font.Code
ln.Text = "1"
ln.TextColor3 = Color3.fromRGB(120, 125, 155)
ln.TextSize = 16
ln.TextXAlignment = Enum.TextXAlignment.Right
ln.TextYAlignment = Enum.TextYAlignment.Top
ln.RichText = true

hl.Name = "HL"
hl.Parent = s
hl.BackgroundTransparency = 1
hl.Position = UDim2.new(0, 46, 0, 0)
hl.Size = UDim2.new(1, -52, 0, 268)
hl.Font = Enum.Font.Code
hl.Text = ""
hl.TextColor3 = Color3.fromRGB(255, 255, 255)
hl.TextSize = 16
hl.TextXAlignment = Enum.TextXAlignment.Left
hl.TextYAlignment = Enum.TextYAlignment.Top
hl.RichText = true
hl.ZIndex = 1

t.Name = "Text"
t.Parent = s
t.BackgroundTransparency = 1
t.BorderSizePixel = 0
t.Position = UDim2.new(0, 46, 0, 0)
t.Size = UDim2.new(1, -52, 0, 268)
t.ClearTextOnFocus = false
t.Font = Enum.Font.Code
t.MultiLine = true
t.PlaceholderText = "-- Script here"
t.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
t.Text = ""
t.TextColor3 = Color3.fromRGB(255, 255, 255)
t.TextSize = 16
t.TextXAlignment = Enum.TextXAlignment.Left
t.TextYAlignment = Enum.TextYAlignment.Top
t.TextWrapped = false
t.TextTransparency = 1
t.ZIndex = 2

bf.Name = "Buttons"
bf.Parent = m
bf.BackgroundTransparency = 1
bf.Position = UDim2.new(0, 12, 1, -72)
bf.Size = UDim2.new(1, -24, 0, 48)

gl.Parent = bf
gl.SortOrder = Enum.SortOrder.LayoutOrder
gl.CellPadding = UDim2.new(0, 10, 0, 0)
gl.CellSize = UDim2.new(0.333, -8, 1, 0)
gl.FillDirectionMaxCells = 3

local function styleBtn(b, txt, bg, fg)
	b.Name = txt
	b.Parent = bf
	b.Text = txt
	b.BackgroundColor3 = bg
	b.TextColor3 = fg
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 16
	local c = Instance.new("UICorner", b)
	c.CornerRadius = UDim.new(0, 10)
	local st = Instance.new("UIStroke", b)
	st.Thickness = 1
	st.Color = Color3.fromRGB(60, 65, 95)
	local scl = Instance.new("UIScale", b)
	b.MouseEnter:Connect(function()
		ts:Create(scl, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.03}):Play()
		ts:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.05)}):Play()
	end)
	b.MouseLeave:Connect(function()
		ts:Create(scl, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
		ts:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = bg}):Play()
	end)
	b.MouseButton1Down:Connect(function()
		ts:Create(scl, TweenInfo.new(0.06), {Scale = 0.97}):Play()
	end)
	b.MouseButton1Up:Connect(function()
		ts:Create(scl, TweenInfo.new(0.1), {Scale = 1.03}):Play()
	end)
end

styleBtn(ex, "Execute", Color3.fromRGB(68, 128, 255), Color3.fromRGB(255, 255, 255))
styleBtn(cl, "Clear", Color3.fromRGB(52, 58, 84), Color3.fromRGB(230, 235, 255))
styleBtn(cp, "Copy", Color3.fromRGB(52, 58, 84), Color3.fromRGB(230, 235, 255))

sb.Name = "Status"
sb.Parent = m
sb.BackgroundTransparency = 1
sb.Position = UDim2.new(0, 14, 1, -22)
sb.Size = UDim2.new(1, -28, 0, 18)
sb.Font = Enum.Font.Gotham
sb.Text = "Ready"
sb.TextColor3 = Color3.fromRGB(110, 245, 140)
sb.TextSize = 14
sb.TextXAlignment = Enum.TextXAlignment.Left

local dragging = false
local dragInput, dragStart, startPos

local function update(i)
	local d = i.Position - dragStart
	m.Position = UDim2.new(
		startPos.X.Scale, startPos.X.Offset + d.X,
		startPos.Y.Scale, startPos.Y.Offset + d.Y
	)
end

tb.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = i.Position
		startPos = m.Position
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

tb.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		dragInput = i
	end
end)

uis.InputChanged:Connect(function(i)
	if dragging and i == dragInput then
		update(i)
	end
end)

local function esc(x)
	x = x:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;")
	return x
end

local kw = {
	"and","break","do","else","elseif","end","false","for","function",
	"goto","if","in","local","nil","not","or","repeat","return","then","true","until","while"
}
local bi = {
	"self","pairs","ipairs","pcall","xpcall","type","next","assert","error","warn",
	"string","table","math","debug","coroutine","os","utf8",
	"game","workspace","script","Enum","Color3","Vector3","UDim2","CFrame","Instance","task","tick","time","wait","spawn"
}

local function colorize(txt)
	local E = esc(txt)
	local ph, n = {}, 0
	local function keep(s)
		n += 1
		ph[n] = s
		return "\1PH" .. n .. "\2"
	end
	E = E:gsub("%-%-%[%[[%s%S]-%]%]", function(s) return keep('<font color="#8B949E">'..s..'</font>') end)
	E = E:gsub("%-%-[^\n]*", function(s) return keep('<font color="#8B949E">'..s..'</font>') end)
	E = E:gsub("%[%[[%s%S]-%]%]", function(s) return keep('<font color="#A3E635">'..s..'</font>') end)
	E = E:gsub('"(.-)"', function(s) return keep('<font color="#A3E635">"'..s..'"</font>') end)
	E = E:gsub("'(.-)'", function(s) return keep('<font color="#A3E635">\''..s..'\'</font>') end)
	E = E:gsub("(%f[%w_]%d[%d%.eE]*%f[^%w_])", '<font color="#60A5FA">%1</font>')
	for _, w in ipairs(kw) do
		E = E:gsub("%f[%w_]"..w.."%f[^%w_]", '<font color="#F472B6">'..w..'</font>')
	end
	for _, w in ipairs(bi) do
		E = E:gsub("%f[%w_]"..w.."%f[^%w_]", '<font color="#F59E0B">'..w..'</font>')
	end
	E = E:gsub("\1PH(%d+)\2", function(i) return ph[tonumber(i)] or "" end)
	return E
end

local tsrv = S("TextService")
local function lineHeight()
	return tsrv:GetTextSize("A", t.TextSize, t.Font, Vector2.new(1e5, 1e5)).Y
end

local function updateLines()
	local txt = t.Text
	if txt == "" then txt = " " end
	local h = lineHeight()
	local c = 1
	for _ in txt:gmatch("\n") do c += 1 end
	local buf = {}
	for i = 1, c do buf[#buf+1] = tostring(i) end
	ln.Text = table.concat(buf, "\n")
	local widest = 0
	for line in (t.Text.."\n"):gmatch("(.-)\n") do
		local sz = tsrv:GetTextSize(line, t.TextSize, t.Font, Vector2.new(1e6, 1e6))
		if sz.X > widest then widest = sz.X end
	end
	local pad = 12
	local tgtH = math.max(268, c * h + pad)
	local tgtW = math.max(s.AbsoluteSize.X - 52, widest + 6)
	hl.Size = UDim2.new(0, tgtW, 0, tgtH)
	t.Size = UDim2.new(0, tgtW, 0, tgtH)
	ln.Size = UDim2.new(0, 40, 0, tgtH)
	s.CanvasSize = UDim2.new(0, 46 + tgtW + 6, 0, tgtH)
end

local function updateHL()
	hl.Text = colorize(t.Text)
	updateLines()
end

t:GetPropertyChangedSignal("Text"):Connect(updateHL)
updateHL()

uis.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.Tab and t:IsFocused() then
		local pos = t.CursorPosition
		if pos <= 0 then return end
		local tx = t.Text
		local pre = tx:sub(1, pos - 1)
		local suf = tx:sub(pos)
		t.Text = pre .. "    " .. suf
		t.CursorPosition = pos + 4
	end
end)

local busy = false
local function setStatus(msg, col, dur)
	sb.Text = msg
	sb.TextColor3 = col
	if dur then
		task.spawn(function()
			task.wait(dur)
			sb.Text = "Ready"
			sb.TextColor3 = Color3.fromRGB(110, 245, 140)
		end)
	end
end

ex.MouseButton1Click:Connect(function()
	if busy then return end
	busy = true
	setStatus("Executing...", Color3.fromRGB(255, 230, 120))
	local ok, err = pcall(function()
		local f = loadstring(t.Text)
		if f then f() end
	end)
	if ok then
		setStatus("Executed", Color3.fromRGB(140, 240, 180), 2)
	else
		setStatus(err or "Error", Color3.fromRGB(255, 120, 120), 3)
	end
	busy = false
end)

cl.MouseButton1Click:Connect(function()
	t.Text = ""
end)

cp.MouseButton1Click:Connect(function()
	local ok = pcall(function() setclipboard(t.Text) end)
	if ok then
		setStatus("Copied", Color3.fromRGB(140, 240, 180), 2)
	else
		setStatus("Copy failed", Color3.fromRGB(255, 120, 120), 2)
	end
end)

xt.MouseButton1Click:Connect(function()
	ts:Create(sc, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.9}):Play()
	task.delay(0.16, function() e:Destroy() end)
end)

local minimized = false
mn.MouseButton1Click:Connect(function()
	minimized = not minimized
	local tgtH = minimized and 46 or 400
	local rot = minimized and 180 or 0
	ts:Create(mn, TweenInfo.new(0.2), {Rotation = rot}):Play()
	ts:Create(m, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 560, 0, tgtH)}):Play()
	s.Visible = not minimized
	bf.Visible = not minimized
	sb.Visible = not minimized
	d.Visible = not minimized
end)