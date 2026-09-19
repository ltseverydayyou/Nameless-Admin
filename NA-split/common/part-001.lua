
_na_boot = { splitConfig = __NA_SPLIT_CONFIG;
	hostEnv = type(__NARootHost) == "table" and __NARootHost or ((getgenv and getgenv()) or _G or {}),
}
_na_boot.hostGetfenv = type(_na_boot.hostEnv.getfenv) == "function" and _na_boot.hostEnv.getfenv or getfenv
_na_boot.hostSetfenv = type(_na_boot.hostEnv.setfenv) == "function" and _na_boot.hostEnv.setfenv or setfenv
_na_boot.hostLoadstring = type(rawget(_na_boot.hostEnv, "loadstring")) == "function" and rawget(_na_boot.hostEnv, "loadstring") or loadstring
_na_boot.hostLoad = type(rawget(_na_boot.hostEnv, "load")) == "function" and rawget(_na_boot.hostEnv, "load") or load
_na_boot.debug = rawget(_na_boot.hostEnv, "debug") or debug
_na_boot.getPrivateRegistry = function()
	local registry
	if type(getreg) == "function" then
		pcall(function()
			registry = getreg()
		end)
	end
	if type(registry) ~= "table" and type(_na_boot.debug) == "table" and type(_na_boot.debug.getregistry) == "function" then
		pcall(function()
			registry = _na_boot.debug.getregistry()
		end)
	end
	if type(registry) ~= "table" then
		registry = _na_boot.hostEnv
	end
	return registry
end
_na_boot.ensureTable = function(host, key)
	local value = type(host) == "table" and rawget(host, key) or nil
	if type(value) ~= "table" then
		value = {}
		if type(host) == "table" then
			pcall(rawset, host, key, value)
			if rawget(host, key) ~= value then
				host[key] = value
			end
		end
	end
	return value
end
_na_boot.privateRegistry = _na_boot.getPrivateRegistry()
_na_boot.privateRoot = _na_boot.ensureTable(_na_boot.privateRegistry, "__nameless_admin_private")
_na_env = _na_boot.ensureTable(_na_boot.privateRoot, "testing")
_na_shared = _na_boot.ensureTable(_na_env, "shared")
_na_boot.runtimeEnv = _na_boot.ensureTable(_na_env, "runtime")
_na_boot.runtimeEnv._na_boot = _na_boot
_na_boot.runtimeEnv._na_env = _na_env
_na_boot.runtimeEnv._na_shared = _na_shared

_na_boot.runtimeEnv.shared = _na_shared
_na_boot.runtimeEnv._G = _na_boot.runtimeEnv
_na_boot.runtimeEnv.getgenv = function()
	return _na_boot.hostEnv
end

do
	local aprilMode = type(_na_boot.hostEnv) == "table" and rawget(_na_boot.hostEnv, "ActivateAprilMode") or nil
	if aprilMode == nil then
		aprilMode = type(_na_env) == "table" and rawget(_na_env, "ActivateAprilMode") or nil
	end
	if aprilMode == nil then
		aprilMode = false
	end
	if type(_na_boot.hostEnv) == "table" then
		pcall(rawset, _na_boot.hostEnv, "ActivateAprilMode", aprilMode == true)
	end
	if type(_na_env) == "table" then
		pcall(rawset, _na_env, "ActivateAprilMode", aprilMode == true)
	end
end

_na_boot.runtimeEnv.getfenv = function(target)
	if target == nil or target == 0 then
		return _na_boot.runtimeEnv
	end
	if type(_na_boot.hostGetfenv) == "function" then
		return _na_boot.hostGetfenv(target)
	end
	return _na_boot.runtimeEnv
end

setmetatable(_na_boot.runtimeEnv, {
	__index = function(_, key)
		if key == "_G" then
			return _na_boot.runtimeEnv
		elseif key == "shared" then
			return _na_shared
		elseif key == "getgenv" then
			return _na_boot.runtimeEnv.getgenv
		elseif key == "getfenv" then
			return _na_boot.runtimeEnv.getfenv
		end
		return _na_boot.hostEnv[key]
	end
})

if type(_na_boot.hostSetfenv) == "function" then
	pcall(_na_boot.hostSetfenv, 1, _na_boot.runtimeEnv)
end

function naAlreadyLoaded()
	if _na_env and (_na_env.ltseverydayyou_NA or _na_env.NA_LOADED) then
		return true
	end
	if _na_shared and (_na_shared.ltseverydayyou_NA or _na_shared.NA_LOADED) then
		return true
	end
	if _na_boot.hostEnv and (_na_boot.hostEnv.ltseverydayyou_NA or _na_boot.hostEnv.NA_LOADED) then
		return true
	end
	return false
end

