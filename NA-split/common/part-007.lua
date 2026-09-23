NAmanage.PartESP_UpdateEntry = function(entry, force, rootPart)
	if not entry or entry.removed then return end
	const part = entry.part
	if not part or not part.Parent then
		NAmanage.PartESP_UnregisterEntry(entry)
		return
	end
	const billboard = entry.billboard
	local label = entry.label
	const drawingLabel = entry.drawingLabel
	const drawingSquare = entry.drawingSquare
	const drawingCornerLines = entry.drawingCornerLines
	local drawingCornerOutlineLines = entry.drawingCornerOutlineLines
	const visual = entry.visual
	const hasBillboard = billboard and billboard.Parent
	const hasDrawingLabel = drawingLabel ~= nil
	const hasDrawingSquare = drawingSquare ~= nil
	const hasDrawingCorners = type(drawingCornerLines) == "table" and #drawingCornerLines > 0
		or type(drawingCornerOutlineLines) == "table" and #drawingCornerOutlineLines > 0
	const hasVisual = visual and visual.Parent
	if not (hasBillboard or hasDrawingLabel or hasDrawingSquare or hasDrawingCorners or hasVisual) then
		NAmanage.PartESP_UnregisterEntry(entry)
		return
	end
	if billboard and ((not label) or label.Parent ~= billboard) then
		label = billboard:FindFirstChildWhichIsA("TextLabel")
		entry.label = label
	end
	if billboard and billboard.Parent then
		NAmanage.ESP_StoreVisual(billboard)
	end
	const baseLight = entry.lightColor or entry.baseColor or Color3.new(1, 1, 1)
	const baseDark = entry.darkColor or baseLight
	local visualLight = baseLight
	local visualDark = baseDark
	local labelColor = baseLight
	local transparency = NAgui.sanitizeTransparency(NAStuff.ESP_PartTransparency or entry.transparency)
	local occluded = false
	if NAStuff.ESP_OcclusionEnabled == true and NAStuff.ESP_OcclusionIncludeParts == true then
		const pos = NAgui.getInstanceWorldPosition(part)
		if pos then
			const plr = Services.Players.LocalPlayer
			const char = plr and plr.Character
			occluded = NAmanage.ESP_GetOcclusionState(part, part, pos, char, tick(), false, {
				partESP = true
			})
		end
	end
	if occluded then
		if NAStuff.ESP_OcclusionDimBoxes == true then
			visualLight = NAmanage.ESP_GetOccludedColor(visualLight)
			visualDark = NAmanage.ESP_GetOccludedColor(visualDark)
			transparency = NAmanage.ESP_GetOccludedTransparency(transparency)
		end
		if NAStuff.ESP_OcclusionDimLabels == true then
			labelColor = NAmanage.ESP_GetOccludedColor(labelColor)
		end
	end
	const baseName = entry.customName or part.Name or "Part"
	local display = baseName
	const showPartText = (NAStuff.ESP_ShowPartText ~= false) and not (occluded and NAStuff.ESP_OcclusionHidePartLabels == true)
	const showDistance = (NAStuff.ESP_ShowPartDistance == true)
	local root = rootPart
	if showDistance and not root then
		const plr = Services.Players.LocalPlayer
		const char = plr and plr.Character
		root = char and getRoot(char)
	end
	if showDistance and root then
		const pos = NAgui.getInstanceWorldPosition(part)
		if pos then
			const dist = math.floor((root.Position - pos).Magnitude + 0.5)
			display = Format("%s | %d studs", baseName, dist)
		end
	end
	if billboard and billboard.Parent then
		pcall(function()
			billboard.Enabled = showPartText
		end)
	end
	if label then
		if showPartText then
			if label.Text ~= display then
				label.Text = display
			end
			if not label.Visible then
				label.Visible = true
			end
			NAgui.applyLabelStyle(label)
			if label.TextColor3 ~= labelColor then
				label.TextColor3 = labelColor
			end
		elseif label.Visible then
			label.Visible = false
		end
	end
	if drawingLabel then
		if showPartText then
			const textPos = NAgui.getInstanceLabelWorldPosition(part, 0.2)
			if not NAmanage.DrawingUpdateText(drawingLabel, textPos, display, labelColor, NAStuff.ESP_LabelTextSize, {
				outlineEnabled = NAStuff.ESP_DrawingPartTextOutline ~= false;
				centered = NAStuff.ESP_DrawingPartTextCentered ~= false;
				font = NAStuff.ESP_DrawingTextFont;
				textTransparency = NAStuff.ESP_DrawingPartTextTransparency;
			}) then
				NAmanage.ESP_RequestVisualRebuild()
				return
			end
		else
			pcall(function()
				drawingLabel.Visible = false
			end)
		end
	end
	const partDrawingStyle = NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingPartBoxStyle)
	if drawingSquare then
		if partDrawingStyle == "Corners" then
			pcall(function()
				drawingSquare.Visible = false
			end)
		elseif not NAmanage.DrawingUpdateSquare(drawingSquare, part, visualLight, transparency, {
			filled = NAStuff.ESP_DrawingPartFilledBoxes == true;
			thickness = NAStuff.ESP_DrawingPartBoxThickness;
		}) then
			NAmanage.ESP_RequestVisualRebuild()
			return
		end
	end
	if partDrawingStyle == "Corners" and type(drawingCornerLines) == "table" then
		local minX, minY, width, height = NAgui.getInstanceViewportBounds(part)
		if minX then
			const alpha = NAgui.toDrawingTransparency(transparency)
			const mainThickness = math.max(1, tonumber(NAStuff.ESP_DrawingPartBoxThickness) or 1)
			const outlineEnabled = NAStuff.ESP_DrawingPartBoxOutline ~= false
			const outlineThickness = math.max(1, tonumber(NAStuff.ESP_DrawingPartBoxOutlineThickness) or (mainThickness + 2))
			const scale = math.clamp(tonumber(NAStuff.ESP_DrawingPartCornerScale) or 0.25, 0.05, 0.5)
			const segX = math.max(4, width * scale)
			const segY = math.max(4, height * scale)
			const points = {
				{ Vector2.new(minX, minY), Vector2.new(minX + segX, minY) },
				{ Vector2.new(minX + width, minY), Vector2.new(minX + width - segX, minY) },
				{ Vector2.new(minX, minY + height), Vector2.new(minX + segX, minY + height) },
				{ Vector2.new(minX + width, minY + height), Vector2.new(minX + width - segX, minY + height) },
				{ Vector2.new(minX, minY), Vector2.new(minX, minY + segY) },
				{ Vector2.new(minX + width, minY), Vector2.new(minX + width, minY + segY) },
				{ Vector2.new(minX, minY + height), Vector2.new(minX, minY + height - segY) },
				{ Vector2.new(minX + width, minY + height), Vector2.new(minX + width, minY + height - segY) },
			}
			if outlineEnabled and type(drawingCornerOutlineLines) ~= "table" then
				drawingCornerOutlineLines = {}
			end
			for i = 1, 8 do
				const seg = points[i]
				if outlineEnabled then
					if not drawingCornerOutlineLines[i] then
						drawingCornerOutlineLines[i] = NAmanage.DrawingCreateLine(Color3.new(0.1, 0.1, 0.1), math.min(1, alpha + 0.15), outlineThickness)
					end
					if not NAmanage.DrawingUpdateLine(drawingCornerOutlineLines[i], seg[1], seg[2], Color3.new(0.1, 0.1, 0.1), math.min(1, alpha + 0.15), outlineThickness) then
						NAmanage.ESP_RequestVisualRebuild()
						return
					end
				elseif type(drawingCornerOutlineLines) == "table" and drawingCornerOutlineLines[i] then
					pcall(function() drawingCornerOutlineLines[i].Visible = false end)
				end
				if not NAmanage.DrawingUpdateLine(drawingCornerLines[i], seg[1], seg[2], visualLight, alpha, mainThickness) then
					NAmanage.ESP_RequestVisualRebuild()
					return
				end
			end
		else
			for i = 1, #(drawingCornerLines or {}) do
				pcall(function()
					drawingCornerLines[i].Visible = false
				end)
			end
			for i = 1, #(drawingCornerOutlineLines or {}) do
				pcall(function()
					drawingCornerOutlineLines[i].Visible = false
				end)
			end
		end
	end
	if visual and visual.Parent then
		NAmanage.ESP_StoreVisual(visual)
		if visual:IsA("Highlight") then
			if visual.Enabled ~= true then
				visual.Enabled = true
			end
			if visual.FillTransparency ~= transparency then
				visual.FillTransparency = transparency
			end
			const outlineTr = NAgui.sanitizeTransparency(NAStuff.ESP_OutlineTransparency or 0)
			if visual.FillColor ~= visualLight then
				visual.FillColor = visualLight
			end
			if visual.OutlineColor ~= visualDark then
				visual.OutlineColor = visualDark
			end
			if visual.OutlineTransparency ~= outlineTr then
				visual.OutlineTransparency = outlineTr
			end
		elseif visual:IsA("BoxHandleAdornment") then
			if visual.Visible ~= true then
				visual.Visible = true
			end
			if visual.Color3 ~= visualLight then
				visual.Color3 = visualLight
			end
			if visual.Transparency ~= transparency then
				visual.Transparency = transparency
			end
			if part:IsA("BasePart") then
				const desired = part.Size + Vector3.new(0.1,0.1,0.1)
				if visual.Size ~= desired then
					visual.Size = desired
				end
			end
		end
	end
end

NAmanage.PartESP_UpdateTexts = function(force)
	const entries = NAStuff.partESPEntries
	if not entries then
		return
	end
	const interval = NAgui.espUsesDrawing("part") and 0.05 or 0.25
	if not force then
		const now = tick()
		const nextUpdate = NAStuff.partESPLastUpdate or 0
		if now < nextUpdate then
			return
		end
		NAStuff.partESPLastUpdate = now + interval
	else
		NAStuff.partESPLastUpdate = tick() + interval
	end
	local rootPart = nil
	if NAStuff.ESP_ShowPartDistance == true then
		const plr = Services.Players.LocalPlayer
		const char = plr and plr.Character
		rootPart = char and getRoot(char)
	end
	if next(entries) == nil then
		NAStuff.partESPUpdateCursor = nil
		NAmanage.PartESP_StopHeartbeat()
		return
	end
	local hasEntry = false
	if force then
		for _, entry in entries do
			if entry and not entry.removed then
				hasEntry = true
				NAmanage.PartESP_UpdateEntry(entry, force, rootPart)
			end
		end
	else
		const perStep = math.clamp(math.floor(tonumber(NAStuff.ESP_PartUpdatePerStep) or 48), 1, 512)
		local cursor = NAStuff.partESPUpdateCursor
		local startCursor = cursor
		local wrapped = false
		local processed = 0
		while processed < perStep do
			if cursor ~= nil and entries[cursor] == nil then
				cursor = nil
				startCursor = nil
			end
			local key, entry = next(entries, cursor)
			if key == nil then
				if processed > 0 and (startCursor == nil or wrapped) then
					break
				end
				wrapped = true
				key, entry = next(entries, nil)
				if key == nil then
					cursor = nil
					break
				end
				if startCursor ~= nil and key == startCursor then
					break
				end
			end
			cursor = key
			processed += 1
			if entry and not entry.removed then
				hasEntry = true
				NAmanage.PartESP_UpdateEntry(entry, false, rootPart)
			end
		end
		NAStuff.partESPUpdateCursor = cursor
	end
	if not hasEntry and next(entries) == nil then
		NAmanage.PartESP_StopHeartbeat()
	end
end

NAmanage.PartESP_StartHeartbeat = function()
	const useDrawingSignal = NAgui.espUsesDrawing("part")
	const desiredSignal = useDrawingSignal and "RenderStepped" or "Heartbeat"
	if NAlib.isConnected("esp_part_update") then
		if NAStuff.partESPUpdateSignal == desiredSignal then
			return
		end
		NAlib.disconnect("esp_part_update")
	end
	NAStuff.partESPUpdateSignal = desiredSignal
	NAStuff.partESPLastUpdate = 0
	const signal = useDrawingSignal and Services.RunService.RenderStepped or Services.RunService.Heartbeat
	NAlib.connect("esp_part_update", signal:Connect(function()
		NAmanage.PartESP_UpdateTexts(false)
	end))
end

NAmanage.PartESP_StopHeartbeat = function()
	const entries = NAStuff.partESPEntries
	if entries and next(entries) then return end
	NAlib.disconnect("esp_part_update")
	NAStuff.partESPUpdateSignal = nil
end

NAmanage.PartESP_RegisterEntry = function(entry)
	if not entry then return end
	entry.entryKey = entry.entryKey or entry.billboard or entry.visual or entry.drawingSquare or entry.drawingLabel or entry.part
	if not entry.entryKey then return end
	NAStuff.partESPEntries[entry.entryKey] = entry
	if not entry._partESPCounted then
		entry._partESPCounted = true
		NAStuff.partESPActiveCount = (tonumber(NAStuff.partESPActiveCount) or 0) + 1
	end
	if entry.visual and typeof(entry.visual) == "Instance" then
		NAStuff.partESPVisualMap[entry.visual] = entry
	end
	if entry.part and typeof(entry.part) == "Instance" then
		local partMap = NAStuff.partESPPartMap
		if type(partMap) ~= "table" then
			partMap = NAmanage.ensureWeakTable(nil, "k")
			NAStuff.partESPPartMap = partMap
		else
			partMap = NAmanage.ensureWeakTable(partMap, "k")
			NAStuff.partESPPartMap = partMap
		end
		local bucket = partMap[entry.part]
		if type(bucket) ~= "table" then
			bucket = {}
			partMap[entry.part] = bucket
		end
		bucket[entry.entryKey] = entry
	end
	if entry.billboardCleanup then
		entry.billboardCleanup:Disconnect()
	end
	if entry.visualCleanup then
		entry.visualCleanup:Disconnect()
	end
	if entry.partCleanup then
		entry.partCleanup:Disconnect()
		entry.partCleanup = nil
	end
	if entry.partDestroyingCleanup then
		entry.partDestroyingCleanup:Disconnect()
		entry.partDestroyingCleanup = nil
	end
	if entry.billboard then
		entry.billboardCleanup = entry.billboard.AncestryChanged:Connect(function(_, parent)
			if not parent then
				NAmanage.PartESP_UnregisterEntry(entry)
			end
		end)
	end
	if entry.visual then
		entry.visualCleanup = entry.visual.AncestryChanged:Connect(function(_, parent)
			if not parent then
				NAmanage.PartESP_UnregisterEntry(entry)
			end
		end)
	end
	if entry.part and typeof(entry.part) == "Instance" then
		entry.partCleanup = entry.part.AncestryChanged:Connect(function(_, parent)
			if not parent then
				NAmanage.PartESP_UnregisterEntry(entry)
			end
		end)
		pcall(function()
			entry.partDestroyingCleanup = entry.part.Destroying:Connect(function()
				NAmanage.PartESP_UnregisterEntry(entry)
			end)
		end)
	end
	NAmanage.PartESP_StartHeartbeat()
	NAmanage.PartESP_UpdateEntry(entry, true)
end

NAmanage.PartESP_UnregisterEntry = function(entry)
	if not entry or entry.removed then return end
	entry.removed = true
	NAmanage.ESP_LocatorRemoveArrow(entry)
	if entry.highlightMaterialTarget then
		const materialTarget = entry.highlightMaterialTarget
		entry.highlightMaterialTarget = nil
		NAmanage.ESP_AdjustHighlightMaterial(materialTarget, false, entry)
	end
	if entry.billboardCleanup then
		entry.billboardCleanup:Disconnect()
		entry.billboardCleanup = nil
	end
	if entry.visualCleanup then
		entry.visualCleanup:Disconnect()
		entry.visualCleanup = nil
	end
	if entry.partCleanup then
		entry.partCleanup:Disconnect()
		entry.partCleanup = nil
	end
	if entry.partDestroyingCleanup then
		entry.partDestroyingCleanup:Disconnect()
		entry.partDestroyingCleanup = nil
	end
	if entry.updateKey then
		NAlib.disconnect(entry.updateKey)
		entry.updateKey = nil
	end
	if entry.entryKey and NAStuff.partESPEntries then
		NAStuff.partESPEntries[entry.entryKey] = nil
	end
	if entry._partESPCounted then
		entry._partESPCounted = nil
		NAStuff.partESPActiveCount = math.max(0, (tonumber(NAStuff.partESPActiveCount) or 1) - 1)
	end
	if entry.visual and typeof(entry.visual) == "Instance" and NAStuff.partESPVisualMap then
		NAStuff.partESPVisualMap[entry.visual] = nil
	end
	if entry.part and typeof(entry.part) == "Instance" and type(NAStuff.partESPPartMap) == "table" then
		const bucket = NAStuff.partESPPartMap[entry.part]
		if type(bucket) == "table" and entry.entryKey then
			bucket[entry.entryKey] = nil
			if not next(bucket) then
				NAStuff.partESPPartMap[entry.part] = nil
			end
		end
	end
	if entry.drawingSquare then
		NAmanage.DrawingRemoveObject(entry.drawingSquare)
		entry.drawingSquare = nil
	end
	if type(entry.drawingCornerLines) == "table" then
		for i = 1, #entry.drawingCornerLines do
			NAmanage.DrawingRemoveObject(entry.drawingCornerLines[i])
		end
		entry.drawingCornerLines = nil
	end
	if type(entry.drawingCornerOutlineLines) == "table" then
		for i = 1, #entry.drawingCornerOutlineLines do
			NAmanage.DrawingRemoveObject(entry.drawingCornerOutlineLines[i])
		end
		entry.drawingCornerOutlineLines = nil
	end
	if entry.drawingLabel then
		NAmanage.DrawingRemoveObject(entry.drawingLabel)
		entry.drawingLabel = nil
	end
	if entry.visual and typeof(entry.visual) == "Instance" then
		pcall(function()
			entry.visual:Destroy()
		end)
	end
	entry.visual = nil
	if entry.billboard then
		pcall(function()
			entry.billboard:Destroy()
		end)
	end
	entry.billboard = nil
	entry.label = nil
	NAmanage.PartESP_StopHeartbeat()
end

NAmanage.PartESP_RebuildVisuals = function()
	const entries = NAStuff.partESPEntries
	if not entries or not next(entries) then
		return
	end
	const grouped = {}
	for _, entry in entries do
		if entry and not entry.removed and entry.part and entry.part.Parent then
			local bucket = grouped[entry.part]
			if not bucket then
				bucket = {}
				grouped[entry.part] = bucket
			end
			bucket[#bucket+1] = {
				color = entry.baseColor or Color3.new(1,1,1),
				transparency = NAgui.sanitizeTransparency(NAStuff.ESP_PartTransparency or entry.transparency or 0.45),
			}
		end
	end
	for part, bucket in grouped do
		NAmanage.RemoveEspFromPart(part)
		for _, info in bucket do
			NAmanage.CreateBox(part, info.color, info.transparency)
		end
	end
	NAmanage.PartESP_UpdateTexts(true)
end

NAmanage.ESP_RebuildVisuals = function()
	for model, data in espCONS do
		if data then
			const wasEnabled = data.boxEnabled
			NAmanage.ESP_RemoveBoxes(model)
			if wasEnabled then
				NAmanage.ESP_AddBoxes(model)
			end
		end
	end
	NAmanage.PartESP_RebuildVisuals()
	NAmanage.PartESP_StartHeartbeat()
	if NAStuff.ESP_LocatorEnabled then
		NAmanage.ESP_LocatorEnable(true)
		NAmanage.ESP_LocatorApplyFlags()
	end
	if NAStuff.ESP_PlayerLocatorEnabled then
		NAmanage.ESP_PlayerLocatorEnable(true)
		NAmanage.ESP_PlayerLocatorApplyFlags()
	end
	NAmanage.ESP_ApplyLabelStyles()
end

function round(num,numDecimalPlaces)
	const mult=10^(numDecimalPlaces or 0)
	return math.floor(num*mult+0.5) / mult
end

function getPlaceInfo(forceRefresh)
	const cachedInfo = NAStuff and NAStuff._placeInfoCache
	if not forceRefresh and type(cachedInfo) == "table" then
		return cachedInfo
	end

	local success, result = pcall(function()
		return __lt.cm("MarketplaceService", "GetProductInfo", PlaceId)
	end)

	if not success or type(result) ~= "table" then
		return cachedInfo
	end

	if NAStuff then
		NAStuff._placeInfoCache = result
		NAStuff._placeInfoCacheAt = os.clock()
	end

	return result
end

function placeName()
	const info = getPlaceInfo()
	const name = info and NAlib.isProperty(info, "Name")
	return name or "unknown"
end

function placeIconAssetId()
	const info = getPlaceInfo()
	const icon = info and NAlib.isProperty(info, "IconImageAssetId")
	if typeof(icon) == "number" then
		return icon
	end
	if typeof(icon) == "string" then
		const digits = icon:match("(%d+)")
		if digits then
			const numeric = tonumber(digits)
			if numeric then
				return numeric
			end
		end
		const asNumber = tonumber(icon)
		if asNumber then
			return asNumber
		end
	end
	return nil
end

Defer(function()
	if NAmanage and NAmanage.btEnabled and NAmanage.btEnabled() then
		pcall(getPlaceInfo)
	end
end)

function SaveUIStroke(color)
	if typeof(color) ~= "Color3" then
		return
	end

	if NAStuff and NAStuff.AprilFoolsData then
		NAStuff.AprilFoolsData.originalColor = color
	end

	NAmanage.NASettingsSet("uiStroke", {
		R = color.R;
		G = color.G;
		B = color.B;
	})
end

function placeCreator()
	const info = getPlaceInfo()
	const creator = info and NAlib.isProperty(info, "Creator")
	const creatorName = creator and NAlib.isProperty(creator, "Name")
	return creatorName or "unknown"
end

NAmanage.ESP_Key = function(model)
	return tostring(model)
end

