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
local function Svc(name)
	return NA_SRV[name];
end;
local function Protect(g)
	if g:IsA("ScreenGui") then
		g.ZIndexBehavior = Enum.ZIndexBehavior.Global;
		g.DisplayOrder = 999999999;
		g.ResetOnSpawn = false;
		g.IgnoreGuiInset = true;
	end;
	local cg = Svc("CoreGui");
	local lp = (Svc("Players")).LocalPlayer;
	local function NAP(i, v)
		if i then
			if v then
				i[v] = "\000";
				i.Archivable = false;
			else
				i.Name = "\000";
				i.Archivable = false;
			end;
		end;
	end;
	if gethui then
		NAP(g);
		g.Parent = gethui();
		return g;
	elseif cg and cg:FindFirstChild("RobloxGui") then
		NAP(g);
		g.Parent = cg:FindFirstChild("RobloxGui");
		return g;
	elseif cg then
		NAP(g);
		g.Parent = cg;
		return g;
	else
		local lp2 = (Svc("Players")).LocalPlayer;
		if lp2 and lp2:FindFirstChildWhichIsA("PlayerGui") then
			NAP(g);
			g.Parent = lp2:FindFirstChildWhichIsA("PlayerGui");
			g.ResetOnSpawn = false;
			return g;
		end;
	end;
	return nil;
end;
local rawRequest = request or http_request or syn and syn.request;
local rq = rawRequest;
local tw = Svc("TweenService");
local ui = Svc("UserInputService");
local hs = Svc("HttpService");
local rs = Svc("RunService");
local MarketplaceService = Svc("MarketplaceService");
local eng = "ScriptBlox";
local col = {
	bg = Color3.fromRGB(20, 22, 26),
	ac = Color3.fromRGB(30, 144, 255),
	sc = Color3.fromRGB(32, 34, 40),
	tx = Color3.fromRGB(255, 255, 255),
	td = Color3.fromRGB(186, 192, 205),
	su = Color3.fromRGB(52, 211, 153),
	wa = Color3.fromRGB(255, 179, 71),
	er = Color3.fromRGB(244, 63, 94)
};
local isMobile = (function()
	local platform = ui:GetPlatform();
	if platform == Enum.Platform.IOS or platform == Enum.Platform.Android or platform == Enum.Platform.AndroidTV or platform == Enum.Platform.Chromecast or platform == Enum.Platform.MetaOS then
		return true;
	end;
	if platform == Enum.Platform.None then
		return ui.TouchEnabled and (not (ui.KeyboardEnabled or ui.MouseEnabled));
	end;
	return false;
end)();
local frameScaleX = isMobile and 0.7 or 0.42;
local frameScaleY = isMobile and 0.8 or 0.7;
local titleWidthScale = isMobile and 0.7 or 0.62;
local searchWidthScale = isMobile and 0.94 or 0.88;
local topHeight = isMobile and 52 or 48;
local searchHeight = isMobile and 56 or 52;
local sidePadding = 12;
local verticalGap = 10;
local NAmanageRef = getgenv and (getgenv()).NAmanage or rawget(_G, "NAmanage");
local function centerFrame(f)
	local cf = NAmanageRef and NAmanageRef.centerFrame;
	if type(cf) == "function" then
		return cf(f);
	end;
	local cam = workspace.CurrentCamera;
	if not (cam and f) then
		return;
	end;
	local vp = cam.ViewportSize;
	if vp.X == 0 or vp.Y == 0 then
		return;
	end;
	local totalX = f.Size.X.Scale + f.Size.X.Offset / vp.X;
	local totalY = f.Size.Y.Scale + f.Size.Y.Offset / vp.Y;
	f.Position = UDim2.new(0.5 - totalX / 2, 0, 0.5 - totalY / 2, 0);
end;
local function clampFrameWithinViewport()
	local cam = workspace.CurrentCamera;
	if not (cam and fr) then
		return;
	end;
	local vp = cam.ViewportSize;
	local size = fr.AbsoluteSize;
	local pos = fr.AbsolutePosition;
	local margin = 8;
	local maxX = math.max(margin, vp.X - size.X - margin);
	local maxY = math.max(margin, vp.Y - size.Y - margin);
	local newX = math.clamp(pos.X, margin, maxX);
	local newY = math.clamp(pos.Y, margin, maxY);
	if newX ~= pos.X or newY ~= pos.Y then
		fr.Position = UDim2.fromOffset(newX, newY);
	end;
end;
local autoCenter = true;
local sg = Instance.new("ScreenGui");
sg.Name = "SBX";
Protect(sg);
local fr = Instance.new("Frame");
fr.Size = UDim2.new(frameScaleX, 0, frameScaleY, 0);
fr.AnchorPoint = Vector2.new(0, 0);
fr.Position = UDim2.new(0, 0, 0, 0);
fr.BackgroundColor3 = col.bg;
fr.BorderSizePixel = 0;
fr.Active = true;
fr.ClipsDescendants = true;
fr.Parent = sg;
if autoCenter then
	centerFrame(fr);
end;
local cam = workspace.CurrentCamera;
if cam then
	(cam:GetPropertyChangedSignal("ViewportSize")):Connect(function()
		if autoCenter then
			centerFrame(fr);
		else
			clampFrameWithinViewport();
		end;
	end);
