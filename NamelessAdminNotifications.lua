local function S(n)
	local s = game:GetService(n)
	if cloneref then s = cloneref(s) end
	return s
end

local TS = S("TweenService")
local RS = S("RunService")
local UIS = S("UserInputService")
local Players = S("Players")

local function UIRoot()
	if RS:IsStudio() then return Players.LocalPlayer:WaitForChild("PlayerGui") end
	return (gethui and gethui()) or S("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or S("CoreGui")
end

local COLORS = {
	Text = Color3.fromRGB(235,235,235),
	Title = Color3.fromRGB(255,255,255),
	Close = Color3.fromRGB(220,70,70),
	Button = Color3.fromRGB(40,40,40),
	ButtonHover = Color3.fromRGB(60,60,60),
	ButtonDown = Color3.fromRGB(30,30,30),
	Stroke = Color3.fromRGB(255,255,255),
	Glow = Color3.fromRGB(0,255,180),
	Card = Color3.fromRGB(20,20,20),
	Shadow = Color3.fromRGB(0,0,0)
}

local PAD, GAP = 12, 10

local root = UIRoot()
local existingGui = root:FindFirstChild("EnhancedNotif")
if _G.EnhancedNotifs and existingGui then return _G.EnhancedNotifs end

local gui = existingGui or Instance.new("ScreenGui")
gui.Name = "EnhancedNotif"
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.DisplayOrder = 2147483647
gui.ResetOnSpawn = false
if not gui.Parent then gui.Parent = root end

local function NotifWidth()
	local w = gui.AbsoluteSize.X
	return math.floor(math.clamp(w*0.28, 280, 380))
end
local function WindowWidth()
	local w = gui.AbsoluteSize.X
	return math.floor(math.clamp(w*0.36, 320, 520))
end

local stackBR = gui:FindFirstChild("StackBR") or Instance.new("Frame")
stackBR.Name = "StackBR"
stackBR.AnchorPoint = Vector2.new(1,1)
stackBR.Position = UDim2.new(1,-20,1,-20)
stackBR.Size = UDim2.new(0,NotifWidth(),1,0)
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
stackTop.Size = UDim2.new(0, WindowWidth(), 1, 0)
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
	stackBR.Size = UDim2.new(0, NotifWidth(), 1, 0)
	stackTop.Size = UDim2.new(0, WindowWidth(), 1, 0)
end)

local function ripple(p, pos)
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
	TS:Create(r,TweenInfo.new(0.6,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(d,d),BackgroundTransparency=1}):Play()
	task.delay(0.65,function() if r then r:Destroy() end end)
end

local function waitContentHeight(content)
	local layout = content:FindFirstChildOfClass("UIListLayout")
	local pad = content:FindFirstChildOfClass("UIPadding")
	local top = (pad and pad.PaddingTop.Offset or 0)
	local bottom = (pad and pad.PaddingBottom.Offset or 0)
	local last = -1
	for _=1,30 do
		RS.Heartbeat:Wait()
		local h = (layout and layout.AbsoluteContentSize.Y or 0) + top + bottom
		if math.abs(h - last) < 1 then return h end
		last = h
	end
	return math.max(0,last)
end

local function setChildrenAlpha(inst, a)
	for _,d in ipairs(inst:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then d.TextTransparency = a end
		if d:IsA("ImageLabel") then d.ImageTransparency = a end
	end
end
local function tweenChildrenAlpha(inst, t, a)
	for _,d in ipairs(inst:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then TS:Create(d,t,{TextTransparency=a}):Play() end
		if d:IsA("ImageLabel") then TS:Create(d,t,{ImageTransparency=a}):Play() end
	end
end

local function buttonBase(parent, text, z)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.Text = text or ""
	b.TextSize = 14
	b.Font = Enum.Font.Gotham
	b.TextColor3 = COLORS.Text
	b.RichText = true
	b.BackgroundColor3 = COLORS.Button
	b.Size = UDim2.new(0,100,0,32)
	b.ZIndex = z or 10
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,18)
	b.Parent = parent
	b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(0.12,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundColor3=COLORS.ButtonHover}):Play() end)
	b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(0.12,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundColor3=COLORS.Button}):Play() end)
	b.MouseButton1Down:Connect(function() TS:Create(b,TweenInfo.new(0.08,Enum.EasingStyle.Sine,Enum.EasingDirection.In),{BackgroundColor3=COLORS.ButtonDown}):Play() end)
	b.MouseButton1Up:Connect(function() TS:Create(b,TweenInfo.new(0.08,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{BackgroundColor3=COLORS.ButtonHover}):Play() end)
	b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then ripple(b,i.Position) end end)
	return b
