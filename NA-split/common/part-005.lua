NAmanage.NAConsoleExportRecords = NAmanage.NAConsoleExportRecords or function(records, formatName)
	if type(records) ~= "table" then
		return false, "NA Console records are unavailable."
	end
	if type(writefile) ~= "function" then
		return false, "writefile is unavailable."
	end
	formatName = Lower(tostring(formatName or "txt"))
	if formatName ~= "json" then
		formatName = "txt"
	end
	const root = "Nameless-Admin"
	const dir = root.."/ConsoleLogs"
	if type(makefolder) == "function" then
		pcall(function() if type(isfolder) ~= "function" or not isfolder(root) then makefolder(root) end end)
		pcall(function() if type(isfolder) ~= "function" or not isfolder(dir) then makefolder(dir) end end)
	end
	local stamp = "session"
	pcall(function() stamp = os.date("%Y%m%d_%H%M%S") end)
	local path = dir.."/NA_Console_"..stamp.."."..formatName
	if type(isfile) == "function" and isfile(path) then
		local index = 2
		repeat
			path = dir.."/NA_Console_"..stamp.."_"..tostring(index).."."..formatName
			index += 1
		until not isfile(path)
	end
	local data
	if formatName == "json" then
		const exported = {}
		for i = 1, #records do
			const record = records[i]
			if type(record) == "table" then
				exported[#exported + 1] = {
					id = record.id,
					type = record.tag,
					message = record.raw,
					source = record.source,
					subsystem = record.subsystem,
					context = record.context,
					timestamp = record.timestamp,
					firstSeen = record.timeText,
					lastSeen = record.lastTimeText or record.timeText,
					count = math.max(1, tonumber(record.duplicateCount) or 1),
				}
			end
		end
		local ok, encoded = pcall(function()
			return Services.HttpService:JSONEncode({
				generatedAt = os.time and os.time() or nil,
				placeId = game.PlaceId,
				gameId = game.GameId,
				jobId = game.JobId,
				count = #exported,
				records = exported,
			})
		end)
		if not ok then
			return false, "Failed to encode console JSON: "..tostring(encoded)
		end
		data = encoded
	else
		const lines = {
			"Nameless Admin Console Export",
			"PlaceId: "..tostring(game.PlaceId).." | GameId: "..tostring(game.GameId).." | JobId: "..tostring(game.JobId),
			"Entries: "..tostring(#records),
			"",
		}
		for i = 1, #records do
			const record = records[i]
			if type(record) == "table" then
				lines[#lines + 1] = tostring(record.copyText or record.plainText or record.raw or "")
			end
		end
		data = Concat(lines, "\r\n")
	end
	local ok, err = pcall(writefile, path, data)
	if not ok then
		return false, "Failed to export console: "..tostring(err)
	end
	return true, path, #records
end

NAmanage.NAConsoleExport = NAmanage.NAConsoleExport or function(formatName)
	if type(NAmanage._NAConsoleExternalExport) == "function" then
		return NAmanage._NAConsoleExternalExport(formatName)
	end
	if type(NAStuff.NAConsoleRuntimeRecords) ~= "table" and type(NAmanage.bindToDevConsole) == "function" then
		pcall(NAmanage.bindToDevConsole)
	end
	if type(NAmanage._NAConsoleExternalExport) == "function" then
		return NAmanage._NAConsoleExternalExport(formatName)
	end
	if type(NAStuff.NAConsoleRuntimeRecords) == "table" then
		return NAmanage.NAConsoleExportRecords(NAStuff.NAConsoleRuntimeRecords, formatName)
	end
	return false, "NA Console records are unavailable."
end

NAmanage.NAConsoleWrite = NAmanage.NAConsoleWrite or function(text, tag, context)
	tag = NAmanage.NAConsoleNormalizeTag(tag)
	text = tostring(text or "")
	context = NAmanage.NAConsoleNormalizeContext(context)
	if context.source == nil then
		context.source = "NamelessAdmin"
	end
	if type(NAmanage._NAConsoleExternalWrite) == "function" then
		return NAmanage._NAConsoleExternalWrite(text, tag, context)
	end
	local pending = NAStuff.NAConsoleExternalPending
	if type(pending) ~= "table" then
		pending = {}
		NAStuff.NAConsoleExternalPending = pending
	end
	pending[#pending + 1] = {
		text = text,
		tag = tag,
		context = context,
		timestamp = os.time and os.time() or nil,
	}
	return true
end

NAmanage.NAConsoleStructuredLog = NAmanage.NAConsoleStructuredLog or function(text, tag, context)
	tag = NAmanage.NAConsoleNormalizeTag(tag)
	text = tostring(text or "")
	context = NAmanage.NAConsoleNormalizeContext(context)
	if context.source == nil then context.source = "NamelessAdmin" end
	if tag == "Error" then
		return NAmanage.NAConsoleWrite(text, tag, context)
	end
	const logService = Services.LogService or SafeGetService("LogService")
	const methodName = tag == "Warn" and "Warn" or (tag == "Info" and "Info" or "Output")
	if logService and type(__lt) == "table" and type(__lt.cm) == "function" then
		const templateSafeText = text:gsub("{", "{{"):gsub("}", "}}")
		local ok = pcall(function()
			__lt.cm("LogService", methodName, templateSafeText, context)
		end)
		if ok then
			return true
		end
	end
	return NAmanage.NAConsoleWrite(text, tag, context)
end

NAmanage.NAConsoleClear = NAmanage.NAConsoleClear or function()
	if type(NAmanage._NAConsoleExternalClear) == "function" then
		return NAmanage._NAConsoleExternalClear()
	end
	NAStuff.NAConsoleExternalPending = {}
	return true
end

NAmanage.NAConsoleShow = NAmanage.NAConsoleShow or function()
	if NAgui and NAgui.consoleeee then
		pcall(NAgui.consoleeee)
	elseif NAUIMANAGER and NAUIMANAGER.NAconsoleFrame then
		NAUIMANAGER.NAconsoleFrame.Visible = true
		if NAmanage.centerFrame then
			pcall(NAmanage.centerFrame, NAUIMANAGER.NAconsoleFrame)
		end
	end
	return true
end

NAmanage.NAConsoleHide = NAmanage.NAConsoleHide or function()
	if NAUIMANAGER and NAUIMANAGER.NAconsoleFrame then
		NAUIMANAGER.NAconsoleFrame.Visible = false
	end
	return true
end

NAmanage.NAConsoleSetTitle = NAmanage.NAConsoleSetTitle or function(title)
	NAStuff.NAConsoleTitle = tostring(title or "")
	const frame = NAUIMANAGER and NAUIMANAGER.NAconsoleFrame
	if frame then
		const titleLabel = frame:FindFirstChild("Title", true) or frame:FindFirstChild("TextLabel", true)
		if titleLabel and titleLabel:IsA("TextLabel") then
			titleLabel.Text = NAStuff.NAConsoleTitle
		end
	end
	return true
end

NAmanage.RConsoleJoinArgs = NAmanage.RConsoleJoinArgs or function(...)
	const argc = select("#", ...)
	if argc <= 0 then
		return ""
	end
	const parts = {}
	for i = 1, argc do
		parts[#parts + 1] = tostring(select(i, ...))
	end
	return Concat(parts, " ")
end

NAmanage.GetRConsoleWrapper = NAmanage.GetRConsoleWrapper or function(name)
	NAmanage.RConsoleWrappers = NAmanage.RConsoleWrappers or {}
	if NAmanage.RConsoleWrappers[name] then
		return NAmanage.RConsoleWrappers[name]
	end
	local fn
	if name == "rconsoleclear" then
		fn = function()
			return NAmanage.NAConsoleClear()
		end
	elseif name == "rconsolecreate" then
		fn = function()
			return NAmanage.NAConsoleShow()
		end
	elseif name == "rconsoledestroy" or name == "rconsoleclose" then
		fn = function()
			return NAmanage.NAConsoleHide()
		end
	elseif name == "rconsolename" then
		fn = function(title)
			return NAmanage.NAConsoleSetTitle(title)
		end
	elseif name == "rconsoleinput" then
		fn = function()
			NAmanage.NAConsoleWrite("[NA] rconsoleinput is not interactive here; returning an empty string.", "Warn")
			return ""
		end
	else
		local tag = "Output"
		if name == "rconsolewarn" then
			tag = "Warn"
		elseif name == "rconsoleerr" or name == "rconsoleerror" then
			tag = "Error"
		elseif name == "rconsoleinfo" then
			tag = "Info"
		end
		fn = function(...)
			return NAmanage.NAConsoleWrite(NAmanage.RConsoleJoinArgs(...), tag)
		end
	end
	NAmanage.RConsoleWrappers[name] = fn
	return fn
end

NAmanage.SetForceRconsoleNAConsole = NAmanage.SetForceRconsoleNAConsole or function(state, opts)
	opts = opts or {}
	state = state ~= false
	const prev = NAStuff.ForceRconsoleNAConsole == true
	NAStuff.ForceRconsoleNAConsole = state
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "forceRconsoleNAConsole", state)
	end
	local rcState = NAStuff.RConsoleFunctionState
	if type(rcState) ~= "table" then
		rcState = { originals = {} }
		NAStuff.RConsoleFunctionState = rcState
	end
	if type(rcState.originals) ~= "table" then
		rcState.originals = {}
	end
	if not opts.force and prev == state then
		return state
	end
	const stores = NAmanage.GetUnsafeFunctionStores()
	const names = NAmanage.RConsoleFunctionNames or {}
	if state then
		for i = 1, #stores do
			const store = stores[i]
			local originals = rcState.originals[store]
			if type(originals) ~= "table" then
				originals = {}
				rcState.originals[store] = originals
			end
			for j = 1, #names do
				const name = names[j]
				const wrapper = NAmanage.GetRConsoleWrapper(name)
				const current = rawget(store, name)
				if originals[name] == nil and current ~= nil and current ~= wrapper then
					originals[name] = current
				end
				pcall(rawset, store, name, wrapper)
			end
		end
	else
		for store, originals in rcState.originals do
			if type(store) == "table" and type(originals) == "table" then
				for _, name in names do
					pcall(rawset, store, name, originals[name])
				end
			end
		end
		if NAStuff.UnsafeFunctionsDisabled == true and NAmanage.SetUnsafeFunctionsDisabled then
			pcall(NAmanage.SetUnsafeFunctionsDisabled, true, {
				save = false;
				silent = true;
				force = true;
			})
		end
	end
	if not opts.silent and DoNotif then
		DoNotif("rconsole API now uses "..(state and "NA console" or "executor defaults"), 2)
	end
	return state
end

NAmanage.SetUnsafeFunctionsDisabled = NAmanage.SetUnsafeFunctionsDisabled or function(state, opts)
	opts = opts or {}
	state = state == true
	const prev = NAStuff.UnsafeFunctionsDisabled == true
	NAStuff.UnsafeFunctionsDisabled = state
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "disableUnsafeFunctions", state)
	end
	local unsafeState = NAStuff.UnsafeFunctionState
	if type(unsafeState) ~= "table" then
		unsafeState = { originals = {} }
		NAStuff.UnsafeFunctionState = unsafeState
	end
	if type(unsafeState.originals) ~= "table" then
		unsafeState.originals = {}
	end
	if not opts.force and prev == state then
		return state
	end
	const names = NAmanage.UnsafeFunctionNames or {}
	const stores = NAmanage.GetUnsafeFunctionStores()
	if state then
		for i = 1, #stores do
			const store = stores[i]
			local originals = unsafeState.originals[store]
			if type(originals) ~= "table" then
				originals = {}
				unsafeState.originals[store] = originals
			end
			for j = 1, #names do
				const name = names[j]
				const current = rawget(store, name)
				if originals[name] == nil and current ~= nil then
					originals[name] = current
				end
				if NAStuff.ForceRconsoleNAConsole == true and NAmanage.RConsoleFunctionSet and NAmanage.RConsoleFunctionSet[name] then
					pcall(rawset, store, name, NAmanage.GetRConsoleWrapper(name))
				else
					pcall(rawset, store, name, nil)
				end
			end
		end
	else
		for store, originals in unsafeState.originals do
			if type(store) == "table" and type(originals) == "table" then
				for name, original in originals do
					pcall(rawset, store, name, original)
				end
			end
		end
		if NAStuff.ForceRconsoleNAConsole == true and NAmanage.SetForceRconsoleNAConsole then
			pcall(NAmanage.SetForceRconsoleNAConsole, true, {
				save = false;
				silent = true;
				force = true;
			})
		end
	end
	if not opts.silent and DoNotif then
		DoNotif("Unsafe functions "..(state and "disabled" or "restored"), 2)
	end
	return state
end

NAmanage.SetFunctionGroupDisabled = NAmanage.SetFunctionGroupDisabled or function(state, opts, config)
	opts = opts or {}
	config = config or {}
	state = state == true
	const stateKey = tostring(config.stateKey or "")
	const stateStoreKey = tostring(config.stateStoreKey or "")
	const settingsKey = tostring(config.settingsKey or "")
	const label = tostring(config.label or "Functions")
	const names = type(config.names) == "table" and config.names or {}
	if stateKey == "" or stateStoreKey == "" then
		return false
	end
	const prev = NAStuff[stateKey] == true
	NAStuff[stateKey] = state
	if opts.save ~= false and settingsKey ~= "" and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, settingsKey, state)
	end
	local groupState = NAStuff[stateStoreKey]
	if type(groupState) ~= "table" then
		groupState = { originals = {} }
		NAStuff[stateStoreKey] = groupState
	end
	if type(groupState.originals) ~= "table" then
		groupState.originals = {}
	end
	if not opts.force and prev == state then
		return state
	end
	const stores = NAmanage.GetUnsafeFunctionStores()
	if state then
		for i = 1, #stores do
			const store = stores[i]
			local originals = groupState.originals[store]
			if type(originals) ~= "table" then
				originals = {}
				groupState.originals[store] = originals
			end
			for j = 1, #names do
				const name = names[j]
				const current = rawget(store, name)
				if originals[name] == nil and current ~= nil then
					originals[name] = current
				end
				pcall(rawset, store, name, nil)
			end
		end
	else
		for store, originals in groupState.originals do
			if type(store) == "table" and type(originals) == "table" then
				for name, original in originals do
					pcall(rawset, store, name, original)
				end
			end
		end
	end
	if not opts.silent and DoNotif then
		DoNotif(label.." "..(state and "disabled" or "restored"), 2)
	end
	return state
end

NAmanage.SetVirtualInputAPIDisabled = NAmanage.SetVirtualInputAPIDisabled or function(state, opts)
	return NAmanage.SetFunctionGroupDisabled(state, opts, {
		stateKey = "VirtualInputAPIDisabled";
		stateStoreKey = "VirtualInputAPIState";
		settingsKey = "disableVirtualInputAPI";
		label = "Virtual input API";
		names = NAmanage.VirtualInputFunctionNames;
	})
end

NAmanage.ApplyHWIDFunctionPolicy = NAmanage.ApplyHWIDFunctionPolicy or function(opts)
	opts = opts or {}
	local hwidState = NAStuff.HWIDFunctionState
	if type(hwidState) ~= "table" then
		hwidState = { originals = {}; captured = {} }
		NAStuff.HWIDFunctionState = hwidState
	end
	if type(hwidState.originals) ~= "table" then
		hwidState.originals = {}
	end
	if type(hwidState.captured) ~= "table" then
		hwidState.captured = {}
	end

	const names = NAmanage.HWIDFunctionNames or {}
	const stores = NAmanage.GetUnsafeFunctionStores()
	const disabled = NAStuff.HWIDFunctionsDisabled == true
	const spoofed = NAStuff.HWIDSpoofEnabled == true
	const spoofFn = function(...)
		return tostring(NAStuff.HWIDSpoofValue or "")
	end

	for i = 1, #stores do
		const store = stores[i]
		local originals = hwidState.originals[store]
		if type(originals) ~= "table" then
			originals = {}
			hwidState.originals[store] = originals
		end
		local captured = hwidState.captured[store]
		if type(captured) ~= "table" then
			captured = {}
			hwidState.captured[store] = captured
		end
		for j = 1, #names do
			const name = names[j]
			if captured[name] ~= true then
				originals[name] = rawget(store, name)
				captured[name] = true
			end
			if disabled then
				pcall(rawset, store, name, nil)
			elseif spoofed then
				pcall(rawset, store, name, spoofFn)
			else
				pcall(rawset, store, name, originals[name])
			end
		end
	end
	return true
end

NAmanage.SetHWIDFunctionsDisabled = NAmanage.SetHWIDFunctionsDisabled or function(state, opts)
	opts = opts or {}
	state = state == true
	NAStuff.HWIDFunctionsDisabled = state
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "disableHWIDFunctions", state)
	end
	NAmanage.ApplyHWIDFunctionPolicy({ force = true })
	if not opts.silent and DoNotif then
		DoNotif("HWID functions "..(state and "disabled" or "restored"), 2)
	end
	return state
end

NAmanage.SetHWIDSpoofEnabled = NAmanage.SetHWIDSpoofEnabled or function(state, opts)
	opts = opts or {}
	state = state == true
	NAStuff.HWIDSpoofEnabled = state
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "spoofHWID", state)
	end
	NAmanage.ApplyHWIDFunctionPolicy({ force = true })
	if not opts.silent and DoNotif then
		DoNotif("HWID spoof "..(state and "enabled" or "disabled"), 2)
	end
	return state
end

NAmanage.SetHWIDSpoofValue = NAmanage.SetHWIDSpoofValue or function(value, opts)
	opts = opts or {}
	value = tostring(value or "")
	NAStuff.HWIDSpoofValue = value
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "spoofedHWID", value)
	end
	if NAStuff.HWIDSpoofEnabled == true then
		NAmanage.ApplyHWIDFunctionPolicy({ force = true })
	end
	if not opts.silent and DoNotif then
		DoNotif("Spoofed HWID updated", 2)
	end
	return value
end

NAmanage.ApplyClientIDSpoof = NAmanage.ApplyClientIDSpoof or function(opts)
	opts = opts or {}
	local spoofState = NAStuff.ClientIDSpoofState
	if type(spoofState) ~= "table" then
		spoofState = {
			hooked = false;
			directTarget = nil;
			directOriginal = nil;
		}
		NAStuff.ClientIDSpoofState = spoofState
	end

	local host = type(_na_boot) == "table" and _na_boot.hostEnv or nil
	local hookFn = type(host) == "table" and rawget(host, "hookfunction") or nil
	if type(hookFn) ~= "function" then
		hookFn = hookfunction
	end

	if NAStuff.ClientIDSpoofEnabled ~= true then
		if spoofState.hooked == true and type(hookFn) == "function" then
			if type(spoofState.directTarget) == "function" and type(spoofState.directOriginal) == "function" then
				pcall(hookFn, spoofState.directTarget, spoofState.directOriginal)
			end
		end
		spoofState.hooked = false
		spoofState.directTarget = nil
		spoofState.directOriginal = nil
		return true
	end
	if spoofState.hooked == true then
		return true
	end

	local service
	if Services and Services.RbxAnalyticsService then
		service = Services.RbxAnalyticsService
	else
		pcall(function()
			service = game:GetService("RbxAnalyticsService")
		end)
	end
	local directTarget = service and service.GetClientId or nil
	local newC = type(host) == "table" and rawget(host, "newcclosure") or nil
	if type(newC) ~= "function" then
		newC = newcclosure
	end
	if type(directTarget) ~= "function" or type(hookFn) ~= "function" then
		return false
	end

	local directOriginal
	local directWrapper = function(self, ...)
		if NAStuff.ClientIDSpoofEnabled == true then
			return tostring(NAStuff.ClientIDSpoofValue or "")
		end
		return directOriginal(self, ...)
	end
	if type(newC) == "function" then
		local ok, wrapped = pcall(newC, directWrapper)
		if ok and type(wrapped) == "function" then
			directWrapper = wrapped
		end
	end
	local okDirect, oldDirect = pcall(hookFn, directTarget, directWrapper)
	if not okDirect or type(oldDirect) ~= "function" then
		return false
	end
	directOriginal = oldDirect

	spoofState.hooked = true
	spoofState.directTarget = directTarget
	spoofState.directOriginal = oldDirect
	return true
end

NAmanage.SetClientIDSpoofEnabled = NAmanage.SetClientIDSpoofEnabled or function(state, opts)
	opts = opts or {}
	state = state == true
	NAStuff.ClientIDSpoofEnabled = state
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "spoofClientID", state)
	end
	local ok = NAmanage.ApplyClientIDSpoof({ force = true })
	if state and ok ~= true then
		NAStuff.ClientIDSpoofEnabled = false
		if opts.save ~= false and NAmanage.NASettingsSet then
			pcall(NAmanage.NASettingsSet, "spoofClientID", false)
		end
		if not opts.silent and DoNotif then
			DoNotif("Client ID spoof unavailable: executor cannot hook RbxAnalyticsService.GetClientId", 4)
		end
		return false
	end
	if not opts.silent and DoNotif then
		if state then
			DoNotif("Client ID spoof enabled", 2)
		else
			DoNotif("Client ID spoof disabled", 2)
		end
	end
	return state
end

NAmanage.SetClientIDSpoofValue = NAmanage.SetClientIDSpoofValue or function(value, opts)
	opts = opts or {}
	value = tostring(value or "")
	NAStuff.ClientIDSpoofValue = value
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "spoofedClientID", value)
	end
	if not opts.silent and DoNotif then
		DoNotif("Spoofed Client ID updated", 2)
	end
	return value
end

NAmanage.SetSynEnv = NAmanage.SetSynEnv or function(state, opts)
	opts = opts or {}
	state = state == true
	const prev = NAStuff.SynEnvEnabled == true
	NAStuff.SynEnvEnabled = state
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "synEnv", state)
	end

	local synState = NAStuff.SynEnvState
	if type(synState) ~= "table" then
		synState = { captured = false; originalSyn = nil; createdSyn = false; added = {} }
		NAStuff.SynEnvState = synState
	end
	if type(synState.added) ~= "table" then
		synState.added = {}
	end

	local host = type(_na_boot) == "table" and _na_boot.hostEnv or nil
	if type(host) ~= "table" and type(getgenv) == "function" then
		local ok, env = pcall(getgenv)
		if ok and type(env) == "table" then
			host = env
		end
	end
	if type(host) ~= "table" then
		if not opts.silent and DoNotif then
			DoNotif("Syn env is unavailable because the executor global environment could not be resolved", 3)
		end
		return false
	end

	if not synState.captured then
		synState.originalSyn = rawget(host, "syn")
		synState.captured = true
	end

	const function first(...)
		for i = 1, select("#", ...) do
			const value = select(i, ...)
			if value ~= nil then
				return value
			end
		end
		return nil
	end

	const function add(target, key, value)
		if type(target) ~= "table" or value == nil or rawget(target, key) ~= nil then
			return
		end
		local ok = pcall(rawset, target, key, value)
		if ok and rawget(target, key) == value then
			table.insert(synState.added, { target = target; key = key; value = value })
		end
	end

	if state then
		if not opts.force and prev == true then
			return true
		end

		local synTable = rawget(host, "syn")
		if type(synTable) ~= "table" then
			synTable = {}
			synState.createdSyn = true
			pcall(rawset, host, "syn", synTable)
		else
			synState.createdSyn = false
		end
		synState.syn = synTable

		local http = rawget(host, "http")
		local ws = first(rawget(host, "WebSocket"), rawget(host, "websocket"))
		local crypt = first(rawget(host, "crypt"), rawget(host, "crypto"))
		local cache = rawget(host, "cache")
		const requestFn = first(rawget(host, "request"), rawget(host, "http_request"), type(http) == "table" and rawget(http, "request") or nil)
		const queueFn = first(rawget(host, "queue_on_teleport"), rawget(host, "queueonteleport"))
		const protectGuiFn = first(rawget(host, "protect_gui"), rawget(host, "protectgui"))
		const unprotectGuiFn = first(rawget(host, "unprotect_gui"), rawget(host, "unprotectgui"))
		const setIdentityFn = first(rawget(host, "set_thread_identity"), rawget(host, "setthreadidentity"), rawget(host, "setidentity"), rawget(host, "set_thread_context"))
		const getIdentityFn = first(rawget(host, "get_thread_identity"), rawget(host, "getthreadidentity"), rawget(host, "getidentity"), rawget(host, "get_thread_context"))
		const clipboardFn = first(rawget(host, "setclipboard"), rawget(host, "toclipboard"), rawget(host, "set_clipboard"))
		const secureCallFn = first(rawget(host, "secure_call"), rawget(host, "securecall"))
		const cacheReplaceFn = first(rawget(host, "cache_replace"), type(cache) == "table" and first(rawget(cache, "replace"), rawget(cache, "replaceinstance")) or nil)
		const cacheInvalidateFn = first(rawget(host, "cache_invalidate"), type(cache) == "table" and first(rawget(cache, "invalidate"), rawget(cache, "invalidateinstance")) or nil)
		const isCachedFn = first(rawget(host, "is_cached"), type(cache) == "table" and first(rawget(cache, "iscached"), rawget(cache, "is_cached")) or nil)

		add(synTable, "request", requestFn)
		add(synTable, "http_request", requestFn)
		add(synTable, "queue_on_teleport", queueFn)
		add(synTable, "queueonteleport", queueFn)
		add(synTable, "protect_gui", protectGuiFn)
		add(synTable, "unprotect_gui", unprotectGuiFn)
		add(synTable, "set_thread_identity", setIdentityFn)
		add(synTable, "setthreadidentity", setIdentityFn)
		add(synTable, "get_thread_identity", getIdentityFn)
		add(synTable, "getthreadidentity", getIdentityFn)
		add(synTable, "setclipboard", clipboardFn)
		add(synTable, "set_clipboard", clipboardFn)
		add(synTable, "secure_call", secureCallFn)
		add(synTable, "cache_replace", cacheReplaceFn)
		add(synTable, "cache_invalidate", cacheInvalidateFn)
		add(synTable, "is_cached", isCachedFn)
		if type(ws) == "table" then
			add(synTable, "websocket", ws)
			add(synTable, "WebSocket", ws)
		end
		if type(crypt) == "table" then
			add(synTable, "crypt", crypt)
			add(synTable, "crypto", crypt)
		end

		if not opts.silent and DoNotif then
			DoNotif("Syn env enabled", 2)
		end
		return true
	end

	for i = #synState.added, 1, -1 do
		const entry = synState.added[i]
		if type(entry) == "table" and type(entry.target) == "table" and rawget(entry.target, entry.key) == entry.value then
			pcall(rawset, entry.target, entry.key, nil)
		end
		synState.added[i] = nil
	end

	local currentSyn = rawget(host, "syn")
	if synState.createdSyn and currentSyn == synState.syn and type(currentSyn) == "table" and next(currentSyn) == nil then
		pcall(rawset, host, "syn", synState.originalSyn)
	end
	synState.syn = nil
	synState.createdSyn = false

	if not opts.silent and DoNotif then
		DoNotif("Syn env disabled", 2)
	end
	return true
end

NAStuff.deltaPrompted = NAmanage.NASettingsGet("deltaPrompted") == true
NAStuff.deltaScriptSource = "loadstring(game:HttpGet(\"https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DeltaCustomizationModule.luau\"))();"
NAStuff.deltaExecutor = typeof(NAStuff.deltaExecutor) == "boolean" and NAStuff.deltaExecutor or nil

function NAmanage.isDeltaExecutor(forceRefresh)
	if not forceRefresh and type(NAStuff.deltaExecutor) == "boolean" then
		return NAStuff.deltaExecutor
	end
	if type(identifyexecutor) ~= "function" then
		NAStuff.deltaExecutor = false
		return false
	end
	local execName = nil
	local ok, result = pcall(identifyexecutor)
	if ok then
		execName = result
	end
	if execName ~= nil and type(execName) ~= "string" then
		execName = tostring(execName)
	end
	const isDelta = type(execName) == "string" and execName:lower() == "delta" or false
	NAStuff.deltaExecutor = isDelta
	return isDelta
end

function NAmanage.deltaRun()
	local ok, err = pcall(function()
		NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/DeltaCustomizationModule.luau")
	end)
	if ok then
		DoNotif("Loaded the Delta customization helper.", 3)
	else
		DoNotif("Failed to load the Delta customization helper: "..tostring(err), 5)
	end
end

function NAmanage.deltaPopup()
	if NAStuff.deltaPrompted then
		return
	end
	if not NAmanage.isDeltaExecutor(true) then
		return
	end
	NAStuff.deltaPrompted = true
	pcall(NAmanage.NASettingsSet, "deltaPrompted", true)
	const popupTitle = (adminName and (adminName.." Notice")) or "Nameless Admin"
	const popupDescription = "Nameless Admin detected that you are using the Delta executor. This is a one-time reminder, so run it now to test Delta Customization or copy the script if you want to keep the script permanently."
	if type(Popup) == "function" then
		Popup({
			Title = popupTitle,
			Description = popupDescription,
			Duration = 0,
			Buttons = {
				{
					Text = "Run Script",
					Callback = NAmanage.deltaRun,
				},
				{
					Text = "Copy Script",
					Callback = function()
						if setclipboard then
							pcall(setclipboard, NAStuff.deltaScriptSource)
							DoNotif("Delta customization script copied to clipboard.", 3)
						else
							DoNotif(NAStuff.deltaScriptSource, 8)
						end
					end,
				},
			},
		})
	else
		DoNotif(popupDescription, 5)
	end
end

NAmanage.deltaPopup()

function NAensureFolder(path)
	if not (FileSupport and type(path) == "string") then
		return false, "no file support or invalid path"
	end
	if NAmanage.safeIsFolder(path) then
		return true
	end
	if type(isfile) == "function" and NAmanage.safeIsFile(path) and type(delfile) == "function" then
		NAmanage.safeDeleteFile(path)
	end

	local ok, err = NAmanage.safeMakeFolder(path)
	if ok then
		return true
	end

	return false, err
end

NAmanage.ensureNoMediaFile = NAmanage.ensureNoMediaFile or function()
	if not (FileSupport and NAfiles and type(NAfiles.NANOMEDIAPATH) == "string") then
		return false
	end
	if type(isfile) == "function" and NAmanage.safeIsFile(NAfiles.NANOMEDIAPATH) then
		return true
	end
	if type(writefile) ~= "function" then
		return false
	end
	const ok = NAmanage.safeWriteFile(NAfiles.NANOMEDIAPATH, "")
	return ok == true
end

-- Creates folder & files for Prefix, Plugins, and etc
if FileSupport then
	const baseOk = NAensureFolder(NAfiles.NAFILEPATH)
	if not baseOk then
		FileSupport = false
	else
		const function ensureDefaultFile(path, data)
			if not NAmanage.safeIsFile(path) then
				NAmanage.safeWriteFile(path, data)
			end
		end
		NAmanage.ensureNoMediaFile()
		if not NAmanage.safeIsFolder(NAfiles.NAWAYPOINTFILEPATH) then
			if NAensureFolder(NAfiles.NAWAYPOINTFILEPATH) then
				-- imagine if it didn't make the folder
				if NAmanage.safeIsFolder(NAfiles.NAWAYPOINTFILEPATH) then
					NamelessMigrate:Waypoints()
				end
			end
		end

		if not NAmanage.safeIsFolder(NAfiles.NAPLUGINFILEPATH) then
			NAensureFolder(NAfiles.NAPLUGINFILEPATH)
		end

		if not NAmanage.safeIsFolder(NAfiles.NAIYPLUGINFILEPATH) then
			NAensureFolder(NAfiles.NAIYPLUGINFILEPATH)
		end

		if not NAmanage.safeIsFolder(NAfiles.NAASSETSFILEPATH) then
			NAensureFolder(NAfiles.NAASSETSFILEPATH)
		end

		ensureDefaultFile(NAfiles.NAALIASPATH, "{}")
		ensureDefaultFile(NAfiles.NAUSERBUTTONSPATH, Services.HttpService:JSONEncode({}))
		ensureDefaultFile(NAfiles.NACOMMANDKEYBINDS, Services.HttpService:JSONEncode({}))
		ensureDefaultFile(NAfiles.NAFLYBINDSPATH, Services.HttpService:JSONEncode({}))
		ensureDefaultFile(NAfiles.NAAUTOEXECPATH, Services.HttpService:JSONEncode({ commands = {}, args = {} }))
		ensureDefaultFile(NAfiles.NAJOINLEAVE, Services.HttpService:JSONEncode(NAmanage.jlDef))
		ensureDefaultFile(NAfiles.NABINDERS, "{}")
		ensureDefaultFile(NAfiles.NATEXTCHATSETTINGSPATH, Services.HttpService:JSONEncode(NAStuff.ChatSettings))
	end

	NAmanage.NASettingsEnsure()
end

function InitUIStroke()
	const defaultColor = Color3.fromRGB(148, 93, 255)

	if not FileSupport then
		DoNotif("Main Color defaulted: no file support")
		return defaultColor
	end

	const data = NAmanage.NASettingsGet("uiStroke")
	if type(data) == "table" then
		const r = tonumber(data.R)
		const g = tonumber(data.G)
		const b = tonumber(data.B)
		if r and g and b then
			return Color3.new(r, g, b)
		end
	end

	NAmanage.NASettingsSet("uiStroke", {
		R = defaultColor.R;
		G = defaultColor.G;
		B = defaultColor.B;
	})
	DoNotif("Main Color reset to default due to invalid or missing data.")
	return defaultColor
end

NAmanage.topbar_readMode=function()
	const mode = NAmanage.NASettingsGet("topbarMode")
	return mode == "side" and "side" or "bottom"
end

NAmanage.topbar_writeMode=function(m)
	if m ~= "side" then
		m = "bottom"
	end
	NAmanage.NASettingsSet("topbarMode", m)
end

NAmanage.topbar_readDock=function()
	const dock = NAmanage.NASettingsGet("topbarDock")
	return dock == "bottom" and "bottom" or "top"
