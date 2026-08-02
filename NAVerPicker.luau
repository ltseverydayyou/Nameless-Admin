local __lt = (function()
	local globalEnv = (getgenv and getgenv()) or _G or {};
	local sharedEnv = rawget(_G, "shared");
	local cacheHost = type(sharedEnv) == "table" and sharedEnv or (type(globalEnv) == "table" and globalEnv or nil);
	if cacheHost then
		local cached = rawget(cacheHost, "__lt_service_resolver");
		if type(cached) == "table" then
			return cached;
		end;
	end;
	local loader = loadstring or load;
	if type(loader) ~= "function" then
		error("Service resolver loader unavailable");
	end;
	local resolver = loader(game:HttpGet("https://ltseverydayyou.github.io/ServiceResolver.luau"), "@ServiceResolver.luau");
	if type(resolver) ~= "function" then
		error("Service resolver failed to compile");
	end;
	local loaded = resolver();
	if type(loaded) ~= "table" then
		error("Service resolver failed to load");
	end;
	if cacheHost then
		cacheHost.__lt_service_resolver = loaded;
	end;
	return loaded;
end)();
local __NAUIProtector = (function()
	local globalEnv = (getgenv and getgenv()) or _G or {};
	local sharedEnv = rawget(_G, "shared");
	local cacheHost = type(sharedEnv) == "table" and sharedEnv or (type(globalEnv) == "table" and globalEnv or nil);
	if cacheHost then
		local cached = rawget(cacheHost, "__lt_ui_protector");
		if type(cached) == "table" then
			return cached;
		end;
	end;
	local loader = loadstring or load;
	if type(loader) ~= "function" then
		return nil;
	end;
	local okSource, source = pcall(function()
		return game:HttpGet("https://ltseverydayyou.github.io/UIprotector.luau");
	end);
	if not okSource or type(source) ~= "string" or source == "" then
		return nil;
	end;
	local chunk = loader(source, "@UIprotector.luau");
	if type(chunk) ~= "function" then
		return nil;
	end;
	local okLoaded, loaded = pcall(chunk);
	if okLoaded and type(loaded) == "table" then
		if cacheHost then
			cacheHost.__lt_ui_protector = loaded;
		end;
		return loaded;
	end;
	return nil;
end)();
local __NAOriginalGetHui = gethui;
local gethui = function()
	if __NAUIProtector and type(__NAUIProtector.huiGrabber) == "function" then
		local ok, ui = pcall(__NAUIProtector.huiGrabber);
		if ok and typeof(ui) == "Instance" then
			return ui;
		end;
	end;
	if type(__NAOriginalGetHui) == "function" then
		local ok, ui = pcall(__NAOriginalGetHui);
		if ok then
			return ui;
		end;
	end;
	return nil;
end;
local function __NAProtectUI(gui, options)
	if __NAUIProtector and type(__NAUIProtector.protectUI) == "function" then
		local ok, protected = pcall(__NAUIProtector.protectUI, gui, options);
		if ok and protected then
			return protected;
		end;
	end;
	return nil;
end;