end;
(fr:GetPropertyChangedSignal("Size")):Connect(function()
	if autoCenter then
		centerFrame(fr);
	else
		clampFrameWithinViewport();
	end;
end);
local frc = Instance.new("UICorner");
frc.CornerRadius = UDim.new(0, 14);
frc.Parent = fr;
local fst = Instance.new("UIStroke");
fst.Thickness = 1;
fst.Color = Color3.fromRGB(70, 75, 85);
fst.Transparency = 0.35;
fst.Parent = fr;
local top = Instance.new("Frame");
top.Size = UDim2.new(1, 0, 0, topHeight);
top.BackgroundColor3 = col.sc;
top.BorderSizePixel = 0;
top.Parent = fr;
local topc = Instance.new("UICorner");
topc.CornerRadius = UDim.new(0, 14);
topc.Parent = top;
local tgrad = Instance.new("UIGradient");
tgrad.Color = ColorSequence.new(Color3.fromRGB(45, 49, 58), col.sc);
tgrad.Rotation = 90;
tgrad.Parent = top;
task.spawn(function()
	while top.Parent do
		(tw:Create(tgrad, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {
			Offset = Vector2.new(0, 0.07)
		})):Play();
		task.wait(1.8);
	end;
end);
local ttl = Instance.new("TextLabel");
ttl.Size = UDim2.new(titleWidthScale, 0, 1, 0);
ttl.Position = UDim2.new(0, sidePadding, 0, 0);
ttl.BackgroundTransparency = 1;
ttl.Font = Enum.Font.GothamBold;
ttl.Text = "Script Hub • by @ltseverydayyou";
ttl.TextColor3 = col.tx;
ttl.TextSize = 16;
ttl.TextXAlignment = Enum.TextXAlignment.Left;
ttl.Parent = top;
local tr = Instance.new("Frame");
tr.BackgroundTransparency = 1;
tr.Size = UDim2.new(0, 0, 1, -12);
tr.Position = UDim2.new(1, -12, 0, 6);
tr.AnchorPoint = Vector2.new(1, 0);
tr.AutomaticSize = Enum.AutomaticSize.X;
tr.Parent = top;
local trl = Instance.new("UIListLayout");
trl.FillDirection = Enum.FillDirection.Horizontal;
trl.HorizontalAlignment = Enum.HorizontalAlignment.Right;
trl.VerticalAlignment = Enum.VerticalAlignment.Center;
trl.Padding = UDim.new(0, 6);
trl.Parent = tr;
local engb = Instance.new("TextButton");
engb.Size = UDim2.new(0, 156, 1, 0);
engb.BackgroundColor3 = col.bg;
engb.Text = "Engine: ScriptBlox";
engb.TextColor3 = col.tx;
engb.TextSize = 13;
engb.Font = Enum.Font.GothamSemibold;
engb.AutoButtonColor = false;
engb.Parent = tr;
local engbc = Instance.new("UICorner");
engbc.CornerRadius = UDim.new(0, 8);
engbc.Parent = engb;
local engbs = Instance.new("UIStroke");
engbs.Thickness = 1;
engbs.Color = Color3.fromRGB(70, 75, 85);
engbs.Transparency = 0.25;
engbs.Parent = engb;
local mini = Instance.new("TextButton");
mini.Size = UDim2.new(0, 36, 1, 0);
mini.BackgroundColor3 = Color3.fromRGB(45, 49, 58);
mini.Text = "^";
mini.TextColor3 = col.tx;
mini.TextScaled = true;
mini.Font = Enum.Font.GothamBold;
mini.AutoButtonColor = false;
mini.Rotation = 0;
mini.Parent = tr;
local minic = Instance.new("UICorner");
minic.CornerRadius = UDim.new(0, 8);
minic.Parent = mini;
local cls = Instance.new("TextButton");
cls.Size = UDim2.new(0, 36, 1, 0);
cls.BackgroundColor3 = Color3.fromRGB(45, 49, 58);
cls.Text = "X";
cls.TextColor3 = col.tx;
cls.TextScaled = true;
cls.Font = Enum.Font.GothamBold;
cls.AutoButtonColor = false;
cls.Parent = tr;
local clsc = Instance.new("UICorner");
clsc.CornerRadius = UDim.new(0, 8);
clsc.Parent = cls;
local sr = Instance.new("Frame");
sr.Size = UDim2.new(1, -(sidePadding * 2), 0, searchHeight);
sr.Position = UDim2.new(0, sidePadding, 0, topHeight + verticalGap);
sr.BackgroundColor3 = col.sc;
sr.BorderSizePixel = 0;
sr.Parent = fr;
local src = Instance.new("UICorner");
src.CornerRadius = UDim.new(0, 10);
src.Parent = sr;
local srs = Instance.new("UIStroke");
srs.Thickness = 1;
srs.Color = Color3.fromRGB(70, 75, 85);
srs.Transparency = 0.25;
srs.Parent = sr;
local sPad = Instance.new("UIPadding");
sPad.PaddingLeft = UDim.new(0, 10);
sPad.PaddingRight = UDim.new(0, 10);
sPad.Parent = sr;
local sLbl = Instance.new("TextLabel");
sLbl.Size = UDim2.new(0, 28, 1, 0);
sLbl.BackgroundTransparency = 1;
sLbl.Font = Enum.Font.GothamBold;
sLbl.Text = "🔎";
sLbl.TextColor3 = col.td;
sLbl.TextScaled = true;
sLbl.Parent = sr;
local goWidth = isMobile and 118 or 128;
local goHeight = isMobile and 34 or 36;
local sbox = Instance.new("TextBox");
sbox.Size = UDim2.new(searchWidthScale, -(goWidth + sidePadding + 32), 1, -12);
sbox.Position = UDim2.new(0, 36, 0, 6);
sbox.BackgroundTransparency = 1;
sbox.Font = Enum.Font.Gotham;
sbox.PlaceholderText = "Search for scripts (scriptblox.com)";
sbox.Text = "";
sbox.TextColor3 = col.tx;
sbox.PlaceholderColor3 = Color3.fromRGB(140, 146, 160);
sbox.TextSize = 15;
sbox.TextXAlignment = Enum.TextXAlignment.Left;
sbox.ClearTextOnFocus = false;
sbox.Parent = sr;
local go = Instance.new("TextButton");
go.Size = UDim2.new(0, goWidth, 0, goHeight);
go.Position = UDim2.new(1, -(sidePadding + goWidth), 0.5, -(goHeight / 2));
go.BackgroundColor3 = col.ac;
go.BorderSizePixel = 0;
go.Font = Enum.Font.GothamSemibold;
go.Text = "Search";
go.TextColor3 = col.tx;
go.TextSize = 14;
go.AutoButtonColor = false;
go.Parent = sr;
local goc = Instance.new("UICorner");
goc.CornerRadius = UDim.new(0, 8);
goc.Parent = go;
local goGrad = Instance.new("UIGradient");
goGrad.Color = ColorSequence.new(col.ac, Color3.fromRGB(58, 160, 255));
goGrad.Rotation = 0;
goGrad.Offset = Vector2.new(-1, 0);
goGrad.Parent = go;
task.spawn(function()
	while go.Parent do
		(tw:Create(goGrad, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Offset = Vector2.new(1, 0)
		})):Play();
		task.wait(2.2);
		goGrad.Offset = Vector2.new(-1, 0);
	end;
end);
local ub = Instance.new("Frame");
ub.AnchorPoint = Vector2.new(0, 1);
ub.Position = UDim2.new(0, 12, 1, -6);
ub.Size = UDim2.new(0, 0, 0, 2);
ub.BackgroundColor3 = col.ac;
ub.BorderSizePixel = 0;
ub.Parent = sr;
local sp = Instance.new("TextLabel");
sp.Size = UDim2.new(0, 30, 0, 30);
sp.Position = UDim2.new(1, -(sidePadding + goWidth + 60), 0.5, -15);
sp.BackgroundTransparency = 1;
sp.Font = Enum.Font.Code;
sp.Text = "";
sp.TextColor3 = col.tx;
sp.TextScaled = true;
sp.ZIndex = 2;
sp.Parent = sr;
local rcOffsetY = topHeight + verticalGap + searchHeight + 8;
local rc = Instance.new("Frame");
rc.Size = UDim2.new(1, -(sidePadding * 2), 1, -(rcOffsetY + 12));
rc.Position = UDim2.new(0, sidePadding, 0, rcOffsetY);
rc.BackgroundColor3 = col.sc;
rc.BorderSizePixel = 0;
rc.Parent = fr;
local rcc = Instance.new("UICorner");
rcc.CornerRadius = UDim.new(0, 10);
rcc.Parent = rc;
local rcs = Instance.new("UIStroke");
rcs.Color = Color3.fromRGB(70, 75, 85);
rcs.Transparency = 0.3;
rcs.Thickness = 1;
rcs.Parent = rc;
local function btnAnim(b, baseCol, hoverCol)
	b:SetAttribute("BaseColor", baseCol);
	local base = b.Size;
	local hover = UDim2.new(base.X.Scale, base.X.Offset + 4, base.Y.Scale, base.Y.Offset + 2);
	local press = UDim2.new(base.X.Scale, base.X.Offset - 2, base.Y.Scale, base.Y.Offset - 1);
	local hovering = false;
	b.MouseEnter:Connect(function()
		if not b.Active then
			return;
		end;
		hovering = true;
		(tw:Create(b, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverCol,
			Size = hover
		})):Play();
	end);
	b.MouseLeave:Connect(function()
		if not b.Active then
			return;
		end;
		hovering = false;
		(tw:Create(b, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = baseCol,
			Size = base
		})):Play();
	end);
	b.MouseButton1Down:Connect(function()
		if not b.Active then
			return;
		end;
		(tw:Create(b, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = press
		})):Play();
	end);
	b.MouseButton1Up:Connect(function()
		if not b.Active then
			return;
		end;
		(tw:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = hovering and hover or base
		})):Play();
	end);
