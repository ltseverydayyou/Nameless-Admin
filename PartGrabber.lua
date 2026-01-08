if (getgenv()).prtGrabLoaded then
	return print("Part Grabber is already running");
end;
(getgenv()).prtGrabLoaded = true;
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
local function ProtectGui(g)
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
local ts = Svc("TweenService");
local uis = Svc("UserInputService");
local gsv = Svc("GuiService");
local plrs = Svc("Players");
local lp = plrs.LocalPlayer;
local IsOnMobile = (function()
	local platform = uis:GetPlatform();
	if platform == Enum.Platform.IOS or platform == Enum.Platform.Android or platform == Enum.Platform.AndroidTV or platform == Enum.Platform.Chromecast or platform == Enum.Platform.MetaOS then
		return true;
	end;
	if platform == Enum.Platform.None then
		return uis.TouchEnabled and (not (uis.KeyboardEnabled or uis.MouseEnabled));
	end;
	return false;
end)();
local BTN_H = IsOnMobile and 28 or 34;
local BTN_TEXT = IsOnMobile and 12 or 13;
local _conns = {};
local function track(c)
	if c then
		table.insert(_conns, c);
	end;
	return c;
end;
local function discAll()
	for i = #_conns, 1, -1 do
		local c = _conns[i];
		if c and c.Disconnect then
			pcall(function()
				c:Disconnect();
			end);
		end;
		_conns[i] = nil;
	end;
end;
local propConns = {};
local function clearPropConns()
	for i = #propConns, 1, -1 do
		local c = propConns[i];
		if c and c.Disconnect then
			pcall(function()
				c:Disconnect();
			end);
		end;
		propConns[i] = nil;
	end;
end;
local sg = Instance.new("ScreenGui");
sg.Name = "PartGrabberX";
sg.ResetOnSpawn = false;
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
ProtectGui(sg);
local ti_fast = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local ti_med = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
local ti_long = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true);
local TOPH = 40;
local win = Instance.new("Frame");
win.Name = "Win";
win.Size = UDim2.new(0, 420, 0, 320);
win.Position = UDim2.new(0.5, -210, 0.5, -160);
win.BackgroundColor3 = Color3.fromRGB(5, 5, 5);
win.BorderSizePixel = 0;
win.Parent = sg;
local winCorner = Instance.new("UICorner");
winCorner.CornerRadius = UDim.new(0, 14);
winCorner.Parent = win;
local winStroke = Instance.new("UIStroke");
winStroke.Thickness = 1.5;
winStroke.Color = Color3.fromRGB(210, 210, 210);
winStroke.Transparency = 0.65;
winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
winStroke.Parent = win;
local sh = Instance.new("ImageLabel");
sh.Name = "Shadow";
sh.BackgroundTransparency = 1;
sh.Image = "rbxassetid://5028857084";
sh.ScaleType = Enum.ScaleType.Slice;
sh.SliceCenter = Rect.new(24, 24, 276, 276);
sh.ImageTransparency = 0.6;
sh.Size = UDim2.new(1, 52, 1, 52);
sh.Position = UDim2.new(0, -26, 0, -26);
sh.ZIndex = 0;
sh.Parent = win;
local winScale = Instance.new("UIScale");
winScale.Scale = 0.92;
winScale.Parent = win;
local uiScale = Instance.new("UIScale");
uiScale.Scale = 1;
uiScale.Parent = win;
local top = Instance.new("Frame");
top.Name = "Top";
top.Size = UDim2.new(1, 0, 0, TOPH);
top.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
top.BorderSizePixel = 0;
top.Parent = win;
top.Active = true;
top.Selectable = true;
local topCorner = Instance.new("UICorner");
topCorner.CornerRadius = UDim.new(0, 14);
topCorner.Parent = top;
local topLine = Instance.new("Frame");
topLine.Name = "TopLine";
topLine.AnchorPoint = Vector2.new(0.5, 1);
topLine.Position = UDim2.new(0.5, 0, 1, 0);
topLine.Size = UDim2.new(1, 0, 0, 1);
topLine.BorderSizePixel = 0;
topLine.BackgroundColor3 = Color3.fromRGB(40, 40, 40);
topLine.Parent = top;
local titleWrap = Instance.new("Frame");
titleWrap.Name = "TitleWrap";
titleWrap.BackgroundTransparency = 1;
titleWrap.Size = UDim2.new(1, -170, 1, 0);
titleWrap.Position = UDim2.new(0, 12, 0, 0);
titleWrap.Parent = top;
local titleLine = Instance.new("Frame");
titleLine.Name = "TitleLine";
titleLine.AnchorPoint = Vector2.new(0, 0.5);
titleLine.Position = UDim2.new(0, 0, 0.5, 0);
titleLine.Size = UDim2.new(0, 2, 0, 18);
titleLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
titleLine.BorderSizePixel = 0;
titleLine.Parent = titleWrap;
local title = Instance.new("TextLabel");
title.Name = "Title";
title.Text = "Part Grabber X";
title.Font = Enum.Font.GothamBold;
title.TextColor3 = Color3.fromRGB(235, 235, 235);
title.TextSize = 16;
title.BackgroundTransparency = 1;
title.Size = UDim2.new(1, -18, 1, 0);
title.Position = UDim2.new(0, 10, 0, 0);
title.TextXAlignment = Enum.TextXAlignment.Left;
title.Parent = titleWrap;
local titleGrad = Instance.new("UIGradient");
titleGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 180, 180)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
});
titleGrad.Rotation = 0;
titleGrad.Parent = title;
local topBtns = Instance.new("Frame");
topBtns.Name = "TopBtns";
topBtns.BackgroundTransparency = 1;
topBtns.Size = UDim2.new(0, 190, 1, -10);
topBtns.Position = UDim2.new(1, -198, 0, 5);
topBtns.Parent = top;
local btnLayout = Instance.new("UIListLayout");
btnLayout.FillDirection = Enum.FillDirection.Horizontal;
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right;
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center;
btnLayout.Padding = UDim.new(0, 6);
btnLayout.Parent = topBtns;
local function mkBtn(txt, col, parent, h)
	local b = Instance.new("TextButton");
	b.Name = txt:gsub("%s+", "");
	b.Text = txt;
	b.Font = Enum.Font.GothamSemibold;
	b.TextSize = BTN_TEXT;
	b.TextColor3 = Color3.fromRGB(235, 235, 235);
	b.BackgroundColor3 = col;
	b.BackgroundTransparency = 0.15;
	b.BorderSizePixel = 0;
	b.AutoButtonColor = false;
	b.Size = UDim2.new(1, 0, 0, h or BTN_H);
	b.Parent = parent;
	local c = Instance.new("UICorner");
	c.CornerRadius = UDim.new(0, 8);
	c.Parent = b;
	local st = Instance.new("UIStroke");
	st.Thickness = 1;
	st.Color = Color3.fromRGB(255, 255, 255);
	st.Transparency = 0.8;
	st.Parent = b;
	local sc = Instance.new("UIScale");
	sc.Scale = 1;
	sc.Parent = b;
	if not IsOnMobile then
		track(b.MouseEnter:Connect(function()
			(ts:Create(b, ti_fast, {
				BackgroundTransparency = 0.05
			})):Play();
			(ts:Create(st, ti_fast, {
				Transparency = 0.4
			})):Play();
		end));
		track(b.MouseLeave:Connect(function()
			(ts:Create(b, ti_fast, {
				BackgroundTransparency = 0.15
			})):Play();
			(ts:Create(st, ti_fast, {
				Transparency = 0.8
			})):Play();
		end));
	end;
	track(b.MouseButton1Down:Connect(function()
		(ts:Create(sc, ti_fast, {
			Scale = 0.96
		})):Play();
	end));
	track(b.MouseButton1Up:Connect(function()
		(ts:Create(sc, ti_fast, {
			Scale = 1
		})):Play();
	end));
	return b;
