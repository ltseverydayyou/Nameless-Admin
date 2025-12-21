if getgenv().npadLoaded then return end
getgenv().npadLoaded = true

local NA_SRV = setmetatable({}, {
	__index = function(self, name)
		local Reference = cloneref and type(cloneref) == "function" and cloneref or function(ref) return ref end
		local ok, svc = pcall(function()
			return Reference(game:GetService(name))
		end)
		if ok and svc then
			rawset(self, name, svc)
			return svc
		end
	end
})

function Svc(name)
	return NA_SRV[name]
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
		local lp2 = Svc("Players").LocalPlayer
		if lp2 and lp2:FindFirstChildWhichIsA("PlayerGui") then
			NAP(g)
			g.Parent = lp2:FindFirstChildWhichIsA("PlayerGui")
			g.ResetOnSpawn = false
			return g
		end
	end
	return nil
end

local ts = Svc("TweenService")
local uis = Svc("UserInputService")
local gsv = Svc("GuiService")
local txtsvc = Svc("TextService")

local isM = (function()
	local p = uis:GetPlatform()
	if p == Enum.Platform.IOS or p == Enum.Platform.Android or p == Enum.Platform.AndroidTV or p == Enum.Platform.Chromecast or p == Enum.Platform.MetaOS then
		return true
	end
	if p == Enum.Platform.None then
		return uis.TouchEnabled and not (uis.KeyboardEnabled or uis.MouseEnabled)
	end
	return false
end)()

local C = {
	winBg = Color3.fromRGB(8, 8, 8),
	winStroke = Color3.fromRGB(255, 255, 255),
	topBg = Color3.fromRGB(5, 5, 5),
	title = Color3.fromRGB(245, 245, 245),
	btnBg = Color3.fromRGB(15, 15, 15),
	btnBgHover = Color3.fromRGB(26, 26, 26),
	btnText = Color3.fromRGB(240, 240, 240),
	bodyBg = Color3.fromRGB(10, 10, 10),
	bodyStroke = Color3.fromRGB(255, 255, 255),
	inputBg = Color3.fromRGB(16, 16, 16),
	inputText = Color3.fromRGB(235, 235, 235),
	inputPlaceholder = Color3.fromRGB(150, 150, 150),
	labelText = Color3.fromRGB(210, 210, 210),
	scrollBar = Color3.fromRGB(180, 180, 180),
	statusText = Color3.fromRGB(210, 210, 210),
	statusTextBad = Color3.fromRGB(255, 255, 255),
	countText = Color3.fromRGB(190, 190, 190),
	txtFrameBg = Color3.fromRGB(12, 12, 12),
	txtFrameStroke = Color3.fromRGB(255, 255, 255),
	extListBg = Color3.fromRGB(12, 12, 12),
	extItemBg = Color3.fromRGB(18, 18, 18),
	extItemHover = Color3.fromRGB(28, 28, 28),
	dockBg = Color3.fromRGB(12, 12, 12),
	dockText = Color3.fromRGB(240, 240, 240),
	dockStroke = Color3.fromRGB(255, 255, 255),
	boxText = Color3.fromRGB(240, 240, 240),
	boxPlaceholder = Color3.fromRGB(150, 150, 150)
}

local gui = Instance.new("ScreenGui")
gui.Name = "NotepadX"
ProtectGui(gui)

local win = Instance.new("Frame")
win.Name = "Win"
win.AnchorPoint = Vector2.new(0.5, 0.5)
win.Position = UDim2.fromScale(0.5, 0.5)
win.Size = UDim2.fromScale(0.6, 0.86)
win.BackgroundColor3 = C.winBg
win.BorderSizePixel = 0
win.Parent = gui

local uiScale = Instance.new("UIScale")
uiScale.Parent = win

local szCons = Instance.new("UISizeConstraint")
szCons.MinSize = Vector2.new(380, 360)
szCons.MaxSize = Vector2.new(980, 740)
szCons.Parent = win

local BASE_MIN = Vector2.new(380, 360)

local winCorner = Instance.new("UICorner")
winCorner.CornerRadius = UDim.new(0, 14)
winCorner.Parent = win

local winStroke = Instance.new("UIStroke")
winStroke.Thickness = 2
winStroke.Color = C.winStroke
winStroke.Transparency = 0.7
winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
winStroke.Parent = win

