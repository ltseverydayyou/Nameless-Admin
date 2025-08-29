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
local caret = Instance.new("Frame")
local selLayer = Instance.new("Frame")
local bf = Instance.new("Frame")
local gl = Instance.new("UIGridLayout")
local ex = Instance.new("TextButton")
local cl = Instance.new("TextButton")
local cp = Instance.new("TextButton")
local sb = Instance.new("TextLabel")

local function S(n) return (cloneref and cloneref(game:GetService(n))) or game:GetService(n) end
local ts, uis, gsv, txtsvc, rs = S("TweenService"), S("UserInputService"), S("GuiService"), S("TextService"), S("RunService")

local function protectUI(gui)
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.DisplayOrder = 999999999
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	local cg = S("CoreGui")
	local lp = S("Players").LocalPlayer
	local function p(i, v) if not i then return end if v then i[v] = "\0" else i.Name = "\0" end i.Archivable = false end
	if cg and cg:FindFirstChild("RobloxGui") then p(gui) gui.Parent = cg.RobloxGui return end
	if cg then p(gui) gui.Parent = cg return end
	if lp and lp:FindFirstChild("PlayerGui") then p(gui) gui.Parent = lp.PlayerGui return end
end

e.Name = "AdvExec"; protectUI(e)

m.Name = "Main"; m.Parent = e; m.Active = true; m.BackgroundColor3 = Color3.fromRGB(22,23,33)
m.ClipsDescendants = true; m.AnchorPoint = Vector2.new(0.5,0.5); m.Position = UDim2.fromScale(0.5,0.5)
m.Size = UDim2.new(0, 440, 0, 340)
c1.CornerRadius = UDim.new(0, 12); c1.Parent = m
local sc = Instance.new("UIScale", m); sc.Scale = 0.97; ts:Create(sc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1}):Play()
local sizeCons = Instance.new("UISizeConstraint", m); sizeCons.MinSize = Vector2.new(380, 300); sizeCons.MaxSize = Vector2.new(780, 640)
local BASE_MIN = sizeCons.MinSize

tb.Name = "TopBar"; tb.Parent = m; tb.BackgroundColor3 = Color3.fromRGB(28,30,42); tb.BorderSizePixel = 0; tb.Size = UDim2.new(1,0,0,44)
c6.CornerRadius = UDim.new(0,12); c6.Parent = tb

tt.Name = "Title"; tt.Parent = tb; tt.BackgroundTransparency = 1; tt.Position = UDim2.new(0,16,0,0)
tt.Size = UDim2.new(1,-120,1,0); tt.Font = Enum.Font.GothamBold; tt.Text = "Executor"; tt.TextColor3 = Color3.fromRGB(235,238,255); tt.TextSize = 20; tt.TextXAlignment = Enum.TextXAlignment.Left

xt.Name = "Exit"; xt.Parent = tb; xt.BackgroundTransparency = 1; xt.Position = UDim2.new(1,-44,0,0); xt.Size = UDim2.new(0,44,1,0)
xt.Font = Enum.Font.GothamBold; xt.Text = "X"; xt.TextColor3 = Color3.fromRGB(255,110,110); xt.TextSize = 18

mn.Name = "Min"; mn.Parent = tb; mn.BackgroundTransparency = 1; mn.Position = UDim2.new(1,-88,0,0); mn.Size = UDim2.new(0,44,1,0)
mn.Font = Enum.Font.GothamBold; mn.Text = "V"; mn.TextColor3 = Color3.fromRGB(140,160,255); mn.TextSize = 18

d.Name = "Sep"; d.Parent = m; d.BackgroundColor3 = Color3.fromRGB(32,34,48); d.Position = UDim2.new(0,0,0,44); d.Size = UDim2.new(1,0,0,2)
c2.CornerRadius = UDim.new(0,1); c2.Parent = d

s.Name = "Scroll"; s.Parent = m; s.Active = true; s.BackgroundColor3 = Color3.fromRGB(26,27,39); s.BorderSizePixel = 0
s.Position = UDim2.new(0,12,0,56); s.Size = UDim2.new(1,-24,1,-164); s.ScrollBarThickness = 6; s.ScrollBarImageColor3 = Color3.fromRGB(110,115,180)
s.CanvasSize = UDim2.new(0,0,0,0); s.ScrollingDirection = Enum.ScrollingDirection.XY; s.ClipsDescendants = true

