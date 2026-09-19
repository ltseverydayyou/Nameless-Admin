SpawnCall(function()
	const settingsBuildStart = os.clock()
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) == "table" then
		perf.settingsBuildStarted = settingsBuildStart
	end
	pcall(function()
		const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
		if type(probe) == "table" and type(probe.mark) == "function" then
			probe.mark("settings_build_start")
		end
	end)
	local okBuild, errBuild = pcall(function()
NAgui.addTab(NA_TABS.TAB_ALL, { default = true, order = 0, textIcon = "grid" })
NAgui.addTab(NA_TABS.TAB_GENERAL, { order = 1, textIcon = "gear" })
NAgui.addTab(NA_TABS.TAB_AUTOMATION, { order = 2, textIcon = "cube-vertexes" })
NAgui.addTab(NA_TABS.TAB_MANAGEMENT, { order = 3, textIcon = "nebula" })
NAgui.addTab(NA_TABS.TAB_SAVE_INSTANCE, { order = 3.5, textIcon = "arrow-down-to-line" })
NAgui.addTab(NA_TABS.TAB_ENGINE_SETTINGS, { order = 4.5, textIcon = "three-sliders-horizontal" })
NAgui.setTab(NA_TABS.TAB_GENERAL)

NAgui.addSection("Prefix Settings")

NAgui.prfxKeyNaem=function(keyName)
	if type(keyName) ~= "string" or keyName == "" then
		return nil
	end
	const clean = keyName:match("^%s*(.-)%s*$")
	if not clean or clean == "" then
		return nil
	end
	if #clean == 1 then
		return clean
	end
	const lower = Lower(clean)
	const aliases = NAStuff.prefixKeyAliasMap or {}
	for char, alias in aliases do
		if type(alias) == "string" and Lower(alias) == lower then
			return char
		end
	end
	const digits = {
		zero = "0", one = "1", two = "2", three = "3", four = "4",
		five = "5", six = "6", seven = "7", eight = "8", nine = "9",
	}
	if digits[lower] then
		return digits[lower]
	end
	return clean
end

NAgui.addKeybind("Prefix", opt.prefix, function(keyName)
	if type(keyName) ~= "string" or keyName == "" then
		return
	end
	const newPrefix = NAgui.prfxKeyNaem(keyName)
	if not newPrefix or newPrefix == "" then
		DoNotif("Please enter a valid prefix")
		if NAmanage.SyncPrefixUI then
			NAmanage.SyncPrefixUI({ force = true, fire = false })
		end
		return
	end
	if NAgui.badPfx(newPrefix) then
		if utf8.len(newPrefix) > 1 then
			DoNotif("Prefix must be a single character (e.g. ; . !)")
		elseif newPrefix:match("[%w]") then
			DoNotif("Prefix cannot contain letters or numbers")
		elseif newPrefix:match("[%[%]%(%)%*%^%$%%{}<>]") then
			DoNotif("That symbol is not allowed as a prefix")
		elseif newPrefix:match("&amp;") or newPrefix:match("&lt;") or newPrefix:match("&gt;")
			or newPrefix:match("&quot;") or newPrefix:match("&#x27;") or newPrefix:match("&#x60;") then
			DoNotif("Encoded/HTML characters are not allowed as a prefix")
		else
			DoNotif("Please enter a valid prefix")
		end
		if NAmanage.SyncPrefixUI then
			NAmanage.SyncPrefixUI({ force = true, fire = false })
		end
		return
	end

	opt.prefix = newPrefix
	DoNotif("Prefix set to: "..newPrefix)
	if NAmanage.SyncPrefixUI then
		NAmanage.SyncPrefixUI()
	end
end)

if FileSupport then
	NAgui.addButton("Save Prefix", function()
		NAmanage.NASettingsSet("prefix", opt.prefix)
		DoNotif("Prefix saved to settings file: "..NAfiles.NAMAINSETTINGSPATH)
	end)
end

NAgui.addSection("UI Settings")

NAgui.addInput("UI Scale", "0.5 - 2.5", Format("%.2f", NAmanage.ClampUIScale(NAUIScale, 1)), function(text)
	const parsed = tonumber(text)
	if not parsed then
		DoNotif("UI Scale must be a number between 0.5 and 2.5", 2)
		if NAmanage.SyncUIScaleUI then
			NAmanage.SyncUIScaleUI({ force = true })
		end
		return
	end

	const clamped = NAmanage.ApplyUIScale(parsed, { save = true, syncUI = false })
	if clamped ~= parsed then
		DoNotif("UI Scale clamped to "..Format("%.2f", clamped), 2)
	else
		DoNotif("UI Scale set to "..Format("%.2f", clamped), 2)
	end

	if NAmanage.SyncUIScaleUI then
		NAmanage.SyncUIScaleUI({ value = clamped, force = true })
	end
end)
NAgui.addToggle("Legacy Horizontal Settings Tabs", NAStuff.LegacyHorizontalSettingsTabs == true, function(v)
	const enabled = NAmanage.SetHorizontalSettingsTabs and NAmanage.SetHorizontalSettingsTabs(v, { save = true }) or (v == true)
	DoNotif("Settings tabs changed to "..(enabled and "horizontal" or "vertical sidebar"), 2)
end)
NAmanage.RegisterToggleAutoSync("Legacy Horizontal Settings Tabs", function()
	return NAStuff.LegacyHorizontalSettingsTabs == true
end)

NAgui.addToggle("Low-End UI Mode", NAStuff.LowEndMode == true, function(v)
	NAStuff.LowEndMode = v == true
	pcall(NAmanage.NASettingsSet, "lowEndUiMode", NAStuff.LowEndMode)
	if NAmanage.InstallUIVisibilityOptimizer then pcall(NAmanage.InstallUIVisibilityOptimizer) end
	DoNotif("Low-End UI Mode "..(NAStuff.LowEndMode and "enabled" or "disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Low-End UI Mode", function() return NAStuff.LowEndMode == true end)

NAgui.addToggle("Custom Teleport Loading Screen", NAStuff.CustomTeleportGuiEnabled ~= false, function(v)
	NAStuff.CustomTeleportGuiEnabled = v ~= false
	pcall(NAmanage.NASettingsSet, "customTeleportGui", NAStuff.CustomTeleportGuiEnabled)
	if not NAStuff.CustomTeleportGuiEnabled then
		if type(NAmanage.GameTeleportGui_Disarm) == "function" then pcall(NAmanage.GameTeleportGui_Disarm) end
		if type(NAmanage.TeleportGui_Clear) == "function" then pcall(NAmanage.TeleportGui_Clear) end
	elseif NAStuff.CustomTeleportGuiGameTeleportsEnabled == true and type(NAmanage.GameTeleportGui_Arm) == "function" then
		pcall(NAmanage.GameTeleportGui_Arm)
	end
	DoNotif("Custom teleport loading screen "..(NAStuff.CustomTeleportGuiEnabled and "enabled" or "disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Custom Teleport Loading Screen", function()
	return NAStuff.CustomTeleportGuiEnabled ~= false
end)

NAgui.addToggle("Use Custom UI on Game Teleports", NAStuff.CustomTeleportGuiGameTeleportsEnabled == true, function(v)
	NAStuff.CustomTeleportGuiGameTeleportsEnabled = v == true
	pcall(NAmanage.NASettingsSet, "customTeleportGuiGameTeleports", NAStuff.CustomTeleportGuiGameTeleportsEnabled)
	if NAStuff.CustomTeleportGuiGameTeleportsEnabled then
		pcall(NAmanage.GameTeleportGui_Arm)
	elseif type(NAmanage.GameTeleportGui_Disarm) == "function" then
		pcall(NAmanage.GameTeleportGui_Disarm)
	end
	DoNotif("Custom UI on game teleports "..(NAStuff.CustomTeleportGuiGameTeleportsEnabled and "enabled" or "disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Use Custom UI on Game Teleports", function()
	return NAStuff.CustomTeleportGuiGameTeleportsEnabled == true
end)

NAgui.addSection("Admin Utility")

NAgui.addToggle("Keep "..adminName, NAQoTEnabled, function(val)
	NAQoTEnabled = val
	NAmanage.NASettingsSet("queueOnTeleport", val)
	if NAQoTEnabled then
		DoNotif(adminName.." will now auto-load after teleport (QueueOnTeleport enabled)", 3)
	else
		DoNotif("QueueOnTeleport has been disabled. "..adminName.." will no longer auto-run after teleport", 3)
	end
end)
NAmanage.RegisterToggleAutoSync("Keep "..adminName, function()
	return NAQoTEnabled == true
end)

NAgui.addToggle("Hide NA Icon", NAStuff.IconInvisible, function(v)
	NAmanage.IconSetInvisible(v, { skipToggle = true, force = true })
	DoNotif("Icon Visibility is "..(v and "Off" or "On"), 2)
end)
NAmanage.RegisterToggleAutoSync("Hide NA Icon", function()
	return NAStuff.IconInvisible == true
end)

NAgui.addToggle("Lock NA Icon", NAStuff.IconLocked, function(v)
	NAgui.setIconLocked(v, { force = true, skipToggle = true })
	DoNotif("Icon Position is "..(v and "Locked" or "Unlocked"), 2)
end)
NAmanage.RegisterToggleAutoSync("Lock NA Icon", function()
	return NAStuff.IconLocked == true
end)

NAgui.addToggle("Command Predictions Prompt", doPREDICTION, function(v)
	doPREDICTION = v
	DoNotif("Command Predictions "..(v and "Enabled" or "Disabled"), 2)
	NAmanage.NASettingsSet("prediction", v)
end)
NAmanage.RegisterToggleAutoSync("Command Predictions Prompt", function()
	return doPREDICTION == true
end)

NAgui.addToggle("Legacy Command Input & Autofill", NAStuff.LegacyCommandUI == true, function(v)
	NAmanage.SetLegacyCommandUI(v == true, {
		save = true;
		notify = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Legacy Command Input & Autofill", function()
	return NAStuff.LegacyCommandUI == true
end)

NAgui.addToggle("Hide Command Autofill List", NAStuff.HideCmdAutofill == true, function(v)
	NAmanage.SetCmdAutofillHidden(v == true, {
		save = true;
		notify = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Hide Command Autofill List", function()
	return NAStuff.HideCmdAutofill == true
end)

NAgui.addToggle("SFW Mode", NAStuff.SFWMode ~= false, function(v)
	NAmanage.SetSFWMode(v ~= false, {
		save = true;
		notify = true;
		refresh = true;
	})
end)
NAmanage.RegisterToggleAutoSync("SFW Mode", function()
	return NAStuff.SFWMode ~= false
end)

NAgui.addToggle("Safe Command Input", NAStuff.CmdInputSafeMode ~= false, function(v)
	NAmanage.SetCmdInputSafeMode(v ~= false, {
		save = true;
		notify = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Safe Command Input", function()
	return NAStuff.CmdInputSafeMode ~= false
end)

NAmanage.ApplyStandaloneFFlag = NAmanage.ApplyStandaloneFFlag or function(flagName, flagValue, opts)
	opts = opts or {}
	local setter = nil
	if type(setfflag) == "function" then
		setter = setfflag
	elseif game and type(game.DefineFastFlag) == "function" then
		setter = function(name, value)
			return game:DefineFastFlag(name, value)
		end
	end

	if not setter then
		if not opts.silent then
			DoNotif("FastFlag changes are unavailable on this executor.", 3)
		end
		return false, "unsupported"
	end

	local ok, err = pcall(setter, flagName, tostring(flagValue))
	if not ok then
		if not opts.silent then
			DoNotif("Failed to set "..tostring(flagName)..".", 3)
		end
		return false, err
	end

	return true
end

NAgui.addToggle("Hide Purchase Prompt GUI", NAStuff.PurchasePromptsDisabled == true, function(v)
	NAStuff.PurchasePromptsDisabled = v == true
	pcall(NAmanage.NASettingsSet, "purchasePromptsDisabled", NAStuff.PurchasePromptsDisabled)
	NAmanage.nuhuhprompt(not NAStuff.PurchasePromptsDisabled)
	DoNotif("Purchase prompt GUI "..(NAStuff.PurchasePromptsDisabled and "hidden" or "visible"), 2)
end)
NAmanage.RegisterToggleAutoSync("Hide Purchase Prompt GUI", function()
	return NAStuff.PurchasePromptsDisabled == true
end)

NAmanage.SetOrder66PurchaseBlock = NAmanage.SetOrder66PurchaseBlock or function(enabled, opts)
	return NAmanage.ApplyStandaloneFFlag("Order66", enabled == true, opts)
end

NAmanage.SetOrder66PurchaseBlock(NAStuff.Order66PurchaseBlock == true, { silent = true })
NAgui.addToggle("Block Robux Purchases", NAStuff.Order66PurchaseBlock == true, function(v)
	const enabled = v == true
	local ok = NAmanage.SetOrder66PurchaseBlock(enabled)
	if not ok then
		return
	end
	NAStuff.Order66PurchaseBlock = enabled
	pcall(NAmanage.NASettingsSet, "order66PurchaseBlock", enabled)
	DoNotif("Robux purchases "..(enabled and "blocked" or "allowed"), 2)
end)
NAmanage.RegisterToggleAutoSync("Block Robux Purchases", function()
	return NAStuff.Order66PurchaseBlock == true
end)

NAgui.addToggle("Disable Network Pause", NAStuff.NetworkPauseDisabled == true, function(v)
	NAStuff.NetworkPauseDisabled = v == true
	pcall(NAmanage.NASettingsSet, "networkPauseDisabled", NAStuff.NetworkPauseDisabled)
	NAmanage.setNetworkPauseBlocked(NAStuff.NetworkPauseDisabled)
	DoNotif("Network pause UI "..(NAStuff.NetworkPauseDisabled and "blocked" or "allowed"), 2)
end)
NAmanage.RegisterToggleAutoSync("Disable Network Pause", function()
	return NAStuff.NetworkPauseDisabled == true
end)

const function buildEngineSettingsControls()
	NAgui.addSection("Roblox Engine Settings")

	NAgui.addSection("Visual Effects")
	NAgui.addInfo("Fast Particle Effects Info", "Makes particles, smoke, fire, beams, and similar effects update faster and more repetitively. This changes effect behavior; it is not a general FPS booster.")
	NAmanage.SetFastParticleEffects = NAmanage.SetFastParticleEffects or function(enabled, opts)
		return NAmanage.ApplyStandaloneFFlag("DebugRenderingSetDeterministic", enabled == true, opts)
	end
	NAmanage.SetFastParticleEffects(NAStuff.FastParticleEffects == true, { silent = true })
	NAgui.addToggle("Fast Particle Effects", NAStuff.FastParticleEffects == true, function(v)
		const enabled = v == true
		const ok = NAmanage.SetFastParticleEffects(enabled)
		if not ok then
			return
		end
		NAStuff.FastParticleEffects = enabled
		pcall(NAmanage.NASettingsSet, "fastParticleEffects", enabled)
		DoNotif("Fast particle effects "..(enabled and "enabled" or "disabled"), 2)
	end)
	NAmanage.RegisterToggleAutoSync("Fast Particle Effects", function()
		return NAStuff.FastParticleEffects == true
	end)

	const function engineBoolValue(entry)
		return NAmanage.EngineSettings.get(entry.service, entry.property, false) == true
	end

	for _, entry in NAmanage.EngineSettings.boolCommands or {} do
		NAmanage.MarkExternalLagProbe("settings_engine_bool:"..tostring(entry.label or entry.property or "?"))
		NAgui.addToggle(entry.label, engineBoolValue(entry), function(v)
			NAmanage.EngineSettings.setBool(entry, v == true)
		end)
		NAmanage.RegisterToggleAutoSync(entry.label, function()
			return engineBoolValue(entry)
		end)
	end

	NAgui.addSection("Engine Number Settings")
	for _, entry in NAmanage.EngineSettings.numberCommands or {} do
		NAmanage.MarkExternalLagProbe("settings_engine_number:"..tostring(entry.label or entry.property or "?"))
		NAgui.addInput(entry.label, entry.usage or "number", tostring(NAmanage.EngineSettings.get(entry.service, entry.property, 0) or 0), function(text)
			NAmanage.EngineSettings.setNumber(entry, text)
		end)
	end

	NAgui.addInput("Incoming Replication Lag", "seconds", tostring(NAmanage.EngineSettings.get("NetworkSettings", "IncomingReplicationLag", 0) or 0), function(text)
		const n = tonumber(text)
		if not n then
			DoNotif("Incoming Replication Lag must be a number", 2)
			return
		end
		NAmanage.EngineSettings.setAndSave("NetworkSettings", "IncomingReplicationLag", math.max(0, n), "Incoming Replication Lag")
	end)

	NAgui.addInput("Physics Environmental Throttle", "1 default, 2 disabled", tostring(NAmanage.EngineSettings.get("PhysicsSettings", "PhysicsEnvironmentalThrottle", 1) or 1), function(text)
		const n = tonumber(text)
		if not n then
			DoNotif("Physics Environmental Throttle must be a number", 2)
			return
		end
		NAmanage.EngineSettings.setAndSave("PhysicsSettings", "PhysicsEnvironmentalThrottle", n, "Physics Environmental Throttle")
	end)

	NAgui.addButton("Reload Render Assets", function()
		NAmanage.EngineSettings.set("RenderSettings", "ReloadAssets", true, "Reload Assets")
	end)

	NAgui.addButton("Show Engine Settings Info", function()
		cmd.run({"enginesettingsinfo"})
	end)
end

NAgui.setTab(NA_TABS.TAB_ENGINE_SETTINGS)
buildEngineSettingsControls()

NAgui.setTab(NA_TABS.TAB_GENERAL)
NAgui.addToggle("Disable Unsafe Functions", NAStuff.UnsafeFunctionsDisabled == true, function(v)
	pcall(NAmanage.SetUnsafeFunctionsDisabled, v == true, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Disable Unsafe Functions", function()
	return NAStuff.UnsafeFunctionsDisabled == true
end)

NAgui.addToggle("Disable Virtual Input API", NAStuff.VirtualInputAPIDisabled == true, function(v)
	pcall(NAmanage.SetVirtualInputAPIDisabled, v == true, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Disable Virtual Input API", function()
	return NAStuff.VirtualInputAPIDisabled == true
end)

NAgui.addToggle("Disable HWID functions", NAStuff.HWIDFunctionsDisabled == true, function(v)
	pcall(NAmanage.SetHWIDFunctionsDisabled, v == true, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Disable HWID functions", function()
	return NAStuff.HWIDFunctionsDisabled == true
end)

NAgui.addToggle("Spoof HWID", NAStuff.HWIDSpoofEnabled == true, function(v)
	pcall(NAmanage.SetHWIDSpoofEnabled, v == true, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Spoof HWID", function()
	return NAStuff.HWIDSpoofEnabled == true
end)

NAgui.addInput("Spoofed HWID", "Custom HWID value", tostring(NAStuff.HWIDSpoofValue or ""), function(text)
	pcall(NAmanage.SetHWIDSpoofValue, text, {
		save = true;
	})
end)

NAgui.addToggle("Spoof Client ID", NAStuff.ClientIDSpoofEnabled == true, function(v)
	pcall(NAmanage.SetClientIDSpoofEnabled, v == true, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Spoof Client ID", function()
	return NAStuff.ClientIDSpoofEnabled == true
end)

NAgui.addInput("Spoofed Client ID", "Custom RbxAnalyticsService Client ID", tostring(NAStuff.ClientIDSpoofValue or ""), function(text)
	pcall(NAmanage.SetClientIDSpoofValue, text, {
		save = true;
	})
end)
NAgui.addInfo("Client ID Spoof Warning", "Spoof Client ID hooks only RbxAnalyticsService:GetClientId(). The targeted hook may still be detectable by games or anti-cheat systems.")

NAgui.addToggle("Syn env", NAStuff.SynEnvEnabled == true, function(v)
	pcall(NAmanage.SetSynEnv, v == true, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Syn env", function()
	return NAStuff.SynEnvEnabled == true
end)

NAgui.addToggle("Force rconsole To NA Console", NAStuff.ForceRconsoleNAConsole ~= false, function(v)
	pcall(NAmanage.SetForceRconsoleNAConsole, v ~= false, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Force rconsole To NA Console", function()
	return NAStuff.ForceRconsoleNAConsole ~= false
end)

NAgui.addToggle("Auto-dismiss Friend Requests", NAStuff.FriendRequestAutoDismiss == true, function(v)
	NAStuff.FriendRequestAutoDismiss = v == true
	pcall(NAmanage.NASettingsSet, "friendRequestAutoDismiss", NAStuff.FriendRequestAutoDismiss)
	NAmanage.setFriendRequestAutoDismiss(NAStuff.FriendRequestAutoDismiss)
	DoNotif("Friend request popups "..(NAStuff.FriendRequestAutoDismiss and "auto-dismissed" or "shown"), 2)
end)
NAmanage.RegisterToggleAutoSync("Auto-dismiss Friend Requests", function()
	return NAStuff.FriendRequestAutoDismiss == true
end)

NAgui.addToggle("Streamer Mode", NAStuff.StreamerModeEnabled == true, function(v)
	NAmanage.setStreamerMode(v == true, {
		save = true;
	})
end)
NAmanage.RegisterToggleAutoSync("Streamer Mode", function()
	return NAStuff.StreamerModeEnabled == true
end)

NAgui.addToggle("Debug Notifications", NAStuff.nuhuhNotifs, function(v)
	NAStuff.nuhuhNotifs = v
	DoNotif("Debug Notifications "..(v and "Enabled" or "Disabled"), 2)
	NAmanage.NASettingsSet("notifsToggle", v)
end)
NAmanage.RegisterToggleAutoSync("Debug Notifications", function()
	return NAStuff.nuhuhNotifs == true
end)

NAgui.addToggle("Run AutoExec on Start", NAStuff.AutoExecEnabled ~= false, function(v)
	NAStuff.AutoExecEnabled = v
	NAmanage.NASettingsSet("autoExecEnabled", v)
	DoNotif("AutoExec "..(v and "will run on start" or "is disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Run AutoExec on Start", function()
	return NAStuff.AutoExecEnabled ~= false
end)

NAgui.addToggle("Run UserButtons on Start", NAStuff.UserButtonsAutoLoad ~= false, function(v)
	NAStuff.UserButtonsAutoLoad = v
	NAmanage.NASettingsSet("userButtonsAutoLoad", v)
	DoNotif("User buttons "..(v and "will load on start" or "will not auto-load on start"), 2)
end)
NAmanage.RegisterToggleAutoSync("Run UserButtons on Start", function()
	return NAStuff.UserButtonsAutoLoad ~= false
end)

NAgui.addToggle("Auto Skip Loading Screen", NAmanage.getAutoSkipPreference(), function(v)
	NAmanage.setAutoSkipPreference(v)
	DoNotif("Auto skip loading screen "..(v and "enabled" or "disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Auto Skip Loading Screen", function()
	return NAmanage.getAutoSkipPreference() == true
end)

NAgui.addToggle("Hide Startup", type(NAmanage.getHideStartupPreference) == "function" and NAmanage.getHideStartupPreference() == true, function(v)
	NAmanage.setHideStartupPreference(v)
	DoNotif("Startup UI "..(v and "will be hidden on next run" or "will show on next run"), 2)
end)
NAmanage.RegisterToggleAutoSync("Hide Startup", function()
	return type(NAmanage.getHideStartupPreference) == "function" and NAmanage.getHideStartupPreference() == true
end)

if type(NAmanage.isDeltaExecutor) == "function" and NAmanage.isDeltaExecutor(true) then
	NAgui.addToggle("Delta Reminder", NAStuff.deltaPrompted ~= true, function(state)
		if state then
			if NAStuff.deltaPrompted ~= true then
				DoNotif("Delta customization reminder is already enabled. The popup will appear soon.", 3)
				Defer(function()
					Wait(0.1)
					NAmanage.deltaPopup()
				end)
				return
			end
			NAStuff.deltaPrompted = false
			pcall(NAmanage.NASettingsSet, "deltaPrompted", false)
			DoNotif("Delta customization reminder re-enabled. It will show again shortly and this toggle will switch off afterwards.", 4)
			Defer(function()
				Wait(0.1)
				NAmanage.deltaPopup()
			end)
		else
			NAStuff.deltaPrompted = true
			pcall(NAmanage.NASettingsSet, "deltaPrompted", true)
			DoNotif("Delta customization reminder disabled.", 3)
		end
	end)
	NAmanage.RegisterToggleAutoSync("Delta Reminder", function()
		return NAStuff.deltaPrompted ~= true
	end)
end

NAgui.addToggle("Loading Mode (Tray)", NALoadingStartMinimized, function(v)
	NALoadingStartMinimized = v and true or false
	NAmanage.NASettingsSet("loadingStartMinimized", NALoadingStartMinimized)
	NAAssetsLoading.applyMinimizedPreference()
	DoNotif("Loading screen will start "..(NALoadingStartMinimized and "in tray" or "expanded"), 2)
end)
NAmanage.RegisterToggleAutoSync("Loading Mode (Tray)", function()
	return NALoadingStartMinimized == true
end)

NAgui.addToggle("Keep Icon Position", NAiconSaveEnabled, function(v)
	local pos = NAgui.getClampedIconPosition() or TextButton.Position
	if v then
		TextButton.Position = pos
	else
		pos = NAgui.clampIconPositionUDim(UDim2.new(0.5, 0, 0.1, 0))
	end
	pcall(NAmanage.NASettingsSet, "iconPosition", {
		X = pos.X.Scale;
		Y = pos.Y.Scale;
	})
	pcall(NAmanage.NASettingsSet, "iconKeepPosition", v == true)
	NAiconSaveEnabled = v == true
	DoNotif("Icon position "..(v and "will be saved" or "won't be saved").." on exit", 2)
end)
NAmanage.RegisterToggleAutoSync("Keep Icon Position", function()
	return NAiconSaveEnabled == true
end)

NAgui.addSection("Dev Console")

NAStuff.DevConsoleControlsBuilt = false
const function buildDevConsoleControls()
	if NAStuff.DevConsoleControlsBuilt == true then
		return
	end
	NAStuff.DevConsoleControlsBuilt = true
	NAmanage.MarkExternalLagProbe("settings_general_devconsole_toggle_copy")
	NAgui.addToggle("Dev Console Copy Buttons", NAStuff.RobloxDevConsoleCopyButtonsEnabled ~= false, function(v)
		NAStuff.RobloxDevConsoleCopyButtonsEnabled = v ~= false
		pcall(NAmanage.NASettingsSet, "devConsoleCopyButtons", NAStuff.RobloxDevConsoleCopyButtonsEnabled)
		NAmanage.refreshDevConsoleFeatures()
	end)
	NAmanage.RegisterToggleAutoSync("Dev Console Copy Buttons", function()
		return NAStuff.RobloxDevConsoleCopyButtonsEnabled ~= false
	end)

	NAmanage.MarkExternalLagProbe("settings_general_devconsole_toggle_master")
	NAgui.addToggle("NA Console Master Input", NAStuff.NAConsoleMasterEnabled ~= false, function(v)
		NAStuff.NAConsoleMasterEnabled = v ~= false
		pcall(NAmanage.NASettingsSet, "devConsoleMasterInput", NAStuff.NAConsoleMasterEnabled)
		NAmanage.refreshDevConsoleFeatures()
	end)
	NAmanage.RegisterToggleAutoSync("NA Console Master Input", function()
		return NAStuff.NAConsoleMasterEnabled ~= false
	end)

	NAmanage.MarkExternalLagProbe("settings_general_devconsole_slider_log_buffer")
	NAgui.addSlider("NA Console Log Buffer", 200, 5000, NAStuff.DevConsoleLogLimit or 1200, 50, " logs", function(v)
		NAStuff.DevConsoleLogLimit = math.clamp(math.floor((tonumber(v) or 1200) + 0.5), 200, 5000)
		pcall(NAmanage.NASettingsSet, "devConsoleLogLimit", NAStuff.DevConsoleLogLimit)
		pcall(NAmanage.bindToDevConsole)
	end)

	NAmanage.MarkExternalLagProbe("settings_general_devconsole_slider_queue")
	NAgui.addSlider("NA Console Queue Limit", 100, 4000, NAStuff.DevConsoleQueueLimit or 600, 50, " pending", function(v)
		NAStuff.DevConsoleQueueLimit = math.clamp(math.floor((tonumber(v) or 600) + 0.5), 100, 4000)
		pcall(NAmanage.NASettingsSet, "devConsoleQueueLimit", NAStuff.DevConsoleQueueLimit)
		pcall(NAmanage.bindToDevConsole)
	end)

	NAgui.addToggle("NA Console Timestamps", NAStuff.DevConsoleTimestamps ~= false, function(v)
		NAStuff.DevConsoleTimestamps = v ~= false
		pcall(NAmanage.NASettingsSet, "devConsoleTimestamps", NAStuff.DevConsoleTimestamps)
		pcall(NAmanage.bindToDevConsole)
	end)
	NAmanage.RegisterToggleAutoSync("NA Console Timestamps", function() return NAStuff.DevConsoleTimestamps ~= false end)

	NAgui.addToggle("NA Console Collapse Duplicates", NAStuff.DevConsoleCollapseDuplicates ~= false, function(v)
		NAStuff.DevConsoleCollapseDuplicates = v ~= false
		pcall(NAmanage.NASettingsSet, "devConsoleCollapseDuplicates", NAStuff.DevConsoleCollapseDuplicates)
		pcall(NAmanage.bindToDevConsole)
	end)
	NAmanage.RegisterToggleAutoSync("NA Console Collapse Duplicates", function() return NAStuff.DevConsoleCollapseDuplicates ~= false end)

	NAgui.addToggle("NA Console Source Labels", NAStuff.DevConsoleShowSource ~= false, function(v)
		NAStuff.DevConsoleShowSource = v ~= false
		pcall(NAmanage.NASettingsSet, "devConsoleShowSource", NAStuff.DevConsoleShowSource)
		pcall(NAmanage.bindToDevConsole)
	end)
	NAmanage.RegisterToggleAutoSync("NA Console Source Labels", function() return NAStuff.DevConsoleShowSource ~= false end)

	NAgui.addToggle("NA Console Copy Context", NAStuff.DevConsoleCopyContext ~= false, function(v)
		NAStuff.DevConsoleCopyContext = v ~= false
		pcall(NAmanage.NASettingsSet, "devConsoleCopyContext", NAStuff.DevConsoleCopyContext)
		pcall(NAmanage.bindToDevConsole)
	end)
	NAmanage.RegisterToggleAutoSync("NA Console Copy Context", function() return NAStuff.DevConsoleCopyContext ~= false end)

	NAgui.addInfo("NA Console Search", "type:error source:NamelessAdmin subsystem:Console ctx:key=value count:>1")

	NAgui.addButton("Export NA Console (TXT)", function()
		local ok, path, count = NAmanage.NAConsoleExport("txt")
		DoNotif(ok and ("Exported "..tostring(count or 0).." console entries to "..tostring(path)) or tostring(path), ok and 3 or 4)
	end)
	NAgui.addButton("Export NA Console (JSON)", function()
		local ok, path, count = NAmanage.NAConsoleExport("json")
		DoNotif(ok and ("Exported "..tostring(count or 0).." console entries to "..tostring(path)) or tostring(path), ok and 3 or 4)
	end)
end

buildDevConsoleControls()

NAmanage.MarkExternalLagProbe("settings_general_asset_defs_start")
NAStuff.PRELOAD_ASSET_CLASS_PROPS = NAStuff.PRELOAD_ASSET_CLASS_PROPS or {
	Animation = { "AnimationId" };
	AnimationClip = { "AnimationId" };
	AnimationTrack = { "Animation" };
	Beam = { "Texture" };
	Decal = { "Texture", "TextureId" };
	Fire = { "Texture" };
	ImageButton = { "Image" };
	ImageLabel = { "Image" };
	MeshPart = { "MeshId", "TextureId" };
	ParticleEmitter = { "Texture" };
	Pants = { "PantsTemplate" };
	PantsGraphic = { "Graphic" };
	Shirt = { "ShirtTemplate" };
	ShirtGraphic = { "Graphic" };
	Sky = { "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp" };
	Smoke = { "Texture" };
	Sound = { "SoundId" };
	SpecialMesh = { "MeshId", "TextureId" };
	SurfaceAppearance = { "AlbedoTexture", "MetalnessTexture", "RoughnessTexture", "NormalId" };
	SurfaceTexture = { "Texture" };
	Trail = { "Texture" };
	Texture = { "Texture", "TextureId" };
	Sparkles = { "Texture" };
	VideoFrame = { "Video" };
	CharacterMesh = { "BaseTextureId", "OverlayTextureId" };
};
NAmanage.MarkExternalLagProbe("settings_general_asset_defs_done")
NAStuff.PRELOAD_INSTANCE_CLASSES = NAStuff.PRELOAD_INSTANCE_CLASSES or {
	Animation = true;
	AnimationClip = true;
	AnimationTrack = true;
	Beam = true;
	Decal = true;
	Fire = true;
	MeshPart = true;
	ParticleEmitter = true;
	Pants = true;
	PantsGraphic = true;
	Shirt = true;
	ShirtGraphic = true;
	Sky = true;
	Smoke = true;
	Sound = true;
	SpecialMesh = true;
	SurfaceAppearance = true;
	SurfaceTexture = true;
	Trail = true;
	Texture = true;
	Sparkles = true;
	VideoFrame = true;
	CharacterMesh = true;
};

NAStuff.ASSET_LOAD_MODE_DEFS = NAStuff.ASSET_LOAD_MODE_DEFS or {
	Batch = { chunk = 96, delay = 0.03 };
	Medium = { chunk = 256, delay = 0.02 };
	Fast = { chunk = 512, delay = 0.01 };
	Aggressive = { chunk = 768, delay = 0.005 };
}
NAStuff.ASSET_LOAD_MODE_ORDER = NAStuff.ASSET_LOAD_MODE_ORDER or { "Batch", "Medium", "Fast", "Aggressive" }
NAStuff.AssetLoadMode = NAStuff.AssetLoadMode or "Fast"

NAmanage.ClampNumber = NAmanage.ClampNumber or function(value, minValue, maxValue)
	if type(value) ~= "number" then
		return value
	end
	minValue = minValue or value
	maxValue = maxValue or value
	if value < minValue then
		value = minValue
	end
	if value > maxValue then
		value = maxValue
	end
	return value
end

NAmanage.GetAssetLoadModeData = NAmanage.GetAssetLoadModeData or function()
	local mode = NAStuff.AssetLoadMode or "Fast"
	local def = NAStuff.ASSET_LOAD_MODE_DEFS[mode]
	if not def then
		mode = "Fast"
		def = NAStuff.ASSET_LOAD_MODE_DEFS.Fast
		NAStuff.AssetLoadMode = mode
	end
	return mode, def
end

NAmanage.SetAssetLoadMode = NAmanage.SetAssetLoadMode or function(mode)
	if type(mode) ~= "string" then
		return
	end
	const def = NAStuff.ASSET_LOAD_MODE_DEFS[mode]
	if not def then
		return
	end
	NAStuff.AssetLoadMode = mode
	if NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "assetLoadMode", mode)
	end
	const box = NAStuff.AssetLoadModeBox
	if box then
		pcall(function()
			box.Text = Format("%s Mode | %d chunk, %.3fs delay", mode, def.chunk, def.delay)
		end)
	end
	if NAgui and NAgui.setDropdownValue and type(NAStuff.AssetLoadModeDropdownLabel) == "string" then
		pcall(function()
			NAgui.setDropdownValue(NAStuff.AssetLoadModeDropdownLabel, { mode }, { fire = false, context = "sync" })
		end)
	end
end

NAmanage.GetAggressivePreloadChunk = NAmanage.GetAggressivePreloadChunk or function()
	local _, def = NAmanage.GetAssetLoadModeData()
	return def.chunk
end

NAmanage.GetAggressiveChunkYield = NAmanage.GetAggressiveChunkYield or function()
	local _, def = NAmanage.GetAssetLoadModeData()
	return def.delay
end

NAmanage.FormatAssetProgress = NAmanage.FormatAssetProgress or function(done, total)
	const loaded = tonumber(done) or 0
	const totalAssets = tonumber(total) or 0
	if totalAssets <= 0 then
		return "0/0 (0/0%)"
	end
	const percent = NAmanage.ClampNumber(loaded / totalAssets, 0, 1) * 100
	return Format("%d/%d (%.0f%%)", loaded, totalAssets, percent)
end

NAmanage.UpdateAssetLoadStatus = NAmanage.UpdateAssetLoadStatus or function(done, total)
	const box = NAStuff.AssetLoadStatusBox
	if not box then
		return
	end
	const text = NAmanage.FormatAssetProgress(done, total)
	pcall(function()
		box.Text = text
	end)
end

originalIO.AssetsPreloadNA = function(opts)
	opts = type(opts) == "table" and opts or {}
	const stMode = opts.st == true
	const lowImpact = opts.lowImpact == true

	const entries = {}
	const seenString = {}
	const seenInstance = {}
	local scanChunk = math.max(100, NAmanage.GetAggressivePreloadChunk())
	local scanYield = math.max(0, NAmanage.GetAggressiveChunkYield())
	if stMode then
		scanChunk = math.max(48, math.floor(scanChunk * 0.25))
		scanYield = math.max(scanYield, 0.02)
	end
	if lowImpact then
		scanChunk = IsOnMobile and 16 or 24
		scanYield = IsOnMobile and 0.08 or 0.05
	end
	local scanned = 0
	local maxInst = tonumber(opts.maxI)
	local maxEnt = tonumber(opts.maxE)
	if lowImpact then
		if not maxInst or maxInst < 1 then
			maxInst = 3000
		end
		if not maxEnt or maxEnt < 1 then
			maxEnt = 1000
		end
	elseif stMode then
		if not maxInst or maxInst < 1 then
			maxInst = 12000
		end
		if not maxEnt or maxEnt < 1 then
			maxEnt = 6000
		end
	end
	local incWs = opts.incWs
	if incWs == nil then
		incWs = not stMode
	end
	const cTok = NAmanage.NewCancelToken()

	const function hitLim()
		if cTok and cTok.cancelled then
			return true
		end
		if maxInst and scanned >= maxInst then
			cTok.cancelled = true
			return true
		end
		if maxEnt and #entries >= maxEnt then
			cTok.cancelled = true
			return true
		end
		return false
	end

	const function addRes(value)
		if hitLim() then
			return
		end
		const t = typeof(value)
		if t == "Instance" then
			if not seenInstance[value] then
				seenInstance[value] = true
				entries[#entries + 1] = value
			end
		elseif t == "string" and value ~= "" and not value:match("^rbxassetid://0+$") then
			if not seenString[value] then
				seenString[value] = true
				entries[#entries + 1] = value
			end
		end
	end

	const roots = {
		SafeGetService("ReplicatedStorage",false),
		SafeGetService("ReplicatedFirst",false),
		SafeGetService("Lighting",false),
		SafeGetService("StarterGui",false),
		SafeGetService("StarterPack",false),
		SafeGetService("StarterPlayer",false),
		SafeGetService("SoundService",false),
		SafeGetService("Chat",false),
		SafeGetService("TextChatService",false),
	}
	if incWs then
		roots[#roots + 1] = Services.Workspace
	end

	for i = 1, #roots do
		if hitLim() then
			break
		end
		const root = roots[i]
		if typeof(root) == "Instance" then
			pcall(function()
				NAmanage.ForEachDescendantYield(root, function(inst)
					if hitLim() then
						return
					end
					if NAStuff.PRELOAD_INSTANCE_CLASSES[inst.ClassName] then
						addRes(inst)
					end
					const props = NAStuff.PRELOAD_ASSET_CLASS_PROPS[inst.ClassName]
					if props then
						for j = 1, #props do
							const prop = props[j]
							local okProp, value = pcall(function()
								return inst[prop]
							end)
							if okProp and value then
								addRes(value)
							end
						end
					end
					scanned += 1
					if hitLim() then
						return
					end
				end, {
					yieldEvery = scanChunk,
					delayTime = (scanYield > 0 and scanYield or nil),
					cancelToken = cTok,
				})
			end)
		end
		if hitLim() then
			break
		end
		if scanYield > 0 then
			Wait(scanYield)
		else
			Wait()
		end
	end

	return entries
end

NAgui.addSection("Asset Loading")
NAStuff.AssetLoadingControlsBuilt = false
const function buildAssetLoadingControls()
	if NAStuff.AssetLoadingControlsBuilt == true then
		return
	end
	NAStuff.AssetLoadingControlsBuilt = true
	NAStuff.AssetLoadModeBox = NAgui.addInfo("Asset Load Mode", "")
	NAStuff.AssetLoadStatusBox = NAgui.addInfo("Asset Load Progress", "0/0 (0/0%)")

	NAgui.addToggle("Preload Assets On Load", NAStuff.AutoPreloadAssets == true, function(v)
		NAStuff.AutoPreloadAssets = v and true or false
		pcall(NAmanage.NASettingsSet, "autoPreloadAssets", NAStuff.AutoPreloadAssets)
	end)
	NAmanage.RegisterToggleAutoSync("Preload Assets On Load", function()
		return NAStuff.AutoPreloadAssets == true
	end)

	NAStuff.AssetLoadModeDropdownLabel = NAStuff.AssetLoadModeDropdownLabel or "Asset Load Mode Selector"
	NAStuff.AssetLoadModeDropdown = NAgui.addDropdown(NAStuff.AssetLoadModeDropdownLabel, NAStuff.ASSET_LOAD_MODE_ORDER, NAStuff.AssetLoadMode, function(selection)
		local modeName = nil
		if type(selection) == "table" then
			modeName = tostring(selection[1] or "")
		else
			modeName = tostring(selection or "")
		end
		modeName = modeName:match("^%s*(.-)%s*$") or modeName
		if modeName == "" then
			return
		end
		if not NAStuff.ASSET_LOAD_MODE_DEFS[modeName] then
			return
		end
		if NAStuff.AssetLoadRunning then
			DoNotif("Finish the current load before changing modes.", 2)
			if NAgui and NAgui.setDropdownValue then
				pcall(function()
					NAgui.setDropdownValue(NAStuff.AssetLoadModeDropdownLabel, { NAStuff.AssetLoadMode or "Fast" }, { fire = false, context = "revert" })
				end)
			end
			return
		end
		NAmanage.SetAssetLoadMode(modeName)
		DoNotif("Asset load mode set to "..modeName, 2)
	end)

	NAStuff.loadGameAssetsButton = NAgui.addButton("Load Game Assets", function()
		NAmanage.StartAssetPreload()
	end)
	NAStuff.AssetLoadButton = NAStuff.loadGameAssetsButton
end

buildAssetLoadingControls()

NAgui.addSection("Lighting Performance")
NAgui.addInfo("Dynamic Lighting Warning", "Freezing dynamic lighting updates stops Roblox's light voxel data from updating. PointLights and SurfaceLights may stop producing or updating light until this is disabled or Roblox is restarted.")

NAmanage.SetVoxelizerLightingPause = NAmanage.SetVoxelizerLightingPause or function(enabled, opts)
	return NAmanage.ApplyStandaloneFFlag("DebugPauseVoxelizer", enabled == true, opts)
end
NAmanage.SetVoxelizerLightingPause(NAStuff.PauseVoxelizerLighting == true, { silent = true })
NAgui.addToggle("Freeze Dynamic Lighting Updates", NAStuff.PauseVoxelizerLighting == true, function(v)
		const enabled = v == true
		const ok = NAmanage.SetVoxelizerLightingPause(enabled)
		if not ok then
			return
		end
		NAStuff.PauseVoxelizerLighting = enabled
		pcall(NAmanage.NASettingsSet, "pauseVoxelizerLighting", enabled)
		DoNotif("Dynamic lighting updates "..(enabled and "frozen" or "enabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Freeze Dynamic Lighting Updates", function()
	return NAStuff.PauseVoxelizerLighting == true
end)

NAmanage.setAssetLoadButtonState = function(isRunning)
	NAStuff.AssetLoadRunning = isRunning and true or false
	const button = NAStuff.AssetLoadButton
	if not button then
		return
	end
	const interact = button:FindFirstChild("Interact")
	if interact then
		interact.Active = not isRunning
		interact.AutoButtonColor = not isRunning
	end
	pcall(function()
		button.Title.Text = isRunning and "Loading Game Assets..." or "Load Game Assets"
	end)
end

NAmanage.finishAssetLoad = function(session, success, total, startTime, err)
	if session.finished then
		return
	end
	session.finished = true
	NAmanage.setAssetLoadButtonState(false)
	if success and total and total > 0 and startTime then
		const elapsed = tick() - startTime
		DoNotif(Format("Preloaded %d assets in %.2fs.", total, elapsed), 3)
	elseif not success then
		DoNotif("Asset preloading failed: "..tostring(err or "unknown"), 4)
	end
end

NAmanage.StartAssetPreload = NAmanage.StartAssetPreload or function(opts)
	opts = type(opts) == "table" and opts or {}
	const silent = opts and opts.silent
	const stMode = opts.st == true
	if NAStuff.AssetLoadRunning then
		if not silent then
			DoNotif("Asset loader is already running.", 2)
		end
		return
	end
	if not Services.ContentProvider or not Services.ContentProvider.PreloadAsync then
		if not silent then
			DoNotif("ContentProvider preloading is unavailable on this platform.", 3)
		end
		return
	end

	NAmanage.setAssetLoadButtonState(true)
	NAmanage.UpdateAssetLoadStatus(0, 0)
	if not silent then
		DoNotif("Scanning for assets to preload...", 2)
	end

	Spawn(function()
		const startTime = tick()
		local totalAssets = 0
		const session = { finished = false }
		local lastProgressTick = startTime
		const lowImpact = opts.lowImpact == true
		local ok, err = pcall(function()
			const perf = NAStuff and NAStuff.StartupPerformance
			const scanStart = os.clock()
			if type(perf) == "table" and stMode then
				perf.assetScanStarted = scanStart
			end
			const assets = originalIO.AssetsPreloadNA({
				st = stMode,
				lowImpact = lowImpact,
				incWs = opts.incWs,
				maxI = opts.maxI,
				maxE = opts.maxE,
			})
			const total = #assets
			totalAssets = total
			if type(perf) == "table" and stMode then
				perf.assetScanElapsed = os.clock() - scanStart
				perf.assetPreloadStarted = os.clock()
				perf.assetPreloadTotal = total
				perf.assetPreloadLowImpact = lowImpact
			end
			if total == 0 then
				NAmanage.UpdateAssetLoadStatus(0, 0)
				if not silent then
					DoNotif("Could not find any assets to preload.", 3)
				end
				return
			end

			NAmanage.UpdateAssetLoadStatus(0, total)
			lastProgressTick = tick()
			local chunkSize = math.max(1, NAmanage.GetAggressivePreloadChunk())
			local chunkYield = math.max(0, NAmanage.GetAggressiveChunkYield())
			if stMode then
				chunkSize = math.max(48, math.floor(chunkSize * 0.4))
				chunkYield = math.max(chunkYield, 0.02)
			end
			if lowImpact then
				chunkSize = IsOnMobile and 8 or 16
				chunkYield = IsOnMobile and 0.12 or 0.08
			end
			if type(perf) == "table" and stMode then
				perf.assetPreloadChunkSize = chunkSize
				perf.assetPreloadChunkYield = chunkYield
			end
			const watchdog = Spawn(function()
				while not session.finished do
					Wait(2)
					if not NAStuff.AssetLoadRunning then
						break
					end
					if tick() - lastProgressTick > 20 then
						NAmanage.finishAssetLoad(session, false, total, startTime, "watchdog timeout")
						break
					end
				end
			end)

			for index = 1, total, chunkSize do
				if session.finished then
					break
				end
				const chunk = {}
				for j = index, math.min(total, index + chunkSize - 1) do
					chunk[#chunk + 1] = assets[j]
				end

				const chunkStart = os.clock()
				pcall(function()
					__lt.cm("ContentProvider", "PreloadAsync", chunk)
				end)
				if type(perf) == "table" and stMode then
					const chunkElapsed = os.clock() - chunkStart
					perf.assetPreloadChunks = (tonumber(perf.assetPreloadChunks) or 0) + 1
					if not perf.assetPreloadMaxChunk or chunkElapsed > perf.assetPreloadMaxChunk then
						perf.assetPreloadMaxChunk = chunkElapsed
					end
				end
				const doneCount = math.min(total, index + #chunk - 1)
				NAmanage.UpdateAssetLoadStatus(doneCount, total)
				lastProgressTick = tick()
				Wait(chunkYield)
			end

			if not session.finished then
				NAmanage.UpdateAssetLoadStatus(total, total)
			end
			if type(perf) == "table" and stMode then
				perf.assetPreloadElapsed = os.clock() - (tonumber(perf.assetPreloadStarted) or os.clock())
			end
		end)
		NAmanage.finishAssetLoad(session, ok, totalAssets, startTime, err)
		if not ok then
			warn("Asset loader failed:", err)
		end
	end)
end

NAmanage.setAssetLoadButtonState(false)
NAmanage.SetAssetLoadMode(NAStuff.AssetLoadMode)
NAgui.addSection("Roblox Input Settings")

NAgui.addToggle("Disable Input Changing", NADisableLastInput, function(v)
	NADisableLastInput = v
	NAmanage.NASettingsSet("disableLastInput", v)

	if v then
		originalIO.ApplyLastInputPatch()
		DoNotif("Input Changing Disabled", 1.5)
	else
		originalIO.RevertLastInputPatch()
		DoNotif("Input Changing Enabled", 1.5)
	end
end)

if IsOnMobile then
	NAgui.addSection("Mobile Camera")
	NAgui.addToggle("Enable Mobile Camera Sensitivity", NAStuff.MobileCamSensEnabled == true, function(state)
		NAmanage.SetMobileCamSensEnabled(state)
	end)
	NAgui.addSlider("Touch Sensitivity Multiplier", 0.2, 4, NAStuff.MobileCamSensitivity or 1, 0.05, "x", function(val)
		NAmanage.SetMobileCamSensitivity(val)
	end)
end

NAgui.addSection("Links")
NAgui.addButton("Discord Server", function()
	const inviteLink = NAmanage._sourceGlyph(NAStuff.inviteLink)
	if setclipboard then
		setclipboard(inviteLink)
		DoNotif("Discord link copied to clipboard!")
	else
		DoNotif("Unable to copy automatically. Invite: "..inviteLink, 3)
	end
end)
NAgui.addButton(adminName.." Documents", function()
	const docsLink = NAmanage._sourceGlyph(NAStuff.docsLink)
	if setclipboard then
		setclipboard(docsLink)
		DoNotif("Documents link copied to clipboard!")
	else
		DoNotif("Unable to copy automatically. Documents: "..docsLink, 3)
	end
end)
NAgui.addButton("Support Ko-fi", function()
	const supportLink = NAmanage._sourceGlyph(NAStuff.supportLink)
	if setclipboard then
		setclipboard(supportLink)
		DoNotif("Support Ko-fi link copied to clipboard!")
	else
		DoNotif("Unable to copy automatically. Support Ko-fi: "..supportLink, 3)
	end
end)

if FileSupport then
	NAgui.addSection("Saved Data")
	NAgui.addButton("Delete Saved Settings...", function()
		NAmanage.openSettingsCleanupPopup()
	end)
end

NAgui.setTab(NA_TABS.TAB_SAVE_INSTANCE)
NAmanage.BuildSaveInstanceTab()

NAgui.SCREEN_GUI_NO_RENDER_FLAG = NAgui.SCREEN_GUI_NO_RENDER_FLAG or "DebugDontRenderScreenGui"
NAgui.screenGuiNoRenderSupported = NAgui.screenGuiNoRenderSupported or false
NAgui.ScreenGuiNoRenderHasSupport=function()
	if not (type(setfflag) == "function" or (game and type(game.DefineFastFlag) == "function")) then
		return false
	end
	if NAFFlags and NAFFlags.isFlagAvailable then
		return NAFFlags.isFlagAvailable(NAgui.SCREEN_GUI_NO_RENDER_FLAG, { notify = false })
	end
	return true
end

NAgui.ScreenGuiNoRenderGet=function()
	if type(getfflag) == "function" then
		local ok, val = pcall(getfflag, NAgui.SCREEN_GUI_NO_RENDER_FLAG)
		if ok then
			val = tostring(val):lower()
			return val == "true" or val == "1"
		end
	end
	return NAStuff._DebugDontRenderScreenGui == true
end

NAgui.ScreenGuiNoRenderSet=function(enabled, opts)
	opts = opts or {}
	const silent = opts.silent == true
	if NAFFlags and NAFFlags.apply then
		local ok, err = NAFFlags.apply(NAgui.SCREEN_GUI_NO_RENDER_FLAG, enabled, { allowDisabled = true, silent = silent })
		if ok then
			NAStuff._DebugDontRenderScreenGui = enabled
		end
		return ok, err
	end
	local setter
	if type(setfflag) == "function" then
		setter = setfflag
	elseif game and type(game.DefineFastFlag) == "function" then
		setter = function(name, value)
			return game:DefineFastFlag(name, value)
		end
	end
	if not setter then
		return false, "unsupported"
	end
	local ok, err = pcall(setter, NAgui.SCREEN_GUI_NO_RENDER_FLAG, enabled and "true" or "false")
	if ok then
		NAStuff._DebugDontRenderScreenGui = enabled
	end
	return ok, err
end

NAgui.ScreenGuiNoRenderToggle=function()
	const desired = not NAgui.ScreenGuiNoRenderGet()
	local ok, err = NAgui.ScreenGuiNoRenderSet(desired)
	if not ok then
		DoNotif("ScreenGui render toggle failed: "..tostring(err), 3)
	end
end

NAgui.screenGuiNoRenderSupported = NAgui.ScreenGuiNoRenderHasSupport()

if NAgui.screenGuiNoRenderSupported then
	NAgui.ScreenGuiNoRenderSet(false, { silent = true })
end

	NAgui.EnsureScreenGuiNoRenderKeybind=function()
	if NAStuff.ScreenGuiNoRenderConn then
		if Services.ContextActionService then
			const screenGuiNoRenderAction = NAmanage.GetSessionActionName("ScreenGuiNoRenderToggle")
			pcall(function() __lt.cm("ContextActionService", "UnbindAction", screenGuiNoRenderAction) end)
		end
		NAStuff.ScreenGuiNoRenderConn = nil
	end
	if NAStuff.ScreenGuiNoRenderUISConn then
		NAStuff.ScreenGuiNoRenderUISConn:Disconnect()
		NAStuff.ScreenGuiNoRenderUISConn = nil
	end
	if not (IsOnPC and NAgui.screenGuiNoRenderSupported and _na_env.NADebugDontRenderKeybindEnabled == true and Services.ContextActionService) then
		return
	end

	const macroKey = Enum.KeyCode.C
	const screenGuiNoRenderAction = NAmanage.GetSessionActionName("ScreenGuiNoRenderToggle")
	NAStuff.ScreenGuiNoRenderConn = __lt.cm("ContextActionService", "BindActionAtPriority",
		screenGuiNoRenderAction,
		function(_, state, input)
			if state ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end
			if input.KeyCode ~= macroKey then
				return Enum.ContextActionResult.Pass
			end
			const ctrlDown = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftControl) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightControl)
			const shiftDown = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftShift) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightShift)
			if ctrlDown and shiftDown then
				NAgui.ScreenGuiNoRenderToggle()
				return Enum.ContextActionResult.Sink
			end
			return Enum.ContextActionResult.Pass
		end,
		false,
		Enum.ContextActionPriority.Low.Value,
		macroKey
	)

	NAStuff.ScreenGuiNoRenderUISConn = Services.UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if not input or input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if input.KeyCode ~= macroKey then
			return
		end
		if _na_env.NADebugDontRenderKeybindEnabled ~= true then
			return
		end
		const ctrlDown = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftControl) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightControl)
		const shiftDown = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftShift) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightShift)
		if ctrlDown and shiftDown then
			NAgui.ScreenGuiNoRenderToggle()
		end
	end)
end

NAgui.EnsureScreenGuiNoRenderKeybind()

NAgui.setTab(NA_TABS.TAB_AUTOMATION)
NAgui.addSection("Staffwatch")

NAgui.addToggle("Ignore LocalPlayer In Staffwatch", NAStuff.StaffwatchIgnoreLocal ~= false, function(v)
	NAStuff.StaffwatchIgnoreLocal = v and true or false
	pcall(NAmanage.NASettingsSet, "staffwatchIgnoreLocal", NAStuff.StaffwatchIgnoreLocal)
	if NAStuff.StaffwatchIgnoreLocal then
		NAmanage.StaffwatchClearPlayer(LocalPlayer)
	elseif NAStuff.StaffwatchState and NAStuff.StaffwatchState.active then
		NAmanage.StaffwatchHandlePlayer(LocalPlayer, false)
	end
	DoNotif("Staffwatch LocalPlayer ignore "..(NAStuff.StaffwatchIgnoreLocal and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Staffwatch Highlight", NAStuff.StaffwatchHighlightEnabled ~= false, function(v)
	NAStuff.StaffwatchHighlightEnabled = v and true or false
	pcall(NAmanage.NASettingsSet, "staffwatchHighlight", NAStuff.StaffwatchHighlightEnabled)
	if NAStuff.StaffwatchHighlightEnabled then
		NAmanage.StaffwatchRefreshMarkers()
	else
		NAmanage.StaffwatchClearHighlights()
	end
	DoNotif("Staffwatch highlight "..(NAStuff.StaffwatchHighlightEnabled and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Staffwatch Overrides ESP/Chams", NAStuff.StaffwatchOverrideESP ~= false, function(v)
	NAStuff.StaffwatchOverrideESP = v and true or false
	pcall(NAmanage.NASettingsSet, "staffwatchOverrideESP", NAStuff.StaffwatchOverrideESP)
	if type(NAmanage.ESP_RefreshPlayerTeamFilters) == "function" then
		NAmanage.ESP_RefreshPlayerTeamFilters()
	end
	DoNotif("Staffwatch ESP/Chams override "..(NAStuff.StaffwatchOverrideESP and "enabled" or "disabled"), 2)
end)

NAgui.addColorPicker("Staffwatch Marker Color", NAmanage.StaffwatchGetMarkerColor(), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.StaffwatchMarkerColor = color
	pcall(NAmanage.NASettingsSet, "staffwatchMarkerColor", { R = color.R; G = color.G; B = color.B })
	NAmanage.StaffwatchRefreshMarkers()
end)

NAgui.addSection("Command & AutoFire Options")

const autoInteractExtraDefault = math.clamp(tonumber(NAStuff.AutoInteractExtraRange) or 5, 0, 1000)
const autoInteractIntervalDefault = math.clamp(tonumber(NAStuff.AutoInteractDefaultInterval) or 0.1, 0, 1)
NAgui.addSlider("AutoFire Default Delay", 0, 1, autoInteractIntervalDefault, 0.01, "", function(val)
	local n = tonumber(val) or autoInteractIntervalDefault
	n = math.floor((math.clamp(n, 0, 1) * 100) + 0.5) / 100
	NAStuff.AutoInteractDefaultInterval = n
	pcall(NAmanage.NASettingsSet, "autoInteractDefaultInterval", n)
	NAjobs.applyLinkedAutoInteractInterval(n)
end)

NAStuff.AutoInteractMethodDropdownLabel = "AutoFire Spam Mode"
NAgui.addDropdown(NAStuff.AutoInteractMethodDropdownLabel, NAStuff.LoopMethodOptions or { "PostSimulation", "PreSimulation", "RenderStepped", "Heartbeat" }, NAmanage.GetAutoFireDefaultMethod("prompt"), function(sel)
	const picked = NAmanage.SetAutoFireDefaultMethod("prompt", NAmanage.getDDTxt(sel) or sel, { save = true; updateRunning = true; rebind = true })
	if NAgui.setDropdownValue then
		NAgui.setDropdownValue(NAStuff.AutoInteractMethodDropdownLabel, picked, { fire = false })
	end
	DoNotif("AutoFire spam mode set to "..picked, 2)
end)

NAgui.addToggle("Use Distance Check for AutoFire", NAStuff.AutoInteractDistanceEnabled ~= false, function(v)
	NAStuff.AutoInteractDistanceEnabled = v ~= false
	pcall(NAmanage.NASettingsSet, "autoInteractDistanceEnabled", NAStuff.AutoInteractDistanceEnabled)
	DoNotif("AutoFire distance check "..(NAStuff.AutoInteractDistanceEnabled and "enabled" or "disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Use Distance Check for AutoFire", function()
	return NAStuff.AutoInteractDistanceEnabled ~= false
end)

NAgui.addSlider("AutoFire Extra Distance", 0, 250, autoInteractExtraDefault, 1, " studs", function(val)
	local n = tonumber(val) or autoInteractExtraDefault
	n = math.clamp(n, 0, 250)
	NAStuff.AutoInteractExtraRange = n
	pcall(NAmanage.NASettingsSet, "autoInteractExtraRange", n)
end)

NAgui.addSection("ClickTouch Options")

NAgui.addSlider("ClickTouch Max Distance", 0, 5000, math.clamp(tonumber(NAStuff.ClickTouchMaxDistance) or 1024, 0, 5000), 25, " studs", function(val)
	local n = math.floor((tonumber(val) or 1024) + 0.5)
	n = (n <= 0) and 0 or math.clamp(n, 50, 5000)
	NAStuff.ClickTouchMaxDistance = n
	pcall(NAmanage.NASettingsSet, "clickTouchMaxDistance", n)
end)

NAgui.addSlider("ClickTouch Cursor Radius", 2, 80, math.clamp(tonumber(NAStuff.ClickTouchScreenRadius) or 18, 2, 80), 1, " px", function(val)
	const n = math.clamp(math.floor((tonumber(val) or 18) + 0.5), 2, 80)
	NAStuff.ClickTouchScreenRadius = n
	pcall(NAmanage.NASettingsSet, "clickTouchScreenRadius", n)
end)

NAgui.addToggle("ClickTouch Blocked By Walls", NAStuff.ClickTouchBlockedByCollide ~= false, function(v)
	NAStuff.ClickTouchBlockedByCollide = v ~= false
	pcall(NAmanage.NASettingsSet, "clickTouchBlockedByCollide", NAStuff.ClickTouchBlockedByCollide)
end)
NAmanage.RegisterToggleAutoSync("ClickTouch Blocked By Walls", function()
	return NAStuff.ClickTouchBlockedByCollide ~= false
end)

NAgui.addToggle("ClickTouch Ignore Non-Collide Blockers", NAStuff.ClickTouchIgnoreNonCollideBlockers ~= false, function(v)
	NAStuff.ClickTouchIgnoreNonCollideBlockers = v ~= false
	pcall(NAmanage.NASettingsSet, "clickTouchIgnoreNonCollideBlockers", NAStuff.ClickTouchIgnoreNonCollideBlockers)
end)
NAmanage.RegisterToggleAutoSync("ClickTouch Ignore Non-Collide Blockers", function()
	return NAStuff.ClickTouchIgnoreNonCollideBlockers ~= false
end)

NAgui.addToggle("ClickTouch Invisible Part Fallback", NAStuff.ClickTouchInvisibleFallback ~= false, function(v)
	NAStuff.ClickTouchInvisibleFallback = v ~= false
	pcall(NAmanage.NASettingsSet, "clickTouchInvisibleFallback", NAStuff.ClickTouchInvisibleFallback)
end)
NAmanage.RegisterToggleAutoSync("ClickTouch Invisible Part Fallback", function()
	return NAStuff.ClickTouchInvisibleFallback ~= false
end)

NAgui.addToggle("ClickTouch Always-On-Top Box", NAStuff.ClickTouchAlwaysOnTop == true, function(v)
	NAStuff.ClickTouchAlwaysOnTop = v == true
	pcall(NAmanage.NASettingsSet, "clickTouchAlwaysOnTop", NAStuff.ClickTouchAlwaysOnTop)
	if NAStuff.clicktouchTargetPart and NAStuff.clicktouchTargetTouch then
		NAmanage.ClickTouchSetVisualTarget(NAStuff.clicktouchTargetPart, NAStuff.clicktouchTargetTouch)
	end
end)
NAmanage.RegisterToggleAutoSync("ClickTouch Always-On-Top Box", function()
	return NAStuff.ClickTouchAlwaysOnTop == true
end)

NAgui.addSection("Remote AutoFire")

const autoFireRemoteIntervalDefault = math.clamp(tonumber(NAStuff.AutoFireRemoteDefaultInterval) or NAmanage.getAutoInteractDefaultInterval(), 0, 1)
NAgui.addSlider("AutoFireRemote Default Delay", 0, 1, autoFireRemoteIntervalDefault, 0.01, "", function(val)
	local n = tonumber(val) or autoFireRemoteIntervalDefault
	n = math.floor((math.clamp(n, 0, 1) * 100) + 0.5) / 100
	NAStuff.AutoFireRemoteDefaultInterval = n
	pcall(NAmanage.NASettingsSet, "autoFireRemoteDefaultInterval", n)
	NAjobs.applyLinkedAutoFireRemoteInterval(n)
end)

NAStuff.AutoFireRemoteMethodDropdownLabel = "AutoFireRemote Spam Mode"
NAgui.addDropdown(NAStuff.AutoFireRemoteMethodDropdownLabel, NAStuff.LoopMethodOptions or { "PostSimulation", "PreSimulation", "RenderStepped", "Heartbeat" }, NAmanage.GetAutoFireDefaultMethod("remote"), function(sel)
	const picked = NAmanage.SetAutoFireDefaultMethod("remote", NAmanage.getDDTxt(sel) or sel, { save = true; updateRunning = true; rebind = true })
	if NAgui.setDropdownValue then
		NAgui.setDropdownValue(NAStuff.AutoFireRemoteMethodDropdownLabel, picked, { fire = false })
	end
	DoNotif("AutoFireRemote spam mode set to "..picked, 2)
end)

NAgui.addSection("Flight Options")
NAgui.addToggle("Disable Fly Velocity Clamp", NAStuff.FlyNoVelocityClamp == true, function(v)
	NAStuff.FlyNoVelocityClamp = v == true
	pcall(NAmanage.NASettingsSet, "flyNoVelocityClamp", NAStuff.FlyNoVelocityClamp)
	if NAStuff.FlyNoVelocityClamp and type(NAmanage.ClearVelocityWalkSpeedClampState) == "function" then
		NAmanage.ClearVelocityWalkSpeedClampState()
	end
	DoNotif("Fly velocity clamp "..(NAStuff.FlyNoVelocityClamp and "disabled" or "enabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Disable Fly Velocity Clamp", function()
	return NAStuff.FlyNoVelocityClamp == true
end)

NAgui.addToggle("cFly Return Visualizer", NAStuff.CFlyVisualizerOn ~= false, function(v)
	NAStuff.CFlyVisualizerOn = v ~= false
	pcall(NAmanage.NASettingsSet, "cFlyVisualizer", NAStuff.CFlyVisualizerOn)
	if NAStuff.CFlyVisualizerOn then
		if flyVariables.cFlyEnabled == true or (NAmanage._state and NAmanage._state.mode == "cfly") then
			const char = getChar()
			const root = char and NAmanage._getCFlyTarget(char) or nil
			NAmanage.CFlyStartVisualizer(root, true)
		end
	else
		NAmanage.CFlyClearVisualizer()
	end
	DoNotif("cFly return visualizer "..(NAStuff.CFlyVisualizerOn and "enabled" or "disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("cFly Return Visualizer", function()
	return NAStuff.CFlyVisualizerOn ~= false
end)

if IsOnMobile then
	NAgui.addSection("Mobile Flight Automation")
	NAgui.addToggle("Auto Enable Fly On Run", NAStuff.MobileFlyAutoEnableOnRun ~= false, function(v)
		NAStuff.MobileFlyAutoEnableOnRun = v ~= false
		pcall(NAmanage.NASettingsSet, "mobileFlyAutoEnableOnRun", NAStuff.MobileFlyAutoEnableOnRun)
		DoNotif("Mobile fly commands will "..(NAStuff.MobileFlyAutoEnableOnRun and "start flying immediately" or "only show the button"), 2)
	end)
	NAmanage.RegisterToggleAutoSync("Auto Enable Fly On Run", function()
		return NAStuff.MobileFlyAutoEnableOnRun ~= false
	end)
end

NAgui.addSection("Environment Automation")

NAStuff.lightingStyleOptions = NAStuff.lightingStyleOptions or {}
for _, item in Enum.LightingStyle:GetEnumItems() do
	NAStuff.lightingStyleOptions[#NAStuff.lightingStyleOptions + 1] = item.Name
end
table.sort(NAStuff.lightingStyleOptions, function(a, b)
	return Lower(a) < Lower(b)
end)

NAStuff.LightingStyleAutomationDropdownLabel = NAStuff.LightingStyleAutomationDropdownLabel or "LightingStyle Auto Apply"
NAgui.addDropdown(NAStuff.LightingStyleAutomationDropdownLabel, NAStuff.lightingStyleOptions, NAStuff.LightingStyleAutomationStyle or "Soft", function(selection)
	local styleName = nil
	if type(selection) == "table" then
		styleName = tostring(selection[1] or "")
	else
		styleName = tostring(selection or "")
	end
	styleName = styleName:match("^%s*(.-)%s*$") or styleName
	if styleName == "" or not Enum.LightingStyle[styleName] then
		return
	end
	NAStuff.LightingStyleAutomationStyle = styleName
	pcall(NAmanage.NASettingsSet, "lightingStyleAutomationStyle", styleName)
	if NAStuff.LightingStyleAutomation == true then
		NAmanage.applyLightingStyleAutomation()
	end
	DoNotif("LightingStyle auto-apply set to "..styleName, 2)
end)

NAgui.addToggle("Auto Apply LightingStyle", NAStuff.LightingStyleAutomation == true, function(v)
	NAStuff.LightingStyleAutomation = v == true
	pcall(NAmanage.NASettingsSet, "lightingStyleAutomation", NAStuff.LightingStyleAutomation)
	if NAStuff.LightingStyleAutomation then
		NAmanage.applyLightingStyleAutomation()
	end
	DoNotif("LightingStyle auto-apply "..(NAStuff.LightingStyleAutomation and "enabled" or "disabled"), 2)
end)
NAmanage.RegisterToggleAutoSync("Auto Apply LightingStyle", function()
	return NAStuff.LightingStyleAutomation == true
end)

NAgui.addSection("Offset Visualizer")

NAgui.addToggle("Offset Visualizer Enabled", NAStuff.OffVisOn ~= false, function(v)
	NAStuff.OffVisOn = v ~= false
	pcall(NAmanage.NASettingsSet, "offVisOn", NAStuff.OffVisOn)
	if not NAStuff.OffVisOn then
		const st = NAStuff and NAStuff.NAundergroundState
		if st then
			NAmanage.ovClr(st)
		end
	end
	NAmanage.ovLive(true)
end)
NAmanage.RegisterToggleAutoSync("Offset Visualizer Enabled", function()
	return NAStuff.OffVisOn ~= false
end)

NAgui.addToggle("Offset Visualizer Accessories", NAStuff.OffVisAcc ~= false, function(v)
	NAStuff.OffVisAcc = v ~= false
	pcall(NAmanage.NASettingsSet, "offVisAcc", NAStuff.OffVisAcc)
	NAmanage.ovLive(true)
end)
NAmanage.RegisterToggleAutoSync("Offset Visualizer Accessories", function()
	return NAStuff.OffVisAcc ~= false
end)

NAgui.addSlider("Offset Visual Fill Transparency", 0, 1, math.clamp(tonumber(NAStuff.OffVisFTr) or 0.82, 0, 1), 0.05, "", function(val)
	const n = math.clamp(tonumber(val) or 0.82, 0, 1)
	NAStuff.OffVisFTr = n
	pcall(NAmanage.NASettingsSet, "offVisFTr", n)
	NAmanage.ovLive(false)
end)

NAgui.addSlider("Offset Visual Outline Transparency", 0, 1, math.clamp(tonumber(NAStuff.OffVisOTr) or 0.15, 0, 1), 0.05, "", function(val)
	const n = math.clamp(tonumber(val) or 0.15, 0, 1)
	NAStuff.OffVisOTr = n
	pcall(NAmanage.NASettingsSet, "offVisOTr", n)
	NAmanage.ovLive(false)
end)

NAmanage.updateFpsBoostOpt=function(key, value)
	NAStuff.FPSBoostOptions = NAStuff.FPSBoostOptions or {}
	NAStuff.FPSBoostOptions[key] = value
	NAStuff.FPSBoostOptions = NAmanage.NASettingsSet("fpsBoostOptions", NAStuff.FPSBoostOptions) or NAStuff.FPSBoostOptions
	if _na_env.NA_FPS_ACTIVE and type(_na_env.NA_FPS_REFRESH) == "function" and NAStuff.FPSBoostOptions.effectMode ~= "destroy" and not _na_env.NA_FPS_REFRESH_PENDING then
		_na_env.NA_FPS_REFRESH_PENDING = true
		task.spawn(function()
			task.wait()
			_na_env.NA_FPS_REFRESH_PENDING = false
			if type(_na_env.NA_FPS_REFRESH) == "function" then
				_na_env.NA_FPS_REFRESH()
			end
		end)
	end
end

NAgui.addSection("FPSBooster Defaults")

NAgui.addToggle("Destroy Effects (FPSBooster)", NAStuff.FPSBoostOptions.effectMode == "destroy", function(v)
	NAmanage.updateFpsBoostOpt("effectMode", v and "destroy" or "disable")
	DoNotif("FPSBooster will "..(v and "destroy" or "disable").." visual effects", 3)
end)
NAmanage.RegisterToggleAutoSync("Destroy Effects (FPSBooster)", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.effectMode == "destroy") == true
end)

NAgui.addToggle("Strip Particles & Trails", NAStuff.FPSBoostOptions.stripParticles ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripParticles", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Strip Particles & Trails", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripParticles ~= false) == true
end)

NAgui.addToggle("Remove Decals", NAStuff.FPSBoostOptions.stripDecals ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripDecals", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Remove Decals", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripDecals ~= false) == true
end)

NAgui.addToggle("Remove Textures", NAStuff.FPSBoostOptions.stripTextures ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripTextures", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Remove Textures", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripTextures ~= false) == true
end)

NAgui.addToggle("Strip SurfaceAppearance", NAStuff.FPSBoostOptions.stripSurfaceAppearance ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripSurfaceAppearance", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Strip SurfaceAppearance", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripSurfaceAppearance ~= false) == true
end)

NAgui.addToggle("Disable Highlights", NAStuff.FPSBoostOptions.stripHighlights ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripHighlights", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Disable Highlights", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripHighlights ~= false) == true
end)

NAgui.addToggle("Disable Lights", NAStuff.FPSBoostOptions.stripLights ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripLights", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Disable Lights", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripLights ~= false) == true
end)

NAgui.addToggle("Disable Post Effects", NAStuff.FPSBoostOptions.stripPostFx ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripPostFx", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Disable Post Effects", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripPostFx ~= false) == true
end)

NAgui.addToggle("Clear Atmospheres", NAStuff.FPSBoostOptions.stripAtmosphere ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripAtmosphere", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Clear Atmospheres", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripAtmosphere ~= false) == true
end)

NAgui.addToggle("Simplify Materials & Shadows", NAStuff.FPSBoostOptions.simplifyMaterials ~= false, function(v)
	NAmanage.updateFpsBoostOpt("simplifyMaterials", v ~= false)
	NAmanage.updateFpsBoostOpt("zeroReflectance", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Simplify Materials & Shadows", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.simplifyMaterials ~= false) == true
end)

NAgui.addToggle("Zero Reflectance", NAStuff.FPSBoostOptions.zeroReflectance ~= false, function(v)
	NAmanage.updateFpsBoostOpt("zeroReflectance", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Zero Reflectance", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.zeroReflectance ~= false) == true
end)

NAgui.addToggle("Performance Mesh LOD", NAStuff.FPSBoostOptions.optimizeMeshes ~= false, function(v)
	NAmanage.updateFpsBoostOpt("optimizeMeshes", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Performance Mesh LOD", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.optimizeMeshes ~= false) == true
end)

NAgui.addToggle("Performance Model LOD", NAStuff.FPSBoostOptions.optimizeModels ~= false, function(v)
	NAmanage.updateFpsBoostOpt("optimizeModels", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Performance Model LOD", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.optimizeModels ~= false) == true
end)

NAgui.addToggle("Reduce World Queries (Aggressive)", NAStuff.FPSBoostOptions.disableWorldQueries == true, function(v)
	NAmanage.updateFpsBoostOpt("disableWorldQueries", v == true)
end)
NAmanage.RegisterToggleAutoSync("Reduce World Queries (Aggressive)", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.disableWorldQueries == true) == true
end)

NAgui.addToggle("Reduce World Touches (Aggressive)", NAStuff.FPSBoostOptions.disableWorldTouches == true, function(v)
	NAmanage.updateFpsBoostOpt("disableWorldTouches", v == true)
end)
NAmanage.RegisterToggleAutoSync("Reduce World Touches (Aggressive)", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.disableWorldTouches == true) == true
end)

NAgui.addToggle("Disable 3D UI", NAStuff.FPSBoostOptions.disable3dUi == true, function(v)
	NAmanage.updateFpsBoostOpt("disable3dUi", v == true)
end)
NAmanage.RegisterToggleAutoSync("Disable 3D UI", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.disable3dUi == true) == true
end)

NAgui.addToggle("Dampen Explosions", NAStuff.FPSBoostOptions.stripExplosions ~= false, function(v)
	NAmanage.updateFpsBoostOpt("stripExplosions", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Dampen Explosions", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.stripExplosions ~= false) == true
end)

NAgui.addToggle("Flatten Lighting (Fog/Shadows)", NAStuff.FPSBoostOptions.flattenLighting ~= false, function(v)
	NAmanage.updateFpsBoostOpt("flattenLighting", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Flatten Lighting (Fog/Shadows)", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.flattenLighting ~= false) == true
end)

NAgui.addToggle("Force Streaming Optimizations", NAStuff.FPSBoostOptions.forceStreaming ~= false, function(v)
	NAmanage.updateFpsBoostOpt("forceStreaming", v ~= false)
end)
NAmanage.RegisterToggleAutoSync("Force Streaming Optimizations", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.forceStreaming ~= false) == true
end)

NAgui.addToggle("Ignore Players", NAStuff.FPSBoostOptions.ignorePlayers ~= false, function(v)
	NAmanage.updateFpsBoostOpt("ignorePlayers", v == true)
end)
NAmanage.RegisterToggleAutoSync("Ignore Players", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.ignorePlayers ~= false) == true
end)

NAgui.addToggle("Ignore Self", NAStuff.FPSBoostOptions.ignoreSelf ~= false, function(v)
	NAmanage.updateFpsBoostOpt("ignoreSelf", v == true)
end)
NAmanage.RegisterToggleAutoSync("Ignore Self", function()
	return (NAStuff.FPSBoostOptions and NAStuff.FPSBoostOptions.ignoreSelf ~= false) == true
end)

const streamRadiusDefault = math.clamp(tonumber(NAStuff.FPSBoostOptions.streamRadius) or 96, 16, 4096)
NAgui.addSlider("Streaming Radius (FPSBooster)", 16, 4096, streamRadiusDefault, 8, " studs", function(val)
	const n = math.clamp(tonumber(val) or streamRadiusDefault, 16, 4096)
	NAmanage.updateFpsBoostOpt("streamRadius", n)
end)

NAgui.addSection("Hitbox Defaults")
NAStuff.hbOptsUi = NAStuff.hbOptsUi or NAmanage.GetHitboxOpts()
NAmanage.saveHitboxOpt=function(key, value)
	NAStuff.hbOptsUi = NAmanage.SetHitboxOpt(key, value)
	NAmanage.HitboxUpdateActive(NAStuff.hbOptsUi)
end

NAgui.addSlider("Hitbox Size", 1, 50, NAStuff.hbOptsUi.size or 10, 1, " studs", function(val)
	const n = math.clamp(tonumber(val) or (NAStuff.hbOptsUi.size or 10), 1, 50)
	NAmanage.saveHitboxOpt("size", n)
end)

NAgui.addSlider("Hitbox Transparency", 0, 1, NAStuff.hbOptsUi.transparency or 0.9, 0.05, "", function(val)
	const n = math.clamp(tonumber(val) or (NAStuff.hbOptsUi.transparency or 0.9), 0, 1)
	NAmanage.saveHitboxOpt("transparency", n)
end)

NAgui.addColorPicker("Hitbox Color", NAmanage.HB_ColorFromOpt(NAStuff.hbOptsUi.color), function(color)
	NAmanage.saveHitboxOpt("color", color)
end)

NAgui.addInput("Hitbox Material", "Neon / ForceField / Plastic", tostring(NAStuff.hbOptsUi.material or "Neon"), function(text)
	local matName = tostring(text or ""):match("^%s*(.-)%s*$") or "Neon"
	matName = NAmanage.HB_ResolveMaterial(matName)
	NAmanage.saveHitboxOpt("material", matName)
	DoNotif("Hitbox material set to "..matName, 2)
	if NAgui.setInputValue then
		NAgui.setInputValue("Hitbox Material", matName)
	end
end)

NAgui.addToggle("Hitbox No-Collide", NAStuff.hbOptsUi.noCollide ~= false, function(v)
	NAmanage.saveHitboxOpt("noCollide", v ~= false)
end)

NAgui.addToggle("Hitbox Massless", NAStuff.hbOptsUi.massless ~= false, function(v)
	NAmanage.saveHitboxOpt("massless", v ~= false)
end)

NAgui.addSection("Partsize Defaults")
NAStuff.psOptsUi = NAStuff.psOptsUi or NAmanage.GetPartSizeOpts()
NAmanage.savePartSizeOpt=function(key, value)
	NAStuff.psOptsUi = NAmanage.SetPartSizeOpt(key, value)
end

NAgui.addSlider("Partsize Transparency", 0, 1, NAStuff.psOptsUi.transparency or 0.5, 0.05, "", function(val)
	const n = math.clamp(tonumber(val) or (NAStuff.psOptsUi.transparency or 0.5), 0, 1)
	NAmanage.savePartSizeOpt("transparency", n)
end)

NAgui.addColorPicker("Partsize Color", NAmanage.PST_ColorFromOpt(NAStuff.psOptsUi.color), function(color)
	NAmanage.savePartSizeOpt("color", color)
end)

NAgui.addToggle("Partsize Change Color", NAStuff.psOptsUi.changeColor == true, function(v)
	NAmanage.savePartSizeOpt("changeColor", v == true)
end)

NAgui.addInput("Partsize Material", "Neon / ForceField / Plastic", tostring(NAStuff.psOptsUi.material or "Neon"), function(text)
	local matName = tostring(text or ""):match("^%s*(.-)%s*$") or "Neon"
	matName = NAmanage.PST_ResolveMaterial(matName)
	NAmanage.savePartSizeOpt("material", matName)
	DoNotif("Partsize material set to "..matName, 2)
	if NAgui.setInputValue then
		NAgui.setInputValue("Partsize Material", matName)
	end
end)

NAgui.addToggle("Partsize Change Material", NAStuff.psOptsUi.changeMaterial == true, function(v)
	NAmanage.savePartSizeOpt("changeMaterial", v == true)
end)

NAgui.addToggle("Partsize No-Collide", NAStuff.psOptsUi.noCollide ~= false, function(v)
	NAmanage.savePartSizeOpt("noCollide", v ~= false)
end)

NAgui.addToggle("Partsize Massless", NAStuff.psOptsUi.massless == true, function(v)
	NAmanage.savePartSizeOpt("massless", v == true)
end)

if IsOnPC then
	if NAgui.screenGuiNoRenderSupported then
		NAgui.addToggle("Ctrl+Shift+C Hide ScreenGui", _na_env.NADebugDontRenderKeybindEnabled == true, function(v)
			_na_env.NADebugDontRenderKeybindEnabled = v and true or false
			NAmanage.NASettingsSet("debugDontRenderKeybind", _na_env.NADebugDontRenderKeybindEnabled)
			NAgui.EnsureScreenGuiNoRenderKeybind()
			DoNotif("ScreenGui hide keybind "..(v and "enabled" or "disabled"), 2)
		end)
		NAmanage.RegisterToggleAutoSync("Ctrl+Shift+C Hide ScreenGui", function()
			return _na_env.NADebugDontRenderKeybindEnabled == true
		end)
	end

	NAgui.addToggle("Freecam Shift+P Keybind", _na_env.NAFreecamKeybindEnabled == true, function(v)
		_na_env.NAFreecamKeybindEnabled = v and true or false
		NAmanage.NASettingsSet("freecamKeybind", _na_env.NAFreecamKeybindEnabled)
		DoNotif("Freecam Shift+P keybind "..(v and "enabled" or "disabled"), 2)
	end)
	NAmanage.RegisterToggleAutoSync("Freecam Shift+P Keybind", function()
		return _na_env.NAFreecamKeybindEnabled == true
	end)
end

tweenDurationDefault = math.clamp(tonumber(NAStuff.tweenSpeed) or 1, 0.05, 5)
NAgui.addSlider("Teleport Tween Duration", 0.05, 5, tweenDurationDefault, 0.05, " s", function(val)
	const clamped = math.clamp(tonumber(val) or tweenDurationDefault, 0.05, 5)
	NAStuff.tweenSpeed = clamped
	NAmanage.NASettingsSet("tweenSpeed", clamped)
end)

const tpdDef = math.clamp(tonumber(NAStuff.tpDelay) or 0.2, 0, 5)
NAgui.addSlider("TP Delay", 0, 5, tpdDef, 0.05, " s", function(val)
	const clp = math.clamp(tonumber(val) or tpdDef, 0, 5)
	NAStuff.tpDelay = clp
	NAmanage.NASettingsSet("tpDelay", clp)
end)

const freecamSpeedDefault = math.clamp(tonumber(NAStuff.FreecamSpeed) or 5, 0.05, 20)
NAgui.addInput("Freecam Speed", "Enter speed (e.g. 10)", tostring(freecamSpeedDefault), function(text)
	const value = tonumber(text)
	if not value then
		DoNotif("Please enter a numeric freecam speed", 2)
		return
	end
	const clamped = math.clamp(value, 0.05, 20)
	NAStuff.FreecamSpeed = clamped
	pcall(NAmanage.NASettingsSet, "freecamSpeed", clamped)
	if NAFreecam and NAFreecam.SetSpeed then
		NAFreecam.SetSpeed(math.clamp(clamped / 5, 0.01, 4))
	end
	DoNotif("Freecam speed set to "..Format("%.2f", clamped), 2)
end)

NAgui.addButton("cmdbar2", function()
	if cmd and cmd.run then
		cmd.run({"cmdbar2"})
	end
end)

NAgui.addToggle("Run cmdbar2 on Start", NAStuff.CmdBar2AutoRun == true, function(v)
	NAStuff.CmdBar2AutoRun = v and true or false
	NAmanage.NASettingsSet("cmdbar2AutoRun", v)
	DoNotif("cmdbar2 "..(v and "will open on start" or "will not auto-open on start"), 2)
end)
NAmanage.RegisterToggleAutoSync("Run cmdbar2 on Start", function()
	return NAStuff.CmdBar2AutoRun == true
end)

NAgui.addSlider("cmdbar2 Width", NAStuff.CmdBar2.minWidth, NAStuff.CmdBar2.maxWidth, NAmanage.CmdBar2ClampValue(NAStuff.CmdBar2Width, NAStuff.CmdBar2.minWidth, NAStuff.CmdBar2.maxWidth, NAStuff.CmdBar2.defaultWidth), 2, " px", function(val)
	NAmanage.CmdBar2ApplySize({
		width = val,
		height = NAStuff.CmdBar2Height,
	})
end)

NAgui.addSlider("cmdbar2 Height", NAStuff.CmdBar2.minHeight, NAStuff.CmdBar2.maxHeight, NAmanage.CmdBar2ClampValue(NAStuff.CmdBar2Height, NAStuff.CmdBar2.minHeight, NAStuff.CmdBar2.maxHeight, NAStuff.CmdBar2.defaultHeight), 1, " px", function(val)
	NAmanage.CmdBar2ApplySize({
		width = NAStuff.CmdBar2Width,
		height = val,
	})
end)

NAgui.setTab(NA_TABS.TAB_MANAGEMENT)

NAStuff.MgmtUI = NAStuff.MgmtUI or {}
NAStuff.MgmtUI.loopCmd = type(NAStuff.MgmtUI.loopCmd) == "string" and NAStuff.MgmtUI.loopCmd or ""
NAStuff.MgmtUI.loopDel = type(NAStuff.MgmtUI.loopDel) == "string" and NAStuff.MgmtUI.loopDel or "1"
NAStuff.MgmtUI.loopMethod = type(NAStuff.MgmtUI.loopMethod) == "string" and NAStuff.MgmtUI.loopMethod or NAmanage.SanitizeLoopMethod(NAStuff.LoopMethod)
NAStuff.MgmtUI.aexecCmd = type(NAStuff.MgmtUI.aexecCmd) == "string" and NAStuff.MgmtUI.aexecCmd or ""
NAStuff.MgmtUI.loopSel = type(NAStuff.MgmtUI.loopSel) == "string" and NAStuff.MgmtUI.loopSel or "None"
NAStuff.MgmtUI.loopSelKey = type(NAStuff.MgmtUI.loopSelKey) == "string" and NAStuff.MgmtUI.loopSelKey or nil
NAStuff.MgmtUI.aexecSel = type(NAStuff.MgmtUI.aexecSel) == "string" and NAStuff.MgmtUI.aexecSel or "None"
NAStuff.MgmtUI.jobSel = type(NAStuff.MgmtUI.jobSel) == "string" and NAStuff.MgmtUI.jobSel or "None"
NAStuff.MgmtUI.jobSelId = type(NAStuff.MgmtUI.jobSelId) == "string" and NAStuff.MgmtUI.jobSelId or nil
NAStuff.MgmtUI.jobKind = type(NAStuff.MgmtUI.jobKind) == "string" and NAStuff.MgmtUI.jobKind or "All"
NAStuff.MgmtUI.logFilter = type(NAStuff.MgmtUI.logFilter) == "string" and NAStuff.MgmtUI.logFilter or tostring(NAStuff.ManagementLogFilter or "All")
NAStuff.MgmtUI.logLines = tostring(math.clamp(math.floor(tonumber(NAStuff.MgmtUI.logLines) or tonumber(NAStuff.ManagementLogLines) or 100), 10, 1000))

NAStuff.loopLbl = NAStuff.loopLbl or "Active Command Loops"
NAStuff.aeLbl = NAStuff.aeLbl or "Stored AutoExec Commands"
NAStuff.jobLbl = NAStuff.jobLbl or "Active Automation Jobs"
NAStuff.loopMap = NAStuff.loopMap or {}
NAStuff.aeMap = NAStuff.aeMap or {}
NAStuff.jobMap = NAStuff.jobMap or {}

NAmanage.getDDTxt=function(sel)
	if type(sel) == "table" then
		return sel[1]
	end
	if type(sel) == "string" then
		return sel
	end
	return nil
end

NAmanage.ManagementClipboardSet = function(text)
	local setter
	if type(NAmanage.CmdInputGetClipboardSet) == "function" then
		setter = NAmanage.CmdInputGetClipboardSet()
	end
	if type(setter) ~= "function" then
		setter = type(setclipboard) == "function" and setclipboard or (type(toclipboard) == "function" and toclipboard or nil)
	end
	if type(setter) ~= "function" then
		return false, "Clipboard is unavailable."
	end
	local ok, err = pcall(setter, tostring(text or ""))
	if not ok then
		return false, "Clipboard failed: "..tostring(err)
	end
	return true
end

NAmanage.GetLoopBySelection = function()
	local key = NAStuff.MgmtUI.loopSelKey
	if type(key) ~= "string" or not Loops[key] then
		key = NAStuff.loopMap[NAStuff.MgmtUI.loopSel or ""]
	end
	if type(key) ~= "string" then
		return nil, nil
	end
	return key, Loops[key]
end

NAmanage.syncLoopDD=function()
	local wantedKey = NAStuff.MgmtUI.loopSelKey or NAStuff.loopMap[NAStuff.MgmtUI.loopSel or ""]
	NAStuff.loopMap = {}
	const reverseMap = {}
	local options = {}
	const entries = NAmanage.GetLoops()

	for i = 1, #entries do
		const entry = entries[i]
		options[#options + 1] = entry.label
		NAStuff.loopMap[entry.label] = entry.key
		reverseMap[entry.key] = entry.label
	end

	if #options == 0 then
		options = { "None" }
	end

	if NAgui.setDropdownOptions then
		NAgui.setDropdownOptions(NAStuff.loopLbl, options)
	end

	local sel = type(wantedKey) == "string" and reverseMap[wantedKey] or nil
	if not sel then
		sel = "None"
		wantedKey = nil
	end
	NAStuff.MgmtUI.loopSel = sel
	NAStuff.MgmtUI.loopSelKey = wantedKey

	if NAgui.setDropdownValue then
		NAgui.setDropdownValue(NAStuff.loopLbl, sel, { fire = false })
	end
end

NAmanage.syncAeDD=function()
	const wanted = NAStuff.MgmtUI.aexecSel
	NAStuff.aeMap = {}
	local options = {}
	const entries = NAmanage.GetAExec()

	for i = 1, #entries do
		const entry = entries[i]
		options[#options + 1] = entry.display
		NAStuff.aeMap[entry.display] = {
			command = entry.command,
			args = entry.args,
			index = entry.index,
		}
	end

	if #options == 0 then
		options = { "None" }
	end

	if NAgui.setDropdownOptions then
		NAgui.setDropdownOptions(NAStuff.aeLbl, options)
	end

	local sel = wanted
	if not sel or not NAStuff.aeMap[sel] then
		sel = "None"
	end
	NAStuff.MgmtUI.aexecSel = sel

	if NAgui.setDropdownValue then
		NAgui.setDropdownValue(NAStuff.aeLbl, sel, { fire = false })
	end
end

NAmanage.GetAutomationJobs = function()
	const entries = {}
	if type(NAjobs) ~= "table" or type(NAjobs.jobs) ~= "table" then
		return entries
	end
	for id, job in NAjobs.jobs do
		if type(job) == "table" then
			const kind = tostring(job.kind or "unknown")
			local target = tostring(job.target or "")
			if target == "" then
				target = "all"
			end
			const mode = job.useFind == true and "partial" or "exact"
			const label = Format("[%s] %s | Target: %s | Delay: %ss | %s | %s", tostring(id), kind, target, tostring(job.interval or 0), tostring(job.method or NAmanage.GetAutoFireDefaultMethod(kind)), mode)
			entries[#entries + 1] = {
				id = tostring(id),
				job = job,
				label = label,
			}
		end
	end
	table.sort(entries, function(a, b)
		return tostring(a.label) < tostring(b.label)
	end)
	return entries
end

NAmanage.syncJobDD = function()
	local wantedId = NAStuff.MgmtUI.jobSelId or NAStuff.jobMap[NAStuff.MgmtUI.jobSel or ""]
	NAStuff.jobMap = {}
	const reverseMap = {}
	local options = {}
	const entries = NAmanage.GetAutomationJobs()
	for i = 1, #entries do
		const entry = entries[i]
		options[#options + 1] = entry.label
		NAStuff.jobMap[entry.label] = entry.id
		reverseMap[entry.id] = entry.label
	end
	if #options == 0 then
		options = { "None" }
	end
	if NAgui.setDropdownOptions then
		NAgui.setDropdownOptions(NAStuff.jobLbl, options)
	end
	local sel = type(wantedId) == "string" and reverseMap[wantedId] or nil
	if not sel then
		sel = "None"
		wantedId = nil
	end
	NAStuff.MgmtUI.jobSel = sel
	NAStuff.MgmtUI.jobSelId = wantedId
	if NAgui.setDropdownValue then
		NAgui.setDropdownValue(NAStuff.jobLbl, sel, { fire = false })
	end
end

NAmanage.PauseLoop = function(loopKey)
	const loopData = type(loopKey) == "string" and Loops[loopKey] or nil
	if not loopData then
		return false, "Loop not found."
	end
	if loopData.running ~= true then
		return false, "Loop is already paused."
	end
	loopData.running = false
	if loopData.key then
		NAlib.disconnect(loopData.key)
	end
	return true, loopData
end

NAmanage.ResumeLoop = function(loopKey)
	const loopData = type(loopKey) == "string" and Loops[loopKey] or nil
	if not loopData then
		return false, "Loop not found."
	end
	if loopData.running == true then
		return false, "Loop is already running."
	end
	loopData.running = true
	local ok, message = NAmanage.ConnectLoop(loopKey)
	if not ok then
		loopData.running = false
		return false, message or "Unable to resume loop."
	end
	return true, loopData
end

NAmanage.RunLoopOnce = function(loopKey)
	const loopData = type(loopKey) == "string" and Loops[loopKey] or nil
	if not loopData then
		return false, "Loop not found."
	end
	local ok, err = pcall(function()
		loopData.command(Unpack(loopData.args or {}))
	end)
	if not ok then
		return false, "Loop command failed: "..tostring(err)
	end
	return true, loopData
end

NAmanage.UpdateLoop = function(loopKey, interval, method)
	const loopData = type(loopKey) == "string" and Loops[loopKey] or nil
	if not loopData then
		return false, "Loop not found."
	end
	const value = tonumber(interval)
	if value == nil or value < 0 then
		return false, "Loop delay must be a number at or above 0."
	end
	loopData.interval = value
	loopData.method = NAmanage.SanitizeLoopMethod(method or loopData.method or NAStuff.LoopMethod)
	if loopData.running == true then
		local ok, message = NAmanage.ConnectLoop(loopKey)
		if not ok then
			return false, message or "Unable to rebind loop."
		end
	end
	return true, loopData
end

NAmanage.StopAllLoops = function()
	const keys = {}
	for key in Loops do
		keys[#keys + 1] = key
	end
	local stopped = 0
	for i = 1, #keys do
		const ok = NAmanage.StopLoop(keys[i])
		if ok then
			stopped += 1
		end
	end
	return stopped
end

NAmanage.RunAutoExecEntry = function(entry)
	if type(entry) ~= "table" or type(entry.command) ~= "string" then
		return false, "No AutoExec command selected."
	end
	const run = { entry.command }
	if type(entry.args) == "string" and entry.args ~= "" then
		const parsed = ParseArguments(entry.args)
		if type(parsed) == "table" then
			for i = 1, #parsed do
				run[#run + 1] = parsed[i]
			end
		end
	end
	Spawn(function()
		pcall(cmd.run, run)
	end)
	return true, NAmanage.FmtAExec(entry.command, entry.args)
end

NAmanage.RunAllAutoExec = function()
	const entries = NAmanage.GetAExec()
	for i = 1, #entries do
		NAmanage.RunAutoExecEntry(entries[i])
	end
	return #entries
end

NAmanage.ReplaceAEXTxt = function(oldCommand, oldArgs, rawText)
	const data = NAmanage.EnsureAEX()
	const index = NAmanage.FindAEX(oldCommand, oldArgs)
	if not index then
		return false, "Selected AutoExec command no longer exists."
	end
	const parsed = ParseArguments(tostring(rawText or ""))
	if type(parsed) ~= "table" or not parsed[1] then
		return false, "Enter a replacement command."
	end
	const rawName = Lower(tostring(parsed[1]))
	const canonical = NAmanage.resolveCommandName(rawName)
	if not canonical then
		return false, "Command ["..rawName.."] does not exist"
	end
	if NAStuff.AutoExecBlockedCommands[canonical] then
		return false, "Command ["..canonical.."] is blocked."
	end
	table.remove(parsed, 1)
	const argString = #parsed > 0 and Concat(parsed, " ") or ""
	const duplicateIndex = NAmanage.FindAEX(canonical, argString)
	if duplicateIndex and duplicateIndex ~= index then
		return false, "Already in AutoExec: "..NAmanage.FmtAExec(canonical, argString)
	end
	data.commands[index] = { c = canonical, a = argString }
	if not NAmanage.AutoExecSave(data) then
		DebugNotif("Failed to save AutoExec changes; they will reset after this session.")
	end
	return true, NAmanage.FmtAExec(canonical, argString)
end

NAmanage.ExportAutoExecText = function()
	const entries = NAmanage.GetAExec()
	const lines = {}
	for i = 1, #entries do
		lines[i] = entries[i].display
	end
	return Concat(lines, "\n"), #entries
end

NAmanage.ManagementCountConnections = function()
	local groups = 0
	local total = 0
	if type(NAStuff.conns) ~= "table" then
		return groups, total
	end
	const names = {}
	for name in NAStuff.conns do
		names[#names + 1] = name
	end
	for i = 1, #names do
		const count = type(NAmanage.prnCon) == "function" and NAmanage.prnCon(names[i]) or 0
		if count > 0 then
			groups += 1
			total += count
		end
	end
	return groups, total
end

NAmanage.GetStartupPerformanceSnapshot = function()
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) ~= "table" then
		return nil
	end
	const function copyList(list, limit)
		const out = {}
		if type(list) == "table" then
			for i = 1, math.min(#list, limit or 12) do
				const item = list[i]
				if type(item) == "table" then
					out[#out + 1] = {
						name = item.name,
						at = item.at,
						elapsed = item.elapsed,
						dt = item.dt,
						attempt = item.attempt,
						index = item.index,
						ok = item.ok,
					}
				end
			end
		end
		return out
	end
	return {
		finished = perf.finished == true,
		elapsed = perf.elapsed,
		readyElapsed = perf.readyElapsed,
		readyBeforeSettings = perf.readyBeforeSettings,
		finishedStatus = perf.finishedStatus,
		reloadIndex = perf.reloadIndex,
		maxFrame = perf.maxFrame,
		frames = perf.frames,
		spikes = copyList(perf.spikes, 12),
		stages = copyList(perf.stages, 24),
		uiFetchElapsed = perf.uiFetchElapsed,
		uiPrepareElapsed = perf.uiPrepareElapsed,
		uiCompileElapsed = perf.uiCompileElapsed,
		uiLoaderRunElapsed = perf.uiLoaderRunElapsed,
		uiRegisterElapsed = perf.uiRegisterElapsed,
		uiWaitElapsed = perf.uiWaitElapsed,
		uiWaitOk = perf.uiWaitOk,
		uiManagerElapsed = perf.uiManagerElapsed,
		uiRunAttempts = copyList(perf.uiRunAttempts, 12),
		loaderTasks = copyList(perf.loaderTasks, 16),
		uiSourceInstances = perf.uiSourceInstances,
		instanceYields = perf.instanceYields,
		commandYields = perf.commandYields,
		instanceNameElapsed = perf.instanceNameElapsed,
		instanceNameCount = perf.instanceNameCount,
		settingsBuildElapsed = perf.settingsBuildElapsed,
		settingsBuildOk = perf.settingsBuildOk,
		autoExecCount = perf.autoExecCount,
		autoExecElapsed = perf.autoExecElapsed,
		autoExecTotalElapsed = perf.autoExecTotalElapsed,
		autoExecMaxElapsed = perf.autoExecMaxElapsed,
		autoExecMaxCommand = perf.autoExecMaxCommand,
		autoExecCommands = copyList(perf.autoExecCommands, 20),
		staffwatchScanElapsed = perf.staffwatchScanElapsed,
		staffwatchScanPlayers = perf.staffwatchScanPlayers,
		assetPreloadDelay = perf.assetPreloadDelay,
		assetScanElapsed = perf.assetScanElapsed,
		assetPreloadElapsed = perf.assetPreloadElapsed,
		assetPreloadTotal = perf.assetPreloadTotal,
		assetPreloadLowImpact = perf.assetPreloadLowImpact,
		assetPreloadChunkSize = perf.assetPreloadChunkSize,
		assetPreloadChunkYield = perf.assetPreloadChunkYield,
		assetPreloadChunks = perf.assetPreloadChunks,
		assetPreloadMaxChunk = perf.assetPreloadMaxChunk,
	}
end

NAmanage.GetManagementSnapshot = function()
	local loopsRunning = 0
	local loopsPaused = 0
	for _, loopData in Loops do
		if type(loopData) == "table" and loopData.running == true then
			loopsRunning += 1
		else
			loopsPaused += 1
		end
	end

	const jobCounts = {
		prompt = 0,
		click = 0,
		touch = 0,
		remote = 0,
		other = 0,
	}
	local jobsTotal = 0
	if type(NAjobs) == "table" and type(NAjobs.jobs) == "table" then
		for _, job in NAjobs.jobs do
			jobsTotal += 1
			local kind = type(job) == "table" and tostring(job.kind or "other") or "other"
			if jobCounts[kind] == nil then
				kind = "other"
			end
			jobCounts[kind] += 1
		end
	end

	const autoExecCount = #NAmanage.GetAExec()
	local connGroups, connTotal = NAmanage.ManagementCountConnections()
	const memory = tonumber(NAmanage.getMemoryMb and NAmanage.getMemoryMb())
	const fps = tonumber(NAmanage.getRealFPS and NAmanage.getRealFPS()) or 0
	const ping = tonumber(NAmanage.GetDataPingMs and NAmanage.GetDataPingMs()) or 0
	const uptime = math.max(0, os.clock() - (tonumber(NASESSIONSTARTEDIDK) or os.clock()))
	const hours = math.floor(uptime / 3600)
	const minutes = math.floor((uptime % 3600) / 60)
	const seconds = math.floor(uptime % 60)
	const uptimeText = hours > 0 and Format("%dh %02dm %02ds", hours, minutes, seconds) or Format("%dm %02ds", minutes, seconds)

	return {
		loopsRunning = loopsRunning,
		loopsPaused = loopsPaused,
		autoExecCount = autoExecCount,
		jobsTotal = jobsTotal,
		jobCounts = jobCounts,
		connGroups = connGroups,
		connTotal = connTotal,
		memory = memory,
		fps = fps,
		ping = ping,
		uptime = uptimeText,
		placeId = tostring(game.PlaceId),
		gameId = tostring(game.GameId),
		jobId = tostring(game.JobId),
		startupPerformance = type(NAmanage.GetStartupPerformanceSnapshot) == "function" and NAmanage.GetStartupPerformanceSnapshot() or nil,
	}
end

NAmanage.RefreshManagementSummary = function()
	const snapshot = NAmanage.GetManagementSnapshot()
	const commandText = Format("Loops: %d running / %d paused | AutoExec: %d", snapshot.loopsRunning, snapshot.loopsPaused, snapshot.autoExecCount)
	const automationText = Format("Jobs: %d | Prompt %d | Click %d | Touch %d | Remote %d", snapshot.jobsTotal, snapshot.jobCounts.prompt, snapshot.jobCounts.click, snapshot.jobCounts.touch, snapshot.jobCounts.remote)
	const memoryText = snapshot.memory and Format("%.1f MB", snapshot.memory) or "Unknown"
	const clientText = Format("FPS %d | Ping %d ms | Memory %s | Connections %d/%d | Uptime %s", snapshot.fps, snapshot.ping, memoryText, snapshot.connTotal, snapshot.connGroups, snapshot.uptime)

	const function updateInfo(box, value)
		if box and box.Parent and box.Text ~= value then
			box.Text = value
		end
	end
	updateInfo(NAStuff.MgmtCommandInfo, commandText)
	updateInfo(NAStuff.MgmtAutomationInfo, automationText)
	updateInfo(NAStuff.MgmtClientInfo, clientText)
	return snapshot
end

NAmanage.FormatManagementSnapshot = function(snapshot)
	snapshot = type(snapshot) == "table" and snapshot or NAmanage.GetManagementSnapshot()
	const memoryText = snapshot.memory and Format("%.2f MB", snapshot.memory) or "Unknown"
	return Concat({
		"Nameless Admin Runtime Snapshot",
		"PlaceId: "..snapshot.placeId,
		"GameId: "..snapshot.gameId,
		"JobId: "..snapshot.jobId,
		"Uptime: "..snapshot.uptime,
		Format("FPS: %d", snapshot.fps),
		Format("Ping: %d ms", snapshot.ping),
		"Memory: "..memoryText,
		Format("Command loops: %d running, %d paused", snapshot.loopsRunning, snapshot.loopsPaused),
		Format("AutoExec entries: %d", snapshot.autoExecCount),
		Format("Automation jobs: %d (prompt %d, click %d, touch %d, remote %d, other %d)", snapshot.jobsTotal, snapshot.jobCounts.prompt, snapshot.jobCounts.click, snapshot.jobCounts.touch, snapshot.jobCounts.remote, snapshot.jobCounts.other),
		Format("Tracked connections: %d across %d groups", snapshot.connTotal, snapshot.connGroups),
	}, "\n")
end

NAmanage.GetRecentClientLogs = function(limit, filter)
	limit = math.clamp(math.floor(tonumber(limit) or 100), 10, 1000)
	filter = tostring(filter or "All")
	if not Services.LogService then
		return false, "LogService is unavailable."
	end
	local ok, history = pcall(function()
		if type(__lt) == "table" and type(__lt.cm) == "function" then
			return __lt.cm("LogService", "GetLogHistory")
		end
		return Services.LogService:GetLogHistory()
	end)
	if not ok or type(history) ~= "table" then
		return false, "Unable to read client logs."
	end
	const reversed = {}
	for i = #history, 1, -1 do
		const entry = history[i]
		if type(entry) == "table" then
			const messageType = tostring(entry.messageType or entry.MessageType or "Output")
			const lowerType = Lower(messageType)
			const include = filter == "All"
				or (filter == "Warnings & Errors" and (Find(lowerType, "warning", 1, true) or Find(lowerType, "error", 1, true)))
				or (filter == "Errors Only" and Find(lowerType, "error", 1, true))
			if include then
				const message = tostring(entry.message or entry.Message or "")
				const timestamp = entry.timestamp or entry.Timestamp
				const prefix = timestamp ~= nil and ("["..tostring(timestamp).."] ") or ""
				reversed[#reversed + 1] = prefix.."["..messageType.."] "..message
				if #reversed >= limit then
					break
				end
			end
		end
	end
	const lines = {}
	for i = #reversed, 1, -1 do
		lines[#lines + 1] = reversed[i]
	end
	return true, Concat(lines, "\n"), #lines
end

NAmanage.SetManagementAutoRefresh = function(enabled, opts)
	const state = enabled == true
	NAStuff.ManagementAutoRefresh = state
	if not opts or opts.save ~= false then
		pcall(NAmanage.NASettingsSet, "managementAutoRefresh", state)
	end
	NAlib.disconnect("ManagementDashboardAutoRefresh")
	if state and Services.RunService and Services.RunService.Heartbeat then
		local elapsed = 0
		NAlib.connect("ManagementDashboardAutoRefresh", Services.RunService.Heartbeat:Connect(function(dt)
			elapsed += tonumber(dt) or 0
			const interval = math.clamp(tonumber(NAStuff.ManagementRefreshInterval) or 2, 0.5, 10)
			if elapsed >= interval then
				elapsed %= interval
				if type(NAmanage.RefreshManagementSummary) == "function" then
					NAmanage.RefreshManagementSummary()
				end
			end
		end))
	end
	return state
end

NAgui.addSection("Command Loop Manager")

NAgui.addDropdown("Command Loop Method", NAStuff.LoopMethodOptions or { "PostSimulation", "PreSimulation", "RenderStepped", "Heartbeat" }, NAmanage.SanitizeLoopMethod(NAStuff.LoopMethod), function(sel)
	const txt = NAmanage.getDDTxt(sel) or "PostSimulation"
	const picked = NAmanage.SetLoopMethod(txt, { save = true; rebind = true })
	NAStuff.MgmtUI.loopMethod = picked
	if NAgui.setDropdownValue then
		NAgui.setDropdownValue("Command Loop Method", picked, { fire = false })
		NAgui.setDropdownValue("Selected Loop Method", picked, { fire = false })
	end
	NAmanage.syncLoopDD()
	NAmanage.RefreshManagementSummary()
	DoNotif("Command loop method set to "..picked, 2)
end)

NAgui.addInput("Loop Command", "command arguments", NAStuff.MgmtUI.loopCmd, function(text)
	NAStuff.MgmtUI.loopCmd = tostring(text or "")
end)

NAgui.addInput("Loop Delay", "seconds (0 = every frame)", NAStuff.MgmtUI.loopDel, function(text)
	NAStuff.MgmtUI.loopDel = tostring(text or "")
end)

NAgui.addDropdown("Selected Loop Method", NAStuff.LoopMethodOptions or { "PostSimulation", "PreSimulation", "RenderStepped", "Heartbeat" }, NAStuff.MgmtUI.loopMethod, function(sel)
	NAStuff.MgmtUI.loopMethod = NAmanage.SanitizeLoopMethod(NAmanage.getDDTxt(sel) or NAStuff.LoopMethod)
end)

NAgui.addButton("Start Loop", function()
	const parsed = ParseArguments(tostring(NAStuff.MgmtUI.loopCmd or ""))
	if type(parsed) ~= "table" or not parsed[1] then
		DoNotif("Enter a command to loop.", 2)
		return
	end
	const cmdName = parsed[1]
	table.remove(parsed, 1)
	const interval = tonumber(NAStuff.MgmtUI.loopDel)
	if interval == nil then
		DoNotif("Loop delay must be a number.", 2)
		return
	end
	local ok, result, loopData = NAmanage.StartLoop(cmdName, parsed, interval, NAStuff.MgmtUI.loopMethod)
	if not ok then
		DoNotif(result, 2)
		return
	end
	NAStuff.MgmtUI.loopSelKey = result
	DoNotif("Loop started for '"..cmdName.."' with delay: "..loopData.interval.."s. Method: "..(loopData.method or NAmanage.SanitizeLoopMethod(NAStuff.LoopMethod))..". Args: "..NAmanage.FmtLoop(loopData.args), 2)
	NAmanage.syncLoopDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addDropdown(NAStuff.loopLbl, { "None" }, "None", function(sel)
	const txt = NAmanage.getDDTxt(sel) or "None"
	NAStuff.MgmtUI.loopSel = txt
	NAStuff.MgmtUI.loopSelKey = NAStuff.loopMap[txt]
end)

NAgui.addButton("Load Selected Loop", function()
	local _, loopData = NAmanage.GetLoopBySelection()
	if not loopData then
		DoNotif("No command loop selected.", 2)
		return
	end
	local commandText = tostring(loopData.commandName or "")
	if type(loopData.args) == "table" and #loopData.args > 0 then
		commandText ..= " "..Concat(loopData.args, " ")
	end
	NAStuff.MgmtUI.loopCmd = commandText
	NAStuff.MgmtUI.loopDel = tostring(loopData.interval or 0)
	NAStuff.MgmtUI.loopMethod = NAmanage.SanitizeLoopMethod(loopData.method or NAStuff.LoopMethod)
	if NAgui.setInputValue then
		NAgui.setInputValue("Loop Command", commandText)
		NAgui.setInputValue("Loop Delay", NAStuff.MgmtUI.loopDel)
	end
	if NAgui.setDropdownValue then
		NAgui.setDropdownValue("Selected Loop Method", NAStuff.MgmtUI.loopMethod, { fire = false })
	end
	DoNotif("Selected loop loaded into the editor.", 2)
end)

NAgui.addButton("Apply Selected Loop Changes", function()
	const key = NAmanage.GetLoopBySelection()
	if not key then
		DoNotif("No command loop selected.", 2)
		return
	end
	local ok, result = NAmanage.UpdateLoop(key, NAStuff.MgmtUI.loopDel, NAStuff.MgmtUI.loopMethod)
	if not ok then
		DoNotif(result, 2)
		return
	end
	DoNotif("Updated loop delay to "..tostring(result.interval).."s and method to "..tostring(result.method)..".", 2)
	NAmanage.syncLoopDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Run Selected Loop Once", function()
	const key = NAmanage.GetLoopBySelection()
	if not key then
		DoNotif("No command loop selected.", 2)
		return
	end
	local ok, result = NAmanage.RunLoopOnce(key)
	DoNotif(ok and ("Ran loop once: "..tostring(result.commandName)) or result, 2)
end)

NAgui.addButton("Pause / Resume Selected Loop", function()
	local key, loopData = NAmanage.GetLoopBySelection()
	if not key or not loopData then
		DoNotif("No command loop selected.", 2)
		return
	end
	local ok, result
	if loopData.running == true then
		ok, result = NAmanage.PauseLoop(key)
	else
		ok, result = NAmanage.ResumeLoop(key)
	end
	if not ok then
		DoNotif(result, 2)
		return
	end
	DoNotif("Loop "..(result.running == true and "resumed" or "paused")..": "..tostring(result.commandName), 2)
	NAmanage.syncLoopDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Stop Selected Loop", function()
	const loopKey = NAmanage.GetLoopBySelection()
	if not loopKey then
		DoNotif("No active loop selected.", 2)
		NAmanage.syncLoopDD()
		return
	end
	local ok, result = NAmanage.StopLoop(loopKey)
	if not ok then
		DoNotif(result, 2)
		NAmanage.syncLoopDD()
		return
	end
	NAStuff.MgmtUI.loopSelKey = nil
	DoNotif("Stopped loop: '"..result.commandName.."' with args: "..NAmanage.FmtLoop(result.args), 2)
	NAmanage.syncLoopDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Stop All Command Loops", function()
	const stopped = NAmanage.StopAllLoops()
	NAStuff.MgmtUI.loopSelKey = nil
	NAmanage.syncLoopDD()
	NAmanage.RefreshManagementSummary()
	DoNotif(stopped > 0 and ("Stopped "..tostring(stopped).." command loop"..(stopped == 1 and "" or "s")..".") or "No command loops were active.", 2)
end)

NAgui.addButton("Refresh Loop List", function()
	NAmanage.syncLoopDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addSection("AutoExec Manager")

NAgui.addInput("AutoExec Command", "command arguments", NAStuff.MgmtUI.aexecCmd, function(text)
	NAStuff.MgmtUI.aexecCmd = tostring(text or "")
end)

NAgui.addButton("Add AutoExec Entry", function()
	local ok, message = NAmanage.AddAEXTxt(NAStuff.MgmtUI.aexecCmd)
	if not ok then
		DoNotif(message, 2)
		return
	end
	NAStuff.MgmtUI.aexecSel = message
	DoNotif("Added to AutoExec: "..message, 2)
	NAmanage.syncAeDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addDropdown(NAStuff.aeLbl, { "None" }, "None", function(sel)
	const txt = NAmanage.getDDTxt(sel) or "None"
	NAStuff.MgmtUI.aexecSel = txt
end)

NAgui.addButton("Load Selected AutoExec", function()
	const entry = NAStuff.aeMap[NAStuff.MgmtUI.aexecSel or ""]
	if not entry then
		DoNotif("No AutoExec command selected.", 2)
		return
	end
	const textValue = NAmanage.FmtAExec(entry.command, entry.args)
	NAStuff.MgmtUI.aexecCmd = textValue
	if NAgui.setInputValue then
		NAgui.setInputValue("AutoExec Command", textValue)
	end
	DoNotif("Selected AutoExec entry loaded into the editor.", 2)
end)

NAgui.addButton("Replace Selected AutoExec", function()
	const entry = NAStuff.aeMap[NAStuff.MgmtUI.aexecSel or ""]
	if not entry then
		DoNotif("No AutoExec command selected.", 2)
		return
	end
	local ok, message = NAmanage.ReplaceAEXTxt(entry.command, entry.args, NAStuff.MgmtUI.aexecCmd)
	if not ok then
		DoNotif(message, 2)
		return
	end
	NAStuff.MgmtUI.aexecSel = message
	DoNotif("Replaced AutoExec entry with: "..message, 2)
	NAmanage.syncAeDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Run Selected AutoExec Now", function()
	const entry = NAStuff.aeMap[NAStuff.MgmtUI.aexecSel or ""]
	local ok, message = NAmanage.RunAutoExecEntry(entry)
	DoNotif(ok and ("Ran AutoExec: "..message) or message, 2)
end)

NAgui.addButton("Run All AutoExec Now", function()
	const count = NAmanage.RunAllAutoExec()
	DoNotif(count > 0 and ("Ran "..tostring(count).." AutoExec command"..(count == 1 and "" or "s")..".") or "No AutoExec commands are stored.", 2)
end)

NAgui.addButton("Remove Selected AutoExec", function()
	const aeEnt = NAStuff.aeMap[NAStuff.MgmtUI.aexecSel or ""]
	if not aeEnt then
		DoNotif("No AutoExec command selected.", 2)
		NAmanage.syncAeDD()
		return
	end
	local ok, message = NAmanage.DelAEX(aeEnt.command, aeEnt.args)
	if not ok then
		DoNotif(message, 2)
		NAmanage.syncAeDD()
		return
	end
	NAStuff.MgmtUI.aexecSel = "None"
	DoNotif("Removed AutoExec command: "..message, 2)
	NAmanage.syncAeDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Export AutoExec List", function()
	local payload, count = NAmanage.ExportAutoExecText()
	if count == 0 then
		DoNotif("No AutoExec commands are stored.", 2)
		return
	end
	local ok, message = NAmanage.ManagementClipboardSet(payload)
	DoNotif(ok and ("Copied "..tostring(count).." AutoExec command"..(count == 1 and "" or "s")..".") or message, 2)
end)

NAgui.addButton("Clear All AutoExec", function()
	local ok, result = NAmanage.ClrAEX()
	if not ok then
		DoNotif(result, 2)
		return
	end
	NAStuff.MgmtUI.aexecSel = "None"
	DoNotif("Cleared "..tostring(result).." AutoExec command"..(result == 1 and "" or "s"), 2)
	NAmanage.syncAeDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Refresh AutoExec List", function()
	NAmanage.syncAeDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addSection("Automation Job Manager")

NAgui.addDropdown(NAStuff.jobLbl, { "None" }, "None", function(sel)
	const txt = NAmanage.getDDTxt(sel) or "None"
	NAStuff.MgmtUI.jobSel = txt
	NAStuff.MgmtUI.jobSelId = NAStuff.jobMap[txt]
end)

NAgui.addDropdown("Automation Job Type", { "All", "Prompt", "Click", "Touch", "Remote" }, NAStuff.MgmtUI.jobKind, function(sel)
	NAStuff.MgmtUI.jobKind = NAmanage.getDDTxt(sel) or "All"
end)

NAgui.addButton("Stop Selected Automation Job", function()
	const id = NAStuff.MgmtUI.jobSelId or NAStuff.jobMap[NAStuff.MgmtUI.jobSel or ""]
	if not id or not (NAjobs.jobs and NAjobs.jobs[id]) then
		DoNotif("No automation job selected.", 2)
		NAmanage.syncJobDD()
		return
	end
	NAjobs.stopById(id)
	NAStuff.MgmtUI.jobSelId = nil
	DoNotif("Stopped automation job: "..tostring(id), 2)
	NAmanage.syncJobDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Stop Selected Automation Type", function()
	const picked = tostring(NAStuff.MgmtUI.jobKind or "All")
	if picked == "All" then
		const count = #NAmanage.GetAutomationJobs()
		NAjobs.stopAll()
		DoNotif(count > 0 and ("Stopped "..tostring(count).." automation job"..(count == 1 and "" or "s")..".") or "No automation jobs were active.", 2)
	else
		const kind = Lower(picked)
		local count = 0
		for _, entry in NAmanage.GetAutomationJobs() do
			if type(entry.job) == "table" and tostring(entry.job.kind) == kind then
				count += 1
			end
		end
		NAjobs.stopByKind(kind)
		DoNotif(count > 0 and ("Stopped "..tostring(count).." "..kind.." automation job"..(count == 1 and "" or "s")..".") or ("No "..kind.." automation jobs were active."), 2)
	end
	NAStuff.MgmtUI.jobSelId = nil
	NAmanage.syncJobDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addButton("Stop All Automation Jobs", function()
	const count = #NAmanage.GetAutomationJobs()
	NAjobs.stopAll()
	NAStuff.MgmtUI.jobSelId = nil
	NAmanage.syncJobDD()
	NAmanage.RefreshManagementSummary()
	DoNotif(count > 0 and ("Stopped "..tostring(count).." automation job"..(count == 1 and "" or "s")..".") or "No automation jobs were active.", 2)
end)

NAgui.addButton("Refresh Automation List", function()
	NAmanage.syncJobDD()
	NAmanage.RefreshManagementSummary()
end)

NAgui.addSection("MCP Bridge")
NAgui.addToggle("MCP Activity Notifications", NAStuff.MCP and NAStuff.MCP.notifyCommands ~= false, function(v)
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	NAStuff.MCP.notifyCommands = v == true
	pcall(NAmanage.NASettingsSet, "mcpNotifyActivity", NAStuff.MCP.notifyCommands)
	DoNotif("MCP activity notifications "..(NAStuff.MCP.notifyCommands and "enabled" or "disabled")..".", 2)
end)
NAmanage.RegisterToggleAutoSync("MCP Activity Notifications", function()
	return type(NAStuff.MCP) == "table" and NAStuff.MCP.notifyCommands ~= false
end)

NAgui.addToggle("MCP Read Notifications", NAStuff.MCP and NAStuff.MCP.notifyReads ~= false, function(v)
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	NAStuff.MCP.notifyReads = v == true
	pcall(NAmanage.NASettingsSet, "mcpNotifyReads", NAStuff.MCP.notifyReads)
	DoNotif("MCP read notifications "..(NAStuff.MCP.notifyReads and "enabled" or "disabled")..".", 2)
end)
NAmanage.RegisterToggleAutoSync("MCP Read Notifications", function()
	return type(NAStuff.MCP) == "table" and NAStuff.MCP.notifyReads ~= false
end)

NAgui.addToggle("MCP UI Access", NAStuff.MCP and NAStuff.MCP.allowUIAccess == true, function(v)
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	NAStuff.MCP.allowUIAccess = v == true
	pcall(NAmanage.NASettingsSet, "mcpAllowUIAccess", NAStuff.MCP.allowUIAccess)
	DoNotif("MCP UI access "..(NAStuff.MCP.allowUIAccess and "enabled" or "disabled")..".", 2)
end)
NAmanage.RegisterToggleAutoSync("MCP UI Access", function()
	return type(NAStuff.MCP) == "table" and NAStuff.MCP.allowUIAccess == true
end)

NAgui.addToggle("MCP Command Prediction", NAStuff.MCP and NAStuff.MCP.commandPrediction == true, function(v)
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	NAStuff.MCP.commandPrediction = v == true
	pcall(NAmanage.NASettingsSet, "mcpCommandPrediction", NAStuff.MCP.commandPrediction)
	DoNotif("MCP command prediction "..(NAStuff.MCP.commandPrediction and "enabled" or "disabled")..".", 2)
end)
NAmanage.RegisterToggleAutoSync("MCP Command Prediction", function()
	return type(NAStuff.MCP) == "table" and NAStuff.MCP.commandPrediction == true
end)

NAgui.addInfo("MCP AI Identity", "Model + AI/MCP tool handshake is mandatory before MCP commands, reads, logs, snapshots, or UI access.")

NAgui.addButton("Show MCP AI Identity", function()
	const identity = type(NAmanage.MCPIdentitySnapshot) == "function" and NAmanage.MCPIdentitySnapshot() or nil
	if not identity then
		DoNotif("No AI is identified. Operational MCP helpers are blocked until identify/handshake provides model + tool.", 4, "MCP AI Identity")
		return
	end
	const provider = identity.provider ~= "" and identity.provider or "Unknown"
	const client = identity.client ~= "" and identity.client or "Unknown"
	DoNotif("Tool: "..identity.tool.."\nModel: "..identity.model.."\nClient: "..client.."\nProvider: "..provider, 5, "MCP AI Identity")
end)

NAgui.addButton("Reset MCP AI Identity", function()
	NAStuff.MCP = type(NAStuff.MCP) == "table" and NAStuff.MCP or {}
	const identity = type(NAmanage.MCPIdentitySnapshot) == "function" and NAmanage.MCPIdentitySnapshot() or nil
	if identity and type(NAmanage.MCPNotifyActivity) == "function" then
		pcall(NAmanage.MCPNotifyActivity, "AI identity reset", NAmanage.MCPIdentityLabel(identity), { force = true, identity = identity, duration = 3 })
	end
	NAStuff.MCP.identity = nil
	NAStuff.MCP.actor = ""
	DoNotif("MCP AI identity cleared. The next operational helper must identify its model + tool again.", 3.5, "MCP AI Identity")
end)

NAgui.addSection("Runtime Dashboard")

NAStuff.MgmtCommandInfo = NAgui.addInfo("Command Runtime", "Loading...")
NAStuff.MgmtAutomationInfo = NAgui.addInfo("Automation Runtime", "Loading...")
NAStuff.MgmtClientInfo = NAgui.addInfo("Client Runtime", "Loading...", {
	textScaled = false;
	minTextSize = 9;
})

NAgui.addToggle("Auto-refresh Management Dashboard", NAStuff.ManagementAutoRefresh == true, function(v)
	NAmanage.SetManagementAutoRefresh(v == true, { save = true })
	NAmanage.RefreshManagementSummary()
	DoNotif("Management dashboard auto-refresh "..(v and "enabled" or "disabled")..".", 2)
end)
NAmanage.RegisterToggleAutoSync("Auto-refresh Management Dashboard", function()
	return NAStuff.ManagementAutoRefresh == true
end)

NAgui.addSlider("Dashboard Refresh Interval", 0.5, 10, math.clamp(tonumber(NAStuff.ManagementRefreshInterval) or 2, 0.5, 10), 0.5, " s", function(value)
	const clamped = math.clamp(tonumber(value) or 2, 0.5, 10)
	NAStuff.ManagementRefreshInterval = clamped
	pcall(NAmanage.NASettingsSet, "managementRefreshInterval", clamped)
end)

NAgui.addButton("Refresh Management Dashboard", function()
	NAmanage.syncLoopDD()
	NAmanage.syncAeDD()
	NAmanage.syncJobDD()
	NAmanage.RefreshManagementSummary()
	DoNotif("Management dashboard refreshed.", 2)
end)

NAgui.addButton("Copy Runtime Snapshot", function()
	const snapshot = NAmanage.RefreshManagementSummary()
	local ok, message = NAmanage.ManagementClipboardSet(NAmanage.FormatManagementSnapshot(snapshot))
	DoNotif(ok and "Runtime snapshot copied." or message, 2)
end)

NAgui.addButton("Prune Stale Runtime State", function()
	local ok, err = pcall(NAmanage.pruneRuntimeInstanceState)
	if type(NAindex) == "table" and type(NAindex.pruneCaches) == "function" then
		pcall(NAindex.pruneCaches)
	end
	NAmanage.syncLoopDD()
	NAmanage.syncJobDD()
	NAmanage.RefreshManagementSummary()
	DoNotif(ok and "Stale runtime state and caches were pruned." or ("Runtime prune failed: "..tostring(err)), 2)
end)

NAgui.addSection("Client Log Export")

NAgui.addDropdown("Log Copy Filter", { "All", "Warnings & Errors", "Errors Only" }, NAStuff.MgmtUI.logFilter, function(sel)
	const picked = NAmanage.getDDTxt(sel) or "All"
	NAStuff.MgmtUI.logFilter = picked
	NAStuff.ManagementLogFilter = picked
	pcall(NAmanage.NASettingsSet, "managementLogFilter", picked)
end)

NAgui.addInput("Log Lines to Copy", "10 - 1000", NAStuff.MgmtUI.logLines, function(text)
	const value = math.clamp(math.floor(tonumber(text) or tonumber(NAStuff.ManagementLogLines) or 100), 10, 1000)
	NAStuff.MgmtUI.logLines = tostring(value)
	NAStuff.ManagementLogLines = value
	pcall(NAmanage.NASettingsSet, "managementLogLines", value)
	if NAgui.setInputValue then
		NAgui.setInputValue("Log Lines to Copy", tostring(value))
	end
end)

NAgui.addButton("Copy Recent Client Logs", function()
	local ok, payload, count = NAmanage.GetRecentClientLogs(NAStuff.MgmtUI.logLines, NAStuff.MgmtUI.logFilter)
	if not ok then
		DoNotif(payload, 2)
		return
	end
	if count == 0 then
		DoNotif("No client logs matched the selected filter.", 2)
		return
	end
	local copied, message = NAmanage.ManagementClipboardSet(payload)
	DoNotif(copied and ("Copied "..tostring(count).." client log line"..(count == 1 and "" or "s")..".") or message, 2)
end)

NAgui.addButton("Clear Last Command Replay", function()
	NAStuff._lastCommand = nil
	NAStuff._prevCommand = nil
	DoNotif("Last-command replay history cleared.", 2)
end)

NAmanage.syncLoopDD()
NAmanage.syncAeDD()
NAmanage.syncJobDD()
NAmanage.RefreshManagementSummary()
NAmanage.SetManagementAutoRefresh(NAStuff.ManagementAutoRefresh == true, { save = false })

NAgui.addTab(NA_TABS.TAB_FFLAGS, { order = 4, textIcon = "flag" })
NAgui.setTab(NA_TABS.TAB_FFLAGS)
NAgui.setTab(NA_TABS.TAB_FFLAGS)

const NAFFlags = NAmanage.NAFFlags or {}
NAmanage.NAFFlags = NAFFlags

NAFFlags.whitelist = {
	{ name = "GameBasicSettingsFramerateCap5", default = true, valueType = "boolean", category = "FPS & Frame Timing" };
	{ name = "DebugDisplayFPS", default = true, valueType = "boolean", category = "FPS & Frame Timing" };
	{ name = "MaxFrameBufferSize", default = 4, valueType = "number", category = "FPS & Frame Timing" };
	{ name = "DebugPerfMode", default = true, valueType = "boolean", category = "FPS & Frame Timing" };
	{ name = "TaskSchedulerTargetFps", default = 2147483647, valueType = "number", category = "FPS & Frame Timing" };
	{ name = "TaskSchedulerLimitTargetFpsTo2402", default = false, valueType = "boolean", category = "FPS & Frame Timing" };
	{ name = "GameBasicSettingsFramerateCap", default = 0, valueType = "number", category = "FPS & Frame Timing" };
	{ name = "EnableFPSAndFrameTime", default = true, valueType = "boolean", category = "FPS & Frame Timing" };
	{ name = "PerformanceControlRespectUserFpsOverridden", default = true, valueType = "boolean", category = "FPS & Frame Timing" };

	{ name = "FullscreenTitleBarTriggerDelayMillis", default = 3600000, valueType = "number", category = "Rendering API & Display" };
	{ name = "HandleAltEnterFullscreenManually", default = false, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "DebugGraphicsPreferD3D11", default = false, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "DebugGraphicsPreferD3D11FL10", default = false, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "DebugGraphicsPreferVulkan", default = true, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "DebugGraphicsPreferOpenGL", default = false, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "DebugGraphicsDisableDirect3D11", default = true, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "RenderCheckThreading", default = true, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "DisableDPIScale", default = true, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "GraphicsGLEnableHQShadersExclusion", default = true, valueType = "boolean", category = "Rendering API & Display" };
	{ name = "GraphicsGLEnableSuperHQShadersExclusion", default = true, valueType = "boolean", category = "Rendering API & Display" };

	{ name = "LCCageDeformLimit", default = -1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "RobloxGuiBlurIntensity", default = 0, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "RenderShadowmapBias", default = -1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "DebugForceMSAASamples", default = 0, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "TextureQualityOverrideEnabled", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "TextureQualityOverride", default = 0, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "TextureCompositorLowResFactor", default = 1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "PerformanceControlTextureQualityBestUtility", default = -1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "EnableRequestAsyncCompression", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "DisablePostFx", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "DebugRenderForceTechnologyVoxel", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "NewLightAttenuation", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "RenderShadowIntensity", default = 0, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "RomarkStartWithGraphicQualityLevel", default = 1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "DebugFRMQualityLevelOverride", default = 0, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "DebugTextureManagerSkipMips", default = -1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "DebugSSAOForce", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "SSAOMipLevels", default = 0, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "DebugSkyGray", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "CommitToGraphicsQualityFix", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "FixGraphicsQuality", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "GraphicsSettingsOnlyShowValidModes", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "PartTexturePackTable2022", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "PartTexturePackTablePre2022", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "CloudsReflectOnWater", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "DebugForceFutureIsBrightPhase2", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "DebugForceFutureIsBrightPhase3", default = false, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "RenderLocalLightFadeInMs_enabled", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "RenderLocalLightUpdatesMax", default = 1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "RenderLocalLightUpdatesMin", default = 1, valueType = "number", category = "Graphics Quality & Lighting" };
	{ name = "NullCheckCloudsRendering", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "GpuGeometryManager7", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "FastGPULightCulling3", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "FRMDisableCloudsAtLowQL", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "RenderAllocateShadowMapResourcesOnDemand2", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };
	{ name = "GpuVoxelCompression", default = true, valueType = "boolean", category = "Graphics Quality & Lighting" };

	{ name = "CSGLevelOfDetailSwitchingDistance", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "CSGLevelOfDetailSwitchingDistanceL12", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "CSGLevelOfDetailSwitchingDistanceL23", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "CSGLevelOfDetailSwitchingDistanceL34", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "CSGv2LodsToGenerate", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "CSGv2LodMinTriangleCount", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "CSGVoxelizerFadeRadius", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "TerrainArraySliceSize", default = 0, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "TextureCompositorActiveJobs", default = 1, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "ViewportFrameMaxSize", default = 9999999, valueType = "number", category = "Textures, Geometry & LOD" };
	{ name = "EnableMultiVETextureManagerSharing", default = true, valueType = "boolean", category = "Textures, Geometry & LOD" };

	{ name = "FixParticleEmissionBias2", default = true, valueType = "boolean", category = "Particles, Grass, Wind & Animation" };
	{ name = "FixParticleAttachmentCulling", default = true, valueType = "boolean", category = "Particles, Grass, Wind & Animation" };
	{ name = "GlobalWindActivated", default = false, valueType = "boolean", category = "Particles, Grass, Wind & Animation" };
	{ name = "GlobalWindRendering", default = false, valueType = "boolean", category = "Particles, Grass, Wind & Animation" };
	{ name = "AnimationLodFacsDistanceMin", default = 0, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "AnimationLodFacsDistanceMax", default = 0, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "AnimationLodFacsVisibilityDenominator", default = 0, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "FRMMaxGrassDistance", default = 0, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "FRMMinGrassDistance", default = 0, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "RenderGrassDetailStrands", default = 0, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "GrassMovementReducedMotionFactor", default = 100, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "RenderGrassHeightScaler", default = 0, valueType = "number", category = "Particles, Grass, Wind & Animation" };
	{ name = "RenderParticlesCapNonVisibleEmission", default = true, valueType = "boolean", category = "Particles, Grass, Wind & Animation" };
	{ name = "RenderParticlesNonVisibleSimBudget1", default = true, valueType = "boolean", category = "Particles, Grass, Wind & Animation" };
	{ name = "RenderParticlesOptimizeVisibleSimLocality", default = true, valueType = "boolean", category = "Particles, Grass, Wind & Animation" };

	{ name = "RuntimeConcurrency", default = 15, valueType = "number", category = "CPU, Threads & Memory" };
	{ name = "SimWorldTaskQueueParallelTasks", default = 16, valueType = "number", category = "CPU, Threads & Memory" };
	{ name = "LuaGcParallelMinMultiTasks", default = 16, valueType = "number", category = "CPU, Threads & Memory" };
	{ name = "TaskSchedulerAutoThreadLimit", default = 15, valueType = "number", category = "CPU, Threads & Memory" };
	{ name = "TaskSchedulerAsyncTasksMinimumThreadCount", default = 15, valueType = "number", category = "CPU, Threads & Memory" };
	{ name = "SmoothClusterTaskQueueMaxParallelTasks", default = 16, valueType = "number", category = "CPU, Threads & Memory" };
	{ name = "DebugRestrictGCDistance", default = 50, valueType = "number", category = "CPU, Threads & Memory" };
	{ name = "MSRefactor5", default = false, valueType = "boolean", category = "CPU, Threads & Memory" };
	{ name = "PerformanceControlEnablePortTextureManagerTrimMemory", default = true, valueType = "boolean", category = "CPU, Threads & Memory" };
	{ name = "AvatarUseRuntimeThreads", default = true, valueType = "boolean", category = "CPU, Threads & Memory" };

	{ name = "PhysicsReceiveNumParallelTasks", default = 16, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "ReplicationDataCacheNumParallelTasks", default = 16, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "NetworkClusterPacketCacheNumParallelTasks", default = 16, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "InterpolationNumParallelTasks", default = 16, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "MegaReplicatorNumParallelTasks", default = 16, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "OptimizeNetworkTransport", default = true, valueType = "boolean", category = "Network, Replication & Physics" };
	{ name = "OptimizeNetworkRouting", default = true, valueType = "boolean", category = "Network, Replication & Physics" };
	{ name = "RakNetResendBufferArrayLength", default = 128, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "WaitOnRecvFromLoopEndedMS", default = 100, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "OptimizeNetwork", default = true, valueType = "boolean", category = "Network, Replication & Physics" };
	{ name = "OptimizeServerTickRate", default = true, valueType = "boolean", category = "Network, Replication & Physics" };
	{ name = "OptimizePingThreshold", default = true, valueType = "boolean", category = "Network, Replication & Physics" };
	{ name = "QueueDataPingFromSendData", default = true, valueType = "boolean", category = "Network, Replication & Physics" };
	{ name = "DontCreatePingJob", default = false, valueType = "boolean", category = "Network, Replication & Physics" };
	{ name = "ServerTickRate", default = 60, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "ServerPhysicsUpdateRate", default = 60, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "PlayerNetworkUpdateRate", default = 60, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "PlayerNetworkUpdateQueueSize", default = 20, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "NetworkLatencyTolerance", default = 0, valueType = "number", category = "Network, Replication & Physics" };
	{ name = "NetworkPrediction", default = true, valueType = "boolean", category = "Network, Replication & Physics" };

	{ name = "TeleportReconnect", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "TeleportReconnect3", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "AddJoinAttemptId", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "EnableQuickGameLaunch", default = false, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "PreloadAllFonts", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "BatchAssetApi", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "BatchAssetApiNoFallbackOnFail", default = false, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "HttpBatchApi_maxWaitMs", default = 50, valueType = "number", category = "Loading, Assets & Teleport" };
	{ name = "HttpBatchApi_bgDelayMs", default = 10, valueType = "number", category = "Loading, Assets & Teleport" };
	{ name = "EnableTexturePreloading", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "EnableSoundPreloading", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };
	{ name = "EnableMeshPreloading2", default = true, valueType = "boolean", category = "Loading, Assets & Teleport" };

	{ name = "ChatTranslationSettingEnabled3", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "UserShowGuiHideToggles", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "GuiHidingApiSupport2", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "CameraMaxZoomDistance", default = 400, valueType = "number", category = "Interface, Camera & Accessibility" };
	{ name = "DebugForceChatDisabled", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "DebugDontRenderScreenGui", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableCommandAutocomplete", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "CoreGuiTypeSelfViewPresent", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "InGameMenuV1FullScreenTitleBar", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableInGameMenuV3", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableInGameMenuControls", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableMenuModernizationABTest", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableMenuModernizationABTest2", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableMenuControlsABTest", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableInGameMenuChromeABTest2", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableInGameMenuChromeABTest3", default = false, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableReportAbuseMenuRoact2", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableReportAbuseMenuLayerOnV3", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableBubbleChatConfigurationV2", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableChromePinnedChat", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableAccessibilitySettingsAPIV2", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableAccessibilitySettingsInExperienceMenu2", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableAccessibilitySettingsEffectsInExperienceChat", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };
	{ name = "EnableAccessibilitySettingsEffectsInCoreScripts2", default = true, valueType = "boolean", category = "Interface, Camera & Accessibility" };

	{ name = "EnableAudioOutputDevice", default = true, valueType = "boolean", category = "Audio" };
	{ name = "FmodUseRuntimeThreading5", default = true, valueType = "boolean", category = "Audio" };

	{ name = "DebugDisableTelemetryEphemeralCounter", default = true, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "DebugDisableTelemetryEphemeralStat", default = true, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "DebugDisableTelemetryEventIngest", default = true, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "DebugDisableTelemetryPoint", default = true, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "DebugDisableTelemetryV2Counter", default = true, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "DebugDisableTelemetryV2Event", default = true, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "DebugDisableTelemetryV2Stat", default = true, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "RenderPerformanceTelemetry", default = false, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "EnableHardwareTelemetry", default = false, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "AudioDeviceTelemetry", default = false, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "EnableSoundTelemetry", default = false, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "EnableFmodErrorsTelemetry", default = false, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "SimReportCPUInfo", default = false, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "EnableGCapsHardwareTelemetry", default = false, valueType = "boolean", category = "Telemetry & Privacy" };
	{ name = "HardwareTelemetryHundredthsPercent", default = 100, valueType = "number", category = "Telemetry & Privacy" };
	{ name = "LightstepHTTPTransportHundredthsPercent2", default = 100, valueType = "number", category = "Telemetry & Privacy" };
	{ name = "ClientLightingEnvmapPlacementTelemetryHundredthsPercent", default = 100, valueType = "number", category = "Telemetry & Privacy" };

	{ name = "AdServiceEnabled", default = false, valueType = "boolean", category = "Client Features & Compatibility" };
}

NAFFlags.info = NAFFlags.info or {
	PhysicsReceiveNumParallelTasks = "Spreads incoming physics work across more CPU threads. Raising it a bit on multi-core PCs can smooth physics in busy servers. If things feel worse, put it back to 16 or turn this flag off.";
	RuntimeConcurrency = "Overall limit for how many worker threads the engine uses at once. Small bumps are fine; extreme values can hurt performance. If in doubt, put it back to 15.";
	SimWorldTaskQueueParallelTasks = "Controls how many threads are used to simulate the world (physics, streaming, etc.). Helpful on strong CPUs, noisy on weak ones. Reset to 16 if it misbehaves.";
	ReplicationDataCacheNumParallelTasks = "Parallelism for handling replicated data from the server. Can help in stacked lobbies; if you see lag spikes, reset to 16.";
	NetworkClusterPacketCacheNumParallelTasks = "How many threads help manage cached network packets. Mostly only noticeable in huge games. Reset to 16 if it feels off.";
	FixParticleEmissionBias2 = "Makes particles emit in a more even and predictable way. You almost always want this on. Turn it off only if you are testing old behavior.";
	InterpolationNumParallelTasks = "Extra threads used for smoothing remote player and object motion. Higher can help on strong CPUs, but don’t go crazy. Reset to 16 if motion gets choppy.";
	MegaReplicatorNumParallelTasks = "Extra threads for really heavy replication loads. Only useful in very busy places. If CPU time explodes, go back to 16.";
	LuaGcParallelMinMultiTasks = "How many threads the Luau garbage collector is willing to use in parallel. It can reduce stutters on fast CPUs; if your CPU is weaker and feels hot, reset to 16.";
	FixParticleAttachmentCulling = "Stops some particle systems disappearing too early when attached to parts. Usually best left on.";

	TaskSchedulerAutoThreadLimit = "Upper bound for how many worker threads the scheduler can spin up. Tiny changes are okay; big jumps can hurt. If you start seeing random jank, go back to 15.";
	TaskSchedulerAsyncTasksMinimumThreadCount = "Minimum number of async worker threads that stay alive. Higher means more idle threads. If you see constant CPU usage even when idle, return to 15.";
	SmoothClusterTaskQueueMaxParallelTasks = "How many tasks can run in parallel in a special networking queue. Mostly experimental; if you touch it and things break, put it back to 16.";

	TeleportReconnect = "Lets the client automatically try to reconnect after a teleport fails. If teleports loop in a weird way, turn this off.";
	TeleportReconnect3 = "Newer version of the teleport reconnect logic. If you see strange reconnect loops, try disabling this one first.";
	AddJoinAttemptId = "Adds IDs to join attempts so errors and reconnects are easier to track. Normally harmless to keep on.";
	ChatTranslationSettingEnabled3 = "Toggles the current chat auto-translation system. If your chat is being translated in ways you don’t like, turn this off.";
	EnableQuickGameLaunch = "Loads into games faster by front-loading some work. Good on strong PCs, might feel heavy on weaker ones. Turn it off if starting a game freezes your PC for a moment.";

	GameBasicSettingsFramerateCap5 = "Unlocks more FPS cap options inside Roblox's own settings menu. Useful if you want the menu to expose higher caps instead of only the usual small set.";
	UserShowGuiHideToggles = "Shows Roblox's built-in GUI hiding toggles in settings. Helpful for screenshots, clean recordings, or quick UI-off testing.";
	GuiHidingApiSupport2 = "Enables the API support behind the GUI hide toggles. Usually paired with UserShowGuiHideToggles so the controls actually work.";
	CameraMaxZoomDistance = "Raises the maximum distance your camera is allowed to zoom out to. Useful in games that do not hard-lock zoom themselves. Lower it again if the camera feels too far away.";
	DebugForceChatDisabled = "Forces chat off on the client. Useful for distraction-free testing or recording. Leave it false if you want normal chat behavior.";
	LCCageDeformLimit = "Limit for how much cage-based mesh deforms. -1 basically means no artificial limit. If an avatar looks broken, try using a small positive number or just disable the flag.";
	FullscreenTitleBarTriggerDelayMillis = "How long you have to hover at the top in fullscreen before the title bar appears, in milliseconds. Set it very high to almost never see the bar. Reset to 2 if you want the default.";
	RobloxGuiBlurIntensity = "How strong the blur behind core UI like the pause menu is. 0 disables the blur, higher makes it blurrier. If you regret changes, just put it back to 0.";
	DebugDisplayFPS = "Shows a simple FPS counter. Handy for testing, annoying if you hate clutter. Turn it off to hide it.";
	RenderShadowmapBias = "Fine-tunes how shadows sit on surfaces. -1 lets Roblox pick automatically. If shadows look like they float or crawl, go back to -1.";
	MaxFrameBufferSize = "How many frames can be buffered. Lower values reduce input lag, higher ones can feel smoother. 4 is a reasonable default to go back to.";
	DebugPerfMode = "Enables a bundle of performance-focused debug paths. If things act unstable, turn this off.";
	AdServiceEnabled = "Turns the built-in ad system on or off. Keeping it false avoids any extra ad-related overhead.";
	HandleAltEnterFullscreenManually = "Makes Roblox handle Alt+Enter itself instead of leaving it to the OS. If Alt+Enter acts weird, try toggling this.";

	DebugGraphicsPreferD3D11 = "Tells Roblox to prefer Direct3D 11. Use it if Vulkan feels unstable on your machine. Turn it back off if D3D11 gives you worse results.";
	DebugGraphicsPreferD3D11FL10 = "Prefers an older D3D11 path that can behave better on very old GPUs. If you don’t have that kind of hardware, you probably don’t need this.";
	DebugGraphicsPreferVulkan = "Tells Roblox to prefer Vulkan. Good on modern GPUs, sometimes buggy on older drivers. Turn it off if you crash or see visual glitches.";
	DebugGraphicsPreferOpenGL = "Tells Roblox to prefer OpenGL. Mainly useful under Wine/Linux or niche cases. If you’re on normal Windows and see issues, disable it.";
	DebugGraphicsDisableDirect3D11 = "Blocks D3D11 so Roblox has to use Vulkan or OpenGL. If that causes crashes, set it back to false.";

	TaskSchedulerTargetFps = "A target FPS hint for the scheduler. People often set it high (like 240 or 300) to avoid caps. If you end up with strange FPS behavior, reset this to its default or a sane number like 60–120.";
	TaskSchedulerLimitTargetFpsTo2402 = "Hard clamps that target FPS hint to 240. If your setup hates ultra-high FPS, turning this on can feel smoother. Turn it off again if you want to experiment with higher caps.";

	DebugForceMSAASamples = "Forces a specific MSAA level. 0 means no override. Try 2 or 4 if you want cleaner edges and have spare GPU power. Go back to 0 if your FPS tanks.";

	TextureQualityOverrideEnabled = "Lets you manually override texture quality. If you want Roblox to manage textures itself, leave this disabled.";
	TextureQualityOverride = "The actual texture quality level to use when override is enabled. 0 is low, higher is sharper but heavier. If textures look awful or too heavy, set it back to 0 or turn the override off.";
	TextureCompositorLowResFactor = "Scale factor for combined avatar/character textures. Values above 1 lower the resolution to save VRAM, 1 is normal. If characters look muddy, put it back to 1.";
	PerformanceControlTextureQualityBestUtility = "Internal weight used for deciding automatic texture quality. Leaving it at -1 lets Roblox handle it. If you change this and things look weird, set it back to -1.";
	EnableRequestAsyncCompression = "Compresses some assets in the background while loading. Can help disk speed at the cost of a bit more CPU work. If load feels spiky, turn it off again.";
	DisablePostFx = "Kills most post-processing (bloom, AO, motion blur, etc.). Good for raw FPS, bad for visuals. Turn it off again if the game starts to look too flat.";
	DebugRenderForceTechnologyVoxel = "Forces the older voxel lighting model. Useful if the newer lighting is buggy or slow on your hardware. Disable it to go back to normal lighting.";

	CSGLevelOfDetailSwitchingDistance = "Base distance at which Roblox starts switching CSG meshes to lower detail. If you see ugly popping, experiment; if it gets worse, set it back to 0.";
	CSGLevelOfDetailSwitchingDistanceL12 = "Distance where level 1 CSG detail drops to level 2. Same idea as above. Reset to 0 if your tweaks are bad.";
	CSGLevelOfDetailSwitchingDistanceL23 = "Distance where level 2 drops to level 3. Again, mostly about when stuff starts looking low-poly. 0 is the safe fallback.";
	CSGLevelOfDetailSwitchingDistanceL34 = "Distance where level 3 drops to level 4. Use only if you really know what you’re tuning. Reset to 0 if unsure.";
	CSGv2LodsToGenerate = "How many levels of detail Roblox even generates for CSG v2 meshes. 0 is conservative and safe. If you change it and see odd meshes, put it back to 0.";
	CSGv2LodMinTriangleCount = "Minimum complexity at which CSG v2 meshes get LODs at all. 0 means everything can get LODs. If low-detail parts look broken, reset to 0.";

	NewLightAttenuation = "Switches to a newer way of fading light over distance. Can make lighting feel different. If a game’s lighting looks wrong, turn this back off.";
	RenderShadowIntensity = "Global multiplier for how strong shadows are. 0 removes them, higher makes them darker. If the world is too dark, bring this down or reset it.";
	CSGVoxelizerFadeRadius = "Controls how smoothly CSG lighting fades in and out around edges. Mostly niche; reset to 0 if you don’t like the result.";

	TerrainArraySliceSize = "Internal chunk size for terrain data. Changing this is risky; if you do and terrain goes crazy, set it back to 0.";

	RomarkStartWithGraphicQualityLevel = "Starting graphics quality when Roblox launches. Set it to a level you like if Roblox always starts too low or too high. Put it back to 1 to be safe.";
	DebugFRMQualityLevelOverride = "Locks overall render quality to a fixed level. Handy for testing or forcing a quality that Roblox won’t pick. Set it back to 0 if the quality slider feels broken.";
	DebugRestrictGCDistance = "Limits how far out geometry is considered for culling. Making it too small can cause stuff to pop in; the default 50 is a safe fallback.";

	MSRefactor5 = "Standalone refactor path for some rendering or core logic. Only flip this if you know it helps your case. Turn it back off if the client acts weird.";
	DebugTextureManagerSkipMips = "Skips top texture mip levels, effectively lowering texture resolution. Values like 1–2 are a mild downgrade for performance; -1 disables the trick and is the safe default.";

	GlobalWindActivated = "Enables the global wind simulation. If foliage or special effects use wind, this decides whether they move at all. Turn it off if you hate the movement.";
	GlobalWindRendering = "Actually draws the visual wind effects. Good for looks, cost for weak GPUs. Turn it off to squeeze extra frames.";

	DebugDontRenderScreenGui = "Stops ScreenGui elements from rendering. Very useful for FPS measurements, very bad if you want to see UI. Turn it off to get UI back.";
	DebugSSAOForce = "Forces a special SSAO (ambient occlusion) debug mode. Only for visuals debugging; turn it off for normal play.";
	SSAOMipLevels = "How many detail levels SSAO uses. Higher is slightly nicer but more expensive. If you go too high and lag, reset to 0.";

	EnableCommandAutocomplete = "Adds autocomplete to the developer console and similar places. Nice for developers; if it ever bugs out, just disable it.";

	AnimationLodFacsDistanceMin = "Distance where animation starts to fade to lower detail. Increase this to keep nearby animations crisp; drop it if you want lower cost. Reset to 0 to let Roblox decide.";
	AnimationLodFacsDistanceMax = "Distance where animation has fully faded to lower detail. Raising it keeps detailed animation further away, costing more. Reset to 0 if things look off.";
	AnimationLodFacsVisibilityDenominator = "Another knob in how animation detail fades with visibility. Most people should leave it alone and keep it at 0.";

	TextureCompositorActiveJobs = "How many jobs the avatar texture compositor can run at once. Higher can make avatars appear faster on multi-core CPUs. If it causes spikes, go back to 1.";

	ViewportFrameMaxSize = "Maximum resolution for what ViewportFrames are allowed to render. A huge value lets them be very sharp but can cost GPU time. If something is too heavy, drop this or reset it.";

	FRMMaxGrassDistance = "How far away grass is drawn. Smaller distance = less grass far away and better FPS. 0 lets Roblox pick; if you mess it up, just go back to that.";
	FRMMinGrassDistance = "How close grass starts rendering around you. Raising this can remove grass near the player and help performance. 0 is the safe fallback.";
	RenderGrassDetailStrands = "Controls how dense or detailed grass strands are. Higher = thicker, nicer grass. If grass is too heavy, lower this or leave it at 0.";
	GrassMovementReducedMotionFactor = "How much grass movement is toned down. Higher values mean calmer grass. If you like the normal movement, put this back to around 100.";

	DebugSkyGray = "Replaces the skybox with a simple gray sky. Good for testing lighting, boring for actual play. Turn it off when you’re done debugging.";
	CoreGuiTypeSelfViewPresent = "Tells Roblox a self-view (camera preview of your avatar) is present. Mostly internal; if you aren’t debugging that UI, you can ignore this.";
	RenderCheckThreading = "Uses extra threads to sanity-check rendering. Good by default; if you suspect it in crashes or odd behavior, try turning it off and see if it helps.";

	OptimizeNetworkTransport = "Enables a more efficient networking transport path. Generally you want this on; if a game behaves worse, try toggling it as a test.";
	OptimizeNetworkRouting = "Optimizes how packets are routed to peers. Keep this on unless you’re isolating a network bug.";
	RakNetResendBufferArrayLength = "How big the buffer of packets waiting to be resent is. Slightly larger buffers can help bad networks but cost some memory. 128 is a good default if you want to undo changes.";
	WaitOnRecvFromLoopEndedMS = "Small delay after the receive loop stops before network teardown. Usually safe at 100ms; if you change it and see odd disconnect timing, set it back.";

	DebugDisableTelemetryEphemeralCounter = "Stops sending short-lived counter telemetry. Turning several of these on reduces how much data your client sends out. Reset to false if you want default behavior.";
	DebugDisableTelemetryEphemeralStat = "Stops sending short-lived stat telemetry. Same idea as above.";
	DebugDisableTelemetryEventIngest = "Reduces some event telemetry ingestion. Better for privacy, worse if Roblox wants diagnostics from you.";
	DebugDisableTelemetryPoint = "Disables generic telemetry points. Flip it on if you want a quieter network footprint; off if you want stock behavior.";
	DebugDisableTelemetryV2Counter = "Disables a newer set of counter telemetry. Same privacy vs diagnostics trade-off.";
	DebugDisableTelemetryV2Event = "Disables V2 event telemetry. Again, less reporting, less insight for Roblox.";
	DebugDisableTelemetryV2Stat = "Disables V2 stat telemetry. If you turn a lot of these off and something breaks, just return them to false.";

	DisableDPIScale = "Ignores Windows DPI scaling for the Roblox window. Great if Roblox looks blurry or over-sized on a high DPI monitor. If UI becomes too tiny, turn this off.";

	OptimizeNetwork = "Packs various network optimizations together. Usually best left on; if you’re debugging something very specific, you can try toggling it.";
	OptimizeServerTickRate = "Hints around how often the server should tick. On public games this is mostly controlled server-side. If you change it and nothing happens, that’s expected.";
	OptimizePingThreshold = "Tweaks thresholds used when smoothing ping. Normally helpful; if your ping graph behaves strangely, you can experiment or just disable it.";
	QueueDataPingFromSendData = "Measures ping based on outgoing traffic rather than a dedicated ping job. Slightly less overhead, slightly different measurements. Turn it off if you need more classic ping behavior.";
	DontCreatePingJob = "Completely skips creating a dedicated ping job. Less background work, but less detailed ping info. Turn it off again if you like proper ping data.";

	RenderPerformanceTelemetry = "Controls whether render/performance metrics are sent back to Roblox. Turning it off reduces telemetry traffic. You can always re-enable it later.";

	CommitToGraphicsQualityFix = "Applies a fix so your graphics quality better matches your hardware. Better to keep on unless you’re testing a bug.";
	FixGraphicsQuality = "Attempts to repair broken saved graphics quality values. Useful if your slider is stuck. If it causes weird behavior, you can turn it back off.";
	GraphicsSettingsOnlyShowValidModes = "Hides graphics options your hardware can’t actually use. Keeping this on makes the settings menu less confusing.";

	PreloadAllFonts = "Loads all fonts upfront instead of waiting until first use. That can add a little delay on startup, but helps avoid mid-game stutters when text appears. Turn it off again if the initial load feels too slow.";

	PartTexturePackTable2022 = "Uses the newer texture packing scheme for parts. Usually better on modern hardware. If some places render weirdly, you can turn this off and use the older table.";
	PartTexturePackTablePre2022 = "Uses the old part texture packing scheme. Only useful if the new one is broken for a specific game. Turn this off once you no longer need the workaround.";

	CloudsReflectOnWater = "Lets clouds show up in water reflections. Looks nice, costs GPU. If water reflections stutter, disable it.";
	DebugForceFutureIsBrightPhase2 = "Forces the older ShadowMap-style Future Is Bright lighting path. Useful as a middle ground if full Future lighting is too heavy or looks wrong in a game.";
	DebugForceFutureIsBrightPhase3 = "Forces the latest version of the Future is Bright lighting pipeline. Looks best on strong GPUs; if you’re struggling for FPS or see bugs, turn it off.";

	InGameMenuV1FullScreenTitleBar = "Brings back the older fullscreen title bar behavior. Nice if you prefer the classic UI. Turn it off if it conflicts with newer menu layouts.";

	EnableHardwareTelemetry = "Allows Roblox to send detailed info about your hardware. Turn it off if you’d rather keep that local.";
	AudioDeviceTelemetry = "Reports how your audio devices are set up. Turning it off is fine if you don’t want that reported.";
	EnableSoundTelemetry = "Reports audio performance and issues. You can disable it if you prefer fewer analytics calls.";
	EnableFmodErrorsTelemetry = "Sends FMOD audio backend errors to Roblox. Turning it off keeps those errors local only.";
	SimReportCPUInfo = "Reports CPU information as part of simulation data. Turn it off for less detailed reporting.";
	EnableGCapsHardwareTelemetry = "Reports GPU capability info. Turn it off if you’re trying to minimize telemetry.";

	BatchAssetApi = "Allows assets to be requested in batches instead of one-by-one. This is normally good for performance and loading. Only turn it off for debugging.";
	BatchAssetApiNoFallbackOnFail = "If a batch asset request fails, this prevents Roblox from falling back to single requests. Only use this for testing failures; turn it off for normal play.";

	GameBasicSettingsFramerateCap = "This is what the in-game Settings framerate slider really writes to. Set it to a number like 60, 120, or 240 to lock your FPS. Set to 0 to let Roblox handle it.";
	RenderGrassHeightScaler = "Changes how tall grass appears. Lower numbers give shorter grass, which can look cleaner in some games. 0 returns to the default behavior.";
	HttpBatchApi_maxWaitMs = "How long the client waits to gather requests before sending a batch. Higher means fewer requests but slightly more latency. 50ms is the default to go back to.";
	HttpBatchApi_bgDelayMs = "Extra delay before sending background batches. Raising it can make large background loads less spiky. 10ms is the safe original value.";

	ServerTickRate = "Target server tick rate in Hz. On normal Roblox servers this is mostly informational; you won’t override the real server. Only relevant if you run or simulate a server yourself.";
	ServerPhysicsUpdateRate = "How often server physics should update. Again, mostly under server control, not the client’s. Leave it at 60 for safety.";
	PlayerNetworkUpdateRate = "How often players get their movement updates. 60 is a good balance. Lower can feel laggy, higher costs more bandwidth.";
	PlayerNetworkUpdateQueueSize = "How many player updates can sit in a queue. Larger values can smooth short spikes at the cost of a bit more latency. 20 is a sane value to restore.";
	NetworkLatencyTolerance = "How tolerant smoothing is of ping spikes. Higher tolerance hides small jitters but can make big jumps feel delayed. 0 is a clean baseline.";

	NetworkPrediction = "Controls whether the client uses prediction to guess short-term movement. If everything feels snappy, keep it on. If a game behaves strangely with prediction, try toggling this off as a test.";

	RenderLocalLightFadeInMs_enabled = "Controls whether local lights gently fade in instead of appearing instantly. If you hate popping when lights switch on, keep this true.";
	RenderLocalLightUpdatesMax = "Upper limit for how many local light updates Roblox performs in one pass. Lower values can reduce spikes in games with a lot of dynamic lights.";
	RenderLocalLightUpdatesMin = "Lower bound for local light updates. Keeping it low can reduce some lighting overhead, while raising it can make fast-changing lights react more quickly.";
	GraphicsGLEnableHQShadersExclusion = "Prevents certain weaker GL setups from using heavy shaders. If you force it off, old/weak GPUs may suffer.";
	GraphicsGLEnableSuperHQShadersExclusion = "Same idea but for the very heaviest shader paths. Leave it on unless you know you want those shaders at any cost.";
	NullCheckCloudsRendering = "Adds safety checks around cloud rendering. Usually helps stability; only disable if chasing down a very specific bug.";
	GpuGeometryManager7 = "Enables a newer system for managing geometry on the GPU. Fine to leave on unless a specific game behaves badly with it.";

	EnableInGameMenuV3 = "Turns on the modern V3 in-game menu. Disable it if it conflicts with your overlays or you just like the old style better.";
	EnableInGameMenuControls = "Enables the newer control logic inside the menu (like better gamepad support). Turn it off if your custom UI navigation gets confused.";
	EnableMenuModernizationABTest = "Lets you force a menu modernization experiment. Not needed in normal use; if menus feel weird after enabling, just turn it back off.";
	EnableMenuModernizationABTest2 = "Second variant of the modernization test. Same idea: only mess with it if you’re curious, then revert.";
	EnableMenuControlsABTest = "Tests alternative menu control schemes. If it feels off, just disable it again.";
	EnableInGameMenuChromeABTest2 = "Lets you see a different style for the menu frame and borders. Fun to try, easy to undo.";
	EnableInGameMenuChromeABTest3 = "Another style variation for the menu shell. If you don’t like the look, turn it off.";

	EnableReportAbuseMenuRoact2 = "Enables the newer report-abuse interface. Keep it on unless it obviously breaks UI.";
	EnableReportAbuseMenuLayerOnV3 = "Controls how the report-abuse screen layers into the V3 menu. Turn it off if it overlaps in ugly ways with your overlays.";
	EnableBubbleChatConfigurationV2 = "Enables a newer, more configurable bubble chat system. If a game’s chat looks broken, try toggling this.";
	EnableChromePinnedChat = "Allows the chat to be pinned like a bar or dock in the UI. If your layout gets cluttered, disable it.";

	EnableAccessibilitySettingsAPIV2 = "Turns on the latest accessibility settings API. Good to keep on so Roblox can respect user preferences.";
	EnableAccessibilitySettingsInExperienceMenu2 = "Shows accessibility settings inside the in-game menu. If you want a minimal-looking menu, you can turn it off.";
	EnableAccessibilitySettingsEffectsInExperienceChat = "Applies accessibility choices (reduced motion, higher contrast, etc.) to chat. Turn it on for comfort, off if it clashes with your theme.";
	EnableAccessibilitySettingsEffectsInCoreScripts2 = "Same idea but for built-in Roblox UI like core menus. Good to keep enabled for accessibility.";

	EnableAudioOutputDevice = "Lets you choose which audio device Roblox uses. Very helpful if you have multiple outputs. Turn it off only if it causes odd audio behavior.";

	HardwareTelemetryHundredthsPercent = "How often hardware telemetry is sampled, expressed in hundredths of a percent. 100 means about 1% of sessions. Setting it to 0 effectively stops this on your client.";
	LightstepHTTPTransportHundredthsPercent2 = "Sampling rate for a specific telemetry pipeline. 0 turns it off for you; 100 is a typical default.";
	ClientLightingEnvmapPlacementTelemetryHundredthsPercent = "Sampling rate for a lighting-related telemetry channel. Set to 0 to stop sending this; set back to 100 if you want default reporting.";
	EnableFPSAndFrameTime = "Enables Roblox's FPS and frame-time instrumentation path. Useful for performance diagnostics; it does not raise FPS by itself.";
	PerformanceControlRespectUserFpsOverridden = "Makes performance control respect a user-overridden FPS target when the current client supports this path. Experimental and may be ignored by some builds.";
	FastGPULightCulling3 = "Uses the newer GPU light-culling path. It can help scenes with many local lights, but driver-specific visual issues are possible.";
	FRMDisableCloudsAtLowQL = "Allows the frame-rate manager to disable clouds at low quality levels, reducing cloud rendering cost on weaker hardware.";
	RenderAllocateShadowMapResourcesOnDemand2 = "Allocates shadow-map resources on demand instead of eagerly. This can reduce unused graphics memory, but it is an internal rollout flag.";
	GpuVoxelCompression = "Enables GPU-side voxel compression where supported. It may reduce graphics memory pressure; disable it if voxel lighting becomes unstable.";
	EnableMultiVETextureManagerSharing = "Shares texture-manager state across multiple view engines where supported. This is intended to reduce duplicated texture work and memory use.";
	RenderParticlesCapNonVisibleEmission = "Caps emission for particles that are not visible, reducing wasted particle work in effects-heavy places.";
	RenderParticlesNonVisibleSimBudget1 = "Applies a simulation budget to non-visible particles. It can improve performance when many effects are off-screen.";
	RenderParticlesOptimizeVisibleSimLocality = "Uses a locality optimization for visible particle simulation. Experimental; revert it if particle effects render incorrectly.";
	PerformanceControlEnablePortTextureManagerTrimMemory = "Lets performance control request texture-memory trimming. Useful under memory pressure, but it can increase texture reloading or pop-in.";
	AvatarUseRuntimeThreads = "Moves supported avatar work onto Roblox runtime threads. This may reduce main-thread spikes in avatar-heavy places, but it is experimental.";
	EnableTexturePreloading = "Enables texture preloading where the current client path supports it. It can reduce later texture pop-in at the cost of startup time and memory.";
	EnableSoundPreloading = "Enables sound preloading where supported. It can reduce delayed first playback, while using more startup bandwidth and memory.";
	EnableMeshPreloading2 = "Enables the newer mesh-preloading path. It can reduce mesh pop-in, but may increase initial loading work.";
	FmodUseRuntimeThreading5 = "Uses Roblox runtime threading for supported FMOD audio work. Experimental; disable it if audio devices or playback become unstable.";
}

for _, entry in NAFFlags.whitelist do
	entry.valueType = entry.valueType or type(entry.default)
end

NAFFlags.filePath = NAfiles.NAFFLAGSPATH or (NAfiles.NAFILEPATH.."/NAFFlags.json")
NAFFlags.metaPath = NAfiles.NAFFLAGSCONFIGPATH or (NAfiles.NAFILEPATH.."/NAFFlagsConfig.json")
NAFFlags.config = NAFFlags.config or { useFFlags = false, autoApply = false, autoApplyLoop = true, autoApplyInterval = 3, flags = {}, custom = {}, enabledFlags = {}, clientKeyAliases = {} }
NAFFlags.config.custom = NAFFlags.config.custom or {}
NAFFlags.config.clientKeyAliases = NAFFlags.config.clientKeyAliases or {}
NAFFlags.values = NAFFlags.values or {}
NAFFlags.clientPrefixes = NAFFlags.clientPrefixes or { "DFFlag", "DFInt", "DFString", "FFlag", "FInt", "FString", "SFFlag", "SFInt", "SFString" }
NAFFlags.renderingPreferFlags = NAFFlags.renderingPreferFlags or {
	"DebugGraphicsPreferD3D11",
	"DebugGraphicsPreferD3D11FL10",
	"DebugGraphicsPreferVulkan",
	"DebugGraphicsPreferOpenGL",
}
NAFFlags.renderingDisableFlag = "DebugGraphicsDisableDirect3D11"

NAFFlags.normalizeValue = function(entry, rawValue, opts)
	opts = opts or {}
	if entry.valueType == "number" then
		const numValue = tonumber(rawValue)
		if numValue == nil then
			if not opts.silent then
				DoNotif(Format("%s expects a number", tostring(entry.name)), 3)
			end
			return nil
		end
		return numValue
	elseif entry.valueType == "boolean" then
		return rawValue and true or false
	end
	return rawValue
end

NAFFlags.parseCustomValue = function(rawValue)
	const str = tostring(rawValue or "")
	const trimmed = str:match("^%s*(.-)%s*$") or str
	const lower = trimmed:lower()
	if lower == "true" then
		return true
	elseif lower == "false" then
		return false
	end
	const num = tonumber(trimmed)
	if num ~= nil then
		return num
	end
	return trimmed
end

NAFFlags.isWhitelistedFlag = function(name)
	for _, entry in NAFFlags.whitelist do
		if entry.name == name then
			return true
		end
	end
	return false
end

NAFFlags.getEntry = function(name)
	for _, entry in NAFFlags.whitelist do
		if entry.name == name then
			return entry
		end
	end
	return nil
end

NAFFlags.isFlagEnabled = function(name)
	const t = NAFFlags.config and NAFFlags.config.enabledFlags
	if not t then
		return false
	end
	return t[name] == true
end

NAFFlags.getDefault = function(entry)
	if entry.valueType == "boolean" then
		return false
	end
	return entry.default
end

NAFFlags.hasClientPrefix = function(name)
	name = tostring(name or "")
	for _, prefix in NAFFlags.clientPrefixes or {} do
		if Sub(name, 1, #prefix) == prefix then
			return true, prefix
		end
	end
	return false, nil
end

NAFFlags.stripClientPrefix = function(name)
	name = tostring(name or "")
	for _, prefix in NAFFlags.clientPrefixes or {} do
		if Sub(name, 1, #prefix) == prefix then
			return Sub(name, #prefix + 1)
		end
	end
	return name
end

NAFFlags.getEntryByAnyName = function(name)
	const rawName = tostring(name or "")
	const baseName = NAFFlags.stripClientPrefix(rawName)
	for _, entry in NAFFlags.whitelist do
		if entry.name == rawName or entry.name == baseName then
			return entry, entry.name
		end
	end
	return nil, baseName
end

NAFFlags.inferClientPrefix = function(value)
	if type(value) == "boolean" then
		return "FFlag"
	elseif type(value) == "number" then
		return "FInt"
	end
	return "FString"
end

NAFFlags.clientKeyFor = function(entry, fallbackName)
	const name = tostring(fallbackName or (entry and entry.name) or "")
	if name == "" then
		return name
	end
	const aliases = NAFFlags.config and NAFFlags.config.clientKeyAliases or nil
	const alias = aliases and aliases[name] or nil
	if type(alias) == "string" and alias ~= "" then
		return alias
	end
	if NAFFlags.hasClientPrefix(name) then
		return name
	end
	local value = entry and NAFFlags.values and NAFFlags.values[entry.name] or nil
	if value == nil and entry then
		value = NAFFlags.getDefault(entry)
	end
	if entry then
		return NAFFlags.inferClientPrefix(value)..name
	end
	return name
end

NAFFlags.clientValueText = function(value)
	if type(value) == "boolean" then
		return value and "True" or "False"
	end
	return tostring(value)
end

NAFFlags.escapeJsonString = function(value)
	local ok, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, tostring(value))
	if ok and type(encoded) == "string" then
		return encoded
	end
	return Format("%q", tostring(value))
end

NAFFlags.encodeClientAppSettings = function(data)
	const keys = {}
	for key, value in data or {} do
		if type(key) == "string" and value ~= nil then
			keys[#keys + 1] = key
		end
	end
	table.sort(keys, function(a, b)
		return Lower(a) < Lower(b)
	end)
	const lines = { "{" }
	for i, key in keys do
		const comma = i < #keys and "," or ""
		lines[#lines + 1] = "  "..NAFFlags.escapeJsonString(key)..": "..NAFFlags.escapeJsonString(data[key])..comma
	end
	lines[#lines + 1] = "}"
	return Concat(lines, "\n")
end

NAFFlags.buildClientSettingsTable = function()
	const out = {}
	const seen = {}
	for _, entry in NAFFlags.whitelist do
		const name = entry.name
		if NAFFlags.config.enabledFlags and NAFFlags.config.enabledFlags[name] == true then
			local value = NAFFlags.values[name]
			if value == nil then
				value = NAFFlags.config.flags and NAFFlags.config.flags[name] or nil
			end
			if value == nil then
				value = NAFFlags.getDefault(entry)
			end
			const key = NAFFlags.clientKeyFor(entry, name)
			if key ~= "" then
				out[key] = NAFFlags.clientValueText(value)
				seen[name] = true
				seen[key] = true
			end
		end
	end
	if not NAFFlags.config.applyWhitelistOnly then
		for name, value in NAFFlags.config.custom or {} do
			if value ~= nil and not seen[name] then
				const key = NAFFlags.clientKeyFor(nil, name)
				if key ~= "" then
					out[key] = NAFFlags.clientValueText(value)
				end
			end
		end
	end
	return out
end

NAFFlags.buildClientAppSettingsJson = function()
	return NAFFlags.encodeClientAppSettings(NAFFlags.buildClientSettingsTable())
end

NAFFlags.loadMeta = function()
	if not FileSupport then
		return false
	end
	local okRead, raw = pcall(readfile, NAFFlags.metaPath)
	if not okRead or type(raw) ~= "string" or raw == "" then
		return false
	end
	local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if not okDecode or type(decoded) ~= "table" then
		return false
	end
	if type(decoded.useFFlags) == "boolean" then
		NAFFlags.config.useFFlags = decoded.useFFlags
	end
	if type(decoded.autoApply) == "boolean" then
		NAFFlags.config.autoApply = decoded.autoApply
	end
	if type(decoded.autoApplyLoop) == "boolean" then
		NAFFlags.config.autoApplyLoop = decoded.autoApplyLoop
	end
	if decoded.autoApplyInterval ~= nil then
		const n = tonumber(decoded.autoApplyInterval)
		if n and n > 0 then
			NAFFlags.config.autoApplyInterval = n
		end
	end
	if type(decoded.applyWhitelistOnly) == "boolean" then
		NAFFlags.config.applyWhitelistOnly = decoded.applyWhitelistOnly
	end
	if type(decoded.enabledFlags) == "table" then
		NAFFlags.config.enabledFlags = {}
		for _, entry in NAFFlags.whitelist do
			NAFFlags.config.enabledFlags[entry.name] = decoded.enabledFlags[entry.name] == true
		end
	end
	if type(decoded.clientKeyAliases) == "table" then
		NAFFlags.config.clientKeyAliases = {}
		for name, alias in decoded.clientKeyAliases do
			if type(name) == "string" and type(alias) == "string" and alias ~= "" then
				NAFFlags.config.clientKeyAliases[name] = alias
			end
		end
	end
	return true
end

NAFFlags.saveMeta = function()
	if not FileSupport then
		return
	end
	const meta = {
		useFFlags = NAFFlags.config.useFFlags == true;
		autoApply = NAFFlags.config.autoApply == true;
		autoApplyLoop = NAFFlags.config.autoApplyLoop ~= false;
		autoApplyInterval = NAFFlags.config.autoApplyInterval;
		applyWhitelistOnly = NAFFlags.config.applyWhitelistOnly == true;
		enabledFlags = NAFFlags.config.enabledFlags or {};
		clientKeyAliases = NAFFlags.config.clientKeyAliases or {};
	}
	local okEncode, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, meta)
	if okEncode and encoded then
		pcall(writefile, NAFFlags.metaPath, encoded)
	end
end

NAFFlags.importClientSettingsTable = function(decoded)
	NAFFlags.config.custom = {}
	NAFFlags.config.enabledFlags = NAFFlags.config.enabledFlags or {}
	NAFFlags.config.clientKeyAliases = NAFFlags.config.clientKeyAliases or {}

	local imported = 0
	for savedName, rawValue in decoded or {} do
		if type(savedName) == "string" then
			const entry = NAFFlags.getEntryByAnyName(savedName)
			const parsed = NAFFlags.parseCustomValue(rawValue)
			if entry then
				const normalized = NAFFlags.normalizeValue(entry, parsed, { silent = true })
				if normalized ~= nil then
					NAFFlags.config.flags[entry.name] = normalized
					NAFFlags.config.enabledFlags[entry.name] = true
					if NAFFlags.hasClientPrefix(savedName) then
						NAFFlags.config.clientKeyAliases[entry.name] = savedName
					end
					imported += 1
				end
			elseif savedName ~= "" then
				NAFFlags.config.custom[savedName] = parsed
				imported += 1
			end
		end
	end
	return imported
end

NAFFlags.syncRuntimeValues = function()
	for _, entry in NAFFlags.whitelist do
		const n = entry.name
		NAFFlags.values[n] = NAFFlags.config.flags and NAFFlags.config.flags[n] or NAFFlags.getDefault(entry)
	end
	for n, v in NAFFlags.config.custom or {} do
		NAFFlags.values[n] = v
	end
end

NAFFlags.resetImportState = function()
	NAFFlags.config.flags = NAFFlags.config.flags or {}
	NAFFlags.config.custom = {}
	NAFFlags.config.enabledFlags = {}
	NAFFlags.config.clientKeyAliases = {}
	for _, entry in NAFFlags.whitelist do
		const n = entry.name
		NAFFlags.config.flags[n] = NAFFlags.getDefault(entry)
		NAFFlags.config.enabledFlags[n] = false
	end
end

NAFFlags.importClientAppSettingsJson = function(raw, opts)
	opts = type(opts) == "table" and opts or {}
	raw = tostring(raw or "")
	if raw:match("^%s*$") then
		return false, 0, 0, 0, "Empty JSON"
	end

	local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if not ok or type(decoded) ~= "table" then
		return false, 0, 0, 0, "Invalid JSON"
	end

	if opts.replace ~= false then
		NAFFlags.resetImportState()
	end

	const imported = NAFFlags.importClientSettingsTable(decoded)
	if imported <= 0 then
		return false, 0, 0, 0, "No valid fast flags found"
	end

	local built = 0
	for _, entry in NAFFlags.whitelist do
		if NAFFlags.config.enabledFlags and NAFFlags.config.enabledFlags[entry.name] == true then
			built += 1
		end
	end

	local custom = 0
	for _, v in NAFFlags.config.custom or {} do
		if v ~= nil then
			custom += 1
		end
	end

	if opts.enable ~= false then
		NAFFlags.config.useFFlags = true
	end

	NAFFlags.syncRuntimeValues()
	NAFFlags.normalizeRenderingPrefs()
	NAFFlags.save()

	if type(NAFFlags.refreshCustomListDisplay) == "function" then
		NAFFlags.refreshCustomListDisplay()
	end

	if NAFFlags.config.autoApply == true then
		NAFFlags.autoApplyWithRetry()
	end

	return true, imported, built, custom, nil
end

NAFFlags.importClientAppSettingsFromText = function(raw)
	local ok, imported, built, custom, err = NAFFlags.importClientAppSettingsJson(raw, { replace = true, enable = true })
	if ok then
		DoNotif(Format("Imported %d fast flags (%d built-in, %d custom).", imported, built, custom), 4)
	else
		DoNotif("ClientAppSettings import failed: "..tostring(err), 4)
	end
	return ok, imported, built, custom, err
end

NAFFlags.existsCache = NAFFlags.existsCache or {}

NAFFlags.flagExists = function(name)
	if NAFFlags.existsCache[name] ~= nil then
		return NAFFlags.existsCache[name]
	end

	if type(getfflag) ~= "function" then
		return nil
	end

	local ok, res = pcall(getfflag, name)
	if ok then
		NAFFlags.existsCache[name] = true
		return true
	end

	const msg = tostring(res):lower()
	if msg:find("fflag is not exist") or msg:find("fflag does not exist") then
		NAFFlags.existsCache[name] = false
		return false
	end

	return nil
end

NAFFlags.normalizeRenderingPrefs = function(changedFlag)
	if not NAFFlags.config or not NAFFlags.config.flags then
		return
	end
	const preferFlags = NAFFlags.renderingPreferFlags or {}
	const disableFlag = NAFFlags.renderingDisableFlag
	local active = nil
	if changedFlag and NAFFlags.values[changedFlag] == true then
		active = changedFlag
	end
	if not active then
		for _, name in preferFlags do
			if NAFFlags.values[name] == true then
				active = name
				break
			end
		end
	end
	for _, name in preferFlags do
		const shouldBe = name == active
		NAFFlags.values[name] = shouldBe
		NAFFlags.config.flags[name] = shouldBe
	end
	if disableFlag then
		if active == "DebugGraphicsPreferVulkan" or active == "DebugGraphicsPreferOpenGL" then
			NAFFlags.values[disableFlag] = true
			NAFFlags.config.flags[disableFlag] = true
		elseif active then
			NAFFlags.values[disableFlag] = false
			NAFFlags.config.flags[disableFlag] = false
		end
	end
end

NAFFlags.isRenderingPreferFlag = function(name)
	for _, flagName in NAFFlags.renderingPreferFlags do
		if flagName == name then
			return true
		end
	end
	return false
end

NAFFlags.applyDefaults = function()
	NAFFlags.config.useFFlags = false
	NAFFlags.config.autoApply = false
	NAFFlags.config.autoApplyLoop = true
	NAFFlags.config.autoApplyInterval = 3
	NAFFlags.config.flags = {}
	NAFFlags.config.custom = {}
	NAFFlags.config.enabledFlags = {}
	for _, entry in NAFFlags.whitelist do
		const n = entry.name
		NAFFlags.config.flags[n] = NAFFlags.getDefault(entry)
		NAFFlags.config.enabledFlags[n] = false
	end
end

NAFFlags.save = function()
	if not FileSupport then
		return
	end
	NAFFlags.config.custom = NAFFlags.config.custom or {}
	NAFFlags.config.enabledFlags = NAFFlags.config.enabledFlags or {}
	NAFFlags.config.clientKeyAliases = NAFFlags.config.clientKeyAliases or {}
	NAFFlags.saveMeta()
	const encoded = NAFFlags.buildClientAppSettingsJson()
	if type(encoded) == "string" then
		pcall(writefile, NAFFlags.filePath, encoded)
	end
end

NAFFlags.load = function()
	NAFFlags.applyDefaults()
	if not FileSupport then
		return
	end

	const hasMeta = NAFFlags.loadMeta()
	local needsSave = false
	local okRead, raw = pcall(readfile, NAFFlags.filePath)

	if okRead and type(raw) == "string" and raw ~= "" then
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if okDecode and type(decoded) == "table" then
			const legacyConfig = type(decoded.flags) == "table"
				or type(decoded.custom) == "table"
				or type(decoded.enabledFlags) == "table"
				or type(decoded.useFFlags) == "boolean"
				or type(decoded.autoApply) == "boolean"

			if legacyConfig then
				if type(decoded.useFFlags) == "boolean" then
					NAFFlags.config.useFFlags = decoded.useFFlags
				else
					needsSave = true
				end
				if type(decoded.autoApply) == "boolean" then
					NAFFlags.config.autoApply = decoded.autoApply
				else
					needsSave = true
				end
				if type(decoded.autoApplyLoop) == "boolean" then
					NAFFlags.config.autoApplyLoop = decoded.autoApplyLoop
				else
					needsSave = true
				end
				if decoded.autoApplyInterval ~= nil then
					const n = tonumber(decoded.autoApplyInterval)
					if n and n > 0 then
						NAFFlags.config.autoApplyInterval = n
					else
						needsSave = true
					end
				end
				if type(decoded.applyWhitelistOnly) == "boolean" then
					NAFFlags.config.applyWhitelistOnly = decoded.applyWhitelistOnly
				end
				if type(decoded.flags) == "table" then
					for _, entry in NAFFlags.whitelist do
						const normalized = NAFFlags.normalizeValue(entry, decoded.flags[entry.name], { silent = true })
						if normalized ~= nil then
							NAFFlags.config.flags[entry.name] = normalized
						else
							needsSave = true
						end
					end
				end
				if type(decoded.custom) == "table" then
					NAFFlags.config.custom = {}
					for customName, customValue in decoded.custom do
						if type(customName) == "string" then
							NAFFlags.config.custom[customName] = customValue
						end
					end
				else
					needsSave = true
				end
				if type(decoded.enabledFlags) == "table" then
					NAFFlags.config.enabledFlags = {}
					for _, e in NAFFlags.whitelist do
						const n = e.name
						NAFFlags.config.enabledFlags[n] = decoded.enabledFlags[n] == true
					end
				else
					needsSave = true
				end
				if type(decoded.clientKeyAliases) == "table" then
					NAFFlags.config.clientKeyAliases = decoded.clientKeyAliases
				end
				needsSave = true
			else
				const imported = NAFFlags.importClientSettingsTable(decoded)
				if imported > 0 and not hasMeta then
					NAFFlags.config.useFFlags = true
				end
				if not hasMeta then
					NAFFlags.saveMeta()
				end
			end
		else
			needsSave = true
		end
	else
		needsSave = true
	end

	NAFFlags.config.custom = NAFFlags.config.custom or {}
	NAFFlags.config.enabledFlags = NAFFlags.config.enabledFlags or {}
	NAFFlags.config.clientKeyAliases = NAFFlags.config.clientKeyAliases or {}

	if needsSave then
		NAFFlags.save()
	end
end

NAFFlags.load()
local removedLegacyManagedFlag = false
for _, legacyName in { "DebugPauseVoxelizer", "FFlagDebugPauseVoxelizer", "DebugRenderingSetDeterministic", "FFlagDebugRenderingSetDeterministic" } do
	if NAFFlags.config.flags and NAFFlags.config.flags[legacyName] ~= nil then
		NAFFlags.config.flags[legacyName] = nil
		removedLegacyManagedFlag = true
	end
	if NAFFlags.config.custom and NAFFlags.config.custom[legacyName] ~= nil then
		NAFFlags.config.custom[legacyName] = nil
		removedLegacyManagedFlag = true
	end
	if NAFFlags.config.enabledFlags and NAFFlags.config.enabledFlags[legacyName] ~= nil then
		NAFFlags.config.enabledFlags[legacyName] = nil
		removedLegacyManagedFlag = true
	end
	if NAFFlags.config.clientKeyAliases and NAFFlags.config.clientKeyAliases[legacyName] ~= nil then
		NAFFlags.config.clientKeyAliases[legacyName] = nil
		removedLegacyManagedFlag = true
	end
end
if removedLegacyManagedFlag then
	NAFFlags.save()
end
for _, entry in NAFFlags.whitelist do
	NAFFlags.values[entry.name] = NAFFlags.config.flags[entry.name]
end
for name, value in NAFFlags.config.custom or {} do
	NAFFlags.values[name] = value
end
NAFFlags.normalizeRenderingPrefs()

NAFFlags.hasSupport = function()
	if type(setfflag) == "function" then
		return true
	end
	local ok, define = pcall(function()
		return game and game.DefineFastFlag
	end)
	return ok and type(define) == "function"
end

NAFFlags._availableFlags = NAFFlags._availableFlags or {}

NAFFlags.isFlagAvailable = function(name, opts)
	opts = opts or {}
	const cache = NAFFlags._availableFlags
	if cache[name] ~= nil then
		return cache[name]
	end
	if type(getfflag) ~= "function" then
		cache[name] = true
		return true
	end
	const ok = pcall(function()
		return getfflag(name)
	end)
	cache[name] = ok
	if not ok and opts.notify then
		DoNotif(Format("%s is not available on this client and will be skipped.", tostring(name)), 3)
	end
	return ok
end

NAFFlags.enabled = function()
	return NAFFlags.config.useFFlags == true
end

NAFFlags._lockedDefaults = NAFFlags._lockedDefaults or {}

NAFFlags.apply = function(flagName, flagValue, opts)
	opts = opts or {}
	const requireEnabled = opts.allowDisabled ~= true

	if requireEnabled and not NAFFlags.enabled() then
		if not opts.silent then
			DoNotif("FastFlags are disabled. Enable \"Use FastFlags\" first.", 3)
		end
		return false, "disabled"
	end

	if not NAFFlags.hasSupport() then
		if not opts.silent then
			DoNotif("setfflag / DefineFastFlag is unavailable on this executor.", 3)
		end
		return false, "unsupported"
	end

	if NAFFlags.isFlagAvailable and not NAFFlags.isFlagAvailable(flagName, { notify = not opts.silent }) then
		return false, "unavailable"
	end

	const setter = type(setfflag) == "function" and setfflag or function(name, value)
		return game:DefineFastFlag(name, value)
	end

	local ok, err = pcall(setter, flagName, tostring(flagValue))
	if not ok then
		const msg = tostring(err or "")
		const l = msg:lower()

		if l:find("registration from lua failed") and l:find("different default value") then
			NAFFlags._lockedDefaults[flagName] = true
			const entry = NAFFlags.getEntry and NAFFlags.getEntry(flagName) or nil
			if entry then
				const def = NAFFlags.getDefault(entry)
				NAFFlags.values[flagName] = def
				if NAFFlags.config and NAFFlags.config.flags then
					NAFFlags.config.flags[flagName] = def
					NAFFlags.save()
				end
			end
			if not opts.silent then
				DoNotif(flagName.." cannot be changed on this executor (default value is locked by the client).", 3)
			end
			return false, "default-locked"
		end

		if not opts.silent then
			DoNotif("Failed to set "..tostring(flagName)..".", 4)
		end
		return false, err
	end

	if not opts.silent then
		DoNotif(Format("%s set to %s", tostring(flagName), tostring(flagValue)), 2)
	end
	return true
end

NAFFlags.getTargets = function()
	const targets = {}
	const seen = {}
	for _, entry in NAFFlags.whitelist do
		const name = entry.name
		if NAgui and NAgui.SCREEN_GUI_NO_RENDER_FLAG and name == NAgui.SCREEN_GUI_NO_RENDER_FLAG then
			continue
		end
		if NAFFlags.isFlagEnabled and not NAFFlags.isFlagEnabled(name) then
			continue
		end
		if not NAFFlags.isFlagAvailable or NAFFlags.isFlagAvailable(name) then
			targets[#targets + 1] = { name = name, value = NAFFlags.values[name] }
			seen[name] = true
		end
	end
	if not NAFFlags.config.applyWhitelistOnly then
		for customName, customValue in NAFFlags.config.custom or {} do
			if NAgui and NAgui.SCREEN_GUI_NO_RENDER_FLAG and customName == NAgui.SCREEN_GUI_NO_RENDER_FLAG then
				continue
			end
			if not seen[customName] and customValue ~= nil then
				targets[#targets + 1] = { name = customName, value = customValue }
			end
		end
	end
	return targets
end

NAFFlags.applyAll = function(opts)
	opts = opts or {}
	const shouldNotify = opts.notify ~= false

	NAFFlags.normalizeRenderingPrefs()

	if not NAFFlags.enabled() then
		if shouldNotify then
			DoNotif("FastFlags are disabled. Enable \"Use FastFlags\" first.", 3)
		end
		return 0, false
	end

	if not NAFFlags.hasSupport() then
		if shouldNotify then
			DoNotif("FastFlag functions not available on this executor.", 3)
		end
		return 0, false
	end

	const targets = NAFFlags.getTargets()

	local applied = 0
	for _, target in targets do
		if NAFFlags.apply(target.name, target.value, { silent = true }) then
			applied = applied + 1
		end
	end

	if shouldNotify then
		DoNotif(Format("Applied %d/%d fast flags", applied, #targets), 3)
	end

	return applied, true
end

NAFFlags.getSortedCustomNames = function()
	const names = {}
	for customName, customValue in NAFFlags.config.custom or {} do
		if customValue ~= nil then
			Insert(names, customName)
		end
	end
	table.sort(names, function(a, b)
		return tostring(a):lower() < tostring(b):lower()
	end)
	return names
end

NAFFlags.updateSelectedDisplay = function()
	const selectedInfo = NAStuff and NAStuff.customFlagSelectedInfo
	if not selectedInfo then
		return
	end
	const names = (NAStuff and NAStuff.customFlagNames) or NAFFlags.getSortedCustomNames()
	const count = #names
	local idx = tonumber(NAStuff and NAStuff.customFlagIndex) or 0
	if count == 0 then
		selectedInfo.Text = "Selected Custom Flag: None"
		return
	end
	if idx < 1 or idx > count then
		idx = 1
		if NAStuff then
			NAStuff.customFlagIndex = idx
		end
	end
	const name = names[idx]
	selectedInfo.Text = Format("Selected Custom Flag: %s (%d/%d)", tostring(name), idx, count)
	selectedInfo.TextScaled = true
end

NAFFlags.refreshCustomListDisplay = function()
	const countInfo = NAStuff and NAStuff.customFlagCountInfo
	const names = NAFFlags.getSortedCustomNames()
	const count = #names
	if NAStuff then
		NAStuff.customFlagNames = names
		if count == 0 then
			NAStuff.customFlagIndex = nil
		else
			local idx = tonumber(NAStuff.customFlagIndex) or 1
			if idx > count then
				idx = 1
			end
			if idx < 1 then
				idx = 1
			end
			NAStuff.customFlagIndex = idx
		end
	end
	if countInfo then
		countInfo.Text = Format("Saved Custom Flags (%d)", count)
	end
	const customFlagDropdownLabel = NAStuff and NAStuff.customFlagDropdownLabel
	if customFlagDropdownLabel and NAgui then
		local options = {}
		local selectedName = "None"
		if count > 0 then
			for i = 1, count do
				options[i] = names[i]
			end
			local idx = tonumber(NAStuff and NAStuff.customFlagIndex) or 1
			if idx < 1 then idx = 1 end
			if idx > count then idx = count end
			selectedName = names[idx] or names[1]
		else
			options = { "None" }
		end
		if NAgui.setDropdownOptions then
			NAgui.setDropdownOptions(customFlagDropdownLabel, options)
		end
		if NAgui.setDropdownValue then
			NAgui.setDropdownValue(customFlagDropdownLabel, selectedName, { fire = false })
		end
	end
	NAFFlags.updateSelectedDisplay()
end

NAFFlags.setCustomFlag = function(name, value)
	const trimmedName = (tostring(name or ""):match("^%s*(.-)%s*$")) or ""
	if trimmedName == "" then
		return false, "Missing flag name"
	end
	if value == nil then
		return false, "Missing flag value"
	end
	name = trimmedName
	if NAFFlags.isWhitelistedFlag and NAFFlags.isWhitelistedFlag(name) then
		return false, "Flag is already managed in the default list"
	end
	NAFFlags.config.custom = NAFFlags.config.custom or {}
	NAFFlags.config.custom[name] = value
	NAFFlags.values[name] = value
	NAFFlags.save()
	NAFFlags.refreshCustomListDisplay()
	return true
end

NAFFlags.removeCustomFlag = function(name)
	const trimmedName = (tostring(name or ""):match("^%s*(.-)%s*$")) or ""
	if trimmedName == "" then
		return false, "Missing flag name"
	end
	name = trimmedName
	if NAFFlags.config.custom then
		NAFFlags.config.custom[name] = nil
	end
	NAFFlags.values[name] = nil
	NAFFlags.save()
	NAFFlags.refreshCustomListDisplay()
	return true
end

NAFFlags.setCustomInputFields = function(name)
	NAStuff.customFFlagName = name or ""
	const value = NAFFlags.config.custom and NAFFlags.config.custom[name] or nil
	const valueText = value ~= nil and tostring(value) or ""
	NAStuff.customFFlagValue = valueText
	if NAgui and NAgui.setInputValue then
		NAgui.setInputValue("Custom Flag Name", NAStuff.customFFlagName, { force = true, fire = true })
		NAgui.setInputValue("Custom Flag Value", valueText, { force = true, fire = true })
	end
	NAFFlags.updateSelectedDisplay()
end

NAFFlags.cycleCustomFlag = function(direction)
	direction = direction or 1
	const names = NAFFlags.getSortedCustomNames()
	const count = #names
	if count == 0 then
		DoNotif("No custom fast flags saved yet.", 3)
		return
	end
	local idx = tonumber(NAStuff.customFlagIndex) or 1
	if direction < 0 then
		idx = idx - 1
	else
		idx = idx + 1
	end
	if idx < 1 then
		idx = count
	elseif idx > count then
		idx = 1
	end
	NAStuff.customFlagIndex = idx
	NAStuff.customFlagNames = names
	const name = names[idx]
	NAFFlags.setCustomInputFields(name)
	NAFFlags.updateSelectedDisplay()
	--DoNotif(Format("Viewing custom fast flag %d/%d: %s", idx, count, tostring(name)), 2)
end

NAFFlags.ensureMaintainLoop = function()
	if NAFFlags._maintainLoopRunning then
		return
	end
	if not (NAFFlags.config.autoApply and NAFFlags.config.autoApplyLoop ~= false and NAFFlags.enabled() and NAFFlags.hasSupport()) then
		return
	end

	const function stillActive()
		return NAFFlags.config.autoApply and NAFFlags.config.autoApplyLoop ~= false and NAFFlags.enabled() and NAFFlags.hasSupport()
	end

	const function loopDelay()
		local n = tonumber(NAFFlags.config.autoApplyInterval) or 3
		if n < 0.1 then n = 0.1 end
		if n > 60 then n = 60 end
		return n
	end

	NAFFlags._maintainLoopRunning = true
	if NAFFlags._maintainConn then
		NAFFlags._maintainConn:Disconnect()
		NAFFlags._maintainConn = nil
	end
	SpawnCall(function()
		while stillActive() and NAFFlags._maintainLoopRunning do
			Wait(loopDelay())
			NAFFlags.applyAll({ notify = false })
		end

		NAFFlags._maintainLoopRunning = false
	end)
end

NAFFlags.stopMaintainLoop = function()
	NAFFlags._maintainLoopRunning = false
	if NAFFlags._maintainConn then
		NAFFlags._maintainConn:Disconnect()
		NAFFlags._maintainConn = nil
	end
end

NAFFlags.disableAll = function()
	NAFFlags.config.useFFlags = false
	NAFFlags.config.autoApply = false
	NAFFlags.config.enabledFlags = NAFFlags.config.enabledFlags or {}

	for _, entry in NAFFlags.whitelist do
		const name = entry.name
		NAFFlags.config.enabledFlags[name] = false
		if entry.valueType == "boolean" then
			NAFFlags.values[name] = false
			NAFFlags.config.flags[name] = false
		end
	end

	local removedCustom = 0
	for _, value in NAFFlags.config.custom or {} do
		if value ~= nil then
			removedCustom += 1
		end
	end
	NAFFlags.config.custom = {}
	NAFFlags.stopMaintainLoop()
	NAFFlags.save()

	if NAgui and NAgui.setToggleState then
		NAgui.setToggleState("Use FastFlags", false, { force = true, fire = false })
		NAgui.setToggleState("Auto-apply FastFlags", false, { force = true, fire = false })
		for _, entry in NAFFlags.whitelist do
			NAgui.setToggleState(entry.name.."_Enabled", false, { force = true, fire = false })
			if entry.valueType == "boolean" then
				NAgui.setToggleState(entry.name, false, { force = true, fire = false })
			end
		end
	end

	if NAStuff then
		NAStuff.customFFlagName = ""
		NAStuff.customFFlagValue = ""
		NAStuff.customFlagIndex = nil
		NAStuff.customFlagNames = {}
	end
	if NAgui and NAgui.setInputValue then
		NAgui.setInputValue("Custom Flag Name", "")
		NAgui.setInputValue("Custom Flag Value", "")
	end
	if type(NAFFlags.refreshCustomListDisplay) == "function" then
		NAFFlags.refreshCustomListDisplay()
	end

	DoNotif(Format("Disabled all FastFlags and removed %d custom flag%s.", removedCustom, removedCustom == 1 and "" or "s"), 3)
end

NAFFlags.autoApplyWithRetry = function(opts)
	opts = opts or {}
	const initialDelays = opts.delays or { 0, 0.5, 1.5 }
	const postLoadDelays = opts.postLoadDelays or { 0, 1 }

	const function runAttempts(delayList)
		for _, delay in delayList do
			if delay > 0 then
				Wait(delay)
			end
			if not (NAFFlags.config.autoApply and NAFFlags.enabled()) then
				return true
			end
			if NAFFlags.hasSupport() then
				local _, success = NAFFlags.applyAll({ notify = false })
				if success then
					return true
				end
			end
		end
		return false
	end

	SpawnCall(function()
		local success = runAttempts(initialDelays)
		if not success then
			local okLoaded, loaded = pcall(function()
				return game:IsLoaded()
			end)
			if not (okLoaded and loaded) then
				pcall(function()
					game.Loaded:Wait()
				end)
			end

			success = runAttempts(postLoadDelays) or success
		end

		if NAFFlags.config.autoApply and NAFFlags.enabled() then
			NAFFlags.ensureMaintainLoop()
		end
	end)
end

NAFFlags.buildSetfflagScript = function()
	NAFFlags.normalizeRenderingPrefs()
	const lines = { "if not setfflag then return warn(\"setfflag unavailable\") end" }
	const seen = {}
	for _, entry in NAFFlags.whitelist do
		const name = entry.name
		if not NAFFlags.isFlagAvailable or NAFFlags.isFlagAvailable(name) then
			local value = NAFFlags.values[name]
			if value == nil then
				value = NAFFlags.getDefault(entry)
			end
			lines[#lines + 1] = Format("setfflag(%q, %q)", name, tostring(value))
			seen[name] = true
		end
	end
	for customName, customValue in NAFFlags.config.custom or {} do
		if not seen[customName] and customValue ~= nil then
			lines[#lines + 1] = Format("setfflag(%q, %q)", customName, tostring(customValue))
		end
	end
	return Concat(lines, "\n")
end

NAFFlags.buildSetfflagScriptEnabled = function()
	NAFFlags.normalizeRenderingPrefs()
	const lines = { "if not setfflag then return warn(\"setfflag unavailable\") end" }
	const seen = {}

	for _, e in NAFFlags.whitelist do
		const n = e.name
		if NAFFlags.isFlagEnabled and not NAFFlags.isFlagEnabled(n) then
			continue
		end
		if not NAFFlags.isFlagAvailable or NAFFlags.isFlagAvailable(n) then
			local v = NAFFlags.values[n]
			if v == nil then
				v = NAFFlags.getDefault(e)
			end
			lines[#lines + 1] = Format("setfflag(%q, %q)", n, tostring(v))
			seen[n] = true
		end
	end

	if not NAFFlags.config.applyWhitelistOnly then
		for n, v in NAFFlags.config.custom or {} do
			if not seen[n] and v ~= nil then
				lines[#lines + 1] = Format("setfflag(%q, %q)", n, tostring(v))
			end
		end
	end

	return Concat(lines, "\n")
end

if NAFFlags.config.autoApply then
	NAFFlags.autoApplyWithRetry()
end

NAgui.addSection("Whitelisted FastFlags")

NAStuff.supportText = NAStuff.supportText or NAFFlags.hasSupport() and "Available" or "Unavailable (setfflag missing)"

NAgui.addInfo("FastFlag Support", NAStuff.supportText)
NAgui.addInfo("Session Warning", "Runtime FastFlags reset after you close Roblox")
NAgui.addInfo("ClientAppSettings Allowlist", "Roblox ignores most non-allowlisted local JSON flags. Runtime support still depends on the current client and executor.")
NAgui.addInfo("Experimental Flags", "Internal flags can be renamed, removed, ignored, or cause visual and stability issues after Roblox updates.")

NAgui.addToggle("Use FastFlags", NAFFlags.config.useFFlags == true, function(state)
	NAFFlags.config.useFFlags = state == true
	NAFFlags.save()
	if NAFFlags.config.autoApply and state == true then
		NAFFlags.autoApplyWithRetry()
	end
end)

NAgui.addToggle("Auto-apply FastFlags", NAFFlags.config.autoApply == true, function(state)
	NAFFlags.config.autoApply = state == true
	NAFFlags.save()
	if state then
		NAFFlags.autoApplyWithRetry()
	end
end)
NAmanage.RegisterToggleAutoSync("Auto-apply FastFlags", function()
	return NAFFlags.config.autoApply == true
end)

NAStuff.autoLoopDefault = NAStuff.autoLoopDefault or math.clamp(tonumber(NAFFlags.config.autoApplyInterval) or 3, 0.1, 60)
NAgui.addToggle("Loop Auto-apply FastFlags", NAFFlags.config.autoApplyLoop ~= false, function(state)
	NAFFlags.config.autoApplyLoop = state ~= false
	NAFFlags.save()
	if state then
		NAFFlags.stopMaintainLoop()
		NAFFlags.ensureMaintainLoop()
	else
		NAFFlags.stopMaintainLoop()
	end
end)
NAmanage.RegisterToggleAutoSync("Loop Auto-apply FastFlags", function()
	return NAFFlags.config.autoApplyLoop ~= false
end)

NAgui.addInput("Auto-apply Interval (s)", "e.g. 3", tostring(NAStuff.autoLoopDefault), function(text)
	local n = tonumber(text)
	if not n then
		DoNotif("Enter a number of seconds (e.g. 3)", 3)
		return
	end
	if n < 0.1 then n = 0.1 end
	if n > 60 then n = 60 end
	NAFFlags.config.autoApplyInterval = n
	NAFFlags.save()
	NAFFlags.stopMaintainLoop()
	NAFFlags.ensureMaintainLoop()
	DoNotif(Format("Auto-apply interval set to %.2f s", n), 2)
	if NAgui.setInputValue then
		NAgui.setInputValue("Auto-apply Interval (s)", Format("%.2f", n))
	end
end)

NAgui.addButton("Apply All FFlags (including custom)", function()
	NAFFlags.applyAll()
end)

NAgui.addButton("Disable All FastFlags", function()
	NAFFlags.disableAll()
end)

NAgui.addToggle("Apply Only Whitelisted FFlags", NAFFlags.config.applyWhitelistOnly == true, function(state)
	NAFFlags.config.applyWhitelistOnly = state == true
	NAFFlags.save()
	const mode = state and "whitelisted only" or "whitelist + custom"
	DoNotif("FastFlags will apply: "..mode, 2)
end)
NAmanage.RegisterToggleAutoSync("Apply Only Whitelisted FFlags", function()
	return NAFFlags.config.applyWhitelistOnly == true
end)

NAgui.addButton("Copy standalone setfflag script", function()
	if not setclipboard then
		DoNotif("Your executor does not support setclipboard", 3)
		return
	end
	const scriptText = NAFFlags.buildSetfflagScript()
	local ok, err = pcall(setclipboard, scriptText)
	if not ok then
		DoNotif("Failed to copy setfflag script: "..tostring(err), 3)
		return
	end
	DoNotif("setfflag script copied to clipboard.", 2)
end)

NAgui.addButton("Copy enabled setfflag script", function()
	if not setclipboard then
		DoNotif("Your executor does not support setclipboard", 3)
		return
	end
	const txt = NAFFlags.buildSetfflagScriptEnabled()
	local ok, err = pcall(setclipboard, txt)
	if not ok then
		DoNotif("Failed to copy setfflag script: "..tostring(err), 3)
		return
	end
	DoNotif("Enabled setfflag script copied to clipboard.", 2)
end)

NAgui.addButton("Copy ClientAppSettings JSON", function()
	if not setclipboard then
		DoNotif("Your executor does not support setclipboard", 3)
		return
	end
	const txt = NAFFlags.buildClientAppSettingsJson()
	local ok, err = pcall(setclipboard, txt)
	if not ok then
		DoNotif("Failed to copy ClientAppSettings JSON: "..tostring(err), 3)
		return
	end
	DoNotif("ClientAppSettings JSON copied to clipboard.", 2)
end)

NAgui.addButton("Import ClientAppSettings JSON from Clipboard", function()
	if type(getclipboard) ~= "function" then
		DoNotif("Your executor does not support getclipboard", 3)
		return
	end
	local ok, raw = pcall(getclipboard)
	if not ok or type(raw) ~= "string" or raw == "" then
		DoNotif("Clipboard is empty or unreadable.", 3)
		return
	end
	NAFFlags.importClientAppSettingsFromText(raw)
end)

NAgui.addButton("Paste ClientAppSettings JSON", function()
	if type(Window) ~= "function" then
		DoNotif("Paste window is unavailable.", 3)
		return
	end
	Window({
		Title = "Import ClientAppSettings JSON";
		Description = "Paste ClientAppSettings JSON. This replaces the current NA FastFlags list and saves NAFFlags.json + NAFFlagsConfig.json.";
		InputField = true;
		Buttons = {{
			Text = "Import";
			Callback = function(raw)
				NAFFlags.importClientAppSettingsFromText(raw)
			end;
		}};
	})
end)

NAgui.addButton("Copy NAFFlagsConfig JSON", function()
	if not setclipboard then
		DoNotif("Your executor does not support setclipboard", 3)
		return
	end
	local txt = "{}"
	if FileSupport and isfile and readfile and isfile(NAFFlags.metaPath) then
		local ok, raw = pcall(readfile, NAFFlags.metaPath)
		if ok and type(raw) == "string" and raw ~= "" then
			txt = raw
		end
	end
	local ok, err = pcall(setclipboard, txt)
	if not ok then
		DoNotif("Failed to copy NAFFlagsConfig JSON: "..tostring(err), 3)
		return
	end
	DoNotif("NAFFlagsConfig JSON copied to clipboard.", 2)
end)

NAgui.addSection("Custom FastFlags")
NAmanage.trimCustomFlagText=function(text)
	const str = tostring(text or "")
	return str:match("^%s*(.-)%s*$") or ""
end
NAStuff.customFFlagName = NAStuff.customFFlagName or ""
NAStuff.customFFlagValue = NAStuff.customFFlagValue or ""
NAgui.addInput("Custom Flag Name", "Enter fast flag name", NAStuff.customFFlagName, function(inputText)
	NAStuff.customFFlagName = inputText
end)
NAgui.addInput("Custom Flag Value", "Enter fast flag value", NAStuff.customFFlagValue, function(inputText)
	NAStuff.customFFlagValue = inputText
end)
NAStuff.customFlagCountInfo = NAStuff.customFlagCountInfo or NAgui.addInfo("Saved Custom Flags", "Saved Custom Flags (0)")
NAStuff.customFlagSelectedInfo = NAStuff.customFlagSelectedInfo or NAgui.addInfo("Selected Custom Flag", "Selected Custom Flag: None")
NAStuff.customFlagDropdownLabel = NAStuff.customFlagDropdownLabel or "Select Custom Flag"
NAgui.addDropdown(NAStuff.customFlagDropdownLabel, { "None" }, "None", function(selection)
	local selectedName = selection
	if type(selectedName) == "table" then
		selectedName = selectedName[1]
	end
	selectedName = NAmanage.trimCustomFlagText(selectedName)
	if selectedName == "" or Lower(selectedName) == "none" then
		return
	end
	const names = NAFFlags.getSortedCustomNames()
	for idx, name in names do
		if name == selectedName then
			NAStuff.customFlagIndex = idx
			break
		end
	end
	NAStuff.customFlagNames = names
	NAFFlags.setCustomInputFields(selectedName)
	NAFFlags.updateSelectedDisplay()
end)
NAFFlags.refreshCustomListDisplay()

NAgui.addButton("Add / Update Custom Flag", function()
	const name = NAmanage.trimCustomFlagText(NAStuff.customFFlagName)
	const valueRaw = NAStuff.customFFlagValue
	if name == "" then
		DoNotif("Enter a fast flag name first.", 3)
		return
	end
	if valueRaw == nil or valueRaw == "" then
		DoNotif("Enter a fast flag value first.", 3)
		return
	end
	if NAFFlags.isWhitelistedFlag and NAFFlags.isWhitelistedFlag(name) then
		DoNotif("That flag already exists in the built-in list above.", 3)
		return
	end
	const parsedValue = NAFFlags.parseCustomValue and NAFFlags.parseCustomValue(valueRaw) or valueRaw
	local ok, err = NAFFlags.setCustomFlag(name, parsedValue)
	if ok then
		DoNotif(Format("Saved custom fast flag %s = %s", name, tostring(parsedValue)), 2)
	else
		DoNotif(tostring(err or "Failed to save custom fast flag"), 3)
	end
end)

NAgui.addButton("Test Custom Flag", function()
	const name = NAmanage.trimCustomFlagText(NAStuff.customFFlagName)
	const valueRaw = NAStuff.customFFlagValue
	if name == "" then
		DoNotif("Enter a fast flag name to test.", 3)
		return
	end
	if valueRaw == nil or valueRaw == "" then
		DoNotif("Enter a fast flag value to test.", 3)
		return
	end
	const parsedValue = NAFFlags.parseCustomValue and NAFFlags.parseCustomValue(valueRaw) or valueRaw
	local ok, err = NAFFlags.apply(name, parsedValue, { allowDisabled = true, silent = true })
	if ok then
		DoNotif(Format("Successfully set %s = %s", name, tostring(parsedValue)), 2)
	else
		DoNotif(Format("Failed to set %s: %s", name, tostring(err or "Unknown error")), 4)
	end
end)

NAgui.addButton("Remove Custom Flag", function()
	const name = NAmanage.trimCustomFlagText(NAStuff.customFFlagName)
	if name == "" then
		DoNotif("Enter the custom flag name you want to remove.", 3)
		return
	end
	if not (NAFFlags.config.custom and NAFFlags.config.custom[name]) then
		DoNotif("No saved custom flag with that name.", 3)
		return
	end
	local ok, err = NAFFlags.removeCustomFlag(name)
	if ok then
		DoNotif("Removed custom fast flag "..name, 2)
	else
		DoNotif(tostring(err or "Failed to remove custom fast flag"), 3)
	end
end)

NAgui.addSection("FastFlag Categories")

local currentFFlagCategory = nil
for _, entry in NAFFlags.whitelist do
	const entryCategory = entry.category or "Other"
	if entryCategory ~= currentFFlagCategory then
		currentFFlagCategory = entryCategory
		NAgui.addSection(entryCategory)
	end

	const entryName = entry.name
	const desc = NAFFlags.info and NAFFlags.info[entryName] or nil

	if NAFFlags.isFlagAvailable and not NAFFlags.isFlagAvailable(entryName) then
		continue
	end

	const function getEnabled()
		const v = NAFFlags.config and NAFFlags.config.enabledFlags and NAFFlags.config.enabledFlags[entryName]
		return v == true
	end

	const function setEnabled(v)
		if not NAFFlags.config then
			return
		end
		NAFFlags.config.enabledFlags = NAFFlags.config.enabledFlags or {}
		NAFFlags.config.enabledFlags[entryName] = v and true or false
		NAFFlags.save()
		if v and NAFFlags.enabled() then
			if NAFFlags.isRenderingPreferFlag and NAFFlags.isRenderingPreferFlag(entryName) or entryName == NAFFlags.renderingDisableFlag then
				NAFFlags.applyAll({ notify = false })
			else
				NAFFlags.apply(entryName, NAFFlags.values[entryName], { silent = true })
			end
		end
	end

	const sideOpts = {
		sideChip = true,
		sideName = entryName.."_Enabled",
		sideText = "Use",
		sideGet = getEnabled,
		sideSet = setEnabled,
	}

	if entry.valueType == "boolean" then
		NAgui.addToggle(entryName, NAFFlags.values[entryName] == true, function(state)
			if NAFFlags._lockedDefaults and NAFFlags._lockedDefaults[entryName] then
				DoNotif(entryName.." cannot be changed on this executor (default-locked).", 3)
				return
			end
			const normalized = NAFFlags.normalizeValue(entry, state)
			if normalized == nil then
				return
			end
			NAFFlags.values[entryName] = normalized
			NAFFlags.config.flags[entryName] = normalized
			const isRenderingPrefer = NAFFlags.isRenderingPreferFlag and NAFFlags.isRenderingPreferFlag(entryName)
			const isRenderingDisable = entryName == NAFFlags.renderingDisableFlag
			if NAFFlags.normalizeRenderingPrefs and (isRenderingPrefer or isRenderingDisable) then
				NAFFlags.normalizeRenderingPrefs(entryName)
			end
			NAFFlags.save()
			if getEnabled() and NAFFlags.enabled() then
				if isRenderingPrefer or isRenderingDisable then
					NAFFlags.applyAll({ notify = false })
				else
					NAFFlags.apply(entryName, normalized)
				end
			end
		end, sideOpts)
	else
		local defaultTextValue = NAFFlags.values[entryName]
		if defaultTextValue == nil then
			defaultTextValue = NAFFlags.getDefault(entry)
		end
		const defaultText = tostring(defaultTextValue)

		const function applyEntryValue(rawValue)
			const normalized = NAFFlags.normalizeValue(entry, rawValue)
			if normalized == nil then
				return false
			end
			NAFFlags.values[entryName] = normalized
			NAFFlags.config.flags[entryName] = normalized
			NAFFlags.save()
			return true
		end

		NAgui.addInput(entryName, "Enter value", defaultText, function(inputValue)
			if applyEntryValue(inputValue) and getEnabled() and NAFFlags.enabled() then
				NAFFlags.apply(entryName, NAFFlags.values[entryName])
			end
		end, sideOpts)
	end

	if desc and desc ~= "" then
		NAgui.addSection(desc)
	end
end

NAgui.addTab(NA_TABS.TAB_INTEGRATIONS, { order = 2, textIcon = "chain-link" })
NAgui.setTab(NA_TABS.TAB_INTEGRATIONS)

NAgui.addSection("Integrations")

NAgui.addButton("Load Cmd (qipu)", function()
	local ok, err = NAmanage.loadCmdIntegration()
	if not ok then
		const msg = "Cmd failed to load: "..tostring(err)
		if type(DoNotif) == "function" then
			DoNotif(msg, 4)
		else
			warn(msg)
		end
	end
end)

NAgui.addToggle("Auto-load Cmd (qipu)", NAStuff.CmdIntegrationAutoRun == true, function(v)
	NAStuff.CmdIntegrationAutoRun = v and true or false
	pcall(NAmanage.NASettingsSet, "cmdIntegrationAutoRun", NAStuff.CmdIntegrationAutoRun)
	if v then
		local ok, err = NAmanage.loadCmdIntegration()
		if not ok then
			const msg = "Cmd failed to load: "..tostring(err)
			if type(DoNotif) == "function" then
				DoNotif(msg, 4)
			else
				warn(msg)
			end
		end
	end
end)
NAmanage.RegisterToggleAutoSync("Auto-load Cmd (qipu)", function()
	return NAStuff.CmdIntegrationAutoRun == true
end)

NAgui.addButton("Refresh Cmd Integration", function()
	if not NAStuff.CmdIntegrationLoaded then
		local ok, err = NAmanage.detectCmdManualLoad()
		if not ok then
			DoNotif("Cmd integration unavailable: "..tostring(err), 4)
			return
		end
	end
	local ok, result = NAmanage.CmdIntegrationRefresh({ refreshUI = true })
	if ok then
		DoNotif("Cmd integration refreshed ("..tostring(#result).." commands)", 3)
	else
		DoNotif("Cmd refresh failed: "..tostring(result), 4)
	end
end)

NAgui.addButton("Open Cmd Command Bar", function()
	const bridge = NAStuff.CmdIntegrationBridge
	const openMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "OpenCommandBar", "openCommandBar", "open" })
	if type(openMethod) ~= "function" then
		DoNotif("Cmd command bar access is unavailable.", 3)
		return
	end
	local ok, result = pcall(openMethod)
	if not ok or result == false then
		DoNotif("Cmd command bar failed to open.", 3)
	end
end)

NAgui.addButton("Cmd Integration Status", function()
	const bridge = NAStuff.CmdIntegrationBridge
	if type(bridge) ~= "table" then
		DoNotif("Cmd integration is disconnected.", 3)
		return
	end
	const stateMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "GetState", "getState" })
	local state = NAStuff.CmdIntegrationState or {}
	if type(stateMethod) == "function" then
		local ok, result = pcall(stateMethod)
		if ok and type(result) == "table" then
			state = result
			NAStuff.CmdIntegrationState = result
		end
	end
	const commandCount = type(NAStuff.CmdIntegrationCommands) == "table" and #NAStuff.CmdIntegrationCommands or tonumber(state.commandCount) or 0
	DoNotif("Cmd v"..tostring(state.version or bridge.Version or bridge.version or "unknown").." | protocol "..tostring(NAStuff.CmdIntegrationProtocol or bridge.Protocol or bridge.protocol or 1).." | "..tostring(commandCount).." commands | route: "..tostring(NAStuff.CmdIntegrationRoutingMode), 5)
end)

NAgui.addButton("Disconnect Cmd Integration", function()
	NAmanage.disconnectCmdIntegration()
end)

NAgui.addDropdown("Cmd Routing Priority", NAmanage.CmdIntegrationModes, NAStuff.CmdIntegrationRoutingMode, function(selection)
	NAStuff.CmdIntegrationRoutingMode = NAmanage.CmdIntegrationNormalizeMode(selection)
	pcall(NAmanage.NASettingsSet, "cmdIntegrationRoutingMode", NAStuff.CmdIntegrationRoutingMode)
	DoNotif("Cmd routing set to "..NAStuff.CmdIntegrationRoutingMode, 3)
end)

NAgui.addToggle("Expose NA Gateway in Cmd", NAStuff.CmdIntegrationExposeGateway ~= false, function(value)
	NAStuff.CmdIntegrationExposeGateway = value == true
	pcall(NAmanage.NASettingsSet, "cmdIntegrationExposeGateway", NAStuff.CmdIntegrationExposeGateway)
	if NAStuff.CmdIntegrationLoaded then
		if NAStuff.CmdIntegrationExposeGateway then
			local ok, err = NAmanage.CmdIntegrationInstallGateway()
			if not ok then
				DoNotif("NA gateway failed: "..tostring(err), 4)
			end
		else
			NAmanage.CmdIntegrationRemoveGateway()
		end
		NAmanage.CmdIntegrationRefresh({ refreshUI = true })
	end
end)
NAmanage.RegisterToggleAutoSync("Expose NA Gateway in Cmd", function()
	return NAStuff.CmdIntegrationExposeGateway ~= false
end)

NAgui.addToggle("Cmd Command Notifications", NAStuff.CmdIntegrationUseNotifications ~= false, function(value)
	NAStuff.CmdIntegrationUseNotifications = value == true
	pcall(NAmanage.NASettingsSet, "cmdIntegrationUseNotifications", NAStuff.CmdIntegrationUseNotifications)
end)
NAmanage.RegisterToggleAutoSync("Cmd Command Notifications", function()
	return NAStuff.CmdIntegrationUseNotifications ~= false
end)

NAgui.addToggle("Mirror Cmd Notifications in NA", NAStuff.CmdIntegrationMirrorNotifications == true, function(value)
	NAStuff.CmdIntegrationMirrorNotifications = value == true
	pcall(NAmanage.NASettingsSet, "cmdIntegrationMirrorNotifications", NAStuff.CmdIntegrationMirrorNotifications)
end)
NAmanage.RegisterToggleAutoSync("Mirror Cmd Notifications in NA", function()
	return NAStuff.CmdIntegrationMirrorNotifications == true
end)

NAgui.addSection("Infinite Yield")

NAgui.addButton("Load Infinite Yield", function()
	local ok, err = NAmanage.loadIYIntegration()
	if not ok then
		const msg = "Infinite Yield failed to load: "..tostring(err)
		if type(DoNotif) == "function" then DoNotif(msg, 4) else warn(msg) end
	end
end)

NAgui.addToggle("Auto-load Infinite Yield", NAStuff.IYIntegrationAutoRun == true, function(v)
	NAStuff.IYIntegrationAutoRun = v and true or false
	pcall(NAmanage.NASettingsSet, "iyIntegrationAutoRun", NAStuff.IYIntegrationAutoRun)
	if v then
		local ok, err = NAmanage.loadIYIntegration()
		if not ok then
			const msg = "Infinite Yield failed to load: "..tostring(err)
			if type(DoNotif) == "function" then DoNotif(msg, 4) else warn(msg) end
		end
	end
end)
NAmanage.RegisterToggleAutoSync("Auto-load Infinite Yield", function() return NAStuff.IYIntegrationAutoRun == true end)

NAgui.addButton("Refresh Infinite Yield Integration", function()
	if not NAStuff.IYIntegrationLoaded then
		local ok, err = NAmanage.detectIYManualLoad()
		if not ok then DoNotif("Infinite Yield integration unavailable: "..tostring(err), 4); return end
	end
	local ok, result = NAmanage.IYIntegrationRefresh({ refreshUI = true })
	if ok then DoNotif("Infinite Yield integration refreshed ("..tostring(#result).." commands)", 3) else DoNotif("Infinite Yield refresh failed: "..tostring(result), 4) end
end)

NAgui.addButton("Open Infinite Yield Command Bar", function()
	const bridge = NAStuff.IYIntegrationBridge
	const openMethod = NAmanage.IYIntegrationGetMethod(bridge, { "OpenCommandBar", "openCommandBar", "open" })
	if type(openMethod) ~= "function" then DoNotif("Infinite Yield command bar access is unavailable.", 3); return end
	local ok, result = pcall(openMethod)
	if not ok or result == false then DoNotif("Infinite Yield command bar failed to open.", 3) end
end)

NAgui.addButton("Infinite Yield Integration Status", function()
	const bridge = NAStuff.IYIntegrationBridge
	if type(bridge) ~= "table" then DoNotif("Infinite Yield integration is disconnected.", 3); return end
	const stateMethod = NAmanage.IYIntegrationGetMethod(bridge, { "GetState", "getState" })
	local state = NAStuff.IYIntegrationState or {}
	if type(stateMethod) == "function" then
		local ok, result = pcall(stateMethod)
		if ok and type(result) == "table" then state = result; NAStuff.IYIntegrationState = result end
	end
	const commandCount = type(NAStuff.IYIntegrationCommands) == "table" and #NAStuff.IYIntegrationCommands or tonumber(state.commandCount) or 0
	DoNotif("Infinite Yield v"..tostring(state.version or bridge.Version or bridge.version or "unknown").." | protocol "..tostring(NAStuff.IYIntegrationProtocol or bridge.Protocol or bridge.protocol or 1).." | "..tostring(commandCount).." commands | route: "..tostring(NAStuff.IYIntegrationRoutingMode), 5)
end)

NAgui.addButton("Disconnect Infinite Yield Integration", function() NAmanage.disconnectIYIntegration() end)

NAgui.addDropdown("Infinite Yield Routing Priority", NAmanage.IYIntegrationModes, NAStuff.IYIntegrationRoutingMode, function(selection)
	NAStuff.IYIntegrationRoutingMode = NAmanage.IYIntegrationNormalizeMode(selection)
	pcall(NAmanage.NASettingsSet, "iyIntegrationRoutingMode", NAStuff.IYIntegrationRoutingMode)
	DoNotif("Infinite Yield routing set to "..NAStuff.IYIntegrationRoutingMode, 3)
end)

NAgui.addToggle("Expose NA Gateway in Infinite Yield", NAStuff.IYIntegrationExposeGateway ~= false, function(value)
	NAStuff.IYIntegrationExposeGateway = value == true
	pcall(NAmanage.NASettingsSet, "iyIntegrationExposeGateway", NAStuff.IYIntegrationExposeGateway)
	if NAStuff.IYIntegrationLoaded then
		if NAStuff.IYIntegrationExposeGateway then
			local ok, err = NAmanage.IYIntegrationInstallGateway()
			if not ok then DoNotif("Infinite Yield NA gateway failed: "..tostring(err), 4) end
		else
			NAmanage.IYIntegrationRemoveGateway()
		end
		NAmanage.IYIntegrationRefresh({ refreshUI = true })
	end
end)
NAmanage.RegisterToggleAutoSync("Expose NA Gateway in Infinite Yield", function() return NAStuff.IYIntegrationExposeGateway ~= false end)

NAgui.addToggle("Mirror Infinite Yield Notifications in NA", NAStuff.IYIntegrationMirrorNotifications == true, function(value)
	NAStuff.IYIntegrationMirrorNotifications = value == true
	pcall(NAmanage.NASettingsSet, "iyIntegrationMirrorNotifications", NAStuff.IYIntegrationMirrorNotifications)
end)
NAmanage.RegisterToggleAutoSync("Mirror Infinite Yield Notifications in NA", function() return NAStuff.IYIntegrationMirrorNotifications == true end)

NAgui.addToggle("Bloxtrap RPC Presence", NAmanage.btEnabled(), function(v)
	NAmanage.btSetEnabled(v)
	if v then
		NAmanage.btGetExecutorInfo(true)
		NAmanage.btUpdate()
	end
end)
NAmanage.RegisterToggleAutoSync("Bloxtrap RPC Presence", function()
	return NAmanage.btEnabled()
end)

NAgui.addSection("Discord Webhook Routing")
NAStuff.Integrations = NAStuff.Integrations or {}
const webhookCfg = NAmanage.NormalizeWebhookConfig(NAStuff.Integrations.webhook or {})
NAStuff.Integrations.webhook = webhookCfg

NAmanage.SaveWebhookOptions = NAmanage.SaveWebhookOptions or function()
	if NAmanage.NASettingsSet and NAStuff.Integrations and NAStuff.Integrations.webhook then
		NAmanage.NASettingsSet("integrationWebhookOptions", NAStuff.Integrations.webhook.options)
	end
end
NAmanage.SaveWebhookTemplates = NAmanage.SaveWebhookTemplates or function()
	if NAmanage.NASettingsSet and NAStuff.Integrations and NAStuff.Integrations.webhook then
		NAmanage.NASettingsSet("integrationWebhookTemplates", NAStuff.Integrations.webhook.templates)
	end
end

NAgui.addToggle("Enable Discord Webhooks", webhookCfg.options.enabled, function(v)
	webhookCfg.options.enabled = v and true or false
	NAmanage.SaveWebhookOptions()
end)
NAgui.addInput("All Events Webhook", "https://discord.com/api/webhooks/...", webhookCfg.urls.all, function(text)
	webhookCfg.urls.all = text or ""
	webhookCfg.url = webhookCfg.urls.all
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookUrlAll", webhookCfg.urls.all)
		NAmanage.NASettingsSet("integrationWebhookUrl", webhookCfg.urls.all)
	end
end)
NAgui.addInput("Join/Leave Webhook", "https://discord.com/api/webhooks/...", webhookCfg.urls.joinleave, function(text)
	webhookCfg.urls.joinleave = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookUrlJoinLeave", webhookCfg.urls.joinleave)
	end
end)
NAgui.addInput("Chat Webhook", "https://discord.com/api/webhooks/...", webhookCfg.urls.chat, function(text)
	webhookCfg.urls.chat = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookUrlChat", webhookCfg.urls.chat)
	end
end)
NAgui.addInput("Command Webhook", "https://discord.com/api/webhooks/...", webhookCfg.urls.commands, function(text)
	webhookCfg.urls.commands = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookUrlCommands", webhookCfg.urls.commands)
	end
end)
NAgui.addToggle("Send To All Webhooks", webhookCfg.useAll == true, function(v)
	webhookCfg.useAll = v and true or false
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookUseAll", webhookCfg.useAll)
	end
end)
NAgui.addSlider("Min Delivery Interval", 0, 30, NAmanage.clampNumber(webhookCfg.minInterval, 0, 30, 2), 0.5, " s", function(v)
	webhookCfg.minInterval = NAmanage.clampNumber(v, 0, 30, 2)
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookInterval", webhookCfg.minInterval)
	end
end)
NAgui.addToggle("Separate Event Cooldowns", webhookCfg.options.separateCooldowns, function(v)
	webhookCfg.options.separateCooldowns = v and true or false
	webhookCfg.lastSentByKind = {}
	NAmanage.SaveWebhookOptions()
end)

NAgui.addSection("Webhook Event Capture")
NAgui.addToggle("Send Join/Leave", webhookCfg.enableJoinLeave, function(v)
	webhookCfg.enableJoinLeave = v and true or false
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookJoinLeave", webhookCfg.enableJoinLeave)
	end
end)
NAgui.addToggle("Send Chat Messages", webhookCfg.enableChat, function(v)
	webhookCfg.enableChat = v and true or false
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookChat", webhookCfg.enableChat)
	end
end)
NAgui.addToggle("Send Command Logs", webhookCfg.enableCommands, function(v)
	webhookCfg.enableCommands = v and true or false
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookCommands", webhookCfg.enableCommands)
	end
end)

NAgui.addSection("Webhook Appearance")
NAgui.addInput("Webhook Username", "Nameless Admin", webhookCfg.options.username, function(text)
	webhookCfg.options.username = tostring(text or ""):sub(1, 80)
	NAmanage.SaveWebhookOptions()
end)
NAgui.addInput("Webhook Avatar URL", "https://example.com/avatar.png", webhookCfg.options.avatarUrl, function(text)
	webhookCfg.options.avatarUrl = text or ""
	NAmanage.SaveWebhookOptions()
end)
NAgui.addToggle("Use Rich Embeds", webhookCfg.options.useEmbeds, function(v)
	webhookCfg.options.useEmbeds = v and true or false
	NAmanage.SaveWebhookOptions()
end)
NAgui.addInput("Embed Title Prefix", "Nameless Admin", webhookCfg.options.titlePrefix, function(text)
	webhookCfg.options.titlePrefix = tostring(text or ""):sub(1, 120)
	NAmanage.SaveWebhookOptions()
end)
NAgui.addInput("Embed Footer", "Nameless Admin", webhookCfg.options.footerText, function(text)
	webhookCfg.options.footerText = tostring(text or ""):sub(1, 2048)
	NAmanage.SaveWebhookOptions()
end)
NAgui.addInput("Embed Thumbnail URL", "https://example.com/icon.png", webhookCfg.options.thumbnailUrl, function(text)
	webhookCfg.options.thumbnailUrl = text or ""
	NAmanage.SaveWebhookOptions()
end)
NAgui.addInput("Embed Image URL", "https://example.com/banner.png", webhookCfg.options.imageUrl, function(text)
	webhookCfg.options.imageUrl = text or ""
	NAmanage.SaveWebhookOptions()
end)
NAgui.addToggle("Include Timestamp", webhookCfg.options.includeTimestamp, function(v)
	webhookCfg.options.includeTimestamp = v and true or false
	NAmanage.SaveWebhookOptions()
end)
NAgui.addToggle("Include Server Context", webhookCfg.options.includeServerInfo, function(v)
	webhookCfg.options.includeServerInfo = v and true or false
	NAmanage.SaveWebhookOptions()
end)
NAgui.addToggle("Block All Mentions", webhookCfg.options.blockMentions, function(v)
	webhookCfg.options.blockMentions = v and true or false
	NAmanage.SaveWebhookOptions()
end)
NAgui.addToggle("Silent Notifications", webhookCfg.options.silent, function(v)
	webhookCfg.options.silent = v and true or false
	NAmanage.SaveWebhookOptions()
end)
NAgui.addToggle("Text To Speech", webhookCfg.options.tts, function(v)
	webhookCfg.options.tts = v and true or false
	NAmanage.SaveWebhookOptions()
end)

NAgui.addSection("Webhook Event Colors")
for _, colorInfo in {
	{ "Join Color", "join" };
	{ "Leave Color", "leave" };
	{ "Chat Color", "chat" };
	{ "Command Color", "command" };
	{ "Main Message Color", "main" };
	{ "Test Color", "test" };
} do
	const colorLabel, colorKey = colorInfo[1], colorInfo[2]
	NAgui.addInput(colorLabel, "Hex: 7C3AED", webhookCfg.options.colors[colorKey], function(text)
		webhookCfg.options.colors[colorKey] = NAmanage.NormalizeWebhookHex(text, NAmanage.WebhookColorDefaults[colorKey])
		NAmanage.SaveWebhookOptions()
	end)
end

NAgui.addSection("Webhook Event Templates")
NAgui.addSection("Placeholders: {player} {display} {userId} {message} {command} {placeId} {gameId} {jobId} {players} {maxPlayers} {admin} {time}")
NAgui.addInput("Join Template", "**{player}** joined the server.", webhookCfg.templates.join, function(text)
	webhookCfg.templates.join = text ~= "" and text or NAmanage.WebhookTemplateDefaults.join
	NAmanage.SaveWebhookTemplates()
end)
NAgui.addInput("Leave Template", "**{player}** left the server.", webhookCfg.templates.leave, function(text)
	webhookCfg.templates.leave = text ~= "" and text or NAmanage.WebhookTemplateDefaults.leave
	NAmanage.SaveWebhookTemplates()
end)
NAgui.addInput("Chat Template", "**{player}:** {message}", webhookCfg.templates.chat, function(text)
	webhookCfg.templates.chat = text ~= "" and text or NAmanage.WebhookTemplateDefaults.chat
	NAmanage.SaveWebhookTemplates()
end)
NAgui.addInput("Command Template", "**{player}** ran `{command}`", webhookCfg.templates.command, function(text)
	webhookCfg.templates.command = text ~= "" and text or NAmanage.WebhookTemplateDefaults.command
	NAmanage.SaveWebhookTemplates()
end)

NAgui.addSection("Webhook Tests & Diagnostics")
NAmanage.WebhookSampleContext = NAmanage.WebhookSampleContext or {
	player = "ExamplePlayer";
	display = "Example Player";
	userId = "123456789";
	message = "Hello from Nameless Admin.";
	command = ";fly me";
	action = "joined";
}
NAmanage.SendWebhookUiTest = NAmanage.SendWebhookUiTest or function(kind)
	local content
	if kind == "test" then
		content = Format("Configuration test from %s.", adminName or "NA")
	else
		content = NAmanage.BuildWebhookEventText(kind, NAmanage.WebhookSampleContext)
	end
	local ok, err, count = NAmanage.SendIntegrationWebhook(kind, content)
	if ok then
		DoNotif(Format("Webhook test sent to %d route(s).", tonumber(count) or 1), 3)
	else
		DoNotif("Webhook test failed: "..tostring(err), 4)
	end
end
NAgui.addButton("Test All Configured Webhooks", function()
	NAmanage.SendWebhookUiTest("test")
end)
NAgui.addButton("Test Join Route", function()
	NAmanage.SendWebhookUiTest("join")
end)
NAgui.addButton("Test Leave Route", function()
	NAmanage.SendWebhookUiTest("leave")
end)
NAgui.addButton("Test Chat Route", function()
	NAmanage.SendWebhookUiTest("chat")
end)
NAgui.addButton("Test Command Route", function()
	NAmanage.SendWebhookUiTest("command")
end)
NAgui.addButton("Copy Payload Preview", function()
	const previewText = NAmanage.BuildWebhookEventText("chat", NAmanage.WebhookSampleContext)
	const payload = NAmanage.BuildIntegrationWebhookPayload("chat", previewText)
	local ok, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, payload)
	if not ok then
		DoNotif("Preview encode failed: "..tostring(encoded), 3)
	elseif type(setclipboard) == "function" then
		setclipboard(encoded)
		DoNotif("Webhook payload preview copied.", 2)
	else
		DoNotif(encoded, 5)
	end
end)
NAgui.addButton("Show Delivery Stats", function()
	const stats = webhookCfg.stats
	const statusText = stats.lastStatus and tostring(stats.lastStatus) or "none"
	local message = Format("Sent: %d | Failed: %d | Last HTTP: %s", stats.sent, stats.failed, statusText)
	if stats.lastError ~= "" then
		message ..= " | Error: "..NAmanage.WebhookClampText(stats.lastError, 120)
	end
	DoNotif(message, 5)
end)
NAgui.addButton("Reset Delivery Stats", function()
	webhookCfg.stats.sent = 0
	webhookCfg.stats.failed = 0
	webhookCfg.stats.lastStatus = nil
	webhookCfg.stats.lastError = ""
	webhookCfg.stats.lastSentAt = 0
	DoNotif("Webhook delivery stats reset.", 2)
end)

NAgui.addSection("Main Webhook Sender")
NAgui.addInput("Main Webhook", "https://discord.com/api/webhooks/...", webhookCfg.urls.main, function(text)
	webhookCfg.urls.main = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookUrlMain", webhookCfg.urls.main)
	end
end)
NAgui.addInput("Message", "Enter message to send", webhookCfg.mainMessage, function(text)
	webhookCfg.mainMessage = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookDraft", webhookCfg.mainMessage)
	end
end)
NAgui.addButton("Send Main Webhook Message", function()
	const msg = webhookCfg.mainMessage or ""
	if msg == "" then
		DoNotif("Please enter a message to send.", 3)
		return
	end
	local ok, err = NAmanage.SendIntegrationWebhook("main", msg)
	if ok then
		DoNotif("Main webhook message sent.", 2)
	else
		DoNotif("Main webhook failed: "..tostring(err), 3)
	end
end)

NAgui.addSection("Raw Webhook Payload")
NAgui.addInput("Raw JSON Payload", [[{"content":"Hello from Nameless Admin"}]], webhookCfg.rawPayload, function(text)
	webhookCfg.rawPayload = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationWebhookRawDraft", webhookCfg.rawPayload)
	end
end)
NAgui.addButton("Send Raw JSON To Main Webhook", function()
	local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, webhookCfg.rawPayload or "")
	if not okDecode or type(decoded) ~= "table" then
		DoNotif("Raw webhook JSON is invalid: "..tostring(decoded), 4)
		return
	end
	local ok, err = NAmanage.SendIntegrationWebhook("main", decoded)
	if ok then
		DoNotif("Raw webhook payload sent.", 2)
	else
		DoNotif("Raw webhook failed: "..tostring(err), 3)
	end
end)
NAgui.addButton("Copy Raw JSON Example", function()
	const example = [[{"content":"Optional plain text","embeds":[{"title":"Custom title","description":"Custom description","color":8131565}]}]]
	if type(setclipboard) == "function" then
		setclipboard(example)
		DoNotif("Raw webhook JSON example copied.", 2)
	else
		DoNotif(example, 5)
	end
end)

NAgui.addSection("API Health Checks")
const function setHealthEndpoint(i, val)
	NAStuff.Integrations.health.endpoints[i] = val or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationHealthEndpoints", NAStuff.Integrations.health.endpoints)
	end
end
const healthDefaults = NAStuff.Integrations.health.endpoints
for i = 1, 3 do
	NAgui.addInput("Endpoint #"..i, "https://example.com/health", healthDefaults[i] or "", function(text)
		setHealthEndpoint(i, text)
	end)
end
NAgui.addButton("Ping Endpoints", function()
	const results = NAmanage.HealthPingAll()
	if #results == 0 then
		DoNotif("No endpoints configured.", 3)
	else
		DoNotif(Concat(results, " | "), 4)
	end
end)
NAgui.addButton("Copy Health Report", function()
	const results = NAmanage.HealthPingAll()
	const report = #results > 0 and Concat(results, " | ") or "No endpoints configured."
	if type(setclipboard) == "function" then
		setclipboard(report)
		DoNotif("Health report copied.", 2)
	else
		DoNotif(report, 5)
	end
end)
NAgui.addButton("Send Health Report To Main Webhook", function()
	const results = NAmanage.HealthPingAll()
	if #results == 0 then
		DoNotif("No endpoints configured.", 3)
		return
	end
	local ok, err = NAmanage.SendIntegrationWebhook("main", "**API Health Report**\n"..Concat(results, "\n"))
	if ok then
		DoNotif("Health report sent to main webhook.", 2)
	else
		DoNotif("Health report failed: "..tostring(err), 3)
	end
end)

NAgui.addSection("Notes / Clipboard")
NAgui.addInput("Note Text", "Optional note to save/copy", NAStuff.Integrations.notes.last, function(text)
	NAStuff.Integrations.notes.last = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationNotesLast", NAStuff.Integrations.notes.last)
	end
end)
NAgui.addButton("Copy Server Info + Note", function()
	const note = NAStuff.Integrations.notes.last or ""
	const payload = NAmanage.ComposeServerNote(note)
	if setclipboard then
		setclipboard(payload)
		DoNotif("Server info copied to clipboard.", 2)
	else
		DoNotif(payload, 3)
	end
end)

NAgui.addSection("Server Actions")
const function copyIntegrationText(label, value)
	if type(setclipboard) ~= "function" then
		DoNotif("Your executor does not support setclipboard.", 3)
		return false
	end
	local ok, err = pcall(setclipboard, tostring(value or ""))
	if ok then
		DoNotif(label.." copied to clipboard.", 2)
		return true
	end
	DoNotif("Clipboard failed: "..tostring(err), 3)
	return false
end

const function getIntegrationTeleportScript()
	const placeId = tostring(game.PlaceId or "")
	const jobId = tostring(game.JobId or "")
	if placeId == "" or jobId == "" then
		return ""
	end
	return Concat({
		'local Players = game:GetService("Players")',
		'local TeleportService = game:GetService("TeleportService")',
		'local ExperienceService = game:GetService("ExperienceService")',
		'local lp = Players.LocalPlayer',
		'local params = { placeId = '..placeId..', gameInstanceId = '..Format("%q", jobId)..' }',
		'local usedFallback = false',
		'local function fallback() if usedFallback then return end usedFallback = true pcall(function() ExperienceService:LaunchExperience(params) end) end',
		'local con; con = TeleportService.TeleportInitFailed:Connect(function(player) if player == lp then if con then con:Disconnect() end fallback() end end)',
		'local ok = pcall(function() TeleportService:TeleportToPlaceInstance('..placeId..', '..Format("%q", jobId)..', lp) end)',
		'if not ok then if con then con:Disconnect() end fallback() end',
	}, "\n")
end

const function getIntegrationServerIds()
	const parts = {
		"PlaceId: "..tostring(game.PlaceId or ""),
		"GameId: "..tostring(game.GameId or ""),
	}
	const jobId = tostring(game.JobId or "")
	if jobId ~= "" then
		parts[#parts + 1] = "JobId: "..jobId
	end
	return Concat(parts, " | ")
end

const function getIntegrationGameUrl()
	const placeId = tostring(game.PlaceId or "")
	if placeId == "" then
		return ""
	end
	return "https://www.roblox.com/games/"..placeId
end

NAgui.addButton("Copy PlaceId", function()
	copyIntegrationText("PlaceId", game.PlaceId or "")
end)
NAgui.addButton("Copy GameId", function()
	const gameId = tostring(game.GameId or "")
	if gameId == "" then
		DoNotif("This game does not expose a GameId yet.", 3)
		return
	end
	copyIntegrationText("GameId", gameId)
end)
NAgui.addButton("Copy JobId", function()
	const jobId = tostring(game.JobId or "")
	if jobId == "" then
		DoNotif("This server does not expose a JobId yet.", 3)
		return
	end
	copyIntegrationText("JobId", jobId)
end)
NAgui.addButton("Copy Teleport Script", function()
	const scriptText = getIntegrationTeleportScript()
	if scriptText == "" then
		DoNotif("Teleport script unavailable right now.", 3)
		return
	end
	copyIntegrationText("Teleport script", scriptText)
end)
NAgui.addButton("Copy All Server IDs", function()
	copyIntegrationText("Server IDs", getIntegrationServerIds())
end)
NAgui.addButton("Copy Game URL", function()
	const gameUrl = getIntegrationGameUrl()
	if gameUrl == "" then
		DoNotif("Game URL unavailable right now.", 3)
		return
	end
	copyIntegrationText("Game URL", gameUrl)
end)
NAgui.addButton("Send Server Info To Main Webhook", function()
	const payload = NAmanage.ComposeServerNote(NAStuff.Integrations.notes.last or "")
	local ok, err = NAmanage.SendIntegrationWebhook("main", payload)
	if ok then
		DoNotif("Server info sent to main webhook.", 2)
	else
		DoNotif("Main webhook failed: "..tostring(err), 3)
	end
end)
NAgui.addButton("Ping Main Webhook + Server Info", function()
	const note = NAStuff.Integrations.notes.last or ""
	const payload = Format("[Ping] %s | %s", adminName or "NA", NAmanage.ComposeServerNote(note))
	local ok, err = NAmanage.SendIntegrationWebhook("main", payload)
	if ok then
		DoNotif("Main webhook ping sent.", 2)
	else
		DoNotif("Main webhook failed: "..tostring(err), 3)
	end
end)
NAgui.addButton("Send Server IDs To Main Webhook", function()
	const payload = Format("[Server IDs] %s | %s", adminName or "NA", getIntegrationServerIds())
	local ok, err = NAmanage.SendIntegrationWebhook("main", payload)
	if ok then
		DoNotif("Server IDs sent to main webhook.", 2)
	else
		DoNotif("Main webhook failed: "..tostring(err), 3)
	end
end)

NAgui.addSection("Bloxstrap RPC Settings")
NAgui.addToggle("Custom RPC Text", NAStuff.Integrations.rpc.useCustom, function(v)
	NAStuff.Integrations.rpc.useCustom = v and true or false
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationRpcUseCustom", NAStuff.Integrations.rpc.useCustom)
	end
	if NAmanage.btEnabled() then
		NAmanage.btUpdate()
	end
end)
NAgui.addInput("RPC Details Text", "Supports {cmds} {game}", NAStuff.Integrations.rpc.details, function(text)
	NAStuff.Integrations.rpc.details = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationRpcDetails", NAStuff.Integrations.rpc.details)
	end
	if NAmanage.btEnabled() and NAStuff.Integrations.rpc.useCustom then
		NAmanage.btUpdate()
	end
end)
NAgui.addInput("RPC State Text", "Supports {cmds} {game}", NAStuff.Integrations.rpc.state, function(text)
	NAStuff.Integrations.rpc.state = text or ""
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("integrationRpcState", NAStuff.Integrations.rpc.state)
	end
	if NAmanage.btEnabled() and NAStuff.Integrations.rpc.useCustom then
		NAmanage.btUpdate()
	end
end)
NAgui.addButton("Refresh RPC Presence", function()
	NAmanage.btUpdate()
	DoNotif("Bloxstrap RPC refreshed.", 2)
end)

NAgui.addTab(NA_TABS.TAB_INTERFACE, { order = 3, textIcon = "two-makeup-brushes" })
NAgui.setTab(NA_TABS.TAB_INTERFACE)

NAgui.clamp01 = NAgui.clamp01 or function(v, fallback)
	local n = tonumber(v)
	if n == nil then
		return fallback or 0
	end
	if n < 0 then n = 0 elseif n > 1 then n = 1 end
	return n
end

NAStuff.IconDefaultTrans = NAStuff.IconDefaultTrans or {
	background = NAStuff.iconAppearance and NAStuff.iconAppearance.background or 0,
	image = NAStuff.iconAppearance and NAStuff.iconAppearance.image or 0,
	text = NAStuff.iconAppearance and NAStuff.iconAppearance.text or 0,
	stroke = NAStuff.iconAppearance and NAStuff.iconAppearance.stroke or 0.7,
}

NAmanage.destroyCrosshair=function()
	if NAStuff.CrosshairGui then
		pcall(function() NAStuff.CrosshairGui:Destroy() end)
	end
	NAStuff.CrosshairGui = nil
end

NAmanage.applyCrosshair = function()
	if not NAStuff.CrosshairEnabled then
		NAmanage.destroyCrosshair()
		return
	end
	local targetParent = NAStuff.NASCREENGUI
	if not targetParent or not targetParent.Parent then
		targetParent = (type(NAmanage.guiCHECKINGAHHHHH) == "function" and NAmanage.guiCHECKINGAHHHHH()) or nil
	end
	if not targetParent then
		const pg = Services.Players and Services.Players.LocalPlayer and Services.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
		targetParent = pg
	end
	if not targetParent then return end
	if NAStuff.CrosshairGui and NAStuff.CrosshairGui.Parent ~= targetParent then
		NAmanage.destroyCrosshair()
	end
	if not NAStuff.CrosshairGui then
		const gui = InstanceNew("ScreenGui")
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Archivable = false
		local ok = pcall(function()
			gui.Parent = targetParent
		end)
		if not ok then
			const fallbackPg = Services.Players and Services.Players.LocalPlayer and Services.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
			if fallbackPg then
				ok = pcall(function()
					gui.Parent = fallbackPg
				end)
			end
		end
		if not ok then
			gui:Destroy()
			return
		end
		NAStuff.CrosshairGui = gui
	end
	const gui = NAStuff.CrosshairGui
	gui:ClearAllChildren()

	const size = math.clamp(tonumber(NAStuff.CrosshairSize) or 8, 2, 100)
	const thick = math.clamp(tonumber(NAStuff.CrosshairThickness) or 2, 1, 20)
	const color = NAStuff.CrosshairColor or Color3.new(1, 1, 1)
	const gap = math.clamp(math.floor((tonumber(NAStuff.CrosshairGap) or 2) + 0.5), 0, 30)
	const showCenter = NAStuff.CrosshairShowCenter ~= false

	const function line(w, h, pos)
		const f = InstanceNew("Frame")
		f.BackgroundColor3 = color
		f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Size = UDim2.new(0, w, 0, h)
		f.Position = pos
		f.Parent = gui
		return f
	end

	if showCenter then
		line(thick, thick, UDim2.fromScale(0.5, 0.5))
	end

	line(thick, size, UDim2.new(0.5, 0, 0.5, -(gap + size / 2))) -- top
	line(thick, size, UDim2.new(0.5, 0, 0.5,  (gap + size / 2))) -- bottom
	line(size, thick, UDim2.new(0.5, -(gap + size / 2), 0.5, 0)) -- left
	line(size, thick, UDim2.new(0.5,  (gap + size / 2), 0.5, 0)) -- right
end

NAmanage.applyIconShape = function(shape)
	const normalized = NAgui.sanitizeIconShape(shape)
	NAStuff.IconShape = normalized
	if UICorner then
		UICorner.CornerRadius = NAgui.getIconShapeCornerRadius(normalized)
	end
	return normalized
end

NAmanage.applyIconAppearance = function()
	if not TextButton then return end
	const clamp01 = NAgui.clamp01
	const label = IconFallbackText
	const bg = clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.background or 0, 0)
	if NAStuff.iconAppearance then NAStuff.iconAppearance.background = bg end
	TextButton.BackgroundTransparency = bg
	if TextButton:IsA("ImageButton") then
		const imgT = clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.image or 0, 0)
		if NAStuff.iconAppearance then NAStuff.iconAppearance.image = imgT end
		TextButton.ImageTransparency = imgT
	else
		const txtT = clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.text or 0, 0)
		if NAStuff.iconAppearance then NAStuff.iconAppearance.text = txtT end
		TextButton.TextTransparency = txtT
		const strokeT = clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.stroke or 0.7, 0.7)
		if NAStuff.iconAppearance then NAStuff.iconAppearance.stroke = strokeT end
		TextButton.TextStrokeTransparency = strokeT
	end
	if label then
		if NAStuff.iconAppearance and NAStuff.iconAppearance.text ~= nil then
			label.TextTransparency = clamp01(NAStuff.iconAppearance.text, 0)
		end
		if NAStuff.iconAppearance and NAStuff.iconAppearance.stroke ~= nil then
			label.TextStrokeTransparency = clamp01(NAStuff.iconAppearance.stroke, 0.7)
		end
	end
	if NAStuff.IconInvisible == true and NAgui.applyIconVisibility then
		NAgui.applyIconVisibility(true)
	end
end

NAmanage.applyTopbarStyle = function()
	const clamp01 = NAgui.clamp01
	NAmanage.Topbar_ApplyButtonShape(NAStuff.TopbarButtonShape, { save = false })
	const glass = TopBarApp and TopBarApp.tGlass
	if glass then
		glass.BackgroundTransparency = clamp01(NAStuff.TopbarGlassTransparency or 0.12, 0.12)
	end
	const stroke = TopBarApp and TopBarApp.tStroke
	if stroke then
		stroke.Transparency = clamp01(NAStuff.TopbarStrokeTransparency or 0.15, 0.15)
	end
	const panel = TopBarApp and TopBarApp.underlay
	if panel then
		panel.BackgroundTransparency = clamp01(NAStuff.TopbarPanelTransparency or 0.1, 0.1)
	end
	const buttonTransparency = clamp01(NAStuff.TopbarButtonTransparency or 0.18, 0.18)
	const scroll = TopBarApp and TopBarApp.scroll
	if scroll then
		for _, btn in scroll:GetChildren() do
			if btn:IsA("TextButton") then
				const bg = btn:FindFirstChildOfClass("Frame")
				if bg then
					bg.BackgroundTransparency = buttonTransparency
				end
			end
		end
	end
	if TopBarApp and TopBarApp.isOpen ~= nil and NAmanage.Topbar_UpdateToggleVisual then
		NAmanage.Topbar_UpdateToggleVisual(TopBarApp.isOpen, { skipIcon = true })
	end
end

NAmanage.applySideSwipeStyle = function(opts)
	const clamp01 = NAgui.clamp01
	if NAmanage.SideSwipe_Init then
		NAmanage.SideSwipe_Init()
	end
	if SideSwipeApp then
		if SideSwipeApp.underlay then
			const basePanelTransparency = clamp01(NAStuff.SideSwipePanelTransparency or 0.35, 0.35)
			SideSwipeApp.underlay.BackgroundTransparency = SideSwipeApp.isOpen and math.max(0, basePanelTransparency - 0.27) or basePanelTransparency
		end
		if SideSwipeApp.handles then
			const ht = clamp01(NAStuff.SideSwipeHandleTransparency or 0.72, 0.72)
			if SideSwipeApp.handles.left then
				SideSwipeApp.handles.left.BackgroundTransparency = ht
			end
			if SideSwipeApp.handles.right then
				SideSwipeApp.handles.right.BackgroundTransparency = ht
			end
		end
		const scroll = SideSwipeApp.scroll
		if scroll then
			scroll.ScrollBarThickness = math.clamp(math.floor((tonumber(NAStuff.SideSwipeScrollBarThickness) or 4) + 0.5), 0, 12)
		end
		if SideSwipeApp.scroll then
			const buttonTransparency = clamp01(NAStuff.SideSwipeButtonTransparency or 0.16, 0.16)
			for _, btn in SideSwipeApp.scroll:GetChildren() do
				if btn:IsA("TextButton") then
					const bg = btn:FindFirstChildOfClass("Frame")
					if bg then
						bg.BackgroundTransparency = buttonTransparency
					end
				end
			end
		end
		const layout = SideSwipeApp.layout
		if layout and layout.Parent then
			const pad = layout.Parent:FindFirstChildOfClass("UIPadding")
			if pad then
				-- force a layout refresh by toggling padding
				const old = pad.PaddingTop
				pad.PaddingTop = old + UDim.new(0, 0)
				pad.PaddingTop = old
			end
		end
		if SideSwipeApp.scroll and SideSwipeApp.scroll:FindFirstChildWhichIsA("UIListLayout", true) then
			const list = SideSwipeApp.scroll:FindFirstChildWhichIsA("UIListLayout", true)
			if list then
				-- triggers AbsoluteContentSize recompute
				list.Padding = list.Padding
			end
		end
		if opts and opts.rebuild and NAmanage.SideSwipe_Rebuild then
			NAmanage.SideSwipe_Rebuild()
		end
		if NAmanage.SideSwipe_UpdateCanvas then
			NAmanage.SideSwipe_UpdateCanvas()
		end
		if NAmanage.SideSwipe_PositionHandles then
			NAmanage.SideSwipe_PositionHandles()
		end
	end
end


const previousRobloxTopbarEditor = NAmanage.RobloxTopbarEditor
if type(NAmanage.RobloxTopbar_SetEnabled) == "function" and type(previousRobloxTopbarEditor) == "table" and previousRobloxTopbarEditor.enabled == true then
	pcall(NAmanage.RobloxTopbar_SetEnabled, false)
end
NAmanage.RobloxTopbarEditor = {}

do
	const editor = NAmanage.RobloxTopbarEditor
	editor.enabled = false
	editor.applying = false
	editor.applyQueued = false
	editor.geometryQueued = false
	editor.generation = 0
	editor.originals = setmetatable({}, { __mode = "k" })
	editor.activePatches = setmetatable({}, { __mode = "k" })
	editor.dynamicPatches = setmetatable({}, { __mode = "k" })
	editor.owned = {}
	editor.connections = {}
	editor.rootConnections = {}
	editor.visibilityConnections = {}
	editor.cornerHelpers = setmetatable({}, { __mode = "k" })
	editor.strokeHelpers = setmetatable({}, { __mode = "k" })
	editor.scaleHelpers = setmetatable({}, { __mode = "k" })
	editor.groupFrames = {}
	editor.groupSpecs = {}
	editor.root = nil
	editor.app = nil
	editor.targets = nil
	editor.cameraConnection = nil

	local scheduleApply
	local scheduleGeometry
	local updateGeometry

	const function disconnectList(list)
		for i = #list, 1, -1 do
			const connection = list[i]
			list[i] = nil
			if connection then
				pcall(function()
					connection:Disconnect()
				end)
			end
		end
	end

	const function disconnectCamera()
		if editor.cameraConnection then
			pcall(function()
				editor.cameraConnection:Disconnect()
			end)
			editor.cameraConnection = nil
		end
	end

	const function trackOwned(object)
		if object then
			editor.owned[#editor.owned + 1] = object
		end
		return object
	end

	const function clearOwned()
		for i = #editor.owned, 1, -1 do
			const object = editor.owned[i]
			editor.owned[i] = nil
			if object then
				pcall(function()
					object:Destroy()
				end)
			end
		end
		editor.cornerHelpers = setmetatable({}, { __mode = "k" })
		editor.strokeHelpers = setmetatable({}, { __mode = "k" })
		editor.scaleHelpers = setmetatable({}, { __mode = "k" })
		editor.groupFrames = {}
		editor.groupSpecs = {}
	end

	const function safeGet(instance, property)
		if not instance then
			return false, nil
		end
		return pcall(function()
			return instance[property]
		end)
	end

	const function remember(instance, property)
		if not instance then
			return nil
		end
		local properties = editor.originals[instance]
		if not properties then
			properties = {}
			editor.originals[instance] = properties
		end
		local record = properties[property]
		if not record then
			local ok, value = safeGet(instance, property)
			if ok then
				record = { value = value }
				properties[property] = record
			end
		end
		return record and record.value or nil
	end

	const function baseValue(instance, property)
		const properties = instance and editor.originals[instance]
		const record = properties and properties[property]
		if record then
			return record.value
		end
		return remember(instance, property)
	end

	const function writeProperty(instance, property, value)
		if not instance then
			return false
		end
		remember(instance, property)
		local ok, current = safeGet(instance, property)
		if ok and current == value then
			return true
		end
		return pcall(function()
			instance[property] = value
		end)
	end

	const function restoreProperty(instance, property)
		const properties = instance and editor.originals[instance]
		const record = properties and properties[property]
		if not record then
			return
		end
		pcall(function()
			if instance[property] ~= record.value then
				instance[property] = record.value
			end
		end)
	end

	const function restoreAll()
		for instance, properties in editor.originals do
			if instance then
				for property, record in properties do
					pcall(function()
						if instance[property] ~= record.value then
							instance[property] = record.value
						end
					end)
				end
			end
		end
		editor.originals = setmetatable({}, { __mode = "k" })
		editor.activePatches = setmetatable({}, { __mode = "k" })
		editor.dynamicPatches = setmetatable({}, { __mode = "k" })
	end

	const function want(desired, instance, property, value)
		if not instance then
			return
		end
		local properties = desired[instance]
		if not properties then
			properties = {}
			desired[instance] = properties
		end
		properties[property] = value
	end

	const function applyDesired(desired)
		for instance, properties in editor.activePatches do
			const wanted = desired[instance]
			for property in properties do
				if not wanted or wanted[property] == nil then
					restoreProperty(instance, property)
					properties[property] = nil
				end
			end
			if next(properties) == nil then
				editor.activePatches[instance] = nil
			end
		end
		for instance, properties in desired do
			local active = editor.activePatches[instance]
			if not active then
				active = {}
				editor.activePatches[instance] = active
			end
			for property, value in properties do
				writeProperty(instance, property, value)
				active[property] = true
			end
		end
	end

	const function setDynamic(instance, property, value)
		if not instance then
			return
		end
		writeProperty(instance, property, value)
		local properties = editor.dynamicPatches[instance]
		if not properties then
			properties = {}
			editor.dynamicPatches[instance] = properties
		end
		properties[property] = true
	end

	const function restoreDynamic(instance, property)
		const properties = instance and editor.dynamicPatches[instance]
		if not properties or not properties[property] then
			return
		end
		restoreProperty(instance, property)
		properties[property] = nil
		if next(properties) == nil then
			editor.dynamicPatches[instance] = nil
		end
	end

	const function lowerName(instance)
		return instance and tostring(instance.Name):lower() or ""
	end

	const function findTopbarApp()
		if not Services.CoreGui then
			return nil, nil
		end
		const root = Services.CoreGui:FindFirstChild("TopBarApp")
		if not root then
			return nil, nil
		end
		if root:IsA("ScreenGui") and root:FindFirstChild("MenuIconHolder") and root:FindFirstChild("UnibarLeftFrame") then
			return root, root
		end
		const direct = root:FindFirstChild("TopBarApp")
		if direct and direct:IsA("ScreenGui") and direct:FindFirstChild("MenuIconHolder") and direct:FindFirstChild("UnibarLeftFrame") then
			return root, direct
		end
		for _, descendant in root:GetDescendants() do
			if descendant:IsA("ScreenGui") and descendant:FindFirstChild("MenuIconHolder") and descendant:FindFirstChild("UnibarLeftFrame") then
				return root, descendant
			end
		end
		return root, nil
	end

	const function classifyButton(instance)
		const tokens = { lowerName(instance) }
		local scanned = 0
		for _, descendant in instance:GetDescendants() do
			tokens[#tokens + 1] = lowerName(descendant)
			scanned += 1
			if scanned >= 64 then
				break
			end
		end
		const joined = table.concat(tokens, " ")
		if joined:find("nine_dot", 1, true) or joined:find("nine dot", 1, true) or joined:find("overflow", 1, true) or joined:find("more", 1, true) then
			return "more"
		end
		if joined:find("voice", 1, true) or joined:find("microphone", 1, true) or joined:find("mic", 1, true) or joined:find("audio", 1, true) then
			return "voice"
		end
		if joined:find("chat", 1, true) then
			return "chat"
		end
		return "other"
	end

	const function isButtonFrame(instance)
		if not instance or not instance:IsA("GuiObject") or instance.Name:sub(1, 3) == "NA_" then
			return false
		end
		if instance:FindFirstChild("IntegrationIconFrame", true) then
			return true
		end
		if instance:FindFirstChildWhichIsA("GuiButton", true) then
			return true
		end
		const role = classifyButton(instance)
		return role ~= "other"
	end

	const function resolveTargets(app)
		const menuHolder = app and app:FindFirstChild("MenuIconHolder", true) or nil
		const triggerPoint = menuHolder and menuHolder:FindFirstChild("TriggerPoint", true) or nil
		const menuHit = triggerPoint and (triggerPoint:FindFirstChild("IconHitArea", true) or triggerPoint:FindFirstChildWhichIsA("GuiButton", true)) or nil
		const menuIcon = menuHit and (menuHit:FindFirstChild("ScalingIcon", true) or menuHit:FindFirstChildWhichIsA("TextLabel", true) or menuHit:FindFirstChildWhichIsA("ImageLabel", true)) or nil
		const unibar = app and app:FindFirstChild("UnibarLeftFrame", true) or nil
		const unibarMenu = unibar and unibar:FindFirstChild("UnibarMenu", true) or nil
		local holder = unibarMenu and unibarMenu:FindFirstChild("2") or nil
		local buttonContainer = holder and holder:FindFirstChild("3") or nil
		if not buttonContainer and unibarMenu then
			for _, descendant in unibarMenu:GetDescendants() do
				if descendant:IsA("GuiObject") then
					local found = 0
					for _, child in descendant:GetChildren() do
						if isButtonFrame(child) then
							found += 1
						end
					end
					if found > 0 then
						buttonContainer = descendant
						holder = descendant.Parent
						break
					end
				end
			end
		end
		local background = nil
		if holder then
			const named = holder:FindFirstChild("2")
			if named and named ~= buttonContainer and named:IsA("GuiObject") then
				background = named
			end
			if not background then
				for _, child in holder:GetChildren() do
					if child ~= buttonContainer and child:IsA("GuiObject") and child:FindFirstChildOfClass("UICorner") then
						background = child
						break
					end
				end
			end
		end
		const buttons = {}
		if buttonContainer then
			for _, child in buttonContainer:GetChildren() do
				if isButtonFrame(child) then
					buttons[#buttons + 1] = child
				end
			end
		end
		const subMenuHost = unibarMenu and unibarMenu:FindFirstChild("SubMenuHost", true) or nil
		return {
			menuHolder = menuHolder;
			triggerPoint = triggerPoint;
			menuHit = menuHit;
			menuIcon = menuIcon;
			unibar = unibar;
			unibarMenu = unibarMenu;
			holder = holder;
			background = background;
			buttonContainer = buttonContainer;
			buttons = buttons;
			subMenuHost = subMenuHost;
		}
	end

	const function sortButtons(buttons)
		table.sort(buttons, function(a, b)
			const aPosition = baseValue(a, "Position") or a.Position
			const bPosition = baseValue(b, "Position") or b.Position
			if aPosition.X.Scale ~= bPosition.X.Scale then
				return aPosition.X.Scale < bPosition.X.Scale
			end
			if aPosition.X.Offset ~= bPosition.X.Offset then
				return aPosition.X.Offset < bPosition.X.Offset
			end
			const aOrder = baseValue(a, "LayoutOrder") or a.LayoutOrder
			const bOrder = baseValue(b, "LayoutOrder") or b.LayoutOrder
			if aOrder ~= bOrder then
				return aOrder < bOrder
			end
			return tostring(a.Name) < tostring(b.Name)
		end)
	end

	const function orderButtons(buttons, morePosition)
		local ordered = {}
		for _, button in buttons do
			ordered[#ordered + 1] = button
		end
		sortButtons(ordered)
		local moreButton = nil
		for _, button in ordered do
			if classifyButton(button) == "more" then
				moreButton = button
				break
			end
		end
		if moreButton and morePosition ~= "Original" then
			const filtered = {}
			for _, button in ordered do
				if button ~= moreButton then
					filtered[#filtered + 1] = button
				end
			end
			if morePosition == "Left" then
				table.insert(filtered, 1, moreButton)
			else
				filtered[#filtered + 1] = moreButton
			end
			ordered = filtered
		end
		return ordered, moreButton
	end

	const function layoutButtons(buttons, morePosition, layout)
		local ordered, moreButton = orderButtons(buttons, morePosition)
		if layout ~= "Menu + Chat + Voice" then
			return ordered, moreButton
		end
		const joined = {}
		const separated = {}
		for _, button in ordered do
			const role = classifyButton(button)
			if role == "chat" or role == "voice" then
				joined[#joined + 1] = button
			else
				separated[#separated + 1] = button
			end
		end
		if #joined == 0 then
			return ordered, moreButton
		end
		for _, button in separated do
			joined[#joined + 1] = button
		end
		return joined, moreButton
	end

	const function getOwnedHelper(map, target, className, name)
		local helper = map[target]
		if helper and helper.Parent == target then
			return helper
		end
		helper = target and target:FindFirstChild(name) or nil
		if helper and not helper:IsA(className) then
			helper = nil
		end
		if not helper and target then
			helper = InstanceNew(className)
			helper.Name = name
			helper.Parent = target
			trackOwned(helper)
		end
		map[target] = helper
		return helper
	end

	const function styleObject(desired, object, color, transparency, radius, strokeUsed)
		if not object then
			return
		end
		want(desired, object, "BackgroundColor3", color)
		want(desired, object, "BackgroundTransparency", transparency)
		local corner = object:FindFirstChildOfClass("UICorner")
		if corner and corner.Name ~= "NA_TopBarAppCorner" then
			want(desired, corner, "CornerRadius", UDim.new(0, radius))
		else
			corner = getOwnedHelper(editor.cornerHelpers, object, "UICorner", "NA_TopBarAppCorner")
			if corner then
				corner.CornerRadius = UDim.new(0, 6)
			end
		end
		const stroke = getOwnedHelper(editor.strokeHelpers, object, "UIStroke", "NA_TopBarAppStroke")
		if stroke then
			strokeUsed[stroke] = true
			stroke.Enabled = NAStuff.RobloxTopbarStrokeEnabled == true
			stroke.Color = NAStuff.RobloxTopbarStrokeColor or Color3.new(1, 1, 1)
			stroke.Transparency = math.clamp(tonumber(NAStuff.RobloxTopbarStrokeTransparency) or 0.5, 0, 1)
			stroke.Thickness = math.clamp(tonumber(NAStuff.RobloxTopbarStrokeThickness) or 1, 0, 4)
			pcall(function()
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			end)
		end
	end

	const function ensureLayout(targets, desired, ordered, buttonSize, gap, menuGap, layout)
		if not targets.buttonContainer then
			return
		end
		const sidePadding = 4
		local startX = sidePadding
		if (layout == "All Unified" or layout == "Menu + Chat + Voice") and targets.menuHit then
			startX = math.floor(targets.menuHit.AbsolutePosition.X + buttonSize + menuGap - targets.buttonContainer.AbsolutePosition.X + 0.5)
		end
		local visibleCount = 0
		for _, button in ordered do
			want(desired, button, "Size", UDim2.fromOffset(buttonSize, buttonSize))
			if button.Visible then
				const x = startX + visibleCount * (buttonSize + gap)
				want(desired, button, "Position", UDim2.fromOffset(x, 0))
				visibleCount += 1
			end
		end
		visibleCount = math.max(1, visibleCount)
		const width = sidePadding * 2 + visibleCount * buttonSize + math.max(0, visibleCount - 1) * gap
		if targets.holder then
			want(desired, targets.holder, "Size", UDim2.fromOffset(width, buttonSize))
		end
		if targets.background then
			want(desired, targets.background, "Position", UDim2.fromOffset(0, 0))
			want(desired, targets.background, "Size", UDim2.fromScale(1, 1))
		end
		want(desired, targets.buttonContainer, "Position", UDim2.fromOffset(0, 0))
		want(desired, targets.buttonContainer, "Size", UDim2.fromScale(1, 1))
		if targets.unibarMenu then
			want(desired, targets.unibarMenu, "Size", UDim2.fromOffset(width, buttonSize))
		end
	end

	const function applyOuterSizing(targets, desired, buttonSize, verticalOffset, horizontalInset)
		const outerHeight = buttonSize + 4
		if targets.menuHolder then
			const originalPosition = baseValue(targets.menuHolder, "Position") or targets.menuHolder.Position
			const originalSize = baseValue(targets.menuHolder, "Size") or targets.menuHolder.Size
			const sign = targets.menuHolder.AnchorPoint.X >= 0.5 and -1 or 1
			want(desired, targets.menuHolder, "Position", UDim2.new(originalPosition.X.Scale, horizontalInset * sign, originalPosition.Y.Scale, verticalOffset))
			want(desired, targets.menuHolder, "Size", UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, outerHeight))
		end
		if targets.unibar then
			const originalPosition = baseValue(targets.unibar, "Position") or targets.unibar.Position
			const originalSize = baseValue(targets.unibar, "Size") or targets.unibar.Size
			const sign = targets.unibar.AnchorPoint.X >= 0.5 and -1 or 1
			want(desired, targets.unibar, "Position", UDim2.new(originalPosition.X.Scale, horizontalInset * sign, originalPosition.Y.Scale, verticalOffset))
			want(desired, targets.unibar, "Size", UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, outerHeight))
		end
		if targets.triggerPoint then
			want(desired, targets.triggerPoint, "Size", UDim2.new(0, buttonSize, 1, 0))
		end
		if targets.menuHit then
			want(desired, targets.menuHit, "Size", UDim2.fromOffset(buttonSize, buttonSize))
		end
	end

	const function iconNodes(targets)
		const nodes = {}
		const seen = setmetatable({}, { __mode = "k" })
		const function add(node)
			if node and node:IsA("GuiObject") and not seen[node] then
				seen[node] = true
				nodes[#nodes + 1] = node
			end
		end
		add(targets.menuIcon)
		for _, button in targets.buttons do
			const iconFrame = button:FindFirstChild("IntegrationIconFrame", true)
			if iconFrame then
				for _, descendant in iconFrame:GetDescendants() do
					if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
						add(descendant)
					end
				end
			end
		end
		return nodes
	end

	const function styleIcons(targets, desired)
		const color = NAStuff.RobloxTopbarIconColor or Color3.new(1, 1, 1)
		const transparency = math.clamp(tonumber(NAStuff.RobloxTopbarIconTransparency) or 0, 0, 1)
		const scale = math.clamp(tonumber(NAStuff.RobloxTopbarIconScale) or 1, 0.6, 1.4)
		const keepGradient = NAStuff.RobloxTopbarKeepIconGradient ~= false
		for _, node in iconNodes(targets) do
			if node:IsA("TextLabel") or node:IsA("TextButton") then
				want(desired, node, "TextColor3", color)
				want(desired, node, "TextTransparency", transparency)
			else
				want(desired, node, "ImageColor3", color)
				want(desired, node, "ImageTransparency", transparency)
			end
			if not keepGradient then
				for _, gradient in node:GetDescendants() do
					if gradient:IsA("UIGradient") then
						want(desired, gradient, "Enabled", false)
					end
				end
			end
			const uiScale = getOwnedHelper(editor.scaleHelpers, node, "UIScale", "NA_TopBarAppIconScale")
			if uiScale then
				uiScale.Scale = scale
			end
		end
	end

	const function getGroupFrame(index, app)
		local frame = editor.groupFrames[index]
		if frame and frame.Parent == app then
			return frame
		end
		frame = InstanceNew("Frame")
		frame.Name = "NA_TopBarAppGroup" .. tostring(index)
		frame.Active = false
		frame.Selectable = false
		frame.BorderSizePixel = 0
		frame.BackgroundTransparency = 1
		frame.Visible = false
		frame.ZIndex = 0
		pcall(function()
			frame.Interactable = false
		end)
		frame.Parent = app
		trackOwned(frame)
		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Name = "NA_TopBarAppCorner"
		corner.Parent = frame
		trackOwned(corner)
		const stroke = InstanceNew("UIStroke")
		stroke.Name = "NA_TopBarAppStroke"
		pcall(function()
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		end)
		stroke.Parent = frame
		trackOwned(stroke)
		editor.groupFrames[index] = frame
		return frame
	end

	const function configureGroup(frame, color, transparency, radius)
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = transparency
		const corner = frame:FindFirstChildOfClass("UICorner")
		if corner then
			corner.CornerRadius = UDim.new(0, 6)
		end
		const stroke = frame:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Enabled = NAStuff.RobloxTopbarStrokeEnabled == true
			stroke.Color = NAStuff.RobloxTopbarStrokeColor or Color3.new(1, 1, 1)
			stroke.Transparency = math.clamp(tonumber(NAStuff.RobloxTopbarStrokeTransparency) or 0.5, 0, 1)
			stroke.Thickness = math.clamp(tonumber(NAStuff.RobloxTopbarStrokeThickness) or 1, 0, 4)
		end
	end

	const function addGroup(app, members, padding, color, transparency, radius)
		if not app or #members == 0 then
			return
		end
		const index = #editor.groupSpecs + 1
		const frame = getGroupFrame(index, app)
		configureGroup(frame, color, transparency, radius)
		frame.Visible = false
		editor.groupSpecs[index] = {
			frame = frame;
			members = members;
			padding = padding;
		}
	end

	const function styleLayout(targets, desired, app, ordered, moreButton)
		const color = NAStuff.RobloxTopbarBackgroundColor or Color3.fromRGB(18, 18, 21)
		const transparency = math.clamp(tonumber(NAStuff.RobloxTopbarBackgroundTransparency) or 0.08, 0, 1)
		const radius = math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarCornerRadius) or 22) + 0.5), 0, 32)
		const padding = math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarGroupPadding) or 0) + 0.5), 0, 12)
		const layout = NAStuff.RobloxTopbarLayout or "Controls Unified"
		const strokeUsed = setmetatable({}, { __mode = "k" })
		for _, stroke in editor.strokeHelpers do
			if stroke then
				stroke.Enabled = false
			end
		end
		for _, frame in editor.groupFrames do
			if frame then
				frame.Visible = false
			end
		end
		editor.groupSpecs = {}
		if targets.background then
			want(desired, targets.background, "BackgroundTransparency", 1)
		end
		if targets.menuHit then
			want(desired, targets.menuHit, "BackgroundTransparency", 1)
		end
		for _, button in targets.buttons do
			want(desired, button, "BackgroundTransparency", 1)
		end
		if layout == "All Separate" then
			styleObject(desired, targets.menuHit, color, transparency, radius, strokeUsed)
			for _, button in ordered do
				styleObject(desired, button, color, transparency, radius, strokeUsed)
			end
		elseif layout == "Menu + Chat + Voice" then
			const joined = {}
			const separated = {}
			for _, button in ordered do
				const role = classifyButton(button)
				if role == "chat" or role == "voice" then
					joined[#joined + 1] = button
				else
					separated[#separated + 1] = button
				end
			end
			if #joined == 0 then
				for _, button in ordered do
					if button ~= moreButton then
						joined[#joined + 1] = button
					end
				end
			end
			for _, button in separated do
				styleObject(desired, button, color, transparency, radius, strokeUsed)
			end
			const members = {}
			if targets.menuHit then
				members[#members + 1] = targets.menuHit
			end
			for _, button in joined do
				members[#members + 1] = button
			end
			addGroup(app, members, padding, color, transparency, radius)
		elseif layout == "All Unified" then
			const members = {}
			if targets.menuHit then
				members[#members + 1] = targets.menuHit
			end
			for _, button in ordered do
				members[#members + 1] = button
			end
			addGroup(app, members, padding, color, transparency, radius)
		else
			styleObject(desired, targets.menuHit, color, transparency, radius, strokeUsed)
			if targets.background then
				styleObject(desired, targets.background, color, transparency, radius, strokeUsed)
			else
				addGroup(app, ordered, padding, color, transparency, radius)
			end
		end
	end

	const function visibleMembersRect(members)
		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge
		local minZ = math.huge
		for _, member in members do
			if member and member.Parent and member:IsA("GuiObject") and member.Visible and member.AbsoluteSize.X > 0 and member.AbsoluteSize.Y > 0 then
				const position = member.AbsolutePosition
				const size = member.AbsoluteSize
				minX = math.min(minX, position.X)
				minY = math.min(minY, position.Y)
				maxX = math.max(maxX, position.X + size.X)
				maxY = math.max(maxY, position.Y + size.Y)
				minZ = math.min(minZ, member.ZIndex)
			end
		end
		if minX == math.huge then
			return nil
		end
		return minX, minY, maxX, maxY, minZ
	end

	const function updateMoreSubMenu(targets, moreButton)
		if not targets.subMenuHost or not moreButton or (NAStuff.RobloxTopbarMorePosition or "Original") == "Original" then
			restoreDynamic(targets.subMenuHost, "Position")
			return
		end
		const originalMore = baseValue(moreButton, "Position") or moreButton.Position
		const originalSubMenu = baseValue(targets.subMenuHost, "Position") or targets.subMenuHost.Position
		const currentMore = moreButton.Position
		setDynamic(targets.subMenuHost, "Position", UDim2.new(
			originalSubMenu.X.Scale + currentMore.X.Scale - originalMore.X.Scale,
			originalSubMenu.X.Offset + currentMore.X.Offset - originalMore.X.Offset,
			originalSubMenu.Y.Scale + currentMore.Y.Scale - originalMore.Y.Scale,
			originalSubMenu.Y.Offset + currentMore.Y.Offset - originalMore.Y.Offset
		))
	end

	updateGeometry = function()
		if not editor.enabled or editor.applying then
			return
		end
		const targets = editor.targets
		if not targets then
			return
		end
		const layout = NAStuff.RobloxTopbarLayout or "Controls Unified"
		local _, moreButton = layoutButtons(targets.buttons, NAStuff.RobloxTopbarMorePosition or "Original", layout)
		updateMoreSubMenu(targets, moreButton)
		restoreDynamic(targets.triggerPoint, "Position")
		for _, spec in editor.groupSpecs do
			const frame = spec.frame
			local minX, minY, maxX, maxY, minZ = visibleMembersRect(spec.members)
			if frame and minX then
				const padding = math.max(0, tonumber(spec.padding) or 0)
				const rootOrigin = frame.AbsolutePosition - Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
				frame.Visible = true
				frame.Position = UDim2.fromOffset(math.floor(minX - padding - rootOrigin.X + 0.5), math.floor(minY - padding - rootOrigin.Y + 0.5))
				frame.Size = UDim2.fromOffset(math.max(1, math.floor(maxX - minX + padding * 2 + 0.5)), math.max(1, math.floor(maxY - minY + padding * 2 + 0.5)))
				frame.ZIndex = minZ == math.huge and 0 or math.max(0, minZ - 1)
			elseif frame then
				frame.Visible = false
			end
		end
	end

	scheduleGeometry = function()
		if not editor.enabled or editor.geometryQueued then
			return
		end
		editor.geometryQueued = true
		const generation = editor.generation
		Delay(0.03, function()
			editor.geometryQueued = false
			if editor.enabled and generation == editor.generation then
				updateGeometry()
			end
		end)
	end

	const function relevantStructure(instance)
		if not instance or instance.Name:sub(1, 3) == "NA_" then
			return false
		end
		const name = lowerName(instance)
		return name == "topbarapp" or name == "menuiconholder" or name == "triggerpoint" or name == "iconhitarea" or name == "unibarleftframe" or name == "unibarmenu" or name == "submenuhost" or name == "integrationiconframe" or name == "nine_dot" or name == "chat" or name == "voice" or name:find("microphone", 1, true) ~= nil or name:find("voice", 1, true) ~= nil or name:find("mic", 1, true) ~= nil
	end

	const function bindVisibility(targets)
		disconnectList(editor.visibilityConnections)
		const function bind(object)
			if not object or not object:IsA("GuiObject") then
				return
			end
			editor.visibilityConnections[#editor.visibilityConnections + 1] = object:GetPropertyChangedSignal("Visible"):Connect(function()
				if editor.enabled and not editor.applying then
					scheduleApply()
				end
			end)
		end
		bind(targets.menuHit)
		for _, button in targets.buttons do
			bind(button)
		end
	end

	const function bindRoot(root, app)
		if editor.root == root and editor.app == app and #editor.rootConnections > 0 then
			return
		end
		disconnectList(editor.rootConnections)
		disconnectList(editor.visibilityConnections)
		clearOwned()
		restoreAll()
		editor.root = root
		editor.app = app
		editor.targets = nil
		if root then
			editor.rootConnections[#editor.rootConnections + 1] = root.AncestryChanged:Connect(function(_, parent)
				if editor.enabled and not parent then
					scheduleApply()
				end
			end)
			editor.rootConnections[#editor.rootConnections + 1] = root.DescendantAdded:Connect(function(descendant)
				if editor.enabled and not editor.applying and relevantStructure(descendant) then
					scheduleApply()
				end
			end)
			editor.rootConnections[#editor.rootConnections + 1] = root.DescendantRemoving:Connect(function(descendant)
				if editor.enabled and not editor.applying and relevantStructure(descendant) then
					scheduleApply()
				end
			end)
		end
	end

	const function bindCamera()
		disconnectCamera()
		const camera = Services.Workspace.CurrentCamera
		if camera then
			editor.cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				if editor.enabled and not editor.applying then
					scheduleGeometry()
				end
			end)
		end
	end

	const function applyEditor()
		if not editor.enabled or editor.applying then
			return false
		end
		editor.applying = true
		editor.generation += 1
		const generation = editor.generation
		local ok, applied = pcall(function()
			local root, app = findTopbarApp()
			bindRoot(root, app)
			if not app then
				return false
			end
			const targets = resolveTargets(app)
			if not targets.menuHit or not targets.buttonContainer then
				editor.targets = targets
				return false
			end
			editor.targets = targets
			bindVisibility(targets)
			restoreDynamic(targets.triggerPoint, "Position")
			restoreDynamic(targets.subMenuHost, "Position")
			const desired = setmetatable({}, { __mode = "k" })
			const buttonSize = math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarButtonSize) or 44) + 0.5), 32, 56)
			const gap = math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarSeparateGap) or 4) + 0.5), 0, 16)
			const menuGap = math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarMenuGap) or 4) + 0.5), 0, 24)
			const verticalOffset = math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarVerticalOffset) or 10) + 0.5), 0, 32)
			const horizontalInset = math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarHorizontalInset) or 16) + 0.5), 0, 48)
			const layout = NAStuff.RobloxTopbarLayout or "Controls Unified"
			local ordered, moreButton = layoutButtons(targets.buttons, NAStuff.RobloxTopbarMorePosition or "Original", layout)
			applyOuterSizing(targets, desired, buttonSize, verticalOffset, horizontalInset)
			ensureLayout(targets, desired, ordered, buttonSize, gap, menuGap, layout)
			styleIcons(targets, desired)
			styleLayout(targets, desired, app, ordered, moreButton)
			applyDesired(desired)
			Defer(function()
				if editor.enabled and generation == editor.generation then
					updateGeometry()
				end
			end)
			Delay(0.08, function()
				if editor.enabled and generation == editor.generation then
					updateGeometry()
				end
			end)
			return true
		end)
		editor.applying = false
		return ok and applied == true
	end

	scheduleApply = function()
		if not editor.enabled or editor.applyQueued then
			return
		end
		editor.applyQueued = true
		Delay(0.05, function()
			editor.applyQueued = false
			if editor.enabled then
				applyEditor()
			end
		end)
	end

	NAmanage.RobloxTopbar_Apply = applyEditor
	NAmanage.RobloxTopbar_ScheduleApply = scheduleApply
	NAmanage.RobloxTopbar_Refresh = function()
		if not editor.enabled then
			return false
		end
		editor.generation += 1
		disconnectList(editor.rootConnections)
		disconnectList(editor.visibilityConnections)
		clearOwned()
		restoreAll()
		editor.root = nil
		editor.app = nil
		editor.targets = nil
		return applyEditor()
	end
	NAmanage.RobloxTopbar_SetEnabled = function(enabled)
		const nextEnabled = enabled == true
		NAStuff.RobloxTopbarEditorEnabled = nextEnabled
		if editor.enabled == nextEnabled then
			if nextEnabled then
				scheduleApply()
			end
			return editor.enabled
		end
		editor.enabled = nextEnabled
		editor.generation += 1
		if editor.enabled then
			if Services.CoreGui then
				editor.connections[#editor.connections + 1] = Services.CoreGui.ChildAdded:Connect(function(child)
					if editor.enabled and child.Name == "TopBarApp" then
						scheduleApply()
					end
				end)
				editor.connections[#editor.connections + 1] = Services.CoreGui.ChildRemoved:Connect(function(child)
					if editor.enabled and child.Name == "TopBarApp" then
						scheduleApply()
					end
				end)
			end
			editor.connections[#editor.connections + 1] = Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				if editor.enabled then
					bindCamera()
					scheduleApply()
				end
			end)
			if Services.GuiService then
				local okConnection, connection = pcall(function()
					return Services.GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
						if editor.enabled and not editor.applying then
							scheduleGeometry()
						end
					end)
				end)
				if okConnection and connection then
					editor.connections[#editor.connections + 1] = connection
				end
			end
			bindCamera()
			scheduleApply()
		else
			editor.applyQueued = false
			editor.geometryQueued = false
			disconnectCamera()
			disconnectList(editor.visibilityConnections)
			disconnectList(editor.rootConnections)
			disconnectList(editor.connections)
			clearOwned()
			restoreAll()
			editor.root = nil
			editor.app = nil
			editor.targets = nil
		end
		return editor.enabled
	end
end
NAmanage.applyIconAppearance()
NAmanage.applyTopbarStyle()
NAmanage.applySideSwipeStyle({ rebuild = false })

NAmanage.WindowAppearance = NAmanage.WindowAppearance or {}
NAStuff.WindowAppearance = NAStuff.WindowAppearance or {}

if NAStuff.WindowAppearance.initialized ~= true then
	NAStuff.WindowAppearance.enabled = NAmanage.NASettingsGet("windowBackgroundEnabled") == true
	NAStuff.WindowAppearance.source = tostring(NAmanage.NASettingsGet("windowBackgroundSource") or "")
	NAStuff.WindowAppearance.localPath = tostring(NAmanage.NASettingsGet("windowBackgroundLocalPath") or "")
	NAStuff.WindowAppearance.scaleMode = tostring(NAmanage.NASettingsGet("windowBackgroundScaleMode") or "Crop")
	NAStuff.WindowAppearance.imageTransparency = tonumber(NAmanage.NASettingsGet("windowBackgroundTransparency")) or 0.3
	NAStuff.WindowAppearance.topbarTransparency = tonumber(NAmanage.NASettingsGet("windowBackgroundTopbarTransparency")) or 0.3
	NAStuff.WindowAppearance.containerTransparency = tonumber(NAmanage.NASettingsGet("windowBackgroundContainerTransparency")) or 0.42
	NAStuff.WindowAppearance.elementTransparency = tonumber(NAmanage.NASettingsGet("windowBackgroundElementTransparency")) or 0
	NAStuff.WindowAppearance.pendingInput = NAStuff.WindowAppearance.source
	NAStuff.WindowAppearance.entries = {}
	NAStuff.WindowAppearance.index = 0
	NAStuff.WindowAppearance.initialized = true
end

NAmanage.WindowAppearance.targetKeys = NAmanage.WindowAppearance.targetKeys or {
	"SettingsFrame";
	"commandsFrame";
	"chatLogsFrame";
	"NAchatFrame";
	"NAconsoleFrame";
	"CommandKeybindsFrame";
	"WaypointFrame";
	"BindersFrame";
	"ExecutorFrame";
	"NotepadFrame";
	"PluginsFrame";
	"MusicFrame";
	"ScriptHubFrame";
	"SubplaceViewerFrame";
	"ServerListFrame";
}
if not table.find(NAmanage.WindowAppearance.targetKeys, "ServerListFrame") then
	NAmanage.WindowAppearance.targetKeys[#NAmanage.WindowAppearance.targetKeys + 1] = "ServerListFrame"
end
if not table.find(NAmanage.WindowAppearance.targetKeys, "NAchatFrame") then
	NAmanage.WindowAppearance.targetKeys[#NAmanage.WindowAppearance.targetKeys + 1] = "NAchatFrame"
end

NAmanage.WindowAppearance.manifestPath = NAfiles.NAWINDOWBACKGROUNDPATH.."/SavedBackgrounds.json"

NAmanage.WindowAppearance.getTargets = function()
	const result = {}
	for _, key in NAmanage.WindowAppearance.targetKeys do
		const frame = NAUIMANAGER and NAUIMANAGER[key]
		if typeof(frame) == "Instance" and frame:IsA("GuiObject") then
			result[#result + 1] = frame
		end
	end
	return result
end

NAmanage.WindowAppearance.scaleType = function(mode)
	mode = tostring(mode or "Crop")
	if mode == "Fit" then
		return Enum.ScaleType.Fit
	elseif mode == "Stretch" then
		return Enum.ScaleType.Stretch
	elseif mode == "Tile" then
		return Enum.ScaleType.Tile
	end
	return Enum.ScaleType.Crop
end

NAmanage.WindowAppearance.ensureFolder = function()
	if not (FileSupport and type(writefile) == "function") then
		return false, "Saved window backgrounds require file support."
	end
	return NAmanage.safeMakeFolder(NAfiles.NAWINDOWBACKGROUNDPATH)
end

NAmanage.WindowAppearance.normalizeUrl = function(value)
	if type(NAgui.iconNormUrl) == "function" then
		const normalized = NAgui.iconNormUrl(value)
		if typeof(normalized) == "string" and normalized ~= "" then
			return normalized
		end
	end
	if typeof(value) ~= "string" then
		return nil
	end
	value = value:match("^%s*(.-)%s*$") or ""
	if value:match("^https?://") then
		return value:gsub(" ", "%%20")
	end
	return nil
end

NAmanage.WindowAppearance.fileNameFromUrl = function(url)
	local name = tostring(url or ""):match("/([^/%?]+)%??[^/]*$") or "window_background.png"
	name = name:gsub("%%[%x][%x]", "_"):gsub("[^%w%._%-]", "_")
	if #name > 96 then
		name = name:sub(#name - 95)
	end
	const extension = name:lower():match("%.([%w]+)$")
	if extension ~= "png" and extension ~= "jpg" and extension ~= "jpeg" and extension ~= "webp" and extension ~= "bmp" then
		name ..= ".png"
	end
	return name
end

NAmanage.WindowAppearance.isImageFile = function(name)
	const ext = tostring(name or ""):lower():match("%.([%w]+)$")
	return ext == "png" or ext == "jpg" or ext == "jpeg" or ext == "webp" or ext == "bmp"
end

NAmanage.WindowAppearance.isManagedPath = function(path)
	if type(path) ~= "string" or path == "" then
		return false
	end
	const normalized = path:gsub("\\", "/")
	const root = tostring(NAfiles.NAWINDOWBACKGROUNDPATH):gsub("\\", "/")
	return normalized == root or normalized:sub(1, #root + 1) == root.."/"
end

NAmanage.WindowAppearance.entryKey = function(entry)
	if type(entry) ~= "table" then
		return ""
	end
	const localPath = tostring(entry.localPath or "")
	if localPath ~= "" then
		return "file:"..localPath:gsub("\\", "/")
	end
	return "source:"..tostring(entry.source or "")
end

NAmanage.WindowAppearance.resolveInput = function(inputValue)
	local raw = typeof(inputValue) == "string" and inputValue or tostring(inputValue or "")
	raw = raw:match("^%s*(.-)%s*$") or ""
	if raw == "" then
		return false, "Enter a Roblox asset id, image URL, or local image path."
	end

	const directDigits = raw:match("^rbxassetid://(%d+)$") or raw:match("^%s*(%d+)%s*$")
	const isRobloxUrl = raw:match("^https?://[^/]*roblox%.com/") ~= nil
	const robloxDigits = isRobloxUrl and (raw:match("[?&]id=(%d+)") or raw:match("^https?://[^/]*roblox%.com/.-/(%d+)")) or nil
	const digits = directDigits or robloxDigits
	if digits then
		return true, {
			source = "rbxassetid://"..digits;
			asset = "rbxassetid://"..digits;
			localPath = "";
			name = "Roblox "..digits;
		}
	end

	if FileSupport and type(getcustomasset) == "function" and NAmanage.safeIsFile(raw) then
		local okAsset, asset = pcall(getcustomasset, raw)
		if okAsset and typeof(asset) == "string" and asset ~= "" then
			return true, {
				source = raw;
				asset = asset;
				localPath = raw;
				name = (type(getFName) == "function" and getFName(raw)) or raw:match("([^/\\]+)$") or "Local Background";
			}
		end
		return false, "Unable to load that local image with getcustomasset."
	end

	const url = NAmanage.WindowAppearance.normalizeUrl(raw)
	if not url then
		return false, "Enter a valid Roblox asset id, HTTP(S) image URL, or local image path."
	end
	if type(getcustomasset) ~= "function" then
		return false, "URL backgrounds require getcustomasset support."
	end
	local okFolder, folderErr = NAmanage.WindowAppearance.ensureFolder()
	if not okFolder then
		return false, folderErr or "Unable to prepare the window background folder."
	end
	local okGet, data = NAmanage.HttpGet(url, { timeout = 10 })
	if not (okGet and typeof(data) == "string" and data ~= "") then
		return false, "Unable to download the window background image."
	end
	const fileName = NAmanage.WindowAppearance.fileNameFromUrl(url)
	const path = NAfiles.NAWINDOWBACKGROUNDPATH.."/"..fileName
	local okWrite, writeErr = NAmanage.safeWriteFile(path, data)
	if not okWrite then
		return false, writeErr or "Unable to save the window background image."
	end
	local okAsset, asset = pcall(getcustomasset, path)
	if not (okAsset and typeof(asset) == "string" and asset ~= "") then
		return false, "The image downloaded, but getcustomasset could not load it."
	end
	return true, {
		source = url;
		asset = asset;
		localPath = path;
		name = fileName;
	}
end

NAmanage.WindowAppearance.ensureLayer = function(frame)
	local image = frame:FindFirstChild("NAWindowBackground")
	if not (image and image:IsA("ImageLabel")) then
		if image then
			image:Destroy()
		end
		image = Instance.new("ImageLabel")
		image.Name = "NAWindowBackground"
		image.Parent = frame
		image.BackgroundTransparency = 1
		image.BorderSizePixel = 0
		image.Position = UDim2.fromScale(0, 0)
		image.Size = UDim2.fromScale(1, 1)
		image.ZIndex = 0
		image.Active = false
		image.Selectable = false
		image:SetAttribute("NAWindowBackgroundLayer", true)
		const corner = Instance.new("UICorner", image)
		const shellCorner = frame:FindFirstChildWhichIsA("UICorner")
		corner.CornerRadius = shellCorner and shellCorner.CornerRadius or UDim.new(0, 6)
	end
	image.ImageColor3 = Color3.fromRGB(255, 255, 255)
	const obsoleteOverlay = image:FindFirstChild("NALightnessOverlay")
	if obsoleteOverlay then
		obsoleteOverlay:Destroy()
	end
	return image
end

NAmanage.WindowAppearance.captureTransparency = function(item)
	if not (item and item:IsA("GuiObject")) then
		return
	end
	if item:GetAttribute("NAOriginalBackgroundTransparency") == nil then
		item:SetAttribute("NAOriginalBackgroundTransparency", item.BackgroundTransparency)
	end
end

NAmanage.WindowAppearance.restoreTransparency = function(item)
	if not (item and item:IsA("GuiObject")) then
		return
	end
	const original = item:GetAttribute("NAOriginalBackgroundTransparency")
	if type(original) == "number" then
		item.BackgroundTransparency = original
	end
end

NAmanage.WindowAppearance.elementRegistry = NAmanage.WindowAppearance.elementRegistry or setmetatable({}, { __mode = "k" })

NAmanage.WindowAppearance.isElementSurface = function(item, frame)
	if not (item and item:IsA("GuiObject")) or item == frame then
		return false
	end
	if item:GetAttribute("NAWindowBackgroundLayer") == true then
		return false
	end
	if item.Name == "Topbar" or item.Name == "Container" or item.Name == "HeaderAccent" or item.Name == "HeaderDivider" then
		return false
	end
	return item.BackgroundTransparency < 0.999
end

NAmanage.WindowAppearance.captureElementTransparency = function(item)
	if not (item and item:IsA("GuiObject")) then
		return
	end
	if item:GetAttribute("NAOriginalElementBackgroundTransparency") == nil then
		item:SetAttribute("NAOriginalElementBackgroundTransparency", item.BackgroundTransparency)
	end
end

NAmanage.WindowAppearance.restoreElementTransparency = function(item)
	if not (item and item:IsA("GuiObject")) then
		return
	end
	const original = item:GetAttribute("NAOriginalElementBackgroundTransparency")
	if type(original) == "number" then
		item.BackgroundTransparency = original
	end
end

NAmanage.WindowAppearance.applyElementSurface = function(item, enabled)
	if not (item and item:IsA("GuiObject")) then
		return
	end
	const original = item:GetAttribute("NAOriginalElementBackgroundTransparency")
	if type(original) ~= "number" then
		return
	end
	if enabled then
		const amount = math.clamp(tonumber(NAStuff.WindowAppearance.elementTransparency) or 0, 0, 1)
		item.BackgroundTransparency = original + ((1 - original) * amount)
	else
		item.BackgroundTransparency = original
	end
end

NAmanage.WindowAppearance.ensureElementRegistry = function(frame)
	if not (frame and frame:IsA("GuiObject")) then
		return nil
	end
	local registry = NAmanage.WindowAppearance.elementRegistry[frame]
	if type(registry) == "table" then
		return registry
	end
	registry = {
		items = {};
		seen = setmetatable({}, { __mode = "k" });
	}
	NAmanage.WindowAppearance.elementRegistry[frame] = registry
	for _, item in frame:GetDescendants() do
		if NAmanage.WindowAppearance.isElementSurface(item, frame) then
			registry.seen[item] = true
			registry.items[#registry.items + 1] = item
			NAmanage.WindowAppearance.captureElementTransparency(item)
		end
	end
	registry.connection = frame.DescendantAdded:Connect(function(item)
		Defer(function()
			if not (item and item.Parent and frame.Parent) then
				return
			end
			if registry.seen[item] or not NAmanage.WindowAppearance.isElementSurface(item, frame) then
				return
			end
			registry.seen[item] = true
			registry.items[#registry.items + 1] = item
			NAmanage.WindowAppearance.captureElementTransparency(item)
			local isChatFrame = NAUIMANAGER and frame == NAUIMANAGER.NAchatFrame
			NAmanage.WindowAppearance.applyElementSurface(item, not isChatFrame and NAStuff.WindowAppearance.enabled == true and typeof(NAStuff.WindowAppearance.runtimeAsset) == "string" and NAStuff.WindowAppearance.runtimeAsset ~= "")
		end)
	end)
	return registry
end

NAmanage.WindowAppearance.applyElementSurfaces = function(frame, enabled)
	const registry = NAmanage.WindowAppearance.ensureElementRegistry(frame)
	if type(registry) ~= "table" then
		return
	end
	local writeIndex = 0
	for i = 1, #registry.items do
		const item = registry.items[i]
		if item and item.Parent then
			writeIndex += 1
			registry.items[writeIndex] = item
			NAmanage.WindowAppearance.applyElementSurface(item, enabled)
		end
	end
	for i = #registry.items, writeIndex + 1, -1 do
		registry.items[i] = nil
	end
end

NAmanage.WindowAppearance.applyFrame = function(frame)
	if not (frame and frame:IsA("GuiObject")) then
		return
	end
	const state = NAStuff.WindowAppearance
	const isChatFrame = NAUIMANAGER and frame == NAUIMANAGER.NAchatFrame
	const image = NAmanage.WindowAppearance.ensureLayer(frame)
	const topbar = frame:FindFirstChild("Topbar")
	const container = frame:FindFirstChild("Container")
	NAmanage.WindowAppearance.captureTransparency(topbar)
	NAmanage.WindowAppearance.captureTransparency(container)

	if state.enabled and typeof(state.runtimeAsset) == "string" and state.runtimeAsset ~= "" then
		image.Image = state.runtimeAsset
		image.ImageColor3 = Color3.fromRGB(255, 255, 255)
		local imageTransparency = tonumber(state.imageTransparency) or 0.3
		if isChatFrame then
			imageTransparency = math.max(imageTransparency, 0.62)
		end
		image.ImageTransparency = math.clamp(imageTransparency, 0, 1)
		image.ScaleType = NAmanage.WindowAppearance.scaleType(state.scaleMode)
		image.TileSize = UDim2.fromOffset(160, 160)
		image.Visible = true
		if isChatFrame then
			NAmanage.WindowAppearance.restoreTransparency(topbar)
			NAmanage.WindowAppearance.restoreTransparency(container)
			NAmanage.WindowAppearance.applyElementSurfaces(frame, false)
		else
			if topbar and topbar:IsA("GuiObject") then
				topbar.BackgroundTransparency = math.clamp(tonumber(state.topbarTransparency) or 0.3, 0, 1)
			end
			if container and container:IsA("GuiObject") then
				container.BackgroundTransparency = math.clamp(tonumber(state.containerTransparency) or 0.42, 0, 1)
			end
			NAmanage.WindowAppearance.applyElementSurfaces(frame, true)
		end
	else
		image.Visible = false
		image.Image = ""
		image.ImageColor3 = Color3.fromRGB(255, 255, 255)
		NAmanage.WindowAppearance.restoreTransparency(topbar)
		NAmanage.WindowAppearance.restoreTransparency(container)
		NAmanage.WindowAppearance.applyElementSurfaces(frame, false)
	end
end

NAmanage.WindowAppearance.applyAll = function()
	for _, frame in NAmanage.WindowAppearance.getTargets() do
		NAmanage.WindowAppearance.applyFrame(frame)
	end
end

NAmanage.WindowAppearance.save = function()
	const state = NAStuff.WindowAppearance
	const settings = NAmanage.NASettingsEnsure()
	const schema = NAmanage.NASettingsGetSchema()
	const values = {
		windowBackgroundEnabled = state.enabled == true;
		windowBackgroundSource = tostring(state.source or "");
		windowBackgroundLocalPath = tostring(state.localPath or "");
		windowBackgroundScaleMode = tostring(state.scaleMode or "Crop");
		windowBackgroundTransparency = math.clamp(tonumber(state.imageTransparency) or 0.3, 0, 1);
		windowBackgroundTopbarTransparency = math.clamp(tonumber(state.topbarTransparency) or 0.3, 0, 1);
		windowBackgroundContainerTransparency = math.clamp(tonumber(state.containerTransparency) or 0.42, 0, 1);
		windowBackgroundElementTransparency = math.clamp(tonumber(state.elementTransparency) or 0, 0, 1);
	}
	for key, value in values do
		const def = schema[key]
		if def then
			settings[key] = NAmanage.NASettingsCoerce(def, value)
		end
	end
	NAmanage.NASettingsSave()
end

NAmanage.WindowAppearance.scheduleSave = function()
	const state = NAStuff.WindowAppearance
	state.saveSequence = (tonumber(state.saveSequence) or 0) + 1
	const sequence = state.saveSequence
	Delay(0.2, function()
		if NAStuff.WindowAppearance and NAStuff.WindowAppearance.saveSequence == sequence then
			NAmanage.WindowAppearance.save()
		end
	end)
end

NAmanage.WindowAppearance.loadLibraryFile = function()
	if not (FileSupport and NAmanage.safeIsFile(NAmanage.WindowAppearance.manifestPath)) then
		return {}
	end
	local okRead, raw = NAmanage.safeReadFile(NAmanage.WindowAppearance.manifestPath)
	if not (okRead and type(raw) == "string" and raw ~= "") then
		return {}
	end
	local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if not (okDecode and type(decoded) == "table") then
		return {}
	end
	return decoded
end

NAmanage.WindowAppearance.saveLibrary = function()
	if not NAmanage.WindowAppearance.ensureFolder() then
		return false
	end
	const payload = {}
	for _, entry in NAStuff.WindowAppearance.entries or {} do
		if type(entry) == "table" and tostring(entry.source or "") ~= "" then
			payload[#payload + 1] = {
				name = tostring(entry.name or "Background");
				source = tostring(entry.source or "");
				localPath = tostring(entry.localPath or "");
			}
		end
	end
	local okEncode, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, payload)
	if not okEncode then
		return false
	end
	return NAmanage.safeWriteFile(NAmanage.WindowAppearance.manifestPath, encoded)
end

NAmanage.WindowAppearance.scanLibrary = function()
	const entries = {}
	const seenSource = {}
	const seenPath = {}
	local manifestChanged = false
	for _, saved in NAmanage.WindowAppearance.loadLibraryFile() do
		if type(saved) == "table" then
			const source = tostring(saved.source or "")
			const localPath = tostring(saved.localPath or "")
			local keep = source ~= ""
			if keep and localPath ~= "" and FileSupport then
				keep = NAmanage.safeIsFile(localPath) == true
				if not keep then
					manifestChanged = true
				end
			end
			if keep then
				const sourceKey = source:lower()
				const pathKey = localPath ~= "" and localPath:gsub("\\", "/"):lower() or ""
				if not seenSource[sourceKey] and (pathKey == "" or not seenPath[pathKey]) then
					entries[#entries + 1] = {
						name = tostring(saved.name or "Background");
						source = source;
						localPath = localPath;
					}
					seenSource[sourceKey] = true
					if pathKey ~= "" then seenPath[pathKey] = true end
				end
			elseif source ~= "" then
				manifestChanged = true
			end
		end
	end

	if FileSupport and type(listfiles) == "function" and NAmanage.WindowAppearance.ensureFolder() then
		local okList, items = pcall(listfiles, NAfiles.NAWINDOWBACKGROUNDPATH)
		if okList and type(items) == "table" then
			for _, fullPath in items do
				const name = (type(getFName) == "function" and getFName(fullPath)) or tostring(fullPath):match("([^/\\]+)$")
				if name and NAmanage.WindowAppearance.isImageFile(name) and NAmanage.safeIsFile(fullPath) then
					const pathKey = tostring(fullPath):gsub("\\", "/"):lower()
					if not seenPath[pathKey] then
						entries[#entries + 1] = {
							name = name;
							source = fullPath;
							localPath = fullPath;
						}
						seenPath[pathKey] = true
						manifestChanged = true
					end
				end
			end
		end
	end

	table.sort(entries, function(a, b)
		return tostring(a.name or ""):lower() < tostring(b.name or ""):lower()
	end)
	NAStuff.WindowAppearance.entries = entries
	if manifestChanged then
		NAmanage.WindowAppearance.saveLibrary()
	end
	return entries
end

NAmanage.WindowAppearance.currentEntry = function()
	const state = NAStuff.WindowAppearance
	const source = tostring(state.source or "")
	const path = tostring(state.localPath or "")
	for i, entry in NAStuff.WindowAppearance.entries or {} do
		if entry and ((path ~= "" and tostring(entry.localPath or "") == path) or (source ~= "" and tostring(entry.source or "") == source)) then
			return entry, i
		end
	end
	return nil, 0
end

NAmanage.WindowAppearance.makeCurrentName = function()
	const state = NAStuff.WindowAppearance
	if tostring(state.localPath or "") ~= "" then
		return (type(getFName) == "function" and getFName(state.localPath)) or tostring(state.localPath):match("([^/\\]+)$") or "Local Background"
	end
	const digits = tostring(state.source or ""):match("^rbxassetid://(%d+)$")
	if digits then
		return "Roblox "..digits
	end
	if tostring(state.source or "") ~= "" then
		return NAmanage.WindowAppearance.fileNameFromUrl(state.source)
	end
	return "Background"
end

NAmanage.WindowAppearance.saveCurrentToLibrary = function()
	const state = NAStuff.WindowAppearance
	if tostring(state.source or "") == "" then
		return false, "No current window background to save."
	end
	if not NAmanage.WindowAppearance.ensureFolder() then
		return false, "Saving multiple backgrounds requires file support."
	end
	NAmanage.WindowAppearance.scanLibrary()
	local existing, existingIndex = NAmanage.WindowAppearance.currentEntry()
	if existing then
		existing.name = existing.name or NAmanage.WindowAppearance.makeCurrentName()
		existing.source = tostring(state.source or existing.source or "")
		existing.localPath = tostring(state.localPath or existing.localPath or "")
		NAStuff.WindowAppearance.index = existingIndex
		NAmanage.WindowAppearance.saveLibrary()
		return true, existing.name
	end

	local name = NAmanage.WindowAppearance.makeCurrentName()
	const base = name
	local suffix = 2
	local duplicate = true
	while duplicate do
		duplicate = false
		for _, entry in NAStuff.WindowAppearance.entries or {} do
			if entry and tostring(entry.name or ""):lower() == name:lower() then
				duplicate = true
				name = base.." ("..tostring(suffix)..")"
				suffix += 1
				break
			end
		end
	end
	NAStuff.WindowAppearance.entries[#NAStuff.WindowAppearance.entries + 1] = {
		name = name;
		source = tostring(state.source or "");
		localPath = tostring(state.localPath or "");
	}
	NAStuff.WindowAppearance.index = #NAStuff.WindowAppearance.entries
	NAmanage.WindowAppearance.saveLibrary()
	return true, name
end

NAmanage.WindowAppearance.useEntry = function(entry)
	if type(entry) ~= "table" then
		return false, "No saved window background selected."
	end
	local result
	const localPath = tostring(entry.localPath or "")
	const source = tostring(entry.source or "")
	if localPath ~= "" and FileSupport and type(getcustomasset) == "function" and NAmanage.safeIsFile(localPath) then
		local okAsset, asset = pcall(getcustomasset, localPath)
		if okAsset and typeof(asset) == "string" and asset ~= "" then
			result = { source = source ~= "" and source or localPath; asset = asset; localPath = localPath; name = entry.name }
		end
	end
	if not result and source:match("^rbxassetid://%d+$") then
		result = { source = source; asset = source; localPath = ""; name = entry.name }
	end
	if not result and source ~= "" then
		local okResolve, resolved = NAmanage.WindowAppearance.resolveInput(source)
		if okResolve then
			result = resolved
		end
	end
	if not result then
		return false, "Saved window background is unavailable."
	end
	const state = NAStuff.WindowAppearance
	state.source = result.source
	state.localPath = result.localPath or ""
	state.runtimeAsset = result.asset
	state.enabled = true
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.save()
	if NAgui.setToggleState then
		NAgui.setToggleState("Use Custom Window Background", true, { force = true, fire = false })
	end
	return true
end

NAmanage.WindowAppearance.removeEntry = function(entry)
	if type(entry) ~= "table" then
		return false
	end
	const state = NAStuff.WindowAppearance
	const removingCurrent = (tostring(state.localPath or "") ~= "" and tostring(entry.localPath or "") == tostring(state.localPath or ""))
		or (tostring(state.source or "") ~= "" and tostring(entry.source or "") == tostring(state.source or ""))
	const localPath = tostring(entry.localPath or "")
	if localPath ~= "" and NAmanage.WindowAppearance.isManagedPath(localPath) and type(delfile) == "function" and NAmanage.safeIsFile(localPath) then
		pcall(delfile, localPath)
	end
	const kept = {}
	for _, candidate in NAStuff.WindowAppearance.entries or {} do
		if candidate ~= entry then
			kept[#kept + 1] = candidate
		end
	end
	NAStuff.WindowAppearance.entries = kept
	NAmanage.WindowAppearance.saveLibrary()
	if removingCurrent then
		state.enabled = false
		state.source = ""
		state.localPath = ""
		state.runtimeAsset = nil
		state.pendingInput = ""
		NAmanage.WindowAppearance.applyAll()
		NAmanage.WindowAppearance.save()
		if NAgui.setToggleState then
			NAgui.setToggleState("Use Custom Window Background", false, { force = true, fire = false })
		end
	end
	NAmanage.WindowAppearance.scanLibrary()
	return true
end

NAmanage.WindowAppearance.removeAll = function()
	if FileSupport and type(listfiles) == "function" and type(delfile) == "function" and NAmanage.WindowAppearance.ensureFolder() then
		local okList, items = pcall(listfiles, NAfiles.NAWINDOWBACKGROUNDPATH)
		if okList and type(items) == "table" then
			for _, fullPath in items do
				const name = (type(getFName) == "function" and getFName(fullPath)) or tostring(fullPath):match("([^/\\]+)$")
				if name and NAmanage.WindowAppearance.isImageFile(name) and NAmanage.safeIsFile(fullPath) then
					pcall(delfile, fullPath)
				end
			end
		end
		if NAmanage.safeIsFile(NAmanage.WindowAppearance.manifestPath) then
			pcall(delfile, NAmanage.WindowAppearance.manifestPath)
		end
	end
	NAStuff.WindowAppearance.entries = {}
	NAStuff.WindowAppearance.index = 0
	NAStuff.WindowAppearance.enabled = false
	NAStuff.WindowAppearance.source = ""
	NAStuff.WindowAppearance.localPath = ""
	NAStuff.WindowAppearance.runtimeAsset = nil
	NAStuff.WindowAppearance.pendingInput = ""
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.save()
	if NAgui.setToggleState then
		NAgui.setToggleState("Use Custom Window Background", false, { force = true, fire = false })
	end
end

NAmanage.WindowAppearance.refreshInfo = function()
	const info = NAStuff.WindowAppearance.info
	if not info then
		return
	end
	const state = NAStuff.WindowAppearance
	const count = #(state.entries or {})
	local prefix
	if state.enabled and typeof(state.runtimeAsset) == "string" and state.runtimeAsset ~= "" then
		prefix = "Enabled • "..tostring(state.scaleMode or "Crop")
	elseif tostring(state.source or "") ~= "" then
		prefix = state.enabled and "Saved but unavailable" or "Disabled"
	else
		prefix = "No background selected"
	end
	info.Text = prefix.." • "..tostring(count).." saved"
end

NAmanage.WindowAppearance.refreshDropdown = function()
	const entries = NAStuff.WindowAppearance.entries or {}
	local options = {}
	local selected = "None"
	const current, currentIndex = NAmanage.WindowAppearance.currentEntry()
	for _, entry in entries do
		if entry and tostring(entry.name or "") ~= "" then
			options[#options + 1] = tostring(entry.name)
		end
	end
	if #options == 0 then
		options = { "None" }
		NAStuff.WindowAppearance.index = 0
	elseif current then
		selected = tostring(current.name or options[1])
		NAStuff.WindowAppearance.index = currentIndex
	else
		local idx = math.floor(tonumber(NAStuff.WindowAppearance.index) or 1)
		if idx < 1 or idx > #options then
			idx = 1
		end
		selected = options[idx]
		NAStuff.WindowAppearance.index = idx
	end
	if NAgui.setDropdownOptions then
		NAgui.setDropdownOptions("Select Saved Window Background", options)
	end
	if NAgui.setDropdownValue then
		NAgui.setDropdownValue("Select Saved Window Background", selected, { fire = false })
	end
	NAmanage.WindowAppearance.refreshInfo()
end

NAmanage.WindowAppearance.loadStoredAsset = function()
	const state = NAStuff.WindowAppearance
	if typeof(state.localPath) == "string" and state.localPath ~= "" and FileSupport and type(getcustomasset) == "function" and NAmanage.safeIsFile(state.localPath) then
		local okAsset, asset = pcall(getcustomasset, state.localPath)
		if okAsset and typeof(asset) == "string" and asset ~= "" then
			state.runtimeAsset = asset
			return true
		end
	end
	if typeof(state.source) == "string" then
		const digits = state.source:match("^rbxassetid://(%d+)$")
		if digits then
			state.runtimeAsset = "rbxassetid://"..digits
			return true
		end
	end
	state.runtimeAsset = nil
	return false
end

NAmanage.WindowAppearance.setEnabled = function(value, opts)
	opts = opts or {}
	const state = NAStuff.WindowAppearance
	value = value == true
	if value and not (typeof(state.runtimeAsset) == "string" and state.runtimeAsset ~= "") then
		if not NAmanage.WindowAppearance.loadStoredAsset() then
			if not opts.skipToggle and NAgui.setToggleState then
				NAgui.setToggleState("Use Custom Window Background", false, { force = true, fire = false })
			end
			return false, "Apply or select a window background before enabling it."
		end
	end
	state.enabled = value
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.save()
	NAmanage.WindowAppearance.refreshInfo()
	if not opts.skipToggle and NAgui.setToggleState then
		NAgui.setToggleState("Use Custom Window Background", value, { force = true, fire = false })
	end
	return true
end

NAmanage.WindowAppearance.applyInput = function(inputValue)
	local ok, result = NAmanage.WindowAppearance.resolveInput(inputValue)
	if not ok then
		return false, result
	end
	const state = NAStuff.WindowAppearance
	state.source = result.source
	state.localPath = result.localPath or ""
	state.runtimeAsset = result.asset
	state.pendingInput = ""
	state.enabled = true
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.save()
	if NAgui.setToggleState then
		NAgui.setToggleState("Use Custom Window Background", true, { force = true, fire = false })
	end
	NAmanage.WindowAppearance.saveCurrentToLibrary()
	NAmanage.WindowAppearance.scanLibrary()
	NAmanage.WindowAppearance.refreshDropdown()
	return true, result.source
end

NAmanage.WindowAppearance.clear = function()
	const state = NAStuff.WindowAppearance
	state.enabled = false
	state.source = ""
	state.localPath = ""
	state.runtimeAsset = nil
	state.pendingInput = ""
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.save()
	NAmanage.WindowAppearance.refreshInfo()
	if NAgui.setToggleState then
		NAgui.setToggleState("Use Custom Window Background", false, { force = true, fire = false })
	end
	if NAgui.setInputValue then
		NAgui.setInputValue("Window Background Asset / URL", "", { force = true, fire = false })
	end
	NAmanage.WindowAppearance.refreshDropdown()
end

NAmanage.WindowAppearance.loadStoredAsset()
NAmanage.WindowAppearance.scanLibrary()
NAmanage.WindowAppearance.applyAll()

NAgui.addSection("UI Customization")

NAgui.addSlider("NA Icon Size", 0.5, 3, NAScale, 0.01, "", function(val)
	NAScale = val
	TextButton.Size = UDim2.new(0, 32 * val, 0, 32 * val)
	NAmanage.NASettingsSet("buttonSize", val)
end)

NAgui.addDropdown("NA Icon Shape", NAgui.getIconShapeOptions(), NAgui.sanitizeIconShape(NAStuff.IconShape), function(selection)
	local picked = selection
	if type(picked) == "table" then
		picked = picked[1]
	end
	const shape = NAmanage.applyIconShape(picked)
	NAmanage.NASettingsSet("iconShape", shape)
end)

const mainColorDefault = (NAStuff and NAStuff.AprilFoolsData and NAStuff.AprilFoolsData.originalColor) or NAUISTROKER

const MAIN_COLOR_TAB_REFRESH_INTERVAL = 1 / 30
const MAIN_COLOR_SAVE_DEBOUNCE = 0.2

NAmanage._mainColorState = NAmanage._mainColorState or {
	pendingTabColor = nil,
	tabFlushQueued = false,
	lastTabFlush = 0,
	pendingSaveColor = nil,
	saveSeq = 0,
	nextStrokePrune = 0,
}

NAgui.applyMainColorToRegisteredStrokes=function(color)
	const state = NAmanage._mainColorState
	const list = NACOLOREDELEMENTS
	if type(list) ~= "table" then
		return
	end

	const now = tick()
	const doPrune = now >= (state.nextStrokePrune or 0)

	if doPrune then
		local writeIdx = 0
		for i = 1, #list do
			const stroke = list[i]
			if typeof(stroke) == "Instance" and stroke:IsA("UIStroke") and stroke.Parent then
				writeIdx += 1
				list[writeIdx] = stroke
				stroke.Color = color
			end
		end
		for i = writeIdx + 1, #list do
			list[i] = nil
		end
		state.nextStrokePrune = now + 1.5
	else
		for i = 1, #list do
			const stroke = list[i]
			if typeof(stroke) == "Instance" and stroke:IsA("UIStroke") then
				stroke.Color = color
			end
		end
	end
end

NAgui.applyMainColorToAccentSurfaces=function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	if type(NAStuff.WindowAccentSurfaces) ~= "table" then
		NAStuff.WindowAccentSurfaces = {}
		if NAStuff.NASCREENGUI then
			for _, item in NAStuff.NASCREENGUI:GetDescendants() do
				if item:IsA("GuiObject") and item:GetAttribute("NAAccentSurface") == true then
					NAStuff.WindowAccentSurfaces[#NAStuff.WindowAccentSurfaces + 1] = item
				end
			end
		end
	end
	local writeIndex = 0
	for i = 1, #NAStuff.WindowAccentSurfaces do
		const item = NAStuff.WindowAccentSurfaces[i]
		if typeof(item) == "Instance" and item:IsA("GuiObject") and item.Parent then
			writeIndex += 1
			NAStuff.WindowAccentSurfaces[writeIndex] = item
			item.BackgroundColor3 = color
		end
	end
	for i = writeIndex + 1, #NAStuff.WindowAccentSurfaces do
		NAStuff.WindowAccentSurfaces[i] = nil
	end
end

NAgui.flushMainColorTabRefresh=function()
	const state = NAmanage._mainColorState
	state.tabFlushQueued = false

	const color = state.pendingTabColor
	if typeof(color) ~= "Color3" then
		return
	end
	state.lastTabFlush = tick()

	if not (TabManager and TabManager.tabs) then
		return
	end

	const computeColor = NAmanage.getTabStrokeColor
	const canCompute = type(computeColor) == "function"
	for name, info in TabManager.tabs do
		const btn = info and info.button
		if btn then
			local stroke = info._tabStrokeCache
			if not (typeof(stroke) == "Instance" and stroke.Parent) then
				stroke = btn:FindFirstChildWhichIsA("UIStroke", true)
				info._tabStrokeCache = stroke
			end
			if stroke then
				if canCompute then
					stroke.Color = computeColor(TabManager.current == name)
				else
					stroke.Color = color
				end
			end
			if originalIO.applyTabDisplayText then
				originalIO.applyTabDisplayText(info, {
					isActive = info._isActive,
					defaultColor = color,
				})
			end
		end
	end
end

NAgui.scheduleMainColorTabRefresh=function(color, forceNow)
	const state = NAmanage._mainColorState
	state.pendingTabColor = color

	if forceNow then
		NAgui.flushMainColorTabRefresh()
		return
	end

	const now = tick()
	const elapsed = now - (state.lastTabFlush or 0)
	if elapsed >= MAIN_COLOR_TAB_REFRESH_INTERVAL and not state.tabFlushQueued then
		NAgui.flushMainColorTabRefresh()
		return
	end

	if state.tabFlushQueued then
		return
	end
	state.tabFlushQueued = true
	const waitFor = math.max(0, MAIN_COLOR_TAB_REFRESH_INTERVAL - elapsed)
	Delay(waitFor, NAgui.flushMainColorTabRefresh)
end

NAgui.scheduleMainColorSave=function(color)
	const state = NAmanage._mainColorState
	state.pendingSaveColor = color
	state.saveSeq = (state.saveSeq or 0) + 1
	const seq = state.saveSeq
	Delay(MAIN_COLOR_SAVE_DEBOUNCE, function()
		const latest = NAmanage._mainColorState
		if not latest or latest.saveSeq ~= seq then
			return
		end
		const pending = latest.pendingSaveColor
		if typeof(pending) == "Color3" then
			SaveUIStroke(pending)
		end
	end)
end

NAgui.addColorPicker("Main Color", mainColorDefault, function(color, meta)
	if typeof(color) ~= "Color3" then
		return
	end

	NAUISTROKER = color
	NAgui.applyMainColorToRegisteredStrokes(color)
	NAgui.applyMainColorToAccentSurfaces(color)
	NAgui.scheduleMainColorTabRefresh(color, meta and meta.context == "init")
	NAmanage.SideSwipe_UpdateHandleColors(color)

	if not (meta and meta.context == "init") then
		NAgui.scheduleMainColorSave(color)
	end
end, {
	fireOnInit = true,
})

NAgui.addSection("Window Appearance")

NAStuff.WindowAppearance.info = NAgui.addInfo("Custom Window Background", "No custom window background selected")
NAmanage.WindowAppearance.refreshInfo()

NAgui.addToggle("Use Custom Window Background", NAStuff.WindowAppearance.enabled == true and typeof(NAStuff.WindowAppearance.runtimeAsset) == "string", function(value)
	local ok, err = NAmanage.WindowAppearance.setEnabled(value, { skipToggle = true })
	if not ok then
		if err then
			DoNotif(err, 3)
		end
		if NAgui.setToggleState then
			NAgui.setToggleState("Use Custom Window Background", NAStuff.WindowAppearance.enabled == true, { force = true, fire = false })
		end
	end
end)

NAmanage.RegisterToggleAutoSync("Use Custom Window Background", function()
	return NAStuff.WindowAppearance.enabled == true and typeof(NAStuff.WindowAppearance.runtimeAsset) == "string" and NAStuff.WindowAppearance.runtimeAsset ~= ""
end)

NAgui.addInput("Window Background Asset / URL", "Asset id, image URL, or local path", NAStuff.WindowAppearance.pendingInput or "", function(text)
	NAStuff.WindowAppearance.pendingInput = text or ""
end)

NAgui.addButton("Apply Window Background", function()
	local ok, result = NAmanage.WindowAppearance.applyInput(NAStuff.WindowAppearance.pendingInput)
	if not ok then
		DoNotif(result or "Unable to apply window background.", 3)
		return
	end
	NAStuff.WindowAppearance.pendingInput = ""
	if NAgui.setInputValue then
		NAgui.setInputValue("Window Background Asset / URL", "", { force = true, fire = false })
	end
	DoNotif("Custom window background applied and saved.", 2)
end)

NAgui.addDropdown("Select Saved Window Background", { "None" }, "None", function(selection)
	local selected = type(selection) == "table" and selection[1] or selection
	selected = tostring(selected or "")
	if selected == "" or Lower(selected) == "none" then
		return
	end
	local target, targetIndex
	for i, entry in NAStuff.WindowAppearance.entries or {} do
		if entry and tostring(entry.name or "") == selected then
			target = entry
			targetIndex = i
			break
		end
	end
	if not target then
		DoNotif("Selected saved background is missing.", 3)
		return
	end
	local okUse, errUse = NAmanage.WindowAppearance.useEntry(target)
	if not okUse then
		DoNotif(errUse or "Unable to apply saved background.", 3)
		return
	end
	NAStuff.WindowAppearance.index = targetIndex or 0
	NAmanage.WindowAppearance.refreshDropdown()
	DoNotif('Applied saved background "'..selected..'".', 2)
end)
NAmanage.WindowAppearance.refreshDropdown()

NAgui.addButton("Save Current Window Background", function()
	local okSave, result = NAmanage.WindowAppearance.saveCurrentToLibrary()
	if not okSave then
		DoNotif(result or "Unable to save current background.", 3)
		return
	end
	NAmanage.WindowAppearance.scanLibrary()
	NAmanage.WindowAppearance.refreshDropdown()
	DoNotif('Saved window background "'..tostring(result)..'".', 2)
end)

NAgui.addDropdown("Window Background Scale", { "Crop", "Fit", "Stretch", "Tile" }, NAStuff.WindowAppearance.scaleMode or "Crop", function(selection)
	local picked = type(selection) == "table" and selection[1] or selection
	picked = tostring(picked or "Crop")
	if picked ~= "Fit" and picked ~= "Stretch" and picked ~= "Tile" then
		picked = "Crop"
	end
	NAStuff.WindowAppearance.scaleMode = picked
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.scheduleSave()
	NAmanage.WindowAppearance.refreshInfo()
end)

NAgui.addSlider("NA Window Background Transparency", 0, 1, NAStuff.WindowAppearance.imageTransparency or 0.3, 0.05, "", function(value)
	NAStuff.WindowAppearance.imageTransparency = math.clamp(tonumber(value) or 0.3, 0, 1)
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.scheduleSave()
end)

NAgui.addSlider("Window Topbar Transparency", 0, 1, NAStuff.WindowAppearance.topbarTransparency or 0.3, 0.05, "", function(value)
	NAStuff.WindowAppearance.topbarTransparency = math.clamp(tonumber(value) or 0.3, 0, 1)
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.scheduleSave()
end)

NAgui.addSlider("Window Container Transparency", 0, 1, NAStuff.WindowAppearance.containerTransparency or 0.42, 0.05, "", function(value)
	NAStuff.WindowAppearance.containerTransparency = math.clamp(tonumber(value) or 0.42, 0, 1)
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.scheduleSave()
end)

NAgui.addSlider("Window UI Element Transparency", 0, 1, NAStuff.WindowAppearance.elementTransparency or 0, 0.05, "", function(value)
	NAStuff.WindowAppearance.elementTransparency = math.clamp(tonumber(value) or 0, 0, 1)
	NAmanage.WindowAppearance.applyAll()
	NAmanage.WindowAppearance.scheduleSave()
end)

NAgui.addButton("Reload Window Backgrounds", function()
	NAmanage.WindowAppearance.scanLibrary()
	NAmanage.WindowAppearance.refreshDropdown()
	DoNotif("Saved window backgrounds reloaded.", 2)
end)

NAgui.addButton("Delete Selected Window Background", function()
	local entry = NAmanage.WindowAppearance.currentEntry()
	if not entry then
		const idx = tonumber(NAStuff.WindowAppearance.index)
		entry = idx and (NAStuff.WindowAppearance.entries or {})[idx] or nil
	end
	if not entry then
		DoNotif("No saved window background selected.", 3)
		return
	end
	const label = tostring(entry.name or "Background")
	if not NAmanage.WindowAppearance.removeEntry(entry) then
		DoNotif("Unable to delete the selected window background.", 3)
		return
	end
	NAmanage.WindowAppearance.refreshDropdown()
	DoNotif('Deleted saved background "'..label..'".', 2)
end)

NAgui.addButton("Remove Window Background...", function()
	const entries = NAStuff.WindowAppearance.entries or {}
	if #entries == 0 then
		DoNotif("No saved window backgrounds.", 3)
		return
	end
	if type(Popup) ~= "function" then
		DoNotif("Popup UI is unavailable in this session.", 3)
		return
	end
	const buttons = {}
	for _, entry in entries do
		const label = tostring(entry.name or "Background")
		Insert(buttons, {
			Text = label,
			Callback = function()
				NAmanage.WindowAppearance.removeEntry(entry)
				NAmanage.WindowAppearance.refreshDropdown()
				DoNotif('Removed saved background "'..label..'".', 2)
			end,
		})
	end
	Insert(buttons, { Text = "Cancel", Callback = function() end })
	Popup({
		Title = "Remove Window Background",
		Description = "Select a saved background to delete.",
		Duration = 0,
		Buttons = buttons,
	})
end)

NAgui.addButton("Remove All Window Backgrounds", function()
	if #(NAStuff.WindowAppearance.entries or {}) == 0 then
		DoNotif("No saved window backgrounds.", 3)
		return
	end
	NAmanage.WindowAppearance.removeAll()
	NAmanage.WindowAppearance.refreshDropdown()
	DoNotif("Removed all saved window backgrounds.", 2)
end)

NAgui.addButton("Clear Window Background", function()
	NAmanage.WindowAppearance.clear()
	DoNotif("Custom window background cleared.", 2)
end)

NAgui.addSection("Icon Appearance")

NAgui.addSlider("Icon Background Transparency", 0, 1, NAgui.clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.background or 0, 0), 0.05, "", function(val)
	const v = NAgui.clamp01(val, 0)
	NAStuff.iconAppearance.background = v
	NAmanage.applyIconAppearance()
	NAmanage.NASettingsSet("iconBgTransparency", v)
end)

if TextButton and TextButton:IsA("ImageButton") then
	NAgui.addSlider("Icon Image Transparency", 0, 1, NAgui.clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.image or 0, 0), 0.05, "", function(val)
		const v = NAgui.clamp01(val, 0)
		NAStuff.iconAppearance.image = v
		NAmanage.applyIconAppearance()
		NAmanage.NASettingsSet("iconImageTransparency", v)
	end)
end

NAgui.addSlider("Icon Text Transparency", 0, 1, NAgui.clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.text or 0, 0), 0.05, "", function(val)
	const v = NAgui.clamp01(val, 0)
	NAStuff.iconAppearance.text = v
	NAmanage.applyIconAppearance()
	NAmanage.NASettingsSet("iconTextTransparency", v)
end)

NAgui.addSlider("Icon Stroke Transparency", 0, 1, NAgui.clamp01(NAStuff.iconAppearance and NAStuff.iconAppearance.stroke or 0.7, 0.7), 0.05, "", function(val)
	const v = NAgui.clamp01(val, 0.7)
	NAStuff.iconAppearance.stroke = v
	NAmanage.applyIconAppearance()
	NAmanage.NASettingsSet("iconStrokeTransparency", v)
end)

NAgui.addButton("Reset Icon Transparency", function()
	NAStuff.iconAppearance.background = NAStuff.IconDefaultTrans.background
	NAStuff.iconAppearance.image = NAStuff.IconDefaultTrans.image
	NAStuff.iconAppearance.text = NAStuff.IconDefaultTrans.text
	NAStuff.iconAppearance.stroke = NAStuff.IconDefaultTrans.stroke
	NAmanage.applyIconAppearance()
	if NAgui.setSliderValue then
		NAgui.setSliderValue("Icon Background Transparency", NAStuff.IconDefaultTrans.background or 0, { force = true, fire = false })
		NAgui.setSliderValue("Icon Text Transparency", NAStuff.IconDefaultTrans.text or 0, { force = true, fire = false })
		NAgui.setSliderValue("Icon Stroke Transparency", NAStuff.IconDefaultTrans.stroke or 0.7, { force = true, fire = false })
		if TextButton and TextButton:IsA("ImageButton") then
			NAgui.setSliderValue("Icon Image Transparency", NAStuff.IconDefaultTrans.image or 0, { force = true, fire = false })
		end
	end
	NAmanage.NASettingsSet("iconBgTransparency", NAStuff.IconDefaultTrans.background or 0)
	NAmanage.NASettingsSet("iconImageTransparency", NAStuff.IconDefaultTrans.image or 0)
	NAmanage.NASettingsSet("iconTextTransparency", NAStuff.IconDefaultTrans.text or 0)
	NAmanage.NASettingsSet("iconStrokeTransparency", NAStuff.IconDefaultTrans.stroke or 0.7)
end)

NAgui.addSection("Crosshair")

NAgui.addToggle("Show Crosshair", NAStuff.CrosshairEnabled == true, function(v)
	NAStuff.CrosshairEnabled = v == true
	NAmanage.NASettingsSet("crosshairEnabled", NAStuff.CrosshairEnabled)
	NAmanage.applyCrosshair()
end)

NAgui.addSlider("Crosshair Size", 2, 100, math.clamp(tonumber(NAStuff.CrosshairSize) or 8, 2, 100), 1, " px", function(val)
	const n = math.clamp(tonumber(val) or NAStuff.CrosshairSize or 8, 2, 100)
	NAStuff.CrosshairSize = n
	NAmanage.NASettingsSet("crosshairSize", n)
	NAmanage.applyCrosshair()
end)

NAgui.addSlider("Crosshair Thickness", 1, 20, math.clamp(tonumber(NAStuff.CrosshairThickness) or 2, 1, 20), 1, " px", function(val)
	const n = math.clamp(tonumber(val) or NAStuff.CrosshairThickness or 2, 1, 20)
	NAStuff.CrosshairThickness = n
	NAmanage.NASettingsSet("crosshairThickness", n)
	NAmanage.applyCrosshair()
end)

NAgui.addSlider("Crosshair Gap", 0, 30, math.clamp(tonumber(NAStuff.CrosshairGap) or 2, 0, 30), 1, " px", function(val)
	const n = math.clamp(math.floor((tonumber(val) or NAStuff.CrosshairGap or 2) + 0.5), 0, 30)
	NAStuff.CrosshairGap = n
	NAmanage.NASettingsSet("crosshairGap", n)
	NAmanage.applyCrosshair()
end)

NAgui.addToggle("Crosshair Center Dot", NAStuff.CrosshairShowCenter ~= false, function(v)
	NAStuff.CrosshairShowCenter = v ~= false
	NAmanage.NASettingsSet("crosshairShowCenter", NAStuff.CrosshairShowCenter)
	NAmanage.applyCrosshair()
end)

NAgui.addColorPicker("Crosshair Color", NAStuff.CrosshairColor or Color3.new(1,1,1), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.CrosshairColor = color
	NAmanage.NASettingsSet("crosshairColor", { R = color.R, G = color.G, B = color.B })
	NAmanage.applyCrosshair()
end, {
	fireOnInit = false,
})

NAgui.addSection("Window Resizing")

NAgui.addToggle("Resize Handle Icons", NAStuff.ResizeHandleIconsEnabled == true, function(v)
	NAStuff.ResizeHandleIconsEnabled = v == true
	NAmanage.NASettingsSet("resizeHandleIcons", NAStuff.ResizeHandleIconsEnabled)
	if NAmanage.RefreshResizeHandles then
		NAmanage.RefreshResizeHandles()
	end
end)
NAmanage.RegisterToggleAutoSync("Resize Handle Icons", function()
	return NAStuff.ResizeHandleIconsEnabled == true
end)

NAgui.addSection("Topbar")

NAgui.addDropdown("Topbar Toggle Shape", NAmanage.Topbar_GetButtonShapeOptions(), NAmanage.Topbar_SanitizeButtonShape(NAStuff.TopbarButtonShape), function(selection)
	local picked = selection
	if type(picked) == "table" then
		picked = picked[1]
	end
	NAmanage.Topbar_ApplyButtonShape(picked, { save = true })
end)

NAgui.addToggle("Dropdown Under Toggle", TopBarApp.mode == "bottom", function(state)
	NAmanage.Topbar_SetMode(state and "bottom" or "side")
end)

NATopbarDock = NAmanage.topbar_readDock()
NAgui.addToggle("Topbar on Bottom", NATopbarDock == "bottom", function(state)
	NAmanage.Topbar_SetDock(state and "bottom" or "top")
end)
NAmanage.RegisterToggleAutoSync("Topbar on Bottom", function()
	return NATopbarDock == "bottom"
end)

NAgui.addToggle("TopBar Visibility", NATOPBARVISIBLE, function(v)
	NAmanage.Topbar_SetVisible(v, { notify = false })
end)
NAmanage.RegisterToggleAutoSync("TopBar Visibility", function()
	return NATOPBARVISIBLE == true
end)

NAgui.addToggle("Keep Topbar Position", NATopbarKeepPosition, function(v)
	NATopbarKeepPosition = v and true or false
	NAmanage.NASettingsSet("topbarKeepPosition", NATopbarKeepPosition)
	if NATopbarKeepPosition then
		NAmanage.Topbar_SavePositionPreference({ force = true })
		DoNotif("Topbar position will be saved on exit", 2)
	else
		NAmanage.Topbar_ResetPositionPreference()
		DoNotif("Topbar position reset to center", 2)
	end
	NAmanage.Topbar_ClampToggle()
end)
NAmanage.RegisterToggleAutoSync("Keep Topbar Position", function()
	return NATopbarKeepPosition == true
end)

NAgui.addSlider("Topbar Glass Transparency", 0, 1, NAgui.clamp01(NAStuff.TopbarGlassTransparency or 0.12, 0.12), 0.05, "", function(v)
	NAStuff.TopbarGlassTransparency = NAgui.clamp01(v, 0.12)
	NAmanage.applyTopbarStyle()
	NAmanage.NASettingsSet("topbarGlassTransparency", NAStuff.TopbarGlassTransparency)
end)

NAgui.addSlider("Topbar Stroke Transparency", 0, 1, NAgui.clamp01(NAStuff.TopbarStrokeTransparency or 0.15, 0.15), 0.05, "", function(v)
	NAStuff.TopbarStrokeTransparency = NAgui.clamp01(v, 0.15)
	NAmanage.applyTopbarStyle()
	NAmanage.NASettingsSet("topbarStrokeTransparency", NAStuff.TopbarStrokeTransparency)
end)

NAgui.addSlider("Topbar Panel Transparency", 0, 1, NAgui.clamp01(NAStuff.TopbarPanelTransparency or 0.1, 0.1), 0.05, "", function(v)
	NAStuff.TopbarPanelTransparency = NAgui.clamp01(v, 0.1)
	NAmanage.applyTopbarStyle()
	NAmanage.NASettingsSet("topbarPanelTransparency", NAStuff.TopbarPanelTransparency)
end)

NAgui.addSlider("Topbar Button Transparency", 0, 1, NAgui.clamp01(NAStuff.TopbarButtonTransparency or 0.18, 0.18), 0.05, "", function(v)
	NAStuff.TopbarButtonTransparency = NAgui.clamp01(v, 0.18)
	NAmanage.applyTopbarStyle()
	NAmanage.NASettingsSet("topbarButtonTransparency", NAStuff.TopbarButtonTransparency)
end)


NAgui.addSection("Roblox TopBarApp")

const robloxTopbarLayouts = {
	"Controls Unified",
	"All Unified",
	"All Separate",
	"Menu + Chat + Voice",
}
const robloxTopbarMorePositions = {
	"Original",
	"Left",
	"Right",
}

NAgui.addToggle("Enable Roblox TopBarApp Editor", NAStuff.RobloxTopbarEditorEnabled == true, function(v)
	NAmanage.NASettingsSet("robloxTopbarEditorEnabled", v == true)
	NAmanage.RobloxTopbar_SetEnabled(v == true)
end)
NAmanage.RegisterToggleAutoSync("Enable Roblox TopBarApp Editor", function()
	return NAmanage.RobloxTopbarEditor and NAmanage.RobloxTopbarEditor.enabled == true
end)

NAgui.addButton("Refresh TopBarApp Editor", function()
	NAmanage.RobloxTopbar_Refresh()
end)

NAgui.addDropdown("TopBarApp Button Grouping", robloxTopbarLayouts, NAStuff.RobloxTopbarLayout or "Controls Unified", function(selection)
	const value = type(selection) == "table" and selection[1] or selection
	NAStuff.RobloxTopbarLayout = NAmanage.NASettingsSet("robloxTopbarLayout", value) or "Controls Unified"
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addDropdown("TopBarApp More Button Position", robloxTopbarMorePositions, NAStuff.RobloxTopbarMorePosition or "Original", function(selection)
	const value = type(selection) == "table" and selection[1] or selection
	NAStuff.RobloxTopbarMorePosition = NAmanage.NASettingsSet("robloxTopbarMorePosition", value) or "Original"
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Button Size", 32, 56, NAStuff.RobloxTopbarButtonSize or 44, 1, " px", function(v)
	NAStuff.RobloxTopbarButtonSize = math.clamp(math.floor((tonumber(v) or 44) + 0.5), 32, 56)
	NAmanage.NASettingsSet("robloxTopbarButtonSize", NAStuff.RobloxTopbarButtonSize)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Button Gap", 0, 16, NAStuff.RobloxTopbarSeparateGap or 4, 1, " px", function(v)
	NAStuff.RobloxTopbarSeparateGap = math.clamp(math.floor((tonumber(v) or 4) + 0.5), 0, 16)
	NAmanage.NASettingsSet("robloxTopbarSeparateGap", NAStuff.RobloxTopbarSeparateGap)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Menu Gap", 0, 24, NAStuff.RobloxTopbarMenuGap or 4, 1, " px", function(v)
	NAStuff.RobloxTopbarMenuGap = math.clamp(math.floor((tonumber(v) or 4) + 0.5), 0, 24)
	NAmanage.NASettingsSet("robloxTopbarMenuGap", NAStuff.RobloxTopbarMenuGap)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Group Padding", 0, 12, NAStuff.RobloxTopbarGroupPadding or 0, 1, " px", function(v)
	NAStuff.RobloxTopbarGroupPadding = math.clamp(math.floor((tonumber(v) or 0) + 0.5), 0, 12)
	NAmanage.NASettingsSet("robloxTopbarGroupPadding", NAStuff.RobloxTopbarGroupPadding)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Vertical Offset", 0, 32, NAStuff.RobloxTopbarVerticalOffset or 10, 1, " px", function(v)
	NAStuff.RobloxTopbarVerticalOffset = math.clamp(math.floor((tonumber(v) or 10) + 0.5), 0, 32)
	NAmanage.NASettingsSet("robloxTopbarVerticalOffset", NAStuff.RobloxTopbarVerticalOffset)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Horizontal Inset", 0, 48, NAStuff.RobloxTopbarHorizontalInset or 16, 1, " px", function(v)
	NAStuff.RobloxTopbarHorizontalInset = math.clamp(math.floor((tonumber(v) or 16) + 0.5), 0, 48)
	NAmanage.NASettingsSet("robloxTopbarHorizontalInset", NAStuff.RobloxTopbarHorizontalInset)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addColorPicker("TopBarApp Background Color", NAStuff.RobloxTopbarBackgroundColor or Color3.fromRGB(18, 18, 21), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.RobloxTopbarBackgroundColor = color
	NAmanage.NASettingsSet("robloxTopbarBackgroundColor", { R = color.R; G = color.G; B = color.B })
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Background Transparency", 0, 1, NAgui.clamp01(NAStuff.RobloxTopbarBackgroundTransparency or 0.08, 0.08), 0.01, "", function(v)
	NAStuff.RobloxTopbarBackgroundTransparency = NAgui.clamp01(v, 0.08)
	NAmanage.NASettingsSet("robloxTopbarBackgroundTransparency", NAStuff.RobloxTopbarBackgroundTransparency)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Corner Radius", 0, 32, math.clamp(math.floor((tonumber(NAStuff.RobloxTopbarCornerRadius) or 22) + 0.5), 0, 32), 1, " px", function(v)
	NAStuff.RobloxTopbarCornerRadius = math.clamp(math.floor((tonumber(v) or 22) + 0.5), 0, 32)
	NAmanage.NASettingsSet("robloxTopbarCornerRadius", NAStuff.RobloxTopbarCornerRadius)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addToggle("TopBarApp Stroke", NAStuff.RobloxTopbarStrokeEnabled == true, function(v)
	NAStuff.RobloxTopbarStrokeEnabled = v == true
	NAmanage.NASettingsSet("robloxTopbarStrokeEnabled", NAStuff.RobloxTopbarStrokeEnabled)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addColorPicker("TopBarApp Stroke Color", NAStuff.RobloxTopbarStrokeColor or Color3.new(1, 1, 1), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.RobloxTopbarStrokeColor = color
	NAmanage.NASettingsSet("robloxTopbarStrokeColor", { R = color.R; G = color.G; B = color.B })
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Stroke Transparency", 0, 1, NAgui.clamp01(NAStuff.RobloxTopbarStrokeTransparency or 0.5, 0.5), 0.01, "", function(v)
	NAStuff.RobloxTopbarStrokeTransparency = NAgui.clamp01(v, 0.5)
	NAmanage.NASettingsSet("robloxTopbarStrokeTransparency", NAStuff.RobloxTopbarStrokeTransparency)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Stroke Thickness", 0, 4, math.clamp(tonumber(NAStuff.RobloxTopbarStrokeThickness) or 1, 0, 4), 0.1, " px", function(v)
	NAStuff.RobloxTopbarStrokeThickness = math.clamp(tonumber(v) or 1, 0, 4)
	NAmanage.NASettingsSet("robloxTopbarStrokeThickness", NAStuff.RobloxTopbarStrokeThickness)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addColorPicker("TopBarApp Icon Color", NAStuff.RobloxTopbarIconColor or Color3.new(1, 1, 1), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.RobloxTopbarIconColor = color
	NAmanage.NASettingsSet("robloxTopbarIconColor", { R = color.R; G = color.G; B = color.B })
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Icon Transparency", 0, 1, NAgui.clamp01(NAStuff.RobloxTopbarIconTransparency or 0, 0), 0.01, "", function(v)
	NAStuff.RobloxTopbarIconTransparency = NAgui.clamp01(v, 0)
	NAmanage.NASettingsSet("robloxTopbarIconTransparency", NAStuff.RobloxTopbarIconTransparency)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addSlider("TopBarApp Icon Scale", 0.6, 1.4, math.clamp(tonumber(NAStuff.RobloxTopbarIconScale) or 1, 0.6, 1.4), 0.05, "x", function(v)
	NAStuff.RobloxTopbarIconScale = math.clamp(tonumber(v) or 1, 0.6, 1.4)
	NAmanage.NASettingsSet("robloxTopbarIconScale", NAStuff.RobloxTopbarIconScale)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addToggle("Keep Roblox Icon Gradient", NAStuff.RobloxTopbarKeepIconGradient ~= false, function(v)
	NAStuff.RobloxTopbarKeepIconGradient = v ~= false
	NAmanage.NASettingsSet("robloxTopbarKeepIconGradient", NAStuff.RobloxTopbarKeepIconGradient)
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAgui.addButton("Reset TopBarApp Editor", function()
	NAStuff.RobloxTopbarLayout = "Controls Unified"
	NAStuff.RobloxTopbarMorePosition = "Original"
	NAStuff.RobloxTopbarButtonSize = 44
	NAStuff.RobloxTopbarSeparateGap = 4
	NAStuff.RobloxTopbarMenuGap = 4
	NAStuff.RobloxTopbarGroupPadding = 0
	NAStuff.RobloxTopbarVerticalOffset = 10
	NAStuff.RobloxTopbarHorizontalInset = 16
	NAStuff.RobloxTopbarBackgroundColor = Color3.fromRGB(18, 18, 21)
	NAStuff.RobloxTopbarBackgroundTransparency = 0.08
	NAStuff.RobloxTopbarCornerRadius = 22
	NAStuff.RobloxTopbarStrokeEnabled = false
	NAStuff.RobloxTopbarStrokeColor = Color3.new(1, 1, 1)
	NAStuff.RobloxTopbarStrokeTransparency = 0.5
	NAStuff.RobloxTopbarStrokeThickness = 1
	NAStuff.RobloxTopbarIconColor = Color3.new(1, 1, 1)
	NAStuff.RobloxTopbarIconTransparency = 0
	NAStuff.RobloxTopbarIconScale = 1
	NAStuff.RobloxTopbarKeepIconGradient = true
	NAmanage.NASettingsSet("robloxTopbarLayout", NAStuff.RobloxTopbarLayout)
	NAmanage.NASettingsSet("robloxTopbarMorePosition", NAStuff.RobloxTopbarMorePosition)
	NAmanage.NASettingsSet("robloxTopbarButtonSize", NAStuff.RobloxTopbarButtonSize)
	NAmanage.NASettingsSet("robloxTopbarSeparateGap", NAStuff.RobloxTopbarSeparateGap)
	NAmanage.NASettingsSet("robloxTopbarMenuGap", NAStuff.RobloxTopbarMenuGap)
	NAmanage.NASettingsSet("robloxTopbarGroupPadding", NAStuff.RobloxTopbarGroupPadding)
	NAmanage.NASettingsSet("robloxTopbarVerticalOffset", NAStuff.RobloxTopbarVerticalOffset)
	NAmanage.NASettingsSet("robloxTopbarHorizontalInset", NAStuff.RobloxTopbarHorizontalInset)
	NAmanage.NASettingsSet("robloxTopbarBackgroundColor", { R = NAStuff.RobloxTopbarBackgroundColor.R; G = NAStuff.RobloxTopbarBackgroundColor.G; B = NAStuff.RobloxTopbarBackgroundColor.B })
	NAmanage.NASettingsSet("robloxTopbarBackgroundTransparency", NAStuff.RobloxTopbarBackgroundTransparency)
	NAmanage.NASettingsSet("robloxTopbarCornerRadius", NAStuff.RobloxTopbarCornerRadius)
	NAmanage.NASettingsSet("robloxTopbarStrokeEnabled", NAStuff.RobloxTopbarStrokeEnabled)
	NAmanage.NASettingsSet("robloxTopbarStrokeColor", { R = 1; G = 1; B = 1 })
	NAmanage.NASettingsSet("robloxTopbarStrokeTransparency", NAStuff.RobloxTopbarStrokeTransparency)
	NAmanage.NASettingsSet("robloxTopbarStrokeThickness", NAStuff.RobloxTopbarStrokeThickness)
	NAmanage.NASettingsSet("robloxTopbarIconColor", { R = 1; G = 1; B = 1 })
	NAmanage.NASettingsSet("robloxTopbarIconTransparency", NAStuff.RobloxTopbarIconTransparency)
	NAmanage.NASettingsSet("robloxTopbarIconScale", NAStuff.RobloxTopbarIconScale)
	NAmanage.NASettingsSet("robloxTopbarKeepIconGradient", NAStuff.RobloxTopbarKeepIconGradient)
	if NAgui.setDropdownValue then
		NAgui.setDropdownValue("TopBarApp Button Grouping", NAStuff.RobloxTopbarLayout, { fire = false })
		NAgui.setDropdownValue("TopBarApp More Button Position", NAStuff.RobloxTopbarMorePosition, { fire = false })
	end
	if NAgui.setColorPickerValue then
		NAgui.setColorPickerValue("TopBarApp Background Color", NAStuff.RobloxTopbarBackgroundColor, { fire = false })
		NAgui.setColorPickerValue("TopBarApp Stroke Color", NAStuff.RobloxTopbarStrokeColor, { fire = false })
		NAgui.setColorPickerValue("TopBarApp Icon Color", NAStuff.RobloxTopbarIconColor, { fire = false })
	end
	if NAgui.setSliderValue then
		NAgui.setSliderValue("TopBarApp Button Size", NAStuff.RobloxTopbarButtonSize, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Button Gap", NAStuff.RobloxTopbarSeparateGap, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Menu Gap", NAStuff.RobloxTopbarMenuGap, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Group Padding", NAStuff.RobloxTopbarGroupPadding, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Vertical Offset", NAStuff.RobloxTopbarVerticalOffset, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Horizontal Inset", NAStuff.RobloxTopbarHorizontalInset, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Background Transparency", NAStuff.RobloxTopbarBackgroundTransparency, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Corner Radius", NAStuff.RobloxTopbarCornerRadius, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Stroke Transparency", NAStuff.RobloxTopbarStrokeTransparency, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Stroke Thickness", NAStuff.RobloxTopbarStrokeThickness, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Icon Transparency", NAStuff.RobloxTopbarIconTransparency, { force = true, fire = false })
		NAgui.setSliderValue("TopBarApp Icon Scale", NAStuff.RobloxTopbarIconScale, { force = true, fire = false })
	end
	NAmanage.RobloxTopbar_ScheduleApply()
end)

NAmanage.RobloxTopbar_SetEnabled(NAStuff.RobloxTopbarEditorEnabled == true)

NAgui.addSection("Edge Swipe Gesture")

NAgui.addToggle("Gesture Handle On Left", NASideSwipeSide ~= "right", function(v)
	NAmanage.SideSwipe_SetSide(v and "left" or "right")
end)
NAmanage.RegisterToggleAutoSync("Gesture Handle On Left", function()
	return NASideSwipeSide ~= "right"
end)

NAgui.addToggle("Edge Swipe Gesture Enabled", NASideSwipeEnabled, function(v)
	NASideSwipeEnabled = v and true or false
	if SideSwipeApp and SideSwipeApp.gui then
		SideSwipeApp.gui.Visible = NASideSwipeEnabled
	end
	NAmanage.NASettingsSet("sideSwipeEnabled", NASideSwipeEnabled)
end)
NAmanage.RegisterToggleAutoSync("Edge Swipe Gesture Enabled", function()
	return NASideSwipeEnabled == true
end)

NAgui.addSection("Edge Swipe Gesture Styling")
NAgui.addInfo("Gesture Auto Size", "Set Panel Height, Handle Width, or Handle Height to 0 to use automatic sizing.")

NAgui.addSlider("Gesture Panel Width", 60, 200, math.clamp(tonumber(NAStuff.SideSwipeWidth) or 80, 60, 200), 1, " px", function(v)
	NAStuff.SideSwipeWidth = math.clamp(math.floor((tonumber(v) or 80) + 0.5), 60, 200)
	NAmanage.NASettingsSet("sideSwipeWidth", NAStuff.SideSwipeWidth)
	NAmanage.applySideSwipeStyle({ rebuild = true })
end)

NAgui.addSlider("Gesture Panel Height", 0, 1200, math.clamp(math.floor((tonumber(NAStuff.SideSwipePanelHeight) or 0) + 0.5), 0, 1200), 5, " px", function(v)
	NAStuff.SideSwipePanelHeight = math.clamp(math.floor((tonumber(v) or 0) + 0.5), 0, 1200)
	NAmanage.NASettingsSet("sideSwipePanelHeight", NAStuff.SideSwipePanelHeight)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAgui.addSlider("Gesture Handle Width", 0, 120, math.clamp(math.floor((tonumber(NAStuff.SideSwipeHandleWidth) or 0) + 0.5), 0, 120), 1, " px", function(v)
	NAStuff.SideSwipeHandleWidth = math.clamp(math.floor((tonumber(v) or 0) + 0.5), 0, 120)
	NAmanage.NASettingsSet("sideSwipeHandleWidth", NAStuff.SideSwipeHandleWidth)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAgui.addSlider("Gesture Handle Height", 0, 800, math.clamp(math.floor((tonumber(NAStuff.SideSwipeHandleHeight) or 0) + 0.5), 0, 800), 5, " px", function(v)
	NAStuff.SideSwipeHandleHeight = math.clamp(math.floor((tonumber(v) or 0) + 0.5), 0, 800)
	NAmanage.NASettingsSet("sideSwipeHandleHeight", NAStuff.SideSwipeHandleHeight)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAgui.addSlider("Gesture Handle Vertical Position", 0, 100, math.clamp(tonumber(NAStuff.SideSwipeHandleVerticalPosition) or 50, 0, 100), 1, "%", function(v)
	NAStuff.SideSwipeHandleVerticalPosition = math.clamp(tonumber(v) or 50, 0, 100)
	NAmanage.NASettingsSet("sideSwipeHandleVerticalPosition", NAStuff.SideSwipeHandleVerticalPosition)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAgui.addSlider("Gesture Swipe Threshold", 8, 120, math.clamp(math.floor((tonumber(NAStuff.SideSwipeSwipeThreshold) or 28) + 0.5), 8, 120), 1, " px", function(v)
	NAStuff.SideSwipeSwipeThreshold = math.clamp(math.floor((tonumber(v) or 28) + 0.5), 8, 120)
	NAmanage.NASettingsSet("sideSwipeSwipeThreshold", NAStuff.SideSwipeSwipeThreshold)
end)

NAgui.addSlider("Gesture Button Height", 32, 96, math.clamp(math.floor((tonumber(NAStuff.SideSwipeButtonHeight) or 48) + 0.5), 32, 96), 1, " px", function(v)
	NAStuff.SideSwipeButtonHeight = math.clamp(math.floor((tonumber(v) or 48) + 0.5), 32, 96)
	NAmanage.NASettingsSet("sideSwipeButtonHeight", NAStuff.SideSwipeButtonHeight)
	NAmanage.applySideSwipeStyle({ rebuild = true })
end)

NAgui.addSlider("Gesture Button Spacing", 0, 32, math.clamp(math.floor((tonumber(NAStuff.SideSwipeButtonSpacing) or 8) + 0.5), 0, 32), 1, " px", function(v)
	NAStuff.SideSwipeButtonSpacing = math.clamp(math.floor((tonumber(v) or 8) + 0.5), 0, 32)
	NAmanage.NASettingsSet("sideSwipeButtonSpacing", NAStuff.SideSwipeButtonSpacing)
	NAmanage.applySideSwipeStyle({ rebuild = true })
end)

NAgui.addSlider("Gesture Handle Transparency", 0, 1, NAgui.clamp01(NAStuff.SideSwipeHandleTransparency or 0.72, 0.72), 0.05, "", function(v)
	NAStuff.SideSwipeHandleTransparency = NAgui.clamp01(v, 0.72)
	NAmanage.NASettingsSet("sideSwipeHandleTransparency", NAStuff.SideSwipeHandleTransparency)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAgui.addSlider("Gesture Panel Transparency", 0, 1, NAgui.clamp01(NAStuff.SideSwipePanelTransparency or 0.35, 0.35), 0.05, "", function(v)
	NAStuff.SideSwipePanelTransparency = NAgui.clamp01(v, 0.35)
	NAmanage.NASettingsSet("sideSwipePanelTransparency", NAStuff.SideSwipePanelTransparency)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAgui.addSlider("Gesture Button Transparency", 0, 1, NAgui.clamp01(NAStuff.SideSwipeButtonTransparency or 0.16, 0.16), 0.05, "", function(v)
	NAStuff.SideSwipeButtonTransparency = NAgui.clamp01(v, 0.16)
	NAmanage.NASettingsSet("sideSwipeButtonTransparency", NAStuff.SideSwipeButtonTransparency)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAgui.addSlider("Gesture Scrollbar Thickness", 0, 12, math.clamp(math.floor((tonumber(NAStuff.SideSwipeScrollBarThickness) or 4) + 0.5), 0, 12), 1, " px", function(v)
	NAStuff.SideSwipeScrollBarThickness = math.clamp(math.floor((tonumber(v) or NAStuff.SideSwipeScrollBarThickness or 4) + 0.5), 0, 12)
	NAmanage.NASettingsSet("sideSwipeScrollBarThickness", NAStuff.SideSwipeScrollBarThickness)
	NAmanage.applySideSwipeStyle({ rebuild = false })
end)

NAmanage.NAInitCoreGuiCustomization=function()
	return NAgui.withSettingsTabContext(NA_TABS.TAB_INTERFACE, function()
		NAgui.addSection("CoreGui Customization")

	if Services.CoreGui then
		const coreCustomizerBatch = IsOnMobile and 12 or 32
		const PT = {
			path      = NAfiles.NAFILEPATH.."/plexity_theme.json",
			default   = { enabled = false, start = { h = 0.8, s = 1, v = 1 }, finish = { h = 0, s = 1, v = 1 } },
			cg        = Services.CoreGui,
			images    = setmetatable({}, { __mode = "k" }),
			gradients = setmetatable({}, { __mode = "k" }),
			watchers  = setmetatable({}, { __mode = "k" }),
			queue     = {},
			queueHead = 1,
			queueTail = 0,
			queueSet  = setmetatable({}, { __mode = "k" }),
			queueToken = 0,
			processing = false,
			queueKickPending = false,
			applying   = false,
			needApplyAll = false,
			applyAllSeq = 0,
			trackedApplyQueued = false,
			rescanning = false,
			rescanAgain = false,
			gradientSeq = nil,
			gradientSeqKey = nil,
			gradientTrans = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0, 0),
				NumberSequenceKeypoint.new(0.5, 0, 0),
				NumberSequenceKeypoint.new(1, 0, 0),
			},
			recheckQueue = {},
			recheckSet = setmetatable({}, { __mode = "k" }),
			recheckHead = 1,
			recheckTail = 0,
			recheckShortTail = 0,
			recheckShortQueued = false,
			recheckLongQueued = false,
		}

		local data = PT.default
		if FileSupport then
			if not isfile(PT.path) then
				writefile(PT.path, Services.HttpService:JSONEncode(PT.default))
			end

			local okRead, raw = pcall(readfile, PT.path)
			if okRead and type(raw) == "string" then
				local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
				if okDecode and type(decoded) == "table" then
					data = decoded
				end
			end
		end

		const function normalizePlexData(raw)
			const out = {
				enabled = false,
				start = {
					h = PT.default.start.h,
					s = PT.default.start.s,
					v = PT.default.start.v,
				},
				finish = {
					h = PT.default.finish.h,
					s = PT.default.finish.s,
					v = PT.default.finish.v,
				},
			}
			if type(raw) ~= "table" then
				return out
			end
			out.enabled = raw.enabled == true
			if type(raw.start) == "table" then
				out.start.h = math.clamp(tonumber(raw.start.h) or out.start.h, 0, 1)
				out.start.s = math.clamp(tonumber(raw.start.s) or out.start.s, 0, 1)
				out.start.v = math.clamp(tonumber(raw.start.v) or out.start.v, 0, 1)
			end
			if type(raw.finish) == "table" then
				out.finish.h = math.clamp(tonumber(raw.finish.h) or out.finish.h, 0, 1)
				out.finish.s = math.clamp(tonumber(raw.finish.s) or out.finish.s, 0, 1)
				out.finish.v = math.clamp(tonumber(raw.finish.v) or out.finish.v, 0, 1)
			end
			return out
		end

		PT.data = normalizePlexData(data)
		local plexSaveSeq = 0

		const function savePlexData(opts)
			if not FileSupport then
				return
			end
			opts = opts or {}
			plexSaveSeq += 1
			const seq = plexSaveSeq
			const function writePlexData()
				pcall(function()
					writefile(PT.path, Services.HttpService:JSONEncode(PT.data))
				end)
			end
			if opts.immediate == true then
				writePlexData()
				return
			end
			Delay(0.2, function()
				if seq == plexSaveSeq then
					writePlexData()
				end
			end)
		end

		const HUI = NAlib.distinctHuiGrabber and NAlib.distinctHuiGrabber(Services.CoreGui) or nil
		const function skipCoreGuiHiddenRoot(inst)
			return HUI and inst == HUI
		end

		const function resetPlexQueue()
			PT.queueToken += 1
			PT.queue = {}
			PT.queueHead = 1
			PT.queueTail = 0
			PT.queueSet = setmetatable({}, { __mode = "k" })
			PT.processing = false
			PT.queueKickPending = false
			PT.recheckQueue = {}
			PT.recheckSet = setmetatable({}, { __mode = "k" })
			PT.recheckHead = 1
			PT.recheckTail = 0
			PT.recheckShortTail = 0
			PT.recheckShortQueued = false
			PT.recheckLongQueued = false
		end

		const function resetPlexImages()
			PT.images = setmetatable({}, { __mode = "k" })
			PT.gradients = setmetatable({}, { __mode = "k" })
		end

		const function resetPlexWatchers()
			const pending = {}
			for o, conns in PT.watchers do
				pending[#pending + 1] = { object = o, conns = conns }
			end
			for i = 1, #pending do
				const conns = pending[i].conns
				if type(conns) == "table" then
					for j = 1, #conns do
						const c = conns[j]
						if c then
							pcall(function()
								c:Disconnect()
							end)
						end
					end
				end
			end
			PT.watchers = setmetatable({}, { __mode = "k" })
		end

		const function getPlexGradientSequence()
			const start = PT.data.start or PT.default.start
			const finish = PT.data.finish or PT.default.finish
			const sh = math.clamp(tonumber(start.h) or PT.default.start.h, 0, 1)
			const ss = math.clamp(tonumber(start.s) or PT.default.start.s, 0, 1)
			const sv = math.clamp(tonumber(start.v) or PT.default.start.v, 0, 1)
			const fh = math.clamp(tonumber(finish.h) or PT.default.finish.h, 0, 1)
			const fs = math.clamp(tonumber(finish.s) or PT.default.finish.s, 0, 1)
			const fv = math.clamp(tonumber(finish.v) or PT.default.finish.v, 0, 1)
			const key = Format("%.5f:%.5f:%.5f|%.5f:%.5f:%.5f",
				sh,
				ss,
				sv,
				fh,
				fs,
				fv
			)
			if PT.gradientSeqKey ~= key then
				PT.gradientSeqKey = key
				PT.gradientSeq = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromHSV(sh, ss, sv)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(fh, fs, fv)),
				}
			end
			return PT.gradientSeq
		end

		const function isPlexImage(o)
			return o and (o:IsA("ImageLabel") or o:IsA("ImageButton"))
		end

		const function isPlexText(o)
			return o and (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox"))
		end

		const function isPlexTarget(o)
			if not (o and o.Parent) then
				return false
			end
			if not (isPlexImage(o) or isPlexText(o)) then
				return false
			end
			if HUI and o:IsDescendantOf(HUI) then
				return false
			end
			return true
		end

		const function isPlexCandidate(o)
			if not (o and (isPlexImage(o) or isPlexText(o))) then
				return false
			end
			if HUI and (o == HUI or o:IsDescendantOf(HUI)) then
				return false
			end
			return true
		end

		const function getImageId(o)
			local value = NAlib.isProperty(o, "Image")
			if type(value) == "string" and value ~= "" then
				return value
			end
			value = NAlib.isProperty(o, "Texture")
			if type(value) == "string" and value ~= "" then
				return value
			end
			value = NAlib.isProperty(o, "TextureId")
			if type(value) == "string" and value ~= "" then
				return value
			end
			return nil
		end

		const function isPlexIconImage(o, imgId)
			if type(imgId) ~= "string" or imgId == "" then
				return false
			end
			const low = imgId:lower()
			if low:match("img_set_%dx_%d+%.png$") then
				return true
			end
			if low:find("rbxasset://textures/ui/", 1, true) or low:find("rbxasset://textures/topbar/", 1, true) then
				return true
			end
			local okRect, rect = pcall(function()
				return o.ImageRectSize
			end)
			if okRect and typeof(rect) == "Vector2" and (rect.X > 0 or rect.Y > 0) then
				return true
			end
			local okSize, size = pcall(function()
				return o.AbsoluteSize
			end)
			if okSize and typeof(size) == "Vector2" and size.X <= 120 and size.Y <= 120 then
				return true
			end
			const name = tostring(o.Name or ""):lower()
			return name:find("icon", 1, true) ~= nil or name:find("glyph", 1, true) ~= nil
		end

		local installPlexWatcher

		const function applyIfReady(o)
			if not (PT.data.enabled and o and o.Parent) then
				return false
			end

			if PT.images[o] then
				if HUI and o:IsDescendantOf(HUI) then
					return false
				end
				if installPlexWatcher then
					installPlexWatcher(o)
				end
				NAmanage.plex_apply(o)
				return true
			end

			if not isPlexTarget(o) then
				return false
			end

			const imgId = getImageId(o)
			if isPlexImage(o) and isPlexIconImage(o, imgId) then
				PT.images[o] = true
				if installPlexWatcher then
					installPlexWatcher(o)
				end
				NAmanage.plex_apply(o)
				return true
			end

			if isPlexText(o) then
				const ff = NAlib.isProperty(o, "FontFace")
				const ffType = ff and typeof(ff) or nil
				const fam = ff and ff.Family or nil

				if (ffType == "Font" or ffType == "FontFace")
					and type(fam) == "string"
					and fam:find("BuilderIcons/BuilderIcons.json", 1, true)
				then
					PT.images[o] = true
					if installPlexWatcher then
						installPlexWatcher(o)
					end
					NAmanage.plex_apply(o)
					return true
				end
			end

			return false
		end

		NAmanage.plex_remove = function(o)
			if not o then
				return
			end
			PT.queueSet[o] = nil
			const cached = PT.gradients and PT.gradients[o] or nil
			if cached and cached.Parent == o and cached.Name == "PlexityGradient" and cached:IsA("UIGradient") then
				pcall(function()
					cached:Destroy()
				end)
				PT.gradients[o] = nil
				return
			end
			local okChildren, children = pcall(function()
				return o:GetChildren()
			end)
			if not (okChildren and type(children) == "table") then
				return
			end
			for i = 1, #children do
				const g = children[i]
				if g and g.Name == "PlexityGradient" and g:IsA("UIGradient") then
					pcall(function()
						g:Destroy()
					end)
				end
			end
			if PT.gradients then
				PT.gradients[o] = nil
			end
		end

		NAmanage.plex_apply = function(o)
			if not (o and o.Parent) then
				return
			end
			if HUI and o:IsDescendantOf(HUI) then
				return
			end
			if isPlexTarget(o) then
				PT.images[o] = true
			end
			if PT.data.enabled then
				const seq = getPlexGradientSequence()
				const trans = PT.gradientTrans
				local ug = PT.gradients and PT.gradients[o] or nil
				if not (ug and ug.Parent == o and ug:IsA("UIGradient")) then
					ug = o:FindFirstChild("PlexityGradient")
					if not (ug and ug:IsA("UIGradient")) then
						if ug then
							pcall(function()
								ug:Destroy()
							end)
						end
						ug = InstanceNew("UIGradient")
						ug.Name = "PlexityGradient"
						pcall(function()
							ug:SetAttribute("NamelessAdminPlexity", true)
						end)
						NAlib.setProperty(ug, "Color", seq)
						NAlib.setProperty(ug, "Rotation", 45)
						NAlib.setProperty(ug, "Transparency", trans)
						ug.Parent = o
						if PT.gradients then
							PT.gradients[o] = ug
						end
						return
					end
					if PT.gradients then
						PT.gradients[o] = ug
					end
				end
				NAlib.setProperty(ug, "Color", seq)
				NAlib.setProperty(ug, "Rotation", 45)
				NAlib.setProperty(ug, "Transparency", trans)
			else
				NAmanage.plex_remove(o)
			end
		end

		local enqueue
		local scheduleQueueProcess

		installPlexWatcher = function(o)
			if not (o and o.Parent and isPlexCandidate(o)) then
				return
			end
			if PT.watchers[o] then
				return
			end
			const conns = {}
			const function bump()
				if not (PT.data.enabled and o and o.Parent) then
					return
				end
				enqueue(o)
				scheduleQueueProcess()
			end
			const function hook(prop)
				local ok, sig = pcall(function()
					return o:GetPropertyChangedSignal(prop)
				end)
				if ok and sig then
					const c = NAmanage.safeConnect(sig, bump)
					if c then
						conns[#conns + 1] = c
					end
				end
			end
			if isPlexImage(o) then
				hook("Image")
				hook("ImageRectSize")
				hook("AbsoluteSize")
			else
				hook("FontFace")
			end
			const anc = NAmanage.safeConnect(o.AncestryChanged, function(_, parent)
				if parent then
					return
				end
				const list = PT.watchers[o]
				if type(list) == "table" then
					for i = 1, #list do
						const c = list[i]
						if c then
							pcall(function()
								c:Disconnect()
							end)
						end
					end
				end
				PT.watchers[o] = nil
				PT.images[o] = nil
				PT.queueSet[o] = nil
				const list = PT.watchers[o]
				if type(list) == "table" then
					for i = 1, #list do
						const c = list[i]
						if c then pcall(function() c:Disconnect() end) end
					end
				end
				PT.watchers[o] = nil
			end)
			if anc then
				conns[#conns + 1] = anc
			end
			PT.watchers[o] = conns
		end

		enqueue = function(o)
			if not (PT.data.enabled and o and o.Parent) then
				return
			end
			if PT.cg and not o:IsDescendantOf(PT.cg) then
				return
			end
			if not isPlexCandidate(o) then
				return
			end
			if PT.queueSet[o] then
				return
			end
			if HUI and o:IsDescendantOf(HUI) then
				return
			end
			PT.queueSet[o] = true
			PT.queueTail += 1
			PT.queue[PT.queueTail] = o
		end

		const function processQueue()
			if PT.processing then
				return
			end
			PT.processing = true
			const token = PT.queueToken
			NAmanage.Wrap(function()
				while token == PT.queueToken and PT.data.enabled and PT.queueHead <= PT.queueTail do
					local budget, waitDelay = NAmanage._evtHubBudget(8, {
						delay = 0,
						ldSc = 0.25,
						ldDel = 0.012,
					})
					while budget > 0 and token == PT.queueToken and PT.data.enabled and PT.queueHead <= PT.queueTail do
						const o = PT.queue[PT.queueHead]
						PT.queue[PT.queueHead] = nil
						PT.queueHead += 1
						if o then
							PT.queueSet[o] = nil
							if o.Parent and PT.data.enabled then
								applyIfReady(o)
							end
						end
						budget -= 1
					end
					if waitDelay > 0 then
						Wait(waitDelay)
					else
						Wait()
					end
				end
				if token == PT.queueToken then
					PT.queue = {}
					PT.queueHead = 1
					PT.queueTail = 0
					PT.queueSet = setmetatable({}, { __mode = "k" })
					PT.processing = false
					PT.queueKickPending = false
				end
			end)()
		end

		scheduleQueueProcess = function()
			if PT.queueKickPending then
				return
			end
			PT.queueKickPending = true
			Defer(function()
				PT.queueKickPending = false
				processQueue()
			end)
		end

		NAmanage.plex_add = function(o)
			enqueue(o)
			scheduleQueueProcess()
		end

		NAmanage.plex_applyAll = function()
			if not PT.data.enabled then
				PT.needApplyAll = false
				return
			end
			if PT.applying then
				PT.needApplyAll = true
				return
			end
			PT.applying = true
			PT.needApplyAll = false
			PT.applyAllSeq += 1
			const seq = PT.applyAllSeq

			NAmanage.Wrap(function()
				const cg = PT.cg
				if cg and PT.data.enabled and seq == PT.applyAllSeq then
					NAmanage.ForEachDescendantYield(cg, function(o)
						if not (PT.data.enabled and seq == PT.applyAllSeq) then
							return
						end
						if o and o.Parent then
							applyIfReady(o)
						end
					end, {
						yieldEvery = coreCustomizerBatch,
						delayTime = 0,
						skipChildren = skipCoreGuiHiddenRoot,
					})
				end
				PT.applying = false
				if PT.needApplyAll then
					NAmanage.plex_applyAll()
				end
			end)()
		end

		PT.scheduleTrackedPlexApply = function()
			if not PT.data.enabled or PT.trackedApplyQueued then
				return
			end
			PT.trackedApplyQueued = true
			Delay(0.05, function()
				PT.trackedApplyQueued = false
				if not PT.data.enabled then
					return
				end
				local count = 0
				for o in PT.images do
					if o and o.Parent then
						NAmanage.plex_apply(o)
						count += 1
						if count % 24 == 0 then
							Wait()
						end
					else
						PT.images[o] = nil
					end
				end
			end)
		end

		PT.rescanAll = function()
			if PT.rescanning then
				PT.rescanAgain = true
				return
			end
			PT.rescanning = true
			NAmanage.Wrap(function()
				repeat
					PT.rescanAgain = false
					const cg = PT.cg
					if cg and PT.data.enabled then
						NAmanage.ForEachDescendantYield(cg, function(inst)
							if not PT.data.enabled then
								return
							end
							enqueue(inst)
						end, {
							yieldEvery = coreCustomizerBatch,
							delayTime = 0,
							skipChildren = skipCoreGuiHiddenRoot,
						})
						processQueue()
					end
				until not (PT.data.enabled and PT.rescanAgain)
				PT.rescanning = false
			end)()
		end

		const function drainPlexRecheck(clearAfter)
			const tail = PT.recheckTail
			const head = clearAfter and PT.recheckHead or ((PT.recheckShortTail or 0) + 1)
			for i = head, tail do
				const o = PT.recheckQueue[i]
				if o and o.Parent and PT.data.enabled then
					enqueue(o)
				end
			end
			scheduleQueueProcess()
			if clearAfter then
				PT.recheckQueue = {}
				PT.recheckSet = setmetatable({}, { __mode = "k" })
				PT.recheckHead = 1
				PT.recheckTail = 0
				PT.recheckShortTail = 0
				PT.recheckLongQueued = false
			else
				PT.recheckShortTail = math.max(PT.recheckShortTail or 0, tail)
				PT.recheckShortQueued = false
			end
		end

		const function schedulePlexRecheck(o)
			if not (PT.data.enabled and o and o.Parent) then
				return
			end
			if not PT.recheckSet[o] then
				PT.recheckSet[o] = true
				PT.recheckTail += 1
				PT.recheckQueue[PT.recheckTail] = o
			end
			if not PT.recheckShortQueued then
				PT.recheckShortQueued = true
				Delay(0.05, function()
					if PT.data.enabled then
						drainPlexRecheck(false)
					else
						PT.recheckShortQueued = false
					end
				end)
			end
			if not PT.recheckLongQueued then
				PT.recheckLongQueued = true
				Delay(0.25, function()
					if PT.data.enabled then
						drainPlexRecheck(true)
					else
						PT.recheckQueue = {}
						PT.recheckSet = setmetatable({}, { __mode = "k" })
						PT.recheckHead = 1
						PT.recheckTail = 0
						PT.recheckShortTail = 0
						PT.recheckShortQueued = false
						PT.recheckLongQueued = false
					end
				end)
			end
		end

		PT.onDescendantAdded = function(o)
			if not PT.data.enabled then
				return
			end
			enqueue(o)
			scheduleQueueProcess()
			schedulePlexRecheck(o)
		end

		PT.setPlexW = function(on)
			NAlib.disconnect("PlexyDescAdded")
			NAlib.disconnect("PlexyDescRemoving")
			if not on or not PT.cg then
				return
			end
			NAlib.connect("PlexyDescAdded", NAmanage.descSub(PT.cg, {
				added = PT.onDescendantAdded,
				filterAdded = isPlexCandidate,
				classNames = { "ImageLabel", "ImageButton", "TextLabel", "TextButton", "TextBox" },
			}))
			NAlib.connect("PlexyDescRemoving", NAmanage.descSub(PT.cg, {
				removing = function(o)
					PT.images[o] = nil
					PT.queueSet[o] = nil
					if PT.gradients then
						PT.gradients[o] = nil
					end
				end,
				filterRemoving = function(o)
					return PT.images[o] == true or PT.queueSet[o] == true
				end,
				classNames = { "ImageLabel", "ImageButton", "TextLabel", "TextButton", "TextBox" },
			}))
		end

		NAmanage.PlexityThemeUnload = function()
			PT.data.enabled = false
			PT.applyAllSeq += 1
			PT.needApplyAll = false
			PT.rescanAgain = false
			PT.setPlexW(false)
			resetPlexQueue()
			resetPlexWatchers()
			const targets = {}
			const targetSet = setmetatable({}, { __mode = "k" })
			for target in PT.images do
				if target and not targetSet[target] then
					targetSet[target] = true
					targets[#targets + 1] = target
				end
			end
			for target in PT.gradients do
				if target and not targetSet[target] then
					targetSet[target] = true
					targets[#targets + 1] = target
				end
			end
			for i = 1, #targets do
				NAmanage.plex_remove(targets[i])
			end
			const cg = PT.cg
			if cg then
				local ok, descendants = pcall(function()
					return cg:GetDescendants()
				end)
				if ok and type(descendants) == "table" then
					for i = 1, #descendants do
						const object = descendants[i]
						if object and object:IsA("UIGradient") and object.Name == "PlexityGradient" then
							pcall(function()
								object:Destroy()
							end)
						end
					end
				end
			end
			resetPlexImages()
		end

		if PT.data.enabled then
			PT.setPlexW(true)
			Defer(function()
				if not PT.data.enabled then
					return
				end
				for _, rootName in { "TopBarApp", "ExperienceChat", "RobloxGui" } do
					const root = PT.cg and PT.cg:FindFirstChild(rootName)
					if root then
						local okList, list = pcall(root.GetDescendants, root)
						if okList and type(list) == "table" then
							for i = 1, #list do
								const object = list[i]
								if isPlexCandidate(object) then
									applyIfReady(object)
								end
							end
						end
					end
				end
				PT.rescanAll()
			end)
		else
			PT.setPlexW(false)
		end

		NAgui.addSection("Plexity Theme")
		NAgui.addToggle("Enable Theme", PT.data.enabled, function(v)
			PT.data.enabled = v
			if v then
				PT.setPlexW(true)
				PT.rescanAll()
			else
				PT.setPlexW(false)
				PT.applyAllSeq += 1
				PT.needApplyAll = false
				resetPlexQueue()
				resetPlexWatchers()
				const cg = PT.cg
				if cg then
					NAmanage.ForEachDescendantYield(cg, function(inst)
						NAmanage.plex_remove(inst)
					end, {
						yieldEvery = coreCustomizerBatch,
						delayTime = 0,
						skipChildren = skipCoreGuiHiddenRoot,
					})
				end
				resetPlexImages()
			end
			savePlexData({ immediate = true })
		end)

		NAgui.addColorPicker("Gradient Start Color", Color3.fromHSV(PT.data.start.h, PT.data.start.s, PT.data.start.v), function(c)
			local h, s, v = c:ToHSV()
			PT.data.start.h, PT.data.start.s, PT.data.start.v = h, s, v
			PT.gradientSeqKey = nil
			if PT.data.enabled then
				PT.scheduleTrackedPlexApply()
			end
			savePlexData()
		end)

		NAgui.addColorPicker("Gradient End Color", Color3.fromHSV(PT.data.finish.h, PT.data.finish.s, PT.data.finish.v), function(c)
			local h, s, v = c:ToHSV()
			PT.data.finish.h, PT.data.finish.s, PT.data.finish.v = h, s, v
			PT.gradientSeqKey = nil
			if PT.data.enabled then
				PT.scheduleTrackedPlexApply()
			end
			savePlexData()
		end)

		const function initBuilderIconEditor()
			const BuilderIconEditor = {
				path = NAfiles.NAFILEPATH.."/BuilderIconsEditor.json",
				default = {
					enabled = false,
					overrides = {},
				},
				data = {
					enabled = false,
					overrides = {},
				},
				entries = {},
				entryPaths = {},
				entryInstSet = setmetatable({}, { __mode = "k" }),
				liveTargets = {},
				selectedLabel = "None",
				selectedDisplay = "None",
				selectedPath = nil,
				selectedInst = nil,
				pendingText = "",
				originalText = {},
				refreshQueued = false,
				reapplyQueued = false,
				catalogUrl = "https://raw.githubusercontent.com/ltseverydayyou/ltseverydayyou.github.io/refs/heads/main/.well-known/buildericons/icons.json",
				catalogPlaceholder = "Select BuilderIcon",
				catalogLoadingLabel = "Loading BuilderIcons...",
				catalogEntries = {},
				catalogOptions = {},
				catalogLookupByText = {},
				catalogLookupByStyle = {
					regular = {},
					filled = {},
				},
				catalogLoading = false,
				catalogLoaded = false,
				catalogError = nil,
				selectedIconLabel = "Select BuilderIcon",
				watchersEnabled = false,
				refreshToken = 0,
				reapplyToken = 0,
				catalogFetchToken = 0,
				overrideLeafs = {},
			}
			BuilderIconEditor.originalText = setmetatable(BuilderIconEditor.originalText, {
				__mode = "k",
			})
			BuilderIconEditor.liveTargets = setmetatable(BuilderIconEditor.liveTargets, {
				__mode = "k",
			})
			const builderIconDropdownLabel = "BuilderIcon Target"
			const builderIconInputLabel = "Custom BuilderIcon"

			const function isBuilderIconTarget(o)
				if not (o and o.Parent) then
					return false
				end
				if not (o:IsA("TextLabel") or o:IsA("TextButton")) then
					return false
				end
				if HUI and o:IsDescendantOf(HUI) then
					return false
				end
				const ff = NAlib.isProperty(o, "FontFace")
				const ffType = ff and typeof(ff) or nil
				const family = ff and ff.Family or nil
				return (ffType == "Font" or ffType == "FontFace")
					and type(family) == "string"
					and family:find("BuilderIcons/BuilderIcons.json", 1, true) ~= nil
			end

			const function isBuilderIconCandidate(o)
				if not (o and (o:IsA("TextLabel") or o:IsA("TextButton"))) then
					return false
				end
				if HUI and (o == HUI or o:IsDescendantOf(HUI)) then
					return false
				end
				return true
			end

			const function getBuilderIconSelectionValue(selection)
				local value = selection
				if type(value) == "table" then
					value = value[1]
				end
				if type(value) ~= "string" then
					return nil
				end
				value = value:match("^%s*(.-)%s*$")
				if not value or value == "" or Lower(value) == "none" then
					return nil
				end
				return value
			end

			const function getBuilderIconText(inst)
				const text = NAlib.isProperty(inst, "Text")
				if type(text) ~= "string" then
					return ""
				end
				return text
			end

			local resolveBuilderIconDisplayText
			local findBuilderIconCatalogLabelByText
			local getBuilderIconTextTokenForEntry

			const function getBuilderIconPreviewText(text)
				text = tostring(text or "")
				text = text:gsub("[\r\n\t]", " ")
				if text == "" then
					return "<empty>"
				end
				if #text > 14 then
					return text:sub(1, 14) .. "..."
				end
				return text
			end

			const function getBuilderIconPath(inst)
				const RawCoreGui = __lt.gs("CoreGui")
				const parts = {}
				local current = inst
				local depth = 0
				while current and depth < 64 do
					if current == RawCoreGui then
						break
					end
					Insert(parts, 1, tostring(current.Name or current.ClassName))
					current = current.Parent
					depth += 1
				end
				return Concat(parts, "/")
			end

			const function normalizeBuilderIconOverridePath(path)
				if type(path) ~= "string" or path == "" then
					return nil
				end
				const trimmed = path:match("^%s*(.-)%s*$")
				if not trimmed or trimmed == "" then
					return nil
				end
				const suffix = trimmed:match("CoreGui/(.+)$")
				if type(suffix) == "string" and suffix ~= "" then
					return suffix
				end
				return trimmed
			end

			const function rebuildBuilderIconOverrideLeafs()
				const leafs = {}
				const overrides = BuilderIconEditor.data and BuilderIconEditor.data.overrides
				if type(overrides) == "table" then
					for path in overrides do
						const normalized = normalizeBuilderIconOverridePath(path)
						const leaf = type(normalized) == "string" and normalized:match("([^/]+)$") or nil
						if type(leaf) == "string" and leaf ~= "" then
							leafs[leaf] = true
						end
					end
				end
				BuilderIconEditor.overrideLeafs = leafs
			end

			const function makeBuilderIconLabel(inst)
				const currentText = getBuilderIconText(inst)
				local originalText = BuilderIconEditor.originalText[inst]
				if type(originalText) ~= "string" or originalText == "" then
					originalText = currentText
				end
				const originalDisplay = resolveBuilderIconDisplayText and resolveBuilderIconDisplayText(originalText) or getBuilderIconPreviewText(originalText)
				if currentText ~= originalText then
					const modifiedDisplay = resolveBuilderIconDisplayText and resolveBuilderIconDisplayText(currentText) or getBuilderIconPreviewText(currentText)
					return Format("%s | %s | %s", originalDisplay, modifiedDisplay, getBuilderIconPath(inst))
				end
				return Format("%s | %s", originalDisplay, getBuilderIconPath(inst))
			end

			const function isTrackedBuilderIconTarget(o)
				if o == BuilderIconEditor.selectedInst then
					return true
				end
				if BuilderIconEditor.originalText[o] ~= nil then
					return true
				end
				if BuilderIconEditor.entryInstSet[o] == true then
					return true
				end
				return false
			end

			const function normalizeBuilderIconData(raw)
				const out = {
					enabled = false,
					overrides = {},
				}
				if type(raw) ~= "table" then
					return out
				end
				if type(raw.enabled) == "boolean" then
					out.enabled = raw.enabled
				end
				const overrides = raw.overrides
				if type(overrides) == "table" then
					for path, text in overrides do
						const normalizedPath = normalizeBuilderIconOverridePath(path)
						if type(normalizedPath) == "string" and normalizedPath ~= "" and type(text) == "string" then
							out.overrides[normalizedPath] = text
						end
					end
				end
				return out
			end

			const function saveBuilderIconData()
				if not FileSupport then
					rebuildBuilderIconOverrideLeafs()
					return
				end
				pcall(function()
					writefile(BuilderIconEditor.path, Services.HttpService:JSONEncode(BuilderIconEditor.data))
				end)
			end

			const function loadBuilderIconData()
				BuilderIconEditor.data = normalizeBuilderIconData(BuilderIconEditor.default)
				if not FileSupport then
					return
				end
				if not isfile(BuilderIconEditor.path) then
					rebuildBuilderIconOverrideLeafs()
					saveBuilderIconData()
					return
				end
				local okRead, raw = pcall(readfile, BuilderIconEditor.path)
				if not okRead or type(raw) ~= "string" or raw == "" then
					saveBuilderIconData()
					return
				end
				local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
				if okDecode then
					BuilderIconEditor.data = normalizeBuilderIconData(decoded)
					rebuildBuilderIconOverrideLeafs()
				else
					saveBuilderIconData()
				end
			end

			const function getSavedBuilderIconTextForPath(path)
				path = normalizeBuilderIconOverridePath(path)
				if type(path) ~= "string" or path == "" then
					return nil
				end
				const overrides = BuilderIconEditor.data and BuilderIconEditor.data.overrides
				if type(overrides) ~= "table" then
					return nil
				end
				const value = overrides[path]
				if type(value) ~= "string" then
					return nil
				end
				return value
			end

			const function setSavedBuilderIconOverride(path, text)
				path = normalizeBuilderIconOverridePath(path)
				if type(path) ~= "string" or path == "" then
					return
				end
				BuilderIconEditor.data.overrides[path] = tostring(text or "")
				rebuildBuilderIconOverrideLeafs()
				saveBuilderIconData()
			end

			const function clearSavedBuilderIconOverride(path)
				path = normalizeBuilderIconOverridePath(path)
				if type(path) ~= "string" or path == "" then
					return
				end
				if BuilderIconEditor.data.overrides[path] == nil then
					return
				end
				BuilderIconEditor.data.overrides[path] = nil
				rebuildBuilderIconOverrideLeafs()
				saveBuilderIconData()
			end

			const function clearAllSavedBuilderIconOverrides()
				BuilderIconEditor.data.overrides = {}
				rebuildBuilderIconOverrideLeafs()
				saveBuilderIconData()
			end

			const function hasSavedBuilderIconOverrides()
				return type(BuilderIconEditor.data) == "table"
					and type(BuilderIconEditor.data.overrides) == "table"
					and next(BuilderIconEditor.data.overrides) ~= nil
			end

			const function restoreAppliedBuilderIconOverrides()
				local restoredAny = false
				for inst, original in BuilderIconEditor.originalText do
					if type(original) == "string" and inst and inst.Parent and isBuilderIconTarget(inst) then
						if getBuilderIconText(inst) ~= original then
							pcall(function()
								inst.Text = original
							end)
							restoredAny = true
						end
					end
				end
				return restoredAny
			end

			const function applySavedBuilderIconOverrideToInstance(inst)
				if BuilderIconEditor.data.enabled ~= true then
					return false
				end
				if not isBuilderIconTarget(inst) then
					return false
				end
				const path = getBuilderIconPath(inst)
				const savedText = getSavedBuilderIconTextForPath(path)
				if type(savedText) ~= "string" then
					return false
				end
				if BuilderIconEditor.originalText[inst] == nil then
					BuilderIconEditor.originalText[inst] = getBuilderIconText(inst)
				end
				if getBuilderIconText(inst) ~= savedText then
					pcall(function()
						inst.Text = savedText
					end)
				end
				return true
			end

			const function applySavedBuilderIconOverrides()
				if BuilderIconEditor.data.enabled ~= true then
					return false, false
				end
				if not hasSavedBuilderIconOverrides() then
					return false, false
				end
				local foundAny = false
				local appliedAny = false
				NAmanage.ForEachDescendantYield(Services.CoreGui, function(inst)
					if isBuilderIconTarget(inst) then
						const path = getBuilderIconPath(inst)
						if getSavedBuilderIconTextForPath(path) ~= nil then
							foundAny = true
							if applySavedBuilderIconOverrideToInstance(inst) then
								appliedAny = true
							end
						end
					end
				end, {
					yieldEvery = coreCustomizerBatch,
					delayTime = 0,
					skipChildren = skipCoreGuiHiddenRoot,
				})
				return foundAny, appliedAny
			end

			const function hasPendingSavedBuilderIconPaths()
				if BuilderIconEditor.data.enabled ~= true then
					return false
				end
				if not hasSavedBuilderIconOverrides() then
					return false
				end
				const foundPaths = {}
				NAmanage.ForEachDescendantYield(Services.CoreGui, function(inst)
					if isBuilderIconTarget(inst) then
						const path = normalizeBuilderIconOverridePath(getBuilderIconPath(inst))
						if type(path) == "string" and path ~= "" then
							foundPaths[path] = true
						end
					end
				end, {
					yieldEvery = coreCustomizerBatch,
					delayTime = 0,
					skipChildren = skipCoreGuiHiddenRoot,
				})
				for path in BuilderIconEditor.data.overrides do
					if not foundPaths[path] then
						return true
					end
				end
				return false
			end

			local refreshBuilderIconDropdown
			local queueBuilderIconRefresh

			const function collectBuilderIconLiveTargets()
				const found = {}
				const seen = {}
				for inst in BuilderIconEditor.liveTargets do
					if isBuilderIconTarget(inst) and not seen[inst] then
						seen[inst] = true
						found[#found + 1] = inst
					else
						BuilderIconEditor.liveTargets[inst] = nil
					end
				end
				return found
			end

			const function queueSavedBuilderIconReapply(opts)
				opts = opts or {}
				if BuilderIconEditor.data.enabled ~= true or not hasSavedBuilderIconOverrides() then
					return
				end
				BuilderIconEditor.reapplyToken += 1
				const token = BuilderIconEditor.reapplyToken
				if BuilderIconEditor.reapplyQueued then
					return
				end
				BuilderIconEditor.reapplyQueued = true
				Delay(opts.delay or 0.35, function()
					if token ~= BuilderIconEditor.reapplyToken or BuilderIconEditor.data.enabled ~= true then
						BuilderIconEditor.reapplyQueued = false
						return
					end
					BuilderIconEditor.reapplyQueued = false
					local _, appliedAny = applySavedBuilderIconOverrides()
					if appliedAny and opts.refreshDropdown == true and NAgui and NAgui._dropdownRegistry and NAgui._dropdownRegistry[builderIconDropdownLabel] then
						queueBuilderIconRefresh({
							delay = 1.25,
						})
					end
				end)
			end

			const function getBuilderIconCatalogSelectionValue(selection)
				local value = selection
				if type(value) == "table" then
					value = value[1]
				end
				if type(value) ~= "string" then
					return nil
				end
				value = value:match("^%s*(.-)%s*$")
				if not value or value == "" then
					return nil
				end
				if value == BuilderIconEditor.catalogPlaceholder or value == BuilderIconEditor.catalogLoadingLabel then
					return nil
				end
				return value
			end

			const function normalizeBuilderIconCatalog(raw)
				local catalog = raw
				if type(raw) == "table" and type(raw.icons) == "table" then
					catalog = raw.icons
				end
				if type(catalog) ~= "table" then
					return {}
				end

				const sourceEntries = {}
				if #catalog > 0 then
					for _, entry in catalog do
						sourceEntries[#sourceEntries + 1] = entry
					end
				else
					for _, entry in catalog do
						if type(entry) == "table" then
							sourceEntries[#sourceEntries + 1] = entry
						end
					end
				end

				const out = {}
				for _, entry in sourceEntries do
					if type(entry) == "table" then
						const name = entry.name or entry.label or entry.components
						const styles = {}
						if type(entry.styles) == "table" then
							for _, styleName in { "regular", "filled" } do
								const styleEntry = entry.styles[styleName]
								if type(styleEntry) == "table" then
									const character = styleEntry.character or styleEntry.glyph or styleEntry.text
									if type(character) == "string" and character ~= "" then
										styles[styleName] = character
									end
								elseif type(styleEntry) == "string" and styleEntry ~= "" then
									styles[styleName] = styleEntry
								end
							end
						end
						if type(name) == "string" and name ~= "" and next(styles) ~= nil then
							out[#out + 1] = {
								name = name,
								components = type(entry.components) == "string" and entry.components or name,
								styles = styles,
							}
						end
					end
				end

				table.sort(out, function(a, b)
					const left = Lower(a.name or a.components or "")
					const right = Lower(b.name or b.components or "")
					if left == right then
						return tostring(a.components or "") < tostring(b.components or "")
					end
					return left < right
				end)

				return out
			end

			const function escapeBuilderIconRichText(text)
				text = tostring(text or "")
				text = text:gsub("&", "&amp;")
				text = text:gsub("<", "&lt;")
				text = text:gsub(">", "&gt;")
				text = text:gsub('"', "&quot;")
				text = text:gsub("'", "&apos;")
				return text
			end

			const function getBuilderIconCatalogEntryByText(text)
				const matched = findBuilderIconCatalogLabelByText(text)
				if type(matched) ~= "string" or matched == "" then
					return nil
				end
				const entry = BuilderIconEditor.catalogEntries and BuilderIconEditor.catalogEntries[matched]
				if type(entry) ~= "table" then
					return nil
				end
				return entry
			end

			const function makeBuilderIconRichSegment(text)
				const entry = getBuilderIconCatalogEntryByText(text)
				if type(entry) == "table" then
					const token = getBuilderIconTextTokenForEntry(entry)
					if type(token) == "string" and token ~= "" then
						return Format(
							'<font family="rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json">%s</font>',
							escapeBuilderIconRichText(token)
						)
					end
				end
				const preview = resolveBuilderIconDisplayText and resolveBuilderIconDisplayText(text) or getBuilderIconPreviewText(text)
				return escapeBuilderIconRichText(preview)
			end

			const function makeBuilderIconDisplayLabel(inst)
				const currentText = getBuilderIconText(inst)
				local originalText = BuilderIconEditor.originalText[inst]
				if type(originalText) ~= "string" or originalText == "" then
					originalText = currentText
				end
				const pathDisplay = escapeBuilderIconRichText(getBuilderIconPath(inst))
				const originalDisplay = makeBuilderIconRichSegment(originalText)
				if currentText ~= originalText then
					const modifiedDisplay = makeBuilderIconRichSegment(currentText)
					return Format("%s | %s | %s", originalDisplay, modifiedDisplay, pathDisplay)
				end
				return Format("%s | %s", originalDisplay, pathDisplay)
			end

			const function rebuildBuilderIconCatalog(entries)
				const options = {}
				const catalogEntries = {}
				const lookupByText = {}
				const lookupByStyle = {
					regular = {},
					filled = {},
				}
				const labelCount = {}

				for _, entry in entries do
					const baseLabel = entry.name or entry.components or "BuilderIcon"
					labelCount[baseLabel] = (labelCount[baseLabel] or 0) + 1
					local label = baseLabel
					if labelCount[baseLabel] > 1 then
						label = baseLabel .. " #" .. tostring(labelCount[baseLabel])
					end
					entry.label = label
					catalogEntries[label] = entry
					if type(entry.components) == "string" and entry.components ~= "" then
						lookupByText[entry.components] = label
					end
					if type(entry.name) == "string" and entry.name ~= "" then
						lookupByText[entry.name] = label
					end
					const token = type(entry.components) == "string" and entry.components ~= "" and entry.components or baseLabel
					const richDisplay = Format(
						'<font family="rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json">%s</font>  %s',
						escapeBuilderIconRichText(token),
						escapeBuilderIconRichText(label)
					)
					options[#options + 1] = {
						value = label,
						display = richDisplay,
						selectedDisplay = richDisplay,
						richText = true,
					}
					for styleName, character in entry.styles or {} do
						if type(character) == "string" and character ~= "" and type(lookupByStyle[styleName]) == "table" then
							lookupByStyle[styleName][character] = label
						end
					end
				end

				BuilderIconEditor.catalogEntries = catalogEntries
				BuilderIconEditor.catalogOptions = options
				BuilderIconEditor.catalogLookupByText = lookupByText
				BuilderIconEditor.catalogLookupByStyle = lookupByStyle
				BuilderIconEditor.catalogLoaded = #entries > 0
				BuilderIconEditor.catalogError = (#entries > 0) and nil or "No BuilderIcons available."
			end

			getBuilderIconTextTokenForEntry = function(entry)
				if type(entry) ~= "table" then
					return nil
				end
				const components = entry.components
				if type(components) == "string" and components ~= "" then
					return components
				end
				const name = entry.name
				if type(name) == "string" and name ~= "" then
					return name
				end
				return nil
			end

			findBuilderIconCatalogLabelByText = function(text)
				if type(text) ~= "string" or text == "" then
					return nil
				end
				const byText = BuilderIconEditor.catalogLookupByText
				if type(byText) == "table" and byText[text] then
					return byText[text]
				end
				for label, entry in BuilderIconEditor.catalogEntries or {} do
					if type(entry) == "table" then
						if entry.components == text or entry.name == text then
							return label
						end
					end
				end
				for _, lookup in BuilderIconEditor.catalogLookupByStyle or {} do
					if type(lookup) == "table" and lookup[text] then
						return lookup[text]
					end
				end
				return nil
			end

			resolveBuilderIconDisplayText = function(text)
				const matched = findBuilderIconCatalogLabelByText(text)
				if type(matched) == "string" and matched ~= "" then
					return matched
				end
				return getBuilderIconPreviewText(text)
			end

			local syncBuilderIconInput

			const function getVisibleBuilderIconCatalogOptions()
				const selectedLabel = BuilderIconEditor.selectedIconLabel
				const visible = {}
				for _, option in BuilderIconEditor.catalogOptions or {} do
					if type(option) == "table" then
						if option.value ~= selectedLabel then
							visible[#visible + 1] = option
						end
					else
						visible[#visible + 1] = option
					end
				end
				if #visible == 0 then
					if BuilderIconEditor.catalogLoading then
						visible[1] = BuilderIconEditor.catalogLoadingLabel
					else
						visible[1] = BuilderIconEditor.catalogPlaceholder
					end
				end
				return visible
			end

			const function syncBuilderIconCatalogDropdown()
				if NAgui.setDropdownOptions then
					NAgui.setDropdownOptions(builderIconInputLabel, getVisibleBuilderIconCatalogOptions())
				end
				if syncBuilderIconInput then
					syncBuilderIconInput()
				end
			end

			const function failBuilderIconCatalog(token, msg, opts)
				if token ~= BuilderIconEditor.catalogFetchToken then
					return
				end
				BuilderIconEditor.catalogLoading = false
				BuilderIconEditor.catalogLoaded = false
				BuilderIconEditor.catalogError = msg
				BuilderIconEditor.catalogOptions = { BuilderIconEditor.catalogPlaceholder }
				syncBuilderIconCatalogDropdown()
				if opts and opts.notify ~= false then
					DoNotif(msg, 3)
				end
			end

			const function fetchBuilderIconCatalog(opts)
				opts = opts or {}
				if BuilderIconEditor.catalogLoading then
					return
				end
				BuilderIconEditor.catalogFetchToken += 1
				const token = BuilderIconEditor.catalogFetchToken
				BuilderIconEditor.catalogLoading = true
				BuilderIconEditor.catalogError = nil
				BuilderIconEditor.catalogLoaded = false
				BuilderIconEditor.catalogOptions = { BuilderIconEditor.catalogLoadingLabel }
				BuilderIconEditor.catalogEntries = {}
				BuilderIconEditor.catalogLookupByText = {}
				BuilderIconEditor.catalogLookupByStyle = {
					regular = {},
					filled = {},
				}
				syncBuilderIconCatalogDropdown()

				Delay(opts.timeout or 8, function()
					if token == BuilderIconEditor.catalogFetchToken and BuilderIconEditor.catalogLoading then
						failBuilderIconCatalog(token, "BuilderIcons catalog timed out.", opts)
						BuilderIconEditor.catalogFetchToken += 1
					end
				end)

				Spawn(function()
					local okHttp, raw = NAmanage.HttpGet(BuilderIconEditor.catalogUrl, { timeout = opts.timeout or 8, Headers = { Accept = "application/json" } })
					if token ~= BuilderIconEditor.catalogFetchToken then
						return
					end
					if not (okHttp and type(raw) == "string" and raw ~= "") then
						failBuilderIconCatalog(token, "Unable to fetch BuilderIcons catalog.", opts)
						return
					end

					local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
					if token ~= BuilderIconEditor.catalogFetchToken then
						return
					end
					if not (okDecode and type(decoded) == "table") then
						failBuilderIconCatalog(token, "Invalid BuilderIcons catalog.", opts)
						return
					end

					const entries = normalizeBuilderIconCatalog(decoded)
					if token ~= BuilderIconEditor.catalogFetchToken then
						return
					end
					BuilderIconEditor.catalogLoading = false
					rebuildBuilderIconCatalog(entries)
					if not BuilderIconEditor.catalogLoaded then
						BuilderIconEditor.catalogOptions = { BuilderIconEditor.catalogPlaceholder }
						syncBuilderIconCatalogDropdown()
						if opts.notify ~= false then
							DoNotif(BuilderIconEditor.catalogError or "No BuilderIcons available.", 3)
						end
						return
					end

					syncBuilderIconCatalogDropdown()
					if refreshBuilderIconDropdown then
						refreshBuilderIconDropdown({
							keepInstance = BuilderIconEditor.selectedInst,
							syncText = false,
						})
					end
					if opts.notify then
						DoNotif("BuilderIcon list refreshed.", 2)
					end
				end)
			end

			syncBuilderIconInput = function()
				local selectedLabel = BuilderIconEditor.catalogPlaceholder
				if BuilderIconEditor.catalogLoading then
					selectedLabel = BuilderIconEditor.catalogLoadingLabel
				elseif BuilderIconEditor.catalogLoaded then
					const matched = findBuilderIconCatalogLabelByText(BuilderIconEditor.pendingText or "")
					if type(matched) == "string" and matched ~= "" then
						selectedLabel = matched
					end
				end
				BuilderIconEditor.selectedIconLabel = selectedLabel
				if NAgui.setDropdownValue then
					NAgui.setDropdownValue(builderIconInputLabel, selectedLabel, {
						fire = false,
					})
				end
			end

			refreshBuilderIconDropdown = function(opts)
				opts = opts or {}
				const previousInst = BuilderIconEditor.selectedInst
				const previousLabel = BuilderIconEditor.selectedLabel
				const previousDisplay = BuilderIconEditor.selectedDisplay
				const previousPath = BuilderIconEditor.selectedPath
				local keepInst = opts.keepInstance
				if keepInst == nil then
					keepInst = previousInst
				end

				local found = {}
				local entries = {}
				local entryPaths = {}
				if opts.fullScan == true then
					BuilderIconEditor.liveTargets = setmetatable({}, {
						__mode = "k",
					})
					NAmanage.ForEachDescendantYield(Services.CoreGui, function(inst)
						if isBuilderIconTarget(inst) then
							BuilderIconEditor.liveTargets[inst] = true
							Insert(found, inst)
						end
					end, {
						yieldEvery = coreCustomizerBatch,
						delayTime = 0,
						skipChildren = skipCoreGuiHiddenRoot,
					})
				else
					found = collectBuilderIconLiveTargets()
				end
				table.sort(found, function(a, b)
					const aPath = getBuilderIconPath(a)
					const bPath = getBuilderIconPath(b)
					if aPath == bPath then
						return getBuilderIconText(a) < getBuilderIconText(b)
					end
					return aPath < bPath
				end)

				local labels = {}
				const labelCount = {}
				local selectedLabel = nil
				local selectedDisplay = nil
				local selectedPath = nil
				for i = 1, #found do
					const inst = found[i]
					const path = getBuilderIconPath(inst)
					const base = makeBuilderIconLabel(inst)
					const display = makeBuilderIconDisplayLabel(inst)
					labelCount[base] = (labelCount[base] or 0) + 1
					local label = base
					if labelCount[base] > 1 then
						label = base .. " #" .. tostring(labelCount[base])
					end
					entries[label] = inst
					entryPaths[label] = path
					labels[#labels + 1] = {
						value = label,
						display = display,
						selectedDisplay = display,
						richText = true,
					}
					if inst == keepInst or (keepInst == nil and type(previousPath) == "string" and previousPath ~= "" and previousPath == path) then
						selectedLabel = label
						selectedDisplay = display
						selectedPath = path
					end
				end

				const keepMissingSelection = keepInst == nil
					and type(previousPath) == "string"
					and previousPath ~= ""
					and selectedPath == nil
					and type(previousLabel) == "string"
					and previousLabel ~= ""
					and type(previousDisplay) == "string"
					and previousDisplay ~= ""

				if keepMissingSelection then
					Insert(labels, 1, {
						value = previousLabel,
						display = previousDisplay,
						selectedDisplay = previousDisplay,
						richText = true,
					})
					selectedLabel = previousLabel
					selectedDisplay = previousDisplay
					selectedPath = previousPath
					BuilderIconEditor.selectedInst = nil
					BuilderIconEditor.selectedLabel = selectedLabel
					BuilderIconEditor.selectedDisplay = selectedDisplay
					BuilderIconEditor.selectedPath = selectedPath
				elseif #labels == 0 then
					labels = { "None" }
					entries = {}
					entryPaths = {}
					selectedLabel = "None"
					selectedDisplay = "None"
					selectedPath = nil
					BuilderIconEditor.selectedInst = nil
					BuilderIconEditor.selectedLabel = selectedLabel
					BuilderIconEditor.selectedDisplay = selectedDisplay
					BuilderIconEditor.selectedPath = selectedPath
					if opts.syncText ~= false then
						BuilderIconEditor.pendingText = ""
					end
				else
					if not selectedLabel then
						const firstOption = labels[1]
						if type(firstOption) == "table" then
							selectedLabel = firstOption.value
							selectedDisplay = firstOption.selectedDisplay or firstOption.display or selectedLabel
						else
							selectedLabel = firstOption
							selectedDisplay = firstOption
						end
						BuilderIconEditor.selectedInst = entries[selectedLabel]
						selectedPath = entryPaths[selectedLabel]
					else
						BuilderIconEditor.selectedInst = entries[selectedLabel]
						selectedPath = selectedPath or entryPaths[selectedLabel]
					end
					BuilderIconEditor.selectedLabel = selectedLabel
					BuilderIconEditor.selectedDisplay = selectedDisplay or BuilderIconEditor.selectedDisplay or selectedLabel
					BuilderIconEditor.selectedPath = selectedPath
					if opts.syncText == true or BuilderIconEditor.selectedInst ~= previousInst then
						BuilderIconEditor.pendingText = BuilderIconEditor.selectedInst and getBuilderIconText(BuilderIconEditor.selectedInst) or BuilderIconEditor.pendingText
					end
				end

				BuilderIconEditor.entries = entries
				BuilderIconEditor.entryPaths = entryPaths
				BuilderIconEditor.entryInstSet = setmetatable({}, { __mode = "k" })
				for _, inst in entries do
					if inst then
						BuilderIconEditor.entryInstSet[inst] = true
					end
				end
				if NAgui.setDropdownOptions then
					NAgui.setDropdownOptions(builderIconDropdownLabel, labels)
				end
				if NAgui.setDropdownValue then
					NAgui.setDropdownValue(builderIconDropdownLabel, BuilderIconEditor.selectedLabel, {
						fire = false,
					})
				end
				if opts.syncText ~= false or BuilderIconEditor.selectedInst ~= previousInst then
					syncBuilderIconInput()
				end
			end

			loadBuilderIconData()

			queueBuilderIconRefresh = function(opts)
				opts = opts or {}
				if BuilderIconEditor.refreshQueued then
					BuilderIconEditor.refreshNeeded = true
					return
				end
				BuilderIconEditor.refreshQueued = true
				BuilderIconEditor.refreshToken += 1
				const token = BuilderIconEditor.refreshToken
				Delay(opts.delay or 2.5, function()
					if token ~= BuilderIconEditor.refreshToken then
						return
					end
					BuilderIconEditor.refreshQueued = false
					BuilderIconEditor.refreshNeeded = false
					refreshBuilderIconDropdown({
						keepInstance = BuilderIconEditor.selectedInst,
						syncText = false,
					})
				end)
			end

			const function disconnectBuilderIconWatchers()
				BuilderIconEditor.watchersEnabled = false
				BuilderIconEditor.refreshQueued = false
				BuilderIconEditor.reapplyQueued = false
				BuilderIconEditor.refreshToken += 1
				BuilderIconEditor.reapplyToken += 1
				BuilderIconEditor.liveTargets = setmetatable({}, {
					__mode = "k",
				})
				NAlib.disconnect("BuilderIconEditorAdded")
				NAlib.disconnect("BuilderIconEditorRemoving")
			end

			NAmanage.BuilderIconEditorUnload = function()
				disconnectBuilderIconWatchers()
				restoreAppliedBuilderIconOverrides()
			end

			const function connectBuilderIconWatchers()
				if BuilderIconEditor.watchersEnabled then
					return
				end
				BuilderIconEditor.watchersEnabled = true
				NAlib.disconnect("BuilderIconEditorAdded")
				NAlib.disconnect("BuilderIconEditorRemoving")
				NAlib.connect("BuilderIconEditorAdded", NAmanage.descSub(Services.CoreGui, {
					added = function(o)
						if not isBuilderIconTarget(o) then
							return
						end
						BuilderIconEditor.liveTargets[o] = true
						const path = getBuilderIconPath(o)
						applySavedBuilderIconOverrideToInstance(o)
						if type(BuilderIconEditor.selectedPath) == "string" and BuilderIconEditor.selectedPath ~= "" and BuilderIconEditor.selectedPath == path then
							BuilderIconEditor.selectedInst = o
							BuilderIconEditor.pendingText = getBuilderIconText(o)
							syncBuilderIconInput()
						end
						queueBuilderIconRefresh()
					end,
					removing = function(o)
						BuilderIconEditor.liveTargets[o] = nil
						const removedPath = isTrackedBuilderIconTarget(o) and getBuilderIconPath(o) or nil
						if o == BuilderIconEditor.selectedInst then
							BuilderIconEditor.selectedInst = nil
							if type(removedPath) == "string" and removedPath ~= "" then
								BuilderIconEditor.selectedPath = removedPath
							end
						end
						BuilderIconEditor.originalText[o] = nil
						BuilderIconEditor.entryInstSet[o] = nil
						queueBuilderIconRefresh()
					end,
					filterAdded = function(o)
						return BuilderIconEditor.data.enabled == true and isBuilderIconCandidate(o)
					end,
					filterRemoving = function(o)
						return o and (BuilderIconEditor.liveTargets[o] == true or isTrackedBuilderIconTarget(o))
					end,
					classNames = { "TextLabel", "TextButton" },
				}))
			end

			NAgui.addSection("BuilderIcon Editor")
			NAgui.addToggle("Use Modified BuilderIcons", BuilderIconEditor.data.enabled == true, function(v)
				const enabled = v == true
				if BuilderIconEditor.data.enabled == enabled then
					return
				end
				BuilderIconEditor.data.enabled = enabled
				saveBuilderIconData()
				if enabled then
					connectBuilderIconWatchers()
					refreshBuilderIconDropdown({
						syncText = true,
						fullScan = true,
					})
					if BuilderIconEditor.catalogLoaded ~= true and BuilderIconEditor.catalogLoading ~= true then
						fetchBuilderIconCatalog({
							notify = false,
							timeout = 8,
						})
					end
					queueSavedBuilderIconReapply({
						delay = 0.05,
						refreshDropdown = true,
					})
				else
					disconnectBuilderIconWatchers()
					restoreAppliedBuilderIconOverrides()
					BuilderIconEditor.pendingText = BuilderIconEditor.selectedInst and getBuilderIconText(BuilderIconEditor.selectedInst) or BuilderIconEditor.pendingText
					syncBuilderIconInput()
					refreshBuilderIconDropdown({
						keepInstance = BuilderIconEditor.selectedInst,
						syncText = true,
					})
				end
			end)
			NAgui.addDropdown(builderIconDropdownLabel, { "None" }, "None", function(selection)
				const picked = getBuilderIconSelectionValue(selection)
				const inst = picked and BuilderIconEditor.entries[picked] or nil
				if inst and inst.Parent then
					BuilderIconEditor.selectedLabel = picked
					BuilderIconEditor.selectedDisplay = makeBuilderIconDisplayLabel(inst)
					BuilderIconEditor.selectedPath = BuilderIconEditor.entryPaths[picked] or getBuilderIconPath(inst)
					BuilderIconEditor.selectedInst = inst
					BuilderIconEditor.pendingText = getBuilderIconText(inst)
					syncBuilderIconInput()
					return
				end
				refreshBuilderIconDropdown({
					syncText = true,
				})
			end)
			NAgui.addDropdown(builderIconInputLabel, { BuilderIconEditor.catalogPlaceholder }, BuilderIconEditor.catalogPlaceholder, function(selection)
				const chosen = getBuilderIconCatalogSelectionValue(selection)
				if not chosen then
					return
				end
				const entry = BuilderIconEditor.catalogEntries[chosen]
				if type(entry) ~= "table" then
					return
				end
				const token = getBuilderIconTextTokenForEntry(entry)
				if type(token) ~= "string" or token == "" then
					DoNotif("Selected BuilderIcon has no usable text token.", 3)
					syncBuilderIconInput()
					return
				end
				BuilderIconEditor.selectedIconLabel = chosen
				BuilderIconEditor.pendingText = token
			end)
			NAgui.addButton("Apply BuilderIcon", function()
				const inst = BuilderIconEditor.selectedInst
				local path = BuilderIconEditor.selectedPath
				const hasLiveInst = inst and inst.Parent and isBuilderIconTarget(inst)
				if hasLiveInst then
					path = getBuilderIconPath(inst)
				end
				if type(path) ~= "string" or path == "" then
					refreshBuilderIconDropdown({
						syncText = false,
					})
					DoNotif("Selected BuilderIcon is no longer available.", 2)
					return
				end
				if hasLiveInst and BuilderIconEditor.originalText[inst] == nil then
					BuilderIconEditor.originalText[inst] = getBuilderIconText(inst)
				end
				const newText = tostring(BuilderIconEditor.pendingText or "")
				if hasLiveInst then
					if BuilderIconEditor.data.enabled == true then
						local ok, err = pcall(function()
							inst.Text = newText
						end)
						if not ok then
							DoNotif("Failed to apply BuilderIcon: "..tostring(err), 3)
							return
						end
					end
				end
				BuilderIconEditor.selectedPath = path
				setSavedBuilderIconOverride(path, newText)
				queueSavedBuilderIconReapply({
					delay = 0.05,
					refreshDropdown = false,
				})
				refreshBuilderIconDropdown({
					keepInstance = hasLiveInst and inst or nil,
					syncText = false,
				})
				if BuilderIconEditor.data.enabled == true then
					DoNotif("BuilderIcon updated.", 2)
				else
					DoNotif("BuilderIcon saved but not active.", 2)
				end
			end)
			NAgui.addButton("Restore BuilderIcon", function()
				const inst = BuilderIconEditor.selectedInst
				if not (inst and inst.Parent and isBuilderIconTarget(inst)) then
					refreshBuilderIconDropdown({
						syncText = false,
					})
					DoNotif("Selected BuilderIcon is no longer available.", 2)
					return
				end
				const original = BuilderIconEditor.originalText[inst]
				if type(original) ~= "string" then
					DoNotif("No saved BuilderIcon text for this entry yet.", 2)
					return
				end
				const path = getBuilderIconPath(inst)
				local ok, err = pcall(function()
					inst.Text = original
				end)
				if not ok then
					DoNotif("Failed to restore BuilderIcon: "..tostring(err), 3)
					return
				end
				clearSavedBuilderIconOverride(path)
				BuilderIconEditor.pendingText = original
				syncBuilderIconInput()
				refreshBuilderIconDropdown({
					keepInstance = inst,
					syncText = false,
				})
				DoNotif("BuilderIcon restored.", 2)
			end)
			NAgui.addButton("Clear All Saved BuilderIcons", function()
				clearAllSavedBuilderIconOverrides()
				local restoredCount = 0
				for inst, original in BuilderIconEditor.originalText do
					if type(original) == "string" and inst and inst.Parent and isBuilderIconTarget(inst) then
						pcall(function()
							inst.Text = original
						end)
						restoredCount += 1
					end
				end
				BuilderIconEditor.pendingText = BuilderIconEditor.selectedInst and getBuilderIconText(BuilderIconEditor.selectedInst) or ""
				syncBuilderIconInput()
				refreshBuilderIconDropdown({
					keepInstance = BuilderIconEditor.selectedInst,
					syncText = false,
				})
				DoNotif("Cleared saved BuilderIcon overrides ("..tostring(restoredCount)..").", 2)
			end)
			NAgui.addButton("Refresh BuilderIcon List", function()
				refreshBuilderIconDropdown({
					syncText = true,
					fullScan = true,
				})
				fetchBuilderIconCatalog({
					notify = true,
					timeout = 8,
				})
			end)

			if BuilderIconEditor.data.enabled == true then
				connectBuilderIconWatchers()
				queueSavedBuilderIconReapply({
					delay = 0.02,
					refreshDropdown = false,
				})
				Defer(function()
					if BuilderIconEditor.data.enabled == true then
						refreshBuilderIconDropdown({
							syncText = false,
							fullScan = false,
						})
					end
				end)
			else
				syncBuilderIconCatalogDropdown()
				disconnectBuilderIconWatchers()
			end
		end
		local okBuilder, builderErr = pcall(initBuilderIconEditor)
		if not okBuilder then
			warn(builderErr)
		end
		if type(NAmanage.initUIEditors) == "function" then
			local okEditors, editorsErr = pcall(NAmanage.initUIEditors, Services.CoreGui, HUI)
			if not okEditors then
				warn(editorsErr)
			end
		end

	end
	end)
end
NAmanage.finalizeLoadingState = NAmanage.finalizeLoadingState or function()
	if NAStuff._loadingFinalizedOnce == true then
		NAStuff._loadingFinalizePending = false
		if type(NAmanage.queueStartupAssetPreload) == "function" then
			NAmanage.queueStartupAssetPreload()
		end
		return
	end
	if type(NAmanage.completeStartupLoading) == "function" then
		NAmanage.completeStartupLoading("ready")
	end
end

NAmanage.finalizeLoadingState()

NAmanage.NAInitCoreGuiCustomization()
NAgui.addTab(NA_TABS.TAB_USER_BUTTONS, { order = 10, textIcon = "circle-plus" })
NAgui.setTab(NA_TABS.TAB_USER_BUTTONS)

originalIO.UserBtnEditor=function()
	const editorState = {
		editAll = false,
		currentIndex = 1,
		currentId = nil,
		width = 60,
		height = 60,
		corner = 0.25,
		bgColor = Color3.fromRGB(0, 0, 0),
		textColor = Color3.fromRGB(255, 255, 255),
		lbl = "",
		hidden = false,
		locked = false,
		interactable = true,
		childIdx = 1,
		childLbl = "",
		childBg = Color3.fromRGB(0,0,0),
		childTc = Color3.fromRGB(255,255,255),
	}

	NAgui.addSection("User Buttons Loader")

	NAgui.addButton("Load User Buttons", function()
		if type(NAmanage.loadButtonIDS) == "function" then
			NAmanage.loadButtonIDS()
		end
		if type(NAmanage.RenderUserButtons) == "function" then
			NAmanage.RenderUserButtons()
		end
		if type(NAmanage.RefreshUserButtonEditor) == "function" then
			NAmanage.RefreshUserButtonEditor({ preserveSelection = true })
		end
		DoNotif("User buttons loaded", 2)
	end)

	const function collectAllIds()
		const ids = {}
		for id, data in NAUserButtons do
			if type(id) == "number" and type(data) == "table" then
				Insert(ids, id)
			end
		end
		table.sort(ids)
		return ids
	end

	const function getTargetIds()
		if editorState.editAll then
			return collectAllIds()
		end
		if type(editorState.currentId) == "number" then
			return { editorState.currentId }
		end
		return {}
	end

	const function applyToTargets(mutator, description)
		if not next(NAUserButtons) then
			return
		end

		const targets = getTargetIds()
		if #targets == 0 then
			return
		end

		local applied = 0
		for _, id in targets do
			const data = NAUserButtons[id]
			if type(data) == "table" then
				mutator(data, id)
				applied = applied + 1
			end
		end

		if applied == 0 then
			return
		end

		NAmanage.UserButtonsSave("editor apply")
		if type(NAmanage.RenderUserButtons) == "function" then
			NAmanage.RenderUserButtons()
		end

		if description then
			const suffix = (applied == 1) and " button" or " buttons"
			--DoNotif(description.." applied to "..tostring(applied)..suffix, 2)
		end
	end

	const function lblPr(def, cb)
		const sg = NAmanage.waitForScreenGui and NAmanage.waitForScreenGui(5)
		if not sg then
			return
		end

		const gui = InstanceNew("ScreenGui")
		gui.IgnoreGuiInset = true
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = sg

		const f = InstanceNew("Frame")
		f.Size = UDim2.new(0, 280, 0, 150)
		f.Position = UDim2.new(0.5, -140, 0.5, -75)
		f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		f.BorderSizePixel = 0
		f.Parent = gui

		const u = InstanceNew("UICorner")
		u.CornerRadius = UDim.new(0, 6)
		u.Parent = f

		const t = InstanceNew("TextLabel")
		t.Size = UDim2.new(1, -20, 0, 30)
		t.Position = UDim2.new(0, 10, 0, 10)
		t.BackgroundTransparency = 1
		t.Text = "Rename UserButton Label"
		t.TextColor3 = Color3.fromRGB(255, 255, 255)
		t.Font = Enum.Font.GothamBold
		t.TextSize = 16
		t.TextWrapped = true
		t.Parent = f

		const tb = InstanceNew("TextBox")
		tb.Size = UDim2.new(1, -20, 0, 32)
		tb.Position = UDim2.new(0, 10, 0, 55)
		tb.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		tb.TextColor3 = Color3.fromRGB(255, 255, 255)
		tb.PlaceholderText = "Type new label"
		tb.Text = type(def) == "string" and def or ""
		tb.TextSize = 16
		tb.Font = Enum.Font.Gotham
		tb.ClearTextOnFocus = false
		tb.Parent = f

		const s = InstanceNew("TextButton")
		s.Size = UDim2.new(0.5, -15, 0, 30)
		s.Position = UDim2.new(0, 10, 1, -40)
		s.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
		s.Text = "Save"
		s.TextColor3 = Color3.fromRGB(255, 255, 255)
		s.Font = Enum.Font.GothamBold
		s.TextSize = 14
		s.Parent = f

		const c = InstanceNew("TextButton")
		c.Size = UDim2.new(0.5, -15, 0, 30)
		c.Position = UDim2.new(0.5, 5, 1, -40)
		c.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		c.Text = "Cancel"
		c.TextColor3 = Color3.fromRGB(255, 255, 255)
		c.Font = Enum.Font.GothamBold
		c.TextSize = 14
		c.Parent = f

		MouseButtonFix(s, function()
			local txt = tostring(tb.Text or "")
			txt = GSub(txt, "^%s+", "")
			txt = GSub(txt, "%s+$", "")
			if txt == "" then
				gui:Destroy()
				return
			end
			gui:Destroy()
			cb(txt)
		end)

		MouseButtonFix(c, function()
			gui:Destroy()
		end)

		NAgui.draggerV2(f)
	end

	NAgui.addSection("Label")

	NAgui.addInput("UserButton Label", "Type label", "", function(txt)
		editorState.lbl = tostring(txt or "")
	end)

	NAgui.addButton("Apply Label", function()
		local txt = tostring(editorState.lbl or "")
		txt = GSub(txt, "^%s+", "")
		txt = GSub(txt, "%s+$", "")
		if txt == "" then
			DoNotif("Type a label first", 2)
			return
		end
		applyToTargets(function(data)
			data.Label = txt
		end, "Label")
		updateSelectionLabel()
	end)

	local selectionInfo
	const buttonDropdownLabel = "Select Button"
	const childDropdownLabel = "Select Child"
	local refreshButtonDropdown
	local refreshChildDropdown

	const function cData()
		if type(editorState.currentId) ~= "number" then
			return
		end
		const g = NAUserButtons[editorState.currentId]
		if not (type(g) == "table" and g.Type == "group" and type(g.Children) == "table" and #g.Children > 0) then
			return
		end
		local idx = tonumber(editorState.childIdx) or 1
		if idx < 1 or idx > #g.Children then
			idx = 1
		end
		editorState.childIdx = idx
		return g, g.Children, idx, g.Children[idx]
	end

	const function cSync()
		local g, list, idx, ch = cData()
		if not ch then
			editorState.childLbl = ""
			editorState.childBg = Color3.fromRGB(0,0,0)
			editorState.childTc = Color3.fromRGB(255,255,255)
			if NAgui and NAgui.setInputValue then
				NAgui.setInputValue("Child Index", "", { force = true, fire = false })
				NAgui.setInputValue("Child Label", "", { force = true, fire = false })
			end
			if NAgui and NAgui.setColorPickerValue then
				NAgui.setColorPickerValue("Child Background", Color3.fromRGB(0,0,0), { fire = false })
				NAgui.setColorPickerValue("Child Text", Color3.fromRGB(255,255,255), { fire = false })
			end
			if refreshChildDropdown then
				refreshChildDropdown()
			end
			return
		end
		const bg = NAmanage.UserButtonColorFromTable(ch.BgColor, Color3.fromRGB(0,0,0))
		const tc = NAmanage.UserButtonColorFromTable(ch.TextColor, Color3.fromRGB(255,255,255))
		editorState.childLbl = ch.Label or ""
		editorState.childBg = bg
		editorState.childTc = tc
		if NAgui and NAgui.setInputValue then
			NAgui.setInputValue("Child Index", tostring(idx), { force = true, fire = false })
			NAgui.setInputValue("Child Label", editorState.childLbl, { force = true, fire = false })
		end
		if NAgui and NAgui.setColorPickerValue then
			NAgui.setColorPickerValue("Child Background", bg, { fire = false })
			NAgui.setColorPickerValue("Child Text", tc, { fire = false })
		end
		if refreshChildDropdown then
			refreshChildDropdown()
		end
	end

	const function updateSelectionLabel()
		if not selectionInfo then
			return
		end
		if type(editorState.currentId) ~= "number" then
			selectionInfo.Text = "Selected: None"
			editorState.lbl = ""
			editorState.childIdx = 1
			editorState.childLbl = ""
			if NAgui and NAgui.setInputValue then
				NAgui.setInputValue("UserButton Label", "", { force = true, fire = false })
			end
			cSync()
			if refreshButtonDropdown then
				refreshButtonDropdown()
			end
			return
		end

		const id = editorState.currentId
		const data = NAUserButtons[id]

		const hidden = (type(data) == "table" and data.Hidden) and true or false
		const locked = (type(data) == "table" and data.Locked) and true or false
		const interactable = not (type(data) == "table" and data.Interactable == false)

		const raw = (type(data) == "table" and type(data.Label) == "string") and data.Label or ""
		local label = raw
		if label == "" then
			label = "Button "..tostring(id)
		end

		local groupSuffix = ""
		if data.Type == "group" then
			const count = (type(data.Children) == "table") and #data.Children or 0
			groupSuffix = (" (group: %d)"):format(count)
		end

		selectionInfo.Text = ("Selected: [%d] %s%s"):format(id, label, groupSuffix)
		if refreshButtonDropdown then
			refreshButtonDropdown()
		end

		if editorState.editAll then
			if NAgui and NAgui.setInputValue then
				NAgui.setInputValue("UserButton Label", editorState.lbl or "", { force = true, fire = false })
			end
			return
		end

		editorState.lbl = raw
		if NAgui and NAgui.setInputValue then
			NAgui.setInputValue("UserButton Label", raw, { force = true, fire = false })
		end

		editorState.hidden = hidden
		editorState.locked = locked
		editorState.interactable = interactable
		if NAgui and NAgui.setToggleState then
			NAgui.setToggleState("Hide Button", hidden, { force = true, fire = false })
			NAgui.setToggleState("Lock Button", locked, { force = true, fire = false })
			NAgui.setToggleState("Toggle Interactable", interactable, { force = true, fire = false })
			NAgui.setToggleState("Side Toggle Layout", data.Type == "group" and data.GroupMode == "side" or false, { force = true, fire = false })
		end

		const w = tonumber(data and data.Width) or 60
		const h = tonumber(data and data.Height) or 60
		local cr = tonumber(data and data.CornerRadius) or 0.25
		if cr < 0 then cr = 0 end
		if cr > 1 then cr = 1 end

		const bg = NAmanage.UserButtonColorFromTable(data and data.BgColor, Color3.fromRGB(0, 0, 0))
		const tc = NAmanage.UserButtonColorFromTable(data and data.TextColor, Color3.fromRGB(255, 255, 255))

		editorState.width = w
		editorState.height = h
		editorState.corner = cr
		editorState.bgColor = bg
		editorState.textColor = tc

		if NAgui and NAgui.setSliderValue then
			NAgui.setSliderValue("Button Width", w, { fire = false })
			NAgui.setSliderValue("Button Height", h, { fire = false })
			NAgui.setSliderValue("Corner Radius", cr, { fire = false })
		end

		if NAgui and NAgui.setColorPickerValue then
			NAgui.setColorPickerValue("Background Color", bg, { fire = false })
			NAgui.setColorPickerValue("Text Color", tc, { fire = false })
		end
		cSync()
	end

	const function selectByDelta(delta)
		const ids = collectAllIds()
		if #ids == 0 then
			editorState.currentId = nil
			editorState.currentIndex = 0
			updateSelectionLabel()
			return
		end
		local idx = editorState.currentIndex
		if idx < 1 or idx > #ids then
			idx = 1
		end
		if delta ~= 0 then
			idx = ((idx - 1 + delta) % #ids) + 1
		end
		editorState.currentIndex = idx
		editorState.currentId = ids[idx]
		updateSelectionLabel()
	end

	const function selectChildByDelta(delta)
		local g, list, idx = cData()
		if not (g and list) then
			DoNotif("Select a group with children", 2)
			return
		end
		idx = ((idx - 1 + delta) % #list) + 1
		editorState.childIdx = idx
		cSync()
	end

	const function getDropdownText(selection)
		local value = selection
		if type(value) == "table" then
			value = value[1]
		end
		if type(value) ~= "string" then
			return nil
		end
		value = value:match("^%s*(.-)%s*$")
		if value == "" then
			return nil
		end
		return value
	end

	refreshButtonDropdown = function()
		const ids = collectAllIds()
		local options = {}
		local selected = "None"
		const currentId = type(editorState.currentId) == "number" and editorState.currentId or nil
		for i, id in ids do
			const data = NAUserButtons[id]
			const label = (type(data) == "table" and type(data.Label) == "string" and data.Label ~= "") and data.Label or ("Button "..tostring(id))
			local groupSuffix = ""
			if type(data) == "table" and data.Type == "group" then
				const count = (type(data.Children) == "table") and #data.Children or 0
				groupSuffix = (" (group: %d)"):format(count)
			end
			const option = ("[%d] %s%s"):format(id, label, groupSuffix)
			Insert(options, option)
			if currentId == id then
				selected = option
				editorState.currentIndex = i
			end
		end
		if #options == 0 then
			options = { "None" }
			selected = "None"
		elseif selected == "None" then
			local idx = editorState.currentIndex
			if idx < 1 or idx > #options then
				idx = 1
			end
			selected = options[idx]
		end
		if NAgui and NAgui.setDropdownOptions then
			NAgui.setDropdownOptions(buttonDropdownLabel, options)
		end
		if NAgui and NAgui.setDropdownValue then
			NAgui.setDropdownValue(buttonDropdownLabel, selected, { fire = false })
		end
	end

	refreshChildDropdown = function()
		local g, list, idx = cData()
		local options = {}
		local selected = "None"
		if g and list and #list > 0 then
			for i, child in list do
				const label = (type(child) == "table" and type(child.Label) == "string" and child.Label ~= "") and child.Label or ("Action "..tostring(i))
				const option = ("[%d] %s"):format(i, label)
				Insert(options, option)
				if i == idx then
					selected = option
				end
			end
		end
		if #options == 0 then
			options = { "None" }
			selected = "None"
		elseif selected == "None" then
			selected = options[1]
		end
		if NAgui and NAgui.setDropdownOptions then
			NAgui.setDropdownOptions(childDropdownLabel, options)
		end
		if NAgui and NAgui.setDropdownValue then
			NAgui.setDropdownValue(childDropdownLabel, selected, { fire = false })
		end
	end

	NAmanage.RefreshUserButtonEditor = function(opts)
		opts = opts or {}
		const ids = collectAllIds()
		if #ids == 0 then
			editorState.currentId = nil
			editorState.currentIndex = 0
			updateSelectionLabel()
			return 0
		end

		local selectedIndex
		if opts.preserveSelection ~= false and type(editorState.currentId) == "number" then
			for i, id in ids do
				if id == editorState.currentId then
					selectedIndex = i
					break
				end
			end
		end

		if not selectedIndex then
			selectedIndex = tonumber(editorState.currentIndex) or 1
			selectedIndex = math.clamp(math.floor(selectedIndex), 1, #ids)
			editorState.currentId = ids[selectedIndex]
		end
		editorState.currentIndex = selectedIndex
		updateSelectionLabel()
		return #ids
	end

	const function getChildPickerColor(label, fallback)
		const reg = NAgui and NAgui._colorPickerRegistry
		const entry = reg and reg[label]
		if entry and entry.get then
			local ok, col = pcall(entry.get)
			if ok and typeof(col) == "Color3" then
				return col
			end
		end
		return fallback
	end

	const function currentChildColors()
		const bg = getChildPickerColor("Child Background", editorState.childBg or Color3.fromRGB(0,0,0))
		const tc = getChildPickerColor("Child Text", editorState.childTc or Color3.fromRGB(255,255,255))
		editorState.childBg = bg
		editorState.childTc = tc
		return bg, tc
	end

	const function applyChildUpdates()
		local g, list, idx, ch = cData()
		if not ch then
			return
		end
		local label = tostring(editorState.childLbl or "")
		label = GSub(label, "^%s+", "")
		label = GSub(label, "%s+$", "")
		if label == "" then
			label = ch.Label or ("Action "..idx)
		end
		local bg, tc = currentChildColors()
		list[idx].Label = label
		list[idx].BgColor = NAmanage.UserButtonColorToTable(bg)
		list[idx].TextColor = NAmanage.UserButtonColorToTable(tc)
		NAmanage.UserButtonsSave("edit group child")
		if type(NAmanage.RenderUserButtons) == "function" then
			NAmanage.RenderUserButtons()
		end
		cSync()
		return true
	end

	NAgui.addSection("Selection")

	NAgui.addToggle("Edit All User Buttons", false, function(value)
		editorState.editAll = value and true or false
	end)

	selectionInfo = NAgui.addInfo("Selected Button", "Selected: None")
	NAgui.addDropdown(buttonDropdownLabel, { "None" }, "None", function(selection)
		const selected = getDropdownText(selection)
		if not selected or Lower(selected) == "none" then
			return
		end
		const id = tonumber(Match(selected, "^%[(%d+)%]"))
		if not id or type(NAUserButtons[id]) ~= "table" then
			if refreshButtonDropdown then
				refreshButtonDropdown()
			end
			return
		end
		const ids = collectAllIds()
		for idx, currentId in ids do
			if currentId == id then
				editorState.currentIndex = idx
				break
			end
		end
		editorState.currentId = id
		updateSelectionLabel()
	end)
	if type(NAmanage.RefreshUserButtonEditor) == "function" then
		NAmanage.RefreshUserButtonEditor({ preserveSelection = true })
	else
		selectByDelta(0)
		if refreshButtonDropdown then
			refreshButtonDropdown()
		end
	end

	NAgui.addButton("Delete Button", function()
		if not next(NAUserButtons) then
			DoNotif("No user buttons to delete", 2)
			return
		end

		const targets = getTargetIds()
		if #targets == 0 then
			DoNotif("No selected button to delete", 2)
			return
		end

		local deleted = 0
		for _, id in targets do
			if NAUserButtons[id] ~= nil then
				NAUserButtons[id] = nil
				originalIO.clearUserButtonState(id)
				deleted = deleted + 1
			end
		end

		if deleted == 0 then
			DoNotif("No user buttons were deleted", 2)
			return
		end

		NAmanage.UserButtonsSave("editor delete")
		if type(NAmanage.RenderUserButtons) == "function" then
			NAmanage.RenderUserButtons()
		end

		editorState.currentId = nil
		editorState.currentIndex = 0
		updateSelectionLabel()

		const suffix = (deleted == 1) and " button" or " buttons"
		DoNotif("Deleted "..tostring(deleted)..suffix, 2)
	end)

	NAgui.addSection("Grouping")

	NAgui.addToggle("Side Toggle Layout", false, function(state)
		const mode = state and "side" or "dropdown"
		applyToTargets(function(data)
			if data.Type == "group" then
				data.GroupMode = mode
			end
		end, "Group mode")
	end)

	NAgui.addButton("Ungroup Selected", function()
		if type(editorState.currentId) ~= "number" then
			DoNotif("Select a group to ungroup", 2)
			return
		end
		const data = NAUserButtons[editorState.currentId]
		if not (type(data) == "table" and data.Type == "group") then
			DoNotif("Selected item is not a group", 2)
			return
		end
		local ok, msg = NAmanage.UserButtons_Ungroup(editorState.currentId)
		if ok then
			editorState.currentId = nil
			editorState.currentIndex = 0
			if type(NAmanage.RenderUserButtons) == "function" then
				NAmanage.RenderUserButtons()
			end
			updateSelectionLabel()
			DoNotif(msg or "Ungrouped", 2)
		else
			DoNotif(msg or "Failed to ungroup", 3)
		end
	end)

	NAgui.addSection("Button State")

	NAgui.addToggle("Hide Button", false, function(state)
		editorState.hidden = state and true or false
		applyToTargets(function(data)
			data.Hidden = editorState.hidden or nil
		end, "Visibility")
	end)

	NAgui.addSection("Group Children")
	NAgui.addDropdown(childDropdownLabel, { "None" }, "None", function(selection)
		const selected = getDropdownText(selection)
		if not selected or Lower(selected) == "none" then
			return
		end
		const idx = tonumber(Match(selected, "^%[(%d+)%]"))
		const g = type(editorState.currentId) == "number" and NAUserButtons[editorState.currentId] or nil
		if not (idx and type(g) == "table" and g.Type == "group" and type(g.Children) == "table" and g.Children[idx]) then
			if refreshChildDropdown then
				refreshChildDropdown()
			end
			return
		end
		editorState.childIdx = idx
		cSync()
	end)
	if refreshChildDropdown then
		refreshChildDropdown()
	end

	NAgui.addInput("Child Index", "Number in group", "", function(txt)
		editorState.childIdx = tonumber(txt) or editorState.childIdx or 1
		cSync()
	end)

	NAgui.addInput("Child Label", "Type child label", "", function(txt)
		editorState.childLbl = tostring(txt or "")
		applyChildUpdates()
	end)

	NAgui.addColorPicker("Child Background", editorState.childBg, function(color)
		if typeof(color) ~= "Color3" then
			return
		end
		editorState.childBg = color
		applyChildUpdates()
	end)

	NAgui.addColorPicker("Child Text", editorState.childTc, function(color)
		if typeof(color) ~= "Color3" then
			return
		end
		editorState.childTc = color
		applyChildUpdates()
	end)

	NAgui.addToggle("Lock Button", false, function(state)
		editorState.locked = state and true or false
		applyToTargets(function(data)
			data.Locked = editorState.locked or nil
		end, "Lock")
	end)

	NAgui.addToggle("Toggle Interactable", true, function(state)
		editorState.interactable = state and true or false
		applyToTargets(function(data)
			if editorState.interactable then
				data.Interactable = nil
			else
				data.Interactable = false
			end
		end, "Interactable")
	end)

	NAgui.addSection("Appearance")

	NAgui.addSlider("Button Width", 20, 500, editorState.width, 2, " px", function(value)
		editorState.width = value
		applyToTargets(function(data)
			data.Width = math.floor(value + 0.5)
		end)
	end)

	NAgui.addSlider("Button Height", 20, 500, editorState.height, 2, " px", function(value)
		editorState.height = value
		applyToTargets(function(data)
			data.Height = math.floor(value + 0.5)
		end)
	end)

	NAgui.addSlider("Corner Radius", 0, 1, editorState.corner, 0.05, "", function(value)
		editorState.corner = value
		applyToTargets(function(data)
			data.CornerRadius = value
		end)
	end)

	NAgui.addColorPicker("Background Color", editorState.bgColor, function(color)
		if typeof(color) ~= "Color3" then
			return
		end
		editorState.bgColor = color
		const stored = NAmanage.UserButtonColorToTable(color)
		applyToTargets(function(data)
			data.BgColor = stored
		end)
	end)

	NAgui.addColorPicker("Text Color", editorState.textColor, function(color)
		if typeof(color) ~= "Color3" then
			return
		end
		editorState.textColor = color
		const stored = NAmanage.UserButtonColorToTable(color)
		applyToTargets(function(data)
			data.TextColor = stored
		end)
	end)

	NAgui.addButton("Reset Appearance Overrides", function()
		applyToTargets(function(data)
			data.Width = nil
			data.Height = nil
			data.BgColor = nil
			data.TextColor = nil
			data.CornerRadius = nil
		end, "Appearance reset")
	end)
	updateSelectionLabel()
end
originalIO.UserBtnEditor()

NAStuff.joinLeaveWarned = false
function NAmanage.jlSave()
	NAmanage.jlCfg = NAmanage.jlNorm(NAmanage.jlCfg)
	NAmanage.logApply()
	if FileSupport then
		writefile(NAfiles.NAJOINLEAVE, Services.HttpService:JSONEncode(NAmanage.jlCfg))
	elseif not NAStuff.joinLeaveWarned then
		NAStuff.joinLeaveWarned = true
		DebugNotif("Logging settings will reset after this session (no file support detected).")
	end
end

NAgui.addTab(NA_TABS.TAB_LOGGING, { order = 11, textIcon = "list-bulleted" })
NAgui.setTab(NA_TABS.TAB_LOGGING)

NAgui.addSection("Join/Leave Logging")

NAgui.addToggle("Log Player Joins", NAmanage.jlCfg.JoinLog, function(v)
	NAmanage.jlCfg.JoinLog = v
	NAmanage.jlSave()
	DoNotif("Join logging "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Log Player Leaves", NAmanage.jlCfg.LeaveLog, function(v)
	NAmanage.jlCfg.LeaveLog = v
	NAmanage.jlSave()
	DoNotif("Leave logging "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Notify If Followed Into", NAmanage.jlCfg.NotifyFollowed == true, function(v)
	NAmanage.jlCfg.NotifyFollowed = v and true or false
	NAmanage.jlSave()
	DoNotif("Followed-into notification "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Save Join/Leave Logs", NAmanage.jlCfg.SaveLog, function(v)
	NAmanage.jlCfg.SaveLog = v
	NAmanage.jlSave()
	DoNotif("Join/Leave log saving has been "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Include User IDs In Join/Leave Logs", NAmanage.jlCfg.JoinLeaveShowUserIds == true, function(v)
	NAmanage.jlCfg.JoinLeaveShowUserIds = v and true or false
	NAmanage.jlSave()
	DoNotif("Join/leave user IDs "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addSection("Chat Logging")

NAgui.addToggle("Log Chat Messages", NAmanage.jlCfg.ChatLog, function(v)
	NAmanage.jlCfg.ChatLog = v
	NAmanage.jlSave()
	DoNotif("Chat logging "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Save Chat Logs", NAmanage.jlCfg.SaveChatLog, function(v)
	NAmanage.jlCfg.SaveChatLog = v
	NAmanage.jlSave()
	DoNotif("Chat log saving has been "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Show Chat Timestamps", NAmanage.jlCfg.ChatShowTimestamps ~= false, function(v)
	NAmanage.jlCfg.ChatShowTimestamps = v and true or false
	NAmanage.jlSave()
	DoNotif("Chat timestamps "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Use Display Names In Chat Log", NAmanage.jlCfg.ChatUseDisplayNames ~= false, function(v)
	NAmanage.jlCfg.ChatUseDisplayNames = v and true or false
	NAmanage.jlSave()
	DoNotif("Display names in chat log "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Include User IDs In Chat Log", NAmanage.jlCfg.ChatShowUserIds == true, function(v)
	NAmanage.jlCfg.ChatShowUserIds = v and true or false
	NAmanage.jlSave()
	DoNotif("Chat log user IDs "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Log Your Own Chat Messages", NAmanage.jlCfg.ChatLogLocalPlayer ~= false, function(v)
	NAmanage.jlCfg.ChatLogLocalPlayer = v and true or false
	NAmanage.jlSave()
	DoNotif("Own chat logging "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addSlider("On-Screen Chat Buffer", 20, 500, tonumber(NAmanage.jlCfg.ChatMaxMessages) or 200, 10, " messages", function(v)
	NAmanage.jlCfg.ChatMaxMessages = math.floor(tonumber(v) or 200)
	if NAStuff.ChatLogState then
		NAStuff.ChatLogState.maxMessages = NAmanage.jlCfg.ChatMaxMessages
		const entries = NAStuff.ChatLogState.entries
		if type(entries) == "table" then
			while #entries > NAStuff.ChatLogState.maxMessages do
				const old = table.remove(entries, 1)
				if old and old.Parent then
					old:Destroy()
				end
			end
		end
	end
	NAmanage.jlSave()
end)

NAgui.addSection("Saved Log Format")

NAgui.addToggle("Include Game/Server Info In Saved Logs", NAmanage.jlCfg.LogIncludeGameInfo ~= false, function(v)
	NAmanage.jlCfg.LogIncludeGameInfo = v and true or false
	NAmanage.jlSave()
	DoNotif("Saved log metadata "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addSection("Notification Preferences")

NAgui.addToggle("Show Welcome Notification", NAmanage.jlCfg.WelcomeNotif ~= false, function(v)
	NAmanage.jlCfg.WelcomeNotif = v and true or false
	NAmanage.jlSave()
	DoNotif("Welcome notification "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Supported Game Alerts", NAmanage.jlCfg.SupportedGameNotif ~= false, function(v)
	NAmanage.jlCfg.SupportedGameNotif = v and true or false
	NAmanage.jlSave()
	DoNotif("Supported game alerts "..(v and "enabled" or "disabled"), 2)
	if v then
		SpawnCall(function()
			NAmanage.NotifySupportedGameScripts({ force = true })
		end)
	end
end)

NAgui.addToggle("Show Keybind Prefix Reminder", NAmanage.jlCfg.KeybindNotif ~= false, function(v)
	NAmanage.jlCfg.KeybindNotif = v and true or false
	NAmanage.jlSave()
	DoNotif("Keybind prefix reminder "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Show Plugin Load Summary", NAmanage.jlCfg.PluginNotif ~= false, function(v)
	NAmanage.jlCfg.PluginNotif = v and true or false
	NAmanage.jlSave()
	DoNotif("Plugin load summary "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addToggle("Show Intro Text Label", NAmanage.jlCfg.IconLabel ~= false, function(v)
	NAmanage.jlCfg.IconLabel = v and true or false
	NAmanage.jlSave()
	DoNotif("Intro text label "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addSection("Other Logging")

NAgui.addToggle("Log Physics Errors", NAmanage.jlCfg.PhysicsLog, function(v)
	NAmanage.jlCfg.PhysicsLog = v
	NAmanage.jlSave()
	DoNotif("Physics error logging "..(v and "enabled" or "disabled"), 2)
end)

NAgui.addSection("Log Maintenance")

NAgui.addButton("Clear Join/Leave Log File", function()
	if not FileSupport then
		DoNotif("File operations not supported by this executor.", 2)
		return
	end
	local ok, msg = originalIO.safeDeleteFile(NAfiles.NAJOINLEAVELOG)
	DoNotif(ok and "Join/Leave log cleared." or ("Failed to clear: "..tostring(msg)), 2.5)
end)

NAgui.addButton("Clear Chat Log File", function()
	if not FileSupport then
		DoNotif("File operations not supported by this executor.", 2)
		return
	end
	local ok, msg = originalIO.safeDeleteFile(NAfiles.NACHATLOGS)
	DoNotif(ok and "Chat log cleared." or ("Failed to clear: "..tostring(msg)), 2.5)
end)


NAmanage.EnsureESPSettingsLoadedForUI = function(timeout)
	const state = NAmanage.ESPSettingsState
	if type(state) ~= "table" then
		return false
	end
	if state.loaded == true then
		return true
	end
	const deadline = os.clock() + math.max(0.1, tonumber(timeout) or 1.5)
	while state.loading == true and os.clock() < deadline do
		Wait()
	end
	if state.loaded == true then
		return true
	end
	if state.loading == true or type(NAmanage.LoadESPSettings) ~= "function" then
		return false
	end
	local ok, loaded = pcall(NAmanage.LoadESPSettings, { reason = "hydrate ESP settings UI" })
	return ok and loaded ~= false and state.loaded == true
end

NAmanage.EnsureESPSettingsLoadedForUI(1.5)

NAgui.addTab(NA_TABS.TAB_ESP, { order = 5, textIcon = "crosshairs" })
NAgui.setTab(NA_TABS.TAB_ESP)

NAgui.isListActive=function(list)
	return type(list) == "table" and next(list) ~= nil
end

NAgui.trimText=function(str)
	return (str or ""):match("^%s*(.-)%s*$")
end

const function addPartESPColorPicker(label, key, defaultColor, refreshFn)
	const startColor = NAmanage.GetPartESPColor(key, defaultColor)
	NAgui.addColorPicker(label, startColor, function(color)
		if typeof(color) ~= "Color3" then
			return
		end
		NAStuff[key] = color
		if type(refreshFn) == "function" then
			refreshFn(color)
		end
		NAmanage.SaveESPSettings()
		NAmanage.PartESP_UpdateTexts(true)
	end)
end

NAgui.addSection("Visuals & Color")
NAgui.addInfo("Drawing API Warning", "Drawing API may break with Vulkan enabled by a bootstrapper");

(function()
	local supportInfo
	const function drawingSupportText(refresh)
		const hasLib = NAgui.getDrawingLibrary() ~= nil
		const sq = NAmanage.DrawingObjectSupported("Square", refresh)
		const ln = NAmanage.DrawingObjectSupported("Line", refresh)
		const tx = NAmanage.DrawingObjectSupported("Text", refresh)
		const tr = NAmanage.DrawingObjectSupported("Triangle", refresh)
		return Format("Lib:%s | Square:%s | Line:%s | Text:%s | Triangle:%s", hasLib and "yes" or "no", sq and "yes" or "no", ln and "yes" or "no", tx and "yes" or "no", tr and "yes" or "no")
	end
	supportInfo = NAgui.addInfo("Drawing API Support", drawingSupportText(false), {
		minTextSize = 8;
		autoShrink = true;
	})
	NAgui.addButton("Refresh Drawing API Support", function()
		if type(NAmanage._drawingObjectSupport) == "table" then
			for key in NAmanage._drawingObjectSupport do
				NAmanage._drawingObjectSupport[key] = nil
			end
		end
		if supportInfo then
			supportInfo.Text = drawingSupportText(true)
		end
		DoNotif("Drawing API support refreshed.", 2)
	end)
	NAgui.addButton("Clear Drawing Cache + Rebuild ESP", function()
		if type(cleardrawcache) == "function" then
			pcall(cleardrawcache)
		end
		if type(NAmanage._drawingObjectSupport) == "table" then
			for key in NAmanage._drawingObjectSupport do
				NAmanage._drawingObjectSupport[key] = nil
			end
		end
		NAmanage.ESP_RebuildVisuals()
		NAmanage.PartESP_RebuildVisuals()
		if supportInfo then
			supportInfo.Text = drawingSupportText(true)
		end
		DoNotif("Drawing ESP rebuilt.", 2)
	end)
end)()

const espRenderOptions = NAgui.getESPRenderModeOptions(true)
const partEspRenderOptions = NAgui.getESPRenderModeOptions(false)
const npcEspRenderOptions = NAgui.getNPCESPRenderModeOptions()
NAStuff.ESP_RenderMode = NAgui.sanitizeESPRenderMode(NAStuff.ESP_RenderMode, "Highlight")
NAStuff.ESP_PartRenderMode = NAgui.sanitizeESPRenderMode(NAStuff.ESP_PartRenderMode, "BoxHandleAdornment")
if NAStuff.ESP_PartRenderMode == "Character Box" then NAStuff.ESP_PartRenderMode = "BoxHandleAdornment" end
NAStuff.NPC_ESP_RenderMode = NAgui.sanitizeNPCESPRenderMode(NAStuff.NPC_ESP_RenderMode)
NAStuff.ESP_DrawingBoxStyle = NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingBoxStyle)
NAStuff.ESP_DrawingPartBoxStyle = NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingPartBoxStyle)
NAStuff.ESP_DrawingTracerOrigin = NAgui.sanitizeESPDrawingTracerOrigin(NAStuff.ESP_DrawingTracerOrigin)
NAStuff.ESP_DrawingTracerTarget = NAgui.sanitizeESPDrawingTracerTarget(NAStuff.ESP_DrawingTracerTarget)
NAStuff.ESP_DrawingTextFont = NAgui.sanitizeDrawingTextFont(NAStuff.ESP_DrawingTextFont)

NAgui.addDropdown("ESP Render Mode", espRenderOptions, NAStuff.ESP_RenderMode, function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	const mode = NAgui.sanitizeESPRenderMode(picked, NAStuff.ESP_RenderMode)
	if mode == NAStuff.ESP_RenderMode then
		return
	end
	NAStuff.ESP_RenderMode = mode
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addDropdown("Part ESP Render Mode", partEspRenderOptions, NAStuff.ESP_PartRenderMode, function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	const mode = NAgui.sanitizeESPRenderMode(picked, NAStuff.ESP_PartRenderMode)
	if mode == NAStuff.ESP_PartRenderMode then
		return
	end
	NAStuff.ESP_PartRenderMode = mode
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addDropdown("NPC ESP Render Mode", npcEspRenderOptions, NAStuff.NPC_ESP_RenderMode, function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	const mode = NAgui.sanitizeNPCESPRenderMode(picked)
	if mode == NAStuff.NPC_ESP_RenderMode then
		return
	end
	NAStuff.NPC_ESP_RenderMode = mode
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addToggle("Use Custom ESP Color", NAStuff.ESP_UseCustomColor == true, function(state)
	NAStuff.ESP_UseCustomColor = state
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addColorPicker("Custom ESP Color", NAStuff.ESP_CustomColor or Color3.new(1, 1, 1), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.ESP_CustomColor = color
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addToggle("ESP Color By Team", (NAStuff.ESP_ColorByTeam ~= false), function(state)
	NAStuff.ESP_ColorByTeam = state
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("ESP Ignore Team", NAStuff.ESP_IgnoreTeam == true, function(state)
	NAStuff.ESP_IgnoreTeam = state == true
	NAmanage.SaveESPSettings()
	if NAmanage.ESP_RefreshPlayerTeamFilters then
		NAmanage.ESP_RefreshPlayerTeamFilters()
	end
end)

NAgui.addInput("ESP Team Prefix", "empty = any team", tostring(NAStuff.ESP_TargetTeam or ""), function(text)
	NAStuff.ESP_TargetTeam = tostring(text or ""):match("^%s*(.-)%s*$") or ""
	NAmanage.SaveESPSettings()
	if NAmanage.ESP_RefreshPlayerTeamFilters then
		NAmanage.ESP_RefreshPlayerTeamFilters()
	end
end)

NAgui.addSlider("Player ESP Transparency", 0, 1, NAgui.sanitizeTransparency(NAStuff.ESP_Transparency or 0.7), 0.05, "", function(v)
	const alpha = NAgui.sanitizeTransparency(v)
	NAStuff.ESP_Transparency = alpha
	for _, data in espCONS do
		if data.highlight then
			data.highlight.FillTransparency = alpha
		end
		if data.drawingBox then
			pcall(function()
				data.drawingBox.Transparency = NAgui.toDrawingTransparency(alpha)
			end)
		end
		for _, box in data.boxTable do
			if box then box.Transparency = alpha end
		end
	end
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Part ESP Transparency", 0, 1, NAgui.sanitizeTransparency(NAStuff.ESP_PartTransparency or 0.45), 0.05, "", function(v)
	const alpha = NAgui.sanitizeTransparency(v)
	NAStuff.ESP_PartTransparency = alpha
	NAmanage.PartESP_UpdateTexts(true)
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Highlight Outline Transparency", 0, 1, NAgui.sanitizeTransparency(NAStuff.ESP_OutlineTransparency or 0), 0.05, "", function(v)
	const outline = NAgui.sanitizeTransparency(v)
	NAStuff.ESP_OutlineTransparency = outline
	for _, data in espCONS do
		if data and data.highlight then
			data.highlight.OutlineTransparency = outline
		end
	end
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSection("Player Drawing API")

NAgui.addDropdown("Drawing Box Style", NAgui.getESPDrawingBoxStyleOptions(), NAStuff.ESP_DrawingBoxStyle, function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	const style = NAgui.sanitizeESPDrawingBoxStyle(picked)
	if style == NAStuff.ESP_DrawingBoxStyle then
		return
	end
	NAStuff.ESP_DrawingBoxStyle = style
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addSlider("Drawing Box Thickness", 1, 6, math.clamp(tonumber(NAStuff.ESP_DrawingBoxThickness) or 1, 1, 6), 1, " px", function(v)
	NAStuff.ESP_DrawingBoxThickness = math.clamp(tonumber(v) or 1, 1, 6)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addToggle("Drawing Filled Boxes", NAStuff.ESP_DrawingFilledBoxes == true, function(state)
	NAStuff.ESP_DrawingFilledBoxes = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addToggle("Drawing Box Outline", NAStuff.ESP_DrawingBoxOutline ~= false, function(state)
	NAStuff.ESP_DrawingBoxOutline = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addSlider("Drawing Outline Thickness", 1, 10, math.clamp(tonumber(NAStuff.ESP_DrawingBoxOutlineThickness) or 3, 1, 10), 1, " px", function(v)
	NAStuff.ESP_DrawingBoxOutlineThickness = math.clamp(tonumber(v) or 3, 1, 10)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addSlider("Drawing Corner Length", 0.05, 0.5, math.clamp(tonumber(NAStuff.ESP_DrawingCornerScale) or 0.25, 0.05, 0.5), 0.01, " scale", function(v)
	NAStuff.ESP_DrawingCornerScale = math.clamp(tonumber(v) or 0.25, 0.05, 0.5)
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Drawing Text Outline", NAStuff.ESP_DrawingTextOutline ~= false, function(state)
	NAStuff.ESP_DrawingTextOutline = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
end)

NAgui.addToggle("Drawing Text Centered", NAStuff.ESP_DrawingTextCentered ~= false, function(state)
	NAStuff.ESP_DrawingTextCentered = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
end)

NAgui.addSlider("Drawing Text Transparency", 0, 1, math.clamp(tonumber(NAStuff.ESP_DrawingTextTransparency) or 0, 0, 1), 0.05, "", function(v)
	NAStuff.ESP_DrawingTextTransparency = math.clamp(tonumber(v) or 0, 0, 1)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
end)

NAgui.addDropdown("Drawing Text Font", NAgui.getDrawingTextFontOptions(), NAgui.sanitizeDrawingTextFont(NAStuff.ESP_DrawingTextFont), function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	NAStuff.ESP_DrawingTextFont = NAgui.sanitizeDrawingTextFont(picked)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Drawing Tracers", NAStuff.ESP_DrawingTracerEnabled == true, function(state)
	NAStuff.ESP_DrawingTracerEnabled = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addDropdown("Tracer Origin", NAgui.getESPDrawingTracerOriginOptions(), NAStuff.ESP_DrawingTracerOrigin, function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	const origin = NAgui.sanitizeESPDrawingTracerOrigin(picked)
	if origin == NAStuff.ESP_DrawingTracerOrigin then
		return
	end
	NAStuff.ESP_DrawingTracerOrigin = origin
	NAmanage.SaveESPSettings()
end)

NAgui.addDropdown("Tracer Target", NAgui.getESPDrawingTracerTargetOptions(), NAgui.sanitizeESPDrawingTracerTarget(NAStuff.ESP_DrawingTracerTarget), function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	const target = NAgui.sanitizeESPDrawingTracerTarget(picked)
	if target == NAStuff.ESP_DrawingTracerTarget then
		return
	end
	NAStuff.ESP_DrawingTracerTarget = target
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Tracer Outline", NAStuff.ESP_DrawingTracerOutline ~= false, function(state)
	NAStuff.ESP_DrawingTracerOutline = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addSlider("Tracer Thickness", 1, 6, math.clamp(tonumber(NAStuff.ESP_DrawingTracerThickness) or 1, 1, 6), 1, " px", function(v)
	NAStuff.ESP_DrawingTracerThickness = math.clamp(tonumber(v) or 1, 1, 6)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_RebuildVisuals()
end)

NAgui.addSection("Part Drawing API")

NAgui.addDropdown("Part Drawing Box Style", NAgui.getESPDrawingBoxStyleOptions(), NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingPartBoxStyle), function(selection)
	const picked = type(selection) == "table" and selection[1] or selection
	const style = NAgui.sanitizeESPDrawingBoxStyle(picked)
	if style == NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingPartBoxStyle) then
		return
	end
	NAStuff.ESP_DrawingPartBoxStyle = style
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_RebuildVisuals()
end)

NAgui.addSlider("Part Drawing Box Thickness", 1, 6, math.clamp(tonumber(NAStuff.ESP_DrawingPartBoxThickness) or 1, 1, 6), 1, " px", function(v)
	NAStuff.ESP_DrawingPartBoxThickness = math.clamp(tonumber(v) or 1, 1, 6)
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_RebuildVisuals()
end)

NAgui.addToggle("Part Drawing Filled Boxes", NAStuff.ESP_DrawingPartFilledBoxes == true, function(state)
	NAStuff.ESP_DrawingPartFilledBoxes = state == true
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_RebuildVisuals()
end)

NAgui.addToggle("Part Drawing Box Outline", NAStuff.ESP_DrawingPartBoxOutline ~= false, function(state)
	NAStuff.ESP_DrawingPartBoxOutline = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_RebuildVisuals()
end)

NAgui.addSlider("Part Drawing Outline Thickness", 1, 10, math.clamp(tonumber(NAStuff.ESP_DrawingPartBoxOutlineThickness) or 3, 1, 10), 1, " px", function(v)
	NAStuff.ESP_DrawingPartBoxOutlineThickness = math.clamp(tonumber(v) or 3, 1, 10)
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_RebuildVisuals()
end)

NAgui.addSlider("Part Drawing Corner Length", 0.05, 0.5, math.clamp(tonumber(NAStuff.ESP_DrawingPartCornerScale) or 0.25, 0.05, 0.5), 0.01, " scale", function(v)
	NAStuff.ESP_DrawingPartCornerScale = math.clamp(tonumber(v) or 0.25, 0.05, 0.5)
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Part Drawing Text Outline", NAStuff.ESP_DrawingPartTextOutline ~= false, function(state)
	NAStuff.ESP_DrawingPartTextOutline = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Part Drawing Text Centered", NAStuff.ESP_DrawingPartTextCentered ~= false, function(state)
	NAStuff.ESP_DrawingPartTextCentered = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSlider("Part Drawing Text Transparency", 0, 1, math.clamp(tonumber(NAStuff.ESP_DrawingPartTextTransparency) or 0, 0, 1), 0.05, "", function(v)
	NAStuff.ESP_DrawingPartTextTransparency = math.clamp(tonumber(v) or 0, 0, 1)
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSlider("Part Drawing Queue Batch", 1, 512, math.clamp(math.floor(tonumber(NAStuff.ESP_DrawingPartQueuePerStep) or 64), 1, 512), 1, " items", function(v)
	NAStuff.ESP_DrawingPartQueuePerStep = math.clamp(math.floor(tonumber(v) or 64), 1, 512)
	NAmanage.SaveESPSettings()
end)

NAgui.addSection("Visibility & Performance")
NAgui.addInfo("ESP Distance Note", "Set a distance slider to 0 to remove that limit.")

NAgui.addSlider("ESP Box Distance", 0, 2000, NAStuff.ESP_BoxMaxDistance or 120, 5, " studs", function(v)
	NAStuff.ESP_BoxMaxDistance = v
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("ESP Label Distance", 0, 5000, NAStuff.ESP_LabelMaxDistance or 1000, 25, " studs", function(v)
	NAStuff.ESP_LabelMaxDistance = v
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("ESP Update Batch Size", 1, 256, math.clamp(math.floor(tonumber(NAStuff.ESP_MaxPerStep) or 24), 1, 256), 1, " models", function(v)
	NAStuff.ESP_MaxPerStep = math.clamp(math.floor(tonumber(v) or 24), 1, 256)
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Drawing ESP Update Batch", 16, 512, math.clamp(math.floor(tonumber(NAStuff.ESP_DrawingMaxPerStep) or 64), 16, 512), 1, " models", function(v)
	NAStuff.ESP_DrawingMaxPerStep = math.clamp(math.floor(tonumber(v) or 64), 16, 512)
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Part ESP Update Batch", 1, 512, math.clamp(math.floor(tonumber(NAStuff.ESP_PartUpdatePerStep) or 48), 1, 512), 1, " parts", function(v)
	NAStuff.ESP_PartUpdatePerStep = math.clamp(math.floor(tonumber(v) or 48), 1, 512)
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Part ESP Max Active", 50, 5000, math.clamp(math.floor(tonumber(NAStuff.ESP_PartMaxActive) or 450), 50, 5000), 10, " visuals", function(v)
	NAStuff.ESP_PartMaxActive = math.clamp(math.floor(tonumber(v) or 450), 50, 5000)
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Part ESP Sweep Interval", 1, 30, math.clamp(tonumber(NAStuff.ESP_PartSweepInterval) or 4, 1, 30), 0.25, "s", function(v)
	NAStuff.ESP_PartSweepInterval = math.clamp(tonumber(v) or 4, 0.75, 30)
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Part ESP Name Safety Sweep", 5, 60, math.clamp(tonumber(NAStuff.ESP_PartNameSweepInterval) or 18, 5, 60), 1, "s", function(v)
	NAStuff.ESP_PartNameSweepInterval = math.clamp(tonumber(v) or 18, 5, 60)
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("ESP Raycast Occlusion", NAStuff.ESP_OcclusionEnabled == true, function(state)
	NAStuff.ESP_OcclusionEnabled = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Affects Player ESP", NAStuff.ESP_OcclusionIncludePlayers == true, function(state)
	NAStuff.ESP_OcclusionIncludePlayers = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
end)

NAgui.addToggle("Occlusion Affects NPC ESP", NAStuff.ESP_OcclusionIncludeNPCs == true, function(state)
	NAStuff.ESP_OcclusionIncludeNPCs = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
end)

NAgui.addToggle("Occlusion Affects Part ESP", NAStuff.ESP_OcclusionIncludeParts == true, function(state)
	NAStuff.ESP_OcclusionIncludeParts = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Hides Player/NPC Labels", NAStuff.ESP_OcclusionHideLabels == true, function(state)
	NAStuff.ESP_OcclusionHideLabels = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Hides Part Labels", NAStuff.ESP_OcclusionHidePartLabels == true, function(state)
	NAStuff.ESP_OcclusionHidePartLabels = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Hides Tracers", NAStuff.ESP_OcclusionHideTracers == true, function(state)
	NAStuff.ESP_OcclusionHideTracers = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
end)

NAgui.addToggle("Occlusion Dims Boxes", NAStuff.ESP_OcclusionDimBoxes == true, function(state)
	NAStuff.ESP_OcclusionDimBoxes = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Dims Labels", NAStuff.ESP_OcclusionDimLabels == true, function(state)
	NAStuff.ESP_OcclusionDimLabels = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Ignores Transparent", NAStuff.ESP_OcclusionIgnoreTransparent == true, function(state)
	NAStuff.ESP_OcclusionIgnoreTransparent = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSlider("Transparent Ignore Threshold", 0, 1, math.clamp(tonumber(NAStuff.ESP_OcclusionTransparentThreshold) or 0.85, 0, 1), 0.05, "", function(v)
	NAStuff.ESP_OcclusionTransparentThreshold = math.clamp(tonumber(v) or 0.85, 0, 1)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Ignores Non-Collidable", NAStuff.ESP_OcclusionIgnoreNonCollidable == true, function(state)
	NAStuff.ESP_OcclusionIgnoreNonCollidable = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Occlusion Ignores Same Model", NAStuff.ESP_OcclusionIgnoreSameModel == true, function(state)
	NAStuff.ESP_OcclusionIgnoreSameModel = state == true
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addColorPicker("Occluded ESP Color", NAStuff.ESP_OcclusionColor or Color3.fromRGB(130, 130, 130), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.ESP_OcclusionColor = color
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSlider("Occlusion Dim Amount", 0, 1, math.clamp(tonumber(NAStuff.ESP_OcclusionDimAmount) or 0.55, 0, 1), 0.05, "", function(v)
	NAStuff.ESP_OcclusionDimAmount = math.clamp(tonumber(v) or 0.55, 0, 1)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSlider("Occlusion Update Interval", 0.05, 1, math.clamp(tonumber(NAStuff.ESP_OcclusionUpdateInterval) or 0.25, 0.05, 1), 0.05, " s", function(v)
	NAStuff.ESP_OcclusionUpdateInterval = math.clamp(tonumber(v) or 0.25, 0.05, 1)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
end)

NAgui.addSlider("Occlusion Ray Batch", 1, 128, math.clamp(math.floor(tonumber(NAStuff.ESP_OcclusionMaxPerStep) or 12), 1, 128), 1, " rays", function(v)
	NAStuff.ESP_OcclusionMaxPerStep = math.clamp(math.floor(tonumber(v) or 12), 1, 128)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
end)

NAgui.addSlider("Occlusion Hit Probe Limit", 1, 20, math.clamp(math.floor(tonumber(NAStuff.ESP_OcclusionHitProbeLimit) or 4), 1, 20), 1, " hits", function(v)
	NAStuff.ESP_OcclusionHitProbeLimit = math.clamp(math.floor(tonumber(v) or 4), 1, 20)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSlider("Occlusion Max Distance", 0, 10000, math.clamp(tonumber(NAStuff.ESP_OcclusionMaxDistance) or 1500, 0, 10000), 50, " studs", function(v)
	NAStuff.ESP_OcclusionMaxDistance = math.clamp(tonumber(v) or 1500, 0, 10000)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ClearOcclusionCache()
end)

NAgui.addSection("Label Content")

NAgui.addToggle("Show Name In Label", (NAStuff.ESP_ShowName ~= false), function(state)
	NAStuff.ESP_ShowName = state
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Show Health In Label", (NAStuff.ESP_ShowHealth ~= false), function(state)
	NAStuff.ESP_ShowHealth = state
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Show Team In Label", (NAStuff.ESP_ShowTeamText ~= false), function(state)
	NAStuff.ESP_ShowTeamText = state
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Show Distance In Label", (NAStuff.ESP_ShowDistance ~= false), function(state)
	NAStuff.ESP_ShowDistance = state
	NAmanage.SaveESPSettings()
end)

NAgui.addSection("Label Appearance")

NAgui.addSlider("Label Text Size", 8, 72, NAgui.sanitizeLabelSize(NAStuff.ESP_LabelTextSize), 1, " px", function(v)
	const size = NAgui.sanitizeLabelSize(v)
	NAStuff.ESP_LabelTextSize = size
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
end)

NAgui.addToggle("Label Text Scaled", NAStuff.ESP_LabelTextScaled, function(state)
	NAStuff.ESP_LabelTextScaled = state
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
end)

NAgui.addSlider("Label Stroke Transparency", 0, 1, math.clamp(tonumber(NAStuff.ESP_LabelStrokeTransparency) or 0.5, 0, 1), 0.05, "", function(v)
	NAStuff.ESP_LabelStrokeTransparency = math.clamp(tonumber(v) or 0.5, 0, 1)
	NAmanage.SaveESPSettings()
	NAmanage.ESP_ApplyLabelStyles()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addSection("Player ESP Locator Arrows")

NAgui.addToggle("Player ESP Locator Arrows", NAStuff.ESP_PlayerLocatorEnabled == true, function(state)
	NAmanage.ESP_SetPlayerLocatorEnabled(state)
end)

NAgui.addSlider("Player Locator Size", 12, 128, math.clamp(tonumber(NAStuff.ESP_PlayerLocatorSize) or 26, 12, 128), 1, " px", function(v)
	NAStuff.ESP_PlayerLocatorSize = math.clamp(tonumber(v) or 26, 12, 128)
	NAmanage.ESP_PlayerLocatorApplyFlags()
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Player Locator Show Text", NAStuff.ESP_PlayerLocatorShowText == true, function(state)
	NAmanage.ESP_SetPlayerLocatorShowText(state)
end)

NAgui.addSlider("Player Locator Text Size", 10, 48, math.clamp(tonumber(NAStuff.ESP_PlayerLocatorTextSize) or 14, 10, 48), 1, " px", function(v)
	NAStuff.ESP_PlayerLocatorTextSize = math.clamp(tonumber(v) or 14, 10, 48)
	NAmanage.ESP_PlayerLocatorApplyFlags()
	NAmanage.SaveESPSettings()
end)

NAgui.addSection("Waypoint ESP")

NAgui.addToggle("Waypoint ESP", (NAmanage.WaypointESPGetState and NAmanage.WaypointESPGetState().enabled == true) or false, function(state)
	if state then
		NAmanage.WaypointESPSetEnabled(true)
	else
		NAmanage.WaypointESPSetEnabled(false)
	end
end)
NAmanage.RegisterToggleAutoSync("Waypoint ESP", function()
	return NAmanage.WaypointESPGetState and NAmanage.WaypointESPGetState().enabled == true
end)

NAgui.addToggle("Waypoint ESP Box", NAStuff.WaypointESP_ShowBox == true, function(state)
	NAStuff.WaypointESP_ShowBox = state == true
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addToggle("Waypoint ESP Name Text", NAStuff.WaypointESP_ShowName ~= false, function(state)
	NAStuff.WaypointESP_ShowName = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addToggle("Waypoint ESP Distance Text", NAStuff.WaypointESP_ShowDistance ~= false, function(state)
	NAStuff.WaypointESP_ShowDistance = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addToggle("Waypoint ESP BuilderIcon", NAStuff.WaypointESP_ShowIcon ~= false, function(state)
	NAStuff.WaypointESP_ShowIcon = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addToggle("Waypoint ESP Highlight", NAStuff.WaypointESP_ShowHighlight ~= false, function(state)
	NAStuff.WaypointESP_ShowHighlight = state ~= false
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addToggle("Waypoint Path Nodes", NAStuff.WaypointPath_ShowNodes ~= false, function(state)
	NAStuff.WaypointPath_ShowNodes = state ~= false
	NAmanage.SaveESPSettings()
	if NAStuff.WaypointPath_ShowNodes ~= false then
		NAmanage.WaypointPathRedraw()
	else
		NAmanage.WaypointPathDestroy(false)
	end
end)

NAgui.addToggle("Waypoint Path Node Text", NAStuff.WaypointPath_ShowText == true, function(state)
	NAStuff.WaypointPath_ShowText = state == true
	NAmanage.SaveESPSettings()
	if type(NAmanage.WaypointPathApplyTextVisibility) == "function" then
		NAmanage.WaypointPathApplyTextVisibility()
	end
end)

NAgui.addSlider("Loop Path Tween Speed", 1, 500, math.clamp(tonumber(NAStuff.WaypointPath_TweenSpeed) or 24, 1, 500), 1, " studs/s", function(v)
	NAStuff.WaypointPath_TweenSpeed = math.clamp(tonumber(v) or 24, 1, 500)
	NAmanage.SaveESPSettings()
end)

NAgui.addSlider("Loop Path TP Delay", 0, 10, math.clamp(tonumber(NAStuff.WaypointPath_TeleportDelay) or 0.25, 0, 10), 0.05, " s", function(v)
	NAStuff.WaypointPath_TeleportDelay = math.clamp(tonumber(v) or 0.25, 0, 10)
	NAmanage.SaveESPSettings()
end)

NAgui.addColorPicker("Waypoint ESP Color", NAStuff.WaypointESP_Color or Color3.fromRGB(75, 155, 255), function(color)
	if typeof(color) ~= "Color3" then
		return
	end
	NAStuff.WaypointESP_Color = color
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addSlider("Waypoint Icon Size", 16, 96, math.clamp(tonumber(NAStuff.WaypointESP_IconSize) or 42, 16, 96), 1, " px", function(v)
	NAStuff.WaypointESP_IconSize = math.clamp(math.floor((tonumber(v) or 42) + 0.5), 16, 96)
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addSlider("Waypoint Text Size", 10, 48, math.clamp(tonumber(NAStuff.WaypointESP_TextSize) or 18, 10, 48), 1, " px", function(v)
	NAStuff.WaypointESP_TextSize = math.clamp(math.floor((tonumber(v) or 18) + 0.5), 10, 48)
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addSlider("Waypoint ESP Distance", 50, 100000, math.clamp(tonumber(NAStuff.WaypointESP_MaxDistance) or 100000, 50, 100000), 50, " studs", function(v)
	NAStuff.WaypointESP_MaxDistance = math.clamp(tonumber(v) or 100000, 50, 100000)
	NAmanage.SaveESPSettings()
	NAmanage.WaypointESPApplyOptions()
end)

NAgui.addSection("Part ESP")

NAgui.addToggle("Show Part ESP Text", (NAStuff.ESP_ShowPartText ~= false), function(state)
	NAStuff.ESP_ShowPartText = state
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_UpdateTexts(true)
end)

NAgui.addToggle("Show Part Distance", (NAStuff.ESP_ShowPartDistance == true), function(state)
	NAStuff.ESP_ShowPartDistance = state
	NAmanage.SaveESPSettings()
	NAmanage.PartESP_UpdateTexts(true)
end)

addPartESPColorPicker("Part ESP Name Color", "ESP_PartColor_Name", Color3.fromRGB(255, 255, 255), function(color)
	NAmanage.RecolorNameESPEntries(color)
end)
addPartESPColorPicker("Folder ESP Color", "ESP_PartColor_Folder", Color3.fromRGB(255, 220, 0), function(color)
	NAmanage.RecolorFolderESPEntries(color)
end)
addPartESPColorPicker("Model ESP Color", "ESP_PartColor_Model", Color3.fromRGB(0, 200, 255), function(color)
	NAmanage.RecolorModelESPEntries(color)
end)
addPartESPColorPicker("Touch ESP Color", "ESP_PartColor_Touch", Color3.fromRGB(255, 0, 0), function(color)
	NAmanage.RecolorPartESPList(NAStuff.touchESPList, color)
end)
addPartESPColorPicker("Proximity ESP Color", "ESP_PartColor_Proximity", Color3.fromRGB(0, 0, 255), function(color)
	NAmanage.RecolorPartESPList(NAStuff.proximityESPList, color)
end)
addPartESPColorPicker("Click ESP Color", "ESP_PartColor_Click", Color3.fromRGB(255, 165, 0), function(color)
	NAmanage.RecolorPartESPList(NAStuff.clickESPList, color)
end)
addPartESPColorPicker("Item ESP Color", "ESP_PartColor_Item", Color3.fromRGB(90, 255, 135), function(color)
	if NAStuff.itemESPEnabled == true then
		NAmanage.ItemESPRefresh(true)
	else
		NAmanage.RecolorPartESPList(NAStuff.itemESPList, color)
	end
end)
addPartESPColorPicker("Seat ESP Color", "ESP_PartColor_Seat", Color3.fromRGB(0, 255, 0), function(color)
	NAmanage.RecolorPartESPList(NAStuff.siteESPList, color)
end)
addPartESPColorPicker("Vehicle Seat ESP Color", "ESP_PartColor_VehicleSeat", Color3.fromRGB(255, 0, 255), function(color)
	NAmanage.RecolorPartESPList(NAStuff.vehicleSiteESPList, color)
end)
addPartESPColorPicker("Unanchored ESP Color", "ESP_PartColor_Unanchored", Color3.fromRGB(255, 220, 0), function(color)
	NAmanage.RecolorPartESPList(NAStuff.unanchoredESPList, color)
end)
addPartESPColorPicker("Collidable ESP Color", "ESP_PartColor_CollisionTrue", Color3.fromRGB(0, 200, 255), function(color)
	NAmanage.RecolorPartESPList(NAStuff.collisiontrueESPList, color)
end)
addPartESPColorPicker("Non-Collidable ESP Color", "ESP_PartColor_CollisionFalse", Color3.fromRGB(255, 120, 120), function(color)
	NAmanage.RecolorPartESPList(NAStuff.collisionfalseESPList, color)
end)
addPartESPColorPicker("Property ESP Color", "ESP_PartColor_Property", Color3.fromRGB(190, 120, 255), function(color)
	NAmanage.RecolorPartESPList(NAStuff.propertyESPList, color)
end)

NAgui.addSection("Part ESP Locator Arrows")

NAgui.addToggle("ESP Locator Arrows", NAStuff.ESP_LocatorEnabled == true, function(state)
	NAmanage.ESP_SetLocatorEnabled(state)
end)

NAgui.addSlider("Locator Size", 12, 128, math.clamp(tonumber(NAStuff.ESP_LocatorSize) or 26, 12, 128), 1, " px", function(v)
	NAStuff.ESP_LocatorSize = math.clamp(tonumber(v) or 26, 12, 128)
	NAmanage.ESP_LocatorApplyFlags()
	NAmanage.SaveESPSettings()
end)

NAgui.addToggle("Locator Show Text", NAStuff.ESP_LocatorShowText == true, function(state)
	NAmanage.ESP_SetLocatorShowText(state)
end)

NAgui.addSlider("Locator Text Size", 10, 48, math.clamp(tonumber(NAStuff.ESP_LocatorTextSize) or 14, 10, 48), 1, " px", function(v)
	NAStuff.ESP_LocatorTextSize = math.clamp(tonumber(v) or 14, 10, 48)
	NAmanage.ESP_LocatorApplyFlags()
	NAmanage.SaveESPSettings()
end)

NAgui.addSection("Interactable ESP (touchesp/proximityesp/clickesp)")

NAgui.addToggle("Touch ESP", NAgui.isListActive(NAStuff.touchESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"touchesp"})
		else
			cmd.run({"untouchesp"})
		end
	end)
end)

NAgui.addToggle("Proximity Prompt ESP", NAgui.isListActive(NAStuff.proximityESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"proximityesp"})
		else
			cmd.run({"unproximityesp"})
		end
	end)
end)

NAgui.addToggle("Click Detector ESP", NAgui.isListActive(NAStuff.clickESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"clickesp"})
		else
			cmd.run({"unclickesp"})
		end
	end)
end)

NAgui.addToggle("Item ESP", NAStuff.itemESPEnabled == true or NAgui.isListActive(NAStuff.itemESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"itemesp"})
		else
			cmd.run({"unitemesp"})
		end
	end)
end)

NAgui.addSection("Seat ESP")

NAgui.addToggle("Seat ESP", NAgui.isListActive(NAStuff.siteESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"sitesp"})
		else
			cmd.run({"unsitesp"})
		end
	end)
end)

NAgui.addToggle("Vehicle Seat ESP", NAgui.isListActive(NAStuff.vehicleSiteESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"vehiclesitesp"})
		else
			cmd.run({"unvehiclesitesp"})
		end
	end)
end)

NAgui.addSection("Physics ESP | AKA: lag section")

NAgui.addToggle("Unanchored Parts ESP", NAgui.isListActive(NAStuff.unanchoredESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"unanchored"})
		else
			cmd.run({"ununanchored"})
		end
	end)
end)

NAgui.addToggle("Collidable Parts ESP", NAgui.isListActive(NAStuff.collisiontrueESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"collisionesp"})
		else
			cmd.run({"uncollisionesp"})
		end
	end)
end)

NAgui.addToggle("Non-Collidable Parts ESP", NAgui.isListActive(NAStuff.collisionfalseESPList), function(state)
	SpawnCall(function()
		if state then
			cmd.run({"nocollisionesp"})
		else
			cmd.run({"unnocollisionesp"})
		end
	end)
end)

NAgui.addSection("Part ESP")

NAgui.addInput("Shape", "Block/Ball/Cylinder/Wedge/CornerWedge", NAStuff.ESP_LastShapeESP, function(text)
	NAStuff.ESP_LastShapeESP = text
end)

NAgui.addButton("Apply Shape ESP", function()
	const rawShape = NAgui.trimText(NAStuff.ESP_LastShapeESP)
	if rawShape == "" then
		SpawnCall(function() cmd.run({"shapeesp"}) end)
		return
	end
	const shapeName = NAmanage.PropertyESP_ResolvePartShape(rawShape)
	if not shapeName then
		DoNotif("No matching shape for: "..rawShape, 3)
		return
	end
	NAStuff.ESP_LastShapeESP = shapeName
	SpawnCall(function() cmd.run({"shapeesp", shapeName}) end)
end)

NAgui.addButton("Clear Shape ESP", function()
	SpawnCall(function() cmd.run({"unshapeesp"}) end)
end)

NAgui.addInput("Property Finder", "Shape Block / Shape=Block", NAStuff.ESP_LastPropertyESP, function(text)
	NAStuff.ESP_LastPropertyESP = text
end)

NAgui.addButton("Apply Property ESP", function()
	const rawInput = NAgui.trimText(NAStuff.ESP_LastPropertyESP)
	if rawInput == "" then
		DoNotif("Enter a property and value before using propertyesp.", 2)
		return
	end
	SpawnCall(function() cmd.run({"propertyesp", rawInput}) end)
end)

NAgui.addButton("Clear Property ESP", function()
	SpawnCall(function() cmd.run({"unpropertyesp"}) end)
end)

NAgui.addInput("Exact Part Name", "Exact part name (partesp)", NAStuff.ESP_LastExactPart, function(text)
	NAStuff.ESP_LastExactPart = text
end)

NAgui.addButton("Apply Exact Part ESP", function()
	const name = NAgui.trimText(NAStuff.ESP_LastExactPart)
	if name == "" then
		DoNotif("Enter an exact part name before using partesp.", 2)
		return
	end
	SpawnCall(function() cmd.run({"pesp", name}) end)
end)

NAgui.addButton("Clear Exact Part ESP", function()
	SpawnCall(function() cmd.run({"unpesp"}) end)
end)

NAgui.addInput("Partial Part Name", "Partial part name (pespfind)", NAStuff.ESP_LastPartialPart, function(text)
	NAStuff.ESP_LastPartialPart = text
end)

NAgui.addButton("Apply Partial Part ESP", function()
	const name = NAgui.trimText(NAStuff.ESP_LastPartialPart)
	if name == "" then
		DoNotif("Enter a partial part name before using pespfind.", 2)
		return
	end
	SpawnCall(function() cmd.run({"pespfind", name}) end)
end)

NAgui.addButton("Clear Partial Part ESP", function()
	SpawnCall(function() cmd.run({"unpespfind"}) end)
end)

NAgui.addSection("Folder ESP")

NAgui.addToggle("Highlight Folder ESP By Models", (NAStuff.ESP_FolderMode == "models"), function(state)
	NAStuff.ESP_FolderMode = state and "models" or "parts"
	NAmanage.SaveESPSettings()
	DoNotif("Folder ESP will highlight by "..(state and "models" or "parts")..".", 2)
	if NAmanage.FolderESP_RefreshActive then
		NAmanage.FolderESP_RefreshActive()
	end
end)

NAgui.addInput("Folder Name", "Folder name to highlight", NAStuff.ESP_LastFolderName, function(text)
	NAStuff.ESP_LastFolderName = text
end)

NAgui.addButton("Apply Folder ESP", function()
	const name = NAgui.trimText(NAStuff.ESP_LastFolderName)
	if name == "" then
		DoNotif("Enter a folder name before using folderesp.", 2)
		return
	end
	SpawnCall(function() cmd.run({"folderesp", name}) end)
end)

NAgui.addButton("Clear Folder ESP", function()
	const name = NAgui.trimText(NAStuff.ESP_LastFolderName)
	SpawnCall(function()
		if name ~= "" then
			cmd.run({"unfolderesp", name})
		else
			cmd.run({"unfolderesp"})
		end
	end)
end)

NAgui.addSection("Model ESP")

NAgui.addToggle("Highlight Model ESP By Models", (NAStuff.ESP_ModelMode == "models"), function(state)
	NAStuff.ESP_ModelMode = state and "models" or "parts"
	NAmanage.SaveESPSettings()
	DoNotif("Model ESP will highlight by "..(state and "models" or "parts")..".", 2)
	if NAmanage.ModelESP_RefreshActive then
		NAmanage.ModelESP_RefreshActive()
	end
end)

NAgui.addInput("Model Name", "Model name to highlight", NAStuff.ESP_LastModelName, function(text)
	NAStuff.ESP_LastModelName = text
end)

NAgui.addButton("Apply Model ESP", function()
	const name = NAgui.trimText(NAStuff.ESP_LastModelName)
	if name == "" then
		DoNotif("Enter a model name before using modelesp.", 2)
		return
	end
	SpawnCall(function() cmd.run({"modelesp", name}) end)
end)

NAgui.addButton("Clear Model ESP", function()
	const name = NAgui.trimText(NAStuff.ESP_LastModelName)
	SpawnCall(function()
		if name ~= "" then
			cmd.run({"unmodelesp", name})
		else
			cmd.run({"unmodelesp"})
		end
	end)
end)

NAgui.addTab(NA_TABS.TAB_CHAT, { order = 7, textIcon = "speech-bubble-align-center" })
NAgui.setTab(NA_TABS.TAB_CHAT)

do
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
	const function dropdownValue(selection, fallback)
		if type(selection) == "table" then
			selection = selection[1]
		end
		if selection == nil then
			return fallback
		end
		return tostring(selection)
	end
	const function saveApplyChat()
		NAmanage.SaveTextChatSettings()
		NAmanage.ApplyTextChatSettings()
	end
	const function updateBubbleLocalOffset(index, value)
		const bubbles = NAStuff.ChatSettings.bubbles
		local current = bubbles.localPlayerStudsOffset
		if type(current) ~= "table" then
			current = {0,0,0}
			bubbles.localPlayerStudsOffset = current
		end
		current[index] = tonumber(value) or 0
		saveApplyChat()
	end
	const bubbleOffsetDefault = NAStuff.ChatSettings.bubbles.localPlayerStudsOffset or {}
	const chatChannelDropdownLabel = "Target Chat Channel"
	const function getTextChatChannelOptions()
		if NAmanage.GetTextChatChannelOptions then
			return NAmanage.GetTextChatChannelOptions()
		end
		return { "Keep Default" }
	end

	NAgui.addSection("Text Chat")
	NAgui.addToggle("Enable Custom Chat Styling", NAStuff.ChatSettings.customEnabled, function(v)
		const wasEnabled = NAStuff.ChatSettings.customEnabled == true
		NAStuff.ChatSettings.customEnabled = v

		if wasEnabled and not v then
			originalIO.backupChatSection("bubbles")
			if not originalIO.assignChatSectionFromTemplate("bubbles") then
				originalIO.restoreChatSectionFromBackup("bubbles")
			end
		elseif v and not wasEnabled then
			if not originalIO.restoreChatSectionFromBackup("bubbles") and type(NAStuff.ChatSettings.bubbles) ~= "table" then
				originalIO.assignChatSectionFromTemplate("bubbles")
			end
		end

		NAmanage.SaveTextChatSettings()
		NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addButton("Reset Custom Chat Settings", function()
		local ok, err = pcall(function()
			const template = NAStuff.ChatSettingsTemplate
			if type(template) ~= "table" then
				error("Chat default settings unavailable.")
			end

			local current = NAStuff.ChatSettings
			const preserveCustom = (current and current.customEnabled) or false
			const preserveCoreChat = (current and current.coreGuiChat ~= nil) and current.coreGuiChat or true
			const preserveCoreChatLoop = (current and current.coreGuiChatLoop == true)
			const templateCopy = originalIO.deepCopyTable(template)

			if type(current) ~= "table" then
				current = {}
				NAStuff.ChatSettings = current
			end

			for key in current do
				current[key] = nil
			end
			for key, value in templateCopy do
				current[key] = value
			end

			NAStuff.ChatSettingsCustomBackup = nil
			current.customEnabled = preserveCustom
			current.coreGuiChat = preserveCoreChat
			current.coreGuiChatLoop = preserveCoreChatLoop

			NAStuff.ChatCustomizationActive = nil
			NAmanage.SaveTextChatSettings()
			NAmanage.ApplyTextChatSettings()
		end)

		if ok then
			DoNotif("Chat style options reset to defaults.", 2)
		else
			warn("[NA] Reset Custom Chat Settings failed:", err)
			DoNotif("Failed to reset chat settings. Check console for details.", 3)
		end
	end)

	NAgui.addToggle("Enable Chat (CoreGui)", NAStuff.ChatSettings.coreGuiChat, function(v)
		NAStuff.ChatSettings.coreGuiChat = v
		NAStuff.ChatSettingsDirty = true
		NAmanage.SaveTextChatSettings()
		NAmanage.ApplyTextChatSettings(true)
	end)

	NAgui.addToggle("Loop Chat CoreGui Apply", NAStuff.ChatSettings.coreGuiChatLoop == true, function(v)
		NAStuff.ChatSettings.coreGuiChatLoop = v == true
		NAStuff.ChatSettingsDirty = true
		NAmanage.SaveTextChatSettings()
		NAmanage.ApplyTextChatSettings(true)
	end)

	NAgui.addSection("Chat Window")
	NAgui.addToggle("Window Enabled", NAStuff.ChatSettings.window.enabled, function(v)
		NAStuff.ChatSettings.window.enabled = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addInput("Window Font Asset", "rbxasset://fonts/families/BuilderSans.json", NAStuff.ChatSettings.window.font or "", function(text)
		NAStuff.ChatSettings.window.font = tostring(text or ""); saveApplyChat()
	end)
	NAgui.addSlider("Window Width Scale", 0.5, 2, tonumber(NAStuff.ChatSettings.window.widthScale) or 1, 0.05, "", function(v)
		NAStuff.ChatSettings.window.widthScale = v; saveApplyChat()
	end)
	NAgui.addSlider("Window Height Scale", 0.5, 2, tonumber(NAStuff.ChatSettings.window.heightScale) or 1, 0.05, "", function(v)
		NAStuff.ChatSettings.window.heightScale = v; saveApplyChat()
	end)
	NAgui.addDropdown("Window Horizontal Alignment", { "Left", "Center", "Right" }, tostring(NAStuff.ChatSettings.window.horizontalAlignment or "Left"), function(selection)
		NAStuff.ChatSettings.window.horizontalAlignment = dropdownValue(selection, "Left"); saveApplyChat()
	end)
	NAgui.addDropdown("Window Vertical Alignment", { "Top", "Center", "Bottom" }, tostring(NAStuff.ChatSettings.window.verticalAlignment or "Top"), function(selection)
		NAStuff.ChatSettings.window.verticalAlignment = dropdownValue(selection, "Top"); saveApplyChat()
	end)
	NAgui.addSlider("Text Size (Window)", 5, 50, NAStuff.ChatSettings.window.textSize, 1, " px", function(v)
		NAStuff.ChatSettings.window.textSize = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Text Color", tblToC3(NAStuff.ChatSettings.window.textColor), function(c)
		NAStuff.ChatSettings.window.textColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Text Transparency (Window)", 0, 1, NAStuff.ChatSettings.window.textTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.window.textTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Text Stroke Color", tblToC3(NAStuff.ChatSettings.window.strokeColor), function(c)
		NAStuff.ChatSettings.window.strokeColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Text Stroke Transparency", 0, 1, NAStuff.ChatSettings.window.strokeTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.window.strokeTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Window Background", tblToC3(NAStuff.ChatSettings.window.backgroundColor), function(c)
		NAStuff.ChatSettings.window.backgroundColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Window Background Transparency", 0, 1, NAStuff.ChatSettings.window.backgroundTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.window.backgroundTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)

	NAgui.addSection("Channel Tabs")
	NAgui.addToggle("Tabs Enabled", NAStuff.ChatSettings.tabs.enabled, function(v)
		NAStuff.ChatSettings.tabs.enabled = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addInput("Tabs Font Asset", "rbxasset://fonts/families/BuilderSans.json", NAStuff.ChatSettings.tabs.font or "", function(text)
		NAStuff.ChatSettings.tabs.font = tostring(text or ""); saveApplyChat()
	end)
	NAgui.addSlider("Text Size (Tabs)", 5, 50, NAStuff.ChatSettings.tabs.textSize, 1, " px", function(v)
		NAStuff.ChatSettings.tabs.textSize = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Tab Background", tblToC3(NAStuff.ChatSettings.tabs.backgroundColor), function(c)
		NAStuff.ChatSettings.tabs.backgroundColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Background Transparency (Tabs)", 0, 1, NAStuff.ChatSettings.tabs.backgroundTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.tabs.backgroundTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Tab Hover Background", tblToC3(NAStuff.ChatSettings.tabs.hoverBackgroundColor), function(c)
		NAStuff.ChatSettings.tabs.hoverBackgroundColor = c3ToTbl(c); saveApplyChat()
	end)
	NAgui.addSlider("Text Transparency (Tabs)", 0, 1, NAStuff.ChatSettings.tabs.textTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.tabs.textTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Text Color (Tabs)", tblToC3(NAStuff.ChatSettings.tabs.textColor), function(c)
		NAStuff.ChatSettings.tabs.textColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Selected Text Color", tblToC3(NAStuff.ChatSettings.tabs.selectedTextColor), function(c)
		NAStuff.ChatSettings.tabs.selectedTextColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Unselected Text Color", tblToC3(NAStuff.ChatSettings.tabs.unselectedTextColor), function(c)
		NAStuff.ChatSettings.tabs.unselectedTextColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Text Stroke Color (Tabs)", tblToC3(NAStuff.ChatSettings.tabs.strokeColor), function(c)
		NAStuff.ChatSettings.tabs.strokeColor = c3ToTbl(c); saveApplyChat()
	end)
	NAgui.addSlider("Text Stroke Transparency (Tabs)", 0, 1, tonumber(NAStuff.ChatSettings.tabs.strokeTransparency) or 0.5, 0.05, "", function(v)
		NAStuff.ChatSettings.tabs.strokeTransparency = v; saveApplyChat()
	end)

	NAgui.addSection("Chat Input")
	NAgui.addToggle("Input Enabled", NAStuff.ChatSettings.input.enabled, function(v)
		NAStuff.ChatSettings.input.enabled = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addInput("Input Font Asset", "rbxasset://fonts/families/BuilderSans.json", NAStuff.ChatSettings.input.font or "", function(text)
		NAStuff.ChatSettings.input.font = tostring(text or ""); saveApplyChat()
	end)
	NAgui.addToggle("Autocomplete", NAStuff.ChatSettings.input.autocomplete, function(v)
		NAStuff.ChatSettings.input.autocomplete = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addToggle("Target #RBXGeneral", NAStuff.ChatSettings.input.targetGeneral, function(v)
		NAStuff.ChatSettings.input.targetGeneral = v
		if v then
			NAStuff.ChatSettings.input.targetChannel = "RBXGeneral"
		elseif NAStuff.ChatSettings.input.targetChannel == "RBXGeneral" then
			NAStuff.ChatSettings.input.targetChannel = ""
		end
		saveApplyChat()
	end)
	NAgui.addDropdown(chatChannelDropdownLabel, getTextChatChannelOptions(), (type(NAStuff.ChatSettings.input.targetChannel) == "string" and NAStuff.ChatSettings.input.targetChannel ~= "") and NAStuff.ChatSettings.input.targetChannel or (NAStuff.ChatSettings.input.targetGeneral and "RBXGeneral" or "Keep Default"), function(selection)
		const channelName = dropdownValue(selection, "Keep Default")
		if channelName == "Keep Default" then
			NAStuff.ChatSettings.input.targetChannel = ""
			NAStuff.ChatSettings.input.targetGeneral = false
		else
			NAStuff.ChatSettings.input.targetChannel = channelName
			NAStuff.ChatSettings.input.targetGeneral = (channelName == "RBXGeneral")
		end
		saveApplyChat()
	end)
	NAgui.addSlider("Text Size (Input)", 5, 25, NAStuff.ChatSettings.input.textSize, 1, " px", function(v)
		NAStuff.ChatSettings.input.textSize = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Text Color (Input)", tblToC3(NAStuff.ChatSettings.input.textColor), function(c)
		NAStuff.ChatSettings.input.textColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Input Stroke Color", tblToC3(NAStuff.ChatSettings.input.strokeColor), function(c)
		NAStuff.ChatSettings.input.strokeColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Text Stroke Transparency (Input)", 0, 1, NAStuff.ChatSettings.input.strokeTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.input.strokeTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Placeholder Color", tblToC3(NAStuff.ChatSettings.input.placeholderColor), function(c)
		NAStuff.ChatSettings.input.placeholderColor = c3ToTbl(c); saveApplyChat()
	end)
	NAgui.addColorPicker("Input Background", tblToC3(NAStuff.ChatSettings.input.backgroundColor), function(c)
		NAStuff.ChatSettings.input.backgroundColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Background Transparency (Input)", 0, 1, NAStuff.ChatSettings.input.backgroundTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.input.backgroundTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	if not IsOnMobile then
		NAgui.addKeybind("Chat Key", NAStuff.ChatSettings.input.keyCode or "Slash", function(keyName)
			NAStuff.ChatSettings.input.keyCode = tostring(keyName or "Slash"); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
		end)
	end

	NAgui.addSection("Bubble Chat")
	NAgui.addToggle("Bubbles Enabled", NAStuff.ChatSettings.bubbles.enabled, function(v)
		NAStuff.ChatSettings.bubbles.enabled = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addInput("Bubble Font Asset", "leave blank to use Roblox default", NAStuff.ChatSettings.bubbles.font or "", function(text)
		NAStuff.ChatSettings.bubbles.font = tostring(text or ""); saveApplyChat()
	end)
	NAgui.addInput("Bubble Adornee Name", "HumanoidRootPart", NAStuff.ChatSettings.bubbles.adorneeName or "HumanoidRootPart", function(text)
		NAStuff.ChatSettings.bubbles.adorneeName = tostring(text or "HumanoidRootPart"); saveApplyChat()
	end)
	NAgui.addSlider("Max Distance", 10, 500, NAStuff.ChatSettings.bubbles.maxDistance, 5, " u", function(v)
		NAStuff.ChatSettings.bubbles.maxDistance = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Minimize Distance", 0, 350, NAStuff.ChatSettings.bubbles.minimizeDistance, 2, " u", function(v)
		NAStuff.ChatSettings.bubbles.minimizeDistance = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Vertical Studs Offset", -10, 20, tonumber(NAStuff.ChatSettings.bubbles.verticalStudsOffset) or 0, 0.25, "", function(v)
		NAStuff.ChatSettings.bubbles.verticalStudsOffset = v; saveApplyChat()
	end)
	NAgui.addSlider("Local Player Offset X", -20, 20, tonumber(bubbleOffsetDefault[1] or bubbleOffsetDefault.X) or 0, 0.25, "", function(v)
		updateBubbleLocalOffset(1, v)
	end)
	NAgui.addSlider("Local Player Offset Y", -20, 20, tonumber(bubbleOffsetDefault[2] or bubbleOffsetDefault.Y) or 0, 0.25, "", function(v)
		updateBubbleLocalOffset(2, v)
	end)
	NAgui.addSlider("Local Player Offset Z", -20, 20, tonumber(bubbleOffsetDefault[3] or bubbleOffsetDefault.Z) or 0, 0.25, "", function(v)
		updateBubbleLocalOffset(3, v)
	end)
	NAgui.addSlider("Text Size (Bubble)", 5, 30, NAStuff.ChatSettings.bubbles.textSize, 1, " px", function(v)
		NAStuff.ChatSettings.bubbles.textSize = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Bubble Text Color", tblToC3(NAStuff.ChatSettings.bubbles.textColor), function(c)
		NAStuff.ChatSettings.bubbles.textColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Text Transparency (Bubble)", 0, 1, NAStuff.ChatSettings.bubbles.textTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.bubbles.textTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Bubble Spacing", 0, 12, NAStuff.ChatSettings.bubbles.spacing, 1, " px", function(v)
		NAStuff.ChatSettings.bubbles.spacing = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addColorPicker("Bubble Background", tblToC3(NAStuff.ChatSettings.bubbles.backgroundColor), function(c)
		NAStuff.ChatSettings.bubbles.backgroundColor = c3ToTbl(c); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Background Transparency (Bubble)", 0, 1, NAStuff.ChatSettings.bubbles.backgroundTransparency, 0.05, "", function(v)
		NAStuff.ChatSettings.bubbles.backgroundTransparency = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Bubble Duration", 3, 30, NAStuff.ChatSettings.bubbles.bubbleDuration, 1, " s", function(v)
		NAStuff.ChatSettings.bubbles.bubbleDuration = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addSlider("Max Bubbles", 1, 5, math.min(5, NAStuff.ChatSettings.bubbles.maxBubbles or 1), 1, "", function(v)
		NAStuff.ChatSettings.bubbles.maxBubbles = math.min(5, v); NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
	NAgui.addToggle("Tail Visible", NAStuff.ChatSettings.bubbles.tailVisible, function(v)
		NAStuff.ChatSettings.bubbles.tailVisible = v; NAmanage.SaveTextChatSettings(); NAmanage.ApplyTextChatSettings()
	end)
end

if not IsOnMobile or NAmanage.CanUseCommandKeybinds() then
	NAgui.addTab(NA_TABS.TAB_KEYBINDS, { order = 8, textIcon = "xbox-a" })
	NAgui.setTab(NA_TABS.TAB_KEYBINDS)

	if IsOnPC then
		NAgui.addSection("Control Lock")
		NAgui.addKeybind("Add Shiftlock Key","LeftShift",function(k)
			if k then NAmanage.ControlLock_AddKey(k) end
		end)
		NAgui.addKeybind("Remove Shiftlock Key","RightShift",function(k)
			if k then NAmanage.ControlLock_RemoveKey(k) end
		end)
		NAgui.addButton("Apply Saved Keys",function()
			NAmanage.ControlLock_Apply(NAStuff._ctrlLockKeys)
		end)
		NAgui.addButton("Reset To Default (Shift)",function()
			NAmanage.ControlLock_ClearToDefault()
		end)
		NAgui.addToggle("Reapply On Respawn",NAStuff._ctrlLockPersist,function(state)
			NAStuff._ctrlLockPersist = state and true or false
			NAmanage.ControlLock_Bind()
		end)

		NAgui.addSection("Fly Keybinds")
		const function createFlyKeybindHandler(varField, connField, connectFunc, successTemplate, emptyMessage)
			emptyMessage = emptyMessage or "Please provide a keybind."
			return function(keyName)
				if keyName == nil then
					return
				end
				const newKey = NAmanage.normalizeFlyBindKey(keyName)
				if newKey == "" then
					DoNotif(emptyMessage)
					return
				end
				flyVariables[varField] = newKey
				const existingConn = flyVariables[connField]
				if existingConn then
					existingConn:Disconnect()
					flyVariables[connField] = nil
				end
				connectFunc()
				NAmanage.SaveFlyKeybinds()
				DebugNotif(Format(successTemplate, newKey:upper()))
			end
		end

		NAgui.addKeybind("Fly Keybind", string.upper(flyVariables.toggleKey or "F"), createFlyKeybindHandler(
			"toggleKey",
			"keybindConn",
			NAmanage.connectFlyKey,
			"Fly keybind set to '%s'"
			))

		NAgui.addKeybind("vFly Keybind", string.upper(flyVariables.vToggleKey or "V"), createFlyKeybindHandler(
			"vToggleKey",
			"vKeybindConn",
			NAmanage.connectVFlyKey,
			"vFly keybind set to '%s'"
			))

		NAgui.addKeybind("cFly Keybind", string.upper(flyVariables.cToggleKey or "C"), createFlyKeybindHandler(
			"cToggleKey",
			"cKeybindConn",
			NAmanage.connectCFlyKey,
			"CFrame fly keybind set to '%s'"
			))

		NAgui.addKeybind("tFly Keybind", string.upper(flyVariables.tflyToggleKey or "T"), createFlyKeybindHandler(
			"tflyToggleKey",
			"tflyKeyConn",
			NAmanage.connectTFlyKey,
			"TFly keybind set to '%s'",
			"Please provide a key."
			))

		NAgui.addSection("Fly / Freecam Vertical")
		const function createStoredFlyKeyHandler(varField, successTemplate, afterSave)
			return function(keyName)
				if keyName == nil then
					return
				end
				const newKey = NAmanage.normalizeFlyBindKey(keyName)
				if newKey == "" then
					DoNotif("Please provide a key.")
					return
				end
				flyVariables[varField] = newKey
				if type(afterSave) == "function" then
					afterSave(newKey)
				end
				NAmanage.SaveFlyKeybinds()
				DebugNotif(Format(successTemplate, newKey:upper()))
			end
		end
		const function restartFreecamIfRunning()
			if NAFreecam and NAFreecam.IsEnabled and NAFreecam.IsEnabled() then
				const speed = math.clamp((tonumber(NAStuff.FreecamSpeed) or 5) / 5, 0.01, 4)
				NAFreecam.Stop()
				NAFreecam.Start(speed)
			end
		end
		NAgui.addKeybind("Fly Up Key", string.upper(flyVariables.flyUpKey or "E"), createStoredFlyKeyHandler(
			"flyUpKey",
			"Fly up key set to '%s'"
			))
		NAgui.addKeybind("Fly Down Key", string.upper(flyVariables.flyDownKey or "Q"), createStoredFlyKeyHandler(
			"flyDownKey",
			"Fly down key set to '%s'"
			))
		NAgui.addKeybind("Freecam Up Key", string.upper(flyVariables.freecamUpKey or "E"), createStoredFlyKeyHandler(
			"freecamUpKey",
			"Freecam up key set to '%s'",
			function(newKey)
				NAStuff.FreecamUpKey = newKey
				restartFreecamIfRunning()
			end
			))
		NAgui.addKeybind("Freecam Down Key", string.upper(flyVariables.freecamDownKey or "Q"), createStoredFlyKeyHandler(
			"freecamDownKey",
			"Freecam down key set to '%s'",
			function(newKey)
				NAStuff.FreecamDownKey = newKey
				restartFreecamIfRunning()
			end
			))

	end

	if NAmanage.CanUseCommandKeybinds() then
		NAgui.addSection("Command Keybinds")
		NAgui.addButton("Open Command Keybinds", function()
			NAgui.commandkeybinds()
		end)
		if NAmanage.CommandKeybindsUIInit() then
			NAmanage.CommandKeybindsUIWire()
			NAmanage.CommandKeybindsUIRefresh()
		end
	end
end

NAgui.addTab(NA_TABS.TAB_CHARACTER, { order = 6, textIcon = "circle-person" })
NAgui.setTab(NA_TABS.TAB_CHARACTER)

NAmanage.ApplyWalkSpeed = function(val)
	const hum = getHum(getChar())
	if hum then
		hum.WalkSpeed = val
	end
end

NAmanage.ApplyJump = function(val)
	const hum = getHum(getChar())
	if hum then
		if hum.UseJumpPower ~= false then
			hum.JumpPower = val
		else
			hum.JumpHeight = val
		end
	end
end

NAgui.addSection("Methods")
NAmanage.SetEnhancedPhysicsReplication = NAmanage.SetEnhancedPhysicsReplication or function(enabled, opts)
	const rate = enabled == true and 64 or 15
	return NAmanage.ApplyStandaloneFFlag("S2PhysicsSenderRate", rate, opts), rate
end

NAmanage.SetEnhancedPhysicsReplication(NAStuff.EnhancedPhysicsReplication == true, { silent = true })
NAgui.addToggle("Enhanced Physics Replication", NAStuff.EnhancedPhysicsReplication == true, function(v)
	const enabled = v == true
	local ok, rate = NAmanage.SetEnhancedPhysicsReplication(enabled)
	if not ok then
		return
	end
	NAStuff.EnhancedPhysicsReplication = enabled
	pcall(NAmanage.NASettingsSet, "enhancedPhysicsReplication", enabled)
	DoNotif("Physics sender rate set to "..tostring(rate), 2)
end)
NAmanage.RegisterToggleAutoSync("Enhanced Physics Replication", function()
	return NAStuff.EnhancedPhysicsReplication == true
end)

NAgui.addToggle("Safe Speed Method", NAStuff.SafeSpeedMethod ~= false, function(state)
	NAStuff.SafeSpeedMethod = state ~= false
	NAmanage.NASettingsSet("safeSpeedMethod", NAStuff.SafeSpeedMethod)
	NAmanage.SyncSpeedMethodState()
end)
NAmanage.RegisterToggleAutoSync("Safe Speed Method", function()
	return NAStuff.SafeSpeedMethod ~= false
end)

NAgui.addToggle("Safe Jump Method", NAStuff.SafeJumpMethod ~= false, function(state)
	NAStuff.SafeJumpMethod = state ~= false
	NAmanage.NASettingsSet("safeJumpMethod", NAStuff.SafeJumpMethod)
end)
NAmanage.RegisterToggleAutoSync("Safe Jump Method", function()
	return NAStuff.SafeJumpMethod ~= false
end)

NAgui.addSection("Offset Customization")
NAgui.addSlider("Offset Position X", -100, 100, NAmanage.UG_getCustomization().positionX, 0.5, " studs", function(value)
	NAmanage.UG_setCustomizationValue("positionX", value)
end)
NAgui.addSlider("Offset Position Y", -100, 100, NAmanage.UG_getCustomization().positionY, 0.5, " studs", function(value)
	NAmanage.UG_setCustomizationValue("positionY", value)
end)
NAgui.addSlider("Offset Position Z", -100, 100, NAmanage.UG_getCustomization().positionZ, 0.5, " studs", function(value)
	NAmanage.UG_setCustomizationValue("positionZ", value)
end)
NAgui.addDropdown("Offset Rotation Preset", NAStuff.OffsetRotationPresetOrder, NAmanage.UG_getCustomization().preset, function(selection)
	NAmanage.UG_applyRotationPreset(selection)
end)
NAgui.addSlider("Offset Rotation X", -180, 180, NAmanage.UG_getCustomization().rotationX, 1, "°", function(value)
	NAmanage.UG_setCustomizationValue("rotationX", value)
end)
NAgui.addSlider("Offset Rotation Y", -180, 180, NAmanage.UG_getCustomization().rotationY, 1, "°", function(value)
	NAmanage.UG_setCustomizationValue("rotationY", value)
end)
NAgui.addSlider("Offset Rotation Z", -180, 180, NAmanage.UG_getCustomization().rotationZ, 1, "°", function(value)
	NAmanage.UG_setCustomizationValue("rotationZ", value)
end)
NAgui.addButton("Enable / Update Offset", function()
	const wasActive = NAStuff.NAundergroundState.Underground == true and NAStuff.NAundergroundState.UndergroundOffsetActive == true
	if NAmanage.UG_enableConfiguredOffset() then
		DoNotif(wasActive and "Offset customization updated" or "Offset customization enabled", 2)
	else
		DoNotif("Character is not ready yet", 2)
	end
end)
NAgui.addButton("Reset Offset Rotation", function()
	NAmanage.UG_setConfiguredRotation(Vector3.new(0, 0, 0), "Normal", true)
	NAmanage.UG_applyCustomization()
	DoNotif("Offset rotation reset", 2)
end)
NAgui.addButton("Reset Offset Customization", function()
	NAmanage.UG_setConfiguredOffset(Vector3.new(0, -15, 0), false)
	NAmanage.UG_setConfiguredRotation(Vector3.new(0, 0, 0), "Normal", false)
	NAmanage.UG_syncCustomizationUI()
	NAmanage.UG_applyCustomization()
	DoNotif("Offset customization reset", 2)
end)

NAStuff.CustomMovementSounds = NAStuff.CustomMovementSounds or {
	Enabled = false,
	WalkInput = "",
	JumpInput = "",
	FallInput = "",
	LandInput = "",
	Volume = 1,
}

do
	const cfg = NAStuff.CustomMovementSounds
	cfg.WalkInput = tostring(cfg.WalkInput or cfg.WalkSoundId or "")
	cfg.JumpInput = tostring(cfg.JumpInput or cfg.JumpSoundId or "")
	cfg.FallInput = tostring(cfg.FallInput or cfg.FallSoundId or "")
	cfg.LandInput = tostring(cfg.LandInput or cfg.LandSoundId or "")
	cfg.Volume = math.clamp(tonumber(cfg.Volume) or 1, 0, 10)
end

NAmanage.CustomMovementSoundSaveSettings = NAmanage.CustomMovementSoundSaveSettings or function()
	const cfg = NAStuff.CustomMovementSounds or {}
	NAmanage.NASettingsSet("customMovementSoundsEnabled", cfg.Enabled == true)
	NAmanage.NASettingsSet("customMovementSoundsWalk", tostring(cfg.WalkInput or ""))
	NAmanage.NASettingsSet("customMovementSoundsJump", tostring(cfg.JumpInput or ""))
	NAmanage.NASettingsSet("customMovementSoundsFall", tostring(cfg.FallInput or ""))
	NAmanage.NASettingsSet("customMovementSoundsLand", tostring(cfg.LandInput or ""))
	NAmanage.NASettingsSet("customMovementSoundsVolume", math.clamp(tonumber(cfg.Volume) or 1, 0, 10))
end

NAmanage.CustomMovementSoundNormalize = NAmanage.CustomMovementSoundNormalize or function(raw)
	if typeof(raw) ~= "string" then
		raw = tostring(raw or "")
	end
	raw = raw:match("^%s*(.-)%s*$")
	if raw == "" then
		return ""
	end
	const digits = raw:match("^rbxassetid://(%d+)$") or raw:match("id=(%d+)") or raw:match("(%d+)$")
	if not digits then
		return nil
	end
	return "rbxassetid://"..digits
end

NAmanage.CustomMovementSoundKind = NAmanage.CustomMovementSoundKind or function(sound)
	if typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
		return nil
	end
	const name = tostring(sound.Name or "")
	if name == "Running" or name == "Run" or name == "Walk" then
		return "Walk"
	end
	if name == "Jumping" or name == "Jump" then
		return "Jump"
	end
	if name == "FreeFalling" or name == "Falling" or name == "Fall" then
		return "Fall"
	end
	if name == "Landing" or name == "Land" then
		return "Land"
	end
	return nil
end

NAmanage.CustomMovementSoundCapture = NAmanage.CustomMovementSoundCapture or function(sound)
	const capturedAttr = "NA_MoveSoundCaptured"
	const origIdAttr = "NA_MoveSoundOrigSoundId"
	const origVolAttr = "NA_MoveSoundOrigVolume"
	if typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
		return
	end
	if NAmanage.GetAttr(sound, capturedAttr) then
		return
	end
	local okId, soundId = pcall(function()
		return sound.SoundId
	end)
	local okVol, volume = pcall(function()
		return sound.Volume
	end)
	pcall(function()
		NAmanage.SetAttr(sound, capturedAttr, true)
		NAmanage.SetAttr(sound, origIdAttr, okId and tostring(soundId or "") or "")
		NAmanage.SetAttr(sound, origVolAttr, okVol and tonumber(volume) or 1)
	end)
end

NAmanage.CustomMovementSoundRestore = NAmanage.CustomMovementSoundRestore or function(sound)
	const capturedAttr = "NA_MoveSoundCaptured"
	const origIdAttr = "NA_MoveSoundOrigSoundId"
	const origVolAttr = "NA_MoveSoundOrigVolume"
	if typeof(sound) ~= "Instance" or not sound:IsA("Sound") then
		return
	end
	const captured = NAmanage.GetAttr(sound, capturedAttr)
	if captured ~= true then
		return
	end
	const origId = NAmanage.GetAttr(sound, origIdAttr)
	const origVol = NAmanage.GetAttr(sound, origVolAttr)
	if origId ~= nil then
		pcall(function()
			sound.SoundId = tostring(origId)
		end)
	end
	if type(origVol) == "number" then
		pcall(function()
			sound.Volume = origVol
		end)
	end
end

NAmanage.CustomMovementSoundApplyOne = NAmanage.CustomMovementSoundApplyOne or function(sound)
	const origIdAttr = "NA_MoveSoundOrigSoundId"
	const kind = NAmanage.CustomMovementSoundKind(sound)
	if not kind then
		return false
	end
	NAmanage.CustomMovementSoundCapture(sound)
	const cfg = NAStuff.CustomMovementSounds or {}
	if cfg.Enabled ~= true then
		NAmanage.CustomMovementSoundRestore(sound)
		return true
	end
	local asset = cfg[kind.."SoundId"]
	if type(asset) ~= "string" then
		asset = ""
	end
	if asset ~= "" then
		pcall(function()
			sound.SoundId = asset
		end)
	else
		const origId = NAmanage.GetAttr(sound, origIdAttr)
		if origId ~= nil then
			pcall(function()
				sound.SoundId = tostring(origId)
			end)
		end
	end
	pcall(function()
		sound.Volume = math.clamp(tonumber(cfg.Volume) or 1, 0, 10)
	end)
	return true
end

NAmanage.CustomMovementSoundApplyToCharacter = NAmanage.CustomMovementSoundApplyToCharacter or function(char)
	char = char or getChar()
	if typeof(char) ~= "Instance" then
		return 0
	end
	local applied = 0
	for _, desc in NAmanage.QueryDescendants(char, "Instance") do
		if NAmanage.CustomMovementSoundApplyOne(desc) then
			applied += 1
		end
	end
	return applied
end

NAmanage.CustomMovementSoundSyncConfig = NAmanage.CustomMovementSoundSyncConfig or function(notifyInvalid)
	const cfg = NAStuff.CustomMovementSounds or {}
	const invalid = {}
	for _, key in {"Walk", "Jump", "Fall", "Land"} do
		local normalized = NAmanage.CustomMovementSoundNormalize(cfg[key.."Input"])
		if normalized == nil then
			invalid[#invalid + 1] = Lower(key)
			normalized = ""
		end
		cfg[key.."SoundId"] = normalized
	end
	cfg.Volume = math.clamp(tonumber(cfg.Volume) or 1, 0, 10)
	if notifyInvalid and #invalid > 0 then
		DoNotif("Invalid movement sound id for: "..Concat(invalid, ", "), 3, "Movement Sounds")
	end
	return #invalid == 0
end

NAmanage.CustomMovementSoundBindCharacter = NAmanage.CustomMovementSoundBindCharacter or function(char)
	NAlib.disconnect("na_move_sounds_desc")
	if typeof(char) ~= "Instance" then
		return
	end
	NAlib.connect("na_move_sounds_desc", NAmanage.descAdd(char, function(inst)
		NAmanage.CustomMovementSoundApplyOne(inst)
	end, function(inst)
		return NAmanage.CustomMovementSoundKind(inst) ~= nil
	end))
end

NAmanage.CustomMovementSoundSetEnabled = NAmanage.CustomMovementSoundSetEnabled or function(enabled, opts)
	const cfg = NAStuff.CustomMovementSounds or {}
	cfg.Enabled = enabled and true or false
	NAmanage.CustomMovementSoundSaveSettings()
	opts = opts or {}
	if cfg.Enabled then
		NAmanage.CustomMovementSoundSyncConfig(opts.notifyInvalid == true)
		NAlib.disconnect("na_move_sounds_char")
		NAlib.connect("na_move_sounds_char", Services.Players.LocalPlayer.CharacterAdded:Connect(function(char)
			Defer(function()
				NAmanage.CustomMovementSoundBindCharacter(char)
				NAmanage.CustomMovementSoundApplyToCharacter(char)
			end)
		end))
		const char = getChar()
		NAmanage.CustomMovementSoundBindCharacter(char)
		const applied = NAmanage.CustomMovementSoundApplyToCharacter(char)
		if opts.notifyApplied == true then
			DoNotif("Applied custom movement sounds to "..tostring(applied).." sound(s).", 2, "Movement Sounds")
		end
	else
		NAlib.disconnect("na_move_sounds_char")
		NAlib.disconnect("na_move_sounds_desc")
		const char = getChar()
		const restored = NAmanage.CustomMovementSoundApplyToCharacter(char)
		if opts.notifyApplied == true then
			DoNotif("Restored "..tostring(restored).." movement sound(s).", 2, "Movement Sounds")
		end
	end
end

NAgui.addSection("Character Selection")
NAgui.addButton("Re-select Character", function()
	if NA_GRAB_BODY and NA_GRAB_BODY.pickOverride then
		Spawn(function()
			NA_GRAB_BODY.pickOverride()
		end)
	end
end)

NAgui.addSection("Character Light")
NAgui.addSlider("Range",      0,  120, settingsLight.range,      0.1,   "", function(val) settingsLight.range      = val end)
NAgui.addSlider("Brightness", 0,   100, settingsLight.brightness, 0.5,   "", function(val) settingsLight.brightness = val end)
NAgui.addColorPicker("Color",  settingsLight.color, function(col) settingsLight.color = col end)
NAgui.addButton("Apply Light", function()
	const root = getRoot(Player.Character)
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

NAgui.addSection("Character Cleanup")
NAgui.addButton("Remove Accessories", function()
	const hum = getHum(getChar())
	const char = hum and hum.Parent
	if not char then
		DoNotif("Character not found.", 2)
		return
	end
	local removed = 0
	for _, child in char:GetChildren() do
		if child:IsA("Accessory") then
			removed += 1
			child:Destroy()
		end
	end
	DoNotif(removed > 0 and ("Removed "..removed.." accessory(ies).") or "No accessories to remove.", 2)
end)

NAgui.addSection("Custom Movement Sounds")
NAgui.addToggle("Enable Custom Movement Sounds", NAStuff.CustomMovementSounds.Enabled == true, function(state)
	NAmanage.CustomMovementSoundSetEnabled(state, {
		notifyInvalid = state == true,
		notifyApplied = true,
	})
end)
NAgui.addInput("Walk Sound", "asset id for running/walk", NAStuff.CustomMovementSounds.WalkInput or "", function(val)
	NAStuff.CustomMovementSounds.WalkInput = tostring(val or "")
	NAmanage.CustomMovementSoundSaveSettings()
end)
NAgui.addInput("Jump Sound", "asset id for jumping", NAStuff.CustomMovementSounds.JumpInput or "", function(val)
	NAStuff.CustomMovementSounds.JumpInput = tostring(val or "")
	NAmanage.CustomMovementSoundSaveSettings()
end)
NAgui.addInput("Fall Sound", "asset id for freefall", NAStuff.CustomMovementSounds.FallInput or "", function(val)
	NAStuff.CustomMovementSounds.FallInput = tostring(val or "")
	NAmanage.CustomMovementSoundSaveSettings()
end)
NAgui.addInput("Land Sound", "optional landing asset id", NAStuff.CustomMovementSounds.LandInput or "", function(val)
	NAStuff.CustomMovementSounds.LandInput = tostring(val or "")
	NAmanage.CustomMovementSoundSaveSettings()
end)
NAgui.addSlider("Movement Sound Volume", 0, 10, tonumber(NAStuff.CustomMovementSounds.Volume) or 1, 0.05, "", function(val)
	NAStuff.CustomMovementSounds.Volume = val
	NAmanage.CustomMovementSoundSaveSettings()
	if NAStuff.CustomMovementSounds.Enabled == true then
		NAmanage.CustomMovementSoundApplyToCharacter(getChar())
	end
end)
NAgui.addButton("Apply Movement Sounds", function()
	NAmanage.CustomMovementSoundSyncConfig(true)
	if NAStuff.CustomMovementSounds.Enabled == true then
		NAmanage.CustomMovementSoundSetEnabled(true, {
			notifyInvalid = true,
			notifyApplied = true,
		})
	else
		DoNotif("Enable custom movement sounds first.", 2, "Movement Sounds")
	end
end)
NAgui.addButton("Restore Default Movement Sounds", function()
	NAStuff.CustomMovementSounds.WalkInput = ""
	NAStuff.CustomMovementSounds.JumpInput = ""
	NAStuff.CustomMovementSounds.FallInput = ""
	NAStuff.CustomMovementSounds.LandInput = ""
	NAStuff.CustomMovementSounds.WalkSoundId = ""
	NAStuff.CustomMovementSounds.JumpSoundId = ""
	NAStuff.CustomMovementSounds.FallSoundId = ""
	NAStuff.CustomMovementSounds.LandSoundId = ""
	NAStuff.CustomMovementSounds.Volume = 1
	NAmanage.CustomMovementSoundSetEnabled(false, {
		notifyApplied = true,
	})
	NAmanage.CustomMovementSoundSaveSettings()
	if NAgui.setToggleState then
		NAgui.setToggleState("Enable Custom Movement Sounds", false, { force = true, fire = false })
	end
	if NAgui.setSliderValue then
		NAgui.setSliderValue("Movement Sound Volume", 1, { force = true, fire = false })
	end
	DoNotif("Movement sounds reset. Reopen the Character tab to refresh the sound-id inputs.", 2, "Movement Sounds")
end)
if NAStuff.CustomMovementSounds.Enabled == true then
	Defer(function()
		NAmanage.CustomMovementSoundSetEnabled(true)
	end)
end

NAmanage.SetupBasicInfoTab = function()
	const previousTab = NAgui.getActiveTab()
	NAgui.addTab(NA_TABS.TAB_BASIC_INFO, { order = 12, textIcon = "circle-i" })
	NAgui.setTab(NA_TABS.TAB_BASIC_INFO)

	const basicInfoConfig = {
		{
			title = "Player";
			fields = {
				{ id = "playerDisplayName", label = "Display Name", path = {"player","displayName"} };
				{ id = "playerUsername", label = "Username", path = {"player","username"} };
				{ id = "playerUserId", label = "UserId", path = {"player","userId"} };
				{ id = "playerAccountAge", label = "Account Age", path = {"player","accountAge"} };
				{ id = "playerMembership", label = "Membership", path = {"player","membership"} };
				{ id = "playerTeam", label = "Team", path = {"player","team"} };
			};
		},
		{
			title = "Platform";
			fields = {
				{ id = "platformName", label = "Platform", path = {"platform","platform"} };
				{ id = "executorName", label = "Executor", path = {"platform","executor"} };
				{ id = "platformDevice", label = "Device", path = {"platform","device"} };
			};
		},
		{
			title = "Game";
			fields = {
				{ id = "gameName", label = "Game Name", path = {"game","name"} };
				{ id = "gameCreator", label = "Creator", path = {"game","creator"} };
				{ id = "gameGenre", label = "Genre", path = {"game","genre"} };
				{ id = "placeVersion", label = "Place Version", path = {"game","placeVersion"} };
			};
		},
		{
			title = "Identifiers";
			fields = {
				{ id = "placeId", label = "Place ID", path = {"ids","placeId"} };
				{ id = "gameId", label = "Game ID", path = {"ids","gameId"} };
				{ id = "jobId", label = "Job ID", path = {"ids","jobId"} };
			};
		},
		{
			title = "Server";
			fields = {
				{ id = "serverPlayers", label = "Players", path = {"server","playerCount"} };
				{ id = "serverPing", label = "Ping", path = {"server","ping"} };
				{ id = "serverRegion", label = "Region", path = {"server","region"} };
				{ id = "serverCity", label = "City", path = {"server","city"} };
				{ id = "serverCountry", label = "Country", path = {"server","country"} };
				{ id = "serverDatacenter", label = "Datacenter ID", path = {"server","datacenter"} };
				{ id = "serverIp", label = "Server IP", path = {"server","ip"} };
				{ id = "serverUptime", label = "Server Uptime", path = {"server","uptime"} };
				{ id = "serverPlaceVersion", label = "Server Place Version", path = {"server","placeVersion"} };
			};
		},
		{
			title = "System";
			fields = {
				{ id = "robloxLocale", label = "Roblox Locale", path = {"system","robloxLocale"} };
				{ id = "systemLocale", label = "System Locale", path = {"system","systemLocale"} };
				{ id = "qualitySetting", label = "Graphics Quality", path = {"system","quality"} };
				{ id = "voiceStatus", label = "Voice Chat", path = {"system","voice"} };
				{ id = "screenResolution", label = "Resolution", path = {"system","resolution"} };
			};
		},
		{
			title = "Session";
			fields = {
				{ id = "sessionUptime", label = "Session Uptime", path = {"session","uptime"} };
			};
		},
		{
			title = "Flags";
			fields = {
				{ id = "naVersion", label = "NA Version", path = {"flags","version"} };
				{ id = "aprilMode", label = "April Fools Mode", path = {"flags","aprilFools"} };
				{ id = "timestamp", label = "Timestamp", path = "timestamp" };
			};
		},
	}

	const basicInfoBoxes = {}

	const function resolveValue(snapshot, path)
		local current = snapshot
		if type(path) == "table" then
			for _, key in path do
				if current == nil then
					break
				end
				current = current[key]
			end
		elseif path ~= nil then
			current = current and current[path] or nil
		end
		if current == nil or current == "" then
			return "Unknown"
		end
		return tostring(current)
	end

	const function copyBasicInfoField(field)
		if type(field) ~= "table" then
			return false
		end

		local clip = type(NAmanage.CmdInputGetClipboardSet) == "function" and NAmanage.CmdInputGetClipboardSet() or nil
		if type(clip) ~= "function" and type(setclipboard) == "function" then
			clip = setclipboard
		end
		if type(clip) ~= "function" then
			DoNotif("Your executor does not support setclipboard.", 3)
			return false
		end

		const snapshot = NAmanage.GetBasicInfoSnapshot()
		const value = resolveValue(snapshot, field.path)
		if value == "" or value == "Unknown" then
			DoNotif("No "..tostring(field.label or "info").." value to copy.", 2)
			return false
		end

		local ok, err = pcall(clip, value)
		if ok then
			DoNotif(tostring(field.label or "Info").." copied to clipboard.", 1.5)
			return true
		end

		DoNotif("Clipboard failed: "..tostring(err), 3)
		return false
	end

	for _, section in basicInfoConfig do
		if NAgui.addSection then
			NAgui.addSection(section.title)
		end
		for _, field in section.fields do
			const currentField = field
			const box = NAgui.addInfo(currentField.label, "", {
				textScaled = true;
				sideChip = true;
				sideText = "Copy";
				sideDoneText = "Copied";
				sideClick = function()
					return copyBasicInfoField(currentField)
				end;
			})
			if box then
				box.Selectable = true
				box.Active = true
			end
			basicInfoBoxes[field.id] = box
		end
	end

	const function refreshBasicInfo()
		const snapshot = NAmanage.GetBasicInfoSnapshot()
		for _, section in basicInfoConfig do
			for _, field in section.fields do
				const box = basicInfoBoxes[field.id]
				if box then
					const value = resolveValue(snapshot, field.path)
					box.Text = value
				end
			end
		end
	end

	NAgui.RefreshBasicInfo = refreshBasicInfo
	refreshBasicInfo()
	NAgui.addButton("Refresh Basic Info", function()
		if type(NAmanage.BasicInfoServerCache) == "table" then
			NAmanage.BasicInfoServerCache.lastFetch = 0
		end
		refreshBasicInfo()
	end)

	const updateInterval = 1
	if not NAgui.BasicInfoUpdate then
		NAgui.BasicInfoUpdate = { interval = updateInterval, token = 0 }
		NAgui.BasicInfoUpdate.token += 1
		const token = NAgui.BasicInfoUpdate.token
		Spawn(function()
			while NAgui.BasicInfoUpdate and NAgui.BasicInfoUpdate.token == token do
				const data = NAgui.BasicInfoUpdate
				const active = TabManager and TabManager.current == NA_TABS.TAB_BASIC_INFO
				if active then
					refreshBasicInfo()
				end
				local waitTime = active and (tonumber(data.interval) or updateInterval) or 1.5
				if NAmanage.isLoad and NAmanage.isLoad() then
					waitTime = math.max(waitTime, 2)
				end
				Wait(waitTime)
			end
		end)
	else
		NAgui.BasicInfoUpdate.interval = updateInterval
	end

	if previousTab and previousTab ~= NA_TABS.TAB_BASIC_INFO then
		NAgui.setTab(previousTab)
	end
end
NAmanage.SetupBasicInfoTab()

NAgui.addTab(NA_TABS.TAB_ROBLOX_DATA, { order = 13, textIcon = "tilt" })
NAgui.setTab(NA_TABS.TAB_ROBLOX_DATA)

NAStuff.GitHubLoadingText = "Loading..."
NAStuff.GitHubFailureText = "Failed to load commits"
NAStuff.GitHubEmptyText = "No commits found"
NAStuff.GitHubEndpointField = nil
NAStuff.GitHubCommits = nil
NAStuff.GitHubCommitMessageField = nil
NAStuff.GitHubCommitDescriptionField = nil
NAStuff.GitHubCommitAuthorField = nil
NAStuff.GitHubCommitDateField = nil
NAStuff.GitHubCommitsLastFetch = 0
NAStuff.GitHubTabInitialized = false
NAStuff.GitHubCommitHeaders = {
	["Accept"] = "application/vnd.github+json";
	["X-GitHub-Api-Version"] = "2022-11-28";
}

if _na_env and rawget(_na_env, "GITHUB_TOKEN") then
	const token = tostring(_na_env.GITHUB_TOKEN)
	if token ~= "" then
		NAStuff.GitHubCommitHeaders["Authorization"] = "Bearer "..token
	end
elseif _na_env and rawget(_na_env, "GITHUB_AUTH") then
	const auth = tostring(_na_env.GITHUB_AUTH)
	if auth ~= "" then
		NAStuff.GitHubCommitHeaders["Authorization"] = auth
	end
end

NAStuff.RobloxVersionEndpoints = {
	"https://raw.githubusercontent.com/ltseverydayyou/ltseverydayyou.github.io/refs/heads/main/.well-known/weao/versions.json";
	"https://raw.githubusercontent.com/ltseverydayyou/ltseverydayyou.github.io/main/.well-known/weao/versions.json";
	"https://ltseverydayyou.github.io/.well-known/weao/versions.json";
	"https://cdn.jsdelivr.net/gh/ltseverydayyou/ltseverydayyou.github.io@main/.well-known/weao/versions.json";
}

NAStuff.RobloxVersionSource = NAStuff.RobloxVersionEndpoints[1]


originalIO.parseRobloxVersionBody=function(body)
	if type(body) ~= "string" then return nil end
	if body:sub(1,3) == "\239\187\191" then body = body:sub(4) end
	local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
	if ok and type(decoded) == "table" then return decoded end
	local a,depth,inStr,esc=nil,0,false,false
	for i=1,#body do
		const c=body:sub(i,i)
		if inStr then
			if esc then esc=false elseif c=="\\" then esc=true elseif c=='"' then inStr=false end
		else
			if c=='"' then inStr=true
			elseif c=='{' then depth=depth+1 a=a or i
			elseif c=='}' and depth>0 then
				depth=depth-1
				if depth==0 and a then
					local ok2, j = pcall(Services.HttpService.JSONDecode, Services.HttpService, body:sub(a,i))
					if ok2 and type(j)=="table" then return j end
				end
			end
		end
	end
	return nil
end

originalIO.normalizeRobloxVersionData=function(decoded)
	if type(decoded) ~= "table" then
		return nil
	end

	local root = decoded
	if type(root.data) == "table" and type(root.data.current) == "table" then
		root = root.data.current
	elseif type(root.current) == "table" then
		root = root.current
	elseif type(root.versions) == "table" and type(root.versions.current) == "table" then
		root = root.versions.current
	end

	if type(root) ~= "table" then
		return nil
	end

	const function txt(value)
		if value == nil then
			return nil
		end
		local out = tostring(value)
		out = out:match("^%s*(.-)%s*$") or out
		if out == "" then
			return nil
		end
		return out
	end

	const function responseVersion(name)
		const response = root[name.."Response"]
		const versionText = type(response) == "table" and txt(response.version) or nil
		const uploadText = txt(root[name]) or (type(response) == "table" and txt(response.clientVersionUpload) or nil)
		if versionText and uploadText and uploadText ~= versionText then
			return versionText.." ("..uploadText..")"
		end
		return versionText or uploadText
	end

	const out = {
		Windows = responseVersion("Windows");
		Mac = responseVersion("Mac");
		Android = responseVersion("Android") or txt(root.Android);
		iOS = responseVersion("iOS") or txt(root.iOS) or txt(root.IOS);
		WindowsDate = txt(root.WindowsDate);
		MacDate = txt(root.MacDate);
		AndroidDate = txt(root.AndroidDate);
		iOSDate = txt(root.iOSDate) or txt(root.IOSDate);
	}

	const fetchedAt = txt(decoded.fetchedAt)
	if fetchedAt then
		out.WindowsDate = out.WindowsDate or fetchedAt
		out.MacDate = out.MacDate or fetchedAt
		out.AndroidDate = out.AndroidDate or fetchedAt
		out.iOSDate = out.iOSDate or fetchedAt
	end

	if out.Windows or out.Mac or out.Android or out.iOS then
		return out
	end

	return nil
end

originalIO.fetchGitHubCommits = function(forceRefresh)
	const cached = NAStuff.GitHubCommits
	const lastFetch = NAStuff.GitHubCommitsLastFetch or 0
	if cached and not forceRefresh and (tick() - lastFetch) < 300 then
		return true, cached
	end

	const requestFunc = NAmanage.HttpRequest

	const baseUrl = opt and opt.githubUrl
	if type(baseUrl) ~= "string" or baseUrl == "" then
		return false, "GitHub URL is not configured"
	end

	const endpoints = {}
	const function appendEndpoint(url)
		if url and url ~= "" then
			Insert(endpoints, url)
		end
	end

	appendEndpoint(baseUrl)

	if not baseUrl:lower():find("^https?://r%.jina%.ai/") then
		appendEndpoint("https://r.jina.ai/"..baseUrl)
	end

	if _na_env and rawget(_na_env, "GITHUB_PROXY") then
		const proxy = tostring(_na_env.GITHUB_PROXY)
		if proxy ~= "" then
			appendEndpoint(proxy)
		end
	end

	const headers = {}
	for key, value in NAStuff.GitHubCommitHeaders or {} do
		headers[key] = value
	end

	local lastError
	for _, endpoint in endpoints do
		const sep = endpoint:find("?", 1, true) and "&" or "?"
		const cacheBuster = "_="..tostring(os.time())..tostring(math.random(1, 1e6))
		const url = endpoint..sep..cacheBuster
		local okRequest, response = requestFunc({
			Url = url;
			Method = "GET";
			Headers = headers;
			Timeout = 8;
			FollowRedirects = true;
			SslVerify = false;
		}, { maxAttempts = 5, timeout = 8 })
		if okRequest and response then
			const status = tonumber(response.StatusCode) or tonumber(response.Status)
			const body = response.Body or response.body
			if status == 200 and type(body) == "string" then
				local decodeOk, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
				if decodeOk and type(decoded) == "table" then
					NAStuff.GitHubCommits = decoded
					NAStuff.GitHubCommitsLastFetch = tick()
					return true, decoded
				else
					lastError = "Invalid JSON response"
				end
			elseif status == 304 and cached then
				NAStuff.GitHubCommitsLastFetch = tick()
				return true, cached
			else
				const statusText = status and tostring(status) or "unknown"
				lastError = Format("GitHub request failed (HTTP %s)", statusText)
			end
		else
			const err = okRequest and "Unknown response error" or tostring(response)
			lastError = err
		end
	end

	if type(baseUrl) == "string" and baseUrl ~= "" then
		const sep = baseUrl:find("?", 1, true) and "&" or "?"
		const cacheBuster = "_="..tostring(os.time())..tostring(math.random(1, 1e6))
		const directUrl = baseUrl..sep..cacheBuster
		local okDirect, bodyDirect = NAmanage.HttpGet(directUrl, { timeout = 8, Headers = headers })
		if okDirect and type(bodyDirect) == "string" then
			local decodeOk, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, bodyDirect)
			if decodeOk and type(decoded) == "table" then
				NAStuff.GitHubCommits = decoded
				NAStuff.GitHubCommitsLastFetch = tick()
				return true, decoded
			end
		end
	end

	return false, lastError or NAStuff.GitHubFailureText
end

originalIO.splitCommitMessage = function(message)
	local raw = tostring(message or "")
	raw = raw:gsub("\r\n", "\n"):gsub("\r", "\n")
	local title, body
	const firstNewline = string.find(raw, "\n", 1, true)
	if firstNewline then
		title = raw:sub(1, firstNewline - 1)
		body = raw:sub(firstNewline + 1)
	else
		title = raw
		body = ""
	end
	title = tostring(title or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
	body = tostring(body or ""):gsub("^\n+", ""):gsub("\n+$", "")
	body = body:gsub("[\t\v\f]+", " ")
	if title == "" then
		title = "(no message)"
	end
	if body:match("^%s*$") then
		body = "No description provided."
	end
	return title, body
end

originalIO.sanitizeCommitMessage = function(message)
	local title = originalIO.splitCommitMessage(message)
	if #title > 86 then
		title = title:sub(1, 83).."..."
	end
	return title
end

originalIO.sanitizeCommitDescription = function(message)
	local _, description = originalIO.splitCommitMessage(message)
	return description
end

originalIO.formatCommitAuthor = function(commit)
	if type(commit) ~= "table" then
		return "Unknown author"
	end
	const commitInfo = commit.commit or {}
	const authorInfo = commitInfo.author or {}
	const fallbackAuthor = commit.author or {}
	const nickname = authorInfo.name
	const username = fallbackAuthor.login
	if nickname and username then
		if nickname == username then
			return nickname
		else
			return Format("%s (%s)", nickname, username)
		end
	elseif nickname then
		return nickname
	elseif username then
		return username
	end
	return "Unknown author"
end

originalIO.formatCommitDate = function(isoDate)
	if type(isoDate) ~= "string" then
		return "Unknown date", nil
	end
	local year, month, day, hour, minute = isoDate:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+)")
	if year and month and day and hour and minute then
		const display = Format("%02d/%02d/%s %s:%s UTC", tonumber(month), tonumber(day), year, hour, minute)
		const shortDate = Format("%02d/%02d/%s", tonumber(month), tonumber(day), year)
		return display, shortDate
	end
	return isoDate, nil
end

NAmanage.FormatGitHubCommitSummary = function(commit)
	if type(commit) ~= "table" then
		return NAStuff.GitHubFailureText
	end
	const sha = commit.sha and tostring(commit.sha):sub(1, 7) or "unknown"
	const commitInfo = commit.commit or {}
	const message = originalIO.sanitizeCommitMessage(commitInfo.message)
	return Format("%s (%s)", message, sha)
end

NAmanage.UpdateGitHubCommitUI = function(commits, statusMessage)
	commits = commits or NAStuff.GitHubCommits
	const commit = (type(commits) == "table" and commits[1]) or nil
	const messageField = NAStuff.GitHubCommitMessageField
	const descriptionField = NAStuff.GitHubCommitDescriptionField
	const authorField = NAStuff.GitHubCommitAuthorField
	const dateField = NAStuff.GitHubCommitDateField

	const endpointField = NAStuff.GitHubEndpointField
	if endpointField then
		endpointField.Text = (type(opt.githubUrl) == "string" and opt.githubUrl ~= "" and opt.githubUrl) or "Unavailable"
	end

	if commit then
		const message = NAmanage.FormatGitHubCommitSummary(commit)
		const authorDisplay = originalIO.formatCommitAuthor(commit)
		const commitInfo = commit.commit or {}
		const description = originalIO.sanitizeCommitDescription(commitInfo.message)
		const authorInfo = commitInfo.author or commitInfo.committer or {}
		local dateDisplay, shortDate = originalIO.formatCommitDate(authorInfo.date)

		if messageField then
			messageField.Text = message or NAStuff.GitHubEmptyText
		end
		if descriptionField then
			descriptionField.Text = description or "No description provided."
		end
		if authorField then
			authorField.Text = authorDisplay or NAStuff.GitHubEmptyText
		end
		if dateField then
			dateField.Text = dateDisplay or NAStuff.GitHubEmptyText
		end

		if shortDate then
			opt.NAupdDate = shortDate
		end
	else
		const fallback = statusMessage or NAStuff.GitHubEmptyText
		if messageField then
			messageField.Text = fallback
		end
		if descriptionField then
			descriptionField.Text = fallback
		end
		if authorField then
			authorField.Text = fallback
		end
		if dateField then
			dateField.Text = fallback
		end
	end
end

NAmanage.RefreshGitHubCommits = function(forceRefresh)
	local ok, result = originalIO.fetchGitHubCommits(forceRefresh)
	if ok then
		NAmanage.UpdateGitHubCommitUI(result)
	else
		local message = result or NAStuff.GitHubFailureText
		if type(message) == "string" and #message > 128 then
			message = message:sub(1, 125).."..."
		end
		warn("[NA] GitHub commit fetch failed:", message)
		NAmanage.UpdateGitHubCommitUI(nil, "Error: "..message)
	end
	return ok
end

originalIO.fetchRobloxVersionData=function(forceRefresh)
	const cached = NAStuff.RobloxVersionData
	const lastFetch = NAStuff.RobloxVersionLastFetch or 0
	if cached and not forceRefresh and (tick() - lastFetch) < 300 then
		return true, cached
	end

	const function cacheData(data, source, remote)
		NAStuff.RobloxVersionData = data
		NAStuff.RobloxVersionLastFetch = tick()
		NAStuff.RobloxVersionFromRemote = remote == true
		NAStuff.RobloxVersionSource = source
		return data
	end

	const function decodeBody(body, source)
		if type(body) ~= "string" or body == "" then
			return nil
		end
		const decoded = originalIO.parseRobloxVersionBody(body)
		const data = originalIO.normalizeRobloxVersionData(decoded)
		if data then
			return cacheData(data, source, true)
		end
		return nil
	end

	const function readUrl(url)
		if type(url) ~= "string" or url == "" then
			return nil
		end

		local okHttp, body = pcall(function()
			return NAmanage.HttpGetOrError(url)
		end)
		if okHttp then
			const data = decodeBody(body, url)
			if data then
				return data
			end
		end

		return nil
	end

	const function localDeviceFallback()
		local okVersion, currentVersion = pcall(function()
			return version and version() or nil
		end)
		if not okVersion or type(currentVersion) ~= "string" or currentVersion == "" then
			if _VERSION then
				currentVersion = tostring(_VERSION)
			else
				return nil
			end
		end

		const nowText = os.date("!%m/%d/%Y, %I:%M:%S %p UTC")
		const sourceText = "Local Client ("..nowText..")"
		return {
			Windows = currentVersion;
			WindowsDate = sourceText;
			Mac = currentVersion;
			MacDate = sourceText;
			Android = currentVersion;
			AndroidDate = sourceText;
			iOS = currentVersion;
			iOSDate = sourceText;
		}
	end

	for _, url in NAStuff.RobloxVersionEndpoints do
		const data = readUrl(url)
		if data then
			return true, data
		end
	end

	const fallback = localDeviceFallback()
	if fallback then
		return true, cacheData(fallback, "Local Client", false)
	end

	if type(cached) == "table" and next(cached) ~= nil then
		return true, cached
	end

	return false, cached
end

NAStuff.RobloxVersionLoadingText = "Loading..."
NAStuff.RobloxVersionMissingText = "Unavailable"
NAStuff.RobloxVersionFailureText = "Failed to load"

NAStuff.RobloxVersionRows = {}
NAStuff.RobloxVersionFromRemote = NAStuff.RobloxVersionFromRemote == true
originalIO.addRobloxVersionSection=function(sectionTitle, versionKey, dateKey)
	NAgui.addSection(sectionTitle)
	const versionField = NAgui.addInfo("Version", NAStuff.RobloxVersionLoadingText)
	const updatedField = NAgui.addInfo("Last Updated", NAStuff.RobloxVersionLoadingText)
	Insert(NAStuff.RobloxVersionRows, {
		versionKey = versionKey;
		dateKey = dateKey;
		versionField = versionField;
		dateField = updatedField;
	})
end

originalIO.withRobloxVersionTab=function(callback)
	if type(callback) ~= "function" then
		return false
	end

	const targetTab = NA_TABS.TAB_ROBLOX_DATA

	const deadline = os.clock() + 5
	while os.clock() < deadline do
		if TabManager and TabManager.tabs and TabManager.tabs[targetTab] and NAgui and NAgui.setTab and NAgui.getActiveTab then
			break
		end
		Wait()
	end

	if not (TabManager and TabManager.tabs and TabManager.tabs[targetTab] and NAgui and NAgui.setTab and NAgui.getActiveTab) then
		return false
	end

	local ok, result = pcall(function()
		return NAgui.withSettingsTabContext(targetTab, callback)
	end)

	return ok, result
end

originalIO.hasRobloxVersionData=function(data)
	if type(data) ~= "table" then
		return false
	end
	const keys = { "Windows", "Mac", "Android", "iOS" }
	for i = 1, #keys do
		const value = data[keys[i]]
		if value ~= nil and tostring(value) ~= "" then
			return true
		end
	end
	return false
end

originalIO.ensureRobloxVersionRows=function()
	if type(NAStuff.RobloxVersionRows) == "table" and #NAStuff.RobloxVersionRows > 0 then
		return true
	end

	local made = false
	const ok = originalIO.withRobloxVersionTab(function()
		NAStuff.RobloxVersionRows = {}
		NAgui.addSection("Powered by weao.xyz API")
		originalIO.addRobloxVersionSection("Windows", "Windows", "WindowsDate")
		originalIO.addRobloxVersionSection("Mac", "Mac", "MacDate")
		originalIO.addRobloxVersionSection("Android", "Android", "AndroidDate")
		originalIO.addRobloxVersionSection("iOS", "iOS", "iOSDate")
		made = true
	end)

	return ok == true and made == true
end

originalIO.renderRobloxVersionSections=function(ok, data)
	if not originalIO.ensureRobloxVersionRows() then
		return false
	end

	const fallbackText = ok and NAStuff.RobloxVersionMissingText or NAStuff.RobloxVersionFailureText
	for _, entry in NAStuff.RobloxVersionRows do
		if entry.versionField then
			const value = type(data) == "table" and data[entry.versionKey] or nil
			entry.versionField.Text = value and tostring(value) or fallbackText
		end
		if entry.dateField then
			const value = type(data) == "table" and data[entry.dateKey] or nil
			entry.dateField.Text = value and tostring(value) or fallbackText
		end
	end

	return true
end

const function buildRobloxDataControls()
	local clientVersion = "Unknown"
	local okVersion, versionValue = pcall(function()
		return version and version() or nil
	end)
	if okVersion and versionValue ~= nil then
		clientVersion = tostring(versionValue)
	elseif _VERSION then
		clientVersion = tostring(_VERSION)
	end
	const luauVersion = tostring(_VERSION or "")
	local textValue = clientVersion
	if luauVersion ~= "" and luauVersion ~= clientVersion then
		textValue = clientVersion.."-"..luauVersion
	end
	NAgui.addInfo("Your Version", textValue, {
		minTextSize = 11;
		clampAlignLeft = false;
		autoShrink = true;
	})

	NAStuff.RobloxVersionRows = {}
	NAgui.addSection("Powered by weao.xyz API")
	originalIO.addRobloxVersionSection("Windows", "Windows", "WindowsDate")
	originalIO.addRobloxVersionSection("Mac", "Mac", "MacDate")
	originalIO.addRobloxVersionSection("Android", "Android", "AndroidDate")
	originalIO.addRobloxVersionSection("iOS", "iOS", "iOSDate")
end

buildRobloxDataControls()

NAgui.addTab(NA_TABS.TAB_CONTRIBUTORS, { order = 14, textIcon = "code" })
NAgui.setTab(NA_TABS.TAB_CONTRIBUTORS)

if not NAStuff.ContributorsTabInitialized then
	NAmanage._sourceTrail = NAmanage._sourceTrail or function()
		if type(NAStuff.Contributors) == "table" and #NAStuff.Contributors > 0 then
			return NAStuff.Contributors
		end

		const sealed = {
			{
				name = { 104, 140, 132, 122, 136, 128, 114 };
				handle = { 82, 127, 136, 136, 123, 141, 118, 132, 140, 120, 118, 143, 144, 128, 135 };
				role = { 97, 138, 130, 122, 136 };
				link = { 122, 135, 136, 133, 137, 81, 64, 65, 122, 125, 137, 126, 140, 115, 64, 118, 131, 130, 69, 131, 133, 133, 120, 138, 122, 136, 144, 117, 115, 140, 141, 132, 139 };
			};
			{
				name = { 104, 124, 132, 122, 136 };
				handle = { 82, 86, 131, 136, 131, 124, 125, 126, 116 };
				role = { 97, 138, 130, 122, 136 };
				link = { 122, 135, 136, 133, 137, 81, 64, 65, 122, 125, 137, 126, 140, 115, 64, 118, 131, 130, 69, 90, 128, 133, 128, 121, 129, 130, 120, 62, 136 };
			};
			{
				name = { 131, 124, 132, 138 };
				handle = { 82, 140, 121, 128, 139 };
				role = { 97, 133, 125, 124, 127, 133, 114, 126, 51, 99, 140, 132, 124, 131 };
				link = { 122, 135, 136, 133, 137, 81, 64, 65, 122, 125, 137, 126, 140, 115, 64, 118, 131, 130, 69, 144, 118, 125, 136 };
			};
		}

		const function unseal(nums)
			const chars = {}
			for i = 1, #nums do
				chars[i] = string.char(nums[i] - ((i % 7) + 17))
			end
			return Concat(chars)
		end

		const decoded = {}
		for i, row in sealed do
			decoded[i] = {
				name = unseal(row.name);
				handle = unseal(row.handle);
				role = unseal(row.role);
				link = unseal(row.link);
			}
		end
		NAStuff.Contributors = decoded
		return decoded
	end

	const function copyContributorLink(label, url)
		url = tostring(url or "")
		if url == "" then
			return
		end
		if type(setclipboard) == "function" then
			const okCopy = pcall(setclipboard, url)
			if okCopy then
				DoNotif(label.." link copied.", 2)
				return
			end
		end
		if type(DoWindow) == "function" then
			DoWindow(url, label)
		else
			DoNotif(label..": "..url, 4)
		end
	end

	NAgui.addSection("Official Contributors")
	for _, contributor in NAmanage._sourceTrail() do
		const name = tostring(contributor.name or "")
		const handle = tostring(contributor.handle or "")
		const role = tostring(contributor.role or "")
		const link = tostring(contributor.link or "")
		local label = name
		if handle ~= "" then
			label = label.." ("..handle..")"
		end
		NAgui.addInfo(role ~= "" and role or "Contributor", label, {
			minTextSize = 10;
			autoShrink = true;
		})
		if link ~= "" then
			NAgui.addButton("Copy "..name.." GitHub", function()
				copyContributorLink(name, link)
			end)
		end
	end

	NAgui.addSection("Verification")
	NAgui.addInfo("Trust Note", "If this looks different, check it against the official repo.", {
		textSize = 12;
		minTextSize = 8;
		autoShrink = true;
	})
	NAgui.addButton("Copy Official Repository", function()
		copyContributorLink("Official repository", NAmanage._sourceGlyph(NAStuff.officialRepoLink))
	end)
	NAgui.addButton("Copy Official Source", function()
		copyContributorLink("Official source", opt.loader or "")
	end)

	NAStuff.ContributorsTabInitialized = true
end

NAgui.addTab(NA_TABS.TAB_ADMIN_INFO, { order = 15, textIcon = "github" })
NAgui.setTab(NA_TABS.TAB_ADMIN_INFO)

if not NAStuff.GitHubTabInitialized then
	NAgui.addSection("Latest Commit")
	NAStuff.GitHubCommitMessageField = NAgui.addInfo("Commit", NAStuff.GitHubLoadingText)
	NAStuff.GitHubCommitDescriptionField = NAgui.addInfo("Description", NAStuff.GitHubLoadingText, {
		textWrapped = true;
		textScaled = false;
		textSize = 11;
		minTextSize = 10;
		autoShrink = false;
		fillWidth = true;
		autoHeight = true;
		inputHeight = 46;
		minInputHeight = 30;
		maxInputHeight = 84;
		textYAlignment = "Center";
	})
	NAStuff.GitHubCommitAuthorField = NAgui.addInfo("Author", NAStuff.GitHubLoadingText)
	NAStuff.GitHubCommitDateField = NAgui.addInfo("Updated", NAStuff.GitHubLoadingText)

	NAgui.addButton("Refresh Commits", function()
		NAmanage.UpdateGitHubCommitUI(nil, NAStuff.GitHubLoadingText)
		SpawnCall(function()
			local ok, result = originalIO.fetchGitHubCommits(true)
			if ok then
				NAmanage.UpdateGitHubCommitUI(result)
				if DoNotif then
					DoNotif("GitHub commits updated.", 2)
				end
			else
				local message = result or NAStuff.GitHubFailureText
				if type(message) == "string" and #message > 128 then
					message = message:sub(1, 125).."..."
				end
				warn("[NA] GitHub commit refresh failed:", message)
				NAmanage.UpdateGitHubCommitUI(nil, "Error: "..tostring(message))
				if DoNotif then
					DoNotif("Failed to refresh GitHub commits.", 3)
				end
			end
		end)
	end)

	NAStuff.GitHubTabInitialized = true
end

SpawnCall(function()
	Wait()
	local callOk, fetchOk, data = pcall(originalIO.fetchRobloxVersionData)
	if callOk then
		originalIO.renderRobloxVersionSections(fetchOk, data)
	else
		warn("[NA] Roblox version fetch failed:", fetchOk)
		originalIO.renderRobloxVersionSections(false, nil)
	end
end)

NAmanage.UpdateGitHubCommitUI(nil, NAStuff.GitHubLoadingText)

SpawnCall(function()
	Wait()
	local callOk, refreshResult = pcall(NAmanage.RefreshGitHubCommits, false)
	if not callOk then
		warn("[NA] GitHub commit refresh crashed:", refreshResult)
		NAmanage.UpdateGitHubCommitUI(nil, NAStuff.GitHubFailureText)
	end
end)

SpawnCall(function()
	Wait(20)
	for _, entry in NAStuff.RobloxVersionRows or {} do
		if entry.versionField and entry.versionField.Text == NAStuff.RobloxVersionLoadingText then
			entry.versionField.Text = NAStuff.RobloxVersionFailureText
		end
		if entry.dateField and entry.dateField.Text == NAStuff.RobloxVersionLoadingText then
			entry.dateField.Text = NAStuff.RobloxVersionFailureText
		end
	end
	if (NAStuff.GitHubCommitMessageField and NAStuff.GitHubCommitMessageField.Text == NAStuff.GitHubLoadingText)
		or (NAStuff.GitHubCommitDescriptionField and NAStuff.GitHubCommitDescriptionField.Text == NAStuff.GitHubLoadingText)
		or (NAStuff.GitHubCommitAuthorField and NAStuff.GitHubCommitAuthorField.Text == NAStuff.GitHubLoadingText)
		or (NAStuff.GitHubCommitDateField and NAStuff.GitHubCommitDateField.Text == NAStuff.GitHubLoadingText) then
		NAmanage.UpdateGitHubCommitUI(nil, NAStuff.GitHubFailureText)
	end
end)

const settingsBuildState = NAgui and NAgui.SettingsBuildState
local settingsRequestedTab = type(settingsBuildState) == "table" and settingsBuildState.userSelectedTab or nil
if not (settingsRequestedTab and TabManager and TabManager.tabs and TabManager.tabs[settingsRequestedTab]) then
	settingsRequestedTab = nil
end
const settingsDefaultTab = settingsRequestedTab or (NA_TABS and NA_TABS.TAB_GENERAL) or NAgui.getActiveTab()
if settingsDefaultTab and NAgui.setTab then
	NAgui.setTab(settingsDefaultTab, { forceMount = true })
end

SpawnCall(function()
	Wait()
	const currentTab = TabManager and TabManager.current
	if currentTab and TabManager.tabs and TabManager.tabs[currentTab] and NAgui and NAgui.setTab then
		NAgui.setTab(currentTab, { forceMount = true })
	end
end)
	end)
	pcall(function()
		const mountTab = (NA_TABS and NA_TABS.TAB_GENERAL) or (TabManager and TabManager.lastNonAll)
		if mountTab and TabManager and TabManager.tabs then
			const info = TabManager.tabs[mountTab]
			TabManager.current = mountTab
			TabManager.lastNonAll = mountTab
			if info and info.page then
				NAUIMANAGER.SettingsList = info.page
			end
		end
	end)
	if NAgui.SettingsBuildDone then
		pcall(NAgui.SettingsBuildDone)
	end
	if type(perf) == "table" then
		perf.settingsBuildElapsed = os.clock() - settingsBuildStart
		perf.settingsBuildOk = okBuild == true
	end
	pcall(function()
		const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
		if type(probe) == "table" and type(probe.mark) == "function" then
			probe.mark("settings_build_done")
		end
	end)
	NAStuff.SettingsBuildRunning = false
	NAStuff._loadingFinalizePending = false
	NAStuff.SettingsBuildReady = okBuild == true
	pcall(function()
		const state = NAgui and NAgui.SettingsBuildState
		local requestedTab = type(state) == "table" and state.userSelectedTab or nil
		if not (requestedTab and TabManager and TabManager.tabs and TabManager.tabs[requestedTab]) then
			requestedTab = nil
		end
		const mountTab = requestedTab or (NA_TABS and NA_TABS.TAB_GENERAL) or (TabManager and TabManager.lastNonAll)
		if okBuild and mountTab and NAgui and NAgui.setTab then
			NAgui.setTab(mountTab, { forceMount = true })
		end
		if type(state) == "table" then
			state.userInteracted = false
			state.userSelectedTab = nil
		end
	end)
	if NAmanage.finalizeLoadingState then
		pcall(NAmanage.finalizeLoadingState)
	end
	NAStuff.StartupInitializersReady = true
	if NAmanage.pumpLoaderQueue then
		pcall(NAmanage.pumpLoaderQueue)
	end
	if type(NAmanage.FinishStartupPerformance) == "function" then
		pcall(NAmanage.FinishStartupPerformance, okBuild and "settings ready" or "settings failed")
	end
	if not okBuild then
		warn(errBuild)
	end
end)
