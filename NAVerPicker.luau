local SRV = setmetatable({}, {
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

local function SafeGetService(name)
	return SRV[name]
end

local hs = SafeGetService("HttpService")
local plrs = SafeGetService("Players")
local lp = plrs.LocalPlayer
local UIS = SafeGetService("UserInputService")

local _naConns = _naConns or {}
local NAlib = {}
if not NAlib.disconnect then
	function NAlib.disconnect(n)
		local t = _naConns[n]
		if t then
			for _, c in ipairs(t) do
				pcall(function() c:Disconnect() end)
			end
			_naConns[n] = nil
		end
	end
end
if not NAlib.connect then
	function NAlib.connect(n, c)
		if not c then return end
		_naConns[n] = _naConns[n] or {}
		table.insert(_naConns[n], c)
		return c
	end
end
if not NAlib.isProperty then
	function NAlib.isProperty(o, p)
		return pcall(function() return o[p] end)
	end
end
if not NAlib.setProperty then
	function NAlib.setProperty(o, p, v)
		pcall(function() o[p] = v end)
	end
end

local function NAProtection(inst,var)
	if not inst then return end
	if var then
		inst[var] = "\0"
	else
		inst.Name = "\0"
	end
	inst.Archivable = false
end

local function NaProtectUI(gui)
	local INV = "\0"
	local MAX_DO = 0x7FFFFFFF
	local target = (gethui and gethui()) or SafeGetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or SafeGetService("CoreGui") or SafeGetService("Players").LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
	if not target then return end
	pcall(function() gui.Archivable = false end)
	gui.Name = INV
	gui.Parent = target
	if gui:IsA("ScreenGui") then
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		gui.DisplayOrder = MAX_DO
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
	end
	local props = {
		Parent = target,
		Name = INV,
		Archivable = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = MAX_DO,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	}
	if not gui:IsA("ScreenGui") then
		props.ZIndexBehavior = nil
		props.DisplayOrder = nil
		props.ResetOnSpawn = nil
		props.IgnoreGuiInset = nil
	end
	for prop, val in pairs(props) do
		if val ~= nil then
			gui:GetPropertyChangedSignal(prop):Connect(function()
				if gui[prop] ~= val then
					pcall(function() gui[prop] = val end)
				end
			end)
		end
	end
	gui.AncestryChanged:Connect(function()
		if gui.Parent ~= target then
			pcall(function() gui.Parent = target end)
		end
	end)
	local hb
	hb = SafeGetService("RunService").Heartbeat:Connect(function()
		for prop, val in pairs(props) do
			if val ~= nil and gui[prop] ~= val then
				pcall(function() gui[prop] = val end)
			end
		end
		if not gui.Parent then
			pcall(function() hb:Disconnect() end)
		end
	end)
	return gui
end

local guiii = {}
guiii.draggerV2 = function(ui, dragui)
	dragui = dragui or ui
	local dragging, dragInput, dragStart, startPos
	local anchor = ui.AnchorPoint
	local sg = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui.Parent

	local function sClamp(v, lo, hi)
		if hi < lo then hi = lo end
		return math.clamp(v, lo, hi)
	end

	local function upd(input)
		local _ = pcall(function()
			local p = sg.AbsoluteSize
			local s = ui.AbsoluteSize
			if p.X <= 0 or p.Y <= 0 then return end
			local sx = startPos.X.Scale * p.X + startPos.X.Offset
			local sy = startPos.Y.Scale * p.Y + startPos.Y.Offset
			local dx = input.Position.X - dragStart.X
			local dy = input.Position.Y - dragStart.Y
			local minX = anchor.X * s.X
			local maxX = p.X - (1 - anchor.X) * s.X
			local minY = anchor.Y * s.Y
			local maxY = p.Y - (1 - anchor.Y) * s.Y
			local nx = sClamp(sx + dx, minX, maxX)
			local ny = sClamp(sy + dy, minY, maxY)
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0)
		end)
	end

	NAlib.disconnect("DraggerV2_"..ui:GetDebugId())

	NAlib.connect("DraggerV2_"..ui:GetDebugId(), dragui.InputBegan:Connect(function(input)
		local _ = pcall(function()
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = ui.Position
				local c = input.Changed:Connect(function()
					local _2 = pcall(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end)
				NAlib.connect("DraggerV2_"..ui:GetDebugId(), c)
			end
		end)
	end))

	NAlib.connect("DraggerV2_"..ui:GetDebugId(), dragui.InputChanged:Connect(function(input)
		local _ = pcall(function()
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
	end))

	NAlib.connect("DraggerV2_"..ui:GetDebugId(), UIS.InputChanged:Connect(function(input)
		local _ = pcall(function()
			if input == dragInput and dragging then
				upd(input)
			end
		end)
	end))

	local function clampToView()
		local ok, err = pcall(function()
			local p = sg.AbsoluteSize
			local s = ui.AbsoluteSize
			if p.X <= 0 or p.Y <= 0 then return end
			local pos = ui.Position
			local ax = pos.X.Scale * p.X + pos.X.Offset
			local ay = pos.Y.Scale * p.Y + pos.Y.Offset
			local minX = anchor.X * s.X
			local maxX = p.X - (1 - anchor.X) * s.X
			local minY = anchor.Y * s.Y
			local maxY = p.Y - (1 - anchor.Y) * s.Y
			local nx = sClamp(ax, minX, maxX)
			local ny = sClamp(ay, minY, maxY)
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0)
		end)
		if not ok then warn("[DraggerV2] Clamp error:", err) end
	end

	NAlib.connect("DraggerV2_"..ui:GetDebugId(), sg:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampToView))
	if ui and ui.GetPropertyChangedSignal then
		NAlib.connect("DraggerV2_"..ui:GetDebugId(), ui:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampToView))
	end
	clampToView()

	if ui and NAlib.isProperty(ui, "Active") then
		NAlib.setProperty(ui, "Active", true)
	end
	if dragui and NAlib.isProperty(dragui, "Active") then
		NAlib.setProperty(dragui, "Active", true)
	end
	pcall(function() ui.Active = true end)
	pcall(function() dragui.Active = true end)
