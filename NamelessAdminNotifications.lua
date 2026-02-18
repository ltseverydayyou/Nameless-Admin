_naNotif_env = getgenv and getgenv() or _G or {};
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
local tw, rs, uis, plrs, cg, hs, ts, gs = S("TweenService"), S("RunService"), S("UserInputService"), S("Players"), S("CoreGui"), S("HttpService"), S("TextService"), S("GuiService");
local function pick()
	if gethui then
		return gethui();
	elseif cg and cg:FindFirstChild("RobloxGui") then
		return cg:FindFirstChild("RobloxGui");
	elseif cg then
		return cg;
	else
		local lp = plrs.LocalPlayer;
		if lp and lp:FindFirstChildWhichIsA("PlayerGui") then
			return lp:FindFirstChildWhichIsA("PlayerGui");
		end;
	end;
	return nil;
end;
local function findGui()
	local targets = {
		gethui and pcall(gethui) and gethui() or nil,
		cg:FindFirstChild("RobloxGui"),
		cg,
		plrs.LocalPlayer and plrs.LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
	};
	for _, p in ipairs(targets) do
		if typeof(p) == "Instance" then
			local g = p:FindFirstChild("EnhancedNotif");
			if g then
				return g, p;
			end;
		end;
	end;
end;
local TH = {
	Txt = Color3.fromRGB(250, 250, 250),
	Ttl = Color3.fromRGB(255, 255, 255),
	Mut = Color3.fromRGB(150, 150, 150),
	Bg = Color3.fromRGB(12, 12, 12),
	Bg2 = Color3.fromRGB(18, 18, 18),
	Border = Color3.fromRGB(255, 255, 255),
	Btn = Color3.fromRGB(25, 25, 25),
	BtnHover = Color3.fromRGB(35, 35, 35),
	BtnActive = Color3.fromRGB(15, 15, 15),
	BtnSel = Color3.fromRGB(255, 255, 255),
	Close = Color3.fromRGB(220, 55, 55),
	CloseHover = Color3.fromRGB(255, 70, 70),
	Progress = Color3.fromRGB(255, 255, 255),
	Shadow = Color3.fromRGB(0, 0, 0)
};
local PAD, GAP = 18, 16;
local FPATH = "enhanced_notif_fonts.json";
local DPATH = "enhanced_notif_docks.json";
local FONTS = {};
local walkDesc;
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
if _naNotif_env.EnhancedNotifs and ex then
	return _naNotif_env.EnhancedNotifs;
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
ov.Active = false;
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
local function syncOverlayActive()
	if not ov then
		return;
	end;
	local hasPopup = false;
	for card in pairs(ACT.Popup) do
		if card and card.Parent then
			hasPopup = true;
			break;
		end;
	end;
	ov.Active = hasPopup;