end;
local pageBarHeight = 40;
local pageBar = Instance.new("Frame");
pageBar.Name = "PageControls";
pageBar.Size = UDim2.new(1, -16, 0, pageBarHeight);
pageBar.Position = UDim2.new(0, 8, 0, 8);
pageBar.BackgroundTransparency = 1;
pageBar.Parent = rc;
local pageLayout = Instance.new("UIListLayout");
pageLayout.FillDirection = Enum.FillDirection.Horizontal;
pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center;
pageLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
pageLayout.Padding = UDim.new(0, 6);
pageLayout.Parent = pageBar;
local function mkPageBtn(txt, width, order)
	local b = Instance.new("TextButton");
	b.Size = UDim2.new(0, width or 72, 0, 30);
	b.BackgroundColor3 = Color3.fromRGB(45, 49, 58);
	b.BorderSizePixel = 0;
	b.AutoButtonColor = false;
	b.Font = Enum.Font.GothamSemibold;
	b.Text = txt;
	b.TextSize = 13;
	b.TextColor3 = col.tx;
	b.LayoutOrder = order or 1;
	b.Parent = pageBar;
	local bc = Instance.new("UICorner");
	bc.CornerRadius = UDim.new(0, 8);
	bc.Parent = b;
	btnAnim(b, b.BackgroundColor3, b.BackgroundColor3:Lerp(col.ac, 0.3));
	return b;
end;
local firstBtn = mkPageBtn("First", nil, 1);
local prevBtn = mkPageBtn("Prev", nil, 2);
local pageInfo = Instance.new("TextLabel");
pageInfo.Size = UDim2.new(0, 140, 0, 30);
pageInfo.BackgroundTransparency = 1;
pageInfo.Font = Enum.Font.Gotham;
pageInfo.TextSize = 13;
pageInfo.TextColor3 = col.td;
pageInfo.Text = "Page 1 / 1";
pageInfo.TextXAlignment = Enum.TextXAlignment.Center;
pageInfo.LayoutOrder = 3;
pageInfo.Parent = pageBar;
local nextBtn = mkPageBtn("Next", nil, 4);
local lastBtn = mkPageBtn("Last", nil, 5);
local pagination = {
	current = 1,
	total = 1,
	query = "",
	trending = false,
	hasResults = false
};
local searching = false;
local function setNavButtonEnabled(btn, enabled)
	if not btn then
		return;
	end;
	local base = btn:GetAttribute("BaseColor") or btn.BackgroundColor3;
	btn.Active = enabled;
	btn.TextColor3 = enabled and col.tx or col.td;
	local disabledColor = base:Lerp(col.sc, 0.5);
	if enabled then
		btn.BackgroundColor3 = base;
	else
		btn.BackgroundColor3 = disabledColor;
	end;
end;
local function updatePageControls()
	local supports = eng == "ScriptBlox" or eng == "RScripts";
	pageBar.Visible = supports;
	if not supports then
		return;
	end;
	local current = math.max(pagination.current, 1);
	local total = math.max(pagination.total, 1);
	pageInfo.Text = ("Page %d / %d"):format(current, total);
	local ready = not searching;
	local hasPrev = current > 1;
	local hasNext = current < total;
	setNavButtonEnabled(firstBtn, ready and hasPrev);
	setNavButtonEnabled(prevBtn, ready and hasPrev);
	setNavButtonEnabled(nextBtn, ready and hasNext);
	setNavButtonEnabled(lastBtn, ready and hasNext);
end;
local function resetPagination(clearQuery)
	pagination.current = 1;
	pagination.total = 1;
	pagination.hasResults = false;
	if clearQuery then
		pagination.query = "";
		pagination.trending = false;
	end;
	updatePageControls();
end;
resetPagination(true);
local sf = Instance.new("ScrollingFrame");
sf.Size = UDim2.new(1, -16, 1, -(pageBarHeight + 24));
sf.Position = UDim2.new(0, 8, 0, pageBarHeight + 16);
sf.BackgroundTransparency = 1;
sf.BorderSizePixel = 0;
sf.ScrollBarThickness = 6;
sf.ScrollBarImageColor3 = col.ac;
sf.CanvasSize = UDim2.new(0, 0, 0, 0);
sf.Parent = rc;
local gridLayout;
local listLayout;
if isMobile then
	listLayout = Instance.new("UIListLayout");
	listLayout.FillDirection = Enum.FillDirection.Vertical;
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	listLayout.Padding = UDim.new(0, 8);
	listLayout.Parent = sf;
else
	gridLayout = Instance.new("UIGridLayout");
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8);
	gridLayout.CellSize = UDim2.new(0.48, -10, 0, 240);
	gridLayout.FillDirection = Enum.FillDirection.Horizontal;
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top;
	gridLayout.Parent = sf;
end;
local pad = Instance.new("UIPadding");
pad.PaddingTop = UDim.new(0, 8);
pad.PaddingLeft = UDim.new(0, 2);
pad.PaddingRight = UDim.new(0, 2);
pad.PaddingBottom = UDim.new(0, 8);
pad.Parent = sf;
local tn = Instance.new("Frame");
tn.AnchorPoint = Vector2.new(1, 0);
tn.BackgroundTransparency = 1;
tn.Size = UDim2.new(0, 280, 1, 0);
tn.Position = UDim2.new(1, -16, 0, 72);
tn.ZIndex = 10;
tn.Parent = fr;
local tnl = Instance.new("UIListLayout");
tnl.VerticalAlignment = Enum.VerticalAlignment.Top;
tnl.HorizontalAlignment = Enum.HorizontalAlignment.Right;
tnl.Padding = UDim.new(0, 8);
tnl.Parent = tn;
local SCRIPTBLOX_BASE = "https://scriptblox.com";
local RSCRIPTS_BASE = "https://rscripts.net";
local IMAGE_CACHE_DIR = "ScriptHubImages";
local function sanitizeFileName(str)
	return str:gsub("[^%w%._%-]", "_");
end;
local function hashString(str)
	local hash = 0;
	for i = 1, #str do
		hash = (hash * 31 + string.byte(str, i)) % 4294967296;
	end;
	return string.format("%08x", hash);