end

local function makeCardBase(w, baseZ)
	local z = baseZ or (100 + #stackBR:GetChildren()*2)
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.LayoutOrder = os.clock()*1000
	card.Size = UDim2.new(0,w,0,0)
	card.BackgroundColor3 = COLORS.Card
	card.BackgroundTransparency = 0.22
	card.ZIndex = z
	card.BorderSizePixel = 0
	card.ClipsDescendants = true
	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.Stroke
	stroke.Thickness = 1.1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = 0.35
	stroke.Parent = card
	local cor = Instance.new("UICorner")
	cor.CornerRadius = UDim.new(0,20)
	cor.Parent = card
	local scale = Instance.new("UIScale")
	scale.Scale = 0.95
	scale.Parent = card

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1,0,0,28)
	header.ZIndex = z+5
	header.Parent = card

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.AnchorPoint = Vector2.new(0,0.5)
	title.Position = UDim2.new(0,PAD,0.5,0)
	title.Size = UDim2.new(1,-(PAD*2+28),1,0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextColor3 = COLORS.Title
	title.RichText = true
	title.ZIndex = z+6
	title.Parent = header

	local close = Instance.new("TextButton")
	close.AutoButtonColor = false
	close.AnchorPoint = Vector2.new(1,0.5)
	close.Position = UDim2.new(1,-PAD,0.5,0)
	close.Size = UDim2.new(0,24,0,24)
	close.Text = "×"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 18
	close.TextColor3 = Color3.new(1,1,1)
	close.BackgroundColor3 = COLORS.Close
	close.ZIndex = z+7
	Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)
	close.Parent = header

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1,0,0,0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.ZIndex = z+1
	content.Parent = card
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0,PAD)
	pad.PaddingRight = UDim.new(0,PAD)
	pad.PaddingTop = UDim.new(0,28 + PAD)
	pad.PaddingBottom = UDim.new(0,PAD)
	pad.Parent = content
	local column = Instance.new("UIListLayout")
	column.Padding = UDim.new(0,8)
	column.FillDirection = Enum.FillDirection.Vertical
	column.HorizontalAlignment = Enum.HorizontalAlignment.Left
	column.SortOrder = Enum.SortOrder.LayoutOrder
	column.Parent = content

	close.MouseEnter:Connect(function() TS:Create(close,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(255,100,100)}):Play() end)
	close.MouseLeave:Connect(function() TS:Create(close,TweenInfo.new(0.12),{BackgroundColor3=COLORS.Close}):Play() end)

	return card, header, title, close, content, stroke, scale
end

local STATE = setmetatable({}, {__mode = "k"})
local function ctx(card)
	local s = STATE[card]
	if not s then s = {} STATE[card] = s end
	return s
end

local function startGlow(button, store)
	local g = button:FindFirstChild("GlowStroke") or Instance.new("UIStroke")
	g.Name = "GlowStroke"
	g.Parent = button
	g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	g.Color = COLORS.Glow
	g.Thickness = 2
	g.Transparency = 0.35
	store.toggleTweens = store.toggleTweens or {}
	if store.toggleTweens[button] then
		for _,tw in ipairs(store.toggleTweens[button]) do pcall(function() tw:Cancel() end) end
	end
	local t1 = TS:Create(g, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.05})
	local t2 = TS:Create(g, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 0.5})
	store.toggleTweens[button] = {t1,t2}
	t1.Completed:Connect(function() if store.toggleTweens and store.toggleTweens[button] then t2:Play() end end)
	t2.Completed:Connect(function() if store.toggleTweens and store.toggleTweens[button] then t1:Play() end end)
	t1:Play()
