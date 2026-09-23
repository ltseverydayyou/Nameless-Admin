NAmanage.StreamerScanContainerAsync = NAmanage.StreamerScanContainerAsync or function(root, opts)
	if typeof(root) ~= "Instance" then
		return
	end
	opts = opts or {}
	const state = NAmanage.StreamerGetState()
	local scanToken = opts.cancelToken
	if type(scanToken) ~= "table" then
		scanToken = state.token
	end
	const rec = NAmanage.StreamerGetRecord(root)
	if rec.scanQueued == true and rec.scanToken == scanToken then
		return
	end
	rec.scanQueued = true
	rec.scanToken = scanToken
	Spawn(function()
		if NAmanage.StreamerIsRunActive(scanToken) then
			NAmanage.StreamerScanContainer(root, scanToken, opts)
		end
		const liveState = NAmanage.StreamerGetState()
		const liveRec = liveState.cache and liveState.cache[root]
		if type(liveRec) == "table" and liveRec.scanToken == scanToken then
			liveRec.scanQueued = false
			liveRec.scanToken = nil
		end
	end)
end

NAmanage.StreamerWatchContainer = NAmanage.StreamerWatchContainer or function(container)
	if not NAmanage.StreamerIsContainer(container) then
		return
	end
	const rec = NAmanage.StreamerGetRecord(container)
	if not rec.containerDescConn then
		rec.containerDescConn = NAmanage.descAdd(container, function(inst)
			if NAmanage.StreamerIsRelevant(inst) then
				NAmanage.StreamerHandleAdded(inst)
			end
		end, NAmanage.StreamerIsRelevant)
	end
	if not rec.containerAncConn then
		rec.containerAncConn = container.AncestryChanged:Connect(function(_, parent)
			if parent then
				return
			end
			NAmanage.StreamerRestoreInstance(container)
		end)
	end
end

NAmanage.StreamerApplyProp = NAmanage.StreamerApplyProp or function(inst, prop, newValue)
	if typeof(inst) ~= "Instance" then
		return false
	end
	const current = NAlib.isProperty(inst, prop)
	if current == nil then
		return false
	end
	const rec = NAmanage.StreamerGetRecord(inst)
	const originalKey = prop .. "Original"
	const appliedKey = prop .. "Applied"
	if rec[appliedKey] == nil or current ~= rec[appliedKey] then
		rec[originalKey] = current
	end
	const okSet = NAlib.setProperty(inst, prop, newValue)
	if okSet then
		rec[appliedKey] = newValue
		return true
	end
	rec[appliedKey] = current
	return false
end

NAmanage.StreamerApplyCharacterVisual = NAmanage.StreamerApplyCharacterVisual or function(inst)
	if not (NAStuff and NAStuff.StreamerModeEnabled == true) then
		return
	end
	if typeof(inst) ~= "Instance" then
		return
	end

	const gray = NAStuff.StreamerModeGray or Color3.fromRGB(127, 127, 127)
	const inAccessory = inst:FindFirstAncestorOfClass("Accessory") ~= nil

	if inst:IsA("BasePart") then
		if inAccessory then
			NAmanage.StreamerApplyProp(inst, "LocalTransparencyModifier", 1)
			return
		end
		NAmanage.StreamerApplyProp(inst, "Color", gray)
		NAmanage.StreamerApplyProp(inst, "Material", Enum.Material.SmoothPlastic)
		NAmanage.StreamerApplyProp(inst, "Reflectance", 0)
		if inst:IsA("MeshPart") then
			NAmanage.StreamerApplyProp(inst, "TextureID", "")
		end
		return
	end

	if inst:IsA("Decal") or inst:IsA("Texture") then
		if not inAccessory then
			NAmanage.StreamerApplyProp(inst, "Transparency", 1)
		end
		return
	end

	if inst:IsA("CharacterMesh") then
		NAmanage.StreamerApplyProp(inst, "BaseTextureId", "")
		NAmanage.StreamerApplyProp(inst, "OverlayTextureId", "")
		NAmanage.StreamerApplyProp(inst, "MeshId", "")
		return
	end

	if inst:IsA("DataModelMesh") then
		NAmanage.StreamerApplyProp(inst, "TextureId", "")
		NAmanage.StreamerApplyProp(inst, "MeshId", "")
		NAmanage.StreamerApplyProp(inst, "VertexColor", Vector3.new(gray.R, gray.G, gray.B))
		return
	end

	if inst:IsA("Shirt") then
		NAmanage.StreamerApplyProp(inst, "ShirtTemplate", "")
		return
	end

	if inst:IsA("Pants") then
		NAmanage.StreamerApplyProp(inst, "PantsTemplate", "")
		return
	end

	if inst:IsA("ShirtGraphic") then
		NAmanage.StreamerApplyProp(inst, "Graphic", "")
		return
	end

	if inst:IsA("BodyColors") then
		const bodyColorProps = {
			"HeadColor3",
			"LeftArmColor3",
			"RightArmColor3",
			"LeftLegColor3",
			"RightLegColor3",
			"TorsoColor3",
		}
		for i = 1, #bodyColorProps do
			NAmanage.StreamerApplyProp(inst, bodyColorProps[i], gray)
		end
		return
	end
end

NAmanage.StreamerHandleCharacterDesc = NAmanage.StreamerHandleCharacterDesc or function(inst, token)
	if typeof(inst) ~= "Instance" then
		return
	end
	if token and not NAmanage.StreamerIsRunActive(token) then
		return
	end
	if inst:IsA("Humanoid") then
		NAmanage.StreamerApplyHumanoid(inst)
		return
	end
	if inst:IsA("Accessory") then
		NAmanage.ForEachDescendantYield(inst, function(desc)
			if token and not NAmanage.StreamerIsRunActive(token) then
				return
			end
			NAmanage.StreamerApplyCharacterVisual(desc)
		end, {
			includeRoot = true;
			yieldEvery = 48;
			cancelToken = token;
		})
		return
	end
	NAmanage.StreamerApplyCharacterVisual(inst)
end

NAmanage.StreamerApplyHumanoid = NAmanage.StreamerApplyHumanoid or function(hum)
	if not (NAStuff and NAStuff.StreamerModeEnabled == true) then
		return
	end
	if typeof(hum) ~= "Instance" or not hum:IsA("Humanoid") then
		return
	end
	const rec = NAmanage.StreamerGetRecord(hum)
	const replacement = tostring(NAStuff.StreamerModeText or "\0")
	NAmanage.StreamerApplyProp(hum, "DisplayDistanceType", Enum.HumanoidDisplayDistanceType.None)
	NAmanage.StreamerApplyProp(hum, "NameDisplayDistance", 0)
	NAmanage.StreamerApplyProp(hum, "Name", replacement)
	NAmanage.StreamerApplyProp(hum, "DisplayName", replacement)
	if not rec.ancConn then
		rec.ancConn = hum.AncestryChanged:Connect(function(_, parent)
			if parent then
				return
			end
			NAmanage.StreamerRestoreInstance(hum)
		end)
	end
end

NAmanage.StreamerHandleCharacter = NAmanage.StreamerHandleCharacter or function(char, token)
	if typeof(char) ~= "Instance" or not char:IsA("Model") then
		return
	end
	local scanToken = token
	if type(scanToken) ~= "table" then
		scanToken = NAmanage.StreamerGetState().token
	end
	const charRec = NAmanage.StreamerGetRecord(char)
	if charRec.charDescConn then
		return
	end
	const function isRelevant(inst)
		if not inst then
			return false
		end
		return inst:IsA("Humanoid")
			or inst:IsA("Accessory")
			or inst:IsA("BasePart")
			or inst:IsA("Decal")
			or inst:IsA("Texture")
			or inst:IsA("CharacterMesh")
			or inst:IsA("DataModelMesh")
			or inst:IsA("Shirt")
			or inst:IsA("Pants")
			or inst:IsA("ShirtGraphic")
			or inst:IsA("BodyColors")
	end
	charRec.charDescConn = NAmanage.descAdd(char, function(inst)
		if isRelevant(inst) then
			NAmanage.StreamerHandleCharacterDesc(inst, scanToken)
		end
	end, isRelevant)
	charRec.charAncConn = char.AncestryChanged:Connect(function(_, parent)
		if parent then
			return
		end
		NAmanage.StreamerRestoreInstance(char)
	end)
	charRec.charScanToken = scanToken
	Spawn(function()
		if scanToken and not NAmanage.StreamerIsRunActive(scanToken) then
			const liveState = NAmanage.StreamerGetState()
			const liveRec = liveState.cache and liveState.cache[char]
			if type(liveRec) == "table" and liveRec.charScanToken == scanToken then
				liveRec.charScanToken = nil
			end
			return
		end
		NAmanage.ForEachDescendantYield(char, function(inst)
			if scanToken and not NAmanage.StreamerIsRunActive(scanToken) then
				return
			end
			NAmanage.StreamerHandleCharacterDesc(inst, scanToken)
		end, {
			includeRoot = true;
			yieldEvery = 24;
			cancelToken = scanToken;
		})
		const liveState = NAmanage.StreamerGetState()
		const liveRec = liveState.cache and liveState.cache[char]
		if type(liveRec) == "table" and liveRec.charScanToken == scanToken then
			liveRec.charScanToken = nil
		end
	end)
end

NAmanage.StreamerApplyTextProp = NAmanage.StreamerApplyTextProp or function(inst, prop)
	local current = NAlib.isProperty(inst, prop)
	if current == nil then
		return
	end
	current = tostring(current)
	const rec = NAmanage.StreamerGetRecord(inst)
	const originalKey = prop .. "Original"
	const appliedKey = prop .. "Applied"
	if rec[appliedKey] == nil or current ~= rec[appliedKey] then
		rec[originalKey] = current
	end
	local original = rec[originalKey]
	if original == nil then
		original = current
		rec[originalKey] = original
	end
	const masked = NAmanage.StreamerMaskText(original)
	rec[appliedKey] = masked
	if current ~= masked then
		NAlib.setProperty(inst, prop, masked)
	end
end

NAmanage.StreamerApplyImageProp = NAmanage.StreamerApplyImageProp or function(inst)
	local current = NAlib.isProperty(inst, "Image")
	if current == nil then
		return
	end
	current = tostring(current)
	const rec = NAmanage.StreamerGetRecord(inst)
	if rec.ImageApplied == nil or current ~= rec.ImageApplied then
		rec.ImageOriginal = current
	end
	local original = rec.ImageOriginal
	if original == nil then
		original = current
		rec.ImageOriginal = original
	end
	local replacement = original
	if NAmanage.StreamerShouldMaskImage(original) then
		replacement = tostring(NAStuff.StreamerModeImage or "")
	end
	rec.ImageApplied = replacement
	if current ~= replacement then
		NAlib.setProperty(inst, "Image", replacement)
	end
end

NAmanage.StreamerScrubInstance = NAmanage.StreamerScrubInstance or function(inst)
	if not (NAStuff and NAStuff.StreamerModeEnabled == true) then
		return
	end
	if not NAmanage.StreamerIsTarget(inst) then
		return
	end
	NAmanage.StreamerWatchTarget(inst)
	if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
		NAmanage.StreamerApplyTextProp(inst, "Text")
		if inst:IsA("TextBox") then
			NAmanage.StreamerApplyTextProp(inst, "PlaceholderText")
		end
	end
	if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
		NAmanage.StreamerApplyImageProp(inst)
	end
end

NAmanage.StreamerRestoreInstance = NAmanage.StreamerRestoreInstance or function(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	const state = NAmanage.StreamerGetState()
	const rec = state.cache and state.cache[inst]
	if type(rec) ~= "table" then
		return true
	end
	if type(rec.signalConns) == "table" then
		for key, conn in rec.signalConns do
			NAmanage.StreamerDisconnectConn(conn)
			rec.signalConns[key] = nil
		end
	end
	if rec.ancConn then
		NAmanage.StreamerDisconnectConn(rec.ancConn)
		rec.ancConn = nil
	end
	if rec.charDescConn then
		NAmanage.StreamerDisconnectConn(rec.charDescConn)
		rec.charDescConn = nil
	end
	if rec.charAncConn then
		NAmanage.StreamerDisconnectConn(rec.charAncConn)
		rec.charAncConn = nil
	end
	if rec.containerDescConn then
		NAmanage.StreamerDisconnectConn(rec.containerDescConn)
		rec.containerDescConn = nil
	end
	if rec.containerAncConn then
		NAmanage.StreamerDisconnectConn(rec.containerAncConn)
		rec.containerAncConn = nil
	end
	rec.scanQueued = nil
	rec.scanToken = nil
	rec.charScanToken = nil
	local failed = false
	const function restoreProp(prop)
		const originalKey = prop .. "Original"
		const appliedKey = prop .. "Applied"
		const original = rec[originalKey]
		const current = NAlib.isProperty(inst, prop)
		if original ~= nil and current ~= nil then
			if not NAlib.setProperty(inst, prop, original) then
				failed = true
				return
			end
		end
		rec[originalKey] = nil
		rec[appliedKey] = nil
	end
	restoreProp("Text")
	restoreProp("PlaceholderText")
	restoreProp("Image")
	restoreProp("Color")
	restoreProp("Material")
	restoreProp("Reflectance")
	restoreProp("LocalTransparencyModifier")
	restoreProp("Transparency")
	restoreProp("TextureID")
	restoreProp("TextureId")
	restoreProp("MeshId")
	restoreProp("VertexColor")
	restoreProp("BaseTextureId")
	restoreProp("OverlayTextureId")
	restoreProp("ShirtTemplate")
	restoreProp("PantsTemplate")
	restoreProp("Graphic")
	restoreProp("HeadColor3")
	restoreProp("LeftArmColor3")
	restoreProp("RightArmColor3")
	restoreProp("LeftLegColor3")
	restoreProp("RightLegColor3")
	restoreProp("TorsoColor3")
	restoreProp("DisplayDistanceType")
	restoreProp("NameDisplayDistance")
	restoreProp("Name")
	restoreProp("DisplayName")
	if failed then
		return false
	end
	state.cache[inst] = nil
	return true
end

NAmanage.StreamerGetRoots = NAmanage.StreamerGetRoots or function(opts)
	opts = opts or {}
	const roots = {}
	const seen = {}
	const function addRoot(root)
		if typeof(root) ~= "Instance" or seen[root] then
			return
		end
		seen[root] = true
		Insert(roots, root)
	end

	addRoot(Services.CoreGui)
	do
		local ok, hub = pcall(function()
			return NAmanage._pgHubGet and NAmanage._pgHubGet()
		end)
		if ok and type(hub) == "table" then
			addRoot(hub.root)
		end
	end
	addRoot(NAlib.distinctHuiGrabber and NAlib.distinctHuiGrabber(Services.CoreGui) or nil)
	if opts.includeWorkspace == true then
		addRoot(Services.Workspace)
	end
	return roots
end

NAmanage.StreamerScrubAll = NAmanage.StreamerScrubAll or function(token, opts)
	const RawWorkspace = __lt.gs("Workspace")
	opts = opts or {}
	const state = NAmanage.StreamerGetState()
	if state.scrubBusy then
		return
	end
	state.scrubBusy = true
	pcall(function()
		const roots = NAmanage.StreamerGetRoots(opts)
		for i = 1, #roots do
			const root = roots[i]
			if token and token.cancelled then
				break
			end
			if root == Services.Workspace or root == RawWorkspace then
				NAmanage.ForEachDescendantYield(root, function(inst)
					if token and token.cancelled then
						return
					end
					if NAmanage.StreamerIsContainer(inst) then
						NAmanage.StreamerHandleAdded(inst)
					end
				end, {
					yieldEvery = tonumber(opts.yieldEvery) or 144;
					cancelToken = token;
				})
			else
				NAmanage.StreamerScanContainer(root, token, {
					yieldEvery = tonumber(opts.yieldEvery) or 96;
				})
			end
		end
	end)
	state.scrubBusy = false
end

NAmanage.StreamerSortRestorePending = NAmanage.StreamerSortRestorePending or function(pending)
	if type(pending) ~= "table" or #pending <= 1 then
		return pending
	end
	const sortMeta = {}
	for i = 1, #pending do
		const inst = pending[i]
		local depth = 0
		local current = inst
		while typeof(current) == "Instance" and current.Parent do
			depth += 1
			current = current.Parent
		end
		sortMeta[inst] = {
			depth = depth;
			key = tostring(inst);
		}
	end
	table.sort(pending, function(a, b)
		const metaA = sortMeta[a]
		const metaB = sortMeta[b]
		if metaA.depth == metaB.depth then
			return metaA.key > metaB.key
		end
		return metaA.depth > metaB.depth
	end)
	return pending
end

NAmanage.StreamerGetPriorityRoots = NAmanage.StreamerGetPriorityRoots or function()
	const roots = {}
	const seen = {}
	const function addRoot(root)
		if typeof(root) ~= "Instance" or seen[root] then
			return
		end
		seen[root] = true
		Insert(roots, root)
	end
	if Services.Players and Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character then
		addRoot(Services.Players.LocalPlayer.Character)
	end
	const baseRoots = NAmanage.StreamerGetRoots({
		includeWorkspace = false;
	})
	for i = 1, #baseRoots do
		addRoot(baseRoots[i])
	end
	return roots
end

NAmanage.StreamerRestorePriority = NAmanage.StreamerRestorePriority or function(opts)
	opts = opts or {}
	const state = NAmanage.StreamerGetState()
	const cache = state.cache
	if type(cache) ~= "table" then
		return 0
	end
	local roots = opts.roots
	if type(roots) ~= "table" then
		roots = NAmanage.StreamerGetPriorityRoots()
	end
	if #roots == 0 then
		return 0
	end
	const pending = {}
	const function isPriority(inst)
		if typeof(inst) ~= "Instance" then
			return false
		end
		for i = 1, #roots do
			const root = roots[i]
			if inst == root then
				return true
			end
			local ok, result = pcall(function()
				return inst:IsDescendantOf(root)
			end)
			if ok and result then
				return true
			end
		end
		return false
	end
	for inst in cache do
		if isPriority(inst) then
			Insert(pending, inst)
		end
	end
	NAmanage.StreamerSortRestorePending(pending)
	for i = 1, #pending do
		NAmanage.StreamerRestoreInstance(pending[i])
	end
	return #pending
end

NAmanage.StreamerRestoreAll = NAmanage.StreamerRestoreAll or function(opts)
	opts = opts or {}
	const state = NAmanage.StreamerGetState()
	if state.restoreToken then
		NAmanage.CancelTokenCancel(state.restoreToken)
		state.restoreToken = nil
	end
	const pending = {}
	for inst in state.cache do
		Insert(pending, inst)
	end
	NAmanage.StreamerSortRestorePending(pending)
	if #pending == 0 then
		if type(opts.onComplete) == "function" then
			pcall(opts.onComplete, 0, false)
		end
		return 0
	end
	local maxPerStep = tonumber(opts.maxPerStep) or tonumber(opts.yieldEvery) or 24
	if maxPerStep < 1 then
		maxPerStep = 1
	end
	local timeBudget = tonumber(opts.timeBudget)
	if timeBudget == nil then
		timeBudget = 0.002
	end
	if timeBudget < 0 then
		timeBudget = 0
	end
	const restoreAsync = opts.async ~= false
	const delayTime = opts.delayTime
	const restoreToken = NAmanage.NewCancelToken()
	state.restoreToken = restoreToken
	const onComplete = type(opts.onComplete) == "function" and opts.onComplete or nil
	local retries = tonumber(opts.retries)
	if retries == nil then
		retries = 2
	end
	local restored = 0
	local idx = 1
	const total = #pending

	const function finish()
		const cancelled = restoreToken.cancelled == true
		if state.restoreToken == restoreToken then
			state.restoreToken = nil
		end
		const remaining = NAmanage.StreamerCacheCount(state.cache)
		if not cancelled and remaining > 0 and retries > 0 then
			Delay(0.15, function()
				const liveState = NAmanage.StreamerGetState()
				if not (NAStuff and NAStuff.StreamerModeEnabled == true) and not liveState.restoreToken then
					NAmanage.StreamerRestoreAll({
						maxPerStep = maxPerStep;
						timeBudget = timeBudget;
						delayTime = delayTime;
						async = restoreAsync;
						retries = retries - 1;
						onComplete = onComplete;
					})
				elseif onComplete then
					pcall(onComplete, restored, true)
				end
			end)
			return
		end
		if onComplete then
			pcall(onComplete, restored, cancelled)
		end
	end

	if not restoreAsync then
		while idx <= total do
			if restoreToken.cancelled then
				break
			end
			local okRestore, didRestore = pcall(NAmanage.StreamerRestoreInstance, pending[idx])
			if okRestore and didRestore ~= false then
				restored += 1
			end
			idx += 1
		end
		finish()
		return restored
	end

	const function runWorker()
		while idx <= total do
			if restoreToken.cancelled then
				break
			end
			const started = os.clock()
			local stepCount = 0
			while idx <= total do
				if restoreToken.cancelled then
					break
				end
				local okRestore, didRestore = pcall(NAmanage.StreamerRestoreInstance, pending[idx])
				if okRestore and didRestore ~= false then
					restored += 1
				end
				idx += 1
				stepCount += 1
				if stepCount >= maxPerStep then
					break
				end
				if timeBudget > 0 and (os.clock() - started) >= timeBudget then
					break
				end
			end
			if idx <= total and not restoreToken.cancelled then
				if delayTime and delayTime > 0 then
					Wait(delayTime)
				else
					Wait()
				end
			end
		end
		finish()
	end

	Spawn(runWorker)
	return total
end

NAmanage.StreamerWatchPlayer = NAmanage.StreamerWatchPlayer or function(plr)
	if not (plr and Services.Players) then
		return
	end
	const userId = tonumber(plr.UserId)
	if not userId then
		return
	end
	const function onNameChanged()
		NAmanage.StreamerScheduleNameRefresh(true)
		if plr.Character then
			const hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				NAmanage.StreamerApplyHumanoid(hum)
			end
		end
	end
	NAlib.connect("streamermode_player_names", plr:GetPropertyChangedSignal("DisplayName"):Connect(onNameChanged))
	NAlib.connect("streamermode_player_names", plr:GetPropertyChangedSignal("Name"):Connect(onNameChanged))
	if plr.Character then
		NAmanage.StreamerHandleCharacter(plr.Character, NAmanage.StreamerGetState().token)
	end
	NAlib.connect("streamermode_player_chars", plr.CharacterAdded:Connect(function(char)
		if NAStuff and NAStuff.StreamerModeEnabled == true then
			NAmanage.StreamerHandleCharacter(char, NAmanage.StreamerGetState().token)
		end
	end))
end

NAmanage.StreamerHandleAdded = NAmanage.StreamerHandleAdded or function(inst)
	if not (NAStuff and NAStuff.StreamerModeEnabled == true) then
		return
	end
	if NAmanage.StreamerIsTarget(inst) then
		NAmanage.StreamerScrubInstance(inst)
		return
	end
	if NAmanage.StreamerIsContainer(inst) then
		NAmanage.StreamerWatchContainer(inst)
		NAmanage.StreamerScanContainerAsync(inst, {
			includeRoot = true;
			yieldEvery = 96;
			cancelToken = NAmanage.StreamerGetState().token;
		})
	end
end

NAmanage.setStreamerMode = NAmanage.setStreamerMode or function(enable, opts)
	opts = opts or {}
	const state = enable == true
	const wasEnabled = NAStuff.StreamerModeEnabled == true
	const smState = NAmanage.StreamerGetState()

	if opts.force ~= true and wasEnabled == state and not (state and smState.applied ~= true) then
		if opts.save ~= false then
			pcall(NAmanage.NASettingsSet, "streamerMode", state)
		end
		if state then
			NAmanage.StreamerSetPlayerListHidden(true)
			NAmanage.StreamerScheduleNameRefresh(true)
		end
		return state
	end

	NAStuff.StreamerModeEnabled = state
	if opts.save ~= false then
		pcall(NAmanage.NASettingsSet, "streamerMode", state)
	end

	if smState.token then
		NAmanage.CancelTokenCancel(smState.token)
		smState.token = nil
	end
	if smState.restoreToken then
		NAmanage.CancelTokenCancel(smState.restoreToken)
		smState.restoreToken = nil
	end

	if not state then
		smState.applied = false
		NAmanage.StreamerSetPlayerListHidden(false)
		NAlib.disconnect("streamermode_coregui")
		NAlib.disconnect("streamermode_playergui")
		NAlib.disconnect("streamermode_hui")
		NAlib.disconnect("streamermode_workspace")
		NAlib.disconnect("streamermode_player_chars")
		NAlib.disconnect("streamermode_players")
		NAlib.disconnect("streamermode_player_names")
		const restoreAsync = opts.restoreAsync ~= false
		const queued = NAmanage.StreamerRestoreAll({
			maxPerStep = tonumber(opts.maxPerStep) or tonumber(opts.yieldEvery) or 32;
			timeBudget = tonumber(opts.timeBudget) or 0.003;
			delayTime = opts.delayTime;
			async = restoreAsync;
		})
		if not opts.silent and DoNotif then
			if (tonumber(queued) or 0) > 0 and restoreAsync then
				DoNotif("Streamer Mode disabled (restoring in background)", 2)
			else
				DoNotif("Streamer Mode disabled", 2)
			end
		end
		return false
	end

	NAmanage.StreamerRefreshNameTokens()
	NAmanage.StreamerSetPlayerListHidden(true)
	Delay(0.25, function()
		if NAStuff and NAStuff.StreamerModeEnabled == true then
			NAmanage.StreamerSetPlayerListHidden(true)
		end
	end)
	NAlib.disconnect("streamermode_player_chars")
	NAlib.disconnect("streamermode_player_names")
	if Services.Players then
		for _, plr in __lt.cm("Players", "GetPlayers") do
			NAmanage.StreamerWatchPlayer(plr)
		end
	end

	NAlib.disconnect("streamermode_coregui")
	NAlib.connect("streamermode_coregui", NAmanage.cgSub({
		added = NAmanage.StreamerHandleAdded,
		filterAdded = NAmanage.StreamerIsRelevant,
		classNames = { "TextLabel", "TextButton", "TextBox", "ImageLabel", "ImageButton", "BillboardGui", "SurfaceGui" },
	}))
	NAlib.disconnect("streamermode_playergui")
	NAlib.connect("streamermode_playergui", NAmanage.pgSub({
		added = NAmanage.StreamerHandleAdded,
		filterAdded = NAmanage.StreamerIsRelevant,
	}))
	NAlib.disconnect("streamermode_hui")
	do
		const hui = NAlib.distinctHuiGrabber and NAlib.distinctHuiGrabber(Services.CoreGui) or nil
		if hui then
			NAlib.connect("streamermode_hui", NAmanage.descSub(hui, {
				added = NAmanage.StreamerHandleAdded,
				filterAdded = NAmanage.StreamerIsRelevant,
			}))
		end
	end
	NAlib.disconnect("streamermode_workspace")
	NAlib.connect("streamermode_workspace", NAmanage.wsSub({
		added = NAmanage.StreamerHandleAdded,
		filterAdded = NAmanage.StreamerIsContainer,
	}))
	NAlib.disconnect("streamermode_players")
	NAlib.connect("streamermode_players", NAmanage.playersSub({
		added = function(plr)
			NAmanage.StreamerWatchPlayer(plr)
			NAmanage.StreamerScheduleNameRefresh(false)
		end,
		removing = function()
			NAmanage.StreamerScheduleNameRefresh(false)
		end,
	}))

	const token = NAmanage.NewCancelToken()
	smState.token = token
	NAmanage.StreamerScrubAll(token, {
		includeWorkspace = true;
		yieldEvery = 72;
	})

	if not opts.silent and DoNotif then
		DoNotif("Streamer Mode enabled", 2)
	end
	smState.applied = true
	return true
end

NAStuff.CmdBar2 = {
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
}

function NAmanage.CmdBar2ClampValue(value, minValue, maxValue, fallback)
	local numberValue = tonumber(value)
	if not numberValue then
		return fallback
	end
	numberValue = math.floor(numberValue + 0.5)
	if numberValue < minValue then
		return minValue
	elseif numberValue > maxValue then
		return maxValue
	end
	return numberValue
end

function NAmanage.CmdBar2ComputeBodyHeight(totalHeight)
	const cfg = NAStuff.CmdBar2 or {}
	const available = totalHeight - (cfg.bodyOffsetY or 0) - (cfg.bodyBottomPadding or 0)
	if available < (cfg.bodyMinHeight or 0) then
		return cfg.bodyMinHeight or 0
	end
	return available
end

CustomFunctionSupport = isfile and isfolder and writefile and readfile and listfiles and appendfile;
FileSupport = isfile and isfolder and writefile and readfile and makefolder;

IsOnMobile=(function()
	const platform=__lt.cm("UserInputService", "GetPlatform")
	if platform==Enum.Platform.IOS or platform==Enum.Platform.Android or platform==Enum.Platform.AndroidTV or platform==Enum.Platform.Chromecast or platform==Enum.Platform.MetaOS then
		return true
	end
	if platform==Enum.Platform.None then
		return Services.UserInputService.TouchEnabled and not (Services.UserInputService.KeyboardEnabled or Services.UserInputService.MouseEnabled)
	end
	return false
end)()
IsOnPC=(function()
	const platform=__lt.cm("UserInputService", "GetPlatform")
	if platform==Enum.Platform.Windows or platform==Enum.Platform.OSX or platform==Enum.Platform.Linux or platform==Enum.Platform.SteamOS or platform==Enum.Platform.UWP or platform==Enum.Platform.DOS or platform==Enum.Platform.BeOS then
		return true
	end
	if platform==Enum.Platform.None then
		return Services.UserInputService.KeyboardEnabled or Services.UserInputService.MouseEnabled
	end
	return false
end)()

--[[ Character helpers ]]--
NA_GRAB_BODY = (function()
	const T = {};
	const _cache = setmetatable({}, {
		__mode = "k"
	});
	local overrideModel = nil;
	local overrideConn = nil;
	local selectingOverride = false;
	local lastOverridePickAt = 0;
	const OVERRIDE_PICK_COOLDOWN = 1.25;
	local setOverrideModel;
	local pickOverrideModel;
	const function asChar(obj)
		if not obj or typeof(obj) ~= "Instance" then
			return nil;
		end;
		if obj:IsA("Player") then
			return obj.Character;
		end;
		if obj:IsA("Model") then
			return obj;
		end;
		return nil;
	end;
	const function firstPart(model)
		if not model then
			return nil
		end
		const q = { model }
		local qi, qn = 1, 1
		while qi <= qn do
			const inst = q[qi]
			qi += 1
			if inst:IsA("BasePart") then
				return inst
			end
			const ch = inst:GetChildren()
			for i = 1, #ch do
				qn += 1
				q[qn] = ch[i]
			end
		end
		return nil
	end
	setOverrideModel = function(model)
		if overrideConn then
			overrideConn:Disconnect();
			overrideConn = nil;
		end;
		overrideModel = model;
		if model then
			overrideConn = model.AncestryChanged:Connect(function(_, parent)
				if not parent then
					if overrideConn then
						overrideConn:Disconnect();
						overrideConn = nil;
					end;
					overrideModel = nil;
					selectingOverride = false;
					if Services.Players and Services.Players.LocalPlayer and Services.Workspace then
						const lp = Services.Players.LocalPlayer;
						const cur = lp.Character;
						if cur and cur.Parent and (not cur:IsDescendantOf(Services.Workspace)) then
							Spawn(function()
								pickOverrideModel();
							end);
						end;
					end;
				end;
			end);
		end;
	end;
	pickOverrideModel = function(force)
		if selectingOverride then
			return overrideModel;
		end;
		if not (Window and Services.Players and Services.Players.LocalPlayer and Services.Workspace) then
			return overrideModel;
		end;
		const lp = Services.Players.LocalPlayer;
		const cur = lp.Character;
		if not cur then
			return overrideModel;
		end;
		if not force and cur:IsDescendantOf(Services.Workspace) then
			return overrideModel;
		end;
		selectingOverride = true;
		const btns = {};
		const cands = {};
		const seen = {};
		for _, plr in __lt.cm("Players", "GetPlayers") do
			const ch = plr.Character;
			if ch and ch:IsDescendantOf(Services.Workspace) and (not seen[ch]) then
				seen[ch] = true;
				Insert(cands, ch);
			end;
		end;
		if CheckIfNPC then
			const q = { Services.Workspace }
			local qi, qn = 1, 1
			while qi <= qn do
				const inst = q[qi]
				qi += 1

				if inst:IsA("Model") and not seen[inst] and CheckIfNPC(inst) then
					seen[inst] = true
					Insert(cands, inst)
				end

				const ch = inst:GetChildren()
				for i = 1, #ch do
					qn += 1
					q[qn] = ch[i]
				end
			end
		end
		const nCnt = {};
		for i = 1, #cands do
			const m = cands[i];
			const n = m.Name;
			nCnt[n] = (nCnt[n] or 0) + 1;
		end;
		const nUse = {};
		local done = false;
		const function fin()
			if done then
				return;
			end;
			done = true;
			selectingOverride = false;
		end;
		if #cands == 0 then
			Insert(btns, {
				Text = "No characters found",
				Callback = function()
					setOverrideModel(nil);
					fin();
				end
			});
		else
			for i = 1, #cands do
				const m = cands[i];
				const n = m.Name;
				local suffix = "";
				if nCnt[n] and nCnt[n] > 1 then
					nUse[n] = (nUse[n] or 0) + 1;
					suffix = " (" .. nUse[n] .. ")";
				end;
				Insert(btns, {
					Text = n .. suffix,
					Callback = function()
						setOverrideModel(m);
						fin();
					end
				});
			end;
		end;
		Insert(btns, {
			Text = "Cancel",
			Callback = function()
				setOverrideModel(nil);
				fin();
			end
		});
		Window({
			WindowTitle = "Select Character",
			Duration = nil,
			Text = "Choose a character or NPC model",
			Buttons = btns
		});
		return overrideModel;
	end;
	const function rebuild(model, rec)
		rec.head = nil
		rec.root = nil
		rec.torso = nil
		rec.humanoid = nil
		if not model then
			rec.dirty = false
			return rec
		end
		const q = { model }
		local qi, qn = 1, 1
		while qi <= qn do
			const inst = q[qi]
			qi += 1
			if inst:IsA("Humanoid") or inst:IsA("AnimationController") then
				rec.humanoid = rec.humanoid or inst
			elseif inst:IsA("BasePart") then
				const name = inst.Name:lower()
				if not rec.root and name:find("root", 1, true) then
					rec.root = inst
				elseif not rec.torso and name:find("torso", 1, true) then
					rec.torso = inst
				elseif not rec.head and name:find("head", 1, true) then
					rec.head = inst
				end
			end
			if rec.head and rec.root and rec.torso and rec.humanoid then
				break
			end
			const ch = inst:GetChildren()
			for i = 1, #ch do
				qn += 1
				q[qn] = ch[i]
			end
		end
		rec.dirty = false
		return rec
	end
	const function ensure(obj)
		local model = asChar(obj);
		if obj == Services.Players.LocalPlayer then
			if overrideModel then
				model = overrideModel;
			elseif model and model.Parent and (not model:IsDescendantOf(Services.Workspace)) then
				const now = os.clock()
				if now - lastOverridePickAt >= OVERRIDE_PICK_COOLDOWN then
					lastOverridePickAt = now
					model = pickOverrideModel(true) or model;
				end
			end;
		elseif not model then
			model = overrideModel;
		end;
		if not model then
			return nil;
		end;
		local rec = _cache[model];
		if not rec then
			rec = {
				dirty = true
			};
			_cache[model] = rec;

			const function applyCandidate(inst)
				if not inst then
					return
				end
				if not rec.humanoid and (inst:IsA("Humanoid") or inst:IsA("AnimationController")) then
					rec.humanoid = inst
					return
				end
				if not inst:IsA("BasePart") then
					return
				end
				const name = inst.Name:lower()
				if not rec.root and name:find("root", 1, true) then
					rec.root = inst
					return
				end
				if not rec.torso and name:find("torso", 1, true) then
					rec.torso = inst
					return
				end
				if not rec.head and name:find("head", 1, true) then
					rec.head = inst
				end
			end

			rec.a = NAmanage.descAdd(model, function(d)
				applyCandidate(d)
			end);

			rec.r = NAmanage.descRem(model, function(d)
				local removedTracked = false
				if rec.head == d then
					rec.head = nil;
					removedTracked = true
				end;
				if rec.root == d then
					rec.root = nil;
					removedTracked = true
				end;
				if rec.torso == d then
					rec.torso = nil;
					removedTracked = true
				end;
				if rec.humanoid == d then
					rec.humanoid = nil;
					removedTracked = true
				end;
				if removedTracked then
					rec.dirty = true;
				end
			end);

			rec.c = model.AncestryChanged:Connect(function(_, parent)
				if not parent then
					if rec.a then
						rec.a:Disconnect();
						rec.a = nil;
					end;
					if rec.r then
						rec.r:Disconnect();
						rec.r = nil;
					end;
					if rec.c then
						rec.c:Disconnect();
						rec.c = nil;
					end;
					_cache[model] = nil;
				end;
			end);
		end;
		if rec.dirty or rec.humanoid and rec.humanoid.Parent == nil then
			rebuild(model, rec);
		end;
		return rec, model;
	end;
	T.ensure = ensure;
	T.firstPart = firstPart;
	T.asChar = asChar;
	T.pickOverride = function()
		selectingOverride = false;
		setOverrideModel(nil);
		return pickOverrideModel(true);
	end;
	return T;
end)();

function getRoot(char)
	local rec, model = NA_GRAB_BODY.ensure(char)
	if not rec then return nil end
	return rec.root or (model and NA_GRAB_BODY.firstPart(model)) or nil
end

function getTorso(char)
	local rec, model = NA_GRAB_BODY.ensure(char)
	if not rec then return nil end
	return rec.torso or (model and NA_GRAB_BODY.firstPart(model)) or nil
end

function getHead(char)
	local rec, model = NA_GRAB_BODY.ensure(char)
	if not rec then return nil end
	return rec.head or (model and NA_GRAB_BODY.firstPart(model)) or nil
end

function getChar()
	const plr = Services.Players.LocalPlayer
	if not plr then return nil end
	local rec, model = NA_GRAB_BODY.ensure(plr)
	return model
end

function getPlrChar(plr)
	return NA_GRAB_BODY.asChar(plr)
end

function getBp()
	const plr = Services.Players.LocalPlayer
	return plr and plr:FindFirstChildOfClass("Backpack") or nil
end

function getHum(char, waitSeconds)
	local target

	if char then
		target = NA_GRAB_BODY.asChar(char) or char
	else
		const plr = Services.Players.LocalPlayer
		if plr then
			target = plr.Character
		end
	end

	if not target then
		return nil
	end

	local hum = target:FindFirstChildOfClass("Humanoid") or target:FindFirstChildOfClass("AnimationController")
	if hum then
		return hum
	end

	local timeout = tonumber(waitSeconds)
	if not timeout or timeout <= 0 then
		const rec = NA_GRAB_BODY.ensure(target)
		return rec and rec.humanoid or nil
	end

	timeout = math.max(0, timeout)
	const deadline = os.clock() + timeout

	const function findHumanoid()
		return target:FindFirstChildOfClass("Humanoid") or target:FindFirstChildOfClass("AnimationController")
	end

	while not hum and os.clock() < deadline do
		Wait(0.05)
		hum = findHumanoid()
	end

	if hum then
		return hum
	end

	const rec = NA_GRAB_BODY.ensure(target)
	return rec and rec.humanoid or nil
end

NAmanage.GetJumpLaunchVelocity = function(hum)
	if not hum then return nil end

	const jumpPower = tonumber(NAlib.isProperty(hum, "JumpPower"))
	if hum.UseJumpPower ~= false and jumpPower and jumpPower > 0 then
		return jumpPower
	end

	const jumpHeight = tonumber(NAlib.isProperty(hum, "JumpHeight"))
	if jumpHeight and jumpHeight > 0 then
		return math.sqrt(2 * Services.Workspace.Gravity * jumpHeight)
	end

	return jumpPower
end

NAmanage.GetJumpHeightFromJumpPower = function(jumpPower)
	const power = tonumber(jumpPower)
	if not power then return nil end

	local gravity = tonumber(Services.Workspace.Gravity) or 196.2
	if gravity <= 0 then
		gravity = 196.2
	end

	return (power * power) / (2 * gravity)
end

NAmanage.PrepareHumanoidForLaunch = function(hum)
	if not hum then return end

	pcall(function()
		if NAlib.isProperty(hum, "Sit") ~= nil then
			hum.Sit = false
		end
	end)

	pcall(function()
		if NAlib.isProperty(hum, "PlatformStand") ~= nil then
			hum.PlatformStand = false
		end
	end)

	local state
	pcall(function()
		state = hum:GetState()
	end)

	if state == Enum.HumanoidStateType.Seated
		or state == Enum.HumanoidStateType.FallingDown
		or state == Enum.HumanoidStateType.Ragdoll
		or state == Enum.HumanoidStateType.PlatformStanding then
		pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end)
	end
