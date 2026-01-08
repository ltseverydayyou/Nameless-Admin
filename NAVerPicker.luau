local SRV = setmetatable({}, {
	__index = function(self, name)
		local Reference = cloneref and type(cloneref) == "function" and cloneref or function(ref)
			return ref;
		end;
		local ok, svc = pcall(function()
			return Reference(game:GetService(name));
		end);
		if ok and svc then
			rawset(self, name, svc);
			return svc;
		end;
	end
});
local function SafeGetService(name)
	return SRV[name];
end;
local hs = SafeGetService("HttpService");
local plrs = SafeGetService("Players");
local lp = plrs.LocalPlayer;
local UIS = SafeGetService("UserInputService");
local TS = SafeGetService("TweenService");
local Lgt = SafeGetService("Lighting");
local _naConns = _naConns or {};
local NAlib = {};
if not NAlib.disconnect then
	function NAlib.disconnect(n)
		local t = _naConns[n];
		if t then
			for _, c in ipairs(t) do
				pcall(function()
					c:Disconnect();
				end);
			end;
			_naConns[n] = nil;
		end;
	end;
end;
if not NAlib.connect then
	function NAlib.connect(n, c)
		if not c then
			return;
		end;
		_naConns[n] = _naConns[n] or {};
		table.insert(_naConns[n], c);
		return c;
	end;
end;
if not NAlib.isProperty then
	function NAlib.isProperty(o, p)
		return pcall(function()
			return o[p];
		end);
	end;
end;
if not NAlib.setProperty then
	function NAlib.setProperty(o, p, v)
		pcall(function()
			o[p] = v;
		end);
	end;
end;
local function NaProtectUI(gui)
	local INV = "\000";
	local MAX_DO = 2147483647;
	local cg = SafeGetService("CoreGui");
	local target = gethui and gethui() or cg and cg:FindFirstChildWhichIsA("ScreenGui") or cg or lp and lp:FindFirstChildWhichIsA("PlayerGui");
	if not target then
		return;
	end;
	pcall(function()
		gui.Archivable = false;
	end);
	gui.Name = INV;
	gui.Parent = target;
	if gui:IsA("ScreenGui") then
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
		gui.DisplayOrder = MAX_DO;
		gui.ResetOnSpawn = false;
		gui.IgnoreGuiInset = true;
	end;
	local props = {
		Parent = target,
		Name = INV,
		Archivable = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder = MAX_DO,
		ResetOnSpawn = false,
		IgnoreGuiInset = true
	};
	if not gui:IsA("ScreenGui") then
		props.ZIndexBehavior = nil;
		props.DisplayOrder = nil;
		props.ResetOnSpawn = nil;
		props.IgnoreGuiInset = nil;
	end;
	for prop, val in pairs(props) do
		if val ~= nil then
			(gui:GetPropertyChangedSignal(prop)):Connect(function()
				if gui[prop] ~= val then
					pcall(function()
						gui[prop] = val;
					end);
				end;
			end);
		end;
	end;
	gui.AncestryChanged:Connect(function()
		if gui.Parent ~= target then
			pcall(function()
				gui.Parent = target;
			end);
		end;
	end);
	local hb;
	hb = (SafeGetService("RunService")).Heartbeat:Connect(function()
		for prop, val in pairs(props) do
			if val ~= nil and gui[prop] ~= val then
				pcall(function()
					gui[prop] = val;
				end);
			end;
		end;
		if not gui.Parent then
			pcall(function()
				hb:Disconnect();
			end);
		end;
	end);
	return gui;
end;
local guiii = {};
guiii.draggerV2 = function(ui, dragui)
	dragui = dragui or ui;
	local dragging, dragInput, dragStart, startPos;
	local anchor = ui.AnchorPoint;
	local sg = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui.Parent;
	local function sClamp(v, lo, hi)
		if hi < lo then
			hi = lo;
		end;
		return math.clamp(v, lo, hi);
	end;
	local function upd(input)
		pcall(function()
			local p = sg.AbsoluteSize;
			local s = ui.AbsoluteSize;
			if p.X <= 0 or p.Y <= 0 then
				return;
			end;
			local sx = startPos.X.Scale * p.X + startPos.X.Offset;
			local sy = startPos.Y.Scale * p.Y + startPos.Y.Offset;
			local dx = input.Position.X - dragStart.X;
			local dy = input.Position.Y - dragStart.Y;
			local minX = anchor.X * s.X;
			local maxX = p.X - (1 - anchor.X) * s.X;
			local minY = anchor.Y * s.Y;
			local maxY = p.Y - (1 - anchor.Y) * s.Y;
			local nx = sClamp(sx + dx, minX, maxX);
			local ny = sClamp(sy + dy, minY, maxY);
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0);
		end);
	end;
	NAlib.disconnect("DraggerV2_" .. ui:GetDebugId());
	NAlib.connect("DraggerV2_" .. ui:GetDebugId(), dragui.InputBegan:Connect(function(input)
		pcall(function()
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true;
				dragStart = input.Position;
				startPos = ui.Position;
				local c = input.Changed:Connect(function()
					pcall(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false;
						end;
					end);
				end);
				NAlib.connect("DraggerV2_" .. ui:GetDebugId(), c);
			end;
		end);
	end));
	NAlib.connect("DraggerV2_" .. ui:GetDebugId(), dragui.InputChanged:Connect(function(input)
		pcall(function()
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input;
			end;
		end);
	end));
	NAlib.connect("DraggerV2_" .. ui:GetDebugId(), UIS.InputChanged:Connect(function(input)
		pcall(function()
			if input == dragInput and dragging then
				upd(input);
			end;
		end);
	end));
	local function clampToView()
		pcall(function()
			local p = sg.AbsoluteSize;
			local s = ui.AbsoluteSize;
			if p.X <= 0 or p.Y <= 0 then
				return;
			end;
			local pos = ui.Position;
			local ax = pos.X.Scale * p.X + pos.X.Offset;
			local ay = pos.Y.Scale * p.Y + pos.Y.Offset;
			local minX = anchor.X * s.X;
			local maxX = p.X - (1 - anchor.X) * s.X;
			local minY = anchor.Y * s.Y;
			local maxY = p.Y - (1 - anchor.Y) * s.Y;
			local nx = sClamp(ax, minX, maxX);
			local ny = sClamp(ay, minY, maxY);
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0);
		end);
	end;
	NAlib.connect("DraggerV2_" .. ui:GetDebugId(), (sg:GetPropertyChangedSignal("AbsoluteSize")):Connect(clampToView));
	if ui and ui.GetPropertyChangedSignal then
		NAlib.connect("DraggerV2_" .. ui:GetDebugId(), (ui:GetPropertyChangedSignal("AbsoluteSize")):Connect(clampToView));
	end;
	clampToView();
	pcall(function()
		ui.Active = true;
	end);
	pcall(function()
		dragui.Active = true;
	end);
