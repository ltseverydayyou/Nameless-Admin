NAmanage.ESP_PlayerLocatorEnableDrawing = function(force)
	if not NAmanage.DrawingTriangleSupported(true) then
		NAStuff.ESP_PlayerLocatorEnabled = true
		NAmanage.ESP_PlayerLocatorUseGuiFallback()
		return
	end
	if NAStuff.ESP_PlayerLocatorEnabled and not force and NAlib.isConnected("esp_player_locator_loop") and NAStuff.ESP_PlayerLocatorBackend == "drawing" then return end
	NAStuff.ESP_PlayerLocatorEnabled = true
	NAStuff.ESP_PlayerLocatorBackend = "drawing"

	if NAStuff.ESP_PlayerLocatorGui and NAStuff.ESP_PlayerLocatorGui.Parent then
		NAStuff.ESP_PlayerLocatorGui:Destroy()
		NAStuff.ESP_PlayerLocatorGui = nil
	end

	NAStuff.ESP_PlayerLocatorArrows = NAStuff.ESP_PlayerLocatorArrows or {}
	const arrows = NAStuff.ESP_PlayerLocatorArrows
	const holderState = {}
	local activeCount = 0
	local iterKey = nil
	local accum = 0
	local lastCleanup = 0

	const function getHolder(model)
		local holder = arrows[model]
		if type(holder) == "table" and holder.drawingArrow then
			return holder
		end
		if holder then
			NAmanage.ESP_LocatorDisposeHolder(holder)
			arrows[model] = nil
		end
		const maxActive = math.clamp(math.floor(tonumber(NAStuff.ESP_PlayerLocatorMaxArrows) or 180), 24, 500)
		if activeCount >= maxActive then
			return nil
		end
		const tri = NAmanage.DrawingCreateTriangle(Color3.new(1, 1, 1), 1)
		if not tri then
			NAmanage.ESP_PlayerLocatorUseGuiFallback()
			return nil
		end
		const label = NAStuff.ESP_PlayerLocatorShowText == true and NAmanage.DrawingCreateText("", Color3.new(1, 1, 1), NAStuff.ESP_PlayerLocatorTextSize or 14) or nil
		holder = {
			drawingArrow = tri,
			drawingLabel = label,
		}
		arrows[model] = holder
		holderState[holder] = { seen = os.clock() }
		activeCount += 1
		return holder
	end

	const function removeHolder(model, holder)
		local had = false
		if holder then
			NAmanage.ESP_LocatorDisposeHolder(holder)
			had = true
		end
		if holderState[holder] then
			holderState[holder] = nil
			had = true
		end
		if model ~= nil and arrows[model] ~= nil then
			arrows[model] = nil
			had = true
		end
		if had and activeCount > 0 then
			activeCount -= 1
		end
	end

	for _, holder in arrows do
		if type(holder) == "table" and holder.drawingArrow then
			activeCount += 1
			holderState[holder] = holderState[holder] or { seen = os.clock() }
		end
	end

	NAlib.disconnect("esp_player_locator_loop")
	NAlib.connect("esp_player_locator_loop", Services.RunService.RenderStepped:Connect(function(dt)
		if not NAStuff.ESP_PlayerLocatorEnabled then return end
		accum += tonumber(dt) or 0
		const updateRate = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorUpdateRate) or 18, 8, 60)
		const stepInterval = 1 / updateRate
		if accum < stepInterval then
			return
		end
		accum = 0

		const cam = Services.Workspace.CurrentCamera
		if not cam then return end
		const vp = cam.ViewportSize
		if vp.X <= 0 or vp.Y <= 0 then return end

		const size = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorSize) or 26, 12, 128)
		const textOn = (NAStuff.ESP_PlayerLocatorShowText == true)
		const textSize = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorTextSize) or 14, 10, 48)
		const perStep = math.clamp(math.floor(tonumber(NAStuff.ESP_PlayerLocatorPerStep) or 64), 12, 400)
		const staleSeconds = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorHoldSeconds) or 0.5, 0.15, 3)
		const now = os.clock()

		const lp = Services.Players.LocalPlayer
		const localChar = lp and lp.Character
		const localRoot = localChar and getRoot(localChar)

		const cx, cy = vp.X * 0.5, vp.Y * 0.5
		const margin = 16 + size * 0.5
		const minX, maxX = margin, vp.X - margin
		const minY, maxY = margin, vp.Y - margin

		local processed = 0
		while processed < perStep do
			if iterKey ~= nil and espCONS[iterKey] == nil then
				iterKey = nil
			end
			local model, data = next(espCONS, iterKey)
			if model == nil then
				model, data = next(espCONS, nil)
				if model == nil then
					iterKey = nil
					break
				end
			end
			iterKey = model
			processed += 1

			if data and data.isNPC ~= true and model and model.Parent and NAmanage.IsValidESPModel(model, false) then
				const targetPart = getRoot(model) or getHead(model) or NAmanage.ESP_FirstBasePart(model)
				const pos = targetPart and targetPart.Position or NAgui.getInstanceWorldPosition(model)
				if pos then
					const v3 = cam:WorldToViewportPoint(pos)
					const x, y, z = v3.X, v3.Y, v3.Z
					const onScreen = (z > 0 and x >= 0 and x <= vp.X and y >= 0 and y <= vp.Y)
					if onScreen then
						const holder = arrows[model]
						if type(holder) == "table" then
							if holder.drawingArrow then pcall(function() holder.drawingArrow.Visible = false end) end
							if holder.drawingLabel then pcall(function() holder.drawingLabel.Visible = false end) end
							const hs = holderState[holder]
							if hs then hs.seen = now end
						end
					else
						const holder = arrows[model] or getHolder(model)
						if type(holder) == "table" and holder.drawingArrow then
							local owner = data.ownerPlayer
							if not (owner and owner.Parent) then
								owner = __lt.cm("Players", "GetPlayerFromCharacter", model)
								if owner then
									data.ownerPlayer = owner
								end
							end
							const col = (NAStuff.ESP_UseCustomColor == true and NAStuff.ESP_CustomColor)
								or (owner and owner.Team and owner.Team.TeamColor and owner.Team.TeamColor.Color)
								or Color3.new(1, 1, 1)

							local dirX, dirY = NAmanage.ESP_LocatorDirection(cam, pos, v3, vp)

							const sx = (cx - margin) / math.max(1e-4, math.abs(dirX))
							const sy = (cy - margin) / math.max(1e-4, math.abs(dirY))
							const scale = math.min(sx, sy)
							local px = cx + (dirX * scale)
							local py = cy + (dirY * scale)
							if px < minX then px = minX elseif px > maxX then px = maxX end
							if py < minY then py = minY elseif py > maxY then py = maxY end

							if not NAmanage.DrawingUpdateTriangle(holder.drawingArrow, px, py, dirX, dirY, size, col, 1) then
								NAmanage.ESP_PlayerLocatorUseGuiFallback()
								return
							end
							const hs = holderState[holder]
							if hs then hs.seen = now end

							if textOn then
								if not holder.drawingLabel then
									holder.drawingLabel = NAmanage.DrawingCreateText("", col, textSize)
								end
								const label = holder.drawingLabel
								if label then
									local nm = (owner and nameChecker(owner)) or (model and model.Name) or "Player"
									if localRoot then
										const d = math.floor((localRoot.Position - pos).Magnitude + 0.5)
										nm = nm.." | "..tostring(d).." studs"
									end
									const gap = 8 + math.floor(size * 0.5)
									local lx = px - (dirX * gap)
									local ly = py - (dirY * gap)
									if lx < 4 then lx = 4 elseif lx > (vp.X - 4) then lx = vp.X - 4 end
									if ly < 4 then ly = 4 elseif ly > (vp.Y - 4) then ly = vp.Y - 4 end
									pcall(function()
										label.Text = nm
										label.Color = col
										label.Size = textSize
										label.Position = Vector2.new(lx, ly)
										label.Visible = true
									end)
								end
							elseif holder.drawingLabel then
								pcall(function()
									holder.drawingLabel.Visible = false
								end)
							end
						end
					end
				end
			else
				removeHolder(model, arrows[model])
			end
		end

		if now - lastCleanup >= 0.2 then
			lastCleanup = now
			for model, holder in arrows do
				const hs = holderState[holder]
				const stale = (not hs) or ((now - (hs.seen or 0)) > staleSeconds)
				const data = espCONS[model]
				const invalid = (not model) or (not data) or data.isNPC == true or (not model.Parent) or (not NAmanage.IsValidESPModel(model, false))
				const hasArrow = type(holder) == "table" and holder.drawingArrow ~= nil
				if invalid or (not hasArrow) or stale then
					removeHolder(model, holder)
				end
			end
		end
	end))
end

NAmanage.ESP_PlayerLocatorEnable = function(force)
	const targetBackend = NAmanage.ESP_PlayerLocatorShouldUseDrawing() and "drawing" or "gui"
	const currentBackend = tostring(NAStuff.ESP_PlayerLocatorBackend or "")
	if NAlib.isConnected("esp_player_locator_loop") and (force or currentBackend ~= targetBackend) then
		NAmanage.ESP_PlayerLocatorDisable()
	end
	if targetBackend == "drawing" then
		NAmanage.ESP_PlayerLocatorEnableDrawing(force)
	else
		NAmanage.ESP_PlayerLocatorEnableGui(force)
	end
end

NAmanage.ESP_PlayerLocatorDisable = function()
	NAStuff.ESP_PlayerLocatorEnabled = false
	NAlib.disconnect("esp_player_locator_loop")
	if NAStuff.ESP_PlayerLocatorArrows then
		for _, holder in NAStuff.ESP_PlayerLocatorArrows do
			NAmanage.ESP_LocatorDisposeHolder(holder)
		end
	end
	NAStuff.ESP_PlayerLocatorArrows = {}
	NAStuff.ESP_PlayerLocatorBackend = nil
	if NAStuff.ESP_PlayerLocatorGui and NAStuff.ESP_PlayerLocatorGui.Parent then
		NAStuff.ESP_PlayerLocatorGui:Destroy()
		NAStuff.ESP_PlayerLocatorGui = nil
	end
end

NAmanage.ItemESPColor = NAmanage.ItemESPColor or function()
	return NAmanage.GetPartESPColor("ESP_PartColor_Item", Color3.fromRGB(90, 255, 135))
end

NAmanage.ItemESPEnsureState = NAmanage.ItemESPEnsureState or function()
	NAStuff.itemESPList = type(NAStuff.itemESPList) == "table" and NAStuff.itemESPList or {}
	NAStuff.itemESPSet = type(NAStuff.itemESPSet) == "table" and NAStuff.itemESPSet or {}
	NAStuff.itemESPToolMap = type(NAStuff.itemESPToolMap) == "table" and NAStuff.itemESPToolMap or {}
	NAStuff.itemESPPartMap = type(NAStuff.itemESPPartMap) == "table" and NAStuff.itemESPPartMap or {}
	return NAStuff.itemESPList, NAStuff.itemESPSet, NAStuff.itemESPToolMap, NAStuff.itemESPPartMap
end

NAmanage.ItemESPRemoveTool = NAmanage.ItemESPRemoveTool or function(tool)
	NAmanage.ItemESPEnsureState()
	const part = NAStuff.itemESPToolMap and NAStuff.itemESPToolMap[tool] or nil
	if typeof(part) == "Instance" then
		NAmanage.PartESP_QueueRemove(part)
		NAmanage.RemoveEspFromPart(part)
		if NAStuff.itemESPSet then
			NAStuff.itemESPSet[part] = nil
		end
		if NAStuff.itemESPPartMap then
			NAStuff.itemESPPartMap[part] = nil
		end
		const listMap = NAmanage.ESP_GetListMap(NAStuff.itemESPList)
		if type(listMap) == "table" then
			NAmanage.ESP_ListRemove(NAStuff.itemESPList, listMap, part)
		end
	end
	if NAStuff.itemESPToolMap then
		NAStuff.itemESPToolMap[tool] = nil
	end
end

NAmanage.ItemESPTrackTool = NAmanage.ItemESPTrackTool or function(tool, force)
	NAmanage.ItemESPEnsureState()
	if not NAmanage.isDroppedTool(tool) then
		NAmanage.ItemESPRemoveTool(tool)
		return false
	end
	const part = NAmanage.toolPart(tool)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return false
	end
	const previous = NAStuff.itemESPToolMap and NAStuff.itemESPToolMap[tool] or nil
	if previous and previous ~= part then
		NAmanage.ItemESPRemoveTool(tool)
	end
	NAStuff.itemESPToolMap[tool] = part
	NAStuff.itemESPPartMap[part] = tool
	NAStuff.itemESPSet[part] = true
	const listMap = NAmanage.ESP_GetListMap(NAStuff.itemESPList)
	if type(listMap) == "table" then
		NAmanage.ESP_ListAdd(NAStuff.itemESPList, listMap, part)
	end
	if force ~= true and previous == part and type(NAStuff.partESPPartMap) == "table" and NAStuff.partESPPartMap[part] ~= nil then
		return true
	end
	const itemName = tostring(tool.Name or "Item")
	NAmanage.PartESP_QueueCreate(part, NAmanage.ItemESPColor(), NAStuff.ESP_PartTransparency or 0.45, function(p)
		return NAStuff.itemESPSet and NAStuff.itemESPSet[p] == true
			and NAStuff.itemESPPartMap and NAmanage.isDroppedTool(NAStuff.itemESPPartMap[p])
	end, itemName)
	return true
end

NAmanage.ItemESPRefresh = NAmanage.ItemESPRefresh or function(force, fullScan)
	NAmanage.ItemESPEnsureState()
	if NAStuff.itemESPEnabled ~= true then
		return 0
	end
	const seenParts = {}
	local count = 0
	for _, tool in NAmanage.toolList(fullScan == true) do
		if NAmanage.ItemESPTrackTool(tool, force) then
			const part = NAStuff.itemESPToolMap and NAStuff.itemESPToolMap[tool] or nil
			if part then
				seenParts[part] = true
				count += 1
			end
		end
	end
	for i = #(NAStuff.itemESPList or {}), 1, -1 do
		const part = NAStuff.itemESPList[i]
		const tool = NAStuff.itemESPPartMap and NAStuff.itemESPPartMap[part] or nil
		if not (part and part.Parent and seenParts[part] and NAmanage.isDroppedTool(tool)) then
			if tool then
				NAmanage.ItemESPRemoveTool(tool)
			else
				NAmanage.RemoveEspFromPart(part)
				if NAStuff.itemESPSet then
					NAStuff.itemESPSet[part] = nil
				end
				if NAStuff.itemESPPartMap then
					NAStuff.itemESPPartMap[part] = nil
				end
				const listMap = NAmanage.ESP_GetListMap(NAStuff.itemESPList)
				if type(listMap) == "table" then
					NAmanage.ESP_ListRemove(NAStuff.itemESPList, listMap, part)
				else
					table.remove(NAStuff.itemESPList, i)
				end
			end
		end
	end
	return count
end

NAmanage.ItemESPEnable = NAmanage.ItemESPEnable or function()
	NAmanage.ItemESPEnsureState()
	NAStuff.itemESPEnabled = true
	NAmanage.initToolCache()
	const count = NAmanage.ItemESPRefresh(false, true)
	NAlib.disconnect("itemesp_loop")
	local nextRefresh = 0
	local nextFullRefresh = 0
	NAlib.connect("itemesp_loop", Services.RunService.Heartbeat:Connect(function()
		if NAStuff.itemESPEnabled ~= true then
			NAlib.disconnect("itemesp_loop")
			return
		end
		const now = tick()
		if now >= nextRefresh then
			nextRefresh = now + 1
			const fullScan = now >= nextFullRefresh
			if fullScan then
				nextFullRefresh = now + 2
			end
			NAmanage.ItemESPRefresh(false, fullScan)
		end
	end))
	NAlib.disconnect("itemesp_workspace_add")
	NAlib.connect("itemesp_workspace_add", NAmanage.descAdd(Services.Workspace, function(inst)
		if NAStuff.itemESPEnabled ~= true then return end
		if inst:IsA("Tool") then
			NAmanage.addToolCache(inst)
			Defer(function()
				if NAStuff.itemESPEnabled == true then
					NAmanage.ItemESPTrackTool(inst)
				end
			end)
		elseif inst:IsA("BasePart") then
			const tool = inst:FindFirstAncestorWhichIsA("Tool")
			if tool then
				NAmanage.addToolCache(tool)
				Defer(function()
					if NAStuff.itemESPEnabled == true then
						NAmanage.ItemESPTrackTool(tool)
					end
				end)
			end
		end
	end, function(inst)
		return inst and (inst:IsA("Tool") or inst:IsA("BasePart"))
	end))
	NAlib.disconnect("itemesp_workspace_rem")
	NAlib.connect("itemesp_workspace_rem", NAmanage.descRem(Services.Workspace, function(inst)
		if inst:IsA("Tool") then
			NAmanage.ItemESPRemoveTool(inst)
		elseif inst:IsA("BasePart") then
			const tool = NAStuff.itemESPPartMap and NAStuff.itemESPPartMap[inst] or nil
			if tool then
				NAmanage.ItemESPRemoveTool(tool)
			end
		end
	end, function(inst)
		return inst and (inst:IsA("Tool") or inst:IsA("BasePart"))
	end))
	DebugNotif(("Item ESP enabled. Showing %d dropped item%s."):format(count, count == 1 and "" or "s"), 2)
	return count
end

NAmanage.ItemESPDisable = NAmanage.ItemESPDisable or function()
	NAmanage.ItemESPEnsureState()
	NAStuff.itemESPEnabled = false
	NAlib.disconnect("itemesp_loop")
	NAlib.disconnect("itemesp_workspace_add")
	NAlib.disconnect("itemesp_workspace_rem")
	for i = #(NAStuff.itemESPList or {}), 1, -1 do
		const part = NAStuff.itemESPList[i]
		if part then
			NAmanage.PartESP_QueueRemove(part)
			NAmanage.RemoveEspFromPart(part)
		end
		NAStuff.itemESPList[i] = nil
	end
	if type(NAStuff.itemESPSet) == "table" then table.clear(NAStuff.itemESPSet) end
	if type(NAStuff.itemESPToolMap) == "table" then table.clear(NAStuff.itemESPToolMap) end
	if type(NAStuff.itemESPPartMap) == "table" then table.clear(NAStuff.itemESPPartMap) end
	DebugNotif("Item ESP disabled.", 2)
end

cmd.add({"touchesp","tesp"},{"touchesp"},function()
	NAmanage.EnableEsp("TouchTransmitter", function()
		return NAmanage.GetPartESPColor("ESP_PartColor_Touch", Color3.fromRGB(255,0,0))
	end, NAStuff.touchESPList)
end)

cmd.add({"untouchesp","untesp"},{"untouchesp"},function()
	NAmanage.DisableEsp("TouchTransmitter", NAStuff.touchESPList)
end)

cmd.add({"proximityesp","prxesp","proxiesp"},{"proximityesp"},function()
	NAmanage.EnableEsp("ProximityPrompt", function()
		return NAmanage.GetPartESPColor("ESP_PartColor_Proximity", Color3.fromRGB(0,0,255))
	end, NAStuff.proximityESPList)
end)

cmd.add({"unproximityesp","unprxesp","unproxiesp"},{"unproximityesp"},function()
	NAmanage.DisableEsp("ProximityPrompt", NAStuff.proximityESPList)
end)

cmd.add({"clickesp","cesp"},{"clickesp"},function()
	NAmanage.EnableEsp("ClickDetector", function()
		return NAmanage.GetPartESPColor("ESP_PartColor_Click", Color3.fromRGB(255,165,0))
	end, NAStuff.clickESPList)
end)

cmd.add({"unclickesp","uncesp"},{"unclickesp"},function()
	NAmanage.DisableEsp("ClickDetector", NAStuff.clickESPList)
end)

cmd.add({"itemesp", "toolesp", "iesp"}, {"itemesp", "Highlight dropped in-game tools/items"}, function()
	NAmanage.ItemESPEnable()
end)

cmd.add({"unitemesp", "untoolesp", "uniesp"}, {"unitemesp", "Disable dropped item ESP"}, function()
	NAmanage.ItemESPDisable()
end)

cmd.add({"sitesp","ssp"},{"sitesp"},function()
	NAmanage.EnableEsp("Seat", function()
		return NAmanage.GetPartESPColor("ESP_PartColor_Seat", Color3.fromRGB(0,255,0))
	end, NAStuff.siteESPList)
end)

cmd.add({"unsitesp","unssp"},{"unsitesp"},function()
	NAmanage.DisableEsp("Seat", NAStuff.siteESPList)
end)

cmd.add({"vehiclesitesp","vsitesp","vsp"},{"vehiclesitesp"},function()
	NAmanage.EnableEsp("VehicleSeat", function()
		return NAmanage.GetPartESPColor("ESP_PartColor_VehicleSeat", Color3.fromRGB(255,0,255))
	end, NAStuff.vehicleSiteESPList)
end)

cmd.add({"unvehiclesitesp","unvsitesp","unvsp"},{"unvehiclesitesp"},function()
	NAmanage.DisableEsp("VehicleSeat", NAStuff.vehicleSiteESPList)
end)

cmd.add({"pesp","esppart","partesp"},{"pesp {partname}"},function(...)
	const name = Concat({...}," ")
	if name=="" then
		NAmanage.DisableNameEsp("exact")
	else
		NAmanage.EnableNameEsp("exact", nil, name)
	end
end,true)

cmd.add({"unpesp","unesppart","unpartesp"},{"unpesp [name|All]","Remove exact-name part ESP by name or All"},function(...)
	const mode = "exact"
	const parts = NAStuff.nameESPPartLists and NAStuff.nameESPPartLists[mode] or {}
	const partMap = NAStuff.nameESPPartMaps and NAStuff.nameESPPartMaps[mode] or {}
	const terms = NAStuff.espNameLists and NAStuff.espNameLists[mode] or {}
	if type(terms) ~= "table" or #terms == 0 then
		DoNotif("No exact-name ESP terms are active.", 2)
		return
	end

	const filter = Lower(Concat({...}," "))

	const function removeAll()
		NAmanage.DisableNameEsp(mode)
		DoNotif("Cleared all exact-name part ESP.", 2)
	end

	const function removeByTerm(term)
		for i = #terms, 1, -1 do
			if terms[i] == term then
				table.remove(terms, i)
			end
		end
		local i = #parts
		while i >= 1 do
			const p = parts[i]
			if p and p.Parent and NAmanage.NameESP_TermMatchesPart(term, p, mode) then
				NAmanage.RemoveEspFromPart(p)
				const removed = NAmanage.ESP_ListRemove(parts, partMap, p)
				if not removed then
					i -= 1
				end
			else
				i -= 1
			end
		end
		DoNotif("Removed exact-name ESP for '"..term.."'.", 2)
	end

	if filter ~= "" then
		if filter == "all" then
			removeAll()
			return
		end
		local picked = nil
		for _, t in terms do
			if t == filter then picked = t break end
		end
		if not picked then
			for _, t in terms do
				if Match(t, filter) then picked = t break end
			end
		end
		if picked then
			removeByTerm(picked)
		else
			DoNotif("No matching exact-name ESP term for: "..filter, 3)
		end
		return
	end

	const buttons = {}
	Insert(buttons, { Text = "All", Callback = removeAll })
	for _, t in terms do
		Insert(buttons, { Text = t, Callback = function() removeByTerm(t) end })
	end

	Window({
		Title = "Remove Exact Part ESP",
		Description = "Select a term to stop tracking (future spawns included).",
		Buttons = buttons
	})
end,true)

cmd.add({"pespfind","partespfind","esppartfind"},{"pespfind {partname}"},function(...)
	const name = Concat({...}," ")
	if name=="" then
		NAmanage.DisableNameEsp("partial")
	else
		NAmanage.EnableNameEsp("partial", nil, name)
	end
end,true)