end

NAmanage.LaunchHumanoid = function(hum, root)
	if not hum then return false end

	if NAStuff.SafeJumpMethod == false then
		const launched = pcall(function()
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end)
		if launched and NAmanage.TPJumpPulse then
			pcall(NAmanage.TPJumpPulse, true)
		end
		return launched
	end

	root = root or getRoot(hum.Parent)
	if not root then return false end

	NAmanage.PrepareHumanoidForLaunch(hum)

	const launchY = NAmanage.GetJumpLaunchVelocity(hum)
	if not launchY then return false end

	local velocity = NAlib.isProperty(root, "AssemblyLinearVelocity") or root.Velocity
	if typeof(velocity) ~= "Vector3" then
		velocity = Vector3.new(0, 0, 0)
	end

	const boostedY = math.max(velocity.Y, launchY)
	local launched = NAlib.setProperty(root, "AssemblyLinearVelocity", Vector3.new(velocity.X, boostedY, velocity.Z))
	if not launched then
		launched = pcall(function()
			root.Velocity = Vector3.new(velocity.X, boostedY, velocity.Z)
		end)
	end

	if launched and NAmanage.TPJumpPulse then
		pcall(NAmanage.TPJumpPulse, true)
	end

	return launched
end

function getPlrHum(plr)
	return getHum(plr)
end

function IsR15(plr)
	plr=(plr or Services.Players.LocalPlayer)
	if plr then
		const h=getPlrHum(plr)
		if h and h.RigType==Enum.HumanoidRigType.R15 then return true end
	end
	return false
end

function IsR6(plr)
	plr=(plr or Services.Players.LocalPlayer)
	if plr then
		const h=getPlrHum(plr)
		if h and h.RigType==Enum.HumanoidRigType.R6 then return true end
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

CheckIfNPC = function(character)
	if not (character and character:IsA("Model")) then
		return false
	end
	const function isPlayerModel(model)
		if not Services.Players then
			return false
		end
		local okPlr, plr = pcall(function()
			return __lt.cm("Players", "GetPlayerFromCharacter", model)
		end)
		if okPlr and plr then
			return true
		end
		for _, p in __lt.cm("Players", "GetPlayers") do
			const ch = p.Character
			if ch and (model == ch or model:IsDescendantOf(ch) or ch:IsDescendantOf(model)) then
				return true
			end
		end
		return false
	end

	const humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	if isPlayerModel(character) then
		return false
	end
	return true
end

NAmanage.IsValidESPModel = function(model, allowNPC)
	if not (model and model:IsA("Model")) then
		return false
	end
	if not model.Parent or not Services.Workspace or not model:IsDescendantOf(Services.Workspace) then
		return false
	end
	const hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 or hum.Parent == nil then
		return false
	end
	const root = getRoot(model)
	if not root or root.Parent == nil then
		return false
	end
	if allowNPC then
		return true
	end
	local okPlr, plr = pcall(function()
		return __lt.cm("Players", "GetPlayerFromCharacter", model)
	end)
	return okPlr and plr ~= nil
end

FindInTable = function(tbl,val)
	if tbl==nil then return false end
	for _,v in tbl do
		if v==val then return true end
	end
	return false
end

updateCanvasSize = function(frame, scale)
	if not (frame and frame.Parent) then
		return
	end
	if NAUIMANAGER and frame == NAUIMANAGER.SettingsList and NAmanage.GetAttr and NAmanage.GetAttr(NAUIMANAGER.SettingsFrame, "NAHeavyResizeSuspended") == true then
		return
	end
	if NAmanage.GetAttr and NAmanage.GetAttr(frame, "NAManualCanvasSize") == true then
		return
	end

	NAmanage._canvasLayoutCache = NAmanage.ensureWeakTable(NAmanage._canvasLayoutCache, "kv")
	NAmanage._canvasHeightCache = NAmanage.ensureWeakTable(NAmanage._canvasHeightCache, "k")

	local layout = NAmanage._canvasLayoutCache[frame]
	if not (layout and layout.Parent == frame) then
		layout = frame:FindFirstChildOfClass("UIListLayout")
		NAmanage._canvasLayoutCache[frame] = layout
	end
	if not layout then
		return
	end

	local targetHeight = layout.AbsoluteContentSize.Y
	if scale and scale ~= 0 then
		targetHeight = targetHeight / scale
	end
	targetHeight = math.max(0, math.floor(targetHeight + 0.5))

	const last = NAmanage._canvasHeightCache[frame]
	if last ~= nil and last == targetHeight then
		return
	end
	NAmanage._canvasHeightCache[frame] = targetHeight

	const cs = frame.CanvasSize
	if cs.Y.Scale == 0 and (cs.Y.Offset or 0) == targetHeight then
		if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
			NAmanage.CustomScroll.refreshByTarget(frame);
		end
		return
	end

	frame.CanvasSize = UDim2.new(0, 0, 0, targetHeight)
	if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
		NAmanage.CustomScroll.refreshByTarget(frame);
	end
end

NAmanage.GetUIScaleFactor = function(inst)
	local scale = 1
	local current = inst
	while current do
		const uiScale = current:FindFirstChildOfClass("UIScale")
		if uiScale and uiScale.Scale then
			const uiScaleValue = tonumber(uiScale.Scale)
			if uiScaleValue and uiScaleValue > 0 then
				scale *= uiScaleValue
			end
		end
		current = current.Parent
	end
	return scale
end

NAmanage.GetLogicalAbsoluteSize = function(inst)
	if not inst then
		return Vector2.new()
	end
	const size = inst.AbsoluteSize or Vector2.new()
	local scale = NAmanage.GetUIScaleFactor and NAmanage.GetUIScaleFactor(inst) or 1
	if not scale or scale <= 0 then
		scale = 1
	end
	return Vector2.new(size.X / scale, size.Y / scale)
end

NAmanage.GetCanvasPositionScale = function(sf, axis)
	local fallback = NAmanage.GetUIScaleFactor and NAmanage.GetUIScaleFactor(sf) or 1
	if not fallback or fallback <= 0 then
		fallback = 1
	end
	if not (sf and sf:IsA("ScrollingFrame")) then
		return fallback
	end

	const axisName = (axis == "X" or axis == "Horizontal") and "X" or "Y"
	local canvasOffset = 0
	local absCanvas = nil
	pcall(function()
		canvasOffset = axisName == "X" and sf.CanvasSize.X.Offset or sf.CanvasSize.Y.Offset
		absCanvas = sf.AbsoluteCanvasSize
	end)
	const absOffset = absCanvas and (axisName == "X" and absCanvas.X or absCanvas.Y) or 0
	if canvasOffset and canvasOffset > 0 and absOffset and absOffset > 0 then
		const ratio = absOffset / canvasOffset
		if ratio and ratio > 0.01 and ratio < 100 then
			return ratio
		end
	end

	return fallback
end

NAmanage.GetLogicalCanvasPosition = function(sf)
	if not sf then
		return Vector2.new()
	end
	const pos = sf.CanvasPosition or Vector2.new()
	const sx = NAmanage.GetCanvasPositionScale and NAmanage.GetCanvasPositionScale(sf, "X") or 1
	const sy = NAmanage.GetCanvasPositionScale and NAmanage.GetCanvasPositionScale(sf, "Y") or 1
	return Vector2.new((tonumber(pos.X) or 0) / math.max(sx, 0.01), (tonumber(pos.Y) or 0) / math.max(sy, 0.01))
end

NAmanage.SetLogicalCanvasPosition = function(sf, x, y)
	if not sf then
		return
	end
	const sx = NAmanage.GetCanvasPositionScale and NAmanage.GetCanvasPositionScale(sf, "X") or 1
	const sy = NAmanage.GetCanvasPositionScale and NAmanage.GetCanvasPositionScale(sf, "Y") or 1
	sf.CanvasPosition = Vector2.new((tonumber(x) or 0) * math.max(sx, 0.01), (tonumber(y) or 0) * math.max(sy, 0.01))
end

NAmanage.GetLogicalWindowSize = function(inst)
	if not inst then
		return Vector2.new()
	end

	local size = nil
	pcall(function()
		size = inst.AbsoluteWindowSize
	end)

	if typeof(size) ~= "Vector2" or size.X <= 0 or size.Y <= 0 then
		size = inst.AbsoluteSize or Vector2.new()
	end

	local scaleX = NAmanage.GetUIScaleFactor and NAmanage.GetUIScaleFactor(inst) or 1
	local scaleY = scaleX
	if inst:IsA("ScrollingFrame") and NAmanage.GetCanvasPositionScale then
		scaleX = NAmanage.GetCanvasPositionScale(inst, "X")
		scaleY = NAmanage.GetCanvasPositionScale(inst, "Y")
	end
	if not scaleX or scaleX <= 0 then scaleX = 1 end
	if not scaleY or scaleY <= 0 then scaleY = 1 end

	return Vector2.new(math.max(1, size.X / scaleX), math.max(1, size.Y / scaleY))
end