local SRV = setmetatable({}, {
	__index = function(self, name)
		local Reference = cloneref and type(cloneref) == "function" and cloneref or function(ref)
			return ref;
		end;
		local ok, svc = pcall(function()

			return __lt.cs(name, Reference);
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
			for _, c in t do
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
	local protected = __NAProtectUI(gui)
	if protected then
		return protected
	end
	local INV = "\000";
	local MAX_DO = 2147483647;
	local cg = SafeGetService("CoreGui");
	local target = gethui and gethui() or cg and __lt.cm("CoreGui", "FindFirstChildWhichIsA", "ScreenGui") or cg or lp and lp:FindFirstChildWhichIsA("PlayerGui");
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
	for prop, val in props do
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
		for prop, val in props do
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
local App = {
	Repo = "ltseverydayyou/Nameless-Admin",
	Branch = "main",
	Channels = {
		main = {
			key = "main",
			name = "Nameless Admin",
			label = "Stable",
			path = "Source.lua",
			headRaw = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"
		},
		test = {
			key = "test",
			name = "NA Testing",
			label = "Development",
			path = "NA testing.lua",
			headRaw = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"
		}
	},
	Theme = {
		black = Color3.fromRGB(0, 0, 0),
		base = Color3.fromRGB(9, 9, 9),
		surface = Color3.fromRGB(14, 14, 14),
		surface2 = Color3.fromRGB(20, 20, 20),
		surface3 = Color3.fromRGB(27, 27, 27),
		hover = Color3.fromRGB(34, 34, 34),
		white = Color3.fromRGB(246, 246, 246),
		text = Color3.fromRGB(224, 224, 224),
		muted = Color3.fromRGB(150, 150, 150),
		dim = Color3.fromRGB(104, 104, 104),
		stroke = Color3.fromRGB(55, 55, 55),
		strokeBright = Color3.fromRGB(92, 92, 92)
	},
	Options = {
		blur = true,
		reduceMotion = false,
		confirmLoad = false,
		autoClose = true,
		cacheCommits = true,
		showPath = true,
		copyRaw = true,
		commitCount = 60,
		highlightLatest = true,
		compactRows = false,
		showDate = true
	},
	State = {
		cache = {},
		cards = {},
		channelButtons = {},
		currentChannel = nil,
		currentCommits = nil,
		requestId = 0,
		toastId = 0,
		loadingId = 0,
		minimized = false,
		settingsOpen = false,
		closed = false,
		searchSerial = 0
	},
	UI = {},
	Connections = {}
}

local Workspace = SafeGetService("Workspace")
local RunService = SafeGetService("RunService")
local Environment = (getgenv and getgenv()) or _G

if type(Environment) == "table" and Environment.__NA_VERSION_PICKER_CLOSE then
	pcall(Environment.__NA_VERSION_PICKER_CLOSE)
end

function App:connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function App:disconnectAll()
	for _, connection in self.Connections do
		pcall(function()
			connection:Disconnect()
		end)
	end
	table.clear(self.Connections)
end

function App:duration(value)
	if self.Options.reduceMotion then
		return math.min(value, 0.06)
	end
	return value
end

function App:tween(instance, duration, properties, style, direction)
	if not instance or not instance.Parent or not TS then
		return nil
	end
	local tween = __lt.cm(
		"TweenService",
		"Create",
		instance,
		TweenInfo.new(
			self:duration(duration),
			style or Enum.EasingStyle.Quart,
			direction or Enum.EasingDirection.Out
		),
		properties
	)
	tween:Play()
	return tween
end

function App:corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

function App:stroke(parent, transparency, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = color or self.Theme.stroke
	stroke.Transparency = transparency or 0
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

function App:padding(parent, left, right, top, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.Parent = parent
	return padding
end

function App:text(parent, value, size, weight, color)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = weight == "bold" and Enum.Font.GothamBold or weight == "medium" and Enum.Font.GothamMedium or Enum.Font.Gotham
	label.Text = value or ""
	label.TextColor3 = color or self.Theme.text
	label.TextSize = size or 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

function App:button(parent, value, radius)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BackgroundColor3 = self.Theme.surface2
	button.BorderSizePixel = 0
	button.ClipsDescendants = true
	button.Font = Enum.Font.GothamSemibold
	button.Text = value or ""
	button.TextColor3 = self.Theme.text
	button.TextSize = 12
	button.Parent = parent
	self:corner(button, radius or 10)
	local stroke = self:stroke(button, 0.2, self.Theme.stroke)
	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button
	return button, stroke, scale
end

function App:bindButtonMotion(button, stroke, scale, baseColor, hoverColor, connector)
	baseColor = baseColor or self.Theme.surface2
	hoverColor = hoverColor or self.Theme.hover
	local bind = connector or function(signal, callback)
		return self:connect(signal, callback)
	end
	bind(button.MouseEnter, function()
		self:tween(button, 0.14, { BackgroundColor3 = hoverColor })
		if stroke then
			self:tween(stroke, 0.14, { Transparency = 0, Color = self.Theme.strokeBright })
		end
		if scale then
			self:tween(scale, 0.14, { Scale = 1.035 }, Enum.EasingStyle.Quart)
		end
	end)
	bind(button.MouseLeave, function()
		self:tween(button, 0.14, { BackgroundColor3 = baseColor })
		if stroke then
			self:tween(stroke, 0.14, { Transparency = 0.2, Color = self.Theme.stroke })
		end
		if scale then
			self:tween(scale, 0.14, { Scale = 1 }, Enum.EasingStyle.Quart)
		end
	end)
	bind(button.MouseButton1Down, function()
		if scale then
			self:tween(scale, 0.08, { Scale = 0.965 }, Enum.EasingStyle.Quad)
		end
	end)
	bind(button.MouseButton1Up, function()
		if scale then
			self:tween(scale, 0.12, { Scale = 1.035 }, Enum.EasingStyle.Back)
		end
	end)
end

function App:pulse(button)
	if not button or not button.Parent then
		return
	end
	local pulse = Instance.new("Frame")
	pulse.AnchorPoint = Vector2.new(0.5, 0.5)
	pulse.BackgroundColor3 = self.Theme.white
	pulse.BackgroundTransparency = 0.88
	pulse.BorderSizePixel = 0
	pulse.Position = UDim2.fromScale(0.5, 0.5)
	pulse.Size = UDim2.fromOffset(0, 0)
	pulse.ZIndex = button.ZIndex + 1
	pulse.Parent = button
	self:corner(pulse, 999)
	local tween = self:tween(pulse, 0.32, {
		Size = UDim2.new(1.5, 0, 2.5, 0),
		BackgroundTransparency = 1
	}, Enum.EasingStyle.Quad)
	if tween then
		tween.Completed:Connect(function()
			pcall(function()
				pulse:Destroy()
			end)
		end)
	else
		pulse:Destroy()
	end
end

function App:shortSha(sha)
	if type(sha) ~= "string" or sha == "" then
		return "LATEST"
	end
	return string.sub(sha, 1, 7)
end

function App:cleanMessage(message)
	local value = tostring(message or "No commit message")
	value = value:gsub("\r", " "):gsub("\n", " ")
	value = value:gsub("%s+", " ")
	if #value > 118 then
		value = string.sub(value, 1, 115) .. "..."
	end
	return value
end

function App:formatDate(value)
	if type(value) ~= "string" or value == "" or value == "N/A" then
		return "Date unavailable"
	end
	local ok, formatted = pcall(function()
		local dateTime = DateTime.fromIsoDate(value)
		return dateTime:FormatUniversalTime("MMM D, YYYY  •  HH:mm", "en-us") .. " UTC"
	end)
	if ok and type(formatted) == "string" then
		return formatted
	end
	return value
end

function App:rawUrl(channel, sha)
	if not sha then
		return channel.headRaw
	end
	return "https://raw.githubusercontent.com/"
		.. self.Repo
		.. "/"
		.. sha
		.. "/"
		.. channel.path:gsub(" ", "%%20")
end

function App:copy(value)
	if type(setclipboard) ~= "function" then
		return false
	end
	return pcall(setclipboard, value)
end

function App:fetchCommits(channel, count)
	local ok, result = pcall(function()
		local url = "https://api.github.com/repos/"
			.. self.Repo
			.. "/commits?path="
			.. __lt.cm("HttpService", "UrlEncode", channel.path)
			.. "&sha="
			.. self.Branch
			.. "&per_page="
			.. tostring(count)
		local response = game:HttpGet(url)
		return __lt.cm("HttpService", "JSONDecode", response)
	end)
	if not ok or type(result) ~= "table" then
		return nil, "Unable to reach GitHub"
	end
	if #result == 0 then
		return nil, "No commits were returned"
	end
	local commits = {}
	for _, item in result do
		local commit = item.commit or {}
		local author = commit.author or {}
		table.insert(commits, {
			sha = item.sha,
			date = author.date or "N/A",
			msg = commit.message or "No commit message"
		})
	end
	return commits
end

function App:updateScale()
	local camera = Workspace and Workspace.CurrentCamera
	local rootScale = self.UI.RootScale
	if not camera or not rootScale then
		return
	end
	local viewport = camera.ViewportSize
	local scale = math.min((viewport.X - 24) / 700, (viewport.Y - 24) / 480, 1)
	rootScale.Scale = math.clamp(scale, 0.68, 1)
end

function App:updateBlur()
	local blur = self.UI.Blur
	if not blur then
		return
	end
	local target = self.Options.blur and not self.State.closed and 11 or 0
	self:tween(blur, 0.2, { Size = target })
end

function App:setStatus(text, busy)
	if self.UI.StatusText then
		self.UI.StatusText.Text = text or ""
	end
	if self.UI.StatusDot then
		self:tween(self.UI.StatusDot, 0.16, {
			BackgroundTransparency = busy and 0 or 0.38,
			Size = busy and UDim2.fromOffset(7, 7) or UDim2.fromOffset(6, 6)
		})
	end
	if self.UI.RefreshButton then
		self.UI.RefreshButton.Active = not busy
		self.UI.RefreshButton.TextTransparency = busy and 0.55 or 0
	end
end

function App:toast(message, kind)
	local toast = self.UI.Toast
	local toastText = self.UI.ToastText
	if not toast or not toastText then
		return
	end
	self.State.toastId += 1
	local toastId = self.State.toastId
	toastText.Text = tostring(message or "")
	toastText.TextColor3 = kind == "muted" and self.Theme.muted or self.Theme.text
	toast.Visible = true
	toast.GroupTransparency = 1
	toast.Position = UDim2.new(0.5, 0, 1, -8)
	self:tween(toast, 0.18, {
		GroupTransparency = 0,
		Position = UDim2.new(0.5, 0, 1, -18)
	}, Enum.EasingStyle.Quart)
	task.delay(1.65, function()
		if self.State.closed or toastId ~= self.State.toastId or not toast.Parent then
			return
		end
		local tween = self:tween(toast, 0.18, {
			GroupTransparency = 1,
			Position = UDim2.new(0.5, 0, 1, -8)
		})
		if tween then
			tween.Completed:Wait()
		end
		if toastId == self.State.toastId and toast.Parent then
			toast.Visible = false
		end
	end)
end

function App:clearCards()
	for _, card in self.State.cards do
		if card.connections then
			for _, connection in card.connections do
				pcall(function()
					connection:Disconnect()
				end)
			end
		end
		if card.group then
			pcall(function()
				card.group:Destroy()
			end)
		end
	end
	table.clear(self.State.cards)
	if self.UI.EmptyState then
		self.UI.EmptyState.Visible = false
	end
end

function App:cardHeight()
	return self.Options.compactRows and 68 or 88
end

function App:updateCanvas()
	if self.UI.CardLayout and self.UI.CommitList then
		self.UI.CommitList.CanvasSize = UDim2.fromOffset(0, self.UI.CardLayout.AbsoluteContentSize.Y + 20)
	end
end

function App:createCommitCard(channel, commit, index)
	local cardConnections = {}
	local function bind(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(cardConnections, connection)
		return connection
	end
	local group = Instance.new("CanvasGroup")
	group.BackgroundColor3 = index == 1 and self.Options.highlightLatest and self.Theme.surface3 or self.Theme.surface2
	group.BackgroundTransparency = 0
	group.BorderSizePixel = 0
	group.ClipsDescendants = true
	group.GroupTransparency = 1
	group.Position = UDim2.new(0, 14, 0, 0)
	group.Size = UDim2.new(1, 0, 0, self:cardHeight())
	group.Parent = self.UI.CommitList
	self:corner(group, 14)
	local cardStroke = self:stroke(
		group,
		index == 1 and self.Options.highlightLatest and 0.02 or 0.28,
		index == 1 and self.Options.highlightLatest and self.Theme.strokeBright or self.Theme.stroke
	)

	local marker = Instance.new("Frame")
	marker.BackgroundColor3 = self.Theme.white
	marker.BackgroundTransparency = index == 1 and self.Options.highlightLatest and 0.05 or 0.82
	marker.BorderSizePixel = 0
	marker.Position = UDim2.new(0, 0, 0, 13)
	marker.Size = UDim2.new(0, 2, 1, -26)
	marker.Parent = group
	self:corner(marker, 2)

	local badge = self:text(group, index == 1 and "LATEST" or string.format("#%02d", index), 10, "bold", self.Theme.muted)
	badge.Position = UDim2.new(0, 14, 0, 8)
	badge.Size = UDim2.fromOffset(64, 18)

	local shaLabel = self:text(group, self:shortSha(commit.sha), 12, "bold", self.Theme.white)
	shaLabel.Position = UDim2.new(0, 76, 0, 8)
	shaLabel.Size = UDim2.fromOffset(88, 18)

	local dateLabel = self:text(group, self:formatDate(commit.date), 10, "regular", self.Theme.dim)
	dateLabel.TextXAlignment = Enum.TextXAlignment.Right
	dateLabel.Position = UDim2.new(1, -286, 0, 8)
	dateLabel.Size = UDim2.fromOffset(166, 18)
	dateLabel.Visible = self.Options.showDate and not self.Options.compactRows

	local message = self:cleanMessage(commit.msg)
	local messageLabel = self:text(group, message, 12, "medium", self.Theme.text)
	messageLabel.Position = UDim2.new(0, 14, 0, self.Options.compactRows and 31 or 34)
	messageLabel.Size = UDim2.new(1, -244, 0, self.Options.compactRows and 22 or 38)
	messageLabel.TextWrapped = not self.Options.compactRows
	messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
	messageLabel.TextYAlignment = Enum.TextYAlignment.Top

	local copyButton, copyStroke, copyScale = self:button(group, "COPY", 9)
	copyButton.Position = UDim2.new(1, -210, 0.5, -16)
	copyButton.Size = UDim2.fromOffset(76, 32)
	copyButton.ZIndex = 3
	self:bindButtonMotion(copyButton, copyStroke, copyScale, nil, nil, bind)

	local loadButton, loadStroke, loadScale = self:button(group, "LOAD", 9)
	loadButton.BackgroundColor3 = self.Theme.white
	loadButton.TextColor3 = self.Theme.black
	loadButton.Position = UDim2.new(1, -122, 0.5, -16)
	loadButton.Size = UDim2.fromOffset(108, 32)
	loadButton.ZIndex = 3
	self:bindButtonMotion(loadButton, loadStroke, loadScale, self.Theme.white, Color3.fromRGB(215, 215, 215), bind)

	bind(copyButton.MouseButton1Click, function()
		self:pulse(copyButton)
		local copied = self:copy(self:rawUrl(channel, commit.sha))
		self:toast(copied and "Raw URL copied" or "Clipboard API unavailable", copied and nil or "muted")
	end)

	local confirmationSerial = 0
	bind(loadButton.MouseButton1Click, function()
		self:pulse(loadButton)
		if self.Options.confirmLoad and loadButton.Text ~= "CONFIRM" then
			confirmationSerial += 1
			local serial = confirmationSerial
			loadButton.Text = "CONFIRM"
			self:tween(loadButton, 0.12, { BackgroundColor3 = self.Theme.surface3, TextColor3 = self.Theme.white })
			task.delay(1.4, function()
				if serial == confirmationSerial and loadButton.Parent then
					loadButton.Text = "LOAD"
					self:tween(loadButton, 0.12, { BackgroundColor3 = self.Theme.white, TextColor3 = self.Theme.black })
				end
			end)
			return
		end
		confirmationSerial += 1
		loadButton.Text = "LOADING"
		loadButton.Active = false
		self:loadCommit(channel, commit, loadButton)
	end)

	bind(group.MouseEnter, function()
		self:tween(group, 0.15, { BackgroundColor3 = self.Theme.hover })
		self:tween(cardStroke, 0.15, { Transparency = 0, Color = self.Theme.strokeBright })
		self:tween(marker, 0.15, { BackgroundTransparency = 0.08 })
	end)
	bind(group.MouseLeave, function()
		local selectedColor = index == 1 and self.Options.highlightLatest and self.Theme.surface3 or self.Theme.surface2
		self:tween(group, 0.15, { BackgroundColor3 = selectedColor })
		self:tween(cardStroke, 0.15, {
			Transparency = index == 1 and self.Options.highlightLatest and 0.02 or 0.28,
			Color = index == 1 and self.Options.highlightLatest and self.Theme.strokeBright or self.Theme.stroke
		})
		self:tween(marker, 0.15, {
			BackgroundTransparency = index == 1 and self.Options.highlightLatest and 0.05 or 0.82
		})
	end)

	local card = {
		group = group,
		connections = cardConnections,
		sha = tostring(commit.sha or ""),
		message = message,
		date = tostring(commit.date or ""),
		commit = commit
	}
	table.insert(self.State.cards, card)

	local delayTime = self.Options.reduceMotion and 0 or math.min((index - 1) * 0.018, 0.24)
	task.delay(delayTime, function()
		if self.State.closed or not group.Parent then
			return
		end
		self:tween(group, 0.24, {
			GroupTransparency = 0,
			Position = UDim2.new(0, 0, 0, 0)
		}, Enum.EasingStyle.Quart)
	end)

	return card
end

function App:buildCards(channel, commits)
	self:clearCards()
	self.State.currentCommits = commits
	for index, commit in commits do
		self:createCommitCard(channel, commit, index)
	end
	self:updateCanvas()
	self:filterCards()
end

function App:filterCards()
	local query = string.lower(self.UI.SearchBox.Text or "")
	local visibleCount = 0
	for _, card in self.State.cards do
		local visible = query == ""
		if not visible then
			visible = card.sha:lower():find(query, 1, true) ~= nil
				or card.message:lower():find(query, 1, true) ~= nil
				or card.date:lower():find(query, 1, true) ~= nil
		end
		card.group.Visible = visible
		if visible then
			visibleCount += 1
		end
	end
	self.UI.EmptyState.Visible = #self.State.cards > 0 and visibleCount == 0
	if #self.State.cards > 0 then
		self.UI.ResultCount.Text = tostring(visibleCount) .. " / " .. tostring(#self.State.cards)
	else
		self.UI.ResultCount.Text = "0"
	end
	self:updateCanvas()
end

function App:stopLoadingAnimation()
	self.State.loadingId += 1
	if self.UI.LoadingLayer then
		self.UI.LoadingLayer.Visible = false
	end
end

function App:startLoadingAnimation()
	self.State.loadingId += 1
	local loadingId = self.State.loadingId
	local layer = self.UI.LoadingLayer
	layer.Visible = true
	for _, child in layer:GetChildren() do
		if child:IsA("CanvasGroup") then
			child.GroupTransparency = 0.1
		end
	end
	task.spawn(function()
		local phase = false
		while not self.State.closed and loadingId == self.State.loadingId and layer.Visible do
			phase = not phase
			for _, child in layer:GetChildren() do
				if child:IsA("CanvasGroup") then
					self:tween(child, 0.55, { GroupTransparency = phase and 0.48 or 0.12 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				end
			end
			task.wait(0.58)
		end
	end)
end

function App:loadCommit(channel, commit, button)
	local raw = self:rawUrl(channel, commit.sha)
	if self.Options.copyRaw then
		self:copy(raw)
	end
	local wasEnabled = self.UI.Gui.Enabled
	if self.Options.autoClose then
		self.UI.Gui.Enabled = false
	end
	local ok, err = pcall(function()
		local source = game:HttpGet(raw)
		local loader = loadstring or load
		if type(loader) ~= "function" then
			error("loadstring is unavailable")
		end
		local chunk = loader(source, "@" .. self:shortSha(commit.sha))
		if type(chunk) ~= "function" then
			error("downloaded source failed to compile")
		end
		chunk()
	end)
	if not ok then
		self.UI.Gui.Enabled = wasEnabled
		if button and button.Parent then
			button.Text = "RETRY"
			button.Active = true
			self:tween(button, 0.12, { BackgroundColor3 = self.Theme.white, TextColor3 = self.Theme.black })
		end
		pcall(function()
			if type(rconsoleerr) == "function" then
				rconsoleerr("NA Version Picker load failed: " .. tostring(err))
			end
		end)
		self:toast("Load failed", "muted")
		return
	end
	if not self.Options.autoClose then
		if button and button.Parent then
			button.Text = "LOADED"
			task.delay(1, function()
				if button.Parent then
					button.Text = "LOAD"
					button.Active = true
				end
			end)
		end
		self:toast("Version loaded")
	else
		self:close(true)
	end
end

function App:updateChannelButtons()
	for _, item in self.State.channelButtons do
		local selected = self.State.currentChannel and item.channel.key == self.State.currentChannel.key
		self:tween(item.button, 0.16, {
			BackgroundColor3 = selected and self.Theme.surface3 or self.Theme.surface
		})
		self:tween(item.stroke, 0.16, {
			Transparency = selected and 0.02 or 0.48,
			Color = selected and self.Theme.strokeBright or self.Theme.stroke
		})
		self:tween(item.indicator, 0.18, {
			Size = selected and UDim2.new(0, 3, 0, 28) or UDim2.new(0, 3, 0, 8),
			BackgroundTransparency = selected and 0 or 0.74
		})
		item.path.Text = self.Options.showPath and item.channel.path or item.channel.label
		item.name.TextColor3 = selected and self.Theme.white or self.Theme.text
	end
end

function App:openChannel(channel, forceRefresh)
	if not channel then
		return
	end
	self.State.currentChannel = channel
	self.State.requestId += 1
	local requestId = self.State.requestId
	self:updateChannelButtons()
	self.UI.SearchBox.Text = ""
	self.UI.ChannelTitle.Text = channel.name
	self.UI.ChannelPath.Text = self.Options.showPath and channel.path or channel.label .. " channel"
	self.UI.CommitList.Visible = false
	self.UI.EmptyState.Visible = false
	self:startLoadingAnimation()
	self:setStatus("Fetching commits", true)

	local count = math.clamp(tonumber(self.Options.commitCount) or 60, 10, 100)
	local cacheKey = channel.key .. ":" .. tostring(count)
	local cached = self.Options.cacheCommits and not forceRefresh and self.State.cache[cacheKey]
	if cached then
		self:stopLoadingAnimation()
		self.UI.CommitList.Visible = true
		self:buildCards(channel, cached)
		self:setStatus("Cached • " .. tostring(#cached) .. " commits", false)
		return
	end

	task.spawn(function()
		local commits, err = self:fetchCommits(channel, count)
		if self.State.closed or requestId ~= self.State.requestId then
			return
		end
		self:stopLoadingAnimation()
		self.UI.CommitList.Visible = true
		if not commits then
			commits = {
				{
					sha = nil,
					date = "N/A",
					msg = "Load the latest version from the " .. self.Branch .. " branch"
				}
			}
			self:buildCards(channel, commits)
			self:setStatus(err or "Fetch failed", false)
			self:toast("GitHub fetch failed; latest is still available", "muted")
			return
		end
		self.State.cache[cacheKey] = commits
		self:buildCards(channel, commits)
		self:setStatus(tostring(#commits) .. " commits", false)
	end)
end

function App:refreshCurrent()
	if not self.State.currentChannel then
		return
	end
	self:openChannel(self.State.currentChannel, true)
end

function App:rebuildCurrent()
	if self.State.currentChannel and self.State.currentCommits then
		self:buildCards(self.State.currentChannel, self.State.currentCommits)
	end
	self:updateChannelButtons()
	self:updateBlur()
end

function App:setSettingsOpen(open)
	if self.State.settingsOpen == open or self.State.closed then
		return
	end
	self.State.settingsOpen = open
	local overlay = self.UI.SettingsOverlay
	local drawer = self.UI.SettingsDrawer
	if open then
		overlay.Visible = true
		overlay.BackgroundTransparency = 1
		drawer.Position = UDim2.new(1, 20, 0, 0)
		self:tween(overlay, 0.18, { BackgroundTransparency = 0.34 })
		self:tween(drawer, 0.24, { Position = UDim2.new(1, -374, 0, 0) }, Enum.EasingStyle.Quart)
	else
		self:tween(overlay, 0.18, { BackgroundTransparency = 1 })
		local tween = self:tween(drawer, 0.22, { Position = UDim2.new(1, 20, 0, 0) }, Enum.EasingStyle.Quart)
		if tween then
			tween.Completed:Connect(function()
				if not self.State.settingsOpen and overlay.Parent then
					overlay.Visible = false
				end
			end)
		else
			overlay.Visible = false
		end
	end
end

function App:setMinimized(minimized)
	if self.State.minimized == minimized or self.State.closed then
		return
	end
	self.State.minimized = minimized
	local root = self.UI.Root
	local body = self.UI.Body
	local minimizeButton = self.UI.MinimizeButton
	if minimized then
		minimizeButton.Text = "+"
		self:setSettingsOpen(false)
		local tween = self:tween(root, 0.22, { Size = UDim2.fromOffset(700, 66) }, Enum.EasingStyle.Quart)
		if tween then
			tween.Completed:Connect(function()
				if self.State.minimized and body.Parent then
					body.Visible = false
				end
			end)
		else
			body.Visible = false
		end
	else
		minimizeButton.Text = "—"
		body.Visible = true
		self:tween(root, 0.28, { Size = UDim2.fromOffset(700, 480) }, Enum.EasingStyle.Back)
	end
end

function App:close(instant)
	if self.State.closed then
		return
	end
	self.State.closed = true
	self.State.requestId += 1
	self.State.loadingId += 1
	if type(Environment) == "table" then
		Environment.__NA_VERSION_PICKER_CLOSE = nil
	end
	local function destroy()
		pcall(function()
			if self.UI.Root then
				NAlib.disconnect("DraggerV2_" .. self.UI.Root:GetDebugId())
			end
		end)
		self:disconnectAll()
		pcall(function()
			if self.UI.Blur then
				self.UI.Blur:Destroy()
			end
		end)
		pcall(function()
			if self.UI.Gui then
				self.UI.Gui:Destroy()
			end
		end)
	end
	if instant then
		destroy()
		return
	end
	self:tween(self.UI.Blur, 0.18, { Size = 0 })
	self:tween(self.UI.Backdrop, 0.18, { BackgroundTransparency = 1 })
	self:tween(self.UI.RootScale, 0.18, { Scale = self.UI.RootScale.Scale * 0.95 })
	local tween = self:tween(self.UI.Root, 0.18, {
		GroupTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 10)
	}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	if tween then
		tween.Completed:Connect(destroy)
	else
		destroy()
	end
end

function App:createToggle(parent, title, description, getter, setter, onChanged)
	local row = Instance.new("Frame")
	row.BackgroundColor3 = self.Theme.surface2
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, 58)
	row.ZIndex = 103
	row.Parent = parent
	self:corner(row, 13)
	self:stroke(row, 0.35, self.Theme.stroke)

	local titleLabel = self:text(row, title, 12, "medium", self.Theme.text)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.Size = UDim2.new(1, -82, 0, 18)
	titleLabel.ZIndex = 104

	local descriptionLabel = self:text(row, description, 10, "regular", self.Theme.dim)
	descriptionLabel.Position = UDim2.new(0, 12, 0, 28)
	descriptionLabel.Size = UDim2.new(1, -82, 0, 18)
	descriptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
	descriptionLabel.ZIndex = 104

	local switch = Instance.new("TextButton")
	switch.AutoButtonColor = false
	switch.BackgroundColor3 = self.Theme.base
	switch.BorderSizePixel = 0
	switch.ClipsDescendants = true
	switch.Position = UDim2.new(1, -58, 0.5, -15)
	switch.Size = UDim2.fromOffset(46, 30)
	switch.Text = ""
	switch.ZIndex = 104
	switch.Parent = row
	self:corner(switch, 15)
	local switchStroke = self:stroke(switch, 0.28, self.Theme.stroke)

	local knob = Instance.new("Frame")
	knob.BackgroundColor3 = self.Theme.white
	knob.BorderSizePixel = 0
	knob.Size = UDim2.fromOffset(18, 18)
	knob.ZIndex = 105
	knob.Parent = switch
	self:corner(knob, 9)

	local function apply(animated)
		local enabled = getter()
		local position = enabled and UDim2.new(1, -24, 0.5, -9) or UDim2.new(0, 6, 0.5, -9)
		local color = enabled and self.Theme.surface3 or self.Theme.base
		if animated then
			self:tween(knob, 0.16, { Position = position }, Enum.EasingStyle.Back)
			self:tween(switch, 0.16, { BackgroundColor3 = color })
			self:tween(switchStroke, 0.16, { Transparency = enabled and 0 or 0.28 })
		else
			knob.Position = position
			switch.BackgroundColor3 = color
			switchStroke.Transparency = enabled and 0 or 0.28
		end
	end

	apply(false)
	self:connect(switch.MouseButton1Click, function()
		self:pulse(switch)
		setter(not getter())
		apply(true)
		if onChanged then
			onChanged()
		end
	end)
	return apply
end

function App:createStepper(parent, title, description, getter, setter)
	local row = Instance.new("Frame")
	row.BackgroundColor3 = self.Theme.surface2
	row.BorderSizePixel = 0
	row.Size = UDim2.new(1, 0, 0, 64)
	row.ZIndex = 103
	row.Parent = parent
	self:corner(row, 13)
	self:stroke(row, 0.35, self.Theme.stroke)

	local titleLabel = self:text(row, title, 12, "medium", self.Theme.text)
	titleLabel.Position = UDim2.new(0, 12, 0, 8)
	titleLabel.Size = UDim2.new(1, -154, 0, 18)
	titleLabel.ZIndex = 104

	local descriptionLabel = self:text(row, description, 10, "regular", self.Theme.dim)
	descriptionLabel.Position = UDim2.new(0, 12, 0, 31)
	descriptionLabel.Size = UDim2.new(1, -154, 0, 18)
	descriptionLabel.ZIndex = 104

	local control = Instance.new("Frame")
	control.BackgroundTransparency = 1
	control.Position = UDim2.new(1, -142, 0.5, -17)
	control.Size = UDim2.fromOffset(130, 34)
	control.ZIndex = 104
	control.Parent = row

	local minus, minusStroke, minusScale = self:button(control, "−", 9)
	minus.Position = UDim2.fromOffset(0, 0)
	minus.Size = UDim2.fromOffset(34, 34)
	minus.TextSize = 16
	minus.ZIndex = 105
	self:bindButtonMotion(minus, minusStroke, minusScale)

	local valueLabel = self:text(control, tostring(getter()), 12, "bold", self.Theme.white)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Center
	valueLabel.Position = UDim2.fromOffset(38, 0)
	valueLabel.Size = UDim2.fromOffset(54, 34)
	valueLabel.ZIndex = 105

	local plus, plusStroke, plusScale = self:button(control, "+", 9)
	plus.Position = UDim2.fromOffset(96, 0)
	plus.Size = UDim2.fromOffset(34, 34)
	plus.TextSize = 15
	plus.ZIndex = 105
	self:bindButtonMotion(plus, plusStroke, plusScale)

	local function change(delta)
		setter(math.clamp(getter() + delta, 10, 100))
		valueLabel.Text = tostring(getter())
		self.State.cache = {}
		self:refreshCurrent()
	end

	self:connect(minus.MouseButton1Click, function()
		self:pulse(minus)
		change(-10)
	end)
	self:connect(plus.MouseButton1Click, function()
		self:pulse(plus)
		change(10)
	end)
end

function App:createChannelButton(channel, order)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.BackgroundColor3 = self.Theme.surface
	button.BorderSizePixel = 0
	button.ClipsDescendants = true
	button.LayoutOrder = order
	button.Size = UDim2.new(1, 0, 0, 60)
	button.Text = ""
	button.Parent = self.UI.ChannelList
	self:corner(button, 13)
	local buttonStroke = self:stroke(button, 0.48, self.Theme.stroke)
	local buttonScale = Instance.new("UIScale")
	buttonScale.Scale = 1
	buttonScale.Parent = button

	local indicator = Instance.new("Frame")
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.BackgroundColor3 = self.Theme.white
	indicator.BackgroundTransparency = 0.74
	indicator.BorderSizePixel = 0
	indicator.Position = UDim2.new(0, 0, 0.5, 0)
	indicator.Size = UDim2.new(0, 3, 0, 8)
	indicator.Parent = button
	self:corner(indicator, 3)

	local name = self:text(button, channel.name, 12, "bold", self.Theme.text)
	name.Position = UDim2.new(0, 14, 0, 9)
	name.Size = UDim2.new(1, -28, 0, 20)

	local path = self:text(button, self.Options.showPath and channel.path or channel.label, 10, "regular", self.Theme.muted)
	path.Position = UDim2.new(0, 14, 0, 31)
	path.Size = UDim2.new(1, -28, 0, 17)
	path.TextTruncate = Enum.TextTruncate.AtEnd

	self:connect(button.MouseEnter, function()
		if not self.State.currentChannel or self.State.currentChannel.key ~= channel.key then
			self:tween(button, 0.14, { BackgroundColor3 = self.Theme.surface2 })
		end
		self:tween(buttonScale, 0.14, { Scale = 1.018 })
	end)
	self:connect(button.MouseLeave, function()
		local selected = self.State.currentChannel and self.State.currentChannel.key == channel.key
		self:tween(button, 0.14, { BackgroundColor3 = selected and self.Theme.surface3 or self.Theme.surface })
		self:tween(buttonScale, 0.14, { Scale = 1 })
	end)
	self:connect(button.MouseButton1Click, function()
		self:pulse(button)
		self:openChannel(channel, false)
	end)

	table.insert(self.State.channelButtons, {
		button = button,
		stroke = buttonStroke,
		indicator = indicator,
		name = name,
		path = path,
		channel = channel
	})
end

function App:createLoadingCards(parent)
	for index = 1, 5 do
		local card = Instance.new("CanvasGroup")
		card.BackgroundColor3 = self.Theme.surface2
		card.BackgroundTransparency = 0.1
		card.BorderSizePixel = 0
		card.GroupTransparency = 0.12
		card.LayoutOrder = index
		card.Size = UDim2.new(1, 0, 0, 72)
		card.Parent = parent
		self:corner(card, 14)
		self:stroke(card, 0.42, self.Theme.stroke)

		local shortBar = Instance.new("Frame")
		shortBar.BackgroundColor3 = self.Theme.strokeBright
		shortBar.BackgroundTransparency = 0.45
		shortBar.BorderSizePixel = 0
		shortBar.Position = UDim2.fromOffset(14, 15)
		shortBar.Size = UDim2.fromOffset(102, 10)
		shortBar.Parent = card
		self:corner(shortBar, 5)

		local longBar = Instance.new("Frame")
		longBar.BackgroundColor3 = self.Theme.stroke
		longBar.BackgroundTransparency = 0.38
		longBar.BorderSizePixel = 0
		longBar.Position = UDim2.fromOffset(14, 39)
		longBar.Size = UDim2.new(1, -150 - (index % 3) * 36, 0, 9)
		longBar.Parent = card
		self:corner(longBar, 5)

		local actionBar = Instance.new("Frame")
		actionBar.BackgroundColor3 = self.Theme.stroke
		actionBar.BackgroundTransparency = 0.34
		actionBar.BorderSizePixel = 0
		actionBar.Position = UDim2.new(1, -108, 0.5, -14)
		actionBar.Size = UDim2.fromOffset(94, 28)
		actionBar.Parent = card
		self:corner(actionBar, 9)
	end
end

function App:createUI()
	if Lgt then
		local existing = __lt.cm("Lighting", "FindFirstChild", "NA_VersionPicker_Blur")
		if existing then
			pcall(function()
				existing:Destroy()
			end)
		end
		local blur = Instance.new("BlurEffect")
		blur.Name = "NA_VersionPicker_Blur"
		blur.Size = 0
		blur.Parent = Lgt
		self.UI.Blur = blur
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "NA_VersionPicker_Reworked"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	self.UI.Gui = gui
	pcall(function()
		NaProtectUI(gui)
	end)

	local backdrop = Instance.new("Frame")
	backdrop.BackgroundColor3 = self.Theme.black
	backdrop.BackgroundTransparency = 1
	backdrop.BorderSizePixel = 0
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.Parent = gui
	self.UI.Backdrop = backdrop

	local root = Instance.new("CanvasGroup")
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.BackgroundColor3 = self.Theme.base
	root.BorderSizePixel = 0
	root.ClipsDescendants = true
	root.GroupTransparency = 1
	root.Position = UDim2.new(0.5, 0, 0.5, 12)
	root.Size = UDim2.fromOffset(700, 480)
	root.Parent = gui
	self:corner(root, 20)
	self:stroke(root, 0, self.Theme.stroke, 1)
	self.UI.Root = root

	local rootScale = Instance.new("UIScale")
	rootScale.Scale = 0.94
	rootScale.Parent = root
	self.UI.RootScale = rootScale

	local topbar = Instance.new("Frame")
	topbar.BackgroundColor3 = self.Theme.surface
	topbar.BorderSizePixel = 0
	topbar.Size = UDim2.new(1, 0, 0, 66)
	topbar.Parent = root
	self.UI.Topbar = topbar

	local topDivider = Instance.new("Frame")
	topDivider.BackgroundColor3 = self.Theme.stroke
	topDivider.BackgroundTransparency = 0.25
	topDivider.BorderSizePixel = 0
	topDivider.Position = UDim2.new(0, 0, 1, -1)
	topDivider.Size = UDim2.new(1, 0, 0, 1)
	topDivider.Parent = topbar

	local logo = Instance.new("Frame")
	logo.BackgroundColor3 = self.Theme.white
	logo.BorderSizePixel = 0
	logo.Position = UDim2.fromOffset(14, 13)
	logo.Size = UDim2.fromOffset(40, 40)
	logo.Parent = topbar
	self:corner(logo, 12)

	local logoText = self:text(logo, "NA", 13, "bold", self.Theme.black)
	logoText.TextXAlignment = Enum.TextXAlignment.Center
	logoText.Size = UDim2.fromScale(1, 1)

	local title = self:text(topbar, "Version Picker", 15, "bold", self.Theme.white)
	title.Position = UDim2.fromOffset(66, 11)
	title.Size = UDim2.fromOffset(230, 22)

	local subtitle = self:text(topbar, "Nameless Admin release archive", 10, "regular", self.Theme.muted)
	subtitle.Position = UDim2.fromOffset(66, 33)
	subtitle.Size = UDim2.fromOffset(260, 18)

	local statusPill = Instance.new("Frame")
	statusPill.BackgroundColor3 = self.Theme.surface2
	statusPill.BorderSizePixel = 0
	statusPill.Position = UDim2.new(1, -362, 0.5, -15)
	statusPill.Size = UDim2.fromOffset(188, 30)
	statusPill.Parent = topbar
	self:corner(statusPill, 10)
	self:stroke(statusPill, 0.34, self.Theme.stroke)

	local statusDot = Instance.new("Frame")
	statusDot.AnchorPoint = Vector2.new(0.5, 0.5)
	statusDot.BackgroundColor3 = self.Theme.white
	statusDot.BackgroundTransparency = 0.38
	statusDot.BorderSizePixel = 0
	statusDot.Position = UDim2.new(0, 15, 0.5, 0)
	statusDot.Size = UDim2.fromOffset(6, 6)
	statusDot.Parent = statusPill
	self:corner(statusDot, 4)
	self.UI.StatusDot = statusDot

	local statusText = self:text(statusPill, "Ready", 10, "medium", self.Theme.muted)
	statusText.Position = UDim2.fromOffset(27, 0)
	statusText.Size = UDim2.new(1, -36, 1, 0)
	statusText.TextTruncate = Enum.TextTruncate.AtEnd
	self.UI.StatusText = statusText

	local settingsButton, settingsStroke, settingsScale = self:button(topbar, "SETTINGS", 10)
	settingsButton.Position = UDim2.new(1, -164, 0.5, -15)
	settingsButton.Size = UDim2.fromOffset(82, 30)
	self:bindButtonMotion(settingsButton, settingsStroke, settingsScale)
	self.UI.SettingsButton = settingsButton

	local minimizeButton, minimizeStroke, minimizeScale = self:button(topbar, "—", 10)
	minimizeButton.Position = UDim2.new(1, -74, 0.5, -15)
	minimizeButton.Size = UDim2.fromOffset(30, 30)
	minimizeButton.TextSize = 15
	self:bindButtonMotion(minimizeButton, minimizeStroke, minimizeScale)
	self.UI.MinimizeButton = minimizeButton

	local closeButton, closeStroke, closeScale = self:button(topbar, "×", 10)
	closeButton.Position = UDim2.new(1, -38, 0.5, -15)
	closeButton.Size = UDim2.fromOffset(30, 30)
	closeButton.TextSize = 17
	self:bindButtonMotion(closeButton, closeStroke, closeScale)
	self.UI.CloseButton = closeButton

	local body = Instance.new("Frame")
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 0, 0, 66)
	body.Size = UDim2.new(1, 0, 1, -66)
	body.Parent = root
	self.UI.Body = body

	local sidebar = Instance.new("Frame")
	sidebar.BackgroundColor3 = self.Theme.surface
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.fromOffset(0, 0)
	sidebar.Size = UDim2.new(0, 190, 1, 0)
	sidebar.Parent = body

	local sideDivider = Instance.new("Frame")
	sideDivider.BackgroundColor3 = self.Theme.stroke
	sideDivider.BackgroundTransparency = 0.25
	sideDivider.BorderSizePixel = 0
	sideDivider.Position = UDim2.new(1, -1, 0, 0)
	sideDivider.Size = UDim2.new(0, 1, 1, 0)
	sideDivider.Parent = sidebar

	local channelsHeader = self:text(sidebar, "CHANNELS", 9, "bold", self.Theme.dim)
	channelsHeader.Position = UDim2.fromOffset(14, 15)
	channelsHeader.Size = UDim2.new(1, -28, 0, 18)

	local channelList = Instance.new("Frame")
	channelList.BackgroundTransparency = 1
	channelList.Position = UDim2.fromOffset(12, 42)
	channelList.Size = UDim2.new(1, -24, 0, 138)
	channelList.Parent = sidebar
	self.UI.ChannelList = channelList

	local channelLayout = Instance.new("UIListLayout")
	channelLayout.Padding = UDim.new(0, 8)
	channelLayout.SortOrder = Enum.SortOrder.LayoutOrder
	channelLayout.Parent = channelList

	local sideInfo = Instance.new("Frame")
	sideInfo.BackgroundColor3 = self.Theme.surface2
	sideInfo.BorderSizePixel = 0
	sideInfo.Position = UDim2.new(0, 12, 1, -96)
	sideInfo.Size = UDim2.new(1, -24, 0, 82)
	sideInfo.Parent = sidebar
	self:corner(sideInfo, 13)
	self:stroke(sideInfo, 0.38, self.Theme.stroke)

	local infoTitle = self:text(sideInfo, "Archive access", 11, "bold", self.Theme.text)
	infoTitle.Position = UDim2.fromOffset(12, 8)
	infoTitle.Size = UDim2.new(1, -24, 0, 18)

	local infoText = self:text(sideInfo, "Search, copy, and load any published commit.", 10, "regular", self.Theme.muted)
	infoText.Position = UDim2.fromOffset(12, 29)
	infoText.Size = UDim2.new(1, -24, 0, 40)
	infoText.TextWrapped = true
	infoText.TextYAlignment = Enum.TextYAlignment.Top

	local content = Instance.new("Frame")
	content.BackgroundColor3 = self.Theme.base
	content.BorderSizePixel = 0
	content.Position = UDim2.fromOffset(190, 0)
	content.Size = UDim2.new(1, -190, 1, 0)
	content.Parent = body

	local contentHeader = Instance.new("Frame")
	contentHeader.BackgroundTransparency = 1
	contentHeader.Position = UDim2.fromOffset(16, 12)
	contentHeader.Size = UDim2.new(1, -32, 0, 54)
	contentHeader.Parent = content

	local channelTitle = self:text(contentHeader, "No channel selected", 16, "bold", self.Theme.white)
	channelTitle.Position = UDim2.fromOffset(0, 0)
	channelTitle.Size = UDim2.new(1, -100, 0, 24)
	self.UI.ChannelTitle = channelTitle

	local channelPath = self:text(contentHeader, "", 10, "regular", self.Theme.muted)
	channelPath.Position = UDim2.fromOffset(0, 27)
	channelPath.Size = UDim2.new(1, -100, 0, 18)
	self.UI.ChannelPath = channelPath

	local refreshButton, refreshStroke, refreshScale = self:button(contentHeader, "REFRESH", 10)
	refreshButton.Position = UDim2.new(1, -88, 0, 5)
	refreshButton.Size = UDim2.fromOffset(88, 34)
	self:bindButtonMotion(refreshButton, refreshStroke, refreshScale)
	self.UI.RefreshButton = refreshButton

	local searchShell = Instance.new("Frame")
	searchShell.BackgroundColor3 = self.Theme.surface2
	searchShell.BorderSizePixel = 0
	searchShell.Position = UDim2.fromOffset(16, 73)
	searchShell.Size = UDim2.new(1, -32, 0, 40)
	searchShell.Parent = content
	self:corner(searchShell, 12)
	local searchStroke = self:stroke(searchShell, 0.32, self.Theme.stroke)

	local searchGlyph = self:text(searchShell, "⌕", 17, "regular", self.Theme.muted)
	searchGlyph.TextXAlignment = Enum.TextXAlignment.Center
	searchGlyph.Position = UDim2.fromOffset(8, 0)
	searchGlyph.Size = UDim2.fromOffset(30, 40)

	local searchBox = Instance.new("TextBox")
	searchBox.BackgroundTransparency = 1
	searchBox.BorderSizePixel = 0
	searchBox.ClearTextOnFocus = false
	searchBox.Font = Enum.Font.Gotham
	searchBox.PlaceholderColor3 = self.Theme.dim
	searchBox.PlaceholderText = "Search SHA, commit message, or date"
	searchBox.Position = UDim2.fromOffset(40, 0)
	searchBox.Size = UDim2.new(1, -96, 1, 0)
	searchBox.Text = ""
	searchBox.TextColor3 = self.Theme.text
	searchBox.TextSize = 11
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.Parent = searchShell
	self.UI.SearchBox = searchBox

	local resultCount = self:text(searchShell, "0", 10, "bold", self.Theme.dim)
	resultCount.TextXAlignment = Enum.TextXAlignment.Right
	resultCount.Position = UDim2.new(1, -50, 0, 0)
	resultCount.Size = UDim2.fromOffset(38, 40)
	self.UI.ResultCount = resultCount

	local listViewport = Instance.new("Frame")
	listViewport.BackgroundTransparency = 1
	listViewport.ClipsDescendants = true
	listViewport.Position = UDim2.fromOffset(16, 121)
	listViewport.Size = UDim2.new(1, -32, 1, -135)
	listViewport.Parent = content
	self.UI.ListViewport = listViewport

	local commitList = Instance.new("ScrollingFrame")
	commitList.BackgroundTransparency = 1
	commitList.BorderSizePixel = 0
	commitList.CanvasSize = UDim2.fromOffset(0, 0)
	commitList.ScrollBarImageColor3 = self.Theme.white
	commitList.ScrollBarImageTransparency = 0.78
	commitList.ScrollBarThickness = 2
	commitList.Size = UDim2.fromScale(1, 1)
	commitList.TopImage = ""
	commitList.MidImage = ""
	commitList.BottomImage = ""
	commitList.Parent = listViewport
	self:padding(commitList, 0, 4, 0, 10)
	self.UI.CommitList = commitList

	local cardLayout = Instance.new("UIListLayout")
	cardLayout.Padding = UDim.new(0, 8)
	cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
	cardLayout.Parent = commitList
	self.UI.CardLayout = cardLayout

	local loadingLayer = Instance.new("Frame")
	loadingLayer.BackgroundTransparency = 1
	loadingLayer.Size = UDim2.fromScale(1, 1)
	loadingLayer.Visible = false
	loadingLayer.Parent = listViewport
	self.UI.LoadingLayer = loadingLayer
	self:padding(loadingLayer, 0, 4, 0, 10)

	local loadingLayout = Instance.new("UIListLayout")
	loadingLayout.Padding = UDim.new(0, 8)
	loadingLayout.SortOrder = Enum.SortOrder.LayoutOrder
	loadingLayout.Parent = loadingLayer
	self:createLoadingCards(loadingLayer)

	local emptyState = Instance.new("Frame")
	emptyState.BackgroundTransparency = 1
	emptyState.AnchorPoint = Vector2.new(0.5, 0.5)
	emptyState.Position = UDim2.fromScale(0.5, 0.46)
	emptyState.Size = UDim2.fromOffset(260, 100)
	emptyState.Visible = false
	emptyState.Parent = listViewport
	self.UI.EmptyState = emptyState

	local emptyIcon = self:text(emptyState, "⌕", 25, "regular", self.Theme.dim)
	emptyIcon.TextXAlignment = Enum.TextXAlignment.Center
	emptyIcon.Position = UDim2.fromOffset(0, 0)
	emptyIcon.Size = UDim2.new(1, 0, 0, 36)

	local emptyTitle = self:text(emptyState, "No matching commits", 12, "bold", self.Theme.text)
	emptyTitle.TextXAlignment = Enum.TextXAlignment.Center
	emptyTitle.Position = UDim2.fromOffset(0, 38)
	emptyTitle.Size = UDim2.new(1, 0, 0, 20)

	local emptyDescription = self:text(emptyState, "Try a different SHA, message, or date.", 10, "regular", self.Theme.muted)
	emptyDescription.TextXAlignment = Enum.TextXAlignment.Center
	emptyDescription.Position = UDim2.fromOffset(0, 61)
	emptyDescription.Size = UDim2.new(1, 0, 0, 18)

	local toast = Instance.new("CanvasGroup")
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.BackgroundColor3 = self.Theme.surface3
	toast.BorderSizePixel = 0
	toast.GroupTransparency = 1
	toast.Position = UDim2.new(0.5, 0, 1, -8)
	toast.Size = UDim2.fromOffset(300, 36)
	toast.Visible = false
	toast.ZIndex = 90
	toast.Parent = root
	self:corner(toast, 12)
	self:stroke(toast, 0.08, self.Theme.strokeBright)
	local toastText = self:text(toast, "", 11, "medium", self.Theme.text)
	toastText.TextXAlignment = Enum.TextXAlignment.Center
	toastText.Size = UDim2.fromScale(1, 1)
	toastText.ZIndex = 91
	self.UI.Toast = toast
	self.UI.ToastText = toastText

	local settingsOverlay = Instance.new("Frame")
	settingsOverlay.BackgroundColor3 = self.Theme.black
	settingsOverlay.BackgroundTransparency = 1
	settingsOverlay.BorderSizePixel = 0
	settingsOverlay.Size = UDim2.fromScale(1, 1)
	settingsOverlay.Visible = false
	settingsOverlay.ZIndex = 100
	settingsOverlay.Parent = root
	self.UI.SettingsOverlay = settingsOverlay

	local drawer = Instance.new("Frame")
	drawer.BackgroundColor3 = self.Theme.surface
	drawer.BorderSizePixel = 0
	drawer.Position = UDim2.new(1, 20, 0, 0)
	drawer.Size = UDim2.fromOffset(374, 480)
	drawer.ZIndex = 101
	drawer.Parent = root
	self:stroke(drawer, 0.05, self.Theme.strokeBright)
	self.UI.SettingsDrawer = drawer

	local drawerHeader = Instance.new("Frame")
	drawerHeader.BackgroundTransparency = 1
	drawerHeader.Size = UDim2.new(1, 0, 0, 62)
	drawerHeader.ZIndex = 102
	drawerHeader.Parent = drawer

	local settingsTitle = self:text(drawerHeader, "Settings", 16, "bold", self.Theme.white)
	settingsTitle.Position = UDim2.fromOffset(16, 10)
	settingsTitle.Size = UDim2.new(1, -70, 0, 22)
	settingsTitle.ZIndex = 103

	local settingsSubtitle = self:text(drawerHeader, "Picker behavior and presentation", 10, "regular", self.Theme.muted)
	settingsSubtitle.Position = UDim2.fromOffset(16, 32)
	settingsSubtitle.Size = UDim2.new(1, -70, 0, 18)
	settingsSubtitle.ZIndex = 103

	local drawerClose, drawerCloseStroke, drawerCloseScale = self:button(drawerHeader, "×", 10)
	drawerClose.Position = UDim2.new(1, -46, 0, 14)
	drawerClose.Size = UDim2.fromOffset(32, 32)
	drawerClose.TextSize = 17
	drawerClose.ZIndex = 103
	self:bindButtonMotion(drawerClose, drawerCloseStroke, drawerCloseScale)

	local settingsList = Instance.new("ScrollingFrame")
	settingsList.BackgroundTransparency = 1
	settingsList.BorderSizePixel = 0
	settingsList.Position = UDim2.new(0, 0, 0, 62)
	settingsList.Size = UDim2.new(1, 0, 1, -62)
	settingsList.ScrollBarImageColor3 = self.Theme.white
	settingsList.ScrollBarImageTransparency = 0.82
	settingsList.ScrollBarThickness = 2
	settingsList.TopImage = ""
	settingsList.MidImage = ""
	settingsList.BottomImage = ""
	settingsList.ZIndex = 102
	settingsList.Parent = drawer
	self:padding(settingsList, 14, 14, 8, 16)

	local settingsLayout = Instance.new("UIListLayout")
	settingsLayout.Padding = UDim.new(0, 8)
	settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	settingsLayout.Parent = settingsList

	self:createToggle(settingsList, "Blur background", "Softens the game behind the picker", function()
		return self.Options.blur
	end, function(value)
		self.Options.blur = value
	end, function()
		self:updateBlur()
	end)

	self:createToggle(settingsList, "Reduce motion", "Uses shorter, simpler transitions", function()
		return self.Options.reduceMotion
	end, function(value)
		self.Options.reduceMotion = value
	end)

	self:createToggle(settingsList, "Confirm before loading", "Requires a second click on LOAD", function()
		return self.Options.confirmLoad
	end, function(value)
		self.Options.confirmLoad = value
	end)

	self:createToggle(settingsList, "Close after loading", "Closes the picker after a successful load", function()
		return self.Options.autoClose
	end, function(value)
		self.Options.autoClose = value
	end)

	self:createToggle(settingsList, "Cache commit lists", "Reuses fetched data when switching channels", function()
		return self.Options.cacheCommits
	end, function(value)
		self.Options.cacheCommits = value
	end)

	self:createToggle(settingsList, "Show file paths", "Shows the source file under each channel", function()
		return self.Options.showPath
	end, function(value)
		self.Options.showPath = value
	end, function()
		self:updateChannelButtons()
		if self.State.currentChannel then
			self.UI.ChannelPath.Text = self.Options.showPath and self.State.currentChannel.path or self.State.currentChannel.label .. " channel"
		end
	end)

	self:createToggle(settingsList, "Copy raw URL on load", "Copies the selected source URL automatically", function()
		return self.Options.copyRaw
	end, function(value)
		self.Options.copyRaw = value
	end)

	self:createToggle(settingsList, "Highlight newest commit", "Adds stronger contrast to the first result", function()
		return self.Options.highlightLatest
	end, function(value)
		self.Options.highlightLatest = value
	end, function()
		self:rebuildCurrent()
	end)

	self:createToggle(settingsList, "Compact commit cards", "Reduces card height and hides date text", function()
		return self.Options.compactRows
	end, function(value)
		self.Options.compactRows = value
	end, function()
		self:rebuildCurrent()
	end)

	self:createToggle(settingsList, "Show commit dates", "Displays the UTC author timestamp", function()
		return self.Options.showDate
	end, function(value)
		self.Options.showDate = value
	end, function()
		self:rebuildCurrent()
	end)

	self:createStepper(settingsList, "Commit count", "Number requested from GitHub", function()
		return self.Options.commitCount
	end, function(value)
		self.Options.commitCount = value
	end)

	local clearCache, clearCacheStroke, clearCacheScale = self:button(settingsList, "CLEAR COMMIT CACHE", 12)
	clearCache.BackgroundColor3 = self.Theme.surface2
	clearCache.Size = UDim2.new(1, 0, 0, 42)
	clearCache.TextColor3 = self.Theme.text
	clearCache.ZIndex = 103
	self:bindButtonMotion(clearCache, clearCacheStroke, clearCacheScale)

	self:connect(clearCache.MouseButton1Click, function()
		self:pulse(clearCache)
		self.State.cache = {}
		self:toast("Commit cache cleared")
	end)

	self:connect(settingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		settingsList.CanvasSize = UDim2.fromOffset(0, settingsLayout.AbsoluteContentSize.Y + 24)
	end)
	self:connect(cardLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		self:updateCanvas()
	end)
	self:connect(searchBox.Focused, function()
		self:tween(searchStroke, 0.15, { Transparency = 0, Color = self.Theme.strokeBright })
	end)
	self:connect(searchBox.FocusLost, function()
		self:tween(searchStroke, 0.15, { Transparency = 0.32, Color = self.Theme.stroke })
	end)
	self:connect(searchBox:GetPropertyChangedSignal("Text"), function()
		self.State.searchSerial += 1
		local serial = self.State.searchSerial
		task.delay(0.08, function()
			if serial == self.State.searchSerial and not self.State.closed then
				self:filterCards()
			end
		end)
	end)
	self:connect(refreshButton.MouseButton1Click, function()
		self:pulse(refreshButton)
		self:refreshCurrent()
	end)
	self:connect(settingsButton.MouseButton1Click, function()
		self:pulse(settingsButton)
		self:setSettingsOpen(true)
	end)
	self:connect(drawerClose.MouseButton1Click, function()
		self:pulse(drawerClose)
		self:setSettingsOpen(false)
	end)
	self:connect(settingsOverlay.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self:setSettingsOpen(false)
		end
	end)
	self:connect(minimizeButton.MouseButton1Click, function()
		self:pulse(minimizeButton)
		self:setMinimized(not self.State.minimized)
	end)
	self:connect(closeButton.MouseButton1Click, function()
		self:pulse(closeButton)
		self:close(false)
	end)
	self:connect(backdrop.InputBegan, function(input)
		if self.State.settingsOpen and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			self:setSettingsOpen(false)
		end
	end)

	self:createChannelButton(self.Channels.main, 1)
	self:createChannelButton(self.Channels.test, 2)

	guiii.draggerV2(root, topbar)
	self:updateScale()
	if Workspace and Workspace.CurrentCamera then
		self:connect(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
			self:updateScale()
		end)
	end
	if Workspace then
		self:connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
			self:updateScale()
		end)
	end
end

function App:start()
	self:createUI()
	if type(Environment) == "table" then
		Environment.__NA_VERSION_PICKER_CLOSE = function()
			self:close(true)
		end
	end
	self:updateBlur()
	local targetScale = self.UI.RootScale.Scale
	self.UI.RootScale.Scale = targetScale * 0.94
	self:tween(self.UI.Backdrop, 0.24, { BackgroundTransparency = 0.38 })
	self:tween(self.UI.RootScale, 0.34, { Scale = targetScale }, Enum.EasingStyle.Back)
	self:tween(self.UI.Root, 0.26, {
		GroupTransparency = 0,
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}, Enum.EasingStyle.Quart)
	self:openChannel(self.Channels.main, false)
	task.delay(0.45, function()
		if not self.State.closed then
			self:toast("Version archive ready")
		end
	end)
end

App:start()