end;
local repo = "ltseverydayyou/Nameless-Admin";
local br = "main";
local chans = {
	main = {
		key = "main",
		name = "Nameless Admin",
		path = "Source.lua",
		headRaw = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"
	},
	test = {
		key = "test",
		name = "NA Testing",
		path = "NA testing.lua",
		headRaw = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"
	}
};
local function getCommits(ch, n)
	local ok, res = pcall(function()
		local u = "https://api.github.com/repos/" .. repo .. "/commits?path=" .. hs:UrlEncode(ch.path) .. "&sha=" .. br .. "&per_page=" .. tostring(n);
		local r = game:HttpGet(u);
		return hs:JSONDecode(r);
	end);
	if not ok or (not res) then
		return nil, "Failed to fetch commits";
	end;
	if type(res) ~= "table" or #res == 0 then
		return nil, "No commits found";
	end;
	local list = {};
	for _, v in ipairs(res) do
		local c = v.commit or {};
		local a = c.author or {};
		list[(#list) + 1] = {
			sha = v.sha,
			date = a.date or "N/A",
			msg = c.message or "No message"
		};
	end;
	return list;
end;
local function shortSha(s)
	if not s then
		return "???????";
	end;
	return string.sub(s, 1, 7);
end;
local function mkRawFromCommit(ch, sha)
	local p = ch.path:gsub(" ", "%%20");
	return "https://raw.githubusercontent.com/" .. repo .. "/" .. sha .. "/" .. p;
end;
local function safeClip(s)
	if type(setclipboard) == "function" then
		return pcall(setclipboard, s);
	end;
	return false;
end;
local function tw(i, d, p, st)
	if not TS then
		return;
	end;
	local ti = TweenInfo.new(d, st or Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local tr = TS:Create(i, ti, p);
	tr:Play();
	return tr;
end;
local C = {
	b0 = Color3.fromRGB(0, 0, 0),
	b1 = Color3.fromRGB(10, 10, 10),
	b2 = Color3.fromRGB(16, 16, 16),
	b3 = Color3.fromRGB(22, 22, 22),
	b4 = Color3.fromRGB(28, 28, 28),
	w0 = Color3.fromRGB(245, 245, 245),
	w1 = Color3.fromRGB(200, 200, 200),
	w2 = Color3.fromRGB(150, 150, 150),
	st = Color3.fromRGB(60, 60, 60),
	st2 = Color3.fromRGB(90, 90, 90)
};
local opt = {
	blr = true,
	red = false,
	ask = false,
	autoClose = true,
	cache = true,
	showPath = true,
	copyRaw = true,
	cnt = 60,
	hi = true,
	cmp = false,
	shw = true
};
local blur = nil;
if Lgt then
	blur = Lgt:FindFirstChild("NA_VP_Blur2");
	if not blur then
		blur = Instance.new("BlurEffect");
		blur.Name = "NA_VP_Blur2";
		blur.Size = 0;
		blur.Parent = Lgt;
	end;
end;
local gui = Instance.new("ScreenGui");
gui.Name = "NA_VersionPicker_2";
gui.ResetOnSpawn = false;
pcall(function()
	NaProtectUI(gui);
end);
local bg = Instance.new("Frame");
bg.Name = "Bg";
bg.Parent = gui;
bg.Size = UDim2.new(1, 0, 1, 0);
bg.Position = UDim2.new(0, 0, 0, 0);
bg.BackgroundColor3 = C.b0;
bg.BackgroundTransparency = 0.32;
bg.BorderSizePixel = 0;
local root = Instance.new("Frame");
root.Name = "Root";
root.Parent = gui;
root.AnchorPoint = Vector2.new(0.5, 0.5);
root.Position = UDim2.new(0.5, 0, 0.5, 0);
root.Size = UDim2.new(0, 560, 0, 390);
root.BackgroundColor3 = C.b1;
root.BorderSizePixel = 0;
root.ClipsDescendants = true;
local rc = Instance.new("UICorner");
rc.CornerRadius = UDim.new(0, 18);
rc.Parent = root;
local rs = Instance.new("UIStroke");
rs.Thickness = 1;
rs.Transparency = 0;
rs.Color = C.st;
rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
rs.Parent = root;
local shine = Instance.new("Frame");
shine.Parent = root;
shine.BackgroundColor3 = C.w0;
shine.BackgroundTransparency = 0.95;
shine.BorderSizePixel = 0;
shine.Position = UDim2.new(-0.2, 0, -0.4, 0);
shine.Size = UDim2.new(1.4, 0, 1.2, 0);
local shg = Instance.new("UIGradient");
shg.Parent = shine;
shg.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.w0),
	ColorSequenceKeypoint.new(0.5, C.w1),
	ColorSequenceKeypoint.new(1, C.w0)
});
shg.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.45, 0.95),
	NumberSequenceKeypoint.new(0.55, 0.95),
	NumberSequenceKeypoint.new(1, 1)
});
shg.Rotation = 28;
local off = Instance.new("Vector3Value");
off.Value = Vector3.new(-0.2, 0, 0);
off.Changed:Connect(function(v)
	shg.Offset = Vector2.new(v.X, 0);
end);
local function animShine()
	while gui.Parent do
		if opt.red then
			task.wait(0.5);
		else
			local t1 = TS:Create(off, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Value = Vector3.new(0.2, 0, 0)
			});
			t1:Play();
			t1.Completed:Wait();
			local t2 = TS:Create(off, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Value = Vector3.new(-0.2, 0, 0)
			});
			t2:Play();
			t2.Completed:Wait();
		end;
	end;
