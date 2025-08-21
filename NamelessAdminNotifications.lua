local function G(n)
	local s = game:GetService(n)
	if cloneref then s = cloneref(s) end
	return s
end

local tw = G("TweenService")
local rs = G("RunService")
local uis = G("UserInputService")
local plrs = G("Players")
local cg = G("CoreGui")

local function pick()
	local a = nil
	pcall(function() if gethui then a = gethui() end end)
	return a or cg:FindFirstChildWhichIsA("ScreenGui") or cg or plrs.LocalPlayer:FindFirstChildWhichIsA("PlayerGui") or plrs.LocalPlayer:WaitForChild("PlayerGui")
end

local function findGui()
	local a = nil
	pcall(function() if gethui then a = gethui() end end)
	local b = cg:FindFirstChildWhichIsA("ScreenGui")
	local c = cg
	local d = plrs.LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
	for _,p in ipairs({a,b,c,d}) do
		if typeof(p)=="Instance" then
			local g = p:FindFirstChild("EnhancedNotif")
			if g then return g,p end
		end
	end
end

local CLR = {
	Text=Color3.fromRGB(235,235,235),
	Title=Color3.fromRGB(255,255,255),
	Close=Color3.fromRGB(220,70,70),
	Btn=Color3.fromRGB(40,40,40),
	BtnH=Color3.fromRGB(60,60,60),
	BtnD=Color3.fromRGB(30,30,30),
	Stroke=Color3.fromRGB(255,255,255),
	Glow=Color3.fromRGB(0,255,180),
	Card=Color3.fromRGB(20,20,20),
	Shadow=Color3.fromRGB(0,0,0),
	Prog=Color3.fromRGB(255,255,255),
	PH=Color3.fromRGB(180,180,180)
}

local PAD,GAP = 12,10

local ex, exParent = findGui()
if getgenv().EnhancedNotifs and ex then return getgenv().EnhancedNotifs end

local root = exParent or pick()
local gui = ex or Instance.new("ScreenGui")
gui.Name = "EnhancedNotif"
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 2147483647
gui.ResetOnSpawn = false
if not gui.Parent then gui.Parent = root end

local function nW() local w=gui.AbsoluteSize.X return math.floor(math.clamp(w*0.28,280,420)) end
local function wW() local w=gui.AbsoluteSize.X return math.floor(math.clamp(w*0.36,340,560)) end

local stackBR = gui:FindFirstChild("StackBR") or Instance.new("Frame")
stackBR.Name = "StackBR"
stackBR.AnchorPoint = Vector2.new(1,1)
stackBR.Position = UDim2.new(1,-20,1,-20)
stackBR.Size = UDim2.new(0,nW(),1,0)
stackBR.BackgroundTransparency = 1
stackBR.Parent = gui
if not stackBR:FindFirstChildOfClass("UIListLayout") then
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0,GAP)
	l.FillDirection = Enum.FillDirection.Vertical
	l.HorizontalAlignment = Enum.HorizontalAlignment.Right
	l.VerticalAlignment = Enum.VerticalAlignment.Bottom
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = stackBR
end

local stackTop = gui:FindFirstChild("StackTop") or Instance.new("Frame")
stackTop.Name = "StackTop"
stackTop.AnchorPoint = Vector2.new(0.5,0)
stackTop.Position = UDim2.new(0.5,0,0,20)
stackTop.Size = UDim2.new(0,wW(),1,0)
stackTop.BackgroundTransparency = 1
stackTop.Parent = gui
if not stackTop:FindFirstChildOfClass("UIListLayout") then
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0,GAP)
	l.FillDirection = Enum.FillDirection.Vertical
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.VerticalAlignment = Enum.VerticalAlignment.Top
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Parent = stackTop
end

gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	stackBR.Size = UDim2.new(0,nW(),1,0)
	stackTop.Size = UDim2.new(0,wW(),1,0)
end)

