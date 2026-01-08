local NA_SRV = setmetatable({}, {
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
local function S(name)
	return NA_SRV[name];
end;
local tw, rs, uis, plrs, cg, hs, ts, lg = S("TweenService"), S("RunService"), S("UserInputService"), S("Players"), S("CoreGui"), S("HttpService"), S("TextService"), S("Lighting");
local function pick()
	local cg = S("CoreGui");
	local lp = (S("Players")).LocalPlayer;
	if gethui then
		return gethui();
	elseif cg and cg:FindFirstChild("RobloxGui") then
		return cg:FindFirstChild("RobloxGui");
	elseif cg then
		return cg;
	else
		local lp2 = (S("Players")).LocalPlayer;
		if lp2 and lp2:FindFirstChildWhichIsA("PlayerGui") then
			return lp2:FindFirstChildWhichIsA("PlayerGui");
		end;
	end;
	return nil;
end;
local function findGui()
	local a;
	pcall(function()
		if gethui then
			a = gethui();
		end;
	end);
	local b = cg:FindFirstChild("RobloxGui");
	local c = cg;
	local d = plrs.LocalPlayer and plrs.LocalPlayer:FindFirstChildWhichIsA("PlayerGui");
	for _, p in ipairs({
		a,
		b,
		c,
		d
	}) do
		if typeof(p) == "Instance" then
			local g = p:FindFirstChild("EnhancedNotif");
			if g then
				return g, p;
			end;
		end;
	end;
end;
local TH = {
	Txt = Color3.fromRGB(235, 235, 235),
	Ttl = Color3.fromRGB(255, 255, 255),
	Mut = Color3.fromRGB(170, 170, 170),
	Bg0 = Color3.fromRGB(10, 10, 10),
	Bg1 = Color3.fromRGB(18, 18, 18),
	Bg2 = Color3.fromRGB(26, 26, 26),
	St0 = Color3.fromRGB(255, 255, 255),
	St1 = Color3.fromRGB(85, 85, 85),
	Btn0 = Color3.fromRGB(22, 22, 22),
	Btn1 = Color3.fromRGB(32, 32, 32),
	Btn2 = Color3.fromRGB(16, 16, 16),
	Bad0 = Color3.fromRGB(235, 70, 70),
	Bad1 = Color3.fromRGB(255, 95, 95),
	Ok0 = Color3.fromRGB(0, 180, 110),
	Ok1 = Color3.fromRGB(0, 210, 130),
	Line = Color3.fromRGB(70, 70, 70),
	Prog = Color3.fromRGB(255, 255, 255),
	Ph = Color3.fromRGB(160, 160, 160)
};
local PAD, GAP = 14, 12;
local FPATH = "enhanced_notif_fonts.json";
local DPATH = "enhanced_notif_docks.json";
local FONTS = {};
do
	for _, e in ipairs(Enum.Font:GetEnumItems()) do
		table.insert(FONTS, {
			e.Name,
			e
		});
	end;
	table.sort(FONTS, function(a, b)
		return a[1] < b[1];
	end);
end;
local ex, exPar = findGui();
if _G.EnhancedNotifs and ex then
	return _G.EnhancedNotifs;
end;
local root = exPar or pick();
local gui = ex or Instance.new("ScreenGui");
gui.Name = "EnhancedNotif";
gui.IgnoreGuiInset = true;
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
gui.DisplayOrder = 2147483647;
gui.ResetOnSpawn = false;
if not gui.Parent then
	gui.Parent = root;
end;
local ov = gui:FindFirstChild("EN_Overlay") or Instance.new("Frame");
ov.Name = "EN_Overlay";
ov.BackgroundTransparency = 1;
ov.BackgroundColor3 = Color3.new(0, 0, 0);
ov.Size = UDim2.fromScale(1, 1);
ov.ZIndex = 50000;
ov.Parent = gui;
local ACT = {
	Notify = setmetatable({}, {
		__mode = "k"
	}),
	Window = setmetatable({}, {
		__mode = "k"
	}),
	Popup = setmetatable({}, {
		__mode = "k"
	})
};
local CURF = {
	Notify = Enum.Font.Gotham,
	Window = Enum.Font.Gotham,
	Popup = Enum.Font.Gotham
};
local function canfs()
	return (isfile and readfile and writefile) ~= nil;
end;
do
	if canfs() and isfile(FPATH) then
		local ok, dat = pcall(function()
			return hs:JSONDecode(readfile(FPATH));
		end);
		if ok and type(dat) == "table" then
			for k, v in pairs(dat) do
				for _, p in ipairs(FONTS) do
					if p[1] == v then
						CURF[k] = p[2];
					end;
				end;
			end;
		end;
	end;
end;
local function saveFonts()
	if not canfs() then
		return;
	end;
	local out = {};
	for k, v in pairs(CURF) do
		for _, p in ipairs(FONTS) do
			if p[2] == v then
				out[k] = p[1];
			end;
		end;
	end;
	pcall(function()
		writefile(FPATH, hs:JSONEncode(out));
	end);
end;
local function applyFontTree(r, f)
	for _, d in ipairs(r:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			d.Font = f;
		end;
	end;
end;
local function setFontKind(kind, f)
	CURF[kind] = f;
	saveFonts();
	for c in pairs(ACT[kind]) do
		if c and c.Parent then
			applyFontTree(c, f);
		end;
	end;
end;
local CURD = {
	Notify = "bottomRight",
	Window = "top",
	Popup = "top"
};
do
	if canfs() and isfile(DPATH) then
		local ok, dat = pcall(function()
			return hs:JSONDecode(readfile(DPATH));
		end);
		if ok and type(dat) == "table" then
			for k, v in pairs(dat) do
				CURD[k] = v;
			end;
		end;
	end;
end;
local function saveDocks()
	if not canfs() then
		return;
	end;
	pcall(function()
		writefile(DPATH, hs:JSONEncode(CURD));
	end);
end;
local function nW()
	return math.floor(math.clamp(gui.AbsoluteSize.X * 0.28, 280, 420));
end;
local function wW()
	return math.floor(math.clamp(gui.AbsoluteSize.X * 0.38, 360, 600));
end;
local stacks = {};
local function mkStack(key)
	local f = Instance.new("Frame");
	f.Name = "Stack_" .. key;
	f.BackgroundTransparency = 1;
	f.Parent = gui;
	local l = Instance.new("UIListLayout", f);
	l.Padding = UDim.new(0, GAP);
	l.SortOrder = Enum.SortOrder.LayoutOrder;
	if key == "bottomRight" then
		f.AnchorPoint = Vector2.new(1, 1);
		f.Position = UDim2.new(1, -24, 1, -24);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Right;
		l.VerticalAlignment = Enum.VerticalAlignment.Bottom;
	elseif key == "bottomLeft" then
		f.AnchorPoint = Vector2.new(0, 1);
		f.Position = UDim2.new(0, 24, 1, -24);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Left;
		l.VerticalAlignment = Enum.VerticalAlignment.Bottom;
	elseif key == "topRight" then
		f.AnchorPoint = Vector2.new(1, 0);
		f.Position = UDim2.new(1, -24, 0, 24);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Right;
		l.VerticalAlignment = Enum.VerticalAlignment.Top;
	elseif key == "topLeft" then
		f.AnchorPoint = Vector2.new(0, 0);
		f.Position = UDim2.new(0, 24, 0, 24);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Left;
		l.VerticalAlignment = Enum.VerticalAlignment.Top;
	elseif key == "top" then
		f.AnchorPoint = Vector2.new(0.5, 0);
		f.Position = UDim2.new(0.5, 0, 0, 24);
		f.Size = UDim2.new(0, wW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		l.VerticalAlignment = Enum.VerticalAlignment.Top;
	elseif key == "bottom" then
		f.AnchorPoint = Vector2.new(0.5, 1);
		f.Position = UDim2.new(0.5, 0, 1, -24);
		f.Size = UDim2.new(0, wW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		l.VerticalAlignment = Enum.VerticalAlignment.Bottom;
	else
		return mkStack("bottomRight");
	end;
	return f;
end;
local function getStack(key)
	key = key or "bottomRight";
	if not stacks[key] or (not stacks[key].Parent) then
		stacks[key] = mkStack(key);
	end;
	return stacks[key];
end;
(gui:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
	for k, f in pairs(stacks) do
		if f and f.Parent then
			f.Size = (k == "top" or k == "bottom") and UDim2.new(0, wW(), 1, 0) or UDim2.new(0, nW(), 1, 0);
		end;
	end;
end);
local function ensureGui()
	if not gui or (not gui.Parent) or (not gui.Parent.Parent) then
		local g, p = findGui();
		if g then
			gui = g;
			root = p;
		else
			root = pick();
			gui = Instance.new("ScreenGui");
			gui.Name = "EnhancedNotif";
			gui.IgnoreGuiInset = true;
			gui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
			gui.DisplayOrder = 2147483647;
			gui.ResetOnSpawn = false;
			gui.Parent = root;
		end;
		ov = gui:FindFirstChild("EN_Overlay") or Instance.new("Frame");
		ov.Name = "EN_Overlay";
		ov.BackgroundTransparency = 1;
		ov.BackgroundColor3 = Color3.new(0, 0, 0);
		ov.Size = UDim2.fromScale(1, 1);
		ov.ZIndex = 50000;
		ov.Parent = gui;
		stacks = {};
	end;
end;
gui.Destroying:Connect(function()
	gui = nil;
	stacks = {};
end);
local VALID = {
	bottomRight = true,
	bottomLeft = true,
	topRight = true,
	topLeft = true,
	top = true,
	bottom = true
};
local ALIAS = {
	topright = "topRight",
	["top right"] = "topRight",
	tr = "topRight",
	topleft = "topLeft",
	["top left"] = "topLeft",
	tl = "topLeft",
	bottomright = "bottomRight",
	["bottom right"] = "bottomRight",
	br = "bottomRight",
	bottomleft = "bottomLeft",
	["bottom left"] = "bottomLeft",
	bl = "bottomLeft",
	["center top"] = "top",
	centertop = "top",
	["center bottom"] = "bottom",
	centerbottom = "bottom"
};
local function mapDock(s)
	s = (tostring(s or "")):lower();
	local m = ALIAS[s] or s;
	return VALID[m] and m or "bottomRight";
end;
local function cntH(c)
	local lay = c:FindFirstChildOfClass("UIListLayout");
	local pad = c:FindFirstChildOfClass("UIPadding");
	local top = pad and pad.PaddingTop.Offset or 0;
	local bot = pad and pad.PaddingBottom.Offset or 0;
	local last = -1;
	for _ = 1, 30 do
		rs.Heartbeat:Wait();
		local h = (lay and lay.AbsoluteContentSize.Y or 0) + top + bot;
		if math.abs(h - last) < 1 then
			return h;
		end;
		last = h;
	end;
	return math.max(0, last);
end;
local function setAAll(root, a)
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			d.TextTransparency = a;
		end;
		if d:IsA("ImageLabel") then
			d.ImageTransparency = a;
		end;
	end;
end;
local function stgInAll(root, dur)
	local t = TweenInfo.new(dur or 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			d.TextTransparency = 1;
			(tw:Create(d, t, {
				TextTransparency = 0
			})):Play();
		elseif d:IsA("ImageLabel") then
			d.ImageTransparency = 1;
			(tw:Create(d, t, {
				ImageTransparency = 0
			})):Play();
		end;
	end;
end;
local function dirFrom(str)
	str = string.lower(tostring(str or ""));
	local d = {
		dx = 0,
		dy = 14,
		rot = -2.5
	};
	if str == "top" or str == "up" then
		d.dy = -14;
		d.rot = 2.5;
	elseif str == "bottom" or str == "down" then
		d.dy = 14;
		d.rot = -2.5;
	elseif str == "topright" or str == "top right" then
		d.dx = 18;
		d.dy = -18;
		d.rot = 2.5;
	elseif str == "topleft" or str == "top left" then
		d.dx = -18;
		d.dy = -18;
		d.rot = 2.5;
	elseif str == "bottomright" or str == "bottom right" then
		d.dx = 18;
		d.dy = 18;
		d.rot = -2.5;
	elseif str == "bottomleft" or str == "bottom left" then
		d.dx = -18;
		d.dy = 18;
		d.rot = -2.5;
	end;
	return d;
end;
local ST = setmetatable({}, {
	__mode = "k"
});
local function ctx(x)
	local s = ST[x];
	if not s then
		s = {};
		ST[x] = s;
	end;
	return s;
end;
local function drag(frame, handle)
	local g = false;
	local sp, su;
	local mv = false;
	handle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			g = true;
			sp = i.Position;
			su = frame.Position;
			mv = false;
		end;
	end);
	handle.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			g = false;
		end;
	end);
	uis.InputChanged:Connect(function(i)
		if g and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - sp;
			if not mv and (math.abs(d.X) > 0 or math.abs(d.Y) > 0) then
				mv = true;
				(ctx(frame)).popupManual = true;
			end;
			frame.Position = UDim2.new(su.X.Scale, su.X.Offset + d.X, su.Y.Scale, su.Y.Offset + d.Y);
		end;
	end);
end;
local function centerPopupRoot(f, force)
	if not f then
		return;
	end;
	local s = ctx(f);
	if not force and s.popupManual then
		return;
	end;
	if force then
		s.popupManual = nil;
	end;
	f.AnchorPoint = Vector2.new(0.5, 0.5);
	f.Position = UDim2.new(0.5, 0, 0.5, 0);
end;
local function trackPopupCenter(root2, card)
	if not (root2 and card) then
		return;
	end;
	local function ref(force)
		centerPopupRoot(root2, force);
	end;
	ref(true);
	(card:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
		ref();
	end);
	local cam = workspace.CurrentCamera;
	if cam then
		(cam:GetPropertyChangedSignal("ViewportSize")):Connect(function()
			ref();
		end);
	end;
end;
local function mkIcn(par, txt, z, font, stl)
	local b = Instance.new("TextButton");
	b.AutoButtonColor = false;
	b.Text = "";
	b.BackgroundColor3 = TH.Btn0;
	b.BackgroundTransparency = 0.06;
	b.Size = UDim2.fromOffset(28, 28);
	b.ZIndex = z;
	b.ClipsDescendants = true;
	b.Parent = par;
	local cr = Instance.new("UICorner", b);
	cr.CornerRadius = UDim.new(0, 999);
	local st = Instance.new("UIStroke", b);
	st.Color = TH.St0;
	st.Transparency = 0.78;
	st.Thickness = 1;
	local lb = Instance.new("TextLabel");
	lb.BackgroundTransparency = 1;
	lb.Size = UDim2.fromScale(1, 1);
	lb.ZIndex = z + 1;
	lb.Font = font or Enum.Font.Gotham;
	lb.Text = txt or "";
	lb.TextScaled = true;
	lb.TextColor3 = TH.Txt;
	lb.Parent = b;
	local cst = Instance.new("UITextSizeConstraint", lb);
	cst.MinTextSize = 10;
	cst.MaxTextSize = 18;
	b:SetAttribute("_stl", stl or "");
	b:SetAttribute("sel", false);
	local function col()
		local s = b:GetAttribute("sel") and true or false;
		local t = b:GetAttribute("_stl") or "";
		if s then
			return TH.Ok1, 0.08;
		end;
		if t == "bad" then
			return TH.Bad0, 0.08;
		end;
		return TH.Btn0, 0.06;
	end;
	local function hov(on)
		if b:GetAttribute("sel") then
			return;
		end;
		local t = b:GetAttribute("_stl") or "";
		if t == "bad" then
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = on and TH.Bad1 or TH.Bad0
			})):Play();
		else
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = on and TH.Btn1 or TH.Btn0
			})):Play();
		end;
	end;
	b.MouseEnter:Connect(function()
		hov(true);
	end);
	b.MouseLeave:Connect(function()
		hov(false);
	end);
	b.MouseButton1Down:Connect(function()
		if b:GetAttribute("sel") then
			return;
		end;
		local t = b:GetAttribute("_stl") or "";
		(tw:Create(b, TweenInfo.new(0.08), {
			BackgroundColor3 = t == "bad" and TH.Bad0 or TH.Btn2
		})):Play();
	end);
	b.MouseButton1Up:Connect(function()
		local bc, bt = col();
		(tw:Create(b, TweenInfo.new(0.1), {
			BackgroundColor3 = bc,
			BackgroundTransparency = bt
		})):Play();
	end);
	local function setSel(on)
		b:SetAttribute("sel", on and true or false);
		local bc, bt = col();
		(tw:Create(b, TweenInfo.new(0.1), {
			BackgroundColor3 = bc,
			BackgroundTransparency = bt
		})):Play();
	end;
	return b, setSel;