end;
task.spawn(animShine);
local function crn(p, r)
	local c = Instance.new("UICorner");
	c.CornerRadius = UDim.new(0, r);
	c.Parent = p;
	return c;
end;
local function stk(p, tr, col)
	local s = Instance.new("UIStroke");
	s.Thickness = 1;
	s.Transparency = tr or 0.2;
	s.Color = col or C.st;
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	s.Parent = p;
	return s;
end;
local function pad(p, l, r, t, b)
	local u = Instance.new("UIPadding");
	u.PaddingLeft = UDim.new(0, l or 0);
	u.PaddingRight = UDim.new(0, r or 0);
	u.PaddingTop = UDim.new(0, t or 0);
	u.PaddingBottom = UDim.new(0, b or 0);
	u.Parent = p;
	return u;
end;
local function txt(p, s, sz, bold, col)
	local t = Instance.new("TextLabel");
	t.Parent = p;
	t.BackgroundTransparency = 1;
	t.Text = s or "";
	t.TextColor3 = col or C.w0;
	t.TextSize = sz or 14;
	t.Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham;
	t.TextXAlignment = Enum.TextXAlignment.Left;
	t.TextYAlignment = Enum.TextYAlignment.Center;
	return t;
end;
local function btn(p, s)
	local b = Instance.new("TextButton");
	b.Parent = p;
	b.AutoButtonColor = false;
	b.Text = s or "";
	b.TextColor3 = C.w0;
	b.TextSize = 13;
	b.Font = Enum.Font.GothamSemibold;
	b.BackgroundColor3 = C.b2;
	b.BorderSizePixel = 0;
	crn(b, 12);
	local st = stk(b, 0.15, C.st);
	return b, st;
end;
local function hvr(b, s)
	local o = b.BackgroundColor3;
	b.MouseEnter:Connect(function()
		tw(b, opt.red and 0.06 or 0.11, {
			BackgroundColor3 = C.b4
		});
		if s then
			tw(s, opt.red and 0.06 or 0.11, {
				Transparency = 0
			});
		end;
	end);
	b.MouseLeave:Connect(function()
		tw(b, opt.red and 0.06 or 0.11, {
			BackgroundColor3 = o
		});
		if s then
			tw(s, opt.red and 0.06 or 0.11, {
				Transparency = 0.15
			});
		end;
	end);
end;
local function rip(b)
	local r = Instance.new("Frame");
	r.Parent = b;
	r.BackgroundColor3 = C.w0;
	r.BackgroundTransparency = 0.92;
	r.BorderSizePixel = 0;
	r.AnchorPoint = Vector2.new(0.5, 0.5);
	r.Position = UDim2.new(0.5, 0, 0.5, 0);
	r.Size = UDim2.new(0, 0, 0, 0);
	r.ZIndex = (b.ZIndex or 1) + 1;
	crn(r, 999);
	local t1 = tw(r, opt.red and 0.1 or 0.18, {
		Size = UDim2.new(1.4, 0, 2.2, 0),
		BackgroundTransparency = 1
	}, Enum.EasingStyle.Quad);
	if t1 then
		t1.Completed:Connect(function()
			pcall(function()
				r:Destroy();
			end);
		end);
	else
		task.delay(0.2, function()
			pcall(function()
				r:Destroy();
			end);
		end);
	end;