end;
local pathMode = "dot";
local function pathModeLabel()
	if pathMode == "dot" then
		return "Path: Dot";
	elseif pathMode == "find" then
		return "Path: Find";
	else
		return "Path: Wait";
	end;
end;
local btnPathMode = mkBtn(pathModeLabel(), Color3.fromRGB(10, 10, 10), topBtns, 30);
btnPathMode.Size = UDim2.new(0, 70, 0, 30);
local btnMin = mkBtn("-", Color3.fromRGB(15, 15, 15), topBtns, 30);
btnMin.Size = UDim2.new(0, 40, 0, 30);
btnMin.TextScaled = true;
local btnExit = mkBtn("×", Color3.fromRGB(10, 10, 10), topBtns, 30);
btnExit.Size = UDim2.new(0, 40, 0, 30);
btnExit.TextScaled = true;
local body = Instance.new("Frame");
body.Name = "Body";
body.Size = UDim2.new(1, -22, 1, -(TOPH + 28));
body.Position = UDim2.new(0, 11, 0, TOPH + 14);
body.BackgroundColor3 = Color3.fromRGB(8, 8, 8);
body.BorderSizePixel = 0;
body.ClipsDescendants = true;
body.Parent = win;
local bodyCorner = Instance.new("UICorner");
bodyCorner.CornerRadius = UDim.new(0, 12);
bodyCorner.Parent = body;
local bodyStroke = Instance.new("UIStroke");
bodyStroke.Thickness = 1;
bodyStroke.Color = Color3.fromRGB(70, 70, 70);
bodyStroke.Transparency = 0.6;
bodyStroke.Parent = body;
local bodyGrad = Instance.new("UIGradient");
bodyGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 6, 6)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 18))
});
bodyGrad.Rotation = 90;
bodyGrad.Parent = body;
local bodyPad = Instance.new("UIPadding");
bodyPad.PaddingTop = UDim.new(0, 8);
bodyPad.PaddingLeft = UDim.new(0, 12);
bodyPad.PaddingRight = UDim.new(0, 12);
bodyPad.PaddingBottom = UDim.new(0, 8);
bodyPad.Parent = body;
local bodyList = Instance.new("UIListLayout");
bodyList.SortOrder = Enum.SortOrder.LayoutOrder;
bodyList.Padding = UDim.new(0, 8);
bodyList.Parent = body;
local headRow = Instance.new("Frame");
headRow.Name = "HeadRow";
headRow.BackgroundTransparency = 1;
headRow.Size = UDim2.new(1, 0, 0, 20);
headRow.LayoutOrder = 1;
headRow.Parent = body;
local headList = Instance.new("UIListLayout");
headList.FillDirection = Enum.FillDirection.Horizontal;
headList.HorizontalAlignment = Enum.HorizontalAlignment.Left;
headList.VerticalAlignment = Enum.VerticalAlignment.Center;
headList.Padding = UDim.new(0, 6);
headList.Parent = headRow;
local dot = Instance.new("Frame");
dot.Name = "Dot";
dot.Size = UDim2.new(0, 10, 0, 10);
dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200);
dot.BorderSizePixel = 0;
dot.Parent = headRow;
local dotCorner = Instance.new("UICorner");
dotCorner.CornerRadius = UDim.new(1, 0);
dotCorner.Parent = dot;
local dotScale = Instance.new("UIScale");
dotScale.Scale = 1;
dotScale.Parent = dot;
(ts:Create(dotScale, ti_long, {
	Scale = 1.15
})):Play();
local lbl = Instance.new("TextLabel");
lbl.Name = "Status";
lbl.Text = "Tap/Click a 3D part to select";
lbl.Font = Enum.Font.GothamSemibold;
lbl.Size = UDim2.new(1, -18, 1, 0);
lbl.TextColor3 = Color3.fromRGB(190, 190, 190);
lbl.TextSize = 12;
lbl.BackgroundTransparency = 1;
lbl.TextXAlignment = Enum.TextXAlignment.Left;
lbl.Parent = headRow;
local sep = Instance.new("Frame");
sep.Name = "Sep";
sep.BackgroundColor3 = Color3.fromRGB(28, 28, 28);
sep.BorderSizePixel = 0;
sep.Size = UDim2.new(1, 0, 0, 1);
sep.LayoutOrder = 2;
sep.Parent = body;
local pathFrame = Instance.new("Frame");
pathFrame.Name = "PathFrame";
pathFrame.AutomaticSize = Enum.AutomaticSize.None;
pathFrame.Size = UDim2.new(1, 0, 0, 72);
pathFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12);
pathFrame.BorderSizePixel = 0;
pathFrame.LayoutOrder = 3;
pathFrame.Parent = body;
local pfCorner = Instance.new("UICorner");
pfCorner.CornerRadius = UDim.new(0, 10);
pfCorner.Parent = pathFrame;
local pfStroke = Instance.new("UIStroke");
pfStroke.Thickness = 1;
pfStroke.Color = Color3.fromRGB(90, 90, 90);
pfStroke.Transparency = 0.55;
pfStroke.Parent = pathFrame;
local pathPad = Instance.new("UIPadding");
pathPad.PaddingTop = UDim.new(0, 8);
pathPad.PaddingBottom = UDim.new(0, 8);
pathPad.PaddingLeft = UDim.new(0, 8);
pathPad.PaddingRight = UDim.new(0, 8);
pathPad.Parent = pathFrame;
local pathLbl = Instance.new("TextLabel");
pathLbl.Name = "PathLabel";
pathLbl.Text = "Selected path";
pathLbl.Font = Enum.Font.Gotham;
pathLbl.TextColor3 = Color3.fromRGB(150, 150, 150);
pathLbl.TextSize = 11;
pathLbl.BackgroundTransparency = 1;
pathLbl.Size = UDim2.new(1, 0, 0, 16);
pathLbl.TextXAlignment = Enum.TextXAlignment.Left;
pathLbl.Parent = pathFrame;
local pathScroll = Instance.new("ScrollingFrame");
pathScroll.Name = "PathScroll";
pathScroll.BackgroundTransparency = 1;
pathScroll.BorderSizePixel = 0;
pathScroll.Size = UDim2.new(1, 0, 1, -18);
pathScroll.Position = UDim2.new(0, 0, 0, 18);
pathScroll.ScrollBarThickness = 4;
pathScroll.ScrollBarImageColor3 = Color3.fromRGB(220, 220, 220);
pathScroll.ScrollBarImageTransparency = 0.1;
pathScroll.AutomaticCanvasSize = Enum.AutomaticSize.None;
pathScroll.CanvasSize = UDim2.new(0, 0, 0, 0);
pathScroll.ClipsDescendants = true;
pathScroll.ScrollingDirection = Enum.ScrollingDirection.Y;
pathScroll.Active = true;
pathScroll.ScrollingEnabled = true;
pathScroll.Parent = pathFrame;
local pathTxt = Instance.new("TextLabel");
pathTxt.Name = "PathText";
pathTxt.Text = "...";
pathTxt.Font = Enum.Font.Code;
pathTxt.TextWrapped = true;
pathTxt.TextXAlignment = Enum.TextXAlignment.Left;
pathTxt.TextYAlignment = Enum.TextYAlignment.Top;
pathTxt.TextSize = 13;
pathTxt.AutomaticSize = Enum.AutomaticSize.Y;
pathTxt.TextColor3 = Color3.fromRGB(235, 235, 235);
pathTxt.BackgroundTransparency = 1;
pathTxt.Size = UDim2.new(1, 0, 0, 0);
pathTxt.Position = UDim2.new(0, 0, 0, 0);
pathTxt.Parent = pathScroll;
local gridWrap = Instance.new("ScrollingFrame");
gridWrap.Name = "GridWrap";
gridWrap.BackgroundTransparency = 1;
gridWrap.Size = UDim2.new(1, 0, 0, BTN_H * 3 + 8 * 2);
gridWrap.LayoutOrder = 4;
gridWrap.BorderSizePixel = 0;
gridWrap.ScrollBarThickness = 3;
gridWrap.ScrollBarImageColor3 = Color3.fromRGB(220, 220, 220);
gridWrap.ScrollBarImageTransparency = 0.1;
gridWrap.AutomaticSize = Enum.AutomaticSize.None;
gridWrap.AutomaticCanvasSize = Enum.AutomaticSize.None;
gridWrap.CanvasSize = UDim2.new(0, 0, 0, 0);
gridWrap.ClipsDescendants = true;
gridWrap.Parent = body;
local gridPad = Instance.new("UIPadding");
gridPad.PaddingTop = UDim.new(0, 6);
gridPad.Parent = gridWrap;
local grid = Instance.new("UIGridLayout");
grid.CellPadding = UDim2.new(0, 10, 0, 8);
grid.CellSize = UDim2.new(0.5, -5, 0, BTN_H);
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center;
grid.SortOrder = Enum.SortOrder.LayoutOrder;
grid.Parent = gridWrap;
local btnCopy = mkBtn("Copy Path", Color3.fromRGB(10, 10, 10), gridWrap, BTN_H);
local btnToggle = mkBtn("Selection: On", Color3.fromRGB(12, 12, 12), gridWrap, BTN_H);
local btnBring = mkBtn("Bring Part", Color3.fromRGB(10, 10, 10), gridWrap, BTN_H);
local btnColl = mkBtn("CanCollide: ?", Color3.fromRGB(12, 12, 12), gridWrap, BTN_H);
local btnAnch = mkBtn("Anchored: ?", Color3.fromRGB(12, 12, 12), gridWrap, BTN_H);
local btnMass = mkBtn("Massless: ?", Color3.fromRGB(12, 12, 12), gridWrap, BTN_H);
local btnRen = mkBtn("Rename Part", Color3.fromRGB(10, 10, 10), gridWrap, BTN_H);
local btnDel = mkBtn("Delete Part", Color3.fromRGB(5, 5, 5), gridWrap, BTN_H);
local function setPathText(t)
	pathTxt.Text = t or "...";
	task.defer(function()
		local b = pathTxt.TextBounds;
		local needed = b.Y + 4;
		local visible = pathScroll.AbsoluteSize.Y;
		if needed <= 0 then
			pathScroll.CanvasSize = UDim2.new(0, 0, 0, 0);
		else
			pathScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(needed, visible + 1));
		end;
	end);