end;
local function mkMenuBtn(par, txt, z, font)
	local b = Instance.new("TextButton");
	b.AutoButtonColor = false;
	b.Text = txt or "";
	b.TextScaled = true;
	b.TextWrapped = true;
	b.Font = font or Enum.Font.Gotham;
	b.TextColor3 = TH.Txt;
	b.RichText = true;
	b.BackgroundColor3 = TH.Btn0;
	b.BackgroundTransparency = 0.08;
	b.Size = UDim2.new(1, 0, 0, 28);
	b.ZIndex = z;
	b.ClipsDescendants = true;
	local c = Instance.new("UICorner", b);
	c.CornerRadius = UDim.new(0, 12);
	local st = Instance.new("UIStroke", b);
	st.Color = TH.St0;
	st.Transparency = 0.84;
	st.Thickness = 1;
	local tsz = Instance.new("UITextSizeConstraint", b);
	tsz.MinTextSize = 11;
	tsz.MaxTextSize = 16;
	b.Parent = par;
	b.MouseEnter:Connect(function()
		(tw:Create(b, TweenInfo.new(0.12), {
			BackgroundColor3 = TH.Btn1
		})):Play();
	end);
	b.MouseLeave:Connect(function()
		(tw:Create(b, TweenInfo.new(0.12), {
			BackgroundColor3 = TH.Btn0
		})):Play();
	end);
	return b;