end

NAmanage.topbar_writeDock=function(dock)
	if dock ~= "bottom" then
		dock = "top"
	end
	NAmanage.NASettingsSet("topbarDock", dock)
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
	const vec = Services.Workspace.CurrentCamera:WorldToScreenPoint(obj.Position)
	return Vector2.new(vec.X, vec.Y)
end

NAmanage.getPlrCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for _,v in __lt.cm("Players", "GetPlayers") do
		if v ~= Services.Players.LocalPlayer and v.Character and getPlrHum(v.Character) then
			for k, x in v.Character:GetChildren() do
				if Find(x.Name, "Torso") then
					const Distance = (NAmanage.worlScreen(x) - NAmanage.mPosVector()).Magnitude
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

WPPath = NAmanage.GetWPPath()
bindersPath = NAfiles.NABINDERS

NAmanage.ESPSettingsState = type(NAmanage.ESPSettingsState) == "table" and NAmanage.ESPSettingsState or {
	loaded = false;
	loading = false;
	saving = false;
	skippedBeforeLoad = false;
}
NAmanage.ESPSettingsLoaded = NAmanage.ESPSettingsState.loaded == true

NAmanage.LoadESPSettings = function(opts)
	opts = type(opts) == "table" and opts or {}
	if NAmanage.ESPSettingsState.loaded == true and opts.force ~= true then
		NAmanage.ESPSettingsLoaded = true
		return true
	end
	if NAmanage.ESPSettingsState.loading == true then
		return false, "ESP settings load already running"
	end
	NAmanage.ESPSettingsState.loading = true
	NAmanage.ESPSettingsState.loaded = false
	NAmanage.ESPSettingsState.missingOnLoad = false
	NAmanage.ESPSettingsState.lastReadError = nil
	NAmanage.ESPSettingsLoaded = false

	const d = {
		ESP_PerfProfileVersion = 2;
		ESP_Transparency = 0.7;
		ESP_PartTransparency = 0.45;
		ESP_BoxMaxDistance = 120;
		ESP_LabelMaxDistance = 1000;
		ESP_ColorByTeam = true;
		ESP_ShowTeamText = true;
		ESP_IgnoreTeam = false;
		ESP_TargetTeam = "";
		ESP_PlayerTargetMode = "all";
		ESP_ShowName = true;
		ESP_ShowHealth = true;
		ESP_ShowDistance = true;
		ESP_RenderMode = "Highlight";
		ESP_PartRenderMode = "BoxHandleAdornment";
		ESP_LabelTextSize = 12;
		ESP_LabelTextScaled = false;
		ESP_LabelStrokeTransparency = 0.5;
		ESP_DrawingTextOutline = true;
		ESP_DrawingTextCentered = true;
		ESP_DrawingTextTransparency = 0;
		ESP_DrawingTextFont = "UI";
		ESP_DrawingBoxStyle = "Square";
		ESP_DrawingBoxThickness = 1;
		ESP_DrawingBoxOutline = true;
		ESP_DrawingBoxOutlineThickness = 3;
		ESP_DrawingFilledBoxes = false;
		ESP_DrawingCornerScale = 0.25;
		ESP_DrawingPartBoxStyle = "Square";
		ESP_DrawingPartTextOutline = true;
		ESP_DrawingPartTextCentered = true;
		ESP_DrawingPartTextTransparency = 0;
		ESP_DrawingPartBoxThickness = 1;
		ESP_DrawingPartBoxOutline = true;
		ESP_DrawingPartBoxOutlineThickness = 3;
		ESP_DrawingPartFilledBoxes = false;
		ESP_DrawingPartCornerScale = 0.25;
		ESP_DrawingPartQueuePerStep = 64;
		ESP_DrawingMaxPerStep = 64;
		ESP_PartUpdatePerStep = 48;
		ESP_PartMaxActive = 450;
		ESP_PartSweepInterval = 4;
		ESP_DrawingTracerEnabled = false;
		ESP_DrawingTracerOrigin = "Bottom";
		ESP_DrawingTracerTarget = "Bottom";
		ESP_DrawingTracerThickness = 1;
		ESP_DrawingTracerOutline = true;
		ESP_OcclusionEnabled = false;
		ESP_OcclusionIncludePlayers = false;
		ESP_OcclusionIncludeNPCs = false;
		ESP_OcclusionIncludeParts = false;
		ESP_OcclusionHideLabels = false;
		ESP_OcclusionHidePartLabels = false;
		ESP_OcclusionHideTracers = false;
		ESP_OcclusionDimBoxes = false;
		ESP_OcclusionDimLabels = false;
		ESP_OcclusionIgnoreTransparent = false;
		ESP_OcclusionTransparentThreshold = 0.85;
		ESP_OcclusionIgnoreNonCollidable = false;
		ESP_OcclusionIgnoreSameModel = false;
		ESP_OcclusionHitProbeLimit = 4;
		ESP_OcclusionDimAmount = 0.55;
		ESP_OcclusionUpdateInterval = 0.25;
		ESP_OcclusionMaxPerStep = 12;
		ESP_OcclusionMaxDistance = 1500;
		ESP_OcclusionColor = {130, 130, 130};
		ESP_UseCustomColor = false;
		ESP_CustomColor = {255, 255, 255};
		ESP_OutlineTransparency = 0;
		ESP_ShowPartText = true;
		ESP_ShowPartDistance = false;
		ESP_PartColor_Name = {255, 255, 255};
		ESP_PartColor_Folder = {255, 220, 0};
		ESP_PartColor_Model = {0, 200, 255};
		ESP_PartColor_Touch = {255, 0, 0};
		ESP_PartColor_Proximity = {0, 0, 255};
		ESP_PartColor_Click = {255, 165, 0};
		ESP_PartColor_Item = {90, 255, 135};
		ESP_PartColor_Seat = {0, 255, 0};
		ESP_PartColor_VehicleSeat = {255, 0, 255};
		ESP_PartColor_Unanchored = {255, 220, 0};
		ESP_PartColor_CollisionTrue = {0, 200, 255};
		ESP_PartColor_CollisionFalse = {255, 120, 120};
		ESP_PartColor_Property = {190, 120, 255};
		ESP_LocatorEnabled = false;
		ESP_LocatorSize = 26;
		ESP_LocatorShowText = false;
		ESP_LocatorTextSize = 14;
		ESP_PlayerLocatorEnabled = false;
		ESP_PlayerLocatorSize = 26;
		ESP_PlayerLocatorShowText = false;
		ESP_PlayerLocatorTextSize = 14;
		WaypointESP_ShowBox = false;
		WaypointESP_ShowName = true;
		WaypointESP_ShowDistance = true;
		WaypointESP_ShowIcon = true;
		WaypointESP_ShowHighlight = true;
		WaypointESP_MaxDistance = 100000;
		WaypointESP_IconSize = 42;
		WaypointESP_TextSize = 18;
		WaypointESP_Color = {75, 155, 255};
		WaypointPath_ShowNodes = true;
		WaypointPath_ShowText = false;
		WaypointPath_LoopMode = "walk";
		WaypointPath_TweenSpeed = 24;
		WaypointPath_TeleportDelay = 0.25;
		ESP_MaxPerStep = 24;
		ESP_FolderMode = "parts";
		ESP_ModelMode = "parts";
		NPC_ESP_RenderMode = "Highlight";
	}
	if FileSupport then
		NAmanage.ESPSettingsState.okRead, NAmanage.ESPSettingsState.cfg, NAmanage.ESPSettingsState.sourcePath = NAmanage.safeReadJsonFileWithRecovery(NAfiles.NAESPSETTINGSPATH, {
			tempPath = NAfiles.NAESPSETTINGSPATH..".tmp";
			backupPath = NAfiles.NAESPSETTINGSPATH..".bak";
		})
		if NAmanage.ESPSettingsState.okRead and type(NAmanage.ESPSettingsState.cfg)=="table" then
			NAmanage.ESPSettingsState.loadedFrom = NAmanage.ESPSettingsState.sourcePath
				for key, defaultValue in d do
					NAmanage.ESPSettingsState.stored = NAmanage.ESPSettingsState.cfg[key]
					if NAmanage.ESPSettingsState.stored ~= nil then
						const kind = typeof(defaultValue)
						if kind == "number" then
							NAmanage.ESPSettingsState.numeric = tonumber(NAmanage.ESPSettingsState.stored)
							if NAmanage.ESPSettingsState.numeric then d[key] = NAmanage.ESPSettingsState.numeric end
						elseif kind == "boolean" then
							if typeof(NAmanage.ESPSettingsState.stored)=="boolean" then
								d[key] = NAmanage.ESPSettingsState.stored
							elseif typeof(NAmanage.ESPSettingsState.stored)=="number" then
								d[key] = NAmanage.ESPSettingsState.stored ~= 0
							elseif typeof(NAmanage.ESPSettingsState.stored)=="string" then
								NAmanage.ESPSettingsState.stringValue = NAmanage.ESPSettingsState.stored:lower()
								if NAmanage.ESPSettingsState.stringValue=="true" or NAmanage.ESPSettingsState.stringValue=="1" then d[key]=true
								elseif NAmanage.ESPSettingsState.stringValue=="false" or NAmanage.ESPSettingsState.stringValue=="0" then d[key]=false end
							end
						else
							d[key] = NAmanage.ESPSettingsState.stored
						end
					end
				end
				NAmanage.ESPSettingsState.perfVersion = tonumber(NAmanage.ESPSettingsState.cfg.ESP_PerfProfileVersion) or 0
				if NAmanage.ESPSettingsState.perfVersion < 2 then
					if tonumber(NAmanage.ESPSettingsState.cfg.ESP_DrawingPartQueuePerStep) == 128 then d.ESP_DrawingPartQueuePerStep = 64 end
					if tonumber(NAmanage.ESPSettingsState.cfg.ESP_MaxPerStep) == 32 then d.ESP_MaxPerStep = 24 end
					if tonumber(NAmanage.ESPSettingsState.cfg.ESP_OcclusionHitProbeLimit) == 6 then d.ESP_OcclusionHitProbeLimit = 4 end
					if tonumber(NAmanage.ESPSettingsState.cfg.ESP_OcclusionUpdateInterval) == 0.18 then d.ESP_OcclusionUpdateInterval = 0.25 end
					if tonumber(NAmanage.ESPSettingsState.cfg.ESP_OcclusionMaxPerStep) == 24 then d.ESP_OcclusionMaxPerStep = 12 end
				end
				d.ESP_PerfProfileVersion = 2
		else
			NAmanage.ESPSettingsState.lastReadError = tostring(NAmanage.ESPSettingsState.cfg or "file missing")
			NAmanage.ESPSettingsState.missingOnLoad = not NAmanage.safeIsFile(NAfiles.NAESPSETTINGSPATH)
		end
	end
	const function sanitizeColor(value, defaultColor)
		if typeof(value) == "Color3" then
			return value
		end
		if type(value) == "table" then
			const r = tonumber(value.R or value[1])
			const g = tonumber(value.G or value[2])
			const b = tonumber(value.B or value[3])
			if r and g and b then
				return Color3.fromRGB(r, g, b)
			end
		end
		return defaultColor
	end
	const legacyMode = tostring(d.ESP_RenderMode or "Highlight")
	const mode = NAgui.sanitizeESPRenderMode(legacyMode, "Highlight")
	local partMode = NAgui.sanitizeESPRenderMode(d.ESP_PartRenderMode or "BoxHandleAdornment", "BoxHandleAdornment")
	if partMode == "Character Box" then partMode = "BoxHandleAdornment" end
	const npcMode = NAgui.sanitizeNPCESPRenderMode(d.NPC_ESP_RenderMode)
	const partTransparency = NAgui.sanitizeTransparency(d.ESP_PartTransparency ~= nil and d.ESP_PartTransparency or d.ESP_Transparency)
	local sz = tonumber(d.ESP_LabelTextSize) or 12
	if sz < 8 then sz = 8 elseif sz > 72 then sz = 72 end
	const stroke = math.clamp(tonumber(d.ESP_LabelStrokeTransparency) or 0.5, 0, 1)
	const drawingBoxThickness = math.clamp(tonumber(d.ESP_DrawingBoxThickness) or 1, 1, 6)
	const drawingBoxOutlineThickness = math.clamp(tonumber(d.ESP_DrawingBoxOutlineThickness) or 3, 1, 10)
	const drawingCornerScale = math.clamp(tonumber(d.ESP_DrawingCornerScale) or 0.25, 0.05, 0.5)
	const drawingTextTransparency = math.clamp(tonumber(d.ESP_DrawingTextTransparency) or 0, 0, 1)
	const drawingPartBoxStyle = NAgui.sanitizeESPDrawingBoxStyle(d.ESP_DrawingPartBoxStyle)
	const drawingPartBoxThickness = math.clamp(tonumber(d.ESP_DrawingPartBoxThickness) or 1, 1, 6)
	const drawingPartBoxOutlineThickness = math.clamp(tonumber(d.ESP_DrawingPartBoxOutlineThickness) or 3, 1, 10)
	const drawingPartCornerScale = math.clamp(tonumber(d.ESP_DrawingPartCornerScale) or 0.25, 0.05, 0.5)
	const drawingPartTextTransparency = math.clamp(tonumber(d.ESP_DrawingPartTextTransparency) or 0, 0, 1)
	const drawingPartQueuePerStep = math.clamp(math.floor(tonumber(d.ESP_DrawingPartQueuePerStep) or 64), 1, 512)
	const drawingMaxPerStep = math.clamp(math.floor(tonumber(d.ESP_DrawingMaxPerStep) or 64), 16, 512)
	const partUpdatePerStep = math.clamp(math.floor(tonumber(d.ESP_PartUpdatePerStep) or 48), 1, 512)
	const partMaxActive = math.clamp(math.floor(tonumber(d.ESP_PartMaxActive) or 450), 50, 5000)
	const partSweepInterval = math.clamp(tonumber(d.ESP_PartSweepInterval) or 4, 0.75, 30)
	const drawingTracerThickness = math.clamp(tonumber(d.ESP_DrawingTracerThickness) or 1, 1, 6)
	const occlusionDimAmount = math.clamp(tonumber(d.ESP_OcclusionDimAmount) or 0.55, 0, 1)
	const occlusionUpdateInterval = math.clamp(tonumber(d.ESP_OcclusionUpdateInterval) or 0.25, 0.05, 1)
	const occlusionMaxPerStep = math.clamp(math.floor(tonumber(d.ESP_OcclusionMaxPerStep) or 12), 1, 128)
	const occlusionMaxDistance = math.clamp(tonumber(d.ESP_OcclusionMaxDistance) or 1500, 0, 10000)
	const occlusionTransparentThreshold = math.clamp(tonumber(d.ESP_OcclusionTransparentThreshold) or 0.85, 0, 1)
	const occlusionHitProbeLimit = math.clamp(math.floor(tonumber(d.ESP_OcclusionHitProbeLimit) or 4), 1, 20)
	const outline = NAgui.sanitizeTransparency(d.ESP_OutlineTransparency)
	const maxPerStep = math.clamp(math.floor(tonumber(d.ESP_MaxPerStep) or 24), 1, 256)
	const customColor = sanitizeColor(d.ESP_CustomColor, Color3.new(1, 1, 1))
	const occlusionColor = sanitizeColor(d.ESP_OcclusionColor, Color3.fromRGB(130, 130, 130))

	NAStuff.ESP_Transparency     = NAgui.sanitizeTransparency(d.ESP_Transparency)
	NAStuff.ESP_BoxMaxDistance   = d.ESP_BoxMaxDistance
	NAStuff.ESP_LabelMaxDistance = d.ESP_LabelMaxDistance
	NAStuff.ESP_ColorByTeam      = d.ESP_ColorByTeam
	NAStuff.ESP_ShowTeamText     = d.ESP_ShowTeamText
	NAStuff.ESP_IgnoreTeam      = d.ESP_IgnoreTeam == true
	NAStuff.ESP_TargetTeam      = tostring(d.ESP_TargetTeam or "")
	NAStuff.ESP_PlayerTargetMode = tostring(d.ESP_PlayerTargetMode or "all")
	NAStuff.ESP_ShowName         = d.ESP_ShowName
	NAStuff.ESP_ShowHealth       = d.ESP_ShowHealth
	NAStuff.ESP_ShowDistance     = d.ESP_ShowDistance
	NAStuff.ESP_ShowPartDistance = d.ESP_ShowPartDistance
	NAStuff.ESP_RenderMode       = mode
	NAStuff.ESP_PartRenderMode   = partMode
	NAStuff.ESP_PartTransparency = partTransparency
	NAStuff.ESP_LabelTextSize    = sz
	NAStuff.ESP_LabelTextScaled  = d.ESP_LabelTextScaled == true
	NAStuff.ESP_LabelStrokeTransparency = stroke
	NAStuff.ESP_DrawingTextOutline = d.ESP_DrawingTextOutline ~= false
	NAStuff.ESP_DrawingTextCentered = d.ESP_DrawingTextCentered ~= false
	NAStuff.ESP_DrawingTextTransparency = drawingTextTransparency
	NAStuff.ESP_DrawingTextFont = NAgui.sanitizeDrawingTextFont(d.ESP_DrawingTextFont)
	NAStuff.ESP_DrawingBoxStyle = NAgui.sanitizeESPDrawingBoxStyle(d.ESP_DrawingBoxStyle)
	NAStuff.ESP_DrawingBoxThickness = drawingBoxThickness
	NAStuff.ESP_DrawingBoxOutline = d.ESP_DrawingBoxOutline ~= false
	NAStuff.ESP_DrawingBoxOutlineThickness = drawingBoxOutlineThickness
	NAStuff.ESP_DrawingFilledBoxes = d.ESP_DrawingFilledBoxes == true
	NAStuff.ESP_DrawingCornerScale = drawingCornerScale
	NAStuff.ESP_DrawingPartBoxStyle = drawingPartBoxStyle
	NAStuff.ESP_DrawingPartTextOutline = d.ESP_DrawingPartTextOutline ~= false
	NAStuff.ESP_DrawingPartTextCentered = d.ESP_DrawingPartTextCentered ~= false
	NAStuff.ESP_DrawingPartTextTransparency = drawingPartTextTransparency
	NAStuff.ESP_DrawingPartBoxThickness = drawingPartBoxThickness
	NAStuff.ESP_DrawingPartBoxOutline = d.ESP_DrawingPartBoxOutline ~= false
	NAStuff.ESP_DrawingPartBoxOutlineThickness = drawingPartBoxOutlineThickness
	NAStuff.ESP_DrawingPartFilledBoxes = d.ESP_DrawingPartFilledBoxes == true
	NAStuff.ESP_DrawingPartCornerScale = drawingPartCornerScale
	NAStuff.ESP_DrawingPartQueuePerStep = drawingPartQueuePerStep
	NAStuff.ESP_DrawingMaxPerStep = drawingMaxPerStep
	NAStuff.ESP_PartUpdatePerStep = partUpdatePerStep
	NAStuff.ESP_PartMaxActive = partMaxActive
	NAStuff.ESP_PartSweepInterval = partSweepInterval
	NAStuff.ESP_DrawingTracerEnabled = d.ESP_DrawingTracerEnabled == true
	NAStuff.ESP_DrawingTracerOrigin = NAgui.sanitizeESPDrawingTracerOrigin(d.ESP_DrawingTracerOrigin)
	NAStuff.ESP_DrawingTracerTarget = NAgui.sanitizeESPDrawingTracerTarget(d.ESP_DrawingTracerTarget)
	NAStuff.ESP_DrawingTracerThickness = drawingTracerThickness
	NAStuff.ESP_DrawingTracerOutline = d.ESP_DrawingTracerOutline ~= false
	NAStuff.ESP_OcclusionEnabled = d.ESP_OcclusionEnabled == true
	NAStuff.ESP_OcclusionIncludePlayers = d.ESP_OcclusionIncludePlayers == true
	NAStuff.ESP_OcclusionIncludeNPCs = d.ESP_OcclusionIncludeNPCs == true
	NAStuff.ESP_OcclusionIncludeParts = d.ESP_OcclusionIncludeParts == true
	NAStuff.ESP_OcclusionHideLabels = d.ESP_OcclusionHideLabels == true
	NAStuff.ESP_OcclusionHidePartLabels = d.ESP_OcclusionHidePartLabels == true
	NAStuff.ESP_OcclusionHideTracers = d.ESP_OcclusionHideTracers == true
	NAStuff.ESP_OcclusionDimBoxes = d.ESP_OcclusionDimBoxes == true
	NAStuff.ESP_OcclusionDimLabels = d.ESP_OcclusionDimLabels == true
	NAStuff.ESP_OcclusionIgnoreTransparent = d.ESP_OcclusionIgnoreTransparent == true
	NAStuff.ESP_OcclusionTransparentThreshold = occlusionTransparentThreshold
	NAStuff.ESP_OcclusionIgnoreNonCollidable = d.ESP_OcclusionIgnoreNonCollidable == true
	NAStuff.ESP_OcclusionIgnoreSameModel = d.ESP_OcclusionIgnoreSameModel == true
	NAStuff.ESP_OcclusionHitProbeLimit = occlusionHitProbeLimit
	NAStuff.ESP_OcclusionDimAmount = occlusionDimAmount
	NAStuff.ESP_OcclusionUpdateInterval = occlusionUpdateInterval
	NAStuff.ESP_OcclusionMaxPerStep = occlusionMaxPerStep
	NAStuff.ESP_OcclusionMaxDistance = occlusionMaxDistance
	NAStuff.ESP_OcclusionColor = occlusionColor
	NAStuff.ESP_UseCustomColor   = d.ESP_UseCustomColor == true
	NAStuff.ESP_CustomColor      = customColor
	NAStuff.ESP_OutlineTransparency = outline
	NAStuff.ESP_ShowPartText = d.ESP_ShowPartText ~= false
	NAStuff.ESP_PartColor_Name = sanitizeColor(d.ESP_PartColor_Name, Color3.fromRGB(255, 255, 255))
	NAStuff.ESP_PartColor_Folder = sanitizeColor(d.ESP_PartColor_Folder, Color3.fromRGB(255, 220, 0))
	NAStuff.ESP_PartColor_Model = sanitizeColor(d.ESP_PartColor_Model, Color3.fromRGB(0, 200, 255))
	NAStuff.ESP_PartColor_Touch = sanitizeColor(d.ESP_PartColor_Touch, Color3.fromRGB(255, 0, 0))
	NAStuff.ESP_PartColor_Proximity = sanitizeColor(d.ESP_PartColor_Proximity, Color3.fromRGB(0, 0, 255))
	NAStuff.ESP_PartColor_Click = sanitizeColor(d.ESP_PartColor_Click, Color3.fromRGB(255, 165, 0))
	NAStuff.ESP_PartColor_Item = sanitizeColor(d.ESP_PartColor_Item, Color3.fromRGB(90, 255, 135))
	NAStuff.ESP_PartColor_Seat = sanitizeColor(d.ESP_PartColor_Seat, Color3.fromRGB(0, 255, 0))
	NAStuff.ESP_PartColor_VehicleSeat = sanitizeColor(d.ESP_PartColor_VehicleSeat, Color3.fromRGB(255, 0, 255))
	NAStuff.ESP_PartColor_Unanchored = sanitizeColor(d.ESP_PartColor_Unanchored, Color3.fromRGB(255, 220, 0))
	NAStuff.ESP_PartColor_CollisionTrue = sanitizeColor(d.ESP_PartColor_CollisionTrue, Color3.fromRGB(0, 200, 255))
	NAStuff.ESP_PartColor_CollisionFalse = sanitizeColor(d.ESP_PartColor_CollisionFalse, Color3.fromRGB(255, 120, 120))
	NAStuff.ESP_PartColor_Property = sanitizeColor(d.ESP_PartColor_Property, Color3.fromRGB(190, 120, 255))
	NAStuff.ESP_MaxPerStep       = maxPerStep
	local folderMode = Lower(tostring(d.ESP_FolderMode or "parts"))
	if folderMode ~= "models" then
		folderMode = "parts"
	end
	NAStuff.ESP_FolderMode = folderMode
	local modelMode = Lower(tostring(d.ESP_ModelMode or "parts"))
	if modelMode ~= "models" then
		modelMode = "parts"
	end
	NAStuff.ESP_ModelMode = modelMode
	NAStuff.NPC_ESP_RenderMode = npcMode

	NAStuff.ESP_LocatorEnabled   = d.ESP_LocatorEnabled == true
	NAStuff.ESP_LocatorSize      = math.clamp(tonumber(d.ESP_LocatorSize) or 26, 12, 128)
	NAStuff.ESP_LocatorShowText  = d.ESP_LocatorShowText == true
	NAStuff.ESP_LocatorTextSize  = math.clamp(tonumber(d.ESP_LocatorTextSize) or 14, 10, 48)
	NAStuff.ESP_PlayerLocatorEnabled  = d.ESP_PlayerLocatorEnabled == true
	NAStuff.ESP_PlayerLocatorSize     = math.clamp(tonumber(d.ESP_PlayerLocatorSize) or 26, 12, 128)
	NAStuff.ESP_PlayerLocatorShowText = d.ESP_PlayerLocatorShowText == true
	NAStuff.ESP_PlayerLocatorTextSize = math.clamp(tonumber(d.ESP_PlayerLocatorTextSize) or 14, 10, 48)
	NAStuff.WaypointESP_ShowBox = d.WaypointESP_ShowBox == true
	NAStuff.WaypointESP_ShowName = d.WaypointESP_ShowName ~= false
	NAStuff.WaypointESP_ShowDistance = d.WaypointESP_ShowDistance ~= false
	NAStuff.WaypointESP_ShowIcon = d.WaypointESP_ShowIcon ~= false
	NAStuff.WaypointESP_ShowHighlight = d.WaypointESP_ShowHighlight ~= false
	NAStuff.WaypointESP_MaxDistance = math.clamp(tonumber(d.WaypointESP_MaxDistance) or 100000, 50, 100000)
	NAStuff.WaypointESP_IconSize = math.clamp(math.floor((tonumber(d.WaypointESP_IconSize) or 42) + 0.5), 16, 96)
	NAStuff.WaypointESP_TextSize = math.clamp(math.floor((tonumber(d.WaypointESP_TextSize) or 18) + 0.5), 10, 48)
	NAStuff.WaypointESP_Color = sanitizeColor(d.WaypointESP_Color, Color3.fromRGB(75, 155, 255))
	NAStuff.WaypointPath_ShowNodes = d.WaypointPath_ShowNodes ~= false
	NAStuff.WaypointPath_ShowText = d.WaypointPath_ShowText == true
	local savedLoopMode = Lower(tostring(d.WaypointPath_LoopMode or "walk"))
	if savedLoopMode == "walking" or savedLoopMode == "cframe" or savedLoopMode == "cframewalk" or savedLoopMode == "cframe-walk" then
		savedLoopMode = "walk"
	elseif savedLoopMode == "tp" or savedLoopMode == "instant" then
		savedLoopMode = "teleport"
	elseif savedLoopMode ~= "tween" and savedLoopMode ~= "teleport" and savedLoopMode ~= "walk" then
		savedLoopMode = "walk"
	end
	NAStuff.WaypointPath_LoopMode = savedLoopMode
	NAStuff.WaypointPath_TweenSpeed = math.clamp(tonumber(d.WaypointPath_TweenSpeed) or 24, 1, 500)
	NAStuff.WaypointPath_TeleportDelay = math.clamp(tonumber(d.WaypointPath_TeleportDelay) or 0.25, 0, 10)

	if NAStuff.ESP_LocatorEnabled then
		NAmanage.ESP_LocatorEnable(true)
	else
		NAmanage.ESP_LocatorDisable()
	end
	NAmanage.ESP_LocatorApplyFlags()
	if NAStuff.ESP_PlayerLocatorEnabled then
		NAmanage.ESP_PlayerLocatorEnable(true)
	else
		NAmanage.ESP_PlayerLocatorDisable()
	end
	NAmanage.ESP_PlayerLocatorApplyFlags()

	NAmanage.ESPSettingsState.loading = false
	NAmanage.ESPSettingsState.loaded = true
	NAmanage.ESPSettingsState.skippedBeforeLoad = false
	NAmanage.ESPSettingsLoaded = true

	if FileSupport and NAmanage.ESPSettingsState.missingOnLoad == true then
		NAmanage.ESPSettingsState.missingOnLoad = false
		Defer(function()
			if NAmanage.ESPSettingsState and NAmanage.ESPSettingsState.loaded == true and type(NAmanage.SaveESPSettings) == "function" then
				NAmanage.SaveESPSettings({ force = true; reason = "create missing ESPSettings after load" })
			end
		end)
	end
	return true
end