end
local function stopGlow(button, store)
	if store.toggleTweens and store.toggleTweens[button] then
		for _,tw in ipairs(store.toggleTweens[button]) do pcall(function() tw:Cancel() end) end
		store.toggleTweens[button] = nil
	end
	local g = button:FindFirstChild("GlowStroke")
	if g then g.Transparency = 1 end
end

local function startSelGlow(button, s)
	local g = button:FindFirstChild("SelStroke") or Instance.new("UIStroke")
	g.Name = "SelStroke"
	g.Parent = button
	g.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	g.Color = COLORS.Glow
	g.Thickness = 2
	g.Transparency = 0.3
	local t1 = TS:Create(g, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.05})
	local t2 = TS:Create(g, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Transparency = 0.5})
	s.glowTweens = s.glowTweens or {}
	if s.glowTweens[button] then
		for _,tw in ipairs(s.glowTweens[button]) do pcall(function() tw:Cancel() end) end
	end
	s.glowTweens[button] = {t1,t2}
	t1.Completed:Connect(function() if s.glowTweens and s.glowTweens[button] then t2:Play() end end)
	t2.Completed:Connect(function() if s.glowTweens and s.glowTweens[button] then t1:Play() end end)
	t1:Play()
end
local function stopSelGlow(button, s)
	if s.glowTweens and s.glowTweens[button] then
		for _,tw in ipairs(s.glowTweens[button]) do pcall(function() tw:Cancel() end) end
		s.glowTweens[button] = nil
	end
	local g = button:FindFirstChild("SelStroke")
	if g then g.Transparency = 1 end
end

local function clearMultiSelection(owner)
	local s = ctx(owner)
	s.selected = {}
	if s.buttonRefs then
		for b,_ in pairs(s.buttonRefs) do
			stopSelGlow(b, s)
			TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=COLORS.Button}):Play()
		end
	end
	if s.confirm then s.confirm.Visible = false end
end

local function buildButtonArea(content, buttons, owner, z)
	if not buttons or #buttons == 0 then return nil end
	local area = Instance.new("Frame")
	area.BackgroundTransparency = 1
	area.Size = UDim2.new(1,0,0,0)
	area.AutomaticSize = Enum.AutomaticSize.Y
	area.ZIndex = (z or 10)
	area.Parent = content

	local grid = Instance.new("UIGridLayout", area)
	local cols = math.min(3,#buttons)
	grid.CellPadding = UDim2.new(0,8,0,8)
	grid.FillDirectionMaxCells = cols
	grid.SortOrder = Enum.SortOrder.LayoutOrder

	local function refresh()
		local w = area.AbsoluteSize.X
		local bw = math.floor((w - (cols-1)*8)/math.max(1,cols))
		grid.CellSize = UDim2.new(0, bw, 0, 32)
	end
	area:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
	task.defer(refresh)

	local s = ctx(owner)
	s.selected = s.selected or {}
	s.buttonRefs = s.buttonRefs or {}

	for _,info in ipairs(buttons) do
		local b = buttonBase(area, info.Text or "", (z or 10)+1)
		s.buttonRefs[b] = info
		b.MouseButton1Click:Connect(function()
			if s.multi then
				local i = table.find(s.selected, info)
				if i then
					table.remove(s.selected,i)
					TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=COLORS.ButtonHover}):Play()
					stopSelGlow(b, s)
				else
					table.insert(s.selected, info)
					TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(0,170,100)}):Play()
					startSelGlow(b, s)
				end
				if s.confirm then s.confirm.Visible = #s.selected>0 end
			else
				if info.Callback then
					if s.input then info.Callback(s.input.Text) else info.Callback() end
				end
				if s.close then s.close() end
			end
		end)
	end
	return area