end;
local function placeMenu(btn, menu)
	local aw, ah = gui.AbsoluteSize.X, gui.AbsoluteSize.Y;
	local fa = btn.AbsolutePosition;
	local fs = btn.AbsoluteSize;
	local ms = menu.AbsoluteSize;
	local mw, mh = math.max(ms.X, 200), math.max(ms.Y, 90);
	local left = fa.X + fs.X + 8 + mw > aw;
	local x = left and fa.X - 8 - mw or fa.X + fs.X + 8;
	local y = math.clamp(fa.Y - 8, 8, ah - mh - 8);
	menu.Position = UDim2.fromOffset(x, y);
	menu.Size = UDim2.new(0, mw, 0, mh);
end;
local function mkHdr(par, z, kind, onPause)
	local state = ctx(par);
	local hdr = Instance.new("Frame");
	hdr.Name = "Header";
	hdr.BackgroundTransparency = 1;
	hdr.Size = UDim2.new(1, 0, 0, 44);
	hdr.ZIndex = z + 200;
	hdr.Parent = par;
	local top = Instance.new("Frame");
	top.Name = "TopLine";
	top.BorderSizePixel = 0;
	top.BackgroundColor3 = TH.St0;
	top.BackgroundTransparency = 0.82;
	top.Position = UDim2.new(0, PAD, 1, -1);
	top.Size = UDim2.new(1, (-PAD) * 2, 0, 1);
	top.ZIndex = z + 199;
	top.Parent = hdr;
	local act = Instance.new("Frame");
	act.Name = "Actions";
	act.AnchorPoint = Vector2.new(1, 0.5);
	act.Position = UDim2.new(1, -PAD, 0.5, 0);
	act.Size = UDim2.new(0, 0, 1, 0);
	act.AutomaticSize = Enum.AutomaticSize.X;
	act.BackgroundTransparency = 1;
	act.ZIndex = z + 220;
	act.Parent = hdr;
	local lay = Instance.new("UIListLayout", act);
	lay.FillDirection = Enum.FillDirection.Horizontal;
	lay.HorizontalAlignment = Enum.HorizontalAlignment.Right;
	lay.VerticalAlignment = Enum.VerticalAlignment.Center;
	lay.Padding = UDim.new(0, 8);
	local posBtn, setPosSel;
	if kind ~= "Popup" then
		posBtn, setPosSel = mkIcn(act, "≡", act.ZIndex + 1, CURF[kind]);
	end;
	local fbtn, setFontSel = mkIcn(act, "Aa", act.ZIndex + 1, CURF[kind]);
	local cls, _ = mkIcn(act, "×", act.ZIndex + 1, CURF[kind], "bad");
	local dot = Instance.new("Frame");
	dot.Name = "Dot";
	dot.BackgroundColor3 = TH.St0;
	dot.BackgroundTransparency = 0.05;
	dot.BorderSizePixel = 0;
	dot.Size = UDim2.fromOffset(8, 8);
	dot.Position = UDim2.new(0, PAD, 0.5, -4);
	dot.ZIndex = z + 210;
	dot.Parent = hdr;
	local dc = Instance.new("UICorner", dot);
	dc.CornerRadius = UDim.new(0, 999);
	local ds = Instance.new("UIStroke", dot);
	ds.Color = TH.St0;
	ds.Transparency = 0.7;
	ds.Thickness = 1;
	local ttl = Instance.new("TextLabel");
	ttl.Name = "Title";
	ttl.AnchorPoint = Vector2.new(0, 0.5);
	ttl.Position = UDim2.new(0, PAD + 14, 0.5, 0);
	ttl.Size = UDim2.new(1, -(PAD + act.AbsoluteSize.X + PAD + 14), 1, 0);
	ttl.BackgroundTransparency = 1;
	ttl.TextTruncate = Enum.TextTruncate.AtEnd;
	ttl.Font = CURF[kind];
	ttl.TextScaled = true;
	ttl.TextXAlignment = Enum.TextXAlignment.Left;
	ttl.TextYAlignment = Enum.TextYAlignment.Center;
	ttl.TextColor3 = TH.Ttl;
	ttl.RichText = true;
	ttl.ZIndex = z + 210;
	ttl.Parent = hdr;
	local tcon = Instance.new("UITextSizeConstraint", ttl);
	tcon.MinTextSize = 14;
	tcon.MaxTextSize = kind == "Popup" and 28 or 22;
	(act:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
		ttl.Size = UDim2.new(1, -(PAD + act.AbsoluteSize.X + PAD + 14), 1, 0);
	end);
	local function closeCard()
		local p = par;
		repeat
			if p:IsA("Frame") and p.Name == "Card" then
				break;
			end;
			p = p.Parent;
		until not p;
		if p then
			local s = ctx(p);
			if s and s.close then
				s.close();
			end;
		end;
	end;
	cls.MouseButton1Click:Connect(function()
		closeCard();
	end);
	local fMenu, fCon, rec;
	local function refreshFonts()
		if not rec then
			return;
		end;
		for _, r in ipairs(rec) do
			local on = r.font == CURF[kind];
			r.set(on);
		end;
	end;
	local function closeFont()
		if fCon then
			fCon:Disconnect();
			fCon = nil;
		end;
		if fMenu and fMenu.Parent then
			fMenu:Destroy();
		end;
		fMenu = nil;
		rec = nil;
		setFontSel(false);
		if kind == "Notify" and onPause then
			onPause(false);
		end;
	end;
	local function openFont()
		if state.closing then
			return;
		end;
		if fMenu and fMenu.Parent then
			closeFont();
			return;
		end;
		if kind == "Notify" and onPause then
			onPause(true);
		end;
		setFontSel(true);
		local m = Instance.new("Frame");
		m.BackgroundColor3 = TH.Bg1;
		m.BackgroundTransparency = 0.06;
		m.BorderSizePixel = 0;
		m.Size = UDim2.new(0, 240, 0, 0);
		m.AutomaticSize = Enum.AutomaticSize.Y;
		m.ZIndex = ov.ZIndex + 10;
		m.Parent = ov;
		local c = Instance.new("UICorner", m);
		c.CornerRadius = UDim.new(0, 18);
		local s = Instance.new("UIStroke", m);
		s.Color = TH.St0;
		s.Thickness = 1;
		s.Transparency = 0.55;
		local p = Instance.new("UIPadding", m);
		p.PaddingTop = UDim.new(0, 8);
		p.PaddingBottom = UDim.new(0, 8);
		p.PaddingLeft = UDim.new(0, 8);
		p.PaddingRight = UDim.new(0, 8);
		local sf = Instance.new("ScrollingFrame");
		sf.BackgroundTransparency = 1;
		sf.BorderSizePixel = 0;
		sf.ScrollBarThickness = 4;
		sf.Size = UDim2.new(1, 0, 0, 250);
		sf.AutomaticCanvasSize = Enum.AutomaticSize.Y;
		sf.CanvasSize = UDim2.new();
		sf.ZIndex = m.ZIndex + 1;
		sf.Parent = m;
		local lay2 = Instance.new("UIListLayout", sf);
		lay2.Padding = UDim.new(0, 6);
		lay2.SortOrder = Enum.SortOrder.LayoutOrder;
		rec = {};
		for _, pair in ipairs(FONTS) do
			local b = mkMenuBtn(sf, pair[1], sf.ZIndex + 1, CURF[kind]);
			local setSel = function(on)
				b:SetAttribute("sel", on and true or false);
				(tw:Create(b, TweenInfo.new(0.1), {
					BackgroundColor3 = on and TH.Ok1 or TH.Btn0,
					BackgroundTransparency = on and 0.06 or 0.08
				})):Play();
			end;
			table.insert(rec, {
				btn = b,
				font = pair[2],
				set = setSel
			});
			b.MouseButton1Click:Connect(function()
				setFontKind(kind, pair[2]);
				applyFontTree(par, pair[2]);
				refreshFonts();
			end);
		end;
		refreshFonts();
		rs.Heartbeat:Wait();
		placeMenu(fbtn, m);
		fMenu = m;
		fCon = rs.Heartbeat:Connect(function()
			if fMenu and fMenu.Parent then
				placeMenu(fbtn, fMenu);
			elseif fCon then
				fCon:Disconnect();
				fCon = nil;
			end;
		end);
		local sc = Instance.new("UIScale", m);
		sc.Scale = 0.96;
		m.BackgroundTransparency = 1;
		(tw:Create(sc, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Scale = 1
		})):Play();
		(tw:Create(m, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.06
		})):Play();
	end;
	fbtn.MouseButton1Click:Connect(function()
		if state.closing then
			return;
		end;
		if fMenu then
			closeFont();
		else
			openFont();
		end;
	end);
	local pMenu, pCon;
	local closePosFn = function()
	end;
	if posBtn then
		local POS = {
			{
				"Top",
				"top"
			},
			{
				"Bottom",
				"bottom"
			},
			{
				"Top Right",
				"topRight"
			},
			{
				"Top Left",
				"topLeft"
			},
			{
				"Bottom Right",
				"bottomRight"
			},
			{
				"Bottom Left",
				"bottomLeft"
			}
		};
		local function closePos()
			if pCon then
				pCon:Disconnect();
				pCon = nil;
			end;
			if pMenu and pMenu.Parent then
				pMenu:Destroy();
			end;
			pMenu = nil;
			setPosSel(false);
			if kind == "Notify" and onPause then
				onPause(false);
			end;
		end;
		local function openPos()
			if state.closing then
				return;
			end;
			if pMenu and pMenu.Parent then
				closePos();
				return;
			end;
			if kind == "Notify" and onPause then
				onPause(true);
			end;
			setPosSel(true);
			local m = Instance.new("Frame");
			m.BackgroundColor3 = TH.Bg1;
			m.BackgroundTransparency = 0.06;
			m.BorderSizePixel = 0;
			m.Size = UDim2.new(0, 210, 0, 0);
			m.AutomaticSize = Enum.AutomaticSize.Y;
			m.ZIndex = ov.ZIndex + 10;
			m.Parent = ov;
			local c = Instance.new("UICorner", m);
			c.CornerRadius = UDim.new(0, 18);
			local s = Instance.new("UIStroke", m);
			s.Color = TH.St0;
			s.Thickness = 1;
			s.Transparency = 0.55;
			local padF = Instance.new("UIPadding", m);
			padF.PaddingTop = UDim.new(0, 8);
			padF.PaddingBottom = UDim.new(0, 8);
			padF.PaddingLeft = UDim.new(0, 8);
			padF.PaddingRight = UDim.new(0, 8);
			local list = Instance.new("UIListLayout", m);
			list.Padding = UDim.new(0, 6);
			list.SortOrder = Enum.SortOrder.LayoutOrder;
			for _, ent in ipairs(POS) do
				local b = mkMenuBtn(m, ent[1], m.ZIndex + 2, CURF[kind]);
				b.MouseButton1Click:Connect(function()
					local p0 = par;
					repeat
						if p0:IsA("Frame") and p0.Name == "Card" then
							break;
						end;
						p0 = p0.Parent;
					until not p0;
					local s0 = ctx(p0);
					if s0.setDock then
						s0.setDock(ent[2], true);
					end;
					closePos();
				end);
			end;
			rs.Heartbeat:Wait();
			placeMenu(posBtn, m);
			pMenu = m;
			pCon = rs.Heartbeat:Connect(function()
				if pMenu and pMenu.Parent then
					placeMenu(posBtn, pMenu);
				elseif pCon then
					pCon:Disconnect();
					pCon = nil;
				end;
			end);
			local sc = Instance.new("UIScale", m);
			sc.Scale = 0.96;
			m.BackgroundTransparency = 1;
			(tw:Create(sc, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Scale = 1
			})):Play();
			(tw:Create(m, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.06
			})):Play();
		end;
		posBtn.MouseButton1Click:Connect(function()
			if state.closing then
				return;
			end;
			if pMenu then
				closePos();
			else
				openPos();
			end;
		end);
		closePosFn = closePos;
	end;
	state.closeMenus = function()
		closeFont();
		closePosFn();
	end;
	return hdr, ttl, act;