NAmanage.CreateNAFreecam=function()
	const module = {}

	const pi = math.pi
	const clamp = math.clamp
	const exp = math.exp
	const rad = math.rad
	const sqrt = math.sqrt
	const tan = math.tan

	local Camera = Services.Workspace.CurrentCamera

	Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		if Services.Workspace.CurrentCamera then
			Camera = Services.Workspace.CurrentCamera
		end
	end)

	const Spring = {} do
		Spring.__index = Spring

		function Spring.new(freq, pos)
			const self = setmetatable({}, Spring)
			self.f = freq
			self.p = pos
			self.v = pos*0
			return self
		end

		function Spring:Update(dt, goal)
			const f = self.f*2*pi
			const p0 = self.p
			const v0 = self.v

			const offset = goal - p0
			const decay = exp(-f*dt)

			const p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
			const v1 = (f*dt*(offset*f - v0) + v0)*decay

			self.p = p1
			self.v = v1

			return p1
		end

		function Spring:SetFreq(freq)
			self.f = freq
		end

		function Spring:Reset(pos)
			self.p = pos
			self.v = pos*0
		end
	end

	local cameraPos = Vector3.new(0, 0, 0)
	local cameraRot = Vector2.new()
	local cameraFov = 70

	const velSpring = Spring.new(1.5, Vector3.new(0, 0, 0))
	const panSpring = Spring.new(1.0, Vector2.new())
	const fovSpring = Spring.new(4.0, 0)

	const NAV_GAIN = Vector3.new(1, 1, 1)*64
	const FOV_GAIN = 300
	const PITCH_LIMIT = rad(90)

	const PAN_PIXELS_TO_RADIANS = rad(0.5)
	const FOV_WHEEL_SPEED = 1.0
	const FOV_WHEEL_SPEED_DT = FOV_WHEEL_SPEED/60

	const NAV_ADJ_SPEED = 0.75
	const NAV_MIN_SPEED = 0.01
	const NAV_MAX_SPEED = 4.0
	const NAV_SHIFT_MUL = 0.25

	const keyboard = {
		[Enum.KeyCode.W] = 0,
		[Enum.KeyCode.A] = 0,
		[Enum.KeyCode.S] = 0,
		[Enum.KeyCode.D] = 0,
		[Enum.KeyCode.Up] = 0,
		[Enum.KeyCode.Down] = 0,
	}

	const function normalizeKeyName(value, fallback)
		local key = value
		if type(key) ~= "string" then
			key = tostring(key or "")
		end
		key = key:match("^%s*(.-)%s*$") or ""
		if key == "" then
			key = tostring(fallback or "")
		end
		key = key:gsub("^Enum%.KeyCode%.", "")
		return key
	end

	const function keyCodeFromName(value, fallback)
		const name = normalizeKeyName(value, fallback)
		local ok, code = pcall(function()
			return Enum.KeyCode[name]
		end)
		if ok and code and code ~= Enum.KeyCode.Unknown then
			return code
		end
		const lowerName = Lower(name)
		for _, enumKey in Enum.KeyCode:GetEnumItems() do
			if Lower(enumKey.Name) == lowerName then
				return enumKey
			end
		end
		return nil
	end

	const function getVerticalKeys()
		const upKey = keyCodeFromName(NAStuff.FreecamUpKey, "E") or Enum.KeyCode.E
		const downKey = keyCodeFromName(NAStuff.FreecamDownKey, "Q") or Enum.KeyCode.Q
		return upKey, downKey
	end

	const function isFreecamKeyboardKey(keyCode)
		if keyboard[keyCode] ~= nil then
			return true
		end
		local upKey, downKey = getVerticalKeys()
		return keyCode == upKey or keyCode == downKey
	end

	const mouse = {
		Delta = Vector2.new(),
		MouseWheel = 0,
	}

	local navSpeed = 1

	const function zeroInput()
		for key in keyboard do
			keyboard[key] = 0
		end
		mouse.Delta = Vector2.new()
		mouse.MouseWheel = 0
	end

	local capturing = false
	local touchConnection = nil

	const function onKeypress(_, inputState, input)
		if input.KeyCode and isFreecamKeyboardKey(input.KeyCode) then
			if inputState == Enum.UserInputState.Begin then
				keyboard[input.KeyCode] = 1
			elseif inputState == Enum.UserInputState.End then
				keyboard[input.KeyCode] = 0
			end
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end

	const function onMousePan(_, inputState, input)
		if inputState == Enum.UserInputState.Change then
			const delta = input.Delta
			mouse.Delta = Vector2.new(-delta.Y, -delta.X)
		end
		return Enum.ContextActionResult.Sink
	end

	const function onTouchPan(_, inputState, input)
		if inputState == Enum.UserInputState.Change then
			const delta = input.Delta
			mouse.Delta = Vector2.new(-delta.Y, -delta.X)
		end
		return Enum.ContextActionResult.Pass
	end

	const function onMouseWheel(_, inputState, input)
		if inputState == Enum.UserInputState.Change then
			mouse.MouseWheel = -input.Position.Z
		end
		return Enum.ContextActionResult.Sink
	end

	const function inputVel(dt)
		if not IsOnMobile then
			navSpeed = clamp(navSpeed + dt*(keyboard[Enum.KeyCode.Up] - keyboard[Enum.KeyCode.Down])*NAV_ADJ_SPEED, NAV_MIN_SPEED, NAV_MAX_SPEED)
		end

		local move = Vector3.new(0, 0, 0)

		if IsOnMobile and typeof(GetCustomMoveVector) == "function" then
			local ok, vec = pcall(GetCustomMoveVector)
			if ok and vec and vec.Magnitude > 0 then
				move = vec
			end
		else
			local freecamUpKey, freecamDownKey = getVerticalKeys()
			move = Vector3.new(
				(keyboard[Enum.KeyCode.D] - keyboard[Enum.KeyCode.A]),
				(keyboard[freecamUpKey] or 0) - (keyboard[freecamDownKey] or 0),
				-(keyboard[Enum.KeyCode.W] - keyboard[Enum.KeyCode.S])
			)
		end

		const shift = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftShift) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightShift)

		return move*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	const function inputPan(dt)
		const kMouse = mouse.Delta
		mouse.Delta = Vector2.new()
		return kMouse
	end

	const function inputFov(dt)
		local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
		if dt > 0 then
			kMouse = (mouse.MouseWheel/dt)*FOV_WHEEL_SPEED_DT
		end
		mouse.MouseWheel = 0
		return kMouse
	end

	local enabled = false
	const storedState = {}

	const function setCameraCFrame(cframe)
		if typeof(cframe) ~= "CFrame" or not Camera then
			return false
		end

		local x, y, _ = cframe:ToOrientation()
		cameraPos = cframe.Position
		cameraRot = Vector2.new(x, y)
		cameraFov = Camera.FieldOfView
		velSpring:Reset(Vector3.new())
		panSpring:Reset(Vector2.new())
		fovSpring:Reset(0)
		zeroInput()
		Camera.CFrame = cframe
		Camera.Focus = cframe
		return true
	end

	const function stepFreecam(dt)
		if not Camera then
			return
		end

		const vel = inputVel(dt)
		const pan = inputPan(dt)
		const fovStep = inputFov(dt)

		const zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))
		cameraFov = clamp(cameraFov + fovStep*FOV_GAIN*(dt/zoomFactor), 1, 120)

		cameraRot = cameraRot + pan*(PAN_PIXELS_TO_RADIANS/zoomFactor)
		cameraRot = Vector2.new(clamp(cameraRot.X, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.Y%(2*pi))

		const cf = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.X, cameraRot.Y, 0)*CFrame.new(vel*NAV_GAIN*dt)

		cameraPos = cf.Position

		Camera.CFrame = cf
		Camera.Focus = cf
		Camera.FieldOfView = cameraFov
	end

	function module.Start(initialSpeed, initialCFrame)
		if enabled or not Camera then
			return
		end

		enabled = true

		if initialSpeed ~= nil then
			const scaled = tonumber(initialSpeed)
			if scaled then
				navSpeed = clamp(scaled, NAV_MIN_SPEED, NAV_MAX_SPEED)
			end
		end

		storedState.cameraType = Camera.CameraType
		storedState.cameraCFrame = Camera.CFrame
		storedState.cameraFocus = Camera.Focus
		storedState.cameraFov = Camera.FieldOfView
		storedState.mouseIconEnabled = Services.UserInputService.MouseIconEnabled
		storedState.mouseBehavior = Services.UserInputService.MouseBehavior

		const cframe = typeof(initialCFrame) == "CFrame" and initialCFrame or Camera.CFrame
		setCameraCFrame(cframe)

		Camera.CameraType = Enum.CameraType.Fixed
		Services.UserInputService.MouseIconEnabled = false
		Services.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		if not capturing and Services.ContextActionService then
			const freecamKeyboardAction = NAmanage.GetSessionActionName("FreecamKeyboard")
			const freecamMousePanAction = NAmanage.GetSessionActionName("FreecamMousePan")
			const freecamMouseWheelAction = NAmanage.GetSessionActionName("FreecamMouseWheel")
			local freecamUpKey, freecamDownKey = getVerticalKeys()
			capturing = true
			__lt.cm("ContextActionService", "BindActionAtPriority", freecamKeyboardAction, onKeypress, false, Enum.ContextActionPriority.High.Value,
				Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
				freecamUpKey, freecamDownKey,
				Enum.KeyCode.Up, Enum.KeyCode.Down
			)
			__lt.cm("ContextActionService", "BindActionAtPriority", freecamMousePanAction, onMousePan, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseMovement)
			__lt.cm("ContextActionService", "BindActionAtPriority", freecamMouseWheelAction, onMouseWheel, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseWheel)
		end

		if IsOnMobile and not touchConnection then
			touchConnection = Services.UserInputService.InputChanged:Connect(function(input, gameProcessed)
				if input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				if gameProcessed then
					return
				end
				if input.UserInputState ~= Enum.UserInputState.Change then
					return
				end
				const delta = input.Delta
				mouse.Delta = Vector2.new(-delta.Y, -delta.X)
			end)
		end

		const freecamRenderBind = NAmanage.GetSessionActionName("FreecamRenderStep")
		__lt.cm("RunService", "BindToRenderStep", freecamRenderBind, Enum.RenderPriority.Camera.Value, stepFreecam)
	end

	function module.Stop()
		if not enabled then
			return
		end

		enabled = false
		const freecamRenderBind = NAmanage.GetSessionActionName("FreecamRenderStep")
		__lt.cm("RunService", "UnbindFromRenderStep", freecamRenderBind)

		if capturing and Services.ContextActionService then
			const freecamKeyboardAction = NAmanage.GetSessionActionName("FreecamKeyboard")
			const freecamMousePanAction = NAmanage.GetSessionActionName("FreecamMousePan")
			const freecamMouseWheelAction = NAmanage.GetSessionActionName("FreecamMouseWheel")
			capturing = false
			__lt.cm("ContextActionService", "UnbindAction", freecamKeyboardAction)
			__lt.cm("ContextActionService", "UnbindAction", freecamMousePanAction)
			__lt.cm("ContextActionService", "UnbindAction", freecamMouseWheelAction)
		end

		if touchConnection then
			touchConnection:Disconnect()
			touchConnection = nil
		end

		zeroInput()

		if Camera and storedState.cameraType then
			Camera.CameraType = storedState.cameraType
			Camera.CFrame = storedState.cameraCFrame
			Camera.Focus = storedState.cameraFocus
			Camera.FieldOfView = storedState.cameraFov
		end

		if storedState.mouseIconEnabled ~= nil then
			Services.UserInputService.MouseIconEnabled = storedState.mouseIconEnabled
		end
		if storedState.mouseBehavior ~= nil then
			local behavior = storedState.mouseBehavior
			if behavior == Enum.MouseBehavior.LockCenter then
				behavior = Enum.MouseBehavior.Default
			end
			Services.UserInputService.MouseBehavior = behavior
		end
	end

	function module.SetCFrame(cframe)
		if not enabled then
			return false
		end
		return setCameraCFrame(cframe)
	end

	function module.SetSpeed(newSpeed)
		const scaled = tonumber(newSpeed)
		if scaled then
			navSpeed = clamp(scaled, NAV_MIN_SPEED, NAV_MAX_SPEED)
		end
	end

	function module.Toggle(initialSpeed)
		if enabled then
			module.Stop()
		else
			module.Start(initialSpeed)
		end
	end

	function module.IsEnabled()
		return enabled
	end

	const FREECAM_MACRO_KEYS = { Enum.KeyCode.LeftShift, Enum.KeyCode.P }

	const function checkMacro()
		for i = 1, #FREECAM_MACRO_KEYS - 1 do
			if not __lt.cm("UserInputService", "IsKeyDown", FREECAM_MACRO_KEYS[i]) then
				return
			end
		end

		if _na_env.NAFreecamKeybindEnabled ~= true then
			return
		end

		module.Toggle()
	end

	if Services.ContextActionService then
		const freecamToggleAction = NAmanage.GetSessionActionName("FreecamToggleKey")
		__lt.cm("ContextActionService", "BindActionAtPriority", freecamToggleAction, function(_, state, input)
			if state == Enum.UserInputState.Begin and input.KeyCode == FREECAM_MACRO_KEYS[#FREECAM_MACRO_KEYS] then
				checkMacro()
			end
			return Enum.ContextActionResult.Pass
		end, false, Enum.ContextActionPriority.Low.Value, FREECAM_MACRO_KEYS[#FREECAM_MACRO_KEYS])
	end

	return module
end

NAFreecam = NAmanage.CreateNAFreecam()

--[[ legacy NAFreecam implementation (disabled)
NAFreecam = {}
do
	pi = math.pi
	clamp = math.clamp
	exp = math.exp
	rad = math.rad
	sqrt = math.sqrt
	tan = math.tan

	Camera = Workspace.CurrentCamera

	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		if Workspace.CurrentCamera then
			Camera = Workspace.CurrentCamera
		end
	end)

	Spring = {} do
		Spring.__index = Spring

		function Spring.new(freq, pos)
			self = setmetatable({}, Spring)
			self.f = freq
			self.p = pos
			self.v = pos*0
			return self
		end

		function Spring:Update(dt, goal)
			f = self.f*2*pi
			p0 = self.p
			v0 = self.v

			offset = goal - p0
			decay = exp(-f*dt)

			p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
			v1 = (f*dt*(offset*f - v0) + v0)*decay

			self.p = p1
			self.v = v1

			return p1
		end

		function Spring:SetFreq(freq)
			self.f = freq
		end

		function Spring:Reset(pos)
			self.p = pos
			self.v = pos*0
		end
	end

	cameraPos = Vector3.new(0, 0, 0)
	cameraRot = Vector2.new()
	cameraFov = 70

	velSpring = Spring.new(1.5, Vector3.new(0, 0, 0))
	panSpring = Spring.new(1.0, Vector2.new())
	fovSpring = Spring.new(4.0, 0)

	NAV_GAIN = Vector3.new(1, 1, 1)*64
	PAN_GAIN = Vector2.new(0.75, 1)*8
	FOV_GAIN = 300
	PITCH_LIMIT = rad(90)

	DEFAULT_FPS = 60
	PAN_MOUSE_SPEED = Vector2.new(1, 1)*(pi/64)
	PAN_MOUSE_SPEED_DT = PAN_MOUSE_SPEED/DEFAULT_FPS
	FOV_WHEEL_SPEED = 1.0
	FOV_WHEEL_SPEED_DT = FOV_WHEEL_SPEED/DEFAULT_FPS

	NAV_ADJ_SPEED = 0.75
	NAV_MIN_SPEED = 0.01
	NAV_MAX_SPEED = 4.0
	NAV_SHIFT_MUL = 0.25

	keyboard = {
		[Enum.KeyCode.W] = 0,
		[Enum.KeyCode.A] = 0,
		[Enum.KeyCode.S] = 0,
		[Enum.KeyCode.D] = 0,
		[Enum.KeyCode.Q] = 0,
		[Enum.KeyCode.E] = 0,
		[Enum.KeyCode.Up] = 0,
		[Enum.KeyCode.Down] = 0,
	}

	mouse = {
		Delta = Vector2.new(),
		MouseWheel = 0,
	}

	navSpeed = 1

	function zeroInput()
		for key in keyboard do
			keyboard[key] = 0
		end
		mouse.Delta = Vector2.new()
		mouse.MouseWheel = 0
	end

	capturing = false

	function onKeypress(_, inputState, input)
		if input.KeyCode and keyboard[input.KeyCode] ~= nil then
			if inputState == Enum.UserInputState.Begin then
				keyboard[input.KeyCode] = 1
			elseif inputState == Enum.UserInputState.End then
				keyboard[input.KeyCode] = 0
			end
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end

	function onMousePan(_, inputState, input)
		if inputState == Enum.UserInputState.Change then
			delta = input.Delta
			mouse.Delta = Vector2.new(-delta.Y, -delta.X)
		end
		return Enum.ContextActionResult.Sink
	end

	function onMouseWheel(_, inputState, input)
		if inputState == Enum.UserInputState.Change then
			mouse.MouseWheel = input.Position.Z
		end
		return Enum.ContextActionResult.Sink
	end

	function inputVel(dt)
		navSpeed = clamp(navSpeed + dt*(keyboard[Enum.KeyCode.Up] - keyboard[Enum.KeyCode.Down])*NAV_ADJ_SPEED, NAV_MIN_SPEED, NAV_MAX_SPEED)

		kKeyboard = Vector3.new(
			(keyboard[Enum.KeyCode.D] - keyboard[Enum.KeyCode.A]),
			(keyboard[Enum.KeyCode.E] - keyboard[Enum.KeyCode.Q]),
			-(keyboard[Enum.KeyCode.W] - keyboard[Enum.KeyCode.S])
		)

		shift = __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.LeftShift) or __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.RightShift)

		return kKeyboard*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function inputPan(dt)
		kMouse = mouse.Delta*PAN_MOUSE_SPEED
		if dt > 0 then
			kMouse = (mouse.Delta/dt)*PAN_MOUSE_SPEED_DT
		end
		mouse.Delta = Vector2.new()
		return kMouse
	end

	function inputFov(dt)
		kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
		if dt > 0 then
			kMouse = (mouse.MouseWheel/dt)*FOV_WHEEL_SPEED_DT
		end
		mouse.MouseWheel = 0
		return kMouse
	end

	enabled = false
	storedState = {}

	function stepFreecam(dt)
		if not Camera then
			return
		end

		vel = velSpring:Update(dt, inputVel(dt))
		pan = panSpring:Update(dt, inputPan(dt))
		fovStep = fovSpring:Update(dt, inputFov(dt))

		zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))
		cameraFov = clamp(cameraFov + fovStep*FOV_GAIN*(dt/zoomFactor), 1, 120)

		cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
		cameraRot = Vector2.new(clamp(cameraRot.X, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.Y%(2*pi))

		cf = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.X, cameraRot.Y, 0)*CFrame.new(vel*NAV_GAIN*dt)

		cameraPos = cf.Position

		Camera.CFrame = cf
		Camera.Focus = cf
		Camera.FieldOfView = cameraFov
	end

	function NAFreecam.Start(initialSpeed)
		if enabled or not Camera then
			return
		end

		enabled = true

		if initialSpeed ~= nil then
			scaled = tonumber(initialSpeed)
			if scaled then
				navSpeed = clamp(scaled, NAV_MIN_SPEED, NAV_MAX_SPEED)
			end
		end

		storedState.cameraType = Camera.CameraType
		storedState.cameraCFrame = Camera.CFrame
		storedState.cameraFocus = Camera.Focus
		storedState.cameraFov = Camera.FieldOfView
		storedState.mouseIconEnabled = UserInputService.MouseIconEnabled
		storedState.mouseBehavior = UserInputService.MouseBehavior

		cframe = Camera.CFrame
		x, y, _ = cframe:ToOrientation()
		cameraPos = cframe.Position
		cameraRot = Vector2.new(x, y)
		cameraFov = Camera.FieldOfView

		velSpring:Reset(Vector3.new(0, 0, 0))
		panSpring:Reset(Vector2.new())
		fovSpring:Reset(0)

		Camera.CameraType = Enum.CameraType.Fixed
		UserInputService.MouseIconEnabled = false
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

		if not capturing and ContextActionService then
			freecamKeyboardAction = NAmanage.GetSessionActionName("FreecamKeyboard")
			freecamMousePanAction = NAmanage.GetSessionActionName("FreecamMousePan")
			freecamMouseWheelAction = NAmanage.GetSessionActionName("FreecamMouseWheel")
			capturing = true
			__lt.cm("ContextActionService", "BindActionAtPriority", freecamKeyboardAction, onKeypress, false, Enum.ContextActionPriority.High.Value,
				Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
				Enum.KeyCode.Q, Enum.KeyCode.E,
				Enum.KeyCode.Up, Enum.KeyCode.Down
			)
			__lt.cm("ContextActionService", "BindActionAtPriority", freecamMousePanAction, onMousePan, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseMovement)
			__lt.cm("ContextActionService", "BindActionAtPriority", freecamMouseWheelAction, onMouseWheel, false, Enum.ContextActionPriority.High.Value, Enum.UserInputType.MouseWheel)
		end

		freecamRenderBind = NAmanage.GetSessionActionName("FreecamRenderStep")
		__lt.cm("RunService", "BindToRenderStep", freecamRenderBind, Enum.RenderPriority.Camera.Value, stepFreecam)
	end

	function NAFreecam.Stop()
		if not enabled then
			return
		end

		enabled = false
		freecamRenderBind = NAmanage.GetSessionActionName("FreecamRenderStep")
		__lt.cm("RunService", "UnbindFromRenderStep", freecamRenderBind)

		if capturing and ContextActionService then
			freecamKeyboardAction = NAmanage.GetSessionActionName("FreecamKeyboard")
			freecamMousePanAction = NAmanage.GetSessionActionName("FreecamMousePan")
			freecamMouseWheelAction = NAmanage.GetSessionActionName("FreecamMouseWheel")
			capturing = false
			__lt.cm("ContextActionService", "UnbindAction", freecamKeyboardAction)
			__lt.cm("ContextActionService", "UnbindAction", freecamMousePanAction)
			__lt.cm("ContextActionService", "UnbindAction", freecamMouseWheelAction)
		end

		zeroInput()

		if Camera and storedState.cameraType then
			Camera.CameraType = storedState.cameraType
			Camera.CFrame = storedState.cameraCFrame
			Camera.Focus = storedState.cameraFocus
			Camera.FieldOfView = storedState.cameraFov
		end

		if storedState.mouseIconEnabled ~= nil then
			UserInputService.MouseIconEnabled = storedState.mouseIconEnabled
		end
		if storedState.mouseBehavior ~= nil then
			UserInputService.MouseBehavior = storedState.mouseBehavior
		end
	end

	function NAFreecam.Toggle(initialSpeed)
		if enabled then
			NAFreecam.Stop()
		else
			NAFreecam.Start(initialSpeed)
		end
	end

	function NAFreecam.IsEnabled()
		return enabled
	end
end
]]

originalIO = {}

originalIO.captureIO=function(name)
	const fn = rawget(_G, name)
	if type(fn) == "function" then
		originalIO[name] = fn
	end
end

if not originalIO.__captured then
	originalIO.__captured = true
	originalIO.captureIO('readfile')
	originalIO.captureIO('writefile')
	originalIO.captureIO('appendfile')
	originalIO.captureIO('listfiles')
	originalIO.captureIO('makefolder')
	originalIO.captureIO('delfile')
	originalIO.captureIO('delfolder')
	originalIO.captureIO('isfile')
	originalIO.captureIO('isfolder')
end

originalIO.pathVariants=function(path)
	if type(path) ~= "string" then
		return { path }
	end
	if path:match('^[%w_]+://') then
		return { path }
	end
	const variants, seen = {}, {}
	const function add(value)
		if type(value) == "string" and value ~= "" and not seen[value] then
			seen[value] = true
			Insert(variants, value)
		end
	end
	add(path)
	add(path:gsub('\\+', '\\'))
	add(path:gsub('//+', '/'))
	add(path:gsub('/', '\\'))
	add(path:gsub('\\', '/'))
	const trimmed = path:gsub('^%.[/\]+', '')
	if trimmed ~= path then
		add(trimmed)
		add(trimmed:gsub('/', '\\'))
		add(trimmed:gsub('\\', '/'))
	end
	return variants
end

originalIO.resolveWithListfiles=function(target)
	const lf = originalIO.listfiles
	if type(lf) ~= "function" then
		return nil
	end
	local dir, filename = target:match('^(.*)[/\\]([^/\\]+)$')
	if not dir or filename == '' then
		return nil
	end
	const dirVariants = originalIO.pathVariants(dir)
	const results = {}
	const lowered = filename:lower()
	for _, candidateDir in dirVariants do
		local ok, entries = pcall(lf, candidateDir)
		if ok and type(entries) == "table" then
			for _, entry in entries do
				const name = entry:match('([^/\\]+)$')
				if name and name:lower() == lowered then
					Insert(results, entry)
				end
			end
		end
	end
	if #results > 0 then
		return results
	end
	return nil
end

if identifyexecutor and identifyexecutor():lower()=="xeno" then
	if not _na_env["__NA_SOLARA_PATH_FIX__"] then
		_na_env["__NA_SOLARA_PATH_FIX__"] = true

		const function wrapWithFallback(fn, returnsBool, allowListResolve)
			if type(fn) ~= "function" then
				return nil
			end
			return function(path, ...)
				if type(path) ~= "string" then
					local ok, result = pcall(fn, path, ...)
					if ok then
						return result
					end
					if returnsBool then
						return false
					end
					error(result)
				end

				for _, candidate in originalIO.pathVariants(path) do
					local ok, result = pcall(fn, candidate, ...)
					if ok then
						return result
					end
				end

				if allowListResolve then
					const resolved = originalIO.resolveWithListfiles(path)
					if resolved then
						for _, candidate in resolved do
							local ok, result = pcall(fn, candidate, ...)
							if ok then
								return result
							end
						end
					end
				end

				if returnsBool then
					return false
				end
				error(("failed to access %s"):format(path))
			end
		end

		if originalIO.readfile then
			readfile = wrapWithFallback(originalIO.readfile, false, true)
		end
		if originalIO.writefile then
			writefile = wrapWithFallback(originalIO.writefile, false, true)
		end
		if originalIO.appendfile then
			appendfile = wrapWithFallback(originalIO.appendfile, false, true)
		end
		if originalIO.listfiles then
			listfiles = wrapWithFallback(originalIO.listfiles, false, false)
		end
		if originalIO.makefolder then
			makefolder = wrapWithFallback(originalIO.makefolder, false, true)
		end
		if originalIO.delfile then
			delfile = wrapWithFallback(originalIO.delfile, false, true)
		end
		if originalIO.delfolder then
			delfolder = wrapWithFallback(originalIO.delfolder, false, true)
		end
		if originalIO.isfile then
			isfile = wrapWithFallback(originalIO.isfile, true, true)
		end
		if originalIO.isfolder then
			isfolder = wrapWithFallback(originalIO.isfolder, true, true)
		end
	end
end

Waypoints = {}
Bindings = Bindings or {}
CommandKeybinds = CommandKeybinds or {}
CommandKeybindOptions = CommandKeybindOptions or {}
InstancesTbl = { click = {}; proxy = {}; touch = {}; }
InstancesTbl.wsAdd = InstancesTbl.wsAdd or {}
InstancesTbl.wsRem = InstancesTbl.wsRem or {}
NAmanage._wsHEnabledAdd = NAmanage._wsHEnabledAdd or {}
NAmanage._wsHEnabledRem = NAmanage._wsHEnabledRem or {}
NAmanage._wsHFilterAdd = NAmanage._wsHFilterAdd or {}
NAmanage._wsHFilterRem = NAmanage._wsHFilterRem or {}
NAmanage._wsHClassAdd = NAmanage._wsHClassAdd or {}
NAmanage._wsHClassRem = NAmanage._wsHClassRem or {}
NAmanage._wsHCounts = NAmanage._wsHCounts or { add = 0, rem = 0 }
do
	local cAdd, cRem = 0, 0
	for _, fn in InstancesTbl.wsAdd do
		if type(fn) == "function" then
			cAdd += 1
		end
	end
	for _, fn in InstancesTbl.wsRem do
		if type(fn) == "function" then
			cRem += 1
		end
	end
	NAmanage._wsHCounts.add = cAdd
	NAmanage._wsHCounts.rem = cRem
end

NAmanage._wsHEvalGate = function(gate)
	if gate == nil then
		return true
	end
	if type(gate) == "boolean" then
		return gate == true
	end
	if type(gate) == "function" then
		local ok, active = pcall(gate)
		return ok and active == true
	end
	return false
end

NAmanage._wsHIsActive = function(kind, key)
	const addKind = not (kind == "rem" or kind == "remove" or kind == "removing")
	const handler = addKind and InstancesTbl.wsAdd[key] or InstancesTbl.wsRem[key]
	if type(handler) ~= "function" then
		return false
	end
	const gates = addKind and NAmanage._wsHEnabledAdd or NAmanage._wsHEnabledRem
	return NAmanage._wsHEvalGate(gates and gates[key])
end

NAmanage._wsHPasses = function(kind, key, inst)
	if not NAmanage._wsHIsActive(kind, key) then
		return false
	end
	if inst == nil then
		return true
	end
	const addKind = not (kind == "rem" or kind == "remove" or kind == "removing")
	const classes = addKind and NAmanage._wsHClassAdd or NAmanage._wsHClassRem
	const classSet = classes and classes[key] or nil
	if classSet and not NAmanage._evtClassPass(classSet, inst) then
		return false
	end
	const filters = addKind and NAmanage._wsHFilterAdd or NAmanage._wsHFilterRem
	const filter = filters and filters[key] or nil
	if type(filter) == "function" then
		local ok, pass = pcall(filter, inst)
		if not (ok and pass == true) then
			return false
		end
	end
	return true
end