end;
local top = Instance.new("Frame");
top.Parent = root;
top.BackgroundTransparency = 1;
top.BorderSizePixel = 0;
top.Size = UDim2.new(1, 0, 0, 56);
local side = Instance.new("Frame");
side.Parent = root;
side.BackgroundColor3 = C.b2;
side.BorderSizePixel = 0;
side.Position = UDim2.new(0, 12, 0, 56);
side.Size = UDim2.new(0, 170, 1, -68);
crn(side, 16);
stk(side, 0.25, C.st);
local main = Instance.new("Frame");
main.Parent = root;
main.BackgroundColor3 = C.b1;
main.BorderSizePixel = 0;
main.Position = UDim2.new(0, 190, 0, 56);
main.Size = UDim2.new(1, -202, 1, -68);
crn(main, 16);
stk(main, 0.25, C.st);
main.ClipsDescendants = true;
local bar = Instance.new("Frame");
bar.Parent = main;
bar.BackgroundColor3 = C.b2;
bar.BorderSizePixel = 0;
bar.Size = UDim2.new(1, 0, 0, 54);
stk(bar, 0.35, C.st);
local barC = Instance.new("UICorner");
barC.CornerRadius = UDim.new(0, 16);
barC.Parent = bar;
local barMask = Instance.new("Frame");
barMask.Parent = bar;
barMask.BackgroundColor3 = C.b2;
barMask.BorderSizePixel = 0;
barMask.Position = UDim2.new(0, 0, 0.5, 0);
barMask.Size = UDim2.new(1, 0, 0.5, 0);
local t1 = txt(top, "Nameless Admin", 16, true, C.w0);
t1.Position = UDim2.new(0, 18, 0, 9);
t1.Size = UDim2.new(1, -170, 0, 20);
local t2 = txt(top, "Version picker", 12, false, C.w2);
t2.Position = UDim2.new(0, 18, 0, 30);
t2.Size = UDim2.new(1, -170, 0, 18);
local bCfg, bCfgS = btn(top, "SET");
bCfg.Position = UDim2.new(1, -160, 0.5, -17);
bCfg.Size = UDim2.new(0, 56, 0, 34);
hvr(bCfg, bCfgS);
local bMin, bMinS = btn(top, "-");
bMin.Position = UDim2.new(1, -96, 0.5, -17);
bMin.Size = UDim2.new(0, 44, 0, 34);
bMin.TextSize = 18;
hvr(bMin, bMinS);
local bX, bXS = btn(top, "X");
bX.Position = UDim2.new(1, -46, 0.5, -17);
bX.Size = UDim2.new(0, 44, 0, 34);
hvr(bX, bXS);
local sHd = txt(side, "Channels", 13, true, C.w0);
sHd.Position = UDim2.new(0, 14, 0, 12);
sHd.Size = UDim2.new(1, -28, 0, 16);
local chWrap = Instance.new("Frame");
chWrap.Parent = side;
chWrap.BackgroundTransparency = 1;
chWrap.Position = UDim2.new(0, 14, 0, 34);
chWrap.Size = UDim2.new(1, -28, 0, 120);
local chLay = Instance.new("UIListLayout");
chLay.Parent = chWrap;
chLay.SortOrder = Enum.SortOrder.LayoutOrder;
chLay.Padding = UDim.new(0, 10);
local function mkChBtn(ch)
	local f = Instance.new("TextButton");
	f.Parent = chWrap;
	f.AutoButtonColor = false;
	f.Text = "";
	f.BackgroundColor3 = C.b3;
	f.BorderSizePixel = 0;
	f.Size = UDim2.new(1, 0, 0, 54);
	crn(f, 14);
	local fs = stk(f, 0.25, C.st);
	local a = Instance.new("Frame");
	a.Parent = f;
	a.BackgroundColor3 = C.w0;
	a.BorderSizePixel = 0;
	a.Position = UDim2.new(0, 0, 0, 0);
	a.Size = UDim2.new(0, 2, 1, 0);
	a.BackgroundTransparency = 0.65;
	local n = txt(f, ch.name, 14, true, C.w0);
	n.Position = UDim2.new(0, 12, 0, 9);
	n.Size = UDim2.new(1, -24, 0, 18);
	local p = txt(f, opt.showPath and ch.path or "Open versions", 12, false, C.w2);
	p.Position = UDim2.new(0, 12, 0, 28);
	p.Size = UDim2.new(1, -24, 0, 16);
	f.MouseEnter:Connect(function()
		tw(f, opt.red and 0.06 or 0.11, {
			BackgroundColor3 = C.b4
		});
		tw(a, opt.red and 0.06 or 0.11, {
			BackgroundTransparency = 0.25
		});
		if fs then
			tw(fs, opt.red and 0.06 or 0.11, {
				Transparency = 0
			});
		end;
	end);
	f.MouseLeave:Connect(function()
		tw(f, opt.red and 0.06 or 0.11, {
			BackgroundColor3 = C.b3
		});
		tw(a, opt.red and 0.06 or 0.11, {
			BackgroundTransparency = 0.65
		});
		if fs then
			tw(fs, opt.red and 0.06 or 0.11, {
				Transparency = 0.25
			});
		end;
	end);
	return f, a, p;
end;
local chBtn = {};
do
	local bA, aA, pA = mkChBtn(chans.main);
	local bB, aB, pB = mkChBtn(chans.test);
	chBtn.main = {
		b = bA,
		a = aA,
		p = pA,
		ch = chans.main
	};
	chBtn.test = {
		b = bB,
		a = aB,
		p = pB,
		ch = chans.test
	};