NAmanage.SaveESPSettings = function(opts)
	opts = type(opts) == "table" and opts or {}
	if not FileSupport then return false, "no file support" end
	if type(NAmanage.ESPSettingsState) ~= "table" then
		NAmanage.ESPSettingsState = { loaded = false; loading = false; saving = false }
	end
	if opts.force ~= true and NAmanage.ESPSettingsState.loaded ~= true then
		NAmanage.ESPSettingsState.skippedBeforeLoad = true
		return false, "ESP settings have not finished loading"
	end
	if NAmanage.ESPSettingsState.saving == true then
		NAmanage.ESPSettingsState.queuedAfterSave = true
		return false, "ESP settings save already running"
	end
	NAmanage.ESPSettingsState.saving = true
	const mode = NAgui.sanitizeESPRenderMode(NAStuff.ESP_RenderMode, "Highlight")
	local partMode = NAgui.sanitizeESPRenderMode(NAStuff.ESP_PartRenderMode, "BoxHandleAdornment")
	if partMode == "Character Box" then partMode = "BoxHandleAdornment" end
	const npcMode = NAgui.sanitizeNPCESPRenderMode(NAStuff.NPC_ESP_RenderMode)
	local sz = tonumber(NAStuff.ESP_LabelTextSize) or 12
	if sz < 8 then sz = 8 elseif sz > 72 then sz = 72 end
	const d = {
		ESP_PerfProfileVersion = 2;
		ESP_Transparency = NAStuff.ESP_Transparency or 0.7;
		ESP_PartTransparency = NAgui.sanitizeTransparency(NAStuff.ESP_PartTransparency ~= nil and NAStuff.ESP_PartTransparency or 0.45);
		ESP_BoxMaxDistance = NAStuff.ESP_BoxMaxDistance or 120;
		ESP_LabelMaxDistance = NAStuff.ESP_LabelMaxDistance or 1000;
		ESP_ColorByTeam = (NAStuff.ESP_ColorByTeam ~= false);
		ESP_ShowTeamText = (NAStuff.ESP_ShowTeamText ~= false);
		ESP_IgnoreTeam = NAStuff.ESP_IgnoreTeam == true;
		ESP_TargetTeam = tostring(NAStuff.ESP_TargetTeam or "");
		ESP_PlayerTargetMode = tostring(NAStuff.ESP_PlayerTargetMode or "all");
		ESP_ShowName = (NAStuff.ESP_ShowName ~= false);
		ESP_ShowHealth = (NAStuff.ESP_ShowHealth ~= false);
		ESP_ShowDistance = (NAStuff.ESP_ShowDistance ~= false);
		ESP_ShowPartDistance = (NAStuff.ESP_ShowPartDistance == true);
		ESP_RenderMode = mode;
		ESP_PartRenderMode = partMode;
		ESP_LabelTextSize = sz;
		ESP_LabelTextScaled = NAStuff.ESP_LabelTextScaled == true;
		ESP_LabelStrokeTransparency = math.clamp(tonumber(NAStuff.ESP_LabelStrokeTransparency) or 0.5, 0, 1);
		ESP_DrawingTextOutline = NAStuff.ESP_DrawingTextOutline ~= false;
		ESP_DrawingTextCentered = NAStuff.ESP_DrawingTextCentered ~= false;
		ESP_DrawingTextTransparency = math.clamp(tonumber(NAStuff.ESP_DrawingTextTransparency) or 0, 0, 1);
		ESP_DrawingTextFont = NAgui.sanitizeDrawingTextFont(NAStuff.ESP_DrawingTextFont);
		ESP_DrawingBoxStyle = NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingBoxStyle);
		ESP_DrawingBoxThickness = math.clamp(tonumber(NAStuff.ESP_DrawingBoxThickness) or 1, 1, 6);
		ESP_DrawingBoxOutline = NAStuff.ESP_DrawingBoxOutline ~= false;
		ESP_DrawingBoxOutlineThickness = math.clamp(tonumber(NAStuff.ESP_DrawingBoxOutlineThickness) or 3, 1, 10);
		ESP_DrawingFilledBoxes = NAStuff.ESP_DrawingFilledBoxes == true;
		ESP_DrawingCornerScale = math.clamp(tonumber(NAStuff.ESP_DrawingCornerScale) or 0.25, 0.05, 0.5);
		ESP_DrawingPartBoxStyle = NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingPartBoxStyle);
		ESP_DrawingPartTextOutline = NAStuff.ESP_DrawingPartTextOutline ~= false;
		ESP_DrawingPartTextCentered = NAStuff.ESP_DrawingPartTextCentered ~= false;
		ESP_DrawingPartTextTransparency = math.clamp(tonumber(NAStuff.ESP_DrawingPartTextTransparency) or 0, 0, 1);
		ESP_DrawingPartBoxThickness = math.clamp(tonumber(NAStuff.ESP_DrawingPartBoxThickness) or 1, 1, 6);
		ESP_DrawingPartBoxOutline = NAStuff.ESP_DrawingPartBoxOutline ~= false;
		ESP_DrawingPartBoxOutlineThickness = math.clamp(tonumber(NAStuff.ESP_DrawingPartBoxOutlineThickness) or 3, 1, 10);
		ESP_DrawingPartFilledBoxes = NAStuff.ESP_DrawingPartFilledBoxes == true;
		ESP_DrawingPartCornerScale = math.clamp(tonumber(NAStuff.ESP_DrawingPartCornerScale) or 0.25, 0.05, 0.5);
		ESP_DrawingPartQueuePerStep = math.clamp(math.floor(tonumber(NAStuff.ESP_DrawingPartQueuePerStep) or 64), 1, 512);
		ESP_DrawingMaxPerStep = math.clamp(math.floor(tonumber(NAStuff.ESP_DrawingMaxPerStep) or 64), 16, 512);
		ESP_PartUpdatePerStep = math.clamp(math.floor(tonumber(NAStuff.ESP_PartUpdatePerStep) or 48), 1, 512);
		ESP_PartMaxActive = math.clamp(math.floor(tonumber(NAStuff.ESP_PartMaxActive) or 450), 50, 5000);
		ESP_PartSweepInterval = math.clamp(tonumber(NAStuff.ESP_PartSweepInterval) or 4, 0.75, 30);
		ESP_DrawingTracerEnabled = NAStuff.ESP_DrawingTracerEnabled == true;
		ESP_DrawingTracerOrigin = NAgui.sanitizeESPDrawingTracerOrigin(NAStuff.ESP_DrawingTracerOrigin);
		ESP_DrawingTracerTarget = NAgui.sanitizeESPDrawingTracerTarget(NAStuff.ESP_DrawingTracerTarget);
		ESP_DrawingTracerThickness = math.clamp(tonumber(NAStuff.ESP_DrawingTracerThickness) or 1, 1, 6);
		ESP_DrawingTracerOutline = NAStuff.ESP_DrawingTracerOutline ~= false;
		ESP_OcclusionEnabled = NAStuff.ESP_OcclusionEnabled == true;
		ESP_OcclusionIncludePlayers = NAStuff.ESP_OcclusionIncludePlayers == true;
		ESP_OcclusionIncludeNPCs = NAStuff.ESP_OcclusionIncludeNPCs == true;
		ESP_OcclusionIncludeParts = NAStuff.ESP_OcclusionIncludeParts == true;
		ESP_OcclusionHideLabels = NAStuff.ESP_OcclusionHideLabels == true;
		ESP_OcclusionHidePartLabels = NAStuff.ESP_OcclusionHidePartLabels == true;
		ESP_OcclusionHideTracers = NAStuff.ESP_OcclusionHideTracers == true;
		ESP_OcclusionDimBoxes = NAStuff.ESP_OcclusionDimBoxes == true;
		ESP_OcclusionDimLabels = NAStuff.ESP_OcclusionDimLabels == true;
		ESP_OcclusionIgnoreTransparent = NAStuff.ESP_OcclusionIgnoreTransparent == true;
		ESP_OcclusionTransparentThreshold = math.clamp(tonumber(NAStuff.ESP_OcclusionTransparentThreshold) or 0.85, 0, 1);
		ESP_OcclusionIgnoreNonCollidable = NAStuff.ESP_OcclusionIgnoreNonCollidable == true;
		ESP_OcclusionIgnoreSameModel = NAStuff.ESP_OcclusionIgnoreSameModel == true;
		ESP_OcclusionHitProbeLimit = math.clamp(math.floor(tonumber(NAStuff.ESP_OcclusionHitProbeLimit) or 4), 1, 20);
		ESP_OcclusionDimAmount = math.clamp(tonumber(NAStuff.ESP_OcclusionDimAmount) or 0.55, 0, 1);
		ESP_OcclusionUpdateInterval = math.clamp(tonumber(NAStuff.ESP_OcclusionUpdateInterval) or 0.25, 0.05, 1);
		ESP_OcclusionMaxPerStep = math.clamp(math.floor(tonumber(NAStuff.ESP_OcclusionMaxPerStep) or 12), 1, 128);
		ESP_OcclusionMaxDistance = math.clamp(tonumber(NAStuff.ESP_OcclusionMaxDistance) or 1500, 0, 10000);
		ESP_OcclusionColor = NAmanage.UserButtonColorToTable(NAStuff.ESP_OcclusionColor or Color3.fromRGB(130, 130, 130));
		ESP_UseCustomColor = NAStuff.ESP_UseCustomColor == true;
		ESP_CustomColor = NAmanage.UserButtonColorToTable(NAStuff.ESP_CustomColor or Color3.new(1, 1, 1));
		ESP_OutlineTransparency = NAgui.sanitizeTransparency(NAStuff.ESP_OutlineTransparency or 0);
		ESP_ShowPartText = (NAStuff.ESP_ShowPartText ~= false);
		ESP_PartColor_Name = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Name or Color3.fromRGB(255, 255, 255));
		ESP_PartColor_Folder = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Folder or Color3.fromRGB(255, 220, 0));
		ESP_PartColor_Model = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Model or Color3.fromRGB(0, 200, 255));
		ESP_PartColor_Touch = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Touch or Color3.fromRGB(255, 0, 0));
		ESP_PartColor_Proximity = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Proximity or Color3.fromRGB(0, 0, 255));
		ESP_PartColor_Click = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Click or Color3.fromRGB(255, 165, 0));
		ESP_PartColor_Item = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Item or Color3.fromRGB(90, 255, 135));
		ESP_PartColor_Seat = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Seat or Color3.fromRGB(0, 255, 0));
		ESP_PartColor_VehicleSeat = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_VehicleSeat or Color3.fromRGB(255, 0, 255));
		ESP_PartColor_Unanchored = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Unanchored or Color3.fromRGB(255, 220, 0));
		ESP_PartColor_CollisionTrue = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_CollisionTrue or Color3.fromRGB(0, 200, 255));
		ESP_PartColor_CollisionFalse = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_CollisionFalse or Color3.fromRGB(255, 120, 120));
		ESP_PartColor_Property = NAmanage.UserButtonColorToTable(NAStuff.ESP_PartColor_Property or Color3.fromRGB(190, 120, 255));
		ESP_LocatorEnabled = NAStuff.ESP_LocatorEnabled == true;
		ESP_LocatorSize = math.clamp(tonumber(NAStuff.ESP_LocatorSize) or 26, 12, 128);
		ESP_LocatorShowText = NAStuff.ESP_LocatorShowText == true;
		ESP_LocatorTextSize = math.clamp(tonumber(NAStuff.ESP_LocatorTextSize) or 14, 10, 48);
		ESP_PlayerLocatorEnabled = NAStuff.ESP_PlayerLocatorEnabled == true;
		ESP_PlayerLocatorSize = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorSize) or 26, 12, 128);
		ESP_PlayerLocatorShowText = NAStuff.ESP_PlayerLocatorShowText == true;
		ESP_PlayerLocatorTextSize = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorTextSize) or 14, 10, 48);
		WaypointESP_ShowBox = NAStuff.WaypointESP_ShowBox == true;
		WaypointESP_ShowName = NAStuff.WaypointESP_ShowName ~= false;
		WaypointESP_ShowDistance = NAStuff.WaypointESP_ShowDistance ~= false;
		WaypointESP_ShowIcon = NAStuff.WaypointESP_ShowIcon ~= false;
		WaypointESP_ShowHighlight = NAStuff.WaypointESP_ShowHighlight ~= false;
		WaypointESP_MaxDistance = math.clamp(tonumber(NAStuff.WaypointESP_MaxDistance) or 100000, 50, 100000);
		WaypointESP_IconSize = math.clamp(math.floor((tonumber(NAStuff.WaypointESP_IconSize) or 42) + 0.5), 16, 96);
		WaypointESP_TextSize = math.clamp(math.floor((tonumber(NAStuff.WaypointESP_TextSize) or 18) + 0.5), 10, 48);
		WaypointESP_Color = NAmanage.UserButtonColorToTable(NAStuff.WaypointESP_Color or Color3.fromRGB(75, 155, 255));
		WaypointPath_ShowNodes = NAStuff.WaypointPath_ShowNodes ~= false;
		WaypointPath_ShowText = NAStuff.WaypointPath_ShowText == true;
		WaypointPath_LoopMode = tostring(NAStuff.WaypointPath_LoopMode or "walk");
		WaypointPath_TweenSpeed = math.clamp(tonumber(NAStuff.WaypointPath_TweenSpeed) or 24, 1, 500);
		WaypointPath_TeleportDelay = math.clamp(tonumber(NAStuff.WaypointPath_TeleportDelay) or 0.25, 0, 10);
		ESP_MaxPerStep = math.clamp(math.floor(tonumber(NAStuff.ESP_MaxPerStep) or 24), 1, 256);
		ESP_FolderMode = (Lower(tostring(NAStuff.ESP_FolderMode)) == "models") and "models" or "parts";
		ESP_ModelMode = (Lower(tostring(NAStuff.ESP_ModelMode)) == "models") and "models" or "parts";
		NPC_ESP_RenderMode = npcMode;
	}
	NAmanage.ESPSettingsState.encoded = Services.HttpService:JSONEncode(d)
	NAmanage.ESPSettingsState.okWrite, NAmanage.ESPSettingsState.writeErr = NAmanage.safeWriteJsonFileWithRecovery(NAfiles.NAESPSETTINGSPATH, NAmanage.ESPSettingsState.encoded, {
		tempPath = NAfiles.NAESPSETTINGSPATH..".tmp";
		backupPath = NAfiles.NAESPSETTINGSPATH..".bak";
	})
	NAmanage.ESPSettingsState.saving = false
	NAmanage.ESPSettingsState.lastSaveOk = NAmanage.ESPSettingsState.okWrite == true
	NAmanage.ESPSettingsState.lastSaveError = NAmanage.ESPSettingsState.okWrite and nil or tostring(NAmanage.ESPSettingsState.writeErr)
	if NAmanage.ESPSettingsState.queuedAfterSave == true and NAmanage.ESPSettingsState.loaded == true then
		NAmanage.ESPSettingsState.queuedAfterSave = false
		Defer(function()
			if NAmanage.ESPSettingsState and NAmanage.ESPSettingsState.loaded == true then
				NAmanage.SaveESPSettings({ force = true; reason = "queued ESPSettings save" })
			end
		end)
	end
	return NAmanage.ESPSettingsState.okWrite, NAmanage.ESPSettingsState.writeErr
end

NAmanage.ESP_LocatorRegisterArrow = function(key, frame, label)
	if not key or not frame then return end
	NAStuff.ESP_LocatorArrows[key] = {
		frame = frame,
		label = label,
	}
end

NAmanage.ESP_LocatorRemoveArrow = function(key)
	const d = NAStuff.ESP_LocatorArrows[key]
	if not d then return end
	if NAmanage.ESP_LocatorDisposeHolder then
		NAmanage.ESP_LocatorDisposeHolder(d)
	end
	NAStuff.ESP_LocatorArrows[key] = nil
end

NAmanage.ESP_LocatorApplyFlags = function()
	const show = NAStuff.ESP_LocatorEnabled == true
	const showTxt = show and NAStuff.ESP_LocatorShowText == true
	const sz = math.clamp(tonumber(NAStuff.ESP_LocatorSize) or 26, 12, 128)
	const ts = math.clamp(tonumber(NAStuff.ESP_LocatorTextSize) or 14, 10, 48)

	for _, d in NAStuff.ESP_LocatorArrows do
		local f, l
		local drawingArrow, drawingLabel
		if typeof(d) == "Instance" then
			f = d
			l = d:FindFirstChild("Name")
		elseif type(d) == "table" then
			f = d.frame or d.holder
			l = d.label
			drawingArrow = d.drawingArrow
			drawingLabel = d.drawingLabel
		end
		if f then
			f.Visible = show
			const p = f:FindFirstChild("Pointer")
			if p then
				p.Size = UDim2.fromOffset(sz, sz)
			end
		end
		if l then
			l.Visible = showTxt
			l.TextSize = ts
		end
		if drawingArrow and not show then
			pcall(function()
				drawingArrow.Visible = false
			end)
		end
		if drawingLabel then
			pcall(function()
				drawingLabel.Visible = showTxt
				drawingLabel.Size = ts
			end)
		end
	end
end

NAmanage.ESP_SetLocatorEnabled = function(on)
	NAStuff.ESP_LocatorEnabled = on == true
	if NAStuff.ESP_LocatorEnabled then
		NAmanage.ESP_LocatorEnable(true)
	else
		NAmanage.ESP_LocatorDisable()
	end
	NAmanage.ESP_LocatorApplyFlags()
	NAmanage.SaveESPSettings()
end

NAmanage.ESP_SetLocatorShowText = function(on)
	NAStuff.ESP_LocatorShowText = on == true
	NAmanage.ESP_LocatorApplyFlags()
	NAmanage.SaveESPSettings()
end

NAmanage.ESP_PlayerLocatorRegisterArrow = function(key, frame, label)
	if not key or not frame then return end
	NAStuff.ESP_PlayerLocatorArrows = NAStuff.ESP_PlayerLocatorArrows or {}
	NAStuff.ESP_PlayerLocatorArrows[key] = {
		frame = frame,
		label = label,
	}
end

NAmanage.ESP_PlayerLocatorRemoveArrow = function(key)
	const arrows = NAStuff.ESP_PlayerLocatorArrows
	if not arrows then return end
	const d = arrows[key]
	if not d then return end
	if NAmanage.ESP_LocatorDisposeHolder then
		NAmanage.ESP_LocatorDisposeHolder(d)
	end
	arrows[key] = nil
end

NAmanage.ESP_PlayerLocatorApplyFlags = function()
	const arrows = NAStuff.ESP_PlayerLocatorArrows
	if type(arrows) ~= "table" then
		return
	end
	const show = NAStuff.ESP_PlayerLocatorEnabled == true
	const showTxt = show and NAStuff.ESP_PlayerLocatorShowText == true
	const sz = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorSize) or 26, 12, 128)
	const ts = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorTextSize) or 14, 10, 48)

	for _, d in arrows do
		local f, l
		local drawingArrow, drawingLabel
		if typeof(d) == "Instance" then
			f = d
			l = d:FindFirstChild("Name")
		elseif type(d) == "table" then
			f = d.frame or d.holder
			l = d.label
			drawingArrow = d.drawingArrow
			drawingLabel = d.drawingLabel
		end
		if f then
			f.Visible = show
			const p = f:FindFirstChild("Pointer")
			if p then
				p.Size = UDim2.fromOffset(sz, sz)
			end
		end
		if l then
			l.Visible = showTxt
			l.TextSize = ts
		end
		if drawingArrow and not show then
			pcall(function()
				drawingArrow.Visible = false
			end)
		end
		if drawingLabel then
			pcall(function()
				drawingLabel.Visible = showTxt
				drawingLabel.Size = ts
			end)
		end
	end
end

NAmanage.ESP_SetPlayerLocatorEnabled = function(on)
	NAStuff.ESP_PlayerLocatorEnabled = on == true
	if NAStuff.ESP_PlayerLocatorEnabled then
		NAmanage.ESP_PlayerLocatorEnable(true)
	else
		NAmanage.ESP_PlayerLocatorDisable()
	end
	NAmanage.ESP_PlayerLocatorApplyFlags()
	NAmanage.SaveESPSettings()
end

NAmanage.ESP_SetPlayerLocatorShowText = function(on)
	NAStuff.ESP_PlayerLocatorShowText = on == true
	NAmanage.ESP_PlayerLocatorApplyFlags()
	NAmanage.SaveESPSettings()
end

NAmanage.ScheduleBinderHookRefresh = NAmanage.ScheduleBinderHookRefresh or function()
	if NAmanage._binderHookRefreshQueued then
		return
	end
	NAmanage._binderHookRefreshQueued = true
	Defer(function()
		NAmanage._binderHookRefreshQueued = false
		if type(NAmanage.RefreshBinderHooks) == "function" then
			NAmanage.RefreshBinderHooks()
		end
	end)
end

NAmanage.SaveBinders=function()
	if FileSupport then
		NAmanage.safeWriteFile(bindersPath, Services.HttpService:JSONEncode(Bindings))
	end
	if type(NAmanage.ScheduleBinderHookRefresh) == "function" then
		NAmanage.ScheduleBinderHookRefresh()
	end
end

NAmanage.BinderEntryText=function(entry)
	if type(entry) == "string" then
		return entry
	end
	if type(entry) == "table" then
		const text = entry.cmd or entry.command or entry.text or entry.value or entry[1]
		if type(text) == "string" then
			return text
		end
	end
	return ""
end

NAmanage.BinderEntryDisabled=function(entry)
	return type(entry) == "table" and (entry.disabled == true or entry.enabled == false)
end

NAmanage.BinderMakeEntry=function(text, disabled)
	text = NAmanage.BinderEntryText(text)
	if disabled == true then
		return { cmd = text; disabled = true }
	end
	return text
end

NAmanage.BinderSetDisabled=function(evName, index, disabled)
	const list = Bindings and Bindings[evName]
	if type(list) ~= "table" then
		return false
	end
	const entry = list[index]
	const text = NAmanage.BinderEntryText(entry)
	if text == "" then
		return false
	end
	list[index] = NAmanage.BinderMakeEntry(text, disabled == true)
	NAmanage.SaveBinders()
	return true
end

NAmanage.BinderCounts=function(evName)
	const list = Bindings and Bindings[evName]
	local active = 0
	local total = 0
	if type(list) ~= "table" then
		return active, total
	end
	for _, entry in list do
		if NAmanage.BinderEntryText(entry) ~= "" then
			total += 1
			if not NAmanage.BinderEntryDisabled(entry) then
				active += 1
			end
		end
	end
	return active, total
end

NAStuff.CKBA = NAStuff.CKBA or {
	ctrl = "Ctrl";
	control = "Ctrl";
	leftcontrol = "Ctrl";
	rightcontrol = "Ctrl";
	lctrl = "Ctrl";
	rctrl = "Ctrl";
	shift = "Shift";
	leftshift = "Shift";
	rightshift = "Shift";
	lshift = "Shift";
	rshift = "Shift";
	alt = "Alt";
	option = "Alt";
	leftalt = "Alt";
	rightalt = "Alt";
	lalt = "Alt";
	ralt = "Alt";
}
NAStuff.CKBO = NAStuff.CKBO or {"Ctrl", "Shift", "Alt"}
NAStuff.CKBM = NAStuff.CKBM or {
	LeftControl = "Ctrl";
	RightControl = "Ctrl";
	LeftShift = "Shift";
	RightShift = "Shift";
	LeftAlt = "Alt";
	RightAlt = "Alt";
}
NAStuff.CKBX = NAStuff.CKBX or {
	leftclick = "LeftClick";
	leftmouse = "LeftClick";
	mouse1 = "LeftClick";
	mousebutton1 = "LeftClick";
	lmb = "LeftClick";
	rightclick = "RightClick";
	rightmouse = "RightClick";
	mouse2 = "RightClick";
	mousebutton2 = "RightClick";
	rmb = "RightClick";
}
NAStuff.CKBL = NAStuff.CKBL or nil

NAmanage.CKBMap = function()
	if NAStuff.CKBL then
		return NAStuff.CKBL
	end
	const lut = {}
	local ok, items = pcall(function()
		return Enum.KeyCode:GetEnumItems()
	end)
	if ok and type(items) == "table" then
		for _, item in items do
			lut[Lower(item.Name)] = item.Name
		end
	end
	for alias, name in NAStuff.CKBX do
		lut[alias] = name
	end
	NAStuff.CKBL = lut
	return lut
end

NAmanage.CKBKey = function(tok)
	if type(tok) ~= "string" or tok == "" then
		return nil
	end
	const lut = NAmanage.CKBMap()
	const name = lut[Lower(tok)]
	if name then
		return name
	end
	local ok, direct = pcall(function()
		return Enum.KeyCode[tok]
	end)
	if ok and direct then
		return direct.Name
	end
	const alias = NAStuff.CKBX[Lower(tok)]
	if alias then
		return alias
	end
	return nil
end

NAmanage.CKBNorm = function(rawKey)
	const trimmed = type(rawKey) == "string" and (rawKey:match("^%s*(.-)%s*$") or "") or ""
	if trimmed == "" then
		return nil
	end

	const parts = {}
	for part in trimmed:gmatch("[^%+]+") do
		const piece = tostring(part):match("^%s*(.-)%s*$") or ""
		if piece ~= "" then
			Insert(parts, piece)
		end
	end
	if #parts == 0 then
		return nil
	end

	if #parts == 1 then
		return NAmanage.CKBKey(parts[1])
	end

	local mainKey = nil
	const modifiers = {}
	for _, piece in parts do
		const resolved = NAmanage.CKBKey(piece)
		local modifier = NAStuff.CKBA[Lower(piece)]
		if not modifier and resolved then
			modifier = NAStuff.CKBA[Lower(resolved)]
		end
		if modifier then
			modifiers[modifier] = true
		else
			if not resolved then
				return nil
			end
			if mainKey and mainKey ~= resolved then
				return nil
			end
			mainKey = resolved
		end
	end

	if not mainKey then
		return nil
	end

	const normalized = {}
	for _, modifier in NAStuff.CKBO do
		if modifiers[modifier] then
			Insert(normalized, modifier)
		end
	end
	Insert(normalized, mainKey)
	return Concat(normalized, "+")
end

NAmanage.CKBBind = function(input, UIS)
	if not (input and UIS) then
		return nil
	end

	local keyName = nil
	if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode then
		keyName = input.KeyCode.Name
		if NAStuff.CKBM[keyName] then
			return nil
		end
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		keyName = "LeftClick"
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		keyName = "RightClick"
	else
		return nil
	end

	const combo = {}
	const ctrlDown = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftControl) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightControl)
	const shiftDown = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftShift) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightShift)
	const altDown = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftAlt) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightAlt)

	if ctrlDown then Insert(combo, "Ctrl") end
	if shiftDown then Insert(combo, "Shift") end
	if altDown then Insert(combo, "Alt") end
	Insert(combo, keyName)

	return Concat(combo, "+")
end