NAmanage.hasWsH = function(kind, inst)
	const counts = NAmanage._wsHCounts or { add = 0, rem = 0 }
	if kind == "rem" or kind == "remove" or kind == "removing" then
		if (tonumber(counts.rem) or 0) <= 0 then
			return false
		end
		for key, fn in InstancesTbl.wsRem or {} do
			if type(fn) == "function" and NAmanage._wsHPasses("rem", key, inst) then
				return true
			end
		end
		return false
	end
	if (tonumber(counts.add) or 0) <= 0 then
		return false
	end
	for key, fn in InstancesTbl.wsAdd or {} do
		if type(fn) == "function" and NAmanage._wsHPasses("add", key, inst) then
			return true
		end
	end
	return false
end

NAmanage.setWsH = function(key, spec)
	if type(key) ~= "string" or key == "" then
		return
	end
	spec = type(spec) == "table" and spec or {}
	const onAdded = type(spec.added) == "function" and spec.added or nil
	const onRemoving = type(spec.removing) == "function" and spec.removing or nil
	const addFilter = type(spec.filterAdded) == "function" and spec.filterAdded or (type(spec.filter) == "function" and spec.filter or nil)
	const remFilter = type(spec.filterRemoving) == "function" and spec.filterRemoving or (type(spec.filter) == "function" and spec.filter or nil)
	const addClass = NAmanage._evtClassSet(spec.classAdded or spec.classFilterAdded or spec.classNames or spec.classFilter)
	const remClass = NAmanage._evtClassSet(spec.classRemoving or spec.classFilterRemoving or spec.classNamesRemoving or spec.classNames or spec.classFilter)
	const gateShared = spec.enabled
	local gateAdd = spec.enabledAdded
	if gateAdd == nil then
		gateAdd = gateShared
	end
	local gateRem = spec.enabledRemoving
	if gateRem == nil then
		gateRem = gateShared
	end
	const counts = NAmanage._wsHCounts or { add = 0, rem = 0 }
	const prevAdded = InstancesTbl.wsAdd[key]
	const prevRemoving = InstancesTbl.wsRem[key]
	if type(prevAdded) == "function" and type(onAdded) ~= "function" then
		counts.add = math.max(0, (tonumber(counts.add) or 0) - 1)
	elseif type(prevAdded) ~= "function" and type(onAdded) == "function" then
		counts.add = (tonumber(counts.add) or 0) + 1
	end
	if type(prevRemoving) == "function" and type(onRemoving) ~= "function" then
		counts.rem = math.max(0, (tonumber(counts.rem) or 0) - 1)
	elseif type(prevRemoving) ~= "function" and type(onRemoving) == "function" then
		counts.rem = (tonumber(counts.rem) or 0) + 1
	end
	NAmanage._wsHCounts = counts
	InstancesTbl.wsAdd[key] = onAdded
	InstancesTbl.wsRem[key] = onRemoving
	if onAdded then
		NAmanage._wsHEnabledAdd[key] = gateAdd
		NAmanage._wsHFilterAdd[key] = addFilter
		NAmanage._wsHClassAdd[key] = addClass
	else
		NAmanage._wsHEnabledAdd[key] = nil
		NAmanage._wsHFilterAdd[key] = nil
		NAmanage._wsHClassAdd[key] = nil
	end
	if onRemoving then
		NAmanage._wsHEnabledRem[key] = gateRem
		NAmanage._wsHFilterRem[key] = remFilter
		NAmanage._wsHClassRem[key] = remClass
	else
		NAmanage._wsHEnabledRem[key] = nil
		NAmanage._wsHFilterRem[key] = nil
		NAmanage._wsHClassRem[key] = nil
	end
end

NAmanage.clrWsH = function(key)
	if type(key) ~= "string" or key == "" then
		return
	end
	const counts = NAmanage._wsHCounts or { add = 0, rem = 0 }
	if type(InstancesTbl.wsAdd[key]) == "function" then
		counts.add = math.max(0, (tonumber(counts.add) or 0) - 1)
	end
	if type(InstancesTbl.wsRem[key]) == "function" then
		counts.rem = math.max(0, (tonumber(counts.rem) or 0) - 1)
	end
	NAmanage._wsHCounts = counts
	InstancesTbl.wsAdd[key] = nil
	InstancesTbl.wsRem[key] = nil
	NAmanage._wsHEnabledAdd[key] = nil
	NAmanage._wsHEnabledRem[key] = nil
	NAmanage._wsHFilterAdd[key] = nil
	NAmanage._wsHFilterRem[key] = nil
	NAmanage._wsHClassAdd[key] = nil
	NAmanage._wsHClassRem[key] = nil
end

opt={
	prefix=NAStuff.prefixCheck;
	NAupdDate='unknown'; --month,day,year
	githubUrl = '';
	loader='';
	NAUILOADER='';
	NAAUTOSCALER=nil;
	cmdIntegrationUrl = "https://raw.githubusercontent.com/yeku/cmd/refs/heads/main/Source.luau";
	iyIntegrationUrl = "https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source";
	NAREQUEST = nil;
	queueteleport=(syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or function() end;
	hiddenprop=(sethiddenproperty or set_hidden_property or set_hidden_prop) or function() end;
	ctrlModule = nil;
	chatTranslateEnabled = true;
	chatTranslateTarget = "en";
	settingsTranslateTarget = "en";
	translateProvider = "mymemory";
	translateApiKey = "";
	translateUseDeepLFree = true;
	translateFallbackGoogle = false;
	translateLibreEndpoint = "";
	translateLibreApiKey = "";
	translateMyMemoryEmail = "";
	translateMyMemoryKey = "";
	--saveTag = false;
}

NAmanage.HttpDefaults = NAmanage.HttpDefaults or {
	maxAttempts = 5,
	timeout = 10,
	baseDelay = 0.65,
	maxDelay = 8,
}

NAmanage.HttpLowerHeaders = NAmanage.HttpLowerHeaders or function(headers)
	const out = {}
	if type(headers) == "table" then
		for key, value in headers do
			out[Lower(tostring(key))] = value
		end
	end
	return out
end

NAmanage.HttpResponseStatus = NAmanage.HttpResponseStatus or function(response)
	if type(response) ~= "table" then
		return nil
	end
	return tonumber(response.StatusCode or response.statusCode or response.Status or response.status or response.Code or response.code)
end

NAmanage.HttpResponseBody = NAmanage.HttpResponseBody or function(response)
	if type(response) == "string" then
		return response
	end
	if type(response) ~= "table" then
		return nil
	end
	const body = response.Body or response.body or response.Data or response.data or response.Text or response.text or response.Content or response.content or response.ResponseBody or response.responseBody or response.Response or response.response
	return type(body) == "string" and body or nil
end

NAmanage.HttpRetryAfter = NAmanage.HttpRetryAfter or function(response)
	if type(response) ~= "table" then
		return nil
	end
	const headers = NAmanage.HttpLowerHeaders(response.Headers or response.headers)
	const retryAfter = tonumber(headers["retry-after"])
		or tonumber(headers["x-ratelimit-reset-after"])
		or tonumber(headers["x-ratelimit-retryafter"])
		or tonumber(headers["x-rate-limit-retry-after"])
	if retryAfter then
		return retryAfter
	end
	const body = NAmanage.HttpResponseBody(response)
	if type(body) == "string" and body ~= "" and Services.HttpService then
		local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
		if ok and type(decoded) == "table" then
			return tonumber(decoded.retry_after or decoded.retryAfter)
		end
	end
	return nil
end

NAmanage.HttpShouldRetry = NAmanage.HttpShouldRetry or function(response, err)
	const status = NAmanage.HttpResponseStatus(response)
	if status == 408 or status == 425 or status == 429 or (status and status >= 500 and status < 600) then
		return true
	end
	const text = Lower(tostring(err or NAmanage.HttpResponseBody(response) or ""))
	return text:find("429", 1, true) ~= nil
		or text:find("too many requests", 1, true) ~= nil
		or text:find("rate limit", 1, true) ~= nil
		or text:find("timed out", 1, true) ~= nil
		or text:find("timeout", 1, true) ~= nil
		or text:find("temporarily unavailable", 1, true) ~= nil
end

NAmanage.HttpDelayForAttempt = NAmanage.HttpDelayForAttempt or function(attempt, response, opts)
	opts = type(opts) == "table" and opts or {}
	const retryAfter = NAmanage.HttpRetryAfter(response)
	if retryAfter then
		return math.clamp(retryAfter, 0.1, tonumber(opts.maxDelay) or NAmanage.HttpDefaults.maxDelay)
	end
	const baseDelay = tonumber(opts.baseDelay) or NAmanage.HttpDefaults.baseDelay
	const maxDelay = tonumber(opts.maxDelay) or NAmanage.HttpDefaults.maxDelay
	return math.clamp((baseDelay * (2 ^ math.max(attempt - 1, 0))) + (math.random() * 0.35), 0.1, maxDelay)
end

NAmanage.GetExecutorRequest = NAmanage.GetExecutorRequest or function()
	const host = (getgenv and getgenv()) or _G or {}
	const candidates = {
		type(request) == "function" and request or nil,
		type(http_request) == "function" and http_request or nil,
		type(httprequest) == "function" and httprequest or nil,
		type(syn) == "table" and type(syn.request) == "function" and syn.request or nil,
		type(http) == "table" and type(http.request) == "function" and http.request or nil,
		type(fluxus) == "table" and type(fluxus.request) == "function" and fluxus.request or nil,
		type(host) == "table" and type(rawget(host, "request")) == "function" and rawget(host, "request") or nil,
		type(host) == "table" and type(rawget(host, "http_request")) == "function" and rawget(host, "http_request") or nil,
		type(host) == "table" and type(rawget(host, "httprequest")) == "function" and rawget(host, "httprequest") or nil,
	}
	for _, fn in candidates do
		if type(fn) == "function" then
			return fn
		end
	end
	return nil
end

NAmanage.HttpCloneRequest = NAmanage.HttpCloneRequest or function(requestData)
	const out = {}
	if type(requestData) == "table" then
		for key, value in requestData do
			out[key] = value
		end
	end
	if out.Url == nil and out.url ~= nil then
		out.Url = out.url
	end
	if out.url == nil and out.Url ~= nil then
		out.url = out.Url
	end
	if out.Method == nil and out.method ~= nil then
		out.Method = out.method
	end
	if out.method == nil and out.Method ~= nil then
		out.method = out.Method
	end
	if out.Method == nil then
		out.Method = "GET"
		out.method = "GET"
	end
	if out.Headers == nil and out.headers ~= nil then
		out.Headers = out.headers
	end
	if out.headers == nil and out.Headers ~= nil then
		out.headers = out.Headers
	end
	if out.Timeout == nil and out.timeout ~= nil then
		out.Timeout = out.timeout
	end
	if out.timeout == nil and out.Timeout ~= nil then
		out.timeout = out.Timeout
	end
	out.Timeout = tonumber(out.Timeout) or tonumber(out.timeout) or NAmanage.HttpDefaults.timeout
	out.timeout = out.Timeout
	if out.FollowRedirects == nil then
		out.FollowRedirects = true
	end
	if out.SslVerify == nil then
		out.SslVerify = false
	end
	return out
end

NAmanage.HttpRequestRaw = NAmanage.HttpRequestRaw or function(requestData)
	local requestFn = opt and opt.NARAWREQUEST
	if type(requestFn) ~= "function" then
		requestFn = NAmanage.GetExecutorRequest()
		if opt then
			opt.NARAWREQUEST = requestFn
		end
	end
	if type(requestFn) == "function" then
		local ok, response = pcall(requestFn, requestData)
		if ok and response ~= nil then
			return true, response
		end
		return false, response
	end
	if Services.HttpService and type(Services.HttpService.RequestAsync) == "function" then
		const requestAsyncData = {}
		for key, value in requestData do
			if key ~= "url"
				and key ~= "method"
				and key ~= "headers"
				and key ~= "body"
				and key ~= "timeout"
				and key ~= "Timeout"
				and key ~= "FollowRedirects"
				and key ~= "SslVerify" then
				requestAsyncData[key] = value
			end
		end
		return pcall(Services.HttpService.RequestAsync, Services.HttpService, requestAsyncData)
	end
	return false, "HTTP request unavailable"
end

NAmanage.HttpRequest = NAmanage.HttpRequest or function(requestData, opts)
	opts = type(opts) == "table" and opts or {}
	if type(requestData) ~= "table" then
		return false, nil, "missing request data"
	end
	const data = NAmanage.HttpCloneRequest(requestData)
	if type(data.Url) ~= "string" or data.Url == "" then
		return false, nil, "missing url"
	end
	const maxAttempts = math.clamp(math.floor(tonumber(opts.maxAttempts or opts.retries) or NAmanage.HttpDefaults.maxAttempts), 1, 10)
	local lastResponse, lastErr
	for attempt = 1, maxAttempts do
		local ok, response = NAmanage.HttpRequestRaw(data)
		lastResponse = response
		if ok and response ~= nil then
			const status = NAmanage.HttpResponseStatus(response)
			if type(response) == "string" then
				return true, response
			end
			if status == nil or (status >= 200 and status < 300) or status == 304 then
				return true, response
			end
			lastErr = Format("HTTP %s", tostring(status))
			if not NAmanage.HttpShouldRetry(response, lastErr) then
				return false, response, lastErr
			end
		else
			lastErr = tostring(response or "request failed")
			if not NAmanage.HttpShouldRetry(nil, lastErr) then
				return false, response, lastErr
			end
		end
		if attempt < maxAttempts then
			Wait(NAmanage.HttpDelayForAttempt(attempt, lastResponse, opts))
		end
	end
	return false, lastResponse, lastErr or "request failed"
end

NAmanage.HttpGet = NAmanage.HttpGet or function(url, opts)
	opts = type(opts) == "table" and opts or {}
	if type(url) ~= "string" or url == "" then
		return false, nil, "missing url"
	end
	const headers = opts.Headers or opts.headers or {
		Accept = "*/*",
	}
	local okReq, response, requestErr = NAmanage.HttpRequest({
		Url = url,
		Method = "GET",
		Headers = headers,
		Timeout = opts.Timeout or opts.timeout or NAmanage.HttpDefaults.timeout,
		FollowRedirects = opts.FollowRedirects ~= false,
		SslVerify = opts.SslVerify == true,
	}, opts)
	if okReq then
		const body = NAmanage.HttpResponseBody(response)
		if type(body) == "string" and body ~= "" then
			return true, body, nil, response
		end
		if type(response) == "string" and response ~= "" then
			return true, response, nil, response
		end
	end

	const maxAttempts = math.clamp(math.floor(tonumber(opts.maxAttempts or opts.retries) or NAmanage.HttpDefaults.maxAttempts), 1, 10)
	local lastErr = requestErr
	for attempt = 1, maxAttempts do
		local okGet, body = pcall(function()
			if opts.noCache ~= nil then
				return game:HttpGet(url, opts.noCache)
			end
			return game:HttpGet(url)
		end)
		if okGet and type(body) == "string" and body ~= "" then
			return true, body, nil, body
		end
		lastErr = tostring(body or lastErr or "request failed")
		if not NAmanage.HttpShouldRetry(nil, lastErr) then
			break
		end
		if attempt < maxAttempts then
			Wait(NAmanage.HttpDelayForAttempt(attempt, nil, opts))
		end
	end
	return false, nil, lastErr or "request failed", response
end

NAmanage.HttpGetOrError = NAmanage.HttpGetOrError or function(url, opts)
	local ok, body, err = NAmanage.HttpGet(url, opts)
	if ok and type(body) == "string" then
		return body
	end
	error(tostring(err or "HTTP request failed"), 2)
end

NAmanage.HttpPost = NAmanage.HttpPost or function(url, body, opts)
	opts = type(opts) == "table" and opts or {}
	const headers = opts.Headers or opts.headers or {
		["Content-Type"] = opts.contentType or "application/json",
		["Accept"] = "*/*",
	}
	return NAmanage.HttpRequest({
		Url = url,
		Method = "POST",
		Headers = headers,
		Body = body,
		Timeout = opts.Timeout or opts.timeout or NAmanage.HttpDefaults.timeout,
		FollowRedirects = opts.FollowRedirects ~= false,
		SslVerify = opts.SslVerify == true,
	}, opts)
end

if opt then
	opt.NARAWREQUEST = NAmanage.GetExecutorRequest()
	opt.NAREQUEST = function(requestData)
		local ok, response, err = NAmanage.HttpRequest(requestData)
		if ok then
			return response
		end
		if response ~= nil then
			return response
		end
		return {
			StatusCode = 0,
			Status = 0,
			Body = tostring(err or "request failed"),
			Error = tostring(err or "request failed"),
		}
	end
end

cmd={}
NAmanage.btCount = 0

NAmanage.btGetExecutorInfo=function(forceRefresh)
	if forceRefresh or not NAmanage._btExecutorInfo then
		local execName = "Unknown"
		local execVersion = "Unknown"

		if type(identifyexecutor) == "function" then
			local ok, name, version = pcall(identifyexecutor)
			if ok then
				if type(name) == "string" and name ~= "" then
					execName = name
				elseif name ~= nil then
					execName = tostring(name)
				end

				if type(version) == "string" and version ~= "" then
					execVersion = version
				elseif version ~= nil then
					execVersion = tostring(version)
				end
			end
		end

		NAmanage._btExecutorInfo = {
			name = execName;
			version = execVersion;
		}
	end

	return NAmanage._btExecutorInfo
end

NAmanage.btEnabled=function()
	if type(NAmanage._btOverride) == "boolean" then
		return NAmanage._btOverride
	end
	if NAmanage.NASettingsGet then
		const value = NAmanage.NASettingsGet("bloxtrapRPC")
		if type(value) == "boolean" then
			return value
		end
	end
	if NAStuff and typeof(NAStuff.NASettingsData) == "table" then
		const stored = NAStuff.NASettingsData.bloxtrapRPC
		if type(stored) == "boolean" then
			return stored
		end
	end
	return false
end

NAmanage.btSetEnabled=function(value)
	NAmanage._btOverride = value == true
	if NAmanage.NASettingsSet then
		NAmanage.NASettingsSet("bloxtrapRPC", value == true)
	end
end

NAmanage.WebhookOptionDefaults = NAmanage.WebhookOptionDefaults or {
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
}

NAmanage.WebhookColorDefaults = NAmanage.WebhookColorDefaults or {
	join = "57F287";
	leave = "ED4245";
	chat = "5865F2";
	command = "FEE75C";
	main = "7C3AED";
	test = "EB459E";
}

NAmanage.WebhookTemplateDefaults = NAmanage.WebhookTemplateDefaults or {
	join = "**{player}** joined the server.";
	leave = "**{player}** left the server.";
	chat = "**{player}:** {message}";
	command = "**{player}** ran `{command}`";
}

NAmanage.NormalizeWebhookHex = NAmanage.NormalizeWebhookHex or function(value, fallback)
	local hex = tostring(value or ""):gsub("#", ""):gsub("[^%x]", ""):upper()
	if #hex == 3 then
		hex = hex:sub(1, 1)..hex:sub(1, 1)..hex:sub(2, 2)..hex:sub(2, 2)..hex:sub(3, 3)..hex:sub(3, 3)
	end
	if #hex ~= 6 or tonumber(hex, 16) == nil then
		return tostring(fallback or "7C3AED"):gsub("#", ""):upper()
	end
	return hex
end

NAmanage.NormalizeWebhookConfig = NAmanage.NormalizeWebhookConfig or function(cfg)
	cfg = type(cfg) == "table" and cfg or {}
	cfg.urls = type(cfg.urls) == "table" and cfg.urls or {}
	cfg.urls.main = type(cfg.urls.main) == "string" and cfg.urls.main or (type(cfg.url) == "string" and cfg.url or "")
	cfg.urls.all = type(cfg.urls.all) == "string" and cfg.urls.all or (type(cfg.url) == "string" and cfg.url or "")
	cfg.urls.joinleave = type(cfg.urls.joinleave) == "string" and cfg.urls.joinleave or ""
	cfg.urls.chat = type(cfg.urls.chat) == "string" and cfg.urls.chat or ""
	cfg.urls.commands = type(cfg.urls.commands) == "string" and cfg.urls.commands or ""
	cfg.url = cfg.urls.all
	cfg.useAll = cfg.useAll == true
	cfg.enableJoinLeave = cfg.enableJoinLeave == true
	cfg.enableChat = cfg.enableChat == true
	cfg.enableCommands = cfg.enableCommands == true
	cfg.minInterval = math.clamp(tonumber(cfg.minInterval) or 2, 0, 30)
	cfg.lastSent = tonumber(cfg.lastSent) or 0
	cfg.lastSentByKind = type(cfg.lastSentByKind) == "table" and cfg.lastSentByKind or {}
	cfg.mainMessage = type(cfg.mainMessage) == "string" and cfg.mainMessage or ""
	cfg.rawPayload = type(cfg.rawPayload) == "string" and cfg.rawPayload or [[{"content":"Hello from Nameless Admin"}]]

	cfg.options = type(cfg.options) == "table" and cfg.options or {}
	NAmanage.MergeMissing(cfg.options, NAmanage.WebhookOptionDefaults)
	cfg.options.enabled = cfg.options.enabled ~= false
	cfg.options.useEmbeds = cfg.options.useEmbeds ~= false
	cfg.options.includeTimestamp = cfg.options.includeTimestamp ~= false
	cfg.options.includeServerInfo = cfg.options.includeServerInfo ~= false
	cfg.options.blockMentions = cfg.options.blockMentions ~= false
	cfg.options.silent = cfg.options.silent == true
	cfg.options.tts = cfg.options.tts == true
	cfg.options.separateCooldowns = cfg.options.separateCooldowns ~= false
	for _, key in { "username", "avatarUrl", "titlePrefix", "footerText", "thumbnailUrl", "imageUrl" } do
		cfg.options[key] = type(cfg.options[key]) == "string" and cfg.options[key] or tostring(cfg.options[key] or "")
	end
	cfg.options.username = cfg.options.username:sub(1, 80)
	cfg.options.titlePrefix = cfg.options.titlePrefix:sub(1, 120)
	cfg.options.footerText = cfg.options.footerText:sub(1, 2048)
	cfg.options.colors = type(cfg.options.colors) == "table" and cfg.options.colors or {}
	for key, fallback in NAmanage.WebhookColorDefaults do
		cfg.options.colors[key] = NAmanage.NormalizeWebhookHex(cfg.options.colors[key], fallback)
	end

	cfg.templates = type(cfg.templates) == "table" and cfg.templates or {}
	NAmanage.MergeMissing(cfg.templates, NAmanage.WebhookTemplateDefaults)
	for key, fallback in NAmanage.WebhookTemplateDefaults do
		if type(cfg.templates[key]) ~= "string" or cfg.templates[key] == "" then
			cfg.templates[key] = fallback
		end
		cfg.templates[key] = cfg.templates[key]:sub(1, 1900)
	end

	cfg.stats = type(cfg.stats) == "table" and cfg.stats or {}
	cfg.stats.sent = math.max(0, math.floor(tonumber(cfg.stats.sent) or 0))
	cfg.stats.failed = math.max(0, math.floor(tonumber(cfg.stats.failed) or 0))
	cfg.stats.lastStatus = tonumber(cfg.stats.lastStatus)
	cfg.stats.lastError = type(cfg.stats.lastError) == "string" and cfg.stats.lastError or ""
	cfg.stats.lastSentAt = tonumber(cfg.stats.lastSentAt) or 0
	return cfg
end

NAmanage.ApplySavedWebhookTables = NAmanage.ApplySavedWebhookTables or function(cfg, savedOptions, savedTemplates)
	cfg = NAmanage.NormalizeWebhookConfig(cfg)
	if type(savedOptions) == "table" then
		for key, value in savedOptions do
			if key == "colors" and type(value) == "table" then
				for colorKey, colorValue in value do
					cfg.options.colors[colorKey] = colorValue
				end
			else
				cfg.options[key] = value
			end
		end
	end
	if type(savedTemplates) == "table" then
		for key, value in savedTemplates do
			cfg.templates[key] = value
		end
	end
	return NAmanage.NormalizeWebhookConfig(cfg)
end

NAmanage.InitializeIntegration=function()
	const integ = NAStuff.Integrations or {}
	integ.webhook = integ.webhook or {}
	integ.webhook.urls = integ.webhook.urls or {}
	integ.webhook.urls.main = integ.webhook.urls.main or integ.webhook.url or integ.webhook.urls.all or ""
	integ.webhook.urls.all = integ.webhook.urls.all or integ.webhook.url or ""
	integ.webhook.urls.joinleave = integ.webhook.urls.joinleave or ""
	integ.webhook.urls.chat = integ.webhook.urls.chat or ""
	integ.webhook.urls.commands = integ.webhook.urls.commands or ""
	integ.webhook.useAll = integ.webhook.useAll == true
	integ.webhook.url = integ.webhook.urls.all
	integ.webhook.enableJoinLeave = integ.webhook.enableJoinLeave == true
	integ.webhook.enableChat = integ.webhook.enableChat == true
	integ.webhook.enableCommands = integ.webhook.enableCommands == true
	integ.webhook.minInterval = tonumber(integ.webhook.minInterval) or 2
	integ.webhook.lastSent = type(integ.webhook.lastSent) == "number" and integ.webhook.lastSent or 0
	integ.webhook = NAmanage.NormalizeWebhookConfig(integ.webhook)
	integ.health = integ.health or { endpoints = {} }
	integ.health.endpoints = integ.health.endpoints or {}
	integ.notes = integ.notes or { last = "" }
	integ.notes.last = integ.notes.last or ""
	integ.rpc = integ.rpc or {}
	integ.rpc.useCustom = integ.rpc.useCustom == true
	integ.rpc.details = integ.rpc.details or ""
	integ.rpc.state = integ.rpc.state or ""

	if NAmanage.NASettingsGet then
		const clampNum = NAmanage.clampNumber or function(v, lo, hi, fallback)
			local n = tonumber(v)
			if not n then return fallback end
			if lo and n < lo then n = lo end
			if hi and n > hi then n = hi end
			return n
		end
		const function asBool(v) return v == true end
		const function asString(v) return type(v) == "string" and v or "" end

		const function readUrl(key, fallback)
			const value = asString(NAmanage.NASettingsGet(key))
			if value ~= "" then
				return value
			end
			return fallback
		end

		integ.webhook.urls.main = readUrl("integrationWebhookUrlMain", integ.webhook.urls.main)
		integ.webhook.urls.all = readUrl("integrationWebhookUrlAll", integ.webhook.urls.all)
		integ.webhook.urls.joinleave = readUrl("integrationWebhookUrlJoinLeave", integ.webhook.urls.joinleave)
		integ.webhook.urls.chat = readUrl("integrationWebhookUrlChat", integ.webhook.urls.chat)
		integ.webhook.urls.commands = readUrl("integrationWebhookUrlCommands", integ.webhook.urls.commands)
		if integ.webhook.urls.all == "" then
			const legacy = asString(NAmanage.NASettingsGet("integrationWebhookUrl"))
			if legacy ~= "" then
				integ.webhook.urls.all = legacy
			end
		end
		integ.webhook.url = integ.webhook.urls.all

		const useAllSaved = NAmanage.NASettingsGet("integrationWebhookUseAll")
		if type(useAllSaved) == "boolean" then
			integ.webhook.useAll = useAllSaved
		end

		integ.webhook.enableJoinLeave = NAmanage.NASettingsGet("integrationWebhookJoinLeave") == true or integ.webhook.enableJoinLeave
		integ.webhook.enableChat = NAmanage.NASettingsGet("integrationWebhookChat") == true or integ.webhook.enableChat
		integ.webhook.enableCommands = NAmanage.NASettingsGet("integrationWebhookCommands") == true or integ.webhook.enableCommands
		integ.webhook.minInterval = clampNum(NAmanage.NASettingsGet("integrationWebhookInterval"), 0, 30, integ.webhook.minInterval)
		integ.webhook = NAmanage.ApplySavedWebhookTables(
			integ.webhook,
			NAmanage.NASettingsGet("integrationWebhookOptions"),
			NAmanage.NASettingsGet("integrationWebhookTemplates")
		)
		const mainDraft = NAmanage.NASettingsGet("integrationWebhookDraft")
		const rawDraft = NAmanage.NASettingsGet("integrationWebhookRawDraft")
		if type(mainDraft) == "string" then integ.webhook.mainMessage = mainDraft end
		if type(rawDraft) == "string" and rawDraft ~= "" then integ.webhook.rawPayload = rawDraft end

		const storedEndpoints = NAmanage.NASettingsGet("integrationHealthEndpoints")
		if type(storedEndpoints) == "table" then
			integ.health.endpoints = {}
			for i = 1, math.min(#storedEndpoints, 3) do
				if type(storedEndpoints[i]) == "string" and storedEndpoints[i] ~= "" then
					integ.health.endpoints[i] = storedEndpoints[i]
				end
			end
		elseif type(storedEndpoints) == "string" and storedEndpoints ~= "" then
			integ.health.endpoints = { storedEndpoints }
		end

		const noteVal = NAmanage.NASettingsGet("integrationNotesLast")
		if type(noteVal) == "string" then
			integ.notes.last = noteVal
		end

		integ.rpc.useCustom = NAmanage.NASettingsGet("integrationRpcUseCustom") == true or integ.rpc.useCustom
		const rpcDetails = NAmanage.NASettingsGet("integrationRpcDetails")
		const rpcState = NAmanage.NASettingsGet("integrationRpcState")
		if type(rpcDetails) == "string" then integ.rpc.details = rpcDetails end
		if type(rpcState) == "string" then integ.rpc.state = rpcState end
	end

	integ.webhook = NAmanage.NormalizeWebhookConfig(integ.webhook)
	NAStuff.Integrations = integ
end
NAmanage.InitializeIntegration()

NAmanage.btSend=function(command, data)
	if not NAmanage.btEnabled() then
		return
	end

	const payload = {
		command = command;
		data = data;
	}

	local ok, encoded = pcall(function()
		return Services.HttpService:JSONEncode(payload)
	end)

	if ok and encoded then
		encoded = encoded:gsub('("assetId"%s*:%s*)([-%d%.eE%+]+)', function(prefix, numeric)
			const numberValue = tonumber(numeric)
			if numberValue then
				return prefix..Format('%.0f', numberValue)
			end
			return prefix..numeric
		end)
		print("[BloxstrapRPC] "..encoded)
	end
end

NAmanage.btUpdate=function(details, state)
	if not NAmanage.btEnabled() then
		return
	end

	const versionHover = (NAStuff and NAStuff.NAjson and NAStuff.NAjson.ver) or "Nameless Admin"
	const count = NAmanage.btCount or 0
	const cfgRPC = (NAStuff.Integrations and NAStuff.Integrations.rpc) or {}
	const placeLabel = placeName and placeName() or "Game"
	const function applyTemplate(text, fallback)
		local src = (text ~= nil and text ~= "") and text or fallback
		if type(src) ~= "string" then
			src = tostring(src)
		end
		return (src or ""):gsub("{cmds}", tostring(count))
			:gsub("{game}", tostring(placeLabel))
	end

	local displayDetails = details or adminName or "Nameless Admin"
	if cfgRPC.useCustom and cfgRPC.details and cfgRPC.details ~= "" then
		displayDetails = applyTemplate(cfgRPC.details, displayDetails)
	end
	if type(displayDetails) ~= "string" then
		displayDetails = tostring(displayDetails)
	end
	local baseState = state

	if baseState == nil then
		if count > 0 then
			baseState = "cmds ran: "..tostring(count)
		else
			baseState = "Idle"
		end
	end
	if cfgRPC.useCustom and cfgRPC.state and cfgRPC.state ~= "" then
		baseState = applyTemplate(cfgRPC.state, baseState)
	end
	if type(baseState) ~= "string" then
		baseState = tostring(baseState)
	end

	const execInfo = NAmanage.btGetExecutorInfo()
	local execNameLabel = execInfo and execInfo.name or "Unknown"
	if execNameLabel == "" then
		execNameLabel = "Unknown"
	end
	execNameLabel = tostring(execNameLabel)
	const execLabel = execNameLabel

	const displayState = Format("%s | Executor: %s", baseState, execLabel)

	const largeAsset = 86994583496114
	local smallAsset = placeIconAssetId and placeIconAssetId() or nil
	if smallAsset == 0 then
		smallAsset = nil
	end
	local smallHover = placeName and placeName() or nil
	if not smallAsset then
		smallAsset = 13409122839
		if not smallHover or smallHover == "" or smallHover == "unknown" then
			smallHover = "v1.0"
		end
	end

	NAmanage.btSend("SetRichPresence", {
		details = displayDetails;
		state = displayState;
		largeImage = {
			assetId = largeAsset;
			hoverText = tostring(versionHover);
		};
		smallImage = smallAsset and {
			assetId = smallAsset;
			hoverText = tostring(smallHover or "Game");
		} or nil;
	})
end

NAmanage.btBump=function()
	NAmanage.btCount = (NAmanage.btCount or 0) + 1
	NAmanage.btUpdate()
end

Defer(function()
	NAmanage.btUpdate()
end)

NAmanage.CmdIntegrationModes = NAmanage.CmdIntegrationModes or { "NA First", "Cmd First", "Explicit Only" }

NAmanage.CmdIntegrationNormalizeMode = function(value)
	value = tostring(value or "NA First")
	for _, mode in NAmanage.CmdIntegrationModes do
		if Lower(mode) == Lower(value) then
			return mode
		end
	end
	return "NA First"
end

NAmanage.CmdIntegrationGetMethod = function(bridge, names)
	if type(bridge) ~= "table" then
		return nil
	end
	for _, name in names do
		const callback = bridge[name]
		if type(callback) == "function" then
			return callback
		end
	end
	return nil
end

NAmanage.CmdIntegrationFindExistingBridge = function()
	for _, target in { _na_env, _na_shared, _na_boot.runtimeEnv, _na_boot.hostEnv } do
		if type(target) == "table" then
			const bridge = rawget(target, "CmdIntegration") or rawget(target, "CmdBridge") or rawget(target, "CmdIntegrationBridge")
			if type(bridge) == "table" then
				return bridge
			end
		end
	end
	return nil
end

NAmanage.CmdIntegrationDisconnectSubscriptions = function()
	const subscriptions = NAStuff.CmdIntegrationSubscriptions
	if type(subscriptions) == "table" then
		for key, subscription in subscriptions do
			if type(subscription) == "function" then
				pcall(subscription)
			elseif type(subscription) == "table" and type(subscription.Disconnect) == "function" then
				pcall(subscription.Disconnect, subscription)
			elseif typeof(subscription) == "RBXScriptConnection" then
				pcall(function()
					subscription:Disconnect()
				end)
			end
			subscriptions[key] = nil
		end
	end
	NAStuff.CmdIntegrationSubscriptions = {}
end

NAmanage.CmdIntegrationRefresh = function(opts)
	opts = opts or {}
	const bridge = opts.bridge or NAStuff.CmdIntegrationBridge
	if type(bridge) ~= "table" then
		NAStuff.CmdIntegrationCommands = nil
		NAStuff.CmdIntegrationCommandSet = nil
		if type(NAmanage.invalidateCommandBuild) == "function" then
			NAmanage.invalidateCommandBuild()
		end
		return false, "bridge-unavailable"
	end

	const listMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "ListCommands", "listCommands", "list" })
	if type(listMethod) ~= "function" then
		return false, "command-list-unavailable"
	end

	local okList, rawList = pcall(listMethod)
	if not okList or type(rawList) ~= "table" then
		return false, tostring(rawList or "command-list-failed")
	end

	const normalized = {}
	const commandSet = {}
	for _, info in rawList do
		if type(info) == "table" then
			const name = tostring(info.name or info.Name or info.command or info.Command or "")
			if name ~= "" then
				const aliases = {}
				const seen = {}
				const rawAliases = info.aliases or info.Aliases or {}
				if type(rawAliases) == "table" then
					for _, alias in rawAliases do
						const value = tostring(alias or "")
						const lowerValue = Lower(value)
						if value ~= "" and not seen[lowerValue] then
							seen[lowerValue] = true
							Insert(aliases, value)
							commandSet[lowerValue] = name
						end
					end
				end
				commandSet[Lower(name)] = name
				const arguments = {}
				const rawArguments = info.arguments or info.Arguments or {}
				if type(rawArguments) == "table" then
					for _, argument in rawArguments do
						if type(argument) == "table" then
							Insert(arguments, {
								name = tostring(argument.name or argument.Name or "");
								type = tostring(argument.type or argument.Type or "String");
							})
						end
					end
				end
				Insert(normalized, {
					name = name;
					aliases = aliases;
					desc = tostring(info.desc or info.description or info.Description or "");
					arguments = arguments;
					plugin = info.plugin == true or info.Plugin == true;
				})
			end
		end
	end

	table.sort(normalized, function(a, b)
		return Lower(a.name) < Lower(b.name)
	end)
	NAStuff.CmdIntegrationCommands = normalized
	NAStuff.CmdIntegrationCommandSet = commandSet
	if type(NAmanage.invalidateCommandBuild) == "function" then
		NAmanage.invalidateCommandBuild()
	end
	if opts.refreshUI ~= false and NAgui and type(NAgui.loadCMDS) == "function" then
		pcall(NAgui.loadCMDS)
	end
	return true, normalized