end;
local function attachTimer(card, fil, dur)
	local hover = uis.MouseEnabled;
	local ext = false;
	local hov = false;
	local function closeCard()
		local s = ctx(card);
		if s and s.close and (not s.closing) then
			s.close();
		end;
	end;
	if not fil then
		local rem = dur;
		local th;
		local function start()
			if th and coroutine.status(th) ~= "dead" then
				return;
			end;
			th = task.spawn(function()
				local last = os.clock();
				while rem > 0 do
					if ext or hov then
						last = os.clock();
						task.wait(0.05);
					else
						local now = os.clock();
						local dt = now - last;
						rem -= dt;
						last = now;
						task.wait(0.05);
					end;
				end;
				th = nil;
				if not ext and (not hov) then
					closeCard();
				end;
			end);
		end;
		start();
		card.Destroying:Connect(function()
			ext = true;
			rem = 0;
		end);
		if hover then
			card.MouseEnter:Connect(function()
				hov = true;
			end);
			card.MouseLeave:Connect(function()
				hov = false;
			end);
		end;
		return {
			pause = function()
				ext = true;
			end,
			resume = function()
				if not ext then
					return;
				end;
				ext = false;
				start();
			end
		};
	end;
	local frac = 1;
	local tn;
	local function stop()
		if tn then
			tn:Cancel();
			tn = nil;
		end;
	end;
	local function playFrom(f)
		fil.Size = UDim2.new(f, 0, 1, 0);
		stop();
		local d = math.max(0.01, dur * f);
		tn = tw:Create(fil, TweenInfo.new(d, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 1, 0)
		});
		tn.Completed:Connect(function()
			if not ext and (not hov) and fil.Size.X.Scale <= 0.001 then
				closeCard();
			end;
		end);
		tn:Play();
	end;
	local function ref()
		if ext or hov then
			stop();
			frac = fil.Size.X.Scale;
		else
			playFrom(frac);
		end;
	end;
	playFrom(frac);
	if hover then
		card.MouseEnter:Connect(function()
			hov = true;
			ref();
		end);
		card.MouseLeave:Connect(function()
			hov = false;
			ref();
		end);
	end;
	return {
		pause = function()
			ext = true;
			ref();
		end,
		resume = function()
			ext = false;
			ref();
		end
	};