local function rip(p, pos)
	p.ClipsDescendants = true
	local r = Instance.new("Frame")
	r.BackgroundColor3 = Color3.new(1,1,1)
	r.BackgroundTransparency = 0.8
	r.ZIndex = p.ZIndex + 1
	r.Size = UDim2.fromOffset(0,0)
	r.AnchorPoint = Vector2.new(0.5,0.5)
	r.Position = UDim2.fromOffset(pos.X - p.AbsolutePosition.X, pos.Y - p.AbsolutePosition.Y)
	Instance.new("UICorner", r).CornerRadius = UDim.new(1,0)
	r.Parent = p
	local d = math.max(p.AbsoluteSize.X,p.AbsoluteSize.Y)*2
	tw:Create(r,TweenInfo.new(0.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(d,d),BackgroundTransparency=1}):Play()
	task.delay(0.65,function() if r then r:Destroy() end end)
end

local function cntH(c)
	local lay = c:FindFirstChildOfClass("UIListLayout")
	local pad = c:FindFirstChildOfClass("UIPadding")
	local top = (pad and pad.PaddingTop.Offset or 0)
	local bot = (pad and pad.PaddingBottom.Offset or 0)
	local last = -1
	for _=1,30 do
		rs.Heartbeat:Wait()
		local h = (lay and lay.AbsoluteContentSize.Y or 0) + top + bot
		if math.abs(h-last) < 1 then return h end
		last = h
	end
	return math.max(0,last)
end