NAmanage.CKBRel = function(bindKey, relKey)
	if type(bindKey) ~= "string" or type(relKey) ~= "string" then
		return false
	end

	const norm = NAmanage.CKBNorm(bindKey) or bindKey
	const relNorm = NAmanage.CKBKey(relKey) or relKey
	const parts = {}
	for part in tostring(norm):gmatch("[^%+]+") do
		Insert(parts, part)
	end
	if #parts == 0 then
		return bindKey == relNorm
	end

	const relMod = NAStuff.CKBM[relNorm]
	if relMod then
		for i = 1, #parts - 1 do
			if parts[i] == relMod then
				return true
			end
		end
		return false
	end

	return parts[#parts] == relNorm
end

NAmanage.CKBRes = function(cand, nMap)
	if type(cand) ~= "string" or cand == "" then
		return nil, nil
	end

	local args = CommandKeybinds[cand]
	if type(args) == "table" then
		return cand, args
	end

	const map = type(nMap) == "table" and nMap or {}
	local mapped = map[cand]
	if mapped and type(CommandKeybinds[mapped]) == "table" then
		return mapped, CommandKeybinds[mapped]
	end

	const nKey = NAmanage.CKBNorm(cand)
	if nKey and nKey ~= "" then
		args = CommandKeybinds[nKey]
		if type(args) == "table" then
			return nKey, args
		end
		mapped = map[nKey]
		if mapped and type(CommandKeybinds[mapped]) == "table" then
			return mapped, CommandKeybinds[mapped]
		end
	end

	return nil, nil
end

NAmanage.CanUseCommandKeybinds = function(showNotif)
	const UIS = Services.UserInputService
	const allowed = UIS and UIS.KeyboardEnabled == true
	if not allowed and showNotif then
		DoNotif("Command Keybinds require keyboard input.", 2)
	end
	return allowed and true or false
end

NAmanage.SaveCommandKeybinds=function()
	if not FileSupport then return end

	const payload = {}
	for key, args in CommandKeybinds do
		const nKey = (type(key) == "string" and NAmanage.CKBNorm(key)) or nil
		const saveKey = nKey or key
		if type(saveKey) == "string" and saveKey ~= "" and type(args) == "table" then
			const opt = CommandKeybindOptions[key] or CommandKeybindOptions[saveKey]
			const disabled = opt and opt.disabled == true
			local entry
			if opt and opt.toggle then
				entry = {
					args1 = args;
					args2 = opt.args2 or args;
				}
				if opt.hold then
					entry.hold = true
				end
			elseif opt and opt.spam then
				entry = {
					args = args;
					spam = true;
				}
				if opt.hold then
					entry.hold = true
				end
			elseif disabled then
				entry = {
					args = args;
				}
			else
				entry = args
			end
			if disabled and type(entry) == "table" then
				entry.disabled = true
			end
			payload[saveKey] = entry
		end
	end

	local ok, err = pcall(function()
		return NAmanage.safeWriteFile(NAfiles.NACOMMANDKEYBINDS, Services.HttpService:JSONEncode(payload))
	end)
	if not ok then
		warn("[NA] Command keybind save failed: "..tostring(err))
	end
end

NAmanage.ApplyCommandKeybinds=function()
	if type(NAStuff.CommandKeySpamCleanup) == "function" then
		pcall(NAStuff.CommandKeySpamCleanup)
	end
	NAStuff.CommandKeySpamCleanup = nil
	if NAStuff.KeybindConnection then
		NAStuff.KeybindConnection:Disconnect()
		NAStuff.KeybindConnection = nil
	end
	if NAStuff.KeybindEndConnection then
		NAStuff.KeybindEndConnection:Disconnect()
		NAStuff.KeybindEndConnection = nil
	end
	if NAStuff.KeybindClickConnection then
		NAStuff.KeybindClickConnection:Disconnect()
		NAStuff.KeybindClickConnection = nil
	end
	const UIS = Services.UserInputService
	if not UIS then
		return
	end
	if not NAmanage.CanUseCommandKeybinds() then
		return
	end

	const function cloneArgs(src)
		const dst = {}
		for i, v in src do
			dst[i] = v
		end
		return dst
	end

	const function isStrongKeybindInput(input)
		return input and input.UserInputType == Enum.UserInputType.Keyboard
	end

	const function shouldBlock(input, gameProcessed)
		if gameProcessed and not isStrongKeybindInput(input) then return true end
		if not NAmanage.CanUseCommandKeybinds() then return true end
		if NAStuff._capturingCommandKeybind then return true end
		if NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive() then return true end
		return false
	end

	const function resolveInputBindName(input)
		if not input then
			return nil
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode then
			return input.KeyCode.Name
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			return "LeftClick"
		end
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			return "RightClick"
		end
		return nil
	end

	const function safeKc(name)
		if type(name) ~= "string" or name == "" then
			return nil
		end
		local ok, keyCode = pcall(function()
			return Enum.KeyCode[name]
		end)
		if ok and keyCode then
			return keyCode
		end
		return nil
	end

	const function resolveBindOnlyClickAction(args)
		if type(args) ~= "table" or type(args[1]) ~= "string" then
			return nil
		end
		const commandName = Lower(args[1])
		if commandName == "clickteleport" or commandName == "clicktp" then
			return "teleport"
		end
		if commandName == "clickdelete" or commandName == "clickdel" then
			return "delete"
		end
		return nil
	end

	const function bindComboActiveForClick(bindKey)
		const normalized = NAmanage.CKBNorm(bindKey) or bindKey
		if type(normalized) ~= "string" or normalized == "" then
			return false
		end

		const parts = {}
		for part in normalized:gmatch("[^%+]+") do
			const piece = tostring(part):match("^%s*(.-)%s*$") or ""
			if piece ~= "" then
				Insert(parts, piece)
			end
		end
		if #parts == 0 then
			return false
		end

		for i = 1, #parts - 1 do
			const modifier = parts[i]
			if modifier == "Ctrl" then
				if not (__lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftControl) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightControl)) then
					return false
				end
			elseif modifier == "Shift" then
				if not (__lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftShift) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightShift)) then
					return false
				end
			elseif modifier == "Alt" then
				if not (__lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftAlt) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightAlt)) then
					return false
				end
			else
				return false
			end
		end

		const main = NAmanage.CKBKey(parts[#parts]) or parts[#parts]
		if main == "LeftClick" then
			return __lt.cm("UserInputService", "IsMouseButtonPressed", Enum.UserInputType.MouseButton1)
		end
		if main == "RightClick" then
			return __lt.cm("UserInputService", "IsMouseButtonPressed", Enum.UserInputType.MouseButton2)
		end

		const keyCode = safeKc(main)
		if keyCode then
			return __lt.cm("UserInputService", "IsKeyDown", keyCode)
		end
		return false
	end

	const function runBindOnlyClickAction(actionName)
		if actionName == "teleport" then
			const player = Services.Players and Services.Players.LocalPlayer
			const char = player and player.Character
			if not (player and char and mouse) then
				return
			end
			const hit = NAmanage._tpTargetFromMouse(mouse, char)
			if not hit then
				return
			end
			const targetPosition = hit.Position + Vector3.new(0, 2.5, 0)
			NAmanage.safePivotModel(char, CFrame.new(targetPosition))
			return
		end

		if actionName == "delete" then
			pcall(function()
				const target = NAmanage.GetMouseTargetPart(mouse, { player and player.Character }, 1024)
				if target and target.Parent then
					target:Destroy()
				end
			end)
		end
	end

	const activeHoldKeys = {}
	const keySpamState = {}
	const activeSpamKeys = {}
	const keyInputGap = 0.06
	const keySpamGap = tonumber(NAStuff.CommandKeySpamGap) or 0.06
	const nMap = {}
	const bindLut = {}
	const bindHit = {}
	const clkBinds = {}
	local anyBind = false
	local holdBind = false
	local spamHoldBind = false

	for rawKey, args in CommandKeybinds do
		if type(rawKey) == "string" and type(args) == "table" then
			const nKey = NAmanage.CKBNorm(rawKey)
			if nKey and nKey ~= "" and rawKey ~= nKey then
				nMap[nKey] = rawKey
			end

			const canonical = nKey or rawKey
			if type(canonical) == "string" and canonical ~= "" then
				anyBind = true
				bindLut[rawKey] = canonical
				bindLut[canonical] = canonical

				const action = resolveBindOnlyClickAction(args)
				if action then
					Insert(clkBinds, {
						key = canonical;
						rawKey = rawKey;
						action = action;
					})
				end

				const opt = CommandKeybindOptions[canonical] or CommandKeybindOptions[rawKey]
				if opt and opt.toggle and opt.hold and type(opt.args2) == "table" then
					holdBind = true
				end
				if opt and opt.spam and opt.hold then
					spamHoldBind = true
				end
			end
		end
	end

	if not anyBind then
		return
	end

	const function getBOpt(boundKey)
		if type(boundKey) ~= "string" or boundKey == "" then
			return nil
		end
		local opt = CommandKeybindOptions[boundKey]
		if opt then
			return opt
		end
		local mapped = nMap[boundKey]
		if mapped then
			opt = CommandKeybindOptions[mapped]
			if opt then
				return opt
			end
		end
		const normalized = NAmanage.CKBNorm(boundKey)
		if normalized and normalized ~= boundKey then
			opt = CommandKeybindOptions[normalized]
			if opt then
				return opt
			end
			mapped = nMap[normalized]
			if mapped then
				opt = CommandKeybindOptions[mapped]
				if opt then
					return opt
				end
			end
		end
		return nil
	end

	const function resCand(cand)
		if type(cand) ~= "string" or cand == "" then
			return nil, nil
		end

		const cached = bindHit[cand]
		if cached ~= nil then
			if cached == false then
				return nil, nil
			end
			const args = CommandKeybinds[cached]
			if type(args) == "table" then
				return cached, args
			end
			bindHit[cand] = false
			return nil, nil
		end

		const canonical = bindLut[cand]
		if canonical and type(CommandKeybinds[canonical]) == "table" then
			bindHit[cand] = canonical
			return canonical, CommandKeybinds[canonical]
		end

		local boundKey, args = NAmanage.CKBRes(cand, nMap)
		if boundKey and type(args) == "table" then
			bindHit[cand] = boundKey
			bindLut[cand] = boundKey
			return boundKey, args
		end

		bindHit[cand] = false
		return nil, nil
	end

	const function stopSpam(boundKey)
		const rec = activeSpamKeys[boundKey]
		if not rec then
			return false
		end
		rec.active = false
		activeSpamKeys[boundKey] = nil
		const opt = getBOpt(boundKey)
		if opt then
			opt.state = false
		end
		return true
	end

	const function startSpam(boundKey, args)
		if activeSpamKeys[boundKey] or type(args) ~= "table" or #args == 0 then
			return false
		end
		const rec = {
			active = true;
		}
		activeSpamKeys[boundKey] = rec
		const opt = getBOpt(boundKey)
		if opt then
			opt.state = true
		end
		Spawn(function()
			while rec.active do
				pcall(function()
					cmd.run(cloneArgs(args))
				end)
				Wait(keySpamGap)
			end
		end)
		return true
	end

	NAStuff.CommandKeySpamCleanup = function()
		for boundKey in activeSpamKeys do
			stopSpam(boundKey)
		end
	end

	NAStuff.KeybindConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
		if not input then return end
		if shouldBlock(input, gameProcessed) then return end
		const inputType = input.UserInputType
		if inputType ~= Enum.UserInputType.Keyboard
			and inputType ~= Enum.UserInputType.MouseButton1
			and inputType ~= Enum.UserInputType.MouseButton2 then
			return
		end

		const cKey = NAmanage.CKBBind(input, UIS)
		const keyName = resolveInputBindName(input)
		local boundKey, args = resCand(cKey)
		if not boundKey and keyName then
			boundKey, args = resCand(keyName)
		end
		if type(args) ~= "table" or #args == 0 then
			return
		end
		const now = os.clock()
		const last = keySpamState[boundKey]
		if last and (now - last) < keyInputGap then
			return
		end
		keySpamState[boundKey] = now

		const opt = getBOpt(boundKey)
		if opt and opt.disabled then
			return
		end
		if resolveBindOnlyClickAction(args) then
			return
		end
		if opt and opt.spam then
			if opt.hold then
				if activeSpamKeys[boundKey] then
					return
				end
				startSpam(boundKey, args)
				return
			end
			if stopSpam(boundKey) then
				return
			end
			startSpam(boundKey, args)
			return
		end
		if opt and opt.toggle and opt.hold and type(opt.args2) == "table" then
			if activeHoldKeys[boundKey] then
				return
			end
			activeHoldKeys[boundKey] = true
			opt.state = true
			cmd.run(cloneArgs(args))
			return
		end
		if opt and opt.toggle and type(opt.args2) == "table" then
			opt.state = not opt.state
			local runArgs
			if opt.state then
				runArgs = cloneArgs(args)
			else
				runArgs = cloneArgs(opt.args2)
			end
			cmd.run(runArgs)
		else
			cmd.run(cloneArgs(args))
		end
	end)

	if holdBind or spamHoldBind then
		NAStuff.KeybindEndConnection = UIS.InputEnded:Connect(function(input, gameProcessed)
			const keyName = resolveInputBindName(input)
			if not keyName then
				return
			end
			const relHolds = {}
			const relSpams = {}
			for holdKey in activeHoldKeys do
				if NAmanage.CKBRel(holdKey, keyName) then
					Insert(relHolds, holdKey)
				end
			end
			for spamKey in activeSpamKeys do
				const opt = getBOpt(spamKey)
				if opt and opt.spam and opt.hold and NAmanage.CKBRel(spamKey, keyName) then
					Insert(relSpams, spamKey)
				end
			end

			if #relHolds == 0 and #relSpams == 0 and shouldBlock(input, gameProcessed) then
				return
			end

			for _, holdKey in relHolds do
				const opt = getBOpt(holdKey)
				if opt and opt.toggle and opt.hold and not opt.disabled and type(opt.args2) == "table" then
					cmd.run(cloneArgs(opt.args2))
				end
				activeHoldKeys[holdKey] = nil
				if opt then
					opt.state = false
				end
			end
			for _, spamKey in relSpams do
				stopSpam(spamKey)
			end
		end)
	end

	if mouse and mouse.Button1Down and #clkBinds > 0 then
		NAStuff.KeybindClickConnection = mouse.Button1Down:Connect(function()
			if NAStuff._capturingCommandKeybind then
				return
			end
			if NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive() then
				return
			end

			for _, rec in clkBinds do
				const opt = getBOpt(rec.key) or getBOpt(rec.rawKey)
				if not (opt and opt.disabled) and bindComboActiveForClick(rec.key) then
					runBindOnlyClickAction(rec.action)
				end
			end
		end)
	end
end

NAmanage.LoadCommandKeybinds=function()
	CommandKeybinds = {}
	CommandKeybindOptions = {}
	if FileSupport and isfile and isfile(NAfiles.NACOMMANDKEYBINDS) then
		local okRead, raw = pcall(readfile, NAfiles.NACOMMANDKEYBINDS)
		if okRead and type(raw) == "string" and raw ~= "" then
			local okDecode, decoded = pcall(function()
				return Services.HttpService:JSONDecode(raw)
			end)
			if okDecode and type(decoded) == "table" then
				for key, value in decoded do
					if type(key) == "string" and type(value) == "table" then
						const saveKey = NAmanage.CKBNorm(key) or key
						if type(saveKey) ~= "string" or saveKey == "" then
							continue
						end
						local args = nil
						local opt = nil
						const disabled = value.disabled == true
						if type(value.args1) == "table" and type(value.args2) == "table" then
							args = value.args1
							opt = {
								toggle = true;
								state = false;
								args2 = value.args2;
								hold = value.hold == true;
							}
						elseif type(value.args) == "table" then
							args = value.args
							if value.spam == true then
								opt = {
									spam = true;
									state = false;
									hold = value.hold == true;
								}
							elseif value.toggle == true then
								const args2 = {}
								for i, v in args do
									args2[i] = v
								end
								if type(args2[1]) == "string" then
									const cmdName = args2[1]
									const lower = Lower(cmdName)
									if lower:sub(1, 2) == "un" then
										args2[1] = cmdName:sub(3)
									else
										args2[1] = "un"..cmdName
									end
								end
								opt = {
									toggle = true;
									state = false;
									args2 = args2;
									hold = value.hold == true;
								}
							end
						end
						if not args then
							args = value
						end
						if type(args) == "table" then
							CommandKeybinds[saveKey] = args
							if disabled then
								opt = opt or {}
								opt.disabled = true
							end
							if opt then
								CommandKeybindOptions[saveKey] = opt
							end
						end
					end
				end
			end
		end
	end
	NAmanage.ApplyCommandKeybinds()
	Defer(function()
		if type(NAmanage.CommandKeybindsUIRefresh) == "function" then
			pcall(NAmanage.CommandKeybindsUIRefresh)
		end
	end)
end

originalIO.deepCopyTable=function(value)
	if type(value) ~= "table" then return value end
	const copy = {}
	for k, v in value do
		copy[k] = originalIO.deepCopyTable(v)
	end
	return copy
end

originalIO.safeDeleteFile=function(path)
	if type(path) ~= "string" then
		return false, "Invalid file path."
	end
	if not (delfile and isfile) then
		return false, "File deletion not supported by this executor."
	end
	if not isfile(path) then
		return true, "File already removed."
	end
	local ok, err = pcall(delfile, path)
	if not ok then
		return false, err or "Failed to delete file."
	end
	return true, "File deleted."
end

originalIO.safeClearFolder=function(path, opts)
	opts = opts or {}
	if type(path) ~= "string" then
		return false, "Invalid folder path."
	end
	if not (isfolder and listfiles and makefolder) then
		return false, "Folder operations not supported by this executor."
	end
	if not isfolder(path) then
		return true, "Folder already removed."
	end

	local okList, entries = pcall(listfiles, path)
	if okList and type(entries) == "table" then
		for _, entry in entries do
			if isfolder(entry) then
				local okSub, errSub = originalIO.safeClearFolder(entry, { removeRoot = true })
				if not okSub then
					return false, errSub
				end
				if delfolder then
					local okDel, errDel = pcall(delfolder, entry)
					if not okDel then
						return false, errDel or ("Failed to remove "..entry)
					end
				end
			else
				if isfile and isfile(entry) then
					local okDel, errDel = pcall(delfile, entry)
					if not okDel then
						return false, errDel or ("Failed to delete "..entry)
					end
				end
			end
		end
	end

	local removedRoot = false
	if opts.removeRoot then
		if delfolder then
			local okDel, errDel = pcall(delfolder, path)
			if not okDel then
				return false, errDel or ("Failed to remove "..path)
			end
			removedRoot = true
		end
	end

	if (opts.recreate or (opts.removeRoot and not removedRoot)) and makefolder then
		local okMk, errMk = pcall(makefolder, path)
		if not okMk then
			return false, errMk or ("Failed to recreate "..path)
		end
		if path == NAfiles.NAFILEPATH and type(NAmanage.ensureNoMediaFile) == "function" then
			NAmanage.ensureNoMediaFile()
		end
	end

	if opts.removeRoot and not removedRoot and not delfolder then
		return true, "Cleared folder contents (folder kept; executor lacks delfolder)."
	end
	if removedRoot and opts.recreate then
		return true, "Folder rebuilt."
	elseif removedRoot then
		return true, "Folder removed."
	end
	return true, "Folder cleared."
end

NAStuff.clnExtMap = NAStuff.clnExtMap or {
	json = "JSON Source File",
	txt = "Text Source File",
	lua = "Luau Script",
	luau = "Luau Script",
	log = "Log File",
	cfg = "Config File",
	ini = "Config File",
	dat = "Data File",
	png = "PNG Image",
	jpg = "JPEG Image",
	jpeg = "JPEG Image",
	webp = "WebP Image",
	bmp = "Bitmap Image",
	mp3 = "MP3 Audio",
	wav = "WAV Audio",
	ogg = "OGG Audio",
}

function NAmanage.clnBase(path)
	return tostring(path):match("([^/\\]+)$") or tostring(path)
end

function NAmanage.clnDisp(path, kind)
	if kind == "folder" then
		return "Folder"
	end
	const name = NAmanage.clnBase(path)
	const ext = name:match("%.([^%.]+)$")
	if not ext then
		return "File"
	end
	const extLower = Lower(ext)
	return NAStuff.clnExtMap[extLower] or (string.upper(extLower).." File")
end

function NAmanage.clnList()
	const entries = {}
	if not FileSupport or not (listfiles and isfolder and isfolder(NAfiles.NAFILEPATH)) then
		return entries
	end

	local okList, children = pcall(listfiles, NAfiles.NAFILEPATH)
	if not okList or type(children) ~= "table" then
		return entries
	end

	table.sort(children, function(a, b)
		return NAmanage.clnBase(a):lower() < NAmanage.clnBase(b):lower()
	end)

	for _, path in children do
		const label = NAmanage.clnBase(path)
		if label and label ~= "" then
			const isDir = isfolder(path)
			entries[#entries + 1] = {
				label = label,
				path = path,
				kind = isDir and "folder" or "file",
				displayType = NAmanage.clnDisp(path, isDir and "folder" or "file"),
				removeRoot = isDir and true or nil,
				recreate = isDir and true or nil,
				success = Format("%s removed.", label),
			}
		end
	end

	if #entries > 0 then
		Insert(entries, 1, {
			label = "[Clear Entire Folder]",
			path = NAfiles.NAFILEPATH,
			kind = "folder",
			displayType = "Nameless-Admin folder",
			removeRoot = true,
			recreate = true,
			success = "Nameless-Admin folder cleared.",
		})
	end

	return entries
end

function NAmanage.buildSettingsCleanupButtons()
	const buttons = {}
	if not FileSupport then
		return buttons
	end

	for _, opt in NAmanage.clnList() do
		const buttonText = Format("%s (%s)", opt.label, opt.displayType or opt.kind)
		Insert(buttons, {
			Text = buttonText,
			Callback = function()
				local ok, info
				if opt.kind == "file" then
					ok, info = originalIO.safeDeleteFile(opt.path)
				else
					ok, info = originalIO.safeClearFolder(opt.path, { removeRoot = opt.removeRoot, recreate = opt.recreate })
				end

				if ok then
					DoNotif(opt.success or info or Format("%s removed.", opt.label), 3)
					if type(opt.after) == "function" then
						pcall(opt.after)
					end
				else
					DoNotif(opt.failure or Format("Failed to remove %s: %s", opt.label, tostring(info)), 4)
				end
			end,
		})
	end

	return buttons
end

function NAmanage.openSettingsCleanupPopup()
	if not FileSupport then
		DoNotif("File support is required to delete saved settings.", 3)
		return
	end
	if type(Popup) ~= "function" then
		DoNotif("Popup UI is unavailable in this session.", 3)
		return
	end

	const buttons = NAmanage.buildSettingsCleanupButtons()
	if #buttons == 0 then
		DoNotif("No saved Nameless-Admin files or folders were found.", 3)
		return
	end

	Popup({
		Title = "Delete Saved Settings",
		Description = "Select a saved file or folder to remove. This action cannot be undone.",
		Duration = 0,
		Buttons = buttons,
	})
end

opt.chatTranslateEnabled = NAmanage.NASettingsGet("chatTranslate")
opt.chatTranslateTarget = NAmanage.NASettingsGet("chatTranslateTarget")
opt.settingsTranslateTarget = NAmanage.NASettingsGet("settingsTranslateTarget")
NAStuff.AutoExecEnabled = NAmanage.NASettingsGet("autoExecEnabled")
NAStuff.UserButtonsAutoLoad = NAmanage.NASettingsGet("userButtonsAutoLoad")
NAStuff.CmdBar2AutoRun = NAmanage.NASettingsGet("cmdbar2AutoRun")
do
	const savedCmdInputSafeMode = NAmanage.NASettingsGet("cmdInputSafeMode")
	if savedCmdInputSafeMode ~= nil then
		NAStuff.CmdInputSafeMode = savedCmdInputSafeMode ~= false
	else
		NAStuff.CmdInputSafeMode = IsOnPC == true and IsOnMobile ~= true
	end
end
NAStuff.HideCmdAutofill = NAmanage.NASettingsGet("hideCmdAutofill") == true
NAStuff.SFWMode = NAmanage.NASettingsGet("sfwMode") ~= false
NAStuff.LegacyCommandUI = NAmanage.NASettingsGet("legacyCommandUI") == true
NAStuff.LegacyHorizontalSettingsTabs = NAmanage.NASettingsGet("legacyHorizontalSettingsTabs") == true
NAStuff.SettingsSidebarCompactMode = NAmanage.NASettingsGet("compactVerticalSettingsTabs") == true
NAStuff.LoopMethodOptions = { "PostSimulation", "PreSimulation", "RenderStepped", "Heartbeat" }
NAStuff.LoopMethod = NAmanage.NASettingsGet("loopMethod") or "PostSimulation"
NAStuff.ManagementAutoRefresh = NAmanage.NASettingsGet("managementAutoRefresh") == true
NAStuff.ManagementRefreshInterval = math.clamp(tonumber(NAmanage.NASettingsGet("managementRefreshInterval")) or 2, 0.5, 10)
NAStuff.ManagementLogLines = math.clamp(math.floor(tonumber(NAmanage.NASettingsGet("managementLogLines")) or 100), 10, 1000)
NAStuff.ManagementLogFilter = tostring(NAmanage.NASettingsGet("managementLogFilter") or "All")
NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
NAStuff.MCP.notifyCommands = NAmanage.NASettingsGet("mcpNotifyActivity") ~= false
NAStuff.MCP.notifyReads = NAmanage.NASettingsGet("mcpNotifyReads") ~= false
NAStuff.MCP.allowUIAccess = NAmanage.NASettingsGet("mcpAllowUIAccess") == true
NAStuff.MCP.commandPrediction = NAmanage.NASettingsGet("mcpCommandPrediction") == true
NAStuff.AutoInteractMethod = NAmanage.NASettingsGet("autoInteractMethod") or NAStuff.AutoInteractMethod or "PostSimulation"
NAStuff.AutoFireRemoteMethod = NAmanage.NASettingsGet("autoFireRemoteMethod") or NAStuff.AutoFireRemoteMethod or "PostSimulation"
NAStuff.NetworkPauseDisabled = NAmanage.NASettingsGet("networkPauseDisabled")
NAStuff.UnsafeFunctionsDisabled = NAmanage.NASettingsGet("disableUnsafeFunctions") == true
NAStuff.VirtualInputAPIDisabled = NAmanage.NASettingsGet("disableVirtualInputAPI") == true
NAStuff.HWIDFunctionsDisabled = NAmanage.NASettingsGet("disableHWIDFunctions") == true
NAStuff.HWIDSpoofEnabled = NAmanage.NASettingsGet("spoofHWID") == true
NAStuff.HWIDSpoofValue = tostring(NAmanage.NASettingsGet("spoofedHWID") or "")
NAStuff.ClientIDSpoofEnabled = NAmanage.NASettingsGet("spoofClientID") == true
NAStuff.ClientIDSpoofValue = tostring(NAmanage.NASettingsGet("spoofedClientID") or "")
NAStuff.SynEnvEnabled = NAmanage.NASettingsGet("synEnv") == true
NAStuff.ForceRconsoleNAConsole = NAmanage.NASettingsGet("forceRconsoleNAConsole") ~= false
NAStuff.FriendRequestAutoDismiss = NAmanage.NASettingsGet("friendRequestAutoDismiss")
NAStuff.StreamerModeEnabled = NAmanage.NASettingsGet("streamerMode") == true
NAStuff.PurchasePromptsDisabled = NAmanage.NASettingsGet("purchasePromptsDisabled")
NAStuff.Order66PurchaseBlock = NAmanage.NASettingsGet("order66PurchaseBlock") == true
NAStuff.CmdIntegrationAutoRun = NAmanage.NASettingsGet("cmdIntegrationAutoRun")
NAStuff.CmdIntegrationRoutingMode = NAmanage.CmdIntegrationNormalizeMode(NAmanage.NASettingsGet("cmdIntegrationRoutingMode") or NAStuff.CmdIntegrationRoutingMode)
NAStuff.CmdIntegrationExposeGateway = NAmanage.NASettingsGet("cmdIntegrationExposeGateway") ~= false
NAStuff.CmdIntegrationUseNotifications = NAmanage.NASettingsGet("cmdIntegrationUseNotifications") ~= false
NAStuff.CmdIntegrationMirrorNotifications = NAmanage.NASettingsGet("cmdIntegrationMirrorNotifications") == true
NAStuff.IYIntegrationAutoRun = NAmanage.NASettingsGet("iyIntegrationAutoRun") == true
NAStuff.IYIntegrationRoutingMode = NAmanage.IYIntegrationNormalizeMode(NAmanage.NASettingsGet("iyIntegrationRoutingMode") or NAStuff.IYIntegrationRoutingMode)
NAStuff.IYIntegrationExposeGateway = NAmanage.NASettingsGet("iyIntegrationExposeGateway") ~= false
NAStuff.IYIntegrationMirrorNotifications = NAmanage.NASettingsGet("iyIntegrationMirrorNotifications") == true
NAStuff.AutoPreloadAssets = NAmanage.NASettingsGet("autoPreloadAssets")
NAStuff.LightingStyleAutomation = NAmanage.NASettingsGet("lightingStyleAutomation") == true
NAStuff.LightingStyleAutomationStyle = NAmanage.NASettingsGet("lightingStyleAutomationStyle") or "Soft"
NAStuff.PauseVoxelizerLighting = NAmanage.NASettingsGet("pauseVoxelizerLighting") == true
NAStuff.FastParticleEffects = NAmanage.NASettingsGet("fastParticleEffects") == true
NAStuff.StaffwatchIgnoreLocal = NAmanage.NASettingsGet("staffwatchIgnoreLocal") ~= false
NAStuff.StaffwatchHighlightEnabled = NAmanage.NASettingsGet("staffwatchHighlight") ~= false
NAStuff.StaffwatchOverrideESP = NAmanage.NASettingsGet("staffwatchOverrideESP") ~= false
NAStuff.StaffwatchMarkerColor = NAmanage.NASettingsGet("staffwatchMarkerColor")
NAStuff.SafeSpeedMethod = NAmanage.NASettingsGet("safeSpeedMethod") ~= false
NAStuff.EnhancedPhysicsReplication = NAmanage.NASettingsGet("enhancedPhysicsReplication") == true
NAStuff.SafeJumpMethod = NAmanage.NASettingsGet("safeJumpMethod") ~= false
NAStuff.CustomMovementSounds = NAStuff.CustomMovementSounds or {}
NAStuff.CustomMovementSounds.Enabled = NAmanage.NASettingsGet("customMovementSoundsEnabled") == true
NAStuff.CustomMovementSounds.WalkInput = tostring(NAmanage.NASettingsGet("customMovementSoundsWalk") or "")
NAStuff.CustomMovementSounds.JumpInput = tostring(NAmanage.NASettingsGet("customMovementSoundsJump") or "")
NAStuff.CustomMovementSounds.FallInput = tostring(NAmanage.NASettingsGet("customMovementSoundsFall") or "")
NAStuff.CustomMovementSounds.LandInput = tostring(NAmanage.NASettingsGet("customMovementSoundsLand") or "")
NAStuff.CustomMovementSounds.Volume = math.clamp(tonumber(NAmanage.NASettingsGet("customMovementSoundsVolume")) or 1, 0, 10)
NAStuff.AssetLoadMode = NAmanage.NASettingsGet("assetLoadMode") or NAStuff.AssetLoadMode
NAStuff.SaveInstanceConfig = {
	safeMode = NAmanage.NASettingsGet("saveInstanceSafeMode") == true;
	shutdownWhenDone = NAmanage.NASettingsGet("saveInstanceShutdownWhenDone") == true;
	antiIdle = NAmanage.NASettingsGet("saveInstanceAntiIdle") ~= false;
	showStatus = NAmanage.NASettingsGet("saveInstanceShowStatus") ~= false;
	readMe = NAmanage.NASettingsGet("saveInstanceReadMe") ~= false;
	debugMode = NAmanage.NASettingsGet("saveInstanceDebugMode") == true;
	debugLog = NAmanage.NASettingsGet("saveInstanceDebugLog") == true;
	anonymous = NAmanage.NASettingsGet("saveInstanceAnonymous") == true;
	mode = tostring(NAmanage.NASettingsGet("saveInstanceMode") or "optimized");
	decompile = NAmanage.NASettingsGet("saveInstanceDecompile") ~= false;
	scriptCache = NAmanage.NASettingsGet("saveInstanceScriptCache") ~= false;
	decompileTimeout = math.clamp(tonumber(NAmanage.NASettingsGet("saveInstanceDecompileTimeout")) or 10, 1, 120);
	decompileJobless = NAmanage.NASettingsGet("saveInstanceDecompileJobless") == true;
	saveBytecode = NAmanage.NASettingsGet("saveInstanceSaveBytecode") == true;
	decompilePrepass = NAmanage.NASettingsGet("saveInstanceDecompilePrepass") == true;
	prepassConcurrency = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("saveInstancePrepassConcurrency")) or 24) + 0.5), 1, 128);
	prepassRateGap = math.max(0, tonumber(NAmanage.NASettingsGet("saveInstancePrepassRateGap")) or 0.12);
	prepassApiUrl = tostring(NAmanage.NASettingsGet("saveInstancePrepassApiUrl") or "https://api.lua.expert/decompile");
	prepassMaxScripts = math.max(1, math.floor((tonumber(NAmanage.NASettingsGet("saveInstancePrepassMaxScripts")) or 6000) + 0.5));
	saveCacheInterval = math.max(0, math.floor((tonumber(NAmanage.NASettingsGet("saveInstanceSaveCacheInterval")) or 56320) + 0.5));
	nilInstances = NAmanage.NASettingsGet("saveInstanceNilInstances") == true;
	ignoreDefaultProperties = NAmanage.NASettingsGet("saveInstanceIgnoreDefaultProperties") ~= false;
	ignoreNotArchivable = NAmanage.NASettingsGet("saveInstanceIgnoreNotArchivable") ~= false;
	ignorePropertiesOfNotScriptsOnScriptsMode = NAmanage.NASettingsGet("saveInstanceIgnorePropertiesOfNotScriptsOnScriptsMode") == true;
	ignoreSpecialProperties = NAmanage.NASettingsGet("saveInstanceIgnoreSpecialProperties") == true;
	useUGCValidationService = NAmanage.NASettingsGet("saveInstanceUseUGCValidationService") ~= false;
	isolateStarterPlayer = NAmanage.NASettingsGet("saveInstanceIsolateStarterPlayer") == true;
	isolatePlayers = NAmanage.NASettingsGet("saveInstanceIsolatePlayers") == true;
	isolateLocalPlayer = NAmanage.NASettingsGet("saveInstanceIsolateLocalPlayer") == true;
	isolateLocalPlayerCharacter = NAmanage.NASettingsGet("saveInstanceIsolateLocalPlayerCharacter") == true;
	savePlayerCharacters = NAmanage.NASettingsGet("saveInstanceSavePlayerCharacters") == true;
	saveNotCreatable = NAmanage.NASettingsGet("saveInstanceSaveNotCreatable") == true;
	alternativeWritefile = NAmanage.NASettingsGet("saveInstanceAlternativeWritefile") ~= false;
	ignoreDefaultPlayerScripts = NAmanage.NASettingsGet("saveInstanceIgnoreDefaultPlayerScripts") ~= false;
	ignoreSharedStrings = NAmanage.NASettingsGet("saveInstanceIgnoreSharedStrings") ~= false;
	sharedStringOverwrite = NAmanage.NASettingsGet("saveInstanceSharedStringOverwrite") == true;
	treatUnionsAsParts = NAmanage.NASettingsGet("saveInstanceTreatUnionsAsParts") == true;
	setStreaming = NAmanage.NASettingsGet("saveInstanceSetStreaming") == true;
	streamingAreaSize = math.max(1, tonumber(NAmanage.NASettingsGet("saveInstanceStreamingAreaSize")) or 10000);
	streamingRadius = math.max(1, tonumber(NAmanage.NASettingsGet("saveInstanceStreamingRadius")) or 1024);
	streamingTimeout = math.max(1, tonumber(NAmanage.NASettingsGet("saveInstanceStreamingTimeout")) or 20);
	streamingConcurrency = math.max(0, math.floor((tonumber(NAmanage.NASettingsGet("saveInstanceStreamingConcurrency")) or 0) + 0.5));
	streamingSlices = math.max(1, math.floor((tonumber(NAmanage.NASettingsGet("saveInstanceStreamingSlices")) or 2) + 0.5));
	streamingMaxTime = math.max(0, tonumber(NAmanage.NASettingsGet("saveInstanceStreamingMaxTime")) or 0);
	streamingChunkWait = math.max(1, tonumber(NAmanage.NASettingsGet("saveInstanceStreamingChunkWait")) or 12);
	streamingSettleTime = math.max(0, tonumber(NAmanage.NASettingsGet("saveInstanceStreamingSettleTime")) or 5);
	neutralizeLighting = NAmanage.NASettingsGet("saveInstanceNeutralizeLighting") == true;
	exportObj = NAmanage.NASettingsGet("saveInstanceExportObj") == true;
	decompileIgnore = tostring(NAmanage.NASettingsGet("saveInstanceDecompileIgnore") or "Chat,CoreGui,CorePackages");
	ignoreList = tostring(NAmanage.NASettingsGet("saveInstanceIgnoreList") or "CoreGui,CorePackages");
	ignoreProperties = tostring(NAmanage.NASettingsGet("saveInstanceIgnoreProperties") or "");
	notCreatableFixes = tostring(NAmanage.NASettingsGet("saveInstanceNotCreatableFixes") or "Player,PlayerScripts,PlayerGui,TouchTransmitter");
	extraOptionsJson = tostring(NAmanage.NASettingsGet("saveInstanceExtraOptionsJson") or "");
	fileNameFormat = tostring(NAmanage.NASettingsGet("saveInstanceFileNameFormat") or "{placeName}_{timestamp}");
}

pcall(NAmanage.SetAssetLoadMode, NAStuff.AssetLoadMode)
pcall(NAmanage.SetUnsafeFunctionsDisabled, NAStuff.UnsafeFunctionsDisabled == true, {
	save = false;
	silent = true;
	force = true;
})
pcall(NAmanage.SetVirtualInputAPIDisabled, NAStuff.VirtualInputAPIDisabled == true, {
	save = false;
	silent = true;
	force = true;
})
pcall(NAmanage.SetHWIDFunctionsDisabled, NAStuff.HWIDFunctionsDisabled == true, {
	save = false;
	silent = true;
	force = true;
})
pcall(NAmanage.SetClientIDSpoofEnabled, NAStuff.ClientIDSpoofEnabled == true, {
	save = false;
	silent = true;
	force = true;
})
pcall(NAmanage.SetSynEnv, NAStuff.SynEnvEnabled == true, {
	save = false;
	silent = true;
	force = true;
})
pcall(NAmanage.SetForceRconsoleNAConsole, NAStuff.ForceRconsoleNAConsole == true, {
	save = false;
	silent = true;
	force = true;
})
pcall(NAmanage.setStreamerMode, NAStuff.StreamerModeEnabled == true, {
	save = false;
	silent = true;
	force = true;
})

NAmanage.loadIntegration=function()
	const integ = NAStuff.Integrations or {}
	integ.webhook = integ.webhook or {}
	integ.webhook.urls = integ.webhook.urls or {}
	const function asString(v)
		return type(v) == "string" and v or ""
	end
	integ.webhook.urls.main = integ.webhook.urls.main or integ.webhook.url or integ.webhook.urls.all or ""
	const function readUrl(key, fallback)
		const value = asString(NAmanage.NASettingsGet(key))
		if value ~= "" then
			return value
		end
		return fallback
	end
	integ.webhook.urls.main = readUrl("integrationWebhookUrlMain", integ.webhook.urls.main or "")
	integ.webhook.urls.all = readUrl("integrationWebhookUrlAll", integ.webhook.urls.all or "")
	if integ.webhook.urls.all == "" then
		const legacy = asString(NAmanage.NASettingsGet("integrationWebhookUrl"))
		if legacy ~= "" then
			integ.webhook.urls.all = legacy
		end
	end
	integ.webhook.urls.joinleave = readUrl("integrationWebhookUrlJoinLeave", integ.webhook.urls.joinleave or "")
	integ.webhook.urls.chat = readUrl("integrationWebhookUrlChat", integ.webhook.urls.chat or "")
	integ.webhook.urls.commands = readUrl("integrationWebhookUrlCommands", integ.webhook.urls.commands or "")
	integ.webhook.url = integ.webhook.urls.all
	const useAllSaved = NAmanage.NASettingsGet("integrationWebhookUseAll")
	if type(useAllSaved) == "boolean" then
		integ.webhook.useAll = useAllSaved
	end
	integ.webhook.useAll = integ.webhook.useAll == true
	integ.webhook.enableJoinLeave = NAmanage.NASettingsGet("integrationWebhookJoinLeave") == true or integ.webhook.enableJoinLeave == true
	integ.webhook.enableChat = NAmanage.NASettingsGet("integrationWebhookChat") == true or integ.webhook.enableChat == true
	integ.webhook.enableCommands = NAmanage.NASettingsGet("integrationWebhookCommands") == true or integ.webhook.enableCommands == true
	const clampNum = (NAmanage and NAmanage.clampNumber) or function(v, lo, hi, fallback)
		local n = tonumber(v)
		if not n then return fallback end
		if lo and n < lo then n = lo end
		if hi and n > hi then n = hi end
		return n
	end
	integ.webhook.minInterval = clampNum(NAmanage.NASettingsGet("integrationWebhookInterval"), 0, 30, integ.webhook.minInterval or 2)
	integ.webhook = NAmanage.ApplySavedWebhookTables(
		integ.webhook,
		NAmanage.NASettingsGet("integrationWebhookOptions"),
		NAmanage.NASettingsGet("integrationWebhookTemplates")
	)
	const webhookDraft = NAmanage.NASettingsGet("integrationWebhookDraft")
	const webhookRawDraft = NAmanage.NASettingsGet("integrationWebhookRawDraft")
	if type(webhookDraft) == "string" then integ.webhook.mainMessage = webhookDraft end
	if type(webhookRawDraft) == "string" and webhookRawDraft ~= "" then integ.webhook.rawPayload = webhookRawDraft end

	const eps = NAmanage.NASettingsGet("integrationHealthEndpoints")
	if type(eps) == "table" then
		integ.health = integ.health or { endpoints = {} }
		integ.health.endpoints = {}
		for i = 1, math.min(#eps, 3) do
			if type(eps[i]) == "string" and eps[i] ~= "" then
				integ.health.endpoints[i] = eps[i]
			end
		end
	elseif type(eps) == "string" and eps ~= "" then
		integ.health = integ.health or { endpoints = {} }
		integ.health.endpoints = { eps }
	end

	integ.notes = integ.notes or {}
	const noteSaved = NAmanage.NASettingsGet("integrationNotesLast")
	if type(noteSaved) == "string" then
		integ.notes.last = noteSaved
	end

	integ.rpc = integ.rpc or {}
	integ.rpc.useCustom = NAmanage.NASettingsGet("integrationRpcUseCustom") == true or integ.rpc.useCustom == true
	const rd = NAmanage.NASettingsGet("integrationRpcDetails")
	const rs = NAmanage.NASettingsGet("integrationRpcState")
	if type(rd) == "string" then integ.rpc.details = rd end
	if type(rs) == "string" then integ.rpc.state = rs end
	integ.webhook = NAmanage.NormalizeWebhookConfig(integ.webhook)
	NAStuff.Integrations = integ
end
NAmanage.loadIntegration()

NAStuff.CmdBar2Width = NAmanage.CmdBar2ClampValue(NAmanage.NASettingsGet("cmdbar2Width"), NAStuff.CmdBar2.minWidth, NAStuff.CmdBar2.maxWidth, NAStuff.CmdBar2.defaultWidth)
NAStuff.CmdBar2Height = NAmanage.CmdBar2ClampValue(NAmanage.NASettingsGet("cmdbar2Height"), NAStuff.CmdBar2.minHeight, NAStuff.CmdBar2.maxHeight, NAStuff.CmdBar2.defaultHeight)
_na_env.NAFreecamKeybindEnabled = NAmanage.NASettingsGet("freecamKeybind")
_na_env.NADebugDontRenderKeybindEnabled = NAmanage.NASettingsGet("debugDontRenderKeybind") == true
NAStuff.tpDelay = math.clamp(tonumber(NAmanage.NASettingsGet("tpDelay")) or 0.2, 0, 5)
NAStuff.FreecamSpeed = math.clamp(tonumber(NAmanage.NASettingsGet("freecamSpeed")) or 5, 0.05, 20)
if NAFreecam and NAFreecam.SetSpeed then
	NAFreecam.SetSpeed(math.clamp(NAStuff.FreecamSpeed / 5, 0.01, 4))
end
NAStuff.MobileFlyAutoEnableOnRun = NAmanage.NASettingsGet("mobileFlyAutoEnableOnRun") ~= false
NAStuff.FlyNoVelocityClamp = NAmanage.NASettingsGet("flyNoVelocityClamp") == true
NAStuff.CFlyVisualizerOn = NAmanage.NASettingsGet("cFlyVisualizer") ~= false
NAStuff.LowEndMode = NAmanage.NASettingsGet("lowEndUiMode") == true
NAStuff.CustomTeleportGuiEnabled = NAmanage.NASettingsGet("customTeleportGui") ~= false
NAStuff.CustomTeleportGuiGameTeleportsEnabled = NAmanage.NASettingsGet("customTeleportGuiGameTeleports") == true
NAStuff.PluginAutoLoad = NAmanage.NASettingsGet("pluginAutoLoad") ~= false
NAStuff.PluginSettingsUIEnabled = NAmanage.NASettingsGet("pluginAllowSettingsUI") ~= false
NAHideStartup = NAmanage.NASettingsGet("hideStartup") == true
NAStuff.HideStartup = NAHideStartup

NAStuff.AutoInteractDistanceEnabled = true
NAStuff.AutoInteractExtraRange = 5
NAStuff.AutoInteractDefaultInterval = math.clamp(tonumber(NAStuff.AutoInteractDefaultInterval) or 0.1, 0, 1)
NAStuff.AutoFireRemoteDefaultInterval = math.clamp(tonumber(NAStuff.AutoFireRemoteDefaultInterval) or NAStuff.AutoInteractDefaultInterval or 0.1, 0, 1)
do
	local n = tonumber(NAmanage.NASettingsGet("clickTouchMaxDistance"))
	if n == nil then
		n = tonumber(NAStuff.ClickTouchMaxDistance) or 1024
	end
	n = math.floor(n + 0.5)
	NAStuff.ClickTouchMaxDistance = (n <= 0) and 0 or math.clamp(n, 50, 5000)
end
NAStuff.ClickTouchScreenRadius = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("clickTouchScreenRadius")) or NAStuff.ClickTouchScreenRadius or 18) + 0.5), 2, 80)
NAStuff.ClickTouchBlockedByCollide = NAmanage.NASettingsGet("clickTouchBlockedByCollide") == true
NAStuff.ClickTouchIgnoreNonCollideBlockers = NAmanage.NASettingsGet("clickTouchIgnoreNonCollideBlockers") ~= false
NAStuff.ClickTouchInvisibleFallback = NAmanage.NASettingsGet("clickTouchInvisibleFallback") ~= false
NAStuff.ClickTouchAlwaysOnTop = NAmanage.NASettingsGet("clickTouchAlwaysOnTop") == true
NAStuff.RobloxDevConsoleCopyButtonsEnabled = NAStuff.RobloxDevConsoleCopyButtonsEnabled ~= false
NAStuff.NAConsoleMasterEnabled = NAStuff.NAConsoleMasterEnabled ~= false
NAStuff.DevConsoleTimestamps = NAStuff.DevConsoleTimestamps ~= false
NAStuff.DevConsoleCollapseDuplicates = NAStuff.DevConsoleCollapseDuplicates ~= false
NAStuff.DevConsoleShowSource = NAStuff.DevConsoleShowSource ~= false
NAStuff.DevConsoleCopyContext = NAStuff.DevConsoleCopyContext ~= false
NAStuff.CrosshairColor = NAStuff.CrosshairColor or Color3.new(1, 1, 1)
NAStuff.CrosshairEnabled = NAStuff.CrosshairEnabled == true
NAStuff.CrosshairSize = NAStuff.CrosshairSize or 8
NAStuff.CrosshairThickness = NAStuff.CrosshairThickness or 2
NAStuff.CrosshairGap = math.clamp(tonumber(NAStuff.CrosshairGap) or 2, 0, 30)
NAStuff.CrosshairShowCenter = NAStuff.CrosshairShowCenter ~= false
NAStuff.MobileCamSensEnabled = NAStuff.MobileCamSensEnabled == true
NAStuff.MobileCamSensitivity = math.clamp(tonumber(NAStuff.MobileCamSensitivity) or 1, 0.2, 4)
NAStuff.OffVisOn = NAStuff.OffVisOn ~= false
NAStuff.OffsetCustomization = NAmanage.NASettingsGet("offsetCustomization")
if type(NAStuff.OffsetCustomization) ~= "table" then
	NAStuff.OffsetCustomization = {
		positionX = 0;
		positionY = -15;
		positionZ = 0;
		rotationX = 0;
		rotationY = 0;
		rotationZ = 0;
		preset = "Custom";
	}