end;
local function clearImageCache()
	if type(isfolder) ~= "function" or type(listfiles) ~= "function" or type(isfile) ~= "function" or type(delfile) ~= "function" then
		return false;
	end;
	local okExists, exists = pcall(isfolder, IMAGE_CACHE_DIR);
	if not okExists or (not exists) then
		return false;
	end;
	local okList, files = pcall(listfiles, IMAGE_CACHE_DIR);
	if not okList or type(files) ~= "table" then
		return false;
	end;
	for _, path in ipairs(files) do
		if type(path) == "string" and path ~= "" then
			pcall(delfile, path);
		end;
	end;
	return true;
end;
local function ensureImageFolder()
	if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return false;
	end;
	local okExists, exists = pcall(isfolder, IMAGE_CACHE_DIR);
	if not okExists then
		return false;
	end;
	if not exists then
		local okMk = pcall(makefolder, IMAGE_CACHE_DIR);
		if not okMk then
			return false;
		end;
	end;
	return true;
end;
local function deriveImageFileName(url)
	local fileName = url:match("/([^/%?#]+)") or "image";
	fileName = fileName:match("([^?#]+)") or fileName;
	local base = fileName:match("(.+)%.") or fileName;
	base = sanitizeFileName(base);
	local ext = "txt";
	local hashed = hashString(url);
	return string.format("%s_%s.%s", base ~= "" and base or "image", hashed, ext);
end;
clearImageCache();
local function normalizeImageUrl(url, base)
	if type(url) ~= "string" or url == "" then
		return nil;
	end;
	local trimmed = url:match("^%s*(.-)%s*$") or "";
	if trimmed == "" then
		return nil;
	end;
	if trimmed:match("^rbxassetid://") or trimmed:match("^rbxthumb://") then
		return nil;
	end;
	if trimmed:match("^https?://") then
		return trimmed;
	end;
	if trimmed:sub(1, 2) == "//" then
		return "https:" .. trimmed;
	end;
	if trimmed:sub(1, 1) == "/" then
		if base then
			return base .. trimmed;
		end;
		return trimmed;
	end;
	if base then
		return base .. "/" .. trimmed;
	end;
	return trimmed;
end;
local function isMeaningfulImageUrl(url)
	if type(url) ~= "string" or url == "" then
		return false;
	end;
	local lower = url:lower();
	if lower:find("no%-script") then
		return false;
	end;
	return true;
end;
local function httpGetBinary(url, headers)
	if type(url) ~= "string" or url == "" then
		return nil;
	end;
	local function tryRequest(customHeaders, tag)
		if type(rq) ~= "function" then
			return nil;
		end;
		local hdr = {};
		if type(customHeaders) == "table" then
			for k, v in pairs(customHeaders) do
				hdr[k] = v;
			end;
		end;
		hdr["User-Agent"] = hdr["User-Agent"] or "Roblox/Http/1.1";
		hdr.Accept = hdr.Accept or "*/*";
		local okReq, res = pcall(rq, {
			Url = url,
			Method = "GET",
			Headers = hdr
		});
		if okReq and res then
			local status = res.StatusCode or res.Status or res.status_code or 0;
			local body = res.Body or res.body;
			if status == 0 or status >= 200 and status < 300 then
				if type(body) == "string" and body ~= "" then
					return body;
				end;
			end;
		end;
		return nil;
	end;
	local data = tryRequest(headers, "rq1");
	if not (type(data) == "string" and data ~= "") then
		local okDirect, direct = pcall(function()
			return game:HttpGet(url);
		end);
		if okDirect and type(direct) == "string" and direct ~= "" then
			data = direct;
		else
			data = tryRequest(nil, "rq2");
		end;
	end;
	if type(data) == "string" and data ~= "" then
		return data;
	end;
	return nil;
end;
local function downloadImageAsset(url)
	if type(url) ~= "string" or url == "" then
		return nil;
	end;
	if type(getcustomasset) ~= "function" or type(writefile) ~= "function" or type(isfile) ~= "function" or type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return nil;
	end;
	if not ensureImageFolder() then
		return nil;
	end;
	local fileName = deriveImageFileName(url);
	local fullPath = IMAGE_CACHE_DIR .. "/" .. fileName;
	local needDownload = true;
	local okExists, exists = pcall(isfile, fullPath);
	if okExists and exists then
		needDownload = false;
	end;
	if needDownload then
		local host = url:match("^https?://([^/]+)") or "";
		local headers;
		if host:find("scriptblox%.com") then
			headers = nil;
		elseif host:find("rscripts%.net") then
			headers = {
				Referer = RSCRIPTS_BASE
			};
		elseif host:find("rbxcdn%.com") then
			headers = {
				Referer = "https://www.roblox.com/"
			};
		end;
		local data = httpGetBinary(url, headers);
		if not (type(data) == "string" and data ~= "") then
			return nil;
		end;
		local okWrite, err = pcall(writefile, fullPath, data);
		if not okWrite then
			return nil;
		end;
	end;
	local okAsset, assetId = pcall(getcustomasset, fullPath);
	if okAsset and assetId then
		return assetId;
	end;
	return nil;
end;
local function resolveScriptBloxImage(data)
	if not data then
		return nil;
	end;
	local function pick(values)
		for _, value in ipairs(values) do
			local normalized = normalizeImageUrl(value, SCRIPTBLOX_BASE);
			if normalized and isMeaningfulImageUrl(normalized) then
				return normalized;
			end;
		end;
	end;
	local fromScript = pick({
		data.image,
		data.imageUrl,
		data.thumbnail,
		data.coverImage,
		data.icon
	});
	if fromScript then
		return fromScript;
	end;
	local game = data.game or {};
	local fromGame = pick({
		game.imageUrl,
		game.thumbnail,
		game.image,
		game.coverImage,
		game.icon
	});
	if fromGame then
		return fromGame;
	end;
	return nil;
end;
local function resolveRScriptsImage(data)
	if not data then
		return nil;
	end;
	local candidates = {
		data.image,
		data.imageUrl,
		data.thumbnail,
		data.cover,
		data.banner,
		data.img
	};
	for _, value in ipairs(candidates) do
		local normalized = normalizeImageUrl(value, RSCRIPTS_BASE);
		if normalized then
			return normalized;
		end;
	end;
	local game = data.game;
	if game then
		local gameFields = {
			game.imgurl,
			game.imageUrl,
			game.image,
			game.thumbnail,
			game.cover,
			game.banner,
			game.gameLogo
		};
		for _, value in ipairs(gameFields) do
			local normalized = normalizeImageUrl(value, RSCRIPTS_BASE);
			if normalized then
				return normalized;
			end;
		end;
	end;
	return nil;
end;
ensureImageFolder();
local function buildRobloxThumbnail(placeId)
	local id = tostring(placeId or "");
	if id == "" or id == "0" then
		return nil;
	end;
	return "https://www.roblox.com/Thumbs/PlaceThumbnail.ashx?width=420&height=270&format=png&placeId=" .. id;