local function setA(inst,a)
	for _,d in ipairs(inst:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then d.TextTransparency = a end
		if d:IsA("ImageLabel") then d.ImageTransparency = a end
	end
end

local function stgIn(inst)
	local t = TweenInfo.new(0.26,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	for _,d in ipairs(inst:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then d.TextTransparency = 1 tw:Create(d,t,{TextTransparency=0}):Play()
		elseif d:IsA("ImageLabel") then d.ImageTransparency = 1 tw:Create(d,t,{ImageTransparency=0}):Play()
		end
	end
end

local function mkBtn(parent, text, z)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.Text = text or ""
	b.TextSize = 14
	b.Font = Enum.Font.Gotham
	b.TextColor3 = CLR.Text
	b.RichText = true
	b.BackgroundColor3 = CLR.Btn
	b.Size = UDim2.new(0,100,0,32)
	b.ZIndex = z or 10
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,18)
	b.Parent = parent
	b.MouseEnter:Connect(function() tw:Create(b,TweenInfo.new(0.12,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundColor3=CLR.BtnH}):Play() end)
	b.MouseLeave:Connect(function() tw:Create(b,TweenInfo.new(0.12,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundColor3=CLR.Btn}):Play() end)
	b.MouseButton1Down:Connect(function() tw:Create(b,TweenInfo.new(0.08,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{BackgroundColor3=CLR.BtnD}):Play() end)
	b.MouseButton1Up:Connect(function() tw:Create(b,TweenInfo.new(0.08,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundColor3=CLR.BtnH}):Play() end)
	b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rip(b,i.Position) end end)
	return b
end

local function mkHdr(parent, z)
	local hdr = Instance.new("Frame")
	hdr.Name = "Header"
	hdr.BackgroundTransparency = 1
	hdr.Size = UDim2.new(1,0,0,32)
	hdr.ZIndex = z
	hdr.Parent = parent

	local act = Instance.new("Frame")
	act.Name = "Actions"
	act.AnchorPoint = Vector2.new(1,0.5)
	act.Position = UDim2.new(1,-PAD,0.5,0)
	act.Size = UDim2.new(0,0,1,0)
	act.AutomaticSize = Enum.AutomaticSize.X
	act.BackgroundTransparency = 1
	act.ZIndex = z+3
	act.Parent = hdr
	local lay = Instance.new("UIListLayout", act)
	lay.FillDirection = Enum.FillDirection.Horizontal
	lay.HorizontalAlignment = Enum.HorizontalAlignment.Right
	lay.VerticalAlignment = Enum.VerticalAlignment.Center
	lay.Padding = UDim.new(0,6)

	local cls = Instance.new("TextButton")
	cls.Name = "Close"
	cls.AutoButtonColor = false
	cls.Size = UDim2.fromOffset(24,24)
	cls.Text = "×"
	cls.Font = Enum.Font.GothamBold
	cls.TextSize = 18
	cls.TextColor3 = Color3.new(1,1,1)
	cls.BackgroundColor3 = CLR.Close
	cls.ZIndex = z+4
	Instance.new("UICorner", cls).CornerRadius = UDim.new(1,0)
	cls.Parent = act
	cls.MouseEnter:Connect(function() tw:Create(cls,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(255,100,100)}):Play() end)
	cls.MouseLeave:Connect(function() tw:Create(cls,TweenInfo.new(0.12),{BackgroundColor3=CLR.Close}):Play() end)

	local ttl = Instance.new("TextLabel")
	ttl.Name = "Title"
	ttl.AnchorPoint = Vector2.new(0,0.5)
	ttl.Position = UDim2.new(0,PAD,0.5,0)
	ttl.Size = UDim2.new(1,-(PAD + act.AbsoluteSize.X + PAD),1,0)
	ttl.BackgroundTransparency = 1
	ttl.TextTruncate = Enum.TextTruncate.AtEnd
	ttl.Font = Enum.Font.GothamBold
	ttl.TextScaled = true
	ttl.TextXAlignment = Enum.TextXAlignment.Left
	ttl.TextYAlignment = Enum.TextYAlignment.Center
	ttl.TextColor3 = CLR.Title
	ttl.RichText = true
	ttl.ZIndex = z+2
	ttl.Parent = hdr

	local function fit()
		ttl.Size = UDim2.new(1,-(PAD + act.AbsoluteSize.X + PAD),1,0)
	end
	act:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
	fit()

	return hdr, ttl, cls, act
end

local function mkCard(w, baseZ)
	local z = baseZ or (100 + #stackBR:GetChildren()*2)
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.LayoutOrder = os.clock()*1000
	card.Size = UDim2.new(0,w,0,0)
	card.BackgroundColor3 = CLR.Card
	card.BackgroundTransparency = 0.18
	card.ZIndex = z
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	local st = Instance.new("UIStroke")
	st.Color = CLR.Stroke
	st.Thickness = 1.6
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Transparency = 0.25
	st.Parent = card
	local cor = Instance.new("UICorner")
	cor.CornerRadius = UDim.new(0,20)
	cor.Parent = card
	local sc = Instance.new("UIScale")
	sc.Scale = 0.94
	sc.Parent = card

	local hdr, ttl, cls, act = mkHdr(card, z+6)

	local cnt = Instance.new("Frame")
	cnt.Name = "Content"
	cnt.BackgroundTransparency = 1
	cnt.Size = UDim2.new(1,0,0,0)
	cnt.AutomaticSize = Enum.AutomaticSize.Y
	cnt.ZIndex = z+1
	cnt.Parent = card
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0,PAD)
	pad.PaddingRight = UDim.new(0,PAD)
	pad.PaddingTop = UDim.new(0,32 + PAD-2)
	pad.PaddingBottom = UDim.new(0,PAD+10)
	pad.Parent = cnt
	local col = Instance.new("UIListLayout")
	col.Padding = UDim.new(0,8)
	col.FillDirection = Enum.FillDirection.Vertical
	col.HorizontalAlignment = Enum.HorizontalAlignment.Left
	col.SortOrder = Enum.SortOrder.LayoutOrder
	col.Parent = cnt

	local ftr = Instance.new("Frame")
	ftr.Name = "Footer"
	ftr.AnchorPoint = Vector2.new(0,1)
	ftr.Position = UDim2.new(0,0,1,0)
	ftr.Size = UDim2.new(1,0,0,10)
	ftr.BackgroundTransparency = 1
	ftr.ZIndex = z+2
	ftr.Parent = card

	local trk = Instance.new("Frame")
	trk.Name = "ProgressTrack"
	trk.AnchorPoint = Vector2.new(0.5,0.5)
	trk.Position = UDim2.new(0.5,0,0.5,0)
	trk.Size = UDim2.new(0.92,0,0,3)
	trk.BackgroundTransparency = 0.65
	trk.BackgroundColor3 = CLR.Prog
	trk.BorderSizePixel = 0
	trk.ZIndex = z+3
	Instance.new("UICorner", trk).CornerRadius = UDim.new(0,18)
	trk.Parent = ftr

	local fil = Instance.new("Frame")
	fil.Name = "ProgressFill"
	fil.AnchorPoint = Vector2.new(0,0.5)
	fil.Position = UDim2.new(0,0,0.5,0)
	fil.Size = UDim2.new(1,0,1,0)
	fil.BackgroundTransparency = 0.1
	fil.BackgroundColor3 = CLR.Prog
	fil.BorderSizePixel = 0
	fil.ZIndex = trk.ZIndex+1
	Instance.new("UICorner", fil).CornerRadius = UDim.new(0,18)
	fil.Parent = trk

	return card, hdr, ttl, cls, act, cnt, ftr, trk, fil, st, sc
end

local STATE = setmetatable({}, {__mode="k"})
local function ctx(card) local s=STATE[card]; if not s then s={} STATE[card]=s end return s end

local function glowOn(b, store)
	local g = b:FindFirstChild("GlowStroke") or Instance.new("UIStroke")
	g.Name = "GlowStroke"
	g.Parent = b
	g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	g.Color = CLR.Glow
	g.Thickness = 2
	g.Transparency = 0.35
	store.tog = store.tog or {}
	if store.tog[b] then for _,t in ipairs(store.tog[b]) do pcall(function() t:Cancel() end) end end
	local t1 = tw:Create(g,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=0.05})
	local t2 = tw:Create(g,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Transparency=0.5})
	store.tog[b]={t1,t2}
	t1.Completed:Connect(function() if store.tog and store.tog[b] then t2:Play() end end)
	t2.Completed:Connect(function() if store.tog and store.tog[b] then t1:Play() end end)
	t1:Play()