end
NAStuff.OffVisAcc = NAStuff.OffVisAcc ~= false
NAStuff.OffVisFTr = math.clamp(tonumber(NAStuff.OffVisFTr) or 0.82, 0, 1)
NAStuff.OffVisOTr = math.clamp(tonumber(NAStuff.OffVisOTr) or 0.15, 0, 1)
NAStuff.DevConsoleLogLimit = math.clamp(math.floor((tonumber(NAStuff.DevConsoleLogLimit) or 1200) + 0.5), 200, 5000)
NAStuff.DevConsoleQueueLimit = math.clamp(math.floor((tonumber(NAStuff.DevConsoleQueueLimit) or 600) + 0.5), 100, 4000)
NAStuff.DevConsoleOverscan = math.clamp(math.floor((tonumber(NAStuff.DevConsoleOverscan) or 320) + 0.5), 60, 2000)

if FileSupport then
	NAStuff.prefixCheck = NAmanage.NASettingsGet("prefix")
	NAsavedScale = NAmanage.NASettingsGet("buttonSize")
	NAUISavedScale = NAmanage.NASettingsGet("uiScale")
	NAQoTEnabled = NAmanage.NASettingsGet("queueOnTeleport")
	NAStuff.nuhuhNotifs = NAmanage.NASettingsGet("notifsToggle")
	const savedTweenSpeed = NAmanage.NASettingsGet("tweenSpeed")
	if type(savedTweenSpeed) == "number" and savedTweenSpeed > 0 then
		NAStuff.tweenSpeed = savedTweenSpeed
	end
	doPREDICTION = NAmanage.NASettingsGet("prediction")
	NAStuff.AutoInteractDistanceEnabled = NAmanage.NASettingsGet("autoInteractDistanceEnabled") ~= false
	NAStuff.AutoInteractExtraRange = tonumber(NAmanage.NASettingsGet("autoInteractExtraRange")) or 5
	NAStuff.AutoInteractDefaultInterval = math.clamp(tonumber(NAmanage.NASettingsGet("autoInteractDefaultInterval")) or NAStuff.AutoInteractDefaultInterval or 0.1, 0, 1)
	NAStuff.AutoFireRemoteDefaultInterval = math.clamp(tonumber(NAmanage.NASettingsGet("autoFireRemoteDefaultInterval")) or NAStuff.AutoFireRemoteDefaultInterval or NAStuff.AutoInteractDefaultInterval or 0.1, 0, 1)
	NAStuff.AutoInteractMethod = NAmanage.NASettingsGet("autoInteractMethod") or NAStuff.AutoInteractMethod or "PostSimulation"
	NAStuff.AutoFireRemoteMethod = NAmanage.NASettingsGet("autoFireRemoteMethod") or NAStuff.AutoFireRemoteMethod or "PostSimulation"
	NAStuff.RobloxDevConsoleCopyButtonsEnabled = NAmanage.NASettingsGet("devConsoleCopyButtons") ~= false
	NAStuff.NAConsoleMasterEnabled = NAmanage.NASettingsGet("devConsoleMasterInput") ~= false
	NAStuff.DevConsoleTimestamps = NAmanage.NASettingsGet("devConsoleTimestamps") ~= false
	NAStuff.DevConsoleCollapseDuplicates = NAmanage.NASettingsGet("devConsoleCollapseDuplicates") ~= false
	NAStuff.DevConsoleShowSource = NAmanage.NASettingsGet("devConsoleShowSource") ~= false
	NAStuff.DevConsoleCopyContext = NAmanage.NASettingsGet("devConsoleCopyContext") ~= false
	NAStuff.DevConsoleLogLimit = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("devConsoleLogLimit")) or NAStuff.DevConsoleLogLimit or 1200) + 0.5), 200, 5000)
	NAStuff.DevConsoleQueueLimit = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("devConsoleQueueLimit")) or NAStuff.DevConsoleQueueLimit or 600) + 0.5), 100, 4000)
	NAStuff.DevConsoleOverscan = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("devConsoleOverscan")) or NAStuff.DevConsoleOverscan or 320) + 0.5), 60, 2000)
	NAStuff.FPSBoostOptions = NAmanage.NASettingsGet("fpsBoostOptions")
	const savedMobileCamSens = tonumber(NAmanage.NASettingsGet("mobileCamSensitivity"))
	if savedMobileCamSens then
		NAStuff.MobileCamSensitivity = math.clamp(savedMobileCamSens, 0.2, 4)
	end
	NAStuff.MobileCamSensEnabled = NAmanage.NASettingsGet("mobileCamSensEnabled") == true
	local ovOn = NAmanage.NASettingsGet("offVisOn")
	if ovOn == nil then ovOn = NAmanage.NASettingsGet("offsetVisualizerEnabled") end
	NAStuff.OffVisOn = ovOn ~= false
	local ovAcc = NAmanage.NASettingsGet("offVisAcc")
	if ovAcc == nil then ovAcc = NAmanage.NASettingsGet("offsetVisualizerIncludeAccessories") end
	NAStuff.OffVisAcc = ovAcc ~= false
	local ovFTr = tonumber(NAmanage.NASettingsGet("offVisFTr"))
	if not ovFTr then ovFTr = tonumber(NAmanage.NASettingsGet("offsetVisualizerFillTransparency")) end
	NAStuff.OffVisFTr = math.clamp(ovFTr or NAStuff.OffVisFTr or 0.82, 0, 1)
	local ovOTr = tonumber(NAmanage.NASettingsGet("offVisOTr"))
	if not ovOTr then ovOTr = tonumber(NAmanage.NASettingsGet("offsetVisualizerOutlineTransparency")) end
	NAStuff.OffVisOTr = math.clamp(ovOTr or NAStuff.OffVisOTr or 0.15, 0, 1)
	const chColorRaw = NAmanage.NASettingsGet("crosshairColor")
	const function toColor3(tbl, fallback)
		if typeof(tbl) == "Color3" then
			return tbl
		end
		if type(tbl) == "table" then
			local r = tonumber(tbl.R or tbl.r)
			local g = tonumber(tbl.G or tbl.g)
			local b = tonumber(tbl.B or tbl.b)
			if r and g and b then
				r = math.clamp(r, 0, 1)
				g = math.clamp(g, 0, 1)
				b = math.clamp(b, 0, 1)
				return Color3.new(r, g, b)
			end
		end
		return fallback
	end
	NAStuff.CrosshairColor = toColor3(chColorRaw, Color3.new(1, 1, 1))
	NAStuff.CrosshairEnabled = NAmanage.NASettingsGet("crosshairEnabled") == true
	NAStuff.CrosshairSize = math.clamp(tonumber(NAmanage.NASettingsGet("crosshairSize")) or 8, 2, 100)
	NAStuff.CrosshairThickness = math.clamp(tonumber(NAmanage.NASettingsGet("crosshairThickness")) or 2, 1, 20)
	NAStuff.CrosshairGap = math.clamp(tonumber(NAmanage.NASettingsGet("crosshairGap")) or 2, 0, 30)
	NAStuff.CrosshairShowCenter = NAmanage.NASettingsGet("crosshairShowCenter") ~= false
	NAUISTROKER = InitUIStroke()
	if NAStuff and NAStuff.AprilFoolsData then
		NAStuff.AprilFoolsData.originalColor = NAUISTROKER
	end
	NAStuff.IconInvisible = NAmanage.NASettingsGet("iconInvisible")
	NAStuff.IconLocked = NAmanage.NASettingsGet("iconLocked")
	NATOPBARVISIBLE = NAmanage.NASettingsGet("topbarVisible")
	NATopbarKeepPosition = NAmanage.NASettingsGet("topbarKeepPosition")
	NATopbarPositionRatio = NAmanage.NASettingsGet("topbarPositionRatio") or 0
	NATopbarDock = NAmanage.topbar_readDock()
	NASideSwipeSide = NAmanage.NASettingsGet("sideSwipeSide") or NASideSwipeSide
	NASideSwipeEnabled = NAmanage.NASettingsGet("sideSwipeEnabled") or NASideSwipeEnabled
	NADisableLastInput = NAmanage.NASettingsGet("disableLastInput")
	if NAmanage.applyCrosshair then
		NAmanage.applyCrosshair()
	end
	const function clamp01(v, fallback)
		local n = tonumber(v)
		if not n then return fallback end
		if n < 0 then n = 0 elseif n > 1 then n = 1 end
		return n
	end
	NAStuff.SideSwipeWidth = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipeWidth")) or 80) + 0.5), 60, 200)
	NAStuff.SideSwipePanelHeight = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipePanelHeight")) or 0) + 0.5), 0, 1200)
	NAStuff.SideSwipeHandleWidth = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipeHandleWidth")) or 0) + 0.5), 0, 120)
	NAStuff.SideSwipeHandleHeight = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipeHandleHeight")) or 0) + 0.5), 0, 800)
	NAStuff.SideSwipeHandleVerticalPosition = math.clamp(tonumber(NAmanage.NASettingsGet("sideSwipeHandleVerticalPosition")) or 50, 0, 100)
	NAStuff.SideSwipeSwipeThreshold = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipeSwipeThreshold")) or 28) + 0.5), 8, 120)
	NAStuff.SideSwipeButtonHeight = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipeButtonHeight")) or 48) + 0.5), 32, 96)
	NAStuff.SideSwipeButtonSpacing = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipeButtonSpacing")) or 8) + 0.5), 0, 32)
	NAStuff.SideSwipeHandleTransparency = clamp01(NAmanage.NASettingsGet("sideSwipeHandleTransparency") or 0.72, 0.72)
	NAStuff.SideSwipePanelTransparency = clamp01(NAmanage.NASettingsGet("sideSwipePanelTransparency") or 0.35, 0.35)
	NAStuff.SideSwipeButtonTransparency = clamp01(NAmanage.NASettingsGet("sideSwipeButtonTransparency") or 0.16, 0.16)
	NAStuff.SideSwipeScrollBarThickness = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("sideSwipeScrollBarThickness")) or 4) + 0.5), 0, 12)
	NAStuff.ResizeHandleIconsEnabled = NAmanage.NASettingsGet("resizeHandleIcons") == true
	NALoadingStartMinimized = NAmanage.NASettingsGet("loadingStartMinimized")
	NAAssetsLoading.applyMinimizedPreference()
	NAStuff.TopbarGlassTransparency = clamp01(NAmanage.NASettingsGet("topbarGlassTransparency") or 0.12, 0.12)
	NAStuff.TopbarButtonShape = NAmanage.NASettingsGet("topbarButtonShape") or "Circle"
	NAStuff.TopbarStrokeTransparency = clamp01(NAmanage.NASettingsGet("topbarStrokeTransparency") or 0.15, 0.15)
	NAStuff.TopbarPanelTransparency = clamp01(NAmanage.NASettingsGet("topbarPanelTransparency") or 0.1, 0.1)
	NAStuff.TopbarButtonTransparency = clamp01(NAmanage.NASettingsGet("topbarButtonTransparency") or 0.18, 0.18)
	NAStuff.RobloxTopbarEditorEnabled = NAmanage.NASettingsGet("robloxTopbarEditorEnabled") == true
	NAStuff.RobloxTopbarLayout = NAmanage.NASettingsGet("robloxTopbarLayout") or "Controls Unified"
	NAStuff.RobloxTopbarMorePosition = NAmanage.NASettingsGet("robloxTopbarMorePosition") or "Original"
	NAStuff.RobloxTopbarBackgroundColor = toColor3(NAmanage.NASettingsGet("robloxTopbarBackgroundColor"), Color3.fromRGB(18, 18, 21))
	NAStuff.RobloxTopbarBackgroundTransparency = clamp01(NAmanage.NASettingsGet("robloxTopbarBackgroundTransparency") or 0.08, 0.08)
	NAStuff.RobloxTopbarCornerRadius = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("robloxTopbarCornerRadius")) or 22) + 0.5), 0, 32)
	NAStuff.RobloxTopbarSeparateGap = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("robloxTopbarSeparateGap")) or 4) + 0.5), 0, 16)
	NAStuff.RobloxTopbarButtonSize = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("robloxTopbarButtonSize")) or 44) + 0.5), 32, 56)
	NAStuff.RobloxTopbarMenuGap = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("robloxTopbarMenuGap")) or 4) + 0.5), 0, 24)
	NAStuff.RobloxTopbarGroupPadding = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("robloxTopbarGroupPadding")) or 0) + 0.5), 0, 12)
	NAStuff.RobloxTopbarVerticalOffset = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("robloxTopbarVerticalOffset")) or 10) + 0.5), 0, 32)
	NAStuff.RobloxTopbarHorizontalInset = math.clamp(math.floor((tonumber(NAmanage.NASettingsGet("robloxTopbarHorizontalInset")) or 16) + 0.5), 0, 48)
	NAStuff.RobloxTopbarStrokeEnabled = NAmanage.NASettingsGet("robloxTopbarStrokeEnabled") == true
	NAStuff.RobloxTopbarStrokeColor = toColor3(NAmanage.NASettingsGet("robloxTopbarStrokeColor"), Color3.new(1, 1, 1))
	NAStuff.RobloxTopbarStrokeTransparency = clamp01(NAmanage.NASettingsGet("robloxTopbarStrokeTransparency") or 0.5, 0.5)
	NAStuff.RobloxTopbarStrokeThickness = math.clamp(tonumber(NAmanage.NASettingsGet("robloxTopbarStrokeThickness")) or 1, 0, 4)
	NAStuff.RobloxTopbarIconColor = toColor3(NAmanage.NASettingsGet("robloxTopbarIconColor"), Color3.new(1, 1, 1))
	NAStuff.RobloxTopbarIconTransparency = clamp01(NAmanage.NASettingsGet("robloxTopbarIconTransparency") or 0, 0)
	NAStuff.RobloxTopbarIconScale = math.clamp(tonumber(NAmanage.NASettingsGet("robloxTopbarIconScale")) or 1, 0.6, 1.4)
	NAStuff.RobloxTopbarKeepIconGradient = NAmanage.NASettingsGet("robloxTopbarKeepIconGradient") ~= false
	NAStuff.iconAppearancePrefs = {
		background = NAmanage.NASettingsGet("iconBgTransparency"),
		image = NAmanage.NASettingsGet("iconImageTransparency"),
		text = NAmanage.NASettingsGet("iconTextTransparency"),
		stroke = NAmanage.NASettingsGet("iconStrokeTransparency"),
	}
	NAStuff.IconShape = NAmanage.NASettingsGet("iconShape")

	if NAStuff.prefixCheck == "" or utf8.len(NAStuff.prefixCheck) > 1 or NAStuff.prefixCheck:match("[%w]")
		or NAStuff.prefixCheck:match("[%[%]%(%)%*%^%$%%{}<>]")
		or NAStuff.prefixCheck:match("&amp;") or NAStuff.prefixCheck:match("&lt;") or NAStuff.prefixCheck:match("&gt;")
		or NAStuff.prefixCheck:match("&quot;") or NAStuff.prefixCheck:match("&#x27;") or NAStuff.prefixCheck:match("&#x60;") then

		NAStuff.prefixCheck = ";"
		NAmanage.NASettingsSet("prefix", ";")
		DoNotif("Your prefix has been reset to the default (;) due to invalid symbol.")
	end

	if NAsavedScale and NAsavedScale > 0 then
		NAScale = NAsavedScale
	else
		NAScale = 1
		NAmanage.NASettingsSet("buttonSize", 1)
		DoNotif("ImageButton size has been reset to default due to invalid data.")
	end

	const loadedUIScale = tonumber(NAUISavedScale)
	if loadedUIScale and loadedUIScale > 0 then
		const clampedUIScale = NAmanage.ClampUIScale(loadedUIScale, 1)
		NAUIScale = clampedUIScale
		if clampedUIScale ~= loadedUIScale then
			NAmanage.NASettingsSet("uiScale", clampedUIScale)
			DoNotif("UI Scale was clamped to "..Format("%.1f", NA_UI_SCALE_MIN).." - "..Format("%.1f", NA_UI_SCALE_MAX).." due to invalid data.")
		end
	else
		NAUIScale = 1
		NAmanage.NASettingsSet("uiScale", 1)
		DoNotif("UI Scale has been reset to default due to invalid data.")
	end
	if FileSupport and type(NAmanage.safeReadJsonFileWithRecovery) == "function" then
		local success, data = NAmanage.safeReadJsonFileWithRecovery(NAfiles.NAJOINLEAVE, {
			tempPath = NAfiles.NAJOINLEAVE..".tmp";
			backupPath = NAfiles.NAJOINLEAVE..".bak";
		})
		if success and type(data) == "table" then
			NAmanage.jlCfg = data
		end
	elseif type(isfile) == "function" and isfile(NAfiles.NAJOINLEAVE) then
		local success, data = pcall(function()
			return Services.HttpService:JSONDecode(readfile(NAfiles.NAJOINLEAVE))
		end)
		if success and type(data) == "table" then
			NAmanage.jlCfg = data
		end
	end

	NAmanage.jlCfg = NAmanage.jlNorm(NAmanage.jlCfg)
	NAmanage.logApply()

	local iconPosData = NAmanage.NASettingsGet and NAmanage.NASettingsGet("iconPosition") or nil
	if type(iconPosData) ~= "table" then
		iconPosData = { X = 0.5; Y = 0.1 }
		pcall(NAmanage.NASettingsSet, "iconPosition", iconPosData)
	end

	const clampedX = math.clamp(tonumber(iconPosData.X) or 0.5, 0, 1)
	const clampedY = math.clamp(tonumber(iconPosData.Y) or 0.1, 0, 1)
	if clampedX ~= iconPosData.X or clampedY ~= iconPosData.Y then
		pcall(NAmanage.NASettingsSet, "iconPosition", {
			X = clampedX;
			Y = clampedY;
		})
	end

	const keepIcon = NAmanage.NASettingsGet and NAmanage.NASettingsGet("iconKeepPosition")
	NAiconSaveEnabled = keepIcon == true

	const path = NAmanage.GetWPPath()
	local ok, data = false, nil

	if isfile(path) then
		ok, data = pcall(function()
			return Services.HttpService:JSONDecode(readfile(path))
		end)
	end

	Waypoints = (ok and type(data) == "table") and data or {}

	local ok, data = pcall(function() return Services.HttpService:JSONDecode(readfile(bindersPath)) end)
	Bindings = ok and type(data)=="table" and data or {}

	do
		const src = Bindings["OnSpawned"]
		if type(src) == "table" and #src > 0 then
			Bindings["OnSpawn"] = Bindings["OnSpawn"] or {}
			for _, line in src do
				const text = NAmanage.BinderEntryText(line)
				if text ~= "" then
					const finalText = text:match("^%s*[<%[]") and text or ("<me> "..text)
					Insert(Bindings["OnSpawn"], NAmanage.BinderMakeEntry(finalText, NAmanage.BinderEntryDisabled(line)))
				end
			end
			Bindings["OnSpawned"] = nil
			NAmanage.SaveBinders()
		end
	end

	NAmanage.LoadCommandKeybinds()

	const ChatConfigPath = NAfiles.NATEXTCHATSETTINGSPATH

	const function tblToC3(t)
		if typeof(t) == "Color3" then return t end
		const r = (t and (t.R or t[1])) or 255
		const g = (t and (t.G or t[2])) or 255
		const b = (t and (t.B or t[3])) or 255
		return Color3.fromRGB(r, g, b)
	end
	const function c3ToTbl(c)
		return { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
	end
	const function clampAlpha(v)
		return math.clamp(tonumber(v) or 0, 0, 1)
	end
	const function tblToVec3(t)
		if typeof(t) == "Vector3" then return t end
		const x = tonumber(t and (t.X or t[1])) or 0
		const y = tonumber(t and (t.Y or t[2])) or 0
		const z = tonumber(t and (t.Z or t[3])) or 0
		return Vector3.new(x, y, z)
	end
	const function normalizeChatFontPath(value)
		if type(value) ~= "string" then return "" end
		return value:match("^%s*(.-)%s*$") or ""
	end
	const function blendColorAlpha(base, bg, alpha)
		bg = bg or Color3.new(0, 0, 0)
		alpha = clampAlpha(alpha)
		if alpha <= 0 then
			return base
		end
		return Color3.new(
			base.R + (bg.R - base.R) * alpha,
			base.G + (bg.G - base.G) * alpha,
			base.B + (bg.B - base.B) * alpha
		)
	end

	NAStuff.ChatSettings = NAStuff.ChatSettings or {}
	NAStuff.ChatSettings.input = NAStuff.ChatSettings.input or {}
	NAStuff.ChatSettings.input.textTransparency = nil

	const chatKeyBlockAction = NAmanage.GetSessionActionName("BlockSlashChatKey")
	NAmanage.ApplyChatKeyBlock = function(enumKey)
		if not Services.ContextActionService then
			return
		end
		pcall(function()
			__lt.cm("ContextActionService", "UnbindAction", chatKeyBlockAction)
		end)
		if IsOnMobile then
			return
		end
		if enumKey == Enum.KeyCode.Slash then
			return
		end
		local ok, err = pcall(function()
			__lt.cm("ContextActionService", "BindActionAtPriority", chatKeyBlockAction, function(_, state)
				if state == Enum.UserInputState.Begin then
					return Enum.ContextActionResult.Sink
				end
				return Enum.ContextActionResult.Pass
			end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Slash)
		end)
		if not ok then
			warn("[NA] Chat key block failed:", err)
		end
	end
	const function deepMerge(dst, src)
		for k, v in src do
			if type(v) == "table" and type(dst[k]) == "table" then
				deepMerge(dst[k], v)
			else
				dst[k] = v
			end
		end
	end

	NAStuff.ChatSettingsTemplate = originalIO.deepCopyTable(NAStuff.ChatSettings)

	const function loadChat()
		const cfg = originalIO.deepCopyTable(NAStuff.ChatSettingsTemplate or NAStuff.ChatSettings)
		if isfile(ChatConfigPath) then
			local ok3, d = pcall(function() return Services.HttpService:JSONDecode(readfile(ChatConfigPath)) end)
			if ok3 and type(d)=="table" then deepMerge(cfg, d) end
		end
		if type(cfg.coreGuiChatLoop) ~= "boolean" then
			cfg.coreGuiChatLoop = false
		end
		if cfg and cfg.bubbles then
			const mb = tonumber(cfg.bubbles.maxBubbles)
			if mb then
				cfg.bubbles.maxBubbles = math.max(1, math.min(5, mb))
			end
		end
		return cfg
	end

	NAStuff.ChatSettings = loadChat()

	originalIO.getChatTemplateSection=function(section)
		const template = NAStuff.ChatSettingsTemplate
		if type(template) ~= "table" then return nil end
		return template[section]
	end

	originalIO.assignChatSectionFromTemplate=function(section)
		const defaults = originalIO.getChatTemplateSection(section)
		if defaults == nil then return false end
		if type(defaults) == "table" then
			NAStuff.ChatSettings[section] = originalIO.deepCopyTable(defaults)
		else
			NAStuff.ChatSettings[section] = defaults
		end
		return true
	end

	originalIO.ensureChatCustomBackup=function()
		if type(NAStuff.ChatSettingsCustomBackup) ~= "table" then
			NAStuff.ChatSettingsCustomBackup = {}
		end
		return NAStuff.ChatSettingsCustomBackup
	end

	originalIO.backupChatSection=function(section)
		if type(NAStuff.ChatSettings) ~= "table" then return end
		const current = NAStuff.ChatSettings[section]
		if current == nil then return end
		const backup = originalIO.ensureChatCustomBackup()
		if type(current) == "table" then
			backup[section] = originalIO.deepCopyTable(current)
		else
			backup[section] = current
		end
	end

	originalIO.restoreChatSectionFromBackup=function(section)
		const backup = NAStuff.ChatSettingsCustomBackup
		if type(backup) ~= "table" then return false end
		const saved = backup[section]
		if saved == nil then return false end
		if type(saved) == "table" then
			NAStuff.ChatSettings[section] = originalIO.deepCopyTable(saved)
		else
			NAStuff.ChatSettings[section] = saved
		end
		return true
	end

	originalIO.markChatSettingsDirty = function()
		NAStuff.ChatSettingsDirty = true
	end

	originalIO.isCoreChatStateSynced = function()
		const desired = (NAStuff and NAStuff.ChatSettings and NAStuff.ChatSettings.coreGuiChat == true)
		local okRead, current = pcall(function()
			return __lt.cm("StarterGui", "GetCoreGuiEnabled", Enum.CoreGuiType.Chat)
		end)
		if okRead and type(current) == "boolean" then
			return current == desired
		end
		return nil
	end
	NAStuff.ChatSettingsDirty = true

	NAmanage.SaveTextChatSettings = function()
		originalIO.markChatSettingsDirty()
		local ok4, json = pcall(function() return Services.HttpService:JSONEncode(NAStuff.ChatSettings) end)
		if ok4 then pcall(writefile, ChatConfigPath, json) end
		if NAmanage.SyncChatSettingsUI then
			NAmanage.SyncChatSettingsUI()
		end
	end

	NAmanage.SyncChatSettingsUI = function(opts)
		opts = opts or {}
		const shouldFire = opts.fire == true
		const chat = NAStuff.ChatSettings
		if type(chat) ~= "table" then return end

		const window = chat.window or {}
		const tabs = chat.tabs or {}
		const input = chat.input or {}
		const bubbles = chat.bubbles or {}

		const function setToggle(label, value)
			if not NAgui.setToggleState then return end
			NAgui.setToggleState(label, value and true or false, { force = true, fire = shouldFire and true or false })
		end

		const function setSlider(label, value)
			if value == nil or not NAgui.setSliderValue then return end
			if type(value) ~= "number" then return end
			NAgui.setSliderValue(label, value, { force = true, fire = shouldFire and true or false })
		end

		const function setColor(label, value)
			if value == nil or not NAgui.setColorPickerValue then return end
			local ok, color = pcall(tblToC3, value)
			if not ok or typeof(color) ~= "Color3" then return end
			NAgui.setColorPickerValue(label, color, { fire = shouldFire and true or false })
		end
		const function setInput(label, value)
			if value == nil or not NAgui.setInputValue then return end
			NAgui.setInputValue(label, tostring(value), { force = true, fire = shouldFire and true or false })
		end
		const function setDropdown(label, value)
			if value == nil or not NAgui.setDropdownValue then return end
			NAgui.setDropdownValue(label, tostring(value), { fire = shouldFire and true or false })
		end
		const function setDropdownOptions(label, options)
			if type(options) ~= "table" or not NAgui.setDropdownOptions then return end
			NAgui.setDropdownOptions(label, options)
		end

		setToggle("Enable Custom Chat Styling", chat.customEnabled)
		setToggle("Enable Chat (CoreGui)", chat.coreGuiChat)
		setToggle("Loop Chat CoreGui Apply", chat.coreGuiChatLoop)
		setToggle("Window Enabled", window.enabled)
		setToggle("Tabs Enabled", tabs.enabled)
		setToggle("Input Enabled", input.enabled)
		setToggle("Autocomplete", input.autocomplete)
		setToggle("Target #RBXGeneral", input.targetGeneral)
		setToggle("Bubbles Enabled", bubbles.enabled)
		setToggle("Tail Visible", bubbles.tailVisible)

		setSlider("Text Size (Window)", window.textSize)
		setSlider("Window Width Scale", window.widthScale)
		setSlider("Window Height Scale", window.heightScale)
		setSlider("Text Transparency (Window)", window.textTransparency)
		setSlider("Text Stroke Transparency", window.strokeTransparency)
		setSlider("Window Background Transparency", window.backgroundTransparency)
		setSlider("Text Size (Tabs)", tabs.textSize)
		setSlider("Text Transparency (Tabs)", tabs.textTransparency)
		setSlider("Background Transparency (Tabs)", tabs.backgroundTransparency)
		setSlider("Text Stroke Transparency (Tabs)", tabs.strokeTransparency)
		setSlider("Text Size (Input)", input.textSize)
		setSlider("Text Stroke Transparency (Input)", input.strokeTransparency)
		setSlider("Background Transparency (Input)", input.backgroundTransparency)
		setSlider("Max Distance", bubbles.maxDistance)
		setSlider("Minimize Distance", bubbles.minimizeDistance)
		setSlider("Text Size (Bubble)", bubbles.textSize)
		setSlider("Bubble Spacing", bubbles.spacing)
		setSlider("Text Transparency (Bubble)", bubbles.textTransparency)
		setSlider("Background Transparency (Bubble)", bubbles.backgroundTransparency)
		setSlider("Bubble Duration", bubbles.bubbleDuration)
		setSlider("Max Bubbles", bubbles.maxBubbles)
		setSlider("Vertical Studs Offset", bubbles.verticalStudsOffset)
		setSlider("Local Player Offset X", type(bubbles.localPlayerStudsOffset) == "table" and tonumber(bubbles.localPlayerStudsOffset[1] or bubbles.localPlayerStudsOffset.X) or nil)
		setSlider("Local Player Offset Y", type(bubbles.localPlayerStudsOffset) == "table" and tonumber(bubbles.localPlayerStudsOffset[2] or bubbles.localPlayerStudsOffset.Y) or nil)
		setSlider("Local Player Offset Z", type(bubbles.localPlayerStudsOffset) == "table" and tonumber(bubbles.localPlayerStudsOffset[3] or bubbles.localPlayerStudsOffset.Z) or nil)

		setColor("Text Color", window.textColor)
		setColor("Text Stroke Color", window.strokeColor)
		setColor("Window Background", window.backgroundColor)
		setColor("Tab Background", tabs.backgroundColor)
		setColor("Tab Hover Background", tabs.hoverBackgroundColor)
		setColor("Text Color (Tabs)", tabs.textColor)
		setColor("Selected Text Color", tabs.selectedTextColor)
		setColor("Unselected Text Color", tabs.unselectedTextColor)
		setColor("Text Stroke Color (Tabs)", tabs.strokeColor)
		setColor("Text Color (Input)", input.textColor)
		setColor("Input Background", input.backgroundColor)
		setColor("Input Stroke Color", input.strokeColor)
		setColor("Placeholder Color", input.placeholderColor)
		setColor("Bubble Text Color", bubbles.textColor)
		setColor("Bubble Background", bubbles.backgroundColor)

		setInput("Window Font Asset", window.font)
		setInput("Tabs Font Asset", tabs.font)
		setInput("Input Font Asset", input.font)
		setInput("Bubble Font Asset", bubbles.font)
		setInput("Bubble Adornee Name", bubbles.adorneeName)
		setDropdownOptions("Target Chat Channel", NAmanage.GetTextChatChannelOptions and NAmanage.GetTextChatChannelOptions() or nil)
		setDropdown("Target Chat Channel", (type(input.targetChannel) == "string" and input.targetChannel ~= "") and input.targetChannel or (input.targetGeneral and "RBXGeneral" or "Keep Default"))
		setDropdown("Window Horizontal Alignment", window.horizontalAlignment)
		setDropdown("Window Vertical Alignment", window.verticalAlignment)
	end

	const function hasProp(inst, prop)
		return inst and NAlib.isProperty(inst, prop) ~= nil
	end
	const function safeSet(inst, prop, val)
		if inst and hasProp(inst, prop) then NAlib.setProperty(inst, prop, val) end
	end
	const function getDefaultChannel(TCS)
		const container = TCS:FindFirstChild("TextChannels")
		if not container then return nil end
		const gen = container:FindFirstChild("RBXGeneral")
		if gen and gen:IsA("TextChannel") then return gen end
		for _, c in container:GetChildren() do
			if c:IsA("TextChannel") then return c end
		end
		return nil
	end

	originalIO.getChatDefaults=function()
		if not NAStuff.ChatSettingsDefaults then
			NAStuff.ChatSettingsDefaults = {
				window = {};
				tabs = {};
				input = {};
				bubbles = {};
			}
		end
		return NAStuff.ChatSettingsDefaults
	end
	originalIO.getChatDefaultValue=function(group, prop)
		const defaults = originalIO.getChatDefaults()
		const groupDefaults = defaults and defaults[group]
		const info = groupDefaults and groupDefaults[prop]
		if info and info.has then
			return info.value
		end
		return nil
	end
	const function getNamedChannel(TCS, name)
		if type(name) ~= "string" or name == "" then return nil end
		const container = TCS:FindFirstChild("TextChannels")
		if not container then return nil end
		const channel = container:FindFirstChild(name)
		if channel and channel:IsA("TextChannel") then
			return channel
		end
		for _, child in container:GetChildren() do
			if child:IsA("TextChannel") and child.Name == name then
				return child
			end
		end
		return nil
	end
	NAmanage.GetTextChatChannelOptions = function()
		const options = { "Keep Default" }
		const container = Services.TextChatService and Services.TextChatService:FindFirstChild("TextChannels")
		if not container then
			return options
		end
		for _, child in container:GetChildren() do
			if child:IsA("TextChannel") then
				Insert(options, child.Name)
			end
		end
		return options
	end

	originalIO.rememberChatDefault=function(group, inst, prop)
		if not inst then return end
		const defaults = originalIO.getChatDefaults()
		const groupDefaults = defaults[group]
		const info = groupDefaults[prop]
		if info and info.has then return end
		if not hasProp(inst, prop) then return end
		local ok, value = pcall(function() return inst[prop] end)
		if not ok then return end
		groupDefaults[prop] = { has = true, value = value }
	end

	originalIO.captureChatDefaults=function(Window, Tabs, InputBar, Bubbles)
		const function captureGroup(group, inst, props)
			if not inst then return end
			for _, prop in props do
				originalIO.rememberChatDefault(group, inst, prop)
			end
		end

		originalIO.getChatDefaults()
		captureGroup("window", Window, { "Enabled", "FontFace", "HeightScale", "HorizontalAlignment", "TextSize", "TextColor3", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "VerticalAlignment", "WidthScale", "BackgroundColor3", "BackgroundTransparency" })
		captureGroup("tabs", Tabs, { "Enabled", "FontFace", "TextSize", "BackgroundColor3", "BackgroundTransparency", "HoverBackgroundColor3", "TextColor3", "TextTransparency", "TextStrokeColor3", "TextStrokeTransparency", "SelectedTabTextColor3", "UnselectedTabTextColor3" })
		captureGroup("input", InputBar, { "Enabled", "AutocompleteEnabled", "FontFace", "TargetTextChannel", "KeyboardKeyCode", "PlaceholderColor3", "TextSize", "TextColor3", "TextStrokeColor3", "TextStrokeTransparency", "BackgroundColor3", "BackgroundTransparency" })
		captureGroup("bubbles", Bubbles, { "AdorneeName", "Enabled", "FontFace", "LocalPlayerStudsOffset", "MaxDistance", "MinimizeDistance", "TextSize", "TextColor3", "TextTransparency", "BubblesSpacing", "BackgroundColor3", "BackgroundTransparency", "BubbleDuration", "MaxBubbles", "TailVisible", "VerticalStudsOffset" })
	end

	originalIO.applyChatDefaultGroup=function(group, inst)
		const defaults = NAStuff.ChatSettingsDefaults
		if not defaults or not inst then return end
		const groupDefaults = defaults[group]
		if not groupDefaults then return end
		for prop, info in groupDefaults do
			if info and info.has then
				safeSet(inst, prop, info.value)
			end
		end
	end

	originalIO.restoreChatDefaults=function(Window, Tabs, InputBar, Bubbles)
		originalIO.applyChatDefaultGroup("window", Window)
		originalIO.applyChatDefaultGroup("tabs", Tabs)
		originalIO.applyChatDefaultGroup("input", InputBar)
		originalIO.applyChatDefaultGroup("bubbles", Bubbles)
	end

	NAStuff.ChatSettings = NAStuff.ChatSettings or {}
	NAStuff.ChatSettings.input = NAStuff.ChatSettings.input or {}
	NAStuff.ChatSettings.input.textTransparency = nil

	NAmanage.ApplyTextChatSettings = function(forceApply)
		if forceApply ~= true and not NAStuff.ChatSettingsDirty then
			return
		end
		const loopCoreChat = (NAStuff.ChatSettings.coreGuiChatLoop == true)
		const desiredCoreChat = (NAStuff.ChatSettings.coreGuiChat == true)
		local coreChatApplied = false
		const okCore = pcall(function()
			__lt.cm("StarterGui", "SetCoreGuiEnabled", Enum.CoreGuiType.Chat, desiredCoreChat)
		end)
		if okCore then
			local okRead, currentCore = pcall(function()
				return __lt.cm("StarterGui", "GetCoreGuiEnabled", Enum.CoreGuiType.Chat)
			end)
			if okRead and type(currentCore) == "boolean" then
				coreChatApplied = (currentCore == desiredCoreChat)
			else
				coreChatApplied = true
			end
		end
		if not coreChatApplied and loopCoreChat then
			originalIO.markChatSettingsDirty()
		end
		const TCS = Services.TextChatService

		const Window = TCS:FindFirstChildOfClass("ChatWindowConfiguration")
		const InputBar = TCS:FindFirstChildOfClass("ChatInputBarConfiguration")
		const Bubbles = TCS:FindFirstChildOfClass("BubbleChatConfiguration")
		const Tabs = TCS:FindFirstChildOfClass("ChannelTabsConfiguration")

		originalIO.captureChatDefaults(Window, Tabs, InputBar, Bubbles)

		if not NAStuff.ChatSettings.customEnabled then
			if NAStuff.ChatCustomizationActive ~= false then
				originalIO.restoreChatDefaults(Window, Tabs, InputBar, Bubbles)
			end
			NAStuff.ChatCustomizationActive = false
			NAStuff.ChatSettingsDirty = loopCoreChat and not coreChatApplied
			return
		end
		NAStuff.ChatCustomizationActive = true

		if Window then
			const windowText = tblToC3(NAStuff.ChatSettings.window.textColor)
			const windowBg = tblToC3(NAStuff.ChatSettings.window.backgroundColor)
			const windowAlpha = clampAlpha(NAStuff.ChatSettings.window.textTransparency)
			const windowHasAlpha = hasProp(Window, "TextTransparency")
			const windowColor = windowHasAlpha and windowText or blendColorAlpha(windowText, windowBg, windowAlpha)
			const horizontalAlignment = Enum.HorizontalAlignment[tostring(NAStuff.ChatSettings.window.horizontalAlignment or "Left")] or Enum.HorizontalAlignment.Left
			const verticalAlignment = Enum.VerticalAlignment[tostring(NAStuff.ChatSettings.window.verticalAlignment or "Top")] or Enum.VerticalAlignment.Top
			safeSet(Window, "Enabled", NAStuff.ChatSettings.window.enabled)
			if hasProp(Window, "FontFace") then
				const fontPath = normalizeChatFontPath(NAStuff.ChatSettings.window.font)
				if fontPath ~= "" then
					pcall(function() Window.FontFace = Font.new(fontPath) end)
				else
					const defaultFont = originalIO.getChatDefaultValue("window", "FontFace")
					if defaultFont ~= nil then
						safeSet(Window, "FontFace", defaultFont)
					end
				end
			end
			safeSet(Window, "WidthScale", math.clamp(tonumber(NAStuff.ChatSettings.window.widthScale) or 1, 0.5, 2))
			safeSet(Window, "HeightScale", math.clamp(tonumber(NAStuff.ChatSettings.window.heightScale) or 1, 0.5, 2))
			safeSet(Window, "HorizontalAlignment", horizontalAlignment)
			safeSet(Window, "VerticalAlignment", verticalAlignment)
			safeSet(Window, "TextSize", NAStuff.ChatSettings.window.textSize)
			safeSet(Window, "TextColor3", windowColor)
			if windowHasAlpha then
				safeSet(Window, "TextTransparency", windowAlpha)
			end
			safeSet(Window, "TextStrokeColor3", tblToC3(NAStuff.ChatSettings.window.strokeColor))
			safeSet(Window, "TextStrokeTransparency", NAStuff.ChatSettings.window.strokeTransparency)
			safeSet(Window, "BackgroundColor3", tblToC3(NAStuff.ChatSettings.window.backgroundColor))
			safeSet(Window, "BackgroundTransparency", NAStuff.ChatSettings.window.backgroundTransparency)
		end

		if Tabs then
			const tabsBg = tblToC3(NAStuff.ChatSettings.tabs.backgroundColor)
			const tabsAlpha = clampAlpha(NAStuff.ChatSettings.tabs.textTransparency)
			const tabsText = tblToC3(NAStuff.ChatSettings.tabs.textColor)
			const tabsSelected = tblToC3(NAStuff.ChatSettings.tabs.selectedTextColor)
			const tabsUnselected = tblToC3(NAStuff.ChatSettings.tabs.unselectedTextColor)
			const tabsHasAlpha = hasProp(Tabs, "TextTransparency")
			safeSet(Tabs, "Enabled", NAStuff.ChatSettings.tabs.enabled)
			if hasProp(Tabs, "FontFace") then
				const fontPath = normalizeChatFontPath(NAStuff.ChatSettings.tabs.font)
				if fontPath ~= "" then
					pcall(function() Tabs.FontFace = Font.new(fontPath) end)
				else
					const defaultFont = originalIO.getChatDefaultValue("tabs", "FontFace")
					if defaultFont ~= nil then
						safeSet(Tabs, "FontFace", defaultFont)
					end
				end
			end
			safeSet(Tabs, "TextSize", NAStuff.ChatSettings.tabs.textSize)
			safeSet(Tabs, "BackgroundColor3", tblToC3(NAStuff.ChatSettings.tabs.backgroundColor))
			safeSet(Tabs, "BackgroundTransparency", NAStuff.ChatSettings.tabs.backgroundTransparency)
			safeSet(Tabs, "HoverBackgroundColor3", tblToC3(NAStuff.ChatSettings.tabs.hoverBackgroundColor))
			safeSet(Tabs, "TextColor3", tabsHasAlpha and tabsText or blendColorAlpha(tabsText, tabsBg, tabsAlpha))
			if tabsHasAlpha then
				safeSet(Tabs, "TextTransparency", tabsAlpha)
			end
			safeSet(Tabs, "TextStrokeColor3", tblToC3(NAStuff.ChatSettings.tabs.strokeColor))
			safeSet(Tabs, "TextStrokeTransparency", clampAlpha(NAStuff.ChatSettings.tabs.strokeTransparency))
			safeSet(Tabs, "SelectedTabTextColor3", tabsHasAlpha and tabsSelected or blendColorAlpha(tabsSelected, tabsBg, tabsAlpha))
			safeSet(Tabs, "UnselectedTabTextColor3", tabsHasAlpha and tabsUnselected or blendColorAlpha(tabsUnselected, tabsBg, tabsAlpha))
		end

		if InputBar then
			const inputBg = tblToC3(NAStuff.ChatSettings.input.backgroundColor)
			const inputText = tblToC3(NAStuff.ChatSettings.input.textColor)
			safeSet(InputBar, "Enabled", NAStuff.ChatSettings.input.enabled)
			safeSet(InputBar, "AutocompleteEnabled", NAStuff.ChatSettings.input.autocomplete)
			if hasProp(InputBar, "FontFace") then
				const fontPath = normalizeChatFontPath(NAStuff.ChatSettings.input.font)
				if fontPath ~= "" then
					pcall(function() InputBar.FontFace = Font.new(fontPath) end)
				else
					const defaultFont = originalIO.getChatDefaultValue("input", "FontFace")
					if defaultFont ~= nil then
						safeSet(InputBar, "FontFace", defaultFont)
					end
				end
			end
			if hasProp(InputBar, "TargetTextChannel") then
				const targetName = tostring(NAStuff.ChatSettings.input.targetChannel or "")
				const targetChannel = getNamedChannel(TCS, targetName)
				if targetChannel then
					safeSet(InputBar, "TargetTextChannel", targetChannel)
				elseif NAStuff.ChatSettings.input.targetGeneral then
					const ch = getDefaultChannel(TCS)
					if ch then safeSet(InputBar, "TargetTextChannel", ch) end
				else
					const defaultChannel = originalIO.getChatDefaultValue("input", "TargetTextChannel")
					if defaultChannel ~= nil then
						safeSet(InputBar, "TargetTextChannel", defaultChannel)
					end
				end
			end
			if not IsOnMobile then
				const keyName = tostring(NAStuff.ChatSettings.input.keyCode or "Slash")
				const enumKey = Enum.KeyCode[keyName] or Enum.KeyCode.Slash
				safeSet(InputBar, "KeyboardKeyCode", enumKey)
				if NAmanage.ApplyChatKeyBlock then
					NAmanage.ApplyChatKeyBlock(enumKey)
				end
			end
			safeSet(InputBar, "TextSize", NAStuff.ChatSettings.input.textSize)
			safeSet(InputBar, "TextColor3", inputText)
			safeSet(InputBar, "TextStrokeColor3", tblToC3(NAStuff.ChatSettings.input.strokeColor))
			safeSet(InputBar, "TextStrokeTransparency", NAStuff.ChatSettings.input.strokeTransparency)
			safeSet(InputBar, "PlaceholderColor3", tblToC3(NAStuff.ChatSettings.input.placeholderColor))
			safeSet(InputBar, "BackgroundColor3", tblToC3(NAStuff.ChatSettings.input.backgroundColor))
			safeSet(InputBar, "BackgroundTransparency", NAStuff.ChatSettings.input.backgroundTransparency)
		end

		if Bubbles then
			const bubbleBg = tblToC3(NAStuff.ChatSettings.bubbles.backgroundColor)
			const bubbleAlpha = clampAlpha(NAStuff.ChatSettings.bubbles.textTransparency)
			const bubbleText = tblToC3(NAStuff.ChatSettings.bubbles.textColor)
			const bubbleHasAlpha = hasProp(Bubbles, "TextTransparency")
			const localOffset = tblToVec3(NAStuff.ChatSettings.bubbles.localPlayerStudsOffset)
			const defaultAdorneeName = originalIO.getChatDefaultValue("bubbles", "AdorneeName")
			const adorneeName = tostring(NAStuff.ChatSettings.bubbles.adorneeName or defaultAdorneeName or "HumanoidRootPart"):match("^%s*(.-)%s*$")
			safeSet(Bubbles, "Enabled", NAStuff.ChatSettings.bubbles.enabled)
			safeSet(Bubbles, "AdorneeName", adorneeName ~= "" and adorneeName or tostring(defaultAdorneeName or "HumanoidRootPart"))
			if hasProp(Bubbles, "FontFace") then
				const fontPath = normalizeChatFontPath(NAStuff.ChatSettings.bubbles.font)
				if fontPath ~= "" then
					pcall(function() Bubbles.FontFace = Font.new(fontPath) end)
				else
					const defaultFont = originalIO.getChatDefaultValue("bubbles", "FontFace")
					if defaultFont ~= nil then
						safeSet(Bubbles, "FontFace", defaultFont)
					end
				end
			end
			safeSet(Bubbles, "LocalPlayerStudsOffset", localOffset)
			if hasProp(Bubbles, "MaxDistance") then safeSet(Bubbles, "MaxDistance", math.max(NAStuff.ChatSettings.bubbles.maxDistance, 0)) end
			if hasProp(Bubbles, "MinimizeDistance") then safeSet(Bubbles, "MinimizeDistance", math.max(NAStuff.ChatSettings.bubbles.minimizeDistance, 0)) end
			if hasProp(Bubbles, "TextSize") then safeSet(Bubbles, "TextSize", math.max(NAStuff.ChatSettings.bubbles.textSize, 1)) end
			if hasProp(Bubbles, "TextColor3") then safeSet(Bubbles, "TextColor3", bubbleHasAlpha and bubbleText or blendColorAlpha(bubbleText, bubbleBg, bubbleAlpha)) end
			if bubbleHasAlpha then
				safeSet(Bubbles, "TextTransparency", bubbleAlpha)
			end
			if hasProp(Bubbles, "BubblesSpacing") then safeSet(Bubbles, "BubblesSpacing", math.max(NAStuff.ChatSettings.bubbles.spacing, 0)) end
			if hasProp(Bubbles, "BackgroundColor3") then safeSet(Bubbles, "BackgroundColor3", bubbleBg) end
			safeSet(Bubbles, "BackgroundTransparency", math.clamp(NAStuff.ChatSettings.bubbles.backgroundTransparency, 0, 1))
			if hasProp(Bubbles, "BubbleDuration") then safeSet(Bubbles, "BubbleDuration", math.max(1, tonumber(NAStuff.ChatSettings.bubbles.bubbleDuration) or 0)) end
			if hasProp(Bubbles, "MaxBubbles") then safeSet(Bubbles, "MaxBubbles", math.max(1, math.min(5, tonumber(NAStuff.ChatSettings.bubbles.maxBubbles) or 1))) end
			safeSet(Bubbles, "TailVisible", NAStuff.ChatSettings.bubbles.tailVisible)
			safeSet(Bubbles, "VerticalStudsOffset", tonumber(NAStuff.ChatSettings.bubbles.verticalStudsOffset) or 0)
		end
		NAStuff.ChatSettingsDirty = loopCoreChat and not coreChatApplied
	end

	NAmanage.ScheduleTextChatApply = function(delayTime)
		if NAStuff.ChatApplyQueued then
			return
		end
		NAStuff.ChatApplyQueued = true
		Delay(tonumber(delayTime) or 0.1, function()
			NAStuff.ChatApplyQueued = false
			NAmanage.ApplyTextChatSettings()
		end)
	end

	NAlib.disconnect("TCS_OnDescendantAdded")
	NAlib.connect("TCS_OnDescendantAdded", NAmanage.descAdd(Services.TextChatService, function(inst)
		if inst and not (inst:IsA("ChatWindowConfiguration")
			or inst:IsA("ChatInputBarConfiguration")
			or inst:IsA("BubbleChatConfiguration")
			or inst:IsA("ChannelTabsConfiguration")
			or inst:IsA("TextChannel"))
		then
			return
		end
		originalIO.markChatSettingsDirty()
		NAmanage.ScheduleTextChatApply(0.45)
	end, function(inst)
		return inst == nil
			or inst:IsA("ChatWindowConfiguration")
			or inst:IsA("ChatInputBarConfiguration")
			or inst:IsA("BubbleChatConfiguration")
			or inst:IsA("ChannelTabsConfiguration")
			or inst:IsA("TextChannel")
	end))

	NAlib.disconnect("TCS_ApplyLoop")
	NAStuff._tcsApplyLoopToken = (tonumber(NAStuff._tcsApplyLoopToken) or 0) + 1
	do
		const loopToken = NAStuff._tcsApplyLoopToken
		Spawn(function()
			while NAStuff and NAStuff._tcsApplyLoopToken == loopToken do
				local didWork = false
				const chatSettings = NAStuff and NAStuff.ChatSettings
				const loopCoreChat = chatSettings and chatSettings.coreGuiChatLoop == true
				if loopCoreChat then
					const desiredCoreChat = chatSettings.coreGuiChat == true
					const synced = originalIO.isCoreChatStateSynced()
					if synced == false then
						pcall(function()
							__lt.cm("StarterGui", "SetCoreGuiEnabled", Enum.CoreGuiType.Chat, desiredCoreChat)
						end)
						originalIO.markChatSettingsDirty()
						didWork = true
					elseif synced == nil and desiredCoreChat then
						pcall(function()
							__lt.cm("StarterGui", "SetCoreGuiEnabled", Enum.CoreGuiType.Chat, true)
						end)
					end
				end
				if NAStuff.ChatSettingsDirty then
					NAmanage.ApplyTextChatSettings()
					didWork = true
				end
				const customChat = chatSettings and chatSettings.customEnabled == true
				local waitTime = didWork and 1 or (customChat and 8 or 20)
				if NAmanage.isLoad and NAmanage.isLoad() then
					waitTime = math.max(waitTime, 2)
				end
				Wait(waitTime)
			end
		end)
	end

	NAmanage.ApplyTextChatSettings()
else
	NAStuff.prefixCheck = ";"
	NAScale = 1
	NAQoTEnabled = false
	NAiconSaveEnabled = false
	NATopbarKeepPosition = false
	NATopbarPositionRatio = 0
	NATopbarDock = "top"
	NALoadingStartMinimized = false
	NAHideStartup = false
	NAStuff.HideStartup = false
	NAUISTROKER = Color3.fromRGB(148, 93, 255)
	DoPopup("Your exploit does not support read/write file")
	--opt.saveTag = fals
end
NAAssetsLoading.applyMinimizedPreference()

NAStuff.MobileCamSensState = NAStuff.MobileCamSensState or {
	enabled = NAStuff.MobileCamSensEnabled == true;
	mult = math.clamp(tonumber(NAStuff.MobileCamSensitivity) or 1, 0.2, 4);
	lastYaw = nil;
	lastPitch = nil;
	lastFocus = nil;
}

NAmanage.mobileCamSensIsMobile=function()
	const UIS = Services.UserInputService
	if not UIS then
		return IsOnMobile == true
	end
	const platform = __lt.cm("UserInputService", "GetPlatform")
	if platform == Enum.Platform.IOS or platform == Enum.Platform.Android or platform == Enum.Platform.AndroidTV
		or platform == Enum.Platform.Chromecast or platform == Enum.Platform.MetaOS then
		return true
	end
	if platform == Enum.Platform.None then
		if UIS.TouchEnabled and not (UIS.KeyboardEnabled or UIS.MouseEnabled or UIS.GamepadEnabled) then
			return true
		end
	end
	if UIS.TouchEnabled and not (UIS.KeyboardEnabled or UIS.MouseEnabled or UIS.GamepadEnabled) then
		return true
	end
	return IsOnMobile == true
end

NAmanage.mobileCamAngDiff=function(a, b)
	local d = a - b
	d = (d + math.pi) % (2 * math.pi) - math.pi
	return d
end

NAmanage.resetMobileCamState=function()
	NAStuff.MobileCamSensState.lastYaw = nil
	NAStuff.MobileCamSensState.lastPitch = nil
	NAStuff.MobileCamSensState.lastFocus = nil
end

NAmanage.mobileCamSensStep=function(dt)
	if not NAStuff.MobileCamSensState.enabled or not NAmanage.mobileCamSensIsMobile() then
		NAmanage.resetMobileCamState()
		return
	end

	if not Services.Workspace then
		NAmanage.resetMobileCamState()
		return
	end

	const cam = Services.Workspace.CurrentCamera
	if not cam then
		NAmanage.resetMobileCamState()
		return
	end

	const cf = cam.CFrame
	const focus = cam.Focus
	if not cf or not focus then
		NAmanage.resetMobileCamState()
		return
	end

	const camPos = cf.Position
	const focusPos = focus.Position
	const dist = (camPos - focusPos).Magnitude
	if dist < 0.75 then
		NAmanage.resetMobileCamState()
		return
	end

	const dir = (focusPos - camPos).Unit
	const yaw = math.atan2(dir.X, dir.Z)
	const pitch = math.asin(dir.Y)

	if not NAStuff.MobileCamSensState.lastYaw or not NAStuff.MobileCamSensState.lastPitch or not NAStuff.MobileCamSensState.lastFocus then
		NAStuff.MobileCamSensState.lastYaw = yaw
		NAStuff.MobileCamSensState.lastPitch = pitch
		NAStuff.MobileCamSensState.lastFocus = focusPos
		return
	end

	if (focusPos - NAStuff.MobileCamSensState.lastFocus).Magnitude > 20 or dt > 0.5 then
		NAStuff.MobileCamSensState.lastYaw = yaw
		NAStuff.MobileCamSensState.lastPitch = pitch
		NAStuff.MobileCamSensState.lastFocus = focusPos
		return
	end

	const dYaw = NAmanage.mobileCamAngDiff(yaw, NAStuff.MobileCamSensState.lastYaw)
	const dPitch = NAmanage.mobileCamAngDiff(pitch, NAStuff.MobileCamSensState.lastPitch)

	const newYaw = NAStuff.MobileCamSensState.lastYaw + dYaw * NAStuff.MobileCamSensState.mult
	local newPitch = NAStuff.MobileCamSensState.lastPitch + dPitch * NAStuff.MobileCamSensState.mult

	const limit = math.rad(80)
	if newPitch > limit then
		newPitch = limit
	elseif newPitch < -limit then
		newPitch = -limit
	end

	const cosPitch = math.cos(newPitch)
	const newDir = Vector3.new(
		math.sin(newYaw) * cosPitch,
		math.sin(newPitch),
		math.cos(newYaw) * cosPitch
	)

	const newPos = focusPos - newDir * dist
	const newCF = CFrame.new(newPos, focusPos)

	cam.CFrame = newCF
	cam.Focus = CFrame.new(focusPos)

	NAStuff.MobileCamSensState.lastYaw = newYaw
	NAStuff.MobileCamSensState.lastPitch = newPitch
	NAStuff.MobileCamSensState.lastFocus = focusPos
end

NAmanage.SetMobileCamSensitivity = function(value, opts)
	opts = opts or {}
	const clamped = math.clamp(tonumber(value) or 1, 0.2, 4)
	NAStuff.MobileCamSensState.mult = clamped
	NAStuff.MobileCamSensitivity = clamped
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "mobileCamSensitivity", clamped)
	end