local top = Instance.new("Frame")
top.Name = "Top"
top.BackgroundColor3 = C.topBg
top.BorderSizePixel = 0
top.Size = UDim2.new(1, 0, 0, 46)
top.Parent = win
top.Active = true
top.Selectable = true

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = top

local topLine = Instance.new("Frame")
topLine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
topLine.BorderSizePixel = 0
topLine.Size = UDim2.new(1, -20, 0, 1)
topLine.Position = UDim2.new(0, 10, 1, -1)
topLine.Parent = top

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -170, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.Font = Enum.Font.GothamSemibold
title.Text = "Notepad X"
title.TextColor3 = C.title
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local topBtns = Instance.new("Frame")
topBtns.BackgroundTransparency = 1
topBtns.Size = UDim2.new(0, 150, 1, -8)
topBtns.Position = UDim2.new(1, -156, 0, 4)
topBtns.Parent = top

local topList = Instance.new("UIListLayout")
topList.FillDirection = Enum.FillDirection.Horizontal
topList.HorizontalAlignment = Enum.HorizontalAlignment.Right
topList.VerticalAlignment = Enum.VerticalAlignment.Center
topList.Padding = UDim.new(0, 6)
topList.Parent = topBtns

local function mkBtn(txt, par, h)
	local b = Instance.new("TextButton")
	b.Name = txt:gsub("%s+", "")
	b.Text = txt
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.TextColor3 = C.btnText
	b.BackgroundColor3 = C.btnBg
	b.BackgroundTransparency = 0
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	b.Size = UDim2.new(0, 64, 0, h or 32)
	b.Parent = par
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = b
	local s = Instance.new("UIStroke")
	s.Thickness = 1
	s.Color = C.winStroke
	s.Transparency = 0.85
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = b
	b.MouseEnter:Connect(function()
		if not isM then
			ts:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.btnBgHover}):Play()
		end
	end)
	b.MouseLeave:Connect(function()
		if not isM then
			ts:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C.btnBg}):Play()
		end
	end)
	b.MouseButton1Down:Connect(function()
		ts:Create(b, TweenInfo.new(0.08), {TextTransparency = 0.35}):Play()
	end)
	b.MouseButton1Up:Connect(function()
		ts:Create(b, TweenInfo.new(0.12), {TextTransparency = 0}):Play()
	end)
	return b
end

local btnMin = mkBtn("-", topBtns, 30)
btnMin.Size = UDim2.new(0, 52, 0, 30)

local btnExit = mkBtn("×", topBtns, 30)
btnExit.Size = UDim2.new(0, 52, 0, 30)

local body = Instance.new("Frame")
body.Name = "Body"
body.BackgroundColor3 = C.bodyBg
body.BorderSizePixel = 0
body.Size = UDim2.new(1, -16, 1, -60)
body.Position = UDim2.new(0, 8, 0, 50)
body.Parent = win

local bodyCorner = Instance.new("UICorner")
bodyCorner.CornerRadius = UDim.new(0, 12)
bodyCorner.Parent = body

local bodyStroke = Instance.new("UIStroke")
bodyStroke.Thickness = 1
bodyStroke.Color = C.bodyStroke
bodyStroke.Transparency = 0.85
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
fileRow.Size = UDim2.new(1, 0, 0, 32)
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
nameBox.TextColor3 = C.inputText
nameBox.PlaceholderText = "file name"
nameBox.PlaceholderColor3 = C.inputPlaceholder
nameBox.BackgroundColor3 = C.inputBg
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
dotLbl.TextColor3 = C.labelText
dotLbl.TextXAlignment = Enum.TextXAlignment.Center
dotLbl.Parent = fileRow

local extBox = Instance.new("TextBox")
extBox.Size = UDim2.new(0.2, 0, 1, 0)
extBox.Text = "txt"
extBox.ClearTextOnFocus = false
extBox.Font = Enum.Font.Gotham
extBox.TextSize = 14
extBox.TextColor3 = C.inputText
extBox.PlaceholderText = "ext"
extBox.PlaceholderColor3 = C.inputPlaceholder
extBox.BackgroundColor3 = C.inputBg
extBox.BorderSizePixel = 0
extBox.Parent = fileRow
local extCorner = Instance.new("UICorner")
extCorner.CornerRadius = UDim.new(0, 10)
extCorner.Parent = extBox