end
local function glowOff(b, store)
	if store.tog and store.tog[b] then for _,t in ipairs(store.tog[b]) do pcall(function() t:Cancel() end) end store.tog[b]=nil end
	local g = b:FindFirstChild("GlowStroke"); if g then g.Transparency = 1 end
end

local function selGlowOn(b, s)
	local g = b:FindFirstChild("SelStroke") or Instance.new("UIStroke")
	g.Name = "SelStroke"
	g.Parent = b
	g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	g.Color = CLR.Glow
	g.Thickness = 2
	g.Transparency = 0.3
	local t1 = tw:Create(g,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=0.05})
	local t2 = tw:Create(g,TweenInfo.new(0.5,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Transparency=0.5})
	s.g = s.g or {}
	if s.g[b] then for _,t in ipairs(s.g[b]) do pcall(function() t:Cancel() end) end end
	s.g[b]={t1,t2}
	t1.Completed:Connect(function() if s.g and s.g[b] then t2:Play() end end)
	t2.Completed:Connect(function() if s.g and s.g[b] then t1:Play() end end)
	t1:Play()
end
local function selGlowOff(b, s)
	if s.g and s.g[b] then for _,t in ipairs(s.g[b]) do pcall(function() t:Cancel() end) end s.g[b]=nil end
	local g = b:FindFirstChild("SelStroke"); if g then g.Transparency = 1 end
end

local function clearSel(owner)
	local s = ctx(owner)
	s.sel = {}
	if s.btns then
		for b,_ in pairs(s.btns) do
			selGlowOff(b, s)
			tw:Create(b,TweenInfo.new(0.1),{BackgroundColor3=CLR.Btn}):Play()
		end
	end
	if s.ok then s.ok.Visible = false end
end