end;
local CURF = {
	Notify = Enum.Font.GothamBold,
	Window = Enum.Font.GothamBold,
	Popup = Enum.Font.GothamBold
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
	walkDesc(r, function(d)
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			d.Font = f;
		end;
	end, 160);
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

local function inz()
	local tl = Vector2.new(0, 0);
	local br = Vector2.new(0, 0);
	if gs and gs.GetSafeZoneOffsets then
		local ok, a, b = pcall(gs.GetSafeZoneOffsets, gs);
		if ok and typeof(a) == "Vector2" and typeof(b) == "Vector2" then
			tl = a;
			br = b;
		end;
	elseif gs and gs.GetGuiInset then
		local ok, v = pcall(gs.GetGuiInset, gs);
		if ok and typeof(v) == "Vector2" then
			tl = v;
		end;
	end;
	return tl, br;
end;

local isMobile = uis.TouchEnabled and (not uis.KeyboardEnabled);

local function mobScale()
	if not isMobile then
		return 1;
	end;
	local x = gui.AbsoluteSize.X;
	local y = gui.AbsoluteSize.Y;
	local s = math.min(x / 900, y / 650);
	return math.clamp(s, 0.72, 0.9);
end;

local function nW()
	if not isMobile then
		return math.floor(math.clamp(gui.AbsoluteSize.X * 0.28, 320, 400));
	end;
	return math.floor(math.clamp(gui.AbsoluteSize.X * 0.78, 280, 380));
end;

local function wW()
	if not isMobile then
		return math.floor(math.clamp(gui.AbsoluteSize.X * 0.38, 360, 600));
	end;
	return math.floor(math.clamp(gui.AbsoluteSize.X * 0.82, 320, 480));
end;
local ctx;
local stacks = {};
local function mkStack(key)
	local tl, br = inz();
	local off = isMobile and 16 or 24;
	local f = Instance.new("Frame");
	f.Name = "Stack_" .. key;
	f.BackgroundTransparency = 1;
	f.Parent = gui;
	local l = Instance.new("UIListLayout", f);
	l.Padding = UDim.new(0, GAP);
	l.SortOrder = Enum.SortOrder.LayoutOrder;
	if key == "bottomRight" then
		f.AnchorPoint = Vector2.new(1, 1);
		f.Position = UDim2.new(1, -off - br.X, 1, -off - br.Y);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Right;
		l.VerticalAlignment = Enum.VerticalAlignment.Bottom;
	elseif key == "bottomLeft" then
		f.AnchorPoint = Vector2.new(0, 1);
		f.Position = UDim2.new(0, off + tl.X, 1, -off - br.Y);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Left;
		l.VerticalAlignment = Enum.VerticalAlignment.Bottom;
	elseif key == "topRight" then
		f.AnchorPoint = Vector2.new(1, 0);
		f.Position = UDim2.new(1, -off - br.X, 0, off + tl.Y);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Right;
		l.VerticalAlignment = Enum.VerticalAlignment.Top;
	elseif key == "topLeft" then
		f.AnchorPoint = Vector2.new(0, 0);
		f.Position = UDim2.new(0, off + tl.X, 0, off + tl.Y);
		f.Size = UDim2.new(0, nW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Left;
		l.VerticalAlignment = Enum.VerticalAlignment.Top;
	elseif key == "top" then
		f.AnchorPoint = Vector2.new(0.5, 0);
		f.Position = UDim2.new(0.5, 0, 0, off + tl.Y);
		f.Size = UDim2.new(0, wW(), 1, 0);
		l.FillDirection = Enum.FillDirection.Vertical;
		l.HorizontalAlignment = Enum.HorizontalAlignment.Center;
		l.VerticalAlignment = Enum.VerticalAlignment.Top;
	elseif key == "bottom" then
		f.AnchorPoint = Vector2.new(0.5, 1);
		f.Position = UDim2.new(0.5, 0, 1, -off - br.Y);
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
local gSzCon, gDeadCon;
local function onGuiSize()
	for k, f in pairs(stacks) do
		if f and f.Parent then
			f.Size = (k == "top" or k == "bottom") and UDim2.new(0, wW(), 1, 0) or UDim2.new(0, nW(), 1, 0);
		end;
	end;

	if isMobile and type(ctx) == "function" then
		local bs = mobScale();
		for _, t in pairs(ACT) do
			for card in pairs(t) do
				if card and card.Parent then
					local s = ctx(card);
					if s and s.sc then
						s.baseScale = bs;
						s.sc.Scale = bs;
					end;
				end;
			end;
		end;
	end;
end;
local function bindGui()
	if gSzCon and gSzCon.Connected then
		gSzCon:Disconnect();
	end;
	if gDeadCon and gDeadCon.Connected then
		gDeadCon:Disconnect();
	end;
	gSzCon = nil;
	gDeadCon = nil;
	if not gui then
		return;
	end;
	gSzCon = (gui:GetPropertyChangedSignal("AbsoluteSize")):Connect(onGuiSize);
	gDeadCon = gui.Destroying:Connect(function()
		gui = nil;
		stacks = {};
	end);
end;
bindGui();
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
		ov.Active = false;
		ov.Parent = gui;
		stacks = {};
	end;
	syncOverlayActive();
	bindGui();
end;
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
	if not c then
		return 0
	end
	local lay = c:FindFirstChildOfClass("UIListLayout")
	local pad = c:FindFirstChildOfClass("UIPadding")
	local top = pad and pad.PaddingTop.Offset or 0
	local bot = pad and pad.PaddingBottom.Offset or 0
	local hh = (lay and lay.AbsoluteContentSize.Y or 0) + top + bot
	if c:IsA("ScrollingFrame") then
		return math.max(0, hh)
	end
	local h = c.AbsoluteSize.Y
	if h and h > 0 then
		return h
	end
	return math.max(0, hh)
end
local ST = setmetatable({}, {
	__mode = "k"
});
ctx = function(x)
	local s = ST[x];
	if not s then
		s = {
			connections = setmetatable({}, { __mode = "k" }),
			tweens = setmetatable({}, { __mode = "k" })
		};
		ST[x] = s;
	end;
	return s;
end;
local function csc(o)
	local s = ctx(o);
	local v = (s and s.baseScale) or (s and s.sc and s.sc.Scale) or 1;
	if v <= 0 then
		v = 1;
	end;
	return v;
end;
local function addConnection(obj, conn)
	if not (obj and conn) then
		return conn;
	end;
	local s = ctx(obj);
	s.connections[conn] = true;
	return conn;
end;
local function addTween(obj, tween)
	if not (obj and tween) then
		return tween;
	end;
	local s = ctx(obj);
	s.tweens[tween] = true;
	local doneConn;
	doneConn = tween.Completed:Connect(function()
		local st = ST[obj];
		if st then
			if st.tweens then st.tweens[tween] = nil; end;
			if st.connections and doneConn then st.connections[doneConn] = nil; end;
		end;
		if doneConn and doneConn.Connected then
			doneConn:Disconnect();
		end;
		doneConn = nil;
	end);
	if doneConn then
		s.connections[doneConn] = true;
	end;
	return tween;
end;
local function clrSt(s)
	if not s then
		return;
	end;
	if s.connections then
		for conn in pairs(s.connections) do
			if conn and conn.Connected then
				conn:Disconnect();
			end;
		end;
		s.connections = setmetatable({}, { __mode = "k" });
	end;
	if s.tweens then
		for tween in pairs(s.tweens) do
			if tween then
				tween:Cancel();
			end;
		end;
		s.tweens = setmetatable({}, { __mode = "k" });
	end;
end;
local function cleanup(obj)
	local s = ST[obj];
	if s then
		clrSt(s);
	end;
	if type(walkDesc) == "function" and typeof(obj) == "Instance" then
		walkDesc(obj, function(d)
			local sd = ST[d];
			if sd then
				clrSt(sd);
				ST[d] = nil;
			end;
		end);
	end;
	ST[obj] = nil;
end;
walkDesc = function(root, fn, ye)
	if not (root and type(fn) == "function") then
		return;
	end;
	local q = {};
	local ch0 = root:GetChildren();
	for i = #ch0, 1, -1 do
		q[#q + 1] = ch0[i];
	end;
	local budget = tonumber(ye) or 0;
	local step = 0;
	while #q > 0 do
		local i = #q;
		local inst = q[i];
		q[i] = nil;
		if inst then
			fn(inst);
			local ch = inst:GetChildren();
			for j = #ch, 1, -1 do
				q[#q + 1] = ch[j];
			end;
		end;
		if budget > 0 then
			step += 1;
			if step >= budget then
				step = 0;
				task.wait();
			end;
		end;
	end;
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
	local c1 = (card:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
		ref();
	end);
	addConnection(card, c1);
	local cam = workspace.CurrentCamera;
	if cam then
		local c2 = (cam:GetPropertyChangedSignal("ViewportSize")):Connect(function()
			ref();
		end);
		addConnection(card, c2);
	end;
end;
local function mkIcn(par, txt, z, font, stl)
	local btnSize = isMobile and 40 or 34;
	local b = Instance.new("TextButton");
	b.AutoButtonColor = false;
	b.Text = "";
	b.BackgroundColor3 = TH.Btn;
	b.BackgroundTransparency = 1;
	b.Size = UDim2.fromOffset(btnSize, btnSize);
	b.ZIndex = z;
	b.ClipsDescendants = true;
	b.Parent = par;
	local cr = Instance.new("UICorner", b);
	cr.CornerRadius = UDim.new(0, 6);
	local st = Instance.new("UIStroke", b);
	st.Color = TH.Border;
	st.Transparency = 0.92;
	st.Thickness = 1;
	local lb = Instance.new("TextLabel");
	lb.BackgroundTransparency = 1;
	lb.Size = UDim2.fromScale(1, 1);
	lb.ZIndex = z + 1;
	lb.Font = font or Enum.Font.GothamBold;
	lb.Text = txt or "";
	lb.TextScaled = true;
	lb.TextColor3 = TH.Txt;
	lb.Parent = b;
	local cst = Instance.new("UITextSizeConstraint", lb);
	cst.MinTextSize = isMobile and 14 or 12;
	cst.MaxTextSize = isMobile and 20 or 18;
	b:SetAttribute("_stl", stl or "");
	b:SetAttribute("sel", false);
	b:SetAttribute("hov", false);
	local function updateColors()
		local s = b:GetAttribute("sel");
		local t = b:GetAttribute("_stl") or "";
		local h = b:GetAttribute("hov");
		if t == "bad" then
			local targetBg = h and TH.CloseHover or TH.Close;
			local targetTrans = (h or s) and 0 or 1;
			local targetBorder = h and 0.85 or 0.92;
			(tw:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetBg,
				BackgroundTransparency = targetTrans
			})):Play();
			(tw:Create(st, TweenInfo.new(0.12), {
				Transparency = targetBorder
			})):Play();
		else
			local targetBg = s and TH.BtnSel or (h and TH.BtnHover or TH.Btn);
			local targetTrans = s and 0 or (h and 0 or 1);
			local targetTxt = s and TH.Bg or TH.Txt;
			local targetBorder = h and 0.85 or 0.92;
			(tw:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetBg,
				BackgroundTransparency = targetTrans
			})):Play();
			(tw:Create(lb, TweenInfo.new(0.12), {
				TextColor3 = targetTxt
			})):Play();
			(tw:Create(st, TweenInfo.new(0.12), {
				Transparency = targetBorder
			})):Play();
		end;
	end;
	local c1 = b.MouseEnter:Connect(function()
		b:SetAttribute("hov", true);
		updateColors();
	end);
	local c2 = b.MouseLeave:Connect(function()
		b:SetAttribute("hov", false);
		updateColors();
	end);
	local c3 = b.MouseButton1Down:Connect(function()
		(tw:Create(b, TweenInfo.new(0.08), {
			BackgroundColor3 = b:GetAttribute("_stl") == "bad" and TH.Close or TH.BtnActive
		})):Play();
	end);
	local c4 = b.MouseButton1Up:Connect(function()
		updateColors();
	end);
	addConnection(b, c1);
	addConnection(b, c2);
	addConnection(b, c3);
	addConnection(b, c4);
	local function setSel(on)
		b:SetAttribute("sel", on);
		updateColors();
	end;
	return b, setSel;