cmd.add({"unpespfind","unpartespfind","unesppartfind"},{"unpespfind [name|All]","Remove partial-name part ESP by name or All"},function(...)
	const mode = "partial"
	const parts = NAStuff.nameESPPartLists and NAStuff.nameESPPartLists[mode] or {}
	const partMap = NAStuff.nameESPPartMaps and NAStuff.nameESPPartMaps[mode] or {}
	const terms = NAStuff.espNameLists and NAStuff.espNameLists[mode] or {}
	if type(terms) ~= "table" or #terms == 0 then
		DoNotif("No partial-name ESP terms are active.", 2)
		return
	end

	const filter = Lower(Concat({...}," "))

	const function removeAll()
		NAmanage.DisableNameEsp(mode)
		DoNotif("Cleared all partial-name part ESP.", 2)
	end

	const function removeByTerm(term)
		for i = #terms, 1, -1 do
			if terms[i] == term then
				table.remove(terms, i)
			end
		end
		local i = #parts
		while i >= 1 do
			const p = parts[i]
			if p and p.Parent and NAmanage.NameESP_TermMatchesPart(term, p, mode) then
				NAmanage.RemoveEspFromPart(p)
				const removed = NAmanage.ESP_ListRemove(parts, partMap, p)
				if not removed then
					i -= 1
				end
			else
				i -= 1
			end
		end
		DoNotif("Removed partial-name ESP for '"..term.."'.", 2)
	end

	if filter ~= "" then
		if filter == "all" then
			removeAll()
			return
		end
		local picked = nil
		for _, t in terms do
			if t == filter then picked = t break end
		end
		if not picked then
			for _, t in terms do
				if Match(t, filter) then picked = t break end
			end
		end
		if picked then
			removeByTerm(picked)
		else
			DoNotif("No matching partial-name ESP term for: "..filter, 3)
		end
		return
	end

	const buttons = {}
	Insert(buttons, { Text = "All", Callback = removeAll })
	for _, t in terms do
		Insert(buttons, { Text = t, Callback = function() removeByTerm(t) end })
	end

	Window({
		Title = "Remove Partial Part ESP",
		Description = "Select a term to stop tracking (future spawns included).",
		Buttons = buttons
	})
end,true)

cmd.add({"unanchored","unanchoredesp","uaesp"},{"unanchored"},function()
	NAmanage.EnableUnanchoredEsp(function()
		return NAmanage.GetPartESPColor("ESP_PartColor_Unanchored", Color3.fromRGB(255,220,0))
	end)
end)

cmd.add({"ununanchored","ununanchoredesp","unuaesp"},{"ununanchored"},function()
	NAmanage.DisableUnanchoredEsp()
end)

cmd.add({"collisionesp","colesp"},{"collisionesp"},function()
	NAmanage.EnableCollisionEsp(true, function()
		return NAmanage.GetPartESPColor("ESP_PartColor_CollisionTrue", Color3.fromRGB(0,200,255))
	end)
end)

cmd.add({"uncollisionesp","uncolesp"},{"uncollisionesp"},function()
	NAmanage.DisableCollisionEsp(true)
end)

cmd.add({"nocollisionesp","ncolesp"},{"nocollisionesp"},function()
	NAmanage.EnableCollisionEsp(false, function()
		return NAmanage.GetPartESPColor("ESP_PartColor_CollisionFalse", Color3.fromRGB(255,120,120))
	end)
end)

cmd.add({"unnocollisionesp","unncolesp"},{"unnocollisionesp"},function()
	NAmanage.DisableCollisionEsp(false)
end)

NAmanage.PropertyESP_EnsureState = function()
	NAStuff.propertyESPList = type(NAStuff.propertyESPList) == "table" and NAStuff.propertyESPList or {}
	NAStuff.propertyESPSet = NAmanage.ensureWeakTable(NAStuff.propertyESPSet, "k")
	NAStuff.propertyESPMatchCounts = NAmanage.ensureWeakTable(NAStuff.propertyESPMatchCounts, "k")
	NAStuff.propertyESPObjectMaps = type(NAStuff.propertyESPObjectMaps) == "table" and NAStuff.propertyESPObjectMaps or {}
	NAStuff.propertyESPQueries = type(NAStuff.propertyESPQueries) == "table" and NAStuff.propertyESPQueries or {}
	return NAStuff.propertyESPList, NAStuff.propertyESPSet, NAStuff.propertyESPMatchCounts, NAStuff.propertyESPObjectMaps, NAStuff.propertyESPQueries
end

NAmanage.PropertyESP_NormalizeText = function(value)
	local textValue = tostring(value or "")
	textValue = GSub(textValue, "^%s+", "")
	textValue = GSub(textValue, "%s+$", "")
	return Lower(textValue)
end

NAmanage.PropertyESP_ClassMatches = function(obj, className)
	if typeof(obj) ~= "Instance" then
		return false
	end
	className = tostring(className or "")
	if className == "" then
		return true
	end
	local ok, result = pcall(function()
		return obj:IsA(className)
	end)
	return ok and result == true
end