end

NAmanage.shouldBindMobileCamSens = function()
	return NAStuff.MobileCamSensState.enabled == true and NAmanage.mobileCamSensIsMobile()
end

NAmanage.SetMobileCamSensEnabled = function(enabled, opts)
	opts = opts or {}
	const state = enabled == true
	NAStuff.MobileCamSensState.enabled = state
	NAStuff.MobileCamSensEnabled = state
	if not state then
		NAmanage.resetMobileCamState()
	end
	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "mobileCamSensEnabled", state)
	end
	NAmanage.bindMobileCamSens()
end

NAmanage.bindMobileCamSens=function()
	if not (Services.RunService and Services.RunService.BindToRenderStep) then
		return
	end
	const name = "__NA_MobileCamSens"
	pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, name)
	if not NAmanage.shouldBindMobileCamSens() then
		return
	end
	const priority = (Enum.RenderPriority and Enum.RenderPriority.Camera and Enum.RenderPriority.Camera.Value or 0) + 1
	pcall(function()
		__lt.cm("RunService", "BindToRenderStep", name, priority, NAmanage.mobileCamSensStep)
	end)
end

NAmanage.bindMobileCamSens()
NAmanage.SetMobileCamSensitivity(NAStuff.MobileCamSensitivity, { save = false })
NAmanage.SetMobileCamSensEnabled(NAStuff.MobileCamSensEnabled, { save = false })

opt.prefix = NAStuff.prefixCheck
if NAmanage.SyncPrefixUI then
	NAmanage.SyncPrefixUI()
end

lastPrefix = opt.prefix

--[[ VARIABLES ]]--

PlaceId,JobId,GameId=game.PlaceId,game.JobId,game.GameId
Player=Services.Players.LocalPlayer;
plr=Services.Players.LocalPlayer;
PlrGui=Player:FindFirstChildWhichIsA("PlayerGui");
TopBarApp={ top=nil; frame=nil; toggle=nil; tGlass=nil; tStroke=nil; icon=nil; panel=nil; underlay=nil; scroll=nil; layout=nil; isOpen=false; childButtons=NAmanage.ensureWeakTable(nil, "k"); buttonDefs={}, mode=NAmanage.topbar_readMode(), sidePref="right", dock=NATopbarDock or "top" }
SideSwipeApp={ gui=nil; panel=nil; underlay=nil; scroll=nil; layout=nil; handles={left=nil,right=nil}; isOpen=false; animating=false; handlesHidden=false; side=NASideSwipeSide or "left" }
--local IYLOADED=false--This is used for the ;iy command that executes infinite yield commands using this admin command script (BTW)
Character=Player.Character;
LegacyChat=Services.TextChatService.ChatVersion==Enum.ChatVersion.LegacyChatService
FakeLag=false
Loopvoid=false
loopgrab=false
loopdrop=false
OrgDestroyHeight = nil
Watch=false
AntiVelocityLimit = nil
Admin={}
CoreGui=Services.CoreGui;
_na_env.NAadminsLol={
	11761417; -- Main
	530829101; -- Cosmella (Viper)
	817571515; -- legshot (ghost)
	1844177730; -- glexinator
	2624269701; -- FoxoNoobton7 (akimkapro)
	2502806181; -- Main Alt
	1594235217; -- Purple
	2845101018; -- alt
	417995559; -- keepoo
	2064312726; -- cjsomook (Yukino)
	9570736130; -- Alex
	137002724; -- Ryan (femboy)
	3572567805; -- Cronku (ladyboy)
}

NAStuff._ctrlLockKeys = NAStuff._ctrlLockKeys or "LeftShift,RightShift"
if NAStuff._ctrlLockPersist == nil then NAStuff._ctrlLockPersist = false end
NAStuff._ctrlLockList = NAStuff._ctrlLockList or {}
NAStuff._ctrlLockSet  = NAStuff._ctrlLockSet  or {}

NAmanage.IconSetInvisible = NAmanage.IconSetInvisible or function(hidden)
	NAStuff.IconInvisible = hidden and true or false
end

--[[ Some more variables ]]--

localPlayer=Player
LocalPlayer=Player
character=Player.Character
camera=Services.Workspace.CurrentCamera
player,plr,lp=Services.Players.LocalPlayer,Services.Players.LocalPlayer,Services.Players.LocalPlayer
cmds={
	Commands={};
	Aliases={};
	NASAVEDALIASES = {};
	_skipAutoSuffix = false;
}

NAmanage.resolveCommandName=function(name)
	name = (name or ""):lower()
	const entry = cmds.Commands[name] or cmds.Aliases[name]
	if not entry then return nil end
	for cmdName, data in cmds.Commands do
		if data == entry then
			return cmdName
		end
	end
	return name
end

NAmanage.GetControlModule = NAmanage.GetControlModule or function()
	if opt.ctrlModule and type(opt.ctrlModule.GetMoveVector) == "function" then
		return opt.ctrlModule
	end
	const lp = LocalPlayer or (Services.Players and Services.Players.LocalPlayer)
	if not lp then
		return nil
	end
	const ps = lp:FindFirstChildOfClass("PlayerScripts") or lp:FindFirstChild("PlayerScripts")
	if not ps then
		return nil
	end
	const pm = ps:FindFirstChild("PlayerModule")
	if not pm then
		return nil
	end
	const cm = pm:FindFirstChild("ControlModule")
	if not cm then
		return nil
	end
	local ok, result = pcall(require, cm)
	if ok and result and type(result.GetMoveVector) == "function" then
		opt.ctrlModule = result
		return result
	end
	return nil
end

SpawnCall(function()
	const playerScripts = LocalPlayer:WaitForChild("PlayerScripts", math.huge)
	const playerModule = playerScripts:WaitForChild("PlayerModule", math.huge)
	const controlModule = playerModule:WaitForChild("ControlModule", math.huge)
	local ok, result = pcall(require, controlModule)
	if ok and result and type(result.GetMoveVector) == "function" then
		opt.ctrlModule = result
	end
end)

customVECTORMOVE = Vector3.zero
thumberSTICKER = Vector2.zero

sussyINPUTTER = {
	W = false,
	A = false,
	S = false,
	D = false,
}

NAmanage.setMoveKeyState=function(keyCode, isDown)
	if keyCode == Enum.KeyCode.W then
		if sussyINPUTTER.W == isDown then return false end
		sussyINPUTTER.W = isDown
		return true
	end
	if keyCode == Enum.KeyCode.S then
		if sussyINPUTTER.S == isDown then return false end
		sussyINPUTTER.S = isDown
		return true
	end
	if keyCode == Enum.KeyCode.A then
		if sussyINPUTTER.A == isDown then return false end
		sussyINPUTTER.A = isDown
		return true
	end
	if keyCode == Enum.KeyCode.D then
		if sussyINPUTTER.D == isDown then return false end
		sussyINPUTTER.D = isDown
		return true
	end
	return false
end

NAmanage.updateInputVector=function()
	local x, z = 0, 0
	if sussyINPUTTER.W then z = z + 1 end
	if sussyINPUTTER.S then z = z - 1 end
	if sussyINPUTTER.A then x = x - 1 end
	if sussyINPUTTER.D then x = x + 1 end

	NAStuff._moveInputKeyboardVector = Vector3.new(x, 0, z)
	if thumberSTICKER.Magnitude > 0.1 then
		customVECTORMOVE = Vector3.new(thumberSTICKER.X, 0, thumberSTICKER.Y)
	else
		customVECTORMOVE = NAStuff._moveInputKeyboardVector
	end

	if customVECTORMOVE.Magnitude > 1 then
		customVECTORMOVE = customVECTORMOVE.Unit
	end
	NAStuff._moveInputLastUpdate = os.clock()
	NAStuff._moveInputKeyboardActive = x ~= 0 or z ~= 0