end;
local function mkMenuBtn(par, txt, z, font)
	local b = Instance.new("TextButton");
	b.AutoButtonColor = false;
	b.Text = txt or "";
	b.TextScaled = true;
	b.TextWrapped = true;
	b.Font = font or Enum.Font.GothamBold;
	b.TextColor3 = TH.Txt;
	b.RichText = true;
	b.BackgroundColor3 = TH.Btn;
	b.BackgroundTransparency = 1;
	b.Size = UDim2.new(1, 0, 0, isMobile and 44 or 36);
	b.ZIndex = z;
	b.ClipsDescendants = true;
	local c = Instance.new("UICorner", b);
	c.CornerRadius = UDim.new(0, 6);
	local st = Instance.new("UIStroke", b);
	st.Color = TH.Border;
	st.Transparency = 0.92;
	st.Thickness = 1;
	local tsz = Instance.new("UITextSizeConstraint", b);
	tsz.MinTextSize = isMobile and 14 or 12;
	tsz.MaxTextSize = isMobile and 16 or 15;
	b.Parent = par;
	local c1 = b.MouseEnter:Connect(function()
		(tw:Create(b, TweenInfo.new(0.12), {
			BackgroundTransparency = 0
		})):Play();
		(tw:Create(b, TweenInfo.new(0.12), {
			BackgroundColor3 = TH.BtnHover
		})):Play();
		(tw:Create(st, TweenInfo.new(0.12), {
			Transparency = 0.85
		})):Play();
	end);
	local c2 = b.MouseLeave:Connect(function()
		if not b:GetAttribute("sel") then
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundTransparency = 1
			})):Play();
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.Btn
			})):Play();
			(tw:Create(st, TweenInfo.new(0.12), {
				Transparency = 0.92
			})):Play();
		end;
	end);
	addConnection(b, c1);
	addConnection(b, c2);
	return b;
end;
local function placeMenu(btn, menu)
	local aw, ah = gui.AbsoluteSize.X, gui.AbsoluteSize.Y;
	local fa = btn.AbsolutePosition;
	local fs = btn.AbsoluteSize;
	local ms = menu.AbsoluteSize;
	local mw, mh = math.max(ms.X, 200), math.max(ms.Y, 90);
	local left = fa.X + fs.X + 10 + mw > aw;
	local x = left and fa.X - 10 - mw or fa.X + fs.X + 10;
	local y = math.clamp(fa.Y - 10, 10, ah - mh - 10);
	menu.Position = UDim2.fromOffset(x, y);
	menu.Size = UDim2.new(0, mw, 0, mh);