ln.Name = "LineNum"; ln.Parent = s; ln.BackgroundColor3 = Color3.fromRGB(24,25,36); ln.BorderSizePixel = 0; ln.Position = UDim2.new(0,0,0,0)
ln.Size = UDim2.new(0,40,1,0); ln.Font = Enum.Font.Code; ln.Text = "1"; ln.TextColor3 = Color3.fromRGB(120,125,155); ln.TextSize = 16
ln.TextXAlignment = Enum.TextXAlignment.Right; ln.TextYAlignment = Enum.TextYAlignment.Top; ln.RichText = true; ln.ZIndex = 1

hl.Name = "HL"; hl.Parent = s; hl.BackgroundTransparency = 1; hl.Position = UDim2.new(0,46,0,0); hl.Size = UDim2.new(1,-52,1,0)
hl.Font = Enum.Font.Code; hl.Text = ""; hl.TextColor3 = Color3.fromRGB(255,255,255); hl.TextSize = 16; hl.TextXAlignment = Enum.TextXAlignment.Left; hl.TextYAlignment = Enum.TextYAlignment.Top
hl.RichText = true; hl.ZIndex = 2

t.Name = "Text"; t.Parent = s; t.BackgroundTransparency = 1; t.BorderSizePixel = 0; t.Position = UDim2.new(0,46,0,0); t.Size = UDim2.new(1,-52,1,0)
t.ClearTextOnFocus = false; t.Font = Enum.Font.Code; t.MultiLine = true; t.PlaceholderText = "-- Script here"; t.PlaceholderColor3 = Color3.fromRGB(150,150,170)
t.Text = ""; t.TextColor3 = Color3.fromRGB(255,255,255); t.TextSize = 16; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top
t.TextWrapped = false; t.TextTransparency = 1; t.ZIndex = 4

selLayer.Name = "SelLayer"; selLayer.Parent = s; selLayer.BackgroundTransparency = 1; selLayer.BorderSizePixel = 0; selLayer.ZIndex = 3

caret.Name = "Caret"; caret.Parent = s; caret.BackgroundColor3 = Color3.fromRGB(235,240,255); caret.BorderSizePixel = 0
caret.Size = UDim2.fromOffset(2, 16); caret.Visible = false; caret.ZIndex = 5

bf.Name = "Buttons"; bf.Parent = m; bf.BackgroundTransparency = 1; bf.Position = UDim2.new(0,12,1,-70); bf.Size = UDim2.new(1,-24,0,48)
gl.Parent = bf; gl.SortOrder = Enum.SortOrder.LayoutOrder; gl.CellPadding = UDim2.new(0,10,0,0); gl.CellSize = UDim2.new(0.333,-8,1,0); gl.FillDirectionMaxCells = 3

local function styleBtn(b, txt, bg, fg)
	b.Name = txt; b.Parent = bf; b.Text = txt; b.BackgroundColor3 = bg; b.TextColor3 = fg; b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamSemibold; b.TextSize = 16
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	local st = Instance.new("UIStroke", b); st.Thickness = 1; st.Color = Color3.fromRGB(60,65,95)
	local scl = Instance.new("UIScale", b)
	b.MouseEnter:Connect(function() ts:Create(scl, TweenInfo.new(0.12), {Scale=1.03}):Play() ts:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = bg:Lerp(Color3.new(1,1,1),0.05)}):Play() end)
	b.MouseLeave:Connect(function() ts:Create(scl, TweenInfo.new(0.12), {Scale=1}):Play() ts:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = bg}):Play() end)
	b.MouseButton1Down:Connect(function() ts:Create(scl, TweenInfo.new(0.06), {Scale=0.97}):Play() end)
	b.MouseButton1Up:Connect(function() ts:Create(scl, TweenInfo.new(0.1), {Scale=1.03}):Play() end)
end