end

local repo = "ltseverydayyou/Nameless-Admin"
local br = "main"

local chans = {
	main = {
		key = "main",
		name = "Nameless Admin",
		path = "Source.lua",
		headRaw = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua",
	},
	test = {
		key = "test",
		name = "NA Testing",
		path = "NA testing.lua",
		headRaw = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua",
	},
}

local function getCommits(ch, n)
	local ok, res = pcall(function()
		local u = "https://api.github.com/repos/"..repo.."/commits?path="..hs:UrlEncode(ch.path).."&sha="..br.."&per_page="..tostring(n)
		local r = game:HttpGet(u)
		return hs:JSONDecode(r)
	end)
	if not ok or not res then
		return nil, "Failed to fetch commits"
	end
	if type(res) ~= "table" or #res == 0 then
		return nil, "No commits found"
	end
	local list = {}
	for _, v in ipairs(res) do
		local c = v.commit or {}
		local a = c.author or {}
		table.insert(list, {
			sha = v.sha,
			date = a.date or "N/A",
			msg = c.message or "No message",
		})
	end
	return list
end

local function shortSha(s)
	if not s then return "???????" end
	return string.sub(s, 1, 7)
end

local function mkRawFromCommit(ch, sha)
	local p = ch.path:gsub(" ", "%%20")
	return "https://raw.githubusercontent.com/"..repo.."/"..sha.."/"..p
end

local gui = Instance.new("ScreenGui")
gui.Name = "NA_VersionPicker"
gui.ResetOnSpawn = false

pcall(function() NaProtectUI(gui) end)

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 420, 0, 320)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(0, 8)
fc.Parent = frame

local top = Instance.new("Frame")
top.Name = "TopBar"
top.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
top.BorderSizePixel = 0
top.Size = UDim2.new(1, 0, 0, 36)
top.Parent = frame

local tc = Instance.new("UICorner")
tc.CornerRadius = UDim.new(0, 8)
tc.Parent = top

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Nameless Admin Loader"
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local close = Instance.new("TextButton")
close.BackgroundTransparency = 1
close.Size = UDim2.new(0, 40, 1, 0)
close.Position = UDim2.new(1, -40, 0, 0)
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextSize = 24
close.TextColor3 = Color3.fromRGB(220, 80, 80)
close.Parent = top

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

guiii.draggerV2(frame, top)