end;
local function mkHdr(par, z, kind, onPause)
	local state = ctx(par);
	local hdrHeight = isMobile and 56 or 52;
	local hdr = Instance.new("Frame");
	hdr.Name = "Header";
	hdr.BackgroundTransparency = 1;
	hdr.Active = kind == "Popup";
	hdr.Size = UDim2.new(1, 0, 0, hdrHeight);
	hdr.ZIndex = z + 200;
	hdr.Parent = par;
	local top = Instance.new("Frame");
	top.Name = "TopLine";
	top.BorderSizePixel = 0;
	top.BackgroundColor3 = TH.Border;
	top.BackgroundTransparency = 0.9;
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
	lay.Padding = UDim.new(0, isMobile and 10 or 8);
	local posBtn, setPosSel;
	if kind ~= "Popup" then
		posBtn, setPosSel = mkIcn(act, "≡", act.ZIndex + 1, CURF[kind]);
	end;
	local fbtn, setFontSel = mkIcn(act, "Aa", act.ZIndex + 1, CURF[kind]);
	local cls, _ = mkIcn(act, "×", act.ZIndex + 1, CURF[kind], "bad");
	lay.SortOrder = Enum.SortOrder.LayoutOrder;
	
	if posBtn then
		posBtn.LayoutOrder = 40;
	end;
	fbtn.LayoutOrder = 30;
	cls.LayoutOrder = 50;
	local dot = Instance.new("Frame");
	dot.Name = "Dot";
	dot.BackgroundColor3 = TH.Border;
	dot.BackgroundTransparency = 0.1;
	dot.BorderSizePixel = 0;
	dot.Size = UDim2.fromOffset(4, 4);
	dot.Position = UDim2.new(0, PAD, 0.5, -2);
	dot.ZIndex = z + 210;
	dot.Parent = hdr;
	local dc = Instance.new("UICorner", dot);
	dc.CornerRadius = UDim.new(1, 0);
	local cnt = Instance.new("TextLabel");
	cnt.Name = "Count";
	cnt.AnchorPoint = Vector2.new(0, 0.5);
	cnt.Position = UDim2.new(0, PAD, 0.5, 0);
	cnt.Size = UDim2.fromOffset(isMobile and 24 or 20, isMobile and 22 or 20);
	cnt.BackgroundTransparency = 1;
	cnt.Font = CURF[kind];
	cnt.TextScaled = true;
	cnt.TextXAlignment = Enum.TextXAlignment.Left;
	cnt.TextYAlignment = Enum.TextYAlignment.Center;
	cnt.TextColor3 = TH.Ttl;
	cnt.RichText = false;
	cnt.Text = "1x";
	cnt.ZIndex = z + 210;
	cnt.Visible = false;
	cnt.Parent = hdr;
	local ccon = Instance.new("UITextSizeConstraint", cnt);
	ccon.MinTextSize = isMobile and 13 or 11;
	ccon.MaxTextSize = isMobile and 18 or 16;
	local ttl = Instance.new("TextLabel");
	ttl.Name = "Title";
	ttl.AnchorPoint = Vector2.new(0, 0.5);
	ttl.Position = UDim2.new(0, PAD + 12, 0.5, 0);
	ttl.Size = UDim2.new(1, -(PAD + act.AbsoluteSize.X + PAD + 12), 1, 0);
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
	tcon.MinTextSize = isMobile and 16 or 14;
	tcon.MaxTextSize = kind == "Popup" and (isMobile and 22 or 20) or (isMobile and 18 or 16);
	local function countW()
		local tx = cnt.Text ~= "" and cnt.Text or "1x";
		local sz = ts:GetTextSize(tx, isMobile and 18 or 16, CURF[kind], Vector2.new(200, 24));
		return math.max(isMobile and 24 or 20, sz.X + (isMobile and 4 or 2));
	end;
	local function refTitle()
		local sca = csc(par);
		local ax = act.AbsoluteSize.X / sca;
		if state.stackCount and state.stackCount > 1 then
			local cw = countW() / sca;
			dot.Visible = false;
			cnt.Visible = true;
			cnt.Size = UDim2.fromOffset(math.max(1, math.floor(cw)), isMobile and 22 or 20);
			ttl.Position = UDim2.new(0, PAD + cw + 8, 0.5, 0);
			ttl.Size = UDim2.new(1, -(PAD + ax + PAD + cw + 8), 1, 0);
		else
			dot.Visible = true;
			cnt.Visible = false;
			ttl.Position = UDim2.new(0, PAD + 12, 0.5, 0);
			ttl.Size = UDim2.new(1, -(PAD + ax + PAD + 12), 1, 0);
		end;
	end;

	refTitle();

	local c1 = act:GetPropertyChangedSignal("AbsoluteSize"):Connect(refTitle);
	local c2 = act.ChildAdded:Connect(function(ch)
		refTitle();
		local c3 = ch:GetPropertyChangedSignal("Visible"):Connect(refTitle);
		addConnection(ch, c3);
	end);
	local c4 = act.ChildRemoved:Connect(refTitle);

	addConnection(act, c1);
	addConnection(act, c2);
	addConnection(act, c4);

	state.stackCount = 1;
	state.setStackCount = function(n)
		local v = math.max(1, math.floor(tonumber(n) or 1));
		state.stackCount = v;
		cnt.Text = tostring(v) .. "x";
		refTitle();
	end;
	state.refTitle = refTitle;
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
	local c2 = cls.MouseButton1Click:Connect(function()
		closeCard();
	end);
	addConnection(cls, c2);
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
			local sp = ST[par];
			if sp and sp.connections then
				sp.connections[fCon] = nil;
			end;
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
		m.BackgroundColor3 = TH.Bg;
		m.BackgroundTransparency = 0.05;
		m.BorderSizePixel = 0;
		m.Size = UDim2.new(0, isMobile and 260 or 240, 0, 0);
		m.AutomaticSize = Enum.AutomaticSize.Y;
		m.ZIndex = ov.ZIndex + 10;
		m.Parent = ov;
		local c = Instance.new("UICorner", m);
		c.CornerRadius = UDim.new(0, 10);
		local s = Instance.new("UIStroke", m);
		s.Color = TH.Border;
		s.Thickness = 1;
		s.Transparency = 0.8;
		local p = Instance.new("UIPadding", m);
		p.PaddingTop = UDim.new(0, 10);
		p.PaddingBottom = UDim.new(0, 10);
		p.PaddingLeft = UDim.new(0, 10);
		p.PaddingRight = UDim.new(0, 10);
		local sf = Instance.new("ScrollingFrame");
		sf.BackgroundTransparency = 1;
		sf.BorderSizePixel = 0;
		sf.ScrollBarThickness = 4;
		sf.Size = UDim2.new(1, 0, 0, isMobile and 300 or 250);
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
				b:SetAttribute("sel", on);
				if on then
					(tw:Create(b, TweenInfo.new(0.12), {
						BackgroundColor3 = TH.BtnSel,
						BackgroundTransparency = 0
					})):Play();
					(tw:Create(b, TweenInfo.new(0.12), {
						TextColor3 = TH.Bg
					})):Play();
				else
					(tw:Create(b, TweenInfo.new(0.12), {
						BackgroundColor3 = TH.Btn,
						BackgroundTransparency = 1
					})):Play();
					(tw:Create(b, TweenInfo.new(0.12), {
						TextColor3 = TH.Txt
					})):Play();
				end;
			end;
			table.insert(rec, {
				btn = b,
				font = pair[2],
				set = setSel
			});
			local c3 = b.MouseButton1Click:Connect(function()
				setFontKind(kind, pair[2]);
				applyFontTree(par, pair[2]);
				refreshFonts();
				refTitle();
			end);
			addConnection(b, c3);
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
				local sp = ST[par];
				if sp and sp.connections then
					sp.connections[fCon] = nil;
				end;
				fCon = nil;
			end;
		end);
		addConnection(par, fCon);
		local sc = Instance.new("UIScale", m);
		sc.Scale = 0.92;
		m.BackgroundTransparency = 1;
		local t1 = tw:Create(sc, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1
		});
		local t2 = tw:Create(m, TweenInfo.new(0.15), {
			BackgroundTransparency = 0.05
		});
		t1:Play();
		t2:Play();
		addTween(m, t1);
		addTween(m, t2);
	end;
	local c4 = fbtn.MouseButton1Click:Connect(function()
		if state.closing then
			return;
		end;
		if fMenu then
			closeFont();
		else
			openFont();
		end;
	end);
	addConnection(fbtn, c4);
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
				local sp = ST[par];
				if sp and sp.connections then
					sp.connections[pCon] = nil;
				end;
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
			m.BackgroundColor3 = TH.Bg;
			m.BackgroundTransparency = 0.05;
			m.BorderSizePixel = 0;
			m.Size = UDim2.new(0, isMobile and 230 or 210, 0, 0);
			m.AutomaticSize = Enum.AutomaticSize.Y;
			m.ZIndex = ov.ZIndex + 10;
			m.Parent = ov;
			local c = Instance.new("UICorner", m);
			c.CornerRadius = UDim.new(0, 10);
			local s = Instance.new("UIStroke", m);
			s.Color = TH.Border;
			s.Thickness = 1;
			s.Transparency = 0.8;
			local padF = Instance.new("UIPadding", m);
			padF.PaddingTop = UDim.new(0, 10);
			padF.PaddingBottom = UDim.new(0, 10);
			padF.PaddingLeft = UDim.new(0, 10);
			padF.PaddingRight = UDim.new(0, 10);
			local list = Instance.new("UIListLayout", m);
			list.Padding = UDim.new(0, 6);
			list.SortOrder = Enum.SortOrder.LayoutOrder;
			for _, ent in ipairs(POS) do
				local b = mkMenuBtn(m, ent[1], m.ZIndex + 2, CURF[kind]);
				local c5 = b.MouseButton1Click:Connect(function()
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
				addConnection(b, c5);
			end;
			rs.Heartbeat:Wait();
			placeMenu(posBtn, m);
			pMenu = m;
			pCon = rs.Heartbeat:Connect(function()
				if pMenu and pMenu.Parent then
					placeMenu(posBtn, pMenu);
				elseif pCon then
					pCon:Disconnect();
					local sp = ST[par];
					if sp and sp.connections then
						sp.connections[pCon] = nil;
					end;
					pCon = nil;
				end;
			end);
			addConnection(par, pCon);
			local sc = Instance.new("UIScale", m);
			sc.Scale = 0.92;
			m.BackgroundTransparency = 1;
			local t1 = tw:Create(sc, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1
			});
			local t2 = tw:Create(m, TweenInfo.new(0.15), {
				BackgroundTransparency = 0.05
			});
			t1:Play();
			t2:Play();
			addTween(m, t1);
			addTween(m, t2);
		end;
		local c6 = posBtn.MouseButton1Click:Connect(function()
			if state.closing then
				return;
			end;
			if pMenu then
				closePos();
			else
				openPos();
			end;
		end);
		addConnection(posBtn, c6);
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
	local s = ctx(card);
	local function closeCard()
		if s and s.close and (not s.closing) then
			s.close();
		end;
	end;
	if not fil then
		local runDur = dur;
		local rem = runDur;
		local th;
		local function start()
			if th and coroutine.status(th) ~= "dead" then
				return;
			end;
			th = task.spawn(function()
				local last = os.clock();
				while rem > 0 do
					if s.closing then
						break;
					end;
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
				if not ext and (not hov) and (not s.closing) then
					closeCard();
				end;
			end);
		end;
		start();
		local c1 = card.Destroying:Connect(function()
			ext = true;
			rem = 0;
		end);
		addConnection(card, c1);
		if hover then
			local c2 = card.MouseEnter:Connect(function()
				hov = true;
			end);
			local c3 = card.MouseLeave:Connect(function()
				hov = false;
			end);
			addConnection(card, c2);
			addConnection(card, c3);
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
			end,
			reset = function(newDur)
				if typeof(newDur) == "number" and newDur > 0 then
					runDur = newDur;
				end;
				rem = runDur;
				if not ext and (not hov) then
					start();
				end;
			end
		};
	end;
	local frac = 1;
	local runDur = dur;
	local tn;
	local function stop()
		if tn then
			tn:Cancel();
			tn = nil;
		end;
	end;
	local function playFrom(f)
		if s.closing then
			stop();
			return;
		end;
		fil.Size = UDim2.new(f, 0, 1, 0);
		stop();
		local d = math.max(0.01, runDur * f);
		tn = tw:Create(fil, TweenInfo.new(d, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 1, 0)
		});
		local c = tn.Completed:Connect(function()
			if not ext and (not hov) and fil.Size.X.Scale <= 0.001 and (not s.closing) then
				closeCard();
			end;
		end);
		addConnection(fil, c);
		tn:Play();
		addTween(fil, tn);
	end;
	local function ref()
		if s.closing then
			stop();
			return;
		end;
		if ext or hov then
			stop();
			frac = fil.Size.X.Scale;
		else
			playFrom(frac);
		end;
	end;
	playFrom(frac);
	if hover then
		local c4 = card.MouseEnter:Connect(function()
			hov = true;
			ref();
		end);
		local c5 = card.MouseLeave:Connect(function()
			hov = false;
			ref();
		end);
		addConnection(card, c4);
		addConnection(card, c5);
	end;
	return {
		pause = function()
			ext = true;
			ref();
		end,
		resume = function()
			ext = false;
			ref();
		end,
		reset = function(newDur)
			if typeof(newDur) == "number" and newDur > 0 then
				runDur = newDur;
			end;
			frac = 1;
			fil.Size = UDim2.new(1, 0, 1, 0);
			if ext or hov then
				stop();
			else
				playFrom(1);
			end;
		end
	};