end;
local inf = txt(side, "", 12, false, C.w2);
inf.Position = UDim2.new(0, 14, 1, -64);
inf.Size = UDim2.new(1, -28, 0, 50);
inf.TextWrapped = true;
inf.TextYAlignment = Enum.TextYAlignment.Top;
inf.Text = "Pick a channel. Search commits. Load any version.";
local chT = txt(bar, "No channel selected", 14, true, C.w0);
chT.Position = UDim2.new(0, 14, 0, 9);
chT.Size = UDim2.new(1, -28, 0, 18);
local chS = txt(bar, "", 12, false, C.w2);
chS.Position = UDim2.new(0, 14, 0, 28);
chS.Size = UDim2.new(1, -28, 0, 16);
local src = Instance.new("TextBox");
src.Parent = main;
src.BackgroundColor3 = C.b2;
src.BorderSizePixel = 0;
src.Position = UDim2.new(0, 12, 0, 66);
src.Size = UDim2.new(1, -24, 0, 36);
src.Font = Enum.Font.Gotham;
src.TextSize = 13;
src.TextColor3 = C.w0;
src.PlaceholderText = "Search by sha / message / date";
src.PlaceholderColor3 = C.w2;
src.ClearTextOnFocus = false;
src.Text = "";
crn(src, 14);
stk(src, 0.2, C.st);
pad(src, 12, 12, 0, 0);
local list = Instance.new("ScrollingFrame");
list.Parent = main;
list.BackgroundTransparency = 1;
list.BorderSizePixel = 0;
list.Position = UDim2.new(0, 0, 0, 110);
list.Size = UDim2.new(1, 0, 1, -110);
list.ScrollBarThickness = 3;
list.ScrollBarImageColor3 = C.w0;
list.ScrollBarImageTransparency = 0.84;
list.TopImage, list.MidImage, list.BottomImage = "", "", "";
pad(list, 12, 12, 12, 12);
local lay = Instance.new("UIListLayout");
lay.Parent = list;
lay.SortOrder = Enum.SortOrder.LayoutOrder;
lay.Padding = UDim.new(0, 10);
(lay:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
	list.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 18);
end);
list.CanvasSize = UDim2.new(0, 0, 0, 18);
local spin = Instance.new("Frame");
spin.Parent = bar;
spin.BackgroundTransparency = 1;
spin.Size = UDim2.new(0, 18, 0, 18);
spin.Position = UDim2.new(1, -26, 0.5, -9);
spin.Visible = false;
local ring = Instance.new("Frame");
ring.Parent = spin;
ring.BackgroundTransparency = 1;
ring.Size = UDim2.new(1, 0, 1, 0);
local ringS = Instance.new("UIStroke");
ringS.Parent = ring;
ringS.Thickness = 2;
ringS.Transparency = 0.1;
ringS.Color = C.w0;
local ringG = Instance.new("UIGradient");
ringG.Parent = ring;
ringG.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.w0),
	ColorSequenceKeypoint.new(1, C.w0)
});
ringG.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.95),
	NumberSequenceKeypoint.new(0.5, 0.1),
	NumberSequenceKeypoint.new(1, 0.95)
});
task.spawn(function()
	local v = 0;
	while gui.Parent do
		if spin.Visible and (not opt.red) then
			v = (v + 7) % 360;
			ringG.Rotation = v;
			task.wait();
		else
			task.wait(0.08);
		end;
	end;
end);
local toast = Instance.new("TextLabel");
toast.Parent = root;
toast.BackgroundColor3 = C.b3;
toast.BorderSizePixel = 0;
toast.AnchorPoint = Vector2.new(0.5, 1);
toast.Position = UDim2.new(0.5, 0, 1, -10);
toast.Size = UDim2.new(0, 320, 0, 34);
toast.TextColor3 = C.w0;
toast.TextSize = 13;
toast.Font = Enum.Font.GothamSemibold;
toast.Text = "";
toast.Visible = false;
toast.ZIndex = 90;
crn(toast, 14);
stk(toast, 0.15, C.st);
local function pop(s)
	toast.Visible = true;
	toast.Text = s;
	toast.TextTransparency = 1;
	toast.BackgroundTransparency = 1;
	toast.Position = UDim2.new(0.5, 0, 1, -6);
	tw(toast, opt.red and 0.1 or 0.16, {
		TextTransparency = 0,
		BackgroundTransparency = 0.06,
		Position = UDim2.new(0.5, 0, 1, -10)
	});
	task.delay(1.25, function()
		if toast.Visible then
			local tr = tw(toast, opt.red and 0.1 or 0.16, {
				TextTransparency = 1,
				BackgroundTransparency = 1,
				Position = UDim2.new(0.5, 0, 1, -6)
			});
			if tr then
				tr.Completed:Wait();
			end;
			toast.Visible = false;
		end;
	end);