end;
local function tryFetchPlaceIcon(placeId, imageLabel)
	if not MarketplaceService or (not placeId) or (not imageLabel) then
		return;
	end;
	(coroutine.wrap(function()
		local ok, info = pcall(function()
			return MarketplaceService:GetProductInfo(tonumber(placeId), Enum.InfoType.Asset);
		end);
		if not ok or (not info) then
			return;
		end;
		local iconId = info.IconImageAssetId;
		if iconId and iconId ~= 0 then
			imageLabel.Image = "rbxassetid://" .. iconId;
			imageLabel.ImageTransparency = 0;
		end;
	end))();
end;
btnAnim(engb, col.bg, Color3.fromRGB(45, 49, 58));
btnAnim(go, col.ac, Color3.fromRGB(58, 160, 255));
btnAnim(mini, mini.BackgroundColor3, mini.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.12));
btnAnim(cls, cls.BackgroundColor3, Color3.fromRGB(72, 24, 32));
local function sizeCanvas()
	local y = 0;
	if gridLayout then
		y = gridLayout.AbsoluteContentSize.Y;
	elseif listLayout then
		y = listLayout.AbsoluteContentSize.Y;
	end;
	sf.CanvasSize = UDim2.new(0, 0, 0, y + 12);
end;
if gridLayout then
	(gridLayout:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(sizeCanvas);
end;
if listLayout then
	(listLayout:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(sizeCanvas);
end;
local function clearAll(anim)
	for _, v in ipairs(sf:GetChildren()) do
		if v:IsA("Frame") and (v.Name:find("^Card") or v.Name == "Msg" or v.Name == "Skel") then
			if anim then
				(tw:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					BackgroundTransparency = 1,
					Position = v.Position + UDim2.new(0, 0, 0, 6)
				})):Play();
				task.delay(0.2, function()
					if v then
						v:Destroy();
					end;
				end);
			else
				v:Destroy();
			end;
		end;
	end;
	sizeCanvas();
end;
local function toast(txt, colr)
	local f = Instance.new("Frame");
	f.Size = UDim2.new(0, 300, 0, 44);
	f.BackgroundColor3 = col.sc;
	f.BorderSizePixel = 0;
	f.ZIndex = 11;
	f.Parent = tn;
	local fc = Instance.new("UICorner");
	fc.CornerRadius = UDim.new(0, 10);
	fc.Parent = f;
	local fs = Instance.new("UIStroke");
	fs.Color = Color3.fromRGB(80, 85, 95);
	fs.Transparency = 0.35;
	fs.Thickness = 1;
	fs.Parent = f;
	local lb = Instance.new("TextLabel");
	lb.BackgroundTransparency = 1;
	lb.Text = txt;
	lb.TextWrapped = true;
	lb.TextXAlignment = Enum.TextXAlignment.Left;
	lb.Font = Enum.Font.Gotham;
	lb.TextSize = 14;
	lb.TextColor3 = colr or col.tx;
	lb.Size = UDim2.new(1, -24, 1, 0);
	lb.Position = UDim2.new(0, 12, 0, 0);
	lb.ZIndex = 12;
	lb.Parent = f;
	f.AnchorPoint = Vector2.new(1, 0);
	f.Position = UDim2.new(1, 24, 0, 0);
	f.BackgroundTransparency = 1;
	lb.TextTransparency = 1;
	(tw:Create(f, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 0
	})):Play();
	(tw:Create(lb, TweenInfo.new(0.2), {
		TextTransparency = 0
	})):Play();
	task.delay(2.2, function()
		(tw:Create(f, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 24, 0, 0),
			BackgroundTransparency = 1
		})):Play();
		task.delay(0.24, function()
			if f then
				f:Destroy();
			end;
		end);
	end);
end;
local spConn;
local spFrames = {
	"⠋",
	"⠙",
	"⠹",
	"⠸",
	"⠼",
	"⠴",
	"⠦",
	"⠧",
	"⠇",
	"⠏"
};
local function spin(on)
	if on then
		if spConn then
			return;
		end;
		sp.Text = spFrames[1];
		ub.Size = UDim2.new(0, 0, 0, 2);
		(tw:Create(ub, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {
			Size = UDim2.new(1, -24, 0, 2)
		})):Play();
		local i, acc = 1, 0;
		spConn = rs.RenderStepped:Connect(function(dt)
			acc += dt;
			if acc > 0.08 then
				acc = 0;
				i = i % (#spFrames) + 1;
				sp.Text = spFrames[i];
			end;
		end);
	else
		if spConn then
			spConn:Disconnect();
			spConn = nil;
		end;
		sp.Text = "";
		(tw:Create(ub, TweenInfo.new(0.15), {
			Size = UDim2.new(0, 0, 0, 2)
		})):Play();
	end;
end;
local function skeleton(n)
	for i = 1, n do
		local s = Instance.new("Frame");
		s.Name = "Skel";
		s.Size = UDim2.new(1, 0, 1, 0);
		s.LayoutOrder = i;
		s.BackgroundColor3 = Color3.fromRGB(40, 44, 52);
		s.BorderSizePixel = 0;
		s.Parent = sf;
		local sc = Instance.new("UICorner");
		sc.CornerRadius = UDim.new(0, 10);
		sc.Parent = s;
		local g = Instance.new("UIGradient");
		g.Color = ColorSequence.new(Color3.fromRGB(50, 54, 62), Color3.fromRGB(60, 64, 72), Color3.fromRGB(50, 54, 62));
		g.Rotation = 0;
		g.Offset = Vector2.new(-1, 0);
		g.Parent = s;
		(tw:Create(g, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
			Offset = Vector2.new(1, 0)
		})):Play();
	end;
	sizeCanvas();
end;
local function mkMsg(txt, bg)
	local el = Instance.new("Frame");
	el.Name = "Msg";
	el.Size = UDim2.new(1, -8, 0, 52);
	el.BackgroundColor3 = bg;
	el.BackgroundTransparency = 0.15;
	el.Parent = sf;
	local elc = Instance.new("UICorner");
	elc.CornerRadius = UDim.new(0, 8);
	elc.Parent = el;
	local lb = Instance.new("TextLabel");
	lb.BackgroundTransparency = 1;
	lb.Size = UDim2.new(1, -20, 1, 0);
	lb.Position = UDim2.new(0, 10, 0, 0);
	lb.Font = Enum.Font.Gotham;
	lb.Text = txt;
	lb.TextSize = 14;
	lb.TextColor3 = col.tx;
	lb.Parent = el;
	local sc = Instance.new("UIScale");
	sc.Scale = 0.96;
	sc.Parent = el;
	el.BackgroundTransparency = 1;
	lb.TextTransparency = 1;
	(tw:Create(el, TweenInfo.new(0.18), {
		BackgroundTransparency = 0.15
	})):Play();
	(tw:Create(lb, TweenInfo.new(0.18), {
		TextTransparency = 0
	})):Play();
	(tw:Create(sc, TweenInfo.new(0.18), {
		Scale = 1
	})):Play();
	sizeCanvas();