end

local function attachHoverTimer(card, bar, duration)
	if not bar then return end
	local pcHover = UIS.MouseEnabled
	local running = true
	local frac = 1
	local tween
	local function playFrom(currentFrac)
		bar.Size = UDim2.new(currentFrac,0,0,3)
		if tween then tween:Cancel() end
		local d = math.max(0.01, duration * currentFrac)
		tween = TS:Create(bar, TweenInfo.new(d, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0,0,0,3)})
		tween.Completed:Connect(function()
			if running and bar.Size.X.Scale <= 0.001 then
				local s = ctx(card)
				if s.close then s.close() end
			end
		end)
		tween:Play()
	end
	playFrom(frac)
	if pcHover then
		card.MouseEnter:Connect(function()
			if not running then return end
			running = false
			if tween then tween:Cancel() end
			frac = bar.Size.X.Scale
		end)
		card.MouseLeave:Connect(function()
			if running then return end
			running = true
			playFrom(frac)
		end)
	end
end

local function appearCard(card, stroke, scale, targetSize)
	setChildrenAlpha(card.Content, 1)
	card.Rotation = -1.5
	card.BackgroundTransparency = 0.35
	stroke.Transparency = 0.7
	scale.Scale = 0.94
	TS:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = targetSize, BackgroundTransparency = 0.22, Rotation = 0}):Play()
	TS:Create(scale, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
	TS:Create(stroke, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.25}):Play()
	tweenChildrenAlpha(card.Content, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), 0)
end
local function disappearCard(card, scale)
	TS:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 0.98}):Play()
	TS:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 0.35}):Play()
	task.delay(0.18,function()
		TS:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, 0)}):Play()
	end)
end

local function openInStack(card, parentFrame, stroke, scale)
	card.Parent = parentFrame
	card.Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, 0)
	card.Visible = true
	local content = card:FindFirstChild("Content")
	local targetH = waitContentHeight(content)
	appearCard(card, stroke, scale, UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, targetH))
end

local function closeCard(card)
	if not card then return end
	disappearCard(card, card:FindFirstChildOfClass("UIScale"))
	task.delay(0.42, function() if card then STATE[card]=nil card:Destroy() end end)
end