end;
setPathText("...");
local function updateCanvas()
	local size = grid.AbsoluteContentSize;
	gridWrap.CanvasSize = UDim2.new(0, 0, 0, size.Y + 12);
end;
track((grid:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(updateCanvas));
updateCanvas();
local modal = Instance.new("Frame");
modal.Visible = false;
modal.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
modal.BackgroundTransparency = 0.45;
modal.BorderSizePixel = 0;
modal.Size = UDim2.new(1, 0, 1, 0);
modal.Position = UDim2.new(0, 0, 0, 0);
modal.Parent = win;
modal.ZIndex = 50;
local renBox = Instance.new("Frame");
renBox.Size = UDim2.new(0, 320, 0, 110);
renBox.Position = UDim2.new(0.5, -160, 0.5, -55);
renBox.BackgroundColor3 = Color3.fromRGB(8, 8, 8);
renBox.BorderSizePixel = 0;
renBox.Parent = modal;
renBox.ZIndex = 51;
local rbCorner = Instance.new("UICorner");
rbCorner.CornerRadius = UDim.new(0, 12);
rbCorner.Parent = renBox;
local rbStroke = Instance.new("UIStroke");
rbStroke.Thickness = 1.5;
rbStroke.Color = Color3.fromRGB(230, 230, 230);
rbStroke.Transparency = 0.35;
rbStroke.Parent = renBox;
local rbScale = Instance.new("UIScale");
rbScale.Scale = 0.9;
rbScale.Parent = renBox;
local rbTitle = Instance.new("TextLabel");
rbTitle.BackgroundTransparency = 1;
rbTitle.Text = "Rename Part";
rbTitle.Font = Enum.Font.GothamBold;
rbTitle.TextSize = 15;
rbTitle.TextColor3 = Color3.fromRGB(235, 235, 235);
rbTitle.Size = UDim2.new(1, -20, 0, 22);
rbTitle.Position = UDim2.new(0, 10, 0, 10);
rbTitle.ZIndex = 51;
rbTitle.TextXAlignment = Enum.TextXAlignment.Left;
rbTitle.Parent = renBox;
local rbInput = Instance.new("TextBox");
rbInput.Size = UDim2.new(1, -20, 0, 30);
rbInput.Position = UDim2.new(0, 10, 0, 48);
rbInput.Font = Enum.Font.Gotham;
rbInput.TextSize = 14;
rbInput.Text = "";
rbInput.ClearTextOnFocus = false;
rbInput.TextColor3 = Color3.fromRGB(235, 235, 235);
rbInput.PlaceholderText = "Enter new name";
rbInput.BackgroundColor3 = Color3.fromRGB(14, 14, 14);
rbInput.BorderSizePixel = 0;
rbInput.Parent = renBox;
rbInput.ZIndex = 51;
local rbInputCorner = Instance.new("UICorner");
rbInputCorner.CornerRadius = UDim.new(0, 8);
rbInputCorner.Parent = rbInput;
local rbRow = Instance.new("Frame");
rbRow.BackgroundTransparency = 1;
rbRow.Size = UDim2.new(1, -20, 0, 28);
rbRow.Position = UDim2.new(0, 10, 1, -36);
rbRow.ZIndex = 51;
rbRow.Parent = renBox;
local rbGrid = Instance.new("UIGridLayout");
rbGrid.CellPadding = UDim2.new(0, 8, 0, 0);
rbGrid.CellSize = UDim2.new(0.5, -4, 1, 0);
rbGrid.Parent = rbRow;
local btnSave = mkBtn("Save", Color3.fromRGB(14, 14, 14), rbRow, 28);
btnSave.ZIndex = 52;
local btnCancel = mkBtn("Cancel", Color3.fromRGB(8, 8, 8), rbRow, 28);
btnCancel.ZIndex = 52;
local selObj = nil;
local adorn = nil;
local selOn = true;
local minimized = false;
local dragging = false;
local dragInput = nil;
local dragStart, startPos = nil, nil;
local currentPath = nil;
local function instPath(o)
	if not o then
		return "";
	end;
	local nodes = {};
	local cur = o;
	while cur and cur ~= game do
		table.insert(nodes, 1, cur);
		cur = cur.Parent;
	end;
	if #nodes == 0 then
		return "";
	end;
	local root = nodes[1];
	local path;
	local parent;
	local startIndex = 1;
	if root == workspace then
		path = "workspace";
		parent = workspace;
		startIndex = 2;
	elseif root.Parent == game then
		path = string.format("game:GetService(\"%s\")", root.Name);
		parent = root;
		startIndex = 2;
	else
		path = "game";
		parent = game;
		startIndex = 1;
	end;
	for i = startIndex, #nodes do
		local inst = nodes[i];
		local siblings = parent:GetChildren();
		local sameCount = 0;
		local idxMatch;
		for idx, child in ipairs(siblings) do
			if child.Name == inst.Name and child.ClassName == inst.ClassName then
				sameCount = sameCount + 1;
				if child == inst then
					idxMatch = idx;
				end;
			end;
		end;
		local useIndex = sameCount > 1 and idxMatch ~= nil;
		if useIndex then
			path = path .. ":GetChildren()[" .. idxMatch .. "]";
		else
			local safeName = inst.Name:gsub("\"", "\\\"");
			if pathMode == "dot" and inst.Name:match("^[%a_][%w_]*$") and parent ~= game then
				path = path .. "." .. inst.Name;
			else
				local fn = pathMode == "wait" and "WaitForChild" or "FindFirstChild";
				path = path .. string.format(":%s(\"%s\")", fn, safeName);
			end;
		end;
		parent = inst;
	end;
	return path;
end;
local function setStatus(t, ok)
	lbl.Text = t;
	local c = ok == nil and Color3.fromRGB(190, 190, 190) or (ok and Color3.fromRGB(235, 235, 235) or Color3.fromRGB(150, 150, 150));
	(ts:Create(lbl, ti_fast, {
		TextColor3 = c
	})):Play();
	local dc = ok == nil and Color3.fromRGB(200, 200, 200) or (ok and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(130, 130, 130));
	(ts:Create(dot, ti_fast, {
		BackgroundColor3 = dc
	})):Play();
end;
local function clearAdorn()
	if adorn then
		adorn:Destroy();
		adorn = nil;
	end;
end;
local function showAdorn(pv)
	clearAdorn();
	local f = Instance.new("Folder");
	f.Name = "PGX_Adorn";
	local h = Instance.new("Highlight");
	h.Name = "PGX_Highlight";
	h.Adornee = pv;
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
	h.FillColor = Color3.fromRGB(255, 255, 255);
	h.OutlineColor = Color3.fromRGB(210, 210, 210);
	h.FillTransparency = 0.9;
	h.OutlineTransparency = 0;
	h.Parent = f;
	local sb = Instance.new("SelectionBox");
	sb.Name = "PGX_Select";
	sb.LineThickness = 0.04;
	sb.Color3 = Color3.fromRGB(235, 235, 235);
	sb.Adornee = pv;
	sb.Parent = f;
	local bha = Instance.new("BoxHandleAdornment");
	bha.Name = "PGX_Box";
	bha.AlwaysOnTop = true;
	bha.ZIndex = 10;
	bha.Adornee = pv;
	bha.Color3 = Color3.fromRGB(220, 220, 220);
	bha.Transparency = 0.9;
	if pv:IsA("BasePart") then
		bha.Size = pv.Size;
	end;
	bha.Parent = f;
	f.Parent = pv;
	adorn = f;
end;
local function updCollBtn()
	if selObj and selObj:IsA("BasePart") then
		if selObj.CanCollide then
			btnColl.Text = "CanCollide: On";
			(ts:Create(btnColl, ti_fast, {
				BackgroundColor3 = Color3.fromRGB(230, 230, 230)
			})):Play();
			btnColl.TextColor3 = Color3.fromRGB(0, 0, 0);
		else
			btnColl.Text = "CanCollide: Off";
			(ts:Create(btnColl, ti_fast, {
				BackgroundColor3 = Color3.fromRGB(18, 18, 18)
			})):Play();
			btnColl.TextColor3 = Color3.fromRGB(235, 235, 235);
		end;
	else
		btnColl.Text = "CanCollide: ?";
		(ts:Create(btnColl, ti_fast, {
			BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		})):Play();
		btnColl.TextColor3 = Color3.fromRGB(235, 235, 235);
	end;
end;
local function updAnchBtn()
	if selObj and selObj:IsA("BasePart") then
		if selObj.Anchored then
			btnAnch.Text = "Anchored: On";
			(ts:Create(btnAnch, ti_fast, {
				BackgroundColor3 = Color3.fromRGB(230, 230, 230)
			})):Play();
			btnAnch.TextColor3 = Color3.fromRGB(0, 0, 0);
		else
			btnAnch.Text = "Anchored: Off";
			(ts:Create(btnAnch, ti_fast, {
				BackgroundColor3 = Color3.fromRGB(18, 18, 18)
			})):Play();
			btnAnch.TextColor3 = Color3.fromRGB(235, 235, 235);
		end;
	else
		btnAnch.Text = "Anchored: ?";
		(ts:Create(btnAnch, ti_fast, {
			BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		})):Play();
		btnAnch.TextColor3 = Color3.fromRGB(235, 235, 235);
	end;
end;
local function updMassBtn()
	if selObj and selObj:IsA("BasePart") then
		if selObj.Massless then
			btnMass.Text = "Massless: On";
			(ts:Create(btnMass, ti_fast, {
				BackgroundColor3 = Color3.fromRGB(230, 230, 230)
			})):Play();
			btnMass.TextColor3 = Color3.fromRGB(0, 0, 0);
		else
			btnMass.Text = "Massless: Off";
			(ts:Create(btnMass, ti_fast, {
				BackgroundColor3 = Color3.fromRGB(18, 18, 18)
			})):Play();
			btnMass.TextColor3 = Color3.fromRGB(235, 235, 235);
		end;
	else
		btnMass.Text = "Massless: ?";
		(ts:Create(btnMass, ti_fast, {
			BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		})):Play();
		btnMass.TextColor3 = Color3.fromRGB(235, 235, 235);
	end;
end;
local function updAllBtns()
	updCollBtn();
	updAnchBtn();
	updMassBtn();
end;
local function applySelSignals(p)
	clearPropConns();
	if not p or (not p:IsDescendantOf(game)) then
		return;
	end;
	if p:IsA("BasePart") then
		table.insert(propConns, (p:GetPropertyChangedSignal("CanCollide")):Connect(updCollBtn));
		table.insert(propConns, (p:GetPropertyChangedSignal("Anchored")):Connect(updAnchBtn));
		table.insert(propConns, (p:GetPropertyChangedSignal("Massless")):Connect(updMassBtn));
	end;
	table.insert(propConns, (p:GetPropertyChangedSignal("Name")):Connect(function()
		if selObj == p then
			setStatus("Part selected: " .. p.Name, true);
			currentPath = instPath(p);
			pathTxt.Text = currentPath;
		end;
	end));
	table.insert(propConns, p.AncestryChanged:Connect(function(_, parent)
		if not p:IsDescendantOf(game) then
			setSel(nil);
		end;
	end));
end;
function setSel(p)
	selObj = p;
	if p then
		currentPath = instPath(p);
		setPathText(currentPath);
		setStatus("Part selected: " .. p.Name, true);
		showAdorn(p);
		updAllBtns();
		applySelSignals(p);
		(ts:Create(pathFrame, ti_fast, {
			BackgroundColor3 = Color3.fromRGB(16, 16, 16)
		})):Play();
		(ts:Create(pfStroke, ti_fast, {
			Transparency = 0.3
		})):Play();
	else
		currentPath = nil;
		setPathText("...");
		setStatus("No part selected", false);
		clearAdorn();
		clearPropConns();
		updAllBtns();
		(ts:Create(pathFrame, ti_fast, {
			BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		})):Play();
		(ts:Create(pfStroke, ti_fast, {
			Transparency = 0.55
		})):Play();
	end;
end;
local function onWin(p)
	local inset = gsv:GetGuiInset();
	local v = Vector2.new(p.X - inset.X, p.Y - inset.Y);
	local a = win.AbsolutePosition;
	local s = win.AbsoluteSize;
	return v.X >= a.X and v.X <= a.X + s.X and v.Y >= a.Y and v.Y <= a.Y + s.Y;
end;
local function raycastPick()
	local cam = workspace.CurrentCamera;
	if not cam then
		return nil;
	end;
	local pos = uis:GetMouseLocation();
	local ray = cam:ViewportPointToRay(pos.X, pos.Y);
	local params = RaycastParams.new();
	params.FilterType = Enum.RaycastFilterType.Exclude;
	local ch = lp.Character;
	if ch then
		params.FilterDescendantsInstances = {
			ch
		};
	end;
	params.IgnoreWater = false;
	local res = workspace:Raycast(ray.Origin, ray.Direction * 10000, params);
	return res and res.Instance or nil;
end;
local function softPick()
	local cam = workspace.CurrentCamera;
	if not cam then
		return nil;
	end;
	local pos = uis:GetMouseLocation();
	local ray = cam:ViewportPointToRay(pos.X, pos.Y);
	local op = OverlapParams.new();
	op.FilterType = Enum.RaycastFilterType.Exclude;
	local ch = lp.Character;
	if ch then
		op.FilterDescendantsInstances = {
			ch
		};
	end;
	local best, bestDist;
	for d = 5, 150, 15 do
		local point = ray.Origin + ray.Direction * d;
		local parts = workspace:GetPartBoundsInRadius(point, 3, op);
		for _, pt in ipairs(parts) do
			if pt:IsA("BasePart") then
				local dist = (cam.CFrame.Position - pt.Position).Magnitude;
				if not bestDist or dist < bestDist then
					bestDist = dist;
					best = pt;
				end;
			end;
		end;
	end;
	return best;
end;
local function pick()
	if not selOn then
		return;
	end;
	if dragging then
		return;
	end;
	local pos = uis:GetMouseLocation();
	if onWin(pos) then
		return;
	end;
	local hit = raycastPick();
	if not hit then
		hit = softPick();
	end;
	if hit and hit:IsA("BasePart") then
		setSel(hit);
	else
		setSel(nil);
	end;
end;
local mouseConn, tapConn, uisChangedConn, tbBeganConn, tbChangedConn;
local function bindPick()
	if mouseConn then
		mouseConn:Disconnect();
		mouseConn = nil;
	end;
	if tapConn then
		tapConn:Disconnect();
		tapConn = nil;
	end;
	local m = lp:GetMouse();
	mouseConn = track(m.Button1Down:Connect(pick));
	tapConn = track(uis.TouchTap:Connect(function(touches, processed)
		if processed then
			return;
		end;
		local p = touches and touches[1];
		if p and onWin(p) then
			return;
		end;
		pick();
	end));
end;
local function showRen(d)
	rbInput.Text = d or "";
	modal.BackgroundTransparency = 1;
	renBox.Visible = true;
	modal.Visible = true;
	rbScale.Scale = 0.9;
	(ts:Create(modal, ti_fast, {
		BackgroundTransparency = 0.25
	})):Play();
	(ts:Create(rbScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	})):Play();
	rbInput:CaptureFocus();