styleBtn(ex, "Execute", Color3.fromRGB(68,128,255), Color3.fromRGB(255,255,255))
styleBtn(cl, "Clear",   Color3.fromRGB(52,58,84),  Color3.fromRGB(230,235,255))
styleBtn(cp, "Copy",    Color3.fromRGB(52,58,84),  Color3.fromRGB(230,235,255))

sb.Name = "Status"; sb.Parent = m; sb.BackgroundTransparency = 1; sb.Position = UDim2.new(0,14,1,-22)
sb.Size = UDim2.new(1,-28,0,18); sb.Font = Enum.Font.Gotham; sb.Text = "Ready"; sb.TextColor3 = Color3.fromRGB(110,245,140); sb.TextSize = 14; sb.TextXAlignment = Enum.TextXAlignment.Left

local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
local function updateDrag(i) local d2 = i.Position - dragStart m.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d2.X, startPos.Y.Scale, startPos.Y.Offset + d2.Y) end
tb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true dragStart=i.Position startPos=m.Position i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end) end end)
tb.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then dragInput=i end end)
uis.InputChanged:Connect(function(i) if dragging and i==dragInput then updateDrag(i) end end)

local function esc(x) return x:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;") end
local kw = {"and","break","do","else","elseif","end","false","for","function","goto","if","in","local","nil","not","or","repeat","return","then","true","until","while"}
local bi = {"self","pairs","ipairs","pcall","xpcall","type","next","assert","error","warn","string","table","math","debug","coroutine","os","utf8","game","workspace","script","Enum","Color3","Vector3","UDim2","CFrame","Instance","task","tick","time","wait","spawn"}

local function colorize(txt)
	local E, ph, n = esc(txt), {}, 0
	local function keep(s2) n+=1 ph[n]=s2 return "\1PH"..n.."\2" end
	E = E:gsub("%-%-%[%[[%s%S]-%]%]", function(s2) return keep('<font color="#8B949E">'..s2..'</font>') end)
	E = E:gsub("%-%-[^\n]*", function(s2) return keep('<font color="#8B949E">'..s2..'</font>') end)
	E = E:gsub("%[%[[%s%S]-%]%]", function(s2) return keep('<font color="#A3E635">'..s2..'</font>') end)
	E = E:gsub('"(.-)"', function(s2) return keep('<font color="#A3E635">"'..s2..'"</font>') end)
	E = E:gsub("'(.-)'", function(s2) return keep('<font color="#A3E635">\''..s2..'\'</font>') end)
	E = E:gsub("(%f[%w_]%d[%d%.eE]*%f[^%w_])", '<font color="#60A5FA">%1</font>')
	for _, w in ipairs(kw) do E = E:gsub("%f[%w_]"..w.."%f[^%w_]", '<font color="#F472B6">'..w..'</font>') end
	for _, w in ipairs(bi) do E = E:gsub("%f[%w_]"..w.."%f[^%w_]", '<font color="#F59E0B">'..w..'</font>') end
	E = E:gsub("\1PH(%d+)\2", function(i2) return ph[tonumber(i2)] or "" end)
	return E
end

local function lineHeight() return txtsvc:GetTextSize("A", t.TextSize, t.Font, Vector2.new(1e5,1e5)).Y end

local CHUNK_NAME, errorLine, runningCo = "UserScript", nil, nil
local errMark = Instance.new("Frame"); errMark.Name="ErrMark"; errMark.Parent = s; errMark.BackgroundColor3 = Color3.fromRGB(255,90,90)
errMark.BackgroundTransparency = 0.85; errMark.BorderSizePixel = 0; errMark.Visible=false; errMark.ZIndex=2

local function gotoLine(n) local y = math.max(0,(n-1)*lineHeight() - s.AbsoluteSize.Y*0.3) s.CanvasPosition = Vector2.new(0,y) end
local function clearErrorUI() errorLine=nil errMark.Visible=false end

