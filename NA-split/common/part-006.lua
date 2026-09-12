NAmanage.RunUnloadCleanups = function(summary)
	const pending = {}
	for key, record in NAmanage._unloadCleanups do
		if type(record) == "table" and type(record.callback) == "function" then
			pending[#pending + 1] = {
				key = key,
				callback = record.callback,
				priority = tonumber(record.priority) or 0,
			}
		end
	end
	table.sort(pending, function(a, b)
		if a.priority == b.priority then
			return a.key < b.key
		end
		return a.priority > b.priority
	end)
	for i = 1, #pending do
		const ok = pcall(pending[i].callback)
		if ok then
			summary.cleanups += 1
		else
			summary.errors += 1
		end
	end
	table.clear(NAmanage._unloadCleanups)
end

NAmanage.UnloadDisconnectTree = function(root, summary)
	if type(root) ~= "table" then
		return
	end
	const seen = {}
	const currentThread = coroutine.running()
	const function walk(value)
		if type(value) ~= "table" or seen[value] then
			return
		end
		seen[value] = true
		const disconnect = rawget(value, "Disconnect")
		if type(disconnect) == "function" and (rawget(value, "Connected") ~= nil or type(rawget(value, "_conns")) == "table") then
			const ok = pcall(disconnect, value)
			if ok then
				summary.connections += 1
			end
		end
		for key, child in value do
			const kind = typeof(child)
			const kindLower = string.lower(tostring(kind or ""))
			local connectionLike = kindLower:find("connection", 1, true) ~= nil
			if not connectionLike then
				local okDisconnect, disconnectMethod = pcall(function()
					return child and child.Disconnect
				end)
				connectionLike = okDisconnect and type(disconnectMethod) == "function"
			end
			if connectionLike then
				local ok = pcall(function()
					child:Disconnect()
				end)
				if not ok then
					ok = pcall(function()
						if type(child.Disable) == "function" then
							child:Disable()
						end
					end)
				end
				if ok then
					summary.connections += 1
				end
				pcall(function()
					value[key] = nil
				end)
			elseif kind == "thread" and child ~= currentThread and task and type(task.cancel) == "function" then
				const ok = pcall(task.cancel, child)
				if ok then
					summary.threads += 1
				end
				pcall(function()
					value[key] = nil
				end)
			elseif type(child) == "table" then
				walk(child)
			end
		end
	end
	walk(root)
end