local extBtn = mkBtn("Ext", fileRow, 28)
extBtn.Size = UDim2.new(0.16, 0, 0, 28)

local btnRow = Instance.new("Frame")
btnRow.BackgroundTransparency = 1
btnRow.Size = UDim2.new(1, 0, 0, 34)
btnRow.LayoutOrder = 2
btnRow.Parent = body

local btnGrid = Instance.new("UIGridLayout")
btnGrid.FillDirection = Enum.FillDirection.Horizontal
btnGrid.CellPadding = UDim2.new(0, 8, 0, 0)
btnGrid.CellSize = UDim2.new(0.333, -6, 1, 0)
btnGrid.FillDirectionMaxCells = 3
btnGrid.Parent = btnRow

local btnNew = mkBtn("New", btnRow, 30)
local btnOpen = mkBtn("Open", btnRow, 30)
local btnSave = mkBtn("Save", btnRow, 30)

local txtFrame = Instance.new("Frame")
txtFrame.BackgroundColor3 = C.txtFrameBg
txtFrame.BorderSizePixel = 0
txtFrame.Size = UDim2.new(1, 0, 1, -(32 + 10 + 34 + 10 + 32 + 10 + 24))
txtFrame.LayoutOrder = 3
txtFrame.Parent = body

local tfCorner = Instance.new("UICorner")
tfCorner.CornerRadius = UDim.new(0, 10)
tfCorner.Parent = txtFrame

local tfStroke = Instance.new("UIStroke")
tfStroke.Thickness = 1
tfStroke.Color = C.txtFrameStroke
tfStroke.Transparency = 0.9
tfStroke.Parent = txtFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Active = true
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Position = UDim2.new(0, 6, 0, 6)
scroll.Size = UDim2.new(1, -12, 1, -12)
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = C.scrollBar
scroll.ScrollingDirection = Enum.ScrollingDirection.XY
scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
scroll.Parent = txtFrame

local box = Instance.new("TextBox")
box.BackgroundTransparency = 1
box.Position = UDim2.new(0, 2, 0, 0)
box.Size = UDim2.new(0, 200, 0, 200)
box.ClearTextOnFocus = false
box.Font = Enum.Font.Code
box.TextSize = 20
box.TextScaled = false
box.MultiLine = true
box.PlaceholderText = "Type here..."
box.PlaceholderColor3 = C.boxPlaceholder
box.Text = ""
box.TextColor3 = C.boxText
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextWrapped = false
box.RichText = false
box.MaxVisibleGraphemes = -1
box.Parent = scroll

local utilRow = Instance.new("Frame")
utilRow.BackgroundTransparency = 1
utilRow.Size = UDim2.new(1, 0, 0, 32)
utilRow.LayoutOrder = 4
utilRow.Parent = body

local utilGrid = Instance.new("UIGridLayout")
utilGrid.FillDirection = Enum.FillDirection.Horizontal
utilGrid.CellPadding = UDim2.new(0, 8, 0, 0)
utilGrid.CellSize = UDim2.new(0.333, -6, 1, 0)
utilGrid.Parent = utilRow

local btnCopy = mkBtn("Copy", utilRow, 30)
local btnClear = mkBtn("Clear", utilRow, 30)
local btnDelete = mkBtn("Delete", utilRow, 30)

local statusRow = Instance.new("Frame")
statusRow.BackgroundTransparency = 1
statusRow.Size = UDim2.new(1, 0, 0, 24)
statusRow.LayoutOrder = 5
statusRow.Parent = body

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.new(0.6, 0, 1, 0)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = C.statusText
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = false
status.TextTruncate = Enum.TextTruncate.AtEnd
status.TextTransparency = 1
status.Parent = statusRow

local counts = Instance.new("TextLabel")
counts.BackgroundTransparency = 1
counts.Size = UDim2.new(0.4, 0, 1, 0)
counts.Position = UDim2.new(0.6, 0, 0, 0)
counts.Text = "Chars: 0 | Lines: 0"
counts.Font = Enum.Font.Gotham
counts.TextSize = 13
counts.TextColor3 = C.countText
counts.TextXAlignment = Enum.TextXAlignment.Right
counts.TextWrapped = false
counts.TextTruncate = Enum.TextTruncate.AtEnd
counts.Parent = statusRow