local function updateLines()
	local txt = t.Text; if txt == "" then txt = " " end
	local h = lineHeight()
	local c = 1; for _ in txt:gmatch("\n") do c+=1 end
	local buf = {}
	for i=1,c do if errorLine and i==errorLine then buf[#buf+1] = '<font color="#FF7A7A">'..i..'</font>' else buf[#buf+1]=tostring(i) end end
	ln.Text = table.concat(buf, "\n")
	local widest = 0
	for line in (t.Text.."\n"):gmatch("(.-)\n") do
		local l = line:gsub("\t","    ")
		local sz = txtsvc:GetTextSize(l, t.TextSize, t.Font, Vector2.new(1e6,1e6))
		if sz.X > widest then widest = sz.X end
	end
	local pad = 12
	local minH = s.AbsoluteSize.Y
	local tgtH = math.max(minH, c*h + pad)
	local tgtW = math.max(s.AbsoluteSize.X - 52, widest + 6)
	hl.Size = UDim2.new(0,tgtW,0,tgtH); t.Size = UDim2.new(0,tgtW,0,tgtH); ln.Size = UDim2.new(0,40,0,tgtH)
	s.CanvasSize = UDim2.new(0, 46 + tgtW + 6, 0, tgtH)
	if errorLine then errMark.Size = UDim2.new(0, tgtW, 0, h) errMark.Position = UDim2.new(0,46,0,(errorLine-1)*h) end
end

local function updateHL() hl.Text = colorize(t.Text) updateLines() end
t:GetPropertyChangedSignal("Text"):Connect(updateHL)

local blinkConn, blinkAccum = nil, 0
local function stopBlink() if blinkConn then blinkConn:Disconnect() blinkConn=nil end end

local function clearSelectionVisuals() for _,ch in ipairs(selLayer:GetChildren()) do ch:Destroy() end end
local function wOf(s2) return txtsvc:GetTextSize(s2:gsub("\t","    "), t.TextSize, t.Font, Vector2.new(1e6,1e6)).X end

local function drawSelection(a, b)
	clearSelectionVisuals()
	if not a or not b or a == b then return end
	if a > b then a, b = b, a end
	local text = t.Text
	local beforeA = text:sub(1, a-1)
	local between = text:sub(a, b-1)
	if #between == 0 then return end
	local h = lineHeight()
	local startLineText = (beforeA:match("([^\n]*)$") or "")
	local startX = wOf(startLineText)
	local y = (select(2, beforeA:gsub("\n","")) or 0) * h
	local rest = between
	local firstNL = rest:find("\n", 1, true)
	local MINW = 6
	if not firstNL then
		local w = math.max(wOf(rest), MINW)
		local fr = Instance.new("Frame")
		fr.BackgroundColor3 = Color3.fromRGB(120,140,220)
		fr.BackgroundTransparency = 0.65
		fr.BorderSizePixel = 0
		fr.ZIndex = 3
		fr.Size = UDim2.new(0, w, 0, h)
		fr.Position = UDim2.new(0, 46 + startX, 0, y)
		fr.Parent = selLayer
	else
		local chunk = rest:sub(1, firstNL-1)
		local w1 = math.max(wOf(chunk), MINW)
		local fr1 = Instance.new("Frame")
		fr1.BackgroundColor3 = Color3.fromRGB(120,140,220)
		fr1.BackgroundTransparency = 0.65
		fr1.BorderSizePixel = 0
		fr1.ZIndex = 3
		fr1.Size = UDim2.new(0, w1, 0, h)
		fr1.Position = UDim2.new(0, 46 + startX, 0, y)
		fr1.Parent = selLayer
		rest = rest:sub(firstNL+1)
		local lineY = y + h
		while true do
			local nl = rest:find("\n", 1, true)
			if not nl then
				if #rest > 0 then
					local wlast = math.max(wOf(rest), MINW)
					local frLast = Instance.new("Frame")
					frLast.BackgroundColor3 = Color3.fromRGB(120,140,220)
					frLast.BackgroundTransparency = 0.65
					frLast.BorderSizePixel = 0
					frLast.ZIndex = 3
					frLast.Size = UDim2.new(0, wlast, 0, h)
					frLast.Position = UDim2.new(0, 46, 0, lineY)
					frLast.Parent = selLayer
				end
				break
			else
				local mid = rest:sub(1, nl-1)
				local wmid = math.max(wOf(mid), MINW)
				local frMid = Instance.new("Frame")
				frMid.BackgroundColor3 = Color3.fromRGB(120,140,220)
				frMid.BackgroundTransparency = 0.65
				frMid.BorderSizePixel = 0
				frMid.ZIndex = 3
				frMid.Size = UDim2.new(0, wmid, 0, h)
				frMid.Position = UDim2.new(0, 46, 0, lineY)
				frMid.Parent = selLayer
				lineY += h
				rest = rest:sub(nl+1)
			end
		end
	end
end

local function showCaretAt(pos)
	local pre = t.Text:sub(1, pos-1)
	local line = (select(2, pre:gsub("\n","")) or 0) + 1
	local lastLineText = pre:match("([^\n]*)$") or ""
	local h = lineHeight()
	local w = wOf(lastLineText)
	caret.Visible = true
	caret.Size = UDim2.fromOffset(2, h - 2)
	caret.Position = UDim2.new(0, 46 + w + 2, 0, (line-1)*h + 1)
	if not blinkConn then
		blinkAccum = 0
		blinkConn = rs.RenderStepped:Connect(function(dt)
			if not t:IsFocused() then stopBlink() caret.Visible = false return end
			blinkAccum += dt
			if blinkAccum >= 0.5 then
				caret.Visible = not caret.Visible
				blinkAccum = 0
			end
		end)
	end
end

local function caretAndSelectionUpdate()
	if not t:IsFocused() then stopBlink(); caret.Visible=false; clearSelectionVisuals(); return end
	local pos = t.CursorPosition
	local ss = t.SelectionStart
	if not pos or pos <= 0 then pos = 1 end
	local hasSel = (ss and ss > 0 and ss ~= pos) and true or false
	if hasSel then
		caret.Visible = false
		drawSelection(ss, pos)
	else
		clearSelectionVisuals()
		showCaretAt(pos)
	end
end

t:GetPropertyChangedSignal("Text"):Connect(function() hl.Text = colorize(t.Text) updateLines() caretAndSelectionUpdate() end)
t:GetPropertyChangedSignal("CursorPosition"):Connect(caretAndSelectionUpdate)
t:GetPropertyChangedSignal("SelectionStart"):Connect(caretAndSelectionUpdate)
t.Focused:Connect(caretAndSelectionUpdate)
t.FocusLost:Connect(function() stopBlink(); caret.Visible=false; clearSelectionVisuals() end)
s:GetPropertyChangedSignal("CanvasSize"):Connect(caretAndSelectionUpdate)

uis.InputBegan:Connect(function(i,gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.Tab and t:IsFocused() then
		local pos = t.CursorPosition or 1
		local tx = t.Text; if pos < 1 then pos = 1 end
		local pre = tx:sub(1, pos-1); local suf = tx:sub(pos)
		t.Text = pre.."    "..suf; t.CursorPosition = pos + 4
	end
end)

local function setStatus(msg, col, dur)
	sb.Text = msg; sb.TextColor3 = col
	if dur then task.spawn(function() task.wait(dur) sb.Text = "Ready"; sb.TextColor3 = Color3.fromRGB(110,245,140) end) end
end

ex.MouseButton1Click:Connect(function()
	errorLine=nil; errMark.Visible=false
	setStatus("Running...", Color3.fromRGB(255,230,120))
	local f, cerr = loadstring(t.Text)
	if not f then
		local ln2 = tonumber(tostring(cerr):match(CHUNK_NAME..":(%d+):") or tostring(cerr):match(":(%d+):"))
		if ln2 then
			errorLine = ln2
			errMark.Size = UDim2.new(0, math.max(0, s.CanvasSize.X.Offset - 52), 0, lineHeight())
			errMark.Position = UDim2.new(0, 46, 0, (ln2-1)*lineHeight())
			errMark.Visible = true
			gotoLine(ln2)
		end
		sb.Text = tostring(cerr); sb.TextColor3 = Color3.fromRGB(255,120,120)
		return
	end
	runningCo = coroutine.create(function()
		local ok, e2 = xpcall(f, function(e2) return tostring(e2).."\n"..debug.traceback(nil,2) end)
		if not ok then
			local ln2 = tonumber(tostring(e2):match(CHUNK_NAME..":(%d+):") or tostring(e2):match(":(%d+):"))
			if ln2 then
				errorLine = ln2
				errMark.Size = UDim2.new(0, math.max(0, s.CanvasSize.X.Offset - 52), 0, lineHeight())
				errMark.Position = UDim2.new(0, 46, 0, (ln2-1)*lineHeight())
				errMark.Visible = true
				gotoLine(ln2)
			end
			sb.Text = tostring(e2); sb.TextColor3 = Color3.fromRGB(255,120,120)
		else
			sb.Text = "Executed"; sb.TextColor3 = Color3.fromRGB(140,240,180)
			task.delay(2, function() sb.Text = "Ready"; sb.TextColor3 = Color3.fromRGB(110,245,140) end)
		end
		runningCo = nil
	end)
	task.spawn(function() local ok, e2 = coroutine.resume(runningCo) if not ok then sb.Text = tostring(e2) end end)
end)

cl.MouseButton1Click:Connect(function() t.Text = ""; errorLine=nil; errMark.Visible=false end)
cp.MouseButton1Click:Connect(function() local ok=pcall(function() setclipboard(t.Text) end) if ok then sb.Text="Copied" sb.TextColor3=Color3.fromRGB(140,240,180) task.delay(1.6,function() sb.Text="Ready" sb.TextColor3=Color3.fromRGB(110,245,140) end) else sb.Text="Copy failed" sb.TextColor3=Color3.fromRGB(255,120,120) end end)
xt.MouseButton1Click:Connect(function() ts:Create(sc, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale=0.95}):Play(); task.delay(0.14, function() e:Destroy() end) end)

local minimized = false
local function targetExpandedSize()
	local cam = workspace.CurrentCamera; local vp = cam and cam.ViewportSize or Vector2.new(1280,720)
	local inset = gsv:GetGuiInset(); local ux = math.max(0, vp.X - inset.X*2); local uy = math.max(0, vp.Y - inset.Y*2)
	local w = math.clamp(ux * 0.34, BASE_MIN.X, sizeCons.MaxSize.X)
	local h = math.clamp(uy * 0.58, BASE_MIN.Y, sizeCons.MaxSize.Y)
	return math.floor(w), math.floor(h)
end
local function topbarOnlyHeight() return tb.AbsoluteSize.Y + 2 end

local function layout()
	local topH, statusH, gap, btnH = tb.AbsoluteSize.Y, 18, 12, 48
	if minimized then
		s.Visible=false; bf.Visible=false; sb.Visible=false; d.Visible=false
	else
		s.Visible=true; bf.Visible=true; sb.Visible=true; d.Visible=true
		local scrollTop = topH + gap + 2
		local reserved = btnH + gap + statusH + gap + 2
		s.Position = UDim2.new(0,12,0,scrollTop)
		s.Size = UDim2.new(1,-24,1,-(scrollTop + reserved))
		bf.Position = UDim2.new(0,12,1,-(statusH + gap + btnH))
		bf.Size = UDim2.new(1,-24,0,btnH)
	end
	updateLines()
	caretAndSelectionUpdate()
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if not minimized then local w,h = targetExpandedSize(); m.Size = UDim2.new(0,w,0,h) end
			layout()
		end)
	end
end)
e:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if not minimized then local w,h = targetExpandedSize(); m.Size = UDim2.new(0,w,0,h) end
	layout()
end)
m:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

mn.MouseButton1Click:Connect(function()
	minimized = not minimized
	ts:Create(mn, TweenInfo.new(0.18), {Rotation = minimized and 180 or 0}):Play()
	if minimized then
		sizeCons.MinSize = Vector2.new(0,0)
		local w, th = m.AbsoluteSize.X, topbarOnlyHeight()
		ts:Create(m, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,w,0,th)}):Play()
		s.Visible=false; bf.Visible=false; sb.Visible=false; d.Visible=false
	else
		sizeCons.MinSize = BASE_MIN
		local w,h = targetExpandedSize()
		ts:Create(m, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,w,0,h)}):Play()
		task.delay(0.02, function() s.Visible=true; bf.Visible=true; sb.Visible=true; d.Visible=true; layout() end)
	end
end)

local function firstShow() local w,h = targetExpandedSize(); m.Size = UDim2.new(0,w,0,h); layout(); hl.Text = colorize(t.Text) updateLines() end
firstShow()