NAmanage.ESP_GetSecureHost = function()
	const host = (NAlib.huiGrabber and NAlib.huiGrabber())
		or Services.CoreGui
		or (Services.Players and Services.Players.LocalPlayer and Services.Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
		or Services.Workspace.CurrentCamera
	if typeof(host) == "Instance" then
		return host
	end
	return nil
end

NAmanage.ESP_GetSecureAttrKey = function()
	local key = NAStuff.ESP_SecureAttrKey
	if type(key) == "string" and key ~= "" then
		return key
	end
	key = NAmanage.GenerateOpaqueSessionKey()
	NAStuff.ESP_SecureAttrKey = key
	return key
end

NAmanage.ESP_HardenVisual = function(inst)
	if typeof(inst) ~= "Instance" then
		return
	end
	pcall(function()
		inst.Archivable = false
	end)
	const secureAttrKey = NAmanage.ESP_GetSecureAttrKey()
	if NAmanage.GetAttr(inst, secureAttrKey) ~= true then
		NAmanage.SetAttr(inst, secureAttrKey, true)
		pcall(function()
			inst.Name = (NAgui.rStringgg and NAgui.rStringgg()) or "\0"
		end)
	end
	const hiddenSetter = (opt and opt.hiddenprop) or hiddenprop or sethiddenproperty or set_hidden_property or set_hidden_prop
	if hiddenSetter then
		pcall(function()
			hiddenSetter(inst, "RobloxLocked", true)
		end)
	end
end

NAmanage.ESP_EnsureSecureContainer = function()
	const host = NAmanage.ESP_GetSecureHost()
	if not host then
		return nil
	end
	local container = NAStuff.ESP_SecureContainer
	if container and not container.Parent then
		NAStuff.ESP_SecureContainer = nil
		container = nil
	end
	if not container then
		container = InstanceNew("Folder")
		NAStuff.ESP_SecureContainer = container
	end
	NAmanage.ESP_HardenVisual(container)
	if container.Parent ~= host then
		pcall(function()
			container.Parent = host
		end)
	end
	return container
end

NAmanage.ESP_StoreVisual = function(inst)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const container = NAmanage.ESP_EnsureSecureContainer()
	if not container then
		return nil
	end
	NAmanage.ESP_HardenVisual(inst)
	if inst.Parent ~= container then
		pcall(function()
			inst.Parent = container
		end)
	end
	return container
end

NAmanage.ESP_CollectTrackedBillboards = function(model, uid)
	const list = {}
	const seen = {}
	const function scan(root)
		if not (root and root.Parent) then
			return
		end
		for _, d in NAmanage.QueryDescendants(root, "BillboardGui") do
			if not seen[d] and NAmanage.GetAttr(d, "NA_ESP_UID") == uid then
				seen[d] = true
				list[#list + 1] = d
			end
		end
	end
	scan(model)
	scan(NAStuff.ESP_SecureContainer)
	return list
end

NAmanage.Helper_GetSecureHost = function()
	return Services.Workspace
end

NAmanage.Helper_EnsureSecureContainer = function()
	const host = NAmanage.Helper_GetSecureHost()
	if not host then
		return nil
	end
	local container = NAStuff.Helper_SecureContainer
	if container and not container.Parent then
		NAStuff.Helper_SecureContainer = nil
		container = nil
	end
	if not container then
		container = InstanceNew("Folder")
		NAStuff.Helper_SecureContainer = container
	end
	NAmanage.ESP_HardenVisual(container)
	if container.Parent ~= host then
		pcall(function()
			container.Parent = host
		end)
	end
	return container
end

NAmanage.Helper_StoreInstance = function(inst)
	if typeof(inst) ~= "Instance" then
		return nil
	end
	const container = NAmanage.Helper_EnsureSecureContainer()
	if not container then
		return nil
	end
	NAmanage.ESP_HardenVisual(inst)
	if inst.Parent ~= container then
		pcall(function()
			inst.Parent = container
		end)
	end
	return container
end

NAmanage.ESP_DestroyLabel = function(model)
	const data = espCONS[model]
	if not data then return end
	const uid = data.uid

	if data.billboard then
		data.billboard:Destroy()
		data.billboard = nil
	end

	if data.textLabel then
		data.textLabel:Destroy()
		data.textLabel = nil
	end
	if data.drawingLabel then
		NAmanage.DrawingRemoveObject(data.drawingLabel)
		data.drawingLabel = nil
	end

	if uid then
		for _, d in NAmanage.ESP_CollectTrackedBillboards(model, uid) do
			d:Destroy()
		end
	end
end

NAmanage.ESP_FirstBasePart = function(model)
	if not model or not model.Parent then return nil end
	for _, d in NAmanage.QueryDescendants(model, "BasePart") do
		return d
	end
	return nil
end

NAmanage.ESP_GetLabelWorldPosition = function(model)
	if not model then
		return nil
	end
	const head = getHead(model)
	if head and head:IsA("BasePart") then
		return head.Position + Vector3.new(0, (head.Size.Y * 0.5) + 0.5, 0)
	end
	const root = getRoot(model)
	if root and root:IsA("BasePart") then
		return root.Position + Vector3.new(0, (root.Size.Y * 0.5) + 2, 0)
	end
	const first = NAmanage.ESP_FirstBasePart(model)
	if first and first:IsA("BasePart") then
		return first.Position + Vector3.new(0, (first.Size.Y * 0.5) + 0.5, 0)
	end
	return nil
end

NAmanage.ESP_RemoveDrawingLabel = function(data)
	if not data then return end
	if data.drawingLabel then
		NAmanage.DrawingRemoveObject(data.drawingLabel)
		data.drawingLabel = nil
	end
end

NAmanage.ESP_EnsureDrawingLabel = function(model)
	const data = espCONS[model]
	if not data then
		return nil
	end
	if not NAmanage.DrawingTextSupported() then
		return nil
	end
	local label = data.drawingLabel
	if label then
		return label
	end
	label = NAmanage.DrawingCreateText("", Color3.new(1, 1, 1), NAStuff.ESP_LabelTextSize, {
		centered = NAStuff.ESP_DrawingTextCentered ~= false;
		font = NAStuff.ESP_DrawingTextFont;
		textTransparency = NAStuff.ESP_DrawingTextTransparency;
	})
	data.drawingLabel = label
	return label
end

NAmanage.ESP_UpdateDrawingLabel = function(model, text, color)
	const data = espCONS[model]
	if not data then return end
	const label = data.drawingLabel or NAmanage.ESP_EnsureDrawingLabel(model)
	if not label then return false end
	const worldPos = NAmanage.ESP_GetLabelWorldPosition(model)
	return NAmanage.DrawingUpdateText(label, worldPos, text, color, NAStuff.ESP_LabelTextSize, {
		centered = NAStuff.ESP_DrawingTextCentered ~= false;
		font = NAStuff.ESP_DrawingTextFont;
		textTransparency = NAStuff.ESP_DrawingTextTransparency;
	})
end

NAmanage.ESP_EnsureLabel = function(model)
	const data = espCONS[model]
	if not data then return end
	const owner = __lt.cm("Players", "GetPlayerFromCharacter", model)
	const forceLabel = owner and NAmanage.ESP_HasPlayerLabelOverride(owner) == true
	if chamsEnabled and not forceLabel then return end
	const renderTarget = (data.isNPC == true) and "npcs" or "players"
	if NAgui.espUsesDrawing(renderTarget) and NAmanage.DrawingTextSupported() then
		if data.billboard then
			data.billboard:Destroy()
			data.billboard = nil
		end
		if data.textLabel then
			data.textLabel:Destroy()
			data.textLabel = nil
		end
		NAmanage.ESP_EnsureDrawingLabel(model)
		return
	end
	NAmanage.ESP_RemoveDrawingLabel(data)

	if not data.uid then
		NAmanage._espLabelUidSeq = (tonumber(NAmanage._espLabelUidSeq) or 0) + 1
		data.uid = NAmanage.GetSessionInstanceName("ESPLabel_"..tostring(NAmanage._espLabelUidSeq))
	end
	const uid = data.uid

	local bb = data.billboard
	local tl = data.textLabel
	const anchor = getHead(model) or getRoot(model) or NAmanage.ESP_FirstBasePart(model)
	if not anchor then
		if bb then
			pcall(function()
				bb.Enabled = false
				bb.Adornee = nil
			end)
		end
		return
	end

	if bb and not bb:IsDescendantOf(game) then
		bb = nil
		tl = nil
		data.billboard = nil
		data.textLabel = nil
	end

	const list = NAmanage.ESP_CollectTrackedBillboards(model, uid)

	local keep = nil
	if bb and bb.Parent and NAmanage.GetAttr(bb, "NA_ESP_UID") == uid then
		keep = bb
	end
	if not keep and #list > 0 then
		keep = list[1]
	end
	for i = 1, #list do
		const inst = list[i]
		if inst ~= keep then
			inst:Destroy()
		end
	end

	if not keep then
		keep = InstanceNew("BillboardGui")
		NAmanage.SetAttr(keep, "NA_ESP_UID", uid)
		keep.Adornee = anchor
		keep.AlwaysOnTop = true
		keep.Size = UDim2.new(0,150,0,40)
		keep.StudsOffset = Vector3.new(0,2.5,0)
		NAmanage.ESP_StoreVisual(keep)

		tl = InstanceNew("TextLabel")
		tl.Size = UDim2.new(1,0,1,0)
		tl.BackgroundTransparency = 1
		tl.Font = Enum.Font.GothamBold
		tl.TextStrokeTransparency = 0.5
		tl.Text = ""
		tl.Parent = keep
		NAmanage.ESP_HardenVisual(tl)
	else
		if not (tl and tl.Parent == keep) then
			tl = keep:FindFirstChildWhichIsA("TextLabel")
			if not tl then
				tl = InstanceNew("TextLabel")
				tl.Size = UDim2.new(1,0,1,0)
				tl.BackgroundTransparency = 1
				tl.Font = Enum.Font.GothamBold
				tl.TextStrokeTransparency = 0.5
				tl.Text = ""
				tl.Parent = keep
			end
		end
	end

	if keep.Adornee ~= anchor then
		keep.Adornee = anchor
	end
	if keep.Enabled ~= true then
		keep.Enabled = true
	end
	NAmanage.ESP_StoreVisual(keep)
	NAmanage.ESP_HardenVisual(tl)

	NAgui.applyLabelStyle(tl)
	data.billboard = keep
	data.textLabel = tl
end

NAmanage.ESP_RemoveDrawing = function(data)
	if not data then return end
	if data.drawingBox then
		NAmanage.DrawingRemoveObject(data.drawingBox)
		data.drawingBox = nil
	end
	if data.drawingBoxOutline then
		NAmanage.DrawingRemoveObject(data.drawingBoxOutline)
		data.drawingBoxOutline = nil
	end
	if type(data.drawingCornerLines) == "table" then
		for i = 1, #data.drawingCornerLines do
			NAmanage.DrawingRemoveObject(data.drawingCornerLines[i])
		end
		data.drawingCornerLines = nil
	end
	if type(data.drawingCornerOutlineLines) == "table" then
		for i = 1, #data.drawingCornerOutlineLines do
			NAmanage.DrawingRemoveObject(data.drawingCornerOutlineLines[i])
		end
		data.drawingCornerOutlineLines = nil
	end
	if data.drawingTracer then
		NAmanage.DrawingRemoveObject(data.drawingTracer)
		data.drawingTracer = nil
	end
	if data.drawingTracerOutline then
		NAmanage.DrawingRemoveObject(data.drawingTracerOutline)
		data.drawingTracerOutline = nil
	end
end

NAmanage.ESP_DestroyInstance = function(inst)
	if inst and typeof(inst) == "Instance" then
		pcall(function()
			inst:Destroy()
		end)
	end
end

NAmanage.ESP_HideDrawingElements = function(data)
	if not data then return end
	const function hide(obj)
		if obj then
			pcall(function()
				obj.Visible = false
			end)
		end
	end
	hide(data.drawingBox)
	hide(data.drawingBoxOutline)
	hide(data.drawingTracer)
	hide(data.drawingTracerOutline)
	if type(data.drawingCornerLines) == "table" then
		for i = 1, #data.drawingCornerLines do
			hide(data.drawingCornerLines[i])
		end
	end
	if type(data.drawingCornerOutlineLines) == "table" then
		for i = 1, #data.drawingCornerOutlineLines do
			hide(data.drawingCornerOutlineLines[i])
		end
	end
end

NAmanage.ESP_SetModelVisualsEnabled = function(data, enabled)
	if not data then return end
	const state = enabled == true
	if data.billboard then
		pcall(function()
			data.billboard.Enabled = state
			if not state then
				data.billboard.Adornee = nil
			end
		end)
	end
	if data.highlight then
		pcall(function()
			data.highlight.Enabled = state
		end)
	end
	if data.charBox then
		pcall(function()
			data.charBox.Visible = state
		end)
	end
	for _, box in data.boxTable or {} do
		if box then
			pcall(function()
				box.Visible = state
			end)
		end
	end
	if not state and NAmanage.ESP_HideDrawingElements then
		NAmanage.ESP_HideDrawingElements(data)
	end
	if data.drawingLabel then
		pcall(function()
			data.drawingLabel.Visible = state
		end)
	end
end

NAmanage.ESP_GetDrawingBoxStyle = function()
	return NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingBoxStyle)
end

NAmanage.ESP_GetDrawingTracerOrigin = function(viewportSize)
	const vp = viewportSize or (Services.Workspace and Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize)
	if typeof(vp) ~= "Vector2" then
		return nil
	end
	const origin = NAgui.sanitizeESPDrawingTracerOrigin(NAStuff.ESP_DrawingTracerOrigin)
	if origin == "Top" then
		return Vector2.new(vp.X * 0.5, 18)
	end
	if origin == "Center" then
		return Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	end
	return Vector2.new(vp.X * 0.5, math.max(18, vp.Y - 18))
end

NAmanage.ESP_EnsureDrawingObjects = function(data)
	if not data then return nil end
	const style = NAmanage.ESP_GetDrawingBoxStyle()
	const wantCorners = style == "Corners" and NAmanage.DrawingLineSupported()
	const outlineEnabled = NAStuff.ESP_DrawingBoxOutline ~= false
	const tracerEnabled = NAStuff.ESP_DrawingTracerEnabled == true and NAmanage.DrawingLineSupported()
	const tracerOutlineEnabled = NAStuff.ESP_DrawingTracerOutline ~= false

	if wantCorners then
		if data.drawingBox then
			NAmanage.DrawingRemoveObject(data.drawingBox)
			data.drawingBox = nil
		end
		if data.drawingBoxOutline then
			NAmanage.DrawingRemoveObject(data.drawingBoxOutline)
			data.drawingBoxOutline = nil
		end
		if type(data.drawingCornerLines) ~= "table" then
			data.drawingCornerLines = {}
		end
		if outlineEnabled then
			if type(data.drawingCornerOutlineLines) ~= "table" then
				data.drawingCornerOutlineLines = {}
			end
		elseif type(data.drawingCornerOutlineLines) == "table" then
			for i = 1, #data.drawingCornerOutlineLines do
				NAmanage.DrawingRemoveObject(data.drawingCornerOutlineLines[i])
			end
			data.drawingCornerOutlineLines = nil
		end
		for i = 1, 8 do
			if not data.drawingCornerLines[i] then
				data.drawingCornerLines[i] = NAmanage.DrawingCreateLine(Color3.new(1, 1, 1), 1, 1)
			end
			if outlineEnabled and not data.drawingCornerOutlineLines[i] then
				data.drawingCornerOutlineLines[i] = NAmanage.DrawingCreateLine(Color3.new(0.1, 0.1, 0.1), 0.9, math.clamp(tonumber(NAStuff.ESP_DrawingBoxOutlineThickness) or 3, 1, 10))
			end
		end
	else
		if type(data.drawingCornerLines) == "table" then
			for i = 1, #data.drawingCornerLines do
				NAmanage.DrawingRemoveObject(data.drawingCornerLines[i])
			end
			data.drawingCornerLines = nil
		end
		if type(data.drawingCornerOutlineLines) == "table" then
			for i = 1, #data.drawingCornerOutlineLines do
				NAmanage.DrawingRemoveObject(data.drawingCornerOutlineLines[i])
			end
			data.drawingCornerOutlineLines = nil
		end
		if not data.drawingBox then
			data.drawingBox = NAmanage.DrawingCreateSquare(Color3.new(1, 1, 1), NAStuff.ESP_Transparency or 0.7, {
				filled = NAStuff.ESP_DrawingFilledBoxes == true;
				thickness = NAStuff.ESP_DrawingBoxThickness;
			})
		end
		if outlineEnabled then
			if not data.drawingBoxOutline then
				data.drawingBoxOutline = NAmanage.DrawingCreateSquare(Color3.new(0.1, 0.1, 0.1), 0.15, {
					thickness = NAStuff.ESP_DrawingBoxOutlineThickness;
				})
			end
		elseif data.drawingBoxOutline then
			NAmanage.DrawingRemoveObject(data.drawingBoxOutline)
			data.drawingBoxOutline = nil
		end
	end

	if tracerEnabled then
		if not data.drawingTracer then
			data.drawingTracer = NAmanage.DrawingCreateLine(Color3.new(1, 1, 1), 0.7, tonumber(NAStuff.ESP_DrawingTracerThickness) or 1)
		end
		if tracerOutlineEnabled then
			if not data.drawingTracerOutline then
				data.drawingTracerOutline = NAmanage.DrawingCreateLine(Color3.new(0.1, 0.1, 0.1), 0.55, (tonumber(NAStuff.ESP_DrawingTracerThickness) or 1) + 2)
			end
		elseif data.drawingTracerOutline then
			NAmanage.DrawingRemoveObject(data.drawingTracerOutline)
			data.drawingTracerOutline = nil
		end
	else
		if data.drawingTracer then
			NAmanage.DrawingRemoveObject(data.drawingTracer)
			data.drawingTracer = nil
		end
		if data.drawingTracerOutline then
			NAmanage.DrawingRemoveObject(data.drawingTracerOutline)
			data.drawingTracerOutline = nil
		end
	end

	return data.drawingBox or data.drawingBoxOutline or data.drawingTracer or data.drawingTracerOutline or (type(data.drawingCornerLines) == "table" and data.drawingCornerLines[1]) or (type(data.drawingCornerOutlineLines) == "table" and data.drawingCornerOutlineLines[1])
end

NAmanage.ESP_UpdateDrawingBox = function(data, inst, color, fillTransparency)
	if not data then
		return false
	end
	local minX, minY, width, height = NAgui.getInstanceViewportBounds(inst)
	if not minX then
		NAmanage.ESP_HideDrawingElements(data)
		return true
	end

	const alpha = NAgui.toDrawingTransparency(fillTransparency or 0.7)
	const mainThickness = math.max(1, tonumber(NAStuff.ESP_DrawingBoxThickness) or 1)
	const outlineEnabled = NAStuff.ESP_DrawingBoxOutline ~= false
	const outlineThickness = math.max(1, tonumber(NAStuff.ESP_DrawingBoxOutlineThickness) or (mainThickness + 2))
	const style = NAmanage.ESP_GetDrawingBoxStyle()

	if style == "Corners" and type(data.drawingCornerLines) == "table" then
		if data.drawingBox then pcall(function() data.drawingBox.Visible = false end) end
		if data.drawingBoxOutline then pcall(function() data.drawingBoxOutline.Visible = false end) end
		const scale = math.clamp(tonumber(NAStuff.ESP_DrawingCornerScale) or 0.25, 0.05, 0.5)
		const segX = math.max(4, width * scale)
		const segY = math.max(4, height * scale)
		const points = {
			{ Vector2.new(minX, minY), Vector2.new(minX + segX, minY) },
			{ Vector2.new(minX + width, minY), Vector2.new(minX + width - segX, minY) },
			{ Vector2.new(minX, minY + height), Vector2.new(minX + segX, minY + height) },
			{ Vector2.new(minX + width, minY + height), Vector2.new(minX + width - segX, minY + height) },
			{ Vector2.new(minX, minY), Vector2.new(minX, minY + segY) },
			{ Vector2.new(minX + width, minY), Vector2.new(minX + width, minY + segY) },
			{ Vector2.new(minX, minY + height), Vector2.new(minX, minY + height - segY) },
			{ Vector2.new(minX + width, minY + height), Vector2.new(minX + width, minY + height - segY) },
		}
		if #data.drawingCornerLines < 8 then
			for i = #data.drawingCornerLines + 1, 8 do
				data.drawingCornerLines[i] = NAmanage.DrawingCreateLine(Color3.new(1, 1, 1), alpha, mainThickness)
			end
		end
		if outlineEnabled then
			if type(data.drawingCornerOutlineLines) ~= "table" then
				data.drawingCornerOutlineLines = {}
			end
			if #data.drawingCornerOutlineLines < 8 then
				for i = #data.drawingCornerOutlineLines + 1, 8 do
					data.drawingCornerOutlineLines[i] = NAmanage.DrawingCreateLine(Color3.new(0.1, 0.1, 0.1), math.min(1, alpha + 0.15), outlineThickness)
				end
			end
		elseif type(data.drawingCornerOutlineLines) == "table" then
			for i = 1, #data.drawingCornerOutlineLines do
				pcall(function() data.drawingCornerOutlineLines[i].Visible = false end)
			end
		end
		for i = 1, 8 do
			const seg = points[i]
			if outlineEnabled and data.drawingCornerOutlineLines and data.drawingCornerOutlineLines[i] then
				if not NAmanage.DrawingUpdateLine(data.drawingCornerOutlineLines[i], seg[1], seg[2], Color3.new(0.1, 0.1, 0.1), math.min(1, alpha + 0.15), outlineThickness) then
					return false
				end
			end
			if not NAmanage.DrawingUpdateLine(data.drawingCornerLines[i], seg[1], seg[2], color, alpha, mainThickness) then
				return false
			end
		end
		return true
	end

	if type(data.drawingCornerLines) == "table" then
		for i = 1, #data.drawingCornerLines do
			pcall(function()
				data.drawingCornerLines[i].Visible = false
			end)
		end
	end
	if type(data.drawingCornerOutlineLines) == "table" then
		for i = 1, #data.drawingCornerOutlineLines do
			pcall(function()
				data.drawingCornerOutlineLines[i].Visible = false
			end)
		end
	end
	local ok = true
	if data.drawingBoxOutline then
		if outlineEnabled then
			ok = NAmanage.DrawingUpdateSquare(data.drawingBoxOutline, inst, Color3.new(0.1, 0.1, 0.1), 0.15, {
				filled = false;
				thickness = outlineThickness;
			}) and ok
		else
			pcall(function() data.drawingBoxOutline.Visible = false end)
		end
	end
	if data.drawingBox then
		ok = NAmanage.DrawingUpdateSquare(data.drawingBox, inst, color, fillTransparency, {
			filled = NAStuff.ESP_DrawingFilledBoxes == true;
			thickness = mainThickness;
		}) and ok
	end
	return ok
end

NAmanage.ESP_UpdateDrawingTracer = function(data, inst, color)
	if not data then
		return false
	end
	if NAStuff.ESP_DrawingTracerEnabled ~= true then
		if data.drawingTracer then pcall(function() data.drawingTracer.Visible = false end) end
		if data.drawingTracerOutline then pcall(function() data.drawingTracerOutline.Visible = false end) end
		return true
	end
	const cam = Services.Workspace and Services.Workspace.CurrentCamera
	if not cam then
		return false
	end
	local minX, minY, width, height = NAgui.getInstanceViewportBounds(inst, cam)
	if not minX then
		if data.drawingTracer then pcall(function() data.drawingTracer.Visible = false end) end
		if data.drawingTracerOutline then pcall(function() data.drawingTracerOutline.Visible = false end) end
		return true
	end
	const fromPos = NAmanage.ESP_GetDrawingTracerOrigin(cam.ViewportSize)
	const target = NAgui.sanitizeESPDrawingTracerTarget(NAStuff.ESP_DrawingTracerTarget)
	local targetY = minY + height
	if target == "Top" then
		targetY = minY
	elseif target == "Center" then
		targetY = minY + height * 0.5
	end
	const toPos = Vector2.new(minX + width * 0.5, targetY)
	const thickness = math.max(1, tonumber(NAStuff.ESP_DrawingTracerThickness) or 1)
	const alpha = math.clamp(0.75, 0, 1)
	local ok = true
	if data.drawingTracerOutline then
		if NAStuff.ESP_DrawingTracerOutline ~= false then
			ok = NAmanage.DrawingUpdateLine(data.drawingTracerOutline, fromPos, toPos, Color3.new(0.1, 0.1, 0.1), math.max(0, alpha - 0.15), thickness + 2) and ok
		else
			pcall(function() data.drawingTracerOutline.Visible = false end)
		end
	end
	if data.drawingTracer then
		ok = NAmanage.DrawingUpdateLine(data.drawingTracer, fromPos, toPos, color, alpha, thickness) and ok
	end
	return ok
end

NAmanage.ESP_EnsureDrawing = function(data)
	if not data then return nil end
	return NAmanage.ESP_EnsureDrawingObjects(data)
end

NAmanage.ESP_RecoverFromDrawingFailure = function(model, data)
	data = data or espCONS[model]
	if not data then
		return
	end
	NAmanage.ESP_RemoveDrawing(data)
	NAmanage.ESP_RemoveDrawingLabel(data)
	data.boxEnabled = false
	if model then
		NAmanage.ESP_AddBoxes(model)
		NAmanage.ESP_EnsureLabel(model)
	end
end

NAmanage.ESP_RequestVisualRebuild = function()
	if NAStuff._espVisualRebuildPending == true then
		return
	end
	NAStuff._espVisualRebuildPending = true
	Defer(function()
		NAStuff._espVisualRebuildPending = false
		NAmanage.ESP_RebuildVisuals()
	end)
end

NAmanage.ESP_AddBoxForPart = function(model, part)
	const data = espCONS[model]
	if not data or data.isNPC or not part or not part:IsA("BasePart") then return end
	if data.boxTable[part] then return end
	if NAgui.espUsesHighlight("players") or NAgui.espUsesDrawing("players") or NAgui.espUsesCharacterBox("players") then return end
	const box = InstanceNew("BoxHandleAdornment")
	box.Adornee = part
	box.AlwaysOnTop = true
	box.ZIndex = 1
	box.Transparency = NAgui.sanitizeTransparency(NAStuff.ESP_Transparency or 0.7)
	box.Size = part.Size
	box.Color3 = Color3.new(1,1,1)
	NAmanage.ESP_StoreVisual(box)
	data.boxTable[part] = box
end

NAmanage.ESP_RemoveCharacterBox = function(data)
	if not data then return end
	const box = data.charBox
	if typeof(box) == "Instance" then
		pcall(function()
			box:Destroy()
		end)
	end
	data.charBox = nil
end

NAmanage.ESP_GetCharacterBoxAdornee = function(model)
	if not (model and model.Parent) then return nil end
	const root = getRoot(model)
	if root and root:IsA("BasePart") then
		return root
	end
	const primary = model.PrimaryPart
	if primary and primary:IsA("BasePart") and primary.Parent then
		return primary
	end
	return NAmanage.ESP_FirstBasePart(model)
end

NAmanage.ESP_EnsureCharacterBox = function(data)
	if not data then return nil end
	local box = data.charBox
	if typeof(box) == "Instance" and box.Parent and box:IsA("BoxHandleAdornment") then
		NAmanage.ESP_StoreVisual(box)
		return box
	end
	if typeof(box) == "Instance" then
		pcall(function()
			box:Destroy()
		end)
	end
	box = InstanceNew("BoxHandleAdornment")
	box.AlwaysOnTop = true
	box.ZIndex = 1
	box.Transparency = NAgui.sanitizeTransparency(NAStuff.ESP_Transparency or 0.7)
	box.Color3 = Color3.new(1, 1, 1)
	box.Size = Vector3.new(1, 1, 1)
	NAmanage.ESP_StoreVisual(box)
	data.charBox = box
	return box
end

NAmanage.ESP_UpdateCharacterBox = function(model, data, color, transparency)
	data = data or espCONS[model]
	if not data then return false end
	const root = NAmanage.ESP_GetCharacterBoxAdornee(model)
	if not root then
		NAmanage.ESP_RemoveCharacterBox(data)
		return false
	end
	local ok, cf, size = pcall(model.GetBoundingBox, model)
	if not (ok and typeof(cf) == "CFrame" and typeof(size) == "Vector3") then
		return false
	end
	const box = NAmanage.ESP_EnsureCharacterBox(data)
	if not box then return false end
	const rel = root.CFrame:ToObjectSpace(cf)
	if box.Adornee ~= root then box.Adornee = root end
	if box.CFrame ~= rel then box.CFrame = rel end
	if box.Size ~= size then box.Size = size end
	if box.Color3 ~= color then box.Color3 = color end
	const tr = NAgui.sanitizeTransparency(transparency or NAStuff.ESP_Transparency or 0.7)
	if box.Transparency ~= tr then box.Transparency = tr end
	NAmanage.ESP_StoreVisual(box)
	return true
end

NAmanage.ESP_AddBoxes = function(model)
	const data = espCONS[model]
	if not data then return end
	const renderMode = data.isNPC and NAgui.getESPRenderMode("npcs") or NAgui.getESPRenderMode("players")

	if renderMode == "Drawing API" then
		NAmanage.ESP_RemoveCharacterBox(data)
		for part, box in data.boxTable do
			if box then box:Destroy() end
			data.boxTable[part] = nil
		end
		if data.highlight then
			NAmanage.ESP_AdjustHighlightMaterial(model, false)
			data.highlight:Destroy()
			data.highlight = nil
		end
		NAmanage.ESP_EnsureDrawing(data)
		data.boxEnabled = true
		return
	end

	NAmanage.ESP_RemoveDrawing(data)

	if renderMode == "Highlight" then
		NAmanage.ESP_RemoveCharacterBox(data)
		local highlight = data.highlight
		if highlight and not highlight.Parent then
			highlight = nil
		end

		if not highlight then
			const hl = InstanceNew("Highlight")
			hl.Name = "NAESP_Highlight"
			hl.Adornee = model
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

			const baseColor = (NAStuff.ESP_UseCustomColor == true and typeof(NAStuff.ESP_CustomColor) == "Color3")
				and NAStuff.ESP_CustomColor
				or Color3.new(1, 1, 1)

			const outline = NAgui.sanitizeTransparency(NAStuff.ESP_OutlineTransparency or 0)

			hl.FillColor = baseColor
			hl.OutlineColor = baseColor
			hl.FillTransparency = NAgui.sanitizeTransparency(NAStuff.ESP_Transparency or 0.7)
			hl.OutlineTransparency = outline
			NAmanage.ESP_StoreVisual(hl)

			data.highlight = hl
			NAmanage.ESP_AdjustHighlightMaterial(model, true)
		else
			data.highlight = highlight
		end

		if data.highlight then
			data.highlight.Enabled = true
			data.highlight.OutlineTransparency = NAgui.sanitizeTransparency(NAStuff.ESP_OutlineTransparency or 0)
		end

		data.boxEnabled = true
		return
	end

	if renderMode == "Character Box" then
		NAmanage.ESP_RemoveDrawing(data)
		for part, box in data.boxTable do
			if box then box:Destroy() end
			data.boxTable[part] = nil
		end
		if data.highlight then
			NAmanage.ESP_AdjustHighlightMaterial(model, false)
			data.highlight:Destroy()
			data.highlight = nil
		end
		NAmanage.ESP_UpdateCharacterBox(model, data, Color3.new(1, 1, 1), NAStuff.ESP_Transparency or 0.7)
		data.boxEnabled = true
		return
	end

	NAmanage.ESP_RemoveCharacterBox(data)
	for _, part in NAmanage.QueryDescendants(model, "BasePart") do
		NAmanage.ESP_AddBoxForPart(model, part)
	end

	data.boxEnabled = true
end

NAmanage.ESP_RemoveBoxes = function(model)
	const data = espCONS[model]
	if not data then return end
	NAmanage.ESP_RemoveDrawing(data)
	NAmanage.ESP_RemoveCharacterBox(data)
	for part, box in data.boxTable do
		if box and typeof(box) == "Instance" then
			pcall(function()
				box:Destroy()
			end)
		end
		data.boxTable[part] = nil
	end
	if data.highlight and typeof(data.highlight) == "Instance" then
		NAmanage.ESP_AdjustHighlightMaterial(model, false)
		pcall(function()
			data.highlight:Destroy()
		end)
	end
	data.highlight = nil
	data.boxEnabled = false
end

NAmanage.ESP_ClearModel = function(model)
	if not model then return end
	const key = NAmanage.ESP_Key(model)
	NAlib.disconnect(key.."_descAdded")
	NAlib.disconnect(key.."_descRemoved")
	NAlib.disconnect(key.."_ancestry")
	NAlib.disconnect(key.."_charAdded")
	NAmanage.ESP_PlayerLocatorRemoveArrow(model)
	NAmanage.ESP_UnregisterModel(model)
	NAmanage.ESP_RemoveBoxes(model)
	NAmanage.ESP_DestroyLabel(model)
	espCONS[model] = nil
end

NAStuff.ESP_ReattachCooldown = NAStuff.ESP_ReattachCooldown or {}
NAStuff.ESP_ReattachTokens = NAStuff.ESP_ReattachTokens or {}
NAStuff.ESP_ReattachPending = NAStuff.ESP_ReattachPending or {}
NAStuff.ESP_WatchedCharacterByUserId = NAStuff.ESP_WatchedCharacterByUserId or {}
NAStuff.ESP_PlayerReconcileInterval = tonumber(NAStuff.ESP_PlayerReconcileInterval) or 0.35
NAStuff.ESP_PlayerReconcileClock = tonumber(NAStuff.ESP_PlayerReconcileClock) or 0

NAmanage.ESP_PlayerConnKey = function(prefix, player)
	local id = "unknown"
	if typeof(player) == "Instance" and player:IsA("Player") then
		const uid = tonumber(player.UserId)
		if uid and uid > 0 then
			id = tostring(uid)
		else
			id = tostring(player.Name or id)
		end
	end
	return tostring(prefix).."_"..id
end

NAmanage.ESP_NormalizePlayerTargetMode = function(mode)
	mode = Lower(tostring(mode or "all"))
	if mode == "enemy" or mode == "enemies" or mode == "nonteam" or mode == "nonteams" or mode == "noteam" or mode == "noteams" or mode == "notteam" then
		return "enemies"
	end
	if mode == "ally" or mode == "allies" or mode == "team" or mode == "teammates" or mode == "mates" then
		return "allies"
	end
	if mode == "teamname" or mode == "specificteam" or mode == "teamfilter" then
		return "teamname"
	end
	return "all"
end

NAmanage.ESP_SetPlayerTargetMode = function(mode, teamPrefix, opts)
	mode = NAmanage.ESP_NormalizePlayerTargetMode(mode)
	NAStuff.ESP_PlayerTargetMode = mode
	if teamPrefix ~= nil then
		NAStuff.ESP_TargetTeam = tostring(teamPrefix or ""):match("^%s*(.-)%s*$") or ""
	elseif mode ~= "teamname" then
		NAStuff.ESP_TargetTeam = ""
	end
	if opts and opts.forceAll == true then
		NAStuff.ESP_IgnoreTeam = false
	elseif mode == "enemies" then
		NAStuff.ESP_IgnoreTeam = true
	end
	if type(NAmanage.SaveESPSettings) == "function" and opts and opts.save == true then
		pcall(NAmanage.SaveESPSettings)
	end
end

NAmanage.ESP_PlayerTeamNameMatchesPrefix = NAmanage.ESP_PlayerTeamNameMatchesPrefix or function(player, targetPrefix)
	targetPrefix = Lower(tostring(targetPrefix or ""))
	if targetPrefix == "" then
		return true
	end
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return false
	end
	const team = player.Team
	const teamName = team and Lower(tostring(team.Name or "")) or ""
	return teamName:sub(1, #targetPrefix) == targetPrefix
end

NAmanage.ESP_PlayerPassesTeamFilter = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return false
	end
	if player == Services.Players.LocalPlayer then
		return false
	end

	const targetPrefix = Lower(tostring(NAStuff.ESP_TargetTeam or ""))
	if targetPrefix ~= "" then
		if not NAmanage.ESP_PlayerTeamNameMatchesPrefix(player, targetPrefix) then
			return false
		end
		if NAStuff.ESP_IgnoreTeam == true and NAmanage.PlayerArgSameTeam(player) then
			return false
		end
		return true
	end

	const mode = NAmanage.ESP_NormalizePlayerTargetMode(NAStuff.ESP_PlayerTargetMode)
	if mode == "enemies" then
		return NAmanage.PlayerArgNonTeam(player)
	elseif mode == "allies" then
		return NAmanage.PlayerArgSameTeam(player)
	end

	if NAStuff.ESP_IgnoreTeam == true and NAmanage.PlayerArgSameTeam(player) then
		return false
	end
	return true
end

NAmanage.ESP_IsStaffwatchOwnedPlayer = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return false
	end
	const state = NAStuff and NAStuff.StaffwatchState
	if type(state) ~= "table" or state.active ~= true or type(state.staffPlayers) ~= "table" then
		return false
	end
	return state.staffPlayers[tostring(player.UserId)] == true
end


NAmanage.ESP_ShouldTrackPlayer = function(player)
	if not ((ESPPlayersEnabled or chamsEnabled) == true) then
		return false
	end
	if not (typeof(player) == "Instance" and player:IsA("Player") and player.Parent ~= nil and player ~= Services.Players.LocalPlayer) then
		return false
	end
	if NAStuff.StaffwatchOverrideESP ~= false and NAmanage.ESP_IsStaffwatchOwnedPlayer(player) then
		return false
	end
	if NAmanage.ESP_HasPlayerLabelOverride and NAmanage.ESP_HasPlayerLabelOverride(player) == true then
		return true
	end
	if ESPPlayersEnabled and not chamsEnabled and ESPAutoTrackAll ~= true then
		return false
	end
	return NAmanage.ESP_PlayerPassesTeamFilter(player)
end

NAmanage.ESP_RefreshPlayerTeamFilters = NAmanage.ESP_RefreshPlayerTeamFilters or function()
	if not (ESPPlayersEnabled or chamsEnabled) then
		return
	end
	for _, plr in __lt.cm("Players", "GetPlayers") do
		if plr ~= Services.Players.LocalPlayer then
			if NAmanage.ESP_ShouldTrackPlayer(plr) then
				if ESPAutoTrackAll or NAmanage.ESP_HasPlayerLabelOverride(plr) == true then
					const model = plr.Character
					if not (model and espCONS[model]) then
						NAmanage.ESP_Add(plr, true)
					end
				end
			else
				const model = plr.Character
				if model and espCONS[model] then
					NAmanage.ESP_ClearModel(model)
				end
			end
		end
	end
end

NAmanage.ESP_BumpReattachToken = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return nil, nil
	end
	const uid = tonumber(player.UserId)
	if not uid or uid <= 0 then
		return nil, nil
	end
	const key = tostring(uid)
	const token = (tonumber(NAStuff.ESP_ReattachTokens[key]) or 0) + 1
	NAStuff.ESP_ReattachTokens[key] = token
	return key, token
end

NAmanage.ESP_DisconnectPlayerWatch = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return
	end
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_charAdded_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_charRemoving_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_charChanged_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_charParent_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_charDescAdded_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_charDescRemoving_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_teamChanged_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_teamColorChanged_plr", player))
	NAlib.disconnect(NAmanage.ESP_PlayerConnKey("esp_neutralChanged_plr", player))
	const uid = tonumber(player.UserId)
	if uid and uid > 0 then
		NAStuff.ESP_ReattachPending[uid] = nil
		NAStuff.ESP_WatchedCharacterByUserId[uid] = nil
	end
	NAmanage.ESP_BumpReattachToken(player)
end

NAmanage.ESP_WatchPlayerCharacter = function(player, model)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return
	end
	const parentKey = NAmanage.ESP_PlayerConnKey("esp_charParent_plr", player)
	const addKey = NAmanage.ESP_PlayerConnKey("esp_charDescAdded_plr", player)
	const removeKey = NAmanage.ESP_PlayerConnKey("esp_charDescRemoving_plr", player)
	NAlib.disconnect(parentKey)
	NAlib.disconnect(addKey)
	NAlib.disconnect(removeKey)
	if not (typeof(model) == "Instance" and model:IsA("Model")) then
		return
	end
	const uid = tonumber(player.UserId)
	if uid and uid > 0 then
		NAStuff.ESP_WatchedCharacterByUserId[uid] = model
	end
	const function refresh(force)
		if not NAmanage.ESP_ShouldTrackPlayer(player) then
			return
		end
		if player.Character ~= model then
			NAmanage.ESP_WatchPlayerCharacter(player, player.Character)
			NAmanage.ESP_RequestReattachPlayer(player, force == true)
			return
		end
		if Services.Workspace and model.Parent and model:IsDescendantOf(Services.Workspace) then
			const data = espCONS[model]
			if NAmanage.IsValidESPModel(model, false) then
				if not data then
					NAmanage.ESP_RequestReattachPlayer(player, force == true)
				else
					data.next = 0
				end
			elseif data then
				data.next = 0
				if NAmanage.ESP_SetModelVisualsEnabled then
					NAmanage.ESP_SetModelVisualsEnabled(data, false)
				end
			end
		else
			if espCONS[model] then
				NAmanage.ESP_ClearModel(model)
			end
			NAmanage.ESP_RequestReattachPlayer(player, force == true)
		end
	end
	NAlib.connect(parentKey, model.AncestryChanged:Connect(function()
		refresh(true)
	end))
	NAlib.connect(addKey, model.DescendantAdded:Connect(function(desc)
		if desc:IsA("BasePart") or desc:IsA("Humanoid") then
			Defer(function()
				refresh(true)
			end)
		end
	end))
	NAlib.connect(removeKey, model.DescendantRemoving:Connect(function(desc)
		if desc:IsA("BasePart") or desc:IsA("Humanoid") then
			Defer(function()
				refresh(false)
			end)
		end
	end))
	refresh(true)
end

NAmanage.ESP_SetupPlayerWatch = function(player)
	if not (typeof(player) == "Instance" and player:IsA("Player")) then
		return
	end
	if player == Services.Players.LocalPlayer then
		return
	end
	const addKey = NAmanage.ESP_PlayerConnKey("esp_charAdded_plr", player)
	const remKey = NAmanage.ESP_PlayerConnKey("esp_charRemoving_plr", player)
	const chKey = NAmanage.ESP_PlayerConnKey("esp_charChanged_plr", player)
	const teamKey = NAmanage.ESP_PlayerConnKey("esp_teamChanged_plr", player)
	const teamColorKey = NAmanage.ESP_PlayerConnKey("esp_teamColorChanged_plr", player)
	const neutralKey = NAmanage.ESP_PlayerConnKey("esp_neutralChanged_plr", player)
	NAlib.disconnect(addKey)
	NAlib.disconnect(remKey)
	NAlib.disconnect(chKey)
	NAlib.disconnect(teamKey)
	NAlib.disconnect(teamColorKey)
	NAlib.disconnect(neutralKey)

	const function refresh(force)
		if not (ESPPlayersEnabled or chamsEnabled) then
			return
		end
		if not (player and player.Parent) then
			NAmanage.ESP_DisconnectPlayerWatch(player)
			return
		end
		if NAmanage.ESP_ShouldTrackPlayer(player) then
			const model = player.Character
			if typeof(model) == "Instance" and model:IsA("Model") then
				NAmanage.ESP_WatchPlayerCharacter(player, model)
			end
			NAmanage.ESP_RequestReattachPlayer(player, force == true)
		else
			const model = player.Character
			if model and espCONS[model] then
				NAmanage.ESP_ClearModel(model)
			end
		end
	end

	NAlib.connect(addKey, player.CharacterAdded:Connect(function()
		refresh(true)
	end))
	NAlib.connect(remKey, player.CharacterRemoving:Connect(function(model)
		if model and espCONS[model] then
			NAmanage.ESP_ClearModel(model)
		end
	end))
	NAlib.connect(chKey, player:GetPropertyChangedSignal("Character"):Connect(function()
		refresh(true)
	end))
	NAlib.connect(teamKey, player:GetPropertyChangedSignal("Team"):Connect(function()
		refresh(true)
	end))
	NAlib.connect(teamColorKey, player:GetPropertyChangedSignal("TeamColor"):Connect(function()
		refresh(true)
	end))
	NAlib.connect(neutralKey, player:GetPropertyChangedSignal("Neutral"):Connect(function()
		refresh(true)
	end))

	if player.Character and NAmanage.ESP_ShouldTrackPlayer(player) then
		NAmanage.ESP_WatchPlayerCharacter(player, player.Character)
	end
end

NAmanage.ESP_StopPlayerRosterWatch = NAmanage.ESP_StopPlayerRosterWatch or function()
	NAlib.disconnect("esp_roster_player_added")
	NAlib.disconnect("esp_roster_player_removing")
	NAlib.disconnect("esp_local_team_changed")
	NAlib.disconnect("esp_local_teamcolor_changed")
	NAlib.disconnect("esp_local_neutral_changed")
end

NAmanage.ESP_StartPlayerRosterWatch = NAmanage.ESP_StartPlayerRosterWatch or function()
	NAmanage.ESP_StopPlayerRosterWatch()

	const function refreshAll()
		if not (ESPPlayersEnabled or chamsEnabled) then
			return
		end
		if NAmanage.ESP_RefreshPlayerTeamFilters then
			NAmanage.ESP_RefreshPlayerTeamFilters()
		end
	end

	NAlib.connect("esp_roster_player_added", Services.Players.PlayerAdded:Connect(function(player)
		Defer(function()
			if not (ESPPlayersEnabled or chamsEnabled) then
				return
			end
			NAmanage.ESP_SetupPlayerWatch(player)
			if NAmanage.ESP_ShouldTrackPlayer(player) then
				NAmanage.ESP_RequestReattachPlayer(player, true)
			end
		end)
	end))

	NAlib.connect("esp_roster_player_removing", Services.Players.PlayerRemoving:Connect(function(player)
		const model = player and player.Character
		if model and espCONS[model] then
			NAmanage.ESP_ClearModel(model)
		end
		if player then
			NAmanage.ESP_DisconnectPlayerWatch(player)
		end
	end))

	const lp = Services.Players.LocalPlayer
	if typeof(lp) == "Instance" and lp:IsA("Player") then
		NAlib.connect("esp_local_team_changed", lp:GetPropertyChangedSignal("Team"):Connect(refreshAll))
		NAlib.connect("esp_local_teamcolor_changed", lp:GetPropertyChangedSignal("TeamColor"):Connect(refreshAll))
		NAlib.connect("esp_local_neutral_changed", lp:GetPropertyChangedSignal("Neutral"):Connect(refreshAll))
	end
end

NAmanage.ESP_GetTrackedModels = function(predicate)
	const list = {}
	for model, data in espCONS do
		if predicate == nil or predicate(model, data) then
			list[#list + 1] = model
		end
	end
	return list
end

NAmanage.ESP_GetPlayerCharacterSet = function()
	const characters = {}
	for model, data in espCONS do
		if data and data.isNPC ~= true and typeof(model) == "Instance" then
			characters[model] = true
		end
	end
	for _, plr in __lt.cm("Players", "GetPlayers") do
		if plr ~= Services.Players.LocalPlayer then
			const char = plr and plr.Character
			if typeof(char) == "Instance" then
				characters[char] = true
			end
			const uid = plr and tonumber(plr.UserId)
			const watched = uid and NAStuff.ESP_WatchedCharacterByUserId and NAStuff.ESP_WatchedCharacterByUserId[uid] or nil
			if typeof(watched) == "Instance" then
				characters[watched] = true
			end
		end
	end
	return characters
end

NAmanage.ESP_AdorneeBelongsToCharacterSet = function(inst, characters)
	if typeof(inst) ~= "Instance" or type(characters) ~= "table" then
		return false
	end
	local ok, adornee = pcall(function()
		return inst.Adornee
	end)
	if not (ok and typeof(adornee) == "Instance") then
		return false
	end
	for character in characters do
		if adornee == character or (adornee.Parent and adornee:IsDescendantOf(character)) then
			return true
		end
	end
	return false
end

NAmanage.ESP_IsKnownPartVisual = function(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	if NAmanage.GetAttr(inst, "NA_StaffwatchVisual") == true then
		return true
	end
	if type(NAStuff.partESPVisualMap) == "table" and NAStuff.partESPVisualMap[inst] then
		return true
	end
	if type(NAStuff.partESPEntries) == "table" and NAStuff.partESPEntries[inst] then
		return true
	end
	const name = tostring(inst.Name or "")
	if Sub(name, -7) == "_peepee" then
		return true
	end
	if inst:IsA("BillboardGui") and Sub(Lower(name), -6) == "_label" and not NAmanage.GetAttr(inst, "NA_ESP_UID") then
		return true
	end
	return false
end

NAmanage.ESP_ClearPlayerOrphanVisuals = function(characters)
	const container = NAStuff and NAStuff.ESP_SecureContainer
	if not (container and container.Parent and type(characters) == "table" and next(characters) ~= nil) then
		return
	end
	for _, child in container:GetChildren() do
		if (child:IsA("Highlight") or child:IsA("BoxHandleAdornment") or child:IsA("BillboardGui"))
			and not NAmanage.ESP_IsKnownPartVisual(child)
			and NAmanage.ESP_AdorneeBelongsToCharacterSet(child, characters) then
			pcall(function()
				child:Destroy()
			end)
		end
	end
end

NAmanage.ESP_ClearAll = function()
	const models = NAmanage.ESP_GetTrackedModels()
	for i = 1, #models do
		NAmanage.ESP_ClearModel(models[i])
	end
	for _, plr in __lt.cm("Players", "GetPlayers") do
		NAmanage.ESP_DisconnectPlayerWatch(plr)
	end
	if NAmanage.ESP_StopPlayerRosterWatch then
		NAmanage.ESP_StopPlayerRosterWatch()
	end
	NAStuff.ESP_ModelList = {}
	NAlib.disconnect("esp_update_global")
	ESPPlayersEnabled = false
	NPCESPenabled = false
	NAmanage.ESP_ClearPlayerLabelOverrides()
	NAmanage.ESP_RecomputeEnabled()
end

NAmanage.ESP_ClearPlayers = function()
	const characters = NAmanage.ESP_GetPlayerCharacterSet()
	const models = NAmanage.ESP_GetTrackedModels(function(_, data)
		return not (data and data.isNPC)
	end)
	for i = 1, #models do
		NAmanage.ESP_ClearModel(models[i])
	end
	NAmanage.ESP_ClearPlayerOrphanVisuals(characters)
	for _, plr in __lt.cm("Players", "GetPlayers") do
		NAmanage.ESP_DisconnectPlayerWatch(plr)
	end
	if NAmanage.ESP_StopPlayerRosterWatch then
		NAmanage.ESP_StopPlayerRosterWatch()
	end
end

NAmanage.ESP_Disconnect = function(target)
	const model = (target and target:IsA("Player")) and target.Character or target
	if typeof(target) == "Instance" and target:IsA("Player") then
		NAmanage.ESP_SetPlayerLabelOverride(target, false)
		NAmanage.ESP_DisconnectPlayerWatch(target)
	end
	NAmanage.ESP_ClearModel(model)
end

NAmanage.ESP_RequestReattachPlayer = function(player, force)
	if not NAmanage.ESP_ShouldTrackPlayer(player) then
		return
	end
	const uid = tonumber(player.UserId)
	if not uid or uid <= 0 then
		return
	end
	if NAStuff.ESP_ReattachPending[uid] then
		return
	end
	const now = tick()
	const last = tonumber(NAStuff.ESP_ReattachCooldown[uid]) or 0
	if force ~= true and now - last < 0.15 then
		return
	end
	NAStuff.ESP_ReattachCooldown[uid] = now
	local tokenKey, token = NAmanage.ESP_BumpReattachToken(player)
	if not tokenKey then
		return
	end
	NAStuff.ESP_ReattachPending[uid] = token
	Spawn(function()
		while NAStuff.ESP_ReattachPending[uid] == token and NAStuff.ESP_ReattachTokens[tokenKey] == token do
			if not NAmanage.ESP_ShouldTrackPlayer(player) then
				break
			end
			const model = player.Character
			if typeof(model) == "Instance" and model:IsA("Model") then
				const parentKey = NAmanage.ESP_PlayerConnKey("esp_charParent_plr", player)
				if not NAlib.isConnected(parentKey) or NAStuff.ESP_WatchedCharacterByUserId[uid] ~= model then
					NAmanage.ESP_WatchPlayerCharacter(player, model)
				end
				if Services.Workspace and model.Parent and model:IsDescendantOf(Services.Workspace) and NAmanage.IsValidESPModel(model, false) then
					if not espCONS[model] then
						NAmanage.ESP_Add(player, true, false)
					end
					break
				end
			end
			Wait(0.2)
		end
		if NAStuff.ESP_ReattachPending[uid] == token then
			NAStuff.ESP_ReattachPending[uid] = nil
		end
	end)
end

NAmanage.ESP_ReconcilePlayers = function(now)
	if not (ESPPlayersEnabled or chamsEnabled) then
		return
	end
	now = tonumber(now) or tick()
	const interval = math.max(0.1, tonumber(NAStuff.ESP_PlayerReconcileInterval) or 0.35)
	if now - (tonumber(NAStuff.ESP_PlayerReconcileClock) or 0) < interval then
		return
	end
	NAStuff.ESP_PlayerReconcileClock = now
	const stale = {}
	for model, data in espCONS do
		if data and data.isNPC ~= true and data.persistent == true then
			const owner = data.ownerPlayer
			if not (owner and owner.Parent and NAmanage.ESP_ShouldTrackPlayer(owner) and owner.Character == model and model.Parent and Services.Workspace and model:IsDescendantOf(Services.Workspace)) then
				stale[#stale + 1] = model
			end
		end
	end
	for i = 1, #stale do
		NAmanage.ESP_ClearModel(stale[i])
	end
	for _, player in __lt.cm("Players", "GetPlayers") do
		if player ~= Services.Players.LocalPlayer then
			const addKey = NAmanage.ESP_PlayerConnKey("esp_charAdded_plr", player)
			if not NAlib.isConnected(addKey) then
				NAmanage.ESP_SetupPlayerWatch(player)
			end
			if NAmanage.ESP_ShouldTrackPlayer(player) then
				const model = player.Character
				if typeof(model) == "Instance" and model:IsA("Model") then
					const parentKey = NAmanage.ESP_PlayerConnKey("esp_charParent_plr", player)
					const uid = tonumber(player.UserId)
					if not NAlib.isConnected(parentKey) or (uid and NAStuff.ESP_WatchedCharacterByUserId[uid] ~= model) then
						NAmanage.ESP_WatchPlayerCharacter(player, model)
					end
				end
				if not (model and espCONS[model] and NAmanage.IsValidESPModel(model, false)) then
					NAmanage.ESP_RequestReattachPlayer(player)
				end
			elseif player.Character and espCONS[player.Character] then
				NAmanage.ESP_ClearModel(player.Character)
			end
		end
	end
end

NAmanage.ESP_UpdateOne = function(model, now, localRoot)
	const data = espCONS[model]
	if not data then return end

	local owner = data.ownerPlayer
	if not (owner and owner.Parent) then
		owner = __lt.cm("Players", "GetPlayerFromCharacter", model)
		if owner then
			data.ownerPlayer = owner
		end
	end
	if not NAmanage.IsValidESPModel(model, data.isNPC) then
		if data.persistent and owner and owner.Parent and owner.Character == model then
			data.next = now + 0.1
			if NAmanage.ESP_SetModelVisualsEnabled then
				NAmanage.ESP_SetModelVisualsEnabled(data, false)
			end
			NAmanage.ESP_RequestReattachPlayer(owner)
			return
		end
		NAmanage.ESP_ClearModel(model)
		if data.persistent and owner then
			NAmanage.ESP_RequestReattachPlayer(owner)
		end
		return
	end
	const rootPart = getRoot(model)
	const labelAnchor = getHead(model) or rootPart or NAmanage.ESP_FirstBasePart(model)
	if data.billboard then
		if not data.billboard.Parent then
			data.billboard = nil
			data.textLabel = nil
			data.next = 0
		elseif labelAnchor and data.billboard.Adornee ~= labelAnchor then
			data.next = 0
		elseif not labelAnchor then
			pcall(function()
				data.billboard.Enabled = false
				data.billboard.Adornee = nil
			end)
		end
	end
	if data.textLabel and data.billboard and data.textLabel.Parent ~= data.billboard then
		data.textLabel = nil
		data.next = 0
	end
	const team = owner and owner.Team or nil
	const teamName = team and team.Name or nil
	const teamColor = team and team.TeamColor and team.TeamColor.Color or nil

	const dist = (localRoot and rootPart) and math.floor((localRoot.Position - rootPart.Position).Magnitude) or nil
	const renderTarget = data.isNPC and "npcs" or "players"
	const drawingPlayers = NAgui.espUsesDrawing(renderTarget)
	local budget
	if drawingPlayers then
		budget = dist and ((dist <= 50 and 0.03) or (dist <= 150 and 0.06) or (dist <= 400 and 0.12) or 0.25) or 0.06
		if data.isNPC then
			budget = budget * (NAStuff.NPC_ESP_DrawingThrottle or 1.25)
		end
	else
		budget = dist and ((dist <= 50 and 0.08) or (dist <= 150 and 0.2) or (dist <= 400 and 0.45) or 0.85) or 0.25
		if data.isNPC then
			budget = budget * (NAStuff.NPC_ESP_Throttle or 2)
		end
	end

	if data.next and now < data.next then return end
	data.next = now + budget

	local modelOnScreen = true
	local labelOnScreen = true
	if drawingPlayers or NAgui.espUsesCharacterBox(renderTarget) then
		modelOnScreen = NAgui.isInstanceInViewport(model)
	end
	if drawingPlayers then
		const labelWorldPos = NAmanage.ESP_GetLabelWorldPosition(model)
		labelOnScreen = NAgui.isWorldPositionInViewport(labelWorldPos)
	end

	const distColor = dist and ((dist > 100 and Color3.fromRGB(0, 255, 0)) or (dist > 50 and Color3.fromRGB(255, 165, 0)) or Color3.fromRGB(255, 0, 0)) or Color3.new(1, 1, 1)
	const customColor = (NAStuff.ESP_UseCustomColor == true) and NAStuff.ESP_CustomColor or nil
	const finalColor = (typeof(customColor) == "Color3" and customColor)
		or ((NAStuff.ESP_ColorByTeam ~= false and teamColor) and teamColor)
		or distColor

	const isNPC = data.isNPC == true
	const boxDist = isNPC and (NAStuff.NPC_ESP_BoxMaxDistance or NAStuff.ESP_BoxMaxDistance or 120) or (NAStuff.ESP_BoxMaxDistance or 120)
	const wantBoxes = ESPenabled and NAmanage.ESP_IsWithinDistance(dist, boxDist)
	const labelDist = isNPC and (NAStuff.NPC_ESP_LabelMaxDistance or NAStuff.ESP_LabelMaxDistance or 600) or (NAStuff.ESP_LabelMaxDistance or 1000)
	const allowLabel = (not isNPC) or (NAStuff.NPC_ESP_ShowLabels ~= false)
	const forceLabel = owner and NAmanage.ESP_HasPlayerLabelOverride(owner) == true
	local wantLabel = ESPenabled
		and allowLabel
		and NAmanage.ESP_IsWithinDistance(dist, labelDist)
		and ((not chamsEnabled) or forceLabel)

	local occluded = false
	const checkOcclusion = (isNPC and NAStuff.ESP_OcclusionIncludeNPCs == true)
		or ((not isNPC) and NAStuff.ESP_OcclusionIncludePlayers == true)
	if rootPart and checkOcclusion then
		const plr = Services.Players.LocalPlayer
		const char = plr and plr.Character
		occluded = NAmanage.ESP_GetOcclusionState(model, model, rootPart.Position, char, now)
	end
	local boxColor = finalColor or Color3.new(1, 1, 1)
	local labelColor = boxColor
	local displayTransparency = NAgui.sanitizeTransparency(NAStuff.ESP_Transparency or 0.7)
	if occluded then
		if NAStuff.ESP_OcclusionDimBoxes == true then
			boxColor = NAmanage.ESP_GetOccludedColor(boxColor)
			displayTransparency = NAmanage.ESP_GetOccludedTransparency(displayTransparency)
		end
		if NAStuff.ESP_OcclusionDimLabels == true then
			labelColor = NAmanage.ESP_GetOccludedColor(labelColor)
		end
		if NAStuff.ESP_OcclusionHideLabels == true then
			wantLabel = false
		end
	end

	if wantBoxes and not data.boxEnabled then
		NAmanage.ESP_AddBoxes(model)
	elseif not wantBoxes and data.boxEnabled then
		NAmanage.ESP_RemoveBoxes(model)
	end

	if data.boxEnabled then
		if NAgui.espUsesDrawing(renderTarget) then
			NAmanage.ESP_RemoveCharacterBox(data)
			if next(data.boxTable) ~= nil then
				for part, box in data.boxTable do
					if box then box:Destroy() end
					data.boxTable[part] = nil
				end
			end
			if data.highlight then
				NAmanage.ESP_AdjustHighlightMaterial(model, false)
				data.highlight:Destroy()
				data.highlight = nil
			end
			const drawingReady = NAmanage.ESP_EnsureDrawing(data)
			if drawingReady then
				const okBox = NAmanage.ESP_UpdateDrawingBox(data, model, boxColor, displayTransparency)
				local okTracer = true
				if occluded and NAStuff.ESP_OcclusionHideTracers == true then
					if data.drawingTracer then pcall(function() data.drawingTracer.Visible = false end) end
					if data.drawingTracerOutline then pcall(function() data.drawingTracerOutline.Visible = false end) end
				else
					okTracer = NAmanage.ESP_UpdateDrawingTracer(data, model, boxColor)
				end
				if not okBox or not okTracer then
					NAmanage.ESP_RecoverFromDrawingFailure(model, data)
				end
			else
				NAmanage.ESP_RecoverFromDrawingFailure(model, data)
			end
		elseif NAgui.espUsesHighlight(renderTarget) then
			NAmanage.ESP_RemoveCharacterBox(data)
			NAmanage.ESP_RemoveDrawing(data)
			if next(data.boxTable) ~= nil then
				for part, box in data.boxTable do
					if box then box:Destroy() end
					data.boxTable[part] = nil
				end
			end
			local highlight = data.highlight
			if not highlight or not highlight.Parent then
				data.highlight = nil
				if wantBoxes then
					NAmanage.ESP_AddBoxes(model)
					highlight = data.highlight
				end
			end
			if highlight then
				if highlight.Enabled ~= modelOnScreen then highlight.Enabled = modelOnScreen end
				NAmanage.ESP_StoreVisual(highlight)
				if highlight.FillTransparency ~= displayTransparency then highlight.FillTransparency = displayTransparency end
				const outline = NAgui.sanitizeTransparency(NAStuff.ESP_OutlineTransparency or 0)
				if highlight.OutlineTransparency ~= outline then highlight.OutlineTransparency = outline end
				if highlight.FillColor ~= boxColor then highlight.FillColor = boxColor end
				if highlight.OutlineColor ~= boxColor then highlight.OutlineColor = boxColor end
			end
		elseif NAgui.espUsesCharacterBox(renderTarget) then
			NAmanage.ESP_RemoveDrawing(data)
			if next(data.boxTable) ~= nil then
				for part, box in data.boxTable do
					if box then box:Destroy() end
					data.boxTable[part] = nil
				end
			end
			if data.highlight then
				NAmanage.ESP_AdjustHighlightMaterial(model, false)
				data.highlight:Destroy()
				data.highlight = nil
			end
			if modelOnScreen then
				if not NAmanage.ESP_UpdateCharacterBox(model, data, boxColor, displayTransparency) then
					NAmanage.ESP_RemoveCharacterBox(data)
				elseif data.charBox and data.charBox.Visible ~= true then
					data.charBox.Visible = true
				end
			elseif data.charBox and data.charBox.Visible ~= false then
				data.charBox.Visible = false
			end
		else
			NAmanage.ESP_RemoveCharacterBox(data)
			NAmanage.ESP_RemoveDrawing(data)
			for part, box in data.boxTable do
				if not part or not part.Parent or not box or not box.Parent then
					if box then box:Destroy() end
					data.boxTable[part] = nil
					if part and part.Parent and wantBoxes then
						NAmanage.ESP_AddBoxForPart(model, part)
					end
				else
					NAmanage.ESP_StoreVisual(box)
					if box.Visible ~= true then box.Visible = true end
					if box.Color3 ~= boxColor then box.Color3 = boxColor end
					if part:IsA("BasePart") and box.Size ~= part.Size then box.Size = part.Size end
					if box.Transparency ~= displayTransparency then box.Transparency = displayTransparency end
				end
			end
			if now >= (tonumber(data.nextPartRescan) or 0) then
				data.nextPartRescan = now + 0.5
				for _, part in NAmanage.QueryDescendants(model, "BasePart") do
					if part.Parent and not data.boxTable[part] then
						NAmanage.ESP_AddBoxForPart(model, part)
					end
				end
			end
		end
	end

	local pieces
	if wantLabel then
		pieces = {}
		if NAStuff.ESP_ShowName ~= false then
			const nm = owner and nameChecker(owner) or model.Name
			if nm and nm ~= "" then pieces[#pieces + 1] = nm end
		end
		if NAStuff.ESP_ShowHealth ~= false then
			const hum = getPlrHum(model)
			const h = hum and math.floor(hum.Health) or nil
			const m = hum and math.floor(hum.MaxHealth) or nil
			if h and m then pieces[#pieces + 1] = tostring(h) .. "/" .. tostring(m) .. " HP" end
		end
		if (NAStuff.ESP_ShowTeamText ~= false) and teamName and teamName ~= "None" then
			pieces[#pieces + 1] = teamName
		end
		if (NAStuff.ESP_ShowDistance ~= false) and dist then
			pieces[#pieces + 1] = tostring(dist) .. " studs"
		end
		const overrideText = owner and NAmanage.ESP_GetPlayerLabelOverrideText and NAmanage.ESP_GetPlayerLabelOverrideText(owner)
		if overrideText then
			pieces[#pieces + 1] = overrideText
		end
	end

	if wantLabel and pieces and #pieces > 0 and labelOnScreen then
		const txt = Concat(pieces, " | ")
		const txtColor = labelColor
		if NAgui.espUsesDrawing(renderTarget) and NAmanage.DrawingTextSupported() then
			NAmanage.ESP_EnsureLabel(model)
			if not NAmanage.ESP_UpdateDrawingLabel(model, txt, txtColor) then
				NAmanage.ESP_EnsureLabel(model)
				const label = data.textLabel
				if label then
					NAgui.applyLabelStyle(label)
					if label.Text ~= txt then label.Text = txt end
					if label.TextColor3 ~= txtColor then label.TextColor3 = txtColor end
				end
			end
		else
			NAmanage.ESP_EnsureLabel(model)
			const label = data.textLabel
			if label then
				NAgui.applyLabelStyle(label)
				if label.Text ~= txt then label.Text = txt end
				if label.TextColor3 ~= txtColor then label.TextColor3 = txtColor end
			end
		end
	elseif wantLabel and pieces and #pieces > 0 then
		if data.billboard and not drawingPlayers then
			pcall(function()
				data.billboard.Enabled = true
			end)
		end
		if data.drawingLabel then
			pcall(function()
				data.drawingLabel.Visible = false
			end)
		end
	else
		NAmanage.ESP_DestroyLabel(model)
	end
end

NAmanage.ESP_RegisterModel=function(m)
	if not m then return end
	const t = NAStuff.ESP_ModelList
	for i = 1, #t do
		if t[i] == m then
			return
		end
	end
	t[#t + 1] = m
end

NAmanage.ESP_UnregisterModel=function(m)
	if not m then return end
	const t = NAStuff.ESP_ModelList
	for i = 1, #t do
		if t[i] == m then
			table.remove(t, i)
			break
		end
	end
	if NAStuff.ESP_ModelIndex > #t then
		NAStuff.ESP_ModelIndex = 1
	end
end

NAmanage.ESP_Add = function(target, persistent, isNPC)
	persistent = persistent or false
	const npcFlag = isNPC == true

	if not (ESPenabled or chamsEnabled) then return end
	if typeof(target) ~= "Instance" then return end

	if target:IsA("Player") and not NAmanage.ESP_ShouldTrackPlayer(target) then
		return
	end

	if target:IsA("Player") and persistent then
		NAmanage.ESP_SetupPlayerWatch(target)
	end

	const model = target:IsA("Player") and target.Character or target
	if not (model and model:IsA("Model")) then
		if target:IsA("Player") and persistent then
			NAmanage.ESP_RequestReattachPlayer(target, true)
		end
		return
	end
	if not NAmanage.IsValidESPModel(model, npcFlag) then
		if target:IsA("Player") and persistent then
			NAmanage.ESP_WatchPlayerCharacter(target, model)
			NAmanage.ESP_RequestReattachPlayer(target, true)
		end
		return
	end
	NAmanage.ESP_ClearModel(model)
	const ownerPlayer = target:IsA("Player") and target or __lt.cm("Players", "GetPlayerFromCharacter", model)

	espCONS[model] = {
		boxTable = {},
		persistent = persistent,
		boxEnabled = false,
		highlight = nil,
		drawingBox = nil,
		charBox = nil,
		isNPC = npcFlag,
		ownerPlayer = ownerPlayer
	}

	NAmanage.ESP_RegisterModel(model)
	const key = NAmanage.ESP_Key(model)

	NAlib.connect(key.."_descAdded", NAmanage.descAdd(model, function(desc)
		if not (ESPenabled or chamsEnabled) then return end
		const data = espCONS[model]
		if not data or data.isNPC then return end
		if desc:IsA("BasePart") and data.boxEnabled then
			NAmanage.ESP_AddBoxForPart(model, desc)
		end
	end, function(desc)
		return desc and desc:IsA("BasePart")
	end))

	NAlib.connect(key.."_descRemoved", NAmanage.descRem(model, function(desc)
		const data = espCONS[model]
		if not data then return end
		const box = data.boxTable[desc]
		if box then
			box:Destroy()
			data.boxTable[desc] = nil
		end
	end))

	NAlib.connect(key.."_ancestry", model.AncestryChanged:Connect(function(_, parent)
		const data = espCONS[model]
		if not data then return end
		if parent == nil or not (Services.Workspace and model:IsDescendantOf(Services.Workspace)) then
			const owner = data.ownerPlayer
			NAmanage.ESP_ClearModel(model)
			if data.persistent and owner then
				NAmanage.ESP_RequestReattachPlayer(owner)
			end
		end
	end))

	NAmanage.ESP_AddBoxes(model)
	NAmanage.ESP_EnsureLabel(model)

	local ok, now = pcall(tick)
	if ok then
		NAmanage.ESP_UpdateOne(model, now, nil)
	end

	NAmanage.ESP_StartGlobal()
end

NAmanage.ESP_StartGlobal = function()
	if NAlib.isConnected("esp_update_global") then return end
	NAlib.connect("esp_update_global", Services.RunService.Heartbeat:Connect(function()
		if not (ESPenabled or chamsEnabled) then return end
		const now = tick()
		if ESPPlayersEnabled or chamsEnabled then
			NAmanage.ESP_ReconcilePlayers(now)
		end
		const list = NAStuff.ESP_ModelList
		const n = list and #list or 0
		if n == 0 then return end

		const plr = Services.Players.LocalPlayer
		const char = plr and plr.Character or nil
		const root = char and getRoot(char) or nil

		local idx = NAStuff.ESP_ModelIndex or 1
		local maxStep = math.clamp(math.floor(tonumber(NAStuff.ESP_MaxPerStep) or 24), 1, 256)
		if NAgui.espUsesDrawing("players") or NAgui.espUsesDrawing("npcs") then
			local drawingStep = tonumber(NAStuff.ESP_DrawingMaxPerStep) or 64
			drawingStep = math.clamp(math.floor(drawingStep), 16, 512)
			maxStep = math.max(maxStep, drawingStep)
		end
		maxStep = math.min(maxStep, n)
		if idx > n then
			idx = 1
		end
		const stop = math.min(n, idx + maxStep - 1)
		for i = idx, stop do
			const m = list[i]
			if m and espCONS[m] then
				NAmanage.ESP_UpdateOne(m, now, root)
			end
		end
		idx = stop + 1
		if idx > n then
			idx = 1
		end
		NAStuff.ESP_ModelIndex = idx
	end))
end

NAmanage.ESP_StopGlobal = function()
	NAlib.disconnect("esp_update_global")
end

--[[local Signal1, Signal2 = nil, nil
flyMobile, MobileWeld = nil, nil

function mobilefly(speed, vfly)
	character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	if flyMobile then flyMobile:Destroy() end
	flyMobile = InstanceNew("Part", Workspace)
	flyMobile.Size, flyMobile.CanCollide = Vector3.new(0.05, 0.05, 0.05), false
	if MobileWeld then MobileWeld:Destroy() end
	MobileWeld = InstanceNew("Weld", flyMobile)
	MobileWeld.Part0, MobileWeld.Part1, MobileWeld.C0 = flyMobile, character:FindFirstChildWhichIsA("Humanoid").RootPart, CFrame.new(0, 0, 0)

	if not flyMobile:FindFirstChildWhichIsA("BodyVelocity") then
		bv = InstanceNew("BodyVelocity", flyMobile)
		bv.MaxForce = Vector3.new(0, 0, 0)
		bv.Velocity = Vector3.new(0, 0, 0)
	end

	if not flyMobile:FindFirstChildWhichIsA("BodyGyro") then
		bg = InstanceNew("BodyGyro", flyMobile)
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.P = 1000
		bg.D = 50
	end

	Signal1 = LocalPlayer.CharacterAdded:Connect(function(newChar)
		if not flyMobile:FindFirstChildWhichIsA("BodyVelocity") then
			bv = InstanceNew("BodyVelocity", flyMobile)
			bv.MaxForce = Vector3.new(0, 0, 0)
			bv.Velocity = Vector3.new(0, 0, 0)
		end

		if not flyMobile:FindFirstChildWhichIsA("BodyGyro") then
			bg = InstanceNew("BodyGyro", flyMobile)
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

	camera = Workspace.CurrentCamera

	Signal2 = RunService.RenderStepped:Connect(function()
		character = getChar()
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		bv = flyMobile and flyMobile:FindFirstChildWhichIsA("BodyVelocity")
		bg = flyMobile and flyMobile:FindFirstChildWhichIsA("BodyGyro")

		if character and humanoid and flyMobile and MobileWeld and bv and bg then
			bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			if not vfly then
				if getHum() and getHum().PlatformStand then getHum().PlatformStand = true end
			end

			bg.CFrame = camera.CFrame
			direction = GetCustomMoveVector()
			newVelocity = Vector3.new(0, 0, 0)

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
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
	end
	if Signal1 then Signal1:Disconnect() end
	if Signal2 then Signal2:Disconnect() end
end]]

tool = nil
if getChar() and getBp() then
	tool=getBp():FindFirstChildOfClass("Tool") or getChar():FindFirstChildOfClass("Tool")
end

_na_env._NAXrayState = type(_na_env._NAXrayState) == "table" and _na_env._NAXrayState or {}
NAStuff.xrayState = _na_env._NAXrayState
NAStuff.xrayState.scanToken = tonumber(NAStuff.xrayState.scanToken) or 0
NAStuff.xrayState.enabled = NAStuff.xrayState.enabled == true
NAStuff.xrayConn = NAStuff.xrayState.conn
NAStuff.xrayEnabled = NAStuff.xrayState.enabled

originalIO.isHumPart=function(inst)
	const RawWorkspace = __lt.gs("Workspace")
	if not inst or not inst.Parent then
		return false
	end
	local cur = inst.Parent
	for i = 1, 5 do
		if not cur or cur == RawWorkspace then
			break
		end
		if cur:FindFirstChildOfClass("Humanoid") then
			return true
		end
		cur = cur.Parent
	end
	return false
end

originalIO.applyXrayToPart=function(prt, transVal)
	if not (prt and prt:IsA("BasePart")) then
		return
	end
	if originalIO.isHumPart(prt) then
		return
	end
	local ok, err = NACaller(function()
		prt.LocalTransparencyModifier = transVal
	end)
	if not ok then
		warn("Failed to mod transparency for part " .. tostring(prt) .. ": " .. tostring(err))
	end
end

originalIO.scanWorkspaceXray=function(transVal, token)
	const root = Services.Workspace
	if not root then
		return
	end

	const q = { root }
	local qi, qn = 1, 1
	const step = 256
	local n = 0

	while qi <= qn do
		if token ~= nil and NAStuff.xrayState.scanToken ~= token then
			return
		end
		const inst = q[qi]
		qi += 1

		if inst:IsA("BasePart") then
			originalIO.applyXrayToPart(inst, transVal)
		end

		const ch = inst:GetChildren()
		for i = 1, #ch do
			qn += 1
			q[qn] = ch[i]
		end

		n += 1
		if n >= step then
			n = 0
			Wait()
			if token ~= nil and NAStuff.xrayState.scanToken ~= token then
				return
			end
		end
	end
end

originalIO.togXray=function(en)
	if type(en) ~= "boolean" then
		warn("togXray: Invalid arg, expected boolean")
		return
	end

	if en == NAStuff.xrayState.enabled and (not en or (NAStuff.xrayState.conn and NAStuff.xrayState.conn.Connected ~= false)) then
		return
	end
	NAStuff.xrayState.enabled = en
	NAStuff.xrayState.scanToken += 1
	NAStuff.xrayEnabled = NAStuff.xrayState.enabled

	if NAStuff.xrayState.conn then
		pcall(function()
			NAStuff.xrayState.conn:Disconnect()
		end)
		NAStuff.xrayState.conn = nil
		NAStuff.xrayConn = nil
	end

	if en then
		NAStuff.xrayState.conn = NAmanage.wsAdd(function(desc)
			if not NAStuff.xrayState.enabled then
				return
			end
			if desc:IsA("BasePart") then
				originalIO.applyXrayToPart(desc, 0.5)
			end
		end)
		NAStuff.xrayConn = NAStuff.xrayState.conn
	end

	Spawn(function(call)
		originalIO.scanWorkspaceXray(call.transVal, call.token)
	end, {
		transVal = en and 0.5 or 0.0,
		token = NAStuff.xrayState.scanToken,
	})
end

NAmanage.XrayUnload=function()
	local state=NAStuff.xrayState
	if type(state)~="table" then
		state={}
		NAStuff.xrayState=state
	end
	state.enabled=false
	state.scanToken=(tonumber(state.scanToken) or 0)+1
	if state.conn then
		pcall(function()
			state.conn:Disconnect()
		end)
	end
	state.conn=nil
	NAStuff.xrayConn=nil
	NAStuff.xrayEnabled=false
	originalIO.scanWorkspaceXray(0.0,state.scanToken)
end

-- [[ FLY VARIABLES ]] --

flyVariables = {
	mOn = false;
	mFlyBruh = nil;
	flyEnabled = false;
	toggleKey = "f";
	flySpeed = 1;
	keybindConn = nil;

	vOn = false;
	vRAHH = nil;
	vFlyEnabled = false;
	vToggleKey = "v";
	vFlySpeed = 1;
	vKeybindConn = nil;

	cOn = false;
	cFlyGUI = nil;
	cFlyEnabled = false;
	cToggleKey = "c";
	cFlySpeed = 1;
	cKeybindConn = nil;

	TFlyEnabled = false;
	tflyCORE = nil;
	tflyToggleKey = "t";
	flyUpKey = "e";
	flyDownKey = "q";
	freecamUpKey = "e";
	freecamDownKey = "q";
	tflyButtonUI = nil;
	TFLYBTN = nil;
	tflyKeyConn = nil;
	TflySpeed = 2;

	tpFlyEnabled = false;
	tpFlySpeed = 1;
	tpFlyToggleKey = "y";
	tpFlyKeyConn = nil;
	tpFlyButtonUI = nil;

	uiPosConns = {};
}

NAmanage.normalizeFlyBindKey = function(value, fallback)
	local key = value
	if type(key) ~= "string" then
		key = tostring(key or "")
	end
	key = key:match("^%s*(.-)%s*$") or ""
	key = Lower(key)
	if key == "" then
		return Lower(tostring(fallback or ""))
	end
	return key
end

NAmanage.SaveFlyKeybinds = function()
	if not FileSupport then
		return
	end
	const payload = {
		fly = NAmanage.normalizeFlyBindKey(flyVariables.toggleKey, "f");
		vfly = NAmanage.normalizeFlyBindKey(flyVariables.vToggleKey, "v");
		cfly = NAmanage.normalizeFlyBindKey(flyVariables.cToggleKey, "c");
		tfly = NAmanage.normalizeFlyBindKey(flyVariables.tflyToggleKey, "t");
		tpfly = NAmanage.normalizeFlyBindKey(flyVariables.tpFlyToggleKey, "y");
		flyUp = NAmanage.normalizeFlyBindKey(flyVariables.flyUpKey, "e");
		flyDown = NAmanage.normalizeFlyBindKey(flyVariables.flyDownKey, "q");
		freecamUp = NAmanage.normalizeFlyBindKey(flyVariables.freecamUpKey, "e");
		freecamDown = NAmanage.normalizeFlyBindKey(flyVariables.freecamDownKey, "q");
	}
	NAStuff.FreecamUpKey = payload.freecamUp
	NAStuff.FreecamDownKey = payload.freecamDown
	local ok, err = pcall(function()
		writefile(NAfiles.NAFLYBINDSPATH, Services.HttpService:JSONEncode(payload))
	end)
	if not ok then
		warn("[NA] Fly keybind save failed: "..tostring(err))
	end
end

NAmanage.LoadFlyKeybinds = function()
	flyVariables.toggleKey = NAmanage.normalizeFlyBindKey(flyVariables.toggleKey, "f")
	flyVariables.vToggleKey = NAmanage.normalizeFlyBindKey(flyVariables.vToggleKey, "v")
	flyVariables.cToggleKey = NAmanage.normalizeFlyBindKey(flyVariables.cToggleKey, "c")
	flyVariables.tflyToggleKey = NAmanage.normalizeFlyBindKey(flyVariables.tflyToggleKey, "t")
	flyVariables.tpFlyToggleKey = NAmanage.normalizeFlyBindKey(flyVariables.tpFlyToggleKey, "y")
	flyVariables.flyUpKey = NAmanage.normalizeFlyBindKey(flyVariables.flyUpKey, "e")
	flyVariables.flyDownKey = NAmanage.normalizeFlyBindKey(flyVariables.flyDownKey, "q")
	flyVariables.freecamUpKey = NAmanage.normalizeFlyBindKey(flyVariables.freecamUpKey, "e")
	flyVariables.freecamDownKey = NAmanage.normalizeFlyBindKey(flyVariables.freecamDownKey, "q")
	NAStuff.FreecamUpKey = flyVariables.freecamUpKey
	NAStuff.FreecamDownKey = flyVariables.freecamDownKey

	if not (FileSupport and isfile and isfile(NAfiles.NAFLYBINDSPATH)) then
		return
	end

	local okRead, raw = pcall(readfile, NAfiles.NAFLYBINDSPATH)
	if not okRead or type(raw) ~= "string" or raw == "" then
		return
	end

	local okDecode, decoded = pcall(function()
		return Services.HttpService:JSONDecode(raw)
	end)
	if not okDecode or type(decoded) ~= "table" then
		return
	end

	flyVariables.toggleKey = NAmanage.normalizeFlyBindKey(decoded.fly, flyVariables.toggleKey or "f")
	flyVariables.vToggleKey = NAmanage.normalizeFlyBindKey(decoded.vfly, flyVariables.vToggleKey or "v")
	flyVariables.cToggleKey = NAmanage.normalizeFlyBindKey(decoded.cfly, flyVariables.cToggleKey or "c")
	flyVariables.tflyToggleKey = NAmanage.normalizeFlyBindKey(decoded.tfly, flyVariables.tflyToggleKey or "t")
	flyVariables.tpFlyToggleKey = NAmanage.normalizeFlyBindKey(decoded.tpfly, flyVariables.tpFlyToggleKey or "y")
	flyVariables.flyUpKey = NAmanage.normalizeFlyBindKey(decoded.flyUp, flyVariables.flyUpKey or "e")
	flyVariables.flyDownKey = NAmanage.normalizeFlyBindKey(decoded.flyDown, flyVariables.flyDownKey or "q")
	flyVariables.freecamUpKey = NAmanage.normalizeFlyBindKey(decoded.freecamUp, flyVariables.freecamUpKey or "e")
	flyVariables.freecamDownKey = NAmanage.normalizeFlyBindKey(decoded.freecamDown, flyVariables.freecamDownKey or "q")
	NAStuff.FreecamUpKey = flyVariables.freecamUpKey
	NAStuff.FreecamDownKey = flyVariables.freecamDownKey
end

NAmanage.LoadFlyKeybinds()

-----------------------------

cmdlp = Services.Players.LocalPlayer
plr = cmdlp
goofyFLY = nil

NAmanage.configureFlyHelper=function(part)
	if not part then return end
	part.Size = Vector3.new(0.05, 0.05, 0.05)
	part.Transparency = 1
	part.CanCollide = false
	pcall(function() part.CanTouch = false end)
	pcall(function() part.CanQuery = false end)
	pcall(function() part.Massless = true end)
	NAmanage.Helper_StoreInstance(part)
end

NAmanage._state={mode="none"}
NAmanage._persist={lastMode="none",wasFlying=false,uiPos={}}
FLYING=FLYING or false

NAmanage._modeEnabled=function(m)
	if m=="fly" then return flyVariables.flyEnabled
	elseif m=="vfly" then return flyVariables.vFlyEnabled
	elseif m=="cfly" then return flyVariables.cFlyEnabled
	elseif m=="tfly" then return flyVariables.TFlyEnabled
	elseif m=="tpfly" then return flyVariables.tpFlyEnabled
	end
	return false
end

NAmanage._releaseQE=function()
	if flyVariables.qeDownConn then pcall(function() flyVariables.qeDownConn:Disconnect() end) end
	if flyVariables.qeUpConn then pcall(function() flyVariables.qeUpConn:Disconnect() end) end
	flyVariables.qeDownConn=nil
	flyVariables.qeUpConn=nil
end

NAmanage._handleFlyVerticalKey=function(keyName, isDown)
	keyName=Lower(tostring(keyName or ""))
	const downKey=NAmanage.normalizeFlyBindKey(flyVariables.flyDownKey, "q")
	const upKey=NAmanage.normalizeFlyBindKey(flyVariables.flyUpKey, "e")
	if keyName == "" then
		return false
	end
	local verticalSpeed = tonumber(flyVariables.flySpeed) or 1
	if NAmanage._state.mode=="vfly" then
		verticalSpeed = tonumber(flyVariables.vFlySpeed) or verticalSpeed
	elseif NAmanage._state.mode=="tpfly" then
		verticalSpeed = tonumber(flyVariables.tpFlySpeed) or verticalSpeed
	end
	if keyName == downKey then
		CONTROL.Q=isDown and -(verticalSpeed*2) or 0
		return true
	elseif keyName == upKey then
		CONTROL.E=isDown and (verticalSpeed*2) or 0
		return true
	end
	return false
end

NAmanage._bindQE=function()
	NAmanage._releaseQE()
	flyVariables.qeDownConn=mouse.KeyDown:Connect(function(k)
		NAmanage._handleFlyVerticalKey(k, true)
	end)
	flyVariables.qeUpConn=mouse.KeyUp:Connect(function(k)
		NAmanage._handleFlyVerticalKey(k, false)
	end)
end

NAmanage._flyKeyCodeMap = NAmanage._flyKeyCodeMap or nil
NAmanage.GetFlyKeyCode = function(value)
	local keyMap = NAmanage._flyKeyCodeMap
	if type(keyMap) ~= "table" then
		keyMap = {}
		for _, item in Enum.KeyCode:GetEnumItems() do
			keyMap[Lower(item.Name)] = item
		end
		NAmanage._flyKeyCodeMap = keyMap
	end
	return keyMap[Lower(tostring(value or ""))]
end

NAmanage.GetTPFlyVerticalDirection = function()
	if NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive() then
		return 0
	end
	local vertical = 0
	const upKey = NAmanage.GetFlyKeyCode(flyVariables.flyUpKey or "e")
	const downKey = NAmanage.GetFlyKeyCode(flyVariables.flyDownKey or "q")
	if Services.UserInputService then
		if upKey then
			local ok, down = pcall(Services.UserInputService.IsKeyDown, Services.UserInputService, upKey)
			if ok and down then vertical += 1 end
		end
		if downKey then
			local ok, down = pcall(Services.UserInputService.IsKeyDown, Services.UserInputService, downKey)
			if ok and down then vertical -= 1 end
		end
	end
	if vertical == 0 then
		if (CONTROL and tonumber(CONTROL.E) or 0) > 0 then vertical += 1 end
		if (CONTROL and tonumber(CONTROL.Q) or 0) < 0 then vertical -= 1 end
	end
	return math.clamp(vertical, -1, 1)
end

NAmanage.IsFlyVelocityClampDisabled=function()
	return NAStuff.FlyNoVelocityClamp == true
end

NAmanage.SetFlyVelocityClampState=function(root, hum, axes, planarDirection)
	if NAmanage.IsFlyVelocityClampDisabled() then
		if type(NAmanage.ClearVelocityWalkSpeedClampState) == "function" then
			NAmanage.ClearVelocityWalkSpeedClampState()
		end
		return
	end
	if type(NAmanage.SetVelocityWalkSpeedClampState) == "function" then
		return NAmanage.SetVelocityWalkSpeedClampState(root, hum, axes, planarDirection)
	end
end

NAmanage._clearPhysics = function(full)
	if CFloop then pcall(function() CFloop:Disconnect() end) end
	CFloop = nil
	NAlib.disconnect("fly_cfly_loop")
	NAlib.disconnect("fly_tpfly_loop")
	flyVariables._tpFlyLoop = false

	if not full then
		return
	end

	if type(NAmanage.CFlyClearVisualizer) == "function" then
		NAmanage.CFlyClearVisualizer()
	end

	if NAmanage._destroyFlyHelper then
		NAmanage._destroyFlyHelper()
	end

	Spawn(function()
		const root = Services.Workspace
		if not root then
			return
		end

		const q = { root }
		local qi, qn = 1, 1
		const step = 256
		local n = 0

		while qi <= qn do
			const inst = q[qi]
			qi += 1

			if NAmanage.GetAttr(inst, "tflyPart") then
				pcall(function()
					inst:Destroy()
				end)
			end

			const ch = inst:GetChildren()
			for i = 1, #ch do
				qn += 1
				q[qn] = ch[i]
			end

			n += 1
			if n >= step then
				n = 0
				Wait()
			end
		end
	end)
end

NAmanage._destroyFlyHelper = function()
	NAlib.disconnect("fly_tpfly_loop")
	flyVariables._tpFlyLoop = false
	if flyVariables._goofyAC then
		pcall(function() flyVariables._goofyAC:Disconnect() end)
		flyVariables._goofyAC = nil
	end
	if flyVariables.TFpos then pcall(function() flyVariables.TFpos:Destroy() end) flyVariables.TFpos = nil end
	if flyVariables.TFgyro then pcall(function() flyVariables.TFgyro:Destroy() end) flyVariables.TFgyro = nil end
	if flyVariables.BG then pcall(function() flyVariables.BG:Destroy() end) flyVariables.BG = nil end
	if flyVariables.BV then pcall(function() flyVariables.BV:Destroy() end) flyVariables.BV = nil end
	if goofyFLY then pcall(function() goofyFLY:Destroy() end) goofyFLY = nil end
end

NAmanage._getCFlyTarget = function(char)
	char = char or getChar()
	if not char then
		return nil
	end
	return getRoot(char) or getHead(char)
end

NAStuff.CFlyVisualizerState = type(NAStuff.CFlyVisualizerState) == "table" and NAStuff.CFlyVisualizerState or {}
NAStuff.CFlyVisualizerState.ovPrefix = "CFlyAnchor"
NAStuff.CFlyVisualizerReturnDistance = tonumber(NAStuff.CFlyVisualizerReturnDistance) or 6

NAmanage.CFlyVisualizerState = function()
	local st = NAStuff.CFlyVisualizerState
	if type(st) ~= "table" then
		st = {}
		NAStuff.CFlyVisualizerState = st
	end
	st.ovPrefix = "CFlyAnchor"
	st.ovEnabled = NAStuff.CFlyVisualizerOn ~= false
	return st
end

NAmanage.CFlyReadCFrame = function(root)
	if not (root and root.Parent) then
		return nil
	end
	local ok, cf = pcall(function()
		return root.CFrame
	end)
	if ok and typeof(cf) == "CFrame" then
		return cf
	end
	return nil
end

NAmanage.CFlyClearVisualizer = function()
	const st = NAmanage.CFlyVisualizerState and NAmanage.CFlyVisualizerState() or nil
	if type(st) == "table" and type(NAmanage.ovClr) == "function" then
		pcall(NAmanage.ovClr, st)
	end
	if type(st) == "table" then
		st.cflyAnchor = nil
		st.UndergroundTransform = nil
		st.ovNextUpd = nil
	end
end

NAmanage.CFlyUpdateVisualizer = function(force)
	const st = NAmanage.CFlyVisualizerState and NAmanage.CFlyVisualizerState() or nil
	if type(st) ~= "table" or type(NAmanage.ovUpd) ~= "function" then
		return
	end
	if NAStuff.CFlyVisualizerOn == false then
		NAmanage.CFlyClearVisualizer()
		return
	end

	const anchor = st.cflyAnchor
	const char = getChar and getChar() or nil
	const root = char and NAmanage._getCFlyTarget(char) or nil
	const current = NAmanage.CFlyReadCFrame(root)
	if (not force and not FLYING) or not (flyVariables.cFlyEnabled == true or NAmanage._state.mode == "cfly") or not (char and root and typeof(anchor) == "CFrame" and typeof(current) == "CFrame") then
		NAmanage.CFlyClearVisualizer()
		return
	end

	const now = os.clock()
	const rate = tonumber(NAStuff.NA_OFFSET_VISUALIZER_UPDATE_RATE) or (1 / 30)
	if not force and now < (st.ovNextUpd or 0) then
		return
	end
	st.ovNextUpd = now + rate
	const currentRot = current - current.Position
	const anchorRot = anchor - anchor.Position
	st.UndergroundTransform = currentRot:ToObjectSpace(anchorRot)
	NAmanage.ovUpd(st, root, current, anchor.Position - current.Position)
end

NAmanage.CFlyStartVisualizer = function(root, reset)
	if NAStuff.CFlyVisualizerOn == false then
		NAmanage.CFlyClearVisualizer()
		return
	end
	root = root or (getChar and NAmanage._getCFlyTarget(getChar()) or nil)
	const st = NAmanage.CFlyVisualizerState and NAmanage.CFlyVisualizerState() or nil
	if type(st) ~= "table" then
		return
	end
	if typeof(st.cflyAnchor) == "CFrame" and reset ~= true then
		NAmanage.CFlyUpdateVisualizer(true)
		return
	end
	const cf = NAmanage.CFlyReadCFrame(root)
	if typeof(cf) ~= "CFrame" then
		return
	end
	st.cflyAnchor = cf
	st.UndergroundTransform = nil
	st.ovNextUpd = nil
	NAmanage.CFlyUpdateVisualizer(true)
end

NAmanage.CFlyStopVisualizer = function(restoreIfNear)
	const st = NAmanage.CFlyVisualizerState and NAmanage.CFlyVisualizerState() or nil
	const anchor = type(st) == "table" and st.cflyAnchor or nil
	local restored = false
	if restoreIfNear and typeof(anchor) == "CFrame" then
		const char = getChar and getChar() or nil
		const root = char and NAmanage._getCFlyTarget(char) or nil
		const current = NAmanage.CFlyReadCFrame(root)
		const returnDistance = tonumber(NAStuff.CFlyVisualizerReturnDistance) or 6
		if typeof(current) == "CFrame" and (current.Position - anchor.Position).Magnitude <= returnDistance then
			restored = pcall(function()
				if char and char.Parent and char.PivotTo then
					char:PivotTo(anchor)
				elseif root then
					root.CFrame = anchor
				end
				if root then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
				end
			end)
		end
	end
	NAmanage.CFlyClearVisualizer()
	return restored
end

NAmanage._captureFlyHumanoidState = function(hum)
	hum = hum or getHum()
	if not hum then
		return
	end
	const saved = flyVariables._humanoidState
	if type(saved) == "table" and saved.hum == hum then
		return
	end
	local state
	local platformStand
	pcall(function()
		state = hum:GetState()
	end)
	pcall(function()
		platformStand = hum.PlatformStand
	end)
	flyVariables._humanoidState = {
		hum = hum;
		mode = NAmanage._state.mode;
		state = state;
		platformStand = platformStand;
	}
end

NAmanage._trackFlyAnchor = function(part)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return
	end
	local tracked = flyVariables._anchoredParts
	if type(tracked) ~= "table" then
		tracked = setmetatable({}, { __mode = "k" })
		flyVariables._anchoredParts = tracked
	end
	if tracked[part] ~= nil then
		return
	end
	local anchored = false
	pcall(function()
		anchored = part.Anchored == true
	end)
	tracked[part] = {
		anchored = anchored;
		frozen = isFrozennn == true;
	}
end

NAmanage._unanchorFlyCharacter = function(char)
	char = char or getChar()
	const tracked = flyVariables._anchoredParts
	if type(tracked) ~= "table" then
		return
	end
	for part, saved in tracked do
		if typeof(part) == "Instance" and part.Parent and part:IsA("BasePart") then
			local anchored = type(saved) == "table" and saved.anchored == true or saved == true
			if type(saved) == "table" and saved.frozen == true and isFrozennn ~= true then
				anchored = false
			end
			if isFrozennn == true and char and part:IsDescendantOf(char) then
				anchored = true
			end
			pcall(function()
				part.Anchored = anchored
			end)
		end
		tracked[part] = nil
	end
end

NAmanage._hardStopCFly = function(char)
	const wasCFly = flyVariables.cFlyEnabled == true or NAmanage._state.mode == "cfly"
	if not wasCFly then
		return false
	end
	if CFloop then
		pcall(function() CFloop:Disconnect() end)
	end
	CFloop = nil
	NAlib.disconnect("fly_cfly_loop")
	if type(NAmanage.CFlyStopVisualizer) == "function" then
		NAmanage.CFlyStopVisualizer(true)
	end
	FLYING = false
	flyVariables.cFlyEnabled = false
	if NAmanage._state.mode == "cfly" then
		NAmanage._state.mode = "none"
	end
	CONTROL = { Q = 0, E = 0 }
	lCONTROL = { Q = 0, E = 0 }
	SPEED = 0
	NAmanage.ClearVelocityWalkSpeedClampState()
	NAmanage._unanchorFlyCharacter(char)
	NAmanage._restoreFlyHumanoidState(getHum(char))
	NAmanage._destroyFlyHelper()
	NAmanage._releaseQE()
	NAmanage._persist.lastMode = "none"
	NAmanage._persist.wasFlying = false
	NAmanage._persist.resumeAfterSpawn = false
	return true
end

NAmanage._isSeated=function(hum)
	hum=hum or getHum()
	if not hum then return false end
	if hum.Sit then return true end
	const seat=hum.SeatPart
	return seat and (seat:IsA("Seat") or seat:IsA("VehicleSeat")) or false
end

NAmanage._restoreFlyHumanoidState=function(hum)
	hum = hum or getHum()
	if not hum then return end
	const saved = flyVariables._humanoidState
	if type(saved) ~= "table" or saved.hum ~= hum then
		return
	end
	flyVariables._humanoidState = nil
	local currentState
	pcall(function()
		currentState = hum:GetState()
	end)
	const changedPlatformStand = saved.mode == "fly" or saved.mode == "vfly"
	if changedPlatformStand and saved.platformStand ~= nil then
		pcall(function()
			hum.PlatformStand = saved.platformStand == true
		end)
	end
	local restoreState
	if SWIMMERRRR == true then
		restoreState = Enum.HumanoidStateType.Swimming
	elseif changedPlatformStand and (
		currentState == Enum.HumanoidStateType.PlatformStanding
		or currentState == Enum.HumanoidStateType.Flying
		or currentState == Enum.HumanoidStateType.Physics
	) then
		restoreState = saved.state
	end
	if restoreState and restoreState ~= Enum.HumanoidStateType.Dead and currentState ~= restoreState then
		pcall(function()
			hum:ChangeState(restoreState)
		end)
	end
end

NAmanage._settleFlyDisabled=function(skipDeferred)
	CONTROL={Q=0,E=0}; lCONTROL={Q=0,E=0}; SPEED=0
	NAmanage.ClearVelocityWalkSpeedClampState()
	const char=getChar()
	const root=char and getRoot(char)
	const hum=getHum(char)
	const floorMaterial = hum and NAlib.isProperty(hum, "FloorMaterial")
	NAmanage._unanchorFlyCharacter(char)
	NAmanage._restoreFlyHumanoidState(hum)
	local currentState
	if hum then
		pcall(function()
			currentState = hum:GetState()
		end)
	end
	const preserveMotion = SWIMMERRRR == true
		or isFrozennn == true
		or currentState == Enum.HumanoidStateType.Swimming
	if root and floorMaterial == Enum.Material.Air and not preserveMotion and not NAmanage.IsFlyVelocityClampDisabled() then
		pcall(function()
			const vel = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(vel.X, math.min(vel.Y, 0), vel.Z)
		end)
	end
	NAmanage._destroyFlyHelper()
	if skipDeferred or floorMaterial ~= Enum.Material.Air or preserveMotion then
		return
	end
	flyVariables._disableSettleToken = (tonumber(flyVariables._disableSettleToken) or 0) + 1
	const token = flyVariables._disableSettleToken
	Spawn(function()
		Wait()
		if token == flyVariables._disableSettleToken and not FLYING then
			NAmanage._settleFlyDisabled(true)
		end
		Wait(0.08)
		if token == flyVariables._disableSettleToken and not FLYING then
			NAmanage._settleFlyDisabled(true)
		end
	end)
end

NAmanage.FLY_Cleanup = function(char)
	const c = char or getChar()
	NAmanage._unanchorFlyCharacter(c)
	FLYING=false
	NAmanage._settleFlyDisabled()
end

NAmanage.FLY_OnRespawnGround = function()
	const c = getChar()
	NAmanage.FLY_Cleanup(c)
end

NAmanage.pauseCurrent = function()
	if not FLYING then
		if NAmanage._state.mode == "cfly" and type(NAmanage.CFlyClearVisualizer) == "function" then
			NAmanage.CFlyClearVisualizer()
		end
		NAmanage._settleFlyDisabled()
		return
	end
	FLYING=false
	const hum=getHum()
	if NAmanage._state.mode=="cfly" then
		if type(NAmanage.CFlyStopVisualizer) == "function" then
			NAmanage.CFlyStopVisualizer(true)
		end
		NAmanage._unanchorFlyCharacter(getChar())
	elseif NAmanage._state.mode=="tfly" then
		if flyVariables.TFpos then flyVariables.TFpos.maxForce=Vector3.new(0,0,0) end
		if flyVariables.TFgyro then flyVariables.TFgyro.maxTorque=Vector3.new(0,0,0) end
	elseif NAmanage._state.mode=="tpfly" then
		if flyVariables.BV then flyVariables.BV.velocity=Vector3.zero flyVariables.BV.maxForce=Vector3.new(0,0,0) end
		if flyVariables.BG then flyVariables.BG.maxTorque=Vector3.new(0,0,0) end
	elseif NAmanage._state.mode=="fly" or NAmanage._state.mode=="vfly" then
		if flyVariables.BV then flyVariables.BV.velocity=Vector3.zero flyVariables.BV.maxForce=Vector3.new(0,0,0) end
		if flyVariables.BG then flyVariables.BG.maxTorque=Vector3.new(0,0,0) end
	end
	NAmanage._settleFlyDisabled()
end

NAmanage._camera=function()
	const cam=Services.Workspace.CurrentCamera
	if cam and cam.Parent then return cam end
	return nil
end

NAmanage._bindCameraWatch=function()
	if flyVariables._camChangedConn then pcall(function() flyVariables._camChangedConn:Disconnect() end) end
	flyVariables._camChangedConn=Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() end)
end

NAmanage.resumeCurrent=function()
	if FLYING then return end
	const char=getChar()
	const hum=getHum(char)
	NAmanage._captureFlyHumanoidState(hum)
	FLYING=true
	NAmanage._ensureForces()
	const cflyTarget=NAmanage._getCFlyTarget(char)
	if NAmanage._state.mode=="cfly" then
		if cflyTarget then
			NAmanage._trackFlyAnchor(cflyTarget)
			cflyTarget.Anchored=true
		end
		if type(NAmanage.CFlyStartVisualizer) == "function" then
			NAmanage.CFlyStartVisualizer(cflyTarget, true)
		end
	elseif NAmanage._state.mode=="tfly" then
		if goofyFLY and flyVariables.TFpos then flyVariables.TFpos.position=goofyFLY.Position end
		const cam=NAmanage._camera()
		if flyVariables.TFgyro and cam then flyVariables.TFgyro.cframe=cam.CFrame end
		if flyVariables.TFpos then flyVariables.TFpos.maxForce=Vector3.new(math.huge,math.huge,math.huge) end
		if flyVariables.TFgyro then flyVariables.TFgyro.maxTorque=Vector3.new(9e9,9e9,9e9) end
	elseif NAmanage._state.mode=="tpfly" then
		if flyVariables.BV then flyVariables.BV.velocity=Vector3.zero flyVariables.BV.maxForce=Vector3.new(9e9,9e9,9e9) end
		if flyVariables.BG then flyVariables.BG.maxTorque=Vector3.new(0,9e9,0) end
	elseif NAmanage._state.mode=="fly" then
		if flyVariables.BV then flyVariables.BV.maxForce=Vector3.new(9e9,9e9,9e9) end
		if flyVariables.BG then flyVariables.BG.maxTorque=Vector3.new(9e9,9e9,9e9) end
		if hum then hum.PlatformStand=true end
	elseif NAmanage._state.mode=="vfly" then
		if flyVariables.BV then flyVariables.BV.maxForce=Vector3.new(9e9,9e9,9e9) end
		if flyVariables.BG then flyVariables.BG.maxTorque=Vector3.new(9e9,9e9,9e9) end
		if hum then hum.PlatformStand=false end
	end
end

NAmanage._destroyMobileFlyUI=function()
	for m,conn in flyVariables.uiPosConns do
		pcall(function() conn:Disconnect() end)
		flyVariables.uiPosConns[m]=nil
	end
	if flyVariables.uiUpdateConn then pcall(function() flyVariables.uiUpdateConn:Disconnect() end) end
	flyVariables.uiUpdateConn=nil
	NAlib.disconnect("fly_mobile_ui_update")
	if flyVariables.mFlyBruh then pcall(function() flyVariables.mFlyBruh:Destroy() end) flyVariables.mFlyBruh=nil end
	if flyVariables.vRAHH then pcall(function() flyVariables.vRAHH:Destroy() end) flyVariables.vRAHH=nil end
	if flyVariables.cFlyGUI then pcall(function() flyVariables.cFlyGUI:Destroy() end) flyVariables.cFlyGUI=nil end
	if flyVariables.TFLYBTN then pcall(function() flyVariables.TFLYBTN:Destroy() end) flyVariables.TFLYBTN=nil end
	if flyVariables.tflyButtonUI then pcall(function() flyVariables.tflyButtonUI:Destroy() end) flyVariables.tflyButtonUI=nil end
	if flyVariables.tpFlyButtonUI then pcall(function() flyVariables.tpFlyButtonUI:Destroy() end) flyVariables.tpFlyButtonUI=nil end
end

NAmanage._ensureMobileFlyUI=function(mode)
	if not IsOnMobile then return end
	NAmanage._destroyMobileFlyUI()
	const mk=function(modeKey,btnText,onToggle,getSpeed,setSpeed,storeRefs)
		const gui=InstanceNew("ScreenGui"); NAgui.NaProtectUI(gui); gui.ResetOnSpawn=false
		const btn=InstanceNew("TextButton",gui)
		const speedBox=InstanceNew("TextBox",gui)
		const toggleBtn=InstanceNew("TextButton",btn)
		const corner=InstanceNew("UICorner",btn)
		corner.CornerRadius = UDim.new(0, 6)
		const corner2=InstanceNew("UICorner",speedBox)
		corner2.CornerRadius = UDim.new(0, 6)
		const corner3=InstanceNew("UICorner",toggleBtn)
		corner3.CornerRadius = UDim.new(0, 6)
		const aspect=InstanceNew("UIAspectRatioConstraint",btn)
		btn.BackgroundColor3=Color3.fromRGB(30,30,30)
		btn.BackgroundTransparency=0.1
		btn.Position=NAmanage._persist.uiPos[modeKey] or UDim2.new(0.9,0,0.5,0)
		btn.Size=UDim2.new(0.08,0,0.1,0)
		btn.Font=Enum.Font.GothamBold
		btn.Text=btnText()
		btn.TextColor3=Color3.fromRGB(255,255,255)
		btn.TextScaled=true
		corner.CornerRadius=UDim.new(0, 6)
		aspect.AspectRatio=1
		speedBox.BackgroundColor3=Color3.fromRGB(30,30,30)
		speedBox.BackgroundTransparency=0.1
		speedBox.AnchorPoint=Vector2.new(0.5,0)
		speedBox.Position=UDim2.new(0.5,0,0,10)
		speedBox.Size=UDim2.new(0,75,0,35)
		speedBox.Font=Enum.Font.GothamBold
		speedBox.Text=tostring(getSpeed())
		speedBox.TextColor3=Color3.fromRGB(255,255,255)
		speedBox.TextSize=24
		speedBox.TextScaled=true
		speedBox.ClearTextOnFocus=false
		speedBox.PlaceholderText="Speed"
		speedBox.Visible=false
		const function applySpeedFromBox()
			const ns=tonumber(speedBox.Text)
			if ns then
				setSpeed(ns)
			end
			speedBox.Text=tostring(getSpeed())
		end
		corner2.CornerRadius=UDim.new(0, 6)
		toggleBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
		toggleBtn.BackgroundTransparency=0.1
		toggleBtn.Position=UDim2.new(0.8,0,-0.1,0)
		toggleBtn.Size=UDim2.new(0.4,0,0.4,0)
		toggleBtn.Font=Enum.Font.SourceSans
		toggleBtn.Text="+"
		toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
		toggleBtn.TextScaled=true
		toggleBtn.AutoButtonColor=true
		corner3.CornerRadius=UDim.new(0, 6)
		MouseButtonFix(toggleBtn,function()
			speedBox.Visible=not speedBox.Visible
			toggleBtn.Text=speedBox.Visible and "-" or "+"
		end)
		speedBox.FocusLost:Connect(applySpeedFromBox)
		MouseButtonFix(btn,function()
			applySpeedFromBox()
			onToggle()
			btn.Text=btnText()
			btn.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
		end)
		NAgui.draggerV2(btn)
		NAgui.draggerV2(speedBox)
		if flyVariables.uiPosConns[modeKey] then pcall(function() flyVariables.uiPosConns[modeKey]:Disconnect() end) end
		flyVariables.uiPosConns[modeKey]=btn:GetPropertyChangedSignal("Position"):Connect(function()
			NAmanage._persist.uiPos[modeKey]=btn.Position
		end)
		if storeRefs then storeRefs(gui,btn) end
	end
	if mode=="fly" then
		mk("fly",function() return FLYING and "Unfly" or "Fly" end,function() NAmanage.toggleFly() end,function() return flyVariables.flySpeed end,function(v) flyVariables.flySpeed=v end,function(gui,btn) flyVariables.mFlyBruh=gui end)
	elseif mode=="vfly" then
		mk("vfly",function() return FLYING and "UnvFly" or "vFly" end,function() NAmanage.toggleVFly() end,function() return flyVariables.vFlySpeed end,function(v) flyVariables.vFlySpeed=v end,function(gui,btn) flyVariables.vRAHH=gui end)
	elseif mode=="cfly" then
		mk("cfly",function() return FLYING and "UnCfly" or "CFly" end,function() NAmanage.toggleCFly() end,function() return flyVariables.cFlySpeed end,function(v) flyVariables.cFlySpeed=v flyVariables.flySpeed=v end,function(gui,btn) flyVariables.cFlyGUI=gui end)
	elseif mode=="tfly" then
		mk("tfly",function() return FLYING and "UnTFly" or "TFly" end,function() NAmanage.toggleTFly() end,function() return flyVariables.TflySpeed end,function(v) flyVariables.TflySpeed=v end,function(gui,btn) flyVariables.tflyButtonUI=gui flyVariables.TFLYBTN=btn end)
	elseif mode=="tpfly" then
		mk("tpfly",function() return FLYING and "UnTPFly" or "TPFly" end,function() NAmanage.toggleTPFly() end,function() return flyVariables.tpFlySpeed end,function(v) flyVariables.tpFlySpeed=v end,function(gui,btn) flyVariables.tpFlyButtonUI=gui end)
	end
	if flyVariables.uiUpdateConn then pcall(function() flyVariables.uiUpdateConn:Disconnect() end) end
	flyVariables.uiUpdateConn=NAlib.reconnect("fly_mobile_ui_update", Services.RunService.Heartbeat:Connect(function()
		if mode=="fly" and flyVariables.mFlyBruh then
			const b=flyVariables.mFlyBruh:FindFirstChildOfClass("TextButton")
			if b then b.Text=FLYING and "Unfly" or "Fly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		elseif mode=="vfly" and flyVariables.vRAHH then
			const b=flyVariables.vRAHH:FindFirstChildOfClass("TextButton")
			if b then b.Text=FLYING and "UnvFly" or "vFly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		elseif mode=="cfly" and flyVariables.cFlyGUI then
			const b=flyVariables.cFlyGUI:FindFirstChildOfClass("TextButton")
			if b then b.Text=FLYING and "UnCfly" or "CFly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		elseif mode=="tfly" and flyVariables.tflyButtonUI then
			const b=flyVariables.tflyButtonUI:FindFirstChildOfClass("TextButton")
			if b then b.Text=FLYING and "UnTFly" or "TFly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		elseif mode=="tpfly" and flyVariables.tpFlyButtonUI then
			const b=flyVariables.tpFlyButtonUI:FindFirstChildOfClass("TextButton")
			if b then b.Text=FLYING and "UnTPFly" or "TPFly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		end
	end))
end

NAmanage.deactivateMode=function(m)
	const wasCurrent=(NAmanage._state.mode==m)
	const wasCFlyActive=(m=="cfly" and (wasCurrent or flyVariables.cFlyEnabled == true))
	if wasCFlyActive and type(NAmanage.CFlyStopVisualizer) == "function" then
		NAmanage.CFlyStopVisualizer(true)
	end
	if wasCurrent then
		NAmanage.pauseCurrent()
		NAmanage._clearPhysics(true)
		NAmanage._state.mode="none"
		NAmanage._releaseQE()
	elseif wasCFlyActive then
		NAmanage._hardStopCFly(getChar())
	end
	if m=="fly" then flyVariables.flyEnabled=false end
	if m=="vfly" then flyVariables.vFlyEnabled=false end
	if m=="cfly" then flyVariables.cFlyEnabled=false end
	if m=="tfly" then flyVariables.TFlyEnabled=false end
	if m=="tpfly" then flyVariables.tpFlyEnabled=false end
	NAmanage.startWatcher()
	NAmanage._destroyMobileFlyUI()
end

NAmanage.sFLY=function(vfly,cfly,tfly,tpfly)
	while not getChar() or not getRoot(getChar()) or not getHum() do Wait() end
	CONTROL={Q=0,E=0}; lCONTROL={Q=0,E=0}; SPEED=0
	const hum=getHum(); const head=getHead(getChar()); const root=getRoot(getChar())
	NAmanage._captureFlyHumanoidState(hum)
	if NAmanage.IsFlyVelocityClampDisabled() then
		if type(NAmanage.ClearVelocityWalkSpeedClampState) == "function" then
			NAmanage.ClearVelocityWalkSpeedClampState()
		end
	elseif type(NAmanage.EnsureVelocityWalkSpeedClampLoop) == "function" then
		NAmanage.EnsureVelocityWalkSpeedClampLoop()
	end
	NAmanage._bindQE()
	if tfly then
		goofyFLY=goofyFLY or InstanceNew("Part",Services.Workspace)
		NAmanage.configureFlyHelper(goofyFLY)
		if not goofyFLY:FindFirstChildOfClass("Weld") then
			const w=InstanceNew("Weld",goofyFLY) w.Part0=goofyFLY w.Part1=root w.C0=CFrame.new()
		end
		flyVariables.TFpos=flyVariables.TFpos or InstanceNew("BodyPosition",goofyFLY)
		flyVariables.TFgyro=flyVariables.TFgyro or InstanceNew("BodyGyro",goofyFLY)
		flyVariables.TFpos.maxForce=Vector3.new(math.huge,math.huge,math.huge)
		flyVariables.TFpos.position=goofyFLY.Position
		const cam0=NAmanage._camera()
		flyVariables.TFgyro.maxTorque=Vector3.new(9e9,9e9,9e9)
		flyVariables.TFgyro.cframe=cam0 and cam0.CFrame or CFrame.new()
		if CFloop then pcall(function() CFloop:Disconnect() end) end
		CFloop=nil
		if not flyVariables._tflyLoop then
			flyVariables._tflyLoop=true
			SpawnCall(function()
				while NAmanage._state.mode=="tfly" do
					const cam=NAmanage._camera()
					if cam and FLYING and flyVariables.TFpos and flyVariables.TFgyro then
						const currentChar=getChar()
						const currentHum=getHum(currentChar)
						const currentRoot=currentChar and getRoot(currentChar)
						const sp=tonumber(flyVariables.TflySpeed) or 1
						const moveDirection=NAmanage.GetFlyMoveDirection(cam, 1)
						local np=flyVariables.TFgyro.cframe-flyVariables.TFgyro.cframe.p+flyVariables.TFpos.position
						if moveDirection.Magnitude>0 then
							np=np+(moveDirection*sp)
						end
						pcall(function()
							flyVariables.TFpos.position=np.p
							flyVariables.TFgyro.cframe=cam.CFrame
						end)
						if currentRoot and currentHum then
							NAmanage.SetFlyVelocityClampState(currentRoot, currentHum, Vector3.new(1,1,1))
						end
					else
						NAmanage.ClearVelocityWalkSpeedClampState()
					end
					Wait()
				end
				NAmanage.ClearVelocityWalkSpeedClampState()
				flyVariables._tflyLoop=false
			end)
		end
	elseif tpfly then
		goofyFLY=goofyFLY or InstanceNew("Part",Services.Workspace)
		NAmanage.configureFlyHelper(goofyFLY)
		if not goofyFLY:FindFirstChildOfClass("Weld") then
			const w=InstanceNew("Weld",goofyFLY) w.Part0=goofyFLY w.Part1=root w.C0=CFrame.new()
		end
		flyVariables.BG=flyVariables.BG or InstanceNew("BodyGyro",goofyFLY)
		flyVariables.BG.P=9e4
		flyVariables.BG.maxTorque=Vector3.new(0,9e9,0)
		flyVariables.BV=flyVariables.BV or InstanceNew("BodyVelocity",goofyFLY)
		flyVariables.BV.velocity=Vector3.zero
		flyVariables.BV.maxForce=Vector3.new(9e9,9e9,9e9)
		if CFloop then pcall(function() CFloop:Disconnect() end) end
		CFloop=nil
	elseif cfly then
		goofyFLY=goofyFLY or InstanceNew("Part",Services.Workspace)
		NAmanage.configureFlyHelper(goofyFLY)
		goofyFLY.Anchored=true
		const cflyTarget=NAmanage._getCFlyTarget(getChar())
		if cflyTarget then
			NAmanage._trackFlyAnchor(cflyTarget)
			cflyTarget.Anchored=true
		end
		if type(NAmanage.CFlyStartVisualizer) == "function" then
			NAmanage.CFlyStartVisualizer(cflyTarget, false)
		end
		if CFloop then pcall(function() CFloop:Disconnect() end) end
		NAlib.disconnect("fly_cfly_loop")
		CFloop=NAlib.reconnect("fly_cfly_loop", Services.RunService.RenderStepped:Connect(function()
			if NAmanage._state.mode~="cfly" or not FLYING then return end
			const currentChar=getChar()
			const currentTarget=NAmanage._getCFlyTarget(currentChar)
			if not currentTarget then return end
			const cam=NAmanage._camera(); if not cam then return end
			const vertical=(CONTROL.E+CONTROL.Q)
			const md=NAmanage.GetCFlyMoveDirection(cam)+(cam.CFrame.UpVector*vertical)
			if md.Magnitude>0 then
				const ns=currentTarget.Position+md.Unit*(tonumber(flyVariables.cFlySpeed) or 1)
				const lk=ns+cam.CFrame.LookVector
				currentTarget.CFrame=CFrame.new(ns,lk)
				goofyFLY.CFrame=currentTarget.CFrame
			end
			if type(NAmanage.CFlyUpdateVisualizer) == "function" then
				NAmanage.CFlyUpdateVisualizer(false)
			end
		end))
	else
		goofyFLY=goofyFLY or InstanceNew("Part",Services.Workspace)
		NAmanage.configureFlyHelper(goofyFLY)
		if not goofyFLY:FindFirstChildOfClass("Weld") then
			const w=InstanceNew("Weld",goofyFLY) w.Part0=goofyFLY w.Part1=root w.C0=CFrame.new()
		end
		flyVariables.BG=flyVariables.BG or InstanceNew("BodyGyro",goofyFLY)
		flyVariables.BG.P=9e4
		flyVariables.BG.maxTorque=Vector3.new(9e9,9e9,9e9)
		flyVariables.BV=flyVariables.BV or InstanceNew("BodyVelocity",goofyFLY)
		flyVariables.BV.velocity=Vector3.zero
		flyVariables.BV.maxForce=Vector3.new(9e9,9e9,9e9)
		if NAmanage._state.mode=="fly" then if hum then hum.PlatformStand=true end else if hum then hum.PlatformStand=false end end
		if CFloop then pcall(function() CFloop:Disconnect() end) end
		if not flyVariables._stdLoop then
			flyVariables._stdLoop=true
			SpawnCall(function()
				while (NAmanage._state.mode=="fly" or NAmanage._state.mode=="vfly") do
					const cam=NAmanage._camera()
					if cam and FLYING and flyVariables.BV and flyVariables.BG then
						const currentChar=getChar()
						const currentHum=getHum(currentChar)
						const currentRoot=currentChar and getRoot(currentChar)
						const moveDirection=NAmanage.GetFlyMoveDirection(cam, 0.2)
						const has=moveDirection.Magnitude>0
						if has then
							SPEED=((NAmanage._state.mode=="vfly" and tonumber(flyVariables.vFlySpeed) or tonumber(flyVariables.flySpeed)) or 1)*50
						elseif SPEED~=0 then
							SPEED=0
						end
						if has then
							flyVariables.BV.velocity=moveDirection*SPEED
							lCONTROL={Q=CONTROL.Q,E=CONTROL.E}
							if currentRoot and currentHum then
								NAmanage.SetFlyVelocityClampState(currentRoot, currentHum, Vector3.new(1,1,1))
							end
						elseif SPEED~=0 then
							const lastVertical=(tonumber((lCONTROL and lCONTROL.Q or 0)+(lCONTROL and lCONTROL.E or 0)) or 0)*0.2
							flyVariables.BV.velocity=cam.CFrame.UpVector*lastVertical*SPEED
							if currentRoot and currentHum then
								NAmanage.SetFlyVelocityClampState(currentRoot, currentHum, Vector3.new(1,1,1))
							end
						else
							flyVariables.BV.velocity=Vector3.zero
							NAmanage.ClearVelocityWalkSpeedClampState()
						end
						flyVariables.BG.cframe=cam.CFrame
					elseif flyVariables.BV then
						flyVariables.BV.velocity=Vector3.zero
						NAmanage.ClearVelocityWalkSpeedClampState()
					end
					Wait()
				end
				NAmanage.ClearVelocityWalkSpeedClampState()
				if flyVariables.BG then pcall(function() flyVariables.BG:Destroy() end) end
				if flyVariables.BV then pcall(function() flyVariables.BV:Destroy() end) end
				flyVariables.BG=nil; flyVariables.BV=nil
				flyVariables._stdLoop=false
			end)
		end
	end
	FLYING=true
end

NAmanage._ensureForces=function()
	if NAmanage._state.mode=="none" then return end
	if not FLYING then
		NAmanage._destroyFlyHelper()
		return
	end
	const char=getChar(); if not char then return end
	const hum=getHum(); if not hum then return end
	const root=getRoot(char); if not root then return end
	const cam=NAmanage._camera()
	if not goofyFLY or goofyFLY.Parent==nil then
		goofyFLY=InstanceNew("Part",Services.Workspace)
		NAmanage.configureFlyHelper(goofyFLY)
		goofyFLY.Anchored=(NAmanage._state.mode=="cfly")
		const head=getHead(char); if head then goofyFLY:PivotTo(head:GetPivot()) end
		if flyVariables._goofyAC then pcall(function() flyVariables._goofyAC:Disconnect() end) end
		flyVariables._goofyAC=goofyFLY.AncestryChanged:Connect(function(_,p) if not p then Defer(NAmanage._ensureForces) end end)
	end
	if NAmanage._state.mode=="tfly" then
		NAmanage._ensureWeldTarget()
		if not flyVariables.TFpos or flyVariables.TFpos.Parent~=goofyFLY then
			flyVariables.TFpos=InstanceNew("BodyPosition",goofyFLY)
			flyVariables.TFpos.position=goofyFLY.Position
		end
		if not flyVariables.TFgyro or flyVariables.TFgyro.Parent~=goofyFLY then
			flyVariables.TFgyro=InstanceNew("BodyGyro",goofyFLY)
			flyVariables.TFgyro.cframe=(cam and cam.CFrame) or CFrame.new()
		end
		if FLYING then
			flyVariables.TFpos.maxForce=Vector3.new(math.huge,math.huge,math.huge)
			flyVariables.TFgyro.maxTorque=Vector3.new(9e9,9e9,9e9)
		else
			flyVariables.TFpos.maxForce=Vector3.new(0,0,0)
			flyVariables.TFgyro.maxTorque=Vector3.new(0,0,0)
		end
	elseif NAmanage._state.mode=="cfly" then
		goofyFLY.Anchored=true
		const cflyTarget=NAmanage._getCFlyTarget(char)
		if cflyTarget and FLYING and not cflyTarget.Anchored then
			NAmanage._trackFlyAnchor(cflyTarget)
			cflyTarget.Anchored=true
		end
	elseif NAmanage._state.mode=="tpfly" then
		NAmanage._ensureWeldTarget()
		if not flyVariables.BG or flyVariables.BG.Parent~=goofyFLY then
			flyVariables.BG=InstanceNew("BodyGyro",goofyFLY)
			flyVariables.BG.P=9e4
		end
		if not flyVariables.BV or flyVariables.BV.Parent~=goofyFLY then
			flyVariables.BV=InstanceNew("BodyVelocity",goofyFLY)
			flyVariables.BV.velocity=Vector3.zero
		end
		if cam then flyVariables.BG.cframe=cam.CFrame end
		flyVariables.BG.maxTorque=FLYING and Vector3.new(0,9e9,0) or Vector3.new(0,0,0)
		flyVariables.BV.maxForce=FLYING and Vector3.new(9e9,9e9,9e9) or Vector3.new(0,0,0)
	else
		NAmanage._ensureWeldTarget()
		if not flyVariables.BG or flyVariables.BG.Parent~=goofyFLY then
			flyVariables.BG=InstanceNew("BodyGyro",goofyFLY)
			flyVariables.BG.P=9e4
		end
		if not flyVariables.BV or flyVariables.BV.Parent~=goofyFLY then
			flyVariables.BV=InstanceNew("BodyVelocity",goofyFLY)
			flyVariables.BV.velocity=Vector3.zero
		end
		if cam then flyVariables.BG.cframe=cam.CFrame end
		flyVariables.BG.maxTorque=FLYING and Vector3.new(9e9,9e9,9e9) or Vector3.new(0,0,0)
		flyVariables.BV.maxForce=FLYING and Vector3.new(9e9,9e9,9e9) or Vector3.new(0,0,0)
		if NAmanage._state.mode=="fly" then hum.PlatformStand=FLYING else hum.PlatformStand=false end
	end
	if not flyVariables.qeDownConn or flyVariables.qeDownConn.Connected==false then
		if flyVariables.qeDownConn then pcall(function() flyVariables.qeDownConn:Disconnect() end) end
		flyVariables.qeDownConn=mouse.KeyDown:Connect(function(k)
			NAmanage._handleFlyVerticalKey(k, true)
		end)
	end
	if not flyVariables.qeUpConn or flyVariables.qeUpConn.Connected==false then
		if flyVariables.qeUpConn then pcall(function() flyVariables.qeUpConn:Disconnect() end) end
		flyVariables.qeUpConn=mouse.KeyUp:Connect(function(k)
			NAmanage._handleFlyVerticalKey(k, false)
		end)
	end
end

NAmanage._ensureLoops=function()
	if NAmanage._state.mode=="tfly" then
		if not flyVariables._tflyLoop then
			flyVariables._tflyLoop=true
			Spawn(function()
				while NAmanage._state.mode=="tfly" do
					if not FLYING then
						NAmanage.ClearVelocityWalkSpeedClampState()
						Wait()
					elseif not goofyFLY or not flyVariables.TFpos or not flyVariables.TFgyro or goofyFLY.Parent==nil or flyVariables.TFpos.Parent~=goofyFLY or flyVariables.TFgyro.Parent~=goofyFLY then
						NAmanage._ensureForces()
						Wait()
					else
						if FLYING then
							const currentChar=getChar()
							const currentHum=getHum(currentChar)
							const currentRoot=currentChar and getRoot(currentChar)
							const cam=Services.Workspace.CurrentCamera
							const sp=tonumber(flyVariables.TflySpeed) or 1
							const moveDirection=NAmanage.GetFlyMoveDirection(cam, 1)
							local np=flyVariables.TFgyro.cframe-flyVariables.TFgyro.cframe.p+flyVariables.TFpos.position
							if moveDirection.Magnitude>0 then
								np=np+(moveDirection*sp)
							end
							pcall(function()
								flyVariables.TFpos.position=np.p
								flyVariables.TFgyro.cframe=cam.CFrame
							end)
							if currentRoot and currentHum then
								NAmanage.SetFlyVelocityClampState(currentRoot, currentHum, Vector3.new(1,1,1))
							end
						else
							NAmanage.ClearVelocityWalkSpeedClampState()
						end
					end
					Wait()
				end
				NAmanage.ClearVelocityWalkSpeedClampState()
				flyVariables._tflyLoop=false
			end)
		end
	elseif NAmanage._state.mode=="tpfly" then
		if not flyVariables._tpFlyLoop or not NAlib.isConnected("fly_tpfly_loop") then
			flyVariables._tpFlyLoop=true
			NAlib.reconnect("fly_tpfly_loop", Services.RunService.Heartbeat:Connect(function(deltaTime)
				if NAmanage._state.mode~="tpfly" then
					NAlib.disconnect("fly_tpfly_loop")
					flyVariables._tpFlyLoop=false
					return
				end
				if not FLYING then
					if flyVariables.BV then pcall(function() flyVariables.BV.velocity=Vector3.zero end) end
					return
				end
				const currentChar=getChar()
				const currentHum=getHum(currentChar)
				const currentRoot=currentChar and getRoot(currentChar)
				if not (currentChar and currentHum and currentRoot) then
					return
				end
				if not goofyFLY or not flyVariables.BG or not flyVariables.BV or goofyFLY.Parent==nil or flyVariables.BG.Parent~=goofyFLY or flyVariables.BV.Parent~=goofyFLY then
					NAmanage._ensureForces()
					return
				end
				const cam=NAmanage._camera()
				if cam and flyVariables.BG then
					pcall(function()
						flyVariables.BG.cframe=cam.CFrame
					end)
				end
				pcall(function()
					flyVariables.BV.velocity=Vector3.zero
				end)
				local moveDirection=Vector3.zero
				if cam then
					moveDirection=NAmanage.GetCFlyMoveDirection(cam)
				end
				if typeof(moveDirection)~="Vector3" then
					moveDirection=Vector3.zero
				end
				const vertical=NAmanage.GetTPFlyVerticalDirection()
				const dt=math.clamp(tonumber(deltaTime) or (1/60), 0, 0.05)
				const sp=math.max(0, tonumber(flyVariables.tpFlySpeed) or 1)
				const frameScale=dt*60
				local offset=moveDirection*(sp*frameScale)
				if cam and vertical~=0 then
					offset += cam.CFrame.UpVector*(vertical*sp*frameScale)
				end
				if offset.Magnitude>0 then
					pcall(function()
						currentChar:TranslateBy(offset)
					end)
				end
			end))
		end
	elseif NAmanage._state.mode=="fly" or NAmanage._state.mode=="vfly" then
		if not flyVariables._stdLoop then
			flyVariables._stdLoop=true
			SpawnCall(function()
				while NAmanage._state.mode=="fly" or NAmanage._state.mode=="vfly" do
					if not FLYING then
						if flyVariables.BV then pcall(function() flyVariables.BV.velocity=Vector3.zero end) end
						NAmanage.ClearVelocityWalkSpeedClampState()
						Wait()
					elseif not goofyFLY or not flyVariables.BG or not flyVariables.BV or goofyFLY.Parent==nil or flyVariables.BG.Parent~=goofyFLY or flyVariables.BV.Parent~=goofyFLY then
						NAmanage._ensureForces()
						Wait()
					else
						if FLYING then
							const currentChar=getChar()
							const currentHum=getHum(currentChar)
							const currentRoot=currentChar and getRoot(currentChar)
							const cam=Services.Workspace.CurrentCamera
							const moveDirection=NAmanage.GetFlyMoveDirection(cam, 0.2)
							const has=moveDirection.Magnitude>0
							if has then
								SPEED=((NAmanage._state.mode=="vfly" and tonumber(flyVariables.vFlySpeed) or tonumber(flyVariables.flySpeed)) or 1)*50
							elseif SPEED~=0 then
								SPEED=0
							end
							if has then
								pcall(function()
									flyVariables.BV.velocity=moveDirection*SPEED
									flyVariables.BG.cframe=cam.CFrame
								end)
								lCONTROL={Q=CONTROL.Q,E=CONTROL.E}
								if currentRoot and currentHum then
									NAmanage.SetFlyVelocityClampState(currentRoot, currentHum, Vector3.new(1,1,1))
								end
							elseif SPEED~=0 then
								pcall(function()
									const lastVertical=(tonumber((lCONTROL and lCONTROL.Q or 0)+(lCONTROL and lCONTROL.E or 0)) or 0)*0.2
									flyVariables.BV.velocity=cam.CFrame.UpVector*lastVertical*SPEED
									flyVariables.BG.cframe=cam.CFrame
								end)
								if currentRoot and currentHum then
									NAmanage.SetFlyVelocityClampState(currentRoot, currentHum, Vector3.new(1,1,1))
								end
							else
								pcall(function()
									flyVariables.BV.velocity=Vector3.zero
									flyVariables.BG.cframe=cam.CFrame
								end)
								NAmanage.ClearVelocityWalkSpeedClampState()
							end
						else
							if flyVariables.BV then pcall(function() flyVariables.BV.velocity=Vector3.zero end) end
							NAmanage.ClearVelocityWalkSpeedClampState()
						end
					end
					Wait()
				end
				NAmanage.ClearVelocityWalkSpeedClampState()
				flyVariables._stdLoop=false
			end)
		end
	elseif NAmanage._state.mode=="cfly" then
		if not CFloop or CFloop.Connected==false then
			if CFloop then pcall(function() CFloop:Disconnect() end) end
			CFloop=NAlib.reconnect("fly_cfly_loop", Services.RunService.RenderStepped:Connect(function()
				if NAmanage._state.mode~="cfly" or not FLYING then return end
				NAmanage._ensureForces()
				const char=getChar()
				const cflyTarget=NAmanage._getCFlyTarget(char)
				if not cflyTarget then return end
				const cam=Services.Workspace.CurrentCamera
				if not cam then return end
				const vertical=(CONTROL.E+CONTROL.Q)
				const md=NAmanage.GetCFlyMoveDirection(cam)+(cam.CFrame.UpVector*vertical)
				if md.Magnitude>0 then
					const ns=cflyTarget.Position+md.Unit*(tonumber(flyVariables.cFlySpeed) or 1)
					const lk=ns+cam.CFrame.LookVector
					cflyTarget.CFrame=CFrame.new(ns,lk)
					if goofyFLY then goofyFLY.CFrame=cflyTarget.CFrame end
				end
				if type(NAmanage.CFlyUpdateVisualizer) == "function" then
					NAmanage.CFlyUpdateVisualizer(false)
				end
			end))
		end
	end
end

NAmanage._ensureWeldTarget=function()
	if flyVariables._weldLoopConn then return end
	flyVariables._weldLoopConn=NAlib.reconnect("fly_weld_target", Services.RunService.Heartbeat:Connect(function()
		if NAmanage._state.mode=="none" or NAmanage._state.mode=="cfly" or not FLYING then return end
		const char=getChar(); if not char then return end
		const root=getRoot(char); if not root then return end
		if not goofyFLY or goofyFLY.Parent==nil then
			goofyFLY=InstanceNew("Part",Services.Workspace)
			NAmanage.configureFlyHelper(goofyFLY)
			goofyFLY.Anchored=false
			const head=getHead(char); if head then goofyFLY:PivotTo(head:GetPivot()) end
		end
		local w=goofyFLY:FindFirstChildOfClass("Weld")
		if not w or w.Parent~=goofyFLY then
			if w then pcall(function() w:Destroy() end) end
			w=InstanceNew("Weld",goofyFLY)
		end
		if (not w.Part0) or w.Part0~=goofyFLY or w.Part0.Parent==nil then pcall(function() w.Part0=goofyFLY end) end
		if (not w.Part1) or w.Part1~=root or w.Part1.Parent==nil or (not w.Part1:IsDescendantOf(char)) then pcall(function() w.Part1=root end) end
		pcall(function() w.C0=CFrame.new() end)
	end))
end

NAmanage.startWatcher=function()
	const shouldWatch = flyVariables.flyEnabled or flyVariables.vFlyEnabled or flyVariables.cFlyEnabled or flyVariables.TFlyEnabled or flyVariables.tpFlyEnabled
	if not shouldWatch then
		if flyVariables._watchConn then
			pcall(function() flyVariables._watchConn:Disconnect() end)
			flyVariables._watchConn = nil
			NAlib.disconnect("fly_watch")
		end
		if type(NAmanage.CFlyClearVisualizer) == "function" then
			NAmanage.CFlyClearVisualizer()
		end
		NAmanage._destroyFlyHelper()
		NAmanage._bindCameraWatch()
		return
	end
	if flyVariables._watchConn then
		NAmanage._bindCameraWatch()
		return
	end
	flyVariables._watchConn=NAlib.reconnect("fly_watch", Services.RunService.Heartbeat:Connect(function()
		const watching = flyVariables.flyEnabled or flyVariables.vFlyEnabled or flyVariables.cFlyEnabled or flyVariables.TFlyEnabled or flyVariables.tpFlyEnabled
		if not watching then
			if flyVariables._watchConn then
				pcall(function() flyVariables._watchConn:Disconnect() end)
				flyVariables._watchConn = nil
				NAlib.disconnect("fly_watch")
			end
			if type(NAmanage.CFlyClearVisualizer) == "function" then
				NAmanage.CFlyClearVisualizer()
			end
			NAmanage._destroyFlyHelper()
			return
		end
		local desired="none"
		if flyVariables.cFlyEnabled then desired="cfly"
		elseif flyVariables.TFlyEnabled then desired="tfly"
		elseif flyVariables.tpFlyEnabled then desired="tpfly"
		elseif flyVariables.vFlyEnabled then desired="vfly"
		elseif flyVariables.flyEnabled then desired="fly" end
		if NAmanage._state.mode=="none" and desired~="none" then
			NAmanage._state.mode=desired
		end
		if not FLYING then
			NAmanage._destroyFlyHelper()
			return
		end
		NAmanage._ensureWeldTarget()
		NAmanage._ensureForces()
		NAmanage._ensureLoops()
	end))
	NAmanage._bindCameraWatch()
end

NAmanage._waitForFlyCharacter = function(char, timeout)
	timeout = tonumber(timeout) or 6
	const started = os.clock()
	while os.clock() - started < timeout do
		const current = char or getChar()
		const root = current and getRoot(current)
		const hum = current and getHum(current)
		if current and current.Parent and root and hum then
			return current, root, hum
		end
		Wait()
	end
	const current = char or getChar()
	return current, current and getRoot(current) or nil, current and getHum(current) or nil
end

NAmanage._parkCFlyForRespawn = function(char)
	const wasCFly = flyVariables.cFlyEnabled == true or NAmanage._state.mode == "cfly"
	if not wasCFly then
		return false
	end
	flyVariables._cflyRespawnToken = (tonumber(flyVariables._cflyRespawnToken) or 0) + 1
	flyVariables._cflyRespawnPending = true
	flyVariables._cflyRespawnResume = FLYING == true
	if CFloop then
		pcall(function()
			CFloop:Disconnect()
		end)
	end
	CFloop = nil
	NAlib.disconnect("fly_cfly_loop")
	CONTROL = { Q = 0, E = 0 }
	lCONTROL = { Q = 0, E = 0 }
	SPEED = 0
	NAmanage.ClearVelocityWalkSpeedClampState()
	if type(NAmanage.CFlyClearVisualizer) == "function" then
		NAmanage.CFlyClearVisualizer()
	end
	NAmanage._unanchorFlyCharacter(char)
	NAmanage._restoreFlyHumanoidState(getHum(char))
	NAmanage._destroyFlyHelper()
	NAmanage._releaseQE()
	FLYING = false
	flyVariables.cFlyEnabled = true
	NAmanage._state.mode = "cfly"
	NAmanage._persist.lastMode = "cfly"
	NAmanage._persist.wasFlying = true
	NAmanage._persist.resumeAfterSpawn = true
	NAmanage.startWatcher()
	return true
end

NAmanage._resumeCFlyAfterRespawn = function(char, token)
	Spawn(function()
		local current, root, hum = NAmanage._waitForFlyCharacter(char, 6)
		if token ~= flyVariables._cflyRespawnToken then
			return
		end
		if not current or not root or not hum then
			return
		end
		if flyVariables.cFlyEnabled ~= true and NAmanage._state.mode ~= "cfly" then
			return
		end
		NAmanage._unanchorFlyCharacter(current)
		Wait()
		if token ~= flyVariables._cflyRespawnToken then
			return
		end
		if flyVariables.cFlyEnabled ~= true and NAmanage._state.mode ~= "cfly" then
			return
		end
		flyVariables.cFlyEnabled = true
		NAmanage._state.mode = "cfly"
		NAmanage._persist.lastMode = "cfly"
		NAmanage._applyMode("cfly", flyVariables._cflyRespawnResume ~= false)
		flyVariables._cflyRespawnPending = false
		flyVariables._cflyRespawnResume = nil
		NAmanage._persist.resumeAfterSpawn = false
	end)
end

NAmanage._bindFlyCharacterCleanup = function()
	const lp = Services.Players and Services.Players.LocalPlayer
	if not lp then
		return
	end
	if lp.CharacterRemoving then
		NAlib.reconnect("fly_char_removing_cleanup", lp.CharacterRemoving:Connect(function(char)
			if NAmanage._parkCFlyForRespawn(char) then
				return
			end
			NAmanage._unanchorFlyCharacter(char)
		end))
	end
	NAlib.reconnect("fly_char_added_cleanup", lp.CharacterAdded:Connect(function(char)
		const shouldResume = flyVariables._cflyRespawnPending == true or flyVariables.cFlyEnabled == true or NAmanage._state.mode == "cfly"
		if shouldResume then
			const token = tonumber(flyVariables._cflyRespawnToken) or 0
			NAmanage._resumeCFlyAfterRespawn(char, token)
		else
			Spawn(function()
				NAmanage._waitForFlyCharacter(char, 6)
				NAmanage._unanchorFlyCharacter(char)
			end)
		end
	end))
end

NAmanage._bindFlyCharacterCleanup()

NAmanage._forceEnableFlags = function(mode)
	flyVariables.flyEnabled=(mode=="fly")
	flyVariables.vFlyEnabled=(mode=="vfly")
	flyVariables.cFlyEnabled=(mode=="cfly")
	flyVariables.TFlyEnabled=(mode=="tfly")
	flyVariables.tpFlyEnabled=(mode=="tpfly")
end

NAmanage._applyMode = function(mode, resume)
	if CFloop then pcall(function() CFloop:Disconnect() end) end
	CFloop=nil
	NAmanage._forceEnableFlags(mode)
	NAmanage._state.mode=mode
	if mode=="cfly" then
		if type(NAmanage.CFlyStartVisualizer) == "function" then
			const char = getChar()
			const root = char and NAmanage._getCFlyTarget(char) or nil
			NAmanage.CFlyStartVisualizer(root, true)
		end
		NAmanage.sFLY(false,true,false)
	elseif mode=="tfly" then
		NAmanage.sFLY(false,false,true,false)
	elseif mode=="tpfly" then
		NAmanage.sFLY(false,false,false,true)
	elseif mode=="vfly" then
		NAmanage.sFLY(true,false,false,false)
	else
		NAmanage.sFLY(false,false,false,false)
	end
	if resume then
		NAmanage.resumeCurrent()
	else
		NAmanage.pauseCurrent()
	end
	NAmanage._ensureMobileFlyUI(mode)
	NAmanage.startWatcher()
	NAmanage._bindCameraWatch()
end

NAmanage.activateMode = function(mode, opts)
	opts = type(opts) == "table" and opts or {}
	const shouldResume = opts.resume ~= false
	const currentMode=NAmanage._state.mode
	if currentMode and currentMode~="none" and currentMode~=mode then
		NAmanage.deactivateMode(currentMode)
	end
	NAmanage._state.mode=mode
	NAmanage._forceEnableFlags(mode)
	const char=getChar()
	const root=char and getRoot(char) or nil
	const hum=char and getHum(char) or nil
	if char and root and hum then
		NAmanage._applyMode(mode, shouldResume)
		return
	end
	NAmanage._persist.lastMode=mode
	NAmanage._persist.resumeAfterSpawn=shouldResume
	if NAlib.isConnected("fly_pending_char") then
		NAlib.disconnect("fly_pending_char")
	end
	NAlib.connect("fly_pending_char", Services.Players.LocalPlayer.CharacterAdded:Connect(function()
		Spawn(function()
			local t=0
			while t<5 and (not getChar() or not getRoot(getChar()) or not getHum()) do
				t+=(Wait() or 0.03)
			end
			NAmanage._applyMode(mode, shouldResume)
			NAmanage._persist.resumeAfterSpawn=false
			NAlib.disconnect("fly_pending_char")
		end)
	end))
end

NAmanage.activateFlightModeFromCommand = function(mode)
	local shouldResume = true
	if IsOnMobile then
		shouldResume = NAStuff.MobileFlyAutoEnableOnRun ~= false
	end
	NAmanage.activateMode(mode, {
		resume = shouldResume;
	})
	if IsOnMobile and shouldResume and NAmanage._state.mode == mode and not FLYING then
		NAmanage.resumeCurrent()
	end
end

NAmanage.keyToggle=function(mode)
	NAmanage._keyToggleLast = NAmanage._keyToggleLast or {}
	const now = os.clock()
	const cooldown = tonumber(NAmanage._keyToggleCooldown) or 0.12
	const last = NAmanage._keyToggleLast[mode]
	if last and (now - last) < cooldown then
		return
	end
	NAmanage._keyToggleLast[mode] = now
	if NAmanage._state.mode~=mode then return end
	if not NAmanage._modeEnabled(mode) then return end
	if FLYING then NAmanage.pauseCurrent() else NAmanage.resumeCurrent() end
end

NAmanage.toggleFly=function()
	if not flyVariables.flyEnabled then
		NAmanage.activateMode("fly")
	else
		if NAmanage._state.mode~="fly" then
			NAmanage.activateMode("fly")
		else
			if FLYING then NAmanage.pauseCurrent() else NAmanage.resumeCurrent() end
		end
	end
end

NAmanage.toggleVFly=function()
	if not flyVariables.vFlyEnabled then
		NAmanage.activateMode("vfly")
	else
		if NAmanage._state.mode~="vfly" then
			NAmanage.activateMode("vfly")
		else
			if FLYING then NAmanage.pauseCurrent() else NAmanage.resumeCurrent() end
		end
	end
end

NAmanage.toggleCFly=function()
	if not flyVariables.cFlyEnabled then
		NAmanage.activateMode("cfly")
	else
		if NAmanage._state.mode~="cfly" then
			NAmanage.activateMode("cfly")
		else
			if FLYING then NAmanage.pauseCurrent() else NAmanage.resumeCurrent() end
		end
	end
end

NAmanage.toggleTFly=function()
	if not flyVariables.TFlyEnabled then
		NAmanage.activateMode("tfly")
	else
		if NAmanage._state.mode~="tfly" then
			NAmanage.activateMode("tfly")
		else
			if FLYING then NAmanage.pauseCurrent() else NAmanage.resumeCurrent() end
		end
	end
end

NAmanage.toggleTPFly=function()
	if not flyVariables.tpFlyEnabled then
		NAmanage.activateMode("tpfly")
	else
		if NAmanage._state.mode~="tpfly" then
			NAmanage.activateMode("tpfly")
		else
			if FLYING then NAmanage.pauseCurrent() else NAmanage.resumeCurrent() end
		end
	end
end

NAmanage._shouldIgnoreFlyKeyInput = function(input, gameProcessed)
	if gameProcessed then
		return true
	end
	if not input or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return true
	end
	if NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive() then
		return true
	end
	return false
end

NAmanage._connectFlyToggleKey = function(connField, keyField, mode)
	const oldConn = flyVariables[connField]
	if oldConn then
		oldConn:Disconnect()
		flyVariables[connField] = nil
	end
	flyVariables[connField] = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if NAmanage._shouldIgnoreFlyKeyInput(input, gameProcessed) then
			return
		end
		const targetKey = Lower(tostring(flyVariables[keyField] or ""))
		if targetKey == "" then
			return
		end
		const keyName = Lower(tostring(input.KeyCode.Name or ""))
		if keyName ~= targetKey then
			return
		end
		NAmanage.keyToggle(mode)
	end)
end

NAmanage.connectFlyKey=function()
	NAmanage._connectFlyToggleKey("keybindConn", "toggleKey", "fly")
end

NAmanage.connectVFlyKey=function()
	NAmanage._connectFlyToggleKey("vKeybindConn", "vToggleKey", "vfly")
end

NAmanage.connectCFlyKey=function()
	NAmanage._connectFlyToggleKey("cKeybindConn", "cToggleKey", "cfly")
end

NAmanage.connectTFlyKey=function()
	NAmanage._connectFlyToggleKey("tflyKeyConn", "tflyToggleKey", "tfly")
end

NAmanage.connectTPFlyKey=function()
	NAmanage._connectFlyToggleKey("tpFlyKeyConn", "tpFlyToggleKey", "tpfly")
end

NAmanage.readAliasFile = function()
	if not (FileSupport and isfile(NAfiles.NAALIASPATH)) then
		return {}
	end

	local okRead, raw = pcall(readfile, NAfiles.NAALIASPATH)
	if not okRead or type(raw) ~= "string" then
		return {}
	end

	local okDecode, decoded = pcall(function()
		return Services.HttpService:JSONDecode(raw)
	end)
	if okDecode and type(decoded) == "table" then
		return decoded
	end

	const trimmed = raw:match("^%s*(.-)%s*$") or ""
	if trimmed ~= "" then
		const backupPath = NAfiles.NAALIASPATH .. ".corrupt_" .. tostring(os.time()) .. ".json"
		pcall(writefile, backupPath, raw)
		NAmanage.loaderWarn('Aliases', ('failed to decode storage; backed up to %s, resetting'):format(backupPath))
	end
	pcall(writefile, NAfiles.NAALIASPATH, Services.HttpService:JSONEncode({}))
	return {}
end

NAmanage.loadAliases = function()
	const aliasMap = NAmanage.readAliasFile()
	for alias, original in aliasMap do
		if type(alias) == "string" and type(original) == "string" then
			const aliasLower = alias:lower()
			const originalLower = original:lower()
			const command = cmds.Commands[originalLower]
			if command then
				cmds.Aliases[aliasLower] = command
				cmds.NASAVEDALIASES[aliasLower] = originalLower
			end
		end
	end
end

NAmanage.decodeUserButtons=function(raw)
	if type(raw) ~= "string" or raw == "" then
		return nil
	end
	local ok, decoded = pcall(function()
		return Services.HttpService:JSONDecode(raw)
	end)
	if ok and type(decoded) == "table" then
		return decoded
	end
	return nil
end

NAmanage.ubNorm=function(dt)
	const norm = {}
	local chg = false
	if type(dt) ~= "table" then
		return norm, false
	end
	for id, entry in dt do
		if type(id) == "number" then
			norm[id] = entry
		else
			chg = true
		end
	end
	for id, entry in dt do
		if type(id) == "string" then
			const n = tonumber(id)
			if n and norm[n] == nil then
				norm[n] = entry
				chg = true
			end
		end
	end
	return norm, chg
end

NAmanage.UserButtonsSave = function(reason, data)
	local pay = data or NAUserButtons or {}
	local norm, chg = NAmanage.ubNorm(pay)
	if chg then
		pay = norm
		if data == nil or data == NAUserButtons then
			NAUserButtons = norm
		end
	end

	if not FileSupport then
		return true
	end

	const path = NAfiles.NAUSERBUTTONSPATH
	const backupPath = path..".bak"
	local okEncode, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, pay)
	if not okEncode then
		NAmanage.loaderWarn('UserButtons', 'failed to encode data'..(reason and (' ('..reason..')') or '')..': '..tostring(encoded))
		return false
	end

	local okRead, existing = pcall(readfile, path)
	if okRead and type(existing) == "string" and existing ~= "" then
		pcall(writefile, backupPath, existing)
	end

	local okWrite, errWrite = pcall(writefile, path, encoded)
	if not okWrite then
		if okRead and type(existing) == "string" then
			pcall(writefile, path, existing)
		end
		NAmanage.loaderWarn('UserButtons', 'failed to save data'..(reason and (' ('..reason..')') or '')..': '..tostring(errWrite))
		return false
	end

	return true
end

NAmanage.loadButtonIDS = function()
	if not FileSupport then
		NAUserButtons = NAUserButtons or {}
		return true
	end

	const path = NAfiles.NAUSERBUTTONSPATH

	if not (isfile and isfile(path)) then
		local okCreate, createErr = pcall(function()
			writefile(path, Services.HttpService:JSONEncode({}))
		end)
		if not okCreate then
			NAmanage.loaderWarn('UserButtons', 'failed to create storage: '..tostring(createErr))
			return false
		end
	end

	local okRead, raw = pcall(readfile, path)
	if not okRead or type(raw) ~= "string" then
		NAmanage.loaderWarn('UserButtons', 'failed to read storage: '..tostring(raw))
		return false
	end

	const decoded = NAmanage.decodeUserButtons(raw)
	if not decoded then
		local backup = nil
		local okBackup, rawBackup = pcall(readfile, path..".bak")
		if okBackup then
			backup = NAmanage.decodeUserButtons(rawBackup)
		end

		if backup then
			NAmanage.loaderWarn('UserButtons', 'storage corrupted; recovered from backup')
			NAUserButtons = backup
			NAmanage.UserButtonsSave("restore backup")
			return true
		end

		NAmanage.loaderWarn('UserButtons', 'invalid storage data; resetting')
		NAUserButtons = {}
		NAmanage.UserButtonsSave("reset invalid data")
		return false
	end

	local norm, normChg = NAmanage.ubNorm(decoded)
	NAUserButtons = norm
	local chg = normChg

	for _, data in NAUserButtons do
		if type(data) == "table" and type(data.Keybind) == "string" and data.Keybind ~= "" then
			const keyName = NAmanage.CKBNorm(data.Keybind) or data.Keybind

			if CommandKeybinds[keyName] == nil then
				const parts = {}
				if type(data.Cmd1) == "string" and data.Cmd1 ~= "" then
					Insert(parts, data.Cmd1)
				end
				if type(data.Args) == "table" then
					for _, v in data.Args do
						Insert(parts, tostring(v))
					end
				end
				if #parts > 0 then
					CommandKeybinds[keyName] = parts
				end
			end

			data.Keybind = nil
			chg = true
		end
	end

	if chg and FileSupport then
		NAmanage.UserButtonsSave("normalize ids")
	end
	NAmanage.SaveCommandKeybinds()
	NAmanage.ApplyCommandKeybinds()
	return true
end

function NAUserButtonNextId()
	local maxId = 0
	for id in NAUserButtons do
		if type(id) == "number" and id > maxId then
			maxId = id
		end
	end
	return maxId + 1
end

function NAUserButtonCloneAsChild(data, fallbackLabel)
	if type(data) ~= "table" then
		return nil
	end
	const label = (type(data.Label) == "string" and data.Label ~= "" and data.Label) or fallbackLabel or "Button"
	const child = {
		Label = label,
		Cmd1 = data.Cmd1,
		Cmd2 = data.Cmd2,
		Args = (type(data.Args) == "table") and originalIO.deepCopyTable(data.Args) or nil,
		ArgsSaved = data.ArgsSaved,
		RunMode = data.RunMode,
		BgColor = data.BgColor,
		TextColor = data.TextColor,
		Width = data.Width,
		Height = data.Height,
		CornerRadius = data.CornerRadius,
		Hidden = data.Hidden,
		Interactable = data.Interactable,
		Locked = data.Locked,
		Pos = data.Pos and originalIO.deepCopyTable(data.Pos),
	}
	return child
end

function NAUserButtonCollectChildren(store, entry, fallbackLabel)
	if type(entry) ~= "table" then
		return
	end
	if entry.Type == "group" and type(entry.Children) == "table" then
		for _, child in entry.Children do
			const clone = NAUserButtonCloneAsChild(child, fallbackLabel)
			if clone then
				Insert(store, clone)
			end
		end
	else
		const clone = NAUserButtonCloneAsChild(entry, fallbackLabel)
		if clone then
			Insert(store, clone)
		end
	end
end

function NAUserButtonRectOverlap(posA, sizeA, posB, sizeB, padding)
	padding = padding or 0
	if not (posA and sizeA and posB and sizeB) then return false end
	return not (
		posA.X + sizeA.X < posB.X - padding
			or posB.X + sizeB.X < posA.X - padding
			or posA.Y + sizeA.Y < posB.Y - padding
			or posB.Y + sizeB.Y < posA.Y - padding
	)
end

NAmanage.UserButtons_CombineButtons = function(targetId, sourceId, opts)
	opts = opts or {}
	if type(targetId) ~= "number" or type(sourceId) ~= "number" then
		return false, "Invalid button ids."
	end
	if targetId == sourceId then
		return false, "Pick two different buttons to combine."
	end

	const target = NAUserButtons[targetId]
	const source = NAUserButtons[sourceId]
	if type(target) ~= "table" or type(source) ~= "table" then
		return false, "One of the buttons is missing."
	end
	if target.Locked or source.Locked then
		return false, "Locked buttons cannot be combined."
	end

	const children = {}
	const targetLabel = (type(target.Label) == "string" and target.Label ~= "" and target.Label) or ("Button "..targetId)
	const sourceLabel = (type(source.Label) == "string" and source.Label ~= "" and source.Label) or ("Button "..sourceId)

	NAUserButtonCollectChildren(children, target, targetLabel)
	NAUserButtonCollectChildren(children, source, sourceLabel)

	target.Type = "group"
	target.Children = children
	target.GroupMode = (opts.mode == "side") and "side" or "dropdown"
	target.Cmd1, target.Cmd2, target.Args, target.RunMode = nil, nil, nil, nil

	NAUserButtons[sourceId] = nil
	originalIO.clearUserButtonState(sourceId)
	originalIO.clearUserButtonState(targetId)

	NAmanage.UserButtonsSave("combine buttons")

	return true, ("Grouped %d buttons"):format(#children)
end

NAmanage.UserButtons_CheckCombine = function(sourceId, sourceBtn)
	if type(sourceId) ~= "number" then
		return
	end
	if not (sourceBtn and sourceBtn.AbsolutePosition) then
		return
	end
	const sourceData = NAUserButtons[sourceId]
	if type(sourceData) ~= "table" or sourceData.Locked then
		return
	end

	const srcPos = sourceBtn.AbsolutePosition
	const srcSize = sourceBtn.AbsoluteSize
	local candidateId

	for id, btn in UserButtonGuiMap do
		if id ~= sourceId and btn and btn.Parent and btn.Visible then
			if NAUserButtonRectOverlap(srcPos, srcSize, btn.AbsolutePosition, btn.AbsoluteSize, 6) then
				candidateId = id
				break
			end
		end
	end

	if not candidateId then
		return
	end

	const targetData = NAUserButtons[candidateId]
	if type(targetData) ~= "table" or targetData.Locked then
		return
	end

	const srcLabel = (type(sourceData.Label) == "string" and sourceData.Label ~= "" and sourceData.Label) or ("Button "..sourceId)
	const targetLabel = (type(targetData.Label) == "string" and targetData.Label ~= "" and targetData.Label) or ("Button "..candidateId)

	Window({
		Title = "Combine User Buttons",
		Description = ("Merge [%d] %s into [%d] %s?"):format(sourceId, srcLabel, candidateId, targetLabel),
		Buttons = {
			{
				Text = "Dropdown Toggle",
				Callback = function()
					local ok, msg = NAmanage.UserButtons_CombineButtons(candidateId, sourceId, { mode = "dropdown" })
					if ok then
						DoNotif("Created dropdown group", 2)
						NAmanage.RenderUserButtons()
					else
						DoNotif(msg or "Failed to combine buttons", 3)
					end
				end
			},
			{
				Text = "Side Toggle",
				Callback = function()
					local ok, msg = NAmanage.UserButtons_CombineButtons(candidateId, sourceId, { mode = "side" })
					if ok then
						DoNotif("Created side group", 2)
						NAmanage.RenderUserButtons()
					else
						DoNotif(msg or "Failed to combine buttons", 3)
					end
				end
			},
			{
				Text = "Cancel",
				Callback = function() end
			},
		}
	})
end

NAmanage.UserButtons_Ungroup = function(groupId)
	if type(groupId) ~= "number" then
		return false, "Invalid group id"
	end
	const group = NAUserButtons[groupId]
	if type(group) ~= "table" or group.Type ~= "group" then
		return false, "Selected item is not a group"
	end

	const children = (type(group.Children) == "table") and group.Children or {}
	if #children == 0 then
		NAUserButtons[groupId] = nil
		originalIO.clearUserButtonState(groupId)
		NAmanage.UserButtonsSave("ungroup empty")
		return true, "Removed empty group"
	end

	const basePos = group.Pos
	local offset = 0
	const offsetStep = 70
	for _, child in children do
		const newId = NAUserButtonNextId()
		const clone = NAUserButtonCloneAsChild(child, child.Label)
		if basePos and type(basePos) == "table" then
			clone.Pos = {
				basePos[1] or 0,
				(basePos[2] or 0) + offset,
				basePos[3] or 0,
				basePos[4] or 0,
			}
			offset = offset + offsetStep
		else
			clone.Pos = nil
		end
		NAUserButtons[newId] = clone
	end

	NAUserButtons[groupId] = nil
	originalIO.clearUserButtonState(groupId)

	NAmanage.UserButtonsSave("ungroup")
	return true, ("Ungrouped %d buttons"):format(#children)
end

NAmanage.AutoExecSave = function(data, context)
	if not FileSupport then return true end

	const out = { commands = {} }
	const src = (type(data) == "table" and type(data.commands) == "table") and data.commands or {}

	for i = 1, #src do
		const it = src[i]
		local c, a

		if type(it) == "table" then
			c = it.c or it.cmd or it.command or it[1]
			a = it.a or it.args or it.arguments or it[2] or ""
		elseif type(it) == "string" then
			c = NAmanage.resolveCommandName(it:lower()) or it:lower()
			a = (type(data) == "table" and data.args and (data.args[it] or data.args[c])) or ""
		end

		if type(c) == "string" then
			if type(a) ~= "string" then
				a = tostring(a or "")
			end
			out.commands[#out.commands + 1] = { c = c:lower(), a = a }
		end
	end

	local ok, err = pcall(function()
		writefile(NAfiles.NAAUTOEXECPATH, Services.HttpService:JSONEncode(out))
	end)

	if not ok then
		if context == "loader" then
			NAmanage.loaderWarn("AutoExec", "failed to update storage: " .. tostring(err))
		else
			warn("[NA] AutoExec save failed: " .. tostring(err))
		end
	end

	return ok
end

NAmanage.loadAutoExec = function()
	const cur = NAEXECDATA or { commands = {}, args = {} }
	const path = NAfiles.NAAUTOEXECPATH

	if not FileSupport then
		NAEXECDATA = cur
		return true
	end

	if not (isfile and isfile(path)) then
		local okc, erc = pcall(function()
			writefile(path, Services.HttpService:JSONEncode({ commands = {}, args = {} }))
		end)
		if not okc then
			NAmanage.loaderWarn("AutoExec", "failed to create storage: " .. tostring(erc))
			return false
		end
	end

	local okr, raw = pcall(readfile, path)
	if not okr or type(raw) ~= "string" then
		NAmanage.loaderWarn("AutoExec", "failed to read storage: " .. tostring(raw))
		return false
	end

	local okd, dec = pcall(function()
		return Services.HttpService:JSONDecode(raw)
	end)

	if not okd or type(dec) ~= "table" then
		const tr = (type(raw) == "string") and raw:match("^%s*(.-)%s*$") or ""
		if tr == "" then
			dec = { commands = {}, args = {} }
		else
			const bkp = path .. ".corrupt_" .. tostring(os.time()) .. ".json"
			pcall(writefile, bkp, raw)
			NAmanage.loaderWarn("AutoExec", ("failed to decode storage; backed up to %s, resetting"):format(bkp))
			local okrs, er2 = pcall(function()
				writefile(path, Services.HttpService:JSONEncode({ commands = {}, args = {} }))
			end)
			if not okrs then
				NAmanage.loaderWarn("AutoExec", "failed to reset storage: " .. tostring(er2))
				return false
			end
			dec = { commands = {}, args = {} }
		end
	end

	local src = dec.commands
	local largs = dec.args

	if type(src) ~= "table" then
		if dec[1] ~= nil then
			src = dec
		else
			src = {}
		end
	end
	if type(largs) ~= "table" then
		largs = {}
	end

	const blk = (NAStuff and type(NAStuff.AutoExecBlockedCommands) == "table") and NAStuff.AutoExecBlockedCommands or {}

	local canRes = type(NAmanage.resolveCommandName) == "function"
		and type(cmds) == "table"
		and type(cmds.Commands) == "table"
		and type(cmds.Aliases) == "table"

	const out = {}
	const seen = {}
	local mod = false

	for i = 1, #src do
		const it = src[i]
		local rn, ra

		if type(it) == "string" then
			rn = it
			ra = largs[it] or ""
			mod = true
		elseif type(it) == "table" then
			rn = it.c or it.cmd or it.command or it[1]
			ra = it.a or it.args or it.arguments or it[2] or ""
		end

		if type(rn) == "string" then
			const low = rn:lower()
			local base = nil

			if canRes then
				local ok, res = pcall(NAmanage.resolveCommandName, low)
				if ok then
					base = res
				else
					canRes = false
				end
			end

			const cn = base or low

			if base and blk[base] then
				mod = true
			else
				if type(ra) ~= "string" then
					ra = tostring(ra or "")
					mod = true
				end

				const k = cn .. "\n" .. ra
				if not seen[k] then
					seen[k] = true
					out[#out + 1] = { c = cn, a = ra }
				else
					mod = true
				end
			end
		else
			mod = true
		end
	end

	const nd = { commands = out, args = {} }

	if mod then
		NAmanage.AutoExecSave(nd, "loader")
	end

	NAEXECDATA = nd
	return true
end

NAmanage.PluginNormalizePath = NAmanage.PluginNormalizePath or function(path)
	return Lower(tostring(path or ""):gsub("\\", "/"):gsub("/+", "/"))
end

NAmanage.PluginBaseName = NAmanage.PluginBaseName or function(path)
	return (tostring(path or ""):match("[^\\/]+$") or tostring(path or ""))
end

NAmanage.PluginIsIgnoredFile = NAmanage.PluginIsIgnoredFile or function(path)
	const base = NAmanage.PluginBaseName(path)
	return type(base) == "string" and base:lower() == "iy_fe.iy"
end

NAmanage.PluginDisabledMap = NAmanage.PluginDisabledMap or function()
	local stored = NAmanage.NASettingsGet and NAmanage.NASettingsGet("pluginDisabled") or {}
	if type(stored) ~= "table" then
		stored = {}
	end
	return stored
end

NAmanage.PluginSaveDisabledMap = NAmanage.PluginSaveDisabledMap or function(map)
	map = type(map) == "table" and map or {}
	if NAmanage.NASettingsSet then
		return NAmanage.NASettingsSet("pluginDisabled", map)
	end
	return map
end

NAmanage.PluginIsDisabled = NAmanage.PluginIsDisabled or function(path)
	const map = NAmanage.PluginDisabledMap()
	const key = NAmanage.PluginNormalizePath(path)
	const base = NAmanage.PluginBaseName(path)
	return map[key] == true or (base ~= "" and map[Lower(base)] == true)
end

NAmanage.PluginSetEnabled = NAmanage.PluginSetEnabled or function(path, enabled)
	const map = {}
	for k, v in NAmanage.PluginDisabledMap() do
		if v == true then
			map[k] = true
		end
	end
	const key = NAmanage.PluginNormalizePath(path)
	if key == "" then
		return false
	end
	if enabled then
		map[key] = nil
		const base = Lower(NAmanage.PluginBaseName(path))
		if base ~= "" then
			map[base] = nil
		end
	else
		map[key] = true
	end
	NAmanage.PluginSaveDisabledMap(map)
	return true
end

NAmanage.PluginListFiles = NAmanage.PluginListFiles or function(includeWorkspace)
	const entries = {}
	const function addDir(dir, kind, extPat)
		if type(dir) ~= "string" or dir == "" or not (isfolder and isfolder(dir)) then
			return
		end
		local ok, items = pcall(listfiles, dir)
		if not ok or type(items) ~= "table" then
			return
		end
		for _, path in items do
			if type(path) == "string" and Lower(path):match(extPat) and not NAmanage.PluginIsIgnoredFile(path) then
				const key = NAmanage.PluginNormalizePath(path)
				const meta = NAmanage._pluginFileMeta and NAmanage._pluginFileMeta[key] or nil
				Insert(entries, {
					path = path,
					key = key,
					name = NAmanage.PluginBaseName(path),
					kind = kind,
					enabled = not NAmanage.PluginIsDisabled(path),
					loaded = meta and meta.loaded == true or false,
					commands = meta and type(meta.commands) == "table" and meta.commands or {},
				})
			end
		end
	end
	addDir(NAfiles and NAfiles.NAPLUGINFILEPATH, ".na", "%.na$")
	addDir(NAfiles and NAfiles.NAIYPLUGINFILEPATH, ".iy", "%.iy$")
	table.sort(entries, function(a, b)
		if a.enabled ~= b.enabled then
			return a.enabled == true
		end
		if a.kind ~= b.kind then
			return tostring(a.kind) < tostring(b.kind)
		end
		return tostring(a.name):lower() < tostring(b.name):lower()
	end)
	return entries
end

NAmanage.PluginJoinPath = NAmanage.PluginJoinPath or function(dir, name)
	dir = tostring(dir or "")
	name = tostring(name or "")
	return (#dir > 0) and (dir.."/"..name) or name
end

NAmanage.PluginUniquePath = NAmanage.PluginUniquePath or function(dir, fileName)
	const name = tostring(fileName or "")
	local base, ext = name:match("^(.*)(%.[^%.]+)$")
	base, ext = base or name, ext or ""
	local path = NAmanage.PluginJoinPath(dir, name)
	if not (isfile and isfile(path)) then
		return path
	end
	local i = 1
	repeat
		path = NAmanage.PluginJoinPath(dir, Format("%s (%d)%s", base, i, ext))
		i += 1
	until not (isfile and isfile(path))
	return path
end

NAmanage.PluginWorkspaceRoot = NAmanage.PluginWorkspaceRoot or function()
	if not listfiles then return "" end
	for _, candidate in {"", ".", "/"} do
		local ok, items = pcall(listfiles, candidate)
		if ok and type(items) == "table" then
			return candidate
		end
	end
	return ""
end

NAmanage.PluginIsInstalledPath = NAmanage.PluginIsInstalledPath or function(path)
	const p = NAmanage.PluginNormalizePath(path)
	for _, dir in {NAfiles and NAfiles.NAPLUGINFILEPATH, NAfiles and NAfiles.NAIYPLUGINFILEPATH} do
		if type(dir) == "string" and dir ~= "" then
			const norm = NAmanage.PluginNormalizePath(dir):gsub("/+$", "")
			const tail = norm:match("([^/]+/[^/]+)$") or norm
			if p == norm or p:sub(1, #norm + 1) == (norm.."/") or p:find("/"..tail.."/", 1, true) then
				return true
			end
		end
	end
	return false
end

NAmanage.PluginListAvailable = NAmanage.PluginListAvailable or function()
	const entries = {}
	if not (listfiles and isfolder) then
		return entries
	end
	const function add(path)
		if type(path) ~= "string" or NAmanage.PluginIsIgnoredFile(path) or NAmanage.PluginIsInstalledPath(path) then
			return
		end
		const lowerPath = Lower(path)
		const kind = lowerPath:match("%.iy$") and ".iy" or (lowerPath:match("%.na$") and ".na" or nil)
		if not kind then return end
		Insert(entries, {
			path = path,
			key = NAmanage.PluginNormalizePath(path),
			name = NAmanage.PluginBaseName(path),
			kind = kind,
		})
	end
	const function scan(dir)
		local ok, items = pcall(listfiles, dir)
		if not ok or type(items) ~= "table" then return end
		for _, path in items do
			local okDir, isDir = pcall(isfolder, path)
			if okDir and isDir then
				if not NAmanage.PluginIsInstalledPath(path) then
					scan(path)
				end
			else
				add(path)
			end
		end
	end
	scan(NAmanage.PluginWorkspaceRoot())
	table.sort(entries, function(a, b)
		if a.kind ~= b.kind then
			return tostring(a.kind) < tostring(b.kind)
		end
		return tostring(a.name):lower() < tostring(b.name):lower()
	end)
	return entries
end

NAmanage.PluginAvailableCacheGet = NAmanage.PluginAvailableCacheGet or function(maxAge)
	const cache = NAStuff and NAStuff.PluginAvailableCache
	if type(cache) ~= "table" or type(cache.entries) ~= "table" then
		return nil
	end
	maxAge = tonumber(maxAge) or 30
	if maxAge > 0 and (tick() - (tonumber(cache.time) or 0)) > maxAge then
		return nil
	end
	return cache.entries
end

NAmanage.PluginScanAvailableAsync = NAmanage.PluginScanAvailableAsync or function(force, callback)
	if type(callback) == "function" then
		NAStuff.PluginAvailableCallbacks = NAStuff.PluginAvailableCallbacks or {}
		Insert(NAStuff.PluginAvailableCallbacks, callback)
	end
	if not force then
		const cached = NAmanage.PluginAvailableCacheGet and NAmanage.PluginAvailableCacheGet(30)
		if cached then
			const callbacks = NAStuff.PluginAvailableCallbacks or {}
			NAStuff.PluginAvailableCallbacks = {}
			for _, cb in callbacks do
				pcall(cb, cached)
			end
			return cached
		end
	end
	if NAStuff.PluginAvailableScanRunning then
		return nil
	end
	NAStuff.PluginAvailableScanRunning = true
	SpawnCall(function()
		const entries = {}
		const seen = {}
		const function add(path)
			if type(path) ~= "string" or seen[path] or NAmanage.PluginIsIgnoredFile(path) or NAmanage.PluginIsInstalledPath(path) then
				return
			end
			const lowerPath = Lower(path)
			const kind = lowerPath:match("%.iy$") and ".iy" or (lowerPath:match("%.na$") and ".na" or nil)
			if not kind then return end
			seen[path] = true
			Insert(entries, {
				path = path,
				key = NAmanage.PluginNormalizePath(path),
				name = NAmanage.PluginBaseName(path),
				kind = kind,
			})
		end
		const queue = {}
		if listfiles and isfolder then
			queue[1] = NAmanage.PluginWorkspaceRoot()
		end
		local head = 1
		local lastYield = os.clock()
		while head <= #queue do
			const dir = queue[head]
			head += 1
			local ok, items = pcall(listfiles, dir)
			if ok and type(items) == "table" then
				for _, path in items do
					local okDir, isDir = pcall(isfolder, path)
					if okDir and isDir then
						if not NAmanage.PluginIsInstalledPath(path) then
							Insert(queue, path)
						end
					else
						add(path)
					end
				end
			end
			if os.clock() - lastYield > 0.008 then
				Wait()
				lastYield = os.clock()
			end
		end
		table.sort(entries, function(a, b)
			if a.kind ~= b.kind then
				return tostring(a.kind) < tostring(b.kind)
			end
			return tostring(a.name):lower() < tostring(b.name):lower()
		end)
		NAStuff.PluginAvailableCache = {
			entries = entries,
			time = tick(),
		}
		NAStuff.PluginAvailableScanRunning = false
		const callbacks = NAStuff.PluginAvailableCallbacks or {}
		NAStuff.PluginAvailableCallbacks = {}
		for _, cb in callbacks do
			pcall(cb, entries)
		end
	end)
	return nil
end

NAmanage.PluginInstallFromWorkspace = NAmanage.PluginInstallFromWorkspace or function(path)
	if not FileSupport or type(path) ~= "string" or path == "" then
		return false, "file operations unavailable"
	end
	if NAmanage.PluginIsInstalledPath(path) then
		return false, "already installed"
	end
	const lowerPath = Lower(path)
	const dstDir = lowerPath:match("%.iy$") and (NAfiles and NAfiles.NAIYPLUGINFILEPATH) or (NAfiles and NAfiles.NAPLUGINFILEPATH)
	if type(dstDir) ~= "string" or dstDir == "" then
		return false, "plugin folder unavailable"
	end
	if not (isfolder and isfolder(dstDir)) and makefolder then
		pcall(makefolder, dstDir)
	end
	const fileName = NAmanage.PluginBaseName(path)
	if fileName == "" then
		return false, "invalid plugin path"
	end
	local okRead, data = pcall(readfile, path)
	if not okRead or data == nil then
		return false, "failed to read plugin"
	end
	const dst = NAmanage.PluginUniquePath(dstDir, fileName)
	const okWrite = pcall(writefile, dst, data)
	if not okWrite then
		return false, "failed to write plugin"
	end
	if delfile then
		const okDelete = pcall(delfile, path)
		if not okDelete then
			return false, "installed, but failed to delete original"
		end
	end
	NAmanage.PluginSetEnabled(dst, true)
	return true, dst
end

NAmanage.PluginNormalizeUrl = NAmanage.PluginNormalizeUrl or function(url)
	if typeof(url) ~= "string" then
		return nil
	end
	local t = url:match("^%s*(.-)%s*$") or ""
	if t == "" then
		return nil
	end
	t = t:gsub(" ", "%%20")
	const q = t:find("%?")
	const base = q and t:sub(1, q - 1) or t
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
	if base:match("^https?://") then
		return t
	end
	return nil
end

NAmanage.PluginFileNameFromUrl = NAmanage.PluginFileNameFromUrl or function(url)
	if type(url) ~= "string" then return nil end
	const base = (url:match("^([^%?#]+)") or url):gsub("/+$", "")
	local name = base:match("/([^/]+)$") or ""
	name = name:gsub("%%20", " ")
	name = name:match("^%s*(.-)%s*$") or ""
	name = name:gsub("[^%w%._%-]", "_"):gsub("_+", "_"):gsub("^_+", ""):gsub("_+$", "")
	if name == "" then return nil end
	return name
end

NAmanage.PluginInstallFromUrl = NAmanage.PluginInstallFromUrl or function(url)
	if not FileSupport then
		return false, "file operations unavailable"
	end
	const norm = NAmanage.PluginNormalizeUrl(url)
	if not norm then
		return false, "enter a valid plugin URL"
	end
	const fileName = NAmanage.PluginFileNameFromUrl(norm)
	if not fileName then
		return false, "unable to determine plugin filename"
	end
	const lowerName = Lower(fileName)
	const kind = lowerName:match("%.iy$") and ".iy" or (lowerName:match("%.na$") and ".na" or nil)
	if not kind then
		return false, "plugin URL must end with .na or .iy"
	end
	local okFetch, data = pcall(function()
		return NAmanage.HttpGetOrError(norm)
	end)
	if not (okFetch and type(data) == "string" and data ~= "") then
		return false, "unable to download plugin"
	end
	const dstDir = kind == ".iy" and (NAfiles and NAfiles.NAIYPLUGINFILEPATH) or (NAfiles and NAfiles.NAPLUGINFILEPATH)
	if type(dstDir) ~= "string" or dstDir == "" then
		return false, "plugin folder unavailable"
	end
	if not (isfolder and isfolder(dstDir)) and makefolder then
		pcall(makefolder, dstDir)
	end
	const dst = NAmanage.PluginUniquePath(dstDir, fileName)
	local okWrite, errWrite = pcall(writefile, dst, data)
	if not okWrite then
		return false, errWrite or "unable to save plugin"
	end
	NAmanage.PluginSetEnabled(dst, true)
	return true, dst
end

NAmanage.PluginMoveToWorkspace = NAmanage.PluginMoveToWorkspace or function(path)
	if not FileSupport or type(path) ~= "string" or path == "" then
		return false, "file operations unavailable"
	end
	const name = NAmanage.PluginBaseName(path)
	if name == "" then
		return false, "invalid plugin path"
	end
	local okRead, data = pcall(readfile, path)
	if not okRead or data == nil then
		return false, "failed to read plugin"
	end
	const dst = NAmanage.PluginUniquePath("", name)
	const okWrite = pcall(writefile, dst, data)
	if not okWrite then
		return false, "failed to write workspace copy"
	end
	if delfile then
		const okDelete = pcall(delfile, path)
		if not okDelete then
			return false, "copied, but failed to delete original"
		end
	end
	NAmanage.PluginSetEnabled(path, true)
	return true, dst
end

NAmanage.PluginUserButtonRequestRender = NAmanage.PluginUserButtonRequestRender or function()
	if NAStuff and NAStuff.PluginUserButtonRenderPaused then
		NAStuff.PluginUserButtonsDirty = true
		return true
	end
	if NAmanage and type(NAmanage.RenderUserButtons) == "function" then
		return pcall(NAmanage.RenderUserButtons)
	end
	return false
end

NAmanage.PluginUserButtonClear = NAmanage.PluginUserButtonClear or function(pluginKey)
	if type(pluginKey) ~= "string" or pluginKey == "" then
		return false
	end
	NAPluginUserButtons = NAPluginUserButtons or {}
	const hadButtons = NAPluginUserButtons[pluginKey] ~= nil
	NAPluginUserButtons[pluginKey] = nil
	NAmanage._pluginUserButtonSpecs = NAPluginUserButtons
	if hadButtons then
		NAStuff.PluginUserButtonsDirty = true
	end
	return hadButtons
end

NAmanage.PluginUserButtonNormalize = NAmanage.PluginUserButtonNormalize or function(spec, label, command, command2)
	const data = {}
	if type(spec) == "table" then
		for k, v in spec do
			data[k] = v
		end
	else
		data.Label = label or spec
		data.Cmd1 = command
		data.Cmd2 = command2
	end

	local cmd1 = data.Cmd1 or data.Command or data.command or data.Cmd or data.cmd or data.Run or data.run or data[2]
	local cmd2 = data.Cmd2 or data.Command2 or data.command2 or data.OffCommand or data.offCommand or data.DisableCommand or data.disableCommand or data.ToggleOff or data.toggleOff or data[3]
	const buttonLabel = data.Label or data.label or data.Text or data.text or data.Name or data.name or data.Title or data.title or data[1] or cmd1

	if type(cmd1) == "table" then
		cmd1 = cmd1[1]
	end
	if type(cmd2) == "table" then
		cmd2 = cmd2[1]
	end
	if type(cmd1) ~= "string" or cmd1 == "" then
		return nil, "missing command"
	end

	local args = data.Args or data.args or data.Arguments or data.arguments
	if type(args) ~= "table" then
		args = nil
	end

	const out = {
		Id = data.Id or data.id or data.ButtonId or data.buttonId,
		Label = tostring(buttonLabel or cmd1),
		Cmd1 = tostring(cmd1),
		Cmd2 = (type(cmd2) == "string" and cmd2 ~= "") and tostring(cmd2) or nil,
		Args = args,
		ArgsSaved = data.ArgsSaved == true or data.argsSaved == true or args ~= nil,
		RunMode = (data.RunMode == "S" or data.SaveArgs == true or data.saveArgs == true) and "S" or "N",
		BgColor = data.BgColor or data.bgColor or data.BackgroundColor or data.backgroundColor,
		TextColor = data.TextColor or data.textColor,
		Width = data.Width or data.width,
		Height = data.Height or data.height,
		CornerRadius = data.CornerRadius or data.cornerRadius,
		Hidden = data.Hidden == true or data.hidden == true,
		Interactable = not (data.Interactable == false or data.interactable == false),
		Locked = data.Locked == true or data.locked == true,
		Pos = data.Pos or data.Position or data.position,
		MobileOnly = data.MobileOnly == true or data.mobileOnly == true,
		PCOnly = data.PCOnly == true or data.pcOnly == true or data.DesktopOnly == true or data.desktopOnly == true,
		PluginButton = true,
	}
	if out.Id ~= nil then
		out.Id = tostring(out.Id)
	end

	const mode = tostring(data.Mode or data.mode or data.Type or data.type or ""):lower()
	if mode == "toggle" and not out.Cmd2 then
		out.Cmd2 = data.Off or data.off or data.Disable or data.disable
	end

	return out
end

NAmanage.PluginUserButtonAdd = NAmanage.PluginUserButtonAdd or function(pluginKey, fileName, spec, command, command2)
	if NAStuff and NAStuff.PluginSettingsUIEnabled == false then
		return false, "plugin UI controls disabled"
	end
	if type(pluginKey) ~= "string" or pluginKey == "" then
		return false, "invalid plugin"
	end
	local button, err = NAmanage.PluginUserButtonNormalize(spec, spec, command, command2)
	if not button then
		return false, err or "invalid button"
	end
	if (button.MobileOnly == true or button.mobileOnly == true) and not IsOnMobile then
		return false, "mobile only"
	end
	if (button.PCOnly == true or button.pcOnly == true or button.DesktopOnly == true or button.desktopOnly == true) and not IsOnPC then
		return false, "pc only"
	end

	NAPluginUserButtons = NAPluginUserButtons or {}
	local bucket = NAPluginUserButtons[pluginKey]
	if not bucket then
		bucket = {
			name = tostring(fileName or "Plugin"),
			items = {},
		}
		NAPluginUserButtons[pluginKey] = bucket
	end
	bucket.items = bucket.items or {}
	local id = button.Id
	if type(id) ~= "string" or id == "" then
		id = (button.Label or "").."|"..(button.Cmd1 or "").."|"..(button.Cmd2 or "")
		button.Id = id
	end
	for i = #bucket.items, 1, -1 do
		const existing = bucket.items[i]
		if type(existing) == "table" and existing.Id == id then
			table.remove(bucket.items, i)
		end
	end
	Insert(bucket.items, button)
	NAmanage._pluginUserButtonSpecs = NAPluginUserButtons
	NAStuff.PluginUserButtonsDirty = true
	NAmanage.PluginUserButtonRequestRender()
	return true, button
end

NAmanage.PluginUserButtonRemove = NAmanage.PluginUserButtonRemove or function(pluginKey, query)
	if type(pluginKey) ~= "string" or pluginKey == "" then
		return false, "invalid plugin"
	end
	NAPluginUserButtons = NAPluginUserButtons or {}
	const bucket = NAPluginUserButtons[pluginKey]
	const items = type(bucket) == "table" and bucket.items or nil
	if type(items) ~= "table" then
		return false, "no buttons"
	end
	local raw = query
	if type(raw) == "table" then
		raw = raw.Id or raw.id or raw.ButtonId or raw.buttonId or raw.Label or raw.label or raw.Command or raw.command or raw.Cmd1 or raw.cmd1
	end
	const needle = raw ~= nil and tostring(raw):lower() or nil
	local removed = 0
	for i = #items, 1, -1 do
		const item = items[i]
		if needle == nil
			or tostring(item.Id or ""):lower() == needle
			or tostring(item.Label or ""):lower() == needle
			or tostring(item.Cmd1 or ""):lower() == needle then
			table.remove(items, i)
			removed += 1
		end
	end
	if removed > 0 then
		NAmanage._pluginUserButtonSpecs = NAPluginUserButtons
		NAStuff.PluginUserButtonsDirty = true
		NAmanage.PluginUserButtonRequestRender()
		return true, removed
	end
	return false, "button not found"
end

NAmanage.PluginUIClear = NAmanage.PluginUIClear or function(pluginKey)
	if type(pluginKey) ~= "string" or pluginKey == "" then
		return
	end
	NAmanage._pluginControlSpecs = NAmanage._pluginControlSpecs or {}
	NAmanage._pluginControlSpecs[pluginKey] = nil
	if NAmanage.PluginUserButtonClear then
		pcall(NAmanage.PluginUserButtonClear, pluginKey)
	end
end

NAmanage.PluginUIFor = NAmanage.PluginUIFor or function(pluginKey, fileName, mode)
	NAmanage._pluginControlSpecs = NAmanage._pluginControlSpecs or {}
	const key = type(pluginKey) == "string" and pluginKey or tostring(pluginKey or "")
	const label = tostring(fileName or "Plugin")
	const function push(kind, tabName, data)
		if NAStuff and NAStuff.PluginSettingsUIEnabled == false then
			return false
		end
		if key == "" then
			return false
		end
		local bucket = NAmanage._pluginControlSpecs[key]
		if not bucket then
			bucket = {
				name = label,
				kind = mode == "iy" and ".iy" or ".na",
				items = {},
			}
			NAmanage._pluginControlSpecs[key] = bucket
		end
		data = type(data) == "table" and data or {}
		data.kind = kind
		data.tabName = tostring(tabName or "Controls")
		Insert(bucket.items, data)
		return true
	end
	const function makeApi(tabName)
		const api = {}
		api.addSection = function(text)
			return push("section", tabName, { label = tostring(text or "") })
		end
		api.addButton = function(text, callback)
			return push("button", tabName, { label = tostring(text or "Button"), callback = callback })
		end
		api.addInput = function(text, placeholder, defaultText, callback)
			return push("input", tabName, {
				label = tostring(text or "Input"),
				placeholder = tostring(placeholder or ""),
				defaultText = tostring(defaultText or ""),
				callback = callback,
			})
		end
		api.addToggle = function(text, defaultValue, callback)
			return push("toggle", tabName, {
				label = tostring(text or "Toggle"),
				defaultValue = defaultValue == true,
				callback = callback,
			})
		end
		api.addUserButton = function(spec, command, command2)
			return NAmanage.PluginUserButtonAdd(key, label, spec, command, command2)
		end
		api.removeUserButton = function(query)
			return NAmanage.PluginUserButtonRemove(key, query)
		end
		api.clearUserButtons = function()
			return NAmanage.PluginUserButtonRemove(key)
		end
		api.addCommandButton = api.addUserButton
		api.addMobileButton = api.addUserButton
		api.addToggleButton = function(text, onCommand, offCommand, opts)
			opts = type(opts) == "table" and opts or {}
			opts.Label = opts.Label or text
			opts.Cmd1 = opts.Cmd1 or opts.Command or onCommand
			opts.Cmd2 = opts.Cmd2 or opts.Command2 or offCommand
			opts.Mode = opts.Mode or "toggle"
			return NAmanage.PluginUserButtonAdd(key, label, opts)
		end
		api.addTab = function(name)
			return makeApi(tostring(name or "Controls"))
		end
		return api
	end
	return makeApi("Controls")
end