local function BuildNotification(p)
	p = typeof(p)=="table" and p or {}
	local w = NotifWidth()
	local card, header, title, closeBtn, content, stroke, scale = makeCardBase(w, nil)
	title.Text = p.Title or "Notification"
	closeBtn.MouseButton1Click:Connect(function() closeCard(card) end)
	closeBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ripple(closeBtn,i.Position) end end)
	if p.Description and p.Description ~= "" then
		local d = Instance.new("TextLabel")
		d.BackgroundTransparency = 1
		d.TextColor3 = COLORS.Text
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
		d.Parent = content
	end
	local inputBox
	if p.InputField then
		inputBox = Instance.new("TextBox")
		inputBox.Size = UDim2.new(1,0,0,34)
		inputBox.ClearTextOnFocus = false
		inputBox.TextXAlignment = Enum.TextXAlignment.Left
		inputBox.TextYAlignment = Enum.TextYAlignment.Center
		inputBox.Font = Enum.Font.Gotham
		inputBox.TextSize = 14
		inputBox.Text=''
		inputBox.PlaceholderText = "Type Here..."
		inputBox.TextColor3 = COLORS.Text
		inputBox.RichText = true
		inputBox.BackgroundColor3 = COLORS.Button
		inputBox.ZIndex = card.ZIndex+2
		Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,18)
		inputBox.Parent = content
		inputBox.Focused:Connect(function() TS:Create(inputBox,TweenInfo.new(0.12),{BackgroundColor3=COLORS.ButtonHover}):Play() end)
		inputBox.FocusLost:Connect(function() TS:Create(inputBox,TweenInfo.new(0.12),{BackgroundColor3=COLORS.Button}):Play() end)
	end
	local s = ctx(card)
	s.multi = false
	s.selected = {}
	s.input = inputBox
	s.close = function() closeCard(card) end
	local buttons = p.Buttons or {}
	if #buttons > 2 then
		local ctrl = Instance.new("Frame")
		ctrl.BackgroundTransparency = 1
		ctrl.Size = UDim2.new(1,0,0,0)
		ctrl.AutomaticSize = Enum.AutomaticSize.Y
		ctrl.ZIndex = card.ZIndex+4
		ctrl.Parent = content
		local lay = Instance.new("UIListLayout", ctrl)
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.HorizontalAlignment = Enum.HorizontalAlignment.Right
		lay.Padding = UDim.new(0,6)
		local confirm = buttonBase(ctrl,"✓",card.ZIndex+5)
		confirm.Size = UDim2.fromOffset(26,26)
		confirm.Visible = false
		confirm.MouseButton1Click:Connect(function()
			for _,info in ipairs(s.selected) do
				if info.Callback then
					if s.input then info.Callback(s.input.Text) else info.Callback() end
				end
			end
			s.close()
		end)
		local toggleBtn = buttonBase(ctrl,"M",card.ZIndex+5)
		toggleBtn.Size = UDim2.fromOffset(26,26)
		toggleBtn.MouseButton1Click:Connect(function()
			s.multi = not s.multi
			TS:Create(toggleBtn,TweenInfo.new(0.1),{BackgroundColor3 = s.multi and Color3.fromRGB(0,170,100) or COLORS.Button}):Play()
			if s.multi then startGlow(toggleBtn, s) else stopGlow(toggleBtn, s); clearMultiSelection(card) end
			confirm.Visible = s.multi and (#s.selected>0)
		end)
		s.confirm = confirm
	end
	buildButtonArea(content, buttons, card, card.ZIndex+2)
	local prog = Instance.new("Frame")
	prog.Name = "Progress"
	prog.BackgroundColor3 = Color3.fromRGB(255,255,255)
	prog.BackgroundTransparency = 0.25
	prog.BorderSizePixel = 0
	prog.AnchorPoint = Vector2.new(0,1)
	prog.Position = UDim2.new(0,0,1,0)
	prog.Size = UDim2.new(1,0,0,3)
	prog.ZIndex = card.ZIndex+2
	Instance.new("UICorner", prog).CornerRadius = UDim.new(0,18)
	prog.Parent = content
	if #buttons > 0 then prog.Visible = false end
	openInStack(card, stackBR, stroke, scale)
	if (p.Duration or 5) > 0 and #buttons == 0 then attachHoverTimer(card, prog, p.Duration or 5) end
	return card
end

local function draggable(ui, handle)
	handle = handle or ui
	local dragging, start, origin
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			start = i.Position
			origin = ui.Position
		end
	end)
	handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d = i.Position - start
			ui.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
		end
	end)
end

