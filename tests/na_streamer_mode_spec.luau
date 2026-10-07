local snippets = {}
local checks, cases = 0, 0
local jobs, objects = {}, {}
local function check(ok, msg) checks += 1; assert(ok, msg) end
local function equal(a, b, msg) check(a == b, msg .. ": " .. tostring(a) .. " ~= " .. tostring(b)) end
local function queue(fn) jobs[#jobs + 1] = fn end
local function flush()
	local turns = 0
	while #jobs > 0 do
		turns += 1
		assert(turns < 100, "work does not settle")
		local batch = jobs
		jobs = {}
		for _, fn in batch do fn() end
	end
end
local function signal()
	local links = {}
	local obj = {}
	function obj:Connect(fn)
		local conn = { Connected = true }
		function conn:Disconnect() self.Connected = false end
		links[conn] = fn
		return conn
	end
	function obj:Fire(...)
		local snap = table.clone(links)
		for conn, fn in snap do if conn.Connected then fn(...) end end
	end
	function obj:Count()
		local n = 0
		for conn in links do if conn.Connected then n += 1 end end
		return n
	end
	return obj
end
local enums = setmetatable({}, { __index = function(t, k)
	local v = setmetatable({}, { __index = function(_, key) return k .. "." .. key end })
	rawset(t, k, v)
	return v
end })
local function color(r, g, b) return { R = r / 255, G = g / 255, B = b / 255 } end
local function dim(xs, xo, ys, yo) return { X = { Scale = xs, Offset = xo }, Y = { Scale = ys, Offset = yo } } end
local classes = { MeshPart = "BasePart", Part = "BasePart", SpecialMesh = "DataModelMesh", Texture = "Decal" }
local methods = {}
function methods:IsA(cls)
	local kind = self.ClassName
	while kind do if kind == cls then return true end; kind = classes[kind] end
	return cls == "Instance" or cls == "GuiObject" and ({ TextLabel = true, TextBox = true, TextButton = true, ImageLabel = true, ImageButton = true, Frame = true })[self.ClassName] == true
end
function methods:GetChildren() return table.clone(self.children) end
function methods:FindFirstChild(name)
	for _, child in self.children do if child.Name == name then return child end end
end
function methods:FindFirstChildOfClass(cls)
	for _, child in self.children do if child:IsA(cls) then return child end end
end
function methods:IsDescendantOf(root)
	local cur = self.Parent
	while cur do if cur == root then return true end; cur = cur.Parent end
	return false
end
function methods:FindFirstAncestorOfClass(cls)
	local cur = self.Parent
	while cur do if cur:IsA(cls) then return cur end; cur = cur.Parent end
end
function methods:GetPropertyChangedSignal(key)
	if not self.signals[key] then self.signals[key] = signal() end
	return self.signals[key]
end
function methods:GetAttribute(key) return self.attrs[key] end
function methods:SetAttribute(key, value) self.attrs[key] = value end
local function walk(root, fn)
	for _, child in root:GetChildren() do fn(child); walk(child, fn) end
end
local new
function methods:Clone()
	local copy = new(self.ClassName)
	for k, v in self.props do if k ~= "Parent" then copy.props[k] = v end end
	for _, child in self.children do child:Clone().Parent = copy end
	return copy
end
function methods:Destroy()
	self.Parent = nil
	for _, child in self:GetChildren() do child:Destroy() end
	self.dead = true
end
local meta = { __index = function(t, k)
	if methods[k] then return methods[k] end
	if t.props[k] ~= nil then return t.props[k] end
	return t.signals[k]
end, __newindex = function(t, k, value)
	if k == "dead" then rawset(t, k, value); return end
	if t.fail[k] then error("write rejected") end
	if t.ClassName == "CharacterMesh" and (k == "MeshId" or k == "BaseTextureId" or k == "OverlayTextureId") then assert(type(value) == "number", "wrong CharacterMesh property type") end
	local old = t.props[k]
	if old == value then return end
	if k == "Parent" then
		local all = { t }
		walk(t, function(child) all[#all + 1] = child end)
		local cur = old
		while cur do for _, child in all do cur.DescendantRemoving:Fire(child) end; cur = cur.Parent end
		if old then table.remove(old.children, table.find(old.children, t)); old.ChildRemoved:Fire(t) end
		t.props.Parent = value
		if value then value.children[#value.children + 1] = t end
		for _, child in all do child.AncestryChanged:Fire(child, child.Parent) end
		cur = value
		while cur do for _, child in all do cur.DescendantAdded:Fire(child) end; cur = cur.Parent end
		if value then value.ChildAdded:Fire(t) end
	else t.props[k] = value end
	t.writes[k] = (t.writes[k] or 0) + 1
	if t.signals[k] then t.signals[k]:Fire() end
	t.Changed:Fire(k)
end }
new = function(cls, parent)
	local obj = setmetatable({ ClassName = cls, children = {}, attrs = {}, signals = {}, props = { Name = cls }, writes = {}, fail = {} }, meta)
	for _, key in { "Changed", "AncestryChanged", "DescendantAdded", "DescendantRemoving", "ChildAdded", "ChildRemoved", "CharacterAdded" } do obj.signals[key] = signal() end
	if obj:IsA("GuiObject") then
		for k, v in { Text = "", PlaceholderText = "", Image = "", RichText = false, TextSize = 16, TextTransparency = 0, TextStrokeTransparency = 1, TextColor3 = "white", PlaceholderColor3 = "gray", FontFace = "Roboto", AutoLocalize = true, ShowNativeInput = true, TextScaled = false, TextWrapped = false, LineHeight = 1, ZIndex = 1, Visible = true, CursorPosition = -1, SelectionStart = -1 } do obj.props[k] = v end
	end
	if obj:IsA("BasePart") then
		for k, v in { Color = "red", Material = "Plastic", Reflectance = 0.2, LocalTransparencyModifier = 0, TextureID = "texture" } do obj.props[k] = v end
	elseif cls == "Humanoid" then
		for k, v in { DisplayName = "Alice", DisplayDistanceType = "Viewer", NameDisplayDistance = 100 } do obj.props[k] = v end
	elseif cls == "CharacterMesh" then obj.props.MeshId, obj.props.BaseTextureId, obj.props.OverlayTextureId = 42, 123, 456
	elseif cls == "SpecialMesh" then obj.props.MeshId, obj.props.TextureId, obj.props.VertexColor = "shape", "texture", "white"
	elseif cls == "Shirt" then obj.props.ShirtTemplate = "shirt"
	elseif cls == "Pants" then obj.props.PantsTemplate = "pants"
	elseif cls == "Decal" then obj.props.Transparency = 0 end
	objects[#objects + 1] = obj
	obj.Parent = parent
	return obj
end
local function inject(e, key)
	local fn, err = loadstring(snippets[key])
	assert(fn, err)
	setfenv(fn, e)
	fn()
end
local function setup()
	local e = setmetatable({}, { __index = getfenv() })
	e.Enum = enums
	e.Color3 = { fromRGB = color }
	e.Vector3 = { new = function(x, y, z) return { X = x, Y = y, Z = z } end }
	e.Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end }
	e.UDim2 = { new = dim }
	e.typeof = function(v) return type(v) == "table" and v.ClassName and "Instance" or typeof(v) end
	e.Spawn, e.Defer, e.Delay, e.Wait = queue, queue, function(_, fn) queue(fn) end, function() end
	e.Insert, e.Lower = table.insert, string.lower
	e.InstanceNew = new
	e.NAStuff = { StreamerModeEnabled = false, StreamerModeText = "User", StreamerModeGray = color(127, 127, 127), StreamerModeImage = "placeholder" }
	e.NAmanage = {}
	e.NAmanage.ensureWeakTable = function(t, mode) return setmetatable(t or {}, { __mode = mode }) end
	e.NAmanage.NewCancelToken = function() return { cancelled = false } end
	e.NAmanage.CancelTokenCancel = function(token) if token then token.cancelled = true end end
	e.budgets = 0
	e.NAmanage.WorkBudgetStep = function(work, batch)
		work.n = (work.n or 0) + 1
		if work.n % batch == 0 then
			e.budgets += 1
			if e.onBudget then e.onBudget() end
		end
	end
	e.settings = {}
	e.NAmanage.NASettingsSet = function(key, value) e.settings[key] = value end
	e.NAmanage.QueryDescendants = function(root, query)
		e.queries[#e.queries + 1] = { root = root, query = query }
		local list = {}
		walk(root, function(inst)
			if query == "BillboardGui >> GuiObject, SurfaceGui >> GuiObject" then
				if inst:IsA("GuiObject") and (inst:FindFirstAncestorOfClass("BillboardGui") or inst:FindFirstAncestorOfClass("SurfaceGui")) then list[#list + 1] = inst end
			else
				for cls in query:gmatch("[%w]+") do if inst:IsA(cls) then list[#list + 1] = inst; break end end
			end
		end)
		return list
	end
	e.queries = {}
	e.Services = { CoreGui = new("CoreGui"), Workspace = new("Workspace"), Players = new("Players"), StarterGui = new("StarterGui") }
	e.players = {}
	for i, name in { "Alice", "Ann" } do
		local p = new("Player", e.Services.Players)
		p.Name, p.DisplayName, p.UserId = name, name, i
		e.players[#e.players + 1] = p
	end
	e.Services.Players.props.LocalPlayer = e.players[1]
	e.gui = new("PlayerGui", e.players[1])
	e.hui = new("Folder", e.Services.CoreGui)
	e.screen = new("ScreenGui", e.hui)
	e.playerList, e.coreSets = false, 0
	e.__lt = { gs = function(name) return e.Services[name] end, cm = function(name, method, ...)
		if name == "Players" and method == "GetPlayers" then return e.players end
		if name == "StarterGui" then
			if e.coreFail then error("CoreGui unavailable") end
			if method == "GetCoreGuiEnabled" then return e.playerList end
			e.playerList = select(2, ...)
			e.coreSets += 1
		end
	end }
	e.SafeGetService = function(name) return e.Services[name] end
	e.NAlib = { groups = {} }
	e.NAlib.isProperty = function(inst, prop)
		if type(inst) ~= "table" then return nil end
		return inst.props and inst.props[prop] or inst[prop]
	end
	e.NAlib.setProperty = function(inst, prop, value)
		if inst.props[prop] == value then return true end
		return pcall(function() inst[prop] = value end)
	end
	e.NAlib.connect = function(key, conn)
		e.NAlib.groups[key] = e.NAlib.groups[key] or {}
		table.insert(e.NAlib.groups[key], conn)
	end
	e.NAlib.disconnect = function(key)
		for _, conn in e.NAlib.groups[key] or {} do conn:Disconnect() end
		e.NAlib.groups[key] = nil
	end
	e.NAlib.distinctHuiGrabber = function() return e.hui end
	e.NAmanage.getUI = function() return e.screen end
	e.NAmanage._pgHubGet = function() return { root = e.gui } end
	local function sub(root, spec)
		return root.DescendantAdded:Connect(function(inst)
			if spec.added and (not spec.filterAdded or spec.filterAdded(inst)) then spec.added(inst) end
		end)
	end
	e.NAmanage.cgSub = function(spec) return sub(e.Services.CoreGui, spec) end
	e.NAmanage.pgSub = function(spec) return sub(e.gui, spec) end
	e.NAmanage.wsSub = function(spec) return sub(e.Services.Workspace, spec) end
	e.NAmanage.descSub = sub
	e.NAmanage.descAdd = function(root, fn, filter) return sub(root, { added = fn, filterAdded = filter }) end
	e.NAmanage.playersSub = function(spec)
		e.playerSpec = spec
		return { Disconnect = function() e.playerSpec = nil end }
	end
	e.NAmanage.ForEachDescendantYield = function(root, fn) walk(root, fn) end
	inject(e, "engine")
	return e
end
local function test(name, fn)
	fn()
	flush()
	cases += 1
	print("PASS: " .. name)
end
local function stop(e)
	e.NAmanage.setStreamerMode(false, { save = false, silent = true, restoreAsync = false })
	flush()
	equal(e.NAmanage.StreamerCacheCount(e.NAmanage.StreamerGetState().cache), 0, "cache not released")
end

test("matching preserves words, markup, entities and literal replacements", function()
	local e = setup()
	e.NAmanage.StreamerRefreshNameTokens()
	equal(e.NAmanage.StreamerMaskText("ALICE, Ann!"), "User, User!", "case variation leaked")
	e.NAmanage.StreamerAddName("Alice Smith")
	e.NAmanage.StreamerAddName("Лена")
	e.NAmanage.StreamerAddName("A&B")
	equal(e.NAmanage.StreamerMaskText("ALICE, Ann and Alice Smith!"), "User, User and User!", "case or longest match failed")
	equal(e.NAmanage.StreamerMaskText("announcement Annette Alice_2 Malice"), "announcement Annette Alice_2 Malice", "ordinary words were corrupted")
	equal(e.NAmanage.StreamerMaskText('<font face="Alice">ALICE &amp; <b>Ann</b></font>', true), '<font face="Alice">User &amp; <b>User</b></font>', "markup or entities corrupted")
	equal(e.NAmanage.StreamerMaskText("<b>Al</b>ice", true), "<b>User</b>", "split styled name leaked")
	equal(e.NAmanage.StreamerMaskText("A&amp;B / &#65;lice / &#x41;nn", true), "User / User / User", "encoded name leaked")
	equal(e.NAmanage.StreamerMaskText("Лена привет"), "User привет", "unicode name leaked")
	e.NAStuff.StreamerModeText = "%1 <Private>"
	equal(e.NAmanage.StreamerMaskText("Alice"), "%1 <Private>", "replacement interpreted as a pattern")
	equal(e.NAmanage.StreamerMaskText("<b>Alice</b>", true), "<b>%1 &lt;Private&gt;</b>", "replacement injected markup")
end)

test("editable values and cursor state survive visual masking", function()
	local e = setup()
	local box = new("TextBox", e.screen)
	box.Text, box.CursorPosition, box.SelectionStart = "goto Alice", 11, 6
	box.TextTransparency, box.TextStrokeTransparency = 0.25, 0.4
	new("UIPadding", box)
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(box.Text, "goto Alice", "command input was rewritten")
	equal(box.CursorPosition, 11, "cursor was moved")
	equal(box.SelectionStart, 6, "selection was moved")
	local overlay = box:FindFirstChild("NAStreamerMask")
	check(overlay and overlay.Text == "goto User", "visual input was not masked")
	check(not overlay.Active and not overlay.Selectable, "overlay captures input")
	equal(box.TextTransparency, 1, "raw input remains visible")
	equal(overlay.TextTransparency, 0.25, "input appearance lost")
	equal(box.ShowNativeInput, false, "native input exposes the value")
	check(not e.NAmanage.StreamerIsTarget(overlay), "overlay masks itself recursively")
	box.Text = "hello"
	equal(box.TextTransparency, 0.25, "unmasked input stays hidden")
	check(not box:FindFirstChild("NAStreamerMask"), "unused overlay survives")
	box.Text, box.PlaceholderText = "", "Find Alice"
	equal(box.PlaceholderText, "Find Alice", "placeholder value rewritten")
	equal(box:FindFirstChild("NAStreamerMask").Text, "Find User", "placeholder not masked")
	box.Text = "Ann"
	box.TextColor3, box.FontFace, box.TextSize = "blue", "BuilderSans", 22
	box.TextTransparency = 0.5
	check(box:FindFirstChild("NAStreamerMask").TextColor3 == "blue", "input style did not refresh")
	equal(box:FindFirstChild("NAStreamerMask").TextTransparency, 0.5, "latest input transparency lost")
	stop(e)
	equal(box.Text, "Ann", "restoration rewrote actual input")
	equal(box.PlaceholderText, "Find Alice", "restoration lost placeholder")
	equal(box.TextTransparency, 0.5, "latest transparency not restored")
	equal(box.ShowNativeInput, true, "native input preference lost")
	check(not box:FindFirstChild("NAStreamerMask"), "overlay leaked after disable")
end)

test("recycled labels and avatar thumbnails restore their latest values", function()
	local e = setup()
	local row = new("TextLabel", e.screen)
	row.Text = "Alice joined"
	local image = new("ImageLabel", e.screen)
	image.Image = "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150"
	local asset = new("ImageLabel", e.screen)
	asset.Image = "rbxthumb://type=Asset&id=123&w=150&h=150"
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(row.Text, "User joined", "label not masked")
	equal(image.Image, "placeholder", "avatar leaked")
	equal(asset.Image, "rbxthumb://type=Asset&id=123&w=150&h=150", "ordinary asset thumbnail hidden")
	row.Text = "Ann left"
	equal(row.Text, "User left", "reused row kept old identity")
	image.Image = "rbxthumb://type=AvatarBust&id=2&w=150&h=150"
	row.Parent = nil
	equal(row.Text, "Ann left", "detached pool row keeps stale mask")
	row.Parent = e.screen
	equal(row.Text, "User left", "reattached row leaks identity")
	e.NAmanage.setStreamerMode(false, { silent = true })
	row.Text = "new text from game"
	image.Image = "new image from game"
	flush()
	equal(row.Text, "new text from game", "restore overwrote newer text")
	equal(image.Image, "new image from game", "restore overwrote newer image")
	equal(e.NAmanage.StreamerCacheCount(e.NAmanage.StreamerGetState().cache), 0, "records leaked")
end)

test("avatars update safely and restore changes without renaming rig objects", function()
	local e = setup()
	local char = new("Model", e.Services.Workspace)
	local hum = new("Humanoid", char)
	local part = new("MeshPart", char)
	local mesh = new("CharacterMesh", char)
	local nextChar = new("Model", e.Services.Workspace)
	new("Humanoid", nextChar)
	e.players[2].Character = nextChar
	local file = new("SpecialMesh", part)
	local shirt = new("Shirt", char)
	e.players[1].Character = char
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(hum.Name, "Humanoid", "rig lookup broken by renaming")
	equal(mesh.MeshId, 42, "character geometry changed")
	equal(file.MeshId, "shape", "special mesh geometry changed")
	equal(mesh.BaseTextureId, 0, "R6 texture not masked")
	equal(mesh.OverlayTextureId, 0, "R6 overlay not masked")
	equal(shirt.ShirtTemplate, "", "clothes not masked")
	part.Color = "green"
	part.TextureID = "new texture"
	shirt.ShirtTemplate = "new shirt"
	hum.DisplayName = "New Display"
	equal(part.Color, e.NAStuff.StreamerModeGray, "changed avatar color leaked")
	local acc = new("Accessory", char)
	local handle = new("Part", acc)
	equal(handle.LocalTransparencyModifier, 1, "late accessory leaked")
	local loose = new("Part", acc)
	loose.Parent = char
	flush()
	equal(loose.LocalTransparencyModifier, 0, "former accessory remains invisible as a body part")
	part.Parent = nextChar
	char.Parent = nil
	flush()
	equal(part.Color, e.NAStuff.StreamerModeGray, "old character cleanup unmasks a transferred part")
	e.playerSpec.removing(e.players[2])
	equal(part.Color, e.NAStuff.StreamerModeGray, "departing player's remaining avatar unmasks early")
	stop(e)
	equal(part.Color, "green", "latest body color lost")
	equal(part.TextureID, "new texture", "latest body texture lost")
	equal(shirt.ShirtTemplate, "new shirt", "latest clothing lost")
	equal(hum.DisplayName, "New Display", "latest display name lost")
	equal(handle.LocalTransparencyModifier, 0, "accessory stays hidden")
end)

test("rapid toggles and cancelled scans never restore an active mask", function()
	local e = setup()
	local row = new("TextLabel", e.screen)
	row.Text = "Alice"
	for _ = 1, 30 do e.NAmanage.setStreamerMode(true, { silent = true }); e.NAmanage.setStreamerMode(false, { silent = true }) end
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(row.Text, "User", "stale callback undid active mode")
	equal(row:GetPropertyChangedSignal("Text"):Count(), 1, "duplicate target watchers")
	local state = e.NAmanage.StreamerGetState()
	e.NAmanage.setStreamerMode(true, { silent = true, force = true })
	flush()
	equal(row:GetPropertyChangedSignal("Text"):Count(), 1, "forced mode duplicates callbacks")
	e.playerSpec.removing(e.players[2])
	table.remove(e.players, 2)
	e.NAmanage.StreamerScheduleNameRefresh(true)
	flush()
	row.Text = "Ann departed"
	equal(row.Text, "User departed", "departed player name leaked from history")
	stop(e)
	equal(row.Text, "Ann departed", "last original text lost")
	equal(row:GetPropertyChangedSignal("Text"):Count(), 0, "target callback leaked")
	check(not next(e.NAlib.groups), "root subscriptions leaked")
	check(state.token == nil and state.restoreToken == nil, "worker token leaked")
end)

test("new names, chat identities, and replacement PlayerGui are covered", function()
	local e = setup()
	e.chatFrame, e.NAChat, e.conversationHistory = new("Frame", e.screen), { users = { { username = "RemoteName", displayName = "Remote Display" } } }, { public = { { username = "FormerName", reply = { username = "ReplyName" } } } }
	inject(e, "chat")
	local row = new("TextLabel", e.screen)
	row.Text = "RemoteName / FormerName / ReplyName"
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(row.Text, "User / User / User", "NA Chat identity outside game roster leaked")
	local named = new("TextLabel", e.screen)
	named.Text = "FutureName"
	e.NAmanage.StreamerTrackIdentity({ username = "FutureName", displayName = "Future Display" })
	flush()
	equal(named.Text, "User", "new NA Chat identity not applied to cached labels")
	e.players[1].DisplayName = "NewAlice"
	flush()
	row.Text = "NewAlice"
	equal(row.Text, "User", "display name update leaked")
	local gui = new("PlayerGui")
	local label = new("TextLabel", gui)
	label.Text = "Alice"
	e.gui.Parent = nil
	e.gui = gui
	gui.Parent = e.players[1]
	flush()
	equal(label.Text, "User", "replacement PlayerGui not scanned")
	stop(e)
end)

test("targeted scans and cached masks keep repeated updates bounded", function()
	local e = setup()
	for _ = 1, 2000 do new("Part", e.Services.Workspace) end
	local board = new("BillboardGui", e.Services.Workspace)
	local label = new("TextLabel", board)
	label.Text = "Alice"
	local icon = new("TextLabel", e.screen)
	icon.FontFace = { Family = "rbxasset://LuaPackages/BuilderIcons/BuilderIcons.json" }
	icon.Text = "Alice"
	local rows = {}
	for i = 1, 1000 do
		local row = new("TextLabel", e.screen)
		row.Text = "Alice " .. i
		rows[i] = row
	end
	local calls = 0
	local mask = e.NAmanage.StreamerMaskText
	e.NAmanage.StreamerMaskText = function(...) calls += 1; return mask(...) end
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(label.Text, "User", "world nameplate leaked")
	equal(icon.Text, "Alice", "icon ligature was replaced with text")
	local initial = calls
	for _ = 1, 20 do for _, row in rows do e.NAmanage.StreamerScrubInstance(row) end end
	equal(calls, initial, "unchanged labels rerun name matching")
	local core = 0
	for _, item in e.queries do
		check(item.query ~= "Instance", "full instance scan used")
		if item.root == e.Services.CoreGui then core += 1 end
	end
	equal(core, 1, "nested UI roots scanned twice")
	check(e.budgets > 10, "large scan does not yield")
	for i, row in rows do equal(row.Text, "User " .. i, "row not masked") end
	stop(e)
end)


test("chat rows measure masked text and refresh when the mode changes", function()
	local e = setup()
	e.chatFrame = new("Frame", e.screen)
	e.NAmanage.NAChat_GetCompactMessages = function() return false end
	e.NAmanage.NAChat_GetEntryAvatarUserId = function() return nil end
	e.NAmanage.NAChat_GetMessageMeasureWidth = function() return 8 end
	e.NAmanage.NAChat_GetMessageTextSize = function() return 14 end
	e.buildChatEntryText = function(entry) return "<b>" .. entry.text .. "</b>" end
	e.Services.TextService = { GetTextSize = function(_, text, _, _, size) return { Y = math.ceil(#text / size.X) * 14 } end }
	local invalidations, refreshes = 0, 0
	e.NAmanage.NAChat_InvalidateVirtualHeights = function() invalidations += 1 end
	e.NAmanage.NAChat_QueueVirtualRefresh = function(bottom) check(not bottom, "streamer toggle forces scrolling"); refreshes += 1 end
	inject(e, "measure")
	inject(e, "callback")
	equal(e.NAmanage.NAChat_MeasureEntryHeight({ text = "Ann Ann" }), 24, "ordinary chat height changed")
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(e.NAmanage.NAChat_MeasureEntryHeight({ text = "Ann Ann" }), 36, "masked text clips because raw text was measured")
	check(invalidations > 0 and refreshes > 0, "chat does not reflow after enable")
	local before = invalidations
	stop(e)
	check(invalidations > before, "chat does not reflow after disable")
end)

test("player-list settings and failed restoration preserve ownership", function()
	local e = setup()
	local row = new("TextLabel", e.screen)
	row.Text = "Alice"
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	stop(e)
	equal(e.playerList, false, "disabled player list enabled by restore")
	e.playerList = true
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	equal(e.playerList, false, "player list remains visible")
	row.fail.Text = true
	e.NAmanage.setStreamerMode(false, { silent = true, restoreAsync = false })
	check(e.NAmanage.StreamerGetState().cache[row], "failed restore lost original")
	row.fail.Text = nil
	flush()
	equal(row.Text, "Alice", "failed restore was not retried")
	equal(e.playerList, true, "original player-list setting lost")
	equal(e.NAmanage.StreamerCacheCount(e.NAmanage.StreamerGetState().cache), 0, "retry records leaked")
	e.NAmanage.setStreamerMode(true, { silent = true })
	flush()
	e.NAmanage.setStreamerMode(false, { silent = true })
	e.NAmanage.setStreamerMode(false, { silent = true, restoreAsync = false })
	equal(row.Text, "Alice", "unload does not finish an already pending restoration")
	equal(e.NAmanage.StreamerCacheCount(e.NAmanage.StreamerGetState().cache), 0, "pending cleanup survives synchronous disable")
	flush()
end)

print(string.format("PASS: %d cases, %d assertions", cases, checks))