NAmanage.UnloadCancelRuntimeTasks = function(runtimeState, summary)
	if type(runtimeState) ~= "table" then
		return
	end
	runtimeState.unloading = true
	const currentThread = coroutine.running()
	const unloadThread = runtimeState.unloadThread
	const pending = {}
	const seen = {}
	const function collect(bucket)
		if type(bucket) ~= "table" then
			return
		end
		for thread in bucket do
			if type(thread) == "thread" and not seen[thread] then
				seen[thread] = true
				pending[#pending + 1] = thread
			end
		end
	end
	collect(runtimeState.waitingThreads)
	collect(runtimeState.spawnActive)
	for i = 1, #pending do
		const thread = pending[i]
		if thread ~= currentThread and thread ~= unloadThread then
			const ok = pcall(task.cancel, thread)
			if ok and summary then
				summary.threads += 1
			end
		end
		if type(runtimeState.waitingThreads) == "table" then
			runtimeState.waitingThreads[thread] = nil
		end
		if type(runtimeState.spawnActive) == "table" then
			runtimeState.spawnActive[thread] = nil
		end
	end
end

NAmanage.UnloadLegacySharedStates = function(summary)
	const targets = {}
	const targetSet = setmetatable({}, { __mode = "k" })
	const function addTarget(target)
		if type(target) == "table" and not targetSet[target] then
			targetSet[target] = true
			targets[#targets + 1] = target
		end
	end
	addTarget(_na_shared)
	addTarget(_na_boot and _na_boot.runtimeEnv and _na_boot.runtimeEnv.shared)
	pcall(function()
		addTarget(shared)
	end)
	const function clearKey(target, key)
		pcall(rawset, target, key, nil)
		pcall(function()
			target[key] = nil
		end)
	end
	const function bump()
		if summary then
			summary.cleanups += 1
		end
	end
	for i = 1, #targets do
		const target = targets[i]
		const permtrip = rawget(target, "__permtrip")
		if type(permtrip) == "table" and type(permtrip.saved) == "table" then
			for hum, was in permtrip.saved do
				if typeof(hum) == "Instance" and hum.Parent then
					pcall(function()
						hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, was)
					end)
				end
			end
			table.clear(permtrip.saved)
			bump()
		end
		clearKey(target, "__permtrip")

		const antitrip = rawget(target, "__antitrip")
		if type(antitrip) == "table" and type(antitrip.saved) == "table" then
			for hum, saved in antitrip.saved do
				if typeof(hum) == "Instance" and hum.Parent and type(saved) == "table" then
					for state, was in saved do
						pcall(function()
							hum:SetStateEnabled(state, was)
						end)
					end
					pcall(function()
						hum.PlatformStand = false
					end)
				end
			end
			table.clear(antitrip.saved)
			bump()
		end
		clearKey(target, "__antitrip")

		const stateLock = rawget(target, "__disablehumanoidstate")
		if type(stateLock) == "table" and type(stateLock.saved) == "table" then
			for hum, saved in stateLock.saved do
				if typeof(hum) == "Instance" and hum.Parent and type(saved) == "table" then
					for state, was in saved do
						pcall(function()
							hum:SetStateEnabled(state, was)
						end)
					end
				end
			end
			table.clear(stateLock.saved)
			bump()
		end
		clearKey(target, "__disablehumanoidstate")

		const antibreak = rawget(target, "__antibreakjoints")
		if type(antibreak) == "table" and type(antibreak.saved) == "table" then
			for hum, old in antibreak.saved do
				if typeof(hum) == "Instance" and hum.Parent and type(old) == "table" then
					if old.bjd ~= nil then
						pcall(function()
							hum.BreakJointsOnDeath = old.bjd
						end)
					end
					if old.dead ~= nil then
						pcall(function()
							hum:SetStateEnabled(Enum.HumanoidStateType.Dead, old.dead)
						end)
					end
				end
			end
			table.clear(antibreak.saved)
			bump()
		end
		clearKey(target, "__antibreakjoints")
	end
end

NAmanage.RemovePlexityGradients = function()
	local core = Services.CoreGui
	if typeof(core) ~= "Instance" then
		pcall(function()
			core = game:GetService("CoreGui")
		end)
	end
	if typeof(core) ~= "Instance" then
		return 0
	end
	local removed = 0
	local okDesc, descendants = pcall(function()
		return core:GetDescendants()
	end)
	if not okDesc or type(descendants) ~= "table" then
		return 0
	end
	for i = 1, #descendants do
		const object = descendants[i]
		if object and object:IsA("UIGradient") then
			local tagged = false
			pcall(function()
				tagged = object:GetAttribute("NamelessAdminPlexity") == true
			end)
			if object.Name == "PlexityGradient" or tagged then
				const ok = pcall(function()
					object:Destroy()
				end)
				if ok then
					removed += 1
				end
			end
		end
	end
	return removed
end

NAmanage.UnloadLegacySignalConnections = function(summary)
	if type(getconnections) ~= "function" then
		return
	end
	const sourceTags = {}
	const storedTags = _na_boot.privateRoot.naSourceTags
	if type(storedTags) == "table" then
		for source, enabled in storedTags do
			if enabled == true and type(source) == "string" and source ~= "" then
				sourceTags[source] = true
			end
		end
	end
	if type(NAmanage._sourceTag) == "string" and NAmanage._sourceTag ~= "" then
		sourceTags[NAmanage._sourceTag] = true
	end
	const signals = {}
	const signalSet = setmetatable({}, { __mode = "k" })
	const function addSignal(signal)
		if signal and not signalSet[signal] then
			signalSet[signal] = true
			signals[#signals + 1] = signal
		end
	end
	local runService = Services.RunService
	if typeof(runService) ~= "Instance" then
		pcall(function()
			runService = game:GetService("RunService")
		end)
	end
	if typeof(runService) == "Instance" then
		for _, key in { "RenderStepped", "PreRender", "Heartbeat", "Stepped", "PreSimulation", "PostSimulation" } do
			pcall(function()
				addSignal(runService[key])
			end)
		end
	end
	local inputService = Services.UserInputService
	if typeof(inputService) ~= "Instance" then
		pcall(function()
			inputService = game:GetService("UserInputService")
		end)
	end
	if typeof(inputService) == "Instance" then
		for _, key in { "InputBegan", "InputChanged", "InputEnded", "JumpRequest", "TextBoxFocused", "TextBoxFocusReleased", "WindowFocused", "WindowFocusReleased" } do
			pcall(function()
				addSignal(inputService[key])
			end)
		end
	end
	local playersService = Services.Players
	if typeof(playersService) ~= "Instance" then
		pcall(function()
			playersService = game:GetService("Players")
		end)
	end
	if typeof(playersService) == "Instance" then
		pcall(function() addSignal(playersService.PlayerAdded) end)
		pcall(function() addSignal(playersService.PlayerRemoving) end)
		const localPlayer = playersService.LocalPlayer
		if localPlayer then
			for _, key in { "CharacterAdded", "CharacterRemoving", "Idled" } do
				pcall(function()
					addSignal(localPlayer[key])
				end)
			end
		end
	end
	for _, container in { Services.Workspace, Services.CoreGui } do
		if typeof(container) == "Instance" then
			for _, key in { "DescendantAdded", "DescendantRemoving", "ChildAdded", "ChildRemoved", "AncestryChanged" } do
				pcall(function()
					addSignal(container[key])
				end)
			end
		end
	end
	const function getFunctionSource(callback)
		local source = ""
		pcall(function()
			source = tostring(debug.info(callback, "s") or "")
		end)
		return source
	end
	const function hasFingerprint(callback)
		if type(getconstants) ~= "function" then
			return false
		end
		local ok, constants = pcall(getconstants, callback)
		if not ok or type(constants) ~= "table" then
			return false
		end
		local hasNAlib, hasNAmanage, hasNAStuff = false, false, false
		local hasNotif, hasFollow, hasMoveTo = false, false, false
		for _, value in constants do
			if value == "NAlib" then
				hasNAlib = true
			elseif value == "NAmanage" then
				hasNAmanage = true
			elseif value == "NAStuff" then
				hasNAStuff = true
			elseif value == "DoNotif" or value == "DebugNotif" then
				hasNotif = true
			elseif value == "follow" then
				hasFollow = true
			elseif value == "MoveTo" then
				hasMoveTo = true
			end
		end
		return hasNAlib and (hasNAmanage or hasNAStuff or hasNotif or (hasFollow and hasMoveTo))
	end
	for i = 1, #signals do
		local ok, connections = pcall(getconnections, signals[i])
		if ok and type(connections) == "table" then
			for _, connection in connections do
				const callback = connection and connection.Function
				if type(callback) == "function" and hasFingerprint(callback) then
					const source = getFunctionSource(callback)
					if source ~= "" then
						sourceTags[source] = true
						_na_boot.privateRoot.naSourceTags[source] = true
					end
				end
			end
		end
	end
	for i = 1, #signals do
		local ok, connections = pcall(getconnections, signals[i])
		if ok and type(connections) == "table" then
			for _, connection in connections do
				const callback = connection and connection.Function
				if type(callback) == "function" and sourceTags[getFunctionSource(callback)] then
					local disconnected = pcall(function()
						connection:Disconnect()
					end)
					if not disconnected then
						disconnected = pcall(function()
							if type(connection.Disable) == "function" then
								connection:Disable()
							end
						end)
					end
					if disconnected and summary then
						summary.connections += 1
					end
				end
			end
		end
	end
end

NAmanage.UnloadLegacyEditorConnections = function(summary)
	if type(getconnections) ~= "function" then
		return
	end
	const sourceTags = {}
	const storedTags = _na_boot.privateRoot.naSourceTags
	if type(storedTags) == "table" then
		for source, enabled in storedTags do
			if enabled == true and type(source) == "string" and source ~= "" then
				sourceTags[source] = true
			end
		end
	end
	if type(NAmanage._sourceTag) == "string" and NAmanage._sourceTag ~= "" then
		sourceTags[NAmanage._sourceTag] = true
	end
	const getUpvalues = debug and debug.getupvalues or getupvalues
	const cornerStates = setmetatable({}, { __mode = "k" })
	const plexStates = setmetatable({}, { __mode = "k" })
	const function getFunctionSource(callback)
		local source = ""
		pcall(function()
			source = tostring(debug.info(callback, "s") or "")
		end)
		return source
	end
	const function collectState(value)
		if type(value) ~= "table" then
			return
		end
		if type(value.data) == "table"
			and type(value.store) == "table"
			and type(value.watchers) == "table"
			and typeof(value.cg) == "Instance"
		then
			cornerStates[value] = true
		end
		if type(value.data) == "table"
			and type(value.images) == "table"
			and type(value.gradients) == "table"
			and type(value.watchers) == "table"
			and typeof(value.cg) == "Instance"
			and type(value.queueToken) == "number"
		then
			plexStates[value] = true
		end
	end
	const function inspectCallback(callback)
		if type(callback) ~= "function" or not sourceTags[getFunctionSource(callback)] then
			return false
		end
		if type(getUpvalues) == "function" then
			local ok, values = pcall(getUpvalues, callback)
			if ok and type(values) == "table" then
				for _, value in values do
					collectState(value)
				end
			end
		end
		return true
	end
	const function scanSignal(signal)
		if not signal then
			return
		end
		local ok, connections = pcall(getconnections, signal)
		if not ok or type(connections) ~= "table" then
			return
		end
		for _, connection in connections do
			if connection and inspectCallback(connection.Function) then
				local disconnected = pcall(function()
					connection:Disconnect()
				end)
				if not disconnected then
					disconnected = pcall(function()
						if type(connection.Disable) == "function" then
							connection:Disable()
						end
					end)
				end
				if disconnected and summary then
					summary.connections += 1
				end
			end
		end
	end
	const roots = {}
	const rootSet = setmetatable({}, { __mode = "k" })
	const function addRoot(root)
		if typeof(root) == "Instance" and not rootSet[root] then
			rootSet[root] = true
			roots[#roots + 1] = root
		end
	end
	addRoot(Services.CoreGui)
	const localPlayer = Services.Players and Services.Players.LocalPlayer
	if localPlayer then
		addRoot(localPlayer:FindFirstChildOfClass("PlayerGui"))
	end
	if NAlib and type(NAlib.distinctHuiGrabber) == "function" then
		local ok, hiddenRoot = pcall(NAlib.distinctHuiGrabber, Services.CoreGui)
		if ok then
			addRoot(hiddenRoot)
		end
	end
	for i = 1, #roots do
		const root = roots[i]
		pcall(function() scanSignal(root.DescendantAdded) end)
		pcall(function() scanSignal(root.DescendantRemoving) end)
		pcall(function() scanSignal(root.ChildAdded) end)
		pcall(function() scanSignal(root.ChildRemoved) end)
		local ok, descendants = pcall(function()
			return root:GetDescendants()
		end)
		if ok and type(descendants) == "table" then
			for j = 1, #descendants do
				const object = descendants[j]
				pcall(function() scanSignal(object.AncestryChanged) end)
				if object:IsA("UICorner") then
					pcall(function() scanSignal(object:GetPropertyChangedSignal("CornerRadius")) end)
				elseif object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
					pcall(function() scanSignal(object:GetPropertyChangedSignal("FontFace")) end)
					pcall(function() scanSignal(object:GetPropertyChangedSignal("Text")) end)
				elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
					pcall(function() scanSignal(object:GetPropertyChangedSignal("Image")) end)
					pcall(function() scanSignal(object:GetPropertyChangedSignal("ImageRectSize")) end)
					pcall(function() scanSignal(object:GetPropertyChangedSignal("AbsoluteSize")) end)
				elseif object:IsA("LayerCollector") or object:IsA("BillboardGui") or object:IsA("SurfaceGui") then
					pcall(function() scanSignal(object.DescendantAdded) end)
					pcall(function() scanSignal(object.DescendantRemoving) end)
				end
			end
		end
	end
	for state in cornerStates do
		pcall(function()
			state.data.enabled = false
			state.restoring = true
		end)
		const stored = {}
		const watched = {}
		const guiRoots = {}
		pcall(function()
			for corner, info in state.store do
				stored[#stored + 1] = { corner = corner, info = info }
			end
		end)
		pcall(function()
			for corner, connections in state.watchers do
				watched[#watched + 1] = { corner = corner, connections = connections }
			end
		end)
		pcall(function()
			for root, connections in state.guiRootWatchers do
				guiRoots[#guiRoots + 1] = { root = root, connections = connections }
			end
		end)
		for i = 1, #watched do
			const connections = watched[i].connections
			if type(connections) == "table" then
				for _, connection in connections do
					pcall(function() connection:Disconnect() end)
				end
			end
		end
		for i = 1, #guiRoots do
			const connections = guiRoots[i].connections
			if type(connections) == "table" then
				for _, connection in connections do
					pcall(function() connection:Disconnect() end)
				end
			end
		end
		for i = 1, #stored do
			const corner = stored[i].corner
			const info = stored[i].info
			if typeof(corner) == "Instance" and corner.Parent and type(info) == "table" and info.original ~= nil then
				pcall(function()
					corner.CornerRadius = info.original
				end)
			end
		end
		pcall(function()
			state.store = setmetatable({}, { __mode = "k" })
			state.watchers = setmetatable({}, { __mode = "k" })
			state.guiRootWatchers = setmetatable({}, { __mode = "k" })
			state.guiRootSeen = setmetatable({}, { __mode = "k" })
			state.restoring = false
		end)
	end
	for state in plexStates do
		pcall(function()
			state.data.enabled = false
			state.queueToken = (tonumber(state.queueToken) or 0) + 1
			state.applyAllSeq = (tonumber(state.applyAllSeq) or 0) + 1
			state.needApplyAll = false
			state.rescanAgain = false
			state.trackedApplyQueued = false
		end)
		pcall(function()
			if type(state.setPlexW) == "function" then
				state.setPlexW(false)
			end
		end)
		const watched = {}
		const gradients = {}
		pcall(function()
			for object, connections in state.watchers do
				watched[#watched + 1] = { object = object, connections = connections }
			end
		end)
		pcall(function()
			for object, gradient in state.gradients do
				gradients[#gradients + 1] = { object = object, gradient = gradient }
			end
		end)
		for i = 1, #watched do
			const connections = watched[i].connections
			if type(connections) == "table" then
				for _, connection in connections do
					pcall(function() connection:Disconnect() end)
				end
			end
		end
		for i = 1, #gradients do
			const gradient = gradients[i].gradient
			if typeof(gradient) == "Instance" then
				pcall(function() gradient:Destroy() end)
			end
		end
		pcall(function()
			state.watchers = setmetatable({}, { __mode = "k" })
			state.images = setmetatable({}, { __mode = "k" })
			state.gradients = setmetatable({}, { __mode = "k" })
			state.queue = {}
			state.queueHead = 1
			state.queueTail = 0
			state.queueSet = setmetatable({}, { __mode = "k" })
			state.recheckQueue = {}
			state.recheckHead = 1
			state.recheckTail = 0
			state.recheckSet = setmetatable({}, { __mode = "k" })
			state.recheckShortQueued = false
			state.recheckLongQueued = false
		end)
	end
end

NAmanage.UnloadRuntimeFlags = function()
	for _, key in { "loopspook", "loopwave", "npcfollowloop", "ISfollowing", "clickVoidEnabled", "clickflingEnabled", "clickscareEnabled", "active" } do
		pcall(function()
			_na_env[key] = false
		end)
	end
	pcall(function()
		_na_env.NA_BPS_Enabled = false
	end)
	const seen = {}
	const function walk(tbl, depth)
		if type(tbl) ~= "table" or seen[tbl] or depth > 6 then
			return
		end
		seen[tbl] = true
		for key, value in tbl do
			if type(key) == "string" and type(value) == "boolean" then
				const lower = string.lower(key)
				if lower:find("enabled", 1, true) or lower:find("active", 1, true) or lower:find("running", 1, true) or lower:find("looping", 1, true) or lower:find("following", 1, true) then
					tbl[key] = false
				end
			elseif type(value) == "table" then
				walk(value, depth + 1)
			end
		end
	end
	walk(NAStuff, 0)
end

NAmanage.Unload = function(opts)
	opts = type(opts) == "table" and opts or {}
	if NAStuff._unloadBusy then
		return false, "Nameless Admin is already unloading."
	end
	NAStuff._unloadBusy = true
	NAStuff._unloading = true
	if type(NAmanage._runtimeState) == "table" then
		NAmanage._runtimeState.unloadThread = coroutine.running()
	end
	const summary = {
		cleanups = 0,
		connections = 0,
		threads = 0,
		instances = 0,
		errors = 0,
	}
	const oldBridge = NAmanage.MCP
	const oldBridgeRun = type(oldBridge) == "table" and oldBridge.run or nil
	const oldUI = NAmanage.getUI and NAmanage.getUI() or nil
	const deadToken = {}
	pcall(function()
		_na_env._NARunToken = deadToken
		_na_shared._NARunToken = deadToken
		_na_boot.runtimeEnv._NARunToken = deadToken
		if type(NAmanage._runtimeState) == "table" then
			NAmanage._runtimeState.runToken = deadToken
			NAmanage._runtimeState.unloading = true
		end
	end)
	const function invoke(name, ...)
		const callback = NAmanage[name]
		if type(callback) ~= "function" then
			return false
		end
		const ok = pcall(callback, ...)
		if ok then
			summary.cleanups += 1
		else
			summary.errors += 1
		end
		return ok
	end
	invoke("FollowUnload")
	invoke("XrayUnload")
	invoke("FontEditorUnload")
	invoke("CornerEditorUnload")
	invoke("PlexityThemeUnload")
	invoke("BuilderIconEditorUnload")
	invoke("cleanupRobloxDevConsoleCopyButtons")
	if type(_na_env.NA_FPS_UNHOOK) == "function" then
		const ok = pcall(_na_env.NA_FPS_UNHOOK)
		if ok then
			summary.cleanups += 1
		else
			summary.errors += 1
		end
	end
	if type(NAgui) == "table" and type(NAgui.ScreenGuiNoRenderSet) == "function" then
		pcall(NAgui.ScreenGuiNoRenderSet, false, { silent = true })
	end
	pcall(function()
		_na_env.NADebugDontRenderKeybindEnabled = false
		if type(NAgui.EnsureScreenGuiNoRenderKeybind) == "function" then
			NAgui.EnsureScreenGuiNoRenderKeybind()
		end
	end)
	pcall(function()
		if type(NAStuff.ATPC) == "table" then
			if type(NAStuff.ATPC.Disable) == "function" then
				NAStuff.ATPC.Disable()
			end
			if typeof(NAStuff.ATPC.gui) == "Instance" then
				NAStuff.ATPC.gui:Destroy()
				summary.instances += 1
			end
			NAStuff.ATPC.gui = nil
			NAStuff.ATPC.btn = nil
		end
	end)
	invoke("AntiBreakRestoreAll")
	NAmanage.UnloadLegacySharedStates(summary)
	NAmanage.UnloadRuntimeFlags()
	NAmanage.UnloadLegacySignalConnections(summary)
	NAmanage.UnloadLegacyEditorConnections(summary)
	invoke("RobloxTopbar_SetEnabled", false)
	invoke("CmdSoftInputStop")
	invoke("Topbar_Destroy")
	invoke("SideSwipe_Destroy")
	invoke("ClickTouchStop")
	invoke("WaypointPathLoopStop", true)
	invoke("StopOffsetWalk", true)
	invoke("WaypointPathStop", true)
	invoke("WaypointPathDestroy", true)
	invoke("WaypointESPDestroy", true)
	invoke("RewindStop", false)
	invoke("wallTpStop", true)
	invoke("God_Disable")
	invoke("ESP_LocatorDisable")
	invoke("ESP_PlayerLocatorDisable")
	invoke("ItemESPDisable")
	invoke("ChatCuteRestore")
	invoke("ClientIdSpoofDisable")
	invoke("HumanoidStateLockStop")
	invoke("HamsterCleanup", { silent = true })
	invoke("setStreamerMode", false, { save = false, silent = true, restoreAsync = false })
	invoke("ESP_ClearAll")
	invoke("PropertyESP_Disable")
	invoke("AntiTouchRestoreState")
	invoke("TargetGuiRestore", NAStuff.TargetGuiHidePrev)
	invoke("TargetGuiRestore", NAStuff.TargetGuiShowPrev)
	invoke("TargetGuiRestore", NAStuff.HideCurrentGuiPrev)
	const function restorePropertyMap(map, property)
		if type(map) ~= "table" then
			return
		end
		for instance, original in map do
			if typeof(instance) == "Instance" and instance.Parent and original ~= nil then
				pcall(function()
					instance[property] = original
				end)
			end
			map[instance] = nil
		end
	end
	restorePropertyMap(NAStuff._ncColl, "CanCollide")
	restorePropertyMap(NAStuff._afOrigCan, "CanCollide")
	restorePropertyMap(NAStuff._afpOrigCan, "CanCollide")
	restorePropertyMap(NAStuff._aaOrig, "Anchored")
	const char = type(getChar) == "function" and getChar() or nil
	const hum = type(getHum) == "function" and getHum(char) or nil
	invoke("FLY_Cleanup", char)
	invoke("AntiNilChar_Restore", char)
	invoke("AntiBreakRestore", hum)
	if char and type(NAmanage.CustomMovementSoundRestore) == "function" then
		const descendants = char:GetDescendants()
		for i = 1, #descendants do
			if descendants[i]:IsA("Sound") then
				pcall(NAmanage.CustomMovementSoundRestore, descendants[i])
			end
		end
	end
	const knownRuns = _na_boot.privateRoot.naRuns
	if type(knownRuns) == "table" then
		for _, record in knownRuns do
			if type(record) == "table" then
				NAmanage.UnloadCancelRuntimeTasks(record.runtimeState, summary)
				const runStuff = record.stuff
				if type(runStuff) == "table" and type(runStuff.conns) == "table" then
					for name, bucket in runStuff.conns do
						if type(bucket) == "table" then
							for _, connection in bucket do
								pcall(function()
									connection:Disconnect()
								end)
							end
						end
						runStuff.conns[name] = nil
					end
				end
				NAmanage.UnloadDisconnectTree(runStuff, summary)
			end
		end
	else
		NAmanage.UnloadCancelRuntimeTasks(NAmanage._runtimeState, summary)
	end
	if type(NAjobs) == "table" and type(NAjobs.stopAll) == "function" then
		const ok = pcall(NAjobs.stopAll)
		if ok then
			summary.cleanups += 1
		else
			summary.errors += 1
		end
	end
	if type(NAgui) == "table" and type(NAgui._menuCleanups) == "table" then
		for key, callback in NAgui._menuCleanups do
			if type(callback) == "function" then
				pcall(callback)
			end
			NAgui._menuCleanups[key] = nil
		end
	end
	NAmanage.RunUnloadCleanups(summary)
	if type(NAStuff.conns) == "table" then
		const names = {}
		for name in NAStuff.conns do
			names[#names + 1] = name
		end
		for i = 1, #names do
			const bucket = NAStuff.conns[names[i]]
			if type(bucket) == "table" then
				summary.connections += #bucket
			end
			NAlib.disconnect(names[i])
		end
	end
	for _, root in { NAStuff, NAjobs, NAmanage._runtimeState, NAgui, NAUIMANAGER, TopBarApp, SideSwipeApp, NAindex } do
		NAmanage.UnloadDisconnectTree(root, summary)
	end
	const roots = {}
	const rootSet = setmetatable({}, { __mode = "k" })
	const function addRoot(instance)
		if typeof(instance) == "Instance" and not rootSet[instance] then
			rootSet[instance] = true
			roots[#roots + 1] = instance
		end
	end
	const function collectInstanceRoots(root)
		const seen = {}
		const function walk(value)
			if type(value) ~= "table" or seen[value] then
				return
			end
			seen[value] = true
			for _, child in value do
				if typeof(child) == "Instance" then
					local ok, ownedUi = pcall(function()
						return child:IsA("LayerCollector") or child:IsA("GuiObject")
					end)
					if ok and ownedUi then
						addRoot(child)
					end
				elseif type(child) == "table" then
					walk(child)
				end
			end
		end
		walk(root)
	end
	addRoot(oldUI)
	addRoot(NAStuff.NASCREENGUI)
	addRoot(rawget(_na_env, "NA_UI_INSTANCE"))
	addRoot(rawget(_na_env, "NA_RAW_UI"))
	addRoot(rawget(_na_shared, "NA_UI_INSTANCE"))
	addRoot(rawget(_na_shared, "NA_RAW_UI"))
	if type(NAmanage.ProtectedInstances) == "table" then
		for instance in NAmanage.ProtectedInstances do
			addRoot(instance)
		end
	end
	for _, root in { NAStuff, NAjobs, NAgui, NAUIMANAGER, TopBarApp, SideSwipeApp, NAindex } do
		collectInstanceRoots(root)
	end
	if type(knownRuns) == "table" then
		for _, record in knownRuns do
			if type(record) == "table" and type(record.stuff) == "table" then
				addRoot(record.stuff.NASCREENGUI)
				collectInstanceRoots(record.stuff)
			end
		end
	end
	const protector = rawget(_na_env, "__NAUIProtector") or rawget(_na_shared, "__NAUIProtector")
	for i = 1, #roots do
		const instance = roots[i]
		pcall(function()
			if instance:IsA("ScreenGui") then
				instance.Enabled = false
			end
		end)
		if type(protector) == "table" and type(protector.cleanup) == "function" then
			pcall(protector.cleanup, instance)
		end
		const ok = pcall(function()
			instance:Destroy()
		end)
		if ok then
			summary.instances += 1
		else
			summary.errors += 1
		end
	end
	if type(protector) == "table" then
		if type(protector.restore) == "function" then
			pcall(protector.restore)
		end
		if type(protector.destroy) == "function" then
			pcall(protector.destroy)
		end
	end
	NAmanage.RemovePlexityGradients()
	const rawDelay = NAmanage._rawTaskDelay or task.delay
	const rawSpawn = NAmanage._rawTaskSpawn or task.spawn
	pcall(rawDelay, 0.1, NAmanage.RemovePlexityGradients)
	pcall(rawDelay, 0.5, NAmanage.RemovePlexityGradients)
	pcall(rawSpawn, function()
		const deadline = os.clock() + 4
		repeat
			NAmanage.RemovePlexityGradients()
			task.wait(0.2)
		until os.clock() >= deadline
		NAmanage.RemovePlexityGradients()
	end)
	if type(knownRuns) == "table" then
		table.clear(knownRuns)
	end
	const clearKeys = {
		"ltseverydayyou_NA",
		"NA_LOADED",
		"NATestingVer",
		"NAverify",
		"NAKey",
		"__NAKeySource",
		"NA_UI_INSTANCE",
		"NA_RAW_UI",
		"NA_UI",
		"NAUILOADEDORSUM",
		"NA_MCP",
		"NamelessAdminMCP",
		"NA_MCP_OPTIONS",
		"_NAStuff",
		"_NAjobs",
		"_NARuntimeState",
		"_NARunToken",
		"_NAXrayState",
		"__NAServiceResolver",
		"__NAUIProtector",
		"__NA_FUNCTION_FIXER_LOADED",
		"__NA_FUNCTION_FIXER_OK",
		"__NA_FUNCTION_FIXER_SOURCE",
		"__NA_FUNCTION_FIXER_CHUNK",
		"NAFreecamKeybindEnabled",
		"NADebugDontRenderKeybindEnabled",
		"NAadminsLol",
		"NA_FPS_ACTIVE",
		"NA_FPS_UNHOOK",
		"NA_BPS_Enabled",
		"NA_BPS_Val",
		"NA_BlockHooked",
		"NA_WSBP_Hooked",
		"npcESPList",
		"__BadgeOwnershipCache",
		"__na_btr_st",
		"BlackholeAttachment",
		"BlackholeTarget",
		"BlackholeActive",
		"Welcome",
		"NamelessWs",
		"NamelessSpeed",
		"NamelessJP",
		"NamelessMaxSlopeAngle",
		"_LState",
		"FullBrightEnabled",
		"FullBrightExecuted",
		"CustomUI",
		"LegacySettings",
		"functionspy",
		"Lzzz",
		"ssss",
		"currentnormal",
		"mainName",
		"testingName",
		"adminName",
	}
	const sandboxOnlyClearKeys = {
		"decompile",
		"disassemble",
		"writefile",
		"readfile",
		"isfile",
		"delfile",
		"gethui",
	}
	const function isNARuntimeEnvironment(target)
		if type(target) ~= "table" then
			return false
		end
		if target == _na_env or target == _na_shared or target == _na_boot.runtimeEnv or target == _na_boot.hostEnv then
			return true
		end
		if rawget(target, "_NAStuff") == NAStuff or rawget(target, "_NAjobs") == NAjobs then
			return true
		end
		if rawget(target, "NA_LOADED") ~= nil or rawget(target, "ltseverydayyou_NA") ~= nil then
			return true
		end
		if rawget(target, "NATestingVer") ~= nil or rawget(target, "__NAKeySource") == "NA testing.lua" then
			return true
		end
		if rawget(target, "NA_MCP") == oldBridge or rawget(target, "NamelessAdminMCP") == oldBridge then
			return true
		end
		return false
	end

	const function clearRuntimeExports()
		const targets = {}
		const targetSet = setmetatable({}, { __mode = "k" })
		const function addTarget(target, force)
			if type(target) ~= "table" or targetSet[target] then
				return
			end
			if force or isNARuntimeEnvironment(target) then
				targetSet[target] = true
				targets[#targets + 1] = target
			end
		end

		addTarget(_na_env, true)
		addTarget(_na_shared, true)
		addTarget(_na_boot.runtimeEnv, true)
		addTarget(_na_boot.hostEnv, true)
		addTarget(_G, true)
		pcall(function()
			if type(shared) == "table" then
				addTarget(shared, true)
			end
		end)
		pcall(function()
			if type(getgenv) == "function" then
				addTarget(getgenv(), true)
			end
		end)
		pcall(function()
			const privateRoot = _na_boot.privateRoot
			if type(privateRoot) == "table" then
				addTarget(rawget(privateRoot, "testing"), true)
				addTarget(rawget(privateRoot, "main"), false)
				addTarget(rawget(privateRoot, "admin"), false)
			end
		end)
		pcall(function()
			if type(getgc) == "function" then
				for _, value in getgc(true) do
					if type(value) == "table" then
						addTarget(value, false)
					end
				end
			end
		end)

		for i = 1, #targets do
			const target = targets[i]
			for j = 1, #clearKeys do
				const key = clearKeys[j]
				const replacement = key == "NAadminsLol" and {} or nil
				pcall(rawset, target, key, replacement)
				pcall(function()
					target[key] = replacement
				end)
			end
			for _, key in { "cmdRun", "RunCommand", "runCommand" } do
				pcall(rawset, target, key, nil)
				pcall(function()
					target[key] = nil
				end)
			end
		end
		for _, target in { _na_env, _na_boot.runtimeEnv } do
			if type(target) == "table" then
				for j = 1, #sandboxOnlyClearKeys do
					pcall(rawset, target, sandboxOnlyClearKeys[j], nil)
					pcall(function()
						target[sandboxOnlyClearKeys[j]] = nil
					end)
				end
			end
		end
	end

	clearRuntimeExports()
	pcall(rawDelay, 0.1, clearRuntimeExports)
	pcall(rawDelay, 0.5, clearRuntimeExports)
	pcall(function()
		NAStuff.NASCREENGUI = nil
		NAStuff.conns = {}
		NAStuff.ProtectedInstanceWatcherRunning = false
		NAStuff._unloading = false
		NAStuff._unloadBusy = false
	end)
	pcall(function()
		if type(NAmanage.ProtectedInstances) == "table" then
			table.clear(NAmanage.ProtectedInstances)
		end
		NAmanage._runtimeState.unloading = true
		if type(_na_boot.privateRoot.naRuns) == "table" then
			_na_boot.privateRoot.naRuns[NAmanage._runToken] = nil
		end
		local anyRuns = false
		if type(_na_boot.privateRoot.naRuns) == "table" then
			for _ in _na_boot.privateRoot.naRuns do
				anyRuns = true
				break
			end
		end
		if not anyRuns then
			_na_boot.privateRoot.naRuns = nil
			_na_boot.privateRoot.naSourceTags = nil
			_na_boot.privateRoot.serviceResolver = nil
			_na_boot.privateRoot.uiProtector = nil
		end
		if rawget(_na_boot.privateRoot, "testing") == _na_env then
			_na_boot.privateRoot.testing = nil
		end
	end)
	return true, summary
end

cmd.add({"unload", "unloadna", "exitna"}, {"unload", "Unload Nameless Admin and clean up its active runtime"}, function()
	if NAStuff._unloadBusy then
		return
	end
	if type(DoNotif) == "function" then
		DoNotif("Unloading Nameless Admin...", 2)
	end
	const unloadDefer = NAmanage._rawTaskDefer or task.defer
	unloadDefer(function()
		NAmanage.Unload()
	end)
end)

cmd.run = function(args)
	const rawArgs = {}
	for i, v in args do
		rawArgs[i] = v
	end

	const function bumpRichPresenceAsync()
		if type(NAmanage.btBump) == "function" then
			Defer(function()
				pcall(NAmanage.btBump)
			end)
		end
	end

	const function sendWebhookAsync(payloadArgs)
		if type(NAmanage.WebhookCommand) == "function" then
			Defer(function()
				pcall(NAmanage.WebhookCommand, payloadArgs)
			end)
		end
	end

	const caller, arguments = args[1], args
	table.remove(args, 1)

	const callerLower = (type(caller) == "string") and caller:lower() or nil
	const shouldRecord = callerLower ~= "lastcommand" and callerLower ~= "lastcmd"
	const routingMode = NAmanage.CmdIntegrationNormalizeMode(NAStuff.CmdIntegrationRoutingMode)
	const iyRoutingMode = NAmanage.IYIntegrationNormalizeMode(NAStuff.IYIntegrationRoutingMode)
	const forcedCmd = callerLower and Sub(callerLower, 1, 4) == "cmd:" or false
	const forcedIY = callerLower and Sub(callerLower, 1, 3) == "iy:" or false

	local success, msg = pcall(function()
		if forcedCmd then
			if NAmanage.tryCmdIntegration(rawArgs, { forced = true }) then
				if shouldRecord then NAmanage.updateLastCommand(rawArgs) end
				sendWebhookAsync(rawArgs)
				return
			end
		elseif forcedIY then
			if NAmanage.tryIYIntegration(rawArgs, { forced = true }) then
				if shouldRecord then NAmanage.updateLastCommand(rawArgs) end
				sendWebhookAsync(rawArgs)
				return
			end
		else
			if routingMode == "Cmd First" and NAmanage.CmdIntegrationHasCommand(callerLower) then
				if NAmanage.tryCmdIntegration(rawArgs) then
					if shouldRecord then NAmanage.updateLastCommand(rawArgs) end
					sendWebhookAsync(rawArgs)
					return
				end
			end
			if iyRoutingMode == "IY First" and NAmanage.IYIntegrationHasCommand(callerLower) then
				if NAmanage.tryIYIntegration(rawArgs) then
					if shouldRecord then NAmanage.updateLastCommand(rawArgs) end
					sendWebhookAsync(rawArgs)
					return
				end
			end
		end
		const command = callerLower and (cmds.Commands[callerLower] or cmds.Aliases[callerLower]) or nil
		if command then
			const depth = tonumber(NAmanage._cmdRunDepth) or 0
			NAmanage._cmdRunDepth = depth + 1
			local okCmd, errCmd = pcall(command[1], unpack(arguments))
			NAmanage._cmdRunDepth = depth
			if not okCmd then
				error(errCmd, 0)
			end
			NAmanage.markCommandDone(rawArgs)
			NAmanage.markCommandUndone(rawArgs)
			bumpRichPresenceAsync()
			if shouldRecord then
				NAmanage.updateLastCommand(rawArgs)
			end
			sendWebhookAsync(rawArgs)
		else
			if not forcedCmd and not forcedIY and routingMode ~= "Explicit Only" and NAmanage.tryCmdIntegration(rawArgs) then
				if shouldRecord then NAmanage.updateLastCommand(rawArgs) end
				sendWebhookAsync(rawArgs)
				return
			end
			if not forcedCmd and not forcedIY and iyRoutingMode ~= "Explicit Only" and NAmanage.tryIYIntegration(rawArgs) then
				if shouldRecord then NAmanage.updateLastCommand(rawArgs) end
				sendWebhookAsync(rawArgs)
				return
			end
			const closest = callerLower and didYouMean(callerLower) or nil
			if closest and doPREDICTION then
				const commandFunc = cmds.Commands[closest] and cmds.Commands[closest][1] or cmds.Aliases[closest] and cmds.Aliases[closest][1]
				const requiresInput = cmds.Commands[closest] and cmds.Commands[closest][3] or cmds.Aliases[closest] and cmds.Aliases[closest][3]

				if requiresInput then
					Window({
						Title = adminName,
						Description = "Command [ "..caller.." ] doesn't exist\nDid you mean [ "..closest.." ]?",
						InputField = true,
						Buttons = {
							{
								Text = "Submit",
								Callback = function(input)
									const parsedArguments = ParseArguments(input)
									if parsedArguments then
										const predictedArguments = {}
										for i, v in parsedArguments do
											predictedArguments[i] = v
										end
										const record = {closest}
										for _, v in predictedArguments do
											record[#record + 1] = v
										end
										SpawnCall(function()
											commandFunc(unpack(predictedArguments))
											NAmanage.btBump()
											if shouldRecord then
												NAmanage.updateLastCommand(record)
											end
										end)
									else
										const record = {closest}
										SpawnCall(function()
											commandFunc()
											NAmanage.btBump()
											if shouldRecord then
												NAmanage.updateLastCommand(record)
											end
										end)
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
									const record = {closest}
									SpawnCall(function()
										commandFunc()
										NAmanage.btBump()
										if shouldRecord then
											NAmanage.updateLastCommand(record)
										end
									end)
								end
							}
						}
					})
				end
			end
		end
	end)

	if not success then warn(adminName.." script error:\n"..msg) end
end

NAmanage.MCPNormalizeArgs = NAmanage.MCPNormalizeArgs or function(...)
	const n = select("#", ...)
	if n == 0 then
		return nil, "no command provided"
	end

	const first = select(1, ...)
	if n == 1 and type(first) == "table" then
		const out = {}
		for i = 1, #first do
			out[#out + 1] = tostring(first[i] or "")
		end
		if #out == 0 then
			return nil, "no command provided"
		end
		return out
	end

	if n == 1 and type(first) == "string" then
		const text = tostring(first or "")
		local out, buf, quote = {}, "", nil
		local i = 1
		while i <= #text do
			const ch = Sub(text, i, i)
			if quote then
				if ch == quote then
					quote = nil
				elseif ch == "\\" and i < #text then
					const nextCh = Sub(text, i + 1, i + 1)
					if nextCh == quote or nextCh == "\\" then
						buf = buf..nextCh
						i += 1
					else
						buf = buf..ch
					end
				else
					buf = buf..ch
				end
			elseif ch == "'" or ch == '"' then
				quote = ch
			elseif ch == " " or ch == "	" then
				if #buf > 0 then
					out[#out + 1] = buf
					buf = ""
				end
			else
				buf = buf..ch
			end
			i += 1
		end
		if #buf > 0 then
			out[#out + 1] = buf
		end
		if #out == 0 then
			return nil, "no command provided"
		end
		return out
	end

	const out = {}
	for i = 1, n do
		out[#out + 1] = tostring(select(i, ...) or "")
	end
	if #out == 0 then
		return nil, "no command provided"
	end
	return out
end

NAmanage.MCPTrim = NAmanage.MCPTrim or function(text)
	text = tostring(text or "")
	text = text:gsub("^%s+", "")
	text = text:gsub("%s+$", "")
	return text
end

NAmanage.MCPSplitSequence = NAmanage.MCPSplitSequence or function(text)
	const steps = {}
	for part in tostring(text or ""):gmatch("[^;\n]+") do
		const step = NAmanage.MCPTrim(part)
		if step ~= "" then
			steps[#steps + 1] = step
		end
	end
	return steps
end

NAmanage.MCPCommandList = function(filter, limit)
	filter = Lower(tostring(filter or ""))
	limit = math.clamp(math.floor(tonumber(limit) or 250), 1, 1000)
	const out = {}
	const aliasesByEntry = {}
	for alias, data in cmds.Aliases or {} do
		if data then
			aliasesByEntry[data] = aliasesByEntry[data] or {}
			aliasesByEntry[data][#aliasesByEntry[data] + 1] = tostring(alias)
		end
	end
	for _, aliases in aliasesByEntry do
		table.sort(aliases)
	end

	const names = {}
	for name in cmds.Commands or {} do
		names[#names + 1] = tostring(name)
	end
	table.sort(names)

	for i = 1, #names do
		const name = names[i]
		const data = cmds.Commands and cmds.Commands[name]
		const info = type(data) == "table" and data[2] or nil
		const title = type(info) == "table" and tostring(info[1] or "") or tostring(info or "")
		const description = type(info) == "table" and tostring(info[2] or "") or ""
		const aliases = aliasesByEntry[data] or {}
		local matches = filter == ""
		if not matches then
			const searchable = Lower(name.." "..title.." "..description.." "..Concat(aliases, " "))
			matches = Find(searchable, filter, 1, true) ~= nil
		end
		if matches then
			out[#out + 1] = {
				name = name,
				title = title,
				description = description,
				requiresArguments = type(data) == "table" and data[3] == true or false,
				aliases = aliases,
			}
			if #out >= limit then
				break
			end
		end
	end
	return out
end

NAmanage.MCPFormatCommand = NAmanage.MCPFormatCommand or function(argv)
	if type(argv) ~= "table" then
		return tostring(argv or "")
	end
	const parts = {}
	for i = 1, #argv do
		local value = tostring(argv[i] or "")
		if value:find("%s") then
			value = '"'..value:gsub('"', '\\"')..'"'
		end
		parts[#parts + 1] = value
	end
	return Concat(parts, " ")
end

NAmanage.MCPCleanText = function(value, maxLength)
	local text = tostring(value or "")
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	maxLength = math.clamp(math.floor(tonumber(maxLength) or 96), 1, 512)
	if #text > maxLength then
		text = text:sub(1, maxLength)
	end
	return text
end

NAmanage.MCPAgentInstructions = "Before using any operational Nameless Admin MCP helper, call identify/handshake and provide your AI provider when known, exact model name, MCP/AI tool, and client application. Never invent an exact model name; report unknown only when the host genuinely does not expose it. In the next user-facing response after identification, explicitly state the model and AI/MCP tool/client connected to Nameless Admin MCP Bridge. After every run, runSequence, or settings mutation, explicitly tell the user which NA MCP helper/command executed and summarize the result."

NAmanage.MCPNormalizeIdentity = function(info)
	if type(info) ~= "table" then
		return nil, "identity must be a table"
	end
	const source = type(info.ai) == "table" and info.ai or info
	const model = NAmanage.MCPCleanText(source.model or source.modelName or source.aiModel, 96)
	const tool = NAmanage.MCPCleanText(source.tool or source.aiTool or source.clientTool or source.mcpTool, 96)
	const client = NAmanage.MCPCleanText(source.client or source.clientName or source.application, 96)
	if model == "" then
		return nil, "AI model is required"
	end
	if tool == "" then
		return nil, "AI tool is required"
	end
	return {
		provider = NAmanage.MCPCleanText(source.provider or source.vendor or source.company, 64),
		model = model,
		tool = tool,
		client = client,
		version = NAmanage.MCPCleanText(source.version or source.clientVersion or source.toolVersion, 48),
		sessionId = NAmanage.MCPCleanText(source.sessionId or source.session or source.conversationId, 96),
		displayName = NAmanage.MCPCleanText(source.displayName or source.name, 96),
		connectedAt = tick(),
	}
end

NAmanage.MCPIdentitySnapshot = function()
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	const identity = type(NAStuff.MCP.identity) == "table" and NAStuff.MCP.identity or nil
	if not identity then
		return nil
	end
	return {
		provider = NAmanage.MCPCleanText(identity.provider, 64),
		model = NAmanage.MCPCleanText(identity.model, 96),
		tool = NAmanage.MCPCleanText(identity.tool, 96),
		client = NAmanage.MCPCleanText(identity.client, 96),
		version = NAmanage.MCPCleanText(identity.version, 48),
		sessionId = NAmanage.MCPCleanText(identity.sessionId, 96),
		displayName = NAmanage.MCPCleanText(identity.displayName, 96),
		connectedAt = identity.connectedAt,
	}
end

NAmanage.MCPIdentityLabel = function(identity)
	identity = type(identity) == "table" and identity or NAmanage.MCPIdentitySnapshot()
	if not identity then
		return ""
	end
	const tool = NAmanage.MCPCleanText(identity.tool ~= "" and identity.tool or identity.client, 96)
	const model = NAmanage.MCPCleanText(identity.model, 96)
	if tool ~= "" and model ~= "" then
		return tool.." | "..model
	elseif model ~= "" then
		return model
	end
	return tool
end

NAmanage.MCPIdentityDisclosure = function(operation, detail, identity)
	identity = type(identity) == "table" and identity or NAmanage.MCPIdentitySnapshot()
	if not identity then
		return nil
	end
	const provider = identity.provider ~= "" and (" by "..identity.provider) or ""
	local action = tostring(operation or "activity")
	if detail and tostring(detail) ~= "" then
		action ..= " ["..tostring(detail).."]"
	end
	return "Nameless Admin MCP Bridge "..action.." used "..identity.tool.." with "..identity.model..provider.."."
end

NAmanage.MCPNotifyActivity = function(action, detail, opts)
	opts = type(opts) == "table" and opts or {}
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	const isRead = opts.read == true
	if NAStuff.MCP.notifyCommands ~= true and opts.force ~= true then
		return false
	end
	if isRead and NAStuff.MCP.notifyReads ~= true and opts.force ~= true then
		return false
	end
	const identity = type(opts.identity) == "table" and opts.identity or NAmanage.MCPIdentitySnapshot()
	const actor = identity and NAmanage.MCPIdentityLabel(identity) or NAmanage.MCPCleanText(opts.actor or NAStuff.MCP.actor, 96)
	const now = os.clock()
	const key = tostring(action or "activity").."|"..tostring(detail or "").."|"..actor
	const lastKey = tostring(NAStuff.MCP._lastNotifyKey or "")
	const lastAt = tonumber(NAStuff.MCP._lastNotifyAt) or 0
	if key == lastKey and now - lastAt < (isRead and 3 or 0.75) and opts.force ~= true then
		NAStuff.MCP._suppressedNotifyCount = (tonumber(NAStuff.MCP._suppressedNotifyCount) or 0) + 1
		return false
	end
	NAStuff.MCP._lastNotifyKey = key
	NAStuff.MCP._lastNotifyAt = now
	const history = type(NAStuff.MCP.history) == "table" and NAStuff.MCP.history or {}
	NAStuff.MCP.history = history
	history[#history + 1] = {
		t = tick(),
		action = tostring(action or "activity"),
		detail = tostring(detail or ""),
		read = isRead,
		actor = actor,
		identity = identity,
		provider = identity and identity.provider or nil,
		model = identity and identity.model or nil,
		tool = identity and identity.tool or nil,
		client = identity and identity.client or nil,
		sessionId = identity and identity.sessionId or nil,
	}
	while #history > 100 do
		table.remove(history, 1)
	end
	if type(DoNotif) ~= "function" then
		return false
	end
	const prefix = actor ~= "" and ("MCP ["..actor.."]") or "MCP"
	local msg = prefix.." "..tostring(action or "activity")
	if detail and tostring(detail) ~= "" then
		msg ..= ": "..tostring(detail)
	end
	const suppressed = tonumber(NAStuff.MCP._suppressedNotifyCount) or 0
	if suppressed > 0 then
		msg ..= " (+"..tostring(suppressed).." repeated)"
		NAStuff.MCP._suppressedNotifyCount = 0
	end
	if #msg > 220 then
		msg = msg:sub(1, 217).."..."
	end
	pcall(DoNotif, msg, opts.duration or (isRead and 1.75 or 2.75), "MCP")
	return true
end

NAmanage.MCPMeta = function(operation, detail, identity)
	identity = type(identity) == "table" and identity or NAmanage.MCPIdentitySnapshot()
	const bridge = type(NAmanage.MCP) == "table" and NAmanage.MCP or {}
	return {
		bridge = tostring(bridge.name or "Nameless Admin MCP Bridge"),
		bridgeVersion = tonumber(bridge.version) or 2,
		protocolVersion = tostring(bridge.protocolVersion or "2.0"),
		operation = tostring(operation or ""),
		detail = detail and tostring(detail) or nil,
		identityRequired = true,
		ai = identity,
		disclosureRequired = identity ~= nil,
		userDisclosure = NAmanage.MCPIdentityDisclosure(operation, detail, identity),
	}
end

NAmanage.MCPAttachMeta = function(payload, operation, detail, identity)
	if type(payload) ~= "table" then
		payload = { ok = true, result = payload }
	end
	const meta = NAmanage.MCPMeta(operation, detail, identity)
	payload.mcp = meta
	if meta.userDisclosure and payload.mustTellUser == nil then
		payload.mustTellUser = meta.userDisclosure
	end
	return payload
end

NAmanage.MCPRequireIdentity = function(operation)
	const identity = NAmanage.MCPIdentitySnapshot()
	if identity then
		return true, identity
	end
	const payload = {
		ok = false,
		code = "MCP_AI_IDENTITY_REQUIRED",
		error = "AI identity required before '"..tostring(operation or "operation").."'. Call identify/handshake with the AI model and MCP tool/client first.",
		requiredAction = "identify",
		requiredFields = { "model", "tool" },
		instructions = NAmanage.MCPAgentInstructions,
		example = {
			provider = "OpenAI",
			model = "<exact model name>",
			tool = "<MCP/AI tool name>",
			client = "<client application>",
		},
	}
	NAmanage.MCPNotifyActivity("blocked "..tostring(operation or "operation"), "AI model/tool identity required", { force = true })
	return false, nil, NAmanage.MCPAttachMeta(payload, operation)
end

NAmanage.InstallMCPBridge = function()
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	if NAStuff.MCP.allowUIAccess == nil then
		NAStuff.MCP.allowUIAccess = false
	end
	if NAStuff.MCP.commandPrediction == nil then
		NAStuff.MCP.commandPrediction = false
	end
	if NAStuff.MCP.notifyCommands == nil then
		NAStuff.MCP.notifyCommands = true
	end
	if NAStuff.MCP.notifyReads == nil then
		NAStuff.MCP.notifyReads = true
	end
	NAStuff.MCP.requireIdentity = true

	const bridge = type(NAmanage.MCP) == "table" and NAmanage.MCP or {}
	NAmanage.MCP = bridge

	bridge.name = "Nameless Admin MCP Bridge"
	bridge.version = 2
	bridge.protocolVersion = "2.0"
	bridge.kind = "nameless-admin"
	bridge.ready = true
	bridge.identityRequired = true
	bridge.requiredIdentityFields = { "model", "tool" }
	bridge.instructions = NAmanage.MCPAgentInstructions
	bridge.helpers = {
		"identify",
		"handshake",
		"hello",
		"whoami",
		"status",
		"manifest",
		"help",
		"run",
		"runSequence",
		"commands",
		"snapshot",
		"basicInfo",
		"logs",
		"ui",
		"activity",
		"options",
		"ping",
		"disconnectAI",
	}
	bridge.capabilities = {
		commandExecution = true,
		commandSequences = true,
		commandDiscovery = true,
		runtimeSnapshot = true,
		basicInfo = true,
		clientLogs = true,
		uiMetadata = true,
		uiInstanceAccess = NAStuff.MCP.allowUIAccess == true,
		activityHistory = true,
		mandatoryAIIdentity = true,
		structuredDisclosure = true,
	}

	bridge.ping = function()
		const identity = NAmanage.MCPIdentitySnapshot()
		return NAmanage.MCPAttachMeta({
			ok = true,
			name = bridge.name,
			version = bridge.version,
			protocolVersion = bridge.protocolVersion,
			kind = bridge.kind,
			adminName = tostring(adminName or "Nameless Admin"),
			testing = _na_env and _na_env.NATestingVer == true or false,
			ready = bridge.ready == true,
			identityRequired = true,
			identified = identity ~= nil,
			requiredIdentityFields = bridge.requiredIdentityFields,
			helpers = bridge.helpers,
			capabilities = bridge.capabilities,
			instructions = bridge.instructions,
			time = os.time and os.time() or nil,
		}, "ping", nil, identity)
	end

	bridge.manifest = function()
		const identity = NAmanage.MCPIdentitySnapshot()
		return NAmanage.MCPAttachMeta({
			ok = true,
			name = bridge.name,
			version = bridge.version,
			protocolVersion = bridge.protocolVersion,
			kind = bridge.kind,
			identityRequired = true,
			requiredIdentityFields = bridge.requiredIdentityFields,
			instructions = bridge.instructions,
			capabilities = bridge.capabilities,
			tools = {
				{ name = "identify", aliases = { "handshake", "hello" }, access = "public", description = "Register AI provider/model/tool/client. Model and tool are mandatory." },
				{ name = "whoami", access = "public", description = "Read the currently registered AI identity." },
				{ name = "status", access = "public", description = "Read bridge readiness, options and identity state." },
				{ name = "ping", access = "public", description = "Read protocol/version, helpers, capabilities and handshake requirements." },
				{ name = "manifest", aliases = { "help" }, access = "public", description = "Describe the bridge contract and available helpers." },
				{ name = "run", access = "identified", description = "Run one exposed Nameless Admin command." },
				{ name = "runSequence", access = "identified", description = "Run semicolon/newline-separated commands, with wait/delay steps." },
				{ name = "commands", access = "identified", description = "Search deterministic command metadata by name, alias, title or description." },
				{ name = "snapshot", access = "identified", description = "Read runtime management and basic-info snapshots." },
				{ name = "basicInfo", access = "identified", description = "Read the compact NA/client information snapshot." },
				{ name = "logs", access = "identified", description = "Read recent client logs using NA log filtering." },
				{ name = "ui", access = "identified", description = "Read UI metadata; Instance access also requires allowUIAccess." },
				{ name = "activity", access = "identified", description = "Read recent MCP actions including AI model/tool attribution." },
				{ name = "options", access = "public-read/identified-write", description = "Read bridge options or mutate supported options after identification." },
				{ name = "disconnectAI", access = "identified", description = "Clear the active AI identity and require a new handshake." },
			},
		}, "manifest", nil, identity)
	end
	bridge.help = bridge.manifest

	bridge.identify = function(info)
		local identity, err = NAmanage.MCPNormalizeIdentity(info)
		if not identity then
			return NAmanage.MCPAttachMeta({
				ok = false,
				code = "MCP_INVALID_AI_IDENTITY",
				error = err,
				requiredFields = { "model", "tool" },
				instructions = bridge.instructions,
			}, "identify")
		end
		NAStuff.MCP.identity = identity
		NAStuff.MCP.actor = NAmanage.MCPIdentityLabel(identity)
		NAmanage.MCPNotifyActivity("AI connected", NAmanage.MCPIdentityLabel(identity), { force = true, identity = identity, duration = 3.5 })
		const provider = identity.provider ~= "" and (" by "..identity.provider) or ""
		const disclosure = "Connected to Nameless Admin MCP Bridge through "..identity.tool.." using "..identity.model..provider.."."
		return NAmanage.MCPAttachMeta({
			ok = true,
			identified = true,
			identity = NAmanage.MCPIdentitySnapshot(),
			disclosureRequired = true,
			userDisclosure = disclosure,
			mustTellUser = disclosure,
			instructions = bridge.instructions,
		}, "identify", NAmanage.MCPIdentityLabel(identity), identity)
	end
	bridge.handshake = bridge.identify
	bridge.hello = bridge.identify

	bridge.whoami = function()
		const identity = NAmanage.MCPIdentitySnapshot()
		return NAmanage.MCPAttachMeta({
			ok = identity ~= nil,
			identified = identity ~= nil,
			identity = identity,
			requiredFields = identity and nil or { "model", "tool" },
			instructions = bridge.instructions,
		}, "whoami", nil, identity)
	end

	bridge.status = function()
		const identity = NAmanage.MCPIdentitySnapshot()
		bridge.capabilities.uiInstanceAccess = NAStuff.MCP.allowUIAccess == true
		return NAmanage.MCPAttachMeta({
			ok = true,
			ready = bridge.ready == true,
			identified = identity ~= nil,
			identity = identity,
			identityRequired = true,
			allowUIAccess = NAStuff.MCP.allowUIAccess == true,
			commandPrediction = NAStuff.MCP.commandPrediction == true,
			notifyCommands = NAStuff.MCP.notifyCommands == true,
			notifyReads = NAStuff.MCP.notifyReads == true,
			helpers = bridge.helpers,
			capabilities = bridge.capabilities,
			instructions = bridge.instructions,
		}, "status", nil, identity)
	end

	bridge.options = function(nextOptions)
		if type(nextOptions) == "table" then
			local allowed, _, denial = NAmanage.MCPRequireIdentity("options")
			if not allowed then
				return denial
			end
			const changed = {}
			for key, value in nextOptions do
				if key == "allowUIAccess" or key == "commandPrediction" or key == "notifyCommands" or key == "notifyReads" then
					NAStuff.MCP[key] = value == true
					changed[#changed + 1] = key.."="..tostring(NAStuff.MCP[key])
				elseif key == "notifyActivity" then
					NAStuff.MCP.notifyCommands = value == true
					changed[#changed + 1] = "notifyCommands="..tostring(NAStuff.MCP.notifyCommands)
				elseif key == "actor" then
					NAStuff.MCP.actor = NAmanage.MCPCleanText(value, 96)
				end
			end
			if #changed > 0 then
				pcall(NAmanage.NASettingsSet, "mcpNotifyActivity", NAStuff.MCP.notifyCommands == true)
				pcall(NAmanage.NASettingsSet, "mcpNotifyReads", NAStuff.MCP.notifyReads == true)
				pcall(NAmanage.NASettingsSet, "mcpAllowUIAccess", NAStuff.MCP.allowUIAccess == true)
				pcall(NAmanage.NASettingsSet, "mcpCommandPrediction", NAStuff.MCP.commandPrediction == true)
				bridge.capabilities.uiInstanceAccess = NAStuff.MCP.allowUIAccess == true
				NAmanage.MCPNotifyActivity("options", Concat(changed, ", "), { duration = 2.5, force = true })
			end
		end
		const identity = NAmanage.MCPIdentitySnapshot()
		return NAmanage.MCPAttachMeta({
			ok = true,
			allowUIAccess = NAStuff.MCP.allowUIAccess == true,
			commandPrediction = NAStuff.MCP.commandPrediction == true,
			notifyCommands = NAStuff.MCP.notifyCommands == true,
			notifyActivity = NAStuff.MCP.notifyCommands == true,
			notifyReads = NAStuff.MCP.notifyReads == true,
			requireIdentity = true,
			identity = identity,
		}, "options", nil, identity)
	end

	bridge.run = function(...)
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("run")
		if not allowed then
			return denial
		end
		local argv, argErr = NAmanage.MCPNormalizeArgs(...)
		if not argv then
			NAmanage.MCPNotifyActivity("rejected command", argErr or "invalid command")
			return NAmanage.MCPAttachMeta({ ok = false, error = argErr or "invalid command" }, "run", nil, identity)
		end
		const commandName = Lower(tostring(argv[1] or ""))
		const commandExists = (cmds.Commands and cmds.Commands[commandName]) or (cmds.Aliases and cmds.Aliases[commandName])
		const formatted = NAmanage.MCPFormatCommand(argv)
		if not commandExists and NAStuff.MCP.commandPrediction ~= true then
			NAmanage.MCPNotifyActivity("rejected command", tostring(argv[1]).." does not exist")
			return NAmanage.MCPAttachMeta({ ok = false, command = argv, error = "Command '"..tostring(argv[1]).."' does not exist." }, "run", formatted, identity)
		end

		const oldPrediction = doPREDICTION
		if NAStuff.MCP.commandPrediction ~= true then
			doPREDICTION = false
		end
		local ok, result = pcall(function()
			return cmd.run(NAmanage.cloneArgsArray(argv))
		end)
		doPREDICTION = oldPrediction

		if not ok then
			NAmanage.MCPNotifyActivity("command error", formatted.." | "..tostring(result))
			return NAmanage.MCPAttachMeta({ ok = false, command = argv, error = tostring(result) }, "run", formatted, identity)
		end
		NAStuff._lastMCPCommand = NAmanage.cloneArgsArray(argv)
		NAmanage.MCPNotifyActivity("ran", formatted, { duration = 2.75 })
		return NAmanage.MCPAttachMeta({ ok = true, command = argv, result = result }, "run", formatted, identity)
	end

	bridge.runSequence = function(text)
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("runSequence")
		if not allowed then
			return denial
		end
		const steps = NAmanage.MCPSplitSequence(text)
		if #steps == 0 then
			NAmanage.MCPNotifyActivity("rejected sequence", "no commands provided")
			return NAmanage.MCPAttachMeta({ ok = false, error = "no commands provided" }, "runSequence", nil, identity)
		end
		NAmanage.MCPNotifyActivity("sequence", tostring(#steps).." step"..(#steps == 1 and "" or "s"), { duration = 2.75 })
		const results = {}
		local allOk = true
		for _, step in steps do
			const waitSeconds = step:lower():match("^wait%s+([%d%.]+)$")
				or step:lower():match("^delay%s+([%d%.]+)$")
			if waitSeconds then
				const seconds = math.max(0, tonumber(waitSeconds) or 0)
				Wait(seconds)
				results[#results + 1] = { ok = true, wait = seconds }
			else
				const result = bridge.run(step)
				results[#results + 1] = result
				if type(result) ~= "table" or result.ok ~= true then
					allOk = false
				end
			end
		end
		return NAmanage.MCPAttachMeta({ ok = allOk, count = #results, results = results }, "runSequence", tostring(#steps).." steps", identity)
	end

	bridge.commands = function(filter, limit)
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("commands")
		if not allowed then
			return denial
		end
		const normalizedFilter = tostring(filter or "")
		const normalizedLimit = math.clamp(math.floor(tonumber(limit) or 250), 1, 1000)
		NAmanage.MCPNotifyActivity("listed commands", (normalizedFilter ~= "" and normalizedFilter or "all").." / "..tostring(normalizedLimit), { read = true })
		const list = NAmanage.MCPCommandList(normalizedFilter, normalizedLimit)
		return NAmanage.MCPAttachMeta({
			ok = true,
			filter = normalizedFilter,
			limit = normalizedLimit,
			count = #list,
			commands = list,
		}, "commands", normalizedFilter ~= "" and normalizedFilter or "all", identity)
	end

	bridge.snapshot = function()
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("snapshot")
		if not allowed then
			return denial
		end
		NAmanage.MCPNotifyActivity("read snapshot", "", { read = true })
		const out = { ok = true }
		if type(NAmanage.GetManagementSnapshot) == "function" then
			out.management = NAmanage.GetManagementSnapshot()
		end
		if type(NAmanage.GetBasicInfoSnapshot) == "function" then
			out.basicInfo = NAmanage.GetBasicInfoSnapshot()
		end
		return NAmanage.MCPAttachMeta(out, "snapshot", nil, identity)
	end

	bridge.basicInfo = function()
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("basicInfo")
		if not allowed then
			return denial
		end
		if type(NAmanage.GetBasicInfoSnapshot) ~= "function" then
			NAmanage.MCPNotifyActivity("basic info error", "unavailable", { read = true })
			return NAmanage.MCPAttachMeta({ ok = false, error = "basic info unavailable" }, "basicInfo", nil, identity)
		end
		NAmanage.MCPNotifyActivity("read basic info", "", { read = true })
		return NAmanage.MCPAttachMeta({ ok = true, basicInfo = NAmanage.GetBasicInfoSnapshot() }, "basicInfo", nil, identity)
	end

	bridge.logs = function(limit, filter)
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("logs")
		if not allowed then
			return denial
		end
		if type(NAmanage.GetRecentClientLogs) ~= "function" then
			NAmanage.MCPNotifyActivity("logs error", "unavailable", { read = true })
			return NAmanage.MCPAttachMeta({ ok = false, error = "client logs unavailable" }, "logs", nil, identity)
		end
		const normalizedLimit = math.clamp(math.floor(tonumber(limit) or 100), 1, 1000)
		const normalizedFilter = tostring(filter or "All")
		NAmanage.MCPNotifyActivity("read logs", normalizedFilter.." / "..tostring(normalizedLimit), { read = true })
		local ok, payload, count = NAmanage.GetRecentClientLogs(normalizedLimit, normalizedFilter)
		return NAmanage.MCPAttachMeta({
			ok = ok == true,
			logs = payload,
			count = count,
			error = ok == true and nil or payload,
		}, "logs", normalizedFilter.." / "..tostring(normalizedLimit), identity)
	end

	bridge.ui = function()
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("ui")
		if not allowed then
			return denial
		end
		NAmanage.MCPNotifyActivity("requested UI", NAStuff.MCP.allowUIAccess == true and "access granted" or "access denied", { read = true })
		const gui = NAmanage.getUI and NAmanage.getUI() or nil
		const info = {
			ok = true,
			hasUI = typeof(gui) == "Instance",
			allowUIAccess = NAStuff.MCP.allowUIAccess == true,
		}
		if typeof(gui) == "Instance" then
			info.name = gui.Name
			info.className = gui.ClassName
			info.enabled = gui.Enabled
			info.parentClassName = gui.Parent and gui.Parent.ClassName or nil
			if NAStuff.MCP.allowUIAccess == true then
				info.instance = gui
			end
		end
		return NAmanage.MCPAttachMeta(info, "ui", NAStuff.MCP.allowUIAccess == true and "instance access enabled" or "metadata only", identity)
	end

	bridge.activity = function(limit)
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("activity")
		if not allowed then
			return denial
		end
		const history = type(NAStuff.MCP) == "table" and type(NAStuff.MCP.history) == "table" and NAStuff.MCP.history or {}
		const maxItems = math.clamp(math.floor(tonumber(limit) or 25), 1, 100)
		const out = {}
		const startIndex = math.max(1, #history - maxItems + 1)
		for i = startIndex, #history do
			const item = history[i]
			if type(item) == "table" then
				out[#out + 1] = {
					t = item.t,
					action = item.action,
					detail = item.detail,
					read = item.read == true,
					actor = item.actor,
					identity = type(item.identity) == "table" and item.identity or nil,
					provider = item.provider,
					model = item.model,
					tool = item.tool,
					client = item.client,
					sessionId = item.sessionId,
				}
			end
		end
		NAmanage.MCPNotifyActivity("read activity", tostring(#out).." item"..(#out == 1 and "" or "s"), { read = true })
		return NAmanage.MCPAttachMeta({ ok = true, activity = out, returned = #out, count = #history }, "activity", tostring(#out).." items", identity)
	end

	bridge.disconnectAI = function()
		local allowed, identity, denial = NAmanage.MCPRequireIdentity("disconnectAI")
		if not allowed then
			return denial
		end
		const label = NAmanage.MCPIdentityLabel(identity)
		const disclosure = "Disconnected "..label.." from Nameless Admin MCP Bridge. A new model/tool handshake is required before further operational access."
		NAmanage.MCPNotifyActivity("AI disconnected", label, { force = true, identity = identity, duration = 3 })
		NAStuff.MCP.identity = nil
		NAStuff.MCP.actor = ""
		const payload = {
			ok = true,
			disconnected = identity,
			identityRequired = true,
			disclosureRequired = true,
			userDisclosure = disclosure,
			mustTellUser = disclosure,
		}
		payload.mcp = {
			bridge = bridge.name,
			bridgeVersion = bridge.version,
			protocolVersion = bridge.protocolVersion,
			operation = "disconnectAI",
			identityRequired = true,
			ai = identity,
			disclosureRequired = true,
			userDisclosure = disclosure,
		}
		return payload
	end

	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" then
			pcall(function()
				target.NA_MCP = bridge
				target.NamelessAdminMCP = bridge
				target.NA_MCP_OPTIONS = NAStuff.MCP
				target.cmdRun = target.cmdRun or bridge.run
				target.RunCommand = target.RunCommand or bridge.run
				target.runCommand = target.runCommand or bridge.run
			end)
		end
	end

	return bridge
end

NAmanage.InstallMCPBridge()

NAmanage._safeLoadQ = {}
NAmanage._safeLoadBusy = false
NAmanage._safeLoadGap = 0.35

NAmanage._safeLoadStart = function()
	if NAmanage._safeLoadBusy then
		return
	end
	NAmanage._safeLoadBusy = true
	Spawn(function()
		while true do
			const job = table.remove(NAmanage._safeLoadQ, 1)
			if not job then
				break
			end

			Wait(job.delay or NAmanage._safeLoadGap)

			local okBody = true
			local body = job.src
			local name = job.chunkName

			if type(job.url) == "string" then
				name = type(name) == "string" and name or ("@"..job.url)
				if type(job.noCache) == "boolean" then
					okBody, body = NAmanage.HttpGet(job.url, { noCache = job.noCache, timeout = 10 })
				else
					okBody, body = NAmanage.HttpGet(job.url, { timeout = 10 })
				end
			else
				name = type(name) == "string" and name or "@NAExternal"
			end

			if not okBody then
				warn(body)
			elseif type(body) ~= "string" or body == "" then
				warn("empty source")
			else
				const loader = loadstring or load
				if type(loader) ~= "function" then
					warn("loadstring unavailable")
				else
					Wait()
					local fn, lerr = loader(body, name)
					body = nil
					job.src = nil
					if type(fn) ~= "function" then
						warn(tostring(lerr or "compile error"))
					else
						if type(job.env) == "table" then
							pcall(setfenv, fn, job.env)
						end
						Wait()
						const args = job.args or {}
						const n = job.n or 0
						const results = table.pack(pcall(fn, Unpack(args, 1, n)))
						if not results[1] then
							warn(results[2])
						elseif type(job.onReturn) == "function" then
							local okAfter, errAfter = pcall(job.onReturn, Unpack(results, 2, results.n))
							if not okAfter then
								warn(errAfter)
							end
						end
					end
				end
			end

			Wait(NAmanage._safeLoadGap)
		end
		NAmanage._safeLoadBusy = false
		if #NAmanage._safeLoadQ > 0 then
			NAmanage._safeLoadStart()
		end
	end)
end

NAmanage.RunSource = function(src, chunkName, ...)
	if type(src) ~= "string" or src == "" then
		return false, "empty source"
	end
	const delayTime = ((tonumber(NAmanage._cmdRunDepth) or 0) > 0) and 0.85 or 0.35
	Insert(NAmanage._safeLoadQ, {
		src = src,
		chunkName = chunkName,
		args = {...},
		n = select("#", ...),
		delay = delayTime,
	})
	NAmanage._safeLoadStart()
	return true
end

NAmanage.RunSourceInEnv = function(src, chunkName, env, onReturn, ...)
	if type(src) ~= "string" or src == "" then
		return false, "empty source"
	end
	const delayTime = ((tonumber(NAmanage._cmdRunDepth) or 0) > 0) and 0.85 or 0.35
	Insert(NAmanage._safeLoadQ, {
		src = src,
		chunkName = chunkName,
		args = {...},
		n = select("#", ...),
		delay = delayTime,
		env = type(env) == "table" and env or nil,
		onReturn = type(onReturn) == "function" and onReturn or nil,
	})
	NAmanage._safeLoadStart()
	return true
end

NAmanage.RunURL = function(url, noCache, chunkName)
	if type(url) ~= "string" or url == "" then
		return false, "empty url"
	end
	if type(noCache) ~= "boolean" then
		chunkName = noCache
		noCache = nil
	end
	const delayTime = ((tonumber(NAmanage._cmdRunDepth) or 0) > 0) and 0.85 or 0.35
	Insert(NAmanage._safeLoadQ, {
		url = url,
		noCache = noCache,
		chunkName = chunkName,
		delay = delayTime,
	})
	NAmanage._safeLoadStart()
	return true
end

NAmanage.RawCompile = function(src, chunkName)
	if type(src) ~= "string" or src == "" then
		return nil, "empty source"
	end
	const loader = type(_na_boot.hostLoadstring) == "function" and _na_boot.hostLoadstring
		or (type(_na_boot.hostLoad) == "function" and _na_boot.hostLoad or nil)
	if type(loader) ~= "function" then
		return nil, "loadstring unavailable"
	end
	local fn, loadErr = loader(src, chunkName)
	if type(fn) ~= "function" then
		return nil, loadErr
	end
	if type(_na_boot.hostSetfenv) == "function" and type(_na_boot.hostEnv) == "table" then
		local okEnv, envErr = pcall(_na_boot.hostSetfenv, fn, _na_boot.hostEnv)
		if not okEnv then
			return nil, tostring(envErr or "failed to restore executor environment")
		end
	end
	return fn
end

NAmanage.RunLoopSource = function(src, chunkName, ...)
	if type(src) ~= "string" or src == "" then
		return false, "empty source"
	end

	const loopData = NAmanage._loopDispatchData
	if type(loopData) ~= "table" or loopData.running ~= true then
		return NAmanage.RunSource(src, chunkName, ...)
	end
	if loopData._loadstringBusy == true then
		return true
	end

	local fn = loopData._loadstringFunction
	if loopData._loadstringSource ~= src or type(fn) ~= "function" then
		const loader = type(loadstring) == "function" and loadstring or load
		if type(loader) ~= "function" then
			return false, "loadstring unavailable"
		end
		local compileError
		fn, compileError = loader(src, chunkName)
		if type(fn) ~= "function" then
			return false, compileError or "loadstring unavailable"
		end
		loopData._loadstringSource = src
		loopData._loadstringChunkName = chunkName
		loopData._loadstringFunction = fn
	end

	loopData._loadstringBusy = true
	const args = table.pack(...)
	Spawn(function()
		local ok, err = pcall(fn, Unpack(args, 1, args.n))
		loopData._loadstringBusy = false
		if not ok and loopData.running == true then
			warn("[NA] command-loop loadstring failed: "..tostring(err))
		end
	end)
	return true
end

NAStuff.ScriptCatalogUrl = "https://ltseverydayyou.github.io/scripts/catalog.json"
NAStuff.ScriptCatalogState = type(NAStuff.ScriptCatalogState) == "table" and NAStuff.ScriptCatalogState or {
	entries = nil;
	notified = {};
}
NAStuff.ScriptCatalogState.notified = type(NAStuff.ScriptCatalogState.notified) == "table" and NAStuff.ScriptCatalogState.notified or {}

NAmanage.ScriptCatalogHasId = function(ids, wanted)
	if type(ids) ~= "table" then
		return false
	end
	wanted = tostring(wanted or "")
	if wanted == "" then
		return false
	end
	for _, id in ids do
		if tostring(id) == wanted then
			return true
		end
	end
	return false
end

NAmanage.FetchScriptCatalog = function(opts)
	opts = type(opts) == "table" and opts or {}
	const state = NAStuff.ScriptCatalogState
	if opts.refresh ~= true and type(state.entries) == "table" then
		return true, state.entries
	end

	const cacheMinute = math.floor(os.time() / 60)
	const url = NAStuff.ScriptCatalogUrl.."?_na="..tostring(cacheMinute)
	local okFetch, body, fetchErr = NAmanage.HttpGet(url, {
		maxAttempts = 3;
		timeout = 8;
		Headers = {
			Accept = "application/json";
			["Cache-Control"] = "no-cache";
		};
	})
	if not okFetch or type(body) ~= "string" or body == "" then
		return false, tostring(fetchErr or "catalog request failed")
	end

	local okDecode, catalog = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
	if not okDecode or type(catalog) ~= "table" or catalog.schemaVersion ~= 1 or type(catalog.scripts) ~= "table" then
		return false, "invalid catalog response"
	end

	const entries = {}
	for _, entry in catalog.scripts do
		if type(entry) == "table"
			and type(entry.id) == "string"
			and type(entry.name) == "string"
			and type(entry.scriptUrl) == "string"
			and entry.status == "supported" then
			Insert(entries, entry)
		end
	end
	state.entries = entries
	state.loadedAt = os.time()
	return true, entries
end

NAmanage.GetSupportedGameScripts = function(entries)
	entries = type(entries) == "table" and entries or NAStuff.ScriptCatalogState.entries
	if type(entries) ~= "table" then
		return {}
	end

	const gameId = tostring((game and game.GameId) or GameId or "")
	const placeId = tostring((game and game.PlaceId) or PlaceId or "")
	const matches = {}
	for _, entry in entries do
		if NAmanage.ScriptCatalogHasId(entry.universeIds, gameId) then
			Insert(matches, entry)
		end
	end
	if #matches == 0 then
		for _, entry in entries do
			if NAmanage.ScriptCatalogHasId(entry.placeIds, placeId) then
				Insert(matches, entry)
			end
		end
	end
	table.sort(matches, function(a, b)
		return Lower(a.name) < Lower(b.name)
	end)
	return matches
end

NAmanage.ShowSupportedGameScripts = function(opts)
	opts = type(opts) == "table" and opts or {}
	local okCatalog, entriesOrErr = NAmanage.FetchScriptCatalog({ refresh = opts.refresh == true })
	if not okCatalog then
		DoNotif("Could not load the script catalog: "..tostring(entriesOrErr), 5, "Supported Game Scripts")
		return false
	end

	const matches = NAmanage.GetSupportedGameScripts(entriesOrErr)
	if #matches == 0 then
		DoNotif("No supported scripts are listed for this game.", 4, "Supported Game Scripts")
		return false
	end

	const buttons = {}
	for _, entry in matches do
		const selectedEntry = entry
		Insert(buttons, {
			Text = selectedEntry.name;
			Callback = function()
				local okRun, runErr = NAmanage.RunURL(selectedEntry.scriptUrl, true, "@NA-Catalog/"..selectedEntry.id)
				if okRun then
					DoNotif("Queued "..selectedEntry.name..".", 3, "Supported Game Scripts")
				else
					DoNotif("Could not run "..selectedEntry.name..": "..tostring(runErr), 5, "Supported Game Scripts")
				end
			end;
		})
	end

	Window({
		Title = "Supported Game Scripts";
		Description = Format("%d supported %s available for this game. Select one to run it.", #matches, #matches == 1 and "script is" or "scripts are");
		Buttons = buttons;
	})
	return true, matches
end

NAmanage.NotifySupportedGameScripts = function(opts)
	opts = type(opts) == "table" and opts or {}
	if NAmanage.jlCfg and NAmanage.jlCfg.SupportedGameNotif == false and opts.force ~= true then
		return false
	end

	local okCatalog, entriesOrErr = NAmanage.FetchScriptCatalog({ refresh = opts.refresh == true })
	if not okCatalog then
		return false, entriesOrErr
	end
	const matches = NAmanage.GetSupportedGameScripts(entriesOrErr)
	if #matches == 0 then
		return false, "no matches"
	end

	const state = NAStuff.ScriptCatalogState
	const gameKey = tostring((game and game.GameId) or GameId or "")..":"..tostring((game and game.PlaceId) or PlaceId or "")
	if opts.force ~= true and state.notified[gameKey] then
		return false, "already notified"
	end
	state.notified[gameKey] = true

	const names = {}
	for index = 1, math.min(#matches, 3) do
		Insert(names, matches[index].name)
	end
	local description = Concat(names, ", ")
	if #matches > #names then
		description ..= Format(" and %d more", #matches - #names)
	end
	description = Format("%d supported %s available: %s", #matches, #matches == 1 and "script is" or "scripts are", description)

	DoNotif({
		Title = "Supported Game Scripts";
		Description = description;
		Duration = 10;
		Buttons = {
			{
				Text = "View Scripts";
				Callback = function()
					NAmanage.ShowSupportedGameScripts()
				end;
			};
		};
	})
	return true, matches
end

NAmanage.ExecutorScriptsSanitizeName = function(name)
	name = tostring(name or "")
	name = name:gsub('[\\/:*?"<>|]', "")
	name = name:gsub("%s+", " ")
	name = name:gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		return ""
	end
	if not name:lower():match("%.lua$") and not name:lower():match("%.luau$") and not name:lower():match("%.txt$") then
		name ..= ".luau"
	end
	return name
end

NAmanage.ExecutorScriptsStripExt = function(name)
	return tostring(name or ""):gsub("%.luau$", ""):gsub("%.lua$", ""):gsub("%.txt$", "")
end

NAmanage.ExecutorScriptsBase = function()
	const base = "Nameless-Admin/NA-Exec"
	return base, base.."/Scripts", base.."/scripts.json"
end

NAmanage.ExecutorScriptsReadIndex = function()
	const out = {}
	local _, _, idx = NAmanage.ExecutorScriptsBase()
	if not (type(isfile) == "function" and type(readfile) == "function" and isfile(idx)) then
		return out
	end
	local ok, raw = pcall(readfile, idx)
	if not ok or type(raw) ~= "string" or raw == "" then
		return out
	end
	local okDec, dec = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if okDec and type(dec) == "table" then
		for _, name in dec do
			if type(name) == "string" and name ~= "" then
				out[#out + 1] = NAmanage.ExecutorScriptsSanitizeName(name)
			end
		end
	end
	return out
end

NAmanage.ExecutorScriptsList = function()
	local _, dir = NAmanage.ExecutorScriptsBase()
	const out = {}
	const seen = {}
	const function push(name, fromDisk)
		if type(name) ~= "string" then
			return
		end
		name = NAmanage.ExecutorScriptsSanitizeName(name:match("([^/\\]+)$") or name)
		if name == "" then
			return
		end
		if fromDisk ~= true and type(isfile) == "function" and not isfile(dir.."/"..name) then
			return
		end
		const low = name:lower()
		if seen[low] then
			return
		end
		seen[low] = true
		out[#out + 1] = name
	end
	if type(listfiles) == "function" then
		local ok, files = pcall(listfiles, dir)
		if ok and type(files) == "table" then
			for _, file in files do
				push(file, true)
			end
		end
	end
	for _, name in NAmanage.ExecutorScriptsReadIndex() do
		push(name, false)
	end
	table.sort(out, function(a, b)
		return a:lower() < b:lower()
	end)
	return out
end

NAmanage.ExecutorScriptsResolve = function(name)
	name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		return nil
	end
	const want = NAmanage.ExecutorScriptsSanitizeName(name)
	const low = want:lower()
	const bare = NAmanage.ExecutorScriptsStripExt(want):lower()
	local _, dir = NAmanage.ExecutorScriptsBase()
	const direct = dir.."/"..want
	if type(isfile) == "function" and isfile(direct) then
		return want, direct
	end
	for _, file in NAmanage.ExecutorScriptsList() do
		const fLow = file:lower()
		const fBare = NAmanage.ExecutorScriptsStripExt(file):lower()
		if fLow == low or fBare == bare then
			return file, dir.."/"..file
		end
	end
	return nil
end

NAmanage.RunExecutorSavedScript = function(name)
	if type(readfile) ~= "function" or type(isfile) ~= "function" then
		return false, "filesystem unavailable"
	end
	local file, path = NAmanage.ExecutorScriptsResolve(name)
	if not file or not path then
		return false, "saved script not found: "..tostring(name)
	end
	local ok, src = pcall(readfile, path)
	if not ok or type(src) ~= "string" or src == "" then
		return false, "could not read saved script: "..tostring(file)
	end
	local okRun, errRun = NAmanage.RunSource(src, "@NA-Exec/Scripts/"..file)
	if okRun then
		DoNotif("Running saved script: "..file, 2)
		return true, file
	end
	return false, errRun or "failed to run saved script"
end

NAmanage.SanitizeLoopMethod = function(method)
	local value = type(method) == "string" and method or tostring(method or "")
	value = value:match("^%s*(.-)%s*$") or value
	const key = value:lower():gsub("[%s_%-]", "")
	if key == "postsimulation" then
		return "PostSimulation"
	elseif key == "presimulation" then
		return "PreSimulation"
	elseif key == "renderstepped" then
		return "RenderStepped"
	elseif key == "heartbeat" then
		return "Heartbeat"
	end
	return "PostSimulation"
end

NAmanage.GetLoopSignal = function(method)
	const picked = NAmanage.SanitizeLoopMethod(method or NAStuff.LoopMethod)
	const sig = Services.RunService and Services.RunService[picked]
	if sig and type(sig.Connect) == "function" then
		return sig, picked
	end
	const fallbacks = { "PostSimulation", "Heartbeat", "PreSimulation", "RenderStepped" }
	for i = 1, #fallbacks do
		const name = fallbacks[i]
		const fallback = Services.RunService and Services.RunService[name]
		if fallback and type(fallback.Connect) == "function" then
			return fallback, name
		end
	end
	return nil, picked
end

NAmanage.GetLoopDt = function(...)
	const n = select("#", ...)
	for i = n, 1, -1 do
		const v = select(i, ...)
		if type(v) == "number" then
			return v
		end
	end
	return 0
end

NAmanage._runLoopCommand = function(loopKey, loopData)
	if type(loopData) ~= "table" or type(loopData.command) ~= "function" then
		return false, "Loop command is unavailable."
	end

	local previousDepth = tonumber(NAmanage._loopDispatchDepth) or 0
	local previousKey = NAmanage._loopDispatchKey
	local previousData = NAmanage._loopDispatchData
	NAmanage._loopDispatchDepth = previousDepth + 1
	NAmanage._loopDispatchKey = loopKey
	NAmanage._loopDispatchData = loopData

	local ok, err = pcall(function()
		loopData.command(Unpack(loopData.args or {}))
	end)

	NAmanage._loopDispatchDepth = previousDepth > 0 and previousDepth or nil
	NAmanage._loopDispatchKey = previousKey
	NAmanage._loopDispatchData = previousData
	return ok, err
end

NAmanage.ConnectLoop = function(loopKey)
	const loopData = Loops and Loops[loopKey]
	if not loopData then
		return false, "Loop not found."
	end
	const connKey = loopData.key or ("loop::"..loopKey)
	loopData.key = connKey
	NAlib.disconnect(connKey)
	local sig, method = NAmanage.GetLoopSignal(loopData.method or NAStuff.LoopMethod)
	if not sig then
		return false, "Loop signal is unavailable."
	end
	loopData.method = method
	local acc = 0
	NAlib.connect(connKey, sig:Connect(function(...)
		const currentLoop = Loops[loopKey]
		if not currentLoop or not currentLoop.running then
			NAlib.disconnect(connKey)
			return
		end
		if currentLoop.interval <= 0 then
			NAmanage._runLoopCommand(loopKey, currentLoop)
			return
		end
		acc += NAmanage.GetLoopDt(...)
		if acc >= currentLoop.interval then
			acc %= currentLoop.interval
			NAmanage._runLoopCommand(loopKey, currentLoop)
		end
	end))
	return true, method
end

NAmanage.RebindLoops = function()
	if type(Loops) ~= "table" then
		return
	end
	for loopKey, loopData in Loops do
		if loopData and loopData.running then
			NAmanage.ConnectLoop(loopKey)
		end
	end
end

NAmanage.SetLoopMethod = function(method, opts)
	const picked = NAmanage.SanitizeLoopMethod(method)
	NAStuff.LoopMethod = picked
	if type(Loops) == "table" and (not opts or opts.updateRunning ~= false) then
		for _, loopData in Loops do
			if type(loopData) == "table" then
				loopData.method = picked
			end
		end
	end
	if not opts or opts.save ~= false then
		pcall(NAmanage.NASettingsSet, "loopMethod", picked)
	end
	if not opts or opts.rebind ~= false then
		NAmanage.RebindLoops()
	end
	return picked
end

NAmanage.GetAutoFireDefaultMethod = function(kind)
	if kind == "remote" then
		return NAmanage.SanitizeLoopMethod(NAStuff.AutoFireRemoteMethod or NAStuff.AutoInteractMethod or NAStuff.LoopMethod or "PostSimulation")
	end
	return NAmanage.SanitizeLoopMethod(NAStuff.AutoInteractMethod or NAStuff.LoopMethod or "PostSimulation")
end

NAmanage.SetAutoFireDefaultMethod = function(kind, method, opts)
	const picked = NAmanage.SanitizeLoopMethod(method)
	const isRemote = kind == "remote"
	if isRemote then
		NAStuff.AutoFireRemoteMethod = picked
	else
		NAStuff.AutoInteractMethod = picked
	end
	if type(NAjobs) == "table" and type(NAjobs.jobs) == "table" and (not opts or opts.updateRunning ~= false) then
		for _, job in NAjobs.jobs do
			if job and ((isRemote and job.kind == "remote") or ((not isRemote) and (job.kind == "prompt" or job.kind == "click" or job.kind == "touch"))) then
				job.method = picked
				job.next = time()
			end
		end
	end
	if not opts or opts.save ~= false then
		pcall(NAmanage.NASettingsSet, isRemote and "autoFireRemoteMethod" or "autoInteractMethod", picked)
	end
	if type(NAjobs) == "table" and type(NAjobs._reschedule) == "function" and (not opts or opts.rebind ~= false) then
		NAjobs._reschedule()
	end
	return picked
end

NAStuff.LoopMethodOptions = NAStuff.LoopMethodOptions or { "PostSimulation", "PreSimulation", "RenderStepped", "Heartbeat" }
NAStuff.LoopMethod = NAmanage.SanitizeLoopMethod(NAStuff.LoopMethod or "PostSimulation")
NAStuff.AutoInteractMethod = NAmanage.GetAutoFireDefaultMethod("prompt")
NAStuff.AutoFireRemoteMethod = NAmanage.GetAutoFireDefaultMethod("remote")

NAmanage.FmtLoop = function(args)
	if not args or #args == 0 then
		return "(no args)"
	end
	return Concat(args, ", ")
end

NAmanage.LoopKey = function(name, args)
	const loopArgs = type(args) == "table" and args or {}
	return Lower(tostring(name or "")).." "..Concat(loopArgs, " ")
end

NAmanage.StartLoop = function(cmdName, args, interval, method)
	if type(cmdName) ~= "string" or cmdName == "" then
		return false, "Command name is required."
	end

	const command = cmds.Commands[cmdName:lower()] or cmds.Aliases[cmdName:lower()]
	if not command then
		return false, "Command '"..cmdName.."' does not exist."
	end

	interval = tonumber(interval)
	if not interval then
		return false, "Loop delay must be a number."
	end
	if interval < 0 then
		return false, "Invalid delay. Loop not started."
	end

	const loopArgs = type(args) == "table" and args or {}
	const loopKey = NAmanage.LoopKey(cmdName, loopArgs)
	if Loops[loopKey] then
		return false, "A loop with these arguments is already running for '"..cmdName.."'."
	end

	const connKey = "loop::"..loopKey
	NAlib.disconnect(connKey)

	const loopData = {
		commandName = cmdName,
		command = command[1],
		args = loopArgs,
		interval = interval,
		running = true,
		key = connKey,
		method = NAmanage.SanitizeLoopMethod(method or NAStuff.LoopMethod),
	}

	Loops[loopKey] = loopData

	NAmanage._runLoopCommand(loopKey, loopData)

	local ok, msg = NAmanage.ConnectLoop(loopKey)
	if not ok then
		Loops[loopKey] = nil
		return false, msg or "Loop signal is unavailable."
	end

	return true, loopKey, loopData
end

NAmanage.StopLoop = function(loopKey)
	const loopData = Loops[loopKey]
	if not loopData then
		return false, "Loop not found."
	end

	loopData.running = false
	if loopData.key then
		NAlib.disconnect(loopData.key)
	end
	Loops[loopKey] = nil

	return true, loopData
end

NAmanage.GetLoops = function()
	const entries = {}
	for loopKey, loopData in Loops do
		const status = loopData.running == true and "Running" or "Paused"
		Insert(entries, {
			key = loopKey,
			data = loopData,
			label = Format("[%s] '%s' | Args: %s | Delay: %ss | Method: %s", status, loopData.commandName, NAmanage.FmtLoop(loopData.args), loopData.interval, loopData.method or NAmanage.SanitizeLoopMethod(NAStuff.LoopMethod)),
		})
	end
	table.sort(entries, function(a, b)
		return tostring(a.label) < tostring(b.label)
	end)
	return entries
end

cmd.loop = function(commandName, args)
	if type(commandName) ~= "string" or commandName == "" then
		DoNotif("Command name is required.", 3)
		return
	end

	local selectedMethod = NAmanage.SanitizeLoopMethod(NAStuff.LoopMethod or "PostSimulation")

	Window({
		Title = "Set Loop Delay",
		Description = "Enter the delay (in seconds) for the loop of command: "..commandName.."\nSpam mode: "..selectedMethod,
		InputField = true,
		Dropdowns = {
			{
				Name = "Spam Mode",
				Options = NAStuff.LoopMethodOptions or { "PostSimulation", "PreSimulation", "RenderStepped", "Heartbeat" },
				CurrentOption = selectedMethod,
				Callback = function(selection)
					selectedMethod = NAmanage.SanitizeLoopMethod(NAmanage.getDDTxt and NAmanage.getDDTxt(selection) or selection)
				end
			}
		},
		Buttons = {
			{
				Text = "Submit",
				Callback = function(input)
					Spawn(function()
						const picked = NAmanage.SanitizeLoopMethod(selectedMethod)
						local ok, result, loopData = NAmanage.StartLoop(commandName, args, tonumber(input) or 0, picked)
						if not ok then
							DoNotif(result, 3)
							return
						end
						DoNotif("Loop started for '"..commandName.."' with delay: "..loopData.interval.."s. Method: "..(loopData.method or picked)..". Args: "..NAmanage.FmtLoop(loopData.args), 3)
					end)
				end
			}
		}
	})
end

cmd.stopLoop = function()
	const loopEnts = NAmanage.GetLoops()
	if #loopEnts == 0 then
		DoNotif("No active loops to stop.", 2)
		return
	end

	const buttons = {}
	for i = 1, #loopEnts do
		const entry = loopEnts[i]
		Insert(buttons, {
			Text = entry.label,
			Callback = function()
				local ok, loopData = NAmanage.StopLoop(entry.key)
				if not ok then
					DoNotif(loopData, 2)
					return
				end
				DoNotif("Stopped loop: '"..loopData.commandName.."' with args: "..NAmanage.FmtLoop(loopData.args), 3)
			end
		})
	end

	Window({
		Title = "Stop a Loop",
		Description = "Select a loop to stop:",
		Buttons = buttons
	})
end

--[[ LIBRARY FUNCTIONS ]]--
NAlib.wrap=function(f)
	return NAmanage.Wrap(function(call)
		if not NAmanage.IsActiveRun(call.token) then
			return
		end
		return call.func()
	end)({
		token = NAmanage._runToken,
		func = f,
	})
end

wrap=NAlib.wrap

function rngMsg()
	return msg[math.random(1,#msg)]
end

function MouseButtonFix(button, clickCallback)
	if not button or type(clickCallback) ~= "function" then
		return { Connected = false, Disconnect = function() end }
	end

	const clickTimeThreshold = 0.45
	const moveThreshold = 10

	local mouseDownTime = 0
	local isPointerDown = false
	local startPosition = nil
	local maxMoveDistance = 0
	const connections = {}
	local disconnected = false
	NAStuff._mouseButtonFixHooks = NAmanage.ensureWeakKeyTable(NAStuff._mouseButtonFixHooks)
	const hooks = NAStuff._mouseButtonFixHooks
	const existing = hooks[button]
	if existing then
		NAmanage.tryDisconnect(existing)
	end

	const state = {
		Connected = true,
	}

	const function disconnectAll()
		if disconnected then
			return
		end
		disconnected = true
		state.Connected = false
		for i = 1, #connections do
			NAmanage.tryDisconnect(connections[i])
			connections[i] = nil
		end
		if hooks[button] == state then
			hooks[button] = nil
		end
	end

	function state:Disconnect()
		disconnectAll()
	end

	hooks[button] = state

	const function getSignal(obj, signalName)
		local ok, signal = pcall(function()
			return obj[signalName]
		end)
		if ok and signal then
			return signal
		end
		return nil
	end

	const function connectSignal(signal, fn)
		if disconnected or not signal then
			return false
		end
		local ok, conn = pcall(function()
			return signal:Connect(fn)
		end)
		if ok and conn then
			connections[#connections + 1] = conn
			return true
		end
		return false
	end

	const function isPressInput(inputType)
		return inputType == Enum.UserInputType.MouseButton1
			or inputType == Enum.UserInputType.Touch
	end

	const function resetState()
		mouseDownTime = 0
		isPointerDown = false
		startPosition = nil
		maxMoveDistance = 0
	end

	const function beginPointer(input)
		if disconnected then
			return
		end
		isPointerDown = true
		mouseDownTime = tick()
		maxMoveDistance = 0
		const pos = input and input.Position
		startPosition = pos and Vector2.new(pos.X, pos.Y) or nil
	end

	const function endPointer()
		if disconnected then
			return
		end
		if not isPointerDown or mouseDownTime == 0 then
			resetState()
			return
		end

		const holdDuration = tick() - mouseDownTime
		const isClick = (holdDuration < clickTimeThreshold) and (maxMoveDistance <= moveThreshold)

		resetState()

		if isClick then
			clickCallback()
		end
	end

	local boundPress = false
	const isGuiButton = type(button.IsA) == "function" and button:IsA("GuiButton")
	if isGuiButton then
		const downSignal = getSignal(button, "MouseButton1Down")
		const upSignal = getSignal(button, "MouseButton1Up")
		const downBound = connectSignal(downSignal, function()
			beginPointer(nil)
		end)
		const upBound = connectSignal(upSignal, function()
			endPointer()
		end)
		boundPress = downBound and upBound
	end

	if not boundPress then
		const beganSignal = getSignal(button, "InputBegan")
		const endedSignal = getSignal(button, "InputEnded")
		const beganBound = connectSignal(beganSignal, function(input)
			if input and isPressInput(input.UserInputType) then
				beginPointer(input)
			end
		end)
		const endedBound = connectSignal(endedSignal, function(input)
			if input and isPressInput(input.UserInputType) then
				endPointer()
			end
		end)
		boundPress = beganBound and endedBound
	end

	const changedSignal = getSignal(button, "InputChanged")
	connectSignal(changedSignal, function(input)
		if not isPointerDown then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		const pos = input.Position
		if not pos then
			return
		end

		if not startPosition then
			startPosition = Vector2.new(pos.X, pos.Y)
			return
		end

		const currentPos = Vector2.new(pos.X, pos.Y)
		const delta = (currentPos - startPosition).Magnitude
		if delta > maxMoveDistance then
			maxMoveDistance = delta
		end
	end)

	if not boundPress then
		disconnectAll()
		return state
	end

	if button.AncestryChanged then
		connectSignal(button.AncestryChanged, function()
			Defer(function()
				if not disconnected and button.Parent == nil then
					disconnectAll()
				end
			end)
		end)
	end
	if button.Destroying then
		connectSignal(button.Destroying, disconnectAll)
	end

	return state
end

NAmanage.AttachMessageCopy = function(gui, rawMessage)
	if not (gui and gui.InputBegan and gui.InputEnded) then
		return
	end
	NAStuff._messageCopyHooks = NAmanage.ensureWeakKeyTable(NAStuff._messageCopyHooks)
	const hooks = NAStuff._messageCopyHooks

	const function buildResolver()
		if type(rawMessage) == "function" then
			return function()
				local ok, value = pcall(rawMessage, gui)
				if ok then
					return value
				end
				return nil
			end
		end
		return function()
			return rawMessage
		end
	end

	const existing = hooks[gui]
	if existing then
		existing.resolveMessage = buildResolver()
		return existing
	end

	const HOLD_TIME = 0.5
	local isHolding = false
	local holdToken = 0

	const state = {
		resolveMessage = buildResolver(),
	}
	hooks[gui] = state

	const function startHold()
		holdToken += 1
		const myToken = holdToken
		isHolding = true
		Delay(HOLD_TIME, function()
			if not isHolding or myToken ~= holdToken then
				return
			end
			const resolver = state.resolveMessage
			local msg = resolver and resolver() or nil
			if msg == nil then
				return
			end
			msg = tostring(msg)
			if msg == "" then
				return
			end
			if setclipboard then
				pcall(setclipboard, msg)
				if DoNotif then
					DoNotif("Message copied to clipboard.", 1.5)
				end
			elseif DoNotif then
				DoNotif("Clipboard unavailable", 1.5)
			end
		end)
	end

	const function stopHold()
		isHolding = false
	end

	state.beginConn = gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			startHold()
		end
	end)

	state.endConn = gui.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			stopHold()
		end
	end)

	const function cleanup()
		holdToken += 1
		isHolding = false
		const s = hooks[gui]
		if not s then
			return
		end
		hooks[gui] = nil
		if s.beginConn then
			pcall(function() s.beginConn:Disconnect() end)
			s.beginConn = nil
		end
		if s.endConn then
			pcall(function() s.endConn:Disconnect() end)
			s.endConn = nil
		end
		if s.ancestryConn then
			pcall(function() s.ancestryConn:Disconnect() end)
			s.ancestryConn = nil
		end
	end

	state.cleanup = cleanup
	state.ancestryConn = gui.AncestryChanged:Connect(function(_, parent)
		if not parent then
			cleanup()
		end
	end)

	return state
end


--[[ FUNCTION TO GET A PLAYER ]]--
NAmanage.NPCArgAll = NAmanage.NPCArgAll or function()
	const out = {}
	const seen = {}
	const function add(m)
		if typeof(m) ~= "Instance" or not m:IsA("Model") then
			return
		end
		if seen[m] then
			return
		end
		if CheckIfNPC(m) then
			seen[m] = true
			Insert(out, m)
		end
	end
	if Services.Workspace then
		for _, m in Services.Workspace:QueryDescendants("Model") do
			add(m)
		end
	end
	return out
end

NAmanage.NPCArgRoot = NAmanage.NPCArgRoot or function(speaker)
	local char = getPlrChar(speaker or LocalPlayer)
	if not char and typeof(speaker) == "Instance" and speaker:IsA("Model") then
		char = speaker
	end
	char = char or getPlrChar(LocalPlayer) or (LocalPlayer and LocalPlayer.Character)
	return char and getRoot(char) or nil
end

NAmanage.NPCArgTrim = NAmanage.NPCArgTrim or function(txt)
	txt = tostring(txt or "")
	return txt:match("^%s*(.-)%s*$") or ""
end

NAmanage.NPCArgSplit = NAmanage.NPCArgSplit or function(txt)
	const out = {}
	txt = NAmanage.NPCArgTrim(txt)
	if txt == "" then
		return out
	end
	for part in txt:gmatch("[^,|]+") do
		part = NAmanage.NPCArgTrim(part)
		if part ~= "" then
			Insert(out, Lower(part))
		end
	end
	if #out == 0 then
		Insert(out, Lower(txt))
	end
	return out
end

NAmanage.NPCArgName = NAmanage.NPCArgName or function(pool, raw)
	const out = {}
	raw = Lower(NAmanage.NPCArgTrim(raw))
	if raw == "" then
		return out
	end
	const function matches(m, loose)
		const n = Lower(m.Name or "")
		const hum = getPlrHum(m)
		const d = hum and Lower(tostring(hum.DisplayName or "")) or ""
		if Sub(n, 1, #raw) == raw or Sub(d, 1, #raw) == raw then
			return true
		end
		return loose and ((Find(n, raw, 1, true) ~= nil) or (d ~= "" and Find(d, raw, 1, true) ~= nil))
	end
	for _, m in pool do
		if matches(m, false) then
			Insert(out, m)
		end
	end
	if #out > 0 then
		return out
	end
	for _, m in pool do
		if matches(m, true) then
			Insert(out, m)
		end
	end
	return out
end

NAmanage.NPCArgOneByDistance = NAmanage.NPCArgOneByDistance or function(pool, speaker, far)
	const org = NAmanage.NPCArgRoot(speaker)
	if not org then
		return {}
	end
	local best = nil
	local bestDist = far and -math.huge or math.huge
	for _, m in pool do
		const r = getRoot(m)
		if r then
			const dist = (r.Position - org.Position).Magnitude
			if (far and dist > bestDist) or ((not far) and dist < bestDist) then
				bestDist = dist
				best = m
			end
		end
	end
	return best and { best } or {}
end

NAmanage.NPCArgWithinRadius = NAmanage.NPCArgWithinRadius or function(pool, speaker, radius)
	const out = {}
	const org = NAmanage.NPCArgRoot(speaker)
	radius = tonumber(radius)
	if not org or not radius then
		return out
	end
	for _, m in pool do
		const r = getRoot(m)
		if r and (r.Position - org.Position).Magnitude <= radius then
			Insert(out, m)
		end
	end
	return out
end

NAmanage.NPCArgFilter = NAmanage.NPCArgFilter or function(pool, speaker, tok)
	if tok == "" or tok == "all" or tok == "others" or tok == "other" or tok == "npcs" or tok == "npc" then
		return pool
	end
	if tok == "random" then
		if #pool == 0 then
			return {}
		end
		return { pool[math.random(1, #pool)] }
	end
	if tok == "nearest" or tok == "closest" then
		return NAmanage.NPCArgOneByDistance(pool, speaker, false)
	end
	if tok == "farthest" or tok == "furthest" then
		return NAmanage.NPCArgOneByDistance(pool, speaker, true)
	end
	if tok == "alive" or tok == "dead" then
		const out = {}
		for _, m in pool do
			const hum = getPlrHum(m)
			if hum and ((tok == "alive" and hum.Health > 0) or (tok == "dead" and hum.Health <= 0)) then
				Insert(out, m)
			end
		end
		return out
	end
	if tok == "seated" or tok == "sat" or tok == "stood" then
		const out = {}
		for _, m in pool do
			const hum = getPlrHum(m)
			if hum and ((tok ~= "stood" and hum.Sit) or (tok == "stood" and not hum.Sit)) then
				Insert(out, m)
			end
		end
		return out
	end
	const amount = tok:match("^#(%d+)$")
	if amount then
		const out = {}
		const left = { Unpack(pool) }
		for _ = 1, math.min(tonumber(amount) or 0, #left) do
			const i = math.random(1, #left)
			Insert(out, left[i])
			table.remove(left, i)
		end
		return out
	end
	const rad = tok:match("^rad(%d+%.%d+)$") or tok:match("^rad(%d+)$") or tok:match("^radius(%d+%.%d+)$") or tok:match("^radius(%d+)$")
	if rad then
		return NAmanage.NPCArgWithinRadius(pool, speaker, rad)
	end
	return NAmanage.NPCArgName(pool, tok)
end

NAmanage.ParseNPCPlayerArg = NAmanage.ParseNPCPlayerArg or function(raw)
	raw = NAmanage.NPCArgTrim(raw)
	if raw == "npcs" then
		return ""
	end
	for _, head in { "npc", "npcs" } do
		const a = head..":"
		const b = head..":["
		const c = head.."["
		if Sub(raw, 1, #b) == b and Sub(raw, -1) == "]" then
			return Sub(raw, #b + 1, -2)
		end
		if Sub(raw, 1, #c) == c and Sub(raw, -1) == "]" then
			return Sub(raw, #c + 1, -2)
		end
		if Sub(raw, 1, #a) == a then
			return Sub(raw, #a + 1)
		end
	end
	return nil
end

NAmanage.ResolveNPCPlayerArg = NAmanage.ResolveNPCPlayerArg or function(speaker, raw)
	const pool = NAmanage.NPCArgAll()
	const toks = NAmanage.NPCArgSplit(raw)
	const out = {}
	const seen = {}
	const function add(list)
		for _, m in list do
			if typeof(m) == "Instance" and not seen[m] then
				seen[m] = true
				Insert(out, m)
			end
		end
	end
	if #toks == 0 then
		add(pool)
	else
		for _, tok in toks do
			add(NAmanage.NPCArgFilter(pool, speaker, tok))
		end
	end
	return out
end

NAmanage.PlayerArgChar = NAmanage.PlayerArgChar or function(target)
	if typeof(target) ~= "Instance" then
		return nil
	end
	if target:IsA("Player") then
		return target.Character or getPlrChar(target)
	end
	if target:IsA("Model") then
		return target
	end
	return getPlrChar(target)
end

NAmanage.PlayerArgRoot = NAmanage.PlayerArgRoot or function(target)
	const char = NAmanage.PlayerArgChar(target)
	return char and getRoot(char) or nil
end

NAmanage.PlayerArgHum = NAmanage.PlayerArgHum or function(target)
	const char = NAmanage.PlayerArgChar(target)
	return char and getPlrHum(char) or nil
end

NAmanage.PlayerArgPivot = NAmanage.PlayerArgPivot or function(target)
	const char = NAmanage.PlayerArgChar(target)
	if not (char and char.Parent) then
		return nil
	end
	local ok, cf = pcall(function()
		return char:GetPivot()
	end)
	if ok and typeof(cf) == "CFrame" then
		return cf
	end
	const root = getRoot(char)
	if root then
		return (NAmanage.UG_clientCFrame and NAmanage.UG_clientCFrame(root)) or root.CFrame
	end
	return nil
end

NAmanage.PlayerArgName = NAmanage.PlayerArgName or function(target)
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			return nameChecker(target)
		end
		return target.Name
	end
	return tostring(target)
end

NAmanage.PlayerArgIsNeutral = NAmanage.PlayerArgIsNeutral or function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return true
	end
	local ok, neutral = pcall(function()
		return player.Neutral
	end)
	return ok and neutral == true
end

NAmanage.PlayerArgSameTeam = function(target, speaker)
	const lp = speaker or Services.Players.LocalPlayer
	if not (typeof(target) == "Instance" and target:IsA("Player")) then
		return false
	end
	if not (typeof(lp) == "Instance" and lp:IsA("Player")) then
		return false
	end
	if target == lp then
		return false
	end
	if NAmanage.PlayerArgIsNeutral(lp) or NAmanage.PlayerArgIsNeutral(target) then
		return false
	end

	const myTeam = lp.Team
	const theirTeam = target.Team
	if myTeam ~= nil and theirTeam ~= nil then
		return theirTeam == myTeam
	end

	local okMyColor, myColor = pcall(function()
		return lp.TeamColor
	end)
	local okTheirColor, theirColor = pcall(function()
		return target.TeamColor
	end)
	return okMyColor and okTheirColor and myColor ~= nil and theirColor ~= nil and myColor == theirColor
end

NAmanage.PlayerArgNonTeam = function(target, speaker)
	const lp = speaker or Services.Players.LocalPlayer
	if not (typeof(target) == "Instance" and target:IsA("Player")) then
		return false
	end
	if target == lp then
		return false
	end
	return not NAmanage.PlayerArgSameTeam(target, lp)
end

PlayerArgs = {
	["all"] = function()
		return __lt.cm("Players", "GetPlayers")
	end,

	["others"] = function(speaker)
		const Targets = {}
		speaker = speaker or LocalPlayer

		Foreach(__lt.cm("Players", "GetPlayers"), function(_, Player)
			if Player ~= speaker then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["me"] = function(speaker)
		speaker = speaker or LocalPlayer
		return speaker and { speaker } or {}
	end,

	["random"] = function(speaker, _, currentList)
		const list = { Unpack(currentList or __lt.cm("Players", "GetPlayers")) }
		speaker = speaker or LocalPlayer
		if speaker then
			const i = Discover(list, speaker)
			if i then table.remove(list, i) end
		end
		if #list == 0 then
			return {}
		end
		return { list[math.random(1, #list)] }
	end,

	["npc"] = function()
		return NAmanage.NPCArgAll()
	end,

	["npcs"] = function()
		return NAmanage.NPCArgAll()
	end,

	["seated"] = function(_, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = NAmanage.PlayerArgHum(Player)
			if Hum and Hum.Sit then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["stood"] = function(_, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = NAmanage.PlayerArgHum(Player)
			if Hum and not Hum.Sit then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["nearest"] = function(speaker, _, currentList)
		speaker = speaker or LocalPlayer
		const origin = NAmanage.PlayerArgRoot(speaker)
		if not origin then return {} end
		local lowest = math.huge
		local Target = nil

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			if Player ~= speaker then
				const root = NAmanage.PlayerArgRoot(Player)
				if root then
					const distance = (root.Position - origin.Position).Magnitude
					if distance < lowest then
						lowest = distance
						Target = Player
					end
				end
			end
		end)

		return Target and { Target } or {}
	end,

	["farthest"] = function(speaker, _, currentList)
		speaker = speaker or LocalPlayer
		const origin = NAmanage.PlayerArgRoot(speaker)
		if not origin then return {} end
		local highest = -math.huge
		local Target = nil

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			if Player ~= speaker then
				const root = NAmanage.PlayerArgRoot(Player)
				if root then
					const distance = (root.Position - origin.Position).Magnitude
					if distance > highest then
						highest = distance
						Target = Player
					end
				end
			end
		end)

		return Target and { Target } or {}
	end,

	["dead"] = function(_, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = NAmanage.PlayerArgHum(Player)
			if not Hum or Hum.Health <= 0 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["alive"] = function(_, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = NAmanage.PlayerArgHum(Player)
			if Hum and Hum.Health > 0 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["friends"] = function(speaker, _, currentList)
		const Targets = {}
		speaker = speaker or LocalPlayer
		if not speaker then return Targets end

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			local ok, isFriend = pcall(Player.IsFriendsWith, Player, speaker.UserId)
			if Player ~= speaker and ok and isFriend then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["nonfriends"] = function(speaker, _, currentList)
		const Targets = {}
		speaker = speaker or LocalPlayer
		if not speaker then return Targets end

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			local ok, isFriend = pcall(Player.IsFriendsWith, Player, speaker.UserId)
			if Player ~= speaker and ok and not isFriend then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["team"] = function(speaker, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			if NAmanage.PlayerArgSameTeam(Player, speaker) then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["nonteam"] = function(speaker, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			if NAmanage.PlayerArgNonTeam(Player, speaker) then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["r15"] = function()
		const Targets = {}

		Foreach(__lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R15 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["r6"] = function()
		const Targets = {}

		Foreach(__lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R6 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["invisible"] = function()
		const Targets = {}

		Foreach(__lt.cm("Players", "GetPlayers"), function(_, Player)
			const Char = Player.Character
			if Char then
				local isInvisible = true
				for _, part in Char:GetChildren() do
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
		const Targets = {}

		Foreach(__lt.cm("Players", "GetPlayers"), function(_, Player)
			const Char = Player.Character
			if Char then
				for _, v in Char:GetChildren() do
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
		const Targets = {}

		Foreach(__lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R15 then
				const desc = Hum:GetAppliedDescription()
				if desc and tonumber(desc.BodyHeightScale) > 1.05 then
					Insert(Targets, Player)
				end
			end
		end)

		return Targets
	end,

	["short"] = function()
		const Targets = {}

		Foreach(__lt.cm("Players", "GetPlayers"), function(_, Player)
			const Hum = getPlrHum(Player.Character)
			if Hum and Hum.RigType == Enum.HumanoidRigType.R15 then
				const desc = Hum:GetAppliedDescription()
				if desc and tonumber(desc.BodyHeightScale) < 0.9 then
					Insert(Targets, Player)
				end
			end
		end)

		return Targets
	end,


	["#(%d+)"] = function(speaker, args, currentList)
		const returns = {}
		const randAmount = tonumber(args[1])
		const pool = { unpack(currentList or __lt.cm("Players", "GetPlayers")) }
		for i = 1, math.min(randAmount, #pool) do
			const idx = math.random(1, #pool)
			Insert(returns, pool[idx])
			table.remove(pool, idx)
		end
		return returns
	end,

	["%%(.+)"] = function(speaker, args)
		const returns = {}
		const teamPrefix = args[1]:lower()
		for _, plr in __lt.cm("Players", "GetPlayers") do
			if plr.Team
				and plr.Team.Name:lower():sub(1, #teamPrefix) == teamPrefix
			then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["allies"] = function(speaker, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			if NAmanage.PlayerArgSameTeam(Player, speaker) then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["enemies"] = function(speaker, _, currentList)
		const Targets = {}

		Foreach(currentList or __lt.cm("Players", "GetPlayers"), function(_, Player)
			if NAmanage.PlayerArgNonTeam(Player, speaker) then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["age(%d+)"] = function(speaker, args)
		const returns = {}
		const maxAge = tonumber(args[1])
		for _, plr in __lt.cm("Players", "GetPlayers") do
			if plr.AccountAge <= maxAge then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["group(%d+)"] = function(speaker, args)
		const returns = {}
		const groupID = tonumber(args[1])
		for _, plr in __lt.cm("Players", "GetPlayers") do
			if plr:IsInGroup(groupID) then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["rad(%d+)"] = function(speaker, args)
		const returns = {}
		const radius = tonumber(args[1])
		const origin = getRoot(speaker.Character)
		if not origin then return returns end
		for _, plr in __lt.cm("Players", "GetPlayers") do
			const root = getRoot(plr.Character)
			if root and (root.Position - origin.Position).Magnitude <= radius then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["userid:(%d+)"] = function(_, args, currentList)
		const returns = {}
		const userId = tonumber(args[1])
		for _, plr in currentList or __lt.cm("Players", "GetPlayers") do
			if plr.UserId == userId then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["username:(.+)"] = function(_, args, currentList)
		const returns = {}
		const search = Lower(tostring(args[1] or ""))
		for _, plr in currentList or __lt.cm("Players", "GetPlayers") do
			if Sub(Lower(plr.Name), 1, #search) == search then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["display:(.+)"] = function(_, args, currentList)
		const returns = {}
		const search = Lower(tostring(args[1] or ""))
		for _, plr in currentList or __lt.cm("Players", "GetPlayers") do
			if Sub(Lower(plr.DisplayName), 1, #search) == search then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["exactuser:(.+)"] = function(_, args, currentList)
		const returns = {}
		const search = Lower(tostring(args[1] or ""))
		for _, plr in currentList or __lt.cm("Players", "GetPlayers") do
			if Lower(plr.Name) == search then
				Insert(returns, plr)
			end
		end
		return returns
	end,

	["cursor"] = function(speaker)
		const returns = {}
		const v = NAmanage.getPlrCursor()
		if v then Insert(returns, v) end
		return returns
	end,
}

PlayerArgs["noteam"] = PlayerArgs["nonteam"]
PlayerArgs["noteams"] = PlayerArgs["nonteam"]
PlayerArgs["nonteams"] = PlayerArgs["nonteam"]
PlayerArgs["notteam"] = PlayerArgs["nonteam"]
PlayerArgs["enemy"] = PlayerArgs["enemies"]
PlayerArgs["ally"] = PlayerArgs["allies"]
PlayerArgs["everyone"] = PlayerArgs["all"]
PlayerArgs["other"] = PlayerArgs["others"]
PlayerArgs["self"] = PlayerArgs["me"]
PlayerArgs["closest"] = PlayerArgs["nearest"]
PlayerArgs["furthest"] = PlayerArgs["farthest"]
PlayerArgs["sat"] = PlayerArgs["seated"]
PlayerArgs["standing"] = PlayerArgs["stood"]
PlayerArgs["friend"] = PlayerArgs["friends"]
PlayerArgs["nonfriend"] = PlayerArgs["nonfriends"]
PlayerArgs["teammate"] = PlayerArgs["team"]
PlayerArgs["teammates"] = PlayerArgs["team"]
PlayerArgs["id:(%d+)"] = PlayerArgs["userid:(%d+)"]
PlayerArgs["name:(.+)"] = PlayerArgs["username:(.+)"]

originalIO.normalizePlayerQuery=function(query)
	if type(query) == "string" then
		return Lower(query:match("^%s*(.-)%s*$") or "")
	end
	if typeof(query) == "Instance" and query:IsA("Player") then
		return Lower(query.Name)
	end
	if type(query) == "table" and type(query.Name) == "string" then
		return Lower(query.Name)
	end
	return ""
end

NAmanage.PlayerArgIntersect = function(source, matches)
	const allowed = {}
	const out = {}
	for _, target in matches or {} do
		allowed[target] = true
	end
	for _, target in source or {} do
		if allowed[target] then
			Insert(out, target)
		end
	end
	return out
end

NAmanage.PlayerArgRemove = function(source, matches)
	const blocked = {}
	const out = {}
	for _, target in matches or {} do
		blocked[target] = true
	end
	for _, target in source or {} do
		if not blocked[target] then
			Insert(out, target)
		end
	end
	return out
end

NAmanage.PlayerArgResolveSimple = function(speaker, raw, currentList)
	raw = originalIO.normalizePlayerQuery(raw)
	currentList = currentList or PlayerArgs["all"](speaker)
	if raw == "" then
		return {}
	end

	if raw == "*" then
		return PlayerArgs["all"](speaker, {}, currentList) or {}
	end
	if PlayerArgs[raw] then
		return PlayerArgs[raw](speaker, {}, currentList) or {}
	end

	const onlyDigits = raw:match("^%d+$")
	if onlyDigits then
		const exactNumericUser = {}
		for _, plr in currentList do
			if Lower(plr.Name) == raw then
				Insert(exactNumericUser, plr)
			end
		end
		if #exactNumericUser > 0 then
			return exactNumericUser
		end
		return PlayerArgs["#(%d+)"](speaker, { onlyDigits }, currentList) or {}
	end

	for pat, fn in PlayerArgs do
		const captures = { raw:match("^"..pat.."$") }
		if #captures > 0 then
			return fn(speaker, captures, currentList) or {}
		end
	end

	const out = {}
	const usernameOnly = Sub(raw, 1, 1) == "@"
	const search = usernameOnly and Sub(raw, 2) or raw
	if search == "" then
		return out
	end
	for _, plr in __lt.cm("Players", "GetPlayers") do
		const n = Lower(plr.Name)
		const d = Lower(plr.DisplayName)
		if Sub(n, 1, #search) == search or (not usernameOnly and Sub(d, 1, #search) == search) then
			Insert(out, plr)
		end
	end
	return out
end

function getPlr(a, b)
	local speaker, raw
	if b == nil then
		speaker = Services.Players.LocalPlayer
		raw = originalIO.normalizePlayerQuery(a)
	else
		speaker = a or Services.Players.LocalPlayer
		raw = originalIO.normalizePlayerQuery(b)
	end

	const npcRaw = NAmanage.ParseNPCPlayerArg and NAmanage.ParseNPCPlayerArg(raw)
	if npcRaw ~= nil then
		return NAmanage.ResolveNPCPlayerArg(speaker, npcRaw)
	end
	if raw == "" then
		return {}
	end

	const found = {}
	const seen = {}
	for segment in raw:gmatch("[^,|]+") do
		segment = segment:match("^%s*(.-)%s*$") or ""
		if segment ~= "" then
			if Sub(segment, 1, 1) ~= "+" and Sub(segment, 1, 1) ~= "-" then
				segment = "+"..segment
			end
			local current = PlayerArgs["all"](speaker)
			local hadToken = false
			for operator, token in segment:gmatch("([+-])([^+-]+)") do
				token = token:match("^%s*(.-)%s*$") or ""
				if token ~= "" then
					hadToken = true
					const matches = NAmanage.PlayerArgResolveSimple(speaker, token, current)
					if operator == "+" then
						current = NAmanage.PlayerArgIntersect(current, matches)
					else
						current = NAmanage.PlayerArgRemove(current, matches)
					end
				end
			end
			if hadToken then
				for _, target in current do
					if not seen[target] then
						seen[target] = true
						Insert(found, target)
					end
				end
			end
		end
	end
	return found
end

NAmanage.getPlr = getPlr
NAmanage.PlayerQueryFromArgs = function(...)
	const args = { ... }
	for i = 1, #args do
		args[i] = tostring(args[i] or "")
	end
	return Concat(args, " "):match("^%s*(.-)%s*$") or ""
end

NAmanage.NewPersistentPlayerRef = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return nil
	end
	const userId = tonumber(player.UserId)
	return {
		UserId = userId,
		Name = player.Name,
		Selector = userId and userId > 0 and ("userid:"..userId) or ("exactuser:"..player.Name),
		Player = player,
	}
end

NAmanage.ResolvePersistentPlayer = function(ref)
	const RawPlayers = __lt.gs("Players")
	if type(ref) ~= "table" then
		return nil
	end
	local player = ref.Player
	if typeof(player) == "Instance" and player:IsA("Player") and player.Parent == RawPlayers then
		return player
	end
	const targets = getPlr(ref.Selector or (ref.Name and ("exactuser:"..ref.Name)) or "")
	player = targets[1]
	ref.Player = player
	return player
end

NAmanage.PersistentPlayerRefs = function(query, speaker)
	const refs = {}
	const seen = {}
	for _, player in getPlr(speaker or Services.Players.LocalPlayer, query) do
		if typeof(player) == "Instance" and player:IsA("Player") and not seen[player.UserId] then
			seen[player.UserId] = true
			Insert(refs, NAmanage.NewPersistentPlayerRef(player))
		end
	end
	return refs
end


NAmanage.JoinLeaveTitle = function(kind)
	if kind == "Join" then
		return ('<font color="%s">Join</font>/'..'<font color="%s">Leave</font>'):format(NAStuff.logClrs.GREEN, NAStuff.logClrs.WHITE)
	end
	return ('<font color="%s">Join</font>/'..'<font color="%s">Leave</font>'):format(NAStuff.logClrs.WHITE, NAStuff.logClrs.RED)
end

NAmanage.FormatJoinLeaveMessage = function(plr, action)
	return NAmanage.formatLogPlayerName(plr, {
		showUserId = NAmanage.jlCfg.JoinLeaveShowUserIds == true;
	}).." has "..tostring(action).." the game."
end

NAmanage.NotifyJoinLeave = function(plr, kind, action)
	const msg = NAmanage.FormatJoinLeaveMessage(plr, action)
	DoNotif(msg, 1, NAmanage.JoinLeaveTitle(kind))
	NAmanage.LogJoinLeave(msg)
end
NAmanage.SpecialMarkerColor = function(value, fallback)
	if typeof(value) == "Color3" then
		return value
	end
	if type(value) == "table" then
		local r = tonumber(value.R or value.r)
		local g = tonumber(value.G or value.g)
		local b = tonumber(value.B or value.b)
		if r and g and b then
			return Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
		end
	end
	return fallback or Color3.new(1, 1, 1)
end

NAmanage.SpecialMarkerOutlineColor = function(color)
	color = NAmanage.SpecialMarkerColor(color, Color3.new(1, 1, 1))
	return color:Lerp(Color3.new(1, 1, 1), 0.72)
end

NAmanage.SpecialMarkerStrokeColor = function(color)
	color = NAmanage.SpecialMarkerColor(color, Color3.new(1, 1, 1))
	return Color3.new(color.R * 0.15, color.G * 0.15, color.B * 0.15)
end


NAmanage.StaffwatchGetMarkerColor = function()
	return NAmanage.SpecialMarkerColor(NAStuff.StaffwatchMarkerColor, Color3.fromRGB(35, 140, 255))
end


--[[ MORE VARIABLES ]]--
plr=Player
speaker=Player
char=plr.Character
deathCFrame = nil
JSONEncode,JSONDecode=Services.HttpService.JSONEncode,Services.HttpService.JSONDecode

NACaller(function()
	LocalPlayer.CharacterAdded:Connect(function(c)
		if not c then return end
		character=c
		Character=c
		char=c
	end)
end)

ESPenabled=false
chamsEnabled=false
ESPAutoTrackAll=false
ESPPlayersEnabled=false
NPCESPenabled=false
NAStuff.ESP_IgnoreTeam = NAStuff.ESP_IgnoreTeam == true
NAStuff.ESP_TargetTeam = tostring(NAStuff.ESP_TargetTeam or "")
NAStuff.ESP_PlayerTargetMode = tostring(NAStuff.ESP_PlayerTargetMode or "all")
if type(espCONS) ~= "table" then
	espCONS = {}
end
if getmetatable(espCONS) then
	setmetatable(espCONS, nil)
end
if type(NAStuff.ESP_PlayerLabelOverrides) ~= "table" then
	NAStuff.ESP_PlayerLabelOverrides = {}
end
if type(NAStuff.ESP_PlayerLabelOverrideText) ~= "table" then
	NAStuff.ESP_PlayerLabelOverrideText = {}
end

NAmanage.ESP_SetPlayerLabelOverride = function(player, enabled, text)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return
	end
	const uid = tonumber(player.UserId)
	if not uid or uid <= 0 then
		return
	end
	if enabled == true then
		NAStuff.ESP_PlayerLabelOverrides[uid] = true
		if type(text) == "string" and text ~= "" then
			NAStuff.ESP_PlayerLabelOverrideText[uid] = text
		end
	else
		NAStuff.ESP_PlayerLabelOverrides[uid] = nil
		NAStuff.ESP_PlayerLabelOverrideText[uid] = nil
	end
end

NAmanage.ESP_HasPlayerLabelOverride = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return false
	end
	const uid = tonumber(player.UserId)
	if not uid or uid <= 0 then
		return false
	end
	return NAStuff.ESP_PlayerLabelOverrides[uid] == true
end

NAmanage.ESP_GetPlayerLabelOverrideText = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return nil
	end
	const uid = tonumber(player.UserId)
	if not uid or uid <= 0 then
		return nil
	end
	const text = NAStuff.ESP_PlayerLabelOverrideText and NAStuff.ESP_PlayerLabelOverrideText[uid]
	if type(text) == "string" and text ~= "" then
		return text
	end
	return nil
end

NAmanage.ESP_HasAnyPlayerLabelOverride = function()
	if type(NAStuff.ESP_PlayerLabelOverrides) ~= "table" then
		return false
	end
	for _, enabled in NAStuff.ESP_PlayerLabelOverrides do
		if enabled == true then
			return true
		end
	end
	return false
end

NAmanage.ESP_ClearPlayerLabelOverrides = function()
	NAStuff.ESP_PlayerLabelOverrides = {}
	NAStuff.ESP_PlayerLabelOverrideText = {}
end

NAmanage.ESP_RecomputeEnabled=function()
	ESPenabled = ESPPlayersEnabled or NPCESPenabled
end

NAmanage.ESP_IsWithinDistance=function(dist, maxDistance)
	const max = tonumber(maxDistance)
	if not max or max <= 0 then
		return true
	end
	if dist == nil then
		return true
	end
	return dist <= max
end

NAmanage.ESP_WaitForPlayerCharacter = function(player, timeoutSeconds)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return nil
	end
	local timeout = tonumber(timeoutSeconds) or 4
	if timeout < 0.1 then
		timeout = 0.1
	end
	const deadline = os.clock() + timeout
	while player.Parent and os.clock() < deadline do
		const char = player.Character
		if char and NAmanage.IsValidESPModel(char, false) then
			return char
		end
		Wait(0.1)
	end
	const char = player.Character
	if char and NAmanage.IsValidESPModel(char, false) then
		return char
	end
	return nil
end


NAgui.getDrawingLibrary = function()
	const draw = Drawing
	if type(draw) == "table" and type(draw.new) == "function" then
		return draw
	end
	local ok, env = false, nil
	if type(getgenv) == "function" then
		ok, env = pcall(getgenv)
	end
	if ok and type(env) == "table" then
		const fromEnv = rawget(env, "Drawing")
		if type(fromEnv) == "table" and type(fromEnv.new) == "function" then
			return fromEnv
		end
	end
	return nil
end

NAmanage.DrawingObjectSupported = function(kind, refresh)
	const objectKind = tostring(kind or "")
	if objectKind == "" then
		return false
	end
	local cache = NAmanage._drawingObjectSupport
	if type(cache) ~= "table" then
		cache = {}
		NAmanage._drawingObjectSupport = cache
	end
	if not refresh and cache[objectKind] ~= nil then
		return cache[objectKind] == true
	end
	const drawingLib = NAgui.getDrawingLibrary()
	if not drawingLib then
		cache[objectKind] = false
		return false
	end
	local ok, obj = pcall(function()
		return drawingLib.new(objectKind)
	end)
	if not ok or not obj then
		cache[objectKind] = false
		return false
	end
	const applied = pcall(function()
		obj.Visible = false
		if objectKind == "Square" then
			obj.Filled = false
			obj.Thickness = 1
			obj.Color = Color3.new(1, 1, 1)
			obj.Transparency = 1
			obj.Position = Vector2.new(0, 0)
			obj.Size = Vector2.new(2, 2)
		elseif objectKind == "Line" then
			obj.Color = Color3.new(1, 1, 1)
			obj.Transparency = 1
			obj.Thickness = 1
			obj.From = Vector2.new(0, 0)
			obj.To = Vector2.new(1, 1)
		elseif objectKind == "Text" then
			obj.Center = true
			obj.Outline = true
			obj.Color = Color3.new(1, 1, 1)
			obj.Size = 12
			obj.Text = ""
			obj.Transparency = 1
			obj.Position = Vector2.new(0, 0)
		elseif objectKind == "Triangle" then
			obj.Filled = true
			obj.Thickness = 1
			obj.Color = Color3.new(1, 1, 1)
			obj.Transparency = 1
			obj.PointA = Vector2.new(0, 0)
			obj.PointB = Vector2.new(1, 0)
			obj.PointC = Vector2.new(0, 1)
		end
	end)
	NAmanage.DrawingRemoveObject(obj)
	cache[objectKind] = applied == true
	return applied == true
end

NAgui.hasDrawingAPI = function()
	return NAmanage.DrawingObjectSupported("Square")
end

NAgui.getESPRenderModeOptions = function(includeCharacterBox)
	const options = { "BoxHandleAdornment" }
	if includeCharacterBox ~= false then
		options[#options + 1] = "Character Box"
	end
	options[#options + 1] = "Highlight"
	if NAgui.hasDrawingAPI() then
		options[#options + 1] = "Drawing API"
	end
	return options
end

NAgui.getNPCESPRenderModeOptions = function()
	const options = { "Highlight" }
	if NAgui.hasDrawingAPI() then
		options[#options + 1] = "Drawing API"
	end
	return options
end

NAgui.getESPDrawingBoxStyleOptions = function()
	return { "Square", "Corners" }
end

NAgui.sanitizeESPDrawingBoxStyle = function(value)
	const normalized = Lower(tostring(value or "square"))
	if normalized == "corners" or normalized == "corner" then
		return "Corners"
	end
	return "Square"
end

NAgui.getESPDrawingTracerOriginOptions = function()
	return { "Bottom", "Center", "Top" }
end

NAgui.sanitizeESPDrawingTracerOrigin = function(value)
	const normalized = Lower(tostring(value or "bottom"))
	if normalized == "top" then
		return "Top"
	end
	if normalized == "center" or normalized == "middle" then
		return "Center"
	end
	return "Bottom"
end

NAgui.getESPDrawingTracerTargetOptions = function()
	return { "Bottom", "Center", "Top" }
end

NAgui.sanitizeESPDrawingTracerTarget = function(value)
	const normalized = Lower(tostring(value or "bottom"))
	if normalized == "top" then
		return "Top"
	end
	if normalized == "center" or normalized == "middle" then
		return "Center"
	end
	return "Bottom"
end

NAgui.getDrawingTextFontOptions = function()
	return { "UI", "System", "Plex", "Monospace" }
end

NAgui.sanitizeDrawingTextFont = function(value)
	const normalized = Lower(tostring(value or "ui"))
	if normalized == "system" or normalized == "1" then
		return "System"
	end
	if normalized == "plex" or normalized == "2" then
		return "Plex"
	end
	if normalized == "monospace" or normalized == "mono" or normalized == "3" then
		return "Monospace"
	end
	return "UI"
end

NAgui.getDrawingTextFontValue = function(value)
	const font = NAgui.sanitizeDrawingTextFont(value)
	if font == "System" then
		return 1
	end
	if font == "Plex" then
		return 2
	end
	if font == "Monospace" then
		return 3
	end
	return 0
end

NAgui.sanitizeDrawingAlpha = function(value)
	return math.clamp(1 - NAgui.sanitizeTransparency(value), 0, 1)
end

NAgui.sanitizeESPRenderMode = function(mode, fallback)
	const desired = Lower(tostring(mode or ""))
	if desired == "highlight" then
		return "Highlight"
	end
	if desired == "boxhandleadornment" or desired == "box" then
		return "BoxHandleAdornment"
	end
	if desired == "character box" or desired == "characterbox" or desired == "bounding box" or desired == "boundingbox" or desired == "bbox" or desired == "charbox" then
		return "Character Box"
	end
	if desired == "drawing api" or desired == "drawingapi" or desired == "drawing" then
		if NAgui.hasDrawingAPI() then
			return "Drawing API"
		end
	end
	local defaultMode = tostring(fallback or "BoxHandleAdornment")
	const normalizedDefault = Lower(defaultMode)
	defaultMode = (normalizedDefault == "highlight") and "Highlight"
		or ((normalizedDefault == "character box" or normalizedDefault == "characterbox" or normalizedDefault == "bounding box" or normalizedDefault == "boundingbox" or normalizedDefault == "bbox" or normalizedDefault == "charbox") and "Character Box")
		or ((normalizedDefault == "drawing api" and NAgui.hasDrawingAPI()) and "Drawing API")
		or "BoxHandleAdornment"
	return defaultMode
end

NAgui.sanitizeNPCESPRenderMode = function(mode)
	const desired = Lower(tostring(mode or ""))
	if desired == "drawing api" or desired == "drawingapi" or desired == "drawing" then
		if NAgui.hasDrawingAPI() then
			return "Drawing API"
		end
	end
	return "Highlight"
end

NAgui.getESPRenderMode = function(target)
	const key = Lower(tostring(target or "players"))
	if key == "npc" or key == "npcs" or key == "npcesp" then
		return NAgui.sanitizeNPCESPRenderMode(NAStuff.NPC_ESP_RenderMode)
	end
	const isPart = key == "part" or key == "parts" or key == "partesp"
	const rawMode = isPart and NAStuff.ESP_PartRenderMode or NAStuff.ESP_RenderMode
	const fallback = isPart and "BoxHandleAdornment" or "Highlight"
	const mode = NAgui.sanitizeESPRenderMode(rawMode, fallback)
	if isPart and mode == "Character Box" then
		return "BoxHandleAdornment"
	end
	return mode
end

NAgui.espUsesHighlight=function(target)
	return NAgui.getESPRenderMode(target) == "Highlight"
end

NAgui.espUsesDrawing = function(target)
	return NAgui.getESPRenderMode(target) == "Drawing API"
end

NAgui.espUsesCharacterBox = function(target)
	return NAgui.getESPRenderMode(target) == "Character Box"
end

NAgui.sanitizeTransparency=function(value)
	local tr = tonumber(value) or 0.7
	if tr < 0 then
		tr = 0
	elseif tr > 1 then
		tr = 1
	end
	return tr
end

NAgui.sanitizeLabelSize=function(value)
	local sz = tonumber(value) or 12
	if sz < 8 then
		sz = 8
	elseif sz > 72 then
		sz = 72
	end
	sz = math.floor(sz + 0.5)
	return sz
end

NAgui.getInstanceWorldPosition=function(inst)
	if not inst then return nil end
	if inst:IsA("BasePart") then
		return inst.Position
	elseif inst:IsA("Model") then
		const primary = inst.PrimaryPart
		if primary and primary.Parent then
			return primary.Position
		end
		local okBox, cf = pcall(inst.GetBoundingBox, inst)
		if okBox and cf then
			return cf.Position
		end
		local okPivot, pivot = pcall(inst.GetPivot, inst)
		if okPivot and pivot then
			return pivot.Position
		end
	end
	return nil
end

NAgui.getInstanceAdornee = function(inst)
	if not inst then return nil end
	if inst:IsA("BasePart") then
		return inst
	end
	if inst:IsA("Model") then
		const primary = inst.PrimaryPart
		if primary and primary.Parent then
			return primary
		end
		const root = getRoot(inst)
		if root and root:IsA("BasePart") then
			return root
		end
		for _, desc in NAmanage.QueryDescendants(inst, "BasePart") do
			if desc and desc.Parent then
				return desc
			end
		end
	end
	return nil
end

NAgui.getInstanceWorldBounds = function(inst)
	if not (inst and inst.Parent) then
		return nil, nil
	end
	if inst:IsA("BasePart") then
		return inst.CFrame, inst.Size
	end
	if inst:IsA("Model") then
		local ok, cf, size = pcall(inst.GetBoundingBox, inst)
		if ok and cf and size then
			return cf, size
		end
	end
	return nil, nil
end

NAgui.getInstanceViewportBounds = function(inst, camera)
	camera = camera or (Services.Workspace and Services.Workspace.CurrentCamera)
	if not camera then
		return nil
	end
	local cf, size = NAgui.getInstanceWorldBounds(inst)
	if not (cf and size) then
		return nil
	end
	const hx, hy, hz = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
	const offsets = {
		Vector3.new(-hx, -hy, -hz),
		Vector3.new(-hx, -hy, hz),
		Vector3.new(-hx, hy, -hz),
		Vector3.new(-hx, hy, hz),
		Vector3.new(hx, -hy, -hz),
		Vector3.new(hx, -hy, hz),
		Vector3.new(hx, hy, -hz),
		Vector3.new(hx, hy, hz),
	}
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local hasPoint = false
	local onScreen = false
	for i = 1, #offsets do
		const worldPoint = cf:PointToWorldSpace(offsets[i])
		local viewportPoint, visible = camera:WorldToViewportPoint(worldPoint)
		if viewportPoint.Z > 0 then
			hasPoint = true
			if viewportPoint.X < minX then minX = viewportPoint.X end
			if viewportPoint.Y < minY then minY = viewportPoint.Y end
			if viewportPoint.X > maxX then maxX = viewportPoint.X end
			if viewportPoint.Y > maxY then maxY = viewportPoint.Y end
			if visible then
				onScreen = true
			end
		end
	end
	if not hasPoint then
		return nil
	end
	const viewportSize = camera.ViewportSize
	if not onScreen then
		if maxX < 0 or minX > viewportSize.X or maxY < 0 or minY > viewportSize.Y then
			return nil
		end
	end
	const width = math.max(1, maxX - minX)
	const height = math.max(1, maxY - minY)
	return minX, minY, width, height
end

NAgui.toDrawingTransparency = function(fillTransparency)
	return math.clamp(1 - NAgui.sanitizeTransparency(fillTransparency), 0, 1)
end

NAgui.getInstanceLabelWorldPosition = function(inst, extraOffset)
	const worldPos = NAgui.getInstanceWorldPosition(inst)
	const rise = tonumber(extraOffset) or 0.2
	if inst and inst:IsA("BasePart") then
		return inst.Position + Vector3.new(0, (inst.Size.Y * 0.5) + rise, 0)
	end
	if inst and inst:IsA("Model") then
		local ok, cf, size = pcall(inst.GetBoundingBox, inst)
		if ok and cf and size then
			return cf.Position + Vector3.new(0, (size.Y * 0.5) + rise, 0)
		end
	end
	if worldPos then
		return worldPos + Vector3.new(0, rise, 0)
	end
	return nil
end

NAmanage.DrawingRemoveObject = function(obj)
	if not obj then return end
	pcall(function()
		obj.Visible = false
	end)
	pcall(function()
		obj:Remove()
	end)
	pcall(function()
		obj:Destroy()
	end)
end

NAmanage.DrawingTriangleSupported = function(refresh)
	return NAmanage.DrawingObjectSupported("Triangle", refresh)
end

NAmanage.DrawingLineSupported = function(refresh)
	return NAmanage.DrawingObjectSupported("Line", refresh)
end

NAmanage.DrawingTextSupported = function(refresh)
	return NAmanage.DrawingObjectSupported("Text", refresh)
end

NAmanage.DrawingCreateSquare = function(color, fillTransparency, options)
	if NAmanage.DrawingObjectSupported and not NAmanage.DrawingObjectSupported("Square") then
		return nil
	end
	const drawingLib = NAgui.getDrawingLibrary()
	if not drawingLib then
		return nil
	end
	local ok, square = pcall(function()
		return drawingLib.new("Square")
	end)
	if not ok or not square then
		if type(NAmanage._drawingObjectSupport) == "table" then
			NAmanage._drawingObjectSupport.Square = false
		end
		return nil
	end
	const alpha = NAgui.toDrawingTransparency(fillTransparency or 0.7)
	const thickness = math.max(1, tonumber(options and options.thickness) or 1)
	const filled = options and options.filled == true
	pcall(function()
		square.Visible = false
		square.Filled = filled
		square.Thickness = thickness
		square.Color = color or Color3.new(1, 1, 1)
		square.Transparency = alpha
	end)
	return square
end

NAmanage.DrawingUpdateSquare = function(square, inst, color, fillTransparency, options)
	if not square then return false end
	local minX, minY, width, height = NAgui.getInstanceViewportBounds(inst)
	if not minX then
		pcall(function()
			square.Visible = false
		end)
		return true
	end
	const alpha = NAgui.toDrawingTransparency(fillTransparency or 0.7)
	const thickness = math.max(1, tonumber(options and options.thickness) or 1)
	const filled = options and options.filled == true
	const ok = pcall(function()
		square.Color = color or Color3.new(1, 1, 1)
		square.Transparency = alpha
		square.Filled = filled
		square.Thickness = thickness
		square.Position = Vector2.new(minX, minY)
		square.Size = Vector2.new(width, height)
		square.Visible = true
	end)
	if not ok and type(NAmanage._drawingObjectSupport) == "table" then
		NAmanage._drawingObjectSupport.Square = false
	end
	return ok
end

NAmanage.DrawingCreateText = function(text, color, textSize, options)
	if NAmanage.DrawingObjectSupported and not NAmanage.DrawingObjectSupported("Text") then
		return nil
	end
	const drawingLib = NAgui.getDrawingLibrary()
	if not drawingLib then
		return nil
	end
	local ok, txt = pcall(function()
		return drawingLib.new("Text")
	end)
	if not ok or not txt then
		if type(NAmanage._drawingObjectSupport) == "table" then
			NAmanage._drawingObjectSupport.Text = false
		end
		return nil
	end
	local outlineEnabled
	if options and options.outlineEnabled ~= nil then
		outlineEnabled = options.outlineEnabled == true
	else
		outlineEnabled = NAStuff.ESP_DrawingTextOutline ~= false
	end
	local centered = options and options.centered
	if centered == nil then
		centered = NAStuff.ESP_DrawingTextCentered ~= false
	end
	const alpha = NAgui.sanitizeDrawingAlpha(options and options.textTransparency or NAStuff.ESP_DrawingTextTransparency or 0)
	const fontValue = NAgui.getDrawingTextFontValue(options and options.font or NAStuff.ESP_DrawingTextFont)
	pcall(function()
		txt.Visible = false
		txt.Center = centered ~= false
		txt.Outline = outlineEnabled
		txt.Color = color or Color3.new(1, 1, 1)
		txt.Size = NAgui.sanitizeLabelSize(textSize or 12)
		txt.Text = tostring(text or "")
		txt.Transparency = alpha
		txt.OutlineColor = Color3.new(0.05, 0.05, 0.05)
	end)
	pcall(function()
		txt.Font = fontValue
	end)
	return txt
end

NAmanage.DrawingUpdateText = function(txt, worldPos, text, color, textSize, options)
	if not txt then return false end
	const cam = Services.Workspace and Services.Workspace.CurrentCamera
	if not cam or not worldPos then
		pcall(function()
			txt.Visible = false
		end)
		return true
	end
	local viewportPoint, onScreen = cam:WorldToViewportPoint(worldPos)
	if viewportPoint.Z <= 0 or not onScreen then
		pcall(function()
			txt.Visible = false
		end)
		return true
	end
	local outlineEnabled
	if options and options.outlineEnabled ~= nil then
		outlineEnabled = options.outlineEnabled == true
	else
		outlineEnabled = NAStuff.ESP_DrawingTextOutline ~= false
	end
	local centered = options and options.centered
	if centered == nil then
		centered = NAStuff.ESP_DrawingTextCentered ~= false
	end
	const alpha = NAgui.sanitizeDrawingAlpha(options and options.textTransparency or NAStuff.ESP_DrawingTextTransparency or 0)
	const fontValue = NAgui.getDrawingTextFontValue(options and options.font or NAStuff.ESP_DrawingTextFont)
	const ok = pcall(function()
		txt.Text = tostring(text or "")
		txt.Color = color or Color3.new(1, 1, 1)
		txt.Size = NAgui.sanitizeLabelSize(textSize or 12)
		txt.Outline = outlineEnabled
		txt.Center = centered ~= false
		txt.Transparency = alpha
		txt.OutlineColor = Color3.new(0.05, 0.05, 0.05)
		txt.Position = Vector2.new(viewportPoint.X, viewportPoint.Y)
		txt.Visible = true
	end)
	pcall(function()
		txt.Font = fontValue
	end)
	if not ok and type(NAmanage._drawingObjectSupport) == "table" then
		NAmanage._drawingObjectSupport.Text = false
	end
	return ok
end

NAmanage.DrawingCreateLine = function(color, alpha, thickness)
	if NAmanage.DrawingLineSupported and not NAmanage.DrawingLineSupported() then
		return nil
	end
	const drawingLib = NAgui.getDrawingLibrary()
	if not drawingLib then
		return nil
	end
	local ok, line = pcall(function()
		return drawingLib.new("Line")
	end)
	if not ok or not line then
		if type(NAmanage._drawingObjectSupport) == "table" then
			NAmanage._drawingObjectSupport.Line = false
		end
		return nil
	end
	pcall(function()
		line.Visible = false
		line.Color = color or Color3.new(1, 1, 1)
		line.Transparency = math.clamp(tonumber(alpha) or 1, 0, 1)
		line.Thickness = math.max(1, tonumber(thickness) or 1)
		line.From = Vector2.new(0, 0)
		line.To = Vector2.new(0, 0)
	end)
	return line
end

NAmanage.DrawingUpdateLine = function(line, fromPos, toPos, color, alpha, thickness)
	if not line then return false end
	if typeof(fromPos) ~= "Vector2" or typeof(toPos) ~= "Vector2" then
		pcall(function()
			line.Visible = false
		end)
		return true
	end
	const ok = pcall(function()
		line.From = fromPos
		line.To = toPos
		line.Color = color or Color3.new(1, 1, 1)
		line.Transparency = math.clamp(tonumber(alpha) or 1, 0, 1)
		line.Thickness = math.max(1, tonumber(thickness) or 1)
		line.Visible = true
	end)
	if not ok and type(NAmanage._drawingObjectSupport) == "table" then
		NAmanage._drawingObjectSupport.Line = false
	end
	return ok
end

NAmanage.DrawingCreateTriangle = function(color, alpha)
	if NAmanage.DrawingTriangleSupported and not NAmanage.DrawingTriangleSupported() then
		return nil
	end
	const drawingLib = NAgui.getDrawingLibrary()
	if not drawingLib then
		return nil
	end
	local ok, tri = pcall(function()
		return drawingLib.new("Triangle")
	end)
	if not ok or not tri then
		if type(NAmanage._drawingObjectSupport) == "table" then
			NAmanage._drawingObjectSupport.Triangle = false
		end
		return nil
	end
	pcall(function()
		tri.Visible = false
		tri.Filled = true
		tri.Thickness = 1
		tri.Color = color or Color3.new(1, 1, 1)
		tri.Transparency = math.clamp(tonumber(alpha) or 1, 0, 1)
	end)
	return tri
end

NAmanage.DrawingUpdateTriangle = function(tri, centerX, centerY, dirX, dirY, size, color, alpha)
	if not tri then
		return
	end
	local dx = tonumber(dirX) or 0
	local dy = tonumber(dirY) or -1
	const mag = math.sqrt((dx * dx) + (dy * dy))
	if mag <= 1e-4 then
		dx, dy = 0, -1
	else
		dx, dy = dx / mag, dy / mag
	end
	const arrowSize = math.clamp(tonumber(size) or 26, 8, 256)
	const tip = arrowSize * 0.5
	const tail = arrowSize * 0.36
	const halfWidth = arrowSize * 0.32
	const px = -dy
	const py = dx
	const ax = centerX + (dx * tip)
	const ay = centerY + (dy * tip)
	const baseX = centerX - (dx * tail)
	const baseY = centerY - (dy * tail)
	const bx = baseX + (px * halfWidth)
	const by = baseY + (py * halfWidth)
	const cx = baseX - (px * halfWidth)
	const cy = baseY - (py * halfWidth)
	const ok = pcall(function()
		tri.Color = color or Color3.new(1, 1, 1)
		tri.Transparency = math.clamp(tonumber(alpha) or 1, 0, 1)
		tri.PointA = Vector2.new(ax, ay)
		tri.PointB = Vector2.new(bx, by)
		tri.PointC = Vector2.new(cx, cy)
		tri.Visible = true
	end)
	if not ok and type(NAmanage._drawingObjectSupport) == "table" then
		NAmanage._drawingObjectSupport.Triangle = false
	end
	return ok
end

NAgui.updateLabelBounds=function(label)
	if not label then return end
	const billboard = label.Parent
	if not billboard or not billboard:IsA("BillboardGui") then return end
	local text = label.Text
	if text == "" then
		text = label.Name or " "
	end
	const targetSize = NAgui.sanitizeLabelSize(NAStuff.ESP_LabelTextSize)
	local success, bounds = pcall(Services.TextService.GetTextSize, Services.TextService, text, targetSize, label.Font, Vector2.new(1e4, 1e4))
	local width = 150
	local height = math.max(targetSize + 12, 30)
	if success and bounds then
		width = math.clamp(math.floor(bounds.X + 16), 80, 600)
		height = math.clamp(math.floor(bounds.Y + 12), 24, 200)
	end
	const size = billboard.Size
	if size.X.Offset ~= width or size.Y.Offset ~= height then
		billboard.Size = UDim2.new(0, width, 0, height)
	end
end

NAgui.applyLabelStyle=function(label)
	if not label then return end
	label.AutomaticSize = Enum.AutomaticSize.None
	label.TextScaled = NAStuff.ESP_LabelTextScaled
	label.TextWrapped = false
	label.ClipsDescendants = false
	label.TextStrokeTransparency = math.clamp(tonumber(NAStuff.ESP_LabelStrokeTransparency) or 0.5, 0, 1)
	label.TextSize = NAgui.sanitizeLabelSize(NAStuff.ESP_LabelTextSize)
	NAgui.updateLabelBounds(label)
end

NAgui.updateLabelForInstance=function(inst)
	if not inst or not inst.Parent then return end
	for _, child in inst:GetChildren() do
		if child:IsA("BillboardGui") and Sub(Lower(child.Name),-6) == "_label" then
			const lbl = child:FindFirstChildWhichIsA("TextLabel")
			if lbl then
				NAgui.applyLabelStyle(lbl)
			end
		end
	end
end

NAmanage.ESP_ApplyLabelStyles = function()
	const scaled = (NAStuff.ESP_LabelTextScaled == true)
	const size = NAgui.sanitizeLabelSize(NAStuff.ESP_LabelTextSize)
	const seen = {}
	if NAStuff.partESPEntries then
		for _, entry in NAStuff.partESPEntries do
			if typeof(entry) == "table" and not seen[entry] then
				seen[entry] = true
				if entry.label then
					entry.label.TextScaled = scaled
					if not scaled then
						entry.label.TextSize = size
					end
				end
				if entry.drawingLabel then
					pcall(function()
						entry.drawingLabel.Size = size
						entry.drawingLabel.Outline = NAStuff.ESP_DrawingPartTextOutline ~= false
						entry.drawingLabel.Center = NAStuff.ESP_DrawingPartTextCentered ~= false
						entry.drawingLabel.Transparency = NAgui.sanitizeDrawingAlpha(NAStuff.ESP_DrawingPartTextTransparency or 0)
						entry.drawingLabel.Font = NAgui.getDrawingTextFontValue(NAStuff.ESP_DrawingTextFont)
						entry.drawingLabel.OutlineColor = Color3.new(0.05, 0.05, 0.05)
					end)
				end
			end
		end
	end
	if NAStuff.partESPVisualMap then
		for _, entry in NAStuff.partESPVisualMap do
			if typeof(entry) == "table" and not seen[entry] then
				seen[entry] = true
				if entry.label then
					entry.label.TextScaled = scaled
					if not scaled then
						entry.label.TextSize = size
					end
				end
				if entry.drawingLabel then
					pcall(function()
						entry.drawingLabel.Size = size
						entry.drawingLabel.Outline = NAStuff.ESP_DrawingPartTextOutline ~= false
						entry.drawingLabel.Center = NAStuff.ESP_DrawingPartTextCentered ~= false
						entry.drawingLabel.Transparency = NAgui.sanitizeDrawingAlpha(NAStuff.ESP_DrawingPartTextTransparency or 0)
						entry.drawingLabel.Font = NAgui.getDrawingTextFontValue(NAStuff.ESP_DrawingTextFont)
						entry.drawingLabel.OutlineColor = Color3.new(0.05, 0.05, 0.05)
					end)
				end
			end
		end
	end
	if type(espCONS) == "table" then
		for _, data in espCONS do
			if type(data) == "table" then
				if data.textLabel then
					data.textLabel.TextScaled = scaled
					if not scaled then
						data.textLabel.TextSize = size
					end
				end
				if data.drawingLabel then
					pcall(function()
						data.drawingLabel.Size = size
						data.drawingLabel.Outline = NAStuff.ESP_DrawingTextOutline ~= false
						data.drawingLabel.Center = NAStuff.ESP_DrawingTextCentered ~= false
						data.drawingLabel.Transparency = NAgui.sanitizeDrawingAlpha(NAStuff.ESP_DrawingTextTransparency or 0)
						data.drawingLabel.Font = NAgui.getDrawingTextFontValue(NAStuff.ESP_DrawingTextFont)
						data.drawingLabel.OutlineColor = Color3.new(0.05, 0.05, 0.05)
					end)
				end
			end
		end
	end
end

NAgui.adjustHighlightMaterialFor = function(target, enable)
	if not target then return end
	local originals = NAStuff.partESPGlassOriginal
	local counts = NAStuff.partESPGlassCount
	local ltOriginals = NAStuff.partESPLocalTransOriginal
	local ltCounts = NAStuff.partESPLocalTransCount
	if not originals then
		originals = NAmanage.ensureWeakTable(nil, "k")
		NAStuff.partESPGlassOriginal = originals
	else
		originals = NAmanage.ensureWeakTable(originals, "k")
		NAStuff.partESPGlassOriginal = originals
	end
	if not counts then
		counts = NAmanage.ensureWeakTable(nil, "k")
		NAStuff.partESPGlassCount = counts
	else
		counts = NAmanage.ensureWeakTable(counts, "k")
		NAStuff.partESPGlassCount = counts
	end
	if not ltOriginals then
		ltOriginals = NAmanage.ensureWeakTable(nil, "k")
		NAStuff.partESPLocalTransOriginal = ltOriginals
	else
		ltOriginals = NAmanage.ensureWeakTable(ltOriginals, "k")
		NAStuff.partESPLocalTransOriginal = ltOriginals
	end
	if not ltCounts then
		ltCounts = NAmanage.ensureWeakTable(nil, "k")
		NAStuff.partESPLocalTransCount = ltCounts
	else
		ltCounts = NAmanage.ensureWeakTable(ltCounts, "k")
		NAStuff.partESPLocalTransCount = ltCounts
	end
	const function handlePart(base)
		if not base or not base:IsA("BasePart") then return end
		local gCount = counts[base] or 0
		local tCount = ltCounts[base] or 0
		if enable then
			if gCount == 0 then
				originals[base] = base.Material
			end
			counts[base] = gCount + 1
			if base.Material ~= Enum.Material.Glass then
				NAlib.setProperty(base, "Material", Enum.Material.Glass)
			end
			if tCount == 0 then
				ltOriginals[base] = base.LocalTransparencyModifier
			end
			ltCounts[base] = tCount + 1
			if base.Transparency >= 1 or base.LocalTransparencyModifier >= 1 then
				NAlib.setProperty(base, "LocalTransparencyModifier", 0.999)
			end
		else
			if gCount > 0 then
				gCount -= 1
				if gCount <= 0 then
					counts[base] = nil
					const original = originals[base]
					if original ~= nil then
						NAlib.setProperty(base, "Material", original)
						originals[base] = nil
					end
				else
					counts[base] = gCount
				end
			end
			if tCount > 0 then
				tCount -= 1
				if tCount <= 0 then
					ltCounts[base] = nil
					const lt = ltOriginals[base]
					if lt ~= nil then
						NAlib.setProperty(base, "LocalTransparencyModifier", lt)
						ltOriginals[base] = nil
					end
				else
					ltCounts[base] = tCount
				end
			end
		end
	end
	if target:IsA("BasePart") then
		handlePart(target)
	elseif target:IsA("Model") then
		for _, desc in NAmanage.QueryDescendants(target, "BasePart") do
			handlePart(desc)
		end
	end
end

NAmanage.ESP_AdjustHighlightMaterial = function(target, enable)
	NAgui.adjustHighlightMaterialFor(target, enable)
end

NAStuff.partESPEntries = NAStuff.partESPEntries or {}
NAStuff.partESPVisualMap = NAmanage.ensureWeakTable(NAStuff.partESPVisualMap, "k")
NAStuff.partESPPartMap = NAmanage.ensureWeakTable(NAStuff.partESPPartMap, "k")
NAStuff.partESPQueueMap = NAmanage.ensureWeakTable(NAStuff.partESPQueueMap, "k")
NAStuff.partESPQueue = NAStuff.partESPQueue or {}
NAStuff.partESPQueueHead = tonumber(NAStuff.partESPQueueHead) or 1
NAStuff.partESPQueueTail = tonumber(NAStuff.partESPQueueTail) or 0
NAStuff.partESPActiveCount = tonumber(NAStuff.partESPActiveCount) or 0
NAStuff.partESPSweeps = NAStuff.partESPSweeps or {}
NAStuff.espScanTokens = NAStuff.espScanTokens or {}
NAStuff.espSweepCursor = NAStuff.espSweepCursor or {}
NAStuff.espNameApplicators = NAStuff.espNameApplicators or {}
NAStuff.espNameWatchers = NAmanage.ensureWeakTable(NAStuff.espNameWatchers, "k")
NAStuff.espNameWatchQueue = NAStuff.espNameWatchQueue or {}
NAStuff.espNameWatchQueueMap = NAmanage.ensureWeakTable(NAStuff.espNameWatchQueueMap, "k")
NAStuff.espNameWatchHead = tonumber(NAStuff.espNameWatchHead) or 1
NAStuff.espNameWatchTail = tonumber(NAStuff.espNameWatchTail) or 0

NAmanage.PartESP_QueueClear = function()
	NAStuff.partESPQueue = {}
	NAStuff.partESPQueueMap = NAmanage.ensureWeakTable(nil, "k")
	NAStuff.partESPQueueHead = 1
	NAStuff.partESPQueueTail = 0
	NAlib.disconnect("esp_part_queue")
end

NAmanage.PartESP_QueueRun = function()
	if NAlib.isConnected("esp_part_queue") then
		return
	end
	NAlib.connect("esp_part_queue", Services.RunService.Heartbeat:Connect(function()
		const queue = NAStuff.partESPQueue
		const qMap = NAStuff.partESPQueueMap
		local head = tonumber(NAStuff.partESPQueueHead) or 1
		const tail = tonumber(NAStuff.partESPQueueTail) or 0
		if head > tail then
			NAmanage.PartESP_QueueClear()
			return
		end

		local maxPerStep = tonumber(NAStuff.ESP_MaxPerStep) or 24
		if NAgui.espUsesDrawing("part") then
			maxPerStep = math.max(maxPerStep, tonumber(NAStuff.ESP_DrawingPartQueuePerStep) or 64)
		end
		maxPerStep = math.clamp(math.floor(maxPerStep), 1, 512)
		local processed = 0
		while processed < maxPerStep and head <= tail do
			const item = queue[head]
			queue[head] = nil
			head += 1
			processed += 1
			if item then
				const part = item.part
				if qMap[part] == item then
					qMap[part] = nil
				end
				if part and part.Parent and (part:IsA("BasePart") or part:IsA("Model")) then
					local canCreate = true
					if type(item.guard) == "function" then
						local ok, result = pcall(item.guard, part, item)
						canCreate = ok and result == true
					end
					if canCreate then
						NAmanage.CreateBox(part, item.color, item.transparency, item.customName)
					end
				end
			end
		end

		NAStuff.partESPQueueHead = head
		NAStuff.partESPQueueTail = tail
		if head > tail then
			NAmanage.PartESP_QueueClear()
		end
	end))
end

NAmanage.PartESP_QueueCreate = function(part, color, transparency, guard, customName)
	if not part or not part.Parent then
		return
	end
	if not (part:IsA("BasePart") or part:IsA("Model")) then
		return
	end
	if type(NAmanage.PartESP_CanCreateFor) == "function" and not NAmanage.PartESP_CanCreateFor(part) then
		NAStuff.partESPSkippedLimit = (tonumber(NAStuff.partESPSkippedLimit) or 0) + 1
		return
	end
	const qMap = NAStuff.partESPQueueMap
	const existing = qMap[part]
	if existing then
		existing.color = color
		existing.transparency = transparency
		existing.guard = guard
		existing.customName = customName
		return
	end
	const queue = NAStuff.partESPQueue
	const tail = (tonumber(NAStuff.partESPQueueTail) or 0) + 1
	const item = {
		part = part,
		color = color,
		transparency = transparency,
		guard = guard,
		customName = customName,
	}
	queue[tail] = item
	qMap[part] = item
	NAStuff.partESPQueueTail = tail
	NAmanage.PartESP_QueueRun()
end

NAmanage.PartESP_QueueRemove = function(part)
	if not part then
		return false
	end
	const qMap = NAStuff.partESPQueueMap
	if type(qMap) ~= "table" then
		return false
	end
	const item = qMap[part]
	if not item then
		return false
	end
	qMap[part] = nil
	item.part = nil
	item.guard = nil
	return true
end

NAmanage.PartESP_MaxActive = function()
	local cap = math.clamp(math.floor(tonumber(NAStuff.ESP_PartMaxActive) or 450), 50, 5000)
	local mode = nil
	pcall(function()
		mode = NAgui.getESPRenderMode("part")
	end)
	if mode == "Highlight" then
		cap = math.min(cap, 255)
	end
	return cap
end

NAmanage.PartESP_CanCreateFor = function(part)
	if not part then
		return false
	end
	const partMap = NAStuff.partESPPartMap
	if type(partMap) == "table" and partMap[part] ~= nil then
		return true
	end
	const qMap = NAStuff.partESPQueueMap
	if type(qMap) == "table" and qMap[part] ~= nil then
		return true
	end
	return (tonumber(NAStuff.partESPActiveCount) or 0) < NAmanage.PartESP_MaxActive()
end

NAmanage.PartESP_StartSweep = function(key, predicate, budget, intervalOverride)
	if type(key) ~= "string" or key == "" or type(predicate) ~= "function" then
		return
	end
	local sweeps = NAStuff.partESPSweeps
	if type(sweeps) ~= "table" then
		sweeps = {}
		NAStuff.partESPSweeps = sweeps
	end
	local state = sweeps[key]
	if type(state) ~= "table" then
		state = {}
		sweeps[key] = state
	end
	state.predicate = predicate
	state.budget = math.clamp(math.floor(tonumber(budget) or tonumber(NAStuff.ESP_RescanPerStep) or 90), 8, 400)
	state.intervalOverride = tonumber(intervalOverride)
	state.interval = math.clamp(state.intervalOverride or tonumber(NAStuff.ESP_PartSweepInterval) or 4, 0.75, 60)

	const function resolveInterval()
		return math.clamp(tonumber(state.intervalOverride) or tonumber(NAStuff.ESP_PartSweepInterval) or tonumber(state.interval) or 4, 0.75, 60)
	end

	const function runSweep()
		if state.running then
			return
		end
		state.running = true
		const token = NAmanage.NewCancelToken()
		state.token = token
		SpawnCall(function()
			NAmanage.ForEachWorkspaceYield(function(obj)
				if token.cancelled or not NAlib.isConnected(key) then
					NAmanage.CancelTokenCancel(token)
					return
				end
				const fn = state.predicate
				if type(fn) == "function" then
					pcall(fn, obj)
				end
			end, {
				yieldEvery = state.budget,
				delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
				cancelToken = token,
			})
			if state.token == token then
				state.running = false
				state.nextRun = tick() + resolveInterval()
			end
		end)
	end

	if not NAlib.isConnected(key) then
		state.nextRun = 0
		NAlib.connect(key, Services.RunService.Heartbeat:Connect(function()
			const active = NAStuff.partESPSweeps and NAStuff.partESPSweeps[key]
			if active ~= state then
				NAlib.disconnect(key)
				return
			end
			const now = tick()
			if not state.running and now >= (tonumber(state.nextRun) or 0) then
				state.interval = resolveInterval()
				state.nextRun = now + state.interval
				runSweep()
			end
		end))
	else
		state.nextRun = 0
	end
	runSweep()
end

NAmanage.PartESP_StopSweep = function(key)
	if type(key) ~= "string" or key == "" then
		return
	end
	const sweeps = NAStuff.partESPSweeps
	const state = type(sweeps) == "table" and sweeps[key] or nil
	if state and state.token then
		NAmanage.CancelTokenCancel(state.token)
	end
	if type(sweeps) == "table" then
		sweeps[key] = nil
	end
	NAlib.disconnect(key)
	if NAStuff.espSweepCursor then
		NAStuff.espSweepCursor[key] = nil
	end
end

NAmanage.ESP_ClearOcclusionCache = function()
	NAStuff.ESP_OcclusionCache = setmetatable({}, { __mode = "k" })
	NAStuff.ESP_OcclusionFrame = nil
	NAStuff.ESP_OcclusionUsed = 0
	NAStuff.ESP_OcclusionRaycastParams = nil
	NAStuff.partESPLastUpdate = 0
	if type(espCONS) == "table" then
		for _, data in espCONS do
			if data then
				data.next = 0
			end
		end
	end
end

NAmanage.ESP_GetOccludedColor = function(color)
	if typeof(color) ~= "Color3" then
		color = Color3.new(1, 1, 1)
	end
	local blockedColor = NAStuff.ESP_OcclusionColor
	if typeof(blockedColor) ~= "Color3" then
		blockedColor = Color3.fromRGB(130, 130, 130)
	end
	const amount = math.clamp(tonumber(NAStuff.ESP_OcclusionDimAmount) or 0.55, 0, 1)
	return color:Lerp(blockedColor, amount)
end

NAmanage.ESP_GetOccludedTransparency = function(transparency)
	const base = NAgui.sanitizeTransparency(transparency)
	const amount = math.clamp(tonumber(NAStuff.ESP_OcclusionDimAmount) or 0.55, 0, 1)
	return math.clamp(base + ((1 - base) * amount), 0, 1)
end

NAmanage.ESP_CanSpendOcclusionRay = function(now)
	now = tonumber(now) or tick()
	const frame = math.floor(now * 30)
	if NAStuff.ESP_OcclusionFrame ~= frame then
		NAStuff.ESP_OcclusionFrame = frame
		NAStuff.ESP_OcclusionUsed = 0
	end
	const maxPerStep = math.clamp(math.floor(tonumber(NAStuff.ESP_OcclusionMaxPerStep) or 12), 1, 128)
	const used = tonumber(NAStuff.ESP_OcclusionUsed) or 0
	if used >= maxPerStep then
		return false
	end
	NAStuff.ESP_OcclusionUsed = used + 1
	return true
end

NAmanage.ESP_ShouldIgnoreOcclusionHit = function(inst)
	if not (inst and typeof(inst) == "Instance") then
		return false
	end
	if inst:IsA("BasePart") then
		if NAStuff.ESP_OcclusionIgnoreNonCollidable == true then
			local ok, canCollide = pcall(function()
				return inst.CanCollide
			end)
			if ok and canCollide == false then
				return true
			end
		end
		if NAStuff.ESP_OcclusionIgnoreTransparent == true then
			const threshold = math.clamp(tonumber(NAStuff.ESP_OcclusionTransparentThreshold) or 0.85, 0, 1)
			local transparency = 0
			pcall(function()
				transparency = math.max(tonumber(inst.Transparency) or 0, tonumber(inst.LocalTransparencyModifier) or 0)
			end)
			if transparency >= threshold then
				return true
			end
		end
	end
	return false
end

NAmanage.ESP_GetOcclusionFilterList = function(inst, localChar, opts)
	const filter = {}
	if localChar then
		filter[#filter + 1] = localChar
	end
	if typeof(inst) == "Instance" then
		if opts and opts.partESP == true and NAStuff.ESP_OcclusionIgnoreSameModel == true then
			const parent = inst.Parent
			if parent and parent:IsA("Model") then
				filter[#filter + 1] = parent
			else
				filter[#filter + 1] = inst
			end
		else
			filter[#filter + 1] = inst
		end
	end
	return filter
end

NAmanage.ESP_RaycastOccluded = function(inst, targetPos, localChar, opts)
	const cam = Services.Workspace and Services.Workspace.CurrentCamera
	if not (cam and Services.Workspace and Services.Workspace.Raycast and targetPos) then
		return false
	end
	const origin = cam.CFrame.Position
	const direction = targetPos - origin
	const distance = direction.Magnitude
	if distance <= 0.5 then
		return false
	end
	const maxDistance = tonumber(NAStuff.ESP_OcclusionMaxDistance) or 1500
	if maxDistance > 0 and distance > maxDistance then
		return false
	end
	local params = NAStuff.ESP_OcclusionRaycastParams
	if not params then
		params = RaycastParams.new()
		const okFilter = pcall(function()
			params.FilterType = Enum.RaycastFilterType.Exclude
		end)
		if not okFilter then
			pcall(function()
				params.FilterType = Enum.RaycastFilterType.Blacklist
			end)
		end
		params.IgnoreWater = true
		NAStuff.ESP_OcclusionRaycastParams = params
	end
	params.IgnoreWater = true
	const filter = NAmanage.ESP_GetOcclusionFilterList(inst, localChar, opts)
	const probeLimit = math.clamp(math.floor(tonumber(NAStuff.ESP_OcclusionHitProbeLimit) or 4), 1, 20)
	for _ = 1, probeLimit do
		params.FilterDescendantsInstances = filter
		const result = Services.Workspace:Raycast(origin, direction, params)
		if not result then
			return false
		end
		const hit = result.Instance
		if hit and NAmanage.ESP_ShouldIgnoreOcclusionHit(hit) then
			filter[#filter + 1] = hit
		else
			return result.Distance < (distance - 0.5)
		end
	end
	return false
end

NAmanage.ESP_GetOcclusionState = function(key, inst, targetPos, localChar, now, force, opts)
	if NAStuff.ESP_OcclusionEnabled ~= true then
		return false
	end
	if not targetPos then
		return false
	end
	local cache = NAStuff.ESP_OcclusionCache
	if type(cache) ~= "table" then
		cache = setmetatable({}, { __mode = "k" })
		NAStuff.ESP_OcclusionCache = cache
	end
	key = key or inst
	if key == nil then
		return false
	end
	now = tonumber(now) or tick()
	local entry = cache[key]
	const interval = math.clamp(tonumber(NAStuff.ESP_OcclusionUpdateInterval) or 0.25, 0.05, 1)
	if entry and not force and now < (entry.next or 0) then
		return entry.blocked == true
	end
	if not force and not NAmanage.ESP_CanSpendOcclusionRay(now) then
		return entry and entry.blocked == true or false
	end
	entry = entry or {}
	entry.blocked = NAmanage.ESP_RaycastOccluded(inst, targetPos, localChar, opts) == true
	entry.next = now + interval
	cache[key] = entry
	return entry.blocked == true
end
