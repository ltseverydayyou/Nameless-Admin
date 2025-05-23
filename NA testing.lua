--[[


─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
─██████████████─██████████████─██████████████─██████████████────██████████████───██████──██████─██████████─██████─────────████████████───
─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░░░██────██░░░░░░░░░░██───██░░██──██░░██─██░░░░░░██─██░░██─────────██░░░░░░░░████─
─██████░░██████─██░░██████████─██░░██████████─██████░░██████────██░░██████░░██───██░░██──██░░██─████░░████─██░░██─────────██░░████░░░░██─
─────██░░██─────██░░██─────────██░░██─────────────██░░██────────██░░██──██░░██───██░░██──██░░██───██░░██───██░░██─────────██░░██──██░░██─
─────██░░██─────██░░██████████─██░░██████████─────██░░██────────██░░██████░░████─██░░██──██░░██───██░░██───██░░██─────────██░░██──██░░██─
─────██░░██─────██░░░░░░░░░░██─██░░░░░░░░░░██─────██░░██────────██░░░░░░░░░░░░██─██░░██──██░░██───██░░██───██░░██─────────██░░██──██░░██─
─────██░░██─────██░░██████████─██████████░░██─────██░░██────────██░░████████░░██─██░░██──██░░██───██░░██───██░░██─────────██░░██──██░░██─
─────██░░██─────██░░██─────────────────██░░██─────██░░██────────██░░██────██░░██─██░░██──██░░██───██░░██───██░░██─────────██░░██──██░░██─
─────██░░██─────██░░██████████─██████████░░██─────██░░██────────██░░████████░░██─██░░██████░░██─████░░████─██░░██████████─██░░████░░░░██─
─────██░░██─────██░░░░░░░░░░██─██░░░░░░░░░░██─────██░░██────────██░░░░░░░░░░░░██─██░░░░░░░░░░██─██░░░░░░██─██░░░░░░░░░░██─██░░░░░░░░████─
─────██████─────██████████████─██████████████─────██████────────████████████████─██████████████─██████████─██████████████─████████████───
─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


]]

if getgenv().RealNamelessLoaded then return end

function NACaller(pp)--helps me log better
	local NAsss,NAerr=pcall(pp)
	if not NAsss then warn("NA script error: "..NAerr) end
end

NACaller(function() getgenv().RealNamelessLoaded=true end)
NACaller(function() getgenv().NATestingVer=true end)
NACaller(function() getgenv().cdshkjvcdsojuefdwonjwojgrwoijuhegr="FIWUIUR" end)

NAbegin=tick()
CMDAUTOFILL = {}

local function SafeGetService(name)
	local service = game:GetService(name)
	local zeNAService = (cloneref and cloneref(service)) or service
	return zeNAService
end

local HttpService=SafeGetService('HttpService');
local Lower = string.lower;
local Split = string.split;
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
local NASCREENGUI=nil --Getmodel("rbxassetid://140418556029404")
local sessionStart = os.clock()
local cmd={}
local lib={}
cmdPluginAdd={}
cmdNAnum=0

function isAprilFools()
	local d = os.date("*t")
	return (d.month == 4 and d.day == 1) or getgenv().ActivateAprilMode or false
end

function loadOldNAUI()
	return getgenv().USEOLDNAUI or false
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

			if math.random() < 0.5 then
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

local function maybeMock(text)
	return isAprilFools() and MockText(text) or text
end

function randomString()
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
	if inst then
		if var then
			inst[var]=randomString()
			inst.Archivable=false
		else
			inst.Name=randomString()
			inst.Archivable=false
		end
	end
end

function NaProtectUI(sGui)
	local cGUI = SafeGetService("CoreGui")
	local lPlr = SafeGetService("Players").LocalPlayer

	if sGui:IsA("ScreenGui") then
		sGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		sGui.DisplayOrder = 999999999
		sGui.ResetOnSpawn = false
		sGui.IgnoreGuiInset = true
	end


	if gethui then
		NAProtection(sGui)
		sGui.Parent = gethui()
		return sGui
	elseif cGUI and cGUI:FindFirstChild("RobloxGui") then
		NAProtection(sGui)
		sGui.Parent = cGUI:FindFirstChild("RobloxGui")
		return sGui
	elseif cGUI then
		NAProtection(sGui)
		sGui.Parent = cGUI
		return sGui
	elseif lPlr and lPlr:FindFirstChild("PlayerGui") then
		NAProtection(sGui)
		sGui.Parent = lPlr:FindFirstChild("PlayerGui")
		sGui.ResetOnSpawn = false
		return sGui
	else
		return nil
	end
end

function guiCHECKINGAHHHHH()
	return (gethui and gethui()) or SafeGetService("CoreGui"):FindFirstChild("RobloxGui") or SafeGetService("CoreGui") or SafeGetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
end

function InstanceNew(c,p)
	local inst = Instance.new(c)
	if p then inst.Parent=p end
	inst.Name = randomString()
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
local curVer = isAprilFools() and Format("%d.%d.%d", math.random(1, 99), math.random(0, 99), math.random(0, 99)) or "2.4.3"

--[[ Brand ]]--
local mainName = 'Nameless Admin'
local testingName = 'NA Testing'
local adminName = 'NA'

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

if not gethui then
	getgenv().gethui=function()
		local h=(SafeGetService("CoreGui"):FindFirstChildWhichIsA("ScreenGui") or SafeGetService("CoreGui") or Players.LocalPlayer:FindFirstChild("PlayerGui"))
		return h
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

NA_storage=InstanceNew("ScreenGui")--Stupid Ahh script removing folders

if not game:IsLoaded() then
	local message = InstanceNew("Message")
	message.Text = adminName.." is waiting for the game to load"
	NaProtectUI(message)
	game.Loaded:Wait()

	repeat Wait() until SafeGetService("Players").LocalPlayer
	message:Destroy()
end

local githubUrl = ''
local loader=''
local NAUILOADER=''
local NAimageButton=nil

if getgenv().NATestingVer then
	loader=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"))();]]
	githubUrl="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?path=NA%20testing.lua"
	NAUILOADER="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/NAUITEST.lua"
else
	loader=[[loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))();]]
	githubUrl="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?path=Source.lua"
	NAUILOADER="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/NAUI.lua"
end

if loadOldNAUI() then
	NAUILOADER="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/NAUIOLD.lua"
end

local queueteleport=(syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or function() end

--Notification library
local Notification = nil

repeat
	local sssss, rerere = pcall(function()
		return loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NamelessAdminNotifications.lua"))()
	end)

	if sssss then
		Notification = rerere
	else
		warn(math.random(1,999999).." | Failed to load notification module: "..rerere.." | retrying...")
		Wait(.3)
	end
until Notification

local Notify = Notification.Notify

function DoNotif(text, duration, sender)
	text = text or "something"
	duration = duration or 5
	sender = sender or adminName

	Notify({
		Title = sender,
		Description = text,
		Duration = duration
	})
end

--Custom file functions checker checker
local CustomFunctionSupport=isfile and isfolder and writefile and readfile and listfiles;
local FileSupport = isfile and isfolder and writefile and readfile and makefolder
NAFILEPATH = "Nameless-Admin"
NAWAYPOINTFILEPATH = "Nameless-Admin/Waypoints"
NAPLUGINFILEPATH = "Nameless-Admin/Plugins"
NAPREFIXPATH = "Nameless-Admin/Prefix.txt"
NAIMAGEBUTTONSIZEPATH = "Nameless-Admin/ImageButtonSize.txt"
NAQOTPATH = "Nameless-Admin/QueueOnTeleport.txt"
NAALIASPATH = "Nameless-Admin/Aliases.json"
NAICONPOSPATH = "Nameless-Admin/IconPosition.json"
NAUSERBUTTONSPATH = "Nameless-Admin/UserButtons.json"
NAAUTOEXECPATH = "Nameless-Admin/AutoExecCommands.json"
NAPREDICTIONPATH = "Nameless-Admin/Prediction.txt"
NAUserButtons = {}
UserButtonGuiList = {}
NAEXECDATA = NAEXECDATA or {commands = {}, args = {}}
doPREDICTION = true

-- Creates folder & files for Prefix, Plugins, and etc
if FileSupport then
	if not isfolder(NAFILEPATH) then
		makefolder(NAFILEPATH)
	end

	if not isfolder(NAWAYPOINTFILEPATH) then
		makefolder(NAWAYPOINTFILEPATH)
	end

	if not isfolder(NAPLUGINFILEPATH) then
		makefolder(NAPLUGINFILEPATH)
	end

	if not isfile(NAPREFIXPATH) then
		writefile(NAPREFIXPATH, ";")
	end

	if not isfile(NAIMAGEBUTTONSIZEPATH) then
		writefile(NAIMAGEBUTTONSIZEPATH, "1")
	end

	if not isfile(NAQOTPATH) then
		writefile(NAQOTPATH, "false")
	end

	if not isfile(NAALIASPATH) then
		writefile(NAALIASPATH, "{}")
	end

	if not isfile(NAICONPOSPATH) then
		writefile(NAICONPOSPATH, HttpService:JSONEncode({
			X = 0.5,
			Y = 0.1,
			Save = false
		}))
	end

	if not isfile(NAUSERBUTTONSPATH) then
		writefile(NAUSERBUTTONSPATH, HttpService:JSONEncode({}))
	end

	if not isfile(NAAUTOEXECPATH) then
		writefile(NAAUTOEXECPATH, "[]")
	end

	if not isfile(NAPREDICTIONPATH) then
		writefile(NAPREDICTIONPATH, "true")
	end
end

local prefixCheck = ";"
local NAScale = 1
NAQoTEnabled = nil
NAiconSaveEnabled = nil
NAREQUEST = request or http_request or (syn and syn.request) or function() end

if FileSupport then
	prefixCheck = readfile(NAPREFIXPATH)
	NAsavedScale = tonumber(readfile(NAIMAGEBUTTONSIZEPATH))
	NAQoTEnabled = readfile(NAQOTPATH) == "true"
	doPREDICTION = readfile(NAPREDICTIONPATH) == "true"

	if prefixCheck == "" or utf8.len(prefixCheck) > 1 or prefixCheck:match("[%w]")
		or prefixCheck:match("[%[%]%(%)%*%^%$%%{}<>]")
		or prefixCheck:match("&amp;") or prefixCheck:match("&lt;") or prefixCheck:match("&gt;")
		or prefixCheck:match("&quot;") or prefixCheck:match("&#x27;") or prefixCheck:match("&#x60;") then

		prefixCheck = ";"
		writefile(NAPREFIXPATH, ";")
		DoNotif("Your prefix has been reset to the default (;) due to invalid symbol.")
	end

	if NAsavedScale and NAsavedScale > 0 then
		NAScale = NAsavedScale
	else
		NAScale = 1
		writefile(NAIMAGEBUTTONSIZEPATH, "1")
		DoNotif("ImageButton size has been reset to default due to invalid data.")
	end

	if isfile(NAICONPOSPATH) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(NAICONPOSPATH))
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
else
	prefixCheck = ";"
	NAScale = 1
	NAQoTEnabled = false
	NAiconSaveEnabled = false
	DoNotif("Your exploit does not support read/write file")
end

--[[ PREFIX AND OTHER STUFF. ]]--
local opt={
	prefix=prefixCheck,
	tupleSeparator=',',
	ui={},
	keybinds={},
}

local lastPrefix = opt.prefix

--[[ Update Logs ]]--
NAupdLogs = {
	log1='updlogs have been abandoned for now';
	log2='join the discord using the command "Discord" to view the update logs';
}

NAupdDate="unknown" --month,day,year

NACaller(function()
	local response = NAREQUEST({
		Url = githubUrl,
		Method = "GET"
	})

	if response and response.StatusCode == 200 then
		local json = HttpService:JSONDecode(response.Body)
		if json and json[1] and json[1].commit and json[1].commit.author and json[1].commit.author.date then
			local year, month, day = json[1].commit.author.date:match("(%d+)-(%d+)-(%d+)")
			NAupdDate = month.."/"..day.."/"..year
		end
	end
end)

--[[ VARIABLES ]]--

local PlaceId,JobId,GameId=game.PlaceId,game.JobId,game.GameId
local Players=SafeGetService("Players");
local UserInputService=SafeGetService("UserInputService");
local ProximityPromptService=SafeGetService("ProximityPromptService");
local TweenService=SafeGetService("TweenService");
local RunService=SafeGetService("RunService");
local TeleportService=SafeGetService("TeleportService");
local StarterGui=SafeGetService("StarterGui");
local SoundService=SafeGetService("SoundService");
local Lighting=SafeGetService("Lighting");
local ReplicatedStorage=SafeGetService("ReplicatedStorage");
local GuiService=SafeGetService("GuiService");
local COREGUI=SafeGetService("CoreGui");
local AvatarEditorService = SafeGetService("AvatarEditorService");
local ChatService = SafeGetService("Chat");
local TextChatService = SafeGetService("TextChatService");
local LogService = SafeGetService("LogService");
local CaptureService = SafeGetService("CaptureService");
local MarketplaceService = SafeGetService("MarketplaceService");
local TextService = SafeGetService("TextService")
local AvatarEditorService = SafeGetService("AvatarEditorService")
local IsOnMobile=false--Discover({Enum.Platform.IOS,Enum.Platform.Android},UserInputService:GetPlatform());
local IsOnPC=false--Discover({Enum.Platform.Windows,Enum.Platform.UWP,Enum.Platform.Linux,Enum.Platform.SteamOS,Enum.Platform.OSX,Enum.Platform.Chromecast,Enum.Platform.WebOS},UserInputService:GetPlatform());
local sethidden=sethiddenproperty or set_hidden_property or set_hidden_prop
local Player=Players.LocalPlayer;
local plr=Players.LocalPlayer;
local PlrGui=Player:FindFirstChild("PlayerGui");
--local IYLOADED=false--This is used for the ;iy command that executes infinite yield commands using this admin command script (BTW)
local Character=Player.Character;
local Humanoid=Character and Character:FindFirstChildWhichIsA("Humanoid") or nil;
local LegacyChat=false--TextChatService.ChatVersion==Enum.ChatVersion.LegacyChatService
local FakeLag=false
local Loopvoid=false
local loopgrab=false
local Loopmute=false
local OrgDestroyHeight = SafeGetService("Workspace").FallenPartsDestroyHeight
local Watch=false
local Admin={}
local playerButtons={}
CoreGui=COREGUI;
_G.NAadminsLol={
	530829101; --Viper
	229501685; --legshot
	817571515; --Aimlock
	144324719; --Cosmic
	1844177730; --glexinator
	2624269701; --Akim
	2502806181; --null
	1594235217; --Purple
	1620986547; --pc alt
	7269577915; --another alt
}

if UserInputService.TouchEnabled then
	IsOnMobile=true
end

if UserInputService.KeyboardEnabled then
	IsOnPC=true
end

--[[ Some more variables ]]--

localPlayer=Player
LocalPlayer=Player
local character=Player.Character
local mouse=localPlayer:GetMouse()
local camera=SafeGetService("Workspace").CurrentCamera
local Commands,Aliases={},{}
local player,plr,lp=Players.LocalPlayer,Players.LocalPlayer,Players.LocalPlayer
local ctrlModule = nil
NASAVEDALIASES = {}

Spawn(function()
	NACaller(function()
		local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule = playerScripts:WaitForChild("PlayerModule", 5)
		local controlModule = playerModule:WaitForChild("ControlModule", 5)

		local ok, result = pcall(require, controlModule)
		if ok then
			ctrlModule = result
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

UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Gamepad1 or input.UserInputType == Enum.UserInputType.Touch then
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			thumberSTICKER = input.Position
			updateInputVector()
		end
	end
end)

function GetCustomMoveVector()
	if ctrlModule then
		local success, vec = pcall(function()
			return ctrlModule:GetMoveVector()
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

	"Greetings, traveler!",
	"Greetings, Earthling!",
	"Ahoy!",
	"Welcome to the show!",
	"Boot sequence complete. Welcome!",
	"System online. Hello!",
	"Executor synced. Let's go!",
	"Ready for action!",
	"Initialization complete!",
	"Connected successfully!",
	"Teleportation successful!",
	"Code ready. Welcome!",
	"Admin mode: Activated.",
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

	cc(Commands)
	cc(Aliases)

	return bestMatch
end
pqwodwjvxnskdsfo = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
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
end
qowijjokqwd = randomahhfunctionthatyouwontgetit("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2x0c2V2ZXJ5ZGF5eW91L3V1dXV1dXUvcmVmcy9oZWFkcy9tYWluL2VuY29kZQ==")
function isRelAdmin(Player)
	for _, id in ipairs(_G.NAadminsLol) do
		if Player.UserId == id then
			return true
		end
	end
	return false
end

function nameChecker(p)
	if not lib.isProperty(p, "DisplayName") then
		return p.Name
	end

	local displayName = p.DisplayName
	if displayName:lower() == p.Name:lower() then
		return '@'..p.Name
	else
		return displayName..' (@'..p.Name..')'
	end
end

function loadedResults(res)
	local sec = tonumber(res) or 0
	local isNegative = sec < 0

	if isNegative then
		sec = math.abs(sec)
	end

	local days = math.floor(sec / 86400)
	local hours = math.floor((sec % 86400) / 3600)
	local minutes = math.floor((sec % 3600) / 60)
	local secondsFloat = sec % 60

	local seconds, fractional = math.modf(secondsFloat)
	local milliseconds = math.floor(fractional * 1000)

	local function formatTime()
		if days > 0 then
			return Format("%d:%02d:%02d:%02d.%03d | Days,Hours,Minutes,Seconds.Milliseconds",
				days, hours, minutes, seconds, milliseconds)
		elseif hours > 0 then
			return Format("%d:%02d:%02d.%03d | Hours,Minutes,Seconds.Milliseconds",
				hours, minutes, seconds, milliseconds)
		elseif minutes > 0 then
			return Format("%d:%02d.%03d | Minutes,Seconds.Milliseconds",
				minutes, seconds, milliseconds)
		else
			return Format("%d.%03d | Seconds.Milliseconds",
				seconds, milliseconds)
		end
	end

	local formatted = formatTime()
	return isNegative and ("-"..formatted) or formatted
end

LocalPlayer.OnTeleport:Connect(function(...)
	if NAQoTEnabled and queueteleport then
		queueteleport(loader)
	end
	if isAprilFools() then
		queueteleport("getgenv().ActivateAprilMode=true")
	end
	if loadOldNAUI() then
		queueteleport("getgenv().USEOLDNAUI=true")
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
			Commands[cmdName:lower()] = data
		else
			Aliases[cmdName:lower()] = data
		end
	end

	commandcount += 1
end

cmd.run = function(args)
	local caller, arguments = args[1], args
	table.remove(args, 1)

	local success, msg = pcall(function()
		local command = Commands[caller:lower()] or Aliases[caller:lower()]
		if command then
			command[1](unpack(arguments))
		else
			local closest = didYouMean(caller:lower())
			if closest and doPREDICTION then
				local commandFunc = Commands[closest] and Commands[closest][1] or Aliases[closest] and Aliases[closest][1]
				local requiresInput = Commands[closest] and Commands[closest][3] or Aliases[closest] and Aliases[closest][3]

				if requiresInput then
					Notify({
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
							},
							{
								Text = "Cancel",
								Callback = function() end
							}
						}
					})
				else
					Notify({
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
							},
							{
								Text = "Cancel",
								Callback = function() end
							}
						}
					})
				end
			end
		end
	end)
end