end;
local function calcCellH(w, list, font)
	local h = 34;
	for _, info in ipairs(list) do
		local t = tostring(info.Text or "");
		local iconSpace = 0;
		local raw = info.Image;
		if raw ~= nil then
			if typeof(raw) == "number" then
				raw = "rbxassetid://" .. raw;
			elseif typeof(raw) ~= "string" then
				raw = nil;
			end;
		end;
		if raw and raw ~= "" then
			iconSpace = 28;
		end;
		local avail = math.max(10, w - 24 - iconSpace);
		local sz = ts:GetTextSize(t, 14, font, Vector2.new(avail, math.huge));
		h = math.max(h, math.ceil(sz.Y) + 14);
	end;
	return math.clamp(h, 34, 86);
end;
local function mkBtnArea(cnt, list, owner, z, maxH, font)
	if not list or #list == 0 then
		return;
	end;
	local sf = Instance.new("ScrollingFrame");
	sf.BackgroundTransparency = 1;
	sf.BorderSizePixel = 0;
	sf.ScrollBarThickness = 6;
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y;
	sf.ScrollingEnabled = true;
	sf.CanvasSize = UDim2.new();
	sf.Size = UDim2.new(1, 0, 0, 0);
	sf.ZIndex = z or 10;
	sf.ClipsDescendants = true;
	sf.Parent = cnt;
	local grid = Instance.new("UIGridLayout", sf);
	grid.CellPadding = UDim2.new(0, 10, 0, 10);
	grid.FillDirectionMaxCells = math.min(3, math.max(1, #list == 1 and 1 or math.min(3, (#list))));
	grid.SortOrder = Enum.SortOrder.LayoutOrder;
	local function fitCells()
		local cols = grid.FillDirectionMaxCells;
		if cols == 1 then
			local ch = calcCellH(sf.AbsoluteSize.X, list, font);
			grid.CellSize = UDim2.new(1, 0, 0, ch);
		else
			local w = sf.AbsoluteSize.X;
			local bw = math.max(100, math.floor((w - (cols - 1) * 10) / cols));
			local ch = calcCellH(bw, list, font);
			grid.CellSize = UDim2.new(0, bw, 0, ch);
		end;
	end;
	(sf:GetPropertyChangedSignal("AbsoluteSize")):Connect(fitCells);
	local function fitH()
		local need = grid.AbsoluteContentSize.Y;
		local cap = math.min(430, math.max(44, maxH or math.floor(gui.AbsoluteSize.Y * 0.52)));
		local h = math.min(need, cap);
		sf.Size = UDim2.new(1, 0, 0, h);
		sf.ScrollingEnabled = need > cap;
		sf.ScrollBarThickness = need > cap and 6 or 0;
	end;
	(grid:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(fitH);
	rs.Heartbeat:Wait();
	fitCells();
	fitH();
	local s = ctx(owner);
	s.sel = s.sel or {};
	s.btns = s.btns or {};
	for _, info in ipairs(list) do
		local b = Instance.new("TextButton");
		b.AutoButtonColor = false;
		b.Text = "";
		b.ZIndex = (z or 10) + 1;
		b.BackgroundColor3 = TH.Btn0;
		b.BackgroundTransparency = 0.06;
		b.ClipsDescendants = true;
		b.Parent = sf;
		local cr = Instance.new("UICorner", b);
		cr.CornerRadius = UDim.new(0, 16);
		local st = Instance.new("UIStroke", b);
		st.Color = TH.St0;
		st.Transparency = 0.78;
		st.Thickness = 1;
		local pad = Instance.new("UIPadding", b);
		pad.PaddingTop = UDim.new(0, 10);
		pad.PaddingBottom = UDim.new(0, 10);
		pad.PaddingRight = UDim.new(0, 14);
		pad.PaddingLeft = UDim.new(0, 14);
		local lay = Instance.new("UIListLayout", b);
		lay.FillDirection = Enum.FillDirection.Horizontal;
		lay.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		lay.VerticalAlignment = Enum.VerticalAlignment.Center;
		lay.SortOrder = Enum.SortOrder.LayoutOrder;
		local raw = info.Image;
		if raw ~= nil then
			if typeof(raw) == "number" then
				raw = "rbxassetid://" .. raw;
			elseif typeof(raw) ~= "string" then
				raw = nil;
			end;
		end;
		local hasIcon = raw and raw ~= "" and true or false;
		lay.Padding = UDim.new(0, hasIcon and 10 or 0);
		local ic = Instance.new("ImageLabel");
		ic.BackgroundTransparency = 1;
		ic.Image = raw and raw or "";
		ic.Visible = hasIcon;
		ic.ImageTransparency = hasIcon and 0 or 1;
		ic.ScaleType = Enum.ScaleType.Fit;
		ic.ZIndex = b.ZIndex + 2;
		ic.LayoutOrder = 10;
		ic.Size = hasIcon and UDim2.fromOffset(20, 20) or UDim2.new(0, 0, 0, 0);
		ic.Parent = b;
		local lb = Instance.new("TextLabel");
		lb.BackgroundTransparency = 1;
		lb.TextColor3 = TH.Txt;
		lb.RichText = true;
		lb.TextWrapped = true;
		lb.TextScaled = true;
		lb.Font = font or Enum.Font.Gotham;
		lb.Text = info.Text or "";
		lb.ZIndex = b.ZIndex + 2;
		lb.LayoutOrder = 20;
		lb.TextYAlignment = Enum.TextYAlignment.Center;
		lb.TextXAlignment = hasIcon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center;
		lb.Size = UDim2.new(1, hasIcon and (-28) or 0, 1, 0);
		local tc = Instance.new("UITextSizeConstraint", lb);
		tc.MinTextSize = 12;
		tc.MaxTextSize = 20;
		lb.Parent = b;
		local function setSel(on)
			b:SetAttribute("sel", on and true or false);
			(tw:Create(b, TweenInfo.new(0.1), {
				BackgroundColor3 = on and TH.Ok1 or TH.Btn0,
				BackgroundTransparency = on and 0.05 or 0.06
			})):Play();
		end;
		s.btns[b] = {
			info = info,
			set = setSel
		};
		setSel(false);
		b.MouseEnter:Connect(function()
			if b:GetAttribute("sel") then
				return;
			end;
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.Btn1
			})):Play();
		end);
		b.MouseLeave:Connect(function()
			if b:GetAttribute("sel") then
				return;
			end;
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.Btn0
			})):Play();
		end);
		b.MouseButton1Click:Connect(function()
			if s.multi then
				local i = table.find(s.sel, info);
				if i then
					table.remove(s.sel, i);
					setSel(false);
				else
					table.insert(s.sel, info);
					setSel(true);
				end;
				if s.ok then
					s.ok(#s.sel > 0);
				end;
			else
				if info.Callback then
					local t = s.inp and s.inp.Text or "";
					info.Callback(t);
				end;
				if s.close then
					s.close();
				end;
			end;
		end);
	end;
	return sf;
end;
local function widthForDock(dock, kind)
	if dock == "top" or dock == "bottom" then
		return wW();
	end;
	return kind == "Popup" and math.floor(math.clamp(gui.AbsoluteSize.X * 0.36, 340, 620)) or nW();
end;
local function appear(card, sc, st, sh, tgt, from, cnt)
	setAAll(cnt, 1);
	card.Rotation = from.rot or (-3);
	card.BackgroundTransparency = 1;
	st.Transparency = 1;
	st.Thickness = 1;
	sc.Scale = 0.86;
	if sh then
		sh.ImageTransparency = 1;
	end;
	card.Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset + (from.dx or 0), card.Position.Y.Scale, card.Position.Y.Offset + (from.dy or 0));
	local tA = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);
	local tB = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);
	(tw:Create(card, tA, {
		Size = tgt,
		BackgroundTransparency = 0.65,
		Rotation = 0,
		Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset - (from.dx or 0), card.Position.Y.Scale, card.Position.Y.Offset - (from.dy or 0))
	})):Play();
	(tw:Create(sc, tA, {
		Scale = 1.05
	})):Play();
	task.delay(0.16, function()
		(tw:Create(sc, tB, {
			Scale = 1
		})):Play();
	end);
	(tw:Create(st, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Transparency = 0.55,
		Thickness = 1
	})):Play();
	if sh then
		(tw:Create(sh, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			ImageTransparency = 0.3
		})):Play();
	end;
	stgInAll(cnt, 0.18);