end;
local minimized = false;
local fullS = fr.Size;
local miniHeight = isMobile and 58 or 48;
local miniS = UDim2.new(frameScaleX, 0, 0, miniHeight);
local function setMin(s)
	minimized = s;
	if minimized then
		mini.Text = "V";
		(tw:Create(fr, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = miniS
		})):Play();
		(tw:Create(fst, TweenInfo.new(0.2), {
			Transparency = 1
		})):Play();
		(tw:Create(mini, TweenInfo.new(0.2), {
			Rotation = 180
		})):Play();
		(tw:Create(rc, TweenInfo.new(0.2), {
			BackgroundTransparency = 1
		})):Play();
		(tw:Create(sr, TweenInfo.new(0.2), {
			BackgroundTransparency = 1
		})):Play();
	else
		mini.Text = "^";
		(tw:Create(fr, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = fullS
		})):Play();
		(tw:Create(fst, TweenInfo.new(0.2), {
			Transparency = 0.35
		})):Play();
		(tw:Create(mini, TweenInfo.new(0.2), {
			Rotation = 0
		})):Play();
		(tw:Create(rc, TweenInfo.new(0.2), {
			BackgroundTransparency = 0
		})):Play();
		(tw:Create(sr, TweenInfo.new(0.2), {
			BackgroundTransparency = 0
		})):Play();
	end;
	task.delay(0.3, clampFrameWithinViewport);
end;
mini.MouseButton1Click:Connect(function()
	setMin(not minimized);
end);
cls.MouseButton1Click:Connect(function()
	(tw:Create(fr, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1,
		Size = fr.Size - UDim2.new(0, 12, 0, 12)
	})):Play();
	task.delay(0.2, function()
		sg:Destroy();
	end);