_na_boot.installExistingMCPBridge = function()
	local existing
	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" then
			existing = existing or rawget(target, "NA_MCP") or rawget(target, "NamelessAdminMCP")
		end
	end

	const options = type(rawget(_na_env, "NA_MCP_OPTIONS")) == "table" and rawget(_na_env, "NA_MCP_OPTIONS") or {}
	if options.allowUIAccess == nil then
		options.allowUIAccess = false
	end
	if options.commandPrediction == nil then
		options.commandPrediction = false
	end
	if options.notifyCommands == nil then
		options.notifyCommands = true
	end
	if options.notifyReads == nil then
		options.notifyReads = true
	end
	options.requireIdentity = true

	if type(existing) == "table"
		and tonumber(existing.version)
		and tonumber(existing.version) >= 2
		and existing.identityRequired == true
		and type(existing.identify) == "function"
		and type(existing.manifest) == "function"
	then
		existing.alreadyLoaded = true
		for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
			if type(target) == "table" then
				pcall(function()
					target.NA_MCP = existing
					target.NamelessAdminMCP = existing
					target.NA_MCP_OPTIONS = options
					target.cmdRun = target.cmdRun or existing.run
					target.RunCommand = target.RunCommand or existing.run
					target.runCommand = target.runCommand or existing.run
				end)
			end
		end
		return true
	end

	const function cleanIdentityText(value, maxLength)
		local text = tostring(value or "")
		text = text:gsub("^%s+", ""):gsub("%s+$", "")
		if #text > (maxLength or 96) then
			text = text:sub(1, maxLength or 96)
		end
		return text
	end

	const function snapshotIdentity()
		const identity = type(options.identity) == "table" and options.identity or nil
		if not identity then
			return nil
		end
		return {
			provider = cleanIdentityText(identity.provider, 64),
			model = cleanIdentityText(identity.model, 96),
			tool = cleanIdentityText(identity.tool, 96),
			client = cleanIdentityText(identity.client, 96),
			version = cleanIdentityText(identity.version, 48),
			sessionId = cleanIdentityText(identity.sessionId, 96),
			displayName = cleanIdentityText(identity.displayName, 96),
			connectedAt = identity.connectedAt,
		}
	end

	const function identityLabel()
		const identity = snapshotIdentity()
		if not identity then
			return ""
		end
		local tool = identity.tool ~= "" and identity.tool or identity.client
		local model = identity.model
		if tool ~= "" and model ~= "" then
			return tool.." | "..model
		elseif model ~= "" then
			return model
		end
		return tool
	end

	const function normalizeIdentity(info)
		if type(info) ~= "table" then
			return nil, "identity must be a table"
		end
		const model = cleanIdentityText(info.model or info.modelName or info.aiModel, 96)
		const tool = cleanIdentityText(info.tool or info.aiTool or info.clientTool or info.mcpTool, 96)
		const client = cleanIdentityText(info.client or info.clientName or info.application, 96)
		if model == "" then
			return nil, "AI model is required"
		end
		if tool == "" then
			return nil, "AI tool is required"
		end
		return {
			provider = cleanIdentityText(info.provider or info.vendor or info.company, 64),
			model = model,
			tool = tool,
			client = client,
			version = cleanIdentityText(info.version or info.clientVersion or info.toolVersion, 48),
			sessionId = cleanIdentityText(info.sessionId or info.session or info.conversationId, 96),
			displayName = cleanIdentityText(info.displayName or info.name, 96),
			connectedAt = tick(),
		}
	end

	const function notifyExistingBridge(action, detail, isRead, force)
		if options.notifyCommands ~= true and force ~= true then
			return
		end
		if isRead and options.notifyReads ~= true and force ~= true then
			return
		end
		local notifier = rawget(_na_env, "DoNotif") or rawget(_na_shared, "DoNotif") or rawget(_na_boot.runtimeEnv, "DoNotif") or rawget(_na_boot.hostEnv, "DoNotif")
		if type(notifier) ~= "function" and type(DoNotif) == "function" then
			notifier = DoNotif
		end
		if type(notifier) ~= "function" then
			return
		end
		const label = identityLabel()
		const fallbackActor = cleanIdentityText(options.actor, 96)
		const actor = label ~= "" and label or fallbackActor
		const prefix = actor ~= "" and ("MCP ["..actor.."]") or "MCP"
		local msg = prefix.." "..tostring(action or "activity")
		if detail and tostring(detail) ~= "" then
			msg ..= ": "..tostring(detail)
		end
		if #msg > 220 then
			msg = msg:sub(1, 217).."..."
		end
		pcall(notifier, msg, isRead and 1.75 or 2.75, "MCP")
	end

	const function findRunner()
		for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
			if type(target) == "table" then
				for _, key in { "RunCommand", "runCommand", "cmdRun" } do
					const fn = rawget(target, key)
					if type(fn) == "function" then
						return fn
					end
				end
			end
		end
		return nil
	end

	const bridge = type(existing) == "table" and existing or {}
	const previousHelpers = {}
	for _, helperName in { "run", "runSequence", "commands", "snapshot", "basicInfo", "logs", "ui", "activity", "options" } do
		const fn = bridge[helperName]
		if type(fn) == "function" then
			previousHelpers[helperName] = fn
		end
	end
	const previousRun = previousHelpers.run
	const previousUI = previousHelpers.ui
	bridge.name = "Nameless Admin MCP Bridge"
	bridge.version = 2
	bridge.protocolVersion = "2.0"
	bridge.kind = "nameless-admin"
	bridge.ready = true
	bridge.alreadyLoaded = true
	bridge.identityRequired = true
	bridge.requiredIdentityFields = { "model", "tool" }
	bridge.instructions = "Before using NA MCP operational helpers, identify yourself with bridge.identify({provider=..., model=..., tool=..., client=...}). Use the exact model name when available and never invent one. Tell the user which AI tool/client and model are connected to Nameless Admin MCP Bridge. After each command or state-changing action, tell the user which NA MCP helper/command ran and summarize its result."
	bridge.helpers = { "identify", "handshake", "hello", "whoami", "manifest", "help", "status", "run", "runSequence", "commands", "snapshot", "basicInfo", "logs", "ui", "activity", "options", "ping", "disconnectAI" }

	const function meta(operation)
		const identity = snapshotIdentity()
		local disclosure
		if identity then
			const provider = identity.provider ~= "" and (" by "..identity.provider) or ""
			disclosure = "Nameless Admin MCP Bridge "..tostring(operation or "activity").." used "..identity.tool.." with "..identity.model..provider.."."
		end
		return {
			bridge = bridge.name,
			bridgeVersion = bridge.version,
			protocolVersion = bridge.protocolVersion,
			operation = tostring(operation or ""),
			identityRequired = true,
			ai = identity,
			disclosureRequired = identity ~= nil,
			userDisclosure = disclosure,
		}
	end

	const function attachMeta(payload, operation)
		if type(payload) ~= "table" then
			payload = { ok = true, result = payload }
		end
		const mcpMeta = meta(operation)
		payload.mcp = mcpMeta
		if mcpMeta.userDisclosure and payload.mustTellUser == nil then
			payload.mustTellUser = mcpMeta.userDisclosure
		end
		return payload
	end

	const function requireIdentity(operation)
		if snapshotIdentity() then
			return true
		end
		const payload = {
			ok = false,
			code = "MCP_AI_IDENTITY_REQUIRED",
			error = "AI identity required before '"..tostring(operation or "operation").."'. Call bridge.identify with the AI model and MCP tool/client first.",
			requiredAction = "identify",
			requiredFields = { "model", "tool" },
			instructions = bridge.instructions,
		}
		payload.mcp = meta(operation)
		notifyExistingBridge("blocked "..tostring(operation or "operation"), "AI model/tool identity required", false, true)
		return false, payload
	end

	const function callPrevious(helperName, isRead, ...)
		local allowed, denial = requireIdentity(helperName)
		if not allowed then
			return denial
		end
		const fn = previousHelpers[helperName]
		if type(fn) ~= "function" then
			notifyExistingBridge(helperName.." error", "helper unavailable", isRead == true, true)
			return attachMeta({ ok = false, error = "Existing NA runtime does not expose '"..helperName.."'. Reload NA fully to install the complete MCP v2 bridge." }, helperName)
		end
		local ok, result = pcall(fn, ...)
		if not ok then
			notifyExistingBridge(helperName.." error", tostring(result), isRead == true, true)
			return attachMeta({ ok = false, error = tostring(result) }, helperName)
		end
		return attachMeta(result, helperName)
	end

	bridge.ping = function()
		return attachMeta({
			ok = true,
			name = bridge.name,
			version = bridge.version,
			protocolVersion = bridge.protocolVersion,
			alreadyLoaded = true,
			testing = _na_env and _na_env.NATestingVer == true or false,
			identityRequired = true,
			identified = snapshotIdentity() ~= nil,
			requiredIdentityFields = bridge.requiredIdentityFields,
			helpers = bridge.helpers,
			instructions = bridge.instructions,
			time = os.time and os.time() or nil,
		}, "ping")
	end

	bridge.manifest = function()
		return attachMeta({
			ok = true,
			name = bridge.name,
			version = bridge.version,
			kind = bridge.kind,
			identityRequired = true,
			requiredIdentityFields = bridge.requiredIdentityFields,
			instructions = bridge.instructions,
			tools = {
				{ name = "identify", description = "Register the AI provider, exact model, MCP tool and client before operational access." },
				{ name = "whoami", description = "Read the currently registered AI identity." },
				{ name = "ping", description = "Read bridge version, readiness and handshake requirements." },
				{ name = "run", description = "Run an exposed Nameless Admin command after AI identification." },
				{ name = "ui", description = "Read NA UI metadata; the Instance is returned only when UI access is enabled." },
				{ name = "options", description = "Read or change bridge options. Mutating options requires identification." },
				{ name = "disconnectAI", description = "Clear the active AI identity and require a new handshake." },
			},
		}, "manifest")
	end
	bridge.help = bridge.manifest

	bridge.identify = function(info)
		local identity, err = normalizeIdentity(info)
		if not identity then
			return attachMeta({
				ok = false,
				code = "MCP_INVALID_AI_IDENTITY",
				error = err,
				requiredFields = { "model", "tool" },
				instructions = bridge.instructions,
			}, "identify")
		end
		options.identity = identity
		options.actor = identityLabel()
		notifyExistingBridge("AI connected", identityLabel(), false, true)
		const provider = identity.provider ~= "" and (" by "..identity.provider) or ""
		return attachMeta({
			ok = true,
			identity = snapshotIdentity(),
			disclosureRequired = true,
			userDisclosure = "Connected to Nameless Admin MCP Bridge through "..identity.tool.." using "..identity.model..provider..".",
			instructions = bridge.instructions,
		}, "identify")
	end
	bridge.handshake = bridge.identify
	bridge.hello = bridge.identify

	bridge.whoami = function()
		const identity = snapshotIdentity()
		return attachMeta({
			ok = identity ~= nil,
			identified = identity ~= nil,
			identity = identity,
			requiredFields = identity and nil or { "model", "tool" },
			instructions = bridge.instructions,
		}, "whoami")
	end

	bridge.status = function()
		return attachMeta({
			ok = true,
			ready = true,
			identified = snapshotIdentity() ~= nil,
			identity = snapshotIdentity(),
			allowUIAccess = options.allowUIAccess == true,
			commandPrediction = options.commandPrediction == true,
			notifyCommands = options.notifyCommands == true,
			notifyReads = options.notifyReads == true,
			requireIdentity = true,
		}, "status")
	end

	bridge.options = function(nextOptions)
		if type(nextOptions) == "table" then
			local allowed, denial = requireIdentity("options")
			if not allowed then
				return denial
			end
			if type(previousHelpers.options) == "function" then
				local ok, result = pcall(previousHelpers.options, nextOptions)
				if not ok then
					return attachMeta({ ok = false, error = tostring(result) }, "options")
				end
				return attachMeta(result, "options")
			end
			const changed = {}
			for key, value in nextOptions do
				if key == "allowUIAccess" or key == "commandPrediction" or key == "notifyCommands" or key == "notifyReads" then
					options[key] = value == true
					changed[#changed + 1] = key.."="..tostring(options[key])
				elseif key == "notifyActivity" then
					options.notifyCommands = value == true
					changed[#changed + 1] = "notifyCommands="..tostring(options.notifyCommands)
				elseif key == "actor" then
					options.actor = cleanIdentityText(value, 96)
				end
			end
			if #changed > 0 then
				notifyExistingBridge("options", table.concat(changed, ", "), false, true)
			end
		elseif type(previousHelpers.options) == "function" then
			local ok, result = pcall(previousHelpers.options)
			if ok then
				return attachMeta(result, "options")
			end
		end
		return attachMeta({
			ok = true,
			allowUIAccess = options.allowUIAccess == true,
			commandPrediction = options.commandPrediction == true,
			notifyCommands = options.notifyCommands == true,
			notifyActivity = options.notifyCommands == true,
			notifyReads = options.notifyReads == true,
			requireIdentity = true,
			identity = snapshotIdentity(),
		}, "options")
	end

	bridge.run = function(...)
		local allowed, denial = requireIdentity("run")
		if not allowed then
			return denial
		end
		if type(previousRun) == "function" and previousRun ~= bridge.run then
			local ok, result = pcall(previousRun, ...)
			if not ok then
				notifyExistingBridge("command error", tostring(result), false, true)
				return attachMeta({ ok = false, error = tostring(result) }, "run")
			end
			return attachMeta(result, "run")
		end
		const runner = findRunner()
		if type(runner) ~= "function" or runner == bridge.run then
			notifyExistingBridge("command error", "runner unavailable", false, true)
			return attachMeta({ ok = false, error = "NA command runner is not exposed yet." }, "run")
		end
		local ok, result = pcall(runner, ...)
		if not ok then
			notifyExistingBridge("command error", tostring(result), false, true)
			return attachMeta({ ok = false, error = tostring(result) }, "run")
		end
		const parts = {}
		for i = 1, select("#", ...) do
			parts[#parts + 1] = tostring(select(i, ...) or "")
		end
		notifyExistingBridge("ran", table.concat(parts, " "), false, false)
		return attachMeta({ ok = true, result = result }, "run")
	end

	bridge.ui = function()
		local allowed, denial = requireIdentity("ui")
		if not allowed then
			return denial
		end
		if type(previousUI) == "function" and previousUI ~= bridge.ui then
			local ok, result = pcall(previousUI)
			if not ok then
				return attachMeta({ ok = false, error = tostring(result) }, "ui")
			end
			return attachMeta(result, "ui")
		end
		notifyExistingBridge("requested UI", options.allowUIAccess == true and "access granted" or "access denied", true, false)
		local gui = rawget(_na_env, "NA_UI_INSTANCE") or rawget(_na_env, "NA_RAW_UI")
			or rawget(_na_shared, "NA_UI_INSTANCE") or rawget(_na_shared, "NA_RAW_UI")
		if not gui then
			const get = rawget(_na_env, "NA_UI") or rawget(_na_shared, "NA_UI")
			if type(get) == "function" then
				pcall(function()
					gui = get()
				end)
			end
		end
		const isInst = typeof(gui) == "Instance"
		const info = {
			ok = true,
			hasUI = isInst,
			allowUIAccess = options.allowUIAccess == true,
		}
		if isInst then
			info.name = gui.Name
			info.className = gui.ClassName
			info.enabled = gui.Enabled
			info.parentClassName = gui.Parent and gui.Parent.ClassName or nil
			if options.allowUIAccess == true then
				info.instance = gui
			end
		end
		return attachMeta(info, "ui")
	end

	bridge.runSequence = function(...)
		return callPrevious("runSequence", false, ...)
	end

	bridge.commands = function(...)
		return callPrevious("commands", true, ...)
	end

	bridge.snapshot = function(...)
		return callPrevious("snapshot", true, ...)
	end

	bridge.basicInfo = function(...)
		return callPrevious("basicInfo", true, ...)
	end

	bridge.logs = function(...)
		return callPrevious("logs", true, ...)
	end

	bridge.activity = function(...)
		return callPrevious("activity", true, ...)
	end

	bridge.disconnectAI = function()
		local allowed, denial = requireIdentity("disconnectAI")
		if not allowed then
			return denial
		end
		const oldIdentity = snapshotIdentity()
		notifyExistingBridge("AI disconnected", identityLabel(), false, true)
		options.identity = nil
		options.actor = ""
		return attachMeta({ ok = true, disconnected = oldIdentity }, "disconnectAI")
	end

	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" then
			pcall(function()
				target.NA_MCP = bridge
				target.NamelessAdminMCP = bridge
				target.NA_MCP_OPTIONS = options
				target.cmdRun = target.cmdRun or bridge.run
				target.RunCommand = target.RunCommand or bridge.run
				target.runCommand = target.runCommand or bridge.run
			end)
		end
	end

	return true
end

if naAlreadyLoaded() then
	_na_boot.installExistingMCPBridge()
	return
end

naFlagValue = tick()
naVerifyKey = "Arys also known as tim1540 loves skidding and lying like a little bitch he is grow up retard"

_na_boot.syncRuntimeGlobals = function(values)
	if type(values) ~= "table" then
		return
	end

	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" then
			for key, value in values do
				pcall(function()
					target[key] = value
				end)
			end
		end
	end
end

_na_boot.syncRuntimeGlobals({
	ltseverydayyou_NA = naFlagValue,
	NA_LOADED = naFlagValue,
	NATestingVer = _na_boot.splitConfig.testing,
	NAverify = naVerifyKey,
	NAKey = naVerifyKey,
	__NAKeySource = _na_boot.splitConfig.sourceTag,
})

_na_boot.lowerHeaders = function(headers)
	const out = {}
	if type(headers) == "table" then
		for key, value in headers do
			out[string.lower(tostring(key))] = value
		end
	end
	return out
end

_na_boot.getResponseStatus = function(response)
	if type(response) ~= "table" then
		return nil
	end
	return tonumber(response.StatusCode or response.statusCode or response.Status or response.status or response.Code or response.code)
end

_na_boot.getResponseBody = function(response)
	if type(response) == "string" then
		return response
	end
	if type(response) ~= "table" then
		return nil
	end
	const body = response.Body or response.body or response.Data or response.data or response.Text or response.text or response.Content or response.content or response.ResponseBody or response.responseBody
	return type(body) == "string" and body or nil
end

_na_boot.getRetryAfter = function(response)
	if type(response) ~= "table" then
		return nil
	end
	const headers = _na_boot.lowerHeaders(response.Headers or response.headers)
	const retryAfter = tonumber(headers["retry-after"]) or tonumber(headers["x-ratelimit-retryafter"]) or tonumber(headers["x-rate-limit-retry-after"])
	return retryAfter
end

_na_boot.isRetryableHttp = function(response, err)
	const status = _na_boot.getResponseStatus(response)
	if status == 408 or status == 425 or status == 429 or (status and status >= 500 and status < 600) then
		return true
	end
	const text = string.lower(tostring(err or _na_boot.getResponseBody(response) or ""))
	return text:find("429", 1, true) ~= nil
		or text:find("too many requests", 1, true) ~= nil
		or text:find("rate limit", 1, true) ~= nil
		or text:find("timed out", 1, true) ~= nil
		or text:find("timeout", 1, true) ~= nil
end

_na_boot.sleepHttp = function(seconds)
	seconds = math.clamp(tonumber(seconds) or 0, 0, 20)
	if type(task) == "table" and type(task.wait) == "function" then
		task.wait(seconds)
	elseif type(wait) == "function" then
		wait(seconds)
	end
end

_na_boot.getExecutorRequest = function()
	const host = _na_boot.hostEnv
	const candidates = {
		type(request) == "function" and request or nil,
		type(http_request) == "function" and http_request or nil,
		type(syn) == "table" and type(syn.request) == "function" and syn.request or nil,
		type(http) == "table" and type(http.request) == "function" and http.request or nil,
		type(fluxus) == "table" and type(fluxus.request) == "function" and fluxus.request or nil,
		type(host) == "table" and type(rawget(host, "request")) == "function" and rawget(host, "request") or nil,
		type(host) == "table" and type(rawget(host, "http_request")) == "function" and rawget(host, "http_request") or nil,
	}
	for _, fn in candidates do
		if type(fn) == "function" then
			return fn
		end
	end
	return nil
end

_na_boot.makeHttpPayload = function(url, opts)
	opts = type(opts) == "table" and opts or {}
	const payload = {
		Url = url,
		url = url,
		Method = opts.Method or opts.method or "GET",
		method = opts.method or opts.Method or "GET",
		Headers = opts.Headers or opts.headers or {
			Accept = "*/*",
		},
		Timeout = tonumber(opts.Timeout or opts.timeout) or 10,
		FollowRedirects = opts.FollowRedirects ~= false,
		SslVerify = opts.SslVerify == true,
	}
	if opts.Body ~= nil or opts.body ~= nil then
		payload.Body = opts.Body or opts.body
		payload.body = opts.body or opts.Body
	end
	return payload
end

_na_boot.requestUrl = function(url, opts)
	const requestFn = _na_boot.getExecutorRequest()
	if type(requestFn) ~= "function" then
		return false, nil, "executor request unavailable"
	end
	return pcall(requestFn, _na_boot.makeHttpPayload(url, opts))
end

_na_boot.httpGet = function(url, opts)
	opts = type(opts) == "table" and opts or {}
	if type(url) ~= "string" or url == "" then
		error("missing url", 2)
	end
	const maxAttempts = math.clamp(math.floor(tonumber(opts.maxAttempts or opts.retries) or 5), 1, 10)
	const timeout = tonumber(opts.timeout or opts.Timeout) or 10
	local lastErr
	for attempt = 1, maxAttempts do
		local okReq, response = _na_boot.requestUrl(url, { Method = "GET", Timeout = timeout, Headers = opts.Headers or opts.headers })
		if okReq and response then
			const status = _na_boot.getResponseStatus(response)
			const body = _na_boot.getResponseBody(response)
			if type(response) == "string" and response ~= "" then
				return response
			end
			if (status == nil or (status >= 200 and status < 300) or status == 304) and type(body) == "string" and body ~= "" then
				return body
			end
			lastErr = "HTTP "..tostring(status or "unknown")
			if not _na_boot.isRetryableHttp(response, lastErr) then
				break
			end
		else
			lastErr = tostring(response or "request failed")
		end

		local okGet, body = pcall(function()
			if opts.noCache ~= nil then
				return game:HttpGet(url, opts.noCache)
			end
			return game:HttpGet(url)
		end)
		if okGet and type(body) == "string" and body ~= "" then
			return body
		end
		if not _na_boot.isRetryableHttp(nil, body) and not _na_boot.isRetryableHttp(nil, lastErr) then
			lastErr = tostring(body or lastErr or "request failed")
			break
		end
		lastErr = tostring(body or lastErr or "request failed")
		if attempt < maxAttempts then
			const retryAfter = _na_boot.getRetryAfter(response)
			const delay = retryAfter or math.min(8, (0.65 * (2 ^ (attempt - 1))) + (math.random() * 0.35))
			_na_boot.sleepHttp(delay)
		end
	end
	error(lastErr or "HTTP request failed", 2)
end

_na_boot.bootstrapRemoteSources = {}
_na_boot.prefetchBootstrapRemotes = function()
	const targets = {}
	if type(rawget(_na_boot.privateRoot, "serviceResolver")) ~= "table" then
		targets.serviceResolver = "https://ltseverydayyou.github.io/ServiceResolver.luau"
	end
	const uiProtectorBuild = "session_name_cursed_null_v1"
	const cachedProtector = rawget(_na_boot.privateRoot, "uiProtector")
	if type(cachedProtector) ~= "table" or rawget(cachedProtector, "ready") ~= true or rawget(cachedProtector, "build") ~= uiProtectorBuild then
		targets.uiProtector = "https://ltseverydayyou.github.io/UIprotector.luau"
	end

	local pending = 0
	const canParallel = type(task) == "table" and type(task.spawn) == "function" and type(task.wait) == "function"
	for key, url in targets do
		if canParallel then
			pending += 1
			task.spawn(function()
				local ok, source = pcall(_na_boot.httpGet, url, { maxAttempts = 2; timeout = 5; })
				_na_boot.bootstrapRemoteSources[key] = ok and source or false
				pending -= 1
			end)
		else
			local ok, source = pcall(_na_boot.httpGet, url, { maxAttempts = 2; timeout = 5; })
			_na_boot.bootstrapRemoteSources[key] = ok and source or false
		end
	end
	while pending > 0 do
		task.wait()
	end
end
_na_boot.getBootstrapRemoteSource = function(key, url)
	const cached = _na_boot.bootstrapRemoteSources[key]
	if type(cached) == "string" and cached ~= "" then
		return cached
	end
	return _na_boot.httpGet(url, { maxAttempts = 3; timeout = 5; })
end
_na_boot.prefetchBootstrapRemotes()

__lt = (function()
	const cached = rawget(_na_boot.privateRoot, "serviceResolver");
	if type(cached) == "table" then
		return cached;
	end;
	const loader = loadstring or load;
	if type(loader) ~= "function" then
		error("Service resolver loader unavailable");
	end;
	const resolver = loader(_na_boot.getBootstrapRemoteSource("serviceResolver", "https://ltseverydayyou.github.io/ServiceResolver.luau"), "@ServiceResolver.luau");
	if type(resolver) ~= "function" then
		error("Service resolver failed to compile");
	end;
	const loaded = resolver();
	if type(loaded) ~= "table" then
		error("Service resolver failed to load");
	end;
	_na_boot.privateRoot.serviceResolver = loaded;
	return loaded;
end)();

__NAUIProtector = (function()
	const uiProtectorBuild = "session_name_cursed_null_v1";
	const cached = rawget(_na_boot.privateRoot, "uiProtector");
	if type(cached) == "table" and rawget(cached, "ready") == true and rawget(cached, "build") == uiProtectorBuild then
		return cached;
	end;
	if type(cached) == "table" then
		pcall(function()
			if type(cached.cleanup) == "function" then
				cached.cleanup();
			end
		end)
		pcall(function()
			if type(cached.restore) == "function" then
				cached.restore();
			end
		end)
	end
	const loader = loadstring or load;
	if type(loader) ~= "function" then
		error("UI protector loader unavailable");
	end;
	const protector = loader(_na_boot.getBootstrapRemoteSource("uiProtector", "https://ltseverydayyou.github.io/UIprotector.luau"), "@UIprotector.luau");
	if type(protector) ~= "function" then
		error("UI protector failed to compile");
	end;
	const loaded = protector();
	if type(loaded) ~= "table" then
		error("UI protector failed to load");
	end;
	_na_boot.privateRoot.uiProtector = loaded;
	return loaded;
end)();

pcall(function()
	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv } do
		if type(target) == "table" then
			target.__NAServiceResolver = __lt
			target.__NAUIProtector = __NAUIProtector
		end
	end
	_na_boot.privateRoot.serviceResolver = __lt
	_na_boot.privateRoot.uiProtector = __NAUIProtector
end)

NAbegin=tick()
CMDAUTOFILL={}

NAmanage={}

NAindex = {}
NAmanage._runtimeState = type(_na_env._NARuntimeState) == "table" and _na_env._NARuntimeState or {}
_na_env._NARuntimeState = NAmanage._runtimeState
NAmanage._runtimeState.runSeq = (tonumber(NAmanage._runtimeState.runSeq) or 0) + 1
NAmanage._runtimeState.spawnActive = type(NAmanage._runtimeState.spawnActive) == "table" and NAmanage._runtimeState.spawnActive or {}
NAmanage._runtimeState.waitingThreads = type(NAmanage._runtimeState.waitingThreads) == "table" and NAmanage._runtimeState.waitingThreads or {}
NAmanage._runtimeState.unloadThread = nil
NAmanage._runToken = {}
NAmanage._runtimeState.runToken = NAmanage._runToken
NAmanage._runtimeState.unloading = false
_na_env._NARunToken = NAmanage._runToken

NAjobs = type(_na_env._NAjobs) == "table" and _na_env._NAjobs or {}
_na_env._NAjobs = NAjobs
NAjobs.jobs = NAjobs.jobs or {}
NAjobs._touchState = NAjobs._touchState or {}
NAjobs._frame = NAjobs._frame or 0
NAjobs._claimed = NAjobs._claimed or {}

Lower    = string.lower
Sub      = string.sub
GSub     = string.gsub
Find     = string.find
Match    = string.match
Format   = string.format

Unpack   = table.unpack
Insert   = table.insert
Concat   = table.concat
Discover = table.find

_naRawTaskSpawn = task.spawn
_naRawTaskDelay = task.delay
_naRawTaskWait = task.wait
_naRawTaskDefer = task.defer
Spawn, Delay, Wait, Defer = nil, nil, nil, nil

NAmanage._rawTaskSpawn = _naRawTaskSpawn
NAmanage._rawTaskDelay = _naRawTaskDelay
NAmanage._rawTaskWait = _naRawTaskWait
NAmanage._rawTaskDefer = _naRawTaskDefer
NAmanage._runtimeState.spawnActive = setmetatable(NAmanage._runtimeState.spawnActive, { __mode = "k" })
NAmanage._runtimeState.waitingThreads = setmetatable(NAmanage._runtimeState.waitingThreads, { __mode = "k" })

function runTrackedTask(token, callback, args)
	const running = coroutine.running()
	if rawget(_na_env, "_NARunToken") ~= token or NAmanage._runtimeState.unloading == true then
		NAmanage._runtimeState.spawnActive[running] = nil
		return
	end
	local rawTaskError
	const results = table.pack(xpcall(function()
		return callback(table.unpack(args, 1, args.n))
	end, function(message)
		rawTaskError = tostring(message or "Unknown error")
		if type(debug) == "table" and type(debug.traceback) == "function" then
			local ok, trace = pcall(debug.traceback, rawTaskError, 2)
			if ok and type(trace) == "string" and trace ~= "" then return trace end
		end
		return rawTaskError
	end))
	NAmanage._runtimeState.spawnActive[running] = nil
	if not results[1] and rawget(_na_env, "_NARunToken") == token and NAmanage._runtimeState.unloading ~= true then
		const trace = tostring(results[2] or rawTaskError or "Unknown error")
		if type(NAmanage.NACallerReportExternalError) == "function" then
			pcall(NAmanage.NACallerReportExternalError, rawTaskError or trace, trace, callback, { context = "NA Tracked Task"; severity = "error" })
		else
			__NARootReportError(rawTaskError or trace, trace, "NA Tracked Task", callback, { severity = "error" })
		end
	end
	return table.unpack(results, 2, results.n)
end

Spawn = function(callback, ...)
	if type(callback) ~= "function" then
		return nil
	end
	const token = NAmanage._runToken
	const args = table.pack(...)
	const thread = _naRawTaskSpawn(runTrackedTask, token, callback, args)
	NAmanage._runtimeState.spawnActive[thread] = true
	return thread
end

Delay = function(seconds, callback, ...)
	if type(callback) ~= "function" then
		return nil
	end
	const token = NAmanage._runToken
	const args = table.pack(...)
	const thread = _naRawTaskDelay(tonumber(seconds) or 0, runTrackedTask, token, callback, args)
	NAmanage._runtimeState.spawnActive[thread] = true
	return thread
end

Defer = function(callback, ...)
	if type(callback) ~= "function" then
		return nil
	end
	const token = NAmanage._runToken
	const args = table.pack(...)
	const thread = _naRawTaskDefer(runTrackedTask, token, callback, args)
	NAmanage._runtimeState.spawnActive[thread] = true
	return thread
end

Wait = function(...)
	const token = NAmanage._runToken
	const running = coroutine.running()
	if type(running) == "thread" then
		NAmanage._runtimeState.waitingThreads[running] = true
	end
	const results = table.pack(_naRawTaskWait(...))
	if type(running) == "thread" then
		NAmanage._runtimeState.waitingThreads[running] = nil
	end
	if rawget(_na_env, "_NARunToken") ~= token or NAmanage._runtimeState.unloading == true then
		if running == NAmanage._runtimeState.unloadThread then
			return table.unpack(results, 1, results.n)
		end
		if type(running) == "thread" then
			_naRawTaskDefer(function()
				pcall(task.cancel, running)
			end)
			return coroutine.yield()
		end
		return nil
	end
	return table.unpack(results, 1, results.n)
end

NAmanage.Wrap = function(callback)
	if type(callback) ~= "function" then
		return function() end
	end
	const token = NAmanage._runToken
	const thread = coroutine.create(function(...)
		return callback(...)
	end)
	NAmanage._runtimeState.spawnActive[thread] = true
	return function(...)
		if rawget(_na_env, "_NARunToken") ~= token or NAmanage._runtimeState.unloading == true then
			pcall(task.cancel, thread)
			NAmanage._runtimeState.spawnActive[thread] = nil
			return
		end
		const results = table.pack(coroutine.resume(thread, ...))
		if not results[1] then
			NAmanage._runtimeState.spawnActive[thread] = nil
			error(results[2], 0)
		end
		if coroutine.status(thread) == "dead" then
			NAmanage._runtimeState.spawnActive[thread] = nil
		end
		return table.unpack(results, 2, results.n)
	end
end

NAmanage.MergeMissing = NAmanage.MergeMissing or function(target, source)
	if type(target) ~= "table" or type(source) ~= "table" then
		return target
	end
	for key, value in source do
		if target[key] == nil then
			target[key] = value
		end
	end
	return target
end

NAmanage.IsActiveRun = NAmanage.IsActiveRun or function(token)
	return rawget(_na_env, "_NARunToken") == (token or NAmanage._runToken)
end

NAmanage.isLiveInstance = NAmanage.isLiveInstance or function(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	if inst == game then
		return true
	end
	local ok, parent = pcall(function()
		return inst.Parent
	end)
	return ok and parent ~= nil
end

NAmanage.ensureWeakTable = NAmanage.ensureWeakTable or function(tbl, mode)
	mode = type(mode) == "string" and mode or "k"
	if type(tbl) ~= "table" then
		tbl = {}
	end
	const mt = getmetatable(tbl)
	if type(mt) == "table" and mt.__mode == mode then
		return tbl
	end
	const weak = setmetatable({}, { __mode = mode })
	for key, value in tbl do
		weak[key] = value
	end
	return weak
end

NAmanage.ensureWeakKeyTable = NAmanage.ensureWeakKeyTable or function(tbl)
	return NAmanage.ensureWeakTable(tbl, "k")
end

NAmanage.tryDisconnect = NAmanage.tryDisconnect or function(conn)
	if conn and type(conn.Disconnect) == "function" then
		pcall(function()
			conn:Disconnect()
		end)
	end
	return nil
end

NAmanage.isLiveConnection = NAmanage.isLiveConnection or function(conn)
	if conn == nil then
		return false
	end
	if typeof(conn) == "RBXScriptConnection" then
		local ok, connected = pcall(function()
			return conn.Connected
		end)
		return ok and connected ~= false
	end
	const disconnect = conn and conn.Disconnect
	if type(disconnect) ~= "function" then
		return false
	end
	if type(conn) == "table" then
		const connected = rawget(conn, "Connected")
		if connected ~= nil then
			return connected ~= false
		end
	end
	local ok, connectedValue = pcall(function()
		return conn.Connected
	end)
	if ok and connectedValue ~= nil then
		return connectedValue ~= false
	end
	return true
end

NAmanage.ConnectHumanoidDeath = NAmanage.ConnectHumanoidDeath or function(hum, callback, opts)
	if typeof(hum) ~= "Instance" or not hum:IsA("Humanoid") then
		return nil
	end

	const watcher = {
		Connected = true,
		_hum = hum,
		_conns = {},
		_dead = false,
	}

	const function disconnectAll()
		if not watcher.Connected then
			return
		end
		watcher.Connected = false
		for i = 1, #watcher._conns do
			NAmanage.tryDisconnect(watcher._conns[i])
			watcher._conns[i] = nil
		end
	end

	function watcher:Disconnect()
		disconnectAll()
	end

	const function fire()
		if watcher._dead then
			return
		end
		watcher._dead = true
		disconnectAll()
		if type(callback) ~= "function" then
			return
		end
		if opts and opts.defer == false then
			pcall(callback, hum)
			return
		end
		Defer(function()
			pcall(callback, hum)
		end)
	end

	watcher._conns[#watcher._conns + 1] = hum.Died:Connect(function()
		fire()
	end)
	watcher._conns[#watcher._conns + 1] = hum.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Dead then
			fire()
		end
	end)
	watcher._conns[#watcher._conns + 1] = hum.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			disconnectAll()
		end
	end)

	return watcher
end

NAmanage.pruneInstanceKeyMap = NAmanage.pruneInstanceKeyMap or function(map, onRemove)
	if type(map) ~= "table" then
		return
	end
	for key, value in map do
		if typeof(key) == "Instance" and not NAmanage.isLiveInstance(key) then
			if type(onRemove) == "function" then
				pcall(onRemove, value, key)
			end
			map[key] = nil
		end
	end
end

NAmanage.pruneConnectionArray = NAmanage.pruneConnectionArray or function(list, resolver)
	if type(list) ~= "table" then
		return
	end
	local write = 1
	for i = 1, #list do
		const item = list[i]
		const conn = type(resolver) == "function" and resolver(item) or item
		if NAmanage.isLiveConnection(conn) then
			list[write] = item
			write += 1
		end
	end
	for i = write, #list do
		list[i] = nil
	end
end

NAmanage.pruneInstanceArray = NAmanage.pruneInstanceArray or function(list, onRemove)
	if type(list) ~= "table" then
		return
	end
	local write = 1
	for i = 1, #list do
		const item = list[i]
		local keep = true
		if typeof(item) == "Instance" then
			keep = NAmanage.isLiveInstance(item)
		end
		if keep then
			list[write] = item
			write += 1
		else
			if type(onRemove) == "function" then
				pcall(onRemove, item, i)
			end
		end
	end
	for i = write, #list do
		list[i] = nil
	end
end

NAmanage.pruneConnectionValueMap = NAmanage.pruneConnectionValueMap or function(map)
	if type(map) ~= "table" then
		return
	end
	for key, value in map do
		if not NAmanage.isLiveConnection(value) then
			map[key] = nil
		end
	end
end

NAmanage.pruneInstanceValueMap = NAmanage.pruneInstanceValueMap or function(map, cb)
	if type(map) ~= "table" then
		return
	end
	for key, val in map do
		if typeof(val) == "Instance" and not NAmanage.isLiveInstance(val) then
			if type(cb) == "function" then
				pcall(cb, val, key)
			end
			map[key] = nil
		end
	end
end

NAmanage.pruneInstancePairMap = NAmanage.pruneInstancePairMap or function(map, cb)
	if type(map) ~= "table" then
		return
	end
	for key, val in map do
		local dead = false
		if typeof(key) == "Instance" and not NAmanage.isLiveInstance(key) then
			dead = true
		elseif typeof(val) == "Instance" and not NAmanage.isLiveInstance(val) then
			dead = true
		end
		if dead then
			if type(cb) == "function" then
				pcall(cb, val, key)
			end
			map[key] = nil
		end
	end
end

NAmanage.pruneRecordMap = NAmanage.pruneRecordMap or function(map, fields, cb)
	if type(map) ~= "table" then
		return
	end
	fields = type(fields) == "table" and fields or {}
	for key, rec in map do
		local dead = false
		if typeof(key) == "Instance" and not NAmanage.isLiveInstance(key) then
			dead = true
		elseif typeof(rec) == "Instance" and not NAmanage.isLiveInstance(rec) then
			dead = true
		elseif type(rec) == "table" then
			for i = 1, #fields do
				const val = rec[fields[i]]
				if typeof(val) == "Instance" and not NAmanage.isLiveInstance(val) then
					dead = true
					break
				end
			end
			if rec.removed == true then
				dead = true
			end
		end
		if dead then
			if type(cb) == "function" then
				pcall(cb, rec, key)
			end
			map[key] = nil
		end
	end
end

NAmanage.pruneSparseInstanceArray = NAmanage.pruneSparseInstanceArray or function(list, fields, cb)
	if type(list) ~= "table" then
		return
	end
	fields = type(fields) == "table" and fields or {}
	for key, item in list do
		if type(key) == "number" then
			local dead = false
			if typeof(item) == "Instance" then
				dead = not NAmanage.isLiveInstance(item)
			elseif type(item) == "table" then
				if item.removed == true then
					dead = true
				else
					for i = 1, #fields do
						const val = item[fields[i]]
						if typeof(val) == "Instance" and not NAmanage.isLiveInstance(val) then
							dead = true
							break
						end
					end
				end
			end
			if dead then
				if type(cb) == "function" then
					pcall(cb, item, key)
				end
				list[key] = nil
			end
		end
	end
end

NAmanage.pruneRuntimeInstanceState = NAmanage.pruneRuntimeInstanceState or function()
	const state = NAStuff
	if type(state) ~= "table" then
		return
	end
	if type(NAmanage.ensureRuntimeWeakTables) == "function" then
		pcall(NAmanage.ensureRuntimeWeakTables)
	end

	NAmanage.pruneInstanceKeyMap(state._afTracked)
	NAmanage.pruneInstanceKeyMap(state._afOrigCan)
	NAmanage.pruneInstanceKeyMap(state._afpTracked)
	NAmanage.pruneInstanceKeyMap(state._afpOrigCan)
	NAmanage.pruneInstanceKeyMap(state._aaTracked)
	NAmanage.pruneInstanceKeyMap(state._aaOrig)
	NAmanage.pruneInstanceKeyMap(state._godOrig)
	NAmanage.pruneInstanceKeyMap(state._kbMovedParts)
	NAmanage.pruneInstanceKeyMap(state._kbTouchParts)
	NAmanage.pruneInstanceKeyMap(state._kbTouchOriginal)
	NAmanage.pruneInstanceKeyMap(state.partESPGlassOriginal)
	NAmanage.pruneInstanceKeyMap(state.partESPGlassCount)
	NAmanage.pruneInstanceKeyMap(state.partESPLocalTransOriginal)
	NAmanage.pruneInstanceKeyMap(state.partESPLocalTransCount)

	NAmanage.pruneInstanceKeyMap(state._afSignals, function(conn)
		NAmanage.tryDisconnect(conn)
	end)
	NAmanage.pruneInstanceKeyMap(state._afpSignals, function(arr)
		if type(arr) == "table" then
			for i = 1, #arr do
				arr[i] = NAmanage.tryDisconnect(arr[i])
			end
		end
	end)
	NAmanage.pruneInstanceKeyMap(state._aaSignals, function(conn)
		NAmanage.tryDisconnect(conn)
	end)
	NAmanage.pruneInstanceKeyMap(state._godSignals, function(arr)
		if type(arr) == "table" then
			for i = 1, #arr do
				NAmanage.tryDisconnect(arr[i])
				arr[i] = nil
			end
		end
	end)
	NAmanage.pruneInstanceKeyMap(state.bHumCons, function(rec)
		if type(rec) == "table" and type(rec.conns) == "table" then
			for i = 1, #rec.conns do
				rec.conns[i] = NAmanage.tryDisconnect(rec.conns[i])
			end
		end
	end)
	NAmanage.pruneInstanceKeyMap(state.bToolCons, function(rec)
		if type(rec) == "table" and type(rec.conns) == "table" then
			for i = 1, #rec.conns do
				rec.conns[i] = NAmanage.tryDisconnect(rec.conns[i])
			end
		end
	end)
	NAmanage.pruneInstanceKeyMap(state.bSetCons, function(conn)
		NAmanage.tryDisconnect(conn)
	end)
	NAmanage.pruneInstanceKeyMap(state.bHum)
	NAmanage.pruneInstanceKeyMap(state.bTool)
	NAmanage.pruneInstanceKeyMap(state.bSet)

	if type(state.elementOriginalParent) == "table" then
		for inst, parent in state.elementOriginalParent do
			if not NAmanage.isLiveInstance(inst) or (typeof(parent) == "Instance" and not NAmanage.isLiveInstance(parent)) then
				state.elementOriginalParent[inst] = nil
			end
		end
	end

	NAmanage.pruneConnectionArray(state.LastInputConns)
	NAmanage.pruneConnectionArray(state.PreferredInputConns)
	NAmanage.pruneConnectionArray(state.antiAFKStored, function(item)
		return type(item) == "table" and item.conn or nil
	end)
	NAmanage.pruneInstanceArray(state.shownParts)
	NAmanage.pruneInstanceArray(state.tpTools)
	NAmanage.pruneInstanceArray(state.touchESPList)
	NAmanage.pruneInstanceArray(state.proximityESPList)
	NAmanage.pruneInstanceArray(state.clickESPList)
	NAmanage.pruneInstanceArray(state.itemESPList)
	NAmanage.pruneInstanceArray(state.siteESPList)
	NAmanage.pruneInstanceArray(state.vehicleSiteESPList)
	NAmanage.pruneInstanceArray(state.unanchoredESPList)
	NAmanage.pruneInstanceArray(state.collisiontrueESPList)
	NAmanage.pruneInstanceArray(state.collisionfalseESPList)
	NAmanage.pruneInstanceArray(state.propertyESPList)
	NAmanage.pruneInstanceArray(state.ESP_ModelList)
	NAmanage.pruneInstanceArray(state.BlockedRemotes)
	NAmanage.pruneInstanceArray(state.RobloxVersionRows)

	NAmanage.pruneInstanceKeyMap(state.npcCandidates)
	NAmanage.pruneInstanceKeyMap(state.npcESPList)
	NAmanage.pruneInstanceKeyMap(state.itemESPSet)
	NAmanage.pruneInstanceKeyMap(state.itemESPToolMap)
	NAmanage.pruneInstanceKeyMap(state.itemESPPartMap)
	NAmanage.pruneInstanceKeyMap(state.unanchoredESPSet)
	NAmanage.pruneInstanceKeyMap(state.collisiontrueESPSet)
	NAmanage.pruneInstanceKeyMap(state.collisionfalseESPSet)
	NAmanage.pruneInstanceKeyMap(state.propertyESPSet)
	NAmanage.pruneInstanceKeyMap(state.propertyESPMatchCounts)
	if type(state.propertyESPObjectMaps) == "table" then
		for _, objectMap in state.propertyESPObjectMaps do
			NAmanage.pruneInstanceKeyMap(objectMap)
		end
	end
	NAmanage.pruneInstanceKeyMap(state._ncColl)
	if type(state.ChatTranslator) == "table" and type(state.ChatTranslator.messages) == "table" then
		state.ChatTranslator.messages = NAmanage.ensureWeakKeyTable(state.ChatTranslator.messages)
		NAmanage.pruneInstanceKeyMap(state.ChatTranslator.messages)
	end
	NAmanage.pruneInstanceKeyMap(state._messageCopyHooks, function(hook)
		if type(hook) == "table" and type(hook.cleanup) == "function" then
			pcall(hook.cleanup)
		end
	end)
	NAmanage.pruneInstanceKeyMap(state.BlockedRemoteModes)
	NAmanage.pruneInstanceKeyMap(state.BlockedRemoteReturns)
	NAmanage.pruneInstanceKeyMap(state.BlockedEventSaved)
	NAmanage.pruneInstanceKeyMap(state.BlockedInvokeSaved)
	NAmanage.pruneInstanceKeyMap(state.ESP_OcclusionCache)
	NAmanage.pruneInstanceKeyMap(NAmanage._canvasLayoutCache)
	NAmanage.pruneInstanceKeyMap(NAmanage._canvasHeightCache)
	NAmanage.pruneInstanceValueMap(NAmanage._statCache)
	NAmanage.pruneInstanceKeyMap(NAmanage.toolCache)
	NAmanage.pruneInstanceKeyMap(NAmanage.grabBusy)
	NAmanage.pruneInstanceKeyMap(NAmanage.toolGrabCol)
	if type(state.airMomentum) == "table" then
		NAmanage.pruneConnectionValueMap(state.airMomentum.connections)
		if typeof(state.airMomentum.root) == "Instance" and not NAmanage.isLiveInstance(state.airMomentum.root) then
			state.airMomentum.root = nil
		end
		if typeof(state.airMomentum.hum) == "Instance" and not NAmanage.isLiveInstance(state.airMomentum.hum) then
			state.airMomentum.hum = nil
		end
	end
	if type(NAmanage._charAddHub) == "table" then
		NAmanage.pruneInstanceKeyMap(NAmanage._charAddHub.pending)
	end
	if type(NAmanage.pruneChatLogState) == "function" then
		NAmanage.pruneChatLogState()
	end
	if type(NAmanage.pruneAdminChatRainbow) == "function" then
		NAmanage.pruneAdminChatRainbow()
	end
	if state._rbxDevConsoleCopyTarget and not NAmanage.isLiveInstance(state._rbxDevConsoleCopyTarget) then
		if type(NAmanage.cleanupRobloxDevConsoleCopyButtons) == "function" then
			pcall(NAmanage.cleanupRobloxDevConsoleCopyButtons)
		else
			state._rbxDevConsoleCopyTarget = nil
			state._rbxDevConsoleCopyRefresh = nil
			state._rbxDevConsoleCopyCleanup = nil
		end
	end
	if type(NAmanage._descHubs) == "table" and type(NAmanage._descHubDispose) == "function" then
		for root, hub in NAmanage._descHubs do
			if not NAmanage.isLiveInstance(root) or type(hub) ~= "table" or hub.root ~= root or hub.alive == false then
				pcall(NAmanage._descHubDispose, root, hub)
			end
		end
	end
	if type(NAmanage._childHubs) == "table" and type(NAmanage._childHubDispose) == "function" then
		for root, hub in NAmanage._childHubs do
			if not NAmanage.isLiveInstance(root) or type(hub) ~= "table" or hub.root ~= root or hub.alive == false then
				pcall(NAmanage._childHubDispose, root, hub)
			end
		end
	end
	if type(NAmanage._mouseMoveHubs) == "table" and type(NAmanage._mouseMoveHubDispose) == "function" then
		for mouseObj, hub in NAmanage._mouseMoveHubs do
			if mouseObj == nil or type(hub) ~= "table" or hub.mouse ~= mouseObj or hub.alive == false or (tonumber(hub.count) or 0) <= 0 then
				pcall(NAmanage._mouseMoveHubDispose, mouseObj, hub)
			end
		end
	end

	if type(state.CommandLabelPool) == "table" then
		for name, label in state.CommandLabelPool do
			if typeof(label) == "Instance" and not NAmanage.isLiveInstance(label) then
				state.CommandLabelPool[name] = nil
			end
		end
	end

	if type(state.tviewBillboards) == "table" then
		for plr, data in state.tviewBillboards do
			if not NAmanage.isLiveInstance(plr) or type(data) ~= "table" then
				state.tviewBillboards[plr] = nil
			elseif (data.bb and not NAmanage.isLiveInstance(data.bb))
				or (data.head and not NAmanage.isLiveInstance(data.head))
				or (data.char and not NAmanage.isLiveInstance(data.char)) then
				if type(NAmanage.tvDetach) == "function" then
					pcall(NAmanage.tvDetach, plr)
				else
					state.tviewBillboards[plr] = nil
				end
			end
		end
	end

	if type(state.airwalk) == "table" then
		NAmanage.pruneConnectionValueMap(state.airwalk.connections)
		if type(state.airwalk.guis) == "table" then
			for key, gui in state.airwalk.guis do
				if typeof(gui) == "Instance" and not NAmanage.isLiveInstance(gui) then
					state.airwalk.guis[key] = nil
				end
			end
		end
	end
	if type(state._commandKeybindUI) == "table" then
		const root = state._commandKeybindUI.root
		if typeof(root) == "Instance" and not NAmanage.isLiveInstance(root) then
			state._commandKeybindUI = nil
		end
	end

	const lState = _na_env and _na_env._LState
	if type(lState) == "table" then
		for _, key in { "ne", "nf" } do
			const rec = lState[key]
			if type(rec) == "table" and type(rec.cache) == "table" then
				rec.cache = NAmanage.ensureWeakKeyTable(rec.cache)
				NAmanage.pruneInstanceKeyMap(rec.cache)
			end
		end
	end


	if type(NAindex) == "table" and type(NAindex.pruneCaches) == "function" then
		pcall(NAindex.pruneCaches)
	end

	if type(state.partESPEntries) == "table" then
		const staleEntries = {}
		for _, entry in state.partESPEntries do
			if type(entry) == "table" then
				const deadPart = typeof(entry.part) == "Instance" and not NAmanage.isLiveInstance(entry.part)
				const deadKey = typeof(entry.entryKey) == "Instance" and not NAmanage.isLiveInstance(entry.entryKey)
				const deadVisual = typeof(entry.visual) == "Instance" and not NAmanage.isLiveInstance(entry.visual)
				const deadBillboard = typeof(entry.billboard) == "Instance" and not NAmanage.isLiveInstance(entry.billboard)
				if entry.removed or deadPart or deadKey or deadVisual or deadBillboard then
					staleEntries[#staleEntries + 1] = entry
				end
			end
		end
		if #staleEntries > 0 and type(NAmanage.PartESP_UnregisterEntry) == "function" then
			for i = 1, #staleEntries do
				pcall(NAmanage.PartESP_UnregisterEntry, staleEntries[i])
			end
		end
	end

	if type(state.partESPQueue) == "table" then
		NAmanage.pruneSparseInstanceArray(state.partESPQueue, { "part" }, function(item)
			if type(item) == "table" then
				const part = item.part
				if typeof(part) == "Instance" and type(state.partESPQueueMap) == "table" and state.partESPQueueMap[part] == item then
					state.partESPQueueMap[part] = nil
				end
				item.part = nil
				item.guard = nil
			end
		end)
	end
	NAmanage.pruneRecordMap(state.partESPQueueMap, { "part" })
	NAmanage.pruneRecordMap(state.partESPVisualMap, { "part", "visual", "billboard" })

	if type(state.partESPPartMap) == "table" then
		for part, bucket in state.partESPPartMap do
			if not NAmanage.isLiveInstance(part) or type(bucket) ~= "table" then
				state.partESPPartMap[part] = nil
			else
				for entryKey, entry in bucket do
					const badEntry = type(entry) ~= "table" or entry.removed
					const badKey = typeof(entryKey) == "Instance" and not NAmanage.isLiveInstance(entryKey)
					if badEntry or badKey then
						bucket[entryKey] = nil
					end
				end
				if not next(bucket) then
					state.partESPPartMap[part] = nil
				end
			end
		end
	end

	if type(state.folderESPMembers) == "table" then
		for folder, list in state.folderESPMembers do
			if not NAmanage.isLiveInstance(folder) then
				const key = type(state.folderESPKeys) == "table" and state.folderESPKeys[folder] or nil
				if key then
					NAlib.disconnect(key)
					state.folderESPKeys[folder] = nil
				end
				const token = type(state.folderESPScanTokens) == "table" and state.folderESPScanTokens[folder] or nil
				if token and type(NAmanage.CancelTokenCancel) == "function" then
					pcall(NAmanage.CancelTokenCancel, token)
				end
				if type(state.folderESPScanTokens) == "table" then
					state.folderESPScanTokens[folder] = nil
				end
				if type(state.folderESPMemberMaps) == "table" then
					state.folderESPMemberMaps[folder] = nil
				end
				state.folderESPMembers[folder] = nil
			else
				NAmanage.pruneInstanceArray(list)
				const map = type(state.folderESPMemberMaps) == "table" and state.folderESPMemberMaps[folder] or nil
				if type(map) == "table" then
					NAmanage.pruneInstanceKeyMap(map)
				end
			end
		end
	end
	if type(state.folderESPKeys) == "table" then
		NAmanage.pruneInstanceKeyMap(state.folderESPKeys, function(key)
			if key then
				NAlib.disconnect(key)
			end
		end)
	end
	if type(state.folderESPScanTokens) == "table" then
		NAmanage.pruneInstanceKeyMap(state.folderESPScanTokens, function(token)
			if token and type(NAmanage.CancelTokenCancel) == "function" then
				pcall(NAmanage.CancelTokenCancel, token)
			end
		end)
	end
	if type(state.folderESPModes) == "table" then
		NAmanage.pruneInstanceKeyMap(state.folderESPModes)
	end

	if type(state.modelESPMembers) == "table" then
		for model, list in state.modelESPMembers do
			const validModel = NAmanage.isLiveInstance(model) and model:IsA("Model")
			if not validModel then
				const key = type(state.modelESPKeys) == "table" and state.modelESPKeys[model] or nil
				if key then
					NAlib.disconnect(key)
					state.modelESPKeys[model] = nil
				end
				const token = type(state.modelESPScanTokens) == "table" and state.modelESPScanTokens[model] or nil
				if token and type(NAmanage.CancelTokenCancel) == "function" then
					pcall(NAmanage.CancelTokenCancel, token)
				end
				if type(list) == "table" then
					for i = #list, 1, -1 do
						const part = list[i]
						if type(NAmanage.PartESP_QueueRemove) == "function" then
							pcall(NAmanage.PartESP_QueueRemove, part)
						end
						if type(NAmanage.RemoveEspFromPart) == "function" then
							pcall(NAmanage.RemoveEspFromPart, part)
						end
						list[i] = nil
					end
				end
				if type(state.modelESPMemberMaps) == "table" then
					state.modelESPMemberMaps[model] = nil
				end
				if type(state.modelESPMap) == "table" then
					state.modelESPMap[model] = nil
				end
				if type(state.modelESPScanTokens) == "table" then
					state.modelESPScanTokens[model] = nil
				end
				if type(state.modelESPModes) == "table" then
					state.modelESPModes[model] = nil
				end
				state.modelESPMembers[model] = nil
			else
				NAmanage.pruneInstanceArray(list)
				const map = type(state.modelESPMemberMaps) == "table" and state.modelESPMemberMaps[model] or nil
				if type(map) == "table" then
					NAmanage.pruneInstanceKeyMap(map)
				end
			end
		end
	end
	if type(state.modelESPKeys) == "table" then
		NAmanage.pruneInstanceKeyMap(state.modelESPKeys, function(key)
			if key then
				NAlib.disconnect(key)
			end
		end)
	end
	if type(state.modelESPScanTokens) == "table" then
		NAmanage.pruneInstanceKeyMap(state.modelESPScanTokens, function(token)
			if token and type(NAmanage.CancelTokenCancel) == "function" then
				pcall(NAmanage.CancelTokenCancel, token)
			end
		end)
	end
	if type(state.modelESPModes) == "table" then
		NAmanage.pruneInstanceKeyMap(state.modelESPModes)
	end
	if type(state.modelESPModels) == "table" then
		for i = #state.modelESPModels, 1, -1 do
			const model = state.modelESPModels[i]
			if not (NAmanage.isLiveInstance(model) and model:IsA("Model")) then
				if type(NAmanage.ESP_ListRemove) == "function" and type(state.modelESPMap) == "table" then
					pcall(NAmanage.ESP_ListRemove, state.modelESPModels, state.modelESPMap, model)
				else
					table.remove(state.modelESPModels, i)
					if type(state.modelESPMap) == "table" then
						state.modelESPMap[model] = nil
						for idx = i, #state.modelESPModels do
							const current = state.modelESPModels[idx]
							if current ~= nil then
								state.modelESPMap[current] = idx
							end
						end
					end
				end
				if type(state.modelESPModes) == "table" then
					state.modelESPModes[model] = nil
				end
			end
		end
	end

	if type(state.PST) == "table" then
		NAmanage.pruneInstanceKeyMap(state.PST.orig)
		NAmanage.pruneInstanceArray(state.PST.exact)
		NAmanage.pruneInstanceArray(state.PST.partial)
	end

	if type(state.ESP_LocatorArrows) == "table" then
		for key, holder in state.ESP_LocatorArrows do
			if typeof(holder) == "Instance" and not NAmanage.isLiveInstance(holder) then
				state.ESP_LocatorArrows[key] = nil
			end
		end
	end
	if type(state.ESP_PlayerLocatorArrows) == "table" then
		for key, holder in state.ESP_PlayerLocatorArrows do
			if typeof(holder) == "Instance" and not NAmanage.isLiveInstance(holder) then
				state.ESP_PlayerLocatorArrows[key] = nil
			end
		end
	end

	if type(state.activeTeleports) == "table" then
		for key, taskState in state.activeTeleports do
			if type(taskState) ~= "table" or taskState.active ~= true then
				state.activeTeleports[key] = nil
			end
		end
	end

	if type(UserButtonGuiList) == "table" then
		NAmanage.pruneInstanceArray(UserButtonGuiList)
	end
	if type(UserButtonGuiMap) == "table" then
		for id, gui in UserButtonGuiMap do
			if typeof(gui) == "Instance" and not NAmanage.isLiveInstance(gui) then
				UserButtonGuiMap[id] = nil
			end
		end
	end
	if type(UserButtonDropdowns) == "table" then
		for id, drop in UserButtonDropdowns do
			if type(drop) == "table" then
				if drop.conn and not NAmanage.isLiveConnection(drop.conn) then
					drop.conn = nil
				end
				if drop.container and not NAmanage.isLiveInstance(drop.container) then
					drop.container = nil
				end
				if drop.container == nil and drop.conn == nil then
					UserButtonDropdowns[id] = nil
				end
			elseif typeof(drop) == "Instance" and not NAmanage.isLiveInstance(drop) then
				UserButtonDropdowns[id] = nil
			end
		end
	end

	if type(coreGuiProtection) == "table" then
		NAmanage.pruneInstanceKeyMap(coreGuiProtection)
	end
	if type(storedTools) == "table" then
		NAmanage.pruneInstanceArray(storedTools)
	end
	if type(npcCache) == "table" then
		NAmanage.pruneInstanceArray(npcCache)
	end
	if type(NAmanage.pruneInteractionIndex) == "function" then
		pcall(NAmanage.pruneInteractionIndex)
	end
	if type(HumanModCons) == "table" then
		NAmanage.pruneConnectionValueMap(HumanModCons)
	end
	if type(ToolLoopCons) == "table" then
		NAmanage.pruneConnectionValueMap(ToolLoopCons)
	end
	if type(MultiToolCons) == "table" then
		NAmanage.pruneConnectionValueMap(MultiToolCons)
	end
	if type(glueloop) == "table" then
		NAmanage.pruneConnectionValueMap(glueloop)
	end
	if type(glueBACKER) == "table" then
		NAmanage.pruneConnectionValueMap(glueBACKER)
	end

	if type(NAgui) == "table" then
		NAmanage.pruneInstanceKeyMap(NAgui._resizeCleanup, function(cleanup)
			if type(cleanup) == "function" then
				pcall(cleanup)
			end
		end)
		if type(NAgui._toggleRegistry) == "table" then
			for key, entry in NAgui._toggleRegistry do
				const button = type(entry) == "table" and entry.button or nil
				if typeof(button) == "Instance" and not NAmanage.isLiveInstance(button) then
					NAgui._toggleRegistry[key] = nil
				end
			end
		end
		if type(NAgui._colorPickerRegistry) == "table" then
			for key, entry in NAgui._colorPickerRegistry do
				const picker = type(entry) == "table" and entry.picker or nil
				if typeof(picker) == "Instance" and not NAmanage.isLiveInstance(picker) then
					NAgui._colorPickerRegistry[key] = nil
				end
			end
		end
		if type(NAgui._inputRegistry) == "table" then
			for key, entry in NAgui._inputRegistry do
				const input = type(entry) == "table" and entry.input or nil
				if typeof(input) == "Instance" and not NAmanage.isLiveInstance(input) then
					NAgui._inputRegistry[key] = nil
				end
			end
		end
		if type(NAgui._sliderRegistry) == "table" then
			for key, entry in NAgui._sliderRegistry do
				const slider = type(entry) == "table" and entry.slider or nil
				if typeof(slider) == "Instance" and not NAmanage.isLiveInstance(slider) then
					NAgui._sliderRegistry[key] = nil
				end
			end
		end
		if type(NAgui._dropdownRegistry) == "table" then
			for key, entry in NAgui._dropdownRegistry do
				local dropdown = type(entry) == "table" and entry.dropdown or nil
				if dropdown == nil and type(entry) == "table" and type(entry.api) == "table" then
					dropdown = entry.api.Instance
				end
				if typeof(dropdown) == "Instance" and not NAmanage.isLiveInstance(dropdown) then
					NAgui._dropdownRegistry[key] = nil
				end
			end
		end
		if type(NAgui._keybindRegistry) == "table" then
			for key, entry in NAgui._keybindRegistry do
				const keybind = type(entry) == "table" and (entry.keybind or entry.button) or nil
				if typeof(keybind) == "Instance" and not NAmanage.isLiveInstance(keybind) then
					NAgui._keybindRegistry[key] = nil
				end
			end
		end
	end

	if type(TopBarApp) == "table" and type(TopBarApp.childButtons) == "table" then
		NAmanage.pruneInstanceKeyMap(TopBarApp.childButtons)
	end
end

NAmanage._gmx31 = NAmanage._gmx31 or function(bytes, seed)
	const out = {}
	seed = tonumber(seed) or 0
	for i = 1, #bytes do
		const key = ((seed + (i * 3)) % 11) + 17
		out[i] = string.char((tonumber(bytes[i]) or 0) - key)
	end
	return Concat(out)
end
NAmanage._guardTokens = NAmanage._guardTokens or {
	name = NAmanage._gmx31({
		142, 132, 125, 133, 129, 100, 122, 121, 135, 97, 87, 136, 131, 135, 134, 135, 119, 137, 128, 132, 129, 125, 130, 117, 127, 88, 108, 107, 104, 107, 112, 86, 97, 108, 82, 103, 106
	}, 5);
	value = NAmanage._gmx31({
		119, 139, 138, 135, 106, 111, 85, 96, 101, 116, 87, 95, 92, 92
	}, 2);
}
NAmanage._routeGateText = NAmanage._routeGateText or NAmanage._gmx31({
	146, 130, 131, 137, 49, 139, 134, 135, 130, 53, 69, 59, 127, 133, 136, 124, 135, 55, 134, 123, 128, 125, 59, 140, 133, 142, 49, 117, 137, 127, 50, 119, 132, 124, 118, 129, 133, 122, 135, 139, 127, 118, 53, 106, 112, 91, 54, 107, 96, 92, 55, 84, 78
}, 7)
NAmanage._routeGateExit = NAmanage._routeGateExit or function()
	const value = NAmanage._routeGateText
	if type(value) == "string" and #value == 53 then
		local total = 0
		for i = 1, #value do
			total = total + (i * (string.byte(value, i) or 0))
		end
		if total == 119325 then
			return value
		end
	end
	return nil
end
NAmanage._routeGateBlob = NAmanage._routeGateBlob or NAmanage._gmx31({
	54, 89, 86, 78, 131, 107, 149, 88, 125, 74, 112, 106, 145, 107, 139, 109, 120, 87, 141, 100, 78, 99, 128, 107, 148, 129, 95, 106, 86, 126, 144, 59, 119, 97, 62, 132, 80
}, 9)

NAmanage._la0 = NAmanage._la0 or { 122, 135, 136, 133, 137, 81, 64, 65, 133, 117, 140, 68 }
NAmanage._cf0 = NAmanage._cf0 or { 86, 133, 139, 118 }
NAmanage._lx2 = NAmanage._lx2 or { 101, 136, 132, 133, 133, 137, 133, 64, 127, 137, 118, 139 }

Notify = nil
Window = nil
Popup  = nil

NA_TABS = {
	TAB_ALL = "All";
	TAB_GENERAL = "General";
	TAB_INTEGRATIONS = "Integrations";
	TAB_INTERFACE = "Interface";
	TAB_FFLAGS = "FFlags";
	TAB_ENGINE_SETTINGS = "Engine Settings";
	TAB_AUTOMATION = "Automation";
	TAB_MANAGEMENT = "Management";
	TAB_SAVE_INSTANCE = "Save Instance";
	TAB_USER_BUTTONS = "User Buttons";
	TAB_LOGGING = "Logging";
	TAB_ESP = "ESP";
	TAB_CHAT = "Chat";
	TAB_CHARACTER = "Character";
	TAB_KEYBINDS = "Keybinds";
	TAB_BASIC_INFO = "Basic Info";
	TAB_ROBLOX_DATA = "Roblox Data";
	TAB_CONTRIBUTORS = "Contributors";
	TAB_ADMIN_INFO = "NA Info";
}

NAStuff = {
	prefixCheck = ";";
	Notification = nil;
	CmdBar2 = (NAStuff and NAStuff.CmdBar2) or {
		defaultWidth = 340;
		defaultHeight = 78;
		minWidth = 200;
		maxWidth = 500;
		minHeight = 70;
		maxHeight = 160;
		topHeight = 26;
		bodyOffsetY = 34;
		bodyBottomPadding = 8;
		bodyMinHeight = 24;
	};
	NAICONMAIN = nil;
	NASCREENGUI = nil; --Getmodel("rbxassetid://140418556029404")
	NAjson = nil;
	nuhuhNotifs = true;
	dmNotificationsEnabled = true;
	inviteLink = { 122, 135, 136, 133, 137, 81, 64, 65, 119, 125, 136, 121, 134, 131, 118, 65, 123, 124, 69, 145, 139, 124, 108, 124, 137, 99, 94, 87, 86 };
	docsLink = { 122, 135, 136, 133, 137, 81, 64, 65, 127, 136, 136, 123, 141, 118, 132, 140, 120, 118, 143, 144, 128, 135, 65, 123, 126, 138, 127, 134, 116, 65, 125, 132, 69, 101, 82, 63, 119, 131, 120, 137 };
	supportLink = { 122, 135, 136, 133, 137, 81, 64, 65, 126, 131, 66, 124, 128, 63, 117, 130, 129, 68, 130, 139, 132, 119, 137, 121, 135, 143, 123, 114, 139, 140, 131, 138 };
	officialRepoLink = { 122, 135, 136, 133, 137, 81, 64, 65, 122, 125, 137, 126, 140, 115, 64, 118, 131, 130, 69, 131, 133, 133, 120, 138, 122, 136, 144, 117, 115, 140, 141, 132, 139, 70, 95, 115, 128, 121, 129, 123, 138, 132, 63, 84, 120, 130, 127, 133 };
	_lb0 = { 127, 132, 135, 126, 142, 115, 137, 138, 127, 132, 120, 135, 137, 135, 123, 135, 133, 66 };
	_cf1 = { 89, 136, 125, 98, 119, 133, 122, 130 };
	_lx1 = { 84, 129, 123 };
	KeybindConnection = nil;
	StreamerModeEnabled = false;
	StreamerModeText = "User";
	StreamerModeGray = Color3.fromRGB(127, 127, 127);
	StreamerModeImage = "rbxasset://textures/LightThemeLoadingCircle.png";
	StreamerModeState = {
		cache = {};
		nameTokens = {};
		token = nil;
		restoreToken = nil;
		applied = false;
		scrubBusy = false;
	};
	AutoExecEnabled = true;
	UserButtonsAutoLoad = true;
	StartupInitializersReady = false;
	FriendRequestAutoDismiss = false;
	ConnectionsToFriends = false;
	UnsafeFunctionsDisabled = false;
	UnsafeFunctionState = {
		originals = {};
	};
	VirtualInputAPIDisabled = false;
	VirtualInputAPIState = {
		originals = {};
	};
	HWIDFunctionsDisabled = false;
	HWIDSpoofEnabled = false;
	HWIDSpoofValue = "";
	HWIDFunctionState = {
		originals = {};
		captured = {};
	};
	ClientIDSpoofEnabled = false;
	ClientIDSpoofValue = "";
	ClientIDSpoofState = {
		hooked = false;
		directTarget = nil;
		directOriginal = nil;
		namecallTarget = nil;
		namecallOriginal = nil;
	};
	SynEnvEnabled = false;
	SynEnvState = {
		captured = false;
		originalSyn = nil;
		createdSyn = false;
		added = {};
	};
	CmdBar2AutoRun = false;
	CmdInputSafeMode = true;
	HideCmdAutofill = false;
	LegacyCommandUI = false;
	LegacyHorizontalSettingsTabs = false;
	SettingsSidebarCompactMode = false;
	CmdIntegrationAutoRun = false;
	CmdIntegrationLoaded = false;
	CmdIntegrationLastSource = nil;
	CmdIntegrationRoutingMode = "NA First";
	CmdIntegrationExposeGateway = true;
	CmdIntegrationUseNotifications = true;
	CmdIntegrationMirrorNotifications = false;
	IYIntegrationAutoRun = false;
	IYIntegrationLoaded = false;
	IYIntegrationLastSource = nil;
	IYIntegrationRoutingMode = "NA First";
	IYIntegrationExposeGateway = true;
	IYIntegrationMirrorNotifications = false;
	cmdAutofillLoading = false;
	cmdAutofillLoadRequested = false;
	uiBootHidden = false;
	HideStartup = false;
	keepCmdFocus = false;
	cmdInputAtInit = nil;
	tweenSpeed = 1;
	tpDelay = 0.2;
	AutoInteractDefaultInterval = 0.1;
	AutoFireRemoteDefaultInterval = 0.1;
	AutoInteractMethod = "PostSimulation";
	AutoFireRemoteMethod = "PostSimulation";
	ClickTouchMaxDistance = 1024;
	ClickTouchScreenRadius = 18;
	ClickTouchBlockedByCollide = false;
	ClickTouchIgnoreNonCollideBlockers = true;
	ClickTouchInvisibleFallback = true;
	ClickTouchAlwaysOnTop = false;
	FreecamSpeed = 5;
	MobileFlyAutoEnableOnRun = true;
	MobileCamSensitivity = 1;
	MobileCamSensEnabled = false;
	CFlyVisualizerOn = true;
	OffVisOn = true;
	OffVisAcc = true;
	OffVisFTr = 0.82;
	OffVisOTr = 0.15;
	BlockedRemotes = {};
	touchESPList = {};
	proximityESPList = {};
	clickESPList = {};
	itemESPList = {};
	itemESPSet = {};
	itemESPToolMap = {};
	itemESPPartMap = {};
	itemESPEnabled = false;
	siteESPList = {};
	vehicleSiteESPList = {};
	unanchoredESPList = {};
	unanchoredESPSet = {};
	collisiontrueESPList = {};
	collisiontrueESPSet = {};
	collisionfalseESPList = {};
	collisionfalseESPSet = {};
	propertyESPList = {};
	propertyESPSet = {};
	propertyESPMatchCounts = {};
	propertyESPObjectMaps = {};
	propertyESPQueries = {};
	espTriggers = {};
	espNameLists = { exact = {}, partial = {} };
	espNameTriggers = {};
	nameESPPartLists = { exact = {}, partial = {} };
	nameESPPartMaps = {
		exact = {},
		partial = {},
	};
	ESP_RenderMode = "Highlight";
	ESP_PartRenderMode = "BoxHandleAdornment";
	ESP_Transparency = 0.7;
	ESP_PartTransparency = 0.45;
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
	ESP_PartNameSweepInterval = 18;
	ESP_NameWatchPerStep = 96;
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
	ESP_OcclusionColor = Color3.fromRGB(130, 130, 130);
	ESP_OcclusionCache = setmetatable({}, { __mode = "k" });
	ESP_UseCustomColor = false;
	ESP_CustomColor = Color3.new(1, 1, 1);
	ESP_OutlineTransparency = 0;
	ESP_IgnoreTeam = false;
	ESP_TargetTeam = "";
	ESP_PlayerTargetMode = "all";
	ESP_ShowPartText = true;
	ESP_ShowPartDistance = false;
	ESP_PartColor_Name = Color3.fromRGB(255, 255, 255);
	ESP_PartColor_Folder = Color3.fromRGB(255, 220, 0);
	ESP_PartColor_Model = Color3.fromRGB(0, 200, 255);
	ESP_PartColor_Touch = Color3.fromRGB(255, 0, 0);
	ESP_PartColor_Proximity = Color3.fromRGB(0, 0, 255);
	ESP_PartColor_Click = Color3.fromRGB(255, 165, 0);
	ESP_PartColor_Item = Color3.fromRGB(90, 255, 135);
	ESP_PartColor_Seat = Color3.fromRGB(0, 255, 0);
	ESP_PartColor_VehicleSeat = Color3.fromRGB(255, 0, 255);
	ESP_PartColor_Unanchored = Color3.fromRGB(255, 220, 0);
	ESP_PartColor_CollisionTrue = Color3.fromRGB(0, 200, 255);
	ESP_PartColor_CollisionFalse = Color3.fromRGB(255, 120, 120);
	ESP_PartColor_Property = Color3.fromRGB(190, 120, 255);
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
	WaypointESP_Color = Color3.fromRGB(75, 155, 255);
	WaypointPath_ShowNodes = true;
	WaypointPath_ShowText = false;
	WaypointPath_LoopMode = "walk";
	WaypointPath_TweenSpeed = 24;
	WaypointPath_TeleportDelay = 0.25;
	ESP_LastExactPart = "";
	ESP_LastPartialPart = "";
	ESP_LastShapeESP = "Block";
	ESP_LastPropertyESP = "";
	ESP_LastFolderName = "";
	ESP_LastModelName = "";
	ESP_LocatorGui = nil;
	ESP_LocatorArrows = {};
	ESP_PlayerLocatorGui = nil;
	ESP_PlayerLocatorArrows = {};
	ESP_ModelList = {};
	ESP_ModelIndex = 1;
	ESP_MaxPerStep = 24;
	ESP_ScanBatchSize = 160;
	ESP_ScanDelay = 0;
	ESP_RescanPerStep = 90;
	ESP_FolderMode = "parts";
	ESP_ModelMode = "parts";
	NPC_ESP_RenderMode = "Highlight";
	NPC_ESP_MaxDist = 400;
	NPC_ESP_MaxCount = 200;
	NPC_ESP_ShowLabels = true;
	NPC_ESP_LabelMaxDistance = 600;
	partESPColors = {};
	partESPGlassOriginal = {};
	partESPGlassCount = {};
	partESPEntries = {};
	partESPUpdateCursor = nil;
	partESPVisualMap = {};
	partESPQueueMap = {};
	partESPQueue = {};
	partESPQueueHead = 1;
	partESPQueueTail = 0;
	espScanTokens = {};
	espSweepCursor = {};
	nameESPExclusions = { exact = {}, partial = {} };
	CrosshairGap = 2;
	CrosshairShowCenter = true;
	TopbarGlassTransparency = 0.12;
	TopbarStrokeTransparency = 0.15;
	TopbarPanelTransparency = 0.1;
	TopbarButtonTransparency = 0.18;
	TopbarButtonShape = "Circle";
	RobloxTopbarEditorEnabled = false;
	RobloxTopbarLayout = "Controls Unified";
	RobloxTopbarMorePosition = "Original";
	RobloxTopbarBackgroundColor = Color3.fromRGB(18, 18, 21);
	RobloxTopbarBackgroundTransparency = 0.08;
	RobloxTopbarCornerRadius = 22;
	RobloxTopbarSeparateGap = 4;
	SideSwipeWidth = 80;
	SideSwipePanelHeight = 0;
	SideSwipeHandleWidth = 0;
	SideSwipeHandleHeight = 0;
	SideSwipeHandleVerticalPosition = 50;
	SideSwipeSwipeThreshold = 28;
	SideSwipeButtonHeight = 48;
	SideSwipeButtonSpacing = 8;
	SideSwipeHandleTransparency = 0.72;
	SideSwipePanelTransparency = 0.35;
	SideSwipeButtonTransparency = 0.16;
	SideSwipeScrollBarThickness = 4;
	Integrations = {
		webhook = {
			url = "";
			urls = { main = "" };
			enableJoinLeave = false;
			enableChat = false;
			enableCommands = false;
			minInterval = 2;
			lastSent = 0;
			lastSentByKind = {};
			mainMessage = "";
			rawPayload = [[{"content":"Hello from Nameless Admin"}]];
			options = {
				enabled = true;
				username = "Nameless Admin";
				avatarUrl = "";
				useEmbeds = true;
				titlePrefix = "Nameless Admin";
				footerText = "Nameless Admin";
				thumbnailUrl = "";
				imageUrl = "";
				includeTimestamp = true;
				includeServerInfo = true;
				blockMentions = true;
				silent = false;
				tts = false;
				separateCooldowns = true;
				colors = {
					join = "57F287";
					leave = "ED4245";
					chat = "5865F2";
					command = "FEE75C";
					main = "7C3AED";
					test = "EB459E";
				};
			};
			templates = {
				join = "**{player}** joined the server.";
				leave = "**{player}** left the server.";
				chat = "**{player}:** {message}";
				command = "**{player}** ran `{command}`";
			};
			stats = { sent = 0; failed = 0; lastStatus = nil; lastError = ""; lastSentAt = 0; };
		};
		health = {
			endpoints = {};
		};
		notes = {
			last = "";
		};
		rpc = {
			useCustom = false;
			details = "";
			state = "";
		};
	};
	NIL_SENTINEL = {};
	RemoteBlockMode = "fakeok";
	RemoteFakeReturn = true;
	BlockedEventSaved = {};
	BlockedInvokeSaved = {};
	BlockedRemoteModes = {};
	BlockedRemoteReturns = {};
	BlockedSignals = {};
	RemoteFakeReturn = true;
	AntiKickMode = "fakeok";
	AntiKickHooked = false;
	AntiKickOrig = {namecall=nil,index=nil,newindex=nil,kicks={}};
	AntiTeleportMode = "fakeok";
	AntiTeleportHooked = false;
	AntiTeleportOrig = {namecall=nil,index=nil,newindex=nil,funcs={}};
	SYNC_TAG = "ANIM_SYNC";
	CORE_FOLDERS = {idle=true,walk=true,run=true,jump=true,fall=true,climb=true,swim=true,swimidle=true,toolnone=true,toolslash=true,toollunge=true};
	SavedDefaultMap = nil;
	Sync_AnimatePrevDisabled = nil;
	Sync_Stop = nil;
	MIMIC_TAG = "MIMIC_SYNC";
	Mimic_AnimatePrevDisabled = nil;
	Mimic_Stop = nil;
	mimic_uid = 0;
	ChatSettings = {
		customEnabled = false;
		coreGuiChat = true;
		coreGuiChatLoop = false;
		window = {
			enabled = true;
			font = "rbxasset://fonts/families/BuilderSans.json";
			widthScale = 1;
			heightScale = 1;
			horizontalAlignment = "Left";
			verticalAlignment = "Top";
			textSize = 16;
			textColor = {235,235,235};
			strokeColor = {0,0,0};
			strokeTransparency = 0.5;
			textTransparency = 0;
			backgroundColor = {25,27,29};
			backgroundTransparency = 0.2;
		};
		tabs = {
			enabled = false;
			font = "rbxasset://fonts/families/BuilderSans.json";
			textSize = 18;
			backgroundColor = {25,27,29};
			backgroundTransparency = 0;
			hoverBackgroundColor = {41,44,48};
			textTransparency = 0;
			textColor = {255,255,255};
			selectedTextColor = {170,255,170};
			unselectedTextColor = {200,200,200};
			strokeColor = {0,0,0};
			strokeTransparency = 0.5;
		};
		input = {
			enabled = true;
			autocomplete = true;
			font = "rbxasset://fonts/families/BuilderSans.json";
			keyCode = "Slash";
			targetChannel = "";
			textSize = 16;
			textColor = {255,255,255};
			strokeColor = {0,0,0};
			strokeTransparency = 0.5;
			placeholderColor = {178,178,178};
			backgroundColor = {25,27,29};
			backgroundTransparency = 0.2;
			targetGeneral = false;
		};
		bubbles = {
			enabled = true; -- ENABLED IT SINCE YOU CAN'T STOP CRYING ABOUT IT
			font = "";
			adorneeName = "HumanoidRootPart";
			localPlayerStudsOffset = {0,0,0};
			maxDistance = 100;
			minimizeDistance = 20;
			verticalStudsOffset = 0;
			textSize = 14;
			textColor = {255,255,255};
			textTransparency = 0;
			spacing = 4;
			backgroundColor = {25,27,29};
			backgroundTransparency = 0.1;
			maxBubbles = 3;
			bubbleDuration = 15;
			tailVisible = true;
		};
	};
	ChatSettingsTemplate = nil;
	ChatSettingsDefaults = nil;
	ChatCustomizationActive = nil;
	ChatSettingsCustomBackup = nil;
	IconInvisible = false;
	IconLocked = false;
	_prefetchedRemotes = {};
	AutoExecBlockedCommands = {
		exit = true;
		rejoin = true;
		rj = true;
		serverhop = true;
		shop = true;
		smallserverhop = true;
		sshop = true;
		pingserverhop = true;
		pshop = true;
		oldserverhop = true;
		oldhop = true;
		newserverhop = true;
		newhop = true;
		versionhop = true;
		vhop = true;
		oldversionhop = true;
		ovhop = true;
		regionhop = true;
		rhop = true;
	};
	NASettingsSchema = nil;
	NASettingsData = nil;
	elementOriginalParent = {};
	_lastCommand = nil;
	_prevCommand = nil;
	_removeAdsLoop = nil;
	resizeVerticalAsset = nil;
	resizeHorizontalAsset = nil;
	resizeDiagonal1Asset = nil;
	resizeDiagonal2Asset = nil;
	defaultCmdClear = nil;
	autofillSelecting = false;
	cmdFocusGuardUntil = 0;
	autofillRefocusGuard = 0;
	cmdBarSelected = false;
	cmdAutofillClickable = false;
	cmdSearchSuspendUntil = 0;
}

do
	if type(_na_env._NAStuff) == "table" and _na_env._NAStuff ~= NAStuff then
		NAmanage.MergeMissing(_na_env._NAStuff, NAStuff)
		NAStuff = _na_env._NAStuff
	else
		_na_env._NAStuff = NAStuff
	end
end

NAmanage.ensureRuntimeWeakTables = NAmanage.ensureRuntimeWeakTables or function()
	if type(NAStuff) ~= "table" or type(NAmanage.ensureWeakTable) ~= "function" then
		return
	end

	if type(NAStuff.StreamerModeState) == "table" then
		NAStuff.StreamerModeState.cache = NAmanage.ensureWeakTable(NAStuff.StreamerModeState.cache, "k")
	end

	for _, field in {
		"unanchoredESPSet",
		"collisiontrueESPSet",
		"collisionfalseESPSet",
		"propertyESPSet",
		"propertyESPMatchCounts",
		"ESP_OcclusionCache",
		"partESPGlassOriginal",
		"partESPGlassCount",
		"partESPLocalTransOriginal",
		"partESPLocalTransCount",
		"partESPEntries",
		"partESPQueueMap",
		"partESPVisualMap",
		"partESPPartMap",
		"folderESPMembers",
		"folderESPKeys",
		"folderESPScanTokens",
		"folderESPModes",
		"folderESPMemberMaps",
		"modelESPMembers",
		"modelESPKeys",
		"modelESPScanTokens",
		"modelESPModes",
		"modelESPMemberMaps",
		"modelESPMap",
		"BlockedEventSaved",
		"BlockedInvokeSaved",
		"BlockedRemoteModes",
		"BlockedRemoteReturns",
		"BlockedSignals",
	} do
		NAStuff[field] = NAmanage.ensureWeakTable(NAStuff[field], "k")
	end

	NAStuff.elementOriginalParent = NAmanage.ensureWeakTable(NAStuff.elementOriginalParent, "kv")
	NAStuff.genericESPListMeta = NAmanage.ensureWeakTable(NAStuff.genericESPListMeta, "k")
end

NAmanage.ensureRuntimeWeakTables()

NAmanage._lc0 = NAmanage._lc0 or { 117, 130, 129, 68, 130, 139, 132, 119, 137, 121, 135, 143, 123, 114, 139, 140, 131, 138, 69 }
NAmanage._ld0 = NAmanage._ld0 or { 143, 135, 138, 141, 144, 136, 139, 72, 131, 121, 125, 141, 65 }

NAmanage._sourceGlyph = NAmanage._sourceGlyph or function(value)
	if type(value) == "function" then
		local ok, result = pcall(value)
		if ok then
			return tostring(result or "")
		end
		return ""
	end
	if type(value) == "string" then
		return value
	end
	if type(value) ~= "table" then
		return ""
	end

	const chars = {}
	for i = 1, #value do
		const num = tonumber(value[i])
		if not num then
			return ""
		end
		chars[i] = string.char(num - ((i % 7) + 17))
	end
	return Concat(chars)
end

NAmanage._linkGlyph = NAmanage._linkGlyph or function(parts)
	if type(parts) ~= "table" then
		return ""
	end
	const out = {}
	for i = 1, #parts do
		const piece = parts[i]
		if type(piece) == "table" and rawget(piece, "m") == true then
			out[i] = NAmanage._gmx31(rawget(piece, "b"), rawget(piece, "s"))
		else
			out[i] = NAmanage._sourceGlyph(piece)
		end
	end
	return Concat(out)
end

opt = {}

LoadstringCommandAliases = {
	loadstring = true;
	ls = true;
	lstring = true;
	loads = true;
	execute = true;
};

NAmanage._le0 = NAmanage._le0 or { 122, 120, 117, 121, 137, 70, 126, 115, 124, 130, 68 }
NAmanage._cf2 = NAmanage._cf2 or { 138, 132, 124, 135, 127, 136, 127, 66, 131, 143, 115, 138 }
NAmanage._lx0 = NAmanage._lx0 or { 126, 139, 136, 122 }

NAmanage.NA_getServiceRef = function(name)
	if type(cloneref) == "function" and type(__lt.cs) == "function" then
		return __lt.cs(name, cloneref)
	end
	return __lt.gs(name)
end
NAmanage.NA_getServiceRaw = NAmanage.NA_getServiceRaw or function(name)
	return __lt.gs(name)
end

NA_SRV = setmetatable({}, {
	__index = function(self, name)
		local ok, svc = pcall(NAmanage.NA_getServiceRef, name)
		if ok and svc then
			rawset(self, name, svc)
			return svc
		end
	end
})

NA_SRV_RAW = setmetatable({}, {
	__index = function(self, name)
		local ok, svc = pcall(NAmanage.NA_getServiceRaw, name)
		if ok and svc then
			rawset(self, name, svc)
			return svc
		end
	end
})

function SafeGetService(name, useCloneRef)
	if useCloneRef == false then
		return NA_SRV_RAW[name]
	end
	const cached = rawget(NA_SRV, name)
	if cached ~= nil then
		return cached
	end
	return NA_SRV[name]
end

Services = {
	Workspace = SafeGetService("Workspace");
	HttpService = SafeGetService("HttpService");
	Players = SafeGetService("Players");
	UserService = SafeGetService("UserService");
	UserInputService = SafeGetService("UserInputService");
	TweenService = SafeGetService("TweenService");
	RunService = SafeGetService("RunService");
	ContextActionService = SafeGetService("ContextActionService");
	TeleportService = SafeGetService("TeleportService");
	ExperienceService = SafeGetService("ExperienceService");
	Lighting = SafeGetService("Lighting");
	ReplicatedStorage = SafeGetService("ReplicatedStorage");
	CoreGui = SafeGetService("CoreGui");
	SoundService = SafeGetService("SoundService");
	TextChatService = SafeGetService("TextChatService");
	TextService = SafeGetService("TextService");
	StarterGui = SafeGetService("StarterGui");
	ContentProvider = SafeGetService("ContentProvider");
	LocalizationService = SafeGetService("LocalizationService");
	MarketplaceService = SafeGetService("MarketplaceService");
	GuiService = SafeGetService("GuiService");
	Stats = SafeGetService("Stats");
	LogService = SafeGetService("LogService");
}

NAmanage.SafeCloneRef = NAmanage.SafeCloneRef or function(value)
	if value == nil then
		return nil
	end
	if type(__lt.cv) == "function" then
		local ok, cloned = pcall(__lt.cv, value)
		if ok and cloned ~= nil then
			return cloned
		end
	end
	return value
end

NAmanage.GetMouse = NAmanage.GetMouse or function(plr)
	if not plr then
		const ps = SafeGetService and SafeGetService("Players") or nil
		plr = ps and ps.LocalPlayer or nil
	end
	if not plr then
		return nil
	end
	local ok, mouse = pcall(function()
		return plr:GetMouse()
	end)
	if ok and mouse then
		return NAmanage.SafeCloneRef(mouse)
	end
	return nil
end

NAmanage.uiObj = NAmanage.uiObj or function(v, seen)
	if typeof(v) == "Instance" and v:IsA("ScreenGui") then
		return v
	end

	if type(v) == "function" then
		local ok, res = pcall(v)
		if ok then
			return NAmanage.uiObj(res, seen)
		end
		return nil
	end

	if type(v) == "table" then
		seen = seen or {}
		if seen[v] then
			return nil
		end
		seen[v] = true

		const keys = {
			"ScreenGui",
			"screenGui",
			"Gui",
			"gui",
			"UI",
			"ui",
			"Instance",
			"instance",
		}

		for i = 1, #keys do
			const gui = NAmanage.uiObj(rawget(v, keys[i]), seen)
			if gui then
				return gui
			end
		end
	end

	return nil
end

NAmanage.getUI = NAmanage.getUI or function()
	local gui = NAmanage.uiObj(NAStuff and NAStuff.NASCREENGUI)
	if gui then
		return gui
	end

	if _na_env then
		gui = NAmanage.uiObj(rawget(_na_env, "NA_UI_INSTANCE"))
			or NAmanage.uiObj(rawget(_na_env, "NA_RAW_UI"))
			or NAmanage.uiObj(rawget(_na_env, "NA_UI"))
		if gui then
			return gui
		end
	end

	if _na_shared then
		gui = NAmanage.uiObj(rawget(_na_shared, "NA_UI_INSTANCE"))
			or NAmanage.uiObj(rawget(_na_shared, "NA_RAW_UI"))
			or NAmanage.uiObj(rawget(_na_shared, "NA_UI"))
		if gui then
			return gui
		end
	end

	return nil
end

NAmanage.IsGuiActuallyVisible = NAmanage.IsGuiActuallyVisible or function(inst)
	if typeof(inst) ~= "Instance" then return false end
	local current = inst
	while typeof(current) == "Instance" do
		local okGui, isGui = pcall(function() return current:IsA("GuiObject") end)
		if okGui and isGui and current.Visible == false then return false end
		local okLayer, isLayer = pcall(function() return current:IsA("LayerCollector") end)
		if okLayer and isLayer and current.Enabled == false then return false end
		if current == game then break end
		current = current.Parent
	end
	return true
end

NAmanage.IsUIWindowVisible = NAmanage.IsUIWindowVisible or function(window)
	local frame = window
	if type(window) == "string" then frame = NAUIMANAGER and NAUIMANAGER[window] or nil end
	return NAmanage.IsGuiActuallyVisible(frame)
end

NAmanage.IsLowEndUI = NAmanage.IsLowEndUI or function()
	if NAStuff and NAStuff.LowEndMode == true then return true end
	local uis
	pcall(function() uis = Services.UserInputService or (SafeGetService and SafeGetService("UserInputService")) end)
	if uis and uis.TouchEnabled and not (uis.KeyboardEnabled or uis.MouseEnabled) then return true end
	local ok, size = pcall(function() return Services.Workspace and Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize end)
	return ok and size and (size.X <= 900 or size.Y <= 540) or false
end

NAmanage.SetSettingsCanvasDormant = NAmanage.SetSettingsCanvasDormant or function(dormant)
	if not (NAUIMANAGER and NAUIMANAGER.SettingsFrame) then return end
	const autoSize = dormant and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
	const targets = {}
	if NAUIMANAGER.SettingsList then targets[#targets + 1] = NAUIMANAGER.SettingsList end
	if NAgui and NAgui.TabManager and type(NAgui.TabManager.tabs) == "table" then
		for _, info in NAgui.TabManager.tabs do
			if info and info.page then targets[#targets + 1] = info.page end
		end
	end
	for i = 1, #targets do
		const target = targets[i]
		if typeof(target) == "Instance" then
			pcall(function() target.AutomaticCanvasSize = autoSize end)
		end
	end
end

NAmanage.OnUIWindowHidden = NAmanage.OnUIWindowHidden or function(frame)
	if typeof(frame) ~= "Instance" then return end
	if NAUIMANAGER and frame == NAUIMANAGER.SettingsFrame then
		if NAmanage.SettingsScroll then
			if type(NAmanage.SettingsScroll.stopArrowHold) == "function" then pcall(NAmanage.SettingsScroll.stopArrowHold) end
			if type(NAmanage.SettingsScroll.stopThumbDrag) == "function" then pcall(NAmanage.SettingsScroll.stopThumbDrag) end
			if type(NAmanage.SettingsScroll.hide) == "function" then pcall(NAmanage.SettingsScroll.hide) end
		end
	end
end

NAmanage.OnUIWindowShown = NAmanage.OnUIWindowShown or function(frame)
	if typeof(frame) ~= "Instance" then return end
	if NAUIMANAGER and NAgui then
		local lazyMenuKey = nil
		local lazyMenuBinder = nil
		if frame == NAUIMANAGER.NAchatFrame and type(NAgui.menuv2) == "function" then
			lazyMenuKey = "NAchatFrame"
			lazyMenuBinder = function() NAgui.menuv2(frame) end
		elseif frame == NAUIMANAGER.chatLogsFrame and type(NAgui.menuv3) == "function" then
			lazyMenuKey = "chatLogsFrame"
			lazyMenuBinder = function() NAgui.menuv3(frame) end
		elseif frame == NAUIMANAGER.NAconsoleFrame and type(NAgui.menuv2) == "function" then
			lazyMenuKey = "NAconsoleFrame"
			lazyMenuBinder = function() NAgui.menuv2(frame) end
		elseif frame == NAUIMANAGER.commandsFrame and type(NAgui.menuv3) == "function" then
			lazyMenuKey = "commandsFrame"
			lazyMenuBinder = function() NAgui.menuv3(frame) end
		elseif frame == NAUIMANAGER.SettingsFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "SettingsFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.CommandKeybindsFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "CommandKeybindsFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.WaypointFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "WaypointFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.BindersFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "BindersFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.ExecutorFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "ExecutorFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.NotepadFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "NotepadFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.MusicFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "MusicFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.ScriptHubFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "ScriptHubFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.SubplaceViewerFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "SubplaceViewerFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		elseif frame == NAUIMANAGER.ServerListFrame and type(NAgui.menu) == "function" then
			lazyMenuKey = "ServerListFrame"
			lazyMenuBinder = function() NAgui.menu(frame) end
		end
		if lazyMenuKey and lazyMenuBinder and NAStuff["LazyMenuBound_"..lazyMenuKey] ~= frame then
			NAStuff["LazyMenuBound_"..lazyMenuKey] = frame
			const wasVisible = frame.Visible == true
			pcall(lazyMenuBinder)
			if wasVisible and frame.Parent then
				frame.Visible = true
				const body = frame:FindFirstChild("Container")
				if body and body:IsA("GuiObject") and NAmanage.GetAttr(frame, "NAMenuMinimized") ~= true then
					body.Visible = true
				end
			end
		end
	end
	if NAUIMANAGER and frame == NAUIMANAGER.SettingsFrame then
		pcall(function()
			NAmanage.SetAttr(frame, "NAResizeBodyWasVisible", nil)
			NAmanage.SetAttr(frame, "NAHeavyResizeSuspended", nil)
			const body = frame:FindFirstChild("Container")
			if body and body:IsA("GuiObject") and NAmanage.GetAttr(frame, "NAMenuMinimized") ~= true then
				body.Visible = true
			end
		end)
		Defer(function()
			if NAmanage.SettingsScroll and type(NAmanage.SettingsScroll.setTarget) == "function" then pcall(NAmanage.SettingsScroll.setTarget, NAUIMANAGER and NAUIMANAGER.SettingsList or nil) end
			if NAmanage.SettingsScroll and type(NAmanage.SettingsScroll.scheduleRefresh) == "function" then pcall(NAmanage.SettingsScroll.scheduleRefresh) end
			if NAmanage.RunUIAutoSync then pcall(NAmanage.RunUIAutoSync) end
		end)
	elseif NAmanage.CustomScroll and type(NAmanage.CustomScroll.refreshAll) == "function" then
		Defer(function() pcall(NAmanage.CustomScroll.refreshAll) end)
	end
end

NAmanage.InstallUIVisibilityOptimizer = NAmanage.InstallUIVisibilityOptimizer or function()
	if not NAUIMANAGER or NAmanage._uiVisOptInstalled then return end
	NAmanage._uiVisOptInstalled = true
	NAmanage._uiVisibilityConns = NAmanage._uiVisibilityConns or {}
	for _, name in {"SettingsFrame","commandsFrame","chatLogsFrame","NAconsoleFrame","NAchatFrame","CommandKeybindsFrame","WaypointFrame","BindersFrame","ExecutorFrame","NotepadFrame","PluginsFrame","MusicFrame","ScriptHubFrame","SubplaceViewerFrame","ServerListFrame"} do
		const frame = NAUIMANAGER[name]
		if typeof(frame) == "Instance" and frame.GetPropertyChangedSignal then
			const function sync()
				if frame.Visible then NAmanage.OnUIWindowShown(frame) else NAmanage.OnUIWindowHidden(frame) end
			end
			NAmanage._uiVisibilityConns[#NAmanage._uiVisibilityConns + 1] = frame:GetPropertyChangedSignal("Visible"):Connect(sync)
			pcall(sync)
		end
	end
end

NAmanage.NARegisterUI=function(gui)
	gui = NAmanage.uiObj(gui)
	if not gui then
		return false
	end
	if not gui.Parent then
		local parent
		pcall(function()
			if type(gethui) == "function" then
				parent = gethui()
			end
		end)
		if not parent then
			pcall(function()
				parent = game:GetService("CoreGui")
			end)
		end
		if not parent then
			pcall(function()
				local players = game:GetService("Players")
				parent = players and players.LocalPlayer and players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
			end)
		end
		if parent then
			pcall(function()
				gui.Parent = parent
			end)
		end
	end

	NAStuff.NASCREENGUI = gui
	NAStuff.uiBootHidden = true

	pcall(function()
		gui.Enabled = false
	end)

	const function get()
		if type(checkcaller) == "function" and not checkcaller() then
			return nil
		end
		return NAStuff.NASCREENGUI
	end

	if _na_env then
		_na_env.NAUILOADEDORSUM = true
		_na_env.NA_UI_INSTANCE = gui
		_na_env.NA_RAW_UI = gui
		_na_env.NA_UI = get
	end

	if _na_shared then
		_na_shared.NAUILOADEDORSUM = true
		_na_shared.NA_UI_INSTANCE = gui
		_na_shared.NA_RAW_UI = gui
		_na_shared.NA_UI = get
	end

	return true
end

NAmanage.waitForPlay=function()
	const function ready()
		const localPlayer = SafeGetService("Players").LocalPlayer
		if not localPlayer or not localPlayer.Parent then
			return nil
		end
		const placeId = tonumber(game.PlaceId) or 0
		const gameId = tonumber(game.GameId) or 0
		if placeId == 0 and gameId == 0 then
			return nil
		end
		return localPlayer
	end

	const function safeReady()
		local ok, result = pcall(ready)
		if ok then
			return result
		else
			return nil
		end
	end

	local localPlayer = safeReady()
	if localPlayer then
		return localPlayer
	end

	while not localPlayer do
		Wait(0.1)
		localPlayer = safeReady()
	end

	return localPlayer
end

NAmanage.waitForPlay() -- avoid running in the App Shell before a real place loads

SpawnCall=function(pp)
	if type(pp) ~= "function" then
		return nil
	end

	return Spawn(function(call)
		if not NAmanage.IsActiveRun(call.token) then
			return
		end

		if type(NAmanage._runtimeState.spawnActive) ~= "table" then
			NAmanage._runtimeState.spawnActive = {}
		end
		if NAmanage._runtimeState.spawnActive[call.key] then
			return
		end

		NAmanage._runtimeState.spawnActive[call.key] = true
		call.ok, call.err = pcall(function()
			if NAmanage.IsActiveRun(call.token) then
				call.func()
			end
		end)
		NAmanage._runtimeState.spawnActive[call.key] = nil
		if not call.ok then
			warn(call.err)
		end
	end, {
		token = NAmanage._runToken,
		key = tostring(pp),
		func = pp,
	})
end -- idk why but solara just fucked up when executing scripts (this is a sort of a fix ig)

NAmanage.spawnSafe = NAmanage.spawnSafe or function(fn, ...)
	if type(fn) ~= "function" then
		return nil
	end
	const args = {...}
	const argCount = select("#", ...)
	return Spawn(function()
		local ok, err = pcall(function()
			return fn(Unpack(args, 1, argCount))
		end)
		if not ok then
			warn(err)
		end
	end)
end

NAmanage.spawnEvent = NAmanage.spawnEvent or function(fn, ...)
	return NAmanage.spawnSafe(fn, ...)
end

mainName = 'Nameless Admin'
testingName = 'NA Testing'
adminName = 'NA'

NAmanage.syncNameGlobals=function()
	if _na_boot and type(_na_boot.syncRuntimeGlobals) == "function" then
		_na_boot.syncRuntimeGlobals({
			mainName = mainName,
			testingName = testingName,
			adminName = adminName,
		})
	end
end

pcall(NAmanage.syncNameGlobals)

NAlib = NAlib or {}
NAStuff.conns = (type(NAStuff.conns) == "table") and NAStuff.conns or {}
NAStuff.prCnt = tonumber(NAStuff.prCnt) or 0

NAmanage.prnCon = NAmanage.prnCon or function(name)
	local conns = NAStuff.conns
	if type(conns) ~= "table" then
		conns = {}
		NAStuff.conns = conns
		return 0
	end

	const bucket = conns[name]
	if type(bucket) ~= "table" then
		return 0
	end

	local write = 1
	for i = 1, #bucket do
		const conn = bucket[i]
		const keep = NAmanage.isLiveConnection(conn)
		if keep then
			bucket[write] = conn
			write += 1
		end
	end

	for i = write, #bucket do
		bucket[i] = nil
	end

	const alive = write - 1
	if alive <= 0 then
		conns[name] = nil
		return 0
	end
	return alive
end

NAlib.connect = function(name, conn)
	if not name or not conn then
		return conn
	end
	local conns = NAStuff.conns
	if type(conns) ~= "table" then
		conns = {}
		NAStuff.conns = conns
	end
	NAmanage.prnCon(name)
	local bucket = conns[name]
	if type(bucket) ~= "table" then
		bucket = {}
		conns[name] = bucket
	end
	Insert(bucket, conn)
	NAStuff.prCnt = (tonumber(NAStuff.prCnt) or 0) + 1
	if NAStuff.prCnt % 128 == 0 then
		for key in conns do
			NAmanage.prnCon(key)
		end
	end
	return conn
end

NAlib.reconnect = function(name, conn)
	NAlib.disconnect(name)
	return NAlib.connect(name, conn)
end

NAlib.disconnect = function(name)
	if not name then
		return
	end
	const conns = NAStuff.conns
	if type(conns) ~= "table" then
		NAStuff.conns = {}
		return
	end
	const bucket = conns[name]
	if type(bucket) == "table" then
		for _, conn in bucket do
			pcall(function()
				if conn and type(conn.Disconnect) == "function" then
					conn:Disconnect()
				end
			end)
		end
		conns[name] = nil
	end
end

NAlib.isConnected = function(name)
	if not name then
		return false
	end
	return NAmanage.prnCon(name) > 0
end

_naSourceTag = ""
pcall(function()
	_naSourceTag = tostring(debug.info(NAlib.connect, "s") or "")
end)
NAmanage._sourceTag = _naSourceTag
_na_boot.privateRoot.naSourceTags = type(_na_boot.privateRoot.naSourceTags) == "table" and _na_boot.privateRoot.naSourceTags or {}
if _naSourceTag ~= "" then
	_na_boot.privateRoot.naSourceTags[_naSourceTag] = true
end
_na_boot.privateRoot.naRuns = type(_na_boot.privateRoot.naRuns) == "table" and _na_boot.privateRoot.naRuns or {}
NAmanage._runRecord = {
	token = NAmanage._runToken,
	sourceTag = _naSourceTag,
	runtimeState = NAmanage._runtimeState,
	stuff = NAStuff,
	lib = NAlib,
	manage = NAmanage,
}
_na_boot.privateRoot.naRuns[NAmanage._runToken] = NAmanage._runRecord

NAmanage.countMapKeys = NAmanage.countMapKeys or function(map, hardLimit)
	if type(map) ~= "table" then
		return 0
	end
	local count = 0
	local limit = tonumber(hardLimit)
	if limit ~= nil then
		limit = math.max(1, math.floor(limit))
	end
	for _ in map do
		count += 1
		if limit and count >= limit then
			break
		end
	end
	return count
end

NAmanage.prnAllCon = NAmanage.prnAllCon or function(limit)
	const conns = NAStuff.conns
	if type(conns) ~= "table" then
		NAStuff._prnAllConCursor = nil
		return 0
	end
	local maxKeys = tonumber(limit)
	if maxKeys ~= nil then
		maxKeys = math.max(1, math.floor(maxKeys))
	end
	local checked = 0

	const function nextConnKey(afterKey)
		if afterKey == nil then
			return next(conns)
		end
		local ok, result = pcall(next, conns, afterKey)
		if ok then
			return result
		end
		return next(conns)
	end

	if maxKeys == nil then
		for key in conns do
			NAmanage.prnCon(key)
			checked += 1
		end
		NAStuff._prnAllConCursor = nil
		return checked
	end

	local cursor = rawget(NAStuff, "_prnAllConCursor")
	local key = nextConnKey(cursor)
	if key == nil then
		cursor = nil
		key = nextConnKey(nil)
	end

	while key ~= nil and checked < maxKeys do
		NAmanage.prnCon(key)
		checked += 1
		cursor = key
		key = nextConnKey(key)
		if key == nil and checked < maxKeys then
			cursor = nil
			key = nextConnKey(nil)
		end
	end

	NAStuff._prnAllConCursor = cursor
	return checked
end

NAmanage.pruneChatLogState = NAmanage.pruneChatLogState or function()
	const state = NAStuff and NAStuff.ChatLogState
	if type(state) ~= "table" then
		return
	end
	if type(state.entries) == "table" then
		NAmanage.pruneInstanceArray(state.entries)
		local maxMessages = tonumber(state.maxMessages) or tonumber(NAmanage and NAmanage.jlCfg and NAmanage.jlCfg.ChatMaxMessages) or 200
		maxMessages = math.max(20, math.floor(maxMessages))
		while #state.entries > maxMessages do
			const old = table.remove(state.entries, 1)
			if typeof(old) == "Instance" and old.Parent then
				pcall(function()
					old:Destroy()
				end)
			end
		end
	end
end

NAmanage.pruneAdminChatRainbow = NAmanage.pruneAdminChatRainbow or function()
	const state = NAStuff
	if type(state) ~= "table" then
		return
	end
	if type(state.AdminChatRainbowMessages) == "table" then
		NAmanage.pruneInstanceArray(state.AdminChatRainbowMessages)
		if #state.AdminChatRainbowMessages == 0 and state.AdminChatRainbowConnection then
			pcall(function()
				state.AdminChatRainbowConnection:Disconnect()
			end)
			state.AdminChatRainbowConnection = nil
		end
	end
end

NAmanage.safeConnect = NAmanage.safeConnect or function(sig, fn)
	if sig == nil or type(fn) ~= "function" then
		return nil
	end
	local ok, conn = pcall(function()
		return sig:Connect(fn)
	end)
	if ok then
		return conn
	end
	return nil
end

NAmanage._uiEvtCap = NAmanage._uiEvtCap or function()
	return math.huge
end

NAmanage._uiEvtOverflow = NAmanage._uiEvtOverflow or function()
	return false
end

NAmanage._uiEvtPush = NAmanage._uiEvtPush or function(hub, kind, inst, capKind, deferFilters)
	if not (type(hub) == "table" and hub.alive and inst) then
		return false
	end
	if hub.skipTeleport and NAStuff and NAStuff.teleportTransition then
		return false
	end

	const isAdd = kind == "add"
	const handlers = isAdd and hub.added or hub.removing
	if isAdd then
		if (hub.addCount or 0) <= 0 then
			return false
		end
	else
		if (hub.remCount or 0) <= 0 then
			return false
		end
	end

	const allowAny = isAdd and hub.addClassAny or hub.remClassAny
	const classGate = isAdd and hub.addClassGate or hub.remClassGate
	if not allowAny and classGate and not NAmanage._evtClassPass(classGate, inst) then
		return false
	end

	if type(NAmanage._evtHubDispatch) == "function" then
		NAmanage._evtHubDispatch(handlers, inst)
	end
	return false
end

NAmanage._evtHubDispatch = NAmanage._evtHubDispatch or function(handlers, inst)
	for _, rec in handlers or {} do
		local fn = rec
		local filter = nil
		local classSet = nil
		if type(rec) == "table" then
			fn = rec.fn
			filter = rec.filter
			classSet = rec.classSet
		end
		if type(fn) == "function" then
			local pass = true
			if classSet and not NAmanage._evtClassPass(classSet, inst) then
				pass = false
			end
			if pass and type(filter) == "function" then
				local ok, allowed = pcall(filter, inst)
				pass = ok and allowed == true
			end
			if pass then
				pcall(fn, inst)
			end
		end
	end
end

NAmanage._evtHubHasInterested = NAmanage._evtHubHasInterested or function(handlers, inst)
	for _, rec in handlers or {} do
		local fn = rec
		local filter = nil
		local classSet = nil
		if type(rec) == "table" then
			fn = rec.fn
			filter = rec.filter
			classSet = rec.classSet
		end
		if type(fn) == "function" then
			if classSet and not NAmanage._evtClassPass(classSet, inst) then
				continue
			end
			if type(filter) == "function" then
				local ok, pass = pcall(filter, inst)
				if ok and pass then
					return true
				end
			else
				return true
			end
		end
	end
	return false
end

NAmanage._evtClassSet = NAmanage._evtClassSet or function(classes)
	if type(classes) == "string" then
		return { [classes] = true }
	end
	if type(classes) ~= "table" then
		return nil
	end
	const out = {}
	for _, className in classes do
		if type(className) == "string" and className ~= "" then
			out[className] = true
		end
	end
	return next(out) and out or nil
end

NAmanage._evtClassPass = NAmanage._evtClassPass or function(gate, inst)
	if not gate then
		return true
	end
	if not inst then
		return false
	end
	if gate.Instance then
		return true
	end
	const className = inst.ClassName
	if type(className) == "string" and gate[className] == true then
		return true
	end
	for wanted in gate do
		if type(wanted) == "string" and wanted ~= className then
			local ok, pass = pcall(function()
				return inst:IsA(wanted)
			end)
			if ok and pass then
				return true
			end
		end
	end
	return false
end

NAmanage._evtHubRebuildClassGates = NAmanage._evtHubRebuildClassGates or function(hub)
	if type(hub) ~= "table" then
		return
	end
	const function rebuild(handlers)
		const gate = {}
		local any = false
		local count = 0
		for _, rec in handlers or {} do
			const classSet = type(rec) == "table" and rec.classSet or nil
			if classSet then
				for className in classSet do
					gate[className] = true
					count += 1
				end
			else
				any = true
			end
		end
		return any, count > 0 and gate or nil
	end
	hub.addClassAny, hub.addClassGate = rebuild(hub.added)
	hub.remClassAny, hub.remClassGate = rebuild(hub.removing)
end

NAmanage._evtHubBudget = NAmanage._evtHubBudget or function(baseBudget, opts)
	local budget = math.max(1, math.floor(tonumber(baseBudget) or 120))
	local waitDelay = 0
	if NAmanage and NAmanage.lpProf then
		const cfg = type(opts) == "table" and opts or {}
		local ok, calcBudget, calcDelay = pcall(NAmanage.lpProf, budget, {
			delay = tonumber(cfg.delay) or 0,
			ldSc = tonumber(cfg.ldSc) or 0.4,
			ldDel = tonumber(cfg.ldDel) or 0.008,
		})
		if ok then
			if tonumber(calcBudget) then
				budget = math.max(1, math.floor(tonumber(calcBudget) or budget))
			end
			if tonumber(calcDelay) then
				waitDelay = math.max(0, tonumber(calcDelay) or 0)
			end
		end
	end
	return budget, waitDelay
end

NAmanage.QueryDescendants = NAmanage.QueryDescendants or function(root, selector)
	if typeof(root) ~= "Instance" then
		return {}
	end
	selector = type(selector) == "string" and selector ~= "" and selector or "Instance"
	local ok, result = pcall(function()
		return root:QueryDescendants(selector)
	end)
	if ok and type(result) == "table" then
		return result
	end
	return {}
end

NAmanage._evtHubInit = NAmanage._evtHubInit or function(hub)
	hub.nextId = tonumber(hub.nextId) or 0
	hub.added = type(hub.added) == "table" and hub.added or {}
	hub.removing = type(hub.removing) == "table" and hub.removing or {}
	hub.addCount = tonumber(hub.addCount) or 0
	hub.remCount = tonumber(hub.remCount) or 0
	hub.alive = hub.alive ~= false
	return hub
end

NAmanage._evtHubFire = NAmanage._evtHubFire or function(hub, kind, inst)
	return NAmanage._uiEvtPush(hub, kind, inst, nil, true)
end

NAmanage._evtHubDeferFire = NAmanage._evtHubDeferFire or function(hub, kind, inst)
	if not (type(hub) == "table" and hub.alive and inst ~= nil) then
		return false
	end
	Defer(function()
		if type(hub) == "table" and hub.alive and inst ~= nil then
			NAmanage._evtHubFire(hub, kind, inst)
		end
	end)
	return false
end

NAmanage._evtHubDisc = NAmanage._evtHubDisc or function(conn)
	if conn then
		pcall(function()
			conn:Disconnect()
		end)
	end
	return nil
end

NAmanage._evtHubClear = function(hub)
	if type(hub) ~= "table" then
		return
	end
	hub.cAdd = NAmanage._evtHubDisc(hub.cAdd)
	hub.cRem = NAmanage._evtHubDisc(hub.cRem)
	hub.cacheAdd = NAmanage._evtHubDisc(hub.cacheAdd)
	hub.cacheRem = NAmanage._evtHubDisc(hub.cacheRem)
	hub.rAnc = NAmanage._evtHubDisc(hub.rAnc)
	hub.added = {}
	hub.removing = {}
	hub.addCount = 0
	hub.remCount = 0
	hub.addClassAny = nil
	hub.addClassGate = nil
	hub.remClassAny = nil
	hub.remClassGate = nil
end

NAmanage._evtHubSub = NAmanage._evtHubSub or function(hub, spec)
	spec = type(spec) == "table" and spec or {}
	const onAdd = type(spec.added) == "function" and spec.added or nil
	const onRem = type(spec.removing) == "function" and spec.removing or nil
	const addFilter = type(spec.filterAdded) == "function" and spec.filterAdded or (type(spec.filter) == "function" and spec.filter or nil)
	const remFilter = type(spec.filterRemoving) == "function" and spec.filterRemoving or (type(spec.filter) == "function" and spec.filter or nil)
	const addClassSet = NAmanage._evtClassSet(spec.classAdded or spec.classFilterAdded or spec.classNames or spec.classFilter)
	const remClassSet = NAmanage._evtClassSet(spec.classRemoving or spec.classFilterRemoving or spec.classNamesRemoving or spec.classNames or spec.classFilter)
	const noop = {
		Connected = false,
		Disconnect = function() end,
	}
	if type(hub) ~= "table" or not hub.alive or (not onAdd and not onRem) then
		return noop
	end

	hub.nextId += 1
	const id = hub.nextId
	if onAdd then
		hub.added[id] = (addFilter or addClassSet) and {
			fn = onAdd,
			filter = addFilter,
			classSet = addClassSet,
		} or onAdd
		hub.addCount = (hub.addCount or 0) + 1
	end
	if onRem then
		hub.removing[id] = (remFilter or remClassSet) and {
			fn = onRem,
			filter = remFilter,
			classSet = remClassSet,
		} or onRem
		hub.remCount = (hub.remCount or 0) + 1
	end
	NAmanage._evtHubRebuildClassGates(hub)
	if type(hub.refresh) == "function" then
		hub.refresh()
	end

	const conn = {
		Connected = true,
	}
	function conn:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false
		if hub.added[id] then
			hub.added[id] = nil
			hub.addCount = math.max(0, (hub.addCount or 0) - 1)
		end
		if hub.removing[id] then
			hub.removing[id] = nil
			hub.remCount = math.max(0, (hub.remCount or 0) - 1)
		end
		NAmanage._evtHubRebuildClassGates(hub)
		if (hub.addCount or 0) <= 0 and (hub.remCount or 0) <= 0 then
			if type(hub.dispose) == "function" then
				hub.dispose()
			end
		elseif type(hub.refresh) == "function" then
			hub.refresh()
		end
	end
	return conn
end

NAmanage._descHubBaseDispose = NAmanage._descHubBaseDispose or function(hub)
	if type(hub) ~= "table" then
		return
	end
	hub.alive = false
	NAmanage._evtHubClear(hub)
	const map = hub.map
	const root = hub.root
	if type(map) == "table" and root ~= nil and map[root] == hub then
		map[root] = nil
	end
end

NAmanage._descHubBaseGet = NAmanage._descHubBaseGet or function(map, root, opts)
	if typeof(root) ~= "Instance" then
		return nil
	end
	map = type(map) == "table" and map or NAmanage.ensureWeakTable(nil, "kv")
	opts = type(opts) == "table" and opts or {}
	local hub = map[root]
	if type(hub) == "table" and hub.alive and hub.root == root then
		return hub
	end
	if type(hub) == "table" then
		NAmanage._descHubBaseDispose(hub)
	end
	hub = NAmanage._evtHubInit({
		root = root,
		map = map,
		cAdd = nil,
		cRem = nil,
		rAnc = nil,
		skipTeleport = opts.skipTeleport == true,
	})

	const function offAdd()
		hub.cAdd = NAmanage._evtHubDisc(hub.cAdd)
	end
	const function offRem()
		hub.cRem = NAmanage._evtHubDisc(hub.cRem)
	end
	function hub.refresh()
		if not (hub.alive and hub.root) then
			offAdd()
			offRem()
			return
		end
		if (hub.addCount or 0) > 0 then
			if not hub.cAdd then
				hub.cAdd = hub.root.DescendantAdded:Connect(function(inst)
					NAmanage._evtHubDeferFire(hub, "add", inst)
				end)
			end
		else
			offAdd()
		end
		if (hub.remCount or 0) > 0 then
			if not hub.cRem then
				hub.cRem = hub.root.DescendantRemoving:Connect(function(inst)
					NAmanage._evtHubDeferFire(hub, "rem", inst)
				end)
			end
		else
			offRem()
		end
	end
	function hub.dispose()
		NAmanage._descHubBaseDispose(hub)
	end
	if opts.ancestry ~= false then
		hub.rAnc = NAmanage.safeConnect(root.AncestryChanged, function(_, parent)
			if not parent then
				hub.dispose()
			end
		end)
	end
	map[root] = hub
	return hub
end

NAmanage._wsHubMap = NAmanage.ensureWeakTable(NAmanage._wsHubMap, "kv")
NAmanage._wsHub = NAmanage._wsHub or nil

NAmanage._wsHubDispose = NAmanage._wsHubDispose or function(hub)
	hub = hub or NAmanage._wsHub
	NAmanage._descHubBaseDispose(hub)
	if NAmanage._wsHub == hub then
		NAmanage._wsHub = nil
	end
end

NAmanage._wsHubGet = NAmanage._wsHubGet or function()
	const hub = NAmanage._descHubBaseGet(NAmanage._wsHubMap, Services.Workspace, {
		ancestry = false,
		skipTeleport = false,
	})
	NAmanage._wsHub = hub
	return hub
end

NAmanage.wsReleaseCache = function(hub)
	hub = hub or NAmanage._wsHub
	if type(hub) == "table" then
		hub.cacheLive = false
		hub.cacheBuilding = false
		hub.cache = {}
		hub.idx = NAmanage.ensureWeakTable(nil, "k")
		hub.cacheAdd = NAmanage._evtHubDisc(hub.cacheAdd)
		hub.cacheRem = NAmanage._evtHubDisc(hub.cacheRem)
	end
	return false
end

NAmanage.wsReleaseCacheIfIdle = function(maxIdle)
	const hub = NAmanage._wsHub
	if type(hub) ~= "table" or hub.cacheLive ~= true then
		return false
	end
	const idle = tonumber(maxIdle) or 30
	const last = tonumber(hub.cacheTouched) or 0
	if idle > 0 and last > 0 and os.clock() - last >= idle and (hub.addCount or 0) <= 0 and (hub.remCount or 0) <= 0 then
		return NAmanage.wsReleaseCache(hub)
	end
	return false
end

NAmanage._wsCacheRemove = function(hub, inst)
	if type(hub) ~= "table" or type(hub.idx) ~= "table" or type(hub.cache) ~= "table" or inst == nil then
		return false
	end
	const idx = hub.idx[inst]
	if not idx then
		return false
	end
	const list = hub.cache
	const lastIdx = #list
	const lastInst = list[lastIdx]
	list[lastIdx] = nil
	hub.idx[inst] = nil
	if idx < lastIdx then
		list[idx] = lastInst
		if lastInst ~= nil then
			hub.idx[lastInst] = idx
		end
	end
	return true
end

NAmanage._wsCacheAdd = function(hub, inst)
	const RawWorkspace = __lt.gs("Workspace")
	if type(hub) ~= "table" or typeof(inst) ~= "Instance" or inst == Services.Workspace or inst == RawWorkspace then
		return false
	end
	if type(hub.cache) ~= "table" then
		hub.cache = {}
	end
	if type(hub.idx) ~= "table" then
		hub.idx = NAmanage.ensureWeakTable(nil, "k")
	end
	if hub.idx[inst] then
		return false
	end
	const n = #hub.cache + 1
	hub.cache[n] = inst
	hub.idx[inst] = n
	return true
end

NAmanage._wsCacheConnect = function(hub)
	const RawWorkspace = __lt.gs("Workspace")
	if type(hub) ~= "table" or (hub.root ~= Services.Workspace and hub.root ~= RawWorkspace) then
		return
	end
	if not hub.cacheAdd then
		hub.cacheAdd = Services.Workspace.DescendantAdded:Connect(function(inst)
			NAmanage._wsCacheAdd(hub, inst)
		end)
	end
	if not hub.cacheRem then
		hub.cacheRem = Services.Workspace.DescendantRemoving:Connect(function(inst)
			NAmanage._wsCacheRemove(hub, inst)
		end)
	end
end

NAmanage._wsCachePrune = function(hub, budget)
	if type(hub) ~= "table" or type(hub.cache) ~= "table" or type(hub.idx) ~= "table" then
		return
	end
	const list = hub.cache
	const total = #list
	if total <= 0 then
		hub.cachePruneCursor = 1
		return
	end
	local cursor = tonumber(hub.cachePruneCursor) or 1
	if cursor < 1 or cursor > total then
		cursor = 1
	end
	local checked = 0
	const maxCheck = math.clamp(math.floor(tonumber(budget) or 48), 1, 256)
	while checked < maxCheck and #list > 0 do
		const inst = list[cursor]
		if typeof(inst) ~= "Instance" or not inst.Parent or not inst:IsDescendantOf(Services.Workspace) then
			NAmanage._wsCacheRemove(hub, inst)
			if cursor > #list then
				cursor = 1
			end
		else
			cursor += 1
			if cursor > #list then
				cursor = 1
			end
		end
		checked += 1
	end
	hub.cachePruneCursor = cursor
end

NAmanage._wsCacheBuildSync = function(hub)
	if type(hub) ~= "table" then
		return {}
	end
	const descs = Services.Workspace:QueryDescendants("Instance")
	hub.cache = {}
	hub.idx = NAmanage.ensureWeakTable(nil, "k")
	for i = 1, #descs do
		NAmanage._wsCacheAdd(hub, descs[i])
	end
	hub.cacheLive = true
	hub.cacheBuilding = false
	hub.cacheBuiltAt = os.clock()
	hub.cacheTouched = hub.cacheBuiltAt
	NAmanage._wsCacheConnect(hub)
	return hub.cache
end

NAmanage._wsCacheBuildAsync = function(hub, opts)
	const RawWorkspace = __lt.gs("Workspace")
	if type(hub) ~= "table" or hub.cacheBuilding == true then
		return
	end
	opts = type(opts) == "table" and opts or {}
	hub.cacheLive = true
	hub.cacheBuilding = true
	hub.cache = {}
	hub.idx = NAmanage.ensureWeakTable(nil, "k")
	hub.cacheTouched = os.clock()
	NAmanage._wsCacheConnect(hub)
	Spawn(function()
		const q = { Services.Workspace }
		local qi, qn = 1, 1
		while qi <= qn and hub.cacheBuilding == true and (hub.root == Services.Workspace or hub.root == RawWorkspace) do
			local budget, waitDelay = NAmanage._evtHubBudget(tonumber(opts.buildBudget) or 192, {
				delay = tonumber(opts.delayTime) or 0,
				ldSc = 0.25,
				ldDel = 0.012,
			})
			while budget > 0 and qi <= qn and hub.cacheBuilding == true do
				const inst = q[qi]
				q[qi] = nil
				qi += 1
				if inst and (inst == Services.Workspace or inst == RawWorkspace or inst.Parent) then
					if inst ~= Services.Workspace and inst ~= RawWorkspace then
						NAmanage._wsCacheAdd(hub, inst)
					end
					local ok, children = pcall(inst.GetChildren, inst)
					if ok and type(children) == "table" then
						for i = 1, #children do
							qn += 1
							q[qn] = children[i]
						end
					end
				end
				budget -= 1
			end
			if qi <= qn then
				if waitDelay > 0 then
					Wait(waitDelay)
				else
					Wait()
				end
			end
		end
		if type(hub) == "table" then
			hub.cacheBuilding = false
			hub.cacheBuiltAt = os.clock()
			hub.cacheTouched = hub.cacheBuiltAt
		end
	end)
end

NAmanage.wsSub = NAmanage.wsSub or function(spec)
	const hub = NAmanage._wsHubGet()
	return NAmanage._evtHubSub(hub, spec)
end

NAmanage.wsAdd = NAmanage.wsAdd or function(fn)
	return NAmanage.wsSub({
		added = fn
	})
end

NAmanage.wsRem = NAmanage.wsRem or function(fn)
	return NAmanage.wsSub({
		removing = fn
	})
end

NAmanage._cgHubMap = NAmanage.ensureWeakTable(NAmanage._cgHubMap, "kv")
NAmanage._cgHub = NAmanage._cgHub or nil

NAmanage._cgHubDispose = NAmanage._cgHubDispose or function(hub)
	hub = hub or NAmanage._cgHub
	NAmanage._descHubBaseDispose(hub)
	if NAmanage._cgHub == hub then
		NAmanage._cgHub = nil
	end
end

NAmanage._cgHubGet = NAmanage._cgHubGet or function()
	const root = (typeof(Services.CoreGui) == "Instance" and Services.CoreGui) or SafeGetService("CoreGui")
	if typeof(root) ~= "Instance" then
		return nil
	end
	local hub = NAmanage._cgHub
	if type(hub) == "table" and hub.root ~= root then
		NAmanage._cgHubDispose(hub)
		hub = nil
	end
	hub = hub or NAmanage._descHubBaseGet(NAmanage._cgHubMap, root, {
		ancestry = false,
		skipTeleport = true,
	})
	NAmanage._cgHub = hub
	return hub
end

NAmanage.cgSub = NAmanage.cgSub or function(spec)
	const hub = NAmanage._cgHubGet()
	return NAmanage._evtHubSub(hub, spec)
end

NAmanage.cgAdd = NAmanage.cgAdd or function(fn, filter)
	return NAmanage.cgSub({
		added = fn,
		filterAdded = filter,
	})
end

NAmanage.cgRem = NAmanage.cgRem or function(fn, filter)
	return NAmanage.cgSub({
		removing = fn,
		filterRemoving = filter,
	})
end

NAmanage._pgHub = NAmanage._pgHub or nil

NAmanage._pgHubDispose = NAmanage._pgHubDispose or function(hub)
	hub = hub or NAmanage._pgHub
	if type(hub) ~= "table" then
		return
	end
	hub.alive = false
	NAmanage._evtHubClear(hub)
	hub.lpAdd = NAmanage._evtHubDisc(hub.lpAdd)
	hub.lpRem = NAmanage._evtHubDisc(hub.lpRem)
	hub.lpAnc = NAmanage._evtHubDisc(hub.lpAnc)
	hub.root = nil
	hub.player = nil
	if NAmanage._pgHub == hub then
		NAmanage._pgHub = nil
	end
end

NAmanage._pgHubGet = NAmanage._pgHubGet or function()
	const players = SafeGetService("Players")
	const lp = players and players.LocalPlayer or nil
	local hub = NAmanage._pgHub
	if type(hub) == "table" and (not hub.alive or hub.player ~= lp) then
		NAmanage._pgHubDispose(hub)
		hub = nil
	end
	if type(hub) == "table" and hub.alive then
		if type(hub.syncRoot) == "function" then
			hub.syncRoot()
		end
		return hub
	end

	hub = NAmanage._evtHubInit({
		player = lp,
		root = nil,
		cAdd = nil,
		cRem = nil,
		rAnc = nil,
		lpAdd = nil,
		lpRem = nil,
		lpAnc = nil,
		skipTeleport = true,
	})

	const function offRoot()
		hub.cAdd = NAmanage._evtHubDisc(hub.cAdd)
		hub.cRem = NAmanage._evtHubDisc(hub.cRem)
		hub.rAnc = NAmanage._evtHubDisc(hub.rAnc)
	end
	function hub.refresh()
		if not (hub.alive and hub.root) then
			offRoot()
			return
		end
		if (hub.addCount or 0) > 0 then
			if not hub.cAdd then
				hub.cAdd = hub.root.DescendantAdded:Connect(function(inst)
					NAmanage._evtHubDeferFire(hub, "add", inst)
				end)
			end
		else
			hub.cAdd = NAmanage._evtHubDisc(hub.cAdd)
		end
		if (hub.remCount or 0) > 0 then
			if not hub.cRem then
				hub.cRem = hub.root.DescendantRemoving:Connect(function(inst)
					NAmanage._evtHubDeferFire(hub, "rem", inst)
				end)
			end
		else
			hub.cRem = NAmanage._evtHubDisc(hub.cRem)
		end
	end
	function hub.dispose()
		NAmanage._pgHubDispose(hub)
	end
	const function bindRoot(root)
		if hub.root == root then
			hub.refresh()
			return
		end
		offRoot()
		hub.root = root
		if root then
			hub.rAnc = NAmanage.safeConnect(root.AncestryChanged, function(_, parent)
				if not parent then
					bindRoot(nil)
					Defer(function()
						if hub.alive and type(hub.syncRoot) == "function" then
							hub.syncRoot()
						end
					end)
				end
			end)
		end
		hub.refresh()
	end
	function hub.syncRoot()
		local root = nil
		if hub.player and hub.player.Parent then
			root = hub.player:FindFirstChildOfClass("PlayerGui") or hub.player:FindFirstChild("PlayerGui")
		end
		bindRoot(root)
	end
	if lp then
		hub.lpAdd = NAmanage.safeConnect(lp.ChildAdded, function(child)
			if child and child:IsA("PlayerGui") then
				bindRoot(child)
			end
		end)
		hub.lpRem = NAmanage.safeConnect(lp.ChildRemoved, function(child)
			if child and child == hub.root then
				bindRoot(nil)
			end
			Defer(function()
				if hub.alive and type(hub.syncRoot) == "function" then
					hub.syncRoot()
				end
			end)
		end)
		hub.lpAnc = NAmanage.safeConnect(lp.AncestryChanged, function(_, parent)
			if not parent then
				bindRoot(nil)
			else
				Defer(function()
					if hub.alive and type(hub.syncRoot) == "function" then
						hub.syncRoot()
					end
				end)
			end
		end)
	end
	hub.syncRoot()
	NAmanage._pgHub = hub
	return hub
end

NAmanage.pgSub = NAmanage.pgSub or function(spec)
	const hub = NAmanage._pgHubGet()
	return NAmanage._evtHubSub(hub, spec)
end

NAmanage.pgAdd = NAmanage.pgAdd or function(fn, filter)
	return NAmanage.pgSub({
		added = fn,
		filterAdded = filter,
	})
end

NAmanage.pgRem = NAmanage.pgRem or function(fn, filter)
	return NAmanage.pgSub({
		removing = fn,
		filterRemoving = filter,
	})
end

NAmanage._playersHub = NAmanage._playersHub or nil

NAmanage._playersHubDispose = NAmanage._playersHubDispose or function(hub)
	hub = hub or NAmanage._playersHub
	if type(hub) ~= "table" then
		return
	end
	hub.alive = false
	NAmanage._evtHubClear(hub)
	hub.players = nil
	if NAmanage._playersHub == hub then
		NAmanage._playersHub = nil
	end
end

NAmanage._playersHubGet = NAmanage._playersHubGet or function()
	const players = SafeGetService("Players")
	local hub = NAmanage._playersHub
	if type(hub) == "table" and (not hub.alive or hub.players ~= players) then
		NAmanage._playersHubDispose(hub)
		hub = nil
	end
	if type(hub) == "table" and hub.alive then
		return hub
	end
	hub = NAmanage._evtHubInit({
		players = players,
		cAdd = nil,
		cRem = nil,
	})
	function hub.refresh()
		if not (hub.alive and hub.players) then
			hub.cAdd = NAmanage._evtHubDisc(hub.cAdd)
			hub.cRem = NAmanage._evtHubDisc(hub.cRem)
			return
		end
		if (hub.addCount or 0) > 0 then
			if not hub.cAdd then
				hub.cAdd = NAmanage.safeConnect(hub.players.PlayerAdded, function(plr)
					NAmanage._evtHubFire(hub, "add", plr)
				end)
			end
		else
			hub.cAdd = NAmanage._evtHubDisc(hub.cAdd)
		end
		if (hub.remCount or 0) > 0 then
			if not hub.cRem then
				hub.cRem = NAmanage.safeConnect(hub.players.PlayerRemoving, function(plr)
					NAmanage._evtHubFire(hub, "rem", plr)
				end)
			end
		else
			hub.cRem = NAmanage._evtHubDisc(hub.cRem)
		end
	end
	function hub.dispose()
		NAmanage._playersHubDispose(hub)
	end
	NAmanage._playersHub = hub
	return hub
end

NAmanage.playersSub = NAmanage.playersSub or function(spec)
	const hub = NAmanage._playersHubGet()
	return NAmanage._evtHubSub(hub, spec)
end

NAmanage.playersAdd = NAmanage.playersAdd or function(fn, filter)
	return NAmanage.playersSub({
		added = fn,
		filterAdded = filter,
	})
end

NAmanage.playersRem = NAmanage.playersRem or function(fn, filter)
	return NAmanage.playersSub({
		removing = fn,
		filterRemoving = filter,
	})
end

NAmanage._descHubs = NAmanage.ensureWeakTable(NAmanage._descHubs, "kv")

NAmanage._descHubDispose = NAmanage._descHubDispose or function(root, hub)
	if type(hub) ~= "table" then
		hub = type(NAmanage._descHubs) == "table" and NAmanage._descHubs[root] or nil
	end
	NAmanage._descHubBaseDispose(hub)
end

NAmanage._descHubGet = NAmanage._descHubGet or function(root)
	return NAmanage._descHubBaseGet(NAmanage._descHubs, root, {
		ancestry = true,
		skipTeleport = true,
	})
end

NAmanage.descSub = NAmanage.descSub or function(root, spec)
	const RawWorkspace = __lt.gs("Workspace")
	const RawCoreGui = __lt.gs("CoreGui")
	const noop = {
		Connected = false,
		Disconnect = function() end,
	}
	if typeof(root) ~= "Instance" then
		return noop
	end
	if (root == Services.Workspace or root == RawWorkspace) and NAmanage.wsSub then
		return NAmanage.wsSub(spec)
	end
	const coreRoot = (typeof(Services.CoreGui) == "Instance" and Services.CoreGui) or SafeGetService("CoreGui")
	if coreRoot and (root == coreRoot or root == RawCoreGui) and NAmanage.cgSub then
		return NAmanage.cgSub(spec)
	end
	if NAmanage.pgSub and NAmanage._pgHubGet then
		local ok, pgHub = pcall(NAmanage._pgHubGet)
		if ok and pgHub and pgHub.root and pgHub.root == root then
			return NAmanage.pgSub(spec)
		end
	end
	return NAmanage._evtHubSub(NAmanage._descHubGet(root), spec)
end

NAmanage.descAdd = NAmanage.descAdd or function(root, fn, filter)
	return NAmanage.descSub(root, {
		added = fn,
		filterAdded = filter,
	})
end

NAmanage.descRem = NAmanage.descRem or function(root, fn, filter)
	return NAmanage.descSub(root, {
		removing = fn,
		filterRemoving = filter,
	})
end

NAmanage._childHubs = NAmanage.ensureWeakTable(NAmanage._childHubs, "kv")

NAmanage._childHubDispose = NAmanage._childHubDispose or function(root, hub)
	const hubs = NAmanage._childHubs
	if type(hub) ~= "table" then
		hub = type(hubs) == "table" and hubs[root] or nil
	end
	if type(hub) ~= "table" then
		return
	end
	hub.alive = false
	if hub.cAdd then
		pcall(function()
			hub.cAdd:Disconnect()
		end)
		hub.cAdd = nil
	end
	if hub.cRem then
		pcall(function()
			hub.cRem:Disconnect()
		end)
		hub.cRem = nil
	end
	if hub.rAnc then
		pcall(function()
			hub.rAnc:Disconnect()
		end)
		hub.rAnc = nil
	end
	hub.added = {}
	hub.removed = {}
	hub.addCount = 0
	hub.remCount = 0
	if type(hubs) == "table" and root ~= nil and hubs[root] == hub then
		hubs[root] = nil
	end
end

NAmanage._childHubGet = NAmanage._childHubGet or function(root)
	if typeof(root) ~= "Instance" then
		return nil
	end
	const hubs = NAmanage._childHubs
	local hub = hubs[root]
	if hub and hub.alive and hub.root == root then
		return hub
	end

	const function disc(c)
		if c then
			pcall(function()
				c:Disconnect()
			end)
		end
	end

	if hub then
		NAmanage._childHubDispose(root, hub)
	end

	hub = {
		root = root,
		nextId = 0,
		added = {},
		removed = {},
		addCount = 0,
		remCount = 0,
		cAdd = nil,
		cRem = nil,
		rAnc = nil,
		alive = true,
	}

	const dispatch = NAmanage._evtHubDispatch

	const function fireChild(kind, inst)
		if not (hub.alive and inst) then
			return
		end
		if kind == "add" then
			if (hub.addCount or 0) <= 0 then
				return
			end
			Defer(function()
				if hub.alive and (hub.addCount or 0) > 0 then
					dispatch(hub.added, inst)
				end
			end)
		else
			if (hub.remCount or 0) <= 0 then
				return
			end
			Defer(function()
				if hub.alive and (hub.remCount or 0) > 0 then
					dispatch(hub.removed, inst)
				end
			end)
		end
	end

	const function wantsEvents()
		return (hub.addCount or 0) > 0 or (hub.remCount or 0) > 0
	end

	const function disconnectHooks()
		disc(hub.cAdd)
		disc(hub.cRem)
		hub.cAdd = nil
		hub.cRem = nil
	end

	const function connectHooks()
		if not (hub.alive and wantsEvents()) then
			return
		end
		if not hub.cAdd then
			hub.cAdd = root.ChildAdded:Connect(function(inst)
				fireChild("add", inst)
			end)
		end
		if not hub.cRem then
			hub.cRem = root.ChildRemoved:Connect(function(inst)
				fireChild("rem", inst)
			end)
		end
	end

	hub.rAnc = NAmanage.safeConnect(root.AncestryChanged, function(_, parent)
		if parent then
			return
		end
		NAmanage._childHubDispose(root, hub)
	end)

	hub.enableHooks = connectHooks
	hub.disableHooks = disconnectHooks
	hubs[root] = hub
	return hub
end

NAmanage.childSub = NAmanage.childSub or function(root, spec)
	spec = spec or {}
	const onAdd = type(spec.added) == "function" and spec.added or nil
	const onRem = type(spec.removed) == "function" and spec.removed
		or (type(spec.removing) == "function" and spec.removing or nil)
	const addFilter = type(spec.filterAdded) == "function" and spec.filterAdded
		or (type(spec.filter) == "function" and spec.filter or nil)
	const remFilter = type(spec.filterRemoved) == "function" and spec.filterRemoved
		or (type(spec.filterRemoving) == "function" and spec.filterRemoving
		or (type(spec.filter) == "function" and spec.filter or nil))
	const noop = {
		Connected = false,
		Disconnect = function() end,
	}
	if not onAdd and not onRem then
		return noop
	end
	if typeof(root) ~= "Instance" then
		return noop
	end

	const hub = NAmanage._childHubGet(root)
	if not hub then
		return noop
	end
	hub.nextId += 1
	const id = hub.nextId
	if onAdd then
		hub.added[id] = addFilter and {
			fn = onAdd,
			filter = addFilter,
		} or onAdd
		hub.addCount = (hub.addCount or 0) + 1
	end
	if onRem then
		hub.removed[id] = remFilter and {
			fn = onRem,
			filter = remFilter,
		} or onRem
		hub.remCount = (hub.remCount or 0) + 1
	end
	if type(hub.enableHooks) == "function" then
		hub.enableHooks()
	end

	const conn = {
		Connected = true,
	}
	function conn:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false
		if hub.added[id] then
			hub.added[id] = nil
			hub.addCount = math.max(0, (hub.addCount or 0) - 1)
		end
		if hub.removed[id] then
			hub.removed[id] = nil
			hub.remCount = math.max(0, (hub.remCount or 0) - 1)
		end
		if (hub.addCount or 0) <= 0 and (hub.remCount or 0) <= 0 then
			NAmanage._childHubDispose(root, hub)
		end
	end
	return conn
end

NAmanage.childAdd = NAmanage.childAdd or function(root, fn, filter)
	return NAmanage.childSub(root, {
		added = fn,
		filterAdded = filter,
	})
end

NAmanage.childRem = NAmanage.childRem or function(root, fn, filter)
	return NAmanage.childSub(root, {
		removed = fn,
		filterRemoved = filter,
	})
end

NAmanage._mouseMoveHubs = NAmanage.ensureWeakTable(NAmanage._mouseMoveHubs, "kv")

NAmanage._mouseMoveHubDispose = NAmanage._mouseMoveHubDispose or function(mouseObj, hub)
	const hubs = NAmanage._mouseMoveHubs
	if type(hub) ~= "table" then
		hub = type(hubs) == "table" and hubs[mouseObj] or nil
	end
	if type(hub) ~= "table" then
		return
	end
	hub.alive = false
	if hub.moveCon then
		pcall(function()
			hub.moveCon:Disconnect()
		end)
		hub.moveCon = nil
	end
	hub.subs = {}
	hub.count = 0
	if type(hubs) == "table" and mouseObj ~= nil and hubs[mouseObj] == hub then
		hubs[mouseObj] = nil
	end
end

NAmanage._mouseMoveHubGet = NAmanage._mouseMoveHubGet or function(mouseObj)
	if not mouseObj then
		return nil
	end

	const hubs = NAmanage._mouseMoveHubs
	local hub = hubs[mouseObj]

	const function disc(c)
		if c then
			pcall(function()
				c:Disconnect()
			end)
		end
	end

	if hub and not hub.alive then
		NAmanage._mouseMoveHubDispose(mouseObj, hub)
		hub = nil
	end

	if hub then
		return hub
	end

	hub = {
		mouse = mouseObj,
		nextId = 0,
		subs = {},
		count = 0,
		moveCon = nil,
		alive = true,
	}

	const function dispatch(x, y, now)
		for _, rec in hub.subs do
			const fn = rec and rec.fn
			if type(fn) == "function" then
				local pass = true
				const guard = rec.guard
				if type(guard) == "function" then
					local okGuard, allowed = pcall(guard, x, y, now)
					pass = okGuard and allowed == true
				end
				if pass then
					const minInterval = rec.minInterval or 0
					if minInterval > 0 then
						const lastRun = rec.lastRun or 0
						if now - lastRun < minInterval then
							pass = false
						end
					end
				end
				if pass then
					const minDelta = rec.minDelta or 0
					if minDelta > 0 then
						const lx = rec.lastX
						const ly = rec.lastY
						if lx ~= nil and ly ~= nil then
							const delta = math.abs(x - lx) + math.abs(y - ly)
							if delta < minDelta then
								pass = false
							end
						end
					end
				end
				if pass then
					rec.lastRun = now
					rec.lastX = x
					rec.lastY = y
					pcall(fn, x, y, now)
				end
			end
		end
	end

	const function ensureConnection()
		if hub.moveCon or not hub.alive or hub.count <= 0 then
			return
		end
		hub.moveCon = mouseObj.Move:Connect(function()
			if not hub.alive then
				return
			end
			const x = tonumber(mouseObj.X) or 0
			const y = tonumber(mouseObj.Y) or 0
			dispatch(x, y, os.clock())
		end)
	end

	const function stopIfIdle()
		if hub.count <= 0 and hub.moveCon then
			disc(hub.moveCon)
			hub.moveCon = nil
		end
	end

	hub.ensureConnection = ensureConnection
	hub.stopIfIdle = stopIfIdle

	hubs[mouseObj] = hub
	return hub
end

NAmanage.mouseMoveSub = NAmanage.mouseMoveSub or function(mouseObj, spec)
	spec = spec or {}
	if type(spec) == "function" then
		spec = { fn = spec }
	end
	const fn = type(spec.fn) == "function" and spec.fn
		or (type(spec.callback) == "function" and spec.callback or nil)
	const noop = {
		Connected = false,
		Disconnect = function() end,
	}
	if type(fn) ~= "function" then
		return noop
	end

	const hub = NAmanage._mouseMoveHubGet(mouseObj)
	if not hub then
		return noop
	end

	hub.nextId += 1
	const id = hub.nextId
	hub.subs[id] = {
		fn = fn,
		guard = type(spec.guard) == "function" and spec.guard or nil,
		minInterval = math.max(0, tonumber(spec.minInterval) or 0),
		minDelta = math.max(0, tonumber(spec.minDelta) or 0),
		lastRun = 0,
		lastX = nil,
		lastY = nil,
	}
	hub.count = (hub.count or 0) + 1
	if type(hub.ensureConnection) == "function" then
		hub.ensureConnection()
	end

	const conn = {
		Connected = true,
	}
	function conn:Disconnect()
		if not self.Connected then
			return
		end
		self.Connected = false
		if hub.subs[id] then
			hub.subs[id] = nil
			hub.count = math.max(0, (hub.count or 0) - 1)
		end
		if (hub.count or 0) <= 0 then
			NAmanage._mouseMoveHubDispose(mouseObj, hub)
		elseif type(hub.stopIfIdle) == "function" then
			hub.stopIfIdle()
		end
	end

	if spec.fireNow then
		const x = tonumber(mouseObj.X) or 0
		const y = tonumber(mouseObj.Y) or 0
		pcall(fn, x, y, os.clock())
	end

	return conn
end

NAlib.isProperty = function(inst, prop)
	local s, r = pcall(function() return inst[prop] end)
	if not s then return nil end
	return r
end

NAlib.setProperty = function(inst, prop, v)
	local ok, cur = pcall(function()
		return inst[prop]
	end)
	if ok and cur == v then
		return true
	end
	const s = pcall(function()
		inst[prop] = v
	end)
	return s
end

-- Attribute shim for executors that break string attributes (Xeno)
NAmanage.GenerateOpaqueSessionKey = function()
	local used = NAStuff._opaqueSessionKeys
	if type(used) ~= "table" then
		used = {}
		NAStuff._opaqueSessionKeys = used
	end
	const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	const digits = "0123456789"
	const safeSymbols = {".", "-", "_", "/"}
	local key = nil
	for _ = 1, 16 do
		const out = {}
		const totalLength = math.random(28, 52)
		const firstIdx = math.random(1, #letters)
		out[1] = letters:sub(firstIdx, firstIdx)
		local symbolCount = 0
		local letterCount = 1
		local digitCount = 0
		for i = 2, totalLength do
			const roll = math.random()
			if roll <= 0.32 then
				const sym = safeSymbols[math.random(1, #safeSymbols)]
				out[i] = sym
				symbolCount = symbolCount + 1
			elseif roll <= 0.72 then
				const idx = math.random(1, #letters)
				out[i] = letters:sub(idx, idx)
				letterCount = letterCount + 1
			else
				const idx = math.random(1, #digits)
				out[i] = digits:sub(idx, idx)
				digitCount = digitCount + 1
			end
		end
		if symbolCount < 6 then
			for i = 1, (6 - symbolCount) do
				const pos = math.random(2, #out)
				out[pos] = safeSymbols[math.random(1, #safeSymbols)]
			end
		end
		if letterCount < 8 then
			for i = 1, (8 - letterCount) do
				const pos = math.random(2, #out)
				const idx = math.random(1, #letters)
				out[pos] = letters:sub(idx, idx)
			end
		end
		if digitCount < 4 then
			for i = 1, (4 - digitCount) do
				const pos = math.random(2, #out)
				const idx = math.random(1, #digits)
				out[pos] = digits:sub(idx, idx)
			end
		end
		const candidate = Concat(out)
		if candidate ~= "" and not used[candidate] then
			used[candidate] = true
			key = candidate
			break
		end
	end
	if type(key) ~= "string" or key == "" then
		key = "a._-/_a._-/_a._-/_a._-/_a._-/_"
		if used[key] then
			repeat
				key = "a" .. tostring(math.random(100000, 999999)) .. "_-/" .. tostring(math.random(100000, 999999)) .. "._" .. tostring(math.random(100000, 999999))
			until not used[key]
		end
		used[key] = true
	end
	return key
end

NAmanage.GenerateOpaqueSessionTagName = function()
	local used = NAStuff._opaqueSessionTagNames
	if type(used) ~= "table" then
		used = {}
		NAStuff._opaqueSessionTagNames = used
	end
	local key = nil
	for _ = 1, 8 do
		const candidate = NAmanage.GenerateOpaqueSessionKey()
		if candidate ~= "" and not used[candidate] then
			used[candidate] = true
			key = candidate
			break
		end
	end
	if type(key) ~= "string" or key == "" then
		key = NAmanage.GenerateOpaqueSessionKey()
		if not used[key] then
			used[key] = true
		end
	end
	return key
end

NAmanage.GetSessionOpaqueMappedValue = function(mapField, key)
	if key == nil then
		return nil
	end
	const logicalKey = tostring(key)
	local map = NAStuff[mapField]
	if type(map) ~= "table" then
		map = {}
		NAStuff[mapField] = map
	end
	local value = map[logicalKey]
	if type(value) == "string" and value ~= "" then
		return value
	end
	value = NAmanage.GenerateOpaqueSessionKey()
	map[logicalKey] = value
	return value
end

NAmanage.GetSessionActionName = function(key)
	return NAmanage.GetSessionOpaqueMappedValue("_sessionActionNameMap", key)
end

NAmanage.GetSessionInstanceName = function(key)
	return NAmanage.GetSessionOpaqueMappedValue("_sessionInstanceNameMap", key)
end

pcall(function()
	if __NAUIProtector and type(__NAUIProtector.setSessionNameProvider) == "function" then
		__NAUIProtector.setSessionNameProvider(function(key)
			if type(NAmanage.GetSessionInstanceName) == "function" then
				return NAmanage.GetSessionInstanceName(key)
			end
		end)
	end
end)

NAmanage.GetSessionAttrKey = function(key)
	if key == nil then
		return nil
	end
	const logicalKey = tostring(key)
	local map = NAStuff._sessionAttrKeyMap
	if type(map) ~= "table" then
		map = {}
		NAStuff._sessionAttrKeyMap = map
	end
	local actualKey = map[logicalKey]
	if type(actualKey) == "string" and actualKey ~= "" then
		return actualKey
	end
	actualKey = NAmanage.GenerateOpaqueSessionKey()
	map[logicalKey] = actualKey
	return actualKey
end

NAmanage.GetSessionAttrTagName = function(key)
	if key == nil then
		return nil
	end
	const logicalKey = tostring(key)
	local map = NAStuff._sessionAttrTagNameMap
	if type(map) ~= "table" then
		map = {}
		NAStuff._sessionAttrTagNameMap = map
	end
	local tagName = map[logicalKey]
	if type(tagName) == "string" and tagName ~= "" then
		return tagName
	end
	tagName = NAmanage.GenerateOpaqueSessionTagName()
	map[logicalKey] = tagName
	return tagName
end

NAmanage.GetAttr=function(inst, key)
	if not inst or not key then return nil end
	const actualKey = NAmanage.GetSessionAttrKey(key)
	local ok, value = pcall(function() return inst:GetAttribute(actualKey) end)
	if ok and value ~= nil then
		return value
	end
	ok, value = pcall(function() return inst:GetAttribute(key) end)
	if ok and value ~= nil then
		return value
	end
	local tag = inst:FindFirstChild(NAmanage.GetSessionAttrTagName(key))
	if tag and tag:IsA("ValueBase") then
		return tag.Value
	end
	tag = inst:FindFirstChild("_NAATTR_"..tostring(key))
	if tag and tag:IsA("ValueBase") then
		return tag.Value
	end
	return nil
end

NAmanage.SetAttr=function(inst, key, value)
	if not inst or not key then return end
	const actualKey = NAmanage.GetSessionAttrKey(key)
	const ok = pcall(function() inst:SetAttribute(actualKey, value) end)
	if ok then
		return
	end

	const tagName = NAmanage.GetSessionAttrTagName(key)
	local existing = inst:FindFirstChild(tagName)

	if value == nil then
		if existing then pcall(function() existing:Destroy() end) end
		return
	end

	local class = "StringValue"
	if type(value) == "boolean" then
		class = "BoolValue"
	elseif type(value) == "number" then
		class = "NumberValue"
	end

	if not existing or existing.ClassName ~= class then
		if existing then pcall(function() existing:Destroy() end) end
		existing = Instance.new(class)
		existing.Name = tagName
		existing.Archivable = false
		existing.Parent = inst
	end

	existing.Value = value
end

NAmanage.NewCancelToken = NAmanage.NewCancelToken or function()
	return { cancelled = false }
end

NAmanage.CancelTokenCancel = NAmanage.CancelTokenCancel or function(token)
	if type(token) == "table" then
		token.cancelled = true
	end
end

NAmanage.isLoad = NAmanage.isLoad or function()
	local load = nil
	if type(_G) == "table" then
		load = rawget(_G, "NAAssetsLoading")
	end
	if type(load) ~= "table" then
		load = NAAssetsLoading
	end
	if type(load) ~= "table" then
		return false
	end
	if load._finalized == true then
		return false
	end
	if load._visualClosed == true then
		return true
	end
	const done = load.completed
	if typeof(done) == "Instance" then
		const completedAttr = NAmanage.GetAttr(done, "Completed")
		if type(completedAttr) == "boolean" then
			return completedAttr ~= true
		end
		if done:IsA("BoolValue") then
			return done.Value ~= true
		end
	end
	return load._finalized ~= true
end

NAmanage.lpProf = NAmanage.lpProf or function(baseBud, opts)
	opts = opts or {}
	local bud = math.max(1, math.floor(tonumber(baseBud) or 1))
	local del = tonumber(opts.delay) or 0
	if NAmanage.isLoad and NAmanage.isLoad() then
		local sc = tonumber(opts.ldSc)
		if not sc then
			sc = 0.4
		end
		sc = math.clamp(sc, 0.05, 1)
		bud = math.max(1, math.floor(bud * sc))
		const ld = tonumber(opts.ldDel)
		if ld and ld > del then
			del = ld
		elseif del <= 0 then
			del = 0.01
		end
	end
	return bud, del
end

NAmanage.ForEachDescendantYield = function(root, handler, opts)
	opts = opts or {}
	if typeof(root) ~= "Instance" or type(handler) ~= "function" then
		return 0
	end

	const cancelToken = opts.cancelToken
	const includeRoot = opts.includeRoot == true
	const maxItems = tonumber(opts.maxItems)
	const stopOnResult = opts.stopOnResult == true
	const yieldEvery = tonumber(opts.yieldEvery) or tonumber(opts.batchSize) or 0
	const delayTime = tonumber(opts.delayTime) or tonumber(opts.delay) or 0
	const skipChildren = type(opts.skipChildren) == "function" and opts.skipChildren or nil
	local processed = 0

	const function run(inst)
		if cancelToken and cancelToken.cancelled then
			return true
		end
		processed += 1
		const result = handler(inst)
		if stopOnResult and result then
			return true
		end
		if maxItems and processed >= maxItems then
			return true
		end
		return false
	end

	if yieldEvery > 0 or opts.streaming == true then
		const q = { root }
		local qi, qn = 1, 1
		while qi <= qn do
			if cancelToken and cancelToken.cancelled then
				break
			end
			const inst = q[qi]
			q[qi] = nil
			qi += 1
			if inst and (inst == root or inst.Parent) then
				if includeRoot or inst ~= root then
					if run(inst) then
						break
					end
					if yieldEvery > 0 and processed % yieldEvery == 0 then
						if delayTime > 0 then
							Wait(delayTime)
						else
							Wait()
						end
					end
				end
				local shouldSkipChildren = false
				if skipChildren then
					local okSkip, skipResult = pcall(skipChildren, inst)
					shouldSkipChildren = okSkip and skipResult == true
				end
				if not shouldSkipChildren then
					local okChildren, children = pcall(inst.GetChildren, inst)
					if okChildren and type(children) == "table" then
						for i = 1, #children do
							qn += 1
							q[qn] = children[i]
						end
					end
				end
			end
		end
		return processed
	end

	const list = NAmanage.QueryDescendants(root, "Instance")
	if includeRoot then
		if run(root) then
			return processed
		end
	end
	for i = 1, #list do
		const inst = list[i]
		if typeof(inst) == "Instance" then
			if run(inst) then
				break
			end
			if yieldEvery > 0 and processed % yieldEvery == 0 then
				if delayTime > 0 then
					Wait(delayTime)
				else
					Wait()
				end
			end
		end
	end

	return processed
end

NAmanage.RunAfterSettingsBuild = NAmanage.RunAfterSettingsBuild or function(delaySeconds, callback)
	if type(callback) ~= "function" then
		return
	end
	Spawn(function()
		const deadline = os.clock() + 60
		while os.clock() < deadline do
			const state = NAgui and NAgui.SettingsBuildState
			if type(state) ~= "table" or state.building ~= true then
				break
			end
			Wait(0.1)
		end
		const delayValue = tonumber(delaySeconds) or 0
		if delayValue > 0 then
			Wait(delayValue)
		end
		pcall(callback)
	end)
end

NAmanage.ForEachWorkspaceYield = function(handler, opts)
	const RawWorkspace = __lt.gs("Workspace")
	opts = opts or {}
	if type(handler) ~= "function" then
		return 0
	end

	const cancelToken = opts.cancelToken
	const includeRoot = opts.includeRoot == true
	const yieldEvery = tonumber(opts.yieldEvery) or tonumber(opts.batchSize) or 160
	const delayTime = tonumber(opts.delayTime) or tonumber(opts.delay) or 0
	const maxItems = tonumber(opts.maxItems) or 0
	local processed = 0
	const q = { Services.Workspace }
	local qi, qn = 1, 1

	while qi <= qn do
		if cancelToken and cancelToken.cancelled then
			break
		end
		const inst = q[qi]
		q[qi] = nil
		qi += 1
		if inst and (inst == Services.Workspace or inst == RawWorkspace or inst.Parent) then
			if includeRoot or (inst ~= Services.Workspace and inst ~= RawWorkspace) then
				processed += 1
				handler(inst, processed, nil)
				if maxItems > 0 and processed >= maxItems then
					break
				end
			end
			local ok, children = pcall(inst.GetChildren, inst)
			if ok and type(children) == "table" then
				for i = 1, #children do
					qn += 1
					q[qn] = children[i]
				end
			end
		end
		if yieldEvery > 0 and processed > 0 and processed % yieldEvery == 0 then
			if delayTime > 0 then
				Wait(delayTime)
			else
				Wait()
			end
		end
	end

	return processed
end

NAmanage.ESP_CancelScanToken = NAmanage.ESP_CancelScanToken or function(key)
	if type(key) ~= "string" or key == "" then
		return
	end
	const tokens = NAStuff.espScanTokens
	if type(tokens) ~= "table" then
		return
	end
	const tok = tokens[key]
	if tok then
		NAmanage.CancelTokenCancel(tok)
		tokens[key] = nil
	end
end

NAmanage.ESP_StartScanToken = NAmanage.ESP_StartScanToken or function(key)
	if type(key) ~= "string" or key == "" then
		return nil
	end
	NAmanage.ESP_CancelScanToken(key)
	const tok = NAmanage.NewCancelToken()
	NAStuff.espScanTokens[key] = tok
	return tok
end

NAmanage.ESP_ListAdd = NAmanage.ESP_ListAdd or function(list, indexMap, item)
	if type(list) ~= "table" or type(indexMap) ~= "table" or item == nil then
		return false
	end
	if indexMap[item] then
		return false
	end
	const n = #list + 1
	list[n] = item
	indexMap[item] = n
	return true
end

NAmanage.ESP_ListRemove = NAmanage.ESP_ListRemove or function(list, indexMap, item)
	if type(list) ~= "table" or type(indexMap) ~= "table" or item == nil then
		return false
	end
	const idx = indexMap[item]
	if not idx then
		return false
	end
	const lastIdx = #list
	const lastItem = list[lastIdx]
	list[lastIdx] = nil
	indexMap[item] = nil
	if idx < lastIdx then
		list[idx] = lastItem
		indexMap[lastItem] = idx
	end
	return true
end

NAmanage.ESP_GetListMeta = NAmanage.ESP_GetListMeta or function(list)
	if type(list) ~= "table" then
		return nil
	end
	local store = NAStuff and NAStuff.genericESPListMeta
	if type(store) ~= "table" then
		store = NAmanage.ensureWeakTable(nil, "k")
		NAStuff.genericESPListMeta = store
	else
		store = NAmanage.ensureWeakTable(store, "k")
		NAStuff.genericESPListMeta = store
	end
	local meta = store[list]
	if type(meta) ~= "table" then
		meta = {
			index = {};
			counts = {};
			objects = {};
		}
		store[list] = meta
	end
	if type(meta.index) ~= "table" then
		meta.index = {}
	end
	if type(meta.counts) ~= "table" then
		meta.counts = {}
	end
	if type(meta.objects) ~= "table" then
		meta.objects = {}
	end
	return meta
end

NAmanage.ESP_GetListMap = NAmanage.ESP_GetListMap or function(list)
	const meta = NAmanage.ESP_GetListMeta(list)
	return meta and meta.index or nil
end

NAmanage.ESP_GetListCountMap = NAmanage.ESP_GetListCountMap or function(list)
	const meta = NAmanage.ESP_GetListMeta(list)
	return meta and meta.counts or nil
end

NAmanage.ESP_GetListObjectMap = NAmanage.ESP_GetListObjectMap or function(list)
	const meta = NAmanage.ESP_GetListMeta(list)
	return meta and meta.objects or nil
end

NAlib.huiGrabber = function()
	if __NAUIProtector and type(__NAUIProtector.huiGrabber) == "function" then
		local ok, hidden = pcall(__NAUIProtector.huiGrabber)
		if ok and typeof(hidden) == "Instance" then
			return hidden
		end
	end
	return (gethui and gethui()) or
		(gethiddenui and gethiddenui()) or
		(gethiddengui and gethiddengui()) or
		(get_hidden_ui and get_hidden_ui()) or
		(get_hidden_gui and get_hidden_gui()) or
		nil
end

NAlib.distinctHuiGrabber = NAlib.distinctHuiGrabber or function(coreRoot)
	return NAlib.huiGrabber and NAlib.huiGrabber() or nil
end


NAmanage.ResolveExperienceService = NAmanage.ResolveExperienceService or function()
	local service = Services.ExperienceService
	if service then
		return service
	end
	local ok, resolved = pcall(function()
		return game.ExperienceService or game:GetService("ExperienceService")
	end)
	if ok and resolved then
		Services.ExperienceService = resolved
		return resolved
	end
	return nil
end

NAmanage.ExperienceServiceLaunch = NAmanage.ExperienceServiceLaunch or function(params, opts)
	params = type(params) == "table" and params or { placeId = params }
	opts = type(opts) == "table" and opts or {}
	const launchParams = {}
	for key, value in params do
		if value ~= nil then
			launchParams[key] = value
		end
	end
	const service = NAmanage.ResolveExperienceService()
	if not service then
		return false, "ExperienceService unavailable"
	end
	local launchGui
	if type(NAmanage.TeleportGui_Create) == "function" and opts.skipGui ~= true then
		const placeId = launchParams.placeId or launchParams.PlaceId or game.PlaceId
		launchGui = NAmanage.TeleportGui_Create(
			placeId,
			opts.placeName or (type(NAmanage.TeleportGui_GetPlaceName) == "function" and NAmanage.TeleportGui_GetPlaceName(placeId) or nil),
			opts.action or "TELEPORTING",
			opts.detail
		)
	end
	local ok, result = pcall(function()
		if opts.callback and service.LaunchExperienceFromSourceWithCallback then
			return service:LaunchExperienceFromSourceWithCallback(launchParams, opts.source or "NamelessAdmin", opts.callback)
		end
		if opts.source and service.LaunchExperienceFromSource then
			return service:LaunchExperienceFromSource(launchParams, opts.source)
		end
		return service:LaunchExperience(launchParams)
	end)
	if not ok and launchGui and type(NAmanage.TeleportGui_Clear) == "function" then
		pcall(NAmanage.TeleportGui_Clear, launchGui)
	end
	return ok, result
end

NAmanage.TeleportArgsToExperienceParams = NAmanage.TeleportArgsToExperienceParams or function(method, args, meta)
	args = type(args) == "table" and args or {}
	meta = type(meta) == "table" and meta or {}
	const params = {}
	const placeId = tonumber(meta.placeId or args[1])
	if placeId then
		params.placeId = placeId
	end
	if method == "TeleportToPlaceInstance" then
		const instanceId = args[2]
		if instanceId ~= nil and tostring(instanceId) ~= "" then
			params.gameInstanceId = tostring(instanceId)
		end
	elseif method == "TeleportToPrivateServer" then
		const accessCode = args[2]
		if accessCode ~= nil and tostring(accessCode) ~= "" then
			params.reservedServerAccessCode = tostring(accessCode)
		end
	elseif method == "TeleportAsync" then
		const teleportOptions = args[3]
		if typeof(teleportOptions) == "Instance" then
			pcall(function()
				const instanceId = teleportOptions.ServerInstanceId
				if instanceId and tostring(instanceId) ~= "" then
					params.gameInstanceId = tostring(instanceId)
				end
			end)
			pcall(function()
				const accessCode = teleportOptions.ReservedServerAccessCode
				if accessCode and tostring(accessCode) ~= "" then
					params.reservedServerAccessCode = tostring(accessCode)
				end
			end)
		end
	end
	if type(meta.experienceParams) == "table" then
		for key, value in meta.experienceParams do
			if value ~= nil then
				params[key] = value
			end
		end
	end
	if next(params) == nil then
		return nil
	end
	return params
end

NAmanage.RegisterTeleportFallback = NAmanage.RegisterTeleportFallback or function(method, args, meta)
	const params = NAmanage.TeleportArgsToExperienceParams(method, args, meta)
	if not params then
		return nil
	end
	const token = tostring(os.clock())..":"..tostring(math.random(1, 1e9))
	NAStuff.TeleportExperienceFallback = {
		token = token;
		params = params;
		opts = type(meta) == "table" and {
			placeName = meta.placeName;
			action = meta.action;
			detail = meta.detail;
			source = meta.source;
			callback = meta.callback;
		} or {};
		method = method;
		startedAt = os.clock();
	}
	task.delay(35, function()
		const pending = NAStuff.TeleportExperienceFallback
		if pending and pending.token == token then
			NAStuff.TeleportExperienceFallback = nil
		end
	end)
	return token
end

NAmanage.TryExperienceFallback = NAmanage.TryExperienceFallback or function(reason, expectedToken)
	const pending = NAStuff.TeleportExperienceFallback
	if type(pending) ~= "table" then
		return false, "No pending ExperienceService fallback"
	end
	if expectedToken and pending.token ~= expectedToken then
		return false, "Teleport fallback token changed"
	end
	if os.clock() - (tonumber(pending.startedAt) or 0) > 35 then
		NAStuff.TeleportExperienceFallback = nil
		return false, "Teleport fallback expired"
	end
	NAStuff.TeleportExperienceFallback = nil
	const opts = type(pending.opts) == "table" and pending.opts or {}
	if reason and tostring(reason) ~= "" then
		opts.detail = opts.detail and (tostring(opts.detail).." | TeleportService failed") or "TeleportService failed"
	end
	local ok, result = NAmanage.ExperienceServiceLaunch(pending.params, opts)
	if ok then
		DebugNotif("TeleportService failed; ExperienceService fallback launched.", 3)
		return true, result
	end
	return false, result
end

NAmanage.LaunchExperience = function(params, opts)
	return NAmanage.ExperienceServiceLaunch(params, opts)
end

NAmanage.ExperienceDebugValue = NAmanage.ExperienceDebugValue or function(value, depth, seen)
	depth = depth or 0
	if depth > 2 then return "..." end
	const valueType = typeof(value)
	if valueType ~= "table" then
		return tostring(value)
	end
	seen = seen or {}
	if seen[value] then return "<cycle>" end
	seen[value] = true
	const parts = {}
	local count = 0
	for key, inner in value do
		count += 1
		if count > 10 then
			parts[#parts + 1] = "..."
			break
		end
		parts[#parts + 1] = tostring(key).."="..NAmanage.ExperienceDebugValue(inner, depth + 1, seen)
	end
	seen[value] = nil
	return "{"..Concat(parts, ", ").."}"
end

NAmanage.ExperienceDebugSnapshot = NAmanage.ExperienceDebugSnapshot or function(label)
	local service = Services.ExperienceService
	if not service then
		local ok, resolved = pcall(function()
			return game.ExperienceService or game:GetService("ExperienceService")
		end)
		if ok and resolved then
			Services.ExperienceService = resolved
			service = resolved
		end
	end
	if not service then
		DebugNotif((label or "ExperienceService")..": unavailable", 4)
		return false
	end
	const parts = {}
	const probes = {
		{"state", "GetPlaceJoinState"},
		{"queue", "GetQueuePosition"},
		{"pending", "GetPendingJoinAttempt"},
		{"followUserId", "GetFollowUserId"},
	}
	for _, probe in probes do
		const key, method = probe[1], probe[2]
		const fn = service[method]
		if type(fn) == "function" then
			local ok, value = pcall(function()
				return fn(service)
			end)
			parts[#parts + 1] = key.."="..(ok and NAmanage.ExperienceDebugValue(value) or ("ERR:"..tostring(value)))
		end
	end
	local text = (label or "ExperienceService")..": "..(#parts > 0 and Concat(parts, " | ") or "no readable state")
	if text:find("queue=-1", 1, true) then
		text = text.." | queue=-1 means no queue position reported"
	end
	DebugNotif(text, 6)
	return true, text
end

NAmanage.ExperienceDebugRecord = NAmanage.ExperienceDebugRecord or function(name, valuesText)
	NAStuff.ExperienceDebugEvents = NAStuff.ExperienceDebugEvents or {}
	const events = NAStuff.ExperienceDebugEvents
	events[#events + 1] = {
		t = os.clock(),
		name = tostring(name or ""),
		values = tostring(valuesText or ""),
	}
	while #events > 20 do
		table.remove(events, 1)
	end
end

NAmanage.ExperienceDebugConnect = NAmanage.ExperienceDebugConnect or function()
	if NAStuff.ExperienceDebugConnected then
		return true
	end
	local service = Services.ExperienceService
	if not service then
		pcall(function()
			service = game.ExperienceService or game:GetService("ExperienceService")
		end)
		if service then Services.ExperienceService = service end
	end
	if not service then
		DebugNotif("ExperienceService debug unavailable", 4)
		return false
	end
	NAStuff.ExperienceDebugConnected = true
	const function dbg(name, ...)
		const values = {}
		for i = 1, select("#", ...) do
			values[#values + 1] = NAmanage.ExperienceDebugValue(select(i, ...))
		end
		const valuesText = Concat(values, " | ")
		NAmanage.ExperienceDebugRecord(name, valuesText)
		DebugNotif("[ExperienceDebug] "..name..": "..valuesText, 6)
	end
	const eventNames = {"OnNewJoinAttempt", "PlaceJoinStateChanged", "QueuePositionChanged", "OnCrossExperienceStarted", "OnCrossExperienceStopped"}
	for _, eventName in eventNames do
		const event = service[eventName]
		if event and event.Connect then
			pcall(function()
				NAlib.connect("experience_debug_"..eventName, event:Connect(function(...)
					dbg(eventName, ...)
				end))
			end)
		end
	end
	const registerNames = {"RegisterForExperienceJoin", "RegisterForExperienceLeave"}
	for _, methodName in registerNames do
		const fn = service[methodName]
		if type(fn) == "function" then
			pcall(function()
				const conn = fn(service, function(...)
					dbg(methodName, ...)
				end)
				if conn and conn.Disconnect then
					NAlib.connect("experience_debug_"..methodName, conn)
				end
			end)
		end
	end
	if Services.LogService and Services.LogService.MessageOut then
		pcall(function()
			NAlib.connect("experience_debug_log", Services.LogService.MessageOut:Connect(function(message, messageType)
				const lowerMessage = Lower(tostring(message or ""))
				if lowerMessage:find("experience") or lowerMessage:find("launch") or lowerMessage:find("queue") or lowerMessage:find("notificationtype") then
					dbg("LogService", tostring(message), tostring(messageType))
				end
			end))
		end)
	end
	DebugNotif("ExperienceService debug hooks enabled.", 4)
	NAmanage.ExperienceDebugSnapshot("ExperienceDebug connected")
	return true
end

NAmanage.GetDataPingStat = NAmanage.GetDataPingStat or function()
	local ok, pingStat = pcall(function()
		if not Services.Stats then
			return nil
		end

		const network = Services.Stats:FindFirstChild("Network")
		if not network then
			return nil
		end

		const serverStats = network:FindFirstChild("ServerStatsItem")
		if serverStats then
			const nested = serverStats:FindFirstChild("Data Ping")
			if nested then
				return nested
			end
		end

		return network:FindFirstChild("Data Ping")
	end)

	if ok then
		return pingStat
	end

	return nil
end

NAmanage.GetDataPingMs = NAmanage.GetDataPingMs or function()
	const pingStat = NAmanage.GetDataPingStat()
	if not pingStat then
		return nil
	end

	local okValue, value = pcall(function()
		if pingStat.GetValue then
			return pingStat:GetValue()
		end
	end)
	if okValue and type(value) == "number" then
		return math.max(0, math.floor(value + 0.5))
	end

	local okString, str = pcall(function()
		if pingStat.GetValueString then
			return pingStat:GetValueString()
		end
	end)
	if okString and type(str) == "string" then
		const num = tonumber((str:gsub("[^%d%.]", "")))
		if num then
			return math.max(0, math.floor(num + 0.5))
		end
	end

	return nil
end

NAmanage.GetDataPingText = NAmanage.GetDataPingText or function()
	const pingStat = NAmanage.GetDataPingStat()
	if not pingStat then
		return nil
	end

	const ms = NAmanage.GetDataPingMs()
	if type(ms) == "number" then
		return Format("%d ms", math.floor(ms + 0.5)), ms
	end

	local okString, str = pcall(function()
		if pingStat.GetValueString then
			return pingStat:GetValueString()
		end
	end)
	if okString and type(str) == "string" and str ~= "" then
		return str, nil
	end

	return nil
end

NAmanage.StreamerEscapePattern = NAmanage.StreamerEscapePattern or function(value)
	value = tostring(value or "")
	return value:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
end

NAmanage.StreamerGetState = NAmanage.StreamerGetState or function()
	local state = NAStuff and NAStuff.StreamerModeState
	if type(state) ~= "table" then
		state = {
			cache = {};
			nameTokens = {};
			token = nil;
			restoreToken = nil;
			applied = false;
			scrubBusy = false;
		}
		NAStuff.StreamerModeState = state
	end
	if type(state.cache) ~= "table" then
		state.cache = {}
	end
	state.cache = NAmanage.ensureWeakTable(state.cache, "k")
	if type(state.nameTokens) ~= "table" then
		state.nameTokens = {}
	end
	return state
end

NAmanage.StreamerSetPlayerListHidden = NAmanage.StreamerSetPlayerListHidden or function(hidden)
	const state = NAmanage.StreamerGetState()
	const starterGui = Services.StarterGui or SafeGetService("StarterGui")
	if not starterGui or not Enum or not Enum.CoreGuiType or not Enum.CoreGuiType.PlayerList then
		return false
	end

	if hidden == true then
		if state.playerListOriginal == nil then
			local okEnabled, enabled = pcall(function()
				return __lt.cm("StarterGui", "GetCoreGuiEnabled", Enum.CoreGuiType.PlayerList)
			end)
			if okEnabled then
				state.playerListOriginal = enabled == true
			else
				state.playerListOriginal = true
			end
		end
		const okSet = pcall(function()
			__lt.cm("StarterGui", "SetCoreGuiEnabled", Enum.CoreGuiType.PlayerList, false)
		end)
		state.playerListHidden = okSet == true
		return okSet == true
	end

	if state.playerListOriginal ~= nil or state.playerListHidden == true then
		const restoreValue = state.playerListOriginal ~= false
		pcall(function()
			__lt.cm("StarterGui", "SetCoreGuiEnabled", Enum.CoreGuiType.PlayerList, restoreValue)
		end)
	end
	state.playerListOriginal = nil
	state.playerListHidden = nil
	return true
end

NAmanage.StreamerCacheCount = NAmanage.StreamerCacheCount or function(cache)
	local count = 0
	if type(cache) == "table" then
		for _ in cache do
			count += 1
		end
	end
	return count
end

NAmanage.StreamerIsRunActive = NAmanage.StreamerIsRunActive or function(token)
	if not (NAStuff and NAStuff.StreamerModeEnabled == true) then
		return false
	end
	if type(token) ~= "table" then
		return true
	end
	if token.cancelled then
		return false
	end
	const state = NAmanage.StreamerGetState()
	return state.token == token
end

NAmanage.StreamerGetRecord = NAmanage.StreamerGetRecord or function(inst)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const state = NAmanage.StreamerGetState()
	const cache = state.cache
	local rec = cache[inst]
	if type(rec) ~= "table" then
		rec = {}
		cache[inst] = rec
	end
	return rec
end

NAmanage.StreamerRefreshNameTokens = NAmanage.StreamerRefreshNameTokens or function()
	const state = NAmanage.StreamerGetState()
	const tokens = {}
	const seen = {}
	if Services.Players then
		for _, plr in __lt.cm("Players", "GetPlayers") do
			const names = {
				plr and plr.Name or nil,
				plr and plr.DisplayName or nil,
			}
			for i = 1, #names do
				const value = names[i]
				if type(value) == "string" and value ~= "" and not seen[value] then
					seen[value] = true
					Insert(tokens, value)
				end
			end
		end
	end
	table.sort(tokens, function(a, b)
		if #a == #b then
			return a < b
		end
		return #a > #b
	end)
	state.nameTokens = tokens
	return tokens
end

NAmanage.StreamerScheduleNameRefresh = NAmanage.StreamerScheduleNameRefresh or function(refreshCached)
	const state = NAmanage.StreamerGetState()
	if refreshCached then
		state.nameRefreshNeedsCached = true
	end
	if state.nameRefreshQueued then
		return
	end
	state.nameRefreshQueued = true
	Delay(0.05, function()
		state.nameRefreshQueued = false
		if not (NAStuff and NAStuff.StreamerModeEnabled == true) then
			state.nameRefreshNeedsCached = false
			return
		end
		NAmanage.StreamerRefreshNameTokens()
		if state.nameRefreshNeedsCached then
			state.nameRefreshNeedsCached = false
			NAmanage.StreamerRefreshCachedTargets()
		end
	end)
end

NAmanage.StreamerRefreshCachedTargets = NAmanage.StreamerRefreshCachedTargets or function()
	const state = NAmanage.StreamerGetState()
	const pending = {}
	for inst in state.cache do
		if typeof(inst) == "Instance" and inst.Parent and NAmanage.StreamerIsTarget(inst) then
			Insert(pending, inst)
		end
	end
	for i = 1, #pending do
		NAmanage.StreamerScrubInstance(pending[i])
	end
end

NAmanage.StreamerMaskText = NAmanage.StreamerMaskText or function(text)
	if text == nil then
		return nil
	end
	const source = tostring(text)
	const tokens = NAmanage.StreamerGetState().nameTokens
	if type(tokens) ~= "table" or #tokens == 0 then
		return source
	end
	local masked = source
	const replacement = tostring(NAStuff.StreamerModeText or "\0")
	for i = 1, #tokens do
		const token = tokens[i]
		if token ~= "" then
			masked = masked:gsub(NAmanage.StreamerEscapePattern(token), replacement)
		end
	end
	return masked
end

NAmanage.StreamerShouldMaskImage = NAmanage.StreamerShouldMaskImage or function(image)
	const value = Lower(tostring(image or ""))
	if value == "" then
		return false
	end
	if value:find("rbxthumb://", 1, true) then
		return true
	end
	if value:find("avatar", 1, true) or value:find("headshot", 1, true) or value:find("bust", 1, true) then
		return true
	end
	if value:find("user-thumbnail", 1, true) or value:find("thumbnail", 1, true) then
		return true
	end
	if value:find("rbxcdn.com", 1, true) and value:find("/users/", 1, true) then
		return true
	end
	return false
end

NAmanage.StreamerIsContainer = NAmanage.StreamerIsContainer or function(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	return inst:IsA("BillboardGui")
		or inst:IsA("SurfaceGui")
end

NAmanage.StreamerIsTarget = NAmanage.StreamerIsTarget or function(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	return inst:IsA("TextLabel")
		or inst:IsA("TextButton")
		or inst:IsA("TextBox")
		or inst:IsA("ImageLabel")
		or inst:IsA("ImageButton")
end

NAmanage.StreamerIsRelevant = NAmanage.StreamerIsRelevant or function(inst)
	return NAmanage.StreamerIsTarget(inst) or NAmanage.StreamerIsContainer(inst)
end

NAmanage.StreamerDisconnectConn = NAmanage.StreamerDisconnectConn or function(conn)
	if conn and type(conn.Disconnect) == "function" then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

NAmanage.StreamerWatchTarget = NAmanage.StreamerWatchTarget or function(inst)
	if not NAmanage.StreamerIsTarget(inst) then
		return
	end
	const rec = NAmanage.StreamerGetRecord(inst)
	rec.signalConns = rec.signalConns or {}
	const function bindSignal(key, signal)
		if rec.signalConns[key] then
			return
		end
		rec.signalConns[key] = signal:Connect(function()
			if NAStuff and NAStuff.StreamerModeEnabled == true then
				NAmanage.StreamerScrubInstance(inst)
			end
		end)
	end
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		bindSignal("Text", inst:GetPropertyChangedSignal("Text"))
		if inst:IsA("TextBox") then
			bindSignal("PlaceholderText", inst:GetPropertyChangedSignal("PlaceholderText"))
		end
	end
	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		bindSignal("Image", inst:GetPropertyChangedSignal("Image"))
	end
	if not rec.ancConn then
		rec.ancConn = inst.AncestryChanged:Connect(function(_, parent)
			if parent then
				return
			end
			NAmanage.StreamerRestoreInstance(inst)
		end)
	end
end

NAmanage.StreamerScanContainer = NAmanage.StreamerScanContainer or function(root, token, opts)
	if typeof(root) ~= "Instance" then
		return
	end
	if token and not NAmanage.StreamerIsRunActive(token) then
		return
	end
	opts = opts or {}
	if opts.includeRoot == true and NAmanage.StreamerIsTarget(root) then
		NAmanage.StreamerScrubInstance(root)
	end
	NAmanage.ForEachDescendantYield(root, function(inst)
		if token and not NAmanage.StreamerIsRunActive(token) then
			return
		end
		if NAmanage.StreamerIsTarget(inst) then
			NAmanage.StreamerScrubInstance(inst)
		end
	end, {
		yieldEvery = tonumber(opts.yieldEvery) or 96;
		cancelToken = token;
	})
end