end;
local function calcCellH(w, list, font)
	local h = isMobile and 48 or 42;
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
			iconSpace = isMobile and 36 or 32;
		end;
		local avail = math.max(10, w - 28 - iconSpace);
		local sz = ts:GetTextSize(t, isMobile and 15 or 14, font, Vector2.new(avail, math.huge));
		h = math.max(h, math.ceil(sz.Y) + (isMobile and 20 or 18));
	end;
	return math.clamp(h, isMobile and 48 or 42, isMobile and 140 or 110);
end;
local function mkBtnArea(cnt, list, owner, z, maxH, font)
	if not list or #list == 0 then
		return;
	end;
	local sf = Instance.new("ScrollingFrame")
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0
	sf.Active = (ctx(owner).kind == "Popup")
	sf.ScrollingEnabled = (ctx(owner).kind == "Popup")
	sf.ScrollBarThickness = (ctx(owner).kind == "Popup") and (isMobile and 8 or 6) or 0
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.CanvasSize = UDim2.new()
	sf.Size = UDim2.new(1, 0, 0, 0)
	sf.ZIndex = z or 10
	sf.ClipsDescendants = true
	sf.Parent = cnt
	local grid = Instance.new("UIGridLayout", sf);
	grid.CellPadding = UDim2.new(0, isMobile and 14 or 12, 0, isMobile and 14 or 12);
	grid.FillDirectionMaxCells = 1;
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center;
	grid.SortOrder = Enum.SortOrder.LayoutOrder;
	local function scv()
		return csc(owner);
	end;
	local function fitCells()
		local sca = scv();
		local w = sf.AbsoluteSize.X / sca;
		if w <= 0 then
			return;
		end;

		local gap = isMobile and 14 or 12;

		local cols;
		if isMobile then
			cols = math.min(3, #list);
		else
			local minCell = 140;
			cols = math.floor((w + gap) / (minCell + gap));
			cols = math.clamp(cols, 1, 3);
			cols = math.min(cols, #list);
		end;

		grid.FillDirectionMaxCells = cols;

		if cols <= 1 then
			local ch = calcCellH(w, list, font);
			grid.CellSize = UDim2.new(1, 0, 0, ch);
		else
			local bw = math.floor((w - (cols - 1) * gap) / cols);
			if (not isMobile) and bw < 80 then
				cols = math.max(1, cols - 1);
				grid.FillDirectionMaxCells = cols;
				if cols <= 1 then
					local ch = calcCellH(w, list, font);
					grid.CellSize = UDim2.new(1, 0, 0, ch);
					return;
				end;
				bw = math.floor((w - (cols - 1) * gap) / cols);
			end;

			local ch = calcCellH(bw, list, font);
			grid.CellSize = UDim2.new(0, bw, 0, ch);
		end;
	end;
	local c1 = (sf:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
		fitCells();
	end);
	addConnection(sf, c1);
	local function fitH()
		local sca = scv();

		local need = (grid.AbsoluteContentSize.Y + (isMobile and 10 or 8)) / sca;
		local cap = math.min(430, math.max(44, maxH or math.floor(gui.AbsoluteSize.Y * 0.52))) / sca;
		local h = math.min(need, cap);

		sf.Size = UDim2.new(1, 0, 0, h);
		sf.ScrollingEnabled = need > cap;
		sf.ScrollBarThickness = need > cap and (isMobile and 8 or 6) or 0;

		task.defer(function()
			local so = ctx(owner);
			if not (owner and owner.Parent) or not (so and so.cnt) or so.closing then
				return;
			end;

			local sca2 = csc(owner);
			local hdr = owner:FindFirstChild("Header");
			local hh = (hdr and hdr.AbsoluteSize.Y) or (isMobile and 56 or 52);

			local extra = (so.trk and so.trk.Visible and so.ftr and so.ftr.AbsoluteSize.Y) or 0;
			local nh = (hh + cntH(so.cnt) + extra) / sca2;

			if nh > 2 then
				local tw0 = tw:Create(owner, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Size = UDim2.new(owner.Size.X.Scale, owner.Size.X.Offset, 0, nh)
				});
				tw0:Play();
				addTween(owner, tw0);
			end;
		end);
	end;
	local c2 = (grid:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
		fitH();
	end);
	addConnection(grid, c2);
	task.defer(function()
		fitCells();
		fitH();
	end);
	task.defer(function()
		local so = ctx(owner);
		if so and so.sc and so.sc.GetPropertyChangedSignal then
			local c = so.sc:GetPropertyChangedSignal("Scale"):Connect(function()
				task.defer(fitCells);
				task.defer(fitH);
			end);
			addConnection(owner, c);
		end;
	end);
	local s = ctx(owner);
	s.sel = s.sel or {};
	s.btns = s.btns or {};
	for _, info in ipairs(list) do
		local b = Instance.new("TextButton");
		b.AutoButtonColor = false;
		b.Text = "";
		b.ZIndex = (z or 10) + 1;
		b.BackgroundColor3 = TH.Btn;
		b.BackgroundTransparency = 1;
		b.ClipsDescendants = true;
		b.Parent = sf;
		local cr = Instance.new("UICorner", b);
		cr.CornerRadius = UDim.new(0, 8);
		local st = Instance.new("UIStroke", b);
		st.Color = TH.Border;
		st.Transparency = 0.92;
		st.Thickness = 1;
		local pad = Instance.new("UIPadding", b);
		pad.PaddingTop = UDim.new(0, isMobile and 14 or 12);
		pad.PaddingBottom = UDim.new(0, isMobile and 14 or 12);
		pad.PaddingRight = UDim.new(0, isMobile and 18 or 16);
		pad.PaddingLeft = UDim.new(0, isMobile and 18 or 16);
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
		lay.Padding = UDim.new(0, hasIcon and (isMobile and 12 or 10) or 0);
		local ic = Instance.new("ImageLabel");
		ic.BackgroundTransparency = 1;
		ic.Image = raw and raw or "";
		ic.Visible = hasIcon;
		ic.ImageTransparency = hasIcon and 0 or 1;
		ic.ScaleType = Enum.ScaleType.Fit;
		ic.ZIndex = b.ZIndex + 2;
		ic.LayoutOrder = 10;
		ic.Size = hasIcon and UDim2.fromOffset((isMobile and 24 or 22), (isMobile and 24 or 22)) or UDim2.new(0, 0, 0, 0);
		ic.Parent = b;
		local lb = Instance.new("TextLabel");
		lb.BackgroundTransparency = 1;
		lb.TextColor3 = TH.Txt;
		lb.RichText = true;
		lb.TextWrapped = true;
		lb.TextScaled = false;
		lb.TextSize = isMobile and 15 or 14;
		lb.Font = font or Enum.Font.GothamBold;
		lb.Text = info.Text or "";
		lb.ZIndex = b.ZIndex + 2;
		lb.LayoutOrder = 20;
		lb.TextYAlignment = Enum.TextYAlignment.Center;
		lb.TextXAlignment = hasIcon and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center;
		lb.Size = UDim2.new(1, hasIcon and (isMobile and (-36) or (-32)) or 0, 1, 0);
		lb.Parent = b;
		local function setSel(on)
			b:SetAttribute("sel", on);
			if on then
				(tw:Create(b, TweenInfo.new(0.12), {
					BackgroundColor3 = TH.BtnSel,
					BackgroundTransparency = 0
				})):Play();
				(tw:Create(st, TweenInfo.new(0.12), {
					Transparency = 0.7
				})):Play();
				(tw:Create(lb, TweenInfo.new(0.12), {
					TextColor3 = TH.Bg
				})):Play();
				if hasIcon then
					(tw:Create(ic, TweenInfo.new(0.12), {
						ImageColor3 = TH.Bg
					})):Play();
				end;
			else
				(tw:Create(b, TweenInfo.new(0.12), {
					BackgroundColor3 = TH.Btn,
					BackgroundTransparency = 1
				})):Play();
				(tw:Create(st, TweenInfo.new(0.12), {
					Transparency = 0.92
				})):Play();
				(tw:Create(lb, TweenInfo.new(0.12), {
					TextColor3 = TH.Txt
				})):Play();
				if hasIcon then
					(tw:Create(ic, TweenInfo.new(0.12), {
						ImageColor3 = TH.Txt
					})):Play();
				end;
			end;
		end;
		s.btns[b] = {
			info = info,
			set = setSel
		};
		setSel(false);
		local c3 = b.MouseEnter:Connect(function()
			if b:GetAttribute("sel") then
				return;
			end;
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundTransparency = 0
			})):Play();
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.BtnHover
			})):Play();
			(tw:Create(st, TweenInfo.new(0.12), {
				Transparency = 0.85
			})):Play();
		end);
		local c4 = b.MouseLeave:Connect(function()
			if b:GetAttribute("sel") then
				return;
			end;
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundTransparency = 1
			})):Play();
			(tw:Create(b, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.Btn
			})):Play();
			(tw:Create(st, TweenInfo.new(0.12), {
				Transparency = 0.92
			})):Play();
		end);
		local c5 = b.MouseButton1Click:Connect(function()
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
		addConnection(b, c3);
		addConnection(b, c4);
		addConnection(b, c5);
	end;
	return sf;
end;
local function widthForDock(dock, kind)
	if dock == "top" or dock == "bottom" then
		return wW();
	end;
	return kind == "Popup" and math.floor(math.clamp(gui.AbsoluteSize.X * (isMobile and 0.88 or 0.36), (isMobile and 360 or 340), (isMobile and 500 or 620))) or nW();
end;
local function dirFrom(str)
	str = string.lower(tostring(str or ""));
	local d = {
		dx = 0,
		dy = isMobile and 20 or 18,
		rot = -1.5
	};
	if str == "top" or str == "up" then
		d.dy = isMobile and (-20) or (-18);
		d.rot = 1.5;
	elseif str == "bottom" or str == "down" then
		d.dy = isMobile and 20 or 18;
		d.rot = -1.5;
	elseif str == "topright" or str == "top right" then
		d.dx = isMobile and 24 or 22;
		d.dy = isMobile and (-24) or (-22);
		d.rot = 1.5;
	elseif str == "topleft" or str == "top left" then
		d.dx = isMobile and (-24) or (-22);
		d.dy = isMobile and (-24) or (-22);
		d.rot = 1.5;
	elseif str == "bottomright" or str == "bottom right" then
		d.dx = isMobile and 24 or 22;
		d.dy = isMobile and 24 or 22;
		d.rot = -1.5;
	elseif str == "bottomleft" or str == "bottom left" then
		d.dx = isMobile and (-24) or (-22);
		d.dy = isMobile and 24 or 22;
		d.rot = -1.5;
	end;
	return d;
end;
local STACKED_NOTIFS = {};
local function canStackNotify(p)
	local btns = p and p.Buttons;
	return (not (p and p.InputField)) and (type(btns) ~= "table" or #btns == 0);
end;
local function notifyStackKey(dock, p)
	return table.concat({
		tostring(dock or "bottomRight"),
		tostring((p and p.Title) or "Notify"),
		tostring((p and p.Description) or ""),
		tostring((p and p.Duration) or "")
	}, "\30");
end;
local function appear(card, sc, st, tgt, from, cnt)
	walkDesc(cnt, function(d)
		if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
			d.TextTransparency = 1;
		end;
		if d:IsA("ImageLabel") then
			d.ImageTransparency = 1;
		end;
	end, 120);

	local bs = (ctx(card).baseScale) or (isMobile and mobScale() or 1);

	card.Rotation = from.rot or (-1.5);
	card.BackgroundTransparency = 1;
	st.Transparency = 1;

	sc.Scale = bs * 0.9;

	card.Position = UDim2.new(
		card.Position.X.Scale,
		card.Position.X.Offset + (from.dx or 0),
		card.Position.Y.Scale,
		card.Position.Y.Offset + (from.dy or 0)
	);

	local tA = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out);
	local tB = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);

	local t1 = tw:Create(card, tA, {
		Size = tgt,
		BackgroundTransparency = 0.6,
		Rotation = 0,
		Position = UDim2.new(
			card.Position.X.Scale,
			card.Position.X.Offset - (from.dx or 0),
			card.Position.Y.Scale,
			card.Position.Y.Offset - (from.dy or 0)
		)
	});

	local t2 = tw:Create(sc, tA, { Scale = bs * 1.02 });
	local t3 = tw:Create(st, TweenInfo.new(0.22), { Transparency = 0.8, Thickness = 1 });

	t1:Play(); t2:Play(); t3:Play();
	addTween(card, t1); addTween(card, t2); addTween(card, t3);

	task.delay(0.18, function()
		local t4 = tw:Create(sc, tB, { Scale = bs });
		t4:Play();
		addTween(card, t4);
	end);

	task.delay(0.05, function()
		local tC = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
		walkDesc(cnt, function(d)
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				local t = tw:Create(d, tC, { TextTransparency = 0 });
				t:Play();
				addTween(card, t);
			elseif d:IsA("ImageLabel") then
				local t = tw:Create(d, tC, { ImageTransparency = 0 });
				t:Play();
				addTween(card, t);
			end;
		end, 120);
	end);