end);
sbox.Focused:Connect(function()
	(tw:Create(sLbl, TweenInfo.new(0.15), {
		TextColor3 = col.ac
	})):Play();
	(tw:Create(srs, TweenInfo.new(0.15), {
		Transparency = 0.1
	})):Play();
end);
sbox.FocusLost:Connect(function()
	(tw:Create(sLbl, TweenInfo.new(0.2), {
		TextColor3 = col.td
	})):Play();
	(tw:Create(srs, TweenInfo.new(0.2), {
		Transparency = 0.25
	})):Play();
end);
local function mkCard(i, d)
	local t = d.title or d.name or "Untitled Script";
	local rw = eng == "ScriptBlox" and d.script or d.rawScript or d.scriptLink or d.raw or "";
	local v = tostring(d.views or d.viewCount or 0);
	local likes = tostring(d.likeCount or 0);
	local keyFlag = eng == "ScriptBlox" and d.key or d.keySystem;
	local scriptType = d.scriptType or "Free";
	local verified = d.verified and "Verified" or "Unverified";
	local status = d.isPatched and "Patched" or "Working";
	local isUniversal = d.isUniversal == true or d.universal == true;
	local mobileStatus;
	if eng == "RScripts" then
		mobileStatus = d.mobileReady == true and "Mobile Ready" or d.mobileReady == false and "PC Only" or "Unknown Platform";
	end;
	local lastUpdated = d.lastBump or d.updatedAt or d.createdAt or "";
	if lastUpdated ~= "" then
		lastUpdated = lastUpdated:match("%d%d%d%d%-%d%d%-%d%d") or lastUpdated:sub(1, 10);
	end;
	local placeSourceId;
	if not isUniversal then
		if eng == "ScriptBlox" then
			placeSourceId = d.game and d.game.gameId;
		else
			placeSourceId = d.game and (d.game.placeId or d.game.gameLink and d.game.gameLink:match("/games/(%d+)"));
		end;
	end;
	local placeId = tonumber(placeSourceId);
	local hasPlaceId = placeId and placeId > 0;
	local gameName;
	if not isUniversal then
		gameName = hasPlaceId and (eng == "ScriptBlox" and (d.game and d.game.name) or d.game and d.game.title) or t;
		if not gameName or gameName == "" then
			gameName = t;
		end;
	end;
	local displayGameId = hasPlaceId and tostring(placeId) or nil;
	local c = Instance.new("Frame");
	c.Name = "Card" .. i;
	c.BackgroundColor3 = col.bg;
	c.BorderSizePixel = 0;
	c.LayoutOrder = i;
	c.ClipsDescendants = true;
	c.Parent = sf;
	if isMobile then
		c.Size = UDim2.new(1, 0, 0, 0);
		c.AutomaticSize = Enum.AutomaticSize.Y;
	else
		c.Size = UDim2.new(1, 0, 1, 0);
	end;
	local cc = Instance.new("UICorner");
	cc.CornerRadius = UDim.new(0, 10);
	cc.Parent = c;
	local cs = Instance.new("UIStroke");
	cs.Color = Color3.fromRGB(70, 75, 85);
	cs.Transparency = 0.35;
	cs.Thickness = 1;
	cs.Parent = c;
	c.MouseEnter:Connect(function()
		(tw:Create(cs, TweenInfo.new(0.12), {
			Transparency = 0.15
		})):Play();
	end);
	c.MouseLeave:Connect(function()
		(tw:Create(cs, TweenInfo.new(0.12), {
			Transparency = 0.35
		})):Play();
	end);
	local remoteImageUrl;
	if eng == "ScriptBlox" then
		remoteImageUrl = resolveScriptBloxImage(d);
	else
		remoteImageUrl = resolveRScriptsImage(d);
	end;
	local coverHeight = 108;
	local coverImage;
	local usingCustomCover = false;
	local sourceUrl = remoteImageUrl;
	if not sourceUrl and hasPlaceId then
		sourceUrl = buildRobloxThumbnail(placeId);
	end;
	if sourceUrl then
		local custom = downloadImageAsset(sourceUrl);
		if custom then
			coverImage = custom;
			usingCustomCover = true;
		else
			coverImage = sourceUrl;
			usingCustomCover = false;
		end;
	end;
	local showCover = coverImage ~= nil;
	if showCover then
		local cover = Instance.new("ImageLabel");
		cover.Size = UDim2.new(1, 0, 0, coverHeight);
		cover.Position = UDim2.new(0, 0, 0, 0);
		cover.BackgroundColor3 = Color3.fromRGB(12, 14, 22);
		cover.BorderSizePixel = 0;
		cover.Image = coverImage or "";
		cover.ImageTransparency = coverImage and 0 or 1;
		cover.ScaleType = Enum.ScaleType.Crop;
		cover.ClipsDescendants = true;
		cover.Parent = c;
		local coverCorner = Instance.new("UICorner");
		coverCorner.CornerRadius = UDim.new(0, 10);
		coverCorner.Parent = cover;
		local coverOverlay = Instance.new("Frame");
		coverOverlay.Size = UDim2.new(1, 0, 1, 0);
		coverOverlay.BackgroundColor3 = Color3.new(0, 0, 0);
		coverOverlay.BackgroundTransparency = 0.25;
		coverOverlay.Parent = cover;
		local grad = Instance.new("UIGradient");
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
		});
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 0.8)
		});
		grad.Rotation = 90;
		grad.Parent = coverOverlay;
		if not isUniversal and gameName and gameName ~= "" then
			local gameBadge = Instance.new("TextLabel");
			gameBadge.Size = UDim2.new(1, -24, 0, 26);
			gameBadge.Position = UDim2.new(0, 12, 1, -38);
			gameBadge.BackgroundTransparency = 1;
			gameBadge.Font = Enum.Font.GothamSemibold;
			gameBadge.TextSize = 14;
			gameBadge.TextXAlignment = Enum.TextXAlignment.Left;
			gameBadge.TextColor3 = col.tx;
			gameBadge.Text = ("Game: %s"):format(gameName);
			gameBadge.Parent = cover;
			if displayGameId then
				local gameIdLabel = Instance.new("TextLabel");
				gameIdLabel.Size = UDim2.new(1, -24, 0, 18);
				gameIdLabel.Position = UDim2.new(0, 12, 1, -18);
				gameIdLabel.BackgroundTransparency = 1;
				gameIdLabel.Font = Enum.Font.Code;
				gameIdLabel.TextSize = 12;
				gameIdLabel.TextXAlignment = Enum.TextXAlignment.Left;
				gameIdLabel.TextColor3 = col.td;
				gameIdLabel.Text = ("ID: %s"):format(displayGameId);
				gameIdLabel.Parent = cover;
			end;
		end;
		if not usingCustomCover then
			tryFetchPlaceIcon(displayGameId, cover);
		end;
	end;
	local bodyOffset = showCover and coverHeight + 12 or 12;
	local textContent = Instance.new("Frame");
	textContent.Size = UDim2.new(1, -24, 0, 0);
	textContent.AutomaticSize = Enum.AutomaticSize.Y;
	if showCover then
		textContent.AnchorPoint = Vector2.new(0, 0);
		textContent.Position = UDim2.new(0, 12, 0, bodyOffset);
	else
		textContent.AnchorPoint = Vector2.new(0, 0.5);
		textContent.Position = UDim2.new(0, 12, 0.5, 0);
	end;
	textContent.BackgroundTransparency = 1;
	textContent.ClipsDescendants = true;
	textContent.AutomaticSize = Enum.AutomaticSize.Y;
	textContent.Parent = c;
	local textLayout = Instance.new("UIListLayout");
	textLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	textLayout.Padding = UDim.new(0, 6);
	textLayout.Parent = textContent;
	local tl = Instance.new("TextLabel");
	tl.Size = UDim2.new(1, 0, 0, 0);
	tl.AutomaticSize = Enum.AutomaticSize.Y;
	tl.BackgroundTransparency = 1;
	tl.Font = Enum.Font.GothamBold;
	tl.Text = tostring(t);
	tl.TextColor3 = col.tx;
	tl.TextSize = 14;
	tl.TextXAlignment = Enum.TextXAlignment.Left;
	tl.TextWrapped = true;
	tl.ZIndex = 2;
	tl.LayoutOrder = 1;
	tl.Parent = textContent;
	local inf = Instance.new("TextLabel");
	inf.Size = UDim2.new(1, 0, 0, isMobile and 72 or 64);
	inf.BackgroundTransparency = 1;
	inf.Font = Enum.Font.Gotham;
	inf.TextWrapped = true;
	inf.TextTruncate = Enum.TextTruncate.AtEnd;
	inf.TextColor3 = col.td;
	inf.TextSize = 12;
	inf.TextXAlignment = Enum.TextXAlignment.Left;
	inf.ZIndex = 2;
	inf.LayoutOrder = 2;
	local infoLines = {};
	if not isUniversal and displayGameId and gameName and gameName ~= "" then
		table.insert(infoLines, ("Game: %s (ID %s)"):format(gameName, displayGameId));
	elseif isUniversal then
		table.insert(infoLines, "Scope: Universal");
	end;
	table.insert(infoLines, ("Type: %s | %s | Key: %s"):format(scriptType, verified, keyFlag and "Key" or "No Key"));
	if eng == "ScriptBlox" then
		table.insert(infoLines, ("Status: %s | Views: %s | Likes: %s"):format(status, v, likes));
	else
		table.insert(infoLines, ("Status: %s | %s | Views: %s | Likes: %s"):format(status, mobileStatus or "Platform Unknown", v, likes));
		table.insert(infoLines, ("Paid: %s"):format(d.paid and "Paid" or "Free"));
		if d.description and d.description ~= "" then
			local desc = d.description:gsub("%c", " ");
			if #desc > 90 then
				desc = desc:sub(1, 87) .. "...";
			end;
			table.insert(infoLines, ("Desc: %s"):format(desc));
		end;
	end;
	if lastUpdated ~= "" then
		table.insert(infoLines, ("Updated: %s"):format(lastUpdated));
	end;
	if eng == "RScripts" and d.discord then
		table.insert(infoLines, ("Discord: %s"):format(d.discord));
	end;
	inf.Text = table.concat(infoLines, "\n");
	inf.Parent = textContent;
	local canCopy = setclipboard ~= nil;
	local hasDiscord = d.discord and setclipboard;
	local btnCount = 1;
	if canCopy then
		btnCount += 1;
	end;
	if hasDiscord then
		btnCount += 1;
	end;
	local rowH = isMobile and btnCount * 30 + (btnCount - 1) * 4 or 30;
	local row = Instance.new("Frame");
	row.BackgroundTransparency = 1;
	row.Size = UDim2.new(1, 0, 0, rowH);
	row.ZIndex = 2;
	row.LayoutOrder = 3;
	row.Parent = textContent;
	local rl = Instance.new("UIListLayout");
	rl.FillDirection = isMobile and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal;
	rl.HorizontalAlignment = Enum.HorizontalAlignment.Left;
	rl.VerticalAlignment = Enum.VerticalAlignment.Center;
	rl.Padding = UDim.new(0, isMobile and 4 or 8);
	rl.SortOrder = Enum.SortOrder.LayoutOrder;
	rl.Parent = row;
	local function mkB(txt, bg)
		local b = Instance.new("TextButton");
		b.Size = isMobile and UDim2.new(1, 0, 0, 30) or UDim2.new(0, 104, 0, 30);
		b.BackgroundColor3 = bg;
		b.Text = txt;
		b.TextColor3 = col.tx;
		b.TextSize = 13;
		b.Font = Enum.Font.GothamSemibold;
		b.AutoButtonColor = false;
		b.Parent = row;
		local bc = Instance.new("UICorner");
		bc.CornerRadius = UDim.new(0, 8);
		bc.Parent = b;
		btnAnim(b, bg, bg:Lerp(Color3.new(1, 1, 1), 0.12));
		return b;
	end;
	local ex = mkB("Run", col.su);
	local cp = canCopy and mkB("Copy", Color3.fromRGB(57, 63, 75)) or nil;
	local dc = hasDiscord and mkB("Discord", Color3.fromRGB(28, 116, 224)) or nil;
	ex.MouseButton1Click:Connect(function()
		pcall(function()
			if eng == "ScriptBlox" then
				(loadstring(rw))();
			else
				(loadstring(game:HttpGet(rw)))();
			end;
		end);
		toast("Executed script", col.tx);
	end);
	if cp then
		cp.MouseButton1Click:Connect(function()
			pcall(function()
				if eng == "ScriptBlox" then
					setclipboard(rw);
				else
					setclipboard(game:HttpGet(rw));
				end;
			end);
			cp.Text = "Copied";
			(tw:Create(cp, TweenInfo.new(0.12), {
				BackgroundColor3 = Color3.fromRGB(76, 82, 96)
			})):Play();
			task.delay(0.9, function()
				cp.Text = "Copy";
				(tw:Create(cp, TweenInfo.new(0.12), {
					BackgroundColor3 = Color3.fromRGB(57, 63, 75)
				})):Play();
			end);
		end);
	end;
	if dc then
		dc.MouseButton1Click:Connect(function()
			pcall(function()
				setclipboard(d.discord);
			end);
			dc.Text = "Copied";
			task.delay(0.9, function()
				dc.Text = "Discord";
			end);
		end);
	end;
	local sca = Instance.new("UIScale");
	sca.Scale = 0.95;
	sca.Parent = c;
	c.BackgroundTransparency = 1;
	tl.TextTransparency = 1;
	inf.TextTransparency = 1;
	(tw:Create(c, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	})):Play();
	(tw:Create(sca, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Scale = 1
	})):Play();
	(tw:Create(tl, TweenInfo.new(0.18), {
		TextTransparency = 0
	})):Play();
	(tw:Create(inf, TweenInfo.new(0.18), {
		TextTransparency = 0
	})):Play();