end;
local setP = Instance.new("Frame");
setP.Parent = gui;
setP.BackgroundTransparency = 1;
setP.Size = UDim2.new(1, 0, 1, 0);
setP.Visible = false;
setP.ZIndex = 200;
local dim = Instance.new("Frame");
dim.Parent = setP;
dim.BackgroundColor3 = C.b0;
dim.BackgroundTransparency = 1;
dim.BorderSizePixel = 0;
dim.Size = UDim2.new(1, 0, 1, 0);
dim.ZIndex = 200;
local setW = Instance.new("Frame");
setW.Parent = setP;
setW.BackgroundColor3 = C.b1;
setW.BorderSizePixel = 0;
setW.AnchorPoint = Vector2.new(1, 0.5);
setW.Position = UDim2.new(1, 20, 0.5, 0);
setW.Size = UDim2.new(0, 340, 0, 360);
setW.ZIndex = 201;
setW.ClipsDescendants = true;
crn(setW, 18);
stk(setW, 0, C.st);
local stT = txt(setW, "Settings", 16, true, C.w0);
stT.Position = UDim2.new(0, 14, 0, 12);
stT.Size = UDim2.new(1, -70, 0, 20);
stT.ZIndex = 202;
local stX, stXS = btn(setW, "X");
stX.Position = UDim2.new(1, -56, 0, 10);
stX.Size = UDim2.new(0, 42, 0, 34);
stX.ZIndex = 202;
hvr(stX, stXS);
local stSc = Instance.new("ScrollingFrame");
stSc.Parent = setW;
stSc.BackgroundTransparency = 1;
stSc.BorderSizePixel = 0;
stSc.Position = UDim2.new(0, 0, 0, 50);
stSc.Size = UDim2.new(1, 0, 1, -50);
stSc.ScrollBarThickness = 3;
stSc.ScrollBarImageColor3 = C.w0;
stSc.ScrollBarImageTransparency = 0.86;
stSc.TopImage, stSc.MidImage, stSc.BottomImage = "", "", "";
stSc.ZIndex = 202;
pad(stSc, 14, 14, 10, 14);
local stLay = Instance.new("UIListLayout");
stLay.Parent = stSc;
stLay.SortOrder = Enum.SortOrder.LayoutOrder;
stLay.Padding = UDim.new(0, 10);
(stLay:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
	stSc.CanvasSize = UDim2.new(0, 0, 0, stLay.AbsoluteContentSize.Y + 18);
end);
stSc.CanvasSize = UDim2.new(0, 0, 0, 18);
local function row(h)
	local r = Instance.new("Frame");
	r.Parent = stSc;
	r.BackgroundColor3 = C.b2;
	r.BackgroundTransparency = 0.06;
	r.BorderSizePixel = 0;
	r.Size = UDim2.new(1, 0, 0, h or 44);
	r.ZIndex = 202;
	crn(r, 16);
	stk(r, 0.22, C.st);
	return r;
end;
local function tog(r, s, getv, setv)
	local t = txt(r, s, 13, true, C.w0);
	t.Position = UDim2.new(0, 12, 0, 0);
	t.Size = UDim2.new(1, -80, 1, 0);
	t.ZIndex = 203;
	local b = Instance.new("TextButton");
	b.Parent = r;
	b.AutoButtonColor = false;
	b.Text = "";
	b.BorderSizePixel = 0;
	b.BackgroundColor3 = C.b1;
	b.Position = UDim2.new(1, -54, 0.5, -14);
	b.Size = UDim2.new(0, 44, 0, 28);
	b.ZIndex = 203;
	crn(b, 14);
	local bs = stk(b, 0.22, C.st);
	local k = Instance.new("Frame");
	k.Parent = b;
	k.BorderSizePixel = 0;
	k.BackgroundColor3 = C.w0;
	k.Size = UDim2.new(0, 18, 0, 18);
	k.Position = UDim2.new(0, 6, 0.5, -9);
	k.ZIndex = 204;
	crn(k, 99);
	local function ap()
		local on = getv();
		if on then
			tw(b, opt.red and 0.06 or 0.11, {
				BackgroundColor3 = C.b4
			});
			tw(k, opt.red and 0.06 or 0.11, {
				Position = UDim2.new(1, -24, 0.5, -9)
			});
			if bs then
				tw(bs, opt.red and 0.06 or 0.11, {
					Transparency = 0
				});
			end;
		else
			tw(b, opt.red and 0.06 or 0.11, {
				BackgroundColor3 = C.b1
			});
			tw(k, opt.red and 0.06 or 0.11, {
				Position = UDim2.new(0, 6, 0.5, -9)
			});
			if bs then
				tw(bs, opt.red and 0.06 or 0.11, {
					Transparency = 0.22
				});
			end;
		end;
	end;
	ap();
	b.MouseButton1Click:Connect(function()
		rip(b);
		setv(not getv());
		ap();
	end);
	return ap;
end;
local function step(r, s, mn, mx, getv, setv)
	local t = txt(r, s, 13, true, C.w0);
	t.Position = UDim2.new(0, 12, 0, 0);
	t.Size = UDim2.new(1, -170, 1, 0);
	t.ZIndex = 203;
	local vL = txt(r, "", 12, false, C.w1);
	vL.TextXAlignment = Enum.TextXAlignment.Right;
	vL.Position = UDim2.new(1, -170, 0, 0);
	vL.Size = UDim2.new(0, 110, 1, 0);
	vL.ZIndex = 203;
	local box = Instance.new("Frame");
	box.Parent = r;
	box.BackgroundColor3 = C.b1;
	box.BorderSizePixel = 0;
	box.Position = UDim2.new(1, -54, 0.5, -10);
	box.Size = UDim2.new(0, 44, 0, 20);
	box.ZIndex = 203;
	crn(box, 10);
	stk(box, 0.22, C.st);
	local dn, dnS = btn(box, "<");
	dn.Size = UDim2.new(0.5, -2, 1, 0);
	dn.Position = UDim2.new(0, 0, 0, 0);
	dn.ZIndex = 204;
	dn.BackgroundColor3 = C.b2;
	hvr(dn, dnS);
	local up, upS = btn(box, ">");
	up.Size = UDim2.new(0.5, -2, 1, 0);
	up.Position = UDim2.new(0.5, 2, 0, 0);
	up.ZIndex = 204;
	up.BackgroundColor3 = C.b2;
	hvr(up, upS);
	local function ap()
		vL.Text = tostring(getv());
	end;
	ap();
	up.MouseButton1Click:Connect(function()
		rip(up);
		setv(math.clamp(getv() + 5, mn, mx));
		ap();
	end);
	dn.MouseButton1Click:Connect(function()
		rip(dn);
		setv(math.clamp(getv() - 5, mn, mx));
		ap();
	end);
	return ap;