end;
local function disappear(card, sc, st)
	local bs = (ctx(card).baseScale) or (isMobile and mobScale() or 1);

	local t1 = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out);
	local t2 = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In);

	local tw1 = tw:Create(sc, t1, { Scale = bs * 1.02 });
	tw1:Play();
	addTween(card, tw1);

	task.delay(0.08, function()
		local tw2 = tw:Create(sc, t2, { Scale = bs * 0.88 });
		local tw3 = tw:Create(card, t2, { BackgroundTransparency = 1, Rotation = -1 });
		local tw4 = tw:Create(st, t2, { Transparency = 1 });

		tw2:Play(); tw3:Play(); tw4:Play();
		addTween(card, tw2); addTween(card, tw3); addTween(card, tw4);

		task.delay(0.1, function()
			local tw5 = tw:Create(card, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, 0)
			});
			tw5:Play();
			addTween(card, tw5);
		end);
	end);
end;
local function mkCard(w, baseZ, kind, onPause)
	local z = baseZ or 100 + tick() % 1 * 1000;
	local card = Instance.new("Frame");
	card.Name = "Card";
	card.LayoutOrder = os.clock() * 1000;
	card.Size = UDim2.new(0, w, 0, 0);
	card.BackgroundColor3 = TH.Bg;
	card.BackgroundTransparency = 1;
	card.ZIndex = z;
	card.BorderSizePixel = 0;
	card.Active = kind == "Popup";
	card.ClipsDescendants = true;
	local cr = Instance.new("UICorner", card);
	cr.CornerRadius = UDim.new(0, isMobile and 18 or 14);
	local st = Instance.new("UIStroke", card);
	st.Color = TH.Border;
	st.Thickness = 1;
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
	st.Transparency = 0.8;
	local sc = Instance.new("UIScale", card);
	sc.Scale = mobScale();
	local s0 = ctx(card);
	s0.sc = sc;
	s0.baseScale = sc.Scale;
	local hdrHeight = isMobile and 56 or 52;
	
	local body = Instance.new("Frame");
	body.Name = "Body";
	body.BackgroundTransparency = 1;
	body.Position = UDim2.new(0, 0, 0, hdrHeight);
	body.Size = UDim2.new(1, 0, 1, -hdrHeight);
	body.ZIndex = z + 110;
	body.Parent = card;

	local cnt = Instance.new("ScrollingFrame")
	cnt.Name = "Content"
	cnt.Active = kind == "Popup"
	cnt.ScrollingEnabled = kind == "Popup"
	cnt.BackgroundTransparency = 1
	cnt.BorderSizePixel = 0
	cnt.ScrollBarThickness = (kind == "Popup") and (isMobile and 6 or 4) or 0
	cnt.AutomaticCanvasSize = Enum.AutomaticSize.Y
	cnt.CanvasSize = UDim2.new()
	cnt.Size = UDim2.new(1, 0, 1, 0)
	cnt.ClipsDescendants = true
	cnt.ZIndex = z + 120
	cnt.Parent = body

	local pad = Instance.new("UIPadding", cnt);
	pad.PaddingLeft = UDim.new(0, PAD);
	pad.PaddingRight = UDim.new(0, PAD);
	pad.PaddingTop = UDim.new(0, PAD);
	pad.PaddingBottom = UDim.new(0, PAD + (isMobile and 20 or 18));

	local col = Instance.new("UIListLayout", cnt);
	col.Padding = UDim.new(0, isMobile and 14 or 12);
	col.FillDirection = Enum.FillDirection.Vertical;
	col.HorizontalAlignment = Enum.HorizontalAlignment.Left;
	col.SortOrder = Enum.SortOrder.LayoutOrder;
	local ftr = Instance.new("Frame");
	ftr.Name = "Footer";
	ftr.AnchorPoint = Vector2.new(0, 1);
	ftr.Position = UDim2.new(0, 0, 1, 0);
	ftr.Size = UDim2.new(1, 0, 0, isMobile and 20 or 18);
	ftr.BackgroundTransparency = 1;
	ftr.ZIndex = z + 130;
	ftr.Parent = card;
	local trk = Instance.new("Frame");
	trk.Name = "ProgTrack";
	trk.AnchorPoint = Vector2.new(0.5, 0.5);
	trk.Position = UDim2.new(0.5, 0, 0.5, 0);
	trk.Size = UDim2.new(0.9, 0, 0, 2);
	trk.BackgroundTransparency = 0.85;
	trk.BackgroundColor3 = TH.Progress;
	trk.BorderSizePixel = 0;
	trk.ZIndex = z + 140;
	trk.Parent = ftr;
	local c1 = Instance.new("UICorner", trk);
	c1.CornerRadius = UDim.new(1, 0);
	local fil = Instance.new("Frame");
	fil.Name = "ProgFill";
	fil.AnchorPoint = Vector2.new(0, 0.5);
	fil.Position = UDim2.new(0, 0, 0.5, 0);
	fil.Size = UDim2.new(1, 0, 1, 0);
	fil.BackgroundTransparency = 0.1;
	fil.BackgroundColor3 = TH.Progress;
	fil.BorderSizePixel = 0;
	fil.ZIndex = z + 141;
	fil.Parent = trk;
	local c2 = Instance.new("UICorner", fil);
	c2.CornerRadius = UDim.new(1, 0);
	local hdr, ttl, act = mkHdr(card, z, kind, onPause);
	return card, hdr, ttl, act, st, sc, cnt, ftr, trk, fil;