end

NAmanage.CmdIntegrationHasCommand = function(name)
	name = Lower(tostring(name or ""))
	if name == "" then
		return false
	end
	const bridge = NAStuff.CmdIntegrationBridge
	const hasMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "HasCommand", "hasCommand" })
	if type(hasMethod) == "function" then
		local ok, result = pcall(hasMethod, name)
		if ok then
			return result == true
		end
	end
	const findMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "FindCommand", "findCommand", "find" })
	if type(findMethod) == "function" then
		local ok, result = pcall(findMethod, name)
		if ok then
			return result ~= nil and result ~= false
		end
	end
	const commandSet = NAStuff.CmdIntegrationCommandSet
	return type(commandSet) == "table" and commandSet[name] ~= nil
end

NAmanage.CmdIntegrationBuildHost = function()
	const host = {
		name = "Nameless Admin";
		protocol = 2;
		version = tostring(adminName or "NA");
	}

	host.list = function()
		const out = {}
		if type(cmds) ~= "table" or type(cmds.Commands) ~= "table" then
			return out
		end
		const aliasesByData = {}
		if type(cmds.Aliases) == "table" then
			for alias, data in cmds.Aliases do
				aliasesByData[data] = aliasesByData[data] or {}
				Insert(aliasesByData[data], tostring(alias))
			end
		end
		for name, data in cmds.Commands do
			const info = type(data[2]) == "table" and data[2] or {}
			const aliases = aliasesByData[data] or {}
			table.sort(aliases)
			Insert(out, {
				name = tostring(name);
				aliases = aliases;
				desc = tostring(info[2] or info[1] or "");
				requiresArguments = data[3] == true;
				meta = type(data[4]) == "table" and data[4] or {};
			})
		end
		table.sort(out, function(a, b)
			return Lower(a.name) < Lower(b.name)
		end)
		return out
	end

	host.find = function(name)
		const lowerName = Lower(tostring(name or ""))
		const data = type(cmds) == "table" and ((cmds.Commands and cmds.Commands[lowerName]) or (cmds.Aliases and cmds.Aliases[lowerName])) or nil
		if not data then
			return nil
		end
		return {
			name = type(NAmanage.resolveCommandName) == "function" and NAmanage.resolveCommandName(lowerName) or lowerName;
			requiresArguments = data[3] == true;
			meta = type(data[4]) == "table" and data[4] or {};
		}
	end

	host.run = function(input)
		const args = {}
		if type(input) == "table" then
			for _, value in input do
				Insert(args, tostring(value or ""))
			end
		else
			local line = tostring(input or "")
			const prefix = tostring(NAStuff.prefixCheck or prefixCheck or ";")
			if prefix ~= "" and Sub(line, 1, #prefix) == prefix then
				line = Sub(line, #prefix + 1)
			end
			if type(ParseArguments) == "function" then
				local okParse, parsed = pcall(ParseArguments, line)
				if okParse and type(parsed) == "table" then
					for _, value in parsed do
						Insert(args, tostring(value or ""))
					end
				end
			end
			if #args == 0 then
				for value in line:gmatch("%S+") do
					Insert(args, value)
				end
			end
		end
		if #args == 0 or type(cmd) ~= "table" or type(cmd.run) ~= "function" then
			return false, "invalid-command"
		end
		const runArgs = {}
		for i, value in args do
			runArgs[i] = value
		end
		local okRun, result = pcall(cmd.run, runArgs)
		if not okRun then
			return false, tostring(result)
		end
		return true, result
	end

	host.parse = host.run
	host.notify = function(title, description, duration)
		if type(title) == "table" then
			const config = title
			title = config.Title or config.title or "Cmd"
			description = config.Description or config.description or ""
			duration = config.Duration or config.duration
		end
		if type(DoNotif) == "function" then
			DoNotif(tostring(title or "Cmd")..(description and description ~= "" and (": "..tostring(description)) or ""), tonumber(duration) or 3)
			return true
		end
		return false
	end
	host.getUI = function()
		if type(NAmanage.getUI) == "function" then
			return NAmanage.getUI()
		end
		return NAStuff.NASCREENGUI
	end
	host.getState = function()
		return {
			name = tostring(adminName or "Nameless Admin");
			testing = _na_env and _na_env.NATestingVer == true or false;
			prefix = tostring(NAStuff.prefixCheck or prefixCheck or ";");
			commandCount = type(cmds) == "table" and type(cmds.Commands) == "table" and (function()
				local count = 0
				for _ in cmds.Commands do
					count += 1
				end
				return count
			end)() or 0;
		}
	end
	return host
end

NAmanage.CmdIntegrationRemoveGateway = function(bridge)
	bridge = bridge or NAStuff.CmdIntegrationBridge
	const gateway = NAStuff.CmdIntegrationGatewayName
	if not gateway then
		return false
	end
	const removeMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "RemoveCommand", "removeCommand" })
	if type(removeMethod) == "function" then
		pcall(removeMethod, gateway)
	end
	NAStuff.CmdIntegrationGatewayName = nil
	return true
end

NAmanage.CmdIntegrationInstallGateway = function(bridge, host)
	bridge = bridge or NAStuff.CmdIntegrationBridge
	host = host or NAStuff.CmdIntegrationHost
	NAmanage.CmdIntegrationRemoveGateway(bridge)
	if NAStuff.CmdIntegrationExposeGateway == false or type(host) ~= "table" then
		return false, "gateway-disabled"
	end
	const addMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "AddCommand", "addCommand" })
	if type(addMethod) ~= "function" then
		return false, "dynamic-commands-unavailable"
	end
	const gateway = NAmanage.CmdIntegrationHasCommand("na") and "namelessadmin" or "na"
	const aliases = gateway == "na" and { "na", "namelessadmin" } or { "namelessadmin", "naadmin" }
	const info = {
		Aliases = aliases;
		Description = "Run a Nameless Admin command through Cmd";
		Arguments = {
			{ Name = "command"; Type = "String"; };
		};
		Plugin = true;
		Task = function(...)
			const parts = {}
			for i = 1, select("#", ...) do
				Insert(parts, tostring(select(i, ...) or ""))
			end
			const line = Concat(parts, " ")
			local ok, result = host.run(line)
			if ok then
				return "Nameless Admin", line ~= "" and ("Ran "..line) or "Command completed"
			end
			return "Nameless Admin", "Failed: "..tostring(result or "unknown error")
		end;
	}
	local okAdd, result, primary = pcall(addMethod, info)
	if not okAdd or result == false then
		return false, tostring(primary or result or "gateway-add-failed")
	end
	NAStuff.CmdIntegrationGatewayName = tostring(primary or gateway)
	return true, NAStuff.CmdIntegrationGatewayName
end

NAmanage.CmdIntegrationAttach = function(bridge)
	if type(bridge) ~= "table" then
		return false, "bridge-unavailable"
	end
	NAmanage.CmdIntegrationDisconnectSubscriptions()
	const host = NAmanage.CmdIntegrationBuildHost()
	NAStuff.CmdIntegrationHost = host
	const attachMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "AttachHost", "attachHost" })
	if type(attachMethod) == "function" then
		pcall(attachMethod, "nameless-admin", host)
	end
	NAmanage.CmdIntegrationInstallGateway(bridge, host)
	const subscribeMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "Subscribe", "subscribe", "on" })
	if type(subscribeMethod) == "function" then
		NAStuff.CmdIntegrationSubscriptions = NAStuff.CmdIntegrationSubscriptions or {}
		local okCommands, commandSubscription = pcall(subscribeMethod, "commandsChanged", function()
			const token = {}
			NAStuff.CmdIntegrationRefreshToken = token
			Delay(0.1, function()
				if NAStuff.CmdIntegrationRefreshToken == token then
					NAmanage.CmdIntegrationRefresh({ refreshUI = true })
				end
			end)
		end)
		if okCommands and commandSubscription then
			NAStuff.CmdIntegrationSubscriptions.commands = commandSubscription
		end
		local okNotifications, notificationSubscription = pcall(subscribeMethod, "notification", function(config)
			if NAStuff.CmdIntegrationMirrorNotifications ~= true or type(DoNotif) ~= "function" then
				return
			end
			config = type(config) == "table" and config or {}
			const title = tostring(config.Title or config.title or "Cmd")
			const description = tostring(config.Description or config.description or "")
			DoNotif(title..(description ~= "" and (": "..description) or ""), tonumber(config.Duration or config.duration) or 3)
		end)
		if okNotifications and notificationSubscription then
			NAStuff.CmdIntegrationSubscriptions.notifications = notificationSubscription
		end
	end
	NAmanage.CmdIntegrationRefresh({ bridge = bridge; refreshUI = true; })
	if type(NAmanage.RegisterUnloadCleanup) == "function" then
		NAmanage.RegisterUnloadCleanup("CmdIntegration", function()
			NAmanage.disconnectCmdIntegration({ silent = true })
		end, 80)
	end
	return true
end

NAmanage.CmdIntegrationApplyBridge = function(bridge, sourceLabel, opts)
	opts = opts or {}
	if type(bridge) ~= "table" then
		return false, "invalid-bridge"
	end
	const listMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "ListCommands", "listCommands", "list" })
	const parseMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "Parse", "parse" })
	const runMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "RunCommand", "runCommand" })
	if type(listMethod) ~= "function" or (type(parseMethod) ~= "function" and type(runMethod) ~= "function") then
		return false, "unsupported-bridge"
	end
	NAStuff.CmdIntegrationBridge = bridge
	NAStuff.CmdIntegrationLoaded = true
	NAStuff.CmdIntegrationLastSource = sourceLabel or "Cmd"
	NAStuff.CmdIntegrationProtocol = tonumber(bridge.Protocol or bridge.protocol) or 1
	const stateMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "GetState", "getState" })
	if type(stateMethod) == "function" then
		local okState, state = pcall(stateMethod)
		if okState and type(state) == "table" then
			NAStuff.CmdIntegrationState = state
			NAStuff.CmdIntegrationPrefix = tostring(state.prefix or bridge.prefix or ";")
			NAStuff.CmdIntegrationSeparator = tostring(state.separator or bridge.separator or ",")
		end
	end
	if not NAStuff.CmdIntegrationPrefix then
		NAStuff.CmdIntegrationPrefix = tostring(bridge.prefix or ";")
	end
	if not NAStuff.CmdIntegrationSeparator then
		NAStuff.CmdIntegrationSeparator = tostring(bridge.separator or ",")
	end
	local okRefresh, refreshResult = NAmanage.CmdIntegrationRefresh({ bridge = bridge; refreshUI = opts.refreshUI ~= false; })
	if not okRefresh then
		NAStuff.CmdIntegrationLoaded = false
		NAStuff.CmdIntegrationBridge = nil
		return false, refreshResult
	end
	NAmanage.CmdIntegrationAttach(bridge)
	return true, sourceLabel
end

NAmanage.disconnectCmdIntegration = function(opts)
	opts = opts or {}
	const bridge = NAStuff.CmdIntegrationBridge
	NAmanage.CmdIntegrationDisconnectSubscriptions()
	NAmanage.CmdIntegrationRemoveGateway(bridge)
	const detachMethod = NAmanage.CmdIntegrationGetMethod(bridge, { "DetachHost", "detachHost" })
	if type(detachMethod) == "function" then
		pcall(detachMethod, "nameless-admin")
	end
	NAStuff.CmdIntegrationBridge = nil
	NAStuff.CmdIntegrationHost = nil
	NAStuff.CmdIntegrationLoaded = false
	NAStuff.CmdIntegrationLastSource = nil
	NAStuff.CmdIntegrationProtocol = nil
	NAStuff.CmdIntegrationCommands = nil
	NAStuff.CmdIntegrationCommandSet = nil
	NAStuff.CmdIntegrationState = nil
	NAStuff.CmdIntegrationGatewayName = nil
	if type(NAmanage.invalidateCommandBuild) == "function" then
		NAmanage.invalidateCommandBuild()
	end
	if NAgui and type(NAgui.loadCMDS) == "function" then
		pcall(NAgui.loadCMDS)
	end
	if not opts.silent and type(DoNotif) == "function" then
		DoNotif("Cmd integration disconnected", 3)
	end
	return true
end