end;
local function hideRen()
	(ts:Create(modal, ti_fast, {
		BackgroundTransparency = 1
	})):Play();
	task.delay(0.16, function()
		modal.Visible = false;
		renBox.Visible = false;
	end);
end;
local function baseSize()
	local bw = IsOnMobile and 390 or 420;
	local bh = minimized and 70 or 320;
	return bw, bh;
end;
local function beginDrag(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return;
	end;
	dragging = true;
	dragStart = input.Position;
	startPos = win.Position;
	track(input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			dragging = false;
		end;
	end));
end;
local function updateDrag(input)
	if not dragging then
		return;
	end;
	local d = input.Position - dragStart;
	win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y);
end;
tbBeganConn = track(top.InputBegan:Connect(function(i)
	beginDrag(i);
end));
tbChangedConn = track(top.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		dragInput = i;
	end;
end));
uisChangedConn = track(uis.InputChanged:Connect(function(i)
	if i == dragInput then
		updateDrag(i);
	end;
end));
local function applyScale()
	local cam = workspace.CurrentCamera;
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720);
	local inset = gsv:GetGuiInset();
	local ux = math.max(0, vp.X - inset.X * 2);
	local uy = math.max(0, vp.Y - inset.Y * 2);
	local bw, bh = baseSize();
	local sc = math.min(ux / (bw + 24), uy / (bh + 60));
	local minScale = IsOnMobile and 0.75 or 0.6;
	uiScale.Scale = math.clamp(sc, minScale, 1);
	win.Size = UDim2.new(0, bw, 0, bh);