local pickFrame = Instance.new("Frame")
pickFrame.Name = "ChannelPicker"
pickFrame.BackgroundTransparency = 1
pickFrame.Size = UDim2.new(1, -20, 1, -46)
pickFrame.Position = UDim2.new(0, 10, 0, 40)
pickFrame.Parent = frame

local pfInfo = Instance.new("TextLabel")
pfInfo.BackgroundTransparency = 1
pfInfo.Size = UDim2.new(1, 0, 0, 40)
pfInfo.Position = UDim2.new(0, 0, 0, 0)
pfInfo.Font = Enum.Font.Gotham
pfInfo.TextSize = 14
pfInfo.TextColor3 = Color3.fromRGB(210, 210, 210)
pfInfo.TextWrapped = true
pfInfo.TextXAlignment = Enum.TextXAlignment.Left
pfInfo.TextYAlignment = Enum.TextYAlignment.Top
pfInfo.Text = "Pick which branch to use, then choose a specific version (commit) from that branch."
pfInfo.Parent = pickFrame

local pfList = Instance.new("UIListLayout")
pfList.FillDirection = Enum.FillDirection.Vertical
pfList.HorizontalAlignment = Enum.HorizontalAlignment.Center
pfList.VerticalAlignment = Enum.VerticalAlignment.Top
pfList.Padding = UDim.new(0, 10)
pfList.SortOrder = Enum.SortOrder.LayoutOrder
pfList.Parent = pickFrame

pfInfo.LayoutOrder = 1

local function mkChanBtn(ch, order)
	local b = Instance.new("TextButton")
	b.Name = ch.key.."_Chan"
	b.Size = UDim2.new(1, 0, 0, 72)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	b.BorderSizePixel = 0
	b.Text = ""
	b.LayoutOrder = order
	b.Parent = pickFrame

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 6)
	bc.Parent = b

	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.Size = UDim2.new(1, -14, 0, 26)
	titleLbl.Position = UDim2.new(0, 7, 0, 6)
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 18
	titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLbl.TextXAlignment = Enum.TextXAlignment.Center
	titleLbl.TextYAlignment = Enum.TextYAlignment.Top
	titleLbl.Text = ch.name
	titleLbl.Parent = b

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Size = UDim2.new(1, -14, 0, 26)
	sub.Position = UDim2.new(0, 7, 0, 38)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 12
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextYAlignment = Enum.TextYAlignment.Top
	sub.TextColor3 = Color3.fromRGB(200, 200, 210)
	sub.Text = "View latest and older versions for this script."
	sub.Parent = b

	return b
end

local mainBtn = mkChanBtn(chans.main, 2)
local testBtn = mkChanBtn(chans.test, 3)

local verFrame = Instance.new("Frame")
verFrame.Name = "VersionPicker"
verFrame.BackgroundTransparency = 1
verFrame.Size = UDim2.new(1, -20, 1, -46)
verFrame.Position = UDim2.new(0, 10, 0, 40)
verFrame.Visible = false
verFrame.Parent = frame

local back = Instance.new("TextButton")
back.Name = "Back"
back.Size = UDim2.new(0, 70, 0, 24)
back.Position = UDim2.new(0, 0, 0, 0)
back.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
back.BorderSizePixel = 0
back.Font = Enum.Font.GothamBold
back.Text = "< Back"
back.TextSize = 14
back.TextColor3 = Color3.fromRGB(230, 230, 230)
back.Parent = verFrame

local backC = Instance.new("UICorner")
backC.CornerRadius = UDim.new(0, 4)
backC.Parent = back

local verTitle = Instance.new("TextLabel")
verTitle.BackgroundTransparency = 1
verTitle.Size = UDim2.new(1, -80, 0, 24)
verTitle.Position = UDim2.new(0, 80, 0, 0)
verTitle.Font = Enum.Font.GothamBold
verTitle.TextSize = 16
verTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
verTitle.TextXAlignment = Enum.TextXAlignment.Left
verTitle.Text = ""
verTitle.Parent = verFrame

local verInfo = Instance.new("TextLabel")
verInfo.BackgroundTransparency = 1
verInfo.Size = UDim2.new(1, 0, 0, 32)
verInfo.Position = UDim2.new(0, 0, 0, 26)
verInfo.Font = Enum.Font.Gotham
verInfo.TextSize = 13
verInfo.TextColor3 = Color3.fromRGB(210, 210, 210)
verInfo.TextXAlignment = Enum.TextXAlignment.Left
verInfo.TextYAlignment = Enum.TextYAlignment.Top
verInfo.TextWrapped = true
verInfo.Text = ""
verInfo.Parent = verFrame

