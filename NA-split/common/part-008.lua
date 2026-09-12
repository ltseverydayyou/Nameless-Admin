NAmanage.LoadPlugins = function(opts)
	opts = opts or {}
	const silent = opts.silent == true
	const forceNotify = opts.forceNotify == true
	if opts.startup == true and NAStuff and NAStuff.PluginAutoLoad == false then
		return true
	end
	if not CustomFunctionSupport then
		return true
	end

	const iyCallCtx = { args = nil, speaker = nil }

	const pluginDirNA = NAfiles.NAPLUGINFILEPATH
	const pluginDirIY = NAfiles.NAIYPLUGINFILEPATH
	const function ensureDir(dir, label)
		if not (isfolder and isfolder(dir)) then
			local ok, err = pcall(makefolder, dir)
			if not ok then
				NAmanage.loaderWarn(label, 'failed to ensure folder: '..tostring(err))
				return false
			end
		end
		return true
	end

	if not ensureDir(pluginDirNA, 'Plugins') then
		return false
	end
	if not ensureDir(pluginDirIY, 'PluginsIY') then
		return false
	end

	const function formatInfo(aliases, argsHint)
		const main = aliases[1]
		const extras = {}
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
					if #buf > 0 then out[#out+1] = buf; buf = "" end
				else
					buf = buf..ch
				end
			end
		end
		if #buf > 0 then out[#out+1] = buf end
		return out
	end
	const function fetchRem(url, method)
		if type(url) ~= "string" or url == "" then
			return nil
		end
		local ok, result = NAmanage.HttpGet(url, {
			noCache = method == "HttpGetAsync" and nil or true,
			timeout = 10,
		})
		if ok and type(result) == "string" and result ~= "" then
			return result
		end
		return nil
	end

	const function stripPluginScanText(content)
		content = tostring(content or "")
		const out = {}
		local i = 1
		const len = #content
		while i <= len do
			const ch = Sub(content, i, i)
			const two = Sub(content, i, i + 1)
			if two == "--" then
				if Sub(content, i + 2, i + 3) == "[[" then
					const closeAt = Find(content, "]]", i + 4, true)
					i = closeAt and (closeAt + 2) or (len + 1)
				else
					const nl = Find(content, "\n", i + 2, true)
					i = nl and (nl + 1) or (len + 1)
				end
			out[#out + 1] = " "
		elseif two == "[[" then
				const closeAt = Find(content, "]]", i + 2, true)
				i = closeAt and (closeAt + 2) or (len + 1)
			out[#out + 1] = " "
		elseif ch == "'" or ch == '"' then
				const q = ch
			i += 1
				while i <= len do
					const c = Sub(content, i, i)
					if c == "\\" then
						i += 2
					elseif c == q then
						i += 1
						break
					else
						i += 1
					end
				end
			out[#out + 1] = " "
		else
			out[#out + 1] = ch
			i += 1
		end
		end
		return Concat(out)
	end

	const function hasNAPluginCommandAPI(content)
		if type(content) ~= "string" then
			return false
		end
		const scan = stripPluginScanText(content)
		const lowerTxt = Lower(scan)
		if lowerTxt:find("cmdpluginadd", 1, true) then
			return true
		end
		if lowerTxt:find("adduserbutton", 1, true)
			or lowerTxt:find("addcommandbutton", 1, true)
			or lowerTxt:find("addmobilebutton", 1, true)
			or lowerTxt:find("addtogglebutton", 1, true)
			or lowerTxt:find("removeuserbutton", 1, true)
			or lowerTxt:find("clearuserbuttons", 1, true)
			or lowerTxt:find("buttononrun", 1, true)
			or lowerTxt:find("userbuttononrun", 1, true)
			or lowerTxt:find(":%s*userbutton%s*%(")
			or lowerTxt:find(":%s*buttononrun%s*%(")
			or lowerTxt:find(":%s*togglebutton%s*%(") then
			return true
		end
		const hasBuilderRoot = lowerTxt:find("naplugin%s*%(")
			or lowerTxt:find("plugin%s*%.%s*new%s*%(")
			or lowerTxt:find("plugin%s*%.%s*create%s*%(")
			or lowerTxt:find("plugin%s*%(")
		const hasBuilderCmd = lowerTxt:find(":%s*cmd%s*%(")
			or lowerTxt:find(":%s*command%s*%(")
			or lowerTxt:find(":%s*addcommand%s*%(")
		if hasBuilderRoot and hasBuilderCmd then
			return true
		end
		if lowerTxt:find("command%s*%(") or lowerTxt:find("cmdplugin%s*%(") then
			return true
		end
		if lowerTxt:find("return%s*{") and lowerTxt:find("commands%s*=") then
			return true
		end
		return false
	end

	const function isNAPlugin(content)
		if type(content) ~= "string" then
			return false
		end
		if hasNAPluginCommandAPI(content) then
			return true
		end
		const seenRemote = {}
		const loadPat = "loadstring%s*%(%s*game[:%.]([%w_]+)%s*%(%s*(['\"])(.-)%2"
		for method, _, url in content:gmatch(loadPat) do
			if url and url ~= "" and not seenRemote[url] then
				const methodLow = method and method:lower() or ""
				if methodLow == "httpget" or methodLow == "httpgetasync" then
					seenRemote[url] = true
					const remote = fetchRem(url, method)
					if remote and hasNAPluginCommandAPI(remote) then
						return true
					end
				end
			end
		end
		return false
	end

	const function isIYPlugin(content)
		if type(content) ~= "string" then
			return false
		end
		const lowerTxt = Lower(stripPluginScanText(content))
		if lowerTxt:find("pluginname", 1, true) and lowerTxt:find("commands", 1, true) then
			return true
		end
		if lowerTxt:find("plugindescription", 1, true) and lowerTxt:find("commands", 1, true) then
			return true
		end
		return false
	end

	const function appendIYCommands(out, iyPlugin)
		if type(out) ~= "table" or type(iyPlugin) ~= "table" then
			return
		end
		const commands = iyPlugin.Commands or iyPlugin.commands
		if type(commands) ~= "table" then
			return
		end

		const function pushCommand(nameKey, cmdDef)
			if type(cmdDef) ~= "table" then
				return
			end
			const listName = cmdDef.ListName or cmdDef.Name or nameKey
			if type(listName) ~= "string" or listName == "" then
				return
			end

			const iyFunc = cmdDef.Function or cmdDef.Callback
			if type(iyFunc) ~= "function" then
				return
			end

			const seen = {}
			const aliases = {}
			const function addAlias(a)
				if type(a) ~= "string" then
					return
				end
				local added = false
				for part in a:gmatch("[^/,|]+") do
					const trimmed = part:match("^%s*(.-)%s*$")
					if trimmed and trimmed ~= "" then
						const low = trimmed:lower()
						if not seen[low] then
							seen[low] = true
							Insert(aliases, trimmed)
						end
						added = true
					end
				end
				if not added and a ~= "" then
					const low = a:lower()
					if not seen[low] then
						seen[low] = true
						Insert(aliases, a)
					end
				end
			end

			addAlias(listName)
			addAlias(nameKey)
			const extra = cmdDef.Aliases
			if type(extra) == "table" then
				for _, a in extra do
					addAlias(a)
				end
			elseif type(extra) == "string" then
				addAlias(extra)
			end

			const argsHint = cmdDef.ArgsHint or cmdDef.Args or cmdDef.Arguments or ""
			const info = cmdDef.Description or cmdDef.Info or iyPlugin.PluginDescription or iyPlugin.Description or "No description"
			const requires = cmdDef.RequiresArguments or cmdDef.RequiresArgs or false
			local overrideAliases = cmdDef.OverrideAliases
			if overrideAliases == nil then overrideAliases = cmdDef.Override end
			if overrideAliases == nil then overrideAliases = cmdDef.ReplaceExisting end
			if overrideAliases == nil then overrideAliases = iyPlugin.OverrideAliases end
			if overrideAliases == nil then overrideAliases = iyPlugin.Override end
			const overrideText = tostring(overrideAliases or ""):lower()
			const overrideState = overrideAliases == true or overrideText == "true" or overrideText == "yes" or overrideText == "1"

			Insert(out, {
				Aliases = aliases,
				ArgsHint = (type(argsHint) == "string") and argsHint or "",
				Info = (type(info) == "string") and info or tostring(info),
				Function = function(...)
					const args = { ... }
					iyCallCtx.args = args
					iyCallCtx.speaker = LocalPlayer
					local ok, res = pcall(iyFunc, args, LocalPlayer)
					iyCallCtx.args = nil
					iyCallCtx.speaker = nil
					if not ok then
						error(res)
					end
					return res
				end,
				RequiresArguments = requires and true or false,
				OverrideAliases = overrideState,
			})
		end

		if #commands > 0 then
			for _, cmdDef in commands do
				pushCommand(cmdDef and (cmdDef.ListName or cmdDef.Name), cmdDef)
			end
			return
		end

		const keys = {}
		for k, v in commands do
			if type(v) == "table" then
				Insert(keys, k)
			end
		end
		table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
		for _, k in keys do
			pushCommand(k, commands[k])
		end
	end

	NAmanage._pluginCommandRecords = NAmanage._pluginCommandRecords or {}
	NAmanage._pluginCommandSources = NAmanage._pluginCommandSources or {}

	const function normKey(path)
		if not path then
			return ""
		end
		const normalized = path:gsub("\\","/")
		return Lower(normalized)
	end

	const function restoreDisplacedAliases(key, subset)
		const record = NAmanage._pluginCommandRecords[key]
		const displaced = subset or (record and record.displaced)
		if type(displaced) ~= "table" then
			return false
		end
		local changed = false
		const sourceMap = NAmanage._pluginCommandSources or {}
		for alias, saved in displaced do
			if type(saved) == "table" then
				const source = sourceMap[alias]
				const sourceKey = cmds.PluginSources and cmds.PluginSources[alias] or nil
				const occupiedByOtherPlugin = (type(source) == "table" and source.key and source.key ~= key)
					or (sourceKey ~= nil and sourceKey ~= key)
				if not occupiedByOtherPlugin then
					if cmds.Commands[alias] == nil and saved.command ~= nil then
						cmds.Commands[alias] = saved.command
						changed = true
					end
					if cmds.Aliases[alias] == nil and saved.alias ~= nil then
						cmds.Aliases[alias] = saved.alias
						changed = true
					end
				end
			end
			if subset and record and type(record.displaced) == "table" then
				record.displaced[alias] = nil
			end
		end
		if subset and record then
			const hasAliases = type(record.aliases) == "table" and next(record.aliases) ~= nil
			const hasDisplaced = type(record.displaced) == "table" and next(record.displaced) ~= nil
			if not hasAliases and not hasDisplaced then
				NAmanage._pluginCommandRecords[key] = nil
			end
		end
		return changed
	end

	const function UnplugCmd(key)
		if not key then
			return false
		end
		const record = NAmanage._pluginCommandRecords[key]
		const aliases = {}
		if record and type(record.aliases) == "table" then
			for alias, data in record.aliases do
				aliases[alias] = data
			end
		end
		if type(NAmanage._pluginCommandSources) == "table" then
			for alias, src in NAmanage._pluginCommandSources do
				if type(src) == "table" and src.key == key then
					aliases[alias] = src.data
				end
			end
		end
		if cmds.PluginSources then
			for alias, srcKey in cmds.PluginSources do
				if srcKey == key then
					aliases[alias] = aliases[alias] or cmds.Commands[alias] or cmds.Aliases[alias]
				end
			end
		end
		local hasAlias = false
		for _ in aliases do
			hasAlias = true
			break
		end
		if not record and not hasAlias then
			return false
		end
		local changed = false
		for alias, data in aliases do
			if data == nil or cmds.Commands[alias] == data then
				if cmds.Commands[alias] ~= nil then
					cmds.Commands[alias] = nil
					changed = true
				end
			end
			if data == nil or cmds.Aliases[alias] == data then
				if cmds.Aliases[alias] ~= nil then
					cmds.Aliases[alias] = nil
					changed = true
				end
			end
			if cmds.PluginSources and cmds.PluginSources[alias] ~= nil then
				cmds.PluginSources[alias] = nil
				changed = true
			end
			if type(NAmanage._pluginCommandSources) == "table" and NAmanage._pluginCommandSources[alias] ~= nil then
				NAmanage._pluginCommandSources[alias] = nil
				changed = true
			end
		end
		if restoreDisplacedAliases(key) then
			changed = true
		end
		NAmanage._pluginCommandRecords[key] = nil
		if type(NAmanage.invalidateCommandBuild) == "function" then
			pcall(NAmanage.invalidateCommandBuild)
		end
		return changed
	end

	const function AddCmdPlug(key, aliases, dataRef)
		if not key or not dataRef or type(aliases) ~= "table" then
			return
		end
		local record = NAmanage._pluginCommandRecords[key]
		if not record then
			record = { aliases = {}, displaced = {} }
			NAmanage._pluginCommandRecords[key] = record
		else
			record.aliases = record.aliases or {}
			record.displaced = record.displaced or {}
		end
		cmds.PluginSources = cmds.PluginSources or {}
		const sourceMap = NAmanage._pluginCommandSources
		for _, alias in aliases do
			if type(alias) == "string" and alias ~= "" then
				const lowerAlias = alias:lower()
				record.aliases[lowerAlias] = dataRef
				cmds.PluginSources[lowerAlias] = key
				if type(sourceMap) == "table" then
					sourceMap[lowerAlias] = { key = key, data = dataRef }
				end
			end
		end
	end

	const function formatAliasSwapNote(replacements)
		if not replacements then
			return nil
		end
		const parts = {}
		for from, to in replacements do
			parts[#parts + 1] = tostring(from).."→"..tostring(to)
		end
		if #parts == 0 then
			return nil
		end
		table.sort(parts)
		return "Conflicting aliases remapped: "..Concat(parts, ", ")
	end

	const function formatAliasOverrideNote(overrides)
		if type(overrides) ~= "table" then
			return nil
		end
		const parts = {}
		for _, displayName in overrides do
			parts[#parts + 1] = tostring(displayName)
		end
		if #parts == 0 then
			return nil
		end
		table.sort(parts)
		return "Overridden base aliases: "..Concat(parts, ", ")
	end

	const function makeUniqueAliases(key, aliases, allowCoreOverride)
		const out = {}
		const replaced = {}
		const overridden = {}
		const seenLocal = {}
		const sourceMap = NAmanage._pluginCommandSources or {}

		const function aliasConflict(lowerAlias, thisKey)
			const src = sourceMap[lowerAlias]
			const sourceKey = cmds.PluginSources and cmds.PluginSources[lowerAlias] or nil
			if (type(src) == "table" and src.key and src.key ~= thisKey)
				or (sourceKey ~= nil and sourceKey ~= thisKey) then
				return "plugin"
			end
			const commandData = cmds.Commands and cmds.Commands[lowerAlias] or nil
			const aliasData = cmds.Aliases and cmds.Aliases[lowerAlias] or nil
			if commandData ~= nil or aliasData ~= nil then
				if cmds.NASAVEDALIASES and cmds.NASAVEDALIASES[lowerAlias] ~= nil then
					return "saved"
				end
				if type(src) == "table" and src.key == thisKey then
					return nil
				end
				if sourceKey == thisKey then
					return nil
				end
				return "core"
			end
			return nil
		end

		const function reserveAlias(baseAlias)
			local counter = 1
			local attempt = "plugin:"..baseAlias
			local lower = attempt:lower()
			while aliasConflict(lower, key) ~= nil do
				counter += 1
				attempt = "plugin"..tostring(counter)..":"..baseAlias
				lower = attempt:lower()
			end
			return attempt, lower
		end

		for _, alias in aliases or {} do
			const name = tostring(alias or "")
			if name ~= "" then
				const lower = name:lower()
				if not seenLocal[lower] then
					seenLocal[lower] = true
					const conflict = aliasConflict(lower, key)
					if conflict == "core" and allowCoreOverride == true then
						overridden[lower] = name
						out[#out + 1] = name
					elseif conflict ~= nil then
						local newAlias, newLower = reserveAlias(name)
						replaced[name] = newAlias
						out[#out + 1] = newAlias
						seenLocal[newLower] = true
					else
						out[#out + 1] = name
					end
				end
			end
		end

		return out, replaced, overridden
	end

	const function displaceCoreAliases(key, aliases)
		if type(aliases) ~= "table" or next(aliases) == nil then
			return nil
		end
		local record = NAmanage._pluginCommandRecords[key]
		if not record then
			record = { aliases = {}, displaced = {} }
			NAmanage._pluginCommandRecords[key] = record
		else
			record.aliases = record.aliases or {}
			record.displaced = record.displaced or {}
		end
		const taken = {}
		const sourceMap = NAmanage._pluginCommandSources or {}
		for lowerAlias in aliases do
			const source = sourceMap[lowerAlias]
			const sourceKey = cmds.PluginSources and cmds.PluginSources[lowerAlias] or nil
			const savedAlias = cmds.NASAVEDALIASES and cmds.NASAVEDALIASES[lowerAlias] or nil
			if not (type(source) == "table" and source.key and source.key ~= key)
				and not (sourceKey ~= nil and sourceKey ~= key)
				and savedAlias == nil then
				const commandData = cmds.Commands[lowerAlias]
				const aliasData = cmds.Aliases[lowerAlias]
				if commandData ~= nil or aliasData ~= nil then
					const displaced = {
						command = commandData,
						alias = aliasData,
					}
					record.displaced[lowerAlias] = displaced
					taken[lowerAlias] = displaced
					cmds.Commands[lowerAlias] = nil
					cmds.Aliases[lowerAlias] = nil
				end
			end
		end
		return taken
	end

	const loadedSumm = {}
	const runMeta = {}
	const seenKeys = {}

	const function enumerate(dir, label, extPat)
		local okList, files = pcall(listfiles, dir)
		if not okList or type(files) ~= "table" then
			const errMsg = okList and "invalid directory listing" or tostring(files)
			NAmanage.loaderWarn(label, "failed to enumerate: "..errMsg)
			return nil
		end
		const out = {}
		for _, p in files do
			if type(p) == "string" and Lower(p):match(extPat) then
				Insert(out, p)
			end
		end
		return out
	end

	const filesNA = enumerate(pluginDirNA, "Plugins", "%.na$") or {}
	const filesIY = enumerate(pluginDirIY, "PluginsIY", "%.iy$") or {}

	NAmanage.PluginCleanupEnv = NAmanage.PluginCleanupEnv or function(key)
		const states = NAmanage and NAmanage._pluginEnvState
		const store = type(states) == "table" and states[key] or nil
		if type(store) ~= "table" then
			return
		end
		const seen = {}
		const function try(fn, owner)
			if type(fn) == "function" and not seen[fn] then
				seen[fn] = true
				pcall(fn, owner)
			end
		end
		const function scan(bucket)
			if type(bucket) ~= "table" then
				return
			end
			try(rawget(bucket, "cleanup"), bucket)
			try(rawget(bucket, "Cleanup"), bucket)
			try(rawget(bucket, "destroy"), bucket)
			try(rawget(bucket, "Destroy"), bucket)
			try(rawget(bucket, "unload"), bucket)
			try(rawget(bucket, "Unload"), bucket)
			for _, value in bucket do
				if type(value) == "table" then
					try(rawget(value, "cleanup"), value)
					try(rawget(value, "Cleanup"), value)
					try(rawget(value, "destroy"), value)
					try(rawget(value, "Destroy"), value)
					try(rawget(value, "unload"), value)
					try(rawget(value, "Unload"), value)
				end
			end
		end
		scan(store.globals)
		scan(store.shared)
	end

	const function loadPluginFile(file, mode)
		const baseName = file and (file:match("[^\\/]+$") or file) or ""
		if mode == "iy" and type(baseName) == "string" and baseName:lower() == "iy_fe.iy" then
			return
		end

		const pluginKey = normKey(file)
		seenKeys[pluginKey] = true
		UnplugCmd(pluginKey)
		if NAmanage.PluginCleanupEnv then
			pcall(NAmanage.PluginCleanupEnv, pluginKey)
		end

		const disabled = NAmanage.PluginIsDisabled and NAmanage.PluginIsDisabled(file)
		runMeta[pluginKey] = {
			path = file,
			name = baseName,
			kind = mode == "iy" and ".iy" or ".na",
			enabled = not disabled,
			loaded = false,
			commands = {},
		}
		if NAmanage.PluginUIClear then
			pcall(NAmanage.PluginUIClear, pluginKey)
		end
		if disabled then
			return
		end

		local success, content = NACaller(readfile, file)
		if not (success and content) then
			DoWindow("[Plugin Read Error] Failed to read '"..file.."'")
			return
		end

		if mode == "na" and not isNAPlugin(content) then
			DoWindow("skipped '"..file.."' (no plugin command API found)")
			return
		end

		local func, loadErr = loadstring(content)
		if not func then
			DoWindow("[Plugin Load Error] '"..file.."': "..tostring(loadErr))
			return
		end

		NAmanage._pluginEnvState = NAmanage._pluginEnvState or {}
		local pluginStore = NAmanage._pluginEnvState[pluginKey]
		if type(pluginStore) ~= "table" then
			pluginStore = {}
			NAmanage._pluginEnvState[pluginKey] = pluginStore
		end
		const colPlugins = {}
		const proxyEnv = {}
		const pluginShared = type(pluginStore.shared) == "table" and pluginStore.shared or {}
		const pluginGlobals = type(pluginStore.globals) == "table" and pluginStore.globals or {}
		pluginStore.shared = pluginShared
		pluginStore.globals = pluginGlobals
		pluginStore.env = proxyEnv
		const baseEnv = getfenv()
		local pluginApi = nil
		const pluginNil = {}
		const pluginEnvShims = {}
		const pluginPrivateEnv = {}
		const pluginBaseGlobals = {}
		const pluginBlockedGlobals = {
			_G = true;
			shared = true;
			getgenv = true;
			getfenv = true;
			setfenv = true;
			game = true;
			["workspace"] = true;
			SafeGetService = true;
			ServiceResolver = true;
			__NAServiceResolver = true;
			__NAUIProtector = true;
			__lt = true;
			NAmanage = true;
			NAStuff = true;
			NAindex = true;
			NAjobs = true;
			NAfiles = true;
			NAlib = true;
			cmds = true;
			cmd = true;
		}
		const function _plugMarkPrivate(env)
			if type(env) == "table" then
				pluginPrivateEnv[env] = true
			end
		end
		_plugMarkPrivate(baseEnv)
		_plugMarkPrivate(_na_env)
		_plugMarkPrivate(_na_shared)
		_plugMarkPrivate(_na_boot and _na_boot.runtimeEnv)
		_plugMarkPrivate(_na_boot and _na_boot.hostEnv)
		_plugMarkPrivate(_na_boot and _na_boot.privateRoot)
		const function _plugBase(name, value)
			if type(name) == "string" and value ~= nil then
				pluginBaseGlobals[name] = value
			end
		end
		for _, name in {
			"assert", "error", "ipairs", "next", "pairs", "pcall", "xpcall", "select", "tonumber", "tostring", "type", "typeof",
			"unpack", "rawequal", "rawget", "rawset", "setmetatable", "getmetatable", "print", "warn", "require",
			"wait", "spawn", "delay", "tick", "time", "elapsedTime", "gcinfo", "collectgarbage", "settings", "UserSettings", "version",
			"cloneref", "compareinstances", "hookfunction", "hookmetamethod", "getnamecallmethod", "setnamecallmethod", "newcclosure", "checkcaller", "getthreadidentity", "getidentity", "get_thread_identity", "setthreadidentity", "setidentity", "set_thread_identity",
			"iscclosure", "islclosure", "isexecutorclosure", "isourclosure", "restorefunction", "clonefunction", "getconnections", "firesignal", "replicatesignal",
			"firetouchinterest", "fireproximityprompt", "fireclickdetector", "getnilinstances", "getinstances", "gethui", "getcustomasset", "getgc", "filtergc",
			"setclipboard", "toclipboard", "queue_on_teleport", "queueonteleport", "identifyexecutor", "isfile", "isfolder", "readfile", "writefile", "appendfile", "listfiles", "makefolder", "delfile", "delfolder",
			"isrbxactive", "keypress", "keyrelease", "keytap", "mouse1click", "mouse1press", "mouse1release", "mouse2click", "mouse2press", "mouse2release", "mousemoveabs", "mousemoverel", "mousescroll",
		} do
			_plugBase(name, baseEnv and baseEnv[name])
		end
		for _, name in {
			"math", "string", "table", "task", "coroutine", "os", "utf8", "bit32", "debug", "Enum", "Instance", "Color3", "BrickColor",
			"Vector2", "Vector3", "Vector2int16", "Vector3int16", "CFrame", "UDim", "UDim2", "Rect", "Ray", "Region3", "Region3int16",
			"NumberRange", "NumberSequence", "NumberSequenceKeypoint", "ColorSequence", "ColorSequenceKeypoint", "TweenInfo", "PhysicalProperties",
			"RaycastParams", "OverlapParams", "Random", "DateTime", "Faces", "Axes", "Font", "PathWaypoint", "DockWidgetPluginGuiInfo", "buffer", "Drawing", "DrawingImmediate", "WebSocket", "crypt",
		} do
			_plugBase(name, baseEnv and baseEnv[name])
		end

		const function _plugResolveGlobal(...)
			for i = 1, select("#", ...) do
				const name = select(i, ...)
				local value = baseEnv and baseEnv[name] or nil
				if value == nil and _na_boot and type(_na_boot.hostEnv) == "table" then
					value = _na_boot.hostEnv[name]
				end
				if value ~= nil then
					return value
				end
			end
			return nil
		end

		const pluginSetHiddenProperty = _plugResolveGlobal(
			"sethiddenproperty", "set_hidden_property", "sethiddenprop", "set_hidden_prop"
		)
		if type(pluginSetHiddenProperty) == "function" then
			pluginBaseGlobals.sethiddenproperty = pluginSetHiddenProperty
			pluginBaseGlobals.set_hidden_property = pluginSetHiddenProperty
			pluginBaseGlobals.sethiddenprop = pluginSetHiddenProperty
			pluginBaseGlobals.set_hidden_prop = pluginSetHiddenProperty
			pluginBaseGlobals.sethidden = pluginSetHiddenProperty
		end

		const pluginGetHiddenProperty = _plugResolveGlobal(
			"gethiddenproperty", "get_hidden_property", "gethiddenprop", "get_hidden_prop"
		)
		if type(pluginGetHiddenProperty) == "function" then
			pluginBaseGlobals.gethiddenproperty = pluginGetHiddenProperty
			pluginBaseGlobals.get_hidden_property = pluginGetHiddenProperty
			pluginBaseGlobals.gethiddenprop = pluginGetHiddenProperty
			pluginBaseGlobals.get_hidden_prop = pluginGetHiddenProperty
			pluginBaseGlobals.gethidden = pluginGetHiddenProperty
		end

		for _, name in {"setscriptable", "isscriptable"} do
			const value = _plugResolveGlobal(name)
			if type(value) == "function" then
				pluginBaseGlobals[name] = value
			end
		end

		const function _plugCleanEnv(env)
			if type(env) ~= "table" or pluginPrivateEnv[env] then
				return proxyEnv
			end
			return env
		end
		pluginEnvShims._G = proxyEnv
		pluginEnvShims.shared = pluginShared
		pluginEnvShims.getgenv = function()
			return proxyEnv
		end
		pluginEnvShims.getfenv = function(target)
			if target == nil or type(target) == "number" then
				return proxyEnv
			end
			const hostGetfenv = baseEnv and baseEnv.getfenv or getfenv
			if type(hostGetfenv) == "function" then
				local ok, env = pcall(hostGetfenv, target)
				if ok then
					return _plugCleanEnv(env)
				end
			end
			return proxyEnv
		end
		pluginEnvShims.setfenv = function(fn, env)
			const hostSetfenv = baseEnv and baseEnv.setfenv or setfenv
			if type(hostSetfenv) == "function" and type(fn) == "function" then
				return hostSetfenv(fn, _plugCleanEnv(env))
			end
			return fn
		end

		const function _runCmd(...)
			const runner = cmd and (cmd.run or cmd.Run)
			if not runner then return nil, "cmd.run not available" end
			const n = select("#", ...)
			local argv
			if n == 1 then
				const a = ...
				if type(a) == "table" then
					argv = a
				elseif type(a) == "string" then
					argv = splitArgs(a)
				else
					return nil, "invalid input to runCommand"
				end
			else
				argv = {}
				for i = 1, n do
					const v = select(i, ...)
					argv[#argv+1] = type(v) == "string" and v or tostring(v)
				end
			end
			local ok1, res1 = NACaller(runner, argv)
			if ok1 then return res1 end
			local ok2, res2 = NACaller(runner, Concat(argv, " "))
			if ok2 then return res2 end
			return nil, res2
		end

		const function _pluginRequest(opts)
			const rq = resolvedRequest or opt.NAREQUEST
			if type(rq) ~= "function" then
				return { StatusCode = 0, Body = "HTTP unavailable" }
			end
			if type(opts) == "table" then
				if type(opts.HttpRequestType) == "boolean" then
					opts = table.clone and table.clone(opts) or { }
					if not table.clone then
						for k, v in opts do opts[k] = v end
					end
					opts.HttpRequestType = nil
				end
			end
			local ok, res = pcall(rq, opts)
			if ok then
				return res
			end
			return { StatusCode = 0, Body = tostring(res) }
		end

		const pluginServiceNames = setmetatable({
			Workspace = true;
			Players = true;
			CoreGui = true;
			ReplicatedFirst = true;
			ReplicatedStorage = true;
			Lighting = true;
			StarterGui = true;
			StarterPack = true;
			StarterPlayer = true;
			ServerScriptService = true;
			ServerStorage = true;
			Teams = true;
			Debris = true;
			Stats = true;
			Chat = true;
			Selection = true;
			NetworkClient = true;
			NetworkServer = true;
			DebugSettings = true;
			ScriptContext = true;
			KeyframeSequenceProvider = true;
			VirtualInputManager = true;
			VirtualUser = true;
		}, {
			__index = function(_, name)
				return type(name) == "string" and (name:match("Service$") ~= nil or name:match("Provider$") ~= nil)
			end
		})
		const pluginServiceAliases = {
			["workspace"] = "Workspace";
			COREGUI = "CoreGui";
			CoreGui = "CoreGui";
			UIS = "UserInputService";
		}
		const rawGame = game
		const pluginServiceCache = {}
		const function _plugServiceName(name)
			if type(name) ~= "string" then
				return nil
			end
			name = pluginServiceAliases[name] or name
			if not name:match("^[%a_][%w_]*$") then
				return nil
			end
			return name
		end
		const function _plugGetRawService(name)
			name = _plugServiceName(name)
			if not name then
				return nil
			end
			if type(__lt) == "table" and type(__lt.gs) == "function" then
				local ok, svc = pcall(__lt.gs, name)
				if ok and typeof(svc) == "Instance" then
					return svc
				end
			end
			return nil
		end
		const function _plugGetService(name)
			name = _plugServiceName(name)
			if not name then
				return nil
			end
			if pluginServiceCache[name] ~= nil then
				return pluginServiceCache[name]
			end
			local svc
			if type(__lt) == "table" then
				if type(cloneref) == "function" and type(__lt.cs) == "function" then
					local ok, resolved = pcall(__lt.cs, name, cloneref)
					if ok and typeof(resolved) == "Instance" then
						svc = resolved
					end
				end
				if not svc and type(__lt.gs) == "function" then
					local ok, resolved = pcall(__lt.gs, name)
					if ok and typeof(resolved) == "Instance" then
						svc = resolved
					end
				end
			end
			if not svc then
				const rawSvc = _plugGetRawService(name)
				if rawSvc then
					if type(__lt) == "table" and type(__lt.cv) == "function" then
						local okRef, cloned = pcall(__lt.cv, rawSvc)
						if okRef and typeof(cloned) == "Instance" then
							svc = cloned
						end
					end
					svc = svc or rawSvc
				end
			end
			if svc then
				pluginServiceCache[name] = svc
			end
			return svc
		end
		const pluginResolverFacade = {}
		pluginResolverFacade.gs = function(selfOrName, maybeName)
			local name = maybeName or selfOrName
			return _plugGetRawService(name)
		end
		pluginResolverFacade.cs = function(selfOrName, maybeName)
			local name = maybeName or selfOrName
			return _plugGetService(name)
		end
		pluginResolverFacade.GetService = pluginResolverFacade.cs
		pluginResolverFacade.getService = pluginResolverFacade.cs
		pluginResolverFacade.GetRawService = pluginResolverFacade.gs
		pluginResolverFacade.getRawService = pluginResolverFacade.gs
		proxyEnv.ServiceResolver = pluginResolverFacade
		proxyEnv.SafeGetService = pluginResolverFacade.cs

		const gameProxy = {}
		function gameProxy:GetService(serviceName)
			return _plugGetService(serviceName)
		end
		function gameProxy:FindService(serviceName)
			return _plugGetService(serviceName)
		end
		function gameProxy:FindFirstChild(name, recursive)
			return _plugGetService(name)
		end
		function gameProxy:WaitForChild(name, timeout)
			const service = _plugGetService(name)
			if service then
				return service
			end
			if timeout ~= nil then
				Wait(math.min(tonumber(timeout) or 0, 0.1))
			end
			return nil
		end
		function gameProxy:HttpGet(url, second)
			return NAmanage.HttpGetOrError(url, { noCache = type(second) == "boolean" and second or nil, timeout = 10 })
		end
		function gameProxy:HttpGetAsync(url, second)
			return NAmanage.HttpGetOrError(url, { noCache = type(second) == "boolean" and second or nil, timeout = 10 })
		end
		const pluginGameAllowedMembers = {
			PlaceId = true;
			JobId = true;
			GameId = true;
			CreatorId = true;
			CreatorType = true;
			Name = true;
			IsLoaded = true;
			Loaded = true;
		}
		setmetatable(gameProxy, {
			__index = function(_, k)
				if k == "GetService" then
					return gameProxy.GetService
				end
				if k == "FindService" then
					return gameProxy.FindService
				end
				if k == "FindFirstChild" then
					return gameProxy.FindFirstChild
				end
				if k == "WaitForChild" then
					return gameProxy.WaitForChild
				end
				if k == "HttpGet" then
					return gameProxy.HttpGet
				end
				if k == "HttpGetAsync" then
					return gameProxy.HttpGetAsync
				end
				if type(k) == "string" and (pluginServiceNames[k] or k:match("^[%a_][%w_]*$")) then
					local service = gameProxy:GetService(k)
					if service then
						return service
					end
				end
				if not pluginGameAllowedMembers[k] then
					return nil
				end
				const v = rawGame[k]
				if type(v) == "function" then
					return function(_, ...)
						return v(rawGame, ...)
					end
				end
				return v
			end
		})

		proxyEnv.cmdRun = _runCmd
		proxyEnv.RunCommand = _runCmd
		proxyEnv.runCommand = _runCmd
		if NAmanage.PluginUIFor then
			const api = NAmanage.PluginUIFor(pluginKey, baseName, mode)
			proxyEnv.NAPluginUI = api
			proxyEnv.PluginUI = api
			proxyEnv.NASettingsUI = api
		end
		proxyEnv.request = _pluginRequest
		proxyEnv.http_request = _pluginRequest
		proxyEnv.httprequest = _pluginRequest
		proxyEnv.syn = {
			request = _pluginRequest;
		}
		proxyEnv.notify = function(msg, detailOrTime, maybeTime)
			local duration = 3
			local text
			if type(detailOrTime) == "string" then
				text = tostring(msg)..": "..detailOrTime
				duration = tonumber(maybeTime) or duration
			else
				text = tostring(msg)
				duration = tonumber(detailOrTime) or duration
			end
			if DoNotif then
				DoNotif(text, duration)
			else
				warn(text)
			end
		end

		proxyEnv.DoNotif = function(text, duration, title)
			const seconds = tonumber(duration) or 3
			if type(DoNotif) == "function" then
				return DoNotif(tostring(text), seconds, type(title) == "string" and title or nil)
			end
			return proxyEnv.notify(text, seconds)
		end
		proxyEnv.Notify = proxyEnv.notify


		const function _plugTrim(v)
			return tostring(v or ""):match("^%s*(.-)%s*$") or ""
		end

		const function _plugAddAlias(list, seen, value)
			if type(list) ~= "table" or type(seen) ~= "table" then
				return
			end
			if type(value) == "table" then
				for _, sub in value do
					_plugAddAlias(list, seen, sub)
				end
				return
			end
			if type(value) ~= "string" and type(value) ~= "number" then
				return
			end
			const raw = _plugTrim(value)
			if raw == "" then
				return
			end
			for part in raw:gmatch("[^,|/]+") do
				const name = _plugTrim(part)
				if name ~= "" then
					const low = name:lower()
					if not seen[low] then
						seen[low] = true
						list[#list + 1] = name
					end
				end
			end
		end

		const function _plugAliases(...)
			const list, seen = {}, {}
			for i = 1, select("#", ...) do
				_plugAddAlias(list, seen, select(i, ...))
			end
			return list
		end

		const function _plugCopy(src)
			const out = {}
			if type(src) == "table" then
				for k, v in src do
					out[k] = v
				end
			end
			return out
		end

		const function _plugReq(v)
			if v == nil then
				return false
			end
			if type(v) == "string" then
				const low = v:lower()
				return low == "true" or low == "yes" or low == "required" or low == "1"
			end
			return v == true
		end

		const function _plugCtx()
			const ctxPlayers = _plugGetService("Players")
			const ctxLocalPlayer = ctxPlayers and ctxPlayers.LocalPlayer or nil
			const ctx = {
				Name = baseName,
				File = baseName,
				Path = file,
				Key = pluginKey,
				Mode = mode,
				UI = proxyEnv.NAPluginUI or proxyEnv.PluginUI or proxyEnv.NASettingsUI,
				Plugin = pluginApi,
				Player = ctxLocalPlayer,
				LocalPlayer = ctxLocalPlayer,
				Services = {},
				ServiceResolver = pluginResolverFacade,
			}
			setmetatable(ctx.Services, {
				__index = function(self, name)
					const svc = _plugGetService(name)
					if svc then
						rawset(self, name, svc)
					end
					return svc
				end
			})
			const function notifyFn(self, msg, duration)
				if self ~= ctx then
					duration = msg
					msg = self
				end
				return proxyEnv.notify(msg, duration)
			end
			const function runFn(self, ...)
				if self == ctx then
					return _runCmd(...)
				end
				return _runCmd(self, ...)
			end
			ctx.Notify = notifyFn
			ctx.notify = notifyFn
			ctx.Run = runFn
			ctx.run = runFn
			ctx.RunCommand = runFn
			ctx.runCommand = runFn
			ctx.Command = runFn
			ctx.command = runFn
			const function buttonFn(self, ...)
				if self == ctx then
					return NAmanage.PluginUserButtonAdd(pluginKey, baseName, ...)
				end
				return NAmanage.PluginUserButtonAdd(pluginKey, baseName, self, ...)
			end
			ctx.AddUserButton = buttonFn
			ctx.addUserButton = buttonFn
			ctx.AddButton = buttonFn
			ctx.addButton = buttonFn
			ctx.UserButton = buttonFn
			ctx.userButton = buttonFn
			ctx.MobileButton = buttonFn
			ctx.mobileButton = buttonFn
			const function removeButtonFn(self, query)
				if self == ctx then
					return NAmanage.PluginUserButtonRemove(pluginKey, query)
				end
				return NAmanage.PluginUserButtonRemove(pluginKey, self)
			end
			ctx.RemoveUserButton = removeButtonFn
			ctx.removeUserButton = removeButtonFn
			ctx.RemoveButton = removeButtonFn
			ctx.removeButton = removeButtonFn
			ctx.ClearUserButtons = function()
				return NAmanage.PluginUserButtonRemove(pluginKey)
			end
			ctx.clearUserButtons = ctx.ClearUserButtons
			ctx.IsOnMobile = IsOnMobile == true
			ctx.IsOnPC = IsOnPC == true
			ctx.IsMobile = ctx.IsOnMobile
			ctx.IsPC = ctx.IsOnPC
			ctx.NA_GRAB_BODY = NA_GRAB_BODY
			ctx.GetRoot = getRoot
			ctx.getRoot = getRoot
			ctx.GetChar = getChar
			ctx.getChar = getChar
			ctx.GetHum = getHum
			ctx.getHum = getHum
			ctx.GetTorso = getTorso
			ctx.getTorso = getTorso
			ctx.GetHead = getHead
			ctx.getHead = getHead
			return ctx
		end

		const function _plugPush(def, useCtx, sourceInfo)
			if type(def) ~= "table" then
				return false
			end
			if def._na_loaded == true then
				return true
			end
			if def[1] and type(def[1]) == "table" and def.Aliases == nil and def.aliases == nil and def.Function == nil and def.Callback == nil and def.Run == nil and def.run == nil and def.Commands == nil and def.commands == nil then
				local any = false
				for _, sub in def do
					if _plugPush(sub, useCtx, sourceInfo) then
						any = true
					end
				end
				return any
			end
			if type(def.Commands or def.commands) == "table" then
				return false
			end
			const aliases = _plugAliases(def.Aliases or def.aliases or def.Alias or def.alias or def.Names or def.names or def.Name or def.name or def.Command or def.command or def.Cmd or def.cmd or def.ListName or def[1])
			const fn = def.Function or def.Callback or def.callback or def.Run or def.run or def.Handler or def.handler or def.Execute or def.execute or def[2]
			if #aliases == 0 or type(fn) ~= "function" then
				return false
			end
			const ctxMode = useCtx == true or def.Context == true or def.WithContext == true or def.UsesContext == true or def._na_ctx == true
			local handler = fn
			if ctxMode then
				handler = function(...)
					return fn(_plugCtx(), ...)
				end
			end
			const buttonOnRun = def.ButtonOnRun or def.buttonOnRun or def.UserButtonOnRun or def.userButtonOnRun or def.CreateButtonOnRun or def.createButtonOnRun
			const removeButtonOnRun = def.RemoveButtonOnRun or def.removeButtonOnRun or def.RemoveUserButtonOnRun or def.removeUserButtonOnRun
			if buttonOnRun ~= nil or removeButtonOnRun ~= nil then
				const inner = handler
				handler = function(...)
					if removeButtonOnRun ~= nil then
						NAmanage.PluginUserButtonRemove(pluginKey, removeButtonOnRun)
					end
					if buttonOnRun ~= nil then
						const opts = type(buttonOnRun) == "table" and _plugCopy(buttonOnRun) or { Label = buttonOnRun }
						opts.Cmd1 = opts.Cmd1 or opts.Command or opts.command or (aliases and aliases[1])
						opts.Label = opts.Label or opts.label or opts.Text or opts.text or opts.Cmd1
						opts.Id = opts.Id or opts.id or opts.Label
						NAmanage.PluginUserButtonAdd(pluginKey, baseName, opts)
					end
					return inner(...)
				end
			end
			local argsHint = def.ArgsHint or def.argsHint or def.Args or def.args or def.Arguments or def.arguments or ""
			if type(argsHint) ~= "string" then
				argsHint = tostring(argsHint or "")
			end
			local info = def.Info or def.info or def.Description or def.description or def.Desc or def.desc or sourceInfo or "No description"
			if type(info) ~= "string" then
				info = tostring(info)
			end
			local req = def.RequiresArguments
			if req == nil then req = def.RequiresArgs end
			if req == nil then req = def.requiresArgs end
			if req == nil then req = def.NeedArgs end
			if req == nil then req = def.needArgs end
			if req == nil then req = def.Required end
			local overrideAliases = def.OverrideAliases
			if overrideAliases == nil then overrideAliases = def.overrideAliases end
			if overrideAliases == nil then overrideAliases = def.Override end
			if overrideAliases == nil then overrideAliases = def.override end
			if overrideAliases == nil then overrideAliases = def.ReplaceExisting end
			if overrideAliases == nil then overrideAliases = def.replaceExisting end
			if overrideAliases == nil then overrideAliases = def.TakePriority end
			if overrideAliases == nil then overrideAliases = def.takePriority end
			colPlugins[#colPlugins + 1] = {
				Aliases = aliases,
				ArgsHint = argsHint,
				Info = info,
				Function = handler,
				RequiresArguments = _plugReq(req),
				OverrideAliases = _plugReq(overrideAliases),
			}
			pcall(function()
				def._na_loaded = true
			end)
			return true
		end

		const function _plugAppend(export, useCtx)
			if type(export) ~= "table" then
				return false
			end
			if export._na_builder == true then
				local any = false
				for _, cmdDef in export._cmds or {} do
					if _plugPush(cmdDef, true, export.Description or export.Info or export.desc) then
						any = true
					end
				end
				return any
			end
			if export[1] and type(export[1]) == "table" and export.Commands == nil and export.commands == nil and export.Aliases == nil and export.aliases == nil then
				local any = false
				for _, cmdDef in export do
					if _plugPush(cmdDef, useCtx, export.Description or export.Info or export.desc) then
						any = true
					end
				end
				return any
			end
			const commands = export.Commands or export.commands
			if type(commands) == "table" then
				local any = false
				for key, cmdDef in commands do
					local normalized
					if type(cmdDef) == "function" then
						normalized = {
							Aliases = _plugAliases(type(key) == "string" and key or nil),
							Function = cmdDef,
							Info = export.Description or export.Info or export.desc or "No description",
							_na_ctx = true,
						}
					elseif type(cmdDef) == "table" then
						normalized = _plugCopy(cmdDef)
						const aliases = _plugAliases(type(key) == "string" and key or nil, normalized.Aliases or normalized.aliases or normalized.Alias or normalized.alias or normalized.Names or normalized.names or normalized.Name or normalized.name)
						normalized.Aliases = aliases
						if normalized.Info == nil and normalized.info == nil and normalized.Description == nil and normalized.description == nil and normalized.Desc == nil and normalized.desc == nil then
							normalized.Info = export.Description or export.Info or export.desc
						end
						normalized._na_ctx = normalized.Context ~= false
					end
					if normalized and _plugPush(normalized, useCtx == nil and true or useCtx, export.Description or export.Info or export.desc) then
						any = true
					end
				end
				return any
			end
			return _plugPush(export, useCtx, export.Description or export.Info or export.desc)
		end

		const _plugMethods = {}
		function _plugMethods:Command(...)
			const cmdDef = {
				Aliases = _plugAliases(...),
				Info = self.Description or self.Info or "No description",
				_na_ctx = true,
			}
			self._cmds[#self._cmds + 1] = cmdDef
			self._active = cmdDef
			return self
		end
		_plugMethods.command = _plugMethods.Command
		_plugMethods.Cmd = _plugMethods.Command
		_plugMethods.cmd = _plugMethods.Command
		_plugMethods.AddCommand = _plugMethods.Command
		_plugMethods.addCommand = _plugMethods.Command
		function _plugMethods:Aliases(...)
			if self._active then
				const seen = {}
				for _, alias in self._active.Aliases or {} do
					seen[tostring(alias):lower()] = true
				end
				for _, alias in _plugAliases(...) do
					_plugAddAlias(self._active.Aliases, seen, alias)
				end
			end
			return self
		end
		_plugMethods.aliases = _plugMethods.Aliases
		_plugMethods.Alias = _plugMethods.Aliases
		_plugMethods.alias = _plugMethods.Aliases
		function _plugMethods:Args(value)
			if self._active then
				self._active.ArgsHint = tostring(value or "")
			end
			return self
		end
		_plugMethods.args = _plugMethods.Args
		_plugMethods.Arguments = _plugMethods.Args
		_plugMethods.arguments = _plugMethods.Args
		function _plugMethods:Info(value)
			if self._active then
				self._active.Info = tostring(value or "")
			else
				self.Info = tostring(value or "")
			end
			return self
		end
		_plugMethods.info = _plugMethods.Info
		_plugMethods.Desc = _plugMethods.Info
		_plugMethods.desc = _plugMethods.Info
		_plugMethods.Description = _plugMethods.Info
		_plugMethods.description = _plugMethods.Info
		function _plugMethods:RequiresArgs(value)
			if self._active then
				self._active.RequiresArguments = value ~= false
			end
			return self
		end
		_plugMethods.requiresArgs = _plugMethods.RequiresArgs
		_plugMethods.RequiresArguments = _plugMethods.RequiresArgs
		_plugMethods.requiresArguments = _plugMethods.RequiresArgs
		_plugMethods.NeedArgs = _plugMethods.RequiresArgs
		_plugMethods.needArgs = _plugMethods.RequiresArgs
		function _plugMethods:NoArgs()
			if self._active then
				self._active.RequiresArguments = false
			end
			return self
		end
		_plugMethods.noArgs = _plugMethods.NoArgs
		function _plugMethods:OverrideAliases(value)
			if self._active then
				self._active.OverrideAliases = value ~= false
			end
			return self
		end
		_plugMethods.overrideAliases = _plugMethods.OverrideAliases
		_plugMethods.Override = _plugMethods.OverrideAliases
		_plugMethods.override = _plugMethods.OverrideAliases
		_plugMethods.ReplaceExisting = _plugMethods.OverrideAliases
		_plugMethods.replaceExisting = _plugMethods.OverrideAliases
		_plugMethods.TakePriority = _plugMethods.OverrideAliases
		_plugMethods.takePriority = _plugMethods.OverrideAliases
		function _plugMethods:UserButton(spec, command, command2)
			if self._active then
				const opts = type(spec) == "table" and _plugCopy(spec) or { Label = spec }
				opts.Label = opts.Label or opts.label or opts.Text or opts.text or (self._active.Aliases and self._active.Aliases[1])
				opts.Cmd1 = opts.Cmd1 or opts.Command or opts.command or (self._active.Aliases and self._active.Aliases[1])
				opts.Cmd2 = opts.Cmd2 or opts.Command2 or opts.command2 or command
				NAmanage.PluginUserButtonAdd(pluginKey, baseName, opts)
				return self
			end
			NAmanage.PluginUserButtonAdd(pluginKey, baseName, spec, command, command2)
			return self
		end
		_plugMethods.userButton = _plugMethods.UserButton
		_plugMethods.Button = _plugMethods.UserButton
		_plugMethods.button = _plugMethods.UserButton
		_plugMethods.MobileButton = _plugMethods.UserButton
		_plugMethods.mobileButton = _plugMethods.UserButton
		function _plugMethods:ButtonOnRun(spec)
			if self._active then
				const opts = type(spec) == "table" and _plugCopy(spec) or { Label = spec }
				opts.Label = opts.Label or opts.label or opts.Text or opts.text or (self._active.Aliases and self._active.Aliases[1])
				opts.Cmd1 = opts.Cmd1 or opts.Command or opts.command or (self._active.Aliases and self._active.Aliases[1])
				opts.Id = opts.Id or opts.id or opts.Label
				self._active.ButtonOnRun = opts
			end
			return self
		end
		_plugMethods.buttonOnRun = _plugMethods.ButtonOnRun
		_plugMethods.UserButtonOnRun = _plugMethods.ButtonOnRun
		_plugMethods.userButtonOnRun = _plugMethods.ButtonOnRun
		_plugMethods.CreateButtonOnRun = _plugMethods.ButtonOnRun
		_plugMethods.createButtonOnRun = _plugMethods.ButtonOnRun
		function _plugMethods:RemoveButtonOnRun(query)
			if self._active then
				self._active.RemoveButtonOnRun = query or (self._active.Aliases and self._active.Aliases[1])
			end
			return self
		end
		_plugMethods.removeButtonOnRun = _plugMethods.RemoveButtonOnRun
		_plugMethods.RemoveUserButtonOnRun = _plugMethods.RemoveButtonOnRun
		_plugMethods.removeUserButtonOnRun = _plugMethods.RemoveButtonOnRun
		function _plugMethods:ToggleButton(spec, offCommand)
			const opts = type(spec) == "table" and _plugCopy(spec) or { Label = spec }
			opts.Mode = opts.Mode or opts.mode or "toggle"
			if self._active then
				opts.Cmd1 = opts.Cmd1 or opts.Command or opts.command or (self._active.Aliases and self._active.Aliases[1])
				opts.Cmd2 = opts.Cmd2 or opts.Command2 or opts.command2 or offCommand
				NAmanage.PluginUserButtonAdd(pluginKey, baseName, opts)
			else
				NAmanage.PluginUserButtonAdd(pluginKey, baseName, opts)
			end
			return self
		end
		_plugMethods.toggleButton = _plugMethods.ToggleButton
		function _plugMethods:Run(fn)
			if self._active and type(fn) == "function" then
				self._active.Function = fn
				_plugPush(self._active, true, self.Description or self.Info)
			end
			return self
		end
		_plugMethods.run = _plugMethods.Run
		_plugMethods.Callback = _plugMethods.Run
		_plugMethods.callback = _plugMethods.Run
		_plugMethods.Function = _plugMethods.Run
		_plugMethods.func = _plugMethods.Run
		function _plugMethods:End()
			self._active = nil
			return self
		end
		_plugMethods.done = _plugMethods.End
		_plugMethods.Done = _plugMethods.End

		const function _plugNew(name, desc)
			const builder = {
				_na_builder = true,
				Name = tostring(name or baseName or "Plugin"),
				Description = type(desc) == "string" and desc or nil,
				_cmds = {},
				_active = nil,
			}
			return setmetatable(builder, { __index = _plugMethods })
		end

		pluginApi = setmetatable({
			new = _plugNew,
			New = _plugNew,
			create = _plugNew,
			Create = _plugNew,
			addUserButton = function(...)
				return NAmanage.PluginUserButtonAdd(pluginKey, baseName, ...)
			end,
			AddUserButton = function(...)
				return NAmanage.PluginUserButtonAdd(pluginKey, baseName, ...)
			end,
			removeUserButton = function(...)
				return NAmanage.PluginUserButtonRemove(pluginKey, ...)
			end,
			RemoveUserButton = function(...)
				return NAmanage.PluginUserButtonRemove(pluginKey, ...)
			end,
			clearUserButtons = function()
				return NAmanage.PluginUserButtonRemove(pluginKey)
			end,
		}, {
			__call = function(_, ...)
				return _plugNew(...)
			end
		})

		proxyEnv.NAPlugin = _plugNew
		proxyEnv.plugin = _plugNew
		proxyEnv.Plugin = pluginApi
		proxyEnv.addUserButton = function(...)
			return NAmanage.PluginUserButtonAdd(pluginKey, baseName, ...)
		end
		proxyEnv.removeUserButton = function(...)
			return NAmanage.PluginUserButtonRemove(pluginKey, ...)
		end
		proxyEnv.clearUserButtons = function()
			return NAmanage.PluginUserButtonRemove(pluginKey)
		end
		proxyEnv.createUserButton = proxyEnv.addUserButton
		proxyEnv.command = function(...)
			return _plugNew(baseName):Command(...)
		end
		proxyEnv.Command = proxyEnv.command
		proxyEnv.cmdPlugin = proxyEnv.command

		const pluginServices = setmetatable({}, {
			__index = function(self, key)
				const svc = _plugGetService(key)
				if svc then
					rawset(self, key, svc)
				end
				return svc
			end
		})

		const function _plugSetService(globalName, serviceName)
			const svc = proxyEnv[globalName] or _plugGetService(serviceName or globalName)
			if svc then
				proxyEnv[globalName] = svc
			end
			return svc
		end

		const function _plugApplyServiceGlobals()
			proxyEnv.Services = proxyEnv.Services or pluginServices
			proxyEnv.services = proxyEnv.services or pluginServices
			proxyEnv.IsOnMobile = IsOnMobile == true
			proxyEnv.IsOnPC = IsOnPC == true
			proxyEnv.IsMobile = proxyEnv.IsOnMobile
			proxyEnv.IsPC = proxyEnv.IsOnPC
			proxyEnv.NA_GRAB_BODY = NA_GRAB_BODY
			proxyEnv.getRoot = proxyEnv.getRoot or getRoot
			proxyEnv.GetRoot = proxyEnv.GetRoot or getRoot
			proxyEnv.getChar = proxyEnv.getChar or getChar
			proxyEnv.GetChar = proxyEnv.GetChar or getChar
			proxyEnv.getHum = proxyEnv.getHum or getHum
			proxyEnv.GetHum = proxyEnv.GetHum or getHum
			proxyEnv.getTorso = proxyEnv.getTorso or getTorso
			proxyEnv.GetTorso = proxyEnv.GetTorso or getTorso
			proxyEnv.getHead = proxyEnv.getHead or getHead
			proxyEnv.GetHead = proxyEnv.GetHead or getHead
			proxyEnv.PlaceId = proxyEnv.PlaceId or tonumber(rawGame and rawGame.PlaceId) or 0
			proxyEnv.JobId = proxyEnv.JobId or tostring((rawGame and rawGame.JobId) or "")
		end

		_plugApplyServiceGlobals()

		if mode == "iy" then
			const function fetchService(name)
				return _plugGetService(name)
			end
			const iyServices = setmetatable({}, {
				__index = function(_, k)
					return fetchService(k)
				end
			})
			proxyEnv.Services = iyServices
			proxyEnv.services = iyServices
			const iyPlayers = _plugGetService("Players")
			const iyUserInputService = _plugGetService("UserInputService")
			const iyTextChatService = _plugGetService("TextChatService")

			local iySplitString

			const function iyGetPlayers(query, speaker)
				const results = {}
				if type(getPlr) ~= "function" then
					return results
				end
				local ok, targets = pcall(function()
					return getPlr(speaker, query or "")
				end)
				if not ok or type(targets) ~= "table" then
					return results
				end
				for _, plr in targets do
					if plr and plr.Name then
						results[#results + 1] = plr.Name
					end
				end
				return results
			end
			proxyEnv.getPlayersByName = iyGetPlayers
			proxyEnv.getPlayer = iyGetPlayers
			proxyEnv.GetPlayer = iyGetPlayers
			proxyEnv.r15 = function(plr)
				local target = plr
				if not target and iyPlayers then
					target = iyPlayers.LocalPlayer
				end
				const hum = target and target.Character and getPlrHum(target.Character)
				return hum and hum.RigType == Enum.HumanoidRigType.R15
			end
			proxyEnv.Services = proxyEnv.Services or iyServices
			proxyEnv.getstring = function(startIdx)
				const args = iyCallCtx.args or {}
				local start = tonumber(startIdx) or 1
				if start < 1 then start = 1 end
				const parts = {}
				for i = start, #args do
					parts[#parts+1] = tostring(args[i])
				end
				return Concat(parts, " ")
			end
			proxyEnv.getString = proxyEnv.getstring

			const function iyIsNumber(str)
				return tonumber(str) ~= nil
			end
			proxyEnv.isNumber = iyIsNumber
			proxyEnv.isnumber = iyIsNumber

			function iySplitString(str, delim)
				const out = {}
				str = tostring(str or "")
				delim = tostring(delim or ",")
				for part in string.gmatch(str, "[^"..delim.."]+") do
					const trimmed = part:match("^%s*(.-)%s*$")
					if trimmed and trimmed ~= "" then
						out[#out+1] = trimmed
					end
				end
				return out
			end
			proxyEnv.splitString = iySplitString

			const function iyToClipboard(txt)
				const payload = tostring(txt or "")
				if typeof(setclipboard) == "function" then
					const ok = pcall(setclipboard, payload)
					if ok then
						return true
					end
				end
				warn("Clipboard unavailable; value: "..payload)
				return false
			end
			proxyEnv.toClipboard = iyToClipboard
			proxyEnv.toclipboard = iyToClipboard

			const lp = iyPlayers and iyPlayers.LocalPlayer or nil
			proxyEnv.Players = proxyEnv.Players or iyPlayers
			proxyEnv.LocalPlayer = lp
			proxyEnv.Player = lp
			proxyEnv.lplr = lp
			proxyEnv.Char = lp and lp.Character or nil
			proxyEnv.Character = lp and lp.Character or nil
			proxyEnv.PlayerGui = lp and lp:FindFirstChildWhichIsA("PlayerGui") or nil
			proxyEnv.PlaceId = tonumber(game and game.PlaceId) or 0
			proxyEnv.JobId = tostring((game and game.JobId) or "")
			proxyEnv.COREGUI = _plugGetService("CoreGui")
			proxyEnv.UserInputService = proxyEnv.UserInputService or iyUserInputService
			proxyEnv.RunService = proxyEnv.RunService or _plugGetService("RunService")
			proxyEnv.TweenService = proxyEnv.TweenService or _plugGetService("TweenService")
			proxyEnv.HttpService = proxyEnv.HttpService or _plugGetService("HttpService")
			proxyEnv.TextChatService = proxyEnv.TextChatService or iyTextChatService
			proxyEnv.TextService = proxyEnv.TextService or _plugGetService("TextService")
			proxyEnv.StarterGui = proxyEnv.StarterGui or _plugGetService("StarterGui")
			proxyEnv.ReplicatedStorage = proxyEnv.ReplicatedStorage or _plugGetService("ReplicatedStorage")
			proxyEnv.Lighting = proxyEnv.Lighting or _plugGetService("Lighting")
			proxyEnv.ContextActionService = proxyEnv.ContextActionService or _plugGetService("ContextActionService")

			const function iyMouse()
				return NAmanage.GetMouse(lp)
			end
			proxyEnv.IYMouse = iyMouse()

			const function iyIsOnMobile()
				if iyUserInputService and typeof(iyUserInputService.GetPlatform) == "function" then
					const platform = iyUserInputService:GetPlatform()
					return platform == Enum.Platform.Android or platform == Enum.Platform.IOS
				end
				return iyUserInputService and iyUserInputService.TouchEnabled and not iyUserInputService.KeyboardEnabled
			end
			proxyEnv.IsOnMobile = iyIsOnMobile()
			proxyEnv.IsOnPC = IsOnPC == true
			proxyEnv.IsMobile = proxyEnv.IsOnMobile
			proxyEnv.IsPC = proxyEnv.IsOnPC
			proxyEnv.NA_GRAB_BODY = NA_GRAB_BODY

			const function iyLegacyChat()
				if iyTextChatService and iyTextChatService.ChatVersion then
					return iyTextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService
				end
				return false
			end
			proxyEnv.isLegacyChat = iyLegacyChat()

			proxyEnv.currentVersion = proxyEnv.currentVersion or "IY-compat"

			proxyEnv.getRoot = function(char)
				if not char then
					return nil
				end
				return char:FindFirstChild("HumanoidRootPart")
					or char:FindFirstChild("Torso")
					or char:FindFirstChild("UpperTorso")
					or char.PrimaryPart
			end

			proxyEnv.Time = function()
				return os.date("%X")
			end

			if not proxyEnv.buffer or type(proxyEnv.buffer.create) ~= "function" then
				const bufShim = {}
				bufShim.__index = bufShim
				function bufShim.create(n)
					return setmetatable({ len = tonumber(n) or 0, data = {} }, bufShim)
				end
				function bufShim.writeu8(b, idx, val)
					if not (b and b.data) then
						return
					end
					b.data[(idx or 0) + 1] = val
				end
				function bufShim.tostring(b)
					if not b or not b.data then
						return ""
					end
					const out = {}
					for i = 1, b.len do
						out[i] = string.char(b.data[i] or 0)
					end
					return Concat(out)
				end
				proxyEnv.buffer = bufShim
			end
		end

		setmetatable(proxyEnv, {
			__metatable = "NAPluginEnvironment",
			__index = function(_, k)
				if k == "loadstring" then
					const baseLoader = baseEnv.loadstring or loadstring
					const function collectRemoteReturn(...)
						const first = select(1, ...)
						if type(first) == "table" then
							if mode == "iy" then
								appendIYCommands(colPlugins, first)
							else
								_plugAppend(first, true)
							end
						end
						return ...
					end
					return function(code, chunkname)
						if (tonumber(NAmanage._cmdRunDepth) or 0) > 0 then
							const src = tostring(code or "")
							return function(...)
								return NAmanage.RunSourceInEnv(src, chunkname or "@NAPluginRuntime", proxyEnv, collectRemoteReturn, ...)
							end
						end
						local f, e = baseLoader(code, chunkname)
						if not f then
							return nil, e
						end
						setfenv(f, proxyEnv)
						return function(...)
							return collectRemoteReturn(f(...))
						end
					end
				elseif k == "load" then
					const baseLoad = baseEnv.load
					if not baseLoad then return nil end
					return function(chunk, chunkname, mode2)
						return baseLoad(chunk, chunkname, mode2, proxyEnv)
					end
				elseif k == "Plugin" then
					return pluginApi
				elseif k == "NAPlugin" or k == "plugin" then
					return _plugNew
				elseif k == "command" or k == "Command" or k == "cmdPlugin" then
					return function(...)
						return _plugNew(baseName):Command(...)
					end
				elseif k == "game" then
					return gameProxy
				elseif k == "httprequest" or k == "request" or k == "http_request" then
					return _pluginRequest
				elseif k == "cmdPluginAdd" then
					return function(v)
						return _plugAppend(v, false)
					end
				end
				const shimValue = pluginEnvShims[k]
				if shimValue ~= nil then
					return shimValue
				end
				const localValue = pluginGlobals[k]
				if localValue == pluginNil then
					return nil
				end
				if localValue ~= nil then
					return localValue
				end
				if k == "LocalPlayer" or k == "Player" or k == "lplr" or k == "Speaker" or k == "speaker" then
					const pls = _plugGetService("Players")
					return pls and pls.LocalPlayer or nil
				elseif k == "Char" or k == "Character" then
					const pls = _plugGetService("Players")
					const lp = pls and pls.LocalPlayer or nil
					return lp and lp.Character or nil
				elseif k == "PlayerGui" then
					const pls = _plugGetService("Players")
					const lp = pls and pls.LocalPlayer or nil
					return lp and lp:FindFirstChildWhichIsA("PlayerGui") or nil
				elseif k == "workspace" then
					return _plugGetService("Workspace")
				end
				const serviceValue = pluginServices[k]
				if serviceValue ~= nil then
					return serviceValue
				end
				const serviceName = _plugServiceName(k)
				if type(serviceName) == "string" and pluginServiceNames[serviceName] then
					return _plugGetService(serviceName)
				end
				if pluginBlockedGlobals[k] then
					return nil
				end
				return pluginBaseGlobals[k]
			end,
			__newindex = function(_, k, v)
				if k == "cmdPluginAdd" then
					_plugAppend(v, false)
				else
					pluginGlobals[k] = (v == nil) and pluginNil or v
				end
			end
		})

		setfenv(func, proxyEnv)

		const prevSkipAdd = cmds._skipAutoSuffix
		cmds._skipAutoSuffix = true
		local ok, execRes = NACaller(func)
		cmds._skipAutoSuffix = prevSkipAdd
		if not ok then
			DoWindow("[Plugin Error] '"..file.."' => "..tostring(execRes))
			return
		end

		if mode == "iy" and type(execRes) == "table" then
			appendIYCommands(colPlugins, execRes)
		elseif mode == "na" and type(execRes) == "table" then
			_plugAppend(execRes, true)
		end

		const cmdNames = {}
		for _, plugin in colPlugins do
			const aliases = plugin.Aliases
			const handler = plugin.Function
			if type(aliases) == "table" and type(handler) == "function" then
				local uniqueAliases, replacedAliases, overriddenAliases = makeUniqueAliases(pluginKey, aliases, plugin.OverrideAliases == true)
				if #uniqueAliases == 0 then
					DoWindow("[Plugin Invalid] '"..file.."' has no usable aliases (conflicts removed)")
				else
					const argsHint = plugin.ArgsHint or ""
					const formattedDisplay = formatInfo(uniqueAliases, argsHint)
					local desc = plugin.Info or "No description"
					const notes = {}
					const swapNote = formatAliasSwapNote(replacedAliases)
					const overrideNote = formatAliasOverrideNote(overriddenAliases)
					if swapNote then
						notes[#notes + 1] = swapNote
					end
					if overrideNote then
						notes[#notes + 1] = overrideNote
					end
					if #notes > 0 then
						desc = desc.." | "..Concat(notes, " | ")
					end
					const info = { formattedDisplay, desc }
					const displaced = displaceCoreAliases(pluginKey, overriddenAliases)
					const prevSkip = cmds._skipAutoSuffix
					cmds._skipAutoSuffix = true
					local okAdd, errAdd = pcall(cmd.add, uniqueAliases, info, handler, plugin.RequiresArguments or false)
					cmds._skipAutoSuffix = prevSkip
					const primaryLow = uniqueAliases[1] and type(uniqueAliases[1]) == "string" and uniqueAliases[1]:lower() or nil
					const dataRef = primaryLow and cmds.Commands[primaryLow] or nil
					if okAdd and dataRef then
						AddCmdPlug(pluginKey, uniqueAliases, dataRef)
						Insert(cmdNames, uniqueAliases[1])
					else
						restoreDisplacedAliases(pluginKey, displaced)
						DoWindow("[Plugin Error] Failed to register command: "..tostring(errAdd or "command data unavailable"))
					end
				end
			else
				DoWindow("[Plugin Invalid] '"..file.."' is missing valid Aliases or Function")
			end
		end

		if #cmdNames > 0 then
			const fileName = file:match("[^\\/]+$") or file
			if runMeta[pluginKey] then
				runMeta[pluginKey].loaded = true
				runMeta[pluginKey].commands = cmdNames
			end
			Insert(loadedSumm, fileName.." ("..Concat(cmdNames, ", ")..")")
		else
			const buttonBucket = type(NAPluginUserButtons) == "table" and NAPluginUserButtons[pluginKey] or nil
			const buttonCount = type(buttonBucket) == "table" and type(buttonBucket.items) == "table" and #buttonBucket.items or 0
			if buttonCount > 0 then
				const fileName = file:match("[^\\/]+$") or file
				if runMeta[pluginKey] then
					runMeta[pluginKey].loaded = true
					runMeta[pluginKey].commands = {}
				end
				Insert(loadedSumm, fileName.." ("..tostring(buttonCount).." button"..(buttonCount == 1 and "" or "s")..")")
			end
		end
	end

	const prevPluginButtonPause = NAStuff and NAStuff.PluginUserButtonRenderPaused
	if NAStuff then
		NAStuff.PluginUserButtonRenderPaused = true
	end
	for _, file in filesNA do
		loadPluginFile(file, "na")
	end
	for _, file in filesIY do
		loadPluginFile(file, "iy")
	end

	const staleKeys = {}
	for key in NAmanage._pluginCommandRecords do
		if not seenKeys[key] then
			Insert(staleKeys, key)
		end
	end
	for _, key in staleKeys do
		UnplugCmd(key)
		if NAmanage.PluginUIClear then
			pcall(NAmanage.PluginUIClear, key)
		end
	end
	NAmanage._pluginFileMeta = runMeta
	if NAStuff then
		NAStuff.PluginUserButtonRenderPaused = prevPluginButtonPause
	end
	if NAStuff and NAStuff.PluginUserButtonsDirty and NAmanage.RenderUserButtons then
		NAStuff.PluginUserButtonsDirty = false
		pcall(NAmanage.RenderUserButtons)
	end

	const hideStartupNotif = opts.startup == true and type(NAmanage.isStartupHidden) == "function" and NAmanage.isStartupHidden() == true
	const allowNotif = (forceNotify == true) or ((NAmanage.jlCfg.PluginNotif ~= false) and not hideStartupNotif)
	if #loadedSumm > 0 and allowNotif and not silent then
		DoNotif("Loaded plugins:\n\n"..Concat(loadedSumm, "\n\n"), 5.7)
	end

	if NAgui and NAgui.loadCMDS then
		pcall(NAgui.loadCMDS, { force = true })
	end
	if NAgui and NAgui.commands and NAUIMANAGER and NAUIMANAGER.commandsFrame and NAUIMANAGER.commandsFrame.Visible then
		pcall(NAgui.commands)
	end

	return true
end

NAmanage.IsPluginCommand = function(cmdName)
	if type(cmdName) ~= "string" then
		return false
	end
	local sources = NAmanage and NAmanage._pluginCommandSources
	if type(sources) ~= "table" then
		sources = {}
	end
	const lowerName = Lower(cmdName)
	const entry = sources[lowerName]
	if entry then
		if entry.data and cmds and cmds.Commands and cmds.Commands[lowerName] ~= entry.data then
			return false
		end
		local pluginType
		if type(entry.key) == "string" then
			if entry.key:match("%.na$") then
				pluginType = ".na"
			elseif entry.key:match("%.iy$") then
				pluginType = ".iy"
			end
		end
		return true, pluginType, entry.key
	end

	if cmds and cmds.PluginSources and cmds.PluginSources[lowerName] then
		const key = cmds.PluginSources[lowerName]
		local pluginType
		if type(key) == "string" then
			if key:match("%.na$") then
				pluginType = ".na"
			elseif key:match("%.iy$") then
				pluginType = ".iy"
			end
		end
		return true, pluginType, key
	end

	return false
end

NAmanage.InitPlugs=function()
	const lp = function(p)
		p = (p or ""):gsub("\\","/"):gsub("/+","/")
		return Lower(p:gsub("/+$",""))
	end
	const bn = function(p) return (p and p:match("[^\\/]+$")) or p end
	const jp = function(d, n) d = d or ""; return (#d > 0) and (d.."/"..n) or n end
	const mk = function(p) if p and #p > 0 and not isfolder(p) then makefolder(p) end end
	const isIgnoredIY = function(p)
		const base = bn(p)
		return type(base) == "string" and base:lower() == "iy_fe.iy"
	end
	const isPluginFile = function(p)
		const n = lp(p)
		if isIgnoredIY(p) then
			return false
		end
		return n:match("%.na$") ~= nil or n:match("%.iy$") ~= nil
	end
	const uniq = function(dir, fname)
		local name, ext = fname:match("^(.*)(%.[^%.]+)$"); name, ext = name or fname, ext or ""
		local try = jp(dir, fname); if not isfile(try) then return try end
		local n = 1
		while true do
			try = jp(dir, Format("%s (%d)%s", name, n, ext))
			if not isfile(try) then return try end
			n += 1
		end
	end
	const root = function()
		for _, c in {"", ".", "/"} do
			local ok, t = pcall(listfiles, c)
			if ok and type(t) == "table" then return c end
		end
		return ""
	end

	const plugsDirNA = NAfiles.NAPLUGINFILEPATH
	const plugsDirIY = NAfiles.NAIYPLUGINFILEPATH or (NAfiles.NAFILEPATH.."/PluginsIY")
	const plugsInfo = {}
	for _, dir in {plugsDirNA, plugsDirIY} do
		const norm = lp(dir)
		const tail = norm:match("([^/]+/[^/]+)$") or norm
		Insert(plugsInfo, { norm = norm, tail = tail })
	end
	const inPlugs = function(path)
		const p = lp(path)
		for _, info in plugsInfo do
			if p == info.norm then return true end
			if p:sub(1, #info.norm + 1) == (info.norm.."/") then return true end
			if p:find("/"..info.tail.."/", 1, true) then return true end
		end
		return false
	end

	const scan = function(startDir)
		const out = {}
		const function rec(dir)
			local ok, items = pcall(listfiles, dir)
			if not ok or type(items) ~= "table" then return end
			for _, p in items do
				local okd, isd = pcall(isfolder, p)
				if okd and isd then
					if not inPlugs(p) then rec(p) end
				else
					if isPluginFile(p) and not inPlugs(p) then Insert(out, p) end
				end
			end
		end
		rec(startDir)
		return out
	end
	const deferPluginReload = function(loadOpts, onDone)
		if not (NAmanage and NAmanage.LoadPlugins) then
			return false
		end
		Spawn(function()
			Wait()
			const ok = NAmanage.LoadPlugins(loadOpts)
			if type(onDone) == "function" then
				pcall(onDone, ok)
			end
		end)
		return true
	end


	NAStuff.PluginMaker = NAStuff.PluginMaker or {}

	NAmanage.PluginMaker_Quote = function(value)
		return string.format("%q", tostring(value or ""))
	end

	NAmanage.PluginMaker_Trim = function(value)
		return tostring(value or ""):match("^%s*(.-)%s*$") or ""
	end

	NAmanage.PluginMaker_SafeFileName = function(value)
		local name = NAmanage.PluginMaker_Trim(value)
		name = name:gsub("[\\/:*?\"<>|]", "_"):gsub("%s+", "_"):gsub("[^%w%._%-]", "_")
		name = name:gsub("_+", "_"):gsub("^_+", ""):gsub("_+$", "")
		if name == "" then
			name = "MyPlugin"
		end
		return name
	end

	NAmanage.PluginMaker_SplitAliases = function(value)
		local out = {}
		local seen = {}
		for part in tostring(value or ""):gmatch("[^,|/]+") do
			local alias = NAmanage.PluginMaker_Trim(part)
			if alias ~= "" then
				local key = alias:lower()
				if not seen[key] then
					seen[key] = true
					out[#out + 1] = alias
				end
			end
		end
		return out
	end

	NAmanage.PluginMaker_DefaultCommand = function(index)
		index = tonumber(index) or 1
		return {
			name = index == 1 and "hello" or ("command"..tostring(index));
			aliases = index == 1 and "hi" or "";
			argsHint = index == 1 and "[name]" or "";
			description = index == 1 and "Example command made with Plugin Maker" or "Plugin command";
			requiresArgs = false;
			overrideAliases = false;
			userButton = index == 1;
			userButtonLabel = index == 1 and "Hello" or "";
			saveButtonArgs = true;
			customCode = "";
			actions = index == 1 and {
				{ type = "notify"; value = "Hello {1}!"; extra = "3" };
			} or {
				{ type = "notify"; value = "Command executed"; extra = "3" };
			};
		}
	end

	NAmanage.PluginMaker_ResetState = function()
		local pm = NAStuff.PluginMaker
		pm.format = "na"
		pm.pluginName = "My Plugin"
		pm.fileName = "MyPlugin"
		pm.description = "Created with Nameless Admin Plugin Maker"
		pm.commands = { NAmanage.PluginMaker_DefaultCommand(1) }
		pm.selectedCommand = 1
		pm.actionType = "notify"
		pm.actionValue = ""
		pm.actionExtra = "3"
		pm.startupCode = ""
		pm.codeEditTarget = nil
		pm.selectedServices = {}
		pm.customServices = {}
		pm.dirty = false
	end

	NAmanage.PluginMaker_GetSelectedCommand = function()
		local pm = NAStuff.PluginMaker
		if type(pm.commands) ~= "table" then
			pm.commands = {}
		end
		local index = math.clamp(math.floor(tonumber(pm.selectedCommand) or 1), 1, math.max(#pm.commands, 1))
		pm.selectedCommand = index
		return pm.commands[index], index
	end

	NAmanage.PluginMaker_TemplateHelper = function()
		return table.concat({
			"local function __na_pm_fill(text, args, player)";
			"\tlocal out = tostring(text or \"\")";
			"\tlocal parts = {}";
			"\tfor i = 1, #(args or {}) do parts[i] = tostring(args[i]) end";
			"\tout = out:gsub(\"{args}\", function() return table.concat(parts, \" \") end)";
			"\tout = out:gsub(\"{user}\", function() return player and tostring(player.Name or \"\") or \"\" end)";
			"\tout = out:gsub(\"{display}\", function() return player and tostring(player.DisplayName or \"\") or \"\" end)";
			"\tout = out:gsub(\"{placeid}\", function() return tostring(game.PlaceId or \"\") end)";
			"\tout = out:gsub(\"{jobid}\", function() return tostring(game.JobId or \"\") end)";
			"\tfor i = 1, #parts do";
			"\t\tlocal key = \"{\"..tostring(i)..\"}\"";
			"\t\tlocal value = parts[i]";
			"\t\tout = out:gsub(key, function() return value end)";
			"\tend";
			"\treturn out";
			"end";
		}, "\n")
	end


	NAmanage.PluginMaker_ServiceCatalog = {
		"AdService";
		"AnalyticsService";
		"AnimationClipProvider";
		"AnimationFromVideoCreatorService";
		"AssetDeliveryProxy";
		"AssetManagerService";
		"AssetService";
		"AvatarCreationService";
		"AvatarEditorService";
		"AvatarImportService";
		"BadgeService";
		"BrowserService";
		"BulkImportService";
		"CaptureService";
		"ChangeHistoryService";
		"Chat";
		"CollectionService";
		"CommerceService";
		"ConfigService";
		"ConfigureServerService";
		"ContentProvider";
		"ContextActionService";
		"ControllerService";
		"CookiesService";
		"CoreGui";
		"CoreScriptSyncService";
		"CreatorStoreService";
		"DataStoreService";
		"Debris";
		"DebugSettings";
		"DraftsService";
		"EditableService";
		"ExperienceService";
		"GamepadService";
		"GeometryService";
		"GroupService";
		"GuiService";
		"HapticService";
		"HttpRbxApiService";
		"HttpService";
		"InsertService";
		"JointsService";
		"KeyboardService";
		"KeyframeSequenceProvider";
		"LanguageService";
		"Lighting";
		"LocalizationService";
		"LoginService";
		"LogService";
		"LuaWebService";
		"MarketplaceService";
		"MatchmakingService";
		"MaterialGenerationService";
		"MaterialService";
		"MemoryStoreService";
		"MemStorageService";
		"MessagingService";
		"MicroProfilerService";
		"MLService";
		"ModerationService";
		"MouseService";
		"NetworkClient";
		"NetworkServer";
		"NotificationService";
		"OpenCloudService";
		"PackageService";
		"PathfindingService";
		"PermissionsService";
		"PhysicsService";
		"PlacesService";
		"Players";
		"PlayerViewService";
		"PluginConnectionService";
		"PluginDebugService";
		"PluginGuiService";
		"PluginManagementService";
		"PluginPolicyService";
		"PointsService";
		"PolicyService";
		"ProcessInstancePhysicsService";
		"ProximityPromptService";
		"PublishService";
		"RbxAnalyticsService";
		"RecommendationService";
		"ReflectionService";
		"RemoteCommandService";
		"ReplicatedFirst";
		"ReplicatedStorage";
		"RunService";
		"SceneAnalysisService";
		"ScriptContext";
		"ScriptDebuggerService";
		"ScriptEditorService";
		"ScriptProfilerService";
		"ScriptService";
		"Selection";
		"SerializationService";
		"ServerScriptService";
		"ServerStorage";
		"SessionCheckService";
		"SmoothVoxelsUpgraderService";
		"SocialService";
		"SoundService";
		"SpawnerService";
		"StarterGui";
		"StarterPack";
		"StarterPlayer";
		"StartupMessageService";
		"Stats";
		"StudioCaptureService";
		"StudioDataService";
		"StudioDeviceEmulatorService";
		"StudioDeviceSimulatorService";
		"StudioPublishService";
		"StudioScreenshotCapture";
		"StudioService";
		"StudioTestService";
		"TeamCreateService";
		"Teams";
		"TeleportService";
		"TestService";
		"TextBoxService";
		"TextChatService";
		"TextService";
		"TimerService";
		"TouchInputService";
		"TweenService";
		"UGCValidationService";
		"UniqueIdLookupService";
		"UserInputService";
		"UserService";
		"VideoCaptureService";
		"VideoService";
		"VirtualInputManager";
		"VirtualUser";
		"VoiceChatService";
		"VRService";
		"VRStatusService";
		"Workspace";
	}

	NAmanage.PluginMaker_ServiceVar = function(name)
		name = tostring(name or ""):gsub("[^%w_]", "_")
		if name == "" then
			return nil
		end
		local reserved = {
			["and"] = true; ["break"] = true; ["do"] = true; ["else"] = true; ["elseif"] = true;
			["end"] = true; ["false"] = true; ["for"] = true; ["function"] = true; ["if"] = true;
			["in"] = true; ["local"] = true; ["nil"] = true; ["not"] = true; ["or"] = true;
			["repeat"] = true; ["return"] = true; ["then"] = true; ["true"] = true; ["until"] = true;
			["while"] = true; ["continue"] = true; ["export"] = true; ["type"] = true;
		}
		if name:match("^%d") or reserved[name] then
			name = "Service_"..name
		end
		return name
	end

	NAmanage.PluginMaker_NormalizeServices = function()
		local pm = NAStuff.PluginMaker
		pm.selectedServices = type(pm.selectedServices) == "table" and pm.selectedServices or {}
		pm.customServices = type(pm.customServices) == "table" and pm.customServices or {}
		local clean = {}
		for name, enabled in pm.selectedServices do
			name = NAmanage.PluginMaker_Trim(name)
			if enabled == true and name:match("^[%a_][%w_]*$") then
				clean[name] = true
			end
		end
		pm.selectedServices = clean
		return clean
	end

	NAmanage.PluginMaker_GetServiceCatalog = function()
		local pm = NAStuff.PluginMaker
		local out, seen = {}, {}
		local function add(name)
			name = NAmanage.PluginMaker_Trim(name)
			if name == "" or not name:match("^[%a_][%w_]*$") then
				return
			end
			local key = name:lower()
			if not seen[key] then
				seen[key] = true
				out[#out + 1] = name
			end
		end
		for _, name in NAmanage.PluginMaker_ServiceCatalog do
			add(name)
		end
		for _, name in pm.customServices or {} do
			add(name)
		end
		pcall(function()
			for _, child in game:GetChildren() do
				if typeof(child) == "Instance" then
					add(child.ClassName)
				end
			end
		end)
		table.sort(out, function(a, b)
			local sa = pm.selectedServices and pm.selectedServices[a] == true
			local sb = pm.selectedServices and pm.selectedServices[b] == true
			if sa ~= sb then
				return sa
			end
			return a:lower() < b:lower()
		end)
		return out
	end

	NAmanage.PluginMaker_GetSelectedServices = function()
		local selected = NAmanage.PluginMaker_NormalizeServices()
		local out = {}
		for name, enabled in selected do
			if enabled == true then
				out[#out + 1] = name
			end
		end
		table.sort(out, function(a, b)
			return a:lower() < b:lower()
		end)
		return out
	end

	NAmanage.PluginMaker_ServicePrelude = function()
		local selected = NAmanage.PluginMaker_GetSelectedServices()
		local lines = {
			"local ServiceResolver = ServiceResolver";
			"assert(type(ServiceResolver) == \"table\", \"NA ServiceResolver unavailable\")";
			"local __na_pm_resolve = ServiceResolver.cs or ServiceResolver.GetService or ServiceResolver.getService";
			"local __na_pm_resolveRaw = ServiceResolver.gs or ServiceResolver.GetRawService or ServiceResolver.getRawService";
			"assert(type(__na_pm_resolve) == \"function\" or type(__na_pm_resolveRaw) == \"function\", \"NA ServiceResolver has no resolver method\")";
			"local Services = setmetatable({}, {";
			"\t__index = function(self, name)";
			"\t\tlocal service = type(__na_pm_resolve) == \"function\" and __na_pm_resolve(name) or nil";
			"\t\tif service == nil and type(__na_pm_resolveRaw) == \"function\" then service = __na_pm_resolveRaw(name) end";
			"\t\tif service ~= nil then rawset(self, name, service) end";
			"\t\treturn service";
			"\tend";
			"})";
		}
		for _, serviceName in selected do
			local varName = NAmanage.PluginMaker_ServiceVar(serviceName)
			if varName then
				lines[#lines + 1] = "local "..varName.." = Services["..NAmanage.PluginMaker_Quote(serviceName).."]"
			end
		end
		if NAStuff.PluginMaker.selectedServices and NAStuff.PluginMaker.selectedServices.Players == true then
			lines[#lines + 1] = "local LocalPlayer = Players and Players.LocalPlayer or nil"
		end
		return table.concat(lines, "\n")
	end

	NAmanage.PluginMaker_AppendRaw = function(lines, code, indent)
		if type(lines) ~= "table" then
			return
		end
		code = tostring(code or "")
		if code == "" then
			return
		end
		indent = tostring(indent or "")
		for line in (code.."\n"):gmatch("(.-)\n") do
			lines[#lines + 1] = indent..line
		end
	end

	NAmanage.PluginMaker_IYContextLines = function()
		return {
			"\t\t\t\tlocal ctx = {";
			"\t\t\t\t\tLocalPlayer = player;";
			"\t\t\t\t\tPlayer = player;";
			"\t\t\t\t\tServices = Services;";
			"\t\t\t\t\tServiceResolver = ServiceResolver;";
			"\t\t\t\t\tIsOnMobile = IsOnMobile == true;";
			"\t\t\t\t\tIsOnPC = IsOnPC == true;";
			"\t\t\t\t}";
			"\t\t\t\tctx.notify = function(_, message, duration)";
			"\t\t\t\t\tif type(notify) == \"function\" then return notify(message, duration) end";
			"\t\t\t\t\tif type(DoNotif) == \"function\" then return DoNotif(message, duration) end";
			"\t\t\t\tend";
			"\t\t\t\tctx.run = function(_, ...)";
			"\t\t\t\t\tif type(cmdRun) == \"function\" then return cmdRun(...) end";
			"\t\t\t\t\tif type(RunCommand) == \"function\" then return RunCommand(...) end";
			"\t\t\t\tend";
			"\t\t\t\tctx.addUserButton = function(_, ...)";
			"\t\t\t\t\tif type(addUserButton) == \"function\" then return addUserButton(...) end";
			"\t\t\t\tend";
			"\t\t\t\tctx.removeUserButton = function(_, ...)";
			"\t\t\t\t\tif type(removeUserButton) == \"function\" then return removeUserButton(...) end";
			"\t\t\t\tend";
		}
	end

	NAmanage.PluginMaker_ActionLines = function(action, mode)
		action = type(action) == "table" and action or {}
		local kind = tostring(action.type or "notify")
		local value = NAmanage.PluginMaker_Quote(action.value or "")
		local extra = tostring(action.extra or "")
		local out = {}
		local native = mode == "na"
		local fill = "__na_pm_fill("..value..", args, player)"
		if kind == "notify" then
			local seconds = math.clamp(tonumber(extra) or 3, 0.1, 30)
			out[#out + 1] = native and ("\t\tctx:notify("..fill..", "..tostring(seconds)..")") or ("\t\tif type(notify) == \"function\" then notify("..fill..", "..tostring(seconds)..") elseif type(DoNotif) == \"function\" then DoNotif("..fill..", "..tostring(seconds)..") end")
		elseif kind == "run" then
			out[#out + 1] = native and ("\t\tctx:run("..fill..")") or ("\t\tif type(cmdRun) == \"function\" then cmdRun("..fill..") elseif type(RunCommand) == \"function\" then RunCommand("..fill..") end")
		elseif kind == "load_url" then
			out[#out + 1] = "\t\tlocal __na_pm_url = "..fill
			out[#out + 1] = "\t\tlocal __na_pm_source = game:HttpGet(__na_pm_url)"
			out[#out + 1] = "\t\tlocal __na_pm_loader = loadstring or load"
			out[#out + 1] = "\t\tif type(__na_pm_loader) ~= \"function\" then error(\"loadstring/load unavailable\") end"
			out[#out + 1] = "\t\tlocal __na_pm_chunk, __na_pm_error = __na_pm_loader(__na_pm_source)"
			out[#out + 1] = "\t\tif not __na_pm_chunk then error(__na_pm_error or \"failed to compile remote source\") end"
			out[#out + 1] = "\t\t__na_pm_chunk()"
		elseif kind == "wait" then
			local seconds = math.clamp(tonumber(action.value) or tonumber(extra) or 1, 0, 120)
			out[#out + 1] = "\t\tif task and task.wait then task.wait("..tostring(seconds)..") elseif wait then wait("..tostring(seconds)..") end"
		elseif kind == "print" then
			out[#out + 1] = "\t\tprint("..fill..")"
		elseif kind == "copy" then
			out[#out + 1] = "\t\tif type(setclipboard) == \"function\" then setclipboard("..fill..") end"
		elseif kind == "mobile_run" then
			if native then
				out[#out + 1] = "\t\tif ctx.IsOnMobile then ctx:run("..fill..") end"
			else
				out[#out + 1] = "\t\tif IsOnMobile and type(cmdRun) == \"function\" then cmdRun("..fill..") end"
			end
		elseif kind == "pc_run" then
			if native then
				out[#out + 1] = "\t\tif ctx.IsOnPC then ctx:run("..fill..") end"
			else
				out[#out + 1] = "\t\tif IsOnPC and type(cmdRun) == \"function\" then cmdRun("..fill..") end"
			end
		elseif kind == "mobile_notify" then
			local seconds = math.clamp(tonumber(extra) or 3, 0.1, 30)
			if native then
				out[#out + 1] = "\t\tif ctx.IsOnMobile then ctx:notify("..fill..", "..tostring(seconds)..") end"
			else
				out[#out + 1] = "\t\tif IsOnMobile and type(notify) == \"function\" then notify("..fill..", "..tostring(seconds)..") end"
			end
		elseif kind == "pc_notify" then
			local seconds = math.clamp(tonumber(extra) or 3, 0.1, 30)
			if native then
				out[#out + 1] = "\t\tif ctx.IsOnPC then ctx:notify("..fill..", "..tostring(seconds)..") end"
			else
				out[#out + 1] = "\t\tif IsOnPC and type(notify) == \"function\" then notify("..fill..", "..tostring(seconds)..") end"
			end
		elseif kind == "add_button" then
			local label = NAmanage.PluginMaker_Quote(action.value or "Button")
			local command = NAmanage.PluginMaker_Quote(extra ~= "" and extra or "")
			if native then
				out[#out + 1] = "\t\tctx:addUserButton({ Label = "..label..", Command = "..command..", SaveArgs = true })"
			else
				out[#out + 1] = "\t\tif type(addUserButton) == \"function\" then addUserButton({ Label = "..label..", Command = "..command..", SaveArgs = true }) end"
			end
		elseif kind == "remove_button" then
			out[#out + 1] = native and ("\t\tctx:removeUserButton("..fill..")") or ("\t\tif type(removeUserButton) == \"function\" then removeUserButton("..fill..") end")
		elseif kind == "stop" then
			out[#out + 1] = "\t\treturn"
		elseif kind == "custom" then
			local raw = tostring(action.value or "")
			if raw ~= "" then
				for line in (raw.."\n"):gmatch("(.-)\n") do
					out[#out + 1] = "\t\t"..line
				end
			end
		end
		return out
	end

	NAmanage.PluginMaker_GenerateNA = function()
		local pm = NAStuff.PluginMaker
		local lines = {
			"local plugin = Plugin.new("..NAmanage.PluginMaker_Quote(pm.pluginName)..", "..NAmanage.PluginMaker_Quote(pm.description)..")";
			"";
			NAmanage.PluginMaker_ServicePrelude();
			"";
			NAmanage.PluginMaker_TemplateHelper();
			"";
		}
		if NAmanage.PluginMaker_Trim(pm.startupCode) ~= "" then
			lines[#lines + 1] = ""
			NAmanage.PluginMaker_AppendRaw(lines, pm.startupCode, "")
			lines[#lines + 1] = ""
		end
		for _, command in pm.commands or {} do
			local name = NAmanage.PluginMaker_Trim(command.name)
			if name ~= "" then
				local aliases = NAmanage.PluginMaker_SplitAliases(command.aliases)
				local call = "\nplugin:cmd("..NAmanage.PluginMaker_Quote(name)
				for _, alias in aliases do
					if alias:lower() ~= name:lower() then
						call = call..", "..NAmanage.PluginMaker_Quote(alias)
					end
				end
				call = call..")"
				lines[#lines + 1] = call
				if NAmanage.PluginMaker_Trim(command.argsHint) ~= "" then
					lines[#lines + 1] = "\t:args("..NAmanage.PluginMaker_Quote(command.argsHint)..")"
				end
				lines[#lines + 1] = "\t:info("..NAmanage.PluginMaker_Quote(command.description)..")"
				if command.requiresArgs == true then
					lines[#lines + 1] = "\t:requiresArgs()"
				end
				if command.overrideAliases == true then
					lines[#lines + 1] = "\t:OverrideAliases()"
				end
				if command.userButton == true then
					local label = NAmanage.PluginMaker_Trim(command.userButtonLabel)
					if label == "" then label = name end
					lines[#lines + 1] = "\t:userButton({ Label = "..NAmanage.PluginMaker_Quote(label)..", SaveArgs = "..tostring(command.saveButtonArgs ~= false).." })"
				end
				lines[#lines + 1] = "\t:run(function(ctx, ...)"
				lines[#lines + 1] = "\t\tlocal args = {...}"
				lines[#lines + 1] = "\t\tlocal player = ctx.LocalPlayer"
				for _, action in command.actions or {} do
					for _, actionLine in NAmanage.PluginMaker_ActionLines(action, "na") do
						lines[#lines + 1] = actionLine
					end
				end
				if NAmanage.PluginMaker_Trim(command.customCode) ~= "" then
					lines[#lines + 1] = "\t\t"
					NAmanage.PluginMaker_AppendRaw(lines, command.customCode, "\t\t")
				end
				lines[#lines + 1] = "\tend)"
			end
		end
		return table.concat(lines, "\n")
	end

	NAmanage.PluginMaker_GenerateIY = function()
		local pm = NAStuff.PluginMaker
		local lines = {
			NAmanage.PluginMaker_ServicePrelude();
			"";
			NAmanage.PluginMaker_TemplateHelper();
			"";
		}
		if NAmanage.PluginMaker_Trim(pm.startupCode) ~= "" then
			NAmanage.PluginMaker_AppendRaw(lines, pm.startupCode, "")
			lines[#lines + 1] = ""
		end
		for _, command in pm.commands or {} do
			local name = NAmanage.PluginMaker_Trim(command.name)
			if name ~= "" and command.userButton == true then
				local label = NAmanage.PluginMaker_Trim(command.userButtonLabel)
				if label == "" then label = name end
				lines[#lines + 1] = "if type(addUserButton) == \"function\" then addUserButton({ Label = "..NAmanage.PluginMaker_Quote(label)..", Command = "..NAmanage.PluginMaker_Quote(name)..", SaveArgs = "..tostring(command.saveButtonArgs ~= false).." }) end"
			end
		end
		if #lines > 2 then
			lines[#lines + 1] = ""
		end
		lines[#lines + 1] = "return {"
		lines[#lines + 1] = "\tPluginName = "..NAmanage.PluginMaker_Quote(pm.pluginName)..";"
		lines[#lines + 1] = "\tPluginDescription = "..NAmanage.PluginMaker_Quote(pm.description)..";"
		lines[#lines + 1] = "\tCommands = {"
		for _, command in pm.commands or {} do
			local name = NAmanage.PluginMaker_Trim(command.name)
			if name ~= "" then
				local aliases = NAmanage.PluginMaker_SplitAliases(command.aliases)
				lines[#lines + 1] = "\t\t["..NAmanage.PluginMaker_Quote(name).."] = {"
				lines[#lines + 1] = "\t\t\tListName = "..NAmanage.PluginMaker_Quote(name)..";"
				if #aliases > 0 then
					local aliasText = {}
					for _, alias in aliases do
						if alias:lower() ~= name:lower() then
							aliasText[#aliasText + 1] = NAmanage.PluginMaker_Quote(alias)
						end
					end
					if #aliasText > 0 then
						lines[#lines + 1] = "\t\t\tAliases = {"..table.concat(aliasText, ", ").."};"
					end
				end
				if NAmanage.PluginMaker_Trim(command.argsHint) ~= "" then
					lines[#lines + 1] = "\t\t\tArgsHint = "..NAmanage.PluginMaker_Quote(command.argsHint)..";"
				end
				lines[#lines + 1] = "\t\t\tDescription = "..NAmanage.PluginMaker_Quote(command.description)..";"
				if command.requiresArgs == true then
					lines[#lines + 1] = "\t\t\tRequiresArguments = true;"
				end
				if command.overrideAliases == true then
					lines[#lines + 1] = "\t\t\tOverrideAliases = true;"
				end
				lines[#lines + 1] = "\t\t\tFunction = function(args, speaker)"
				lines[#lines + 1] = "\t\t\t\tlocal player = speaker"
				for _, ctxLine in NAmanage.PluginMaker_IYContextLines() do
					lines[#lines + 1] = ctxLine
				end
				for _, action in command.actions or {} do
					for _, actionLine in NAmanage.PluginMaker_ActionLines(action, "iy") do
						lines[#lines + 1] = actionLine:gsub("^\t\t", "\t\t\t\t")
					end
				end
				if NAmanage.PluginMaker_Trim(command.customCode) ~= "" then
					lines[#lines + 1] = "\t\t\t\t"
					NAmanage.PluginMaker_AppendRaw(lines, command.customCode, "\t\t\t\t")
				end
				lines[#lines + 1] = "\t\t\tend;"
				lines[#lines + 1] = "\t\t};"
			end
		end
		lines[#lines + 1] = "\t};"
		lines[#lines + 1] = "}"
		return table.concat(lines, "\n")
	end

	NAmanage.PluginMaker_Generate = function()
		local pm = NAStuff.PluginMaker
		if type(pm.commands) ~= "table" or #pm.commands == 0 then
			return nil, "Add at least one command"
		end
		if NAmanage.PluginMaker_Trim(pm.pluginName) == "" then
			return nil, "Plugin name is required"
		end
		local valid = 0
		local seen = {}
		for _, command in pm.commands do
			local name = NAmanage.PluginMaker_Trim(command.name)
			if name ~= "" then
				local key = name:lower()
				if seen[key] then
					return nil, "Duplicate command name: "..name
				end
				seen[key] = true
				valid += 1
			end
		end
		if valid == 0 then
			return nil, "At least one command needs a name"
		end
		if pm.format == "iy" then
			return NAmanage.PluginMaker_GenerateIY()
		end
		return NAmanage.PluginMaker_GenerateNA()
	end

	NAmanage.PluginMaker_CompileCheck = function(source)
		if type(source) ~= "string" or source == "" then
			return false, "Generated source is empty"
		end
		local loader = loadstring or load
		if type(loader) ~= "function" then
			return true, "Compile checker unavailable"
		end
		local ok, fn, err = pcall(loader, source, "@NAPluginMaker")
		if not ok then
			ok, fn, err = pcall(loader, source)
		end
		if not ok then
			return false, tostring(fn)
		end
		if not fn then
			return false, tostring(err or "Compile failed")
		end
		return true
	end

	NAmanage.PluginMaker_UniquePath = function(path)
		if type(isfile) ~= "function" or not isfile(path) then
			return path
		end
		local stem, ext = path:match("^(.*)(%.[^%.\\/]+)$")
		stem = stem or path
		ext = ext or ""
		for i = 2, 999 do
			local candidate = stem.."_"..tostring(i)..ext
			if not isfile(candidate) then
				return candidate
			end
		end
		return stem.."_"..tostring(os.time and os.time() or math.random(1000, 9999))..ext
	end

	NAmanage.PluginMaker_Save = function(install, conflictPolicy)
		local pm = NAStuff.PluginMaker
		local source, genErr = NAmanage.PluginMaker_Generate()
		if not source then
			return false, genErr
		end
		local compileOk, compileErr = NAmanage.PluginMaker_CompileCheck(source)
		if not compileOk then
			return false, "Compile check failed: "..tostring(compileErr)
		end
		if type(writefile) ~= "function" then
			return false, "writefile is unavailable"
		end
		local ext = pm.format == "iy" and ".iy" or ".na"
		local fileName = NAmanage.PluginMaker_SafeFileName(pm.fileName ~= "" and pm.fileName or pm.pluginName)
		fileName = fileName:gsub("%.[nN][aA]$", ""):gsub("%.[iI][yY]$", "")..ext
		local path = fileName
		if install == true then
			local folder = pm.format == "iy" and NAfiles.NAIYPLUGINFILEPATH or NAfiles.NAPLUGINFILEPATH
			if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(folder) then
				local okFolder = pcall(makefolder, folder)
				if not okFolder then
					return false, "Could not create plugin folder"
				end
			end
			path = folder.."/"..fileName
		end
		local exists = type(isfile) == "function" and isfile(path)
		if exists and conflictPolicy == nil then
			if type(NAmanage.PluginMaker_OpenSaveConflict) == "function" then
				NAmanage.PluginMaker_OpenSaveConflict(install, path)
				return nil, "conflict", path
			end
			path = NAmanage.PluginMaker_UniquePath(path)
		elseif exists and conflictPolicy == "copy" then
			path = NAmanage.PluginMaker_UniquePath(path)
		elseif exists and conflictPolicy == "backup" then
			if type(readfile) ~= "function" then
				return false, "readfile is unavailable for backup"
			end
			local stem, oldExt = path:match("^(.*)(%.[^%.\\/]+)$")
			stem = stem or path
			oldExt = oldExt or ""
			local backupPath = NAmanage.PluginMaker_UniquePath(stem.."_old"..oldExt)
			local okRead, oldSource = pcall(readfile, path)
			if not okRead then
				return false, "Failed to read existing plugin: "..tostring(oldSource)
			end
			local okBackup, backupErr = pcall(writefile, backupPath, oldSource)
			if not okBackup then
				return false, "Failed to back up existing plugin: "..tostring(backupErr)
			end
		end
		local okWrite, writeErr = pcall(writefile, path, source)
		if not okWrite then
			return false, tostring(writeErr)
		end
		if install == true and type(NAmanage.LoadPlugins) == "function" then
			pcall(NAmanage.LoadPlugins, { silent = true })
			if type(NAmanage.PluginsWindow_RequestRebuild) == "function" then
				pcall(NAmanage.PluginsWindow_RequestRebuild)
			end
		end
		pm.dirty = false
		return true, path, source
	end

	NAmanage.PluginMaker_ListPluginFiles = function()
		local out = {}
		if type(listfiles) ~= "function" then
			return out
		end
		local dirs = {
			{ path = NAfiles and NAfiles.NAPLUGINFILEPATH; format = "na" };
			{ path = NAfiles and NAfiles.NAIYPLUGINFILEPATH; format = "iy" };
		}
		for _, info in dirs do
			if type(info.path) == "string" and info.path ~= "" and (type(isfolder) ~= "function" or isfolder(info.path)) then
				local ok, items = pcall(listfiles, info.path)
				if ok and type(items) == "table" then
					for _, path in items do
						if type(path) == "string" then
							local low = path:lower()
							local valid = info.format == "na" and low:match("%.na$") or info.format == "iy" and low:match("%.iy$")
							if valid then
								out[#out + 1] = {
									path = path;
									format = info.format;
									name = path:match("[^\\/]+$") or path;
								}
							end
						end
					end
				end
			end
		end
		table.sort(out, function(a, b)
			return tostring(a.name):lower() < tostring(b.name):lower()
		end)
		return out
	end

	NAmanage.PluginMaker_ReloadPlugins = function()
		if type(NAmanage.LoadPlugins) == "function" then
			pcall(NAmanage.LoadPlugins, { silent = true })
		end
		if type(NAmanage.PluginsWindow_RequestRebuild) == "function" then
			pcall(NAmanage.PluginsWindow_RequestRebuild)
		end
	end

	NAmanage.PluginMaker_OpenInstalledManager = function()
		local pm = NAStuff.PluginMaker
		if type(NAmanage.PluginsWindow_SetVisible) == "function" then
			NAmanage.PluginsWindow_SetVisible(true)
			return true
		end
		if type(NAmanage.PluginsWindow_Toggle) == "function" then
			NAmanage.PluginsWindow_Toggle(true)
			return true
		end
		NAmanage.PluginMaker_SetStatus("Plugins window is unavailable", "error")
		return false
	end

	NAmanage.PluginMaker_EnsureSaveConflict = function()
		local pm = NAStuff.PluginMaker
		if pm.SaveConflictOverlay and pm.SaveConflictOverlay.Parent == pm.Frame then
			return true
		end
		if not pm.Frame or not pm.Frame.Parent then
			return false
		end
		pm.SaveConflictOverlay = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			Name = "SaveConflictOverlay";
			BackgroundColor3 = Color3.fromRGB(4, 4, 7);
			BackgroundTransparency = 0.2;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = false;
			Active = true;
			ZIndex = 160;
		})
		local card = NAmanage.PluginMaker_New("Frame", pm.SaveConflictOverlay, {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(0, 390, 0, 250);
			BackgroundColor3 = Color3.fromRGB(19, 20, 27);
			BorderSizePixel = 0;
			ZIndex = 161;
		})
		NAmanage.PluginMaker_Corner(card, 9)
		NAmanage.PluginMaker_Stroke(card, 0.35)
		local constraint = NAmanage.PluginMaker_New("UISizeConstraint", card, {})
		constraint.MinSize = Vector2.new(250, 230)
		constraint.MaxSize = Vector2.new(430, 280)

		local title = NAmanage.PluginMaker_Label(card, "Plugin File Already Exists", 14)
		title.Position = UDim2.new(0, 12, 0, 10)
		title.Size = UDim2.new(1, -24, 0, 24)
		title.Font = Enum.Font.GothamBold
		title.TextColor3 = Color3.fromRGB(255, 205, 135)
		title.ZIndex = 162

		pm.SaveConflictPath = NAmanage.PluginMaker_Label(card, "", 10)
		pm.SaveConflictPath.Position = UDim2.new(0, 12, 0, 38)
		pm.SaveConflictPath.Size = UDim2.new(1, -24, 0, 42)
		pm.SaveConflictPath.TextColor3 = Color3.fromRGB(165, 168, 185)
		pm.SaveConflictPath.TextYAlignment = Enum.TextYAlignment.Top
		pm.SaveConflictPath.ZIndex = 162

		local choices = NAmanage.PluginMaker_New("Frame", card, {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 12, 0, 86);
			Size = UDim2.new(1, -24, 1, -98);
			ZIndex = 162;
		})
		local layout = NAmanage.PluginMaker_New("UIListLayout", choices, {
			Padding = UDim.new(0, 6);
			SortOrder = Enum.SortOrder.LayoutOrder;
		})

		local function finish(policy)
			local pending = pm.PendingSaveConflict
			pm.SaveConflictOverlay.Visible = false
			pm.PendingSaveConflict = nil
			if not pending then
				return
			end
			local ok, path = NAmanage.PluginMaker_Save(pending.install == true, policy)
			if ok then
				NAmanage.PluginMaker_SetStatus((pending.install and "Installed " or "Saved ")..tostring(path), "success")
				DoNotif((pending.install and "Plugin Maker installed " or "Plugin Maker saved ")..tostring(path), 3)
			elseif ok == false then
				NAmanage.PluginMaker_SetStatus(tostring(path), "error")
			end
		end

		local overwrite = NAmanage.PluginMaker_Button(choices, "Overwrite Existing", function()
			finish("overwrite")
		end)
		overwrite.Size = UDim2.new(1, 0, 0, 31)
		overwrite.BackgroundColor3 = Color3.fromRGB(105, 45, 55)

		local copy = NAmanage.PluginMaker_Button(choices, "Save As Copy (_2, _3, ...)", function()
			finish("copy")
		end)
		copy.Size = UDim2.new(1, 0, 0, 31)

		local backup = NAmanage.PluginMaker_Button(choices, "Back Up Existing As _old, Then Replace", function()
			finish("backup")
		end)
		backup.Size = UDim2.new(1, 0, 0, 31)
		backup.BackgroundColor3 = Color3.fromRGB(75, 58, 105)

		local cancel = NAmanage.PluginMaker_Button(choices, "Cancel", function()
			pm.PendingSaveConflict = nil
			pm.SaveConflictOverlay.Visible = false
			NAmanage.PluginMaker_SetStatus("Save cancelled", "warn")
		end)
		cancel.Size = UDim2.new(1, 0, 0, 31)
		return true
	end

	NAmanage.PluginMaker_OpenSaveConflict = function(install, path)
		local pm = NAStuff.PluginMaker
		if not NAmanage.PluginMaker_EnsureSaveConflict() then
			return false
		end
		pm.PendingSaveConflict = {
			install = install == true;
			path = path;
		}
		pm.SaveConflictPath.Text = "A file already exists at:\n"..tostring(path)
		pm.SaveConflictOverlay.Visible = true
		NAmanage.PluginMaker_SetStatus("Choose how to handle the existing file", "warn")
		return true
	end

	NAmanage.PluginMaker_EnsureFilePicker = function()
		local pm = NAStuff.PluginMaker
		if pm.FilePickerOverlay and pm.FilePickerOverlay.Parent == pm.Frame then
			return true
		end
		if not pm.Frame or not pm.Frame.Parent then
			return false
		end

		pm.FilePickerOverlay = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			Name = "PluginFilePicker";
			BackgroundColor3 = Color3.fromRGB(4, 4, 7);
			BackgroundTransparency = 0.22;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = false;
			Active = true;
			ZIndex = 150;
		})
		local card = NAmanage.PluginMaker_New("Frame", pm.FilePickerOverlay, {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(0.66, 0, 0.75, 0);
			BackgroundColor3 = Color3.fromRGB(18, 19, 25);
			BorderSizePixel = 0;
			ZIndex = 151;
		})
		NAmanage.PluginMaker_Corner(card, 9)
		NAmanage.PluginMaker_Stroke(card, 0.38)
		local constraint = NAmanage.PluginMaker_New("UISizeConstraint", card, {})
		constraint.MinSize = Vector2.new(260, 240)
		constraint.MaxSize = Vector2.new(560, 480)

		local title = NAmanage.PluginMaker_Label(card, "Edit Existing Plugin", 14)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.Size = UDim2.new(1, -88, 0, 24)
		title.Font = Enum.Font.GothamBold
		title.ZIndex = 152

		local close = NAmanage.PluginMaker_Button(card, "Close", function()
			pm.FilePickerOverlay.Visible = false
		end)
		close.AnchorPoint = Vector2.new(1, 0)
		close.Position = UDim2.new(1, -8, 0, 7)
		close.Size = UDim2.new(0, 66, 0, 26)
		close.ZIndex = 153

		pm.FilePickerSearch = NAmanage.PluginMaker_Input(card, "Search installed .na / .iy plugins...", "", function()
			if type(NAmanage.PluginMaker_RefreshFilePicker) == "function" then
				NAmanage.PluginMaker_RefreshFilePicker()
			end
		end)
		pm.FilePickerSearch.Position = UDim2.new(0, 10, 0, 38)
		pm.FilePickerSearch.Size = UDim2.new(1, -20, 0, 30)
		pm.FilePickerSearch.ZIndex = 152
		pm.FilePickerSearch:GetPropertyChangedSignal("Text"):Connect(function()
			if pm.FilePickerOverlay and pm.FilePickerOverlay.Visible then
				NAmanage.PluginMaker_RefreshFilePicker()
			end
		end)

		pm.FilePickerList = NAmanage.PluginMaker_New("ScrollingFrame", card, {
			BackgroundColor3 = Color3.fromRGB(12, 13, 17);
			BackgroundTransparency = 0.08;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 10, 0, 76);
			Size = UDim2.new(1, -20, 1, -86);
			CanvasSize = UDim2.new();
			ScrollBarThickness = 4;
			ScrollingDirection = Enum.ScrollingDirection.Y;
			ZIndex = 152;
		})
		NAmanage.PluginMaker_Corner(pm.FilePickerList, 7)
		NAmanage.PluginMaker_Stroke(pm.FilePickerList, 0.8)
		return true
	end

	NAmanage.PluginMaker_OpenExistingFile = function(entry)
		local pm = NAStuff.PluginMaker
		if type(entry) ~= "table" or type(entry.path) ~= "string" or type(readfile) ~= "function" then
			return
		end
		local ok, source = pcall(readfile, entry.path)
		if not ok then
			NAmanage.PluginMaker_SetStatus("Failed to read "..tostring(entry.name)..": "..tostring(source), "error")
			return
		end
		if not NAmanage.PluginMaker_EnsureCodeEditor() then
			return
		end
		pm.FilePickerOverlay.Visible = false
		pm.codeEditTarget = "file"
		pm.codeEditPath = entry.path
		pm.codeEditFormat = entry.format
		pm.CodeTitle.Text = "Edit Existing - "..tostring(entry.name)
		pm.CodeHint.Text = "Raw plugin source. Save Code compile-checks it, writes it back to the same file, then reloads NA plugins."
		pm.CodeBox.Text = tostring(source or "")
		pm.CodeOverlay.Visible = true
	end

	NAmanage.PluginMaker_RefreshFilePicker = function()
		local pm = NAStuff.PluginMaker
		local list = pm.FilePickerList
		if not list or not list.Parent then
			return
		end
		NAmanage.PluginMaker_ClearGui(list)
		local layout = NAmanage.PluginMaker_New("UIListLayout", list, {
			Padding = UDim.new(0, 5);
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local pad = NAmanage.PluginMaker_New("UIPadding", list, {})
		pad.PaddingTop = UDim.new(0, 6)
		pad.PaddingBottom = UDim.new(0, 6)
		pad.PaddingLeft = UDim.new(0, 6)
		pad.PaddingRight = UDim.new(0, 6)

		local query = tostring(pm.FilePickerSearch and pm.FilePickerSearch.Text or ""):lower()
		local count = 0
		for _, entry in NAmanage.PluginMaker_ListPluginFiles() do
			local hay = (tostring(entry.name).." "..tostring(entry.format).." "..tostring(entry.path)):lower()
			if query == "" or hay:find(query, 1, true) then
				count += 1
				local row = NAmanage.PluginMaker_New("Frame", list, {
					BackgroundColor3 = Color3.fromRGB(31, 32, 41);
					BackgroundTransparency = 0.08;
					BorderSizePixel = 0;
					Size = UDim2.new(1, -2, 0, 40);
				})
				NAmanage.PluginMaker_Corner(row, 6)
				NAmanage.PluginMaker_Stroke(row, 0.84)
				local tag = NAmanage.PluginMaker_Label(row, entry.format == "iy" and "IY" or "NA", 10)
				tag.Position = UDim2.new(0, 7, 0.5, -11)
				tag.Size = UDim2.new(0, 28, 0, 22)
				tag.TextXAlignment = Enum.TextXAlignment.Center
				tag.BackgroundTransparency = 0
				tag.BackgroundColor3 = entry.format == "iy" and Color3.fromRGB(57, 74, 102) or Color3.fromRGB(75, 58, 105)
				NAmanage.PluginMaker_Corner(tag, 5)
				local name = NAmanage.PluginMaker_Label(row, entry.name, 11)
				name.Position = UDim2.new(0, 42, 0, 0)
				name.Size = UDim2.new(1, -122, 1, 0)
				name.TextTruncate = Enum.TextTruncate.AtEnd
				local edit = NAmanage.PluginMaker_Button(row, "Edit", function()
					NAmanage.PluginMaker_OpenExistingFile(entry)
				end)
				edit.AnchorPoint = Vector2.new(1, 0.5)
				edit.Position = UDim2.new(1, -7, 0.5, 0)
				edit.Size = UDim2.new(0, 64, 0, 26)
				edit.BackgroundColor3 = Color3.fromRGB(75, 58, 105)
			end
		end
		if count == 0 then
			local empty = NAmanage.PluginMaker_Label(list, "No matching installed plugins.", 11)
			empty.Size = UDim2.new(1, -2, 0, 42)
			empty.TextXAlignment = Enum.TextXAlignment.Center
			empty.TextColor3 = Color3.fromRGB(150, 153, 170)
		end
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if list and list.Parent then
				list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
			end
		end)
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end

	NAmanage.PluginMaker_OpenFilePicker = function()
		local pm = NAStuff.PluginMaker
		if not NAmanage.PluginMaker_EnsureFilePicker() then
			return
		end
		pm.FilePickerOverlay.Visible = true
		NAmanage.PluginMaker_RefreshFilePicker()
	end

	NAmanage.PluginMaker_ToggleMinimize = function()
		local pm = NAStuff.PluginMaker
		local frame = pm.Frame
		if not frame or not frame.Parent then
			return
		end
		pm.minimized = not (pm.minimized == true)
		if pm.minimized then
			pm.restoreSize = frame.Size
			if pm.ResizeCleanup then
				pcall(pm.ResizeCleanup)
				pm.ResizeCleanup = nil
			end
			if pm.Meta then pm.Meta.Visible = false end
			if pm.Workspace then pm.Workspace.Visible = false end
			if pm.Footer then pm.Footer.Visible = false end
			if pm.PreviewOverlay then pm.PreviewOverlay.Visible = false end
			if pm.ActionPickerOverlay then pm.ActionPickerOverlay.Visible = false end
			if pm.CodeOverlay then pm.CodeOverlay.Visible = false end
			if pm.FilePickerOverlay then pm.FilePickerOverlay.Visible = false end
			if pm.SaveConflictOverlay then pm.SaveConflictOverlay.Visible = false end
			NAmanage.SetAttr(frame, "NAMenuMinimized", true)
			frame.Size = UDim2.fromOffset(math.max(260, frame.Size.X.Offset), 44)
			if pm.MinimizeButton then pm.MinimizeButton.Text = "+" end
		else
			NAmanage.SetAttr(frame, "NAMenuMinimized", false)
			frame.Size = pm.restoreSize or UDim2.fromOffset(900, 620)
			if pm.Meta then pm.Meta.Visible = true end
			if pm.Workspace then pm.Workspace.Visible = true end
			if pm.Footer then pm.Footer.Visible = true end
			if pm.MinimizeButton then pm.MinimizeButton.Text = "-" end
			NAmanage.PluginMaker_ApplyLayout()
			NAmanage.PluginMaker_BindResize()
		end
	end

	NAmanage.PluginMaker_ProbeService = function(name)
		name = NAmanage.PluginMaker_Trim(name)
		if name == "" then
			return false, "empty service name"
		end
		if type(NAmanage.NA_getServiceRef) == "function" then
			local ok, service = pcall(NAmanage.NA_getServiceRef, name)
			if ok and typeof(service) == "Instance" then
				return true, service
			end
		end
		if type(NAmanage.NA_getServiceRaw) == "function" then
			local ok, service = pcall(NAmanage.NA_getServiceRaw, name)
			if ok and typeof(service) == "Instance" then
				return true, service
			end
		end
		return false, nil
	end

	NAmanage.PluginMaker_UpdateServiceButton = function()
		local pm = NAStuff.PluginMaker
		if pm.ServicesButton and pm.ServicesButton.Parent then
			local count = #NAmanage.PluginMaker_GetSelectedServices()
			pm.ServicesButton.Text = "Services ("..tostring(count)..")"
			pm.ServicesButton.BackgroundColor3 = count > 0 and Color3.fromRGB(75, 58, 105) or Color3.fromRGB(42, 43, 54)
		end
	end

	NAmanage.PluginMaker_SelectServicePreset = function(kind)
		local pm = NAStuff.PluginMaker
		pm.selectedServices = type(pm.selectedServices) == "table" and pm.selectedServices or {}
		if kind == "clear" then
			pm.selectedServices = {}
		elseif kind == "common" then
			pm.selectedServices = {
				Players = true;
				Workspace = true;
				RunService = true;
				TweenService = true;
				UserInputService = true;
				HttpService = true;
				ReplicatedStorage = true;
				Lighting = true;
			}
		elseif kind == "all" then
			local selected = {}
			for _, name in NAmanage.PluginMaker_GetServiceCatalog() do
				selected[name] = true
			end
			pm.selectedServices = selected
		end
		pm.dirty = true
		NAmanage.PluginMaker_UpdateServiceButton()
		if type(NAmanage.PluginMaker_RefreshServicePicker) == "function" then
			NAmanage.PluginMaker_RefreshServicePicker()
		end
	end

	NAmanage.PluginMaker_EnsureServicePicker = function()
		local pm = NAStuff.PluginMaker
		if pm.ServiceOverlay and pm.ServiceOverlay.Parent == pm.Frame then
			return true
		end
		if not pm.Frame or not pm.Frame.Parent then
			return false
		end

		pm.ServiceOverlay = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			Name = "ServicePicker";
			BackgroundColor3 = Color3.fromRGB(4, 4, 7);
			BackgroundTransparency = 0.2;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = false;
			Active = true;
			ZIndex = 170;
		})

		local card = NAmanage.PluginMaker_New("Frame", pm.ServiceOverlay, {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(0.72, 0, 0.84, 0);
			BackgroundColor3 = Color3.fromRGB(18, 19, 25);
			BorderSizePixel = 0;
			ZIndex = 171;
		})
		NAmanage.PluginMaker_Corner(card, 9)
		NAmanage.PluginMaker_Stroke(card, 0.35)
		local sizeConstraint = NAmanage.PluginMaker_New("UISizeConstraint", card, {})
		sizeConstraint.MinSize = Vector2.new(280, 300)
		sizeConstraint.MaxSize = Vector2.new(620, 560)

		local title = NAmanage.PluginMaker_Label(card, "Services - NA ServiceResolver", 14)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.Size = UDim2.new(1, -90, 0, 22)
		title.Font = Enum.Font.GothamBold
		title.ZIndex = 172

		local close = NAmanage.PluginMaker_Button(card, "Done", function()
			pm.ServiceOverlay.Visible = false
			NAmanage.PluginMaker_UpdateServiceButton()
			NAmanage.PluginMaker_RebuildEditor()
		end)
		close.AnchorPoint = Vector2.new(1, 0)
		close.Position = UDim2.new(1, -8, 0, 7)
		close.Size = UDim2.new(0, 68, 0, 26)
		close.BackgroundColor3 = Color3.fromRGB(75, 58, 105)
		close.ZIndex = 173

		local info = NAmanage.PluginMaker_Label(card, "Pick only what the plugin needs. Catalog + live DataModel services + custom names; ServiceResolver is the only service resolution path.", 10)
		info.Position = UDim2.new(0, 10, 0, 31)
		info.Size = UDim2.new(1, -20, 0, 32)
		info.TextColor3 = Color3.fromRGB(155, 158, 176)
		info.TextYAlignment = Enum.TextYAlignment.Top
		info.ZIndex = 172

		pm.ServiceSearch = NAmanage.PluginMaker_Input(card, "Search services...", "", function()
			NAmanage.PluginMaker_RefreshServicePicker()
		end)
		pm.ServiceSearch.Position = UDim2.new(0, 10, 0, 66)
		pm.ServiceSearch.Size = UDim2.new(1, -20, 0, 30)
		pm.ServiceSearch.ZIndex = 172
		pm.ServiceSearch:GetPropertyChangedSignal("Text"):Connect(function()
			if pm.ServiceOverlay and pm.ServiceOverlay.Visible then
				NAmanage.PluginMaker_RefreshServicePicker()
			end
		end)

		pm.ServiceList = NAmanage.PluginMaker_New("ScrollingFrame", card, {
			BackgroundColor3 = Color3.fromRGB(12, 13, 17);
			BackgroundTransparency = 0.06;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 10, 0, 102);
			Size = UDim2.new(1, -20, 1, -194);
			CanvasSize = UDim2.new();
			ScrollBarThickness = 4;
			ScrollingDirection = Enum.ScrollingDirection.Y;
			ZIndex = 172;
		})
		NAmanage.PluginMaker_Corner(pm.ServiceList, 7)
		NAmanage.PluginMaker_Stroke(pm.ServiceList, 0.8)

		local customRow = NAmanage.PluginMaker_New("Frame", card, {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 10, 1, -86);
			Size = UDim2.new(1, -20, 0, 30);
			ZIndex = 172;
		})
		pm.CustomServiceBox = NAmanage.PluginMaker_Input(customRow, "Custom service name...", "", nil)
		pm.CustomServiceBox.Position = UDim2.new(0, 0, 0, 0)
		pm.CustomServiceBox.Size = UDim2.new(1, -88, 1, 0)
		local addCustom = NAmanage.PluginMaker_Button(customRow, "Add", function()
			local name = NAmanage.PluginMaker_Trim(pm.CustomServiceBox and pm.CustomServiceBox.Text or "")
			if not name:match("^[%a_][%w_]*$") then
				NAmanage.PluginMaker_SetStatus("Invalid service name", "error")
				return
			end
			pm.customServices = type(pm.customServices) == "table" and pm.customServices or {}
			local exists = false
			for _, current in pm.customServices do
				if tostring(current):lower() == name:lower() then
					exists = true
					break
				end
			end
			if not exists then
				pm.customServices[#pm.customServices + 1] = name
			end
			pm.selectedServices[name] = true
			pm.CustomServiceBox.Text = ""
			pm.dirty = true
			NAmanage.PluginMaker_UpdateServiceButton()
			NAmanage.PluginMaker_RefreshServicePicker()
		end)
		addCustom.AnchorPoint = Vector2.new(1, 0)
		addCustom.Position = UDim2.new(1, 0, 0, 0)
		addCustom.Size = UDim2.new(0, 82, 1, 0)
		addCustom.BackgroundColor3 = Color3.fromRGB(57, 74, 102)

		pm.ServiceSelectedLabel = NAmanage.PluginMaker_Label(card, "", 10)
		pm.ServiceSelectedLabel.Position = UDim2.new(0, 10, 1, -52)
		pm.ServiceSelectedLabel.Size = UDim2.new(0.28, -5, 0, 26)
		pm.ServiceSelectedLabel.TextColor3 = Color3.fromRGB(165, 168, 185)
		pm.ServiceSelectedLabel.ZIndex = 172

		local presetRow = NAmanage.PluginMaker_New("Frame", card, {
			BackgroundTransparency = 1;
			Position = UDim2.new(0.28, 5, 1, -52);
			Size = UDim2.new(0.72, -15, 0, 26);
			ZIndex = 172;
		})
		local grid = NAmanage.PluginMaker_New("UIGridLayout", presetRow, {
			CellPadding = UDim2.new(0, 5, 0, 0);
			CellSize = UDim2.new(0.333333, -4, 1, 0);
			FillDirectionMaxCells = 3;
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		NAmanage.PluginMaker_Button(presetRow, "Common", function()
			NAmanage.PluginMaker_SelectServicePreset("common")
		end)
		NAmanage.PluginMaker_Button(presetRow, "All", function()
			NAmanage.PluginMaker_SelectServicePreset("all")
		end)
		local clear = NAmanage.PluginMaker_Button(presetRow, "Clear", function()
			NAmanage.PluginMaker_SelectServicePreset("clear")
		end)
		clear.TextColor3 = Color3.fromRGB(255, 165, 170)
		return true
	end

	NAmanage.PluginMaker_RefreshServicePicker = function()
		local pm = NAStuff.PluginMaker
		local list = pm.ServiceList
		if not list or not list.Parent then
			return
		end
		NAmanage.PluginMaker_NormalizeServices()
		NAmanage.PluginMaker_ClearGui(list)
		local layout = NAmanage.PluginMaker_New("UIListLayout", list, {
			Padding = UDim.new(0, 4);
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local padding = NAmanage.PluginMaker_New("UIPadding", list, {})
		padding.PaddingTop = UDim.new(0, 5)
		padding.PaddingBottom = UDim.new(0, 5)
		padding.PaddingLeft = UDim.new(0, 5)
		padding.PaddingRight = UDim.new(0, 5)

		local query = tostring(pm.ServiceSearch and pm.ServiceSearch.Text or ""):lower()
		local visibleCount = 0
		for _, name in NAmanage.PluginMaker_GetServiceCatalog() do
			if query == "" or name:lower():find(query, 1, true) then
				visibleCount += 1
				local selected = pm.selectedServices[name] == true
				local button = NAmanage.PluginMaker_Button(list, (selected and "✓  " or "    ")..name, function()
					local enable = not (pm.selectedServices[name] == true)
					pm.selectedServices[name] = enable
					pm.dirty = true
					if enable then
						local available = NAmanage.PluginMaker_ProbeService(name)
						if available then
							NAmanage.PluginMaker_SetStatus(name.." selected through ServiceResolver", "success")
						else
							NAmanage.PluginMaker_SetStatus(name.." selected; ServiceResolver may return nil in this client/context", "warn")
						end
					end
					NAmanage.PluginMaker_UpdateServiceButton()
					NAmanage.PluginMaker_RefreshServicePicker()
				end)
				button.Size = UDim2.new(1, -2, 0, 30)
				button.TextXAlignment = Enum.TextXAlignment.Left
				if selected then
					button.BackgroundColor3 = Color3.fromRGB(75, 58, 105)
					button.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
				local pad = button:FindFirstChildOfClass("UIPadding")
				if pad then pad.PaddingLeft = UDim.new(0, 9) end
			end
		end
		if visibleCount == 0 then
			local empty = NAmanage.PluginMaker_Label(list, "No matching services. Use Custom Service below.", 11)
			empty.Size = UDim2.new(1, -2, 0, 40)
			empty.TextXAlignment = Enum.TextXAlignment.Center
			empty.TextColor3 = Color3.fromRGB(145, 148, 165)
		end
		if pm.ServiceSelectedLabel then
			pm.ServiceSelectedLabel.Text = tostring(#NAmanage.PluginMaker_GetSelectedServices()).." selected"
		end
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if list and list.Parent then
				list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
			end
		end)
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end

	NAmanage.PluginMaker_OpenServicePicker = function()
		local pm = NAStuff.PluginMaker
		if not NAmanage.PluginMaker_EnsureServicePicker() then
			return
		end
		pm.ServiceOverlay.Visible = true
		NAmanage.PluginMaker_RefreshServicePicker()
	end

	NAmanage.PluginMaker_SetStatus = function(text, kind)
		local pm = NAStuff.PluginMaker
		if pm.Status and pm.Status.Parent then
			pm.Status.Text = tostring(text or "")
			if kind == "error" then
				pm.Status.TextColor3 = Color3.fromRGB(255, 125, 135)
			elseif kind == "success" then
				pm.Status.TextColor3 = Color3.fromRGB(135, 230, 160)
			elseif kind == "warn" then
				pm.Status.TextColor3 = Color3.fromRGB(245, 205, 125)
			else
				pm.Status.TextColor3 = Color3.fromRGB(175, 178, 195)
			end
		end
	end

	NAmanage.PluginMaker_New = function(className, parent, props)
		local obj = InstanceNew(className)
		local hasExplicitZ = type(props) == "table" and props.ZIndex ~= nil
		if type(props) == "table" then
			for key, value in props do
				pcall(function()
					obj[key] = value
				end)
			end
		end
		if not hasExplicitZ and obj:IsA("GuiObject") and typeof(parent) == "Instance" and parent:IsA("GuiObject") then
			pcall(function()
				obj.ZIndex = math.max(1, parent.ZIndex + 1)
			end)
		end
		obj.Parent = parent
		return obj
	end

	NAmanage.PluginMaker_SyncZIndex = function(root)
		if typeof(root) ~= "Instance" then
			return
		end
		local function sync(parent)
			for _, child in parent:GetChildren() do
				if child:IsA("GuiObject") then
					if parent:IsA("GuiObject") and child.ZIndex <= parent.ZIndex then
						child.ZIndex = parent.ZIndex + 1
					end
					sync(child)
				end
			end
		end
		sync(root)
	end

	NAmanage.PluginMaker_Corner = function(obj, radius)
		local corner = NAmanage.PluginMaker_New("UICorner", obj, {})
		corner.CornerRadius = UDim.new(0, radius or 6)
		return corner
	end

	NAmanage.PluginMaker_Stroke = function(obj, transparency)
		local stroke = NAmanage.PluginMaker_New("UIStroke", obj, {
			Thickness = 1;
			Color = NAUISTROKER or Color3.fromRGB(155, 100, 255);
			Transparency = transparency == nil and 0.55 or transparency;
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
		})
		return stroke
	end

	NAmanage.PluginMaker_Button = function(parent, text, callback)
		local button = NAmanage.PluginMaker_New("TextButton", parent, {
			AutoButtonColor = false;
			BackgroundColor3 = Color3.fromRGB(42, 43, 54);
			BackgroundTransparency = 0.08;
			BorderSizePixel = 0;
			Font = Enum.Font.Gotham;
			Text = tostring(text or "Button");
			TextColor3 = Color3.fromRGB(238, 239, 245);
			TextSize = 12;
			TextWrapped = true;
		})
		NAmanage.PluginMaker_Corner(button, 6)
		NAmanage.PluginMaker_Stroke(button, 0.72)
		button.MouseButton1Click:Connect(function()
			if type(callback) == "function" then
				pcall(callback)
			end
		end)
		return button
	end

	NAmanage.PluginMaker_Input = function(parent, placeholder, text, callback)
		local box = NAmanage.PluginMaker_New("TextBox", parent, {
			BackgroundColor3 = Color3.fromRGB(29, 30, 39);
			BackgroundTransparency = 0.08;
			BorderSizePixel = 0;
			ClearTextOnFocus = false;
			Font = Enum.Font.Gotham;
			PlaceholderText = tostring(placeholder or "");
			PlaceholderColor3 = Color3.fromRGB(135, 138, 155);
			Text = tostring(text or "");
			TextColor3 = Color3.fromRGB(238, 239, 245);
			TextSize = 12;
			TextXAlignment = Enum.TextXAlignment.Left;
		})
		NAmanage.PluginMaker_Corner(box, 6)
		NAmanage.PluginMaker_Stroke(box, 0.76)
		local pad = NAmanage.PluginMaker_New("UIPadding", box, {})
		pad.PaddingLeft = UDim.new(0, 8)
		pad.PaddingRight = UDim.new(0, 8)
		box.FocusLost:Connect(function()
			if type(callback) == "function" then
				pcall(callback, box.Text)
			end
		end)
		return box
	end

	NAmanage.PluginMaker_Label = function(parent, text, size)
		return NAmanage.PluginMaker_New("TextLabel", parent, {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Font = Enum.Font.Gotham;
			Text = tostring(text or "");
			TextColor3 = Color3.fromRGB(205, 207, 220);
			TextSize = size or 12;
			TextWrapped = true;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Center;
		})
	end

	NAmanage.PluginMaker_ClearGui = function(parent)
		if not parent then return end
		for _, child in parent:GetChildren() do
			child:Destroy()
		end
	end

	NAmanage.PluginMaker_ActionName = function(kind)
		local names = {
			notify = "Notify";
			run = "Run NA Command";
			load_url = "Load URL / loadstring";
			wait = "Wait";
			print = "Print";
			copy = "Copy Text";
			mobile_run = "Run Command - Mobile Only";
			pc_run = "Run Command - PC Only";
			mobile_notify = "Notify - Mobile Only";
			pc_notify = "Notify - PC Only";
			add_button = "Add User Button";
			remove_button = "Remove User Button";
			stop = "Stop Command";
			custom = "Custom Lua";
		}
		return names[tostring(kind or "")] or tostring(kind or "Action")
	end

	NAmanage.PluginMaker_ActionTypes = {
		"notify";
		"run";
		"load_url";
		"wait";
		"print";
		"copy";
		"mobile_run";
		"pc_run";
		"mobile_notify";
		"pc_notify";
		"add_button";
		"remove_button";
		"stop";
		"custom";
	}

	NAmanage.PluginMaker_RebuildCommandList = function()
		local pm = NAStuff.PluginMaker
		local list = pm.CommandList
		if not list or not list.Parent then return end
		NAmanage.PluginMaker_ClearGui(list)
		local layout = NAmanage.PluginMaker_New("UIListLayout", list, {
			Padding = UDim.new(0, 5);
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local pad = NAmanage.PluginMaker_New("UIPadding", list, {})
		pad.PaddingTop = UDim.new(0, 6)
		pad.PaddingBottom = UDim.new(0, 6)
		pad.PaddingLeft = UDim.new(0, 6)
		pad.PaddingRight = UDim.new(0, 6)
		for index, command in pm.commands or {} do
			local button = NAmanage.PluginMaker_Button(list, tostring(command.name ~= "" and command.name or ("Command "..index)), function()
				pm.selectedCommand = index
				NAmanage.PluginMaker_RebuildCommandList()
				NAmanage.PluginMaker_RebuildEditor()
			end)
			button.Size = UDim2.new(1, -2, 0, 34)
			if index == pm.selectedCommand then
				button.BackgroundColor3 = Color3.fromRGB(75, 58, 105)
				button.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if list and list.Parent then
				list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
			end
		end)
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
	end

	NAmanage.PluginMaker_ActionExtraHint = function(kind)
		if kind == "notify" or kind == "mobile_notify" or kind == "pc_notify" then
			return "Duration seconds"
		elseif kind == "add_button" then
			return "Command to run"
		elseif kind == "load_url" then
			return "No extra value needed"
		elseif kind == "wait" then
			return "Optional seconds"
		end
		return "Extra value"
	end

	NAmanage.PluginMaker_ActionValueHint = function(kind)
		if kind == "notify" or kind == "print" or kind == "copy" or kind == "mobile_notify" or kind == "pc_notify" then
			return "Text; placeholders supported"
		elseif kind == "run" or kind == "mobile_run" or kind == "pc_run" then
			return "NA command, e.g. fly 50"
		elseif kind == "load_url" then
			return "Raw script URL, e.g. https://raw.githubusercontent.com/..."
		elseif kind == "wait" then
			return "Seconds"
		elseif kind == "add_button" then
			return "Button label"
		elseif kind == "remove_button" then
			return "Button label or id"
		elseif kind == "custom" then
			return "Lua/Luau code"
		elseif kind == "stop" then
			return "No value needed"
		end
		return "Value"
	end

	NAmanage.PluginMaker_EnsureActionPicker = function()
		local pm = NAStuff.PluginMaker
		if pm.ActionPickerOverlay and pm.ActionPickerOverlay.Parent == pm.Frame then
			return true
		end
		if not pm.Frame or not pm.Frame.Parent then
			return false
		end

		pm.ActionPickerOverlay = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			Name = "ActionPickerOverlay";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = false;
			Active = true;
			ZIndex = 130;
		})

		local card = NAmanage.PluginMaker_New("Frame", pm.ActionPickerOverlay, {
			Name = "ActionPickerCard";
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(0.55, 0, 0.72, 0);
			BackgroundColor3 = Color3.fromRGB(20, 21, 28);
			BackgroundTransparency = 0.02;
			BorderSizePixel = 0;
			ZIndex = 131;
		})
		NAmanage.PluginMaker_Corner(card, 9)
		NAmanage.PluginMaker_Stroke(card, 0.35)

		local sizeConstraint = NAmanage.PluginMaker_New("UISizeConstraint", card, {})
		sizeConstraint.MinSize = Vector2.new(240, 220)
		sizeConstraint.MaxSize = Vector2.new(420, 420)

		local title = NAmanage.PluginMaker_Label(card, "Choose Action", 14)
		title.Position = UDim2.new(0, 12, 0, 8)
		title.Size = UDim2.new(1, -92, 0, 24)
		title.Font = Enum.Font.GothamBold
		title.TextColor3 = Color3.fromRGB(245, 246, 250)
		title.ZIndex = 132

		local close = NAmanage.PluginMaker_Button(card, "Close", function()
			pm.ActionPickerOverlay.Visible = false
		end)
		close.AnchorPoint = Vector2.new(1, 0)
		close.Position = UDim2.new(1, -8, 0, 7)
		close.Size = UDim2.new(0, 66, 0, 26)
		close.ZIndex = 133

		local hint = NAmanage.PluginMaker_Label(card, "Select what the command should do. The picker closes after selection.", 10)
		hint.Position = UDim2.new(0, 12, 0, 34)
		hint.Size = UDim2.new(1, -24, 0, 30)
		hint.TextColor3 = Color3.fromRGB(160, 163, 180)
		hint.ZIndex = 132

		local list = NAmanage.PluginMaker_New("ScrollingFrame", card, {
			Name = "ActionPickerList";
			BackgroundColor3 = Color3.fromRGB(15, 16, 21);
			BackgroundTransparency = 0.08;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 10, 0, 68);
			Size = UDim2.new(1, -20, 1, -78);
			CanvasSize = UDim2.new();
			ScrollBarThickness = 4;
			ScrollingDirection = Enum.ScrollingDirection.Y;
			ZIndex = 132;
		})
		NAmanage.PluginMaker_Corner(list, 7)
		NAmanage.PluginMaker_Stroke(list, 0.78)
		local layout = NAmanage.PluginMaker_New("UIListLayout", list, {
			Padding = UDim.new(0, 5);
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local padding = NAmanage.PluginMaker_New("UIPadding", list, {})
		padding.PaddingTop = UDim.new(0, 6)
		padding.PaddingBottom = UDim.new(0, 6)
		padding.PaddingLeft = UDim.new(0, 6)
		padding.PaddingRight = UDim.new(0, 6)

		for _, kind in NAmanage.PluginMaker_ActionTypes do
			local button = NAmanage.PluginMaker_Button(list, NAmanage.PluginMaker_ActionName(kind), function()
				pm.actionType = kind
				pm.ActionPickerOverlay.Visible = false
				if pm.ActionTypeButton and pm.ActionTypeButton.Parent then
					pm.ActionTypeButton.Text = NAmanage.PluginMaker_ActionName(kind).."  v"
				end
				if pm.ActionValueBox and pm.ActionValueBox.Parent then
					pm.ActionValueBox.PlaceholderText = NAmanage.PluginMaker_ActionValueHint(kind)
				end
				if pm.ActionExtraBox and pm.ActionExtraBox.Parent then
					pm.ActionExtraBox.PlaceholderText = NAmanage.PluginMaker_ActionExtraHint(kind)
				end
			end)
			button.Size = UDim2.new(1, -2, 0, 34)
			button.TextXAlignment = Enum.TextXAlignment.Left
			button.ZIndex = 133
		end

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if list and list.Parent then
				list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
			end
		end)
		list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
		return true
	end

	NAmanage.PluginMaker_OpenActionMenu = function()
		local pm = NAStuff.PluginMaker
		if not NAmanage.PluginMaker_EnsureActionPicker() then
			return
		end
		pm.ActionPickerOverlay.Visible = true
	end

	NAmanage.PluginMaker_EnsureCodeEditor = function()
		local pm = NAStuff.PluginMaker
		if pm.CodeOverlay and pm.CodeOverlay.Parent == pm.Frame then
			return true
		end
		if not pm.Frame or not pm.Frame.Parent then
			return false
		end

		pm.CodeOverlay = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			Name = "CodeEditorOverlay";
			BackgroundColor3 = Color3.fromRGB(4, 4, 7);
			BackgroundTransparency = 0.25;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = false;
			Active = true;
			ZIndex = 140;
		})

		local card = NAmanage.PluginMaker_New("Frame", pm.CodeOverlay, {
			Name = "CodeEditorCard";
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(1, -30, 1, -30);
			BackgroundColor3 = Color3.fromRGB(18, 19, 25);
			BorderSizePixel = 0;
			ZIndex = 141;
		})
		NAmanage.PluginMaker_Corner(card, 9)
		NAmanage.PluginMaker_Stroke(card, 0.4)

		pm.CodeTitle = NAmanage.PluginMaker_Label(card, "Code Editor", 14)
		pm.CodeTitle.Position = UDim2.new(0, 10, 0, 7)
		pm.CodeTitle.Size = UDim2.new(1, -20, 0, 22)
		pm.CodeTitle.Font = Enum.Font.GothamBold
		pm.CodeTitle.TextColor3 = Color3.fromRGB(245, 246, 250)
		pm.CodeTitle.ZIndex = 142

		pm.CodeHint = NAmanage.PluginMaker_Label(card, "", 10)
		pm.CodeHint.Position = UDim2.new(0, 10, 0, 31)
		pm.CodeHint.Size = UDim2.new(1, -20, 0, 34)
		pm.CodeHint.TextColor3 = Color3.fromRGB(155, 158, 176)
		pm.CodeHint.TextYAlignment = Enum.TextYAlignment.Top
		pm.CodeHint.ZIndex = 142

		pm.CodeBox = NAmanage.PluginMaker_New("TextBox", card, {
			Name = "Code";
			BackgroundColor3 = Color3.fromRGB(11, 12, 16);
			BackgroundTransparency = 0.02;
			BorderSizePixel = 0;
			ClearTextOnFocus = false;
			Font = Enum.Font.Code;
			MultiLine = true;
			Position = UDim2.new(0, 10, 0, 70);
			Size = UDim2.new(1, -20, 1, -146);
			Text = "";
			TextColor3 = Color3.fromRGB(225, 227, 235);
			TextSize = 12;
			TextWrapped = false;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Top;
			ZIndex = 142;
		})
		NAmanage.PluginMaker_Corner(pm.CodeBox, 6)
		NAmanage.PluginMaker_Stroke(pm.CodeBox, 0.75)
		local codePadding = NAmanage.PluginMaker_New("UIPadding", pm.CodeBox, {})
		codePadding.PaddingTop = UDim.new(0, 7)
		codePadding.PaddingBottom = UDim.new(0, 7)
		codePadding.PaddingLeft = UDim.new(0, 7)
		codePadding.PaddingRight = UDim.new(0, 7)

		local buttons = NAmanage.PluginMaker_New("Frame", card, {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 10, 1, -68);
			Size = UDim2.new(1, -20, 0, 58);
			ZIndex = 142;
		})
		local grid = NAmanage.PluginMaker_New("UIGridLayout", buttons, {
			CellPadding = UDim2.new(0, 5, 0, 4);
			CellSize = UDim2.new(0.333333, -4, 0, 27);
			FillDirectionMaxCells = 3;
			SortOrder = Enum.SortOrder.LayoutOrder;
		})

		NAmanage.PluginMaker_Button(buttons, "Load URL Example", function()
			local snippet = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/user/repo/refs/heads/main/script.lua"))()'
			if pm.CodeBox.Text ~= "" and not pm.CodeBox.Text:match("\n$") then
				pm.CodeBox.Text ..= "\n"
			end
			pm.CodeBox.Text ..= snippet
		end)

		NAmanage.PluginMaker_Button(buttons, "Service Example", function()
			local selected = NAmanage.PluginMaker_GetSelectedServices()
			local name = selected[1] or "CollectionService"
			local varName = NAmanage.PluginMaker_ServiceVar(name) or "Service"
			local snippet = 'local '..varName..' = Services['..NAmanage.PluginMaker_Quote(name)..']'
			if pm.CodeBox.Text ~= "" and not pm.CodeBox.Text:match("\n$") then
				pm.CodeBox.Text ..= "\n"
			end
			pm.CodeBox.Text ..= snippet
		end)

		NAmanage.PluginMaker_Button(buttons, "Copy", function()
			if type(setclipboard) == "function" then
				pcall(setclipboard, pm.CodeBox.Text)
			end
		end)

		local save = NAmanage.PluginMaker_Button(buttons, "Save Code", function()
			local value = tostring(pm.CodeBox.Text or "")
			if pm.codeEditTarget == "file" then
				if type(pm.codeEditPath) ~= "string" or type(writefile) ~= "function" then
					NAmanage.PluginMaker_SetStatus("Existing plugin path or writefile is unavailable", "error")
					return
				end
				local okCompile, compileErr = NAmanage.PluginMaker_CompileCheck(value)
				if not okCompile then
					NAmanage.PluginMaker_SetStatus("Compile error: "..tostring(compileErr), "error")
					return
				end
				local okWrite, writeErr = pcall(writefile, pm.codeEditPath, value)
				if not okWrite then
					NAmanage.PluginMaker_SetStatus("Failed to update plugin: "..tostring(writeErr), "error")
					return
				end
				NAmanage.PluginMaker_ReloadPlugins()
				pm.CodeOverlay.Visible = false
				NAmanage.PluginMaker_SetStatus("Updated "..tostring(pm.codeEditPath), "success")
				DoNotif("Plugin updated and reloaded", 3)
				return
			end
			if pm.codeEditTarget == "startup" then
				pm.startupCode = value
			elseif pm.codeEditTarget == "command" then
				local command = pm.commands and pm.commands[pm.codeEditCommandIndex or pm.selectedCommand]
				if command then
					command.customCode = value
				end
			end
			pm.dirty = true
			pm.CodeOverlay.Visible = false
			NAmanage.PluginMaker_RebuildEditor()
			NAmanage.PluginMaker_SetStatus("Custom code updated", "success")
		end)
		save.BackgroundColor3 = Color3.fromRGB(75, 58, 105)

		NAmanage.PluginMaker_Button(buttons, "Cancel", function()
			pm.CodeOverlay.Visible = false
		end)
		return true
	end

	NAmanage.PluginMaker_OpenCodeEditor = function(target)
		local pm = NAStuff.PluginMaker
		if not NAmanage.PluginMaker_EnsureCodeEditor() then
			return
		end
		pm.codeEditTarget = target
		if target == "startup" then
			pm.codeEditCommandIndex = nil
			pm.CodeTitle.Text = "Plugin Startup Code"
			pm.CodeHint.Text = "Runs when the plugin loads. Available: ServiceResolver, Services, and "..tostring(#NAmanage.PluginMaker_GetSelectedServices()).." selected service local(s)."
			pm.CodeBox.Text = tostring(pm.startupCode or "")
		else
			local command, index = NAmanage.PluginMaker_GetSelectedCommand()
			pm.codeEditCommandIndex = index
			pm.CodeTitle.Text = "Command Code - "..tostring(command and command.name or "Command")
			pm.CodeHint.Text = "Runs inside this command after its visual actions. Available: args, player, ctx, ctx.ServiceResolver, Services, and "..tostring(#NAmanage.PluginMaker_GetSelectedServices()).." selected service local(s)."
			pm.CodeBox.Text = tostring(command and command.customCode or "")
		end
		pm.CodeOverlay.Visible = true
	end

	NAmanage.PluginMaker_RebuildEditor = function()
		local pm = NAStuff.PluginMaker
		local scroll = pm.Editor
		if not scroll or not scroll.Parent then return end
		NAmanage.PluginMaker_ClearGui(scroll)
		local command = NAmanage.PluginMaker_GetSelectedCommand()
		if not command then return end
		local layout = NAmanage.PluginMaker_New("UIListLayout", scroll, {
			Padding = UDim.new(0, 7);
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local padding = NAmanage.PluginMaker_New("UIPadding", scroll, {})
		padding.PaddingTop = UDim.new(0, 8)
		padding.PaddingBottom = UDim.new(0, 10)
		padding.PaddingLeft = UDim.new(0, 8)
		padding.PaddingRight = UDim.new(0, 8)

		local function row(height)
			return NAmanage.PluginMaker_New("Frame", scroll, {
				BackgroundTransparency = 1;
				BorderSizePixel = 0;
				Size = UDim2.new(1, -2, 0, height or 34);
			})
		end

		local function inputRow(labelText, value, placeholder, callback)
			local holder = row(38)
			local label = NAmanage.PluginMaker_Label(holder, labelText, 11)
			label.Position = UDim2.new(0, 0, 0, 0)
			label.Size = UDim2.new(0.31, -6, 1, 0)
			local box = NAmanage.PluginMaker_Input(holder, placeholder, value, callback)
			box.Position = UDim2.new(0.31, 0, 0, 2)
			box.Size = UDim2.new(0.69, 0, 1, -4)
			return box
		end

		inputRow("Command", command.name, "Command name", function(value)
			command.name = NAmanage.PluginMaker_Trim(value)
			pm.dirty = true
			NAmanage.PluginMaker_RebuildCommandList()
		end)
		inputRow("Aliases", command.aliases, "alias1, alias2", function(value)
			command.aliases = value
			pm.dirty = true
		end)
		inputRow("Arguments", command.argsHint, "[player] [text]", function(value)
			command.argsHint = value
			pm.dirty = true
		end)
		inputRow("Description", command.description, "What this command does", function(value)
			command.description = value
			pm.dirty = true
		end)

		local toggleRow = row(34)
		local toggleLayout = NAmanage.PluginMaker_New("UIGridLayout", toggleRow, {
			CellPadding = UDim2.new(0, 5, 0, 0);
			CellSize = UDim2.new(0.33, -4, 1, 0);
			FillDirectionMaxCells = 3;
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local function toggleButton(text, key)
			local button
			local function paint()
				button.Text = text..": "..(command[key] == true and "ON" or "OFF")
				button.BackgroundColor3 = command[key] == true and Color3.fromRGB(75, 58, 105) or Color3.fromRGB(42, 43, 54)
			end
			button = NAmanage.PluginMaker_Button(toggleRow, "", function()
				command[key] = not (command[key] == true)
				pm.dirty = true
				paint()
				if key == "userButton" then
					NAmanage.PluginMaker_RebuildEditor()
				end
			end)
			paint()
			return button
		end
		toggleButton("Requires Args", "requiresArgs")
		toggleButton("Override Alias", "overrideAliases")
		toggleButton("User Button", "userButton")

		if command.userButton == true then
			inputRow("Button Label", command.userButtonLabel, command.name ~= "" and command.name or "Button", function(value)
				command.userButtonLabel = value
				pm.dirty = true
			end)
			local saveArgsRow = row(32)
			local saveArgs = NAmanage.PluginMaker_Button(saveArgsRow, "", function()
				command.saveButtonArgs = not (command.saveButtonArgs ~= false)
				pm.dirty = true
				NAmanage.PluginMaker_RebuildEditor()
			end)
			saveArgs.Size = UDim2.new(1, 0, 1, 0)
			saveArgs.Text = "User Button Saves Typed Args: "..(command.saveButtonArgs ~= false and "ON" or "OFF")
			if command.saveButtonArgs ~= false then saveArgs.BackgroundColor3 = Color3.fromRGB(75, 58, 105) end
		end

		local hint = row(48)
		local hintLabel = NAmanage.PluginMaker_Label(hint, "Placeholders: {1}, {2}, {args}, {user}, {display}, {placeid}, {jobid}", 11)
		hintLabel.Size = UDim2.new(1, 0, 1, 0)
		hintLabel.TextColor3 = Color3.fromRGB(165, 168, 185)

		local codeRow = row(34)
		local codeGrid = NAmanage.PluginMaker_New("UIGridLayout", codeRow, {
			CellPadding = UDim2.new(0, 6, 0, 0);
			CellSize = UDim2.new(0.5, -3, 1, 0);
			FillDirectionMaxCells = 2;
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local startupCodeButton = NAmanage.PluginMaker_Button(codeRow, "Plugin Startup Code"..(NAmanage.PluginMaker_Trim(pm.startupCode) ~= "" and "  *" or ""), function()
			NAmanage.PluginMaker_OpenCodeEditor("startup")
		end)
		local commandCodeButton = NAmanage.PluginMaker_Button(codeRow, "Command Code"..(NAmanage.PluginMaker_Trim(command.customCode) ~= "" and "  *" or ""), function()
			NAmanage.PluginMaker_OpenCodeEditor("command")
		end)
		if NAmanage.PluginMaker_Trim(pm.startupCode) ~= "" then
			startupCodeButton.BackgroundColor3 = Color3.fromRGB(57, 74, 102)
		end
		if NAmanage.PluginMaker_Trim(command.customCode) ~= "" then
			commandCodeButton.BackgroundColor3 = Color3.fromRGB(75, 58, 105)
		end

		local actionHeader = row(24)
		local actionTitle = NAmanage.PluginMaker_Label(actionHeader, "Actions", 13)
		actionTitle.Size = UDim2.new(1, 0, 1, 0)
		actionTitle.Font = Enum.Font.GothamBold

		for index, action in command.actions or {} do
			local actionRow = row(58)
			actionRow.BackgroundColor3 = Color3.fromRGB(34, 35, 44)
			actionRow.BackgroundTransparency = 0.12
			NAmanage.PluginMaker_Corner(actionRow, 6)
			NAmanage.PluginMaker_Stroke(actionRow, 0.82)
			local title = NAmanage.PluginMaker_Label(actionRow, tostring(index)..". "..NAmanage.PluginMaker_ActionName(action.type), 11)
			title.Position = UDim2.new(0, 8, 0, 4)
			title.Size = UDim2.new(1, -104, 0, 18)
			title.Font = Enum.Font.GothamBold
			local summary = NAmanage.PluginMaker_Label(actionRow, tostring(action.value or "")..((action.extra and action.extra ~= "") and ("  |  "..tostring(action.extra)) or ""), 10)
			summary.Position = UDim2.new(0, 8, 0, 24)
			summary.Size = UDim2.new(1, -104, 0, 26)
			summary.TextColor3 = Color3.fromRGB(170, 173, 190)
			summary.TextTruncate = Enum.TextTruncate.AtEnd
			local up = NAmanage.PluginMaker_Button(actionRow, "^", function()
				if index > 1 then
					command.actions[index], command.actions[index - 1] = command.actions[index - 1], command.actions[index]
					pm.dirty = true
					NAmanage.PluginMaker_RebuildEditor()
				end
			end)
			up.Position = UDim2.new(1, -92, 0, 14)
			up.Size = UDim2.new(0, 26, 0, 28)
			local down = NAmanage.PluginMaker_Button(actionRow, "v", function()
				if index < #command.actions then
					command.actions[index], command.actions[index + 1] = command.actions[index + 1], command.actions[index]
					pm.dirty = true
					NAmanage.PluginMaker_RebuildEditor()
				end
			end)
			down.Position = UDim2.new(1, -62, 0, 14)
			down.Size = UDim2.new(0, 26, 0, 28)
			local remove = NAmanage.PluginMaker_Button(actionRow, "x", function()
				table.remove(command.actions, index)
				pm.dirty = true
				NAmanage.PluginMaker_RebuildEditor()
			end)
			remove.Position = UDim2.new(1, -32, 0, 14)
			remove.Size = UDim2.new(0, 26, 0, 28)
			remove.TextColor3 = Color3.fromRGB(255, 160, 168)
		end

		local addAction = row(112)
		addAction.BackgroundColor3 = Color3.fromRGB(31, 32, 40)
		addAction.BackgroundTransparency = 0.08
		NAmanage.PluginMaker_Corner(addAction, 7)
		NAmanage.PluginMaker_Stroke(addAction, 0.78)

		pm.ActionTypeButton = NAmanage.PluginMaker_Button(addAction, NAmanage.PluginMaker_ActionName(pm.actionType).."  v", function()
			NAmanage.PluginMaker_OpenActionMenu()
		end)
		pm.ActionTypeButton.Position = UDim2.new(0, 6, 0, 6)
		pm.ActionTypeButton.Size = UDim2.new(0.38, -9, 0, 30)

		pm.ActionValueBox = NAmanage.PluginMaker_Input(addAction, NAmanage.PluginMaker_ActionValueHint(pm.actionType), pm.actionValue or "", function(value)
			pm.actionValue = value
		end)
		pm.ActionValueBox.Position = UDim2.new(0.38, 3, 0, 6)
		pm.ActionValueBox.Size = UDim2.new(0.62, -9, 0, 30)

		pm.ActionExtraBox = NAmanage.PluginMaker_Input(addAction, NAmanage.PluginMaker_ActionExtraHint(pm.actionType), pm.actionExtra or "", function(value)
			pm.actionExtra = value
		end)
		pm.ActionExtraBox.Position = UDim2.new(0, 6, 0, 42)
		pm.ActionExtraBox.Size = UDim2.new(0.62, -9, 0, 30)

		local addButton = NAmanage.PluginMaker_Button(addAction, "Add Action", function()
			if pm.ActionValueBox then pm.actionValue = pm.ActionValueBox.Text end
			if pm.ActionExtraBox then pm.actionExtra = pm.ActionExtraBox.Text end
			command.actions = command.actions or {}
			command.actions[#command.actions + 1] = {
				type = pm.actionType or "notify";
				value = pm.actionValue or "";
				extra = pm.actionExtra or "";
			}
			pm.actionValue = ""
			if pm.actionType ~= "notify" and pm.actionType ~= "mobile_notify" and pm.actionType ~= "pc_notify" then
				pm.actionExtra = ""
			end
			pm.dirty = true
			NAmanage.PluginMaker_RebuildEditor()
		end)
		addButton.Position = UDim2.new(0.62, 3, 0, 42)
		addButton.Size = UDim2.new(0.38, -9, 0, 30)
		addButton.BackgroundColor3 = Color3.fromRGB(75, 58, 105)

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if scroll and scroll.Parent then
				scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 18)
			end
		end)
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 18)
	end

	NAmanage.PluginMaker_OpenPreview = function()
		local pm = NAStuff.PluginMaker
		local source, err = NAmanage.PluginMaker_Generate()
		if not source then
			NAmanage.PluginMaker_SetStatus(err, "error")
			return
		end
		local okCompile, compileErr = NAmanage.PluginMaker_CompileCheck(source)
		if not okCompile then
			NAmanage.PluginMaker_SetStatus("Compile error: "..tostring(compileErr), "error")
			return
		end
		if not pm.PreviewOverlay or not pm.PreviewOverlay.Parent then return end
		pm.PreviewBox.Text = source
		pm.PreviewOverlay.Visible = true
		NAmanage.PluginMaker_SetStatus("Generated "..tostring(pm.format == "iy" and ".iy" or ".na").." source successfully", "success")
	end

	NAmanage.PluginMaker_ApplyLayout = function()
		local pm = NAStuff.PluginMaker
		local frame = pm.Frame
		if not frame or not frame.Parent then return end
		local size = frame.AbsoluteSize
		local width = math.max(1, tonumber(size.X) or 1)
		local compactTop = width < 520
		if pm.FormatButton then
			pm.FormatButton.Size = UDim2.new(0, compactTop and 42 or 54, 0, 28)
			pm.FormatButton.Position = UDim2.new(1, compactTop and -154 or -200, 0.5, 0)
		end
		if pm.EditExistingButton then
			pm.EditExistingButton.Text = compactTop and "E" or "Edit"
			pm.EditExistingButton.Size = UDim2.new(0, compactTop and 30 or 48, 0, 28)
			pm.EditExistingButton.Position = UDim2.new(1, compactTop and -106 or -146, 0.5, 0)
		end
		if pm.ManageButton then
			pm.ManageButton.Text = compactTop and "P" or "Plugins"
			pm.ManageButton.Size = UDim2.new(0, compactTop and 30 or 58, 0, 28)
			pm.ManageButton.Position = UDim2.new(1, compactTop and -70 or -82, 0.5, 0)
		end
		if pm.Topbar then
			local title = pm.Topbar:FindFirstChildWhichIsA("TextLabel")
			if title then
				title.Size = UDim2.new(1, compactTop and -170 or -250, 0, 20)
			end
		end
		if pm.CommandPanel then
			local leftWidth
			if width < 500 then
				leftWidth = math.clamp(math.floor(width * 0.28), 104, 132)
			else
				leftWidth = math.clamp(math.floor(width * 0.25), 132, 210)
			end
			pm.CommandPanel.Size = UDim2.new(0, leftWidth, 1, 0)
			if pm.EditorPanel then
				pm.EditorPanel.Position = UDim2.new(0, leftWidth + 8, 0, 0)
				pm.EditorPanel.Size = UDim2.new(1, -(leftWidth + 8), 1, 0)
			end
		end
	end

	NAmanage.PluginMaker_Resize = function(initial)
		local pm = NAStuff.PluginMaker
		local frame = pm.Frame
		if not frame or not frame.Parent then return end
		if initial == true then
			local camera = Services.Workspace and Services.Workspace.CurrentCamera
			local vp = camera and camera.ViewportSize or Vector2.new(900, 600)
			local width = math.max(300, math.min(900, vp.X - 18))
			local height = math.max(280, math.min(620, vp.Y - 28))
			if NAmanage.ExecutorWindowSizing and type(NAmanage.ExecutorWindowSizing.GetSize) == "function" then
				local okMetrics, metrics = pcall(NAmanage.ExecutorWindowSizing.GetSize, 900, 620, {
					minWidth = 520;
					minHeight = 360;
					mobileMinWidth = 300;
					mobileMinHeight = 260;
				})
				if okMetrics and type(metrics) == "table" then
					width = math.min(tonumber(metrics.width) or width, math.max(300, vp.X - 18))
					height = math.min(tonumber(metrics.height) or height, math.max(280, vp.Y - 28))
				end
			end
			frame.Size = UDim2.fromOffset(width, height)
		end
		NAmanage.PluginMaker_ApplyLayout()
		if initial == true and type(NAmanage.centerFrame) == "function" then
			pcall(NAmanage.centerFrame, frame)
		end
	end

	NAmanage.PluginMaker_BindResize = function()
		local pm = NAStuff.PluginMaker
		local frame = pm.Frame
		if not frame or not frame.Parent then
			return
		end
		if pm.ResizeCleanup then
			pcall(pm.ResizeCleanup)
			pm.ResizeCleanup = nil
		end
		if NAgui and type(NAgui.resizeable) == "function" then
			local minSize = IsOnMobile and Vector2.new(300, 260) or Vector2.new(520, 360)
			pm.ResizeCleanup = NAgui.resizeable(frame, minSize, Vector2.new(5000, 5000))
		end
		if pm.LayoutConnection then
			pcall(function() pm.LayoutConnection:Disconnect() end)
			pm.LayoutConnection = nil
		end
		pm.LayoutConnection = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			NAmanage.PluginMaker_ApplyLayout()
		end)
	end

	NAmanage.PluginMaker_BindDrag = function()
		local pm = NAStuff.PluginMaker
		local frame = pm.Frame
		local topbar = pm.Topbar
		if not frame or not topbar or not Services.UserInputService then return end
		pm.dragging = false
		topbar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				pm.dragging = true
				pm.dragStart = input.Position
				pm.dragPos = frame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						pm.dragging = false
					end
				end)
			end
		end)
		Services.UserInputService.InputChanged:Connect(function(input)
			if not pm.dragging or not pm.dragStart or not pm.dragPos then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
			local delta = input.Position - pm.dragStart
			frame.Position = UDim2.new(pm.dragPos.X.Scale, pm.dragPos.X.Offset + delta.X, pm.dragPos.Y.Scale, pm.dragPos.Y.Offset + delta.Y)
		end)
	end

	NAmanage.PluginMaker_BuildUI = function()
		local pm = NAStuff.PluginMaker
		local root = NAmanage.getUI and NAmanage.getUI() or (NAStuff and NAStuff.NASCREENGUI)
		if not root then
			return false, "NA UI root unavailable"
		end
		if pm.Frame and pm.Frame.Parent then
			pm.Frame:Destroy()
		end

		pm.Frame = NAmanage.PluginMaker_New("Frame", root, {
			Name = "PluginMaker";
			AnchorPoint = Vector2.new(0, 0);
			Position = UDim2.fromOffset(0, 0);
			BackgroundColor3 = Color3.fromRGB(15, 16, 21);
			BackgroundTransparency = 0.04;
			BorderSizePixel = 0;
			ClipsDescendants = true;
			Visible = true;
			ZIndex = 70;
		})
		NAmanage.PluginMaker_Corner(pm.Frame, 10)
		NAmanage.PluginMaker_Stroke(pm.Frame, 0.38)

		pm.Topbar = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			BackgroundColor3 = Color3.fromRGB(21, 22, 29);
			BackgroundTransparency = 0.06;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(1, 0, 0, 44);
			ZIndex = 72;
		})
		local title = NAmanage.PluginMaker_Label(pm.Topbar, "Plugin Maker", 16)
		title.Position = UDim2.new(0, 12, 0, 4)
		title.Size = UDim2.new(1, -250, 0, 20)
		title.Font = Enum.Font.GothamBold
		title.TextColor3 = Color3.fromRGB(245, 246, 250)
		title.ZIndex = 73
		local subtitle = NAmanage.PluginMaker_Label(pm.Topbar, "Build .na / .iy plugins without writing code", 10)
		subtitle.Position = UDim2.new(0, 12, 0, 23)
		subtitle.Size = UDim2.new(1, -250, 0, 15)
		subtitle.TextColor3 = Color3.fromRGB(160, 163, 180)
		subtitle.ZIndex = 73

		local close = NAmanage.PluginMaker_Button(pm.Topbar, "X", function()
			pm.Frame.Visible = false
		end)
		close.AnchorPoint = Vector2.new(1, 0.5)
		close.Position = UDim2.new(1, -10, 0.5, 0)
		close.Size = UDim2.new(0, 30, 0, 28)
		close.TextColor3 = Color3.fromRGB(255, 170, 176)
		close.ZIndex = 74

		pm.MinimizeButton = NAmanage.PluginMaker_Button(pm.Topbar, "-", function()
			NAmanage.PluginMaker_ToggleMinimize()
		end)
		pm.MinimizeButton.AnchorPoint = Vector2.new(1, 0.5)
		pm.MinimizeButton.Position = UDim2.new(1, -46, 0.5, 0)
		pm.MinimizeButton.Size = UDim2.new(0, 30, 0, 28)
		pm.MinimizeButton.ZIndex = 74

		pm.ManageButton = NAmanage.PluginMaker_Button(pm.Topbar, "Plugins", function()
			NAmanage.PluginMaker_OpenInstalledManager()
		end)
		pm.ManageButton.AnchorPoint = Vector2.new(1, 0.5)
		pm.ManageButton.Position = UDim2.new(1, -82, 0.5, 0)
		pm.ManageButton.Size = UDim2.new(0, 58, 0, 28)
		pm.ManageButton.ZIndex = 74

		pm.EditExistingButton = NAmanage.PluginMaker_Button(pm.Topbar, "Edit", function()
			NAmanage.PluginMaker_OpenFilePicker()
		end)
		pm.EditExistingButton.AnchorPoint = Vector2.new(1, 0.5)
		pm.EditExistingButton.Position = UDim2.new(1, -146, 0.5, 0)
		pm.EditExistingButton.Size = UDim2.new(0, 48, 0, 28)
		pm.EditExistingButton.BackgroundColor3 = Color3.fromRGB(57, 74, 102)
		pm.EditExistingButton.ZIndex = 74

		pm.FormatButton = NAmanage.PluginMaker_Button(pm.Topbar, ".NA", function()
			pm.format = pm.format == "na" and "iy" or "na"
			pm.FormatButton.Text = pm.format == "iy" and ".IY" or ".NA"
			pm.FormatButton.BackgroundColor3 = pm.format == "iy" and Color3.fromRGB(57, 74, 102) or Color3.fromRGB(75, 58, 105)
			pm.dirty = true
			NAmanage.PluginMaker_RebuildEditor()
			NAmanage.PluginMaker_SetStatus("Output format: "..(pm.format == "iy" and "Infinite Yield .iy" or "Native NA .na"), "warn")
		end)
		pm.FormatButton.AnchorPoint = Vector2.new(1, 0.5)
		pm.FormatButton.Position = UDim2.new(1, -200, 0.5, 0)
		pm.FormatButton.Size = UDim2.new(0, 54, 0, 28)
		pm.FormatButton.BackgroundColor3 = Color3.fromRGB(75, 58, 105)
		pm.FormatButton.ZIndex = 74

		pm.Meta = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 10, 0, 52);
			Size = UDim2.new(1, -20, 0, 82);
			ZIndex = 71;
		})

		local pluginNameLabel = NAmanage.PluginMaker_Label(pm.Meta, "Plugin Name", 10)
		pluginNameLabel.Position = UDim2.new(0, 0, 0, 0)
		pluginNameLabel.Size = UDim2.new(0.5, -5, 0, 16)
		local fileNameLabel = NAmanage.PluginMaker_Label(pm.Meta, "File Name", 10)
		fileNameLabel.Position = UDim2.new(0.5, 5, 0, 0)
		fileNameLabel.Size = UDim2.new(0.5, -5, 0, 16)
		pm.PluginNameBox = NAmanage.PluginMaker_Input(pm.Meta, "My Plugin", pm.pluginName, function(value)
			pm.pluginName = NAmanage.PluginMaker_Trim(value)
			if pm.fileName == "" or pm.fileName == "MyPlugin" then
				pm.fileName = NAmanage.PluginMaker_SafeFileName(pm.pluginName)
				if pm.FileNameBox then pm.FileNameBox.Text = pm.fileName end
			end
			pm.dirty = true
		end)
		pm.PluginNameBox.Position = UDim2.new(0, 0, 0, 18)
		pm.PluginNameBox.Size = UDim2.new(0.5, -5, 0, 28)
		pm.FileNameBox = NAmanage.PluginMaker_Input(pm.Meta, "MyPlugin", pm.fileName, function(value)
			pm.fileName = NAmanage.PluginMaker_SafeFileName(value)
			pm.dirty = true
		end)
		pm.FileNameBox.Position = UDim2.new(0.5, 5, 0, 18)
		pm.FileNameBox.Size = UDim2.new(0.5, -5, 0, 28)
		pm.DescriptionBox = NAmanage.PluginMaker_Input(pm.Meta, "Plugin description", pm.description, function(value)
			pm.description = value
			pm.dirty = true
		end)
		pm.DescriptionBox.Position = UDim2.new(0, 0, 0, 52)
		pm.DescriptionBox.Size = UDim2.new(0.68, -5, 0, 28)
		pm.ServicesButton = NAmanage.PluginMaker_Button(pm.Meta, "Services (0)", function()
			NAmanage.PluginMaker_OpenServicePicker()
		end)
		pm.ServicesButton.Position = UDim2.new(0.68, 5, 0, 52)
		pm.ServicesButton.Size = UDim2.new(0.32, -5, 0, 28)
		pm.ServicesButton.BackgroundColor3 = Color3.fromRGB(42, 43, 54)

		pm.Workspace = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 10, 0, 142);
			Size = UDim2.new(1, -20, 1, -202);
			ZIndex = 71;
		})

		pm.CommandPanel = NAmanage.PluginMaker_New("Frame", pm.Workspace, {
			BackgroundColor3 = Color3.fromRGB(24, 25, 32);
			BackgroundTransparency = 0.08;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 0, 0, 0);
			Size = UDim2.new(0, 190, 1, 0);
			ZIndex = 72;
		})
		NAmanage.PluginMaker_Corner(pm.CommandPanel, 7)
		NAmanage.PluginMaker_Stroke(pm.CommandPanel, 0.76)
		local commandsTitle = NAmanage.PluginMaker_Label(pm.CommandPanel, "Commands", 12)
		commandsTitle.Position = UDim2.new(0, 8, 0, 4)
		commandsTitle.Size = UDim2.new(1, -16, 0, 22)
		commandsTitle.Font = Enum.Font.GothamBold
		pm.CommandList = NAmanage.PluginMaker_New("ScrollingFrame", pm.CommandPanel, {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 4, 0, 30);
			Size = UDim2.new(1, -8, 1, -72);
			CanvasSize = UDim2.new();
			ScrollBarThickness = 3;
			ZIndex = 73;
		})
		local commandButtons = NAmanage.PluginMaker_New("Frame", pm.CommandPanel, {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 6, 1, -38);
			Size = UDim2.new(1, -12, 0, 32);
			ZIndex = 74;
		})
		local commandGrid = NAmanage.PluginMaker_New("UIGridLayout", commandButtons, {
			CellPadding = UDim2.new(0, 4, 0, 0);
			CellSize = UDim2.new(0.333, -3, 1, 0);
			FillDirectionMaxCells = 3;
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		local addCommand = NAmanage.PluginMaker_Button(commandButtons, "+", function()
			pm.commands[#pm.commands + 1] = NAmanage.PluginMaker_DefaultCommand(#pm.commands + 1)
			pm.selectedCommand = #pm.commands
			pm.dirty = true
			NAmanage.PluginMaker_RebuildCommandList()
			NAmanage.PluginMaker_RebuildEditor()
		end)
		local duplicateCommand = NAmanage.PluginMaker_Button(commandButtons, "Copy", function()
			local command = NAmanage.PluginMaker_GetSelectedCommand()
			if not command then return end
			local copy = {}
			for key, value in command do
				if key == "actions" then
					copy.actions = {}
					for _, action in value or {} do
						copy.actions[#copy.actions + 1] = { type = action.type; value = action.value; extra = action.extra }
					end
				else
					copy[key] = value
				end
			end
			copy.name = tostring(copy.name or "command").."_copy"
			pm.commands[#pm.commands + 1] = copy
			pm.selectedCommand = #pm.commands
			pm.dirty = true
			NAmanage.PluginMaker_RebuildCommandList()
			NAmanage.PluginMaker_RebuildEditor()
		end)
		local deleteCommand = NAmanage.PluginMaker_Button(commandButtons, "Del", function()
			if #pm.commands <= 1 then
				NAmanage.PluginMaker_SetStatus("A plugin needs at least one command", "warn")
				return
			end
			table.remove(pm.commands, pm.selectedCommand)
			pm.selectedCommand = math.clamp(pm.selectedCommand, 1, #pm.commands)
			pm.dirty = true
			NAmanage.PluginMaker_RebuildCommandList()
			NAmanage.PluginMaker_RebuildEditor()
		end)
		deleteCommand.TextColor3 = Color3.fromRGB(255, 160, 168)

		pm.EditorPanel = NAmanage.PluginMaker_New("Frame", pm.Workspace, {
			BackgroundColor3 = Color3.fromRGB(24, 25, 32);
			BackgroundTransparency = 0.08;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 198, 0, 0);
			Size = UDim2.new(1, -198, 1, 0);
			ZIndex = 72;
		})
		NAmanage.PluginMaker_Corner(pm.EditorPanel, 7)
		NAmanage.PluginMaker_Stroke(pm.EditorPanel, 0.76)
		pm.Editor = NAmanage.PluginMaker_New("ScrollingFrame", pm.EditorPanel, {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 4, 0, 4);
			Size = UDim2.new(1, -8, 1, -8);
			CanvasSize = UDim2.new();
			ScrollBarThickness = 4;
			ZIndex = 73;
		})

		pm.Footer = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 10, 1, -52);
			Size = UDim2.new(1, -20, 0, 42);
			ZIndex = 72;
		})
		pm.Status = NAmanage.PluginMaker_Label(pm.Footer, "Ready", 10)
		pm.Status.Position = UDim2.new(0, 0, 0, 0)
		pm.Status.Size = UDim2.new(1, 0, 0, 12)
		local footerButtons = NAmanage.PluginMaker_New("Frame", pm.Footer, {
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 0, 0, 14);
			Size = UDim2.new(1, 0, 0, 28);
			ZIndex = 73;
		})
		local footerGrid = NAmanage.PluginMaker_New("UIGridLayout", footerButtons, {
			CellPadding = UDim2.new(0, 5, 0, 0);
			CellSize = UDim2.new(0.2, -4, 1, 0);
			FillDirectionMaxCells = 5;
			SortOrder = Enum.SortOrder.LayoutOrder;
		})
		NAmanage.PluginMaker_Button(footerButtons, "Preview", function()
			NAmanage.PluginMaker_OpenPreview()
		end)
		NAmanage.PluginMaker_Button(footerButtons, "Copy Source", function()
			local source, err = NAmanage.PluginMaker_Generate()
			if not source then
				NAmanage.PluginMaker_SetStatus(err, "error")
				return
			end
			local okCompile, compileErr = NAmanage.PluginMaker_CompileCheck(source)
			if not okCompile then
				NAmanage.PluginMaker_SetStatus("Compile error: "..tostring(compileErr), "error")
				return
			end
			if type(setclipboard) ~= "function" then
				NAmanage.PluginMaker_SetStatus("Clipboard unavailable", "error")
				return
			end
			local ok = pcall(setclipboard, source)
			NAmanage.PluginMaker_SetStatus(ok and "Plugin source copied" or "Copy failed", ok and "success" or "error")
		end)
		NAmanage.PluginMaker_Button(footerButtons, "Save File", function()
			local ok, path = NAmanage.PluginMaker_Save(false)
			if ok == true then
				NAmanage.PluginMaker_SetStatus("Saved "..tostring(path), "success")
				DoNotif("Plugin Maker saved "..tostring(path), 3)
			elseif ok == false then
				NAmanage.PluginMaker_SetStatus(tostring(path), "error")
			end
		end)
		local installButton = NAmanage.PluginMaker_Button(footerButtons, "Save + Install", function()
			local ok, path = NAmanage.PluginMaker_Save(true)
			if ok == true then
				NAmanage.PluginMaker_SetStatus("Installed "..tostring(path), "success")
				DoNotif("Plugin Maker installed "..tostring(path), 3)
			elseif ok == false then
				NAmanage.PluginMaker_SetStatus(tostring(path), "error")
			end
		end)
		installButton.BackgroundColor3 = Color3.fromRGB(75, 58, 105)
		NAmanage.PluginMaker_Button(footerButtons, "Reset", function()
			NAmanage.PluginMaker_ResetState()
			pm = NAStuff.PluginMaker
			if pm.Frame and pm.Frame.Parent then pm.Frame:Destroy() end
			NAmanage.PluginMaker_BuildUI()
		end)

		pm.PreviewOverlay = NAmanage.PluginMaker_New("Frame", pm.Frame, {
			BackgroundColor3 = Color3.fromRGB(5, 5, 8);
			BackgroundTransparency = 0.16;
			BorderSizePixel = 0;
			Size = UDim2.new(1, 0, 1, 0);
			Visible = false;
			ZIndex = 100;
		})
		local previewCard = NAmanage.PluginMaker_New("Frame", pm.PreviewOverlay, {
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(1, -30, 1, -30);
			BackgroundColor3 = Color3.fromRGB(18, 19, 25);
			BorderSizePixel = 0;
			ZIndex = 101;
		})
		NAmanage.PluginMaker_Corner(previewCard, 8)
		NAmanage.PluginMaker_Stroke(previewCard, 0.45)
		local previewTitle = NAmanage.PluginMaker_Label(previewCard, "Generated Plugin Source", 14)
		previewTitle.Position = UDim2.new(0, 10, 0, 6)
		previewTitle.Size = UDim2.new(1, -92, 0, 26)
		previewTitle.Font = Enum.Font.GothamBold
		previewTitle.ZIndex = 102
		local previewClose = NAmanage.PluginMaker_Button(previewCard, "Close", function()
			pm.PreviewOverlay.Visible = false
		end)
		previewClose.AnchorPoint = Vector2.new(1, 0)
		previewClose.Position = UDim2.new(1, -8, 0, 6)
		previewClose.Size = UDim2.new(0, 68, 0, 26)
		previewClose.ZIndex = 103
		pm.PreviewBox = NAmanage.PluginMaker_New("TextBox", previewCard, {
			BackgroundColor3 = Color3.fromRGB(12, 13, 17);
			BackgroundTransparency = 0.04;
			BorderSizePixel = 0;
			ClearTextOnFocus = false;
			Font = Enum.Font.Code;
			MultiLine = true;
			Position = UDim2.new(0, 8, 0, 38);
			Size = UDim2.new(1, -16, 1, -76);
			Text = "";
			TextColor3 = Color3.fromRGB(225, 227, 235);
			TextSize = 12;
			TextWrapped = false;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Top;
			ZIndex = 102;
		})
		NAmanage.PluginMaker_Corner(pm.PreviewBox, 6)
		NAmanage.PluginMaker_Stroke(pm.PreviewBox, 0.78)
		local previewCopy = NAmanage.PluginMaker_Button(previewCard, "Copy Source", function()
			if type(setclipboard) == "function" then
				local ok = pcall(setclipboard, pm.PreviewBox.Text)
				NAmanage.PluginMaker_SetStatus(ok and "Plugin source copied" or "Copy failed", ok and "success" or "error")
			end
		end)
		previewCopy.Position = UDim2.new(0, 8, 1, -32)
		previewCopy.Size = UDim2.new(0, 110, 0, 26)
		previewCopy.ZIndex = 103

		NAmanage.PluginMaker_Resize(true)
		NAmanage.PluginMaker_RebuildCommandList()
		NAmanage.PluginMaker_RebuildEditor()
		NAmanage.PluginMaker_UpdateServiceButton()
		NAmanage.PluginMaker_SyncZIndex(pm.Frame)
		NAmanage.PluginMaker_BindResize()
		NAmanage.PluginMaker_BindDrag()

		if Services.Workspace and Services.Workspace.CurrentCamera then
			Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				if pm.Frame and pm.Frame.Parent then
					NAmanage.PluginMaker_Resize(false)
					if type(NAmanage.centerFrame) == "function" then
						pcall(NAmanage.centerFrame, pm.Frame)
					end
				end
			end)
		end
		return true
	end

	NAmanage.PluginMaker_Open = function()
		local pm = NAStuff.PluginMaker
		if type(pm.commands) ~= "table" or #pm.commands == 0 then
			NAmanage.PluginMaker_ResetState()
			pm = NAStuff.PluginMaker
		end
		if pm.Frame and pm.Frame.Parent then
			pm.Frame.Visible = true
			if pm.minimized == true then
				NAmanage.PluginMaker_ToggleMinimize()
			end
			NAmanage.PluginMaker_Resize(false)
			if type(NAmanage.centerFrame) == "function" then
				pcall(NAmanage.centerFrame, pm.Frame)
			end
			NAmanage.PluginMaker_RebuildCommandList()
			NAmanage.PluginMaker_RebuildEditor()
			NAmanage.PluginMaker_UpdateServiceButton()
			NAmanage.PluginMaker_SyncZIndex(pm.Frame)
			if not pm.ResizeCleanup then
				NAmanage.PluginMaker_BindResize()
			end
			return true
		end
		return NAmanage.PluginMaker_BuildUI()
	end

	cmd.add(
		{"pluginmaker","makeplugin","pluginbuilder","plugmaker","pmaker"},
		{"pluginmaker","Open the no-code .na/.iy plugin builder"},
		function()
			local ok, err = NAmanage.PluginMaker_Open()
			if not ok then
				DoNotif("Plugin Maker failed: "..tostring(err or "unknown error"), 3)
			end
		end
	)

	cmd.add(
		{"addallplugins","addplugins","aap","aaplugs"},
		{"addallplugins","Move all .na to Nameless-Admin/Plugins and all .iy to Nameless-Admin/PluginsIY, then load them"},
		function()
			mk(plugsDirNA)
			mk(plugsDirIY)
			const ws = root()
			const found = scan(ws)
			local moved, errs = {}, 0
			for _, src in found do
				if isIgnoredIY(src) then
					continue
				end
				local okR, data = pcall(readfile, src)
				if okR and data then
					const isIY = lp(src):match("%.iy$") ~= nil
					const dstDir = isIY and plugsDirIY or plugsDirNA
					const dst = uniq(dstDir, bn(src))
					const okW = pcall(writefile, dst, data)
					if okW and delfile and pcall(delfile, src) then
						Insert(moved, bn(dst))
					else
						errs += 1
					end
				else
					errs += 1
				end
			end
			if #moved > 0 then
				DoNotif("Moved "..#moved.." plugin file(s):\n\n"..Concat(moved, "\n"), 4.5)
				deferPluginReload()
			else
				DoNotif((errs>0) and ("No plugins moved ("..errs.." error(s))") or "No .na/.iy files found outside Plugins/PluginsIY", 3)
			end
		end
	)

	cmd.add(
		{"addplugin","addplug","ap","aplug"},
		{"addplugin","Move one .na to Plugins or one .iy to PluginsIY, then load it"},
		function(...)
			mk(plugsDirNA)
			mk(plugsDirIY)
			const query = tostring((...) or ""):lower()
			const ws = root()
			const all = scan(ws) -- already excludes anything under Plugins
			if #all == 0 then DoNotif("No .na/.iy files found outside Plugins/PluginsIY",3); return end

			const function moveOne(path)
				if isIgnoredIY(path) then
					DoNotif("Skipping IY_FE.iy (Infinite Yield settings file)", 3)
					return
				end
				const file = bn(path)
				local okR, data = pcall(readfile, path)
				if not okR or not data then DoNotif("Failed to read "..file,3); return end
				const isIY = lp(path):match("%.iy$") ~= nil
				const dstDir = isIY and plugsDirIY or plugsDirNA
				const dst = uniq(dstDir, file)
				const okW = pcall(writefile, dst, data)
				if not okW then DoNotif("Failed to write "..file,3); return end
				if not (delfile and pcall(delfile, path)) then DoNotif("Wrote but couldn't delete source "..file,3); return end
				DoNotif("Moved plugin "..file,3)
				deferPluginReload()
			end

			if #query > 0 then
				const hits = {}
				for _, p in all do
					const base = bn(p):lower()
					if base == query or base:find(query, 1, true) then Insert(hits, p) end
				end
				if #hits == 1 then moveOne(hits[1]); return end
				if #hits == 0 then DoNotif("No match for '"..query.."'",3); return end
				const btns = {}
				for _, p in hits do
					const file = bn(p)
					Insert(btns, { Text = file, Callback = function() moveOne(p) end })
				end
				const show = Window or DoWindow
				if show then show({Title = "Select Plugin", Buttons = btns}) else DoNotif("Multiple matches; refine name",3) end
				return
			end

			const btns = {}
			for _, p in all do
				const file = bn(p)
				Insert(btns, { Text = file, Callback = function() moveOne(p) end })
			end
			const show = Window or DoWindow
			if show then show({Title = "Add Plugin", Buttons = btns}) else DoNotif("UI not available",3) end
		end
	)

	cmd.add(
		{"reloadplugin","relplug","rp"},
		{"reloadplugin [name]","Reload plugin files (reloads all if no name provided)"},
		function(...)
			if not CustomFunctionSupport or not (NAmanage and NAmanage.LoadPlugins) then
				DoNotif("Plugin loader unavailable",3)
				return
			end
			const query = tostring((...) or ""):lower()
			if query ~= "" then
				local matched = false
				for _, dir in {plugsDirNA, plugsDirIY} do
					if isfolder and isfolder(dir) then
						local ok, items = pcall(listfiles, dir)
						if ok and type(items) == "table" then
							for _, path in items do
								if isPluginFile(path) then
									const name = path:match("[^\\/]+$") or path
									if name and name:lower():find(query, 1, true) then
										matched = true
										break
									end
								end
							end
						end
					end
					if matched then break end
				end
				if not matched then
					DoNotif("No plugin matched '"..query.."'",3)
					return
				end
			end
			deferPluginReload({ forceNotify = true }, function(ok)
				if not ok then
					DoNotif("Failed to reload plugins",3)
				elseif NAgui and NAgui.loadCMDS then
					pcall(NAgui.loadCMDS, { force = true })
				end
			end)
		end
	)

	cmd.add(
		{"removeplugin","rmplugin","delplugin","rmp"},
		{"removeplugin","Move a plugin file from Nameless-Admin/Plugins or Nameless-Admin/PluginsIY back to workspace"},
		function()
			if not (isfolder(plugsDirNA) or isfolder(plugsDirIY)) then DoNotif("Plugins folder not found",3); return end
			const btns = {}
			const function addButtons(dir, prefix, extPat)
				if not isfolder(dir) then return end
				local ok, items = pcall(listfiles, dir)
				if not ok or type(items) ~= "table" then return end
				for _, p in items do
					if isIgnoredIY(p) then
						continue
					end
					if type(p) == "string" and lp(p):match(extPat) then
						const file = bn(p)
						Insert(btns, {
							Text = prefix..file,
							Callback = function()
								local okR, data = pcall(readfile, p)
								if not okR or not data then DoNotif("Failed to read "..file,3); return end
								const dst = uniq("", file)
								const okW = pcall(writefile, dst, data)
								if okW and delfile and pcall(delfile, p) then
									DoNotif("Moved "..file.." to workspace",3)
									if NAmanage and NAmanage.LoadPlugins then
										deferPluginReload({ silent = true })
									elseif NAgui and NAgui.loadCMDS then
										pcall(NAgui.loadCMDS, { force = true })
									end
								else
									DoNotif("Failed to move "..file,3)
								end
							end
						})
					end
				end
			end
			addButtons(plugsDirNA, "[NA] ", "%.na$")
			addButtons(plugsDirIY, "[IY] ", "%.iy$")
			if #btns == 0 then DoNotif("No plugins found in Plugins/PluginsIY folders",3); return end
			const show = Window or DoWindow
			if show then show({Title = "Move Plugin to Workspace", Buttons = btns}) else DoNotif("Window UI not available",3) end
		end
	)

	cmd.add(
		{"removeallplugins","rmaplugins","clearplugins","rmap","rmaplugs"},
		{"removeallplugins","Move all plugins from Nameless-Admin/Plugins and Nameless-Admin/PluginsIY back to workspace"},
		function()
			if not (isfolder(plugsDirNA) or isfolder(plugsDirIY)) then DoNotif("Plugins folder not found",3); return end
			local moved, errs = {}, 0
			const function moveAll(dir, extPat)
				if not isfolder(dir) then return end
				local ok, items = pcall(listfiles, dir)
				if not ok or type(items) ~= "table" then errs += 1; return end
				for _, p in items do
					if isIgnoredIY(p) then
						continue
					end
					if type(p) == "string" and lp(p):match(extPat) then
						const file = bn(p)
						local okR, data = pcall(readfile, p)
						if okR and data then
							const dst = uniq("", file)
							const okW = pcall(writefile, dst, data)
							if okW and delfile and pcall(delfile, p) then
								Insert(moved, file)
							else
								errs += 1
							end
						else
							errs += 1
						end
					end
				end
			end
			moveAll(plugsDirNA, "%.na$")
			moveAll(plugsDirIY, "%.iy$")
			if #moved > 0 then
				DoNotif("Moved "..#moved.." plugin file(s) to workspace:\n\n"..Concat(moved, "\n"), 4.5)
			else
				DoNotif((errs>0) and ("No plugin files moved ("..errs.." error(s))") or "No plugins found",3)
			end
			deferPluginReload()
		end
	)
end

NAmanage.SaveWaypoints = function()
	if not FileSupport then return end

	const path = NAmanage.GetWPPath()

	if next(Waypoints) then
		writefile(path, Services.HttpService:JSONEncode(Waypoints))
	else
		if delfile and isfile(path) then
			pcall(delfile, path)
		elseif isfile(path) then
			writefile(path, "{}")
		end
	end
	if NAStuff and type(NAStuff.WaypointESPState) == "table"
		and NAStuff.WaypointESPState.enabled == true
		and type(NAmanage.WaypointESPRefresh) == "function" then
		Defer(function()
			if NAStuff and type(NAStuff.WaypointESPState) == "table"
				and NAStuff.WaypointESPState.enabled == true
				and type(NAmanage.WaypointESPRefresh) == "function" then
				NAmanage.WaypointESPRefresh(true)
			end
		end)
	end
end

NAmanage.LogJoinLeave = function(message)
	if not FileSupport or not appendfile or not (NAmanage.jlCfg and NAmanage.jlCfg.SaveLog) then return end

	const logPath = NAfiles.NAJOINLEAVELOG
	const timestamp = os.date("[%Y-%m-%d %H:%M:%S]")
	const includeGameInfo = NAmanage.jlCfg.LogIncludeGameInfo ~= false
	local suffix = ""
	if includeGameInfo then
		suffix = Format(
			" | Game: %s | PlaceId: %s | GameId: %s | JobId: %s",
			placeName() or "unknown",
			tostring(PlaceId),
			tostring(GameId),
			tostring(JobId)
		)
	end

	const logMessage = Format(
		"%s %s%s\n",
		timestamp,
		message,
		suffix
	)

	if isfile(logPath) then
		appendfile(logPath, logMessage)
	else
		writefile(logPath, logMessage)
	end

end