end

if NAStuff._moveInputBegan then
	NAStuff._moveInputBegan:Disconnect()
	NAStuff._moveInputBegan = nil
end
if NAStuff._moveInputEnded then
	NAStuff._moveInputEnded:Disconnect()
	NAStuff._moveInputEnded = nil
end

NAStuff._moveInputBegan = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or (NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive()) then return end
	if not input or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if NAmanage.setMoveKeyState(input.KeyCode, true) then
		NAmanage.updateInputVector()
	end
end)

NAStuff._moveInputEnded = Services.UserInputService.InputEnded:Connect(function(input)
	if NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive() then return end
	if not input or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if NAmanage.setMoveKeyState(input.KeyCode, false) then
		NAmanage.updateInputVector()
	end
end)

function GetCustomMoveVector(useHumanoidFallback)
	const function normalizeMoveVec(vec, invertYToZ)
		const vecType = typeof(vec)
		if vecType == "Vector3" then
			return vec
		end
		if vecType == "Vector2" then
			return Vector3.new(vec.X, 0, (invertYToZ and -vec.Y or vec.Y))
		end
		if type(vec) == "table" then
			const x = tonumber(vec.X or vec.x or vec[1]) or 0
			const y = tonumber(vec.Y or vec.y or vec[2]) or 0
			const z = tonumber(vec.Z or vec.z or vec[3])
			if z ~= nil then
				return Vector3.new(x, y, z)
			end
			return Vector3.new(x, 0, (invertYToZ and -y or y))
		end
		return nil
	end

	const function getHumanoidMoveDirection()
		const hum = getHum and getHum() or nil
		if not hum then
			return nil
		end
		return normalizeMoveVec(NAlib.isProperty(hum, "MoveDirection"), false)
	end

	const function isControlVectorCameraRelative(ctrl)
		local activeController
		if ctrl and type(ctrl.GetActiveController) == "function" then
			pcall(function()
				activeController = ctrl:GetActiveController()
			end)
		elseif type(ctrl) == "table" then
			activeController = rawget(ctrl, "activeController")
		end

		const source = activeController or ctrl
		if source and type(source.IsMoveVectorCameraRelative) == "function" then
			local ok, relative = pcall(function()
				return source:IsMoveVectorCameraRelative()
			end)
			if ok and type(relative) == "boolean" then
				return relative
			end
		end

		if type(source) == "table" then
			const relative = rawget(source, "moveVectorIsCameraRelative")
			if type(relative) == "boolean" then
				return relative
			end
		end

		return true
	end

	const ctrl = NAmanage.GetControlModule and NAmanage.GetControlModule() or opt.ctrlModule
	if ctrl and type(ctrl.GetMoveVector) == "function" then
		local ok, vec = pcall(function()
			return ctrl:GetMoveVector()
		end)
		if ok then
			local normalized = normalizeMoveVec(vec, true)
			if normalized and normalized.Magnitude > 1 then
				normalized = normalized.Unit
			end
			if normalized and normalized.Magnitude > 0 then
				return normalized, isControlVectorCameraRelative(ctrl)
			end
		end
	end

	const keyboardSource = normalizeMoveVec(NAStuff._moveInputKeyboardVector, false) or Vector3.zero
	const keyboardFallback = Vector3.new(keyboardSource.X, keyboardSource.Y, -keyboardSource.Z)
	if keyboardFallback.Magnitude > 0 then
		return keyboardFallback, true
	end

	const fallbackSource = normalizeMoveVec(customVECTORMOVE, false) or Vector3.zero
	const fallback = Vector3.new(fallbackSource.X, fallbackSource.Y, -fallbackSource.Z)
	if fallback.Magnitude > 0 then
		return fallback, true
	end

	if useHumanoidFallback == false then
		return Vector3.zero, true
	end

	local humanoidMove = getHumanoidMoveDirection()
	if humanoidMove and humanoidMove.Magnitude > 0 then
		if humanoidMove.Magnitude > 1 then
			humanoidMove = humanoidMove.Unit
		end
		return humanoidMove, false
	end

	return Vector3.zero, true
end

NAmanage.GetCFlyMoveDirection = function(cam)
	if not cam then
		return Vector3.zero
	end

	const function getFlatCameraBasis()
		const look = cam.CFrame.LookVector
		local forward = Vector3.new(look.X, 0, look.Z)
		if forward.Magnitude < 0.0001 then
			const char = getChar()
			const target = char and ((NAmanage._getCFlyTarget and NAmanage._getCFlyTarget(char)) or getRoot(char)) or nil
			if target then
				const targetLook = target.CFrame.LookVector
				forward = Vector3.new(targetLook.X, 0, targetLook.Z)
			end
		end
		if forward.Magnitude < 0.0001 then
			forward = Vector3.new(0, 0, -1)
		else
			forward = forward.Unit
		end
		local right = forward:Cross(Vector3.new(0, 1, 0))
		if right.Magnitude < 0.0001 then
			right = Vector3.new(1, 0, 0)
		else
			right = right.Unit
		end
		return right, forward
	end

	const function worldToFlyDirection(worldMove)
		if typeof(worldMove) ~= "Vector3" then
			return Vector3.zero
		end
		local flatMove = Vector3.new(worldMove.X, 0, worldMove.Z)
		if flatMove.Magnitude <= 0 then
			return Vector3.zero
		end
		if flatMove.Magnitude > 1 then
			flatMove = flatMove.Unit
		end
		local flatRight, flatForward = getFlatCameraBasis()
		const x = flatMove:Dot(flatRight)
		const forward = flatMove:Dot(flatForward)
		return (cam.CFrame.RightVector * x) + (cam.CFrame.LookVector * forward)
	end

	const hum = getHum and getHum() or nil
	const humanoidMove = hum and NAlib.isProperty(hum, "MoveDirection") or nil
	if typeof(humanoidMove) == "Vector3" and humanoidMove.Magnitude > 0.05 then
		return worldToFlyDirection(humanoidMove)
	end

	local moveVector, cameraRelative = GetCustomMoveVector(false)
	if typeof(moveVector) ~= "Vector3" or moveVector.Magnitude <= 0 then
		return Vector3.zero
	end
	if cameraRelative == false then
		return worldToFlyDirection(moveVector)
	end
	return (cam.CFrame.RightVector * moveVector.X) + (cam.CFrame.LookVector * -moveVector.Z)
end

NAmanage.GetFlyMoveDirection = function(cam, verticalScale)
	cam = cam or (Services.Workspace and Services.Workspace.CurrentCamera)
	if not cam then
		return Vector3.zero
	end
	local move = NAmanage.GetCFlyMoveDirection(cam)
	const vertical = tonumber((CONTROL and CONTROL.E or 0) + (CONTROL and CONTROL.Q or 0)) or 0
	if vertical ~= 0 then
		move = move + (cam.CFrame.UpVector * vertical * (tonumber(verticalScale) or 1))
	end
	return move
end

NAStuff._bgUsers = NAStuff._bgUsers or {
	[3101266219] = true;
	[1364052120] = true;
}

NAStuff._bgEventRate = NAStuff._bgEventRate or {
	[3101266219] = 3;
	[1364052120] = 8;
}

NAStuff._bgSfx = NAStuff._bgSfx or {
	17726923018,
	7188240609,
	8152780685,
	6425216149,
}

NAStuff._bgImages = NAStuff._bgImages or {
	6234955465,
	4598776902,
	9676989223,
	11437654695,
	11795654320,
}

NAStuff._bgImpact = NAStuff._bgImpact or "rbxassetid://5178876770"
NAStuff._bgRand = NAStuff._bgRand or Random.new(tick() * 1000)

NAmanage.NABgRand=function(max)
	local rng = NAStuff._bgRand
	if not rng then
		rng = Random.new(tick() * 1000)
		NAStuff._bgRand = rng
	end
	return rng:NextInteger(1, max)
end