local extList = Instance.new("Frame")
extList.Visible = false
extList.BackgroundColor3 = C.extListBg
extList.BorderSizePixel = 0
extList.Size = UDim2.new(0, 180, 0, 0)
extList.ZIndex = 50
extList.Parent = gui

local extCorner2 = Instance.new("UICorner")
extCorner2.CornerRadius = UDim.new(0, 10)
extCorner2.Parent = extList

local extStroke = Instance.new("UIStroke")
extStroke.Thickness = 1
extStroke.Color = C.winStroke
extStroke.Transparency = 0.9
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

local exts = { "txt", "lua", "json", "md", "log", "cfg", "csv", "xml", "ini", "html" }

local extOpen = false
local extH = 160

local function setStatus(msg, good)
	status.TextTransparency = 1
	status.TextColor3 = good == false and C.statusTextBad or C.statusText
	status.Text = (good == false and "! " or "✓ ") .. msg
	ts:Create(status, TweenInfo.new(0.12), {TextTransparency = 0}):Play()
	task.delay(2.0, function()
		if status then
			local t = ts:Create(status, TweenInfo.new(0.18), {TextTransparency = 1})
			t:Play()
			t.Completed:Wait()
			if status then
				status.Text = ""
			end
		end
	end)
end

local function posExt()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
	local p = extBtn.AbsolutePosition
	local s = extBtn.AbsoluteSize
	local x = math.clamp(p.X, 8, vp.X - 180 - 8)
	local y = p.Y + s.Y + 4
	if y + extH + 8 > vp.Y then
		y = p.Y - extH - 4
	end
	extList.Position = UDim2.fromOffset(x, y)
end

local function showExt()
	if extOpen then return end
	extOpen = true
	posExt()
	extList.Size = UDim2.new(0, 180, 0, 0)
	extList.Visible = true
	ts:Create(extList, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 180, 0, extH)}):Play()
end

local function hideExt()
	if not extOpen then return end
	extOpen = false
	local twn = ts:Create(extList, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 180, 0, 0)})
	twn:Play()
	task.delay(0.14, function()
		if not extOpen then
			extList.Visible = false
		end
	end)
end

local function mkExtButton(t)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 26)
	b.Text = t
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 14
	b.BackgroundColor3 = C.extItemBg
	b.TextColor3 = C.btnText
	b.BorderSizePixel = 0
	b.ZIndex = 52
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = b
	b.Parent = extScroll
	b.MouseEnter:Connect(function()
		ts:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = C.extItemHover}):Play()
	end)
	b.MouseLeave:Connect(function()
		ts:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = C.extItemBg}):Play()
	end)
	b.MouseButton1Click:Connect(function()
		extBox.Text = t
		hideExt()
	end)
end

for _, e2 in ipairs(exts) do
	mkExtButton(e2)
end

local minz = false

local dock = Instance.new("TextButton")
dock.Name = "NP_Dock"
dock.Text = "📝"
dock.Font = Enum.Font.GothamBold
dock.TextScaled = true
dock.BackgroundColor3 = C.dockBg
dock.TextColor3 = C.dockText
dock.BorderSizePixel = 0
dock.Size = UDim2.fromOffset(56, 56)
dock.Visible = false
dock.AnchorPoint = Vector2.new(0.5, 0.5)
dock.Parent = gui

local dockC = Instance.new("UICorner")
dockC.CornerRadius = UDim.new(1, 0)
dockC.Parent = dock

local dockS = Instance.new("UIStroke")
dockS.Thickness = 1
dockS.Color = C.dockStroke
dockS.Transparency = 0.5
dockS.Parent = dock

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function safeName(s)
	s = trim(s or "")
	if s == "" then
		return "file"
	end
	s = s:gsub("[%c%z<>:\"/\\|%?%*]", "_")
	s = s:gsub("^%.*", "")
	if s == "" then
		s = "file"
	end
	return s
end

local function normExt(e)
	e = trim(e or ""):lower():gsub("^%.", "")
	if e == "" then
		return "txt"
	end
	if not e:match("^[%w]+$") then
		return "txt"
	end
	if #e > 16 then
		return "txt"
	end
	return e