end;
local ap1 = tog(row(44), "Blur behind UI", function()
	return opt.blr;
end, function(v)
	opt.blr = v;
end);
local ap2 = tog(row(44), "Reduce motion", function()
	return opt.red;
end, function(v)
	opt.red = v;
end);
local ap3 = tog(row(44), "Confirm before load", function()
	return opt.ask;
end, function(v)
	opt.ask = v;
end);
local ap4 = tog(row(44), "Auto close on load", function()
	return opt.autoClose;
end, function(v)
	opt.autoClose = v;
end);
local ap5 = tog(row(44), "Cache commits", function()
	return opt.cache;
end, function(v)
	opt.cache = v;
end);
local ap6 = tog(row(44), "Show path text", function()
	return opt.showPath;
end, function(v)
	opt.showPath = v;
end);
local ap7 = tog(row(44), "Copy raw on load", function()
	return opt.copyRaw;
end, function(v)
	opt.copyRaw = v;
end);
local ap8 = tog(row(44), "Highlight latest", function()
	return opt.hi;
end, function(v)
	opt.hi = v;
end);
local ap9 = tog(row(44), "Compact rows", function()
	return opt.cmp;
end, function(v)
	opt.cmp = v;
end);
local apA = tog(row(44), "Show date line", function()
	return opt.shw;
end, function(v)
	opt.shw = v;
end);
local apB = step(row(44), "Commit count", 10, 100, function()
	return opt.cnt;
end, function(v)
	opt.cnt = v;
end);
local function openSet(v)
	if v then
		setP.Visible = true;
		dim.BackgroundTransparency = 1;
		setW.Position = UDim2.new(1, 20, 0.5, 0);
		if blur and opt.blr then
			tw(blur, opt.red and 0.1 or 0.16, {
				Size = 14
			});
		end;
		tw(dim, opt.red and 0.1 or 0.16, {
			BackgroundTransparency = 0.45
		});
		tw(setW, opt.red and 0.12 or 0.18, {
			Position = UDim2.new(1, -10, 0.5, 0)
		});
	else
		if blur then
			tw(blur, opt.red and 0.1 or 0.16, {
				Size = 0
			});
		end;
		tw(dim, opt.red and 0.1 or 0.16, {
			BackgroundTransparency = 1
		});
		local tr = tw(setW, opt.red and 0.1 or 0.16, {
			Position = UDim2.new(1, 20, 0.5, 0)
		});
		if tr then
			tr.Completed:Wait();
		end;
		setP.Visible = false;
	end;
end;
bCfg.MouseButton1Click:Connect(function()
	rip(bCfg);
	openSet(true);
end);
stX.MouseButton1Click:Connect(function()
	rip(stX);
	openSet(false);
end);
dim.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		openSet(false);
	end;
end);
local cache = {};
local cur = nil;
local items = {};
local function clrList()
	for _, v in ipairs(items) do
		if v and v.f then
			pcall(function()
				v.f:Destroy();
			end);
		end;
	end;
	table.clear(items);
end;
local function rowH()
	return opt.cmp and 64 or 86;
end;
local function mkIt(ch, v, idx)
	local f = Instance.new("Frame");
	f.Parent = list;
	f.BackgroundColor3 = C.b2;
	f.BackgroundTransparency = 0.04;
	f.BorderSizePixel = 0;
	f.Size = UDim2.new(1, 0, 0, rowH());
	f.ClipsDescendants = true;
	crn(f, 16);
	local fs = stk(f, 0.22, C.st);
	local tag = idx == 1 and "LATEST" or "COMMIT " .. tostring(idx);
	local sha = shortSha(v.sha);
	local hd = txt(f, tag .. "  " .. sha, 13, true, C.w0);
	hd.Position = UDim2.new(0, 14, 0, 10);
	hd.Size = UDim2.new(1, -124, 0, 18);
	local dt = txt(f, tostring(v.date or "N/A"), 12, false, C.w2);
	dt.Position = UDim2.new(0, 14, 0, 30);
	dt.Size = UDim2.new(1, -124, 0, 16);
	dt.Visible = opt.shw;
	local msg = tostring(v.msg or "No message");
	msg = (msg:gsub("\r", " ")):gsub("\n", " ");
	if #msg > 92 then
		msg = string.sub(msg, 1, 89) .. "...";
	end;
	local tx = txt(f, msg, 12, false, C.w1);
	tx.Position = UDim2.new(0, 14, 0, opt.shw and 48 or 32);
	tx.Size = UDim2.new(1, -124, 0, 16);
	local ld, ldS = btn(f, "LOAD");
	ld.Size = UDim2.new(0, 92, 0, 34);
	ld.Position = UDim2.new(1, -104, 0.5, -17);
	hvr(ld, ldS);
	if opt.hi and idx == 1 then
		f.BackgroundColor3 = C.b3;
		hd.TextColor3 = C.w0;
		if fs then
			fs.Transparency = 0.06;
		end;
	end;
	local function getRaw()
		if v and v.sha then
			return mkRawFromCommit(ch, v.sha);
		end;
		return ch.headRaw;
	end;
	local arm = false;
	local function doLoad()
		local raw = getRaw();
		if opt.copyRaw then
			safeClip(raw);
		end;
		if opt.autoClose then
			root.Visible = false;
			gui.Enabled = false;
		end;
		local ok, err = pcall(function()
			(loadstring(game:HttpGet(raw)))();
		end);
		if not ok then
			pcall(function()
				if rconsoleerr then
					rconsoleerr("Load failed: " .. tostring(err));
				end;
			end);
			gui.Enabled = true;
			root.Visible = true;
			pop("Load failed");
			return;
		end;
		pop("Loaded");
	end;
	ld.MouseButton1Click:Connect(function()
		rip(ld);
		if opt.ask then
			if not arm then
				arm = true;
				pop("Click again to confirm");
				task.delay(0.9, function()
					arm = false;
				end);
				return;
			end;
			arm = false;
		end;
		doLoad();
	end);
	f.MouseEnter:Connect(function()
		tw(f, opt.red and 0.06 or 0.11, {
			BackgroundColor3 = C.b4
		});
		if fs then
			tw(fs, opt.red and 0.06 or 0.11, {
				Transparency = 0
			});
		end;
	end);
	f.MouseLeave:Connect(function()
		local bc = opt.hi and idx == 1 and C.b3 or C.b2;
		tw(f, opt.red and 0.06 or 0.11, {
			BackgroundColor3 = bc
		});
		if fs then
			tw(fs, opt.red and 0.06 or 0.11, {
				Transparency = opt.hi and idx == 1 and 0.06 or 0.22
			});
		end;
	end);
	return {
		f = f,
		sha = v.sha,
		msg = msg,
		date = tostring(v.date or "")
	};