cmd.loop = function(commandName, args)
	local command = Commands[commandName:lower()] or Aliases[commandName:lower()]
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

	Notify({
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
			},
			{
				Text = "Cancel",
				Callback = function()
					DoNotif("Loop creation canceled.", 2)
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

	Insert(buttons, {
		Text = "Cancel",
		Callback = function()
			DoNotif("No loops were stopped.", 2)
		end
	})

	Notify({
		Title = "Stop a Loop",
		Description = "Select a loop to stop:",
		Buttons = buttons
	})
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


--[[ Fully setup Nameless admin storage ]]
NaProtectUI(NA_storage)

--[[ LIBRARY FUNCTIONS ]]--
lib.wrap=function(f)
	return coroutine.wrap(f)()
end

local wrap=lib.wrap

function rngMsg()
	return msg[math.random(1,#msg)]
end

function getRoot(char)
	if char:IsA("Player") then char = char.Character end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChildWhichIsA("BasePart") or nil
end

function getTorso(char)
	if char:IsA("Player") then char = char.Character end
	return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart") or nil
end

function getChar()
	local plr = Players.LocalPlayer
	return plr.Character
end

function getPlrChar(plr)
	local fix=plr:IsA("Player") and (plr and plr.Character) or plr or nil
	return fix
end

function getBp()
	local plr = Players.LocalPlayer
	return plr:FindFirstChildWhichIsA("Backpack")
end

function getHum()
	local char = getChar()
	return char and char:FindFirstChildWhichIsA("Humanoid") or nil
end

function getPlrHum(plr)
	local char = getPlrChar(plr)
	return char and char:FindFirstChildWhichIsA("Humanoid") or nil
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
		pcall(function()
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

CheckIfNPC = function(Character)
	if (Character and Character:IsA("Model")) and (Character:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(Character)) then
		return true
	end
end

FindInTable = function(tbl,val)
	if tbl==nil then return false end
	for _,v in pairs(tbl) do
		if v==val then return true end
	end
	return false
end

function MouseButtonFix(button,clickCallback)
	local isHolding = false
	local holdThreshold = 0.45
	local mouseDownTime = 0

	button.MouseButton1Down:Connect(function()
		isHolding = false
		mouseDownTime = tick()
	end)

	button.MouseButton1Up:Connect(function()
		local holdDuration = tick() - mouseDownTime
		if holdDuration < holdThreshold and not isHolding then
			clickCallback()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and input.UserInputState == Enum.UserInputState.Change then
			isHolding = true
		end
	end)
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

		Foreach(SafeGetService("Workspace"):GetDescendants(), function(Index, Model)
			if CheckIfNPC(Model) then
				Insert(Targets, Model)
			end
		end)

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

	["alts"] = function() -- scuffed one
		local Targets = {}

		Foreach(Players:GetPlayers(), function(_, Player)
			local Char = Player.Character
			if Char then
				local accCount = 0
				for _, item in ipairs(Char:GetChildren()) do
					if item:IsA("Accessory") then
						accCount = accCount + 1
					end
				end

				if accCount <= 1 then
					Insert(Targets, Player)
				end
			end
		end)

		return Targets
	end,
}

function getPlr(Target)
	local Target = Lower(Target);
	local Check = PlayerArgs[Target];

	if Check then
		return Check()
	else
		local Specific = {}

		Foreach(Players:GetPlayers(), function(Index, Player)
			local Name, Display = Lower(Player.Name), Lower(Player.DisplayName)

			if Sub(Name, 1, #Target) == Target then
				Insert(Specific, Player)

			elseif Sub(Display, 1, #Target) == Target then
				Insert(Specific, Player)
			end
		end)

		return Specific
	end
end

--[[ MORE VARIABLES ]]--
plr=Player
speaker=Player
char=plr.Character
deathCFrame = nil
local JSONEncode,JSONDecode=HttpService.JSONEncode,HttpService.JSONDecode

NACaller(function()
	LocalPlayer.CharacterAdded:Connect(function(c)
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

GaemInfo=nil

function placeName()
	--[[while true do
		local success, page = pcall(function()
			return SafeGetService("AssetService"):GetGamePlacesAsync()
		end)

		if success then
			while true do
				for _, place in ipairs(page:GetCurrentPage()) do
					if place.PlaceId == PlaceId then
						return place.Name
					end
				end

				if page.IsFinished then
					break
				end

				local successAdvance = pcall(function()
					page:AdvanceToNextPageAsync()
				end)

				if not successAdvance then
					break
				end
			end
		end

		Wait(.5)
	end]]
	local checking = 'unknown'
	if GaemInfo and GaemInfo.Name then checking = GaemInfo.Name end
	return checking
end

function placeCreator()
	local checkingCreator = 'unknown'
	if GaemInfo and  GaemInfo.Creator and GaemInfo.Creator.Name then checkingCreator = GaemInfo.Creator.Name end
	return checkingCreator
end

function storeESP(p, cType, conn)
	if not espCONS[p.Name] then
		espCONS[p.Name] = {}
	end
	Insert(espCONS[p.Name], {type = cType, connection = conn})
end

function discPlrESP(player)
	if espCONS[player.Name] then
		for _, entry in ipairs(espCONS[player.Name]) do
			if entry.connection then
				entry.connection:Disconnect()
			end
		end
		espCONS[player.Name] = nil
	end
	removeESPonLEAVE(player)
end

function removeAllESP()
	for _, esp in pairs(espCONS) do
		if esp.highlight then esp.highlight:Destroy() end
		if esp.billboard then esp.billboard:Destroy() end
		if esp.connection then esp.connection:Disconnect() end
	end
	table.clear(espCONS)
end

function removeESPonLEAVE(player)
	local esp = espCONS[player]
	if esp then
		if esp.highlight then esp.highlight:Destroy() end
		if esp.billboard then esp.billboard:Destroy() end
		if esp.connection then esp.connection:Disconnect() end
		espCONS[player] = nil
	end
end

function NAESP(player, persistent)
	persistent = persistent or false

	Spawn(function()
		discPlrESP(player)

		local character = getPlrChar(player)
		if not character or player == Players.LocalPlayer then return end

		if espCONS[player] then
			if espCONS[player].highlight then espCONS[player].highlight:Destroy() end
			if espCONS[player].billboard then espCONS[player].billboard:Destroy() end
			if espCONS[player].connection then espCONS[player].connection:Disconnect() end
		end

		local highlight = InstanceNew("Highlight")
		highlight.Name = "\0"
		highlight.FillTransparency = 0.6
		highlight.OutlineTransparency = 0
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.Parent = character

		local billboardGui, textLabel
		local lastTextColor = nil
		local lastFillColor = nil

		if character:FindFirstChild("Head") and not chamsEnabled then
			billboardGui = InstanceNew("BillboardGui")
			billboardGui.Name = "\0"
			billboardGui.Size = UDim2.new(0, 200, 0, 50)
			billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
			billboardGui.AlwaysOnTop = true
			billboardGui.Parent = character.Head

			textLabel = InstanceNew("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.Position = UDim2.new(0, 0, 0, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.TextColor3 = Color3.new(1, 1, 1)
			textLabel.Font = Enum.Font.GothamBold
			textLabel.TextSize = 14
			textLabel.TextStrokeTransparency = 0.2
			textLabel.Text = ""
			textLabel.Parent = billboardGui
		end

		local localChar = getPlrChar(Players.LocalPlayer)
		local localRoot = localChar and getRoot(localChar)

		local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local espLoop

		espLoop = RunService.RenderStepped:Connect(function()
			if not character:IsDescendantOf(workspace) then
				espLoop:Disconnect()
				return
			end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local rootPart = getRoot(character)
			local isValid = humanoid and rootPart and localRoot

			if isValid then
				local health = math.floor(humanoid.Health)
				local maxHealth = math.floor(humanoid.MaxHealth)
				local distance = math.floor((localRoot.Position - rootPart.Position).Magnitude)

				local distanceColor = distance < 50 and Color3.fromRGB(255, 0, 0)
					or distance < 100 and Color3.fromRGB(255, 165, 0)
					or Color3.fromRGB(0, 255, 0)

				local hasTeam, teamColor = pcall(function()
					return player.Team.TeamColor.Color
				end)

				local targetColor = hasTeam and teamColor or distanceColor

				if textLabel then
					local newText = Format("%s | %d/%d HP | %d studs", nameChecker(player), health, maxHealth, distance)
					if textLabel.Text ~= newText then
						textLabel.Text = newText
					end
					if textLabel.TextColor3 ~= distanceColor and lastTextColor ~= distanceColor then
						lastTextColor = distanceColor
						TweenService:Create(textLabel, tweenInfo, { TextColor3 = distanceColor }):Play()
					end
				end

				if highlight.FillColor ~= targetColor and lastFillColor ~= targetColor then
					lastFillColor = targetColor
					TweenService:Create(highlight, tweenInfo, { FillColor = targetColor }):Play()
				end
			end
		end)

		espCONS[player] = {
			highlight = highlight,
			billboard = billboardGui,
			connection = espLoop
		}

		if not player:IsA("Model") then
			local characterAddedConnection
			characterAddedConnection = player.CharacterAdded:Connect(function()
				if not ESPenabled and not persistent then
					characterAddedConnection:Disconnect()
					return
				end

				local char = player.Character or player.CharacterAdded:Wait()

				if espCONS[player] then
					if espCONS[player].highlight then espCONS[player].highlight:Destroy() end
					if espCONS[player].billboard then espCONS[player].billboard:Destroy() end
					if espCONS[player].connection then espCONS[player].connection:Disconnect() end
					espCONS[player] = nil
				end

				Wait(0.5)
				NAESP(player, persistent)
			end)

			storeESP(player, "characterAdded", characterAddedConnection)
		end
	end)
end

--[[local Signal1, Signal2 = nil, nil
local flyMobile, MobileWeld = nil, nil

function mobilefly(speed, vfly)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if flyMobile then flyMobile:Destroy() end
	flyMobile = InstanceNew("Part", SafeGetService("Workspace").CurrentCamera)
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

	local camera = SafeGetService("Workspace").CurrentCamera

	Signal2 = RunService.RenderStepped:Connect(function()
		local character = getChar()
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local bv = flyMobile and flyMobile:FindFirstChildWhichIsA("BodyVelocity")
		local bg = flyMobile and flyMobile:FindFirstChildWhichIsA("BodyGyro")

		if character and humanoid and flyMobile and MobileWeld and bv and bg then
			bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			if not vfly then
				getHum().PlatformStand = true
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
		getHum().PlatformStand = false
	end
	if Signal1 then Signal1:Disconnect() end
	if Signal2 then Signal2:Disconnect() end
end]]

local tool
if getChar() and getBp() then
	tool=getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
end

function xxRAYYYY(v)
	if v then
		for _,i in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if i:IsA("BasePart") and not i.Parent:FindFirstChild("Humanoid") and not i.Parent.Parent:FindFirstChild("Humanoid") then
				i.LocalTransparencyModifier=0.5
			end
		end
	else
		for _,i in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if i:IsA("BasePart") and not i.Parent:FindFirstChild("Humanoid") and not i.Parent.Parent:FindFirstChild("Humanoid") then
				i.LocalTransparencyModifier=0
			end
		end
	end
end

-- [[ FLY VARIABLES ]] --

mOn = false
mFlyBruh = nil
flyEnabled = false
toggleKey = "f"
flySpeed = 1
keybindConn = nil

vOn = false
vRAHH = nil
vFlyEnabled = false
vToggleKey = "v"
vFlySpeed = 1
vKeybindConn = nil

cOn = false
cFlyGUI = nil
cFlyEnabled = false
cToggleKey = "c"
cFlySpeed = 1
cKeybindConn = nil

TFlyEnabled = false
tflyCORE = nil
tflyToggleKey = "t"
tflyButtonUI = nil
TFLYBTN = nil
tflyKeyConn = nil
TflySpeed = 2

-----------------------------

local cmdlp = Players.LocalPlayer
plr = cmdlp
local cmdm = plr:GetMouse()
goofyFLY = nil

function sFLY(vfly, cfly)
	while not cmdlp or not cmdlp.Character or not getRoot(cmdlp.Character) or not cmdlp.Character:FindFirstChild("Humanoid") or not cmdm do
		Wait()
	end

	if goofyFLY then goofyFLY:Destroy() end
	if CFloop then CFloop:Disconnect() CFloop = nil end

	local char = cmdlp.Character
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local Head = char:WaitForChild("Head")
	local root = getRoot(char)
	if not root then return end

	local Camera = SafeGetService("Workspace").CurrentCamera

	goofyFLY = InstanceNew("Part", Camera)
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

		CFloop = RunService.Heartbeat:Connect(function()
			local moveVec = GetCustomMoveVector()
			local vertical = (CONTROL.E + CONTROL.Q)
			local fullMove = Vector3.new(moveVec.X, vertical, -moveVec.Z)

			local moveDirection =
				(Camera.CFrame.RightVector * fullMove.X) +
				(Camera.CFrame.UpVector * fullMove.Y) +
				(Camera.CFrame.LookVector * fullMove.Z)

			if moveDirection.Magnitude > 0 then
				local newPos = Head.Position + moveDirection.Unit * flySpeed
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
					SPEED = (vfly and vFlySpeed or flySpeed) * 50
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

function readAliasFile()
	if FileSupport and isfile(NAALIASPATH) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(NAALIASPATH))
		end)
		if success and type(data) == "table" then
			return data
		end
	end
	return {}
end

function loadAliases()
	local aliasMap = readAliasFile()
	for alias, original in pairs(aliasMap) do
		if Commands[original:lower()] then
			local command = Commands[original:lower()]
			Aliases[alias:lower()] = {command[1], command[2], command[3]}
			NASAVEDALIASES[alias:lower()] = true
		end
	end
end

function loadButtonIDS()
	if FileSupport and isfile(NAUSERBUTTONSPATH) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(NAUSERBUTTONSPATH))
		end)
		if success and type(data) == "table" then
			NAUserButtons = data
		end
	end
end

function loadAutoExec()
	NAEXECDATA = {commands = {}, args = {}}

	if FileSupport and isfile(NAAUTOEXECPATH) then
		local success, decoded = pcall(function()
			return HttpService:JSONDecode(readfile(NAAUTOEXECPATH))
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

local function LoadPlugins()
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

	local files = listfiles(NAPLUGINFILEPATH)

	for _, file in ipairs(files) do
		if Lower(file):match("%.na$") then
			local success, content = pcall(readfile, file)
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

					local ok, execErr = pcall(func)
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
								DoNotif("[Plugin Invalid] '"..file.."' is missing valid Aliases or Function")
							end
						end

						if #fileCommandNames > 0 then
							local fileName = file:match("[^\\/]+$") or file
							Insert(loadedSummaries, fileName.." ("..Concat(fileCommandNames, ", ")..")")
						end
					else
						DoNotif("[Plugin Error] '"..file.."' => "..tostring(execErr))
					end
				else
					DoNotif("[Plugin Load Error] '"..file.."': "..tostring(loadErr))
				end
			else
				DoNotif("[Plugin Read Error] Failed to read '"..file.."'")
			end
		end
	end

	if #loadedSummaries > 0 then
		DoNotif("Loaded plugins:\n\n"..Concat(loadedSummaries, "\n\n"), 6)
	end
end

function RenderUserButtons()
	for _, btn in pairs(UserButtonGuiList) do
		btn:Destroy()
	end
	table.clear(UserButtonGuiList)

	local SavedArguments = {}
	local ActivePrompts = {}

	function ButtonInputPrompt(commandName, callback)
		local promptGui = InstanceNew("ScreenGui")
		promptGui.IgnoreGuiInset = true
		promptGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		promptGui.Parent = NASCREENGUI

		local frame = InstanceNew("Frame")
		frame.Size = UDim2.new(0, 260, 0, 140)
		frame.Position = UDim2.new(0.5, -130, 0.5, -70)
		frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		frame.BorderSizePixel = 0
		frame.Parent = promptGui

		local corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0.1, 0)
		corner.Parent = frame

		local title = InstanceNew("TextLabel")
		title.Size = UDim2.new(1, -20, 0, 30)
		title.Position = UDim2.new(0, 10, 0, 10)
		title.BackgroundTransparency = 1
		title.Text = "Arguments for: "..commandName
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 16
		title.TextWrapped = true
		title.Parent = frame

		local textbox = InstanceNew("TextBox")
		textbox.Size = UDim2.new(1, -20, 0, 30)
		textbox.Position = UDim2.new(0, 10, 0, 50)
		textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
		textbox.PlaceholderText = "Type arguments here"
		textbox.Text = ""
		textbox.TextSize = 16
		textbox.Font = Enum.Font.Gotham
		textbox.ClearTextOnFocus = false
		textbox.Parent = frame

		local submit = InstanceNew("TextButton")
		submit.Size = UDim2.new(0.5, -15, 0, 30)
		submit.Position = UDim2.new(0, 10, 1, -40)
		submit.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		submit.Text = "Submit"
		submit.TextColor3 = Color3.fromRGB(255, 255, 255)
		submit.Font = Enum.Font.GothamBold
		submit.TextSize = 14
		submit.Parent = frame

		local cancel = InstanceNew("TextButton")
		cancel.Size = UDim2.new(0.5, -15, 0, 30)
		cancel.Position = UDim2.new(0.5, 5, 1, -40)
		cancel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		cancel.Text = "Cancel"
		cancel.TextColor3 = Color3.fromRGB(255, 255, 255)
		cancel.Font = Enum.Font.GothamBold
		cancel.TextSize = 14
		cancel.Parent = frame

		MouseButtonFix(submit,function()
			Spawn(function()
				callback(textbox.Text)
			end)
			if ActivePrompts then
				ActivePrompts[commandName] = nil
			end
			promptGui:Destroy()
		end)

		MouseButtonFix(cancel,function()
			if ActivePrompts then
				ActivePrompts[commandName] = nil
			end
			promptGui:Destroy()
		end)

		gui.draggablev2(frame)
	end

	local totalButtons = #NAUserButtons
	local totalWidth = totalButtons * (100 + 10)
	local startX = 0.5 - (totalWidth / 2) / NASCREENGUI.AbsoluteSize.X
	local spacing = 110
	local TOGGLE_COLOR_ON = Color3.fromRGB(0, 170, 0)
	local TOGGLE_COLOR_OFF = Color3.fromRGB(30, 30, 30)

	local index = 0
	for id, data in pairs(NAUserButtons) do
		local btn = InstanceNew("TextButton")
		btn.Name = "NAUserButton_"..id
		btn.Text = data.Label
		btn.Size = UDim2.new(0, 60, 0, 60)
		btn.AnchorPoint = Vector2.new(0.5, 1)
		btn.Position = UDim2.new(startX + (spacing * index) / NASCREENGUI.AbsoluteSize.X, 0, 0.9, 0)
		btn.Parent = NASCREENGUI
		btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.BorderSizePixel = 0
		btn.ZIndex = 9999
		btn.AutoButtonColor = true

		local corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0.25, 0)
		corner.Parent = btn

		gui.draggablev2(btn)

		local toggled = false
		local saveEnabled = data.RunMode == "S"
		SavedArguments[id] = data.Args or {}

		local cmdToRun = data.Cmd1
		local commandData = Commands[cmdToRun:lower()] or Aliases[cmdToRun:lower()]
		local requiresArgs = commandData and commandData[3]

		if requiresArgs then
			local saveToggle = InstanceNew("TextButton")
			saveToggle.Size = UDim2.new(0, 20, 0, 20)
			saveToggle.Position = UDim2.new(1, -15, 0, -10)
			saveToggle.AnchorPoint = Vector2.new(0.5, 0)
			saveToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			saveToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
			saveToggle.TextSize = 12
			saveToggle.Font = Enum.Font.Gotham
			saveToggle.Text = saveEnabled and "S" or "N"
			saveToggle.ZIndex = 10000
			saveToggle.Parent = btn

			MouseButtonFix(saveToggle, function()
				saveEnabled = not saveEnabled
				saveToggle.Text = saveEnabled and "S" or "N"
				data.RunMode = saveEnabled and "S" or "N"
				if FileSupport then
					writefile(NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
				end
			end)
		end

		MouseButtonFix(btn, function()
			local cmdToRunNow
			if not toggled or not data.Cmd2 then
				cmdToRunNow = data.Cmd1
			else
				cmdToRunNow = data.Cmd2
			end

			local commandDataNow = Commands[cmdToRunNow:lower()] or Aliases[cmdToRunNow:lower()]
			local requiresArgsNow = commandDataNow and commandDataNow[3]

			local function runCommand(parsedArguments)
				local finalArgs = {cmdToRunNow}
				if parsedArguments then
					for _, v in ipairs(parsedArguments) do
						Insert(finalArgs, v)
					end
				end
				cmd.run(finalArgs)
			
				if data.Cmd2 then
					toggled = not toggled
					btn.BackgroundColor3 = toggled and TOGGLE_COLOR_ON or TOGGLE_COLOR_OFF
				end
			end

			if requiresArgsNow then
				if saveEnabled and data.Args and #data.Args > 0 then
					runCommand(data.Args)
				else
					if ActivePrompts[cmdToRunNow] then
						return
					end

					ActivePrompts[cmdToRunNow] = true
					ButtonInputPrompt(cmdToRunNow, function(input)
						ActivePrompts[cmdToRunNow] = nil
						local parsedArguments = ParseArguments(input)
						if parsedArguments then
							SavedArguments[id] = parsedArguments
							data.Args = parsedArguments
							if FileSupport then
								writefile(NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
							end
							runCommand(parsedArguments)
						else
							runCommand(nil)
						end
					end)
				end
			else
				runCommand(nil)
			end
		end)

		Insert(UserButtonGuiList, btn)
		index = index + 1
	end
end

local lp=Players.LocalPlayer

--[[ LIB FUNCTIONS ]]--
chatmsgshooks={}
Playerchats={}

lib.LocalPlayerChat=function(...)
	local args={...}
	if TextChatService:FindFirstChild("TextChannels") then
		local sendto=TextChatService.TextChannels.RBXGeneral
		if args[2]~=nil and  args[2]~="All"  then
			if not Playerchats[args[2]] then
				for i,v in pairs(TextChatService.TextChannels:GetChildren()) do
					if Find(v.Name,"RBXWhisper:") then
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
			if sendto==TextChatService.TextChannels.RBXGeneral then
				chatmsgshooks[args[1]]={args[1],args}
				Spawn(function()
					TextChatService.TextChannels.RBXGeneral:SendAsync("/w @"..args[2])
				end)
				return "Hooking"
			end
		end
		sendto:SendAsync(args[1] or "")
	else
		if args[2] and args[2]~="All" then
			ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w "..args[2].." "..args[1] or "","All")
		else
			ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(args[1] or "","All")
		end
	end
end

if TextChatService:FindFirstChild("TextChannels") then
	TextChatService.TextChannels.ChildAdded:Connect(function(v)
		if Find(v.Name,"RBXWhisper:") then
			Wait(1)
			for id,va in pairs(chatmsgshooks) do
				if v:FindFirstChild(va[1]) and v:FindFirstChild(Players.LocalPlayer.Name) then
					if v[Players.LocalPlayer.Name].CanSend==false then
						continue
					end
					Playerchats[va[1]]=v
					chatmsgshooks[id]=nil
					lib.LocalPlayerChat(va[2])
					break
				end
			end
		end
	end)
end

lib.lpchat=lib.LocalPlayerChat

lib.find=function(t,v)	--mmmmmm
	for i,e in pairs(t) do
		if i==v or e==v then
			return i
		end
	end
	return nil
end

lib.parseText = function(text, watch, rPlr)
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

lib.parseCommand = function(text, rPlr)
	wrap(function()
		local prefix = rPlr and (isRelAdmin(rPlr) and not isRelAdmin(Players.LocalPlayer) and ";" or nil) or opt.prefix
		if not prefix then return end
		local commands = lib.parseText(text, prefix, rPlr)
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

lib.connect = function(name, connection)
	connections[name] = connections[name] or {}
	Insert(connections[name], connection)
	return connection
end

lib.disconnect = function(name)
	if connections[name] then
		for _, conn in ipairs(connections[name]) do
			conn:Disconnect()
		end
		connections[name] = nil
	end
end

lib.isConnected = function(name)
    return connections[name] ~= nil
end

lib.isProperty = function(inst,prop)
	local s, r = pcall(function()
		return inst[prop]
	end)
	if not s then return nil end
	return r
end

lib.setProperty = function(inst,prop,v)
	local s, _ = pcall(function()
		inst[prop] = v
	end)
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

	local success, result = pcall(function()
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

	if not Commands[original] then
		DoNotif("Command '"..original.."' does not exist", 2)
		return
	end

	if Commands[alias] or Aliases[alias] then
		DoNotif("The name '"..alias.."' is already used by another command or alias", 2)
		return
	end

	local command = Commands[original]
	Aliases[alias] = {command[1], command[2], command[3]}
	NASAVEDALIASES[alias] = true

	if FileSupport then
		local aliasMap = readAliasFile()
		aliasMap[alias] = original
		writefile(NAALIASPATH, HttpService:JSONEncode(aliasMap))
	end

	DoNotif("Alias '"..alias.."' has been added for command '"..original.."'", 2)
end, true)

cmd.add({"removealias"}, {"removealias", "Select and remove a saved alias"}, function()
	local aliasMap = FileSupport and readAliasFile() or {}

	if next(aliasMap) == nil then
		DoNotif("No saved aliases to remove", 2)
		return
	end

	local buttons = {}

	for alias, original in pairs(aliasMap) do
		Insert(buttons, {
			Text = 'Alias: '..alias.." | Command: "..original,
			Callback = function()
				Aliases[alias] = nil
				aliasMap[alias] = nil
				if FileSupport then
					writefile(NAALIASPATH, HttpService:JSONEncode(aliasMap))
				end
				DoNotif("Removed alias '"..alias.."'", 2)
			end
		})
	end

	Insert(buttons, {
		Text = "Cancel",
		Callback = function()
			DoNotif("Alias removal cancelled", 2)
		end
	})

	Notify({
		Title = "Remove Alias",
		Description = "Select an alias to remove:",
		Buttons = buttons
	})
end)

cmd.add({"clearaliases"}, {"clearaliases", "Removes all aliases created using addalias."}, function()
	if not FileSupport then return end

	for alias in pairs(NASAVEDALIASES) do
		Aliases[alias] = nil
	end

	NASAVEDALIASES = {}
	writefile(NAALIASPATH, "{}")
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
		writefile(NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
	end

	RenderUserButtons()

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
					writefile(NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
				end

				RenderUserButtons()

				DoNotif("Removed user button: ["..id.."] "..label, 2)
			end
		})
	end

	Insert(options, {
		Text = "Cancel",
		Callback = function()
			DoNotif("Cancelled removing button", 2)
		end
	})

	Notify({
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

	Notify({
		Title = "Clear All Buttons",
		Description = "Are you sure you want to clear all user buttons?",
		Buttons = {
			{
				Text = "Yes",
				Callback = function()
					table.clear(NAUserButtons)

					if FileSupport then
						writefile(NAUSERBUTTONSPATH, HttpService:JSONEncode(NAUserButtons))
					end

					RenderUserButtons()

					DoNotif("Cleared all user buttons", 2)
				end
			},
			{
				Text = "Cancel",
				Callback = function()
					DoNotif("Cancelled clearing buttons", 2)
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

	if not Commands[commandName] and not Aliases[commandName] then
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
		writefile(NAAUTOEXECPATH, HttpService:JSONEncode(NAEXECDATA))
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
					writefile(NAAUTOEXECPATH, HttpService:JSONEncode(NAEXECDATA))
				end

				DoNotif("Removed AutoExec command: "..display, 2)
			end
		})
	end

	Insert(options, {
		Text = "Cancel",
		Callback = function()
			DoNotif("Cancelled removing AutoExec", 2)
		end
	})

	Notify({
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
		writefile(NAAUTOEXECPATH, HttpService:JSONEncode(NAEXECDATA))
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

cmd.add({"stoploop"}, {"stoploop", "Stop a running loop"}, function()
	cmd.stopLoop()
end)

if IsOnMobile then
	local scaleFrame = nil
	cmd.add({"guiscale", "guisize", "gsize", "gscale"}, {"guiscale (guisize, gsize, gscale)", "Adjust the scale of the "..adminName.." button"}, function()
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

		local sizeRange = {0.5, 3}
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
		progress.Size = UDim2.new((NAScale - minSize) / (maxSize - minSize), 0, 1, 0)
		progress.BorderSizePixel = 0

		progressCorner.CornerRadius = UDim.new(0.5, 0)
		progressCorner.Parent = progress

		knob.Parent = slider
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Size = UDim2.new(0, 25, 1.5, 0)
		knob.Position = UDim2.new((NAScale - minSize) / (maxSize - minSize), 0, -0.25, 0)
		knob.Text = ""
		knob.BorderSizePixel = 0
		knob.AutoButtonColor = false

		knobCorner.CornerRadius = UDim.new(1, 0)
		knobCorner.Parent = knob

		label.Parent = frame
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0.3, 0)
		label.Position = UDim2.new(0, 0, 0.1, 0)
		label.Text = "Scale: "..Format("%.2f", NAScale)
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
			NAimageButton.Size = UDim2.new(0, 32 * scale, 0, 33 * scale)
			progress.Size = UDim2.new((scale - minSize) / (maxSize - minSize) + 0.05, 0, 1, 0)
			knob.Position = UDim2.new((scale - minSize) / (maxSize - minSize), 0, -0.25, 0)
			label.Text = "Scale: "..Format("%.2f", scale)
		end

		update(NAScale)

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
							writefile(NAIMAGEBUTTONSIZEPATH, tostring(NAScale))
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
				NAScale = math.clamp(newScale, minSize, maxSize)
				update(NAScale)
			end
		end)

		MouseButtonFix(closeButton,function()
			scaleFrame:Destroy()
		end)

		gui.draggablev2(frame)
	end)

	cmd.add({"keepiconpos", "kip", "saveicon", "kpos"}, {"keepiconpos (kip, saveicon, kpos)", "Save current icon position"}, function()
		if FileSupport then
			local pos = NAimageButton.Position
			writefile(NAICONPOSPATH, HttpService:JSONEncode({
				X = pos.X.Scale,
				Y = pos.Y.Scale,
				Save = true
			}))
			NAiconSaveEnabled = true
			DoNotif("Icon position saved", 2)
		else
			DoNotif("Your exploit does not support file saving", 2)
		end
	end)

	cmd.add({"forgeticonpos", "fip", "reseticon", "rpos"}, {"forgeticonpos (fip, reseticon, rpos)", "Reset icon position to default"}, function()
		if FileSupport then
			writefile(NAICONPOSPATH, HttpService:JSONEncode({
				X = 0.5,
				Y = 0.1,
				Save = false
			}))
		end
		NAimageButton.Position = UDim2.new(0.5, 0, 0.1, 0)
		NAiconSaveEnabled = false
		DoNotif("Icon position reset to default", 2)
	end)

end

cmd.add({"scripthub","hub"},{"scripthub (hub)","Thanks to scriptblox api"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/ScriptHubNA.lua"))()
end)

--[[cmd.add({"resizechat","rc"},{"resizechat (rc)","Makes chat resizable and draggable"},function()
	require(ChatService.ClientChatModules.ChatSettings).WindowResizable=true
	require(ChatService.ClientChatModules.ChatSettings).WindowDraggable=true
end)]]

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
		writefile(NAPREFIXPATH, newPrefix)
		opt.prefix = newPrefix
		DoNotif("Prefix saved to: "..newPrefix)
	end
end, true)

--[ UTILITY ]--

cmd.add({"chatlogs","clogs"},{"chatlogs (clogs)","Open the chat logs"},function()
	gui.chatlogs()
end)

cmd.add({"gotocampos","tocampos","tcp"},{"gotocampos (tocampos,tcp)","Teleports you to your camera position works with free cam but freezes you"},function()
	local player=Players.LocalPlayer
	local UserInputService=UserInputService
	function teleportPlayer()
		local character=player.Character or player.CharacterAdded:wait(1)
		local camera=SafeGetService("Workspace").CurrentCamera
		local cameraPosition=camera.CFrame.Position
		character:SetPrimaryPartCFrame(CFrame.new(cameraPosition))
	end
	local camera=SafeGetService("Workspace").CurrentCamera
	repeat Wait() until camera.CFrame~=CFrame.new()

	teleportPlayer()
end)

cmd.add({"teleportgui","tpui","universeviewer","uviewer"},{"teleportgui (tpui,universeviewer,uviewer)","Gives an UI that grabs all places and teleports you by clicking a simple button"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer"))();
end)

cmd.add({"serverremotespy","srs","sremotespy"},{"serverremotespy (srs,sremotespy)","Gives an UI that logs all the remotes being called from the server (thanks SolSpy lol)"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Server%20Spy.lua"))()
end)

cmd.add({"updatelog","updlog","updates"},{"updatelog (updlog,updates)","show the update logs for Nameless Admin"},function()
	gui.updateLogs()
end)

cmd.add({"discord", "invite", "support", "help"}, {"discord (invite, support, help)", "Copy an invite link"}, function()
	local inviteLink = "https://discord.gg/zzjYhtMGFD"

	if setclipboard then
		Notify({
			Title = "Discord",
			Description = inviteLink,
			Buttons = {
				{Text = "Copy Link", Callback = function() setclipboard(inviteLink) end},
				{Text = "Close", Callback = function() end}
			}
		})
	else
		Notify({
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

cmd.add({"clickfling","mousefling"}, {"clickfling (mousefling)", "Fling a player by clicking them"}, function()
	clickflingEnabled = true
	if clickflingUI then clickflingUI:Destroy() end
	lib.disconnect("clickfling_mouse")

	local Mouse = player:GetMouse()
	clickflingUI = InstanceNew("ScreenGui")
	NaProtectUI(clickflingUI)

	local toggleButton = InstanceNew("TextButton")
	toggleButton.Size = UDim2.new(0, 120, 0, 40)
	toggleButton.Text = "ClickFling: ON"
	toggleButton.Position = UDim2.new(0.5, -60, 0, 10)
	toggleButton.TextScaled = 16
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toggleButton.BackgroundTransparency = 0.2
	toggleButton.Parent = clickflingUI

	local uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = toggleButton

	gui.draggablev2(toggleButton)

	MouseButtonFix(toggleButton, function()
		clickflingEnabled = not clickflingEnabled
		if clickflingEnabled then
			toggleButton.Text = "ClickFling: ON"
		else
			toggleButton.Text = "ClickFling: OFF"
		end
	end)

	lib.connect("clickfling_mouse", Mouse.Button1Down:Connect(function()
		if not clickflingEnabled then return end
		local Target = Mouse.Target
		if Target and Target.Parent and Target.Parent:IsA("Model") and Players:GetPlayerFromCharacter(Target.Parent) then
			local PlayerName = Players:GetPlayerFromCharacter(Target.Parent).Name
			local player = Players.LocalPlayer
			local Targets = {PlayerName}
			local Players = game:GetService("Players")
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
								return x;
							elseif x.DisplayName:lower():match("^"..Name) then
								return x;
							end
						end
					end
				else
					return
				end
			end

			local Message = function(_Title, _Text, Time)
				print(_Title)
				print(_Text)
				print(Time)
			end

			local SkidFling = function(TargetPlayer)
				local Character = Player.Character
				local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
				local RootPart = Humanoid and Humanoid.RootPart

				local TCharacter = TargetPlayer.Character
				local THumanoid
				local TRootPart
				local THead
				local Accessory
				local Handle

				if TCharacter:FindFirstChildOfClass("Humanoid") then
					THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
				end
				if THumanoid and THumanoid.RootPart then
					TRootPart = THumanoid.RootPart
				end
				if TCharacter:FindFirstChild("Head") then
					THead = TCharacter:FindFirstChild("Head")
				end
				if TCharacter:FindFirstChildOfClass("Accessory") then
					Accessory = TCharacter:FindFirstChildOfClass("Accessory")
				end
				if Accessory and Accessory:FindFirstChild("Handle") then
					Handle = Accessory.Handle
				end

				if Character and Humanoid and RootPart then
					if not getgenv().OldPos or RootPart.Velocity.Magnitude < 50 then
						getgenv().OldPos = RootPart.CFrame
					end
					if THumanoid and THumanoid.Sit and not AllBool then
					end
					if THead then
						SafeGetService("Workspace").CurrentCamera.CameraSubject = THead
					elseif not THead and Handle then
						SafeGetService("Workspace").CurrentCamera.CameraSubject = Handle
					elseif THumanoid and TRootPart then
						SafeGetService("Workspace").CurrentCamera.CameraSubject = THumanoid
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
					end

					SafeGetService("Workspace").FallenPartsDestroyHeight = 0/0

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
					end

					BV:Destroy()
					Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
					SafeGetService("Workspace").CurrentCamera.CameraSubject = Humanoid

					repeat
						RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
						Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
						Humanoid:ChangeState("GettingUp")
						Foreach(Character:GetChildren(), function(_, x)
							if x:IsA("BasePart") then
								x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
							end
						end)
						Wait()
					until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
					SafeGetService("Workspace").FallenPartsDestroyHeight = getgenv().FPDH
				else
				end
			end

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
					else
					end
				elseif not GetPlayer(x) and not AllBool then
				end
			end
		end
	end))
	Insert(clickConnections, conn)
end)

cmd.add({"unclickfling", "unmousefling"}, {"unclickfling (unmousefling)","disables clickfling"}, function()
	clickflingEnabled = false
	if clickflingUI then clickflingUI:Destroy() end
	lib.disconnect("clickfling_mouse")
end)

cmd.add({"ping"}, {"ping", "Shows your ping"}, function()
	local function createWindow(position, maxSize, minSize, defaultText)
		local screenGui = InstanceNew("ScreenGui")
		NaProtectUI(screenGui)
		screenGui.ResetOnSpawn = false

		local window = InstanceNew("TextLabel")
		window.Parent = screenGui
		window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		window.BackgroundTransparency = 0.2
		window.Position = position
		window.Size = maxSize
		window.Font = Enum.Font.GothamSemibold
		window.Text = defaultText
		window.TextColor3 = Color3.fromRGB(255, 255, 255)
		window.TextSize = 16
		window.TextXAlignment = Enum.TextXAlignment.Center
		window.TextWrapped = true

		local uiCorner = InstanceNew("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 10)
		uiCorner.Parent = window

		local uiStroke = InstanceNew("UIStroke")
		uiStroke.Color = Color3.fromRGB(100, 100, 255)
		uiStroke.Thickness = 1.5
		uiStroke.Parent = window

		local closeButton = InstanceNew("TextButton")
		closeButton.Parent = window
		closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		closeButton.Position = UDim2.new(1, -25, 0.5, -10)
		closeButton.Size = UDim2.new(0, 20, 0, 20)
		closeButton.Font = Enum.Font.GothamBold
		closeButton.Text = "X"
		closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeButton.TextSize = 14
		closeButton.ZIndex = 10

		local closeUICorner = InstanceNew("UICorner")
		closeUICorner.CornerRadius = UDim.new(0, 10)
		closeUICorner.Parent = closeButton

		local minimizeButton = InstanceNew("TextButton")
		minimizeButton.Parent = window
		minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
		minimizeButton.Position = UDim2.new(1, -50, 0.5, -10)
		minimizeButton.Size = UDim2.new(0, 20, 0, 20)
		minimizeButton.Font = Enum.Font.GothamBold
		minimizeButton.Text = "-"
		minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		minimizeButton.TextSize = 14
		minimizeButton.ZIndex = 10

		local minUICorner = InstanceNew("UICorner")
		minUICorner.CornerRadius = UDim.new(0, 10)
		minUICorner.Parent = minimizeButton

		return {
			screenGui = screenGui,
			window = window,
			closeButton = closeButton,
			minimizeButton = minimizeButton,
			maxSize = maxSize,
			minSize = minSize,
			defaultText = defaultText,
			minimized = false
		}
	end

	local function setupMinimize(guiElements)
		MouseButtonFix(guiElements.minimizeButton, function()
			guiElements.minimized = not guiElements.minimized
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local targetSize = guiElements.minimized and guiElements.minSize or guiElements.maxSize
			local tween = TweenService:Create(guiElements.window, tweenInfo, {Size = targetSize})
			tween:Play()
			if guiElements.minimized then
				local title = guiElements.defaultText:match("^(%S+)")
				guiElements.window.Text = title
			else
				guiElements.window.Text = guiElements.defaultText
			end
		end)
	end

	local function setupClose(guiElements)
		MouseButtonFix(guiElements.closeButton, function()
			guiElements.screenGui:Destroy()
		end)
	end

	local function setupDraggable(guiElements)
		gui.draggablev2(guiElements.window)
	end
	local guiElements = createWindow(UDim2.new(0, 0, 0, 48), UDim2.new(0, 201, 0, 35), UDim2.new(0, 201, 0, 20), "Ping: --")
	setupMinimize(guiElements)
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

			if not guiElements.minimized then
				guiElements.window.Text = "Ping: "..ping.." ms"
				guiElements.window.TextColor3 = color
			end

			lastUpdate = currentTime
		end
	end)
end)

cmd.add({"fps"}, {"fps", "Shows your fps"}, function()
	local function createWindow(position, maxSize, minSize, defaultText)
		local screenGui = InstanceNew("ScreenGui")
		NaProtectUI(screenGui)
		screenGui.ResetOnSpawn = false

		local window = InstanceNew("TextLabel")
		window.Parent = screenGui
		window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		window.BackgroundTransparency = 0.2
		window.Position = position
		window.Size = maxSize
		window.Font = Enum.Font.GothamSemibold
		window.Text = defaultText
		window.TextColor3 = Color3.fromRGB(255, 255, 255)
		window.TextSize = 16
		window.TextXAlignment = Enum.TextXAlignment.Center
		window.TextWrapped = true

		local uiCorner = InstanceNew("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 10)
		uiCorner.Parent = window

		local uiStroke = InstanceNew("UIStroke")
		uiStroke.Color = Color3.fromRGB(100, 100, 255)
		uiStroke.Thickness = 1.5
		uiStroke.Parent = window

		local closeButton = InstanceNew("TextButton")
		closeButton.Parent = window
		closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		closeButton.Position = UDim2.new(1, -25, 0.5, -10)
		closeButton.Size = UDim2.new(0, 20, 0, 20)
		closeButton.Font = Enum.Font.GothamBold
		closeButton.Text = "X"
		closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeButton.TextSize = 14
		closeButton.ZIndex = 10

		local closeUICorner = InstanceNew("UICorner")
		closeUICorner.CornerRadius = UDim.new(0, 10)
		closeUICorner.Parent = closeButton

		local minimizeButton = InstanceNew("TextButton")
		minimizeButton.Parent = window
		minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
		minimizeButton.Position = UDim2.new(1, -50, 0.5, -10)
		minimizeButton.Size = UDim2.new(0, 20, 0, 20)
		minimizeButton.Font = Enum.Font.GothamBold
		minimizeButton.Text = "-"
		minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		minimizeButton.TextSize = 14
		minimizeButton.ZIndex = 10

		local minUICorner = InstanceNew("UICorner")
		minUICorner.CornerRadius = UDim.new(0, 10)
		minUICorner.Parent = minimizeButton

		return {
			screenGui = screenGui,
			window = window,
			closeButton = closeButton,
			minimizeButton = minimizeButton,
			maxSize = maxSize,
			minSize = minSize,
			defaultText = defaultText,
			minimized = false
		}
	end

	local function setupMinimize(guiElements)
		MouseButtonFix(guiElements.minimizeButton, function()
			guiElements.minimized = not guiElements.minimized
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local targetSize = guiElements.minimized and guiElements.minSize or guiElements.maxSize
			local tween = TweenService:Create(guiElements.window, tweenInfo, {Size = targetSize})
			tween:Play()
			if guiElements.minimized then
				local title = guiElements.defaultText:match("^(%S+)")
				guiElements.window.Text = title
			else
				guiElements.window.Text = guiElements.defaultText
			end
		end)
	end

	local function setupClose(guiElements)
		MouseButtonFix(guiElements.closeButton, function()
			guiElements.screenGui:Destroy()
		end)
	end

	local function setupDraggable(guiElements)
		gui.draggablev2(guiElements.window)
	end
	local guiElements = createWindow(UDim2.new(0, 0, 0, 6), UDim2.new(0, 201, 0, 35), UDim2.new(0, 201, 0, 20), "FPS: --")
	setupMinimize(guiElements)
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

			if not guiElements.minimized then
				guiElements.window.Text = "FPS: "..fps
				guiElements.window.TextColor3 = color
			end

			lastUpdate = currentTime
		end
	end)
end)

cmd.add({"stats"}, {"stats", "Shows both FPS and ping"}, function()
	local function createWindow(position, maxSize, minSize, defaultText)
		local screenGui = InstanceNew("ScreenGui")
		NaProtectUI(screenGui)
		screenGui.ResetOnSpawn = false

		local window = InstanceNew("TextLabel")
		window.Parent = screenGui
		window.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
		window.BackgroundTransparency = 0.2
		window.Position = position
		window.Size = maxSize
		window.Font = Enum.Font.GothamSemibold
		window.Text = defaultText
		window.TextColor3 = Color3.fromRGB(255, 255, 255)
		window.TextSize = 14
		window.TextXAlignment = Enum.TextXAlignment.Center
		window.TextWrapped = true

		local uiCorner = InstanceNew("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 10)
		uiCorner.Parent = window

		local uiStroke = InstanceNew("UIStroke")
		uiStroke.Color = Color3.fromRGB(100, 100, 255)
		uiStroke.Thickness = 1.5
		uiStroke.Parent = window

		local closeButton = InstanceNew("TextButton")
		closeButton.Parent = window
		closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		closeButton.Position = UDim2.new(1, -25, 0.5, -10)
		closeButton.Size = UDim2.new(0, 20, 0, 20)
		closeButton.Font = Enum.Font.GothamBold
		closeButton.Text = "X"
		closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeButton.TextSize = 14
		closeButton.ZIndex = 10

		local closeUICorner = InstanceNew("UICorner")
		closeUICorner.CornerRadius = UDim.new(0, 10)
		closeUICorner.Parent = closeButton

		local minimizeButton = InstanceNew("TextButton")
		minimizeButton.Parent = window
		minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 255)
		minimizeButton.Position = UDim2.new(1, -50, 0.5, -10)
		minimizeButton.Size = UDim2.new(0, 20, 0, 20)
		minimizeButton.Font = Enum.Font.GothamBold
		minimizeButton.Text = "-"
		minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		minimizeButton.TextSize = 14
		minimizeButton.ZIndex = 10

		local minUICorner = InstanceNew("UICorner")
		minUICorner.CornerRadius = UDim.new(0, 10)
		minUICorner.Parent = minimizeButton

		return {
			screenGui = screenGui,
			window = window,
			closeButton = closeButton,
			minimizeButton = minimizeButton,
			maxSize = maxSize,
			minSize = minSize,
			defaultText = defaultText,
			minimized = false
		}
	end

	local function setupMinimize(guiElements)
		MouseButtonFix(guiElements.minimizeButton, function()
			guiElements.minimized = not guiElements.minimized
			local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local targetSize = guiElements.minimized and guiElements.minSize or guiElements.maxSize
			local tween = TweenService:Create(guiElements.window, tweenInfo, {Size = targetSize})
			tween:Play()
			if guiElements.minimized then
				local title = guiElements.defaultText:match("^(%S+)")
				guiElements.window.Text = title
			else
				guiElements.window.Text = guiElements.defaultText
			end
		end)
	end

	local function setupClose(guiElements)
		MouseButtonFix(guiElements.closeButton, function()
			guiElements.screenGui:Destroy()
		end)
	end

	local function setupDraggable(guiElements)
		gui.draggablev2(guiElements.window)
	end
	local guiElements = createWindow(UDim2.new(0, 0, 0, 48), UDim2.new(0, 250, 0, 50), UDim2.new(0, 250, 0, 20), "Ping: -- ms | FPS: --")
	setupMinimize(guiElements)
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

			if not guiElements.minimized then
				guiElements.window.Text = "Ping: "..ping.." ms | FPS: "..fps
				guiElements.window.TextColor3 = pingColor
			end

			lastUpdate = currentTime
		end
	end)
end)


cmd.add({"commands","cmds"},{"commands","Open the command list"},function()
	gui.commands()
end)

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

	gui.draggablev2(window, header)

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
        local cam  = SafeGetService("Workspace").CurrentCamera
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
	lib.disconnect("staffNotifier")

	if game.CreatorType == Enum.CreatorType.Group then
		local staffList = {}
		lib.connect("staffNotifier", Players.PlayerAdded:Connect(function(player)
			local info = groupRole(player)
			if info.IsStaff then
				DoNotif(formatUsername(player).." is a "..info.Role)
			end
		end))
		for _, player in pairs(Players:GetPlayers()) do
			local info = groupRole(player)
			if info.IsStaff then
				Insert(staffList, formatUsername(player).." is a "..info.Role)
			end
		end
		DoNotif(#staffList > 0 and Concat(staffList, ",\n") or "Tracking enabled")
	else
		DoNotif("Game is not owned by a Group")
	end
end)

cmd.add({"stoptrackstaff", "untrackstaff"}, {"stoptrackstaff (untrackstaff)", "Stop tracking staff members"}, function()
	lib.disconnect("staffNotifier")
	DoNotif("Tracking disabled")
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
		PlrGui.ScreenOrientation=StarterGui.ScreenOrientation
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

	DoNotif("Walkfling enabled", 2)
	hiddenfling = true

	if not NA_storage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
		local detection = InstanceNew("Decal")
		detection.Name = "juisdfj0i32i0eidsuf0iok"
		detection.Parent = NA_storage
	end

	lib.disconnect("walkflinger")
	lib.connect("walkflinger", RunService.Heartbeat:Connect(function()
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
		lib.disconnect("walkfling_charfix")
		lib.connect("walkfling_charfix", lp.CharacterAdded:Connect(function()
			if hiddenfling then
				DoNotif("Re-enabling Walkfling")
			end
		end))
	end
end)
cmd.add({"unwalkfling", "unwfling", "unwf"}, {"unwalkfling (unwfling,unwf)", "stop the walkfling command"}, function()
	if not hiddenfling then return end

	DoNotif("Walkfling disabled", 2)
	hiddenfling = false

	lib.disconnect("walkflinger")
	lib.disconnect("walkfling_charfix")
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

			queueteleport(tpScript)
		end

		Spawn(function()
			pcall(function()
				DoNotif("Rejoining back to the same position...")
			end)

			local success = pcall(function()
				if #Players:GetPlayers() <= 1 then
					LocalPlayer:Kick("\nRejoining...")
					Wait(0.5)
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
		DoNotif("Teleport failed: "..err)
	end

	tp.TeleportInitFailed:Connect(tpError)

	if #plrs:GetPlayers() <= 1 then
		lp:Kick("Rejoining...")
		Wait()
		tp:TeleportCancel()
		local success, err = pcall(function()
			tp:Teleport(PlaceId)
		end)
		if not success then
			tpError(err)
		end
	else
		tp:TeleportCancel()
		local success, err = pcall(function()
			tp:TeleportToPlaceInstance(PlaceId, JobId, lp)
		end)
		if not success then
			tpError(err)
		end
	end

	Wait()
	DoNotif("Rejoining...")
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
	if not rootPart then return end

	local respawnCFrame = rootPart.CFrame

	local humanoid = oldChar:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
		humanoid.Health = 0
	end

	local newChar = player.CharacterAdded:Wait()
	newChar:WaitForChild("HumanoidRootPart",3)

	Wait(0.2)

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
	if vFlyEnabled then
		FLYING = false
		getHum().PlatformStand = false
		if goofyFLY then goofyFLY:Destroy() end
		vFlyEnabled = false
	else
		FLYING = true
		sFLY(true)
		vFlyEnabled = true
	end
end

function connectVFlyKey()
	if vKeybindConn then
		vKeybindConn:Disconnect()
	end
	vKeybindConn = cmdm.KeyDown:Connect(function(KEY)
		if KEY:lower() == vToggleKey then
			toggleVFly()
		end
	end)
end

cmd.add({"vfly", "vehiclefly"}, {"vehiclefly (vfly)", "be able to fly vehicles"}, function(...)
	local arg = (...) or nil
	vFlySpeed = arg or 1
	connectVFlyKey()
	vFlyEnabled = true

	if vRAHH then
		vRAHH:Destroy()
		vRAHH = nil
	end

	cmd.run({"uncfly", ''})
	cmd.run({"unfly", ''})

	if IsOnMobile then
		Wait()
		DoNotif(adminName.." detected mobile. vFly button added for easier use.", 2)

		vRAHH = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local speedBox = InstanceNew("TextBox")
		local toggleBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local corner2 = InstanceNew("UICorner")
		local corner3 = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(vRAHH)
		vRAHH.ResetOnSpawn = false

		btn.Parent = vRAHH
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

		speedBox.Parent = vRAHH
		speedBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(vFlySpeed)
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
				if not vOn then
					local newSpeed = tonumber(speedBox.Text) or vFlySpeed
					vFlySpeed = newSpeed
					speedBox.Text = tostring(vFlySpeed)
					vOn = true
					btn.Text = "UnvFly"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					sFLY(true)
					getHum().PlatformStand = false
				else
					vOn = false
					btn.Text = "vFly"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					FLYING = false
					getHum().PlatformStand = false
					if goofyFLY then goofyFLY:Destroy() end
				end
			end)
		end)()

		gui.draggablev2(btn)
		gui.draggablev2(speedBox)
	else
		FLYING = false
		getHum().PlatformStand = false
		Wait()
		DoNotif("Vehicle fly enabled. Press '"..vToggleKey:upper().."' to toggle vehicle flying.")
		sFLY(true)
		speedofthevfly = vFlySpeed
		speedofthefly = vFlySpeed
	end
end, true)

cmd.add({"unvfly", "unvehiclefly"}, {"unvehiclefly (unvfly)", "disable vehicle fly"}, function(bool)
	Wait()
	if not bool then DoNotif("Not vFlying anymore", 2) end
	FLYING = false
	getHum().PlatformStand = false
	if goofyFLY then goofyFLY:Destroy() end
	vOn = false
	if vRAHH then
		vRAHH:Destroy()
		vRAHH = nil
	end
	if vKeybindConn then
		vKeybindConn:Disconnect()
		vKeybindConn = nil
	end
end)

if IsOnPC then
	cmd.add({"vflybind", "vflykeybind","bindvfly"}, {"vflybind (vflykeybind, bindvfly)", "set a custom keybind for the 'vFly' command"}, function(...)
		local newKey = (...):lower()
		if newKey == "" or newKey==nil then
			DoNotif("Please provide a keybind.")
			return
		end

		vToggleKey = newKey
		if vKeybindConn then
			vKeybindConn:Disconnect()
		end
		connectVFlyKey()

		DoNotif("vFly keybind set to '"..vToggleKey:upper().."'")
	end,true)
end

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
		DoNotif("Could not find backpack or character.")
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

cmd.add({"tweento","tweengoto", "tgoto"}, {"tweengoto <player> (tweento, tgoto)", "Teleportation method that bypasses some anticheats"}, function(...)
	local Username = (...)
	local speaker = Players.LocalPlayer

	local target = getPlr(Username)
	for _, plr in next, target do
		if not plr or not plr.Character then return end

		TweenService:Create(getRoot(speaker.Character), TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = getRoot(plr.Character).CFrame}):Play()
	end
end, true)


cmd.add({"reach", "swordreach"}, {"reach [number] (swordreach)", "Extends sword reach in one direction"}, function(reachsize)
	reachsize = tonumber(reachsize) or 25

	local char = getChar()
	local bp = getBp()
	local Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")

	if not Tool then return end

	local toolHnld = Tool:FindFirstChild("Handle") or Tool:FindFirstChildWhichIsA("BasePart")
	if not toolHnld then return end

	if Tool:FindFirstChild("OGSize3") then
		toolHnld.Size = Tool.OGSize3.Value
		Tool.OGSize3:Destroy()
		if toolHnld:FindFirstChild("FunTIMES") then
			toolHnld.FunTIMES:Destroy()
		end
	end

	local val = InstanceNew("Vector3Value", Tool)
	val.Name = "OGSize3"
	val.Value = toolHnld.Size

	local sb = InstanceNew("SelectionBox")
	sb.Adornee = toolHnld
	sb.Name = "FunTIMES"
	sb.LineThickness = 0.01
	sb.Color3 = Color3.fromRGB(255, 0, 0)
	sb.Transparency = 0.7
	sb.Parent = toolHnld

	toolHnld.Massless = true
	toolHnld.Size = Vector3.new(toolHnld.Size.X, toolHnld.Size.Y, reachsize)
end,true)

cmd.add({"boxreach"}, {"boxreach [number]", "Creates a box-shaped hitbox around your tool"}, function(reachsize)
	reachsize = tonumber(reachsize) or 25

	local char = getChar()
	local bp = getBp()
	local Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")

	if not Tool then return end

	local toolHnld = Tool:FindFirstChild("Handle") or Tool:FindFirstChildWhichIsA("BasePart")
	if not toolHnld then return end

	if Tool:FindFirstChild("OGSize3") then
		toolHnld.Size = Tool.OGSize3.Value
		Tool.OGSize3:Destroy()
		if toolHnld:FindFirstChild("FunTIMES") then
			toolHnld.FunTIMES:Destroy()
		end
	end

	local val = InstanceNew("Vector3Value", Tool)
	val.Name = "OGSize3"
	val.Value = toolHnld.Size

	local sb = InstanceNew("SelectionBox")
	sb.Adornee = toolHnld
	sb.Name = "FunTIMES"
	sb.LineThickness = 0.01
	sb.Color3 = Color3.fromRGB(0, 0, 255)
	sb.Transparency = 0.7
	sb.Parent = toolHnld

	toolHnld.Massless = true
	toolHnld.Size = Vector3.new(reachsize, reachsize, reachsize)
end,true)

cmd.add({"resetreach", "normalreach", "unreach"}, {"resetreach (normalreach, unreach)", "Resets tool to normal size"}, function()
	local char = getChar()
	local bp = getBp()
	local Tool = char and char:FindFirstChildOfClass("Tool") or bp and bp:FindFirstChildOfClass("Tool")

	if not Tool then return end

	local toolHnld = Tool:FindFirstChild("Handle") or Tool:FindFirstChildWhichIsA("BasePart")
	if not toolHnld then return end

	if Tool:FindFirstChild("OGSize3") then
		toolHnld.Size = Tool.OGSize3.Value
		Tool.OGSize3:Destroy()
		if toolHnld:FindFirstChild("FunTIMES") then
			toolHnld.FunTIMES:Destroy()
		end
	end
end)

cmd.add({"aura"}, {"aura [distance]", "Continuously damages nearby players within range using a damage tool"}, function(range)
	range = tonumber(range) or 20

	local Players = SafeGetService("Players")
	local LocalPlayer = Players.LocalPlayer

	if not firetouchinterest then
		return DoNotif('Your exploit does not support firetouchinterest to run this command')
	end

	lib.disconnect("aura_loop")

	local function getToolAndHandle()
		local char = LocalPlayer.Character
		if not char then return end
		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then return end
		local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
		return tool, handle
	end

	lib.connect("aura_loop", RunService.RenderStepped:Connect(function()
		local Tool, Handle = getToolAndHandle()
		if Tool and Handle and Tool.Parent == LocalPlayer.Character then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local targetChar = player.Character
					local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
					if humanoid and humanoid.Health > 0 then
						for _, part in ipairs(targetChar:GetChildren()) do
							if part:IsA("BasePart") and (part.Position - Handle.Position).Magnitude <= range then
								firetouchinterest(Handle, part, 0)
								Wait()
								firetouchinterest(Handle, part, 1)
							end
						end
					end
				end
			end
		end
	end))

	DoNotif("Aura enabled at range "..tostring(range), 1.2)
end, true)

cmd.add({"unaura"}, {"unaura", "Stops the running aura loop"}, function()
	if lib.isConnected("aura_loop") then
		lib.disconnect("aura_loop")
		DoNotif("Aura disabled", 1.2)
	else
		DoNotif("Aura is not active", 1.2)
	end
end, true)

cmd.add({"antivoid"},{"antivoid","Prevents you from falling into the void by launching you upwards"},function()
	lib.disconnect("antivoid")

	lib.connect("antivoid", RunService.Stepped:Connect(function()
		local character = Players.LocalPlayer.Character
		local root = character and getRoot(character)
		if root and root.Position.Y <= OrgDestroyHeight + 25 then
			root.Velocity = Vector3.new(root.Velocity.X, root.Velocity.Y + 250, root.Velocity.Z)
		end
	end))

	DoNotif("AntiVoid Enabled", 3)
end)

cmd.add({"unantivoid"},{"unantivoid","Disables antivoid"},function()
	lib.disconnect("antivoid")
	DoNotif("AntiVoid Disabled", 3)
end)

originalFPDH = nil

cmd.add({"antivoid2"}, {"antivoid2", "sets FallenPartsDestroyHeight to -inf"}, function()
	if not originalFPDH then
		originalFPDH = SafeGetService("Workspace").FallenPartsDestroyHeight
	end

	SafeGetService("Workspace").FallenPartsDestroyHeight = -9e9
end)

cmd.add({"unantivoid2"}, {"unantivoid2", "reverts FallenPartsDestroyHeight"}, function()
	if originalFPDH ~= nil then
		SafeGetService("Workspace").FallenPartsDestroyHeight = originalFPDH
		DoNotif("FallenPartsDestroyHeight reverted to original value | Antivoid2 Disabled",2)
	else
		DoNotif("Original value was not stored. Cannot revert.",2)
	end
end)

cmd.add({"droptool"}, {"dropatool", "Drop one of your tools"}, function()
	local backpack = getBp()
	local toolToDrop = nil

	if not toolToDrop then
		for _, tool in ipairs(getChar():GetChildren()) do
			if tool:IsA("Tool") then
				toolToDrop = tool
				break
			end
		end
	end

	Wait()

	if backpack and not toolToDrop then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent = getChar()
				toolToDrop = tool
				break
			end
		end
	end

	if toolToDrop then
		toolToDrop.Parent = SafeGetService("Workspace")
	end
end)


cmd.add({"droptools"},{"dropalltools","Drop all of your tools"},function()
	backpack=getBp()
	if backpack then
		for _,tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent=getChar()
			end
		end
	end
	Wait()
	for _,tool in pairs(getChar():GetChildren()) do
		if tool:IsA("Tool") then
			tool.Parent=SafeGetService("Workspace")
		end
	end
end)

cmd.add({"notools"},{"notools","Remove your tools"},function()
	for _,tool in pairs(getChar():GetChildren()) do
		if tool:IsA("Tool") then
			tool:Destroy()
		end
	end
	for _,tool in pairs(getBp():GetChildren()) do
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
	oldgrav=SafeGetService("Workspace").Gravity
	SafeGetService("Workspace").Gravity=0
	local char=getChar()
	local swimDied=function()
		SafeGetService("Workspace").Gravity=oldgrav
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
	local w = SafeGetService("Workspace")
	local l = Lighting
	local t = w.Terrain

	local function optimizeInstance(v)
		if v:IsA("BasePart") then
			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
			if v:IsA("MeshPart") and not decalsEnabled then v.TextureID = "" end
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
			pcall(function() v[v.ClassName.."Template"] = "" end)
		end
	end

	pcall(function() sethiddenproperty(l,"Technology",Enum.Technology.Compatibility) end)
	pcall(function() sethiddenproperty(t,"Decoration",false) end)
	t.WaterWaveSize = 0
	t.WaterWaveSpeed = 0
	t.WaterReflectance = 0
	t.WaterTransparency = 0
	l.GlobalShadows = false
	l.FogEnd = math.huge
	l.Brightness = 0
	pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)

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
	local gui = InstanceNew("ScreenGui")
	NaProtectUI(gui)
	gui.Name = "AntiLagGUI"
	gui.ResetOnSpawn = false

	local frame = InstanceNew("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Size = UDim2.new(0.3, 0, 0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0.35, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = gui

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
		gui:Destroy()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/low%20detail"))()
	end)

	MouseButtonFix(closeBtn,function()
		gui:Destroy()
	end)

	local minimized = false
	MouseButtonFix(minimizeBtn,function()
		minimized = not minimized
		content.Visible = not minimized
		minimizeBtn.Text = minimized and "+" or "-"
	end)
	gui.draggablev2(frame)
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
	for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency==1 and v.CanCollide then
			v:Destroy()
		end
	end
end)

local shownParts = {}

cmd.add({"invisibleparts","invisparts"},{"invisibleparts (invisparts)","Shows invisible parts"},function()
	for _, v in ipairs(SafeGetService("Workspace"):GetDescendants()) do
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
			local head = char and char:FindFirstChild("Head")
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
	for _,child in pairs(Player.Character:GetDescendants()) do
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
	for _,child in pairs(Player.Character:GetDescendants()) do
		if child:IsA("BasePart") then
			child.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.3,0.5)
		end
	end
end)

cmd.add({"weaken"},{"weaken","Makes your character less dense"},function(...)
	local args={...}
	for _,child in pairs(Player.Character:GetDescendants()) do
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
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
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
		DoNotif("No available seats found in the game", 3)
		return
	end

	table.sort(seats, function(a, b)
		return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
	end)

	local seat = seats[1]
	if seat then
		seat:Sit(humanoid)
		DoNotif("Sat in the nearest seat", 2)
	else
		DoNotif("Failed to sit in a seat", 3)
	end
end)

cmd.add({"vehicleseat", "vseat"}, {"vehicleseat (vseat)", "Sits you in a vehicle seat, useful for trying to find cars in games"}, function()
	local character = getChar()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
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
		DoNotif("No available VehicleSeats found in the game", 3)
		return
	end

	table.sort(vehicleSeats, function(a, b)
		return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
	end)

	local vseat = vehicleSeats[1]
	if vseat then
		vseat:Sit(humanoid)
		DoNotif("Sat in the nearest VehicleSeat", 2)
	else
		DoNotif("Failed to sit in a VehicleSeat", 3)
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
	local uptime = os.clock() - sessionStart
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

		gui.draggablev2(btn)
	else
		lib.disconnect("somersault_key")
		lib.connect("somersault_key", cmdm.KeyDown:Connect(function(KEY)
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

	lib.disconnect("somersault_key")
end, false)
cmd.add({"cartornado", "ctornado"}, {"cartornado (ctornado)", "Tornados a car just sit in the car"}, function()
	local Player = Players.LocalPlayer
	local RunService = RunService
	local Workspace = SafeGetService("Workspace")

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

		local hum = Character:FindFirstChildOfClass("Humanoid")
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
				flyg.CFrame = SafeGetService("Workspace").CurrentCamera.CFrame * CFrame.Angles(-math.rad(f * 50 * speed / maxSpeed), 0, 0)
				flyv.Velocity = SafeGetService("Workspace").CurrentCamera.CFrame.LookVector * speed
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
	lib.disconnect("spam")
end)

cmd.add({"UNCTest","UNC"},{"UNCTest (UNC)","Test how many functions your executor supports"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/UNC%20test"))()
end)

cmd.add({"sUNCtest","sUNC"},{"sUNCtest (sUNC)","uses sUNC test that test the functions if they're working"},function()
	getgenv().sUNCDebug = {
		["printcheckpoints"] = false,
		["delaybetweentests"] = 0
	}

	loadstring(game:HttpGet("https://script.sunc.su/"))()
end)

cmd.add({"cherryUNC","CUNC"},{"cherryUNC (CUNC)","executes cherry's advanced UNC checker that actually checks your executor's UNC (if it crashes that's roblox issue)"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Executor-Tests/refs/heads/main/Environment/Test.lua", true))()
end)

cmd.add({"vulnerabilitytest","vulntest"},{"vulnerabilitytest (vulntest)","Test if your executor is Vulnerable"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/VulnTest.lua"))()
end)

cmd.add({"respawn", "re"}, {"respawn (re)", "Respawn your character"}, function()
	respawn()
end)

cmd.add({"antisit"},{"antisit","Prevents the player from sitting"},function()
	local function noSit(character)
		local humanoid = character:WaitForChild("Humanoid", 5)
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			humanoid.Sit = true
		end
	end

	if LocalPlayer.Character then
		noSit(LocalPlayer.Character)
	end

	lib.disconnect("antisit_conn")
	lib.connect("antisit_conn", LocalPlayer.CharacterAdded:Connect(noSit))

	DoNotif("Anti sit enabled", 3)
end)

cmd.add({"unantisit"},{"unantisit","Allows the player to sit again"},function()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		humanoid.Sit = false
	end

	lib.disconnect("antisit_conn")
	DoNotif("Anti sit disabled", 3)
end)

cmd.add({"antikick", "nokick", "bypasskick", "bk"}, {"antikick (nokick, bypasskick, bk)", "Bypass Kick on Most Games"}, function()
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

	if not getRawMetatable or not setReadOnly or not newcclosure then
		DoNotif("Required metatable functions are not available", 3)
		return
	end

	local meta = getRawMetatable(game)
	if not meta then
		DoNotif("Failed to get the metatable of the game object", 3)
		return
	end

	local player = SafeGetService("Players").LocalPlayer

	local function applyAntiKick(mode)
		local oldNamecall = meta.__namecall
		local oldIndex = meta.__index
		local oldNewIndex = meta.__newindex

		setReadOnly(meta, false)

		meta.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if method and self == player then
				local m = method:lower()
				if m == "kick" then
					if mode == "fake" then
						DoNotif("Kick intercepted (Fake Success)",2)
						return true
					else
						DoNotif("Kick attempt blocked (Error)",2)
						return
					end
				elseif m == "destroy" then
					DoNotif("Destroy attempt blocked",2)
					return
				end
			end
			return oldNamecall(self, ...)
		end)

		meta.__index = newcclosure(function(self, key)
			if self == player then
				if key == "Kick" then
					DoNotif("Access to Kick blocked",2)
					return function() end
				elseif key == "Destroy" then
					DoNotif("Access to Destroy blocked",2)
					return function() end
				end
			end
			return oldIndex(self, key)
		end)

		meta.__newindex = newcclosure(function(self, key, value)
			if self == player and (key == "Kick" or key == "Destroy") then
				DoNotif("Attempt to overwrite "..key.." blocked",2)
				return
			end
			return oldNewIndex(self, key, value)
		end)

		setReadOnly(meta, true)
		DoNotif("Anti-Kick Enabled: Mode - "..(mode == "fake" and "Fake Success" or "Error"),2)
	end

	Notify({
		Title = "Anti-Kick Mode Selection",
		Description = "Choose how kick attempts should be handled.",
		Buttons = {
			{Text = "Fake Success", Callback = function()
				applyAntiKick("fake")
			end},
			{Text = "Error", Callback = function()
				applyAntiKick("error")
			end}
		}
	})
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

	acftpCONN = RunService.RenderStepped:Connect(function()
		for part in pairs(acftpCFrames) do
			if part and part:IsDescendantOf(character) then
				acftpCFrames[part] = part.CFrame
			end
		end
	end)

	DoNotif("Anti CFrame Teleport enabled", 1.5)
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
	DoNotif("Anti CFrame Teleport disabled", 1.5)
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

		gui.draggablev2(acftpBtn)
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
	getChar():FindFirstChildOfClass("Humanoid"):ChangeState(0)
	getRoot(getChar()).Velocity=getRoot(getChar()).CFrame.LookVector*25
end)

cmd.add({"antitrip"}, {"antitrip", "no tripping today bruh"}, function()
	local function doTRIPPER(char)
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = getRoot(char)
		if not (hum and root) then return end

		lib.disconnect("trip_fall")
		lib.connect("trip_fall", hum.FallingDown:Connect(function()
			root.Velocity = Vector3.zero
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end))
	end

	if LocalPlayer.Character then
		doTRIPPER(LocalPlayer.Character)
	end

	lib.disconnect("trip_char")
	lib.connect("trip_char", LocalPlayer.CharacterAdded:Connect(doTRIPPER))

	DoNotif("Antitrip Enabled", 2)
end)

cmd.add({"unantitrip"}, {"unantitrip", "tripping allowed now"}, function()
	lib.disconnect("trip_fall")
	lib.disconnect("trip_char")
	DoNotif("Antitrip Disabled", 2)
end)

cmd.add({"checkrfe"},{"checkrfe","Checks if the game has respect filtering enabled off"},function()
	DoNotif(SoundService.RespectFilteringEnabled and "Respect Filtering Enabled is on" or "Respect Filtering Enabled is off")
end)

cmd.add({"sit"},{"sit","Sit your player"},function()
	local hum=character:FindFirstChildWhichIsA("Humanoid")
	if hum then
		hum.Sit=true
	end
end)

cmd.add({"oldroblox"},{"oldroblox","Old skybox and studs"},function()
	for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:IsA("BasePart") then
			local dec=InstanceNew("Texture",v)
			dec.Texture="rbxassetid://48715260"
			dec.Face="Top"
			dec.StudsPerTileU="1"
			dec.StudsPerTileV="1"
			dec.Transparency=v.Transparency
			v.Material="Plastic"
			local dec2=InstanceNew("Texture",v)
			dec2.Texture="rbxassetid://20299774"
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
	sky.SkyboxBk="rbxassetid://161781263"
	sky.SkyboxDn="rbxassetid://161781258"
	sky.SkyboxFt="rbxassetid://161781261"
	sky.SkyboxLf="rbxassetid://161781267"
	sky.SkyboxRt="rbxassetid://161781268"
	sky.SkyboxUp="rbxassetid://161781260"
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
	local Camera = SafeGetService("Workspace").CurrentCamera

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

	RunService.RenderStepped:Connect(function()
		CheckMode()
		if Toggled then
			local targetPlayer = GetClosestPlayer()
			if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
				local humanoid = targetPlayer.Character.Humanoid
				if humanoid.Health > 0 then
					Click()
				end
			end
		end
	end)

	On.Text = "TriggerBot On: "..tostring(Toggled).." (Key: "..ToggleKey.Name..")"

	DoNotif("Advanced Trigger Bot Loaded")
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
	if lib.isConnected("spawnCONNECTION") and lib.isConnected("spawnCHARCON") then
		return DoNotif("spawn point is already running", 3)
	end

	DoNotif("Spawn has been set")
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

	lib.connect("spawnCONNECTION", RunService.Stepped:Connect(handleRespawn))

	lib.connect("spawnCHARCON", LocalPlayer.CharacterAdded:Connect(function()
		Wait(1)
		needsRespawning = false
		hasPosition = false
	end))
end)

cmd.add({"disablespawn", "unsetspawn", "ds"}, {"disablespawn (unsetspawn, ds)", "Disables the previously set spawn point"}, function()
	DoNotif("Spawn point has been disabled")
	lib.disconnect("spawnCONNECTION")
	lib.disconnect("spawnCHARCON")
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
	local Camera = SafeGetService("Workspace").CurrentCamera

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
	local humanoid = character:WaitForChild("Humanoid")

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {character}

	lib.connect("hamster_render", RunService.RenderStepped:Connect(function(delta)
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
		local result = SafeGetService("Workspace"):Raycast(
			ball.Position,
			Vector3.new(0, -((ball.Size.Y / 2) + JUMP_GAP), 0),
			params
		)
		if result then
			ball.Velocity = ball.Velocity + Vector3.new(0, JUMP_POWER, 0)
		end
	end)

	humanoid.Died:Connect(function()
		lib.disconnect("hamster_render")
	end)

	Camera.CameraSubject = ball
end, true)

cmd.add({"antiafk","noafk"},{"antiafk (noafk)","Prevents you from being kicked for being AFK"},function()
	if not lib.isConnected("antiAFK") then
		local player = Players.LocalPlayer
		local virtualUser = SafeGetService("VirtualUser")

		lib.connect("antiAFK", player.Idled:Connect(function()
			virtualUser:Button2Down(Vector2.new(0, 0), SafeGetService("Workspace").CurrentCamera.CFrame)
			Wait(1)
			virtualUser:Button2Up(Vector2.new(0, 0), SafeGetService("Workspace").CurrentCamera.CFrame)
		end))

		DoNotif("Anti AFK has been enabled")
	else
		DoNotif("Anti AFK is already enabled")
	end
end)

cmd.add({"unantiafk","unnoafk"},{"unantiafk (unnoafk)","Allows you to be kicked for being AFK"},function()
	if lib.isConnected("antiAFK") then
		lib.disconnect("antiAFK")
		DoNotif("Anti AFK has been disabled")
	else
		DoNotif("Anti AFK is already disabled")
	end
end)

local tpUI = nil

cmd.add({"clicktp", "tptool"}, {"clicktp (tptool)", "Teleport where your mouse is"}, function()
	local TweenService = SafeGetService("TweenService")
	local player = Players.LocalPlayer
	local mouse = player:GetMouse()

	if tpUI then
		tpUI:Destroy()
		tpUI = nil
		lib.disconnect("tp_down")
		lib.disconnect("tp_up")
	end

	tpUI = InstanceNew("ScreenGui")
	NaProtectUI(tpUI)

	local clickTpButton = InstanceNew("TextButton")
	clickTpButton.Size = UDim2.new(0, 130, 0, 40)
	clickTpButton.AnchorPoint = Vector2.new(0.5, 0)
	clickTpButton.Position = UDim2.new(0.45, 0, 0.1, 0)
	clickTpButton.Text = "Enable Click TP"
	clickTpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	clickTpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	clickTpButton.BorderSizePixel = 0
	clickTpButton.Parent = tpUI

	local clickTpCorner = InstanceNew("UICorner")
	clickTpCorner.CornerRadius = UDim.new(0, 10)
	clickTpCorner.Parent = clickTpButton

	local tweenTpButton = InstanceNew("TextButton")
	tweenTpButton.Size = UDim2.new(0, 130, 0, 40)
	tweenTpButton.AnchorPoint = Vector2.new(0.5, 0)
	tweenTpButton.Position = UDim2.new(0.55, 0, 0.1, 0)
	tweenTpButton.Text = "Enable Tween TP"
	tweenTpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	tweenTpButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	tweenTpButton.BorderSizePixel = 0
	tweenTpButton.Parent = tpUI

	local tweenTpCorner = InstanceNew("UICorner")
	tweenTpCorner.CornerRadius = UDim.new(0, 10)
	tweenTpCorner.Parent = tweenTpButton

	local clickTpEnabled = false
	local tweenTpEnabled = false

	MouseButtonFix(clickTpButton, function()
		clickTpEnabled = not clickTpEnabled
		tweenTpEnabled = false
		tweenTpButton.Text = "Enable Tween TP"
		clickTpButton.Text = clickTpEnabled and "Disable Click TP" or "Enable Click TP"
	end)

	MouseButtonFix(tweenTpButton, function()
		tweenTpEnabled = not tweenTpEnabled
		clickTpEnabled = false
		clickTpButton.Text = "Enable Click TP"
		tweenTpButton.Text = tweenTpEnabled and "Disable Tween TP" or "Enable Tween TP"
	end)

	local initialMousePosition = nil
	local dragThreshold = 10

	lib.connect("tp_down", mouse.Button1Down:Connect(function()
		initialMousePosition = Vector2.new(mouse.X, mouse.Y)
	end))

	lib.connect("tp_up", mouse.Button1Up:Connect(function()
		if initialMousePosition then
			local currentMousePosition = Vector2.new(mouse.X, mouse.Y)
			local distance = (currentMousePosition - initialMousePosition).Magnitude
			if distance <= dragThreshold then
				if clickTpEnabled then
					local pos = mouse.Hit + Vector3.new(0, 2.5, 0)
					local targetCFrame = CFrame.new(pos.X, pos.Y, pos.Z)
					getRoot(player.Character).CFrame = targetCFrame
				elseif tweenTpEnabled then
					local pos = mouse.Hit + Vector3.new(0, 2.5, 0)
					local humanoidRootPart = getRoot(player.Character)
					local tweenInfo = TweenInfo.new(
						1,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.Out,
						0,
						false,
						0
					)
					local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
						CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
					})
					tween:Play()
				end
			end
		end
		initialMousePosition = nil
	end))

	gui.draggablev2(clickTpButton)
	gui.draggablev2(tweenTpButton)
end)

cmd.add({"unclicktp", "untptool"}, {"unclicktp (untptool)", "Remove teleport buttons"}, function()
	if tpUI then
		tpUI:Destroy()
		tpUI = nil
	end
	lib.disconnect("tp_down")
	lib.disconnect("tp_up")
end)

cmd.add({"dex"},{"dex","Using this you can see the parts / guis / scripts etc with this. A really good and helpful script."},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DexByMoonMobile"))()
end)

cmd.add({"Decompiler"},{"Decompiler","Allows you to decompile LocalScript/ModuleScript's"},function()
	Spawn(function()
		assert(getscriptbytecode, "Exploit not supported.")

		local API: string = "http://api.plusgiant5.com/"

		local last_call = 0
		function call(konstantType: string, scriptPath: Script | ModuleScript | LocalScript): string
			local success: boolean, bytecode: string = pcall(getscriptbytecode, scriptPath)

			if (not success) then
				return
			end

			local time_elapsed = os.clock() - last_call
			if time_elapsed <= .5 then
				Wait(.5 - time_elapsed)
			end
			local httpResult = NAREQUEST({
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
	local s,idd=pcall(function()
		return Players:GetUserIdFromNameAsync(tostring(thingy))
	end)

	if not s then return warn("err: "..tostring(idd)) end

	if not setclipboard then return DoNotif("no setclipboard") end
	setclipboard(tostring(idd))

	DoNotif("Copied "..tostring(thingy).."'s UserId: "..tostring(idd))
end,true)

cmd.add({"getuserfromid","guid"},{"getuserfromid (guid)","Copy a user's Username by ID"}, function(thingy)
	local s,naem=pcall(function()
		return Players:GetNameFromUserIdAsync(thingy)
	end)

	if not s then return warn("err: "..tostring(naem)) end

	if not setclipboard then return DoNotif("no setclipboard") end
	setclipboard(tostring(naem))

	DoNotif("Copied "..tostring(naem).."'s Username with ID of "..tostring(thingy))
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

local aFLING = {on = false, c = {}}
function addFLINGER(c) Insert(aFLING.c, c) end

cmd.add({"antifling"}, {"antifling", "makes other players non-collidable with you"}, function()
	if aFLING.on then for _, cn in ipairs(aFLING.c) do cn:Disconnect() end aFLING.c = {} end
	aFLING.on = true
	addFLINGER(RunService.Stepped:Connect(function()
		for _, pl in ipairs(Players:GetPlayers()) do
			if pl ~= LocalPlayer and pl.Character then
				for _, p in ipairs(pl.Character:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end
	end))
	local function setNo(p)
		if p:IsA("BasePart") then
			p.CanCollide = false
			addFLINGER(p:GetPropertyChangedSignal("CanCollide"):Connect(function()
				if p.CanCollide then p.CanCollide = false end
			end))
		end
	end
	local function hook(c)
		for _, p in ipairs(c:GetDescendants()) do setNo(p) end
		addFLINGER(c.DescendantAdded:Connect(setNo))
	end
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer then
			if pl.Character then hook(pl.Character) end
			addFLINGER(pl.CharacterAdded:Connect(hook))
		end
	end
	addFLINGER(Players.PlayerAdded:Connect(function(pl)
		if pl ~= LocalPlayer then addFLINGER(pl.CharacterAdded:Connect(hook)) end
	end))
	DoNotif("Antifling Enabled")
end)

cmd.add({"unantifling"}, {"unantifling", "restores collision for other players"}, function()
	if aFLING.on then
		for _, cn in ipairs(aFLING.c) do cn:Disconnect() end
		aFLING.c = {}
		aFLING.on = false
	end
	DoNotif("Antifling Disabled")
end)

cmd.add({"gravitygun"},{"gravitygun","Probably the best gravity gun script thats fe"},function()
	Wait();
	DoNotif("Wait a few seconds for it to load")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/gravity%20gun"))()
end)

cmd.add({"lockws","lockworkspace"},{"lockws (lockworkspace)","Locks the whole workspace"},function()
	for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		v.Locked=true
	end
end)

cmd.add({"unlockws","unlockworkspace"},{"unlockws (unlockworkspace)","Unlocks the whole workspace"},function()
	for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		v.Locked=false
	end
end)

vspeedBTN = nil

cmd.add({"vehiclespeed", "vspeed"}, {"vehiclespeed <amount> (vspeed)", "Change the vehicle speed"}, function(amount)
	lib.disconnect("vehicleloopspeed")

	if vspeedBTN then
		vspeedBTN:Destroy()
		vspeedBTN = nil
	end

	local intens = tonumber(amount) or 1

	lib.connect("vehicleloopspeed", RunService.Stepped:Connect(function()
		local subject = SafeGetService("Workspace").CurrentCamera.CameraSubject
		if subject and subject:IsA("Humanoid") and subject.SeatPart then
			subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
		elseif subject and subject:IsA("BasePart") then
			subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
		end
	end))

	DoNotif("Vehicle speed set to "..intens)

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

			lib.disconnect("vehicleloopspeed")
			lib.connect("vehicleloopspeed", RunService.Stepped:Connect(function()
				local subject = SafeGetService("Workspace").CurrentCamera.CameraSubject
				if subject and subject:IsA("Humanoid") and subject.SeatPart then
					subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
				elseif subject and subject:IsA("BasePart") then
					subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
				end
			end))

			btn.Text = "vSpeed ON"
			btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		else
			lib.disconnect("vehicleloopspeed")

			local subject = SafeGetService("Workspace").CurrentCamera.CameraSubject
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
		local subject = SafeGetService("Workspace").CurrentCamera.CameraSubject
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

		lib.disconnect("vehicleloopspeed")
		lib.connect("vehicleloopspeed", RunService.Stepped:Connect(function()
			local subject = SafeGetService("Workspace").CurrentCamera.CameraSubject
			if subject and subject:IsA("Humanoid") and subject.SeatPart then
				subject.SeatPart:ApplyImpulse(subject.SeatPart.CFrame.LookVector * Vector3.new(intens, 0, intens))
			elseif subject and subject:IsA("BasePart") then
				subject:ApplyImpulse(subject.CFrame.LookVector * Vector3.new(intens, 0, intens))
			end
		end))

		DoNotif("vSpeed updated to "..intens, 2)
	end)

	gui.draggablev2(btn)
	gui.draggablev2(speedBox)
	gui.draggablev2(vstopBtn)
end, true)

cmd.add({"unvehiclespeed", "unvspeed"}, {"unvehiclespeed (unvspeed)", "Stops the vehiclespeed command"}, function()
	lib.disconnect("vehicleloopspeed")

	if vspeedBTN then
		vspeedBTN:Destroy()
		vspeedBTN = nil
	end

	local subject = SafeGetService("Workspace").CurrentCamera.CameraSubject
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

	DoNotif("Vehicle speed disabled")
end)

local active=false
local players=Players
local camera=SafeGetService("Workspace").CurrentCamera

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

	local success, currentRotation = pcall(function()
		return GameSettings.RotationType
	end)

	if success then
		OriginalRotationType = currentRotation
	end

	lib.connect("shiftlock_loop", RunService.RenderStepped:Connect(function()
		pcall(function()
			GameSettings.RotationType = Enum.RotationType.CameraRelative
		end)
	end))

	ShiftLockEnabled = true
	DoNotif("ShiftLock Enabled", 2)
end

function DisableShiftLock()
	if not ShiftLockEnabled then return end

	lib.disconnect("shiftlock_loop")

	pcall(function()
		GameSettings.RotationType = OriginalRotationType or Enum.RotationType.MovementRelative
	end)

	ShiftLockEnabled = false
	DoNotif("ShiftLock Disabled", 2)
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
				StarterGui:SetCoreGuiEnabled(coreGuiType, true)
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

	if enableName and enableName ~= "" then
		local found = false
		for _, button in ipairs(buttons) do
			if Match(button.Text:lower(), enableName:lower()) then
				button.Callback()
				if not hiddenNotif then
					DoNotif("CoreGui Enabled: "..button.Text.." has been enabled.", 3)
				end
				found = true
				break
			end
		end
		if not found then
			DoNotif("No matching CoreGui element found for: "..enableName, 3)
		end
	else
		Insert(buttons, {
			Text = "Cancel",
			Callback = function() end
		})
		Notify({
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
				StarterGui:SetCoreGuiEnabled(coreGuiType, false)
			end
		})
	end

	Insert(buttons, {
		Text = "Shiftlock",
		Callback = function()
			LocalPlayer.DevEnableMouseLock = false
		end
	})

	if disableName and disableName ~= "" then
		local found = false
		for _, button in ipairs(buttons) do
			if Match(button.Text:lower(), disableName:lower()) then
				button.Callback()
				if not hiddenNotif then
					DoNotif("CoreGui Disabled: "..button.Text.." has been disabled.", 3)
				end
				found = true
				break
			end
		end
		if not found then
			DoNotif("No matching CoreGui element found for: "..disableName, 3)
		end
	else
		Insert(buttons, {
			Text = "Cancel",
			Callback = function() end
		})
		Notify({
			Title = "Disable a Specific Core Gui Element",
			Buttons = buttons
		})
	end
end,true)

cmd.add({"reverb", "reverbcontrol"}, {"reverb (reverbcontrol)", "Manage sound reverb settings"}, function()
	local reverbButtons = {}
	for _, reverbType in ipairs(Enum.ReverbType:GetEnumItems()) do
		Insert(reverbButtons, {
			Text = reverbType.Name,
			Callback = function()
				SoundService.AmbientReverb = reverbType
			end
		})
	end

	Insert(reverbButtons, {
		Text = "Cancel",
		Callback = function() end
	})

	Notify({
		Title = "Sound Reverb Options",
		Buttons = reverbButtons
	})
end)

cmd.add({"cam", "camera", "cameratype"}, {"cam (camera, cameratype)", "Manage camera type settings"}, function()
	local cameraTypeButtons = {}
	for _, cameraType in ipairs(Enum.CameraType:GetEnumItems()) do
		Insert(cameraTypeButtons, {
			Text = cameraType.Name,
			Callback = function()
				SafeGetService("Workspace").CurrentCamera.CameraType = cameraType
			end
		})
	end

	Insert(cameraTypeButtons, {
		Text = "Cancel",
		Callback = function() end
	})

	Notify({
		Title = "Camera Type Options",
		Buttons = cameraTypeButtons
	})
end)

cmd.add({"esp"}, {"esp", "locate where the players are"}, function()
	ESPenabled = true
	chamsEnabled = false
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name ~= Players.LocalPlayer.Name then
			NAESP(player)
		end
	end

	if not getgenv().ESPJoinConnection then
		getgenv().ESPJoinConnection = Players.PlayerAdded:Connect(function(player)
			if ESPenabled and player.Name ~= Players.LocalPlayer.Name then
				NAESP(player)
			end
		end)
	end
end)

cmd.add({"chams"}, {"chams", "ESP but without the text :shock:"}, function()
	ESPenabled = true
	chamsEnabled = true
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name ~= Players.LocalPlayer.Name then
			NAESP(player)
		end
	end

	if not getgenv().ESPJoinConnection then
		getgenv().ESPJoinConnection = Players.PlayerAdded:Connect(function(player)
			if ESPenabled and player.Name ~= Players.LocalPlayer.Name then
				NAESP(player)
			end
		end)
	end
end)

cmd.add({"locate"}, {"locate <username>", "locate where the players are"}, function(...)
	local username = (...)
	local target = getPlr(username)
	for _, plr in next, target do
		if plr then
			NAESP(plr, true)
		end
	end
end, true)

cmd.add({"npcesp", "espnpc"}, {"npcesp (espnpc)", "locate where the npcs are"}, function()
	local target = getPlr("npc")
	for _, plr in next, target do
		if plr then
			NAESP(plr, true)
		end
	end
end)

cmd.add({"unnpcesp", "unespnpc"}, {"unnpcesp (unespnpc)", "stop locating npcs"}, function()
	local target = getPlr("npc")
	for _, plr in next, target do
		if plr then
			discPlrESP(plr)
		end
	end
end)

cmd.add({"unesp", "unchams"}, {"unesp (unchams)", "Disables esp/chams"}, function()
	ESPenabled = false
	chamsEnabled = false
	removeAllESP()

	if getgenv().ESPJoinConnection then
		getgenv().ESPJoinConnection:Disconnect()
		getgenv().ESPJoinConnection = nil
	end
end)

cmd.add({"unlocate"}, {"unlocate <player>"}, function(username)
	local target = getPlr(username)
	for _, plr in next, target do
		if plr then
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
				local humanoid = getPlrChar(targetPlayer):FindFirstChildWhichIsA("Humanoid")
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

				RunService.RenderStepped:Wait()
			end
		end)
	end
end, true)

cmd.add({"creep", "scare"}, {"creep <player> (scare)", "Teleports from a player behind them and under the floor to the top"}, function(...)
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

	if not target.Character or not target.Character:FindFirstChild("Humanoid") or not target.Character:FindFirstChild("Humanoid").RootPart then
		DoNotif("Target's character is invalid.", 3)
		return
	end

	root.CFrame = target.Character.Humanoid.RootPart.CFrame * CFrame.new(0, -10, 4)
	Wait()

	if lib.isConnected("noclip") then
		lib.disconnect("noclip")
	end

	lib.connect("noclip", RunService.Stepped:Connect(function()
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

	lib.disconnect("noclip")
end, true)

cmd.add({"netless","net"},{"netless (net)","Executes netless which makes scripts more stable"},function()
	for i,v in next,getChar():GetDescendants() do
		if v:IsA("BasePart") and v.Name~="HumanoidRootPart" then
			RunService.Heartbeat:Connect(function()
				v.Velocity=Vector3.new(-30,0,0)
			end)
		end
	end

	Wait();

	DoNotif("Netless has been activated,re-run this script if you die")
end)

cmd.add({"reset","die"},{"reset (die)","Makes your health be 0"},function()
	Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
	Player.Character:FindFirstChildOfClass("Humanoid").Health=0
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

    if lib.isConnected(connName) then
        lib.disconnect(connName)
        DoNotif("Disabled", 2)
        return
    end

    local lastHealth = humanoid.Health

    lib.connect(connName, humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < lastHealth then
            local msg = damageMessages[math.random(1, #damageMessages)]
            lib.LocalPlayerChat(msg, "All")
        end
        lastHealth = newHealth
    end))

    DoNotif("Enabled", 2)
end)

cmd.add({"undamagechat", "undmgchat", "unpainchat"}, {"undamagechat (undmgchat, unpainchat)", "Disables damage reaction chat"}, function()
    if lib.isConnected("damagechat") then
        lib.disconnect("damagechat")
        DoNotif("Disabled", 2)
    else
        DoNotif("Already disabled", 2)
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
    if builderAnim then pcall(function() builderAnim:Destroy() end) builderAnim = nil end

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
    x.MouseButton1Click:Connect(function() pcall(builderAnim.Destroy, builderAnim) builderAnim = nil end)

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
    gui.draggable(m)
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
	if LegacyChat then
		ChatService.BubbleChatEnabled = true
	else
		TextChatService.BubbleChatConfiguration.Enabled = true
	end
end)

cmd.add({"unbubblechat","unbchat"},{"unbubblechat (unbchat)","Disabled BubbleChat"},function()
	if LegacyChat then
		ChatService.BubbleChatEnabled = false
	else
		TextChatService.BubbleChatConfiguration.Enabled = false
	end
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

cmd.add({"admin"},{"admin","whitelist someone to allow them to use commands"},function(...)
	function ChatMessage(Message,Whisper)
		lib.LocalPlayerChat(Message,Whisper or "All")
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
		lib.LocalPlayerChat(Message,Whisper or "All")
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

		DoNotif("Copied your jobid ("..JobId..")")
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

	DoNotif("Searching")
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
		DoNotif("serverhopping | Player Count: "..found)
		TeleportService:TeleportToPlaceInstance(PlaceId,SomeSRVS[1])
	end
end)

cmd.add({"smallserverhop","sshop"},{"smallserverhop (sshop)","serverhop to a small server"},function()
	Wait();

	DoNotif("Searching")

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
		DoNotif("serverhopping | Player Count: "..found)
		TeleportService:TeleportToPlaceInstance(PlaceId,SomeSRVS[1])
	end
end)

cmd.add({"pingserverhop","pshop"},{"pingserverhop (pshop)","serverhop to a server with the best ping"},function()
	Wait();

	DoNotif("Searching for server with best ping")

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
		DoNotif(Format("Serverhopping to server with ping: %s ms", tostring(BestPing)))
		TeleportService:TeleportToPlaceInstance(PlaceId, BestJobId)
	else
		DoNotif("No better server found")
	end
end)

if askndnijewfijewongf~=zmxcnsaodakscn then
	uhefwewufjodwcijdscsauasd = "aWYgc2V0Y2xpcGJvYXJkIHRoZW4KCQkJc2V0Y2xpcGJvYXJkKFtbbG9hZHN0cmluZyhnYW1lOkh0dHBHZXQoImh0dHBzOi8vcmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbS9sdHNldmVyeWRheXlvdS9OYW1lbGVzcy1BZG1pbi9tYWluL1NvdXJjZS5sdWEiKSkoKTtdXSkKCQllbmQKCQl0YXNrLnNwYXduKGZ1bmN0aW9uKCkgZ2FtZTpHZXRTZXJ2aWNlKCJQbGF5ZXJzIikuTG9jYWxQbGF5ZXI6S2ljayhbW3ZlcnNpb24gbWlzc21hdGNoIHBsZWFzZSB1c2UgdGhlIG9yaWdpbmFsIE5hbWVsZXNzIEFkbWluIHNvdXJjZV1dKSBlbmQpIHRhc2sud2FpdCgxKSB3aGlsZSB0cnVlIGRvIGVuZA=="
	oioji32eipqpaofvofsiv = randomahhfunctionthatyouwontgetit(uhefwewufjodwcijdscsauasd)
	return loadstring(oioji32eipqpaofvofsiv)()
end

cmd.add({"autorejoin", "autorj"}, {"autorejoin (autorj)", "Rejoins the server if you get kicked / disconnected"}, function()
	lib.disconnect("autorejoin")

	local function handleRejoin()
		if #Players:GetPlayers() <= 1 then
			Players.LocalPlayer:Kick("Rejoining...")
			Wait()
			TeleportService:Teleport(PlaceId, Players.LocalPlayer)
		else
			TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Players.LocalPlayer)
		end
	end

	lib.connect("autorejoin", GuiService.ErrorMessageChanged:Connect(function()
		Spawn(handleRejoin)
	end))

	DoNotif("Auto Rejoin is now enabled!")
end)

cmd.add({"unautorejoin", "unautorj"}, {"unautorejoin (unautorj)", "Disables auto rejoin command"}, function()
	if lib.isConnected("autorejoin") then
		lib.disconnect("autorejoin")
		DoNotif("Auto Rejoin is now disabled!")
	else
		DoNotif("Auto Rejoin is already disabled!")
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
	local UICorner = InstanceNew("UICorner")
	local UIStroke = InstanceNew("UIStroke")

	NaProtectUI(FunctionSpy)

	Main.Parent=FunctionSpy
	Main.BackgroundColor3=Color3.fromRGB(33,33,33)
	Main.BorderSizePixel=0
	Main.Position=UDim2.new(0,10,0,36)
	Main.Size=UDim2.new(0,536,0,328)
	Main.Active=true

	local function addRoundedCorners(instance, radius)
		local corner = UICorner:Clone()
		corner.CornerRadius = UDim.new(0, radius)
		corner.Parent = instance
	end

	local function addStroke(instance, color, thick)
		local stroke = UIStroke:Clone()
		stroke.Color = color
		stroke.Thickness = thick
		stroke.Parent = instance
	end

	addRoundedCorners(Main, 10)
	addStroke(Main, Color3.fromRGB(255, 255, 255), 2)

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

	FakeTitle.Parent=Main
	FakeTitle.BackgroundColor3=Color3.fromRGB(40,40,40)
	FakeTitle.BorderSizePixel=0
	FakeTitle.Position=UDim2.new(0,225,0,-26)
	FakeTitle.Size=UDim2.new(0.166044772,0,0,26)
	FakeTitle.Font=Enum.Font.GothamMedium
	FakeTitle.Text="FunctionSpy"
	FakeTitle.TextColor3=Color3.fromRGB(255,255,255)
	FakeTitle.TextSize=14.000

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

	local gradient = InstanceNew("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
	}
	gradient.Rotation = 45
	gradient.Parent = Title

	clear.Parent=Title
	clear.BackgroundTransparency=1.000
	clear.Position=UDim2.new(1,-28,0,2)
	clear.Size=UDim2.new(0,24,0,24)
	clear.ZIndex=2
	clear.Image="rbxassetid://3926305904"
	clear.ImageRectOffset=Vector2.new(924,724)
	clear.ImageRectSize=Vector2.new(36,36)

	MouseButtonFix(clear,function()
		if getgenv().functionspy then
			getgenv().functionspy.shutdown()
		end
	end)

	RightPanel.Parent=Main
	RightPanel.Active=true
	RightPanel.BackgroundColor3=Color3.fromRGB(35,35,35)
	RightPanel.BorderSizePixel=0
	RightPanel.Position=UDim2.new(0.349999994,0,0,0)
	RightPanel.Size=UDim2.new(0.649999976,0,1,0)
	RightPanel.CanvasSize=UDim2.new(0,0,0,0)
	RightPanel.HorizontalScrollBarInset=Enum.ScrollBarInset.ScrollBar
	RightPanel.ScrollBarThickness=3

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
	output.TextScaled = true
	output.TextXAlignment=Enum.TextXAlignment.Left
	output.TextYAlignment=Enum.TextYAlignment.Top

	clear_2.Parent=RightPanel
	clear_2.BackgroundColor3=Color3.fromRGB(30,30,30)
	clear_2.BorderSizePixel=0
	clear_2.Position=UDim2.new(0.0631457642,0,0.826219559,0)
	clear_2.Size=UDim2.new(0,140,0,33)
	clear_2.Font=Enum.Font.SourceSans
	clear_2.Text="Clear logs"
	clear_2.TextColor3=Color3.fromRGB(255,255,255)
	clear_2.TextSize=14.000

	copy.Parent=RightPanel
	copy.BackgroundColor3=Color3.fromRGB(30,30,30)
	copy.BorderSizePixel=0
	copy.Position=UDim2.new(0.545350134,0,0.826219559,0)
	copy.Size=UDim2.new(0,140,0,33)
	copy.Font=Enum.Font.SourceSans
	copy.Text="Copy info"
	copy.TextColor3=Color3.fromRGB(255,255,255)
	copy.TextSize=14.000

	local function addHoverEffect(button)
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		end)
	end

	addHoverEffect(clear_2)
	addHoverEffect(copy)

	local shadow = InstanceNew("ImageLabel")
	shadow.Parent = Main
	shadow.BackgroundTransparency = 1
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0, -10, 0, -10)
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = Color3.new(0, 0, 0)
	shadow.ImageTransparency = 0.5
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)

	function AKIHDI_fake_script()
		getgenv().functionspy={
			instance=Main.Parent;
			logging=true;
			connections={};
		}

		getgenv().functionspy.shutdown=function()
			for i,v in pairs(getgenv().functionspy.connections) do
				v:Disconnect()
			end
			getgenv().functionspy.connections={}
			getgenv().functionspy=nil
			Main.Parent:Destroy()
		end

		local connections={}

		local currentInfo=nil

		local getinfo = debug.getinfo or function(f)
			return {name = tostring(f)}
		end

		function log(name,text)
			local btn=Main.LeftPanel.example:Clone()
			btn.Parent=Main.LeftPanel
			btn.Name=name
			btn.name.Text=name
			btn.Visible=true
			Insert(connections,MouseButtonFix(btn,function()
				Main.RightPanel.output.Text=text
				currentInfo=text
			end))
		end

		MouseButtonFix(clear,function()
			if getgenv().functionspy then
				getgenv().functionspy.shutdown()
			end
		end)

		MouseButtonFix(Main.RightPanel.copy,function()
			if currentInfo~=nil then
				setclipboard(tostring(currentInfo))
			end
		end)

		MouseButtonFix(Main.RightPanel.clear,function()
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

		local Seralize
		local success, result = pcall(function()
			return loadstring(game:HttpGet('https://api.irisapp.ca/Scripts/SeralizeTable.lua',true))()
		end)

		if success then
			Seralize = result
		else
			Seralize = function(tbl, depth)
				if not tbl then return "nil" end
				if type(tbl) ~= "table" then return tostring(tbl) end

				depth = depth or 0
				if depth > 5 then return "..." end

				local indent = string.rep("    ", depth)
				local indent_inner = string.rep("    ", depth + 1)
				local result = "{\n"

				for k, v in pairs(tbl) do
					local key_str
					if type(k) == "string" then
						key_str = '["'..k..'"]'
					else
						key_str = "["..tostring(k).."]"
					end

					local value_str
					if type(v) == "table" then
						value_str = Seralize(v, depth + 1)
					elseif type(v) == "string" then
						value_str = '"'..v..'"'
					elseif type(v) == "function" then
						local info = debug.getinfo(v)
						value_str = "function "..(info.name or "").." "..tostring(v)
					else
						value_str = tostring(v)
					end

					result = result..indent_inner..key_str.." = "..value_str..",\n"
				end

				result = result..indent.."}"
				return result
			end
		end

		function GetFunctionInfo(func)
			if type(func) ~= "function" then return tostring(func) end

			local info = debug.getinfo(func)
			local result = "function"

			if info.name and info.name ~= "" then
				result = result.." "..info.name
			end

			result = result.." "..tostring(func).." {\n"
			result = result.."    source: "..(info.source or "unknown")..",\n"
			result = result.."    line: "..(info.linedefined or "?").." to "..(info.lastlinedefined or "?")..",\n"
			result = result.."    params: "..(info.nparams or "?")..(info.isvararg and " + vararg" or "")..",\n"

			local upvalues = ""
			local i = 1
			while true do
				local name, value = debug.getupvalue(func, i)
				if not name then break end

				local value_str
				if type(value) == "table" then
					value_str = "table: "..tostring(value)
				elseif type(value) == "function" then
					value_str = "function: "..tostring(value)
				elseif type(value) == "string" then
					value_str = '"'..value..'"'
				else
					value_str = tostring(value)
				end

				upvalues = upvalues.."        "..name.." = "..value_str..",\n"
				i = i + 1
			end

			if upvalues ~= "" then
				result = result.."    upvalues: {\n"..upvalues.."    },\n"
			end

			result = result.."}"
			return result
		end


		for i,v in next,toLog do
			if type(v)=="string" then
				local suc,err=pcall(function()
					local func = loadstring("return "..v)()
					if func then
						hooked[i]=hookfunction(func,function(...)
							local args={...}
							if getgenv().functionspy then
								pcall(function()
									out=""
									out=out..(v..",Args-> {")..("\n"):format()
									for l,k in pairs(args) do
										if type(k)=="function" then
											out = out..("    ["..tostring(l).."] Type-> "..type(k)..",Info->\n        "..GetFunctionInfo(k))..("\n"):format()
										elseif type(k)=="table" then
											out = out..("    ["..tostring(l).."] Type-> "..type(k)..",Data->\n"..Seralize(k))..("\n"):format()
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
									if getgenv().functionspy.logging==true then
										log(v,out)
									end
								end)
							end
							return hooked[i](...)
						end)
					end
				end)
				if not suc then
					warn("Something went wrong while hooking "..v..". Error: "..err)
				end
			elseif type(v)=="function" then
				local suc,err=pcall(function()
					hooked[i]=hookfunction(v,function(...)
						local args={...}
						if getgenv().functionspy then
							pcall(function()
								out=""
								local funcName = getinfo(v).name or "unknown"
								out=out..(funcName..",Args-> {")..("\n"):format()
								for l,k in pairs(args) do
									if type(k)=="function" then
										local funcInfo = getinfo(k)
										local funcName = funcInfo and funcInfo.name or "unknown"
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Name-> "..funcName)..("\n"):format()
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
								if getgenv().functionspy.logging==true then
									log(funcName,out)
								end
							end)
						end
						return hooked[i](...)
					end)
				end)
				if not suc then
					local funcName = getinfo(v).name or "unknown"
					warn("Something went wrong while hooking "..funcName..". Error: "..err)
				end
			end
		end

	end
	coroutine.wrap(AKIHDI_fake_script)()
	function BIPVKVC_fake_script()
		local script=InstanceNew('LocalScript',FakeTitle)

		Insert(getgenv().functionspy.connections,FakeTitle.MouseEnter:Connect(function()
			if getgenv().functionspy.logging==true then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif getgenv().functionspy.logging==false then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(getgenv().functionspy.connections,FakeTitle.MouseMoved:Connect(function()
			if getgenv().functionspy.logging==true then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif getgenv().functionspy.logging==false then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(getgenv().functionspy.connections,MouseButtonFix(FakeTitle,function()
			getgenv().functionspy.logging=not getgenv().functionspy.logging
			if getgenv().functionspy.logging==true then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif getgenv().functionspy.logging==false then
				TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(getgenv().functionspy.connections,FakeTitle.MouseLeave:Connect(function()
			TweenService:Create(FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,1,1)}):Play()
		end))
	end
	coroutine.wrap(BIPVKVC_fake_script)()
	function PRML_fake_script()
		MouseButtonFix(clear,function()
			getgenv().functionspy.shutdown()
		end)
	end
	coroutine.wrap(PRML_fake_script)()
	gui.draggablev2(Main,Title)
end)

function toggleFly()
	if flyEnabled then
		FLYING = false
		getHum().PlatformStand = false
		if goofyFLY then goofyFLY:Destroy() end
		flyEnabled = false
	else
		FLYING = true
		sFLY()
		flyEnabled = true
	end
end

function connectFlyKey()
	if keybindConn then
		keybindConn:Disconnect()
	end
	keybindConn = cmdm.KeyDown:Connect(function(KEY)
		if KEY:lower() == toggleKey then
			toggleFly()
		end
	end)
end

cmd.add({"fly"}, {"fly [speed]", "Enable flight"}, function(...)
	local arg = (...) or nil
	flySpeed = arg or 1
	connectFlyKey()
	flyEnabled = true

	if mFlyBruh then
		mFlyBruh:Destroy()
		mFlyBruh = nil
	end
	cmd.run({"uncfly", ''})
	cmd.run({"unvfly", ''})

	if IsOnMobile then
		Wait()
		DoNotif(adminName.." detected mobile. Fly button added for easier use.", 2)

		mFlyBruh = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local speedBox = InstanceNew("TextBox")
		local toggleBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local corner2 = InstanceNew("UICorner")
		local corner3 = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(mFlyBruh)
		mFlyBruh.ResetOnSpawn = false

		btn.Parent = mFlyBruh
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

		speedBox.Parent = mFlyBruh
		speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(flySpeed)
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
				if not mOn then
					local newSpeed = tonumber(speedBox.Text) or flySpeed
					flySpeed = newSpeed
					speedBox.Text = tostring(flySpeed)
					mOn = true
					btn.Text = "Unfly"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					sFLY()
				else
					mOn = false
					btn.Text = "Fly"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					FLYING = false
					getHum().PlatformStand = false
					if goofyFLY then goofyFLY:Destroy() end
				end
			end)
		end)()

		gui.draggablev2(btn)
		gui.draggablev2(speedBox)
	else
		FLYING = false
		getHum().PlatformStand = false
		Wait()
		DoNotif("Fly enabled. Press '"..toggleKey:upper().."' to toggle flying.")
		sFLY()
		speedofthevfly = flySpeed
		speedofthefly = flySpeed
	end
end, true)

cmd.add({"unfly"}, {"unfly", "Disable flight"}, function(bool)
	Wait()
	if not bool then DoNotif("Not flying anymore", 2) end
	FLYING = false
	getHum().PlatformStand = false
	if goofyFLY then goofyFLY:Destroy() end
	mOn = false
	if mFlyBruh then
		mFlyBruh:Destroy()
		mFlyBruh = nil
	end
	if keybindConn then
		keybindConn:Disconnect()
		keybindConn = nil
	end
end)

if IsOnPC then
	cmd.add({"flybind", "flykeybind","bindfly"}, {"flybind (flykeybind, bindfly)", "set a custom keybind for the 'fly' command"}, function(...)
		local newKey = (...):lower()
		if newKey == "" or newKey==nil then
			DoNotif("Please provide a keybind.")
			return
		end

		toggleKey = newKey
		if keybindConn then
			keybindConn:Disconnect()
			keybindConn = nil
		end
		connectFlyKey()

		DoNotif("Fly keybind set to '"..toggleKey:upper().."'")
	end,true)
end

function toggleCFly()
	local char = cmdlp.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local head = char and char:FindFirstChild("Head")

	if cFlyEnabled then
		FLYING = false
		cFlyEnabled = false

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
		cFlyEnabled = true
		sFLY(nil, true)
	end
end

function connectCFlyKey()
	if cKeybindConn then
		cKeybindConn:Disconnect()
	end
	cKeybindConn = cmdm.KeyDown:Connect(function(KEY)
		if KEY:lower() == cToggleKey then
			toggleCFly()
		end
	end)
end

cmd.add({"cframefly", "cfly"}, {"cframefly [speed] (cfly)", "Enable CFrame-based flight"}, function(...)
	local arg = (...) or nil
	cFlySpeed = tonumber(arg) or cFlySpeed
	flySpeed = cFlySpeed

	connectCFlyKey()
	cFlyEnabled = true

	if cFlyGUI then
		cFlyGUI:Destroy()
		cFlyGUI = nil
	end

	cmd.run({"unfly", ''})
	cmd.run({"unvfly", ''})

	if IsOnMobile then
		Wait()
		DoNotif(adminName.." detected mobile. CFrame Fly button added.", 2)

		cFlyGUI = InstanceNew("ScreenGui")
		local btn = InstanceNew("TextButton")
		local speedBox = InstanceNew("TextBox")
		local toggleBtn = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")
		local corner2 = InstanceNew("UICorner")
		local corner3 = InstanceNew("UICorner")
		local aspect = InstanceNew("UIAspectRatioConstraint")

		NaProtectUI(cFlyGUI)
		cFlyGUI.ResetOnSpawn = false

		btn.Parent = cFlyGUI
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

		speedBox.Parent = cFlyGUI
		speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(cFlySpeed)
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
				if not cOn then
					local newSpeed = tonumber(speedBox.Text) or cFlySpeed
					cFlySpeed = newSpeed
					flySpeed = cFlySpeed
					speedBox.Text = tostring(cFlySpeed)
					cOn = true
					btn.Text = "UnCfly"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					sFLY(true, true)
				else
					cOn = false
					btn.Text = "CFly"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					FLYING = false
					local hum = getHum()
					local head = getChar() and getChar():FindFirstChild("Head")
					head.Anchored = false
					hum.PlatformStand = false
					if CFloop then CFloop:Disconnect() CFloop = nil end
					if goofyFLY then goofyFLY:Destroy() end
				end
			end)
		end)()

		gui.draggablev2(btn)
		gui.draggablev2(speedBox)
	else
		FLYING = false
		getHum().PlatformStand = false
		Wait()
		DoNotif("CFrame Fly enabled. Press '"..cToggleKey:upper().."' to toggle.")
		sFLY(true, true)
	end
end, true)

cmd.add({"uncframefly","uncfly"}, {"uncframefly (uncfly)", "Disable CFrame-based flight"}, function(bool)
	Wait()
	if not bool then DoNotif("CFrame Fly disabled.", 2) end
	FLYING = false

	local char = cmdlp.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local head = char and char:FindFirstChild("Head")

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

	cOn = false
	if cFlyGUI then
		cFlyGUI:Destroy()
		cFlyGUI = nil
	end
	if cKeybindConn then
		cKeybindConn:Disconnect()
		cKeybindConn = nil
	end
end)

if IsOnPC then
	cmd.add({"cflybind", "cframeflybind", "bindcfly"}, {"cflybind [key] (cframeflybind, bindcfly)", "Set custom keybind for CFrame fly"}, function(...)
		local newKey = (...) or ""
		newKey = newKey:lower()
		if newKey == "" then
			DoNotif("Please provide a keybind.")
			return
		end

		cToggleKey = newKey

		if cKeybindConn then
			cKeybindConn:Disconnect()
			cKeybindConn = nil
		end

		connectCFlyKey()
		DoNotif("CFrame fly keybind set to '"..cToggleKey:upper().."'")
	end,true)
end

function toggleTFly()
	if TFlyEnabled then
		TFlyEnabled = false
		for _, v in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if v:GetAttribute("tflyPart") then
				v:Destroy()
			end
		end
		local hum = getHum()
		if hum then hum.PlatformStand = false end
		if TFLYBTN then
			TFLYBTN.Text = "TFly"
			TFLYBTN.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
		end
	else
		TFlyEnabled = true
		local speed = TflySpeed
		local Humanoid = getHum()

		tflyCORE = InstanceNew("Part", SafeGetService("Workspace").CurrentCamera)
		tflyCORE:SetAttribute("tflyPart", true)
		tflyCORE.Size = Vector3.new(0.05, 0.05, 0.05)
		tflyCORE.CanCollide = false

		local Weld = InstanceNew("Weld", tflyCORE)
		Weld.Part0 = tflyCORE
		Weld.Part1 = Humanoid.RootPart
		Weld.C0 = CFrame.new(0, 0, 0)

		local pos = InstanceNew("BodyPosition", tflyCORE)
		local gyro = InstanceNew("BodyGyro", tflyCORE)
		pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
		pos.position = tflyCORE.Position
		gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		gyro.cframe = tflyCORE.CFrame

		coroutine.wrap(function()
			repeat
				Wait()
				Humanoid.PlatformStand = true
				local newPosition = gyro.cframe - gyro.cframe.p + pos.position

				local moveVec = GetCustomMoveVector()
				moveVec = Vector3.new(moveVec.X, moveVec.Y, -moveVec.Z)

				if moveVec.Magnitude > 0 then
					local camera = SafeGetService("Workspace").CurrentCamera
					newPosition = newPosition + (camera.CFrame.RightVector * moveVec.X * speed)
					newPosition = newPosition + (camera.CFrame.LookVector * moveVec.Z * speed)
				end

				pos.position = newPosition.p
				gyro.cframe = SafeGetService("Workspace").CurrentCamera.CoordinateFrame
			until not TFlyEnabled

			if gyro then gyro:Destroy() end
			if pos then pos:Destroy() end
			Humanoid.PlatformStand = false
		end)()

		if TFLYBTN then
			TFLYBTN.Text = "UnTFly"
			TFLYBTN.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		end
	end
end

cmd.add({"tfly", "tweenfly"}, {"tfly [speed] (tweenfly)", "Enables smooth flying"}, function(...)
	local arg = (...) or nil
	TflySpeed = arg or 1

	if IsOnMobile then
		Wait()
		DoNotif(adminName.." detected mobile. Tfly button added for easier use.", 2)

		if tflyButtonUI then tflyButtonUI:Destroy() end
		if TFLYBTN then TFLYBTN:Destroy() end

		tflyButtonUI = InstanceNew("ScreenGui")
		TFLYBTN = InstanceNew("TextButton")
		local corner = InstanceNew("UICorner")

		NaProtectUI(tflyButtonUI)
		tflyButtonUI.ResetOnSpawn = false

		TFLYBTN.Parent = tflyButtonUI
		TFLYBTN.BackgroundColor3 = Color3.fromRGB(30,30,30)
		TFLYBTN.BackgroundTransparency = 0.1
		TFLYBTN.Position = UDim2.new(0.9,0,0.5,0)
		TFLYBTN.Size = UDim2.new(0.08,0,0.1,0)
		TFLYBTN.Font = Enum.Font.GothamBold
		TFLYBTN.Text = "TFly"
		TFLYBTN.TextColor3 = Color3.fromRGB(255,255,255)
		TFLYBTN.TextSize = 18
		TFLYBTN.TextWrapped = true
		TFLYBTN.Active = true
		TFLYBTN.TextScaled = true

		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = TFLYBTN

		MouseButtonFix(TFLYBTN, toggleTFly)
		gui.draggablev2(TFLYBTN)
	else
		if tflyKeyConn then tflyKeyConn:Disconnect() end
		tflyKeyConn = cmdm.KeyDown:Connect(function(key)
			if key:lower() == tflyToggleKey then
				toggleTFly()
			end
		end)
		DoNotif("TFly keybind set to '"..tflyToggleKey:upper().."'. Press to toggle.")
	end

	toggleTFly()
end, true)

cmd.add({"untfly", "untweenfly"}, {"untfly (untweenfly)", "Disables tween flying"}, function()
	Wait()
	DoNotif("Not flying anymore", 2)
	TFlyEnabled = false
	for _, v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:GetAttribute("tflyPart") then
			v:Destroy()
		end
	end
	local hum = getHum()
	if hum then hum.PlatformStand = false end
	if tflyButtonUI then
		tflyButtonUI:Destroy()
		tflyButtonUI = nil
	end
	if TFLYBTN then
		TFLYBTN:Destroy()
		TFLYBTN = nil
	end
	if tflyKeyConn then
		tflyKeyConn:Disconnect()
		tflyKeyConn = nil
	end
end)

if IsOnPC then
	cmd.add({"tflykeybind", "bindtfly", "tflybind"}, {"tflykeybind [key] (bindtfly, tflybind)", "Set keybind for tfly toggle"}, function(...)
		local key = (...) or ""
		if key == "" then
			DoNotif("Please provide a key.")
			return
		end
		tflyToggleKey = key:lower()
		if tflyKeyConn then tflyKeyConn:Disconnect() end
		tflyKeyConn = cmdm.KeyDown:Connect(function(k)
			if k:lower() == tflyToggleKey then
				toggleTFly()
			end
		end)
		DoNotif("TFly keybind set to '"..tflyToggleKey:upper().."'")
	end, true)
end

cmd.add({"noclip","nclip","nc"},{"noclip","Disable your player's collision"},function()
	lib.disconnect("noclip")
	lib.connect("noclip",RunService.Stepped:Connect(function()
		if not getChar() then return end
		for i,v in pairs(getChar():GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide=false
			end
		end
	end))
end)

cmd.add({"clip","c"},{"clip","Enable your player's collision"},function()
	lib.disconnect("noclip")
end)

originalPos = nil
platformPart = nil
activationTime = nil

cmd.add({"antibang"}, {"antibang", "prevents users to bang you (still WORK IN PROGRESS)"}, function()
	lib.disconnect("antibang_loop")

	local root = getRoot(LocalPlayer.Character)
	if not root then return end

	originalPos = root.CFrame
	local orgHeight = SafeGetService("Workspace").FallenPartsDestroyHeight
	local anims = {"rbxassetid://5918726674", "rbxassetid://148840371", "rbxassetid://698251653", "rbxassetid://72042024", "rbxassetid://189854234", "rbxassetid://106772613", "rbxassetid://10714360343", "rbxassetid://95383980"}
	local inVoid = false
	local targetPlayer = nil
	local toldNotif = false
	local activationTime = nil

	LocalPlayer.CharacterAdded:Connect(function(char)
		Wait(1)
		root = getRoot(char)
	end)

	lib.connect("antibang_loop", RunService.Stepped:Connect(function()
		for _, p in pairs(SafeGetService("Players"):GetPlayers()) do
			if p ~= LocalPlayer and p.Character and getRoot(p.Character) then
				if (getRoot(p.Character).Position - root.Position).Magnitude <= 10 then
					local tracks = p.Character:FindFirstChild("Humanoid"):GetPlayingAnimationTracks()
					for _, t in pairs(tracks) do
						if Discover(anims, t.Animation.AnimationId) then
							if not inVoid then
								inVoid = true
								activationTime = tick()
								targetPlayer = p
								SafeGetService("Workspace").FallenPartsDestroyHeight = 0/1/0
								platformPart = InstanceNew("Part")
								platformPart.Size = Vector3.new(9999, 1, 9999)
								platformPart.Anchored = true
								platformPart.CanCollide = true
								platformPart.Transparency = 1
								platformPart.Position = Vector3.new(0, orgHeight - 30, 0)
								platformPart.Parent = SafeGetService("Workspace").CurrentCamera
								root.CFrame = CFrame.new(Vector3.new(0, orgHeight - 25, 0))
								if not toldNotif then
									toldNotif = true
									DoNotif("Antibang activated | Target: "..nameChecker(targetPlayer), 2)
								end
							end
						end
					end
				end
			end
		end

		if inVoid then
			if (not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") or targetPlayer.Character.Humanoid.Health <= 0)
				or (activationTime and tick() - activationTime >= 10) then
				inVoid = false
				targetPlayer = nil
				root.CFrame = originalPos
				root.Anchored = true
				Wait()
				root.Anchored = false
				SafeGetService("Workspace").FallenPartsDestroyHeight = orgHeight
				if platformPart then
					platformPart:Destroy()
					platformPart = nil
				end
				if toldNotif then
					toldNotif = false
					if activationTime and tick() - activationTime >= 10 then
						DoNotif("Antibang deactivated (timeout)", 2)
					else
						DoNotif("Antibang deactivated", 2)
					end
				end
			end
		end
	end))

	DoNotif("Antibang Enabled", 3)
end)

cmd.add({"unantibang"}, {"unantibang", "disables antibang"}, function()
	lib.disconnect("antibang_loop")
	if platformPart then
		platformPart:Destroy()
		platformPart = nil
	end
	DoNotif("Antibang Disabled", 3)
end)

cmd.add({"orbit"}, {"orbit <player> <distance>", "Orbit around a player"}, function(p, d)
	lib.disconnect("orbit")
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
	lib.connect("orbit", RunService.Stepped:Connect(function()
		if not (thrp.Parent and hrp.Parent) then
			lib.disconnect("orbit")
			return
		end
		sineX, sineZ = sineX + 0.05, sineZ + 0.05
		local sinX, sinZ = math.sin(sineX), math.sin(sineZ)
		hrp.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(sinX * dist, 0, sinZ * dist) * (hrp.CFrame - hrp.CFrame.p) + thrp.CFrame.p
	end))
end, true)

cmd.add({"uporbit"}, {"uporbit <player> <distance>", "Orbit around a player on the Y axis"}, function(p, d)
	lib.disconnect("orbit")
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
	lib.connect("orbit", RunService.Stepped:Connect(function()
		if not (thrp.Parent and hrp.Parent) then
			lib.disconnect("orbit")
			return
		end
		sineX, sineY = sineX + 0.05, sineY + 0.05
		local sinX, sinY = math.sin(sineX), math.sin(sineY)
		hrp.Velocity = Vector3.zero
		hrp.CFrame = CFrame.new(sinX * dist, sinY * dist, 0) * (hrp.CFrame - hrp.CFrame.p) + thrp.CFrame.p
	end))
end, true)

cmd.add({"unorbit"}, {"unorbit", "Stop orbiting"}, function()
	lib.disconnect("orbit")
end)

cmd.add({"freezewalk"},{"freezewalk","Freezes your character on the server but lets you walk on the client"},function()
	local Character=getChar()
	local Root=getRoot(Character)

	if IsR6() then
		local Clone=Root:Clone()
		Root:Destroy()
		Clone.Parent=Character
	else
		Character.LowerTorso.Anchored=true
		Character.LowerTorso.Root:Destroy()
	end
	DoNotif("freezewalk is activated,reset to stop it")
end)

fcBTNTOGGLE = nil

cmd.add({"freecam","fc","fcam"},{"freecam [speed] (fc,fcam)","Enable free camera"},function(...)
	argg = (...)
	local speed = argg or 5

	if lib.isConnected("freecam") then
		lib.disconnect("freecam")
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

		lib.connect("freecam", RunService.RenderStepped:Connect(function(dt)
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
				if not mOn then
					local newSpeed = tonumber(speedBox.Text) or 5
					if newSpeed then
						speed = newSpeed
						speedBox.Text = tostring(speed)
					else
						speed = 5
						speedBox.Text = tostring(speed)
					end
					mOn = true
					btn.Text = "UNFC"
					btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
					runFREECAM()
				else
					mOn = false
					btn.Text = "FC"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					if lib.isConnected("freecam") then
						lib.disconnect("freecam")
					end
					camera.CameraSubject = getChar()
					Spawn(function() cmd.run({"unfr"}) end)
				end
			end)
		end)()

		gui.draggablev2(btn)
		gui.draggablev2(speedBox)
	else
		DoNotif("Freecam is activated, use WASD to move around", 2)
		runFREECAM()
	end
end, true)

cmd.add({"unfreecam","unfc","unfcam"},{"unfreecam (unfc,unfcam)","Disable free camera"},function()
	lib.disconnect("freecam")
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

	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
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
	local cam = SafeGetService("Workspace").CurrentCamera

	Wait(Players.RespawnTime - 0.165)

	local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end

	Wait(0.5)

	if rootPart then
		getRoot(LocalPlayer.Character).CFrame = rootPart.CFrame
	end

	SafeGetService("Workspace").CurrentCamera = cam
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
	lib.disconnect("cm")
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

			tcon[#tcon] = lib.connect("cm", mouse.Button1Down:Connect(function()
				tool:Activate()
			end))
			tcon[#tcon] = lib.connect("cm", tool.Changed:Connect(function(p)
				if p == "Grip" and tool.Grip ~= g then
					tool.Grip = g
				end
			end))

			lib.connect("cm", tool.AncestryChanged:Connect(function()
				for i = 1, #tcon do
					tcon[i]:Disconnect()
				end
			end))
		end
	end
end,true)

cmd.add({"seizure"}, {"seizure", "Gives you a seizure"}, function()
	Spawn(function()
		if getgenv().Lzzz == true then return end

		local Anim = InstanceNew("Animation")
		if LocalPlayer.Character:FindFirstChild("UpperTorso") then
			Anim.AnimationId = "rbxassetid://507767968"
		else
			Anim.AnimationId = "rbxassetid://180436148"
		end
		local k = getHum():LoadAnimation(Anim)
		getgenv().ssss = LocalPlayer:GetMouse()
		getgenv().Lzzz = false

		if Lzzz == false then
			getgenv().Lzzz = true
			if LocalPlayer.Character:FindFirstChild("UpperTorso") then
				Anim.AnimationId = "rbxassetid://507767968"
			else
				Anim.AnimationId = "rbxassetid://180436148"
			end
			getgenv().currentnormal = SafeGetService("Workspace").Gravity
			SafeGetService("Workspace").Gravity = 196.2
			LocalPlayer.Character:PivotTo(LocalPlayer.Character:GetPivot() * CFrame.Angles(2, 0, 0))
			Wait(0.5)
			getHum().PlatformStand = true
			LocalPlayer.Character.Animate.Disabled = true

			k:Play()
			k:AdjustSpeed(10)

			LocalPlayer.Character.Animate.Disabled = true
		else
			getgenv().Lzzz = false
			if LocalPlayer.Character:FindFirstChild("UpperTorso") then
				Anim.AnimationId = "rbxassetid://507767968"
			else
				Anim.AnimationId = "rbxassetid://180436148"
			end
			SafeGetService("Workspace").Gravity = currentnormal
			getHum().PlatformStand = false
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
		if LocalPlayer.Character:FindFirstChild("UpperTorso") then
			Anim.AnimationId = "rbxassetid://507767968"
		else
			Anim.AnimationId = "rbxassetid://180436148"
		end

		local k = getHum():LoadAnimation(Anim)

		getgenv().Lzzz = false
		SafeGetService("Workspace").Gravity = currentnormal
		getHum().PlatformStand = false
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
	DoNotif("Hid the player")
	local Username = (...)
	local target = getPlr(Username)
	for _, plr in next, target do
		if plr and plr.Character then
			local A_1 = "/mute "..plr.Name
			local A_2 = "All"
			lib.LocalPlayerChat(A_1, A_2)
			plr.Character.Parent = Lighting
		end
	end
end, true)

cmd.add({"unhide", "show"}, {"show <player> (unhide)", "places the selected player back to workspace"}, function(...)
	Wait()
	DoNotif("Unhid the player")
	local Username = (...)
	local target = getPlr(Username)
	for _, plr in next, target do
		if plr and plr.Character then
			local A_1 = "/unmute "..plr.Name
			local A_2 = "All"
			lib.LocalPlayerChat(A_1, A_2)
			plr.Character.Parent = SafeGetService("Workspace")
		end
	end
end, true)

if IsOnPC then
	cmd.add({"aimbot","aimbotui","aimbotgui"},{"aimbot (aimbotui,aimbotgui)","aimbot and yeah"},function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/NewAimbot.lua"))()
		--loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Aimbot.lua",true))()
	end)
end

cmd.add({"grabtools"},{"grabtools","grabs dropped tools"},function()
	local c=getChar()
	if c and getHum() then
		for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if v:IsA("Tool") then
				getHum():EquipTool(v)
			end
		end
	end
end)

cmd.add({"loopgrabtools"},{"loopgrabtools","Loop grabs dropped tools"},function()
	loopgrab=true
	repeat Wait(1)
		local c=getChar()
		if c and getHum() then
			for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
				if v:IsA("Tool") then
					getHum():EquipTool(v)
				end
			end
		end
	until loopgrab==false
end)

cmd.add({"unloopgrabtools"},{"unloopgrabtools","Stops the loop grab command"},function()
	loopgrab=false
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

cmd.add({"antichatlogs", "antichatlogger"}, {"antichatlogs (antichatlogger)", "Prevents you from getting banning when typing unspeakable messages (game needs legacy chat service or manual override)"}, function()
	local CachedChannels = {}

	lib.BypassChatMessage = function(message, recipient)
		if LegacyChat then
			local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
			if not chatEvents then return end
			if recipient and recipient ~= "All" then
				chatEvents.SayMessageRequest:FireServer("/w "..recipient.." "..message, "All")
			else
				chatEvents.SayMessageRequest:FireServer(message, "All")
			end
		else
			local targetChannel
	
			if recipient and recipient ~= "All" then
				targetChannel = CachedChannels[recipient]
				if targetChannel then
					if not targetChannel:IsDescendantOf(TextChatService)
						or not targetChannel:FindFirstChild(recipient)
						or not targetChannel:FindFirstChild(LocalPlayer.Name) then
						CachedChannels[recipient] = nil
						targetChannel = nil
					end
				end
				if not targetChannel then
					for _, ch in pairs(TextChatService.TextChannels:GetChildren()) do
						if ch.Name:find("RBXWhisper:") and ch:FindFirstChild(recipient) then
							targetChannel = ch
							CachedChannels[recipient] = ch
							break
						end
					end
				end
			end
	
			if not targetChannel then
				targetChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
					or TextChatService.TextChannels:FindFirstChild("General")
			end
	
			if targetChannel then
				targetChannel:SendAsync(message)
			end
		end
	end

	local function getTargetName(targetChip)
		if targetChip and targetChip:IsA("TextButton") then
			local displayName = Match(targetChip.Text or "", "^%[To%s+(.-)%]$")
			if displayName and displayName ~= "" then
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr.DisplayName:lower() == displayName:lower() then
						return plr.Name
					end
				end
			end
		end
		return "All"
	end

	if LegacyChat then
		local success = pcall(function()
			local ChatMain = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("ChatScript"):WaitForChild("ChatMain"))
			rawset(ChatMain, "MessagePosted", {
				fire = function(message)
					lib.BypassChatMessage(message)
				end,
				wait = function() end,
				connect = function() end
			})
		end)
		DoNotif(success and "Antichatlogs active (Legacy Chat)" or "Failed to hook legacy chat")
	else
		Spawn(function()
			repeat Wait() until COREGUI:FindFirstChild("ExperienceChat")
			local experienceChat = COREGUI:WaitForChild("ExperienceChat")
			local appLayout = experienceChat:FindFirstChild("appLayout")
			if not appLayout then return end

			local chatInputBar = appLayout:FindFirstChild("chatInputBar")
			if not chatInputBar then return end

			local background = chatInputBar:FindFirstChild("Background")
			if not background then return end

			local container = background:FindFirstChild("Container")
			if not container then return end

			local textContainer = container:FindFirstChild("TextContainer")
			local textBoxContainer = textContainer and textContainer:FindFirstChild("TextBoxContainer")
			local chatBox = textBoxContainer and textBoxContainer:FindFirstChild("TextBox")
			local sendButton = container:FindFirstChild("SendButton")
			local targetChip = textContainer and textContainer:FindFirstChild("TargetChannelChip")

			if chatBox then
				chatBox.FocusLost:Connect(function(enterPressed)
					if enterPressed and chatBox.Text ~= "" then
						local msg = chatBox.Text
						local recipient = getTargetName(targetChip)
						chatBox.Text = ""
						Defer(function()
							lib.BypassChatMessage(msg, recipient)
						end)
					end
				end)
			end

			if sendButton and chatBox then
				sendButton.MouseButton1Click:Connect(function()
					if chatBox.Text ~= "" then
						local msg = chatBox.Text
						local recipient = getTargetName(targetChip)
						chatBox.Text = ""
						Defer(function()
							lib.BypassChatMessage(msg, recipient)
						end)
					end
				end)
			end
		end)
		DoNotif("Antichatlogs active (TextChatService)")
	end
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
  local res = NAREQUEST({Url = url, Method = "GET"})
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
gui.draggable(main, top)
end
local ok, result = pcall(getBadges)
if ok then
  createBadgeUI(result)
else
  DoNotif("Failed to fetch badge data")
end
end)

cmd.add({"bodytransparency","btransparency", "bodyt"}, {"bodytransparency <number> (btransparency,bodyt)", "Sets LocalTransparencyModifier of bodyparts to whatever number you put (0-1)"}, function(v)
	local vv = tonumber(v) or 0

	lib.disconnect("body_transparency")

	lib.connect("body_transparency", RunService.RenderStepped:Connect(function()
		local char = LocalPlayer.Character
		if char then
			for _, p in ipairs(char:GetChildren()) do
				if p:IsA("BasePart") and p.Name:lower() ~= "head" then
					p.LocalTransparencyModifier = vv
				end
			end
		end
	end))

	DoNotif("Body transparency set to "..vv, 1.5)
end, true)

cmd.add({"unbodytransparency", "unbtransparency", "unbodyt"}, {"unbodytransparency (unbtransparency,unbodyt)", "Stops transparency loop"}, function()
	if lib.isConnected("body_transparency") then
		lib.disconnect("body_transparency")
	else
		DoNotif("No loop running", 2)
	end
end)

cmd.add({"animationspeed", "animspeed", "aspeed"}, {"animationspeed <speed> (animspeed,aspeed)", "Adjusts the speed of currently playing animations"}, function(speed)
	local targetSpeed = tonumber(speed) or 1

	lib.disconnect("animation_speed")

	lib.connect("animation_speed", RunService.Heartbeat:Connect(function()
		local character = getChar()
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:FindFirstChildOfClass("AnimationController")
		if humanoid then
			for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
				if track and track:IsA("AnimationTrack") then
					track:AdjustSpeed(targetSpeed)
				end
			end
		end
	end))

	DoNotif("Animation speed set to "..targetSpeed)
end, true)

cmd.add({"unanimationspeed", "unanimspeed", "unaspeed"}, {"unanimationspeed (unanimspeed,unaspeed)", "Stops the animation speed adjustment loop"}, function()
	if lib.isConnected("animation_speed") then
		lib.disconnect("animation_speed")
		DoNotif("Animation speed disabled")
	else
		DoNotif("No active animation speed to disable")
	end
end)

cmd.add({"placeid","pid"},{"placeid (pid)","Copies the PlaceId of the game you're in"},function()
	setclipboard(tostring(PlaceId))

	Wait();

	DoNotif("Copied the game's PlaceId: "..PlaceId)
end)

cmd.add({"gameid","universeid","gid"},{"gameid (universeid,gid)","Copies the GameId/Universe Id of the game you're in"},function()
	setclipboard(tostring(GameId))

	Wait();

	DoNotif("Copied the game's GameId: "..GameId)
end)

cmd.add({"firework"}, {"firework", "pop"}, function()
	local character = LocalPlayer.Character
	if not character then return end

	local root = getRoot(character)
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not root or not humanoid then return end

	humanoid.PlatformStand = true

	local part = InstanceNew("Part")
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.Parent = SafeGetService("Workspace").CurrentCamera

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

	lib.connect("firework_spin", RunService.Heartbeat:Connect(function(dt)
		if tick() - startTime > spinTime then
			lib.disconnect("firework_spin")
			bv:Destroy()
			bg:Destroy()
			part:Destroy()

			local explosion = InstanceNew("Explosion")
			explosion.Position = root.Position
			explosion.BlastRadius = 6
			explosion.BlastPressure = 500000
			explosion.Parent = SafeGetService("Workspace")

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

	DoNotif("Copied the game's place name: "..placeNaem)
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
		DoNotif("Copied the username of "..nameChecker(plr))
	end
end, true)

cmd.add({"copydisplay", "cdisplay"}, {"copydisplay <player> (cdisplay)", "Copies the display name of the target"}, function(...)
	local usr = ...
	local tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.DisplayName))
		Wait()
		DoNotif("Copied the display name of "..nameChecker(plr))
	end
end, true)

cmd.add({"copyid", "id"}, {"copyid <player> (id)", "Copies the UserId of the target"}, function(...)
	local usr = ...
	local tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.UserId))
		Wait()
		DoNotif("Copied the UserId of "..nameChecker(plr))
	end
end, true)

--[ PLAYER ]--
function toggleKB(enable)
	local p = Players.LocalPlayer
	local hrp = getRoot(p.Character)
	local parts = SafeGetService("Workspace"):GetPartBoundsInRadius(hrp.Position, 10)
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
	DoNotif("Netbypass enabled")
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

cmd.add({"chat", "message"}, {"chat <text> (message)", "Chats for you, useful if you're muted"}, function(...)
	local chatMessage = Concat({...}, " ")
	local chatTarget = "All"
	lib.LocalPlayerChat(chatMessage, chatTarget)
end, true)

cmd.add({"privatemessage", "pm"}, {"privatemessage <player> <text> (pm)", "Sends a private message to a player"}, function(...)
	local args = {...}
	local Player = getPlr(args[1])

	for _, plr in next, Player do
		local chatMessage = Concat(args, " ", 2)
		local chatTarget = plr.Name
		local result = lib.LocalPlayerChat(chatMessage, chatTarget)
		if result == "Hooking" then
			Wait(.5)
			lib.LocalPlayerChat(chatMessage, chatTarget)
		end
	end
end,true)

cmd.add({"mimicchat", "mimic"}, {"mimicchat <player> (mimic)", "Mimics the chat of a player"}, function(name)
	lib.disconnect("mimicchat")

	local targets = getPlr(name)
	if #targets == 0 then
		DoNotif("Player not found",2)
		return
	end

	for _, plr in pairs(targets) do
		DoNotif("Now mimicking "..plr.Name.."'s chat", 2)

		lib.connect("mimicchat", plr.Chatted:Connect(function(msg)
			lib.LocalPlayerChat(msg, "All")
		end))
	end
end, true)

cmd.add({"stopmimic", "unmimic"}, {"stopmimic (unmimic)", "Stops mimicking a player"}, function()
	lib.disconnect("mimicchat")
	DoNotif("Stopped mimicking", 2)
end, true)

cmd.add({"fixcam", "fix"}, {"fixcam", "Fix your camera"}, function()
	local ws = SafeGetService("Workspace")
	local plr = Players.LocalPlayer
	ws.CurrentCamera:Remove()
	Wait(0.1)
	repeat Wait() until plr.Character
	local cam = ws.CurrentCamera
	cam.CameraSubject = plr.Character:FindFirstChildWhichIsA("Humanoid")
	cam.CameraType = "Custom"
	plr.CameraMinZoomDistance = 0.5
	plr.CameraMaxZoomDistance = math.huge
	plr.CameraMode = "Classic"
	plr.Character:FindFirstChild("Head").Anchored = false
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

	local ScreenGui = createUIElement("ScreenGui", { Name = randomString() })
	NaProtectUI(ScreenGui)

	local background = createUIElement("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 0
	}, ScreenGui)

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
				{ Size = UDim2.new(0, newSize, 0, newSize), Rotation = newRotation }
			)
			tween:Play()
			tween.Completed:Wait()
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
			ttLabelLeft.Text = "Challenge: "..challenge:sub(1, math.random(1, #challenge))
			Wait(math.random(0.05, 0.15))
		end
	end

	local function dramaticCountdown(num)
		dramaticLabel.Text = tostring(num)
		playSound(138081500, 2)
		Wait(1)
		dramaticLabel.Text = ""
	end

	local function count()
		local num = 180
		while Wait(1) do
			if not getgenv().SawFinish then
				if num > 0 then
					num = num - 1
					playSound(138081500, 1)
					ttLabelRight.Text = "Time Remaining: "..num.." seconds"

					local progress = num / 180
					local tween = TweenService:Create(
						progressFill,
						TweenInfo.new(1, Enum.EasingStyle.Linear),
						{ Size = UDim2.new(progress, 0, 1, 0) }
					)
					tween:Play()

					if num == 30 or num == 20 or num == 10 then
						dramaticCountdown(num)
					elseif num <= 10 then
						dramaticLabel.Text = tostring(num)
						playSound(138081500, 2)
					end
				else
					Players.LocalPlayer:Kick("You Failed The Challenge")
				end
			else
				ttLabelLeft.Text = "You Survived... For Now"
				ttLabelRight.Text = ""
				dramaticLabel.Text = ""
				playSound(9125915751, 5)
				Wait(2)
				ScreenGui:Destroy()
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

attachedPart=nil

cmd.add({"fling"}, {"fling <player>", "Fling the given player"}, function(plr)
	local mouse = LocalPlayer:GetMouse()
	local Targets = {plr}
	local Players = game:GetService("Players")
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
	local Message = function(_Title, _Text, Time)
		print(_Title)
		print(_Text)
		print(Time)
	end
	local SkidFling = function(TargetPlayer)
		if attachedPart then attachedPart:Destroy() attachedPart=nil end
		local Character = Player.Character
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
		local HRP = Humanoid and Humanoid.RootPart
		local camera = SafeGetService("Workspace").CurrentCamera
		attachedPart = InstanceNew("Part")
		attachedPart.Size = Vector3.new(1, 1, 1)
		attachedPart.Transparency = 1
		attachedPart.CanCollide = false
		attachedPart.Anchored = false
		attachedPart.Parent = camera
		local weld = InstanceNew("WeldConstraint")
		weld.Part0 = HRP
		weld.Part1 = attachedPart
		weld.Parent = attachedPart
		local bodyGyro = InstanceNew("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
		bodyGyro.D = 1000
		bodyGyro.P = 2000
		bodyGyro.Parent = attachedPart
		local RootPart = HRP
		local TCharacter = TargetPlayer.Character
		local THumanoid, TRootPart, THead, Accessory, Handle
		if TCharacter:FindFirstChildOfClass("Humanoid") then
			THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
		end
		if THumanoid and THumanoid.RootPart then
			TRootPart = THumanoid.RootPart
		end
		if TCharacter:FindFirstChild("Head") then
			THead = TCharacter.Head
		end
		if TCharacter:FindFirstChildOfClass("Accessory") then
			Accessory = TCharacter:FindFirstChildOfClass("Accessory")
		end
		if Accessory and Accessory:FindFirstChild("Handle") then
			Handle = Accessory.Handle
		end
		if Character and Humanoid and HRP then
			if not getgenv().OldPos or RootPart.Velocity.Magnitude < 50 then
				getgenv().OldPos = RootPart.CFrame
			end
			if THumanoid and THumanoid.Sit and not AllBool then
			end
			if THead then
				SafeGetService("Workspace").CurrentCamera.CameraSubject = THead
			elseif not THead and Handle then
				SafeGetService("Workspace").CurrentCamera.CameraSubject = Handle
			elseif THumanoid and TRootPart then
				SafeGetService("Workspace").CurrentCamera.CameraSubject = THumanoid
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
				if attachedPart then attachedPart:Destroy() attachedPart=nil end
			end
			SafeGetService("Workspace").FallenPartsDestroyHeight = 0/0
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
			end
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			SafeGetService("Workspace").CurrentCamera.CameraSubject = Humanoid
			repeat
				RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
				Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
				Humanoid:ChangeState("GettingUp")
				Foreach(Character:GetChildren(), function(_, x)
					if x:IsA("BasePart") then
						x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
					end
				end)
				Wait()
			until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
			SafeGetService("Workspace").FallenPartsDestroyHeight = getgenv().FPDH
			attachedPart:Destroy()
		end
	end
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
		end
	end
end, true)

cmd.add({"commitoof", "suicide", "kys"}, {"commitoof (suicide, kys)", "FE dramatic oof sequence"}, function()
	local p = Players.LocalPlayer
	local c = p.Character or p.CharacterAdded:Wait()
	local h = c:FindFirstChildWhichIsA("Humanoid")

	lib.LocalPlayerChat("Okay.. I will do it.", "All")
	Wait(1)
	lib.LocalPlayerChat("I will oof", "All")
	Wait(1)
	lib.LocalPlayerChat("Goodbye.", "All")
	Wait(1)

	local r = getRoot(c)
	h:MoveTo(r.Position + r.CFrame.LookVector * 10)
	h:ChangeState(Enum.HumanoidStateType.Jumping)
	Wait(0.5)
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
		lib.disconnect("timestop_char_"..plr.UserId)
	end
	lib.disconnect("timestop_playeradd")

	for _, plr in pairs(target) do
		local char = getPlrChar(plr)
		if char then
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Anchored = true
				end
			end
		end

		lib.connect("timestop_char_"..plr.UserId, plr.CharacterAdded:Connect(function(char)
			char:WaitForChild("HumanoidRootPart", 3)
			for _, v in pairs(char:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Anchored = true
				end
			end
		end))
	end

	lib.connect("timestop_playeradd", Players.PlayerAdded:Connect(function(plr)
		lib.connect("timestop_char_"..plr.UserId, plr.CharacterAdded:Connect(function(char)
			char:WaitForChild("HumanoidRootPart", 3)
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
		lib.disconnect("timestop_char_"..plr.UserId)
	end
	lib.disconnect("timestop_playeradd")

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

cmd.add({"goto","to","tp","teleport"},{"goto <player/X,Y,Z>","Teleport to the given player or X,Y,Z coordinates"},function(...)
	Username=(...)

	local target=getPlr(Username)
	for _, plr in next, target do
		getRoot(getChar()).CFrame=getPlrHum(plr).RootPart.CFrame
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

cmd.add({"lookat", "stare"}, {"stare <player> (lookat)", "Stare at a player"}, function(...)
	local Username = (...)
	local Target = getPlr(Username)

	for _, plr in next, Target do
		lib.disconnect("stare_direct")

		local lp = Players.LocalPlayer
		if not (lp.Character and getRoot(lp.Character)) then return end
		if not (plr and plr.Character and getRoot(plr.Character)) then return end

		lp.Character.Humanoid.AutoRotate = false

		local function Stare()
			if lp.Character and plr.Character and getRoot(plr.Character) then
				stareFIXER(lp.Character, getRoot(plr.Character).Position)
			elseif not Players:FindFirstChild(plr.Name) then
				lib.disconnect("stare_direct")
			end
		end

		lib.connect("stare_direct", RunService.RenderStepped:Connect(Stare))
	end
end, true)

cmd.add({"unlookat", "unstare"}, {"unstare (unlookat)", "Stops staring"}, function()
	lib.disconnect("stare_direct")
	local char = Players.LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.AutoRotate = true
	end
end)

cmd.add({"starenear", "stareclosest"}, {"starenear (stareclosest)", "Stare at the closest player"}, function()
	lib.disconnect("stare_nearest")

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
	if lp.Character and lp.Character:FindFirstChild("Humanoid") then
		lp.Character.Humanoid.AutoRotate = false
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

	lib.connect("stare_nearest", RunService.RenderStepped:Connect(stare))
end)

cmd.add({"unstarenear", "unstareclosest"}, {"unstarenear (unstareclosest)", "Stop staring at closest player"}, function()
	lib.disconnect("stare_nearest")
	local char = Players.LocalPlayer.Character
	if char and char:FindFirstChild("Humanoid") then
		char.Humanoid.AutoRotate = true
	end
end)

local specGui, currentPlayerIndex = nil, 1

function cleanup()
	lib.disconnect("spectate_char")
	lib.disconnect("spectate_loop")
	lib.disconnect("spectate_leave")

	if specGui then
		specGui:Destroy()
		specGui = nil
	end

	SafeGetService("Workspace").CurrentCamera.CameraSubject = getHum()
end

function spectatePlayer(targetPlayer)
	if not targetPlayer then return end

	lib.disconnect("spectate_char")
	lib.disconnect("spectate_loop")
	lib.disconnect("spectate_leave")

	lib.connect("spectate_char", targetPlayer.CharacterAdded:Connect(function(character)
		repeat Wait() until character:FindFirstChildWhichIsA("Humanoid")
		SafeGetService("Workspace").CurrentCamera.CameraSubject = character:FindFirstChildWhichIsA("Humanoid")
	end))

	lib.connect("spectate_leave", Players.PlayerRemoving:Connect(function(player)
		if player == targetPlayer then
			cleanup()
			DoNotif("Player left - camera reset")
		end
	end))

	local loop = coroutine.create(function()
		while true do
			if targetPlayer.Character and targetPlayer.Character:FindFirstChildWhichIsA("Humanoid") then
				SafeGetService("Workspace").CurrentCamera.CameraSubject = targetPlayer.Character:FindFirstChildWhichIsA("Humanoid")
			end
			Wait()
		end
	end)
	lib.connect("spectate_loop", {
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

function createSpecUI()
	if not specGui then
		specGui = InstanceNew("ScreenGui")
		NaProtectUI(specGui)
		specGui.ResetOnSpawn = false

		local frame = InstanceNew("Frame")
		frame.Size = UDim2.new(0, 350, 0, 40)
		frame.Position = UDim2.new(0.5, -175, 1, -160)
		frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		frame.BorderSizePixel = 0
		frame.Parent = specGui

		local corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 20)
		corner.Parent = frame

		gui.draggablev2(frame)

		local backButton = InstanceNew("TextButton")
		backButton.Size = UDim2.new(0, 40, 0, 40)
		backButton.Position = UDim2.new(0, -18, 0, 0)
		backButton.Text = "<"
		backButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		backButton.Font = Enum.Font.GothamBold
		backButton.TextSize = 24
		backButton.Parent = frame

		local backCorner = InstanceNew("UICorner")
		backCorner.CornerRadius = UDim.new(0, 10)
		backCorner.Parent = backButton

		local forwardButton = InstanceNew("TextButton")
		forwardButton.Size = UDim2.new(0, 40, 0, 40)
		forwardButton.Position = UDim2.new(1, -22, 0, 0)
		forwardButton.Text = ">"
		forwardButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		forwardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		forwardButton.Font = Enum.Font.GothamBold
		forwardButton.TextSize = 24
		forwardButton.Parent = frame

		local forwardCorner = InstanceNew("UICorner")
		forwardCorner.CornerRadius = UDim.new(0, 10)
		forwardCorner.Parent = forwardButton

		local dropdownLabel = InstanceNew("TextLabel")
		dropdownLabel.Size = UDim2.new(0.76, 0, 1, 0)
		dropdownLabel.Position = UDim2.new(0.08, 0, 0, 0)
		dropdownLabel.BackgroundTransparency = 1
		dropdownLabel.Text = "Spectating: None"
		dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		dropdownLabel.Font = Enum.Font.GothamBold
		dropdownLabel.TextScaled = true
		dropdownLabel.Parent = frame

		local dropCorner = InstanceNew("UICorner")
		dropCorner.CornerRadius = UDim.new(0, 10)
		dropCorner.Parent = dropdownLabel

		local closeButton = InstanceNew("TextButton")
		closeButton.Size = UDim2.new(0, 30, 0, 30)
		closeButton.Position = UDim2.new(1, -55, 0, 5)
		closeButton.Text = "X"
		closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeButton.Font = Enum.Font.GothamBold
		closeButton.TextSize = 18
		closeButton.Parent = frame

		local closeCorner = InstanceNew("UICorner")
		closeCorner.CornerRadius = UDim.new(0, 5)
		closeCorner.Parent = closeButton

		MouseButtonFix(closeButton,function()
			cleanup()
		end)

		local toggleDropdownButton = InstanceNew("TextButton")
		toggleDropdownButton.Size = UDim2.new(0, 30, 0, 20)
		toggleDropdownButton.Position = UDim2.new(0.5, -15, 1, 5)
		toggleDropdownButton.Text = "v"
		toggleDropdownButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		toggleDropdownButton.TextColor3 = Color3.new(1, 1, 1)
		toggleDropdownButton.Font = Enum.Font.GothamBold
		toggleDropdownButton.TextSize = 18
		toggleDropdownButton.Parent = frame

		local toggleCorner = InstanceNew("UICorner")
		toggleCorner.CornerRadius = UDim.new(0, 6)
		toggleCorner.Parent = toggleDropdownButton

		local dropdownOpen = false
		local dropdownList

		local function updateSpectating()
			if #playerButtons == 0 then
				dropdownLabel.Text = "Spectating: None"
				return
			end
			local currentPlayer = playerButtons[currentPlayerIndex]
			local nameCheck = nameChecker(currentPlayer)
			dropdownLabel.Text = "Spectating: "..nameCheck
			if currentPlayer == LocalPlayer then
				dropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
			else
				dropdownLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
			end
			spectatePlayer(currentPlayer)

			if dropdownOpen and dropdownList then
				for _, child in pairs(dropdownList:GetChildren()) do
					if child:IsA("TextButton") then
						local idx = child:GetAttribute("PlayerIndex")
						if idx then
							local playerRef = playerButtons[idx]
							if playerRef then
								if playerRef == LocalPlayer then
									child.TextColor3 = Color3.fromRGB(255, 255, 0)
								elseif playerRef == currentPlayer then
									child.TextColor3 = Color3.fromRGB(0, 162, 255)
								else
									child.TextColor3 = Color3.fromRGB(255, 255, 255)
								end
							end
						end
					end
				end
			end
		end

		MouseButtonFix(backButton, function()
			if #playerButtons == 0 then return end
			currentPlayerIndex = currentPlayerIndex - 1
			if currentPlayerIndex < 1 then
				currentPlayerIndex = #playerButtons
			end
			updateSpectating()
		end)

		MouseButtonFix(forwardButton, function()
			if #playerButtons == 0 then return end
			currentPlayerIndex = currentPlayerIndex + 1
			if currentPlayerIndex > #playerButtons then
				currentPlayerIndex = 1
			end
			updateSpectating()
		end)

		MouseButtonFix(toggleDropdownButton,function()
			if dropdownOpen then
				if dropdownList then
					local closeTween = TweenService:Create(dropdownList, TweenInfo.new(0.25), { Size = UDim2.new(1, 0, 0, 0) })
					local moveToggle = TweenService:Create(toggleDropdownButton, TweenInfo.new(0.25), { Position = UDim2.new(0.5, -15, 1, 5) })
					closeTween:Play()
					moveToggle:Play()
					closeTween.Completed:Wait()
					dropdownList:Destroy()
					dropdownList = nil
				end
				toggleDropdownButton.Text = "v"
				dropdownOpen = false
			else
				dropdownList = InstanceNew("ScrollingFrame")
				local totalHeight = #playerButtons * 30
				local listHeight = math.min(totalHeight, 150)
				dropdownList.Size = UDim2.new(1, 0, 0, 0)
				dropdownList.Position = UDim2.new(0, 0, 1, 0)
				dropdownList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				dropdownList.BorderSizePixel = 0
				dropdownList.ScrollBarThickness = 5
				dropdownList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
				dropdownList.ClipsDescendants = true
				dropdownList.Parent = frame

				local listCorner = InstanceNew("UICorner")
				listCorner.CornerRadius = UDim.new(0, 10)
				listCorner.Parent = dropdownList

				local listLayout = InstanceNew("UIListLayout")
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder
				listLayout.Parent = dropdownList

				local openTween = TweenService:Create(dropdownList, TweenInfo.new(0.25), { Size = UDim2.new(1, 0, 0, listHeight) })
				local moveToggle = TweenService:Create(toggleDropdownButton, TweenInfo.new(0.25), { Position = UDim2.new(0.5, -15, 1, listHeight + 10) })

				openTween:Play()
				moveToggle:Play()

				toggleDropdownButton.Text = "^"
				dropdownOpen = true

				for i, player in ipairs(playerButtons) do
					local playerButton = InstanceNew("TextButton")
					playerButton.Size = UDim2.new(1, 0, 0, 30)
					playerButton.LayoutOrder = i
					playerButton.Text = ""
					playerButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					playerButton.Font = Enum.Font.Gotham
					playerButton.TextScaled = true
					playerButton.Parent = dropdownList
					playerButton:SetAttribute("PlayerIndex", i)

					local headshot = InstanceNew("ImageLabel")
					headshot.Size = UDim2.new(0, 30, 0, 30)
					headshot.Position = UDim2.new(0, 0, 0, 0)
					headshot.BackgroundTransparency = 1
					headshot.Parent = playerButton
					local thumbType = Enum.ThumbnailType.HeadShot
					local thumbSize = Enum.ThumbnailSize.Size420x420
					headshot.Image = Players:GetUserThumbnailAsync(player.UserId, thumbType, thumbSize)

					local nameLabel = InstanceNew("TextLabel")
					nameLabel.Size = UDim2.new(1, -35, 1, 0)
					nameLabel.Position = UDim2.new(0, 35, 0, 0)
					nameLabel.BackgroundTransparency = 1
					nameLabel.Text = nameChecker(player)
					nameLabel.Font = Enum.Font.Gotham
					nameLabel.TextScaled = true
					if player == Players.LocalPlayer then
						nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
					elseif playerButtons[currentPlayerIndex] == player then
						nameLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
					else
						nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
					nameLabel.Parent = playerButton

					MouseButtonFix(playerButton,function()
						currentPlayerIndex = i
						updateSpectating()
					end)
				end
			end
		end)

		updateSpectating()
	end
end

cmd.add({"watch2", "view2", "spectate2"}, {"watch2 <Player> (view2, spectate2)", "Spectate player with GUI"}, function()
	cleanup()
	createSpecUI()
end)

cmd.add({"unwatch2", "unview2"}, {"unwatch2 (unview2)", "Stop spectating with GUI"}, function()
	cleanup()
end)

cmd.add({"stealaudio", "getaudio", "steal", "logaudio"}, {"stealaudio <player> (getaudio,logaudio,steal)", "Save all sounds a player is playing to a file -Cyrus"}, function(p)
	Wait()
	local players = getPlr(p)
	for _, plr in next, players do
		if not plr then
			DoNotif("Player not found.")
			return
		end
		local char = plr.Character
		if not char then
			DoNotif("Character not found for player "..nameChecker(plr))
			return
		end
		local audioList = {}
		for _, songer in pairs(char:GetDescendants()) do
			if songer:IsA("Sound") and songer.Playing then
				Insert(audioList, songer.SoundId)
			end
		end
		if #audioList > 0 then
			local audios = Concat(audioList, "\n")
			setclipboard(audios)
			DoNotif("Audio links have been copied to your clipboard.")
		else
			DoNotif("No playing audio found for player "..nameChecker(plr))
		end
	end
end, true)

cmd.add({"follow", "stalk", "walk"}, {"follow <player>", "Follow a player wherever they go"}, function(p)
	lib.disconnect("follow")
	local targetPlayers = getPlr(p)
	for _, plr in next, targetPlayers do
		if not plr then
			DoNotif("Player not found or invalid.")
			return
		end
		lib.connect("follow", RunService.Stepped:Connect(function()
			local target = plr.Character
			local character = getChar()
			if target and character then
				local hum = character:FindFirstChildWhichIsA("Humanoid")
				local targetPart = target:FindFirstChild("Head")
				if hum and targetPart then
					local targetPos = targetPart.Position
					hum:MoveTo(targetPos)
				else
					lib.disconnect("follow")
				end
			else
				lib.disconnect("follow")
			end
		end))
	end
end, true)

cmd.add({"unfollow", "unstalk", "unwalk", "unpathfind"}, {"unfollow", "Stop all attempts to follow a player"}, function()
	lib.disconnect("follow")
end)

PROXIMITY_RADIUS = 15
lastDistances = {}
ISfollowing = false
followTarget = nil
followConnection = nil
flwCharAdd = nil

cmd.add({"autofollow", "autostalk", "proxfollow"}, {"autofollow (autostalk,proxfollow)", "Automatically follow any player who comes close"}, function()
	lib.disconnect("autofollow")
	if followConnection then followConnection:Disconnect() followConnection = nil end
	if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
	lastDistances = {}
	ISfollowing = false
	followTarget = nil

	lib.connect("autofollow", RunService.Stepped:Connect(function()
		if ISfollowing then return end

		local myChar = getChar()
		local myRoot = getRoot(myChar)
		local myHum = myChar and myChar:FindFirstChildWhichIsA("Humanoid")
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
							if not targetRoot then return end

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

							local hum = char:FindFirstChildWhichIsA("Humanoid")
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
	lib.disconnect("autofollow")
	if followConnection then followConnection:Disconnect() followConnection = nil end
	if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
	lastDistances = {}
	ISfollowing = false
	followTarget = nil
end)

cmd.add({"pathfind"}, {"pathfind <player>", "Follow a player using the pathfinder API wherever they go"}, function(p)
	local targetPlayers = getPlr(p)
	for _, plr in next, targetPlayers do
		if not plr then return end
		lib.disconnect("follow")
		local debounce = false
		lib.connect("follow", RunService.Stepped:Connect(function()
			if debounce then return end
			debounce = true
			local target = plr.Character
			local character = getChar()
			if not target or not character then
				debounce = false
				return
			end
			local hum = character:FindFirstChildWhichIsA("Humanoid")
			local main = getRoot(target)
			if hum and main then
				local targetPart = main or target:FindFirstChild("Head")
				local targetPos = (targetPart.CFrame * CFrame.new(0, 0, -0.5)).p
				local PathService = SafeGetService("PathfindingService")
				local path = PathService:CreatePath({
					AgentRadius = 2,
					AgentHeight = 5,
					AgentCanJump = true
				})
				path:ComputeAsync(hum.RootPart.Position, targetPos)
				if path.Status ~= Enum.PathStatus.NoPath then
					local waypoints = path:GetWaypoints()
					for i, waypoint in pairs(waypoints) do
						if waypoint.Action == Enum.PathWaypointAction.Jump then
							hum:ChangeState(Enum.HumanoidStateType.Jumping)
							hum:MoveTo(waypoint.Position)
							hum.MoveToFinished:Wait()
						else
							hum:MoveTo(waypoint.Position)
							hum.MoveToFinished:Wait()
						end
					end
				end
			end
			debounce = false
		end))
	end
end, true)

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

		gui.draggablev2(btn)

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

cmd.add({"blackhole"}, {"blackhole", "Makes unanchored parts teleport to the black hole"}, function()
	local UserInputService = SafeGetService("UserInputService")
	local Mouse = LocalPlayer:GetMouse()
	local Folder = InstanceNew("Folder", SafeGetService("Workspace"))
	local Part = InstanceNew("Part", Folder)
	local Attachment1 = InstanceNew("Attachment", Part)
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	local Updated = Mouse.Hit + Vector3.new(0, 5, 0)

	local NetworkAccess = coroutine.create(function()
		settings().Physics.AllowSleep = false
		while RunService.RenderStepped:Wait() do
			for _, Players in next, SafeGetService("Players"):GetPlayers() do
				if Players ~= LocalPlayer then
					Players.MaximumSimulationRadius = 0
					sethiddenproperty(Players, "SimulationRadius", 0)
				end
			end
			LocalPlayer.MaximumSimulationRadius = math.pow(math.huge, math.huge)
		end
	end)
	coroutine.resume(NetworkAccess)

	local function ForcePart(v)
		if v:IsA("Part") and v.Anchored == false and v.Parent:FindFirstChild("Humanoid") == nil and v.Parent:FindFirstChild("Head") == nil and v.Name ~= "Handle" then
			Mouse.TargetFilter = v
			for _, x in next, v:GetChildren() do
				if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
					x:Destroy()
				end
			end
			if v:FindFirstChild("Attachment") then
				v:FindFirstChild("Attachment"):Destroy()
			end
			if v:FindFirstChild("AlignPosition") then
				v:FindFirstChild("AlignPosition"):Destroy()
			end
			if v:FindFirstChild("Torque") then
				v:FindFirstChild("Torque"):Destroy()
			end
			v.CanCollide = false
			local Torque = InstanceNew("Torque", v)
			Torque.Torque = Vector3.new(100000, 100000, 100000)
			local AlignPosition = InstanceNew("AlignPosition", v)
			local Attachment2 = InstanceNew("Attachment", v)
			Torque.Attachment0 = Attachment2
			AlignPosition.MaxForce = 9999999999999999
			AlignPosition.MaxVelocity = math.huge
			AlignPosition.Responsiveness = 200
			AlignPosition.Attachment0 = Attachment2
			AlignPosition.Attachment1 = Attachment1
		end
	end

	for _, v in next, SafeGetService("Workspace"):GetDescendants() do
		ForcePart(v)
	end

	SafeGetService("Workspace").DescendantAdded:Connect(function(v)
		ForcePart(v)
	end)

	UserInputService.InputBegan:Connect(function(Key, Chat)
		if Key.KeyCode == Enum.KeyCode.E and not Chat and not IsOnMobile then
			Updated = Mouse.Hit + Vector3.new(0, 5, 0)
		end
	end)

	if IsOnMobile then
		local sGUI=InstanceNew("ScreenGui")
		NaProtectUI(sGUI)
		UICorner = InstanceNew("UICorner")
		local button = InstanceNew("TextButton")
		button.Text = "Move Blackhole"
		button.AnchorPoint = Vector2.new(0.5,0)
		button.Size = UDim2.new(0, 150, 0, 40)
		button.Position = UDim2.new(0.5, 0, 0.9, 0)
		button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
		button.TextColor3 = Color3.new(1, 1, 1)
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 18
		button.Parent=sGUI

		UICorner.CornerRadius = UDim.new(0.25, 0)
		UICorner.Parent = button

		MouseButtonFix(button,function()
			Updated = Mouse.Hit + Vector3.new(0, 5, 0)
		end)

		gui.draggablev2(button)
	end

	Spawn(function()
		while RunService.RenderStepped:Wait() do
			Attachment1.WorldCFrame = Updated
		end
	end)

	Wait()

	DoNotif("Blackhole has been loaded, "..(IsOnMobile and "tap the button to move it" or "press E to change the position to where your mouse is"))
end)

cmd.add({"disableanimations","disableanims"},{"disableanimations (disableanims)","Freezes your animations"},function()
	getChar().Animate.Disabled=true
end)

cmd.add({"undisableanimations","undisableanims"},{"undisableanimations (undisableanims)","Unfreezes your animations"},function()
	getChar().Animate.Disabled=false
end)

cmd.add({"hatresize"},{"hatresize","Makes your hats very big r15 only"},function()

	Wait();

	DoNotif("Hat resize loaded, rthro needed")

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
	Loopvoid = true
	repeat Wait()
		local mouse = LocalPlayer:GetMouse()
		local Players = game:GetService("Players")
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
			local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
			local HRP = Humanoid and Humanoid.RootPart
			local camera = SafeGetService("Workspace").CurrentCamera
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
			if TCharacter:FindFirstChildOfClass("Humanoid") then
				THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
			end
			if THumanoid and THumanoid.RootPart then
				TRootPart = THumanoid.RootPart
			end
			if TCharacter:FindFirstChild("Head") then
				THead = TCharacter:FindFirstChild("Head")
			end
			if TCharacter:FindFirstChildOfClass("Accessory") then
				Accessory = TCharacter:FindFirstChildOfClass("Accessory")
			end
			if Accessory and Accessory:FindFirstChild("Handle") then
				Handle = Accessory.Handle
			end
			if Character and Humanoid and HRP then
				if not getgenv().OldPos or RootPart.Velocity.Magnitude < 50 then
					getgenv().OldPos = RootPart.CFrame
				end
				if THumanoid and THumanoid.Sit and not AllBool then
					return
				end
				if THead then
					SafeGetService("Workspace").CurrentCamera.CameraSubject = THead
				elseif not THead and Handle then
					SafeGetService("Workspace").CurrentCamera.CameraSubject = Handle
				elseif THumanoid and TRootPart then
					SafeGetService("Workspace").CurrentCamera.CameraSubject = THumanoid
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
				SafeGetService("Workspace").FallenPartsDestroyHeight = 0/0
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
				SafeGetService("Workspace").CurrentCamera.CameraSubject = Humanoid
				repeat
					RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
					Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
					Humanoid:ChangeState("GettingUp")
					Foreach(Character:GetChildren(), function(_, x)
						if x:IsA("BasePart") then
							x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
						end
					end)
					Wait()
				until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
				SafeGetService("Workspace").FallenPartsDestroyHeight = getgenv().FPDH
				if LOOPPROTECT then LOOPPROTECT:Destroy() LOOPPROTECT = nil end
			else
				return
			end
		end
		if not Welcome then DoNotif("Enjoy!", 5, "Script by AnthonyIsntHere") end
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
	Hook = hookfunction(MarketplaceService.UserOwnsGamePassAsync, newcclosure(function(self, ...)
		return true
	end))

	DoNotif("✅ Free gamepasses enabled! Rejoin to disable. Note: This only works in some games.")
end)

--[[cmd.add({"freedevproduct", "freedp"},{"freedevproduct (freedp)", "Simulates a successful Developer Product purchase"},function()
    hookfunction(MarketplaceService.PromptProductPurchase, newcclosure(function(self, player, productId, ...)
        if player == LocalPlayer then
        DoNotif("✅ Simulated dev product purchase for ProductId: "..tostring(productId))

        local success, err = pcall(function()
                local ReceiptInfo = {
                    PlayerId = player.UserId,
                    ProductId = productId,
                    CurrencySpent = 0,
                    PlaceIdWherePurchased = PlaceId,
                    PurchaseId = HttpService:GenerateGUID(false)
                }

                if typeof(getgenv().ProcessReceipt) == "function" then
                    getgenv().ProcessReceipt(ReceiptInfo)
                elseif typeof(getgenv().ProcessReceipt) == "function" then
                    getgenv().ProcessReceipt(ReceiptInfo)
                end
            end)

            if not success then
                warn("⚠️ Could not simulate ProcessReceipt: "..tostring(err))
            end
        end
        return
    end))

    DoNotif("🟢 Fake dev product purchase enabled! Use in games with local handlers.")
end)]]

cmd.add({"listen"}, {"listen <player>", "Listen to your target's voice chat"}, function(plr)
	local trg = getPlr(plr)

	for _, plr in next, trg do
		local Root = getRoot(plr.Character)
		if Root then
			SoundService:SetListener(Enum.ListenerType.ObjectPosition, Root)
		end
	end
end,true)

cmd.add({"unlisten"}, {"unlisten", "Stops listening"}, function()
	SoundService:SetListener(Enum.ListenerType.Camera)
end)

cmd.add({"lockmouse", "lockm"}, {"lockmouse (lockm)", "Locks your mouse in the center"}, function()
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end)

cmd.add({"unlockmouse", "unlockm"}, {"unlockmouse (unlockm)", "Unlocks your mouse"}, function()
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
end)

if IsOnPC then
	cmd.add({"lockmouse2", "lockm2"}, {"lockmouse2 (lockm2)", "Locks your mouse in the center (first person)"}, function()
		gui.doModal(false)
	end)
	cmd.add({"unlockmouse2", "unlockm2"}, {"unlockmouse2 (unlockm2)", "Unlocks your mouse (fr this time)"}, function()
		gui.doModal(true)
	end)
end

--[[cmd.add({"chattag", "ctags", "chatt", "tag"}, {"chattag (ctags, chatt, tag)", "gives you a chat tag (visually)"}, function(...)
	if not LegacyChat then return DoNotif("this doesn't work with Legacy Chat System please use it on a game that uses the new Chat System",5) end
	local tag = Concat({...}, " ")
	LocalPlayer:SetAttribute("CustomNAtagger", tag)
end, true)]]

platformParts = {}

cmd.add({"headsit"}, {"headsit <player>", "sit on someone's head"}, function(p)
	local ppp = getPlr(p)

	for _, plr in next, ppp do
		if not plr then return end

		local char = getChar()
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return end

		lib.disconnect("headsit_follow")
		lib.disconnect("headsit_died")

		local charRoot = getRoot(char)
		local target = plr.Character
		if not charRoot or not target then return end

		hum.Sit = true

		lib.connect("headsit_died", hum.Died:Connect(function()
			lib.disconnect("headsit_follow")
			lib.disconnect("headsit_died")
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
			part.Parent = SafeGetService("Workspace").CurrentCamera
			Insert(platformParts, part)
		end

		lib.connect("headsit_follow", RunService.Heartbeat:Connect(function()
			if not SafeGetService("Players"):FindFirstChild(plr.Name)
				or not plr.Character
				or not plr.Character:FindFirstChild("Head")
				or hum.Sit == false then

				lib.disconnect("headsit_follow")
				lib.disconnect("headsit_died")

				for _, part in pairs(platformParts) do
					part:Destroy()
				end
				platformParts = {}
			else
				local targetHead = plr.Character:FindFirstChild("Head")
				charRoot.CFrame = targetHead.CFrame * CFrame.new(0, 1.6, 0.4)

				for i, wall in ipairs(walls) do
					platformParts[i].CFrame = charRoot.CFrame * wall.offset
				end
			end
		end))
	end
end, true)

cmd.add({"unheadsit"}, {"unheadsit", "Stop the headsit command."}, function()
	lib.disconnect("headsit_follow")
	lib.disconnect("headsit_died")

	for _, part in pairs(platformParts) do
		part:Destroy()
	end
	platformParts = {}

	local char = getChar()
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

cmd.add({"wallhop"},{"wallhop","wallhop helper"},function()
	local char = getChar()
	local root = getRoot(char)
	local hum = char:FindFirstChildOfClass("Humanoid")

	lib.disconnect("wallhop_loop")

	local canHop = true

	lib.connect("wallhop_loop", RunService.Heartbeat:Connect(function()
		if not char or not root or not hum or hum.Health <= 0 then
			lib.disconnect("wallhop_loop")
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
	lib.disconnect("wallhop_loop")
end)

cmd.add({"jump"},{"jump","jump."},function()
	getHum():ChangeState(Enum.HumanoidStateType.Jumping)
end)

cmd.add({"loopjump", "bhop"}, {"loopjump (bhop)", "Continuously jump."}, function()
	lib.disconnect("loopjump")

	lib.connect("loopjump", RunService.Heartbeat:Connect(function()
		local h = getHum()
		if h and h:GetState() ~= Enum.HumanoidStateType.Freefall then
			h:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end))
end)

cmd.add({"unloopjump", "unbhop"}, {"unloopjump (unbhop)", "Stop continuous jumping."}, function()
	lib.disconnect("loopjump")
end)

standParts = {}

cmd.add({"headstand"}, {"headstand <player>", "Stand on someone's head."}, function(p)
	lib.disconnect("headstand_follow")
	lib.disconnect("headstand_died")

	local targets = getPlr(p)
	if #targets == 0 then return end

	local plr = targets[1]
	local char = getChar()
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	lib.connect("headstand_died", hum.Died:Connect(function()
		lib.disconnect("headstand_follow")
		lib.disconnect("headstand_died")
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
		part.Parent = SafeGetService("Workspace").CurrentCamera
		Insert(standParts, part)
	end

	lib.connect("headstand_follow", RunService.Heartbeat:Connect(function()
		local plrCharacter = plr.Character
		if Players:FindFirstChild(plr.Name) and plrCharacter and getRoot(plrCharacter) and getRoot(char) then
			local charRoot = getRoot(char)
			charRoot.CFrame = getRoot(plrCharacter).CFrame * CFrame.new(0, 4.6, 0.4)
			for i, wall in ipairs(walls) do
				standParts[i].CFrame = charRoot.CFrame * wall.offset
			end
		else
			lib.disconnect("headstand_follow")
			lib.disconnect("headstand_died")
			for _, part in pairs(standParts) do
				part:Destroy()
			end
			standParts = {}
		end
	end))
end, true)

cmd.add({"unheadstand"}, {"unheadstand", "Stop the headstand command."}, function()
	lib.disconnect("headstand_follow")
	lib.disconnect("headstand_died")

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

	lib.disconnect("loopws_apply")
	lib.disconnect("loopws_char")

	local function getHum()
		local char = LocalPlayer and LocalPlayer.Character
		return char and char:FindFirstChildOfClass("Humanoid")
	end

	local function applyWS()
		local hum = getHum()
		if hum then
			hum.WalkSpeed = val
			lib.connect("loopws_apply", hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if loopws and hum.WalkSpeed ~= val then
					hum.WalkSpeed = val
				end
			end))
		end
	end

	applyWS()

	lib.connect("loopws_char", LocalPlayer.CharacterAdded:Connect(function()
		repeat Wait() until getHum()
		if loopws then applyWS() end
	end))
end, true)

cmd.add({"unloopwalkspeed", "unloopws", "unlws"}, {"unloopwalkspeed (unloopws,unlws)", "Disable loop walkspeed"}, function()
	loopws = false
	lib.disconnect("loopws_apply")
	lib.disconnect("loopws_char")
end)

getgenv().NamelessJP = nil
local loopjp = false

cmd.add({"loopjumppower", "loopjp", "ljp"}, {"loopjumppower <number> (loopjp,ljp)", "Loop JumpPower"}, function(...)
	local val = tonumber(...) or 50
	getgenv().NamelessJP = val
	loopjp = true

	lib.disconnect("loopjp_apply")
	lib.disconnect("loopjp_char")

	local function getHum()
		local char = LocalPlayer and LocalPlayer.Character
		return char and char:FindFirstChildOfClass("Humanoid")
	end

	local function applyJP()
		local hum = getHum()
		if not hum then return end

		if hum.UseJumpPower then
			hum.JumpPower = val
			lib.connect("loopjp_apply", hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
				if loopjp and hum.JumpPower ~= val then
					hum.JumpPower = val
				end
			end))
		else
			hum.JumpHeight = val
			lib.connect("loopjp_apply", hum:GetPropertyChangedSignal("JumpHeight"):Connect(function()
				if loopjp and hum.JumpHeight ~= val then
					hum.JumpHeight = val
				end
			end))
		end
	end

	applyJP()

	lib.connect("loopjp_char", LocalPlayer.CharacterAdded:Connect(function()
		repeat Wait() until getHum()
		if loopjp then applyJP() end
	end))
end, true)

cmd.add({"unloopjumppower", "unloopjp", "unljp"}, {"unloopjumppower (unloopjp,unljp)", "Disable loop jump power"}, function()
	loopjp = false
	lib.disconnect("loopjp_apply")
	lib.disconnect("loopjp_char")
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
			if char:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R15 then
				waveAnim.AnimationId = "rbxassetid://507770239"
			else
				waveAnim.AnimationId = "rbxassetid://128777973"
			end
			getRoot(char).CFrame = targetCFrame * CFrame.new(0, 0, -3)
			local charPos = char.PrimaryPart.Position
			local tpos = getRoot(plr.Character).Position
			local newCFrame = CFrame.new(charPos, Vector3.new(tpos.X, charPos.Y, tpos.Z))
			Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCFrame)
			local wave = char:FindFirstChildOfClass("Humanoid"):LoadAnimation(waveAnim)
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
	DoNotif("Copied tools from ReplicatedStorage and Lighting", 3)
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

		local head = char:FindFirstChild("Head")
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
			if not plr.Parent or not plr.Character or not head:IsDescendantOf(SafeGetService("Workspace")) then
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

cmd.add({"toolview2", "tview2"}, {"toolview2 (tview2)", "Live-updating tool viewer"}, function()
	if renderConn then renderConn:Disconnect() end
	if playerAddConn then playerAddConn:Disconnect() end
	if playerRemoveConn then playerRemoveConn:Disconnect() end
	for _, c in pairs(toolConnections) do pcall(function() c:Disconnect() end) end
	toolConnections = {}

	local old = guiCHECKINGAHHHHH():FindFirstChild("ToolViewGui")
	if old then old:Destroy() end

	local ui = InstanceNew("ScreenGui")
	NaProtectUI(ui)
	ui.Name = "ToolViewGui"
	ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

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
	main.Parent = ui
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
		for _, c in pairs(toolConnections) do pcall(function() c:Disconnect() end) end
		ui:Destroy()
	end)

	gui.draggable(main,topbar)
end)

cmd.add({"waveat", "wat"}, {"waveat <player> (wat)", "Wave to a player"}, function(...)
	local playerName = (...)
	local targets = getPlr(playerName)
	if #targets == 0 then return end
	local plr = targets[1]
	local char = getChar()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
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
	local humanoid = getChar():FindFirstChildOfClass("Humanoid")
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
		part.Parent = SafeGetService("Workspace").CurrentCamera
		Insert(bangParts, part)
	end
	local bangOffset = CFrame.new(0, 1, -1.1)
	bangLoop = RunService.Stepped:Connect(function()
		pcall(function()
			local targetCharacter = Players[bangplr].Character
			if targetCharacter then
				local otherHead = targetCharacter:FindFirstChild("Head")
				local localRoot = getRoot(getChar())
				if otherHead and localRoot then
					localRoot.CFrame = otherHead.CFrame * bangOffset
				end
				local charPos = getChar().PrimaryPart.Position
				local targetRoot = getRoot(plr.Character)
				if targetRoot then
					local newCFrame = CFrame.new(charPos, Vector3.new(targetRoot.Position.X, charPos.Y, targetRoot.Position.Z))
					Players.LocalPlayer.Character:SetPrimaryPartCFrame(newCFrame)
				end
				for i, wall in ipairs(walls) do
					bangParts[i].CFrame = localRoot.CFrame * wall.offset
				end
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

	local humanoid = char:FindFirstChildOfClass("Humanoid")
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
		part.Parent = SafeGetService("Workspace").CurrentCamera
		Insert(jerkParts, part)
	end

	local jerkOffset = CFrame.new(0, -2.5, -0.25) * CFrame.Angles(math.pi * 0.5, 0, math.pi)
	jerkLoop = RunService.Stepped:Connect(function()
		pcall(function()
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
	local root = char and getRoot(char)
	if root then
		root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
	end

	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
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

cmd.add({"suck", "dicksuck"}, {"suck <player> <number> (dicksuck)", "suck it"}, function(h, d)
	if suckLOOP then
		suckLOOP = nil
	end
	if doSUCKING then
		doSUCKING:Stop()
	end
	if suckANIM then
		suckANIM:Destroy()
	end
	if suckDIED then
		suckDIED:Disconnect()
	end
	for _, p in pairs(SUCKYSUCKY) do
		p:Destroy()
	end
	SUCKYSUCKY = {}

	local speed = d or 10
	local tweenDuration = 1 / speed
	local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local username = h
	local targets = getPlr(username)
	if #targets == 0 then return end
	local plr = targets[1]

	suckANIM = InstanceNew("Animation")
	local isR15 = IsR15(Players.LocalPlayer)
	if not isR15 then
		suckANIM.AnimationId = "rbxassetid://189854234"
	else
		suckANIM.AnimationId = "rbxassetid://5918726674"
	end
	local hum = getChar():FindFirstChildOfClass("Humanoid")
	doSUCKING = hum:LoadAnimation(suckANIM)
	doSUCKING:Play(0.1, 1, 1)
	doSUCKING:AdjustSpeed(speed)

	suckDIED = hum.Died:Connect(function()
		if suckLOOP then
			suckLOOP = nil
		end
		doSUCKING:Stop()
		suckANIM:Destroy()
		if suckDIED then
			suckDIED:Disconnect()
		end
		for _, part in pairs(SUCKYSUCKY) do
			part:Destroy()
		end
		SUCKYSUCKY = {}
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
		part.Parent = SafeGetService("Workspace").CurrentCamera
		Insert(SUCKYSUCKY, part)
	end

	suckLOOP = coroutine.wrap(function()
		while true do
			local targetCharacter = plr.Character
			local localCharacter = getChar()
			if targetCharacter and getRoot(targetCharacter) and localCharacter and getRoot(localCharacter) then
				local targetHRP = getRoot(targetCharacter)
				local localHRP = getRoot(localCharacter)
				local forwardCFrame = targetHRP.CFrame * CFrame.new(0, -2.3, -2.5) * CFrame.Angles(0, math.pi, 0)
				local backwardCFrame = targetHRP.CFrame * CFrame.new(0, -2.3, -1.3) * CFrame.Angles(0, math.pi, 0)
				local tweenForward = TweenService:Create(
					localHRP,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{CFrame = forwardCFrame}
				)
				tweenForward:Play()
				tweenForward.Completed:Wait()
				local tweenBackward = TweenService:Create(
					localHRP,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{CFrame = backwardCFrame}
				)
				tweenBackward:Play()
				tweenBackward.Completed:Wait()
				for i, wall in ipairs(walls) do
					SUCKYSUCKY[i].CFrame = localHRP.CFrame * wall.offset
				end
			else
				break
			end
		end
	end)
	suckLOOP()
end, true)

cmd.add({"unsuck", "undicksuck"}, {"unsuck (undicksuck)", "no more fun"}, function()
	if suckLOOP then
		suckLOOP = nil
	end
	if doSUCKING then
		doSUCKING:Stop()
	end
	if suckANIM then
		suckANIM:Destroy()
	end
	if suckDIED then
		suckDIED:Disconnect()
	end
	for _, p in pairs(SUCKYSUCKY) do
		p:Destroy()
	end
	SUCKYSUCKY = {}
end)

cmd.add({"improvetextures"},{"improvetextures","Switches Textures"},function()
	sethidden(SafeGetService("MaterialService"), "Use2022Materials", true)
end)

cmd.add({"undotextures"},{"undotextures","Switches Textures"},function()
	sethidden(SafeGetService("MaterialService"), "Use2022Materials", false)
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
	local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
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
	HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgeJump)
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(newChar)
		Char = newChar
		Human = newChar:WaitForChild("Humanoid")
		edgeJump()
		HumanModCons.ejLoop = (HumanModCons.ejLoop and HumanModCons.ejLoop:Disconnect() and false) or RunService.RenderStepped:Connect(edgeJump)
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
	local hum = getChar():FindFirstChildOfClass("Humanoid")
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
		part.Parent = SafeGetService("Workspace").CurrentCamera
		Insert(BANGPARTS, part)
	end

	local bangOffset = CFrame.new(0, 0, 1.1)
	bangLoop = RunService.Stepped:Connect(function()
		pcall(function()
			local targetRoot = getRoot(Players[bangplr].Character)
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

cmd.add({"inversebang", "ibang", "inverseb"}, {"inversebang <player> <number> (inversebang/inverseb)", "you're the one getting fucked today ;)"},function(h, d)
	if inversebangLoop then
		inversebangLoop = nil
	end
	if doInversebang then
		doInversebang:Stop()
	end
	if inversebangAnim then
		inversebangAnim:Destroy()
	end
	if inversebangAnim2 then
		inversebangAnim2:Destroy()
	end
	if inversebangDied then
		inversebangDied:Disconnect()
	end
	for _, p in pairs(INVERSEBANGPARTS) do
		p:Destroy()
	end
	INVERSEBANGPARTS = {}

	local speed = d or 10
	local username = h
	local targets = getPlr(username)
	if #targets == 0 then return end
	local plr = targets[1]

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
	local hum = getChar():FindFirstChildOfClass("Humanoid")
	doInversebang = hum:LoadAnimation(inversebangAnim)
	doInversebang:Play(0.1, 1, 1)
	doInversebang:AdjustSpeed(speed)
	if not isR15 and inversebangAnim2 then
		doInversebang2 = hum:LoadAnimation(inversebangAnim2)
		doInversebang2:Play(0.1, 1, 1)
		doInversebang2:AdjustSpeed(speed)
	end

	inversebangDied = hum.Died:Connect(function()
		if inversebangLoop then
			inversebangLoop = nil
		end
		doInversebang:Stop()
		if doInversebang2 then
			doInversebang2:Stop()
		end
		inversebangAnim:Destroy()
		if inversebangDied then
			inversebangDied:Disconnect()
		end
		for _, part in pairs(INVERSEBANGPARTS) do
			part:Destroy()
		end
		INVERSEBANGPARTS = {}
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
		part.Parent = SafeGetService("Workspace").CurrentCamera
		Insert(INVERSEBANGPARTS, part)
	end

	local bangOffset = CFrame.new(0, 0, 1.1)

	inversebangLoop = coroutine.wrap(function()
		while true do
			local targetCharacter = plr.Character
			local localCharacter = getChar()
			if targetCharacter and getRoot(targetCharacter) and localCharacter and getRoot(localCharacter) then
				local targetHRP = getRoot(targetCharacter)
				local localHRP = getRoot(localCharacter)
				local forwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, -2.5)
				local backwardCFrame = targetHRP.CFrame * CFrame.new(0, 0, -1.3)
				local tweenForward = TweenService:Create(
					localHRP,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{CFrame = forwardCFrame}
				)
				tweenForward:Play()
				tweenForward.Completed:Wait()
				local tweenBackward = TweenService:Create(
					localHRP,
					TweenInfo.new(0.15, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{CFrame = backwardCFrame}
				)
				tweenBackward:Play()
				tweenBackward.Completed:Wait()
				for i, wall in ipairs(walls) do
					INVERSEBANGPARTS[i].CFrame = localHRP.CFrame * wall.offset
				end
			else
				break
			end
		end
	end)
	inversebangLoop()
end, true)

cmd.add({"uninversebang", "unibang", "uninverseb"}, {"uninversebang (unibang)", "no more fun"}, function()
	if inversebangLoop then
		inversebangLoop = nil
	end
	if doInversebang then
		doInversebang:Stop()
	end
	if doInversebang2 then
		doInversebang2:Stop()
	end
	if inversebangAnim then
		inversebangAnim:Destroy()
	end
	if inversebangDied then
		inversebangDied:Disconnect()
	end
	for _, p in pairs(INVERSEBANGPARTS) do
		p:Destroy()
	end
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
	local humanoid = getChar():FindFirstChildWhichIsA("Humanoid")
	local backpack = LocalPlayer:FindFirstChildWhichIsA("Backpack")
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

		lib.disconnect("hug_toggle")
		lib.disconnect("hug_side")
		lib.disconnect("hug_click")
		lib.disconnect("hug_plat")

		for _, track in pairs(currentHugTracks) do pcall(function() track:Stop() end) end
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

		gui.draggablev2(toggleHugButton)
		gui.draggablev2(sideToggleButton)

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
					table.insert(currentHugTracks, track1)
					table.insert(currentHugTracks, track2)
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
							part.Parent = SafeGetService("Workspace").CurrentCamera
							table.insert(huggiePARTS, part)
						end
						lib.connect("hug_plat", RunService.Heartbeat:Connect(function()
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

		lib.connect("hug_toggle", MouseButtonFix(toggleHugButton, function()
			hugModeEnabled = not hugModeEnabled
			if hugModeEnabled then
				toggleHugButton.Text = "Hug Mode: ON"
			else
				toggleHugButton.Text = "Hug Mode: OFF"
				for _, track in pairs(currentHugTracks) do pcall(function() track:Stop() end) end
				currentHugTracks = {}
				currentHugTarget = nil
				for _, part in pairs(huggiePARTS) do part:Destroy() end
				huggiePARTS = {}
				lib.disconnect("hug_plat")
			end
		end))

		lib.connect("hug_side", MouseButtonFix(sideToggleButton, function()
			hugFromFront = not hugFromFront
			sideToggleButton.Text = (hugFromFront and "Hug Side: Front") or "Hug Side: Back"
		end))

		lib.connect("hug_click", LocalPlayer:GetMouse().Button1Down:Connect(function()
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
	lib.disconnect("hug_toggle")
	lib.disconnect("hug_side")
	lib.disconnect("hug_click")
	lib.disconnect("hug_plat")

	for _, track in pairs(currentHugTracks) do pcall(function() track:Stop() end) end
	currentHugTracks = {}
	currentHugTarget = nil
	hugFromFront = false
	hugModeEnabled = false
	for _, part in pairs(huggiePARTS) do part:Destroy() end
	huggiePARTS = {}
	if hugUI then hugUI:Destroy() hugUI = nil end
end)

glueloop = {}

cmd.add({"glue", "loopgoto", "lgoto"}, {"glue <player> (loopgoto,lgoto)", "Loop teleport to a player"}, function(...)
	local user = (...)
	local targets = getPlr(user)
	for _, plr in next, targets do
		if glueloop[plr] then
			glueloop[plr]:Disconnect()
			glueloop[plr] = nil
		end
		glueloop[plr] = RunService.RenderStepped:Connect(function()
			local char = plr.Character
			if char then
				local targetRoot = getRoot(char)
				local localRoot = getRoot(getChar())
				if targetRoot and localRoot then
					localRoot.CFrame = targetRoot.CFrame
				end
			end
		end)
	end
end, true)

cmd.add({"unglue", "unloopgoto", "noloopgoto"}, {"unglue (unloopgoto,noloopgoto)", "Stops teleporting you to a player"}, function()
	for _, connection in pairs(glueloop) do
		connection:Disconnect()
	end
	glueloop = {}
end)

glueBACKER = {}

cmd.add({"glueback", "loopbehind", "lbehind"}, {"glueback <player> (loopbehind,lbehind)", "Loop teleport behind a player"}, function(...)
	local input = (...)
	local players = getPlr(input)
	for _, target in next, players do
		if glueBACKER[target] then
			glueBACKER[target]:Disconnect()
			glueBACKER[target] = nil
		end
		glueBACKER[target] = RunService.RenderStepped:Connect(function()
			local targetChar = target.Character
			if targetChar then
				local targetRoot = getRoot(targetChar)
				local localRoot = getRoot(getChar())
				if targetRoot and localRoot then
					local cf = targetRoot.CFrame * CFrame.new(0, 0, 3)
					localRoot.CFrame = CFrame.new(cf.Position, targetRoot.Position)
				end
			end
		end)
	end
end, true)

cmd.add({"unglueback", "unloopbehind", "unlbehind"}, {"unglueback (unloopbehind,unlbehind)", "Stops teleporting you to a player"}, function()
	for _, conn in pairs(glueBACKER) do
		conn:Disconnect()
	end
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
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
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

cmd.add({"loopspook", "loopscare"}, {"loopspook <player> (loopscare)", "Teleports next to a player repeatedly"}, function(...)
	local t = getPlr(...)
	loopspook = true

	Spawn(function()
		while loopspook do
			for _, p in ipairs(t) do
				local lc = getChar()
				local lr = getRoot(lc)
				if p.Character and p.Character:FindFirstChild("Humanoid") then
					local tr = getRoot(p.Character)
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
end, true)

cmd.add({"unloopspook", "unloopscare"}, {"unloopspook (unloopscare)", "Stops the loopspook command"}, function()
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
	DoNotif(IsOnMobile and "Airwalk: ON" or "Airwalk: ON (Q And E)")
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
		gui.draggablev2(button)

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

	awPart = InstanceNew("Part", SafeGetService("Workspace"))
	awPart.Size = Vector3.new(7, 2, 3)
	awPart.CFrame = getRoot(getChar()).CFrame - Vector3.new(0, 4, 0)
	awPart.Transparency = 1
	awPart.Anchored = true
	airwalk.Y = getRoot(getChar()).CFrame.y

	Airwalker = RunService.RenderStepped:Connect(function()
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
	DoNotif("Airwalk: OFF")
end)

bringc = {}

cmd.add({"cbring", "clientbring"}, {"clientbring <player> (cbring)", "Brings the player on your client"}, function(...)
	local username = (...)
	local target = getPlr(username)
	if #target == 0 then return end
	if lib.isConnected("noclip") then
		lib.disconnect("noclip")
	end
	for _, conn in ipairs(bringc) do
		conn:Disconnect()
	end
	bringc = {}
	lib.connect("noclip", RunService.Stepped:Connect(function()
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
	if lib.isConnected("noclip") then
		lib.disconnect("noclip")
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
		lib.disconnect("TPWalkingConnection")
	end

	TPWalk = true
	local Speed = ...

	lib.connect("TPWalkingConnection", RunService.Stepped:Connect(function(_, deltaTime)
		if TPWalk then
			local humanoid = getChar():FindFirstChildWhichIsA("Humanoid")
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
	lib.disconnect("TPWalkingConnection")
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
			DoNotif("Loopmuted "..p.Name)
		else
			DoNotif(p.Name.." already loopmuted")
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
			DoNotif("Unloopmuted "..p.Name)
		else
			DoNotif(p.Name.." not loopmuted")
		end
	end
end, true)

cmd.add({"getmass"},{"getmass <player>","Get your mass"},function(...)
	target=getPlr(...)
	for _, plr in next, target do
		local mass=getRoot(plr.Character).AssemblyMass
		Wait();

		DoNotif(nameChecker(plr).."'s mass is "..mass)
	end
end,true)

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
	SafeGetService("Workspace"):FindFirstChildOfClass('Terrain'):Clear()
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
		GuiService:CloseInspectMenu()
		GuiService:InspectPlayerFromUserId(plr.UserId)
	end
end, true)

function nuhuhprompt(v)
	pcall(function()
		for _, o in COREGUI:GetChildren() do
			if o:IsA("GuiBase") and o.Name:lower():find("purchaseprompt") then
				o.Enabled = v
			end
		end
	end)
end

cmd.add({"noprompt","nopurchaseprompts","noprompts"},{"noprompt (nopurchaseprompts,noprompts)","remove the stupid purchase prompt"},function()
	nuhuhprompt(false)
	DoNotif("Purchase prompts have been disabled")
end)

cmd.add({"prompt","purchaseprompts","showprompts","showpurchaseprompts"},{"prompt (purchaseprompts,showprompts,showpurchaseprompts)","allows the stupid purchase prompt"},function()
	nuhuhprompt(true)
	DoNotif("Purchase prompts have been enabled")
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
	spinPart.Parent = SafeGetService("Workspace").CurrentCamera
	spinPart.CFrame = getRoot(LocalPlayer.Character).CFrame

	spinThingy = InstanceNew("BodyAngularVelocity")
	spinThingy.Parent = spinPart
	spinThingy.MaxTorque = Vector3.new(0, math.huge, 0)
	spinThingy.AngularVelocity = Vector3.new(0, spinSpeed, 0)

	local weld = InstanceNew("WeldConstraint")
	weld.Part0 = spinPart
	weld.Part1 = getRoot(LocalPlayer.Character)
	weld.Parent = spinPart

	DoNotif("Spinning...")
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

	DoNotif("Spin Disabled", 3)
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
	SafeGetService("Workspace").Gravity=(...)
end,true)

cmd.add({"fireclickdetectors","fcd","firecd"},{"fireclickdetectors (fcd,firecd)","Fires every click detector that's in workspace"},function()
	local ccamount=0
	for _,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:IsA("ClickDetector") then
			ccamount=ccamount+1
			fireclickdetector(v)
		end
	end

	Wait();

	DoNotif("Fired "..ccamount.." amount of click detectors")
end)

cmd.add({"noclickdetectorlimits","nocdlimits","removecdlimits"},{"noclickdetectorlimits <limit> (nocdlimits,removecdlimits)","Sets all click detectors MaxActivationDistance to math.huge"},function(...)
	for i,v in ipairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:IsA("ClickDetector") then
			if (...) == nil then
				v.MaxActivationDistance=math.huge
			else
				v.MaxActivationDistance=(...)
			end
		end
	end
end,true)

cmd.add({"noproximitypromptlimits","nopplimits","removepplimits"},{"noproximitypromptlimits <limit> (nopplimits,removepplimits)","Sets all proximity prompts MaxActivationDistance to math.huge"},function(...)
	for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			if (...) == nil then
				v.MaxActivationDistance=math.huge
			else
				v.MaxActivationDistance=(...)
			end
		end
	end
end,true)

cmd.add({"instantproximityprompts","instantpp","ipp"},{"instantproximityprompts (instantpp,ipp)","Disable the cooldown for proximity prompts"},function()
	lib.disconnect("instantpp")
	lib.connect("instantpp", ProximityPromptService.PromptButtonHoldBegan:Connect(function(pp)
		fireproximityprompt(pp, 1)
	end))
end)

cmd.add({"uninstantproximityprompts","uninstantpp","unipp"},{"uninstantproximityprompts (uninstantpp,unipp)","Undo the cooldown removal"},function()
	lib.disconnect("instantpp")
end)

cmd.add({"r6"},{"r6","Shows a prompt that will switch your character rig type into R6"},function()
	AvatarEditorService:PromptSaveAvatar(getPlrHum(LocalPlayer).HumanoidDescription,Enum.HumanoidRigType.R6)
	AvatarEditorService.PromptSaveAvatarCompleted:Wait()
	Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
	Player.Character:FindFirstChildOfClass("Humanoid").Health=0
end)

cmd.add({"r15"},{"r15","Shows a prompt that will switch your character rig type into R15"},function()
	AvatarEditorService:PromptSaveAvatar(getPlrHum(LocalPlayer).HumanoidDescription,Enum.HumanoidRigType.R15)
	AvatarEditorService.PromptSaveAvatarCompleted:Wait()
	Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
	Player.Character:FindFirstChildOfClass("Humanoid").Health=0
end)

cmd.add({"maxslopeangle", "msa"}, {"maxslopeangle (msa)", "Changes your character's MaxSlopeAngle"}, function(...)
	local args = {...}
	local amount = tonumber(args[1]) or 89

	local humanoid = getHum()
	if humanoid and humanoid:IsA("Humanoid") then
		humanoid.MaxSlopeAngle = amount
		DoNotif(Format("Set MaxSlopeAngle to %s", tostring(amount)), 2)
	else
		DoNotif("Humanoid not found or invalid.", 2)
	end
end,true)

cmd.add({"godmode", "god"}, {"godmode (god)", "Toggles invincibility"}, function()
	local humanoid = getHum()
	if humanoid then
		lib.disconnect("godmode")

		lib.connect("godmode", humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if humanoid.Health ~= humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end))

		humanoid.Health = humanoid.MaxHealth
		DoNotif("Godmode ON", 2)
	else
		DoNotif("Humanoid not found", 2)
	end
end)

cmd.add({"ungodmode", "ungod"}, {"ungodmode (ungod)", "Disables invincibility"}, function()
	lib.disconnect("godmode")
	DoNotif("Godmode OFF", 2)
end)

cmd.add({"controllock", "ctrllock"}, {"controllock (ctrllock)", "Sets your Shiftlock keybinds to the control keys"}, function()
	local player = Players.LocalPlayer
	local mouseLockController = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:WaitForChild("BoundKeys")

	boundKeys.Value = "LeftControl,RightControl"

	DoNotif("Set your Shiftlock keybinds to Ctrl")
end)

cmd.add({"resetlock"}, {"resetlock", "Resets your Shiftlock keybinds to default (LeftShift)"}, function()
	local player = LocalPlayer
	local mouseLockController = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	local boundKeys = mouseLockController:WaitForChild("BoundKeys")

	boundKeys.Value = "LeftShift,RightShift"

	DoNotif("Reset your Shiftlock keybinds to Shift")
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
				DoNotif(Format("Reported %s", nameChecker(player)).." | "..Format("Reason - %s", reason))

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

cmd.add({"light"}, {"light <range> <brightness>", "Gives your player dynamic light"}, function(range, brightness)
	range = tonumber(range) or 30
	brightness = tonumber(brightness) or 1

	local light = InstanceNew("PointLight")
	light.Parent = getRoot(Player.Character)
	light.Range = range
	light.Brightness = brightness
end, true)

cmd.add({"unlight", "nolight"}, {"unlight (nolight)", "Removes dynamic light from your player"}, function()
	for _, descendant in pairs(Player.Character:GetDescendants()) do
		if descendant:IsA("PointLight") then
			descendant:Destroy()
		end
	end
end)

cmd.add({"lighting", "lightingcontrol"}, {"lighting (lightingcontrol)", "Manage lighting technology settings"}, function()
	local lightingButtons = {}
	for _, lightingType in ipairs(Enum.Technology:GetEnumItems()) do
		Insert(lightingButtons, {
			Text = lightingType.Name,
			Callback = function()
				Lighting.Technology = lightingType
			end
		})
	end

	Insert(lightingButtons, {
		Text = "Cancel",
		Callback = function() end
	})

	Notify({
		Title = "Lighting Technology Options",
		Buttons = lightingButtons
	})
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
		local camera=SafeGetService("Workspace").CurrentCamera
		local cameraPosition=camera.CFrame.Position

		local tween=TweenService:Create(character.PrimaryPart,TweenInfo.new(2),{
			CFrame=CFrame.new(cameraPosition)
		})

		tween:Play()
	end


	local camera=SafeGetService("Workspace").CurrentCamera
	repeat Wait() until camera.CFrame~=CFrame.new()

	teleportPlayer()

end)

cmd.add({"delete", "remove", "del"}, {"delete {partname} (remove, del)", "Removes any part with a certain name from the workspace"}, function(...)
	local deleteCount = 0
	local args = {...}
	local targetName = Concat(args, " ")

	for _, d in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if d.Name:lower() == targetName:lower() then
			d:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()

	if deleteCount > 0 then
		DoNotif("Deleted "..deleteCount.." instance(s) of '"..targetName.."'", 2.5)
	else
		DoNotif("'"..targetName.."' not found to delete", 2.5)
	end
end, true)

cmd.add({"deletefind", "removefind", "delfind"}, {"deletefind {partname} (removefind, delfind)", "Removes any part with a name containing the given text from the workspace"}, function(...)
	local deFind = 0
	local targetName = Concat({...}, " "):lower()

	for _, d in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if d.Name:lower():find(targetName) then
			d:Destroy()
			deFind = deFind + 1
		end
	end

	Wait()

	if deFind > 0 then
		DoNotif("Deleted "..deFind.." instance(s) containing '"..targetName.."'", 2.5)
	else
		DoNotif("No instances found containing '"..targetName.."'", 2.5)
	end
end, true)

cmd.add({"deletelighting", "removelighting", "removel", "ldel"},{"deletelighting (removelighting, removel, ldel)","Removes all descendants (objects) within Lighting."},function()
	for _, l in ipairs(Lighting:GetDescendants()) do
		l:Destroy()
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
		for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if part.Name:lower() == targetName then
				part:Destroy()
			end
		end
	end

	if not autoRemoveConnection then
		autoRemoveConnection = SafeGetService("Workspace").DescendantAdded:Connect(handleDescendantAdd)
	end

	Wait()
	DoNotif("Auto deleting instances with name: "..targetName, 2.5)
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
		for _, obj in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if obj.Name:lower():find(kw) then
				obj:Destroy()
			end
		end
	end

	if not finderConn then
		finderConn = SafeGetService("Workspace").DescendantAdded:Connect(onAdd)
	end

	Wait()
	DoNotif("Auto deleting parts containing: "..kw, 2.5)
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

	for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if part.ClassName:lower() == targetClass then
			part:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()
	if deleteCount > 0 then
		DoNotif("Deleted "..deleteCount.." instance(s) of class: "..targetClass, 2.5)
	else
		DoNotif("No instances of class: "..targetClass.." found to delete", 2.5)
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
		for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if part.ClassName:lower() == targetClass then
				part:Destroy()
			end
		end
	end

	if not autoClassConnection then
		autoClassConnection = SafeGetService("Workspace").DescendantAdded:Connect(handleClassDescendantAdd)
	end

	Wait()
	DoNotif("Auto deleting instances with class: "..targetClass, 2.5)
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
		DoNotif("Deleted "..deleteCount.." instance(s) of '"..targetName.."' inside the character", 2.5)
	else
		DoNotif("'"..targetName.."' not found in the character", 2.5)
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
		DoNotif("Deleted "..count.." instance(s) containing '"..kw.."' in character", 2.5)
	else
		DoNotif("Nothing found containing '"..kw.."' in character", 2.5)
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
		DoNotif("Deleted "..deleteCount.." instance(s) of class: "..targetClass.." inside the character", 2.5)
	else
		DoNotif("No instances of class: "..targetClass.." found in the character", 2.5)
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
		for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if not taskState.active then return end
			if part:IsA("BasePart") and part.Name:lower() == partName then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then getChar():PivotTo(part:GetPivot()) end
				Wait(.2)
			end
		end
	end)
end, true)

cmd.add({"tweengotopart", "tgotopart", "ttopart", "ttoprt"}, {"tweengotopart {partname}", "Tweens you to each matching part by name once"}, function(...)
	local partName = Concat({...}, " "):lower()
	local commandKey = "tweengotopart"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if not taskState.active then return end
			if part:IsA("BasePart") and part.Name:lower() == partName then
				if getHum() then getHum().Sit = false Wait(0.1) end
				local tween = TweenService:Create(getRoot(getChar()), TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = part.CFrame})
				tween:Play()
				Wait(1.1)
			end
		end
	end)
end, true)


cmd.add({"gotopartfind", "topartfind", "toprtfind"}, {"gotopartfind {name}", "Teleports to each part containing name once"}, function(...)
	local name = Concat({...}, " "):lower()
	local commandKey = "gotopartfind"

	if activeTeleports[commandKey] then
		activeTeleports[commandKey].active = false
	end

	local taskState = {active = true}
	activeTeleports[commandKey] = taskState

	Spawn(function()
		for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
		for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
		for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
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

	for _, part in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if part:IsA("BasePart") and part.Name:lower() == partName then
			if getChar() then
				part:PivotTo(getChar():GetPivot())
			end
		end
	end
end, true)

cmd.add({"bringmodel", "bmodel"}, {"bringmodel {modelname} (bmodel)", "Brings a model to your character by name"}, function(...)
	local modelName = Concat({...}, " "):lower()

	for _, model in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
		for _, model in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
		for _, model in pairs(SafeGetService("Workspace"):GetDescendants()) do
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

	for _, model in pairs(SafeGetService("Workspace"):GetDescendants()) do
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

OGGRAVV = SafeGetService("Workspace").Gravity
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

		OGGRAVV = SafeGetService("Workspace").Gravity
		SafeGetService("Workspace").Gravity = 0

		ZEhumSTATE(humanoid, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		humanoid.WalkSpeed = speed or 16

		lib.connect("swim_die", humanoid.Died:Connect(function()
			SafeGetService("Workspace").Gravity = OGGRAVV
			SWIMMERRRR = false
		end))

		lib.connect("swim_heartbeat", RunService.Heartbeat:Connect(function()
			pcall(function()
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
		SafeGetService("Workspace").Gravity = OGGRAVV
		SWIMMERRRR = false

		lib.disconnect("swim_die")
		lib.disconnect("swim_heartbeat")

		ZEhumSTATE(humanoid, true)
		humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
		humanoid.WalkSpeed = 16
	end
end)

cmd.add({"tpua", "bringua"}, {"tpua <player> (bringua)", "brings every unanchored part on the map"}, function(target)
	local targetPlayer = getPlr(target)
	if not targetPlayer or not getPlrChar(targetPlayer) or not getRoot(getPlrChar(targetPlayer)) then return end
	local targetCF = getRoot(getPlrChar(targetPlayer)).CFrame

	Spawn(function()
		while true do
			RunService.Heartbeat:Wait()
			sethiddenproperty(LocalPlayer, "SimulationRadius", 1e9)
			LocalPlayer.MaximumSimulationRadius = 1e9
		end
	end)

	for _, v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(targetPlayer.Character) then
			v.CFrame = targetCF * CFrame.new(math.random(-10,10), 0, math.random(-10,10))
		end
	end
end,true)

cmd.add({"swordfighter", "sfighter", "swordf", "swordbot", "sf"},{"swordfighter (sfighter, swordf, swordbot, sf)", "Activates a sword fighting bot that engages in automated PvP combat"},function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Sword%20Fight%20Bot"))()
end)

local espList = {}
touchESPList = {}
proximityESPList = {}
clickESPList = {}
local partTrigger = nil
local espTriggers = {}

function createBox(part, color, transparency)
	local box = InstanceNew("BoxHandleAdornment")
	box.Name = part.Name:lower().."_PEEPEE"
	box.Parent = part
	box.Adornee = part
	box.AlwaysOnTop = true
	box.ZIndex = 0
	if part:IsA("BasePart") then
		box.Size = part.Size
	elseif part:FindFirstChildWhichIsA("BasePart") then
		box.Size = part:FindFirstChildWhichIsA("BasePart").Size
	else
		box.Size = Vector3.new(4, 4, 4)
	end

	box.Transparency = transparency or 0.45
	box.Color3 = color
	return box
end

function onPartAdded(part)
	if #espList > 0 then
		if Discover(espList, part.Name:lower()) then
			if part:IsA("BasePart") or part:IsA("Model") then
				createBox(part, Color3.fromRGB(50, 205, 50), 0.45)
			end
		end
	else
		if partTrigger then
			partTrigger:Disconnect()
			partTrigger = nil
		end
	end
end

function enableEsp(objType, color, list)
	for _, obj in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if obj:IsA(objType) then
			local parent = obj.Parent
			if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
				if not Discover(list, parent) then
					Insert(list, parent)
					createBox(parent, color, 0.45)
				end
			end
		end
	end

	if not espTriggers[objType] then
		espTriggers[objType] = SafeGetService("Workspace").DescendantAdded:Connect(function(obj)
			if obj:IsA(objType) then
				local parent = obj.Parent
				if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
					if not Discover(list, parent) then
						Insert(list, parent)
						createBox(parent, color, 0.45)
					end
				end
			end
		end)
	end
end

function disableEsp(objType, list)
	if espTriggers[objType] then
		espTriggers[objType]:Disconnect()
		espTriggers[objType] = nil
	end

	for _, obj in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if obj:IsA("BoxHandleAdornment") and obj.Name:sub(-7) == "_PEEPEE" then
			local adornee = obj.Adornee
			if adornee and Discover(list, adornee) then
				obj:Destroy()
			end
		end
	end

	table.clear(list)
end

cmd.add({"pesp", "esppart", "partesp"}, {"pesp {partname} (esppart, partesp)", "Highlights specific parts by name"}, function(...)
	local args = {...}
	local partName = Concat(args, " "):lower()

	if not Discover(espList, partName) then
		Insert(espList, partName)

		for _, obj in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if obj.Name:lower() == partName then
				if obj:IsA("BasePart") or obj:IsA("Model") then
					createBox(obj, Color3.fromRGB(50, 205, 50), 0.45)
				end
			end
		end
	end

	if not partTrigger then
		partTrigger = SafeGetService("Workspace").DescendantAdded:Connect(onPartAdded)
	end
end, true)

cmd.add({"pespfind", "partespfind", "esppartfind"}, {"pespfind {partname} (partespfind, esppartfind)", "Highlights parts that partially match the name"}, function(...)
	local args = {...}
	local partName = Concat(args, " "):lower()

	if not Discover(espList, partName) then
		Insert(espList, partName)

		for _, obj in pairs(SafeGetService("Workspace"):GetDescendants()) do
			if obj.Name:lower():find(partName) then
				if obj:IsA("BasePart") or obj:IsA("Model") then
					createBox(obj, Color3.fromRGB(50, 205, 50), 0.45)
				end
			end
		end
	end

	if not partTrigger then
		partTrigger = SafeGetService("Workspace").DescendantAdded:Connect(function(part)
			if #espList > 0 then
				for _, name in ipairs(espList) do
					if part.Name:lower():find(name) then
						if part:IsA("BasePart") or part:IsA("Model") then
							createBox(part, Color3.fromRGB(50, 205, 50), 0.45)
						end
					end
				end
			end
		end)
	end
end, true)

cmd.add({"unpesp", "unesppart", "unpartesp"}, {"unpesp (unesppart, unpartesp)", "Removes ESP from specific parts added by pesp"}, function()
	for _, obj in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if obj:IsA("BoxHandleAdornment") and obj.Name:sub(-7) == "_PEEPEE" then
			local adornee = obj.Adornee
			if adornee then
				for _, name in ipairs(espList) do
					if adornee.Name:lower():find(name) then
						obj:Destroy()
						break
					end
				end
			end
		end
	end

	espList = {}

	if partTrigger then
		partTrigger:Disconnect()
		partTrigger = nil
	end
end)

cmd.add({"touchesp", "tesp"}, {"touchesp (tesp)", "Highlights parts with TouchTransmitter"}, function()
	enableEsp("TouchTransmitter", Color3.fromRGB(255, 0, 0), touchESPList)
end)

cmd.add({"untouchesp", "untesp"}, {"untouchesp (untesp)", "Removes ESP from parts with TouchTransmitter"}, function()
	disableEsp("TouchTransmitter", touchESPList)
end)

cmd.add({"proximityesp", "prxesp", "proxiesp"}, {"proximityesp (prxesp, proxiesp)", "Highlights parts with ProximityPrompt"}, function()
	enableEsp("ProximityPrompt", Color3.fromRGB(0, 0, 255), proximityESPList)
end)

cmd.add({"unproximityesp", "unprxesp", "unproxiesp"}, {"unproximityesp (unprxesp, unproxiesp)", "Removes ESP from parts with ProximityPrompt"}, function()
	disableEsp("ProximityPrompt", proximityESPList)
end)

cmd.add({"clickesp", "cesp"}, {"clickesp (cesp)", "Highlights parts with ClickDetector"}, function()
	enableEsp("ClickDetector", Color3.fromRGB(255, 165, 0), clickESPList)
end)

cmd.add({"unclickesp", "uncesp"}, {"unclickesp (uncesp)", "Removes ESP from parts with ClickDetector"}, function()
	disableEsp("ClickDetector", clickESPList)
end)

cmd.add({"viewpart", "viewp", "vpart"}, {"viewpart {partName} (viewp, vpart)", "Focuses camera on a part, model, or folder"},function(...)
	local partName = Concat({...}, " "):lower()
	local ws = SafeGetService("Workspace")
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

	DoNotif("No matching part, model, or folder with a BasePart found named '"..partName.."'")
end,true)

cmd.add({"unviewpart", "unviewp"}, {"unviewpart (unviewp)", "Resets the camera to the local humanoid"}, function()
	local camera = SafeGetService("Workspace").CurrentCamera
	local humanoid = getHum()
	if humanoid then
		camera.CameraSubject = humanoid
	end
end)

cmd.add({"viewpartfind", "viewpfind", "vpartfind"}, {"viewpartfind {name} (viewpfind, vpartfind)", "Focuses camera on a part, model, or folder with name containing the given text"}, function(...)
	local name = Concat({...}, " "):lower()
	local ws = SafeGetService("Workspace")
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

	DoNotif("No part, model, or folder containing '"..name.."' with a BasePart found")
end, true)

cmd.add({"unviewpart", "unviewp"}, {"unviewpart (unviewp)", "Resets the camera to the local humanoid"}, function()
	local cam = SafeGetService("Workspace").CurrentCamera
	local hum = getHum()
	if hum then
		cam.CameraSubject = hum
	end
end)

cmd.add({"console", "debug"},{"console (debug)","Opens developer console"},function()
	--StarterGui:SetCore("DevConsoleVisible",true)
	gui.consoleeee()
end)

local ogSIZES = {}
local hbCON = {}

cmd.add({"hitbox", "hbox"}, {"hitbox {amount}", "Modifies everyone's hitbox to the specified size"}, function(playerName, size)
	local targetPlayers = getPlr(playerName)
	local hitboxSize = tonumber(size) or 10

	for _, plr in pairs(targetPlayers) do
		local character = getPlrChar(plr)
		local root = character and getRoot(character)
		if root then
			if not ogSIZES[plr] then
				ogSIZES[plr] = root.Size
			end

			root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
			root.Transparency = 0.9
			root.BrickColor = BrickColor.new("Really black")
			root.Material = Enum.Material.Neon

			if hbCON[plr] then
				hbCON[plr]:Disconnect()
			end

			hbCON[plr] = RunService.Stepped:Connect(function()
				local r = getPlrChar(plr) and getRoot(getPlrChar(plr))
				if r then
					r.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
					r.Transparency = 0.9
					r.BrickColor = BrickColor.new("Really black")
					r.Material = Enum.Material.Neon
				end
			end)
		end
	end
end, true)

cmd.add({"unhitbox", "unhbox"}, {"unhitbox", "Disables hitbox modifications"}, function(playerName)
	local targetPlayers = getPlr(playerName)

	for _, plr in pairs(targetPlayers) do
		local character = getPlrChar(plr)
		local root = character and getRoot(character)
		if root then
			local original = ogSIZES[plr] or Vector3.new(2, 2, 1)
			root.Size = original
			root.Transparency = 1
			root.BrickColor = BrickColor.new("Really black")
			root.Material = Enum.Material.Neon
		end

		if hbCON[plr] then
			hbCON[plr]:Disconnect()
			hbCON[plr] = nil
		end

		ogSIZES[plr] = nil
	end
end,true)

cmd.add({"breakcars", "bcars"}, {"breakcars (bcars)", "Breaks any car"}, function()
	DoNotif("Car breaker loaded, sit on a vehicle and be the driver")

	local Player = Players.LocalPlayer
	local Mouse = Player:GetMouse()
	local RunService = RunService
	local UserInputService = UserInputService

	local Folder = InstanceNew("Folder")
	Folder.Parent = SafeGetService("Workspace")

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
					sethiddenproperty(player, "SimulationRadius", 0)
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
		if parent:FindFirstChildOfClass("Humanoid") or parent:FindFirstChild("Head") then return end

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

	for _, descendant in ipairs(SafeGetService("Workspace"):GetDescendants()) do
		applyForceToPart(descendant)
	end

	SafeGetService("Workspace").DescendantAdded:Connect(applyForceToPart)

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

cmd.add({"firetouchinterests", "fti"}, {"firetouchinterests (fti)", "Fires every Touch Interest that's in workspace"}, function()
	local char = getChar()
	local root = char and getRoot(char)

	local count = 0
	local toucher = {}

	for _, des in ipairs(SafeGetService("Workspace"):GetDescendants()) do
		if des:IsA("TouchTransmitter") then
			local pp = des.Parent
			if pp and pp:IsA("BasePart") then
				Insert(toucher, pp)
				count = count + 1
			end
		end
	end

	for _, part in ipairs(toucher) do
		coroutine.wrap(function()
			local originalCFrame = part.CFrame
			part.CFrame = root.CFrame

			firetouchinterest(root, part, 0)
			Wait()
			firetouchinterest(root, part, 1)

			Delay(0.1, function()
				part.CFrame = originalCFrame
			end)
		end)()
	end

	Wait()
	DoNotif("Fired "..count.." touch interests")
end)

cmd.add({"infjump", "infinitejump"}, {"infjump (infinitejump)", "Enables infinite jumping"}, function()
	Wait()
	DoNotif("Infinite Jump Enabled", 2)

	local function getHumanoid()
		local character = plr.Character or plr.CharacterAdded:Wait()
		return character:WaitForChild("Humanoid")
	end

	local function doINFJUMPY()
		lib.disconnect("infjump_jump")

		local debounce = false
		local humanoid = getHumanoid()

		lib.connect("infjump_jump", UserInputService.JumpRequest:Connect(function()
			if not debounce and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				debounce = true
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

				Delay(0.25, function()
					debounce = false
				end)
			end
		end))
	end

	doINFJUMPY()

	lib.disconnect("infjump_char")
	lib.connect("infjump_char", plr.CharacterAdded:Connect(function(char)
		char:WaitForChild("Humanoid")
		doINFJUMPY()
	end))
end)

cmd.add({"uninfjump", "uninfinitejump"}, {"uninfjump (uninfinitejump)", "Disables infinite jumping"}, function()
	Wait()
	DoNotif("Infinite Jump Disabled", 2)

	lib.disconnect("infjump_jump")
	lib.disconnect("infjump_char")
end)

cmd.add({"flyjump"},{"flyjump","Allows you to hold space to fly up"},function()
	Wait()
	DoNotif("FlyJump Enabled", 3)

	lib.disconnect("flyjump")
	lib.connect("flyjump", UserInputService.JumpRequest:Connect(function()
		Player.Character:FindFirstChildWhichIsA("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
	end))
end)

cmd.add({"unflyjump","noflyjump"},{"unflyjump (noflyjump)","Disables flyjump"},function()
	Wait()
	DoNotif("FlyJump Disabled", 3)

	lib.disconnect("flyjump")
end)

cmd.add({"xray","xrayon"},{"xray (xrayon)","Makes you be able to see through walls"},function()
	Wait();

	DoNotif("Xray enabled")
	xxRAYYYY(true)
end)

cmd.add({"unxray","xrayoff"},{"unxray (xrayoff)","Makes you not be able to see through walls"},function()
	Wait();

	DoNotif("Xray disabled")
	xxRAYYYY(false)
end)

cmd.add({"pastebinscraper","pastebinscrape"},{"pastebinscraper (pastebinscrape)","Scrapes paste bin posts"},function()
	Wait();

	loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/trash(paste)bin%20scrapper"))()
	COREGUI.Scraper["Pastebin Scraper"].BackgroundTransparency=0.5
	COREGUI.Scraper["Pastebin Scraper"].TextButton.Text="             ⭐ Pastebin Post Scraper ⭐"
	COREGUI.Scraper["Pastebin Scraper"].Content.Search.PlaceholderText="Search for a post here..."
	COREGUI.Scraper["Pastebin Scraper"].Content.Search.BackgroundTransparency=0.4
	DoNotif("Pastebin scraper loaded")
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
	lib.disconnect("loopday")

	Lighting.ClockTime = 14

	lib.connect("loopday", Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		if Lighting.ClockTime ~= 14 then
			Lighting.ClockTime = 14
		end
	end))
end)

cmd.add({"unloopday", "unlday"}, {"unloopday (unlday)", "No more sunshine"}, function()
	lib.disconnect("loopday")
end)

cmd.add({"loopfullbright", "loopfb", "lfb"}, {"loopfullbright (loopfb,lfb)", "Sunshiiiine!"}, function()
	lib.disconnect("fbCon")
	lib.disconnect("fbCon1")
	lib.disconnect("fbCon2")
	lib.disconnect("fbCon3")
	lib.disconnect("fbCon4")

	Lighting.Brightness = 1
	Lighting.ClockTime = 12
	Lighting.FogEnd = 786543
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)

	lib.connect("fbCon", Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
		if Lighting.Brightness ~= 1 then
			Lighting.Brightness = 1
		end
	end))
	lib.connect("fbCon1", Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		if Lighting.ClockTime ~= 12 then
			Lighting.ClockTime = 12
		end
	end))
	lib.connect("fbCon2", Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
		if Lighting.FogEnd ~= 786543 then
			Lighting.FogEnd = 786543
		end
	end))
	lib.connect("fbCon3", Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
		if Lighting.GlobalShadows ~= false then
			Lighting.GlobalShadows = false
		end
	end))
	lib.connect("fbCon4", Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
		if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) then
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		end
	end))
end)

cmd.add({"unloopfullbright", "unloopfb", "unlfb"}, {"unloopfullbright (unloopfb,unlfb)", "No more sunshine"}, function()
	lib.disconnect("fbCon")
	lib.disconnect("fbCon1")
	lib.disconnect("fbCon2")
	lib.disconnect("fbCon3")
	lib.disconnect("fbCon4")
end)

cmd.add({"loopnight", "loopn", "ln"}, {"loopnight (loopn,ln)", "Moonlight."}, function()
	lib.disconnect("nightCon")
	lib.disconnect("nightCon1")
	lib.disconnect("nightCon2")
	lib.disconnect("nightCon3")
	lib.disconnect("nightCon4")

	Lighting.Brightness = 1
	Lighting.ClockTime = 0
	Lighting.FogEnd = 786543
	Lighting.GlobalShadows = false
	Lighting.Ambient = Color3.fromRGB(178, 178, 178)

	lib.connect("nightCon", Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
		if Lighting.Brightness ~= 1 then
			Lighting.Brightness = 1
		end
	end))
	lib.connect("nightCon1", Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
		if Lighting.ClockTime ~= 0 then
			Lighting.ClockTime = 0
		end
	end))
	lib.connect("nightCon2", Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
		if Lighting.FogEnd ~= 786543 then
			Lighting.FogEnd = 786543
		end
	end))
	lib.connect("nightCon3", Lighting:GetPropertyChangedSignal("GlobalShadows"):Connect(function()
		if Lighting.GlobalShadows ~= false then
			Lighting.GlobalShadows = false
		end
	end))
	lib.connect("nightCon4", Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
		if Lighting.Ambient ~= Color3.fromRGB(178, 178, 178) then
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		end
	end))
end)

cmd.add({"unloopnight", "unloopn", "unln"}, {"unloopnight (unloopn,unln)", "No more moonlight."}, function()
	lib.disconnect("nightCon")
	lib.disconnect("nightCon1")
	lib.disconnect("nightCon2")
	lib.disconnect("nightCon3")
	lib.disconnect("nightCon4")
end)

cmd.add({"loopnofog","lnofog","lnf", "loopnf"},{"loopnofog (lnofog,lnf,loopnf)","See clearly forever!"},function()
	local Lighting = Lighting

	lib.disconnect("nofog_con")
	lib.disconnect("nofog_loop")

	Lighting.FogEnd = 786543

	function fogFunc()
		for i, v in pairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") then
				v:Destroy()
			end
		end
	end

	lib.connect("nofog_con", Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
		if Lighting.FogEnd ~= 786543 then
			Lighting.FogEnd = 786543
		end
	end))

	lib.connect("nofog_loop", RunService.RenderStepped:Connect(fogFunc))
end)

cmd.add({"unloopnofog","unlnofog","unlnf","unloopnf"},{"unloopnofog (unlnofog,unlnf,unloopnf)","No more sight."},function()
	lib.disconnect("nofog_con")
	lib.disconnect("nofog_loop")
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

cmd.add({"fireproximityprompts","fpp","firepp"},{"fireproximityprompts (fpp,firepp)","Fires every Proximity Prompt that's in workspace"},function()
	fppamount=0
	for i,v in pairs(SafeGetService("Workspace"):GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			fppamount=fppamount+1
			fireproximityprompt(v,1)
		end
	end


	Wait();

	DoNotif("Fired "..fppamount.." of proximity prompts")
end)

cmd.add({"gamma", "exposure"},{"gamma (exposure)","gamma vision (real)"},function(num)
	expose = tonumber(num) or 0
	Lighting.ExposureCompensation = expose
end,true)

cmd.add({"loopgamma", "loopexposure"},{"loopgamma (loopexposure)","loop gamma vision (mega real)"},function(num)
	expose = tonumber(num) or 0
	lib.disconnect("loopgamma")

	Lighting.ExposureCompensation = expose

	lib.connect("loopgamma", Lighting:GetPropertyChangedSignal("ExposureCompensation"):Connect(function()
		if Lighting.ExposureCompensation ~= expose then
			Lighting.ExposureCompensation = expose
		end
	end))
end, true)

cmd.add({"unloopgamma", "unlgamma", "unloopexposure", "unlexposure"},{"unloopgamma (unlgamma, unloopexposure, unlexposure)","stop gamma vision (real)"},function()
	lib.disconnect("loopgamma")
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
		pcall(function()
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
	local camera = SafeGetService("Workspace").CurrentCamera

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
		if lib.isConnected("ilovesolara") then lib.disconnect("ilovesolara") player.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Zoom return end
		lib.connect("ilovesolara",player:GetPropertyChangedSignal("DevCameraOcclusionMode"):Connect(function()
			if player.DevCameraOcclusionMode~=Enum.DevCameraOcclusionMode.Invisicam then
				player.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Invisicam
			end
		end))
		player.DevCameraOcclusionMode=Enum.DevCameraOcclusionMode.Invisicam
	end
end)

cmd.add({"uncameranoclip","uncamnoclip","uncnoclip","unnccam"},{"uncameranoclip (uncamnoclip,uncnoclip,unnccam)","Restores normal camera"}, function()
	local player = Players.LocalPlayer
	local camera = SafeGetService("Workspace").CurrentCamera

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
		lib.disconnect("ilovesolara")
		LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
	end
end)

cmd.add({"oganims"},{"oganims","Old animations from 2007"},function()
	Wait();
	DoNotif("OG animations set")
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
	HH = getChar().Humanoid.HipHeight

	function setDisplayDistance(distance)
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") then
				player.Character:FindFirstChildWhichIsA("Humanoid").NameDisplayDistance = distance
				player.Character:FindFirstChildWhichIsA("Humanoid").HealthDisplayDistance = distance
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

			handle = InstanceNew("Part", SafeGetService("Workspace"))
			handle.Name = "Handle"
			handle.Transparency = 1
			handle.CanCollide = false
			handle.Size = Vector3.new(2, 1, 1)

			weld = InstanceNew("Weld", handle)
			weld.Part0 = handle
			weld.Part1 = getRoot(getChar())
			weld.C0 = CFrame.new(0, offset - 1.5, 0)

			setDisplayDistance(offset + 100)
			SafeGetService("Workspace").CurrentCamera.CameraSubject = handle
			getRoot(getChar()).CFrame = getRoot(getChar()).CFrame * CFrame.new(0, offset, 0)
			getChar().Humanoid.HipHeight = offset
			getChar().Humanoid:ChangeState(11)

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
			SafeGetService("Workspace").CurrentCamera.CameraSubject = getChar().Humanoid
			getRoot(getChar()).CFrame = getRoot(getChar()).CFrame * CFrame.new(0, -offset, 0)
			getChar().Humanoid.HipHeight = HH

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

			for _, track in pairs(getChar().Humanoid:GetPlayingAnimationTracks()) do
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

cmd.add({"invisible", "invis"}, {"invisible (invis)", "Sets invisibility to scare people or something"}, function()
	if invisKeybindConnection then return DoNotif("invis is already loaded bruh") end -- most stupidest check ever lmao
	local UIS = UserInputService
	local Player = Players.LocalPlayer
	local Character = Player.Character or Player.CharacterAdded:Wait()
	Character.Archivable = true
	OriginalPosition = getRoot(Character).CFrame

	local function TurnVisible()
		if not IsInvis then return end
		IsInvis = false
		OriginalPosition = getRoot(InvisibleCharacter).CFrame
		if invisKeybindConnection then
			invisKeybindConnection:Disconnect()
			invisKeybindConnection = nil
		end
		if invisBtnlol then
			invisBtnlol:Destroy()
			invisBtnlol = nil
		end
		if InvisibleCharacter then
			InvisibleCharacter:Destroy()
			InvisibleCharacter = nil
		end
		Player.Character = Character
		getRoot(Player.Character).CFrame=OriginalPosition
		Character.Parent = SafeGetService("Workspace")
		DoNotif("Invisibility has been turned off.")
		StarterGui:SetCore("ResetButtonCallback", true)
	end

	local function ToggleInvisibility()
		if not IsInvis then
			IsInvis = true
			InvisibleCharacter = Character:Clone()
			InvisibleCharacter.Parent = SafeGetService("Workspace")
			for _, v in pairs(InvisibleCharacter:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = v.Name:lower() == "humanoidrootpart" and 1 or 0.5
				end
			end
			local root = getRoot(Character)
			if root then
				OriginalPosition = root.CFrame
				root.CFrame = CFrame.new(0, math.pi*1000000, 0)
			end
			Wait(0.1)
			Character.Parent = Lighting
			if OriginalPosition then
				local invisRoot = getRoot(InvisibleCharacter)
				if invisRoot then
					invisRoot.CFrame = OriginalPosition
				end
			end
			Player.Character = InvisibleCharacter
			SafeGetService("Workspace").CurrentCamera.CameraSubject = InvisibleCharacter:FindFirstChildWhichIsA("Humanoid")
			DoNotif("You are now invisible.")
			StarterGui:SetCore("ResetButtonCallback", false)
		else
			TurnVisible()
		end
	end

	invisKeybindConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == InvisBindLol and not gameProcessed then
			ToggleInvisibility()
		end
	end)

	local humanoid = Character:FindFirstChild("Humanoid")
	if humanoid then
		humanoid.Died:Connect(function()
			TurnVisible()
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

		TextButton.Parent = invisBtnlol
		TextButton.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
		TextButton.BackgroundTransparency = 0.14
		TextButton.Position = UDim2.new(0.9, 0, 0.8, 0)
		TextButton.Size = UDim2.new(0.1, 0, 0.1, 0)
		TextButton.Font = Enum.Font.SourceSansBold
		TextButton.Text = "Invisible"
		TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextButton.TextSize = 15
		TextButton.TextWrapped = true
		TextButton.Active = true
		TextButton.TextScaled = true

		UICorner.Parent = TextButton
		UIAspectRatioConstraint.Parent = TextButton
		UIAspectRatioConstraint.AspectRatio = 1.0

		gui.draggablev2(TextButton)

		MouseButtonFix(TextButton,function()
			ToggleInvisibility()
			TextButton.Text = IsInvis and "Visible" or "Invisible"
		end)
	end

	Wait()
	DoNotif("Invisible loaded, press "..InvisBindLol.Name.." to toggle or use the mobile button.")
end)

cmd.add({"invisbind", "invisiblebind","bindinvis"}, {"invisbind (invisiblebind, bindinvis)", "set a custom keybind for the 'Invisible' command"}, function(...)
	local args = {...}
	if args[1] then
		InvisBindLol = Enum.KeyCode[args[1]] or Enum.KeyCode[args[1]:upper()]
		if InvisBindLol then
			DoNotif("Invis bind set to "..InvisBindLol.Name)
		else
			DoNotif("Invalid keybind, defaulting to E")
			InvisBindLol = Enum.KeyCode.E
		end
	else
		DoNotif("No keybind provided")
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
		DoNotif("Fired "..remoteCount.." remotes\nFailed: "..failedCount.." remotes")
	end)
end)

cmd.add({"keepna"}, {"keepna", "keep executing "..adminName.." every time you teleport"}, function()
	NAQoTEnabled=true
	if FileSupport then
		writefile(NAQOTPATH, "true")
		DoNotif(adminName.." will now auto-load after teleport (QueueOnTeleport enabled)")
	end
end)

cmd.add({"unkeepna"}, {"unkeepna", "Stop executing "..adminName.." every time you teleport"}, function()
	NAQoTEnabled=false
	if FileSupport then
		writefile(NAQOTPATH, "false")
		if not NAQoTEnabled then
			DoNotif("QueueOnTeleport has been disabled. "..adminName.." will no longer auto-run after teleport")
		end
	end
end)

cmd.add({"prediction", "predict"}, {"prediction (predict)", "prompts command prediction if you spelled it wrong"}, function()
	doPREDICTION=true
	DoNotif("predictions enabled",2)
	if FileSupport then
		writefile(NAPREDICTIONPATH, "true")
	end
end)

cmd.add({"unprediction", "unpredict"}, {"unprediction (unpredict)", "disable command predictions"}, function()
	doPREDICTION=false
	DoNotif("predictions disabled",2)
	if FileSupport then
		writefile(NAPREDICTIONPATH, "false")
	end
end)

loopedFOV = nil

cmd.add({"fov"}, {"fov <number>", "Sets your FOV to a custom value (1–120)"}, function(num)
	local field = math.clamp(tonumber(num) or 70, 1, 120)
	local cam = SafeGetService("Workspace").CurrentCamera
	TweenService:Create(cam, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {FieldOfView = field}):Play()
end, true)

cmd.add({"loopfov", "lfov"}, {"loopfov <number> (lfov)", "Loops your FOV to stay at a custom value (1–120)"}, function(num)
	loopedFOV = math.clamp(tonumber(num) or 70, 1, 120)

	local function apply()
		lib.disconnect("fov_loop")
		lib.disconnect("fov_refresh")

		local cam = SafeGetService("Workspace").CurrentCamera
		if not cam then return end

		lib.connect("fov_loop", RunService.RenderStepped:Connect(function()
			if cam.FieldOfView ~= loopedFOV then
				cam.FieldOfView = loopedFOV
			end
		end))

		lib.connect("fov_refresh", cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
			if cam.FieldOfView ~= loopedFOV then
				cam.FieldOfView = loopedFOV
			end
		end))
	end

	lib.disconnect("fov_watch")
	lib.connect("fov_watch", SafeGetService("Workspace"):GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Wait(0.05)
		apply()
	end))

	apply()
end, true)

cmd.add({"unloopfov", "unlfov"}, {"unloopfov (unlfov)", "Stops the looped FOV"}, function()
	lib.disconnect("fov_loop")
	lib.disconnect("fov_refresh")
	lib.disconnect("fov_watch")
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

	DoNotif("Tools saved: "..#storedTools,2)
end)

cmd.add({"loadtools", "ltools"}, {"loadtools (ltools)", "Restores your saved tools to your backpack"}, function()
	for _, tool in pairs(storedTools) do
		if not LocalPlayer.Backpack:FindFirstChild(tool.Name) then
			local clonedTool = tool:Clone()
			clonedTool.Parent = LocalPlayer.Backpack
		end
	end

	DoNotif("Tools loaded: "..#storedTools,2)
end)

cmd.add({"preventtools", "noequip", "antiequip"}, {"preventtools (noequip,antiequip)", "Prevents any item from being equipped"}, function()
	local p = Players.LocalPlayer
	local c = p.Character

	lib.disconnect("noequip_char")
	lib.disconnect("noequip_hum")

	local h = c and c:FindFirstChildWhichIsA("Humanoid")
	if not h then return end

	h:UnequipTools()

	local function onTool(t)
		if t:IsA("Tool") then
			t.Enabled = false
			Defer(function()
				h:UnequipTools()
				DoNotif("Tool "..t.Name.." blocked", 2)
			end)
		end
	end

	lib.connect("noequip_char", c.ChildAdded:Connect(onTool))
	lib.connect("noequip_hum", h.ChildAdded:Connect(onTool))

	DoNotif("Tool prevention on", 3)
end)

cmd.add({"unpreventtools", "unnoequip", "unantiequip"}, {"unpreventtools (unnoequip,unantiequip)", "Self-explanatory"}, function()
	lib.disconnect("noequip_char")
	lib.disconnect("noequip_hum")
	DoNotif("Tool prevention off", 2)
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

	lib.connect("oofspam_forcerun", RunService.Stepped:Connect(function()
		if not Humanoid then return lib.disconnect("oofspam_forcerun") end
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end))

	LocalPlayer.Character = nil
	LocalPlayer.Character = Character
	Wait(Players.RespawnTime + 0.1)

	lib.connect("oofspam_loop", RunService.Heartbeat:Connect(function()
		if not getgenv().enabled then
			lib.disconnect("oofspam_loop")
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
		lib.LocalPlayerChat("\0","All")
	end
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
	for _,hum in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
	for _,hum in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
		for _,hum in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
	for _,hum in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
	for _,hum in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
	for _,hum in pairs(SafeGetService("Workspace"):GetDescendants()) do
		disappear(hum)
	end
end)

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
	for _,hum in pairs(SafeGetService("Workspace"):GetDescendants()) do
		disappear(hum)
	end
end)

npcCache = {}
cmd.add({"loopbringnpcs", "lbnpcs"}, {"loopbringnpcs (lbnpcs)", "Loops NPC bringing"}, function()
	if lib.isConnected("loopbringnpcs") then lib.disconnect("loopbringnpcs") end
	table.clear(npcCache)
	for _, hum in ipairs(SafeGetService("Workspace"):GetDescendants()) do
		if hum:IsA("Humanoid") and not Players:GetPlayerFromCharacter(hum.Parent) then
			Insert(npcCache, hum)
		end
	end

	lib.connect("loopbringnpcs", RunService.Heartbeat:Connect(function()
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
							if lib.isProperty(part, "CanCollide") then
								lib.setProperty(part, "CanCollide", false)
							end
						end
					end
				end)
			end
		end
	end))
end)

cmd.add({"unloopbringnpcs", "unlbnpcs"}, {"unloopbringnpcs (unlbnpcs)", "Stops NPC bring loop"}, function()
	lib.disconnect("loopbringnpcs")
end)

cmd.add({"gotonpcs"}, {"gotonpcs", "Teleports to each NPC"}, function()
	local Players = SafeGetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local npcs = {}
	for _, d in pairs(SafeGetService("Workspace"):GetDescendants()) do
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
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = getRoot(char)
		if not (char and hum and root) then return end

		local randomOffset = Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
		local targetPos = root.Position + randomOffset

		NPCControl.CurrentTarget = targetPos
		hum:MoveTo(targetPos)

		DoNotif("Moving to: "..Format("X: %.0f, Y: %.0f, Z: %.0f", targetPos.X, targetPos.Y, targetPos.Z), 1.5)
	end

	NPCControl.Connection = RunService.Heartbeat:Connect(function(dt)
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = getRoot(char)
		if not (char and hum and root) then return end

		NPCControl.MoveCooldown=NPCControl.MoveCooldown - dt
		NPCControl._jumpCooldown = (NPCControl._jumpCooldown or 0) - dt
		NPCControl._moveTimeout = (NPCControl._moveTimeout or 0) + dt

		if hum.Sit then
			DoNotif("Sitting detected — jumping to escape", 1.5)
			hum.Sit = false
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
			NPCControl._jumpCooldown = 1.5
			return
		end

		if NPCControl.CurrentTarget and (root.Position - NPCControl.CurrentTarget).Magnitude < 2 then
			DoNotif("Reached target", 1.5)
			NPCControl.CurrentTarget = nil
		end

		if not NPCControl.CurrentTarget or NPCControl._moveTimeout > 5 then
			if NPCControl._moveTimeout > 5 then
				DoNotif("Stuck — retrying new path", 1.5)
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
					DoNotif("Obstacle detected — jumping", 1.5)
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
	lib.disconnect("clickkill_mouse")

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

	gui.draggablev2(toggleButton)

	MouseButtonFix(toggleButton, function()
		clickkillEnabled = not clickkillEnabled
		toggleButton.Text = clickkillEnabled and "ClickKill: ON" or "ClickKill: OFF"
	end)

	lib.connect("clickkill_mouse", Mouse.Button1Down:Connect(function()
		if not clickkillEnabled then return end

		local Target = Mouse.Target
		if Target and Target.Parent then
			local Character = Target.Parent
			if CheckIfNPC(Character) then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
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
	lib.disconnect("clickkill_mouse")
end)

cmd.add({"voidnpcs", "vnpcs"}, {"voidnpcs (vnpcs)", "Teleports NPC's to void"}, function()
	for _, d in ipairs(SafeGetService("Workspace"):GetDescendants()) do
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
	lib.disconnect("clickvoid_mouse")

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
	gui.draggablev2(button)

	MouseButtonFix(button, function()
		clickVoidEnabled = not clickVoidEnabled
		button.Text = clickVoidEnabled and "ClickVoid: ON" or "ClickVoid: OFF"
	end)

	local mouse = player:GetMouse()
	lib.connect("clickvoid_mouse", mouse.Button1Down:Connect(function()
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
	lib.disconnect("clickvoid_mouse")
end)

--[[ FUNCTIONALITY ]]--
localPlayer.Chatted:Connect(function(str)
	lib.parseCommand(str)
end)

--[[ Admin Player]]
function IsAdminAndRun(Message, Player)
	if Admin[Player.UserId] or isRelAdmin(Player) then
		lib.parseCommand(Message, Player)
	end
end

function CheckPermissions(Player)
	Player.Chatted:Connect(function(Message)
		IsAdminAndRun(Message,Player)
	end)
end

--[[function Getmodel(id)
	local ob23e232323=nil
	s,r=pcall(function()
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
		return loadstring(game:HttpGet(NAUILOADER))()
	end)

	if NASUC then
		NASCREENGUI = resexy
	else
		warn(math.random(1,999999).." | Failed to load UI module: "..resexy.." | retrying...")
		Wait(.3)
	end
until NASCREENGUI
local rPlayer=Players:FindFirstChildWhichIsA("Player")
local coreGuiProtection={}
if not RunService:IsStudio() then
else
	repeat Wait() until player:FindFirstChild("AdminUI",true)
	NASCREENGUI=player:FindFirstChild("AdminUI",true)
end
--repeat Wait() until ScreenGui~=nil -- if it loads late then I'll just add this here

NaProtectUI(NASCREENGUI)

local description = NASCREENGUI:FindFirstChild("Description")
local AUTOSCALER = NASCREENGUI:FindFirstChild("AutoScale")
local cmdBar = NASCREENGUI:FindFirstChild("CmdBar")
local centerBar = cmdBar and cmdBar:FindFirstChild("CenterBar")
local cmdInput = centerBar and centerBar:FindFirstChild("Input")
local cmdAutofill = cmdBar and cmdBar:FindFirstChild("Autofill")
local cmdExample = cmdAutofill and cmdAutofill:FindFirstChildWhichIsA("Frame")
local leftFill = cmdBar and cmdBar:FindFirstChild("LeftFill")
local rightFill = cmdBar and cmdBar:FindFirstChild("RightFill")
local chatLogsFrame = NASCREENGUI:FindFirstChild("ChatLogs")
local chatLogs = chatLogsFrame and chatLogsFrame:FindFirstChild("Container") and chatLogsFrame:FindFirstChild("Container"):FindFirstChild("Logs")
local chatExample = chatLogs and chatLogs:FindFirstChildWhichIsA("TextLabel")
local NAconsoleFrame = NASCREENGUI:FindFirstChild("soRealConsole")
local NAconsoleLogs = NAconsoleFrame and NAconsoleFrame:FindFirstChild("Container") and NAconsoleFrame:FindFirstChild("Container"):FindFirstChild("Logs")
local NAconsoleExample = NAconsoleLogs and NAconsoleLogs:FindFirstChildWhichIsA("TextLabel")
local NAcontainer = NAconsoleFrame and NAconsoleFrame:FindFirstChild("Container")
local NAfilter = NAcontainer and NAcontainer:FindFirstChild("Filter")
local commandsFrame = NASCREENGUI:FindFirstChild("Commands")
local commandsFilter = commandsFrame and commandsFrame:FindFirstChild("Container") and commandsFrame:FindFirstChild("Container"):FindFirstChild("Filter")
local commandsList = commandsFrame and commandsFrame:FindFirstChild("Container") and commandsFrame:FindFirstChild("Container"):FindFirstChild("List")
local commandExample = commandsList and commandsList:FindFirstChild("TextLabel")
local UpdLogsFrame = NASCREENGUI:FindFirstChild("UpdLog")
local UpdLogsTitle = loadOldNAUI() and UpdLogsFrame and UpdLogsFrame:FindFirstChild("Topbar") and UpdLogsFrame:FindFirstChild("Topbar"):FindFirstChild("TopBar") and UpdLogsFrame:FindFirstChild("Topbar"):FindFirstChild("TopBar"):FindFirstChild("Title") or UpdLogsFrame and UpdLogsFrame:FindFirstChild("Topbar") and UpdLogsFrame:FindFirstChild("Topbar"):FindFirstChild("Title")
local UpdLogsList = UpdLogsFrame and UpdLogsFrame:FindFirstChild("Container") and UpdLogsFrame:FindFirstChild("Container"):FindFirstChild("List")
local UpdLogsLabel = UpdLogsList and UpdLogsList:FindFirstChildWhichIsA("TextLabel")
local resizeFrame = NASCREENGUI:FindFirstChild("Resizeable")
local ModalFixer = NASCREENGUI:FindFirstChildWhichIsA("ImageButton")
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

if cmdExample then
	cmdExample.Parent = nil
end

if chatExample then
	chatExample.Parent = nil
end

if NAconsoleExample then
	NAconsoleExample.Parent = nil
end

if commandExample then
	commandExample.Parent = nil
end

if UpdLogsLabel then
	UpdLogsLabel.Parent = nil
end

if resizeFrame then
	resizeFrame.Parent = nil
end

	--[[pcall(function()
		for i,v in pairs(NASCREENGUI:GetDescendants()) do
			coreGuiProtection[v]=rPlayer.Name
		end
		NASCREENGUI.DescendantAdded:Connect(function(v)
			coreGuiProtection[v]=rPlayer.Name
		end)
		coreGuiProtection[NASCREENGUI]=rPlayer.Name
	
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
		local newGui=COREGUI:FindFirstChildWhichIsA("NASCREENGUI")
		newGui.DescendantAdded:Connect(function(v)
			coreGuiProtection[v]=rPlayer.Name
		end)
		for i,v in pairs(NASCREENGUI:GetChildren()) do
			v.Parent=newGui
		end
		NASCREENGUI=newGui
	end]]

--[[ GUI FUNCTIONS ]]--
gui={}
gui.txtSize=function(ui,x,y)
	local textService=TextService
	return textService:GetTextSize(ui.Text,ui.TextSize,ui.Font,Vector2.new(x,y))
end
gui.commands = function()
	local cFrame, cList = commandsFrame, commandsList

	if not cFrame.Visible then
		cFrame.Visible = true
		cList.CanvasSize = UDim2.new(0, 0, 0, 0)
	end

	for _, v in ipairs(cList:GetChildren()) do
		if v:IsA("TextLabel") then v:Destroy() end
	end

	local yOffset = 5
	for cmdName, tbl in pairs(Commands) do
		local Cmd = commandExample:Clone()
		Cmd.Parent = cList
		Cmd.Name = cmdName
		Cmd.Text = " "..tbl[2][1]
		Cmd.Position = UDim2.new(0, 0, 0, yOffset)

		Cmd.MouseEnter:Connect(function()
			description.Visible = true
			description.Text = tbl[2][2]
		end)

		Cmd.MouseLeave:Connect(function()
			if description.Text == tbl[2][2] then
				description.Visible = false
				description.Text = ""
			end
		end)

		yOffset = yOffset + 20
	end

	cList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	cFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
end
gui.chatlogs = function()
	if chatLogsFrame then
		if not chatLogsFrame.Visible then
			chatLogsFrame.Visible = true
		end
		chatLogsFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
	end
end
gui.doModal = function(v)
	ModalFixer.Modal = v
end
gui.consoleeee = function()
	if NAconsoleFrame then
		if not NAconsoleFrame.Visible then
			NAconsoleFrame.Visible = true
		end
		NAconsoleFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
	end
end
gui.updateLogs = function()
	if UpdLogsFrame then
		if not UpdLogsFrame.Visible and next(NAupdLogs) then
			UpdLogsFrame.Visible = true
		elseif not next(NAupdLogs) then
			DoNotif("no upd logs for now...")
		else
			warn("huh?")
		end
		UpdLogsFrame.Position = UDim2.new(0.43, 0, 0.4, 0)
	end
end
gui.tween = function(obj, style, direction, duration, goal, callback)
	style = style or "Sine"
	direction = direction or "Out"
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle[style], Enum.EasingDirection[direction])
	local tween = TweenService:Create(obj, tweenInfo, goal)
	if callback then tween.Completed:Connect(callback) end
	tween:Play()
	return tween
end

gui.resizeable = function(ui, min, max)
	min = min or Vector2.new(ui.AbsoluteSize.X, ui.AbsoluteSize.Y)
	max = max or Vector2.new(5000, 5000)

	local screenGui = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui.Parent
	local scale = AUTOSCALER and AUTOSCALER.Scale or 1

	local rgui = resizeFrame:Clone()
	rgui.Parent = ui

	local dragging = false
	local mode
	local UIPos
	local lastSize
	local lastPos = Vector2.new()

	local function updateResize(currentPos)
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
	end

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateResize(Vector2.new(input.Position.X, input.Position.Y))
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			mode = nil
			if mouse and mouse.Icon ~= "" then
				mouse.Icon = ""
			end
		end
	end)

	for _, button in pairs(rgui:GetChildren()) do
		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				mode = button
				dragging = true
				local currentPos = input.Position
				lastPos = Vector2.new(currentPos.X, currentPos.Y)
				lastSize = ui.AbsoluteSize
				UIPos = ui.Position
			end
		end)

		button.InputEnded:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and mode == button then
				dragging = false
				mode = nil
				if mouse and resizeXY[button.Name] and mouse.Icon == resizeXY[button.Name][3] then
					mouse.Icon = ""
				end
			end
		end)

		button.MouseEnter:Connect(function()
			if resizeXY[button.Name] and mouse then
				mouse.Icon = resizeXY[button.Name][3]
			end
		end)

		button.MouseLeave:Connect(function()
			if not dragging and resizeXY[button.Name] and mouse and mouse.Icon == resizeXY[button.Name][3] then
				mouse.Icon = ""
			end
		end)
	end

	return function()
		rgui:Destroy()
	end
end

gui.draggable=function(ui, dragui)
	if not dragui then dragui = ui end
	local UserInputService = SafeGetService("UserInputService")
	local dragging
	local dragInput
	local dragStart
	local startPos
	local function update(input)
		local delta = input.Position - dragStart
		local newXOffset = startPos.X.Offset + delta.X
		local newYOffset = startPos.Y.Offset + delta.Y
		local screenSize = ui.Parent.AbsoluteSize
		local newXScale = startPos.X.Scale + (newXOffset / screenSize.X)
		local newYScale = startPos.Y.Scale + (newYOffset / screenSize.Y)
		ui.Position = UDim2.new(newXScale, 0, newYScale, 0)
	end
	dragui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = ui.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	dragui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
	ui.Active = true
end

gui.draggablev2 = function(ui, dragui)
	if not dragui then
		dragui = ui
	end
	local UserInputService = SafeGetService("UserInputService")

	local screenGui = ui:FindFirstAncestorWhichIsA("ScreenGui") or ui.Parent

	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		local parentSize = screenGui.AbsoluteSize
		local uiSize = ui.AbsoluteSize

		local newXScale = startPos.X.Scale + (delta.X / parentSize.X)
		local newYScale = startPos.Y.Scale + (delta.Y / parentSize.Y)

		local anchor = ui.AnchorPoint
		local minX = anchor.X * (uiSize.X / parentSize.X)
		local maxX = 1 - (1 - anchor.X) * (uiSize.X / parentSize.X)
		local minY = anchor.Y * (uiSize.Y / parentSize.Y)
		local maxY = 1 - (1 - anchor.Y) * (uiSize.Y / parentSize.Y)

		newXScale = math.clamp(newXScale, minX, maxX)
		newYScale = math.clamp(newYScale, minY, maxY)

		ui.Position = UDim2.new(newXScale, 0, newYScale, 0)
	end

	dragui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = ui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	local function onScreenSizeChanged()
		local parentSize = screenGui.AbsoluteSize
		local uiSize = ui.AbsoluteSize
		local currentPos = ui.Position

		local anchor = ui.AnchorPoint
		local minX = anchor.X * (uiSize.X / parentSize.X)
		local maxX = 1 - (1 - anchor.X) * (uiSize.X / parentSize.X)
		local minY = anchor.Y * (uiSize.Y / parentSize.Y)
		local maxY = 1 - (1 - anchor.Y) * (uiSize.Y / parentSize.Y)

		local newXScale = math.clamp(currentPos.X.Scale, minX, maxX)
		local newYScale = math.clamp(currentPos.Y.Scale, minY, maxY)

		ui.Position = UDim2.new(newXScale, 0, newYScale, 0)
	end

	screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(onScreenSizeChanged)

	ui.Active = true
end

gui.menuify = function(menu)
	if menu:IsA("Frame") then menu.AnchorPoint=Vector2.new(0,0) end
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
			gui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, sizeX.Value, 0, 35)})
				.Completed:Connect(function()
					isAnimating = false
				end)
		else
			gui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, sizeX.Value, 0, sizeY.Value)})
				.Completed:Connect(function()
					isAnimating = false
				end)
		end
	end

	MouseButtonFix(minimizeButton, toggleMinimize)
	MouseButtonFix(exitButton, function()
		menu.Visible = false
	end)
	gui.draggablev2(menu, menu.Topbar)
	menu.Visible = false
end

gui.menuifyv2 = function(menu)
	if menu:IsA("Frame") then menu.AnchorPoint = Vector2.new(0, 0) end

	local exitButton = menu:FindFirstChild("Exit", true)
	local minimizeButton = menu:FindFirstChild("Minimize", true)
	local clearButton = menu:FindFirstChild("Clear", true)

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
			gui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, sizeX.Value, 0, 35)}).Completed:Connect(function()
				isAnimating = false
			end)
		else
			gui.tween(menu, "Quart", "Out", 0.5, {Size = UDim2.new(0, sizeX.Value, 0, sizeY.Value)}).Completed:Connect(function()
				isAnimating = false
			end)
		end
	end

	MouseButtonFix(minimizeButton, toggleMinimize)
	MouseButtonFix(exitButton, function()
		menu.Visible = false
	end)

	if clearButton then
		clearButton.Visible = true

		MouseButtonFix(clearButton, function()
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
	end

	gui.draggablev2(menu, menu.Topbar)
	menu.Visible = false
end

gui.hideFill = function()
	for i, v in ipairs(CMDAUTOFILL) do
		if v:IsA("Frame") then
			v.Visible = false
		end
	end
end

gui.loadCommands = function()
	for _, v in pairs(cmdAutofill:GetChildren()) do
		if v:IsA("GuiObject") and v.Name ~= "UIListLayout" then
			v:Destroy()
		end
	end

	CMDAUTOFILL = {}
	local i = 0

	for name, cmdData in pairs(Commands) do
		local usageText = "Unknown"
		local info = cmdData[2]

		if type(info) == "table" and #info >= 1 then
			usageText = info[1]

			local aliasesList = {}
			for alias, aliasData in pairs(Aliases) do
				if aliasData == cmdData then
					Insert(aliasesList, alias)
				end
			end

			if #aliasesList > 0 and not usageText:find("%b()") then
				usageText = usageText.." ("..Concat(aliasesList, ", ")..")"
			end
		end

		local btn = cmdExample:Clone()
		btn.Parent = cmdAutofill
		btn.Name = name
		btn.Input.Text = usageText

		i += 1
		Insert(CMDAUTOFILL, btn)
	end

	cmdNAnum = i
	gui.hideFill()
end

gui.loadCommands()

Spawn(function() -- plugin tester
	while Wait(2) do
		if countDictNA(Commands) ~= cmdNAnum then
			gui.loadCommands()
		end
	end
end)

gui.barSelect = function(speed)
	speed = speed or 0.4

	centerBar.Visible = true
	centerBar.Size = UDim2.new(0, 0, 1, 15)

	gui.tween(centerBar, "Quint", "Out", speed, {Size = UDim2.new(0, 250, 1, 15)})

	leftFill.Position = UDim2.new(-0.5, 0, 0.5, 0)
	rightFill.Position = UDim2.new(1.5, 0, 0.5, 0)

	gui.tween(leftFill, "Quart", "Out", speed, {Position = UDim2.new(0, 0, 0.5, 0)})
	gui.tween(rightFill, "Quart", "Out", speed, {Position = UDim2.new(1, 0, 0.5, 0)})
end

gui.barDeselect = function(speed)
	speed = speed or 0.4

	gui.tween(centerBar, "Back", "InOut", speed, {Size = UDim2.new(0, 250, 0, 0)})

	gui.tween(leftFill, "Quart", "In", speed * 0.9, {Position = UDim2.new(-0.5, -125, 0.5, 0)})
	gui.tween(rightFill, "Quart", "In", speed * 0.9, {Position = UDim2.new(1.5, 125, 0.5, 0)})

	for i, v in ipairs(cmdAutofill:GetChildren()) do
		if v:IsA("Frame") then
			wrap(function()
				Wait(math.random(50, 120) / 1000)
				gui.tween(v, "Exponential", "In", 0.25, {Size = UDim2.new(0, 0, 0, 25)})
			end)
		end
	end
end

--[[ AUTOFILL SEARCHER ]]--
searchedSEARCH=false
lastSearchText = ""
searchHeartbeat = nil

gui.searchCommands = function()
	local inputText = GSub(cmdInput.Text, ";", "")
	inputText = Lower(inputText)

	if inputText == lastSearchText then
		return
	end

	lastSearchText = inputText

	if searchHeartbeat then
		searchHeartbeat:Disconnect()
	end

	searchHeartbeat = RunService.Heartbeat:Connect(function()
		searchHeartbeat:Disconnect()

		local searchTerm = inputText
		if Find(searchTerm, "%s") then
			if not searchedSEARCH then
				for _, frame in ipairs(CMDAUTOFILL) do
					frame.Visible = false
				end
				searchedSEARCH = true
			end
			return
		end

		searchedSEARCH = false

		local searchTermLength = #searchTerm
		local results = {}
		local maxResults = 5

		for _, frame in ipairs(CMDAUTOFILL) do
			local cmdName = Lower(frame.Name)
			local command = Commands[cmdName]
			if not command then continue end

			local displayInfo = command[2] and command[2][1] or ""
			local searchableName = Lower(displayInfo)
			searchableName = GSub(searchableName, "<[^>]+>", "")
			searchableName = GSub(searchableName, "%[[^%]]+%]", "")
			searchableName = GSub(searchableName, "%([^%)]+%)", "")
			searchableName = GSub(searchableName, "{[^}]+}", "")
			searchableName = GSub(searchableName, "【[^】]+】", "")
			searchableName = GSub(searchableName, "〖[^〗]+〗", "")
			searchableName = GSub(searchableName, "«[^»]+»", "")
			searchableName = GSub(searchableName, "‹[^›]+›", "")
			searchableName = GSub(searchableName, "「[^」]+」", "")
			searchableName = GSub(searchableName, "『[^』]+』", "")
			searchableName = GSub(searchableName, "（[^）]+）", "")
			searchableName = GSub(searchableName, "〔[^〕]+〕", "")
			searchableName = GSub(searchableName, "‖[^‖]+‖", "")
			searchableName = GSub(searchableName, "%s+", " ")
			searchableName = GSub(searchableName, "^%s*(.-)%s*$", "%1")

			local extraAliases = {}
			for alias in displayInfo:gmatch("%(([^%)]+)%)") do
				for a in alias:gmatch("[^,%s]+") do
					Insert(extraAliases, Lower(a))
				end
			end

			local score = 999
			local matchText = cmdName

			if cmdName == searchTerm then
				score = 1
			elseif Sub(cmdName, 1, searchTermLength) == searchTerm then
				score = 2
			elseif Aliases[searchTerm] and Aliases[searchTerm][1] == command[1] then
				score = 3
				matchText = searchTerm
			elseif NASAVEDALIASES[searchTerm] and NASAVEDALIASES[searchTerm] == cmdName then
				score = 3
				matchText = searchTerm
			else
				for alias, realCmd in pairs(Aliases) do
					if realCmd[1] == command[1] and Sub(alias, 1, searchTermLength) == searchTerm then
						score = 4
						matchText = alias
						break
					end
				end
				for alias, realCmd in pairs(NASAVEDALIASES) do
					if realCmd == cmdName and Sub(alias, 1, searchTermLength) == searchTerm then
						score = 4
						matchText = alias
						break
					end
				end
			end

			if score == 999 then
				for _, extraAlias in ipairs(extraAliases) do
					if extraAlias == searchTerm then
						score = 3
						matchText = cmdName
						break
					elseif Sub(extraAlias, 1, searchTermLength) == searchTerm then
						score = 4
						matchText = cmdName
						break
					elseif Find(extraAlias, searchTerm, 1, true) then
						score = 5
						matchText = cmdName
						break
					end
				end
			end

			if score == 999 and searchTermLength >= 2 then
				if Find(cmdName, searchTerm, 1, true) then
					score = 6
					matchText = cmdName
				elseif Find(searchableName, searchTerm, 1, true) then
					score = 7
					matchText = displayInfo
				end
			end

			if score < 999 then
				Insert(results, {
					frame = frame,
					score = score,
					text = matchText,
					name = cmdName,
				})
			end
		end

		table.sort(results, function(a, b)
			if a.score == b.score then
				return a.name < b.name
			end
			return a.score < b.score
		end)

		for _, frame in ipairs(CMDAUTOFILL) do
			frame.Visible = false
		end

		for i, result in ipairs(results) do
			if i > maxResults then break end

			local frame = result.frame
			frame.Visible = true

			local width = math.sqrt(i) * 125
			local yOffset = (i - 1) * 28
			local newPos = UDim2.new(0.5, width, 0, yOffset)

			gui.tween(frame, "Quint", "Out", 0.3, {
				Size = UDim2.new(0.5, width, 0, 25),
				Position = newPos,
			})
		end
	end)
end

--[[ OPEN THE COMMAND BAR ]]--
mouse.KeyDown:Connect(function(k)
	if k:lower()==opt.prefix then
		Wait();
		gui.barSelect()
		cmdInput.Text=''
		cmdInput:CaptureFocus()
	end
end)

--[[ CLOSE THE COMMAND BAR ]]--
cmdInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		wrap(function()
			lib.parseCommand(opt.prefix..cmdInput.Text)
		end)
	end
	gui.barDeselect()
end)

cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
	gui.searchCommands()
end)

gui.barDeselect(0)
cmdBar.Visible=true
if chatLogsFrame then
	gui.menuifyv2(chatLogsFrame)
end

if NAconsoleFrame then
	gui.menuifyv2(NAconsoleFrame)
end

if commandsFrame then
	gui.menuify(commandsFrame)
end

if UpdLogsFrame then
	gui.menuify(UpdLogsFrame)
end

--[[ GUI RESIZE FUNCTION ]]--

if chatLogsFrame then gui.resizeable(chatLogsFrame) end
if NAconsoleFrame then gui.resizeable(NAconsoleFrame) end
if commandsFrame then gui.resizeable(commandsFrame) end
if UpdLogsFrame then gui.resizeable(UpdLogsFrame) end

--[[ CMDS COMMANDS SEARCH FUNCTION ]]--
commandsFilter:GetPropertyChangedSignal("Text"):Connect(function()
	local searchText = Lower(GSub(commandsFilter.Text, ";", ""))

	for _, label in ipairs(commandsList:GetChildren()) do
		if label:IsA("TextLabel") then
			local cmdName = Lower(label.Name)
			local command = Commands[cmdName]
			local displayInfo = command and command[2] and command[2][1] or ""
			local updatedText = displayInfo

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
			for alias, aliasData in pairs(Aliases) do
				if aliasData[1] == baseFunc then
					Insert(extraAliases, Lower(alias))
				end
			end
			for alias, realCmdName in pairs(NASAVEDALIASES) do
				if realCmdName == cmdName then
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
	local chatMsg = chatExample:Clone()

	for _, v in pairs(chatLogs:GetChildren()) do
		if v:IsA("TextLabel") then
			v.LayoutOrder = v.LayoutOrder + 1
		end
	end

	chatMsg.Name = randomString()
	chatMsg.Parent = chatLogs

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

	if isNAadmin then
		chatMsg:Destroy()
	else
		if displayName == userName then
			chatMsg.Text = ("@%s: %s"):format(userName, msg)
		else
			chatMsg.Text = ("%s [@%s]: %s"):format(displayName, userName, msg)
		end

		if plr == LocalPlayer then
			chatMsg.TextColor3 = Color3.fromRGB(0, 0, 155)
		elseif LocalPlayer:IsFriendsWith(plr.UserId) then
			chatMsg.TextColor3 = Color3.fromRGB(255, 255, 0)
		end
	end

	local txtSize = gui.txtSize(chatMsg, chatMsg.AbsoluteSize.X, 100)
	chatMsg.Size = UDim2.new(1, -5, 0, txtSize.Y)

	local MAX_MESSAGES = 100
	local chatFrames = {}
	for _, v in pairs(chatLogs:GetChildren()) do
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

function bindToDevConsole()
	if not NAconsoleLogs or not NAconsoleExample then return end

	local toggles = { Output = true, Info = true, Warn = true, Error = true }

	local FilterButtons = InstanceNew("Frame")
	FilterButtons.Name = "FilterButtons"
	FilterButtons.Size = UDim2.new(1, -10, 0, 22)
	FilterButtons.Position = UDim2.new(0.5, 0, 0, 30)
	FilterButtons.AnchorPoint = Vector2.new(0.5, 0)
	FilterButtons.BackgroundTransparency = 1
	FilterButtons.Parent = NAconsoleLogs.Parent

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

		local checkbox = InstanceNew("TextLabel")
		checkbox.Name = "Checkbox"
		checkbox.Size = UDim2.new(0, 18, 1, 0)
		checkbox.Position = UDim2.new(0, 5, 0, 0)
		checkbox.BackgroundTransparency = 1
		checkbox.Font = Enum.Font.Gotham
		checkbox.TextSize = 14
		checkbox.TextXAlignment = Enum.TextXAlignment.Center
		checkbox.TextYAlignment = Enum.TextYAlignment.Center
		checkbox.Text = "✅"
		checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
		checkbox.Parent = btnContainer

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

		MouseButtonFix(clickZone,function()
			toggles[logType] = not toggles[logType]
			checkbox.Text = toggles[logType] and "✅" or "⬜"

			for _, label in pairs(NAconsoleLogs:GetChildren()) do
				if label:IsA("TextLabel") and label:FindFirstChild("Tag") then
					local tag = label.Tag.Value
					local matchesSearch = NAfilter.Text == "" or Find(label.Text:lower(), NAfilter.Text:lower())
					label.Visible = toggles[tag] and matchesSearch
				end
			end
		end)
	end

	NAfilter:GetPropertyChangedSignal("Text"):Connect(function()
		local query = NAfilter.Text:lower()
		for _, label in pairs(NAconsoleLogs:GetChildren()) do
			if label:IsA("TextLabel") and label:FindFirstChild("Tag") then
				local tag = label.Tag.Value
				local matches = query == "" or Find(label.Text:lower(), query)
				label.Visible = toggles[tag] and matches
			end
		end
	end)

	local messageCounter = 0

	LogService.MessageOut:Connect(function(msg, msgTYPE)
		messageCounter=messageCounter + 1

		local logLabel = NAconsoleExample:Clone()
		logLabel.Name = "Log_"..tostring(math.random(100000, 999999))
		logLabel.Parent = NAconsoleLogs
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

		logLabel.Text = Format(
			'<font color="%s">[%s]</font>: <font color="#ffffff">%s</font>',
			tagColor,
			tagText,
			msg
		)

		local tag = InstanceNew("StringValue")
		tag.Name = "Tag"
		tag.Value = tagText
		tag.Parent = logLabel

		local txtSize = gui.txtSize(logLabel, logLabel.AbsoluteSize.X, 100)
		logLabel.Size = UDim2.new(1, -5, 0, txtSize.Y)

		local MAX_MESSAGES = 300
		local logFrames = {}

		for _, v in pairs(NAconsoleLogs:GetChildren()) do
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

		local matchesSearch = NAfilter.Text == "" or Find(logLabel.Text:lower(), NAfilter.Text:lower())
		logLabel.Visible = toggles[tagText] and matchesSearch
	end)
end

function NAUISCALEUPD()
	if not SafeGetService("Workspace").CurrentCamera then return end

	local screenHeight = SafeGetService("Workspace").CurrentCamera.ViewportSize.Y
	local baseHeight = 720
	AUTOSCALER.Scale = math.clamp(screenHeight / baseHeight, 0.75, 1.25)
end

function setupPlayer(plr)
	plr.Chatted:Connect(function(msg)
		bindToChat(plr, msg)
	end)

	Insert(playerButtons, plr)

	if plr ~= LocalPlayer then
		CheckPermissions(plr)
	end

	if ESPenabled then
		Spawn(function()
			repeat Wait() until plr.Character
			NAESP(plr)
		end)
	end
end

for _, plr in pairs(Players:GetPlayers()) do
	setupPlayer(plr)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(plr)
	local index = Discover(playerButtons, plr)
	if index then
		table.remove(playerButtons, index)
	end
	removeESPonLEAVE(plr)
end)

function setupFLASHBACK(c)
	if not c then return end
	c:WaitForChild("Humanoid",5).Died:Connect(function()
		local root = getRoot(character)
		if root then
			deathCFrame = root.CFrame
		end
	end)
end

setupFLASHBACK(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(setupFLASHBACK)

mouse.Move:Connect(function()
	local viewportSize = SafeGetService("Workspace").CurrentCamera and SafeGetService("Workspace").CurrentCamera.ViewportSize or Vector2.new(1920, 1080)

	local xScale = mouse.X / viewportSize.X
	local yScale = mouse.Y / viewportSize.Y

	description.Position = UDim2.new(xScale, 0, yScale, 0)

	local newSize = gui.txtSize(description, 200, 100)
	description.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
end)

function updateCanvasSize(frame, scale)
	local layout = frame:FindFirstChildOfClass("UIListLayout")
	if layout then
		local adjustedHeight = layout.AbsoluteContentSize.Y / scale
		frame.CanvasSize = UDim2.new(0, 0, 0, adjustedHeight)
	end
end

RunService.Stepped:Connect(function()
	if chatLogs then updateCanvasSize(chatLogs, AUTOSCALER.Scale) end
	if NAconsoleLogs then updateCanvasSize(NAconsoleLogs, AUTOSCALER.Scale) end
	if commandsList then updateCanvasSize(commandsList, AUTOSCALER.Scale) end
	if UpdLogsList then updateCanvasSize(UpdLogsList, AUTOSCALER.Scale) end
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

			if FileSupport and isfile(NAPREFIXPATH) then
				local filePrefix = readfile(NAPREFIXPATH)
				if isInvalid(filePrefix) then
					writefile(NAPREFIXPATH, ";")
				end
			end
		end
	else
		lastPrefix = p
	end
end)

RunService.RenderStepped:Connect(NAUISCALEUPD)

Spawn(function()
	local template = UpdLogsLabel
	local list = UpdLogsList

	UpdLogsTitle.Text = UpdLogsTitle.Text.." "..NAupdDate

	if next(NAupdLogs) then
		for name, txt in pairs(NAupdLogs) do
			local btn = template:Clone()
			btn.Parent = list
			btn.Name = name
			btn.Text = "-"..txt
		end
	end
end)

--[[ COMMAND BAR BUTTON ]]--
local TextLabel = InstanceNew("TextLabel")
local UICorner = InstanceNew("UICorner")
local UIStroke = InstanceNew("UIStroke")
local UIGradient = InstanceNew("UIGradient")
local ImageButton = InstanceNew("ImageButton")
local UICorner2 = InstanceNew("UICorner")

TextLabel.Parent = NASCREENGUI
TextLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TextLabel.BackgroundTransparency = 1
TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
TextLabel.Size = UDim2.new(0, 0, 0, 0)
TextLabel.Font = Enum.Font.FredokaOne
TextLabel.Text = getSeasonEmoji().." "..adminName.." V"..curVer.." "..getSeasonEmoji()
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 22
TextLabel.TextWrapped = true
TextLabel.TextStrokeTransparency = 0.7
TextLabel.TextTransparency = 1
TextLabel.ZIndex = 9999

UICorner2.CornerRadius = UDim.new(0.25, 0)
UICorner2.Parent = TextLabel

UIStroke.Parent = TextLabel
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 0, 0)
UIStroke.Transparency = 0.4
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

UIGradient.Parent = TextLabel
UIGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 170))
}
UIGradient.Transparency = NumberSequence.new{
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.5, 0.25),
	NumberSequenceKeypoint.new(1, 0)
}
UIGradient.Rotation = 55

ImageButton.Parent = NASCREENGUI
ImageButton.BackgroundTransparency = 1
ImageButton.AnchorPoint = Vector2.new(0.5, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.5, 0, -1, 0)
ImageButton.Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale)
ImageButton.Image = isAprilFools() and "rbxassetid://104531932157501" or "rbxassetid://77352376040674"
ImageButton.ZIndex = 9999

UICorner.CornerRadius = UDim.new(0.5, 0)
UICorner.Parent = ImageButton

NAimageButton = ImageButton

if IsOnMobile then
	ImageButton.MouseEnter:Connect(function()
		TweenService:Create(ImageButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 35 * NAScale, 0, 35 * NAScale)
		}):Play()
	end)
	ImageButton.MouseLeave:Connect(function()
		TweenService:Create(ImageButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale)
		}):Play()
	end)
end

swooshySWOOSH = false

function Swoosh()
	TweenService:Create(ImageButton, TweenInfo.new(1.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Rotation = isAprilFools() and math.random(540, 1440) or 720
	}):Play()

	gui.draggablev2(ImageButton)

	if swooshySWOOSH then
		return
	end
	swooshySWOOSH = true

	ImageButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if FileSupport and NAiconSaveEnabled then
						local pos = ImageButton.Position
						writefile(NAICONPOSPATH, HttpService:JSONEncode({
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

	if IsOnMobile then
		ImageButton.Size = UDim2.new(0, 0, 0, 0)
		ImageButton.ImageTransparency = 1

		local targetPos = UDim2.new(0.5, 0, 0.1, 0)

		if FileSupport and isfile(NAICONPOSPATH) then
			local data = HttpService:JSONDecode(readfile(NAICONPOSPATH))
			if data and data.X and data.Y then
				targetPos = UDim2.new(data.X, 0, data.Y, 0)
			end
		end

		ImageButton.Position = UDim2.new(targetPos.X.Scale, 0, targetPos.Y.Scale - 0.15, -20)

		local appearBtnTween = TweenService:Create(ImageButton, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 32 * NAScale, 0, 32 * NAScale),
			Position = targetPos,
			ImageTransparency = 0
		})
		appearBtnTween:Play()

		Swoosh()
	else
		ImageButton:Destroy()
	end

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

if IsOnMobile then
	MouseButtonFix(ImageButton,function()
		gui.barSelect()
		cmdInput.Text=''
		cmdInput:CaptureFocus()
	end)
end

--@ltseverydayyou (Aervanix)
--@Cosmella (Viper)

--original by @qipu | loadstring(game:HttpGet("https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"))();

Spawn(function()
	local NAresult = tick() - NAbegin
	local nameCheck = nameChecker(Player)

	Delay(0.3, function()
		local executorName = identifyexecutor and identifyexecutor() or "Unknown"
		local welcomeMessage = "Welcome to "..adminName.." V"..curVer

		executorName = maybeMock(executorName)
		welcomeMessage = maybeMock(welcomeMessage)

		local notifBody = welcomeMessage..
			(identifyexecutor and ("\nExecutor: "..executorName) or "")..
			"\nUpdated on: "..NAupdDate..
			"\nTime Taken To Load: "..loadedResults(NAresult)

		DoNotif(notifBody, 6, rngMsg().." "..nameCheck)

		if not FileSupport then
			warn("NAWWW NO FILE SUPPORT???????")
			Notify({
				Title = maybeMock("Would you like to enable QueueOnTeleport?"),
				Description = maybeMock("With QueueOnTeleport, "..adminName.." will automatically execute itself upon teleporting to a game or place."),
				Buttons = {
					{Text = "Yes", Callback = function()
						queueteleport(loader)
					end},
					{Text = "No", Callback = function() end}
				}
			})
		elseif not queueteleport then
			warn('your executor is dog shit')
		end

		Wait(1)

		if IsOnPC then
			local keybindMessage = maybeMock("Your Keybind Prefix: "..opt.prefix)
			DoNotif(keybindMessage, 10, adminName.." Keybind Prefix")
		end

		Wait(2)

		--[[Notify({
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

		--[[local updateLogMessage = maybeMock('Added "updlog" command (displays any new changes added into '..adminName..')')
		DoNotif(updateLogMessage, nil, "Info")]]
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
	cmdInput.ZIndex = 10
	cmdInput.PlaceholderText = isAprilFools() and '🤡 '..adminName.." V"..curVer..' 🤡' or getSeasonEmoji()..' '..adminName.." V"..curVer..' '..getSeasonEmoji()
end)

CaptureService.CaptureBegan:Connect(function()
	if NAimageButton then
		NAimageButton.Visible=false
	end
end)

CaptureService.CaptureEnded:Connect(function()
	Delay(0.1, function()
		if NAimageButton then
			NAimageButton.Visible=true
		end
	end)
end)

--[[if not LegacyChat then
	TextChatService.OnIncomingMessage = function(message)
		local textSource = message.TextSource
		if not textSource then return end

		local fromPlayer = Players:GetPlayerByUserId(textSource.UserId)
		if not fromPlayer then return end

		for _, adminId in ipairs(_G.NAadminsLol) do
			if fromPlayer.UserId == adminId then
				local clr = 255
				local hex = Format("#%02X%02X%02X", clr, clr, clr)
				local props = InstanceNew("TextChatMessageProperties")
				props.PrefixText = Format('<font color="%s">[NA ADMIN]</font> %s', hex, message.PrefixText or "")
				props.Text = message.Text
				return props
			end
		end

		local tag = fromPlayer:GetAttribute("CustomNAtagger")
		if tag then
			local props = InstanceNew("TextChatMessageProperties")
			props.PrefixText = Format('<font color="#00FFAA">[%s]</font> %s', tag, message.PrefixText or "")
			props.Text = message.Text
			return props
		end
	end
end]]

print([[
	
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
]])

math.randomseed(os.time())

Spawn(function()
	while Wait() do
		if getHum() then
			getHum().AutoJumpEnabled=false
			break
		end
	end
end)

Spawn(function() -- init
	if cmdBar then cmdBar.Name = randomString() end
	if chatLogsFrame then chatLogsFrame.Name = randomString() end
	if NAconsoleFrame then NAconsoleFrame.Name = randomString() end
	if commandsFrame then commandsFrame.Name = randomString() end
	if UpdLogsFrame then UpdLogsFrame.Name = randomString() end
	if resizeFrame then resizeFrame.Name = randomString() end
	if description then description.Name = randomString() end
	if ModalFixer then ModalFixer.Name = randomString() end
	if AUTOSCALER then AUTOSCALER.Name = randomString() end
end)

Spawn(bindToDevConsole)
Spawn(loadAliases)
Spawn(loadButtonIDS)
Spawn(RenderUserButtons)
Spawn(loadAutoExec)
Spawn(LoadPlugins)

Spawn(function()
	NACaller(function()
		GaemInfo = MarketplaceService:GetProductInfo(PlaceId)
	end)
end)

Spawn(function()
	NACaller(function()--better saveinstance support
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/SaveInstance.lua"))();
	end)
end)