end;
local function openIn(card, par, ftr, trk, st, sc, from, cnt)
	card.Parent = par
	card.Size = UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, 0)
	card.Visible = true

	task.defer(function()
		if not card or (not card.Parent) then
			return
		end

		rs.Heartbeat:Wait()
		rs.Heartbeat:Wait()

		local sca = csc(card)
		local extra = typeof(trk) == "Instance" and trk.Visible and ftr and ftr.AbsoluteSize.Y or 0
		local hdr = card:FindFirstChild("Header")
		local hh = (hdr and hdr.AbsoluteSize.Y) or (isMobile and 56 or 52)

		local needed = cntH(cnt)
		local h = (hh + needed + extra) / sca

		local maxH = (gui.AbsoluteSize.Y * (isMobile and 0.9 or 0.82)) / sca
		h = math.min(h, maxH)

		if h < 2 then h = 2 end

		appear(card, sc, st, UDim2.new(card.Size.X.Scale, card.Size.X.Offset, 0, h), from, cnt)
	end)
end
local function build(kind, p)
	ensureGui();
	p = typeof(p) == "table" and p or {};
	local def = kind == "Window" and "top" or "bottomRight";
	local dock = mapDock(p.Dock or CURD[kind] or def);
	local stackKey;
	if kind == "Notify" and canStackNotify(p) then
		stackKey = notifyStackKey(dock, p);
		local exCard = STACKED_NOTIFS[stackKey];
		if exCard and exCard.Parent then
			local ex = ctx(exCard);
			if ex and (not ex.closing) then
				local newCount = math.max(1, math.floor(tonumber(ex.stackCount) or 1)) + 1;
				if ex.setStackCount then
					ex.setStackCount(newCount);
				else
					ex.stackCount = newCount;
				end;
				exCard.LayoutOrder = os.clock() * 1000;
				local newDur = typeof(p.Duration) == "number" and p.Duration > 0 and p.Duration or nil;
				if ex.timCtl and ex.timCtl.reset then
					ex.timCtl.reset(newDur);
				end;
				return exCard;
			end;
		end;
		STACKED_NOTIFS[stackKey] = nil;
	end;
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
	local function destroyPopupRoot()
		local root = grp;
		grp = nil;
		if root and root.Parent then
			pcall(function()
				root:Destroy();
			end);
		end;
	end;
	if kind == "Popup" then
		grp = Instance.new("Frame");
		grp.Name = "PopupRoot";
		grp.BackgroundTransparency = 1;
		grp.Active = true;
		grp.AnchorPoint = Vector2.new(0.5, 0.5);
		grp.Position = UDim2.fromScale(0.5, 0.5);
		grp.Size = UDim2.fromOffset(w, 0);
		grp.ZIndex = 40000;
		grp.Parent = gui;
		baseZ = grp.ZIndex + 10;
	end;
	local timCtl;
	local card, hdr, ttl, act, st, sc, cnt, ftr, trk, fil = mkCard(w, baseZ, kind, function(paused)
		if timCtl then
			if paused then
				timCtl.pause();
			else
				timCtl.resume();
			end;
		end;
	end);
	if kind == "Popup" then
		local function syncGrp()
			if grp and card then
				grp.Size = UDim2.fromOffset(card.AbsoluteSize.X, card.AbsoluteSize.Y)
			end
		end
		local csz = card:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncGrp)
		addConnection(card, csz)
		syncGrp()
	end
	ACT[kind][card] = true;
	syncOverlayActive();
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
	s.stackKey = stackKey;
	if stackKey then
		STACKED_NOTIFS[stackKey] = card;
	end;
	if s.setStackCount then
		s.setStackCount(1);
	end;
	s.closing = false;
	s.close = function()
		if s.closing then
			return;
		end;
		s.closing = true;
		if s.stackKey and STACKED_NOTIFS[s.stackKey] == card then
			STACKED_NOTIFS[s.stackKey] = nil;
		end;
		if s.closeMenus then
			s.closeMenus();
		end;
		disappear(card, sc, st);
		task.delay(0.38, function()
			if card then
				cleanup(card);
				for _, t in pairs(ACT) do
					t[card] = nil;
				end;
				syncOverlayActive();
				pcall(function()
					card:Destroy();
				end);
				destroyPopupRoot();
			end;
		end);
	end;
	addConnection(card, card.Destroying:Connect(function()
		if s.stackKey and STACKED_NOTIFS[s.stackKey] == card then
			STACKED_NOTIFS[s.stackKey] = nil;
		end;
		for _, t in pairs(ACT) do
			t[card] = nil;
		end;
		syncOverlayActive();
		cleanup(card);
		destroyPopupRoot();
	end));
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
		local hdr = card:FindFirstChild("Header");
		local hh = (hdr and hdr.AbsoluteSize.Y) or (isMobile and 56 or 52);

		local h = (hh + cntH(s.cnt) + extra) / csc(card);
		local b = (newDock == "bottom" or newDock == "bottomLeft" or newDock == "bottomRight") and dirFrom("bottom") or dirFrom("top");
		card.Parent = tgt;
		card.Size = UDim2.new(0, card.AbsoluteSize.X, 0, card.AbsoluteSize.Y);
		card.Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset + (b.dx or 0), card.Position.Y.Scale, card.Position.Y.Offset + (b.dy or 0));
		local t = tw:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, newW, 0, h),
			Position = UDim2.new(card.Position.X.Scale, card.Position.X.Offset - (b.dx or 0), card.Position.Y.Scale, card.Position.Y.Offset - (b.dy or 0))
		});
		t:Play();
		addTween(card, t);
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
		d.TextSize = isMobile and 15 or 14;
		d.AutomaticSize = Enum.AutomaticSize.Y;
		d.Size = UDim2.new(1, 0, 0, 0);
		d.ZIndex = card.ZIndex + 121;
		d.Text = p.Description;
		d.Parent = cnt;
	end;
	if p.InputField then
		local inp = Instance.new("TextBox");
		inp.Size = UDim2.new(1, 0, 0, isMobile and 48 or 44);
		inp.ClearTextOnFocus = false;
		inp.TextXAlignment = Enum.TextXAlignment.Left;
		inp.TextYAlignment = Enum.TextYAlignment.Center;
		inp.Font = CURF[kind];
		inp.TextSize = isMobile and 15 or 14;
		inp.TextColor3 = TH.Txt;
		inp.RichText = true;
		inp.BackgroundColor3 = TH.Btn;
		inp.BackgroundTransparency = 1;
		inp.Text = "";
		inp.PlaceholderText = p.Placeholder or "Type here…";
		inp.PlaceholderColor3 = TH.Mut;
		inp.ZIndex = card.ZIndex + 121;
		inp.Parent = cnt;
		local c = Instance.new("UICorner", inp);
		c.CornerRadius = UDim.new(0, 8);
		local st2 = Instance.new("UIStroke", inp);
		st2.Color = TH.Border;
		st2.Transparency = 0.92;
		st2.Thickness = 1;
		local p2 = Instance.new("UIPadding", inp);
		p2.PaddingLeft = UDim.new(0, isMobile and 16 or 14);
		p2.PaddingRight = UDim.new(0, isMobile and 16 or 14);
		s.inp = inp;
		local c1 = inp.Focused:Connect(function()
			(tw:Create(inp, TweenInfo.new(0.12), {
				BackgroundTransparency = 0
			})):Play();
			(tw:Create(inp, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.BtnHover
			})):Play();
			(tw:Create(st2, TweenInfo.new(0.12), {
				Transparency = 0.85
			})):Play();
		end);
		local c2 = inp.FocusLost:Connect(function()
			(tw:Create(inp, TweenInfo.new(0.12), {
				BackgroundTransparency = 1
			})):Play();
			(tw:Create(inp, TweenInfo.new(0.12), {
				BackgroundColor3 = TH.Btn
			})):Play();
			(tw:Create(st2, TweenInfo.new(0.12), {
				Transparency = 0.92
			})):Play();
		end);
		addConnection(inp, c1);
		addConnection(inp, c2);
	end;
	local btns = p.Buttons or {};
	if #btns > 0 then
		mkBtnArea(cnt, btns, card, card.ZIndex + 122, math.floor(gui.AbsoluteSize.Y * 0.52), CURF[kind]);
	end;
	if #btns > 2 then
		local mBtn, setMSel = mkIcn(act, "M", act.ZIndex + 3, CURF[kind]);
		local okBtn, _ = mkIcn(act, "✓", act.ZIndex + 3, CURF[kind]);
		mBtn.LayoutOrder = 10;
		okBtn.LayoutOrder = 20;
		okBtn.Visible = false;
		local function showOK(on)
			on = (s.multi and on) and true or false;
			okBtn.Visible = on;
			task.spawn(function()
				rs.Heartbeat:Wait();
				rs.Heartbeat:Wait();
				if s and s.refTitle then
					s.refTitle();
				end;
			end);
		end;
		setMSel(false);
		local c1 = mBtn.MouseButton1Click:Connect(function()
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
		local c2 = okBtn.MouseButton1Click:Connect(function()
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
		addConnection(mBtn, c1);
		addConnection(okBtn, c2);
		s.ok = function(vis)
			showOK((s.multi and vis) and true or false);
		end;
	end;
	local dur = typeof(p.Duration) == "number" and p.Duration > 0 and p.Duration or nil;
	local showProg = kind == "Notify" and #btns == 0 and dur ~= nil;
	local shouldTimer = kind == "Notify" and dur ~= nil;
	local parent = kind == "Popup" and grp or getStack(dock);
	trk.Visible = showProg;
	openIn(card, parent, ftr, showProg and trk or nil, st, sc, from, cnt);
	if shouldTimer then
		timCtl = attachTimer(card, showProg and fil or nil, dur);
	end;
	s.timCtl = timCtl;
	if kind == "Popup" then
		ov.BackgroundTransparency = 1;
		trackPopupCenter(grp, card);
		grp.Active = true;
		grp.Draggable = true;
		card.Draggable = false;
		local function markManual()
			(ctx(grp)).popupManual = true;
		end;
		if grp.DragBegin then
			addConnection(card, grp.DragBegin:Connect(markManual));
		end;
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
_naNotif_env.EnhancedNotifs = {
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
return _naNotif_env.EnhancedNotifs;