end;
local function setBusy(v, s)
	spin.Visible = v and true or false;
	chS.Text = s or "";
end;
local function applyChBtns()
	for _, it in pairs(chBtn) do
		local on = cur and it.ch and cur.key == it.ch.key;
		it.a.BackgroundTransparency = on and 0.1 or 0.65;
		it.p.Text = opt.showPath and it.ch.path or "Open versions";
	end;
end;
local function build(ch, list0)
	clrList();
	items = {};
	local tot = #list0;
	for i, v in ipairs(list0) do
		items[(#items) + 1] = mkIt(ch, v, i, tot);
	end;
end;
local function filt()
	local q = (src.Text or ""):lower();
	for _, it in ipairs(items) do
		if it and it.f then
			if q == "" then
				it.f.Visible = true;
			else
				local ok = false;
				ok = ok or it.sha and ((tostring(it.sha)):lower()):find(q, 1, true) ~= nil;
				ok = ok or it.msg and (it.msg:lower()):find(q, 1, true) ~= nil;
				ok = ok or it.date and (it.date:lower()):find(q, 1, true) ~= nil;
				it.f.Visible = ok;
			end;
		end;
	end;
end;
local sDb = 0;
(src:GetPropertyChangedSignal("Text")):Connect(function()
	sDb += 1;
	local c = sDb;
	task.delay(0.12, function()
		if c == sDb then
			filt();
		end;
	end);
end);
local function openCh(ch)
	cur = ch;
	applyChBtns();
	src.Text = "";
	chT.Text = ch.name;
	chS.Text = "Fetching...";
	setBusy(true, "Fetching commits...");
	local n = math.clamp(tonumber(opt.cnt) or 60, 10, 100);
	local use = opt.cache and cache[ch.key] and #cache[ch.key] >= 1 and #cache[ch.key] >= math.min(10);
	if use then
		setBusy(false, "Loaded from cache (" .. tostring(#cache[ch.key]) .. ")");
		build(ch, cache[ch.key]);
		filt();
		return;
	end;
	task.spawn(function()
		local list0, err = getCommits(ch, n);
		if not list0 then
			setBusy(false, tostring(err or "Fetch failed"));
			pop("Fetch failed (loading latest)");
			build(ch, {
				{
					sha = nil,
					date = "N/A",
					msg = "Latest from " .. br
				}
			});
			return;
		end;
		cache[ch.key] = list0;
		setBusy(false, "Total: " .. tostring((#list0)));
		build(ch, list0);
		filt();
	end);
end;
for _, it in pairs(chBtn) do
	it.b.MouseButton1Click:Connect(function()
		rip(it.b);
		openCh(it.ch);
	end);
end;
local minned = false;
local sz0 = root.Size;
bMin.MouseButton1Click:Connect(function()
	rip(bMin);
	minned = not minned;
	if minned then
		bMin.Text = "+";
		tw(root, opt.red and 0.1 or 0.16, {
			Size = UDim2.new(0, sz0.X.Offset, 0, 56)
		});
		side.Visible = false;
		main.Visible = false;
	else
		bMin.Text = "-";
		side.Visible = true;
		main.Visible = true;
		tw(root, opt.red and 0.1 or 0.16, {
			Size = sz0
		});
	end;
end);
bX.MouseButton1Click:Connect(function()
	rip(bX);
	if blur then
		pcall(function()
			blur:Destroy();
		end);
	end;
	gui:Destroy();
end);
bg.InputBegan:Connect(function(inp)
	if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
		if setP.Visible then
			openSet(false);
		end;
	end;
end);
local function applySet()
	ap1();
	ap2();
	ap3();
	ap4();
	ap5();
	ap6();
	ap7();
	ap8();
	ap9();
	apA();
	apB();
	for _, it in pairs(chBtn) do
		it.p.Text = opt.showPath and it.ch.path or "Open versions";
	end;
	for _, it in ipairs(items) do
		if it and it.f then
			it.f.Size = UDim2.new(1, 0, 0, rowH());
		end;
	end;
	if cur and opt.cache and cache[cur.key] then
		cache[cur.key] = cache[cur.key];
	end;
	if not opt.blr and blur then
		blur.Size = 0;
	end;
end;
(setP:GetPropertyChangedSignal("Visible")):Connect(function()
	applySet();
end);
applySet();
guiii.draggerV2(root, top);
openCh(chans.main);
pop("Ready");