NAmanage.loadCmdIntegration=function(opts)
	opts = opts or {}

	const function fetchFile(path)
		if not (FileSupport and type(isfile) == "function" and isfile(path)) then
			return nil, nil, "file not found"
		end
		local ok, raw = pcall(readfile, path)
		if ok and type(raw) == "string" and raw ~= "" then
			return raw, "file:"..path
		end
		return nil, nil, Format("unable to read %s", tostring(path))
	end

	const function fetchUrl(url)
		if type(url) ~= "string" or url == "" then
			return nil, nil, "invalid url"
		end
		const request = opt and opt.NAREQUEST
		if type(request) == "function" then
			local ok, response = pcall(request, {
				Url = url;
				Method = "GET";
				Timeout = 10;
				FollowRedirects = true;
				SslVerify = false;
			})
			if ok and response then
				const body = response.Body or response.body or response.Data or response.data or response.Text or response.text or response.Content or response.content or response[1]
				if type(body) == "string" and body ~= "" then
					return body, url
				end
			end
		end
		local ok, body = NAmanage.HttpGet(url, { timeout = 10 })
		if ok and type(body) == "string" and body ~= "" then
			return body, url
		end
		return nil, nil, "request failed"
	end

	if NAStuff.CmdIntegrationLoading then
		return false, "Cmd is already loading"
	end
	if NAStuff.CmdIntegrationLoaded and type(NAStuff.CmdIntegrationBridge) == "table" then
		NAmanage.CmdIntegrationRefresh({ refreshUI = true })
		if not opts.silent and type(DebugNotif) == "function" then
			DebugNotif("Cmd integration refreshed.", 2)
		end
		return true, NAStuff.CmdIntegrationLastSource
	end

	const existing = NAmanage.CmdIntegrationFindExistingBridge()
	if type(existing) == "table" then
		local okExisting, existingResult = NAmanage.CmdIntegrationApplyBridge(existing, "existing-bridge", opts)
		if okExisting then
			return true, existingResult
		end
	end

	const sources = {}
	const function pushFile(path)
		if FileSupport and type(isfile) == "function" and path and path ~= "" and isfile(path) then
			Insert(sources, { kind = "file", value = path })
		end
	end
	pushFile(opts.path)
	pushFile("cmd/main.luau")
	pushFile("Cmd/main.luau")
	pushFile("cmd/main.lua")
	pushFile("Cmd/main.lua")
	const function pushUrl(url)
		if url and url ~= "" then
			Insert(sources, { kind = "url", value = url })
		end
	end
	pushUrl(opts.url)
	pushUrl(opt.cmdIntegrationUrl)

	local raw, sourceLabel
	local lastError
	for _, src in sources do
		if src.kind == "file" then
			raw, sourceLabel, lastError = fetchFile(src.value)
		else
			raw, sourceLabel, lastError = fetchUrl(src.value)
		end
		if raw and raw ~= "" then
			break
		end
	end
	if not raw or raw == "" then
		return false, lastError or "unable to fetch Cmd script"
	end

	const bridgeSuffix = [=[
;local _g=(getgenv and getgenv()) or _G
;local _native=_g and (_g.CmdIntegration or _g.CmdBridge or _g.CmdIntegrationBridge)
;if type(_native)=="table" and (type(_native.ListCommands)=="function" or type(_native.list)=="function") then return _native end
;local _listeners={}
;local _hosts={}
;local _nextListener=0
;local function _emit(event,...)
	local packed=table.pack(...)
	for _,bucket in {_listeners[event],_listeners["*"]} do
		if type(bucket)=="table" then
			for _,callback in bucket do
				task.spawn(function() pcall(callback,table.unpack(packed,1,packed.n)) end)
			end
		end
	end
end
;local function _cmdList()
	local out={}
	if type(Commands)=="table" then
		for n,d in Commands do
			local aliases={}
			local arguments={}
			if type(d)=="table" and type(d[1])=="table" then
				for _,a in d[1] do aliases[#aliases+1]=tostring(a) end
			end
			if type(d)=="table" and type(d[3])=="table" then
				for _,a in d[3] do
					if type(a)=="table" then arguments[#arguments+1]={name=tostring(a.Name or a.name or ""),type=tostring(a.Type or a.type or "String")} end
				end
			end
			local desc=""
			if type(d)=="table" then desc=tostring(d[2] or "") end
			out[#out+1]={name=tostring(n),aliases=aliases,desc=desc,arguments=arguments,plugin=type(d)=="table" and d[4]==true}
		end
	end
	table.sort(out,function(a,b) return string.lower(a.name)<string.lower(b.name) end)
	return out
end
;local function _find(name)
	name=string.lower(tostring(name or ""))
	if type(Command)=="table" and type(Command.Find)=="function" then return Command.Find(name) end
	if type(Commands)=="table" then
		for _,entry in Commands do
			if type(entry)=="table" and type(entry[1])=="table" then
				for _,alias in entry[1] do if string.lower(tostring(alias))==name then return entry end end
			end
		end
	end
end
;local _b={Name="Cmd",Version=Settings and Settings.Version or "unknown",Protocol=1,protocol=1,Capabilities={Commands=true,DynamicCommands=type(Command)=="table" and type(Command.Add)=="function",Events=true,Hosts=true,Notifications=type(API)=="table",Settings=type(Settings)=="table",UI=typeof(UI)=="Instance"}}
;_b.ListCommands=_cmdList
;_b.list=_cmdList
;_b.FindCommand=function(name) return _find(name) end
;_b.HasCommand=function(name) return _find(name)~=nil end
;_b.RunCommand=function(name,args,options)
	if not _find(name) then return false,"command-not-found" end
	if type(Command)=="table" and type(Command.Run)=="function" then Command.Run(type(options)=="table" and options.ignoreNotifications==true,string.lower(tostring(name)),type(args)=="table" and args or {}) return true end
	return false,"runner-unavailable"
end
;_b.Parse=function(input,options)
	if type(Command)=="table" and type(Command.Parse)=="function" then Command.Parse(type(options)=="table" and options.ignoreNotifications==true,tostring(input or "")) return true end
	return false,"parser-unavailable"
end
;_b.parse=function(ignore,input) return _b.Parse(input,{ignoreNotifications=ignore==true}) end
;_b.GetSettings=function() return Settings end
;_b.SetSetting=function(section,key,value)
	if key==nil then key=section section=nil end
	local target=section and Settings and Settings[section] or Settings
	if type(target)~="table" then return false,"setting-section-unavailable" end
	target[key]=value
	if type(UpdateSettings)=="function" then pcall(UpdateSettings) end
	_emit("settingsChanged",{Section=section,Key=key,Value=value})
	return true
end
;_b.GetState=function() return {name="Cmd",version=Settings and Settings.Version or "unknown",protocol=1,prefix=Settings and Settings.Prefix or ";",chatPrefix=Settings and Settings.ChatPrefix or "!",separator=Settings and Settings.Seperator or ",",commandCount=#_cmdList(),uiEnabled=typeof(UI)=="Instance" and UI.Enabled~=false} end
;_b.Notify=function(config) if type(API)=="table" and type(API.Notify)=="function" then API:Notify(type(config)=="table" and config or {}) return true end return false end
;_b.OpenCommandBar=function() if type(OpenCommandBar)=="function" then OpenCommandBar() return true end return false end
;_b.GetUI=function() return UI end
;_b.AddCommand=function(info)
	if type(Command)~="table" or type(Command.Add)~="function" then return false,"dynamic-commands-unavailable" end
	local aliases=type(info)=="table" and (info.Aliases or info.aliases) or nil
	Command.Add(info)
	local primary=type(aliases)=="table" and aliases[1] and string.lower(tostring(aliases[1])) or nil
	local entry=primary and _find(primary) or nil
	if entry and type(Fill)=="table" and type(Fill.Add)=="function" then pcall(Fill.Add,entry) end
	_emit("commandsChanged",{Action="add",Name=primary,Command=entry})
	return entry~=nil,primary
end
;_b.RemoveCommand=function(name)
	local entry=_find(name)
	if not entry then return false,"command-not-found" end
	local primary
	for commandName,value in Commands do if value==entry then primary=commandName Commands[commandName]=nil break end end
	_emit("commandsChanged",{Action="remove",Name=primary or name,Command=entry})
	return true,primary
end
;_b.AttachHost=function(name,host) name=string.lower(tostring(name or "")) if name=="" or type(host)~="table" then return false end _hosts[name]=host _emit("hostChanged",{Action="attach",Name=name,Host=host}) return true end
;_b.DetachHost=function(name) name=string.lower(tostring(name or "")) local host=_hosts[name] _hosts[name]=nil _emit("hostChanged",{Action="detach",Name=name,Host=host}) return host~=nil end
;_b.GetHost=function(name) return _hosts[string.lower(tostring(name or ""))] end
;_b.Subscribe=function(event,callback)
	if type(event)~="string" or type(callback)~="function" then return nil end
	_nextListener+=1
	local id=_nextListener
	_listeners[event]=_listeners[event] or {}
	_listeners[event][id]=callback
	return {Id=id,Disconnect=function() if _listeners[event] then _listeners[event][id]=nil end end}
end
;if type(API)=="table" and type(API.Notify)=="function" then
	local originalNotify=API.Notify
	API.Notify=function(self,config) _emit("notification",config or {}) return originalNotify(self,config) end
end
;if _g then _g.CmdIntegration=_b _g.CmdBridge=_b _g.CmdIntegrationBridge=_b end
;return _b]=]
	raw = raw..bridgeSuffix

	const loader = loadstring or load
	if type(loader) ~= "function" then
		return false, "compiler unavailable"
	end
	local chunk, compileErr = loader(raw, "CmdIntegration")
	if not chunk then
		return false, compileErr or "compile error"
	end
	NAStuff.CmdIntegrationLoading = true
	local ok, result = pcall(chunk)
	NAStuff.CmdIntegrationLoading = false
	if not ok then
		return false, result
	end
	const bridge = type(result) == "table" and result or NAmanage.CmdIntegrationFindExistingBridge()
	local okApply, applyResult = NAmanage.CmdIntegrationApplyBridge(bridge, sourceLabel, opts)
	if not okApply then
		return false, applyResult
	end
	if not opts.silent and type(DoNotif) == "function" then
		const state = NAStuff.CmdIntegrationState
		const version = type(state) == "table" and state.version or bridge.Version or bridge.version
		DoNotif("Cmd integrated"..(version and (" (v"..tostring(version)..")") or ""), 3)
	end
	return true, sourceLabel
end

NAmanage._naIsCmdCommandEntry=function(data)
	return type(data) == "table"
		and type(data[1]) == "table"
		and type(data[5]) == "function"
end

NAmanage._naIsCmdCommandsTable=function(tbl)
	if type(tbl) ~= "table" then
		return false
	end
	local seen = 0
	for key, value in tbl do
		if type(key) ~= "string" then
			return false
		end
		if NAmanage._naIsCmdCommandEntry(value) then
			seen += 1
			if seen >= 3 then
				return true
			end
		end
	end
	return seen > 0
end

NAmanage.detectCmdManualLoad=function(opts)
	opts = opts or {}
	const existingBridge = NAmanage.CmdIntegrationFindExistingBridge()
	if type(existingBridge) == "table" then
		return NAmanage.CmdIntegrationApplyBridge(existingBridge, "manual-bridge", opts)
	end
	local commandsTable
	local commandModule
	local settingsTable
	if type(getgc) == "function" then
		for _, object in getgc(true) do
			if type(object) == "table" then
				if not commandsTable and NAmanage._naIsCmdCommandsTable(object) then
					commandsTable = object
				end
				if not commandModule and type(rawget(object, "Parse")) == "function" and type(rawget(object, "Run")) == "function" then
					commandModule = object
				end
				if not settingsTable and type(rawget(object, "Prefix")) == "string" and type(rawget(object, "ChatPrefix")) == "string" then
					settingsTable = object
				end
			end
			if commandsTable and commandModule and settingsTable then
				break
			end
		end
	end
	if not commandsTable or not commandModule then
		return false, "cmd-not-found"
	end
	const function listCommands()
		const out = {}
		for name, data in commandsTable do
			const aliases = {}
			for _, alias in type(data[1]) == "table" and data[1] or {} do
				Insert(aliases, tostring(alias))
			end
			const arguments = {}
			for _, argument in type(data[3]) == "table" and data[3] or {} do
				if type(argument) == "table" then
					Insert(arguments, { name = tostring(argument.Name or argument.name or ""); type = tostring(argument.Type or argument.type or "String"); })
				end
			end
			Insert(out, { name = tostring(name); aliases = aliases; desc = tostring(data[2] or ""); arguments = arguments; plugin = data[4] == true; })
		end
		return out
	end
	const function findCommand(name)
		name = Lower(tostring(name or ""))
		for _, data in commandsTable do
			for _, alias in type(data[1]) == "table" and data[1] or {} do
				if Lower(tostring(alias)) == name then
					return data
				end
			end
		end
	end
	const bridge = {
		Protocol = 1;
		protocol = 1;
		ListCommands = listCommands;
		list = listCommands;
		FindCommand = findCommand;
		HasCommand = function(name) return findCommand(name) ~= nil end;
		RunCommand = function(name, args, options)
			if not findCommand(name) then return false, "command-not-found" end
			commandModule.Run(type(options) == "table" and options.ignoreNotifications == true, Lower(tostring(name)), type(args) == "table" and args or {})
			return true
		end;
		Parse = function(input, options)
			commandModule.Parse(type(options) == "table" and options.ignoreNotifications == true, tostring(input or ""))
			return true
		end;
		GetState = function()
			return { name = "Cmd"; version = settingsTable and settingsTable.Version; protocol = 1; prefix = settingsTable and settingsTable.Prefix or ";"; chatPrefix = settingsTable and settingsTable.ChatPrefix or "!"; separator = settingsTable and settingsTable.Seperator or ","; commandCount = #listCommands(); }
		end;
	}
	return NAmanage.CmdIntegrationApplyBridge(bridge, "manual-detect", opts)
end

NAmanage.IYIntegrationModes = NAmanage.IYIntegrationModes or { "NA First", "IY First", "Explicit Only" }

NAmanage.IYIntegrationNormalizeMode = function(value)
	value = tostring(value or "NA First")
	for _, mode in NAmanage.IYIntegrationModes do
		if Lower(mode) == Lower(value) then
			return mode
		end
	end
	return "NA First"
end

NAmanage.IYIntegrationGetMethod = function(bridge, names)
	if type(bridge) ~= "table" then return nil end
	for _, name in names do
		const callback = bridge[name]
		if type(callback) == "function" then return callback end
	end
	return nil
end

NAmanage.IYIntegrationFindExistingBridge = function()
	for _, target in { _na_env, _na_shared, _na_boot and _na_boot.runtimeEnv, _na_boot and _na_boot.hostEnv, type(getgenv) == "function" and getgenv() or nil, _G } do
		if type(target) == "table" then
			const bridge = rawget(target, "IYIntegration") or rawget(target, "IYBridge") or rawget(target, "InfiniteYieldIntegration") or rawget(target, "InfiniteYieldBridge")
			if type(bridge) == "table" then
				const listMethod = NAmanage.IYIntegrationGetMethod(bridge, { "ListCommands", "listCommands", "list" })
				const runMethod = NAmanage.IYIntegrationGetMethod(bridge, { "RunCommand", "runCommand", "Parse", "parse" })
				if type(listMethod) == "function" and type(runMethod) == "function" then return bridge end
			end
		end
	end
	return nil
end

NAmanage.IYIntegrationFindUI = function()
	const roots = {}
	if Services.CoreGui then roots[#roots + 1] = Services.CoreGui end
	const playerGui = Services.Players and Services.Players.LocalPlayer and Services.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if playerGui then roots[#roots + 1] = playerGui end
	for _, root in roots do
		local ok, descendants = pcall(root.GetDescendants, root)
		if ok and type(descendants) == "table" then
			for _, node in descendants do
				if node:IsA("TextLabel") and type(node.Text) == "string" and node.Text:match("^Infinite Yield FE v") then
					const holder = node.Parent
					const commands = holder and holder:FindFirstChild("CMDs")
					const commandBar = holder and holder:FindFirstChild("Cmdbar")
					local input = commandBar
					if typeof(input) ~= "Instance" or not input:IsA("TextBox") then
						input = commandBar and commandBar:FindFirstChildWhichIsA("TextBox", true) or nil
					end
					if holder and commands and commands:IsA("GuiObject") and input and input:IsA("TextBox") then
						return { holder = holder; commands = commands; input = input; title = node; root = root; }
					end
				end
			end
		end
	end
	return nil
end

NAmanage.IYIntegrationParseDisplayCommand = function(text, description)
	text = tostring(text or ""):match("^%s*(.-)%s*$") or ""
	if text == "" then return nil end
	const arguments = {}
	for hint in text:gmatch("%[([^%]]+)%]") do
		hint = tostring(hint or ""):match("^%s*(.-)%s*$") or ""
		if hint ~= "" then arguments[#arguments + 1] = { name = hint; type = "String"; } end
	end
	local head = text:match("^([^%[]+)") or text
	head = head:gsub("%s*%([^%)]*%)%s*$", "")
	const names = {}
	for part in head:gmatch("[^/]+") do
		part = tostring(part or ""):match("^%s*(.-)%s*$") or ""
		part = part:gsub("%s*%([^%)]*%)%s*$", "")
		const token = part:match("^([^%s]+)")
		if token and token ~= "" then names[#names + 1] = token end
	end
	if #names == 0 then return nil end
	const aliases = {}
	const seen = { [Lower(names[1])] = true }
	for index = 2, #names do
		const alias = names[index]
		const key = Lower(alias)
		if alias ~= "" and not seen[key] then seen[key] = true; aliases[#aliases + 1] = alias end
	end
	return {
		name = names[1];
		aliases = aliases;
		desc = tostring(description or "");
		usage = text;
		arguments = arguments;
		requiresArguments = #arguments > 0;
		plugin = false;
	}
end

NAmanage.IYIntegrationBuildUIBridge = function(ui)
	ui = type(ui) == "table" and ui or NAmanage.IYIntegrationFindUI()
	if type(ui) ~= "table" or typeof(ui.commands) ~= "Instance" or typeof(ui.input) ~= "Instance" then return nil, "iy-ui-unavailable" end
	const bridge = { Protocol = 2; protocol = 2; Name = "Infinite Yield"; name = "Infinite Yield"; Kind = "InfiniteYieldUI"; kind = "InfiniteYieldUI"; uiOnly = true; }
	const virtualPrimary = {}
	const virtualLookup = {}
	local virtualFocusConnection = nil
	local virtualTextConnection = nil
	local virtualKeyConnection = nil
	local virtualLastText = tostring(ui.input.Text or "")
	local virtualLastRunText = ""
	local virtualLastRunAt = 0
	const function currentPrefix()
		local placeholder = tostring(ui.input and ui.input.PlaceholderText or "")
		return placeholder:match("%((.-)%)%s*$") or ";"
	end
	const function stripPrefix(line)
		line = tostring(line or "")
		const pfx = currentPrefix()
		if pfx ~= "" and line:sub(1, #pfx) == pfx then return line:sub(#pfx + 1) end
		return line
	end
	const function runVirtualLine(rawLine)
		local line = stripPrefix(rawLine)
		line = tostring(line or ""):match("^%s*(.-)%s*$") or ""
		if line == "" then return false end
		const now = os.clock()
		if line == virtualLastRunText and now - virtualLastRunAt < 0.2 then return false end
		const args = {}
		for token in line:gmatch("%S+") do args[#args + 1] = token end
		const first = args[1] and Lower(args[1]) or ""
		const entry = first ~= "" and virtualLookup[first] or nil
		if not entry then return false end
		virtualLastRunText = line
		virtualLastRunAt = now
		table.remove(args, 1)
		Defer(function()
			local ok, accepted, result = pcall(entry.callback, table.unpack(args))
			if not ok then
				warn("Infinite Yield virtual command error:", tostring(entry.name), tostring(accepted))
			elseif accepted == false then
				warn("Infinite Yield virtual command failed:", tostring(entry.name), tostring(result or "unknown error"))
			end
		end)
		return true
	end
	const function ensureVirtualFocus()
		if virtualTextConnection == nil then
			virtualTextConnection = ui.input:GetPropertyChangedSignal("Text"):Connect(function()
				const current = tostring(ui.input.Text or "")
				if current ~= "" then virtualLastText = current end
			end)
		end
		if virtualKeyConnection == nil and Services.UserInputService then
			virtualKeyConnection = Services.UserInputService.InputBegan:Connect(function(input)
				if not input or not ui.input:IsFocused() then return end
				if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
					runVirtualLine(virtualLastText ~= "" and virtualLastText or ui.input.Text)
				end
			end)
		end
		if virtualFocusConnection == nil then
			virtualFocusConnection = ui.input.FocusLost:Connect(function(enterPressed)
				if enterPressed then runVirtualLine(virtualLastText ~= "" and virtualLastText or ui.input.Text) end
			end)
		end
	end
	const function maybeDisconnectVirtualFocus()
		if next(virtualPrimary) ~= nil then return end
		for _, connection in { virtualFocusConnection, virtualTextConnection, virtualKeyConnection } do
			if connection then pcall(connection.Disconnect, connection) end
		end
		virtualFocusConnection = nil
		virtualTextConnection = nil
		virtualKeyConnection = nil
		virtualLastText = ""
	end
	const function listCommands()
		const result = {}
		for _, child in ui.commands:GetChildren() do
			if child:IsA("TextButton") and child.TextTransparency < 1 then
				const info = NAmanage.IYIntegrationParseDisplayCommand(child:GetAttribute("Title") or child.Text, child:GetAttribute("Desc"))
				if info then result[#result + 1] = info end
			end
		end
		for _, entry in virtualPrimary do
			result[#result + 1] = {
				name = entry.name;
				aliases = entry.aliases;
				desc = entry.desc;
				usage = entry.name;
				arguments = entry.arguments;
				requiresArguments = #entry.arguments > 0;
				plugin = true;
			}
		end
		table.sort(result, function(a, b) return Lower(a.name) < Lower(b.name) end)
		return result
	end
	const function parseLine(inputLine)
		if not (ui.input and ui.input.Parent) then return false, "command-bar-unavailable" end
		local ok, err = pcall(function()
			ui.input:CaptureFocus()
			ui.input.Text = tostring(inputLine or "")
			ui.input.CursorPosition = #ui.input.Text + 1
			ui.input:ReleaseFocus(true)
		end)
		if not ok then return false, tostring(err) end
		return true, "submitted"
	end
	bridge.ListCommands = listCommands
	bridge.listCommands = listCommands
	bridge.list = listCommands
	bridge.Parse = parseLine
	bridge.parse = parseLine
	bridge.HasCommand = function(name)
		name = Lower(tostring(name or ""))
		if name == "" then return false end
		if virtualLookup[name] then return true end
		for _, info in listCommands() do
			if Lower(tostring(info.name or "")) == name then return true end
			for _, alias in type(info.aliases) == "table" and info.aliases or {} do if Lower(tostring(alias or "")) == name then return true end end
		end
		return false
	end
	bridge.hasCommand = bridge.HasCommand
	bridge.RunCommand = function(name, args)
		const key = Lower(tostring(name or ""))
		const virtual = virtualLookup[key]
		const values = {}
		for _, value in type(args) == "table" and args or {} do values[#values + 1] = tostring(value or "") end
		if virtual then
			local ok, accepted, result = pcall(virtual.callback, table.unpack(values))
			if not ok then return false, tostring(accepted) end
			if accepted == false then return false, tostring(result or "virtual-command-failed") end
			return true, result ~= nil and result or accepted
		end
		local line = tostring(name or "")
		if #values > 0 then line ..= " "..Concat(values, " ") end
		return parseLine(line)
	end
	bridge.runCommand = bridge.RunCommand
	bridge.AddCommand = function(info)
		if type(info) ~= "table" then return false, "invalid-command" end
		local name = tostring(info.Name or info.name or "")
		if name == "" then return false, "missing-command-name" end
		const callback = info.Task or info.task or info.Callback or info.callback or info.Function or info.func
		if type(callback) ~= "function" then return false, "missing-command-callback" end
		const aliases = {}
		const entry = { name = name; aliases = aliases; callback = callback; desc = tostring(info.Description or info.description or ""); arguments = type(info.Arguments or info.arguments) == "table" and (info.Arguments or info.arguments) or {}; }
		virtualPrimary[Lower(name)] = entry
		virtualLookup[Lower(name)] = entry
		for _, alias in type(info.Aliases or info.aliases) == "table" and (info.Aliases or info.aliases) or {} do
			alias = tostring(alias or "")
			if alias ~= "" then aliases[#aliases + 1] = alias; virtualLookup[Lower(alias)] = entry end
		end
		ensureVirtualFocus()
		return true, name
	end
	bridge.addCommand = bridge.AddCommand
	bridge.RemoveCommand = function(name)
		const key = Lower(tostring(name or ""))
		const entry = virtualLookup[key]
		if not entry then return false, "command-not-found" end
		virtualPrimary[Lower(entry.name)] = nil
		virtualLookup[Lower(entry.name)] = nil
		for _, alias in entry.aliases do virtualLookup[Lower(alias)] = nil end
		maybeDisconnectVirtualFocus()
		return true, entry.name
	end
	bridge.removeCommand = bridge.RemoveCommand
	bridge.GetState = function()
		local version = "unknown"
		if ui.title and type(ui.title.Text) == "string" then version = ui.title.Text:match("v([^%s]+)") or version end
		return { name = "Infinite Yield"; version = version; protocol = 2; prefix = currentPrefix(); commandCount = #listCommands(); commandBarAvailable = ui.input and ui.input.Parent ~= nil; uiVisible = ui.holder and ui.holder.Visible ~= false; uiOnly = true; }
	end
	bridge.getState = bridge.GetState
	bridge.OpenCommandBar = function()
		if not (ui.input and ui.input.Parent) then return false, "command-bar-unavailable" end
		if ui.holder then ui.holder.Visible = true end
		local ok, err = pcall(function() ui.input:CaptureFocus() end)
		return ok, err
	end
	bridge.openCommandBar = bridge.OpenCommandBar
	bridge.open = bridge.OpenCommandBar
	bridge.GetUI = function() return ui.holder end
	bridge.getUI = bridge.GetUI
	bridge.Subscribe = function(event, callback)
		if event ~= "commandsChanged" or type(callback) ~= "function" then return nil end
		const bag = {}
		bag[#bag + 1] = ui.commands.ChildAdded:Connect(function(child)
			if child:IsA("TextButton") then Defer(callback, { Action = "add"; }) end
		end)
		bag[#bag + 1] = ui.commands.ChildRemoved:Connect(function(child)
			if child:IsA("TextButton") then Defer(callback, { Action = "remove"; }) end
		end)
		return { Disconnect = function() for _, connection in bag do pcall(connection.Disconnect, connection) end end; }
	end
	bridge.subscribe = bridge.Subscribe
	bridge.on = bridge.Subscribe
	bridge.Destroy = function()
		for _, connection in { virtualFocusConnection, virtualTextConnection, virtualKeyConnection } do
			if connection then pcall(connection.Disconnect, connection) end
		end
		virtualFocusConnection = nil
		virtualTextConnection = nil
		virtualKeyConnection = nil
		table.clear(virtualPrimary)
		table.clear(virtualLookup)
	end
	bridge.destroy = bridge.Destroy
	return bridge
end

NAmanage.IYIntegrationBuildRuntimeBridge = function(runtime)
	if type(runtime) ~= "table" or type(runtime.cmds) ~= "table" or type(runtime.execCmd) ~= "function" then return nil, "iy-runtime-unavailable" end
	const bridge = { Protocol = 2; protocol = 2; Name = "Infinite Yield"; name = "Infinite Yield"; Kind = "InfiniteYieldRuntime"; kind = "InfiniteYieldRuntime"; runtimeCaptured = true; }
	const function listCommands()
		const meta = {}
		if type(runtime.CMDs) == "table" then
			for _, display in runtime.CMDs do
				if type(display) == "table" then
					const info = NAmanage.IYIntegrationParseDisplayCommand(display.NAME, display.DESC)
					if info then
						meta[Lower(info.name)] = info
						for _, alias in info.aliases do meta[Lower(alias)] = info end
					end
				end
			end
		end
		const result = {}
		for _, entry in runtime.cmds do
			if type(entry) == "table" then
				const name = tostring(entry.NAME or "")
				if name ~= "" then
					const aliases = {}
					for _, alias in type(entry.ALIAS) == "table" and entry.ALIAS or {} do aliases[#aliases + 1] = tostring(alias or "") end
					local info = meta[Lower(name)]
					if not info then for _, alias in aliases do info = meta[Lower(alias)]; if info then break end end end
					result[#result + 1] = { name = name; aliases = aliases; desc = info and info.desc or ""; usage = info and info.usage or name; arguments = info and info.arguments or {}; requiresArguments = info and info.requiresArguments or false; plugin = entry.PLUGIN ~= nil and entry.PLUGIN ~= false; }
				end
			end
		end
		table.sort(result, function(a, b) return Lower(a.name) < Lower(b.name) end)
		return result
	end
	bridge.ListCommands = listCommands
	bridge.listCommands = listCommands
	bridge.list = listCommands
	bridge.Parse = function(line)
		local ok, err = pcall(runtime.execCmd, tostring(line or ""), Services.Players and Services.Players.LocalPlayer, true)
		if not ok then return false, tostring(err) end
		return true, "scheduled"
	end
	bridge.parse = bridge.Parse
	bridge.RunCommand = function(name, args)
		local line = tostring(name or "")
		const values = {}
		for _, value in type(args) == "table" and args or {} do values[#values + 1] = tostring(value or "") end
		if #values > 0 then line ..= " "..Concat(values, " ") end
		return bridge.Parse(line)
	end
	bridge.runCommand = bridge.RunCommand
	bridge.HasCommand = function(name)
		if type(runtime.findCmd) ~= "function" then return false end
		local ok, result = pcall(runtime.findCmd, tostring(name or ""))
		return ok and result ~= nil
	end
	bridge.hasCommand = bridge.HasCommand
	bridge.AddCommand = function(info)
		if type(runtime.addcmd) ~= "function" or type(info) ~= "table" then return false, "dynamic-commands-unavailable" end
		local name = tostring(info.Name or info.name or "")
		const aliases = {}
		for _, alias in type(info.Aliases or info.aliases) == "table" and (info.Aliases or info.aliases) or {} do if tostring(alias or "") ~= "" then aliases[#aliases + 1] = tostring(alias) end end
		if name == "" then return false, "missing-command-name" end
		const callback = info.Task or info.task or info.Callback or info.callback or info.Function or info.func
		if type(callback) ~= "function" then return false, "missing-command-callback" end
		local ok, err = pcall(runtime.addcmd, name, aliases, function(args) return callback(table.unpack(type(args) == "table" and args or {})) end, true)
		return ok, ok and name or err
	end
	bridge.addCommand = bridge.AddCommand
	bridge.RemoveCommand = function(name)
		if type(runtime.removecmd) ~= "function" then return false, "dynamic-commands-unavailable" end
		local ok, err = pcall(runtime.removecmd, tostring(name or ""))
		return ok, ok and tostring(name or "") or err
	end
	bridge.removeCommand = bridge.RemoveCommand
	bridge.GetState = function() return { name = "Infinite Yield"; version = tostring(runtime.currentVersion or "unknown"); protocol = 2; commandCount = #listCommands(); runtimeCaptured = true; } end
	bridge.getState = bridge.GetState
	local ui = NAmanage.IYIntegrationFindUI()
	if type(ui) == "table" then
		const uiBridge = NAmanage.IYIntegrationBuildUIBridge(ui)
		if type(uiBridge) == "table" then
			bridge.OpenCommandBar = uiBridge.OpenCommandBar
			bridge.openCommandBar = uiBridge.openCommandBar
			bridge.open = uiBridge.open
			bridge.GetUI = uiBridge.GetUI
			bridge.getUI = uiBridge.getUI
			bridge.Subscribe = uiBridge.Subscribe
			bridge.subscribe = uiBridge.subscribe
			bridge.on = uiBridge.on
		end
	end
	return bridge
end

NAmanage.IYIntegrationDisconnectSubscriptions = function()
	const subscriptions = NAStuff.IYIntegrationSubscriptions
	if type(subscriptions) == "table" then
		for key, subscription in subscriptions do
			if type(subscription) == "function" then pcall(subscription)
			elseif type(subscription) == "table" and type(subscription.Disconnect) == "function" then pcall(subscription.Disconnect, subscription)
			elseif typeof(subscription) == "RBXScriptConnection" then pcall(subscription.Disconnect, subscription) end
			subscriptions[key] = nil
		end
	end
	NAStuff.IYIntegrationSubscriptions = {}
end

NAmanage.IYIntegrationRefresh = function(opts)
	opts = opts or {}
	const bridge = opts.bridge or NAStuff.IYIntegrationBridge
	if type(bridge) ~= "table" then return false, "bridge-unavailable" end
	const listMethod = NAmanage.IYIntegrationGetMethod(bridge, { "ListCommands", "listCommands", "list" })
	if type(listMethod) ~= "function" then return false, "command-list-unavailable" end
	local okList, rawList = pcall(listMethod)
	if not okList or type(rawList) ~= "table" then return false, tostring(rawList or "command-list-failed") end
	const normalized, commandSet = {}, {}
	for _, info in rawList do
		if type(info) == "table" then
			const name = tostring(info.name or info.Name or "")
			if name ~= "" then
				const aliases, seen = {}, {}
				for _, alias in type(info.aliases or info.Aliases) == "table" and (info.aliases or info.Aliases) or {} do
					const value = tostring(alias or "")
					const key = Lower(value)
					if value ~= "" and not seen[key] then seen[key] = true; aliases[#aliases + 1] = value; commandSet[key] = name end
				end
				commandSet[Lower(name)] = name
				normalized[#normalized + 1] = { name = name; aliases = aliases; desc = tostring(info.desc or info.description or info.Description or ""); arguments = type(info.arguments or info.Arguments) == "table" and (info.arguments or info.Arguments) or {}; plugin = info.plugin == true or info.Plugin == true; origin = "iy"; }
			end
		end
	end
	table.sort(normalized, function(a, b) return Lower(a.name) < Lower(b.name) end)
	NAStuff.IYIntegrationCommands = normalized
	NAStuff.IYIntegrationCommandSet = commandSet
	if type(NAmanage.invalidateCommandBuild) == "function" then NAmanage.invalidateCommandBuild() end
	if opts.refreshUI ~= false and NAgui and type(NAgui.loadCMDS) == "function" then pcall(NAgui.loadCMDS) end
	return true, normalized
end

NAmanage.IYIntegrationHasCommand = function(name)
	name = Lower(tostring(name or ""))
	if name == "" then return false end
	const bridge = NAStuff.IYIntegrationBridge
	const hasMethod = NAmanage.IYIntegrationGetMethod(bridge, { "HasCommand", "hasCommand" })
	if type(hasMethod) == "function" then local ok, found = pcall(hasMethod, name); if ok then return found == true end end
	return type(NAStuff.IYIntegrationCommandSet) == "table" and NAStuff.IYIntegrationCommandSet[name] ~= nil
end

NAmanage.IYIntegrationRemoveGateway = function(bridge)
	bridge = bridge or NAStuff.IYIntegrationBridge
	const gateway = NAStuff.IYIntegrationGatewayName
	if not gateway then return false end
	const removeMethod = NAmanage.IYIntegrationGetMethod(bridge, { "RemoveCommand", "removeCommand" })
	if type(removeMethod) == "function" then pcall(removeMethod, gateway) end
	NAStuff.IYIntegrationGatewayName = nil
	return true
end

NAmanage.IYIntegrationInstallGateway = function(bridge, host)
	bridge = bridge or NAStuff.IYIntegrationBridge
	host = host or NAStuff.IYIntegrationHost
	NAmanage.IYIntegrationRemoveGateway(bridge)
	if NAStuff.IYIntegrationExposeGateway == false or type(host) ~= "table" then return false, "gateway-disabled" end
	const addMethod = NAmanage.IYIntegrationGetMethod(bridge, { "AddCommand", "addCommand" })
	if type(addMethod) ~= "function" then return false, "runtime-gateway-unavailable" end
	const gateway = NAmanage.IYIntegrationHasCommand("na") and "namelessadmin" or "na"
	local ok, accepted, result = pcall(addMethod, { Name = gateway; Aliases = gateway == "na" and { "namelessadmin", "naadmin" } or { "naadmin" }; Description = "Run a Nameless Admin command through Infinite Yield"; Task = function(...)
		const args = { ... }
		if #args == 0 then return false end
		if type(host.run) == "function" then return host.run(args) end
		return false
	end; })
	if not ok or accepted == false then return false, tostring(result or accepted or "gateway-failed") end
	NAStuff.IYIntegrationGatewayName = tostring(result or gateway)
	return true, NAStuff.IYIntegrationGatewayName
end

NAmanage.IYIntegrationAttach = function(bridge)
	if type(bridge) ~= "table" then return false end
	NAmanage.IYIntegrationDisconnectSubscriptions()
	const host = NAmanage.CmdIntegrationBuildHost and NAmanage.CmdIntegrationBuildHost() or nil
	NAStuff.IYIntegrationHost = host
	NAmanage.IYIntegrationInstallGateway(bridge, host)
	const subscribeMethod = NAmanage.IYIntegrationGetMethod(bridge, { "Subscribe", "subscribe", "on" })
	if type(subscribeMethod) == "function" then
		local ok, subscription = pcall(subscribeMethod, "commandsChanged", function()
			NAStuff.IYIntegrationRefreshToken = (tonumber(NAStuff.IYIntegrationRefreshToken) or 0) + 1
			const token = NAStuff.IYIntegrationRefreshToken
			Delay(0.1, function() if NAStuff.IYIntegrationRefreshToken == token then NAmanage.IYIntegrationRefresh({ refreshUI = true }) end end)
		end)
		if ok and subscription then NAStuff.IYIntegrationSubscriptions = { commands = subscription } end
	end
	return true
end

NAmanage.IYIntegrationApplyBridge = function(bridge, sourceLabel, opts)
	opts = opts or {}
	if type(bridge) ~= "table" then return false, "invalid-bridge" end
	NAStuff.IYIntegrationBridge = bridge
	NAStuff.IYIntegrationLoaded = true
	NAStuff.IYIntegrationLastSource = sourceLabel or "Infinite Yield"
	NAStuff.IYIntegrationProtocol = tonumber(bridge.Protocol or bridge.protocol) or 1
	const stateMethod = NAmanage.IYIntegrationGetMethod(bridge, { "GetState", "getState" })
	if type(stateMethod) == "function" then local ok, state = pcall(stateMethod); if ok and type(state) == "table" then NAStuff.IYIntegrationState = state end end
	local okRefresh, refreshResult = NAmanage.IYIntegrationRefresh({ bridge = bridge; refreshUI = opts.refreshUI ~= false; })
	if not okRefresh then NAStuff.IYIntegrationLoaded = false; NAStuff.IYIntegrationBridge = nil; return false, refreshResult end
	NAmanage.IYIntegrationAttach(bridge)
	return true, sourceLabel
end

NAmanage.disconnectIYIntegration = function(opts)
	opts = opts or {}
	const bridge = NAStuff.IYIntegrationBridge
	NAmanage.IYIntegrationDisconnectSubscriptions()
	NAmanage.IYIntegrationRemoveGateway(bridge)
	local destroyMethod = NAmanage.IYIntegrationGetMethod(bridge, { "Destroy", "destroy" })
	if type(destroyMethod) == "function" then pcall(destroyMethod) end
	NAStuff.IYIntegrationBridge = nil
	NAStuff.IYIntegrationHost = nil
	NAStuff.IYIntegrationLoaded = false
	NAStuff.IYIntegrationLastSource = nil
	NAStuff.IYIntegrationProtocol = nil
	NAStuff.IYIntegrationCommands = nil
	NAStuff.IYIntegrationCommandSet = nil
	NAStuff.IYIntegrationState = nil
	NAStuff.IYIntegrationGatewayName = nil
	if type(NAmanage.invalidateCommandBuild) == "function" then NAmanage.invalidateCommandBuild() end
	if NAgui and type(NAgui.loadCMDS) == "function" then pcall(NAgui.loadCMDS) end
	if not opts.silent and type(DoNotif) == "function" then DoNotif("Infinite Yield integration disconnected", 3) end
	return true
end

NAmanage.detectIYManualLoad = function(opts)
	opts = opts or {}
	local bridge = NAmanage.IYIntegrationFindExistingBridge()
	if type(bridge) == "table" then return NAmanage.IYIntegrationApplyBridge(bridge, opts.sourceLabel or "existing-bridge", opts) end
	const ui = NAmanage.IYIntegrationFindUI()
	if type(ui) ~= "table" then return false, "infinite-yield-not-found" end
	local built, err = NAmanage.IYIntegrationBuildUIBridge(ui)
	if type(built) ~= "table" then return false, err or "ui-bridge-build-failed" end
	return NAmanage.IYIntegrationApplyBridge(built, opts.sourceLabel or "existing-ui", opts)
end

NAmanage.loadIYIntegration = function(opts)
	opts = opts or {}
	if NAStuff.IYIntegrationLoading then return false, "Infinite Yield is already loading" end
	if NAStuff.IYIntegrationLoaded and type(NAStuff.IYIntegrationBridge) == "table" then return NAmanage.IYIntegrationRefresh({ refreshUI = true }) end
	local okExisting, existingResult = NAmanage.detectIYManualLoad({ sourceLabel = "existing-ui"; refreshUI = opts.refreshUI ~= false; })
	if okExisting then return true, existingResult end
	local alreadyLoaded = false
	if type(getgenv) == "function" then local ok, env = pcall(getgenv); if ok and type(env) == "table" then alreadyLoaded = rawget(env, "IY_LOADED") == true end end
	if alreadyLoaded then
		for _ = 1, 30 do
			Wait(0.1)
			local okAttach, attachResult = NAmanage.detectIYManualLoad({ sourceLabel = "existing-ui"; refreshUI = opts.refreshUI ~= false; })
			if okAttach then return true, attachResult end
		end
		return false, "Infinite Yield is loaded but its command UI was not found"
	end
	const function fetchUrl(url)
		if type(url) ~= "string" or url == "" then return nil, "invalid url" end
		const request = opt and opt.NAREQUEST
		if type(request) == "function" then
			local ok, response = pcall(request, { Url = url; Method = "GET"; Timeout = 15; FollowRedirects = true; SslVerify = false; })
			if ok and response then
				const body = response.Body or response.body or response.Data or response.data or response.Text or response.text or response.Content or response.content or response[1]
				if type(body) == "string" and body ~= "" then return body end
			end
		end
		local ok, body = NAmanage.HttpGet(url, { timeout = 15 })
		if ok and type(body) == "string" and body ~= "" then return body end
		return nil, "request failed"
	end
	const sourceUrl = tostring(opts.url or (opt and opt.iyIntegrationUrl) or "https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source")
	local raw, fetchErr = fetchUrl(sourceUrl)
	if not raw then return false, fetchErr end
	const captureSuffix = [=[
;return {cmds=cmds,findCmd=findCmd,execCmd=execCmd,addcmd=addcmd,removecmd=removecmd,notify=notify,CMDs=CMDs,Holder=Holder,Cmdbar=Cmdbar,PARENT=PARENT,currentVersion=currentVersion,prefix=prefix,Players=Players,maximizeHolder=maximizeHolder}
]=]
	const loader = loadstring or load
	if type(loader) ~= "function" then return false, "compiler unavailable" end
	local chunk, compileErr = loader(raw..captureSuffix, "InfiniteYieldIntegration")
	if not chunk then return false, compileErr or "compile error" end
	NAStuff.IYIntegrationLoading = true
	local okRun, runtime = pcall(chunk)
	NAStuff.IYIntegrationLoading = false
	if not okRun then return false, runtime end
	local bridge
	if type(runtime) == "table" then bridge = NAmanage.IYIntegrationBuildRuntimeBridge(runtime) end
	if type(bridge) ~= "table" then
		for _ = 1, 30 do
			Wait(0.1)
			local ui = NAmanage.IYIntegrationFindUI()
			if type(ui) == "table" then bridge = NAmanage.IYIntegrationBuildUIBridge(ui); break end
		end
	end
	if type(bridge) ~= "table" then return false, "Infinite Yield loaded but bridge creation failed" end
	local okApply, applyResult = NAmanage.IYIntegrationApplyBridge(bridge, sourceUrl, opts)
	if not okApply then return false, applyResult end
	if not opts.silent and type(DoNotif) == "function" then
		const state = NAStuff.IYIntegrationState or {}
		DoNotif("Infinite Yield integrated"..(state.version and (" (v"..tostring(state.version)..")") or ""), 3)
	end
	return true, sourceUrl
end

NAmanage.resolveTweenDuration=function(scale)
	local base = tonumber(NAStuff.tweenSpeed) or 1
	if base <= 0 then
		base = 1
	end
	scale = tonumber(scale) or 1
	if scale <= 0 then
		scale = 1
	end
	return math.max(0.05, base * scale)
end
NAmanage.tpDelay=function()
	const interval = tonumber(NAStuff.tpDelay) or 0.2
	return math.clamp(interval, 0, 5)
end
NAmanage._loaderStatus = NAmanage._loaderStatus or {}

NAmanage.loaderWarn=function(label, detail)
	warn(Format('[%s loader] %s: %s', adminName, label, detail))
end

NAmanage.GetExternalLagProbe = NAmanage.GetExternalLagProbe or function()
	local probe = nil
	pcall(function()
		const genv = getgenv and getgenv() or nil
		if type(genv) == "table" then
			probe = rawget(genv, "__CodexLagProbe")
		end
	end)
	if type(probe) == "table" then
		return probe
	end
	if type(_na_env) == "table" then
		probe = rawget(_na_env, "__CodexLagProbe")
		if type(probe) == "table" then
			return probe
		end
	end
	if type(_G) == "table" then
		probe = rawget(_G, "__CodexLagProbe")
		if type(probe) == "table" then
			return probe
		end
	end
	return nil
end

NAmanage.MarkExternalLagProbe = NAmanage.MarkExternalLagProbe or function(name)
	const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe() or nil
	if type(probe) == "table" and type(probe.mark) == "function" then
		pcall(probe.mark, tostring(name or "mark"))
	end
end

function NAmanage.waitForScreenGui(timeoutSeconds)
	const t = tonumber(timeoutSeconds) or 5
	const deadline = tick() + math.max(t, 0)

	repeat
		const gui = NAmanage.getUI and NAmanage.getUI() or nil
		if gui then
			NAStuff.NASCREENGUI = gui
			return gui
		end
		Wait(0.05)
	until tick() >= deadline

	return nil
end

function NAmanage.runLoader(label, callback, opts)
	opts = opts or {}
	const attempts = opts.retries or 3
	const delay = opts.delay or 0.35
	const retryOnFalse = opts.retryOnFalse
	const requireGui = opts.requiresGui
	const guiTimeout = opts.guiTimeout or 5

	if requireGui and not NAmanage.waitForScreenGui(guiTimeout) then
		NAmanage.loaderWarn(label, 'aborted: interface not ready')
		return false
	end

	local lastErr
	for attempt = 1, attempts do
		local ok, result = pcall(callback)
		if ok and (result ~= false or not retryOnFalse) then
			NAmanage._loaderStatus[label] = true
			return true, result
		end

		if ok then
			lastErr = 'callback returned false'
			if retryOnFalse then
				NAmanage.loaderWarn(label, Format('attempt %d/%d returned false', attempt, attempts))
			end
		else
			lastErr = result
			NAmanage.loaderWarn(label, Format('attempt %d/%d failed: %s', attempt, attempts, tostring(result)))
		end

		if attempt < attempts then
			Wait(delay)
			if requireGui then
				const gui = NAmanage.waitForScreenGui(guiTimeout)
				if not gui then
					break
				end
			end
		end
	end

	if opts.onFailure then
		pcall(opts.onFailure, lastErr)
	end
	NAmanage._loaderStatus[label] = false
	return false
end

NAmanage.clampNumber=function(value, minValue, maxValue, fallback)
	local n = tonumber(value)
	if n == nil then return fallback end
	if minValue and n < minValue then n = minValue end
	if maxValue and n > maxValue then n = maxValue end
	return n
end

NAmanage.WebhookTrim = NAmanage.WebhookTrim or function(value)
	return tostring(value or ""):match("^%s*(.-)%s*$") or ""
end

NAmanage.WebhookClampText = NAmanage.WebhookClampText or function(value, maxLength)
	const textValue = tostring(value or "")
	maxLength = math.max(1, math.floor(tonumber(maxLength) or 2000))
	if #textValue > maxLength then
		return textValue:sub(1, math.max(1, maxLength - 3)).."..."
	end
	return textValue
end

NAmanage.WebhookColorNumber = NAmanage.WebhookColorNumber or function(value, fallback)
	const normalized = NAmanage.NormalizeWebhookHex(value, fallback)
	return tonumber(normalized, 16) or tonumber(tostring(fallback or "7C3AED"), 16) or 8131565
end

NAmanage.WebhookIsoTimestamp = NAmanage.WebhookIsoTimestamp or function()
	local ok, result = pcall(function()
		return DateTime.now():ToIsoDate()
	end)
	if ok and type(result) == "string" then
		return result
	end
	return nil
end

NAmanage.WebhookContext = NAmanage.WebhookContext or function(extra)
	const localPlayer = Services.Players and Services.Players.LocalPlayer
	const playerName = localPlayer and localPlayer.Name or "LocalPlayer"
	const displayName = localPlayer and localPlayer.DisplayName or playerName
	const context = {
		player = playerName;
		display = displayName;
		userId = tostring(localPlayer and localPlayer.UserId or "");
		message = "";
		command = "";
		action = "";
		placeId = tostring(game.PlaceId or "");
		gameId = tostring(game.GameId or "");
		jobId = tostring(game.JobId or "");
		players = tostring(Services.Players and Services.Players.NumPlayers or 0);
		maxPlayers = tostring(Services.Players and Services.Players.MaxPlayers or "?");
		admin = tostring(adminName or "NA");
		time = "";
	}
	local okTime, timeText = pcall(function()
		return os.date("!%Y-%m-%d %H:%M:%S UTC")
	end)
	if okTime and type(timeText) == "string" then
		context.time = timeText
	end
	if type(extra) == "table" then
		for key, value in extra do
			context[key] = tostring(value or "")
		end
	end
	return context
end

NAmanage.ApplyWebhookTemplate = NAmanage.ApplyWebhookTemplate or function(template, context)
	template = tostring(template or "")
	context = type(context) == "table" and context or NAmanage.WebhookContext()
	const result = template:gsub("{([%w_]+)}", function(key)
		const value = context[key]
		if value == nil then
			return "{"..key.."}"
		end
		return tostring(value)
	end)
	return result
end

NAmanage.BuildWebhookEventText = NAmanage.BuildWebhookEventText or function(kind, context)
	local cfg = NAStuff.Integrations and NAStuff.Integrations.webhook
	cfg = NAmanage.NormalizeWebhookConfig(cfg)
	local templateKey = kind
	if kind == "joinleave" then
		templateKey = context and context.action == "left" and "leave" or "join"
	elseif kind == "commands" then
		templateKey = "command"
	end
	const template = cfg.templates[templateKey] or NAmanage.WebhookTemplateDefaults[templateKey] or "{message}"
	return NAmanage.ApplyWebhookTemplate(template, NAmanage.WebhookContext(context))
end

NAmanage.WebhookEventTitle = NAmanage.WebhookEventTitle or function(kind)
	const titles = {
		join = "Player Joined";
		leave = "Player Left";
		joinleave = "Join / Leave Log";
		chat = "Chat Log";
		command = "Command Log";
		commands = "Command Log";
		main = "Manual Message";
		message = "Manual Message";
		msg = "Manual Message";
		test = "Webhook Test";
	}
	return titles[kind] or "Integration Event"
end

NAmanage.WebhookServerField = NAmanage.WebhookServerField or function()
	const placeId = tostring(game.PlaceId or "")
	const gameId = tostring(game.GameId or "")
	const jobId = tostring(game.JobId or "")
	const count = tostring(Services.Players and Services.Players.NumPlayers or 0)
	const maximum = tostring(Services.Players and Services.Players.MaxPlayers or "?")
	const lines = {
		Format("PlaceId: `%s`", placeId ~= "" and placeId or "unknown");
		Format("GameId: `%s`", gameId ~= "" and gameId or "unknown");
		Format("Players: `%s/%s`", count, maximum);
	}
	if jobId ~= "" then
		Insert(lines, Format("JobId: `%s`", jobId))
	end
	return {
		name = "Server";
		value = NAmanage.WebhookClampText(Concat(lines, "\n"), 1024);
		inline = false;
	}
end

NAmanage.BuildIntegrationWebhookPayload = NAmanage.BuildIntegrationWebhookPayload or function(kind, content)
	local cfg = NAStuff.Integrations and NAStuff.Integrations.webhook
	cfg = NAmanage.NormalizeWebhookConfig(cfg)
	const options = cfg.options
	const payload = {}
	if type(content) == "table" then
		for key, value in content do
			payload[key] = value
		end
	else
		local contentText = NAmanage.WebhookClampText(content, options.useEmbeds and 4096 or 2000)
		if options.useEmbeds then
			payload.embeds = {
				{
					description = contentText;
				},
			}
		else
			if options.includeServerInfo then
				const serverField = NAmanage.WebhookServerField()
				const serverText = type(serverField) == "table" and tostring(serverField.value or ""):gsub("`", "") or ""
				if serverText ~= "" then
					contentText ..= "\n"..serverText
				end
			end
			payload.content = NAmanage.WebhookClampText(contentText, 2000)
		end
	end

	if options.username ~= "" and payload.username == nil then
		payload.username = options.username:sub(1, 80)
	end
	if options.avatarUrl ~= "" and payload.avatar_url == nil then
		payload.avatar_url = options.avatarUrl
	end
	if options.tts and payload.tts == nil then
		payload.tts = true
	end
	if options.blockMentions then
		payload.allowed_mentions = { parse = {} }
	end
	if options.silent and payload.flags == nil then
		payload.flags = 4096
	end

	if type(payload.content) == "string" then
		payload.content = NAmanage.WebhookClampText(payload.content, 2000)
	end
	if type(payload.embeds) == "table" then
		local colorKey = kind
		if kind == "commands" then colorKey = "command" end
		if kind == "message" or kind == "msg" then colorKey = "main" end
		const fallbackColor = NAmanage.WebhookColorDefaults[colorKey] or NAmanage.WebhookColorDefaults.main
		const selectedColor = options.colors[colorKey] or fallbackColor
		for index, embed in payload.embeds do
			if type(embed) == "table" then
				if index == 1 and embed.title == nil then
					const prefix = NAmanage.WebhookTrim(options.titlePrefix)
					const eventTitle = NAmanage.WebhookEventTitle(kind)
					embed.title = prefix ~= "" and (prefix.." • "..eventTitle) or eventTitle
				end
				if embed.description ~= nil then
					embed.description = NAmanage.WebhookClampText(embed.description, 4096)
				end
				if embed.color == nil then
					embed.color = NAmanage.WebhookColorNumber(selectedColor, fallbackColor)
				end
				if options.includeTimestamp and embed.timestamp == nil then
					embed.timestamp = NAmanage.WebhookIsoTimestamp()
				end
				if options.footerText ~= "" and embed.footer == nil then
					embed.footer = { text = options.footerText:sub(1, 2048) }
				end
				if index == 1 and options.thumbnailUrl ~= "" and embed.thumbnail == nil then
					embed.thumbnail = { url = options.thumbnailUrl }
				end
				if index == 1 and options.imageUrl ~= "" and embed.image == nil then
					embed.image = { url = options.imageUrl }
				end
				if index == 1 and options.includeServerInfo then
					embed.fields = type(embed.fields) == "table" and embed.fields or {}
					local hasServerField = false
					for _, field in embed.fields do
						if type(field) == "table" and field.name == "Server" then
							hasServerField = true
							break
						end
					end
					if not hasServerField and #embed.fields < 25 then
						Insert(embed.fields, NAmanage.WebhookServerField())
					end
				end
			end
		end
	end
	return payload
end

NAmanage.GetIntegrationWebhookTargets = NAmanage.GetIntegrationWebhookTargets or function(kind, cfg)
	cfg = NAmanage.NormalizeWebhookConfig(cfg)
	const urlsCfg = cfg.urls or {}
	const dedupe = {}
	const targets = {}
	const function addUrl(url)
		if type(url) ~= "string" then return end
		const trimmed = NAmanage.WebhookTrim(url)
		if trimmed ~= "" and not dedupe[trimmed] then
			dedupe[trimmed] = true
			Insert(targets, trimmed)
		end
	end
	local kindKey = nil
	local fallbackUrl = NAmanage.WebhookTrim(urlsCfg.all) ~= "" and urlsCfg.all or cfg.url
	if kind == "join" or kind == "leave" or kind == "joinleave" then
		kindKey = "joinleave"
	elseif kind == "chat" then
		kindKey = "chat"
	elseif kind == "command" or kind == "commands" then
		kindKey = "commands"
	elseif kind == "main" or kind == "message" or kind == "msg" then
		kindKey = "main"
		if NAmanage.WebhookTrim(urlsCfg.main) ~= "" then
			fallbackUrl = urlsCfg.main
		end
	elseif urlsCfg.main and kind == nil then
		fallbackUrl = urlsCfg.main
	end
	if kindKey and urlsCfg[kindKey] then
		addUrl(urlsCfg[kindKey])
	end
	if kind == "test" then
		addUrl(urlsCfg.joinleave)
		addUrl(urlsCfg.chat)
		addUrl(urlsCfg.commands)
		addUrl(urlsCfg.main)
	end
	if cfg.useAll or #targets == 0 or kind == "test" then
		addUrl(fallbackUrl)
	end
	return targets
end

NAmanage.SendIntegrationWebhook=function(kind, content)
	local cfg = NAStuff.Integrations and NAStuff.Integrations.webhook
	cfg = NAmanage.NormalizeWebhookConfig(cfg)
	if not (cfg and content and content ~= "") then
		return false, "missing config"
	end
	if cfg.options.enabled == false then
		return false, "webhooks disabled"
	end
	const targets = NAmanage.GetIntegrationWebhookTargets(kind, cfg)
	if #targets == 0 then
		return false, "missing webhook url"
	end
	const now = tick()
	const minInt = NAmanage.clampNumber(cfg.minInterval, 0, 30, 2) or 2
	const cooldownKey = cfg.options.separateCooldowns and tostring(kind or "default") or "__all"
	const lastSent = tonumber(cfg.lastSentByKind[cooldownKey]) or (cooldownKey == "__all" and tonumber(cfg.lastSent) or 0) or 0
	if kind ~= "test" and minInt > 0 and (now - lastSent) < minInt then
		return false, Format("local cooldown (%.1fs remaining)", minInt - (now - lastSent))
	end
	const payloadData = NAmanage.BuildIntegrationWebhookPayload(kind, content)
	local okEncode, payload = pcall(Services.HttpService.JSONEncode, Services.HttpService, payloadData)
	if not okEncode then
		cfg.stats.failed += 1
		cfg.stats.lastError = tostring(payload)
		return false, "payload encode failed: "..tostring(payload)
	end
	local sentCount = 0
	local lastErr = nil
	local lastStatus = nil
	for _, url in targets do
		local ok, res, err = NAmanage.HttpPost(url, payload, {
			Headers = { ["Content-Type"] = "application/json" },
			timeout = 10,
			maxAttempts = 5,
			maxDelay = 120,
		})
		const status = NAmanage.HttpResponseStatus(res)
		lastStatus = status or lastStatus
		if ok and (status == nil or status < 400) then
			sentCount += 1
		else
			lastErr = err or (status and Format("HTTP %s", tostring(status))) or "request failed"
		end
	end
	cfg.stats.lastStatus = lastStatus
	if sentCount > 0 then
		cfg.lastSent = now
		cfg.lastSentByKind[cooldownKey] = now
		cfg.stats.sent += sentCount
		cfg.stats.lastSentAt = now
		cfg.stats.lastError = lastErr or ""
		if sentCount < #targets then
			cfg.stats.failed += (#targets - sentCount)
		end
		return true, nil, sentCount
	end
	cfg.stats.failed += math.max(1, #targets)
	cfg.stats.lastError = tostring(lastErr or "request failed")
	return false, lastErr
end

NAmanage.WebhookJoinLeave=function(plr, action)
	if NAStuff and NAStuff.StreamerModeEnabled == true then return end
	if NAStuff and NAStuff.teleportTransition == true then return end
	const cfg = NAStuff.Integrations and NAStuff.Integrations.webhook
	if not (cfg and cfg.enableJoinLeave) then return end
	const localPlr = Services.Players and Services.Players.LocalPlayer
	if localPlr and plr then
		if plr == localPlr then return end
		const lpId = tonumber(localPlr.UserId)
		const plrId = tonumber(plr.UserId)
		if lpId and plrId and lpId == plrId then return end
	end
	const username = nameChecker and nameChecker(plr) or (plr and plr.Name) or "Player"
	const kind = action == "leave" and "leave" or "join"
	const context = {
		player = username;
		display = plr and plr.DisplayName or username;
		userId = tostring(plr and plr.UserId or "");
		action = kind == "leave" and "left" or "joined";
	}
	const text = NAmanage.BuildWebhookEventText(kind, context)
	SpawnCall(function()
		pcall(NAmanage.SendIntegrationWebhook, kind, text)
	end)
end

NAmanage.WebhookChat=function(plr, msg)
	const cfg = NAStuff.Integrations and NAStuff.Integrations.webhook
	if not (cfg and cfg.enableChat) then return end
	const uname = (type(nameChecker) == "function" and nameChecker(plr)) or (plr and plr.Name) or "Player"
	const message = tostring(msg or ""):gsub("<br%s*/?>", " "):gsub("<[^>]+>", "")
	const text = NAmanage.BuildWebhookEventText("chat", {
		player = uname;
		display = plr and plr.DisplayName or uname;
		userId = tostring(plr and plr.UserId or "");
		message = message;
	})
	SpawnCall(function()
		pcall(NAmanage.SendIntegrationWebhook, "chat", text)
	end)
end

NAmanage.WebhookCommand=function(rawArgs)
	const cfg = NAStuff.Integrations and NAStuff.Integrations.webhook
	if not (cfg and cfg.enableCommands) then return end
	if type(rawArgs) ~= "table" or #rawArgs == 0 then return end
	const localPlayer = Services.Players and Services.Players.LocalPlayer
	const playerName = nameChecker and nameChecker(localPlayer) or (localPlayer and localPlayer.Name) or "LocalPlayer"
	const line = Concat(rawArgs, " ")
	const text = NAmanage.BuildWebhookEventText("command", {
		player = playerName;
		display = localPlayer and localPlayer.DisplayName or playerName;
		userId = tostring(localPlayer and localPlayer.UserId or "");
		command = line;
	})
	SpawnCall(function()
		pcall(NAmanage.SendIntegrationWebhook, "command", text)
	end)
end

NAmanage.HealthPing=function(url)
	if type(url) ~= "string" or url == "" then
		return false, "missing url"
	end
	const start = os.clock()
	local ok, _, err = NAmanage.HttpGet(url, { timeout = 5, maxAttempts = 3 })
	const elapsed = os.clock() - start
	if ok then
		return true, elapsed
	end
	return false, err or "error", elapsed
end

NAmanage.HealthPingAll=function()
	const eps = (NAStuff.Integrations and NAStuff.Integrations.health and NAStuff.Integrations.health.endpoints) or {}
	const results = {}
	for idx, url in eps do
		if url and url ~= "" then
			local ok, info, elapsed = NAmanage.HealthPing(url)
			if ok then
				Insert(results, Format("#%d OK (%.2fs)", idx, tonumber(info) or elapsed or 0))
			else
				const errText = tostring(info or "error")
				Insert(results, Format("#%d FAIL: %s", idx, errText))
			end
		end
	end
	return results
end

NAmanage.ComposeServerNote=function(note)
	const parts = {}
	const jobId = tostring(game.JobId or "")
	const placeId = tostring(game.PlaceId or "")
	Insert(parts, "PlaceId: "..placeId)
	if jobId and jobId ~= "" then
		Insert(parts, "JobId: "..jobId)
	end
	const serverCount = Services.Players and Services.Players.NumPlayers or nil
	if serverCount then
		const max = Services.Players.MaxPlayers or "?"
		Insert(parts, Format("Players: %s/%s", serverCount, max))
	end
	if note and note ~= "" then
		Insert(parts, "Note: "..note)
	end
	return Concat(parts, " | ")
end

NAmanage._loaderQueue = NAmanage._loaderQueue or {}
NAmanage._loaderQueueHead = tonumber(NAmanage._loaderQueueHead) or 1
NAmanage._loaderQueueTail = tonumber(NAmanage._loaderQueueTail) or 0
NAmanage._loaderQueueRunning = tonumber(NAmanage._loaderQueueRunning) or 0
NAmanage._loaderQueueHeavyRunning = tonumber(NAmanage._loaderQueueHeavyRunning) or 0
NAmanage._loaderQueuePumping = NAmanage._loaderQueuePumping == true

NAmanage._loaderQueueProfile = NAmanage._loaderQueueProfile or function()
	const configuredMax = tonumber(NAStuff and NAStuff.LoaderMaxConcurrency)
	const configuredHeavy = tonumber(NAStuff and NAStuff.LoaderMaxHeavyConcurrency)
	const configuredSpacing = tonumber(NAStuff and NAStuff.LoaderLaunchSpacing)
	const maxRunning = math.clamp(math.floor(configuredMax or 4), 1, 16)
	const maxHeavy = math.clamp(math.floor(configuredHeavy or 1), 1, maxRunning)
	const launchSpacing = math.max(0, configuredSpacing ~= nil and configuredSpacing or 0.01)
	return maxRunning, maxHeavy, launchSpacing
end

function NAmanage.pumpLoaderQueue()
	if NAStuff and NAStuff.StartupInitializersReady == false then
		return
	end
	if NAmanage._loaderQueuePumping then
		return
	end
	NAmanage._loaderQueuePumping = true
	Spawn(function()
		while NAmanage._loaderQueueHead <= NAmanage._loaderQueueTail do
			const maxRunning, maxHeavy, launchSpacing = NAmanage._loaderQueueProfile()
			const job = NAmanage._loaderQueue[NAmanage._loaderQueueHead]
			const heavy = job and job.heavy == true
			if (tonumber(NAmanage._loaderQueueRunning) or 0) >= maxRunning
				or (heavy and (tonumber(NAmanage._loaderQueueHeavyRunning) or 0) >= maxHeavy) then
				Wait()
				continue
			end
			NAmanage._loaderQueue[NAmanage._loaderQueueHead] = nil
			NAmanage._loaderQueueHead += 1
			if job and type(job.callback) == "function" then
				NAmanage._loaderQueueRunning = (tonumber(NAmanage._loaderQueueRunning) or 0) + 1
				if heavy then
					NAmanage._loaderQueueHeavyRunning = (tonumber(NAmanage._loaderQueueHeavyRunning) or 0) + 1
				end
				Spawn(function()
					pcall(NAmanage.runLoader, job.label, job.callback, job.opts)
					NAmanage._loaderQueueRunning = math.max(0, (tonumber(NAmanage._loaderQueueRunning) or 1) - 1)
					if heavy then
						NAmanage._loaderQueueHeavyRunning = math.max(0, (tonumber(NAmanage._loaderQueueHeavyRunning) or 1) - 1)
					end
				end)
				local spacing = tonumber(job.spacing)
				if spacing == nil then
					spacing = launchSpacing
				end
				if spacing > 0 then
					Wait(spacing)
				end
			end
		end
		while (tonumber(NAmanage._loaderQueueRunning) or 0) > 0 do
			Wait()
		end
		NAmanage._loaderQueue = {}
		NAmanage._loaderQueueHead = 1
		NAmanage._loaderQueueTail = 0
		NAmanage._loaderQueueHeavyRunning = 0
		NAmanage._loaderQueuePumping = false
	end)
end

function NAmanage.scheduleLoader(label, callback, opts)
	opts = opts or {}
	NAmanage._loaderQueueTail = (tonumber(NAmanage._loaderQueueTail) or 0) + 1
	NAmanage._loaderQueue[NAmanage._loaderQueueTail] = {
		label = label,
		callback = callback,
		opts = opts,
		spacing = opts.spacing,
		heavy = opts.heavy == true,
	}
	if not (NAStuff and NAStuff.StartupInitializersReady == false) then
		NAmanage.pumpLoaderQueue()
	end
end

NAmanage.spawnStartupLoader = NAmanage.spawnStartupLoader or function(label, callback, opts)
	if type(callback) ~= "function" then
		return nil
	end
	opts = opts or {}
	const name = tostring(label or callback)
	NAmanage._startupLoaderThreads = NAmanage._startupLoaderThreads or {}
	if NAmanage._startupLoaderThreads[name] == true and opts.allowDuplicate ~= true then
		return nil
	end
	NAmanage._startupLoaderThreads[name] = true
	return Spawn(function()
		const started = os.clock()
		pcall(function()
			const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
			if type(probe) == "table" and type(probe.mark) == "function" then
				probe.mark("loader_start:"..name)
			end
		end)
		local ok, err = pcall(callback)
		const perf = NAStuff and NAStuff.StartupPerformance
		if type(perf) == "table" and perf.finished ~= true then
			const tasks = type(perf.loaderTasks) == "table" and perf.loaderTasks or {}
			perf.loaderTasks = tasks
			if #tasks < 32 then
				tasks[#tasks + 1] = {
					name = name;
					elapsed = os.clock() - started;
					at = started - (tonumber(perf.started) or started);
				}
			end
		end
		if not ok then
			if NAmanage.loaderWarn then
				NAmanage.loaderWarn(name, tostring(err))
			else
				warn(err)
			end
		end
		pcall(function()
			const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
			if type(probe) == "table" and type(probe.mark) == "function" then
				probe.mark("loader_done:"..name)
			end
		end)
		NAmanage._startupLoaderThreads[name] = nil
	end)
end

searchIndex = {}
cmds = nil
defaultBarCommands = { "settings", "commands", "cmdloop", "adonisbypass", "discord" }
shouldShowDefaultAutofill = false
prevVisible, results = {}, {}
lastSearchText, gen = "", 0
searchInputTarget = nil
aliasExactCache, aliasPrefixCache = {}, {}
savedExactCache, savedPrefixCache = {}, {}
aliasOwnerByAlias, savedOwnerByAlias = {}, {}

NAmanage.defaultCommandMatches=function(entry, target)
	if not (entry and target) then
		return false
	end
	if entry.lowerName == target then
		return true
	end
	if entry.extraAliases then
		for _, alias in entry.extraAliases do
			if alias and Lower(alias) == target then
				return true
			end
		end
	end
	const baseLower = entry.name and Lower(entry.name) or nil
	if baseLower then
		const commandData = cmds.Commands[baseLower]
		const aliasData = cmds.Aliases[target]
		if commandData and aliasData and commandData == aliasData then
			return true
		end
		const savedAliasTarget = cmds.NASAVEDALIASES[target]
		if savedAliasTarget and Lower(savedAliasTarget) == baseLower then
			return true
		end
	end
	return false
end
NAImageAssets = {
	Icon = "NAnew.png";
	nilsongamer99 = "nilsongamer99.png";
	Sheet = "sheet.png";
	ShadeGradientFlipped = "shadeGradientFlipped.png";
	DotCrosshair = "DotCrosshair.png";
	Inlet = "Inlet.png";
	Stud = "oldStud.png";
	bk = "SkyBk.png";
	dn = "SkyDn.png";
	ft = "SkyFt.png";
	lf = "SkyLf.png";
	rt = "SkyRt.png";
	up = "SkyUp.png";
	ResizeVertical = "Vertical16x16.png";
	ResizeHorizontal = "Horizontal16x16.png";
	ResizeDiagonal1 = "Diagonal116x16.png";
	ResizeDiagonal2 = "Diagonal216x16.png";
}
NAStuff._rf = NAStuff._rf or readfile
NAStuff._wf = NAStuff._wf or writefile
NAStuff._iff = NAStuff._iff or isfile
NAStuff._df = NAStuff._df or delfile

NAStuff.dotBad = NAStuff.dotBad or false

NAmanage.stripExt=function(p)
	if type(p) ~= "string" then
		return p
	end
	return (p:gsub("([^/]+)%.[^/]+$", "%1"))
end

NAmanage.isInvalidPathErr=function(e)
	return type(e) == "string" and e:find("Invalid path", 1, true) ~= nil
end

if type(NAStuff._wf) == "function" then
	_na_env.writefile = function(p, data, ...)
		if type(p) ~= "string" then
			return NAStuff._wf(p, data, ...)
		end

		const pNoExt = NAmanage.stripExt(p)
		local ok, err = pcall(NAStuff._wf, p, data, ...)
		if ok then
			NAStuff.dotBad = false
			return
		end

		if pNoExt ~= p and NAmanage.isInvalidPathErr(err) then
			local ok2, err2 = pcall(NAStuff._wf, pNoExt, data, ...)
			if ok2 then
				NAStuff.dotBad = true
				return
			end
			error(err2 or err)
		end

		error(err)
	end
end

if type(NAStuff._rf) == "function" then
	_na_env.readfile = function(p, ...)
		if type(p) ~= "string" then
			return NAStuff._rf(p, ...)
		end

		const pNoExt = NAmanage.stripExt(p)
		local ok, res = pcall(NAStuff._rf, p, ...)
		if ok and res ~= nil then
			NAStuff.dotBad = false
			return res
		end

		if pNoExt ~= p then
			local ok2, res2 = pcall(NAStuff._rf, pNoExt, ...)
			if ok2 then
				NAStuff.dotBad = true
				return res2
			end
		end

		return nil
	end
end

if type(NAStuff._iff) == "function" then
	_na_env.isfile = function(p, ...)
		if type(p) ~= "string" then
			local ok, res = pcall(NAStuff._iff, p, ...)
			return ok and res or false
		end

		const pNoExt = NAmanage.stripExt(p)

		local ok, res = pcall(NAStuff._iff, p, ...)
		if ok and res then
			return true
		end

		if pNoExt ~= p then
			local ok2, res2 = pcall(NAStuff._iff, pNoExt, ...)
			if ok2 and res2 then
				NAStuff.dotBad = true
				return true
			end
		end

		return false
	end
end

if type(NAStuff._df) == "function" then
	_na_env.delfile = function(p, ...)
		if type(p) ~= "string" then
			return NAStuff._df(p, ...)
		end

		const pNoExt = NAmanage.stripExt(p)

		local ok, err = pcall(NAStuff._df, p, ...)
		if ok then
			NAStuff.dotBad = false
			return
		end

		if pNoExt ~= p and NAmanage.isInvalidPathErr(err) then
			local ok2, err2 = pcall(NAStuff._df, pNoExt, ...)
			if ok2 then
				NAStuff.dotBad = true
				return
			end
			error(err2 or err)
		end

		error(err)
	end
end
NAfiles = {
	NAFILEPATH = "Nameless-Admin";
	NANOMEDIAPATH = "Nameless-Admin/.nomedia";
	NAWAYPOINTFILEPATH = "Nameless-Admin/Waypoints";
	NAPLUGINFILEPATH = "Nameless-Admin/Plugins";
	NAIYPLUGINFILEPATH = "Nameless-Admin/PluginsIY";
	NAASSETSFILEPATH = "Nameless-Admin/Assets";
	NASCRIPTIMAGEPATH = "Nameless-Admin/ScriptImages";
	NAMAINSETTINGSPATH = "Nameless-Admin/Settings.json";
	NAPREFIXPATH = "Nameless-Admin/Prefix.txt";
	NABUTTONSIZEPATH = "Nameless-Admin/ButtonSize.txt";
	NAUISIZEPATH = "Nameless-Admin/UIScale.txt";
	NAQOTPATH = "Nameless-Admin/QueueOnTeleport.txt";
	NAALIASPATH = "Nameless-Admin/Aliases.json";
	NAUSERBUTTONSPATH = "Nameless-Admin/UserButtons.json";
	NAAUTOEXECPATH = "Nameless-Admin/AutoExecCommands.json";
	NAPREDICTIONPATH = "Nameless-Admin/Prediction.txt";
	NASTROKETHINGY = "Nameless-Admin/NAUIStroker.txt";
	NAJOINLEAVE = "Nameless-Admin/JoinLeave.json";
	NAJOINLEAVELOG = "Nameless-Admin/JoinLeaveLog.txt";
	NACHATLOGS = "Nameless-Admin/ChatLogs.txt";
	NATOPBAR = "Nameless-Admin/TopBarApp.txt";
	NANOTIFSTOGGLE = "Nameless-Admin/NotifsTgl.txt";
	NABINDERS = "Nameless-Admin/Binders.json";
	NAESPSETTINGSPATH = "Nameless-Admin/ESPSettings.json";
	NATOPBARMODE = "Nameless-Admin/TopbarMode.txt";
	NATEXTCHATSETTINGSPATH = "Nameless-Admin/TextChatSettings.json";
	NACUSTOMFONTPATH = "Nameless-Admin/CustomFont";
	NACUSTOMICONPATH = "Nameless-Admin/CustomIcon";
	NAWINDOWBACKGROUNDPATH = "Nameless-Admin/WindowBackgrounds";
	NACOMMANDKEYBINDS = "Nameless-Admin/CommandKeybinds.json";
	NANOTEPADPATH = "Nameless-Admin/NA-Notepad";
	NAFLYBINDSPATH = "Nameless-Admin/FlyBinds.json";
	NAFFLAGSPATH = "Nameless-Admin/NAFFlags.json";
	NAFFLAGSCONFIGPATH = "Nameless-Admin/NAFFlagsConfig.json";
}

NAmanage.isFileAccessErr=NAmanage.isFileAccessErr or function(err)
	const msg = Lower(tostring(err or ""))
	return msg:find("access is denied", 1, true) ~= nil
		or msg:find("permission denied", 1, true) ~= nil
		or msg:find("unauthorized", 1, true) ~= nil
		or msg:find("operation not permitted", 1, true) ~= nil
		or msg:find("create_directories", 1, true) ~= nil
end

NAmanage.noteFileWriteIssue=NAmanage.noteFileWriteIssue or function(op, path, err)
	NAStuff.FileWriteBlocked = true
	if not NAStuff.FileWriteIssue then
		NAStuff.FileWriteIssue = {
			op = tostring(op or "write");
			path = tostring(path or "");
			err = tostring(err or "unknown error");
		}
		warn(Format("[NA] File storage unavailable during %s for %s: %s", NAStuff.FileWriteIssue.op, NAStuff.FileWriteIssue.path, NAStuff.FileWriteIssue.err))
	end
	if type(NAmanage.NotifyFileWriteIssue) == "function" then
		NAmanage.NotifyFileWriteIssue()
	end
	return false, err
end

NAmanage.NotifyFileWriteIssue=NAmanage.NotifyFileWriteIssue or function()
	if NAStuff.FileWriteIssueNotified or not NAStuff.FileWriteIssue then
		return
	end
	if type(DoNotif) ~= "function" then
		return
	end
	NAStuff.FileWriteIssueNotified = true
	const issue = NAStuff.FileWriteIssue
	const pathText = issue.path ~= "" and issue.path or "Nameless-Admin"
	DoNotif("Couldn't write to executor workspace ("..pathText.."). NA will keep loading, but settings/saved data won't persist until the folder is writable or the executor is run as admin.", 9, "File Access")
end

NAmanage.safeIsFolder=NAmanage.safeIsFolder or function(path)
	if type(isfolder) ~= "function" or type(path) ~= "string" then
		return false
	end
	local ok, res = pcall(isfolder, path)
	if ok then
		return res == true
	end
	if NAmanage.isFileAccessErr(res) then
		NAmanage.noteFileWriteIssue("check folder", path, res)
	end
	return false
end

NAmanage.safeIsFile=NAmanage.safeIsFile or function(path)
	if type(isfile) ~= "function" or type(path) ~= "string" then
		return false
	end
	local ok, res = pcall(isfile, path)
	if ok then
		return res == true
	end
	if NAmanage.isFileAccessErr(res) then
		NAmanage.noteFileWriteIssue("check file", path, res)
	end
	return false
end

NAmanage.safeMakeFolder=NAmanage.safeMakeFolder or function(path)
	if not (FileSupport and type(path) == "string" and path ~= "") then
		return false, "no file support or invalid path"
	end
	if NAmanage.safeIsFolder(path) then
		return true
	end
	if type(makefolder) ~= "function" then
		return false, "makefolder missing"
	end
	local ok, err = pcall(makefolder, path)
	if ok then
		return true
	end
	if NAmanage.stripExt then
		const alt = NAmanage.stripExt(path)
		if alt ~= path then
			local okAlt, errAlt = pcall(makefolder, alt)
			if okAlt then
				return true
			end
			err = errAlt or err
		end
	end
	if NAmanage.isFileAccessErr(err) then
		return NAmanage.noteFileWriteIssue("create folder", path, err)
	end
	return false, err
end

NAmanage.safeWriteFile=NAmanage.safeWriteFile or function(path, data)
	if not (FileSupport and type(writefile) == "function" and type(path) == "string") then
		return false, "no file support or invalid path"
	end
	if NAStuff.FileWriteBlocked then
		const issue = NAStuff.FileWriteIssue
		return false, issue and issue.err or "file writes blocked"
	end
	local ok, err = pcall(writefile, path, data)
	if ok then
		return true
	end
	if NAmanage.isFileAccessErr(err) then
		return NAmanage.noteFileWriteIssue("write file", path, err)
	end
	return false, err
end

NAmanage.safeDeleteFile=NAmanage.safeDeleteFile or function(path)
	if not (FileSupport and type(delfile) == "function" and type(path) == "string") then
		return false, "no file support or invalid path"
	end
	if NAStuff.FileWriteBlocked then
		const issue = NAStuff.FileWriteIssue
		return false, issue and issue.err or "file writes blocked"
	end
	local ok, err = pcall(delfile, path)
	if ok then
		return true
	end
	if NAmanage.isFileAccessErr(err) then
		return NAmanage.noteFileWriteIssue("delete file", path, err)
	end
	return false, err
end

NAmanage._jsonSafeState = type(NAmanage._jsonSafeState) == "table" and NAmanage._jsonSafeState or {
	read = {};
	decode = {};
	candidates = {};
}

NAmanage.safeReadFile=NAmanage.safeReadFile or function(path)
	if not (FileSupport and type(readfile) == "function" and type(path) == "string") then
		return false, nil, "no file support or invalid path"
	end
	NAmanage._jsonSafeState.read.ok, NAmanage._jsonSafeState.read.data = pcall(readfile, path)
	if NAmanage._jsonSafeState.read.ok and type(NAmanage._jsonSafeState.read.data) == "string" then
		return true, NAmanage._jsonSafeState.read.data
	end
	if NAmanage.isFileAccessErr(NAmanage._jsonSafeState.read.data) then
		NAmanage.noteFileWriteIssue("read file", path, NAmanage._jsonSafeState.read.data)
	end
	return false, nil, NAmanage._jsonSafeState.read.data
end

NAmanage.safeJsonDecode=NAmanage.safeJsonDecode or function(raw)
	if type(raw) ~= "string" or raw == "" then
		return false, nil, "empty json"
	end
	NAmanage._jsonSafeState.decode.ok, NAmanage._jsonSafeState.decode.value = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if NAmanage._jsonSafeState.decode.ok and type(NAmanage._jsonSafeState.decode.value) == "table" then
		return true, NAmanage._jsonSafeState.decode.value
	end
	return false, nil, NAmanage._jsonSafeState.decode.value or "invalid json"
end