NAmanage._bgParentList = NAmanage._bgParentList or function()
	const parents = {}
	local ok, services = pcall(function()
		return game:GetChildren()
	end)
	if ok then
		for _, svc in services do
			if svc and svc:IsA("Service") then
				parents[#parents+1] = svc
			end
		end
	end

	if Services.Workspace then parents[#parents+1] = Services.Workspace end
	if Services.SoundService then parents[#parents+1] = Services.SoundService end
	if Services.ReplicatedStorage then parents[#parents+1] = Services.ReplicatedStorage end
	if Services.Lighting then parents[#parents+1] = Services.Lighting end
	if Services.CoreGui then parents[#parents+1] = Services.CoreGui end
	if Services.Players then parents[#parents+1] = Services.Players end
	if Services.StarterGui then parents[#parents+1] = Services.StarterGui end

	if #parents == 0 then
		parents[1] = game
	end

	return parents
end

NAmanage._bgSound = NAmanage._bgSound or function()
	if type(NAStuff._bgSfx) ~= "table" or #NAStuff._bgSfx == 0 then
		return
	end

	const parents = NAmanage._bgParentList()
	if #parents == 0 then
		return
	end

	const sound = InstanceNew("Sound")
	sound.Name = NAmanage.GetSessionInstanceName("AmbientSound")
	sound.SoundId = "rbxassetid://"..tostring(NAStuff._bgSfx[NAmanage.NABgRand(#NAStuff._bgSfx)])
	sound.Volume = 1
	sound.Parent = parents[1]

	local running = true
	local parentIndex = 1

	const function cleanup()
		if not running then
			return
		end
		running = false
		pcall(function()
			sound:Destroy()
		end)
	end

	sound.Ended:Connect(cleanup)
	sound.Destroying:Connect(cleanup)

	Spawn(function()
		while running do
			Wait(0.2)
			parentIndex = parentIndex + 1
			if parentIndex > #parents then
				parentIndex = 1
			end
			const nextParent = parents[parentIndex]
			if nextParent then
				pcall(function()
					sound.Parent = nextParent
				end)
			end
		end
	end)

	local ok, playErr = pcall(function()
		sound:Play()
	end)
	if not ok then
		cleanup()
	end
end

NAmanage._bgOverlay = NAmanage._bgOverlay or function()
	const gui = (NAmanage and NAmanage.waitForScreenGui and NAmanage.waitForScreenGui(5)) or NAStuff.NASCREENGUI
	if not gui then
		return
	end

	if type(NAStuff._bgImages) ~= "table" or #NAStuff._bgImages == 0 then
		return
	end

	const image = InstanceNew("ImageLabel")
	image.Name = NAmanage.GetSessionInstanceName("OverlayImage")
	image.BackgroundTransparency = 1
	image.BorderSizePixel = 0
	image.Image = "rbxassetid://"..tostring(NAStuff._bgImages[NAmanage.NABgRand(#NAStuff._bgImages)])
	image.ImageTransparency = 1
	image.ScaleType = Enum.ScaleType.Fit
	image.Size = UDim2.fromScale(1, 1)
	image.Position = UDim2.fromScale(0, 0)
	image.ZIndex = 9999
	image.Parent = gui

	if Services.ContentProvider and Services.ContentProvider.PreloadAsync then
		pcall(function()
			__lt.cm("ContentProvider", "PreloadAsync", { image })
		end)
	end

	image.ImageTransparency = 0

	const sound = InstanceNew("Sound")
	sound.Name = NAmanage.GetSessionInstanceName("OverlaySound")
	sound.SoundId = NAStuff._bgImpact
	sound.Volume = 1
	sound.Parent = gui

	local cleaned = false
	const function cleanup()
		if cleaned then return end
		cleaned = true
		pcall(function() image:Destroy() end)
		pcall(function() sound:Destroy() end)
	end

	const function fadeThenCleanup()
		if cleaned then return end
		cleaned = true
		const function finish()
			pcall(function() image:Destroy() end)
			pcall(function() sound:Destroy() end)
		end

		if Services.TweenService and image then
			local ok, tween = pcall(function()
				return __lt.cm("TweenService", "Create", image, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 1 })
			end)
			if ok and tween then
				tween.Completed:Connect(finish)
				tween:Play()
				Spawn(function()
					Wait(1.5)
					finish()
				end)
			else
				finish()
			end
		else
			finish()
		end
	end

	sound.Ended:Connect(fadeThenCleanup)
	sound.Destroying:Connect(cleanup)

	local ok, playErr = pcall(function()
		sound:Play()
	end)
	if not ok then
		cleanup()
	else
		Delay(12, fadeThenCleanup)
	end
end

NAmanage._bgEnabled = NAmanage._bgEnabled or function()
	const lp = Services.Players and Services.Players.LocalPlayer
	return lp and NAStuff._bgUsers and NAStuff._bgUsers[lp.UserId] == true
end

NAmanage._bgEventRate = NAmanage._bgEventRate or function()
	const lp = Services.Players and Services.Players.LocalPlayer
	if not lp then
		return 1
	end
	const userRates = NAStuff._bgEventRate
	const rate = userRates and tonumber(userRates[lp.UserId]) or 1
	if not rate or rate < 1 then
		return 1
	end
	return rate
end

NAmanage._bgScaledWait = NAmanage._bgScaledWait or function(minWait, maxWait)
	const minT = tonumber(minWait) or 1
	local maxT = tonumber(maxWait) or minT
	if maxT < minT then
		maxT = minT
	end
	const span = maxT - minT
	local waitTime = minT
	if span > 0 then
		waitTime = waitTime + (NAmanage.NABgRand(span + 1) - 1)
	end
	waitTime = waitTime / ((NAmanage._bgEventRate and NAmanage._bgEventRate()) or 1)
	return math.max(5, waitTime)
end

SpawnCall(function()
	if not (NAmanage._bgEnabled and NAmanage._bgEnabled()) then
		return
	end
end)

if not NAStuff._bgSoundLoopStarted then
	NAStuff._bgSoundLoopStarted = true
	SpawnCall(function()
		if not (NAmanage._bgEnabled and NAmanage._bgEnabled()) then
			return
		end

		while true do
			local waitTime
			if isAprilFools and isAprilFools() then
				const aprilData = NAStuff and NAStuff.AprilFoolsData or {}
				const soundCooldown = aprilData.prankSoundCooldown or {}
				waitTime = NAmanage._bgScaledWait(tonumber(soundCooldown.min) or 300, tonumber(soundCooldown.max) or 480) -- 5-8 minutes (AF mode), scaled per user
			else
				waitTime = NAmanage._bgScaledWait(180, 300) -- 3-5 minutes, scaled per user
			end
			Wait(waitTime)
			SpawnCall(NAmanage._bgSound)
		end
	end)
end

if not NAStuff._bgOverlayLoopStarted then
	NAStuff._bgOverlayLoopStarted = true
	SpawnCall(function()
		if not (NAmanage._bgEnabled and NAmanage._bgEnabled()) then
			return
		end

		while true do
			local waitTime
			if isAprilFools and isAprilFools() then
				const aprilData = NAStuff and NAStuff.AprilFoolsData or {}
				const overlayCooldown = aprilData.prankOverlayCooldown or {}
				waitTime = NAmanage._bgScaledWait(tonumber(overlayCooldown.min) or 420, tonumber(overlayCooldown.max) or 720) -- 7-12 minutes (AF mode), scaled per user
			else
				waitTime = NAmanage._bgScaledWait(300, 900) -- 5-15 minutes, scaled per user
			end
			Wait(waitTime)
			SpawnCall(NAmanage._bgOverlay)
		end
	end)
end

bringc={}

--[[ Welcome Messages ]]--
msg = {
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
	const lenS, lenT = #s, #t
	if lenS == 0 then return lenT end
	if lenT == 0 then return lenS end

	const d = {}

	for i = 0, lenS do
		d[i] = {}
		d[i][0] = i
	end
	for j = 1, lenT do
		d[0][j] = j
	end

	for i = 1, lenS do
		for j = 1, lenT do
			const cost = (s:sub(i, i) == t:sub(j, j)) and 0 or 1
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

	const function cc(collection)
		for name in collection do
			const distance = levenshtein(input, name)
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
		r, f = '', (pqwodwjvxnskdsfo:find(x) - 1)
		for i = 6, 1, -1 do
			r = r..(f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
		end
		return r
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		c = 0
		for i = 1, 8 do
			c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
		end
		return string.char(c)
	end))
end]]
function isRelAdmin(Player)
	if not Player then
		return false
	end
	const admins = _na_env and _na_env.NAadminsLol
	if type(admins) ~= "table" then
		return false
	end
	for _, id in admins do
		if Player.UserId == id then
			return true
		end
	end
	return false
end

NAmanage.rebuildIndex=function(entriesOverride)
	table.clear(searchIndex)
	local entries = entriesOverride
	if type(entries) ~= "table" then
		entries = NAStuff.AutofillEntries or {}
	end
	const metaByName = NAStuff.AutofillMetaByName or {}
	for _, entry in entries do
		const cmdName = entry and entry.name
		if not cmdName then
			continue
		end
		const meta = metaByName[cmdName]
		const command = cmds.Commands[cmdName]
		local displayInfo = meta and meta.displayText or ""
		const extra = {}
		if meta and type(meta.aliases) == "table" then
			for _, alias in meta.aliases do
				const aliasText = Lower(tostring(alias or ""))
				if aliasText ~= "" then
					extra[#extra + 1] = aliasText
				end
			end
		end
		if command and displayInfo == "" then
			local updatedText, aliasList = fixStupidSearchGoober(cmdName, command)
			if updatedText and type(command[2]) == "table" then
				command[2][1] = updatedText
			end
			displayInfo = (command[2] and command[2][1]) or ""
			for _, alias in aliasList or {} do
				const aliasText = Lower(tostring(alias or ""))
				if aliasText ~= "" then
					extra[#extra + 1] = aliasText
				end
			end
		end
		const lowerName = Lower(cmdName)
		const searchable = NAmanage.stripMarkup(Lower((meta and meta.searchable) or displayInfo))
		Insert(searchIndex,{
			name = cmdName,
			lowerName = lowerName,
			searchable = searchable,
			extraAliases = extra,
			display = entry.display,
			meta = meta
		})
	end
end

NAmanage.rebuildSearchAliasCache = function()
	table.clear(aliasOwnerByAlias)
	table.clear(savedOwnerByAlias)
	const dataToName = {}
	for cmdName, data in cmds.Commands or {} do
		dataToName[data] = cmdName
	end
	for alias, data in cmds.Aliases or {} do
		const owner = dataToName[data]
		if owner then
			aliasOwnerByAlias[alias] = owner
		end
	end
	for alias, original in cmds.NASAVEDALIASES or {} do
		if type(original) == "string" and original ~= "" then
			savedOwnerByAlias[alias] = original
		end
	end
end

NAmanage.applyCommandDataPackage = NAmanage.applyCommandDataPackage or function(package)
	if type(package) ~= "table" then
		return false
	end
	if type(NAmanage.resetCommandWorkBudget) == "function" then
		NAmanage.resetCommandWorkBudget()
	end
	NAStuff.AutofillEntries = package.entries or {}
	NAStuff.AutofillMetaByName = package.metaByName or {}
	NAStuff.DefaultBarAutofillEntries = package.defaultEntryMap or {}
	table.clear(searchIndex)
	for i = 1, #(package.searchEntries or {}) do
		searchIndex[i] = package.searchEntries[i]
		NAmanage.cmdYield(i, 48)
	end
	table.clear(aliasOwnerByAlias)
	local aliasStep = 0
	for alias, owner in package.aliasOwnerMap or {} do
		aliasStep += 1
		aliasOwnerByAlias[alias] = owner
		NAmanage.cmdYield(aliasStep, 48)
	end
	table.clear(savedOwnerByAlias)
	local savedStep = 0
	for alias, owner in package.savedOwnerMap or {} do
		savedStep += 1
		savedOwnerByAlias[alias] = owner
		NAmanage.cmdYield(savedStep, 48)
	end
	NAStuff.CommandBuildSignatureApplied = package.signature or (NAmanage.getCommandBuildSignature and NAmanage.getCommandBuildSignature()) or nil
	cmdNAnum = tonumber(package.totalCount) or #(package.entries or {})
	return true
end

NAmanage.ControlLock_FromString = function(s)
	NAStuff._ctrlLockList = {}
	NAStuff._ctrlLockSet = {}
	for key in string.gmatch((s or ""), "([^,]+)") do
		const k = key:gsub("%s+","")
		if k ~= "" and not NAStuff._ctrlLockSet[k] then
			Insert(NAStuff._ctrlLockList, k)
			NAStuff._ctrlLockSet[k] = true
		end
	end
	if #NAStuff._ctrlLockList == 0 then
		NAStuff._ctrlLockList = {"LeftShift","RightShift"}
		NAStuff._ctrlLockSet = {LeftShift=true, RightShift=true}
	end
	NAStuff._ctrlLockKeys = Concat(NAStuff._ctrlLockList, ",")
end

NAmanage.ControlLock_ToString = function()
	NAStuff._ctrlLockKeys = Concat(NAStuff._ctrlLockList, ",")
	return NAStuff._ctrlLockKeys
end

NAmanage.ControlLock_Apply = function(keys)
	if not IsOnPC then DebugNotif("PC-only feature") return end
	const player = Services.Players.LocalPlayer
	const mlc = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	const boundKeys = mlc:WaitForChild("BoundKeys")
	boundKeys.Value = keys
	DebugNotif("Shiftlock keys set to "..keys)
end

NAmanage.ControlLock_AddKey = function(keyName)
	if not keyName or keyName == "" then return end
	if not NAStuff._ctrlLockSet[keyName] then
		Insert(NAStuff._ctrlLockList, keyName)
		NAStuff._ctrlLockSet[keyName] = true
		NAmanage.ControlLock_ToString()
		NAmanage.ControlLock_Apply(NAStuff._ctrlLockKeys)
		DebugNotif("Added "..keyName.." to Shiftlock keys")
	else
		DebugNotif(keyName.." already in list")
	end
end

NAmanage.ControlLock_RemoveKey = function(keyName)
	if not keyName or keyName == "" then return end
	if NAStuff._ctrlLockSet[keyName] then
		const idx = Discover(NAStuff._ctrlLockList, keyName)
		if idx then table.remove(NAStuff._ctrlLockList, idx) end
		NAStuff._ctrlLockSet[keyName] = nil
		NAmanage.ControlLock_ToString()
		NAmanage.ControlLock_Apply(NAStuff._ctrlLockKeys)
		DebugNotif("Removed "..keyName.." from Shiftlock keys")
	else
		DebugNotif(keyName.." not in list")
	end
end

NAmanage.ControlLock_ClearToDefault = function()
	NAStuff._ctrlLockList = {"LeftShift","RightShift"}
	NAStuff._ctrlLockSet = {LeftShift=true, RightShift=true}
	NAmanage.ControlLock_ToString()
	NAmanage.ControlLock_Apply(NAStuff._ctrlLockKeys)
end

NAmanage.ControlLock_Bind = function()
	NAlib.disconnect("controllock_persist")
	if NAStuff._ctrlLockPersist and IsOnPC then
		NAlib.connect("controllock_persist", Services.Players.LocalPlayer.CharacterAdded:Connect(function()
			NAmanage.ControlLock_Apply(NAStuff._ctrlLockKeys)
		end))
	end
end

function nameChecker(p)
	if not NAlib.isProperty(p, "DisplayName") then
		return p.Name
	end

	const displayName = p.DisplayName
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

	const args = {}
	for arg in string.gmatch(input, "[^%s]+") do
		Insert(args, arg)
	end
	return args
end

NAmanage.CommandArgumentAutofillFixedIndex = {
	addalias = 2;
	addbutton = 2;
	ab = 2;
	addautoexec = 2;
	aaexec = 2;
	addae = 2;
	addauto = 2;
	aexecadd = 2;
	cmdloop = 2;
	commandloop = 2;
	ifundone = 2;
	ifnotdone = 2;
	ifnew = 2;
	propertychanged = 4;
	changed = 4;
	pchanged = 4;
	propchanged = 4;
}

NAmanage.commandArgumentAutofillIndex = function(firstLower, tokens)
	firstLower = Lower(tostring(firstLower or ""))
	const fixedIndex = NAmanage.CommandArgumentAutofillFixedIndex[firstLower]
	if fixedIndex then
		return fixedIndex
	end

	if firstLower == "loop" then
		local idx = 2
		if tokens[idx] and tonumber(tokens[idx].text) then
			idx += 1
		end
		return idx
	end

	if firstLower == "repeat" then
		local idx = 2
		if tokens[idx] and tonumber(tokens[idx].text) then
			idx += 1
		end
		if tokens[idx] and tonumber(tokens[idx].text) then
			idx += 1
		end
		return idx
	end
end

NAmanage.getCmdAutofillContext = function(rawText)
	local raw = tostring(rawText or "")
	const prefix = tostring(opt and opt.prefix or "")
	if prefix ~= "" then
		const escapedPrefix = (NAmanage.StreamerEscapePattern and NAmanage.StreamerEscapePattern(prefix)) or prefix:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
		raw = raw:gsub("^%s*"..escapedPrefix.."+", "")
	end

	const sanitized = NAmanage.stripChar(raw, false) or raw
	const lowerSanitized = Lower(sanitized)
	const tokens = {}
	for startPos, word, endPos in sanitized:gmatch("()(%S+)()") do
		tokens[#tokens + 1] = {
			text = word,
			lower = Lower(word),
			startPos = startPos,
			endPos = endPos - 1,
		}
	end

	const ctx = {
		raw = sanitized,
		query = lowerSanitized:gsub("%s+$", ""),
		prefix = "",
		suffix = "",
		mode = "command",
	}

	const first = tokens[1]
	local commandArgIndex = first and NAmanage.commandArgumentAutofillIndex(first.lower, tokens)
	if commandArgIndex then
		const commandToken = tokens[commandArgIndex]
		if commandToken then
			ctx.mode = "command-argument"
			ctx.query = commandToken.lower
			ctx.prefix = sanitized:sub(1, commandToken.startPos - 1)
			ctx.suffix = sanitized:sub(commandToken.endPos + 1)
		elseif sanitized:match("%s$") and #tokens >= commandArgIndex - 1 then
			ctx.mode = "command-argument"
			ctx.query = ""
			ctx.prefix = sanitized
			if sanitized ~= "" and not sanitized:match("%s$") then
				ctx.prefix = sanitized.." "
			end
			ctx.suffix = ""
		else
			commandArgIndex = nil
		end
		if commandArgIndex then
			return ctx
		end
	end

	const trimmed = ctx.query
	if Match(trimmed, "%s") then
		const commandToken = tokens[1]
		if commandToken then
			ctx.query = commandToken.lower
			ctx.prefix = sanitized:sub(1, commandToken.startPos - 1)
			ctx.suffix = sanitized:sub(commandToken.endPos + 1)
		end
	end

	return ctx
end

NAmanage.composeCmdAutofillText = function(ctx, commandName)
	const name = NAmanage.stripChar(tostring(commandName or ""))
	if name == "" then
		return ""
	end
	if ctx and (ctx.mode == "command-argument" or ctx.mode == "cmdloop-command" or ctx.suffix ~= "" or ctx.prefix ~= "") then
		return (ctx.prefix or "")..name..(ctx.suffix or "")
	end
	return name
end

NAgui.MakeSwitchRow=function(parent, name, labelText)
	const f = InstanceNew("Frame")
	f.Name = name or "SwitchRow"
	f.BackgroundColor3 = Color3.fromRGB(44, 44, 49)
	f.BorderSizePixel = 0
	f.Size = UDim2.new(1, -10, 0, 32)
	f.BackgroundTransparency = 0.2
	f.Parent = parent

	const c = InstanceNew("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = f

	const st = InstanceNew("UIStroke")
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Color = Color3.fromRGB(71, 71, 71)
	st.Parent = f

	const t = InstanceNew("TextLabel")
	t.Name = "Title"
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.Gotham
	t.TextSize = 14
	t.TextColor3 = Color3.fromRGB(244, 244, 249)
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.AnchorPoint = Vector2.new(0, 0.5)
	t.Position = UDim2.new(0, 12, 0.5, 0)
	t.Size = UDim2.new(1, -80, 0, 16)
	t.TextTruncate = Enum.TextTruncate.AtEnd
	t.Text = labelText or "Toggle"
	t.Parent = f

	const btn = InstanceNew("TextButton")
	btn.Name = "Interact"
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.ZIndex = (f.ZIndex or 1) + 1
	btn.Parent = f

	const sw = InstanceNew("Frame")
	sw.Name = "Switch"
	sw.BorderSizePixel = 0
	sw.AnchorPoint = Vector2.new(1, 0.5)
	sw.Position = UDim2.new(1, -12, 0.5, 0)
	sw.Size = UDim2.new(0, 45, 0, 22)
	sw.BackgroundColor3 = Color3.fromRGB(49, 49, 54)
	sw.Parent = f

	const c2 = InstanceNew("UICorner")
	c2.CornerRadius = UDim.new(0, 6)
	c2.Parent = sw

	const st2 = InstanceNew("UIStroke")
	st2.Color = Color3.fromRGB(71, 71, 71)
	st2.Parent = sw

	const dot = InstanceNew("Frame")
	dot.Name = "Indicator"
	dot.BorderSizePixel = 0
	dot.AnchorPoint = Vector2.new(0, 0.5)
	dot.Position = UDim2.new(0, 2, 0.5, 0)
	dot.Size = UDim2.new(0, 18, 0, 18)
	dot.BackgroundColor3 = Color3.fromRGB(114, 114, 124)
	dot.Parent = sw

	const c3 = InstanceNew("UICorner")
	c3.CornerRadius = UDim.new(0, 6)
	c3.Parent = dot

	const st3 = InstanceNew("UIStroke")
	st3.Color = Color3.fromRGB(83, 83, 83)
	st3.Parent = dot

	return f, btn, sw, dot, t
end

NAmanage._normPlayer = function(p)
	if typeof(p) == "Instance" and p:IsA("Player") then return p end
	if type(p) == "string" then
		const targets = NAmanage.getPlr and NAmanage.getPlr("exactuser:"..p) or {}
		return targets[1]
	end
	return nil
end

NAmanage._makeCtx = function(evName, ...)
	const lp = Services.Players and Services.Players.LocalPlayer
	const ctx = { event = evName, localPlayer = lp }
	local a1, a2, a3 = ...

	if evName == "OnChatted" then
		if typeof(a1) == "Instance" and a1:IsA("Player") then
			ctx.player, ctx.message = a1, a2
		else
			ctx.player, ctx.message = lp, a1
		end
	elseif evName == "OnJoin" or evName == "OnLeave" then
		ctx.player = NAmanage._normPlayer(a1) or lp
	elseif evName == "OnSpawn" then
		ctx.player = NAmanage._normPlayer(a1) or lp
		ctx.character = a2
	elseif evName == "OnDeath" then
		if typeof(a1) == "Instance" and a1:IsA("Player") then
			ctx.player = a1
		else
			ctx.player = lp
		end
	elseif evName == "OnDamage" then
		if typeof(a1) == "Instance" and a1:IsA("Player") then
			ctx.player, ctx.oldhp, ctx.newhp = a1, a2, a3
		else
			ctx.player, ctx.oldhp, ctx.newhp = lp, a1, a2
		end
	elseif evName == "OnKill" then
		ctx.player = NAmanage._normPlayer(a1)
		ctx.victim = NAmanage._normPlayer(a2)
	elseif evName == "OnJump" then
		ctx.player = NAmanage._normPlayer(a1) or lp
		ctx.humanoid = a2
	elseif evName == "OnEquipItem" or evName == "OnUnequipItem" then
		ctx.player = NAmanage._normPlayer(a1) or lp
		ctx.item = a2
	else
		ctx.player = lp
	end

	ctx.isSelf = (ctx.player == lp)
	return ctx
end

NAmanage._parseSelectorPrefix = function(s)
	local open, rest = s:match("^%s*([<%[].-[>%]])%s*(.*)$")
	if not open then return nil, s end

	const tag = open:sub(2, #open - 1)
	const sel = { terms = {} }

	for part in string.gmatch(tag, "[^,%s]+") do
		local k, v = part:match("^([^:]+):(.+)$")
		k = (k or part)
		const kl = k:lower()
		const vl = v and v:lower()

		if kl == "me" then
			sel.me = true
		elseif kl == "notme" or kl == "others" then
			sel.notme = true
		elseif kl == "all" then
			sel.all = true
		elseif kl == "id" or kl == "userid" then
			sel.id = tonumber(vl)
		elseif kl == "friend" or kl == "friends" then
			sel.friend = true
		elseif kl == "player" or kl == "name" then
			sel.namePrefix = vl
		elseif kl == "display" or kl == "displayname" then
			sel.displayPrefix = vl
		elseif kl == "t" or kl == "target" then
			if vl and vl ~= "" then Insert(sel.terms, vl) end
		else
			Insert(sel.terms, k:lower())
		end
	end

	return sel, rest
end

NAmanage._selectorPasses = function(sel, ctx)
	if not sel then return true end
	const lp = Services.Players and Services.Players.LocalPlayer
	const plr = ctx.player
	if not plr or not lp then return false end

	const ev = ctx.event
	if ev == "OnJoin" or ev == "OnLeave" then
		if plr == lp then return false end
		if sel.me then return false end
	end

	if sel.me and plr ~= lp then return false end
	if sel.notme and plr == lp then return false end
	if sel.id and plr.UserId ~= sel.id then return false end
	if sel.friend and not lp:IsFriendsWith(plr.UserId) then return false end

	const resolver = NAmanage.getPlr
	if sel.namePrefix and sel.namePrefix ~= "" then
		local ok, list = pcall(function() return resolver and resolver(lp, sel.namePrefix) or {} end)
		if not ok or type(list) ~= "table" or not Discover(list, plr) then
			return false
		end
	end
	if sel.displayPrefix and sel.displayPrefix ~= "" then
		local ok, list = pcall(function() return resolver and resolver(lp, "display:"..sel.displayPrefix) or {} end)
		if not ok or type(list) ~= "table" or not Discover(list, plr) then
			return false
		end
	end

	if sel.all then
		return true
	end

	if sel.terms and #sel.terms > 0 then
		for _, term in sel.terms do
			local ok, list = pcall(function() return resolver and resolver(lp, term) or {} end)
			list = (ok and type(list) == "table") and list or {}
			if Discover(list, plr) then
				return true
			end
		end
		return false
	end

	return true
end

NAmanage._expandTokens = function(s, ctx)
	const lp = Services.Players and Services.Players.LocalPlayer
	return (s:gsub("{(.-)}", function(key)
		key = key:lower()
		if key == "me" then return (lp and lp.Name) or "" end
		if key == "myid" then return (lp and tostring(lp.UserId)) or "" end
		if key == "player" then return (ctx.player and ctx.player.Name) or "" end
		if key == "display" or key == "displayname" then return (ctx.player and ctx.player.DisplayName) or "" end
		if key == "userid" then return (ctx.player and tostring(ctx.player.UserId)) or "" end
		if key == "message" then return ctx.message or "" end
		if key == "oldhp" then return ctx.oldhp and tostring(math.floor(ctx.oldhp + 0.5)) or "" end
		if key == "newhp" then return ctx.newhp and tostring(math.floor(ctx.newhp + 0.5)) or "" end
		if key == "killer" then return (ctx.player and ctx.player.Name) or "" end
		if key == "killerid" then return (ctx.player and tostring(ctx.player.UserId)) or "" end
		if key == "victim" then return (ctx.victim and ctx.victim.Name) or "" end
		if key == "victimdisplay" or key == "victimdisplayname" then return (ctx.victim and ctx.victim.DisplayName) or "" end
		if key == "victimid" then return (ctx.victim and tostring(ctx.victim.UserId)) or "" end
		if key == "item" or key == "tool" then return (ctx.item and ctx.item.Name) or "" end
		if key == "itemclass" or key == "toolclass" then return (ctx.item and ctx.item.ClassName) or "" end
		return ""
	end))
end

NAmanage.ExecuteBindings = function(evName, ...)
	const list = Bindings[evName]
	if type(list) ~= "table" then return end

	const ctx = NAmanage._makeCtx(evName, ...)
	for _, raw in list do
		if not NAmanage.BinderEntryDisabled(raw) then
			const line = NAmanage.BinderEntryText(raw)
			if line ~= "" then
				local sel, cmdText = NAmanage._parseSelectorPrefix(line)
				if NAmanage._selectorPasses(sel, ctx) then
					const expanded = NAmanage._expandTokens(cmdText, ctx)
					SpawnCall(function()
						if Find(expanded, ";", 1, true) or Find(expanded, "\n", 1, true) then
							NAmanage.BinderRunSequence(expanded)
							return
						end
						const args = ParseArguments(expanded) or { expanded }
						cmd.run(args)
					end)
				end
			end
		end
	end
end

NAmanage.BinderTrim = function(text)
	if type(text) ~= "string" then
		return ""
	end
	return text:match("^%s*(.-)%s*$") or ""
end

NAmanage.BinderSplitSequence = function(raw)
	const steps = {}
	const text = NAmanage.BinderTrim(raw)
	if text == "" then
		return steps
	end

	for part in text:gmatch("[^;\n]+") do
		const step = NAmanage.BinderTrim(part)
		if step ~= "" then
			Insert(steps, step)
		end
	end

	if #steps == 0 and text ~= "" then
		Insert(steps, text)
	end

	return steps
end

NAmanage.BinderWaitFromStep = function(step)
	const trimmed = NAmanage.BinderTrim(step)
	if trimmed == "" then
		return nil
	end

	const lower = Lower(trimmed)
	const num = lower:match("^wait%s+([%-]?[%d%.]+)$")
		or lower:match("^delay%s+([%-]?[%d%.]+)$")
		or lower:match("^pause%s+([%-]?[%d%.]+)$")

	if not num then
		return nil
	end

	local seconds = tonumber(num)
	if not seconds then
		return nil
	end
	if seconds < 0 then
		seconds = 0
	end
	return seconds
end

NAmanage.BinderRunSequence = function(raw)
	const steps = NAmanage.BinderSplitSequence(raw)
	if #steps == 0 then
		return false, "No steps provided"
	end

	for _, step in steps do
		const waitTime = NAmanage.BinderWaitFromStep(step)
		if waitTime ~= nil then
			Wait(waitTime)
		else
			const args = ParseArguments(step)
			if args and args[1] then
				cmd.run(args)
			end
		end
	end

	return true
end

NAmanage.BinderHasEntries = function(evName)
	const list = Bindings and Bindings[evName]
	if type(list) ~= "table" then
		return false
	end
	for _, entry in list do
		if NAmanage.BinderEntryText(entry) ~= "" then
			return true
		end
	end
	return false
end

NAmanage.BinderNeedsToolHooks = function()
	return NAmanage.BinderHasEntries("OnEquipItem")
		or NAmanage.BinderHasEntries("OnUnequipItem")
end

NAmanage.BinderNeedsHumanoidHooks = function()
	return NAmanage.BinderHasEntries("OnDeath")
		or NAmanage.BinderHasEntries("OnKill")
		or NAmanage.BinderHasEntries("OnDamage")
		or NAmanage.BinderHasEntries("OnJump")
end

NAmanage.BinderNeedsCharacterHooks = function()
	return NAmanage.BinderHasEntries("OnSpawn")
		or NAmanage.BinderNeedsToolHooks()
		or NAmanage.BinderNeedsHumanoidHooks()
end

function loadedResults(res)
	local total = tonumber(res) or 0
	const isNegative = total < 0
	total = math.abs(total)

	const units = {
		{ "d", 86400 },
		{ "h", 3600 },
		{ "m", 60 },
		{ "s", 1 },
	}

	const parts = {}
	for _, u in units do
		const count = math.floor(total / u[2])
		total = total % u[2]
		parts[u[1]] = count
	end

	const milliseconds = math.floor((total) * 1000)
	const output = {}

	for _, u in units do
		const val = parts[u[1]]
		if val > 0 then
			Insert(output, Format("%d%s", val, u[1]))
		end
	end

	if parts["s"] == 0 and milliseconds > 0 then
		Insert(output, Format("%.3fs", milliseconds / 1000))
	end

	const result = Concat(output, " ")
	return isNegative and ("-"..result) or result
end

NAmanage.prepareTeleportCleanup = NAmanage.prepareTeleportCleanup or function()
	if NAStuff then
		NAStuff.teleportTransition = true
		NAStuff.teleportTransitionSince = tick()
	end
	pcall(function()
		if NAmanage._cgHubDispose then
			NAmanage._cgHubDispose()
		end
	end)
	pcall(function()
		if NAmanage._pgHubDispose then
			NAmanage._pgHubDispose()
		end
	end)
	pcall(function()
		if NAmanage.wsReleaseCache then
			NAmanage.wsReleaseCache()
		end
	end)
	if NAStuff then
		NAStuff._mainLoopToken = (tonumber(NAStuff._mainLoopToken) or 0) + 1
	end
	if NAlib and NAlib.disconnect then
		const names = {
			"CornerEditor",
			"CornerEditor_PlayerGui",
			"CornerEditor_HUI",
			"CornerEditor_PlayerGuiAdded",
			"CornerEditor_PlayerGuiRemoved",
			"FontEditor",
			"FontEditor_PlayerGui",
			"FontEditor_HUI",
			"FontEditor_PlayerGuiAdded",
			"FontEditor_PlayerGuiRemoved",
			"streamermode_coregui",
			"streamermode_playergui",
			"streamermode_hui",
			"streamermode_workspace",
			"NA_RenderStepMain",
			"NA_MouseDesc",
		}
		for i = 1, #names do
			pcall(NAlib.disconnect, names[i])
		end
	end
end

NAStuff.onTP = LocalPlayer.OnTeleport
if NAStuff.onTP and typeof(NAStuff.onTP) == "RBXScriptSignal" then
	if NAStuff.onTPConnection then
		pcall(function() NAStuff.onTPConnection:Disconnect() end)
	end
	NAStuff.onTPConnected = true
	pcall(function()
		NAStuff.onTPConnection = NAStuff.onTP:Connect(function(...)
			const tpState = select(1, ...)
			const stateName = (typeof(tpState) == "EnumItem" and tpState.Name) or tostring(tpState or "")
			if stateName == "Failed" then
				NAStuff.teleportTransition = false
				NAStuff.teleportTransitionSince = nil
				NAStuff._qotQueued = false
				if type(NAmanage.TeleportGui_Clear) == "function" then
					pcall(NAmanage.TeleportGui_Clear)
				end
				if type(NAmanage.GameTeleportGui_Reset) == "function" then
					pcall(NAmanage.GameTeleportGui_Reset)
				end
				if type(NAmanage.TryExperienceFallback) == "function" then
					local fallbackOk, fallbackErr = NAmanage.TryExperienceFallback("LocalPlayer.OnTeleport Failed")
					if not fallbackOk and fallbackErr and fallbackErr ~= "No pending ExperienceService fallback" then
						DebugNotif("ExperienceService fallback failed: "..tostring(fallbackErr), 4)
					end
				end
				return
			end
			if stateName == "RequestedFromServer" or stateName == "Started" or stateName == "WaitingForServer" or stateName == "InProgress" then
				if type(NAmanage.GameTeleportGui_OnTeleport) == "function" then
					pcall(NAmanage.GameTeleportGui_OnTeleport, tpState, select(2, ...), select(3, ...))
				end
				NAmanage.prepareTeleportCleanup()
				if not NAStuff._qotQueued then
					NAStuff._qotQueued = true
					Defer(function()
						if NAQoTEnabled and type(opt.queueteleport) == "function" and type(opt.loader) == "string" and opt.loader ~= "" then
							pcall(opt.queueteleport, opt.loader)
						end
						if isAprilFools() and type(opt.queueteleport) == "function" then
							pcall(opt.queueteleport, [[
								local env = (getgenv and getgenv()) or _G or {}
								env.ActivateAprilMode = true
							]])
						end
					end)
				end
			end
		end)
	end)
end

if Services.TeleportService then
	NAStuff.teleportTransitionFailHook = true
	pcall(function()
		NAlib.disconnect("na_teleport_transition_fail")
		NAlib.connect("na_teleport_transition_fail", Services.TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
			const lp = Services.Players and Services.Players.LocalPlayer
			if lp and player == lp then
				NAStuff.teleportTransition = false
				NAStuff.teleportTransitionSince = nil
				NAStuff._qotQueued = false
				if type(NAmanage.TeleportGui_Clear) == "function" then
					pcall(NAmanage.TeleportGui_Clear)
				end
				if type(NAmanage.GameTeleportGui_Reset) == "function" then
					pcall(NAmanage.GameTeleportGui_Reset)
				end
				if type(NAmanage.TryExperienceFallback) == "function" then
					local fallbackOk, fallbackErr = NAmanage.TryExperienceFallback("TeleportInitFailed: "..tostring(result).." "..tostring(errorMessage))
					if not fallbackOk and fallbackErr and fallbackErr ~= "No pending ExperienceService fallback" then
						DebugNotif("ExperienceService fallback failed: "..tostring(fallbackErr), 4)
					end
				end
			end
		end))
	end)
end

NAmanage.cloneArgsArray=function(source)
	const out = {}
	if source then
		for i, v in source do
			out[i] = v
		end
	end
	return out
end

NAStuff._doneCommands = NAStuff._doneCommands or {}

NAmanage.commandPrimaryName = function(commandData, fallback)
	if commandData then
		for name, data in cmds.Commands or {} do
			if data == commandData then
				return name
			end
		end
	end
	return Lower(tostring(fallback or ""))
end

NAmanage.commandDoneKey = function(rawArgs)
	if type(rawArgs) ~= "table" then
		return nil, nil, nil
	end
	const first = rawArgs[1]
	if type(first) ~= "string" or first == "" then
		return nil, nil, nil
	end
	const lowerFirst = Lower(first)
	const commandData = (cmds.Commands and cmds.Commands[lowerFirst]) or (cmds.Aliases and cmds.Aliases[lowerFirst])
	const primary = NAmanage.commandPrimaryName(commandData, lowerFirst)
	const args = {}
	for i = 2, #rawArgs do
		args[#args + 1] = tostring(rawArgs[i] or "")
	end
	return primary.." "..Concat(args, " "), primary, args
end

NAmanage.markCommandDone = function(rawArgs)
	const key = NAmanage.commandDoneKey(rawArgs)
	if key and key ~= "" then
		NAStuff._doneCommands[key] = true
	end
end

NAmanage.markCommandUndone = function(rawArgs)
	local _, primary = NAmanage.commandDoneKey(rawArgs)
	if not primary or primary == "" then
		return
	end
	if Sub(primary, 1, 2) ~= "un" then
		return
	end
	const base = Sub(primary, 3)
	if base == "" then
		return
	end
	for key in NAStuff._doneCommands do
		if key == base or Sub(key, 1, #base + 1) == base.." " then
			NAStuff._doneCommands[key] = nil
		end
	end
end

NAmanage.commandWasDone = function(rawArgs)
	const key = NAmanage.commandDoneKey(rawArgs)
	return key and NAStuff._doneCommands[key] == true
end

NAmanage.updateLastCommand=function(rawArgs)
	if type(rawArgs) ~= "table" then return end
	const first = rawArgs[1]
	if type(first) ~= "string" then return end
	const lowerFirst = Lower(first)
	if lowerFirst == "lastcommand" or lowerFirst == "lastcmd" then
		return
	end
	if NAStuff._lastCommand then
		NAStuff._prevCommand = NAmanage.cloneArgsArray(NAStuff._lastCommand)
	else
		NAStuff._prevCommand = nil
	end
	NAStuff._lastCommand = rawArgs
end

NAmanage.tryIYIntegration=function(rawArgs, opts)
	opts = opts or {}
	local bridge = NAStuff.IYIntegrationBridge
	if type(bridge) ~= "table" then
		bridge = NAmanage.IYIntegrationFindExistingBridge()
		if type(bridge) == "table" then
			NAStuff.IYIntegrationBridge = bridge
		else
			local okAttach = false
			if type(NAmanage.detectIYManualLoad) == "function" then
				okAttach = select(1, NAmanage.detectIYManualLoad({ sourceLabel = "lazy-ui"; refreshUI = false; }))
			end
			if okAttach then bridge = NAStuff.IYIntegrationBridge end
		end
	end
	if type(bridge) ~= "table" or type(rawArgs) ~= "table" or type(rawArgs[1]) ~= "string" then
		return false, "bridge-unavailable"
	end
	const first = tostring(rawArgs[1])
	const forced = Sub(first, 1, 3):lower() == "iy:"
	local commandName = forced and Sub(first, 4) or first
	commandName = Lower(tostring(commandName or ""))
	if commandName == "" or not NAmanage.IYIntegrationHasCommand(commandName) then return false, "command-not-found" end
	const arguments = {}
	for index = 2, #rawArgs do arguments[#arguments + 1] = tostring(rawArgs[index] or "") end
	const runMethod = NAmanage.IYIntegrationGetMethod(bridge, { "RunCommand", "runCommand" })
	if type(runMethod) == "function" then
		local okRun, accepted, result = pcall(runMethod, commandName, arguments, { source = "nameless-admin"; })
		if okRun and accepted ~= false then return true, result end
		return false, tostring(result or accepted or "command-run-failed")
	end
	const parseMethod = NAmanage.IYIntegrationGetMethod(bridge, { "Parse", "parse" })
	if type(parseMethod) ~= "function" then return false, "parser-unavailable" end
	local line = commandName
	if #arguments > 0 then line = line.." "..Concat(arguments, " ") end
	local okParse, accepted, result = pcall(parseMethod, line, { source = "nameless-admin"; })
	if okParse and accepted ~= false then return true, result end
	return false, tostring(result or accepted or "command-parse-failed")
end

NAmanage.tryCmdIntegration=function(rawArgs, opts)
	opts = opts or {}
	local bridge = NAStuff.CmdIntegrationBridge
	if type(bridge) ~= "table" then
		bridge = NAmanage.CmdIntegrationFindExistingBridge()
		if type(bridge) == "table" then
			NAStuff.CmdIntegrationBridge = bridge
		end
	end
	if type(bridge) ~= "table" or type(rawArgs) ~= "table" or type(rawArgs[1]) ~= "string" then
		return false, "bridge-unavailable"
	end

	const first = tostring(rawArgs[1])
	const forced = Sub(first, 1, 4):lower() == "cmd:"
	local commandName = forced and Sub(first, 5) or first
	commandName = Lower(tostring(commandName or ""))
	if commandName == "" or not NAmanage.CmdIntegrationHasCommand(commandName) then
		return false, "command-not-found"
	end

	const arguments = {}
	for index = 2, #rawArgs do
		Insert(arguments, tostring(rawArgs[index] or ""))
	end
	const ignoreNotifications = NAStuff.CmdIntegrationUseNotifications ~= true
	const runMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "RunCommand", "runCommand" })
	if type(runMethod) == "function" then
		local okRun, accepted, result = pcall(runMethod, commandName, arguments, { ignoreNotifications = ignoreNotifications; source = "nameless-admin"; })
		if okRun and accepted ~= false then
			return true, result
		end
		return false, tostring(result or accepted or "command-run-failed")
	end

	const parseMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "Parse", "parse" })
	if type(parseMethod) ~= "function" then
		return false, "parser-unavailable"
	end
	local prefix = tostring(NAStuff.CmdIntegrationPrefix or bridge.prefix or ";")
	local separator = tostring(NAStuff.CmdIntegrationSeparator or bridge.separator or ",")
	if prefix == "" then prefix = ";" end
	if separator == "" then separator = "," end
	local line = prefix..commandName
	if #arguments > 0 then
		line = line.." "..Concat(arguments, separator)
	end
	const protocol = tonumber(bridge.Protocol or bridge.protocol) or 1
	local okParse, accepted, result
	if protocol >= 2 or bridge.Parse == parseMethod then
		okParse, accepted, result = pcall(parseMethod, line, { ignoreNotifications = ignoreNotifications; source = "nameless-admin"; })
	else
		okParse, accepted, result = pcall(parseMethod, ignoreNotifications, line)
	end
	if okParse and accepted ~= false then
		return true, result
	end
	return false, tostring(result or accepted or "command-parse-failed")
end

--[[ COMMAND FUNCTIONS ]]--
commandcount=0
NAmanage.makeUniqueAlias=function(aliasName, seen)
	const base = tostring(aliasName or "")
	const lowerBase = Lower(base)
	if base == "" then
		return nil, false
	end
	const hidden = type(NAStuff.SFWHiddenCommands) == "table" and NAStuff.SFWHiddenCommands or nil
	const hiddenCommands = hidden and hidden.Commands or nil
	const hiddenAliases = hidden and hidden.Aliases or nil
	if not seen[lowerBase]
		and not cmds.Commands[lowerBase]
		and not cmds.Aliases[lowerBase]
		and not (hiddenCommands and hiddenCommands[lowerBase])
		and not (hiddenAliases and hiddenAliases[lowerBase]) then
		return base, false
	end
	local idx = 1
	while true do
		const candidate = base..tostring(idx)
		const lowerCandidate = Lower(candidate)
		if not seen[lowerCandidate]
			and not cmds.Commands[lowerCandidate]
			and not cmds.Aliases[lowerCandidate]
			and not (hiddenCommands and hiddenCommands[lowerCandidate])
			and not (hiddenAliases and hiddenAliases[lowerCandidate]) then
			return candidate, true
		end
		idx = idx + 1
	end
end
Loops = {}
NAmanage.ensurePatchedInfo=function(info)
	local title = ""
	local desc = ""
	if type(info) == "table" then
		title = tostring(info[1] or "")
		desc = tostring(info[2] or "")
	elseif info ~= nil then
		title = tostring(info)
	end

	const lowerTitle = Lower(title)
	const lowerDesc = Lower(desc)

	if title == "" then
		title = "[PATCHED]"
	elseif not lowerTitle:find("patched", 1, true) then
		title = "[PATCHED] "..title
	end

	if desc == "" then
		desc = "Patched / may not work; might work again later or be removed if it stays patched"
	elseif not lowerDesc:find("patched", 1, true) then
		desc = desc.." (patched; might work again later or be removed if it stays patched)"
	end

	return {title, desc}
end

NAmanage.wrapPatchedFunc=function(func)
	if type(func) ~= "function" then
		return function()
			DoNotif("This command is patched and may not work. It could work again later or never be fixed; patched commands may be removed from NA if they stay patched.", 5)
		end
	end
	return function(...)
		DoNotif("This command is patched and may not work. It could work again later or never be fixed; patched commands may be removed from NA if they stay patched.", 5)
		return func(...)
	end
end

NAmanage.CmdArgDetect = NAmanage.CmdArgDetect or {}
NAmanage.CmdArgDetect.trim = NAmanage.CmdArgDetect.trim or function(text)
	text = tostring(text or "")
	text = text:gsub("^%s+", "")
	text = text:gsub("%s+$", "")
	return text
end

NAmanage.CmdArgDetect.aliasSet = NAmanage.CmdArgDetect.aliasSet or function(aliases)
	NAmanage.CmdArgDetect._aliasSet = NAmanage.CmdArgDetect._aliasSet or {}
	table.clear(NAmanage.CmdArgDetect._aliasSet)
	if type(aliases) == "table" then
		for i = 2, #aliases do
			if type(aliases[i]) == "string" and aliases[i] ~= "" then
				NAmanage.CmdArgDetect._aliasSet[Lower(aliases[i])] = true
			end
		end
	end
	return NAmanage.CmdArgDetect._aliasSet
end

NAmanage.CmdArgDetect.inner = NAmanage.CmdArgDetect.inner or function(block)
	if type(block) ~= "string" or #block < 2 then
		return ""
	end
	return NAmanage.CmdArgDetect.trim(Sub(block, 2, #block - 1))
end

NAmanage.CmdArgDetect.isBadgeBlock = NAmanage.CmdArgDetect.isBadgeBlock or function(inner)
	inner = Lower(NAmanage.CmdArgDetect.trim(inner))
	return inner == "patched" or inner == "na" or inner == "iy"
end

NAmanage.CmdArgDetect.isAliasParen = NAmanage.CmdArgDetect.isAliasParen or function(inner, aliasSet)
	if type(aliasSet) ~= "table" then
		return false
	end
	inner = NAmanage.CmdArgDetect.trim(inner)
	if inner == "" then
		return true
	end
	if inner:find("[<>%[%]{}|/:=]", 1, false) then
		return false
	end
	NAmanage.CmdArgDetect._aliasParts = NAmanage.CmdArgDetect._aliasParts or {}
	table.clear(NAmanage.CmdArgDetect._aliasParts)
	for part in inner:gmatch("[^,%s]+") do
		NAmanage.CmdArgDetect._aliasParts[#NAmanage.CmdArgDetect._aliasParts + 1] = Lower(part)
	end
	if #NAmanage.CmdArgDetect._aliasParts == 0 then
		return true
	end
	for i = 1, #NAmanage.CmdArgDetect._aliasParts do
		if not aliasSet[NAmanage.CmdArgDetect._aliasParts[i]] then
			return false
		end
	end
	return true
end

NAmanage.CmdArgDetect.has = NAmanage.CmdArgDetect.has or function(text, aliasSet)
	if type(text) ~= "string" then
		return false
	end
	for block in text:gmatch("%b<>") do
		if NAmanage.CmdArgDetect.inner(block) ~= "" then
			return true
		end
	end
	for block in text:gmatch("%b{}") do
		if NAmanage.CmdArgDetect.inner(block) ~= "" then
			return true
		end
	end
	for block in text:gmatch("%b[]") do
		NAmanage.CmdArgDetect._inner = NAmanage.CmdArgDetect.inner(block)
		if NAmanage.CmdArgDetect._inner ~= "" and not NAmanage.CmdArgDetect.isBadgeBlock(NAmanage.CmdArgDetect._inner) then
			return true
		end
	end
	for block in text:gmatch("%b()") do
		NAmanage.CmdArgDetect._inner = NAmanage.CmdArgDetect.inner(block)
		if NAmanage.CmdArgDetect._inner ~= "" and not NAmanage.CmdArgDetect.isAliasParen(NAmanage.CmdArgDetect._inner, aliasSet) then
			return true
		end
	end
	return false
end

NAmanage.inferRequiresArguments=function(infoTable, aliases)
	NAmanage.CmdArgDetect._set = NAmanage.CmdArgDetect.aliasSet(aliases)
	if type(infoTable) == "table" then
		if NAmanage.CmdArgDetect.has(infoTable[1], NAmanage.CmdArgDetect._set) then
			return true
		end
		if (type(infoTable[1]) ~= "string" or infoTable[1] == "") and NAmanage.CmdArgDetect.has(infoTable[2], NAmanage.CmdArgDetect._set) then
			return true
		end
	elseif type(infoTable) == "string" then
		return NAmanage.CmdArgDetect.has(infoTable, NAmanage.CmdArgDetect._set)
	end
	return false
end

NAStuff.CommandBuildRevision = tonumber(NAStuff.CommandBuildRevision) or 0
NAmanage.invalidateCommandBuild = NAmanage.invalidateCommandBuild or function()
	NAStuff.CommandBuildRevision = (tonumber(NAStuff.CommandBuildRevision) or 0) + 1
	NAStuff.CommandBuildSignatureCache = nil
	NAStuff.CommandBuildSignatureCacheRevision = nil
	return NAStuff.CommandBuildRevision
end

NAmanage.StartupCommandBudgetStep = NAmanage.StartupCommandBudgetStep or function()
	if NAStuff._loadingFinalizedOnce == true or (NAAssetsLoading and NAAssetsLoading._finalized == true) then
		return
	end
	local state = NAStuff._startupCommandBudget
	if type(state) ~= "table" then
		state = { count = 0; lastYield = os.clock(); }
		NAStuff._startupCommandBudget = state
	end
	state.count += 1
	const now = os.clock()
	const lowImpact = IsOnMobile == true or (type(NAmanage.IsLowEndUI) == "function" and NAmanage.IsLowEndUI() == true)
	const perf = NAStuff.StartupPerformance
	const lastFrameDt = type(perf) == "table" and tonumber(perf.lastFrameDt) or nil
	const highFps = lastFrameDt and lastFrameDt > 0 and lastFrameDt < (1 / 240)
	const batch = highFps and (lowImpact and 32 or 64) or (lowImpact and 64 or 96)
	const budget = highFps and 0.006 or (lowImpact and 0.018 or 0.025)

	if type(NAmanage.pulseLoadingUI) == "function" and state.count % 40 == 0 then
		pcall(NAmanage.pulseLoadingUI, "registering commands ("..tostring(state.count)..")", math.min(0.989, 0.965 + state.count / 40000))
	end

	if state.count % batch ~= 0 and now - (tonumber(state.lastYield) or now) < budget then
		return
	end

	local canYield = true
	if coroutine and type(coroutine.isyieldable) == "function" then
		canYield = coroutine.isyieldable()
	end
	if canYield then
		Wait()
		if type(perf) == "table" then
			perf.commandYields = (tonumber(perf.commandYields) or 0) + 1
		end
	end
	state.lastYield = os.clock()
end

NAmanage.IsSFWRestrictedCommand = function(data)
	return type(data) == "table"
		and type(data[4]) == "table"
		and data[4].sfwRestricted == true
end

NAStuff.SFWHiddenCommands = {
	Commands = {};
	Aliases = {};
}

NAmanage.RefreshSFWCommandRegistry = function(opts)
	opts = type(opts) == "table" and opts or {}
	const hidden = NAStuff.SFWHiddenCommands
	local changed = false

	if NAStuff.SFWMode == true then
		const commandNames = {}
		for name, data in cmds.Commands do
			if NAmanage.IsSFWRestrictedCommand(data) then
				commandNames[#commandNames + 1] = name
			end
		end
		for _, name in commandNames do
			hidden.Commands[name] = cmds.Commands[name]
			cmds.Commands[name] = nil
			changed = true
		end

		const aliasNames = {}
		for name, data in cmds.Aliases do
			if NAmanage.IsSFWRestrictedCommand(data) then
				aliasNames[#aliasNames + 1] = name
			end
		end
		for _, name in aliasNames do
			hidden.Aliases[name] = cmds.Aliases[name]
			cmds.Aliases[name] = nil
			changed = true
		end
	else
		const commandNames = {}
		for name in hidden.Commands do
			commandNames[#commandNames + 1] = name
		end
		for _, name in commandNames do
			if cmds.Commands[name] == nil then
				cmds.Commands[name] = hidden.Commands[name]
				hidden.Commands[name] = nil
				changed = true
			end
		end

		const aliasNames = {}
		for name in hidden.Aliases do
			aliasNames[#aliasNames + 1] = name
		end
		for _, name in aliasNames do
			if cmds.Aliases[name] == nil and cmds.Commands[name] == nil then
				cmds.Aliases[name] = hidden.Aliases[name]
				hidden.Aliases[name] = nil
				changed = true
			end
		end
	end

	if changed and type(NAmanage.invalidateCommandBuild) == "function" then
		NAmanage.invalidateCommandBuild()
	end
	if changed and opts.refresh ~= false and type(NAgui) == "table" and type(NAgui.loadCMDS) == "function" then
		pcall(NAgui.loadCMDS, { force = true })
	end
	return changed
end

NAmanage.SetSFWMode = function(enabled, opts)
	opts = type(opts) == "table" and opts or {}
	NAStuff.SFWMode = enabled ~= false
	if opts.save ~= false and type(NAmanage.NASettingsSet) == "function" then
		pcall(NAmanage.NASettingsSet, "sfwMode", NAStuff.SFWMode)
	end
	NAmanage.RefreshSFWCommandRegistry({ refresh = opts.refresh ~= false })
	if opts.notify == true then
		DoNotif("SFW Mode "..(NAStuff.SFWMode and "Enabled" or "Disabled"), 2)
	end
	return NAStuff.SFWMode
end

cmd.add = function(aliases, info, func, requiresArguments, meta)
	if type(requiresArguments) == "table" and meta == nil then
		meta = requiresArguments
		requiresArguments = nil
	end

	if requiresArguments == nil then
		requiresArguments = NAmanage.inferRequiresArguments(info, aliases) or false
	end

	meta = type(meta) == "table" and meta or {}

	if type(aliases) ~= "table" or #aliases == 0 then
		return
	end

	const autoSuffix = cmds._skipAutoSuffix ~= true
	const seen = {}
	const normalized = {}
	local renamed = false

	for _, aliasName in aliases do
		if type(aliasName) == "string" and aliasName ~= "" then
			local finalName = aliasName
			if autoSuffix then
				local uniqueName, didRename = NAmanage.makeUniqueAlias(aliasName, seen)
				if uniqueName then
					finalName = uniqueName
				end
				if didRename then
					renamed = true
				end
			else
				finalName = tostring(aliasName)
			end
			const lowerFinal = Lower(finalName)
			if not seen[lowerFinal] then
				seen[lowerFinal] = true
				Insert(normalized, finalName)
			end
		end
	end

	if #normalized == 0 then
		return
	end

	const primary = normalized[1]
	const primaryLower = primary and primary:lower() or nil
	local infoTable = info
	if renamed and type(info) == "table" then
		infoTable = {
			Format("%s [renamed to %s]", tostring(info[1] or primary), tostring(primary)),
			tostring(info[2] or "")
		}
	end
	if meta.patched then
		infoTable = NAmanage.ensurePatchedInfo(infoTable)
	end
	const data = {func, infoTable, requiresArguments, meta}
	local commandTarget = cmds.Commands
	local aliasTarget = cmds.Aliases
	if meta.sfwRestricted == true and NAStuff.SFWMode == true then
		commandTarget = NAStuff.SFWHiddenCommands.Commands
		aliasTarget = NAStuff.SFWHiddenCommands.Aliases
	end
	if primaryLower then
		if not commandTarget[primaryLower] then
			commandcount += 1
		end
		commandTarget[primaryLower] = data
	end

	for index = 2, #normalized do
		const aliasName = normalized[index]
		if type(aliasName) == "string" and aliasName ~= "" then
			aliasTarget[Lower(aliasName)] = data
		end
	end
	if type(NAmanage.invalidateCommandBuild) == "function" then
		NAmanage.invalidateCommandBuild()
	end
	if type(NAmanage.StartupCommandBudgetStep) == "function" then
		NAmanage.StartupCommandBudgetStep()
	end
end

cmd.addRestricted = function(aliases, info, func, requiresArguments, meta)
	if type(requiresArguments) == "table" and meta == nil then
		meta = requiresArguments
		requiresArguments = nil
	end
	meta = type(meta) == "table" and meta or {}
	meta.sfwRestricted = true
	return cmd.add(aliases, info, func, requiresArguments, meta)
end

cmd.addPatched = function(aliases, info, func, requiresArguments)
	return cmd.add(aliases, NAmanage.ensurePatchedInfo(info), NAmanage.wrapPatchedFunc(func), requiresArguments, { patched = true })
end

NAmanage._unloadCleanups = type(NAmanage._unloadCleanups) == "table" and NAmanage._unloadCleanups or {}

NAmanage.RegisterUnloadCleanup = function(key, callback, priority)
	if type(key) ~= "string" or key == "" or type(callback) ~= "function" then
		return false
	end
	NAmanage._unloadCleanups[key] = {
		callback = callback,
		priority = tonumber(priority) or 0,
	}
	return true
end

NAmanage.UnregisterUnloadCleanup = function(key)
	if type(key) == "string" then
		NAmanage._unloadCleanups[key] = nil
	end
end