end;
local function finishSearch()
	spin(false);
	go.Text = "Search";
	go.Active = true;
	searching = false;
	updatePageControls();
end;
local fetch;
local function runSearchFromInput(forceTrending)
	if searching then
		return;
	end;
	local raw = sbox.Text or "";
	raw = (raw:gsub("^%s+", "")):gsub("%s+$", "");
	if raw ~= "" then
		fetch(raw, false, 1);
		return true;
	elseif eng == "ScriptBlox" then
		fetch("", forceTrending == false and false or true, 1);
		return true;
	elseif eng == "RScripts" then
		fetch("", false, 1);
		return true;
	end;
	return false;
end;
function fetch(searchText, trending, page)
	if searching then
		return;
	end;
	clearImageCache();
	local supportsTrending = eng == "ScriptBlox";
	trending = supportsTrending and trending == true or false;
	page = math.max(tonumber(page) or 1, 1);
	searchText = searchText or "";
	pagination.query = searchText;
	pagination.trending = trending;
	pagination.current = page;
	pagination.hasResults = false;
	updatePageControls();
	searching = true;
	updatePageControls();
	clearAll(true);
	skeleton(4);
	spin(true);
	go.Text = "Searching...";
	go.Active = false;
	local encoded = hs:UrlEncode(searchText);
	local url;
	if eng == "RScripts" then
		url = string.format("https://rscripts.net/api/v2/scripts?page=%d&orderBy=date&sort=desc", page);
		if searchText ~= "" then
			url = url .. "&q=" .. encoded;
		end;
	elseif trending then
		url = string.format("%s/api/script/fetch?page=%d", SCRIPTBLOX_BASE, page);
	else
		url = string.format("%s/api/script/search?q=%s&page=%d", SCRIPTBLOX_BASE, encoded, page);
	end;
	local ok, res = pcall(function()
		return rq({
			Url = url,
			Method = "GET"
		});
	end);
	clearAll(false);
	if not ok or (not res) or (not res.Body) then
		mkMsg("Request failed", col.er);
		finishSearch();
		sizeCanvas();
		return;
	end;
	local ok2, dec = pcall(function()
		return hs:JSONDecode(res.Body);
	end);
	if not ok2 or (not dec) then
		mkMsg("Invalid response", col.er);
		finishSearch();
		sizeCanvas();
		return;
	end;
	local data;
	local totalPages = 1;
	if eng == "RScripts" then
		data = dec.scripts;
		totalPages = dec.info and dec.info.maxPages or 1;
	else
		local result = dec.result or {};
		data = result.scripts;
		totalPages = result.totalPages or 1;
	end;
	pagination.total = math.max(totalPages or 1, 1);
	if not data or #data == 0 then
		mkMsg("No scripts found", col.wa);
		finishSearch();
		sizeCanvas();
		return;
	end;
	pagination.hasResults = true;
	for i, d in ipairs(data) do
		mkCard(i, d);
		task.wait(0.02);
	end;
	finishSearch();
	sizeCanvas();
end;
engb.MouseButton1Click:Connect(function()
	if eng == "ScriptBlox" then
		eng = "RScripts";
		engb.Text = "Engine: RScripts";
		sbox.PlaceholderText = "Search for scripts (rscripts.net)";
		(tw:Create(engb, TweenInfo.new(0.18), {
			BackgroundColor3 = Color3.fromRGB(45, 49, 58)
		})):Play();
		toast("Switched to RScripts", col.tx);
	else
		eng = "ScriptBlox";
		engb.Text = "Engine: ScriptBlox";
		sbox.PlaceholderText = "Search for scripts (scriptblox.com)";
		(tw:Create(engb, TweenInfo.new(0.18), {
			BackgroundColor3 = col.bg
		})):Play();
		toast("Switched to ScriptBlox", col.tx);
	end;
	resetPagination(true);
end);
go.MouseButton1Click:Connect(function()
	runSearchFromInput();
end);
sbox.FocusLost:Connect(function(enter)
	if enter then
		runSearchFromInput();
	end;
end);
local function requestPage(targetPage)
	if searching then
		return;
	end;
	if eng ~= "ScriptBlox" and eng ~= "RScripts" then
		return;
	end;
	if not pagination.hasResults then
		return;
	end;
	local total = math.max(pagination.total, 1);
	if targetPage < 1 then
		targetPage = 1;
	end;
	if targetPage > total then
		targetPage = total;
	end;
	if targetPage == pagination.current then
		return;
	end;
	fetch(pagination.query, pagination.trending, targetPage);
end;
firstBtn.MouseButton1Click:Connect(function()
	requestPage(1);
end);
prevBtn.MouseButton1Click:Connect(function()
	requestPage(pagination.current - 1);
end);
nextBtn.MouseButton1Click:Connect(function()
	requestPage(pagination.current + 1);
end);
lastBtn.MouseButton1Click:Connect(function()
	requestPage(pagination.total);
end);
local drag, dIn, dStart, start;
local function up(i)
	local d = i.Position - dStart;
	fr.Position = UDim2.new(start.X.Scale, start.X.Offset + d.X, start.Y.Scale, start.Y.Offset + d.Y);
end;
top.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag = true;
		autoCenter = false;
		dStart = i.Position;
		start = fr.Position;
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				drag = false;
				clampFrameWithinViewport();
			end;
		end);
	end;
end);
top.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		dIn = i;
	end;
end);
ui.InputChanged:Connect(function(i)
	if i == dIn and drag then
		up(i);
	end;
end);
local openS = Instance.new("UIScale");
openS.Scale = 0.9;
openS.Parent = fr;
fr.BackgroundTransparency = 1;
(tw:Create(openS, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Scale = 1
})):Play();
(tw:Create(fr, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	BackgroundTransparency = 0
})):Play();