local function BuildTopWindow(p)
	p = typeof(p)=="table" and p or {}
	local w = WindowWidth()
	local card, header, title, closeBtn, content, stroke, scale = makeCardBase(w, nil)
	title.Text = p.Title or "Window"
	closeBtn.MouseButton1Click:Connect(function() closeCard(card) end)
	closeBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ripple(closeBtn,i.Position) end end)
	if p.Description and p.Description ~= "" then
		local d = Instance.new("TextLabel")
		d.BackgroundTransparency = 1
		d.TextColor3 = COLORS.Text
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
		d.Parent = content
	end
	local inputBox
	if p.InputField then
		inputBox = Instance.new("TextBox")
		inputBox.Size = UDim2.new(1,0,0,34)
		inputBox.ClearTextOnFocus = false
		inputBox.TextXAlignment = Enum.TextXAlignment.Left
		inputBox.TextYAlignment = Enum.TextYAlignment.Center
		inputBox.Font = Enum.Font.Gotham
		inputBox.TextSize = 14
		inputBox.Text=''
		inputBox.PlaceholderText = "Type Here..."
		inputBox.TextColor3 = COLORS.Text
		inputBox.RichText = true
		inputBox.BackgroundColor3 = COLORS.Button
		inputBox.ZIndex = card.ZIndex+2
		Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,18)
		inputBox.Parent = content
		inputBox.Focused:Connect(function() TS:Create(inputBox,TweenInfo.new(0.12),{BackgroundColor3=COLORS.ButtonHover}):Play() end)
		inputBox.FocusLost:Connect(function() TS:Create(inputBox,TweenInfo.new(0.12),{BackgroundColor3=COLORS.Button}):Play() end)
	end
	local s = ctx(card)
	s.multi = false
	s.selected = {}
	s.input = inputBox
	s.close = function() closeCard(card) end
	local buttons = p.Buttons or {}
	buildButtonArea(content, buttons, card, card.ZIndex+2)
	if #buttons > 2 then
		local ctrl = Instance.new("Frame")
		ctrl.BackgroundTransparency = 1
		ctrl.Size = UDim2.new(1,0,0,0)
		ctrl.AutomaticSize = Enum.AutomaticSize.Y
		ctrl.ZIndex = card.ZIndex+4
		ctrl.Parent = content
		local lay = Instance.new("UIListLayout", ctrl)
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
		lay.Padding = UDim.new(0,6)
		local m = buttonBase(ctrl,"M",card.ZIndex+5)
		m.Size = UDim2.fromOffset(26,26)
		local ok = buttonBase(ctrl,"✓",card.ZIndex+5)
		ok.Size = UDim2.fromOffset(26,26)
		ok.Visible = false
		m.MouseButton1Click:Connect(function()
			s.multi = not s.multi
			TS:Create(m,TweenInfo.new(0.1),{BackgroundColor3 = s.multi and Color3.fromRGB(0,170,100) or COLORS.Button}):Play()
			if s.multi then startGlow(m, s) else stopGlow(m, s); clearMultiSelection(card) end
			ok.Visible = s.multi and (#s.selected>0)
		end)
		ok.MouseButton1Click:Connect(function()
			for _,info in ipairs(s.selected) do
				if info.Callback then
					if s.input then info.Callback(s.input.Text) else info.Callback() end
				end
			end
			s.close()
		end)
		s.confirm = ok
	end
	openInStack(card, stackTop, stroke, scale)
	return card
end

local function BuildPopupModal(p)
	p = typeof(p)=="table" and p or {}
	local w = math.floor(math.clamp(gui.AbsoluteSize.X*0.34, 320, 520))

	local group = Instance.new("Frame")
	group.Name = "PopupGroup"
	group.BackgroundTransparency = 1
	group.AnchorPoint = Vector2.new(0.5,0.5)
	group.Position = UDim2.fromScale(0.5,0.5)
	group.Size = UDim2.fromOffset(w, 0)
	group.ZIndex = 30000
	group.Parent = gui

	local baseZ = group.ZIndex + 10

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.AnchorPoint = Vector2.new(0.5,0.5)
	shadow.Position = UDim2.fromScale(0.5,0.5)
	shadow.Size = UDim2.fromOffset(w+28, 40)
	shadow.BackgroundColor3 = COLORS.Shadow
	shadow.BackgroundTransparency = 1
	shadow.ZIndex = baseZ - 1
	shadow.Parent = group
	local shCorner = Instance.new("UICorner")
	shCorner.CornerRadius = UDim.new(0,26)
	shCorner.Parent = shadow

	local card, header, title, closeBtn, content, stroke, scale = makeCardBase(w, baseZ)
	card.Parent = group
	card.AnchorPoint = Vector2.new(0.5,0.5)
	card.Position = UDim2.fromScale(0.5,0.5)
	title.Text = p.Title or "Popup"
	closeBtn.MouseButton1Click:Connect(function()
		disappearCard(card, scale)
		TS:Create(shadow, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
		task.delay(0.42, function() if group then group:Destroy() end end)
	end)
	closeBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ripple(closeBtn,i.Position) end end)

	if p.Description and p.Description ~= "" then
		local d = Instance.new("TextLabel")
		d.BackgroundTransparency = 1
		d.TextColor3 = COLORS.Text
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
		d.Parent = content
	end

	local inputBox
	if p.InputField then
		inputBox = Instance.new("TextBox")
		inputBox.Size = UDim2.new(1,0,0,34)
		inputBox.ClearTextOnFocus = false
		inputBox.TextXAlignment = Enum.TextXAlignment.Left
		inputBox.TextYAlignment = Enum.TextYAlignment.Center
		inputBox.Font = Enum.Font.Gotham
		inputBox.TextSize = 14
		inputBox.Text=''
		inputBox.PlaceholderText = "Type Here..."
		inputBox.TextColor3 = COLORS.Text
		inputBox.RichText = true
		inputBox.BackgroundColor3 = COLORS.Button
		inputBox.ZIndex = baseZ+2
		Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0,18)
		inputBox.Parent = content
		inputBox.Focused:Connect(function() TS:Create(inputBox,TweenInfo.new(0.12),{BackgroundColor3=COLORS.ButtonHover}):Play() end)
		inputBox.FocusLost:Connect(function() TS:Create(inputBox,TweenInfo.new(0.12),{BackgroundColor3=COLORS.Button}):Play() end)
	end

	local s = ctx(card)
	s.multi = false
	s.selected = {}
	s.input = inputBox
	s.close = function() if closeBtn then closeBtn:Activate() end end

	local buttons = p.Buttons or {}
	buildButtonArea(content, buttons, card, baseZ+2)

	if #buttons > 2 then
		local ctrl = Instance.new("Frame")
		ctrl.BackgroundTransparency = 1
		ctrl.Size = UDim2.new(1,0,0,0)
		ctrl.AutomaticSize = Enum.AutomaticSize.Y
		ctrl.ZIndex = baseZ+4
		ctrl.Parent = content
		local lay = Instance.new("UIListLayout", ctrl)
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
		lay.Padding = UDim.new(0,6)
		local m = buttonBase(ctrl,"M",baseZ+5)
		m.Size = UDim2.fromOffset(26,26)
		local ok = buttonBase(ctrl,"✓",baseZ+5)
		ok.Size = UDim2.fromOffset(26,26)
		ok.Visible = false
		m.MouseButton1Click:Connect(function()
			s.multi = not s.multi
			TS:Create(m,TweenInfo.new(0.1),{BackgroundColor3 = s.multi and Color3.fromRGB(0,170,100) or COLORS.Button}):Play()
			if s.multi then startGlow(m, s) else stopGlow(m, s); clearMultiSelection(card) end
			ok.Visible = s.multi and (#s.selected>0)
		end)
		ok.MouseButton1Click:Connect(function()
			for _,info in ipairs(s.selected) do
				if info.Callback then
					if s.input then info.Callback(s.input.Text) else info.Callback() end
				end
			end
			s.close()
		end)
		s.confirm = ok
	end

	local targetH = waitContentHeight(content)
	group.Size = UDim2.fromOffset(w, targetH + 8)
	shadow.Size = UDim2.fromOffset(w+28, math.max(40, targetH+22))
	setChildrenAlpha(card.Content, 1)
	card.Rotation = -1.5
	card.BackgroundTransparency = 0.35
	stroke.Transparency = 0.7
	scale.Scale = 0.92
	TS:Create(shadow, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.78}):Play()
	TS:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0,w,0,targetH), BackgroundTransparency = 0.22, Rotation = 0}):Play()
	TS:Create(scale, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
	TS:Create(stroke, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Transparency = 0.25}):Play()
	tweenChildrenAlpha(card.Content, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), 0)

	draggable(group, header)
	return card, group
end

_G.EnhancedNotifs = {
	Notify = function(p) return BuildNotification(p) end,
	Window = function(p) return BuildTopWindow(p) end,
	Popup = function(p) return BuildPopupModal(p) end,
}

return _G.EnhancedNotifs