end;
local function disappear(card, sc, st, sh)
	local t1 = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
	local t2 = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In);
	(tw:Create(sc, t1, {
		Scale = 1.02
	})):Play();
	task.delay(0.07, function()
		(tw:Create(sc, t2, {
			Scale = 0.88
		})):Play();
		(tw:Create(card, t2, {
			BackgroundTransparency = 1,
			Rotation = -1.5
		})):Play();
		if st then
			(tw:Create(st, t2, {
				Transparency = 1
			})):Play();
		end;
		if sh then
			(tw:Create(sh, t2, {
				ImageTransparency = 1
			})):Play();
		end;
		task.delay(0.08, function()
			(tw:Create(card, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, 0)
			})):Play();
		end);
	end);
end;
local function mkCard(w, baseZ, kind, onPause)
	local z = baseZ or 100 + tick() % 1 * 1000;
	local card = Instance.new("Frame");
	card.Name = "Card";
	card.LayoutOrder = os.clock() * 1000;
	card.Size = UDim2.new(0, w, 0, 0);
	card.BackgroundColor3 = TH.Bg1;
	card.BackgroundTransparency = 0;
	card.ZIndex = z;
	card.BorderSizePixel = 0;
	card.ClipsDescendants = true;
	local cr = Instance.new("UICorner", card);
	cr.CornerRadius = UDim.new(0, 22);
	local st = Instance.new("UIStroke", card);
	st.Color = TH.St0;
	st.Thickness = 1;
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	st.Transparency = 0.55;
	local sc = Instance.new("UIScale", card);
	sc.Scale = 1;
	local grad = Instance.new("UIGradient", card);
	grad.Rotation = 90;
	grad.Color = ColorSequence.new(TH.Bg2, TH.Bg0);
	local cnt = Instance.new("Frame");
	cnt.Name = "Content";
	cnt.BackgroundTransparency = 1;
	cnt.Size = UDim2.new(1, 0, 0, 0);
	cnt.AutomaticSize = Enum.AutomaticSize.Y;
	cnt.ZIndex = z + 120;
	cnt.Parent = card;
	local pad = Instance.new("UIPadding", cnt);
	pad.PaddingLeft = UDim.new(0, PAD);
	pad.PaddingRight = UDim.new(0, PAD);
	pad.PaddingTop = UDim.new(0, 44 + PAD - 4);
	pad.PaddingBottom = UDim.new(0, PAD + 16);
	local col = Instance.new("UIListLayout", cnt);
	col.Padding = UDim.new(0, 10);
	col.FillDirection = Enum.FillDirection.Vertical;
	col.HorizontalAlignment = Enum.HorizontalAlignment.Left;
	col.SortOrder = Enum.SortOrder.LayoutOrder;
	local ftr = Instance.new("Frame");
	ftr.Name = "Footer";
	ftr.AnchorPoint = Vector2.new(0, 1);
	ftr.Position = UDim2.new(0, 0, 1, 0);
	ftr.Size = UDim2.new(1, 0, 0, 16);
	ftr.BackgroundTransparency = 1;
	ftr.ZIndex = z + 130;
	ftr.Parent = card;
	local trk = Instance.new("Frame");
	trk.Name = "ProgTrack";
	trk.AnchorPoint = Vector2.new(0.5, 0.5);
	trk.Position = UDim2.new(0.5, 0, 0.5, 0);
	trk.Size = UDim2.new(0.86, 0, 0, 3);
	trk.BackgroundTransparency = 0.75;
	trk.BackgroundColor3 = TH.Prog;
	trk.BorderSizePixel = 0;
	trk.ZIndex = z + 140;
	trk.Parent = ftr;
	local c1 = Instance.new("UICorner", trk);
	c1.CornerRadius = UDim.new(0, 999);
	local fil = Instance.new("Frame");
	fil.Name = "ProgFill";
	fil.AnchorPoint = Vector2.new(0, 0.5);
	fil.Position = UDim2.new(0, 0, 0.5, 0);
	fil.Size = UDim2.new(1, 0, 1, 0);
	fil.BackgroundTransparency = 0.08;
	fil.BackgroundColor3 = TH.Prog;
	fil.BorderSizePixel = 0;
	fil.ZIndex = z + 141;
	fil.Parent = trk;
	local c2 = Instance.new("UICorner", fil);
	c2.CornerRadius = UDim.new(0, 999);
	local hdr, ttl, act = mkHdr(card, z, kind, onPause);
	return card, hdr, ttl, act, st, sc, sh, cnt, ftr, trk, fil;