end

local function fullName()
	return safeName(nameBox.Text) .. "." .. normExt(extBox.Text)
end

local function countLines(s)
	if s == "" then
		return 0
	end
	return select(2, s:gsub("\n", "")) + 1
end

local function lineH()
	return txtsvc:GetTextSize("Ag", 20, box.Font, Vector2.new(1e5, 1e5)).Y
end

local function maxW(text)
	local m = 0
	for line in (text .. "\n"):gmatch("(.-)\n") do
		local w = txtsvc:GetTextSize(line == "" and " " or line, 20, box.Font, Vector2.new(1e7, 1e7)).X
		if w > m then
			m = w
		end
	end
	return m + 16
end

local function refCanvas()
	box.MaxVisibleGraphemes = -1
	local w = math.max(scroll.AbsoluteSize.X, maxW(box.Text))
	local h = math.max(scroll.AbsoluteSize.Y, countLines(box.Text) * (lineH() + 2) + 24)
	box.Size = UDim2.new(0, w - 8, 0, h - 8)
	scroll.CanvasSize = UDim2.new(0, w, 0, h)
end

local function updCounts()
	local s = box.Text
	local c = #s
	local l = (s == "" and 0) or (select(2, s:gsub("\n", "")) + 1)
	counts.Text = ("Chars: %d | Lines: %d"):format(c, l)
end

local function doScale()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local inset = gsv:GetGuiInset()
	local ux = math.max(0, vp.X - inset.X * 2)
	local uy = math.max(0, vp.Y - inset.Y * 2)
	local tw = math.clamp(ux * 0.6, BASE_MIN.X, szCons.MaxSize.X)
	local th = math.clamp(uy * 0.86, BASE_MIN.Y, szCons.MaxSize.Y)
	win.Size = UDim2.new(0, tw, 0, th)
	local sc = math.min(ux / tw, uy / th)
	uiScale.Scale = math.clamp(sc, 0.65, 1)
end

local function hookVP()
	local function hookCam(c)
		if not c then
			return
		end
		c:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			doScale()
			refCanvas()
		end)
	end
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		hookCam(workspace.CurrentCamera)
		doScale()
		refCanvas()
	end)
	if workspace.CurrentCamera then
		hookCam(workspace.CurrentCamera)
	end
	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		doScale()
		refCanvas()
	end)
	scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(refCanvas)
end

local drag = false
local dragIn, dragStart, startPos = nil, nil, nil

top.InputBegan:Connect(function(i)
	if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	drag = true
	dragStart = i.Position
	startPos = win.Position
	ts:Create(winStroke, TweenInfo.new(0.08), {Thickness = 3}):Play()
	i.Changed:Connect(function()
		if i.UserInputState == Enum.UserInputState.End then
			drag = false
			ts:Create(winStroke, TweenInfo.new(0.08), {Thickness = 2}):Play()
		end
	end)
end)

top.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		dragIn = i
	end
end)

uis.InputChanged:Connect(function(i)
	if drag and i == dragIn then
		local d2 = i.Position - dragStart
		win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d2.X, startPos.Y.Scale, startPos.Y.Offset + d2.Y)
	end
end)

local lastPos, lastSz = win.Position, win.Size

local function clampDock(x, y)
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local px = math.clamp(x, 36, vp.X - 36)
	local py = math.clamp(y, 36, vp.Y - 36)
	return px, py
end

