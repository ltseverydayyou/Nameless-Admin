if getgenv().RealNamelessLoaded then return end

pcall(function() getgenv().RealNamelessLoaded=true end)
pcall(function() getgenv().NATestingVer=false end)
pcall(function() getgenv().cdshkjvcdsojuefdwonjwojgrwoijuhegr="FIWUIUR" end)

NAbegin=tick()
CMDAUTOFILL = {}

local function SafeGetService(name)
	local Service = (game.GetService);
	local Reference = (cloneref) or function(reference) return reference end
	return Reference(Service(game, name));
end

local HttpService=SafeGetService('HttpService');
local Lower = string.lower;
local Sub = string.sub;
local GSub = string.gsub;
local Find = string.find;
local Match = string.match;
local Format = string.format;
local Unpack = table.unpack;
local Insert = table.insert;
local Spawn = task.spawn;
local Delay = task.delay;
local Wait = task.wait;
local Discover = table.find;
local Concat = table.concat;
local Defer = task.defer;
local mouse=SafeGetService("Players").LocalPlayer:GetMouse()
local Waypoints = {}
local Bindings = Bindings or {}
local NAStuff = {
	NASCREENGUI=nil; --Getmodel("rbxassetid://140418556029404")
	NAjson = nil;
	nuhuhNotifs = true;
	KeybindConnection = nil;
}
local interactTbl = {
	click = {};
	proxy = {};
	touch = {};
}
local Notification = nil
local mainName = 'Nameless Admin'
local testingName = 'NA Testing'
local adminName = 'NA'
local inviteLink = "https://discord.gg/zzjYhtMGFD"
local cmd={}
local NAmanage={}
local searchIndex = {}
local prevVisible, results = {}, {}
local lastSearchText, gen = "", 0
local NAImageAssets = {
	Icon = "NAnew.png";
	sWare = "ScriptWare.png";
	Sheet = "sheet.png";
	Inlet = "Inlet.png";
	Stud = "oldStud.png";
	bk = "SkyBk.png";
	dn = "SkyDn.png";
	ft = "SkyFt.png";
	lf = "SkyLf.png";
	rt = "SkyRt.png";
	up = "SkyUp.png";
}
local prefixCheck = ";"
local NAScale = 1
local NAUIScale = 1
local flingManager = {
	FlingOldPos = nil;
	lFlingOldPos = nil;
	cFlingOldPos = nil;
}
local settingsLight = {
	range = 30;
	brightness = 1;
	color = Color3.new(1,1,1);
	LIGHTER = nil;
}
local events = {"OnSpawned","OnDeath","OnChatted","OnDamage","OnJoin","OnLeave"}
local morphTarget = ""
NASESSIONSTARTEDIDK = os.clock()
NAlib={}
NAgui={}
NACOLOREDELEMENTS={}
cmdNAnum=0
NAQoTEnabled = nil
NAiconSaveEnabled = nil
NAUISTROKER = Color3.fromRGB(148, 93, 255)
NATOPBARVISIBLE = true

for _, ev in ipairs(events) do
	if type(Bindings[ev]) ~= "table" then
		Bindings[ev] = {}
	end
end

function isAprilFools()
	local d = os.date("*t")
	return (d.month == 4 and d.day == 1) or getgenv().ActivateAprilMode or false
end

function yayApril(isTesting)
	local baseNames = {
		"Clueless", "Gay", "Infinite", "Sussy", "Broken", "Shadow", "Quirky",
		"Zoomy", "Wacky", "Booba", "Spicy", "Meme", "Doofy", "Silly",
		"Goblin", "Bingus", "Chonky", "Floofy", "Yeety", "Bonky", "Derpy",
		"Cheesy", "Nugget", "Funky", "Floppy", "Chunky", "Snazzy", "Wonky",
		"Goober", "Dorky", "Zany", "Glitchy", "Bubbly", "Wizzy", "Turbo",
		"Pixel", "Nifty", "Jazzy", "Rascal", "Muddled", "Quasar", "Nimbus",
		"Echo", "Froggy", "Gobsmack", "Hiccup", "Jinx", "Kooky", "Loco",
		"Mango", "Noodle", "Oddball", "Peculiar", "Quibble", "Rumble",
		"Snickle", "Tango", "Umbra", "Velcro", "Widdle", "Yonder", "Zephyr",
		"Bamboozle", "Cranky", "Doodle", "Eerie", "Frisky", "Gizmo", "Hazy",
		"Icicle", "Jolly", "Karma", "Lullaby", "Mystic", "Nebula", "Opal",
		"Poppy", "Riddle", "Slinky", "Tickle", "Vortex", "Whimsy", "Xenon",
		"Yummy", "Zodiac", "Astral", "Blizzard", "Cobalt", "Drifter", "Ember",
		"Flux", "Glacier", "Harpy", "Inferno", "Jester", "Katana", "Labyrinth",
		"Mirage", "Nomad", "Oracle", "Phantom", "Quill", "Rogue", "Specter",
		"Tempest", "Uproar", "Vagabond", "Wraith", "Xylophone", "Yoshi", "Zenith",
		"Arpeggio", "Basilisk", "Catalyst", "Dynamo", "Equinox", "Fortune",
		"Griffin", "Horizon", "Illusion", "Jubilee", "Kismet", "Labyrinthine",
		"Monsoon", "Nightfall", "Obsidian", "Paradox", "Quantum", "Requiem",
		"Serenade", "Trilogy", "Unicorn", "Vortexial", "Wanderer", "Xenith",
		"Yield", "Zeppelin", "Avalanche", "Banshee", "Comet", "Delta", "Eclipse",
		"Fable", "Golem", "Helix", "Isotope", "Jargon", "Kodiak", "Lynx",
		"Maelstrom", "Nimbus", "Oasis", "Pulse", "Quasar", "Rift", "Savage",
		"Tempestuous", "Undertow", "Vertex", "Wavelength", "Xanadu", "Yukon",
		"Zephyrine", "Apex", "Bravado", "Crescent", "Drizzle", "Emissary",
		"Frenzy", "Gargoyle", "Harbinger", "Incognito", "Jubilation", "Kaleidoscope",
		"Labour", "Mandala", "Nirvana", "Odyssey", "Palindrome", "Quintessence",
		"Renaissance", "Symphony", "Tapestry", "Utopia", "Virtuoso", "Whirlpool",
		"Xeme", "Yonderly", "Zenobia"
	}

	local suffix = isTesting and "Testing" or "Admin"
	local name = baseNames[math.random(#baseNames)]

	return name.." "..suffix
end

function MockText(text)
	local result = {}
	local toggle = true
	local glitchChars = {"̶", "̷", "̸", "̹", "̺", "̻", "͓", "͔", "͘", "͜", "͞", "͟", "͢"}

	math.randomseed(os.time())

	for i = 1, #text do
		local char = text:sub(i, i)
		if char:match("%a") then
			local transformed = toggle and char:upper() or char:lower()
			toggle = not toggle

			if math.random() < 0.15 then
				local glitch = glitchChars[math.random(#glitchChars)]
				transformed = transformed..glitch
			end

			Insert(result, transformed)
		else
			Insert(result, char)
		end
	end
	return Concat(result)
end

function maybeMock(text)
	return isAprilFools() and MockText(text) or text
end

if getgenv().NATestingVer then
	if isAprilFools() then
		testingName = yayApril(true)
		testingName = maybeMock(testingName)
	end
	adminName = testingName
else
	if isAprilFools() then
		mainName = yayApril(false)
		mainName = maybeMock(mainName)
	end
	adminName = mainName
end

repeat
	local success, result = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NamelessAdminNotifications.lua"))()
	end)

	if success then
		Notification = result
	else
		warn(Format("[%d] Failed to load notification module: %s | retrying...", math.random(100000, 999999), tostring(result)))
		Wait(0.3)
	end
until Notification

local Notify = Notification.Notify
local Window = Notification.Window
local Popup  = Notification.Popup

function DoNotif(text, duration, title)
	Notify({
		Title = title or adminName or nil,
		Description = text or "something",
		Duration = duration or 5
	})
end

function DebugNotif(text, duration, title)
	if not NAStuff.nuhuhNotifs then return end
	Notify({
		Title = title or adminName or nil,
		Description = text or "something",
		Duration = duration or 5
	})
end

function DoWindow(text, title)
	Window({
		Title = title or adminName or nil,
		Description = text or "something",
	})
end

function DoPopup(text, title)
	Popup({
		Title = title or adminName or nil,
		Description = text or "something",
	})
end

function NACaller(fn, ...)
	local args = {...}
	local function wrapped()
		return fn(unpack(args))
	end

	local t = table.pack(xpcall(wrapped, function(msg)
		return debug.traceback(msg, 2)
	end))

	if not t[1] then
		local err = t[2]
		warn("NA script error:\n"..err)

		Popup({
			Title       = adminName or "Oops!",
			Description = Format(
				"Oops! Something went wrong. If this keeps happening or seems serious, please let the owner know.\n\nDetails:\n%s",
				err
			),
			Buttons     = {
				{
					Text = "Copy Error",
					Callback = function()
						if setclipboard then
							setclipboard(err)
							DoNotif("Error details copied to clipboard!")
						else
							DoWindow("Error details:\n"..err)
						end
					end
				},
				{
					Text = "Discord Server",
					Callback = function()
						if setclipboard then
							setclipboard(inviteLink)
							DoNotif("Discord link copied to clipboard!")
						else
							DoWindow("Server Invite: "..inviteLink)
						end
					end
				}
			}
		})
	end

	return Unpack(t, 1, t.n)
end

NACaller(function()
	repeat
		Wait(0.1)
		local okFetch, raw = NACaller(game.HttpGet, game, "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/NA%20stuff.json")
		if okFetch then
			local okDecode, decoded = NACaller(HttpService.JSONDecode, HttpService, raw)
			if okDecode and type(decoded) == "table" then
				NAStuff.NAjson = decoded
			end
		end
	until NAStuff.NAjson
end)

function rStringgg()
	local length = math.random(10, 20)
	local result = {}
	local glitchMarks = {"̶", "̷", "̸", "̹", "̺", "̻", "͓", "͔", "͘", "͜", "͞", "͟", "͢"}

	for i = 1, length do
		local char = string.char(math.random(32, 126))
		Insert(result, char)
		if math.random() < 0.5 then
			local numGlitches = math.random(1, 4)
			for j = 1, numGlitches do
				Insert(result, glitchMarks[math.random(#glitchMarks)])
			end
		end
	end

	if math.random() < 0.3 then
		Insert(result, utf8.char(math.random(0x0300, 0x036F)))
	end

	if math.random() < 0.1 then
		Insert(result, "\0")
	end

	if math.random() < 0.1 then
		Insert(result, string.rep("​", math.random(5, 20)))
	end

	if math.random() < 0.2 then
		Insert(result, utf8.char(0x202E))
	end

	return Concat(result)
end

function NAProtection(inst,var)
	if not inst then return end
	if var then
		inst[var] = "\0"
	else
		inst.Name   = "\0"
	end
	inst.Archivable = false
end

function NaProtectUI(gui)
	local RunService = SafeGetService("RunService")
	local Players    = SafeGetService("Players")
	local CoreGui    = SafeGetService("CoreGui")
	local INV = "\0"
	local MAX_DO = 0x7FFFFFFF
	local target = (gethui and gethui())
		or (CoreGui:FindFirstChild("RobloxGui") or CoreGui:FindFirstChildWhichIsA("ScreenGui") or CoreGui)
		or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
	if not target then return end
	pcall(function() gui.Archivable = false end)
	gui.Name   = INV
	gui.Parent = target
	if gui:IsA("ScreenGui") then
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		gui.DisplayOrder   = MAX_DO
		gui.ResetOnSpawn   = false
		gui.IgnoreGuiInset = true
	end
	local props = {
		Parent         = target,
		Name           = INV,
		Archivable     = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		DisplayOrder   = MAX_DO,
		ResetOnSpawn   = false,
		IgnoreGuiInset = true,
	}
	if not gui:IsA("ScreenGui") then
		props.ZIndexBehavior = nil
		props.DisplayOrder   = nil
		props.ResetOnSpawn   = nil
		props.IgnoreGuiInset = nil
	end
	for prop, val in pairs(props) do
		gui:GetPropertyChangedSignal(prop):Connect(function()
			if gui[prop] ~= val then
				pcall(function() gui[prop] = val end)
			end
		end)
	end
	gui.AncestryChanged:Connect(function(_, newParent)
		if gui.Parent ~= target then
			pcall(function() gui.Parent = target end)
		end
	end)
	local hb
	hb = RunService.Heartbeat:Connect(function()
		for prop, val in pairs(props) do
			if gui[prop] ~= val then
				pcall(function() gui[prop] = val end)
			end
		end
		if not gui.Parent then
			pcall(function() hb:Disconnect() end)
		end
	end)
	return gui
end

NAmanage.centerFrame = function(f)
	local cam = workspace.CurrentCamera
	local vp = cam.ViewportSize
	local totalX = f.Size.X.Scale + (f.Size.X.Offset / vp.X)
	local totalY = f.Size.Y.Scale + (f.Size.Y.Offset / vp.Y)
	f.Position = UDim2.new(
		0.5 - totalX/2, 0,
		0.5 - totalY/2, 0
	)
end

NAmanage.guiCHECKINGAHHHHH=function()
	return (gethui and gethui()) or SafeGetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or SafeGetService("CoreGui") or SafeGetService("Players").LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
end

function InstanceNew(c,p)
	local inst = Instance.new(c)
	if p then inst.Parent = p end
	inst.Name = "\0"
	return inst
end

function countDictNA(tbl)
	local count = 0
	for _ in pairs(tbl) do
		count += 1
	end
	return count
end

--[[ Version ]]--
local curVer = isAprilFools() and Format(" V%d.%d.%d", math.random(1, 99), math.random(0, 99), math.random(0, 99)) or NAStuff.NAjson and " V"..NAStuff.NAjson.ver or ""

function getSeasonEmoji()
	local date = os.date("*t")
	local month = date.month
	local day = date.day

	if month == 1 and day == 1 then
		return '🎉' -- New Year's Day
	elseif month == 2 and day == 14 then
		return '❤️' -- Valentine's Day
	elseif month == 2 and day >= 1 and day <= 21 then
		return '🧧' -- Chinese New Year (approximate)
	elseif month == 3 and day == 17 then
		return '☘️' -- St. Patrick's Day
	elseif month == 4 and day >= 1 and day <= 15 then
		return '🥚' -- Easter (approximate)
	elseif month == 5 and day >= 8 and day <= 14 then
		return '💐' -- Mother's Day (approximate second Sunday)
	elseif month == 6 and day >= 15 and day <= 21 then
		return '👔' -- Father's Day (approximate third Sunday)
	elseif month == 6 and day == 21 then
		return '☀️' -- Summer Solstice
	elseif month == 9 and day == 22 then
		return '🍂' -- Autumn Equinox
	elseif month == 10 and day == 31 then
		return '🎃' -- Halloween
	elseif month == 11 and day >= 22 and day <= 28 then
		return '🦃' -- Thanksgiving (approximate fourth Thursday)
	elseif month == 12 and day == 25 then
		return '🎄' -- Christmas
	elseif month == 12 and day == 31 then
		return '🎆' -- New Year's Eve
	end

	if month == 12 or month <= 2 then
		return '❄️' -- Winter
	elseif month >= 3 and month <= 5 then
		return '🌸' -- Spring
	elseif month >= 6 and month <= 8 then
		return '☀️' -- Summer
	elseif month >= 9 and month <= 11 then
		return '🍂' -- Autumn
	end

	return ''
end

if not gethui then
	getgenv().gethui=function()
		return NAmanage.guiCHECKINGAHHHHH()
	end
end

if (identifyexecutor() == "Solara" or identifyexecutor() == "Xeno") or not fireproximityprompt then
	getgenv().fireproximityprompt=function(pp)
		local oldenabled=pp.Enabled
		local oldhold=pp.HoldDuration
		local oldrlos=pp.RequiresLineOfSight
		pp.Enabled=true
		pp.HoldDuration=0
		pp.RequiresLineOfSight=false
		Wait(.23)
		pp:InputHoldBegin()
		Wait()
		pp:InputHoldEnd()
		Wait(.1)
		pp.Enabled=pp.Enabled
		pp.HoldDuration=pp.HoldDuration
		pp.RequiresLineOfSight=pp.RequiresLineOfSight
	end
end

if not game:IsLoaded() then
	local message = InstanceNew("Message")
	message.Text = adminName.." is waiting for the game to load"
	NaProtectUI(message)
	game.Loaded:Wait()

	repeat Wait(.1) until SafeGetService("Players").LocalPlayer
	message:Destroy()
end

local JoinLeaveConfig = {
	JoinLog = false;
	LeaveLog = false;
	SaveLog = false;
}
local opt={
	prefix=prefixCheck;
	NAupdDate='unknown'; --month,day,year
	githubUrl = '';
	loader='';
	NAUILOADER='';
	NAAUTOSCALER=nil;
	NA_storage=nil;--Stupid Ahh script removing folders
	NAREQUEST = request or http_request or (syn and syn.request) or function() end;
	queueteleport=(syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or function() end;
	hiddenprop=(sethiddenproperty or set_hidden_property or set_hidden_prop) or function() end;
	ctrlModule = nil;
	currentTagText = "Tag";
	currentTagColor = Color3.fromRGB(0, 255, 170);
	currentTagRGB = false;
	saveTag = false;
}

if getgenv().NATestingVer then
	opt.loader=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"))();]]
	opt.githubUrl="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?path=NA%20testing.lua"
	opt.NAUILOADER="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/NAUITEST.lua"
else
	opt.loader=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))();]]
	opt.githubUrl="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?path=Source.lua"
	opt.NAUILOADER="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/NAUI.lua"
end

--Custom file functions checker checker
local CustomFunctionSupport=isfile and isfolder and writefile and readfile and listfiles and appendfile;
local FileSupport = isfile and isfolder and writefile and readfile and makefolder
local NAfiles = {
	NAFILEPATH = "Nameless-Admin";
	NAWAYPOINTFILEPATH = "Nameless-Admin/Waypoints";
	NAPLUGINFILEPATH = "Nameless-Admin/Plugins";
	NAASSETSFILEPATH = "Nameless-Admin/Assets";
	NAPREFIXPATH = "Nameless-Admin/Prefix.txt";
	NABUTTONSIZEPATH = "Nameless-Admin/ButtonSize.txt";
	NAUISIZEPATH = "Nameless-Admin/UIScale.txt";
	NAQOTPATH = "Nameless-Admin/QueueOnTeleport.txt";
	NAALIASPATH = "Nameless-Admin/Aliases.json";
	NAICONPOSPATH = "Nameless-Admin/IconPosition.json";
	NAUSERBUTTONSPATH = "Nameless-Admin/UserButtons.json";
	NAAUTOEXECPATH = "Nameless-Admin/AutoExecCommands.json";
	NAPREDICTIONPATH = "Nameless-Admin/Prediction.txt";
	NASTROKETHINGY = "Nameless-Admin/NAUIStroker.txt";
	NAJOINLEAVE = "Nameless-Admin/JoinLeave.json";
	NAJOINLEAVELOG = "Nameless-Admin/JoinLeaveLog.txt";
	NACHATLOGS = "Nameless-Admin/ChatLogs.txt";
	NACHATTAG = "Nameless-Admin/ChatTag.json";
	NATOPBAR = "Nameless-Admin/TopBarApp.txt";
	NANOTIFSTOGGLE = "Nameless-Admin/NotifsTgl.txt";
	NABINDERS = "Nameless-Admin/Binders.json";
}
NAUserButtons = {}
UserButtonGuiList = {}
NAEXECDATA = NAEXECDATA or {commands = {}, args = {}}
doPREDICTION = true

-- Creates folder & files for Prefix, Plugins, and etc
if FileSupport then
	if not isfolder(NAfiles.NAFILEPATH) then
		makefolder(NAfiles.NAFILEPATH)
	end

	if not isfolder(NAfiles.NAWAYPOINTFILEPATH) then
		makefolder(NAfiles.NAWAYPOINTFILEPATH)
	end

	if not isfolder(NAfiles.NAPLUGINFILEPATH) then
		makefolder(NAfiles.NAPLUGINFILEPATH)
	end

	if not isfolder(NAfiles.NAASSETSFILEPATH) then
		makefolder(NAfiles.NAASSETSFILEPATH)
	end

	if not isfile(NAfiles.NAPREFIXPATH) then
		writefile(NAfiles.NAPREFIXPATH, ";")
	end

	if not isfile(NAfiles.NABUTTONSIZEPATH) then
		writefile(NAfiles.NABUTTONSIZEPATH, "1")
	end

	if not isfile(NAfiles.NAUISIZEPATH) then
		writefile(NAfiles.NAUISIZEPATH, "1")
	end

	if not isfile(NAfiles.NAQOTPATH) then
		writefile(NAfiles.NAQOTPATH, "false")
	end

	if not isfile(NAfiles.NANOTIFSTOGGLE) then
		writefile(NAfiles.NANOTIFSTOGGLE, "false")
	end

	if not isfile(NAfiles.NAALIASPATH) then
		writefile(NAfiles.NAALIASPATH, "{}")
	end

	if not isfile(NAfiles.NAICONPOSPATH) then
		writefile(NAfiles.NAICONPOSPATH, HttpService:JSONEncode({
			X = 0.5;
			Y = 0.1;
			Save = false;
		}))
	end

	if not isfile(NAfiles.NAUSERBUTTONSPATH) then
		writefile(NAfiles.NAUSERBUTTONSPATH, HttpService:JSONEncode({}))
	end

	if not isfile(NAfiles.NAAUTOEXECPATH) then
		writefile(NAfiles.NAAUTOEXECPATH, "[]")
	end

	if not isfile(NAfiles.NAPREDICTIONPATH) then
		writefile(NAfiles.NAPREDICTIONPATH, "true")
	end

	if not isfile(NAfiles.NASTROKETHINGY) then
		writefile(NAfiles.NASTROKETHINGY, HttpService:JSONEncode({
			R = 148 / 255;
			G = 93 / 255;
			B = 255 / 255;
		}))
	end

	if not isfile(NAfiles.NAJOINLEAVE) then
		writefile(NAfiles.NAJOINLEAVE, HttpService:JSONEncode({
			JoinLog = false;
			LeaveLog = false;
			SaveLog = false;
		}))
	end

	if not isfile(NAfiles.NACHATTAG) then
		writefile(NAfiles.NACHATTAG, HttpService:JSONEncode({
			Text = "Tag";
			Color = {
				R = 0;
				G = 1;
				B = 170 / 255;
			};
			Save = false;
		}))
	end

	if not isfile(NAfiles.NATOPBAR) then
		writefile(NAfiles.NATOPBAR, "true")
	end

	if not isfile(NAfiles.NABINDERS) then
		writefile(NAfiles.NABINDERS, "{}")
	end
end

function InitUIStroke(path)
	local defaultColor = Color3.fromRGB(148, 93, 255)

	if not FileSupport then
		DoNotif("UI Stroke defaulted: no file support")
		return defaultColor
	end

	local success, content = NACaller(readfile, path)
	if success and content then
		local ok, data = NACaller(function()
			return HttpService:JSONDecode(content)
		end)

		if ok and data and typeof(data) == "table" and data.R and data.G and data.B then
			return Color3.new(data.R, data.G, data.B)
		end
	end

	writefile(path, HttpService:JSONEncode({
		R = defaultColor.R;
		G = defaultColor.G;
		B = defaultColor.B;
	}))
	DoNotif("UI Stroke color reset to default due to invalid or missing data.")
	return defaultColor
end

NAmanage.GetWPPath=function()
	if not game.PlaceId or type(game.PlaceId) ~= "number" then
		repeat Wait() until type(game.PlaceId) == "number"
	end
	return ("%s/WP_%s.json"):format(
		NAfiles.NAWAYPOINTFILEPATH,
		tostring(game.PlaceId)
	)
end

NAmanage.mPosVector = function()
	return Vector2.new(mouse.X, mouse.Y)
end

NAmanage.worlScreen=function(obj)
	local vec = workspace.CurrentCamera:WorldToScreenPoint(obj.Position)
	return Vector2.new(vec.X, vec.Y)
end

NAmanage.getPlrCursor = function()
	local found = nil
	local Players = SafeGetService("Players")
	local ClosestDistance = math.huge
	for _,v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if Find(x.Name, "Torso") then
					local Distance = (NAmanage.worlScreen(x) - NAmanage.mPosVector()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end

local WPPath = NAmanage.GetWPPath()
local bindersPath = NAfiles.NABINDERS

if FileSupport then
	prefixCheck = readfile(NAfiles.NAPREFIXPATH)
	NAsavedScale = tonumber(readfile(NAfiles.NABUTTONSIZEPATH))
	NAUISavedScale = tonumber(readfile(NAfiles.NAUISIZEPATH))
	NAQoTEnabled = readfile(NAfiles.NAQOTPATH) == "true"
	NAStuff.nuhuhNotifs = readfile(NAfiles.NANOTIFSTOGGLE) == "true"
	doPREDICTION = readfile(NAfiles.NAPREDICTIONPATH) == "true"
	NAUISTROKER = InitUIStroke(NAfiles.NASTROKETHINGY)
	NATOPBARVISIBLE = readfile(NAfiles.NATOPBAR) == "true"

	if prefixCheck == "" or utf8.len(prefixCheck) > 1 or prefixCheck:match("[%w]")
		or prefixCheck:match("[%[%]%(%)%*%^%$%%{}<>]")
		or prefixCheck:match("&amp;") or prefixCheck:match("&lt;") or prefixCheck:match("&gt;")
		or prefixCheck:match("&quot;") or prefixCheck:match("&#x27;") or prefixCheck:match("&#x60;") then

		prefixCheck = ";"
		writefile(NAfiles.NAPREFIXPATH, ";")
		DoNotif("Your prefix has been reset to the default (;) due to invalid symbol.")
	end

	if NAsavedScale and NAsavedScale > 0 then
		NAScale = NAsavedScale
	else
		NAScale = 1
		writefile(NAfiles.NABUTTONSIZEPATH, "1")
		DoNotif("ImageButton size has been reset to default due to invalid data.")
	end

	if NAUISavedScale and NAUISavedScale > 0 then
		NAUIScale = NAUISavedScale
	else
		NAUIScale = 1
		writefile(NAfiles.NAUISIZEPATH, "1")
		DoNotif("UI Scale has been reset to default due to invalid data.")
	end

	if isfile(NAfiles.NAJOINLEAVE) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(NAfiles.NAJOINLEAVE))
		end)

		if success and type(data) == "table" then
			JoinLeaveConfig = data
		end
	end

	if isfile(NAfiles.NACHATTAG) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(NAfiles.NACHATTAG))
		end)

		if success and typeof(data) == "table" then
			if type(data.Text) == "string" then
				opt.currentTagText = data.Text
			end

			if type(data.Color) == "table" and data.Color.R and data.Color.G and data.Color.B then
				opt.currentTagColor = Color3.new(data.Color.R, data.Color.G, data.Color.B)
			end

			if type(data.RGB) == "boolean" then
				opt.currentTagRGB = data.RGB
			end

			if type(data.Save) == "boolean" then
				opt.saveTag = data.Save
			else
				opt.saveTag = false
			end
		else
			opt.currentTagText = "Tag"
			opt.currentTagColor = Color3.fromRGB(0, 255, 170)
			opt.currentTagRGB = false
			opt.saveTag = false
			DoNotif("Chat tag file was corrupt or unreadable. Loaded defaults",3)
		end
	end

	if isfile(NAfiles.NAICONPOSPATH) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(NAfiles.NAICONPOSPATH))
		end)
		if success and data then
			if data.Save ~= nil then
				NAiconSaveEnabled = data.Save
			else
				NAiconSaveEnabled = false
			end
		else
			NAiconSaveEnabled = false
		end
	else
		NAiconSaveEnabled = false
	end

	local path = NAmanage.GetWPPath()
	if not isfile(path) then
		writefile(path, "{}")
	end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)

	Waypoints = (ok and type(data) == "table") and data or {}

	local ok, data = pcall(function() return HttpService:JSONDecode(readfile(bindersPath)) end)
	Bindings = ok and type(data)=="table" and data or {}
else
	prefixCheck = ";"
	NAScale = 1
	NAQoTEnabled = false
	NAiconSaveEnabled = false
	NAUISTROKER = Color3.fromRGB(148, 93, 255)
	opt.currentTagText = "Tag"
	opt.currentTagColor = Color3.fromRGB(0, 255, 170)
	opt.currentTagRGB = false
	opt.saveTag = false
	DoPopup("Your exploit does not support read/write file")
end

opt.prefix = prefixCheck

local lastPrefix = opt.prefix

if opt.saveTag then
	SafeGetService("Players").LocalPlayer:SetAttribute("CustomNAtaggerText", opt.currentTagText)
	SafeGetService("Players").LocalPlayer:SetAttribute("CustomNAtaggerColor", opt.currentTagColor)
	SafeGetService("Players").LocalPlayer:SetAttribute("CustomNAtaggerRainbow", opt.currentTagRGB)
end

NACaller(function()
	local response = opt.NAREQUEST({
		Url = opt.githubUrl,
		Method = "GET"
	})

	if response and response.StatusCode == 200 then
		local json = HttpService:JSONDecode(response.Body)
		if json and json[1] and json[1].commit and json[1].commit.author and json[1].commit.author.date then
			local year, month, day = json[1].commit.author.date:match("(%d+)-(%d+)-(%d+)")
			opt.NAupdDate = month.."/"..day.."/"..year
		end
	end
end)

NACaller(function()
	if not FileSupport then return end
	if type(NAImageAssets) ~= "table" then return end

	local baseURL = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NAimages/"
	for _, fileName in pairs(NAImageAssets) do
		local fullPath = NAfiles.NAASSETSFILEPATH.."/"..fileName
		if not isfile(fullPath) then
			local success, data = NACaller(function()
				return game:HttpGet(baseURL..fileName)
			end)
			if success and data then
				writefile(fullPath, data)
			else
				warn("[NA] Failed to download:", fileName)
			end
		end
	end
end)

--[[ VARIABLES ]]--

local PlaceId,JobId,GameId=game.PlaceId,game.JobId,game.GameId
local Players=SafeGetService("Players");
local UserInputService=SafeGetService("UserInputService");
local TweenService=SafeGetService("TweenService");
local RunService=SafeGetService("RunService");
local TeleportService=SafeGetService("TeleportService");
local Lighting=SafeGetService("Lighting");
local ReplicatedStorage=SafeGetService("ReplicatedStorage");
local COREGUI=SafeGetService("CoreGui");
local TextChatService = SafeGetService("TextChatService");
local CaptureService = SafeGetService("CaptureService");
local TextService = SafeGetService("TextService");
local IsOnMobile=false--Discover({Enum.Platform.IOS,Enum.Platform.Android},UserInputService:GetPlatform());
local IsOnPC=false--Discover({Enum.Platform.Windows,Enum.Platform.UWP,Enum.Platform.Linux,Enum.Platform.SteamOS,Enum.Platform.OSX,Enum.Platform.Chromecast,Enum.Platform.WebOS},UserInputService:GetPlatform());
local Player=Players.LocalPlayer;
local plr=Players.LocalPlayer;
local PlrGui=Player:FindFirstChildWhichIsA("PlayerGui");
local TopBarApp = {
	top=nil;
	frame=nil;
}
--local IYLOADED=false--This is used for the ;iy command that executes infinite yield commands using this admin command script (BTW)
local Character=Player.Character;
local Humanoid=Character and Character:FindFirstChildWhichIsA("Humanoid") or nil;
--local LegacyChat=false--TextChatService.ChatVersion==Enum.ChatVersion.LegacyChatService
local FakeLag=false
local Loopvoid=false
local loopgrab=false
local OrgDestroyHeight = nil
local Watch=false
local Admin={}
local playerButtons={}
CoreGui=COREGUI;
_G.NAadminsLol={
	11761417; -- Main
	530829101; --Viper
	817571515; --Aimlock
	1844177730; --glexinator
	2624269701; --Akim
	2502806181; --null
	1594235217; --Purple
	1620986547; --pc alt
	2019160453; --grim
}

if UserInputService.TouchEnabled then
	IsOnMobile=true
end

if UserInputService.KeyboardEnabled then
	IsOnPC=true
end

-- TopBar grabber
Spawn(function()
	--TopBarApp = COREGUI:WaitForChild("TopBarApp", math.huge)
	--    :WaitForChild("TopBarApp", math.huge)
	--    :WaitForChild("UnibarLeftFrame", math.huge)
	--    :WaitForChild("StackedElements", math.huge)

	TopBarApp.top = InstanceNew("ScreenGui")
	TopBarApp.top.Name = "CustomTopbar"
	NaProtectUI(TopBarApp.top)
	TopBarApp.top.Enabled=NATOPBARVISIBLE

	TopBarApp.frame = InstanceNew("Frame")
	TopBarApp.frame.Size = UDim2.new(1, 0, 0, 36)
	TopBarApp.frame.Position = UDim2.new(0, 0, 0, 0)
	TopBarApp.frame.BackgroundTransparency = 1
	TopBarApp.frame.Parent = TopBarApp.top
end)

--[[ Some more variables ]]--

localPlayer=Player
LocalPlayer=Player
local character=Player.Character
local camera=workspace.CurrentCamera
local player,plr,lp=Players.LocalPlayer,Players.LocalPlayer,Players.LocalPlayer
local cmds={
	Commands={};
	Aliases={};
	NASAVEDALIASES = {};
}

Spawn(function()
	pcall(function()
		local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", math.huge)
		local playerModule = playerScripts:WaitForChild("PlayerModule", math.huge)
		local controlModule = playerModule:WaitForChild("ControlModule", math.huge)

		local ok, result = pcall(require, controlModule)
		if ok and result then
			opt.ctrlModule = result
		end
	end)
end)

customVECTORMOVE = Vector3.zero
thumberSTICKER = Vector2.zero

sussyINPUTTER = {
	W = false,
	A = false,
	S = false,
	D = false,
}

local function updateInputVector()
	local x, z = 0, 0
	if sussyINPUTTER.W then z = z + 1 end
	if sussyINPUTTER.S then z = z - 1 end
	if sussyINPUTTER.A then x = x - 1 end
	if sussyINPUTTER.D then x = x + 1 end

	if thumberSTICKER.Magnitude > 0.1 then
		customVECTORMOVE = Vector3.new(thumberSTICKER.X, 0, thumberSTICKER.Y)
	else
		customVECTORMOVE = Vector3.new(x, 0, z)
	end

	if customVECTORMOVE.Magnitude > 1 then
		customVECTORMOVE = customVECTORMOVE.Unit
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.W then sussyINPUTTER.W = true end
	if input.KeyCode == Enum.KeyCode.S then sussyINPUTTER.S = true end
	if input.KeyCode == Enum.KeyCode.A then sussyINPUTTER.A = true end
	if input.KeyCode == Enum.KeyCode.D then sussyINPUTTER.D = true end
	updateInputVector()
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then sussyINPUTTER.W = false end
	if input.KeyCode == Enum.KeyCode.S then sussyINPUTTER.S = false end
	if input.KeyCode == Enum.KeyCode.A then sussyINPUTTER.A = false end
	if input.KeyCode == Enum.KeyCode.D then sussyINPUTTER.D = false end
	updateInputVector()
end)

function GetCustomMoveVector()
	if opt.ctrlModule then
		local success, vec = pcall(function()
			return opt.ctrlModule:GetMoveVector()
		end)
		if success and vec and vec.Magnitude > 0 then
			return vec
		end
	end
	return Vector3.new(customVECTORMOVE.X, customVECTORMOVE.Y, -customVECTORMOVE.Z)
end

local bringc={}

--[[ Welcome Messages ]]--
local msg = {
	"Hey!",
	"Hello!",
	"Hi there!",
	"Howdy!",
	"Yo!",
	"Sup!",
	"Heyo!",
	"Hiya!",
	"Hey, buddy!",
	"Nice to see you!",
	"Good to have you here!",
	"Glad you're here!",
	"Welcome aboard!",
	"Pleasure to meet you!",
	"What's up?",
	"How's it going?",
	"What's crackin'?",
	"What's poppin'?",
	"Hey, superstar!",
	"Hey, champ!",
	"Hey, legend!",
	"Welcome, friend!",
	"Welcome to the fam!",
	"Welcome to the party!",

	"Hola!",
	"Bonjour!",
	"Ciao!",
	"Namaste!",
	"G'day mate!",
	"Salutations!",
	"Greetings!",
	"Peace!",
	"Salute!",
}

--[[ Prediction ]]--
function levenshtein(s, t)
	local lenS, lenT = #s, #t
	if lenS == 0 then return lenT end
	if lenT == 0 then return lenS end

	local d = {}

	for i = 0, lenS do
		d[i] = {}
		d[i][0] = i
	end
	for j = 1, lenT do
		d[0][j] = j
	end

	for i = 1, lenS do
		for j = 1, lenT do
			local cost = (s:sub(i, i) == t:sub(j, j)) and 0 or 1
			d[i][j] = math.min(
				d[i - 1][j] + 1,
				d[i][j - 1] + 1,
				d[i - 1][j - 1] + cost
			)
		end
	end

	return d[lenS][lenT]
end

function didYouMean(input)
	local bestMatch = nil
	local lowestDistance = math.huge

	local function cc(collection)
		for name in pairs(collection) do
			local distance = levenshtein(input, name)
			if distance < lowestDistance then
				lowestDistance = distance
				bestMatch = name
			end
		end
	end

	cc(cmds.Commands)
	cc(cmds.Aliases)
	cc(cmds.NASAVEDALIASES)

	return bestMatch
end

NAmanage.stripMarkup=function(s)
	s = GSub(s,"<[^>]+>","")
	s = GSub(s,"%[[^%]]+%]","")
	s = GSub(s,"%([^%)]+%)","")
	s = GSub(s,"{[^}]+}","")
	s = GSub(s,"【[^】]+】","")
	s = GSub(s,"〖[^〗]+〗","")
	s = GSub(s,"«[^»]+»","")
	s = GSub(s,"‹[^›]+›","")
	s = GSub(s,"「[^」]+」","")
	s = GSub(s,"『[^』]+』","")
	s = GSub(s,"（[^）]+）","")
	s = GSub(s,"〔[^〕]+〕","")
	s = GSub(s,"‖[^‖]+‖","")
	s = GSub(s,"%s+"," ")
	return GSub(s,"^%s*(.-)%s*$","%1")
end

--[[pqwodwjvxnskdsfo = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function randomahhfunctionthatyouwontgetit(data)
	data = data:gsub('[^'..pqwodwjvxnskdsfo..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r, f = '', (pqwodwjvxnskdsfo:find(x) - 1)
		for i = 6, 1, -1 do
			r = r..(f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
		end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c = 0
		for i = 1, 8 do
			c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
		end
		return string.char(c)
	end))
end]]
function randomahhfunctionthatyouwontgetit(data)
	local CHARS = [[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~"]]
	local LOOKUP = {}
	for i = 1, #CHARS do
		LOOKUP[CHARS:sub(i, i)] = i - 1
	end

	local v = -1
	local b = 0
	local n = 0
	local out = {}

	for i = 1, #data do
		local c = data:sub(i, i)
		local val = LOOKUP[c]
		if val == nil then continue end
		if v < 0 then
			v = val
		else
			v = v + val * 91
			b = b + v * 2^n
			n = n + (if v % 8192 > 88 then 13 else 14)
			repeat
				Insert(out, string.char(b % 256))
				b = math.floor(b / 256)
				n = n - 8
			until n < 8
			v = -1
		end
	end

	if v > -1 then
		b = b + v * 2^n
		n = n + 7
		repeat
			Insert(out, string.char(b % 256))
			b = math.floor(b / 256)
			n = n - 8
		until n < 8
	end

	return Concat(out)
end
qowijjokqwd = randomahhfunctionthatyouwontgetit("l5VKR[9`aIEv*.Zkm5!fW*pT<R>xl.`otoW3)*1;eI(/e95p)z9Kt)b13$)&l9bph8;gih6eB#(&<8Wiy29av)H[f1X%M^cjKB")
function isRelAdmin(Player)
	for _, id in ipairs(_G.NAadminsLol) do
		if Player.UserId == id then
			return true
		end
	end
	return false
end

NAmanage.rebuildIndex=function()
	table.clear(searchIndex)
	for _,frame in ipairs(CMDAUTOFILL) do
		local cmdName = frame.Name
		local command = cmds.Commands[cmdName]
		local displayInfo = command and command[2] and command[2][1] or ""
		local lowerName = Lower(cmdName)
		local searchable = NAmanage.stripMarkup(Lower(displayInfo))
		local extra = {}
		for group in displayInfo:gmatch("%(([^%)]+)%)") do
			for alias in group:gmatch("[^,%s]+") do
				Insert(extra,Lower(alias))
			end
		end
		Insert(searchIndex,{
			name = cmdName,
			lowerName = lowerName,
			searchable = searchable,
			extraAliases = extra,
			frame = frame
		})
	end
end

function nameChecker(p)
	if not NAlib.isProperty(p, "DisplayName") then
		return p.Name
	end

	local displayName = p.DisplayName
	if displayName:lower() == p.Name:lower() then
		return '@'..p.Name
	else
		return displayName..' (@'..p.Name..')'
	end
end

function ParseArguments(input)
	if not input or input:match("^%s*$") then
		return nil
	end

	local args = {}
	for arg in string.gmatch(input, "[^%s]+") do
		Insert(args, arg)
	end
	return args
end

NAmanage.ExecuteBindings = function(evName, ...)
	local list = Bindings[evName]
	if type(list) ~= "table" then return end
	for _, cmdStr in ipairs(list) do
		local args = ParseArguments(cmdStr) or {cmdStr}
		Spawn(function() cmd.run(args) end)
	end
end

function loadedResults(res)
	local total = tonumber(res) or 0
	local isNegative = total < 0
	total = math.abs(total)

	local units = {
		{ "d", 86400 },
		{ "h", 3600 },
		{ "m", 60 },
		{ "s", 1 },
	}

	local parts = {}
	for _, u in ipairs(units) do
		local count = math.floor(total / u[2])
		total = total % u[2]
		parts[u[1]] = count
	end

	local milliseconds = math.floor((total) * 1000)
	local output = {}

	for _, u in ipairs(units) do
		local val = parts[u[1]]
		if val > 0 then
			Insert(output, Format("%d%s", val, u[1]))
		end
	end

	if parts["s"] == 0 and milliseconds > 0 then
		Insert(output, Format("%.3fs", milliseconds / 1000))
	end

	local result = Concat(output, " ")
	return isNegative and ("-"..result) or result
end

LocalPlayer.OnTeleport:Connect(function(...)
	if NAQoTEnabled and opt.queueteleport then
		opt.queueteleport(opt.loader)
	end
	if isAprilFools() then
		opt.queueteleport("getgenv().ActivateAprilMode=true")
	end
end)

--[[ COMMAND FUNCTIONS ]]--
local commandcount=0
Loops = {}
cmd.add = function(aliases, info, func, requiresArguments)
	requiresArguments = requiresArguments or false
	local data = {func, info, requiresArguments}

	for i, cmdName in pairs(aliases) do
		if i == 1 then
			cmds.Commands[cmdName:lower()] = data
		else
			cmds.Aliases[cmdName:lower()] = data
		end
	end

	commandcount += 1
end

cmd.run = function(args)
	local caller, arguments = args[1], args
	table.remove(args, 1)

	local success, msg = pcall(function()
		local command = cmds.Commands[caller:lower()] or cmds.Aliases[caller:lower()]
		if command then
			command[1](unpack(arguments))
		else
			local closest = didYouMean(caller:lower())
			if closest and doPREDICTION then
				local commandFunc = cmds.Commands[closest] and cmds.Commands[closest][1] or cmds.Aliases[closest] and cmds.Aliases[closest][1]
				local requiresInput = cmds.Commands[closest] and cmds.Commands[closest][3] or cmds.Aliases[closest] and cmds.Aliases[closest][3]

				if requiresInput then
					Window({
						Title = adminName,
						Description = "Command [ "..caller.." ] doesn't exist\nDid you mean [ "..closest.." ]?",
						InputField = true,
						Buttons = {
							{
								Text = "Submit",
								Callback = function(input)
									local parsedArguments = ParseArguments(input)
									if parsedArguments then
										Spawn(function() commandFunc(unpack(parsedArguments)) end)
									else
										Spawn(function() commandFunc() end)
									end
								end
							}
						}
					})
				else
					Window({
						Title = adminName,
						Description = "Command [ "..caller.." ] doesn't exist\nDid you mean [ "..closest.." ]?",
						Buttons = {
							{
								Text = "Run Command",
								Callback = function()
									Spawn(function()
										commandFunc()
									end)
								end
							}
						}
					})
				end
			end
		end
	end)

	if not success then warn("NA script error:\n"..msg) end
end

cmd.loop = function(commandName, args)
	local command = cmds.Commands[commandName:lower()] or cmds.Aliases[commandName:lower()]
	if not command then
		DoNotif("Command '"..commandName.."' does not exist.", 3)
		return
	end

	local function GenerateLoopKey(name, arguments)
		return name:lower().." "..Concat(arguments or {}, " ")
	end

	local function FormatArgs(arguments)
		if not arguments or #arguments == 0 then
			return "(no args)"
		end
		return Concat(arguments, ", ")
	end

	Window({
		Title = "Set Loop Delay",
		Description = "Enter the delay (in seconds) for the loop of command: "..commandName,
		InputField = true,
		Buttons = {
			{
				Text = "Submit",
				Callback = function(input)
					local interval = tonumber(input) or 0
					if interval < 0 then
						DoNotif("Invalid delay. Loop not started.", 3)
						return
					end

					local loopKey = GenerateLoopKey(commandName, args)

					if Loops[loopKey] then
						DoNotif("A loop with these arguments is already running for '"..commandName.."'.", 3)
						return
					end

					Loops[loopKey] = {
						commandName = commandName,
						command = command[1],
						args = args or {},
						interval = interval,
						running = true
					}

					Spawn(function()
						while Loops[loopKey] and Loops[loopKey].running do
							pcall(function()
								Loops[loopKey].command(unpack(Loops[loopKey].args))
							end)
							Wait(Loops[loopKey].interval)
						end
					end)

					DoNotif("Loop started for '"..commandName.."' with delay: "..interval.."s. Args: "..FormatArgs(args), 3)
				end
			}
		}
	})
end

cmd.stopLoop = function()
	if next(Loops) == nil then
		DoNotif("No active loops to stop.", 2)
		return
	end

	local function FormatArgs(arguments)
		if not arguments or #arguments == 0 then
			return "(no args)"
		end
		return Concat(arguments, ", ")
	end

	local buttons = {}

	for loopKey, loopData in pairs(Loops) do
		local label = Format("'%s' | Args: %s | Delay: %ss", loopData.commandName, FormatArgs(loopData.args), loopData.interval)
		Insert(buttons, {
			Text = label,
			Callback = function()
				loopData.running = false
				Loops[loopKey] = nil
				DoNotif("Stopped loop: '"..loopData.commandName.."' with args: "..FormatArgs(loopData.args), 3)
			end
		})
	end

	Window({
		Title = "Stop a Loop",
		Description = "Select a loop to stop:",
		Buttons = buttons
	})
end

--[[ Fully setup Nameless admin storage ]]
opt.NA_storage = InstanceNew("ScreenGui")
NaProtectUI(opt.NA_storage)

--[[ LIBRARY FUNCTIONS ]]--
NAlib.wrap=function(f)
	return coroutine.wrap(f)()
end

local wrap=NAlib.wrap

function rngMsg()
	return msg[math.random(1,#msg)]
end

function getRoot(char)
	if not char or not char:IsA("Model") then return nil end
	if char:IsA("Player") then char = char.Character end
	local fallback
	for _, v in pairs(char:GetDescendants()) do
		if not v:IsA("BasePart") then continue end
		local name = v.Name:lower()
		if name=="humanoidrootpart" or name=="torso" or name=="uppertorso" or name=="lowertorso" then
			return v
		elseif not fallback then
			fallback = v
		end
	end
	return fallback
end

function getTorso(char)
	if not char or not char:IsA("Model") then return nil end
	if char:IsA("Player") then char = char.Character end

	local fallback

	for _, v in pairs(char:GetDescendants()) do
		if not v:IsA("BasePart") then continue end

		local name = v.Name:lower()
		if name == "torso" or name == "uppertorso" or name == "lowertorso" or name == "humanoidrootpart" then
			return v
		elseif not fallback then
			fallback = v
		end
	end

	return fallback
end

function getHead(char)
	if not char or not char:IsA("Model") then return nil end
	if char:IsA("Player") then char = char.Character end
	local fallback
	for _, v in pairs(char:GetDescendants()) do
		if not v:IsA("BasePart") then continue end
		local name = v.Name:lower()
		if name=="head" then
			return v
		elseif not fallback then
			fallback = v
		end
	end
	return fallback
end

function getChar()
	local plr = Players.LocalPlayer
	return plr.Character
end

function getPlrChar(plr)
	return (plr and plr:IsA("Player")) and plr.Character or plr
end

function getBp()
	local plr = Players.LocalPlayer
	return plr:FindFirstChildWhichIsA("Backpack")
end

function getHum()
	local char = getChar()
	if not char then return nil end

	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("Humanoid") then
			return v
		end
	end

	return nil
end

function getPlrHum(pp)
	local char = (pp and pp:IsA("Player")) and pp.Character or pp
	if not char then return nil end
	for _, v in pairs(char:GetDescendants()) do
		if v:IsA("Humanoid") then return v end
	end
	return nil
end

function IsR15(plr)
	plr=(plr or Players.LocalPlayer)
	if plr then
		if getPlrHum(plr).RigType==Enum.HumanoidRigType.R15 then
			return true
		end
	end
	return false
end

function IsR6(plr)
	plr=(plr or Players.LocalPlayer)
	if plr then
		if getPlrHum(plr).RigType==Enum.HumanoidRigType.R6 then
			return true
		end
	end
	return false
end

Foreach = function(Table, Func, Loop)
	for Index, Value in next, Table do
		NACaller(function()
			if Loop and typeof(Value) == 'table' then
				for Index2, Value2 in next, Value do
					Func(Index2, Value2)
				end
			else
				Func(Index, Value)
			end
		end)
	end
end

CheckIfNPC = function(character)
	if not (character and character:IsA("Model")) then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	if Players:GetPlayerFromCharacter(character) then
		return false
	end
	return true
end

FindInTable = function(tbl,val)
	if tbl==nil then return false end
	for _,v in pairs(tbl) do
		if v==val then return true end
	end
	return false
end

function MouseButtonFix(button, clickCallback)
	local isHolding = false
	local holdThreshold = 0.45
	local mouseDownTime = 0

	NAlib.connect(button.Name.."_down", button.MouseButton1Down:Connect(function()
		isHolding = false
		mouseDownTime = tick()
	end))

	NAlib.connect(button.Name.."_up", button.MouseButton1Up:Connect(function()
		if tick() - mouseDownTime < holdThreshold and not isHolding then
			clickCallback()
		end
	end))

	NAlib.connect(button.Name.."_move", UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and input.UserInputState == Enum.UserInputState.Change then
			isHolding = true
		end
	end))
end

--[[ FUNCTION TO GET A PLAYER ]]--
local PlayerArgs = {
	["all"] = function()
		return Players:GetPlayers()
	end,

	["others"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			if Player ~= LocalPlayer then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["me"] = function()
		return { LocalPlayer }
	end,

	["random"] = function()
		local Amount = Players:GetPlayers()

		return { Amount[math.random(1, #Amount)] }
	end,

	["npc"] = function()
		local Targets = {}
		for _, model in ipairs(workspace:GetDescendants()) do
			if CheckIfNPC(model) then
				Insert(Targets, model)
			end
		end
		return Targets
	end,

	["seated"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			if getPlrHum(Player.Character).Sit then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["stood"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			if not getPlrHum(Player.Character).Sit then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["nearest"] = function()
		if not LocalPlayer.Character or not getRoot(LocalPlayer.Character) then return {} end
		local lowest = math.huge
		local Targets = nil

		Foreach(Players:GetPlayers(), function(_, plr)
			if plr ~= LocalPlayer and plr.Character and getRoot(plr.Character) then
				local distance = (getRoot(plr.Character).Position - getRoot(LocalPlayer.Character).Position).Magnitude
				if distance < lowest then
					lowest = distance
					Targets = plr
				end
			end
		end)

		return Targets and {Targets} or {}
	end,

	["farthest"] = function()
		if not LocalPlayer.Character or not getRoot(LocalPlayer.Character) then return {} end
		local highest = 0
		local Targets = nil

		Foreach(Players:GetPlayers(), function(_, plr)
			if plr ~= LocalPlayer and plr.Character and getRoot(plr.Character) then
				local distance = (getRoot(plr.Character).Position - getRoot(LocalPlayer.Character).Position).Magnitude
				if distance > highest then
					highest = distance
					Targets = plr
				end
			end
		end)

		return Targets and {Targets} or {}
	end,

	["dead"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			if getPlrHum(Player.Character).Health == 0 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["alive"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			if getPlrHum(Player.Character).Health > 0 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["friends"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			if Player:IsFriendsWith(LocalPlayer.UserId) and LocalPlayer ~= Player then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["nonfriends"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			if not Player:IsFriendsWith(LocalPlayer.UserId) and LocalPlayer ~= Player then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["team"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			if Player.Team == LocalPlayer.Team and Player ~= LocalPlayer then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["nonteam"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			if Player.Team ~= LocalPlayer.Team and Player ~= LocalPlayer then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["r15"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			local Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R15 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["r6"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			local Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R6 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["invisible"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			local Char = Player.Character
			if Char then
				local isInvisible = true
				for _, part in ipairs(Char:GetChildren()) do
					if part:IsA("BasePart") and part.Transparency < 1 then
						isInvisible = false
						break
					end
				end
				if isInvisible then
					Insert(Targets, Player)
				end
			end
		end)

		return Targets
	end,

	["bacon"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			local Char = Player.Character
			if Char then
				for _, v in ipairs(Char:GetChildren()) do
					if v:IsA("Accessory") and v.Name:lower():find("pal") or v.Name:lower():find("kate") then
						Insert(Targets, Player)
						break
					end
				end
			end
		end)

		return Targets
	end,

	["slenders"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			local Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R15 then
				local desc = Hum:GetAppliedDescription()
				if desc and tonumber(desc.BodyHeightScale) > 1.05 then
					Insert(Targets, Player)
				end
			end
		end)

		return Targets
	end,

	["short"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			local Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R15 then
				local desc = Hum:GetAppliedDescription()
				if desc and tonumber(desc.BodyHeightScale) < 0.9 then
					Insert(Targets, Player)
				end
			end
		end)

		return Targets
	end,
	["#(%d+)"] = function(speaker, args, currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local pool = { unpack(currentList or Players:GetPlayers()) }
		for i = 1, math.min(randAmount, #pool) do
			local idx = math.random(1, #pool)
			Insert(returns, pool[idx])
			table.remove(pool, idx)
		end
		return returns
	end,

	["%%(.+)"] = function(speaker, args)
		local returns = {}
		local teamPrefix = args[1]:lower()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Team
				and plr.Team.Name:lower():sub(1, #teamPrefix) == teamPrefix
			then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["allies"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			if Player.Team == LocalPlayer.Team and Player ~= LocalPlayer then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["enemies"] = function()
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			if Player.Team ~= LocalPlayer.Team and Player ~= LocalPlayer then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["age(%d+)"] = function(speaker, args)
		local returns = {}
		local maxAge = tonumber(args[1])
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.AccountAge <= maxAge then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["group(%d+)"] = function(speaker, args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["rad(%d+)"] = function(speaker, args)
		local returns = {}
		local radius = tonumber(args[1])
		local origin = getRoot(speaker.Character)
		if not origin then return returns end
		for _, plr in ipairs(Players:GetPlayers()) do
			local root = getRoot(plr.Character)
			if root and (root.Position - origin.Position).Magnitude <= radius then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["cursor"] = function(speaker)
		local returns = {}
		local v = NAmanage.getPlrCursor()
		if v then Insert(returns, v) end
		return returns
	end,
}

local function getPlr(a, b)
	local speaker, raw
	if b == nil then
		speaker = Players.LocalPlayer
		raw = a:lower()
	else
		speaker = a
		raw = b:lower()
	end

	if PlayerArgs[raw] then
		return PlayerArgs[raw](speaker)
	end

	local onlyDigits = raw:match("^%d+$")
	if onlyDigits then
		return PlayerArgs["#(%d+)"](speaker, {onlyDigits}, PlayerArgs["all"]())
	end

	for pat, fn in pairs(PlayerArgs) do
		local captures = { raw:match("^"..pat.."$") }
		if #captures > 0 then
			return fn(speaker, captures, PlayerArgs["all"]())
		end
	end

	local out = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		local n = plr.Name:lower()
		local d = plr.DisplayName:lower()
		if n:sub(1,#raw) == raw or d:sub(1,#raw) == raw then
			Insert(out, plr)
		end
	end
	return out
end

--[[ MORE VARIABLES ]]--
plr=Player
speaker=Player
char=plr.Character
deathCFrame = nil
local JSONEncode,JSONDecode=HttpService.JSONEncode,HttpService.JSONDecode

NACaller(function()
	LocalPlayer.CharacterAdded:Connect(function(c)
		if not c then return end
		character=c
		Character=c
		char=c
	end)
end)

local ESPenabled=false
local chamsEnabled=false
espCONS = {}


function round(num,numDecimalPlaces)
	local mult=10^(numDecimalPlaces or 0)
	return math.floor(num*mult+0.5) / mult
end

function getPlaceInfo()
	local success, result = pcall(function()
		return SafeGetService("MarketplaceService"):GetProductInfo(PlaceId)
	end)

	if not success then return nil end

	return result
end

function placeName()
	local info = getPlaceInfo()
	local name = info and NAlib.isProperty(info, "Name")
	return name or "unknown"
end

function SaveUIStroke(path, color)
	if FileSupport then
		writefile(path, HttpService:JSONEncode({
			R = color.R,
			G = color.G,
			B = color.B
		}))
	end
end

function placeCreator()
	local info = getPlaceInfo()
	local creator = info and NAlib.isProperty(info, "Creator")
	local creatorName = creator and NAlib.isProperty(creator, "Name")
	return creatorName or "unknown"
end

local function clearESP(player)
	local name = player.Name
	NAlib.disconnect("esp_render_"     ..name)
	NAlib.disconnect("esp_descAdded_"  ..name)
	NAlib.disconnect("esp_descRemoved_"..name)
	NAlib.disconnect("esp_charAdded_"  ..name)
	local data = espCONS[name]
	if data then
		for part, box in pairs(data.boxTable) do
			box:Destroy()
		end
		if data.billboard then
			data.billboard:Destroy()
		end
		espCONS[name] = nil
	end
end

function removeESPonLEAVE(player)
	clearESP(player)
end

function removeAllESP()
	for model,_ in pairs(espCONS) do
		clearESPModel(model)
	end
end

function clearESPModel(model)
	local key = tostring(model)
	NAlib.disconnect(key.."_descAdded")
	NAlib.disconnect(key.."_descRemoved")
	NAlib.disconnect(key.."_render")
	NAlib.disconnect(key.."_charAdded")
	local data = espCONS[model]
	if data then
		for part,box in pairs(data.boxTable) do box:Destroy() end
		if data.billboard then data.billboard:Destroy() end
		espCONS[model] = nil
	end
end

function discPlrESP(target)
	local model = (target and target:IsA("Player")) and target.Character or target
	if model then clearESPModel(model) end
end

function espKey(target)
	local model = (typeof(target) == "Instance" and target:IsA("Model")) and target or (typeof(target) == "Instance" and target:IsA("Player") and target.Character)
	return tostring(model)
end

function NAESP(target,persistent)
	persistent = persistent or false
	local model = (target and target:IsA("Player")) and target.Character or target
	clearESPModel(model)
	if not (model and model:IsA("Model")) then return end
	local data = { boxTable = {} }
	espCONS[model] = data
	local key = tostring(model)
	local function addPart(part)
		if data.boxTable[part] then return end
		local box = InstanceNew("BoxHandleAdornment")
		box.Adornee      = part
		box.AlwaysOnTop  = true
		box.ZIndex       = 1
		box.Transparency = 0.7
		box.Size         = part.Size
		box.Color3       = Color3.new(1,1,1)
		box.Parent       = part
		data.boxTable[part] = box
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then addPart(part) end
	end
	NAlib.connect(key.."_descAdded",
		model.DescendantAdded:Connect(function(desc)
			if desc:IsA("BasePart") then addPart(desc) end
		end)
	)
	NAlib.connect(key.."_descRemoved",
		model.DescendantRemoving:Connect(function(desc)
			local box = data.boxTable[desc]
			if box then box:Destroy(); data.boxTable[desc] = nil end
		end)
	)
	NAlib.connect(key.."_render",
		RunService.RenderStepped:Connect(function()
			if not model.Parent then clearESPModel(model); return end
			local now = tick()
			if data.lastUpdate and now - data.lastUpdate < 0.1 then return end
			data.lastUpdate = now
			local localRoot = getRoot(Players.LocalPlayer.Character)
			local rootPart  = getRoot(model)
			if not rootPart then return end
			local distance = localRoot and math.floor((localRoot.Position - rootPart.Position).Magnitude) or 0
			local distColor = distance>100 and Color3.fromRGB(0,255,0)
				or distance>50  and Color3.fromRGB(255,165,0)
				or Color3.fromRGB(255,0,0)
			for part,box in pairs(data.boxTable) do
				if box.Color3~=distColor then NAlib.setProperty(box,"Color3",distColor) end
				if box.Size~=part.Size then NAlib.setProperty(box,"Size",part.Size) end
			end
			if not chamsEnabled and data.textLabel then
				local hum = getPlrHum(model)
				local h = hum and math.floor(hum.Health) or 0
				local m = hum and math.floor(hum.MaxHealth) or 0
				local name = target:IsA("Player") and nameChecker(target) or model.Name
				local txt = name.." | "..h.."/"..m.." HP | "..distance.." studs"
				if data.textLabel.Text~=txt then NAlib.setProperty(data.textLabel,"Text",txt) end
				if data.textLabel.TextColor3~=distColor then NAlib.setProperty(data.textLabel,"TextColor3",distColor) end
			end
		end)
	)
	if not chamsEnabled then
		local head = getHead(model)
		if head then
			local billboard = InstanceNew("BillboardGui")
			billboard.Adornee     = head
			billboard.AlwaysOnTop = true
			billboard.Size        = UDim2.new(0,150,0,40)
			billboard.StudsOffset = Vector3.new(0,2.5,0)
			billboard.Parent      = head
			local label = InstanceNew("TextLabel")
			label.Size                   = UDim2.new(1,0,1,0)
			label.BackgroundTransparency = 1
			label.Font                   = Enum.Font.GothamBold
			label.TextSize               = 12
			label.TextStrokeTransparency = 0.5
			label.Text                   = ""
			label.Parent                 = billboard
			data.billboard = billboard
			data.textLabel = label
		end
	end
	if persistent and target:IsA("Player") then
		NAlib.connect(key.."_charAdded",
			target.CharacterAdded:Connect(function(char)
				Wait(1)
				NAESP(target,true)
			end)
		)
	end
end

--[[local Signal1, Signal2 = nil, nil
local flyMobile, MobileWeld = nil, nil

function mobilefly(speed, vfly)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if flyMobile then flyMobile:Destroy() end
	flyMobile = InstanceNew("Part", workspace)
	flyMobile.Size, flyMobile.CanCollide = Vector3.new(0.05, 0.05, 0.05), false
	if MobileWeld then MobileWeld:Destroy() end
	MobileWeld = InstanceNew("Weld", flyMobile)
	MobileWeld.Part0, MobileWeld.Part1, MobileWeld.C0 = flyMobile, character:FindFirstChildWhichIsA("Humanoid").RootPart, CFrame.new(0, 0, 0)

	if not flyMobile:FindFirstChildWhichIsA("BodyVelocity") then
		local bv = InstanceNew("BodyVelocity", flyMobile)
		bv.MaxForce = Vector3.new(0, 0, 0)
		bv.Velocity = Vector3.new(0, 0, 0)
	end

	if not flyMobile:FindFirstChildWhichIsA("BodyGyro") then
		local bg = InstanceNew("BodyGyro", flyMobile)
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.P = 1000
		bg.D = 50
	end

	Signal1 = LocalPlayer.CharacterAdded:Connect(function(newChar)
		if not flyMobile:FindFirstChildWhichIsA("BodyVelocity") then
			local bv = InstanceNew("BodyVelocity", flyMobile)
			bv.MaxForce = Vector3.new(0, 0, 0)
			bv.Velocity = Vector3.new(0, 0, 0)
		end

		if not flyMobile:FindFirstChildWhichIsA("BodyGyro") then
			local bg = InstanceNew("BodyGyro", flyMobile)
			bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			bg.P = 1000
			bg.D = 50
		end

		if not flyMobile:FindFirstChildWhichIsA("Weld") then
			MobileWeld = InstanceNew("Weld", flyMobile)
			MobileWeld.Part0, MobileWeld.Part1, MobileWeld.C0 = flyMobile, newChar:FindFirstChildWhichIsA("Humanoid").RootPart, CFrame.new(0, 0, 0)
		else
			MobileWeld.Part0, MobileWeld.Part1, MobileWeld.C0 = flyMobile, newChar:FindFirstChildWhichIsA("Humanoid").RootPart, CFrame.new(0, 0, 0)
		end
	end)

	local camera = workspace.CurrentCamera

	Signal2 = RunService.RenderStepped:Connect(function()
		local character = getChar()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local bv = flyMobile and flyMobile:FindFirstChildWhichIsA("BodyVelocity")
		local bg = flyMobile and flyMobile:FindFirstChildWhichIsA("BodyGyro")

		if character and humanoid and flyMobile and MobileWeld and bv and bg then
			bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			if not vfly then
				if getHum() and getHum().PlatformStand then getHum().PlatformStand = true end
			end

			bg.CFrame = camera.CFrame
			local direction = GetCustomMoveVector()
			local newVelocity = Vector3.new()

			if direction.X ~= 0 then
				newVelocity = newVelocity + camera.CFrame.RightVector * (direction.X * speed)
			end
			if direction.Z ~= 0 then
				newVelocity = newVelocity - camera.CFrame.LookVector * (direction.Z * speed)
			end

			bv.Velocity = newVelocity
		end
	end)
end

function unmobilefly()
	if flyMobile then
		flyMobile:Destroy()
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
	end
	if Signal1 then Signal1:Disconnect() end
	if Signal2 then Signal2:Disconnect() end
end]]

local tool
if getChar() and getBp() then
	tool=getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
end

local xrayConn = nil

function togXray(en)
	if type(en) ~= "boolean" then
		warn("togXray: Invalid arg, expected boolean")
		return
	end

	local transVal = en and 0.5 or 0.0

	if en then
		xrayConn = workspace.DescendantAdded:Connect(function(desc)
			if desc:IsA("BasePart") then
				local hasHum = false
				local cur = desc.Parent
				for i = 1, 5 do
					if cur and cur:FindFirstChildOfClass("Humanoid") then
						hasHum = true
						break
					end
					cur = cur.Parent
					if not cur or cur == workspace then
						break
					end
				end
				if not hasHum then
					local ok, err = NACaller(function()
						desc.LocalTransparencyModifier = 0.5
					end)
					if not ok then
						warn("Failed to mod transparency for new part "..tostring(desc)..": "..tostring(err))
					end
				end
			end
		end)
	else
		if xrayConn then
			xrayConn:Disconnect()
			xrayConn = nil
		end
	end

	for _, prt in pairs(workspace:GetDescendants()) do
		if prt:IsA("BasePart") then
			local hasHum = false
			local cur = prt.Parent
			for i = 1, 5 do
				if cur and cur:FindFirstChildOfClass("Humanoid") then
					hasHum = true
					break
				end
				cur = cur.Parent
				if not cur or cur == workspace then
					break
				end
			end
			if not hasHum then
				local ok, err = NACaller(function()
					prt.LocalTransparencyModifier = transVal
				end)
				if not ok then
					warn("Failed to mod transparency for part "..tostring(prt)..": "..tostring(err))
				end
			end
		end
	end
end

-- [[ FLY VARIABLES ]] --

local flyVariables = {
	mOn = false;
	mFlyBruh = nil;
	flyEnabled = false;
	toggleKey = "f";
	flySpeed = 1;
	keybindConn = nil;

	vOn = false;
	vRAHH = nil;
	vFlyEnabled = false;
	vToggleKey = "v";
	vFlySpeed = 1;
	vKeybindConn = nil;

	cOn = false;
	cFlyGUI = nil;
	cFlyEnabled = false;
	cToggleKey = "c";
	cFlySpeed = 1;
	cKeybindConn = nil;

	TFlyEnabled = false;
	tflyCORE = nil;
	tflyToggleKey = "t";
	tflyButtonUI = nil;
	TFLYBTN = nil;
	tflyKeyConn = nil;
	TflySpeed = 2;
}

-----------------------------

cmdlp = Players.LocalPlayer
plr = cmdlp
local cmdm = plr:GetMouse()
goofyFLY = nil

function sFLY(vfly, cfly)
	while not cmdlp or not getChar() or not getRoot(getChar()) or not getHum() or not cmdm do
		Wait()
	end

	if goofyFLY then goofyFLY:Destroy() end
	if CFloop then CFloop:Disconnect() CFloop = nil end

	local char = getChar()
	local humanoid = getHum()
	local Head = getHead(char)
	local root = getRoot(char)
	if not root then return end

	local Camera = workspace.CurrentCamera

	goofyFLY = InstanceNew("Part", workspace)
	goofyFLY.Size = Vector3.new(0.05, 0.05, 0.05)
	goofyFLY.Transparency = 1
	goofyFLY.CanCollide = false
	goofyFLY.Anchored = cfly and true or false

	local CONTROL = { Q = 0, E = 0 }
	local lCONTROL = { Q = 0, E = 0 }
	local SPEED = 0

	cmdm.KeyDown:Connect(function(KEY)
		local key = KEY:lower()
		if key == 'q' then
			CONTROL.Q = vfly and -speedofthevfly * 2 or -speedofthefly * 2
		elseif key == 'e' then
			CONTROL.E = vfly and speedofthevfly * 2 or speedofthefly * 2
		end
	end)

	cmdm.KeyUp:Connect(function(KEY)
		local key = KEY:lower()
		if key == 'q' then
			CONTROL.Q = 0
		elseif key == 'e' then
			CONTROL.E = 0
		end
	end)

	if cfly then
		humanoid.PlatformStand = true
		Head.Anchored = true

		CFloop = RunService.Stepped:Connect(function()
			local moveVec = GetCustomMoveVector()
			local vertical = (CONTROL.E + CONTROL.Q)
			local fullMove = Vector3.new(moveVec.X, vertical, -moveVec.Z)

			local moveDirection =
				(Camera.CFrame.RightVector * fullMove.X) +
				(Camera.CFrame.UpVector * fullMove.Y) +
				(Camera.CFrame.LookVector * fullMove.Z)

			if moveDirection.Magnitude > 0 then
				local newPos = Head.Position + moveDirection.Unit * flyVariables.flySpeed
				local lookAt = newPos + Camera.CFrame.LookVector
				Head.CFrame = CFrame.new(newPos, lookAt)
				goofyFLY.CFrame = Head.CFrame
			end
		end)
	else
		local Weld = InstanceNew("Weld", goofyFLY)
		Weld.Part0 = goofyFLY
		Weld.Part1 = root
		Weld.C0 = CFrame.new()

		local BG = InstanceNew("BodyGyro", goofyFLY)
		BG.P = 9e4
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = Camera.CFrame

		local BV = InstanceNew("BodyVelocity", goofyFLY)
		BV.velocity = Vector3.zero
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)

		FLYING = true

		Spawn(function()
			while FLYING do
				if not vfly then
					humanoid.PlatformStand = true
				end

				local moveVec = GetCustomMoveVector()
				moveVec = Vector3.new(moveVec.X, moveVec.Y, -moveVec.Z)
				local hasInput = moveVec.Magnitude > 0 or CONTROL.Q ~= 0 or CONTROL.E ~= 0

				if hasInput then
					SPEED = (vfly and flyVariables.vFlySpeed or flyVariables.flySpeed) * 50
				elseif SPEED ~= 0 then
					SPEED = 0
				end

				if hasInput then
					BV.velocity = ((Camera.CoordinateFrame.LookVector * moveVec.Z) +
						((Camera.CoordinateFrame * CFrame.new(moveVec.X, (moveVec.Z + CONTROL.Q + CONTROL.E) * 0.2, 0).p) -
							Camera.CoordinateFrame.p)) * SPEED
					lCONTROL = { Q = CONTROL.Q, E = CONTROL.E }
				elseif SPEED ~= 0 then
					BV.velocity = ((Camera.CoordinateFrame.LookVector * moveVec.Z) +
						((Camera.CoordinateFrame * CFrame.new(moveVec.X, (moveVec.Z + lCONTROL.Q + lCONTROL.E) * 0.2, 0).p) -
							Camera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.zero
				end

				BG.cframe = Camera.CoordinateFrame
				Wait()
			end

			CONTROL = { Q = 0, E = 0 }
			lCONTROL = { Q = 0, E = 0 }
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			humanoid.PlatformStand = false
		end)
	end
end

NAmanage.readAliasFile = function()
	if FileSupport and isfile(NAfiles.NAALIASPATH) then
		local success, data = NACaller(function()
			return HttpService:JSONDecode(readfile(NAfiles.NAALIASPATH))
		end)
		if success and type(data) == "table" then
			return data
		end
	end
	return {}
end

NAmanage.loadAliases = function()
	local aliasMap = NAmanage.readAliasFile()
	for alias, original in pairs(aliasMap) do
		if cmds.Commands[original:lower()] then
			local command = cmds.Commands[original:lower()]
			cmds.Aliases[alias:lower()] = {command[1], command[2], command[3]}
			cmds.NASAVEDALIASES[alias:lower()] = true
		end
	end
end

NAmanage.loadButtonIDS = function()
	if FileSupport and isfile(NAfiles.NAUSERBUTTONSPATH) then
		local success, data = NACaller(function()
			return HttpService:JSONDecode(readfile(NAfiles.NAUSERBUTTONSPATH))
		end)
		if success and type(data) == "table" then
			NAUserButtons = data
		end
	end
end

NAmanage.loadAutoExec = function()
	NAEXECDATA = {commands = {}, args = {}}

	if FileSupport and isfile(NAfiles.NAAUTOEXECPATH) then
		local success, decoded = NACaller(function()
			return HttpService:JSONDecode(readfile(NAfiles.NAAUTOEXECPATH))
		end)
		if success and type(decoded) == "table" then
			NAEXECDATA = decoded

			if not NAEXECDATA.commands then
				NAEXECDATA.commands = {}
			end
			if not NAEXECDATA.args then
				NAEXECDATA.args = {}
			end
		end
	end
end

NAmanage.LoadPlugins = function()
	if not CustomFunctionSupport then return end

	local function formatInfo(aliases, argsHint)
		local main = aliases[1]
		local extras = {}

		for i = 2, #aliases do
			Insert(extras, aliases[i])
		end

		local formatted = main

		if argsHint and argsHint ~= "" then
			formatted = formatted.." "..argsHint
		end

		if #extras > 0 then
			formatted = formatted.." ("..Concat(extras, ", ")..")"
		end

		return formatted
	end

	local loadedSummaries = {}

	local files = listfiles(NAfiles.NAPLUGINFILEPATH)

	for _, file in ipairs(files) do
		if Lower(file):match("%.na$") then
			local success, content = NACaller(readfile, file)
			if success and content then
				local func, loadErr = loadstring(content)
				if func then
					local collectedPlugins = {}

					local proxyEnv = {}
					local baseEnv = getfenv()

					setmetatable(proxyEnv, {
						__index = baseEnv,
						__newindex = function(_, k, v)
							if k == "cmdPluginAdd" then
								if type(v) == "table" then
									if v[1] and type(v[1]) == "table" then
										for _, sub in ipairs(v) do
											Insert(collectedPlugins, sub)
										end
									else
										Insert(collectedPlugins, v)
									end
								end
							else
								rawset(baseEnv, k, v)
							end
						end
					})

					setfenv(func, proxyEnv)

					local ok, execErr = NACaller(func)
					if ok then
						local fileCommandNames = {}

						for _, plugin in ipairs(collectedPlugins) do
							local aliases = plugin.Aliases
							local handler = plugin.Function

							if type(aliases) == "table" and type(handler) == "function" then
								local argsHint = plugin.ArgsHint or ""
								local formattedDisplay = formatInfo(aliases, argsHint)
								local info = {
									formattedDisplay,
									plugin.Info or "No description"
								}

								cmd.add(
									aliases,
									info,
									handler,
									plugin.RequiresArguments or false
								)

								Insert(fileCommandNames, aliases[1])
							else
								DoWindow("[Plugin Invalid] '"..file.."' is missing valid Aliases or Function")
							end
						end

						if #fileCommandNames > 0 then
							local fileName = file:match("[^\\/]+$") or file
							Insert(loadedSummaries, fileName.." ("..Concat(fileCommandNames, ", ")..")")
						end
					else
						DoWindow("[Plugin Error] '"..file.."' => "..tostring(execErr))
					end
				else
					DoWindow("[Plugin Load Error] '"..file.."': "..tostring(loadErr))
				end
			else
				DoWindow("[Plugin Read Error] Failed to read '"..file.."'")
			end
		end
	end

	if #loadedSummaries > 0 then
		DoNotif("Loaded plugins:\n\n"..Concat(loadedSummaries, "\n\n"), 5.7)
	end
end

NAmanage.SaveWaypoints = function()
	if not FileSupport then return end

	local path = NAmanage.GetWPPath()

	if next(Waypoints) then
		writefile(path, HttpService:JSONEncode(Waypoints))
	else
		if delfile and isfile(path) then
			pcall(delfile, path)
		else
			writefile(path, "{}")
		end
	end
end

NAmanage.SaveBinders=function()
	if FileSupport then
		writefile(bindersPath, HttpService:JSONEncode(Bindings))
	end
end

NAmanage.LogJoinLeave = function(message)
	if not FileSupport or not appendfile or not JoinLeaveConfig.SaveLog then return end

	local logPath = NAfiles.NAJOINLEAVELOG
	local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")

	local logMessage = Format(
		"%s %s | Game: %s | PlaceId: %s | GameId: %s | JobId: %s\n",
		timestamp,
		message,
		placeName() or "unknown",
		tostring(PlaceId),
		tostring(GameId),
		tostring(JobId)
	)

	if isfile(logPath) then
		appendfile(logPath, logMessage)
	else
		writefile(logPath, logMessage)
	end
end

NAmanage.RenderUserButtons = function()
	if NAStuff.KeybindConnection then
		NAStuff.KeybindConnection:Disconnect()
		NAStuff.KeybindConnection = nil
	end
	for _, btn in pairs(UserButtonGuiList) do
		btn:Destroy()
	end
	table.clear(UserButtonGuiList)

	local UIS = UserInputService
	local SavedArgs       = {}
	local ActivePrompts   = {}
	local ActiveKeyBinding= {}
	local ActionBindings  = {}
	local tSize = 28

	function ButtonInputPrompt(cmdName, cb)
		local gui = InstanceNew("ScreenGui")
		gui.IgnoreGuiInset = true
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = NAStuff.NASCREENGUI

		local f = InstanceNew("Frame")
		f.Size = UDim2.new(0,260,0,140)
		f.Position = UDim2.new(0.5,-130,0.5,-70)
		f.BackgroundColor3 = Color3.fromRGB(30,30,30)
		f.BorderSizePixel = 0
		f.Parent = gui

		local u = InstanceNew("UICorner")
		u.CornerRadius = UDim.new(0.1,0)
		u.Parent = f

		local t = InstanceNew("TextLabel")
		t.Size = UDim2.new(1,-20,0,30)
		t.Position = UDim2.new(0,10,0,10)
		t.BackgroundTransparency = 1
		t.Text = "Arguments for: "..cmdName
		t.TextColor3 = Color3.fromRGB(255,255,255)
		t.Font = Enum.Font.GothamBold
		t.TextSize = 16
		t.TextWrapped = true
		t.Parent = f

		local tb = InstanceNew("TextBox")
		tb.Size = UDim2.new(1,-20,0,30)
		tb.Position = UDim2.new(0,10,0,50)
		tb.BackgroundColor3 = Color3.fromRGB(50,50,50)
		tb.TextColor3 = Color3.fromRGB(255,255,255)
		tb.PlaceholderText = "Type arguments here"
		tb.Text=""
		tb.TextSize = 16
		tb.Font = Enum.Font.Gotham
		tb.ClearTextOnFocus = false
		tb.Parent = f

		local s = InstanceNew("TextButton")
		s.Size = UDim2.new(0.5,-15,0,30)
		s.Position = UDim2.new(0,10,1,-40)
		s.BackgroundColor3 = Color3.fromRGB(0,170,255)
		s.Text = "Submit"
		s.TextColor3 = Color3.fromRGB(255,255,255)
		s.Font = Enum.Font.GothamBold
		s.TextSize = 14
		s.Parent = f

		local c = InstanceNew("TextButton")
		c.Size = UDim2.new(0.5,-15,0,30)
		c.Position = UDim2.new(0.5,5,1,-40)
		c.BackgroundColor3 = Color3.fromRGB(255,0,0)
		c.Text = "Cancel"
		c.TextColor3 = Color3.fromRGB(255,255,255)
		c.Font = Enum.Font.GothamBold
		c.TextSize = 14
		c.Parent = f

		MouseButtonFix(s, function()
			cb(tb.Text)
			ActivePrompts[cmdName] = nil
			gui:Destroy()
		end)
		MouseButtonFix(c, function()
			ActivePrompts[cmdName] = nil
			gui:Destroy()
		end)
		NAgui.draggerV2(f)
	end

	local total   = #NAUserButtons
	local totalW  = total * 110
	local startX  = 0.5 - (totalW/2)/NAStuff.NASCREENGUI.AbsoluteSize.X
	local spacing = 110
	local ON, OFF = Color3.fromRGB(0,170,0), Color3.fromRGB(30,30,30)

	local idx = 0
	for id, data in pairs(NAUserButtons) do
		local btn = InstanceNew("TextButton")
		btn.Name            = "NAUserButton_"..id
		btn.Text            = data.Label
		btn.Size            = UDim2.new(0,60, 0,60)
		btn.AnchorPoint     = Vector2.new(0.5,1)
		btn.Position        = UDim2.new(startX + (spacing*idx)/NAStuff.NASCREENGUI.AbsoluteSize.X, 0, 0.9, 0)
		btn.Parent          = NAStuff.NASCREENGUI
		btn.BackgroundColor3= Color3.fromRGB(0,0,0)
		btn.TextColor3      = Color3.fromRGB(255,255,255)
		btn.TextScaled      = true
		btn.Font            = Enum.Font.GothamBold
		btn.BorderSizePixel = 0
		btn.ZIndex          = 9999
		btn.AutoButtonColor = true

		local btnCorner = InstanceNew("UICorner")
		btnCorner.CornerRadius = UDim.new(0.25,0)
		btnCorner.Parent       = btn
		NAgui.draggerV2(btn)

		local toggled     = false
		local saveEnabled = data.RunMode == "S"
		SavedArgs[id]     = data.Args or {}

		local cmd1      = data.Cmd1
		local cd1       = cmds.Commands[cmd1:lower()] or cmds.Aliases[cmd1:lower()]
		local needsArgs = cd1 and cd1[3]

		if needsArgs then
			local saveToggle = InstanceNew("TextButton")
			saveToggle.Size             = UDim2.new(0,tSize,0,tSize)
			saveToggle.AnchorPoint      = Vector2.new(1,1)
			saveToggle.Position         = UDim2.new(1,0,0,0)
			saveToggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
			saveToggle.TextColor3       = Color3.fromRGB(255,255,255)
			saveToggle.TextScaled       = true
			saveToggle.Font             = Enum.Font.Gotham
			saveToggle.Text             = saveEnabled and "S" or "N"
			saveToggle.ZIndex           = 10000
			saveToggle.Parent           = btn

			local stCorner = InstanceNew("UICorner")
			stCorner.CornerRadius = UDim.new(0.5,0)
			stCorner.Parent       = saveToggle

			MouseButtonFix(saveToggle, function()
				saveEnabled = not saveEnabled
				saveToggle.Text = saveEnabled and "S" or "N"
				data.RunMode = saveEnabled and "S" or "N"
				if FileSupport then
					writefile(NAfiles.NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
				end
			end)
		end

		local function runCmd(args)
			local toRun = (not toggled or not data.Cmd2) and data.Cmd1 or data.Cmd2
			local arr   = {toRun}
			if args then for _,v in ipairs(args) do Insert(arr, v) end end
			cmd.run(arr)
			if data.Cmd2 then
				toggled = not toggled
				btn.BackgroundColor3 = toggled and ON or OFF
			end
		end

		MouseButtonFix(btn, function()
			local now     = (not toggled or not data.Cmd2) and data.Cmd1 or data.Cmd2
			local nd      = cmds.Commands[now:lower()] or cmds.Aliases[now:lower()]
			local na      = nd and nd[3]
			if na then
				if saveEnabled and data.Args and #data.Args>0 then
					runCmd(data.Args)
				else
					if ActivePrompts[now] then return end
					ActivePrompts[now] = true
					ButtonInputPrompt(now, function(input)
						ActivePrompts[now] = nil
						local parsed = ParseArguments(input)
						if parsed then
							SavedArgs[id] = parsed
							data.Args     = parsed
							if FileSupport then
								writefile(NAfiles.NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
							end
							runCmd(parsed)
						else
							runCmd(nil)
						end
					end)
				end
			else
				runCmd(nil)
			end
		end)

		if IsOnPC then
			local keyToggle = InstanceNew("TextButton")
			keyToggle.Size             = UDim2.new(0,tSize,0,tSize)
			keyToggle.AnchorPoint      = Vector2.new(0,1)
			keyToggle.Position         = UDim2.new(0,0,0,0)
			keyToggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
			keyToggle.TextColor3       = Color3.fromRGB(255,255,255)
			keyToggle.TextScaled       = true
			keyToggle.Font             = Enum.Font.Gotham
			keyToggle.Text             = data.Keybind or "Key"
			keyToggle.ZIndex           = 10000
			keyToggle.Parent           = btn

			local ktCorner = InstanceNew("UICorner")
			ktCorner.CornerRadius = UDim.new(0.5,0)
			ktCorner.Parent       = keyToggle

			MouseButtonFix(keyToggle, function()
				if ActiveKeyBinding[id] then return end
				ActiveKeyBinding[id] = true
				keyToggle.Text = "..."
				local conn
				conn = UIS.InputBegan:Connect(function(input, gp)
					if gp or not input.KeyCode then return end
					local old = data.Keybind
					if old then ActionBindings[old] = nil end
					local new = input.KeyCode.Name
					data.Keybind = new
					keyToggle.Text = new
					if FileSupport then
						writefile(NAfiles.NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
					end
					ActionBindings[new] = function() runCmd(data.Args) end
					ActiveKeyBinding[id] = nil
					conn:Disconnect()
				end)
			end)

			if data.Keybind then
				ActionBindings[data.Keybind] = function() runCmd(data.Args) end
			end
		end

		Insert(UserButtonGuiList, btn)
		idx = idx + 1
	end

	if IsOnPC then
		NAStuff.KeybindConnection = UIS.InputBegan:Connect(function(input, gp)
			if gp or not input.KeyCode then return end
			local act = ActionBindings[input.KeyCode.Name]
			if act then act() end
		end)
	end
end

local lp=Players.LocalPlayer

--[[ LIB FUNCTIONS ]]--
chatmsgshooks={}
Playerchats={}
local oldChat = false --TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService and ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and  ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

if oldChat then
	NAlib.LocalPlayerChat=function(...)
		local args={...}
		if args[2] and args[2]~="All" then
			ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..args[2].." "..args[1] or "","All")
		else
			ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(args[1] or "","All")
		end
	end
else
	local RBXGeneral = nil
	NACaller(function()
		if TextChatService.CreateDefaultTextChannels then
			for i,v in pairs(TextChatService:GetDescendants()) do
				if v:IsA("TextChannel") and v.Name=="RBXGeneral" then
					if v:FindFirstChild(Players.LocalPlayer.Name) and v[Players.LocalPlayer.Name]:IsA("TextSource") then
						RBXGeneral = v
						break
					end
				end
			end
		end

		if not RBXGeneral then
			for i,v in pairs(TextChatService:GetDescendants()) do
				if v:IsA("TextChannel") then
					for index,player in pairs(Players:GetPlayers()) do
						if v:FindFirstChild(player.Name) and v[player.Name]:IsA("TextSource") and v[player.Name].CanSend then
							RBXGeneral = v
						else
							RBXGeneral = nil
							break
						end
					end
					if RBXGeneral then
						break
					end
				end
			end

			if not RBXGeneral then
				for i,v in pairs(TextChatService:GetDescendants()) do
					if v:IsA("TextChannel") then
						if v:FindFirstChild(Players.LocalPlayer.Name) and v[Players.LocalPlayer.Name]:IsA("TextSource") and v[Players.LocalPlayer.Name].CanSend then
							RBXGeneral = v
							break
						end
					end
				end
			end
			-- i have tried enough
			if not RBXGeneral then
				NAlib.LocalPlayerChat=function(...)
					NACaller(function()
						error("unable to get the chat system for the game")
					end)	
				end
				return	
			end
		end

		NAlib.LocalPlayerChat=function(...)
			local args={...}
			local sendto=RBXGeneral
			if args[2]~=nil and  args[2]~="All"  then
				if not Playerchats[args[2]] then
					for i,v in pairs(TextChatService:GetDescendants()) do
						if v:IsA("TextChannel") and Find(v.Name,"RBXWhisper:") then
							if v:FindFirstChild(args[2]) and v:FindFirstChild(Players.LocalPlayer.Name) then
								if v[Players.LocalPlayer.Name].CanSend==false then
									continue
								end
								sendto=v
								Playerchats[args[2]]=v
								break
							end
						end
					end
				else
					sendto=Playerchats[args[2]]
				end
				if sendto==RBXGeneral then
					chatmsgshooks[args[1]]={args[1],args}
					Spawn(function()
						RBXGeneral:SendAsync("/w @"..args[2])
					end)
					return "Hooking"
				end
			end
			sendto:SendAsync(args[1] or "")

		end
	end)

	if TextChatService:FindFirstChild("TextChannels") then
		TextChatService.TextChannels.ChildAdded:Connect(function(v)
			if  v:IsA("TextChannel") and Find(v.Name,"RBXWhisper:") then
				Wait(1)
				for id,va in pairs(chatmsgshooks) do
					if v:FindFirstChild(va[1]) and v:FindFirstChild(Players.LocalPlayer.Name) then
						if v[Players.LocalPlayer.Name].CanSend==false then
							continue
						end
						Playerchats[va[1]]=v
						chatmsgshooks[id]=nil
						NAlib.LocalPlayerChat(va[2])
					end
				end
			end
		end)
	end
end

NAlib.lpchat=NAlib.LocalPlayerChat

NAlib.find=function(t,v)	--mmmmmm
	for i,e in pairs(t) do
		if i==v or e==v then
			return i
		end
	end
	return nil
end

NAlib.parseText = function(text, watch, rPlr)
	local function FIIIX(str)
		local chatPrefix = str:match("^/(%a+)%s")
		if chatPrefix then
			str = str:gsub("^/%a+%s*", "")
		end
		return str
	end

	if not text then return nil end

	local prefix
	if rPlr then
		if isRelAdmin(rPlr) and isRelAdmin(Players.LocalPlayer) then
			return nil
		elseif not isRelAdmin(rPlr) then
			prefix = ";"
		else
			prefix = watch
		end
		watch = prefix
	else
		prefix = watch
	end

	text = FIIIX(text)

	if text:sub(1, #prefix) ~= prefix then
		return nil
	end

	text = text:sub(#prefix + 1)

	local parsed = {}
	for arg in text:gmatch("[^ ]+") do
		Insert(parsed, arg)
	end

	return {parsed}
end

NAlib.parseCommand = function(text, rPlr)
	wrap(function()
		local prefix = rPlr and (isRelAdmin(rPlr) and not isRelAdmin(Players.LocalPlayer) and ";" or nil) or opt.prefix
		if not prefix then return end
		local commands = NAlib.parseText(text, prefix, rPlr)
		if not commands then return end
		for _, parsed in pairs(commands) do
			local args = {}
			for _, arg in pairs(parsed) do
				Insert(args, arg)
			end
			cmd.run(args)
		end
	end)
end

local connections = {}

NAlib.connect = function(name, connection)
	connections[name] = connections[name] or {}
	Insert(connections[name], connection)
	return connection
end

NAlib.disconnect = function(name)
	if connections[name] then
		for _, conn in ipairs(connections[name]) do
			conn:Disconnect()
		end
		connections[name] = nil
	end
end

NAlib.isConnected = function(name)
	return connections[name] ~= nil
end

NAlib.isProperty = function(inst, prop)
	local s, r = pcall(function() return inst[prop] end)
	if not s then return nil end
	return r
end

NAlib.setProperty = function(inst, prop, v)
	local s, _ = pcall(function() inst[prop] = v end)
	return s
end

--prepare for annoying and unnecessary tool grip math
local rad=math.rad
local clamp=math.clamp
local tan=math.tan

--[[ COMMANDS ]]--

cmd.add({"url"}, {"url <link>", "Run the script using URL"}, function(...)
	local args = {...}
	local link = Concat(args, " ")

	if not link or link == "" then
		return DoNotif("no link provided", 2)
	end

	local success, result = NACaller(function()
		return game:HttpGet(link)
	end)

	if not success then return end

	local func = loadstring(result)
	if not func then return end

	Spawn(func)
end, true)

cmd.add({"loadstring", "ls", "lstring", "loads", "execute"}, {"loadstring <code> (ls, lstring, loads, execute)", "Run code using loadstring"}, function(...)
	local args = {...}
	local code = Concat(args, " ")

	if not code or code == "" then
		return DoNotif("no code provided", 2)
	end

	local func = loadstring(code)
	if not func then return end

	Spawn(func)
end, true)

cmd.add({"addalias"}, {"addalias <command> <alias>", "Adds a persistent alias for an existing command"}, function(original, alias)
	if not original or not alias then
		DoNotif("Usage: addalias <command> <alias>", 2)
		return
	end

	original, alias = original:lower(), alias:lower()

	if not cmds.Commands[original] then
		DoNotif("Command '"..original.."' does not exist", 2)
		return
	end

	if cmds.Commands[alias] or cmds.Aliases[alias] then
		DoNotif("The name '"..alias.."' is already used by another command or alias", 2)
		return
	end

	local command = cmds.Commands[original]
	cmds.Aliases[alias] = {command[1], command[2], command[3]}
	cmds.NASAVEDALIASES[alias] = true

	if FileSupport then
		local aliasMap = NAmanage.readAliasFile()
		aliasMap[alias] = original
		writefile(NAfiles.NAALIASPATH, HttpService:JSONEncode(aliasMap))
	end

	DoNotif("Alias '"..alias.."' has been added for command '"..original.."'", 2)
end, true)

cmd.add({"removealias"}, {"removealias", "Select and remove a saved alias"}, function()
	local aliasMap = FileSupport and NAmanage.readAliasFile() or {}

	if next(aliasMap) == nil then
		DoNotif("No saved aliases to remove", 2)
		return
	end

	local buttons = {}

	for alias, original in pairs(aliasMap) do
		Insert(buttons, {
			Text = 'Alias: '..alias.." | Command: "..original,
			Callback = function()
				cmds.Aliases[alias] = nil
				aliasMap[alias] = nil
				if FileSupport then
					writefile(NAfiles.NAALIASPATH, HttpService:JSONEncode(aliasMap))
				end
				DoNotif("Removed alias '"..alias.."'", 2)
			end
		})
	end

	Window({
		Title = "Remove Alias",
		Description = "Select an alias to remove:",
		Buttons = buttons
	})
end)

cmd.add({"clearaliases"}, {"clearaliases", "Removes all aliases created using addalias."}, function()
	if not FileSupport then return end

	for alias in pairs(cmds.NASAVEDALIASES) do
		cmds.Aliases[alias] = nil
	end

	cmds.NASAVEDALIASES = {}
	writefile(NAfiles.NAALIASPATH, "{}")
	DoNotif("All aliases have been removed", 2)
end)

cmd.add({"addbutton", "ab"}, {"addbutton <command> <label> [<command2>] (ab)", "Add a mobile button"}, function(arg1, arg2, arg3)
	if not arg1 or not arg2 then
		DoNotif("Usage: ;addbutton <command> <label> [<command2>]", 2)
		return
	end

	local id = #NAUserButtons + 1
	NAUserButtons[id] = {
		Cmd1 = arg1,
		Label = arg2,
		Cmd2 = arg3
	}

	if FileSupport then
		writefile(NAfiles.NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
	end

	NAmanage.RenderUserButtons()

	DoNotif("Added button with id "..id, 2)
end,true)

cmd.add({"removebutton", "rb"}, {"removebutton (rb)", "Remove a user button"}, function()
	if not next(NAUserButtons) then
		DoNotif("No user buttons to remove", 2)
		return
	end

	local options = {}
	for id, data in pairs(NAUserButtons) do
		local label = data.Label or ("Button "..id)
		local cmdDisplay = data.Cmd1 or "?"
		if data.Cmd2 then
			cmdDisplay = cmdDisplay.." / "..data.Cmd2
		end

		Insert(options, {
			Text = "["..id.."] "..label.." ("..cmdDisplay..")",
			Callback = function()
				NAUserButtons[id] = nil

				if FileSupport then
					writefile(NAfiles.NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
				end

				NAmanage.RenderUserButtons()

				DoNotif("Removed user button: ["..id.."] "..label, 2)
			end
		})
	end

	Window({
		Title = "Remove User Button",
		Description = "Select a button to remove:",
		Buttons = options
	})
end)

cmd.add({"clearbuttons", "clearbtns", "cb"}, {"clearbuttons (clearbtns, cb)", "Clear all user buttons"}, function()
	if not next(NAUserButtons) then
		DoNotif("No user buttons to clear", 2)
		return
	end

	Window({
		Title = "Clear All Buttons",
		Description = "Are you sure you want to clear all user buttons?",
		Buttons = {
			{
				Text = "Yes",
				Callback = function()
					table.clear(NAUserButtons)

					if FileSupport then
						writefile(NAfiles.NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
					end

					NAmanage.RenderUserButtons()

					DoNotif("Cleared all user buttons", 2)
				end
			}
		}
	})
end)

cmd.add({"addautoexec", "aaexec", "addae", "addauto", "aexecadd"}, {"addautoexec <command> [arguments] (aaexec, addae, addauto, aexecadd)", "Add a command to autoexecute"}, function(arg1, ...)
	if not arg1 then
		DoNotif("Usage: ;addautoexec <command> [arguments...]", 2)
		return
	end

	local args = {...}
	local commandName = arg1:lower()

	if not cmds.Commands[commandName] and not cmds.Aliases[commandName] then
		DoNotif("Command ["..commandName.."] does not exist", 2)
		return
	end

	NAEXECDATA = NAEXECDATA or {commands = {}, args = {}}
	if not NAEXECDATA.commands then
		NAEXECDATA.commands = {}
	end
	if not NAEXECDATA.args then
		NAEXECDATA.args = {}
	end

	local exists = false
	for _, cmd in ipairs(NAEXECDATA.commands) do
		if cmd == commandName then
			exists = true
			break
		end
	end
	if not exists then
		Insert(NAEXECDATA.commands, commandName)
	end

	if #args > 0 then
		local argumentString = Concat(args, " ")
		NAEXECDATA.args[commandName] = argumentString
	else
		NAEXECDATA.args[commandName] = ""
	end

	if FileSupport then
		writefile(NAfiles.NAAUTOEXECPATH, HttpService:JSONEncode(NAEXECDATA))
	end

	DoNotif("Added to AutoExec: "..arg1.." "..(args[1] or ""), 2)
end,true)

cmd.add({"removeautoexec", "raexec", "removeae", "removeauto", "aexecremove"}, {"removeautoexec (raexec, removeae, removeauto, aexecremove)", "Remove a command from autoexecute"}, function()
	if #NAEXECDATA.commands == 0 then
		DoNotif("No AutoExec commands to remove", 2)
		return
	end

	local options = {}
	for i, cmdName in ipairs(NAEXECDATA.commands) do
		local args = NAEXECDATA.args[cmdName]
		local display = args and args ~= "" and (cmdName.." "..args) or cmdName
		Insert(options, {
			Text = display,
			Callback = function()
				local removedCommand = table.remove(NAEXECDATA.commands, i)
				NAEXECDATA.args[removedCommand] = nil

				if FileSupport then
					writefile(NAfiles.NAAUTOEXECPATH, HttpService:JSONEncode(NAEXECDATA))
				end

				DoNotif("Removed AutoExec command: "..display, 2)
			end
		})
	end

	Window({
		Title = "Remove AutoExec Command",
		Description = "Select which AutoExec to remove:",
		Buttons = options
	})
end)

cmd.add({"autoexecclear", "aexecclear", "aeclear"}, {"autoexecclear (aexecclear, aeclear)", "Clear all AutoExec commands"}, function()
	if #NAEXECDATA.commands == 0 then
		DoNotif("No AutoExec commands to clear", 2)
		return
	end

	NAEXECDATA.commands = {}
	NAEXECDATA.args = {}

	if FileSupport then
		writefile(NAfiles.NAAUTOEXECPATH, HttpService:JSONEncode(NAEXECDATA))
	end

	DoNotif("Cleared all AutoExec commands", 2)
end)

cmd.add({"executor","exec"},{"executor (exec)","Very simple executor"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NAexecutor.lua"))()
end)

cmd.add({"commandloop", "cmdloop"}, {"commandloop <command> {arguments} (cmdloop)", "Run a command on loop"}, function(...)
	local args = {...}
	local commandName = args[1]
	table.remove(args, 1)

	if not commandName then
		DoNotif("Command name is required.",3)
		return
	end

	cmd.loop(commandName, args)
end,true)

cmd.add({"stoploop", "uncmdloop", "sloop", "stopl"}, {"stoploop", "Stop a running loop"}, function()
	cmd.stopLoop()
end)

cmd.add({"scripthub","hub"},{"scripthub (hub)","Thanks to scriptblox/rscripts API"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/ScriptHubNA.lua"))()
end)

--[[cmd.add({"resizechat","rc"},{"resizechat (rc)","Makes chat resizable and draggable"},function()
	require(SafeGetService("Chat").ClientChatModules.ChatSettings).WindowResizable=true
	require(SafeGetService("Chat").ClientChatModules.ChatSettings).WindowDraggable=true
end)]]

local scaleFrame = nil
cmd.add({"uiscale", "uscale", "guiscale", "gscale"}, {"uiscale (uscale)", "Adjust the scale of the "..adminName.." UI"}, function()
	if scaleFrame then scaleFrame:Destroy() scaleFrame=nil end
	scaleFrame = InstanceNew("ScreenGui")
	local frame = InstanceNew("Frame")
	local frameCorner = InstanceNew("UICorner")
	local slider = InstanceNew("Frame")
	local sliderCorner = InstanceNew("UICorner")
	local progress = InstanceNew("Frame")
	local progressCorner = InstanceNew("UICorner")
	local knob = InstanceNew("TextButton")
	local knobCorner = InstanceNew("UICorner")
	local label = InstanceNew("TextLabel")
	local closeButton = InstanceNew("TextButton")
	local closeCorner = InstanceNew("UICorner")

	local sizeRange = {0.5, 2.5}
	local minSize, maxSize = sizeRange[1], sizeRange[2]

	NaProtectUI(scaleFrame)
	frame.Parent = scaleFrame
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Size = UDim2.new(0, 400, 0, 120)
	frame.Position = UDim2.new(0.5,-283/2+5,0.5,-260/2+5)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.05

	frameCorner.CornerRadius = UDim.new(0.1, 0)
	frameCorner.Parent = frame

	slider.Parent = frame
	slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	slider.Size = UDim2.new(0.8, 0, 0.2, 0)
	slider.Position = UDim2.new(0.1, 0, 0.5, 0)
	slider.AnchorPoint = Vector2.new(0, 0.5)
	slider.BorderSizePixel = 0

	sliderCorner.CornerRadius = UDim.new(0.5, 0)
	sliderCorner.Parent = slider

	progress.Parent = slider
	progress.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	progress.Size = UDim2.new((NAUIScale - minSize) / (maxSize - minSize), 0, 1, 0)
	progress.BorderSizePixel = 0

	progressCorner.CornerRadius = UDim.new(0.5, 0)
	progressCorner.Parent = progress

	knob.Parent = slider
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Size = UDim2.new(0, 25, 1.5, 0)
	knob.Position = UDim2.new((NAUIScale - minSize) / (maxSize - minSize), 0, -0.25, 0)
	knob.Text = ""
	knob.BorderSizePixel = 0
	knob.AutoButtonColor = false

	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	label.Parent = frame
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0.3, 0)
	label.Position = UDim2.new(0, 0, 0.1, 0)
	label.Text = "Scale: "..Format("%.2f", NAUIScale)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.Gotham
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Center

	closeButton.Parent = frame
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -40, 0, 10)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.Gotham
	closeButton.TextSize = 14
	closeButton.BorderSizePixel = 0

	closeCorner.CornerRadius = UDim.new(0.5, 0)
	closeCorner.Parent = closeButton

	local function update(scale)
		opt.NAAUTOSCALER.Scale = scale
		progress.Size = UDim2.new((scale - minSize) / (maxSize - minSize) + 0.05, 0, 1, 0)
		knob.Position = UDim2.new((scale - minSize) / (maxSize - minSize), 0, -0.25, 0)
		label.Text = "Scale: "..Format("%.2f", scale)
	end

	update(NAUIScale)

	local dragging = false
	local dragInput
	local sliderStart, sliderWidth

	local UserInputService = UserInputService
	local RunService = RunService

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			sliderStart = slider.AbsolutePosition.X
			sliderWidth = slider.AbsoluteSize.X
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if FileSupport then
						writefile(NAfiles.NAUISIZEPATH, tostring(NAUIScale))
					end
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local mouseX = input.Position.X
			local relativePosition = (mouseX - sliderStart) / sliderWidth
			local newScale = math.clamp(relativePosition, 0, 1) * (maxSize - minSize) + minSize
			NAUIScale = math.clamp(newScale, minSize, maxSize)
			update(NAUIScale)
		end
	end)

	MouseButtonFix(closeButton,function()
		scaleFrame:Destroy()
	end)

	NAgui.draggerV2(frame)
end)

cmd.add({"prefix"}, {"prefix <symbol>", "Changes the admin prefix"}, function(...)
	local newPrefix = (...)
	if not newPrefix or newPrefix == "" then
		DoNotif("Please enter a valid prefix")
	elseif utf8.len(newPrefix) > 1 then
		DoNotif("Prefix must be a single character (e.g. ; . !)")
	elseif newPrefix:match("[%w]") then
		DoNotif("Prefix cannot contain letters or numbers")
	elseif newPrefix:match("[%[%]%(%)%*%^%$%%{}<>]") then
		DoNotif("That symbol is not allowed as a prefix")
	elseif newPrefix:match("&amp;") or newPrefix:match("&lt;") or newPrefix:match("&gt;") or newPrefix:match("&quot;") or newPrefix:match("&#x27;") or newPrefix:match("&#x60;") then
		DoNotif("Encoded/HTML characters are not allowed as a prefix")
	else
		opt.prefix = newPrefix
		DoNotif("Prefix set to: "..newPrefix)
	end
end, true)

cmd.add({"saveprefix"}, {"saveprefix <symbol>", "Saves the prefix to a file and applies it"}, function(...)
	if not FileSupport then return end

	local newPrefix = (...)
	if not newPrefix or newPrefix == "" then
		DoNotif("Please enter a valid prefix")
	elseif utf8.len(newPrefix) > 1 then
		DoNotif("Prefix must be a single character (e.g. ; . !)")
	elseif newPrefix:match("[%w]") then
		DoNotif("Prefix cannot contain letters or numbers")
	elseif newPrefix:match("[%[%]%(%)%*%^%$%%{}<>]") then
		DoNotif("That symbol is not allowed as a prefix")
	elseif newPrefix:match("&amp;") or newPrefix:match("&lt;") or newPrefix:match("&gt;") or newPrefix:match("&quot;") or newPrefix:match("&#x27;") or newPrefix:match("&#x60;") then
		DoNotif("Encoded/HTML characters are not allowed as a prefix")
	else
		writefile(NAfiles.NAPREFIXPATH, newPrefix)
		opt.prefix = newPrefix
		DoNotif("Prefix saved to: "..newPrefix)
	end
end, true)

--[ UTILITY ]--

cmd.add({"chatlogs","clogs"},{"chatlogs (clogs)","Open the chat logs"},function()
	NAgui.chatlogs()
end)

cmd.add({"gotocampos","tocampos","tcp"},{"gotocampos (tocampos,tcp)","Teleports you to your camera position works with free cam but freezes you"},function()
	local player=Players.LocalPlayer
	local UserInputService=UserInputService
	function teleportPlayer()
		local character=player.Character or player.CharacterAdded:wait(1)
		local camera=workspace.CurrentCamera
		local cameraPosition=camera.CFrame.Position
		character:SetPrimaryPartCFrame(CFrame.new(cameraPosition))
	end
	local camera=workspace.CurrentCamera
	repeat Wait() until camera.CFrame~=CFrame.new()

	teleportPlayer()
end)

cmd.add({"teleportgui","tpui","universeviewer","uviewer"},{"teleportgui (tpui,universeviewer,uviewer)","Gives an UI that grabs all places and teleports you by clicking a simple button"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer"))();
end)

cmd.add({"serverremotespy","srs","sremotespy"},{"serverremotespy (srs,sremotespy)","Gives an UI that logs all the remotes being called from the server (thanks SolSpy lol)"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Server%20Spy.lua"))()
end)

cmd.add({"discord", "invite", "support", "help"}, {"discord (invite, support, help)", "Copy an invite link"}, function()
	if setclipboard then
		Window({
			Title = "Discord",
			Description = inviteLink,
			Buttons = {
				{Text = "Copy Link", Callback = function() setclipboard(inviteLink) end},
				{Text = "Close", Callback = function() end}
			}
		})
	else
		Window({
			Title = "Discord",
			Description = "Your exploit does not support setclipboard.\nPlease manually type the invite link: "..inviteLink,
			Buttons = {
				{Text = "Close", Callback = function() end}
			}
		})
	end
	--DoNotif("not available yet", 2)
end)

clickflingUI = nil
clickflingEnabled = true

cmd.add({"clickfling","mousefling"},{"clickfling (mousefling)","Fling a player by clicking them"},function()
	clickflingEnabled = true
	if clickflingUI then clickflingUI:Destroy() end
	NAlib.disconnect("clickfling_mouse")

	local Mouse = player:GetMouse()
	clickflingUI = InstanceNew("ScreenGui")
	NaProtectUI(clickflingUI)

	local toggleButton = InstanceNew("TextButton")
	toggleButton.Size = UDim2.new(0,120,0,40)
	toggleButton.Text = "ClickFling: ON"
	toggleButton.Position = UDim2.new(0.5,-60,0,10)
	toggleButton.TextScaled = 16
	toggleButton.TextColor3 = Color3.new(1,1,1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
	toggleButton.BackgroundTransparency = 0.2
	toggleButton.Parent = clickflingUI

	local uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0,8)
	uiCorner.Parent = toggleButton

	NAgui.draggerV2(toggleButton)

	MouseButtonFix(toggleButton,function()
		clickflingEnabled = not clickflingEnabled
		if clickflingEnabled then
			toggleButton.Text = "ClickFling: ON"
		else
			toggleButton.Text = "ClickFling: OFF"
		end
	end)

	local conn = Mouse.Button1Down:Connect(function()
		if not clickflingEnabled then return end
		local Target = Mouse.Target
		local Players = game.GetService(game,"Players")
		if Target and Target.Parent and Target.Parent:IsA("Model") and Players:GetPlayerFromCharacter(Target.Parent) then
			local PlayerName = Players:GetPlayerFromCharacter(Target.Parent).Name
			local playerLocal = Players.LocalPlayer
			local Targets = {PlayerName}
			local Players = game.GetService(game,"Players")
			local Player = Players.LocalPlayer
			local AllBool = false

			local GetPlayer = function(Name)
				Name = Lower(Name)
				if Name == "all" or Name == "others" then
					AllBool = true
					return
				elseif Name == "random" then
					local GetPlayers = Players:GetPlayers()
					if Discover(GetPlayers,Player) then table.remove(GetPlayers,Discover(GetPlayers,Player)) end
					return GetPlayers[math.random(#GetPlayers)]
				end
				for _,x in next,Players:GetPlayers() do
					if x~=Player then
						if Sub(Lower(x.Name),1,#Name)==Name or Sub(Lower(x.DisplayName),1,#Name)==Name then
							return x
						end
					end
				end
			end

			local flingManager = flingManager
			local OrgDestroyHeight = workspace.FallenPartsDestroyHeight

			local SkidFling = function(TargetPlayer)
				local Character = Player.Character
				local Humanoid = getPlrHum(Character)
				local RootPart = Humanoid and Humanoid.RootPart
				local TCharacter = TargetPlayer.Character
				local THumanoid = getPlrHum(TCharacter)
				local TRootPart = THumanoid and THumanoid.RootPart
				local THead = getHead(TCharacter)
				local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
				local Handle = Accessory and Accessory:FindFirstChild("Handle")

				if Character and Humanoid and RootPart then
					if not flingManager.cFlingOldPos or RootPart.Velocity.Magnitude<50 then
						flingManager.cFlingOldPos = RootPart.CFrame
					end
					if THead then
						workspace.CurrentCamera.CameraSubject = THead
					elseif Handle then
						workspace.CurrentCamera.CameraSubject = Handle
					elseif THumanoid and TRootPart then
						workspace.CurrentCamera.CameraSubject = THumanoid
					end
					if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

					local function FPos(BasePart,Pos,Ang)
						RootPart.CFrame = CFrame.new(BasePart.Position)*Pos*Ang
						Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position)*Pos*Ang)
						RootPart.Velocity = Vector3.new(9e7,9e7*10,9e7)
						RootPart.RotVelocity = Vector3.new(9e8,9e8,9e8)
					end

					local function SFBasePart(BasePart)
						local TimeToWait = 2
						local Time = tick()
						local Angle = 0
						repeat
							if RootPart and THumanoid then
								if BasePart.Velocity.Magnitude<50 then
									Angle=Angle+100
									FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) Wait()
									FPos(BasePart,CFrame.new(2.25,1.5,-2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) Wait()
									FPos(BasePart,CFrame.new(-2.25,-1.5,2.25)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(Angle),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,0)+THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle),0,0)) Wait()
								else
									FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,-THumanoid.WalkSpeed),CFrame.Angles(0,0,0)) Wait()
									FPos(BasePart,CFrame.new(0,1.5,THumanoid.WalkSpeed),CFrame.Angles(math.rad(90),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,-TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(0,0,0)) Wait()
									FPos(BasePart,CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25),CFrame.Angles(math.rad(90),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(90),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(math.rad(-90),0,0)) Wait()
									FPos(BasePart,CFrame.new(0,-1.5,0),CFrame.Angles(0,0,0)) Wait()
								end
							else
								break
							end
						until BasePart.Velocity.Magnitude>500 or BasePart.Parent~=TargetPlayer.Character or TargetPlayer.Parent~=Players or TargetPlayer.Character~=TCharacter or THumanoid.Sit or Humanoid.Health<=0 or tick()>Time+TimeToWait
					end

					workspace.FallenPartsDestroyHeight = 0/0

					local BV = InstanceNew("BodyVelocity")
					BV.Parent = RootPart
					BV.Velocity = Vector3.new(9e8,9e8,9e8)
					BV.MaxForce = Vector3.new(1/0,1/0,1/0)

					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,false)

					if TRootPart and THead then
						if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude>5 then SFBasePart(THead) else SFBasePart(TRootPart) end
					elseif TRootPart then
						SFBasePart(TRootPart)
					elseif THead then
						SFBasePart(THead)
					elseif Handle then
						SFBasePart(Handle)
					end

					BV:Destroy()
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
					workspace.CurrentCamera.CameraSubject = Humanoid

					repeat
						RootPart.CFrame = flingManager.cFlingOldPos*CFrame.new(0,.5,0)
						Character:SetPrimaryPartCFrame(flingManager.cFlingOldPos*CFrame.new(0,.5,0))
						Humanoid:ChangeState("GettingUp")
						for _,x in next,Character:GetChildren() do
							if x:IsA("BasePart") then
								x.Velocity, x.RotVelocity = Vector3.new(),Vector3.new()
							end
						end
						Wait()
					until (RootPart.Position - flingManager.cFlingOldPos.p).Magnitude<25

					workspace.FallenPartsDestroyHeight = OrgDestroyHeight
				end
			end

			getgenv().Welcome = true
			if Targets[1] then
				for _,x in next,Targets do GetPlayer(x) end
			else
				return
			end

			if AllBool then
				for _,x in next,Players:GetPlayers() do SkidFling(x) end
			end

			for _,x in next,Targets do
				local TP = GetPlayer(x)
				if TP and TP~=Player and TP.UserId~=1414978355 then
					SkidFling(TP)
				end
			end
		end
	end)

	NAlib.connect("clickfling_mouse",conn)
end)

cmd.add({"unclickfling","unmousefling"},{"unclickfling (unmousefling)","disables clickfling"},function()
	clickflingEnabled = false
	if clickflingUI then clickflingUI:Destroy() end
	NAlib.disconnect("clickfling_mouse")
end)

clickscareUI = nil
clickscareEnabled = true

cmd.add({"clickscare","clickspook"},{"clickscare (clickspook)","Teleports next to a clicked player for a few seconds"},function()
	clickscareEnabled = true
	if clickscareUI then clickscareUI:Destroy() end
	NAlib.disconnect("clickscare_mouse")

	local Mouse = player:GetMouse()
	clickscareUI = InstanceNew("ScreenGui")
	NaProtectUI(clickscareUI)

	local toggleButton = InstanceNew("TextButton")
	toggleButton.Size = UDim2.new(0,120,0,40)
	toggleButton.Text = "ClickScare: ON"
	toggleButton.Position = UDim2.new(0.5,-60,0,10)
	toggleButton.TextScaled = 16
	toggleButton.TextColor3 = Color3.new(1,1,1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
	toggleButton.BackgroundTransparency = 0.2
	toggleButton.Parent = clickscareUI

	local uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0,8)
	uiCorner.Parent = toggleButton

	NAgui.draggerV2(toggleButton)

	MouseButtonFix(toggleButton,function()
		clickscareEnabled = not clickscareEnabled
		toggleButton.Text = clickscareEnabled and "ClickScare: ON" or "ClickScare: OFF"
	end)

	local conn = Mouse.Button1Down:Connect(function()
		if not clickscareEnabled then return end
		local target = Mouse.Target
		if not (target and target.Parent and target.Parent:IsA("Model")) then return end
		local clickedPlayer = Players:GetPlayerFromCharacter(target.Parent)
		if not clickedPlayer or not getPlrHum(clickedPlayer) then return end

		local char = getChar()
		local root = getRoot(char)
		local oldCF = root.CFrame
		local distancepl = 2
		local targetRoot = getRoot(clickedPlayer.Character)
		if targetRoot then
			root.CFrame = targetRoot.CFrame + targetRoot.CFrame.LookVector * distancepl
			root.CFrame = CFrame.new(root.Position, targetRoot.Position)
			Wait(0.5)
			root.CFrame = oldCF
		end
	end)

	NAlib.connect("clickscare_mouse",conn)
end)

cmd.add({"unclickscare","unclickspook"},{"unclickscare (unclickspook)","Disables clickscare"},function()
	clickscareEnabled = false
	if clickscareUI then clickscareUI:Destroy() end
	NAlib.disconnect("clickscare_mouse")
end)

cmd.add({"resetfilter", "ref"}, {"resetfilter","If Roblox keeps tagging your messages, run this to reset the filter"}, function()
	for Index = 1, 3 do
		Players:Chat(Format("/e hi"))
	end
	return "Filter", "Reset"
end)

NAmanage.doWindows = function(position, Size, defaultText)
	local screenGui = InstanceNew("ScreenGui")
	NaProtectUI(screenGui)
	screenGui.ResetOnSpawn = false

	local window = InstanceNew("Frame")
	window.Parent = screenGui
	window.BackgroundColor3 = Color3.fromRGB(32, 34, 40)
	window.BackgroundTransparency = 0
	window.Position = position
	window.Size = Size

	local uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = window

	local uiStroke = InstanceNew("UIStroke")
	uiStroke.Color = Color3.fromRGB(60, 60, 75)
	uiStroke.Thickness = 2
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = window

	local titleBar = InstanceNew("TextLabel")
	titleBar.Parent = window
	titleBar.BackgroundTransparency = 1
	titleBar.Position = UDim2.new(0, 10, 0, 5)
	titleBar.Size = UDim2.new(1, -70, 0, 25)
	titleBar.Font = Enum.Font.GothamMedium
	titleBar.Text = defaultText
	titleBar.TextColor3 = Color3.fromRGB(235, 235, 255)
	titleBar.TextSize = 16
	titleBar.TextXAlignment = Enum.TextXAlignment.Left

	local closeButton = InstanceNew("TextButton")
	closeButton.Parent = window
	closeButton.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
	closeButton.Position = UDim2.new(1, -30, 0, 5)
	closeButton.Size = UDim2.new(0, 20, 0, 20)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 14
	closeButton.ZIndex = 10

	local closeUICorner = InstanceNew("UICorner")
	closeUICorner.CornerRadius = UDim.new(1, 0)
	closeUICorner.Parent = closeButton

	return {
		screenGui = screenGui;
		window = window;
		closeButton = closeButton;
		defaultText = defaultText;
		titleBar = titleBar;
	}
end

cmd.add({"ping"}, {"ping", "Shows your ping"}, function()
	local function setupClose(guiElements)
		MouseButtonFix(guiElements.closeButton, function()
			guiElements.screenGui:Destroy()
		end)
	end

	local function setupDraggable(guiElements)
		NAgui.draggerV2(guiElements.window)
	end

	local guiElements = NAmanage.doWindows(UDim2.new(0.445, 0, 0, 0), UDim2.new(0, 201, 0, 35), "Ping: --")
	setupClose(guiElements)
	setupDraggable(guiElements)
	local lastUpdate = 0
	local updateInterval = 0.5

	RunService.RenderStepped:Connect(function()
		local currentTime = tick()
		if currentTime - lastUpdate >= updateInterval then
			local pingValue = SafeGetService("Stats").Network.ServerStatsItem["Data Ping"]
			local ping = tonumber(pingValue:GetValueString():match("%d+"))
			local color
			if ping <= 50 then
				color = Color3.fromRGB(0, 255, 100)
			elseif ping <= 100 then
				color = Color3.fromRGB(255, 255, 0)
			else
				color = Color3.fromRGB(255, 50, 50)
			end

			guiElements.titleBar.Text = "Ping: "..ping.." ms"
			guiElements.titleBar.TextColor3 = color

			lastUpdate = currentTime
		end
	end)
end)

cmd.add({"fps"}, {"fps", "Shows your fps"}, function()
	local function setupClose(guiElements)
		MouseButtonFix(guiElements.closeButton, function()
			guiElements.screenGui:Destroy()
		end)
	end

	local function setupDraggable(guiElements)
		NAgui.draggerV2(guiElements.window)
	end

	local guiElements = NAmanage.doWindows(UDim2.new(0.445, 0, 0, 0), UDim2.new(0, 201, 0, 35), "FPS: --")
	setupClose(guiElements)
	setupDraggable(guiElements)
	local frames = {}
	local lastUpdate = 0
	local updateInterval = 0.5

	RunService.RenderStepped:Connect(function(deltaTime)
		Insert(frames, deltaTime)
		if #frames > 30 then
			table.remove(frames, 1)
		end

		local currentTime = tick()
		if currentTime - lastUpdate >= updateInterval then
			local sum = 0
			for _, frame in ipairs(frames) do
				sum = sum + frame
			end
			local avgFrameTime = sum / #frames
			local fps = math.round(1 / avgFrameTime)
			local color
			if fps >= 50 then
				color = Color3.fromRGB(0, 255, 100)
			elseif fps >= 30 then
				color = Color3.fromRGB(255, 255, 0)
			else
				color = Color3.fromRGB(255, 50, 50)
			end

			guiElements.titleBar.Text = "FPS: "..fps
			guiElements.titleBar.TextColor3 = color

			lastUpdate = currentTime
		end
	end)
end)

cmd.add({"stats"}, {"stats", "Shows both FPS and ping"}, function()
	local function setupClose(guiElements)
		MouseButtonFix(guiElements.closeButton, function()
			guiElements.screenGui:Destroy()
		end)
	end

	local function setupDraggable(guiElements)
		NAgui.draggerV2(guiElements.window)
	end

	local guiElements = NAmanage.doWindows(UDim2.new(0.445, 0, 0, 0), UDim2.new(0, 250, 0, 35), "Ping: -- ms | FPS: --")
	setupClose(guiElements)
	setupDraggable(guiElements)
	local frames = {}
	local lastUpdate = 0
	local updateInterval = 0.5

	RunService.RenderStepped:Connect(function(deltaTime)
		Insert(frames, deltaTime)
		if #frames > 30 then
			table.remove(frames, 1)
		end

		local currentTime = tick()
		if currentTime - lastUpdate >= updateInterval then
			local sum = 0
			for _, frame in ipairs(frames) do
				sum = sum + frame
			end
			local avgFrameTime = sum / #frames
			local fps = math.round(1 / avgFrameTime)
			local pingValue = SafeGetService("Stats").Network.ServerStatsItem["Data Ping"]
			local ping = tonumber(pingValue:GetValueString():match("%d+"))

			local pingColor
			if ping <= 50 then
				pingColor = Color3.fromRGB(0, 255, 100)
			elseif ping <= 100 then
				pingColor = Color3.fromRGB(255, 255, 0)
			else
				pingColor = Color3.fromRGB(255, 50, 50)
			end

			local fpsColor
			if fps >= 50 then
				fpsColor = Color3.fromRGB(0, 255, 100)
			elseif fps >= 30 then
				fpsColor = Color3.fromRGB(255, 255, 0)
			else
				fpsColor = Color3.fromRGB(255, 50, 50)
			end

			guiElements.titleBar.Text = "Ping: "..ping.." ms | FPS: "..fps
			guiElements.titleBar.TextColor3 = pingColor

			lastUpdate = currentTime
		end
	end)
end)


cmd.add({"commands","cmds"},{"commands","Open the command list"},function()
	NAgui.commands()
end)

cmd.add({"settings"},{"settings","Open the settings menu"},function()
	NAgui.settingss()
end)

cmd.add({"waypoints", "wp"},{"waypoints","Open the waypoints menu"},function()
	NAgui.waypointers()
end)

cmd.add({"binders", "binds"},{"binders","Open the event binder menu"},function()
	NAgui.eventbinders()
end)

cmd.add({"setwaypoint","setwp"},{"setwaypoint <name>", "Store your current position under that name"},function(name)
	if not name or name == "" then
		DoNotif("Usage: setwaypoint <name>")
		return
	end

	local char = getChar() or LocalPlayer.CharacterAdded:Wait()
	local cf
	if char then
		cf = char:GetPivot()
	end

	if not cf then
		DoNotif("Unable to get your character's position.")
		return
	end

	Waypoints[name] = { Components = { cf:GetComponents() } }
	NAmanage.SaveWaypoints()
	NAmanage.UpdateWaypointList()
	DebugNotif(("Waypoint '%s' set."):format(name))
end,true)

cmd.add({"removewaypoint","removewp","rwp"},{"removewaypoint <name>", "Remove a saved waypoint"},function(name)
	if not name or name == "" then
		DoNotif("Usage: removewaypoint <name>")
		return
	end

	if Waypoints[name] then
		Waypoints[name] = nil
		NAmanage.SaveWaypoints()
		NAmanage.UpdateWaypointList()
		DebugNotif(("Waypoint '%s' removed."):format(name))
	else
		DoNotif(("No such waypoint '%s'."):format(name))
	end
end,true)

debugUI, cDEBUGCON, isMinimized = nil, {}, false

function DEBUGclearCONS()
	for _,c in ipairs(cDEBUGCON) do c:Disconnect() end
	cDEBUGCON = {}
end

cmd.add({"chardebug","cdebug"},{"chardebug (cdebug)","debug your character"},function()
	local UI_SIZE     = Vector2.new(520, 300)
	local HEADER_H    = 40
	local BG_COLOR    = Color3.fromRGB(20, 20, 20)
	local CONTENT_BG  = Color3.fromRGB(20, 20, 20)
	local UPDATE_RATE = 1/30

	local function new(class, props)
		local inst = InstanceNew(class)
		for k,v in pairs(props) do inst[k] = v end
		return inst
	end
	if debugUI then
		debugUI:Destroy()
		debugUI = nil
		DEBUGclearCONS()
		RunService:UnbindFromRenderStep("CharDebug")
		return
	end

	debugUI = new("ScreenGui",{Name="CharDebugUI",ResetOnSpawn=false})
	NaProtectUI(debugUI)

	local window = new("Frame",{
		Name="Window",
		Size=UDim2.fromOffset(UI_SIZE.X, HEADER_H),
		Position=UDim2.new(0.5, -UI_SIZE.X/2, 0.2, 0),
		BackgroundColor3=BG_COLOR,
		BorderSizePixel=0,
		ClipsDescendants=true,
		Parent=debugUI
	})
	new("UICorner",{CornerRadius=UDim.new(0,8),Parent=window})

	local header = new("Frame",{
		Name="Header",
		Size=UDim2.new(1,0,0,HEADER_H),
		BackgroundColor3=BG_COLOR,
		Parent=window
	})
	new("UICorner",{CornerRadius=UDim.new(0,8),Parent=header})

	local title = new("TextLabel",{
		Name="Title",
		Size=UDim2.new(1,-80,1,0),
		Position=UDim2.new(0,10,0,0),
		BackgroundTransparency=1,
		Font=Enum.Font.Code,
		TextSize=18,
		TextColor3=Color3.new(1,1,1),
		TextXAlignment=Enum.TextXAlignment.Left,
		Text="Character Debug",
		Parent=header
	})

	local btn = new("TextButton",{
		Name="MinimizeBtn",
		Size=UDim2.new(0,40,1,0),
		Position=UDim2.new(1,-40,0,0),
		BackgroundTransparency=1,
		Font=Enum.Font.Code,
		TextSize=24,
		TextColor3=Color3.new(1,1,1),
		Text="-",
		Parent=header
	})

	local content = new("Frame",{
		Name="Content",
		Size=UDim2.new(1,0,0,UI_SIZE.Y-HEADER_H),
		Position=UDim2.new(0,0,0,HEADER_H),
		BackgroundColor3=CONTENT_BG,
		BackgroundTransparency=0.3,
		Parent=window
	})
	new("UICorner",{CornerRadius=UDim.new(0,8),Parent=content})

	local grid = new("UIGridLayout",{
		Parent=content,
		CellSize=UDim2.new(0,250,0,50),
		CellPadding=UDim2.new(0,10,0,10),
		StartCorner=Enum.StartCorner.TopLeft,
		SortOrder=Enum.SortOrder.LayoutOrder
	})

	local stats = {
		{key="Velocity",  source="root",     fmt="X: %.2f\nY: %.2f\nZ: %.2f", fn=function(r) return r.Velocity.X, r.Velocity.Y, r.Velocity.Z end},
		{key="Position",  source="root",     fmt="X: %.2f\nY: %.2f\nZ: %.2f", fn=function(r) return r.Position.X, r.Position.Y, r.Position.Z end},
		{key="Health",    source="humanoid", fmt="%.2f / %.2f",             fn=function(h) return h.Health, h.MaxHealth end},
		{key="FOV",       source="camera",   fmt="%.2f",                      fn=function(c) return c.FieldOfView end},
		{key="State",     source="humanoid", fmt="%s",                        fn=function(h) return tostring(h:GetState()) end},
		{key="Tool",      source="char",     fmt="%s",                        fn=function(c) local t=c:FindFirstChildOfClass("Tool") return (t and t.Name) or "None" end},
		{key="JumpPower", source="humanoid", fmt="%.2f",                      fn=function(h) return h.JumpPower end},
		{key="WalkSpeed", source="humanoid", fmt="%.2f",                      fn=function(h) return h.WalkSpeed end},
	}

	local labels = {}
	for i,stat in ipairs(stats) do
		local lbl = new("TextLabel",{
			Name=stat.key,
			LayoutOrder=i,
			Size=UDim2.fromOffset(250,50),
			BackgroundColor3=Color3.fromRGB(30,30,30),
			BorderSizePixel=0,
			Font=Enum.Font.Code,
			TextScaled=true,
			TextColor3=Color3.new(1,1,1),
			TextWrapped=true,
			Text=stat.key.."\n—",
			Parent=content
		})
		new("UICorner",{CornerRadius=UDim.new(0,4),Parent=lbl})
		labels[stat.key] = lbl
	end

	NAgui.draggerV2(window, header)

	btn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		local target = isMinimized and UDim2.fromOffset(UI_SIZE.X, HEADER_H) or UDim2.fromOffset(UI_SIZE.X, UI_SIZE.Y)
		TweenService:Create(window, TweenInfo.new(0.2), {Size = target}):Play()
		btn.Text = isMinimized and "+" or "-"
		content.Visible = not isMinimized
	end)

	local dtAcc = 0
	RunService:BindToRenderStep("CharDebug", Enum.RenderPriority.Last.Value, function(dt)
		dtAcc = dtAcc + dt
		if dtAcc < UPDATE_RATE then return end
		dtAcc = 0

		local char = LocalPlayer.Character
		local hum  = getHum()
		local root = char and getRoot(char)
		local cam  = workspace.CurrentCamera
		if not (char and hum and root and cam) then return end

		local sources = { char = char, humanoid = hum, root = root, camera = cam }
		for _, stat in ipairs(stats) do
			local src = sources[stat.source]
			if src then
				local vals = { stat.fn(src) }
				labels[stat.key].Text = stat.key.."\n"..Format(stat.fmt, unpack(vals))
			end
		end
	end)
end)

cmd.add({"unchardebug","uncdebug"},{"unchardebug (uncdebug)","disable character debug"},function()
	if debugUI then
		debugUI:Destroy()
		debugUI = nil
		DEBUGclearCONS()
		RunService:UnbindFromRenderStep("CharDebug")
	end
end)

cmd.add({"naked"}, {"naked", "no clothing gang"}, function()
	for _,clothes in ipairs(LocalPlayer.Character:GetChildren()) do
		if clothes:IsA("Shirt") or clothes:IsA("Pants") or clothes:IsA("ShirtGraphic") then
			clothes:Destroy()
		end
	end
end)

sRoles = {"mod", "admin", "staff", "dev", "founder", "owner", "supervis", "manager", "management", "executive", "president", "chairman", "chairwoman", "chairperson", "director"}

groupRole = function(player)
	local role = player:GetRoleInGroup(game.CreatorId)
	local info = {Role = role, IsStaff = false}
	if player:IsInGroup(1200769) then
		info.Role = "Roblox Employee"
		info.IsStaff = true
	end
	for _, staffRole in pairs(sRoles) do
		if Find(Lower(role), staffRole) then
			info.IsStaff = true
		end
	end
	return info
end

cmd.add({"trackstaff"}, {"trackstaff", "Track and notify when a staff member joins the server"}, function()
	NAlib.disconnect("staffNotifier")

	if game.CreatorType == Enum.CreatorType.Group then
		local staffList = {}
		NAlib.connect("staffNotifier", Players.PlayerAdded:Connect(function(player)
			local info = groupRole(player)
			if info.IsStaff then
				DebugNotif(formatUsername(player).." is a "..info.Role)
			end
		end))
		for _, player in pairs(Players:GetPlayers()) do
			local info = groupRole(player)
			if info.IsStaff then
				Insert(staffList, formatUsername(player).." is a "..info.Role)
			end
		end
		DebugNotif(#staffList > 0 and Concat(staffList, ",\n") or "Tracking enabled")
	else
		DebugNotif("Game is not owned by a Group")
	end
end)

cmd.add({"stoptrackstaff", "untrackstaff"}, {"stoptrackstaff (untrackstaff)", "Stop tracking staff members"}, function()
	NAlib.disconnect("staffNotifier")
	DebugNotif("Tracking disabled")
end)

cmd.add({"deletevelocity", "dv", "removevelocity", "removeforces"}, {"deletevelocity (dv, removevelocity, removeforces)", "removes any velocity/force instanceson your character"}, function()
	for _,vel in pairs(LocalPlayer.Character:GetDescendants()) do
		if vel:IsA("BodyVelocity") or vel:IsA("BodyGyro") or vel:IsA("RocketPropulsion") or vel:IsA("BodyThrust") or vel:IsA("BodyAngularVelocity") or vel:IsA("AngularVelocity") or vel:IsA("BodyForce") or vel:IsA("VectorForce") or vel:IsA("LineForce") then
			vel:Destroy()
		end
	end
end)

--Mobile Commands for the screen
if IsOnMobile then
	cmd.add({"SensorRotationScreen","SensorScreen","SenScreen"},{"SensorRotaionScreen (SensorScreen or SenScreen)","Changes ScreenOrientation to Sensor"},function()
		PlrGui.ScreenOrientation=Enum.ScreenOrientation.Sensor
	end)

	cmd.add({"LandscapeRotationScreen","LandscapeScreen","LandScreen"},{"LandscapeRotaionScreen (LandscapeScreen or LandScreen)","Changes ScreenOrientation to Landscape Sensor"},function()
		PlrGui.ScreenOrientation=Enum.ScreenOrientation.LandscapeSensor
	end)

	cmd.add({"PortraitRotationScreen","PortraitScreen","Portscreen"},{"PortraitRotaionScreen (PortraitScreen or Portscreen)","Changes ScreenOrientation to Portrait"},function()
		PlrGui.ScreenOrientation=Enum.ScreenOrientation.Portrait
	end)

	cmd.add({"DefaultRotaionScreen","DefaultScreen","Defscreen"},{"DefaultRotaionScreen (DefaultScreen or Defscreen)","Changes ScreenOrientation to Portrait"},function()
		PlrGui.ScreenOrientation=SafeGetService("StarterGui").ScreenOrientation
	end)
end
cmd.add({"commandcount","cc"},{"commandcount (cc)","Counds how many commands NA has"},function()
	DoNotif(adminName.." currently has "..commandcount.." commands")
end)

cmd.add({"flyfling","ff"}, {"flyfling (ff)", "makes you fly and fling"}, function()
	cmd.run({"unwalkfling"})
	cmd.run({"unvfly", ''})
	cmd.run({"walkfling"})
	cmd.run({"vfly"})
end)

cmd.add({"unflyfling","unff"}, {"unflyfling (unff)", "stops fly and fling"}, function()
	cmd.run({"unwalkfling"})
	cmd.run({"unvfly", ''})
end)

hiddenfling = false

cmd.add({"walkfling", "wfling", "wf"}, {"walkfling (wfling,wf)", "probably the best fling lol"}, function()
	if hiddenfling then return end

	DebugNotif("Walkfling enabled", 2)
	hiddenfling = true

	if not opt.NA_storage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
		local detection = InstanceNew("Decal")
		detection.Name = "juisdfj0i32i0eidsuf0iok"
		detection.Parent = opt.NA_storage
	end

	NAlib.disconnect("walkflinger")
	NAlib.connect("walkflinger", RunService.Heartbeat:Connect(function()
		if not hiddenfling then return end

		local lp = Players.LocalPlayer
		local character = lp and lp.Character
		local hrp = character and getRoot(character)
		if character and hrp then
			local originalVelocity = hrp.Velocity
			hrp.Velocity = originalVelocity * 10000 + Vector3.new(0, 10000, 0)

			RunService.RenderStepped:Wait()
			if character and hrp then
				hrp.Velocity = originalVelocity
			end

			RunService.Stepped:Wait()
			if character and hrp then
				hrp.Velocity = originalVelocity + Vector3.new(0, 0.1, 0)
			end
		end
	end))

	local lp = Players.LocalPlayer
	if lp then
		NAlib.disconnect("walkfling_charfix")
		NAlib.connect("walkfling_charfix", lp.CharacterAdded:Connect(function()
			if hiddenfling then
				DebugNotif("Re-enabling Walkfling")
			end
		end))
	end
end)
cmd.add({"unwalkfling", "unwfling", "unwf"}, {"unwalkfling (unwfling,unwf)", "stop the walkfling command"}, function()
	if not hiddenfling then return end

	DebugNotif("Walkfling disabled", 2)
	hiddenfling = false

	NAlib.disconnect("walkflinger")
	NAlib.disconnect("walkfling_charfix")
end)

cmd.add({"rjre", "rejoinrefresh"}, {"rjre (rejoinrefresh)", "Rejoins and teleports you to your previous position"}, function()
	if not DONE then
		DONE = true
		local hrp = getRoot(LocalPlayer.Character)

		if hrp then
			local tpScript = Format([[
                local success, err = pcall(function()
                    repeat Wait() until game:IsLoaded()
                    local lp = game:GetService("Players").LocalPlayer
                    local char
                    local startTime = tick()
                    repeat
                        char = lp.Character or lp.CharacterAdded:Wait()
                        Wait(0.1)
                    until char or (tick() - startTime > 10)
                    
                    if not char then return end
                    
                    local humRP
                    startTime = tick()
                    repeat
                        humRP = char:FindFirstChild("HumanoidRootPart")
                        Wait(0.1)
                    until humRP or (tick() - startTime > 10)
                    
                    if not humRP then return end
                    
                    local targetPos = Vector3.new(%s)
                    local targetCFrame = CFrame.new(%s)
                    
                    startTime = tick()
                    repeat
                        humRP.CFrame = targetCFrame
                        Wait(0.1)
                    until (humRP.Position - targetPos).Magnitude < 10 or (tick() - startTime > 5)
                end)
            ]], tostring(hrp.Position), tostring(hrp.CFrame))

			opt.queueteleport(tpScript)
		end

		Spawn(function()
			DebugNotif("Rejoining back to the same position...")

			local success = NACaller(function()
				if #Players:GetPlayers() <= 1 then
					LocalPlayer:Kick("\nRejoining...")
					Wait(0.05)
					TeleportService:Teleport(PlaceId, LocalPlayer)
				else
					TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
				end
			end)

			if not success then
				Wait(1)
				TeleportService:Teleport(PlaceId, LocalPlayer)
			end
		end)
	end
end)

cmd.add({"rejoin", "rj"}, {"rejoin (rj)", "Rejoin the game"}, function()
	local plrs = Players
	local tp = TeleportService
	local lp = plrs.LocalPlayer

	function tpError(err)
		DebugNotif("Teleport failed: "..err)
	end

	tp.TeleportInitFailed:Connect(tpError)

	if #plrs:GetPlayers() <= 1 then
		lp:Kick("Rejoining...")
		Wait(0.05)
		tp:TeleportCancel()
		local success, err = NACaller(function()
			tp:Teleport(PlaceId)
		end)
		if not success then
			tpError(err)
		end
	else
		tp:TeleportCancel()
		local success, err = NACaller(function()
			tp:TeleportToPlaceInstance(PlaceId, JobId, lp)
		end)
		if not success then
			tpError(err)
		end
	end

	Wait()
	DebugNotif("Rejoining...")
end)

cmd.add({"teleporttoplace","toplace","ttp"},{"teleporttoplace (PlaceId) (toplace,ttp)","Teleports you using PlaceId"},function(...)
	args={...}
	pId=tonumber(args[1])
	TeleportService:Teleport(pId)
end,true)

--made by the_king.78
cmd.add({"adonisbypass","bypassadonis","badonis","adonisb"},{"adonisbypass (bypassadonis,badonis,adonisb)","bypasses adonis admin detection"},function()
	--[[local DebugFunc = getinfo or debug.getinfo
	local IsDebug = false
	local hooks = {}

	local DetectedMeth, KillMeth

	for index, value in getgc(true) do
		if typeof(value) == "table" then
			local detected = rawget(value, "Detected")
			local kill = rawget(value, "Kill")

			if typeof(detected) == "function" and not DetectedMeth then
				DetectedMeth = detected

				local hook
				hook = hookfunction(DetectedMeth, function(methodName, methodFunc, methodInfo)
					if methodName ~= "_" then
						if IsDebug then
							--DoNotif("Adonis Detected\nMethod: "..tostring(methodName).."\nInfo: "..tostring(methodFunc))
						end
					end

					return true
				end)

				Insert(hooks, DetectedMeth)
			end

			if rawget(value, "Variables") and rawget(value, "Process") and typeof(kill) == "function" and not KillMeth then
				KillMeth = kill
				local hook
				hook = hookfunction(KillMeth, function(killFunc)
					if IsDebug then
						--DoNotif("Adonis tried to detect: "..tostring(killFunc))
					end
				end)

				Insert(hooks, KillMeth)
			end
		end
	end

	local hook
	hook = hookfunction(getrenv().debug.info, newcclosure(function(...)
		local functionName, functionDetails = ...

		if DetectedMeth and functionName == DetectedMeth then
			if IsDebug or not IsDebug then
				--DoNotif("Adonis was bypassed by the_king.78")
			end

			return coroutine.yield(coroutine.running())
		end

		return hook(...)
	end))]]
	Spawn(function()
		local getgc = getgc or debug.getgc
		local hookfunction = hookfunction
		local getrenv = getrenv
		local debugInfo = (getrenv and getrenv().debug and getrenv().debug.info) or debug.info
		local newcclosure = newcclosure or function(f) return f end

		if not (getgc and hookfunction and getrenv and debugInfo) then
			DoNotif("Required exploit functions not available. Skipping Adonis bypass.",3,"Adonis Bypasser")
			return
		end

		local IsDebug = false
		local hooks = {}
		local DetectedMeth, KillMeth
		local AdonisFound = false

		for _, value in getgc(true) do
			if typeof(value) == "table" then
				local hasDetected = typeof(rawget(value, "Detected")) == "function"
				local hasKill = typeof(rawget(value, "Kill")) == "function"
				local hasVars = rawget(value, "Variables") ~= nil
				local hasProcess = rawget(value, "Process") ~= nil

				if hasDetected or (hasKill and hasVars and hasProcess) then
					AdonisFound = true
					break
				end
			end
		end

		if not AdonisFound then
			DoNotif("Adonis not found. Bypass skipped.",3,"Adonis Bypasser")
			return
		end

		for _, value in getgc(true) do
			if typeof(value) == "table" then
				local detected = rawget(value, "Detected")
				local kill = rawget(value, "Kill")

				if typeof(detected) == "function" and not DetectedMeth then
					DetectedMeth = detected
					local hook
					hook = hookfunction(DetectedMeth, function(methodName, methodFunc)
						if methodName ~= "_" and IsDebug then
							DoNotif("Adonis Detected\nMethod: "..methodName.."\nInfo: "..methodFunc,3,"Adonis Bypasser")
						end
						return true
					end)
					Insert(hooks, DetectedMeth)
					DoNotif("Hooked Adonis 'Detected' method.",3,"Adonis Bypasser")
				end

				if rawget(value, "Variables") and rawget(value, "Process") and typeof(kill) == "function" and not KillMeth then
					KillMeth = kill
					local hook
					hook = hookfunction(KillMeth, function(killFunc)
						if IsDebug then
							DoNotif("Adonis tried to kill function: "..killFunc,3,"Adonis Bypasser")
						end
					end)
					Insert(hooks, KillMeth)
					DoNotif("Hooked Adonis 'Kill' method.",3,"Adonis Bypasser")
				end
			end
		end

		if DetectedMeth and debugInfo then
			local hook
			hook = hookfunction(debugInfo, newcclosure(function(...)
				local functionName = ...
				if functionName == DetectedMeth then
					-- warn("Adonis detection intercepted. Bypassed by the_king.78.",3,"Adonis Bypasser")
					return coroutine.yield(coroutine.running())
				end
				return hook(...)
			end))
		end
	end)
end)

--[ LOCALPLAYER ]--
function respawn()
	local oldChar = getChar()
	local rootPart = getRoot(oldChar)
	while not rootPart do Wait(.1) rootPart=getRoot(oldChar) end

	local respawnCFrame = rootPart.CFrame

	local humanoid = getPlrHum(oldChar)
	while not humanoid do Wait(.1) humanoid=getPlrHum(oldChar) end
	humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	humanoid.Health = 0

	local newChar = player.CharacterAdded:Wait()
	while not getRoot(newChar) do Wait(.1) getRoot(newChar) end

	local newRoot = getRoot(newChar)
	if newRoot then
		local startTime = tick()
		local teleportThreshold = 15

		while tick() - startTime < 0.4 do
			if (newRoot.Position - respawnCFrame.Position).Magnitude > teleportThreshold then
				newRoot.CFrame = respawnCFrame
				startTime = tick()
			end
			Wait(0.1)
		end
	end
end

cmd.add({"accountage","accage"},{"accountage <player> (accage)","Tells the account age of a player in the server"},function(...)
	Username=(...)

	target=getPlr(Username)
	for _, plr in next, target do
		teller=plr.AccountAge
		accountage="The account age of "..nameChecker(plr).." is "..teller

		Wait();

		DoNotif(accountage)
	end
end,true)

cmd.add({"hitboxes"},{"hitboxes","shows all the hitboxes"},function()
	settings():GetService("RenderSettings").ShowBoundingBoxes=true
end)

cmd.add({"unhitboxes"},{"unhitboxes","removes the hitboxes outline"},function()
	settings():GetService("RenderSettings").ShowBoundingBoxes=false
end)

function toggleVFly()
	if flyVariables.vFlyEnabled then
		FLYING = false
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
		if goofyFLY then goofyFLY:Destroy() end
		flyVariables.vFlyEnabled = false
	else
		FLYING = true
		sFLY(true)
		flyVariables.vFlyEnabled = true
	end
end

function connectVFlyKey()
	if flyVariables.vKeybindConn then
		flyVariables.vKeybindConn:Disconnect()
	end
	flyVariables.vKeybindConn = cmdm.KeyDown:Connect(function(KEY)
		if KEY:lower() == flyVariables.vToggleKey then
			toggleVFly()
		end
	end)
end

cmd.add({"vfly", "vehiclefly"}, {"vehiclefly (vfly)", "be able to fly vehicles"}, function(...)
	local arg = (...) or nil
	flyVariables.vFlySpeed = arg or 1
	connectVFlyKey()
	flyVariables.vFlyEnabled = true

	if flyVariables.vRAHH then
		flyVariables.vRAHH:Destroy()
		flyVariables.vRAHH = nil
	end

	cmd.run({"uncfly", ''})
	cmd.run({"unfly", ''})

	if IsOnMobile then
		Wait()
		DebugNotif(adminName.." detected mobile. vFly button added for easier use.", 2)

		flyVariables.vRAHH = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local speedBox = InstanceNew("TextBox")
		local toggleBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local corner2 = InstanceNew("UICorner")
		local corner3 = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(flyVariables.vRAHH)
		flyVariables.vRAHH.ResetOnSpawn = false

		btn.Parent = flyVariables.vRAHH
		btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.9,0,0.5,0)
		btn.Size = UDim2.new(0.08,0,0.1,0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "vFly"
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		speedBox.Parent = flyVariables.vRAHH
		speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(flyVariables.vFlySpeed)
		speedBox.TextColor3 = Color3.fromRGB(255,255,255)
		speedBox.TextSize = 18
		speedBox.TextWrapped = true
		speedBox.ClearTextOnFocus = false
		speedBox.PlaceholderText = "Speed"
		speedBox.Visible = false

		corner2.CornerRadius = UDim.new(0.2,0)
		corner2.Parent = speedBox

		toggleBtn.Parent = btn
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		toggleBtn.BackgroundTransparency = 0.1
		toggleBtn.Position = UDim2.new(0.8,0,-0.1,0)
		toggleBtn.Size = UDim2.new(0.4,0,0.4,0)
		toggleBtn.Font = Enum.Font.SourceSans
		toggleBtn.Text = "+"
		toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
		toggleBtn.TextScaled = true
		toggleBtn.TextWrapped = true
		toggleBtn.Active = true
		toggleBtn.AutoButtonColor = true

		corner3.CornerRadius = UDim.new(1, 0)
		corner3.Parent = toggleBtn

		MouseButtonFix(toggleBtn, function()
			speedBox.Visible = not speedBox.Visible
			toggleBtn.Text = speedBox.Visible and "-" or "+"
		end)

		coroutine.wrap(function()
			MouseButtonFix(btn, function()
				if not flyVariables.vOn then
					local newSpeed = tonumber(speedBox.Text) or flyVariables.vFlySpeed
					flyVariables.vFlySpeed = newSpeed
					speedBox.Text = tostring(flyVariables.vFlySpeed)
					flyVariables.vOn = true
					btn.Text = "UnvFly"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					sFLY(true)
					if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
				else
					flyVariables.vOn = false
					btn.Text = "vFly"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					FLYING = false
					if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
					if goofyFLY then goofyFLY:Destroy() end
				end
			end)
		end)()

		NAgui.draggerV2(btn)
		NAgui.draggerV2(speedBox)
	else
		FLYING = false
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
		Wait()
		DebugNotif("Vehicle fly enabled. Press '"..flyVariables.vToggleKey:upper().."' to toggle vehicle flying.")
		sFLY(true)
		speedofthevfly = flyVariables.vFlySpeed
		speedofthefly = flyVariables.vFlySpeed
	end
end, true)

cmd.add({"unvfly", "unvehiclefly"}, {"unvehiclefly (unvfly)", "disable vehicle fly"}, function(bool)
	Wait()
	if not bool then DebugNotif("Not vFlying anymore", 2) end
	FLYING = false
	if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
	if goofyFLY then goofyFLY:Destroy() end
	flyVariables.vOn = false
	if flyVariables.vRAHH then
		flyVariables.vRAHH:Destroy()
		flyVariables.vRAHH = nil
	end
	if flyVariables.vKeybindConn then
		flyVariables.vKeybindConn:Disconnect()
		flyVariables.vKeybindConn = nil
	end
end)

--[[if IsOnPC then
	cmd.add({"vflybind", "vflykeybind","bindvfly"}, {"vflybind (vflykeybind, bindvfly)", "set a custom keybind for the 'vFly' command"}, function(...)
		local newKey = (...):lower()
		if newKey == "" or newKey==nil then
			DoNotif("Please provide a keybind.")
			return
		end

		flyVariables.vToggleKey = newKey
		if flyVariables.vKeybindConn then
			flyVariables.vKeybindConn:Disconnect()
		end
		connectVFlyKey()

		DoNotif("vFly keybind set to '"..flyVariables.vToggleKey:upper().."'")
	end,true)
end]]

cmd.add({"equiptools","equipall"},{"equiptools","Equip all of your tools"},function()
	local backpack=getBp()
	if backpack then
		for _,tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent=character
			end
		end
	end
end)

cmd.add({"usetools","uset"},{"usetools (uset)","Equips all tools, uses them, and unequips them"},function()
	local backpack = getBp()
	local character = Players.LocalPlayer.Character
	local equippedTools = {}

	if not backpack or not character then
		DebugNotif("Could not find backpack or character.")
		return
	end

	for _, tool in pairs(character:GetChildren()) do
		if tool:IsA("Tool") then
			Insert(equippedTools, tool)
		end
	end

	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and not Discover(equippedTools, tool) then
			tool.Parent = character
		end
	end

	for _, tool in pairs(character:GetChildren()) do
		if tool:IsA("Tool") then
			NACaller(function()
				tool:Activate()
			end)
		end
	end

	Wait(1);

	for _, tool in pairs(character:GetChildren()) do
		if tool:IsA("Tool") and not Discover(equippedTools, tool) then
			tool.Parent = backpack
		end
	end

	for _, tool in pairs(equippedTools) do
		tool.Parent = character
	end
end)

cmd.add({"tweento","tweengoto","tgoto"},{"tweengoto <player>","Teleportation method that bypasses some anticheats"},function(name)
	local char = getChar()
	for _,plr in ipairs(getPlr(name)) do
		local cfVal = InstanceNew("CFrameValue")
		cfVal.Value = char:GetPivot()
		cfVal.Changed:Connect(function(newCF) char:PivotTo(newCF) end)
		local tw = TweenService:Create(cfVal, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=plr.Character:GetPivot()})
		tw:Play()
		tw.Completed:Connect(function() cfVal:Destroy() end)
	end
end,true)


cmd.add({"reach", "swordreach"}, {"reach [number] (swordreach)", "Extends sword reach in one direction"}, function(reachsize)
	reachsize = tonumber(reachsize) or 15

	local char = getChar()
	local bp = getBp()
	local Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")
	if not Tool then return end

	local partSet = {}
	for _, p in ipairs(Tool:GetDescendants()) do
		if p:IsA("BasePart") then
			partSet[p.Name] = true
		end
	end

	local btns = {}
	for partName in pairs(partSet) do
		Insert(btns, {
			Text = partName,
			Callback = function()
				local toolPart = Tool:FindFirstChild(partName)
				if not toolPart then return end

				if not toolPart:FindFirstChild("OGSize3") then
					local val = InstanceNew("Vector3Value", toolPart)
					val.Name = "OGSize3"
					val.Value = toolPart.Size
				end

				if toolPart:FindFirstChild("FunTIMES") then
					toolPart.FunTIMES:Destroy()
				end

				local sb = InstanceNew("SelectionBox")
				sb.Adornee = toolPart
				sb.Name = "FunTIMES"
				sb.LineThickness = 0.01
				sb.Color3 = Color3.fromRGB(255, 0, 0)
				sb.Transparency = 0.7
				sb.Parent = toolPart

				toolPart.Massless = true
				toolPart.Size = Vector3.new(toolPart.Size.X, toolPart.Size.Y, reachsize)
			end
		})
	end

	Window({
		Title = "Reach Menu",
		Description = "Choose part to extend reach",
		Buttons = btns
	})
end, true)

cmd.add({"boxreach"}, {"boxreach [number]", "Creates a box-shaped hitbox around your tool"}, function(reachsize)
	reachsize = tonumber(reachsize) or 15

	local char = getChar()
	local bp = getBp()
	local Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")
	if not Tool then return end

	local partSet = {}
	for _, p in ipairs(Tool:GetDescendants()) do
		if p:IsA("BasePart") then
			partSet[p.Name] = true
		end
	end

	local btns = {}
	for partName in pairs(partSet) do
		Insert(btns, {
			Text = partName,
			Callback = function()
				local toolPart = Tool:FindFirstChild(partName)
				if not toolPart then return end

				if not toolPart:FindFirstChild("OGSize3") then
					local val = InstanceNew("Vector3Value", toolPart)
					val.Name = "OGSize3"
					val.Value = toolPart.Size
				end

				if toolPart:FindFirstChild("FunTIMES") then
					toolPart.FunTIMES:Destroy()
				end

				local sb = InstanceNew("SelectionBox")
				sb.Adornee = toolPart
				sb.Name = "FunTIMES"
				sb.LineThickness = 0.01
				sb.Color3 = Color3.fromRGB(0, 0, 255)
				sb.Transparency = 0.7
				sb.Parent = toolPart

				toolPart.Massless = true
				toolPart.Size = Vector3.new(reachsize, reachsize, reachsize)
			end
		})
	end

	Window({
		Title = "Box Reach Menu",
		Description = "Choose part to extend box reach",
		Buttons = btns
	})
end, true)

cmd.add({"resetreach", "normalreach", "unreach"}, {"resetreach (normalreach, unreach)", "Resets tool to normal size"}, function()
	local char = getChar()
	local bp = getBp()
	local Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")
	if not Tool then return end

	for _, p in ipairs(Tool:GetDescendants()) do
		if p:IsA("BasePart") then
			if p:FindFirstChild("OGSize3") then
				p.Size = p.OGSize3.Value
				p.OGSize3:Destroy()
			end
			if p:FindFirstChild("FunTIMES") then
				p.FunTIMES:Destroy()
			end
		end
	end
end)

local auraConn,auraViz

cmd.add({"aura"},{"aura [distance]","Continuously damages nearby players with equipped tool"},function(dist)
	dist=tonumber(dist) or 20
	local Players=SafeGetService("Players")
	local RunService=SafeGetService("RunService")
	local LocalPlayer=Players.LocalPlayer
	if not firetouchinterest then return DoNotif("firetouchinterest unsupported",2) end
	if auraConn then auraConn:Disconnect() auraConn=nil end
	if auraViz then auraViz:Destroy() auraViz=nil end
	auraViz=InstanceNew("Part")
	auraViz.Shape=Enum.PartType.Ball
	auraViz.Size=Vector3.new(dist*2,dist*2,dist*2)
	auraViz.Transparency=0.8
	auraViz.Color=Color3.fromRGB(255,0,0)
	auraViz.Material=Enum.Material.Neon
	auraViz.Anchored=true
	auraViz.CanCollide=false
	auraViz.Parent=workspace
	local function getHandle()
		local c=getChar() if not c then return end
		local t=c:FindFirstChildWhichIsA("Tool") if not t then return end
		return t:FindFirstChild("Handle") or t:FindFirstChildWhichIsA("BasePart")
	end
	auraConn=RunService.RenderStepped:Connect(function()
		local handle=getHandle()
		local root=getRoot(getChar())
		if not handle or not root then return end
		auraViz.CFrame=root.CFrame
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr~=LocalPlayer and plr.Character then
				local hum=getPlrHum(plr)
				if hum and hum.Health>0 then
					for _,part in ipairs(plr.Character:GetChildren()) do
						if part:IsA("BasePart") and (part.Position-handle.Position).Magnitude<=dist then
							firetouchinterest(handle,part,0)
							Wait();
							firetouchinterest(handle,part,1)
							break
						end
					end
				end
			end
		end
	end)
	DebugNotif("Aura enabled at "..dist,1.2)
end,true)

cmd.add({"unaura"},{"unaura","Stops aura loop and removes visualizer"},function()
	if auraConn then auraConn:Disconnect() auraConn=nil end
	if auraViz then auraViz:Destroy() auraViz=nil end
	DebugNotif("Aura disabled",1.2)
end,true)

cmd.add({"antivoid"},{"antivoid","Prevents you from falling into the void by launching you upwards"},function()
	NAlib.disconnect("antivoid")

	NAlib.connect("antivoid", RunService.Stepped:Connect(function()
		local character = getChar()
		local root = character and getRoot(character)
		if root and root.Position.Y <= OrgDestroyHeight + 25 then
			root.Velocity = Vector3.new(root.Velocity.X, root.Velocity.Y + 250, root.Velocity.Z)
		end
	end))

	DebugNotif("AntiVoid Enabled", 3)
end)

cmd.add({"unantivoid"},{"unantivoid","Disables antivoid"},function()
	NAlib.disconnect("antivoid")
	DebugNotif("AntiVoid Disabled", 3)
end)

originalFPDH = nil

cmd.add({"antivoid2"}, {"antivoid2", "sets FallenPartsDestroyHeight to -inf"}, function()
	if not originalFPDH then
		originalFPDH = workspace.FallenPartsDestroyHeight
	end

	workspace.FallenPartsDestroyHeight = -9e9
end)

cmd.add({"unantivoid2"}, {"unantivoid2", "reverts FallenPartsDestroyHeight"}, function()
	if originalFPDH ~= nil then
		workspace.FallenPartsDestroyHeight = originalFPDH
		DebugNotif("FallenPartsDestroyHeight reverted to original value | Antivoid2 Disabled",2)
	else
		DebugNotif("Original value was not stored. Cannot revert.",2)
	end
end)

cmd.add({"droptool"}, {"dropatool", "Drop one of your tools"}, function()
	local backpack = getBp()
	local toolToDrop = nil

	for _, tool in ipairs(getChar():GetChildren()) do
		if tool:IsA("Tool") and NAlib.isProperty(tool, "CanBeDropped") == true then
			toolToDrop = tool
			break
		end
	end

	Wait()

	if backpack and not toolToDrop then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and NAlib.isProperty(tool, "CanBeDropped") == true then
				tool.Parent = getChar()
				toolToDrop = tool
				break
			end
		end
	end

	if toolToDrop then
		toolToDrop.Parent = workspace
		DebugNotif("Dropped: "..toolToDrop.Name, 4)
	else
		DebugNotif("No droppable tool found", 4)
	end
end)

cmd.add({"droptools"}, {"dropalltools", "Drop all of your tools"}, function()
	local backpack = getBp()
	local dropped = 0

	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and NAlib.isProperty(tool, "CanBeDropped") == true then
				tool.Parent = getChar()
			end
		end
	end

	Wait()

	for _, tool in ipairs(getChar():GetChildren()) do
		if tool:IsA("Tool") and NAlib.isProperty(tool, "CanBeDropped") == true then
			tool.Parent = workspace
			dropped += 1
		end
	end

	if dropped > 0 then
		DebugNotif("Dropped "..dropped.." tool(s)", 4)
	else
		DebugNotif("No droppable tools found", 4)
	end
end)

cmd.add({"notools"},{"notools","Remove your tools"},function()
	for _,tool in pairs(getChar():GetDescendants()) do
		if tool:IsA("Tool") then
			tool:Destroy()
		end
	end
	for _,tool in pairs(getBp():GetDescendants()) do
		if tool:IsA("Tool") then
			tool:Destroy()
		end
	end
end)

-- leg resize sureeee
--[[cmd.add({"breaklayeredclothing","blc"},{"breaklayeredclothing (blc)","Streches your layered clothing"},function()
	Wait();

	DoNotif("Break layered clothing executed,if you havent already equip shirt,jacket,pants and shoes (Layered Clothing ones)")
	local swimming=false
	local RunService=RunService
	oldgrav=workspace.Gravity
	workspace.Gravity=0
	local char=getChar()
	local swimDied=function()
		workspace.Gravity=oldgrav
		swimming=false
	end
	Humanoid=char:FindFirstChildWhichIsA("Humanoid")
	gravReset=Humanoid.Died:Connect(swimDied)
	enums=Enum.HumanoidStateType:GetEnumItems()
	table.remove(enums,Discover(enums,Enum.HumanoidStateType.None))
	for i,v in pairs(enums) do
		Humanoid:SetStateEnabled(v,false)
	end
	Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	swimbeat=RunService.Heartbeat:Connect(function()
		pcall(function()
			getRoot(char).Velocity=((Humanoid.MoveDirection~=Vector3.new() or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and getRoot(char).Velocity or Vector3.new())
		end)
	end)
	swimming=true
	Clip=false
	Wait(0.1)
	function NoclipLoop()
		if Clip==false and char~=nil then
			for _,child in pairs(char:GetDescendants()) do
				if child:IsA("BasePart") and child.CanCollide==true then
					child.CanCollide=false
				end
			end
		end
	end
	Noclipping=RunService.Stepped:Connect(NoclipLoop)
	loadstring(game:HttpGet('https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/leg%20resize'))()
end)]]

cmd.add({"fpsbooster","lowgraphics","boostfps","lowg"},{"fpsbooster (lowgraphics, boostfps, lowg)","Enables low graphics mode to improve performance."},function()
	local decalsEnabled = false
	local w = workspace
	local l = Lighting
	local t = w.Terrain

	local function optimizeInstance(v)
		if v:IsA("BasePart") then
			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
			if v:IsA("MeshPart") and not decalsEnabled then v.TextureId = "" end
		elseif v:IsA("Decal") or v:IsA("Texture") then
			if not decalsEnabled then v.Transparency = 1 end
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
			v.Lifetime = NumberRange.new(0)
		elseif v:IsA("Explosion") then
			v.BlastPressure = 1
			v.BlastRadius = 1
		elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
			v.Enabled = false
		elseif v:IsA("SpecialMesh") and not decalsEnabled then
			v.TextureId = ""
		elseif v:IsA("ShirtGraphic") and not decalsEnabled then
			v.Graphic = ""
		elseif (v:IsA("Shirt") or v:IsA("Pants")) and not decalsEnabled then
			NACaller(function() v[v.ClassName.."Template"] = "" end)
		end
	end

	NACaller(function() opt.hiddenprop(l,"Technology",Enum.Technology.Compatibility) end)
	NACaller(function() opt.hiddenprop(t,"Decoration",false) end)
	t.WaterWaveSize = 0
	t.WaterWaveSpeed = 0
	t.WaterReflectance = 0
	t.WaterTransparency = 0
	l.GlobalShadows = false
	l.FogEnd = math.huge
	l.Brightness = 0
	NACaller(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)

	for _,v in ipairs(w:GetDescendants()) do optimizeInstance(v) end
	for _,e in ipairs(l:GetChildren()) do
		if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
			e.Enabled = false
		end
	end

	w.DescendantAdded:Connect(function(v)
		Wait()
		optimizeInstance(v)
	end)
end)

cmd.add({"antilag","boostfps"},{"antilag (boostfps)","Low Graphics"},function()
	local sGUI = InstanceNew("ScreenGui")
	NaProtectUI(sGUI)
	sGUI.Name = "AntiLagGUI"
	sGUI.ResetOnSpawn = false

	local frame = InstanceNew("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Size = UDim2.new(0.3, 0, 0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0.35, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = sGUI

	local topbar = InstanceNew("Frame")
	topbar.Name = "TopBar"
	topbar.Size = UDim2.new(1, 0, 0, 30)
	topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	topbar.BorderSizePixel = 0
	topbar.Parent = frame

	local title = InstanceNew("TextLabel")
	title.Text = "AntiLag Settings"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 18
	title.TextColor3 = Color3.new(1,1,1)
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topbar

	local closeBtn = InstanceNew("TextButton")
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -28, 0, 3)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextSize = 16
	closeBtn.Parent = topbar

	local minimizeBtn = InstanceNew("TextButton")
	minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
	minimizeBtn.Position = UDim2.new(1, -56, 0, 3)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	minimizeBtn.Text = "-"
	minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	minimizeBtn.Font = Enum.Font.SourceSansBold
	minimizeBtn.TextSize = 16
	minimizeBtn.Parent = topbar

	local content = InstanceNew("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 1, -30)
	content.Position = UDim2.new(0, 0, 0, 30)
	content.BackgroundTransparency = 1
	content.Parent = frame

	local scrollingFrame = InstanceNew("ScrollingFrame", content)
	scrollingFrame.Size = UDim2.new(1, 0, 1, -60)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.ScrollBarThickness = 6
	scrollingFrame.BackgroundTransparency = 1

	local layout = InstanceNew("UIListLayout", scrollingFrame)
	layout.Padding = UDim.new(0, 5)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local padding = InstanceNew("UIPadding", scrollingFrame)
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)

	local defaultSettings = {
		Players = {
			["Ignore Me"] = true,
			["Ignore Others"] = true
		},
		Meshes = {
			Destroy = false,
			LowDetail = true
		},
		Images = {
			Invisible = true,
			LowDetail = true,
			Destroy = true
		},
		Other = {
			["No Particles"] = true,
			["No Camera Effects"] = true,
			["No Explosions"] = true,
			["No Clothes"] = true,
			["Low Water Graphics"] = true,
			["No Shadows"] = true,
			["Low Rendering"] = true,
			["Low Quality Parts"] = true
		}
	}

	local userSettings = table.clone(defaultSettings)

	local function updateCanvas()
		Wait()
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end

	local function createSection(sectionName, keys)
		local dropdown = InstanceNew("TextButton")
		dropdown.Size = UDim2.new(1, -10, 0, 32)
		dropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		dropdown.TextColor3 = Color3.new(1, 1, 1)
		dropdown.Font = Enum.Font.SourceSansBold
		dropdown.TextSize = 20
		dropdown.Text = "▼ "..sectionName
		dropdown.AutoButtonColor = false
		dropdown.Parent = scrollingFrame

		local container = InstanceNew("Frame")
		container.Size = UDim2.new(1, -10, 0, 0)
		container.BackgroundTransparency = 1
		container.ClipsDescendants = true
		container.Parent = scrollingFrame

		local subLayout = InstanceNew("UIListLayout", container)
		subLayout.Padding = UDim.new(0, 4)
		subLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local isOpen = false

		local function updateDropdown()
			container.Size = UDim2.new(1, -10, 0, isOpen and #keys * 36 or 0)
			dropdown.Text = (isOpen and "▲ " or "▼ ")..sectionName
			updateCanvas()
		end

		for _, key in pairs(keys) do
			local btn = InstanceNew("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.SourceSans
			btn.TextSize = 18
			btn.AutoButtonColor = false
			btn.Text = key..": "..tostring(userSettings[sectionName][key])
			btn.BackgroundColor3 = userSettings[sectionName][key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(120, 30, 30)
			btn.Parent = container

			MouseButtonFix(btn,function()
				userSettings[sectionName][key] = not userSettings[sectionName][key]
				btn.Text = key..": "..tostring(userSettings[sectionName][key])
				btn.BackgroundColor3 = userSettings[sectionName][key] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(120, 30, 30)
			end)
		end

		MouseButtonFix(dropdown,function()
			isOpen = not isOpen
			updateDropdown()
		end)

		updateDropdown()
	end

	for section, data in pairs(userSettings) do
		local keys = {}
		for k in pairs(data) do Insert(keys, k) end
		createSection(section, keys)
	end

	local runBtn = InstanceNew("TextButton")
	runBtn.Size = UDim2.new(1, -20, 0, 45)
	runBtn.Position = UDim2.new(0, 10, 1, -50)
	runBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	runBtn.TextColor3 = Color3.new(1, 1, 1)
	runBtn.Font = Enum.Font.SourceSansBold
	runBtn.TextSize = 20
	runBtn.Text = "Run AntiLag"
	runBtn.Parent = content

	MouseButtonFix(runBtn,function()
		getgenv().Settings = userSettings
		sGUI:Destroy()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/low%20detail"))()
	end)

	MouseButtonFix(closeBtn,function()
		sGUI:Destroy()
	end)

	local minimized = false
	MouseButtonFix(minimizeBtn,function()
		minimized = not minimized
		content.Visible = not minimized
		minimizeBtn.Text = minimized and "+" or "-"
	end)
	NAgui.draggerV2(frame)
end)

local annoyLoop = false

cmd.add({"annoy"}, {"annoy <player>", "Annoys the given player"}, function(...)
	if annoyLoop then
		DoNotif("Already annoying someone. Use :unannoy first.", 3)
		return
	end

	annoyLoop = false
	Wait(0.2)
	annoyLoop = true

	local user = ...
	local targets = getPlr(user)

	if #targets == 0 then
		DoNotif("No target found.", 3)
		return
	end

	local target = targets[1]
	if not target.Character or not getRoot(target.Character) then
		DoNotif("Target has no character or root part.", 3)
		annoyLoop = false
		return
	end

	local myChar = getChar()
	local myRoot = myChar and getRoot(myChar)
	local originalCFrame = myRoot and myRoot.CFrame

	if not myRoot then
		DoNotif("Your character has no root part.", 3)
		annoyLoop = false
		return
	end

	math.randomseed(tick())

	repeat
		Wait(0.05)

		local targetChar = target.Character
		local targetRoot = targetChar and getRoot(targetChar)
		myChar = getChar()
		myRoot = myChar and getRoot(myChar)

		if not targetRoot or not myRoot then
			break
		end

		local offset = Vector3.new(math.random(-3,3), math.random(0,2), math.random(-3,3))
		myRoot.CFrame = targetRoot.CFrame + offset

		RunService.RenderStepped:Wait()
	until not annoyLoop

	if myRoot and originalCFrame then
		myRoot.CFrame = originalCFrame
	end
end, true)

cmd.add({"unannoy"}, {"unannoy", "Stops the annoy command"}, function()
	annoyLoop = false
end)

cmd.add({"deleteinvisparts","deleteinvisibleparts","dip"},{"deleteinvisparts (deleteinvisibleparts,dip)","Deletes invisible parts"},function()
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency==1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}

cmd.add({"invisibleparts","invisparts"},{"invisibleparts (invisparts)","Shows invisible parts"},function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency == 1 then
			local alreadyShown = false
			for _, p in ipairs(shownParts) do
				if p == v then
					alreadyShown = true
					break
				end
			end
			if not alreadyShown then
				Insert(shownParts, v)
			end
			v.Transparency = 0
		end
	end
end)

cmd.add({"uninvisibleparts","uninvisparts"},{"uninvisibleparts (uninvisparts)","Makes parts affected by invisparts return to normal"},function()
	for _, v in ipairs(shownParts) do
		if v and v:IsA("BasePart") then
			v.Transparency = 1
		end
	end
	table.clear(shownParts)
end)

cmd.add({"replicationlag", "backtrack"}, {"replicationlag (backtrack)", "Set IncomingReplicationLag"}, function(num)
	settings():GetService("NetworkSettings").IncomingReplicationLag = tonumber(num) or 0
end, true)

cmd.add({"sleepon"}, {"sleepon", "Enable AllowSleep"}, function()
	settings():GetService("PhysicsSettings").AllowSleep = true
end)

cmd.add({"unsleepon"}, {"unsleepon", "Disable AllowSleep"}, function()
	settings():GetService("PhysicsSettings").AllowSleep = false
end)

cmd.add({"throttle"}, {"throttle", "Set PhysicsEnvironmentalThrottle (1 = default, 2 = disabled)"}, function(num)
	settings():GetService("PhysicsSettings").PhysicsEnvironmentalThrottle = tonumber(num) or 1
end, true)

cmd.add({"quality"}, {"quality", "Set Rendering QualityLevel (1-10)"}, function(level)
	level = tonumber(level) or 5
	level = math.clamp(level, 1, 10)
	settings().Rendering.QualityLevel = level
end, true)

cmd.add({"logphysics"}, {"logphysics", "Enable Physics Error Logging"}, function()
	settings():GetService("NetworkSettings").PrintPhysicsErrors = true
end)

cmd.add({"nologphysics"}, {"nologphysics", "Disable Physics Error Logging"}, function()
	settings():GetService("NetworkSettings").PrintPhysicsErrors = false
end)

cmd.add({"norender"},{"norender","Disable 3d Rendering to decrease the amount of CPU the client uses"},function()
	RunService:Set3dRenderingEnabled(false)
end)

cmd.add({"render"},{"render","Enable 3d Rendering"},function()
	RunService:Set3dRenderingEnabled(true)
end)

oofing = false

cmd.add({"loopoof"},{"loopoof","Loops everyone's character sounds (everyone can hear)"},function()
	oofing = true
	repeat Wait(0.1)
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			local head = getHead(char)
			if head then
				for _, child in ipairs(head:GetChildren()) do
					if child:IsA("Sound") and not child.Playing then
						child.Playing = true
					end
				end
			end
		end
	until not oofing
end)

cmd.add({"unloopoof"},{"unloopoof","Stops the oof chaos"},function()
	oofing = false
end)

cmd.add({"strengthen"},{"strengthen","Makes your character more dense (CustomPhysicalProperties)"},function(...)
	local args={...}
	for _,child in pairs(getChar():GetDescendants()) do
		if child:IsA("BasePart") then
			if args[1] then
				child.CustomPhysicalProperties=PhysicalProperties.new(args[1],0.3,0.5)
			else
				child.CustomPhysicalProperties=PhysicalProperties.new(100,0.3,0.5)
			end
		end
	end
end,true)

cmd.add({"unweaken","unstrengthen"},{"unweaken (unstrengthen)","Sets your characters CustomPhysicalProperties to default"},function()
	for _,child in pairs(getChar():GetDescendants()) do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5)
		end
	end
end)

cmd.add({"weaken"},{"weaken","Makes your character less dense"},function(...)
	local args={...}
	for _,child in pairs(getChar():GetDescendants()) do
		if child:IsA("BasePart") then
			if args[1] then
				child.CustomPhysicalProperties=PhysicalProperties.new(-args[1],0.3,0.5)
			else
				child.CustomPhysicalProperties=PhysicalProperties.new(0,0.3,0.5)
			end
		end
	end
end,true)

cmd.add({"seat"}, {"seat", "Finds a seat and automatically sits on it"}, function()
	local character = getChar()
	local humanoid = getHum()
	local root = character and getRoot(character)

	if not humanoid or not root then
		DoNotif("Your character or humanoid is invalid", 3)
		return
	end

	local seats = {}
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("Seat") and not v.Occupant then
			Insert(seats, v)
		end
	end

	if #seats == 0 then
		DebugNotif("No available seats found in the game", 3)
		return
	end

	table.sort(seats, function(a, b)
		return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
	end)

	local seat = seats[1]
	if seat then
		seat:Sit(humanoid)
		DebugNotif("Sat in the nearest seat", 2)
	else
		DebugNotif("Failed to sit in a seat", 3)
	end
end)

cmd.add({"vehicleseat", "vseat"}, {"vehicleseat (vseat)", "Sits you in a vehicle seat, useful for trying to find cars in games"}, function()
	local character = getChar()
	local humanoid = getHum()
	local root = character and getRoot(character)

	if not humanoid or not root then
		DoNotif("Your character or humanoid is invalid", 3)
		return
	end

	local vehicleSeats = {}
	for _, v in ipairs(game:GetDescendants()) do
		if v:IsA("VehicleSeat") and not v.Occupant then
			Insert(vehicleSeats, v)
		end
	end

	if #vehicleSeats == 0 then
		DebugNotif("No available VehicleSeats found in the game", 3)
		return
	end

	table.sort(vehicleSeats, function(a, b)
		return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
	end)

	local vseat = vehicleSeats[1]
	if vseat then
		vseat:Sit(humanoid)
		DebugNotif("Sat in the nearest VehicleSeat", 2)
	else
		DebugNotif("Failed to sit in a VehicleSeat", 3)
	end
end)
cmd.add({"copytools","ctools"},{"copytools <player> (ctools)","Copies the tools the given player has"},function(...)
	local targets = getPlr(...)
	local lp = Players.LocalPlayer
	if not lp then return end
	local backpack = lp:FindFirstChildOfClass("Backpack")
	if not backpack then return end
	for _,plr in ipairs(targets) do
		local tBackpack = plr:FindFirstChildOfClass("Backpack")
		if tBackpack then
			for _,tool in ipairs(tBackpack:GetChildren()) do
				if tool:IsA("Tool") or tool:IsA("HopperBin") then
					tool:Clone().Parent = backpack
				end
			end
		end
	end
end,true)
cmd.add({"localtime", "yourtime"}, {"localtime (yourtime)", "Shows your current time"}, function()
	local time = os.date("*t")
	local clock = Format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	DoNotif("Your Local Time Is: "..clock)
end)
cmd.add({"localdate", "yourdate"}, {"localdate (yourdate)", "Shows your current date"}, function()
	local time = os.date("*t")
	local dateStr = Format("%02d/%02d/%04d", time.day, time.month, time.year)
	DoNotif("Your Local Date Is: "..dateStr)
end)
zmxcnsaodakscn = nil
repeat
	local UNNNAMEEDD, FUFRRRR = pcall(function()
		return loadstring(game:HttpGet(qowijjokqwd))()
	end)

	if UNNNAMEEDD then
		zmxcnsaodakscn = FUFRRRR
	else
		Wait(.3)
	end
until zmxcnsaodakscn
askndnijewfijewongf = getgenv().cdshkjvcdsojuefdwonjwojgrwoijuhegr
cmd.add({"servertime", "svtime"}, {"servertime (svtime)", "Shows the server's current time"}, function()
	local time = os.date("!*t")
	local clock = Format("%02d:%02d:%02d", time.hour, time.min, time.sec)
	DoNotif("Server (UTC) Time Is: "..clock)
end)
cmd.add({"serverdate", "svdate"}, {"serverdate (svdate)", "Shows the server's current date"}, function()
	local time = os.date("!*t")
	local dateStr = Format("%02d/%02d/%04d", time.day, time.month, time.year)
	DoNotif("Server (UTC) Date Is: "..dateStr)
end)
cmd.add({"datetime", "localdatetime"}, {"datetime (localdatetime)", "Shows your full local date and time"}, function()
	local time = os.date("*t")
	local dateTime = Format("%02d/%02d/%04d %02d:%02d:%02d", time.day, time.month, time.year, time.hour, time.min, time.sec)
	DoNotif("Your Local Date & Time: "..dateTime)
end)
cmd.add({"uptime"}, {"uptime", "Shows how long the game/session has been running"}, function()
	local uptime = os.clock() - NASESSIONSTARTEDIDK
	local hours = math.floor(uptime / 3600)
	local minutes = math.floor((uptime % 3600) / 60)
	local seconds = math.floor(uptime % 60)
	local uptimeStr = Format("%02d:%02d:%02d", hours, minutes, seconds)
	DoNotif("Uptime: "..uptimeStr)
end)
cmd.add({"timestamp", "epoch"}, {"timestamp (epoch)", "Shows current Unix timestamp"}, function()
	local timestamp = os.time()
	DoNotif("Current Unix Timestamp: "..timestamp)
end)
somersaultBTN = nil
somersaultToggleKey = "x"
cmd.add({"somersault", "frontflip"}, {"somersault (frontflip)", "Makes you do a clean front flip"}, function(...)
	local function somersaulter()
		local p = LocalPlayer
		local c = getChar() or p.CharacterAdded:Wait()
		local hrp = getRoot(c)
		local hum = getHum()

		if hum:GetState() ~= Enum.HumanoidStateType.Freefall and hum.FloorMaterial ~= Enum.Material.Air then
			hum.PlatformStand = true
			hrp.AssemblyAngularVelocity = hrp.CFrame.RightVector * -40
			hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * 30 + Vector3.new(0, 30, 0)

			Delay(0.25, function()
				hrp.AssemblyAngularVelocity = Vector3.zero
				hum.PlatformStand = false
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end
	end

	if IsOnMobile then
		if somersaultBTN then
			somersaultBTN:Destroy()
			somersaultBTN = nil
		end

		somersaultBTN = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(somersaultBTN)
		somersaultBTN.ResetOnSpawn = false

		btn.Parent = somersaultBTN
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.85, 0, 0.5, 0)
		btn.Size = UDim2.new(0.08, 0, 0.1, 0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "Flip"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		coroutine.wrap(function()
			MouseButtonFix(btn, function()
				somersaulter()
			end)
		end)()

		NAgui.draggerV2(btn)
	else
		NAlib.disconnect("somersault_key")
		NAlib.connect("somersault_key", cmdm.KeyDown:Connect(function(KEY)
			if KEY:lower() == somersaultToggleKey then
				somersaulter()
			end
		end))

		DoNotif("Press '"..somersaultToggleKey:upper().."' to flip!", 3)
	end
end, false)
cmd.add({"unsomersault", "unfrontflip"}, {"unsomersault (unfrontflip)", "Disable somersault button and keybind"}, function(...)
	if somersaultBTN then
		somersaultBTN:Destroy()
		somersaultBTN = nil
	end

	NAlib.disconnect("somersault_key")
end, false)
cmd.add({"cartornado", "ctornado"}, {"cartornado (ctornado)", "Tornados a car just sit in the car"}, function()
	local Player = Players.LocalPlayer
	local RunService = RunService
	local Workspace = workspace

	repeat RunService.RenderStepped:Wait() until Player.Character
	local Character = Player.Character

	local SPart = InstanceNew("Part")
	SPart.Anchored = true
	SPart.CanCollide = true
	SPart.Size = Vector3.new(1, 100, 1)
	SPart.Transparency = 0.4
	SPart.Parent = Workspace

	RunService.Stepped:Connect(function()
		local hum = Character and getHum()
		if hum and Character.PrimaryPart then
			local rayOrigin = Character.PrimaryPart.Position + Character.PrimaryPart.CFrame.LookVector * 6
			local rayDir = Vector3.new(0, -4, 0)
			local ray = Ray.new(rayOrigin, rayDir)
			local part = Workspace:FindPartOnRayWithIgnoreList(ray, {Character})
			if part then
				SPart.CFrame = Character.PrimaryPart.CFrame + Character.PrimaryPart.CFrame.LookVector * 6
			end
		end
	end)

	SPart.Touched:Connect(function(hit)
		if not hit:IsA("Seat") then return end

		local torso = getTorso(Character)
		if not torso then return end

		local hum = getHum()
		if not hum then return end

		local flyv = InstanceNew("BodyVelocity")
		local flyg = InstanceNew("BodyGyro")
		local speed = 50
		local lastSpeed = speed
		local maxSpeed = 100
		local isRunning = false
		local f = 0
		local isFlying = true

		flyv.Parent = torso
		flyv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

		flyg.Parent = torso
		flyg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		flyg.P = 1000
		flyg.D = 50

		hum.PlatformStand = true

		hum.Changed:Connect(function()
			isRunning = hum.MoveDirection.Magnitude > 0
		end)

		Spawn(function()
			while isFlying do
				flyg.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad(f * 50 * speed / maxSpeed), 0, 0)
				flyv.Velocity = workspace.CurrentCamera.CFrame.LookVector * speed
				Wait(0.1)

				if speed < 0 then
					speed = 0
					f = 0
				end

				if isRunning then
					speed = lastSpeed
				else
					if speed ~= 0 then
						lastSpeed = speed
					end
					speed = 0
				end
			end
		end)

		Wait(0.3)
		hit:Sit(hum)
		SPart:Destroy()

		local seat = hum.SeatPart
		if not seat then return end

		local vehicleModel = seat.Parent
		while vehicleModel and not vehicleModel:IsA("Model") do
			vehicleModel = vehicleModel.Parent
		end

		if vehicleModel then
			for _, v in pairs(vehicleModel:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide then
					v.CanCollide = false
				end
			end
		end

		Wait(0.2)
		speed = 80

		local spin = InstanceNew("BodyAngularVelocity")
		spin.MaxTorque = Vector3.new(0, math.huge, 0)
		spin.AngularVelocity = Vector3.new(0, 2000, 0)
		spin.Parent = Character.PrimaryPart
	end)
end)

cmd.add({"unspam","unlag","unchatspam","unanimlag","unremotespam"},{"unspam","Stop all attempts to lag/spam"},function()
	NAlib.disconnect("spam")
end)

cmd.add({"UNCTest","UNC"},{"UNCTest (UNC)","Test how many functions your executor supports"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/UNC%20test"))()
end)

-- game based so bye bye api
--[[cmd.add({"sUNCtest","sUNC"},{"sUNCtest (sUNC)","uses sUNC test that test the functions if they're working"},function()
	getgenv().sUNCDebug = {
		["printcheckpoints"] = false,
		["delaybetweentests"] = 0
	}

	loadstring(game:HttpGet("https://script.sunc.su/"))()
end)]]

cmd.add({"vulnerabilitytest","vulntest"},{"vulnerabilitytest (vulntest)","Test if your executor is Vulnerable"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/VulnTest.lua"))()
end)

cmd.add({"respawn", "re"}, {"respawn (re)", "Respawn your character"}, function()
	respawn()
end)

cmd.add({"antisit"},{"antisit","Prevents the player from sitting"},function()
	local function noSit(character)
		local humanoid = getPlrHum(character)
		while not humanoid do Wait(.1) humanoid = getPlrHum(character) end
		humanoid.Sit = false
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	end

	if LocalPlayer.Character then
		noSit(LocalPlayer.Character)
	end

	NAlib.disconnect("antisit_conn")
	NAlib.connect("antisit_conn", LocalPlayer.CharacterAdded:Connect(noSit))

	DebugNotif("Anti sit enabled", 3)
end)

cmd.add({"unantisit"},{"unantisit","Allows the player to sit again"},function()
	local character = LocalPlayer.Character
	local humanoid = getHum()
	while not humanoid do Wait(.1) humanoid = getHum() end
	humanoid.Sit = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)

	NAlib.disconnect("antisit_conn")
	DebugNotif("Anti sit disabled", 3)
end)

cmd.add({"antikick", "nokick", "bypasskick", "bk"}, {"antikick (nokick, bypasskick, bk)", "Bypass Kick on Most Games"}, function()
	local getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	local setReadOnly = setreadonly or (
		make_writeable and function(t, readOnly)
			if readOnly then make_readonly(t) else make_writeable(t) end
		end
	)

	if not getRawMetatable or not setReadOnly or not newcclosure or not hookfunction then
		DoNotif("Required exploit functions not available", 3)
		return
	end

	local meta = getRawMetatable(game)
	if not meta then
		DoNotif("Failed to get game metatable", 3)
		return
	end

	local player = SafeGetService("Players").LocalPlayer
	if not player then
		DoNotif("LocalPlayer not found", 3)
		return
	end

	_G.__antikick = {
		oldNamecall = meta.__namecall,
		oldIndex = meta.__index,
		oldNewIndex = meta.__newindex
	}

	for _, Kick in next, { player.Kick, player.kick } do
		local originalKick
		originalKick = hookfunction(Kick, newcclosure(function(...)
			local args = {...}
			local msg = tostring(args[1] or "No message")
			DebugNotif("Kick call blocked (hooked): "..msg, 3)
		end))
	end

	setReadOnly(meta, false)

	meta.__namecall = newcclosure(function(self, ...)
		if self == player and getnamecallmethod():lower() == "kick" then
			local args = {...}
			local msg = tostring(args[1] or "No message")
			DebugNotif("Kick attempt blocked (__namecall): "..msg, 3)
			return
		end
		return _G.__antikick.oldNamecall(self, ...)
	end)

	meta.__index = newcclosure(function(self, key)
		if self == player then
			local lowered = tostring(key):lower()
			if lowered:find("kick") or lowered:find("destroy") or lowered:find("break") then
				DebugNotif("Blocked access to suspicious key: "..key, 3)
				return function() DebugNotif("Blocked execution of: "..key, 3) end
			end
		end
		return _G.__antikick.oldIndex(self, key)
	end)

	meta.__newindex = newcclosure(function(self, key, value)
		if self == player then
			local lowered = tostring(key):lower()
			if lowered:find("kick") or lowered:find("destroy") then
				DebugNotif("Blocked overwrite of "..key, 2)
				return
			end
		end
		return _G.__antikick.oldNewIndex(self, key, value)
	end)

	setReadOnly(meta, true)

	DebugNotif("Anti-Kick Enabled (All kicks blocked)", 2)
end)

cmd.add({"antiteleport", "noteleport", "blocktp"}, {"antiteleport (noteleport, blocktp)", "Prevents TeleportService from moving you to another place"}, function()
	local getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	local setReadOnly = setreadonly or (
		make_writeable and function(t, readOnly)
			if readOnly then make_readonly(t) else make_writeable(t) end
		end
	)

	if not getRawMetatable or not setReadOnly or not newcclosure or not hookfunction or not hookmetamethod then
		DebugNotif("Required exploit functions not available", 3)
		return
	end

	local TeleportService = SafeGetService("TeleportService")
	if not TeleportService then
		DebugNotif("TeleportService not found", 3)
		return
	end

	_G.__antiteleport = {
		oldNamecall = getRawMetatable(game).__namecall,
		oldIndex = getRawMetatable(game).__index,
		oldNewIndex = getRawMetatable(game).__newindex
	}

	for _, tpFunc in next, {
		TeleportService.Teleport,
		TeleportService.TeleportToPlaceInstance,
		TeleportService.TeleportAsync,
		TeleportService.TeleportPartyAsync,
		getrenv().TeleportToPrivateServer
		} do
		if typeof(tpFunc) == "function" then
			hookfunction(tpFunc, newcclosure(function(...)
				DebugNotif("Teleport blocked (hooked)", 3)
				return
			end))
		end
	end

	local meta = getRawMetatable(game)

	setReadOnly(meta, false)

	meta.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if typeof(method) == "string" and method:lower():find("teleport") then
			DebugNotif("Teleport blocked (__namecall): "..method, 3)
			return
		end
		return _G.__antiteleport.oldNamecall(self, ...)
	end)

	meta.__index = newcclosure(function(self, key)
		if self == TeleportService then
			local lowered = tostring(key):lower()
			if lowered:find("teleport") then
				DebugNotif("Blocked access to teleport method: "..key, 3)
				return function() DebugNotif("Blocked execution of: "..key, 3) end
			end
		end
		return _G.__antiteleport.oldIndex(self, key)
	end)

	meta.__newindex = newcclosure(function(self, key, value)
		if self == TeleportService then
			local lowered = tostring(key):lower()
			if lowered:find("teleport") then
				DebugNotif("Blocked overwrite of teleport method: "..key, 2)
				return
			end
		end
		return _G.__antiteleport.oldNewIndex(self, key, value)
	end)

	setReadOnly(meta, true)

	DebugNotif("Anti-Teleport Enabled", 2)
end)

cmd.add({"unantikick", "unnokick", "unbypasskick", "unbk"}, {"unantikick", "Disables Anti-Kick protection"}, function()
	local getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	local setReadOnly = setreadonly or (
		make_writeable and function(t, readOnly)
			if readOnly then
				make_readonly(t)
			else
				make_writeable(t)
			end
		end
	)

	local meta = getRawMetatable(game)
	if not meta or not _G.__antikick then
		DoNotif("Anti-Kick not active or missing references", 3)
		return
	end

	setReadOnly(meta, false)
	meta.__namecall = _G.__antikick.oldNamecall
	meta.__index = _G.__antikick.oldIndex
	meta.__newindex = _G.__antikick.oldNewIndex
	setReadOnly(meta, true)

	_G.__antikick = nil

	DebugNotif("Anti-Kick Disabled", 2)
end)

cmd.add({"unantiteleport", "unnoteleport", "unblocktp"}, {"unantiteleport", "Disables Anti-Teleport protection"}, function()
	local getRawMetatable = (debug and debug.getmetatable) or getrawmetatable
	local setReadOnly = setreadonly or (
		make_writeable and function(t, readOnly)
			if readOnly then
				make_readonly(t)
			else
				make_writeable(t)
			end
		end
	)

	local meta = getRawMetatable(game)
	if not meta or not _G.__antiteleport then
		DoNotif("Anti-Teleport not active or missing references", 3)
		return
	end

	setReadOnly(meta, false)
	meta.__namecall = _G.__antiteleport.oldNamecall
	meta.__index = _G.__antiteleport.oldIndex
	meta.__newindex = _G.__antiteleport.oldNewIndex
	setReadOnly(meta, true)

	_G.__antiteleport = nil

	DebugNotif("Anti-Teleport Disabled", 2)
end)

acftpCON = {}
acftpCONN = nil
acftpCFrames = {}
acftpGUI = nil
acftpState = false

function enableACFTP()
	acftpState = true
	local character = LocalPlayer and LocalPlayer.Character
	if not character then
		DoNotif("Your character is invalid.", 3)
		return
	end

	for _, con in pairs(acftpCON) do
		con:Disconnect()
	end
	acftpCON = {}
	acftpCFrames = {}

	if acftpCONN then
		acftpCONN:Disconnect()
		acftpCONN = nil
	end

	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			acftpCFrames[part] = part.CFrame
			acftpCON[part] = part:GetPropertyChangedSignal("CFrame"):Connect(function()
				if part:IsDescendantOf(character) and part.CFrame ~= acftpCFrames[part] then
					part.CFrame = acftpCFrames[part]
				end
			end)
		end
	end

	acftpCONN = RunService.Stepped:Connect(function()
		for part in pairs(acftpCFrames) do
			if part and part:IsDescendantOf(character) then
				acftpCFrames[part] = part.CFrame
			end
		end
	end)

	DebugNotif("Anti CFrame Teleport enabled", 1.5)
end

function disableACFTP()
	for _, con in pairs(acftpCON) do
		con:Disconnect()
	end
	acftpCON = {}
	acftpCFrames = {}

	if acftpCONN then
		acftpCONN:Disconnect()
		acftpCONN = nil
	end

	acftpState = false
	DebugNotif("Anti CFrame Teleport disabled", 1.5)
end

cmd.add({"anticframeteleport", "acframetp", "acftp"}, {"anticframeteleport (acframetp,acftp)", "Prevents scripts from teleporting you by resetting your CFrame"}, function()
	enableACFTP()

	if IsOnMobile then
		if acftpGUI then
			acftpGUI:Destroy()
		end

		acftpGUI = InstanceNew("ScreenGui")
		local acftpBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(acftpGUI)
		acftpGUI.ResetOnSpawn = false

		acftpBtn.Parent = acftpGUI
		acftpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		acftpBtn.BackgroundTransparency = 0.1
		acftpBtn.Position = UDim2.new(0.9, 0, 0.4, 0)
		acftpBtn.Size = UDim2.new(0.08, 0, 0.1, 0)
		acftpBtn.Font = Enum.Font.GothamBold
		acftpBtn.Text = "UNACFTP"
		acftpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		acftpBtn.TextSize = 18
		acftpBtn.TextScaled = true
		acftpBtn.TextWrapped = true
		acftpBtn.Active = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = acftpBtn
		aspect.Parent = acftpBtn
		aspect.AspectRatio = 1.0

		MouseButtonFix(acftpBtn, function()
			acftpState = not acftpState
			if acftpState then
				enableACFTP()
				acftpBtn.Text = "UNACFTP"
				acftpBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			else
				disableACFTP()
				acftpBtn.Text = "ACFTP"
				acftpBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
			end
		end)

		NAgui.draggerV2(acftpBtn)
	end
end)

cmd.add({"unanticframeteleport", "unacframetp", "unacftp"}, {"unanticframeteleport (unacframetp,unacftp)", "Disables Anti CFrame Teleport"}, function()
	disableACFTP()

	if acftpGUI then
		acftpGUI:Destroy()
		acftpGUI = nil
	end
end)

cmd.add({"lay"},{"lay","zzzzzzzz"},function()
	local Human=getHum()
	if not Human then return end
	Human.Sit=true
	Wait(.1)
	Human.RootPart.CFrame=Human.RootPart.CFrame*CFrame.Angles(math.pi*.5,0,0)
	for _,v in ipairs(Human:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end)

cmd.add({"trip"},{"trip","get up NOW"},function()
	getHum():ChangeState(0)
	getRoot(getChar()).Velocity=getRoot(getChar()).CFrame.LookVector*25
end)

cmd.add({"antitrip"}, {"antitrip", "no tripping today bruh"}, function()
	local function doTRIPPER(char)
		local hum = getPlrHum(char)
		local root = getRoot(char)
		while not (hum and root) do Wait(.1) hum=getPlrHum(char) root=getRoot(char) end

		NAlib.disconnect("trip_fall")
		NAlib.connect("trip_fall", hum.FallingDown:Connect(function()
			root.Velocity = Vector3.zero
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end))
	end

	if LocalPlayer.Character then
		doTRIPPER(LocalPlayer.Character)
	end

	NAlib.disconnect("trip_char")
	NAlib.connect("trip_char", LocalPlayer.CharacterAdded:Connect(doTRIPPER))

	DebugNotif("Antitrip Enabled", 2)
end)

cmd.add({"unantitrip"}, {"unantitrip", "tripping allowed now"}, function()
	NAlib.disconnect("trip_fall")
	NAlib.disconnect("trip_char")
	DebugNotif("Antitrip Disabled", 2)
end)

cmd.add({"checkrfe"},{"checkrfe","Checks if the game has respect filtering enabled off"},function()
	DoNotif(SafeGetService("SoundService").RespectFilteringEnabled and "Respect Filtering Enabled is on" or "Respect Filtering Enabled is off")
end)

cmd.add({"sit"},{"sit","Sit your player"},function()
	local hum=getHum()
	if hum then
		hum.Sit=true
	end
end)

cmd.add({"oldroblox"},{"oldroblox","Old skybox and studs"},function()
	for i,v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			local dec=InstanceNew("Texture",v)
			dec.Texture=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.Stud) or "rbxassetid://48715260"
			dec.Face="Top"
			dec.StudsPerTileU="1"
			dec.StudsPerTileV="1"
			dec.Transparency=v.Transparency
			v.Material="Plastic"
			local dec2=InstanceNew("Texture",v)
			dec2.Texture=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.Inlet) or "rbxassetid://20299774"
			dec2.Face="Bottom"
			dec2.StudsPerTileU="1"
			dec2.StudsPerTileV="1"
			dec2.Transparency=v.Transparency
			v.Material="Plastic"
		end
	end
	Lighting.ClockTime=12
	Lighting.GlobalShadows=false
	Lighting.Outlines=false
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Sky") then
			v:Destroy()
		end
	end
	local sky=InstanceNew("Sky",Lighting)
	sky.SkyboxBk=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.bk) or "rbxassetid://161781263"
	sky.SkyboxDn=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.dn) or "rbxassetid://161781258"
	sky.SkyboxFt=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.ft) or "rbxassetid://161781261"
	sky.SkyboxLf=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.lf) or "rbxassetid://161781267"
	sky.SkyboxRt=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.rt) or "rbxassetid://161781268"
	sky.SkyboxUp=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.up) or "rbxassetid://161781260"
end)

cmd.add({"f3x","fex"},{"f3x (fex)","F3X for client"},function()
	loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)()
end)

cmd.add({"harked","comet"},{"harked (comet)","Executes Comet which is like harked"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/comet"))();
end)

cmd.add({"triggerbot", "tbot"}, {"triggerbot (tbot)", "Executes a script that automatically clicks the mouse when the mouse is on a player"}, function()
	local ToggleKey = Enum.KeyCode.Z
	local FieldOfView = 10

	local Players = Players
	local RunService = RunService
	local UIS = UserInputService
	local Camera = workspace.CurrentCamera

	local Player = Players.LocalPlayer
	local Mouse = Player:GetMouse()
	local Toggled = false
	local Mode = "FFA"
	local LastMode = nil

	local GUI = InstanceNew("ScreenGui")
	local On = InstanceNew("TextLabel")
	local uicorner = InstanceNew("UICorner")
	NaProtectUI(GUI)
	On.Parent = GUI
	On.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
	On.BackgroundTransparency = 0.14
	On.BorderSizePixel = 0
	On.Position = UDim2.new(0.88, 0, 0.33, 0)
	On.Size = UDim2.new(0, 160, 0, 20)
	On.Font = Enum.Font.SourceSans
	On.Text = "TriggerBot On: false (Key: Q)"
	On.TextColor3 = Color3.new(1, 1, 1)
	On.TextScaled = true
	On.TextSize = 14
	On.TextWrapped = true
	uicorner.Parent = On

	local function IsInFieldOfView(target)
		local targetPosition = target.Position
		local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPosition)
		if onScreen then
			local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
			local targetScreenPosition = Vector2.new(screenPoint.X, screenPoint.Y)
			local distance = (mousePosition - targetScreenPosition).Magnitude
			return distance <= FieldOfView
		end
		return false
	end

	local function IsEnemy(otherPlayer)
		if Mode == "FFA" then
			return true
		else
			return otherPlayer.Team ~= nil and Player.Team ~= nil and otherPlayer.Team ~= Player.Team
		end
	end

	local function GetClosestPlayer()
		for _, otherPlayer in pairs(Players:GetPlayers()) do
			if otherPlayer ~= Player and IsEnemy(otherPlayer) and otherPlayer.Character then
				for _, part in pairs(otherPlayer.Character:GetChildren()) do
					if part:IsA("BasePart") and IsInFieldOfView(part) then
						return otherPlayer
					end
				end
			end
		end
		return nil
	end

	local function Click()
		mouse1click()
	end

	local function CheckMode()
		if #Players:GetPlayers() > 0 and Players.LocalPlayer.Team == nil then
			Mode = "FFA"
		else
			Mode = "Team"
		end

		if Mode ~= LastMode then
			DoNotif("Mode changed to: "..Mode)
			LastMode = Mode
		end
	end

	UIS.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == ToggleKey then
			Toggled = not Toggled
			On.Text = "TriggerBot On: "..tostring(Toggled).." (Key: "..ToggleKey.Name..")"
		end
	end)

	RunService.Stepped:Connect(function()
		CheckMode()
		if Toggled then
			local targetPlayer = GetClosestPlayer()
			if getPlrHum(targetPlayer) then
				local humanoid = getPlrHum(targetPlayer)
				if humanoid.Health > 0 then
					Click()
				end
			end
		end
	end)

	On.Text = "TriggerBot On: "..tostring(Toggled).." (Key: "..ToggleKey.Name..")"

	DebugNotif("Advanced Trigger Bot Loaded")
end)

cmd.add({"nofog"},{"nofog","Removes all fog from the game"},function()
	local Lighting=Lighting
	Lighting.FogEnd=100000
	for i,v in pairs(Lighting:GetDescendants()) do
		if v:IsA("Atmosphere") then
			v:Destroy()
		end
	end
end)

stationaryRespawn = false
needsRespawning = false
hasPosition = false
spawnPosition = CFrame.new()

cmd.add({"setspawn", "spawnpoint", "ss"}, {"setspawn (spawnpoint, ss)", "Sets your spawn point to the current character's position"}, function()
	if NAlib.isConnected("spawnCONNECTION") and NAlib.isConnected("spawnCHARCON") then
		return DoNotif("spawn point is already running", 3)
	end

	DebugNotif("Spawn has been set")
	stationaryRespawn = true

	function handleRespawn()
		if stationaryRespawn and getHum() and getHum().Health == 0 then
			if not hasPosition then
				spawnPosition = getRoot(getChar()).CFrame
				hasPosition = true
			end
			needsRespawning = true
		end

		if needsRespawning then
			if getChar() and getRoot(getChar()) then
				getRoot(getChar()).CFrame = spawnPosition
			end
		end
	end

	NAlib.connect("spawnCONNECTION", RunService.Stepped:Connect(handleRespawn))

	NAlib.connect("spawnCHARCON", LocalPlayer.CharacterAdded:Connect(function()
		Wait(1)
		needsRespawning = false
		hasPosition = false
	end))
end)

cmd.add({"disablespawn", "unsetspawn", "ds"}, {"disablespawn (unsetspawn, ds)", "Disables the previously set spawn point"}, function()
	DebugNotif("Spawn point has been disabled")
	NAlib.disconnect("spawnCONNECTION")
	NAlib.disconnect("spawnCHARCON")
	stationaryRespawn = false
	needsRespawning = false
	hasPosition = false
	spawnPosition = CFrame.new()
end)

cmd.add({"flashback", "deathpos", "deathtp"}, {"flashback (deathpos, deathtp)", "Teleports you to your last death point"}, function()
	if deathCFrame then
		local character = getChar()
		if character and getRoot(character) then
			getRoot(character).CFrame = deathCFrame
		else
			DoNotif("Could not teleport, root is missing", 3)
		end
	else
		DoNotif("No available death location to teleport to! You need to die first", 3)
	end
end)

cmd.add({"hamster"}, {"hamster <number>", "Hamster ball"}, function(...)
	local UserInputService = SafeGetService("UserInputService")
	local RunService = RunService
	local Camera = workspace.CurrentCamera

	local SPEED_MULTIPLIER = (...) or 30
	local JUMP_POWER = 60
	local JUMP_GAP = 0.3

	local character = SafeGetService("Players").LocalPlayer.Character

	for i, v in ipairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end

	local ball = getRoot(character)
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(5, 5, 5)
	local humanoid = getHum()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {character}

	NAlib.connect("hamster_render", RunService.RenderStepped:Connect(function(delta)
		ball.CanCollide = true
		humanoid.PlatformStand = true
		if UserInputService:GetFocusedTextBox() then return end

		local moveVec = GetCustomMoveVector()

		if moveVec.Magnitude > 0 then
			local right = Camera.CFrame.RightVector
			local forward = Camera.CFrame.LookVector
			ball.RotVelocity = ball.RotVelocity + (right * moveVec.Z * delta * SPEED_MULTIPLIER)
			ball.RotVelocity = ball.RotVelocity + (forward * moveVec.X * delta * SPEED_MULTIPLIER)
		end
	end))

	UserInputService.JumpRequest:Connect(function()
		local result = workspace:Raycast(
			ball.Position,
			Vector3.new(0, -((ball.Size.Y / 2) + JUMP_GAP), 0),
			params
		)
		if result then
			ball.Velocity = ball.Velocity + Vector3.new(0, JUMP_POWER, 0)
		end
	end)

	humanoid.Died:Connect(function()
		NAlib.disconnect("hamster_render")
	end)

	Camera.CameraSubject = ball
end, true)

cmd.add({"antiafk","noafk"},{"antiafk (noafk)","Prevents you from being kicked for being AFK"},function()
	if not NAlib.isConnected("antiAFK") then
		local player = Players.LocalPlayer
		local virtualUser = SafeGetService("VirtualUser")

		NAlib.connect("antiAFK", player.Idled:Connect(function()
			virtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			Wait(1)
			virtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end))

		DebugNotif("Anti AFK has been enabled")
	else
		DebugNotif("Anti AFK is already enabled")
	end
end)

cmd.add({"unantiafk","unnoafk"},{"unantiafk (unnoafk)","Allows you to be kicked for being AFK"},function()
	if NAlib.isConnected("antiAFK") then
		NAlib.disconnect("antiAFK")
		DebugNotif("Anti AFK has been disabled")
	else
		DebugNotif("Anti AFK is already disabled")
	end
end)

local tpUI
local tpTools = {}

NAmanage.clearAllTP = function()
	if tpUI then
		tpUI:Destroy()
		tpUI = nil
	end
	for _, t in ipairs(tpTools) do
		t:Destroy()
	end
	tpTools = {}
	NAlib.disconnect("tp_down")
	NAlib.disconnect("tp_up")
end

NAmanage.makeClickTweenUI = function()
	NAmanage.clearAllTP()
	local TweenService = SafeGetService("TweenService")
	local player = Players.LocalPlayer
	local mouse = player:GetMouse()

	tpUI = InstanceNew("ScreenGui")
	NaProtectUI(tpUI)

	local clickTpButton = InstanceNew("TextButton")
	clickTpButton.Size = UDim2.new(0,130,0,40)
	clickTpButton.AnchorPoint = Vector2.new(0.5,0)
	clickTpButton.Position = UDim2.new(0.45,0,0.1,0)
	clickTpButton.Text = "Enable Click TP"
	clickTpButton.TextColor3 = Color3.fromRGB(255,255,255)
	clickTpButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
	clickTpButton.BorderSizePixel = 0
	clickTpButton.Parent = tpUI

	local tweenTpButton = clickTpButton:Clone()
	tweenTpButton.Position = UDim2.new(0.55,0,0.1,0)
	tweenTpButton.Text = "Enable Tween TP"
	tweenTpButton.Parent = tpUI

	InstanceNew("UICorner", clickTpButton)
	InstanceNew("UICorner", tweenTpButton)

	local clickEnabled = false
	local tweenEnabled = false
	local initialPos
	local dragThreshold = 10
	local ctCFVal

	MouseButtonFix(clickTpButton, function()
		clickEnabled = not clickEnabled
		tweenEnabled = false
		if ctCFVal then
			ctCFVal:Destroy()
			ctCFVal = nil
		end
		clickTpButton.Text = clickEnabled and "Disable Click TP" or "Enable Click TP"
		tweenTpButton.Text = "Enable Tween TP"
	end)

	MouseButtonFix(tweenTpButton, function()
		tweenEnabled = not tweenEnabled
		clickEnabled = false
		if not tweenEnabled and ctCFVal then
			ctCFVal:Destroy()
			ctCFVal = nil
		end
		tweenTpButton.Text = tweenEnabled and "Disable Tween TP" or "Enable Tween TP"
		clickTpButton.Text = "Enable Click TP"
	end)

	NAlib.connect("tp_down", mouse.Button1Down:Connect(function()
		initialPos = Vector2.new(mouse.X, mouse.Y)
	end))

	NAlib.connect("tp_up", mouse.Button1Up:Connect(function()
		if not initialPos then return end
		local currentPos = Vector2.new(mouse.X, mouse.Y)
		if (currentPos - initialPos).Magnitude <= dragThreshold then
			local target = mouse.Hit + Vector3.new(0,2.5,0)
			local char = player.Character
			if clickEnabled then
				char:PivotTo(CFrame.new(target.p))
			elseif tweenEnabled then
				if ctCFVal then
					ctCFVal:Destroy()
					ctCFVal = nil
				end
				local cfVal = InstanceNew("CFrameValue")
				ctCFVal = cfVal
				cfVal.Value = char:GetPivot()
				cfVal.Changed:Connect(function(newCF)
					char:PivotTo(newCF)
				end)
				local tw = TweenService:Create(cfVal, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=CFrame.new(target.p)})
				tw:Play()
				tw.Completed:Connect(function()
					if cfVal then
						cfVal:Destroy()
						if ctCFVal == cfVal then
							ctCFVal = nil
						end
					end
				end)
			end
		end
		initialPos = nil
	end))

	NAgui.draggerV2(clickTpButton)
	NAgui.draggerV2(tweenTpButton)
end

NAmanage.makeClickTweenTools = function()
	NAmanage.clearAllTP()
	local TweenService = SafeGetService("TweenService")
	local player = Players.LocalPlayer

	local function newTool(name, tween)
		local tool = InstanceNew("Tool")
		tool.Name = name
		tool.RequiresHandle = false
		tool.CanBeDropped = false
		tool.Parent = player.Backpack
		tool.Activated:Connect(function()
			local mouse = player:GetMouse()
			local target = mouse.Hit + Vector3.new(0,2.5,0)
			local char = player.Character
			if tween then
				local cfVal = InstanceNew("CFrameValue")
				cfVal.Value = char:GetPivot()
				cfVal.Changed:Connect(function(newCF)
					char:PivotTo(newCF)
				end)
				local tw = TweenService:Create(cfVal, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value=CFrame.new(target.p)})
				tw:Play()
				tw.Completed:Connect(function()
					cfVal:Destroy()
				end)
			else
				char:PivotTo(CFrame.new(target.p))
			end
		end)
		Insert(tpTools, tool)
	end

	newTool("Click TP", false)
	newTool("Tween TP", true)
end

cmd.add({"clicktp","tptool"},{"clicktp (tptool)","Teleport where your mouse is"},function()
	Window({
		Title = "Choose Teleport Mode",
		Description = "Would you like to use on-screen buttons, or equipable Tools in your Backpack?",
		Buttons = {
			{Text="UI Buttons",Callback=NAmanage.makeClickTweenUI},
			{Text="Backpack Tools",Callback=NAmanage.makeClickTweenTools}
		}
	})
end)

cmd.add({"unclicktp","untptool"},{"unclicktp (untptool)","Remove teleport buttons or tools"},function()
	NAmanage.clearAllTP()
end)

cmd.add({"olddex"},{"olddex","Using this you can see the parts / guis / scripts etc with this. A really good and helpful script."},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DexByMoonMobile"))()
end)

cmd.add({"dex"},{"dex","Better version of dex"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DexPlusBackup.luau"))()
end)

cmd.add({"minimap"},{"minimap","just a minimap lol"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/minimap.luau"))()
end)

cmd.add({"animationplayer","animplayer", "aplayer","animp"},{"animationplayer","dropdown menu with all the animations the game has to be played"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/AnimPlayer.luau"))();
end)

cmd.add({"Decompiler"},{"Decompiler","Allows you to decompile LocalScript/ModuleScript's using konstant"},function()
	Spawn(function()
		assert(getscriptbytecode, "Exploit not supported.")

		local API: string = "http://api.plusgiant5.com/"

		local last_call = 0
		function call(konstantType: string, scriptPath: Script | ModuleScript | LocalScript): string
			local success: boolean, bytecode: string = NACaller(getscriptbytecode, scriptPath)

			if (not success) then
				return
			end

			local time_elapsed = os.clock() - last_call
			if time_elapsed <= .5 then
				Wait(.5 - time_elapsed)
			end
			local httpResult = opt.NAREQUEST({
				Url = API..konstantType,
				Body = bytecode,
				Method = "POST",
				Headers = {
					["Content-Type"] = "text/plain"
				},
			})
			last_call = os.clock()

			if (httpResult.StatusCode ~= 200) then
				return
			else
				return httpResult.Body
			end
		end

		function decompile(scriptPath: Script | ModuleScript | LocalScript): string
			return call("/konstant/decompile", scriptPath)
		end

		function disassemble(scriptPath: Script | ModuleScript | LocalScript): string
			return call("/konstant/disassemble", scriptPath)
		end

		getgenv().decompile = decompile
		getgenv().disassemble = disassemble

		-- by lovrewe
	end)
	--loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/WompWomp.lua"))()
end)

cmd.add({"getidfromusername","gidu"},{"getidfromusername (gidu)","Copy a user's UserId by Username"}, function(thingy)
	local s,idd=NACaller(function()
		return Players:GetUserIdFromNameAsync(tostring(thingy))
	end)

	if not s then return DoNotif("err: "..tostring(idd)) end

	if not setclipboard then return DoNotif("no setclipboard") end
	setclipboard(tostring(idd))

	DebugNotif("Copied "..tostring(thingy).."'s UserId: "..tostring(idd))
end,true)

cmd.add({"getuserfromid","guid"},{"getuserfromid (guid)","Copy a user's Username by ID"}, function(thingy)
	local s,naem=NACaller(function()
		return Players:GetNameFromUserIdAsync(thingy)
	end)

	if not s then return DoNotif("err: "..tostring(naem)) end

	if not setclipboard then return DoNotif("no setclipboard") end
	setclipboard(tostring(naem))

	DebugNotif("Copied "..tostring(naem).."'s Username with ID of "..tostring(thingy))
end,true)

cmd.add({"synapsedex","sdex"},{"synapsedex (sdex)","Loads SynapseX's dex explorer"},function()
	local rng=Random.new()

	local charset={}
	for i=48,57 do Insert(charset,string.char(i)) end
	for i=65,90 do Insert(charset,string.char(i)) end
	for i=97,122 do Insert(charset,string.char(i)) end
	function RandomCharacters(length)
		if length>0 then
			return RandomCharacters(length-1)..charset[rng:NextInteger(1,#charset)]
		else
			return ""
		end
	end

	local Dex=game:GetObjects("rbxassetid://9553291002")[1]
	Dex.Name=RandomCharacters(rng:NextInteger(5,20))
	NaProtectUI(Dex)

	function Load(Obj,Url)
		function GiveOwnGlobals(Func,Script)
			local Fenv={}
			local RealFenv={script=Script}
			local FenvMt={}
			FenvMt.__index=function(a,b)
				if RealFenv[b]==nil then
					return getfenv()[b]
				else
					return RealFenv[b]
				end
			end
			FenvMt.__newindex=function(a,b,c)
				if RealFenv[b]==nil then
					getfenv()[b]=c
				else
					RealFenv[b]=c
				end
			end
			setmetatable(Fenv,FenvMt)
			setfenv(Func,Fenv)
			return Func
		end

		function LoadScripts(Script)
			if Script.ClassName=="Script" or Script.ClassName=="LocalScript" then
				Spawn(function()
					GiveOwnGlobals(loadstring(Script.Source,"="..Script:GetFullName()),Script)()
				end)
			end
			for i,v in pairs(Script:GetChildren()) do
				LoadScripts(v)
			end
		end

		LoadScripts(Obj)
	end

	Load(Dex)
end)

cmd.add({"antifling"}, {"antifling", "makes other players non-collidable with you"}, function()
	NAlib.disconnect("antifling")
	NAlib.connect("antifling", RunService.Stepped:Connect(function()
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= LocalPlayer and pl.Character then
				for _, part in ipairs(pl.Character:GetDescendants()) do
					if part:IsA("BasePart") and NAlib.isProperty(part, "CanCollide") then
						NAlib.setProperty(part, "CanCollide", false)
					end
				end
			end
		end
	end))
	DebugNotif("Antifling Enabled")
end)

cmd.add({"unantifling"}, {"unantifling", "restores collision for other players"}, function()
	NAlib.disconnect("antifling")
	DebugNotif("Antifling Disabled")
end)

cmd.add({"gravitygun"},{"gravitygun","Probably the best gravity gun script thats fe"},function()
	Wait();
	DoNotif("Wait a few seconds for it to load",2.5)
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/gravity%20gun"))()
end)

cmd.add({"lockws","lockworkspace"},{"lockws (lockworkspace)","Locks the whole workspace"},function()
	for _, inst in ipairs(workspace:GetDescendants()) do
		if NAlib.isProperty(inst, "Locked") ~= nil then
			NAlib.setProperty(inst, "Locked", true)
		end
	end
end)

cmd.add({"unlockws","unlockworkspace"},{"unlockws (unlockworkspace)","Unlocks everything in Workspace"},function()
	for _, inst in ipairs(workspace:GetDescendants()) do
		if NAlib.isProperty(inst, "Locked") ~= nil then
			NAlib.setProperty(inst, "Locked", false)
		end
	end
end)

vspeedBTN = nil

cmd.add({"vehiclespeed", "vspeed"}, {"vehiclespeed <amount> (vspeed)", "Change the vehicle speed"}, function(amount)
	NAlib.disconnect("vehicleloopspeed")

	if vspeedBTN then
		vspeedBTN:Destroy()
		vspeedBTN = nil
	end

	local intens = tonumber(amount) or 1

	NAlib.connect("vehicleloopspeed", RunService.Stepped:Connect(function()
		local subject = workspace.CurrentCamera.CameraSubject
		if subject and subject:IsA("Humanoid") and subject.SeatPart then
			subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
		elseif subject and subject:IsA("BasePart") then
			subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
		end
	end))

	DebugNotif("Vehicle speed set to "..intens)

	Wait()

	vspeedBTN = InstanceNew("ScreenGui")
	local btn = InstanceNew("TextButton")
	local speedBox = InstanceNew("TextBox")
	local toggleBtn = InstanceNew("TextButton")
	local corner = InstanceNew("UICorner")
	local corner2 = InstanceNew("UICorner")
	local corner3 = InstanceNew("UICorner")
	local aspect = InstanceNew("UIAspectRatioConstraint")
	local vstopBtn = InstanceNew("TextButton")
	local vstopCorner = InstanceNew("UICorner")

	NaProtectUI(vspeedBTN)

	btn.Parent = vspeedBTN
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.BackgroundTransparency = 0.1
	btn.Position = UDim2.new(0.9, 0, 0.4, 0)
	btn.Size = UDim2.new(0.08, 0, 0.1, 0)
	btn.Font = Enum.Font.GothamBold
	btn.Text = "vSpeed"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.TextWrapped = true
	btn.Active = true

	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = btn

	aspect.Parent = btn
	aspect.AspectRatio = 1.0

	speedBox.Parent = vspeedBTN
	speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	speedBox.BackgroundTransparency = 0.1
	speedBox.AnchorPoint = Vector2.new(0.5, 0)
	speedBox.Position = UDim2.new(0.5, 0, 0, 10)
	speedBox.Size = UDim2.new(0, 75, 0, 35)
	speedBox.Font = Enum.Font.GothamBold
	speedBox.Text = tostring(intens)
	speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	speedBox.TextSize = 18
	speedBox.TextWrapped = true
	speedBox.ClearTextOnFocus = false
	speedBox.PlaceholderText = "Speed"
	speedBox.Visible = false

	corner2.CornerRadius = UDim.new(0.2, 0)
	corner2.Parent = speedBox

	toggleBtn.Parent = btn
	toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggleBtn.BackgroundTransparency = 0.1
	toggleBtn.Position = UDim2.new(0.8, 0, -0.1, 0)
	toggleBtn.Size = UDim2.new(0.4, 0, 0.4, 0)
	toggleBtn.Font = Enum.Font.SourceSans
	toggleBtn.Text = "+"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.TextScaled = true
	toggleBtn.TextWrapped = true
	toggleBtn.Active = true
	toggleBtn.AutoButtonColor = true

	corner3.CornerRadius = UDim.new(1, 0)
	corner3.Parent = toggleBtn

	vstopBtn.Parent = vspeedBTN
	vstopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	vstopBtn.BackgroundTransparency = 0.1
	vstopBtn.Position = UDim2.new(0.9, 0, 0.52, 0)
	vstopBtn.Size = UDim2.new(0.08, 0, 0.1, 0)
	vstopBtn.Font = Enum.Font.GothamBold
	vstopBtn.Text = "vSTOP"
	vstopBtn.TextColor3 = Color3.new(1, 1, 1)
	vstopBtn.TextScaled = true
	vstopBtn.TextWrapped = true
	vstopBtn.Active = true
	vstopBtn.AutoButtonColor = true

	vstopCorner.CornerRadius = UDim.new(0.2, 0)
	vstopCorner.Parent = vstopBtn

	MouseButtonFix(toggleBtn, function()
		speedBox.Visible = not speedBox.Visible
		toggleBtn.Text = speedBox.Visible and "-" or "+"
	end)

	local vSpeedOn = true
	btn.Text = "vSpeed ON"
	btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)

	MouseButtonFix(btn, function()
		vSpeedOn = not vSpeedOn

		if vSpeedOn then
			local newIntens = tonumber(speedBox.Text) or 1
			intens = newIntens

			NAlib.disconnect("vehicleloopspeed")
			NAlib.connect("vehicleloopspeed", RunService.Stepped:Connect(function()
				local subject = workspace.CurrentCamera.CameraSubject
				if subject and subject:IsA("Humanoid") and subject.SeatPart then
					subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
				elseif subject and subject:IsA("BasePart") then
					subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
				end
			end))

			btn.Text = "vSpeed ON"
			btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			NAlib.disconnect("vehicleloopspeed")

			local subject = workspace.CurrentCamera.CameraSubject
			if subject then
				local root
				if subject:IsA("Humanoid") and subject.SeatPart then
					root = subject.SeatPart
				elseif subject:IsA("BasePart") then
					root = subject
				end

				if root then
					Spawn(function()
						for i = 1, 10 do
							if root:IsDescendantOf(game) then
								root.AssemblyLinearVelocity=root.AssemblyLinearVelocity * .8
								root.AssemblyAngularVelocity=root.AssemblyAngularVelocity * .8
								Wait(0.05)
							end
						end
					end)
				end
			end

			btn.Text = "vSpeed"
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		end
	end)

	MouseButtonFix(vstopBtn, function()
		local subject = workspace.CurrentCamera.CameraSubject
		if subject then
			local root
			if subject:IsA("Humanoid") and subject.SeatPart then
				root = subject.SeatPart
			elseif subject:IsA("BasePart") then
				root = subject
			end

			if root then
				local model = root:FindFirstAncestorOfClass("Model")
				if model then
					for _, part in ipairs(model:GetDescendants()) do
						if part:IsA("BasePart") then
							part.AssemblyLinearVelocity = Vector3.zero
							part.AssemblyAngularVelocity = Vector3.zero
						end
						if part:IsA("VehicleSeat") then
							part.Throttle = 0
							part.Steer = 0
						end
					end
				else
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end
			end
		end
	end)

	speedBox.FocusLost:Connect(function()
		if not vSpeedOn then return end
		local newIntens = tonumber(speedBox.Text) or 1
		intens = newIntens

		NAlib.disconnect("vehicleloopspeed")
		NAlib.connect("vehicleloopspeed", RunService.Stepped:Connect(function()
			local subject = workspace.CurrentCamera.CameraSubject
			if subject and subject:IsA("Humanoid") and subject.SeatPart then
				subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
			elseif subject and subject:IsA("BasePart") then
				subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
			end
		end))

		DebugNotif("vSpeed updated to "..intens, 2)
	end)

	NAgui.draggerV2(btn)
	NAgui.draggerV2(speedBox)
	NAgui.draggerV2(vstopBtn)
end, true)

cmd.add({"unvehiclespeed", "unvspeed"}, {"unvehiclespeed (unvspeed)", "Stops the vehiclespeed command"}, function()
	NAlib.disconnect("vehicleloopspeed")

	if vspeedBTN then
		vspeedBTN:Destroy()
		vspeedBTN = nil
	end

	local subject = workspace.CurrentCamera.CameraSubject
	if subject then
		local root
		if subject:IsA("Humanoid") and subject.SeatPart then
			root = subject.SeatPart
		elseif subject:IsA("BasePart") then
			root = subject
		end

		if root then
			local model = root:FindFirstAncestorOfClass("Model")
			if model then
				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end
					if part:IsA("VehicleSeat") then
						part.Throttle = 0
						part.Steer = 0
					end
				end
			else
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	DebugNotif("Vehicle speed disabled")
end)

local active=false
local players=Players
local camera=workspace.CurrentCamera

local uis=UserInputService

local active=false
function UpdateAutoRotate(BOOL)
	humanoid.AutoRotate=BOOL
end

local GameSettings = UserSettings():GetService("UserGameSettings")

local OriginalRotationType = nil
local ShiftLockEnabled = false

function EnableShiftLock()
	if ShiftLockEnabled then return end

	local success, currentRotation = NACaller(function()
		return GameSettings.RotationType
	end)

	if success then
		OriginalRotationType = currentRotation
	end

	NAlib.connect("shiftlock_loop", RunService.Stepped:Connect(function()
		NACaller(function()
			GameSettings.RotationType = Enum.RotationType.CameraRelative
		end)
	end))

	ShiftLockEnabled = true
	DebugNotif("ShiftLock Enabled", 2)
end

function DisableShiftLock()
	if not ShiftLockEnabled then return end

	NAlib.disconnect("shiftlock_loop")

	NACaller(function()
		GameSettings.RotationType = OriginalRotationType or Enum.RotationType.MovementRelative
	end)

	ShiftLockEnabled = false
	DebugNotif("ShiftLock Disabled", 2)
end

cmd.add({"shiftlock","sl"}, {"shiftlock (sl)", "Toggles shiftlock"}, function()
	if IsOnMobile then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/shiftlock"))()
	else
		EnableShiftLock()
	end
end)

cmd.add({"unshiftlock","unsl"}, {"unshiftlock (unsl)", "Disables shiftlock"}, function()
	if IsOnPC then
		DisableShiftLock()
	end
end)

-- if you're reading this use the command 'cmdloop enable' to enable the command loop
-- example 'cmdloop enable shiftlock hidden' (hides notification to display) or set hidden to just anything as long as argument 2 is not empty 💀

cmd.add({"enable"}, {"enable", "Enables a specific CoreGui"}, function(...)
	local args = {...}
	local enableName = args[1]
	local hiddenNotif = args[2] -- scuffed way lmao
	local buttons = {}

	for _, coreGuiType in ipairs(Enum.CoreGuiType:GetEnumItems()) do
		Insert(buttons, {
			Text = coreGuiType.Name,
			Callback = function()
				SafeGetService("StarterGui"):SetCoreGuiEnabled(coreGuiType, true)
				if coreGuiType == Enum.CoreGuiType.Chat or coreGuiType == Enum.CoreGuiType.All then
					loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/EnableChat.lua"))()
				end
			end
		})
	end

	Insert(buttons, {
		Text = "Shiftlock",
		Callback = function()
			LocalPlayer.DevEnableMouseLock = true
		end
	})

	Insert(buttons, {
		Text = "Reset",
		Callback = function()
			SafeGetService("StarterGui"):SetCore("ResetButtonCallback", true)
		end
	})

	if enableName and enableName ~= "" then
		local found = false
		for _, button in ipairs(buttons) do
			if Match(button.Text:lower(), enableName:lower()) then
				button.Callback()
				if not hiddenNotif then
					DebugNotif("CoreGui Enabled: "..button.Text.." has been enabled.", 3)
				end
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching CoreGui element found for: "..enableName, 3)
		end
	else
		Window({
			Title = "Enable a Specific Core Gui Element",
			Buttons = buttons
		})
	end
end, true)

cmd.add({"disable"}, {"disable", "Disables a specific CoreGui"}, function(...)
	local args = {...}
	local disableName = args[1]
	local hiddenNotif = args[2] -- scuffed way lmao
	local buttons = {}

	for _, coreGuiType in ipairs(Enum.CoreGuiType:GetEnumItems()) do
		Insert(buttons, {
			Text = coreGuiType.Name,
			Callback = function()
				SafeGetService("StarterGui"):SetCoreGuiEnabled(coreGuiType, false)
			end
		})
	end

	Insert(buttons, {
		Text = "Shiftlock",
		Callback = function()
			LocalPlayer.DevEnableMouseLock = false
		end
	})

	Insert(buttons, {
		Text = "Reset",
		Callback = function()
			SafeGetService("StarterGui"):SetCore("ResetButtonCallback", false)
		end
	})

	if disableName and disableName ~= "" then
		local found = false
		for _, button in ipairs(buttons) do
			if Match(button.Text:lower(), disableName:lower()) then
				button.Callback()
				if not hiddenNotif then
					DebugNotif("CoreGui Disabled: "..button.Text.." has been disabled.", 3)
				end
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching CoreGui element found for: "..disableName, 3)
		end
	else
		Window({
			Title = "Disable a Specific Core Gui Element",
			Buttons = buttons
		})
	end
end,true)

cmd.add({"reverb","reverbcontrol"},{"reverb (reverbcontrol)","Manage sound reverb settings"},function(...)
	local args = {...}
	local target = args[1]
	local buttons = {}
	for _, rt in ipairs(Enum.ReverbType:GetEnumItems()) do
		Insert(buttons, {
			Text = rt.Name,
			Callback = function()
				SafeGetService("SoundService").AmbientReverb = rt
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in ipairs(buttons) do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				DebugNotif("Reverb set to "..btn.Text, 3)
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching reverb type for: "..target, 3)
		end
	else
		Window({
			Title = "Sound Reverb Options",
			Buttons = buttons
		})
	end
end)

cmd.add({"cam","camera","cameratype"},{"cam (camera, cameratype)","Manage camera type settings"},function(...)
	local args = {...}
	local target = args[1]
	local buttons = {}
	for _, ct in ipairs(Enum.CameraType:GetEnumItems()) do
		Insert(buttons, {
			Text = ct.Name,
			Callback = function()
				workspace.CurrentCamera.CameraType = ct
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in ipairs(buttons) do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				DebugNotif("Camera type set to "..btn.Text, 3)
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching camera type for: "..target, 3)
		end
	else
		Window({
			Title = "Camera Type Options",
			Buttons = buttons
		})
	end
end)

alignmentButtonsGui = nil

cmd.add({"alignmentkeys","alignkeys","ak"},{"alignmentkeys","Enable alignment keys"}, function()
	local function onInput(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.Comma and workspace.CurrentCamera then
			workspace.CurrentCamera:PanUnits(-1)
		elseif input.KeyCode == Enum.KeyCode.Period and workspace.CurrentCamera then
			workspace.CurrentCamera:PanUnits(1)
		end
	end
	if not NAlib.isConnected("align_input") then
		NAlib.connect("align_input", UserInputService.InputBegan:Connect(onInput))
	end
	if IsOnMobile and not alignmentButtonsGui then
		alignmentButtonsGui = InstanceNew("ScreenGui")
		alignmentButtonsGui.Name = "AlignButtons"
		alignmentButtonsGui.ResetOnSpawn = false
		NaProtectUI(alignmentButtonsGui)

		local btnSize = UDim2.new(0.1, 0, 0.1, 0)

		local leftButton = InstanceNew("TextButton")
		leftButton.Name = "PanLeft"
		leftButton.Text = "<"
		leftButton.TextScaled = true
		leftButton.Size = btnSize
		leftButton.Position = UDim2.new(0.45, 0, 0.05, 0)
		leftButton.AnchorPoint = Vector2.new(0.5, 0.5)
		leftButton.BackgroundColor3 = Color3.new(0, 0, 0)
		leftButton.BorderSizePixel = 0
		leftButton.TextColor3 = Color3.new(1, 1, 1)
		leftButton.Parent = alignmentButtonsGui

		local leftUICorner = InstanceNew("UICorner")
		leftUICorner.CornerRadius = UDim.new(1, 0)
		leftUICorner.Parent = leftButton

		local rightButton = InstanceNew("TextButton")
		rightButton.Name = "PanRight"
		rightButton.Text = ">"
		rightButton.TextScaled = true
		rightButton.Size = btnSize
		rightButton.Position = UDim2.new(0.55, 0, 0.05, 0)
		rightButton.AnchorPoint = Vector2.new(0.5, 0.5)
		rightButton.BackgroundColor3 = Color3.new(0, 0, 0)
		rightButton.BorderSizePixel = 0
		rightButton.TextColor3 = Color3.new(1, 1, 1)
		rightButton.Parent = alignmentButtonsGui

		local rightUICorner = InstanceNew("UICorner")
		rightUICorner.CornerRadius = UDim.new(1, 0)
		rightUICorner.Parent = rightButton

		NAgui.draggerV2(leftButton)
		NAgui.draggerV2(rightButton)

		NAlib.connect("align_mobile_left", MouseButtonFix(leftButton,function()
			if workspace.CurrentCamera then
				workspace.CurrentCamera:PanUnits(-1)
			end
		end))
		NAlib.connect("align_mobile_right", MouseButtonFix(rightButton,function()
			if workspace.CurrentCamera then
				workspace.CurrentCamera:PanUnits(1)
			end
		end))
	end
end)

cmd.add({"disablealignmentkeys","disablealignkeys","dak"},{"disablealignmentkeys","Disable alignment keys"}, function()
	NAlib.disconnect("align_input")
	if IsOnMobile and alignmentButtonsGui then
		NAlib.disconnect("align_mobile_left")
		NAlib.disconnect("align_mobile_right")
		alignmentButtonsGui:Destroy()
		alignmentButtonsGui = nil
		mobileLeftConn = nil
		mobileRightConn = nil
	end
end)

cmd.add({"esp"}, {"esp", "locate where the players are"}, function()
	ESPenabled = true
	chamsEnabled = false
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name ~= Players.LocalPlayer.Name then
			NAESP(player,true)
		end
	end
end)

cmd.add({"chams"}, {"chams", "ESP but without the text :shock:"}, function()
	ESPenabled = true
	chamsEnabled = true
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name ~= Players.LocalPlayer.Name then
			NAESP(player,true)
		end
	end
end)

cmd.add({"locate"}, {"locate <username1> <username2> etc (optional)", "locate where the specified player(s) are"}, function(...)
	local usernames = {...}
	for _, username in ipairs(usernames) do
		local target = getPlr(username)
		for _, plr in ipairs(target) do
			if plr then
				NAESP(plr, true)
			end
		end
	end
end, true)

NPC_SCAN_KEY = "npc_esp_scan"
getgenv().npcESPList = {}

cmd.add({"npcesp","espnpc"},{"npcesp (espnpc)","locate where the npcs are"},function()
	ESPenabled = true
	chamsEnabled = false
	getgenv().npcESPList = {}
	if not NAlib.isConnected(NPC_SCAN_KEY) then
		local accumulator = 0
		NAlib.connect(NPC_SCAN_KEY,RunService.Heartbeat:Connect(function(dt)
			accumulator = accumulator + dt
			if accumulator < 0.5 then return end
			accumulator = 0
			local found = {}
			for _,inst in ipairs(workspace:GetDescendants()) do
				if inst:IsA("Model") then
					local h = getPlrHum(inst)
					local root = getRoot(inst)
					if h and not Players:GetPlayerFromCharacter(inst) and root then
						found[inst] = true
						if not getgenv().npcESPList[inst] then
							getgenv().npcESPList[inst] = true
							NAESP(inst,false)
						end
					end
				end
			end
			for inst in pairs(getgenv().npcESPList) do
				if not found[inst] then
					getgenv().npcESPList[inst] = nil
					discPlrESP(inst)
				end
			end
		end))
	end
end)

cmd.add({"unnpcesp","unespnpc"},{"unnpcesp (unespnpc)","stop locating npcs"},function()
	ESPenabled = false
	chamsEnabled = false
	if NAlib.isConnected(NPC_SCAN_KEY) then
		NAlib.disconnect(NPC_SCAN_KEY)
	end
	for inst in pairs(getgenv().npcESPList) do
		discPlrESP(inst)
	end
	getgenv().npcESPList = {}
end)

cmd.add({"unesp","unchams"},{"unesp (unchams)","Disables esp/chams"},function()
	ESPenabled   = false
	chamsEnabled = false
	if NAlib.isConnected(NPC_SCAN_KEY) then
		NAlib.disconnect(NPC_SCAN_KEY)
	end
	removeAllESP()
end)

cmd.add({"unlocate"},{"unlocate <username1> <username2>"},function(...)
	for _, name in ipairs({...}) do
		for _, plr in ipairs(getPlr(name)) do
			discPlrESP(plr)
		end
	end
end, true)

cmd.add({"crash"},{"crash","crashes ur client lol (why would you even use this tho)"},function()
	while true do end
end)

VVVVVVVVVVVCARRR = {}

cmd.add({"vehiclenoclip", "vnoclip"}, {"vehiclenoclip (vnoclip)", "Disables vehicle collision"}, function()
	VVVVVVVVVVVCARRR = {}

	local hum = getHum()
	if not hum then return DoNotif("no humanoid found",2) end
	local seat = hum and hum.SeatPart

	local model = seat.Parent
	while model and not model:IsA("Model") do
		model = model.Parent
	end

	Wait(0.1)
	cmd.run({"noclip"})

	for _, pp in ipairs(model:GetDescendants()) do
		if pp:IsA("BasePart") and pp.CanCollide then
			Insert(VVVVVVVVVVVCARRR, pp)
			pp.CanCollide = false
		end
	end
end)

cmd.add({"vehicleclip", "vclip", "unvnoclip", "unvehiclenoclip"}, {"vehicleclip (vclip, unvnoclip, unvehiclenoclip)", "Enables vehicle collision"}, function()
	cmd.run({"clip"})

	for _, pppp in ipairs(VVVVVVVVVVVCARRR) do
		if pppp and pppp:IsA("BasePart") then
			pppp.CanCollide = true
		end
	end

	VVVVVVVVVVVCARRR = {}
end)

cmd.add({"handlekill", "hkill"}, {"handlekill <player> (hkill)", "Kills a player using a tool that deals damage on touch"}, function(...)
	local Players = SafeGetService("Players")
	local LocalPlayer = Players.LocalPlayer

	if not firetouchinterest then
		return DoNotif('Your exploit does not support firetouchinterest to run this command')
	end

	local function zeTOOL()
		local character = LocalPlayer.Character
		if not character then return nil, nil end
		local tool = character:FindFirstChildWhichIsA("Tool")
		if not tool then return nil, nil end
		local handle = tool:FindFirstChild("Handle")
		return tool, handle
	end

	local Tool, Handle = zeTOOL()
	if not Tool or not Handle then
		return DoNotif('You need to hold a "Tool" that does damage on touch')
	end

	local username = ...
	local targets = getPlr(username)
	if #targets == 0 then
		return DoNotif("No target found",2)
	end

	for _, targetPlayer in ipairs(targets) do
		Spawn(function()
			while Tool and getPlrChar(LocalPlayer) and getPlrChar(targetPlayer) and Tool.Parent == LocalPlayer.Character do
				local humanoid = getPlrHum(targetPlayer)
				if not humanoid or humanoid.Health <= 0 then
					break
				end

				for _, part in ipairs(getPlrChar(targetPlayer):GetChildren()) do
					if part:IsA("BasePart") then
						firetouchinterest(Handle, part, 0)
						Wait()
						firetouchinterest(Handle, part, 1)
					end
				end

				RunService.Stepped:Wait()
			end
		end)
	end
end, true)

cmd.add({"creep"}, {"creep <player>", "Teleports from a player behind them and under the floor to the top"}, function(...)
	local username = ...
	local targets = getPlr(username)
	if #targets == 0 then
		DoNotif("No target found.", 3)
		return
	end

	local target = targets[1]
	local character = getChar()
	if not character then
		DoNotif("Your character is invalid.", 3)
		return
	end

	local root = getRoot(character)
	if not root then
		DoNotif("Your character's root is invalid.", 3)
		return
	end

	if not target.Character or not getPlrHum(target) or not getPlrHum(target).RootPart then
		DoNotif("Target's character is invalid.", 3)
		return
	end

	root.CFrame = getPlrHum(target).RootPart.CFrame * CFrame.new(0, -10, 4)
	Wait()

	if NAlib.isConnected("noclip") then
		NAlib.disconnect("noclip")
	end

	NAlib.connect("noclip", RunService.Stepped:Connect(function()
		local char = getChar()
		if not char then return end
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end))
	Wait()

	root.Anchored = true
	Wait()

	local tweenService = TweenService
	local tweenInfo = TweenInfo.new(1000, Enum.EasingStyle.Linear)
	local tween = tweenService:Create(root, tweenInfo, {CFrame = CFrame.new(0, 10000, 0)})
	tween:Play()
	Wait(1.5)
	tween:Pause()

	root.Anchored = false
	Wait()

	NAlib.disconnect("noclip")
end, true)

cmd.add({"netless","net"},{"netless (net)","Executes netless which makes scripts more stable"},function()
	for i,v in next,getChar():GetDescendants() do
		if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
			RunService.Stepped:Connect(function()
				v.Velocity=Vector3.new(-30,0,0)
			end)
		end
	end

	Wait();

	DebugNotif("Netless has been activated,re-run this script if you die")
end)

cmd.add({"reset","die"},{"reset (die)","Makes your health be 0"},function()
	getHum():ChangeState(Enum.HumanoidStateType.Dead)
	getHum().Health=0
end)

local damageMessages = {
	"Ouch!", "Ow!", "Aw!", "That hurt!", "Yikes!", "Gah!", "Nooo!",
	"Stop that!", "Bruh...", "Hmph!", "I felt that!", "What the–?!", "My pixels!", "Dang!",
	"Seriously?", "Try that again!", "Cut it out!", "That was rude!"
}

cmd.add({"damagechat", "dmgchat", "painchat"}, {"damagechat (dmgchat, painchat)", "Toggles chat message when you take damage"}, function()
	local humanoid = getHum()

	if not humanoid then
		DoNotif("Humanoid not found", 2)
		return
	end

	local connName = "damagechat"

	if NAlib.isConnected(connName) then
		NAlib.disconnect(connName)
		DoNotif("Disabled", 2)
		return
	end

	local lastHealth = humanoid.Health

	NAlib.connect(connName, humanoid.HealthChanged:Connect(function(newHealth)
		if newHealth < lastHealth then
			local msg = damageMessages[math.random(1, #damageMessages)]
			NAlib.LocalPlayerChat(msg, "All")
		end
		lastHealth = newHealth
	end))

	DebugNotif("Enabled", 2)
end)

cmd.add({"undamagechat", "undmgchat", "unpainchat"}, {"undamagechat (undmgchat, unpainchat)", "Disables damage reaction chat"}, function()
	if NAlib.isConnected("damagechat") then
		NAlib.disconnect("damagechat")
		DebugNotif("Disabled", 2)
	else
		DebugNotif("Already disabled", 2)
	end
end)

cmd.add({"runanim", "playanim", "anim"}, {"runanim <id> [speed] (playanim,anim)", "Plays an animation by ID with optional speed multiplier"}, function(id, speed)
	local hum = getHum()
	if not hum then return end
	id = tostring(id)
	speed = tonumber(speed) or 1
	local animator = hum:FindFirstChildOfClass("Animator") or InstanceNew("Animator", hum)
	local anim = InstanceNew("Animation")
	anim.AnimationId = "rbxassetid://"..id
	local track = animator:LoadAnimation(anim)
	track:Play()
	track:AdjustSpeed(speed)
	Delay(track.Length / speed, function()
		track:Stop()
		track:Destroy()
		anim:Destroy()
	end)
end, true)

local storedAnims = {}
builderAnim = nil

cmd.add({"animbuilder","abuilder"},{"animbuilder (abuilder)","Opens animation builder GUI"},function()
	if builderAnim then NACaller(function() builderAnim:Destroy() end) builderAnim = nil end

	local function getData()
		local hum = getHum()
		if not hum then return end
		local animate = hum.Parent:FindFirstChild("Animate")
		if not animate then return end
		return hum, animate
	end

	local p = LocalPlayer
	local uid = p.UserId
	if not storedAnims[uid] then
		local hum0, animate0 = getData()
		if not animate0 then return end
		local store = {}
		for _, v in pairs(animate0:GetChildren()) do
			if v:IsA("StringValue") then
				local a = v:FindFirstChildWhichIsA("Animation")
				if a then store[v.Name] = a.AnimationId end
			end
		end
		storedAnims[uid] = store
	end

	builderAnim = InstanceNew("ScreenGui")
	NaProtectUI(builderAnim)

	local m = InstanceNew("Frame", builderAnim)
	local fullW, fullH = 420, 515
	m.Size = UDim2.new(0, fullW, 0, fullH)
	m.Position = UDim2.new(0.5, -fullW/2, 0.5, -fullH/2)
	m.BackgroundColor3 = Color3.fromRGB(30,30,30)
	m.BackgroundTransparency = 0.4
	m.ClipsDescendants = true
	InstanceNew("UICorner", m).CornerRadius = UDim.new(0,12)

	local title = InstanceNew("TextLabel", m)
	title.Size = UDim2.new(1,0,0,30)
	title.Position = UDim2.new(0,0,0,0)
	title.BackgroundTransparency = 1
	title.Text = "Animation Builder"
	title.TextSize = 20
	title.Font = Enum.Font.SourceSansSemibold
	title.TextColor3 = Color3.new(1,1,1)

	local x = InstanceNew("TextButton", m)
	x.Size = UDim2.new(0,30,0,30)
	x.Position = UDim2.new(1,-35,0,2)
	x.Text = "X"
	x.Font = Enum.Font.SourceSansBold
	x.TextSize = 18
	x.BackgroundColor3 = Color3.fromRGB(200,50,50)
	x.BackgroundTransparency = 0.5
	InstanceNew("UICorner", x).CornerRadius = UDim.new(0,8)
	x.MouseButton1Click:Connect(function() NACaller(builderAnim.Destroy, builderAnim) builderAnim = nil end)

	local states = {"Idle","Walk","Run","Jump","Fall","Climb","Swim","Sit"}
	local tb = {}
	for i, k in ipairs(states) do
		local r = InstanceNew("Frame", m)
		r.Size = UDim2.new(1,-20,0,50)
		r.Position = UDim2.new(0,10,0,40 + (i-1)*55)
		r.BackgroundColor3 = Color3.fromRGB(50,50,50)
		r.BackgroundTransparency = 0.3
		InstanceNew("UICorner", r).CornerRadius = UDim.new(0,10)

		local l = InstanceNew("TextLabel", r)
		l.Text = k
		l.Size = UDim2.new(0.3,0,1,0)
		l.Position = UDim2.new(0,10,0,0)
		l.BackgroundTransparency = 1
		l.TextSize = 16
		l.Font = Enum.Font.SourceSans
		l.TextColor3 = Color3.new(1,1,1)
		l.TextXAlignment = Enum.TextXAlignment.Left

		local te = InstanceNew("TextBox", r)
		te.PlaceholderText = "Insert ID"
		te.Text = ""
		te.ClearTextOnFocus = false
		te.Size = UDim2.new(0.7,-20,0,30)
		te.Position = UDim2.new(0.3,10,0,10)
		te.BackgroundColor3 = Color3.fromRGB(70,70,70)
		te.BackgroundTransparency = 0.2
		te.TextSize = 16
		te.Font = Enum.Font.SourceSans
		te.TextColor3 = Color3.new(1,1,1)
		InstanceNew("UICorner", te).CornerRadius = UDim.new(0,8)
		te:GetPropertyChangedSignal("Text"):Connect(function()
			local clean = te.Text:gsub('%D','') if te.Text~=clean then te.Text=clean end
		end)
		tb[Lower(k)] = te
	end

	local btnY = fullH - 45
	local save = InstanceNew("TextButton", m)
	save.Size = UDim2.new(0.48,0,0,40)
	save.Position = UDim2.new(0.02,0,0,btnY)
	save.Text = "Save"
	save.TextSize = 18
	save.Font = Enum.Font.SourceSansSemibold
	save.BackgroundColor3 = Color3.fromRGB(80,160,80)
	save.BackgroundTransparency = 0.2
	InstanceNew("UICorner", save).CornerRadius = UDim.new(0,10)

	local revert = InstanceNew("TextButton", m)
	revert.Size = UDim2.new(0.48,0,0,40)
	revert.Position = UDim2.new(0.5,0,0,btnY)
	revert.Text = "Revert"
	revert.TextSize = 18
	revert.Font = Enum.Font.SourceSansSemibold
	revert.BackgroundColor3 = Color3.fromRGB(160,80,80)
	revert.BackgroundTransparency = 0.2
	InstanceNew("UICorner", revert).CornerRadius = UDim.new(0,10)

	local function applyAnims(mode)
		local hum, animate = getData()
		if not animate then return end
		for _, k in ipairs(states) do
			local e = tb[Lower(k)]
			if mode == "save" then
				local id = tonumber(e.Text)
				if id then local o = animate:FindFirstChild(k:lower())
					if o and o:IsA("StringValue") then local a = o:FindFirstChildWhichIsA("Animation") if a then a.AnimationId = "rbxassetid://"..id end end
				end
			else
				local raw = storedAnims[uid] and storedAnims[uid][k:lower()]
				if raw then local num = raw:match('%d+') if num then local orig = tonumber(num)
						if orig then local o = animate:FindFirstChild(k:lower())
							if o and o:IsA("StringValue") then local a = o:FindFirstChildWhichIsA("Animation") if a then a.AnimationId = raw end end
							tb[Lower(k)].Text = tostring(orig)
						end
					end
				end
			end
		end
	end
	save.MouseButton1Click:Connect(function() applyAnims("save") end)
	revert.MouseButton1Click:Connect(function() applyAnims("revert") end)
	NAgui.dragger(m)
end)

cmd.add({"setkiller", "killeranim"}, {"setkiller (killeranim)", "Sets killer animation set"}, function()
	if not IsR6() then DoNotif("command requires R6") return end
	local hum = getHum()
	if not hum then return end

	local animate = hum.Parent:FindFirstChild("Animate")
	if not animate then return end

	if not storedAnims[hum] then
		local store = {}
		for _, obj in pairs(animate:GetChildren()) do
			if obj:IsA("StringValue") then
				local anim = obj:FindFirstChildWhichIsA("Animation")
				if anim then
					store[obj.Name] = anim.AnimationId
				end
			end
		end
		storedAnims[hum] = store
	end

	local function setAnim(name, id)
		local obj = animate:FindFirstChild(name)
		if obj and obj:IsA("StringValue") then
			local anim = obj:FindFirstChildWhichIsA("Animation")
			if anim then
				anim.AnimationId = "rbxassetid://"..tostring(id)
			end
		end
	end

	setAnim("walk", 252557606)
	setAnim("run", 252557606)
	setAnim("jump", 165167557)
	setAnim("fall", 97170520)
end)

cmd.add({"setpsycho", "psychoanim"}, {"setpsycho (psychoanim)", "Sets psycho animation set"}, function()
	if not IsR6() then DoNotif("command requires R6") return end
	local hum = getHum()
	if not hum then return end

	local animate = hum.Parent:FindFirstChild("Animate")
	if not animate then return end

	if not storedAnims[hum] then
		local store = {}
		for _, obj in pairs(animate:GetChildren()) do
			if obj:IsA("StringValue") then
				local anim = obj:FindFirstChildWhichIsA("Animation")
				if anim then
					store[obj.Name] = anim.AnimationId
				end
			end
		end
		storedAnims[hum] = store
	end

	local function setAnim(name, id)
		local obj = animate:FindFirstChild(name)
		if obj and obj:IsA("StringValue") then
			local anim = obj:FindFirstChildWhichIsA("Animation")
			if anim then
				anim.AnimationId = "rbxassetid://"..tostring(id)
			end
		end
	end

	setAnim("idle", 33796059)
	setAnim("walk", 95415492)
	setAnim("run", 95415492)
	setAnim("jump", 165167557)
	setAnim("fall", 97170520)

	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then return end

	Spawn(function()
		while hum and hum.Parent and hum.Health > 0 do
			for _, track in pairs(animator:GetPlayingAnimationTracks()) do
				if track.Animation.AnimationId == "rbxassetid://33796059" and track.Speed < 50 then
					track:AdjustSpeed(50)
				end
			end
			Wait(0.2)
		end
	end)
end)

cmd.add({"resetanims", "defaultanims", "animsreset"}, {"resetanims (defaultanims,animsreset)", "Restores your previous animations"}, function()
	if not IsR6() then DoNotif("command requires R6") return end
	local hum = getHum()
	if not hum then return end

	local animate = hum.Parent:FindFirstChild("Animate")
	if not animate then return end

	local store = storedAnims[hum]
	if not store then return end

	for name, id in pairs(store) do
		local obj = animate:FindFirstChild(name)
		if obj and obj:IsA("StringValue") then
			local anim = obj:FindFirstChildWhichIsA("Animation")
			if anim then
				anim.AnimationId = id
			end
		end
	end

	storedAnims[hum] = nil
end)

cmd.add({"bubblechat","bchat"},{"bubblechat (bchat)","Enables BubbleChat"},function()
	TextChatService.BubbleChatConfiguration.Enabled = true
end)

cmd.add({"unbubblechat","unbchat"},{"unbubblechat (unbchat)","Disabled BubbleChat"},function()
	TextChatService.BubbleChatConfiguration.Enabled = false
end)

cmd.add({"saveinstance","savegame"},{"saveinstance (savegame)","if it bugs out try removing stuff from your AutoExec folder"},function()
	--saveinstance({})
	local Params={
		RepoURL="https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
		SSI="saveinstance",
	}
	local synsaveinstance=loadstring(game:HttpGet(Params.RepoURL..Params.SSI..".luau",true),Params.SSI)()
	local Options={}
	if identifyexecutor()=="Fluxus" then
		Options={ IgnoreSpecialProperties=true }
	end
	synsaveinstance(Options)
end)

cmd.add({"admin","whitelist"},{"admin <player>","Whitelist the user to have access to *your* client-side commands, anything they type runs on *you*, not on themselves"},function(...)
	function ChatMessage(Message,Whisper)
		NAlib.LocalPlayerChat(Message,Whisper or "All")
	end
	local Player=getPlr(...)
	for _, plr in next, Player do
		if plr~=nil and not Admin[plr.UserId] then
			Admin[plr.UserId]={plr=plr}
			ChatMessage("["..adminName.."] You've got admin. Prefix: ';'",plr.Name)
			Wait(0.2)
			DoNotif(nameChecker(plr).." has now been whitelisted to use commands",15)
		else
			DoNotif("No player found")
		end
	end
end,true)

cmd.add({"unadmin"},{"unadmin <player>","removes someone from being admin"},function(...)
	function ChatMessage(Message,Whisper)
		NAlib.LocalPlayerChat(Message,Whisper or "All")
	end
	local Player=getPlr(...)
	for _, plr in next, Player do
		if plr~=nil and Admin[plr.UserId] then
			Admin[plr.UserId]=nil
			ChatMessage("You can no longer use commands",plr.Name)
			DoNotif(nameChecker(plr).." is no longer an admin",15)
		else
			DoNotif("Player not found")
		end
	end
end,true)

cmd.add({"partname","partpath","partgrabber"},{"partname (partpath,partgrabber)","gives a ui and allows you click on a part to grab it's path"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/PartGrabber.lua"))()
end)

-- patched (womp)
--[[cmd.add({"backdoor","backdoorscan"},{"backdoor (backdoorscan)","Scans for any backdoors using FraktureSS"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Frakture"))()
end)]]

cmd.add({"jobid"},{"jobid","Copies your job id"},function()
	if setclipboard then
		setclipboard(tostring(JobId))
		Wait();

		DebugNotif("Copied your jobid ("..JobId..")")
	else
		DoNotif("Your executor does not support setclipboard")
	end
end)

cmd.add({"joinjobid","joinjid","jjobid","jjid"},{"joinjobid <jobid> (joinjid,jjobid,jjid)","Joins the job id you put in"},function(...)
	zeId={...}
	id=zeId[1]
	TeleportService:TeleportToPlaceInstance(PlaceId,id)
end,true)

cmd.add({"serverhop","shop"},{"serverhop (shop)","serverhop"},function()
	Wait();

	DebugNotif("Searching")
	local Number=0
	local SomeSRVS={}
	local found=0
	for _,v in ipairs(HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v)=="table" and v.maxPlayers>v.playing and v.id~=JobId then
			if v.playing>Number then
				Number=v.playing
				SomeSRVS[1]=v.id
				found=v.playing
			end
		end
	end
	if #SomeSRVS>0 then
		DebugNotif("serverhopping | Player Count: "..found)
		TeleportService:TeleportToPlaceInstance(PlaceId,SomeSRVS[1])
	end
end)

cmd.add({"smallserverhop","sshop"},{"smallserverhop (sshop)","serverhop to a small server"},function()
	Wait();

	DebugNotif("Searching")

	local Number=math.huge
	local SomeSRVS={}
	local found=0

	for _,v in ipairs(HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data) do
		if type(v)=="table" and v.maxPlayers>v.playing and v.id~=JobId then
			if v.playing<Number then
				Number=v.playing
				SomeSRVS[1]=v.id
				found=v.playing
			end
		end
	end

	if #SomeSRVS>0 then
		DebugNotif("serverhopping | Player Count: "..found)
		TeleportService:TeleportToPlaceInstance(PlaceId,SomeSRVS[1])
	end
end)

cmd.add({"pingserverhop","pshop"},{"pingserverhop (pshop)","serverhop to a server with the best ping"},function()
	Wait();

	DebugNotif("Searching for server with best ping")

	local Servers = JSONDecode(HttpService, game:HttpGetAsync("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
	local BestPing = math.huge
	local BestJobId = nil

	if Servers and #Servers > 0 then
		for _, Server in next, Servers do
			if type(Server) == "table" and Server.id ~= JobId then
				local ping = Server.ping
				if ping and ping < BestPing then
					BestPing = ping
					BestJobId = Server.id
				end
			end
		end
	end

	if BestJobId then
		DebugNotif(Format("Serverhopping to server with ping: %s ms", tostring(BestPing)))
		TeleportService:TeleportToPlaceInstance(PlaceId, BestJobId)
	else
		DebugNotif("No better server found")
	end
end)

if askndnijewfijewongf~=zmxcnsaodakscn then
	uhefwewufjodwcijdscsauasd = [[DSh+f,nTG$I)I^XiuM=Cq/"@gC%M7Lpoi5(IN:%N2$>+lEFg*ibg2+DZM%Z%xEZk6l_1.yFZ,$n0KFBMl5VKR[9`aIEv*.Zkm5!fW*pT<R>xl.`otoW3)*1;eI(/e95p)z9Kt)b13$)&!Oqm?in<R[4G6!Y64^jmjaU=t60eM%10Evap#GLaWc.!k9Q6HXQDPO$JmJ>y1BFv;mdQZuH<!=6i6U<xhQQn%X4Dw.Z;;RPKqxfd)z^g^*VvAGe!wP!j$2wZqgG{s!m!xwXikPG3]0RT@SSmw,9j$2,<8==/x#h.FQ_o2X=CY<=Hb%zt]m9j44!f,W#Ny#V6JQKm(nFfe,ueb%6t?vqmxoh+i>;Nt!fpgPcLtoef4WQIb%a%sQFl,X;a4W5vwS60nuWogP=Cf><clTy]]
	oioji32eipqpaofvofsiv = randomahhfunctionthatyouwontgetit(uhefwewufjodwcijdscsauasd)
	return loadstring(oioji32eipqpaofvofsiv)()
end

cmd.add({"autorejoin", "autorj"}, {"autorejoin (autorj)", "Rejoins the server if you get kicked / disconnected"}, function()
	NAlib.disconnect("autorejoin")

	local function handleRejoin()
		if #Players:GetPlayers() <= 1 then
			Players.LocalPlayer:Kick("Rejoining...")
			Wait(.05)
			TeleportService:Teleport(PlaceId, Players.LocalPlayer)
		else
			TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
		end
	end

	NAlib.connect("autorejoin", SafeGetService("GuiService").ErrorMessageChanged:Connect(function()
		Spawn(handleRejoin)
	end))

	DebugNotif("Auto Rejoin is now enabled!")
end)

cmd.add({"unautorejoin", "unautorj"}, {"unautorejoin (unautorj)", "Disables auto rejoin command"}, function()
	if NAlib.isConnected("autorejoin") then
		NAlib.disconnect("autorejoin")
		DebugNotif("Auto Rejoin is now disabled!")
	else
		DebugNotif("Auto Rejoin is already disabled!")
	end
end)

cmd.add({"functionspy"},{"functionspy","Check console"},function()
	local toLog={
		debug.getconstants;
		getconstants;
		debug.getconstant;
		getconstant;
		debug.setconstant;
		setconstant;
		debug.getupvalues;
		debug.getupvalue;
		getupvalues;
		getupvalue;
		debug.setupvalue;
		setupvalue;
		getsenv;
		getreg;
		getgc;
		getconnections;
		firesignal;
		fireclickdetector;
		fireproximityprompt;
		firetouchinterest;
		gethiddenproperty;
		sethiddenproperty;
		hookmetamethod;
		setnamecallmethod;
		getrawmetatable;
		setrawmetatable;
		setreadonly;
		isreadonly;
		debug.setmetatable;
	}

	local FunctionSpy=InstanceNew("ScreenGui")
	local Main=InstanceNew("Frame")
	local LeftPanel=InstanceNew("ScrollingFrame")
	local UIListLayout=InstanceNew("UIListLayout")
	local example=InstanceNew("TextButton")
	local name=InstanceNew("TextLabel")
	local UIPadding=InstanceNew("UIPadding")
	local FakeTitle=InstanceNew("TextButton")
	local Title=InstanceNew("TextLabel")
	local clear=InstanceNew("ImageButton")
	local RightPanel=InstanceNew("ScrollingFrame")
	local output=InstanceNew("TextLabel")
	local clear_2=InstanceNew("TextButton")
	local copy=InstanceNew("TextButton")

	NaProtectUI(FunctionSpy)
	FunctionSpy.Name="FunctionSpy"
	FunctionSpy.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

	Main.Name="Main"
	Main.Parent=FunctionSpy
	Main.BackgroundColor3=Color3.fromRGB(33,33,33)
	Main.BorderSizePixel=0
	Main.Position=UDim2.new(0,10,0,36)
	Main.Size=UDim2.new(0,536,0,328)

	LeftPanel.Name="LeftPanel"
	LeftPanel.Parent=Main
	LeftPanel.Active=true
	LeftPanel.BackgroundColor3=Color3.fromRGB(45,45,45)
	LeftPanel.BorderSizePixel=0
	LeftPanel.Size=UDim2.new(0.349999994,0,1,0)
	LeftPanel.CanvasSize=UDim2.new(0,0,0,0)
	LeftPanel.HorizontalScrollBarInset=Enum.ScrollBarInset.ScrollBar
	LeftPanel.ScrollBarThickness=3

	UIListLayout.Parent=LeftPanel
	UIListLayout.SortOrder=Enum.SortOrder.LayoutOrder
	UIListLayout.Padding=UDim.new(0,7)

	example.Name="example"
	example.Parent=LeftPanel
	example.BackgroundColor3=Color3.fromRGB(31,31,31)
	example.BorderSizePixel=0
	example.Position=UDim2.new(4.39481269e-08,0,0,0)
	example.Size=UDim2.new(0,163,0,19)
	example.Visible=false
	example.Font=Enum.Font.SourceSans
	example.Text=""
	example.TextColor3=Color3.fromRGB(0,0,0)
	example.TextSize=14.000
	example.TextXAlignment=Enum.TextXAlignment.Left

	name.Name="name"
	name.Parent=example
	name.BackgroundColor3=Color3.fromRGB(255,255,255)
	name.BackgroundTransparency=1.000
	name.BorderSizePixel=0
	name.Position=UDim2.new(0,10,0,0)
	name.Size=UDim2.new(1,-10,1,0)
	name.Font=Enum.Font.SourceSans
	name.TextColor3=Color3.fromRGB(255,255,255)
	name.TextSize=14.000
	name.TextXAlignment=Enum.TextXAlignment.Left

	UIPadding.Parent=LeftPanel
	UIPadding.PaddingBottom=UDim.new(0,7)
	UIPadding.PaddingLeft=UDim.new(0,7)
	UIPadding.PaddingRight=UDim.new(0,7)
	UIPadding.PaddingTop=UDim.new(0,7)

	FakeTitle.Name="FakeTitle"
	FakeTitle.Parent=Main
	FakeTitle.BackgroundColor3=Color3.fromRGB(40,40,40)
	FakeTitle.BorderSizePixel=0
	FakeTitle.Position=UDim2.new(0,225,0,-26)
	FakeTitle.Size=UDim2.new(0.166044772,0,0,26)
	FakeTitle.Font=Enum.Font.GothamMedium
	FakeTitle.Text="FunctionSpy"
	FakeTitle.TextColor3=Color3.fromRGB(255,255,255)
	FakeTitle.TextSize=14.000

	Title.Name="Title"
	Title.Parent=Main
	Title.BackgroundColor3=Color3.fromRGB(40,40,40)
	Title.BorderSizePixel=0
	Title.Position=UDim2.new(0,0,0,-26)
	Title.Size=UDim2.new(1,0,0,26)
	Title.Font=Enum.Font.GothamMedium
	Title.Text="FunctionSpy"
	Title.TextColor3=Color3.fromRGB(255,255,255)
	Title.TextSize=14.000
	Title.TextWrapped=true

	clear.Name="clear"
	clear.Parent=Title
	clear.BackgroundTransparency=1.000
	clear.Position=UDim2.new(1,-28,0,2)
	clear.Size=UDim2.new(0,24,0,24)
	clear.ZIndex=2
	clear.Image=getcustomasset and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.Sheet) or "rbxassetid://3926305904"
	clear.ImageRectOffset=Vector2.new(924,724)
	clear.ImageRectSize=Vector2.new(36,36)

	RightPanel.Name="RightPanel"
	RightPanel.Parent=Main
	RightPanel.Active=true
	RightPanel.BackgroundColor3=Color3.fromRGB(35,35,35)
	RightPanel.BorderSizePixel=0
	RightPanel.Position=UDim2.new(0.349999994,0,0,0)
	RightPanel.Size=UDim2.new(0.649999976,0,1,0)
	RightPanel.CanvasSize=UDim2.new(0,0,0,0)
	RightPanel.HorizontalScrollBarInset=Enum.ScrollBarInset.ScrollBar
	RightPanel.ScrollBarThickness=3

	output.Name="output"
	output.Parent=RightPanel
	output.BackgroundColor3=Color3.fromRGB(255,255,255)
	output.BackgroundTransparency=1.000
	output.BorderColor3=Color3.fromRGB(27,42,53)
	output.BorderSizePixel=0
	output.Position=UDim2.new(0,10,0,10)
	output.Size=UDim2.new(1,-10,0.75,-10)
	output.Font=Enum.Font.GothamMedium
	output.Text=""
	output.TextColor3=Color3.fromRGB(255,255,255)
	output.TextSize=14.000
	output.TextXAlignment=Enum.TextXAlignment.Left
	output.TextYAlignment=Enum.TextYAlignment.Top

	clear_2.Name="clear"
	clear_2.Parent=RightPanel
	clear_2.BackgroundColor3=Color3.fromRGB(30,30,30)
	clear_2.BorderSizePixel=0
	clear_2.Position=UDim2.new(0.0631457642,0,0.826219559,0)
	clear_2.Size=UDim2.new(0,140,0,33)
	clear_2.Font=Enum.Font.SourceSans
	clear_2.Text="Clear logs"
	clear_2.TextColor3=Color3.fromRGB(255,255,255)
	clear_2.TextSize=14.000

	copy.Name="copy"
	copy.Parent=RightPanel
	copy.BackgroundColor3=Color3.fromRGB(30,30,30)
	copy.BorderSizePixel=0
	copy.Position=UDim2.new(0.545350134,0,0.826219559,0)
	copy.Size=UDim2.new(0,140,0,33)
	copy.Font=Enum.Font.SourceSans
	copy.Text="Copy info"
	copy.TextColor3=Color3.fromRGB(255,255,255)
	copy.TextSize=14.000

	--Scripts:

	function AKIHDI_fake_script()
		_G.functionspy={
			instance=Main.Parent;
			logging=true;
			connections={};
		}

		_G.functionspy.shutdown=function()
			for i,v in pairs(_G.functionspy.connections) do
				v:Disconnect()
			end
			_G.functionspy.connections={}
			_G.functionspy=nil
			Main.Parent:Destroy()
		end

		local connections={}

		local currentInfo=nil

		function log(name,text)
			local btn=Main.LeftPanel.example:Clone()
			btn.Parent=Main.LeftPanel
			btn.Name=name
			btn.name.Text=name
			btn.Visible=true
			Insert(connections,btn.MouseButton1Click:Connect(function()
				Main.RightPanel.output.Text=text
				currentInfo=text
			end))
		end

		Main.RightPanel.copy.MouseButton1Click:Connect(function()
			if currentInfo~=nil then
				setclipboard(tostring(currentInfo))
			end
		end)

		Main.RightPanel.clear.MouseButton1Click:Connect(function()
			for i,v in pairs(connections) do
				v:Disconnect()
			end
			for i,v in pairs(Main.LeftPanel:GetDescendants()) do
				if v:IsA("TextButton") and v.Visible==true then
					v:Destroy()
				end
			end
			Main.RightPanel.output.Text=""
			currentInfo=nil
		end)

		local hooked={}
		local Seralize=loadstring(game:HttpGet('https://api.irisapp.ca/Scripts/SeralizeTable.lua',true))()
		for i,v in next,toLog do
			if type(v)=="string" then
				local suc,err=NACaller(function()
					local func=loadstring("return "..v)()
					hooked[i]=hookfunction(func,function(...)
						local args={...}
						if _G.functionspy then
							NACaller(function()
								out=""
								out=out..(v..",Args-> {")..("\n"):format()
								for l,k in pairs(args) do
									if type(k)=="function" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Name-> "..getinfo(k).name)..("\n"):format()
									elseif type(k)=="table" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Data-> "..Seralize(k))..("\n"):format()
									elseif type(k)=="boolean" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k).."-> "..type(k))..("\n"):format()
									elseif type(k)=="nil" then
										out=out..("    ["..tostring(l).."] null")..("\n"):format()
									elseif type(k)=="number" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									else
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									end
								end
								out=out..("},Result-> "..tostring(nil))..("\n"):format()
								if _G.functionspy.logging==true then
									log(v,out)
								end
							end)
						end
						return hooked[i](...)
					end)
				end)
				if not suc then
					warn("Something went wrong while hooking "..v..". Error: "..err)
				end
			elseif type(v)=="function" then
				local suc,err=NACaller(function()
					hooked[i]=hookfunction(v,function(...)
						local args={...}
						if _G.functionspy then
							NACaller(function() 
								out=""
								out=out..(getinfo(v).name..",Args-> {")..("\n"):format()
								for l,k in pairs(args) do
									if type(k)=="function" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Name-> "..getinfo(k).name)..("\n"):format()
									elseif type(k)=="table" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Data-> "..Seralize(k))..("\n"):format()
									elseif type(k)=="boolean" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k).."-> "..type(k))..("\n"):format()
									elseif type(k)=="nil" then
										out=out..("    ["..tostring(l).."] null")..("\n"):format()
									elseif type(k)=="number" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									else
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									end
								end
								out=out..("},Result-> "..tostring(nil))..("\n"):format()
								if _G.functionspy.logging==true then
									log(getinfo(v).name,out)
								end
							end)
						end
						return hooked[i](...)
					end)
				end)
				if not suc then
					warn("Something went wrong while hooking "..getinfo(v).name..". Error: "..err)
				end
			end
		end

	end
	coroutine.wrap(AKIHDI_fake_script)()
	function KVVJTK_fake_script()
		local UIS=UserInputService
		local frame=FakeTitle.Parent
		local dragToggle=nil
		local dragSpeed=0.25
		local dragStart=nil
		local startPos=nil

		function updateInput(input)
			local delta=input.Position-dragStart
			local position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
				startPos.Y.Scale,startPos.Y.Offset+delta.Y)
			TweenService:Create(frame,TweenInfo.new(dragSpeed),{Position=position}):Play()
		end

		Insert(_G.functionspy.connections,frame.Title.InputBegan:Connect(function(input)
			if (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then 
				dragToggle=true
				dragStart=input.Position
				startPos=frame.Position
				input.Changed:Connect(function()
					if input.UserInputState==Enum.UserInputState.End then
						dragToggle=false
					end
				end)
			end
		end))

		Insert(_G.functionspy.connections,UIS.InputChanged:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
				if dragToggle then
					updateInput(input)
				end
			end
		end))

	end
	coroutine.wrap(KVVJTK_fake_script)()
	function BIPVKVC_fake_script()
		local script=InstanceNew('LocalScript',FakeTitle)

		Insert(_G.functionspy.connections,FakeTitle.MouseEnter:Connect(function()
			if _G.functionspy.logging==true then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif _G.functionspy.logging==false then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(_G.functionspy.connections,FakeTitle.MouseMoved:Connect(function()
			if _G.functionspy.logging==true then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif _G.functionspy.logging==false then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(_G.functionspy.connections,FakeTitle.MouseButton1Click:Connect(function()
			_G.functionspy.logging=not _G.functionspy.logging
			if _G.functionspy.logging==true then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif _G.functionspy.logging==false then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(_G.functionspy.connections,FakeTitle.MouseLeave:Connect(function()
			TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,1,1)}):Play()
		end))
	end
	coroutine.wrap(BIPVKVC_fake_script)()
	function PRML_fake_script()
		clear.MouseButton1Click:Connect(function()
			_G.functionspy.shutdown()
		end)
	end
	coroutine.wrap(PRML_fake_script)()
end)

function toggleFly()
	if flyVariables.flyEnabled then
		FLYING = false
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
		if goofyFLY then goofyFLY:Destroy() end
		flyVariables.flyEnabled = false
	else
		FLYING = true
		sFLY()
		flyVariables.flyEnabled = true
	end
end

function connectFlyKey()
	if flyVariables.keybindConn then
		flyVariables.keybindConn:Disconnect()
	end
	flyVariables.keybindConn = cmdm.KeyDown:Connect(function(KEY)
		if KEY:lower() == flyVariables.toggleKey then
			toggleFly()
		end
	end)
end

cmd.add({"fly"}, {"fly [speed]", "Enable flight"}, function(...)
	local arg = (...) or nil
	flyVariables.flySpeed = arg or 1
	connectFlyKey()
	flyVariables.flyEnabled = true

	if flyVariables.mFlyBruh then
		flyVariables.mFlyBruh:Destroy()
		flyVariables.mFlyBruh = nil
	end
	cmd.run({"uncfly", ''})
	cmd.run({"unvfly", ''})

	if IsOnMobile then
		Wait()
		DebugNotif(adminName.." detected mobile. Fly button added for easier use.", 2)

		flyVariables.mFlyBruh = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local speedBox = InstanceNew("TextBox")
		local toggleBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local corner2 = InstanceNew("UICorner")
		local corner3 = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(flyVariables.mFlyBruh)
		flyVariables.mFlyBruh.ResetOnSpawn = false

		btn.Parent = flyVariables.mFlyBruh
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.9, 0, 0.5, 0)
		btn.Size = UDim2.new(0.08, 0, 0.1, 0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "Fly"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		speedBox.Parent = flyVariables.mFlyBruh
		speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(flyVariables.flySpeed)
		speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		speedBox.TextSize = 18
		speedBox.TextWrapped = true
		speedBox.ClearTextOnFocus = false
		speedBox.PlaceholderText = "Speed"
		speedBox.Visible = false

		corner2.CornerRadius = UDim.new(0.2, 0)
		corner2.Parent = speedBox

		toggleBtn.Parent = btn
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		toggleBtn.BackgroundTransparency = 0.1
		toggleBtn.Position = UDim2.new(0.8, 0, -0.1, 0)
		toggleBtn.Size = UDim2.new(0.4, 0, 0.4, 0)
		toggleBtn.Font = Enum.Font.SourceSans
		toggleBtn.Text = "+"
		toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleBtn.TextScaled = true
		toggleBtn.TextWrapped = true
		toggleBtn.Active = true
		toggleBtn.AutoButtonColor = true

		corner3.CornerRadius = UDim.new(1, 0)
		corner3.Parent = toggleBtn

		MouseButtonFix(toggleBtn, function()
			speedBox.Visible = not speedBox.Visible
			toggleBtn.Text = speedBox.Visible and "-" or "+"
		end)

		coroutine.wrap(function()
			MouseButtonFix(btn, function()
				if not flyVariables.mOn then
					local newSpeed = tonumber(speedBox.Text) or flyVariables.flySpeed
					flyVariables.flySpeed = newSpeed
					speedBox.Text = tostring(flyVariables.flySpeed)
					flyVariables.mOn = true
					btn.Text = "Unfly"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					sFLY()
				else
					flyVariables.mOn = false
					btn.Text = "Fly"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					FLYING = false
					if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
					if goofyFLY then goofyFLY:Destroy() end
				end
			end)
		end)()

		NAgui.draggerV2(btn)
		NAgui.draggerV2(speedBox)
	else
		FLYING = false
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
		Wait()
		DebugNotif("Fly enabled. Press '"..flyVariables.toggleKey:upper().."' to toggle flying.")
		sFLY()
		speedofthevfly = flyVariables.flySpeed
		speedofthefly = flyVariables.flySpeed
	end
end, true)

cmd.add({"unfly"}, {"unfly", "Disable flight"}, function(bool)
	Wait()
	if not bool then DebugNotif("Not flying anymore", 2) end
	FLYING = false
	if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
	if goofyFLY then goofyFLY:Destroy() end
	flyVariables.mOn = false
	if flyVariables.mFlyBruh then
		flyVariables.mFlyBruh:Destroy()
		flyVariables.mFlyBruh = nil
	end
	if flyVariables.keybindConn then
		flyVariables.keybindConn:Disconnect()
		flyVariables.keybindConn = nil
	end
end)

function toggleCFly()
	local char = cmdlp.Character
	local humanoid = getHum()
	local head = getHead(char)

	if flyVariables.cFlyEnabled then
		FLYING = false
		flyVariables.cFlyEnabled = false

		if CFloop then
			CFloop:Disconnect()
			CFloop = nil
		end

		if humanoid then
			humanoid.PlatformStand = false
		end

		if head then
			head.Anchored = false
		end

		if goofyFLY then
			goofyFLY:Destroy()
			goofyFLY = nil
		end
	else
		FLYING = true
		flyVariables.cFlyEnabled = true
		sFLY(nil, true)
	end
end

function connectCFlyKey()
	if flyVariables.cKeybindConn then
		flyVariables.cKeybindConn:Disconnect()
	end
	flyVariables.cKeybindConn = cmdm.KeyDown:Connect(function(KEY)
		if KEY:lower() == flyVariables.cToggleKey then
			toggleCFly()
		end
	end)
end

cmd.add({"cframefly", "cfly"}, {"cframefly [speed] (cfly)", "Enable CFrame-based flight"}, function(...)
	local arg = (...) or nil
	flyVariables.cFlySpeed = tonumber(arg) or flyVariables.cFlySpeed
	flyVariables.flySpeed = flyVariables.cFlySpeed

	connectCFlyKey()
	flyVariables.cFlyEnabled = true

	if flyVariables.cFlyGUI then
		flyVariables.cFlyGUI:Destroy()
		flyVariables.cFlyGUI = nil
	end

	cmd.run({"unfly", ''})
	cmd.run({"unvfly", ''})

	if IsOnMobile then
		Wait()
		DebugNotif(adminName.." detected mobile. CFrame Fly button added.", 2)

		flyVariables.cFlyGUI = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local speedBox = InstanceNew("TextBox")
		local toggleBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local corner2 = InstanceNew("UICorner")
		local corner3 = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(flyVariables.cFlyGUI)
		flyVariables.cFlyGUI.ResetOnSpawn = false

		btn.Parent = flyVariables.cFlyGUI
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.9, 0, 0.6, 0)
		btn.Size = UDim2.new(0.08, 0, 0.1, 0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "CFly"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		speedBox.Parent = flyVariables.cFlyGUI
		speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(flyVariables.cFlySpeed)
		speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		speedBox.TextSize = 18
		speedBox.TextWrapped = true
		speedBox.ClearTextOnFocus = false
		speedBox.PlaceholderText = "Speed"
		speedBox.Visible = false

		corner2.CornerRadius = UDim.new(0.2, 0)
		corner2.Parent = speedBox

		toggleBtn.Parent = btn
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		toggleBtn.BackgroundTransparency = 0.1
		toggleBtn.Position = UDim2.new(0.8, 0, -0.1, 0)
		toggleBtn.Size = UDim2.new(0.4, 0, 0.4, 0)
		toggleBtn.Font = Enum.Font.SourceSans
		toggleBtn.Text = "+"
		toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleBtn.TextScaled = true
		toggleBtn.TextWrapped = true
		toggleBtn.Active = true
		toggleBtn.AutoButtonColor = true

		corner3.CornerRadius = UDim.new(1, 0)
		corner3.Parent = toggleBtn

		MouseButtonFix(toggleBtn, function()
			speedBox.Visible = not speedBox.Visible
			toggleBtn.Text = speedBox.Visible and "-" or "+"
		end)

		coroutine.wrap(function()
			MouseButtonFix(btn, function()
				if not flyVariables.cOn then
					local newSpeed = tonumber(speedBox.Text) or flyVariables.cFlySpeed
					flyVariables.cFlySpeed = newSpeed
					flyVariables.flySpeed = flyVariables.cFlySpeed
					speedBox.Text = tostring(flyVariables.cFlySpeed)
					flyVariables.cOn = true
					btn.Text = "UnCfly"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					sFLY(true, true)
				else
					flyVariables.cOn = false
					btn.Text = "CFly"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					FLYING = false
					local hum = getHum()
					local head = getChar() and getHead(getChar())
					head.Anchored = false
					hum.PlatformStand = false
					if CFloop then CFloop:Disconnect() CFloop = nil end
					if goofyFLY then goofyFLY:Destroy() end
				end
			end)
		end)()

		NAgui.draggerV2(btn)
		NAgui.draggerV2(speedBox)
	else
		FLYING = false
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
		Wait()
		DebugNotif("CFrame Fly enabled. Press '"..flyVariables.cToggleKey:upper().."' to toggle.")
		sFLY(true, true)
	end
end, true)

cmd.add({"uncframefly","uncfly"}, {"uncframefly (uncfly)", "Disable CFrame-based flight"}, function(bool)
	Wait()
	if not bool then DebugNotif("CFrame Fly disabled.", 2) end
	FLYING = false

	local char = cmdlp.Character
	local hum = getHum()
	local head = getHead(char)

	if CFloop then
		CFloop:Disconnect()
		CFloop = nil
	end

	if hum then
		hum.PlatformStand = false
	end

	if head then
		head.Anchored = false
	end

	if goofyFLY then
		goofyFLY:Destroy()
	end

	flyVariables.cOn = false
	if flyVariables.cFlyGUI then
		flyVariables.cFlyGUI:Destroy()
		flyVariables.cFlyGUI = nil
	end
	if flyVariables.cKeybindConn then
		flyVariables.cKeybindConn:Disconnect()
		flyVariables.cKeybindConn = nil
	end
end)

--[[if IsOnPC then
	cmd.add({"cflybind", "cframeflybind", "bindcfly"}, {"cflybind [key] (cframeflybind, bindcfly)", "Set custom keybind for CFrame fly"}, function(...)
		local newKey = (...) or ""
		newKey = newKey:lower()
		if newKey == "" then
			DoNotif("Please provide a keybind.")
			return
		end

		flyVariables.cToggleKey = newKey

		if flyVariables.cKeybindConn then
			flyVariables.cKeybindConn:Disconnect()
			flyVariables.cKeybindConn = nil
		end

		connectCFlyKey()
		DoNotif("CFrame fly keybind set to '"..flyVariables.cToggleKey:upper().."'")
	end,true)
end]]

function toggleTFly()
	if flyVariables.TFlyEnabled then
		flyVariables.TFlyEnabled = false
		for _, v in pairs(workspace:GetDescendants()) do
			if v:GetAttribute("tflyPart") then
				v:Destroy()
			end
		end
		local hum = getHum()
		if hum then hum.PlatformStand = false end
		if flyVariables.TFLYBTN then
			flyVariables.TFLYBTN.Text = "TFly"
			flyVariables.TFLYBTN.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	else
		flyVariables.TFlyEnabled = true
		local speed = flyVariables.TflySpeed
		local Humanoid = getHum()

		flyVariables.tflyCORE = InstanceNew("Part", workspace)
		flyVariables.tflyCORE:SetAttribute("tflyPart", true)
		flyVariables.tflyCORE.Size = Vector3.new(0.05, 0.05, 0.05)
		flyVariables.tflyCORE.CanCollide = false

		local Weld = InstanceNew("Weld", flyVariables.tflyCORE)
		Weld.Part0 = flyVariables.tflyCORE
		Weld.Part1 = Humanoid.RootPart
		Weld.C0 = CFrame.new(0, 0, 0)

		local pos = InstanceNew("BodyPosition", flyVariables.tflyCORE)
		local gyro = InstanceNew("BodyGyro", flyVariables.tflyCORE)
		pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
		pos.position = flyVariables.tflyCORE.Position
		gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		gyro.cframe = flyVariables.tflyCORE.CFrame

		coroutine.wrap(function()
			repeat
				Wait()
				Humanoid.PlatformStand = true
				local newPosition = gyro.cframe - gyro.cframe.p + pos.position

				local moveVec = GetCustomMoveVector()
				moveVec = Vector3.new(moveVec.X, moveVec.Y, -moveVec.Z)

				if moveVec.Magnitude > 0 then
					local camera = workspace.CurrentCamera
					newPosition = newPosition + (camera.CFrame.RightVector * moveVec.X * speed)
					newPosition = newPosition + (camera.CFrame.LookVector * moveVec.Z * speed)
				end

				pos.position = newPosition.p
				gyro.cframe = workspace.CurrentCamera.CoordinateFrame
			until not flyVariables.TFlyEnabled

			if gyro then gyro:Destroy() end
			if pos then pos:Destroy() end
			Humanoid.PlatformStand = false
		end)()

		if flyVariables.TFLYBTN then
			flyVariables.TFLYBTN.Text = "UnTFly"
			flyVariables.TFLYBTN.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		end
	end
end

cmd.add({"tfly", "tweenfly"}, {"tfly [speed] (tweenfly)", "Enables smooth flying"}, function(...)
	local arg = (...) or nil
	flyVariables.TflySpeed = arg or 1

	if IsOnMobile then
		Wait()
		DebugNotif(adminName.." detected mobile. Tfly button added for easier use.", 2)

		if flyVariables.tflyButtonUI then flyVariables.tflyButtonUI:Destroy() end
		if flyVariables.TFLYBTN then flyVariables.TFLYBTN:Destroy() end

		flyVariables.tflyButtonUI = InstanceNew("ScreenGui")
		flyVariables.TFLYBTN = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")

		NaProtectUI(flyVariables.tflyButtonUI)
		flyVariables.tflyButtonUI.ResetOnSpawn = false

		flyVariables.TFLYBTN.Parent = flyVariables.tflyButtonUI
		flyVariables.TFLYBTN.BackgroundColor3 = Color3.fromRGB(30,30,30)
		flyVariables.TFLYBTN.BackgroundTransparency = 0.1
		flyVariables.TFLYBTN.Position = UDim2.new(0.9,0,0.5,0)
		flyVariables.TFLYBTN.Size = UDim2.new(0.08,0,0.1,0)
		flyVariables.TFLYBTN.Font = Enum.Font.GothamBold
		flyVariables.TFLYBTN.Text = "TFly"
		flyVariables.TFLYBTN.TextColor3 = Color3.fromRGB(255,255,255)
		flyVariables.TFLYBTN.TextSize = 18
		flyVariables.TFLYBTN.TextWrapped = true
		flyVariables.TFLYBTN.Active = true
		flyVariables.TFLYBTN.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = flyVariables.TFLYBTN

		MouseButtonFix(flyVariables.TFLYBTN, toggleTFly)
		NAgui.draggerV2(flyVariables.TFLYBTN)
	else
		if flyVariables.tflyKeyConn then flyVariables.tflyKeyConn:Disconnect() end
		flyVariables.tflyKeyConn = cmdm.KeyDown:Connect(function(key)
			if key:lower() == flyVariables.tflyToggleKey then
				toggleTFly()
			end
		end)
		DebugNotif("TFly keybind set to '"..flyVariables.tflyToggleKey:upper().."'. Press to toggle.")
	end

	toggleTFly()
end, true)

cmd.add({"untfly", "untweenfly"}, {"untfly (untweenfly)", "Disables tween flying"}, function()
	Wait()
	DebugNotif("Not flying anymore", 2)
	flyVariables.TFlyEnabled = false
	for _, v in pairs(workspace:GetDescendants()) do
		if v:GetAttribute("tflyPart") then
			v:Destroy()
		end
	end
	local hum = getHum()
	if hum then hum.PlatformStand = false end
	if flyVariables.tflyButtonUI then
		flyVariables.tflyButtonUI:Destroy()
		flyVariables.tflyButtonUI = nil
	end
	if flyVariables.TFLYBTN then
		flyVariables.TFLYBTN:Destroy()
		flyVariables.TFLYBTN = nil
	end
	if flyVariables.tflyKeyConn then
		flyVariables.tflyKeyConn:Disconnect()
		flyVariables.tflyKeyConn = nil
	end
end)

--[[if IsOnPC then
	cmd.add({"tflykeybind", "bindtfly", "tflybind"}, {"tflykeybind [key] (bindtfly, tflybind)", "Set keybind for tfly toggle"}, function(...)
		local key = (...) or ""
		if key == "" then
			DoNotif("Please provide a key.")
			return
		end
		flyVariables.tflyToggleKey = key:lower()
		if flyVariables.tflyKeyConn then flyVariables.tflyKeyConn:Disconnect() end
		flyVariables.tflyKeyConn = cmdm.KeyDown:Connect(function(k)
			if k:lower() == flyVariables.tflyToggleKey then
				toggleTFly()
			end
		end)
		DoNotif("TFly keybind set to '"..flyVariables.tflyToggleKey:upper().."'")
	end, true)
end]]

cmd.add({"noclip","nclip","nc"},{"noclip","Disable your player's collision"},function()
	NAlib.disconnect("noclip")
	NAlib.connect("noclip",RunService.Stepped:Connect(function()
		if not getChar() then return end
		for i,v in pairs(getChar():GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide=false
			end
		end
	end))
end)

cmd.add({"clip"},{"clip","Enable your player's collision"},function()
	NAlib.disconnect("noclip")
end)

originalPos = nil
platformPart = nil
activationTime = nil

cmd.add({"antibang"}, {"antibang", "prevents users to bang you (still WORK IN PROGRESS)"}, function()
	NAlib.disconnect("antibang_loop")

	local root = getRoot(LocalPlayer.Character)
	if not root then return end

	originalPos = root.CFrame
	local orgHeight = workspace.FallenPartsDestroyHeight
	local anims = {"rbxassetid://5918726674", "rbxassetid://148840371", "rbxassetid://698251653", "rbxassetid://72042024", "rbxassetid://189854234", "rbxassetid://106772613", "rbxassetid://10714360343", "rbxassetid://95383980"}
	local inVoid = false
	local targetPlayer = nil
	local toldNotif = false
	local activationTime = nil

	LocalPlayer.CharacterAdded:Connect(function(char)
		Wait(1)
		root = getRoot(char)
	end)

	NAlib.connect("antibang_loop", RunService.Stepped:Connect(function()
		for _, p in pairs(SafeGetService("Players"):GetPlayers()) do
			if p ~= LocalPlayer and p.Character and getRoot(p.Character) then
				if (getRoot(p.Character).Position - root.Position).Magnitude <= 10 then
					local tracks = getPlrHum(p):GetPlayingAnimationTracks()
					for _, t in pairs(tracks) do
						if Discover(anims, t.Animation.AnimationId) then
							if not inVoid then
								inVoid = true
								activationTime = tick()
								targetPlayer = p
								workspace.FallenPartsDestroyHeight = 0/1/0
								platformPart = InstanceNew("Part")
								platformPart.Size = Vector3.new(9999, 1, 9999)
								platformPart.Anchored = true
								platformPart.CanCollide = true
								platformPart.Transparency = 1
								platformPart.Position = Vector3.new(0, orgHeight - 30, 0)
								platformPart.Parent = workspace
								root.CFrame = CFrame.new(Vector3.new(0, orgHeight - 25, 0))
								if not toldNotif then
									toldNotif = true
									DebugNotif("Antibang activated | Target: "..nameChecker(targetPlayer), 2)
								end
							end
						end
					end
				end
			end
		end

		if inVoid then
			if (not targetPlayer or not targetPlayer.Character or not getPlrHum(targetPlayer) or getPlrHum(targetPlayer).Health <= 0)
				or (activationTime and tick() - activationTime >= 10) then
				inVoid = false
				targetPlayer = nil
				root.CFrame = originalPos
				root.Anchored = true
				Wait()
				root.Anchored = false
				workspace.FallenPartsDestroyHeight = orgHeight
				if platformPart then
					platformPart:Destroy()
					platformPart = nil
				end
				if toldNotif then
					toldNotif = false
					if activationTime and tick() - activationTime >= 10 then
						DebugNotif("Antibang deactivated (timeout)", 2)
					else
						DebugNotif("Antibang deactivated", 2)
					end
				end
			end
		end
	end))

	DebugNotif("Antibang Enabled", 3)
end)

cmd.add({"unantibang"}, {"unantibang", "disables antibang"}, function()
	NAlib.disconnect("antibang_loop")
	if platformPart then
		platformPart:Destroy()
		platformPart = nil
	end
	DebugNotif("Antibang Disabled", 3)
end)

cmd.add({"orbit"}, {"orbit <player> <distance>", "Orbit around a player"}, function(p, d)
	NAlib.disconnect("orbit")
	local targets = getPlr(p)
	if #targets == 0 then return end
	local target = targets[1]
	local tchar = target.Character
	local char = getChar()
	if not tchar or not char then return end
	local thrp = getRoot(tchar)
	local hrp = getRoot(char)
	if not thrp or not hrp then return end
	local dist = tonumber(d) or 4
	local sineX, sineZ = 0, math.pi / 2
	NAlib.connect("orbit", RunService.Stepped:Connect(function()
		if not (thrp.Parent and hrp.Parent) then
			NAlib.disconnect("orbit")
			return
		end
		sineX, sineZ = sineX + 0.05, sineZ + 0.05
		local sinX, sinZ = math.sin(sineX), math.sin(sineZ)
		hrp.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(sinX * dist, 0, sinZ * dist) * (hrp.CFrame - hrp.CFrame.p) + thrp.CFrame.p
	end))
end, true)

cmd.add({"uporbit"}, {"uporbit <player> <distance>", "Orbit around a player on the Y axis"}, function(p, d)
	NAlib.disconnect("orbit")
	local targets = getPlr(p)
	if #targets == 0 then return end
	local target = targets[1]
	local tchar = target.Character
	local char = getChar()
	if not tchar or not char then return end
	local thrp = getRoot(tchar)
	local hrp = getRoot(char)
	if not thrp or not hrp then return end
	local dist = tonumber(d) or 4
	local sineX, sineY = 0, math.pi / 2
	NAlib.connect("orbit", RunService.Stepped:Connect(function()
		if not (thrp.Parent and hrp.Parent) then
			NAlib.disconnect("orbit")
			return
		end
		sineX, sineY = sineX + 0.05, sineY + 0.05
		local sinX, sinY = math.sin(sineX), math.sin(sineY)
		hrp.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(sinX * dist, sinY * dist, 0) * (hrp.CFrame - hrp.CFrame.p) + thrp.CFrame.p
	end))
end, true)

cmd.add({"unorbit"}, {"unorbit", "Stop orbiting"}, function()
	NAlib.disconnect("orbit")
end)

cmd.add({"freezewalk"},{"freezewalk","Freezes your character on the server but lets you walk on the client"},function()
	local Character=getChar()
	local Root=getRoot(Character)

	if IsR6() then
		local Clone=Root:Clone()
		Root:Destroy()
		Clone.Parent=Character
	else
		getTorso(Character).Anchored=true
		getTorso(Character).Root:Destroy()
	end
	DebugNotif("freezewalk is activated,reset to stop it")
end)

fcBTNTOGGLE = nil

cmd.add({"freecam","fc","fcam"},{"freecam [speed] (fc,fcam)","Enable free camera"},function(...)
	argg = (...)
	local speed = argg or 5

	if NAlib.isConnected("freecam") then
		NAlib.disconnect("freecam")
		camera.CameraSubject = getChar()
		Spawn(function() cmd.run({"unfr"}) end)
	end

	if fcBTNTOGGLE then fcBTNTOGGLE:Destroy() fcBTNTOGGLE = nil end

	function runFREECAM()
		local cf = InstanceNew("CFrameValue")
		local camPart = InstanceNew("Part")
		camPart.Transparency = 1
		camPart.Anchored = true
		camPart.CFrame = camera.CFrame

		Spawn(function()
			cmd.run({"fr",''})
		end)

		NAlib.connect("freecam", RunService.Stepped:Connect(function(dt)
			local primaryPart = camPart
			camera.CameraSubject = primaryPart

			local moveVec = GetCustomMoveVector()

			local x = moveVec.X * speed
			local y = moveVec.Y * speed
			local z = moveVec.Z * speed

			primaryPart.CFrame = CFrame.new(
				primaryPart.CFrame.p,
				(camera.CFrame * CFrame.new(0, 0, -100)).p
			)

			local moveDir = CFrame.new(x, y, z)
			cf.Value = cf.Value:lerp(moveDir, 0.2)
			primaryPart.CFrame = primaryPart.CFrame:lerp(primaryPart.CFrame * cf.Value, 0.2)
		end))
	end

	if IsOnMobile then
		if fcBTNTOGGLE then fcBTNTOGGLE:Destroy() fcBTNTOGGLE = nil end

		fcBTNTOGGLE = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local speedBox = InstanceNew("TextBox")
		local toggleBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local corner2 = InstanceNew("UICorner")
		local corner3 = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(fcBTNTOGGLE)
		fcBTNTOGGLE.ResetOnSpawn = false

		btn.Parent = fcBTNTOGGLE
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.9, 0, 0.5, 0)
		btn.Size = UDim2.new(0.08, 0, 0.1, 0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "FC"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		speedBox.Parent = fcBTNTOGGLE
		speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(speed)
		speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		speedBox.TextSize = 18
		speedBox.TextWrapped = true
		speedBox.ClearTextOnFocus = false
		speedBox.PlaceholderText = "Speed"
		speedBox.Visible = false

		corner2.CornerRadius = UDim.new(0.2, 0)
		corner2.Parent = speedBox

		toggleBtn.Parent = btn
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		toggleBtn.BackgroundTransparency = 0.1
		toggleBtn.Position = UDim2.new(0.9, 0, -0.1, 0)
		toggleBtn.Size = UDim2.new(0.4, 0, 0.4, 0)
		toggleBtn.Font = Enum.Font.SourceSans
		toggleBtn.Text = "+"
		toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleBtn.TextSize = 14
		toggleBtn.TextWrapped = true
		toggleBtn.Active = true
		toggleBtn.AutoButtonColor = true

		corner3.CornerRadius = UDim.new(1, 0)
		corner3.Parent = toggleBtn

		MouseButtonFix(toggleBtn, function()
			speedBox.Visible = not speedBox.Visible
			toggleBtn.Text = speedBox.Visible and "-" or "+"
		end)

		coroutine.wrap(function()
			MouseButtonFix(btn, function()
				if not flyVariables.mOn then
					local newSpeed = tonumber(speedBox.Text) or 5
					if newSpeed then
						speed = newSpeed
						speedBox.Text = tostring(speed)
					else
						speed = 5
						speedBox.Text = tostring(speed)
					end
					flyVariables.mOn = true
					btn.Text = "UNFC"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					runFREECAM()
				else
					flyVariables.mOn = false
					btn.Text = "FC"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					if NAlib.isConnected("freecam") then
						NAlib.disconnect("freecam")
					end
					camera.CameraSubject = getChar()
					Spawn(function() cmd.run({"unfr"}) end)
				end
			end)
		end)()

		NAgui.draggerV2(btn)
		NAgui.draggerV2(speedBox)
	else
		DebugNotif("Freecam is activated, use WASD to move around", 2)
		runFREECAM()
	end
end, true)

cmd.add({"unfreecam","unfc","unfcam"},{"unfreecam (unfc,unfcam)","Disable free camera"},function()
	NAlib.disconnect("freecam")
	camera.CameraSubject = getChar()
	Spawn(function()
		cmd.run({"unfr"})
	end)
	if fcBTNTOGGLE then fcBTNTOGGLE:Destroy() fcBTNTOGGLE = nil end
end)

cmd.add({"nohats","drophats"},{"nohats (drophats)","Drop all of your hats"},function()
	for _,hat in pairs(getChar():GetChildren()) do
		if hat:IsA("Accoutrement") then
			hat:FindFirstChildWhichIsA("Weld",true):Destroy()
		end
	end
end)

cmd.add({"permadeath", "pdeath"}, {"permadeath (pdeath)", "be death permanently"}, function()
	if not replicatesignal then
		return DoNotif("Your executor does not support 'replicatesignal'")
	end

	replicatesignal(LocalPlayer.ConnectDiedSignalBackend)
	Wait(Players.RespawnTime + 0.1)

	local humanoid = getHum()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end
end)

cmd.add({"unpermadeath", "unpdeath"}, {"unpermadeath (unpdeath)", "no perma death"}, function()
	if not replicatesignal then
		return DoNotif("Your executor does not support 'replicatesignal'")
	end

	replicatesignal(LocalPlayer.ConnectDiedSignalBackend)
end)

cmd.add({"instantrespawn", "instantr", "irespawn"}, {"instantrespawn (instantr, irespawn)", "respawn instantly"}, function()
	if not replicatesignal then
		return DoNotif("Your executor does not support 'replicatesignal'")
	end

	replicatesignal(LocalPlayer.ConnectDiedSignalBackend)

	local rootPart = LocalPlayer.Character and getRoot(LocalPlayer.Character)
	local cam = workspace.CurrentCamera

	Wait(Players.RespawnTime - 0.165)

	local humanoid = getHum()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end

	Wait(0.5)

	if rootPart then
		getRoot(LocalPlayer.Character).CFrame = rootPart.CFrame
	end

	workspace.CurrentCamera = cam
end)

function getAllTools()
	local tools={}
	local backpack=localPlayer:FindFirstChildWhichIsA("Backpack")
	if backpack then
		for i,v in pairs(backpack:GetChildren()) do
			if v:IsA("Tool") then
				Insert(tools,v)
			end
		end
	end
	for i,v in pairs(character:GetChildren()) do
		if v:IsA("Tool") then
			Insert(tools,v)
		end
	end
	return tools
end

cmd.add({"circlemath", "cm"}, {"circlemath <mode> <size>", "Gay circle math\nModes: a,b,c,d,e"}, function(mode, size)
	local mode = mode or "a"
	local backpack = getBp()
	NAlib.disconnect("cm")
	if backpack and character.Parent then
		local tools = getAllTools()
		for i, tool in pairs(tools) do
			local cpos, g = (math.pi*2)*(i/#tools), CFrame.new()
			local tcon = {}
			tool.Parent = backpack

			if mode == "a" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(0, 0, size)*
						CFrame.Angles(rad(90), 0, cpos)
				)
			elseif mode == "b" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(i - #tools/2, 0, 0)*
						CFrame.Angles(rad(90), 0, 0)
				)
			elseif mode == "c" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(cpos/3, 0, 0)*
						CFrame.Angles(rad(90), 0, cpos*2)
				)
			elseif mode == "d" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(clamp(tan(cpos), -3, 3), 0, 0)*
						CFrame.Angles(rad(90), 0, cpos)
				)
			elseif mode == "e" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(0, 0, clamp(tan(cpos), -5, 5))*
						CFrame.Angles(rad(90), 0, cpos)
				)
			end
			tool.Grip = g
			tool.Parent = character

			tcon[#tcon] = NAlib.connect("cm", mouse.Button1Down:Connect(function()
				tool:Activate()
			end))
			tcon[#tcon] = NAlib.connect("cm", tool.Changed:Connect(function(p)
				if p == "Grip" and tool.Grip ~= g then
					tool.Grip = g
				end
			end))

			NAlib.connect("cm", tool.AncestryChanged:Connect(function()
				for i = 1, #tcon do
					tcon[i]:Disconnect()
				end
			end))
		end
	end
end,true)

GRIPUITHINGYIDFK = nil

cmd.add({"grippos", "setgrip"}, {"grippos (setgrip)", "Opens a UI to manually input grip offset and rotation."}, function()
	local plr = LocalPlayer
	if GRIPUITHINGYIDFK then return end

	GRIPUITHINGYIDFK = InstanceNew("ScreenGui")
	GRIPUITHINGYIDFK.Name = "GripAdjustUI"
	GRIPUITHINGYIDFK.ResetOnSpawn = false
	NaProtectUI(GRIPUITHINGYIDFK)

	local frame = InstanceNew("Frame")
	frame.Size = UDim2.new(0, 320, 0, 270)
	frame.Position = UDim2.new(0.5, -160, 0.5, -135)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	frame.BorderSizePixel = 0
	frame.Parent = GRIPUITHINGYIDFK

	local corner = InstanceNew("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 6)

	local gradient = InstanceNew("UIGradient", frame)
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
	}

	local titleBar = InstanceNew("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = frame

	local barCorner = InstanceNew("UICorner", titleBar)
	barCorner.CornerRadius = UDim.new(0, 6)

	local title = InstanceNew("TextLabel")
	title.Size = UDim2.new(1, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.Text = "Grip Position Editor"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.Parent = titleBar

	local preview = InstanceNew("TextButton")
	preview.Size = UDim2.new(0, 260, 0, 28)
	preview.Position = UDim2.new(0, 30, 0, 180)
	preview.Text = "🔍 Preview"
	preview.Font = Enum.Font.GothamBold
	preview.TextSize = 15
	preview.BackgroundColor3 = Color3.fromRGB(75, 75, 95)
	preview.TextColor3 = Color3.new(1, 1, 1)
	preview.Parent = frame
	InstanceNew("UICorner", preview)

	local labels = {"X", "Y", "Z", "RX", "RY", "RZ"}
	local textBoxes = {}

	for i, label in ipairs(labels) do
		local xOffset = ((i - 1) % 3) * 100
		local yOffset = 40 + math.floor((i - 1) / 3) * 50

		local labelUI = InstanceNew("TextLabel")
		labelUI.Size = UDim2.new(0, 40, 0, 25)
		labelUI.Position = UDim2.new(0, 10 + xOffset, 0, yOffset)
		labelUI.BackgroundTransparency = 1
		labelUI.Text = label
		labelUI.TextColor3 = Color3.fromRGB(255, 255, 255)
		labelUI.Font = Enum.Font.Gotham
		labelUI.TextSize = 14
		labelUI.Parent = frame

		local box = InstanceNew("TextBox")
		box.Size = UDim2.new(0, 50, 0, 25)
		box.Position = UDim2.new(0, 50 + xOffset, 0, yOffset)
		box.PlaceholderText = "0"
		box.Text = ""
		box.Font = Enum.Font.Gotham
		box.TextSize = 14
		box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		box.TextColor3 = Color3.fromRGB(255, 255, 255)
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.Parent = frame

		local boxCorner = InstanceNew("UICorner", box)
		boxCorner.CornerRadius = UDim.new(0, 4)

		textBoxes[label] = box
	end

	local function getVal(name)
		return tonumber(textBoxes[name].Text) or 0
	end

	local function closeUI()
		if GRIPUITHINGYIDFK then
			GRIPUITHINGYIDFK:Destroy()
			GRIPUITHINGYIDFK = nil
		end
	end

	local function applyGrip()
		local char = getChar()
		local tool = char and char:FindFirstChildOfClass("Tool")
		local backpack = getBp() or LocalPlayer:FindFirstChild("Backpack")
		if not tool or not backpack then return end

		local pos = Vector3.new(getVal("X"), getVal("Y"), getVal("Z"))
		local rot = Vector3.new(getVal("RX"), getVal("RY"), getVal("RZ"))
		local gripCFrame = CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))

		tool.Parent = backpack
		Wait()
		tool.Grip = gripCFrame
		tool.Parent = char

		local fix
		fix = tool.Changed:Connect(function(prop)
			if prop == "Grip" and tool.Grip ~= gripCFrame then
				tool.Grip = gripCFrame
			end
		end)

		tool.AncestryChanged:Connect(function()
			if fix then fix:Disconnect() end
		end)
	end

	local confirm = InstanceNew("TextButton")
	confirm.Size = UDim2.new(0, 130, 0, 32)
	confirm.Position = UDim2.new(0, 20, 0, 215)
	confirm.Text = "Apply"
	confirm.Font = Enum.Font.GothamBold
	confirm.TextSize = 16
	confirm.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
	confirm.TextColor3 = Color3.new(1, 1, 1)
	confirm.Parent = frame
	InstanceNew("UICorner", confirm)

	local cancel = InstanceNew("TextButton")
	cancel.Size = UDim2.new(0, 130, 0, 32)
	cancel.Position = UDim2.new(0, 170, 0, 215)
	cancel.Text = "Cancel"
	cancel.Font = Enum.Font.GothamBold
	cancel.TextSize = 16
	cancel.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	cancel.TextColor3 = Color3.new(1, 1, 1)
	cancel.Parent = frame
	InstanceNew("UICorner", cancel)

	confirm.MouseButton1Click:Connect(function()
		applyGrip()
		closeUI()
	end)

	preview.MouseButton1Click:Connect(applyGrip)
	cancel.MouseButton1Click:Connect(closeUI)

	NAgui.draggerV2(frame)
end)

cmd.add({"seizure"}, {"seizure", "Gives you a seizure"}, function()
	Spawn(function()
		if getgenv().Lzzz == true then return end

		local Anim = InstanceNew("Animation")
		if IsR15() then
			Anim.AnimationId = "rbxassetid://507767968"
		else
			Anim.AnimationId = "rbxassetid://180436148"
		end
		local k = getHum():LoadAnimation(Anim)
		getgenv().ssss = LocalPlayer:GetMouse()
		getgenv().Lzzz = false

		if Lzzz == false then
			getgenv().Lzzz = true
			if IsR15() then
				Anim.AnimationId = "rbxassetid://507767968"
			else
				Anim.AnimationId = "rbxassetid://180436148"
			end
			getgenv().currentnormal = workspace.Gravity
			workspace.Gravity = 196.2
			LocalPlayer.Character:PivotTo(LocalPlayer.Character:GetPivot() * CFrame.Angles(2, 0, 0))
			Wait(0.5)
			if getHum() and getHum().PlatformStand then getHum().PlatformStand = true end
			LocalPlayer.Character.Animate.Disabled = true

			k:Play()
			k:AdjustSpeed(10)

			LocalPlayer.Character.Animate.Disabled = true
		else
			getgenv().Lzzz = false
			if IsR15() then
				Anim.AnimationId = "rbxassetid://507767968"
			else
				Anim.AnimationId = "rbxassetid://180436148"
			end
			workspace.Gravity = currentnormal
			if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
			getHum().Jump = true
			k:Stop()

			LocalPlayer.Character.Animate.Disabled = false
			RunService.Heartbeat:Wait()
			for i = 1,10 do
				getRoot(LocalPlayer.Character).AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				Wait(0.1)
			end
		end

		RunService.RenderStepped:Connect(function()
			if Lzzz == true then
				getRoot(LocalPlayer.Character).CFrame = getRoot(LocalPlayer.Character).CFrame * CFrame.new(
					.075 * math.sin(45 * tick()),
					.075 * math.sin(45 * tick()),
					.075 * math.sin(45 * tick())
				)
			end
		end)
	end)
end)

cmd.add({"unseizure"}, {"unseizure", "Stops you from having a seizure not in real life noob"}, function()
	Spawn(function()
		if getgenv().Lzzz ~= true then return end

		local Anim = InstanceNew("Animation")
		if IsR15() then
			Anim.AnimationId = "rbxassetid://507767968"
		else
			Anim.AnimationId = "rbxassetid://180436148"
		end

		local k = getHum():LoadAnimation(Anim)

		getgenv().Lzzz = false
		workspace.Gravity = currentnormal
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
		getHum().Jump = true
		k:Stop()

		LocalPlayer.Character.Animate.Disabled = false

		RunService.Heartbeat:Wait()
		for i = 1, 10 do
			getRoot(LocalPlayer.Character).AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			Wait(0.1)
		end
	end)
end)

cmd.add({"fakelag", "flag"}, {"fakelag (flag)", "fake lag"}, function()
	if FakeLag then return end
	FakeLag = true

	while FakeLag do
		local root = getRoot(getChar())
		if root then
			root.Anchored = true
			Wait(0.05)
			root.Anchored = false
			Wait(0.05)
		else
			FakeLag = false
		end
	end
end)

cmd.add({"unfakelag", "unflag"}, {"unfakelag (unflag)", "stops the fake lag command"}, function()
	FakeLag = false
end)

local r=math.rad
local center=CFrame.new(1.5,0.5,-1.5)

cmd.add({"hide", "unshow"}, {"hide <player> (unshow)", "places the selected player to lighting"}, function(...)
	Wait()
	DebugNotif("Hid the player")
	local Username = (...)
	local target = getPlr(Username)
	for _, plr in next, target do
		if plr and plr.Character then
			local A_1 = "/mute "..plr.Name
			local A_2 = "All"
			NAlib.LocalPlayerChat(A_1, A_2)
			plr.Character.Parent = Lighting
		end
	end
end, true)

cmd.add({"unhide", "show"}, {"show <player> (unhide)", "places the selected player back to workspace"}, function(...)
	Wait()
	DebugNotif("Unhid the player")
	local Username = (...)
	local target = getPlr(Username)
	for _, plr in next, target do
		if plr and plr.Character then
			local A_1 = "/unmute "..plr.Name
			local A_2 = "All"
			NAlib.LocalPlayerChat(A_1, A_2)
			plr.Character.Parent = workspace
		end
	end
end, true)

if IsOnPC then
	cmd.add({"aimbot","aimbotui","aimbotgui"},{"aimbot (aimbotui,aimbotgui)","aimbot and yeah"},function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/NewAimbot.lua"))()
		--loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Aimbot.lua",true))()
	end)
end

NAmanage.grabAllTools=function()
	local char = getChar()
	local hum = char and getHum()
	if not hum then return 0 end
	local count = 0
	for _, tool in ipairs(workspace:GetDescendants()) do
		if tool:IsA("Tool") then
			if NACaller(function() hum:EquipTool(tool) end) then
				count += 1
			end
		end
	end
	return count
end

cmd.add({"grabtools"},{"grabtools","Grabs dropped tools"},function()
	local count = NAmanage.grabAllTools()
	if count > 0 then
		DebugNotif(("Grabbed %d tools"):format(count), 2)
	else
		DebugNotif("No tools to grab", 2)
	end
end)

cmd.add({"loopgrabtools"},{"loopgrabtools","Loop grabs dropped tools"},function()
	if loopgrab then
		DebugNotif("Loop grab already running", 2)
		return
	end
	loopgrab = true
	DebugNotif("Started loop grabbing tools", 2)
	Spawn(function()
		while loopgrab do
			NAmanage.grabAllTools()
			Wait(1)
		end
		DebugNotif("Stopped loop grabbing tools", 2)
	end)
end)

cmd.add({"unloopgrabtools"},{"unloopgrabtools","Stops the loop grab command"},function()
	if not loopgrab then
		DebugNotif("Loop grab is not running", 2)
		return
	end
	loopgrab = false
end)

cmd.add({"dance"},{"dance","Does a random dance"},function()
	dances={"248263260","27789359","45834924","28488254","33796059","30196114","52155728"}
	if getChar():FindFirstChildOfClass('Humanoid').RigType==Enum.HumanoidRigType.R15 then
		dances={"4555808220","4555782893","3333432454","4049037604"}
	end
	if theanim then
		theanim:Stop()
		theanim:Destroy()
		local animation=InstanceNew("Animation")
		animation.AnimationId="rbxassetid://"..dances[math.random(1,#dances)]
		theanim=getChar():FindFirstChildOfClass('Humanoid'):LoadAnimation(animation)
		theanim:Play()
	else
		local animation=InstanceNew("Animation")
		animation.AnimationId="rbxassetid://"..dances[math.random(1,#dances)]
		theanim=getChar():FindFirstChildOfClass('Humanoid'):LoadAnimation(animation)
		theanim:Play()
	end
end)

cmd.add({"undance"},{"undance","Stops the dance command"},function()
	theanim:Stop()
	theanim:Destroy()
end)

cmd.add({"antichatlogs","antichatlogger"},{"antichatlogs (antichatlogger)","Prevents you from getting banning when typing unspeakable messages (requires the new chat service)"},function()
	local Players=SafeGetService("Players")
	local TextChatService=SafeGetService("TextChatService")
	local CoreGui=SafeGetService("CoreGui")
	local LocalPlayer=Players.LocalPlayer
	local glyphs={
		b={"β","в","բ"},
		c={"ծ"},
		d={"δ","д","դ"},
		e={"ε","է"},
		f={"φ","ф","ֆ"},
		h={"η","н"},
		i={"ի"},
		j={"ջ"},
		k={"κ","к","կ"},
		l={"λ","л","լ"},
		m={"μ","м","մ"},
		n={"η","н","ն"},
		p={"պ"},
		r={"ր"},
		t={"τ","т","տ"},
		u={"մ"},
		v={"в"},
		w={"ω","ш","վ"},
		x={"χ","խ"},
		y={"յ"},
		z={"ζ","з"},
		["1"]={"१"},
		["2"]={"२","٢"},
		["3"]={"३","٣"},
		["4"]={"४","٤"},
		["5"]={"५"},
		["6"]={"६","٦"},
		["7"]={"७"},
		["8"]={"८","٨"},
		["9"]={"९","٩"}
	}
	local function obfuscateMessage(msg)
		local out={}
		for _,code in utf8.codes(msg) do
			local ch=utf8.char(code)
			local lower=Lower(ch)
			if glyphs[lower] then
				local g=glyphs[lower][math.random(#glyphs[lower])]
				if ch:match("%u") then g=g:upper() end
				ch=g
			end
			Insert(out,ch)
		end
		return Concat(out)
	end
	local CachedChannels={}
	NAlib.BypassChatMessage=function(message,recipient)
		Spawn(function()
			local text=obfuscateMessage(message)
			local channel
			if recipient and recipient~="All" then
				channel=CachedChannels[recipient]
				if not channel or not channel:IsDescendantOf(TextChatService) or not channel:FindFirstChild(recipient) then
					channel=nil
					for _,c in ipairs(TextChatService.TextChannels:GetChildren()) do
						if Find(c.Name,"^RBXWhisper:") and c:FindFirstChild(recipient) then
							channel=c
							CachedChannels[recipient]=c
							break
						end
					end
				end
			end
			if not channel then channel=TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:FindFirstChild("General") end
			if channel then NACaller(function() channel:SendAsync(text) end) end
		end)
	end
	local function resolveRecipient(chip)
		if chip and chip:IsA("TextButton") then
			local txt=chip.Text or ""
			local d=Match(txt,"^%[To%s+(.+)%]$")
			if d and d~="" then
				d=Lower(d)
				for _,plr in ipairs(Players:GetPlayers()) do
					if Lower(plr.DisplayName)==d then return plr.Name end
				end
			end
		end
		return "All"
	end
	Spawn(function()
		repeat Wait() until CoreGui:FindFirstChild("ExperienceChat")
		local ec=CoreGui:WaitForChild("ExperienceChat")
		local al=ec:WaitForChild("appLayout")
		local cb=al:WaitForChild("chatInputBar")
		local bg=cb:WaitForChild("Background")
		local ct=bg:WaitForChild("Container")
		local tc=ct:WaitForChild("TextContainer")
		local bc=tc:WaitForChild("TextBoxContainer")
		local box=bc:WaitForChild("TextBox")
		local btn=ct:WaitForChild("SendButton")
		local chip=tc:FindFirstChild("TargetChannelChip")
		local function hook()
			local m=box.Text
			if m~="" then
				box.Text=""
				NAlib.BypassChatMessage(m,resolveRecipient(chip))
			end
		end
		box.FocusLost:Connect(function(e) if e then hook() end end)
		btn.MouseButton1Click:Connect(hook)
	end)
	DoNotif("antichatlogs activated (W.I.P)")
end)

cmd.add({"animspoofer","animationspoofer","spoofanim","animspoof"},{"animspoofer (animationspoofer, spoofanim, animspoof)","Loads up an animation spoofer,spoofs animations that use rbxassetid"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Animation%20Spoofer"))()
end)

cmd.add({"badgeviewer", "badgeview", "bviewer","badgev","bv"},{"badgeviewer (badgeview, bviewer, badgev, bv)","loads up a badge viewer UI that views all badges in the game you're in"},function()
	local Player = Players.LocalPlayer
	local function getBadges()
		local all = {}
		local cursor = ""
		repeat
			local url = ("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&sortOrder=Asc%s"):format(
				GameId,
				cursor ~= "" and "&cursor="..HttpService:UrlEncode(cursor) or ""
			)
			local res = opt.NAREQUEST({Url = url, Method = "GET"})
			if not res or res.StatusCode ~= 200 then
				break
			end
			local body = HttpService:JSONDecode(res.Body)
			for _, b in ipairs(body.data or {}) do
				Insert(all, {
					id = b.id,
					name = b.name,
					desc = b.displayDescription or b.description or "",
					icon = b.iconImageId,
					rarity = b.statistics and b.statistics.winRatePercentage or 0,
					awarded = b.statistics and b.statistics.awardedCount or 0,
					pastDay = b.statistics and b.statistics.pastDayAwardedCount or 0,
					universe = b.awardingUniverse and b.awardingUniverse.name or "Unknown"
				})
			end
			cursor = body.nextPageCursor or ""
		until cursor == ""
		return all
	end
	local function createBadgeUI(data)
		local sgui = InstanceNew("ScreenGui")
		NaProtectUI(sgui)
		sgui.Name = "BadgeViewer"
		local main = InstanceNew("Frame", sgui)
		main.Size = UDim2.new(0.5,0,0.7,0)
		main.Position = UDim2.new(0.25, 0, 0.2, 0)
		main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		main.BackgroundTransparency = 0.2
		main.BorderSizePixel = 0
		main.ClipsDescendants = true
		main.Active = true
		main.Visible = true
		main.Name = "Main"
		main:ClearAllChildren()
		local uicorner = InstanceNew("UICorner", main)
		uicorner.CornerRadius = UDim.new(0, 16)
		local top = InstanceNew("Frame", main)
		top.Size = UDim2.new(1, 0, 0, 40)
		top.BackgroundTransparency = 0.3
		top.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		local topCorner = InstanceNew("UICorner", top)
		topCorner.CornerRadius = UDim.new(0, 12)
		local title = InstanceNew("TextLabel", top)
		title.Size = UDim2.new(1, -80, 1, 0)
		title.Position = UDim2.new(0, 10, 0, 0)
		title.Text = "Badge Viewer"
		title.Font = Enum.Font.GothamBold
		title.TextSize = 20
		title.TextColor3 = Color3.fromRGB(240, 240, 240)
		title.BackgroundTransparency = 1
		title.TextXAlignment = Enum.TextXAlignment.Left
		local closeBtn = InstanceNew("TextButton", top)
		closeBtn.Text = "X"
		closeBtn.Size = UDim2.new(0, 30, 1, 0)
		closeBtn.Position = UDim2.new(1, -35, 0, 0)
		closeBtn.Font = Enum.Font.Gotham
		closeBtn.TextSize = 16
		closeBtn.BackgroundTransparency = 1
		closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
		local minBtn = InstanceNew("TextButton", top)
		minBtn.Text = "-"
		minBtn.Size = UDim2.new(0, 30, 1, 0)
		minBtn.Position = UDim2.new(1, -70, 0, 0)
		minBtn.Font = Enum.Font.Gotham
		minBtn.TextSize = 20
		minBtn.BackgroundTransparency = 1
		minBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
		local scroll = InstanceNew("ScrollingFrame", main)
		scroll.Size = UDim2.new(1, -20, 1, -50)
		scroll.Position = UDim2.new(0, 10, 0, 45)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 6
		scroll.CanvasSize = UDim2.new(0, 0, 0, #data * 130)
		local layout = InstanceNew("UIListLayout", scroll)
		layout.Padding = UDim.new(0, 10)
		for _, b in ipairs(data) do
			local f = InstanceNew("Frame", scroll)
			f.Size = UDim2.new(1, 0, 0, 120)
			f.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			f.BackgroundTransparency = 0.4
			local fc = InstanceNew("UICorner", f)
			fc.CornerRadius = UDim.new(0, 10)
			local img = InstanceNew("ImageLabel", f)
			img.Size = UDim2.new(0, 100, 0, 100)
			img.Position = UDim2.new(0, 10, 0, 10)
			img.Image = "rbxthumb://type=Asset&id="..b.icon.."&w=420&h=420"
			img.BackgroundTransparency = 1
			local title = InstanceNew("TextLabel", f)
			title.Position = UDim2.new(0, 120, 0, 10)
			title.Size = UDim2.new(1, -130, 0, 25)
			title.Text = b.name
			title.TextColor3 = Color3.fromRGB(255, 255, 255)
			title.Font = Enum.Font.GothamSemibold
			title.TextSize = 18
			title.BackgroundTransparency = 1
			title.TextXAlignment = Enum.TextXAlignment.Left
			local desc = InstanceNew("TextLabel", f)
			desc.Position = UDim2.new(0, 120, 0, 35)
			desc.Size = UDim2.new(1, -130, 0, 30)
			desc.Text = b.desc
			desc.TextWrapped = true
			desc.TextColor3 = Color3.fromRGB(200, 200, 200)
			desc.Font = Enum.Font.Gotham
			desc.TextSize = 14
			desc.BackgroundTransparency = 1
			desc.TextXAlignment = Enum.TextXAlignment.Left
			local stat = InstanceNew("TextLabel", f)
			stat.Position = UDim2.new(0, 120, 0, 65)
			stat.Size = UDim2.new(1, -130, 0, 50)
			stat.Text = Format("Win: %.2f%% | Awarded: %d | 24h: %d\nFrom: %s", b.rarity, b.awarded, b.pastDay, b.universe)
			stat.TextColor3 = Color3.fromRGB(160, 160, 160)
			stat.Font = Enum.Font.Gotham
			stat.TextSize = 13
			stat.TextWrapped = true
			stat.BackgroundTransparency = 1
			stat.TextXAlignment = Enum.TextXAlignment.Left
		end
		closeBtn.MouseButton1Click:Connect(function()
			local tween = TweenService:Create(main, TweenInfo.new(0.4), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0)
			})
			tween:Play()
			tween.Completed:Wait()
			sgui:Destroy()
		end)
		local minimized = false
		minBtn.MouseButton1Click:Connect(function()
			local target = minimized and UDim2.new(0.5,0,0.7,0) or UDim2.new(0.5,0,0.07,0)
			local tween = TweenService:Create(main, TweenInfo.new(0.3), {Size = target})
			tween:Play()
			minimized = not minimized
		end)
		NAgui.dragger(main, top)
	end
	local ok, result = NACaller(getBadges)
	if ok then
		createBadgeUI(result)
	else
		DoNotif("Failed to fetch badge data")
	end
end)

cmd.add({"bodytransparency","btransparency", "bodyt"}, {"bodytransparency <number> (btransparency,bodyt)", "Sets LocalTransparencyModifier of bodyparts to whatever number you put (0-1)"}, function(v)
	local vv = tonumber(v) or 0

	NAlib.disconnect("body_transparency")

	NAlib.connect("body_transparency", RunService.Stepped:Connect(function()
		local char = LocalPlayer.Character
		if char then
			for _, p in ipairs(char:GetChildren()) do
				if p:IsA("BasePart") and p.Name:lower() ~= "head" then
					p.LocalTransparencyModifier = vv
				end
			end
		end
	end))

	DebugNotif("Body transparency set to "..vv, 1.5)
end, true)

cmd.add({"unbodytransparency", "unbtransparency", "unbodyt"}, {"unbodytransparency (unbtransparency,unbodyt)", "Stops transparency loop"}, function()
	if NAlib.isConnected("body_transparency") then
		NAlib.disconnect("body_transparency")
	else
		DebugNotif("No loop running", 2)
	end
end)

cmd.add({"animationspeed", "animspeed", "aspeed"}, {"animationspeed <speed> (animspeed,aspeed)", "Adjusts the speed of currently playing animations"}, function(speed)
	local targetSpeed = tonumber(speed) or 1

	NAlib.disconnect("animation_speed")

	NAlib.connect("animation_speed", RunService.Stepped:Connect(function()
		local character = getChar()
		local humanoid = getHum() or character:FindFirstChildOfClass("AnimationController")
		if humanoid then
			for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
				if track and track:IsA("AnimationTrack") then
					track:AdjustSpeed(targetSpeed)
				end
			end
		end
	end))

	DebugNotif("Animation speed set to "..targetSpeed)
end, true)

cmd.add({"unanimationspeed", "unanimspeed", "unaspeed"}, {"unanimationspeed (unanimspeed,unaspeed)", "Stops the animation speed adjustment loop"}, function()
	if NAlib.isConnected("animation_speed") then
		NAlib.disconnect("animation_speed")
		DebugNotif("Animation speed disabled")
	else
		DebugNotif("No active animation speed to disable")
	end
end)

cmd.add({"placeid","pid"},{"placeid (pid)","Copies the PlaceId of the game you're in"},function()
	setclipboard(tostring(PlaceId))

	Wait();

	DebugNotif("Copied the game's PlaceId: "..PlaceId)
end)

cmd.add({"gameid","universeid","gid"},{"gameid (universeid,gid)","Copies the GameId/Universe Id of the game you're in"},function()
	setclipboard(tostring(GameId))

	Wait();

	DebugNotif("Copied the game's GameId: "..GameId)
end)

cmd.add({"firework"}, {"firework", "pop"}, function()
	local character = LocalPlayer.Character
	if not character then return end

	local root = getRoot(character)
	local humanoid = getHum()
	if not root or not humanoid then return end

	humanoid.PlatformStand = true

	local part = InstanceNew("Part")
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.Parent = workspace

	local weld = InstanceNew("Weld")
	weld.Part0 = part
	weld.Part1 = root
	weld.C0 = CFrame.new()
	weld.Parent = part

	local bv = InstanceNew("BodyVelocity")
	bv.Velocity = Vector3.new(0, 50, 0)
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Parent = part

	local bg = InstanceNew("BodyGyro")
	bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bg.P = 10000
	bg.D = 0
	bg.Parent = part

	local spinTime = 3
	local spinSpeed = 720
	local startTime = tick()
	local angle = 0

	NAlib.connect("firework_spin", RunService.Heartbeat:Connect(function(dt)
		if tick() - startTime > spinTime then
			NAlib.disconnect("firework_spin")
			bv:Destroy()
			bg:Destroy()
			part:Destroy()

			local explosion = InstanceNew("Explosion")
			explosion.Position = root.Position
			explosion.BlastRadius = 6
			explosion.BlastPressure = 500000
			explosion.Parent = workspace

			humanoid.Health = 0
			return
		end

		angle = angle + math.rad(spinSpeed * dt)
		bg.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, angle, 0)
	end))
end)

cmd.add({"placename","pname"},{"placename (pname)","Copies the game's place name to your clipboard"},function()
	placeNaem = placeName()
	setclipboard(placeNaem)

	Wait();

	DebugNotif("Copied the game's place name: "..placeNaem)
end)

cmd.add({"gameinfo","ginfo"},{"gameinfo (ginfo)","shows info about the game you're playing"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/GameInfo.lua"))()
end)

cmd.add({"copyname", "cname"}, {"copyname <player> (cname)", "Copies the username of the target"}, function(...)
	local usr = ...
	local tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.Name))
		Wait()
		DebugNotif("Copied the username of "..nameChecker(plr))
	end
end, true)

cmd.add({"copydisplay", "cdisplay"}, {"copydisplay <player> (cdisplay)", "Copies the display name of the target"}, function(...)
	local usr = ...
	local tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.DisplayName))
		Wait()
		DebugNotif("Copied the display name of "..nameChecker(plr))
	end
end, true)

cmd.add({"copyid", "id"}, {"copyid <player> (id)", "Copies the UserId of the target"}, function(...)
	local usr = ...
	local tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.UserId))
		Wait()
		DebugNotif("Copied the UserId of "..nameChecker(plr))
	end
end, true)

--[ PLAYER ]--
function toggleKB(enable)
	local p = Players.LocalPlayer
	local hrp = getRoot(p.Character)
	local parts = workspace:GetPartBoundsInRadius(hrp.Position, 10)
	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			part.CanTouch = enable
		end
	end
end

cmd.add({"antikillbrick", "antikb"}, {"antikillbrick (antikb)", "Prevents kill bricks from killing you"}, function()
	toggleKB(false)
end)

cmd.add({"unantikillbrick", "unantikb"}, {"unantikillbrick (unantikb)", "Allows kill bricks to kill you"}, function()
	toggleKB(true)
end)

cmd.add({"height","hipheight","hh"},{"height <number> (hipheight,hh)","Changes your hipheight"},function(...)
	getHum().HipHeight=(...)
end,true)

cmd.add({"netbypass", "netb"}, {"netbypass (netb)", "Net bypass"}, function()
	Wait()
	DebugNotif("Netbypass enabled")
	local fenv = getfenv()
	local shp = fenv.sethiddenproperty or fenv.set_hidden_property or fenv.sethiddenprop or fenv.set_hidden_prop
	local ssr = fenv.setsimulationradius or fenv.setsimradius or fenv.set_simulation_radius
	net = shp and function(r) shp(lp, "SimulationRadius", r) end or ssr
end)

cmd.add({"day"},{"day","Makes it day"},function()
	Lighting.ClockTime=14
end)

cmd.add({"night"},{"night","Makes it night"},function()
	Lighting.ClockTime=0
end)

cmd.add({"time"}, {"time <number>", "Sets the time"}, function(...)
	local time = {...}
	if time then Lighting.ClockTime = time[1] end
end, true)

cmd.add({"chat", "message"}, {"chat <text> (message)", "Chats for you, useful if you're muted"}, function(...)
	local chatMessage = Concat({...}, " ")
	local chatTarget = "All"
	NAlib.LocalPlayerChat(chatMessage, chatTarget)
end, true)

cmd.add({"privatemessage", "pm"}, {"privatemessage <player> <text> (pm)", "Sends a private message to a player"}, function(...)
	local args = {...}
	local Player = getPlr(args[1])

	for _, plr in next, Player do
		local chatMessage = Concat(args, " ", 2)
		local chatTarget = plr.Name
		local result = NAlib.LocalPlayerChat(chatMessage, chatTarget)
		if result == "Hooking" then
			Wait(.5)
			NAlib.LocalPlayerChat(chatMessage, chatTarget)
		end
	end
end,true)

cmd.add({"mimicchat", "mimic"}, {"mimicchat <player> (mimic)", "Mimics the chat of a player"}, function(name)
	NAlib.disconnect("mimicchat")

	local targets = getPlr(name)
	if #targets == 0 then
		DoNotif("Player not found",2)
		return
	end

	for _, plr in pairs(targets) do
		DebugNotif("Now mimicking "..plr.Name.."'s chat", 2)

		NAlib.connect("mimicchat", plr.Chatted:Connect(function(msg)
			NAlib.LocalPlayerChat(msg, "All")
		end))
	end
end, true)

cmd.add({"stopmimic", "unmimic"}, {"stopmimic (unmimic)", "Stops mimicking a player"}, function()
	NAlib.disconnect("mimicchat")
	DebugNotif("Stopped mimicking", 2)
end, true)

cmd.add({"fixcam", "fix"}, {"fixcam", "Fix your camera"}, function()
	local ws = workspace
	local plr = Players.LocalPlayer
	ws.CurrentCamera:Remove()
	Wait(0.1)
	repeat Wait() until plr.Character
	local cam = ws.CurrentCamera
	cam.CameraSubject = getHum()
	cam.CameraType = "Custom"
	plr.CameraMinZoomDistance = 0.5
	plr.CameraMaxZoomDistance = math.huge
	plr.CameraMode = "Classic"
	getHead(plr.Character).Anchored = false
end)

cmd.add({"saw"}, {"saw <challenge>", "shush"}, function(...)
	local challenge = Concat({...}, " ")
	getgenv().SawFinish = false

	local function playSound(id, vol)
		local sfx = InstanceNew("Sound")
		sfx.Parent = PlrGui
		sfx.SoundId = "rbxassetid://"..id
		sfx.Volume = vol or 1
		sfx:Play()
		sfx.Ended:Connect(function()
			sfx:Destroy()
		end)
	end

	local function createUIElement(class, properties, parent)
		local element = InstanceNew(class)
		for prop, value in pairs(properties) do
			element[prop] = value
		end
		if parent then element.Parent = parent end
		return element
	end

	local ScreenGui = createUIElement("ScreenGui", { Name = '\0' })
	NaProtectUI(ScreenGui)

	local background = createUIElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 0
	}, ScreenGui)

	local staticOverlay = createUIElement("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Image = "rbxassetid://259236205",
		ImageTransparency = 0.8,
		ZIndex = 1
	}, background)

	coroutine.wrap(function()
		while not getgenv().SawFinish do
			local tween = TweenService:Create(
				staticOverlay,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ ImageTransparency = math.random(0.7, 0.9), Position = UDim2.new(math.random(-0.01, 0.01), 0, math.random(-0.01, 0.01), 0) }
			)
			tween:Play()
			Wait(math.random(0.05, 0.2))
		end
	end)()

	local bgTween = TweenService:Create(
		background,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.5 }
	)
	bgTween:Play()

	local progressBar = createUIElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(50, 50, 50),
		Position = UDim2.new(0.25, 0, 0.05, 0),
		Size = UDim2.new(0.5, 0, 0.03, 0),
		BorderSizePixel = 0,
		ZIndex = 2
	}, ScreenGui)

	local progressFill = createUIElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		ZIndex = 3
	}, progressBar)

	local imgLabel = createUIElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.1, 0),
		Size = UDim2.new(0, 150, 0, 150),
		Image = "rbxassetid://8747893766",
		ImageColor3 = Color3.fromRGB(255, 0, 0),
		ZIndex = 2
	}, ScreenGui)

	coroutine.wrap(function()
		while not getgenv().SawFinish do
			local newSize = math.random(140, 160)
			local newRotation = math.random(-10, 10)
			local tween = TweenService:Create(
				imgLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ Size = UDim2.new(0, newSize, 0, newSize), Rotation = newRotation, ImageColor3 = Color3.fromRGB(math.random(200, 255), 0, 0) }
			)
			tween:Play()
			tween.Completed:Wait()
			if math.random() < 0.2 then
				local glitchTween = TweenService:Create(
					imgLabel,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{ ImageTransparency = math.random(0.3, 0.7), Position = UDim2.new(0.5 + math.random(-0.05, 0.05), 0, 0.1 + math.random(-0.05, 0.05), 0) }
				)
				glitchTween:Play()
				glitchTween.Completed:Wait()
				local resetTween = TweenService:Create(
					imgLabel,
					TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
					{ ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.1, 0) }
				)
				resetTween:Play()
			end
		end
	end)()

	local ttLabelLeft = createUIElement("TextLabel", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.3,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0.05, 0, 0.5, 0),
		Size = UDim2.new(0.4, 0, 0.1, 0),
		Font = Enum.Font.SciFi,
		Text = "Challenge: "..challenge,
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextSize = 24,
		TextStrokeColor3 = Color3.fromRGB(100, 0, 0),
		TextStrokeTransparency = 0.5,
		TextWrapped = true,
		ZIndex = 3
	}, ScreenGui)

	local ttLabelRight = createUIElement("TextLabel", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.3,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(0.95, 0, 0.5, 0),
		Size = UDim2.new(0.4, 0, 0.1, 0),
		Font = Enum.Font.SciFi,
		Text = "Time Remaining: 180 seconds",
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextSize = 24,
		TextStrokeColor3 = Color3.fromRGB(100, 0, 0),
		TextStrokeTransparency = 0.5,
		TextWrapped = true,
		ZIndex = 3
	}, ScreenGui)

	local dramaticLabel = createUIElement("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.7, 0),
		Size = UDim2.new(0.5, 0, 0.2, 0),
		Font = Enum.Font.SciFi,
		Text = "",
		TextColor3 = Color3.fromRGB(255, 0, 0),
		TextSize = 50,
		TextStrokeTransparency = 0.5,
		TextWrapped = true,
		ZIndex = 4
	}, ScreenGui)

	local function flickerText()
		while not getgenv().SawFinish do
			local newColor = Color3.fromRGB(math.random(200, 255), 0, 0)
			ttLabelLeft.TextColor3 = newColor
			ttLabelRight.TextColor3 = newColor
			ttLabelLeft.TextStrokeTransparency = math.random(0.4, 0.7)
			ttLabelRight.TextStrokeTransparency = math.random(0.4, 0.7)
			ttLabelLeft.Text = "Challenge: "..challenge:sub(1, math.random(1, #challenge))
			Wait(math.random(0.05, 0.15))
		end
	end

	local function dramaticCountdown(num)
		dramaticLabel.Text = tostring(num)
		playSound(138081500, 2)
		for i = 1, 5 do
			local shakeTween = TweenService:Create(
				dramaticLabel,
				TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ Position = UDim2.new(0.5 + math.random(-0.02, 0.02), 0, 0.7 + math.random(-0.02, 0.02), 0) }
			)
			shakeTween:Play()
			shakeTween.Completed:Wait()
		end
		local resetTween = TweenService:Create(
			dramaticLabel,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ Position = UDim2.new(0.5, 0, 0.7, 0) }
		)
		resetTween:Play()
		Wait(1)
		dramaticLabel.Text = ""
	end

	local ambientSound = InstanceNew("Sound")
	ambientSound.Parent = PlrGui
	ambientSound.SoundId = "rbxassetid://1846090198"
	ambientSound.Volume = 0.2
	ambientSound.Looped = true
	ambientSound:Play()

	local function count()
		local num = 180
		while Wait(1) do
			if not getgenv().SawFinish then
				if num > 0 then
					num = num - 1
					playSound(138081500, num <= 10 and 2 or 1)
					ttLabelRight.Text = "Time Remaining: "..num.." seconds"

					local progress = num / 180
					local jitter = math.random(-0.02, 0.02)
					local tween = TweenService:Create(
						progressFill,
						TweenInfo.new(1, Enum.EasingStyle.Linear),
						{ Size = UDim2.new(progress + jitter, 0, 1, 0), BackgroundColor3 = num <= 30 and Color3.fromRGB(math.random(200, 255), math.random(0, 50), 0) or Color3.fromRGB(255, 0, 0) }
					)
					tween:Play()

					if num == 30 or num == 20 or num == 10 then
						dramaticCountdown(num)
					elseif num <= 10 then
						dramaticLabel.Text = tostring(num)
						playSound(138081500, 2)
					end
				else
					local flash = createUIElement("Frame", {
						BackgroundColor3 = Color3.fromRGB(255, 0, 0),
						BackgroundTransparency = 0,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 10
					}, ScreenGui)
					playSound(9125915751, 5)
					Wait(0.2)
					flash:Destroy()
					Players.LocalPlayer:Kick("You Failed The Challenge")
				end
			else
				ttLabelLeft.Text = "You Survived... For Now"
				ttLabelRight.Text = ""
				dramaticLabel.Text = "I'll be watching..."
				local distortion = createUIElement("Frame", {
					BackgroundColor3 = Color3.fromRGB(100, 0, 0),
					BackgroundTransparency = 0.7,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 5
				}, ScreenGui)
				local glitchOverlay = createUIElement("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Image = "rbxassetid://259236205",
					ImageTransparency = 0.5,
					ZIndex = 6
				}, distortion)
				playSound(9125915751, 5)
				for i = 1, 3 do
					local glitchTween = TweenService:Create(
						glitchOverlay,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
						{ Position = UDim2.new(math.random(-0.05, 0.05), 0, math.random(-0.05, 0.05), 0), ImageTransparency = math.random(0.3, 0.7) }
					)
					glitchTween:Play()
					Wait(0.15)
				end
				local fadeTween = TweenService:Create(
					dramaticLabel,
					TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ TextTransparency = 1 }
				)
				local distortionFade = TweenService:Create(
					distortion,
					TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ BackgroundTransparency = 1 }
				)
				local glitchFade = TweenService:Create(
					glitchOverlay,
					TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ ImageTransparency = 1 }
				)
				fadeTween:Play()
				distortionFade:Play()
				glitchFade:Play()
				Wait(3)
				ScreenGui:Destroy()
				ambientSound:Destroy()
				break
			end
		end
	end

	coroutine.wrap(count)()
	coroutine.wrap(flickerText)()
end, true)

cmd.add({"jend"}, {"jend", "nil"}, function()
	getgenv().SawFinish = true
end)

cmd.add({"fling"}, {"fling <player>", "Fling the given player"}, function(plr)
	local Players = game.GetService(game,"Players")
	local LocalPlayer    = Players.LocalPlayer
	local Character      = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid       = getPlrHum(Character)
	local RootPart       = Humanoid and Humanoid.RootPart
	if not RootPart then return end

	local AllBool = false
	local function GetPlayer(Name)
		Name = Lower(Name)
		if Name == "all" or Name == "others" then
			AllBool = true
			return
		elseif Name == "random" then
			local list = Players:GetPlayers()
			if Discover(list, LocalPlayer) then
				table.remove(list, Discover(list, LocalPlayer))
			end
			return list[math.random(#list)]
		end
		for _, x in next, Players:GetPlayers() do
			if x ~= LocalPlayer then
				if Sub(Lower(x.Name), 1, #Name) == Name or Sub(Lower(x.DisplayName), 1, #Name) == Name then
					return x
				end
			end
		end
	end

	local flingManager       = flingManager
	local OrgDestroyHeight   = workspace.FallenPartsDestroyHeight

	local function SkidFling(TargetPlayer)
		local Character = LocalPlayer.Character
		local Humanoid  = getPlrHum(Character)
		local RootPart  = Humanoid and Humanoid.RootPart
		local TChar     = TargetPlayer.Character
		local THumanoid = getPlrHum(TChar)
		local TRootPart = THumanoid and THumanoid.RootPart
		local THead     = getHead(TChar)
		local Acc       = TChar:FindFirstChildOfClass("Accessory")
		local Handle    = Acc and Acc:FindFirstChild("Handle")

		if Character and Humanoid and RootPart then
			if not flingManager.cFlingOldPos or RootPart.Velocity.Magnitude < 50 then
				flingManager.cFlingOldPos = RootPart.CFrame
			end

			if THead then
				workspace.CurrentCamera.CameraSubject = THead
			elseif Handle then
				workspace.CurrentCamera.CameraSubject = Handle
			elseif THumanoid and TRootPart then
				workspace.CurrentCamera.CameraSubject = THumanoid
			end

			if not TChar:FindFirstChildWhichIsA("BasePart") then return end

			local function FPos(BasePart, Pos, Ang)
				RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
				Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
				RootPart.Velocity    = Vector3.new(9e7, 9e7*10, 9e7)
				RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
			end

			local function SFBasePart(BasePart)
				local TimeToWait = 2
				local Time       = tick()
				local Angle      = 0
				repeat
					if RootPart and THumanoid then
						if BasePart.Velocity.Magnitude < 50 then
							Angle = Angle + 100
							FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(2.25,1.5,-2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(-2.25,-1.5,2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) Wait()
						else
							FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,-THumanoid.WalkSpeed), CFrame.Angles(0,0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,-TRootPart.Velocity.Magnitude/1.25), CFrame.Angles(0,0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,TRootPart.Velocity.Magnitude/1.25), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(-90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) Wait()
						end
					else
						break
					end
				until BasePart.Velocity.Magnitude > 500
					or BasePart.Parent ~= TargetPlayer.Character
					or TargetPlayer.Parent ~= Players
					or TargetPlayer.Character ~= TChar
					or THumanoid.Sit
					or Humanoid.Health <= 0
					or tick() > Time + TimeToWait
			end

			workspace.FallenPartsDestroyHeight = 0/0

			local BV = InstanceNew("BodyVelocity")
			BV.Parent    = RootPart
			BV.Velocity  = Vector3.new(9e8,9e8,9e8)
			BV.MaxForce  = Vector3.new(1/0,1/0,1/0)

			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

			if TRootPart and THead then
				if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
					SFBasePart(THead)
				else
					SFBasePart(TRootPart)
				end
			elseif TRootPart then
				SFBasePart(TRootPart)
			elseif THead then
				SFBasePart(THead)
			elseif Handle then
				SFBasePart(Handle)
			end

			BV:Destroy()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			workspace.CurrentCamera.CameraSubject = Humanoid

			repeat
				RootPart.CFrame                  = flingManager.cFlingOldPos * CFrame.new(0, .5, 0)
				Character:SetPrimaryPartCFrame( flingManager.cFlingOldPos * CFrame.new(0, .5, 0) )
				Humanoid:ChangeState("GettingUp")
				for _, x in next, Character:GetChildren() do
					if x:IsA("BasePart") then
						x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
					end
				end
				Wait()
			until (RootPart.Position - flingManager.cFlingOldPos.p).Magnitude < 25

			workspace.FallenPartsDestroyHeight = OrgDestroyHeight
		end
	end

	local targets = {}
	for _, name in next, {plr} do
		local p = GetPlayer(name)
		if p then Insert(targets, p) end
	end

	if AllBool then
		for _, p in next, Players:GetPlayers() do
			if p ~= LocalPlayer then SkidFling(p) end
		end
	else
		for _, p in next, targets do
			SkidFling(p)
		end
	end
end)

cmd.add({"commitoof", "suicide", "kys"}, {"commitoof (suicide, kys)", "Triggers a dramatic oof sequence for the player"}, function()
	local p = Players.LocalPlayer
	if not p then
		return
	end

	local c = p.Character
	if not c then
		c = p.CharacterAdded:Wait()
	end

	local h = getPlrHum(c)
	if not h then
		return
	end

	local r = getRoot(c)
	if not r then
		return
	end

	NAlib.LocalPlayerChat("Okay... I will do it.", "All")
	Wait(1.5)
	NAlib.LocalPlayerChat("I will oof now...", "All")
	Wait(1.5)
	NAlib.LocalPlayerChat("Goodbye, cruel world.", "All")
	Wait(2)

	h:MoveTo(r.Position + r.CFrame.LookVector * 10)
	h:ChangeState(Enum.HumanoidStateType.Jumping)
	Wait(0.45)

	cmd.run({'die'})
end)

cmd.add({"volume","vol"},{"volume <1-10> (vol)","Changes your volume"},function(vol)
	amount=vol/10
	UserSettings():GetService("UserGameSettings").MasterVolume=amount
end,true)

cmd.add({"sensitivity","sens"},{"sensitivity <1-10> (sens)","Changes your sensitivity"},function(ss)
	UserInputService.MouseDeltaSensitivity=ss
end,true)

cmd.add({"torandom","tr"},{"torandom (tr)","Teleports to a random player"},function()
	target=getPlr("random")
	for _, plr in next, target do
		getRoot(getChar()).CFrame=getPlrHum(plr).RootPart.CFrame
	end
end)

cmd.add({"timestop", "tstop"}, {"timestop (tstop)", "freezes all players (ZA WARUDO)"}, function()
	local target = getPlr("others")
	if #target == 0 then return end

	for _, plr in pairs(Players:GetPlayers()) do
		NAlib.disconnect("timestop_char_"..plr.UserId)
	end
	NAlib.disconnect("timestop_playeradd")

	for _, plr in pairs(target) do
		local char = getPlrChar(plr)
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Anchored = true
				end
			end
		end

		NAlib.connect("timestop_char_"..plr.UserId, plr.CharacterAdded:Connect(function(char)
			while not getRoot(char) do Wait(.1) end
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Anchored = true
				end
			end
		end))
	end

	NAlib.connect("timestop_playeradd", Players.PlayerAdded:Connect(function(plr)
		NAlib.connect("timestop_char_"..plr.UserId, plr.CharacterAdded:Connect(function(char)
			while not getRoot(char) do Wait(.1) end
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Anchored = true
				end
			end
		end))
	end))
end)

cmd.add({"untimestop", "untstop"}, {"untimestop (untstop)", "unfreeze all players"}, function()
	local target = getPlr("all")
	if #target == 0 then return end

	for _, plr in pairs(Players:GetPlayers()) do
		NAlib.disconnect("timestop_char_"..plr.UserId)
	end
	NAlib.disconnect("timestop_playeradd")

	for _, plr in pairs(target) do
		local char = getPlrChar(plr)
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Anchored = false
				end
			end
		end
	end
end)

cmd.add({"char","character","morph"},{"char <username/userid>","change your character's appearance to someone else's"},function(args,returner)
	local arg=args
	local plrplr = returner or Players.LocalPlayer
	local uid=tonumber(arg)
	if not uid then
		local ok,id=NACaller(Players.GetUserIdFromNameAsync,Players,arg)
		if not ok then return end
		uid=id
	end
	local function aa(c,id)
		local a=game:GetObjects("rbxassetid://"..id)[1]
		if not(a and a:IsA("Accessory"))then return end
		for _,v in ipairs(a:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false v.Massless=true end end
		a.Parent=c
		local h=a:FindFirstChild("Handle") if not h then return end
		local at={} for _,ch in ipairs(h:GetChildren())do if ch:IsA("Attachment")then at[#at+1]=ch end end
		local ok2
		for _,ac in ipairs(at)do
			local ra=c:FindFirstChild(ac.Name,true)
			if ra and ra:IsA("Attachment")then
				h.CFrame=ra.WorldCFrame*ac.CFrame:Inverse()
				local w=InstanceNew("WeldConstraint")
				w.Part0,w.Part1,w.Parent=ra.Parent,h,h
				ok2=true break
			end
		end
		if not ok2 then
			local hd=getHead(c) or getRoot(c)
			if hd then
				h.CFrame=hd.CFrame
				local w=InstanceNew("WeldConstraint")
				w.Part0,w.Part1,w.Parent=hd,h,h
			end
		end
	end
	local function ap()
		local c=getPlrChar(plrplr)
		for _,x in ipairs(c:GetChildren())do if x:IsA("Accessory")or x:IsA("CharacterMesh")or x:IsA("Shirt")or x:IsA("Pants")or x:IsA("ShirtGraphic")then x:Destroy()end end
		local d=Players:GetHumanoidDescriptionFromUserId(uid)
		local ar=Players:GetCharacterAppearanceAsync(uid)
		for _,info in ipairs(d:GetAccessories(true))do aa(c,info.AssetId)end
		local hum=getPlrHum(plrplr)
		if hum and hum:FindFirstChild("HumanoidDescription")then
			local pd=hum.HumanoidDescription
			pd.BodyTypeScale,pd.DepthScale,pd.HeadScale,pd.HeightScale,pd.ProportionScale,pd.WidthScale=
				d.BodyTypeScale,d.DepthScale,d.HeadScale,d.HeightScale,d.ProportionScale,d.WidthScale
		end
		local bc=c:FindFirstChildOfClass("BodyColors")
		if bc then
			bc.HeadColor3,bc.LeftArmColor3,bc.LeftLegColor3,bc.RightArmColor3,bc.RightLegColor3,bc.TorsoColor3=
				d.HeadColor,d.LeftArmColor,d.LeftLegColor,d.RightArmColor,d.RightLegColor,d.TorsoColor
		end
		local hd=getHead(c)
		if hd then for _,dec in ipairs(hd:GetChildren())do if dec:IsA("Decal")then dec:Destroy()end end end
		for _,v in ipairs(ar:GetDescendants())do
			if IsR6(plrplr) and v:IsA("CharacterMesh")then
				v:Clone().Parent=c
			elseif IsR15(plrplr) and v:IsA("MeshPart")then
				local tp=c:FindFirstChild(v.Name,true)
				if tp then tp.MeshId,tp.TextureID=v.MeshId,v.TextureID end
			elseif v:IsA("Shirt")or v:IsA("Pants")or v:IsA("ShirtGraphic")then
				v:Clone().Parent=c
			elseif v:IsA("Decal")and Lower(v.Name)=="face"then
				v:Clone().Parent=hd
			end
		end
		if IsR15(plrplr) then
			local b={LeftFoot="7430071039",LeftHand="7430070991",LeftLowerArm="7430071005",LeftLowerLeg="7430071049",
				LeftUpperArm="7430071044",LeftUpperLeg="7430071065",LowerTorso="7430071109",RightFoot="7430071082",
				RightHand="7430070997",RightLowerArm="7430071013",RightLowerLeg="7430071105",RightUpperArm="7430071041",
				RightUpperLeg="7430071119",UpperTorso="7430071038"}
			for name,id2 in pairs(b)do
				local found=false
				for _,v in ipairs(ar:GetDescendants())do if v:IsA("MeshPart")and v.Name==name then found=true break end end
				if not found then
					local mp=c:FindFirstChild(name)
					if mp and mp:IsA("MeshPart")then
						mp.MeshId="https://assetdelivery.roblox.com/v1/asset/?id="..id2
					end
				end
			end
		end
	end
	ap()
	if not returner then
		Players:Chat("!IY "..args)
	end
end,true)

cmd.add({"unchar"},{"unchar","revert to your character"},function()
	local naem=Players.LocalPlayer.Name
	cmd.run({"char", naem})
end)

cmd.add({"autochar","achar"},{"autochar","auto-change your character on respawn"},function(args)
	local target = args
	if not target then return end
	NAlib.disconnect("autochar")
	NAlib.connect("autochar", Players.LocalPlayer.CharacterAdded:Connect(function()
		cmd.run({"char", target})
	end))
	cmd.run({"char", target})
end, true)

cmd.add({"unautochar","unachar"},{"unautochar","stop auto-change on respawn"},function()
	NAlib.disconnect("autochar")
end)

cmd.add({"goto","to","tp","teleport"},{"goto <player|X,Y,Z>","Teleport to the given player or X,Y,Z coordinates"},function(...)
	local input   = Concat({...}," ")
	local targets = getPlr(input)
	local char    = getChar()
	if #targets > 0 then
		for _,plr in ipairs(targets) do
			char:PivotTo(plr.Character:GetPivot())
		end
	else
		local x,y,z = input:match("^(%-?%d+%.?%d*)[,%s]+(%-?%d+%.?%d*)[,%s]+(%-?%d+%.?%d*)$")
		if x and y and z then
			char:PivotTo(CFrame.new(tonumber(x),tonumber(y),tonumber(z)))
		else
			DebugNotif("Invalid input: not a valid player or X,Y,Z coordinates",3)
		end
	end
end,true)

function stareFIXER(char, facePos)
	local root = getRoot(char)
	if not root then return end
	local pos = root.Position
	local flatTarget = Vector3.new(facePos.X, pos.Y, facePos.Z)
	if (flatTarget - pos).Magnitude < 0.1 then return end
	root.CFrame = CFrame.new(pos, flatTarget)
end

cmd.add({"lookat", "stare"}, {"lookat <player>", "Stare at a player"}, function(...)
	local Username = (...)
	local Target = getPlr(Username)

	for _, plr in next, Target do
		NAlib.disconnect("stare_direct")

		local lp = Players.LocalPlayer
		if not (lp.Character and getRoot(lp.Character)) then return end
		if not (plr and plr.Character and getRoot(plr.Character)) then return end

		getHum().AutoRotate = false

		local function Stare()
			if lp.Character and plr.Character and getRoot(plr.Character) then
				stareFIXER(lp.Character, getRoot(plr.Character).Position)
			elseif not Players:FindFirstChild(plr.Name) then
				NAlib.disconnect("stare_direct")
			end
		end

		NAlib.connect("stare_direct", RunService.RenderStepped:Connect(Stare))
	end
end, true)

cmd.add({"unlookat", "unstare"}, {"unlookat", "Stops staring"}, function()
	NAlib.disconnect("stare_direct")
	if getHum() then
		getHum().AutoRotate = true
	end
end)

cmd.add({"starenear", "stareclosest"}, {"starenear (stareclosest)", "Stare at the closest player"}, function()
	NAlib.disconnect("stare_nearest")

	local function getClosest()
		local lp = Players.LocalPlayer
		local char = lp.Character
		if not (char and getRoot(char)) then return nil end

		local closest, dist = nil, math.huge
		local pos = getRoot(char).Position
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= lp and p.Character and getRoot(p.Character) then
				local pPos = getRoot(p.Character).Position
				local d = (pPos - pos).Magnitude
				if d < dist then
					dist = d
					closest = p
				end
			end
		end
		return closest
	end

	local lp = Players.LocalPlayer
	if getHum() then
		getHum().AutoRotate = false
	end

	local function stare()
		local lp = Players.LocalPlayer
		local char = lp.Character
		if not (char and getRoot(char)) then return end
		local target = getClosest()
		if target and target.Character and getRoot(target.Character) then
			stareFIXER(char, getRoot(target.Character).Position)
		end
	end

	NAlib.connect("stare_nearest", RunService.RenderStepped:Connect(stare))
end)

cmd.add({"unstarenear", "unstareclosest"}, {"unstarenear (unstareclosest)", "Stop staring at closest player"}, function()
	NAlib.disconnect("stare_nearest")
	if getHum() then
		getHum().AutoRotate = true
	end
end)

local specUI = nil
local connStep, connAdd, connRemove = nil, nil, nil

function cleanup()
	NAlib.disconnect("spectate_char")
	NAlib.disconnect("spectate_loop")
	NAlib.disconnect("spectate_leave")

	if connStep then connStep:Disconnect() connStep = nil end
	if connAdd then connAdd:Disconnect() connAdd = nil end
	if connRemove then connRemove:Disconnect() connRemove = nil end

	if specUI then specUI:Destroy() specUI = nil end

	local hum = getHum()
	local cam = workspace.CurrentCamera
	if hum then cam.CameraSubject = hum end
end

function spectatePlayer(targetPlayer)
	if not targetPlayer then return end

	NAlib.disconnect("spectate_char")
	NAlib.disconnect("spectate_loop")
	NAlib.disconnect("spectate_leave")

	NAlib.connect("spectate_char", targetPlayer.CharacterAdded:Connect(function(character)
		while not getPlrHum(character) do Wait(.1) end
		workspace.CurrentCamera.CameraSubject = getPlrHum(character)
	end))

	NAlib.connect("spectate_leave", Players.PlayerRemoving:Connect(function(player)
		if player == targetPlayer then
			cleanup()
			DebugNotif("Player left - camera reset")
		end
	end))

	local loop = coroutine.create(function()
		while true do
			if getPlrHum(targetPlayer) then
				workspace.CurrentCamera.CameraSubject = getPlrHum(targetPlayer)
			end
			Wait()
		end
	end)
	NAlib.connect("spectate_loop", {
		Disconnect = function()
			if coroutine.status(loop) ~= "dead" then
				coroutine.close(loop)
			end
		end
	})
	coroutine.resume(loop)
end

cmd.add({"watch", "view", "spectate"}, {"watch <Player> (view, spectate)", "Spectate player"}, function(...)
	cleanup()
	local targetPlayer = getPlr((...))
	for _, plr in next, targetPlayer do
		if not plr then return end
		spectatePlayer(plr)
	end
end, true)

cmd.add({"unwatch", "unview"}, {"unwatch (unview)", "Stop spectating"}, function()
	cleanup()
end)

cmd.add({"watch2","view2","spectate2"},{"watch2",""},function()
	local LocalPlayer = Players.LocalPlayer
	local spectatedPlayer = nil
	local playerList, currentIndex = {}, 1
	local frame, titleLabel, toggleBtn, scroll, listOpen = false, false, false, false, false
	local baseTogglePos = 5

	local function rebuild()
		table.clear(playerList)
		for _, p in ipairs(Players:GetPlayers()) do
			Insert(playerList, p)
		end
		table.sort(playerList, function(a, b) return a.Name < b.Name end)
	end

	local function cam(p)
		local h = getPlrHum(p)
		workspace.CurrentCamera.CameraSubject = h or getRoot(p.Character) or p.Character:FindFirstChildWhichIsA("BasePart")
	end

	local function recolor()
		if not listOpen or not scroll then return end
		for _, btn in ipairs(scroll:GetChildren()) do
			if btn:IsA("TextButton") then
				local idx = btn:GetAttribute("idx")
				local lbl = btn:FindFirstChild("NameLabel")
				if idx and lbl then
					local plr = playerList[idx]
					if plr == LocalPlayer then
						lbl.TextColor3 = Color3.fromRGB(255, 255, 0)
					elseif idx == currentIndex then
						lbl.TextColor3 = Color3.fromRGB(0, 162, 255)
					else
						lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end
			end
		end
	end

	local function refresh()
		if not titleLabel then return end
		if #playerList == 0 then
			titleLabel.Text = "Spectating: None"
			spectatedPlayer = nil
			return
		end
		if spectatedPlayer and Discover(playerList, spectatedPlayer) then
			currentIndex = Discover(playerList, spectatedPlayer)
		else
			if currentIndex < 1 then currentIndex = 1 end
			if currentIndex > #playerList then currentIndex = 1 end
			spectatedPlayer = playerList[currentIndex]
		end
		local plr = playerList[currentIndex]
		if not plr then
			titleLabel.Text = "Spectating: None"
			spectatedPlayer = nil
			return
		end
		titleLabel.Text = "Spectating: "..nameChecker(plr)
		titleLabel.TextColor3 = (plr == LocalPlayer) and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(0, 162, 255)
		cam(plr)
		recolor()
	end

	local function updateDropdown()
		if not listOpen or not scroll then return end
		for _, child in ipairs(scroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for i, plr in ipairs(playerList) do
			local pb = InstanceNew("TextButton", scroll)
			pb.Size = UDim2.new(1, 0, 0, 30)
			pb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			pb.Font = Enum.Font.Gotham
			pb.Text = ""
			pb.LayoutOrder = i
			pb:SetAttribute("idx", i)
			InstanceNew("UICorner", pb).CornerRadius = UDim.new(0, 6)

			local img = InstanceNew("ImageLabel", pb)
			img.Size = UDim2.new(0, 30, 0, 30)
			img.BackgroundTransparency = 1
			img.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

			local nameLbl = InstanceNew("TextLabel", pb)
			nameLbl.Name = "NameLabel"
			nameLbl.BackgroundTransparency = 1
			nameLbl.Size = UDim2.new(1, -35, 1, 0)
			nameLbl.Position = UDim2.new(0, 35, 0, 0)
			nameLbl.Font = Enum.Font.Gotham
			nameLbl.TextScaled = true
			nameLbl.Text = nameChecker(plr)

			MouseButtonFix(pb, function()
				currentIndex = i
				spectatedPlayer = playerList[currentIndex]
				refresh()
			end)
		end
		local h = math.min(#playerList * 30, 300)
		scroll.CanvasSize = UDim2.new(0, 0, 0, #playerList * 30)
		scroll.Size = UDim2.new(1, 0, 0, h)
		toggleBtn.Position = UDim2.new(0.5, -15, 1, h + 10)
		recolor()
	end

	local function mkBtn(txt, pos, size, bg, ts, cb)
		local b = InstanceNew("TextButton", frame)
		b.Size = size or UDim2.new(0, 40, 0, 40)
		b.Position = pos
		b.BackgroundColor3 = bg or Color3.fromRGB(50, 50, 50)
		b.Text = txt
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBold
		b.TextSize = ts or 24
		InstanceNew("UICorner", b).CornerRadius = UDim.new(0, 10)
		MouseButtonFix(b, cb)
		return b
	end

	rebuild()
	if #playerList == 0 then return DebugNotif("No players to spectate", 2) end

	specUI = InstanceNew("ScreenGui")
	NaProtectUI(specUI)
	specUI.ResetOnSpawn = false
	specUI.DisplayOrder = 10
	frame = InstanceNew("Frame", specUI)
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Size = UDim2.new(0, 350, 0, 40)
	frame.Position = UDim2.new(0.5, 0, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	InstanceNew("UICorner", frame).CornerRadius = UDim.new(0, 20)
	NAgui.draggerV2(frame)

	titleLabel = InstanceNew("TextLabel", frame)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
	titleLabel.Position = UDim2.new(0.15, 0, 0, 0)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true

	mkBtn("<", UDim2.new(0, -18, 0, 0), nil, nil, nil, function()
		currentIndex = currentIndex - 1
		if currentIndex < 1 then currentIndex = #playerList end
		spectatedPlayer = playerList[currentIndex]
		refresh()
	end)
	mkBtn(">", UDim2.new(1, -22, 0, 0), nil, nil, nil, function()
		currentIndex = currentIndex + 1
		if currentIndex > #playerList then currentIndex = 1 end
		spectatedPlayer = playerList[currentIndex]
		refresh()
	end)
	mkBtn("X", UDim2.new(1, -55, 0, 5), UDim2.new(0, 30, 0, 30), Color3.fromRGB(255, 50, 50), 18, function()
		cleanup()
	end)

	toggleBtn = mkBtn("v", UDim2.new(0.5, -15, 1, baseTogglePos), UDim2.new(0, 30, 0, 20), Color3.fromRGB(40, 40, 40), 18, function()
		if listOpen then
			local tClose = TweenService:Create(scroll, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 0)})
			local tPos = TweenService:Create(toggleBtn, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -15, 1, baseTogglePos)})
			tClose:Play()
			tPos:Play()
			tClose.Completed:Wait()
			scroll:Destroy()
			scroll = nil
			listOpen = false
			toggleBtn.Text = "v"
		else
			scroll = InstanceNew("ScrollingFrame", frame)
			scroll.Size = UDim2.new(1, 0, 0, 0)
			scroll.Position = UDim2.new(0, 0, 1, 0)
			scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			scroll.BorderSizePixel = 0
			scroll.ScrollBarThickness = 8
			scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scroll.ClipsDescendants = true
			InstanceNew("UICorner", scroll).CornerRadius = UDim.new(0, 10)
			InstanceNew("UIListLayout", scroll).SortOrder = Enum.SortOrder.LayoutOrder

			local loading = InstanceNew("TextLabel", scroll)
			loading.Size = UDim2.new(1, 0, 0, 30)
			loading.BackgroundTransparency = 1
			loading.Font = Enum.Font.GothamSemibold
			loading.TextScaled = true
			loading.TextColor3 = Color3.fromRGB(255, 255, 255)
			loading.Text = "Loading..."

			Spawn(function()
				loading:Destroy()
				for i, plr in ipairs(playerList) do
					local pb = InstanceNew("TextButton", scroll)
					pb.Size = UDim2.new(1, 0, 0, 30)
					pb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					pb.Font = Enum.Font.Gotham
					pb.Text = ""
					pb.LayoutOrder = i
					pb:SetAttribute("idx", i)
					InstanceNew("UICorner", pb).CornerRadius = UDim.new(0, 6)

					local img = InstanceNew("ImageLabel", pb)
					img.Size = UDim2.new(0, 30, 0, 30)
					img.BackgroundTransparency = 1
					img.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

					local nameLbl = InstanceNew("TextLabel", pb)
					nameLbl.Name = "NameLabel"
					nameLbl.BackgroundTransparency = 1
					nameLbl.Size = UDim2.new(1, -35, 1, 0)
					nameLbl.Position = UDim2.new(0, 35, 0, 0)
					nameLbl.Font = Enum.Font.Gotham
					nameLbl.TextScaled = true
					nameLbl.Text = nameChecker(plr)

					MouseButtonFix(pb, function()
						currentIndex = i
						spectatedPlayer = playerList[currentIndex]
						refresh()
					end)
				end
				local h = math.min(#playerList * 30, 300)
				scroll.CanvasSize = UDim2.new(0, 0, 0, #playerList * 30)
				local open = TweenService:Create(scroll, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, h)})
				local move = TweenService:Create(toggleBtn, TweenInfo.new(0.25), {Position = UDim2.new(0.5, -15, 1, h + 10)})
				open:Play()
				move:Play()
				listOpen = true
				toggleBtn.Text = "^"
				recolor()
			end)
		end
	end)

	connStep = RunService.RenderStepped:Connect(function()
		if #playerList == 0 then return end
		local p = playerList[currentIndex]
		if not p or not p.Character then rebuild() end
		cam(playerList[currentIndex])
	end)
	connAdd = Players.PlayerAdded:Connect(function()
		rebuild()
		refresh()
		updateDropdown()
	end)
	connRemove = Players.PlayerRemoving:Connect(function(plr)
		rebuild()
		if plr == spectatedPlayer then
			spectatedPlayer = nil
			if #playerList > 0 then
				currentIndex = 1
			else
				currentIndex = 0
			end
		end
		refresh()
		updateDropdown()
	end)

	refresh()
end, true)

cmd.add({"unwatch2","unview2"},{"unwatch2",""},function()
	cleanup()
	DebugNotif("Spectate stopped", 1.2)
end, true)

cmd.add({"stealaudio","getaudio","steal","logaudio"},{"stealaudio <player>","Save all sounds a player is playing to a file -Cyrus"},function(p)
	Wait(.1)
	local players=getPlr(p)
	if not next(players) then DoNotif("Player not found") return end
	local ids={}
	for _,plr in pairs(players)do
		local char=plr and plr.Character
		if char then
			for _,snd in pairs(char:GetDescendants())do
				if snd:IsA("Sound") and snd.Playing then
					ids[#ids+1]=snd.SoundId
				end
			end
		end
	end
	if #ids>0 then
		setclipboard(Concat(ids,"\n"))
		DebugNotif("Audio links copied.")
	else
		DebugNotif("No audio found.")
	end
end,true)

cmd.add({"follow", "stalk", "walk"}, {"follow <player>", "Follow a player wherever they go"}, function(p)
	NAlib.disconnect("follow")
	local targetPlayers = getPlr(p)
	for _, plr in next, targetPlayers do
		if not plr then
			DoNotif("Player not found or invalid.")
			return
		end
		NAlib.connect("follow", RunService.RenderStepped:Connect(function()
			local target = plr.Character
			if target then
				local hum = getHum()
				local targetPart = getHead(target)
				if hum and targetPart then
					local targetPos = targetPart.Position
					hum:MoveTo(targetPos)
				else
					NAlib.disconnect("follow")
				end
			else
				NAlib.disconnect("follow")
			end
		end))
	end
end, true)

cmd.add({"unfollow", "unstalk", "unwalk", "unpathfind"}, {"unfollow", "Stop all attempts to follow a player"}, function()
	NAlib.disconnect("follow")
end)

PROXIMITY_RADIUS = 15
lastDistances = {}
ISfollowing = false
followTarget = nil
followConnection = nil
flwCharAdd = nil

cmd.add({"autofollow", "autostalk", "proxfollow"}, {"autofollow (autostalk,proxfollow)", "Automatically follow any player who comes close"}, function()
	NAlib.disconnect("autofollow")
	if followConnection then followConnection:Disconnect() followConnection = nil end
	if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
	lastDistances = {}
	ISfollowing = false
	followTarget = nil

	NAlib.connect("autofollow", RunService.Stepped:Connect(function()
		if ISfollowing then return end

		local myChar = getChar()
		local myRoot = getRoot(myChar)
		local myHum = getHum()
		if not (myChar and myRoot and myHum) then return end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local char = plr.Character
				local root = getRoot(char)
				if char and root then
					local currentDist = (myRoot.Position - root.Position).Magnitude
					local lastDist = lastDistances[plr]

					if lastDist and lastDist > PROXIMITY_RADIUS and currentDist < PROXIMITY_RADIUS and currentDist < lastDist then
						ISfollowing = true
						followTarget = plr

						local function setupFollow(char)
							local targetRoot = getRoot(char)
							while not targetRoot do Wait(.1) targetRoot=getRoot(char) end

							if followConnection then followConnection:Disconnect() end
							followConnection = RunService.Stepped:Connect(function()
								if myChar and myHum and targetRoot and char and char.Parent then
									myHum:MoveTo(targetRoot.Position)
								else
									if followConnection then followConnection:Disconnect() followConnection = nil end
									if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
									ISfollowing = false
									followTarget = nil
								end
							end)

							local hum = getPlrHum(plr)
							if hum then
								hum.Died:Connect(function()
									if followConnection then followConnection:Disconnect() followConnection = nil end
									ISfollowing = false
									followTarget = nil
								end)
							end
						end

						if plr.Character then
							setupFollow(plr.Character)
						end

						if flwCharAdd then flwCharAdd:Disconnect() end
						flwCharAdd = plr.CharacterAdded:Connect(function(newChar)
							Wait(0.1)
							setupFollow(newChar)
						end)

						break
					end

					lastDistances[plr] = currentDist
				end
			end
		end
	end))
end)

cmd.add({"unautofollow", "stopautofollow", "unproxfollow"}, {"unautofollow (stopautofollow,unproxfollow)", "Stop automatically following nearby players"}, function()
	NAlib.disconnect("autofollow")
	if followConnection then followConnection:Disconnect() followConnection = nil end
	if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
	lastDistances = {}
	ISfollowing = false
	followTarget = nil
end)

cmd.add({"pathfind"},{"pathfind <player>","Follow a player using the pathfinder API wherever they go"},function(p)
	Wait(.1)
	local players=getPlr(p)
	for _,plr in ipairs(players)do
		if plr then
			NAlib.disconnect("follow")
			local ps=SafeGetService("PathfindingService")
			local lastSrc, lastDst = Vector3.new(), Vector3.new()
			NAlib.connect("follow",RunService.Heartbeat:Connect(function()
				local hum=getHum() local char=getChar() local tgt=plr.Character
				if not(hum and char and tgt and hum.RootPart) then return end
				local src=hum.RootPart.Position
				local dst=(getRoot(tgt) or getHead(tgt)).Position+Vector3.new(0,0,-2)
				if (src-lastSrc).Magnitude>1 or (dst-lastDst).Magnitude>1 then
					lastSrc, lastDst = src, dst
					local path=ps:CreatePath{AgentRadius=2,AgentHeight=5,AgentCanJump=true}
					path:ComputeAsync(src,dst)
					if path.Status~=Enum.PathStatus.NoPath then
						for _,wp in ipairs(path:GetWaypoints())do
							if wp.Action==Enum.PathWaypointAction.Jump then
								if hum:GetState()~=Enum.HumanoidStateType.Freefall and hum.FloorMaterial~=Enum.Material.Air then
									hum:ChangeState(Enum.HumanoidStateType.Jumping)
								end
							end
							hum:MoveTo(wp.Position)
							hum.MoveToFinished:Wait(1)
						end
					end
				end
			end))
		end
	end
end,true)

freezeBTNTOGGLE = nil
isFrozennn = false

cmd.add({"freeze","thaw","anchor","fr"},{"freeze (thaw,anchor,fr)","Freezes your character"}, function(bool)
	local char = getChar()
	if not char then return end

	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	isFrozennn = true

	if IsOnMobile and not bool then
		if freezeBTNTOGGLE then freezeBTNTOGGLE:Destroy() freezeBTNTOGGLE = nil end

		freezeBTNTOGGLE = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(freezeBTNTOGGLE)
		freezeBTNTOGGLE.ResetOnSpawn = false

		btn.Parent = freezeBTNTOGGLE
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.9, 0, 0.6, 0)
		btn.Size = UDim2.new(0.08, 0, 0.1, 0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "UNFRZ"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		NAgui.draggerV2(btn)

		MouseButtonFix(btn, function()
			local char = getChar()
			if not char then return end

			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					part.Anchored = not isFrozennn
				end
			end

			isFrozennn = not isFrozennn
			btn.Text = isFrozennn and "UNFRZ" or "FRZ"
			btn.BackgroundColor3 = isFrozennn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
		end)
	end
end)

cmd.add({"unfreeze","unthaw","unanchor","unfr"},{"unfreeze (unthaw,unanchor,unfr)","Unfreezes your character"}, function()
	local char = getChar()
	if not char then return end

	for _, part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	isFrozennn = false

	if freezeBTNTOGGLE then
		freezeBTNTOGGLE:Destroy()
		freezeBTNTOGGLE = nil
	end
end)

cmd.add({"blackhole","bhole","bholepull"},{"blackhole","Makes unanchored parts teleport to the black hole"},function()
	if NAlib.isConnected("blackhole_force") then return DebugNotif("Blackhole already exists.") end

	local UIS=SafeGetService("UserInputService")
	local Mouse=LocalPlayer:GetMouse()
	local Folder=InstanceNew("Folder",workspace)
	local Part=InstanceNew("Part",Folder)
	local Attachment1=InstanceNew("Attachment",Part)
	Part.Anchored=true Part.CanCollide=false Part.Transparency=1

	local Updated=Mouse.Hit+Vector3.new(0,5,0)
	_G.BlackholeAttachment=Attachment1
	_G.BlackholeTarget=Updated
	_G.BlackholeActive=false

	NAlib.connect("blackhole_sim",RunService.RenderStepped:Connect(function()
		settings().Physics.AllowSleep=false
		for _,plr in next,Players:GetPlayers() do
			if plr~=LocalPlayer then NACaller(function()
					plr.MaximumSimulationRadius=0
					opt.hiddenprop(plr,"SimulationRadius",0)
				end) end
		end
		NACaller(function()
			LocalPlayer.MaximumSimulationRadius=1e9
			opt.hiddenprop(LocalPlayer,"SimulationRadius",1e9)
		end)
	end))

	NAlib.connect("blackhole_pos",RunService.RenderStepped:Connect(function()
		if _G.BlackholeAttachment then
			_G.BlackholeAttachment.WorldCFrame=_G.BlackholeTarget
		end
	end))

	local function ForcePart(v)
		if not _G.BlackholeActive then return end
		if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name~="Handle" then
			for _,x in next,v:GetChildren() do
				if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
			end
			for _,n in next,{"Attachment","AlignPosition","Torque"} do local i=v:FindFirstChild(n) if i then i:Destroy() end end
			v.CanCollide=false
			local a2=InstanceNew("Attachment",v)
			local align=InstanceNew("AlignPosition",v)
			local torque=InstanceNew("Torque",v)
			align.Attachment0=a2 align.Attachment1=_G.BlackholeAttachment
			align.MaxForce=1e9 align.MaxVelocity=math.huge align.Responsiveness=200
			torque.Attachment0=a2 torque.Torque=Vector3.new(100000,100000,100000)
		end
	end

	for _,v in next,workspace:GetDescendants() do ForcePart(v) end
	NAlib.connect("blackhole_force",workspace.DescendantAdded:Connect(ForcePart))

	UIS.InputBegan:Connect(function(k,chat)
		if k.KeyCode==Enum.KeyCode.E and not chat then
			_G.BlackholeTarget=Mouse.Hit+Vector3.new(0,5,0)
		end
	end)

	local sGUI=InstanceNew("ScreenGui")
	NaProtectUI(sGUI)

	local toggleBtn=InstanceNew("TextButton",sGUI)
	local toggleCorner=InstanceNew("UICorner",toggleBtn)
	toggleBtn.Text="Enable Blackhole"
	toggleBtn.AnchorPoint=Vector2.new(0.5,0)
	toggleBtn.Size=UDim2.new(0,160,0,40)
	toggleBtn.Position=UDim2.new(0.5,0,0.88,0)
	toggleBtn.BackgroundColor3=Color3.new(0.15,0.15,0.15)
	toggleBtn.TextColor3=Color3.new(1,1,1)
	toggleBtn.Font=Enum.Font.SourceSansBold
	toggleBtn.TextSize=18
	toggleCorner.CornerRadius=UDim.new(0.25,0)

	MouseButtonFix(toggleBtn,function()
		_G.BlackholeActive=not _G.BlackholeActive
		toggleBtn.Text=_G.BlackholeActive and "Disable Blackhole" or "Enable Blackhole"
		if not _G.BlackholeActive then
			for _,p in ipairs(workspace:GetDescendants()) do
				if p:IsA("BasePart") and not p.Anchored then
					for _,o in ipairs(p:GetChildren()) do
						if o:IsA("AlignPosition") or o:IsA("Torque") or o:IsA("Attachment") then o:Destroy() end
					end
				end
			end
			DebugNotif("Blackhole force disabled",2)
		else
			for _,v in next,workspace:GetDescendants() do ForcePart(v) end
			DebugNotif("Blackhole force enabled",2)
		end
	end)

	local moveBtn=InstanceNew("TextButton",sGUI)
	local moveCorner=InstanceNew("UICorner",moveBtn)
	moveBtn.Text="Move Blackhole"
	moveBtn.AnchorPoint=Vector2.new(0.5,0)
	moveBtn.Size=UDim2.new(0,160,0,40)
	moveBtn.Position=UDim2.new(0.5,0,0.94,0)
	moveBtn.BackgroundColor3=Color3.new(0.2,0.2,0.2)
	moveBtn.TextColor3=Color3.new(1,1,1)
	moveBtn.Font=Enum.Font.SourceSansBold
	moveBtn.TextSize=18
	moveCorner.CornerRadius=UDim.new(0.25,0)

	MouseButtonFix(moveBtn,function()
		_G.BlackholeTarget=Mouse.Hit+Vector3.new(0,5,0)
	end)

	NAgui.draggerV2(toggleBtn)
	NAgui.draggerV2(moveBtn)

	DebugNotif("Blackhole created. Tap button or press E to move",3)
end,true)

cmd.add({"disableanimations","disableanims"},{"disableanimations (disableanims)","Freezes your animations"},function()
	getChar().Animate.Disabled=true
end)

cmd.add({"undisableanimations","undisableanims"},{"undisableanimations (undisableanims)","Unfreezes your animations"},function()
	getChar().Animate.Disabled=false
end)

cmd.add({"hatresize"},{"hatresize","Makes your hats very big r15 only"},function()
	Wait();

	DebugNotif("Hat resize loaded, rthro needed")

	loadstring(game:HttpGet('https://raw.githubusercontent.com/DigitalityScripts/roblox-scripts/refs/heads/main/Patched/hat%20resize'))()
end)

cmd.add({"exit"},{"exit","Close down roblox"},function()
	game:Shutdown()
end)

cmd.add({"firekey","fkey"},{"firekey <key> (fkey)","makes you fire a keybind using VirtualInputManager"},function(...)
	local vim=SafeGetService("VirtualInputManager");
	local input = (...)
	local keyMap = {
		["leftcontrol"] = Enum.KeyCode.LeftControl,
		["rightcontrol"] = Enum.KeyCode.RightControl,
		["leftshift"] = Enum.KeyCode.LeftShift,
		["rightshift"] = Enum.KeyCode.RightShift,
		["leftalt"] = Enum.KeyCode.LeftAlt,
		["rightalt"] = Enum.KeyCode.RightAlt,
		["space"] = Enum.KeyCode.Space,
		["tab"] = Enum.KeyCode.Tab,
		["escape"] = Enum.KeyCode.Escape,
		["enter"] = Enum.KeyCode.Return,
		["backspace"] = Enum.KeyCode.Backspace
	}

	local keyCode

	if keyMap[input:lower()] then
		keyCode = keyMap[input:lower()]
	else
		keyCode = Enum.KeyCode[input:upper()]
	end

	if keyCode then
		vim:SendKeyEvent(true, keyCode, 0, game)
		vim:SendKeyEvent(false, keyCode, 0, game)
	end
end,true)

LOOPPROTECT = nil

cmd.add({"loopfling"}, {"loopfling <player>", "Loop voids a player"}, function(plr)
	local Targets = {plr}
	Loopvoid = false
	Loopvoid = true
	repeat Wait()
		local mouse = LocalPlayer:GetMouse()
		local Players = game.GetService(game,"Players")
		local Player = Players.LocalPlayer
		local AllBool = false
		local GetPlayer = function(Name)
			Name = Name:lower()
			if Name == "all" or Name == "others" then
				AllBool = true
				return
			elseif Name == "random" then
				local GetPlayers = Players:GetPlayers()
				if Discover(GetPlayers, Player) then table.remove(GetPlayers, Discover(GetPlayers, Player)) end
				return GetPlayers[math.random(#GetPlayers)]
			elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
				for _, x in next, Players:GetPlayers() do
					if x ~= Player then
						if x.Name:lower():match("^"..Name) then
							return x
						elseif x.DisplayName:lower():match("^"..Name) then
							return x
						end
					end
				end
			else
				return
			end
		end
		local SkidFling = function(TargetPlayer)
			if LOOPPROTECT then LOOPPROTECT:Destroy() LOOPPROTECT = nil end
			local Character = Player.Character
			local Humanoid = getPlrHum(Character)
			local HRP = Humanoid and Humanoid.RootPart
			local camera = workspace.CurrentCamera
			LOOPPROTECT = InstanceNew("Part")
			LOOPPROTECT.Size = Vector3.new(1, 1, 1)
			LOOPPROTECT.Transparency = 1
			LOOPPROTECT.CanCollide = false
			LOOPPROTECT.Anchored = false
			LOOPPROTECT.Parent = camera
			local weld = InstanceNew("WeldConstraint")
			weld.Part0 = HRP
			weld.Part1 = LOOPPROTECT
			weld.Parent = LOOPPROTECT
			local bodyGyro = InstanceNew("BodyGyro")
			bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
			bodyGyro.D = 1000
			bodyGyro.P = 2000
			bodyGyro.Parent = LOOPPROTECT
			local RootPart = HRP
			local TCharacter = TargetPlayer.Character
			local THumanoid, TRootPart, THead, Accessory, Handle
			if not TCharacter then if LOOPPROTECT then LOOPPROTECT:Destroy() LOOPPROTECT = nil end return end
			if getPlrHum(TCharacter) then
				THumanoid = getPlrHum(TCharacter)
			end
			if THumanoid and THumanoid.RootPart then
				TRootPart = THumanoid.RootPart
			end
			if getHead(TCharacter) then
				THead = getHead(TCharacter)
			end
			if TCharacter:FindFirstChildOfClass("Accessory") then
				Accessory = TCharacter:FindFirstChildOfClass("Accessory")
			end
			if Accessory and Accessory:FindFirstChild("Handle") then
				Handle = Accessory.Handle
			end
			if Character and Humanoid and HRP then
				if not flingManager.lFlingOldPos or RootPart.Velocity.Magnitude < 50 then
					flingManager.lFlingOldPos = RootPart.CFrame
				end
				if THumanoid and THumanoid.Sit and not AllBool then
					return
				end
				if THead then
					workspace.CurrentCamera.CameraSubject = THead
				elseif not THead and Handle then
					workspace.CurrentCamera.CameraSubject = Handle
				elseif THumanoid and TRootPart then
					workspace.CurrentCamera.CameraSubject = THumanoid
				end
				if not TCharacter:FindFirstChildWhichIsA("BasePart") then
					return
				end
				local FPos = function(BasePart, Pos, Ang)
					RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
					Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
					RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
					RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
				end
				local SFBasePart = function(BasePart)
					local TimeToWait = 2
					local Time = tick()
					local Angle = 0
					repeat
						if RootPart and THumanoid then
							if BasePart.Velocity.Magnitude < 50 then
								Angle = Angle + 100
								FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
								Wait()
							else
								FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
								Wait()
								FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
								Wait()
							end
						else
							break
						end
					until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
					if LOOPPROTECT then LOOPPROTECT:Destroy() LOOPPROTECT = nil end
				end
				workspace.FallenPartsDestroyHeight = 0/0
				local BV = InstanceNew("BodyVelocity")
				BV.Parent = RootPart
				BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
				BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
				if TRootPart and THead then
					if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
						SFBasePart(THead)
					else
						SFBasePart(TRootPart)
					end
				elseif TRootPart and not THead then
					SFBasePart(TRootPart)
				elseif not TRootPart and THead then
					SFBasePart(THead)
				elseif not TRootPart and not THead and Accessory and Handle then
					SFBasePart(Handle)
				else
					return
				end
				BV:Destroy()
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
				workspace.CurrentCamera.CameraSubject = Humanoid
				repeat
					RootPart.CFrame = flingManager.lFlingOldPos * CFrame.new(0, 0.5, 0)
					Character:SetPrimaryPartCFrame(flingManager.lFlingOldPos * CFrame.new(0, 0.5, 0))
					Humanoid:ChangeState("GettingUp")
					Foreach(Character:GetChildren(), function(_, x)
						if x:IsA("BasePart") then
							x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
						end
					end)
					Wait()
				until (RootPart.Position - flingManager.lFlingOldPos.p).Magnitude < 25
				workspace.FallenPartsDestroyHeight = OrgDestroyHeight
				if LOOPPROTECT then LOOPPROTECT:Destroy() LOOPPROTECT = nil end
			else
				return
			end
		end
		if not getgenv().Welcome then DebugNotif("Enjoy!", 5, "Script by AnthonyIsntHere") end
		getgenv().Welcome = true
		if Targets[1] then for _, x in next, Targets do GetPlayer(x) end else return end
		if AllBool then
			for _, x in next, Players:GetPlayers() do
				SkidFling(x)
			end
		end
		for _, x in next, Targets do
			if GetPlayer(x) and GetPlayer(x) ~= Player then
				if GetPlayer(x).UserId ~= 1414978355 then
					local TPlayer = GetPlayer(x)
					if TPlayer then
						SkidFling(TPlayer)
					end
				end
			elseif not GetPlayer(x) and not AllBool then
			end
		end
	until Loopvoid == false
end, true)

cmd.add({"unloopfling"}, {"unloopfling", "Stops loop flinging a player"}, function()
	Loopvoid = false
	repeat Wait() if LOOPPROTECT then LOOPPROTECT:Destroy() LOOPPROTECT = nil end until LOOPPROTECT == nil
end)

cmd.add({"freegamepass", "freegp"},{"freegamepass (freegp)", "Returns true if the UserOwnsGamePassAsync function gets used"},function()
	local Hook
	Hook = hookfunction(SafeGetService("MarketplaceService").UserOwnsGamePassAsync, newcclosure(function(self, ...)
		return true
	end))

	DebugNotif("✅ Free gamepasses enabled! Rejoin to disable. Note: This only works in some games.")
end)

cmd.add({"listen"}, {"listen <player>", "Listen to your target's voice chat"}, function(plr)
	local trg = getPlr(plr)

	for _, plr in next, trg do
		local Root = getRoot(plr.Character)
		if Root then
			SafeGetService("SoundService"):SetListener(Enum.ListenerType.ObjectPosition, Root)
		end
	end
end,true)

cmd.add({"unlisten"}, {"unlisten", "Stops listening"}, function()
	SafeGetService("SoundService"):SetListener(Enum.ListenerType.Camera)
end)

if IsOnPC then
	cmd.add({"lockmouse", "lockm"}, {"lockmouse2 (lockm2)", "Default Mouse Behaviour (idk any description)"}, function()
		NAgui.doModal(false)
	end)
	cmd.add({"unlockmouse", "unlockm"}, {"unlockmouse2 (unlockm2)", "Unlocks your mouse (fr this time)"}, function()
		NAgui.doModal(true)
	end)
	cmd.add({"lockmouse2", "lockm2"}, {"lockmouse2 (lockm2)", "Locks your mouse in the center"}, function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	end)

	cmd.add({"unlockmouse2", "unlockm2"}, {"unlockmouse2 (unlockm2)", "Unlocks your mouse"}, function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)
end

platformParts = {}

cmd.add({"headsit"}, {"headsit <player>", "sit on someone's head"}, function(p)
	local ppp = getPlr(p)

	for _, plr in next, ppp do
		if not plr then return end

		local char = getChar()
		local hum = getHum()
		if not hum then return end

		NAlib.disconnect("headsit_follow")
		NAlib.disconnect("headsit_died")

		local charRoot = getRoot(char)
		local target = plr.Character
		if not charRoot or not target then return end

		hum.Sit = true

		NAlib.connect("headsit_died", hum.Died:Connect(function()
			NAlib.disconnect("headsit_follow")
			NAlib.disconnect("headsit_died")
			for _, part in pairs(platformParts) do
				part:Destroy()
			end
			platformParts = {}
		end))

		for _, part in pairs(platformParts) do
			part:Destroy()
		end
		platformParts = {}

		local thick = 1
		local halfWidth = 2
		local halfDepth = 2
		local halfHeight = 3

		local walls = {
			{offset = CFrame.new(0, 0, halfDepth + thick / 500), size = Vector3.new(4, 6, thick)},
			{offset = CFrame.new(0, 0, -(halfDepth + thick / 500)), size = Vector3.new(4, 6, thick)},
			{offset = CFrame.new(halfWidth + thick / 500, 0, 0), size = Vector3.new(thick, 6, 4)},
			{offset = CFrame.new(-(halfWidth + thick / 500), 0, 0), size = Vector3.new(thick, 6, 4)},
			{offset = CFrame.new(0, halfHeight + thick / 500, 0), size = Vector3.new(4, thick, 4)},
			{offset = CFrame.new(0, -(halfHeight + thick / 500), 0), size = Vector3.new(4, thick, 4)}
		}

		for _, wall in ipairs(walls) do
			local part = InstanceNew("Part")
			part.Size = wall.size
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 1
			part.Parent = workspace
			Insert(platformParts, part)
		end

		NAlib.connect("headsit_follow", RunService.Stepped:Connect(function()
			if not SafeGetService("Players"):FindFirstChild(plr.Name)
				or not plr.Character
				or not getHead(plr.Character)
				or hum.Sit == false then

				NAlib.disconnect("headsit_follow")
				NAlib.disconnect("headsit_died")

				for _, part in pairs(platformParts) do
					part:Destroy()
				end
				platformParts = {}
			else
				local targetHead = getHead(plr.Character)
				charRoot.CFrame = targetHead.CFrame * CFrame.new(0, 1.6, 0.4)

				for i, wall in ipairs(walls) do
					platformParts[i].CFrame = charRoot.CFrame * wall.offset
				end
			end
		end))
	end
end, true)

cmd.add({"unheadsit"}, {"unheadsit", "Stop the headsit command."}, function()
	NAlib.disconnect("headsit_follow")
	NAlib.disconnect("headsit_died")

	for _, part in pairs(platformParts) do
		part:Destroy()
	end
	platformParts = {}

	local char = getChar()
	local hum = getHum()
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

cmd.add({"wallhop"},{"wallhop","wallhop helper"},function()
	local char = getChar()
	local root = getRoot(char)
	local hum = getHum()

	NAlib.disconnect("wallhop_loop")

	local canHop = true

	NAlib.connect("wallhop_loop", RunService.Stepped:Connect(function()
		if not char or not root or not hum or hum.Health <= 0 then
			NAlib.disconnect("wallhop_loop")
			return
		end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = {char}

		local origin = root.Position + Vector3.new(0, -1, 0)
		local direction = root.CFrame.LookVector * 1.5
		local wallResult = workspace:Raycast(origin, direction, params)

		if wallResult and hum.FloorMaterial == Enum.Material.Air then
			local hitPart = wallResult.Instance
			local topPoint = wallResult.Position + Vector3.new(0, 0.1, 0)
			local upperCheck = workspace:Raycast(topPoint, Vector3.new(0, 2, 0), params)

			if upperCheck and upperCheck.Instance ~= hitPart then
				if root.Velocity.Y < -1 and canHop then
					canHop = false

					local originalYaw = root.Orientation.Y
					local flickAngle = 35 * (math.random(0,1) == 0 and -1 or 1)
					local newYaw = originalYaw + flickAngle

					root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(newYaw), 0)
					hum:ChangeState(Enum.HumanoidStateType.Jumping)

					Delay(0.1, function()
						if root and root.Parent then
							root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(originalYaw), 0)
						end
					end)
				end
			end
		end

		if root.Velocity.Y > 0 then
			canHop = true
		end
	end))
end)

cmd.add({"unwallhop"},{"unwallhop","disable wallhop helper"},function()
	NAlib.disconnect("wallhop_loop")
end)

cmd.add({"jump"},{"jump","jump."},function()
	getHum():ChangeState(Enum.HumanoidStateType.Jumping)
end)

cmd.add({"loopjump","bhop"},{"loopjump (bhop)","Continuously jump."},function()
	NAlib.disconnect("loopjump")
	NAlib.connect("loopjump",RunService.RenderStepped:Connect(function()
		local h=getHum()
		if h and h:GetState()~=Enum.HumanoidStateType.Freefall and h.FloorMaterial~=Enum.Material.Air then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end))
end)

cmd.add({"unloopjump","unbhop"},{"unloopjump (unbhop)","Stop continuous jumping."},function()
	NAlib.disconnect("loopjump")
end)

cmd.add({"trussjump","tj","tjump","trussj"},{"trussjump","Boost off trusses when you jump"},function() -- totally didn't stole this idea from FE2 lmao
	NAlib.disconnect("trussjump_spawn") NAlib.disconnect("trussjump_jump")
	local function hook()
		local hm=getHum()
		if not hm then return false end
		NAlib.disconnect("trussjump_jump")
		NAlib.connect("trussjump_jump",hm.Jumping:Connect(function(isJump)
			NACaller(function()
				local char=getChar()
				local rt=char and getRoot(char)
				local h=getHum()
				if isJump and h and rt and h:GetState()==Enum.HumanoidStateType.Jumping then
					h:SetStateEnabled(Enum.HumanoidStateType.Climbing,false)
					local hor=Vector3.new(rt.Velocity.X,0,rt.Velocity.Z)
					rt.Velocity=hor+Vector3.new(0,h.JumpPower*1.1,0)
					Delay(0.2,function() h:SetStateEnabled(Enum.HumanoidStateType.Climbing,true) end)
				end
			end)
		end))
		return true
	end
	local attempts=5
	while attempts>0 and not hook() do
		attempts-=1
		Wait(1)
	end
	if not getHum() then DoNotif("failed to hook to Humanoid",2) end
	NAlib.connect("trussjump_spawn",LocalPlayer.CharacterAdded:Connect(function()
		local attempts2=5
		while attempts2>0 and not hook() do
			attempts2-=1
			Wait(1)
		end
		if not getHum() then DoNotif("failed to hook to Humanoid",2) end
	end))
	DebugNotif("Trussjump enabled",2)
end,true)

cmd.add({"untrussjump","untj","untjump","untrussj"},{"untrussjump","Disable trussjump"},function()
	NAlib.disconnect("trussjump_spawn") NAlib.disconnect("trussjump_jump")
end)

standParts = {}

cmd.add({"headstand"}, {"headstand <player>", "Stand on someone's head."}, function(p)
	NAlib.disconnect("headstand_follow")
	NAlib.disconnect("headstand_died")

	local targets = getPlr(p)
	if #targets == 0 then return end

	local plr = targets[1]
	local char = getChar()
	if not char then return end
	local hum = getHum()
	if not hum then return end

	NAlib.connect("headstand_died", hum.Died:Connect(function()
		NAlib.disconnect("headstand_follow")
		NAlib.disconnect("headstand_died")
		for _, part in pairs(standParts) do
			part:Destroy()
		end
		standParts = {}
	end))

	for _, part in pairs(standParts) do
		part:Destroy()
	end
	standParts = {}

	local thick = 1
	local halfWidth = 2
	local halfDepth = 2
	local halfHeight = 3

	local walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick/500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick/500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick/500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick/500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick/500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick/500), 0), size = Vector3.new(4, thick, 4)}
	}

	for _, wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(standParts, part)
	end

	NAlib.connect("headstand_follow", RunService.Stepped:Connect(function()
		local plrCharacter = plr.Character
		if Players:FindFirstChild(plr.Name) and plrCharacter and getRoot(plrCharacter) and getRoot(char) then
			local charRoot = getRoot(char)
			charRoot.CFrame = getRoot(plrCharacter).CFrame * CFrame.new(0, 4.6, 0.4)
			for i, wall in ipairs(walls) do
				standParts[i].CFrame = charRoot.CFrame * wall.offset
			end
		else
			NAlib.disconnect("headstand_follow")
			NAlib.disconnect("headstand_died")
			for _, part in pairs(standParts) do
				part:Destroy()
			end
			standParts = {}
		end
	end))
end, true)

cmd.add({"unheadstand"}, {"unheadstand", "Stop the headstand command."}, function()
	NAlib.disconnect("headstand_follow")
	NAlib.disconnect("headstand_died")

	for _, part in pairs(standParts) do
		part:Destroy()
	end
	standParts = {}
end)

getgenv().NamelessWs = nil
local loopws = false

cmd.add({"loopwalkspeed", "loopws", "lws"}, {"loopwalkspeed <number> (loopws,lws)", "Loop walkspeed"}, function(...)
	local val = tonumber(...) or 16
	getgenv().NamelessWs = val
	loopws = true

	NAlib.disconnect("loopws_apply")
	NAlib.disconnect("loopws_char")

	local function applyWS()
		local hum = getHum()
		if hum then
			hum.WalkSpeed = val
			NAlib.connect("loopws_apply", hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if loopws and hum.WalkSpeed ~= val then
					hum.WalkSpeed = val
				end
			end))
		end
	end

	applyWS()

	NAlib.connect("loopws_char", LocalPlayer.CharacterAdded:Connect(function()
		while not getHum() do Wait(.1) end
		if loopws then applyWS() end
	end))
end, true)

cmd.add({"unloopwalkspeed", "unloopws", "unlws"}, {"unloopwalkspeed (unloopws,unlws)", "Disable loop walkspeed"}, function()
	loopws = false
	NAlib.disconnect("loopws_apply")
	NAlib.disconnect("loopws_char")
end)

getgenv().NamelessJP = nil
local loopjp = false

cmd.add({"loopjumppower", "loopjp", "ljp"}, {"loopjumppower <number> (loopjp,ljp)", "Loop JumpPower"}, function(...)
	local val = tonumber(...) or 50
	getgenv().NamelessJP = val
	loopjp = true

	NAlib.disconnect("loopjp_apply")
	NAlib.disconnect("loopjp_char")

	local function applyJP()
		local hum = getHum()
		if not hum then return end

		if hum.UseJumpPower then
			hum.JumpPower = val
			NAlib.connect("loopjp_apply", hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
				if loopjp and hum.JumpPower ~= val then
					hum.JumpPower = val
				end
			end))
		else
			hum.JumpHeight = val
			NAlib.connect("loopjp_apply", hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
				if loopjp and hum.JumpHeight ~= val then
					hum.JumpHeight = val
				end
			end))
		end
	end

	applyJP()

	NAlib.connect("loopjp_char", LocalPlayer.CharacterAdded:Connect(function()
		while not getHum() do Wait(.1) end
		if loopjp then applyJP() end
	end))
end, true)

cmd.add({"unloopjumppower", "unloopjp", "unljp"}, {"unloopjumppower (unloopjp,unljp)", "Disable loop jump power"}, function()
	loopjp = false
	NAlib.disconnect("loopjp_apply")
	NAlib.disconnect("loopjp_char")
end)

cmd.add({"stopanimations", "stopanims", "stopanim", "noanim"}, {"stopanimations (stopanims,stopanim,noanim)", "Stops running animations"}, function()
	local char = Players.LocalPlayer and Players.LocalPlayer.Character
	local hum = getHum() or (char and char:FindFirstChildOfClass("AnimationController"))
	if not hum then return end

	for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
		track:Stop()
	end
end)

loopwave = false

cmd.add({"loopwaveat", "loopwat"}, {"loopwaveat <player> (loopwat)", "Wave to a player in a loop"}, function(...)
	loopwave = true
	local playerName = (...)
	local targets = getPlr(playerName)
	for _, plr in next, targets do
		local char = getChar()
		local oldCFrame = getRoot(char).CFrame
		repeat
			Wait(0.2)
			local targetCFrame = getRoot(plr.Character).CFrame
			local waveAnim = InstanceNew("Animation")
			if getHum().RigType == Enum.HumanoidRigType.R15 then
				waveAnim.AnimationId = "rbxassetid://507770239"
			else
				waveAnim.AnimationId = "rbxassetid://128777973"
			end
			getRoot(char).CFrame = targetCFrame * CFrame.new(0, 0, -3)
			local charPos = char.PrimaryPart.Position
			local tpos = getRoot(plr.Character).Position
			local newCFrame = CFrame.new(charPos, Vector3.new(tpos.X, charPos.Y, tpos.Z))
			Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCFrame)
			local wave = getHum():LoadAnimation(waveAnim)
			wave:Play(-1, 5, -1)
			Wait(1.6)
			wave:Stop()
		until not loopwave
		getRoot(char).CFrame = oldCFrame
	end
end, true)

cmd.add({"unloopwaveat", "unloopwat"}, {"unloopwaveat <player> (unloopwat)", "Stops the loopwaveat command"}, function()
	loopwave = false
end)

cmd.add({"tools", "gears"}, {"tools <player> (gears)", "Copies tools from ReplicatedStorage and Lighting"}, function()
	function copyTools(source)
		for _, item in pairs(source:GetDescendants()) do
			if item:IsA('Tool') or item:IsA('HopperBin') then
				item:Clone().Parent = getBp()
			end
		end
	end

	copyTools(Lighting)
	copyTools(ReplicatedStorage)

	Wait()
	DebugNotif("Copied tools from ReplicatedStorage and Lighting", 3)
end)

tviewBillboards = {}

cmd.add({"toolview", "tview"}, {"toolview <player> (tview)", "3D tool viewer above a player's head"}, function(...)
	local targets = getPlr(...)
	for _, plr in ipairs(targets) do
		local existing = tviewBillboards[plr]
		if existing then
			existing:Destroy()
			tviewBillboards[plr] = nil
		end

		local char = getPlrChar(plr)
		if not char then continue end

		local head = getHead(char)
		if not head then continue end

		local bb = InstanceNew("BillboardGui")
		bb.Name = "ToolViewDisplay"
		bb.Size = UDim2.new(0, 0, 0, 0)
		bb.StudsOffset = Vector3.new(0, 2.5, 0)
		bb.Adornee = head
		bb.AlwaysOnTop = true
		bb.LightInfluence = 0
		bb.ResetOnSpawn = false
		bb.Parent = head

		local container = InstanceNew("Frame")
		container.BackgroundTransparency = 1
		container.Size = UDim2.new(0, 0, 0, 50)
		container.AutomaticSize = Enum.AutomaticSize.X
		container.ClipsDescendants = false
		container.Parent = bb

		local layout = InstanceNew("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 6)
		layout.Parent = container

		tviewBillboards[plr] = bb

		local function makeToolBtn(tool)
			local hasImg = tool.TextureId and tool.TextureId ~= ""
			local btn = hasImg and InstanceNew("ImageButton") or InstanceNew("TextButton")
			btn.Size = UDim2.new(0, 50, 0, 50)
			btn.Name = tool.Name
			btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			btn.AutoButtonColor = false
			btn.ZIndex = 5
			InstanceNew("UICorner", btn).CornerRadius = UDim.new(0.2, 0)

			if hasImg then
				btn.Image = tool.TextureId
			else
				btn.Text = tool.Name
				btn.TextScaled = true
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.SourceSans
			end

			return btn
		end

		local lastToolNames = {}

		local function getToolNames()
			local names = {}
			local function add(t)
				if t:IsA("Tool") then
					Insert(names, t.Name)
				end
			end

			local bp = plr:FindFirstChildOfClass("Backpack")
			if bp then for _, t in ipairs(bp:GetChildren()) do add(t) end end

			local char = getPlrChar(plr)
			if char then for _, t in ipairs(char:GetChildren()) do add(t) end end

			table.sort(names)
			return names
		end

		local function toolListChanged()
			local current = getToolNames()
			if #current ~= #lastToolNames then
				lastToolNames = current
				return true
			end
			for i = 1, #current do
				if current[i] ~= lastToolNames[i] then
					lastToolNames = current
					return true
				end
			end
			return false
		end

		local function refresh()
			for _, c in ipairs(container:GetChildren()) do
				if c:IsA("GuiButton") then c:Destroy() end
			end

			local bp = plr:FindFirstChildOfClass("Backpack")
			if bp then
				for _, t in ipairs(bp:GetChildren()) do
					if t:IsA("Tool") then makeToolBtn(t).Parent = container end
				end
			end

			local char = getPlrChar(plr)
			if char then
				for _, t in ipairs(char:GetChildren()) do
					if t:IsA("Tool") then makeToolBtn(t).Parent = container end
				end
			end
		end

		refresh()

		local hb
		hb = RunService.RenderStepped:Connect(function()
			if not plr.Parent or not plr.Character or not head:IsDescendantOf(workspace) then
				bb:Destroy()
				tviewBillboards[plr] = nil
				if hb then hb:Disconnect() end
				return
			end

			if toolListChanged() then
				refresh()
			end

			local width = container.AbsoluteSize.X
			local height = container.AbsoluteSize.Y
			bb.Size = UDim2.new(0, width, 0, height)
		end)

		Insert(toolConnections, hb)
	end
end, true)

cmd.add({"untoolview", "untview"}, {"untview <player> (untview)", "Removes the tool viewer above a player’s head"}, function(...)
	local targets = getPlr(...)
	for _, plr in ipairs(targets) do
		local bb = tviewBillboards[plr]
		if bb then
			bb:Destroy()
			tviewBillboards[plr] = nil
		end
	end
end, true)

renderConn = nil
playerAddConn = nil
playerRemoveConn = nil
toolConnections = {}
idkwhyididntmakethisbruh = nil

cmd.add({"toolview2", "tview2"}, {"toolview2 (tview2)", "Live-updating tool viewer"}, function()
	if renderConn then renderConn:Disconnect() end
	if playerAddConn then playerAddConn:Disconnect() end
	if playerRemoveConn then playerRemoveConn:Disconnect() end
	for _, c in pairs(toolConnections) do NACaller(function() c:Disconnect() end) end
	toolConnections = {}

	if idkwhyididntmakethisbruh then idkwhyididntmakethisbruh:Destroy() idkwhyididntmakethisbruh = nil end

	idkwhyididntmakethisbruh = InstanceNew("ScreenGui")
	NaProtectUI(idkwhyididntmakethisbruh)
	idkwhyididntmakethisbruh.Name = "ToolViewGui"
	idkwhyididntmakethisbruh.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local main = InstanceNew("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0.4, 0, 0.5, 0)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	main.BorderSizePixel = 0
	main.ZIndex = 10
	main.Active = true
	main.Selectable = true
	main.Parent = idkwhyididntmakethisbruh
	InstanceNew("UICorner", main).CornerRadius = UDim.new(0, 20)

	local topbar = InstanceNew("Frame")
	topbar.Size = UDim2.new(1, 0, 0, 35)
	topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	topbar.BorderSizePixel = 0
	topbar.ZIndex = 11
	topbar.Active = true
	topbar.Selectable = true
	topbar.Parent = main
	InstanceNew("UICorner", topbar).CornerRadius = UDim.new(0, 8)

	local title = InstanceNew("TextLabel")
	title.Text = "Tool Viewer"
	title.Size = UDim2.new(1, -70, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 11
	title.Parent = topbar

	local closeBtn = InstanceNew("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 1, 0)
	closeBtn.Position = UDim2.new(1, -35, 0, 0)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	closeBtn.ZIndex = 11
	closeBtn.Parent = topbar
	InstanceNew("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

	local minimizeBtn = InstanceNew("TextButton")
	minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
	minimizeBtn.Position = UDim2.new(1, -70, 0, 0)
	minimizeBtn.Text = "-"
	minimizeBtn.Font = Enum.Font.SourceSansBold
	minimizeBtn.TextSize = 16
	minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	minimizeBtn.ZIndex = 11
	minimizeBtn.Parent = topbar
	InstanceNew("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

	local scroll = InstanceNew("ScrollingFrame")
	scroll.Name = "Content"
	scroll.Size = UDim2.new(1, 0, 1, -35)
	scroll.Position = UDim2.new(0, 0, 0, 35)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 6
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ZIndex = 10
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = main

	local list = InstanceNew("UIListLayout")
	list.Padding = UDim.new(0, 12)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll

	local sections = {}

	local function makeToolBtn(tool)
		local hasImg = tool.TextureId and tool.TextureId ~= ""
		local btn = hasImg and InstanceNew("ImageButton") or InstanceNew("TextButton")
		btn.Size = UDim2.new(0, 50, 0, 50)
		btn.Name = tool.Name
		btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		btn.AutoButtonColor = false
		btn.ZIndex = 5
		InstanceNew("UICorner", btn).CornerRadius = UDim.new(0.2, 0)

		if hasImg then
			btn.Image = tool.TextureId
		else
			btn.Text = tool.Name
			btn.TextScaled = true
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.SourceSans
		end

		return btn
	end

	local function createSection(plr)
		local frame = InstanceNew("Frame")
		frame.Size = UDim2.new(1, -10, 0, 100)
		frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		frame.BorderSizePixel = 0
		frame.ZIndex = 10
		frame.Parent = scroll
		InstanceNew("UICorner", frame).CornerRadius = UDim.new(0, 12)

		local name = InstanceNew("TextLabel")
		name.Size = UDim2.new(1, -10, 0, 30)
		name.Position = UDim2.new(0, 5, 0, 5)
		name.BackgroundTransparency = 1
		name.Text = nameChecker(plr)
		name.Font = Enum.Font.SourceSansSemibold
		name.TextSize = 18
		name.TextColor3 = Color3.new(1, 1, 1)
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.ZIndex = 10
		name.Parent = frame

		local holder = InstanceNew("ScrollingFrame")
		holder.Name = "ToolHolder"
		holder.Position = UDim2.new(0, 5, 0, 35)
		holder.Size = UDim2.new(1, -10, 0, 55)
		holder.CanvasSize = UDim2.new(0, 0, 0, 0)
		holder.ScrollBarThickness = 4
		holder.ScrollingDirection = Enum.ScrollingDirection.X
		holder.AutomaticCanvasSize = Enum.AutomaticSize.X
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.ZIndex = 10
		holder.Parent = frame

		local hList = InstanceNew("UIListLayout")
		hList.Padding = UDim.new(0, 6)
		hList.FillDirection = Enum.FillDirection.Horizontal
		hList.SortOrder = Enum.SortOrder.LayoutOrder
		hList.Parent = holder

		sections[plr] = {
			Frame = frame,
			Holder = holder
		}
	end

	local function updateTools(plr)
		local sec = sections[plr]
		if not sec then return end

		for _, btn in ipairs(sec.Holder:GetChildren()) do
			if btn:IsA("GuiButton") then btn:Destroy() end
		end

		local tools = {}

		local bp = plr:FindFirstChildOfClass("Backpack")
		if bp then
			for _, t in ipairs(bp:GetChildren()) do
				if t:IsA("Tool") then Insert(tools, t) end
			end
		end

		local char = getPlrChar(plr)
		if char then
			for _, t in ipairs(char:GetChildren()) do
				if t:IsA("Tool") then Insert(tools, t) end
			end
		end

		for _, t in ipairs(tools) do
			makeToolBtn(t).Parent = sec.Holder
		end
	end

	local function refreshAll()
		for plr in pairs(sections) do
			updateTools(plr)
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		createSection(plr)
	end

	renderConn = RunService.RenderStepped:Connect(refreshAll)
	playerAddConn = Players.PlayerAdded:Connect(function(plr)
		createSection(plr)
	end)
	playerRemoveConn = Players.PlayerRemoving:Connect(function(plr)
		local sec = sections[plr]
		if sec then sec.Frame:Destroy() end
		sections[plr] = nil
	end)

	local minimized = false
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		scroll.Visible = not minimized
		main.Size = minimized and UDim2.new(0.4, 0, 0.05, 0) or UDim2.new(0.4, 0, 0.5, 0)
	end)

	closeBtn.MouseButton1Click:Connect(function()
		if renderConn then renderConn:Disconnect() end
		if playerAddConn then playerAddConn:Disconnect() end
		if playerRemoveConn then playerRemoveConn:Disconnect() end
		for _, c in pairs(toolConnections) do NACaller(function() c:Disconnect() end) end
		if idkwhyididntmakethisbruh then idkwhyididntmakethisbruh:Destroy() idkwhyididntmakethisbruh = nil end
	end)

	NAgui.dragger(main,topbar)
end)

cmd.add({"waveat", "wat"}, {"waveat <player> (wat)", "Wave to a player"}, function(...)
	local playerName = (...)
	local targets = getPlr(playerName)
	if #targets == 0 then return end
	local plr = targets[1]
	local char = getChar()
	local humanoid = getHum()
	local localRoot = getRoot(char)
	local oldCFrame = localRoot.CFrame
	local targetRoot = getRoot(plr.Character)
	if targetRoot then
		localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
		local charPos = char.PrimaryPart.Position
		local targetHRP = getRoot(plr.Character)
		if targetHRP then
			local newCFrame = CFrame.new(charPos, Vector3.new(targetHRP.Position.X, charPos.Y, targetHRP.Position.Z))
			Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCFrame)
		end
		local waveAnim = InstanceNew("Animation")
		if IsR15() then
			waveAnim.AnimationId = "rbxassetid://507770239"
		else
			waveAnim.AnimationId = "rbxassetid://128777973"
		end
		local wave = humanoid:LoadAnimation(waveAnim)
		wave:Play(-1, 5, -1)
		Wait(1.6)
		wave:Stop()
		localRoot.CFrame = oldCFrame
	end
end, true)

bang, bangAnim, bangLoop, bangDied, bangParts = nil, nil, nil, nil, {}

cmd.add({"headbang", "mouthbang", "headfuck", "mouthfuck", "facebang", "facefuck", "hb", "mb"}, {"headbang <player> (mouthbang,headfuck,mouthfuck,facebang,facefuck,hb,mb)", "Bang them in the mouth because you are gay"}, function(h, d)
	local speed = d or 10
	local username = h
	local players = getPlr(username)
	if #players == 0 then return end
	local plr = players[1]
	bangAnim = InstanceNew("Animation")
	if not IsR15(Players.LocalPlayer) then
		bangAnim.AnimationId = "rbxassetid://148840371"
	else
		bangAnim.AnimationId = "rbxassetid://5918726674"
	end
	local humanoid = getHum()
	if not humanoid then return end
	bang = humanoid:LoadAnimation(bangAnim)
	bang:Play(0.1, 1, 1)
	bang:AdjustSpeed(speed)
	local bangplr = plr.Name
	bangDied = humanoid.Died:Connect(function()
		if bangLoop then
			bangLoop:Disconnect()
		end
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
		for _, part in pairs(bangParts) do
			part:Destroy()
		end
		bangParts = {}
	end)
	for _, part in pairs(bangParts) do
		part:Destroy()
	end
	bangParts = {}
	local thick = 0.2
	local halfWidth = 2
	local halfDepth = 2
	local halfHeight = 3
	local walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick/500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick/500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick/500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick/500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick/500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick/500), 0), size = Vector3.new(4, thick, 4)}
	}
	for i, wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(bangParts, part)
	end
	local bangOffset = CFrame.new(0, 1, -1.1)
	bangLoop = RunService.Stepped:Connect(function()
		NACaller(function()
			local targetPlayer = Players:FindFirstChild(bangplr)
			if not targetPlayer or not targetPlayer.Character then return end
			local targetCharacter = targetPlayer.Character
			local otherHead = getHead(targetCharacter)
			local localRoot = getRoot(getChar())
			if otherHead and localRoot then
				localRoot.CFrame = otherHead.CFrame * bangOffset
			end
			local charPos = getChar().PrimaryPart.Position
			local targetRoot = getRoot(targetCharacter)
			if targetRoot then
				local newCFrame = CFrame.new(charPos, Vector3.new(targetRoot.Position.X, charPos.Y, targetRoot.Position.Z))
				Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCFrame)
			end
			for i, wall in ipairs(walls) do
				bangParts[i].CFrame = localRoot.CFrame * wall.offset
			end
		end)
	end)
end, true)

cmd.add({"unheadbang", "unmouthbang", "unhb", "unmb"}, {"unheadbang (unmouthbang,unhb,unmb)", "Stops headbang"}, function()
	if bangLoop then
		bangLoop:Disconnect()
		bang:Stop()
		bangAnim:Destroy()
		bangDied:Disconnect()
	end
	for _, part in pairs(bangParts) do
		part:Destroy()
	end
	bangParts = {}
end)

jerkAnim, jerkTrack, jerkLoop, jerkDied, jerkParts = nil, nil, nil, nil, {}

cmd.add({"jerkuser", "jorkuser", "handjob", "hjob", "handj"}, {"jerkuser <player> (jorkuser, handjob, hjob, handj)", "Lay under them and vibe"}, function(h, d)
	if not IsR6() then DoNotif("command requires R6",3) return end
	local username = h
	local players = getPlr(username)
	if #players == 0 then return end
	local plr = players[1]

	local char = getChar()
	if not char then return end

	local humanoid = getHum()
	if not humanoid then return end

	jerkAnim = InstanceNew("Animation")
	jerkAnim.AnimationId = "rbxassetid://95383980"
	jerkTrack = humanoid:LoadAnimation(jerkAnim)
	jerkTrack.Looped = true
	jerkTrack:Play()

	humanoid.Sit = true
	Wait(0.1)

	local root = getRoot(char)
	if not root then return end

	root.CFrame = root.CFrame * CFrame.Angles(math.pi * 0.5, math.pi, 0)

	for _, part in pairs(jerkParts) do
		part:Destroy()
	end
	jerkParts = {}

	local thick = 0.2
	local halfWidth = 2
	local halfDepth = 2
	local halfHeight = 3
	local walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick / 500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick / 500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick / 500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick / 500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick / 500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick / 500), 0), size = Vector3.new(4, thick, 4)}
	}

	for i, wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(jerkParts, part)
	end

	local jerkOffset = CFrame.new(0, -2.5, -0.25) * CFrame.Angles(math.pi * 0.5, 0, math.pi)
	jerkLoop = RunService.Stepped:Connect(function()
		NACaller(function()
			for i, wall in ipairs(walls) do
				jerkParts[i].CFrame = root.CFrame * wall.offset
			end
			local targetChar = plr.Character
			local targetRoot = targetChar and getRoot(targetChar)
			if targetRoot then
				root.CFrame = targetRoot.CFrame * jerkOffset
			end
		end)
	end)

	jerkDied = humanoid.Died:Connect(function()
		if jerkLoop then jerkLoop:Disconnect() end
		if jerkTrack then jerkTrack:Stop() end
		if jerkAnim then jerkAnim:Destroy() end
		for _, part in pairs(jerkParts) do
			part:Destroy()
		end
		jerkParts = {}
	end)
end, true)

cmd.add({"unjerkuser", "unjorkuser", "unhandjob", "unhjob", "unhandj"}, {"unjerkuser (unjorkuser, unhandjob, unhjob, unhandj)", "Stop the jerk user action"}, function()
	if jerkLoop then jerkLoop:Disconnect() end
	if jerkTrack then jerkTrack:Stop() end
	if jerkAnim then jerkAnim:Destroy() end
	if jerkDied then jerkDied:Disconnect() end

	local char = getChar()
	local root = getRoot(char)
	if root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
	end

	local humanoid = getHum()
	if humanoid then
		humanoid.Sit = false
	end

	for _, part in pairs(jerkParts) do
		part:Destroy()
	end
	jerkParts = {}
end)

suckLOOP = nil
suckANIM = nil
suckDIED = nil
doSUCKING = nil
SUCKYSUCKY = {}

cmd.add({"suck","dicksuck"},{"suck <player> <number>","suck it"},function(h,d)
	if suckLOOP then suckLOOP = nil end
	if doSUCKING then doSUCKING:Stop() end
	if suckANIM then suckANIM:Destroy() end
	if suckDIED then suckDIED:Disconnect() end
	for _,p in pairs(SUCKYSUCKY) do p:Destroy() end
	SUCKYSUCKY = {}

	local speed = d or 10
	local tweenDuration = 1/speed
	local tweenInfo = TweenInfo.new(tweenDuration,Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
	local targets = getPlr(h)
	if #targets == 0 then return end
	local plr = targets[1]
	local targetName = plr.Name

	suckANIM = InstanceNew("Animation")
	if not IsR15(Players.LocalPlayer) then
		suckANIM.AnimationId = "rbxassetid://189854234"
	else
		suckANIM.AnimationId = "rbxassetid://5918726674"
	end
	local hum = getHum()
	doSUCKING = hum:LoadAnimation(suckANIM)
	doSUCKING:Play(0.1,1,1)
	doSUCKING:AdjustSpeed(speed)

	suckDIED = hum.Died:Connect(function()
		if suckLOOP then suckLOOP = nil end
		doSUCKING:Stop()
		suckANIM:Destroy()
		suckDIED:Disconnect()
		for _,part in pairs(SUCKYSUCKY) do part:Destroy() end
		SUCKYSUCKY = {}
	end)

	local thick,halfWidth,halfDepth,halfHeight = 0.2,2,2,3
	local walls = {
		{offset=CFrame.new(0,0,halfDepth+thick/500), size=Vector3.new(4,6,thick)},
		{offset=CFrame.new(0,0,-(halfDepth+thick/500)), size=Vector3.new(4,6,thick)},
		{offset=CFrame.new(halfWidth+thick/500,0,0), size=Vector3.new(thick,6,4)},
		{offset=CFrame.new(-(halfWidth+thick/500),0,0), size=Vector3.new(thick,6,4)},
		{offset=CFrame.new(0,halfHeight+thick/500,0), size=Vector3.new(4,thick,4)},
		{offset=CFrame.new(0,-(halfHeight+thick/500),0), size=Vector3.new(4,thick,4)},
	}
	for i,wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size=wall.size
		part.Anchored=true
		part.CanCollide=true
		part.Transparency=1
		part.Parent=workspace
		Insert(SUCKYSUCKY,part)
	end

	suckLOOP = coroutine.wrap(function()
		while true do
			local targetPlayer = Players:FindFirstChild(targetName)
			local targetCharacter = targetPlayer and targetPlayer.Character
			local localCharacter = getChar()
			if targetCharacter and getRoot(targetCharacter) and localCharacter and getRoot(localCharacter) then
				local targetHRP = getRoot(targetCharacter)
				local localHRP = getRoot(localCharacter)
				local forwardCFrame = targetHRP.CFrame * CFrame.new(0,-2.3,-2.5) * CFrame.Angles(0,math.pi,0)
				local backwardCFrame = targetHRP.CFrame * CFrame.new(0,-2.3,-1.3) * CFrame.Angles(0,math.pi,0)
				local tweenForward = TweenService:Create(localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=forwardCFrame})
				tweenForward:Play()
				tweenForward.Completed:Wait()
				local tweenBackward = TweenService:Create(localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=backwardCFrame})
				tweenBackward:Play()
				tweenBackward.Completed:Wait()
				for i,wall in ipairs(walls) do
					SUCKYSUCKY[i].CFrame = localHRP.CFrame * wall.offset
				end
			end
			Wait(0.1)
		end
	end)
	suckLOOP()
end,true)

cmd.add({"unsuck","undicksuck"},{"unsuck","no more fun"},function()
	suckLOOP = nil
	if doSUCKING then doSUCKING:Stop() end
	if suckANIM then suckANIM:Destroy() end
	if suckDIED then suckDIED:Disconnect() end
	for _,p in pairs(SUCKYSUCKY) do p:Destroy() end
	SUCKYSUCKY = {}
end)

cmd.add({"improvetextures"},{"improvetextures","Switches Textures"},function()
	opt.hiddenprop(SafeGetService("MaterialService"), "Use2022Materials", true)
end)

cmd.add({"undotextures"},{"undotextures","Switches Textures"},function()
	opt.hiddenprop(SafeGetService("MaterialService"), "Use2022Materials", false)
end)

cmd.add({"serverlist","serverlister","slist"},{"serverlist (serverlister,slist)","list of servers to join in"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/ServerLister.lua"))();
end)

cmd.add({"keyboard"},{"keyboard","provides a keyboard gui for mobile users"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/VirtualKeyboard.lua"))();
end)

cmd.add({"backpack"},{"backpack","provides a custom backpack gui"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/mobileBACKPACK.lua"))();
end)

HumanModCons = {}

cmd.add({"edgejump", "ejump"}, {"edgejump (ejump)", "Automatically jumps when you get to the edge of an object"}, function()
	local Char = speaker.Character
	local Human = getHum()
	local currentState
	local previousState
	local lastCFrame

	local function edgeJump()
		if Char and Human then
			previousState = currentState
			currentState = Human:GetState()
			if previousState ~= currentState and currentState == Enum.HumanoidStateType.Freefall and previousState ~= Enum.HumanoidStateType.Jumping then
				local rootPart = getRoot(Char)
				rootPart.CFrame = lastCFrame
				rootPart.Velocity = Vector3.new(rootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, rootPart.Velocity.Z)
			end
			lastCFrame = getRoot(Char).CFrame
		end
	end

	edgeJump()
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.Stepped:Connect(edgeJump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(newChar)
		Char = newChar
		Human = getPlrHum(newChar)
		edgeJump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.Stepped:Connect(edgeJump)
	end)
end)

cmd.add({"unedgejump", "noedgejump", "noejump", "unejump"}, {"unedgejump (noedgejump, noejump, unejump)", "Disables edgejump"}, function()
	if HumanModCons.ejLoop then
		HumanModCons.ejLoop:Disconnect()
		HumanModCons.ejLoop = nil
	end

	if HumanModCons.ejCA then
		HumanModCons.ejCA:Disconnect()
		HumanModCons.ejCA = nil
	end
end)

cmd.add({"equiptools","etools","equipt"},{"equiptools (etools,equipt)","Equips every tool in your inventory"},function()
	for i,v in pairs(LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") then
			v.Parent = getChar()
		end
	end
end)
cmd.add({"unequiptools"},{"unequiptools","Unequips every tool you are currently holding"},function()
	if getChar() then
		getChar():FindFirstChildOfClass('Humanoid'):UnequipTools()
	end
end)

bangLoop = nil
bangAnim = nil
bangDied = nil
doBang = nil
BANGPARTS = {}

cmd.add({"bang", "fuck"}, {"bang <player> <number> (fuck)", "fucks the player by attaching to them"}, function(h, d)
	if bangLoop then
		bangLoop:Disconnect()
	end
	if doBang then
		doBang:Stop()
	end
	if bangAnim then
		bangAnim:Destroy()
	end
	if bangDied then
		bangDied:Disconnect()
	end
	for _, p in pairs(BANGPARTS) do
		p:Destroy()
	end
	BANGPARTS = {}

	local speed = d or 10
	local username = h
	local targets = getPlr(username)
	if #targets == 0 then return end
	local plr = targets[1]

	bangAnim = InstanceNew("Animation")
	if not IsR15(Players.LocalPlayer) then
		bangAnim.AnimationId = "rbxassetid://148840371"
	else
		bangAnim.AnimationId = "rbxassetid://5918726674"
	end
	local hum = getHum()
	doBang = hum:LoadAnimation(bangAnim)
	doBang:Play(0.1, 1, 1)
	doBang:AdjustSpeed(speed)

	local bangplr = plr.Name
	bangDied = hum.Died:Connect(function()
		if bangLoop then
			bangLoop:Disconnect()
		end
		doBang:Stop()
		bangAnim:Destroy()
		if bangDied then
			bangDied:Disconnect()
		end
		for _, part in pairs(BANGPARTS) do
			part:Destroy()
		end
		BANGPARTS = {}
	end)

	local thick = 0.2
	local halfWidth = 2
	local halfDepth = 2
	local halfHeight = 3
	local walls = {
		{offset = CFrame.new(0, 0, halfDepth + thick/500), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(0, 0, -(halfDepth + thick/500)), size = Vector3.new(4, 6, thick)},
		{offset = CFrame.new(halfWidth + thick/500, 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(-(halfWidth + thick/500), 0, 0), size = Vector3.new(thick, 6, 4)},
		{offset = CFrame.new(0, halfHeight + thick/500, 0), size = Vector3.new(4, thick, 4)},
		{offset = CFrame.new(0, -(halfHeight + thick/500), 0), size = Vector3.new(4, thick, 4)}
	}
	for i, wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(BANGPARTS, part)
	end

	local bangOffset = CFrame.new(0, 0, 1.1)
	bangLoop = RunService.Stepped:Connect(function()
		NACaller(function()
			local targetPlayer = Players:FindFirstChild(bangplr)
			if not targetPlayer or not targetPlayer.Character then return end
			local targetRoot = getRoot(targetPlayer.Character)
			local localRoot = getRoot(getChar())
			if targetRoot and localRoot then
				localRoot.CFrame = targetRoot.CFrame * bangOffset
				for i, wall in ipairs(walls) do
					BANGPARTS[i].CFrame = localRoot.CFrame * wall.offset
				end
			end
		end)
	end)
end, true)

cmd.add({"unbang", "unfuck"}, {"unbang (unfuck)", "Unbangs the player"}, function()
	if bangLoop then
		bangLoop:Disconnect()
	end
	if doBang then
		doBang:Stop()
	end
	if bangAnim then
		bangAnim:Destroy()
	end
	if bangDied then
		bangDied:Disconnect()
	end
	for _, p in pairs(BANGPARTS) do
		p:Destroy()
	end
	BANGPARTS = {}
end)

inversebangLoop = nil
inversebangAnim = nil
inversebangAnim2 = nil
inversebangDied = nil
doInversebang = nil
doInversebang2 = nil
INVERSEBANGPARTS = {}

cmd.add({"inversebang","ibang","inverseb"},{"inversebang <player> <number>","you're the one getting fucked today ;)"},function(h,d)
	if inversebangLoop then inversebangLoop = nil end
	if doInversebang then doInversebang:Stop() end
	if inversebangAnim then inversebangAnim:Destroy() end
	if inversebangAnim2 then inversebangAnim2:Destroy() end
	if inversebangDied then inversebangDied:Disconnect() end
	for _,p in pairs(INVERSEBANGPARTS) do p:Destroy() end
	INVERSEBANGPARTS = {}

	local speed = d or 10
	local targets = getPlr(h)
	if #targets == 0 then return end
	local plr = targets[1]
	local bangplr = plr.Name

	inversebangAnim = InstanceNew("Animation")
	local isR15 = IsR15(Players.LocalPlayer)
	if not isR15 then
		inversebangAnim.AnimationId = "rbxassetid://189854234"
		inversebangAnim2 = InstanceNew("Animation")
		inversebangAnim2.AnimationId = "rbxassetid://106772613"
	else
		inversebangAnim.AnimationId = "rbxassetid://10714360343"
		inversebangAnim2 = nil
	end

	local hum = getHum()
	doInversebang = hum:LoadAnimation(inversebangAnim)
	doInversebang:Play(0.1,1,1)
	doInversebang:AdjustSpeed(speed)
	if not isR15 and inversebangAnim2 then
		doInversebang2 = hum:LoadAnimation(inversebangAnim2)
		doInversebang2:Play(0.1,1,1)
		doInversebang2:AdjustSpeed(speed)
	end

	inversebangDied = hum.Died:Connect(function()
		if inversebangLoop then inversebangLoop = nil end
		doInversebang:Stop()
		if doInversebang2 then doInversebang2:Stop() end
		inversebangAnim:Destroy()
		inversebangDied:Disconnect()
		for _,part in pairs(INVERSEBANGPARTS) do part:Destroy() end
		INVERSEBANGPARTS = {}
	end)

	local thick,halfWidth,halfDepth,halfHeight = 0.2,2,2,3
	local walls = {
		{offset=CFrame.new(0,0,halfDepth+thick/500),    size=Vector3.new(4,6,thick)},
		{offset=CFrame.new(0,0,-(halfDepth+thick/500)), size=Vector3.new(4,6,thick)},
		{offset=CFrame.new(halfWidth+thick/500,0,0),    size=Vector3.new(thick,6,4)},
		{offset=CFrame.new(-(halfWidth+thick/500),0,0), size=Vector3.new(thick,6,4)},
		{offset=CFrame.new(0,halfHeight+thick/500,0),   size=Vector3.new(4,thick,4)},
		{offset=CFrame.new(0,-(halfHeight+thick/500),0),size=Vector3.new(4,thick,4)},
	}
	for i,wall in ipairs(walls) do
		local part = InstanceNew("Part")
		part.Size = wall.size
		part.Anchored = true
		part.CanCollide = true
		part.Transparency = 1
		part.Parent = workspace
		Insert(INVERSEBANGPARTS,part)
	end

	inversebangLoop = coroutine.wrap(function()
		while true do
			local targetPlayer = Players:FindFirstChild(bangplr)
			local targetCharacter = targetPlayer and targetPlayer.Character
			local localCharacter = getChar()
			if targetCharacter and getRoot(targetCharacter) and localCharacter and getRoot(localCharacter) then
				local targetHRP = getRoot(targetCharacter)
				local localHRP = getRoot(localCharacter)
				local forwardCFrame = targetHRP.CFrame * CFrame.new(0,0,-2.5)
				local backwardCFrame = targetHRP.CFrame * CFrame.new(0,0,-1.3)
				local tweenForward = TweenService:Create(localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=forwardCFrame})
				tweenForward:Play()
				tweenForward.Completed:Wait()
				local tweenBackward = TweenService:Create(localHRP,TweenInfo.new(0.15,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{CFrame=backwardCFrame})
				tweenBackward:Play()
				tweenBackward.Completed:Wait()
				for i,wall in ipairs(walls) do
					INVERSEBANGPARTS[i].CFrame = localHRP.CFrame * wall.offset
				end
			end
			Wait(0.1)
		end
	end)
	inversebangLoop()
end,true)

cmd.add({"uninversebang","unibang","uninverseb"},{"uninversebang","no more fun"},function()
	if inversebangLoop then inversebangLoop = nil end
	if doInversebang then doInversebang:Stop() end
	if doInversebang2 then doInversebang2:Stop() end
	if inversebangAnim then inversebangAnim:Destroy() end
	if inversebangDied then inversebangDied:Disconnect() end
	for _,p in pairs(INVERSEBANGPARTS) do p:Destroy() end
	INVERSEBANGPARTS = {}
end)

sussyID = "rbxassetid://106772613"
susTrack, susCONN = nil, nil

cmd.add({"suslay", "laysus"}, {"suslay (laysus)", "Lay down in a suspicious way"}, function()
	if not IsR6() then return DoNotif("R6 only") end

	if susTrack then
		susTrack:Stop()
		susTrack = nil
	end

	if susCONN then
		susCONN:Disconnect()
		susCONN = nil
	end

	local hum = getHum()
	local root = hum.RootPart

	hum.Sit = true
	Wait(0.1)
	root.CFrame=root.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)

	for _, a in ipairs(hum:GetPlayingAnimationTracks()) do
		a:Stop()
	end

	local anim = InstanceNew("Animation")
	anim.AnimationId = sussyID
	susTrack = hum:LoadAnimation(anim)
	susTrack:Play()

	susCONN = hum:GetPropertyChangedSignal("Jump"):Connect(function()
		if susTrack then
			susTrack:Stop()
			susTrack = nil
		end
		if susCONN then
			susCONN:Disconnect()
			susCONN = nil
		end
	end)
end)

cmd.add({"unsuslay"}, {"unsuslay", "Stand up from the sussy lay"}, function()
	getHum():ChangeState(Enum.HumanoidStateType.Jumping)

	if susTrack then
		susTrack:Stop()
		susTrack = nil
	end

	if susCONN then
		susCONN:Disconnect()
		susCONN = nil
	end
end)

cmd.add({"jerk", "jork"}, {"jerk (jork)", "jorking it"}, function()
	local humanoid = getHum()
	local backpack = getBp()
	if not humanoid or not backpack then return end

	local tool = InstanceNew("Tool")
	tool.Name = "Jerk"
	tool.ToolTip = "oh yes i am feeling it COMING OUT AHHHHHHHHHHHHHHHHHHHHH"
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil

	local function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	humanoid.Died:Connect(stopTomfoolery)

	while Wait() do
		if not jorkin then continue end

		if not track then
			local anim = InstanceNew("Animation")
			anim.AnimationId = not IsR15() and "rbxassetid://72042024" or "rbxassetid://698251653"
			track = humanoid:LoadAnimation(anim)
		end

		track:Play()
		track:AdjustSpeed(IsR15() and 0.7 or 0.65)
		track.TimePosition = 0.6
		Wait(0.2)
		while track and track.TimePosition < (not IsR15() and 0.65 or 0.7) do Wait(0.2) end
		if track then
			track:Stop()
			track = nil
		end
	end
end)

huggiePARTS = {}
hugUI = nil
currentHugTracks = {}
currentHugTarget = nil
hugFromFront = false
hugModeEnabled = false

cmd.add({"hug", "clickhug"}, {"hug (clickhug)", "huggies time (click on a target to hug)"}, function()
	if IsR6() then
		local mouse = LocalPlayer:GetMouse()

		NAlib.disconnect("hug_toggle")
		NAlib.disconnect("hug_side")
		NAlib.disconnect("hug_click")
		NAlib.disconnect("hug_plat")

		for _, track in pairs(currentHugTracks) do NACaller(function() track:Stop() end) end
		currentHugTracks = {}

		if hugUI then hugUI:Destroy() end
		hugFromFront = false
		currentHugTarget = nil
		for _, part in pairs(huggiePARTS) do part:Destroy() end
		huggiePARTS = {}

		hugUI = InstanceNew("ScreenGui")
		hugUI.Name = "HugModeUI"
		NaProtectUI(hugUI)

		local toggleHugButton = InstanceNew("TextButton")
		toggleHugButton.AnchorPoint = Vector2.new(0.5, 0)
		toggleHugButton.Size = UDim2.new(0, 150, 0, 50)
		toggleHugButton.Position = UDim2.new(0.4, 0, 0.1, 0)
		toggleHugButton.Text = "Hug Mode: OFF"
		toggleHugButton.TextSize = 14
		toggleHugButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		toggleHugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleHugButton.Parent = hugUI

		local sideToggleButton = InstanceNew("TextButton")
		sideToggleButton.AnchorPoint = Vector2.new(0.5, 0)
		sideToggleButton.Size = UDim2.new(0, 150, 0, 50)
		sideToggleButton.Position = UDim2.new(0.6, 0, 0.1, 0)
		sideToggleButton.Text = "Hug Side: Back"
		sideToggleButton.TextSize = 14
		sideToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		sideToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		sideToggleButton.Parent = hugUI

		local uiCorner = InstanceNew("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = toggleHugButton

		local sideUICorner = InstanceNew("UICorner")
		sideUICorner.CornerRadius = UDim.new(0, 8)
		sideUICorner.Parent = sideToggleButton

		NAgui.draggerV2(toggleHugButton)
		NAgui.draggerV2(sideToggleButton)

		hugModeEnabled = false

		local function performHug(targetCharacter)
			currentHugTarget = targetCharacter

			local offsetDistance = 1.5
			local targetHRP = getRoot(targetCharacter)
			local localCharacter = LocalPlayer.Character
			if not localCharacter then return end
			local localHRP = getRoot(localCharacter)
			if targetHRP and localHRP then
				local offset = (hugFromFront and (targetHRP.CFrame.LookVector * offsetDistance)) or (-(targetHRP.CFrame.LookVector * offsetDistance))
				local initialHugPos = targetHRP.Position + offset
				localHRP.CFrame = CFrame.new(initialHugPos, targetHRP.Position)
				local humanoid = getPlrHum(localCharacter)
				if humanoid then
					local anim1 = InstanceNew("Animation")
					anim1.AnimationId = "rbxassetid://283545583"
					local track1 = humanoid:LoadAnimation(anim1)
					local anim2 = InstanceNew("Animation")
					anim2.AnimationId = "rbxassetid://225975820"
					local track2 = humanoid:LoadAnimation(anim2)
					Insert(currentHugTracks, track1)
					Insert(currentHugTracks, track2)
					track1:Play()
					track2:Play()

					if #huggiePARTS == 0 then
						local thick = 0.2
						local halfWidth = 2
						local halfDepth = 2
						local halfHeight = 3
						local walls = {
							{offset = CFrame.new(0, 0, halfDepth + thick/500), size = Vector3.new(4, 6, thick)},
							{offset = CFrame.new(0, 0, -(halfDepth + thick/500)), size = Vector3.new(4, 6, thick)},
							{offset = CFrame.new(halfWidth + thick/500, 0, 0), size = Vector3.new(thick, 6, 4)},
							{offset = CFrame.new(-(halfWidth + thick/500), 0, 0), size = Vector3.new(thick, 6, 4)},
							{offset = CFrame.new(0, halfHeight + thick/500, 0), size = Vector3.new(4, thick, 4)},
							{offset = CFrame.new(0, -(halfHeight + thick/500), 0), size = Vector3.new(4, thick, 4)}
						}
						for i, wall in ipairs(walls) do
							local part = InstanceNew("Part")
							part.Size = wall.size
							part.Anchored = true
							part.CanCollide = true
							part.Transparency = 1
							part.Parent = workspace
							Insert(huggiePARTS, part)
						end
						NAlib.connect("hug_plat", RunService.Stepped:Connect(function()
							local charRoot = getRoot(LocalPlayer.Character)
							if charRoot then
								for i, wall in ipairs(walls) do
									huggiePARTS[i].CFrame = charRoot.CFrame * wall.offset
								end
							end
						end))
					end

					Spawn(function()
						while hugModeEnabled and targetCharacter and getRoot(targetCharacter) and (currentHugTarget == targetCharacter) do
							targetHRP = getRoot(targetCharacter)
							offset = (hugFromFront and (targetHRP.CFrame.LookVector * offsetDistance)) or (-(targetHRP.CFrame.LookVector * offsetDistance))
							local newHugPos = targetHRP.Position + offset
							if localHRP then
								localHRP.CFrame = CFrame.new(newHugPos, targetHRP.Position)
							end
							Wait()
						end
					end)
				end
			end
		end

		NAlib.connect("hug_toggle", MouseButtonFix(toggleHugButton, function()
			hugModeEnabled = not hugModeEnabled
			if hugModeEnabled then
				toggleHugButton.Text = "Hug Mode: ON"
			else
				toggleHugButton.Text = "Hug Mode: OFF"
				for _, track in pairs(currentHugTracks) do NACaller(function() track:Stop() end) end
				currentHugTracks = {}
				currentHugTarget = nil
				for _, part in pairs(huggiePARTS) do part:Destroy() end
				huggiePARTS = {}
				NAlib.disconnect("hug_plat")
			end
		end))

		NAlib.connect("hug_side", MouseButtonFix(sideToggleButton, function()
			hugFromFront = not hugFromFront
			sideToggleButton.Text = (hugFromFront and "Hug Side: Front") or "Hug Side: Back"
		end))

		NAlib.connect("hug_click", LocalPlayer:GetMouse().Button1Down:Connect(function()
			if not hugModeEnabled then return end
			local target = mouse.Target
			if target and target.Parent then
				local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
				if targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer.Character then
					performHug(targetPlayer.Character)
				end
			end
		end))
	else
		DoNotif("command requires R6")
	end
end)

cmd.add({"unhug"}, {"unhug", "no huggies :("}, function()
	NAlib.disconnect("hug_toggle")
	NAlib.disconnect("hug_side")
	NAlib.disconnect("hug_click")
	NAlib.disconnect("hug_plat")

	for _, track in pairs(currentHugTracks) do NACaller(function() track:Stop() end) end
	currentHugTracks = {}
	currentHugTarget = nil
	hugFromFront = false
	hugModeEnabled = false
	for _, part in pairs(huggiePARTS) do part:Destroy() end
	huggiePARTS = {}
	if hugUI then hugUI:Destroy() hugUI = nil end
end)

glueloop = {}

cmd.add({"glue","loopgoto","lgoto"},{"glue <player>","Loop teleport to a player"},function(...)
	local input = (...)
	local players = getPlr(input)
	for _, p in next, players do
		local name = p.Name
		if glueloop[name] then glueloop[name]:Disconnect() end
		glueloop[name] = RunService.Stepped:Connect(function()
			local target = Players:FindFirstChild(name)
			if target and target.Character then
				getChar():PivotTo(target.Character:GetPivot()*CFrame.new(0,1.5,0))
			end
		end)
	end
end,true)

cmd.add({"unglue","unloopgoto","noloopgoto"},{"unglue","Stops teleporting you to a player"},function()
	for _, conn in pairs(glueloop) do conn:Disconnect() end
	glueloop = {}
end)

glueBACKER = {}

cmd.add({"glueback","loopbehind","lbehind"},{"glueback <player>","Loop teleport behind a player"},function(...)
	local input   = (...)
	local targets = getPlr(input)
	for _,target in next,targets do
		local name = target.Name
		if glueBACKER[name] then
			glueBACKER[name]:Disconnect()
			glueBACKER[name] = nil
		end
		glueBACKER[name] = RunService.Stepped:Connect(function()
			local tp = Players:FindFirstChild(name)
			if not tp or not tp.Character then return end
			getChar():PivotTo(tp.Character:GetPivot()*CFrame.new(0,1.5,3))
		end)
	end
end,true)

cmd.add({"unglueback","unloopbehind","unlbehind"},{"unglueback","Stops teleporting you to a player"},function()
	for _,conn in pairs(glueBACKER) do conn:Disconnect() end
	glueBACKER = {}
end)

cmd.add({"spook", "scare"}, {"spook <player> (scare)", "Teleports next to a player for a few seconds"}, function(...)
	local username = (...)
	local targets = getPlr(username)
	for _, plr in next, targets do
		local char = getChar()
		local root = getRoot(char)
		local oldCF = root.CFrame
		local distancepl = 2
		if getPlrHum(plr) then
			local targetRoot = getRoot(plr.Character)
			if targetRoot then
				root.CFrame = targetRoot.CFrame + targetRoot.CFrame.LookVector * distancepl
				root.CFrame = CFrame.new(root.Position, targetRoot.Position)
				Wait(0.5)
				root.CFrame = oldCF
			end
		end
	end
end, true)

loopspook = false

cmd.add({"loopspook","loopscare"},{"loopspook <player>","Teleports next to a player repeatedly"},function(...)
	local input = (...)
	local names = {}
	for _, p in ipairs(getPlr(input)) do
		names[#names+1] = p.Name
	end
	loopspook = true

	Spawn(function()
		while loopspook do
			for _, name in ipairs(names) do
				local target = Players:FindFirstChild(name)
				if target and getPlrHum(target) then
					local lc = getChar()
					local lr = getRoot(lc)
					local tr = getRoot(target.Character)
					if lr and tr then
						local old = lr.CFrame
						lr.CFrame = tr.CFrame + tr.CFrame.LookVector * 2
						lr.CFrame = CFrame.new(lr.Position, tr.Position)
						Wait(0.5)
						lr.CFrame = old
					end
				end
			end
			Wait(0.3)
		end
	end)
end,true)

cmd.add({"unloopspook","unloopscare"},{"unloopspook","Stops the loopspook command"},function()
	loopspook = false
end)

Airwalker, awPart = nil, nil
local airwalk = {
	Vars = {
		keybinds = {
			Increase = Enum.KeyCode.E,
			Decrease = Enum.KeyCode.Q,
		},
		decrease = false,
		increase = false,
		offset = 0,
	},
	connections = {},
	guis = {},
}

cmd.add({"airwalk", "float", "aw"}, {"airwalk (float, aw)", "Press space to go up, unairwalk to stop"}, function()
	DebugNotif(IsOnMobile and "Airwalk: ON" or "Airwalk: ON (Q And E)")
	if Airwalker then Airwalker:Disconnect() Airwalker = nil end
	if awPart then awPart:Destroy() awPart = nil end

	function createButton(parent, text, position, callbackDown, callbackUp)
		local button = InstanceNew("TextButton")
		button.Parent = parent
		button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		button.BackgroundTransparency = 0
		button.Position = position
		button.Size = UDim2.new(0.05, 0, 0.1, 0)
		button.Font = Enum.Font.SourceSansBold
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 18
		button.TextScaled = true
		button.AutoButtonColor = false

		local corner = InstanceNew("UICorner", button)
		corner.CornerRadius = UDim.new(0.2, 0)

		local stroke = InstanceNew("UIStroke", button)
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Thickness = 2

		local hoverEffect = function(isHovering)
			button.BackgroundColor3 = isHovering and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(45, 45, 45)
		end

		button.MouseEnter:Connect(function() hoverEffect(true) end)
		button.MouseLeave:Connect(function() hoverEffect(false) end)
		button.MouseButton1Down:Connect(callbackDown)
		button.MouseButton1Up:Connect(callbackUp)
		NAgui.draggerV2(button)

		return button
	end

	if IsOnMobile then
		local guiDown = InstanceNew("ScreenGui")
		NaProtectUI(guiDown)
		guiDown.ResetOnSpawn = false
		airwalk.guis.down = guiDown
		createButton(guiDown, "DOWN", UDim2.new(0.9, 0, 0.7, 0), function() airwalk.Vars.decrease = true end, function() airwalk.Vars.decrease = false end)

		local guiUp = InstanceNew("ScreenGui")
		NaProtectUI(guiUp)
		guiUp.ResetOnSpawn = false
		airwalk.guis.up = guiUp
		createButton(guiUp, "UP", UDim2.new(0.9, 0, 0.5, 0), function() airwalk.Vars.increase = true end, function() airwalk.Vars.increase = false end)
	else
		airwalk.connections.inputBegan = uis.InputBegan:Connect(function(input)
			if input.KeyCode == airwalk.Vars.keybinds.Increase then airwalk.Vars.increase = true end
			if input.KeyCode == airwalk.Vars.keybinds.Decrease then airwalk.Vars.decrease = true end
		end)
		airwalk.connections.inputEnded = uis.InputEnded:Connect(function(input)
			if input.KeyCode == airwalk.Vars.keybinds.Increase then airwalk.Vars.increase = false end
			if input.KeyCode == airwalk.Vars.keybinds.Decrease then airwalk.Vars.decrease = false end
		end)
	end

	awPart = InstanceNew("Part", workspace)
	awPart.Size = Vector3.new(7, 2, 3)
	awPart.CFrame = getRoot(getChar()).CFrame - Vector3.new(0, 4, 0)
	awPart.Transparency = 1
	awPart.Anchored = true
	airwalk.Y = getRoot(getChar()).CFrame.y

	Airwalker = RunService.Stepped:Connect(function()
		if not awPart then Airwalker:Disconnect() return end
		airwalk.Vars.offset = airwalk.Vars.decrease and 5 or (airwalk.Vars.increase and 3.5 or 4)
		if airwalk.Vars.offset == 4 then
			local smalldis = getRoot(getChar()).CFrame.y - airwalk.Y
			if smalldis < 0.01 then
				getRoot(getChar()).CFrame = CFrame.new(getRoot(getChar()).CFrame.X, airwalk.Y, getRoot(getChar()).CFrame.Z) * getRoot(getChar()).CFrame.Rotation
			end
		end
		airwalk.Y = getRoot(getChar()).CFrame.y
		awPart.CFrame = getRoot(getChar()).CFrame - Vector3.new(0, airwalk.Vars.offset, 0)
	end)
end)

cmd.add({"unairwalk", "unfloat", "unaw"}, {"unairwalk (unfloat, unaw)", "Stops the airwalk command"}, function()
	if Airwalker then Airwalker:Disconnect() Airwalker = nil end
	if awPart then awPart:Destroy() awPart = nil end
	for _, conn in pairs(airwalk.connections) do
		if conn then conn:Disconnect() end
	end
	airwalk.connections = {}
	for _, gui in pairs(airwalk.guis) do
		if gui then gui:Destroy() end
	end
	airwalk.guis = {}
	DebugNotif("Airwalk: OFF")
end)

bringc = {}

cmd.add({"cbring", "clientbring"}, {"clientbring <player> (cbring)", "Brings the player on your client"}, function(...)
	local username = (...)
	local target = getPlr(username)
	if #target == 0 then return end
	if NAlib.isConnected("noclip") then
		NAlib.disconnect("noclip")
	end
	for _, conn in ipairs(bringc) do
		conn:Disconnect()
	end
	bringc = {}
	NAlib.connect("noclip", RunService.Stepped:Connect(function()
		local char = getChar()
		if not char then return end
		for _, descendant in pairs(char:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.CanCollide = false
			end
		end
	end))
	for _, plr in next, target do
		if not plr then return end
		local conn = RunService.RenderStepped:Connect(function()
			if getPlrChar(plr) then
				local targetRoot = getRoot(getPlrChar(plr))
				local localRoot = getRoot(getChar())
				if targetRoot and localRoot then
					targetRoot.CFrame = localRoot.CFrame + localRoot.CFrame.LookVector * 3
				end
			end
		end)
		Insert(bringc, conn)
	end
end, true)

cmd.add({"uncbring", "unclientbring"}, {"unclientbring (uncbring)", "Disable Client bring command"}, function()
	for _, conn in ipairs(bringc) do
		conn:Disconnect()
	end
	bringc = {}
	if NAlib.isConnected("noclip") then
		NAlib.disconnect("noclip")
	end
end)

cmd.add({"mute", "muteboombox"}, {"mute <player> (muteboombox)", "Mutes the player's boombox"}, function(...)
	local uuuu = ...
	local pp = getPlr(uuuu)
	if #pp == 0 then return end

	local function NONOSOUND(container)
		for _, descendant in ipairs(container:GetDescendants()) do
			if descendant:IsA("Sound") and descendant.Playing then
				descendant.Playing = false
			end
		end
	end

	for _, plr in ipairs(pp) do
		if plr and plr.Character then
			NONOSOUND(plr.Character)
		end

		local BK = plr:FindFirstChildOfClass("Backpack")
		if BK then
			NONOSOUND(BK)
		end
	end
end, true)

TPWalk = false

cmd.add({"tpwalk", "tpwalk"}, {"tpwalk <number>", "More undetectable walkspeed script"}, function(...)
	if TPWalk then
		TPWalk = false
		NAlib.disconnect("TPWalkingConnection")
	end

	TPWalk = true
	local Speed = ...

	NAlib.connect("TPWalkingConnection", RunService.Stepped:Connect(function(_, deltaTime)
		if TPWalk then
			local humanoid = getHum()
			if humanoid and humanoid.MoveDirection.Magnitude > 0 then
				local moveDirection = humanoid.MoveDirection
				local translation = moveDirection * (Speed or 1) * deltaTime * 10
				getChar():TranslateBy(translation)
			end
		end
	end))
end, true)

cmd.add({"untpwalk"}, {"untpwalk", "Stops the tpwalk command"}, function()
	TPWalk = false
	NAlib.disconnect("TPWalkingConnection")
end)

local tptptpSPEED = {
	enabled = false;
	part = nil;
	accumulator = 0;
	pos = Vector3.new();
	useCollisionCheck = false;
	useStepMovement = false;
	oldUI = nil;
	oldSpeed = nil;
	speedConn = nil;
}

cmd.add({"tpspeed","tpspeed"},{"tpspeed <number>","Teleport in leaps with visual target"}, function(...)
	if tptptpSPEED.enabled then
		tptptpSPEED.enabled = false
		NAlib.disconnect("TPSpeedVisual")
		if tptptpSPEED.part then tptptpSPEED.part:Destroy() tptptpSPEED.part = nil end
		if tptptpSPEED.oldUI then tptptpSPEED.oldUI:Destroy() tptptpSPEED.oldUI = nil end
		if tptptpSPEED.speedConn then tptptpSPEED.speedConn:Disconnect() tptptpSPEED.speedConn = nil end
		local humanoid = getHum()
		if humanoid and tptptpSPEED.oldSpeed then humanoid.WalkSpeed = tptptpSPEED.oldSpeed end
	end

	tptptpSPEED.enabled = true
	local speed = tonumber(...) or 1
	local char = getChar()
	tptptpSPEED.pos = char:GetPivot().Position
	tptptpSPEED.accumulator = 0

	tptptpSPEED.part = InstanceNew("Part", workspace)
	tptptpSPEED.part.Size = Vector3.new(2,2,2)
	tptptpSPEED.part.Anchored = true
	tptptpSPEED.part.CanCollide = false
	tptptpSPEED.part.Material = Enum.Material.SmoothPlastic
	tptptpSPEED.part.Color = Color3.fromRGB(0,255,0)
	tptptpSPEED.part.Transparency = 0.5

	tptptpSPEED.oldUI = InstanceNew("ScreenGui")
	NaProtectUI(tptptpSPEED.oldUI)
	tptptpSPEED.oldUI.Name = "TPSpeedGui"
	tptptpSPEED.oldUI.ResetOnSpawn = false

	local function createButton(name, text, xScale)
		local btn = InstanceNew("TextButton", tptptpSPEED.oldUI)
		btn.Name = name
		btn.Text = text
		btn.Size = UDim2.new(0.1,0,0.04,0)
		btn.Position = UDim2.new(xScale,0,0.02,0)
		btn.AnchorPoint = Vector2.new(0.5,0)
		btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		btn.TextColor3 = Color3.new(1,1,1)
		local corner = InstanceNew("UICorner", btn)
		corner.CornerRadius = UDim.new(0.5,0)
		return btn
	end

	local collisionBtn = createButton("CollisionCheckButton","Collision: Off",0.4)
	local movementBtn  = createButton("MovementModeButton",  "Mode: Snap",  0.6)

	MouseButtonFix(collisionBtn, function()
		tptptpSPEED.useCollisionCheck = not tptptpSPEED.useCollisionCheck
		collisionBtn.Text = "Collision: "..(tptptpSPEED.useCollisionCheck and "On" or "Off")
	end)
	MouseButtonFix(movementBtn, function()
		tptptpSPEED.useStepMovement = not tptptpSPEED.useStepMovement
		movementBtn.Text = "Mode: "..(tptptpSPEED.useStepMovement and "Step" or "Snap")
	end)
	NAgui.draggerV2(collisionBtn)
	NAgui.draggerV2(movementBtn)

	do
		local humanoid = getHum()
		if humanoid then
			tptptpSPEED.oldSpeed = humanoid.WalkSpeed
			tptptpSPEED.speedConn = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				local new = humanoid.WalkSpeed
				if new > 0 then tptptpSPEED.oldSpeed = new end
				humanoid.WalkSpeed = 0
			end)
			humanoid.WalkSpeed = 0
		end
	end

	NAlib.connect("TPSpeedVisual", RunService.Stepped:Connect(function(_,dt)
		if not tptptpSPEED.enabled then return end
		local char = getChar()
		local humanoid = getHum()
		if humanoid and humanoid.MoveDirection.Magnitude > 0 then
			local dir = humanoid.MoveDirection.Unit
			local origin = char:GetPivot().Position
			local leap = speed * 0.4 * 10
			local newPos = (tptptpSPEED.useStepMovement
				and tptptpSPEED.pos + dir * (speed * dt * 10)
				or origin + dir * leap)

			if tptptpSPEED.useCollisionCheck then
				local half = tptptpSPEED.part.Size/2
				local region = Region3.new(newPos-half, newPos+half)
				local parts = workspace:FindPartsInRegion3WithIgnoreList(region,{char,tptptpSPEED.part},10)
				local ok = true
				for _,p in ipairs(parts) do if p.CanCollide then ok=false break end end
				if ok then tptptpSPEED.pos = newPos end
			else
				tptptpSPEED.pos = newPos
			end

			tptptpSPEED.part.CFrame = CFrame.new(tptptpSPEED.pos)
			tptptpSPEED.accumulator = tptptpSPEED.accumulator + dt
			if tptptpSPEED.accumulator >= 0.4 then
				tptptpSPEED.accumulator = tptptpSPEED.accumulator - 0.4
				local pivot = char:GetPivot()
				char:PivotTo(CFrame.new(tptptpSPEED.pos)*(pivot-pivot.Position))
			end
		end
	end))
end, true)

cmd.add({"untpspeed"},{"untpspeed","Stops the tpspeed command"}, function()
	if tptptpSPEED.enabled then
		tptptpSPEED.enabled = false
		NAlib.disconnect("TPSpeedVisual")
		if tptptpSPEED.part then tptptpSPEED.part:Destroy() tptptpSPEED.part=nil end
		if tptptpSPEED.oldUI then tptptpSPEED.oldUI:Destroy() tptptpSPEED.oldUI=nil end
		if tptptpSPEED.speedConn then tptptpSPEED.speedConn:Disconnect() tptptpSPEED.speedConn=nil end
		local humanoid = getHum()
		if humanoid and tptptpSPEED.oldSpeed then humanoid.WalkSpeed = tptptpSPEED.oldSpeed end
	end
end)

muteLOOP = {}

cmd.add({"loopmute", "loopmuteboombox"}, {"loopmute <player> (loopmuteboombox)", "Loop mutes the player's boombox"}, function(...)
	local u = ...
	local pls = getPlr(u)
	if #pls == 0 then return end

	local function mute(p)
		if p and p.Character then
			for _, d in ipairs(p.Character:GetDescendants()) do
				if d:IsA("Sound") and d.Playing then
					d.Playing = false
				end
			end
		end
		local bp = p:FindFirstChildOfClass("Backpack")
		if bp then
			for _, d in ipairs(bp:GetDescendants()) do
				if d:IsA("Sound") and d.Playing then
					d.Playing = false
				end
			end
		end
	end

	for _, p in ipairs(pls) do
		local id = p.UserId
		if not muteLOOP[id] then
			muteLOOP[id] = Spawn(function()
				while p and p.Parent do
					mute(p)
					Wait(1)
				end
				muteLOOP[id] = nil
			end)
			DebugNotif("Loopmuted "..p.Name)
		else
			DebugNotif(p.Name.." already loopmuted")
		end
	end
end, true)

cmd.add({"unloopmute", "unloopmuteboombox"}, {"unloopmute <player> (unloopmuteboombox)", "Unloop mutes the player's boombox"}, function(...)
	local u = ...
	local pls = getPlr(u)
	if #pls == 0 then return end

	for _, p in ipairs(pls) do
		local id = p.UserId
		local t = muteLOOP[id]
		if t then
			coroutine.close(t)
			muteLOOP[id] = nil
			DebugNotif("Unloopmuted "..p.Name)
		else
			DebugNotif(p.Name.." not loopmuted")
		end
	end
end, true)

cmd.add({"getmass"}, {"getmass <player>", "Get your mass"}, function(...)
	local target = getPlr(...)
	for _, plr in next, target do
		local char = getPlrChar(plr)
		if char then
			local root = getRoot(char)
			if root then
				local mass = root.AssemblyMass
				DoNotif(nameChecker(plr).."'s mass is "..mass)
			end
		end
		Wait()
	end
end, true)

cmd.add({"copyposition", "copypos", "cpos"}, {"copyposition <player>", "Get the position of another player"}, function(...)
	local target = getPlr(...)
	for _, plr in next, target do
		local char = getPlrChar(plr)
		if char then
			local root = getRoot(char)
			if root then
				local pos = root.Position
				DebugNotif(nameChecker(plr).."'s position is: "..tostring(pos))
				if setclipboard then
					setclipboard(tostring(pos))
				end
			end
		end
		Wait()
	end
end, true)

cmd.add({"equiptools"},{"equiptools","Equips every tool in your inventory at once"},function()
	for i,v in pairs(Player:FindFirstChildOfClass("Backpack"):GetChildren()) do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent=Player.Character
		end
	end
end)

cmd.add({"unequiptools"},{"unequiptools","Unequips every tool you are currently holding at once"},function()
	Player.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

cmd.add({"removeterrain", "rterrain", "noterrain"},{"removeterrain (rterrain, noterrain)","clears terrain"},function()
	workspace:FindFirstChildOfClass('Terrain'):Clear()
end)

cmd.add({"clearnilinstances", "nonilinstances", "cni"},{"clearnilinstances (nonilinstances, cni)","Removes nil instances"},function()
	if getnilinstances then
		for _,nill in pairs(getnilinstances()) do
			nill:Destroy()
		end
	else
		DoNotif("Your exploit does not support getnilinstances")
	end
end)

cmd.add({"inspect"}, {"inspect", "checks a user's items"}, function(args)
	local targetPlayers = getPlr(args)

	for _, plr in next, targetPlayers do
		SafeGetService("GuiService"):CloseInspectMenu()
		SafeGetService("GuiService"):InspectPlayerFromUserId(plr.UserId)
	end
end, true)

function nuhuhprompt(v)
	NACaller(function()
		for _, o in COREGUI:GetChildren() do
			if o:IsA("GuiBase") and o.Name:lower():find("purchaseprompt") then
				o.Enabled = v
			end
		end
	end)
end

cmd.add({"noprompt","nopurchaseprompts","noprompts"},{"noprompt (nopurchaseprompts,noprompts)","remove the stupid purchase prompt"},function()
	nuhuhprompt(false)
	DebugNotif("Purchase prompts have been disabled")
end)

cmd.add({"prompt","purchaseprompts","showprompts","showpurchaseprompts"},{"prompt (purchaseprompts,showprompts,showpurchaseprompts)","allows the stupid purchase prompt"},function()
	nuhuhprompt(true)
	DebugNotif("Purchase prompts have been enabled")
end)

cmd.add({"wallwalk"},{"wallwalk","Makes you walk on walls"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/WallWalk.lua"))() -- backup cause i don't trust pastebin
end)

hiddenGUIS = {}

cmd.add({"hideguis"}, {"hideguis", "Hides GUIs"}, function()
	for _, guiElement in pairs(PlrGui:GetDescendants()) do
		if (guiElement:IsA("Frame") or guiElement:IsA("ImageLabel") or guiElement:IsA("ScrollingFrame")) and guiElement.Visible then
			guiElement.Visible = false
			if not Discover(hiddenGUIS, guiElement) then
				Insert(hiddenGUIS, guiElement)
			end
		end
	end
end)

cmd.add({"showguis"}, {"showguis", "Shows GUIs that were hidden using hideguis"}, function()
	for _, guiElement in pairs(hiddenGUIS) do
		guiElement.Visible = true
	end
	hiddenGUIS = {}
end)

spinThingy = nil
spinPart = nil

cmd.add({"spin"}, {"spin {amount}", "Makes your character spin as fast as you want"}, function(...)
	Wait()

	local spinSpeed = (...)
	if not spinSpeed then spinSpeed = 20 end

	if spinThingy then
		spinThingy:Destroy()
		spinThingy = nil
	end

	if spinPart then
		spinPart:Destroy()
		spinPart = nil
	end

	spinPart = InstanceNew("Part")
	spinPart.Anchored = false
	spinPart.CanCollide = false
	spinPart.Transparency = 1
	spinPart.Size = Vector3.new(1, 1, 1)
	spinPart.Parent = workspace
	spinPart.CFrame = getRoot(LocalPlayer.Character).CFrame

	spinThingy = InstanceNew("BodyAngularVelocity")
	spinThingy.Parent = spinPart
	spinThingy.MaxTorque = Vector3.new(0, math.huge, 0)
	spinThingy.AngularVelocity = Vector3.new(0, spinSpeed, 0)

	local weld = InstanceNew("WeldConstraint")
	weld.Part0 = spinPart
	weld.Part1 = getRoot(LocalPlayer.Character)
	weld.Parent = spinPart

	DebugNotif("Spinning...")
end, true)

cmd.add({"unspin"}, {"unspin", "Makes your character unspin"}, function()
	Wait()

	if spinThingy then
		spinThingy:Destroy()
		spinThingy = nil
	end

	if spinPart then
		spinPart:Destroy()
		spinPart = nil
	end

	DebugNotif("Spin Disabled", 3)
end)

cmd.add({"notepad"},{"notepad","notepad for making scripts / etc"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NAnotepad.lua"))()
end)

cmd.add({"rc7"},{"rc7","RC7 Internal UI"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/rc%20sexy%207"))()
end)

cmd.add({"scriptviewer","viewscripts"},{"scriptviewer (viewscripts)","Can view scripts made by 0866"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/scriptviewer",true))()
end)

cmd.add({"hydroxide","hydro"},{"hydroxide (hydro)","executes hydroxide"},function()
	if IsOnMobile then
		local owner = "Hosvile"
		local branch = "revision"

		local function webImport(file)
			return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/MC-Hydroxide/%s/%s.lua"):format(owner, branch, file)), file..'.lua')()
		end

		webImport("init")
		webImport("ui/main")
	else
		local owner="Upbolt"
		local branch="revision"

		local function webImport(file)
			return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner,branch,file)),file..'.lua')()
		end

		webImport("init")
		webImport("ui/main")
	end
end)

cmd.add({"remotespy","simplespy","rspy"},{"remotespy (simplespy,rspy)","executes simplespy that supports both pc and mobile"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/simplee%20spyyy%20mobilee"))()
end)

cmd.add({"turtlespy","tspy"},{"turtlespy (tspy)","executes Turtle Spy that supports both pc and mobile"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Turtle%20Spy.lua"))()
end)

cmd.add({"gravity","grav"},{"gravity <amount> (grav)","sets game gravity to whatever u want"},function(...)
	workspace.Gravity=(...)
end,true)

cmd.add({"fireclickdetectors","fcd","firecd"},{"fireclickdetectors (fcd,firecd)","Fires every ClickDetector in Workspace"},function(...)
	local args={...}
	local target=args[1] and Concat(args," "):lower()
	if typeof(fireclickdetector)~="function" then return DoNotif("fireclickdetector not available",3) end
	local list,f={},0
	for _,d in ipairs(interactTbl.click) do
		if not target or d.Name:lower()==target or (d.Parent and d.Parent.Name:lower()==target) then
			Insert(list,d)
		end
	end
	if #list==0 then
		if target then return DebugNotif("No ClickDetectors found matching \""..target.."\"",2) end
		return DebugNotif("No ClickDetectors found",2)
	end
	for _,d in ipairs(list) do
		if not pcall(function() fireclickdetector(d) end) then f += 1 end
	end
	Wait()
	if f>0 then
		DebugNotif(("Fired %d ClickDetectors, Failed: %d"):format(#list,f),2)
	else
		DebugNotif(("Fired %d ClickDetectors"):format(#list),2)
	end
end,true)

cmd.add({"fireproximityprompts","fpp","firepp"},{"fireproximityprompts (fpp,firepp)","Fires every ProximityPrompt in Workspace"},function(...)
	local args={...}
	local target=args[1] and Concat(args," "):lower()
	if typeof(fireproximityprompt)~="function" then return DoNotif("fireproximityprompt not available",3) end
	local list,f={},0
	for _,p in ipairs(interactTbl.proxy) do
		if not target or p.Name:lower()==target or (p.Parent and p.Parent.Name:lower()==target) then
			Insert(list,p)
		end
	end
	if #list==0 then
		if target then return DebugNotif("No ProximityPrompts found matching \""..target.."\"",2) end
		return DebugNotif("No ProximityPrompts found",2)
	end
	for _,p in ipairs(list) do
		if not pcall(function() fireproximityprompt(p,1) end) then f += 1 end
	end
	Wait()
	if f>0 then
		DebugNotif(("Fired %d ProximityPrompts, Failed: %d"):format(#list,f),2)
	else
		DebugNotif(("Fired %d ProximityPrompts"):format(#list),2)
	end
end,true)

cmd.add({"firetouchinterests","fti"},{"firetouchinterests (fti)","Fires every TouchInterest in Workspace"},function(...)
	local args = {...}
	local target = args[1] and Lower(Concat(args," ")):lower()
	if typeof(firetouchinterest) ~= "function" then return end
	local char = getChar()
	local root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
	if not root then return end
	local found = 0
	for _,t in ipairs(interactTbl.touch) do
		local nameMatch = not target or Lower(t.Name)==target or (t.Parent and Lower(t.Parent.Name)==target)
		if nameMatch then
			local container = t.Parent
			local part = container:IsA("BasePart") and container or container:FindFirstAncestorWhichIsA("BasePart")
			if part then
				found += 1
				Spawn(function()
					local orig = part.CFrame
					part.CFrame = root.CFrame
					firetouchinterest(part,root,1)
					Wait()
					firetouchinterest(part,root,0)
					Delay(0.1,function() part.CFrame = orig end)
				end)
			end
		end
	end
	if found == 0 then
		if target then
			DebugNotif(("No TouchInterests found matching \"%s\""):format(target),2)
		else
			DebugNotif("No TouchInterests found",2)
		end
	else
		DebugNotif(("Fired %d TouchInterests"):format(found),2)
	end
end,true)

cmd.add({"AutoFireClick","afc"},{"AutoFireClick <interval> [target] (afc)","Automatically fires ClickDetectors matching [target] every <interval> seconds (default 0.1)"},function(...)
	local args = {...}
	local interval = tonumber(args[1]) or 0.1
	local target = args[2] and Lower(Concat(args," ",2))
	local last = tick()
	NAlib.connect("AutoFireClick", RunService.Heartbeat:Connect(function()
		if tick() - last >= interval then
			last = tick()
			for _, d in ipairs(interactTbl.click) do
				local part = d.Parent:IsA("BasePart") and d.Parent or d:FindFirstAncestorWhichIsA("BasePart")
				if part and (not target
					or Lower(part.Name) == target
					or (part.Parent and Lower(part.Parent.Name) == target)) then
					pcall(fireclickdetector, d)
				end
			end
		end
	end))
	if target then
		DebugNotif(("AutoFireClick \"%s\" started"):format(target),2)
	else
		DebugNotif("AutoFireClick started",2)
	end
end, true)

cmd.add({"AutoFireProxi","afp"},{"AutoFireProxi <interval> [target] (afp)","Automatically fires ProximityPrompts matching [target] every <interval> seconds (default 0.1)"},function(...)
	local args = {...}
	local interval = tonumber(args[1]) or 0.1
	local target = args[2] and Lower(Concat(args," ",2))
	local last = tick()
	NAlib.connect("AutoFireProxi", RunService.Heartbeat:Connect(function()
		if tick() - last >= interval then
			last = tick()
			for _, p in ipairs(interactTbl.proxy) do
				local part = p.Parent:IsA("BasePart") and p.Parent or p:FindFirstAncestorWhichIsA("BasePart")
				if part and (not target
					or Lower(part.Name) == target
					or (part.Parent and Lower(part.Parent.Name) == target)) then
					pcall(fireproximityprompt, p, 1)
				end
			end
		end
	end))
	if target then
		DebugNotif(("AutoFireProxi \"%s\" started"):format(target),2)
	else
		DebugNotif("AutoFireProxi started",2)
	end
end, true)

cmd.add({"AutoTouch","at"},{"AutoTouch <interval> [target] (at)","Automatically fires TouchInterests on parts matching [target] every <interval> seconds (default 1)"},function(...)
	local args = {...}
	local interval = tonumber(args[1]) or 1
	local target = args[2] and Lower(Concat(args," ",2)):lower()
	local last = tick()
	NAlib.connect("AutoTouch",RunService.Heartbeat:Connect(function()
		if tick()-last < interval then return end
		last = tick()
		local char = getChar()
		local root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
		if not root then return end
		for _,t in ipairs(interactTbl.touch) do
			local nameMatch = not target or Lower(t.Name)==target or (t.Parent and Lower(t.Parent.Name)==target)
			if nameMatch then
				local container = t.Parent
				local part = container:IsA("BasePart") and container or container:FindFirstAncestorWhichIsA("BasePart")
				if part then
					Spawn(function()
						local orig = part.CFrame
						part.CFrame = root.CFrame
						firetouchinterest(part,root,1)
						Wait()
						firetouchinterest(part,root,0)
						Delay(0.1,function() part.CFrame = orig end)
					end)
				end
			end
		end
	end))
	if target then
		DebugNotif(("AutoTouch \"%s\" started"):format(target),2)
	else
		DebugNotif("AutoTouch started",2)
	end
end,true)

cmd.add({"unautofireclick","uafc"},{"unautofireclick (uafc)","Stops the AutoFireClick loop"},function()
	if NAlib.isConnected("AutoFireClick") then
		NAlib.disconnect("AutoFireClick")
		DebugNotif("AutoFireClick stopped",2)
	else
		DebugNotif("AutoFireClick not running",2)
	end
end)

cmd.add({"unautofireproxi","uafp"},{"unautofireproxi (uafp)","Stops the AutoFireProxi loop"},function()
	if NAlib.isConnected("AutoFireProxi") then
		NAlib.disconnect("AutoFireProxi")
		DebugNotif("AutoFireProxi stopped",2)
	else
		DebugNotif("AutoFireProxi not running",2)
	end
end)

cmd.add({"unautotouch","uat"},{"unautotouch (uat)","Stops the AutoTouch loop"},function()
	if NAlib.isConnected("AutoTouch") then
		NAlib.disconnect("AutoTouch")
		DebugNotif("AutoTouch stopped",2)
	else
		DebugNotif("AutoTouch not running",2)
	end
end)

cmd.add({"noclickdetectorlimits","nocdlimits","removecdlimits"},{"noclickdetectorlimits <limit> (nocdlimits,removecdlimits)","Sets all click detectors MaxActivationDistance to math.huge"},function(...)
	local limit = (...) or math.huge
	for _,v in ipairs(interactTbl.click) do
		v.MaxActivationDistance = limit
	end
end,true)

cmd.add({"noproximitypromptlimits","nopplimits","removepplimits"},{"noproximitypromptlimits <limit> (nopplimits,removepplimits)","Sets all proximity prompts MaxActivationDistance to math.huge"},function(...)
	local limit = (...) or math.huge
	for _,v in ipairs(interactTbl.proxy) do
		v.MaxActivationDistance = limit
	end
end,true)

cmd.add({"instantproximityprompts","instantpp","ipp"},{"instantproximityprompts (instantpp,ipp)","Disable the cooldown for proximity prompts"},function()
	NAlib.disconnect("instantpp")
	NAlib.connect("instantpp", SafeGetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(pp)
		fireproximityprompt(pp, 1)
	end))
end)

cmd.add({"uninstantproximityprompts","uninstantpp","unipp"},{"uninstantproximityprompts (uninstantpp,unipp)","Undo the cooldown removal"},function()
	NAlib.disconnect("instantpp")
end)

cmd.add({"r6"},{"r6","Shows a prompt that will switch your character rig type into R6"},function()
	SafeGetService("AvatarEditorService"):PromptSaveAvatar(getPlrHum(LocalPlayer).HumanoidDescription,Enum.HumanoidRigType.R6)
	SafeGetService("AvatarEditorService").PromptSaveAvatarCompleted:Wait()
	getHum():ChangeState(Enum.HumanoidStateType.Dead)
	getHum().Health=0
end)

cmd.add({"r15"},{"r15","Shows a prompt that will switch your character rig type into R15"},function()
	SafeGetService("AvatarEditorService"):PromptSaveAvatar(getPlrHum(LocalPlayer).HumanoidDescription,Enum.HumanoidRigType.R15)
	SafeGetService("AvatarEditorService").PromptSaveAvatarCompleted:Wait()
	getHum():ChangeState(Enum.HumanoidStateType.Dead)
	getHum().Health=0
end)

cmd.add({"maxslopeangle", "msa"}, {"maxslopeangle (msa)", "Changes your character's MaxSlopeAngle"}, function(...)
	local args = {...}
	local amount = tonumber(args[1]) or 89

	local humanoid = getHum()
	if humanoid then
		humanoid.MaxSlopeAngle = amount
		DebugNotif(Format("Set MaxSlopeAngle to %s", tostring(amount)), 2)
	else
		DebugNotif("Humanoid not found or invalid.", 2)
	end
end,true)

-- garbage that needs to be changed to something else

cmd.add({"godmode", "god"}, {"godmode (god)", "Toggles invincibility"}, function()
	local humanoid = getHum()
	if humanoid then
		NAlib.disconnect("godmode")

		NAlib.connect("godmode", humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if humanoid.Health ~= humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end))

		humanoid.Health = humanoid.MaxHealth
		DebugNotif("Godmode ON", 2)
	else
		DebugNotif("Humanoid not found", 2)
	end
end)

cmd.add({"ungodmode", "ungod"}, {"ungodmode (ungod)", "Disables invincibility"}, function()
	NAlib.disconnect("godmode")
	DebugNotif("Godmode OFF", 2)
end)

cmd.add({"controllock", "ctrllock"}, {"controllock (ctrllock)", "Sets your Shiftlock keybinds to the control keys"}, function()
	local player = Players.LocalPlayer
	local mouseLockController = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:WaitForChild("BoundKeys")

	boundKeys.Value = "LeftControl,RightControl"

	DebugNotif("Set your Shiftlock keybinds to Ctrl")
end)

cmd.add({"resetlock"}, {"resetlock", "Resets your Shiftlock keybinds to default (LeftShift)"}, function()
	local player = LocalPlayer
	local mouseLockController = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:WaitForChild("BoundKeys")

	boundKeys.Value = "LeftShift,RightShift"

	DebugNotif("Reset your Shiftlock keybinds to Shift")
end)

cmd.add({"autoreport"}, {"autoreport", "Automatically reports players to get them banned"}, function()
	local ReportKeywords = {
		kid = "Bullying",
		youtube = "Offsite Links",
		date = "Dating",
		hack = "Cheating/Exploiting",
		idiot = "Bullying",
		fat = "Bullying",
		exploit = "Cheating/Exploiting",
		cheat = "Cheating/Exploiting",
		noob = "Bullying",
		clown = "Bullying",
	}

	local function CheckIfReportable(message)
		message = message:lower()
		for keyword, reason in pairs(ReportKeywords) do
			if message:find(keyword) then
				return keyword, reason
			end
		end
		return nil, nil
	end

	local function MonitorPlayerChat(player)
		if player == LocalPlayer then return end

		player.Chatted:Connect(function(message)
			local keyword, reason = CheckIfReportable(message)
			if keyword and reason then
				DebugNotif(Format("Reported %s", nameChecker(player)).." | "..Format("Reason - %s", reason))

				if reportplayer then
					reportplayer(player, reason, Format("Saying %s", keyword))
				else
					SafeGetService("Players"):ReportAbuse(player, reason, Format("Saying %s", keyword))
				end
			end
		end)
	end

	for _, player in ipairs(SafeGetService("Players"):GetPlayers()) do
		MonitorPlayerChat(player)
	end

	SafeGetService("Players").PlayerAdded:Connect(function(player)
		MonitorPlayerChat(player)
	end)
end)


cmd.add({"light"},{"light <range> <brightness> <hexColor>","Gives your player dynamic light"},function(rangeStr,brightnessStr,colorHex)
	local range     = tonumber(rangeStr)   or settingsLight.range
	local brightness= tonumber(brightnessStr)or settingsLight.brightness
	local color     = settingsLight.color
	if colorHex and #colorHex>0 then
		local hex = colorHex:match("^#?(%x+)")
		if hex and (#hex==6 or #hex==3) then
			if #hex==3 then hex = hex:gsub(".", function(c) return c..c end) end
			local r = tonumber(hex:sub(1,2),16)/255
			local g = tonumber(hex:sub(3,4),16)/255
			local b = tonumber(hex:sub(5,6),16)/255
			color = Color3.new(r,g,b)
		end
	end

	local root = getRoot(Player.Character)
	if not root then return end

	local light = settingsLight.LIGHTER
	if not light or not light.Parent then
		light = InstanceNew("PointLight")
		settingsLight.LIGHTER = light
	end

	light.Parent     = root
	light.Range      = range
	light.Brightness = brightness
	light.Color      = color
end, true)

cmd.add({"unlight","nolight"},{"unlight (nolight)","Removes dynamic light from your player"},function()
	if settingsLight.LIGHTER then
		settingsLight.LIGHTER:Destroy()
		settingsLight.LIGHTER = nil
	end
end)

cmd.add({"lighting","lightingcontrol"},{"lighting (lightingcontrol)","Manage lighting technology settings"},function(...)
	local args = {...}
	local target = args[1]
	local buttons = {}
	for _, lt in ipairs(Enum.Technology:GetEnumItems()) do
		Insert(buttons, {
			Text = lt.Name,
			Callback = function()
				Lighting.Technology = lt
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in ipairs(buttons) do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				DebugNotif("Lighting technology set to "..btn.Text, 3)
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching lighting tech for: "..target, 3)
		end
	else
		Window({
			Title = "Lighting Technology Options",
			Buttons = buttons
		})
	end
end)

cmd.add({"friend"}, {"friend", "Sends a friend request to your target"}, function(p)
	local Targets = getPlr(p)

	for Index, Target in next, Targets do
		LocalPlayer:RequestFriendship(Target)
	end
end,true)

cmd.add({"tweengotocampos","tweentocampos","tweentcp"},{"tweengotocampos (tweentcp)","Another version of goto camera position but bypassing more anti-cheats"},function()
	local player=Players.LocalPlayer
	local UserInputService=UserInputService
	local TweenService=TweenService

	function teleportPlayer()
		local character=player.Character or player.CharacterAdded:wait(1)
		local camera=workspace.CurrentCamera
		local cameraPosition=camera.CFrame.Position

		local tween=TweenService:Create(character.PrimaryPart,TweenInfo.new(2),{
			CFrame=CFrame.new(cameraPosition)
		})

		tween:Play()
	end


	local camera=workspace.CurrentCamera
	repeat Wait() until camera.CFrame~=CFrame.new()

	teleportPlayer()

end)

cmd.add({"delete", "remove", "del"}, {"delete {partname} (remove, del)", "Removes any part with a certain name from the workspace"}, function(...)
	local deleteCount = 0
	local args = {...}
	local targetName = Concat(args, " ")

	for _, d in pairs(workspace:GetDescendants()) do
		if d.Name:lower() == targetName:lower() then
			d:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()

	if deleteCount > 0 then
		DebugNotif("Deleted "..deleteCount.." instance(s) of '"..targetName.."'", 2.5)
	else
		DebugNotif("'"..targetName.."' not found to delete", 2.5)
	end
end, true)

cmd.add({"deletefind", "removefind", "delfind"}, {"deletefind {partname} (removefind, delfind)", "Removes any part with a name containing the given text from the workspace"}, function(...)
	local deFind = 0
	local targetName = Concat({...}, " "):lower()

	for _, d in pairs(workspace:GetDescendants()) do
		if d.Name:lower():find(targetName) then
			d:Destroy()
			deFind = deFind + 1
		end
	end

	Wait()

	if deFind > 0 then
		DebugNotif("Deleted "..deFind.." instance(s) containing '"..targetName.."'", 2.5)
	else
		DebugNotif("No instances found containing '"..targetName.."'", 2.5)
	end
end, true)

cmd.add({"deletelighting", "removelighting", "removel", "ldel"},{"deletelighting (removelighting, removel, ldel)","Removes all descendants (objects) within Lighting."},function()
	for _, l in ipairs(Lighting:GetDescendants()) do
		l:Destroy()
	end
end)

cmd.add({"lightingdisable", "disablelighting", "ldisable"},{"lightingdisable (disablelighting, ldisable)", "Disables all post-processing effects in Lighting instead of deleting them."},function()
	for _, inst in ipairs(Lighting:GetDescendants()) do
		if inst:IsA("PostEffect") then
			inst.Enabled = false
		end
	end
end)

autoRemover = {}
autoRemoveConnection = nil

function handleDescendantAdd(part)
	if #autoRemover > 0 then
		if FindInTable(autoRemover, part.Name:lower()) then
			Defer(function()
				if part and part.Parent then
					part:Destroy()
				end
			end)
		end
	else
		if autoRemoveConnection then
			autoRemoveConnection:Disconnect()
			autoRemoveConnection = nil
		end
	end
end

cmd.add({"autodelete", "autoremove", "autodel"}, {"autodelete {partname} (autoremove, autodel)", "Removes any part with a certain name from the workspace on loop"}, function(...)
	local args = {...}
	local targetName = Concat(args, " "):lower()

	if not FindInTable(autoRemover, targetName) then
		Insert(autoRemover, targetName)
		for _, part in pairs(workspace:GetDescendants()) do
			if part.Name:lower() == targetName then
				part:Destroy()
			end
		end
	end

	if not autoRemoveConnection then
		autoRemoveConnection = workspace.DescendantAdded:Connect(handleDescendantAdd)
	end

	Wait()
	DebugNotif("Auto deleting instances with name: "..targetName, 2.5)
end, true)

cmd.add({"unautodelete", "unautoremove", "unautodel"}, {"unautodelete {partname} (unautoremove, unautodel)", "Disables autodelete"}, function()
	if autoRemoveConnection then
		autoRemoveConnection:Disconnect()
		autoRemoveConnection = nil
	end
	autoRemover = {}
end)

autoFinder = {}
finderConn = nil

function onAdd(obj)
	if #autoFinder > 0 then
		for _, kw in pairs(autoFinder) do
			if obj.Name:lower():find(kw) then
				Defer(function()
					if obj and obj.Parent then
						obj:Destroy()
					end
				end)
				break
			end
		end
	else
		if finderConn then
			finderConn:Disconnect()
			finderConn = nil
		end
	end
end

cmd.add({"autodeletefind", "autoremovefind", "autodelfind"}, {"autodeletefind {name} (autoremovefind, autodelfind)", "Auto removes parts with names containing text"}, function(...)
	local args = {...}
	local kw = Concat(args, " "):lower()

	if not FindInTable(autoFinder, kw) then
		Insert(autoFinder, kw)
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj.Name:lower():find(kw) then
				obj:Destroy()
			end
		end
	end

	if not finderConn then
		finderConn = workspace.DescendantAdded:Connect(onAdd)
	end

	Wait()
	DebugNotif("Auto deleting parts containing: "..kw, 2.5)
end, true)

cmd.add({"unautodeletefind", "unautoremovefind", "unautodelfind"}, {"unautodeletefind (unautoremovefind,unautodelfind)", "Stops autodeletefind"}, function()
	if finderConn then
		finderConn:Disconnect()
		finderConn = nil
	end
	autoFinder = {}
end)

cmd.add({"deleteclass", "removeclass", "dc"}, {"deleteclass {ClassName} (removeclass, dc)", "Removes any part with a certain classname from the workspace"}, function(...)
	local args = {...}
	local targetClass = args[1]:lower()
	local deleteCount = 0

	for _, part in pairs(workspace:GetDescendants()) do
		if part.ClassName:lower() == targetClass then
			part:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()
	if deleteCount > 0 then
		DebugNotif("Deleted "..deleteCount.." instance(s) of class: "..targetClass, 2.5)
	else
		DebugNotif("No instances of class: "..targetClass.." found to delete", 2.5)
	end
end, true)

local autoClassRemover = {}
local autoClassConnection = nil

function handleClassDescendantAdd(part)
	if #autoClassRemover > 0 then
		if FindInTable(autoClassRemover, part.ClassName:lower()) then
			Defer(function()
				if part and part.Parent then
					part:Destroy()
				end
			end)
		end
	else
		if autoClassConnection then
			autoClassConnection:Disconnect()
			autoClassConnection = nil
		end
	end
end

cmd.add({"autodeleteclass", "autoremoveclass", "autodc"}, {"autodeleteclass {ClassName} (autoremoveclass, autodc)", "Removes any part with a certain classname from the workspace on loop"}, function(...)
	local args = {...}
	local targetClass = args[1]:lower()

	if not FindInTable(autoClassRemover, targetClass) then
		Insert(autoClassRemover, targetClass)
		for _, part in pairs(workspace:GetDescendants()) do
			if part.ClassName:lower() == targetClass then
				part:Destroy()
			end
		end
	end

	if not autoClassConnection then
		autoClassConnection = workspace.DescendantAdded:Connect(handleClassDescendantAdd)
	end

	Wait()
	DebugNotif("Auto deleting instances with class: "..targetClass, 2.5)
end, true)

cmd.add({"unautodeleteclass", "unautoremoveclass", "unautodc"}, {"unautodeleteclass {ClassName} (unautoremoveclass, unautodc)", "Disables autodeleteclass"}, function()
	if autoClassConnection then
		autoClassConnection:Disconnect()
		autoClassConnection = nil
	end
	autoClassRemover = {}
end)

cmd.add({"chardelete", "charremove", "chardel", "cdelete", "cremove", "cdel"}, {"chardelete {partname} (charremove, chardel, cdelete, cremove, cdel)", "Removes any part with a certain name from your character"}, function(...)
	local args = {...}
	local targetName = Concat(args, " "):lower()
	local deleteCount = 0

	for _, part in pairs(Player.Character:GetDescendants()) do
		if part.Name:lower() == targetName then
			part:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()
	if deleteCount > 0 then
		DebugNotif("Deleted "..deleteCount.." instance(s) of '"..targetName.."' inside the character", 2.5)
	else
		DebugNotif("'"..targetName.."' not found in the character", 2.5)
	end
end, true)

cmd.add({"chardeletefind", "charremovefind", "chardelfind", "cdeletefind", "cremovefind", "cdelfind"}, {"chardeletefind {name} (charremovefind, chardelfind, cdeletefind, cremovefind, cdelfind)", "Removes parts in your character with names containing text"}, function(...)
	local args = {...}
	local kw = Concat(args, " "):lower()
	local count = 0

	for _, obj in pairs(Player.Character:GetDescendants()) do
		if obj.Name:lower():find(kw) then
			obj:Destroy()
			count = count + 1
		end
	end

	Wait()
	if count > 0 then
		DebugNotif("Deleted "..count.." instance(s) containing '"..kw.."' in character", 2.5)
	else
		DebugNotif("Nothing found containing '"..kw.."' in character", 2.5)
	end
end, true)

cmd.add({"chardeleteclass", "charremoveclass", "chardeleteclassname", "cdc"}, {"chardeleteclass {ClassName} (charremoveclass, chardeleteclassname, cdc)", "Removes any part with a certain classname from your character"}, function(...)
	local args = {...}
	local targetClass = args[1]:lower()
	local deleteCount = 0

	for _, part in pairs(Player.Character:GetDescendants()) do
		if part.ClassName:lower() == targetClass then
			part:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()
	if deleteCount > 0 then
		DebugNotif("Deleted "..deleteCount.." instance(s) of class: "..targetClass.." inside the character", 2.5)
	else
		DebugNotif("No instances of class: "..targetClass.." found in the character", 2.5)
	end
end, true)

local activeTeleports = {}

cmd.add({"gotopart", "topart", "toprt"}, {"gotopart {partname}", "Teleports you to each matching part by name once"}, function(...)
	local partName = Concat({...}, " "):lower()
	local commandKey = "gotopart"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, part in pairs(workspace:GetDescendants()) do
			if not taskState.active then return end
			if part:IsA("BasePart") and part.Name:lower() == partName then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then getChar():PivotTo(part:GetPivot()) end
				Wait(.2)
			end
		end
	end)
end, true)

cmd.add({"tweengotopart","tgotopart","ttopart","ttoprt"},{"tweengotopart <partName>","Tween to each matching part by name once"},function(...)
	local partName = Concat({...}," "):lower()
	local key      = "tweengotopart"
	if activeTeleports[key] then activeTeleports[key].active = false end
	local state    = {active = true}
	activeTeleports[key] = state
	Spawn(function()
		local char = getChar()
		for _,obj in ipairs(workspace:GetDescendants()) do
			if not state.active then return end
			if obj:IsA("BasePart") and obj.Name:lower() == partName then
				local hum = getHum()
				if hum then hum.Sit = false end
				local cfVal = InstanceNew("CFrameValue")
				cfVal.Value = char:GetPivot()
				cfVal.Changed:Connect(function(newCF) char:PivotTo(newCF) end)
				local tw = TweenService:Create(cfVal, TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Value = obj.CFrame})
				tw:Play()
				tw.Completed:Connect(function() cfVal:Destroy() end)
				Wait(0.1)
			end
		end
	end)
end,true)


cmd.add({"gotopartfind", "topartfind", "toprtfind"}, {"gotopartfind {name}", "Teleports to each part containing name once"}, function(...)
	local name = Concat({...}, " "):lower()
	local commandKey = "gotopartfind"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, part in pairs(workspace:GetDescendants()) do
			if not taskState.active then return end
			if part:IsA("BasePart") and part.Name:lower():find(name) then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then getChar():PivotTo(part:GetPivot()) end
				Wait(.2)
			end
		end
	end)
end, true)

cmd.add({"tweengotopartfind", "tgotopartfind", "ttopartfind", "ttoprtfind"}, {"tweengotopartfind {name}", "Tweens to each part containing name once"}, function(...)
	local name = Concat({...}, " "):lower()
	local commandKey = "tweengotopartfind"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, part in pairs(workspace:GetDescendants()) do
			if not taskState.active then return end
			if part:IsA("BasePart") and part.Name:lower():find(name) then
				if getHum() then getHum().Sit = false Wait(0.1) end
				local tween = TweenService:Create(getRoot(getChar()), TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = part.CFrame})
				tween:Play()
				Wait(1.1)
			end
		end
	end)
end, true)

cmd.add({"gotopartclass", "gpc", "gotopartc", "gotoprtc"}, {"gotopartclass {classname}", "Teleports to each part of class once"}, function(...)
	local className = ({...})[1]:lower()
	local commandKey = "gotopartclass"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, part in pairs(workspace:GetDescendants()) do
			if not taskState.active then return end
			if part:IsA("BasePart") and part.ClassName:lower() == className then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then getChar():PivotTo(part:GetPivot()) end
				Wait(.2)
			end
		end
	end)
end, true)

cmd.add({"bringpart", "bpart", "bprt"}, {"bringpart {partname} (bpart, bprt)", "Brings a part to your character by name"}, function(...)
	local partName = Concat({...}, " "):lower()

	for _, part in pairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and part.Name:lower() == partName then
			if getChar() then
				part:PivotTo(getChar():GetPivot())
			end
		end
	end
end, true)

cmd.add({"bringmodel", "bmodel"}, {"bringmodel {modelname} (bmodel)", "Brings a model to your character by name"}, function(...)
	local modelName = Concat({...}, " "):lower()

	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name:lower() == modelName then
			if getChar() then
				model:PivotTo(getChar():GetPivot())
			end
		end
	end
end, true)

cmd.add({"gotomodel", "tomodel"}, {"gotomodel {modelname}", "Teleports to each model with name once"}, function(...)
	local modelName = Concat({...}, " "):lower()
	local commandKey = "gotomodel"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, model in pairs(workspace:GetDescendants()) do
			if not taskState.active then return end
			if model:IsA("Model") and model.Name:lower() == modelName then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then getChar():PivotTo(model:GetPivot()) end
				Wait(.2)
			end
		end
	end)
end, true)

cmd.add({"gotomodelfind", "tomodelfind"}, {"gotomodelfind {name}", "Teleports to each model containing name once"}, function(...)
	local name = Concat({...}, " "):lower()
	local commandKey = "gotomodelfind"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, model in pairs(workspace:GetDescendants()) do
			if not taskState.active then return end
			if model:IsA("Model") and model.Name:lower():find(name) then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then getChar():PivotTo(model:GetPivot()) end
				Wait(.2)
			end
		end
	end)
end, true)

cmd.add({"gotomodelfind", "tomodelfind"}, {"gotomodelfind {name} (tomodelfind)", "Teleports you to a model whose name contains the given text"}, function(...)
	local name = Concat({...}, " "):lower()

	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Model") and model.Name:lower():find(name) then
			if getHum() then
				getHum().Sit = false
				Wait(0.1)
			end
			if getChar() then
				getChar():PivotTo(model:GetPivot())
			end
			Wait(0.2)
		end
	end
end, true)

OGGRAVV = workspace.Gravity
SWIMMERRRR = false

function ZEhumSTATE(humanoid, enabled)
	local states = Enum.HumanoidStateType:GetEnumItems()
	table.remove(states, Discover(states, Enum.HumanoidStateType.None))
	for _, state in ipairs(states) do
		humanoid:SetStateEnabled(state, enabled)
	end
end

cmd.add({"swim"}, {"swim {speed}", "Swim in the air"}, function(speed)
	local player = Players.LocalPlayer
	local humanoid = getHum()

	if not SWIMMERRRR and humanoid and humanoid.Parent then
		local hrp = getRoot(humanoid.Parent)
		if not hrp then return end

		OGGRAVV = workspace.Gravity
		workspace.Gravity = 0

		ZEhumSTATE(humanoid, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		humanoid.WalkSpeed = speed or 16

		NAlib.connect("swim_die", humanoid.Died:Connect(function()
			workspace.Gravity = OGGRAVV
			SWIMMERRRR = false
		end))

		NAlib.connect("swim_heartbeat", RunService.Stepped:Connect(function()
			NACaller(function()
				if humanoid and hrp then
					local move = humanoid.MoveDirection
					local velocity = (move.Magnitude > 0 or UserInputService:IsKeyDown(Enum.KeyCode.Space)) and hrp.Velocity or Vector3.zero
					hrp.Velocity = velocity
				end
			end)
		end))

		SWIMMERRRR = true
	end
end, true)

cmd.add({"unswim"}, {"unswim", "Stops the swim script"}, function()
	local player = Players.LocalPlayer
	local humanoid = getHum()

	if humanoid then
		workspace.Gravity = OGGRAVV
		SWIMMERRRR = false

		NAlib.disconnect("swim_die")
		NAlib.disconnect("swim_heartbeat")

		ZEhumSTATE(humanoid, true)
		humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		humanoid.WalkSpeed = 16
	end
end)

cmd.add({"punch"},{"punch","punch tool that flings"},function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/puncher.luau'))()
end)

cmd.add({"tpua","bringua"},{"tpua <player>","Brings every unanchored part on the map to the player"},function(...)
	local targets=getPlr(...)
	local targetPlayer=targets[1]
	if not targetPlayer then targetPlayer=LocalPlayer end

	local root=getRoot(getPlrChar(targetPlayer))
	if not root then return end

	local targetCF=root.CFrame

	Spawn(function()
		while RunService.Heartbeat:Wait() do
			NACaller(function()
				opt.hiddenprop(LocalPlayer,"SimulationRadius",1e9)
				LocalPlayer.MaximumSimulationRadius=1e9
			end)
		end
	end)

	local function ForcePart(v)
		if not v:IsA("BasePart") then return end
		if v.Anchored or v:IsDescendantOf(targetPlayer.Character) then return end
		if v.Parent:FindFirstChildWhichIsA("Humanoid") or v.Parent:FindFirstChild("Head") or v.Name=="Handle" then return end

		for _,x in next,v:GetChildren() do
			if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
		end
		for _,n in next,{"Attachment","AlignPosition","Torque"} do
			local i=v:FindFirstChild(n)
			if i then i:Destroy() end
		end

		v.CanCollide=false
		v.CFrame=targetCF*CFrame.new(math.random(-10,10),0,math.random(-10,10))
	end

	for _,part in ipairs(workspace:GetDescendants()) do
		ForcePart(part)
	end
end,true)

cmd.add({"blackholefollow","bhf","bhpull","bhfollow"},{"blackholefollow","Pulls unanchored parts to you with spin"},function()
	if NAlib.isConnected("bhf") then return DoNotif("BHF already active") end

	local root=getRoot(getPlrChar(LocalPlayer));if not root then return end
	local att1=InstanceNew("Attachment",root);att1.Name="BHF_Attach"

	local function ForcePart(v)
		if not v:IsA("BasePart") then return end
		if v.Anchored or v:IsDescendantOf(LocalPlayer.Character) then return end
		if v.Parent:FindFirstChildWhichIsA("Humanoid") or v.Parent:FindFirstChild("Head") or v.Name=="Handle" then return end

		for _,x in next,v:GetChildren() do
			if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
		end
		for _,n in next,{"Attachment","AlignPosition","Torque"} do
			local i=v:FindFirstChild(n)
			if i then i:Destroy() end
		end

		v.CanCollide=false

		local att0=InstanceNew("Attachment",v)
		local align=InstanceNew("AlignPosition",v)
		align.Attachment0=att0
		align.Attachment1=att1
		align.MaxForce=1e9
		align.MaxVelocity=math.huge
		align.Responsiveness=200

		local torque=InstanceNew("Torque",v)
		torque.Attachment0=att0
		torque.Torque=Vector3.new(100000,100000,100000)
	end

	for _,part in ipairs(workspace:GetDescendants()) do Defer(function() ForcePart(part) end) end

	NAlib.connect("bhf",workspace.DescendantAdded:Connect(ForcePart))
	NAlib.connect("bhf_sim",RunService.Heartbeat:Connect(function()
		NACaller(function()
			opt.hiddenprop(LocalPlayer,"SimulationRadius",1e9)
			LocalPlayer.MaximumSimulationRadius=1e9
		end)
	end))

	DebugNotif("Blackhole follow enabled.")
end,true)

cmd.add({"noblackholefollow","nobhf","nobhpull","stopbhf"},{"noblackholefollow","Stops blackhole follow and clears constraints"},function()
	NAlib.disconnect("bhf")
	NAlib.disconnect("bhf_sim")

	local root=getRoot(getPlrChar(LocalPlayer))
	if root then local att=root:FindFirstChild("BHF_Attach") if att then att:Destroy() end end

	for _,part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored then
			for _,obj in ipairs(part:GetChildren()) do
				if obj:IsA("AlignPosition") or obj:IsA("Torque") or obj:IsA("Attachment") then obj:Destroy() end
			end
		end
	end

	DebugNotif("Blackhole follow disabled.")
end,true)

cmd.add({"swordfighter", "sfighter", "swordf", "swordbot", "sf"},{"swordfighter (sfighter, swordf, swordbot, sf)", "Activates a sword fighting bot that engages in automated PvP combat"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Sword%20Fight%20Bot"))()
end)

local touchESPList, proximityESPList, clickESPList, siteESPList, vehicleSiteESPList = {}, {}, {}, {}, {}
local espTriggers = {}
local espNameLists = {exact={},partial={}}
local espNameTriggers = {}
local nameESPPartLists = {exact={},partial={}}

local function createBox(part,color,transparency)
	local c = color or Color3.new(1,1,1)
	local h,s,v = Color3.toHSV(c)
	local off = 0.35
	local dC = Color3.fromHSV(h,s,math.clamp(v-off,0,1))
	local lC = Color3.fromHSV(h,s,math.clamp(v+off,0,1))
	local b = InstanceNew("BoxHandleAdornment",part)
	b.Name = Lower(part.Name).."_peepee"
	b.Adornee = part
	b.AlwaysOnTop = true
	b.ZIndex = 0
	b.Transparency = transparency or 0.45
	b.Color3 = lC
	local bb = InstanceNew("BillboardGui",part)
	bb.Name = Lower(part.Name).."_label"
	bb.Adornee = part
	bb.Size = UDim2.new(0,100,0,30)
	bb.StudsOffset = Vector3.new(0,0.5,0)
	bb.AlwaysOnTop = true
	bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local tl = InstanceNew("TextLabel",bb)
	tl.Size = UDim2.new(1,0,1,0)
	tl.BackgroundTransparency = 1
	tl.Text = part.Name
	tl.TextColor3 = Color3.new(1,1,1)
	tl.Font = Enum.Font.SourceSansBold
	tl.TextSize = 14
	tl.TextStrokeTransparency = 0.5
	tl.ZIndex = 1
	local gr = InstanceNew("UIGradient",tl)
	gr.Color = ColorSequence.new(dC,lC)
	local function update()
		if not b.Parent then return end
		if part:IsA("Model") then
			local _,ms = part:GetBoundingBox()
			b.Size = ms + Vector3.new(0.1,0.1,0.1)
		else
			b.Size = part.Size + Vector3.new(0.1,0.1,0.1)
		end
		bb.StudsOffset = Vector3.new(0,b.Size.Y/2+0.2,0)
	end
	update()
	Defer(update)
	local key = "esp_update_"..tostring(b)
	if part:IsA("Model") then
		NAlib.connect(key, part.DescendantAdded:Connect(update))
		NAlib.connect(key, part.DescendantRemoving:Connect(update))
	elseif NAlib.isProperty(part,"Size") then
		NAlib.connect(key, part:GetPropertyChangedSignal("Size"):Connect(update))
	end
	b:GetPropertyChangedSignal("Parent"):Connect(function()
		if not b.Parent then
			NAlib.disconnect(key)
		end
	end)
	return b
end

local function removeEspFromPart(part)
	for _,child in ipairs(part:GetChildren()) do
		if child:IsA("BoxHandleAdornment") and Sub(child.Name,-7) == "_peepee" then
			NAlib.disconnect("esp_update_"..tostring(child))
			child:Destroy()
		end
	end
	for _,child in ipairs(part:GetChildren()) do
		if child:IsA("BillboardGui") and Sub(Lower(child.Name),-6) == "_label" then
			child:Destroy()
		end
	end
end

local function enableEsp(objType,color,list)
	for _,obj in pairs(workspace:GetDescendants()) do
		if obj:IsA(objType) then
			local parent = obj:FindFirstAncestorWhichIsA("BasePart") or obj:FindFirstAncestorWhichIsA("Model")
			if parent and not Discover(list,parent) then
				Insert(list,parent)
				createBox(parent,color,0.45)
			end
		end
	end
	if not espTriggers[objType] then
		espTriggers[objType] = workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA(objType) then
				local parent = obj:FindFirstAncestorWhichIsA("BasePart") or obj:FindFirstAncestorWhichIsA("Model")
				if parent and not Discover(list,parent) then
					Insert(list,parent)
					createBox(parent,color,0.45)
				end
			end
		end)
	end
end

local function disableEsp(objType,list)
	if espTriggers[objType] then
		espTriggers[objType]:Disconnect()
		espTriggers[objType] = nil
	end
	for _,part in ipairs(list) do
		removeEspFromPart(part)
	end
	table.clear(list)
end

local function enableNameEsp(mode,color,...)
	local terms = {...}
	local list = espNameLists[mode]
	local parts = nameESPPartLists[mode]
	for _,term in ipairs(terms) do
		term = Lower(term)
		if not Discover(list,term) then
			Insert(list,term)
		end
	end
	local function matchFn(obj)
		if not (obj:IsA("BasePart") or obj:IsA("Model")) then return false end
		local nm = Lower(obj.Name)
		for _,term in ipairs(list) do
			if (mode=="exact" and nm==term) or (mode=="partial" and Find(nm,term)) then
				return true
			end
		end
		return false
	end
	local function handleNameChange(obj)
		local matches = matchFn(obj)
		local idx = Discover(parts,obj)
		if matches and not idx then
			Insert(parts,obj)
			createBox(obj,color,0.45)
		elseif not matches and idx then
			removeEspFromPart(obj)
			table.remove(parts,idx)
		end
	end
	for _,obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("Model") then
			NAlib.connect("esp_namechange_"..mode, obj:GetPropertyChangedSignal("Name"):Connect(function()
				handleNameChange(obj)
			end))
			handleNameChange(obj)
		end
	end
	if not espNameTriggers[mode] then
		espNameTriggers[mode] = workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA("BasePart") or obj:IsA("Model") then
				NAlib.connect("esp_namechange_"..mode, obj:GetPropertyChangedSignal("Name"):Connect(function()
					handleNameChange(obj)
				end))
				handleNameChange(obj)
			end
		end)
	end
end

local function disableNameEsp(mode)
	if espNameTriggers[mode] then
		espNameTriggers[mode]:Disconnect()
		espNameTriggers[mode] = nil
	end
	NAlib.disconnect("esp_namechange_"..mode)
	local parts = nameESPPartLists[mode]
	for _,part in ipairs(parts) do
		removeEspFromPart(part)
	end
	table.clear(parts)
	table.clear(espNameLists[mode])
end

cmd.add({"touchesp","tesp"},{"touchesp"},function()
	enableEsp("TouchTransmitter",Color3.fromRGB(255,0,0),touchESPList)
end)

cmd.add({"untouchesp","untesp"},{"untouchesp"},function()
	disableEsp("TouchTransmitter",touchESPList)
end)

cmd.add({"proximityesp","prxesp","proxiesp"},{"proximityesp"},function()
	enableEsp("ProximityPrompt",Color3.fromRGB(0,0,255),proximityESPList)
end)

cmd.add({"unproximityesp","unprxesp","unproxiesp"},{"unproximityesp"},function()
	disableEsp("ProximityPrompt",proximityESPList)
end)

cmd.add({"clickesp","cesp"},{"clickesp"},function()
	enableEsp("ClickDetector",Color3.fromRGB(255,165,0),clickESPList)
end)

cmd.add({"unclickesp","uncesp"},{"unclickesp"},function()
	disableEsp("ClickDetector",clickESPList)
end)

cmd.add({"sitesp","ssp"},{"sitesp"},function()
	enableEsp("Seat", Color3.fromRGB(0,255,0), siteESPList)
end)

cmd.add({"unsitesp","unssp"},{"unsitesp"},function()
	disableEsp("Seat", siteESPList)
end)

cmd.add({"vehiclesitesp","vsitesp","vsp"},{"vehiclesitesp"},function()
	enableEsp("VehicleSeat", Color3.fromRGB(255,0,255), vehicleSiteESPList)
end)

cmd.add({"unvehiclesitesp","unvsitesp","unvsp"},{"unvehiclesitesp"},function()
	disableEsp("VehicleSeat", vehicleSiteESPList)
end)

cmd.add({"pesp","esppart","partesp"},{"pesp {partname}"},function(...)
	local name = Concat({...}," ")
	if name=="" then
		disableNameEsp("exact")
	else
		enableNameEsp("exact",nil,name)
	end
end,true)

cmd.add({"unpesp","unesppart","unpartesp"},{"unpesp"},function()
	disableNameEsp("exact")
end)

cmd.add({"pespfind","partespfind","esppartfind"},{"pespfind {partname}"},function(...)
	local name = Concat({...}," ")
	if name=="" then
		disableNameEsp("partial")
	else
		enableNameEsp("partial",nil,name)
	end
end,true)

cmd.add({"unpespfind","unpartespfind","unesppartfind"},{"unpespfind"},function()
	disableNameEsp("partial")
end)

cmd.add({"viewpart", "viewp", "vpart"}, {"viewpart {partName} (viewp, vpart)", "Focuses camera on a part, model, or folder"},function(...)
	local partName = Concat({...}, " "):lower()
	local ws = workspace
	local camera = ws.CurrentCamera

	for _, obj in ipairs(ws:GetDescendants()) do
		if obj.Name:lower() == partName then
			if obj:IsA("BasePart") then
				camera.CameraSubject = obj
				return
			elseif obj:IsA("Model") or obj:IsA("Folder") then
				for _, child in ipairs(obj:GetDescendants()) do
					if child:IsA("BasePart") then
						camera.CameraSubject = child
						return
					end
				end
			end
		end
	end

	DebugNotif("No matching part, model, or folder with a BasePart found named '"..partName.."'")
end,true)

cmd.add({"unviewpart", "unviewp"}, {"unviewpart (unviewp)", "Resets the camera to the local humanoid"}, function()
	local camera = workspace.CurrentCamera
	local humanoid = getHum()
	if humanoid then
		camera.CameraSubject = humanoid
	end
end)

cmd.add({"viewpartfind", "viewpfind", "vpartfind"}, {"viewpartfind {name} (viewpfind, vpartfind)", "Focuses camera on a part, model, or folder with name containing the given text"}, function(...)
	local name = Concat({...}, " "):lower()
	local ws = workspace
	local cam = ws.CurrentCamera

	for _, obj in ipairs(ws:GetDescendants()) do
		if obj.Name:lower():find(name) then
			if obj:IsA("BasePart") then
				cam.CameraSubject = obj
				return
			elseif obj:IsA("Model") or obj:IsA("Folder") then
				for _, child in ipairs(obj:GetDescendants()) do
					if child:IsA("BasePart") then
						cam.CameraSubject = child
						return
					end
				end
			end
		end
	end

	DebugNotif("No part, model, or folder containing '"..name.."' with a BasePart found")
end, true)

cmd.add({"unviewpart", "unviewp"}, {"unviewpart (unviewp)", "Resets the camera to the local humanoid"}, function()
	local cam = workspace.CurrentCamera
	local hum = getHum()
	if hum then
		cam.CameraSubject = hum
	end
end)

cmd.add({"console", "debug"}, {"console (debug)", "Opens developer console"}, function()
	local consoleButtons = {
		{
			Text = "Roblox Console",
			Callback = function()
				SafeGetService("StarterGui"):SetCore("DevConsoleVisible", true)
			end
		},
		{
			Text = "Custom Console",
			Callback = function()
				NAgui.consoleeee()
			end
		}
	}

	Window({
		Title = "Select Console",
		Buttons = consoleButtons
	})
end)

local ogParts,resizeLoops={},{}
local hbAddConn,hbRemConn=nil,nil

cmd.add({"hitbox","hbox"},{"hitbox <player> {size}",""},function(pArg,sArg)
	local Players=SafeGetService("Players")
	local RunService=SafeGetService("RunService")
	local targets=getPlr(pArg) if #targets==0 then DoNotif("No players found",2) return end
	local n=tonumber(sArg) or 10
	local global=(Lower(pArg)=="all" or Lower(pArg)=="others")
	local partSet={All=true}
	for _,plr in ipairs(targets)do
		local char=getPlrChar(plr)
		if char then
			for _,p in ipairs(char:GetChildren())do
				if p:IsA("BasePart") then partSet[p.Name]=true end
			end
		end
	end
	local btns={}
	for limb,_ in pairs(partSet)do
		Insert(btns,{
			Text=limb,
			Callback=function()
				if hbAddConn then hbAddConn:Disconnect() hbAddConn=nil end
				if hbRemConn then hbRemConn:Disconnect() hbRemConn=nil end
				local newSize=Vector3.new(n,n,n)
				local function cache(b,plr)
					ogParts[plr][b]={Size=b.Size,Transparency=b.Transparency,BrickColor=b.BrickColor,Material=b.Material,CanCollide=b.CanCollide}
				end
				local function apply(plr)
					ogParts[plr]=ogParts[plr] or {}
					if resizeLoops[plr] then resizeLoops[plr]:Disconnect() end
					resizeLoops[plr]=RunService.Stepped:Connect(function()
						local char=getPlrChar(plr) if not char then return end
						for _,bp in ipairs(char:GetChildren())do
							if bp:IsA("BasePart") and (limb=="All" or bp.Name:lower()==limb:lower()) then
								if not ogParts[plr][bp] then cache(bp,plr) end
								bp.Size=newSize
								bp.Transparency=0.9
								bp.BrickColor=BrickColor.new("Really black")
								bp.Material=Enum.Material.Neon
								bp.CanCollide=false
								bp.Massless=true
							end
						end
					end)
				end
				for _,plr in ipairs(targets)do apply(plr) end
				if global then
					hbAddConn=Players.PlayerAdded:Connect(apply)
					hbRemConn=Players.PlayerRemoving:Connect(function(plr)
						if resizeLoops[plr] then resizeLoops[plr]:Disconnect() resizeLoops[plr]=nil end
						ogParts[plr]=nil
					end)
				end
			end
		})
	end
	Window({Title="Hitbox Menu",Description="Choose limb to resize",Buttons=btns})
end,true)

cmd.add({"unhitbox","unhbox"},{"unhitbox <player>",""},function(pArg)
	local Players=SafeGetService("Players")
	local targets=getPlr(pArg)
	for _,plr in ipairs(targets)do
		local char=getPlrChar(plr)
		if char and ogParts[plr] then
			for bp,props in pairs(ogParts[plr])do
				local ref=char:FindFirstChild(bp.Name) or bp
				if ref then
					ref.Size=props.Size
					ref.Transparency=props.Transparency
					ref.BrickColor=props.BrickColor
					ref.Material=props.Material
					ref.CanCollide=props.CanCollide
				end
			end
		end
		if resizeLoops[plr] then resizeLoops[plr]:Disconnect() resizeLoops[plr]=nil end
		ogParts[plr]=nil
	end
	if hbAddConn then hbAddConn:Disconnect() hbAddConn=nil end
	if hbRemConn then hbRemConn:Disconnect() hbRemConn=nil end
end,true)

local PST = {
	orig   = {},
	exact  = {},
	partial= {},
	sizeE  = {},
	sizeP  = {},
}

NAmanage.cachePart = function(p)
	PST.orig[p] = {
		Size         = p.Size,
		Transparency = p.Transparency,
		CanCollide   = p.CanCollide,
	}
end

NAmanage.resizePart = function(p, sizeVec, store)
	if not PST.orig[p] then NAmanage.cachePart(p) end
	p.Size         = sizeVec
	p.Transparency = 0.5
	p.CanCollide   = false
	Insert(store, p)
end

cmd.add({"partsize","psize","sizepart"},{"partsize {name} {size}", "Grow a part or model named exactly <name> to the cube size you choose."},function(nameArg, sizeArg)
	local term, n = Lower(nameArg), tonumber(sizeArg)
	if not n then DoNotif("Invalid size",2) return end
	local sizeVec = Vector3.new(n,n,n)
	PST.sizeE[term] = sizeVec

	local parts, elser = {}, {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		local nm = Lower(obj.Name)
		if obj:IsA("BasePart") and nm == term then
			Insert(parts, obj)
		elseif nm == term then
			Insert(elser, obj)
		end
	end

	for _, p in ipairs(parts) do
		NAmanage.resizePart(p, sizeVec, PST.exact)
	end
	for _, m in ipairs(elser) do
		for _, d in ipairs(m:GetDescendants()) do
			if d:IsA("BasePart") then
				NAmanage.resizePart(d, sizeVec, PST.exact)
			end
		end
	end

	if not NAlib.isConnected("partsizeExact") then
		NAlib.connect("partsizeExact", workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA("BasePart") then
				local nm = Lower(obj.Name)
				local sz = PST.sizeE[nm]
				if sz then
					NAmanage.resizePart(obj, sz, PST.exact)
					return
				end
			else
				local sz = PST.sizeE[Lower(obj.Name)]
				if sz then
					for _, d in ipairs(obj:GetDescendants()) do
						if d:IsA("BasePart") then
							NAmanage.resizePart(d, sz, PST.exact)
						end
					end
				end
			end
		end))
	end
end, true)

cmd.add({"partsizefind","psizefind","sizefind","partsizef"},{"partsizefind {term} {size}", "Grow every part or model whose name contains <term> to the cube size you choose."},function(termArg, sizeArg)
	local term, n = Lower(termArg), tonumber(sizeArg)
	if not n then DoNotif("Invalid size",2) return end
	local sizeVec = Vector3.new(n,n,n)
	PST.sizeP[term] = sizeVec

	local parts, elser = {}, {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		local nm = Lower(obj.Name)
		if obj:IsA("BasePart") and nm:find(term) then
			Insert(parts, obj)
		elseif nm:find(term) then
			Insert(elser, obj)
		end
	end

	for _, p in ipairs(parts) do
		NAmanage.resizePart(p, sizeVec, PST.partial)
	end
	for _, m in ipairs(elser) do
		for _, d in ipairs(m:GetDescendants()) do
			if d:IsA("BasePart") then
				NAmanage.resizePart(d, sizeVec, PST.partial)
			end
		end
	end

	if not NAlib.isConnected("partsizeFind") then
		NAlib.connect("partsizeFind", workspace.DescendantAdded:Connect(function(obj)
			if obj:IsA("BasePart") then
				local nm = Lower(obj.Name)
				for t, sz in pairs(PST.sizeP) do
					if nm:find(t) then
						NAmanage.resizePart(obj, sz, PST.partial)
						return
					end
				end
			else
				for t, sz in pairs(PST.sizeP) do
					if Lower(obj.Name):find(t) then
						for _, d in ipairs(obj:GetDescendants()) do
							if d:IsA("BasePart") then
								NAmanage.resizePart(d, sz, PST.partial)
							end
						end
						return
					end
				end
			end
		end))
	end
end, true)

cmd.add({"unpartsize","unsizepart","unpsize"},{"unpartsize", "Undo partsize—return those parts back to their original size and collision."},function()
	for _, p in ipairs(PST.exact) do
		local pr = PST.orig[p]
		if pr then
			p.Size         = pr.Size
			p.Transparency = pr.Transparency
			p.CanCollide   = pr.CanCollide
			PST.orig[p] = nil
		end
	end
	table.clear(PST.exact)
	table.clear(PST.sizeE)
	NAlib.disconnect("partsizeExact")
end, true)

cmd.add({"unpartsizefind","unsizefind","unpsizefind"},{"unpartsizefind", "Undo partsizefind—return those resized parts back to their original size and collision."},function()
	for _, p in ipairs(PST.partial) do
		local pr = PST.orig[p]
		if pr then
			p.Size         = pr.Size
			p.Transparency = pr.Transparency
			p.CanCollide   = pr.CanCollide
			PST.orig[p] = nil
		end
	end
	table.clear(PST.partial)
	table.clear(PST.sizeP)
	NAlib.disconnect("partsizeFind")
end, true)

cmd.add({"breakcars", "bcars"}, {"breakcars (bcars)", "Breaks any car"}, function()
	DebugNotif("Car breaker loaded, sit on a vehicle and be the driver")

	local Player = Players.LocalPlayer
	local Mouse = Player:GetMouse()
	local RunService = RunService
	local UserInputService = UserInputService

	local Folder = InstanceNew("Folder")
	Folder.Parent = workspace

	local Part = InstanceNew("Part")
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	Part.Size = Vector3.new(1, 1, 1)
	Part.Parent = Folder

	local Attachment1 = InstanceNew("Attachment")
	Attachment1.Parent = Part

	local UpdatedPosition = Mouse.Hit + Vector3.new(0, 5, 0)

	Spawn(function()
		while Wait() do
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= Player then
					player.MaximumSimulationRadius = 0
					opt.hiddenprop(player, "SimulationRadius", 0)
				end
			end
			Player.MaximumSimulationRadius = math.pow(math.huge, math.huge)
			setsimulationradius(math.huge)
		end
	end)

	local function applyForceToPart(part)
		if not part:IsA("BasePart") or part.Anchored then return end
		if part.Name == "Handle" then return end
		local parent = part.Parent
		if getPlrHum(parent) or getHead(parent) then return end

		Mouse.TargetFilter = part

		for _, v in ipairs(part:GetChildren()) do
			if v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") or v:IsA("BodyGyro")
				or v:IsA("BodyPosition") or v:IsA("BodyThrust") or v:IsA("BodyVelocity")
				or v:IsA("RocketPropulsion") or v:IsA("Torque") or v:IsA("AlignPosition")
				or v:IsA("Attachment") then
				v:Destroy()
			end
		end

		part.CanCollide = false

		local torque = InstanceNew("Torque")
		torque.Torque = Vector3.new(100000, 100000, 100000)
		torque.Parent = part

		local alignPosition = InstanceNew("AlignPosition")
		alignPosition.MaxForce = math.huge
		alignPosition.MaxVelocity = math.huge
		alignPosition.Responsiveness = 200
		alignPosition.Parent = part

		local attachment2 = InstanceNew("Attachment")
		attachment2.Parent = part

		torque.Attachment0 = attachment2
		alignPosition.Attachment0 = attachment2
		alignPosition.Attachment1 = Attachment1
	end

	for _, descendant in ipairs(workspace:GetDescendants()) do
		applyForceToPart(descendant)
	end

	workspace.DescendantAdded:Connect(applyForceToPart)

	UserInputService.InputBegan:Connect(function(input, isChatting)
		if input.KeyCode == Enum.KeyCode.E and not isChatting then
			UpdatedPosition = Mouse.Hit + Vector3.new(0, 5, 0)
		end
	end)

	Spawn(function()
		while Wait() do
			Attachment1.WorldCFrame = UpdatedPosition
		end
	end)
end)

cmd.add({"setsimradius", "ssr", "simrad"},{"setsimradius <number>","Set sim radius using available methods. Usage: setsimradius <radius>"},function(...)
	local r = tonumber(...)
	if not r then
		return DoNotif("Invalid input. Usage: setsimradius <number>")
	end

	local ok = false

	if setsimulationradius then
		NACaller(function()
			setsimulationradius(r)
			ok = true
			DebugNotif("SimRadius set with setsimulationradius: "..r)
		end)
	end

	if not ok and opt.hiddenprop then
		if NACaller(function()
				opt.hiddenprop(LocalPlayer, "SimulationRadius", r)
			end) then
			ok = true
			DebugNotif("SimRadius set with sethiddenproperty: "..r)
		end
	end

	if not ok then
		if NACaller(function()
				LocalPlayer.SimulationRadius = r
			end) then
			ok = true
			DebugNotif("SimRadius set directly: "..r)
		end
	end

	if not ok then
		DebugNotif("No supported method to set sim radius.")
	end
end,true)

cmd.add({"infjump", "infinitejump"}, {"infjump (infinitejump)", "Enables infinite jumping"}, function()
	Wait()
	DebugNotif("Infinite Jump Enabled", 2)

	local function doINFJUMPY()
		NAlib.disconnect("infjump_jump")

		local debounce = false
		local humanoid = nil

		while not humanoid do Wait(.1) humanoid = getHum() end

		NAlib.connect("infjump_jump", UserInputService.JumpRequest:Connect(function()
			if not debounce and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				debounce = true
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

				Delay(0.25, function()
					debounce = false
				end)
			end
		end))
	end

	NAlib.disconnect("infjump_char")
	NAlib.connect("infjump_char", plr.CharacterAdded:Connect(function()
		doINFJUMPY()
	end))

	doINFJUMPY()
end)

cmd.add({"uninfjump", "uninfinitejump"}, {"uninfjump (uninfinitejump)", "Disables infinite jumping"}, function()
	Wait()
	DebugNotif("Infinite Jump Disabled", 2)

	NAlib.disconnect("infjump_jump")
	NAlib.disconnect("infjump_char")
end)

cmd.add({"flyjump"},{"flyjump","Allows you to hold space to fly up"},function()
	Wait()
	DebugNotif("FlyJump Enabled", 3)

	NAlib.disconnect("flyjump")
	NAlib.connect("flyjump", UserInputService.JumpRequest:Connect(function()
		getHum():ChangeState(Enum.HumanoidStateType.Jumping)
	end))
end)

cmd.add({"unflyjump","noflyjump"},{"unflyjump (noflyjump)","Disables flyjump"},function()
	Wait()
	DebugNotif("FlyJump Disabled", 3)

	NAlib.disconnect("flyjump")
end)

cmd.add({"xray", "xrayon"}, {"xray (xrayon)", "Enables X-ray vision to see through walls"}, function()
	Wait()
	DebugNotif("X-ray enabled")
	togXray(true)
end)

cmd.add({"unxray", "xrayoff"}, {"unxray (xrayoff)", "Disables X-ray vision"}, function()
	Wait()
	DebugNotif("X-ray disabled")
	togXray(false)
end)

cmd.add({"pastebinscraper","pastebinscrape"},{"pastebinscraper (pastebinscrape)","Scrapes paste bin posts"},function()
	Wait();

	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/trash(paste)bin%20scrapper"))()
	COREGUI.Scraper["Pastebin Scraper"].BackgroundTransparency=0.5
	COREGUI.Scraper["Pastebin Scraper"].TextButton.Text="             ⭐ Pastebin Post Scraper ⭐"
	COREGUI.Scraper["Pastebin Scraper"].Content.Search.PlaceholderText="Search for a post here..."
	COREGUI.Scraper["Pastebin Scraper"].Content.Search.BackgroundTransparency=0.4
	DebugNotif("Pastebin scraper loaded")
end)

cmd.add({"fullbright","fullb","fb"},{"fullbright (fullb,fb)","Makes games that are really dark to have no darkness and be really light"},function()
	if not getgenv().FullBrightExecuted then

		getgenv().FullBrightEnabled=false

		getgenv().NormalLightingSettings={
			Brightness=Lighting.Brightness,
			ClockTime=Lighting.ClockTime,
			FogEnd=Lighting.FogEnd,
			GlobalShadows=Lighting.GlobalShadows,
			Ambient=Lighting.Ambient
		}

		Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
			if Lighting.Brightness~=1 and Lighting.Brightness~=getgenv().NormalLightingSettings.Brightness then
				getgenv().NormalLightingSettings.Brightness=Lighting.Brightness
				if not getgenv().FullBrightEnabled then
					repeat
						Wait()
					until getgenv().FullBrightEnabled
				end
				Lighting.Brightness=1
			end
		end)

		Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
			if Lighting.ClockTime~=12 and Lighting.ClockTime~=getgenv().NormalLightingSettings.ClockTime then
				getgenv().NormalLightingSettings.ClockTime=Lighting.ClockTime
				if not getgenv().FullBrightEnabled then
					repeat
						Wait()
					until getgenv().FullBrightEnabled
				end
				Lighting.ClockTime=12
			end
		end)

		Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
			if Lighting.FogEnd~=786543 and Lighting.FogEnd~=getgenv().NormalLightingSettings.FogEnd then
				getgenv().NormalLightingSettings.FogEnd=Lighting.FogEnd
				if not getgenv().FullBrightEnabled then
					repeat
						Wait()
					until getgenv().FullBrightEnabled
				end
				Lighting.FogEnd=786543
			end
		end)

		Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
			if Lighting.GlobalShadows~=false and Lighting.GlobalShadows~=getgenv().NormalLightingSettings.GlobalShadows then
				getgenv().NormalLightingSettings.GlobalShadows=Lighting.GlobalShadows
				if not getgenv().FullBrightEnabled then
					repeat
						Wait()
					until getgenv().FullBrightEnabled
				end
				Lighting.GlobalShadows=false
			end
		end)

		Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
			if Lighting.Ambient~=Color3.fromRGB(178,178,178) and Lighting.Ambient~=getgenv().NormalLightingSettings.Ambient then
				getgenv().NormalLightingSettings.Ambient=Lighting.Ambient
				if not getgenv().FullBrightEnabled then
					repeat
						Wait()
					until getgenv().FullBrightEnabled
				end
				Lighting.Ambient=Color3.fromRGB(178,178,178)
			end
		end)

		Lighting.Brightness=1
		Lighting.ClockTime=12
		Lighting.FogEnd=786543
		Lighting.GlobalShadows=false
		Lighting.Ambient=Color3.fromRGB(178,178,178)

		local LatestValue=true
		Spawn(function()
			repeat
				Wait()
			until getgenv().FullBrightEnabled
			while Wait() do
				if getgenv().FullBrightEnabled~=LatestValue then
					if not getgenv().FullBrightEnabled then
						Lighting.Brightness=getgenv().NormalLightingSettings.Brightness
						Lighting.ClockTime=getgenv().NormalLightingSettings.ClockTime
						Lighting.FogEnd=getgenv().NormalLightingSettings.FogEnd
						Lighting.GlobalShadows=getgenv().NormalLightingSettings.GlobalShadows
						Lighting.Ambient=getgenv().NormalLightingSettings.Ambient
					else
						Lighting.Brightness=1
						Lighting.ClockTime=12
						Lighting.FogEnd=786543
						Lighting.GlobalShadows=false
						Lighting.Ambient=Color3.fromRGB(178,178,178)
					end
					LatestValue=not LatestValue
				end
			end
		end)
	end

	getgenv().FullBrightExecuted=true
	getgenv().FullBrightEnabled=not getgenv().FullBrightEnabled
end)

cmd.add({"loopday", "lday"}, {"loopday (lday)", "Sunshiiiine!"}, function()
	NAlib.disconnect("loopday")

	Lighting.ClockTime = 14

	NAlib.connect("loopday", Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		if Lighting.ClockTime ~= 14 then
			Lighting.ClockTime = 14
		end
	end))
end)

cmd.add({"unloopday", "unlday"}, {"unloopday (unlday)", "No more sunshine"}, function()
	NAlib.disconnect("loopday")
end)

cmd.add({"loopfullbright", "loopfb", "lfb"}, {"loopfullbright (loopfb,lfb)", "Sunshiiiine!"}, function()
	NAlib.disconnect("fbCon")
	NAlib.disconnect("fbCon1")
	NAlib.disconnect("fbCon2")
	NAlib.disconnect("fbCon3")
	NAlib.disconnect("fbCon4")

	Lighting.Brightness = 1
	Lighting.ClockTime = 12
	Lighting.FogEnd = 786543
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)

	NAlib.connect("fbCon", Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
		if Lighting.Brightness ~= 1 then
			Lighting.Brightness = 1
		end
	end))
	NAlib.connect("fbCon1", Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		if Lighting.ClockTime ~= 12 then
			Lighting.ClockTime = 12
		end
	end))
	NAlib.connect("fbCon2", Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
		if Lighting.FogEnd ~= 786543 then
			Lighting.FogEnd = 786543
		end
	end))
	NAlib.connect("fbCon3", Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
		if Lighting.GlobalShadows ~= false then
			Lighting.GlobalShadows = false
		end
	end))
	NAlib.connect("fbCon4", Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
		if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) then
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		end
	end))
end)

cmd.add({"unloopfullbright", "unloopfb", "unlfb"}, {"unloopfullbright (unloopfb,unlfb)", "No more sunshine"}, function()
	NAlib.disconnect("fbCon")
	NAlib.disconnect("fbCon1")
	NAlib.disconnect("fbCon2")
	NAlib.disconnect("fbCon3")
	NAlib.disconnect("fbCon4")
end)

cmd.add({"loopnight", "loopn", "ln"}, {"loopnight (loopn,ln)", "Moonlight."}, function()
	NAlib.disconnect("nightCon")
	NAlib.disconnect("nightCon1")
	NAlib.disconnect("nightCon2")
	NAlib.disconnect("nightCon3")
	NAlib.disconnect("nightCon4")

	Lighting.Brightness = 1
	Lighting.ClockTime = 0
	Lighting.FogEnd = 786543
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)

	NAlib.connect("nightCon", Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
		if Lighting.Brightness ~= 1 then
			Lighting.Brightness = 1
		end
	end))
	NAlib.connect("nightCon1", Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		if Lighting.ClockTime ~= 0 then
			Lighting.ClockTime = 0
		end
	end))
	NAlib.connect("nightCon2", Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
		if Lighting.FogEnd ~= 786543 then
			Lighting.FogEnd = 786543
		end
	end))
	NAlib.connect("nightCon3", Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
		if Lighting.GlobalShadows ~= false then
			Lighting.GlobalShadows = false
		end
	end))
	NAlib.connect("nightCon4", Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
		if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) then
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		end
	end))
end)

cmd.add({"unloopnight", "unloopn", "unln"}, {"unloopnight (unloopn,unln)", "No more moonlight."}, function()
	NAlib.disconnect("nightCon")
	NAlib.disconnect("nightCon1")
	NAlib.disconnect("nightCon2")
	NAlib.disconnect("nightCon3")
	NAlib.disconnect("nightCon4")
end)

cmd.add({"loopnofog","lnofog","lnf", "loopnf"},{"loopnofog (lnofog,lnf,loopnf)","See clearly forever!"},function()
	local Lighting = Lighting

	NAlib.disconnect("nofog_con")
	NAlib.disconnect("nofog_loop")

	Lighting.FogEnd = 786543

	function fogFunc()
		for i, v in pairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") then
				v:Destroy()
			end
		end
	end

	NAlib.connect("nofog_con", Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
		if Lighting.FogEnd ~= 786543 then
			Lighting.FogEnd = 786543
		end
	end))

	NAlib.connect("nofog_loop", RunService.RenderStepped:Connect(fogFunc))
end)

cmd.add({"unloopnofog","unlnofog","unlnf","unloopnf"},{"unloopnofog (unlnofog,unlnf,unloopnf)","No more sight."},function()
	NAlib.disconnect("nofog_con")
	NAlib.disconnect("nofog_loop")
end)

cmd.add({"brightness"},{"brightness","Changes the brightness lighting property"},function(...)
	Lighting.Brightness=(...)
end,true)

cmd.add({"globalshadows","gshadows"},{"globalshadows (gshadows)","Enables global shadows"},function()
	Lighting.GlobalShadows=true
end)

cmd.add({"unglobalshadows","nogshadows","ungshadows","noglobalshadows"},{"unglobalshadows (nogshadows,ungshadows,noglobalshadows)","Disables global shadows"},function()
	Lighting.GlobalShadows=false
end)

cmd.add({"gamma", "exposure"},{"gamma (exposure)","gamma vision (real)"},function(num)
	expose = tonumber(num) or 0
	Lighting.ExposureCompensation = expose
end,true)

cmd.add({"loopgamma", "loopexposure"},{"loopgamma (loopexposure)","loop gamma vision (mega real)"},function(num)
	expose = tonumber(num) or 0
	NAlib.disconnect("loopgamma")

	Lighting.ExposureCompensation = expose

	NAlib.connect("loopgamma", Lighting:GetPropertyChangedSignal("ExposureCompensation"):Connect(function()
		if Lighting.ExposureCompensation ~= expose then
			Lighting.ExposureCompensation = expose
		end
	end))
end, true)

cmd.add({"unloopgamma", "unlgamma", "unloopexposure", "unlexposure"},{"unloopgamma (unlgamma, unloopexposure, unlexposure)","stop gamma vision (real)"},function()
	NAlib.disconnect("loopgamma")
end)

cmd.add({"unsuspendvc", "fixvc", "rejoinvc", "restorevc"},{"unsuspendvc (fixvc, rejoinvc, restorevc)","allows you to use Voice Chat again"},function()
	SafeGetService("VoiceChatService"):joinVoice()

	if typeof(onVoiceModerated) ~= "RBXScriptConnection" then
		onVoiceModerated = SafeGetService("VoiceChatInternal").LocalPlayerModerated:Connect(function()
			Wait(1)
			SafeGetService("VoiceChatService"):joinVoice()
		end)
	end
end)

--[[cmd.add({"iy"},{"iy {command}","Executes infinite yield scripts"},function(...)
	if IYLOADED==false then
		function copytable(tbl) local copy={} for i,v in pairs(tbl) do copy[i]=v end return copy end
		local sandbox_env=copytable(getfenv())
		setmetatable(sandbox_env,{
			__index=function(self,i)
				if rawget(sandbox_env,i) then
					return rawget(sandbox_env,i)
				elseif getfenv()[i] then
					return getfenv()[i]
				end
			end
		})
		sandbox_env.game=nil
		iy,_=game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"):gsub("local Main","Main"):gsub("Players.LocalPlayer.Chatted","Funny=Players.LocalPlayer.Chatted"):gsub("local lastMessage","notify=getgenv().notify\nlocal lastMessage")
		setfenv(loadstring(iy),sandbox_env)()
		iy_cmds_table=sandbox_env.CMDs
		iy_gui=sandbox_env.Main
		iy_chathandler=sandbox_env.Funny
		execCmd=sandbox_env.execCmd
		iy_gui:Destroy()
		NACaller(function()
			iy_chathandler:Disconnect()
		end)
		IYLOADED=true
	end
	execCmd((...))
end,true)]]

cmd.add({"firstp","1stp","firstperson","fp"},{"firstperson (1stp,firstp,fp)","Makes you go in first person mode"},function()
	Player.CameraMode="LockFirstPerson"
end)

cmd.add({"thirdp","3rdp","thirdperson"},{"thirdperson (3rdp,thirdp)","Makes you go in third person mode"},function()
	Player.CameraMaxZoomDistance=math.huge
	Player.CameraMode="Classic"
end)

cmd.add({"maxzoom"},{"maxzoom <amount>","Set your maximum camera distance"},function(num)
	local num=tonumber(num) or 128
	Players.LocalPlayer.CameraMaxZoomDistance=num
end,true)

cmd.add({"minzoom"},{"minzoom <amount>","Set your minimum camera distance"},function(...)
	local args={...}
	local num=args[1]

	if num==nil then
		num=0
	else
		num=tonumber(num)
	end
	Players.LocalPlayer.CameraMinZoomDistance=num
end,true)

cmd.add({"cameranoclip","camnoclip","cnoclip","nccam"},{"cameranoclip (camnoclip,cnoclip,nccam)","Makes your camera clip through walls"}, function()
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera

	local SetConstant = (debug and debug.setconstant) or setconstant
	local GetConstants = (debug and debug.getconstants) or getconstants
	local HasAdvancedAccess = (getgc and SetConstant and GetConstants)

	if HasAdvancedAccess then
		local PlayerModule = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("PlayerModule")
		local Popper = PlayerModule and PlayerModule:FindFirstChild("CameraModule") and PlayerModule.CameraModule:FindFirstChild("ZoomController") and PlayerModule.CameraModule.ZoomController:FindFirstChild("Popper")

		if Popper then
			for i, v in pairs(getgc()) do
				if type(v) == "function" and getfenv(v).script == Popper then
					for i2, v2 in pairs(GetConstants(v)) do
						if tonumber(v2) == 0.25 then
							SetConstant(v, i2, 0)
						elseif tonumber(v2) == 0 then
							SetConstant(v, i2, 0.25)
						end
					end
				end
			end
		end
	else
		--[[if _G._noclipConnection then _G._noclipConnection:Disconnect() end
		if _G._noclipInput then _G._noclipInput:Disconnect() end
		if _G._noclipZoom then _G._noclipZoom:Disconnect() end
		if _G._noclipBegin then _G._noclipBegin:Disconnect() end
		if _G._noclipEnd then _G._noclipEnd:Disconnect() end

		local rootPart = (player.Character or player.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
		local zoom = (camera.CFrame.Position - rootPart.Position).Magnitude
		local minZoom = player.CameraMinZoomDistance
		local maxZoom = player.CameraMaxZoomDistance
		local rotationX, rotationY = 0, 0
		local sensitivity = 0.2
		local rotating = false

		camera.CameraType = Enum.CameraType.Scriptable
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default

		_G._noclipBegin = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				rotating = true
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			end
		end)

		_G._noclipEnd = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton2 then
				rotating = false
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
		end)

		_G._noclipInput = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and rotating then
				rotationX=rotationX - input.Delta.X * sensitivity
				rotationY = math.clamp(rotationY + input.Delta.Y * sensitivity, -80, 80)
			end
		end)

		_G._noclipZoom = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				zoom = math.clamp(zoom - input.Position.Z * 2, minZoom, maxZoom)
			end
		end)

		_G._noclipConnection = RunService.RenderStepped:Connect(function()
			local targetPos = rootPart.Position + Vector3.new(0, 2, 0)
			local rot = CFrame.Angles(0, math.rad(rotationX), 0) * CFrame.Angles(math.rad(rotationY), 0, 0)
			local camPos = targetPos + rot:VectorToWorldSpace(Vector3.new(0, 0, -zoom))
			camera.CFrame = CFrame.new(camPos, targetPos)
		end)]]
		if NAlib.isConnected("ilovesolara") then NAlib.disconnect("ilovesolara") player.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Zoom return end
		NAlib.connect("ilovesolara",player:GetPropertyChangedSignal("DevCameraOcclusionMode"):Connect(function()
			if player.DevCameraOcclusionMode~=Enum.DevCameraOcclusionMode.Invisicam then
				player.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Invisicam
			end
		end))
		player.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Invisicam
	end
end)

cmd.add({"uncameranoclip","uncamnoclip","uncnoclip","unnccam"},{"uncameranoclip (uncamnoclip,uncnoclip,unnccam)","Restores normal camera"}, function()
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera

	local SetConstant = (debug and debug.setconstant) or setconstant
	local GetConstants = (debug and debug.getconstants) or getconstants
	local HasAdvancedAccess = (getgc and SetConstant and GetConstants)

	if HasAdvancedAccess then
		local PlayerModule = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("PlayerModule")
		local Popper = PlayerModule and PlayerModule:FindFirstChild("CameraModule") and PlayerModule.CameraModule:FindFirstChild("ZoomController") and PlayerModule.CameraModule.ZoomController:FindFirstChild("Popper")

		if Popper then
			for i, v in pairs(getgc()) do
				if type(v) == "function" and getfenv(v).script == Popper then
					for i2, v2 in pairs(GetConstants(v)) do
						if tonumber(v2) == 0.25 then
							SetConstant(v, i2, 0)
						elseif tonumber(v2) == 0 then
							SetConstant(v, i2, 0.25)
						end
					end
				end
			end
		end
	else
		--[[if _G._noclipConnection then _G._noclipConnection:Disconnect() _G._noclipConnection = nil end
		if _G._noclipInput then _G._noclipInput:Disconnect() _G._noclipInput = nil end
		if _G._noclipZoom then _G._noclipZoom:Disconnect() _G._noclipZoom = nil end
		if _G._noclipBegin then _G._noclipBegin:Disconnect() _G._noclipBegin = nil end
		if _G._noclipEnd then _G._noclipEnd:Disconnect() _G._noclipEnd = nil end

		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		camera.CameraType = Enum.CameraType.Custom

		local scripts = player:FindFirstChild("PlayerScripts")
		if scripts then
			local existingModule = scripts:FindFirstChild("PlayerModule")
			if existingModule then existingModule:Destroy() end

			local starterModule = SafeGetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts"):FindFirstChild("PlayerModule")
			if starterModule then
				local newModule = starterModule:Clone()
				newModule.Parent = scripts
			end
		end]]
		NAlib.disconnect("ilovesolara")
		LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
	end
end)

cmd.add({"oganims"},{"oganims","Old animations from 2007"},function()
	Wait();
	DebugNotif("OG animations set")
	loadstring(game:HttpGet(('https://pastebin.com/raw/6GNkQUu6'),true))()
end)

cmd.add({"fakechat"},{"fakechat","Fake a chat gui"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/fake%20chatte"))()
end)

cmd.add({"fpscap"},{"fpscap <number>","Sets the fps cap to whatever you want"},function(arg)
	local cap = tonumber(arg)
	if cap then
		setfpscap(math.clamp(cap, 1, 999))
	else
		DoNotif("invalid input",1.3)
	end
end,true)

cmd.add({"toolinvisible", "tinvis"}, {"toolinvisible (tinvis)", "Be invisible while still being able to use tools"}, function()
	local offset = 1100
	invisible = false
	local grips = {}
	local heldTool
	local gripChanged
	local handle
	local weld
	HH = getHum().HipHeight

	function setDisplayDistance(distance)
		for _, player in pairs(Players:GetPlayers()) do
			if getPlrChar(player) and getPlrHum(player) then
				getPlrHum(player).NameDisplayDistance = distance
				getPlrHum(player).HealthDisplayDistance = distance
			end
		end
	end

	local tool = InstanceNew("Tool", Players.LocalPlayer.Backpack)
	tool.Name = "Turn Invisible"
	tool.RequiresHandle = false
	tool.CanBeDropped = false

	tool.Equipped:Connect(function()
		Wait()
		if not invisible then
			invisible = true
			tool.Name = "Visible Enabled"

			if handle then
				handle:Destroy()
			end
			if weld then
				weld:Destroy()
			end

			handle = InstanceNew("Part", workspace)
			handle.Name = "Handle"
			handle.Transparency = 1
			handle.CanCollide = false
			handle.Size = Vector3.new(2, 1, 1)

			weld = InstanceNew("Weld", handle)
			weld.Part0 = handle
			weld.Part1 = getRoot(getChar())
			weld.C0 = CFrame.new(0, offset - 1.5, 0)

			setDisplayDistance(offset + 100)
			workspace.CurrentCamera.CameraSubject = handle
			getRoot(getChar()).CFrame = getRoot(getChar()).CFrame * CFrame.new(0, offset, 0)
			getHum().HipHeight = offset
			getHum():ChangeState(11)

			for _, child in pairs(Players.LocalPlayer.Backpack:GetChildren()) do
				if child:IsA("Tool") and child ~= tool then
					grips[child] = child.Grip
				end
			end
			if getHum() then
				getHum():SetStateEnabled("Seated", false)
				getHum().Sit = true
			end
		else
			invisible = false
			tool.Name = "Visible Disabled"

			if handle then
				handle:Destroy()
			end
			if weld then
				weld:Destroy()
			end

			for _, child in pairs(getChar():GetChildren()) do
				if child:IsA("Tool") then
					child.Parent = Players.LocalPlayer.Backpack
				end
			end

			for tool, grip in pairs(grips) do
				if tool then
					tool.Grip = grip
				end
			end

			heldTool = nil
			setDisplayDistance(100)
			workspace.CurrentCamera.CameraSubject = getHum()
			getRoot(getChar()).CFrame = getRoot(getChar()).CFrame * CFrame.new(0, -offset, 0)
			getHum().HipHeight = HH

			if getHum() then
				getHum():SetStateEnabled("Seated", true)
				getHum().Sit = false
			end
		end

		tool.Parent = Players.LocalPlayer.Backpack
	end)

	getChar().ChildAdded:Connect(function(child)
		Wait()
		if invisible and child:IsA("Tool") and child ~= heldTool and child ~= tool then
			heldTool = child
			local lastGrip = heldTool.Grip

			if not grips[heldTool] then
				grips[heldTool] = lastGrip
			end

			for _, track in pairs(getHum():GetPlayingAnimationTracks()) do
				track:Stop()
			end

			getChar().Animate.Disabled = true
			heldTool.Grip = heldTool.Grip * (CFrame.new(0, offset - 1.5, 1.5) * CFrame.Angles(math.rad(-90), 0, 0))
			heldTool.Parent = Players.LocalPlayer.Backpack
			heldTool.Parent = getChar()

			if gripChanged then
				gripChanged:Disconnect()
			end

			gripChanged = heldTool:GetPropertyChangedSignal("Grip"):Connect(function()
				Wait()
				if not invisible then
					gripChanged:Disconnect()
				end

				if heldTool.Grip ~= lastGrip then
					lastGrip = heldTool.Grip * (CFrame.new(0, offset - 1.5, 1.5) * CFrame.Angles(math.rad(-90), 0, 0))
					heldTool.Grip = lastGrip
					heldTool.Parent = Players.LocalPlayer.Backpack
					heldTool.Parent = getChar()
				end
			end)
		end
	end)
end)

invisBtnlol = nil
invisKeybindConnection = nil
IsInvis = false
InvisibleCharacter = nil
OriginalPosition = nil
InvisBindLol = Enum.KeyCode.E

cmd.add({"invisible", "invis"},{"invisible (invis)", "Sets invisibility to scare people or something"}, function()
	if invisKeybindConnection then
		DebugNotif("Invisibility is already loaded!")
		return
	end

	local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	Character.Archivable = true
	OriginalPosition = getRoot(Character).CFrame

	local function TurnVisible()
		if not IsInvis then return end
		IsInvis = false
		OriginalPosition = getRoot(InvisibleCharacter).CFrame
		if InvisibleCharacter then
			InvisibleCharacter:Destroy()
			InvisibleCharacter = nil
		end
		Players.LocalPlayer.Character = Character
		Character.Parent = workspace
		RunService.Heartbeat:Wait()
		local root = getRoot(Character)
		if root then
			root.CFrame = OriginalPosition
		end
		DebugNotif("Invisibility turned off.")
		SafeGetService("StarterGui"):SetCore("ResetButtonCallback", true)
	end

	local function ToggleInvisibility()
		if not IsInvis then
			IsInvis = true
			InvisibleCharacter = Character:Clone()
			InvisibleCharacter.Parent = workspace
			for _, v in ipairs(InvisibleCharacter:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = v.Name:lower() == "humanoidrootpart" and 1 or 0.5
				end
			end
			local root = getRoot(Character)
			if root then
				OriginalPosition = root.CFrame
				root.CFrame = CFrame.new(0, math.pi * 1000000, 0)
			end
			Wait(0.1)
			Character.Parent = ReplicatedStorage
			local invisRoot = getRoot(InvisibleCharacter)
			if invisRoot then
				invisRoot.CFrame = OriginalPosition
			end
			Players.LocalPlayer.Character = InvisibleCharacter
			workspace.CurrentCamera.CameraSubject = getPlrHum(InvisibleCharacter)
			DebugNotif("You are now invisible.")
			SafeGetService("StarterGui"):SetCore("ResetButtonCallback", false)
		else
			TurnVisible()
		end
	end

	if invisKeybindConnection then
		invisKeybindConnection:Disconnect()
		invisKeybindConnection = nil
	end

	invisKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == InvisBindLol and not gameProcessed then
			ToggleInvisibility()
		end
	end)

	local humanoid = getPlrHum(Character)
	if humanoid then
		humanoid.Died:Connect(function()
			cmd.run({"vis"})
		end)
	end

	if IsOnMobile then
		if invisBtnlol then invisBtnlol:Destroy() invisBtnlol = nil end
		invisBtnlol = InstanceNew("ScreenGui")
		local TextButton = InstanceNew("TextButton")
		local UICorner = InstanceNew("UICorner")
		local UIAspectRatioConstraint = InstanceNew("UIAspectRatioConstraint")
		NaProtectUI(invisBtnlol)
		invisBtnlol.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		invisBtnlol.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		TextButton.Parent = invisBtnlol
		TextButton.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
		TextButton.BackgroundTransparency = 0.14
		TextButton.Position = UDim2.new(0.9, 0, 0.8, 0)
		TextButton.Size = UDim2.new(0.1, 0, 0.1, 0)
		TextButton.Font = Enum.Font.SourceSansBold
		TextButton.Text = "Invisible"
		TextButton.TextColor3 = Color3.new(1, 1, 1)
		TextButton.TextSize = 15
		TextButton.TextWrapped = true
		TextButton.TextScaled = true
		TextButton.Active = true
		UICorner.Parent = TextButton
		UIAspectRatioConstraint.Parent = TextButton
		UIAspectRatioConstraint.AspectRatio = 1
		NAgui.draggerV2(TextButton)
		MouseButtonFix(TextButton, function()
			ToggleInvisibility()
			TextButton.Text = IsInvis and "Visible" or "Invisible"
		end)
	end

	Wait()
	DebugNotif("Invisible loaded. Press "..InvisBindLol.Name.." or use the mobile button",2.5)
end)

cmd.add({"visible", "vis"}, {"visible", "turn visible"}, function()
	if invisKeybindConnection then
		invisKeybindConnection:Disconnect()
		invisKeybindConnection = nil
	end
	if invisBtnlol then
		invisBtnlol:Destroy()
		invisBtnlol = nil
	end
	local Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	if IsInvis then
		IsInvis = false
		if InvisibleCharacter then InvisibleCharacter:Destroy() InvisibleCharacter = nil end
		Players.LocalPlayer.Character = Character
		Character.Parent = workspace
	end
	DebugNotif("Invisibility Disabled",2)
end)

cmd.add({"invisbind", "invisiblebind","bindinvis"}, {"invisbind (invisiblebind, bindinvis)", "set a custom keybind for the 'Invisible' command"}, function(...)
	local args = {...}
	if args[1] then
		InvisBindLol = Enum.KeyCode[args[1]] or Enum.KeyCode[args[1]:upper()]
		if InvisBindLol then
			DebugNotif("Invis bind set to "..InvisBindLol.Name)
		else
			DebugNotif("Invalid keybind, defaulting to E")
			InvisBindLol = Enum.KeyCode.E
		end
	else
		DebugNotif("No keybind provided")
	end
end,true)

cmd.add({"fireremotes", "fremotes", "frem"}, {"fireremotes (fremotes, frem)", "Fires every remote with arguments"}, function()
	local remoteCount = 0
	local failedCount = 0

	for _, obj in ipairs(game:GetDescendants()) do
		if not obj:IsDescendantOf(COREGUI) and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
			Spawn(function()
				local ok
				if obj:IsA("RemoteEvent") then
					ok = pcall(function() obj:FireServer() end)
				elseif obj:IsA("RemoteFunction") then
					ok = pcall(function() obj:InvokeServer() end)
				end

				if ok then
					remoteCount=remoteCount + 1
				else
					failedCount=failedCount + 1
				end
			end)
		end
	end

	Delay(2, function()
		DebugNotif("Fired "..remoteCount.." remotes\nFailed: "..failedCount.." remotes")
	end)
end)

cmd.add({"keepna"}, {"keepna", "keep executing "..adminName.." every time you teleport"}, function()
	NAQoTEnabled=true
	if FileSupport then
		writefile(NAfiles.NAQOTPATH, "true")
		DoNotif(adminName.." will now auto-load after teleport (QueueOnTeleport enabled)")
	end
end)

cmd.add({"unkeepna"}, {"unkeepna", "Stop executing "..adminName.." every time you teleport"}, function()
	NAQoTEnabled=false
	if FileSupport then
		writefile(NAfiles.NAQOTPATH, "false")
		if not NAQoTEnabled then
			DoNotif("QueueOnTeleport has been disabled. "..adminName.." will no longer auto-run after teleport")
		end
	end
end)

loopedFOV = nil

cmd.add({"fov"}, {"fov <number>", "Sets your FOV to a custom value (1–120)"}, function(num)
	local field = math.clamp(tonumber(num) or 70, 1, 120)
	local cam = workspace.CurrentCamera
	TweenService:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = field}):Play()
end, true)

cmd.add({"loopfov", "lfov"}, {"loopfov <number> (lfov)", "Loops your FOV to stay at a custom value (1–120)"}, function(num)
	loopedFOV = math.clamp(tonumber(num) or 70, 1, 120)

	local function apply()
		NAlib.disconnect("fov_loop")
		NAlib.disconnect("fov_refresh")

		local cam = workspace.CurrentCamera
		if not cam then return end

		NAlib.connect("fov_loop", RunService.Stepped:Connect(function()
			if cam.FieldOfView ~= loopedFOV then
				cam.FieldOfView = loopedFOV
			end
		end))

		NAlib.connect("fov_refresh", cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			if cam.FieldOfView ~= loopedFOV then
				cam.FieldOfView = loopedFOV
			end
		end))
	end

	NAlib.disconnect("fov_watch")
	NAlib.connect("fov_watch", workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Wait(0.05)
		apply()
	end))

	apply()
end, true)

cmd.add({"unloopfov", "unlfov"}, {"unloopfov (unlfov)", "Stops the looped FOV"}, function()
	NAlib.disconnect("fov_loop")
	NAlib.disconnect("fov_refresh")
	NAlib.disconnect("fov_watch")
	loopedFOV = nil
end)

cmd.add({"homebrew"},{"homebrew","Executes homebrew admin"},function()
	getgenv().CustomUI=false
	loadstring(game:HttpGet(('https://raw.githubusercontent.com/mgamingpro/HomebrewAdmin/master/Main'),true))()
end)

cmd.add({"fatesadmin"},{"fatesadmin","Executes fates admin"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua"))();
end)

storedTools = {}

cmd.add({"savetools", "stools"}, {"savetools (stools)", "Saves your tools to memory"}, function()
	storedTools = {}

	for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local clonedTool = tool:Clone()
			Insert(storedTools, clonedTool)
		end
	end

	for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
		if tool:IsA("Tool") then
			local clonedTool = tool:Clone()
			Insert(storedTools, clonedTool)
		end
	end

	DebugNotif("Tools saved: "..#storedTools,2)
end)

cmd.add({"loadtools", "ltools"}, {"loadtools (ltools)", "Restores your saved tools to your backpack"}, function()
	for _, tool in pairs(storedTools) do
		if not LocalPlayer.Backpack:FindFirstChild(tool.Name) then
			local clonedTool = tool:Clone()
			clonedTool.Parent = LocalPlayer.Backpack
		end
	end

	DebugNotif("Tools loaded: "..#storedTools,2)
end)

cmd.add({"preventtools", "noequip", "antiequip"}, {"preventtools (noequip,antiequip)", "Prevents any item from being equipped"}, function()
	local p = Players.LocalPlayer
	local c = p.Character

	NAlib.disconnect("noequip_char")
	NAlib.disconnect("noequip_hum")

	local h = getHum()
	if not h then return end

	h:UnequipTools()

	local function onTool(t)
		if t:IsA("Tool") then
			t.Enabled = false
			Defer(function()
				h:UnequipTools()
				DebugNotif("Tool "..t.Name.." blocked", 2)
			end)
		end
	end

	NAlib.connect("noequip_char", c.ChildAdded:Connect(onTool))
	NAlib.connect("noequip_hum", h.ChildAdded:Connect(onTool))

	DebugNotif("Tool prevention on", 3)
end)

cmd.add({"unpreventtools", "unnoequip", "unantiequip"}, {"unpreventtools (unnoequip,unantiequip)", "Self-explanatory"}, function()
	NAlib.disconnect("noequip_char")
	NAlib.disconnect("noequip_hum")
	DebugNotif("Tool prevention off", 2)
end)

cmd.add({"ws", "speed", "walkspeed"}, {"walkspeed <number> (speed,ws)", "Sets your WalkSpeed"}, function(...)
	local a = {...}
	local s = tonumber(a[2] or a[1]) or 16
	local h = getHum()
	if s and h then
		h.WalkSpeed = s
	end
end, true)

cmd.add({"jp", "jumppower"}, {"jumppower <number> (jp)", "Sets your JumpPower"}, function(...)
	local a = {...}
	local j = tonumber(a[1]) or 50
	local h = getHum()
	if j and h then
		if h.UseJumpPower then
			h.JumpPower = j
		else
			h.JumpHeight = j
		end
	end
end, true)

cmd.add({"oofspam"},{"oofspam","Spams oof"},function()
	getgenv().enabled = true
	getgenv().speed = 100
	local HRP = Humanoid.RootPart or getRoot(Humanoid.Parent)
	if not Humanoid or not getgenv().enabled then
		if Humanoid and Humanoid.Health <= 0 then
			Humanoid:Destroy()
		end
		return
	end
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	Humanoid.BreakJointsOnDeath = false
	Humanoid.RequiresNeck = false

	NAlib.connect("oofspam_forcerun", RunService.Stepped:Connect(function()
		if not Humanoid then return NAlib.disconnect("oofspam_forcerun") end
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end))

	LocalPlayer.Character = nil
	LocalPlayer.Character = Character
	Wait(Players.RespawnTime + 0.1)

	NAlib.connect("oofspam_loop", RunService.Heartbeat:Connect(function()
		if not getgenv().enabled then
			NAlib.disconnect("oofspam_loop")
			return
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end))
end)

cmd.add({"httpspy"},{"httpspy","HTTP Spy"},function()
	loadstring(game:HttpGet('https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/httpspy.lua'))()
end)

cmd.add({"keystroke"},{"keystroke","Executes a keystroke ui script"},function()
	loadstring(game:HttpGet("https://system-exodus.com/scripts/misc-releases/Keystrokes.lua",true))()
end)

cmd.add({"errorchat"},{"errorchat","Makes the chat error appear when roblox chat is slow"},function()
	for i=1,3 do
		NAlib.LocalPlayerChat("\0","All")
	end
end)

cmd.add({"clearerror", "noerror"}, {"clearerror", "Clears any current error or disconnected UI immediately"}, function()
	SafeGetService("GuiService"):ClearError()
end)

cmd.add({"antierror"}, {"antierror", "Continuously blocks and clears any future error or disconnected UI"}, function()
	NAlib.disconnect("antierror")
	NAlib.connect("antierror", SafeGetService("GuiService").ErrorMessageChanged:Connect(function()
		SafeGetService("GuiService"):ClearError()
	end))
	DebugNotif("Anti Error is now enabled!", 2)
end)

cmd.add({"unantierror", "noantierror"}, {"unantierror", "Disables Anti Error"}, function()
	NAlib.disconnect("antierror")
	DebugNotif("Anti Error is now disabled!",2)
end)

-- [[ NPC SECTION ]] --

cmd.add({"flingnpcs"}, {"flingnpcs", "Flings NPCs"}, function()
	local npcs = {}

	local function disappear(hum)
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			hum.HipHeight = 1024
		end
	end
	for _,hum in pairs(workspace:GetDescendants()) do
		disappear(hum)
	end
end)

cmd.add({"npcfollow"}, {"npcfollow", "Makes NPCS follow you"}, function()
	local npcs = {}

	local function disappear(hum)
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			local rootPart = getRoot(hum.Parent)
			local targetPos = getRoot(LocalPlayer.Character).Position
			hum:MoveTo(targetPos)
		end
	end
	for _,hum in pairs(workspace:GetDescendants()) do
		disappear(hum)
	end
end)

npcfollowloop = false
cmd.add({"loopnpcfollow"}, {"loopnpcfollow", "Makes NPCS follow you in a loop"}, function()
	npcfollowloop = true

	repeat Wait(0.1)
		local npcs = {}

		local function disappear(hum)
			if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
				Insert(npcs,{hum,hum.HipHeight})
				local rootPart = getRoot(hum.Parent)
				local targetPos = getRoot(LocalPlayer.Character).Position
				hum:MoveTo(targetPos)
			end
		end
		for _,hum in pairs(workspace:GetDescendants()) do
			disappear(hum)
		end
	until npcfollowloop == false
end)

cmd.add({"unloopnpcfollow"}, {"unloopnpcfollow", "Makes NPCS not follow you in a loop"}, function()
	npcfollowloop = false
end)

cmd.add({"sitnpcs"}, {"sitnpcs", "Makes NPCS sit"}, function()
	local npcs = {}

	local function disappear(hum)
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			local rootPart = getRoot(hum.Parent)
			if rootPart then
				hum.Sit = true
			end
		end
	end
	for _,hum in pairs(workspace:GetDescendants()) do
		disappear(hum)
	end
end)

cmd.add({"unsitnpcs"}, {"unsitnpcs", "Makes NPCS unsit"}, function()
	local npcs = {}

	local function disappear(hum)
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			local rootPart = getRoot(hum.Parent)
			if rootPart then
				hum.Sit = true
			end
		end
	end
	for _,hum in pairs(workspace:GetDescendants()) do
		disappear(hum)
	end
end)

cmd.add({"killnpcs"}, {"killnpcs", "Kills NPCs"}, function()
	local npcs = {}

	local function disappear(hum)
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			local rootPart = getRoot(hum.Parent)
			if rootPart then
				hum.Health = 0
			end
		end
	end
	for _,hum in pairs(workspace:GetDescendants()) do
		disappear(hum)
	end
end)

cmd.add({"npcwalkspeed","npcws"},{"npcwalkspeed <speed>","Sets all NPC WalkSpeed to <speed> (default 16)"},function(speedStr)
	local speed = tonumber(speedStr) or 16
	for _, hum in pairs(workspace:GetDescendants()) do
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			local root = getRoot(hum.Parent)
			if root then hum.WalkSpeed = speed end
		end
	end
end,true)

cmd.add({"npcjumppower","npcjp"},{"npcjumppower <power>","Sets all NPC JumpPower to <power> (default 50)"},function(powerStr)
	local power=tonumber(powerStr) or 50
	for _,hum in pairs(workspace:GetDescendants()) do
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			local root=getRoot(hum.Parent)
			if root then hum.JumpPower=power end
		end
	end
end,true)

cmd.add({"bringnpcs"}, {"bringnpcs", "Brings NPCs"}, function()
	local npcs = {}

	local function disappear(hum)
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			local rootPart = getRoot(hum.Parent)
			if rootPart then
				rootPart.CFrame = getRoot(LocalPlayer.Character).CFrame
			end
		end
	end
	for _,hum in pairs(workspace:GetDescendants()) do
		disappear(hum)
	end
end)

npcCache = {}
cmd.add({"loopbringnpcs", "lbnpcs"}, {"loopbringnpcs (lbnpcs)", "Loops NPC bringing"}, function()
	if NAlib.isConnected("loopbringnpcs") then NAlib.disconnect("loopbringnpcs") end
	table.clear(npcCache)
	for _, hum in ipairs(workspace:GetDescendants()) do
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcCache, hum)
		end
	end

	NAlib.connect("loopbringnpcs", RunService.Stepped:Connect(function()
		for _, hum in ipairs(npcCache) do
			if hum.Parent and hum.Health > 0 then
				local model = hum.Parent
				local rootPart = getRoot(model)
				local localRoot = LocalPlayer.Character and getRoot(LocalPlayer.Character)
				if rootPart and localRoot then
					rootPart.CFrame = localRoot.CFrame
				end
				Spawn(function()
					for _, part in ipairs(model:GetDescendants()) do
						if part:IsA("BasePart") then
							if NAlib.isProperty(part, "CanCollide") then
								NAlib.setProperty(part, "CanCollide", false)
							end
						end
					end
				end)
			end
		end
	end))
end)

cmd.add({"unloopbringnpcs", "unlbnpcs"}, {"unloopbringnpcs (unlbnpcs)", "Stops NPC bring loop"}, function()
	NAlib.disconnect("loopbringnpcs")
end)

cmd.add({"gotonpcs"}, {"gotonpcs", "Teleports to each NPC"}, function()
	local Players = SafeGetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local npcs = {}
	for _, d in pairs(workspace:GetDescendants()) do
		if d:IsA("Humanoid") and not Players:GetPlayerFromCharacter(d.Parent) then
			local root = getRoot(d.Parent)
			if root then
				Insert(npcs, root)
			end
		end
	end
	Spawn(function()
		for _, npcRoot in ipairs(npcs) do
			local char = LocalPlayer.Character
			if char and getRoot(char) then
				getRoot(char).CFrame = npcRoot.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end)
end)

local NPCControl = {
	Enabled = false,
	Connection = nil,
	CurrentTarget = nil,
	MoveCooldown = 0
}

cmd.add({"actnpc"}, {"actnpc", "Start acting like an NPC"}, function()
	if NPCControl.Enabled then return end
	NPCControl.Enabled = true

	local function moveToRandom()
		local char = LocalPlayer.Character
		local hum = getHum()
		local root = getRoot(char)
		if not (char and hum and root) then return end

		local randomOffset = Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
		local targetPos = root.Position + randomOffset

		NPCControl.CurrentTarget = targetPos
		hum:MoveTo(targetPos)

		DebugNotif("Moving to: "..Format("X: %.0f, Y: %.0f, Z: %.0f", targetPos.X, targetPos.Y, targetPos.Z), 1.5)
	end

	NPCControl.Connection = RunService.Heartbeat:Connect(function(dt)
		local char = LocalPlayer.Character
		local hum = getHum()
		local root = getRoot(char)
		if not (char and hum and root) then return end

		NPCControl.MoveCooldown=NPCControl.MoveCooldown - dt
		NPCControl._jumpCooldown = (NPCControl._jumpCooldown or 0) - dt
		NPCControl._moveTimeout = (NPCControl._moveTimeout or 0) + dt

		if hum.Sit then
			DebugNotif("Sitting detected — jumping to escape", 1.5)
			hum.Sit = false
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			NPCControl._jumpCooldown = 1.5
			return
		end

		if NPCControl.CurrentTarget and (root.Position - NPCControl.CurrentTarget).Magnitude < 2 then
			DebugNotif("Reached target", 1.5)
			NPCControl.CurrentTarget = nil
		end

		if not NPCControl.CurrentTarget or NPCControl._moveTimeout > 5 then
			if NPCControl._moveTimeout > 5 then
				DebugNotif("Stuck — retrying new path", 1.5)
			end
			if NPCControl.MoveCooldown <= 0 then
				moveToRandom()
				NPCControl.MoveCooldown = math.random(2, 4)
				NPCControl._moveTimeout = 0
			end
		end

		local forward = root.CFrame.LookVector
		local origin = root.Position + Vector3.new(0, 2, 0)
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		rayParams.FilterDescendantsInstances = {char}
		local result = Workspace:Raycast(origin, forward * 3 + Vector3.new(0, -2, 0), rayParams)

		if result and NPCControl._jumpCooldown <= 0 then
			local part = result.Instance
			local model = part:FindFirstAncestorOfClass("Model")
			local isPlayerChar = model and Players:GetPlayerFromCharacter(model)

			if part.CanCollide and not isPlayerChar then
				if hum:GetState() == Enum.HumanoidStateType.Running then
					DebugNotif("Obstacle detected — jumping", 1.5)
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
					NPCControl._jumpCooldown = 1.5
				end
			end
		end
	end)
end)

cmd.add({"unactnpc", "stopnpc"}, {"unactnpc (stopnpc)", "Stop acting like an NPC"}, function()
	if not NPCControl.Enabled then return end
	NPCControl.Enabled = false
	if NPCControl.Connection then
		NPCControl.Connection:Disconnect()
		NPCControl.Connection = nil
	end
end)

clickkillUI = nil
clickkillEnabled = false

cmd.add({"clickkillnpc", "cknpc"}, {"clickkillnpc (cknpc)", "Click on an NPC to kill it"}, function()
	clickkillEnabled = true

	if clickkillUI then clickkillUI:Destroy() end
	NAlib.disconnect("clickkill_mouse")

	local Mouse = player:GetMouse()

	clickkillUI = InstanceNew("ScreenGui")
	NaProtectUI(clickkillUI)

	local toggleButton = InstanceNew("TextButton")
	toggleButton.Size = UDim2.new(0, 120, 0, 40)
	toggleButton.Text = "ClickKill: ON"
	toggleButton.Position = UDim2.new(0.5, -60, 0, 10)
	toggleButton.TextScaled = 16
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toggleButton.BackgroundTransparency = 0.2
	toggleButton.Parent = clickkillUI

	local uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = toggleButton

	NAgui.draggerV2(toggleButton)

	MouseButtonFix(toggleButton, function()
		clickkillEnabled = not clickkillEnabled
		toggleButton.Text = clickkillEnabled and "ClickKill: ON" or "ClickKill: OFF"
	end)

	NAlib.connect("clickkill_mouse", Mouse.Button1Down:Connect(function()
		if not clickkillEnabled then return end

		local Target = Mouse.Target
		if Target and Target.Parent then
			local Character = Target.Parent
			if CheckIfNPC(Character) then
				local Humanoid = getPlrHum(Character)
				if Humanoid then
					Humanoid.Health = 0
				end
			end
		end
	end))
end)

cmd.add({"unclickkillnpc", "uncknpc"}, {"unclickkillnpc (uncknpc)", "Disable clickkillnpc"}, function()
	clickkillEnabled = false
	if clickkillUI then clickkillUI:Destroy() end
	NAlib.disconnect("clickkill_mouse")
end)

cmd.add({"voidnpcs", "vnpcs"}, {"voidnpcs (vnpcs)", "Teleports NPC's to void"}, function()
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("Humanoid") and not Players:GetPlayerFromCharacter(d.Parent) then
			local root = getPlrHum(d.Parent)
			if root then
				root.HipHeight = math.huge
			end
		end
	end
end)

clickVoidUI = nil
clickVoidEnabled = false

cmd.add({"clickvoidnpc", "cvnpc"}, {"clickvoidnpc (cvnpc)", "Click to void NPCs"}, function()
	clickVoidEnabled = true

	if clickVoidUI then clickVoidUI:Destroy() end
	NAlib.disconnect("clickvoid_mouse")

	clickVoidUI = InstanceNew("ScreenGui")
	NaProtectUI(clickVoidUI)

	local button = InstanceNew("TextButton")
	button.Size = UDim2.new(0, 120, 0, 40)
	button.Text = "ClickVoid: ON"
	button.Position = UDim2.new(0.5, -60, 0, 10)
	button.TextScaled = true
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.BackgroundTransparency = 0.2
	button.Parent = clickVoidUI

	local corner = InstanceNew("UICorner", button)
	corner.CornerRadius = UDim.new(0, 8)
	NAgui.draggerV2(button)

	MouseButtonFix(button, function()
		clickVoidEnabled = not clickVoidEnabled
		button.Text = clickVoidEnabled and "ClickVoid: ON" or "ClickVoid: OFF"
	end)

	local mouse = player:GetMouse()
	NAlib.connect("clickvoid_mouse", mouse.Button1Down:Connect(function()
		if not clickVoidEnabled then return end

		local target = mouse.Target
		if target and target.Parent and CheckIfNPC(target.Parent) then
			local root = getPlrHum(target.Parent)
			if root then
				root.HipHeight = math.huge
			end
		end
	end))
end)

cmd.add({"unclickvoidnpc", "uncvnpc"}, {"unclickvoidnpc (uncvnpc)","Disable click-void"}, function()
	clickVoidEnabled = false
	if clickVoidUI then clickVoidUI:Destroy() end
	NAlib.disconnect("clickvoid_mouse")
end)

clickSpeedUI,clickSpeedEnabled=nil,false

cmd.add({"clicknpcws","cnpcws"},{"clicknpcws","Click on an NPC to set its WalkSpeed"},function()
	clickSpeedEnabled=true
	if clickSpeedUI then clickSpeedUI:Destroy() end
	NAlib.disconnect("clickspeed_mouse")
	local player=Players.LocalPlayer
	local mouse=player:GetMouse()
	clickSpeedUI=InstanceNew("ScreenGui")
	NaProtectUI(clickSpeedUI)
	local btn=InstanceNew("TextButton")
	btn.Size=UDim2.new(0,120,0,40)
	btn.Position=UDim2.new(0.5,-130,0,10)
	btn.Text="SetSpeed: ON"
	btn.TextSize=16
	btn.TextColor3=Color3.new(1,1,1)
	btn.Font=Enum.Font.GothamBold
	btn.BackgroundColor3=Color3.fromRGB(40,40,40)
	btn.BackgroundTransparency=0.2
	btn.Parent=clickSpeedUI
	local cor1=InstanceNew("UICorner")
	cor1.CornerRadius=UDim.new(0,8)
	cor1.Parent=btn
	NAgui.draggerV2(btn)
	local tb=InstanceNew("TextBox")
	tb.Size=UDim2.new(0,120,0,40)
	tb.Position=UDim2.new(0.5,10,0,10)
	tb.Text="16"
	tb.PlaceholderText="Speed"
	tb.TextSize=16
	tb.TextColor3=Color3.new(1,1,1)
	tb.Font=Enum.Font.Gotham
	tb.BackgroundColor3=Color3.fromRGB(50,50,50)
	tb.BackgroundTransparency=0.2
	tb.Parent=clickSpeedUI
	local cor2=InstanceNew("UICorner")
	cor2.CornerRadius=UDim.new(0,8)
	cor2.Parent=tb
	NAgui.draggerV2(tb)
	local speedNumber=16
	tb.FocusLost:Connect(function(enterPressed)
		local n=tonumber(tb.Text)
		if n then speedNumber=n else tb.Text=tostring(speedNumber) end
	end)
	MouseButtonFix(btn,function()
		clickSpeedEnabled=not clickSpeedEnabled
		btn.Text=clickSpeedEnabled and "SetSpeed: ON" or "SetSpeed: OFF"
	end)
	NAlib.connect("clickspeed_mouse",mouse.Button1Down:Connect(function()
		if not clickSpeedEnabled then return end
		local hit=mouse.Target
		if hit and hit.Parent and CheckIfNPC(hit.Parent) then
			local hum=getPlrHum(hit.Parent)
			if hum then hum.WalkSpeed=speedNumber end
		end
	end))
end)

cmd.add({"unclicknpcws","uncnpcws"},{"unclicknpcws","Disable clicknpcws"},function()
	clickSpeedEnabled=false
	if clickSpeedUI then clickSpeedUI:Destroy() end
	NAlib.disconnect("clickspeed_mouse")
end)

clickJumpUI,clickJumpEnabled=nil,false

cmd.add({"clicknpcjp","cnpcjp"},{"clicknpcjp","Click on an NPC to set its JumpPower"},function()
	clickJumpEnabled=true
	if clickJumpUI then clickJumpUI:Destroy() end
	NAlib.disconnect("clickjump_mouse")
	local player=Players.LocalPlayer
	local mouse=player:GetMouse()
	clickJumpUI=InstanceNew("ScreenGui")
	NaProtectUI(clickJumpUI)
	local btn=InstanceNew("TextButton")
	btn.Size=UDim2.new(0,120,0,40)
	btn.Position=UDim2.new(0.5,-130,0,10)
	btn.Text="SetJump: ON"
	btn.TextSize=16
	btn.TextColor3=Color3.new(1,1,1)
	btn.Font=Enum.Font.GothamBold
	btn.BackgroundColor3=Color3.fromRGB(40,40,40)
	btn.BackgroundTransparency=0.2
	btn.Parent=clickJumpUI
	local cor1=InstanceNew("UICorner")
	cor1.CornerRadius=UDim.new(0,8)
	cor1.Parent=btn
	NAgui.draggerV2(btn)
	local tb=InstanceNew("TextBox")
	tb.Size=UDim2.new(0,120,0,40)
	tb.Position=UDim2.new(0.5,10,0,10)
	tb.Text="50"
	tb.PlaceholderText="JumpPower"
	tb.TextSize=16
	tb.TextColor3=Color3.new(1,1,1)
	tb.Font=Enum.Font.Gotham
	tb.BackgroundColor3=Color3.fromRGB(50,50,50)
	tb.BackgroundTransparency=0.2
	tb.Parent=clickJumpUI
	local cor2=InstanceNew("UICorner")
	cor2.CornerRadius=UDim.new(0,8)
	cor2.Parent=tb
	NAgui.draggerV2(tb)
	local jumpPowerNumber=50
	tb.FocusLost:Connect(function(enterPressed)
		local n=tonumber(tb.Text)
		if n then jumpPowerNumber=n else tb.Text=tostring(jumpPowerNumber) end
	end)
	MouseButtonFix(btn,function()
		clickJumpEnabled=not clickJumpEnabled
		btn.Text=clickJumpEnabled and "SetJump: ON" or "SetJump: OFF"
	end)
	NAlib.connect("clickjump_mouse",mouse.Button1Down:Connect(function()
		if not clickJumpEnabled then return end
		local hit=mouse.Target
		if hit and hit.Parent and CheckIfNPC(hit.Parent) then
			local hum=getPlrHum(hit.Parent)
			if hum then hum.JumpPower=jumpPowerNumber end
		end
	end))
end)

cmd.add({"unclicknpcjp","uncnpcjp"},{"unclicknpcjp","Disable clicknpcjp"},function()
	clickJumpEnabled=false
	if clickJumpUI then clickJumpUI:Destroy() end
	NAlib.disconnect("clickjump_mouse")
end)

--[[ FUNCTIONALITY ]]--
localPlayer.Chatted:Connect(function(str)
	NAlib.parseCommand(str)
	NAmanage.ExecuteBindings("OnChatted", str)
end)

--[[ Admin Player]]
function IsAdminAndRun(Message, Player)
	if Admin[Player.UserId] or isRelAdmin(Player) then
		NAlib.parseCommand(Message, Player)
	end
end

function CheckPermissions(Player)
	Player.Chatted:Connect(function(Message)
		IsAdminAndRun(Message,Player)
	end)
end

--[[function Getmodel(id)
	local ob23e232323=nil
	s,r=NACaller(function()
		ob23e232323=game:GetObjects(id)[1]
	end)
	if s and ob23e232323 then
		return ob23e232323
	end
	Wait(1)
	warn("retrying")
	return Getmodel(id)
end]]

--[[ GUI VARIABLES ]]--
repeat
	local NASUC, resexy = pcall(function()
		return loadstring(game:HttpGet(opt.NAUILOADER))()
	end)

	if NASUC then
		NAStuff.NASCREENGUI = resexy
	else
		warn(math.random(1,999999).." | Failed to load UI module: "..resexy.." | retrying...")
		Wait(.3)
	end
until NAStuff.NASCREENGUI
local rPlayer=Players:FindFirstChildWhichIsA("Player")
local coreGuiProtection={}
if not RunService:IsStudio() then
else
	repeat Wait() until player:FindFirstChild("AdminUI",true)
	NAStuff.NASCREENGUI=player:FindFirstChild("AdminUI",true)
end
--repeat Wait() until ScreenGui~=nil -- if it loads late then I'll just add this here

NaProtectUI(NAStuff.NASCREENGUI)

local NAUIMANAGER = {
	description          = NAStuff.NASCREENGUI:FindFirstChild("Description");
	AUTOSCALER           = NAStuff.NASCREENGUI:FindFirstChild("AutoScale");
	cmdBar               = NAStuff.NASCREENGUI:FindFirstChild("CmdBar");
	centerBar            = NAStuff.NASCREENGUI:FindFirstChild("CmdBar")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("CenterBar");
	cmdInput             = NAStuff.NASCREENGUI:FindFirstChild("CmdBar")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("CenterBar")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("CenterBar"):FindFirstChild("Input");
	cmdAutofill          = NAStuff.NASCREENGUI:FindFirstChild("CmdBar")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("Autofill");
	cmdExample           = NAStuff.NASCREENGUI:FindFirstChild("CmdBar")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("Autofill")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("Autofill"):FindFirstChildWhichIsA("Frame");
	leftFill             = NAStuff.NASCREENGUI:FindFirstChild("CmdBar")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("LeftFill");
	rightFill            = NAStuff.NASCREENGUI:FindFirstChild("CmdBar")
		and NAStuff.NASCREENGUI:FindFirstChild("CmdBar"):FindFirstChild("RightFill");

	chatLogsFrame        = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs");
	chatLogs             = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")
		and NAStuff.NASCREENGUI:FindFirstChild("ChatLogs"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("ChatLogs"):FindFirstChild("Container"):FindFirstChild("Logs");
	chatExample          = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")
		and NAStuff.NASCREENGUI:FindFirstChild("ChatLogs"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("ChatLogs"):FindFirstChild("Container"):FindFirstChild("Logs")
		and NAStuff.NASCREENGUI:FindFirstChild("ChatLogs"):FindFirstChild("Container"):FindFirstChild("Logs"):FindFirstChildWhichIsA("TextLabel");

	NAconsoleFrame       = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole");
	NAconsoleLogs        = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container"):FindFirstChild("Logs");
	NAconsoleExample     = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container"):FindFirstChild("Logs")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container"):FindFirstChild("Logs"):FindFirstChildWhichIsA("TextLabel");
	NAcontainer          = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container");
	NAfilter             = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"):FindFirstChild("Container"):FindFirstChild("Filter");

	commandsFrame        = NAStuff.NASCREENGUI:FindFirstChild("Commands");
	commandsFilter       = NAStuff.NASCREENGUI:FindFirstChild("Commands")
		and NAStuff.NASCREENGUI:FindFirstChild("Commands"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("Commands"):FindFirstChild("Container"):FindFirstChild("Filter");
	commandsList         = NAStuff.NASCREENGUI:FindFirstChild("Commands")
		and NAStuff.NASCREENGUI:FindFirstChild("Commands"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("Commands"):FindFirstChild("Container"):FindFirstChild("List");
	commandExample       = NAStuff.NASCREENGUI:FindFirstChild("Commands")
		and NAStuff.NASCREENGUI:FindFirstChild("Commands"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("Commands"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("Commands"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("TextLabel");

	resizeFrame          = NAStuff.NASCREENGUI:FindFirstChild("Resizeable");
	ModalFixer           = NAStuff.NASCREENGUI:FindFirstChildWhichIsA("ImageButton");

	SettingsFrame        = NAStuff.NASCREENGUI:FindFirstChild("setsettings");
	SettingsContainer    = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container");
	SettingsList         = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List");
	SettingsButton       = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("Button");
	SettingsColorPicker  = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("ColorPicker");
	SettingsSectionTitle = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("SectionTitle");
	SettingsToggle       = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("Toggle");
	SettingsInput        = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("Input");
	SettingsKeybind      = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("Keybind");
	SettingsSlider       = NAStuff.NASCREENGUI:FindFirstChild("setsettings")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("setsettings"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("Slider");
	WaypointFrame        = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint");
	WaypointContainer    = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container");
	WaypointList         = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container"):FindFirstChild("List");
	filterBox             = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container"):FindFirstChildWhichIsA("TextBox");
	WPFrame       = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container"):FindFirstChild("List")
		and NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"):FindFirstChild("Container"):FindFirstChild("List"):FindFirstChild("WP");
	BindersFrame        = NAStuff.NASCREENGUI:FindFirstChild("binders");
	BindersContainer    = NAStuff.NASCREENGUI:FindFirstChild("binders")
		and NAStuff.NASCREENGUI:FindFirstChild("binders"):FindFirstChild("Container");
	BindersList         = NAStuff.NASCREENGUI:FindFirstChild("binders")
		and NAStuff.NASCREENGUI:FindFirstChild("binders"):FindFirstChild("Container")
		and NAStuff.NASCREENGUI:FindFirstChild("binders"):FindFirstChild("Container"):FindFirstChild("List");
}

local resizeXY={
	Top = {Vector2.new(0,-1),    Vector2.new(0,-1),    "rbxassetid://2911850935"},
	Bottom = {Vector2.new(0,1),    Vector2.new(0,0),    "rbxassetid://2911850935"},
	Left = {Vector2.new(-1,0),    Vector2.new(1,0),    "rbxassetid://2911851464"},
	Right = {Vector2.new(1,0),    Vector2.new(0,0),    "rbxassetid://2911851464"},

	TopLeft = {Vector2.new(-1,-1),    Vector2.new(1,-1),    "rbxassetid://2911852219"},
	TopRight = {Vector2.new(1,-1),    Vector2.new(0,-1),    "rbxassetid://2911851859"},
	BottomLeft = {Vector2.new(-1,1),    Vector2.new(1,0),    "rbxassetid://2911851859"},
	BottomRight = {Vector2.new(1,1),    Vector2.new(0,0),    "rbxassetid://2911852219"},
}

local fillSizes={
	right=NAUIMANAGER.rightFill.Size,
	left=NAUIMANAGER.leftFill.Size,
}

if NAUIMANAGER.cmdExample then
	NAUIMANAGER.cmdExample.Parent = nil
end

if NAUIMANAGER.chatExample then
	NAUIMANAGER.chatExample.Parent = nil
end

if NAUIMANAGER.NAconsoleExample then
	NAUIMANAGER.NAconsoleExample.Parent = nil
end

if NAUIMANAGER.commandExample then
	NAUIMANAGER.commandExample.Parent = nil
end

if NAUIMANAGER.resizeFrame then
	NAUIMANAGER.resizeFrame.Parent = nil
end

if NAUIMANAGER.SettingsButton then
	NAUIMANAGER.SettingsButton.Parent = nil
end

if NAUIMANAGER.SettingsColorPicker then
	NAUIMANAGER.SettingsColorPicker.Parent = nil
end

if NAUIMANAGER.SettingsSectionTitle then
	NAUIMANAGER.SettingsSectionTitle.Parent = nil
end

if NAUIMANAGER.SettingsToggle then
	NAUIMANAGER.SettingsToggle.Parent = nil
end

if NAUIMANAGER.SettingsInput then
	NAUIMANAGER.SettingsInput.Parent = nil
end

if NAUIMANAGER.SettingsKeybind then
	NAUIMANAGER.SettingsKeybind.Parent = nil
end

if NAUIMANAGER.SettingsSlider then
	NAUIMANAGER.SettingsSlider.Parent = nil
end

if NAUIMANAGER.WPFrame then
	NAUIMANAGER.WPFrame.Parent = nil
end

local templates = {
	Button = NAUIMANAGER.SettingsButton;
	ColorPicker = NAUIMANAGER.SettingsColorPicker;
	SectionTitle = NAUIMANAGER.SettingsSectionTitle;
	Toggle = NAUIMANAGER.SettingsToggle;
	Input = NAUIMANAGER.SettingsInput;
	Keybind = NAUIMANAGER.SettingsKeybind;
	Slider = NAUIMANAGER.SettingsSlider;
	WaypointerFrame = NAUIMANAGER.WPFrame;
	Index = 0;
}

Spawn(function()
	for _,v in ipairs(NAStuff.NASCREENGUI:GetDescendants()) do
		if v:IsA("UIStroke") then
			Insert(NACOLOREDELEMENTS, v)
		end
	end
end)

local predictionInput = NAUIMANAGER.cmdInput:Clone()
predictionInput.Name = "predictionInput"
predictionInput.TextEditable = false
predictionInput.TextTransparency = 1
predictionInput.TextColor3 = Color3.fromRGB(180, 180, 180)
predictionInput.BackgroundTransparency = 1
predictionInput.ZIndex = NAUIMANAGER.cmdInput.ZIndex + 1
predictionInput.Parent = NAUIMANAGER.cmdInput.Parent
predictionInput.PlaceholderText = ""

opt.NAAUTOSCALER = NAUIMANAGER.AUTOSCALER

	--[[NACaller(function()
		for i,v in pairs(NAStuff.NASCREENGUI:GetDescendants()) do
			coreGuiProtection[v]=rPlayer.Name
		end
		NAStuff.NASCREENGUI.DescendantAdded:Connect(function(v)
			coreGuiProtection[v]=rPlayer.Name
		end)
		coreGuiProtection[NAStuff.NASCREENGUI]=rPlayer.Name
	
		local meta=getrawmetatable(game)
		local tostr=meta.__tostring
		setreadonly(meta,false)
		meta.__tostring=newcclosure(function(t)
			if coreGuiProtection[t] and not checkcaller() then
				return coreGuiProtection[t]
			end
			return tostr(t)
		end)
	end)
	if not RunService:IsStudio() then
		local newGui=COREGUI:FindFirstChildWhichIsA("NAStuff.NASCREENGUI")
		newGui.DescendantAdded:Connect(function(v)
			coreGuiProtection[v]=rPlayer.Name
		end)
		for i,v in pairs(NAStuff.NASCREENGUI:GetChildren()) do
			v.Parent=newGui
		end
		NAStuff.NASCREENGUI=newGui
	end]]

cmd.add({"rename"}, {"rename <text>", "Renames the admin UI placeholder to the given name"}, function(...)
	local newName = Concat({...}, " ")
	adminName = newName
	if NAUIMANAGER.cmdInput and NAUIMANAGER.cmdInput.PlaceholderText then
		NAUIMANAGER.cmdInput.PlaceholderText = newName
	end
end, true)

cmd.add({"unname"}, {"unname", "Resets the admin UI placeholder name to default"}, function(...)
	adminName = getgenv().NATestingVer and "NA Testing" or "Nameless Admin"
	if NAUIMANAGER.cmdInput and NAUIMANAGER.cmdInput.PlaceholderText then
		NAUIMANAGER.cmdInput.PlaceholderText = isAprilFools() and '🤡 '..adminName..curVer..' 🤡' or getSeasonEmoji()..' '..adminName..curVer..' '..getSeasonEmoji()
	end
end, false)

--[[ GUI FUNCTIONS ]]--
NAgui.txtSize=function(ui,x,y)
	local textService=TextService
	return textService:GetTextSize(ui.Text,ui.TextSize,ui.Font,Vector2.new(x,y))
end
NAgui.commands = function()
	local cFrame, cList = NAUIMANAGER.commandsFrame, NAUIMANAGER.commandsList

	if not cFrame.Visible then
		cFrame.Visible = true
		cList.CanvasSize = UDim2.new(0, 0, 0, 0)
	end

	for _, v in ipairs(cList:GetChildren()) do
		if v:IsA("TextLabel") then v:Destroy() end
	end

	local yOffset = 5
	for cmdName, tbl in pairs(cmds.Commands) do
		local Cmd = NAUIMANAGER.commandExample:Clone()
		Cmd.Parent = cList
		Cmd.Name = cmdName
		Cmd.Text = " "..tbl[2][1]
		Cmd.Position = UDim2.new(0, 0, 0, yOffset)

		Cmd.MouseEnter:Connect(function()
			NAUIMANAGER.description.Visible = true
			NAUIMANAGER.description.Text = tbl[2][2]
		end)

		Cmd.MouseLeave:Connect(function()
			if NAUIMANAGER.description.Text == tbl[2][2] then
				NAUIMANAGER.description.Visible = false
				NAUIMANAGER.description.Text = ""
			end
		end)

		yOffset = yOffset + 20
	end

	cList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	--cFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
	NAmanage.centerFrame(cFrame)
end
NAgui.chatlogs = function()
	if NAUIMANAGER.chatLogsFrame then
		if not NAUIMANAGER.chatLogsFrame.Visible then
			NAUIMANAGER.chatLogsFrame.Visible = true
		end
		--NAUIMANAGER.chatLogsFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.chatLogsFrame)
	end
end
NAgui.doModal = function(v)
	NAUIMANAGER.ModalFixer.Modal = v
end
NAgui.consoleeee = function()
	if NAUIMANAGER.NAconsoleFrame then
		if not NAUIMANAGER.NAconsoleFrame.Visible then
			NAUIMANAGER.NAconsoleFrame.Visible = true
		end
		--NAUIMANAGER.NAconsoleFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.NAconsoleFrame)
	end
end
NAgui.settingss = function()
	if NAUIMANAGER.SettingsFrame then
		if not NAUIMANAGER.SettingsFrame.Visible then
			NAUIMANAGER.SettingsFrame.Visible = true
		end
		--NAUIMANAGER.SettingsFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.SettingsFrame)
	end
end
NAgui.waypointers = function()
	if NAUIMANAGER.WaypointFrame then
		if not NAUIMANAGER.WaypointFrame.Visible then
			NAUIMANAGER.WaypointFrame.Visible = true
		end
		--NAUIMANAGER.WaypointFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.WaypointFrame)
	end
end
NAgui.eventbinders = function()
	if NAUIMANAGER.BindersFrame then
		if not NAUIMANAGER.BindersFrame.Visible then
			NAUIMANAGER.BindersFrame.Visible = true
		end
		--NAUIMANAGER.BindersFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
		NAmanage.centerFrame(NAUIMANAGER.BindersFrame)
	end
end
NAgui.tween = function(obj, style, direction, duration, goal, callback)
	style = style or "Sine"
	direction = direction or "Out"
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle[style], Enum.EasingDirection[direction])
	local tween = TweenService:Create(obj, tweenInfo, goal)
	if callback then tween.Completed:Connect(callback) end
	tween:Play()
	return tween
end
NAgui.resizeable = function(ui, min, max)
	min = min or Vector2.new(ui.AbsoluteSize.X, ui.AbsoluteSize.Y)
	max = max or Vector2.new(5000, 5000)

	local screenGui = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui.Parent
	local scale = NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or 1

	local rgui = NAUIMANAGER.resizeFrame:Clone()
	rgui.Parent = ui

	local dragging = false
	local mode
	local UIPos
	local lastSize
	local lastPos = Vector2.new()

	local function updateResize(currentPos)
		local success, err = NACaller(function()
			if not dragging or not mode then return end

			local xy = resizeXY[mode.Name]
			if not xy then return end

			local parentSize = screenGui.AbsoluteSize
			local delta = (currentPos - lastPos) / scale

			local resizeDelta = Vector2.new(
				delta.X * xy[1].X,
				delta.Y * xy[1].Y
			)

			local newSize = Vector2.new(
				math.clamp(lastSize.X + resizeDelta.X, min.X, max.X),
				math.clamp(lastSize.Y + resizeDelta.Y, min.Y, max.Y)
			)

			ui.Size = UDim2.new(0, newSize.X, 0, newSize.Y)

			local deltaXScale = (lastSize.X - newSize.X) / parentSize.X
			local deltaYScale = (lastSize.Y - newSize.Y) / parentSize.Y

			local newXScale = UIPos.X.Scale
			local newYScale = UIPos.Y.Scale

			if xy[1].X < 0 then
				newXScale = newXScale + deltaXScale
			end

			if xy[1].Y < 0 then
				newYScale = newYScale + deltaYScale
			end

			ui.Position = UDim2.new(newXScale, 0, newYScale, 0)
		end)

		if not success then
			warn("Resize update failed:", err)
		end
	end

	NACaller(function()
		UserInputService.InputChanged:Connect(function(input)
			local success, err = NACaller(function()
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateResize(Vector2.new(input.Position.X, input.Position.Y))
				end
			end)
			if not success then warn("InputChanged error:", err) end
		end)
	end)

	NACaller(function()
		UserInputService.InputEnded:Connect(function(input)
			local success, err = NACaller(function()
				if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
					dragging = false
					mode = nil
					if mouse and mouse.Icon ~= "" then
						mouse.Icon = ""
					end
				end
			end)
			if not success then warn("InputEnded error:", err) end
		end)
	end)

	for _, button in pairs(rgui:GetChildren()) do
		NACaller(function()
			button.InputBegan:Connect(function(input)
				local success, err = NACaller(function()
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						mode = button
						dragging = true
						local currentPos = input.Position
						lastPos = Vector2.new(currentPos.X, currentPos.Y)
						lastSize = ui.AbsoluteSize
						UIPos = ui.Position
					end
				end)
				if not success then warn("InputBegan error:", err) end
			end)
		end)

		NACaller(function()
			button.InputEnded:Connect(function(input)
				local success, err = NACaller(function()
					if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and mode == button then
						dragging = false
						mode = nil
						if mouse and resizeXY[button.Name] and mouse.Icon == resizeXY[button.Name][3] then
							mouse.Icon = ""
						end
					end
				end)
				if not success then warn("InputEnded error:", err) end
			end)
		end)

		NACaller(function()
			button.MouseEnter:Connect(function()
				local success, err = NACaller(function()
					if resizeXY[button.Name] and mouse then
						mouse.Icon = resizeXY[button.Name][3]
					end
				end)
				if not success then warn("MouseEnter error:", err) end
			end)
		end)

		NACaller(function()
			button.MouseLeave:Connect(function()
				local success, err = NACaller(function()
					if not dragging and resizeXY[button.Name] and mouse and mouse.Icon == resizeXY[button.Name][3] then
						mouse.Icon = ""
					end
				end)
				if not success then warn("MouseLeave error:", err) end
			end)
		end)
	end

	return function()
		NACaller(function()
			rgui:Destroy()
		end)
	end
end

NAmanage.UpdateWaypointList=function()
	local list = NAUIMANAGER.WaypointList
	local rawFilter = NAUIMANAGER.filterBox and NAUIMANAGER.filterBox.Text or ""
	local filterText = rawFilter:lower()
	for _, child in ipairs(list:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	for name, entry in pairs(Waypoints) do
		if filterText == "" or name:lower():find(filterText, 1, true) then
			local row = NAUIMANAGER.WPFrame:Clone()
			row.Name = name
			row.Parent = list
			local nameBtn = row:FindFirstChildWhichIsA("TextButton")
			if nameBtn then nameBtn.Text = name end
			local actionFrame = row:FindFirstChildWhichIsA("Frame")
			if actionFrame then
				local copyBtn = actionFrame:FindFirstChild("CopyBtn")
				local delBtn = actionFrame:FindFirstChild("DelBtn")
				local tpBtn = actionFrame:FindFirstChild("TPBtn")
				if copyBtn then
					copyBtn.MouseButton1Click:Connect(function()
						local comps = entry.Components
						local cf = CFrame.new(unpack(comps))
						if setclipboard then
							pcall(setclipboard, tostring(cf))
							DebugNotif("Copied "..name)
						else
							DebugNotif("Copy not supported")
						end
					end)
				end
				if delBtn then
					delBtn.MouseButton1Click:Connect(function()
						Waypoints[name] = nil
						NAmanage.SaveWaypoints()
						NAmanage.UpdateWaypointList()
						DebugNotif("Removed '"..name.."'")
					end)
				end
				if tpBtn then
					tpBtn.MouseButton1Click:Connect(function()
						local comps = entry.Components
						local cf = CFrame.new(unpack(comps))
						local char = getChar()
						if char then
							char:PivotTo(cf)
						end
					end)
				end
			end
		end
	end
end

NAgui.addButton = function(label, callback)
	if not NAUIMANAGER.SettingsList then return end
	local button = templates.Button:Clone()
	button.Title.Text = label
	button.Parent = NAUIMANAGER.SettingsList
	button.LayoutOrder = templates.Index
	templates.Index = templates.Index + 1

	MouseButtonFix(button.Interact,function()
		pcall(callback)
	end)
end

NAgui.addSection = function(titleText)
	if not NAUIMANAGER.SettingsList then return end
	local section = templates.SectionTitle:Clone()
	section.Title.Text = titleText
	section.Parent = NAUIMANAGER.SettingsList
	section.LayoutOrder = templates.Index
	templates.Index = templates.Index + 1
end

NAgui.addToggle = function(label, defaultValue, callback)
	if not NAUIMANAGER.SettingsList then return end
	local toggle = templates.Toggle:Clone()
	local switch = toggle:FindFirstChild("Switch")
	local indicator = switch and switch:FindFirstChild("Indicator")
	local stroke = indicator and indicator:FindFirstChild("UIStroke")

	toggle.Title.Text = label
	toggle.Parent = NAUIMANAGER.SettingsList
	toggle.LayoutOrder = templates.Index
	templates.Index = templates.Index + 1

	local state = defaultValue

	local function updateVisual()
		if state then
			indicator.Position = UDim2.new(1, -20, 0.5, 0)
			indicator.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
			stroke.Color = Color3.fromRGB(50, 255, 80)
		else
			indicator.Position = UDim2.new(1, -40, 0.5, 0)
			indicator.BackgroundColor3 = Color3.fromRGB(111, 111, 121)
			stroke.Color = Color3.fromRGB(80, 80, 80)
		end
	end

	updateVisual()

	MouseButtonFix(toggle.Interact,function()
		state = not state
		updateVisual()
		pcall(function()
			callback(state)
		end)
	end)
end

NAgui.addColorPicker = function(label, defaultColor, callback)
	if not NAUIMANAGER.SettingsList then return end
	local picker = templates.ColorPicker:Clone()
	picker.Title.Text = label
	picker.Parent = NAUIMANAGER.SettingsList
	picker.LayoutOrder = templates.Index
	templates.Index = templates.Index + 1

	local background = picker.CPBackground
	local display = background.Display
	local main = background.MainCP
	local slider = picker.ColorSlider
	local rgb = picker.RGB
	local hex = picker.HexInput

	local h, s, v = defaultColor:ToHSV()
	local draggingMain = false
	local draggingSlider = false

	main.MainPoint.AnchorPoint = Vector2.new(0.5, 0.5)
	slider.SliderPoint.AnchorPoint = Vector2.new(0.5, 0.5)

	local function updateUI(pushToInputs)
		local color = Color3.fromHSV(h, s, v)
		display.BackgroundColor3 = color
		background.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		main.MainPoint.Position = UDim2.new(s, 0, 1 - v, 0)
		slider.SliderPoint.Position = UDim2.new(h, 0, 0.5, 0)

		local r = math.floor(color.R * 255 + 0.5)
		local g = math.floor(color.G * 255 + 0.5)
		local b = math.floor(color.B * 255 + 0.5)

		if pushToInputs then
			rgb.RInput.InputBox.Text = tostring(r)
			rgb.GInput.InputBox.Text = tostring(g)
			rgb.BInput.InputBox.Text = tostring(b)
			hex.InputBox.Text = Format("#%02X%02X%02X", r, g, b)
		end

		pcall(function()
			callback(color)
		end)
	end

	local function parseRGBInputs()
		local r = tonumber(rgb.RInput.InputBox.Text) or 0
		local g = tonumber(rgb.GInput.InputBox.Text) or 0
		local b = tonumber(rgb.BInput.InputBox.Text) or 0

		r = math.clamp(r, 0, 255)
		g = math.clamp(g, 0, 255)
		b = math.clamp(b, 0, 255)

		h, s, v = Color3.fromRGB(r, g, b):ToHSV()
		updateUI(false)
	end

	rgb.RInput.InputBox.FocusLost:Connect(parseRGBInputs)
	rgb.GInput.InputBox.FocusLost:Connect(parseRGBInputs)
	rgb.BInput.InputBox.FocusLost:Connect(parseRGBInputs)

	hex.InputBox.FocusLost:Connect(function()
		local text = hex.InputBox.Text:gsub("#", ""):upper()
		if text:match("^[0-9A-F]+$") and #text == 6 then
			local r = tonumber(text:sub(1, 2), 16)
			local g = tonumber(text:sub(3, 4), 16)
			local b = tonumber(text:sub(5, 6), 16)
			if r and g and b then
				h, s, v = Color3.fromRGB(r, g, b):ToHSV()
				updateUI(true)
			end
		else
			hex.InputBox.Text = Format("#%02X%02X%02X", math.floor(Color3.fromHSV(h,s,v).R * 255 + 0.5), math.floor(Color3.fromHSV(h,s,v).G * 255 + 0.5), math.floor(Color3.fromHSV(h,s,v).B * 255 + 0.5))
		end
	end)

	local mouse = lp:GetMouse()

	local function setupDragDetection(obj, dragType)
		obj.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				if dragType == "main" then
					draggingMain = true
				elseif dragType == "slider" then
					draggingSlider = true
				end
			end
		end)
	end

	setupDragDetection(main, "main")
	setupDragDetection(main.MainPoint, "main")
	setupDragDetection(slider, "slider")
	setupDragDetection(slider.SliderPoint, "slider")

	SafeGetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingMain = false
			draggingSlider = false
		end
	end)

	SafeGetService("RunService").RenderStepped:Connect(function()
		if draggingMain then
			local relX = math.clamp(mouse.X - main.AbsolutePosition.X, 0, main.AbsoluteSize.X)
			local relY = math.clamp(mouse.Y - main.AbsolutePosition.Y, 0, main.AbsoluteSize.Y)
			s = relX / main.AbsoluteSize.X
			v = 1 - (relY / main.AbsoluteSize.Y)
			updateUI(true)
		end
		if draggingSlider then
			local relX = math.clamp(mouse.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
			h = relX / slider.AbsoluteSize.X
			updateUI(true)
		end
	end)

	updateUI(true)
end

NAgui.addInput = function(label, placeholder, defaultText, callback)
	local input = templates.Input:Clone()
	input.Title.Text = label
	input.InputFrame.InputBox.Text = defaultText or ""
	input.InputFrame.InputBox.PlaceholderText = placeholder or ""

	input.LayoutOrder = templates.Index
	templates.Index = templates.Index + 1
	input.Parent = NAUIMANAGER.SettingsList

	input.InputFrame.InputBox.FocusLost:Connect(function()
		pcall(callback, input.InputFrame.InputBox.Text)
	end)

	input.InputFrame.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
		input.InputFrame:TweenSize(
			UDim2.new(0, input.InputFrame.InputBox.TextBounds.X + 24, 0, 30),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Exponential,
			0.2,
			true
		)
	end)
end

NAgui.addKeybind = function(label, defaultKey, callback)
	local keybind = templates.Keybind:Clone()
	keybind.Title.Text = label
	keybind.KeybindFrame.KeybindBox.Text = defaultKey

	keybind.LayoutOrder = templates.Index
	templates.Index = templates.Index + 1
	keybind.Parent = NAUIMANAGER.SettingsList

	local capturing = false

	keybind.KeybindFrame.KeybindBox.Focused:Connect(function()
		capturing = true
		keybind.KeybindFrame.KeybindBox.Text = ""
	end)

	keybind.KeybindFrame.KeybindBox.FocusLost:Connect(function()
		capturing = false
		if keybind.KeybindFrame.KeybindBox.Text == "" then
			keybind.KeybindFrame.KeybindBox.Text = defaultKey
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if capturing and input.KeyCode ~= Enum.KeyCode.Unknown then
			local keyName = tostring(input.KeyCode):split(".")[3]
			keybind.KeybindFrame.KeybindBox:ReleaseFocus()
			keybind.KeybindFrame.KeybindBox.Text = keyName
			capturing = false
			pcall(callback, keyName)
		elseif not capturing and keybind.KeybindFrame.KeybindBox.Text ~= "" then
			if tostring(input.KeyCode) == "Enum.KeyCode."..keybind.KeybindFrame.KeybindBox.Text and not processed then
				pcall(callback)
			end
		end
	end)

	keybind.KeybindFrame.KeybindBox:GetPropertyChangedSignal("Text"):Connect(function()
		keybind.KeybindFrame:TweenSize(
			UDim2.new(0, keybind.KeybindFrame.KeybindBox.TextBounds.X + 24, 0, 30),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Exponential,
			0.2,
			true
		)
	end)
end

NAgui.addSlider = function(label, min, max, defaultValue, increment, suffix, callback)
	local slider = templates.Slider:Clone()
	slider.Title.Text = label

	slider.LayoutOrder = templates.Index
	templates.Index = templates.Index + 1
	slider.Parent = NAUIMANAGER.SettingsList

	local interact = slider.Main.Interact
	local progress = slider.Main.Progress
	local infoText = slider.Main.Information

	local dragging = false

	local function updateSliderValueFromPos(x)
		local relX = math.clamp(x - interact.AbsolutePosition.X, 0, interact.AbsoluteSize.X)
		local percent = relX / interact.AbsoluteSize.X
		local value = math.floor((min + (max - min) * percent) / increment + 0.5) * increment
		value = math.clamp(value, min, max)

		progress.Size = UDim2.new(percent, 0, 1, 0)
		infoText.Text = tostring(value)..(suffix or "")
		pcall(callback, value)
	end

	interact.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	interact.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if dragging then
			updateSliderValueFromPos(UserInputService:GetMouseLocation().X)
		end
	end)

	local initialPercent = (defaultValue - min) / (max - min)
	progress.Size = UDim2.new(initialPercent, 0, 1, 0)
	infoText.Text = tostring(defaultValue)..(suffix or "")
end

NAgui.dragger = function(ui, dragui)
	dragui = dragui or ui
	local UserInputService = SafeGetService("UserInputService")
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local success, err = NACaller(function()
			local delta = input.Position - dragStart
			local screenSize = ui.Parent.AbsoluteSize
			local newXScale = startPos.X.Scale + (startPos.X.Offset + delta.X) / screenSize.X
			local newYScale = startPos.Y.Scale + (startPos.Y.Offset + delta.Y) / screenSize.Y
			ui.Position = UDim2.new(newXScale, 0, newYScale, 0)
		end)
		if not success then
			warn("[Dragger] update error:", err)
		end
	end

	NACaller(function()
		dragui.InputBegan:Connect(function(input)
			local success, err = NACaller(function()
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragStart = input.Position
					startPos = ui.Position

					NACaller(function()
						input.Changed:Connect(function()
							local ok, innerErr = NACaller(function()
								if input.UserInputState == Enum.UserInputState.End then
									dragging = false
								end
							end)
							if not ok then warn("[Dragger] input.Changed error:", innerErr) end
						end)
					end)
				end
			end)
			if not success then warn("[Dragger] InputBegan error:", err) end
		end)
	end)

	NACaller(function()
		dragui.InputChanged:Connect(function(input)
			local success, err = NACaller(function()
				if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
					dragInput = input
				end
			end)
			if not success then warn("[Dragger] InputChanged error:", err) end
		end)
	end)

	NACaller(function()
		UserInputService.InputChanged:Connect(function(input)
			local success, err = NACaller(function()
				if input == dragInput and dragging then
					update(input)
				end
			end)
			if not success then warn("[Dragger] UserInputService.InputChanged error:", err) end
		end)
	end)

	local success, err = NACaller(function()
		ui.Active = true
	end)
	if not success then warn("[Dragger] Set Active error:", err) end
end

NAgui.draggerV2 = function(ui, dragui)
	dragui = dragui or ui
	local connName = "DraggerV2_"..ui:GetDebugId()
	NAlib.disconnect(connName)
	local UserInputService = SafeGetService("UserInputService")
	local screenGui = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui.Parent
	local dragging, dragInput, dragStart, startPos
	local anchor = ui.AnchorPoint

	local function safeClamp(v, lo, hi)
		if hi < lo then hi = lo end
		return math.clamp(v, lo, hi)
	end

	local function update(input)
		local ok, err = NACaller(function()
			local p = screenGui.AbsoluteSize
			local s = ui.AbsoluteSize
			if p.X <= 0 or p.Y <= 0 then return end
			local startX = startPos.X.Scale * p.X + startPos.X.Offset
			local startY = startPos.Y.Scale * p.Y + startPos.Y.Offset
			local dx = input.Position.X - dragStart.X
			local dy = input.Position.Y - dragStart.Y
			local minX = anchor.X * s.X
			local maxX = p.X - (1 - anchor.X) * s.X
			local minY = anchor.Y * s.Y
			local maxY = p.Y - (1 - anchor.Y) * s.Y
			local nx = safeClamp(startX + dx, minX, maxX)
			local ny = safeClamp(startY + dy, minY, maxY)
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0)
		end)
		if not ok then warn("[DraggerV2] update error:", err) end
	end

	NAlib.connect(connName, dragui.InputBegan:Connect(function(input)
		local ok, err = NACaller(function()
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = ui.Position
				local c = input.Changed:Connect(function()
					local ok2, err2 = NACaller(function()
						if input.UserInputState == Enum.UserInputState.End then dragging = false end
					end)
					if not ok2 then warn("[DraggerV2] input.Changed error:", err2) end
				end)
				NAlib.connect(connName, c)
			end
		end)
		if not ok then warn("[DraggerV2] InputBegan error:", err) end
	end))

	NAlib.connect(connName, dragui.InputChanged:Connect(function(input)
		local ok, err = NACaller(function()
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		if not ok then warn("[DraggerV2] InputChanged error:", err) end
	end))

	NAlib.connect(connName, UserInputService.InputChanged:Connect(function(input)
		local ok, err = NACaller(function()
			if input == dragInput and dragging then update(input) end
		end)
		if not ok then warn("[DraggerV2] UserInputService.InputChanged error:", err) end
	end))

	local function onScreenSizeChanged()
		local ok, err = NACaller(function()
			local p = screenGui.AbsoluteSize
			local s = ui.AbsoluteSize
			if p.X <= 0 or p.Y <= 0 then return end
			local curr = ui.Position
			local absX = curr.X.Scale * p.X + curr.X.Offset
			local absY = curr.Y.Scale * p.Y + curr.Y.Offset
			local minX = anchor.X * s.X
			local maxX = p.X - (1 - anchor.X) * s.X
			local minY = anchor.Y * s.Y
			local maxY = p.Y - (1 - anchor.Y) * s.Y
			local nx = safeClamp(absX, minX, maxX)
			local ny = safeClamp(absY, minY, maxY)
			ui.Position = UDim2.new(nx / p.X, 0, ny / p.Y, 0)
		end)
		if not ok then warn("[DraggerV2] Screen size update error:", err) end
	end

	NAlib.connect(connName, screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(onScreenSizeChanged))

	if ui and NAlib.isProperty(ui, "Active") then
		NAlib.setProperty(ui, "Active", true)
	end
	if dragui and NAlib.isProperty(dragui, "Active") then
		NAlib.setProperty(dragui, "Active", true)
	end
end

NAgui.menu = function(menu)
	if menu:IsA("Frame") then menu.AnchorPoint = Vector2.new(0, 0) end
	local exitButton = menu:FindFirstChild("Exit", true)
	local minimizeButton = menu:FindFirstChild("Minimize", true)
	local minimized = false
	local isAnimating = false
	local sizeX = InstanceNew("IntValue", menu)
	local sizeY = InstanceNew("IntValue", menu)

	local function toggleMinimize()
		if isAnimating then return end
		minimized = not minimized
		isAnimating = true

		if minimized then
			sizeX.Value = menu.Size.X.Offset
			sizeY.Value = menu.Size.Y.Offset
			NAgui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, sizeX.Value, 0, 35)})
				.Completed:Connect(function()
					isAnimating = false
				end)
		else
			NAgui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, sizeX.Value, 0, sizeY.Value)})
				.Completed:Connect(function()
					isAnimating = false
				end)
		end
	end

	MouseButtonFix(minimizeButton, toggleMinimize)
	MouseButtonFix(exitButton, function()
		menu.Visible = false
	end)
	NAgui.draggerV2(menu, menu.Topbar)
	menu.Visible = false
end

NAgui.menuv2 = function(menu)
	NACaller(function()
		if menu:IsA("Frame") then
			menu.AnchorPoint = Vector2.new(0, 0)
		end
	end)

	local exitButton = menu:FindFirstChild("Exit", true)
	local minimizeButton = menu:FindFirstChild("Minimize", true)
	local clearButton = menu:FindFirstChild("Clear", true)

	local minimized = false
	local isAnimating = false
	local sizeX = InstanceNew("IntValue", menu)
	local sizeY = InstanceNew("IntValue", menu)

	local function toggleMinimize()
		local success, err = NACaller(function()
			if isAnimating then return end
			minimized = not minimized
			isAnimating = true

			if minimized then
				sizeX.Value = menu.Size.X.Offset
				sizeY.Value = menu.Size.Y.Offset
				NAgui.tween(menu, "Quart", "Out", 0.5, {
					Size = UDim2.new(0, sizeX.Value, 0, 35)
				}).Completed:Connect(function()
					isAnimating = false
				end)
			else
				NAgui.tween(menu, "Quart", "Out", 0.5, {
					Size = UDim2.new(0, sizeX.Value, 0, sizeY.Value)
				}).Completed:Connect(function()
					isAnimating = false
				end)
			end
		end)
		if not success then warn("menuv2 toggleMinimize error:", err) end
	end

	NACaller(function()
		MouseButtonFix(minimizeButton, toggleMinimize)
	end)

	NACaller(function()
		MouseButtonFix(exitButton, function()
			local ok, err = NACaller(function()
				menu.Visible = false
			end)
			if not ok then warn("menuv2 exit button error:", err) end
		end)
	end)

	if clearButton then
		NACaller(function()
			clearButton.Visible = true
			MouseButtonFix(clearButton, function()
				local ok, err = NACaller(function()
					local container = menu:FindFirstChild("Container", true)
					if container then
						local scrollingFrame = container:FindFirstChildOfClass("ScrollingFrame")
						if scrollingFrame then
							local layout = scrollingFrame:FindFirstChildOfClass("UIListLayout", true)
							if layout then
								for _, v in ipairs(layout.Parent:GetChildren()) do
									if v:IsA("TextLabel") then
										v:Destroy()
									end
								end
							end
						end
					end
				end)
				if not ok then warn("menuv2 clear button error:", err) end
			end)
		end)
	end

	NACaller(function()
		NAgui.draggerV2(menu, menu.Topbar)
	end)

	NACaller(function()
		menu.Visible = false
	end)
end

NAgui.hideFill = function()
	for i, v in ipairs(CMDAUTOFILL) do
		if v:IsA("Frame") then
			v.Visible = false
		end
	end
end

NAgui.loadCMDS = function()
	for _, v in pairs(NAUIMANAGER.cmdAutofill:GetChildren()) do
		if v:IsA("GuiObject") and v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end
	CMDAUTOFILL = {}
	local i = 0
	for name, cmdData in pairs(cmds.Commands) do
		local usageText = "Unknown"
		local info = cmdData[2]
		if type(info) == "table" and #info >= 1 then
			usageText = info[1]
			local aliasesList = {}
			for alias, aliasCmdData in pairs(cmds.Aliases) do
				if aliasCmdData == cmdData or cmds.Commands[alias] == cmdData then
					Insert(aliasesList, alias)
				end
			end
			if #aliasesList > 0 then
				local listed = {}
				for word in usageText:gmatch("%w+") do
					listed[word:lower()] = true
				end
				local missing = {}
				for _, alias in ipairs(aliasesList) do
					if not listed[alias:lower()] then
						Insert(missing, alias)
					end
				end
				if #missing > 0 then
					usageText = usageText.." ("..Concat(missing, ", ")..")"
				end
			end
		end
		local btn = NAUIMANAGER.cmdExample:Clone()
		btn.Parent = NAUIMANAGER.cmdAutofill
		btn.Name = name
		btn.Input.Text = usageText
		i += 1
		Insert(CMDAUTOFILL, btn)
	end
	cmdNAnum = i
	NAgui.hideFill()
	NAmanage.rebuildIndex()
end

Spawn(function() -- plugin tester
	while Wait(2) do
		if countDictNA(cmds.Commands) ~= cmdNAnum then
			NAgui.loadCMDS()
		end
	end
end)

-- TopBar stuff idk (it's gonna be used in the future)
Spawn(function()
	repeat Wait(0.5) until TopBarApp.top and typeof(TopBarApp.top)=="Instance"

	local toggle=InstanceNew("ImageButton",TopBarApp.frame)
	toggle.Name="TopbarToggle"
	toggle.Size=UDim2.new(0,42,0,42)
	toggle.Position=UDim2.new(1,-50,0,10)
	toggle.AnchorPoint=Vector2.new(1,0)
	toggle.BackgroundColor3=Color3.new(0,0,0)
	toggle.BackgroundTransparency=0.3
	toggle.BorderSizePixel=0
	toggle.ClipsDescendants=true
	toggle.ZIndex=10
	InstanceNew("UICorner",toggle).CornerRadius=UDim.new(0.5,0)

	local CLOSED_IMG="rbxasset://textures/ui/MenuBar/icon_menu.png"
	local OPENED_IMG="rbxasset://textures/ui/ScreenshotHud/Close@2x.png"

	local iconMain=InstanceNew("ImageLabel",toggle)
	iconMain.AnchorPoint=Vector2.new(0.5,0.5)
	iconMain.Position=UDim2.new(0.5,0,0.5,0)
	iconMain.Size=UDim2.new(0.8,0,0.8,0)
	iconMain.BackgroundTransparency=1
	iconMain.ScaleType=Enum.ScaleType.Fit
	iconMain.Image=CLOSED_IMG
	iconMain.ZIndex=11

	local dropdown=InstanceNew("Frame",TopBarApp.frame)
	dropdown.Name="DropdownFrame"
	dropdown.Size=UDim2.new(0,0,0,42)
	dropdown.Visible=false
	dropdown.ClipsDescendants=true
	dropdown.BackgroundTransparency=1
	dropdown.ZIndex=5

	local bg=InstanceNew("Frame",dropdown)
	bg.Name="Background"
	bg.Size=UDim2.new(1,0,1,0)
	bg.BackgroundColor3=Color3.new(0,0,0)
	bg.BackgroundTransparency=1
	bg.ZIndex=6
	InstanceNew("UICorner",bg).CornerRadius=UDim.new(0.5,0)

	local container=InstanceNew("ScrollingFrame",dropdown)
	container.Name="Container"
	container.Size=UDim2.new(1,0,1,0)
	container.CanvasSize=UDim2.new(0,0,0,0)
	container.ScrollBarThickness=3
	container.ScrollingDirection=Enum.ScrollingDirection.X
	container.BackgroundTransparency=1
	container.ZIndex=7

	local layout=InstanceNew("UIListLayout",container)
	layout.FillDirection=Enum.FillDirection.Horizontal
	layout.HorizontalAlignment=Enum.HorizontalAlignment.Left
	layout.SortOrder=Enum.SortOrder.LayoutOrder
	layout.Padding=UDim.new(0,8)

	local BUTTON_SIZE=42
	local PADDING=layout.Padding.Offset
	local MAX_VISIBLE=4
	local MAX_WIDTH=MAX_VISIBLE*BUTTON_SIZE+(MAX_VISIBLE-1)*PADDING
	local MARGIN=4

	local DROPDOWN_TWEEN=TweenInfo.new(0.15,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
	local ICON_TWEEN=TweenInfo.new(0.05,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)

	local isOpen=false
	local currentSide="right"

	local buttonDefs={
		{name="settings",image="rbxasset://textures/CollisionGroupsEditor/manage.png",func=function()
			if NAUIMANAGER.SettingsFrame then
				NAUIMANAGER.SettingsFrame.Visible=not NAUIMANAGER.SettingsFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.SettingsFrame)
			end
		end},
		{name="cmds",image="rbxasset://textures/ui/TopBar/moreOff@2x.png",func=NAgui.commands},
		{name="chatlogs",image="rbxasset://textures/ui/Chat/ToggleChat@2x.png",func=function()
			if NAUIMANAGER.chatLogsFrame then
				NAUIMANAGER.chatLogsFrame.Visible=not NAUIMANAGER.chatLogsFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.chatLogsFrame)
			end
		end},
		{name="console",image="rbxasset://textures/Icon_Stream_Off.png",func=function()
			if NAUIMANAGER.NAconsoleFrame then
				NAUIMANAGER.NAconsoleFrame.Visible=not NAUIMANAGER.NAconsoleFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.NAconsoleFrame)
			end
		end},
		{name="waypp",image="rbxasset://textures/ui/waypoint.png",func=function()
			if NAUIMANAGER.WaypointFrame then
				NAUIMANAGER.WaypointFrame.Visible=not NAUIMANAGER.WaypointFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.WaypointFrame)
			end
		end},
		{name="bindd",image="rbxasset://textures/StudioToolbox/AssetConfig/creations@2x.png",func=function()
			if NAUIMANAGER.BindersFrame then
				NAUIMANAGER.BindersFrame.Visible=not NAUIMANAGER.BindersFrame.Visible
				NAmanage.centerFrame(NAUIMANAGER.BindersFrame)
			end
		end},
	}

	local childButtons={}
	local function buildButtons()
		for _,c in pairs(container:GetChildren())do
			if c:IsA("ImageButton")then c:Destroy()end
		end
		for i,def in ipairs(buttonDefs)do
			local btn=InstanceNew("ImageButton",container)
			btn.Name=Format("%sBtn",def.name)
			btn.Size=UDim2.new(0,BUTTON_SIZE,0,BUTTON_SIZE)
			btn.LayoutOrder=i
			btn.BackgroundColor3=Color3.new(0,0,0)
			btn.BackgroundTransparency=0.3
			btn.BorderSizePixel=0
			btn.ClipsDescendants=true
			btn.ZIndex=8
			InstanceNew("UICorner",btn).CornerRadius=UDim.new(0.5,0)
			local icon=InstanceNew("ImageLabel",btn)
			icon.Name="Icon"
			icon.AnchorPoint=Vector2.new(0.5,0.5)
			icon.Position=UDim2.new(0.5,0,0.5,0)
			icon.Size=UDim2.new(0.8,0,0.8,0)
			icon.BackgroundTransparency=1
			icon.ScaleType=Enum.ScaleType.Fit
			icon.Image=def.image
			icon.ZIndex=9
			childButtons[btn]=def.func
		end
	end
	buildButtons()

	NAlib.connect("contentSize",layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize=UDim2.new(0,layout.AbsoluteContentSize.X+PADDING,0,0)
	end))

	local function clampToggle()
		local fw=TopBarApp.frame.AbsoluteSize.X
		local bw=toggle.AbsoluteSize.X
		local off=math.clamp(toggle.Position.X.Offset,-(fw-bw),0)
		toggle.Position=UDim2.new(toggle.Position.X.Scale,off,toggle.Position.Y.Scale,toggle.Position.Y.Offset)
	end
	NAlib.connect("frameSize",TopBarApp.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(clampToggle))

	local function computeProps()
		local count=#buttonDefs
		local contentW=count*BUTTON_SIZE+(count-1)*PADDING
		for _,c in ipairs(dropdown:GetDescendants())do
			if c:IsA("UISizeConstraint")then
				contentW=math.clamp(contentW,c.MinSize.X,c.MaxSize.X)
			end
		end
		local showW=math.min(contentW,MAX_WIDTH)
		local frameX=TopBarApp.frame.AbsolutePosition.X
		local frameW=TopBarApp.frame.AbsoluteSize.X
		local tL=toggle.AbsolutePosition.X-frameX
		local tR=tL+toggle.AbsoluteSize.X
		local yOff=toggle.AbsolutePosition.Y-TopBarApp.frame.AbsolutePosition.Y
		if frameW-tR>=showW+MARGIN then
			return showW,UDim2.new(0,tR+MARGIN,0,yOff),"right"
		else
			return showW,UDim2.new(0,tL-MARGIN,0,yOff),"left"
		end
	end

	local function updatePosition()
		local w,pos,side=computeProps()
		dropdown.AnchorPoint=Vector2.new(side=="left"and 1 or 0,0)
		if dropdown.Visible then
			TweenService:Create(dropdown,DROPDOWN_TWEEN,{Position=pos}):Play()
			if side~=currentSide then
				TweenService:Create(iconMain,ICON_TWEEN,{Rotation=side=="left"and 180 or 0}):Play()
				currentSide=side
			end
		else
			dropdown.Position=pos
			iconMain.Rotation=side=="left"and 180 or 0
			currentSide=side
		end
	end
	updatePosition()

	local cam=workspace.CurrentCamera
	if cam then
		NAlib.connect("camSize",cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			updatePosition()
		end))
	end
	NAlib.connect("camChange",workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		cam=workspace.CurrentCamera
		NAlib.disconnect("camSize")
		if cam then
			NAlib.connect("camSize",cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				updatePosition()
			end))
		end
		updatePosition()
	end))

	local function animateIcon(img)
		local s=TweenService:Create(iconMain,ICON_TWEEN,{Size=UDim2.new(0,0,0,0)})
		s:Play();s.Completed:Wait()
		iconMain.Image=img
		TweenService:Create(iconMain,ICON_TWEEN,{Size=UDim2.new(0.8,0,0.8,0)}):Play()
	end

	local function makeDraggable(ui, dragui)
		dragui = dragui or ui
		local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

		dragui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or  input.UserInputType == Enum.UserInputType.Touch then
				dragging   = true
				dragStart  = input.Position
				startPos   = ui.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		dragui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or  input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				local fw, bw = TopBarApp.frame.AbsoluteSize.X, ui.AbsoluteSize.X
				local newX = math.clamp(startPos.X.Offset + delta.X, -(fw - bw), 0)
				ui.Position = UDim2.new(startPos.X.Scale, newX,startPos.Y.Scale, startPos.Y.Offset)
				if ui == toggle then
					clampToggle()
					updatePosition()
				end
			end
		end)

		ui.Active = true
	end
	makeDraggable(toggle)
	for btn, fn in pairs(childButtons) do makeDraggable(btn) end

	local function toggleDropdown()
		isOpen=not isOpen
		local w,pos,side=computeProps()
		dropdown.AnchorPoint=Vector2.new(side=="left"and 1 or 0,0)
		if isOpen then
			dropdown.Visible=true
			TweenService:Create(iconMain,ICON_TWEEN,{Rotation=side=="left"and 180 or 0}):Play()
			TweenService:Create(dropdown,DROPDOWN_TWEEN,{Position=pos,Size=UDim2.new(0,w,0,BUTTON_SIZE)}):Play()
			TweenService:Create(bg,DROPDOWN_TWEEN,{BackgroundTransparency=0.3}):Play()
			animateIcon(OPENED_IMG)
		else
			TweenService:Create(bg,DROPDOWN_TWEEN,{BackgroundTransparency=1}):Play()
			local t=TweenService:Create(dropdown,DROPDOWN_TWEEN,{Size=UDim2.new(0,0,0,BUTTON_SIZE)})
			t:Play();t.Completed:Wait()
			dropdown.Visible=false
			animateIcon(CLOSED_IMG)
		end
	end

	MouseButtonFix(toggle,toggleDropdown)
	for btn,fn in pairs(childButtons)do MouseButtonFix(btn,fn)end
end)

NAgui.barSelect = function(speed)
	speed = speed or 0.4

	NAUIMANAGER.centerBar.Size = UDim2.new(0, 0, 0, 0)

	NAgui.tween(NAUIMANAGER.centerBar, "Back", "Out", speed, {
		Size = UDim2.new(0, 280, 1, 10)
	})

	NAUIMANAGER.leftFill.Position = UDim2.new(0.5, 0, 0.5, 0)
	NAUIMANAGER.rightFill.Position = UDim2.new(0.5, 0, 0.5, 0)
	NAUIMANAGER.leftFill.Size = UDim2.new(0, 0, fillSizes.left.Y.Scale, fillSizes.left.Y.Offset)
	NAUIMANAGER.rightFill.Size = UDim2.new(0, 0, fillSizes.right.Y.Scale, fillSizes.right.Y.Offset)

	Wait(speed * 0.1)
	NAgui.tween(NAUIMANAGER.leftFill, "Quart", "Out", speed * 1.2, {
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = fillSizes.left
	})
	NAgui.tween(NAUIMANAGER.rightFill, "Quart", "Out", speed * 1.2, {
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = fillSizes.right
	})
end

NAgui.barDeselect = function(speed)
	speed = speed or 0.4

	NAgui.tween(NAUIMANAGER.centerBar, "Back", "InOut", speed, {
		Size = UDim2.new(0, 0, 0, 0)
	})

	NAgui.tween(NAUIMANAGER.leftFill, "Quart", "In", speed * 0.9, {
		Position = UDim2.new(-0.5, -125, 0.5, 0),
		Size = UDim2.new(0, 0, fillSizes.left.Y.Scale, fillSizes.left.Y.Offset)
	})
	NAgui.tween(NAUIMANAGER.rightFill, "Quart", "In", speed * 0.9, {
		Position = UDim2.new(1.5, 125, 0.5, 0),
		Size = UDim2.new(0, 0, fillSizes.right.Y.Scale, fillSizes.right.Y.Offset)
	})

	for i, v in ipairs(NAUIMANAGER.cmdAutofill:GetChildren()) do
		if v:IsA("Frame") then
			wrap(function()
				Wait(math.random(50, 120) / 1000)
				NAgui.tween(v, "Exponential", "In", 0.25, {
					Size = UDim2.new(0, 0, 0, 25)
				})
			end)
		end
	end
end

--[[ AUTOFILL SEARCHER ]]--
function fixStupidSearchGoober(cmdName, command)
	local dInfo = command and command[2] and command[2][1] or ""
	local func = command and command[1]

	local aliasSet = {}
	for alias, data in pairs(cmds.Aliases) do
		if data[1] == func then
			aliasSet[Lower(alias)] = true
		end
	end

	local main = cmdName and Lower(cmdName)
	local existingAliases = {}
	local prefix, aliasBlock = dInfo:match("^(.-)%s*%((.-)%)$")

	if aliasBlock then
		for a in aliasBlock:gmatch("[^,%s]+") do
			aliasSet[Lower(a)] = true
		end
	end

	local final = {}
	for alias in pairs(aliasSet) do
		if alias ~= main then
			Insert(final, alias)
		end
	end
	table.sort(final)

	local updTxt
	if prefix then
		updTxt = prefix.." ("..Concat(final, ", ")..")"
	else
		updTxt = dInfo
		if #final > 0 then
			updTxt = updTxt.." ("..Concat(final, ", ")..")"
		end
	end

	return updTxt, final
end

NAmanage.computeScore=function(entry,term,len)
	if entry.lowerName == term then return 1,entry.name end
	if Sub(entry.lowerName,1,len) == term then return 2,entry.name end
	if cmds.Aliases[term] and cmds.Aliases[term][1] == cmds.Commands[entry.name][1] then return 3,term end
	if cmds.NASAVEDALIASES[term] == entry.name then return 3,term end
	for alias,real in pairs(cmds.Aliases) do
		if real[1] == cmds.Commands[entry.name][1] and Sub(alias,1,len) == term then
			return 4,alias
		end
	end
	for alias,real in pairs(cmds.NASAVEDALIASES) do
		if real == entry.name and Sub(alias,1,len) == term then
			return 4,alias
		end
	end
	for _,a in ipairs(entry.extraAliases) do
		if a == term then return 3,entry.name end
		if Sub(a,1,len) == term then return 4,entry.name end
		if Find(a,term,1,true) then return 5,entry.name end
	end
	if len >= 2 then
		if Find(entry.lowerName,term,1,true) then return 6,entry.name end
		if Find(entry.searchable,term,1,true) then
			return 7,(cmds.Commands[entry.name][2] and cmds.Commands[entry.name][2][1] or entry.name)
		end
	end
end

NAmanage.performSearch=function(term)
	for _,f in ipairs(prevVisible) do f.Visible = false end
	table.clear(prevVisible)
	table.clear(results)
	if Match(term,"%s") or term == "" then
		predictionInput.Text = ""
		return
	end
	local len = #term
	for _,entry in ipairs(searchIndex) do
		local sc,txt = NAmanage.computeScore(entry,term,len)
		if sc then
			Insert(results,{frame=entry.frame,score=sc,text=txt,name=entry.name})
		end
	end
	table.sort(results,function(a,b)
		if a.score==b.score then return a.name<b.name end
		return a.score<b.score
	end)
	predictionInput.Text = (results[1] and results[1].text) or ""
	for i=1,math.min(5,#results)do
		local r=results[i]
		local f=r.frame
		Insert(prevVisible,f)
		f.Visible=true
		local w=math.sqrt(i)*125
		local y=(i-1)*28
		local pos=UDim2.new(0.5,w,0,y)
		local size=UDim2.new(0.5,w,0,25)
		if canTween then
			NAgui.tween(f,"Quint","Out",0.2,{Size=size,Position=pos})
		else
			f.Size=size
			f.Position=pos
		end
	end
end

NAgui.searchCommands = function()
	if NAlib.isConnected("SearchInput") then NAlib.disconnect("SearchInput") end
	NAlib.connect("SearchInput",NAUIMANAGER.cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
		local cleaned = Lower(GSub(NAUIMANAGER.cmdInput.Text,";",""))
		if cleaned==lastSearchText then return end
		lastSearchText=cleaned
		gen+=1
		local thisGen=gen
		Delay(0.08,function()
			if thisGen~=gen then return end
			NAmanage.performSearch(cleaned)
		end)
	end))
end

NAgui.loadCMDS()
NAgui.searchCommands()

--[[ OPEN THE COMMAND BAR ]]--
--[[mouse.KeyDown:Connect(function(k)
	if k:lower()==opt.prefix then
		Wait();
		NAgui.barSelect()
		cmdInput.Text=''
		cmdInput:CaptureFocus()
	end
end)]]
UserInputService.InputBegan:Connect(function(i, g)
	if g then return end
	local c = tostring(opt.prefix):sub(1,1)
	local k
	for _, v in pairs(Enum.KeyCode:GetEnumItems()) do
		if v.Name:lower() == c:lower() or v.Value == string.byte(c) then
			k = v
			break
		end
	end
	if i.KeyCode == k then
		Wait()
		if NAUIMANAGER.cmdInput then
			NAgui.barSelect()
			NAUIMANAGER.cmdInput.Text = ''

			while true do
				NAUIMANAGER.cmdInput:CaptureFocus()
				Wait(.00005)
				NAUIMANAGER.cmdInput.Text = ''
				if NAUIMANAGER.cmdInput:IsFocused() then break end
			end
		end
	end
end)

--[[ CLOSE THE COMMAND BAR ]]--
NAUIMANAGER.cmdInput.FocusLost:Connect(function(enter)
	if enter then
		local txt = NAUIMANAGER.cmdInput.Text
		if txt and #txt > 0 then
			wrap(function()
				NAlib.parseCommand(opt.prefix..txt)
			end)
		end
	end
	if predictionInput then
		predictionInput.Text = ""
	end
	Wait(.05)
	if not NAUIMANAGER.cmdInput:IsFocused() then NAgui.barDeselect() end
end)

NAUIMANAGER.cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
	NAgui.searchCommands()
end)

if NAUIMANAGER.filterBox then
	NAUIMANAGER.filterBox:GetPropertyChangedSignal("Text"):Connect(NAmanage.UpdateWaypointList)
end

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Tab
		and UserInputService:GetFocusedTextBox() == NAUIMANAGER.cmdInput then
		local predictionText = predictionInput and predictionInput.Text or ""
		if predictionText ~= "" then
			Wait()
			NAUIMANAGER.cmdInput.Text = predictionText
			NAUIMANAGER.cmdInput.CursorPosition = #predictionText + 1
			predictionInput.Text = ""
		end
	end
end)

NAgui.barDeselect(0)
NAUIMANAGER.cmdBar.Visible=true
if NAUIMANAGER.chatLogsFrame then
	NAgui.menuv2(NAUIMANAGER.chatLogsFrame)
end

if NAUIMANAGER.NAconsoleFrame then
	NAgui.menuv2(NAUIMANAGER.NAconsoleFrame)
end

if NAUIMANAGER.commandsFrame then
	NAgui.menu(NAUIMANAGER.commandsFrame)
end

if NAUIMANAGER.SettingsFrame then
	NAgui.menu(NAUIMANAGER.SettingsFrame)
end

if NAUIMANAGER.WaypointFrame then
	NAgui.menu(NAUIMANAGER.WaypointFrame)
end

if NAUIMANAGER.BindersFrame then
	NAgui.menu(NAUIMANAGER.BindersFrame)
end

--[[ GUI RESIZE FUNCTION ]]--

if NAUIMANAGER.chatLogsFrame then NAgui.resizeable(NAUIMANAGER.chatLogsFrame) end
if NAUIMANAGER.NAconsoleFrame then NAgui.resizeable(NAUIMANAGER.NAconsoleFrame) end
if NAUIMANAGER.commandsFrame then NAgui.resizeable(NAUIMANAGER.commandsFrame) end
if NAUIMANAGER.SettingsFrame then NAgui.resizeable(NAUIMANAGER.SettingsFrame) end
if NAUIMANAGER.WaypointFrame then NAgui.resizeable(NAUIMANAGER.WaypointFrame) end
if NAUIMANAGER.BindersFrame then NAgui.resizeable(NAUIMANAGER.BindersFrame) end

--[[ CMDS COMMANDS SEARCH FUNCTION ]]--
NAUIMANAGER.commandsFilter:GetPropertyChangedSignal("Text"):Connect(function()
	local searchText = Lower(GSub(NAUIMANAGER.commandsFilter.Text, ";", ""))

	for _, label in ipairs(NAUIMANAGER.commandsList:GetChildren()) do
		if label:IsA("TextLabel") then
			local cmdName = Lower(label.Name)
			local command = cmds.Commands[cmdName]
			local displayInfo = command and command[2] and command[2][1] or ""
			local updatedText, extraAliases = fixStupidSearchGoober(cmdName, command)

			local searchableInfo = Lower(displayInfo)
			searchableInfo = GSub(searchableInfo, "<[^>]+>", "")
			searchableInfo = GSub(searchableInfo, "%[[^%]]+%]", "")
			searchableInfo = GSub(searchableInfo, "%([^%)]+%)", "")
			searchableInfo = GSub(searchableInfo, "{[^}]+}", "")
			searchableInfo = GSub(searchableInfo, "【[^】]+】", "")
			searchableInfo = GSub(searchableInfo, "〖[^〗]+〗", "")
			searchableInfo = GSub(searchableInfo, "«[^»]+»", "")
			searchableInfo = GSub(searchableInfo, "‹[^›]+›", "")
			searchableInfo = GSub(searchableInfo, "「[^」]+」", "")
			searchableInfo = GSub(searchableInfo, "『[^』]+』", "")
			searchableInfo = GSub(searchableInfo, "（[^）]+）", "")
			searchableInfo = GSub(searchableInfo, "〔[^〕]+〕", "")
			searchableInfo = GSub(searchableInfo, "‖[^‖]+‖", "")
			searchableInfo = GSub(searchableInfo, "%s+", " ")
			searchableInfo = GSub(searchableInfo, "^%s*(.-)%s*$", "%1")

			local extraAliases = {}
			local baseFunc = command and command[1]
			for alias, aliasData in pairs(cmds.Aliases) do
				if aliasData[1] == baseFunc then
					Insert(extraAliases, Lower(alias))
				end
			end

			if #extraAliases > 0 and not Find(updatedText, "%b()") then
				updatedText = updatedText.." ("..Concat(extraAliases, ", ")..")"
			end

			local matches = false

			if Sub(cmdName, 1, #searchText) == searchText then
				matches = true
			elseif Find(searchableInfo, searchText, 1, true) then
				matches = true
			else
				for _, alias in ipairs(extraAliases) do
					if Sub(alias, 1, #searchText) == searchText or Find(alias, searchText, 1, true) then
						matches = true
						break
					end
				end
			end

			label.Visible = matches
			if matches then
				label.Text = updatedText
			end
		end
	end
end)

--[[ CHAT TO USE COMMANDS ]]--
function bindToChat(plr, msg)
	local chatMsg = NAUIMANAGER.chatExample:Clone()

	for _, v in pairs(NAUIMANAGER.chatLogs:GetChildren()) do
		if v:IsA("TextLabel") then
			v.LayoutOrder = v.LayoutOrder + 1
		end
	end

	chatMsg.Name = '\0'
	chatMsg.Parent = NAUIMANAGER.chatLogs

	local displayName = plr.DisplayName or "Unknown"
	local userName = plr.Name or "Unknown"

	local isNAadmin = false
	if _G.NAadminsLol then
		for _, id in ipairs(_G.NAadminsLol) do
			if plr.UserId == id then
				isNAadmin = true
				break
			end
		end
	end

	local currentTime = os.date("%Y-%m-%d %H:%M:%S")
	if displayName == userName then
		chatMsg.Text = ("@%s: %s"):format(userName, msg)
	else
		chatMsg.Text = ("%s [@%s]: %s"):format(displayName, userName, msg)
	end

	if isNAadmin then
		local function rainbowColor()
			local time = tick()
			local r = math.sin(time * 0.5) * 127 + 128
			local g = math.sin(time * 0.5 + 2 * math.pi / 3) * 127 + 128
			local b = math.sin(time * 0.5 + 4 * math.pi / 3) * 127 + 128
			return Color3.fromRGB(r, g, b)
		end
		RunService.Heartbeat:Connect(function()
			if chatMsg and chatMsg.Parent then
				chatMsg.TextColor3 = rainbowColor()
			end
		end)
	else
		if plr == LocalPlayer then
			chatMsg.TextColor3 = Color3.fromRGB(0, 155, 255)
		elseif LocalPlayer:IsFriendsWith(plr.UserId) then
			chatMsg.TextColor3 = Color3.fromRGB(255, 255, 0)
		end
	end

	NACaller(function()
		if FileSupport and appendfile then
			local cEntry = Format(
				"[%s] %s | Game: %s | PlaceId: %s | GameId: %s | JobId: %s\n",
				currentTime,
				chatMsg.Text,
				placeName() or "unknown",
				tostring(PlaceId),
				tostring(GameId),
				tostring(JobId)
			)
			if isfile(NAfiles.NACHATLOGS) then
				appendfile(NAfiles.NACHATLOGS, cEntry)
			else
				writefile(NAfiles.NACHATLOGS, cEntry)
			end
		end
	end)

	local txtSize = NAgui.txtSize(chatMsg, chatMsg.AbsoluteSize.X, 200)
	chatMsg.Size = UDim2.new(1, -5, 0, txtSize.Y)

	local MAX_MESSAGES = 200
	local chatFrames = {}
	for _, v in pairs(NAUIMANAGER.chatLogs:GetChildren()) do
		if v:IsA("TextLabel") then
			Insert(chatFrames, v)
		end
	end

	table.sort(chatFrames, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)

	if #chatFrames > MAX_MESSAGES then
		for i = MAX_MESSAGES + 1, #chatFrames do
			chatFrames[i]:Destroy()
		end
	end
end

NAmanage.bindToDevConsole = function()
	if not NAUIMANAGER.NAconsoleLogs or not NAUIMANAGER.NAconsoleExample then return end

	local toggles = { Output = true, Info = true, Warn = true, Error = true }

	local FilterButtons = InstanceNew("Frame")
	FilterButtons.Name = "FilterButtons"
	FilterButtons.Size = UDim2.new(1, -10, 0, 22)
	FilterButtons.Position = UDim2.new(0.5, 0, 0, 30)
	FilterButtons.AnchorPoint = Vector2.new(0.5, 0)
	FilterButtons.BackgroundTransparency = 1
	FilterButtons.Parent = NAUIMANAGER.NAconsoleLogs.Parent

	local layout = InstanceNew("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = FilterButtons

	local buttonTypes = { "Output", "Info", "Warn", "Error" }

	for _, logType in ipairs(buttonTypes) do
		local btnContainer = InstanceNew("Frame")
		btnContainer.Name = logType
		btnContainer.Size = UDim2.new(0, 90, 1, 0)
		btnContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btnContainer.Parent = FilterButtons

		local corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = btnContainer

		local checkbox = InstanceNew("Frame")
		checkbox.Name = "Checkbox"
		checkbox.Size = UDim2.new(0, 18, 0, 18)
		checkbox.Position = UDim2.new(0, 5, 0.5, 0)
		checkbox.AnchorPoint = Vector2.new(0, 0.5)
		checkbox.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		checkbox.BorderSizePixel = 0
		checkbox.Parent = btnContainer

		local boxCorner = InstanceNew("UICorner")
		boxCorner.CornerRadius = UDim.new(0, 4)
		boxCorner.Parent = checkbox

		local label = InstanceNew("TextLabel")
		label.Name = "Label"
		label.Text = logType
		label.Position = UDim2.new(0, 28, 0, 0)
		label.Size = UDim2.new(1, -28, 1, 0)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.Parent = btnContainer

		local clickZone = InstanceNew("TextButton")
		clickZone.Name = "ClickArea"
		clickZone.Size = UDim2.new(1, 0, 1, 0)
		clickZone.BackgroundTransparency = 1
		clickZone.Text = ""
		clickZone.Parent = btnContainer

		MouseButtonFix(clickZone, function()
			toggles[logType] = not toggles[logType]
			local targetColor = toggles[logType] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			local tween = TweenService:Create(checkbox, tweenInfo, {BackgroundColor3 = targetColor})
			tween:Play()

			for _, label in pairs(NAUIMANAGER.NAconsoleLogs:GetChildren()) do
				if label:IsA("TextLabel") and label:FindFirstChild("Tag") then
					local tag = label.Tag.Value
					local matchesSearch = NAUIMANAGER.NAfilter.Text == "" or Find(label.Text:lower(), NAUIMANAGER.NAfilter.Text:lower())
					label.Visible = toggles[tag] and matchesSearch
				end
			end
		end)
	end

	NAUIMANAGER.NAfilter:GetPropertyChangedSignal("Text"):Connect(function()
		local query = NAUIMANAGER.NAfilter.Text:lower()
		for _, label in pairs(NAUIMANAGER.NAconsoleLogs:GetChildren()) do
			if label:IsA("TextLabel") and label:FindFirstChild("Tag") then
				local tag = label.Tag.Value
				local matches = query == "" or Find(label.Text:lower(), query)
				label.Visible = toggles[tag] and matches
			end
		end
	end)

	local messageCounter = 0

	SafeGetService("LogService").MessageOut:Connect(function(msg, msgTYPE)
		messageCounter = messageCounter + 1

		local logLabel = NAUIMANAGER.NAconsoleExample:Clone()
		logLabel.Name = "Log_"..tostring(math.random(100000, 999999))
		logLabel.Parent = NAUIMANAGER.NAconsoleLogs
		logLabel.LayoutOrder = messageCounter
		logLabel.RichText = true

		local tagColor = "#cccccc"
		local tagText = "Output"

		if msgTYPE == Enum.MessageType.MessageError then
			tagColor = "#ff6464"
			tagText = "Error"
		elseif msgTYPE == Enum.MessageType.MessageWarning then
			tagColor = "#ffcc00"
			tagText = "Warn"
		elseif msgTYPE == Enum.MessageType.MessageInfo then
			tagColor = "#66ccff"
			tagText = "Info"
		end

		local escapedMsg = msg:gsub("<", "&lt;"):gsub(">", "&gt;")

		logLabel.Text = '<font color="'..tagColor..'">['..tagText..']</font>: <font color="#ffffff">'..escapedMsg..'</font>'

		local tag = InstanceNew("StringValue")
		tag.Name = "Tag"
		tag.Value = tagText
		tag.Parent = logLabel

		local txtSize = NAgui.txtSize(logLabel, logLabel.AbsoluteSize.X, 100)
		logLabel.Size = UDim2.new(1, -5, 0, txtSize.Y)

		local MAX_MESSAGES = 200
		local logFrames = {}

		for _, v in pairs(NAUIMANAGER.NAconsoleLogs:GetChildren()) do
			if v:IsA("TextLabel") then
				Insert(logFrames, v)
			end
		end

		table.sort(logFrames, function(a, b)
			return a.LayoutOrder < b.LayoutOrder
		end)

		while #logFrames > MAX_MESSAGES do
			logFrames[1]:Destroy()
			table.remove(logFrames, 1)
		end

		local matchesSearch = NAUIMANAGER.NAfilter.Text == "" or Find(logLabel.Text:lower(), NAUIMANAGER.NAfilter.Text:lower())
		logLabel.Visible = toggles[tagText] and matchesSearch
	end)
end

--[[function NAUISCALEUPD()
	if not workspace.CurrentCamera then return end

	local screenHeight = workspace.CurrentCamera.ViewportSize.Y
	local baseHeight = 720
	AUTOSCALER.Scale = math.clamp(screenHeight / baseHeight, 0.75, 1.25)
end]]

local logClrs={
	GREEN   = "#00FF00";
	WHITE   = "#FFFFFF";
	RED     = "#FF0000";
}

function setupPlayer(plr,bruh)
	NAmanage.ExecuteBindings("OnJoin", plr.Name)
	plr.Chatted:Connect(function(msg)
		bindToChat(plr, msg)
		if plr~=LocalPlayer then
			local t = msg:match("^!IY%s+(%S+)")
			if t then
				cmd.run({"char",t,plr})
			end
		end
	end)

	Insert(playerButtons, plr)

	if plr ~= LocalPlayer then
		CheckPermissions(plr)
	end

	if ESPenabled then
		Spawn(function()
			repeat Wait(.5) until plr.Character
			Wait(.5)
			NAESP(plr,true)
		end)
	end

	if JoinLeaveConfig.JoinLog and not bruh then
		local joinMsg = nameChecker(plr).." has joined the game."
		local categoryRT = ('<font color="%s">Join</font>/'..'<font color="%s">Leave</font>'):format(logClrs.GREEN, logClrs.WHITE)
		DoNotif(joinMsg, 1, categoryRT)
		NAmanage.LogJoinLeave(joinMsg)
	end
end

for _, plr in pairs(Players:GetPlayers()) do
	setupPlayer(plr, true)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(plr)
	NAmanage.ExecuteBindings("OnLeave", plr.Name)
	local index = Discover(playerButtons, plr)
	if index then
		table.remove(playerButtons, index)
	end
	removeESPonLEAVE(plr)
	if JoinLeaveConfig.LeaveLog then
		local leaveMsg = nameChecker(plr).." has left the game."
		local categoryRT = ('<font color="%s">Join</font>/'..'<font color="%s">Leave</font>'):format(logClrs.WHITE, logClrs.RED)
		DoNotif(leaveMsg, 1, categoryRT)
		NAmanage.LogJoinLeave(leaveMsg)
	end
end)

Spawn(function()
	NAmanage.UIrenamerFRIEND=function(o)
		if type(o.Text) == "string" then
			o.Text = o.Text:gsub("Connections","Friends"):gsub("Connection","Friend")
		end
	end

	for _, internet in ipairs(workspace:GetDescendants()) do
		if internet:IsA("ClickDetector") then
			Insert(interactTbl.click, internet)
		elseif internet:IsA("ProximityPrompt") then
			Insert(interactTbl.proxy, internet)
		elseif internet:IsA("TouchTransmitter") then
			Insert(interactTbl.touch, internet)
		end
	end

	if CoreGui then
		for _, o in ipairs(CoreGui:GetDescendants()) do
			if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
				NAmanage.UIrenamerFRIEND(o)
			end
		end
		CoreGui.DescendantAdded:Connect(function(o)
			if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
				NAmanage.UIrenamerFRIEND(o)
			end
			for _, c in ipairs(o:GetDescendants()) do
				if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
					NAmanage.UIrenamerFRIEND(c)
				end
			end
		end)
	end

	workspace.DescendantAdded:Connect(function(internet)
		if internet:IsA("ClickDetector") then
			Insert(interactTbl.click, internet)
		elseif internet:IsA("ProximityPrompt") then
			Insert(interactTbl.proxy, internet)
		elseif internet:IsA("TouchTransmitter") then
			Insert(interactTbl.touch, internet)
		end
	end)

	workspace.DescendantRemoving:Connect(function(internet)
		if internet:IsA("ClickDetector") then
			local i = Discover(interactTbl.click, internet)
			if i then table.remove(interactTbl.click, i) end
		elseif internet:IsA("ProximityPrompt") then
			local i = Discover(interactTbl.proxy, internet)
			if i then table.remove(interactTbl.proxy, i) end
		elseif internet:IsA("TouchTransmitter") then
			local i = Discover(interactTbl.touch, internet)
			if i then table.remove(interactTbl.touch, i) end
		end
	end)
end)

Spawn(function()
	local function setupFLASHBACK(c)
		if not c then return end

		local hum = getHum()
		while not hum do Wait(.1) hum=getHum() end
		hum.Died:Connect(function()
			local root = getRoot(character)
			if root then
				deathCFrame = root.CFrame
			end
		end)
	end

	setupFLASHBACK(LocalPlayer.Character)
	LocalPlayer.CharacterAdded:Connect(function(c)
		setupFLASHBACK(c)
		NAmanage.ExecuteBindings("OnSpawned", char)
		Wait(.5)
		local humanoid = getHum()
		if humanoid then
			local lastHP = humanoid.Health
			humanoid.Died:Connect(function() NAmanage.ExecuteBindings("OnDeath") end)
			humanoid.HealthChanged:Connect(function(newHP)
				if newHP < lastHP then
					NAmanage.ExecuteBindings("OnDamage", lastHP, newHP)
				end
				lastHP = newHP
			end)
		end
	end)

	if LocalPlayer.Character then
		local char = LocalPlayer.Character
		local humanoid = getHum()
		if humanoid then
			local lastHP = humanoid.Health
			humanoid.Died:Connect(function() NAmanage.ExecuteBindings("OnDeath") end)
			humanoid.HealthChanged:Connect(function(newHP)
				if newHP < lastHP then
					NAmanage.ExecuteBindings("OnDamage", lastHP, newHP)
				end
				lastHP = newHP
			end)
		end
	end
end)

mouse.Move:Connect(function()
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)

	local xScale = mouse.X / viewportSize.X
	local yScale = mouse.Y / viewportSize.Y

	NAUIMANAGER.description.Position = UDim2.new(xScale, 0, yScale, 0)

	local newSize = NAgui.txtSize(NAUIMANAGER.description, 200, 100)
	NAUIMANAGER.description.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
end)

function updateCanvasSize(frame, scale)
	local layout = frame:FindFirstChildOfClass("UIListLayout")
	if layout then
		local adjustedHeight = layout.AbsoluteContentSize.Y / scale
		frame.CanvasSize = UDim2.new(0, 0, 0, adjustedHeight)
	end
end

RunService.RenderStepped:Connect(function()
	if NAUIMANAGER.chatLogs then updateCanvasSize(NAUIMANAGER.chatLogs, NAUIMANAGER.AUTOSCALER.Scale) end
	if NAUIMANAGER.NAconsoleLogs then updateCanvasSize(NAUIMANAGER.NAconsoleLogs, NAUIMANAGER.AUTOSCALER.Scale) end
	if NAUIMANAGER.commandsList then updateCanvasSize(NAUIMANAGER.commandsList, NAUIMANAGER.AUTOSCALER.Scale) end
	if NAUIMANAGER.SettingsList then updateCanvasSize(NAUIMANAGER.SettingsList, NAUIMANAGER.AUTOSCALER.Scale) end
	if NAUIMANAGER.WaypointList then updateCanvasSize(NAUIMANAGER.WaypointList, NAUIMANAGER.AUTOSCALER.Scale) end
	if NAUIMANAGER.BindersList then updateCanvasSize(NAUIMANAGER.BindersList, NAUIMANAGER.AUTOSCALER.Scale) end
end)

RunService.RenderStepped:Connect(function()
	local p = opt.prefix

	local function isInvalid(prefix)
		return not prefix
			or utf8.len(prefix) ~= 1
			or prefix:match("[%w]")
			or prefix:match("[%[%]%(%)%*%^%$%%{}<>]")
			or prefix:match("&amp;") or prefix:match("&lt;") or prefix:match("&gt;")
			or prefix:match("&quot;") or prefix:match("&#x27;") or prefix:match("&#x60;")
	end

	if isInvalid(p) then
		if opt.prefix ~= ";" then
			opt.prefix = ";"
			DoNotif("Invalid prefix detected. Resetting to default ';'")
			lastPrefix = ";"

			if FileSupport and isfile(NAfiles.NAPREFIXPATH) then
				local filePrefix = readfile(NAfiles.NAPREFIXPATH)
				if isInvalid(filePrefix) then
					writefile(NAfiles.NAPREFIXPATH, ";")
				end
			end
		end
	else
		lastPrefix = p
	end
end)

--RunService.RenderStepped:Connect(NAUISCALEUPD)

NACaller(function()
	if NAStuff.NAjson and NAStuff.NAjson.annc and NAStuff.NAjson.annc ~= "" then
		DoPopup(NAStuff.NAjson.annc, adminName.." Announcement")
	end
end)

--[[ COMMAND BAR BUTTON ]]--
local TextLabel = InstanceNew("TextLabel")
local UICorner = InstanceNew("UICorner")
local UIStroke = InstanceNew("UIStroke")
local TextButton
local UICorner2 = InstanceNew("UICorner")

NAICONASSET = nil

NACaller(function() NAICONASSET=(getcustomasset and (isAprilFools() and getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.sWare) or getcustomasset(NAfiles.NAASSETSFILEPATH.."/"..NAImageAssets.Icon))) or nil end)

if NAICONASSET then
	TextButton = InstanceNew("ImageButton")
	TextButton.Image = NAICONASSET
else
	TextButton = InstanceNew("TextButton")
	TextButton.Font = Enum.Font.SourceSansBold
	TextButton.TextColor3 = Color3.fromRGB(241, 241, 241)
	TextButton.TextSize = 22
	if isAprilFools() then
		cringyahhnamesidk = { "IY", "FE", "F3X", "HD", "CMD", "Ω", "R6", "Ø", "NA", "CMDX" }
		TextButton.Text = cringyahhnamesidk[math.random(1, #cringyahhnamesidk)]
	else
		TextButton.Text = "NA"
	end
end

TextLabel.Parent = NAStuff.NASCREENGUI
TextLabel.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
TextLabel.BackgroundTransparency = 0.1
TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
TextLabel.Size = UDim2.new(0, 0, 0, 0)
TextLabel.Font = Enum.Font.FredokaOne
TextLabel.Text = getSeasonEmoji().." "..adminName..curVer.." "..getSeasonEmoji()
TextLabel.TextColor3 = Color3.fromRGB(241, 241, 241)
TextLabel.TextSize = 22
TextLabel.TextWrapped = true
TextLabel.TextStrokeTransparency = 0.7
TextLabel.TextTransparency = 1
TextLabel.ZIndex = 9999

UICorner2.CornerRadius = UDim.new(0.25, 0)
UICorner2.Parent = TextLabel

UIStroke.Parent = TextLabel
UIStroke.Thickness = 2
UIStroke.Color = NAUISTROKER --Color3.fromRGB(148, 93, 255)
UIStroke.Transparency = 0.4
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

TextButton.Parent = NAStuff.NASCREENGUI
TextButton.BackgroundTransparency = 0
TextButton.AnchorPoint = Vector2.new(0.5, 0)
TextButton.BorderSizePixel = 0
TextButton.BackgroundColor3 = Color3.fromRGB(25, 26, 30)
TextButton.Position = UDim2.new(0.5, 0, -1, 0)
TextButton.Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale)
TextButton.ZIndex = 9999

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = TextButton

TextButton.MouseEnter:Connect(function()
	TweenService:Create(TextButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 35 * NAScale, 0, 35 * NAScale)
	}):Play()
end)

TextButton.MouseLeave:Connect(function()
	TweenService:Create(TextButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale)
	}):Play()
end)

swooshySWOOSH = false

function Swoosh()
	TweenService:Create(TextButton, TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Rotation = 720
	}):Play()
	NAgui.draggerV2(TextButton)
	if swooshySWOOSH then return end
	swooshySWOOSH = true
	TextButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if FileSupport and NAiconSaveEnabled then
						local pos = TextButton.Position
						writefile(NAfiles.NAICONPOSPATH, HttpService:JSONEncode({
							X = pos.X.Scale,
							Y = pos.Y.Scale,
							Save = NAiconSaveEnabled
						}))
					end
				end
			end)
		end
	end)
end

function mainNameless()
	local txtLabel = TextLabel
	local textWidth = TextService:GetTextSize(txtLabel.Text, txtLabel.TextSize, txtLabel.Font, Vector2.new(math.huge, math.huge)).X
	local finalSize = UDim2.new(0, textWidth + 80, 0, 40)

	local appearTween = TweenService:Create(txtLabel, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Size = finalSize,
		BackgroundTransparency = 0.1,
		TextTransparency = 0,
	})

	local riseTween = TweenService:Create(txtLabel, TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.48, 0)
	})

	appearTween:Play()
	riseTween:Play()

	TextButton.Size = UDim2.new(0, 0, 0, 0)
	if TextButton:IsA("TextButton") then
		TextButton.TextTransparency = 1
	end

	local targetPos = UDim2.new(0.5, 0, 0.1, 0)

	if FileSupport and isfile(NAfiles.NAICONPOSPATH) then
		local data = HttpService:JSONDecode(readfile(NAfiles.NAICONPOSPATH))
		if data and data.X and data.Y then
			targetPos = UDim2.new(data.X, 0, data.Y, 0)
		end
	end

	TextButton.Position = UDim2.new(targetPos.X.Scale, 0, targetPos.Y.Scale - 0.15, -20)

	local tweenProps = {
		Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale),
		Position = targetPos
	}

	if TextButton:IsA("TextButton") then
		tweenProps.TextTransparency = 0
	end

	local appearBtnTween = TweenService:Create(TextButton, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), tweenProps)
	appearBtnTween:Play()

	Swoosh()

	Wait(2.5)

	local fadeOutTween = TweenService:Create(txtLabel, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.InOut), {
		TextTransparency = 1,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.52, 20),
		Size = UDim2.new(0, 0, 0, 0)
	})

	fadeOutTween:Play()
	fadeOutTween.Completed:Once(function()
		txtLabel:Destroy()
	end)
end

coroutine.wrap(mainNameless)()

MouseButtonFix(TextButton,function()
	NAgui.barSelect()
	NAUIMANAGER.cmdInput.Text=''
	NAUIMANAGER.cmdInput:CaptureFocus()
	Wait(.00005)
	NAUIMANAGER.cmdInput.Text=''
end)

--@ltseverydayyou (Aervanix)
--@Cosmella (Viper)

--original by @qipu | loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))();

Spawn(function()
	local NAresult = tick() - NAbegin
	local nameCheck = nameChecker(Player)

	Delay(0.3, function()
		local executorName = identifyexecutor and identifyexecutor() or "Unknown"
		local welcomeMessage = "Welcome to "..adminName..curVer

		executorName = maybeMock(executorName)
		welcomeMessage = maybeMock(welcomeMessage)

		local notifBody = welcomeMessage..
			(identifyexecutor and ("\nExecutor: "..executorName) or "")..
			"\nUpdated on: "..opt.NAupdDate..
			"\nTime Taken To Load: "..loadedResults(NAresult)

		DoNotif(notifBody, 6, rngMsg().." "..nameCheck)

		if not FileSupport then
			warn("NAWWW NO FILE SUPPORT???????")
			Window({
				Title = maybeMock("Would you like to enable QueueOnTeleport?"),
				Description = maybeMock("With QueueOnTeleport, "..adminName.." will automatically execute itself upon teleporting to a game or place."),
				Buttons = {
					{Text = "Yes", Callback = function()
						opt.queueteleport(opt.loader)
					end},
					{Text = "No", Callback = function() end}
				}
			})
		elseif not opt.queueteleport then
			warn('your executor is dog shit')
		end

		Wait(1)

		if IsOnPC then
			local keybindMessage = maybeMock("Your Keybind Prefix: "..opt.prefix)
			DoNotif(keybindMessage, 10, adminName.." Keybind Prefix")
		end

		pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/SaveInstance.lua"))() end) -- it has better SaveInstance support and important functions that are required

		-- just ignore this section (personal stuff)
		--[[Window({
			Title = adminName.." (Archived)",
			Description = 'This version is no longer maintained.\nCheck the README on GitHub for legacy details.',
			Buttons = {
				{
					Text = "Copy GitHub Repo",
					Callback = function()
						setclipboard("https://github.com/ltseverydayyou/Nameless-Admin")
					end
				},
				{
					Text = "Discord Server",
					Callback = function()
						setclipboard("https://discord.gg/zzjYhtMGFD")
					end
				},
				{
					Text = "Close",
					Callback = function() end
				}
			}
		})]]
	end)
	Spawn(function()
		Wait(.5)
		for _, commandName in ipairs(NAEXECDATA.commands) do
			local fullRun = {commandName}
			local argsString = NAEXECDATA.args[commandName]
			if argsString and argsString ~= "" then
				local extraArgs = ParseArguments(argsString)
				for _, v in ipairs(extraArgs) do
					Insert(fullRun, v)
				end
			end
			cmd.run(fullRun)
		end
	end)
	NAUIMANAGER.cmdInput.ZIndex = 10
	NAUIMANAGER.cmdInput.PlaceholderText = isAprilFools() and '🤡 '..adminName..curVer..' 🤡' or getSeasonEmoji()..' '..adminName..curVer..' '..getSeasonEmoji()
end)

CaptureService.CaptureBegan:Connect(function()
	if TextButton then
		TextButton.Visible=false
	end
end)

CaptureService.CaptureEnded:Connect(function()
	Delay(0.1, function()
		if TextButton then
			TextButton.Visible=true
		end
	end)
end)

NAmanage.hsv2rgb=function(h, s, v)
	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c
	local r1, g1, b1
	if h < 60 then
		r1, g1, b1 = c, x, 0
	elseif h < 120 then
		r1, g1, b1 = x, c, 0
	elseif h < 180 then
		r1, g1, b1 = 0, c, x
	elseif h < 240 then
		r1, g1, b1 = 0, x, c
	elseif h < 300 then
		r1, g1, b1 = x, 0, c
	else
		r1, g1, b1 = c, 0, x
	end
	return (r1 + m), (g1 + m), (b1 + m)
end

NAmanage.gradientify=function(text)
	local len = #text
	if len == 0 then return "" end
	local out = {}
	for i = 1, len do
		local frac = (i - 1) / (len - 1)
		local hue = frac * 360
		local r, g, b = NAmanage.hsv2rgb(hue, 1, 1)
		local hex = Format("#%02X%02X%02X", r * 255, g * 255, b * 255)
		local ch = text:sub(i, i)
		out[i] = Format('<font color="%s">%s</font>', hex, ch)
	end
	return Concat(out)
end

NAmanage.grayGradient=function(text)
	local startGray = 0
	local endGray   = 100
	local len = #text
	if len == 0 then return "" end
	local out = {}
	for i = 1, len do
		local frac = (i - 1) / (len - 1)
		local v = startGray + (endGray - startGray) * frac
		local g = math.floor(v)
		local hex = Format("#%02X%02X%02X", g, g, g)
		local ch = text:sub(i, i)
		out[i] = Format('<font color="%s">%s</font>', hex, ch)
	end
	return Concat(out)
end

TextChatService.OnIncomingMessage = function(message)
	local ts = message.TextSource
	if not ts then return end
	local pl = Players:GetPlayerByUserId(ts.UserId)
	if not pl then return end

	for _, id in ipairs(_G.NAadminsLol or {}) do
		if pl.UserId == id then
			local props = InstanceNew("TextChatMessageProperties")
			local name = nameChecker(pl)
			local gradName = NAmanage.gradientify(name)
			local tag      = NAmanage.grayGradient("[NA ADMIN]")
			props.PrefixText = Format('%s %s: ', tag, gradName)
			props.Text = message.Text
			return props
		end
	end

	local tagText   = pl:GetAttribute("CustomNAtaggerText")
	local tagCol    = pl:GetAttribute("CustomNAtaggerColor")
	local useRainbow = pl:GetAttribute("CustomNAtaggerRainbow")

	if tagText and tagCol then
		local r, g, b = tagCol.R * 255, tagCol.G * 255, tagCol.B * 255
		local hex = Format("#%02X%02X%02X", r, g, b)
		local props = InstanceNew("TextChatMessageProperties")
		local name = nameChecker(pl)
		local displayName = useRainbow and NAmanage.gradientify(name) or name
		props.PrefixText = Format('<font color="%s">[%s]</font> %s: ', hex, tagText, displayName)
		props.Text = message.Text
		return props
	end

	--[[local props = InstanceNew("TextChatMessageProperties")
	local name = nameChecker(pl)
	props.PrefixText = Format('%s: ', name)
	props.Text = message.Text
	return props]]
end

--[[
print(
	
███╗░░██╗░█████╗░███╗░░░███╗███████╗██╗░░░░░███████╗░██████╗░██████╗
████╗░██║██╔══██╗████╗░████║██╔════╝██║░░░░░██╔════╝██╔════╝██╔════╝
██╔██╗██║███████║██╔████╔██║█████╗░░██║░░░░░█████╗░░╚█████╗░╚█████╗░
██║╚████║██╔══██║██║╚██╔╝██║██╔══╝░░██║░░░░░██╔══╝░░░╚═══██╗░╚═══██╗
██║░╚███║██║░░██║██║░╚═╝░██║███████╗███████╗███████╗██████╔╝██████╔╝
╚═╝░░╚══╝╚═╝░░╚═╝╚═╝░░░░░╚═╝╚══════╝╚══════╝╚══════╝╚═════╝░╚═════╝░

░█████╗░██████╗░███╗░░░███╗██╗███╗░░██╗
██╔══██╗██╔══██╗████╗░████║██║████╗░██║
███████║██║░░██║██╔████╔██║██║██╔██╗██║
██╔══██║██║░░██║██║╚██╔╝██║██║██║╚████║
██║░░██║██████╔╝██║░╚═╝░██║██║██║░╚███║
╚═╝░░╚═╝╚═════╝░╚═╝░░░░░╚═╝╚═╝╚═╝░░╚══╝
)
]]

math.randomseed(os.time())

Spawn(function()
	while Wait() do
		if getHum() then getHum().AutoJumpEnabled=false end -- bye bye useless autojump
	end
end)

Spawn(function() -- init
	if NAUIMANAGER.cmdBar then NAProtection(NAUIMANAGER.cmdBar) end
	if NAUIMANAGER.chatLogsFrame then NAProtection(NAUIMANAGER.chatLogsFrame) end
	if NAUIMANAGER.NAconsoleFrame then NAProtection(NAUIMANAGER.NAconsoleFrame) end
	if NAUIMANAGER.commandsFrame then NAProtection(NAUIMANAGER.commandsFrame) end
	if NAUIMANAGER.resizeFrame then NAProtection(NAUIMANAGER.resizeFrame) end
	if NAUIMANAGER.description then NAProtection(NAUIMANAGER.description) end
	if NAUIMANAGER.ModalFixer then NAProtection(NAUIMANAGER.ModalFixer) end
	if NAUIMANAGER.AUTOSCALER then NAProtection(NAUIMANAGER.AUTOSCALER) NAUIMANAGER.AUTOSCALER.Scale = NAUIScale end
	if NAUIMANAGER.SettingsFrame then NAProtection(NAUIMANAGER.SettingsFrame) end
	if NAUIMANAGER.WaypointFrame then NAProtection(NAUIMANAGER.WaypointFrame) end
	if NAUIMANAGER.BindersFrame then NAProtection(NAUIMANAGER.BindersFrame) end
	if not PlrGui then PlrGui=Player:WaitForChild("PlayerGui",math.huge) end
end)

Spawn(NAmanage.bindToDevConsole)
Spawn(NAmanage.loadAliases)
Spawn(NAmanage.loadButtonIDS)
Spawn(NAmanage.RenderUserButtons)
Spawn(NAmanage.loadAutoExec)
Spawn(NAmanage.LoadPlugins)
Spawn(NAmanage.UpdateWaypointList)


OrgDestroyHeight=NAlib.isProperty(workspace, "FallenPartsDestroyHeight") or math.huge

local bindersList      = NAUIMANAGER.BindersList
Spawn(function()
	local layoutOrder = 1
	for _, evName in ipairs(events) do
		local ev = evName
		local HEADER_H = 30

		local binderFrame = InstanceNew("Frame")
		binderFrame.Name             = ev.."Binder"
		binderFrame.Parent           = bindersList
		binderFrame.Size             = UDim2.new(1,0,0, HEADER_H)
		binderFrame.LayoutOrder      = layoutOrder
		binderFrame.ClipsDescendants = true
		binderFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
		local binderCorner = InstanceNew("UICorner", binderFrame)
		binderCorner.CornerRadius    = UDim.new(0,8)
		local binderStroke = InstanceNew("UIStroke", binderFrame)
		binderStroke.Color           = Color3.fromRGB(60,60,60)
		binderStroke.Thickness       = 1

		local header = InstanceNew("TextButton")
		header.Name                   = "Header"
		header.Parent                 = binderFrame
		header.Size                   = UDim2.new(1,-30,0, HEADER_H)
		header.Position               = UDim2.new(0,0,0,0)
		header.BackgroundColor3       = Color3.fromRGB(30,30,30)
		header.AutoButtonColor        = false
		header.Font                   = Enum.Font.SourceSansSemibold
		header.TextSize               = 14
		header.TextColor3             = Color3.fromRGB(255,255,255)
		header.Text                   = ev
		local headerCorner = InstanceNew("UICorner", header)
		headerCorner.CornerRadius     = UDim.new(0,6)
		header.MouseEnter:Connect(function() header.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
		header.MouseLeave:Connect(function() header.BackgroundColor3 = Color3.fromRGB(30,30,30) end)

		local addBtn = InstanceNew("TextButton")
		addBtn.Name                    = "AddBtn"
		addBtn.Parent                  = binderFrame
		addBtn.Size                    = UDim2.new(0,30,0, HEADER_H)
		addBtn.Position                = UDim2.new(1,-30,0,0)
		addBtn.BackgroundColor3        = Color3.fromRGB(30,30,30)
		addBtn.AutoButtonColor         = false
		addBtn.Font                    = Enum.Font.SourceSansBold
		addBtn.TextSize                = 18
		addBtn.TextColor3              = Color3.fromRGB(255,255,255)
		addBtn.Text                    = "+"
		local addCorner = InstanceNew("UICorner", addBtn)
		addCorner.CornerRadius         = UDim.new(0,6)
		addBtn.MouseEnter:Connect(function() addBtn.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
		addBtn.MouseLeave:Connect(function() addBtn.BackgroundColor3 = Color3.fromRGB(30,30,30) end)

		local itemsFrame = InstanceNew("Frame")
		itemsFrame.Name                 = "Items"
		itemsFrame.Parent               = binderFrame
		itemsFrame.Position             = UDim2.new(0,0,0, HEADER_H)
		itemsFrame.Size                 = UDim2.new(1,0,0, 0)
		itemsFrame.BackgroundColor3     = Color3.fromRGB(25,25,25)
		local itemsCorner = InstanceNew("UICorner", itemsFrame)
		itemsCorner.CornerRadius        = UDim.new(0,6)

		local uiLayout = InstanceNew("UIListLayout")
		uiLayout.SortOrder              = Enum.SortOrder.LayoutOrder
		uiLayout.Padding                = UDim.new(0,4)
		uiLayout.Parent                 = itemsFrame
		uiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if binderFrame:GetAttribute("Expanded") then
				local h = uiLayout.AbsoluteContentSize.Y + 8
				itemsFrame:TweenSize(UDim2.new(1,0,0,h), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H + h), "Out", "Quint", 0.25, true)
			end
		end)

		header.MouseButton1Click:Connect(function()
			local exp = binderFrame:GetAttribute("Expanded")
			binderFrame:SetAttribute("Expanded", not exp)
			if exp then
				itemsFrame:TweenSize(UDim2.new(1,0,0,0), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H), "Out", "Quint", 0.25, true)
			else
				local h = uiLayout.AbsoluteContentSize.Y + 8
				itemsFrame:TweenSize(UDim2.new(1,0,0,h), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H + h), "Out", "Quint", 0.25, true)
			end
		end)

		local function refreshItems()
			for _, child in ipairs(itemsFrame:GetChildren()) do
				if child.Name == "BinderItem" then
					child:Destroy()
				end
			end
			local list = Bindings[ev] or {}
			header.Text = ev.." ("..#list..")"
			if #list > 0 then
				binderFrame:SetAttribute("Expanded", true)
				local h = uiLayout.AbsoluteContentSize.Y + 8
				itemsFrame:TweenSize(UDim2.new(1,0,0,h), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H + h), "Out", "Quint", 0.25, true)
			else
				binderFrame:SetAttribute("Expanded", false)
				itemsFrame:TweenSize(UDim2.new(1,0,0,0), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H), "Out", "Quint", 0.25, true)
			end
			for i, cmdStr in ipairs(list) do
				local item = InstanceNew("Frame")
				item.Name               = "BinderItem"
				item.Parent             = itemsFrame
				item.Size               = UDim2.new(1,0,0,24)
				item.LayoutOrder        = i
				item.BackgroundColor3   = Color3.fromRGB(35,35,35)
				local itemCorner = InstanceNew("UICorner", item)
				itemCorner.CornerRadius  = UDim.new(0,4)

				local lbl = InstanceNew("TextLabel")
				lbl.Parent               = item
				lbl.Size                 = UDim2.new(1,-24,1,0)
				lbl.Position             = UDim2.new(0,8,0,0)
				lbl.BackgroundTransparency = 1
				lbl.Text                 = cmdStr
				lbl.Font                 = Enum.Font.SourceSans
				lbl.TextSize             = 14
				lbl.TextColor3           = Color3.fromRGB(255,255,255)
				lbl.TextXAlignment       = Enum.TextXAlignment.Left

				local rem = InstanceNew("TextButton")
				rem.Parent               = item
				rem.Size                 = UDim2.new(0,20,0,20)
				rem.Position             = UDim2.new(1,-24,0,2)
				rem.BackgroundTransparency = 1
				rem.Text                 = "×"
				rem.Font                 = Enum.Font.SourceSansBold
				rem.TextSize             = 18
				rem.TextColor3           = Color3.fromRGB(255,100,100)
				rem.MouseButton1Click:Connect(function()
					table.remove(list, i)
					NAmanage.SaveBinders()
					refreshItems()
				end)
			end
		end

		addBtn.MouseButton1Click:Connect(function()
			Bindings[ev] = Bindings[ev] or {}
			Window({
				Title       = ev.." Binders",
				Description = "Enter commands for "..ev,
				InputField  = true,
				Buttons     = {{
					Text     = "Submit",
					Callback = function(input)
						local cmdName = input:match("^(%S+)")
						if not (cmds.Commands[cmdName:lower()] or cmds.Aliases[cmdName:lower()]) then
							DoNotif("Command '"..cmdName.."' not found.")
							return
						end
						Insert(Bindings[ev], input)
						NAmanage.SaveBinders()
						refreshItems()
					end
				}}
			})
		end)

		refreshItems()
		layoutOrder = layoutOrder + 1
	end
end)

-- [[ GUI ELEMENTS ]] --

--[[

NAgui.addToggle("Toggle Button", true, function(state)
	print("State:", state)
end)

NAgui.addColorPicker("Color Picker", Color3.fromRGB(200, 50, 100), function(color)
	print("Selected Color:", color)
end)

NAgui.addButton("button", function()
	print'pressed button'
end)

NAgui.addSection("Section Label")

NAgui.addInput("Input Label", "Placeholder", "", function(text)
	print("Input:", text)
end)

NAgui.addKeybind("Toggle Key", "F", function(key)
	print("key triggered:", key)
end)

NAgui.addSlider("Slider", 0, 100, 50, 5, "%", function(val) -- min, max, default, add, suffix
	print("Slider Value:", val)
end)

]]

NAgui.addSection("Prefix Settings")

NAgui.addInput("Prefix", "Enter a Prefix", opt.prefix, function(text)
	local newPrefix = text
	if not newPrefix or newPrefix == "" then
		DoNotif("Please enter a valid prefix")
	elseif utf8.len(newPrefix) > 1 then
		DoNotif("Prefix must be a single character (e.g. ; . !)")
	elseif newPrefix:match("[%w]") then
		DoNotif("Prefix cannot contain letters or numbers")
	elseif newPrefix:match("[%[%]%(%)%*%^%$%%{}<>]") then
		DoNotif("That symbol is not allowed as a prefix")
	elseif newPrefix:match("&amp;") or newPrefix:match("&lt;") or newPrefix:match("&gt;")
		or newPrefix:match("&quot;") or newPrefix:match("&#x27;") or newPrefix:match("&#x60;") then
		DoNotif("Encoded/HTML characters are not allowed as a prefix")
	else
		opt.prefix = newPrefix
		DoNotif("Prefix set to: "..newPrefix)
	end
end)

if FileSupport then
	NAgui.addButton("Save Prefix", function()
		if isfile(NAfiles.NAPREFIXPATH) then
			writefile(NAfiles.NAPREFIXPATH, opt.prefix)
			DoNotif("Prefix saved to file: "..NAfiles.NAPREFIXPATH)
		else
			DoNotif("File not found: "..NAfiles.NAPREFIXPATH)
		end
	end)
end

NAgui.addSection("Admin Utility")

NAgui.addToggle("Keep "..adminName, NAQoTEnabled, function(val)
	NAQoTEnabled = val
	if FileSupport then
		writefile(NAfiles.NAQOTPATH, tostring(val))
	end
	if NAQoTEnabled then
		DoNotif(adminName.." will now auto-load after teleport (QueueOnTeleport enabled)", 3)
	else
		DoNotif("QueueOnTeleport has been disabled. "..adminName.." will no longer auto-run after teleport", 3)
	end
end)

NAgui.addToggle("Command Predictions Prompt", doPREDICTION, function(v)
	doPREDICTION = v
	DoNotif("Command Predictions "..(v and "Enabled" or "Disabled"), 2)
	if FileSupport then
		writefile(NAfiles.NAPREDICTIONPATH, tostring(v))
	end
end)

NAgui.addToggle("Debug Notifications", NAStuff.nuhuhNotifs, function(v)
	NAStuff.nuhuhNotifs = v
	DoNotif("Debug Notifications "..(v and "Enabled" or "Disabled"), 2)
	if FileSupport then
		writefile(NAfiles.NANOTIFSTOGGLE, tostring(v))
	end
end)

NAgui.addToggle("Keep Icon Position", NAiconSaveEnabled, function(v)
	local pos = TextButton.Position
	writefile(NAfiles.NAICONPOSPATH, HttpService:JSONEncode({
		X = v and pos.X.Scale or 0.5,
		Y = v and pos.Y.Scale or 0.1,
		Save = v
	}))
	NAiconSaveEnabled = v
	DoNotif("Icon position "..(v and "will be saved" or "won't be saved").." on exit", 2)
end)

NAgui.addSection("UI Customization")

NAgui.addSlider("NA Icon Size", 0.5, 3, NAScale, 0.01, "", function(val)
	NAScale = val
	TextButton.Size = UDim2.new(0, 32 * val, 0, 33 * val)
	if FileSupport then
		writefile(NAfiles.NABUTTONSIZEPATH, tostring(val))
	end
end)

NAgui.addToggle("TopBar Visibility", NATOPBARVISIBLE, function(v)
	TopBarApp.top.Enabled = v
	if FileSupport then
		writefile(NAfiles.NATOPBAR, tostring(v))
	end
end)

NAgui.addColorPicker("UI Stroke", NAUISTROKER, function(color)
	for _, element in ipairs(NACOLOREDELEMENTS) do
		if element:IsA("UIStroke") then
			element.Color = color
		end
	end
	SaveUIStroke(NAfiles.NASTROKETHINGY, color)
end)

if FileSupport then
	NAgui.addSection("Join/Leave Logging")

	NAgui.addToggle("Log Player Joins", JoinLeaveConfig.JoinLog, function(v)
		JoinLeaveConfig.JoinLog = v
		writefile(NAfiles.NAJOINLEAVE, HttpService:JSONEncode(JoinLeaveConfig))
		DoNotif("Join logging "..(v and "enabled" or "disabled"), 2)
	end)

	NAgui.addToggle("Log Player Leaves", JoinLeaveConfig.LeaveLog, function(v)
		JoinLeaveConfig.LeaveLog = v
		writefile(NAfiles.NAJOINLEAVE, HttpService:JSONEncode(JoinLeaveConfig))
		DoNotif("Leave logging "..(v and "enabled" or "disabled"), 2)
	end)

	NAgui.addToggle("Save Join/Leave Logs", JoinLeaveConfig.SaveLog, function(v)
		JoinLeaveConfig.SaveLog = v
		writefile(NAfiles.NAJOINLEAVE, HttpService:JSONEncode(JoinLeaveConfig))
		DoNotif("Join/Leave log saving has been "..(v and "enabled" or "disabled"), 2)
	end)
end

if IsOnPC then
	NAgui.addSection("Fly Keybinds")

	NAgui.addInput("Fly Keybind", "Enter Keybind", "F", function(text)
		local newKey = text:lower()
		if newKey == "" then
			DoNotif("Please provide a keybind.")
			return
		end
		flyVariables.toggleKey = newKey
		if flyVariables.keybindConn then
			flyVariables.keybindConn:Disconnect()
			flyVariables.keybindConn = nil
		end
		connectFlyKey()
		DebugNotif("Fly keybind set to '"..flyVariables.toggleKey:upper().."'")
	end)

	NAgui.addInput("vFly Keybind", "Enter Keybind", "V", function(text)
		local newKey = text:lower()
		if newKey == "" then
			DoNotif("Please provide a keybind.")
			return
		end
		flyVariables.vToggleKey = newKey
		if flyVariables.vKeybindConn then
			flyVariables.vKeybindConn:Disconnect()
		end
		connectVFlyKey()
		DebugNotif("vFly keybind set to '"..flyVariables.vToggleKey:upper().."'")
	end)

	NAgui.addInput("cFly Keybind", "Enter Keybind", "C", function(text)
		local newKey = (text or ""):lower()
		if newKey == "" then
			DoNotif("Please provide a keybind.")
			return
		end
		flyVariables.cToggleKey = newKey
		if flyVariables.cKeybindConn then
			flyVariables.cKeybindConn:Disconnect()
			flyVariables.cKeybindConn = nil
		end
		connectCFlyKey()
		DebugNotif("CFrame fly keybind set to '"..flyVariables.cToggleKey:upper().."'")
	end)

	NAgui.addInput("tFly Keybind", "Enter Keybind", "T", function(text)
		local key = (text or ""):lower()
		if key == "" then
			DoNotif("Please provide a key.")
			return
		end
		flyVariables.tflyToggleKey = key
		if flyVariables.tflyKeyConn then
			flyVariables.tflyKeyConn:Disconnect()
		end
		flyVariables.tflyKeyConn = cmdm.KeyDown:Connect(function(k)
			if k:lower() == flyVariables.tflyToggleKey then
				toggleTFly()
			end
		end)
		DebugNotif("TFly keybind set to '"..flyVariables.tflyToggleKey:upper().."'")
	end)
end

NAgui.addSection("Character Morph")
NAgui.addInput("Target User", "UserId or Username", "", function(val)
	morphTarget = val
end)
NAgui.addButton("Morph Character", function()
	if morphTarget ~= "" then
		cmd.run({"char", morphTarget})
	end
end)
NAgui.addButton("Revert Character", function()
	cmd.run({"unchar"})
end)
NAgui.addToggle("Auto Morph", false, function(state)
	if state then
		NAlib.disconnect("autochartoggle")
		NAlib.connect("autochartoggle", Players.LocalPlayer.CharacterAdded:Connect(function()
			if morphTarget ~= "" then
				cmd.run({"char", morphTarget})
			end
		end))
		if morphTarget ~= "" then
			cmd.run({"char", morphTarget})
		end
	else
		NAlib.disconnect("autochartoggle")
	end
end)

NAgui.addSection("Character Light")

NAgui.addSlider("Range",      0,  60, settingsLight.range,      1,   "", function(val) settingsLight.range      = val end)
NAgui.addSlider("Brightness", 0,   30, settingsLight.brightness, 1,   "", function(val) settingsLight.brightness = val end)
NAgui.addColorPicker("Color",  settingsLight.color, function(col) settingsLight.color = col end)

NAgui.addButton("Apply Light", function()
	local root = getRoot(Player.Character)
	if not root then return end

	local light = settingsLight.LIGHTER
	if not light or not light.Parent then
		light = InstanceNew("PointLight")
		settingsLight.LIGHTER = light
	end

	light.Parent     = root
	light.Range      = settingsLight.range
	light.Brightness = settingsLight.brightness
	light.Color      = settingsLight.color
end)

NAgui.addButton("Remove Light", function()
	if settingsLight.LIGHTER then
		settingsLight.LIGHTER:Destroy()
		settingsLight.LIGHTER = nil
	end
end)

if FileSupport and CoreGui then
	Spawn(function()
		local PT = {
			path    = NAfiles.NAFILEPATH.."/plexity_theme.json",
			default = { enabled = false, start = { h = 0.8, s = 1, v = 1 }, finish = { h = 0, s = 1, v = 1 } },
			cg      = CoreGui,
			images  = {}
		}

		if FileSupport and not isfile(PT.path) then
			writefile(PT.path, HttpService:JSONEncode(PT.default))
		end

		local raw, tbl
		if FileSupport and isfile(PT.path) then
			local ok; ok, raw = pcall(readfile, PT.path)
			if ok then
				local ok2; ok2, tbl = pcall(HttpService.JSONDecode, HttpService, raw)
				if not (ok2 and type(tbl)=="table") then tbl = nil end
			end
		end

		PT.data = tbl or PT.default

		NAmanage.plex_remove = function(o)
			local g = o:FindFirstChildOfClass("UIGradient")
			if g then g:Destroy() end
		end

		NAmanage.plex_apply = function(o)
			NAmanage.plex_remove(o)
			if PT.data.enabled then
				local seq = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromHSV(PT.data.start.h, PT.data.start.s, PT.data.start.v)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(PT.data.finish.h, PT.data.finish.s, PT.data.finish.v)),
				}
				local ug = Instance.new("UIGradient", o)
				ug.Color, ug.Rotation = seq, 45
			end
		end

		NAmanage.plex_add = function(o)
			if not PT.images[o] and (o:IsA("ImageLabel") or o:IsA("ImageButton")) then
				local id = NAlib.isProperty(o, "Image")
					or NAlib.isProperty(o, "Texture")
					or NAlib.isProperty(o, "TextureId")
				if type(id)=="string" and id:match("img_set_%dx_%d+%.png$") then
					PT.images[o] = true
					NAmanage.plex_apply(o)
				end
			end
		end

		NAmanage.plex_applyAll = function()
			for o in pairs(PT.images) do
				NAmanage.plex_apply(o)
			end
		end

		for _, o in ipairs(PT.cg:GetDescendants()) do
			NAmanage.plex_add(o)
		end

		if PT.data.enabled then
			NAlib.connect("PlexyDesc", PT.cg.DescendantAdded:Connect(NAmanage.plex_add))
		end

		NAgui.addSection("Plexity Theme")
		NAgui.addToggle("Enable Theme", PT.data.enabled, function(v)
			PT.data.enabled = v
			NAlib.disconnect("PlexyDesc")
			if v then
				NAmanage.plex_applyAll()
				NAlib.connect("PlexyDesc", PT.cg.DescendantAdded:Connect(NAmanage.plex_add))
			else
				for o in pairs(PT.images) do
					NAmanage.plex_remove(o)
				end
			end
			if FileSupport then
				writefile(PT.path, HttpService:JSONEncode(PT.data))
			end
		end)

		NAgui.addColorPicker("Gradient Start Color", Color3.fromHSV(PT.data.start.h, PT.data.start.s, PT.data.start.v), function(c)
			local h, s, v = c:ToHSV()
			PT.data.start.h, PT.data.start.s, PT.data.start.v = h, s, v
			NAmanage.plex_applyAll()
			if FileSupport then
				writefile(PT.path, HttpService:JSONEncode(PT.data))
			end
		end)

		NAgui.addColorPicker("Gradient End Color", Color3.fromHSV(PT.data.finish.h, PT.data.finish.s, PT.data.finish.v), function(c)
			local h, s, v = c:ToHSV()
			PT.data.finish.h, PT.data.finish.s, PT.data.finish.v = h, s, v
			NAmanage.plex_applyAll()
			if FileSupport then
				writefile(PT.path, HttpService:JSONEncode(PT.data))
			end
		end)
	end)
end


NAgui.addSection("Chat Tag Customization (Client Sided)")

NAgui.addInput("Tag Text", "Enter your tag", opt.currentTagText, function(inputText)
	opt.currentTagText = inputText
end)

NAgui.addColorPicker("Tag Color", opt.currentTagColor, function(color)
	opt.currentTagColor = color
end)

NAgui.addToggle("Rainbow Name", opt.currentTagRGB, function(state)
	opt.currentTagRGB = state
end)

NAgui.addButton("Apply Chat Tag", function()
	if opt.currentTagText == "" or not opt.currentTagText then
		DoNotif("Please enter a tag name before applying",2)
		return
	end

	LocalPlayer:SetAttribute("CustomNAtaggerText", opt.currentTagText)
	LocalPlayer:SetAttribute("CustomNAtaggerColor", opt.currentTagColor)
	LocalPlayer:SetAttribute("CustomNAtaggerRainbow", opt.currentTagRGB)

	if FileSupport then
		writefile(NAfiles.NACHATTAG, HttpService:JSONEncode({
			Text = opt.currentTagText;
			Color = {
				R = opt.currentTagColor.R;
				G = opt.currentTagColor.G;
				B = opt.currentTagColor.B;
			};
			RGB = opt.currentTagRGB;
			Save = true;
		}))
	end

	DebugNotif("Custom chat tag applied and saved!",2.5)
end)

NAgui.addButton("Remove Chat Tag", function()
	LocalPlayer:SetAttribute("CustomNAtaggerText", nil)
	LocalPlayer:SetAttribute("CustomNAtaggerColor", nil)
	LocalPlayer:SetAttribute("CustomNAtaggerRainbow", nil)

	if FileSupport and isfile(NAfiles.NACHATTAG) then
		writefile(NAfiles.NACHATTAG, HttpService:JSONEncode({
			Text = opt.currentTagText;
			Color = { R = opt.currentTagColor.R, G = opt.currentTagColor.G, B = opt.currentTagColor.B };
			RGB = opt.currentTagRGB;
			Save = false;
		}))
	end

	DebugNotif("Custom chat tag removed.",2.5)
end)