NAmanage.safeReadJsonFileWithRecovery=NAmanage.safeReadJsonFileWithRecovery or function(path, opts)
	opts = type(opts) == "table" and opts or {}
	if not (FileSupport and type(path) == "string" and path ~= "") then
		return false, nil, "no file support or invalid path"
	end

	NAmanage._jsonSafeState.candidates[1] = path
	for i = 2, #NAmanage._jsonSafeState.candidates do
		NAmanage._jsonSafeState.candidates[i] = nil
	end
	if opts.tempPath ~= false then
		NAmanage._jsonSafeState.candidates[#NAmanage._jsonSafeState.candidates + 1] = type(opts.tempPath) == "string" and opts.tempPath or (path..".tmp")
	end
	if opts.backupPath ~= false then
		NAmanage._jsonSafeState.candidates[#NAmanage._jsonSafeState.candidates + 1] = type(opts.backupPath) == "string" and opts.backupPath or (path..".bak")
	end

	NAmanage._jsonSafeState.firstErr = "file missing"
	for _, candidate in NAmanage._jsonSafeState.candidates do
		if type(candidate) == "string" and candidate ~= "" and NAmanage.safeIsFile(candidate) then
			NAmanage._jsonSafeState.okRead, NAmanage._jsonSafeState.raw, NAmanage._jsonSafeState.readErr = NAmanage.safeReadFile(candidate)
			if NAmanage._jsonSafeState.okRead then
				NAmanage._jsonSafeState.okDecode, NAmanage._jsonSafeState.decoded, NAmanage._jsonSafeState.decodeErr = NAmanage.safeJsonDecode(NAmanage._jsonSafeState.raw)
				if NAmanage._jsonSafeState.okDecode then
					if candidate ~= path then
						NAmanage.safeWriteFile(path, NAmanage._jsonSafeState.raw)
					end
					return true, NAmanage._jsonSafeState.decoded, candidate
				end
				NAmanage._jsonSafeState.firstErr = NAmanage._jsonSafeState.decodeErr
			else
				NAmanage._jsonSafeState.firstErr = NAmanage._jsonSafeState.readErr
			end
		end
	end

	return false, nil, NAmanage._jsonSafeState.firstErr
end

NAmanage.safeWriteJsonFileWithRecovery=NAmanage.safeWriteJsonFileWithRecovery or function(path, data, opts)
	opts = type(opts) == "table" and opts or {}
	if not (FileSupport and type(path) == "string" and path ~= "" and type(data) == "string") then
		return false, "no file support or invalid path"
	end

	NAmanage._jsonSafeState.okNew, NAmanage._jsonSafeState.decodedNew, NAmanage._jsonSafeState.newErr = NAmanage.safeJsonDecode(data)
	if not NAmanage._jsonSafeState.okNew then
		return false, "refusing to write invalid json: "..tostring(NAmanage._jsonSafeState.newErr)
	end

	NAmanage._jsonSafeState.tempPath = type(opts.tempPath) == "string" and opts.tempPath or (path..".tmp")
	NAmanage._jsonSafeState.backupPath = type(opts.backupPath) == "string" and opts.backupPath or (path..".bak")

	if NAmanage.safeIsFile(path) then
		NAmanage._jsonSafeState.okOldRead, NAmanage._jsonSafeState.oldRaw = NAmanage.safeReadFile(path)
		if NAmanage._jsonSafeState.okOldRead then
			NAmanage._jsonSafeState.okOldJson = NAmanage.safeJsonDecode(NAmanage._jsonSafeState.oldRaw)
			if NAmanage._jsonSafeState.okOldJson then
				NAmanage.safeWriteFile(NAmanage._jsonSafeState.backupPath, NAmanage._jsonSafeState.oldRaw)
			end
		end
	end

	NAmanage._jsonSafeState.okTemp, NAmanage._jsonSafeState.tempErr = NAmanage.safeWriteFile(NAmanage._jsonSafeState.tempPath, data)
	if not NAmanage._jsonSafeState.okTemp then
		return false, NAmanage._jsonSafeState.tempErr
	end

	NAmanage._jsonSafeState.okTempRead, NAmanage._jsonSafeState.tempRaw, NAmanage._jsonSafeState.tempReadErr = NAmanage.safeReadFile(NAmanage._jsonSafeState.tempPath)
	if not NAmanage._jsonSafeState.okTempRead or NAmanage._jsonSafeState.tempRaw ~= data then
		NAmanage.safeDeleteFile(NAmanage._jsonSafeState.tempPath)
		return false, NAmanage._jsonSafeState.tempReadErr or "temp write verification failed"
	end

	NAmanage._jsonSafeState.okMain, NAmanage._jsonSafeState.mainErr = NAmanage.safeWriteFile(path, NAmanage._jsonSafeState.tempRaw)
	if not NAmanage._jsonSafeState.okMain then
		return false, NAmanage._jsonSafeState.mainErr
	end

	NAmanage._jsonSafeState.okVerify, NAmanage._jsonSafeState.verifyRaw, NAmanage._jsonSafeState.verifyErr = NAmanage.safeReadFile(path)
	if not NAmanage._jsonSafeState.okVerify or NAmanage._jsonSafeState.verifyRaw ~= NAmanage._jsonSafeState.tempRaw then
		NAmanage._jsonSafeState.okBackup, NAmanage._jsonSafeState.backupRaw = NAmanage.safeReadFile(NAmanage._jsonSafeState.backupPath)
		if NAmanage._jsonSafeState.okBackup then
			NAmanage.safeWriteFile(path, NAmanage._jsonSafeState.backupRaw)
		end
		return false, NAmanage._jsonSafeState.verifyErr or "main write verification failed"
	end

	NAmanage.safeDeleteFile(NAmanage._jsonSafeState.tempPath)
	return true
end

NAmanage.getNAImageFileName = NAmanage.getNAImageFileName or function(keyOrFile)
	if type(keyOrFile) ~= "string" or keyOrFile == "" then
		return nil
	end
	if type(NAImageAssets) == "table" and type(NAImageAssets[keyOrFile]) == "string" then
		return NAImageAssets[keyOrFile]
	end
	return keyOrFile
end

NAmanage.getNAImageAssetSourceUrl = NAmanage.getNAImageAssetSourceUrl or function(keyOrFile)
	const fileName = NAmanage.getNAImageFileName(keyOrFile)
	if type(fileName) ~= "string" or fileName == "" then
		return nil
	end
	return "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NAimages/"..fileName
end

NAmanage.getNAImageAssetCandidatePaths = NAmanage.getNAImageAssetCandidatePaths or function(keyOrFile)
	const fileName = NAmanage.getNAImageFileName(keyOrFile)
	if type(fileName) ~= "string" or fileName == "" then
		return {}
	end
	if not (NAfiles and type(NAfiles.NAASSETSFILEPATH) == "string" and NAfiles.NAASSETSFILEPATH ~= "") then
		return {}
	end
	return { NAfiles.NAASSETSFILEPATH.."/"..fileName }
end

NAmanage.getNAImageAssetPath = NAmanage.getNAImageAssetPath or function(keyOrFile, opts)
	opts = type(opts) == "table" and opts or {}
	const candidates = NAmanage.getNAImageAssetCandidatePaths(keyOrFile)
	if #candidates == 0 then
		return nil
	end
	if opts.preferredOnly or type(isfile) ~= "function" then
		return candidates[1]
	end
	for _, path in candidates do
		local okEx, exists = pcall(isfile, path)
		if okEx and exists then
			return path
		end
	end
	return candidates[1]
end

NAmanage.getNAImageAsset = NAmanage.getNAImageAsset or function(keyOrFile, fallback)
	if type(getcustomasset) ~= "function" then
		return fallback
	end
	const candidates = NAmanage.getNAImageAssetCandidatePaths(keyOrFile)
	for _, path in candidates do
		local okAsset, asset = pcall(getcustomasset, path)
		if okAsset and type(asset) == "string" and asset ~= "" then
			return asset
		end
	end
	return fallback
end

NAmanage.initUIEditors=function(coreGui, HUI)
	if not (coreGui and NAgui) then
		return
	end

	const function weakKeyMap()
		return setmetatable({}, {
			__mode = "k",
		})
	end

	const CE = {
		path = NAfiles.NAFILEPATH.."/corner_editor.json",
		default = {
			enabled = false,
			radius = 10,
			targetCoreGui = true,
			targetPlayerGui = false,
			targetBillboardGui = false,
			targetSurfaceGui = false,
			targetHiddenUi = false,
		},
		cg = coreGui,
		store = weakKeyMap(),
		watchers = weakKeyMap(),
		guiRootWatchers = weakKeyMap(),
		guiRootSeen = weakKeyMap(),
		restoring = false,
	}

	const data = {
		enabled = CE.default.enabled,
		radius = CE.default.radius,
		targetCoreGui = CE.default.targetCoreGui,
		targetPlayerGui = CE.default.targetPlayerGui,
		targetBillboardGui = CE.default.targetBillboardGui,
		targetSurfaceGui = CE.default.targetSurfaceGui,
		targetHiddenUi = CE.default.targetHiddenUi,
	}
	if FileSupport then
		if not NAmanage.safeIsFile(CE.path) then
			NAmanage.safeWriteFile(CE.path, Services.HttpService:JSONEncode(CE.default))
		end
		local okRead, raw = pcall(readfile, CE.path)
		if okRead and type(raw) == "string" then
			local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
			if okDecode and type(decoded) == "table" then
				data.enabled = decoded.enabled == true
				const parsedRadius = tonumber(decoded.radius)
				if parsedRadius then
					data.radius = parsedRadius
				end
				if type(decoded.targetCoreGui) == "boolean" then
					data.targetCoreGui = decoded.targetCoreGui
				end
				if type(decoded.targetPlayerGui) == "boolean" then
					data.targetPlayerGui = decoded.targetPlayerGui
				end
				if type(decoded.targetBillboardGui) == "boolean" then
					data.targetBillboardGui = decoded.targetBillboardGui
				end
				if type(decoded.targetSurfaceGui) == "boolean" then
					data.targetSurfaceGui = decoded.targetSurfaceGui
				end
				if type(decoded.targetHiddenUi) == "boolean" then
					data.targetHiddenUi = decoded.targetHiddenUi
				end
			end
		end
	end
	data.radius = math.clamp(data.radius, 0, 64)
	CE.data = data

	local uiScanJobs = {}
	local uiScanJobKeys = {}
	local uiScanHead = 1
	local uiScanTail = 0
	local uiScanning = false

	const function queueUIScan(root, fn, opts)
		if not root or not fn then
			return
		end
		opts = opts or {}
		const guard = type(opts.guard) == "function" and opts.guard or nil
		const skipChildren = type(opts.skipChildren) == "function" and opts.skipChildren or nil
		local key = opts.key
		if key ~= nil then
			key = tostring(key)
			if uiScanJobKeys[key] then
				return
			end
		end

		uiScanTail += 1
		const job = {
			fn = fn,
			guard = guard,
			skipChildren = skipChildren,
			key = key,
			q = { root },
			qi = 1,
			qn = 1,
		}
		uiScanJobs[uiScanTail] = job
		if key then
			uiScanJobKeys[key] = job
		end

		if uiScanning then
			return
		end
		uiScanning = true

		Spawn(function()
			const function finishJob(jobToClear)
				if jobToClear and jobToClear.key then
					uiScanJobKeys[jobToClear.key] = nil
				end
				if jobToClear and type(jobToClear.q) == "table" then
					for i = jobToClear.qi or 1, jobToClear.qn or #jobToClear.q do
						jobToClear.q[i] = nil
					end
				end
			end

			while uiScanHead <= uiScanTail do
				local budget, waitDelay = NAmanage._evtHubBudget(8, {
					delay = 0,
					ldSc = 0.25,
					ldDel = 0.012,
				})

				while budget > 0 and uiScanHead <= uiScanTail do
					const job = uiScanJobs[uiScanHead]
					if not job then
						uiScanHead += 1
						continue
					end
					const jobGuard = job.guard
					if jobGuard and not jobGuard() then
						finishJob(job)
						uiScanJobs[uiScanHead] = nil
						uiScanHead += 1
						continue
					end
					const q = job.q
					const qi = job.qi
					local qn = job.qn
					const jobFn = job.fn
					const jobSkipChildren = job.skipChildren

					if qi > qn then
						finishJob(job)
						uiScanJobs[uiScanHead] = nil
						uiScanHead += 1
					else
						const inst = q[qi]
						q[qi] = nil
						job.qi = qi + 1

						if jobGuard and not jobGuard() then
							finishJob(job)
							uiScanJobs[uiScanHead] = nil
							uiScanHead += 1
							continue
						end
						if inst and inst.Parent then
							pcall(jobFn, inst)

							local shouldSkipChildren = false
							if jobSkipChildren then
								local okSkip, skipResult = pcall(jobSkipChildren, inst)
								shouldSkipChildren = okSkip and skipResult == true
							end
							if not shouldSkipChildren then
								local okChildren, ch = pcall(function()
									return inst:GetChildren()
								end)
								if okChildren and type(ch) == "table" then
									for i = 1, #ch do
										qn += 1
										q[qn] = ch[i]
									end
									job.qn = qn
								end
							end
						end

						budget -= 1
					end
				end

				if waitDelay > 0 then
					Wait(waitDelay)
				else
					Wait()
				end
			end

			uiScanJobs = {}
			uiScanJobKeys = {}
			uiScanHead = 1
			uiScanTail = 0
			uiScanning = false
		end)
	end

	const function isInsideHiddenUiRoot(inst)
		if not (HUI and inst) then
			return false
		end
		if inst == HUI then
			return true
		end
		local ok, result = pcall(inst.IsDescendantOf, inst, HUI)
		return ok and result == true
	end

	const function getPlayerGui()
		const lp = Services.Players and Services.Players.LocalPlayer
		if not lp then
			return nil
		end
		return lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
	end

	const function getCRad()
		return UDim.new(0, math.clamp(tonumber(CE.data.radius) or CE.default.radius, 0, 64))
	end

	const function isRobloxTopbarEditorTarget(o)
		const topbarEditor = NAmanage and NAmanage.RobloxTopbarEditor
		if not ((topbarEditor and topbarEditor.enabled) or (NAStuff and NAStuff.RobloxTopbarEditorEnabled == true)) then
			return false
		end
		const coreGui = CE.cg
		const topbarRoot = coreGui and coreGui:FindFirstChild("TopBarApp")
		return topbarRoot ~= nil and o:IsDescendantOf(topbarRoot)
	end

	const function isCTgt(o)
		if not (o and o:IsA("UICorner")) then
			return false
		end
		if isRobloxTopbarEditorTarget(o) then
			return false
		end
		if HUI and o:IsDescendantOf(HUI) and not CE.data.targetHiddenUi then
			return false
		end
		if CE.data.targetHiddenUi and HUI and o:IsDescendantOf(HUI) then
			return true
		end
		if CE.data.targetCoreGui and CE.cg and o:IsDescendantOf(CE.cg) then
			return true
		end
		if CE.data.targetPlayerGui then
			const pg = getPlayerGui()
			if pg and o:IsDescendantOf(pg) then
				return true
			end
		end
		if CE.data.targetBillboardGui then
			local ok, bb = pcall(function()
				return o:FindFirstAncestorOfClass("BillboardGui")
			end)
			if ok and bb then
				return true
			end
		end
		if CE.data.targetSurfaceGui then
			local ok, sg = pcall(function()
				return o:FindFirstAncestorOfClass("SurfaceGui")
			end)
			if ok and sg then
				return true
			end
		end
		return false
	end

	const function getCTgts()
		const containers = {}
		if CE.data.targetCoreGui and CE.cg then
			containers[#containers + 1] = CE.cg
		end
		if CE.data.targetPlayerGui then
			const pg = getPlayerGui()
			if pg then
				containers[#containers + 1] = pg
			end
		end
		if CE.data.targetHiddenUi and HUI then
			containers[#containers + 1] = HUI
		end
		return containers
	end

	const function getCBB(o)
		if not (CE.data.targetBillboardGui and typeof(o) == "Instance") then
			return nil
		end
		if o:IsA("BillboardGui") then
			return o
		end
		local ok, ancestor = pcall(function()
			return o:FindFirstAncestorOfClass("BillboardGui")
		end)
		if ok then
			return ancestor
		end
		return nil
	end

	const function getCSurf(o)
		if not (CE.data.targetSurfaceGui and typeof(o) == "Instance") then
			return nil
		end
		if o:IsA("SurfaceGui") then
			return o
		end
		local ok, ancestor = pcall(function()
			return o:FindFirstAncestorOfClass("SurfaceGui")
		end)
		if ok then
			return ancestor
		end
		return nil
	end

	const function stopCWat(target)
		const watcher = CE.watchers[target]
		if not watcher then
			return
		end
		if watcher.change then
			pcall(function()
				watcher.change:Disconnect()
			end)
		end
		if watcher.ancestry then
			pcall(function()
				watcher.ancestry:Disconnect()
			end)
		end
		CE.watchers[target] = nil
	end

	const function setCWat(target)
		if not target or CE.watchers[target] then
			return
		end
		const watcher = {}
		watcher.change = target:GetPropertyChangedSignal("CornerRadius"):Connect(function()
			if CE.restoring or not CE.data.enabled or not isCTgt(target) then
				return
			end
			const desired = getCRad()
			if target.CornerRadius ~= desired then
				pcall(function()
					target.CornerRadius = desired
				end)
			end
		end)
		watcher.ancestry = target.AncestryChanged:Connect(function(obj)
			if not obj.Parent then
				stopCWat(obj)
				CE.store[obj] = nil
			end
		end)
		CE.watchers[target] = watcher
	end

	const function setCorner(o)
		if not CE.data.enabled then
			return
		end
		if not isCTgt(o) then
			return
		end
		local info = CE.store[o]
		if not info then
			info = { original = o.CornerRadius }
			CE.store[o] = info
		end
		const radius = getCRad()
		if o.CornerRadius ~= radius then
			o.CornerRadius = radius
		end
		setCWat(o)
	end

	local cornerApplyQueue = {}
	local cornerApplySet = weakKeyMap()
	local cornerApplyHead = 1
	local cornerApplyTail = 0
	local cornerApplyBusy = false
	local cornerApplyToken = 0

	const function queueCornerApply(o)
		if not (CE.data.enabled and o and o.Parent and o:IsA("UICorner")) then
			return
		end
		if cornerApplySet[o] then
			return
		end
		cornerApplySet[o] = true
		cornerApplyTail += 1
		cornerApplyQueue[cornerApplyTail] = o
		if cornerApplyTail - cornerApplyHead > 2048 then
			cornerApplyQueue = {}
			cornerApplySet = weakKeyMap()
			cornerApplyHead = 1
			cornerApplyTail = 0
			cornerApplyBusy = false
			return
		end
		if cornerApplyBusy then
			return
		end
		cornerApplyBusy = true
		cornerApplyToken += 1
		const token = cornerApplyToken
		Spawn(function()
			while cornerApplyToken == token and cornerApplyHead <= cornerApplyTail do
				local budget, waitDelay = NAmanage._evtHubBudget(8, {
					delay = 0,
					ldSc = 0.25,
					ldDel = 0.012,
				})
				while budget > 0 and cornerApplyToken == token and cornerApplyHead <= cornerApplyTail do
					const inst = cornerApplyQueue[cornerApplyHead]
					cornerApplyQueue[cornerApplyHead] = nil
					cornerApplyHead += 1
					if inst then
						cornerApplySet[inst] = nil
						if inst.Parent and CE.data.enabled then
							setCorner(inst)
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
			if cornerApplyToken == token then
				cornerApplyQueue = {}
				cornerApplySet = weakKeyMap()
				cornerApplyHead = 1
				cornerApplyTail = 0
				cornerApplyBusy = false
			end
		end)
	end

	const function clearGuiRootWatchers()
		const pending = {}
		for root, conns in CE.guiRootWatchers do
			pending[#pending + 1] = { root = root, conns = conns }
		end
		for i = 1, #pending do
			const conns = pending[i].conns
			if type(conns) == "table" then
				if conns.desc then pcall(function() conns.desc:Disconnect() end) end
				if conns.anc then pcall(function() conns.anc:Disconnect() end) end
			end
		end
		CE.guiRootWatchers = weakKeyMap()
		CE.guiRootSeen = weakKeyMap()
	end

	const function resetCorn()
		CE.restoring = true
		const stored = {}
		const watched = {}
		for corner, info in CE.store do
			stored[#stored + 1] = { corner = corner, info = info }
		end
		for corner in CE.watchers do
			watched[#watched + 1] = corner
		end
		for i = 1, #watched do
			stopCWat(watched[i])
		end
		for i = 1, #stored do
			const corner = stored[i].corner
			const info = stored[i].info
			if corner and info and info.original ~= nil then
				pcall(function()
					corner.CornerRadius = info.original
				end)
			end
		end
		CE.restoring = false
		CE.store = weakKeyMap()
		CE.watchers = weakKeyMap()
		cornerApplyToken += 1
		cornerApplyQueue = {}
		cornerApplySet = weakKeyMap()
		cornerApplyHead = 1
		cornerApplyTail = 0
		cornerApplyBusy = false
		clearGuiRootWatchers()
	end

	NAmanage.CornerEditorUnload = function()
		CE.data.enabled = false
		NAlib.disconnect("CornerEditor")
		NAlib.disconnect("CornerEditor_PlayerGui")
		NAlib.disconnect("CornerEditor_HUI")
		NAlib.disconnect("CornerEditor_Billboard")
		NAlib.disconnect("CornerEditor_Surface")
		NAlib.disconnect("CornerEditor_PlayerGuiAdded")
		NAlib.disconnect("CornerEditor_PlayerGuiRemoved")
		resetCorn()
	end

	const function applyCornersIn(container)
		if not container then
			return
		end
		queueUIScan(container, function(inst)
			if inst:IsA("UICorner") then
				queueCornerApply(inst)
			end
		end, {
			key = "corner-container:"..tostring(container),
			guard = function()
				return CE.data.enabled
			end,
			skipChildren = function(inst)
				return container == CE.cg and HUI and inst == HUI
			end,
		})
	end

	local watchGuiRoot

	const function applyCorn()
		if not CE.data.enabled then
			return
		end

		for _, container in getCTgts() do
			applyCornersIn(container)
		end

		const world = Services.Workspace
		if not world then
			return
		end

		if CE.data.targetBillboardGui or CE.data.targetSurfaceGui then
			queueUIScan(world, function(inst)
				if CE.data.targetBillboardGui and inst:IsA("BillboardGui") then
					CE.guiRootSeen[inst] = true
					applyCornersIn(inst)
					watchGuiRoot(inst)
				elseif CE.data.targetSurfaceGui and inst:IsA("SurfaceGui") then
					CE.guiRootSeen[inst] = true
					applyCornersIn(inst)
					watchGuiRoot(inst)
				end
			end, {
				key = "corner-world",
				guard = function()
					return CE.data.enabled and (CE.data.targetBillboardGui or CE.data.targetSurfaceGui)
				end,
			})
		end
	end
	local cornerSaveSeq = 0
	const function saveCData(opts)
		if not FileSupport then
			return
		end
		opts = opts or {}
		cornerSaveSeq += 1
		const seq = cornerSaveSeq
		const function writeCornerData()
			pcall(function()
				NAmanage.safeWriteFile(CE.path, Services.HttpService:JSONEncode(CE.data))
			end)
		end
		if opts.immediate == true then
			writeCornerData()
			return
		end
		Delay(0.2, function()
			if seq == cornerSaveSeq then
				writeCornerData()
			end
		end)
	end

	const function onCDesc(o)
		if not (CE.data.enabled and o:IsA("UICorner")) then
			return
		end
		if CE.data.targetHiddenUi ~= true and isInsideHiddenUiRoot(o) then
			return
		end
		queueCornerApply(o)
	end

	function watchGuiRoot(root)
		if not root or CE.guiRootWatchers[root] then
			return
		end
		const conns = {}
		conns.desc = NAmanage.descSub(root, {
			added = function(d)
				if CE.data.enabled then
					queueCornerApply(d)
				end
			end,
			filterAdded = function(d)
				return d and d:IsA("UICorner")
			end,
		})
		conns.anc = root.AncestryChanged:Connect(function(obj, parent)
			if parent == nil then
				if CE.guiRootWatchers[root] then
					if conns.desc then pcall(function() conns.desc:Disconnect() end) end
					if conns.anc then pcall(function() conns.anc:Disconnect() end) end
					CE.guiRootWatchers[root] = nil
				end
				CE.guiRootSeen[root] = nil
			end
		end)
		CE.guiRootWatchers[root] = conns
	end

	const function onCBB(o)
		if not CE.data.enabled then
			return
		end
		if not o:IsA("BillboardGui") then
			return
		end
		const root = getCBB(o)
		if not root then
			return
		end
		if not CE.guiRootSeen[root] then
			CE.guiRootSeen[root] = true
			applyCornersIn(root)
		end
		if o:IsA("UICorner") then
			setCorner(o)
		end
		watchGuiRoot(root)
	end

	const function onCSurf(o)
		if not CE.data.enabled then
			return
		end
		if not o:IsA("SurfaceGui") then
			return
		end
		const root = getCSurf(o)
		if not root then
			return
		end
		if not CE.guiRootSeen[root] then
			CE.guiRootSeen[root] = true
			applyCornersIn(root)
		end
		if o:IsA("UICorner") then
			setCorner(o)
		end
		watchGuiRoot(root)
	end

	NAmanage.setWsH("CornerEditor_World", {
		enabled = function()
			return CE.data.enabled == true
		end,
		classNames = { "BillboardGui", "SurfaceGui" },
		added = function(o)
			onCBB(o)
			onCSurf(o)
		end
	})

	const function syncCConn()
		const shouldWatch = CE.data.enabled == true
		NAlib.disconnect("CornerEditor")
		if shouldWatch and CE.data.targetCoreGui and CE.cg then
			NAlib.connect("CornerEditor", NAmanage.descSub(CE.cg, {
				added = onCDesc,
				filterAdded = function(o)
					return o and o:IsA("UICorner") and not (CE.data.targetHiddenUi ~= true and isInsideHiddenUiRoot(o))
				end,
				classNames = "UICorner",
			}))
		end

		NAlib.disconnect("CornerEditor_PlayerGui")
		if shouldWatch and CE.data.targetPlayerGui then
			NAlib.connect("CornerEditor_PlayerGui", NAmanage.pgSub({
				added = onCDesc,
				filterAdded = function(o)
					return o and o:IsA("UICorner")
				end,
			}))
		end

		NAlib.disconnect("CornerEditor_HUI")
		if shouldWatch and CE.data.targetHiddenUi and HUI then
			NAlib.connect("CornerEditor_HUI", NAmanage.descSub(HUI, {
				added = onCDesc,
				filterAdded = function(o)
					return o and o:IsA("UICorner")
				end,
			}))
		end

		NAlib.disconnect("CornerEditor_Billboard")
		NAlib.disconnect("CornerEditor_Surface")
	end

	const function monCPGui()
		NAlib.disconnect("CornerEditor_PlayerGuiAdded")
		NAlib.disconnect("CornerEditor_PlayerGuiRemoved")
		if NAmanage.pgSub then
			return
		end
		if not (CE.data.enabled and CE.data.targetPlayerGui) then
			return
		end
		const lp = Services.Players and Services.Players.LocalPlayer
		if not lp then
			return
		end
		NAlib.connect("CornerEditor_PlayerGuiAdded", NAmanage.childAdd(lp, function(child)
			if child:IsA("PlayerGui") then
				syncCConn()
				if CE.data.enabled then
					applyCorn()
				end
			end
		end, function(child)
			return child and child:IsA("PlayerGui")
		end))
		NAlib.connect("CornerEditor_PlayerGuiRemoved", NAmanage.childRem(lp, function(child)
			if child:IsA("PlayerGui") then
				syncCConn()
			end
		end, function(child)
			return child and child:IsA("PlayerGui")
		end))
	end

	const function setCTgt(field, value)
		if CE.data[field] == value then
			return
		end
		CE.data[field] = value
		saveCData()
		syncCConn()
		monCPGui()
		if CE.data.enabled then
			resetCorn()
			applyCorn()
		end
	end

	if CE.data.enabled then
		syncCConn()
		monCPGui()
		Defer(function()
			if CE.data.enabled then
				applyCorn()
			end
		end)
	else
		syncCConn()
		monCPGui()
	end

	local FontEditor
	local persistFontData
	local persistFontData

	const function newFontStore()
		return weakKeyMap()
	end

	local FontChoices = {}
	local CustomFontChoices = {}
	local FontChoiceIndex = {}
	const FontExts = {
		[".ttf"] = true,
		[".otf"] = true,
		[".ttc"] = true,
		[".otc"] = true,
		[".woff"] = true,
		[".woff2"] = true,
		[".fon"] = true,
		[".fnt"] = true,
		[".pfb"] = true,
		[".pfa"] = true,
		[".dfont"] = true,
		[".eot"] = true,
	}
	const NAFontSrc = {
		list = "https://api.github.com/repos/ltseverydayyou/uuuuuuu/contents/NAfonts?ref=main",
		raw = "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/NAfonts/",
	}

	const function clearFontChoices()
		FontChoices = {}
		CustomFontChoices = {}
		FontChoiceIndex = {}
	end

	const function addFontChoice(choice)
		if not choice or not choice.key then
			return
		end
		FontChoices[#FontChoices + 1] = choice
		FontChoiceIndex[choice.key] = choice
		if choice.kind == "custom" then
			CustomFontChoices[#CustomFontChoices + 1] = choice
		end
	end

	const function enforceCustomCycleAvailability()
		if FontEditor.data.useCustomCycle and #CustomFontChoices == 0 then
			FontEditor.data.useCustomCycle = false
			persistFontData()
		end
	end

	const function getActiveFontChoices()
		if FontEditor.data.useCustomCycle and #CustomFontChoices > 0 then
			return CustomFontChoices
		end
		return FontChoices
	end

	const function ensureCustomFontFolder()
		if isDelta then
			return false, "Custom font files are disabled on this executor."
		end
		if not FileSupport then
			return false, "File support is required for custom fonts."
		end
		if type(FontEditor.customDir) ~= "string" or FontEditor.customDir == "" then
			return false, "Custom font directory is not configured."
		end
		if type(isfolder) == "function" then
			local exists = false
			local ok, res = pcall(isfolder, FontEditor.customDir)
			if ok then
				exists = res
			end
			if not exists then
				if type(makefolder) ~= "function" then
					return false, "\"makefolder\" is required for custom fonts."
				end
				local okMk, err = pcall(makefolder, FontEditor.customDir)
				if not okMk then
					return false, err or "Unable to create custom font directory."
				end
			end
		end
		return true
	end

	const function getCustomFontCount()
		return type(FontEditor.customFonts) == "table" and #FontEditor.customFonts or 0
	end

	const function hasCustomFonts()
		return getCustomFontCount() > 0
	end

	const function formatCustomFontStatus()
		const count = getCustomFontCount()
		if count == 0 then
			return "No custom fonts installed"
		end
		if count == 1 then
			return "1 custom font installed"
		end
		return Format("%d custom fonts installed", count)
	end

	const function preprocessFontUrl(url)
		if type(url) ~= "string" then
			return nil
		end
		local trimmed = url:match("^%s*(.-)%s*$") or ""
		if trimmed == "" then
			return nil
		end
		trimmed = trimmed:gsub(" ", "%%20")
		const qPos = trimmed:find("%?")
		const base = qPos and trimmed:sub(1, qPos - 1) or trimmed
		return trimmed, base
	end

	const function normalizeGitHubPath(path)
		if type(path) ~= "string" then
			return ""
		end
		local cleaned = path:gsub("^/+", "")
		cleaned = cleaned:gsub("/+$", "")
		return cleaned
	end

	const function encodeGitHubPath(path)
		const normalized = normalizeGitHubPath(path or "")
		if normalized == "" then
			return ""
		end
		const segments = {}
		for segment in normalized:gmatch("[^/]+") do
			segments[#segments + 1] = Services.HttpService:UrlEncode(segment)
		end
		return Concat(segments, "/")
	end

	const function parseGitHubFolderUrl(baseUrl, originalUrl)
		if type(baseUrl) ~= "string" or baseUrl == "" then
			return nil
		end
		local owner, repo, kind, rest = baseUrl:match("^https?://github.com/([^/]+)/([^/]+)/([^/]+)/?(.*)$")
		if owner and repo and kind then
			if kind == "tree" then
				local sanitizedRest = rest or ""
				if sanitizedRest:sub(1, 11) == "refs/heads/" then
					sanitizedRest = sanitizedRest:sub(12)
				elseif sanitizedRest:sub(1, 10) == "refs/tags/" then
					sanitizedRest = sanitizedRest:sub(11)
				end
				local branch, path = sanitizedRest:match("^([^/]+)/(.*)$")
				if not branch then
					branch = sanitizedRest ~= "" and sanitizedRest or "main"
					path = ""
				end
				branch = branch:gsub("%%2[Ff]", "/")
				path = (path and path:gsub("%%2[Ff]", "/")) or ""
				return {
					owner = owner,
					repo = repo,
					branch = branch,
					path = normalizeGitHubPath(path),
					originalUrl = originalUrl or baseUrl,
				}
			end
			return nil
		end
		local ownerOnly, repoOnly = baseUrl:match("^https?://github.com/([^/]+)/([^/?#]+)$")
		if ownerOnly and repoOnly then
			return {
				owner = ownerOnly,
				repo = repoOnly:gsub("%.git$", ""),
				branch = "main",
				path = "",
				originalUrl = originalUrl or baseUrl,
			}
		end
		return nil
	end

	const GitHubFolderLimits = {
		depth = 4,
		total = 40,
	}

	const function fetchGitHubFolderContents(info, relativePath)
		if type(info) ~= "table" or type(info.owner) ~= "string" or type(info.repo) ~= "string" then
			return false, "Invalid GitHub folder reference."
		end
		const branch = info.branch ~= "" and info.branch or "main"
		local baseUrl = Format("https://api.github.com/repos/%s/%s/contents", info.owner, info.repo)
		const encodedPath = encodeGitHubPath(relativePath or "")
		if encodedPath ~= "" then
			baseUrl = baseUrl.."/"..encodedPath
		end
		baseUrl = baseUrl.."?ref="..Services.HttpService:UrlEncode(branch)
		local ok, raw = pcall(function()
			return NAmanage.HttpGetOrError(baseUrl)
		end)
		if not (ok and type(raw) == "string" and raw ~= "") then
			return false, raw or "Unable to fetch GitHub folder contents."
		end
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if not (okDecode and type(decoded) == "table") then
			return false, "Invalid GitHub folder response."
		end
		if type(decoded.message) == "string" and decoded.message ~= "" then
			return false, decoded.message
		end
		return true, decoded
	end

	const function normalizeCustomFontUrl(url)
		local trimmed, noQuery = preprocessFontUrl(url)
		if not trimmed then
			return nil
		end
		local owner, repo, kind, rest = noQuery:match("^https?://github.com/([^/]+)/([^/]+)/([^/]+)/(.+)$")
		if owner and repo and kind and rest then
			local sanitizedRest = rest
			if sanitizedRest:sub(1, 11) == "refs/heads/" then
				sanitizedRest = sanitizedRest:sub(12)
			elseif sanitizedRest:sub(1, 10) == "refs/tags/" then
				sanitizedRest = sanitizedRest:sub(11)
			end
			local branch, path = sanitizedRest:match("^([^/]+)/(.+)$")
			if branch and path then
				branch = branch:gsub("%%2[Ff]", "/")
				path = path:gsub("%%2[Ff]", "/")
				if kind == "blob" or kind == "raw" then
					return Format("https://raw.githubusercontent.com/%s/%s/%s/%s", owner, repo, branch, path)
				end
			end
		end
		const directRaw = noQuery:match("^https?://raw%.githubusercontent%.com/.+")
		if directRaw then
			return trimmed
		end
		return trimmed
	end

	const function sanitizeFileName(name)
		if type(name) ~= "string" then
			return nil
		end
		const trimmed = name:match("^%s*(.-)%s*$") or ""
		local sanitized = trimmed:gsub("[^%w%._%-]", "_")
		sanitized = sanitized:gsub("_+", "_")
		sanitized = sanitized:gsub("^_+", "")
		sanitized = sanitized:gsub("_+$", "")
		if sanitized == "" then
			return nil
		end
		return sanitized
	end

	const function sanitizeId(name)
		if type(name) ~= "string" then
			return nil
		end
		const lowered = name:lower()
		local sanitized = lowered:gsub("[^%w]+", "_")
		sanitized = sanitized:gsub("_+", "_")
		sanitized = sanitized:gsub("^_+", "")
		sanitized = sanitized:gsub("_+$", "")
		if sanitized == "" then
			return nil
		end
		return sanitized
	end

	const function getFName(path)
		if type(path) ~= "string" then
			return nil
		end
		const normalized = path:gsub("\\", "/")
		return normalized:match("([^/]+)$")
	end

	const function isFontExt(name)
		if type(name) ~= "string" or name == "" then
			return false
		end
		const ext = name:match("%.[^%.]+$")
		return ext and FontExts[ext:lower()] == true
	end

	const function collectGitHubFontFiles(info)
		if type(info) ~= "table" then
			return false, "Invalid GitHub folder reference."
		end
		const fonts = {}
		const visited = {}
		const function visitKey(path)
			return (path and path ~= "") and path or "/"
		end
		const function scan(path, depth)
			depth = depth or 0
			if depth > GitHubFolderLimits.depth then
				return true
			end
			if #fonts >= GitHubFolderLimits.total then
				return true
			end
			local okFetch, payload = fetchGitHubFolderContents(info, path or "")
			if not okFetch then
				return false, payload
			end
			const entries = {}
			if payload.type == "file" then
				entries[1] = payload
			elseif #payload > 0 then
				for _, entry in payload do
					entries[#entries + 1] = entry
				end
			else
				return true
			end
			for _, entry in entries do
				if type(entry) == "table" then
					if entry.type == "file" then
						if entry.name and isFontExt(entry.name) and entry.download_url then
							fonts[#fonts + 1] = {
								name = entry.name,
								label = entry.name:gsub("%.[^%.]+$", ""),
								url = entry.download_url,
							}
							if #fonts >= GitHubFolderLimits.total then
								break
							end
						end
					elseif entry.type == "dir" and entry.path then
						const key = visitKey(entry.path)
						if not visited[key] then
							visited[key] = true
							local okChild, errChild = scan(entry.path, depth + 1)
							if not okChild then
								return false, errChild
							end
							if #fonts >= GitHubFolderLimits.total then
								break
							end
						end
					end
				end
			end
			return true
		end
		const startPath = normalizeGitHubPath(info.path or "")
		visited[visitKey(startPath)] = true
		local okScan, errScan = scan(startPath, 0)
		if not okScan then
			return false, errScan
		end
		return true, fonts
	end

	const IconExts = {
		[".png"] = true,
		[".jpg"] = true,
		[".jpeg"] = true,
		[".webp"] = true,
		[".bmp"] = true,
	}

	const function isIconExt(name)
		if type(name) ~= "string" or name == "" then
			return false
		end
		const ext = name:match("%.[^%.]+$")
		return ext and IconExts[ext:lower()] == true
	end

	const function collectGitHubIconFiles(info)
		if type(info) ~= "table" then
			return false, "Invalid GitHub folder reference."
		end
		const icons = {}
		const visited = {}
		const function key(path)
			return (path and path ~= "") and path or "/"
		end
		const function scan(path, depth)
			depth = depth or 0
			if depth > GitHubFolderLimits.depth then
				return true
			end
			if #icons >= GitHubFolderLimits.total then
				return true
			end
			local okFetch, payload = fetchGitHubFolderContents(info, path or "")
			if not okFetch then
				return false, payload
			end
			const entries = {}
			if payload.type == "file" then
				entries[1] = payload
			elseif #payload > 0 then
				for _, e in payload do
					entries[#entries + 1] = e
				end
			else
				return true
			end
			for _, e in entries do
				if type(e) == "table" then
					if e.type == "file" then
						if e.name and isIconExt(e.name) and e.download_url then
							icons[#icons + 1] = {
								name = e.name,
								url = e.download_url,
							}
							if #icons >= GitHubFolderLimits.total then
								break
							end
						end
					elseif e.type == "dir" and e.path then
						const k = key(e.path)
						if not visited[k] then
							visited[k] = true
							local okChild, errChild = scan(e.path, depth + 1)
							if not okChild then
								return false, errChild
							end
							if #icons >= GitHubFolderLimits.total then
								break
							end
						end
					end
				end
			end
			return true
		end
		const startPath = normalizeGitHubPath(info.path or "")
		visited[key(startPath)] = true
		local okScan, errScan = scan(startPath, 0)
		if not okScan then
			return false, errScan
		end
		return true, icons
	end

	NAgui.installIconsFromGitHubFolder = function(info)
		if not NAgui.iconFsOk() then
			return false, "Custom icons require file support and getcustomasset."
		end
		if not NAgui.ensureIconFolder() then
			return false, "Unable to prepare CustomIcon folder."
		end
		local okList, list = collectGitHubIconFiles(info)
		if not okList then
			return false, list
		end
		if #list == 0 then
			return false, "No image files were found in that folder."
		end
		local count = 0
		local lastAsset
		local lastErr
		for _, ico in list do
			local okSave, asset = NAgui.iconSaveFromUrl(ico.url)
			if okSave and typeof(asset) == "string" then
				count += 1
				lastAsset = asset
			else
				lastErr = asset
			end
		end
		if count == 0 then
			return false, lastErr or "Unable to download icons from that folder."
		end
		return true, {
			count = count,
			asset = lastAsset,
			source = info.originalUrl,
		}
	end

	const function uniqFontId(base)
		local clean = base
		if not clean or clean == "" then
			clean = "font_"..tostring(os.time())
		end
		local id = clean
		local idx = 1
		while FontEditor.customFontMap and FontEditor.customFontMap[id] do
			idx += 1
			id = Format("%s_%d", clean, idx)
		end
		return id
	end

	const function saveCustomFontManifest()
		if not FileSupport then
			return
		end
		if type(writefile) ~= "function" then
			return
		end
		const payload = { fonts = FontEditor.customFonts }
		pcall(writefile, FontEditor.customManifest, Services.HttpService:JSONEncode(payload))
	end

	const function customFontFileExists(fileName)
		if type(fileName) ~= "string" or fileName == "" then
			return false
		end
		if type(FontEditor) ~= "table" or type(FontEditor.customDir) ~= "string" then
			return false
		end
		if type(isfile) ~= "function" then
			return false
		end
		local ok, exists = pcall(isfile, FontEditor.customDir.."/"..fileName)
		return ok and exists
	end

	const function deleteCustomFontFile(fileName)
		if not (type(fileName) == "string" and fileName ~= "") then
			return
		end
		if type(FontEditor) ~= "table" or type(FontEditor.customDir) ~= "string" then
			return
		end
		if type(isfile) ~= "function" or type(delfile) ~= "function" then
			return
		end
		const fullPath = FontEditor.customDir.."/"..fileName
		local okExists, exists = pcall(isfile, fullPath)
		if okExists and exists then
			pcall(delfile, fullPath)
		end
	end

	const function removeCustomFontEntry(entry, opts)
		if not (entry and entry.id) then
			return
		end
		opts = opts or {}
		const id = entry.id
		if opts.deleteFiles then
			if entry.file then
				deleteCustomFontFile(entry.file)
			end
			if entry.familyFile then
				deleteCustomFontFile(entry.familyFile)
			end
		end
		for i = #FontEditor.customFonts, 1, -1 do
			const item = FontEditor.customFonts[i]
			if item and item.id == id then
				table.remove(FontEditor.customFonts, i)
				break
			end
		end
		FontEditor.customFontMap[id] = nil
		if not opts.skipSave then
			saveCustomFontManifest()
		end
		if FontEditor.refreshCustomFontUI then
			FontEditor.refreshCustomFontUI()
		end
	end

	const function removeAllCustomFonts()
		if type(FontEditor.customFonts) ~= "table" or #FontEditor.customFonts == 0 then
			return
		end
		const entries = {}
		for _, entry in FontEditor.customFonts do
			entries[#entries + 1] = entry
		end
		for _, entry in entries do
			removeCustomFontEntry(entry, { deleteFiles = true, skipSave = true })
		end
		FontEditor.customFonts = {}
		FontEditor.customFontMap = {}
		saveCustomFontManifest()
		rebuildFontChoices()
		enforceCustomCycleAvailability()
		if FontEditor.refreshCustomFontUI then
			FontEditor.refreshCustomFontUI()
		end
	end

	const function scanFonts()
		if isDelta then
			return false
		end
		if not (FileSupport and listfiles) then
			return false
		end
		if type(FontEditor.customDir) ~= "string" or FontEditor.customDir == "" then
			return false
		end
		if type(FontEditor.customFonts) ~= "table" or type(FontEditor.customFontMap) ~= "table" then
			return false
		end
		const okFolder = ensureCustomFontFolder()
		if not okFolder then
			return false
		end
		local okList, items = pcall(listfiles, FontEditor.customDir)
		if not (okList and type(items) == "table") then
			return false
		end
		const known = {}
		for _, entry in FontEditor.customFonts do
			if entry.file then
				known[entry.file:lower()] = true
			end
		end
		local added = false
		for _, fullPath in items do
			const name = getFName(fullPath)
			if name and isFontExt(name) then
				const lower = name:lower()
				if not known[lower] then
					const base = name:gsub("%.[^%.]+$", "")
					const id = uniqFontId(sanitizeId(base) or sanitizeId(name))
					const label = base ~= "" and base or id
					const entry = {
						id = id,
						name = label,
						displayName = label,
						file = name,
						url = nil,
					}
					FontEditor.customFonts[#FontEditor.customFonts + 1] = entry
					FontEditor.customFontMap[id] = entry
					known[lower] = true
					added = true
				end
			end
		end
		if added then
			saveCustomFontManifest()
		end
		return added
	end

	const function loadCustomFontManifest()
		FontEditor.customFonts = {}
		FontEditor.customFontMap = {}
		if isDelta then
			return
		end
		if not FileSupport then
			return
		end
		const okFolder = ensureCustomFontFolder()
		if not okFolder then
			return
		end
		if type(isfile) ~= "function" or type(readfile) ~= "function" then
			return
		end
		if not isfile(FontEditor.customManifest) then
			return
		end
		local ok, raw = pcall(readfile, FontEditor.customManifest)
		if not (ok and type(raw) == "string" and raw ~= "") then
			return
		end
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if not (okDecode and type(decoded) == "table") then
			return
		end
		const items = decoded.fonts or decoded
		if type(items) ~= "table" then
			return
		end
		local manifestDirty = false
		const validFonts = {}
		const validMap = {}
		for _, entry in items do
			if type(entry) == "table" and type(entry.file) == "string" then
				entry.id = entry.id or sanitizeId(entry.name or entry.file) or sanitizeId(NAmanage.GetSessionInstanceName("CustomFontEntry_"..tostring(entry.name or entry.file or #validFonts + 1))) or tostring(os.time())
				entry.name = entry.name or entry.id
				entry.displayName = entry.displayName or entry.name
				entry.url = normalizeCustomFontUrl(entry.url) or entry.url
				entry.familyFile = entry.familyFile
				if not customFontFileExists(entry.file) then
					if entry.familyFile then
						deleteCustomFontFile(entry.familyFile)
					end
					manifestDirty = true
				elseif validMap[entry.id] then
					manifestDirty = true
				else
					validFonts[#validFonts + 1] = entry
					validMap[entry.id] = entry
				end
			else
				manifestDirty = true
			end
		end
		FontEditor.customFonts = validFonts
		FontEditor.customFontMap = validMap
		if manifestDirty then
			saveCustomFontManifest()
		end
	end

	const function rebuildFontChoices()
		clearFontChoices()
		for _, enumFont in Enum.Font:GetEnumItems() do
			if enumFont ~= Enum.Font.Unknown then
				addFontChoice({
					key = "enum:"..enumFont.Name,
					label = enumFont.Name,
					kind = "enum",
					enum = enumFont,
				})
			end
		end
		for _, entry in FontEditor.customFonts do
			if type(entry.id) == "string" and type(entry.file) == "string" then
				const label = entry.displayName or entry.name or entry.id
				addFontChoice({
					key = "custom:"..entry.id,
					label = "[Custom] "..label,
					kind = "custom",
					entry = entry,
				})
			end
		end
		enforceCustomCycleAvailability()
	end

	const function getFontChoice(fontKey)
		if type(fontKey) ~= "string" or fontKey == "" then
			return nil
		end
		const choice = FontChoiceIndex[fontKey]
		if choice then
			return choice
		end
		if not fontKey:find(":", 1, true) then
			local ok, enumCandidate = pcall(function()
				return Enum.Font[fontKey]
			end)
			if ok and enumCandidate and enumCandidate ~= Enum.Font.Unknown then
				return FontChoiceIndex["enum:"..fontKey]
			end
		end
		return nil
	end

	const function normalizeFontKey(fontKey)
		if type(fontKey) ~= "string" or fontKey == "" then
			return FontEditor.default.fontKey
		end
		if fontKey == "enum:Unknown" then
			return FontEditor.default.fontKey
		end
		if FontChoiceIndex[fontKey] then
			return fontKey
		end
		if not fontKey:find(":", 1, true) then
			local ok, enumCandidate = pcall(function()
				return Enum.Font[fontKey]
			end)
			if ok and enumCandidate and enumCandidate ~= Enum.Font.Unknown then
				return "enum:"..fontKey
			end
		end
		return FontEditor.default.fontKey
	end
	const function getCustomFontAsset(entry)
		if isDelta then
			return nil, "Custom font files are disabled on this executor."
		end
		if type(entry) ~= "table" or type(entry.file) ~= "string" then
			return nil, "Invalid custom font entry."
		end
		if type(getcustomasset) ~= "function" then
			return nil, "Custom fonts require getcustomasset support."
		end
		if not FileSupport or type(writefile) ~= "function" then
			return nil, "File support is required for custom fonts."
		end
		if not customFontFileExists(entry.file) then
			removeCustomFontEntry(entry)
			rebuildFontChoices()
			enforceCustomCycleAvailability()
			return nil, "Custom font file is missing."
		end
		const fullPath = FontEditor.customDir.."/"..entry.file
		local okAsset, assetId = pcall(getcustomasset, fullPath)
		if not (okAsset and type(assetId) == "string") then
			return nil, "Unable to load custom font file."
		end
		const familyFile = entry.familyFile or (entry.id.."_family.json")
		const familyPath = FontEditor.customDir.."/"..familyFile
		if entry.familyFile and entry.familyFile ~= familyFile then
			deleteCustomFontFile(entry.familyFile)
		end
		const needsPersist = entry.familyFile ~= familyFile
		entry.familyFile = familyFile
		const familyData = {
			family = entry.displayName or entry.name or entry.id,
			faces = {
				{
					assetId = assetId,
					weight = "Regular",
					style = "Normal",
				},
			},
		}
		local okWrite, errWrite = pcall(writefile, familyPath, Services.HttpService:JSONEncode(familyData))
		if not okWrite then
			return nil, errWrite or "Unable to create font family data."
		end
		local okFamilyAsset, familyAssetId = pcall(getcustomasset, familyPath)
		if not (okFamilyAsset and type(familyAssetId) == "string") then
			return nil, "Unable to load custom font family."
		end
		if needsPersist then
			saveCustomFontManifest()
		end
		local okFont, fontFace = pcall(Font.new, familyAssetId, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		if okFont and typeof(fontFace) == "Font" then
			return fontFace
		end
		return nil, "Invalid font file."
	end

	const function deriveFileNameFromUrl(url)
		if type(url) ~= "string" then
			return nil
		end
		const candidate = url:match("/([^/%?]+)$")
		return candidate
	end

	const function deriveLegacyIconFileNameFromUrl(url)
		const remoteFile = deriveFileNameFromUrl(url) or "CustomIcon.png"
		return sanitizeFileName(remoteFile) or ("icon_"..tostring(os.time())..".png")
	end

	const function installFontFromUrl(name, url, opts)
		opts = opts or {}
		const rawName = type(name) == "string" and (name:match("^%s*(.-)%s*$") or "") or ""
		local httpOk, data = NAmanage.HttpGet(url, { timeout = 10 })
		if not (httpOk and type(data) == "string" and data ~= "") then
			return false, "Unable to download font file."
		end
		const remoteFile = opts.remoteFileName or deriveFileNameFromUrl(url)
		local sanitizedRemote = sanitizeFileName(remoteFile or rawName)
		if not sanitizedRemote then
			sanitizedRemote = "font_"..tostring(os.time())..".otf"
		end
		const ext = sanitizedRemote:match("%.[^%.]+$") or ".otf"
		const idSource = rawName ~= "" and rawName or sanitizedRemote:gsub("%.[^%.]+$", "")
		const id = sanitizeId(idSource) or sanitizeId(NAmanage.GetSessionInstanceName("CustomFontInstall_"..tostring(idSource or sanitizedRemote or os.time()))) or tostring(os.time())
		const fileName = id..ext
		const fullPath = FontEditor.customDir.."/"..fileName
		local okWrite, errWrite = pcall(writefile, fullPath, data)
		if not okWrite then
			return false, errWrite or "Unable to save custom font file."
		end
		local entry = FontEditor.customFontMap[id]
		if entry then
			entry.file = fileName
			entry.url = url
			if rawName ~= "" then
				entry.name = rawName
				entry.displayName = rawName
			end
		else
			const display = rawName ~= "" and rawName or sanitizedRemote:gsub("%.[^%.]+$", "")
			entry = {
				id = id,
				name = display,
				displayName = display,
				file = fileName,
				url = url,
			}
			FontEditor.customFontMap[id] = entry
			FontEditor.customFonts[#FontEditor.customFonts + 1] = entry
		end
		if not opts.deferSave then
			saveCustomFontManifest()
			rebuildFontChoices()
		end
		return true, entry
	end

	const function installFontsFromGitHubFolder(name, folderInfo)
		local okFonts, fontList = collectGitHubFontFiles(folderInfo)
		if not okFonts then
			return false, fontList
		end
		if #fontList == 0 then
			return false, "No font files were found in that folder."
		end
		const baseName = type(name) == "string" and (name:match("^%s*(.-)%s*$") or "") or ""
		const installed = {}
		local lastErr = nil
		for _, font in fontList do
			local label = font.label
			if baseName ~= "" then
				label = baseName.." - "..font.label
			end
			local okInstall, result = installFontFromUrl(label, font.url, {
				remoteFileName = font.name,
				deferSave = true,
			})
			if okInstall then
				installed[#installed + 1] = result
			else
				lastErr = result
			end
		end
		if #installed == 0 then
			return false, lastErr or "Unable to install fonts from that folder."
		end
		saveCustomFontManifest()
		rebuildFontChoices()
		return true, {
			multi = true,
			entries = installed,
			count = #installed,
			source = folderInfo.originalUrl,
		}
	end

	const function addOrUpdateCustomFont(name, url, opts)
		opts = opts or {}
		if isDelta then
			return false, "Custom font files are disabled on this executor."
		end
		if not FileSupport then
			return false, "File support is required for custom fonts."
		end
		if type(writefile) ~= "function" then
			return false, "writefile is required for custom fonts."
		end
		if type(url) ~= "string" or url == "" then
			return false, "A font URL is required."
		end
		local trimmed, baseUrl = preprocessFontUrl(url)
		if not trimmed then
			return false, "A font URL is required."
		end
		local okFolder, folderErr = ensureCustomFontFolder()
		if not okFolder then
			return false, folderErr
		end
		if not opts.skipFolderScan then
			const folderInfo = parseGitHubFolderUrl(baseUrl, trimmed)
			if folderInfo then
				folderInfo.path = folderInfo.path or ""
				return installFontsFromGitHubFolder(name, folderInfo)
			end
		end
		const normalizedUrl = normalizeCustomFontUrl(trimmed)
		if not normalizedUrl then
			return false, "Invalid font URL."
		end
		return installFontFromUrl(name, normalizedUrl, opts)
	end

	const function getNAList()
		local ok, raw = NAmanage.HttpGet(NAFontSrc.list, { timeout = 10, Headers = { Accept = "application/json" } })
		if not (ok and type(raw) == "string" and raw ~= "") then
			return false, "Unable to fetch NA font catalog."
		end
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if not (okDecode and type(decoded) == "table") then
			return false, "Invalid NA font catalog."
		end
		const items = {}
		if #decoded > 0 then
			for _, entry in decoded do
				items[#items + 1] = entry
			end
		else
			for _, entry in decoded do
				if type(entry) == "table" then
					items[#items + 1] = entry
				end
			end
		end
		const fonts = {}
		for _, entry in items do
			if type(entry) == "table" and type(entry.name) == "string" then
				if isFontExt(entry.name) then
					fonts[#fonts + 1] = {
						name = entry.name,
						label = entry.name:gsub("%.[^%.]+$", ""),
						url = NAFontSrc.raw..entry.name,
					}
				end
			end
		end
		if #fonts == 0 then
			return false, "No preset fonts available."
		end
		return true, fonts
	end

	const function dlNAFonts()
		if isDelta then
			return false, "NA preset fonts are disabled on this executor."
		end
		if not FileSupport then
			return false, "Custom fonts require file support."
		end
		local okFolder, folderErr = ensureCustomFontFolder()
		if not okFolder then
			return false, folderErr
		end
		local okList, fonts = getNAList()
		if not okList then
			return false, fonts
		end
		local count = 0
		local lastErr = nil
		for _, font in fonts do
			const label = font.label ~= "" and font.label or font.name
			local okInstall, res = addOrUpdateCustomFont(label, font.url)
			if okInstall then
				count += 1
			else
				lastErr = res or ("Unable to install "..label)
			end
		end
		if count == 0 then
			return false, lastErr or "No preset fonts installed."
		end
		return true, count
	end

	FontEditor = {
		path = NAfiles.NAFILEPATH.."/font_override.json",
		default = {
			enabled = false,
			font = "Gotham",
			fontKey = "enum:Gotham",
			targetCoreGui = true,
			targetPlayerGui = false,
			targetBillboardGui = false,
			targetSurfaceGui = false,
			targetHiddenUi = false,
			useCustomCycle = false,
		},
		cg = Services.CoreGui,
		store = newFontStore(),
		data = {
			enabled = false,
			font = "Gotham",
			fontKey = "enum:Gotham",
			targetCoreGui = true,
			targetPlayerGui = false,
			targetBillboardGui = false,
			targetSurfaceGui = false,
			targetHiddenUi = false,
			useCustomCycle = false,
		},
		currentFont = Enum.Font.Gotham,
		currentFontIsCustom = false,
		customDir = NAfiles.NACUSTOMFONTPATH,
		customManifest = NAfiles.NACUSTOMFONTPATH.."/fonts.json",
		customFonts = {},
		customFontMap = {},
		customInputs = { name = "", url = "" },
		refreshCustomFontUI = nil,
		watchers = weakKeyMap(),
		guiRootWatchers = weakKeyMap(),
		guiRootSeen = weakKeyMap(),
		restoring = false,
		dlBusy = false,
	}
	const ex = identifyexecutor and identifyexecutor():lower() or ""
	const isDelta = (ex == "delta")

	const function disconnectFontWatcher(target)
		const watcher = FontEditor.watchers[target]
		if not watcher then
			return
		end
		if watcher.change then
			pcall(function()
				watcher.change:Disconnect()
			end)
		end
		if watcher.ancestry then
			pcall(function()
				watcher.ancestry:Disconnect()
			end)
		end
		FontEditor.watchers[target] = nil
	end

	const function ensureFontWatcher(target)
		if not target or FontEditor.watchers[target] then
			return
		end
		const watcher = {}
		watcher.change = target:GetPropertyChangedSignal("FontFace"):Connect(function()
			if FontEditor.restoring then
				return
			end
			if not FontEditor.data.enabled then
				return
			end
			if FontEditor.currentFontIsCustom then
				const currentFace = NAlib.isProperty(target, "FontFace")
				if currentFace ~= FontEditor.currentFont then
					pcall(function()
						target.FontFace = FontEditor.currentFont
					end)
				end
			end
		end)
		watcher.ancestry = target.AncestryChanged:Connect(function(obj)
			if not obj.Parent then
				disconnectFontWatcher(obj)
				FontEditor.store[obj] = nil
			end
		end)
		FontEditor.watchers[target] = watcher
	end

	persistFontData = function()
		if not FileSupport then
			return
		end
		const payload = {
			enabled = FontEditor.data.enabled,
			fontKey = FontEditor.data.fontKey or FontEditor.default.fontKey,
			fontLabel = FontEditor.data.font,
			targetCoreGui = FontEditor.data.targetCoreGui,
			targetPlayerGui = FontEditor.data.targetPlayerGui,
			targetBillboardGui = FontEditor.data.targetBillboardGui,
			targetSurfaceGui = FontEditor.data.targetSurfaceGui,
			targetHiddenUi = FontEditor.data.targetHiddenUi,
			useCustomCycle = FontEditor.data.useCustomCycle,
		}
		NAmanage.safeWriteFile(FontEditor.path, Services.HttpService:JSONEncode(payload))
	end

	const function loadFontData()
		local stored = FontEditor.default

		if FileSupport then
			if not NAmanage.safeIsFile(FontEditor.path) then
				NAmanage.safeWriteFile(FontEditor.path, Services.HttpService:JSONEncode(FontEditor.default))
			end
			local ok, raw = pcall(readfile, FontEditor.path)
			if ok and type(raw) == "string" then
				local okD, dec = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
				if okD and type(dec) == "table" then
					stored = dec
				end
			end
		end

		local k = stored.fontKey or stored.font or FontEditor.default.fontKey
		local lbl = stored.fontLabel or stored.font or FontEditor.default.font

		if type(k) ~= "string" or k == "" then
			k = FontEditor.default.fontKey
		end
		if type(lbl) ~= "string" or lbl == "" then
			lbl = FontEditor.default.font
		end

		FontEditor.data.fontKey = k
		FontEditor.data.font = lbl

		if type(stored.targetCoreGui) == "boolean" then
			FontEditor.data.targetCoreGui = stored.targetCoreGui
		else
			FontEditor.data.targetCoreGui = FontEditor.default.targetCoreGui
		end

		if type(stored.targetPlayerGui) == "boolean" then
			FontEditor.data.targetPlayerGui = stored.targetPlayerGui
		else
			FontEditor.data.targetPlayerGui = FontEditor.default.targetPlayerGui
		end

		if type(stored.targetBillboardGui) == "boolean" then
			FontEditor.data.targetBillboardGui = stored.targetBillboardGui
		else
			FontEditor.data.targetBillboardGui = FontEditor.default.targetBillboardGui
		end

		if type(stored.targetSurfaceGui) == "boolean" then
			FontEditor.data.targetSurfaceGui = stored.targetSurfaceGui
		else
			FontEditor.data.targetSurfaceGui = FontEditor.default.targetSurfaceGui
		end
		if type(stored.targetHiddenUi) == "boolean" then
			FontEditor.data.targetHiddenUi = stored.targetHiddenUi
		else
			FontEditor.data.targetHiddenUi = FontEditor.default.targetHiddenUi
		end

		FontEditor.data.useCustomCycle = stored.useCustomCycle == true
		FontEditor.data.enabled = stored.enabled == true
	end

	const function isBuilderIconFontFace(o)
		const ff = NAlib.isProperty(o, "FontFace")
		const ffType = ff and typeof(ff) or nil
		const fam = ff and ff.Family or nil
		return (ffType == "Font" or ffType == "FontFace")
			and type(fam) == "string"
			and fam:find("BuilderIcons/BuilderIcons.json", 1, true)
	end

	const function isNAUIElement(o)
		return o and NAStuff and NAStuff.NASCREENGUI and o:IsDescendantOf(NAStuff.NASCREENGUI)
	end

	const function isFontClassTarget(o)
		return o and (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox"))
	end

	const function isFontTarget(o)
		if not (o and o.Parent) then
			return false
		end
		if HUI and o:IsDescendantOf(HUI) and not FontEditor.data.targetHiddenUi then
			return false
		end
		if isNAUIElement(o) and not FontEditor.data.targetHiddenUi then
			return false
		end
		if not isFontClassTarget(o) then
			return false
		end
		if FontEditor.data.targetHiddenUi and HUI and o:IsDescendantOf(HUI) then
			return true
		end
		if FontEditor.data.targetCoreGui and FontEditor.cg and o:IsDescendantOf(FontEditor.cg) then
			return true
		end
		if FontEditor.data.targetPlayerGui then
			const pg = getPlayerGui()
			if pg and o:IsDescendantOf(pg) then
				return true
			end
		end
		if FontEditor.data.targetBillboardGui then
			local ok, bb = pcall(function()
				return o:FindFirstAncestorOfClass("BillboardGui")
			end)
			if ok and bb then
				return true
			end
		end
		if FontEditor.data.targetSurfaceGui then
			local ok, sg = pcall(function()
				return o:FindFirstAncestorOfClass("SurfaceGui")
			end)
			if ok and sg then
				return true
			end
		end
		return false
	end

	const function isInPlayerGui(o)
		local ok, pg = pcall(function()
			return o:FindFirstAncestorOfClass("PlayerGui")
		end)
		return ok and pg ~= nil
	end

	const function captureFontFaceState(o)
		local ok, value = pcall(function()
			return o.FontFace
		end)
		if ok then
			return true, value
		end
		return false, nil
	end

	const function applyFontToInstance(o)
		if not FontEditor.data.enabled then
			return
		end
		if not isFontTarget(o) then
			return
		end
		if isBuilderIconFontFace(o) then
			return
		end
		if not FontEditor.currentFont then
			return
		end

		if not FontEditor.store[o] then
			local hasFF, ff = captureFontFaceState(o)
			FontEditor.store[o] = {
				Font = NAlib.isProperty(o, "Font"),
				FontFace = ff,
				FontFaceSupported = hasFF,
			}
		end

		const info = FontEditor.store[o]

		if FontEditor.currentFontIsCustom then
			if not isInPlayerGui(o) then
				ensureFontWatcher(o)
			end
			if info and info.FontFaceSupported and NAlib.isProperty(o, "FontFace") ~= FontEditor.currentFont then
				pcall(function()
					o.FontFace = FontEditor.currentFont
				end)
			end
		else
			if info and info.FontFaceSupported then
				ensureFontWatcher(o)
				if NAlib.isProperty(o, "FontFace") ~= info.FontFace then
					pcall(function()
						o.FontFace = info.FontFace
					end)
				end
			end
			const cur = NAlib.isProperty(o, "Font")
			if cur == FontEditor.currentFont then
				return
			end
			pcall(function()
				o.Font = FontEditor.currentFont
			end)
		end
	end

	local fontApplyQueue = {}
	local fontApplySet = weakKeyMap()
	local fontApplyHead = 1
	local fontApplyTail = 0
	local fontApplyBusy = false
	local fontApplyToken = 0

	const function queueFontApply(o)
		if not (FontEditor.data.enabled and o and o.Parent and isFontTarget(o)) then
			return
		end
		if fontApplySet[o] then
			return
		end
		fontApplySet[o] = true
		fontApplyTail += 1
		fontApplyQueue[fontApplyTail] = o
		if fontApplyTail - fontApplyHead > 2048 then
			fontApplyQueue = {}
			fontApplySet = weakKeyMap()
			fontApplyHead = 1
			fontApplyTail = 0
			fontApplyBusy = false
			return
		end
		if fontApplyBusy then
			return
		end
		fontApplyBusy = true
		fontApplyToken += 1
		const token = fontApplyToken
		Spawn(function()
			while fontApplyToken == token and fontApplyHead <= fontApplyTail do
				local budget, waitDelay = NAmanage._evtHubBudget(8, {
					delay = 0,
					ldSc = 0.25,
					ldDel = 0.012,
				})
				while budget > 0 and fontApplyToken == token and fontApplyHead <= fontApplyTail do
					const inst = fontApplyQueue[fontApplyHead]
					fontApplyQueue[fontApplyHead] = nil
					fontApplyHead += 1
					if inst then
						fontApplySet[inst] = nil
						if inst.Parent and FontEditor.data.enabled then
							applyFontToInstance(inst)
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
			if fontApplyToken == token then
				fontApplyQueue = {}
				fontApplySet = weakKeyMap()
				fontApplyHead = 1
				fontApplyTail = 0
				fontApplyBusy = false
			end
		end)
	end
	const function clearFontGuiRootWatchers()
		for root, conns in FontEditor.guiRootWatchers do
			if conns.desc then pcall(function() conns.desc:Disconnect() end) end
			if conns.anc then pcall(function() conns.anc:Disconnect() end) end
			FontEditor.guiRootWatchers[root] = nil
		end
		FontEditor.guiRootWatchers = weakKeyMap()
		FontEditor.guiRootSeen = weakKeyMap()
	end

	const function watchFontGuiRoot(root)
		if not root or FontEditor.guiRootWatchers[root] then
			return
		end
		const conns = {}
		conns.desc = NAmanage.descSub(root, {
			added = function(d)
				if FontEditor.data.enabled then
					queueFontApply(d)
				end
			end,
			filterAdded = function(d)
				return isFontTarget(d)
			end,
		})
		conns.anc = root.AncestryChanged:Connect(function(obj, parent)
			if parent == nil then
				if FontEditor.guiRootWatchers[root] then
					if conns.desc then pcall(function() conns.desc:Disconnect() end) end
					if conns.anc then pcall(function() conns.anc:Disconnect() end) end
					FontEditor.guiRootWatchers[root] = nil
				end
				FontEditor.guiRootSeen[root] = nil
			end
		end)
		FontEditor.guiRootWatchers[root] = conns
	end

	const function applyFontToDescendants(container)
		if not container then
			return
		end
		queueUIScan(container, function(inst)
			if isFontTarget(inst) then
				queueFontApply(inst)
			end
		end, {
			key = "font-container:"..tostring(container),
			guard = function()
				return FontEditor.data.enabled
			end,
			skipChildren = function(inst)
				return container == FontEditor.cg and HUI and inst == HUI
			end,
		})
	end

	const function getFontTargets()
		const containers = {}
		if FontEditor.data.targetCoreGui and FontEditor.cg then
			containers[#containers + 1] = FontEditor.cg
		end
		if FontEditor.data.targetPlayerGui then
			const pg = getPlayerGui()
			if pg then
				containers[#containers + 1] = pg
			end
		end
		if FontEditor.data.targetHiddenUi and HUI then
			containers[#containers + 1] = HUI
		end
		return containers
	end

	const function restoreAllFonts()
		FontEditor.restoring = true
		for target, info in FontEditor.store do
			if target and info then
				if info.FontFaceSupported then
					pcall(function()
						target.FontFace = info.FontFace
					end)
				end
				if info.Font ~= nil then
					pcall(function()
						target.Font = info.Font
					end)
				end
			end
			disconnectFontWatcher(target)
		end
		FontEditor.restoring = false
		FontEditor.store = newFontStore()
		FontEditor.watchers = weakKeyMap()
		clearFontGuiRootWatchers()
		fontApplyToken += 1
		fontApplyQueue = {}
		fontApplySet = weakKeyMap()
		fontApplyHead = 1
		fontApplyTail = 0
		fontApplyBusy = false
	end

	NAmanage.FontEditorUnload = function()
		FontEditor.data.enabled = false
		NAlib.disconnect("FontEditor")
		NAlib.disconnect("FontEditor_PlayerGui")
		NAlib.disconnect("FontEditor_HUI")
		NAlib.disconnect("FontEditor_Billboard")
		NAlib.disconnect("FontEditor_Surface")
		NAlib.disconnect("FontEditor_PlayerGuiAdded")
		NAlib.disconnect("FontEditor_PlayerGuiRemoved")
		restoreAllFonts()
	end

	const function applyAllFonts()
		if not FontEditor.data.enabled then
			return
		end

		for _, container in getFontTargets() do
			applyFontToDescendants(container)
		end

		const world = Services.Workspace
		if not world then
			return
		end

		if FontEditor.data.targetBillboardGui or FontEditor.data.targetSurfaceGui then
			queueUIScan(world, function(inst)
				if FontEditor.data.targetBillboardGui and inst:IsA("BillboardGui") then
					if not FontEditor.guiRootSeen[inst] then
						FontEditor.guiRootSeen[inst] = true
						applyFontToDescendants(inst)
					end
					watchFontGuiRoot(inst)
				elseif FontEditor.data.targetSurfaceGui and inst:IsA("SurfaceGui") then
					if not FontEditor.guiRootSeen[inst] then
						FontEditor.guiRootSeen[inst] = true
						applyFontToDescendants(inst)
					end
					watchFontGuiRoot(inst)
				end
			end, {
				key = "font-world",
				guard = function()
					return FontEditor.data.enabled and (FontEditor.data.targetBillboardGui or FontEditor.data.targetSurfaceGui)
				end,
			})
		end
	end

	const function applyFontChoice(choice, opts)
		if not choice then
			return false, "Invalid font choice."
		end
		opts = opts or {}
		local resolvedFont = nil
		const isCustom = choice.kind == "custom"
		if isCustom then
			local fontFace, err = getCustomFontAsset(choice.entry)
			if not fontFace then
				return false, err
			end
			resolvedFont = fontFace
		else
			resolvedFont = choice.enum
		end
		if not resolvedFont then
			return false, "Unable to resolve font selection."
		end
		FontEditor.currentFont = resolvedFont
		FontEditor.currentFontIsCustom = isCustom
		FontEditor.data.fontKey = choice.key
		FontEditor.data.font = choice.label
		if opts.persist ~= false then
			persistFontData()
		end
		if FontEditor.data.enabled and opts.apply ~= false then
			applyAllFonts()
		end
		return true
	end

	const function setOverrideFont(fontKey, opts)
		opts = opts or {}
		const normalized = normalizeFontKey(fontKey)
		const choice = getFontChoice(normalized) or getFontChoice(FontEditor.default.fontKey)
		if not choice then
			return
		end
		local ok, err = applyFontChoice(choice, opts)
		if not ok and choice.kind == "custom" then
			if not opts.silent then
				DoNotif(err or "Unable to load custom font.", 3)
			end
			const fallback = getFontChoice(FontEditor.default.fontKey)
			if fallback then
				applyFontChoice(fallback, opts)
			end
		elseif not ok and not opts.silent then
			DoNotif(err or "Unable to update override font.", 3)
		end
		const syncDropdown = FontEditor and FontEditor.refreshFontDropdown
		if type(syncDropdown) == "function" then
			pcall(syncDropdown)
		end
	end

	const function cycleOverrideFont(delta)
		const choices = getActiveFontChoices()
		if #choices == 0 then
			DoNotif("No fonts available to cycle.", 3)
			return
		end
		const currentKey = FontEditor.data.fontKey or FontEditor.default.fontKey
		local index = 1
		for i, choice in choices do
			if choice.key == currentKey then
				index = i
				break
			end
		end
		const nextIndex = ((index - 1 + delta) % #choices) + 1
		setOverrideFont(choices[nextIndex].key)
	end

	const function onFontDescendantAdded(o)
		if not FontEditor.data.enabled then
			return
		end
		if FontEditor.data.targetHiddenUi ~= true and isInsideHiddenUiRoot(o) then
			return
		end
		queueFontApply(o)
	end

	const function onFontBillboardAdded(o)
		if not FontEditor.data.enabled then
			return
		end
		if not FontEditor.data.targetBillboardGui then
			return
		end
		if not o:IsA("BillboardGui") then
			return
		end
		if not FontEditor.guiRootSeen[o] then
			FontEditor.guiRootSeen[o] = true
			applyFontToDescendants(o)
		end
		watchFontGuiRoot(o)
	end

	const function onFontSurfaceAdded(o)
		if not FontEditor.data.enabled then
			return
		end
		if not FontEditor.data.targetSurfaceGui then
			return
		end
		if not o:IsA("SurfaceGui") then
			return
		end
		if not FontEditor.guiRootSeen[o] then
			FontEditor.guiRootSeen[o] = true
			applyFontToDescendants(o)
		end
		watchFontGuiRoot(o)
	end

	NAmanage.setWsH("FontEditor_World", {
		enabled = function()
			return FontEditor.data.enabled == true
		end,
		classNames = { "BillboardGui", "SurfaceGui" },
		added = function(o)
			onFontBillboardAdded(o)
			onFontSurfaceAdded(o)
		end
	})

	const function refreshFontConnections()
		const shouldWatch = FontEditor.data.enabled == true
		NAlib.disconnect("FontEditor")
		if shouldWatch and FontEditor.data.targetCoreGui and FontEditor.cg then
			NAlib.connect("FontEditor", NAmanage.descSub(FontEditor.cg, {
				added = onFontDescendantAdded,
				filterAdded = function(o)
					return isFontClassTarget(o) and not (FontEditor.data.targetHiddenUi ~= true and isInsideHiddenUiRoot(o))
				end,
				classNames = { "TextLabel", "TextButton", "TextBox" },
			}))
		end

		NAlib.disconnect("FontEditor_PlayerGui")
		if shouldWatch and FontEditor.data.targetPlayerGui then
			NAlib.connect("FontEditor_PlayerGui", NAmanage.pgSub({
				added = onFontDescendantAdded,
				filterAdded = function(o)
					return isFontTarget(o)
				end,
			}))
		end

		NAlib.disconnect("FontEditor_HUI")
		if shouldWatch and FontEditor.data.targetHiddenUi and HUI then
			NAlib.connect("FontEditor_HUI", NAmanage.descSub(HUI, {
				added = onFontDescendantAdded,
				filterAdded = function(o)
					return isFontTarget(o)
				end,
			}))
		end

		NAlib.disconnect("FontEditor_Billboard")
		NAlib.disconnect("FontEditor_Surface")
	end

	const function monitorFontPlayerGui()
		NAlib.disconnect("FontEditor_PlayerGuiAdded")
		NAlib.disconnect("FontEditor_PlayerGuiRemoved")
		if NAmanage.pgSub then
			return
		end
		if not (FontEditor.data.enabled and FontEditor.data.targetPlayerGui) then
			return
		end
		const lp = Services.Players and Services.Players.LocalPlayer
		if not lp then
			return
		end
		NAlib.connect("FontEditor_PlayerGuiAdded", NAmanage.childAdd(lp, function(child)
			if child:IsA("PlayerGui") then
				refreshFontConnections()
				if FontEditor.data.enabled then
					applyAllFonts()
				end
			end
		end, function(child)
			return child and child:IsA("PlayerGui")
		end))
		NAlib.connect("FontEditor_PlayerGuiRemoved", NAmanage.childRem(lp, function(child)
			if child:IsA("PlayerGui") then
				refreshFontConnections()
			end
		end, function(child)
			return child and child:IsA("PlayerGui")
		end))
	end

	const function updateFontTarget(field, value)
		if FontEditor.data[field] == value then
			return
		end
		FontEditor.data[field] = value
		persistFontData()
		refreshFontConnections()
		monitorFontPlayerGui()
		if FontEditor.data.enabled then
			restoreAllFonts()
			applyAllFonts()
		end
	end

	loadCustomFontManifest()
	scanFonts()
	rebuildFontChoices()
	loadFontData()
	setOverrideFont(FontEditor.data.fontKey, { persist = false, apply = false, silent = true })

	if FontEditor.data.enabled then
		refreshFontConnections()
		monitorFontPlayerGui()
		Defer(function()
			if FontEditor.data.enabled then
				applyAllFonts()
			end
		end)
	else
		refreshFontConnections()
		monitorFontPlayerGui()
	end

	NAgui.addSection("Corner Editor")
	NAgui.addToggle("Override Corner Radius", CE.data.enabled, function(v)
		CE.data.enabled = v
		syncCConn()
		monCPGui()
		if CE.data.enabled then
			resetCorn()
			applyCorn()
		else
			resetCorn()
		end
		saveCData()
	end)
	NAgui.addToggle("Corner Target: CoreGui", CE.data.targetCoreGui, function(v)
		setCTgt("targetCoreGui", v == true)
	end)
	NAgui.addToggle("Corner Target: PlayerGui", CE.data.targetPlayerGui, function(v)
		setCTgt("targetPlayerGui", v == true)
	end)
	NAgui.addToggle("Corner Target: BillboardGui", CE.data.targetBillboardGui, function(v)
		setCTgt("targetBillboardGui", v == true)
	end)
	NAgui.addToggle("Corner Target: SurfaceGui", CE.data.targetSurfaceGui, function(v)
		setCTgt("targetSurfaceGui", v == true)
	end)
	NAgui.addToggle("Corner Target: gethui/hiddenui", CE.data.targetHiddenUi, function(v)
		setCTgt("targetHiddenUi", v == true)
	end)
	const sliderRadius = math.clamp(CE.data.radius, 0, 64)
	NAgui.addSlider("Corner Radius", 0, 64, sliderRadius, 0.5, " px", function(v)
		const parsed = math.clamp(tonumber(v) or CE.default.radius, 0, 64)
		CE.data.radius = parsed
		if CE.data.enabled then
			applyCorn()
		end
		saveCData()
	end)

	NAgui.addSection("Font Changer")
	NAgui.addToggle("Override Text Font", FontEditor.data.enabled, function(v)
		FontEditor.data.enabled = v
		refreshFontConnections()
		monitorFontPlayerGui()
		if FontEditor.data.enabled then
			restoreAllFonts()
			applyAllFonts()
		else
			restoreAllFonts()
		end
		persistFontData()
	end)
	NAgui.addToggle("Font Target: CoreGui", FontEditor.data.targetCoreGui, function(v)
		updateFontTarget("targetCoreGui", v == true)
	end)
	NAgui.addToggle("Font Target: PlayerGui", FontEditor.data.targetPlayerGui, function(v)
		updateFontTarget("targetPlayerGui", v == true)
	end)
	NAgui.addToggle("Font Target: BillboardGui", FontEditor.data.targetBillboardGui, function(v)
		updateFontTarget("targetBillboardGui", v == true)
	end)
	NAgui.addToggle("Font Target: SurfaceGui", FontEditor.data.targetSurfaceGui, function(v)
		updateFontTarget("targetSurfaceGui", v == true)
	end)
	NAgui.addToggle("Font Target: gethui/hiddenui", FontEditor.data.targetHiddenUi, function(v)
		updateFontTarget("targetHiddenUi", v == true)
	end)
	const fontInfoBox = NAgui.addInfo("Current Font", FontEditor.data.font)
	const function refreshFontInfo()
		if fontInfoBox then
			fontInfoBox.Text = FontEditor.data.font
		end
	end
	local cfInfo
	const cfCycleLabel = "Cycle Custom Fonts Only"
	const cfNameLabel = "Custom Font Name"
	const cfUrlLabel = "Custom Font URL"
	const fontDropdownLabel = "Select Font"
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
	const function refreshFontDropdown()
		const choices = getActiveFontChoices()
		local options = {}
		local selected = "None"
		const currentKey = FontEditor.data.fontKey or FontEditor.default.fontKey
		for _, choice in choices do
			const label = tostring(choice.label or choice.key or "Font")
			Insert(options, label)
			if choice.key == currentKey then
				selected = label
			end
		end
		if #options == 0 then
			options = { "None" }
			selected = "None"
		elseif selected == "None" then
			selected = options[1]
		end
		if NAgui.setDropdownOptions then
			NAgui.setDropdownOptions(fontDropdownLabel, options)
		end
		if NAgui.setDropdownValue then
			NAgui.setDropdownValue(fontDropdownLabel, selected, { fire = false })
		end
	end
	const function refreshFontUI()
		if scanFonts() then
			rebuildFontChoices()
		end
		if cfInfo then
			cfInfo.Text = formatCustomFontStatus()
		end
		if not hasCustomFonts() and NAgui.setToggleState then
			NAgui.setToggleState(cfCycleLabel, false, { force = true, fire = false })
		end
		refreshFontDropdown()
	end
	const function openFontDeletePopup()
		if not hasCustomFonts() then
			DoNotif("No custom fonts installed.", 3)
			return
		end
		if type(Popup) ~= "function" then
			DoNotif("Popup UI is unavailable in this session.", 3)
			return
		end
		const buttons = {}
		for _, entry in FontEditor.customFonts do
			const label = (entry.displayName or entry.name or entry.id) or "Custom Font"
			Insert(buttons, {
				Text = label,
				Callback = function()
					const key = entry.id and ("custom:"..entry.id) or nil
					const wasCurrent = key and FontEditor.data.fontKey == key
					removeCustomFontEntry(entry, { deleteFiles = true })
					rebuildFontChoices()
					if wasCurrent then
						setOverrideFont(FontEditor.default.fontKey)
						refreshFontInfo()
					end
					refreshFontUI()
					DoNotif(Format("Removed custom font \"%s\".", label), 2)
				end,
			})
		end
		Insert(buttons, { Text = "Cancel", Callback = function() end })
		Popup({
			Title = "Remove Custom Font",
			Description = "Select a custom font to delete.",
			Duration = 0,
			Buttons = buttons,
		})
	end
	refreshFontInfo()
	NAgui.addDropdown(fontDropdownLabel, { "None" }, "None", function(selection)
		const selected = getDropdownText(selection)
		if not selected or Lower(selected) == "none" then
			return
		end
		const choices = getActiveFontChoices()
		for _, choice in choices do
			if tostring(choice.label or "") == selected then
				setOverrideFont(choice.key)
				refreshFontInfo()
				refreshFontUI()
				return
			end
		end
		refreshFontDropdown()
	end)
	NAgui.addButton("Reset Font", function()
		setOverrideFont(FontEditor.default.fontKey)
		refreshFontInfo()
		refreshFontUI()
	end)
	cfInfo = NAgui.addInfo("Custom Fonts", formatCustomFontStatus())
	refreshFontUI()
	FontEditor.refreshFontDropdown = refreshFontDropdown
	FontEditor.refreshCustomFontUI = refreshFontUI
	NAgui.addToggle(cfCycleLabel, FontEditor.data.useCustomCycle and hasCustomFonts(), function(v)
		if v and not hasCustomFonts() then
			DoNotif("Install a custom font first.", 3)
			if NAgui.setToggleState then
				NAgui.setToggleState(cfCycleLabel, false, { force = true, fire = false })
			end
			return
		end
		FontEditor.data.useCustomCycle = v == true
		persistFontData()
		refreshFontUI()
	end)
	NAgui.addSection("Custom Font Loader")
	NAgui.addInput(cfNameLabel, "Display name (optional)", FontEditor.customInputs.name, function(text)
		FontEditor.customInputs.name = text or ""
	end)
	NAgui.addInput(cfUrlLabel, "Font URL (GitHub/raw/external)", FontEditor.customInputs.url, function(text)
		FontEditor.customInputs.url = text or ""
	end)
	NAgui.addButton("Download Custom Font", function()
		if not FileSupport then
			DoNotif("Custom fonts require file support.", 3)
			return
		end
		local ok, result = addOrUpdateCustomFont(FontEditor.customInputs.name, FontEditor.customInputs.url)
		if ok and type(result) == "table" then
			const function clearInputs()
				if NAgui.setInputValue then
					NAgui.setInputValue(cfNameLabel, "", { force = true, fire = false })
					NAgui.setInputValue(cfUrlLabel, "", { force = true, fire = false })
				end
				FontEditor.customInputs.name = ""
				FontEditor.customInputs.url = ""
			end
			if result.multi and type(result.entries) == "table" and #result.entries > 0 then
				const lastEntry = result.entries[#result.entries]
				if lastEntry and lastEntry.id then
					setOverrideFont("custom:"..lastEntry.id)
				end
				refreshFontInfo()
				refreshFontUI()
				clearInputs()
				const count = result.count or #result.entries
				DoNotif(Format("Installed %d font%s from folder.", count, count == 1 and "" or "s"), 2)
			elseif result.id then
				setOverrideFont("custom:"..result.id)
				refreshFontInfo()
				refreshFontUI()
				clearInputs()
				DoNotif("Custom font saved.", 2)
			else
				refreshFontInfo()
				refreshFontUI()
				clearInputs()
				DoNotif("Custom font saved.", 2)
			end
		else
			DoNotif(result or "Unable to save custom font.", 3)
		end
	end)
	NAgui.addButton("Download NA Fonts", function()
		if FontEditor.dlBusy then
			DoNotif("Preset font download already running.", 3)
			return
		end
		FontEditor.dlBusy = true
		local ok, res = dlNAFonts()
		FontEditor.dlBusy = false
		if ok then
			refreshFontInfo()
			refreshFontUI()
			DoNotif(Format("Installed %d NA font%s.", res, res == 1 and "" or "s"), 2)
		else
			DoNotif(res or "Unable to download NA fonts.", 3)
		end
	end)
	NAgui.addButton("Remove Custom Font...", openFontDeletePopup)
	NAgui.addButton("Reload Custom Fonts", function()
		loadCustomFontManifest()
		scanFonts()
		rebuildFontChoices()
		setOverrideFont(FontEditor.data.fontKey, { persist = false, apply = false, silent = true })
		refreshFontInfo()
		refreshFontUI()
		DoNotif("Custom fonts reloaded.", 2)
	end)
	NAgui.addButton("Remove All Custom Fonts", function()
		if not hasCustomFonts() then
			DoNotif("No custom fonts installed.", 3)
			return
		end
		const wasCustom = type(FontEditor.data.fontKey) == "string" and FontEditor.data.fontKey:find("^custom:") == 1
		removeAllCustomFonts()
		if wasCustom then
			setOverrideFont(FontEditor.default.fontKey)
			refreshFontInfo()
		end
		refreshFontUI()
		DoNotif("Removed all custom fonts.", 2)
	end)

	const Icfg = {
		path = NAfiles.NAICONSETTINGSPATH or (NAfiles.NAFILEPATH.."/custom_icon.json"),
		def = {
			enabled = false,
			assetId = "",
			localPath = "",
			index = 0,
		},
	}

	const function loadIcfg()
		local d = Icfg.def
		if FileSupport then
			if not NAmanage.safeIsFile(Icfg.path) then
				NAmanage.safeWriteFile(Icfg.path, Services.HttpService:JSONEncode(Icfg.def))
			end
			local ok, raw = pcall(readfile, Icfg.path)
			if ok and type(raw) == "string" then
				local okD, dec = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
				if okD and type(dec) == "table" then
					d = dec
				end
			end
		end
		return d
	end

	const function saveIcfg()
		if not FileSupport then
			return
		end
		const payload = {
			enabled = NAStuff.CustomIcon.enabled == true,
			assetId = typeof(NAStuff.CustomIcon.assetId) == "string" and NAStuff.CustomIcon.assetId or "",
			localPath = typeof(NAStuff.CustomIcon.localPath) == "string" and NAStuff.CustomIcon.localPath or "",
			index = tonumber(NAStuff.CustomIcon.index) or 0,
		}
		pcall(writefile, Icfg.path, Services.HttpService:JSONEncode(payload))
	end

	NAStuff.iconAppearance = NAStuff.iconAppearance or {
		background = NAStuff.NAICONMAIN.BackgroundTransparency;
		text = (NAStuff.IconFallbackLabel and NAStuff.IconFallbackLabel.TextTransparency) or (NAStuff.NAICONMAIN:IsA("TextButton") and NAStuff.NAICONMAIN.TextTransparency) or nil;
		stroke = (NAStuff.IconFallbackLabel and NAStuff.IconFallbackLabel.TextStrokeTransparency) or (NAStuff.NAICONMAIN:IsA("TextButton") and NAStuff.NAICONMAIN.TextStrokeTransparency) or nil;
		image = NAStuff.NAICONMAIN:IsA("ImageButton") and NAStuff.NAICONMAIN.ImageTransparency or nil;
	}

	NAStuff.IconSrc = NAStuff.IconSrc or {
		list = "https://api.github.com/repos/ltseverydayyou/uuuuuuu/contents/NAicons?ref=main";
		raw = "https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/NAicons/";
	}

	NAStuff.CustomIcon = NAStuff.CustomIcon or {}
	NAStuff.CustomIcon.entries = NAStuff.CustomIcon.entries or {}
	NAStuff.CustomIcon.index = NAStuff.CustomIcon.index or 0

	NAgui.iconFsOk = function()
		return FileSupport and type(writefile) == "function" and type(getcustomasset) == "function"
	end

	const icfg = loadIcfg()
	if type(icfg) == "table" then
		if typeof(icfg.assetId) == "string" and icfg.assetId ~= "" then
			NAStuff.CustomIcon.assetId = icfg.assetId
		end
		if typeof(icfg.localPath) == "string" and icfg.localPath ~= "" then
			NAStuff.CustomIcon.localPath = icfg.localPath
		end
		if typeof(icfg.enabled) == "boolean" then
			NAStuff.CustomIcon.enabled = icfg.enabled
		end
		if typeof(icfg.index) == "number" then
			NAStuff.CustomIcon.index = icfg.index
		end
	end

	if typeof(NAStuff.CustomIcon.localPath) == "string"
		and NAStuff.CustomIcon.localPath ~= ""
		and NAgui.iconFsOk()
	then
		local okA, assetFromFile = pcall(getcustomasset, NAStuff.CustomIcon.localPath)
		if okA and typeof(assetFromFile) == "string" then
			NAStuff.CustomIcon.assetId = assetFromFile
		end
	end

	NAgui.getNAIconList = function()
		const src = NAStuff.IconSrc
		if not src or typeof(src.list) ~= "string" or src.list == "" then
			return false, "NA icon catalog URL not configured."
		end
		local ok, raw = pcall(function()
			return NAmanage.HttpGetOrError(src.list, { Headers = { Accept = "application/json" } })
		end)
		if not (ok and typeof(raw) == "string" and raw ~= "") then
			return false, "Unable to fetch NA icon catalog."
		end
		local okD, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if not (okD and type(decoded) == "table") then
			return false, "Invalid NA icon catalog."
		end
		const items = {}
		if #decoded > 0 then
			for _, entry in decoded do
				items[#items + 1] = entry
			end
		else
			for _, entry in decoded do
				if type(entry) == "table" then
					items[#items + 1] = entry
				end
			end
		end
		const icons = {}
		for _, e in items do
			if type(e) == "table" and type(e.name) == "string" and e.type == "file" then
				const url = e.download_url or (src.raw and (src.raw..e.name))
				if type(url) == "string" and url ~= "" then
					icons[#icons + 1] = {
						name = e.name;
						url = url;
					}
				end
			end
		end
		if #icons == 0 then
			return false, "No NA icons available."
		end
		return true, icons
	end
	NAgui.downloadNAIcons = function()
		if not NAgui.iconFsOk() then
			return false, "Custom icons require file support and getcustomasset."
		end
		if not NAgui.ensureIconFolder() then
			return false, "Unable to prepare CustomIcon folder."
		end
		local okList, icons = NAgui.getNAIconList()
		if not okList then
			return false, icons
		end
		local count = 0
		local lastErr = nil
		for _, ico in icons do
			local okSave, errOrAsset = NAgui.iconSaveFromUrl(ico.url)
			if okSave then
				count += 1
			else
				lastErr = errOrAsset
			end
		end
		if count == 0 then
			return false, lastErr or "No NA icons downloaded."
		end
		return true, count
	end

	NAgui.ensureIconFolder = function()
		if not FileSupport then
			return false
		end
		const dir = NAfiles.NACUSTOMICONPATH
		if typeof(dir) ~= "string" or dir == "" then
			return false
		end
		if type(isfolder) == "function" then
			local ok, exists = pcall(isfolder, dir)
			if ok and exists then
				return true
			end
			if type(makefolder) ~= "function" then
				return false
			end
			const okMk = pcall(makefolder, dir)
			return okMk == true
		end
		return true
	end

	const function getDefaultNAIconAsset()
		const existing = NAStuff.CustomIcon.defaultImage
		if typeof(existing) == "string" and existing ~= "" then
			return existing
		end
		if type(getcustomasset) == "function"
			and NAfiles and NAfiles.NAASSETSFILEPATH
			and NAImageAssets and typeof(NAImageAssets.Icon) == "string" and NAImageAssets.Icon ~= ""
		then
			const asset = NAmanage.getNAImageAsset("Icon", "")
			if typeof(asset) == "string" and asset ~= "" then
				return asset
			end
		end
		return ""
	end

	const function resetCustomIconToDefault()
		const defaultImage = getDefaultNAIconAsset()
		if defaultImage ~= "" then
			NAStuff.CustomIcon.defaultImage = defaultImage
		end
		NAStuff.CustomIcon.localPath = nil
		NAStuff.CustomIcon.assetId = nil
		NAStuff.CustomIcon.index = 0
		NAStuff.CustomIcon.enabled = false
		if type(NAgui._applyIconState) == "function" then
			NAgui._applyIconState()
		end
		saveIcfg()
		if NAgui.setToggleState then
			NAgui.setToggleState("Use Custom NA Icon", false, { force = true, fire = false })
		end
	end

	NAgui.iconPreUrl = function(u)
		if typeof(u) ~= "string" then
			return nil
		end
		local t = u:match("^%s*(.-)%s*$") or ""
		if t == "" then
			return nil
		end
		t = t:gsub(" ", "%%20")
		const q = t:find("%?")
		const base = q and t:sub(1, q - 1) or t
		return t, base
	end

	NAgui.iconNormUrl = function(u)
		local t, base = NAgui.iconPreUrl(u)
		if not t then
			return nil
		end
		local owner, repo, kind, rest = base:match("^https?://github.com/([^/]+)/([^/]+)/([^/]+)/(.+)$")
		if owner and repo and kind and rest then
			local s = rest
			if s:sub(1, 11) == "refs/heads/" then
				s = s:sub(12)
			elseif s:sub(1, 10) == "refs/tags/" then
				s = s:sub(11)
			end
			local branch, path = s:match("^([^/]+)/(.+)$")
			if branch and path and (kind == "blob" or kind == "raw") then
				branch = branch:gsub("%%2[Ff]", "/")
				path = path:gsub("%%2[Ff]", "/")
				return Format("https://raw.githubusercontent.com/%s/%s/%s/%s", owner, repo, branch, path)
			end
		end
		const rawDir = base:match("^https?://raw%.githubusercontent%.com/.+")
		if rawDir then
			return t
		end
		return t
	end

	NAgui.scanCustomIcons = function()
		if not (FileSupport and listfiles) then
			return
		end
		if not NAgui.ensureIconFolder() then
			return
		end
		const dir = NAfiles.NACUSTOMICONPATH
		local ok, items = pcall(listfiles, dir)
		if not (ok and type(items) == "table") then
			return
		end
		const list = {}
		for _, fullPath in items do
			const name = getFName(fullPath)
			if name then
				list[#list + 1] = { file = name }
			end
		end
		NAStuff.CustomIcon.entries = list
		const hasLocalPath = typeof(NAStuff.CustomIcon.localPath) == "string" and NAStuff.CustomIcon.localPath ~= ""
		local idx = 0
		if hasLocalPath then
			const cur = getFName(NAStuff.CustomIcon.localPath)
			if cur then
				for i, e in list do
					if e.file == cur then
						idx = i
						break
					end
				end
			end
		end
		if #list == 0 and hasLocalPath then
			resetCustomIconToDefault()
			return
		end
		if idx == 0 and #list > 0 then
			idx = 1
		end
		NAStuff.CustomIcon.index = idx
	end

	NAgui.formatCustomIconStatus = function()
		const list = NAStuff.CustomIcon.entries or {}
		const n = #list
		if n == 0 then
			return "No custom icons installed"
		end
		if n == 1 then
			return "1 custom icon installed"
		end
		return tostring(n).." custom icons installed"
	end

	NAgui.refreshCustomIconUI = function()
		const info = NAStuff.CustomIcon.info
		if info then
			info.Text = NAgui.formatCustomIconStatus()
		end
		const syncDropdown = NAStuff.CustomIcon and NAStuff.CustomIcon.refreshDropdown
		if type(syncDropdown) == "function" then
			pcall(syncDropdown)
		end
	end

	NAgui.iconSaveFromUrl = function(url)
		if not NAgui.iconFsOk() then
			return false, "Custom image icons require file support and getcustomasset."
		end
		if not NAgui.ensureIconFolder() then
			return false, "Unable to prepare CustomIcon folder."
		end
		const norm = NAgui.iconNormUrl(url)
		if not norm then
			return false, "Enter a valid image URL or asset id."
		end
		local ok, data = NAmanage.HttpGet(norm, { timeout = 10 })
		if not (ok and typeof(data) == "string" and data ~= "") then
			return false, "Unable to download custom icon image."
		end
		const safeName = deriveLegacyIconFileNameFromUrl(norm)
		const fullPath = NAfiles.NACUSTOMICONPATH.."/"..safeName
		local okW, errW = pcall(writefile, fullPath, data)
		if not okW then
			return false, errW or "Unable to save custom icon image."
		end
		local okA, asset = pcall(getcustomasset, fullPath)
		if not (okA and typeof(asset) == "string") then
			return false, "Unable to load custom icon image."
		end
		NAStuff.CustomIcon.localPath = fullPath
		const list = NAStuff.CustomIcon.entries or {}
		local idx = nil
		for i, e in list do
			if e.file == safeName then
				idx = i
				break
			end
		end
		if not idx then
			list[#list + 1] = { file = safeName }
			idx = #list
		end
		NAStuff.CustomIcon.entries = list
		NAStuff.CustomIcon.index = idx
		return true, asset
	end

	if NAmanage and type(NAmanage.NASettingsGet) == "function" then
		const storedAsset = NAmanage.NASettingsGet("customIconAssetId")
		const storedPath = NAmanage.NASettingsGet("customIconLocalPath")
		const storedEnabled = NAmanage.NASettingsGet("customIconEnabled")
		const hasAsset = typeof(NAStuff.CustomIcon.assetId) == "string" and NAStuff.CustomIcon.assetId ~= ""
		const hasPath = typeof(NAStuff.CustomIcon.localPath) == "string" and NAStuff.CustomIcon.localPath ~= ""
		const hasEnabled = typeof(NAStuff.CustomIcon.enabled) == "boolean"

		if not hasAsset and not hasPath then
			if typeof(storedPath) == "string" and storedPath ~= "" and NAgui.iconFsOk() then
				NAStuff.CustomIcon.localPath = storedPath
				local okA, assetFromFile = pcall(getcustomasset, storedPath)
				if okA and typeof(assetFromFile) == "string" then
					NAStuff.CustomIcon.assetId = assetFromFile
				elseif typeof(storedAsset) == "string" and storedAsset ~= "" then
					NAStuff.CustomIcon.assetId = storedAsset
				end
			elseif typeof(storedAsset) == "string" and storedAsset ~= "" then
				NAStuff.CustomIcon.assetId = storedAsset
			end
		end

		if not hasEnabled and typeof(storedEnabled) == "boolean" then
			NAStuff.CustomIcon.enabled = storedEnabled
		end
	end

	if NAgui.iconSupported() and NAStuff.NAICONMAIN and typeof(NAStuff.NAICONMAIN.Image) == "string" and NAStuff.NAICONMAIN.Image ~= "" then
		NAStuff.CustomIcon.defaultImage = NAStuff.CustomIcon.defaultImage or NAStuff.NAICONMAIN.Image
	end

	if typeof(NAStuff.CustomIcon.assetId) ~= "string" or NAStuff.CustomIcon.assetId == "" then
		NAStuff.CustomIcon.assetId = nil
	end

	if typeof(NAStuff.CustomIcon.enabled) ~= "boolean" then
		NAStuff.CustomIcon.enabled = false
	end

	NAgui._saveIconSettings = function()
		saveIcfg()
	end

	NAgui.getIconDigits = function()
		if typeof(NAStuff.CustomIcon.assetId) == "string" then
			return NAStuff.CustomIcon.assetId:match("(%d+)$") or ""
		end
		return ""
	end

	NAgui._applyIconState = function()
		if not NAgui.iconSupported() then
			return false
		end
		const state = NAStuff.CustomIcon
		local targetImage
		if state.enabled and typeof(state.assetId) == "string" and state.assetId ~= "" then
			targetImage = state.assetId
		elseif typeof(state.defaultImage) == "string" and state.defaultImage ~= "" then
			targetImage = state.defaultImage
		end
		local applied = false
		if targetImage and targetImage ~= "" then
			NAStuff.NAICONMAIN.Image = targetImage
			applied = true
		else
			NAStuff.NAICONMAIN.Image = ""
		end
		if NAStuff.IconFallbackLabel then
			NAStuff.IconFallbackLabel.Visible = not applied
		end
		return applied
	end

	NAgui.useCustomIconEntry = function(entry, opts)
		opts = opts or {}
		if not NAgui.iconSupported() then
			return false, "Custom icon requires getcustomasset support for the NA icon."
		end
		if not entry or not entry.file then
			return false, "No custom icon entry."
		end
		if not NAgui.ensureIconFolder() then
			return false, "Unable to prepare CustomIcon folder."
		end
		const fullPath = NAfiles.NACUSTOMICONPATH.."/"..entry.file
		if type(isfile) == "function" then
			local okEx, ex = pcall(isfile, fullPath)
			if not (okEx and ex) then
				return false, "Custom icon file is missing."
			end
		end
		local okA, asset = pcall(getcustomasset, fullPath)
		if not (okA and typeof(asset) == "string") then
			return false, "Unable to load custom icon image."
		end
		NAStuff.CustomIcon.localPath = fullPath
		NAStuff.CustomIcon.assetId = asset
		if opts.autoEnable ~= false then
			NAStuff.CustomIcon.enabled = true
		end
		NAgui._applyIconState()
		NAgui._saveIconSettings()
		return true
	end

	NAgui.cycleCustomIcon = function(delta)
		const list = NAStuff.CustomIcon.entries or {}
		if #list == 0 then
			DoNotif("No custom icons installed.", 3)
			return
		end
		delta = delta or 1
		local idx = NAStuff.CustomIcon.index or 0
		if idx < 1 or idx > #list then
			idx = 1
		end
		idx = ((idx - 1 + delta) % #list) + 1
		local ok, err = NAgui.useCustomIconEntry(list[idx])
		if not ok then
			if err then
				DoNotif(err, 3)
			end
			return
		end
		NAStuff.CustomIcon.index = idx
	end

	NAgui.setIconEnabled = function(enabled, opts)
		opts = opts or {}
		if not NAgui.iconSupported() then
			return false, "Custom icon requires getcustomasset support for the NA icon."
		end
		enabled = enabled and true or false
		if enabled and not NAStuff.CustomIcon.assetId then
			if not opts.skipToggle and NAgui.setToggleState then
				NAgui.setToggleState("Use Custom NA Icon", false, { force = true, fire = false })
			end
			return false, "Add an asset id or URL before enabling the custom icon."
		end
		if NAStuff.CustomIcon.enabled == enabled and not opts.force then
			return true
		end
		NAStuff.CustomIcon.enabled = enabled
		NAgui._applyIconState()
		if not opts.skipToggle and NAgui.setToggleState then
			NAgui.setToggleState("Use Custom NA Icon", enabled, { force = true, fire = false })
		end
		NAgui._saveIconSettings()
		return true
	end

	NAgui.setIconAsset = function(inputValue, opts)
		opts = opts or {}
		if not NAgui.iconSupported() then
			return false, "Custom icon requires getcustomasset support for the NA icon."
		end
		local raw = typeof(inputValue) == "string" and inputValue or tostring(inputValue)
		if typeof(raw) ~= "string" then
			return false, "Enter a valid asset id or image URL."
		end
		raw = raw:match("^%s*(.-)%s*$")
		if raw == "" then
			return false, "Enter a valid asset id or image URL."
		end
		const digits = raw:match("^rbxassetid://(%d+)$") or raw:match("id=(%d+)") or raw:match("^(%d+)$")
		local newAsset
		NAStuff.CustomIcon.localPath = nil
		if digits then
			newAsset = "rbxassetid://"..digits
		else
			local t, base = NAgui.iconPreUrl(raw)
			if not t then
				return false, "Enter a valid asset id or image URL."
			end
			const folderInfo = parseGitHubFolderUrl(base, t)
			if folderInfo then
				local okFolder, res = NAgui.installIconsFromGitHubFolder(folderInfo)
				if not okFolder then
					return false, res or "Unable to save custom icon."
				end
				NAgui.scanCustomIcons()
				NAgui.refreshCustomIconUI()
				newAsset = res and res.asset
				if not newAsset then
					return false, "Installed icons but failed to apply one of them."
				end
			else
				local okIcon, r = NAgui.iconSaveFromUrl(t)
				if not okIcon then
					return false, r or "Unable to save custom icon."
				end
				newAsset = r
			end
		end
		NAStuff.CustomIcon.assetId = newAsset
		if opts.autoEnable ~= false then
			NAStuff.CustomIcon.enabled = true
		end
		NAgui._applyIconState()
		if opts.autoEnable ~= false and not opts.skipToggle and NAgui.setToggleState then
			NAgui.setToggleState("Use Custom NA Icon", true, { force = true, fire = false })
		end
		NAgui._saveIconSettings()
		if digits then
			return true, digits
		end
		return true, raw
	end

	if NAStuff.CustomIcon.enabled and NAStuff.CustomIcon.assetId and NAgui.iconSupported() then
		NAgui._applyIconState()
	end

	NAgui.scanCustomIcons()

	NAStuff.CustomIcon.pendingInput = NAStuff.CustomIcon.pendingInput or ((NAgui.getIconDigits and NAgui.getIconDigits()) or "")

	const function deleteIconFile(name)
		if type(name) ~= "string" or name == "" then
			return
		end
		if type(isfile) ~= "function" or type(delfile) ~= "function" then
			return
		end
		const full = NAfiles.NACUSTOMICONPATH.."/"..name
		local okEx, ex = pcall(isfile, full)
		if okEx and ex then
			pcall(delfile, full)
		end
	end

	const function clearCurrentIconIf(fileName)
		if type(fileName) ~= "string" or fileName == "" then
			return
		end
		const full = NAfiles.NACUSTOMICONPATH.."/"..fileName
		if NAStuff.CustomIcon.localPath == full then
			NAStuff.CustomIcon.localPath = nil
			NAStuff.CustomIcon.assetId = nil
			NAStuff.CustomIcon.index = 0
			NAStuff.CustomIcon.enabled = false
			NAgui._applyIconState()
			if NAgui.setToggleState then
				NAgui.setToggleState("Use Custom NA Icon", false, { force = true, fire = false })
			end
			NAgui._saveIconSettings()
		end
	end

	const function removeCustomIconEntry(entry)
		if not (entry and entry.file) then
			return
		end
		deleteIconFile(entry.file)
		clearCurrentIconIf(entry.file)
		NAgui.scanCustomIcons()
		NAgui.refreshCustomIconUI()
	end

	const function removeAllCustomIcons()
		const list = NAStuff.CustomIcon.entries or {}
		for _, entry in list do
			if entry and entry.file then
				deleteIconFile(entry.file)
			end
		end
		NAStuff.CustomIcon.entries = {}
		NAStuff.CustomIcon.index = 0
		NAStuff.CustomIcon.localPath = nil
		NAStuff.CustomIcon.assetId = nil
		NAStuff.CustomIcon.enabled = false
		NAgui._applyIconState()
		if NAgui.setToggleState then
			NAgui.setToggleState("Use Custom NA Icon", false, { force = true, fire = false })
		end
		NAgui._saveIconSettings()
		NAgui.scanCustomIcons()
		NAgui.refreshCustomIconUI()
	end

	const function openIconDeletePopup()
		const list = NAStuff.CustomIcon.entries or {}
		if #list == 0 then
			DoNotif("No custom icons installed.", 3)
			return
		end
		if type(Popup) ~= "function" then
			DoNotif("Popup UI is unavailable in this session.", 3)
			return
		end
		const buttons = {}
		for _, entry in list do
			const label = entry.file or "Custom Icon"
			Insert(buttons, {
				Text = label,
				Callback = function()
					removeCustomIconEntry(entry)
					DoNotif('Removed custom icon "'..label..'".', 2)
				end,
			})
		end
		Insert(buttons, { Text = "Cancel", Callback = function() end })
		Popup({
			Title = "Remove Custom Icon",
			Description = "Select a custom icon to delete.",
			Duration = 0,
			Buttons = buttons,
		})
	end

	NAgui.addSection("Custom NA Icon")

	NAStuff.CustomIcon.info = NAgui.addInfo("Custom Icons", NAgui.formatCustomIconStatus())
	NAgui.refreshCustomIconUI()

	NAgui.addToggle("Use Custom NA Icon", NAStuff.CustomIcon.enabled == true and NAgui.iconSupported(), function(v)
		if not NAgui.iconSupported() then
			DoNotif("Custom icon requires getcustomasset support for the NA icon.", 3)
			if NAgui.setToggleState then
				NAgui.setToggleState("Use Custom NA Icon", false, { force = true, fire = false })
			end
			return
		end
		local ok, err = NAgui.setIconEnabled(v, { skipToggle = true })
		if not ok then
			if err then
				DoNotif(err, 3)
			end
			if NAgui.setToggleState then
				NAgui.setToggleState("Use Custom NA Icon", NAStuff.CustomIcon.enabled == true, { force = true, fire = false })
			end
			return
		end
		DoNotif("Custom NA Icon "..(v and "enabled" or "disabled"), 2)
	end)

	NAmanage.RegisterToggleAutoSync("Use Custom NA Icon", function()
		return NAStuff.CustomIcon.enabled == true and NAgui.iconSupported()
	end)

	NAgui.addInput("Custom Icon Asset / URL", "Enter asset id or image URL", NAStuff.CustomIcon.pendingInput, function(text)
		NAStuff.CustomIcon.pendingInput = text or ""
	end)

	NAgui.addButton("Apply Custom Icon", function()
		if not NAgui.iconSupported() then
			DoNotif("Custom icon requires getcustomasset support for the NA icon.", 3)
			return
		end
		local ok, result = NAgui.setIconAsset(NAStuff.CustomIcon.pendingInput)
		if ok then
			NAStuff.CustomIcon.pendingInput = ""
			if NAgui.setInputValue then
				NAgui.setInputValue("Custom Icon Asset / URL", "", { force = true, fire = false })
			end
			NAgui.scanCustomIcons()
			NAgui.refreshCustomIconUI()
			DoNotif("Custom NA Icon updated.", 2)
		else
			DoNotif(result or "Unable to update custom icon.", 3)
		end
	end)

	const customIconDropdownLabel = "Select Custom Icon"
	const function getSelectedIconName(selection)
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
		if Lower(value) == "none" then
			return nil
		end
		return value
	end

	const function useCustomIconByName(iconName, opts)
		opts = opts or {}
		const wanted = getSelectedIconName(iconName)
		if not wanted then
			return false, "No custom icon selected."
		end
		const list = NAStuff.CustomIcon.entries or {}
		local targetEntry, targetIndex
		for i, entry in list do
			if entry and entry.file == wanted then
				targetEntry = entry
				targetIndex = i
				break
			end
		end
		if not targetEntry then
			return false, "Selected custom icon is missing."
		end
		local okUse, errUse = NAgui.useCustomIconEntry(targetEntry)
		if not okUse then
			return false, errUse or "Unable to apply selected custom icon."
		end
		NAStuff.CustomIcon.index = targetIndex or NAStuff.CustomIcon.index
		if NAgui.setToggleState then
			NAgui.setToggleState("Use Custom NA Icon", true, { force = true, fire = false })
		end
		if opts.notify then
			DoNotif('Applied custom icon "'..wanted..'".', 2)
		end
		return true
	end

	const function refreshCustomIconDropdown()
		const list = NAStuff.CustomIcon.entries or {}
		local options = {}
		local selectedName = "None"

		if #list > 0 then
			const currentName = (type(getFName) == "function" and getFName(NAStuff.CustomIcon.localPath)) or nil
			for i, entry in list do
				if entry and entry.file then
					Insert(options, entry.file)
					if currentName and entry.file == currentName then
						selectedName = entry.file
						NAStuff.CustomIcon.index = i
					end
				end
			end
			if selectedName == "None" and #options > 0 then
				const idx = tonumber(NAStuff.CustomIcon.index)
				if idx and options[idx] then
					selectedName = options[idx]
				else
					selectedName = options[1]
				end
			end
		else
			options = { "None" }
			NAStuff.CustomIcon.index = 0
		end

		if NAgui.setDropdownOptions then
			NAgui.setDropdownOptions(customIconDropdownLabel, options)
		end
		if NAgui.setDropdownValue then
			NAgui.setDropdownValue(customIconDropdownLabel, selectedName, { fire = false })
		end
	end

	NAStuff.CustomIcon.refreshDropdown = refreshCustomIconDropdown
	NAgui.addDropdown(customIconDropdownLabel, { "None" }, "None", function(selection)
		const chosen = getSelectedIconName(selection)
		if not chosen then
			return
		end
		local okUse, errUse = useCustomIconByName(chosen, { notify = true })
		if not okUse and errUse then
			DoNotif(errUse, 3)
		end
		NAgui.refreshCustomIconUI()
	end)
	refreshCustomIconDropdown()

	NAgui.addButton("Download NA Icons", function()
		local ok, res = NAgui.downloadNAIcons()
		if ok then
			NAgui.scanCustomIcons()
			NAgui.refreshCustomIconUI()
			DoNotif(Format("Installed %d NA icon%s.", res, res == 1 and "" or "s"), 2)
		else
			DoNotif(res or "Unable to download NA icons.", 3)
		end
	end)

	NAgui.addButton("Reload Custom Icons", function()
		NAgui.scanCustomIcons()
		NAgui.refreshCustomIconUI()
		DoNotif("Custom icons reloaded.", 2)
	end)

	NAgui.addButton("Remove Custom Icon...", openIconDeletePopup)

	NAgui.addButton("Remove All Custom Icons", function()
		const list = NAStuff.CustomIcon.entries or {}
		if #list == 0 then
			DoNotif("No custom icons installed.", 3)
			return
		end
		removeAllCustomIcons()
		DoNotif("Removed all custom icons.", 2)
	end)
end

NAScale = 1
NAUIScale = 1
NA_UI_SCALE_MIN = 0.5
NA_UI_SCALE_MAX = 2.5

NAmanage.ClampUIScale = function(value, fallback)
	local n = tonumber(value)
	if not n then
		n = tonumber(fallback)
	end
	if not n then
		n = tonumber(NAUIScale) or 1
	end
	return math.clamp(n, NA_UI_SCALE_MIN, NA_UI_SCALE_MAX)
end

NAmanage.ApplyUIScale = function(value, opts)
	opts = opts or {}
	const clamped = NAmanage.ClampUIScale(value, opts.fallback)
	NAUIScale = clamped

	const scaler = (opt and opt.NAAUTOSCALER) or (NAUIMANAGER and NAUIMANAGER.AUTOSCALER)
	if scaler then
		scaler.Scale = clamped
	end

	if opts.save ~= false and NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "uiScale", clamped)
	end

	if opts.syncUI ~= false and NAmanage.SyncUIScaleUI then
		NAmanage.SyncUIScaleUI({
			value = clamped,
			force = opts.forceSync ~= false,
			fire = opts.fireSync == true,
		})
	end

	if NAmanage.SettingsTabLayout and type(NAmanage.SettingsTabLayout.Apply) == "function" then
		Defer(function()
			if type(NAmanage.SettingsTabLayout.FitFrameToViewport) == "function" then
				NAmanage.SettingsTabLayout.FitFrameToViewport()
			end
			NAmanage.SettingsTabLayout.Apply()
			if type(NAmanage.RefreshSettingsResizeHandle) == "function" then
				NAmanage.RefreshSettingsResizeHandle()
			end
			const settingsFrame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
			if settingsFrame and settingsFrame.Parent and settingsFrame.Visible and type(NAmanage.centerFrame) == "function" then
				NAmanage.centerFrame(settingsFrame)
			end
		end)
	end

	return clamped
end

flingManager = { FlingOldPos = nil; lFlingOldPos = nil; cFlingOldPos = nil; }

flingManager.FlingVelocity = Vector3.new(9e7, 9e8, 9e7)
flingManager.FlingAngularVelocity = Vector3.new(9e8, 9e8, 9e8)
flingManager.MoverFlingVelocity = Vector3.new(9e8, 9e8, 9e8)

flingManager.IsFiniteNumber = function(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

flingManager.IsFiniteVector = function(value)
	return typeof(value) == "Vector3"
		and flingManager.IsFiniteNumber(value.X)
		and flingManager.IsFiniteNumber(value.Y)
		and flingManager.IsFiniteNumber(value.Z)
end

flingManager.SetFlingVelocity = function(part)
	if not part then
		return
	end

	pcall(function() part.AssemblyLinearVelocity = flingManager.FlingVelocity end)
	pcall(function() part.AssemblyAngularVelocity = flingManager.FlingAngularVelocity end)
	pcall(function() part.Velocity = flingManager.FlingVelocity end)
	pcall(function() part.RotVelocity = flingManager.FlingAngularVelocity end)
end

flingManager.SetMoverFlingVelocity = function(mover)
	if not mover then
		return
	end

	pcall(function()
		mover.Velocity = flingManager.MoverFlingVelocity
	end)
end

flingManager.ClearPartVelocity = function(part)
	if not part then
		return
	end

	const zero = Vector3.new(0, 0, 0)
	pcall(function() part.AssemblyLinearVelocity = zero end)
	pcall(function() part.AssemblyAngularVelocity = zero end)
	pcall(function() part.Velocity = zero end)
	pcall(function() part.RotVelocity = zero end)
end

flingManager.GetPartVelocity = function(part)
	local best = Vector3.new(0, 0, 0)
	local bestSq = 0
	if not part then
		return best, 0
	end

	local ok, assemblyVel = pcall(function()
		return part.AssemblyLinearVelocity
	end)
	if ok and flingManager.IsFiniteVector(assemblyVel) then
		best = assemblyVel
		bestSq = assemblyVel:Dot(assemblyVel)
	end

	local legacyOk, legacyVel = pcall(function()
		return part.Velocity
	end)
	if legacyOk and flingManager.IsFiniteVector(legacyVel) then
		const legacySq = legacyVel:Dot(legacyVel)
		if legacySq > bestSq then
			best = legacyVel
			bestSq = legacySq
		end
	end

	return best, math.sqrt(bestSq)
end

flingManager.GetPlayerCharacter = function(plr)
	if not plr or typeof(plr) ~= "Instance" or not plr:IsA("Player") then
		return nil
	end

	const char = plr.Character
	if char and char.Parent and char:IsDescendantOf(Services.Workspace) then
		return char
	end

	const names = {}
	names[plr.Name] = true
	names[plr.DisplayName] = true

	const function isUsableCharacter(model)
		if not model or not model:IsA("Model") or not names[model.Name] or not model:IsDescendantOf(Services.Workspace) then
			return false
		end

		const hum = getPlrHum(model)
		const root = hum and hum.RootPart or getRoot(model) or model:FindFirstChild("HumanoidRootPart", true)
		return hum ~= nil and root ~= nil
	end

	for _, inst in next, NAmanage.QueryDescendants(Services.Workspace, "Model") do
		if isUsableCharacter(inst) then
			return inst
		end
	end

	return char
end

NAmanage.GetRobloxApiUrls = function(url)
	if type(url) ~= "string" or url == "" then
		return {}
	end

	local subdomain, path = url:match("^https?://([%w%-]+)%.roblox%.com(/.*)$")
	if not subdomain then
		subdomain, path = url:match("^https?://([%w%-]+)%.roproxy%.com(/.*)$")
	end
	if not subdomain then
		subdomain, path = url:match("^https?://([%w%-]+)%.rotunnel%.com(/.*)$")
	end
	if not subdomain or not path then
		return { url }
	end

	return {
		"https://"..subdomain..".roproxy.com"..path,
		"https://"..subdomain..".rotunnel.com"..path,
		"https://"..subdomain..".roblox.com"..path,
	}
end

NAmanage.FetchRobloxApiBody = function(url, opts)
	opts = opts or {}
	const method = opts.Method or opts.method or "GET"
	const body = opts.Body or opts.body
	const headers = opts.Headers or opts.headers or { Accept = "application/json" }
	const timeout = opts.Timeout or opts.timeout or 5
	const req = opt and opt.NAREQUEST

	const function runLimited(callback)
		local finished = false
		local okRun, result
		Spawn(function()
			okRun, result = pcall(callback)
			finished = true
		end)
		const deadline = os.clock() + math.clamp(tonumber(timeout) or 5, 1, 30)
		while not finished and os.clock() < deadline do
			Wait(0.05)
		end
		if not finished then
			return false, nil
		end
		return okRun, result
	end

	for _, apiUrl in NAmanage.GetRobloxApiUrls(url) do
		if type(req) == "function" then
			local okReq, resp = runLimited(function()
				return req({
					Url = apiUrl,
					Method = method,
					Headers = headers,
					Body = body,
					Timeout = timeout,
					FollowRedirects = true,
					SslVerify = false,
				})
			end)
			if okReq and resp then
				if type(resp) == "string" and resp ~= "" then
					return resp, apiUrl
				end
				const status = tonumber(resp.StatusCode or resp.Status or 200) or 200
				const text = resp.Body or resp.body or resp.Data or resp.data or resp.Text or resp.text or resp.Content or resp.content or resp.ResponseBody
				if status >= 200 and status < 300 and type(text) == "string" and text ~= "" then
					return text, apiUrl
				end
			end
		end

		if method == "GET" then
			local okGet, text = runLimited(function()
				return NAmanage.HttpGetOrError(apiUrl, { timeout = timeout })
			end)
			if okGet and type(text) == "string" and text ~= "" then
				return text, apiUrl
			end
		end
	end

	return nil, nil
end

NAmanage.FetchRobloxApiJSON = function(url, opts)
	const body = NAmanage.FetchRobloxApiBody(url, opts)
	if type(body) ~= "string" or body == "" or not Services.HttpService or not Services.HttpService.JSONDecode then
		return nil
	end

	local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
	if ok and type(decoded) == "table" then
		return decoded
	end
	return nil
end

settingsLight = { range = 30; brightness = 1; color = Color3.new(1,1,1); LIGHTER = nil; }
events = {
	"OnSpawn",
	"OnDeath",
	"OnKill",
	"OnDamage",
	"OnChatted",
	"OnJump",
	"OnEquipItem",
	"OnUnequipItem",
	"OnJoin",
	"OnLeave",
}
NASESSIONSTARTEDIDK = os.clock()
NAlib = NAlib or {}
NAgui={}
NAindex = { _init = false }
NAjobs  = {
	jobs = {},
	hb = {},
	sig = {},
	seq = 0,
	_frame = 0,
	_claimed = {},
	_touchState = {},
	_q = {},
	_qHead = 1,
	_qTail = 0,
	_maxTicksPerStep = 8,
	_zeroMinInterval = 0.005,
	_zeroTargetTicksPerSecond = 180,
	_stepInterval = (1 / 240),
	_maxCatchUpSteps = 12,
	_staggerCap = 0.003,
	_accum = {},
	_batchNext = { prompt = {}, click = {}, remote = {} },
	_promptBatchNext = 0,
	_clickBatchNext = 0,
	_remoteBatchNext = 0,
	_promptBatchFloor = 0.05,
	_clickBatchFloor = 0.05,
	_promptMaxFiresPerBatch = 18,
	_clickMaxFiresPerBatch = 18,
	_promptScanPerBatch = 220,
	_clickScanPerBatch = 220,
	_promptRefireFloor = 0.08,
	_clickRefireFloor = 0.08,
	_promptCursor = 0,
	_clickCursor = 0,
	_lastPromptFire = {},
	_lastClickFire = {}
}
NAutil  = NAutil  or {}
NAsuppress = NAsuppress or { ref = {}, snap = {} }
NACOLOREDELEMENTS={}
NACOLOREDELEMENTS_SET={}

DEFAULT_UI_STROKE_COLOR=Color3.fromRGB(148,93,255)
COLOR_WHITE=Color3.new(1,1,1)
COLOR_BLACK=Color3.new(0,0,0)

NAmanage.FormatAccountAge=function(days)
	if type(days) ~= "number" then
		return "Unknown"
	end
	if days < 0 then
		days = 0
	end
	const years=math.floor(days/365)
	const remainingDays=days%365
	const months=math.floor(remainingDays/30)
	const finalDays=math.floor(remainingDays%30)
	const parts={}
	if years>0 then parts[#parts+1]=tostring(years).." yr" end
	if months>0 then parts[#parts+1]=tostring(months).." mo" end
	if finalDays>0 or #parts==0 then parts[#parts+1]=tostring(finalDays).." d" end
	return Concat(parts," ")
end

NAgui.RegisterColoredStroke=function(stroke)
	if typeof(stroke) ~= "Instance" then return end
	if not stroke:IsA("UIStroke") then return end
	if not stroke.Parent then return end
	NAmanage._strokeRegistry = NAmanage._strokeRegistry or { adds = 0, nextPrune = 0 }
	const reg = NAmanage._strokeRegistry
	reg.adds = (tonumber(reg.adds) or 0) + 1
	if reg.adds % 128 == 0 and type(NAgui.pruneRegisteredStrokes) == "function" then
		NAgui.pruneRegisteredStrokes(false)
	end
	if NACOLOREDELEMENTS_SET[stroke] then return end
	NACOLOREDELEMENTS_SET[stroke]=true
	const baseColor=NAUISTROKER or DEFAULT_UI_STROKE_COLOR or stroke.Color
	stroke.Color=baseColor
	Insert(NACOLOREDELEMENTS,stroke)
end

NAgui.pruneRegisteredStrokes = function(force)
	const list = NACOLOREDELEMENTS
	if type(list) ~= "table" then
		return 0
	end
	NAmanage._strokeRegistry = NAmanage._strokeRegistry or { adds = 0, nextPrune = 0 }
	const reg = NAmanage._strokeRegistry
	const now = tick()
	if not force and now < (tonumber(reg.nextPrune) or 0) then
		return #list
	end
	local writeIdx = 0
	for i = 1, #list do
		const stroke = list[i]
		if typeof(stroke) == "Instance" and stroke:IsA("UIStroke") and stroke.Parent then
			writeIdx += 1
			list[writeIdx] = stroke
			NACOLOREDELEMENTS_SET[stroke] = true
		else
			if stroke ~= nil then
				NACOLOREDELEMENTS_SET[stroke] = nil
			end
		end
	end
	for i = writeIdx + 1, #list do
		list[i] = nil
	end
	reg.nextPrune = now + 2
	reg.adds = 0
	return writeIdx
end

NAgui.RegisterStrokesFrom=function(instance)
	if typeof(instance) ~= "Instance" then return end
	if instance:IsA("UIStroke") then
		NAgui.RegisterColoredStroke(instance)
		return
	end
	for _, descendant in NAmanage.QueryDescendants(instance, "UIStroke") do
		NAgui.RegisterColoredStroke(descendant)
	end
end

NAgui.deferSettingsWork = NAgui.deferSettingsWork or function(fn)
	if type(fn) ~= "function" then
		return nil
	end
	while NAmanage and type(NAmanage.IsSettingsBuildTeleportPaused) == "function" and NAmanage.IsSettingsBuildTeleportPaused() do
		Wait(0.1)
	end
	local ok, err = pcall(fn)
	if not ok then
		warn(err)
	end
	return ok
end

NAgui.RegisterStrokesFromAsync = NAgui.RegisterStrokesFromAsync or function(instance)
	if typeof(instance) ~= "Instance" then return end
	return NAgui.deferSettingsWork(function()
		if instance and instance.Parent and NAgui.RegisterStrokesFrom then
			NAgui.RegisterStrokesFrom(instance)
		end
	end)
end

NAgui.ComputeTabStrokeColor=function(isActive)
	const base=NAUISTROKER or DEFAULT_UI_STROKE_COLOR
	if isActive then
		return base:Lerp(COLOR_WHITE,0.22)
	end
	return base:Lerp(COLOR_BLACK,0.12)
end

NAmanage.getTabStrokeColor = NAgui.ComputeTabStrokeColor

NAmanage.GetBasicInfoSnapshot = function()
	const snapshot = {
		player = {};
		platform = {};
		game = {};
		ids = {};
		server = {};
		system = {};
		flags = {};
		session = {};
		timestamp = "";
	}

	const function formatDuration(seconds)
		local value = tonumber(seconds) or 0
		if value < 0 then
			value = 0
		end
		const hours = math.floor(value / 3600)
		const minutes = math.floor((value % 3600) / 60)
		const secs = math.floor(value % 60)
		return Format("%02d:%02d:%02d", hours, minutes, secs)
	end

	const player = Services.Players and Services.Players.LocalPlayer
	const displayName = player and player.DisplayName or "Unknown"
	const username = player and player.Name or "Unknown"
	const userId = player and player.UserId or nil
	const accountAgeDays = player and player.AccountAge or nil
	local membership = "None"
	if player and player.MembershipType == Enum.MembershipType.Premium then
		membership = "Premium"
	end
	local teamName = "None"
	if player and player.Team then
		teamName = player.Team.Name or "None"
	end

	snapshot.player.displayName = displayName
	snapshot.player.username = username
	snapshot.player.userId = userId and tostring(userId) or "Unknown"
	snapshot.player.accountAge = NAmanage.FormatAccountAge(accountAgeDays)
	snapshot.player.membership = membership
	snapshot.player.team = teamName

	local platformName = "Unknown"
	if Services.UserInputService then
		local okPlatform, platformEnum = pcall(Services.UserInputService.GetPlatform, Services.UserInputService)
		if okPlatform and platformEnum then
			platformName = platformEnum.Name or tostring(platformEnum)
		end
	end

	local executorName = "Unknown"
	if identifyexecutor then
		local okExec, execResult = pcall(identifyexecutor)
		if okExec and execResult and execResult ~= "" then
			executorName = execResult
		end
	elseif identifyexec then
		local okExecAlt, execResultAlt = pcall(identifyexec)
		if okExecAlt and execResultAlt and execResultAlt ~= "" then
			executorName = execResultAlt
		end
	end

	local deviceType = "Unknown"
	if IsOnMobile then
		deviceType = "Mobile"
	elseif IsOnPC then
		deviceType = "Desktop"
	elseif platformName ~= "Unknown" then
		deviceType = platformName
	end

	const inputs = {}
	if Services.UserInputService then
		if Services.UserInputService.TouchEnabled then Insert(inputs, "Touch") end
		if Services.UserInputService.GamepadEnabled then Insert(inputs, "Gamepad") end
		if Services.UserInputService.KeyboardEnabled or Services.UserInputService.MouseEnabled then
			Insert(inputs, "KB/M")
		end
	end
	const controlScheme = #inputs > 0 and Concat(inputs, ", ") or "Unknown"

	snapshot.platform.platform = platformName
	snapshot.platform.executor = executorName
	snapshot.platform.device = deviceType
	snapshot.platform.input = controlScheme

	const robloxLocale = Services.LocalizationService and Services.LocalizationService.RobloxLocaleId or "Unknown"
	const systemLocale = Services.LocalizationService and Services.LocalizationService.SystemLocaleId or "Unknown"

	local qualitySetting = "Auto"
	local okUGS, userGameSettings = pcall(function()
		return UserSettings():GetService("UserGameSettings")
	end)
	if okUGS and userGameSettings then
		const savedQuality = userGameSettings.SavedQualityLevel
		if typeof(savedQuality) == "EnumItem" then
			qualitySetting = savedQuality.Name or tostring(savedQuality)
		elseif savedQuality ~= nil then
			qualitySetting = tostring(savedQuality)
		end
	end

	local voiceStatus = "Unknown"
	if NAmanage then
		NAmanage.BasicInfoVoiceCache = NAmanage.BasicInfoVoiceCache or {}
		const voiceCache = NAmanage.BasicInfoVoiceCache
		if voiceCache.userId ~= userId then
			voiceCache.userId = userId
			voiceCache.value = nil
			voiceCache.fetching = false
			voiceCache.lastFetch = 0
		end
		if type(voiceCache.value) == "string" and voiceCache.value ~= "" then
			voiceStatus = voiceCache.value
		end
		const voiceNow = (os.clock and os.clock() or tick())
		const voiceLast = tonumber(voiceCache.lastFetch) or 0
		const voiceRetry = voiceStatus == "Unknown" and 15 or 60
		if userId and (not voiceCache.fetching) and (voiceLast == 0 or (voiceNow - voiceLast) > voiceRetry) then
			voiceCache.fetching = true
			voiceCache.lastFetch = voiceNow
			const fetchUserId = userId
			SpawnCall(function()
				local resolved = "Unknown"
				if fetchUserId then
					local okVoice, voiceEnabled = pcall(function()
						return __lt.cm("VoiceChatService", "IsVoiceEnabledForUserIdAsync", fetchUserId)
					end)
					if okVoice then
						resolved = voiceEnabled and "Enabled" or "Disabled"
					end
				end
				if voiceCache.userId == fetchUserId then
					voiceCache.value = resolved
					voiceCache.fetching = false
				end
			end)
		end
	end

	local resolution = "Unknown"
	const camera = Services.Workspace and Services.Workspace.CurrentCamera
	if camera and camera.ViewportSize then
		resolution = Format("%dx%d", math.floor(camera.ViewportSize.X), math.floor(camera.ViewportSize.Y))
	end

	snapshot.system.robloxLocale = robloxLocale
	snapshot.system.systemLocale = systemLocale
	snapshot.system.quality = qualitySetting
	snapshot.system.voice = voiceStatus
	snapshot.system.resolution = resolution

	const placeId = tonumber(game.PlaceId) or 0
	const gameId = game.GameId or "Unknown"
	local jobIdValue = game.JobId
	if jobIdValue == nil or jobIdValue == "" then
		jobIdValue = "Unavailable"
	end

	local gameName = "Unknown"
	local creatorName = "Unknown"
	local gameGenre = "Unknown"
	const universeId = tonumber(gameId) or 0
	const placeVersion = tonumber(game.PlaceVersion) or nil
	const now = (os.clock and os.clock() or tick())

	if NAmanage then
		NAmanage.BasicInfoGameCache = NAmanage.BasicInfoGameCache or {}
		const cache = NAmanage.BasicInfoGameCache

		if cache.universeId ~= universeId then
			cache.universeId = universeId
			cache.name = nil
			cache.creator = nil
			cache.genre = nil
			cache.fetching = false
			cache.lastFetch = 0
			cache.fetchId = 0
			cache.marketplaceFetched = false
			cache.marketplaceFetching = false
			cache.marketplaceLastFetch = 0
			cache.marketplaceFetchId = 0
		end

		if cache.name then
			gameName = cache.name
		end
		if cache.creator then
			creatorName = cache.creator
		end
		if cache.genre then
			gameGenre = cache.genre
		end

		const lastFetch = cache.lastFetch or 0
		if universeId ~= 0 and not cache.fetching and not cache.genre and (lastFetch == 0 or (now - lastFetch > 30)) then
			cache.fetching = true
			cache.lastFetch = now
			cache.fetchId = (cache.fetchId or 0) + 1
			const fetchId = cache.fetchId

			SpawnCall(function()
				const url = "https://games.roblox.com/v1/games?universeIds="..tostring(universeId)
				const body = NAmanage.FetchRobloxApiBody(url, { Timeout = 5 })

				if type(body) == "string" and body ~= "" and Services.HttpService and Services.HttpService.JSONDecode then
					local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
					if okDecode and type(decoded) == "table" and type(decoded.data) == "table" and decoded.data[1] and cache.fetchId == fetchId and cache.universeId == universeId then
						const entry = decoded.data[1]
						cache.name = cache.name or entry.name or entry.Name
						if entry.creator and type(entry.creator) == "table" then
							cache.creator = cache.creator or entry.creator.name or entry.creator.Name
						end
						cache.genre = cache.genre or entry.genre or entry.genre_l1 or entry.genre_l2 or entry.Genre
					end
				end

				if cache.fetchId == fetchId then
					cache.fetching = false
				end
			end)
		end

		const marketplaceLastFetch = tonumber(cache.marketplaceLastFetch) or 0
		if Services.MarketplaceService and placeId ~= 0 and (gameName == "Unknown" or creatorName == "Unknown")
			and (not cache.marketplaceFetching)
			and ((not cache.marketplaceFetched) or marketplaceLastFetch == 0 or (now - marketplaceLastFetch > 60))
		then
			cache.marketplaceFetching = true
			cache.marketplaceLastFetch = now
			cache.marketplaceFetchId = (cache.marketplaceFetchId or 0) + 1
			const marketplaceFetchId = cache.marketplaceFetchId
			const fetchUniverseId = universeId
			const fetchPlaceId = placeId
			SpawnCall(function()
				local okInfo, infoResult = pcall(Services.MarketplaceService.GetProductInfo, Services.MarketplaceService, fetchPlaceId)
				if cache.universeId == fetchUniverseId and cache.marketplaceFetchId == marketplaceFetchId then
					if okInfo and type(infoResult) == "table" then
						cache.name = cache.name or infoResult.Name
						if infoResult.Creator and infoResult.Creator.Name then
							cache.creator = cache.creator or infoResult.Creator.Name
						end
						cache.marketplaceFetched = true
					end
					cache.marketplaceFetching = false
				end
			end)
		end
		gameName = cache.name or gameName
		creatorName = cache.creator or creatorName
		gameGenre = cache.genre or gameGenre
	end

	snapshot.game.name = gameName
	snapshot.game.creator = creatorName
	snapshot.game.genre = gameGenre
	snapshot.game.placeVersion = placeVersion and tostring(placeVersion) or "Unknown"

	snapshot.ids.placeId = placeId ~= 0 and tostring(placeId) or "Unknown"
	local gameIdText = tostring(gameId)
	if gameIdText == "" or gameIdText == "0" then
		gameIdText = "Unknown"
	end
	snapshot.ids.gameId = gameIdText
	snapshot.ids.jobId = tostring(jobIdValue)

	const playerCount = Services.Players and Services.Players.NumPlayers or 0
	const maxPlayers = Services.Players and Services.Players.MaxPlayers or 0

	local serverPing = "Unknown"
	const safePingText = NAmanage.GetDataPingText and NAmanage.GetDataPingText() or nil
	if type(safePingText) == "string" and safePingText ~= "" then
		serverPing = safePingText
	end

	local serverMeta = nil
	if type(NAStuff.srv) == "table" and type(NAStuff.srv.getServerDetail) == "function" and tostring(game.JobId or "") ~= "" then
		NAmanage.BasicInfoServerCache = type(NAmanage.BasicInfoServerCache) == "table" and NAmanage.BasicInfoServerCache or {}
		const cache = NAmanage.BasicInfoServerCache
		const key = tostring(placeId).."|"..tostring(game.JobId)
		if cache.key ~= key then
			cache.key = key
			cache.data = nil
			cache.fetching = false
			cache.lastFetch = 0
		end
		serverMeta = cache.data
		const metaNow = tick()
		if not cache.fetching and (cache.lastFetch == 0 or metaNow - (tonumber(cache.lastFetch) or 0) > 60) then
			cache.fetching = true
			cache.lastFetch = metaNow
			const fetchKey = key
			SpawnCall(function()
				local detail = NAStuff.srv:getServerDetail(placeId, game.JobId, false)
				if cache.key == fetchKey then
					cache.data = detail
					cache.fetching = false
				end
			end)
		end
	end

	snapshot.server.playerCount = Format("%d/%d", playerCount, maxPlayers)
	snapshot.server.ping = serverPing
	snapshot.server.region = serverMeta and (serverMeta.regionLabel or serverMeta.city or serverMeta.regionName or serverMeta.country) or "Unknown"
	snapshot.server.city = serverMeta and serverMeta.city or "Unknown"
	snapshot.server.country = serverMeta and serverMeta.country or "Unknown"
	snapshot.server.datacenter = serverMeta and serverMeta.datacenterId and tostring(serverMeta.datacenterId) or "Unknown"
	snapshot.server.ip = serverMeta and serverMeta.ipAddress or "Unknown"
	snapshot.server.uptime = serverMeta and serverMeta.uptime and NAStuff.srv:formatUptime(serverMeta.uptime, true) or "Unknown"
	snapshot.server.placeVersion = serverMeta and serverMeta.placeVersion and tostring(serverMeta.placeVersion) or "Unknown"

	const isTesting = getgenv and _na_env.NATestingVer
	local aprilMode = type(_na_boot) == "table" and type(_na_boot.hostEnv) == "table" and rawget(_na_boot.hostEnv, "ActivateAprilMode") or nil
	if aprilMode == nil then
		aprilMode = _na_env.ActivateAprilMode
	end

	snapshot.flags.version = isTesting and "Testing" or "Normal"
	snapshot.flags.aprilFools = aprilMode and "Enabled" or "Disabled"

	const sessionSeconds = (os.clock and os.clock() or tick()) - (NASESSIONSTARTEDIDK or 0)
	snapshot.session.uptime = formatDuration(sessionSeconds)

	snapshot.timestamp = os.date("%m/%d/%Y | %H:%M:%S")

	return snapshot
end

NAmanage.prefetchRobloxGameInfo = function()
	const cache = NAmanage.BasicInfoGameCache or {}
	NAmanage.BasicInfoGameCache = cache

	const placeId = tonumber(game.PlaceId) or 0
	const universeId = tonumber(game.GameId) or 0
	if universeId == 0 then
		return false, "no universe id"
	end
	const now = (os.clock and os.clock() or tick())

	if cache.universeId ~= universeId then
		cache.universeId = universeId
		cache.name = nil
		cache.creator = nil
		cache.genre = nil
		cache.fetching = false
		cache.lastFetch = 0
		cache.fetchId = 0
		cache.marketplaceFetched = false
		cache.marketplaceFetching = false
		cache.marketplaceLastFetch = 0
		cache.marketplaceFetchId = 0
	end

	const lastFetch = tonumber(cache.lastFetch) or 0
	if (not cache.fetching) and (cache.genre == nil) and (lastFetch == 0 or (now - lastFetch > 15)) then
		cache.fetching = true
		cache.lastFetch = now
		cache.fetchId = (cache.fetchId or 0) + 1
		const fetchId = cache.fetchId
		const fetchUniverseId = universeId
		SpawnCall(function()
			const url = "https://games.roblox.com/v1/games?universeIds="..tostring(fetchUniverseId)
			const body = NAmanage.FetchRobloxApiBody(url, { Timeout = 5 })

			if type(body) == "string" and body ~= "" and Services.HttpService and Services.HttpService.JSONDecode then
				local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
				if okDecode and type(decoded) == "table" and type(decoded.data) == "table" and decoded.data[1]
					and cache.fetchId == fetchId and cache.universeId == fetchUniverseId
				then
					const entry = decoded.data[1]
					cache.name = cache.name or entry.name or entry.Name
					if entry.creator and type(entry.creator) == "table" then
						cache.creator = cache.creator or entry.creator.name or entry.creator.Name
					end
					cache.genre = cache.genre or entry.genre or entry.genre_l1 or entry.genre_l2 or entry.Genre
				end
			end

			if cache.fetchId == fetchId then
				cache.fetching = false
			end
		end)
	end

	const cachedName = cache.name or "Unknown"
	const cachedCreator = cache.creator or "Unknown"
	const marketplaceLastFetch = tonumber(cache.marketplaceLastFetch) or 0
	if Services.MarketplaceService and placeId ~= 0 and (cachedName == "Unknown" or cachedCreator == "Unknown")
		and (not cache.marketplaceFetching)
		and ((not cache.marketplaceFetched) or marketplaceLastFetch == 0 or (now - marketplaceLastFetch > 60))
	then
		cache.marketplaceFetching = true
		cache.marketplaceLastFetch = now
		cache.marketplaceFetchId = (cache.marketplaceFetchId or 0) + 1
		const marketplaceFetchId = cache.marketplaceFetchId
		const fetchUniverseId = universeId
		const fetchPlaceId = placeId
		SpawnCall(function()
			local okInfo, infoResult = pcall(Services.MarketplaceService.GetProductInfo, Services.MarketplaceService, fetchPlaceId)
			if cache.universeId == fetchUniverseId and cache.marketplaceFetchId == marketplaceFetchId then
				if okInfo and type(infoResult) == "table" then
					cache.name = cache.name or infoResult.Name
					if infoResult.Creator and infoResult.Creator.Name then
						cache.creator = cache.creator or infoResult.Creator.Name
					end
					cache.marketplaceFetched = true
				end
				cache.marketplaceFetching = false
			end
		end)
	end

	const success = cache.genre ~= nil or cache.name ~= nil
	return success
end
cmdNAnum=0
NAQoTEnabled = nil
NAiconSaveEnabled = nil
NAUISTROKER = DEFAULT_UI_STROKE_COLOR
NATOPBARVISIBLE = true
NATopbarKeepPosition = false
NATopbarPositionRatio = 0
NATopbarDock = "top"
NALoadingStartMinimized = false
NAHideStartup = false
NASideSwipeSide = "left"
NASideSwipeEnabled = false
NADisableLastInput = false

do
	if FileSupport then
		NAmanage.safeMakeFolder(NAfiles.NAFILEPATH)
		local ok, raw = pcall(function()
			if typeof(isfile) == "function" and NAmanage.safeIsFile(NAfiles.NAMAINSETTINGSPATH) then
				return readfile(NAfiles.NAMAINSETTINGSPATH)
			end
			return nil
		end)
		if ok and type(raw) == "string" and raw ~= "" then
			local decodedOk, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
			if decodedOk and typeof(decoded) == "table" then
				const val = decoded.loadingStartMinimized
				const function parseBool(value)
					if type(value) == "boolean" then return value end
					if type(value) == "string" then
						const lowered = value:lower()
						if lowered == "true" or lowered == "1" then return true end
						if lowered == "false" or lowered == "0" then return false end
					end
					if type(value) == "number" then
						return value ~= 0
					end
					return nil
				end
				const parsed = parseBool(val)
				if parsed ~= nil then
					NALoadingStartMinimized = parsed
				end
				const hideParsed = parseBool(decoded.hideStartup)
				if hideParsed ~= nil then
					NAHideStartup = hideParsed
				end
			end
		end
	end
end

if _na_env.NATestingVer then
	opt.loaderUrl="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NA%20testing.lua"
	opt.githubUrl="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?per_page=10"
	local __NAUIHost = type(_na_boot) == "table" and type(_na_boot.hostEnv) == "table" and _na_boot.hostEnv or {}
	opt.NAUILOADER = (type(__NAUIHost) == "table" and rawget(__NAUIHost, "NAChatUIUrl")) or "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/NAUITEST.lua"
else
	opt.loaderUrl="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"
	opt.githubUrl="https://api.github.com/repos/ltseverydayyou/Nameless-Admin/commits?per_page=10"
	opt.NAUILOADER="https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/NAUI.lua"
end

NAmanage.centerFrame = function(f)
	if not f or not f.Parent then
		return false
	end

	local parentSize
	pcall(function()
		parentSize = f.Parent.AbsoluteSize
	end)
	if typeof(parentSize) ~= "Vector2" or parentSize.X <= 0 or parentSize.Y <= 0 then
		const cam = Services.Workspace.CurrentCamera
		parentSize = cam and cam.ViewportSize or nil
	end
	if typeof(parentSize) ~= "Vector2" or parentSize.X <= 0 or parentSize.Y <= 0 then
		return false
	end

	local renderedSize = f.AbsoluteSize
	if typeof(renderedSize) ~= "Vector2" or renderedSize.X <= 0 or renderedSize.Y <= 0 then
		local scale = NAmanage.GetUIScaleFactor and NAmanage.GetUIScaleFactor(f) or 1
		if not scale or scale <= 0 then
			scale = 1
		end
		renderedSize = Vector2.new(
			((parentSize.X * f.Size.X.Scale) + f.Size.X.Offset) * scale,
			((parentSize.Y * f.Size.Y.Scale) + f.Size.Y.Offset) * scale
		)
	end

	const anchor = f.AnchorPoint
	const targetAnchor = Vector2.new(parentSize.X * 0.5, parentSize.Y * 0.5) + Vector2.new(
		(anchor.X - 0.5) * renderedSize.X,
		(anchor.Y - 0.5) * renderedSize.Y
	)

	f.Position = UDim2.fromScale(
		targetAnchor.X / parentSize.X,
		targetAnchor.Y / parentSize.Y
	)
	return true
end

NAmanage.guiCHECKINGAHHHHH=function()
	return (NAlib.huiGrabber and NAlib.huiGrabber()) or __lt.cm("CoreGui", "FindFirstChildWhichIsA", "ScreenGui") or Services.CoreGui or Services.Players.LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
end

if not NAlib.huiGrabber() then
	_na_env.gethui=function()
		return NAmanage.guiCHECKINGAHHHHH()
	end
end

do
	const previousPerf = type(NAStuff.StartupPerformance) == "table" and NAStuff.StartupPerformance or nil
	NAStuff.StartupPerformance = {
	started = os.clock();
	maxFrame = 0;
	spikes = {};
	stages = {};
	currentStage = nil;
	stageStarted = nil;
	commandYields = 0;
	instanceYields = 0;
	uiSourceInstances = 0;
	finished = false;
	reloadIndex = (tonumber(previousPerf and previousPerf.reloadIndex) or 0) + 1;
	previousElapsed = previousPerf and previousPerf.elapsed or nil;
	}
end
pcall(function()
	_na_env.__NAStartupPerformance = NAStuff.StartupPerformance
end)

NAmanage.MarkStartupStage = NAmanage.MarkStartupStage or function(stage, status)
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) ~= "table" or perf.finished == true then
		return
	end
	const now = os.clock()
	const started = tonumber(perf.started) or now
	local stages = perf.stages
	if type(stages) ~= "table" then
		stages = {}
		perf.stages = stages
	end
	if type(perf.currentStage) == "string" and perf.currentStage ~= "" then
		if #stages < 48 then
			stages[#stages + 1] = {
				name = perf.currentStage;
				elapsed = now - (tonumber(perf.stageStarted) or now);
				at = now - started;
			}
		end
	end
	perf.currentStage = tostring(stage or "unknown")
	perf.stageStarted = now
	perf.lastStatus = tostring(status or stage or "")
	pcall(function()
		const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
		if type(probe) == "table" and type(probe.mark) == "function" then
			probe.mark("stage:"..perf.currentStage)
		end
	end)
end

NAlib.disconnect("NA_startup_performance")
NAlib.connect("NA_startup_performance", Services.RunService.Heartbeat:Connect(function(dt)
	const perf = NAStuff.StartupPerformance
	if type(perf) ~= "table" or perf.finished == true then
		return
	end
	dt = tonumber(dt) or 0
	perf.lastFrameDt = dt
	perf.frames = (tonumber(perf.frames) or 0) + 1
	if dt > 0 and (not perf.minFrame or dt < perf.minFrame) then
		perf.minFrame = dt
	end
	if dt > (tonumber(perf.maxFrame) or 0) then
		perf.maxFrame = dt
	end
	if dt >= 0.08 then
		const spikes = perf.spikes
		if type(spikes) == "table" and #spikes < 24 then
			spikes[#spikes + 1] = {
				dt = dt;
				at = os.clock() - (tonumber(perf.started) or os.clock());
			}
		end
	end
end))

NAmanage.StartupInstanceBudgetStep = NAmanage.StartupInstanceBudgetStep or function()
	const buildState = NAgui and NAgui.SettingsBuildState
	const settingsBuilding = NAStuff.SettingsBuildRunning == true or (type(buildState) == "table" and buildState.building == true)
	if settingsBuilding then
		return
	end
	if NAStuff._loadingFinalizedOnce == true or (NAAssetsLoading and NAAssetsLoading._finalized == true) then
		return
	end
	local state = NAStuff._startupInstanceBudget
	if type(state) ~= "table" then
		state = { count = 0; lastYield = os.clock(); }
		NAStuff._startupInstanceBudget = state
	end
	state.count += 1
	const now = os.clock()
	const mobile = IsOnMobile == true
	const perf = NAStuff.StartupPerformance
	const lastFrameDt = type(perf) == "table" and tonumber(perf.lastFrameDt) or nil
	const highFps = lastFrameDt and lastFrameDt > 0 and lastFrameDt < (1 / 240)
	local batch
	local budget
	if settingsBuilding then
		batch = highFps and (mobile and 2 or 3) or (mobile and 3 or 6)
		budget = highFps and 0.00075 or (mobile and 0.002 or 0.003)
	else
		batch = highFps and (mobile and 3 or 5) or (mobile and 12 or 22)
		budget = highFps and 0.0009 or (mobile and 0.004 or 0.006)
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
		const perf = NAStuff.StartupPerformance
		if type(perf) == "table" then
			perf.instanceYields = (tonumber(perf.instanceYields) or 0) + 1
		end
	end
	state.lastYield = os.clock()
end

NAmanage.IsStartupBuilding = NAmanage.IsStartupBuilding or function()
	return not (NAStuff and (NAStuff._loadingFinalizedOnce == true or (NAAssetsLoading and NAAssetsLoading._finalized == true)))
end

NAmanage.GetFastStartupInstanceName = NAmanage.GetFastStartupInstanceName or function()
	return "\0"
end

NAmanage.GetDefaultInstanceName = NAmanage.GetDefaultInstanceName or function()
	if type(NAmanage.IsStartupBuilding) == "function" and NAmanage.IsStartupBuilding() and NAStuff.FastStartupInstanceNames ~= false then
		return NAmanage.GetFastStartupInstanceName()
	end
	return (NAgui.rStringgg and NAgui.rStringgg()) or "\0"
end

function InstanceNew(c,p)
	if type(NAmanage.StartupInstanceBudgetStep) == "function" then
		NAmanage.StartupInstanceBudgetStep()
	end
	const inst = Instance.new(c)
	const nameStart = os.clock()
	inst.Name = NAmanage.GetDefaultInstanceName()
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) == "table" and perf.finished ~= true then
		perf.instanceNameElapsed = (tonumber(perf.instanceNameElapsed) or 0) + (os.clock() - nameStart)
		perf.instanceNameCount = (tonumber(perf.instanceNameCount) or 0) + 1
	end
	if p then inst.Parent = p end
	return inst
end

NAStuff.NACallerErrors = type(NAStuff.NACallerErrors) == "table" and NAStuff.NACallerErrors or {}
NAStuff.NACallerErrorCount = tonumber(NAStuff.NACallerErrorCount) or 0
NAStuff.NACallerOptions = type(NAStuff.NACallerOptions) == "table" and NAStuff.NACallerOptions or {}
for key, value in {
	popup = true;
	warn = true;
	notify = false;
	notifyDuration = 4;
	log = true;
	history = true;
	includeTraceback = true;
	maxHistory = 50;
	rethrow = false;
	silent = false;
} do
	if NAStuff.NACallerOptions[key] == nil then
		NAStuff.NACallerOptions[key] = value
	end
end

NAmanage.NACallerConfigure = function(nextOptions)
	if type(nextOptions) == "table" then
		for key, value in nextOptions do
			NAStuff.NACallerOptions[key] = value
		end
	end
	const snapshot = {}
	for key, value in NAStuff.NACallerOptions do
		snapshot[key] = value
	end
	return snapshot
end

NAmanage.NACallerGetExecutorInfo = function()
	local execName = "Unknown"
	local execVersion = "Unknown"
	if type(NAmanage.btGetExecutorInfo) == "function" then
		local ok, info = pcall(NAmanage.btGetExecutorInfo)
		if ok and type(info) == "table" then
			if info.name ~= nil and tostring(info.name) ~= "" then
				execName = tostring(info.name)
			end
			if info.version ~= nil and tostring(info.version) ~= "" then
				execVersion = tostring(info.version)
			end
		end
	end
	if execName == "Unknown" and type(identifyexecutor) == "function" then
		local ok, name, versionValue = pcall(identifyexecutor)
		if ok then
			if name ~= nil and tostring(name) ~= "" then execName = tostring(name) end
			if versionValue ~= nil and tostring(versionValue) ~= "" then execVersion = tostring(versionValue) end
		end
	end
	if execName == "Unknown" and type(getexecutorname) == "function" then
		local ok, value = pcall(getexecutorname)
		if ok and value ~= nil and tostring(value) ~= "" then execName = tostring(value) end
	end
	if execVersion == "Unknown" and type(getexecutorversion) == "function" then
		local ok, value = pcall(getexecutorversion)
		if ok and value ~= nil and tostring(value) ~= "" then execVersion = tostring(value) end
	end
	return execName, execVersion
end

NAmanage.NACallerGetDebugInfo = function(fn, callerLevel)
	const info = {
		functionName = "anonymous";
		functionSource = "Unknown";
		functionLine = -1;
		callerName = "anonymous";
		callerSource = "Unknown";
		callerLine = -1;
	}
	if type(debug) == "table" and type(debug.info) == "function" then
		pcall(function()
			local source, line, name = debug.info(fn, "sln")
			if source ~= nil and tostring(source) ~= "" then info.functionSource = tostring(source) end
			if tonumber(line) then info.functionLine = tonumber(line) end
			if name ~= nil and tostring(name) ~= "" then info.functionName = tostring(name) end
		end)
		pcall(function()
			local source, line, name = debug.info(tonumber(callerLevel) or 3, "sln")
			if source ~= nil and tostring(source) ~= "" then info.callerSource = tostring(source) end
			if tonumber(line) then info.callerLine = tonumber(line) end
			if name ~= nil and tostring(name) ~= "" then info.callerName = tostring(name) end
		end)
	end
	return info
end

NAmanage.NACallerGetEnvironmentInfo = function()
	local platform = "Unknown"
	if Services.UserInputService then
		pcall(function()
			const value = Services.UserInputService:GetPlatform()
			platform = value and (value.Name or tostring(value)) or platform
		end)
	end
	local clientVersion = "Unknown"
	if type(version) == "function" then
		local ok, value = pcall(version)
		if ok and value ~= nil and tostring(value) ~= "" then clientVersion = tostring(value) end
	end
	local timestamp = tostring(os.time and os.time() or "Unknown")
	if type(os.date) == "function" then
		local ok, value = pcall(os.date, "!%Y-%m-%dT%H:%M:%SZ")
		if ok and type(value) == "string" and value ~= "" then timestamp = value end
	end
	return {
		platform = platform;
		clientVersion = clientVersion;
		timestamp = timestamp;
		placeName = tostring(game and game.Name or "Unknown");
		placeId = tostring(game and game.PlaceId or "Unknown");
		gameId = tostring(game and game.GameId or "Unknown");
		jobId = tostring(game and game.JobId or "Unknown");
	}
end

NAmanage.NACallerBuildReport = function(rawError, tracebackText, fn, options)
	options = type(options) == "table" and options or {}
	NAStuff.NACallerErrorCount = (tonumber(NAStuff.NACallerErrorCount) or 0) + 1
	const errorId = Format("NAE-%06d", NAStuff.NACallerErrorCount)
	const execName, execVersion = NAmanage.NACallerGetExecutorInfo()
	const debugInfo = NAmanage.NACallerGetDebugInfo(fn, 3)
	const envInfo = NAmanage.NACallerGetEnvironmentInfo()
	const context = tostring(options.context or options.label or options.name or (debugInfo.callerName ~= "anonymous" and debugInfo.callerName) or "NACaller callback")
	const mode = (_na_env and _na_env.NATestingVer == true) and tostring(testingName or "NA Testing") or tostring(mainName or adminName or "Nameless Admin")
	const sourceTag = tostring((_na_env and rawget(_na_env, "__NAKeySource")) or "Unknown")
	const lines = {
		"[Nameless Admin Error Report]";
		"Error ID: "..errorId;
		"Time (UTC): "..envInfo.timestamp;
		"Context: "..context;
		"Severity: "..string.upper(tostring(options.severity or "error"));
		"";
		"Runtime";
		"Executor: "..execName;
		"Executor Version: "..execVersion;
		"Roblox Client: "..envInfo.clientVersion;
		"Platform: "..envInfo.platform;
		"NA Mode: "..mode;
		"NA Source: "..sourceTag;
		"Run Sequence: "..tostring(NAmanage._runtimeState and NAmanage._runtimeState.runSeq or "Unknown");
		"";
		"Session";
		"Place: "..envInfo.placeName;
		"PlaceId: "..envInfo.placeId;
		"GameId: "..envInfo.gameId;
		"JobId: "..envInfo.jobId;
		"";
		"Callback";
		"Function: "..debugInfo.functionName;
		"Defined At: "..debugInfo.functionSource..":"..tostring(debugInfo.functionLine);
		"Called From: "..debugInfo.callerSource..":"..tostring(debugInfo.callerLine).." ("..debugInfo.callerName..")";
		"";
		"Error";
		tostring(rawError or "Unknown error");
	}
	if type(options.details) == "table" then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Additional Context"
		for key, value in options.details do
			lines[#lines + 1] = tostring(key)..": "..tostring(value)
		end
	end
	if options.includeTraceback ~= false then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Traceback"
		lines[#lines + 1] = tostring(tracebackText or rawError or "Unavailable")
	end
	return errorId, context, Concat(lines, "\n")
end

NAStuff.NACallerFileCount = math.max(tonumber(NAStuff.NACallerFileCount) or 0, tonumber(__NARootErrorState.lastIndex) or 0)

NAmanage.NACallerGetNextLogPath = function(dir)
	local maxIndex = tonumber(NAStuff.NACallerFileCount) or 0
	if type(listfiles) == "function" then
		local ok, entries = pcall(listfiles, dir)
		if ok and type(entries) == "table" then
			for _, entry in entries do
				const normalized = tostring(entry):gsub("\\", "/")
				const index = tonumber(normalized:match("NA_Error#(%d+)%.txt$"))
				if index and index > maxIndex then
					maxIndex = index
				end
			end
		end
	end
	local nextIndex = maxIndex + 1
	local path = dir.."/NA_Error#"..tostring(nextIndex)..".txt"
	if type(isfile) == "function" then
		while isfile(path) do
			nextIndex += 1
			path = dir.."/NA_Error#"..tostring(nextIndex)..".txt"
		end
	end
	NAStuff.NACallerFileCount = nextIndex
	__NARootErrorState.lastIndex = math.max(tonumber(__NARootErrorState.lastIndex) or 0, nextIndex)
	return path
end

NAmanage.NACallerStoreReport = function(errorId, context, report, options)
	options = type(options) == "table" and options or {}
	const history = NAStuff.NACallerErrors
	if options.history ~= false then
		history[#history + 1] = {
			id = errorId;
			context = context;
			report = report;
			time = os.time and os.time() or 0;
		}
		const maxHistory = math.clamp(math.floor(tonumber(options.maxHistory) or 50), 1, 250)
		while #history > maxHistory do
			table.remove(history, 1)
		end
	end
	const writer = type(writefile) == "function" and writefile or (type(appendfile) == "function" and appendfile or nil)
	if options.log == false or not FileSupport or type(writer) ~= "function" or not NAfiles or type(NAfiles.NAFILEPATH) ~= "string" then
		return nil
	end
	local logPath
	local saved = false
	pcall(function()
		const root = NAfiles.NAFILEPATH
		const dir = root.."/ErrorLogs"
		if type(NAmanage.safeMakeFolder) == "function" then
			NAmanage.safeMakeFolder(root)
			NAmanage.safeMakeFolder(dir)
		elseif type(makefolder) == "function" then
			if type(isfolder) ~= "function" or not isfolder(root) then pcall(makefolder, root) end
			if type(isfolder) ~= "function" or not isfolder(dir) then pcall(makefolder, dir) end
		end
		logPath = NAmanage.NACallerGetNextLogPath(dir)
		writer(logPath, report.."\n")
		saved = true
	end)
	return saved and logPath or nil
end

NAmanage.NACallerReportExternalError = function(rawError, tracebackText, fn, nextOptions)
	const options = {}
	for key, value in NAStuff.NACallerOptions do options[key] = value end
	if type(nextOptions) == "table" then
		for key, value in nextOptions do options[key] = value end
	end
	const errorId, context, report = NAmanage.NACallerBuildReport(rawError, tracebackText, fn, options)
	const logPath = NAmanage.NACallerStoreReport(errorId, context, report, options)
	pcall(NAmanage.NACallerShowError, errorId, context, rawError, report, logPath, options)
	return errorId, context, report, logPath
end

NAmanage.NACallerShowError = function(errorId, context, rawError, report, logPath, options)
	options = type(options) == "table" and options or {}
	if options.silent == true then return end
	if options.warn ~= false then
		warn("["..errorId.."] "..tostring(adminName or "NA").." callback error ("..context..")\n"..report)
	end
	if options.notify == true and type(DoNotif) == "function" then
		pcall(DoNotif, errorId.." | "..context.." failed", tonumber(options.notifyDuration) or 4, "NA Error")
	end
	if options.popup == false or type(Popup) ~= "function" then return end
	local shortError = tostring(rawError or "Unknown error")
	if #shortError > 420 then shortError = shortError:sub(1, 417).."..." end
	const execName, execVersion = NAmanage.NACallerGetExecutorInfo()
	local description = errorId.."\n"..context.."\n\n"..shortError.."\n\nExecutor: "..execName.." | "..execVersion
	if logPath then description ..= "\nLog: "..logPath end
	Popup({
		Title = tostring(options.title or ((adminName or "NA").." Error"));
		Description = description;
		Buttons = {
			{
				Text = "Copy Report";
				Callback = function()
					if type(setclipboard) == "function" then
						pcall(setclipboard, report)
						if type(DoNotif) == "function" then DoNotif("Full error report copied", 2, errorId) end
					elseif type(DoWindow) == "function" then
						DoWindow(report, errorId)
					else
						warn(report)
					end
				end;
			};
			{
				Text = "View Details";
				Callback = function()
					if type(DoWindow) == "function" then
						DoWindow(report, errorId.." Error Report")
					else
						warn(report)
					end
				end;
			};
			{
				Text = "Discord Server";
				Callback = function()
					const inviteLink = type(NAmanage._sourceGlyph) == "function" and NAmanage._sourceGlyph(NAStuff.inviteLink) or tostring(NAStuff.inviteLink or "")
					if type(setclipboard) == "function" then
						pcall(setclipboard, inviteLink)
						if type(DoNotif) == "function" then DoNotif("Discord link copied to clipboard", 2) end
					elseif type(DoWindow) == "function" then
						DoWindow("Server Invite: "..inviteLink, "Discord Server")
					end
				end;
			};
		};
	})
end

function NACaller(fnOrOptions, ...)
	const options = {}
	for key, value in NAStuff.NACallerOptions do
		options[key] = value
	end
	local fn
	local args
	if type(fnOrOptions) == "table" and type(select(1, ...)) == "function" then
		for key, value in fnOrOptions do
			options[key] = value
		end
		fn = select(1, ...)
		args = table.pack(select(2, ...))
	else
		fn = fnOrOptions
		args = table.pack(...)
	end
	if type(fn) ~= "function" then
		const message = "NACaller expected a function, got "..type(fn)
		if options.warn ~= false then warn(message) end
		return false, message
	end
	local rawError
	const function wrapped()
		return fn(Unpack(args, 1, args.n))
	end
	const t = table.pack(xpcall(wrapped, function(msg)
		rawError = tostring(msg or "Unknown error")
		if type(debug) == "table" and type(debug.traceback) == "function" then
			local ok, trace = pcall(debug.traceback, rawError, 2)
			if ok and type(trace) == "string" and trace ~= "" then return trace end
		end
		return rawError
	end))
	if not t[1] then
		const tracebackText = tostring(t[2] or rawError or "Unknown error")
		NAmanage.NACallerReportExternalError(rawError or tracebackText, tracebackText, fn, options)
		if options.rethrow == true then
			error(tracebackText, 0)
		end
	end
	return Unpack(t, 1, t.n)
end

if type(__NARootHost) == "table" then
	pcall(rawset, __NARootHost, "NACaller", NACaller)
end

NAmanage.loaderState = NAmanage.loaderState or {
	autoSkip = false;
	loaded = false;
	hideStartup = NAHideStartup == true;
	hideStartupLoaded = false;
	settingsPath = "Nameless-Admin/Settings.json";
}

function getAutoSkipSettingsPath()
	const state = NAmanage.loaderState or {}
	const path = state.settingsPath
	if type(path) == "string" and path ~= "" then
		return path
	end
	if type(NAfiles) == "table" and type(NAfiles.NAMAINSETTINGSPATH) == "string" then
		return NAfiles.NAMAINSETTINGSPATH
	end
	return "Nameless-Admin/Settings.json"
end

function getAutoSkipFromSettingsCache(state)
	if type(NAmanage.NASettingsGet) == "function" then
		local ok, value = NACaller(NAmanage.NASettingsGet, "autoSkipLoading")
		if ok and type(value) == "boolean" then
			state.autoSkip = value
			state.loaded = true
			return true, value
		end
	end

	if type(NAStuff.NASettingsData) == "table" then
		const value = NAStuff.NASettingsData.autoSkipLoading
		if type(value) == "boolean" then
			state.autoSkip = value
			state.loaded = true
			return true, value
		end
	end

	return false, nil
end

function readAutoSkipSettingsFile(path)
	if not (FileSupport and type(isfile) == "function" and NAmanage.safeIsFile(path)) then
		return nil
	end

	local ok, raw = NACaller(readfile, path)
	if not (ok and type(raw) == "string" and raw ~= "") then
		return nil
	end

	local decodeOk, decoded = NACaller(function()
		return Services.HttpService:JSONDecode(raw)
	end)

	if decodeOk and typeof(decoded) == "table" then
		return decoded
	end

	return nil
end

function writeAutoSkipSettingsFile(path, enabled)
	if not FileSupport then
		return false
	end

	if type(NAmanage.safeMakeFolder) == "function" then
		NAmanage.safeMakeFolder("Nameless-Admin")
	elseif type(makefolder) == "function" and type(isfolder) == "function" then
		local okFolder, exists = pcall(isfolder, "Nameless-Admin")
		if not (okFolder and exists == true) then
			pcall(makefolder, "Nameless-Admin")
		end
	end

	local data = readAutoSkipSettingsFile(path)
	if typeof(data) ~= "table" then
		data = {}
	end

	data.autoSkipLoading = enabled == true

	local encodeOk, encoded = NACaller(function()
		return Services.HttpService:JSONEncode(data)
	end)

	if encodeOk and type(encoded) == "string" then
		const ok = NAmanage.safeWriteFile(path, encoded)
		return ok == true
	end

	return false
end

NAmanage.getAutoSkipPreference = function()
	const state = NAmanage.loaderState
	local cached, value = getAutoSkipFromSettingsCache(state)
	if cached then
		return value
	end

	if state.loaded then
		return state.autoSkip
	end

	state.loaded = true
	const data = readAutoSkipSettingsFile(getAutoSkipSettingsPath())
	if typeof(data) == "table" and type(data.autoSkipLoading) == "boolean" then
		state.autoSkip = data.autoSkipLoading
	end

	return state.autoSkip
end

NAmanage.setAutoSkipPreference = function(enabled)
	const state = NAmanage.loaderState
	const value = enabled and true or false
	state.autoSkip = value
	state.loaded = true

	if type(NAStuff.NASettingsData) == "table" then
		NAStuff.NASettingsData.autoSkipLoading = value
	end

	if type(NAmanage.NASettingsEnsure) == "function" and type(NAmanage.NASettingsSave) == "function" then
		local ok, settings = NACaller(NAmanage.NASettingsEnsure)
		if ok and typeof(settings) == "table" then
			settings.autoSkipLoading = value
			NAStuff.NASettingsData = settings
			NACaller(NAmanage.NASettingsSave)
			return
		end
	end

	writeAutoSkipSettingsFile(getAutoSkipSettingsPath(), value)
end

NAmanage.getHideStartupFromSettingsCache=function(state)
	if type(NAmanage.NASettingsGet) == "function" then
		local ok, value = NACaller(NAmanage.NASettingsGet, "hideStartup")
		if ok and type(value) == "boolean" then
			state.hideStartup = value
			state.hideStartupLoaded = true
			return true, value
		end
	end

	if type(NAStuff.NASettingsData) == "table" then
		const value = NAStuff.NASettingsData.hideStartup
		if type(value) == "boolean" then
			state.hideStartup = value
			state.hideStartupLoaded = true
			return true, value
		end
	end

	return false, nil
end

NAmanage.writeHideStartupSettingsFile=function(path, enabled)
	if not FileSupport then
		return false
	end

	if type(NAmanage.safeMakeFolder) == "function" then
		NAmanage.safeMakeFolder("Nameless-Admin")
	elseif type(makefolder) == "function" and type(isfolder) == "function" then
		local okFolder, exists = pcall(isfolder, "Nameless-Admin")
		if not (okFolder and exists == true) then
			pcall(makefolder, "Nameless-Admin")
		end
	end

	local data = readAutoSkipSettingsFile(path)
	if typeof(data) ~= "table" then
		data = {}
	end

	data.hideStartup = enabled == true

	local encodeOk, encoded = NACaller(function()
		return Services.HttpService:JSONEncode(data)
	end)

	if encodeOk and type(encoded) == "string" then
		const ok = NAmanage.safeWriteFile(path, encoded)
		return ok == true
	end

	return false
end

NAmanage.getHideStartupPreference = function()
	const state = NAmanage.loaderState
	local cached, value = NAmanage.getHideStartupFromSettingsCache(state)
	if cached then
		NAHideStartup = value == true
		if type(NAStuff) == "table" then
			NAStuff.HideStartup = NAHideStartup
		end
		return value
	end

	if state.hideStartupLoaded then
		return state.hideStartup == true
	end

	state.hideStartupLoaded = true
	const data = readAutoSkipSettingsFile(getAutoSkipSettingsPath())
	if typeof(data) == "table" and type(data.hideStartup) == "boolean" then
		state.hideStartup = data.hideStartup
	end

	NAHideStartup = state.hideStartup == true
	if type(NAStuff) == "table" then
		NAStuff.HideStartup = NAHideStartup
	end
	return state.hideStartup == true
end

NAmanage.setHideStartupPreference = function(enabled)
	const state = NAmanage.loaderState
	const value = enabled and true or false
	state.hideStartup = value
	state.hideStartupLoaded = true
	NAHideStartup = value
	if type(NAStuff) == "table" then
		NAStuff.HideStartup = value
	end

	if type(NAStuff.NASettingsData) == "table" then
		NAStuff.NASettingsData.hideStartup = value
	end

	if type(NAmanage.NASettingsEnsure) == "function" and type(NAmanage.NASettingsSave) == "function" then
		local ok, settings = NACaller(NAmanage.NASettingsEnsure)
		if ok and typeof(settings) == "table" then
			settings.hideStartup = value
			NAStuff.NASettingsData = settings
			NACaller(NAmanage.NASettingsSave)
			return
		end
	end

	NAmanage.writeHideStartupSettingsFile(getAutoSkipSettingsPath(), value)
end

NAmanage.isStartupHidden = function()
	if type(NAmanage.getHideStartupPreference) == "function" then
		return NAmanage.getHideStartupPreference() == true
	end
	return NAHideStartup == true or (type(NAStuff) == "table" and NAStuff.HideStartup == true)
end

NAmanage.RandomCursedInstanceString = NAmanage.RandomCursedInstanceString or function()
	const len = math.random(10, 20)
	const out = {}
	const marks = {"̶", "̷", "̸", "̹", "̺", "̻", "͓", "͔", "͘", "͜", "͞", "͟", "͢"}
	for i = 1, len do
		Insert(out, string.char(math.random(32, 126)))
		if math.random() < 0.5 then
			for _ = 1, math.random(1, 4) do
				Insert(out, marks[math.random(#marks)])
			end
		end
	end
	if utf8 and type(utf8.char) == "function" and math.random() < 0.3 then
		Insert(out, utf8.char(math.random(0x0300, 0x036F)))
	end
	if math.random() < 0.1 then
		Insert(out, string.rep("​", math.random(5, 20)))
	end
	if utf8 and type(utf8.char) == "function" and math.random() < 0.2 then
		Insert(out, utf8.char(0x202E))
	end
	return Concat(out)
end

NAgui.rStringgg=function(key)
	const out = {}
	local mapKey = key
	if type(mapKey) ~= "string" or mapKey == "" then
		NAmanage._rStringSessionNameSeq = (tonumber(NAmanage._rStringSessionNameSeq) or 0) + 1
		mapKey = "RandomInstanceName_"..tostring(NAmanage._rStringSessionNameSeq)
	end

	if type(NAmanage.GetSessionInstanceName) == "function" then
		local ok, ret = pcall(NAmanage.GetSessionInstanceName, mapKey)
		if ok and type(ret) == "string" and ret ~= "" then
			Insert(out, ret)
		end
	end

	local cursed = nil
	if type(NAmanage.RandomCursedInstanceString) == "function" then
		local ok, ret = pcall(NAmanage.RandomCursedInstanceString)
		if ok and type(ret) == "string" and ret ~= "" then
			cursed = ret
		end
	end
	if type(cursed) == "string" and cursed ~= "" then
		Insert(out, cursed)
	end

	Insert(out, "\0")

	const result = Concat(out)
	if result ~= "" then
		return result
	end
	return "\0"
end

NAmanage.ProtectedInstances = NAmanage.ProtectedInstances or setmetatable({}, { __mode = "k" })

NAmanage.RandomizeInstanceName = NAmanage.RandomizeInstanceName or function(inst, key)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const name = (NAgui.rStringgg and NAgui.rStringgg(key)) or "\0"
	pcall(function()
		inst.Name = name
	end)
	return name
end

NAmanage.StartProtectedInstanceWatcher = NAmanage.StartProtectedInstanceWatcher or function()
	if NAStuff.ProtectedInstanceWatcherRunning then
		return
	end
	NAStuff.ProtectedInstanceWatcherRunning = true
	Spawn(function()
		while NAStuff and NAStuff.ProtectedInstanceWatcherRunning do
			local any = false
			for inst, info in NAmanage.ProtectedInstances do
				any = true
				if typeof(inst) ~= "Instance" then
					NAmanage.ProtectedInstances[inst] = nil
				elseif type(info) == "table" then
					if info.enforceName == true and type(info.name) == "string" then
						pcall(function()
							if inst.Name ~= info.name then
								inst.Name = info.name
							end
						end)
					end
					if info.enforceParent == true then
						const wantedParent = info.parent
						pcall(function()
							if inst.Parent ~= wantedParent then
								inst.Parent = wantedParent
							end
						end)
					end
				end
			end
			Wait(any and 1.25 or 4)
		end
	end)
end

NAmanage.ProtectInstance = NAmanage.ProtectInstance or function(inst, opts)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	opts = opts or {}
	if __NAUIProtector and type(__NAUIProtector.protectInstance) == "function" then
		local ok, protected = pcall(__NAUIProtector.protectInstance, inst, opts)
		if ok and protected then
			return protected
		end
	end
	local protectedName = nil
	if opts.renameRoot == true then
		protectedName = NAmanage.RandomizeInstanceName(inst, opts.nameKey)
	end
	if opts.renameDescendants == true then
		for _, desc in NAmanage.QueryDescendants(inst, "Instance") do
			NAmanage.RandomizeInstanceName(desc)
		end
	end
	if opts.register ~= false and (opts.enforceName == true or opts.enforceParent == true) then
		NAmanage.ProtectedInstances[inst] = {
			enforceName = opts.enforceName == true and type(protectedName) == "string",
			name = protectedName,
			enforceParent = opts.enforceParent == true,
			parent = opts.parent,
		}
		NAmanage.StartProtectedInstanceWatcher()
	end
	return inst
end

NAgui.NAProtection=function(inst,var)
	if __NAUIProtector and type(__NAUIProtector.protectName) == "function" then
		local ok, result = pcall(__NAUIProtector.protectName, inst, var)
		if ok and result then
			return result
		end
	end
	if not inst then return end
	if var then
		inst[var] = ((NAgui.rStringgg and NAgui.rStringgg()) or "\0")
	else
		inst.Name   = ((NAgui.rStringgg and NAgui.rStringgg()) or "\0")
	end
	if NAmanage.ProtectInstance then
		NAmanage.ProtectInstance(inst, {
			register = true,
		})
	end
end

NAgui.NaProtectUI=function(gui)
	if __NAUIProtector and type(__NAUIProtector.protectUI) == "function" then
		local ok, protected = pcall(__NAUIProtector.protectUI, gui, {
			parentResolver = NAmanage.guiCHECKINGAHHHHH,
			coreGui = Services.CoreGui,
			players = Services.Players,
			localPlayer = Services.Players and Services.Players.LocalPlayer,
		})
		if ok and protected then
			return protected
		end
	end
	if typeof(gui) ~= "Instance" then
		return nil
	end

	const INV = ((NAgui.rStringgg and NAgui.rStringgg()) or "\0")
	const MAX_DO = 0x7FFFFFFF
	const target = NAmanage.guiCHECKINGAHHHHH()
	if not target then return end
	gui.Name   = INV
	gui.Parent = target
	if NAmanage.ProtectInstance then
		NAmanage.ProtectInstance(gui, {
			register = true,
			enforceParent = true,
			parent = target,
		})
	end
	if gui:IsA("ScreenGui") then
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		gui.DisplayOrder   = MAX_DO
		gui.ResetOnSpawn   = false
		gui.IgnoreGuiInset = true
	end
	const props = {
		Parent         = target,
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
	for prop, val in props do
		if val ~= nil then
			gui:GetPropertyChangedSignal(prop):Connect(function()
				if gui[prop] ~= val then
					pcall(function() gui[prop] = val end)
				end
			end)
		end
	end
	gui.AncestryChanged:Connect(function(_, newParent)
		if gui.Parent ~= target then
			pcall(function() gui.Parent = target end)
		end
	end)
	Spawn(function()
		while gui and gui.Parent do
			Wait(0.75)
			for prop, val in props do
				if val ~= nil and gui[prop] ~= val then
					pcall(function() gui[prop] = val end)
				end
			end
		end
	end)
	return gui
end

function isAprilFools()
	const d = os.date("*t")
	local aprilMode = type(_na_boot) == "table" and type(_na_boot.hostEnv) == "table" and rawget(_na_boot.hostEnv, "ActivateAprilMode") or nil
	if aprilMode == nil then
		aprilMode = _na_env.ActivateAprilMode
	end
	return (d.month == 4 and d.day == 1) or aprilMode == true
end

function yayApril(isTesting)
	const baseNames = {
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
	const suffix = isTesting and "Testing" or "Admin"
	const name = baseNames[math.random(#baseNames)]
	return name.." "..suffix
end

function maybeMock(text)
	return isAprilFools() and MockText(text) or text
end

NAStuff.AprilFoolsData = NAStuff.AprilFoolsData or {}
NAStuff.AprilFoolsData.started = NAStuff.AprilFoolsData.started or false
NAStuff.AprilFoolsData.prankNotifs = NAStuff.AprilFoolsData.prankNotifs or {
	"Breaking news: "..adminName.." now ships with free banana peel DLC",
	"New feature unlocked: invisible UI. Close your eyes to see it",
	"Reminder: every bug today is a surprise feature",
	"Limited time event: type ;help for a coupon that does nothing",
	"Security alert: unauthorized laughter detected",
	"Patch notes: seriousness reduced by 200%",
}
NAStuff.AprilFoolsData.placeholderJokes = NAStuff.AprilFoolsData.placeholderJokes or {
	"Enter a totally real command (promise)",
	"Try ;clown ? We dare you",
	"Command bar is in prank mode, proceed with giggles",
	"Your keyboard is now a whoopee cushion",
	"This placeholder is legally binding. (Not really)",
	"Now with 300% more clown energy",
}
NAStuff.AprilFoolsData.originalColor = NAStuff.AprilFoolsData.originalColor or NAUISTROKER
NAStuff.AprilFoolsData.reverted = NAStuff.AprilFoolsData.reverted or false
NAStuff.AprilFoolsData.prankNotifCooldown = NAStuff.AprilFoolsData.prankNotifCooldown or {
	min = 60,
	max = 120,
}
NAStuff.AprilFoolsData.prankSoundCooldown = NAStuff.AprilFoolsData.prankSoundCooldown or {
	min = 300,
	max = 480,
}
NAStuff.AprilFoolsData.prankOverlayCooldown = NAStuff.AprilFoolsData.prankOverlayCooldown or {
	min = 420,
	max = 720,
}

MockText = function(text)
	const result = {}
	local toggle = true
	for i = 1, #text do
		const char = text:sub(i, i)
		if char:match("%a") then
			local transformed = toggle and char:upper() or char:lower()
			toggle = not toggle
			if math.random() < 0.25 then
				transformed = transformed:upper()
			elseif math.random() < 0.25 then
				transformed = transformed:lower()
			end
			Insert(result, transformed)
		else
			Insert(result, char)
		end
	end
	return Concat(result)
end

NAmanage.AprilPick = NAmanage.AprilPick or function(list)
	if type(list) ~= "table" or #list == 0 then
		return nil
	end
	return list[math.random(1, #list)]
end

NAmanage.nudgeAprilIcon = function()
	if not (isAprilFools() and TextButton) then return end
	const wobble = math.random(-15, 15)
	pcall(function()
		__lt.cm("TweenService", "Create", TextButton, TweenInfo.new(0.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Rotation = wobble }):Play()
		Delay(0.35, function()
			__lt.cm("TweenService", "Create", TextButton, TweenInfo.new(0.25, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), { Rotation = 0 }):Play()
		end)
	end)
end