local function mkBtnArea(cnt, btnList, owner, z)
	if not btnList or #btnList==0 then return end
	local fr = Instance.new("Frame")
	fr.BackgroundTransparency = 1
	fr.Size = UDim2.new(1,0,0,0)
	fr.AutomaticSize = Enum.AutomaticSize.Y
	fr.ZIndex = (z or 10)
	fr.Parent = cnt

	local grid = Instance.new("UIGridLayout", fr)
	local cols = (#btnList==1) and 1 or math.min(3,#btnList)
	grid.CellPadding = UDim2.new(0,8,0,8)
	grid.FillDirectionMaxCells = cols
	grid.SortOrder = Enum.SortOrder.LayoutOrder

	local function refresh()
		if cols==1 then
			grid.CellSize = UDim2.new(1,0,0,32)
		else
			local w = fr.AbsoluteSize.X
			local bw = math.max(80, math.floor((w - (cols-1)*8)/cols))
			grid.CellSize = UDim2.new(0,bw,0,32)
		end
	end
	fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	task.defer(refresh)

	local s = ctx(owner)
	s.sel = s.sel or {}
	s.btns = s.btns or {}

	for _,info in ipairs(btnList) do
		local b = mkBtn(fr, info.Text or "", (z or 10)+1)
		s.btns[b] = info
		b.MouseButton1Click:Connect(function()
			if s.multi then
				local i = table.find(s.sel, info)
				if i then
					table.remove(s.sel,i)
					tw:Create(b,TweenInfo.new(0.1),{BackgroundColor3=CLR.BtnH}):Play()
					selGlowOff(b, s)
				else
					table.insert(s.sel, info)
					tw:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(0,170,100)}):Play()
					selGlowOn(b, s)
				end
				if s.ok then s.ok.Visible = #s.sel>0 end
			else
				if info.Callback then
					local t = s.inp and s.inp.Text or ""
					info.Callback(t)
				end
				if s.close then s.close() end
			end
		end)
	end
end

local function attachTimer(card, fil, dur)
	if not fil then return end
	local hover = uis.MouseEnabled
	local run = true
	local frac = 1
	local tween
	local function playFrom(f)
		fil.Size = UDim2.new(f,0,1,0)
		if tween then tween:Cancel() end
		local d = math.max(0.01, dur*f)
		tween = tw:Create(fil,TweenInfo.new(d,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Size=UDim2.new(0,0,1,0)})
		tween.Completed:Connect(function()
			if run and fil.Size.X.Scale<=0.001 then local s=ctx(card); if s.close then s.close() end end
		end)
		tween:Play()
	end
	playFrom(frac)
	if hover then
		card.MouseEnter:Connect(function()
			if not run then return end
			run=false
			if tween then tween:Cancel() end
			frac = fil.Size.X.Scale
		end)
		card.MouseLeave:Connect(function()
			if run then return end
			run=true
			playFrom(frac)
		end)
	end
end

local function appear(card, st, sc, tgt, from, cnt)
	setA(cnt,1)
	card.Rotation = from and from.rot or -1.5
	card.BackgroundTransparency = 0.4
	st.Transparency = 0.7
	st.Thickness = 2.2
	sc.Scale = 0.92
	if from and from.offsetY then
		card.Position = UDim2.new(card.Position.X.Scale,card.Position.X.Offset,card.Position.Y.Scale,card.Position.Y.Offset+from.offsetY)
	end
	local c1 = tw:Create(card,TweenInfo.new(0.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size=tgt,BackgroundTransparency=0.18,Rotation=0})
	local s1 = tw:Create(sc,TweenInfo.new(0.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Scale=1.02})
	local s2 = tw:Create(sc,TweenInfo.new(0.16,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Scale=1})
	local stw = tw:Create(st,TweenInfo.new(0.28,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency=0.25,Thickness=1.6})
	c1:Play() s1:Play() stw:Play()
	s1.Completed:Connect(function() s2:Play() end)
	stgIn(cnt)
end

local function disappear(card, sc)
	local sA = tw:Create(sc,TweenInfo.new(0.12,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Scale=1.015})
	local sB = tw:Create(sc,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Scale=0.96})
	local cB = tw:Create(card,TweenInfo.new(0.2,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{BackgroundTransparency=0.42})
	sA:Play()
	sA.Completed:Connect(function()
		sB:Play() cB:Play()
		task.delay(0.12,function()
			tw:Create(card,TweenInfo.new(0.18,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{Size=UDim2.new(card.Size.X.Scale,card.Size.X.Offset,0,0)}):Play()
		end)
	end)
end

local function openIn(card, parent, ftr, trk, fil, st, sc, from, cnt)
	card.Parent = parent
	card.Size = UDim2.new(card.Size.X.Scale,card.Size.X.Offset,0,0)
	card.Visible = true
	local h = cntH(cnt) + ((trk and trk.Visible) and ftr.AbsoluteSize.Y or 0)
	appear(card,st,sc,UDim2.new(card.Size.X.Scale,card.Size.X.Offset,0,h),from,cnt)
end

local function close(card)
	if not card then return end
	disappear(card, card:FindFirstChildOfClass("UIScale"))
	task.delay(0.42,function() if card then STATE[card]=nil card:Destroy() end end)
end

local function drag(ui, handle)
	handle = handle or ui
	local on, start, origin
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			on=true start=i.Position origin=ui.Position
		end
	end)
	handle.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			on=false
		end
	end)
	uis.InputChanged:Connect(function(i)
		if on and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d = i.Position-start
			ui.Position = UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y)
		end
	end)