end;
local function openIn(card, par, ftr, trk, st, sc, sh, from, cnt)
	card.Parent = par;
	card.Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, 0);
	card.Visible = true;
	local extra = typeof(trk) == "Instance" and trk.Visible and ftr and ftr.AbsoluteSize.Y or 0;
	local h = cntH(cnt) + extra;
	appear(card, sc, st, sh, UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, h), from, cnt);
end;
local function build(kind, p)
	ensureGui();
	p = typeof(p) == "table" and p or {};
	local def = kind == "Window" and "top" or "bottomRight";
	local dock = mapDock(p.Dock or CURD[kind] or def);
	local from;
	if dock == "top" then
		from = dirFrom("top");
	elseif dock == "bottom" then
		from = dirFrom("bottom");
	elseif dock == "topRight" then
		from = dirFrom("top right");
	elseif dock == "topLeft" then
		from = dirFrom("top left");
	elseif dock == "bottomRight" then
		from = dirFrom("bottom right");
	else
		from = dirFrom("bottom left");
	end;
	local w = widthForDock(dock, kind);
	local baseZ, grp;
	if kind == "Popup" then
		grp = Instance.new("Frame");
		grp.Name = "PopupRoot";
		grp.BackgroundTransparency = 1;
		grp.AnchorPoint = Vector2.new(0.5, 0.5);
		grp.Position = UDim2.fromScale(0.5, 0.5);
		grp.Size = UDim2.fromOffset(w, 0);
		grp.ZIndex = 40000;
		grp.Parent = gui;
		baseZ = grp.ZIndex + 10;
	end;
	local timCtl;
	local card, hdr, ttl, act, st, sc, sh, cnt, ftr, trk, fil = mkCard(w, baseZ, kind, function(paused)
		if timCtl then
			if paused then
				timCtl.pause();
			else
				timCtl.resume();
			end;
		end;
	end);
	ACT[kind][card] = true;
	ttl.Text = p.Title or kind;
	local s = ctx(card);
	s.kind = kind;
	s.cnt = cnt;
	s.ftr = ftr;
	s.trk = trk;
	s.fil = fil;
	s.dock = dock;
	s.multi = false;
	s.sel = {};
	s.btns = nil;
	s.ok = nil;
	s.closing = false;
	s.close = function()
		if s.closing then
			return;
		end;
		s.closing = true;
		if s.closeMenus then
			s.closeMenus();
		end;
		disappear(card, sc, st, sh);
		task.delay(0.36, function()
			if card then
				ST[card] = nil;
				for _, t in pairs(ACT) do
					t[card] = nil;
				end;
				card:Destroy();
			end;
		end);
	end;
	function s.setDock(newDock, persist)
		newDock = mapDock(newDock);
		if s.dock == newDock then
			return;
		end;
		s.dock = newDock;
		if persist then
			CURD[kind] = newDock;
			saveDocks();
		end;
		local tgt = getStack(newDock);
		local newW = widthForDock(newDock, kind);
		local extra = s.trk.Visible and s.ftr.AbsoluteSize.Y or 0;
		local h = cntH(s.cnt) + extra;
		local b = (newDock == "bottom" or newDock == "bottomLeft" or newDock == "bottomRight") and dirFrom("bottom") or dirFrom("top");
		card.Parent = tgt;
		card.Size = UDim2.new(0, card.AbsoluteSize.X, 0, card.AbsoluteSize.Y);
		card.Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset + (b.dx or 0), card.Position.Y.Scale, card.Position.Y.Offset + (b.dy or 0));
		(tw:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, newW, 0, h),
			Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset - (b.dx or 0), card.Position.Y.Scale, card.Position.Y.Offset - (b.dy or 0))
		})):Play();
	end;
	if p.Description and p.Description ~= "" then
		local d = Instance.new("TextLabel");
		d.BackgroundTransparency = 1;
		d.TextColor3 = TH.Txt;
		d.TextXAlignment = Enum.TextXAlignment.Left;
		d.TextYAlignment = Enum.TextYAlignment.Top;
		d.TextWrapped = true;
		d.RichText = true;
		d.Font = CURF[kind];
		d.TextScaled = false;
		d.TextSize = 14;
		d.AutomaticSize = Enum.AutomaticSize.Y;
		d.Size = UDim2.new(1, 0, 0, 0);
		d.ZIndex = card.ZIndex + 121;
		d.Text = p.Description;
		d.Parent = cnt;
	end;
	if p.InputField then
		local inp = Instance.new("TextBox");
		inp.Size = UDim2.new(1, 0, 0, 38);
		inp.ClearTextOnFocus = false;
		inp.TextXAlignment = Enum.TextXAlignment.Left;
		inp.TextYAlignment = Enum.TextYAlignment.Center;
		inp.Font = CURF[kind];
		inp.TextSize = 14;
		inp.TextColor3 = TH.Txt;
		inp.RichText = true;
		inp.BackgroundColor3 = TH.Btn0;
		inp.BackgroundTransparency = 0.06;
		inp.Text = "";
		inp.PlaceholderText = p.Placeholder or "Type here…";
		inp.PlaceholderColor3 = TH.Ph;
		inp.ZIndex = card.ZIndex + 121;
		inp.Parent = cnt;
		local c = Instance.new("UICorner", inp);
		c.CornerRadius = UDim.new(0, 16);
		local st2 = Instance.new("UIStroke", inp);
		st2.Color = TH.St0;
		st2.Transparency = 0.82;
		st2.Thickness = 1;
		s.inp = inp;
		inp.Focused:Connect(function()
			(tw:Create(inp, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.Btn1
			})):Play();
		end);
		inp.FocusLost:Connect(function()
			(tw:Create(inp, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.Btn0
			})):Play();
		end);
	end;
	local btns = p.Buttons or {};
	if #btns > 0 then
		mkBtnArea(cnt, btns, card, card.ZIndex + 122, math.floor(gui.AbsoluteSize.Y * 0.52), CURF[kind]);
	end;
	if #btns > 2 then
		local mBtn, setMSel = mkIcn(act, "M", act.ZIndex + 3, CURF[kind]);
		local okBtn, _ = mkIcn(act, "✓", act.ZIndex + 3, CURF[kind]);
		okBtn.Visible = false;
		local function showOK(on)
			okBtn.Visible = on and true or false;
		end;
		setMSel(false);
		mBtn.MouseButton1Click:Connect(function()
			if s.closing then
				return;
			end;
			s.multi = not s.multi;
			setMSel(s.multi);
			if not s.multi then
				s.sel = {};
				if s.btns then
					for b2, rec in pairs(s.btns) do
						if rec and rec.set then
							rec.set(false);
						end;
					end;
				end;
				showOK(false);
			else
				showOK(#(s.sel or {}) > 0);
			end;
		end);
		okBtn.MouseButton1Click:Connect(function()
			if s.closing then
				return;
			end;
			for _, info in ipairs(s.sel or {}) do
				if info.Callback then
					info.Callback(s.inp and s.inp.Text or "");
				end;
			end;
			if s.close then
				s.close();
			end;
		end);
		s.ok = function(vis)
			showOK(vis);
		end;
	end;
	local dur = typeof(p.Duration) == "number" and p.Duration > 0 and p.Duration or nil;
	local showProg = kind == "Notify" and #btns == 0 and dur ~= nil;
	local shouldTimer = kind == "Notify" and dur ~= nil;
	local parent = kind == "Popup" and grp or getStack(dock);
	trk.Visible = showProg;
	openIn(card, parent, ftr, showProg and trk or nil, st, sc, sh, from, cnt);
	if shouldTimer then
		timCtl = attachTimer(card, showProg and fil or nil, dur);
	end;
	if kind == "Popup" then
		ov.BackgroundTransparency = 1;
		trackPopupCenter(grp, card);
		drag(parent, card.Header);
	end;
	return card;
end;
local function Notify(p)
	return build("Notify", p);
end;
local function Window(p)
	return build("Window", p or {});
end;
local function Popup(p)
	p = p or {};
	p.Dock = p.Dock or CURD.Popup or "top";
	return build("Popup", p);
end;
_G.EnhancedNotifs = {
	Notify = function(p)
		return Notify(p);
	end,
	Window = function(p)
		return Window(p);
	end,
	Popup = function(p)
		return Popup(p);
	end,
	SetFont = function(kind, name)
		for _, pair in ipairs(FONTS) do
			if pair[1] == name then
				setFontKind(kind, pair[2]);
				break;
			end;
		end;
	end
};
return _G.EnhancedNotifs;