NAmanage.PropertyESP_ValueMatches = function(value, expected)
	const expectedText = NAmanage.PropertyESP_NormalizeText(expected)
	if expectedText == "" then
		return false
	end
	const kind = typeof(value)
	if kind == "EnumItem" then
		const candidates = { tostring(value) }
		pcall(function()
			candidates[#candidates + 1] = value.Name
			candidates[#candidates + 1] = value.EnumType.Name.."."..value.Name
			candidates[#candidates + 1] = "Enum."..value.EnumType.Name.."."..value.Name
		end)
		for _, candidate in candidates do
			if NAmanage.PropertyESP_NormalizeText(candidate) == expectedText then
				return true
			end
		end
		return false
	elseif kind == "boolean" then
		return (value == true and (expectedText == "true" or expectedText == "1" or expectedText == "yes" or expectedText == "on"))
			or (value == false and (expectedText == "false" or expectedText == "0" or expectedText == "no" or expectedText == "off"))
	elseif kind == "number" then
		const n = tonumber(expectedText)
		if n then
			return math.abs(value - n) <= 0.000001
		end
		return NAmanage.PropertyESP_NormalizeText(value) == expectedText
	end
	return NAmanage.PropertyESP_NormalizeText(value) == expectedText
end

NAmanage.PropertyESP_ResolveTarget = function(obj)
	if typeof(obj) ~= "Instance" then
		return nil
	end
	if obj:IsA("BasePart") or obj:IsA("Model") then
		return obj
	end
	return obj:FindFirstAncestorWhichIsA("BasePart") or obj:FindFirstAncestorWhichIsA("Model")
end

NAmanage.PropertyESP_CurrentColor = function(record)
	const colorValue = record and record.color
	const resolved = (type(colorValue) == "function") and colorValue() or colorValue
	if typeof(resolved) == "Color3" then
		return resolved
	end
	return NAmanage.GetPartESPColor("ESP_PartColor_Property", Color3.fromRGB(190, 120, 255))
end

NAmanage.PropertyESP_RemoveTarget = function(record, obj)
	if type(record) ~= "table" then
		return false
	end
	const matches = record.matches
	const target = type(matches) == "table" and matches[obj] or nil
	if target == nil then
		return false
	end
	matches[obj] = nil
	const list, setMap, counts = NAStuff.propertyESPList, NAStuff.propertyESPSet, NAStuff.propertyESPMatchCounts
	const count = tonumber(counts and counts[target]) or 0
	if count <= 1 then
		if counts then
			counts[target] = nil
		end
		if NAmanage.ESP_ListRemove(list, setMap, target) then
			NAmanage.PartESP_QueueRemove(target)
			NAmanage.RemoveEspFromPart(target)
		end
	else
		counts[target] = count - 1
	end
	return true
end

NAmanage.PropertyESP_AddTarget = function(record, obj, target)
	if type(record) ~= "table" or typeof(obj) ~= "Instance" or typeof(target) ~= "Instance" then
		return false
	end
	local list, setMap, counts, objectMaps = NAmanage.PropertyESP_EnsureState()
	local matches = record.matches
	if type(matches) ~= "table" then
		matches = NAmanage.ensureWeakTable(nil, "k")
		record.matches = matches
		objectMaps[record.key] = matches
	end
	const current = matches[obj]
	if current == target then
		return false
	end
	if current ~= nil then
		NAmanage.PropertyESP_RemoveTarget(record, obj)
	end
	matches[obj] = target
	const count = tonumber(counts[target]) or 0
	counts[target] = count + 1
	if count <= 0 and NAmanage.ESP_ListAdd(list, setMap, target) then
		NAmanage.PartESP_QueueCreate(target, NAmanage.PropertyESP_CurrentColor(record), NAStuff.ESP_PartTransparency or 0.45, function(p)
			return setMap[p] ~= nil
		end)
	end
	return true
end

NAmanage.PropertyESP_UpdateObject = function(obj, record)
	if typeof(obj) ~= "Instance" or type(record) ~= "table" then
		return
	end
	if not obj.Parent then
		NAmanage.PropertyESP_RemoveTarget(record, obj)
		return
	end
	if not NAmanage.PropertyESP_ClassMatches(obj, record.className) then
		NAmanage.PropertyESP_RemoveTarget(record, obj)
		return
	end
	const value = NAlib.isProperty(obj, record.propertyName)
	if value == nil then
		NAmanage.PropertyESP_RemoveTarget(record, obj)
		return
	end
	record.propertyFound = true
	if NAmanage.PropertyESP_ValueMatches(value, record.valueText) then
		record.foundMatches = (tonumber(record.foundMatches) or 0) + 1
		const target = NAmanage.PropertyESP_ResolveTarget(obj)
		if target and target.Parent then
			NAmanage.PropertyESP_AddTarget(record, obj, target)
		else
			NAmanage.PropertyESP_RemoveTarget(record, obj)
		end
	else
		NAmanage.PropertyESP_RemoveTarget(record, obj)
	end
end

NAmanage.PropertyESP_UpdateAllRecords = function(obj)
	const queries = NAStuff and NAStuff.propertyESPQueries
	if type(queries) ~= "table" then
		return
	end
	for _, record in queries do
		NAmanage.PropertyESP_UpdateObject(obj, record)
	end
end

NAmanage.PropertyESP_RemoveObjectFromAll = function(obj)
	const queries = NAStuff and NAStuff.propertyESPQueries
	if type(queries) ~= "table" then
		return
	end
	for _, record in queries do
		NAmanage.PropertyESP_RemoveTarget(record, obj)
	end
end

NAmanage.PropertyESP_HasQueries = function()
	const queries = NAStuff and NAStuff.propertyESPQueries
	return type(queries) == "table" and next(queries) ~= nil
end

NAmanage.PropertyESP_StartWatchers = function()
	NAmanage.PropertyESP_EnsureState()
	if not NAStuff.espTriggers["__propertyesp"] then
		NAStuff.espTriggers["__propertyesp"] = NAmanage.wsSub({
			added = function(obj)
				NAmanage.PropertyESP_UpdateAllRecords(obj)
			end,
			removing = function(obj)
				NAmanage.PropertyESP_RemoveObjectFromAll(obj)
			end,
		})
	end
	NAmanage.PartESP_StartSweep("__propertyesp_sweep", function(obj)
		NAmanage.PropertyESP_UpdateAllRecords(obj)
	end, tonumber(NAStuff.ESP_RescanPerStep) or 90, tonumber(NAStuff.ESP_PartSweepInterval) or 4)
end

NAmanage.PropertyESP_StopWatchersIfIdle = function()
	if NAmanage.PropertyESP_HasQueries() then
		return
	end
	if NAStuff.espTriggers["__propertyesp"] then
		NAStuff.espTriggers["__propertyesp"]:Disconnect()
		NAStuff.espTriggers["__propertyesp"] = nil
	end
	NAmanage.PartESP_StopSweep("__propertyesp_sweep")
	NAmanage.ESP_CancelScanToken("__propertyesp_scan")
end

NAmanage.PropertyESP_MakeKey = function(propertyName, valueText, className)
	return NAmanage.PropertyESP_NormalizeText(propertyName).."="..NAmanage.PropertyESP_NormalizeText(valueText).."@"..NAmanage.PropertyESP_NormalizeText(className)
end

NAmanage.PropertyESP_Enable = function(propertyName, valueText, className, label, color, silent)
	propertyName = tostring(propertyName or "")
	valueText = tostring(valueText or "")
	className = tostring(className or "")
	propertyName = GSub(GSub(propertyName, "^%s+", ""), "%s+$", "")
	valueText = GSub(GSub(valueText, "^%s+", ""), "%s+$", "")
	className = GSub(GSub(className, "^%s+", ""), "%s+$", "")
	if propertyName == "" or valueText == "" then
		DoNotif("Usage: propertyesp <Property> <Value> [class:ClassName]", 3)
		return false
	end

	local _, _, _, objectMaps, queries = NAmanage.PropertyESP_EnsureState()
	const key = NAmanage.PropertyESP_MakeKey(propertyName, valueText, className)
	local record = queries[key]
	if type(record) ~= "table" then
		record = {
			key = key;
			matches = NAmanage.ensureWeakTable(nil, "k");
		}
		queries[key] = record
		objectMaps[key] = record.matches
	end
	record.propertyName = propertyName
	record.valueText = valueText
	record.className = className
	record.label = tostring(label or (propertyName.." = "..valueText))
	record.color = color
	record.propertyFound = false
	record.foundMatches = 0

	NAmanage.PropertyESP_StartWatchers()
	const scanKey = "__propertyesp_scan_"..key
	const scanToken = NAmanage.ESP_StartScanToken(scanKey)
	record.scanToken = scanToken
	SpawnCall(function()
		NAmanage.ForEachWorkspaceYield(function(obj)
			if scanToken and scanToken.cancelled then
				return
			end
			NAmanage.PropertyESP_UpdateObject(obj, record)
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = scanToken,
		})
		if record.scanToken == scanToken then
			record.scanToken = nil
		end
		if NAStuff.espScanTokens and NAStuff.espScanTokens[scanKey] == scanToken then
			NAStuff.espScanTokens[scanKey] = nil
		end
		if silent ~= true and not (scanToken and scanToken.cancelled) then
			if record.propertyFound ~= true then
				DoNotif("Property not found: "..propertyName, 3)
			elseif (tonumber(record.foundMatches) or 0) <= 0 then
				DoNotif("No property ESP matches for "..record.label..".", 2)
			else
				DoNotif("Property ESP enabled: "..record.label, 2)
			end
		end
	end)
	return true
end

NAmanage.PropertyESP_Disable = function(propertyName, valueText)
	NAmanage.PropertyESP_EnsureState()
	const queries = NAStuff.propertyESPQueries
	local removed = 0
	const propFilter = NAmanage.PropertyESP_NormalizeText(propertyName)
	const valueFilter = NAmanage.PropertyESP_NormalizeText(valueText)
	const keys = {}
	for key, record in queries do
		const propOk = propFilter == "" or NAmanage.PropertyESP_NormalizeText(record.propertyName) == propFilter
		const valueOk = valueFilter == "" or valueFilter == "all" or NAmanage.PropertyESP_NormalizeText(record.valueText) == valueFilter
		if propOk and valueOk then
			keys[#keys + 1] = key
		end
	end
	for i = 1, #keys do
		const key = keys[i]
		const record = queries[key]
		if type(record) == "table" then
			if record.scanToken then
				NAmanage.CancelTokenCancel(record.scanToken)
				record.scanToken = nil
			end
			NAmanage.ESP_CancelScanToken("__propertyesp_scan_"..key)
			const objects = {}
			if type(record.matches) == "table" then
				for obj, _ in record.matches do
					objects[#objects + 1] = obj
				end
			end
			for n = 1, #objects do
				NAmanage.PropertyESP_RemoveTarget(record, objects[n])
			end
			if type(NAStuff.propertyESPObjectMaps) == "table" then
				NAStuff.propertyESPObjectMaps[key] = nil
			end
			queries[key] = nil
			removed += 1
		end
	end
	NAmanage.PropertyESP_StopWatchersIfIdle()
	return removed
end

NAmanage.PropertyESP_ParseArgs = function(...)
	local rawInput = Concat({...}, " ")
	rawInput = GSub(GSub(rawInput, "^%s+", ""), "%s+$", "")
	if rawInput == "" then
		return nil, nil, nil
	end
	local propertyName, valueText, className
	const eq = Find(rawInput, "=", 1, true)
	if eq then
		propertyName = Sub(rawInput, 1, eq - 1)
		valueText = Sub(rawInput, eq + 1)
	else
		local firstWord, restText = Match(rawInput, "^(%S+)%s+(.+)$")
		if firstWord and restText then
			propertyName = firstWord
			valueText = restText
		else
			const args = {...}
			propertyName = tostring(args[1] or "")
			const values = {}
			for i = 2, #args do
				values[#values + 1] = tostring(args[i] or "")
			end
			valueText = Concat(values, " ")
		end
	end
	const classFromValue = Match(valueText, "%s+[Cc][Ll][Aa][Ss][Ss]:([%w_]+)%s*$") or Match(valueText, "%s+[Ii][Ss][Aa]:([%w_]+)%s*$")
	if classFromValue then
		className = classFromValue
		valueText = GSub(valueText, "%s+[Cc][Ll][Aa][Ss][Ss]:[%w_]+%s*$", "")
		valueText = GSub(valueText, "%s+[Ii][Ss][Aa]:[%w_]+%s*$", "")
	else
		className = ""
	end
	propertyName = GSub(GSub(tostring(propertyName or ""), "^%s+", ""), "%s+$", "")
	valueText = GSub(GSub(tostring(valueText or ""), "^%s+", ""), "%s+$", "")
	return propertyName, valueText, className
end

NAmanage.PropertyESP_CompactPartShapeText = function(value)
	return GSub(GSub(NAmanage.PropertyESP_NormalizeText(value), "[%s_%-]+", ""), "part$", "")
end

NAmanage.PropertyESP_GetPartShapeItems = function()
	const items = {}
	local ok, enumItems = pcall(function()
		return Enum.PartType:GetEnumItems()
	end)
	if ok and type(enumItems) == "table" then
		for _, enumItem in enumItems do
			if typeof(enumItem) == "EnumItem" then
				Insert(items, enumItem)
			end
		end
	end
	return items
end

NAmanage.PropertyESP_PartShapeAlias = function(compact)
	const map = {
		sphere = "Ball";
		spherical = "Ball";
		cube = "Block";
		brick = "Block";
		box = "Block";
		block = "Block";
		ball = "Ball";
		cylinder = "Cylinder";
		wedge = "Wedge";
		corner = "CornerWedge";
		cornerwedge = "CornerWedge";
	}
	return map[compact]
end

NAmanage.PropertyESP_TextDistance = function(a, b)
	a = tostring(a or "")
	b = tostring(b or "")
	const la, lb = #a, #b
	if la == 0 then return lb end
	if lb == 0 then return la end
	local prev = {}
	local curr = {}
	for j = 0, lb do
		prev[j] = j
	end
	for i = 1, la do
		curr[0] = i
		const ca = Sub(a, i, i)
		for j = 1, lb do
			const cost = ca == Sub(b, j, j) and 0 or 1
			const deletion = prev[j] + 1
			const insertion = curr[j - 1] + 1
			const substitution = prev[j - 1] + cost
			curr[j] = math.min(deletion, insertion, substitution)
		end
		prev, curr = curr, prev
	end
	return prev[lb]
end

NAmanage.PropertyESP_ResolvePartShape = function(value)
	const compact = NAmanage.PropertyESP_CompactPartShapeText(value)
	if compact == "" then
		return nil
	end
	const aliased = NAmanage.PropertyESP_PartShapeAlias(compact)
	if aliased then
		return aliased
	end
	const items = NAmanage.PropertyESP_GetPartShapeItems()
	for _, enumItem in items do
		const name = tostring(enumItem.Name or "")
		if NAmanage.PropertyESP_CompactPartShapeText(name) == compact then
			return name
		end
		if tostring(enumItem.Value or "") == compact then
			return name
		end
	end
	for _, enumItem in items do
		const name = tostring(enumItem.Name or "")
		const lowerName = NAmanage.PropertyESP_CompactPartShapeText(name)
		if Sub(lowerName, 1, #compact) == compact then
			return name
		end
	end
	for _, enumItem in items do
		const name = tostring(enumItem.Name or "")
		const lowerName = NAmanage.PropertyESP_CompactPartShapeText(name)
		if Find(lowerName, compact, 1, true) then
			return name
		end
	end
	local bestName, bestScore = nil, math.huge
	for _, enumItem in items do
		const name = tostring(enumItem.Name or "")
		const lowerName = NAmanage.PropertyESP_CompactPartShapeText(name)
		const score = NAmanage.PropertyESP_TextDistance(compact, lowerName)
		if score < bestScore then
			bestName, bestScore = name, score
		end
	end
	if bestName and bestScore <= math.max(2, math.floor(#compact * 0.45)) then
		return bestName
	end
	return nil
end

NAmanage.PropertyESP_NormalizePartShape = NAmanage.PropertyESP_ResolvePartShape

NAmanage.PropertyESP_EnableShape = function(shapeName)
	shapeName = NAmanage.PropertyESP_ResolvePartShape(shapeName)
	if not shapeName then
		return false
	end
	NAStuff.ESP_LastShapeESP = shapeName
	return NAmanage.PropertyESP_Enable("Shape", shapeName, "Part", "Shape = "..shapeName, function()
		return NAmanage.GetPartESPColor("ESP_PartColor_Property", Color3.fromRGB(190, 120, 255))
	end)
end

NAmanage.PropertyESP_OpenPartShapePicker = function()
	const buttons = {}
	for _, partType in NAmanage.PropertyESP_GetPartShapeItems() do
		const shapeName = tostring(partType.Name or "")
		if shapeName ~= "" then
			Insert(buttons, {
				Text = shapeName,
				Callback = function()
					NAmanage.PropertyESP_EnableShape(shapeName)
				end
			})
		end
	end
	if #buttons <= 0 then
		DoNotif("PartType enum list is unavailable.", 3)
		return
	end
	Window({
		Title = "Shape ESP Options",
		Buttons = buttons
	})
end

cmd.add({"propertyesp", "propesp", "espproperty", "propertyfinder", "findproperty"}, {"propertyesp <Property> <Value> [class:ClassName]", "ESP instances with a matching readable property value"}, function(...)
	local propertyName, valueText, className = NAmanage.PropertyESP_ParseArgs(...)
	if not propertyName or propertyName == "" or not valueText or valueText == "" then
		DoNotif("Usage: propertyesp Shape Block or propertyesp Shape=Block", 3)
		return
	end
	NAStuff.ESP_LastPropertyESP = propertyName.." "..valueText
	if className and className ~= "" then
		NAStuff.ESP_LastPropertyESP = NAStuff.ESP_LastPropertyESP.." class:"..className
	end
	NAmanage.PropertyESP_Enable(propertyName, valueText, className, propertyName.." = "..valueText, function()
		return NAmanage.GetPartESPColor("ESP_PartColor_Property", Color3.fromRGB(190, 120, 255))
	end)
end, true)

cmd.add({"unpropertyesp", "unpropesp", "unespproperty", "unpropertyfinder", "unfindproperty"}, {"unpropertyesp [Property] [Value|All]", "Disable property ESP entries"}, function(...)
	const rawInput = GSub(GSub(Concat({...}, " "), "^%s+", ""), "%s+$", "")
	local removed = 0
	if rawInput == "" or NAmanage.PropertyESP_NormalizeText(rawInput) == "all" then
		removed = NAmanage.PropertyESP_Disable()
	else
		local propertyName, valueText = NAmanage.PropertyESP_ParseArgs(...)
		removed = NAmanage.PropertyESP_Disable(propertyName, valueText)
	end
	if removed > 0 then
		DoNotif("Disabled "..tostring(removed).." property ESP entr"..(removed == 1 and "y" or "ies")..".", 2)
	else
		DoNotif("No matching property ESP entries are active.", 2)
	end
end, true)

cmd.add({"shapeesp", "shapesp", "partshapeesp", "shapefinder", "shapefinderesp"}, {"shapeesp [Block|Ball|Cylinder|Wedge|CornerWedge]", "ESP Part instances with the selected Shape"}, function(...)
	const rawShape = GSub(GSub(Concat({...}, " "), "^%s+", ""), "%s+$", "")
	if rawShape == "" then
		NAmanage.PropertyESP_OpenPartShapePicker()
		return
	end
	const shapeName = NAmanage.PropertyESP_ResolvePartShape(rawShape)
	if not shapeName then
		DoNotif("No matching part shape for: "..rawShape, 3)
		return
	end
	NAmanage.PropertyESP_EnableShape(shapeName)
end, true)

cmd.add({"unshapeesp", "unshapesp", "unpartshapeesp", "unshapefinder", "unshapefinderesp"}, {"unshapeesp [shape|All]", "Disable Shape ESP entries"}, function(...)
	const rawShape = GSub(GSub(Concat({...}, " "), "^%s+", ""), "%s+$", "")
	local removed
	if rawShape == "" or NAmanage.PropertyESP_NormalizeText(rawShape) == "all" then
		removed = NAmanage.PropertyESP_Disable("Shape")
	else
		const shapeName = NAmanage.PropertyESP_NormalizePartShape(rawShape)
		if not shapeName then
			DoNotif("Usage: unshapeesp [Block|Ball|Cylinder|Wedge|CornerWedge|All]", 3)
			return
		end
		removed = NAmanage.PropertyESP_Disable("Shape", shapeName)
	end
	if removed and removed > 0 then
		DoNotif("Disabled Shape ESP.", 2)
	else
		DoNotif("Shape ESP is not active.", 2)
	end
end, true)

cmd.add({"esplocator","locator","trackesp"},{"esplocator",""},function()
	NAmanage.ESP_SetLocatorEnabled(true)
end)

cmd.add({"unesplocator","unlocator","untrackesp"},{"unesplocator",""},function()
	NAmanage.ESP_SetLocatorEnabled(false)
end)

originalIO.folderESPMode=function()
	return (Lower(tostring(NAStuff.ESP_FolderMode or "parts")) == "models") and "models" or "parts"
end

originalIO.modelESPMode=function()
	return (Lower(tostring(NAStuff.ESP_ModelMode or "parts")) == "models") and "models" or "parts"
end

originalIO.espSortNameMatches=function(matches, needle)
	table.sort(matches, function(a, b)
		const la, lb = Lower(a.Name), Lower(b.Name)
		const pa = Find(la, needle, 1, true) or math.huge
		const pb = Find(lb, needle, 1, true) or math.huge
		if pa == pb then
			if #la == #lb then
				return la < lb
			end
			return #la < #lb
		end
		return pa < pb
	end)
end

originalIO.espDisplayName=function(instance)
	if typeof(instance) ~= "Instance" then
		return tostring(instance)
	end
	local ok, fullName = pcall(function()
		return instance:GetFullName()
	end)
	if ok and type(fullName) == "string" and fullName ~= "" then
		return fullName
	end
	return instance.Name
end

originalIO.espCollectNameMatches=function(rawInput, searchToken, filterFn)
	const loweredInput = Lower(rawInput)
	const matches = {}
	local exactMatch
	NAmanage.ForEachWorkspaceYield(function(obj)
		if searchToken.cancelled or exactMatch then
			return
		end
		if filterFn(obj) then
			const lowered = Lower(obj.Name)
			if lowered == loweredInput then
				exactMatch = obj
			elseif Find(lowered, loweredInput, 1, true) then
				Insert(matches, obj)
			end
		end
	end, {
		yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
		delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
		cancelToken = searchToken,
	})
	return exactMatch, matches
end

NAmanage.FolderESP_Enable = function(folder)
	if typeof(folder) ~= "Instance" or not folder:IsA("Folder") then
		return
	end

	if not NAStuff.folderESPMembers then NAStuff.folderESPMembers = {} end
	if not NAStuff.folderESPMemberMaps then NAStuff.folderESPMemberMaps = {} end
	if not NAStuff.folderESPKeys then NAStuff.folderESPKeys = {} end
	if not NAStuff.folderESPScanTokens then NAStuff.folderESPScanTokens = {} end
	if not NAStuff.folderESPModes then NAStuff.folderESPModes = {} end

	const mode = originalIO.folderESPMode()
	const function currentColor()
		return NAmanage.GetPartESPColor("ESP_PartColor_Folder", Color3.fromRGB(255,220,0))
	end

	const activeKey = NAStuff.folderESPKeys[folder]
	const lastMode = NAStuff.folderESPModes[folder]
	const isActive = activeKey and NAlib.isConnected(activeKey)
	const existingList = NAStuff.folderESPMembers[folder]
	if isActive and lastMode == mode and type(existingList) == "table" then
		return
	end

	const function topModelFor(instance, rootFolder)
		if not instance or not rootFolder then
			return nil
		end
		local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model")
		while model and model.Parent and model.Parent:IsA("Model") and model.Parent:IsDescendantOf(rootFolder) do
			model = model.Parent
		end
		if model and model:IsDescendantOf(rootFolder) then
			return model
		end
		return nil
	end

	const function modelHasBasePart(model)
		return model and model:FindFirstChildWhichIsA("BasePart", true)
	end

	const function addTarget(list, map, target)
		if not target or not target.Parent then
			return
		end
		if NAmanage.ESP_ListAdd(list, map, target) then
			NAmanage.PartESP_QueueCreate(target, currentColor(), NAStuff.ESP_PartTransparency or 0.45, function(p)
				return map[p] ~= nil
			end)
		end
	end

	const function removeTarget(list, map, target)
		if not target then
			return
		end
		if NAmanage.ESP_ListRemove(list, map, target) then
			NAmanage.PartESP_QueueRemove(target)
			NAmanage.RemoveEspFromPart(target)
		end
	end

	const function handleDesc(rootFolder, list, map, desc)
		if mode == "models" then
			if desc:IsA("Model") then
				const top = topModelFor(desc, rootFolder)
				if top == desc and modelHasBasePart(top) then
					addTarget(list, map, top)
				end
			elseif desc:IsA("BasePart") then
				const top = topModelFor(desc, rootFolder)
				if top and modelHasBasePart(top) then
					addTarget(list, map, top)
				else
					addTarget(list, map, desc)
				end
			end
		elseif desc:IsA("BasePart") then
			addTarget(list, map, desc)
		end
	end

	const function rescanFolder(rootFolder, list, map, token)
		NAmanage.ForEachDescendantYield(rootFolder, function(desc)
			if token and token.cancelled then
				return
			end
			handleDesc(rootFolder, list, map, desc)
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = token,
		})
	end

	local list = NAStuff.folderESPMembers[folder]
	if not list then
		list = {}
	end
	local map = NAStuff.folderESPMemberMaps[folder]
	if type(map) ~= "table" then
		map = {}
	end
	for i = #list, 1, -1 do
		NAmanage.RemoveEspFromPart(list[i])
		list[i] = nil
	end
	table.clear(map)
	NAStuff.folderESPMembers[folder] = list
	NAStuff.folderESPMemberMaps[folder] = map
	NAStuff.folderESPModes[folder] = mode

	local key = NAStuff.folderESPKeys[folder]
	if not key then
		key = "esp_folder_"..tostring(folder)
		NAStuff.folderESPKeys[folder] = key
	end

	if NAlib.isConnected(key) then
		NAlib.disconnect(key)
	end

	const prevToken = NAStuff.folderESPScanTokens[folder]
	if prevToken then
		NAmanage.CancelTokenCancel(prevToken)
	end
	const scanToken = NAmanage.NewCancelToken()
	NAStuff.folderESPScanTokens[folder] = scanToken
	SpawnCall(function()
		rescanFolder(folder, list, map, scanToken)
		if NAStuff.folderESPScanTokens and NAStuff.folderESPScanTokens[folder] == scanToken then
			NAStuff.folderESPScanTokens[folder] = nil
		end
	end)

	const function onAdded(obj)
		handleDesc(folder, list, map, obj)
	end

	const function onRemoving(obj)
		if mode == "models" then
			if obj:IsA("Model") then
				removeTarget(list, map, obj)
			elseif obj:IsA("BasePart") then
				const top = topModelFor(obj, folder)
				if top then
					Defer(function()
						if not modelHasBasePart(top) then
							removeTarget(list, map, top)
						end
					end)
				end
				removeTarget(list, map, obj)
			end
		elseif obj:IsA("BasePart") then
			removeTarget(list, map, obj)
		end
	end

	NAlib.connect(key, NAmanage.descAdd(folder, onAdded))
	NAlib.connect(key, NAmanage.descRem(folder, onRemoving))
end

NAmanage.FolderESP_Disable = function(folder)
	if typeof(folder) ~= "Instance" then
		return false
	end

	local removed = false
	const members = NAStuff.folderESPMembers
	const keysCache = NAStuff.folderESPKeys
	const mapsCache = NAStuff.folderESPMemberMaps
	const scanTokens = NAStuff.folderESPScanTokens
	const modeCache = NAStuff.folderESPModes

	if type(keysCache) == "table" then
		const conn = keysCache[folder]
		if conn then
			NAlib.disconnect(conn)
			keysCache[folder] = nil
			removed = true
		end
	end

	if type(scanTokens) == "table" then
		const token = scanTokens[folder]
		if token then
			NAmanage.CancelTokenCancel(token)
			scanTokens[folder] = nil
		end
	end

	if type(members) == "table" then
		const list = members[folder]
		if type(list) == "table" then
			for i = #list, 1, -1 do
				const part = list[i]
				NAmanage.PartESP_QueueRemove(part)
				NAmanage.RemoveEspFromPart(part)
				list[i] = nil
				removed = true
			end
			members[folder] = nil
		end
	end

	if type(mapsCache) == "table" then
		const map = mapsCache[folder]
		if type(map) == "table" then
			table.clear(map)
		end
		mapsCache[folder] = nil
	end

	if type(modeCache) == "table" then
		modeCache[folder] = nil
	end

	return removed
end

NAmanage.FolderESP_RefreshActive = function()
	const members = NAStuff.folderESPMembers
	if type(members) ~= "table" then
		return
	end
	const tracked = {}
	for folder, _ in members do
		if typeof(folder) == "Instance" and folder:IsA("Folder") then
			tracked[#tracked + 1] = folder
		else
			members[folder] = nil
		end
	end
	for _, folder in tracked do
		NAmanage.FolderESP_Disable(folder)
		NAmanage.FolderESP_Enable(folder)
	end
end

NAmanage.ModelESP_Enable = function(model)
	if typeof(model) ~= "Instance" or not model:IsA("Model") then
		return
	end
	if not model.Parent or not model:FindFirstChildWhichIsA("BasePart", true) then
		DoNotif("Model ESP needs a model with a BasePart: "..originalIO.espDisplayName(model), 3)
		return
	end
	if not NAStuff.modelESPModels then NAStuff.modelESPModels = {} end
	if not NAStuff.modelESPMap then NAStuff.modelESPMap = {} end
	if not NAStuff.modelESPMembers then NAStuff.modelESPMembers = {} end
	if not NAStuff.modelESPMemberMaps then NAStuff.modelESPMemberMaps = {} end
	if not NAStuff.modelESPKeys then NAStuff.modelESPKeys = {} end
	if not NAStuff.modelESPScanTokens then NAStuff.modelESPScanTokens = {} end
	if not NAStuff.modelESPModes then NAStuff.modelESPModes = {} end

	NAmanage.ESP_ListAdd(NAStuff.modelESPModels, NAStuff.modelESPMap, model)

	const mode = originalIO.modelESPMode()
	const function currentColor()
		return NAmanage.GetPartESPColor("ESP_PartColor_Model", Color3.fromRGB(0, 200, 255))
	end

	const activeKey = NAStuff.modelESPKeys[model]
	const lastMode = NAStuff.modelESPModes[model]
	const isActive = activeKey and NAlib.isConnected(activeKey)
	const existingList = NAStuff.modelESPMembers[model]
	if isActive and lastMode == mode and type(existingList) == "table" then
		return
	end

	const function addTarget(list, map, target)
		if not target or not target.Parent then
			return
		end
		if NAmanage.ESP_ListAdd(list, map, target) then
			NAmanage.PartESP_QueueCreate(target, currentColor(), NAStuff.ESP_PartTransparency or 0.45, function(entry)
				return map[entry] ~= nil
			end)
		end
	end

	const function removeTarget(list, map, target)
		if not target then
			return
		end
		if NAmanage.ESP_ListRemove(list, map, target) then
			NAmanage.PartESP_QueueRemove(target)
			NAmanage.RemoveEspFromPart(target)
		end
	end

	const function rescanModel(rootModel, list, map, token)
		if mode == "models" then
			if rootModel.Parent and rootModel:FindFirstChildWhichIsA("BasePart", true) then
				addTarget(list, map, rootModel)
			end
			return
		end
		NAmanage.ForEachDescendantYield(rootModel, function(desc)
			if token and token.cancelled then
				return
			end
			if desc:IsA("BasePart") then
				addTarget(list, map, desc)
			end
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = token,
		})
	end

	local list = NAStuff.modelESPMembers[model]
	if not list then
		list = {}
	end
	local map = NAStuff.modelESPMemberMaps[model]
	if type(map) ~= "table" then
		map = {}
	end
	for i = #list, 1, -1 do
		NAmanage.RemoveEspFromPart(list[i])
		list[i] = nil
	end
	table.clear(map)
	NAStuff.modelESPMembers[model] = list
	NAStuff.modelESPMemberMaps[model] = map
	NAStuff.modelESPModes[model] = mode

	local key = NAStuff.modelESPKeys[model]
	if not key then
		key = "esp_model_"..tostring(model)
		NAStuff.modelESPKeys[model] = key
	end

	if NAlib.isConnected(key) then
		NAlib.disconnect(key)
	end

	const prevToken = NAStuff.modelESPScanTokens[model]
	if prevToken then
		NAmanage.CancelTokenCancel(prevToken)
	end
	const scanToken = NAmanage.NewCancelToken()
	NAStuff.modelESPScanTokens[model] = scanToken
	SpawnCall(function()
		rescanModel(model, list, map, scanToken)
		if NAStuff.modelESPScanTokens and NAStuff.modelESPScanTokens[model] == scanToken then
			NAStuff.modelESPScanTokens[model] = nil
		end
	end)

	const function onAdded(obj)
		if mode == "models" then
			if obj:IsA("BasePart") then
				addTarget(list, map, model)
			end
		elseif obj:IsA("BasePart") then
			addTarget(list, map, obj)
		end
	end

	const function onRemoving(obj)
		if mode == "models" then
			if obj:IsA("BasePart") then
				Defer(function()
					if not (model and model.Parent) then
						return
					end
					if not model:FindFirstChildWhichIsA("BasePart", true) then
						removeTarget(list, map, model)
					end
				end)
			end
		elseif obj:IsA("BasePart") then
			removeTarget(list, map, obj)
		end
	end

	NAlib.connect(key, NAmanage.descAdd(model, onAdded))
	NAlib.connect(key, NAmanage.descRem(model, onRemoving))
	NAlib.connect(key, model.AncestryChanged:Connect(function(_, parentNow)
		if not parentNow then
			NAmanage.ModelESP_Disable(model)
		end
	end))
end

NAmanage.ModelESP_Disable = function(model)
	if typeof(model) ~= "Instance" then
		return false
	end

	local removed = false
	const models = NAStuff.modelESPModels
	const modelMap = NAStuff.modelESPMap
	const memberLists = NAStuff.modelESPMembers
	const memberMaps = NAStuff.modelESPMemberMaps
	const keys = NAStuff.modelESPKeys
	const scanTokens = NAStuff.modelESPScanTokens
	const modes = NAStuff.modelESPModes

	if type(scanTokens) == "table" then
		const token = scanTokens[model]
		if token then
			NAmanage.CancelTokenCancel(token)
			scanTokens[model] = nil
		end
	end

	if type(keys) == "table" then
		const key = keys[model]
		if key then
			NAlib.disconnect(key)
			keys[model] = nil
		end
	end

	if type(memberLists) == "table" then
		const list = memberLists[model]
		if type(list) == "table" then
			for i = #list, 1, -1 do
				NAmanage.PartESP_QueueRemove(list[i])
				NAmanage.RemoveEspFromPart(list[i])
				list[i] = nil
				removed = true
			end
		end
		memberLists[model] = nil
	end

	if type(memberMaps) == "table" then
		const map = memberMaps[model]
		if type(map) == "table" then
			table.clear(map)
		end
		memberMaps[model] = nil
	end
	if type(modes) == "table" then
		modes[model] = nil
	end

	NAmanage.RemoveEspFromPart(model)
	if type(models) == "table" and type(modelMap) == "table" and NAmanage.ESP_ListRemove(models, modelMap, model) then
		removed = true
	end
	return removed
end

NAmanage.ModelESP_RefreshActive = function()
	const models = NAStuff.modelESPModels
	const map = NAStuff.modelESPMap
	if type(models) ~= "table" or type(map) ~= "table" then
		return
	end
	for i = #models, 1, -1 do
		const model = models[i]
		if typeof(model) ~= "Instance" or not model:IsA("Model") or not model.Parent or not model:FindFirstChildWhichIsA("BasePart", true) then
			NAmanage.ModelESP_Disable(model)
		else
			NAmanage.ModelESP_Disable(model)
			NAmanage.ModelESP_Enable(model)
		end
	end
end

cmd.add({"folderesp","fesp"},{"folderesp {folderName}","Highlights folder contents (parts or models)"},function(...)
	const rawInput = Concat({...}, " ")
	const name = Lower(rawInput)
	if name == "" then
		return
	end
	if NAStuff.folderSearchToken then
		NAmanage.CancelTokenCancel(NAStuff.folderSearchToken)
	end
	const searchToken = NAmanage.NewCancelToken()
	NAStuff.folderSearchToken = searchToken

	SpawnCall(function()
		local exactFolder, matches = originalIO.espCollectNameMatches(rawInput, searchToken, function(obj)
			return obj and obj:IsA("Folder")
		end)

		if searchToken.cancelled then
			return
		end
		if NAStuff.folderSearchToken == searchToken then
			NAStuff.folderSearchToken = nil
		end

		if exactFolder then
			NAmanage.FolderESP_Enable(exactFolder)
			return
		end

		if #matches == 0 then
			DoNotif(Format("No folders found containing '%s'.", rawInput), 3)
			return
		end

		originalIO.espSortNameMatches(matches, name)

		const buttons = {}
		if #matches > 1 then
			Insert(buttons, {
				Text = "All Matches",
				Callback = function()
					for _, folder in matches do
						if folder and folder:IsA("Folder") then
							NAmanage.FolderESP_Enable(folder)
						end
					end
				end
			})
		end
		for _, folder in matches do
			const folderRef = folder
			Insert(buttons, {
				Text = originalIO.espDisplayName(folderRef),
				Callback = function()
					if folderRef and folderRef:IsA("Folder") then
						NAmanage.FolderESP_Enable(folderRef)
					end
				end
			})
		end

		Window({
			Title = "Folder ESP",
			Description = "Select folder(s) to highlight. Toggle multi-select in the header to pick several.",
			Buttons = buttons
		})
	end)
end,true)


cmd.add({"unfolderesp","unfesp"},{"unfolderesp [folderName]","Disables folder ESP for a folder or all"},function(...)
	const members = NAStuff.folderESPMembers
	if type(members) ~= "table" then
		DoNotif("No folder ESP entries are active.", 2)
		return
	end

	const function detachFolder(folder)
		return NAmanage.FolderESP_Disable(folder)
	end

	const function collectTrackedFolders()
		const tracked = {}
		for folder, _ in members do
			if typeof(folder) == "Instance" then
				tracked[#tracked + 1] = folder
			else
				members[folder] = nil
			end
		end
		table.sort(tracked, function(a, b)
			return Lower(a.Name) < Lower(b.Name)
		end)
		return tracked
	end

	const function removeAllFolders()
		const tracked = collectTrackedFolders()
		local removed = 0
		for _, folder in tracked do
			if detachFolder(folder) then
				removed += 1
			end
		end
		if removed > 0 then
			DoNotif(Format("Stopped folder ESP for %d folder(s).", removed), 2)
		else
			DoNotif("No folder ESP entries were active.", 2)
		end
	end

	const trackedFolders = collectTrackedFolders()

	local rawInput = Concat({...}, " ")
	rawInput = (type(rawInput) == "string") and rawInput:gsub("^%s+", ""):gsub("%s+$", "") or ""
	const loweredInput = Lower(rawInput)

	if loweredInput ~= "" then
		if loweredInput == "all" or loweredInput == "*" then
			removeAllFolders()
			return
		end

		local picked = nil
		for _, folder in trackedFolders do
			if Lower(folder.Name) == loweredInput then
				picked = folder
				break
			end
		end

		if not picked then
			for _, folder in trackedFolders do
				if Find(Lower(folder.Name), loweredInput, 1, true) then
					picked = folder
					break
				end
			end
		end

		if picked and detachFolder(picked) then
			DoNotif(Format("Stopped folder ESP for '%s'.", picked.Name), 2)
		else
			DoNotif(Format("No folder ESP entry matching '%s'.", rawInput ~= "" and rawInput or loweredInput), 3)
		end
		return
	end

	if #trackedFolders == 0 then
		DoNotif("No folder ESP entries are active.", 2)
		return
	end

	const buttons = {
		{
			Text = "All",
			Callback = removeAllFolders
		}
	}

	for _, folder in trackedFolders do
		const folderRef = folder
		buttons[#buttons + 1] = {
			Text = folderRef.Name,
			Callback = function()
				if detachFolder(folderRef) then
					DoNotif(Format("Stopped folder ESP for '%s'.", folderRef.Name), 2)
				else
					DoNotif("Folder ESP entry was not active.", 2)
				end
			end
		}
	end

	Window({
		Title = "Folder ESP",
		Description = "Select a folder ESP entry to disable.",
		Buttons = buttons
	})
end,true)


cmd.add({"viewpart", "viewp", "vpart"}, {"viewpart {partName} (viewp, vpart)", "Focuses camera on a part, model, or folder"},function(...)
	const partName = Concat({...}, " "):lower()
	const ws = Services.Workspace
	const camera = ws.CurrentCamera

	for _, obj in NAmanage.QueryDescendants(ws, "Instance") do
		if obj.Name:lower() == partName then
			if obj:IsA("BasePart") then
				camera.CameraSubject = obj
				return
			elseif obj:IsA("Model") or obj:IsA("Folder") then
				for _, child in NAmanage.QueryDescendants(obj, "BasePart") do
					camera.CameraSubject = child
					return
				end
			end
		end
	end

	DebugNotif("No matching part, model, or folder with a BasePart found named '"..partName.."'")
end,true)

cmd.add({"unviewpart", "unviewp"}, {"unviewpart (unviewp)", "Resets the camera to the local humanoid"}, function()
	const camera = Services.Workspace.CurrentCamera
	const humanoid = getHum()
	if humanoid then
		camera.CameraSubject = humanoid
	end
end)

cmd.add({"viewpartfind", "viewpfind", "vpartfind"}, {"viewpartfind {name} (viewpfind, vpartfind)", "Focuses camera on a part, model, or folder with name containing the given text"}, function(...)
	const name = Concat({...}, " "):lower()
	const ws = Services.Workspace
	const cam = ws.CurrentCamera

	for _, obj in NAmanage.QueryDescendants(ws, "Instance") do
		if obj.Name:lower():find(name) then
			if obj:IsA("BasePart") then
				cam.CameraSubject = obj
				return
			elseif obj:IsA("Model") or obj:IsA("Folder") then
				for _, child in NAmanage.QueryDescendants(obj, "BasePart") do
					cam.CameraSubject = child
					return
				end
			end
		end
	end

	DebugNotif("No part, model, or folder containing '"..name.."' with a BasePart found")
end, true)

cmd.add({"unviewpart", "unviewp"}, {"unviewpart (unviewp)", "Resets the camera to the local humanoid"}, function()
	const cam = Services.Workspace.CurrentCamera
	const hum = getHum()
	if hum then
		cam.CameraSubject = hum
	end
end)

cmd.add({"console", "debug"}, {"console (debug)", "Opens developer console"}, function()
	const consoleButtons = {
		{
			Text = "Roblox Console",
			Callback = function()
				__lt.cm("StarterGui", "SetCore", "DevConsoleVisible", true)
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

cmd.add({"oldconsole", "olddebug"}, {"oldconsole", "opens old version of the developer console"}, function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/OldConsole.lua")
end)

cmd.add({"exportconsole", "consoleexport", "conexport"}, {"exportconsole [txt|json] (consoleexport, conexport)", "Exports the current NA Console records with timestamps, duplicate counts, and structured context"}, function(formatName)
	local ok, path, count = NAmanage.NAConsoleExport(formatName or "txt")
	if not ok then
		return DoNotif(tostring(path), 4)
	end
	DoNotif("Exported "..tostring(count or 0).." console entries to "..tostring(path), 3)
end, true)

NAmanage.HB_Defaults=function()
	return {
		size = 10;
		transparency = 0.9;
		color = { R = 0; G = 0; B = 0 };
		material = "Neon";
		noCollide = true;
		massless = true;
	}
end

NAmanage.HB_Coerce=function(opts)
	const base = NAmanage.HB_Defaults()
	if type(opts) ~= "table" then
		return base
	end
	if typeof(opts.color) == "Color3" then
		base.color = { R = opts.color.R; G = opts.color.G; B = opts.color.B }
	elseif type(opts.color) == "table" then
		base.color = {
			R = math.clamp(opts.color.R or opts.color.r or opts.color[1] or base.color.R, 0, 1);
			G = math.clamp(opts.color.G or opts.color.g or opts.color[2] or base.color.G, 0, 1);
			B = math.clamp(opts.color.B or opts.color.b or opts.color[3] or base.color.B, 0, 1);
		}
	end
	base.size = math.clamp(tonumber(opts.size) or base.size, 0.1, 200)
	base.transparency = math.clamp(tonumber(opts.transparency) or base.transparency, 0, 1)
	if opts.material ~= nil then
		base.material = NAmanage.HB_ResolveMaterial(opts.material)
	end
	base.noCollide = opts.noCollide ~= false
	base.massless = opts.massless ~= false
	return base
end

NAmanage.HB_ColorFromOpt=function(opt)
	if typeof(opt) == "Color3" then
		return opt
	end
	if type(opt) == "table" then
		const r = tonumber(opt.R or opt.r or opt[1])
		const g = tonumber(opt.G or opt.g or opt[2])
		const b = tonumber(opt.B or opt.b or opt[3])
		if r and g and b then
			return Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
		end
	end
	return BrickColor.new("Really black").Color
end

NAmanage.HB_ResolveMaterial=function(matName)
	const items = Enum.Material:GetEnumItems()
	const defaultMat = "Neon"
	if matName == nil then return defaultMat end
	const input = tostring(matName)
	if input == "" then return defaultMat end
	const lowerInput = input:lower()

	local bestName = nil
	local bestScore = math.huge

	const function score(name)
		const lname = name:lower()
		if lname == lowerInput then return 0 end
		if lname:sub(1, #lowerInput) == lowerInput then return 1 end
		if lname:find(lowerInput, 1, true) then return 2 end
		return 3
	end

	for _, item in items do
		const s = score(item.Name)
		if s < bestScore or (s == bestScore and #item.Name < #(bestName or item.Name)) then
			bestScore = s
			bestName = item.Name
			if s == 0 then
				break
			end
		end
	end

	return bestName or defaultMat
end

NAStuff.HitboxOptions = NAmanage.HB_Coerce(NAStuff.HitboxOptions or (NAmanage.NASettingsGet and NAmanage.NASettingsGet("hitboxOptions")))

function NAmanage.GetHitboxOpts()
	NAStuff.HitboxOptions = NAmanage.HB_Coerce(NAStuff.HitboxOptions)
	return NAStuff.HitboxOptions
end

function NAmanage.SetHitboxOpt(key, value)
	local opts = NAmanage.HB_Coerce(NAStuff.HitboxOptions)
	opts[key] = value
	opts = NAmanage.HB_Coerce(opts)
	NAStuff.HitboxOptions = opts
	if NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "hitboxOptions", opts)
	end
	if NAmanage.HitboxUpdateActive then
		NAmanage.HitboxUpdateActive(opts)
	end
	return opts
end

function NAmanage.HitboxUpdateActive(newOpts)
	const opts = NAmanage.HB_Coerce(newOpts or NAmanage.GetHitboxOpts())
	const function rescan(D)
		if not (D and D.ps) then return end
		for key,_ in D.ps do
			local ch = nil
			if typeof(key) == "Instance" and key:IsA("Player") then
				ch = getPlrChar(key)
			elseif typeof(key) == "Instance" and key:IsA("Model") then
				ch = key
			end
			if ch and ch.Parent then
				for _,bp in ch:GetChildren() do
					if bp:IsA("BasePart") then
						D.ps[key] = D.ps[key] or {}
						D.ps[key][bp] = true
					end
				end
			end
		end
	end
	const function updateCfg(D)
		if not (D and D.cfg) then return end
		rescan(D)
		D.cfg.sz = Vector3.new(opts.size, opts.size, opts.size)
		D.cfg.tr = opts.transparency
		D.cfg.bc = BrickColor.new(NAmanage.HB_ColorFromOpt(opts.color))
		D.cfg.mat = Enum.Material[NAmanage.HB_ResolveMaterial(opts.material or "Neon")] or Enum.Material.Neon
		D.cfg.noCollide = opts.noCollide ~= false
		D.cfg.massless = opts.massless ~= false
		const function match(bp)
			if not bp then return false end
			if D.cfg.limb == "All" then return true end
			return Lower(bp.Name) == D.cfg.limbL
		end
		for key, set in D.ps or {} do
			for bp,_ in set do
				if bp and bp.Parent and match(bp) then
					D.og[key] = D.og[key] or {}
					if not D.og[key][bp] then
						D.og[key][bp] = {
							Size=bp.Size, Transparency=bp.Transparency, BrickColor=bp.BrickColor,
							Material=bp.Material, CanCollide=bp.CanCollide, Massless=bp.Massless
						}
					end
					if bp.Size ~= D.cfg.sz then bp.Size = D.cfg.sz end
					if bp.Transparency ~= D.cfg.tr then bp.Transparency = D.cfg.tr end
					if bp.BrickColor ~= D.cfg.bc then bp.BrickColor = D.cfg.bc end
					if bp.Material ~= D.cfg.mat then bp.Material = D.cfg.mat end
					if D.cfg.noCollide then
						if bp.CanCollide then bp.CanCollide = false end
					else
						const og = D.og[key][bp]
						if og and bp.CanCollide ~= og.CanCollide then
							bp.CanCollide = og.CanCollide
						end
					end
					if D.cfg.massless then
						if not bp.Massless then bp.Massless = true end
					else
						const og = D.og[key][bp]
						if og and bp.Massless ~= og.Massless then
							bp.Massless = og.Massless
						end
					end
				end
			end
		end
	end
	updateCfg(NAStuff.HB and NAStuff.HB.P)
	updateCfg(NAStuff.HB and NAStuff.HB.N)
end

cmd.add({"hitbox","hbox"}, {"hitbox <player|npc:filter> {size}",""}, function(pArg, sArg)
	NAStuff.HB = NAStuff.HB or {};
	NAStuff.HB.P = NAStuff.HB.P or {
		ps = {},
		og = {},
		ca = {},
		da = {},
		ac = {},
		tc = {},
		addConn = nil,
		remConn = nil,
		run = nil,
		cfg = nil
	};
	NAStuff.HB.N = NAStuff.HB.N or {
		ps = {},
		og = {},
		md = {},
		ac = {},
		wc = nil,
		run = nil,
		cfg = nil
	};
	const targets = getPlr(pArg);
	const hbOpts = NAmanage.GetHitboxOpts();
	const n = tonumber(sArg) or hbOpts.size or 10;
	const argL = Lower(pArg or "");
	const npc = argL == "npc";
	const selectorMode = ({
		all = true,
		others = true,
		nonteam = true,
		noteam = true,
		noteams = true,
		nonteams = true,
		notteam = true,
		enemies = true,
		enemy = true,
		team = true,
		allies = true,
		ally = true,
	})[argL] and argL or nil;
	const glb = selectorMode == "all" or selectorMode == "others";
	const allowEmpty = npc or selectorMode ~= nil;
	if #targets == 0 and (not allowEmpty) then
		DoNotif("No targets found", 2);
		return;
	end;
	const defaultTransparency = math.clamp(tonumber(hbOpts.transparency) or 0.9, 0, 1);
	const defaultColor = NAmanage.HB_ColorFromOpt(hbOpts.color);
	const defaultMaterial = Enum.Material[NAmanage.HB_ResolveMaterial(hbOpts.material or "Neon")] or Enum.Material.Neon;
	const defaultNoCollide = hbOpts.noCollide ~= false;
	const defaultMassless = hbOpts.massless ~= false;
	const function GetChar(t)
		if typeof(t) == "Instance" and t:IsA("Player") then
			return getPlrChar(t);
		elseif typeof(t) == "Instance" and t:IsA("Model") then
			return t;
		end;
	end;
	const partSet = {
		All = true
	};
	if #targets == 0 then
		const defaults = {
			"Head",
			"UpperTorso",
			"LowerTorso",
			"Torso",
			"LeftUpperArm",
			"LeftLowerArm",
			"LeftHand",
			"RightUpperArm",
			"RightLowerArm",
			"RightHand",
			"LeftUpperLeg",
			"LeftLowerLeg",
			"LeftFoot",
			"RightUpperLeg",
			"RightLowerLeg",
			"RightFoot"
		};
		for _, limb in defaults do
			partSet[limb] = true;
		end;
	end;
	for _, t in targets do
		const c = GetChar(t);
		if c then
			for _, p in c:GetChildren() do
				if p:IsA("BasePart") then
					partSet[p.Name] = true;
				end;
			end;
		end;
	end;
	const btns = {};
	for limb, _ in partSet do
		Insert(btns, {
			Text = limb,
			Callback = function()
				const sz = Vector3.new(n, n, n);
				const bc = BrickColor.new(defaultColor);
				const mat = defaultMaterial;
				const limbL = Lower(limb);
				const isAll = limb == "All";
				const function MatchBp(bp)
					if isAll then
						return true;
					end;
					return Lower(bp.Name) == limbL;
				end;
				const function Cache(D, key, bp)
					D.og[key] = D.og[key] or {};
					if not D.og[key][bp] then
						D.og[key][bp] = {
							Size = bp.Size,
							Transparency = bp.Transparency,
							BrickColor = bp.BrickColor,
							Material = bp.Material,
							CanCollide = bp.CanCollide,
							Massless = bp.Massless
						};
					end;
					if not NAmanage.GetAttr(bp, "NAHB_HasOrig") then
						const c = bp.BrickColor.Color;
						NAmanage.SetAttr(bp, "NAHB_HasOrig", true);
						NAmanage.SetAttr(bp, "NAHB_OSizeX", bp.Size.X);
						NAmanage.SetAttr(bp, "NAHB_OSizeY", bp.Size.Y);
						NAmanage.SetAttr(bp, "NAHB_OSizeZ", bp.Size.Z);
						NAmanage.SetAttr(bp, "NAHB_OTransparency", bp.Transparency);
						NAmanage.SetAttr(bp, "NAHB_OColorR", c.R);
						NAmanage.SetAttr(bp, "NAHB_OColorG", c.G);
						NAmanage.SetAttr(bp, "NAHB_OColorB", c.B);
						NAmanage.SetAttr(bp, "NAHB_OMaterial", bp.Material.Name);
						NAmanage.SetAttr(bp, "NAHB_OCanCollide", bp.CanCollide);
						NAmanage.SetAttr(bp, "NAHB_OMassless", bp.Massless);
					end;
				end;
				const function ApplyBp(D, key, bp)
					Cache(D, key, bp);
					const og = D.og[key] and D.og[key][bp] or nil;
					if bp.Size ~= D.cfg.sz then
						bp.Size = D.cfg.sz;
					end;
					if bp.Transparency ~= D.cfg.tr then
						bp.Transparency = D.cfg.tr;
					end;
					if bp.BrickColor ~= D.cfg.bc then
						bp.BrickColor = D.cfg.bc;
					end;
					if bp.Material ~= D.cfg.mat then
						bp.Material = D.cfg.mat;
					end;
					if D.cfg.noCollide then
						if bp.CanCollide then
							bp.CanCollide = false;
						end;
					elseif og and bp.CanCollide ~= og.CanCollide then
						bp.CanCollide = og.CanCollide;
					end;
					if D.cfg.massless then
						if not bp.Massless then
							bp.Massless = true;
						end;
					elseif og and bp.Massless ~= og.Massless then
						bp.Massless = og.Massless;
					end;
				end;
				if npc then
					const D = NAStuff.HB.N;
					if D.run then
						D.run:Disconnect();
						D.run = nil;
					end;
					NAlib.disconnect("hitbox_npc_loop");
					if D.wc then
						D.wc:Disconnect();
						D.wc = nil;
					end;
					for m, c in D.md do
						if c then
							c:Disconnect();
						end;
						D.md[m] = nil;
					end;
					for m, c in D.ac do
						if c then
							c:Disconnect();
						end;
						D.ac[m] = nil;
					end;
					for m, _ in D.ps do
						D.ps[m] = nil;
					end;
					D.cfg = {
						limb = limb,
						limbL = limbL,
						sz = sz,
						bc = bc,
						mat = mat,
						tr = defaultTransparency,
						noCollide = defaultNoCollide,
						massless = defaultMassless
					};
					const function Track(m, bp)
						if not (bp and bp.Parent) then
							return;
						end;
						if not bp:IsA("BasePart") then
							return;
						end;
						if not MatchBp(bp) then
							return;
						end;
						D.ps[m] = D.ps[m] or {};
						D.ps[m][bp] = true;
						ApplyBp(D, m, bp);
					end;
					const function Scan(m)
						if not (m and m.Parent) then
							return;
						end;
						for _, c in m:GetChildren() do
							if c:IsA("BasePart") then
								Track(m, c);
							end;
						end;
					end;
					const function Setup(m)
						if not (m and m.Parent) then
							return;
						end;
						if D.md[m] then
							D.md[m]:Disconnect();
						end;
						D.md[m] = NAmanage.descAdd(m, function(inst)
							if inst and inst:IsA("BasePart") then
								Track(m, inst);
							end;
						end, function(inst)
							return inst and inst:IsA("BasePart")
						end);
						if D.ac[m] then
							D.ac[m]:Disconnect();
						end;
						D.ac[m] = m.AncestryChanged:Connect(function(_, parent)
							if not D.cfg then
								return;
							end;
							if parent and Services.Workspace and m:IsDescendantOf(Services.Workspace) then
								Defer(function()
									Scan(m);
								end);
							end;
						end);
						Scan(m);
					end;
					const function IsNPC(inst)
						if inst and inst:IsA("Model") and CheckIfNPC(inst) then
							return inst;
						end;
						const m = inst and inst:FindFirstAncestorWhichIsA("Model") or nil;
						if m and CheckIfNPC(m) then
							return m;
						end;
						return nil;
					end;
					for _, t in targets do
						const m = GetChar(t);
						if m then
							Setup(m);
						end;
					end;
					D.wc = NAmanage.wsAdd(function(inst)
						const m = IsNPC(inst);
						if m then
							Defer(function()
								if not D.md[m] then
									Setup(m);
								end;
							end);
						end;
					end);
					local acc = 0;
					local acc2 = 0;
					D.run = NAlib.reconnect("hitbox_npc_loop", Services.RunService.Heartbeat:Connect(function(dt)
						acc += dt;
						acc2 += dt;
						if acc >= 0.12 then
							acc = 0;
							for m, c in D.md do
								if not (m and m.Parent) then
									if c then
										c:Disconnect();
									end;
									D.md[m] = nil;
									if D.ac[m] then
										D.ac[m]:Disconnect();
										D.ac[m] = nil;
									end;
									D.ps[m] = nil;
									D.og[m] = nil;
								end;
							end;
							for m, set in D.ps do
								if not (m and m.Parent) then
									D.ps[m] = nil;
									D.og[m] = nil;
									if D.md[m] then
										D.md[m]:Disconnect();
										D.md[m] = nil;
									end;
									if D.ac[m] then
										D.ac[m]:Disconnect();
										D.ac[m] = nil;
									end;
								else
									for bp, _ in set do
										if not (bp and bp.Parent) then
											set[bp] = nil;
										elseif MatchBp(bp) then
											ApplyBp(D, m, bp);
										end;
									end;
								end;
							end;
						end;
						if acc2 >= 0.35 then
							acc2 = 0;
							for _, ch in Services.Workspace:GetChildren() do
								if ch:IsA("Model") and CheckIfNPC(ch) and (not D.md[ch]) then
									Setup(ch);
								end;
							end;
						end;
					end));
				else
					const D = NAStuff.HB.P;
					if D.run then
						D.run:Disconnect();
						D.run = nil;
					end;
					NAlib.disconnect("hitbox_player_loop");
					if D.addConn then
						D.addConn:Disconnect();
						D.addConn = nil;
					end;
					if D.remConn then
						D.remConn:Disconnect();
						D.remConn = nil;
					end;
					for k, c in D.ca do
						if c then
							c:Disconnect();
						end;
						D.ca[k] = nil;
					end;
					for k, c in D.da do
						if c then
							c:Disconnect();
						end;
						D.da[k] = nil;
					end;
					for k, c in D.ac do
						if c then
							c:Disconnect();
						end;
						D.ac[k] = nil;
					end;
					D.tc = D.tc or {};
					for k, c in D.tc do
						if c then
							c:Disconnect();
						end;
						D.tc[k] = nil;
					end;
					for k, _ in D.ps do
						D.ps[k] = nil;
					end;
					D.cfg = {
						limb = limb,
						limbL = limbL,
						sz = sz,
						bc = bc,
						mat = mat,
						tr = defaultTransparency,
						noCollide = defaultNoCollide,
						massless = defaultMassless
					};
					D.tc = D.tc or {};
					D.selectorMode = selectorMode;
					D.targetSet = {};
					const function ModeAllows(plr)
						if not (typeof(plr) == "Instance" and plr:IsA("Player")) then
							return false;
						end;
						if selectorMode == "all" then
							return true;
						elseif selectorMode == "others" then
							return plr ~= Services.Players.LocalPlayer;
						elseif selectorMode == "nonteam" or selectorMode == "noteam" or selectorMode == "noteams" or selectorMode == "nonteams" or selectorMode == "notteam" or selectorMode == "enemies" or selectorMode == "enemy" then
							return NAmanage.PlayerArgNonTeam(plr);
						elseif selectorMode == "team" or selectorMode == "allies" or selectorMode == "ally" then
							return NAmanage.PlayerArgSameTeam(plr);
						end;
						return D.targetSet[plr] == true;
					end;
					const function Track(k, bp)
						if not (bp and bp.Parent) then
							return;
						end;
						if not bp:IsA("BasePart") then
							return;
						end;
						if not MatchBp(bp) then
							return;
						end;
						D.ps[k] = D.ps[k] or {};
						D.ps[k][bp] = true;
						ApplyBp(D, k, bp);
					end;
					const function Scan(k, ch)
						if not (ch and ch.Parent) then
							return;
						end;
						for _, c in ch:GetChildren() do
							if c:IsA("BasePart") then
								Track(k, c);
							end;
						end;
					end;
					const function SetupChar(k, ch)
						if D.da[k] then
							D.da[k]:Disconnect();
						end;
						D.da[k] = NAmanage.descAdd(ch, function(inst)
							if inst and inst:IsA("BasePart") then
								Track(k, inst);
							end;
						end, function(inst)
							return inst and inst:IsA("BasePart")
						end);
						if D.ac[k] then
							D.ac[k]:Disconnect();
						end;
						D.ac[k] = ch.AncestryChanged:Connect(function(_, parent)
							if not D.cfg then
								return;
							end;
							if parent and Services.Workspace and ch:IsDescendantOf(Services.Workspace) then
								Defer(function()
									const cc = GetChar(k);
									if cc then
										Scan(k, cc);
									end;
								end);
							end;
						end);
						Scan(k, ch);
					end;
					const function SetupKey(k)
						if not (k and typeof(k) == "Instance") then
							return;
						end;
						D.targetSet[k] = true;
						const ch = GetChar(k);
						if ch then
							SetupChar(k, ch);
						end;
						if typeof(k) == "Instance" and k:IsA("Player") and k.CharacterAdded then
							if D.ca[k] then
								D.ca[k]:Disconnect();
							end;
							D.ca[k] = k.CharacterAdded:Connect(function(c)
								Defer(function()
									if c and ModeAllows(k) then
										SetupChar(k, c);
									end;
								end);
							end);
							if D.tc[k] then
								D.tc[k]:Disconnect();
							end;
							D.tc[k] = k:GetPropertyChangedSignal("Team"):Connect(function()
								if ModeAllows(k) then
									const cc = GetChar(k);
									if cc then
										SetupChar(k, cc);
									end;
								end;
							end);
						end;
						Defer(function()
							const cc = GetChar(k);
							if cc and ModeAllows(k) then
								Scan(k, cc);
							end;
						end);
					end;
					for _, t in targets do
						if selectorMode == nil or ModeAllows(t) then
							SetupKey(t);
						end;
					end;
					if selectorMode then
						for _, plr in __lt.cm("Players", "GetPlayers") do
							if ModeAllows(plr) and not D.ca[plr] then
								SetupKey(plr);
							end;
						end;
					end;
					if selectorMode then
						D.addConn = Services.Players.PlayerAdded:Connect(function(plr)
							if ModeAllows(plr) then
								SetupKey(plr);
							end;
						end);
						D.remConn = Services.Players.PlayerRemoving:Connect(function(plr)
							if D.ca[plr] then
								D.ca[plr]:Disconnect();
								D.ca[plr] = nil;
							end;
							if D.da[plr] then
								D.da[plr]:Disconnect();
								D.da[plr] = nil;
							end;
							if D.ac[plr] then
								D.ac[plr]:Disconnect();
								D.ac[plr] = nil;
							end;
							if D.tc and D.tc[plr] then
								D.tc[plr]:Disconnect();
								D.tc[plr] = nil;
							end;
							D.ps[plr] = nil;
							D.og[plr] = nil;
						end);
					end;
					local acc = 0;
					D.run = NAlib.reconnect("hitbox_player_loop", Services.RunService.Heartbeat:Connect(function(dt)
						acc += dt;
						if acc < 0.12 then
							return;
						end;
						acc = 0;
						for k, set in D.ps do
							const ch = GetChar(k);
							if not (ch and ch.Parent) then
								D.ps[k] = nil;
							else
								for bp, _ in set do
									if not (bp and bp.Parent) then
										set[bp] = nil;
									elseif MatchBp(bp) then
										ApplyBp(D, k, bp);
									end;
								end;
							end;
						end;
						if selectorMode then
							for _, plr in __lt.cm("Players", "GetPlayers") do
								if ModeAllows(plr) and not D.ca[plr] then
									SetupKey(plr);
								end;
							end;
						end;
					end));
				end;
			end
		});
	end;
	Window({
		Title = "Hitbox Menu",
		Description = "Choose limb to resize",
		Buttons = btns
	});
end, true);

cmd.add({"unhitbox","unhbox"}, {"unhitbox <player|npc:filter>",""}, function(pArg)
	NAStuff.HB = NAStuff.HB or {}
	NAStuff.HB.P = NAStuff.HB.P or {
		ps = {},
		og = {},
		ca = {},
		da = {},
		ac = {},
		tc = {},
		addConn = nil,
		remConn = nil,
		run = nil,
		cfg = nil
	}
	NAStuff.HB.N = NAStuff.HB.N or {
		ps = {},
		og = {},
		md = {},
		ac = {},
		wc = nil,
		run = nil,
		cfg = nil
	}

	const argL = pArg and Lower(pArg) or ""
	const targets = getPlr(pArg)
	const npc = argL == "npc"
	const glb = argL == "" or argL == "all" or argL == "others"
	const allowEmpty = npc or glb

	if #targets == 0 and not allowEmpty then
		DoNotif("No targets found", 2)
		return
	end

	const function RestorePart(bp, pr)
		if not (bp and bp.Parent) then
			return
		end

		const sx = NAmanage.GetAttr(bp, "NAHB_OSizeX")
		const sy = NAmanage.GetAttr(bp, "NAHB_OSizeY")
		const sz = NAmanage.GetAttr(bp, "NAHB_OSizeZ")
		if sx and sy and sz then
			bp.Size = Vector3.new(sx, sy, sz)
		elseif pr and pr.Size then
			bp.Size = pr.Size
		end

		const tr = NAmanage.GetAttr(bp, "NAHB_OTransparency")
		if tr ~= nil then
			bp.Transparency = tr
		elseif pr and pr.Transparency ~= nil then
			bp.Transparency = pr.Transparency
		end

		const cr = NAmanage.GetAttr(bp, "NAHB_OColorR")
		const cg = NAmanage.GetAttr(bp, "NAHB_OColorG")
		const cb = NAmanage.GetAttr(bp, "NAHB_OColorB")
		if cr and cg and cb then
			bp.BrickColor = BrickColor.new(Color3.new(cr, cg, cb))
		elseif pr and pr.BrickColor then
			bp.BrickColor = pr.BrickColor
		end

		const matName = NAmanage.GetAttr(bp, "NAHB_OMaterial")
		if matName then
			const em = Enum.Material[matName]
			if em then
				bp.Material = em
			end
		elseif pr and pr.Material then
			bp.Material = pr.Material
		end

		const cc = NAmanage.GetAttr(bp, "NAHB_OCanCollide")
		if cc ~= nil then
			bp.CanCollide = cc
		elseif pr and pr.CanCollide ~= nil then
			bp.CanCollide = pr.CanCollide
		end

		const ml = NAmanage.GetAttr(bp, "NAHB_OMassless")
		if ml ~= nil then
			bp.Massless = ml
		elseif pr and pr.Massless ~= nil then
			bp.Massless = pr.Massless
		end

		NAmanage.SetAttr(bp, "NAHB_HasOrig", nil)
		NAmanage.SetAttr(bp, "NAHB_OSizeX", nil)
		NAmanage.SetAttr(bp, "NAHB_OSizeY", nil)
		NAmanage.SetAttr(bp, "NAHB_OSizeZ", nil)
		NAmanage.SetAttr(bp, "NAHB_OTransparency", nil)
		NAmanage.SetAttr(bp, "NAHB_OColorR", nil)
		NAmanage.SetAttr(bp, "NAHB_OColorG", nil)
		NAmanage.SetAttr(bp, "NAHB_OColorB", nil)
		NAmanage.SetAttr(bp, "NAHB_OMaterial", nil)
		NAmanage.SetAttr(bp, "NAHB_OCanCollide", nil)
		NAmanage.SetAttr(bp, "NAHB_OMassless", nil)
	end

	const function RestoreMap(mp)
		for bp, pr in mp do
			RestorePart(bp, pr)
		end
	end

	const function GetChar(t)
		if typeof(t) == "Instance" and t:IsA("Player") then
			return getPlrChar(t)
		elseif typeof(t) == "Instance" and t:IsA("Model") then
			return t
		end
	end

	const function restoreEntryPlayer(D, k)
		const ch = GetChar(k)
		if ch and ch.Parent then
			const mp = D.og[k]
			for _, bp in NAmanage.QueryDescendants(ch, "BasePart") do
				const pr = mp and mp[bp] or nil
				RestorePart(bp, pr)
			end
		elseif D.og[k] then
			RestoreMap(D.og[k])
		end
		D.og[k] = nil
		D.ps[k] = nil
		if D.ca[k] then
			D.ca[k]:Disconnect()
			D.ca[k] = nil
		end
		if D.da[k] then
			D.da[k]:Disconnect()
			D.da[k] = nil
		end
		if D.ac[k] then
			D.ac[k]:Disconnect()
			D.ac[k] = nil
		end
		if type(D.tc) == "table" and D.tc[k] then
			D.tc[k]:Disconnect()
			D.tc[k] = nil
		end
	end

	const function restoreEntryNPC(D, k)
		const ch = GetChar(k)
		if ch and ch.Parent then
			const mp = D.og[k]
			for _, bp in NAmanage.QueryDescendants(ch, "BasePart") do
				const pr = mp and mp[bp] or nil
				RestorePart(bp, pr)
			end
		elseif D.og[k] then
			RestoreMap(D.og[k])
		end
		D.og[k] = nil
		D.ps[k] = nil
	end

	const function cleanupPlayers(D)
		local any = false
		for _ in D.ps do
			any = true
			break
		end
		if any then
			return
		end
		for _, c in D.ca do
			if c then
				c:Disconnect()
			end
		end
		for _, c in D.da do
			if c then
				c:Disconnect()
			end
		end
		for _, c in D.ac do
			if c then
				c:Disconnect()
			end
		end
		if type(D.tc) == "table" then
			for _, c in D.tc do
				if c then
					c:Disconnect()
				end
			end
		end
		D.ca = {}
		D.da = {}
		D.ac = {}
		D.tc = {}
		if D.addConn then
			D.addConn:Disconnect()
			D.addConn = nil
		end
		if D.remConn then
			D.remConn:Disconnect()
			D.remConn = nil
		end
		if D.run then
			D.run:Disconnect()
			D.run = nil
		end
		NAlib.disconnect("hitbox_player_loop")
		D.cfg = nil
	end

	const function cleanupNPC(D)
		local any = false
		for _ in D.ps do
			any = true
			break
		end
		if any then
			return
		end
		for _, c in D.md do
			if c then
				c:Disconnect()
			end
		end
		for _, c in D.ac do
			if c then
				c:Disconnect()
			end
		end
		D.md = {}
		D.ac = {}
		if D.wc then
			D.wc:Disconnect()
			D.wc = nil
		end
		if D.run then
			D.run:Disconnect()
			D.run = nil
		end
		NAlib.disconnect("hitbox_npc_loop")
		D.cfg = nil
	end

	if npc then
		const D = NAStuff.HB.N
		for k in D.og do
			restoreEntryNPC(D, k)
		end
		for _, t in targets do
			restoreEntryNPC(D, t)
		end
		cleanupNPC(D)
		return
	end

	const D = NAStuff.HB.P
	const lp = Services.Players.LocalPlayer

	if glb then
		if argL == "others" then
			for _, plr in __lt.cm("Players", "GetPlayers") do
				if plr ~= lp then
					restoreEntryPlayer(D, plr)
				end
			end
		else
			for _, plr in __lt.cm("Players", "GetPlayers") do
				restoreEntryPlayer(D, plr)
			end
		end
		cleanupPlayers(D)
		return
	end

	for _, t in targets do
		restoreEntryPlayer(D, t)
	end
	cleanupPlayers(D)
end, true)

if type(NAStuff.PST) == "table" and type(NAStuff.PST.conn) == "table" then
	for _, cs in NAStuff.PST.conn do
		if type(cs) == "table" then
			for _, c in cs do
				if c then pcall(function() c:Disconnect() end) end
			end
		elseif cs then
			pcall(function() cs:Disconnect() end)
		end
	end
end

NAlib.disconnect("partsizeExact")
NAlib.disconnect("partsizeFind")
NAlib.disconnect("partsizeWatch")
NAlib.disconnect("partsizeFlush")
NAlib.disconnect("partsizeClean")

NAStuff.PST = {
	orig = {},
	exact = {},
	partial = {},
	exactSet = {},
	partialSet = {},
	sizeE = {},
	sizeP = {},
	conn = {},
	busy = {},
	pend = {},
	queue = {},
	qSet = {},
	qHead = 1,
}

NAmanage.PST_Defaults = function()
	return {
		transparency = 0.5,
		color = { R = 0, G = 0, B = 0 },
		material = "Neon",
		noCollide = true,
		massless = false,
		changeColor = false,
		changeMaterial = false,
	}
end

NAmanage.PST_ColorFromOpt = function(opt)
	if typeof(opt) == "Color3" then
		return opt
	end
	if type(opt) == "table" then
		const r = tonumber(opt.R or opt.r or opt[1])
		const g = tonumber(opt.G or opt.g or opt[2])
		const b = tonumber(opt.B or opt.b or opt[3])
		if r and g and b then
			return Color3.new(math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1))
		end
	end
	return BrickColor.new("Really black").Color
end

NAmanage.PST_ResolveMaterial = function(matName)
	if NAmanage.HB_ResolveMaterial then
		return NAmanage.HB_ResolveMaterial(matName)
	end
	const defaultMat = "Neon"
	if matName == nil then return defaultMat end
	const input = tostring(matName)
	if input == "" then return defaultMat end
	const lowerInput = input:lower()
	local bestName = nil
	local bestScore = math.huge
	const function score(name)
		const lname = name:lower()
		if lname == lowerInput then return 0 end
		if lname:sub(1, #lowerInput) == lowerInput then return 1 end
		if lname:find(lowerInput, 1, true) then return 2 end
		return 3
	end
	for _, item in Enum.Material:GetEnumItems() do
		const s = score(item.Name)
		if s < bestScore or (s == bestScore and #item.Name < #(bestName or item.Name)) then
			bestScore = s
			bestName = item.Name
			if s == 0 then
				break
			end
		end
	end
	return bestName or defaultMat
end

NAmanage.PST_Coerce = function(opts)
	const base = NAmanage.PST_Defaults()
	if type(opts) ~= "table" then
		return base
	end
	base.transparency = math.clamp(tonumber(opts.transparency) or base.transparency, 0, 1)
	if typeof(opts.color) == "Color3" then
		base.color = { R = opts.color.R, G = opts.color.G, B = opts.color.B }
	elseif type(opts.color) == "table" then
		base.color = {
			R = math.clamp(tonumber(opts.color.R or opts.color.r or opts.color[1]) or base.color.R, 0, 1),
			G = math.clamp(tonumber(opts.color.G or opts.color.g or opts.color[2]) or base.color.G, 0, 1),
			B = math.clamp(tonumber(opts.color.B or opts.color.b or opts.color[3]) or base.color.B, 0, 1),
		}
	end
	if opts.material ~= nil then
		base.material = NAmanage.PST_ResolveMaterial(opts.material)
	end
	base.noCollide = opts.noCollide ~= false
	base.massless = opts.massless == true
	base.changeColor = opts.changeColor == true
	base.changeMaterial = opts.changeMaterial == true
	return base
end

NAStuff.PartSizeOptions = NAmanage.PST_Coerce(NAStuff.PartSizeOptions or (NAmanage.NASettingsGet and NAmanage.NASettingsGet("partSizeOptions")))

NAmanage.GetPartSizeOpts = function()
	NAStuff.PartSizeOptions = NAmanage.PST_Coerce(NAStuff.PartSizeOptions)
	return NAStuff.PartSizeOptions
end

NAmanage.SetPartSizeOpt = function(key, value)
	local opts = NAmanage.PST_Coerce(NAStuff.PartSizeOptions)
	opts[key] = value
	opts = NAmanage.PST_Coerce(opts)
	NAStuff.PartSizeOptions = opts
	if NAmanage.NASettingsSet then
		pcall(NAmanage.NASettingsSet, "partSizeOptions", opts)
	end
	if NAmanage.PST_UpdateActive then
		NAmanage.PST_UpdateActive(opts)
	end
	return opts
end

NAmanage.PST_AddStore = function(store, set, p)
	if not (store and set and p) then return end
	if not set[p] then
		set[p] = true
		Insert(store, p)
	end
end

NAmanage.PST_RemoveStore = function(store, set, p)
	if not (store and set and p) then return end
	set[p] = nil
	for i = #store, 1, -1 do
		if store[i] == p then
			table.remove(store, i)
		end
	end
end

NAmanage.cachePart = function(p)
	if not (p and p.Parent) then return end
	if not NAStuff.PST.orig[p] then
		NAStuff.PST.orig[p] = {
			Size = p.Size,
			Transparency = p.Transparency,
			CanCollide = p.CanCollide,
			BrickColor = p.BrickColor,
			Material = p.Material,
			Massless = p.Massless,
		}
	end
end

NAmanage.PST_RestoreRaw = function(p)
	const pr = NAStuff.PST.orig[p]
	if pr and p and p.Parent then
		NAStuff.PST.busy[p] = true
		NACaller(function()
			if pr.Size then p.Size = pr.Size end
			if pr.Transparency ~= nil then p.Transparency = pr.Transparency end
			if pr.CanCollide ~= nil then p.CanCollide = pr.CanCollide end
			if pr.BrickColor then p.BrickColor = pr.BrickColor end
			if pr.Material then p.Material = pr.Material end
			if pr.Massless ~= nil then p.Massless = pr.Massless end
		end)
		NAStuff.PST.busy[p] = nil
	end
	NAStuff.PST.orig[p] = nil
end

NAmanage.PST_Unwatch = function(p)
	const cs = NAStuff.PST.conn[p]
	if type(cs) == "table" then
		for _, c in cs do
			if c then pcall(function() c:Disconnect() end) end
		end
	elseif cs then
		pcall(function() cs:Disconnect() end)
	end
	NAStuff.PST.conn[p] = nil
	NAStuff.PST.busy[p] = nil
	NAStuff.PST.pend[p] = nil
end

NAmanage.PST_RemovePart = function(p, restore)
	NAmanage.PST_RemoveStore(NAStuff.PST.exact, NAStuff.PST.exactSet, p)
	NAmanage.PST_RemoveStore(NAStuff.PST.partial, NAStuff.PST.partialSet, p)
	if restore then
		NAmanage.PST_RestoreRaw(p)
	end
	NAmanage.PST_Unwatch(p)
end

NAmanage.PST_MatchExact = function(p)
	local obj = p
	while obj do
		const sz = NAStuff.PST.sizeE[Lower(obj.Name)]
		if sz then
			return sz
		end
		obj = obj.Parent
	end
end

NAmanage.PST_MatchPartial = function(p)
	local obj = p
	while obj do
		const nm = Lower(obj.Name)
		for term, sz in NAStuff.PST.sizeP do
			if Find(nm, term, 1, true) then
				return sz
			end
		end
		obj = obj.Parent
	end
end

NAmanage.PST_Target = function(p)
	local sz = NAmanage.PST_MatchExact(p)
	if sz then
		return sz, "exact"
	end
	sz = NAmanage.PST_MatchPartial(p)
	if sz then
		return sz, "partial"
	end
end

NAmanage.PST_Apply = function(p, sizeVec)
	if not (p and p.Parent and p:IsA("BasePart")) then return end
	NAmanage.cachePart(p)
	const opts = NAmanage.GetPartSizeOpts()
	const pr = NAStuff.PST.orig[p]
	const bc = BrickColor.new(NAmanage.PST_ColorFromOpt(opts.color))
	const mat = Enum.Material[NAmanage.PST_ResolveMaterial(opts.material or "Neon")] or Enum.Material.Neon
	NAStuff.PST.busy[p] = true
	NACaller(function()
		if p.Size ~= sizeVec then p.Size = sizeVec end
		if p.Transparency ~= opts.transparency then p.Transparency = opts.transparency end
		if opts.noCollide then
			if p.CanCollide then p.CanCollide = false end
		elseif pr and p.CanCollide ~= pr.CanCollide then
			p.CanCollide = pr.CanCollide
		end
		if opts.massless then
			if not p.Massless then p.Massless = true end
		elseif pr and p.Massless ~= pr.Massless then
			p.Massless = pr.Massless
		end
		if opts.changeColor then
			if p.BrickColor ~= bc then p.BrickColor = bc end
		elseif pr and p.BrickColor ~= pr.BrickColor then
			p.BrickColor = pr.BrickColor
		end
		if opts.changeMaterial then
			if p.Material ~= mat then p.Material = mat end
		elseif pr and p.Material ~= pr.Material then
			p.Material = pr.Material
		end
	end)
	NAStuff.PST.busy[p] = nil
end

NAmanage.PST_Refresh = function(p)
	if not (p and p.Parent and p:IsA("BasePart")) then
		NAmanage.PST_RemovePart(p, false)
		return
	end
	local sz, kind = NAmanage.PST_Target(p)
	if not sz then
		NAmanage.PST_RemovePart(p, true)
		return
	end
	if kind == "exact" then
		NAmanage.PST_AddStore(NAStuff.PST.exact, NAStuff.PST.exactSet, p)
	elseif kind == "partial" then
		NAmanage.PST_AddStore(NAStuff.PST.partial, NAStuff.PST.partialSet, p)
	end
	NAmanage.PST_Apply(p, sz)
	NAmanage.PST_Watch(p)
end

NAmanage.PST_Watch = function(p)
	if not (p and p.Parent and p:IsA("BasePart")) then return end
	if NAStuff.PST.conn[p] then return end
	const cs = {}
	cs[1] = p:GetPropertyChangedSignal("Size"):Connect(function()
		if NAStuff.PST.busy[p] or NAStuff.PST.pend[p] then return end
		NAStuff.PST.pend[p] = true
		Defer(function()
			NAStuff.PST.pend[p] = nil
			if not (p and p.Parent) then
				NAmanage.PST_RemovePart(p, false)
				return
			end
			NAmanage.PST_Refresh(p)
		end)
	end)
	cs[2] = p.AncestryChanged:Connect(function(_, parent)
		if parent then return end
		Defer(function()
			if not (p and p.Parent) then
				NAmanage.PST_RemovePart(p, false)
			end
		end)
	end)
	NAStuff.PST.conn[p] = cs
end

NAmanage.resizePart = function(p, sizeVec, store, set)
	if not (p and p.Parent and p:IsA("BasePart")) then return end
	NAmanage.PST_AddStore(store, set, p)
	NAmanage.PST_Apply(p, sizeVec)
	NAmanage.PST_Watch(p)
end

NAmanage.PST_Active = function()
	return next(NAStuff.PST.sizeE) ~= nil or next(NAStuff.PST.sizeP) ~= nil
end

NAmanage.PST_ClearQueue = function()
	if type(NAStuff.PST.queue) == "table" then table.clear(NAStuff.PST.queue) end
	if type(NAStuff.PST.qSet) == "table" then table.clear(NAStuff.PST.qSet) end
	NAStuff.PST.qHead = 1
end

NAmanage.PST_StartFlush = function()
	if NAlib.isConnected("partsizeFlush") then return end
	NAlib.connect("partsizeFlush", Services.RunService.Heartbeat:Connect(function()
		if not NAmanage.PST_Active() then
			NAmanage.PST_ClearQueue()
			NAlib.disconnect("partsizeFlush")
			return
		end
		const q = NAStuff.PST.queue
		if type(q) ~= "table" then
			NAStuff.PST.queue = {}
			NAStuff.PST.qSet = {}
			NAStuff.PST.qHead = 1
			NAlib.disconnect("partsizeFlush")
			return
		end
		local i = tonumber(NAStuff.PST.qHead) or 1
		const total = #q
		if i > total then
			NAmanage.PST_ClearQueue()
			NAlib.disconnect("partsizeFlush")
			return
		end
		local budget = 48
		if NAmanage._evtHubBudget then
			local ok, b = pcall(function()
				return NAmanage._evtHubBudget(48, { ldSc = 0.45, ldDel = 0 })
			end)
			if ok and tonumber(b) then
				budget = math.clamp(math.floor(b), 8, 128)
			end
		end
		local done = 0
		while i <= total and done < budget do
			const p = q[i]
			q[i] = nil
			if type(NAStuff.PST.qSet) == "table" then NAStuff.PST.qSet[p] = nil end
			if p and p.Parent and p:IsA("BasePart") then
				NAmanage.PST_Refresh(p)
			end
			i += 1
			done += 1
		end
		NAStuff.PST.qHead = i
	end))
end

NAmanage.PST_Queue = function(p)
	if not (p and p.Parent and p:IsA("BasePart")) then return end
	if not NAmanage.PST_Active() then return end
	if type(NAStuff.PST.queue) ~= "table" then NAStuff.PST.queue = {} end
	if type(NAStuff.PST.qSet) ~= "table" then NAStuff.PST.qSet = {} end
	if NAStuff.PST.qSet[p] then return end
	NAStuff.PST.qSet[p] = true
	Insert(NAStuff.PST.queue, p)
	NAmanage.PST_StartFlush()
end

NAmanage.PST_EnsureWatch = function()
	if NAlib.isConnected("partsizeWatch") then return end
	NAlib.connect("partsizeWatch", NAmanage.wsSub({
		classAdded = "BasePart",
		added = function(obj)
			NAmanage.PST_Queue(obj)
		end,
	}))
end

NAmanage.PST_UpdateWatch = function()
	if NAmanage.PST_Active() then
		NAmanage.PST_EnsureWatch()
	else
		NAlib.disconnect("partsizeWatch")
		NAlib.disconnect("partsizeFlush")
		NAmanage.PST_ClearQueue()
	end
end

NAmanage.PST_UpdateActive = function(newOpts)
	NAStuff.PartSizeOptions = NAmanage.PST_Coerce(newOpts or NAmanage.GetPartSizeOpts())
	const seen = {}
	for _, p in NAStuff.PST.exact do
		if p and not seen[p] then
			seen[p] = true
			NAmanage.PST_Refresh(p)
		end
	end
	for _, p in NAStuff.PST.partial do
		if p and not seen[p] then
			seen[p] = true
			NAmanage.PST_Refresh(p)
		end
	end
end

NAmanage.PST_ScanAll = function()
	for _, obj in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do
		NAmanage.PST_Queue(obj)
	end
end

cmd.add({"partsize","psize","sizepart"},{"partsize {name} {size}", "Grow a part or model named exactly <name> to the cube size you choose."},function(nameArg, sizeArg)
	const term = Lower(tostring(nameArg or "")):match("^%s*(.-)%s*$") or ""
	local n = tonumber(sizeArg)
	if term == "" then DoNotif("Invalid name", 2) return end
	if not n then DoNotif("Invalid size", 2) return end
	n = math.clamp(n, 0.1, 10000)
	NAStuff.PST.sizeE[term] = Vector3.new(n, n, n)
	NAmanage.PST_ScanAll()
	NAmanage.PST_UpdateWatch()
end, true)

cmd.add({"partsizefind","psizefind","sizefind","partsizef"},{"partsizefind {term} {size}", "Grow every part or model whose name contains <term> to the cube size you choose."},function(termArg, sizeArg)
	const term = Lower(tostring(termArg or "")):match("^%s*(.-)%s*$") or ""
	local n = tonumber(sizeArg)
	if term == "" then DoNotif("Invalid term", 2) return end
	if not n then DoNotif("Invalid size", 2) return end
	n = math.clamp(n, 0.1, 10000)
	NAStuff.PST.sizeP[term] = Vector3.new(n, n, n)
	NAmanage.PST_ScanAll()
	NAmanage.PST_UpdateWatch()
end, true)

cmd.add({"unpartsize","unsizepart","unpsize"},{"unpartsize", "Undo partsize—return those parts back to their original size and collision."},function()
	const parts = NAStuff.PST.exact
	const sizeMap = NAStuff.PST.sizeE

	const terms = {}
	for term, _ in sizeMap do
		Insert(terms, term)
	end

	const function termMatchesPart(term, part)
		local obj = part
		while obj do
			if Lower(obj.Name) == term then
				return true
			end
			obj = obj.Parent
		end
		return false
	end

	const function refreshList(list)
		for _, p in list do
			if p then
				NAmanage.PST_Refresh(p)
			end
		end
		NAmanage.PST_UpdateWatch()
	end

	const function removeAll()
		const list = {}
		for _, p in parts do
			if p then Insert(list, p) end
		end
		table.clear(parts)
		table.clear(NAStuff.PST.exactSet)
		table.clear(sizeMap)
		refreshList(list)
		DoNotif("Cleared all exact-name partsize changes.", 2)
	end

	if #terms == 0 then
		if #parts == 0 then
			DoNotif("No exact-name partsize changes are active.", 2)
		else
			removeAll()
		end
		return
	end

	const function removeByTerm(term)
		const list = {}
		sizeMap[term] = nil
		for i = #parts, 1, -1 do
			const p = parts[i]
			if p and termMatchesPart(term, p) then
				Insert(list, p)
				NAStuff.PST.exactSet[p] = nil
				table.remove(parts, i)
			end
		end
		refreshList(list)
		DoNotif("Reverted partsize for exact name '"..term.."'.", 2)
	end

	const buttons = {}
	Insert(buttons, { Text = "All", Callback = removeAll })
	for _, t in terms do
		Insert(buttons, { Text = t, Callback = function() removeByTerm(t) end })
	end

	Window({
		Title = "Undo Exact Partsize",
		Description = "Select a name to restore original size (future spawns included).",
		Buttons = buttons
	})
end, true)

cmd.add({"unpartsizefind","unsizefind","unpsizefind"},{"unpartsizefind", "Undo partsizefind—return those resized parts back to their original size and collision."},function()
	const parts = NAStuff.PST.partial
	const sizeMap = NAStuff.PST.sizeP

	const terms = {}
	for term, _ in sizeMap do
		Insert(terms, term)
	end

	const function termMatchesPart(term, part)
		local obj = part
		while obj do
			if Find(Lower(obj.Name), term, 1, true) ~= nil then
				return true
			end
			obj = obj.Parent
		end
		return false
	end

	const function refreshList(list)
		for _, p in list do
			if p then
				NAmanage.PST_Refresh(p)
			end
		end
		NAmanage.PST_UpdateWatch()
	end

	const function removeAll()
		const list = {}
		for _, p in parts do
			if p then Insert(list, p) end
		end
		table.clear(parts)
		table.clear(NAStuff.PST.partialSet)
		table.clear(sizeMap)
		refreshList(list)
		DoNotif("Cleared all partial-name partsize changes.", 2)
	end

	if #terms == 0 then
		if #parts == 0 then
			DoNotif("No partial-name partsize changes are active.", 2)
		else
			removeAll()
		end
		return
	end

	const function removeByTerm(term)
		const list = {}
		sizeMap[term] = nil
		for i = #parts, 1, -1 do
			const p = parts[i]
			if p and termMatchesPart(term, p) then
				Insert(list, p)
				NAStuff.PST.partialSet[p] = nil
				table.remove(parts, i)
			end
		end
		refreshList(list)
		DoNotif("Reverted partsizefind for term '"..term.."'.", 2)
	end

	const buttons = {}
	Insert(buttons, { Text = "All", Callback = removeAll })
	for _, t in terms do
		Insert(buttons, { Text = t, Callback = function() removeByTerm(t) end })
	end

	Window({
		Title = "Undo Partial Partsize",
		Description = "Select a term to restore original size (future spawns included).",
		Buttons = buttons
	})
end, true)

cmd.add({"breakcars", "bcars"}, {"breakcars (bcars)", "Breaks any car"}, function()
	NAStuff = NAStuff or {}
	const CONN_KEY = "breakcars"
	if NAStuff._breakcarsEnabled then
		NAStuff._breakcarsEnabled = false
		NAlib.disconnect(CONN_KEY)
		if NAStuff._breakcarsFolder then
			pcall(function() NAStuff._breakcarsFolder:Destroy() end)
		end
		NAStuff._breakcarsFolder = nil
		DoNotif("Breakcars disabled", 2, "BreakCars")
		return
	end
	NAStuff._breakcarsEnabled = true
	NAlib.disconnect(CONN_KEY)
	if NAStuff._breakcarsFolder then
		pcall(function() NAStuff._breakcarsFolder:Destroy() end)
		NAStuff._breakcarsFolder = nil
	end

	DebugNotif("Car breaker loaded, sit on a vehicle and be the driver")

	const Player = Services.Players.LocalPlayer
	const Mouse = NAmanage.GetMouse(Player)

	const Folder = InstanceNew("Folder")
	Folder.Parent = Services.Workspace
	NAStuff._breakcarsFolder = Folder
	NAlib.connect(CONN_KEY, Folder.AncestryChanged:Connect(function(_, parent)
		if not parent then
			NAStuff._breakcarsEnabled = false
			NAStuff._breakcarsFolder = nil
			Defer(function()
				NAlib.disconnect(CONN_KEY)
			end)
		end
	end))

	const Part = InstanceNew("Part")
	Part.Anchored = true
	Part.CanCollide = false
	Part.Transparency = 1
	Part.Size = Vector3.new(1, 1, 1)
	Part.Parent = Folder

	const Attachment1 = InstanceNew("Attachment")
	Attachment1.Parent = Part

	const function getBreakcarsTarget()
		const cf = NAmanage.GetMouseWorldCFrame(Mouse, { Player and Player.Character, Folder }, 2048)
		if cf then
			return cf + Vector3.new(0, 5, 0)
		end
		return CFrame.new(Part.Position)
	end

	local UpdatedPosition = getBreakcarsTarget()

	SpawnCall(function()
		while NAStuff._breakcarsEnabled and Wait() do
			for _, player in __lt.cm("Players", "GetPlayers") do
				if player ~= Player then
					pcall(function() player.MaximumSimulationRadius = 0 end)
					pcall(function() if opt and opt.hiddenprop then opt.hiddenprop(player, "SimulationRadius", 0) end end)
				end
			end
			pcall(function() Player.MaximumSimulationRadius = math.pow(math.huge, math.huge) end)
			pcall(function() if setsimulationradius then setsimulationradius(math.huge) end end)
		end
	end)

	const function applyForceToPart(part)
		if not part:IsA("BasePart") or part.Anchored then return end
		if part.Name == "Handle" then return end
		const parent = part.Parent
		if getPlrHum(parent) or getHead(parent) then return end

		Mouse.TargetFilter = part

		for _, v in part:GetChildren() do
			if v:IsA("BodyAngularVelocity") or v:IsA("BodyForce") or v:IsA("BodyGyro")
				or v:IsA("BodyPosition") or v:IsA("BodyThrust") or v:IsA("BodyVelocity")
				or v:IsA("RocketPropulsion") or v:IsA("Torque") or v:IsA("AlignPosition")
				or v:IsA("Attachment") then
				v:Destroy()
			end
		end

		part.CanCollide = false

		const torque = InstanceNew("Torque")
		torque.Torque = Vector3.new(100000, 100000, 100000)
		torque.Parent = part

		const alignPosition = InstanceNew("AlignPosition")
		alignPosition.MaxForce = math.huge
		alignPosition.MaxVelocity = math.huge
		alignPosition.Responsiveness = 200
		alignPosition.Parent = part

		const attachment2 = InstanceNew("Attachment")
		attachment2.Parent = part

		torque.Attachment0 = attachment2
		alignPosition.Attachment0 = attachment2
		alignPosition.Attachment1 = Attachment1
	end

	for _, descendant in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do
		applyForceToPart(descendant)
	end

	NAlib.connect(CONN_KEY, NAmanage.wsAdd(applyForceToPart))

	NAlib.connect(CONN_KEY, Services.UserInputService.InputBegan:Connect(function(input, isChatting)
		if input.KeyCode == Enum.KeyCode.E and not isChatting then
			UpdatedPosition = getBreakcarsTarget()
		end
	end))

	SpawnCall(function()
		while NAStuff._breakcarsEnabled and Wait() do
			pcall(function()
				Attachment1.WorldCFrame = UpdatedPosition
			end)
		end
		pcall(function()
			if Folder and Folder.Parent then
				Folder:Destroy()
			end
		end)
	end)
end)

cmd.add({"setsimradius", "ssr", "simrad"},{"setsimradius <number>","Set sim radius using available methods. Usage: setsimradius <radius>"},function(...)
	const r = tonumber(...)
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

	const function doINFJUMPY()
		NAlib.disconnect("infjump_jump")

		local debounce = false
		local humanoid = nil

		while not humanoid do Wait(.1) humanoid = getHum() end

		NAlib.connect("infjump_jump", Services.UserInputService.JumpRequest:Connect(function()
			if not debounce and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				debounce = true
				NAmanage.LaunchHumanoid(humanoid)

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
	NAlib.connect("flyjump", Services.UserInputService.JumpRequest:Connect(function()
		const hum = getHum()
		if hum then
			NAmanage.LaunchHumanoid(hum)
		end
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
	originalIO.togXray(true)
end)

cmd.add({"unxray", "xrayoff"}, {"unxray (xrayoff)", "Disables X-ray vision"}, function()
	Wait()
	DebugNotif("X-ray disabled")
	originalIO.togXray(false)
end)

NAmanage.Echolocation = NAmanage.Echolocation or {}

NAmanage.Echolocation.GetState = function()
	local state = NAStuff.EcholocationState
	if type(state) ~= "table" then
		state = {
			enabled = false;
			token = 0;
			pulses = {};
			wavePool = {};
			highlightPool = {};
			targetSlots = NAmanage.ensureWeakKeyTable(nil);
			patchSlots = NAmanage.ensureWeakKeyTable(nil);
			sourceOrigins = NAmanage.ensureWeakKeyTable(nil);
			sourceSoundPulseAt = NAmanage.ensureWeakKeyTable(nil);
			emitterBoundPlayers = NAmanage.ensureWeakKeyTable(nil);
			soundRecords = NAmanage.ensureWeakKeyTable(nil);
			soundList = {};
			soundCursor = 1;
			nextSoundPoll = 0;
			config = {};
			lastStepAt = 0;
			lastDarknessAt = 0;
			wasGrounded = nil;
			airborneAt = 0;
		}
		NAStuff.EcholocationState = state
	end
	state.config = type(state.config) == "table" and state.config or {}
	for key, value in {
		range = 74;
		waveSpeed = 92;
		revealTime = 1.15;
		queryInterval = 0.055;
		maxQueryParts = 220;
		maxRevealPerQuery = 72;
		maxHighlights = 112;
		maxWaves = 8;
		maxActivePulses = 28;
		maxPulsesPerSource = 3;
		maxWaveSlotsPerSource = 1;
		largePartDimension = 36;
		largePartApparentRatio = 0.9;
		surfacePatchMaxSize = 12;
		surfacePatchMinSize = 1.5;
		surfacePatchCameraRatio = 0.22;
		surfacePatchThickness = 0.055;
		movingSourceResetDistance = 5.5;
		stepBaseInterval = 0.56;
		soundPollInterval = 0.05;
		soundPulseCooldown = 0.18;
		soundSourceMergeCooldown = 0.09;
		soundEventDebounce = 0.045;
		soundMinLoudness = 1;
		soundBaseRange = 20;
		soundMaxRange = 120;
		soundChecksPerPoll = 96;
		audioGraphDepth = 10;
		maxPatchSlotsPerPart = 6;
	} do
		if state.config[key] == nil then
			state.config[key] = value
		end
	end
	state.pulses = type(state.pulses) == "table" and state.pulses or {}
	state.wavePool = type(state.wavePool) == "table" and state.wavePool or {}
	state.highlightPool = type(state.highlightPool) == "table" and state.highlightPool or {}
	state.targetSlots = NAmanage.ensureWeakKeyTable(state.targetSlots)
	state.patchSlots = NAmanage.ensureWeakKeyTable(state.patchSlots)
	state.sourceOrigins = NAmanage.ensureWeakKeyTable(state.sourceOrigins)
	state.sourceSoundPulseAt = NAmanage.ensureWeakKeyTable(state.sourceSoundPulseAt)
	state.emitterBoundPlayers = NAmanage.ensureWeakKeyTable(state.emitterBoundPlayers)
	state.soundRecords = NAmanage.ensureWeakKeyTable(state.soundRecords)
	state.soundList = type(state.soundList) == "table" and state.soundList or {}
	state.soundCursor = math.max(1, math.floor(tonumber(state.soundCursor) or 1))
	state.nextSoundPoll = tonumber(state.nextSoundPoll) or 0
	return state
end

NAmanage.Echolocation.SafeSet = function(inst, prop, value)
	if typeof(inst) ~= "Instance" then
		return false
	end
	local ok = pcall(function()
		inst[prop] = value
	end)
	if not ok and NAlib and type(NAlib.setProperty) == "function" then
		ok = pcall(NAlib.setProperty, inst, prop, value)
	end
	return ok
end

NAmanage.Echolocation.SafeGet = function(inst, prop)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	local ok, value = pcall(function()
		return inst[prop]
	end)
	if ok then
		return value
	end
	return nil
end

NAmanage.Echolocation.DisableConflictingLighting = function()
	if type(NAmanage._ensureL) ~= "function" then
		return
	end
	local st = NAmanage._ensureL()
	if type(st) ~= "table" then
		return
	end
	for _, name in { "disableTimeLoops", "disableFB", "disableNB", "disableShader" } do
		if type(st[name]) == "function" then
			pcall(st[name])
		end
	end
	if type(st.disableNF) == "function" then
		pcall(st.disableNF, true)
	end
	if type(st.disableNM) == "function" then
		pcall(st.disableNM)
	end
end

NAmanage.Echolocation.CaptureLighting = function()
	local state = NAmanage.Echolocation.GetState()
	if not Services.Lighting then
		return
	end
	NAmanage.Echolocation.DisableConflictingLighting()
	state.lightingTarget = {
		Brightness = 0;
		Ambient = Color3.new(0, 0, 0);
		OutdoorAmbient = Color3.new(0, 0, 0);
		ColorShift_Top = Color3.new(0, 0, 0);
		ColorShift_Bottom = Color3.new(0, 0, 0);
		ExposureCompensation = -3.5;
		ClockTime = 0;
		FogColor = Color3.new(0, 0, 0);
		FogStart = 0;
		FogEnd = 42;
		EnvironmentDiffuseScale = 0;
		EnvironmentSpecularScale = 0;
		GlobalShadows = false;
	}
	state.lightingBackup = {}
	for prop in state.lightingTarget do
		local value = NAmanage.Echolocation.SafeGet(Services.Lighting, prop)
		if value ~= nil then
			state.lightingBackup[prop] = value
		end
	end
end

NAmanage.Echolocation.ApplyDarkness = function()
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled or not Services.Lighting or type(state.lightingTarget) ~= "table" then
		return
	end
	for prop, value in state.lightingTarget do
		if NAmanage.Echolocation.SafeGet(Services.Lighting, prop) ~= value then
			NAmanage.Echolocation.SafeSet(Services.Lighting, prop, value)
		end
	end
end

NAmanage.Echolocation.RestoreLighting = function()
	local state = NAmanage.Echolocation.GetState()
	if Services.Lighting and type(state.lightingBackup) == "table" then
		for prop, value in state.lightingBackup do
			NAmanage.Echolocation.SafeSet(Services.Lighting, prop, value)
		end
	end
	state.lightingBackup = nil
	state.lightingTarget = nil
end

NAmanage.Echolocation.EnsureVisualRoot = function()
	local state = NAmanage.Echolocation.GetState()
	if typeof(state.visualRoot) == "Instance" and state.visualRoot.Parent then
		return state.visualRoot
	end
	local folder = InstanceNew("Folder")
	folder.Name = "\0"
	folder.Parent = Services.Workspace
	state.visualRoot = folder
	return folder
end

NAmanage.Echolocation.UpdateOverlapFilter = function()
	local state = NAmanage.Echolocation.GetState()
	if typeof(state.overlap) ~= "OverlapParams" then
		state.overlap = OverlapParams.new()
	end
	pcall(function()
		state.overlap.FilterType = Enum.RaycastFilterType.Exclude
		state.overlap.MaxParts = math.max(0, math.floor(tonumber(state.config.maxQueryParts) or 220))
		state.overlap.RespectCanCollide = false
		local filter = {}
		if typeof(state.visualRoot) == "Instance" then
			filter[#filter + 1] = state.visualRoot
		end
		if typeof(state.character) == "Instance" then
			filter[#filter + 1] = state.character
		end
		state.overlap.FilterDescendantsInstances = filter
	end)
	return state.overlap
end

NAmanage.Echolocation.EnsureSelfHighlight = function()
	local state = NAmanage.Echolocation.GetState()
	if typeof(state.selfHighlight) ~= "Instance" or not state.selfHighlight.Parent then
		local root = NAmanage.Echolocation.EnsureVisualRoot()
		local highlight = InstanceNew("Highlight", root)
		highlight.Name = "\0"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = Color3.new(1, 1, 1)
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 0.93
		highlight.OutlineTransparency = 0.05
		highlight.Enabled = true
		state.selfHighlight = highlight
	end
	state.selfHighlight.Adornee = state.character
	return state.selfHighlight
end

NAmanage.Echolocation.CreateWaveSlot = function()
	local state = NAmanage.Echolocation.GetState()
	if #state.wavePool >= math.max(1, math.floor(tonumber(state.config.maxWaves) or 4)) then
		return nil
	end
	local root = NAmanage.Echolocation.EnsureVisualRoot()
	local part = InstanceNew("Part", root)
	part.Name = "\0"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = Vector3.new(0.05, 0.05, 0.05)
	local slot = {
		active = false;
		part = part;
		rings = {};
	}
	for i = 1, 3 do
		local ring = InstanceNew("CylinderHandleAdornment", root)
		ring.Name = "\0"
		ring.Adornee = part
		ring.AlwaysOnTop = true
		ring.ZIndex = 10
		ring.Color3 = Color3.new(1, 1, 1)
		ring.Transparency = 1
		ring.Height = 0.035
		ring.Angle = 360
		ring.Radius = 0.1
		ring.InnerRadius = 0
		if i == 2 then
			ring.CFrame = CFrame.Angles(math.pi * 0.5, 0, 0)
		elseif i == 3 then
			ring.CFrame = CFrame.Angles(0, 0, math.pi * 0.5)
		end
		pcall(function()
			ring.AdornCullingMode = Enum.AdornCullingMode.Never
		end)
		slot.rings[i] = ring
	end
	state.wavePool[#state.wavePool + 1] = slot
	return slot
end

NAmanage.Echolocation.AcquireWaveSlot = function(sourceKey)
	local state = NAmanage.Echolocation.GetState()
	local perSourceCap = math.max(1, math.floor(tonumber(state.config.maxWaveSlotsPerSource) or 2))
	local sourceActive = 0
	local inactive = nil
	local counts = {}
	for i = 1, #state.wavePool do
		local slot = state.wavePool[i]
		if slot.active ~= true then
			inactive = inactive or slot
		else
			local pulse = slot.pulse
			local key = type(pulse) == "table" and pulse.sourceKey or nil
			counts[key or false] = (counts[key or false] or 0) + 1
			if key == sourceKey then
				sourceActive += 1
			end
		end
	end
	if sourceActive >= perSourceCap then
		return nil
	end
	if inactive then
		return inactive
	end
	if #state.wavePool < math.max(1, math.floor(tonumber(state.config.maxWaves) or 6)) then
		return NAmanage.Echolocation.CreateWaveSlot()
	end
	local donorSlot = nil
	local donorCount = 1
	local donorStarted = math.huge
	for i = 1, #state.wavePool do
		local slot = state.wavePool[i]
		local pulse = slot.active == true and slot.pulse or nil
		if type(pulse) == "table" then
			local key = pulse.sourceKey
			local count = counts[key or false] or 0
			local started = tonumber(pulse.started) or 0
			if key ~= sourceKey and count > 1 and (count > donorCount or (count == donorCount and started < donorStarted)) then
				donorSlot = slot
				donorCount = count
				donorStarted = started
			end
		end
	end
	if donorSlot then
		local donorPulse = donorSlot.pulse
		if type(donorPulse) == "table" and donorPulse.slot == donorSlot then
			donorPulse.slot = nil
		end
		NAmanage.Echolocation.ReleaseWaveSlot(donorSlot)
		return donorSlot
	end
	return nil
end

NAmanage.Echolocation.ReleaseWaveSlot = function(slot)
	if type(slot) ~= "table" then
		return
	end
	slot.active = false
	slot.pulse = nil
	for i = 1, #(slot.rings or {}) do
		pcall(function()
			slot.rings[i].Transparency = 1
		end)
	end
end

NAmanage.Echolocation.CreateHighlightSlot = function()
	local state = NAmanage.Echolocation.GetState()
	if #state.highlightPool >= math.max(1, math.floor(tonumber(state.config.maxHighlights) or 112)) then
		return nil
	end
	local root = NAmanage.Echolocation.EnsureVisualRoot()
	local highlight = InstanceNew("Highlight", root)
	highlight.Name = "\0"
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Enabled = false
	local slot = {
		active = false;
		highlight = highlight;
		patch = nil;
		mode = nil;
	}
	state.highlightPool[#state.highlightPool + 1] = slot
	return slot
end

NAmanage.Echolocation.EnsurePatchVisual = function(slot)
	if type(slot) ~= "table" then
		return nil
	end
	if typeof(slot.patch) == "Instance" and slot.patch.Parent then
		return slot.patch
	end
	local root = NAmanage.Echolocation.EnsureVisualRoot()
	local patch = InstanceNew("BoxHandleAdornment", root)
	patch.Name = "\0"
	patch.AlwaysOnTop = true
	patch.ZIndex = 9
	patch.Color3 = Color3.new(1, 1, 1)
	patch.Transparency = 1
	patch.Size = Vector3.new(0.05, 0.05, 0.05)
	pcall(function()
		patch.AdornCullingMode = Enum.AdornCullingMode.Never
	end)
	slot.patch = patch
	return patch
end

NAmanage.Echolocation.ReleaseHighlightSlot = function(slot)
	local state = NAmanage.Echolocation.GetState()
	if type(slot) ~= "table" then
		return
	end
	if slot.lookupKind == "patch" and typeof(slot.lookupTarget) == "Instance" then
		local sourceMap = state.patchSlots[slot.lookupTarget]
		if type(sourceMap) == "table" then
			local lookupKey = slot.lookupSourceKey ~= nil and slot.lookupSourceKey or false
			if sourceMap[lookupKey] == slot then
				sourceMap[lookupKey] = nil
			end
			if next(sourceMap) == nil then
				state.patchSlots[slot.lookupTarget] = nil
			end
		end
	elseif slot.target and state.targetSlots[slot.target] == slot then
		state.targetSlots[slot.target] = nil
	end
	slot.target = nil
	slot.sourceKey = nil
	slot.lookupKind = nil
	slot.lookupTarget = nil
	slot.lookupSourceKey = nil
	slot.active = false
	slot.started = 0
	slot.lastTouched = 0
	slot.revealDuration = 0
	slot.expires = 0
	slot.mode = nil
	slot.patchPart = nil
	slot.patchOrigin = nil
	if typeof(slot.highlight) == "Instance" then
		pcall(function()
			slot.highlight.Enabled = false
			slot.highlight.Adornee = nil
			slot.highlight.FillTransparency = 1
			slot.highlight.OutlineTransparency = 1
		end)
	end
	if typeof(slot.patch) == "Instance" then
		pcall(function()
			slot.patch.Adornee = nil
			slot.patch.Transparency = 1
		end)
	end
end

NAmanage.Echolocation.RefreshMovingSource = function(sourceKey, origin)
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled or typeof(sourceKey) ~= "Instance" or not sourceKey.Parent or typeof(origin) ~= "Vector3" then
		return false
	end
	local record = state.sourceOrigins[sourceKey]
	if type(record) ~= "table" then
		record = { origin = origin; }
		state.sourceOrigins[sourceKey] = record
		return false
	end
	local previous = record.origin
	if typeof(previous) ~= "Vector3" then
		record.origin = origin
		return false
	end
	local resetDistance = math.max(1, tonumber(state.config.movingSourceResetDistance) or 5.5)
	if (origin - previous).Magnitude < resetDistance then
		return false
	end
	record.origin = origin
	record.lastMovedAt = os.clock()
	return true
end

NAmanage.Echolocation.GetPhysicalSourceKey = function(sourceObject, fallback)
	if typeof(sourceObject) == "Instance" and sourceObject.Parent then
		if tostring(sourceObject.ClassName or "") == "Attachment" then
			local parent = sourceObject.Parent
			if parent and parent:IsA("BasePart") then
				return parent
			end
		end
		if sourceObject:IsA("BasePart") or sourceObject:IsA("Model") then
			return sourceObject
		end
	end
	return typeof(fallback) == "Instance" and fallback or nil
end

NAmanage.Echolocation.ResolveTarget = function(part)
	local state = NAmanage.Echolocation.GetState()
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") or not part.Parent then
		return nil, false
	end
	if typeof(state.visualRoot) == "Instance" and part:IsDescendantOf(state.visualRoot) then
		return nil, false
	end
	if typeof(state.character) == "Instance" and part:IsDescendantOf(state.character) then
		return nil, false
	end
	local camera = Services.Workspace.CurrentCamera
	if camera and part:IsDescendantOf(camera) then
		return nil, false
	end
	local model = part:FindFirstAncestorOfClass("Model")
	if model and model ~= state.character then
		local humanoid = model:FindFirstChildOfClass("Humanoid")
		if humanoid then
			return model, true
		end
	end
	return part, false
end

NAmanage.Echolocation.ShouldUseSurfacePatch = function(part)
	local state = NAmanage.Echolocation.GetState()
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") or not part.Parent then
		return false
	end
	local size = part.Size
	local maxDimension = math.max(size.X, size.Y, size.Z)
	if maxDimension >= math.max(8, tonumber(state.config.largePartDimension) or 36) then
		return true
	end
	local camera = Services.Workspace.CurrentCamera
	if not camera then
		return false
	end
	local cameraPosition = camera.CFrame.Position
	local closest = nil
	pcall(function()
		closest = part:GetClosestPointOnSurface(cameraPosition)
	end)
	if typeof(closest) ~= "Vector3" then
		closest = part.Position
	end
	local distance = math.max(0.5, (cameraPosition - closest).Magnitude)
	return (maxDimension / distance) >= math.max(0.2, tonumber(state.config.largePartApparentRatio) or 0.9)
end

NAmanage.Echolocation.GetSurfacePatch = function(part, origin)
	local state = NAmanage.Echolocation.GetState()
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") or not part.Parent then
		return nil, nil
	end
	origin = typeof(origin) == "Vector3" and origin or part.Position
	local size = part.Size
	local half = size * 0.5
	local localOrigin = part.CFrame:PointToObjectSpace(origin)
	local localSurface = Vector3.new(
		math.clamp(localOrigin.X, -half.X, half.X),
		math.clamp(localOrigin.Y, -half.Y, half.Y),
		math.clamp(localOrigin.Z, -half.Z, half.Z)
	)
	local inside = math.abs(localOrigin.X) <= half.X and math.abs(localOrigin.Y) <= half.Y and math.abs(localOrigin.Z) <= half.Z
	if inside then
		local dx = half.X - math.abs(localOrigin.X)
		local dy = half.Y - math.abs(localOrigin.Y)
		local dz = half.Z - math.abs(localOrigin.Z)
		if dx <= dy and dx <= dz then
			localSurface = Vector3.new(localOrigin.X >= 0 and half.X or -half.X, localOrigin.Y, localOrigin.Z)
		elseif dy <= dz then
			localSurface = Vector3.new(localOrigin.X, localOrigin.Y >= 0 and half.Y or -half.Y, localOrigin.Z)
		else
			localSurface = Vector3.new(localOrigin.X, localOrigin.Y, localOrigin.Z >= 0 and half.Z or -half.Z)
		end
	else
		local closest = nil
		pcall(function()
			closest = part:GetClosestPointOnSurface(origin)
		end)
		if typeof(closest) == "Vector3" then
			localSurface = part.CFrame:PointToObjectSpace(closest)
		end
	end
	local nx = half.X > 0 and math.abs(math.abs(localSurface.X) - half.X) or math.huge
	local ny = half.Y > 0 and math.abs(math.abs(localSurface.Y) - half.Y) or math.huge
	local nz = half.Z > 0 and math.abs(math.abs(localSurface.Z) - half.Z) or math.huge
	local axis = "X"
	if ny <= nx and ny <= nz then
		axis = "Y"
	elseif nz <= nx and nz <= ny then
		axis = "Z"
	end
	if axis == "X" then
		localSurface = Vector3.new(localSurface.X >= 0 and half.X or -half.X, math.clamp(localSurface.Y, -half.Y, half.Y), math.clamp(localSurface.Z, -half.Z, half.Z))
	elseif axis == "Y" then
		localSurface = Vector3.new(math.clamp(localSurface.X, -half.X, half.X), localSurface.Y >= 0 and half.Y or -half.Y, math.clamp(localSurface.Z, -half.Z, half.Z))
	else
		localSurface = Vector3.new(math.clamp(localSurface.X, -half.X, half.X), math.clamp(localSurface.Y, -half.Y, half.Y), localSurface.Z >= 0 and half.Z or -half.Z)
	end
	local worldSurface = part.CFrame:PointToWorldSpace(localSurface)
	local camera = Services.Workspace.CurrentCamera
	local cameraDistance = camera and (camera.CFrame.Position - worldSurface).Magnitude or 30
	local minSpan = math.max(0.5, tonumber(state.config.surfacePatchMinSize) or 1.5)
	local maxSpan = math.max(minSpan, tonumber(state.config.surfacePatchMaxSize) or 12)
	local ratio = math.max(0.05, tonumber(state.config.surfacePatchCameraRatio) or 0.22)
	local span = math.clamp(cameraDistance * ratio, minSpan, maxSpan)
	local thickness = math.max(0.015, tonumber(state.config.surfacePatchThickness) or 0.055)
	local patchSize
	if axis == "X" then
		patchSize = Vector3.new(thickness, math.min(size.Y, span), math.min(size.Z, span))
	elseif axis == "Y" then
		patchSize = Vector3.new(math.min(size.X, span), thickness, math.min(size.Z, span))
	else
		patchSize = Vector3.new(math.min(size.X, span), math.min(size.Y, span), thickness)
	end
	return CFrame.new(localSurface), patchSize
end

NAmanage.Echolocation.ApplySlotVisual = function(slot, target, isCharacter, hitPart, origin)
	if type(slot) ~= "table" or typeof(target) ~= "Instance" then
		return
	end
	local previousMode = slot.mode
	local previousPatchPart = slot.patchPart
	local patchPart = nil
	if isCharacter ~= true then
		if typeof(hitPart) == "Instance" and hitPart:IsA("BasePart") and hitPart.Parent then
			patchPart = hitPart
		elseif target:IsA("BasePart") then
			patchPart = target
		end
	end
	local usePatch = patchPart and NAmanage.Echolocation.ShouldUseSurfacePatch(patchPart)
	slot.mode = usePatch and "patch" or "highlight"
	slot.patchPart = usePatch and patchPart or nil
	slot.patchOrigin = usePatch and origin or nil
	if usePatch then
		local patch = NAmanage.Echolocation.EnsurePatchVisual(slot)
		local relativeCFrame, patchSize = NAmanage.Echolocation.GetSurfacePatch(patchPart, origin)
		local samePatch = previousMode == "patch"
			and previousPatchPart == patchPart
			and patch
			and patch.Adornee == patchPart
		if typeof(slot.highlight) == "Instance" then
			pcall(function()
				slot.highlight.Enabled = false
				slot.highlight.Adornee = nil
			end)
		end
		if patch and relativeCFrame and patchSize then
			pcall(function()
				patch.Adornee = patchPart
				if samePatch then
					patch.CFrame = patch.CFrame:Lerp(relativeCFrame, 0.55)
					patch.Size = patch.Size:Lerp(patchSize, 0.55)
				else
					patch.CFrame = relativeCFrame
					patch.Size = patchSize
					patch.Transparency = 1
				end
			end)
		end
	else
		if typeof(slot.patch) == "Instance" then
			pcall(function()
				slot.patch.Adornee = nil
				slot.patch.Transparency = 1
			end)
		end
		if typeof(slot.highlight) == "Instance" then
			local sameHighlight = previousMode == "highlight"
				and slot.highlight.Adornee == target
				and slot.highlight.Enabled == true
			pcall(function()
				slot.highlight.Adornee = target
				if not sameHighlight then
					slot.highlight.FillTransparency = 1
					slot.highlight.OutlineTransparency = 1
				end
				slot.highlight.Enabled = true
			end)
		end
	end
end

NAmanage.Echolocation.TouchTarget = function(target, isCharacter, strength, sourceKey, hitPart, origin)
	local state = NAmanage.Echolocation.GetState()
	if typeof(target) ~= "Instance" or not target.Parent then
		return
	end
	local patchPart = nil
	if isCharacter ~= true then
		if typeof(hitPart) == "Instance" and hitPart:IsA("BasePart") and hitPart.Parent then
			patchPart = hitPart
		elseif target:IsA("BasePart") then
			patchPart = target
		end
	end
	local wantsPatch = patchPart ~= nil and NAmanage.Echolocation.ShouldUseSurfacePatch(patchPart)
	local sourceLookupKey = sourceKey ~= nil and sourceKey or false
	local slot
	local sourceMap
	if wantsPatch then
		sourceMap = state.patchSlots[patchPart]
		if type(sourceMap) ~= "table" then
			sourceMap = {}
			state.patchSlots[patchPart] = sourceMap
		end
		slot = sourceMap[sourceLookupKey]
	else
		slot = state.targetSlots[target]
	end
	local now = os.clock()
	local revealDuration = (tonumber(state.config.revealTime) or 1.15) * math.clamp(tonumber(strength) or 1, 0.75, 1.5)
	if type(slot) == "table" and slot.active == true then
		if type(slot.started) ~= "number" then
			slot.started = now
		end
		slot.lastTouched = now
		slot.revealDuration = math.max(tonumber(slot.revealDuration) or 0, revealDuration)
		slot.expires = math.max(tonumber(slot.expires) or 0, now + revealDuration)
		slot.isCharacter = isCharacter == true
		slot.sourceKey = sourceKey
		NAmanage.Echolocation.ApplySlotVisual(slot, target, isCharacter, hitPart, origin)
		return
	end
	if wantsPatch and type(sourceMap) == "table" then
		local patchCount = 0
		local oldestSlot = nil
		local oldestTouched = math.huge
		for _, existing in sourceMap do
			if type(existing) == "table" and existing.active == true then
				patchCount += 1
				local touched = tonumber(existing.lastTouched) or 0
				if touched < oldestTouched then
					oldestTouched = touched
					oldestSlot = existing
				end
			end
		end
		if patchCount >= math.max(1, math.floor(tonumber(state.config.maxPatchSlotsPerPart) or 6)) and oldestSlot then
			NAmanage.Echolocation.ReleaseHighlightSlot(oldestSlot)
		end
	end
	for i = 1, #state.highlightPool do
		if state.highlightPool[i].active ~= true then
			slot = state.highlightPool[i]
			break
		end
	end
	if type(slot) ~= "table" or slot.active == true then
		slot = NAmanage.Echolocation.CreateHighlightSlot()
	end
	if not slot then
		return
	end
	slot.active = true
	slot.target = target
	slot.started = now
	slot.lastTouched = now
	slot.revealDuration = revealDuration
	slot.expires = now + revealDuration
	slot.isCharacter = isCharacter == true
	slot.sourceKey = sourceKey
	if wantsPatch then
		sourceMap = state.patchSlots[patchPart]
		if type(sourceMap) ~= "table" then
			sourceMap = {}
			state.patchSlots[patchPart] = sourceMap
		end
		slot.lookupKind = "patch"
		slot.lookupTarget = patchPart
		slot.lookupSourceKey = sourceLookupKey
		sourceMap[sourceLookupKey] = slot
	else
		slot.lookupKind = "highlight"
		slot.lookupTarget = target
		slot.lookupSourceKey = nil
		state.targetSlots[target] = slot
	end
	NAmanage.Echolocation.ApplySlotVisual(slot, target, isCharacter, hitPart, origin)
end

NAmanage.Echolocation.UpdateHighlights = function(now)
	local state = NAmanage.Echolocation.GetState()
	for i = 1, #state.highlightPool do
		local slot = state.highlightPool[i]
		if slot.active == true then
			if typeof(slot.target) ~= "Instance" or not slot.target.Parent or now >= (tonumber(slot.expires) or 0) then
				NAmanage.Echolocation.ReleaseHighlightSlot(slot)
			else
				local started = tonumber(slot.started) or now
				local revealDuration = math.max(0.05, tonumber(slot.revealDuration) or ((tonumber(slot.expires) or now) - started))
				local age = math.max(0, now - started)
				local remaining = math.max(0, (tonumber(slot.expires) or now) - now)
				local fadeIn = math.clamp(age / 0.07, 0, 1)
				local fadeOutWindow = math.clamp(revealDuration * 0.42, 0.18, 0.55)
				local fadeOut = math.clamp(remaining / fadeOutWindow, 0, 1)
				local opacity = math.min(fadeIn, fadeOut)
				if slot.mode == "patch" and typeof(slot.patch) == "Instance" then
					if typeof(slot.patchPart) == "Instance" and slot.patchPart.Parent then
						pcall(function()
							slot.patch.Transparency = math.clamp(1 - (0.82 * opacity), 0.12, 1)
						end)
					else
						NAmanage.Echolocation.ReleaseHighlightSlot(slot)
					end
				elseif typeof(slot.highlight) == "Instance" then
					local fillTarget = slot.isCharacter and 0.68 or 0.88
					local outlineTarget = slot.isCharacter and 0.02 or 0.08
					pcall(function()
						slot.highlight.FillTransparency = 1 - ((1 - fillTarget) * opacity)
						slot.highlight.OutlineTransparency = 1 - ((1 - outlineTarget) * opacity)
					end)
				end
			end
		end
	end
end

NAmanage.Echolocation.IsPartReachedByPulse = function(part, pulse)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") or type(pulse) ~= "table" or typeof(pulse.origin) ~= "Vector3" then
		return false
	end
	local radius = math.max(0.25, tonumber(pulse.radius) or 0.25)
	local tolerance = math.clamp(radius * 0.025, 0.2, 1.25)
	local size = part.Size
	local maxDimension = math.max(size.X, size.Y, size.Z)
	local className = tostring(part.ClassName or "")
	local needsExact = maxDimension >= math.max(8, tonumber(NAmanage.Echolocation.GetState().config.largePartDimension) or 36)
		or className == "MeshPart"
		or part:IsA("PartOperation")
	if needsExact then
		local closest = nil
		pcall(function()
			closest = part:GetClosestPointOnSurface(pulse.origin)
		end)
		if typeof(closest) == "Vector3" then
			return (closest - pulse.origin).Magnitude <= radius + tolerance
		end
	end
	local centerDistance = (part.Position - pulse.origin).Magnitude
	local halfDiagonal = size.Magnitude * 0.5
	local nearestApprox = math.max(0, centerDistance - halfDiagonal)
	return nearestApprox <= radius + tolerance
end

NAmanage.Echolocation.QueryPulse = function(pulse)
	local state = NAmanage.Echolocation.GetState()
	if type(pulse) ~= "table" or not state.enabled then
		return
	end
	local overlap = NAmanage.Echolocation.UpdateOverlapFilter()
	local ok, parts = pcall(function()
		return Services.Workspace:GetPartBoundsInRadius(pulse.origin, math.max(0.25, tonumber(pulse.radius) or 0.25), overlap)
	end)
	if not ok or type(parts) ~= "table" then
		return
	end
	local revealed = 0
	local maxReveal = math.max(1, math.floor(tonumber(state.config.maxRevealPerQuery) or 72))
	for i = 1, #parts do
		local part = parts[i]
		if NAmanage.Echolocation.IsPartReachedByPulse(part, pulse) then
			local target, isCharacter = NAmanage.Echolocation.ResolveTarget(part)
			if target and not pulse.seen[target] then
				pulse.seen[target] = true
				NAmanage.Echolocation.TouchTarget(target, isCharacter, pulse.strength, pulse.sourceKey, part, pulse.origin)
				revealed += 1
				if revealed >= maxReveal then
					break
				end
			end
		end
	end
end

NAmanage.Echolocation.RemovePulseAt = function(index)
	local state = NAmanage.Echolocation.GetState()
	index = math.floor(tonumber(index) or 0)
	if index < 1 or index > #state.pulses then
		return nil
	end
	local pulse = table.remove(state.pulses, index)
	if type(pulse) == "table" then
		NAmanage.Echolocation.ReleaseWaveSlot(pulse.slot)
		pulse.slot = nil
	end
	return pulse
end

NAmanage.Echolocation.TrimPulseCapacity = function(sourceKey)
	local state = NAmanage.Echolocation.GetState()
	local maxActivePulses = math.max(4, math.floor(tonumber(state.config.maxActivePulses) or 28))
	local perSourceCap = math.max(1, math.floor(tonumber(state.config.maxPulsesPerSource) or 3))
	if sourceKey ~= nil then
		local sourceCount = 0
		for i = 1, #state.pulses do
			local pulse = state.pulses[i]
			if type(pulse) == "table" and pulse.sourceKey == sourceKey then
				sourceCount += 1
			end
		end
		if sourceCount >= perSourceCap then
			return false
		end
	end
	if #state.pulses < maxActivePulses then
		return true
	end
	local counts = {}
	for i = 1, #state.pulses do
		local pulse = state.pulses[i]
		if type(pulse) == "table" then
			local key = pulse.sourceKey or false
			counts[key] = (counts[key] or 0) + 1
		end
	end
	local removeIndex = nil
	local donorCount = 1
	local donorStarted = math.huge
	for i = 1, #state.pulses do
		local pulse = state.pulses[i]
		if type(pulse) == "table" then
			local key = pulse.sourceKey or false
			local count = counts[key] or 0
			local started = tonumber(pulse.started) or 0
			if key ~= (sourceKey or false) and count > 1 and (count > donorCount or (count == donorCount and started < donorStarted)) then
				removeIndex = i
				donorCount = count
				donorStarted = started
			end
		end
	end
	if removeIndex then
		NAmanage.Echolocation.RemovePulseAt(removeIndex)
		return #state.pulses < maxActivePulses
	end
	return false
end

NAmanage.Echolocation.Emit = function(origin, maxRadius, strength, sourceKey)
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled or typeof(origin) ~= "Vector3" then
		return false
	end
	if typeof(sourceKey) == "Instance" then
		NAmanage.Echolocation.RefreshMovingSource(sourceKey, origin)
	end
	if NAmanage.Echolocation.TrimPulseCapacity(sourceKey) ~= true then
		return false
	end
	local slot = NAmanage.Echolocation.AcquireWaveSlot(sourceKey)
	local radius = math.clamp(tonumber(maxRadius) or tonumber(state.config.range) or 74, 12, 180)
	local waveSpeed = math.max(20, tonumber(state.config.waveSpeed) or 92)
	local now = os.clock()
	local pulse = {
		origin = origin;
		started = now;
		duration = radius / waveSpeed;
		maxRadius = radius;
		radius = 0.1;
		lastRadius = 0;
		strength = math.clamp(tonumber(strength) or 1, 0.5, 1.5);
		sourceKey = sourceKey;
		nextQuery = 0;
		seen = NAmanage.ensureWeakKeyTable(nil);
		slot = slot;
	}
	if type(slot) == "table" then
		slot.active = true
		slot.pulse = pulse
		pcall(function()
			slot.part.CFrame = CFrame.new(origin)
		end)
	end
	state.pulses[#state.pulses + 1] = pulse
	return true
end

NAmanage.Echolocation.UpdatePulses = function(now)
	local state = NAmanage.Echolocation.GetState()
	for i = #state.pulses, 1, -1 do
		local pulse = state.pulses[i]
		local progress = math.clamp((now - pulse.started) / math.max(0.05, pulse.duration), 0, 1)
		pulse.radius = math.max(0.1, pulse.maxRadius * progress)
		local ringThickness = math.clamp(pulse.radius * 0.012, 0.08, 0.28)
		local ringTransparency = math.clamp(0.1 + progress * 0.72, 0.1, 0.9)
		if type(pulse.slot) == "table" then
			for ringIndex = 1, #(pulse.slot.rings or {}) do
				local ring = pulse.slot.rings[ringIndex]
				pcall(function()
					ring.Radius = pulse.radius
					ring.InnerRadius = math.max(0, pulse.radius - ringThickness)
					ring.Transparency = math.clamp(ringTransparency + ((ringIndex - 1) * 0.04), 0, 0.96)
				end)
			end
		end
		if now >= (tonumber(pulse.nextQuery) or 0) then
			pulse.nextQuery = now + math.max(0.025, tonumber(state.config.queryInterval) or 0.055)
			NAmanage.Echolocation.QueryPulse(pulse)
		end
		if progress >= 1 then
			NAmanage.Echolocation.ReleaseWaveSlot(pulse.slot)
			table.remove(state.pulses, i)
		end
	end
end


NAmanage.Echolocation.GetWorldPosition = function(inst)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	local className = tostring(inst.ClassName or "")
	if className == "Attachment" then
		local ok, value = pcall(function()
			return inst.WorldPosition
		end)
		if ok and typeof(value) == "Vector3" then
			return value
		end
	elseif inst:IsA("BasePart") then
		return inst.Position
	elseif className == "Camera" then
		local ok, value = pcall(function()
			return inst.CFrame.Position
		end)
		if ok and typeof(value) == "Vector3" then
			return value
		end
	elseif inst:IsA("Model") then
		local root = getRoot(inst)
		if root then
			return root.Position
		end
		local ok, pivot = pcall(function()
			return inst:GetPivot()
		end)
		if ok and typeof(pivot) == "CFrame" then
			return pivot.Position
		end
	end
	return nil
end

NAmanage.Echolocation.ResolveClassicSoundOrigin = function(sound)
	const RawWorkspace = __lt.gs("Workspace")
	if typeof(sound) ~= "Instance" or tostring(sound.ClassName or "") ~= "Sound" or not sound.Parent then
		return nil, nil
	end
	local current = sound.Parent
	while typeof(current) == "Instance" and current ~= RawWorkspace do
		local className = tostring(current.ClassName or "")
		if className == "Attachment" or current:IsA("BasePart") then
			return NAmanage.Echolocation.GetWorldPosition(current), current
		end
		current = current.Parent
	end
	local tool = sound:FindFirstAncestorOfClass("Tool")
	if tool then
		local handle = tool:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			return handle.Position, handle
		end
	end
	local model = sound:FindFirstAncestorOfClass("Model")
	if model and model:IsDescendantOf(Services.Workspace) then
		local position = NAmanage.Echolocation.GetWorldPosition(model)
		if position then
			return position, model
		end
	end
	return nil, nil
end

NAmanage.Echolocation.ResolveEmitterOrigin = function(emitter)
	if typeof(emitter) ~= "Instance" or tostring(emitter.ClassName or "") ~= "AudioEmitter" or not emitter.Parent then
		return nil, nil
	end
	local positionType = NAmanage.Echolocation.SafeGet(emitter, "PositionType")
	if positionType ~= nil and tostring(positionType):find("Instance", 1, true) then
		local positionInstance = NAmanage.Echolocation.SafeGet(emitter, "PositionInstance")
		local position = NAmanage.Echolocation.GetWorldPosition(positionInstance)
		if position then
			return position, positionInstance
		end
	end
	local parent = emitter.Parent
	local position = NAmanage.Echolocation.GetWorldPosition(parent)
	if position then
		return position, parent
	end
	return nil, nil
end

NAmanage.Echolocation.FindAudioPlayers = function(node, depth, visited, out, playingOnly)
	if typeof(node) ~= "Instance" or (tonumber(depth) or 0) > math.max(2, tonumber(NAmanage.Echolocation.GetState().config.audioGraphDepth) or 10) then
		return out or {}
	end
	visited = type(visited) == "table" and visited or {}
	out = type(out) == "table" and out or {}
	if visited[node] then
		return out
	end
	visited[node] = true
	if tostring(node.ClassName or "") == "AudioPlayer" then
		if playingOnly ~= true or NAmanage.Echolocation.SafeGet(node, "IsPlaying") == true then
			out[#out + 1] = node
		end
		return out
	end
	local okMethod, getWires = pcall(function()
		return node.GetConnectedWires
	end)
	if not okMethod or type(getWires) ~= "function" then
		return out
	end
	local ok, wires = pcall(getWires, node, "Input")
	if not ok or type(wires) ~= "table" then
		return out
	end
	for i = 1, #wires do
		local wire = wires[i]
		if typeof(wire) == "Instance" then
			local source = NAmanage.Echolocation.SafeGet(wire, "SourceInstance")
			NAmanage.Echolocation.FindAudioPlayers(source, (tonumber(depth) or 0) + 1, visited, out, playingOnly)
		end
	end
	return out
end

NAmanage.Echolocation.FindPlayingAudioPlayers = function(node)
	return NAmanage.Echolocation.FindAudioPlayers(node, 0, {}, {}, true)
end

NAmanage.Echolocation.FindPlayingAudioPlayer = function(node, depth, visited)
	local players = NAmanage.Echolocation.FindAudioPlayers(node, depth or 0, visited or {}, {}, true)
	return players[1]
end

NAmanage.Echolocation.GetEmitterDistanceCap = function(emitter)
	if typeof(emitter) ~= "Instance" or tostring(emitter.ClassName or "") ~= "AudioEmitter" then
		return nil
	end
	local ok, curve = pcall(function()
		return emitter:GetDistanceAttenuation()
	end)
	if not ok or type(curve) ~= "table" then
		return nil
	end
	local maxDistance = nil
	for distance, volume in curve do
		local d = tonumber(distance)
		local v = tonumber(volume)
		if d and v and v > 0 and (not maxDistance or d > maxDistance) then
			maxDistance = d
		end
	end
	return maxDistance
end

NAmanage.Echolocation.SourcePulseAllowed = function(sourceKey, now, moved)
	local state = NAmanage.Echolocation.GetState()
	if sourceKey == nil then
		return true
	end
	now = tonumber(now) or os.clock()
	local last = tonumber(state.sourceSoundPulseAt[sourceKey]) or 0
	local cooldown = math.max(0.03, tonumber(state.config.soundSourceMergeCooldown) or 0.09)
	if moved ~= true and now - last < cooldown then
		return false
	end
	state.sourceSoundPulseAt[sourceKey] = now
	return true
end

NAmanage.Echolocation.RevealSourceObject = function(sourceObject, strength, sourceKey, origin)
	if typeof(sourceObject) ~= "Instance" or not sourceObject.Parent then
		return
	end
	local target
	local hitPart
	local isCharacter = false
	if sourceObject:IsA("BasePart") then
		hitPart = sourceObject
		target, isCharacter = NAmanage.Echolocation.ResolveTarget(sourceObject)
	elseif sourceObject:IsA("Model") then
		target = sourceObject
		isCharacter = sourceObject:FindFirstChildOfClass("Humanoid") ~= nil
		hitPart = sourceObject.PrimaryPart or sourceObject:FindFirstChildWhichIsA("BasePart", true)
	elseif tostring(sourceObject.ClassName or "") == "Attachment" then
		local parent = sourceObject.Parent
		if parent and parent:IsA("BasePart") then
			hitPart = parent
			target, isCharacter = NAmanage.Echolocation.ResolveTarget(parent)
		end
	end
	if target then
		NAmanage.Echolocation.TouchTarget(target, isCharacter, strength, sourceKey, hitPart, origin)
	end
end

NAmanage.Echolocation.EmitClassicSound = function(sound, now, force)
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled or typeof(sound) ~= "Instance" or tostring(sound.ClassName or "") ~= "Sound" or not sound.Parent then
		return false
	end
	local record = state.soundRecords[sound]
	if type(record) ~= "table" then
		return false
	end
	local playing = NAmanage.Echolocation.SafeGet(sound, "IsPlaying") == true or NAmanage.Echolocation.SafeGet(sound, "Playing") == true
	local wasPlaying = record.playing == true
	record.playing = playing
	if playing and not wasPlaying then
		force = true
	end
	if not playing and force ~= true then
		return false
	end
	local origin, sourceObject = NAmanage.Echolocation.ResolveClassicSoundOrigin(sound)
	if typeof(origin) ~= "Vector3" then
		return false
	end
	local sourceKey = NAmanage.Echolocation.GetPhysicalSourceKey(sourceObject, sound) or sound
	local sourceMoved = NAmanage.Echolocation.RefreshMovingSource(sourceKey, origin)
	now = tonumber(now) or os.clock()
	local loudness = math.max(0, tonumber(NAmanage.Echolocation.SafeGet(sound, "PlaybackLoudness")) or 0)
	local volume = math.max(0, tonumber(NAmanage.Echolocation.SafeGet(sound, "Volume")) or 1)
	local minLoudness = math.max(0, tonumber(state.config.soundMinLoudness) or 1)
	local normalized = math.clamp(loudness / 1000, 0, 1)
	local cooldown = math.max(0.08, tonumber(state.config.soundPulseCooldown) or 0.18)
	local quietFallback = force ~= true and loudness < minLoudness and playing and volume > 0
	if quietFallback then
		cooldown = math.max(0.45, cooldown * 2.5)
		normalized = math.clamp(volume / 4, 0.05, 0.25)
	elseif force == true and normalized <= 0 then
		normalized = math.clamp(volume / 2, 0.08, 0.45)
	else
		cooldown = math.clamp(cooldown - (normalized * 0.07), 0.09, 0.5)
	end
	if force ~= true and sourceMoved ~= true and now - (tonumber(record.lastPulse) or 0) < cooldown then
		return false
	end
	if NAmanage.Echolocation.SourcePulseAllowed(sourceKey, now, sourceMoved) ~= true then
		NAmanage.Echolocation.RevealSourceObject(sourceObject, math.clamp(0.82 + (normalized * 0.68), 0.82, 1.5), sourceKey, origin)
		return false
	end
	local minRange = math.max(12, tonumber(state.config.soundBaseRange) or 20)
	local maxRange = math.max(minRange, tonumber(state.config.soundMaxRange) or 120)
	local radius = minRange + (math.sqrt(normalized) * (maxRange - minRange))
	local rolloff = tonumber(NAmanage.Echolocation.SafeGet(sound, "RollOffMaxDistance"))
	if rolloff and rolloff > 0 then
		radius = math.min(radius, math.max(12, rolloff))
	end
	radius = math.clamp(radius, 12, maxRange)
	local strength = math.clamp(0.82 + (normalized * 0.68), 0.82, 1.5)
	record.lastPulse = now
	record.lastLoudness = loudness
	record.sourceKey = sourceKey
	NAmanage.Echolocation.RevealSourceObject(sourceObject, strength, sourceKey, origin)
	return NAmanage.Echolocation.Emit(origin, radius, strength, sourceKey)
end

NAmanage.Echolocation.EmitAudioEmitter = function(emitter, now, force)
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled or typeof(emitter) ~= "Instance" or tostring(emitter.ClassName or "") ~= "AudioEmitter" or not emitter.Parent then
		return false
	end
	local record = state.soundRecords[emitter]
	if type(record) ~= "table" then
		return false
	end
	local players = NAmanage.Echolocation.FindPlayingAudioPlayers(emitter)
	if #players <= 0 then
		record.playing = false
		return false
	end
	local wasPlaying = record.playing == true
	record.playing = true
	if not wasPlaying then
		force = true
	end
	now = tonumber(now) or os.clock()
	local origin, sourceObject = NAmanage.Echolocation.ResolveEmitterOrigin(emitter)
	if typeof(origin) ~= "Vector3" then
		return false
	end
	local sourceKey = NAmanage.Echolocation.GetPhysicalSourceKey(sourceObject, emitter) or emitter
	local sourceMoved = NAmanage.Echolocation.RefreshMovingSource(sourceKey, origin)
	local cooldown = math.max(0.14, (tonumber(state.config.soundPulseCooldown) or 0.18) * 1.35)
	if force ~= true and sourceMoved ~= true and now - (tonumber(record.lastPulse) or 0) < cooldown then
		return false
	end
	local combined = 0
	for i = 1, #players do
		local volume = math.max(0, tonumber(NAmanage.Echolocation.SafeGet(players[i], "Volume")) or 1)
		combined += math.clamp(volume / 2, 0.05, 1)
	end
	local normalized = math.clamp(combined / math.max(1, math.sqrt(#players)), 0.12, 1)
	if NAmanage.Echolocation.SourcePulseAllowed(sourceKey, now, sourceMoved) ~= true then
		NAmanage.Echolocation.RevealSourceObject(sourceObject, math.clamp(0.85 + normalized * 0.55, 0.85, 1.4), sourceKey, origin)
		return false
	end
	local minRange = math.max(12, tonumber(state.config.soundBaseRange) or 20)
	local maxRange = math.max(minRange, tonumber(state.config.soundMaxRange) or 120)
	local radius = math.clamp(minRange + math.sqrt(normalized) * (maxRange - minRange), 12, maxRange)
	local emitterCap = NAmanage.Echolocation.GetEmitterDistanceCap(emitter)
	if emitterCap and emitterCap > 0 then
		radius = math.min(radius, math.max(12, emitterCap))
	end
	local strength = math.clamp(0.85 + normalized * 0.55, 0.85, 1.4)
	record.lastPulse = now
	record.playerCount = #players
	record.sourceKey = sourceKey
	NAmanage.Echolocation.RevealSourceObject(sourceObject, strength, sourceKey, origin)
	return NAmanage.Echolocation.Emit(origin, radius, strength, sourceKey)
end

NAmanage.Echolocation.BindEmitterAudioPlayers = function(emitter)
	local state = NAmanage.Echolocation.GetState()
	if typeof(emitter) ~= "Instance" or tostring(emitter.ClassName or "") ~= "AudioEmitter" or not emitter.Parent then
		return
	end
	local bound = state.emitterBoundPlayers[emitter]
	if type(bound) ~= "table" then
		bound = NAmanage.ensureWeakKeyTable(nil)
		state.emitterBoundPlayers[emitter] = bound
	end
	local players = NAmanage.Echolocation.FindAudioPlayers(emitter, 0, {}, {}, false)
	for i = 1, #players do
		local player = players[i]
		if typeof(player) == "Instance" and not bound[player] then
			bound[player] = true
			local okSignal, signal = pcall(function()
				return player:GetPropertyChangedSignal("IsPlaying")
			end)
			if okSignal and signal then
				NAlib.connect("echolocation_audio_events", signal:Connect(function()
					if NAmanage.Echolocation.GetState().enabled and NAmanage.Echolocation.SafeGet(player, "IsPlaying") == true then
						Defer(function()
							if emitter.Parent and NAmanage.Echolocation.GetState().enabled then
								NAmanage.Echolocation.EmitAudioEmitter(emitter, os.clock(), true)
							end
						end)
					end
				end))
			end
			local okLoop, looped = pcall(function()
				return player.Looped
			end)
			if okLoop and looped then
				NAlib.connect("echolocation_audio_events", looped:Connect(function()
					if emitter.Parent and NAmanage.Echolocation.GetState().enabled then
						NAmanage.Echolocation.EmitAudioEmitter(emitter, os.clock(), true)
					end
				end))
			end
		end
	end
end

NAmanage.Echolocation.TrackAudioSource = function(inst)
	local state = NAmanage.Echolocation.GetState()
	if typeof(inst) ~= "Instance" or not inst.Parent then
		return false
	end
	local className = tostring(inst.ClassName or "")
	if className ~= "Sound" and className ~= "AudioEmitter" then
		return false
	end
	if state.soundRecords[inst] then
		if className == "AudioEmitter" then
			NAmanage.Echolocation.BindEmitterAudioPlayers(inst)
		end
		return true
	end
	local record = {
		instance = inst;
		kind = className;
		lastPulse = 0;
		lastLoudness = 0;
		lastEventAt = 0;
		playing = false;
	}
	state.soundRecords[inst] = record
	state.soundList[#state.soundList + 1] = record
	if className == "Sound" then
		local function trigger()
			local currentState = NAmanage.Echolocation.GetState()
			if not currentState.enabled or not inst.Parent then
				return
			end
			local now = os.clock()
			local eventDebounce = math.max(0.02, tonumber(currentState.config.soundEventDebounce) or 0.045)
			if now - (tonumber(record.lastEventAt) or 0) < eventDebounce then
				return
			end
			record.lastEventAt = now
			Defer(function()
				if inst.Parent and NAmanage.Echolocation.GetState().enabled then
					NAmanage.Echolocation.EmitClassicSound(inst, os.clock(), true)
				end
			end)
		end
		local okPlayed, played = pcall(function()
			return inst.Played
		end)
		if okPlayed and played then
			NAlib.connect("echolocation_sound_events", played:Connect(trigger))
		end
		local okPlaying, playingSignal = pcall(function()
			return inst:GetPropertyChangedSignal("Playing")
		end)
		if okPlaying and playingSignal then
			NAlib.connect("echolocation_sound_events", playingSignal:Connect(function()
				if NAmanage.Echolocation.SafeGet(inst, "Playing") == true then
					trigger()
				end
			end))
		end
	else
		NAmanage.Echolocation.BindEmitterAudioPlayers(inst)
		local okWiring, wiringChanged = pcall(function()
			return inst.WiringChanged
		end)
		if okWiring and wiringChanged then
			NAlib.connect("echolocation_audio_events", wiringChanged:Connect(function()
				if inst.Parent and NAmanage.Echolocation.GetState().enabled then
					NAmanage.Echolocation.BindEmitterAudioPlayers(inst)
					Defer(function()
						NAmanage.Echolocation.EmitAudioEmitter(inst, os.clock(), true)
					end)
				end
			end))
		end
	end
	return true
end

NAmanage.Echolocation.InitializeAudioSources = function()
	local state = NAmanage.Echolocation.GetState()
	NAlib.disconnect("echolocation_sound_events")
	NAlib.disconnect("echolocation_audio_events")
	NAlib.disconnect("echolocation_source_added")
	state.soundRecords = NAmanage.ensureWeakKeyTable(nil)
	state.emitterBoundPlayers = NAmanage.ensureWeakKeyTable(nil)
	state.sourceSoundPulseAt = NAmanage.ensureWeakKeyTable(nil)
	state.soundList = {}
	state.soundCursor = 1
	state.nextSoundPoll = 0
	local classic = NAmanage.QueryDescendants(Services.Workspace, "Sound")
	for i = 1, #classic do
		NAmanage.Echolocation.TrackAudioSource(classic[i])
	end
	local emitters = NAmanage.QueryDescendants(Services.Workspace, "AudioEmitter")
	for i = 1, #emitters do
		NAmanage.Echolocation.TrackAudioSource(emitters[i])
	end
	NAlib.reconnect("echolocation_source_added", Services.Workspace.DescendantAdded:Connect(function(inst)
		if not NAmanage.Echolocation.GetState().enabled or typeof(inst) ~= "Instance" then
			return
		end
		local className = tostring(inst.ClassName or "")
		if className == "Sound" or className == "AudioEmitter" then
			NAmanage.Echolocation.TrackAudioSource(inst)
			Defer(function()
				local currentState = NAmanage.Echolocation.GetState()
				if not currentState.enabled or not inst.Parent then
					return
				end
				if className == "Sound" then
					NAmanage.Echolocation.EmitClassicSound(inst, os.clock(), false)
				else
					NAmanage.Echolocation.EmitAudioEmitter(inst, os.clock(), false)
				end
			end)
		end
	end))
end

NAmanage.Echolocation.UpdateAudioSources = function(now)
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled or now < (tonumber(state.nextSoundPoll) or 0) then
		return
	end
	state.nextSoundPoll = now + math.max(0.02, tonumber(state.config.soundPollInterval) or 0.05)
	local list = state.soundList
	local count = #list
	if count <= 0 then
		return
	end
	local checks = math.min(count, math.max(1, math.floor(tonumber(state.config.soundChecksPerPoll) or 48)))
	local cursor = math.clamp(math.floor(tonumber(state.soundCursor) or 1), 1, math.max(1, count))
	for _ = 1, checks do
		if cursor > #list then
			cursor = 1
		end
		local record = list[cursor]
		local inst = type(record) == "table" and record.instance or nil
		if typeof(inst) ~= "Instance" or not inst.Parent or not inst:IsDescendantOf(Services.Workspace) then
			if typeof(inst) == "Instance" then
				state.soundRecords[inst] = nil
			end
			table.remove(list, cursor)
			if #list <= 0 then
				cursor = 1
				break
			end
		else
			if record.kind == "Sound" then
				NAmanage.Echolocation.EmitClassicSound(inst, now, false)
			elseif record.kind == "AudioEmitter" then
				NAmanage.Echolocation.EmitAudioEmitter(inst, now)
			end
			cursor += 1
		end
	end
	state.soundCursor = cursor
end

NAmanage.Echolocation.GetFootOrigin = function(root, humanoid)
	if not root then
		return nil
	end
	local offset = 2.5
	if humanoid then
		offset = math.max(1.5, (tonumber(humanoid.HipHeight) or 2) + ((root.Size and root.Size.Y or 2) * 0.5))
	end
	return root.Position - Vector3.new(0, offset, 0)
end

NAmanage.Echolocation.UpdateCharacter = function(now)
	local state = NAmanage.Echolocation.GetState()
	local player = Services.Players and Services.Players.LocalPlayer
	local character = player and player.Character or nil
	if character ~= state.character then
		state.character = character
		state.wasGrounded = nil
		state.airborneAt = now
		state.lastStepAt = 0
		NAmanage.Echolocation.UpdateOverlapFilter()
		NAmanage.Echolocation.EnsureSelfHighlight()
	end
	if not character or not character.Parent then
		return
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = getRoot(character)
	if not humanoid or not root or humanoid.Health <= 0 then
		return
	end
	local currentFootOrigin = NAmanage.Echolocation.GetFootOrigin(root, humanoid) or root.Position
	NAmanage.Echolocation.RefreshMovingSource(root, currentFootOrigin)
	if typeof(state.selfHighlight) == "Instance" then
		state.selfHighlight.Adornee = character
	end
	local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
	if state.wasGrounded == nil then
		state.wasGrounded = grounded
	end
	if not grounded and state.wasGrounded == true then
		state.airborneAt = now
	elseif grounded and state.wasGrounded == false then
		local airTime = now - (tonumber(state.airborneAt) or now)
		if airTime >= 0.16 then
			local origin = NAmanage.Echolocation.GetFootOrigin(root, humanoid)
			if origin then
				NAmanage.Echolocation.Emit(origin, math.min(110, (tonumber(state.config.range) or 74) * 1.2), 1.25, root)
				state.lastStepAt = now
			end
		end
	end
	state.wasGrounded = grounded
	if not grounded or humanoid.MoveDirection.Magnitude <= 0.05 then
		return
	end
	local velocity = root.AssemblyLinearVelocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	if speed < 1 then
		speed = humanoid.MoveDirection.Magnitude * math.max(tonumber(humanoid.WalkSpeed) or 16, 1)
	end
	if speed < 1 then
		return
	end
	local interval = math.clamp((tonumber(state.config.stepBaseInterval) or 0.56) * (16 / math.max(speed, 6)), 0.22, 0.68)
	if now - (tonumber(state.lastStepAt) or 0) < interval then
		return
	end
	state.lastStepAt = now
	local origin = NAmanage.Echolocation.GetFootOrigin(root, humanoid)
	if origin then
		local radius = math.clamp((tonumber(state.config.range) or 74) + ((speed - 16) * 0.8), 54, 105)
		NAmanage.Echolocation.Emit(origin, radius, math.clamp(0.85 + (speed / 80), 0.9, 1.25), root)
	end
end

NAmanage.Echolocation.Update = function()
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled then
		return
	end
	local now = os.clock()
	NAmanage.Echolocation.UpdateCharacter(now)
	NAmanage.Echolocation.UpdateAudioSources(now)
	NAmanage.Echolocation.UpdatePulses(now)
	NAmanage.Echolocation.UpdateHighlights(now)
	if now - (tonumber(state.lastDarknessAt) or 0) >= 0.2 then
		state.lastDarknessAt = now
		NAmanage.Echolocation.ApplyDarkness()
	end
end

NAmanage.Echolocation.Start = function(notify)
	local state = NAmanage.Echolocation.GetState()
	if state.enabled then
		if notify ~= false then
			DoNotif("Echolocation is already enabled", 2)
		end
		return true
	end
	state.enabled = true
	state.token = (tonumber(state.token) or 0) + 1
	state.pulses = {}
	state.sourceOrigins = NAmanage.ensureWeakKeyTable(nil)
	state.sourceSoundPulseAt = NAmanage.ensureWeakKeyTable(nil)
	state.patchSlots = NAmanage.ensureWeakKeyTable(nil)
	state.lastStepAt = 0
	state.lastDarknessAt = 0
	state.wasGrounded = nil
	state.airborneAt = os.clock()
	NAmanage.Echolocation.EnsureVisualRoot()
	NAmanage.Echolocation.CaptureLighting()
	state.character = Services.Players and Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character or nil
	NAmanage.Echolocation.UpdateOverlapFilter()
	NAmanage.Echolocation.EnsureSelfHighlight()
	NAmanage.Echolocation.InitializeAudioSources()
	NAmanage.Echolocation.ApplyDarkness()
	NAlib.reconnect("echolocation_runtime", Services.RunService.Heartbeat:Connect(function()
		NAmanage.Echolocation.Update()
	end))
	local root = state.character and getRoot(state.character) or nil
	if root then
		NAmanage.Echolocation.Emit(root.Position, math.min(90, tonumber(state.config.range) or 74), 1.1, root)
	end
	if notify ~= false then
		DoNotif("Echolocation enabled. Movement, landings, and spatial game sounds now emit pings.", 3, "Echolocation")
	end
	return true
end

NAmanage.Echolocation.Stop = function(notify)
	local state = NAmanage.Echolocation.GetState()
	local hadState = state.enabled == true or state.lightingBackup ~= nil or typeof(state.visualRoot) == "Instance"
	state.enabled = false
	state.token = (tonumber(state.token) or 0) + 1
	NAlib.disconnect("echolocation_runtime")
	NAlib.disconnect("echolocation_source_added")
	NAlib.disconnect("echolocation_sound_events")
	NAlib.disconnect("echolocation_audio_events")
	NAmanage.Echolocation.RestoreLighting()
	if typeof(state.visualRoot) == "Instance" then
		pcall(function()
			state.visualRoot:Destroy()
		end)
	end
	state.visualRoot = nil
	state.selfHighlight = nil
	state.overlap = nil
	state.character = nil
	state.pulses = {}
	state.wavePool = {}
	state.highlightPool = {}
	state.targetSlots = NAmanage.ensureWeakKeyTable(nil)
	state.patchSlots = NAmanage.ensureWeakKeyTable(nil)
	state.sourceOrigins = NAmanage.ensureWeakKeyTable(nil)
	state.sourceSoundPulseAt = NAmanage.ensureWeakKeyTable(nil)
	state.emitterBoundPlayers = NAmanage.ensureWeakKeyTable(nil)
	state.soundRecords = NAmanage.ensureWeakKeyTable(nil)
	state.soundList = {}
	state.soundCursor = 1
	state.nextSoundPoll = 0
	state.wasGrounded = nil
	state.airborneAt = 0
	state.lastStepAt = 0
	if notify ~= false and hadState then
		DoNotif("Echolocation disabled and Lighting restored.", 3, "Echolocation")
	end
	return hadState
end

NAmanage.RegisterUnloadCleanup("echolocation_restore", function()
	NAmanage.Echolocation.Stop(false)
end, 120)

cmd.add({"echolocation", "echo", "echolocate"}, {"echolocation (echo, echolocate)", "[BETA] Darkens the world and reveals geometry and entities from movement, landings, and spatial Sound/AudioEmitter sources"}, function()
	NAmanage.Echolocation.Start(true)
end)

cmd.add({"unecholocation", "unecho", "noecho"}, {"unecholocation (unecho, noecho)", "Disable echolocation and restore Lighting"}, function()
	NAmanage.Echolocation.Stop(true)
end)

cmd.add({"echoping", "eping", "sonarping"}, {"echoping (eping, sonarping)", "Emit a strong manual echolocation ping"}, function()
	local state = NAmanage.Echolocation.GetState()
	if not state.enabled then
		DoNotif("Enable echolocation first", 2, "Echolocation")
		return
	end
	local character = Services.Players and Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character or nil
	local root = character and getRoot(character) or nil
	if not root then
		DoNotif("Character root unavailable", 2, "Echolocation")
		return
	end
	NAmanage.Echolocation.Emit(root.Position, math.min(140, (tonumber(state.config.range) or 74) * 1.45), 1.5)
end)

NAmanage._ensureL=function()
	const st = _na_env._LState or {}
	_na_env._LState = st
	st.safeGet = st.safeGet or function(inst, prop) local ok,v=pcall(function() return inst[prop] end) if ok then return v end end
	st.safeSet = st.safeSet or function(inst, prop, v) return NAlib.setProperty(inst, prop, v) end
	if not st._utils then
		st._utils = true
		st.hook = function(name, fn) if not NAlib.isConnected(name) then NAlib.connect(name, fn()) end end
		st.disableTimeLoops = function()
			NAlib.disconnect("time_day")
			NAlib.disconnect("time_night")
		end
		st.disableShader = function()
			const sh = st.shader
			if not sh or not sh.enabled then return end
			sh.enabled = false
			if sh.restore then pcall(sh.restore) end
		end
		st.disableNF = function(force)
			const nf = st.nf
			if not nf then return end
			if not force and nf.sticky then return end
			const wasEnabled = nf.enabled
			if wasEnabled then
				nf.enabled = false
			end
			if force then nf.sticky = false end
			if not wasEnabled then return end
			if not ((st.fb and st.fb.enabled) or (st.nb and st.nb.enabled)) then
				if st.safeSet then
					if nf.baselineFogEnd~=nil then st.safeSet(Services.Lighting,"FogEnd",nf.baselineFogEnd) end
					if st.safeGet(Services.Lighting,"FogStart")~=nil and nf.baselineFogStart~=nil then st.safeSet(Services.Lighting,"FogStart",nf.baselineFogStart) end
				end
			end
			const cache = nf.cache
			if cache then
				for inst,saved in cache do
					if inst and inst.Parent and saved then
						for p,v in saved do
							st.safeSet(inst,p,v)
						end
					end
					cache[inst] = nil
				end
			end
		end
		st.disableFB = function()
			if st.fb and st.fb.enabled then
				if st.restoreFB then st.restoreFB() end
				st.fb.enabled = false
				_na_env.FullBrightEnabled = false
			end
		end
		st.disableNB = function()
			if st.nb and st.nb.enabled then
				if st.restoreNB then st.restoreNB() end
				st.nb.enabled = false
			end
		end
		st.cancelFor = function(mode)
			if mode ~= "echo" and type(NAmanage.Echolocation) == "table" and type(NAmanage.Echolocation.GetState) == "function" and type(NAmanage.Echolocation.Stop) == "function" then
				local echoState = NAmanage.Echolocation.GetState()
				if echoState and echoState.enabled == true then
					NAmanage.Echolocation.Stop(false)
				end
			end
			if mode=="fb" then
				st.disableTimeLoops()
				st.disableNF()
				st.disableNB()
				if st.disableNM then st.disableNM() end
				st.disableShader()
			elseif mode=="day" then
				st.disableFB()
				st.disableNB()
				if st.disableNM then st.disableNM() end
				st.disableShader()
			elseif mode=="night" then
				st.disableTimeLoops()
				st.disableFB()
				if st.disableNM then st.disableNM() end
				st.disableShader()
			elseif mode=="nf" then
				st.disableFB()
				st.disableNB()
				if st.disableNM then st.disableNM() end
				st.disableShader()
			elseif mode=="shader" then
				st.disableTimeLoops()
				st.disableFB()
				st.disableNB()
				st.disableNF(true)
				if st.disableNM then st.disableNM() end
			end
		end
	end
	return st
end