end

local function Notify(p)
	p = typeof(p)=="table" and p or {}
	local w = nW()
	local card,hdr,ttl,cls,act,cnt,ftr,trk,fil,st,sc = mkCard(w,nil)
	ttl.Text = p.Title or "Notification"
	cls.MouseButton1Click:Connect(function() close(card) end)
	cls.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rip(cls,i.Position) end end)

	if p.Description and p.Description~="" then
		local d = Instance.new("TextLabel")
		d.BackgroundTransparency = 1
		d.TextColor3 = CLR.Text
		d.TextXAlignment = Enum.TextXAlignment.Left
		d.TextYAlignment = Enum.TextYAlignment.Top
		d.TextWrapped = true
		d.RichText = true
		d.Font = Enum.Font.Gotham
		d.TextSize = 14
		d.AutomaticSize = Enum.AutomaticSize.Y
		d.Size = UDim2.new(1,0,0,0)
		d.ZIndex = card.ZIndex+2
		d.Text = p.Description
		d.Parent = cnt
	end

	local inp
	if p.InputField then
		inp = Instance.new("TextBox")
		inp.Size = UDim2.new(1,0,0,34)
		inp.ClearTextOnFocus = false
		inp.TextXAlignment = Enum.TextXAlignment.Left
		inp.TextYAlignment = Enum.TextYAlignment.Center
		inp.Font = Enum.Font.Gotham
		inp.TextSize = 14
		inp.TextColor3 = CLR.Text
		inp.RichText = true
		inp.BackgroundColor3 = CLR.Btn
		inp.Text = ""
		inp.PlaceholderText = p.Placeholder or "Type here…"
		inp.PlaceholderColor3 = CLR.PH
		inp.ZIndex = card.ZIndex+2
		Instance.new("UICorner", inp).CornerRadius = UDim.new(0,18)
		inp.Parent = cnt
		inp.Focused:Connect(function() tw:Create(inp,TweenInfo.new(0.12),{BackgroundColor3=CLR.BtnH}):Play() end)
		inp.FocusLost:Connect(function() tw:Create(inp,TweenInfo.new(0.12),{BackgroundColor3=CLR.Btn}):Play() end)
	end

	local s = ctx(card)
	s.multi=false
	s.sel={}
	s.inp=inp
	s.close=function() close(card) end

	local btns = p.Buttons or {}
	if #btns>0 then mkBtnArea(cnt, btns, card, card.ZIndex+2) end

	local ok, m
	if #btns>2 then
		ok = mkBtn(act,"✓",act.ZIndex+1)
		ok.Size = UDim2.fromOffset(24,24)
		ok.Visible=false
		ok.MouseButton1Click:Connect(function()
			for _,info in ipairs(s.sel) do
				if info.Callback then info.Callback(s.inp and s.inp.Text or "") end
			end
			s.close()
		end)
		m = mkBtn(act,"M",act.ZIndex+1)
		m.Size = UDim2.fromOffset(24,24)
		m.MouseButton1Click:Connect(function()
			s.multi = not s.multi
			tw:Create(m,TweenInfo.new(0.1),{BackgroundColor3 = s.multi and Color3.fromRGB(0,170,100) or CLR.Btn}):Play()
			if s.multi then glowOn(m,s) else glowOff(m,s) clearSel(card) end
			ok.Visible = s.multi and (#s.sel>0)
		end)
		s.ok = ok
	end

	trk.Visible = (#btns==0)
	openIn(card, stackBR, ftr, trk, fil, st, sc, {offsetY=10,rot=-1.2}, cnt)
	if (p.Duration or 5)>0 and #btns==0 then attachTimer(card, fil, p.Duration or 5) end
	return card
end

local function Window(p)
	p = typeof(p)=="table" and p or {}
	local w = wW()
	local card,hdr,ttl,cls,act,cnt,ftr,trk,fil,st,sc = mkCard(w,nil)
	ttl.Text = p.Title or "Window"
	cls.MouseButton1Click:Connect(function() close(card) end)
	cls.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rip(cls,i.Position) end end)

	if p.Description and p.Description~="" then
		local d = Instance.new("TextLabel")
		d.BackgroundTransparency = 1
		d.TextColor3 = CLR.Text
		d.TextXAlignment = Enum.TextXAlignment.Left
		d.TextYAlignment = Enum.TextYAlignment.Top
		d.TextWrapped = true
		d.RichText = true
		d.Font = Enum.Font.Gotham
		d.TextSize = 14
		d.AutomaticSize = Enum.AutomaticSize.Y
		d.Size = UDim2.new(1,0,0,0)
		d.ZIndex = card.ZIndex+2
		d.Text = p.Description
		d.Parent = cnt
	end

	local inp
	if p.InputField then
		inp = Instance.new("TextBox")
		inp.Size = UDim2.new(1,0,0,34)
		inp.ClearTextOnFocus = false
		inp.TextXAlignment = Enum.TextXAlignment.Left
		inp.TextYAlignment = Enum.TextYAlignment.Center
		inp.Font = Enum.Font.Gotham
		inp.TextSize = 14
		inp.TextColor3 = CLR.Text
		inp.RichText = true
		inp.BackgroundColor3 = CLR.Btn
		inp.Text = ""
		inp.PlaceholderText = p.Placeholder or "Type here…"
		inp.PlaceholderColor3 = CLR.PH
		inp.ZIndex = card.ZIndex+2
		Instance.new("UICorner", inp).CornerRadius = UDim.new(0,18)
		inp.Parent = cnt
	end

	local s = ctx(card)
	s.multi=false
	s.sel={}
	s.inp=inp
	s.close=function() close(card) end

	local btns = p.Buttons or {}
	if #btns>0 then mkBtnArea(cnt, btns, card, card.ZIndex+2) end

	local ok, m
	if #btns>2 then
		ok = mkBtn(act,"✓",act.ZIndex+1)
		ok.Size = UDim2.fromOffset(24,24)
		ok.Visible=false
		ok.MouseButton1Click:Connect(function()
			for _,info in ipairs(s.sel) do
				if info.Callback then info.Callback(s.inp and s.inp.Text or "") end
			end
			s.close()
		end)
		m = mkBtn(act,"M",act.ZIndex+1)
		m.Size = UDim2.fromOffset(24,24)
		m.MouseButton1Click:Connect(function()
			s.multi = not s.multi
			tw:Create(m,TweenInfo.new(0.1),{BackgroundColor3 = s.multi and Color3.fromRGB(0,170,100) or CLR.Btn}):Play()
			if s.multi then glowOn(m,s) else glowOff(m,s) clearSel(card) end
			ok.Visible = s.multi and (#s.sel>0)
		end)
		s.ok = ok
	end

	trk.Visible=false
	openIn(card, stackTop, ftr, trk, fil, st, sc, {offsetY=-10,rot=-1.2}, cnt)
	return card
end

local function Popup(p)
	p = typeof(p)=="table" and p or {}
	local w = math.floor(math.clamp(gui.AbsoluteSize.X*0.34,320,560))

	local grp = Instance.new("Frame")
	grp.Name = "PopupGroup"
	grp.BackgroundTransparency = 1
	grp.AnchorPoint = Vector2.new(0.5,0.5)
	grp.Position = UDim2.fromScale(0.5,0.5)
	grp.Size = UDim2.fromOffset(w,0)
	grp.ZIndex = 30000
	grp.Parent = gui

	local baseZ = grp.ZIndex + 10

	local sh = Instance.new("Frame")
	sh.Name = "Shadow"
	sh.AnchorPoint = Vector2.new(0.5,0.5)
	sh.Position = UDim2.fromScale(0.5,0.5)
	sh.BackgroundColor3 = CLR.Shadow
	sh.BackgroundTransparency = 1
	sh.ZIndex = baseZ - 1
	sh.Parent = grp
	Instance.new("UICorner", sh).CornerRadius = UDim.new(0,26)

	local card,hdr,ttl,cls,act,cnt,ftr,trk,fil,st,sc = mkCard(w,baseZ)
	card.Parent = grp
	card.AnchorPoint = Vector2.new(0.5,0.5)
	card.Position = UDim2.fromScale(0.5,0.5)
	ttl.Text = p.Title or "Popup"
	cls.MouseButton1Click:Connect(function()
		disappear(card, sc)
		tw:Create(sh,TweenInfo.new(0.22,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{BackgroundTransparency=1}):Play()
		task.delay(0.42,function() if grp then grp:Destroy() end end)
	end)
	cls.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then rip(cls,i.Position) end end)

	if p.Description and p.Description~="" then
		local d = Instance.new("TextLabel")
		d.BackgroundTransparency = 1
		d.TextColor3 = CLR.Text
		d.TextXAlignment = Enum.TextXAlignment.Left
		d.TextYAlignment = Enum.TextYAlignment.Top
		d.TextWrapped = true
		d.RichText = true
		d.Font = Enum.Font.Gotham
		d.TextSize = 14
		d.AutomaticSize = Enum.AutomaticSize.Y
		d.Size = UDim2.new(1,0,0,0)
		d.ZIndex = baseZ+2
		d.Text = p.Description
		d.Parent = cnt
	end

	local inp
	if p.InputField then
		inp = Instance.new("TextBox")
		inp.Size = UDim2.new(1,0,0,34)
		inp.ClearTextOnFocus = false
		inp.TextXAlignment = Enum.TextXAlignment.Left
		inp.TextYAlignment = Enum.TextYAlignment.Center
		inp.Font = Enum.Font.Gotham
		inp.TextSize = 14
		inp.TextColor3 = CLR.Text
		inp.RichText = true
		inp.BackgroundColor3 = CLR.Btn
		inp.Text = ""
		inp.PlaceholderText = p.Placeholder or "Type here…"
		inp.PlaceholderColor3 = CLR.PH
		inp.ZIndex = baseZ+2
		Instance.new("UICorner", inp).CornerRadius = UDim.new(0,18)
		inp.Parent = cnt
	end

	local s = ctx(card)
	s.multi=false
	s.sel={}
	s.inp=inp
	s.close=function() if cls then cls:Activate() end end

	local btns = p.Buttons or {}
	if #btns>0 then mkBtnArea(cnt, btns, card, baseZ+2) end

	local ok, m
	if #btns>2 then
		ok = mkBtn(act,"✓",act.ZIndex+1)
		ok.Size = UDim2.fromOffset(24,24)
		ok.Visible=false
		ok.MouseButton1Click:Connect(function()
			for _,info in ipairs(s.sel) do
				if info.Callback then info.Callback(s.inp and s.inp.Text or "") end
			end
			s.close()
		end)
		m = mkBtn(act,"M",act.ZIndex+1)
		m.Size = UDim2.fromOffset(24,24)
		m.MouseButton1Click:Connect(function()
			s.multi = not s.multi
			tw:Create(m,TweenInfo.new(0.1),{BackgroundColor3 = s.multi and Color3.fromRGB(0,170,100) or CLR.Btn}):Play()
			if s.multi then glowOn(m,s) else glowOff(m,s) clearSel(card) end
			ok.Visible = s.multi and (#s.sel>0)
		end)
		s.ok = ok
	end

	trk.Visible=false
	local h = cntH(cnt) + ftr.AbsoluteSize.Y
	grp.Size = UDim2.fromOffset(w,h)
	local function syncSh()
		local a = card.AbsoluteSize
		sh.Size = UDim2.fromOffset(a.X+24,a.Y+24)
	end
	card:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncSh)
	syncSh()
	tw:Create(sh,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0.78}):Play()
	appear(card, st, sc, UDim2.new(0,w,0,h), {offsetY=12,rot=-1.2}, cnt)
	drag(grp, hdr)
	return card, grp
end

getgenv().EnhancedNotifs = {
	Notify = function(p) return Notify(p) end,
	Window = function(p) return Window(p) end,
	Popup = function(p) return Popup(p) end,
}

return getgenv().EnhancedNotifs