local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "List"
listFrame.BackgroundTransparency = 0.2
listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
listFrame.BorderSizePixel = 0
listFrame.Size = UDim2.new(1, 0, 1, -70)
listFrame.Position = UDim2.new(0, 0, 0, 60)
listFrame.ScrollBarThickness = 6
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.Parent = verFrame

local lfC = Instance.new("UICorner")
lfC.CornerRadius = UDim.new(0, 6)
lfC.Parent = listFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = listFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
end)

local currChan = nil

local function loadVer(ch, v)
	frame.Visible = false
	gui.Enabled = false
	local raw
	if v and v.sha then
		raw = mkRawFromCommit(ch, v.sha)
	else
		raw = ch.headRaw
	end
	local ok, err = pcall(function()
		loadstring(game:HttpGet(raw))()
	end)
	if not ok then
		rconsoleerr("Failed to load "..ch.name..": "..tostring(err))
		gui.Enabled = true
		frame.Visible = true
	end
end

local function clearList()
	for _, c in ipairs(listFrame:GetChildren()) do
		if c:IsA("TextButton") then
			c:Destroy()
		end
	end
end

local function mkVerBtn(ch, v, idx, total)
	local b = Instance.new("TextButton")
	b.Name = "Ver_"..tostring(idx)
	b.Size = UDim2.new(1, -10, 0, 70)
	b.BackgroundColor3 = idx == 1 and Color3.fromRGB(55, 90, 140) or Color3.fromRGB(40, 40, 55)
	b.BorderSizePixel = 0
	b.Text = ""
	b.Parent = listFrame

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 4)
	bc.Parent = b

	local topLine = Instance.new("TextLabel")
	topLine.BackgroundTransparency = 1
	topLine.Size = UDim2.new(1, -12, 0, 22)
	topLine.Position = UDim2.new(0, 6, 0, 6)
	topLine.Font = Enum.Font.GothamBold
	topLine.TextSize = 13
	topLine.TextXAlignment = Enum.TextXAlignment.Left
	topLine.TextYAlignment = Enum.TextYAlignment.Top
	topLine.TextColor3 = Color3.fromRGB(255, 255, 255)
	local tag = idx == 1 and "Latest" or ("Commit #"..tostring(idx))
	local sha = shortSha(v.sha)
	topLine.Text = tag.."  ("..sha..")"
	topLine.Parent = b

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Size = UDim2.new(1, -12, 0, 36)
	sub.Position = UDim2.new(0, 6, 0, 28)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 12
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextYAlignment = Enum.TextYAlignment.Top
	sub.TextColor3 = Color3.fromRGB(210, 210, 220)
	local msg = v.msg or "No message"
	if #msg > 80 then
		msg = string.sub(msg, 1, 77).."..."
	end
	sub.Text = tostring(v.date or "N/A").."  |  "..msg
	sub.Parent = b

	b.MouseButton1Click:Connect(function()
		loadVer(ch, v)
	end)
end

local function openChan(ch)
	currChan = ch
	pickFrame.Visible = false
	verFrame.Visible = true
	verTitle.Text = ch.name.." Versions"
	verInfo.Text = "Fetching versions from GitHub for "..ch.path.."..."
	clearList()

	task.spawn(function()
		local list, err = getCommits(ch, 100)
		if not list then
			verInfo.Text = err.."  Loading latest from branch."
			mkVerBtn(ch, {sha = nil, date = "N/A", msg = "Latest from "..br}, 1, 1)
			return
		end
		verInfo.Text = "Top is the latest version. Older commits are below ("..tostring(#list).." total)."
		for i, v in ipairs(list) do
			mkVerBtn(ch, v, i, #list)
		end
	end)
end

back.MouseButton1Click:Connect(function()
	verFrame.Visible = false
	pickFrame.Visible = true
	clearList()
end)

mainBtn.MouseButton1Click:Connect(function()
	openChan(chans.main)
end)

testBtn.MouseButton1Click:Connect(function()
	openChan(chans.test)
end)