local function toDock()
	if minz then
		return
	end
	minz = true
	lastPos, lastSz = win.Position, win.Size
	local ax = win.AbsolutePosition.X + win.AbsoluteSize.X * 0.5
	local ay = win.AbsolutePosition.Y + 28
	ax, ay = clampDock(ax, ay)
	dock.Position = UDim2.fromOffset(ax, ay)
	dock.Size = UDim2.fromOffset(0, 0)
	dock.Visible = true
	ts:Create(win, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
	ts:Create(body, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
	ts:Create(top, TweenInfo.new(0.18), {BackgroundTransparency = 1}):Play()
	for _, g in ipairs(body:GetDescendants()) do
		if g:IsA("GuiObject") then
			g.Visible = false
		end
	end
	ts:Create(dock, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(56, 56)}):Play()
	task.delay(0.18, function()
		win.Visible = false
	end)
end

local function fromDock()
	if not minz then
		return
	end
	minz = false
	win.Visible = true
	ts:Create(dock, TweenInfo.new(0.16), {Size = UDim2.fromOffset(0, 0)}):Play()
	ts:Create(win, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
	task.delay(0.02, function()
		for _, g in ipairs(body:GetDescendants()) do
			if g:IsA("GuiObject") then
				g.Visible = true
			end
		end
		ts:Create(body, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
		ts:Create(top, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
		win.Position = lastPos
		win.Size = lastSz
		dock.Visible = false
		doScale()
		refCanvas()
	end)
end

btnMin.MouseButton1Click:Connect(toDock)
dock.MouseButton1Click:Connect(fromDock)

btnExit.MouseButton1Click:Connect(function()
	gui:Destroy()
	getgenv().npadLoaded = false
end)

extBtn.MouseButton1Click:Connect(function()
	if extOpen then
		hideExt()
	else
		showExt()
	end
end)

uis.InputBegan:Connect(function(i, gpe)
	if gpe then
		return
	end
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		if not extList.Visible then
			return
		end
		local mp = (i.UserInputType == Enum.UserInputType.Touch) and i.Position or uis:GetMouseLocation()
		local pos = Vector2.new(extList.AbsolutePosition.X, extList.AbsolutePosition.Y)
		local sz = extList.AbsoluteSize
		if mp.X < pos.X or mp.X > pos.X + sz.X or mp.Y < pos.Y or mp.Y > pos.Y + sz.Y then
			hideExt()
		end
	end
end)

local function doSave(t)
	if not writefile then
		setStatus("FS not available", false)
		return
	end
	local fn = t or fullName()
	local ok = pcall(writefile, fn, box.Text)
	if ok then
		setStatus("Saved " .. fn, true)
	else
		setStatus("Save failed", false)
	end
end

local function doOpen(fn)
	if not (isfile and readfile) then
		setStatus("FS not available", false)
		return
	end
	if isfile(fn) then
		local ok, data = pcall(readfile, fn)
		if ok then
			box.Text = tostring(data or "")
			setStatus("Opened " .. fn, true)
		else
			setStatus("Open failed", false)
		end
	else
		setStatus("No such file", false)
	end
end

local function doDel(fn)
	if not (isfile and delfile) then
		setStatus("FS not available", false)
		return
	end
	if isfile(fn) then
		local ok = pcall(delfile, fn)
		if ok then
			setStatus("Deleted " .. fn, true)
		else
			setStatus("Delete failed", false)
		end
	else
		setStatus("No such file", false)
	end
end

btnCopy.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(box.Text)
		setStatus("Copied to clipboard", true)
	else
		setStatus("Clipboard not available", false)
	end
end)

btnClear.MouseButton1Click:Connect(function()
	box.Text = ""
	refCanvas()
	updCounts()
	setStatus("Cleared", true)
end)

btnDelete.MouseButton1Click:Connect(function()
	doDel(fullName())
end)

btnNew.MouseButton1Click:Connect(function()
	nameBox.Text = "file"
	extBox.Text = "txt"
	box.Text = ""
	refCanvas()
	updCounts()
	setStatus("New document", true)
end)

btnOpen.MouseButton1Click:Connect(function()
	doOpen(fullName())
	refCanvas()
	updCounts()
end)

btnSave.MouseButton1Click:Connect(function()
	nameBox.Text = safeName(nameBox.Text)
	extBox.Text = normExt(extBox.Text)
	doSave()
end)

box:GetPropertyChangedSignal("Text"):Connect(function()
	box.MaxVisibleGraphemes = -1
	refCanvas()
	updCounts()
end)

scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(refCanvas)

uis.InputBegan:Connect(function(i, gpe)
	if gpe then
		return
	end
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

doScale()
hookVP()
refCanvas()
updCounts()

win.BackgroundTransparency = 1
body.BackgroundTransparency = 1
top.BackgroundTransparency = 1
task.spawn(function()
	local sc = uiScale.Scale
	uiScale.Scale = sc * 0.9
	ts:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = sc}):Play()
	ts:Create(win, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	ts:Create(body, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	ts:Create(top, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)