end;
local function hookViewport()
	local function hookCam(c)
		if not c then
			return;
		end;
		track((c:GetPropertyChangedSignal("ViewportSize")):Connect(applyScale));
	end;
	track((workspace:GetPropertyChangedSignal("CurrentCamera")):Connect(function()
		hookCam(workspace.CurrentCamera);
		applyScale();
	end));
	if workspace.CurrentCamera then
		hookCam(workspace.CurrentCamera);
	end;
	track((sg:GetPropertyChangedSignal("AbsoluteSize")):Connect(applyScale));
end;
btnMin.MouseButton1Click:Connect(function()
	minimized = not minimized;
	local bw, bh = baseSize();
	if minimized then
		local tw = ts:Create(win, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, bw, 0, bh)
		});
		tw.Completed:Connect(function()
			body.Visible = false;
		end);
		tw:Play();
		btnMin.Text = "+";
	else
		body.Visible = true;
		(ts:Create(win, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, bw, 0, bh)
		})):Play();
		btnMin.Text = "-";
	end;
end);
btnExit.MouseButton1Click:Connect(function()
	selOn = false;
	setSel(nil);
	discAll();
	(ts:Create(winScale, ti_fast, {
		Scale = 0.9
	})):Play();
	(ts:Create(win, ti_fast, {
		BackgroundTransparency = 1
	})):Play();
	(ts:Create(winStroke, ti_fast, {
		Transparency = 1
	})):Play();
	task.delay(0.18, function()
		if sg then
			sg:Destroy();
		end;
		(getgenv()).prtGrabLoaded = false;
	end);
end);
btnCopy.MouseButton1Click:Connect(function()
	if currentPath and setclipboard then
		setclipboard(currentPath);
		setStatus("Path copied", true);
	else
		setStatus("No part to copy", false);
	end;
end);
btnToggle.MouseButton1Click:Connect(function()
	selOn = not selOn;
	if selOn then
		btnToggle.Text = "Selection: On";
		(ts:Create(btnToggle, ti_fast, {
			BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		})):Play();
		setStatus("Selection enabled", true);
	else
		btnToggle.Text = "Selection: Off";
		(ts:Create(btnToggle, ti_fast, {
			BackgroundColor3 = Color3.fromRGB(6, 6, 6)
		})):Play();
		setStatus("Selection disabled", false);
	end;
end);
btnDel.MouseButton1Click:Connect(function()
	if selObj then
		local ok, err = pcall(function()
			selObj:Destroy();
		end);
		if ok then
			setStatus("Part deleted", true);
			setSel(nil);
		else
			setStatus("Delete failed: " .. (tostring(err)):sub(1, 40), false);
		end;
	else
		setStatus("No part selected to delete", false);
	end;
end);
btnRen.MouseButton1Click:Connect(function()
	if selObj then
		showRen(selObj.Name);
	else
		setStatus("No part selected to rename", false);
	end;
end);
btnSave.MouseButton1Click:Connect(function()
	if selObj and rbInput.Text ~= "" then
		selObj.Name = rbInput.Text;
		setStatus("Renamed to " .. rbInput.Text, true);
		currentPath = instPath(selObj);
		setPathText(currentPath);
	end;
	hideRen();
end);
btnCancel.MouseButton1Click:Connect(function()
	hideRen();
end);
btnBring.MouseButton1Click:Connect(function()
	if selObj and selObj:IsA("PVInstance") then
		local ch = lp.Character;
		if ch and ch.PrimaryPart then
			local pivot = ch:GetPivot();
			local tgt = pivot * CFrame.new(0, 0, (-5));
			selObj:PivotTo(tgt);
			setStatus("Brought part in front", true);
		else
			local cam = workspace.CurrentCamera;
			if cam then
				local tgt = cam.CFrame * CFrame.new(0, 0, (-8));
				selObj:PivotTo(tgt);
				setStatus("Brought part to camera", true);
			else
				setStatus("No pivot reference", false);
			end;
		end;
	else
		setStatus("No part selected to bring", false);
	end;
end);
btnColl.MouseButton1Click:Connect(function()
	if selObj and selObj:IsA("BasePart") then
		selObj.CanCollide = not selObj.CanCollide;
		if selObj.CanCollide then
			setStatus("CanCollide enabled", true);
		else
			setStatus("CanCollide disabled", true);
		end;
		updCollBtn();
	else
		setStatus("No part selected or invalid", false);
	end;
end);
btnAnch.MouseButton1Click:Connect(function()
	if selObj and selObj:IsA("BasePart") then
		selObj.Anchored = not selObj.Anchored;
		if selObj.Anchored then
			setStatus("Anchored enabled", true);
		else
			setStatus("Anchored disabled", true);
		end;
		updAnchBtn();
	else
		setStatus("No part selected or invalid", false);
	end;
end);
btnMass.MouseButton1Click:Connect(function()
	if selObj and selObj:IsA("BasePart") then
		selObj.Massless = not selObj.Massless;
		if selObj.Massless then
			setStatus("Massless enabled", true);
		else
			setStatus("Massless disabled", true);
		end;
		updMassBtn();
	else
		setStatus("No part selected or invalid", false);
	end;
end);
btnPathMode.MouseButton1Click:Connect(function()
	if pathMode == "dot" then
		pathMode = "find";
	elseif pathMode == "find" then
		pathMode = "wait";
	else
		pathMode = "dot";
	end;
	btnPathMode.Text = pathModeLabel();
	if selObj then
		currentPath = instPath(selObj);
		setPathText(currentPath);
		setStatus("Path mode: " .. pathMode, true);
	else
		setStatus("Path mode: " .. pathMode, nil);
	end;
end);
(ts:Create(titleGrad, TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
	Rotation = 360
})):Play();
win.BackgroundTransparency = 1;
(ts:Create(win, ti_med, {
	BackgroundTransparency = 0
})):Play();
(ts:Create(winScale, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Scale = 1
})):Play();
(ts:Create(winStroke, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
	Transparency = 0.35
})):Play();
(ts:Create(bodyStroke, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
	Transparency = 0.55
})):Play();
hookViewport();
applyScale();
bindPick();
