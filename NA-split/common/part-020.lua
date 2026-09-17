NAmanage.ScriptHub_DownloadImage = function(url, generation)
	const hub = NAmanage.ScriptHub
	generation = tonumber(generation) or hub.imageGeneration
	if generation ~= hub.imageGeneration or type(url) ~= "string" or url == "" then
		return nil
	end
	if Match(url, "^rbxassetid://") or Match(url, "^rbxthumb://") then
		return url
	end
	const cached = hub.imageAssets[url]
	if type(cached) == "string" and cached ~= "" then
		return cached
	end
	if generation ~= hub.imageGeneration then
		return nil
	end
	if not NAmanage.ScriptHub_EnsureImageFolder() then
		return url
	end
	const path = NAmanage.ScriptHub_GetImagePath(url, generation)
	local exists = false
	if type(NAmanage.safeIsFile) == "function" then
		exists = NAmanage.safeIsFile(path)
	elseif type(isfile) == "function" then
		local okExists, value = pcall(isfile, path)
		exists = okExists and value == true
	end
	if not exists then
		local body
		for _, targetUrl in NAmanage.ScriptHub_GetImageTargets(url) do
			if generation ~= hub.imageGeneration then
				return nil
			end
			local okGet, result = NAmanage.HttpGet(targetUrl, {
				timeout = 12;
				maxAttempts = 2;
				Headers = NAmanage.ScriptHub_GetImageHeaders(targetUrl);
			})
			if generation ~= hub.imageGeneration then
				return nil
			end
			if okGet and type(result) == "string" and result ~= "" then
				body = result
				break
			end
		end
		if generation ~= hub.imageGeneration then
			return nil
		end
		if type(body) ~= "string" or body == "" then
			return url
		end
		local okWrite
		if type(NAmanage.safeWriteFile) == "function" then
			okWrite = NAmanage.safeWriteFile(path, body)
		else
			okWrite = pcall(writefile, path, body)
		end
		if generation ~= hub.imageGeneration then
			if okWrite == true then
				if type(NAmanage.safeDeleteFile) == "function" then
					NAmanage.safeDeleteFile(path)
				elseif type(delfile) == "function" then
					pcall(delfile, path)
				end
			end
			return nil
		end
		if okWrite ~= true then
			return url
		end
	end
	if generation ~= hub.imageGeneration then
		return nil
	end
	local okAsset, asset = pcall(getcustomasset, path)
	if generation ~= hub.imageGeneration then
		return nil
	end
	if okAsset and type(asset) == "string" and asset ~= "" then
		hub.imageAssets[url] = asset
		return asset
	end
	return url
end

NAmanage.ScriptHub_ApplyImage = function(imageLabel, asset)
	if not (imageLabel and imageLabel:IsA("ImageLabel") and type(asset) == "string" and asset ~= "") then
		return
	end
	imageLabel.Image = asset
	imageLabel.ImageTransparency = math.clamp(tonumber(imageLabel:GetAttribute("NAScriptHubLoadedTransparency")) or 0, 0, 1)
end

NAmanage.ScriptHub_LoadImage = function(imageLabel, url)
	const hub = NAmanage.ScriptHub
	if not (imageLabel and imageLabel:IsA("ImageLabel") and type(url) == "string" and url ~= "") then
		return
	end
	if Match(url, "^rbxassetid://") or Match(url, "^rbxthumb://") then
		NAmanage.ScriptHub_ApplyImage(imageLabel, url)
		return
	end
	const cached = hub.imageAssets[url]
	if type(cached) == "string" and cached ~= "" then
		NAmanage.ScriptHub_ApplyImage(imageLabel, cached)
		return
	end
	const generation = hub.imageGeneration
	const pendingKey = tostring(generation).."|"..url
	if type(hub.imagePending[pendingKey]) == "table" then
		hub.imagePending[pendingKey][#hub.imagePending[pendingKey] + 1] = imageLabel
		return
	end
	hub.imagePending[pendingKey] = { imageLabel }
	SpawnCall(function()
		const asset = NAmanage.ScriptHub_DownloadImage(url, generation)
		const waiting = hub.imagePending[pendingKey] or {}
		hub.imagePending[pendingKey] = nil
		if generation ~= hub.imageGeneration or type(asset) ~= "string" or asset == "" then
			return
		end
		for _, target in waiting do
			if target and target.Parent then
				NAmanage.ScriptHub_ApplyImage(target, asset)
			end
		end
	end)
end

NAmanage.ScriptHub_SetActionText = function(button, text, iconName)
	if not button then
		return
	end
	if type(iconName) == "string" and iconName ~= "" then
		const iconFont = BUILDER_ICON_FONT_PATH or "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"
		button.RichText = true
		button.Text = Format('<font family="%s">%s</font>  %s', iconFont, iconName, tostring(text or ""))
	else
		button.RichText = false
		button.Text = tostring(text or "")
	end
end

NAmanage.ScriptHub_CreateActionButton = function(parent, text, width, background, iconName)
	const button = InstanceNew("TextButton", parent)
	button.Name = text
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.BackgroundColor3 = background
	button.BackgroundTransparency = 0.12
	button.Size = UDim2.new(0, width, 0, 28)
	NAmanage.ScriptHub_SetActionText(button, text, iconName)
	button.TextColor3 = Color3.fromRGB(245, 245, 250)
	button.TextSize = 13
	button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
	const corner = InstanceNew("UICorner", button)
	corner.CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke", button)
	stroke.Name = "UIStroker"
	stroke.Thickness = 1.25
	stroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	stroke.Transparency = 0.25
	return button
end

NAmanage.ScriptHub_CreateCard = function(data, order)
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	const results = ui and ui.results
	if not results then
		return
	end
	const titleText = tostring(data.title or data.name or "Untitled Script")
	const requiresKey = NAmanage.ScriptHub_RequiresKey(data)
	const stats = type(data.stats) == "table" and data.stats or {}
	const flags = type(data.flags) == "table" and data.flags or {}
	const views = tostring(data.views or data.viewCount or stats.views or 0)
	const likes = tostring(data.likes or data.likeCount or stats.likes or 0)
	const verified = data.verified == true or flags.verified == true or type(data.author) == "table" and (data.author.verified == true or data.author.isScripterVerified == true)
	const universal = NAmanage.ScriptHub_IsUniversal(data)
	const catalogEntry = data.naCatalog == true
	const savedEntry = data.naSaved == true
	const gameData = type(data.game) == "table" and data.game or nil
	local gameName = (catalogEntry or savedEntry) and tostring(data.gameName or "") or gameData and tostring(gameData.name or gameData.title or "") or ""
	const placeId = NAmanage.ScriptHub_GetPlaceId(data)
	local imageUrl = NAmanage.ScriptHub_ResolveImageURL(data)
	if not imageUrl and placeId then
		imageUrl = NAmanage.ScriptHub_BuildPlaceThumbnail(placeId)
	end
	local status = savedEntry and "Saved" or catalogEntry and "Supported" or hub.engine == "RobloxScripts" and "Published" or (data.isPatched == true or flags.patched == true) and "Patched" or "Working"
	local description = type(data.description) == "string" and GSub(data.description, "%c", " ") or ""
	const descriptionLimit = hub.phone and 105 or hub.compact and 130 or 150
	if #description > descriptionLimit then
		description = Sub(description, 1, descriptionLimit - 3).."..."
	end
	const lines = {}
	if savedEntry then
		lines[#lines + 1] = universal and "Scope: Universal" or gameName ~= "" and "Game: "..gameName or "Saved game script"
		lines[#lines + 1] = "Saved from: "..tostring(data.savedEngine or "Script Hub").." | Key: "..(requiresKey and "Required" or "No Key")
		if tonumber(data.savedAt) and data.savedAt > 0 then
			lines[#lines + 1] = "Saved: "..os.date("%Y-%m-%d %H:%M", data.savedAt)
		end
	elseif catalogEntry then
		if data.catalogGameLinked == true then
			lines[#lines + 1] = data.currentGame == true and "Available for the current game" or "Supported game script"
		else
			lines[#lines + 1] = "General / universal catalog script"
		end
		if gameName ~= "" then
			lines[#lines + 1] = "Game: "..gameName
		end
		if placeId then
			lines[#lines + 1] = "Place ID: "..tostring(placeId)
		end
		lines[#lines + 1] = "Status: Supported | Source: Nameless Admin catalog"
	elseif universal then
		lines[#lines + 1] = "Scope: Universal"
	elseif gameName ~= "" then
		lines[#lines + 1] = placeId and Format("Game: %s (ID %s)", gameName, tostring(placeId)) or "Game: "..gameName
	end
	if not catalogEntry and not savedEntry then
		lines[#lines + 1] = Format("Status: %s | Key: %s | %s", status, requiresKey and "Required" or "No Key", verified and "Verified" or "Unverified")
		lines[#lines + 1] = Format("Views: %s | Likes: %s", views, likes)
		if hub.engine == "RScripts" then
			lines[#lines + 1] = data.mobileReady == true and "Platform: Mobile Ready" or data.mobileReady == false and "Platform: PC Only" or "Platform: Unknown"
		elseif hub.engine == "HaxHell" then
			lines[#lines + 1] = flags.mobileSupported == true and "Platform: Mobile Supported" or flags.mobileSupported == false and "Platform: PC / Unknown" or "Platform: Unknown"
		end
	end
	if description ~= "" then
		lines[#lines + 1] = description
	end

	const coverHeight = imageUrl and (hub.phone and 82 or hub.compact and 96 or 108) or 0
	const bodyOffset = imageUrl and coverHeight + 8 or 0
	const cardHeight = (hub.phone and (description ~= "" and 188 or 168) or hub.compact and (description ~= "" and 180 or 160) or (description ~= "" and 174 or 154)) + bodyOffset
	const card = InstanceNew("Frame", results)
	card.Name = "ScriptHubCard"
	card.LayoutOrder = order
	card.BorderSizePixel = 0
	card.BackgroundColor3 = Color3.fromRGB(42, 42, 49)
	card.BackgroundTransparency = 0.12
	card.Size = UDim2.new(1, -4, 0, cardHeight)
	card.ClipsDescendants = true
	const corner = InstanceNew("UICorner", card)
	corner.CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke", card)
	stroke.Name = "UIStroker"
	stroke.Thickness = 1.25
	stroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	stroke.Transparency = 0.35

	if imageUrl then
		const cover = InstanceNew("ImageLabel", card)
		cover.Name = "Cover"
		cover.BorderSizePixel = 0
		cover.BackgroundColor3 = Color3.fromRGB(25, 25, 31)
		cover.BackgroundTransparency = 0.08
		cover.Position = UDim2.new(0, 0, 0, 0)
		cover.Size = UDim2.new(1, 0, 0, coverHeight)
		cover.Image = ""
		cover.ImageTransparency = 1
		cover.ScaleType = Enum.ScaleType.Crop
		cover.ClipsDescendants = true
		const coverCorner = InstanceNew("UICorner", cover)
		coverCorner.CornerRadius = UDim.new(0, 6)
		const overlay = InstanceNew("Frame", cover)
		overlay.Name = "Overlay"
		overlay.BorderSizePixel = 0
		overlay.BackgroundColor3 = Color3.new(0, 0, 0)
		overlay.BackgroundTransparency = 0.55
		overlay.Size = UDim2.new(1, 0, 1, 0)
		const overlayGradient = InstanceNew("UIGradient", overlay)
		overlayGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85),
			NumberSequenceKeypoint.new(1, 0.15),
		})
		overlayGradient.Rotation = 90
		if not universal and gameName ~= "" then
			const gameLabel = InstanceNew("TextLabel", cover)
			gameLabel.Name = "Game"
			gameLabel.BorderSizePixel = 0
			gameLabel.BackgroundTransparency = 1
			gameLabel.Position = UDim2.new(0, 10, 1, -28)
			gameLabel.Size = UDim2.new(1, -20, 0, 22)
			gameLabel.TextXAlignment = Enum.TextXAlignment.Left
			gameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			gameLabel.Text = gameName
			gameLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
			gameLabel.TextSize = 13
			gameLabel.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		end
		NAmanage.ScriptHub_LoadImage(cover, imageUrl)
	end

	const title = InstanceNew("TextLabel", card)
	title.Name = "Title"
	title.BorderSizePixel = 0
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 10, 0, bodyOffset + 8)
	title.Size = UDim2.new(1, -20, 0, 24)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Text = titleText
	title.TextColor3 = Color3.fromRGB(245, 245, 250)
	title.TextSize = hub.phone and 14 or 15
	title.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)

	const info = InstanceNew("TextLabel", card)
	info.Name = "Info"
	info.BorderSizePixel = 0
	info.BackgroundTransparency = 1
	info.Position = UDim2.new(0, 10, 0, bodyOffset + 34)
	info.Size = UDim2.new(1, -20, 1, -(bodyOffset + 78))
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top
	info.TextWrapped = true
	info.Text = Concat(lines, "\n")
	info.TextColor3 = Color3.fromRGB(205, 205, 218)
	info.TextSize = hub.phone and 11 or 12
	info.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

	const actions = InstanceNew("ScrollingFrame", card)
	actions.Name = "Actions"
	actions.BorderSizePixel = 0
	actions.BackgroundTransparency = 1
	actions.Position = UDim2.new(0, 10, 1, -36)
	actions.Size = UDim2.new(1, -20, 0, 28)
	actions.AutomaticCanvasSize = Enum.AutomaticSize.X
	actions.CanvasSize = UDim2.new()
	actions.ScrollingDirection = Enum.ScrollingDirection.X
	actions.ScrollBarThickness = 0
	const layout = InstanceNew("UIListLayout", actions)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 7)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	const safeExecute = NAmanage.ScriptHub_CreateActionButton(actions, "Safe Execute", 116, Color3.fromRGB(56, 103, 154), "shield-check")
	NAlib.connect("NAScriptHubCards", safeExecute.MouseButton1Click:Connect(function()
		NAmanage.ScriptHub_SafeRunEntry(data)
	end))
	const execute = NAmanage.ScriptHub_CreateActionButton(actions, "Execute", 98, Color3.fromRGB(45, 125, 88), "bullet-flying")
	NAlib.connect("NAScriptHubCards", execute.MouseButton1Click:Connect(function()
		NAmanage.ScriptHub_RunEntry(data)
	end))
	if not universal and placeId then
		const join = NAmanage.ScriptHub_CreateActionButton(actions, "Join", 84, Color3.fromRGB(48, 91, 158), "person-teleport")
		join.LayoutOrder = -1
		NAlib.connect("NAScriptHubCards", join.MouseButton1Click:Connect(function()
			NAmanage.ScriptHub_JoinEntry(data)
		end))
	end
	if type(setclipboard) == "function" then
		const copy = NAmanage.ScriptHub_CreateActionButton(actions, "Copy", 84, Color3.fromRGB(65, 68, 82), "chain-link")
		NAlib.connect("NAScriptHubCards", copy.MouseButton1Click:Connect(function()
			NAmanage.ScriptHub_CopyEntry(data)
		end))
	end
	if hub.tabMode == "public" and not catalogEntry and not savedEntry then
		const save = NAmanage.ScriptHub_CreateActionButton(actions, "Save", 84, Color3.fromRGB(118, 82, 42), "floppy-disk")
		NAlib.connect("NAScriptHubCards", save.MouseButton1Click:Connect(function()
			NAmanage.ScriptHub_SaveEntry(data, save)
		end))
	end
	if savedEntry then
		const delete = NAmanage.ScriptHub_CreateActionButton(actions, "Delete", 84, Color3.fromRGB(132, 50, 57))
		NAlib.connect("NAScriptHubCards", delete.MouseButton1Click:Connect(function()
			NAmanage.ScriptHub_DeleteSavedEntry(data, delete)
		end))
	end
	if type(data.discord) == "string" and data.discord ~= "" and type(setclipboard) == "function" then
		const discord = NAmanage.ScriptHub_CreateActionButton(actions, "Discord", 84, Color3.fromRGB(52, 90, 155), "discord")
		NAlib.connect("NAScriptHubCards", discord.MouseButton1Click:Connect(function()
			local okCopy = pcall(setclipboard, data.discord)
			DoNotif(okCopy and "Discord link copied." or "Failed to copy Discord link.", 2, "Script Hub")
		end))
	end
end

NAmanage.ScriptHub_Render = function()
	const hub = NAmanage.ScriptHub
	hub.rendering = true
	NAlib.disconnect("NAScriptHubCards")
	NAmanage.ScriptHub_ClearResults()
	local shown = 0
	for _, data in hub.entries do
		if type(data) == "table" and NAmanage.ScriptHub_PassesFilter(data) then
			shown += 1
			NAmanage.ScriptHub_CreateCard(data, shown)
		end
	end
	if shown == 0 then
		local text = hub.tabMode == "supported" and "No catalog scripts found" or hub.tabMode == "saved" and (hub.query ~= "" and "No saved scripts found" or "No saved scripts yet") or "No scripts found"
		if hub.tabMode == "public" and hub.filterMode == "keyless" then
			text = "No keyless scripts found on this page"
		elseif hub.tabMode == "public" and hub.filterMode == "key" then
			text = "No key-required scripts found on this page"
		end
		NAmanage.ScriptHub_Message(text, Color3.fromRGB(105, 78, 42))
	end
	NAmanage.ScriptHub_UpdateControls()
	hub.rendering = false
	Defer(function()
		const ui = hub.ui or NAmanage.ScriptHub_GetUI()
		const results = ui and ui.results
		if results and results.Parent then
			pcall(updateCanvasSize, results, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
			if NAmanage.ScriptHubScroll and NAmanage.ScriptHubScroll.setTarget then
				pcall(NAmanage.ScriptHubScroll.setTarget, results)
			end
			if NAmanage.ScriptHubScroll and NAmanage.ScriptHubScroll.scheduleRefresh then
				pcall(NAmanage.ScriptHubScroll.scheduleRefresh)
			end
		end
	end)
end

NAmanage.ScriptHub_FetchCatalogGameIcons = function(entries)
	const placeIds = {}
	const seen = {}
	for _, entry in entries do
		if type(entry) == "table" and type(entry.placeIds) == "table" then
			for _, rawId in entry.placeIds do
				const id = tostring(rawId or "")
				if id ~= "" and not seen[id] then
					seen[id] = true
					Insert(placeIds, id)
				end
			end
		end
	end
	if #placeIds == 0 then
		return {}
	end

	const query = "placeIds="..Services.HttpService:UrlEncode(Concat(placeIds, ",")).."&returnPolicy=PlaceHolder&size=256x256&format=Png&isCircular=false"
	local decoded
	for _, host in { "thumbnails.roproxy.com", "thumbnails.rotunnel.com", "thumbnails.roblox.com" } do
		local okFetch, body = NAmanage.HttpGet("https://"..host.."/v1/places/gameicons?"..query, {
			timeout = 8;
			maxAttempts = 2;
			Headers = { Accept = "application/json" };
		})
		if okFetch and type(body) == "string" and body ~= "" then
			local okDecode, payload = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
			if okDecode and type(payload) == "table" and type(payload.data) == "table" then
				decoded = payload
				break
			end
		end
	end

	const icons = {}
	for _, item in type(decoded) == "table" and decoded.data or {} do
		const id = tostring(type(item) == "table" and item.targetId or "")
		const imageUrl = type(item) == "table" and item.imageUrl or nil
		if id ~= "" and type(imageUrl) == "string" and imageUrl ~= "" then
			icons[id] = imageUrl
		end
	end
	return icons
end

NAmanage.ScriptHub_FetchCatalogGameNames = function(entries)
	const universeIds = {}
	const seen = {}
	for _, entry in entries do
		if type(entry) == "table" and type(entry.universeIds) == "table" then
			for _, rawId in entry.universeIds do
				const id = tostring(rawId or "")
				if id ~= "" and not seen[id] then
					seen[id] = true
					Insert(universeIds, id)
				end
			end
		end
	end
	if #universeIds == 0 then
		return {}
	end

	const query = "universeIds="..Services.HttpService:UrlEncode(Concat(universeIds, ","))
	local decoded
	for _, host in { "games.roproxy.com", "games.rotunnel.com", "games.roblox.com" } do
		local okFetch, body = NAmanage.HttpGet("https://"..host.."/v1/games?"..query, {
			timeout = 8;
			maxAttempts = 2;
			Headers = { Accept = "application/json" };
		})
		if okFetch and type(body) == "string" and body ~= "" then
			local okDecode, payload = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
			if okDecode and type(payload) == "table" and type(payload.data) == "table" then
				decoded = payload
				break
			end
		end
	end

	const names = {}
	for _, item in type(decoded) == "table" and decoded.data or {} do
		const universeId = tostring(type(item) == "table" and item.id or "")
		const rootPlaceId = tostring(type(item) == "table" and item.rootPlaceId or "")
		const gameName = type(item) == "table" and item.name or nil
		if type(gameName) == "string" and gameName ~= "" then
			if universeId ~= "" then
				names[universeId] = gameName
			end
			if rootPlaceId ~= "" then
				names[rootPlaceId] = gameName
			end
		end
	end
	return names
end

NAmanage.ScriptHub_LoadSupported = function(query, page, refresh)
	const hub = NAmanage.ScriptHub
	if hub.searching or hub.tabMode ~= "supported" then
		return false
	end
	query = GSub(GSub(tostring(query or ""), "^%s+", ""), "%s+$", "")
	page = math.max(math.floor(tonumber(page) or 1), 1)
	hub.query = query
	hub.page = page
	NAmanage.ScriptHub_ClearImageCache()
	hub.searching = true
	hub.fetchToken += 1
	const token = hub.fetchToken
	NAmanage.ScriptHub_Message("Loading my scripts...", Color3.fromRGB(65, 62, 82))
	NAmanage.ScriptHub_UpdateControls()
	SpawnCall(function()
		local okCatalog, entriesOrErr = NAmanage.FetchScriptCatalog({ refresh = refresh == true })
		if token ~= hub.fetchToken or hub.tabMode ~= "supported" then
			return
		end
		if not okCatalog then
			hub.searching = false
			NAmanage.ScriptHub_Message("Catalog request failed: "..tostring(entriesOrErr), Color3.fromRGB(120, 55, 65))
			NAmanage.ScriptHub_UpdateControls()
			return
		end

		const gameIcons = NAmanage.ScriptHub_FetchCatalogGameIcons(entriesOrErr)
		const gameNames = NAmanage.ScriptHub_FetchCatalogGameNames(entriesOrErr)
		const normalizedQuery = Lower(query)
		const currentGameId = tostring((game and game.GameId) or GameId or "")
		const currentPlaceId = tostring((game and game.PlaceId) or PlaceId or "")
		const matches = {}
		for _, entry in entriesOrErr do
			if type(entry) == "table" then
				const gameLinked = type(entry.placeIds) == "table" and #entry.placeIds > 0 or type(entry.universeIds) == "table" and #entry.universeIds > 0
				const categoryMatch = hub.catalogMode == "all" or hub.catalogMode == "games" and gameLinked or hub.catalogMode == "other" and not gameLinked
				const placeId = type(entry.placeIds) == "table" and entry.placeIds[1]
				const universeId = type(entry.universeIds) == "table" and entry.universeIds[1]
				const gameName = gameLinked and (gameNames[tostring(universeId or "")] or gameNames[tostring(placeId or "")] or entry.gameName or entry.name) or ""
				local searchable = Lower(tostring(entry.name or "").." "..tostring(entry.id or "").." "..tostring(gameName or ""))
				if type(entry.placeIds) == "table" then
					searchable ..= " "..Concat(entry.placeIds, " ")
				end
				if type(entry.universeIds) == "table" then
					searchable ..= " "..Concat(entry.universeIds, " ")
				end
				if categoryMatch and (normalizedQuery == "" or Find(searchable, normalizedQuery, 1, true)) then
					const currentGame = gameLinked and (NAmanage.ScriptCatalogHasId(entry.universeIds, currentGameId) or NAmanage.ScriptCatalogHasId(entry.placeIds, currentPlaceId)) or false
					Insert(matches, {
						naCatalog = true;
						catalogGameLinked = gameLinked;
						id = entry.id;
						name = entry.name;
						title = entry.name;
						gameName = gameName;
						scriptUrl = entry.scriptUrl;
						imageUrl = entry.imageUrl or gameLinked and (gameIcons[tostring(placeId or "")] or NAmanage.ScriptHub_BuildGameIcon(universeId, placeId)) or nil;
						placeIds = entry.placeIds;
						universeIds = entry.universeIds;
						isUniversal = not gameLinked;
						featured = entry.featured == true;
						currentGame = currentGame;
					})
				end
			end
		end
		table.sort(matches, function(a, b)
			if a.currentGame ~= b.currentGame then
				return a.currentGame == true
			end
			if a.featured ~= b.featured then
				return a.featured == true
			end
			if a.catalogGameLinked ~= b.catalogGameLinked then
				return a.catalogGameLinked == true
			end
			return Lower(a.name) < Lower(b.name)
		end)

		const pageSize = math.max(math.floor(tonumber(hub.supportedPageSize) or 16), 1)
		const totalPages = math.max(math.ceil(#matches / pageSize), 1)
		page = math.clamp(page, 1, totalPages)
		const firstIndex = (page - 1) * pageSize + 1
		const pageEntries = {}
		for index = firstIndex, math.min(firstIndex + pageSize - 1, #matches) do
			Insert(pageEntries, matches[index])
		end
		hub.entries = pageEntries
		hub.totalPages = totalPages
		hub.page = page
		hub.searching = false
		NAmanage.ScriptHub_Render()
	end)
	return true
end

NAmanage.ScriptHub_ResolveScriptBloxPlaceId = function(data)
	const hub = NAmanage.ScriptHub
	const scriptId = tostring(type(data) == "table" and (data._id or data.id or data.slug) or "")
	if scriptId == "" then
		return nil
	end
	const cacheKey = "ScriptBlox:"..scriptId
	const cached = hub.placeIdCache[cacheKey]
	if cached ~= nil then
		return cached or nil
	end
	local placeId
	local okFetch, body = NAmanage.HttpGet("https://scriptblox.com/api/script/"..Services.HttpService:UrlEncode(scriptId), {
		timeout = 7;
		maxAttempts = 2;
		Headers = { Accept = "application/json" };
	})
	if okFetch and type(body) == "string" and body ~= "" then
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
		const details = okDecode and type(decoded) == "table" and type(decoded.script) == "table" and decoded.script or nil
		placeId = details and NAmanage.ScriptHub_GetPlaceId(details) or nil
	end
	hub.placeIdCache[cacheKey] = placeId or false
	return placeId
end

NAmanage.ScriptHub_ResolveRobloxScriptsPlaceId = function(data)
	const hub = NAmanage.ScriptHub
	const gameData = type(data) == "table" and type(data.game) == "table" and data.game or nil
	const gameName = gameData and tostring(gameData.name or "") or ""
	const wantedName = NAmanage.ScriptHub_NormalizeGameName(gameName)
	const wantedSlug = NAmanage.ScriptHub_NormalizeGameName(gameData and gameData.slug or "")
	if wantedName == "" and wantedSlug == "" then
		return nil
	end
	const cacheKey = "RobloxScripts:"..(wantedSlug ~= "" and wantedSlug or wantedName)
	const cached = hub.placeIdCache[cacheKey]
	if cached ~= nil then
		return cached or nil
	end

	local placeId
	const query = Services.HttpService:UrlEncode(gameName ~= "" and gameName or tostring(gameData.slug or ""))
	for _, host in { "apis.roproxy.com", "apis.rotunnel.com", "apis.roblox.com" } do
		local okFetch, body = NAmanage.HttpGet("https://"..host.."/search-api/omni-search?searchQuery="..query.."&sessionId=na-script-hub", {
			timeout = 7;
			maxAttempts = 1;
			Headers = { Accept = "application/json" };
		})
		if okFetch and type(body) == "string" and body ~= "" then
			local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
			if okDecode and type(decoded) == "table" and type(decoded.searchResults) == "table" then
				for _, group in decoded.searchResults do
					if type(group) == "table" and group.contentGroupType == "Game" and type(group.contents) == "table" then
						for _, item in group.contents do
							const resultName = NAmanage.ScriptHub_NormalizeGameName(type(item) == "table" and item.name or "")
							if resultName ~= "" and (resultName == wantedName or resultName == wantedSlug) then
								const candidate = tonumber(item.rootPlaceId or item.placeId)
								if candidate and candidate > 0 then
									placeId = candidate
									break
								end
							end
						end
					end
					if placeId then
						break
					end
				end
			end
		end
		if placeId then
			break
		end
	end
	hub.placeIdCache[cacheKey] = placeId or false
	return placeId
end

NAmanage.ScriptHub_HydratePlaceIds = function(entries, engine, token)
	const hub = NAmanage.ScriptHub
	const queue = {}
	for _, data in entries do
		if type(data) == "table" and not NAmanage.ScriptHub_IsUniversal(data) and not NAmanage.ScriptHub_GetPlaceId(data) then
			if engine == "ScriptBlox" or engine == "RobloxScripts" then
				Insert(queue, data)
			end
		end
	end
	if #queue == 0 then
		return true
	end

	local nextIndex = 1
	local running = math.min(#queue, 4)
	for _ = 1, running do
		Spawn(function()
			while token == hub.fetchToken do
				const index = nextIndex
				nextIndex += 1
				const data = queue[index]
				if not data then
					break
				end
				local placeId
				if engine == "ScriptBlox" then
					placeId = NAmanage.ScriptHub_ResolveScriptBloxPlaceId(data)
				else
					placeId = NAmanage.ScriptHub_ResolveRobloxScriptsPlaceId(data)
				end
				if placeId then
					data.naResolvedPlaceId = placeId
				end
			end
			running -= 1
		end)
	end
	const deadline = os.clock() + 12
	while running > 0 and token == hub.fetchToken and os.clock() < deadline do
		task.wait(0.05)
	end
	return token == hub.fetchToken
end

NAmanage.ScriptHub_BuildURL = function(query, page)
	const hub = NAmanage.ScriptHub
	query = tostring(query or "")
	page = math.max(tonumber(page) or 1, 1)
	local encoded = Services.HttpService:UrlEncode(query)
	if hub.engine == "RScripts" then
		local url = Format("https://rscripts.net/api/v2/scripts?page=%d&orderBy=date&sort=desc", page)
		if query ~= "" then
			url ..= "&q="..encoded
		end
		return url
	elseif hub.engine == "RobloxScripts" then
		if #query > 100 then
			query = Sub(query, 1, 100)
			encoded = Services.HttpService:UrlEncode(query)
		end
		local url = Format("https://robloxscripts.com/api/v1/scripts?page=%d&limit=24&sort=newest", page)
		if query ~= "" then
			url ..= "&q="..encoded
		end
		return url
	elseif hub.engine == "HaxHell" then
		if query == "" then
			return Format("https://haxhell.com/api/v1/scripts?page=%d&limit=24&sort=latest", page)
		end
		return Format("https://haxhell.com/api/v1/search/scripts?q=%s&page=%d&limit=24&sort=latest", encoded, page)
	elseif query == "" then
		return Format("https://scriptblox.com/api/script/fetch?page=%d", page)
	end
	return Format("https://scriptblox.com/api/script/search?q=%s&page=%d", encoded, page)
end

NAmanage.ScriptHub_ParseResponse = function(decoded, requestedPage)
	const hub = NAmanage.ScriptHub
	local entries = {}
	local totalPages = 1
	local currentPage = requestedPage
	if hub.engine == "RScripts" then
		entries = type(decoded.scripts) == "table" and decoded.scripts or type(decoded.data) == "table" and decoded.data or {}
		totalPages = tonumber(type(decoded.info) == "table" and decoded.info.maxPages) or tonumber(decoded.totalPages) or 1
	elseif hub.engine == "RobloxScripts" then
		entries = type(decoded.data) == "table" and decoded.data or type(decoded.scripts) == "table" and decoded.scripts or {}
		const pagination = type(decoded.pagination) == "table" and decoded.pagination or {}
		const totalItems = tonumber(pagination.total or pagination.totalItems)
		const limit = tonumber(pagination.limit or pagination.perPage) or 24
		totalPages = tonumber(pagination.totalPages or pagination.pages or pagination.lastPage)
		if not totalPages and totalItems then
			totalPages = math.ceil(totalItems / math.max(limit, 1))
		end
		currentPage = tonumber(pagination.page or pagination.currentPage) or requestedPage
	elseif hub.engine == "HaxHell" then
		entries = type(decoded.data) == "table" and decoded.data or {}
		const pagination = type(decoded.pagination) == "table" and decoded.pagination or {}
		totalPages = tonumber(pagination.totalPages or pagination.pages or pagination.lastPage) or 1
		currentPage = tonumber(pagination.page or pagination.currentPage) or requestedPage
	else
		const result = type(decoded.result) == "table" and decoded.result or {}
		entries = type(result.scripts) == "table" and result.scripts or type(decoded.scripts) == "table" and decoded.scripts or {}
		totalPages = tonumber(result.totalPages or decoded.totalPages) or 1
	end
	const pageCap = hub.engine == "HaxHell" and 10000 or 500
	return entries, math.clamp(math.floor(tonumber(totalPages) or 1), 1, pageCap), math.max(math.floor(tonumber(currentPage) or requestedPage), 1)
end

NAmanage.ScriptHub_Fetch = function(query, page)
	const hub = NAmanage.ScriptHub
	if hub.tabMode == "supported" then
		return NAmanage.ScriptHub_LoadSupported(query, page)
	end
	if hub.searching then
		return false
	end
	query = tostring(query or "")
	query = GSub(GSub(query, "^%s+", ""), "%s+$", "")
	if hub.engine == "HaxHell" and query ~= "" and #query < 2 then
		NAmanage.ScriptHub_Message("HaxHell search requires at least 2 characters.", Color3.fromRGB(120, 85, 45))
		NAmanage.ScriptHub_UpdateControls()
		return false
	end
	page = math.max(math.floor(tonumber(page) or 1), 1)
	hub.query = query
	hub.page = page
	NAmanage.ScriptHub_ClearImageCache()
	hub.searching = true
	hub.fetchToken += 1
	const token = hub.fetchToken
	const requestEngine = hub.engine
	NAmanage.ScriptHub_Message("Searching "..hub.engine.."...", Color3.fromRGB(65, 62, 82))
	NAmanage.ScriptHub_UpdateControls()
	SpawnCall(function()
		const url = NAmanage.ScriptHub_BuildURL(query, page)
		local okFetch, body, fetchErr = NAmanage.HttpGet(url, {
			timeout = 12;
			maxAttempts = 3;
			Headers = { Accept = "application/json" };
		})
		if token ~= hub.fetchToken then
			return
		end
		if not okFetch or type(body) ~= "string" or body == "" then
			hub.searching = false
			NAmanage.ScriptHub_Message("Request failed: "..tostring(fetchErr or "empty response"), Color3.fromRGB(120, 55, 65))
			NAmanage.ScriptHub_UpdateControls()
			return
		end
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
		if not okDecode or type(decoded) ~= "table" then
			hub.searching = false
			NAmanage.ScriptHub_Message("Invalid API response", Color3.fromRGB(120, 55, 65))
			NAmanage.ScriptHub_UpdateControls()
			return
		end
		local entries, totalPages, currentPage = NAmanage.ScriptHub_ParseResponse(decoded, page)
		if not NAmanage.ScriptHub_HydratePlaceIds(entries, requestEngine, token) or token ~= hub.fetchToken then
			return
		end
		hub.entries = entries
		hub.totalPages = totalPages
		hub.page = math.clamp(currentPage, 1, totalPages)
		hub.searching = false
		NAmanage.ScriptHub_Render()
	end)
	return true
end

NAmanage.ScriptHub_SearchInput = function()
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	const query = ui and ui.searchBox and ui.searchBox.Text or ""
	if hub.tabMode == "supported" then
		return NAmanage.ScriptHub_LoadSupported(query, 1)
	elseif hub.tabMode == "saved" then
		return NAmanage.ScriptHub_LoadSaved(query, 1)
	end
	return NAmanage.ScriptHub_Fetch(query, 1)
end

NAmanage.ScriptHub_RequestPage = function(page)
	const hub = NAmanage.ScriptHub
	if hub.searching or #hub.entries == 0 then
		return
	end
	page = math.clamp(math.floor(tonumber(page) or hub.page), 1, math.max(hub.totalPages, 1))
	if page ~= hub.page then
		if hub.tabMode == "supported" then
			NAmanage.ScriptHub_LoadSupported(hub.query, page)
		elseif hub.tabMode == "saved" then
			NAmanage.ScriptHub_LoadSaved(hub.query, page)
		else
			NAmanage.ScriptHub_Fetch(hub.query, page)
		end
	end
end

NAmanage.ScriptHub_Init = function()
	const hub = NAmanage.ScriptHub
	const ui = NAmanage.ScriptHub_GetUI()
	if not (ui and ui.frame and ui.container and ui.results and ui.searchBox and ui.search and ui.engine and ui.publicTab and ui.supportedTab and ui.savedTab) then
		return false
	end
	if hub.ready and hub.boundFrame == ui.frame then
		return true
	end
	hub.boundFrame = ui.frame
	hub.ready = true
	NAlib.disconnect("NAScriptHub")
	NAlib.connect("NAScriptHub", ui.publicTab.MouseButton1Click:Connect(function()
		NAmanage.ScriptHub_SetTab("public")
	end))
	NAlib.connect("NAScriptHub", ui.supportedTab.MouseButton1Click:Connect(function()
		NAmanage.ScriptHub_SetTab("supported")
	end))
	NAlib.connect("NAScriptHub", ui.savedTab.MouseButton1Click:Connect(function()
		NAmanage.ScriptHub_SetTab("saved")
	end))
	NAlib.connect("NAScriptHub", ui.engine.MouseButton1Click:Connect(function()
		NAmanage.ScriptHub_ToggleEngineDropdown()
	end))
	NAlib.connect("NAScriptHub", ui.search.MouseButton1Click:Connect(NAmanage.ScriptHub_SearchInput))
	NAlib.connect("NAScriptHub", ui.searchBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			NAmanage.ScriptHub_SearchInput()
		end
	end))
	if ui.first then
		NAlib.connect("NAScriptHub", ui.first.MouseButton1Click:Connect(function() NAmanage.ScriptHub_RequestPage(1) end))
	end
	if ui.prev then
		NAlib.connect("NAScriptHub", ui.prev.MouseButton1Click:Connect(function() NAmanage.ScriptHub_RequestPage(hub.page - 1) end))
	end
	if ui.next then
		NAlib.connect("NAScriptHub", ui.next.MouseButton1Click:Connect(function() NAmanage.ScriptHub_RequestPage(hub.page + 1) end))
	end
	if ui.last then
		NAlib.connect("NAScriptHub", ui.last.MouseButton1Click:Connect(function() NAmanage.ScriptHub_RequestPage(hub.totalPages) end))
	end
	if ui.filter then
		NAlib.connect("NAScriptHub", ui.filter.MouseButton1Click:Connect(function()
			if hub.searching then
				return
			end
			if hub.tabMode == "supported" then
				const index = table.find(hub.catalogModes, hub.catalogMode) or 1
				hub.catalogMode = hub.catalogModes[index % #hub.catalogModes + 1]
				NAmanage.ScriptHub_UpdateHeader()
				NAmanage.ScriptHub_LoadSupported(hub.query, 1)
				return
			end
			if hub.tabMode == "saved" then
				return
			end
			if #hub.entries == 0 then
				return
			end
			const index = table.find(hub.filterModes, hub.filterMode) or 1
			hub.filterMode = hub.filterModes[index % #hub.filterModes + 1]
			NAmanage.ScriptHub_Render()
		end))
	end
	NAmanage.ScriptHub_EnsureImageFolder()
	NAmanage.ScriptHub_UpdateHeader()
	NAmanage.ScriptHub_ApplyResponsive(false)
	NAmanage.ScriptHub_SaveFrameSize = function()
		NAmanage.ExecutorWindowSizing.Save(ui.frame, "NAScriptHubSavedSizeX", "NAScriptHubSavedSizeY")
	end
	NAlib.disconnect("NAScriptHubResponsive")
	NAlib.connect("NAScriptHubResponsive", ui.frame:GetPropertyChangedSignal("Size"):Connect(NAmanage.ScriptHub_SaveFrameSize))
	NAlib.connect("NAScriptHubResponsive", ui.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		const changed = NAmanage.ScriptHub_UpdateResponsiveLayout()
		if changed and #hub.entries > 0 and hub.rendering ~= true then
			Defer(NAmanage.ScriptHub_Render)
		end
	end))
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect("NAScriptHubResponsive", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			Defer(function()
				if ui.frame and ui.frame.Parent then
					NAmanage.ScriptHub_ApplyResponsive(true)
				end
			end)
		end))
	end
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NAScriptHubResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Defer(function()
				if ui.frame and ui.frame.Parent then
					NAmanage.ScriptHub_ApplyResponsive(true)
				end
			end)
		end))
	end
	if NAUIMANAGER and NAUIMANAGER.AUTOSCALER then
		NAlib.connect("NAScriptHubResponsive", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(function()
			Defer(function()
				if ui.frame and ui.frame.Parent then
					NAmanage.ScriptHub_ApplyResponsive(true)
				end
			end)
		end))
	end
	if #hub.entries > 0 then
		NAmanage.ScriptHub_Render()
	else
		NAmanage.ScriptHub_Message(hub.tabMode == "supported" and "Open this tab to load the NA script catalog." or hub.tabMode == "saved" and "Save a public-hub result to keep it here." or "Search or open the hub to load the latest scripts.", Color3.fromRGB(65, 62, 82))
	end
	return true
end

NAmanage.ScriptHub_Toggle = function()
	const frame = NAUIMANAGER and NAUIMANAGER.ScriptHubFrame
	if not frame then
		DoNotif("Script Hub UI unavailable.", 3, "Script Hub")
		return false
	end
	if not NAmanage.ScriptHub_Init() then
		DoNotif("Script Hub failed to initialize.", 3, "Script Hub")
		return false
	end
	if frame.Visible then
		frame.Visible = false
		return true
	end
	frame.Visible = true
	NAmanage.centerFrame(frame)
	if NAmanage.OnUIWindowShown then
		pcall(NAmanage.OnUIWindowShown, frame)
	end
	if #NAmanage.ScriptHub.entries == 0 and not NAmanage.ScriptHub.searching then
		if NAmanage.ScriptHub.tabMode == "supported" then
			NAmanage.ScriptHub_LoadSupported(NAmanage.ScriptHub.query, 1)
		elseif NAmanage.ScriptHub.tabMode == "saved" then
			NAmanage.ScriptHub_LoadSaved(NAmanage.ScriptHub.query, 1)
		else
			NAmanage.ScriptHub_Fetch(NAmanage.ScriptHub.query, 1)
		end
	end
	return true
end

do
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) == "table" then
		perf.uiManagerElapsed = os.clock() - uiManagerBuildStart
	end
	pcall(function()
		const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
		if type(probe) == "table" and type(probe.mark) == "function" then
			probe.mark("ui_manager_done")
		end
	end)
end

NAmanage.EnsurePluginsWindow = NAmanage.EnsurePluginsWindow or function()
	const frame = NAUIMANAGER and NAUIMANAGER.PluginsFrame
	if not frame then
		return nil
	end
	if NAUIMANAGER then
		NAUIMANAGER.PluginsContainer = frame:FindFirstChild("Container")
		NAUIMANAGER.PluginsList = NAUIMANAGER.PluginsContainer and NAUIMANAGER.PluginsContainer:FindFirstChild("List")
		NAUIMANAGER.PluginsFilter = NAUIMANAGER.PluginsContainer and NAUIMANAGER.PluginsContainer:FindFirstChild("Filter")
		const container = NAUIMANAGER.PluginsContainer
		const list = NAUIMANAGER.PluginsList
		if container and list and container:IsA("GuiObject") and list:IsA("ScrollingFrame") then
			const function skin(obj, radius, strokeColor)
				if not obj then return end
				if not obj:FindFirstChildWhichIsA("UICorner") then
					const corner = InstanceNew("UICorner", obj)
					corner.CornerRadius = UDim.new(0, 6)
				end
				if strokeColor and not obj:FindFirstChildWhichIsA("UIStroke") then
					const stroke = InstanceNew("UIStroke", obj)
					stroke.Thickness = 1
					stroke.Transparency = 0.75
					stroke.Color = strokeColor
				end
			end

			const function ensureScrollBar(name, axis)
				const horizontal = axis == "X"
				local bar = container:FindFirstChild(name)
				if not (bar and bar:IsA("GuiObject")) then
					bar = InstanceNew("Frame", container)
					bar.Name = name
					bar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
					bar.BackgroundTransparency = 0.08
					bar.BorderSizePixel = 0
					bar.Visible = false
					bar.ZIndex = 35
					skin(bar, 7, NAUISTROKER or Color3.fromRGB(155, 100, 255))
				end
				bar.AnchorPoint = Vector2.new(0, 0)
				if horizontal then
					bar.Position = UDim2.new(list.Position.X.Scale, list.Position.X.Offset, 1, -18)
					bar.Size = UDim2.new(list.Size.X.Scale, list.Size.X.Offset, 0, 16)
				else
					bar.Position = UDim2.new(1, -18, list.Position.Y.Scale, list.Position.Y.Offset)
					bar.Size = UDim2.new(0, 16, list.Size.Y.Scale, list.Size.Y.Offset)
				end

				const upName = horizontal and "Left" or "Up"
				const downName = horizontal and "Right" or "Down"
				local upButton = bar:FindFirstChild(upName)
				if not (upButton and upButton:IsA("TextButton")) then
					upButton = InstanceNew("TextButton", bar)
					upButton.Name = upName
					upButton.AutoButtonColor = false
					upButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
					upButton.BackgroundTransparency = 0.15
					upButton.BorderSizePixel = 0
					upButton.Font = Enum.Font.GothamBold
					upButton.Text = horizontal and "<" or "^"
					upButton.TextColor3 = Color3.fromRGB(245, 245, 250)
					upButton.TextSize = 10
					upButton.ZIndex = 36
					skin(upButton, 5)
				end

				local downButton = bar:FindFirstChild(downName)
				if not (downButton and downButton:IsA("TextButton")) then
					downButton = InstanceNew("TextButton", bar)
					downButton.Name = downName
					downButton.AutoButtonColor = false
					downButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
					downButton.BackgroundTransparency = 0.15
					downButton.BorderSizePixel = 0
					downButton.Font = Enum.Font.GothamBold
					downButton.Text = horizontal and ">" or "v"
					downButton.TextColor3 = Color3.fromRGB(245, 245, 250)
					downButton.TextSize = 10
					downButton.ZIndex = 36
					skin(downButton, 5)
				end

				local track = bar:FindFirstChild("Track")
				if not (track and track:IsA("GuiObject")) then
					track = InstanceNew("Frame", bar)
					track.Name = "Track"
					track.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
					track.BackgroundTransparency = 0.2
					track.BorderSizePixel = 0
					track.ZIndex = 36
					skin(track, 5)
				end

				local thumb = track:FindFirstChild("Thumb")
				if not (thumb and thumb:IsA("GuiObject")) then
					thumb = InstanceNew("Frame", track)
					thumb.Name = "Thumb"
					thumb.BackgroundColor3 = NAUISTROKER or Color3.fromRGB(155, 100, 255)
					thumb.BackgroundTransparency = 0.12
					thumb.BorderSizePixel = 0
					thumb.ZIndex = 37
					skin(thumb, 5)
				end

				if horizontal then
					upButton.Position = UDim2.new(0, 0, 0, 0)
					upButton.Size = UDim2.new(0, 16, 1, 0)
					downButton.AnchorPoint = Vector2.new(1, 0)
					downButton.Position = UDim2.new(1, 0, 0, 0)
					downButton.Size = UDim2.new(0, 16, 1, 0)
					track.Position = UDim2.new(0, 18, 0, 0)
					track.Size = UDim2.new(1, -36, 1, 0)
				else
					upButton.Position = UDim2.new(0, 0, 0, 0)
					upButton.Size = UDim2.new(1, 0, 0, 16)
					downButton.AnchorPoint = Vector2.new(0, 1)
					downButton.Position = UDim2.new(0, 0, 1, 0)
					downButton.Size = UDim2.new(1, 0, 0, 16)
					track.Position = UDim2.new(0, 0, 0, 18)
					track.Size = UDim2.new(1, 0, 1, -36)
				end
				return bar, upButton, downButton, track, thumb
			end

			local vBar, vUp, vDown, vTrack, vThumb = ensureScrollBar("CustomScrollBar", "Y")
			local hBar, hLeft, hRight, hTrack, hThumb = ensureScrollBar("CustomHorizontalScrollBar", "X")
			NAUIMANAGER.PluginsCustomScrollBar = vBar
			NAUIMANAGER.PluginsCustomScrollUp = vUp
			NAUIMANAGER.PluginsCustomScrollDown = vDown
			NAUIMANAGER.PluginsCustomScrollTrack = vTrack
			NAUIMANAGER.PluginsCustomScrollThumb = vThumb
			NAUIMANAGER.PluginsCustomHorizontalScrollBar = hBar
			NAUIMANAGER.PluginsCustomScrollLeft = hLeft
			NAUIMANAGER.PluginsCustomScrollRight = hRight
			NAUIMANAGER.PluginsCustomHorizontalScrollTrack = hTrack
			NAUIMANAGER.PluginsCustomHorizontalScrollThumb = hThumb
			pcall(function()
				list.Active = true
				list.ScrollingDirection = Enum.ScrollingDirection.XY
				list.ScrollBarThickness = 0
				list.ScrollBarImageTransparency = 1
				list.VerticalScrollBarInset = Enum.ScrollBarInset.None
				list.HorizontalScrollBarInset = Enum.ScrollBarInset.None
			end)
		end
	end
	return frame
end

NAmanage.EnsurePluginsWindow()

originalIO.resizeCursors = function(key, fallback)
	const asset = NAmanage.getNAImageAsset(key, nil)
	if type(asset) == "string" and asset ~= "" then
		return asset
	end;
	return fallback;
end;

NAStuff.resizeVerticalAsset = originalIO.resizeCursors("ResizeVertical", "rbxassetid://2911850935")
NAStuff.resizeHorizontalAsset = originalIO.resizeCursors("ResizeHorizontal", "rbxassetid://2911851464")
NAStuff.resizeDiagonal1Asset = originalIO.resizeCursors("ResizeDiagonal1", "rbxassetid://2911851859")
NAStuff.resizeDiagonal2Asset = originalIO.resizeCursors("ResizeDiagonal2", "rbxassetid://2911852219")

resizeXY = {
	Top = {
		Vector2.new(0, -1),
		Vector2.new(0, -1),
		NAStuff.resizeVerticalAsset
	},
	Bottom = {
		Vector2.new(0, 1),
		Vector2.new(0, 0),
		NAStuff.resizeVerticalAsset
	},
	Left = {
		Vector2.new(-1, 0),
		Vector2.new(1, 0),
		NAStuff.resizeHorizontalAsset
	},
	Right = {
		Vector2.new(1, 0),
		Vector2.new(0, 0),
		NAStuff.resizeHorizontalAsset
	},
	TopLeft = {
		Vector2.new(-1, -1),
		Vector2.new(1, -1),
		NAStuff.resizeDiagonal2Asset
	},
	TopRight = {
		Vector2.new(1, -1),
		Vector2.new(0, -1),
		NAStuff.resizeDiagonal1Asset
	},
	BottomLeft = {
		Vector2.new(-1, 1),
		Vector2.new(1, 0),
		NAStuff.resizeDiagonal1Asset
	},
	BottomRight = {
		Vector2.new(1, 1),
		Vector2.new(0, 0),
		NAStuff.resizeDiagonal2Asset
	}
};

NAmanage.IsLegacyCommandUI = function()
	return type(NAStuff) == "table" and NAStuff.LegacyCommandUI == true
end

NAmanage.ApplyCmdAutofillFrameMode = function(frame, legacy)
	if not (frame and frame:IsA("GuiObject")) then
		return
	end
	legacy = legacy == true
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundTransparency = 1
	frame.Size = legacy and UDim2.new(0.5, 0, 0, 28) or UDim2.new(1, -16, 0, 38)
	frame.Position = legacy and UDim2.new(0.5, 0, 0.82, 0) or UDim2.new(0.5, 0, 0, 0)
	frame.ZIndex = legacy and 1 or 19

	const inputObj = frame:FindFirstChild("Input")
	if inputObj and inputObj:IsA("TextButton") then
		inputObj.TextWrapped = legacy
		inputObj.TextSize = legacy and 18 or 14
		inputObj.TextScaled = legacy
		inputObj.TextColor3 = legacy and Color3.fromRGB(235, 235, 245) or Color3.fromRGB(232, 232, 236)
		inputObj.TextXAlignment = legacy and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
		inputObj.FontFace = legacy
			and Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		inputObj.ZIndex = legacy and 2 or 22
		inputObj.AnchorPoint = legacy and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5)
		inputObj.BackgroundTransparency = 1
		inputObj.Size = legacy and UDim2.new(1, 0, 1, -5) or UDim2.new(1, 0, 1, 0)
		inputObj.Position = legacy and UDim2.new(0, 0, 0.5, 0) or UDim2.new(0.5, 0, 0.5, 0)
		inputObj.AutoButtonColor = legacy == true
		const inputPadding = inputObj:FindFirstChildOfClass("UIPadding")
		if inputPadding then
			inputPadding.PaddingLeft = legacy and UDim.new(0, 0) or UDim.new(0, 16)
			inputPadding.PaddingRight = legacy and UDim.new(0, 0) or UDim.new(0, 14)
		end
	end

	const background = frame:FindFirstChild("Background")
	if background and background:IsA("GuiObject") then
		background.ZIndex = legacy and 1 or 20
	end
	const visual = background and background:FindFirstChild("Horizontal")
	if visual and visual:IsA("GuiObject") then
		visual.BackgroundColor3 = legacy and Color3.fromRGB(45, 45, 50) or Color3.fromRGB(24, 24, 27)
		visual.BackgroundTransparency = legacy and 0.3 or 0.2
		visual.ZIndex = legacy and 1 or 20
		const corner = visual:FindFirstChildOfClass("UICorner")
		if corner then
			corner.CornerRadius = UDim.new(0, legacy and 6 or 8)
		end
		const gradient = visual:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient.Color = legacy and ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 55)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 45))
			}) or ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 34)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(19, 19, 22))
			})
		end
		const outline = visual:FindFirstChild("ItemOutline")
		if outline and outline:IsA("UIStroke") then
			outline.Enabled = not legacy
			outline.Transparency = 0.76
		end
		const line = visual:FindFirstChild("SelectionLine")
		if line and line:IsA("GuiObject") then
			line.Visible = not legacy
			line.BackgroundTransparency = 0.42
		end
	end
end

NAmanage.ApplyCommandPredictionMode = function(legacy)
	if not predictionInput then
		return
	end
	legacy = legacy == true
	const inputObj = NAUIMANAGER and NAUIMANAGER.cmdInput
	if inputObj then
		predictionInput.AnchorPoint = inputObj.AnchorPoint
		predictionInput.Position = inputObj.Position
		predictionInput.Size = inputObj.Size
		predictionInput.TextWrapped = inputObj.TextWrapped
		predictionInput.TextScaled = inputObj.TextScaled
		predictionInput.TextSize = inputObj.TextSize
		predictionInput.TextXAlignment = inputObj.TextXAlignment
		predictionInput.FontFace = inputObj.FontFace
	end
	predictionInput.TextEditable = false
	predictionInput.Active = false
	predictionInput.Selectable = false
	predictionInput.BackgroundTransparency = 1
	predictionInput.PlaceholderText = ""
	if legacy then
		predictionInput.TextTransparency = 1
		predictionInput.TextColor3 = Color3.fromRGB(180, 180, 180)
		predictionInput.ZIndex = (inputObj and inputObj.ZIndex or 2) + 1
		predictionInput.Visible = true
	else
		predictionInput.TextTransparency = 0.55
		predictionInput.TextColor3 = Color3.fromRGB(155, 155, 164)
		predictionInput.ZIndex = math.max(1, (inputObj and inputObj.ZIndex or 23) - 1)
		if type(NAmanage.SyncCmdPredictionVisual) == "function" then
			NAmanage.SyncCmdPredictionVisual()
		else
			predictionInput.Visible = false
		end
	end
end

NAmanage.ApplyCommandUIMode = function(opts)
	opts = type(opts) == "table" and opts or {}
	const legacy = NAmanage.IsLegacyCommandUI()
	const bar = NAUIMANAGER and NAUIMANAGER.cmdBar
	const centerBar = NAUIMANAGER and NAUIMANAGER.centerBar
	const inputObj = NAUIMANAGER and NAUIMANAGER.cmdInput
	const leftFill = NAUIMANAGER and NAUIMANAGER.leftFill
	const rightFill = NAUIMANAGER and NAUIMANAGER.rightFill
	const autofill = NAUIMANAGER and NAUIMANAGER.cmdAutofill
	if not (bar and centerBar and inputObj and leftFill and rightFill and autofill) then
		return false
	end

	pcall(function()
		bar:SetAttribute("NACommandUIMode", legacy and "Legacy" or "Modern")
	end)
	bar.Size = legacy and UDim2.new(1, 0, 0, 30) or UDim2.new(1, 0, 0, 46)
	bar.Position = legacy and UDim2.new(0.5, 0, 0.5, -20) or UDim2.new(0.5, 0, 0.5, 0)

	centerBar.ZIndex = legacy and 2 or 20
	centerBar.AnchorPoint = Vector2.new(0.5, 0.5)
	centerBar.Position = UDim2.new(0.5, 0, 0.5, 0)
	centerBar.Size = legacy and UDim2.new(0, 280, 1, 10) or UDim2.new(0, 520, 1, 0)
	centerBar.BackgroundTransparency = 1
	centerBar.ClipsDescendants = not legacy

	const shell = centerBar:FindFirstChild("Horizontal")
	if shell and shell:IsA("GuiObject") then
		shell.ZIndex = legacy and 2 or 20
		shell.BackgroundColor3 = legacy and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(13, 13, 15)
		shell.BackgroundTransparency = legacy and 0.2 or 0.04
		const corner = shell:FindFirstChildOfClass("UICorner")
		if corner then
			corner.CornerRadius = UDim.new(0, legacy and 8 or 12)
		end
		const gradient = shell:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient.Color = legacy and ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 50)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
			}) or ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 23)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 12))
			})
		end
		const outline = shell:FindFirstChild("CmdOutline")
		if outline and outline:IsA("UIStroke") then
			outline.Enabled = not legacy
			outline.Transparency = NAStuff.cmdBarSelected == true and 0.18 or 0.58
		end
	end

	inputObj.Active = not legacy
	inputObj.ZIndex = legacy and 2 or 23
	inputObj.TextWrapped = legacy
	inputObj.TextSize = legacy and 20 or 15
	inputObj.TextScaled = legacy
	inputObj.TextXAlignment = legacy and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
	inputObj.TextColor3 = legacy and Color3.fromRGB(245, 245, 255) or Color3.fromRGB(246, 246, 248)
	inputObj.FontFace = legacy
		and Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	inputObj.AnchorPoint = legacy and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5)
	inputObj.Size = legacy and UDim2.new(1, -10, 0.7, 0) or UDim2.new(1, -207, 1, 0)
	inputObj.Position = legacy and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 43, 0.5, 0)
	inputObj.ClearTextOnFocus = legacy
	NAStuff.defaultCmdClear = legacy
	inputObj.PlaceholderColor3 = legacy and Color3.fromRGB(178, 178, 178) or Color3.fromRGB(130, 130, 138)
	const inputPadding = inputObj:FindFirstChildOfClass("UIPadding")
	if inputPadding then
		inputPadding.PaddingLeft = UDim.new(0, 0)
		inputPadding.PaddingRight = UDim.new(0, 0)
	end

	for _, name in { "Prompt", "EnterHint", "TabHint" } do
		const obj = centerBar:FindFirstChild(name)
		if obj and obj:IsA("GuiObject") then
			obj.Visible = not legacy
		end
	end

	leftFill.AnchorPoint = Vector2.new(0, 0.5)
	leftFill.Size = legacy and UDim2.new(0.5, -140, 1, 0) or UDim2.new(0, 0, 1, 0)
	leftFill.Position = legacy and UDim2.new(0, 0, 0.5, 0) or UDim2.new(0.5, -260, 0.5, 0)
	leftFill.Visible = legacy
	const leftVisual = leftFill:FindFirstChild("Horizontal")
	if leftVisual and leftVisual:IsA("GuiObject") then
		leftVisual.BackgroundColor3 = legacy and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(255, 255, 255)
		leftVisual.BackgroundTransparency = legacy and 0.2 or 1
		leftVisual.Size = legacy and UDim2.new(1.005, 0, 1, 0) or UDim2.new(1, 0, 1, 0)
	end

	rightFill.AnchorPoint = Vector2.new(1, 0.5)
	rightFill.Size = legacy and UDim2.new(0.5, -140, 1, 0) or UDim2.new(0, 0, 1, 0)
	rightFill.Position = legacy and UDim2.new(1, 0, 0.5, 0) or UDim2.new(0.5, 260, 0.5, 0)
	rightFill.Visible = legacy
	const rightVisual = rightFill:FindFirstChild("Horizontal")
	if rightVisual and rightVisual:IsA("GuiObject") then
		rightVisual.BackgroundColor3 = legacy and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(255, 255, 255)
		rightVisual.BackgroundTransparency = legacy and 0.2 or 1
		rightVisual.Size = legacy and UDim2.new(1.005, 0, 1, 0) or UDim2.new(1, 0, 1, 0)
		rightVisual.Position = legacy and UDim2.new(-0.005, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
	end

	autofill.CanvasSize = legacy and UDim2.new(0, 0, 5, 0) or UDim2.new(0, 0, 0, 0)
	autofill.ScrollingEnabled = false
	autofill.BackgroundColor3 = legacy and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(12, 12, 14)
	autofill.Selectable = false
	autofill.AnchorPoint = legacy and Vector2.new(0.5, 0) or Vector2.new(0.5, 1)
	autofill.Size = legacy and UDim2.new(1, 0, 0, 150) or UDim2.new(0, 520, 0, 56)
	autofill.Position = legacy and UDim2.new(0.5, 0, -6.5, 15) or UDim2.new(0.5, 0, 0, -10)
	autofill.BackgroundTransparency = 1
	autofill.BorderSizePixel = 0
	autofill.ScrollBarThickness = legacy and 12 or 0
	autofill.ClipsDescendants = not legacy
	autofill.ZIndex = legacy and 1 or 18
	const autofillCorner = autofill:FindFirstChildOfClass("UICorner")
	if autofillCorner then
		autofillCorner.CornerRadius = UDim.new(0, legacy and 0 or 12)
	end
	const autofillOutline = autofill:FindFirstChild("AutofillOutline")
	if autofillOutline and autofillOutline:IsA("UIStroke") then
		autofillOutline.Enabled = not legacy
		autofillOutline.Transparency = 1
	end
	const autofillPadding = autofill:FindFirstChildOfClass("UIPadding")
	if autofillPadding then
		const amount = legacy and 0 or 8
		autofillPadding.PaddingTop = UDim.new(0, amount)
		autofillPadding.PaddingBottom = UDim.new(0, amount)
		autofillPadding.PaddingLeft = UDim.new(0, amount)
		autofillPadding.PaddingRight = UDim.new(0, amount)
	end
	const layout = autofill:FindFirstChildOfClass("UIListLayout")
	if layout then
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Padding = UDim.new(0, legacy and 5 or 6)
		layout.VerticalAlignment = legacy and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
		layout.SortOrder = Enum.SortOrder.LayoutOrder
	end

	if NAUIMANAGER.cmdExample then
		NAmanage.ApplyCmdAutofillFrameMode(NAUIMANAGER.cmdExample, legacy)
	end
	const pool = NAStuff and NAStuff.CmdAutofillPool
	if type(pool) == "table" then
		for i = 1, #pool do
			NAmanage.ApplyCmdAutofillFrameMode(pool[i], legacy)
		end
	end

	fillSizes = {
		right = legacy and UDim2.new(0.5, -140, 1, 0) or UDim2.new(0, 0, 1, 0),
		left = legacy and UDim2.new(0.5, -140, 1, 0) or UDim2.new(0, 0, 1, 0)
	}
	cmdBarExpandedSize = legacy and UDim2.new(0, 280, 1, 10) or UDim2.new(0, 520, 1, 0)
	NAStuff.cmdAutofillLimit = legacy and 5 or (NAStuff.cmdAutofillLimit or 5)
	NAStuff.cmdAutofillRowHeight = legacy and 28 or (NAStuff.cmdAutofillRowHeight or 38)
	NAmanage.ApplyCommandPredictionMode(legacy)

	if not legacy and type(NAmanage.PositionCmdBarAtViewportCenter) == "function" and opts.skipPosition ~= true then
		NAmanage.PositionCmdBarAtViewportCenter()
	end
	if type(NAmanage.ApplyCmdAutofillVisibility) == "function" then
		NAmanage.ApplyCmdAutofillVisibility({ refresh = false })
	else
		autofill.Visible = legacy and NAStuff.HideCmdAutofill ~= true or false
	end
	return true
end

NAmanage.SetLegacyCommandUI = function(enabled, opts)
	opts = type(opts) == "table" and opts or {}
	const active = NAmanage.isCmdBarActive and NAmanage.isCmdBarActive() == true
	NAStuff.LegacyCommandUI = enabled == true
	if opts.save ~= false and type(NAmanage.NASettingsSet) == "function" then
		pcall(NAmanage.NASettingsSet, "legacyCommandUI", NAStuff.LegacyCommandUI)
	end
	NAmanage.ApplyCommandUIMode()
	if active and type(NAgui.barSelect) == "function" then
		NAgui.barSelect(0)
		if type(NAgui.autoFILLLL) == "function" then
			Delay(0, NAgui.autoFILLLL)
		end
	elseif type(NAgui.barDeselect) == "function" then
		NAgui.barDeselect(0)
	end
	if opts.notify == true then
		DoNotif("Legacy command input + autofill "..(NAStuff.LegacyCommandUI and "enabled" or "disabled"), 2)
	end
	return NAStuff.LegacyCommandUI
end

NAmanage.ApplyCommandUIMode({ skipPosition = true })

fillSizes = {
	right = NAUIMANAGER.rightFill.Size,
	left = NAUIMANAGER.leftFill.Size
};
cmdBarExpandedSize = NAmanage.IsLegacyCommandUI() and UDim2.new(0, 280, 1, 10) or (NAUIMANAGER.centerBar and NAUIMANAGER.centerBar.Size or UDim2.new(0, 520, 1, 0))
NAmanage.PositionCmdBarAtViewportCenter = function()
	const bar = NAUIMANAGER and NAUIMANAGER.cmdBar
	if not (bar and bar:IsA("GuiObject")) then return end
	if NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() then
		bar.Size = UDim2.new(1, 0, 0, 30)
		bar.Position = UDim2.new(0.5, 0, 0.5, -20)
		cmdBarExpandedSize = UDim2.new(0, 280, 1, 10)
		NAStuff.cmdAutofillLimit = 5
		NAStuff.cmdAutofillRowHeight = 28
		const centerBar = NAUIMANAGER and NAUIMANAGER.centerBar
		if centerBar and NAStuff.cmdBarSelected == true then
			centerBar.Size = cmdBarExpandedSize
		end
		return
	end
	const camera = Services.Workspace and Services.Workspace.CurrentCamera
	const viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local uiScale = 1
	if NAUIMANAGER.AUTOSCALER and tonumber(NAUIMANAGER.AUTOSCALER.Scale) then
		uiScale = math.max(tonumber(NAUIMANAGER.AUTOSCALER.Scale), 0.01)
	end
	const availableWidth = math.max(280, math.floor(((viewport.X - 24) / uiScale) + 0.5))
	const barWidth = math.min(520, availableWidth)
	cmdBarExpandedSize = UDim2.new(0, barWidth, 1, 0)
	const centerBar = NAUIMANAGER.centerBar
	if centerBar and (NAStuff.cmdBarSelected == true or centerBar.Size.X.Offset > 1) then
		centerBar.Size = cmdBarExpandedSize
	end

	const touchOnly = Services.UserInputService and Services.UserInputService.TouchEnabled
		and not Services.UserInputService.KeyboardEnabled and not Services.UserInputService.MouseEnabled
	const mobileLayout = IsOnMobile == true or touchOnly
	const compactMobile = mobileLayout and viewport.Y < 620
	const suggestionLimit = compactMobile and 3 or 5
	const suggestionRowHeight = compactMobile and 40 or 38
	NAStuff.cmdAutofillLimit = suggestionLimit
	NAStuff.cmdAutofillRowHeight = suggestionRowHeight
	const autofill = NAUIMANAGER.cmdAutofill
	if autofill and autofill:IsA("GuiObject") then
		const visibleCount = math.clamp(tonumber(NAStuff.cmdAutofillVisibleCount) or 1, 1, suggestionLimit)
		const autofillHeight = 16 + (visibleCount * suggestionRowHeight) + ((visibleCount - 1) * 6)
		autofill.Size = UDim2.new(0, barWidth, 0, autofillHeight)
	end
	if centerBar then
		const tabHint = centerBar:FindFirstChild("TabHint")
		const input = centerBar:FindFirstChild("Input")
		if tabHint and tabHint:IsA("TextLabel") then
			tabHint.Text = "TAB  AUTOFILL"
			tabHint.Visible = not mobileLayout
		end
		const function layoutCmdTextBox(textBox)
			if not (textBox and textBox:IsA("TextBox")) then return end
			const rightClearance = mobileLayout and 76 or 164
			textBox.AnchorPoint = Vector2.new(0, 0.5)
			textBox.Position = UDim2.new(0, 43, 0.5, 0)
			textBox.Size = UDim2.new(1, -(43 + rightClearance), 1, 0)
			const padding = textBox:FindFirstChildOfClass("UIPadding")
			if padding then
				padding.PaddingLeft = UDim.new(0, 0)
				padding.PaddingRight = UDim.new(0, 0)
			end
		end
		layoutCmdTextBox(input)
		layoutCmdTextBox(predictionInput)
	end
	local offsetX, offsetY = 0, 0
	const screenGui = NAStuff and NAStuff.NASCREENGUI
	const ignoresInset = screenGui and screenGui:IsA("ScreenGui") and screenGui.IgnoreGuiInset == true
	if not ignoresInset and Services.GuiService and Services.GuiService.GetGuiInset then
		local ok, topLeft, bottomRight = pcall(Services.GuiService.GetGuiInset, Services.GuiService)
		if ok and typeof(topLeft) == "Vector2" and typeof(bottomRight) == "Vector2" then
			offsetX = math.floor(((topLeft.X - bottomRight.X) * 0.5) + 0.5)
			offsetY = math.floor(((topLeft.Y - bottomRight.Y) * 0.5) + 0.5)
		end
	end
	bar.Position = UDim2.new(0.5, offsetX, 0.5, offsetY)
end
NAmanage.PositionCmdBarAtViewportCenter()
if Services.Workspace and Services.Workspace.CurrentCamera then
	NAlib.connect("CmdBarViewportCenter", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(NAmanage.PositionCmdBarAtViewportCenter))
end
if NAUIMANAGER.AUTOSCALER then
	NAlib.connect("CmdBarUIScale", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(NAmanage.PositionCmdBarAtViewportCenter))
end
if Services.GuiService then
	pcall(function()
		NAlib.connect("CmdBarInsetCenter", Services.GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(NAmanage.PositionCmdBarAtViewportCenter))
	end)
end
if NAUIMANAGER.cmdExample then
	NAUIMANAGER.cmdExample.Parent = nil;
end;
if NAUIMANAGER.chatExample then
	NAUIMANAGER.chatExample.Parent = nil;
end;
if NAUIMANAGER.NAconsoleExample then
	NAUIMANAGER.NAconsoleExample.Parent = nil;
end;
if NAUIMANAGER.commandExample then
	NAUIMANAGER.commandExample.Parent = nil;
end;
if NAUIMANAGER.resizeFrame then
	NAUIMANAGER.resizeFrame.Parent = nil;
end;
if NAUIMANAGER.SettingsButton then
	NAUIMANAGER.SettingsButton.Parent = nil;
end;
if NAUIMANAGER.SettingsColorPicker then
	NAUIMANAGER.SettingsColorPicker.Parent = nil;
end;
if NAUIMANAGER.SettingsSectionTitle then
	NAUIMANAGER.SettingsSectionTitle.Parent = nil;
end;
if NAUIMANAGER.SettingsToggle then
	NAUIMANAGER.SettingsToggle.Parent = nil;
end;
if NAUIMANAGER.SettingsInput then
	NAUIMANAGER.SettingsInput.Parent = nil;
end;
if NAUIMANAGER.SettingsKeybind then
	NAUIMANAGER.SettingsKeybind.Parent = nil;
end;
if NAUIMANAGER.SettingsSlider then
	NAUIMANAGER.SettingsSlider.Parent = nil;
end;
if NAUIMANAGER.SettingsDropdown then
	NAUIMANAGER.SettingsDropdown.Parent = nil;
end;
if NAUIMANAGER.SettingsTabButton then
	NAUIMANAGER.SettingsTabButton.Parent = nil;
end;
if NAUIMANAGER.WPFrame then
	NAUIMANAGER.WPFrame.Parent = nil;
end;
templates = {
	Button = NAUIMANAGER.SettingsButton,
	ColorPicker = NAUIMANAGER.SettingsColorPicker,
	SectionTitle = NAUIMANAGER.SettingsSectionTitle,
	Toggle = NAUIMANAGER.SettingsToggle,
	Input = NAUIMANAGER.SettingsInput,
	Keybind = NAUIMANAGER.SettingsKeybind,
	Slider = NAUIMANAGER.SettingsSlider,
	Dropdown = NAUIMANAGER.SettingsDropdown,
	WaypointerFrame = NAUIMANAGER.WPFrame
};
TabManager = {
	holder = NAUIMANAGER.SettingsTabs,
	container = NAUIMANAGER.SettingsPages,
	template = NAUIMANAGER.SettingsTabButton,
	defaultPage = NAUIMANAGER.SettingsList,
	tabs = {},
	order = {},
	current = nil,
	fallback = nil,
	fallbackIndex = 0,
	lastNonAll = nil
};

NAmanage.SettingsTabLayout = NAmanage.SettingsTabLayout or {}
do
	const layoutState = NAmanage.SettingsTabLayout

	layoutState.IsHorizontal = function()
		return NAStuff.LegacyHorizontalSettingsTabs == true
	end

	layoutState.IsCompact = function()
		return layoutState.IsHorizontal() ~= true and NAStuff.SettingsSidebarCompactMode == true
	end

	layoutState.GetScale = function()
		local scale = NAUIMANAGER and NAUIMANAGER.AUTOSCALER and tonumber(NAUIMANAGER.AUTOSCALER.Scale) or tonumber(NAUIScale) or 1
		if not scale or scale <= 0 then
			scale = 1
		end
		return scale
	end

	layoutState.CapturePreferredSize = function(force)
		const frame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
		if not frame then
			return layoutState.preferredSize
		end
		if not force and layoutState.preferredSize then
			return layoutState.preferredSize
		end
		const size = frame.Size
		local width = tonumber(size.X.Offset) or 0
		local height = tonumber(size.Y.Offset) or 0
		if width <= 0 or height <= 0 then
			const logical = NAmanage.GetLogicalAbsoluteSize and NAmanage.GetLogicalAbsoluteSize(frame) or Vector2.new(720, 480)
			width = math.max(1, tonumber(logical.X) or 720)
			height = math.max(1, tonumber(logical.Y) or 480)
		end
		layoutState.preferredSize = Vector2.new(width, height)
		return layoutState.preferredSize
	end

	layoutState.FitFrameToViewport = function()
		const frame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
		if not frame or layoutState.internalSizeChange == true then
			return false
		end
		if NAmanage.GetAttr and (NAmanage.GetAttr(frame, "NAMenuMaximized") == true or NAmanage.GetAttr(frame, "NAMenuMinimized") == true) then
			return false
		end
		const preferred = layoutState.CapturePreferredSize(false)
		if not preferred then
			return false
		end
		local viewport = NAStuff and NAStuff.NASCREENGUI and NAStuff.NASCREENGUI.AbsoluteSize or nil
		if not viewport or viewport.X <= 0 or viewport.Y <= 0 then
			viewport = Services.Workspace and Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		end
		const scale = layoutState.GetScale()
		const maxWidth = math.max(220, math.floor(((viewport.X - 24) / scale) + 0.5))
		const maxHeight = math.max(160, math.floor(((viewport.Y - 24) / scale) + 0.5))
		const targetWidth = math.min(preferred.X, maxWidth)
		const targetHeight = math.min(preferred.Y, maxHeight)
		const current = frame.Size
		if math.abs((tonumber(current.X.Offset) or 0) - targetWidth) < 1 and math.abs((tonumber(current.Y.Offset) or 0) - targetHeight) < 1 then
			return false
		end
		layoutState.internalSizeChange = true
		frame.Size = UDim2.fromOffset(targetWidth, targetHeight)
		layoutState.internalSizeChange = false
		return true
	end

	layoutState.GetLogicalSize = function(inst, fallback)
		if inst and type(NAmanage.GetLogicalAbsoluteSize) == "function" then
			local ok, size = pcall(NAmanage.GetLogicalAbsoluteSize, inst)
			if ok and typeof(size) == "Vector2" and size.X > 0 and size.Y > 0 then
				return size
			end
		end
		return fallback or Vector2.new(700, 414)
	end

	layoutState.StyleButton = function(button, horizontal)
		if not (button and button:IsA("GuiObject")) then
			return
		end
		const compact = not horizontal and NAStuff.SettingsSidebarCompactMode == true
		const title = button:FindFirstChild("Title")
		const interact = button:FindFirstChild("Interact")
		button.ZIndex = 6
		if title and title:IsA("GuiObject") then
			title.ZIndex = 7
		end
		if interact and interact:IsA("GuiObject") then
			interact.ZIndex = 8
		end
		if horizontal then
			button.Size = UDim2.new(0, 124, 0, 32)
			if title and title:IsA("TextLabel") then
				title.TextXAlignment = Enum.TextXAlignment.Center
				title.Position = UDim2.new(0, 5, 0, 0)
				title.Size = UDim2.new(1, -10, 1, 0)
			end
		elseif compact then
			button.Size = UDim2.new(0, 40, 0, 36)
			if title and title:IsA("TextLabel") then
				title.TextXAlignment = Enum.TextXAlignment.Center
				title.Position = UDim2.new(0, 0, 0, 0)
				title.Size = UDim2.new(1, 0, 1, 0)
			end
		else
			button.Size = UDim2.new(1, -12, 0, 34)
			if title and title:IsA("TextLabel") then
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.Position = UDim2.new(0, 12, 0, 0)
				title.Size = UDim2.new(1, -20, 1, 0)
			end
		end
	end

	layoutState.UpdateTabCanvas = function(resetPosition)
		const tabList = NAUIMANAGER and NAUIMANAGER.SettingsTabs
		if not (tabList and tabList:IsA("ScrollingFrame")) then
			return false
		end
		const listLayout = tabList:FindFirstChildWhichIsA("UIListLayout")
		if not listLayout then
			return false
		end
		local scale = NAmanage.GetUIScaleFactor and NAmanage.GetUIScaleFactor(tabList) or layoutState.GetScale()
		if not scale or scale <= 0 then
			scale = 1
		end
		const content = listLayout.AbsoluteContentSize
		const padding = tabList:FindFirstChildWhichIsA("UIPadding")
		local padX = 0
		local padY = 0
		if padding then
			padX = (padding.PaddingLeft.Offset or 0) + (padding.PaddingRight.Offset or 0)
			padY = (padding.PaddingTop.Offset or 0) + (padding.PaddingBottom.Offset or 0)
		end
		const horizontal = layoutState.IsHorizontal()
		tabList.AutomaticCanvasSize = Enum.AutomaticSize.None
		if horizontal then
			const width = math.max(0, math.ceil((content.X / scale) + padX + 2))
			tabList.CanvasSize = UDim2.fromOffset(width, 0)
		else
			const height = math.max(0, math.ceil((content.Y / scale) + padY + 2))
			tabList.CanvasSize = UDim2.fromOffset(0, height)
		end
		Defer(function()
			if not (tabList and tabList.Parent) then
				return
			end
			pcall(function() tabList:ResetScrollVelocity() end)
			if resetPosition then
				tabList.CanvasPosition = Vector2.new(0, 0)
				return
			end
			const maxX = math.max(0, tabList.AbsoluteCanvasSize.X - tabList.AbsoluteWindowSize.X)
			const maxY = math.max(0, tabList.AbsoluteCanvasSize.Y - tabList.AbsoluteWindowSize.Y)
			const pos = tabList.CanvasPosition
			tabList.CanvasPosition = Vector2.new(math.clamp(pos.X, 0, maxX), math.clamp(pos.Y, 0, maxY))
		end)
		return true
	end

	layoutState.SyncTabButtons = function(horizontal)
		const tabList = NAUIMANAGER and NAUIMANAGER.SettingsTabs
		if not tabList then
			return
		end
		if TabManager and type(TabManager.tabs) == "table" then
			for _, info in TabManager.tabs do
				if info and info.button then
					if info.button.Parent ~= tabList then
						info.button.Parent = tabList
					end
					info.button.Visible = true
					layoutState.StyleButton(info.button, horizontal)
					if originalIO and type(originalIO.applyTabDisplayText) == "function" then
						originalIO.applyTabDisplayText(info, {
							isActive = info._isActive,
							defaultColor = NAUISTROKER or DEFAULT_UI_STROKE_COLOR
						})
					end
				end
			end
		end
	end

	layoutState.EnsureCompactToggleButton = function(sidebar)
		if not (sidebar and sidebar:IsA("GuiObject")) then
			return nil
		end
		local button = sidebar:FindFirstChild("CompactModeToggle")
		if button and not button:IsA("TextButton") then
			pcall(function() button:Destroy() end)
			button = nil
		end
		if not button then
			button = Instance.new("TextButton")
			button.Name = "CompactModeToggle"
			button.AnchorPoint = Vector2.new(0.5, 1)
			button.Position = UDim2.new(0.5, 0, 1, -7)
			button.Size = UDim2.new(1, -14, 0, 32)
			button.BorderSizePixel = 0
			button.BackgroundColor3 = Color3.fromRGB(31, 32, 42)
			button.BackgroundTransparency = 0.12
			button.AutoButtonColor = false
			button.TextColor3 = Color3.fromRGB(235, 235, 245)
			button.TextSize = 13
			button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			button.ZIndex = 8
			button.Parent = sidebar

			const corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = button

			const stroke = Instance.new("UIStroke")
			stroke.Name = "UIStroker"
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Thickness = 1
			stroke.Transparency = 0.34
			stroke.Color = NAUISTROKER or DEFAULT_UI_STROKE_COLOR or Color3.fromRGB(155, 100, 255)
			stroke.Parent = button
			if NAgui and type(NAgui.RegisterColoredStroke) == "function" then
				NAgui.RegisterColoredStroke(stroke)
			end

			MouseButtonFix(button, function()
				if layoutState.IsHorizontal() then
					return
				end
				if type(NAmanage.SetSettingsSidebarCompact) == "function" then
					NAmanage.SetSettingsSidebarCompact(not NAStuff.SettingsSidebarCompactMode, { save = true })
				else
					NAStuff.SettingsSidebarCompactMode = not NAStuff.SettingsSidebarCompactMode
					layoutState.Apply()
				end
			end)
		end
		return button
	end

	layoutState.Apply = function(opts)
		opts = type(opts) == "table" and opts or {}
		const tabContainer = NAUIMANAGER and NAUIMANAGER.SettingsTabContainer
		const tabList = NAUIMANAGER and NAUIMANAGER.SettingsTabs
		const searchBox = NAUIMANAGER and NAUIMANAGER.SettingsSearchBox
		const pages = NAUIMANAGER and NAUIMANAGER.SettingsPages
		if not (tabContainer and tabList and searchBox and pages) then
			return false
		end

		const horizontal = layoutState.IsHorizontal()
		const compact = layoutState.IsCompact()
		const listLayout = tabList:FindFirstChildWhichIsA("UIListLayout")
		const sidebar = tabContainer:FindFirstChild("SidebarSurface")
		const compactToggle = layoutState.EnsureCompactToggleButton(sidebar)

		const modeChanged = layoutState.lastHorizontal ~= nil and layoutState.lastHorizontal ~= horizontal
		layoutState.lastHorizontal = horizontal
		tabList.AutomaticCanvasSize = Enum.AutomaticSize.None
		tabList.CanvasSize = UDim2.fromOffset(0, 0)
		tabList.ElasticBehavior = Enum.ElasticBehavior.Never
		tabList.ScrollingEnabled = true
		tabList.ZIndex = 5

		if horizontal then
			if sidebar and sidebar:IsA("GuiObject") then
				sidebar.Visible = false
			end
			if compactToggle then
				compactToggle.Visible = false
			end
			tabList.Visible = true
			tabList.ScrollingDirection = Enum.ScrollingDirection.X
			tabList.Size = UDim2.new(1, -16, 0, 40)
			tabList.Position = UDim2.new(0, 8, 0, 8)
			tabList.ScrollBarThickness = 2
			if listLayout then
				listLayout.FillDirection = Enum.FillDirection.Horizontal
				listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				listLayout.Padding = UDim.new(0, 6)
			end
			searchBox.Position = UDim2.new(0, 8, 0, 56)
			searchBox.Size = UDim2.new(1, -16, 0, 36)
			pages.Position = UDim2.new(0, 8, 0, 100)
			pages.Size = UDim2.new(1, -16, 1, -108)
		else
			const logical = layoutState.GetLogicalSize(tabContainer, Vector2.new(700, 414))
			const minSidebar = IsOnMobile and 132 or 148
			const maxSidebar = IsOnMobile and 160 or 190
			const expandedWidth = math.clamp(math.floor((logical.X * 0.25) + 0.5), minSidebar, maxSidebar)
			const sidebarWidth = compact and (IsOnMobile and 54 or 58) or expandedWidth
			const contentX = sidebarWidth + 14
			if sidebar and sidebar:IsA("GuiObject") then
				sidebar.Visible = true
				sidebar.Position = UDim2.new(0, 4, 0, 4)
				sidebar.Size = UDim2.new(0, sidebarWidth, 1, -8)
			end
			if compactToggle then
				compactToggle.Visible = true
				compactToggle.Size = compact and UDim2.new(0, 40, 0, 32) or UDim2.new(1, -14, 0, 32)
				compactToggle.Text = compact and ">>" or "<<  Compact"
				compactToggle.TextSize = compact and 15 or 13
			end
			tabList.Visible = true
			tabList.ScrollingDirection = Enum.ScrollingDirection.Y
			tabList.Size = UDim2.new(0, compact and 46 or math.max(104, sidebarWidth - 8), 1, -56)
			tabList.Position = UDim2.new(0, compact and 6 or 8, 0, 8)
			tabList.ScrollBarThickness = compact and 0 or 2
			if listLayout then
				listLayout.FillDirection = Enum.FillDirection.Vertical
				listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
				listLayout.Padding = UDim.new(0, 5)
			end
			searchBox.Position = UDim2.new(0, contentX, 0, 8)
			searchBox.Size = UDim2.new(1, -(contentX + 8), 0, 36)
			pages.Position = UDim2.new(0, contentX, 0, 52)
			pages.Size = UDim2.new(1, -(contentX + 8), 1, -60)
		end

		layoutState.StyleButton(TabManager and TabManager.template, horizontal)
		layoutState.SyncTabButtons(horizontal)
		const resetCanvas = opts.resetCanvas == true or modeChanged
		if resetCanvas then
			tabList.CanvasPosition = Vector2.new(0, 0)
		end
		Defer(function()
			if layoutState and type(layoutState.SyncTabButtons) == "function" then
				layoutState.SyncTabButtons(horizontal)
			end
			if layoutState and type(layoutState.UpdateTabCanvas) == "function" then
				layoutState.UpdateTabCanvas(resetCanvas)
			end
		end)

		if NAUIMANAGER.SettingsList and type(updateCanvasSize) == "function" then
			Defer(function()
				if NAUIMANAGER and NAUIMANAGER.SettingsList then
					updateCanvasSize(NAUIMANAGER.SettingsList, layoutState.GetScale())
				end
			end)
		end
		return true
	end

	NAmanage.GetSettingsResizeMin = function()
		const horizontal = layoutState.IsHorizontal()
		const compact = layoutState.IsCompact()
		const base = horizontal
			and (IsOnMobile and Vector2.new(340, 270) or Vector2.new(440, 320))
			or (compact
				and (IsOnMobile and Vector2.new(330, 280) or Vector2.new(430, 340))
				or (IsOnMobile and Vector2.new(390, 300) or Vector2.new(520, 360)))
		local viewport = NAStuff and NAStuff.NASCREENGUI and NAStuff.NASCREENGUI.AbsoluteSize or nil
		if not viewport or viewport.X <= 0 or viewport.Y <= 0 then
			viewport = Services.Workspace and Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		end
		const scale = layoutState.GetScale()
		const maxX = math.max(220, math.floor(((viewport.X - 24) / scale) + 0.5))
		const maxY = math.max(160, math.floor(((viewport.Y - 24) / scale) + 0.5))
		return Vector2.new(math.min(base.X, maxX), math.min(base.Y, maxY))
	end

	NAmanage.RefreshSettingsResizeHandle = function()
		if NAgui and type(NAgui.resizeable) == "function" and NAUIMANAGER and NAUIMANAGER.SettingsFrame then
			return NAgui.resizeable(NAUIMANAGER.SettingsFrame, NAmanage.GetSettingsResizeMin(), Vector2.new(5000, 5000))
		end
	end

	NAmanage.SetSettingsSidebarCompact = function(enabled, opts)
		opts = type(opts) == "table" and opts or {}
		NAStuff.SettingsSidebarCompactMode = enabled == true
		if opts.save ~= false and type(NAmanage.NASettingsSet) == "function" then
			pcall(NAmanage.NASettingsSet, "compactVerticalSettingsTabs", NAStuff.SettingsSidebarCompactMode)
		end
		layoutState.Apply({ resetCanvas = opts.resetCanvas == true })
		if opts.refreshResize ~= false then
			Defer(NAmanage.RefreshSettingsResizeHandle)
		end
		return NAStuff.SettingsSidebarCompactMode
	end

	NAmanage.SetHorizontalSettingsTabs = function(enabled, opts)
		opts = type(opts) == "table" and opts or {}
		NAStuff.LegacyHorizontalSettingsTabs = enabled == true
		if opts.save ~= false and type(NAmanage.NASettingsSet) == "function" then
			pcall(NAmanage.NASettingsSet, "legacyHorizontalSettingsTabs", NAStuff.LegacyHorizontalSettingsTabs)
		end
		layoutState.Apply({ resetCanvas = true })
		if opts.refreshResize ~= false then
			Defer(NAmanage.RefreshSettingsResizeHandle)
		end
		return NAStuff.LegacyHorizontalSettingsTabs
	end

	layoutState.CapturePreferredSize(true)
	layoutState.FitFrameToViewport()

	NAlib.disconnect("NA_SettingsTabLayout")
	if NAUIMANAGER and NAUIMANAGER.SettingsFrame then
		NAlib.connect("NA_SettingsTabLayout", NAUIMANAGER.SettingsFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			layoutState.Apply()
		end))
		NAlib.connect("NA_SettingsTabLayout", NAUIMANAGER.SettingsFrame:GetPropertyChangedSignal("Size"):Connect(function()
			if layoutState.internalSizeChange ~= true and NAmanage.GetAttr and NAmanage.GetAttr(NAUIMANAGER.SettingsFrame, "NAResizeActive") == true then
				layoutState.CapturePreferredSize(true)
			end
		end))
	end
	if NAUIMANAGER and NAUIMANAGER.AUTOSCALER then
		NAlib.connect("NA_SettingsTabLayout", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(function()
			Defer(function()
				layoutState.FitFrameToViewport()
				layoutState.Apply()
				NAmanage.RefreshSettingsResizeHandle()
				const settingsFrame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
				if settingsFrame and settingsFrame.Parent and settingsFrame.Visible and type(NAmanage.centerFrame) == "function" then
					NAmanage.centerFrame(settingsFrame)
				end
			end)
		end))
	end
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NA_SettingsTabLayout", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Defer(function()
				layoutState.FitFrameToViewport()
				layoutState.Apply()
				NAmanage.RefreshSettingsResizeHandle()
			end)
		end))
	end
	const tabCanvasList = NAUIMANAGER and NAUIMANAGER.SettingsTabs
	const tabCanvasLayout = tabCanvasList and tabCanvasList:FindFirstChildWhichIsA("UIListLayout")
	NAlib.disconnect("NA_SettingsTabCanvasContent")
	NAlib.disconnect("NA_SettingsTabCanvasSize")
	if tabCanvasLayout then
		NAlib.connect("NA_SettingsTabCanvasContent", tabCanvasLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Defer(function()
				if layoutState and type(layoutState.UpdateTabCanvas) == "function" then
					layoutState.UpdateTabCanvas(false)
				end
			end)
		end))
	end
	if tabCanvasList then
		NAlib.connect("NA_SettingsTabCanvasSize", tabCanvasList:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Defer(function()
				if layoutState and type(layoutState.UpdateTabCanvas) == "function" then
					layoutState.UpdateTabCanvas(false)
				end
			end)
		end))
	end
	layoutState.Apply({ resetCanvas = false })
end

BUILDER_ICON_FONT_PATH = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"

originalIO.escapeRichTextText = function(text)
	text = tostring(text or "");
	if text == "" then
		return "";
	end;
	return ((text:gsub("&", "&amp;")):gsub("<", "&lt;")):gsub(">", "&gt;");
end;
originalIO.colorValueToHex = function(color)
	if typeof(color) == "Color3" then
		const r = math.clamp(math.floor(color.R * 255 + 0.5), 0, 255);
		const g = math.clamp(math.floor(color.G * 255 + 0.5), 0, 255);
		const b = math.clamp(math.floor(color.B * 255 + 0.5), 0, 255);
		return Format("#%02X%02X%02X", r, g, b);
	elseif type(color) == "string" and color ~= "" then
		return color;
	end;
	return nil;
end;
originalIO.resolveTabIconMarkup = function(iconOption, opts)
	if iconOption == nil then
		return nil;
	end;
	opts = opts or {};
	const isActive = opts.isActive == true;
	const defaultColor = opts.defaultColor;
	local name = iconOption;
	local gap;
	local tint;
	local stateBold;
	if type(iconOption) == "table" then
		name = iconOption.icon or iconOption.name or iconOption[1];
		gap = iconOption.gap or iconOption.spacing;
		if iconOption.color or iconOption.tint then
			tint = iconOption.color or iconOption.tint;
		end;
		if isActive and iconOption.activeBold ~= nil then
			stateBold = iconOption.activeBold;
		elseif not isActive and iconOption.inactiveBold ~= nil then
			stateBold = iconOption.inactiveBold;
		elseif isActive and iconOption.activeFilled ~= nil then
			stateBold = iconOption.activeFilled;
		elseif not isActive and iconOption.inactiveFilled ~= nil then
			stateBold = iconOption.inactiveFilled;
		end;
		if stateBold == nil then
			if iconOption.bold ~= nil then
				stateBold = iconOption.bold;
			elseif iconOption.filled ~= nil then
				stateBold = iconOption.filled;
			elseif iconOption.weight == "bold" or iconOption.variant == "filled" then
				stateBold = true;
			end;
		end;
	end;
	if type(name) ~= "string" then
		return nil;
	end;
	const trimmed = name:match("^%s*(.-)%s*$");
	if not trimmed or trimmed == "" then
		return nil;
	end;
	local glyph = trimmed:gsub("%s+", "");
	glyph = originalIO.escapeRichTextText(glyph);
	if glyph == "" then
		return nil;
	end;
	if stateBold == nil then
		stateBold = isActive;
	end;
	if stateBold then
		glyph = "<b>" .. glyph .. "</b>";
	end;
	local markup = Format("<font family=\"%s\">%s</font>", BUILDER_ICON_FONT_PATH, glyph);
	const colorHex = originalIO.colorValueToHex(tint or defaultColor);
	if colorHex then
		markup = Format("<font color=\"%s\">%s</font>", colorHex, markup);
	end;
	local iconGap = " ";
	if type(gap) == "number" and gap > 0 then
		iconGap = string.rep(" ", math.clamp(math.floor(gap + 0.5), 1, 8));
	elseif type(gap) == "string" and gap ~= "" then
		iconGap = gap;
	end;
	return markup, iconGap;
end;
originalIO.composeTabTitleText = function(info, opts)
	if not info then
		return "";
	end;
	opts = opts or {};
	local rawTitle = nil;
	const translator = NAStuff and NAStuff.ChatTranslator;
	const settingsLang = translator and translator.settingsTarget;
	if type(settingsLang) == "string" and settingsLang ~= ""
		and type(info.localizedDisplay) == "table"
		and type(info.localizedDisplay[settingsLang]) == "string"
		and info.localizedDisplay[settingsLang] ~= "" then
		rawTitle = info.localizedDisplay[settingsLang];
	end;
	if type(rawTitle) ~= "string" or rawTitle == "" then
		rawTitle = info.displayName;
	end;
	if type(rawTitle) ~= "string" or rawTitle == "" then
		rawTitle = info.name or "";
	end;
	local safeDisplay = originalIO.escapeRichTextText(rawTitle);
	if safeDisplay == "" and info.name and info.name ~= rawTitle then
		safeDisplay = originalIO.escapeRichTextText(info.name);
	end;
	local iconMarkup, iconGap = originalIO.resolveTabIconMarkup(info.textIcon, {
		isActive = opts.isActive,
		defaultColor = opts.defaultColor
	});
	const iconOnly = opts.iconOnly == true
		or (NAmanage and NAmanage.SettingsTabLayout and type(NAmanage.SettingsTabLayout.IsCompact) == "function" and NAmanage.SettingsTabLayout.IsCompact());
	if iconOnly then
		if iconMarkup then
			return iconMarkup;
		end;
		const fallback = tostring(rawTitle or info.name or "?"):match("^%s*(.)") or "?";
		return originalIO.escapeRichTextText(fallback);
	end;
	if iconMarkup then
		return iconMarkup .. (iconGap or " ") .. safeDisplay;
	end;
	return safeDisplay;
end;
originalIO.applyTabDisplayText = function(info, opts)
	if not info or (not info.button) then
		return;
	end;
	opts = opts or {};
	const title = info.button:FindFirstChild("Title");
	if not title then
		return;
	end;
	if title.RichText ~= true then
		title.RichText = true;
	end;
	local isActive = opts.isActive;
	if isActive == nil then
		isActive = info._isActive;
	end;
	local defaultColor = opts.defaultColor;
	if defaultColor == nil then
		defaultColor = NAUISTROKER or DEFAULT_UI_STROKE_COLOR;
	end;
	title.Text = originalIO.composeTabTitleText(info, {
		isActive = isActive,
		defaultColor = defaultColor
	});
end;
NAStuff.tabsLayout = TabManager.holder and (TabManager.holder:FindFirstChildWhichIsA("UIListLayout") or TabManager.holder:FindFirstChildWhichIsA("UIGridLayout"));
if NAStuff.tabsLayout and NAStuff.tabsLayout.SortOrder ~= Enum.SortOrder.LayoutOrder then
	pcall(function()
		NAStuff.tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	end);
end;

if TabManager.template then
	TabManager.template.Visible = false;
end;
if TabManager.defaultPage then
	local maxOrder = 0;
	for _, child in TabManager.defaultPage:GetChildren() do
		if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
			maxOrder = math.max(maxOrder, child.LayoutOrder or 0);
		end;
	end;
	TabManager.pageTemplate = TabManager.defaultPage:Clone();
	TabManager.pageTemplate.Name = "TabPageTemplate";
	TabManager.pageTemplate.CanvasPosition = Vector2.new(0, 0);
	TabManager.pageTemplate.Parent = nil;
	TabManager.fallback = {
		page = TabManager.defaultPage,
		layoutIndex = maxOrder
	};
	TabManager.fallbackIndex = maxOrder;
	TabManager.defaultPage.Visible = true;
end;
NAmanage.CustomScroll = NAmanage.CustomScroll or {};
do
	const registry = NAmanage.CustomScroll;
	registry.controllers = registry.controllers or {};
	registry._byTarget = registry._byTarget or setmetatable({}, {
		__mode = "k"
	});
	registry._targetFitBase = registry._targetFitBase or setmetatable({}, {
		__mode = "k"
	});
	registry.step = registry.step or 54;
	registry.repeatDelay = registry.repeatDelay or 0.28;
	registry.repeatRate = registry.repeatRate or 0.05;

	const function disconnectConn(conn)
		if conn and conn.Disconnect then
			pcall(function()
				conn:Disconnect();
			end);
		end;
	end;

	const function disconnectAll(conns)
		if not conns then
			return;
		end;
		for key, conn in conns do
			disconnectConn(conn);
			conns[key] = nil;
		end;
	end;

	const function isPressInput(inputType)
		return inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch;
	end;

	const function isScrollingFrame(frame)
		return frame and typeof(frame) == "Instance" and frame:IsA("ScrollingFrame");
	end;

	const function normalizeWidgets(widgets)
		if type(widgets) ~= "table" then
			return nil;
		end;
		const bar = widgets.bar or widgets[1];
		const upButton = widgets.upButton or widgets.up or widgets[2];
		const downButton = widgets.downButton or widgets.down or widgets[3];
		const track = widgets.track or widgets[4];
		const thumb = widgets.thumb or widgets[5];
		if not (bar and upButton and downButton and track and thumb) then
			return nil;
		end;
		return {
			bar = bar,
			upButton = upButton,
			downButton = downButton,
			track = track,
			thumb = thumb
		};
	end;

	function registry.getScale()
		const scaler = NAUIMANAGER and NAUIMANAGER.AUTOSCALER;
		local scale = tonumber(scaler and scaler.Scale) or 1;
		if not scale or scale <= 0 then
			scale = 1;
		end;
		return scale;
	end;

	function registry.refreshByTarget(frame)
		if not frame then
			return;
		end;
		const ctrls = registry._byTarget[frame];
		if not ctrls then
			return;
		end;
		for ctrl in ctrls do
			if ctrl and ctrl.scheduleRefresh then
				ctrl.scheduleRefresh();
			end;
		end;
	end;

	const function untrackTarget(ctrl)
		const target = ctrl and ctrl.target;
		if not target then
			return;
		end;
		const bucket = registry._byTarget[target];
		if bucket then
			bucket[ctrl] = nil;
			if next(bucket) == nil then
				registry._byTarget[target] = nil;
			end;
		end;
	end;

	const function trackTarget(ctrl, target)
		if not target then
			return;
		end;
		local bucket = registry._byTarget[target];
		if not bucket then
			bucket = {};
			registry._byTarget[target] = bucket;
		end;
		bucket[ctrl] = true;
	end;

	function registry.create(name, config)
		const ctrl = registry.controllers[name] or {};
		registry.controllers[name] = ctrl;

		ctrl.name = name;
		ctrl.config = config or ctrl.config or {};
		ctrl.axis = (ctrl.config.axis == "X" or ctrl.config.axis == "Horizontal") and "X" or "Y";
		ctrl.step = ctrl.config.step or ctrl.step or registry.step;
		ctrl.repeatDelay = ctrl.config.repeatDelay or ctrl.repeatDelay or registry.repeatDelay;
		ctrl.repeatRate = ctrl.config.repeatRate or ctrl.repeatRate or registry.repeatRate;
		ctrl._widgetConns = ctrl._widgetConns or {};
		ctrl._targetConns = ctrl._targetConns or {};
		ctrl._widgetRoot = ctrl._widgetRoot or nil;

		function ctrl.getWidgets()
			const getter = ctrl.config and ctrl.config.getWidgets;
			if not getter then
				return nil;
			end;
			local ok, widgets = pcall(getter, ctrl);
			if not ok then
				return nil;
			end;
			return normalizeWidgets(widgets);
		end;

		function ctrl.getTarget()
			if isScrollingFrame(ctrl.target) then
				return ctrl.target;
			end;
			const getter = ctrl.config and ctrl.config.getTarget;
			if getter then
				local ok, target = pcall(getter, ctrl);
				if ok and isScrollingFrame(target) then
					return target;
				end;
			end;
			return nil;
		end;

		function ctrl.isActive()
			const checker = ctrl.config and ctrl.config.isActive
			if type(checker) == "function" then
				local ok, active = pcall(checker, ctrl)
				if ok and active == false then return false end
			end
			const target = ctrl.getTarget()
			if not target then return false end
			return not NAmanage.IsGuiActuallyVisible or NAmanage.IsGuiActuallyVisible(target)
		end;

		function ctrl.getVisibleSpace(target)
			if not target then
				return 0;
			end;
			if ctrl.config and type(ctrl.config.getVisibleSpace) == "function" then
				local ok, result = pcall(ctrl.config.getVisibleSpace, ctrl, target);
				if ok and type(result) == "number" then
					return math.max(0, result);
				end;
			end;
			local logicalSize = nil;
			if target:IsA("ScrollingFrame") and NAmanage.GetLogicalWindowSize then
				logicalSize = NAmanage.GetLogicalWindowSize(target);
			elseif NAmanage.GetLogicalAbsoluteSize then
				logicalSize = NAmanage.GetLogicalAbsoluteSize(target);
			end;
			if logicalSize then
				return math.max(0, (ctrl.axis == "X" and logicalSize.X or logicalSize.Y) or 0);
			end;
			const absSize = ctrl.axis == "X" and target.AbsoluteSize.X or target.AbsoluteSize.Y;
			return math.max(0, (absSize or 0) / registry.getScale());
		end;

		function ctrl.getTotalSpace(target)
			if not target then
				return 0;
			end;
			if ctrl.config and type(ctrl.config.getTotalSpace) == "function" then
				local ok, result = pcall(ctrl.config.getTotalSpace, ctrl, target);
				if ok and type(result) == "number" then
					return math.max(0, result);
				end;
			end;
			return math.max(ctrl.getVisibleSpace(target), tonumber((ctrl.axis == "X" and target.CanvasSize.X or target.CanvasSize.Y).Offset) or 0);
		end;

		function ctrl.getPosition(target)
			if not target then
				return 0;
			end;
			if ctrl.config and type(ctrl.config.getPosition) == "function" then
				local ok, result = pcall(ctrl.config.getPosition, ctrl, target);
				if ok and type(result) == "number" then
					return result;
				end;
			end;
			if NAmanage.GetLogicalCanvasPosition then
				const logicalPos = NAmanage.GetLogicalCanvasPosition(target);
				return tonumber(ctrl.axis == "X" and logicalPos.X or logicalPos.Y) or 0;
			end
			return tonumber(ctrl.axis == "X" and target.CanvasPosition.X or target.CanvasPosition.Y) or 0;
		end;

		function ctrl.getMaxPosition(target)
			if not target then
				return 0;
			end;
			const total = ctrl.getTotalSpace(target);
			const visible = ctrl.getVisibleSpace(target);
			return math.max(0, total - visible);
		end;

		function ctrl.applyTargetDefaults(target)
			if not isScrollingFrame(target) then
				return;
			end;
			pcall(function()
				target.Active = true;
				target.ScrollBarThickness = 0;
				target.ScrollBarImageTransparency = 1;
				target.VerticalScrollBarInset = Enum.ScrollBarInset.None;
				target.HorizontalScrollBarInset = Enum.ScrollBarInset.None;
			end);
			if ctrl.config and ctrl.config.applyTargetDefaults then
				pcall(ctrl.config.applyTargetDefaults, ctrl, target);
			end;
		end;

		ctrl.applyPageDefaults = ctrl.applyTargetDefaults;

		function ctrl.fitTargetToBar(target, widgets, reserveSpace)
			if ctrl.axis == "X" or not (ctrl.config and ctrl.config.fitTargetToBar == true) then
				return false;
			end;
			const bar = widgets and widgets.bar;
			if not (target and target.Parent and bar and bar.Parent) then
				return false;
			end;
			if target.AnchorPoint and math.abs((target.AnchorPoint.X or 0)) > 0.001 then
				return false;
			end;
			local base = registry._targetFitBase[target];
			local scale = NAmanage.GetUIScaleFactor and NAmanage.GetUIScaleFactor(target.Parent) or 1;
			if not scale or scale <= 0 then
				scale = 1;
			end;
			if not base then
				const parentWidth = ((target.Parent.AbsoluteSize and target.Parent.AbsoluteSize.X) or 0) / scale;
				const targetX = (((target.AbsolutePosition and target.AbsolutePosition.X) or 0) - (((target.Parent.AbsolutePosition and target.Parent.AbsolutePosition.X) or 0))) / scale;
				const targetWidth = ((target.AbsoluteSize and target.AbsoluteSize.X) or 0) / scale;
				base = {
					size = target.Size,
					position = target.Position,
					rightReserve = math.max(0, parentWidth - targetX - targetWidth),
				};
				registry._targetFitBase[target] = base;
			end;
			const barWidth = math.max(0, (((bar.AbsoluteSize and bar.AbsoluteSize.X) or 0) / scale));
			const remove = math.floor(math.min(tonumber(base.rightReserve) or 0, barWidth + 2) + 0.5);
			local nextSize = base.size;
			if not reserveSpace and remove > 0 then
				nextSize = UDim2.new(base.size.X.Scale, base.size.X.Offset + remove, base.size.Y.Scale, base.size.Y.Offset);
			end;
			if target.Position ~= base.position then
				target.Position = base.position;
			end;
			if target.Size ~= nextSize then
				target.Size = nextSize;
				return true;
			end;
			return false;
		end;

		function ctrl.hide()
			ctrl._lastScrollMetrics = nil;
			const widgets = ctrl.getWidgets();
			if widgets and widgets.bar then
				widgets.bar.Visible = false;
			end;
		end;

		function ctrl.scheduleRefresh()
			if ctrl.isActive and not ctrl.isActive() then
				ctrl._needsRefresh = true
				ctrl.hide()
				return
			end
			if ctrl._refreshQueued then
				return;
			end;
			ctrl._refreshQueued = true;
			Defer(function()
				ctrl._refreshQueued = false;
				if registry.controllers[name] == ctrl then
					ctrl.refresh();
				end;
			end);
		end;

		function ctrl.stopArrowHold()
			if ctrl._arrowHold and ctrl._arrowHold.stop then
				ctrl._arrowHold.stop();
			end;
			ctrl._arrowHold = nil;
		end;

		function ctrl.stopThumbDrag()
			if ctrl._thumbDrag and ctrl._thumbDrag.stop then
				ctrl._thumbDrag.stop();
			end;
			ctrl._thumbDrag = nil;
		end;

		function ctrl.disconnectTarget()
			ctrl.stopArrowHold();
			ctrl.stopThumbDrag();
			untrackTarget(ctrl);
			disconnectAll(ctrl._targetConns);
			ctrl._layout = nil;
			ctrl._lastScrollMetrics = nil;
			ctrl.target = nil;
		end;

		function ctrl.refresh()
			if ctrl.isActive and not ctrl.isActive() then
				ctrl._needsRefresh = true
				ctrl.hide()
				return
			end
			ctrl._needsRefresh = false
			const widgets = ctrl.getWidgets();
			if not widgets then
				return;
			end;
			const bar = widgets.bar;
			const upButton = widgets.upButton;
			const downButton = widgets.downButton;
			const track = widgets.track;
			const thumb = widgets.thumb;
			const target = ctrl.getTarget();

			if ctrl.config and ctrl.config.layoutForTarget then
				pcall(ctrl.config.layoutForTarget, ctrl, target, widgets);
			end;

			if not (target and target.Parent and (target.Visible ~= false or (ctrl.config and ctrl.config.allowHiddenTarget == true)) and bar and bar.Parent and track and thumb) then
				ctrl.hide();
				return;
			end;

			ctrl.applyTargetDefaults(target);

			const layout = target:FindFirstChildOfClass("UIListLayout");
			if layout ~= ctrl._layout then
				disconnectConn(ctrl._targetConns.layout);
				ctrl._targetConns.layout = nil;
				ctrl._layout = layout;
				if layout then
					ctrl._targetConns.layout = layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
						updateCanvasSize(target, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
						ctrl.scheduleRefresh();
					end);
				end;
			end;

			local visible = ctrl.getVisibleSpace(target);
			local total = math.max(visible, ctrl.getTotalSpace(target));
			local maxPos = math.max(0, total - visible);
			local trackSize = math.max(0, ctrl.axis == "X" and (track.AbsoluteSize.X or 0) or (track.AbsoluteSize.Y or 0));
			local canScroll = maxPos > 1 and visible > 0 and trackSize > 0;
			if canScroll and ctrl.fitTargetToBar(target, widgets, true) then
				if updateCanvasSize then
					pcall(updateCanvasSize, target, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
				end;
				if ctrl.config and ctrl.config.layoutForTarget then
					pcall(ctrl.config.layoutForTarget, ctrl, target, widgets);
				end;
				visible = ctrl.getVisibleSpace(target);
				total = math.max(visible, ctrl.getTotalSpace(target));
				maxPos = math.max(0, total - visible);
				trackSize = math.max(0, ctrl.axis == "X" and (track.AbsoluteSize.X or 0) or (track.AbsoluteSize.Y or 0));
				canScroll = maxPos > 1 and visible > 0 and trackSize > 0;
			end;
			if not canScroll and ctrl.fitTargetToBar(target, widgets, false) then
				if updateCanvasSize then
					pcall(updateCanvasSize, target, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
				end;
				visible = ctrl.getVisibleSpace(target);
				total = math.max(visible, ctrl.getTotalSpace(target));
				maxPos = math.max(0, total - visible);
				trackSize = math.max(0, ctrl.axis == "X" and (track.AbsoluteSize.X or 0) or (track.AbsoluteSize.Y or 0));
				canScroll = maxPos > 1 and visible > 0 and trackSize > 0;
				if canScroll and ctrl.fitTargetToBar(target, widgets, true) then
					if updateCanvasSize then
						pcall(updateCanvasSize, target, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
					end;
					visible = ctrl.getVisibleSpace(target);
					total = math.max(visible, ctrl.getTotalSpace(target));
					maxPos = math.max(0, total - visible);
					trackSize = math.max(0, ctrl.axis == "X" and (track.AbsoluteSize.X or 0) or (track.AbsoluteSize.Y or 0));
					canScroll = maxPos > 1 and visible > 0 and trackSize > 0;
				end;
			end;
			bar.Visible = canScroll;
			if not canScroll then
				return;
			end;

			ctrl._lastScrollMetrics = {
				visible = visible,
				total = total,
				maxPos = maxPos,
				trackSize = trackSize
			};
			ctrl.updateThumb(widgets, target, visible, total, maxPos, trackSize);
		end;

		function ctrl.updateThumb(widgets, target, visible, total, maxPos, trackSize)
			widgets = widgets or ctrl.getWidgets();
			target = target or ctrl.getTarget();
			if not widgets or not target then
				return false;
			end;
			const upButton = widgets.upButton;
			const downButton = widgets.downButton;
			const track = widgets.track;
			const thumb = widgets.thumb;
			if not (upButton and downButton and track and thumb) then
				return false;
			end;
			visible = tonumber(visible) or ctrl.getVisibleSpace(target);
			total = tonumber(total) or math.max(visible, ctrl.getTotalSpace(target));
			maxPos = tonumber(maxPos) or math.max(0, total - visible);
			trackSize = tonumber(trackSize) or math.max(0, ctrl.axis == "X" and (track.AbsoluteSize.X or 0) or (track.AbsoluteSize.Y or 0));
			if maxPos <= 1 or visible <= 0 or trackSize <= 0 then
				return false;
			end;
			const currentPos = math.clamp(tonumber(ctrl.getPosition(target)) or 0, 0, maxPos);
			const upEnabled = currentPos > 0.5;
			const downEnabled = currentPos < (maxPos - 0.5);
			upButton.BackgroundTransparency = upEnabled and 0.15 or 0.55;
			downButton.BackgroundTransparency = downEnabled and 0.15 or 0.55;
			upButton.TextTransparency = upEnabled and 0 or 0.5;
			downButton.TextTransparency = downEnabled and 0 or 0.5;

			const minThumb = tonumber(ctrl.config.minThumb) or (IsOnMobile and 28 or 18);
				local thumbMainSize = trackSize;
				if total > 0 then
					const maxThumb = math.max(1, trackSize);
					const minSafe = math.min(math.max(1, minThumb), maxThumb);
					const rawThumb = trackSize * (visible / total);
					thumbMainSize = math.floor(math.clamp(rawThumb, minSafe, maxThumb) + 0.5);
				end;
			const travel = math.max(0, trackSize - thumbMainSize);
			const percent = maxPos > 0 and (currentPos / maxPos) or 0;
			if ctrl.axis == "X" then
				thumb.Size = UDim2.new(0, thumbMainSize, 1, 0);
				thumb.Position = UDim2.new(0, math.floor(travel * percent + 0.5), 0, 0);
			else
				thumb.Size = UDim2.new(1, 0, 0, thumbMainSize);
				thumb.Position = UDim2.new(0, 0, 0, math.floor(travel * percent + 0.5));
			end;
			return true;
		end;

		function ctrl.refreshPosition()
			if ctrl.isActive and not ctrl.isActive() then
				ctrl.hide();
				return;
			end;
			const widgets = ctrl.getWidgets();
			const target = ctrl.getTarget();
			if not (widgets and target and widgets.bar and widgets.bar.Visible == true) then
				return;
			end;
			const metrics = ctrl._lastScrollMetrics;
			if metrics and ctrl.updateThumb(widgets, target, metrics.visible, metrics.total, metrics.maxPos, metrics.trackSize) then
				return;
			end;
			ctrl.updateThumb(widgets, target);
		end;

		function ctrl.scrollTo(pos)
			const target = ctrl.getTarget();
			if not target then
				ctrl.hide();
				return;
			end;
			const maxPos = ctrl.getMaxPosition(target);
			const nextPos = math.clamp(tonumber(pos) or 0, 0, maxPos);
			if ctrl.config and type(ctrl.config.setPosition) == "function" then
				pcall(ctrl.config.setPosition, ctrl, target, nextPos);
				ctrl.refreshPosition();
				return;
			end;
			if NAmanage.GetLogicalCanvasPosition and NAmanage.SetLogicalCanvasPosition then
				const logicalPos = NAmanage.GetLogicalCanvasPosition(target);
				const currentX = tonumber(logicalPos.X) or 0;
				const currentY = tonumber(logicalPos.Y) or 0;
				if ctrl.axis == "X" then
					NAmanage.SetLogicalCanvasPosition(target, nextPos, currentY);
				else
					NAmanage.SetLogicalCanvasPosition(target, currentX, nextPos);
				end
			else
				const currentX = tonumber(target.CanvasPosition.X) or 0;
				const currentY = tonumber(target.CanvasPosition.Y) or 0;
				target.CanvasPosition = ctrl.axis == "X" and Vector2.new(nextPos, currentY) or Vector2.new(currentX, nextPos);
			end
			ctrl.refreshPosition();
		end;

		function ctrl.scrollBy(delta)
			const target = ctrl.getTarget();
			if not target then
				ctrl.hide();
				return;
			end;
			const current = ctrl.getPosition(target);
			ctrl.scrollTo((tonumber(current) or 0) + (tonumber(delta) or 0));
		end;

		function ctrl.pageStep(direction)
			const target = ctrl.getTarget();
			if not target then
				ctrl.hide();
				return;
			end;
			const amount = math.max(24, ctrl.getVisibleSpace(target) - 24);
			ctrl.scrollBy((direction or 1) < 0 and -amount or amount);
		end;

		function ctrl.setTarget(target)
			if not isScrollingFrame(target) then
				target = nil;
			end;
			if ctrl.target == target then
				ctrl.scheduleRefresh();
				return target;
			end;

			ctrl.disconnectTarget();
			ctrl.target = target;
			if not target then
				ctrl.hide();
				return nil;
			end;

			trackTarget(ctrl, target);
			ctrl.applyTargetDefaults(target);
			ctrl._targetConns.canvasPos = target:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				ctrl.refreshPosition();
			end);
			ctrl._targetConns.canvasSize = target:GetPropertyChangedSignal("CanvasSize"):Connect(function()
				ctrl.scheduleRefresh();
			end);
			ctrl._targetConns.absSize = target:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				ctrl.scheduleRefresh();
			end);
			ctrl._targetConns.ancestry = target.AncestryChanged:Connect(function(_, parent)
				if not parent then
					ctrl.setTarget(nil);
				else
					ctrl.scheduleRefresh();
				end;
			end);
			if target.Destroying then
				ctrl._targetConns.destroying = target.Destroying:Connect(function()
					ctrl.setTarget(nil);
				end);
			end;

			ctrl.scheduleRefresh();
			return target;
		end;

		function ctrl.install()
			const widgets = ctrl.getWidgets();
			if not widgets then
				return nil;
			end;
			const bar = widgets.bar;
			const upButton = widgets.upButton;
			const downButton = widgets.downButton;
			const track = widgets.track;
			const thumb = widgets.thumb;
			if ctrl._widgetRoot ~= bar then
				ctrl.stopArrowHold();
				ctrl.stopThumbDrag();
				disconnectAll(ctrl._widgetConns);
				ctrl._widgetRoot = bar;

				const function startArrowHold(delta, input)
					if not input or not isPressInput(input.UserInputType) then
						return;
					end;
					ctrl.stopThumbDrag();
					ctrl.stopArrowHold();

					local active = true;
					const pointer = input.UserInputType == Enum.UserInputType.Touch and input or nil;
					local touchLocked = false;
					local endConn;
					const touchMode = ctrl.name .. "-scroll-arrow";

					if pointer and NAgui.tryLockTouchGesture and not NAgui.tryLockTouchGesture(bar, touchMode, pointer) then
						return;
					end;
					touchLocked = pointer ~= nil;

					const function stop()
						if not active then
							return;
						end;
						active = false;
						if touchLocked and NAgui.releaseTouchGesture then
							NAgui.releaseTouchGesture(bar, touchMode, pointer);
						end;
						disconnectConn(endConn);
						if ctrl._arrowHold and ctrl._arrowHold.stop == stop then
							ctrl._arrowHold = nil;
						end;
						ctrl.scheduleRefresh();
					end;

					ctrl._arrowHold = {
						stop = stop
					};
					ctrl.scrollBy(delta);
					endConn = Services.UserInputService.InputEnded:Connect(function(endedInput)
						if endedInput.UserInputType == Enum.UserInputType.MouseButton1
							or (endedInput.UserInputType == Enum.UserInputType.Touch and endedInput == pointer) then
							stop();
						end;
					end);

					Spawn(function()
						const startedAt = tick();
						while active do
							if tick() - startedAt >= ctrl.repeatDelay then
								ctrl.scrollBy(delta);
								Wait(ctrl.repeatRate);
							else
								Wait(0.03);
							end;
						end
					end);
				end;

				ctrl._widgetConns.up = upButton.InputBegan:Connect(function(input)
					startArrowHold(-(ctrl.step or registry.step), input);
				end);
				ctrl._widgetConns.down = downButton.InputBegan:Connect(function(input)
					startArrowHold(ctrl.step or registry.step, input);
				end);
				ctrl._widgetConns.track = track.InputBegan:Connect(function(input)
					if not input or not isPressInput(input.UserInputType) then
						return;
					end;
					const pointerPos = input.Position and (ctrl.axis == "X" and input.Position.X or input.Position.Y);
					if not pointerPos then
						return;
					end;
					const thumbStart = ctrl.axis == "X" and thumb.AbsolutePosition.X or thumb.AbsolutePosition.Y;
					const thumbEnd = thumbStart + (ctrl.axis == "X" and thumb.AbsoluteSize.X or thumb.AbsoluteSize.Y);
					if pointerPos >= thumbStart and pointerPos <= thumbEnd then
						return;
					end;
					ctrl.stopArrowHold();
					ctrl.stopThumbDrag();
					if pointerPos < thumbStart then
						ctrl.pageStep(-1);
					else
						ctrl.pageStep(1);
					end;
				end);
				ctrl._widgetConns.thumb = thumb.InputBegan:Connect(function(input)
					if not input or not isPressInput(input.UserInputType) then
						return;
					end;
					ctrl.stopArrowHold();
					ctrl.stopThumbDrag();

					local active = true;
					const pointer = input.UserInputType == Enum.UserInputType.Touch and input or nil;
					local touchLocked = false;
					local moveConn;
					local endConn;
					const offset = input.Position and ((ctrl.axis == "X" and input.Position.X or input.Position.Y) - (ctrl.axis == "X" and thumb.AbsolutePosition.X or thumb.AbsolutePosition.Y)) or 0;
					const touchMode = ctrl.name .. "-scroll-thumb";

					if pointer and NAgui.tryLockTouchGesture and not NAgui.tryLockTouchGesture(bar, touchMode, pointer) then
						return;
					end;
					touchLocked = pointer ~= nil;

					const function stop()
						if not active then
							return;
						end;
						active = false;
						if touchLocked and NAgui.releaseTouchGesture then
							NAgui.releaseTouchGesture(bar, touchMode, pointer);
						end;
						disconnectConn(moveConn);
						disconnectConn(endConn);
						if ctrl._thumbDrag and ctrl._thumbDrag.stop == stop then
							ctrl._thumbDrag = nil;
						end;
						ctrl.scheduleRefresh();
					end;

					ctrl._thumbDrag = {
						stop = stop
					};
					moveConn = Services.UserInputService.InputChanged:Connect(function(changedInput)
						if not active then
							return;
						end;
						const inputType = changedInput.UserInputType;
						if inputType ~= Enum.UserInputType.MouseMovement
							and not (inputType == Enum.UserInputType.Touch and changedInput == pointer) then
							return;
						end;
						const target = ctrl.getTarget();
						if not target then
							stop();
							return;
						end;
						const trackMain = ctrl.axis == "X" and track.AbsoluteSize.X or track.AbsoluteSize.Y;
						const thumbMain = ctrl.axis == "X" and thumb.AbsoluteSize.X or thumb.AbsoluteSize.Y;
						const trackTravel = math.max(0, trackMain - thumbMain);
						const inputPos = ctrl.axis == "X" and changedInput.Position.X or changedInput.Position.Y;
						const trackPos = ctrl.axis == "X" and track.AbsolutePosition.X or track.AbsolutePosition.Y;
						const rawPos = inputPos - trackPos - offset;
						const thumbPos = math.clamp(rawPos, 0, trackTravel);
						const percent = trackTravel > 0 and (thumbPos / trackTravel) or 0;
						ctrl.scrollTo(percent * ctrl.getMaxPosition(target));
					end);
					endConn = Services.UserInputService.InputEnded:Connect(function(endedInput)
						if endedInput.UserInputType == Enum.UserInputType.MouseButton1
							or (endedInput.UserInputType == Enum.UserInputType.Touch and endedInput == pointer) then
							stop();
						end;
					end);
				end);
				ctrl._widgetConns.ancestry = bar.AncestryChanged:Connect(function(_, parent)
					if not parent then
						ctrl.stopArrowHold();
						ctrl.stopThumbDrag();
						disconnectAll(ctrl._widgetConns);
						ctrl._widgetRoot = nil;
					else
						ctrl.scheduleRefresh();
					end;
				end);
			end;

			ctrl._installed = true;
			ctrl.setTarget(ctrl.getTarget());
			return ctrl;
		end;

		return ctrl;
	end;

	function registry.refreshAll()
		for _, ctrl in registry.controllers do
			if ctrl and ctrl.install and ctrl._installed ~= true then
				pcall(ctrl.install)
			elseif ctrl and ctrl.scheduleRefresh then
				pcall(ctrl.scheduleRefresh)
			end
		end
	end

	const function settingsWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.SettingsCustomScrollBar,
			upButton = mgr.SettingsCustomScrollUp,
			downButton = mgr.SettingsCustomScrollDown,
			track = mgr.SettingsCustomScrollTrack,
			thumb = mgr.SettingsCustomScrollThumb
		};
	end;

	const function chatWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.ChatCustomScrollBar,
			upButton = mgr.ChatCustomScrollUp,
			downButton = mgr.ChatCustomScrollDown,
			track = mgr.ChatCustomScrollTrack,
			thumb = mgr.ChatCustomScrollThumb
		};
	end;

	const function commandsWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.CommandsCustomScrollBar,
			upButton = mgr.CommandsCustomScrollUp,
			downButton = mgr.CommandsCustomScrollDown,
			track = mgr.CommandsCustomScrollTrack,
			thumb = mgr.CommandsCustomScrollThumb
		};
	end;

	const function commandKeybindWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.CommandKeybindsCustomScrollBar,
			upButton = mgr.CommandKeybindsCustomScrollUp,
			downButton = mgr.CommandKeybindsCustomScrollDown,
			track = mgr.CommandKeybindsCustomScrollTrack,
			thumb = mgr.CommandKeybindsCustomScrollThumb
		};
	end;

	const function waypointWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.WaypointCustomScrollBar,
			upButton = mgr.WaypointCustomScrollUp,
			downButton = mgr.WaypointCustomScrollDown,
			track = mgr.WaypointCustomScrollTrack,
			thumb = mgr.WaypointCustomScrollThumb
		};
	end;

	const function bindersWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.BindersCustomScrollBar,
			upButton = mgr.BindersCustomScrollUp,
			downButton = mgr.BindersCustomScrollDown,
			track = mgr.BindersCustomScrollTrack,
			thumb = mgr.BindersCustomScrollThumb
		};
	end;

	const function consoleWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.ConsoleCustomScrollBar,
			upButton = mgr.ConsoleCustomScrollUp,
			downButton = mgr.ConsoleCustomScrollDown,
			track = mgr.ConsoleCustomScrollTrack,
			thumb = mgr.ConsoleCustomScrollThumb
		};
	end;

	const function scriptHubWidgets()
		const container = NAUIMANAGER and NAUIMANAGER.ScriptHubContainer
		const bar = container and container:FindFirstChild("CustomScrollBar")
		const track = bar and bar:FindFirstChild("Track")
		if not (bar and track) then
			return nil
		end
		return {
			bar = bar,
			upButton = bar:FindFirstChild("Up"),
			downButton = bar:FindFirstChild("Down"),
			track = track,
			thumb = track:FindFirstChild("Thumb")
		}
	end

	const function subplaceViewerWidgets()
		const container = NAUIMANAGER and NAUIMANAGER.SubplaceViewerContainer
		const bar = container and container:FindFirstChild("CustomScrollBar")
		const track = bar and bar:FindFirstChild("Track")
		if not (bar and track) then
			return nil
		end
		return {
			bar = bar,
			upButton = bar:FindFirstChild("Up"),
			downButton = bar:FindFirstChild("Down"),
			track = track,
			thumb = track:FindFirstChild("Thumb")
		}
	end

	const function serverListWidgets()
		const container = NAUIMANAGER and NAUIMANAGER.ServerListContainer
		const bar = container and container:FindFirstChild("CustomScrollBar")
		const track = bar and bar:FindFirstChild("Track")
		if not (bar and track) then
			return nil
		end
		return {
			bar = bar,
			upButton = bar:FindFirstChild("Up"),
			downButton = bar:FindFirstChild("Down"),
			track = track,
			thumb = track:FindFirstChild("Thumb")
		}
	end

	const function pluginsWidgets(axis)
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		if axis == "X" then
			return {
				bar = mgr.PluginsCustomHorizontalScrollBar,
				upButton = mgr.PluginsCustomScrollLeft,
				downButton = mgr.PluginsCustomScrollRight,
				track = mgr.PluginsCustomHorizontalScrollTrack,
				thumb = mgr.PluginsCustomHorizontalScrollThumb
			};
		end;
		return {
			bar = mgr.PluginsCustomScrollBar,
			upButton = mgr.PluginsCustomScrollUp,
			downButton = mgr.PluginsCustomScrollDown,
			track = mgr.PluginsCustomScrollTrack,
			thumb = mgr.PluginsCustomScrollThumb
		};
	end;

	const function alignBarToTarget(_, target, widgets)
		const bar = widgets and widgets.bar;
		if not (target and bar and bar.Parent and target.Parent == bar.Parent) then
			return;
		end;
		local scale = NAmanage.GetUIScaleFactor and NAmanage.GetUIScaleFactor(bar.Parent) or 1;
		if not scale or scale <= 0 then
			scale = 1;
		end;
		const parentY = bar.Parent.AbsolutePosition and bar.Parent.AbsolutePosition.Y or 0;
		const offsetY = math.floor(((((target.AbsolutePosition and target.AbsolutePosition.Y) or parentY) - parentY) / scale) + 0.5);
		const height = math.max(0, math.floor((((target.AbsoluteSize and target.AbsoluteSize.Y) or 0) / scale) + 0.5));
		bar.Position = UDim2.new(bar.Position.X.Scale, bar.Position.X.Offset, 0, offsetY);
		bar.Size = UDim2.new(bar.Size.X.Scale, bar.Size.X.Offset, 0, height);
	end;

	const function alignHorizontalBarToTarget(_, target, widgets)
		const bar = widgets and widgets.bar;
		if not (target and bar and bar.Parent and target.Parent == bar.Parent) then
			return;
		end;
		bar.Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset, bar.Position.Y.Scale, bar.Position.Y.Offset);
		bar.Size = UDim2.new(target.Size.X.Scale, target.Size.X.Offset, bar.Size.Y.Scale, bar.Size.Y.Offset);
	end;

	NAmanage.SettingsScroll = registry.create("settings", {
		getWidgets = settingsWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.SettingsList or nil;
		end,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("SettingsFrame")
		end
	});

	NAmanage.ChatScroll = registry.create("chat", {
		getWidgets = chatWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.chatLogs or nil;
		end,
		layoutForTarget = alignBarToTarget,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("chatLogsFrame")
		end
	});

	const function naChatMessageWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.NAchatMessageCustomScrollBar,
			upButton = mgr.NAchatMessageCustomScrollUp,
			downButton = mgr.NAchatMessageCustomScrollDown,
			track = mgr.NAchatMessageCustomScrollTrack,
			thumb = mgr.NAchatMessageCustomScrollThumb
		};
	end;

	const function naChatUsersWidgets()
		const mgr = NAUIMANAGER;
		if not mgr then
			return nil;
		end;
		return {
			bar = mgr.NAchatUsersCustomScrollBar,
			upButton = mgr.NAchatUsersCustomScrollUp,
			downButton = mgr.NAchatUsersCustomScrollDown,
			track = mgr.NAchatUsersCustomScrollTrack,
			thumb = mgr.NAchatUsersCustomScrollThumb
		};
	end;

	NAmanage.NAChatMessagesScroll = registry.create("na_chat_messages", {
		getWidgets = naChatMessageWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.NAchatChatScroll or nil;
		end,
		layoutForTarget = alignBarToTarget,
		isActive = function()
			const frame = NAUIMANAGER and NAUIMANAGER.NAchatFrame;
			return frame and frame.Visible == true;
		end
	});

	NAmanage.NAChatUsersScroll = registry.create("na_chat_users", {
		getWidgets = naChatUsersWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.NAchatUsersScroll or nil;
		end,
		layoutForTarget = alignBarToTarget,
		isActive = function()
			const frame = NAUIMANAGER and NAUIMANAGER.NAchatFrame;
			return frame and frame.Visible == true;
		end
	});

	NAmanage.CommandsScroll = registry.create("commands", {
		getWidgets = commandsWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.commandsList or nil;
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("commandsFrame")
		end
	});

	NAmanage.CommandKeybindsScroll = registry.create("command_keybinds", {
		getWidgets = commandKeybindWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.CommandKeybindsList or nil;
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("CommandKeybindsFrame")
		end
	});

	NAmanage.WaypointScroll = registry.create("waypoints", {
		getWidgets = waypointWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.WaypointList or nil;
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("WaypointFrame")
		end
	});

	NAmanage.BindersScroll = registry.create("binders", {
		getWidgets = bindersWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.BindersList or nil;
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("BindersFrame")
		end
	});

	NAmanage.ConsoleScroll = registry.create("console", {
		getWidgets = consoleWidgets,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.NAconsoleLogs or nil;
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("NAconsoleFrame")
		end
	});

	NAmanage.ScriptHubScroll = registry.create("script_hub", {
		getWidgets = scriptHubWidgets,
		getTarget = function()
			const container = NAUIMANAGER and NAUIMANAGER.ScriptHubContainer
			return container and container:FindFirstChild("Results") or nil
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("ScriptHubFrame")
		end
	})

	NAmanage.SubplaceViewerScroll = registry.create("subplace_viewer", {
		getWidgets = subplaceViewerWidgets,
		getTarget = function()
			const container = NAUIMANAGER and NAUIMANAGER.SubplaceViewerContainer
			return container and container:FindFirstChild("List") or nil
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("SubplaceViewerFrame")
		end
	})

	NAmanage.ServerListScroll = registry.create("server_list", {
		getWidgets = serverListWidgets,
		getTarget = function()
			const container = NAUIMANAGER and NAUIMANAGER.ServerListContainer
			return container and container:FindFirstChild("List") or nil
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("ServerListFrame")
		end
	})

	NAmanage.PluginsScroll = registry.create("plugins_v", {
		getWidgets = function()
			return pluginsWidgets("Y");
		end,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.PluginsList or nil;
		end,
		layoutForTarget = alignBarToTarget,
		fitTargetToBar = true,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("PluginsFrame")
		end
	});

	NAmanage.PluginsHorizontalScroll = registry.create("plugins_h", {
		axis = "X",
		getWidgets = function()
			return pluginsWidgets("X");
		end,
		getTarget = function()
			return NAUIMANAGER and NAUIMANAGER.PluginsList or nil;
		end,
		layoutForTarget = alignHorizontalBarToTarget,
		isActive = function()
			return NAmanage.IsUIWindowVisible and NAmanage.IsUIWindowVisible("PluginsFrame")
		end,
		step = 96
	});
end;
if NAmanage.SettingsScroll and NAmanage.SettingsScroll.install then
	NAmanage.SettingsScroll.install();
end;
if NAmanage.ChatScroll and NAmanage.ChatScroll.install then
	NAmanage.ChatScroll.install();
end;
if NAmanage.NAChatMessagesScroll and NAmanage.NAChatMessagesScroll.install then
	NAmanage.NAChatMessagesScroll.install();
end;
if NAmanage.NAChatUsersScroll and NAmanage.NAChatUsersScroll.install then
	NAmanage.NAChatUsersScroll.install();
end;
if NAmanage.CommandsScroll and NAmanage.CommandsScroll.install then
	NAmanage.CommandsScroll.install();
end;
if NAmanage.CommandKeybindsScroll and NAmanage.CommandKeybindsScroll.install then
	NAmanage.CommandKeybindsScroll.install();
end;
if NAmanage.WaypointScroll and NAmanage.WaypointScroll.install then
	NAmanage.WaypointScroll.install();
end;
if NAmanage.BindersScroll and NAmanage.BindersScroll.install then
	NAmanage.BindersScroll.install();
end;
if NAmanage.ConsoleScroll and NAmanage.ConsoleScroll.install then
	NAmanage.ConsoleScroll.install();
end;
if NAmanage.ScriptHubScroll and NAmanage.ScriptHubScroll.install then
	NAmanage.ScriptHubScroll.install();
end;
if NAmanage.SubplaceViewerScroll and NAmanage.SubplaceViewerScroll.install then
	NAmanage.SubplaceViewerScroll.install();
end;
if NAmanage.PluginsScroll and NAmanage.PluginsScroll.install then
	NAmanage.PluginsScroll.install();
end;
if NAmanage.PluginsHorizontalScroll and NAmanage.PluginsHorizontalScroll.install then
	NAmanage.PluginsHorizontalScroll.install();
end;
NAStuff.settingsAllDirty = true;
NAmanage.markAllTabDirty = function(tabName)
	if not tabName or not NA_TABS or tabName == NA_TABS.TAB_ALL then
		return;
	end;
	NAStuff.settingsAllDirty = true;
	const info = TabManager.tabs and TabManager.tabs[tabName];
	if info then
		info.elementsDirty = true;
	end;
end;
NAmanage.getAllTabWrapper = function(page, createIfMissing)
	if not page then
		return nil;
	end;
	local found = nil;
	for _, child in page:GetChildren() do
		if child:IsA("GuiObject") and NAmanage.GetAttr(child, "NAAllWrapper") then
			if not found then
				found = child;
			else
				child:Destroy();
			end;
		end;
	end;
	if found or not createIfMissing then
		return found;
	end;
	const merged = InstanceNew("Frame");
	merged.Name = "NAAllMerged";
	merged.BackgroundTransparency = 1;
	merged.Size = UDim2.new(1, 0, 0, 0);
	merged.AutomaticSize = Enum.AutomaticSize.Y;
	merged.LayoutOrder = -1;
	NAmanage.SetAttr(merged, "NAAllWrapper", true);
	merged.Parent = page;

	const ml = InstanceNew("UIListLayout");
	ml.FillDirection = Enum.FillDirection.Vertical;
	ml.SortOrder = Enum.SortOrder.LayoutOrder;
	ml.Padding = UDim.new(0, 6);
	ml.Parent = merged;
	return merged;
end;
NAmanage.registerElementForCurrentTab = function(instance, targetTabName)
	if not instance then
		return;
	end;
	const currentName = targetTabName or (NAgui.getSettingsTabContext and NAgui.getSettingsTabContext()) or TabManager.current;
	if not currentName or NA_TABS.TAB_ALL and currentName == NA_TABS.TAB_ALL then
		return;
	end;
	if not NAStuff.elementOriginalParent[instance] then
		NAStuff.elementOriginalParent[instance] = instance.Parent;
	end;
	pcall(function()
		NAmanage.SetAttr(instance, "NAOriginalTab", currentName);
	end);
	const info = TabManager.tabs and TabManager.tabs[currentName];
	if info then
		info.elements = info.elements or {};
		Insert(info.elements, instance);
		info.elementsDirty = true;
	end;
	NAmanage.markAllTabDirty(currentName);
end;
NAmanage.clearAllTabWrappers = function(page)
	if not page then
		return;
	end;
	for _, child in page:GetChildren() do
		if child:IsA("GuiObject") and NAmanage.GetAttr(child, "NAAllWrapper") then
			for _, element in child:GetChildren() do
				if element:IsA("GuiObject") then
					local originalParent = NAStuff.elementOriginalParent[element];
					if not originalParent then
						const originalTab = NAmanage.GetAttr(element, "NAOriginalTab");
						if originalTab and TabManager.tabs then
							const info = TabManager.tabs[originalTab];
							originalParent = info and info.page;
						end;
					end;
					originalParent = originalParent or page;
					const origOrder = NAmanage.GetAttr(element, "NAOrigOrder");
					if typeof(origOrder) == "number" then
						element.LayoutOrder = origOrder;
					end;
					if element.Parent ~= originalParent then
						element.Parent = originalParent;
					end;
				end;
			end;
			child:Destroy();
		end;
	end;
end;
NAmanage.restoreAllTabElements = function()
	const allInfo = TabManager.tabs and NA_TABS.TAB_ALL and TabManager.tabs[NA_TABS.TAB_ALL] or nil;
	if allInfo and allInfo.page then
		NAmanage.clearAllTabWrappers(allInfo.page);
	end;
end;
NAmanage.collectTabElements = function(tabInfo, tabName)
	const cached = tabInfo and tabInfo.elements;
	if type(cached) == "table" and #cached > 0 and not tabInfo.elementsDirty then
		const valid = {};
		for _, element in cached do
			if typeof(element) == "Instance" and element.Parent and element:IsA("GuiObject") then
				Insert(valid, element);
			end;
		end;
		table.sort(valid, function(a, b)
			return (a.LayoutOrder or 0) < (b.LayoutOrder or 0);
		end);
		tabInfo.elements = valid;
		return valid;
	end;
	const elements = {};
	if not tabInfo or (not tabInfo.page) then
		return elements;
	end;
	for _, child in tabInfo.page:GetChildren() do
		if child:IsA("GuiObject") and (not NAmanage.GetAttr(child, "NAAllWrapper")) and (not child:IsA("UIListLayout")) and (not child:IsA("UIPadding")) and (not child:IsA("UIPageLayout")) then
			Insert(elements, child);
		end;
	end;
	table.sort(elements, function(a, b)
		return (a.LayoutOrder or 0) < (b.LayoutOrder or 0);
	end);
	tabInfo.elements = elements;
	for _, element in elements do
		if not NAStuff.elementOriginalParent[element] then
			NAStuff.elementOriginalParent[element] = tabInfo.page;
		end;
		pcall(function()
			NAmanage.SetAttr(element, "NAOriginalTab", tabName);
		end);
	end;
	tabInfo.elementsDirty = false;
	return elements;
end;
NAmanage.mountTabElements = function(tabInfo, tabName)
	if not tabInfo or (not tabInfo.page) then
		return 0;
	end;
	local moved = 0;
	const elements = NAmanage.collectTabElements(tabInfo, tabName);
	for index, element in elements do
		if element and element.Parent and element.Parent ~= tabInfo.page then
			const origOrder = NAmanage.GetAttr(element, "NAOrigOrder");
			if typeof(origOrder) == "number" then
				element.LayoutOrder = origOrder;
			end;
			element.Parent = tabInfo.page;
			moved += 1;
		end;
		if NAgui.SettingsBuildStep and index % 4 == 0 then
			NAgui.SettingsBuildStep("mount");
		end;
	end;
	return moved;
end;
NAmanage.prepareAllTabDisplay = function(allInfo)
	if not allInfo or (not allInfo.page) then
		return;
	end;
	const page = allInfo.page;
	local layout = page:FindFirstChildWhichIsA("UIListLayout");
	if not layout then
		layout = InstanceNew("UIListLayout");
		layout.FillDirection = Enum.FillDirection.Vertical;
		layout.SortOrder = Enum.SortOrder.LayoutOrder;
		layout.Padding = UDim.new(0, 10);
		layout.Parent = page;
	else
		layout.SortOrder = Enum.SortOrder.LayoutOrder;
	end;
	if page:IsA("ScrollingFrame") then
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y;
		page.CanvasPosition = Vector2.new(0, 0);
	end;
	const merged = NAmanage.getAllTabWrapper(page, true);
	if merged and not NAStuff.settingsAllDirty then
		return;
	end;
	local cursor = 0;
	for _, tabName in TabManager.order do
		if tabName ~= NA_TABS.TAB_ALL then
			const tabInfo = TabManager.tabs[tabName];
			if tabInfo then
				const elements = NAmanage.collectTabElements(tabInfo, tabName);
				for index, element in elements do
					if NAmanage.GetAttr(element, "NAHideInAll") == true then
						continue;
					end;
					if NAmanage.GetAttr(element, "NAOrigOrder") == nil then
						NAmanage.SetAttr(element, "NAOrigOrder", element.LayoutOrder or 0);
					end;
					element.LayoutOrder = cursor;
					cursor += 1;
					if element.Parent ~= merged then
						element.Parent = merged;
					end;
					if NAgui.SettingsBuildStep and index % 4 == 0 then
						NAgui.SettingsBuildStep("mount");
					end;
				end;
			end;
		end;
	end;
	NAStuff.settingsAllDirty = false;
	if page:IsA("ScrollingFrame") then
		updateCanvasSize(page, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
	end;
end;
NAmanage.updateTabVisual = function(tabInfo, isActive)
	if not tabInfo then
		return;
	end;
	tabInfo._isActive = isActive and true or false;
	if not tabInfo.button then
		return;
	end;
	const btn = tabInfo.button;
	btn.BackgroundTransparency = isActive and 0.1 or 0.25;
	const stroke = btn:FindFirstChildWhichIsA("UIStroke", true);
	if stroke then
		NAgui.RegisterColoredStroke(stroke);
		const computeColor = NAmanage.getTabStrokeColor;
		if typeof(computeColor) == "function" then
			stroke.Color = computeColor(isActive);
		else
			stroke.Color = NAUISTROKER or DEFAULT_UI_STROKE_COLOR;
		end;
	end;
	const title = btn:FindFirstChild("Title");
	if title then
		if originalIO.applyTabDisplayText then
			originalIO.applyTabDisplayText(tabInfo, {
				isActive = isActive,
				defaultColor = NAUISTROKER or DEFAULT_UI_STROKE_COLOR
			});
		end;
		title.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(234, 234, 244);
	end;
end;
NAgui.getActiveTab = function()
	return TabManager.current;
end;

NAgui._settingsTabContexts = NAgui._settingsTabContexts or setmetatable({}, { __mode = "k" })
NAgui._settingsMainContextKey = NAgui._settingsMainContextKey or {}
NAgui.getSettingsThreadKey = function()
	return coroutine.running() or NAgui._settingsMainContextKey
end
NAgui.getSettingsTabContext = function()
	const contexts = NAgui._settingsTabContexts
	if type(contexts) ~= "table" then
		return nil
	end
	return contexts[NAgui.getSettingsThreadKey()]
end
NAgui.setSettingsTabContext = function(tabName)
	const contexts = NAgui._settingsTabContexts
	if type(contexts) ~= "table" then
		return
	end
	const key = NAgui.getSettingsThreadKey()
	if tabName == nil then
		contexts[key] = nil
	else
		contexts[key] = tabName
	end
end
NAgui.withSettingsTabContext = function(tabName, callback)
	if type(callback) ~= "function" then
		return nil
	end
	const key = NAgui.getSettingsThreadKey()
	const contexts = NAgui._settingsTabContexts
	const previous = contexts[key]
	contexts[key] = tabName
	const results = table.pack(pcall(callback))
	if previous == nil then
		contexts[key] = nil
	else
		contexts[key] = previous
	end
	if not results[1] then
		error(results[2], 0)
	end
	return Unpack(results, 2, results.n)
end

NAmanage.ClearSettingsTabPage = NAmanage.ClearSettingsTabPage or function(tabName)
	const info = tabName and TabManager and TabManager.tabs and TabManager.tabs[tabName]
	const page = info and info.page
	if typeof(page) ~= "Instance" then
		return false
	end
	for _, child in page:GetChildren() do
		const keep = child:IsA("UIListLayout") or child:IsA("UIPadding") or child:IsA("UIGridLayout") or child:IsA("UIPageLayout")
		if not keep then
			child:Destroy()
		end
	end
	info.elements = {}
	info.layoutIndex = 0
	return true
end

NAmanage.RegisterLazySettingsTab = NAmanage.RegisterLazySettingsTab or function(tabName, builder)
	if type(tabName) ~= "string" or type(builder) ~= "function" then
		return false
	end
	NAmanage.LazySettingsTabs = type(NAmanage.LazySettingsTabs) == "table" and NAmanage.LazySettingsTabs or {}
	NAmanage.LazySettingsTabs[tabName] = {
		builder = builder;
		built = false;
		building = false;
	}
	return true
end

NAmanage.BuildLazySettingsTab = NAmanage.BuildLazySettingsTab or function(tabName)
	const store = type(NAmanage.LazySettingsTabs) == "table" and NAmanage.LazySettingsTabs or nil
	const entry = store and store[tabName]
	if not entry or entry.built == true or entry.building == true then
		return entry and entry.built == true
	end
	entry.building = true
	NAmanage.MarkExternalLagProbe("settings_lazy_build_start:"..tostring(tabName))
	NAmanage.ClearSettingsTabPage(tabName)
	local ok, err = NAgui.withSettingsTabContext(tabName, entry.builder)
	entry.building = false
	entry.built = ok == true
	NAmanage.MarkExternalLagProbe((ok and "settings_lazy_build_done:" or "settings_lazy_build_error:")..tostring(tabName))
	if not ok then
		warn(err)
		return false
	end
	const info = TabManager and TabManager.tabs and TabManager.tabs[tabName]
	if info and info.page and TabManager.current == tabName then
		if updateCanvasSize then
			pcall(updateCanvasSize, info.page, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
		end
		if NAmanage.SettingsScroll and NAmanage.SettingsScroll.setTarget then
			pcall(NAmanage.SettingsScroll.setTarget, info.page)
		end
	end
	return true
end
NAgui.getSettingsTarget = function()
	const tabName = NAgui.getSettingsTabContext() or TabManager.current
	const info = tabName and TabManager.tabs and TabManager.tabs[tabName]
	const page = info and info.page or (NAUIMANAGER and NAUIMANAGER.SettingsList)
	return page, tabName
end

NAgui._nextLayoutOrder = function(targetTabName)
	const resolvedTabName = targetTabName or NAgui.getSettingsTabContext() or TabManager.current
	const active = resolvedTabName and TabManager.tabs[resolvedTabName];
	if active then
		active.layoutIndex = (active.layoutIndex or 0) + 1;
		return active.layoutIndex;
	elseif TabManager.fallback then
		TabManager.fallback.layoutIndex = (TabManager.fallback.layoutIndex or 0) + 1;
		TabManager.fallbackIndex = TabManager.fallback.layoutIndex;
		return TabManager.fallback.layoutIndex;
	else
		TabManager.fallbackIndex = (TabManager.fallbackIndex or 0) + 1;
		return TabManager.fallbackIndex;
	end;
end;
NAgui.setTab = function(name, opts)
	opts = opts or {};
	const info = name and TabManager.tabs[name];
	if not info then
		return nil;
	end;
	const previousTab = TabManager.current;
	const isAllTab = NA_TABS and name == NA_TABS.TAB_ALL;
	const buildState = NAgui.SettingsBuildState;
	const settingsBuildActive = NAStuff.SettingsBuildRunning == true and type(buildState) == "table" and buildState.background == true;
	const backgroundBuild = settingsBuildActive and opts.user ~= true and opts.forceMount ~= true;
	if settingsBuildActive and opts.user == true then
		buildState.userInteracted = true;
		buildState.userSelectedTab = name;
	end;
	if backgroundBuild then
		if NAgui.setSettingsTabContext then
			NAgui.setSettingsTabContext(name);
		end;
		if buildState.userInteracted == true then
			return info.page;
		end;
		TabManager.current = name;
		if not isAllTab then
			TabManager.lastNonAll = name;
		end;
		const keepMounted = name == ((NA_TABS and NA_TABS.TAB_GENERAL) or nil);
		if info.page then
			info.page.Visible = false;
			if keepMounted and TabManager.container then
				if info.page.Parent ~= TabManager.container then
					info.page.Parent = TabManager.container;
				end;
			elseif info.page.Parent then
				info.page.Parent = nil;
			end;
			NAUIMANAGER.SettingsList = info.page;
		end;
		for tabName, tabInfo in TabManager.tabs do
			if tabInfo.page then
				tabInfo.page.Visible = false;
				const keepTabMounted = tabName == ((NA_TABS and NA_TABS.TAB_GENERAL) or nil);
				if keepTabMounted and TabManager.container then
					if tabInfo.page.Parent ~= TabManager.container then
						tabInfo.page.Parent = TabManager.container;
					end;
				elseif tabInfo.page.Parent then
					tabInfo.page.Parent = nil;
				end;
			end;
			NAmanage.updateTabVisual(tabInfo, tabName == name);
		end;
		return info.page;
	end;
	if previousTab == name then
		if name == NA_TABS.TAB_BASIC_INFO and NAgui.RefreshBasicInfo then
			pcall(NAgui.RefreshBasicInfo);
		end;
		if info.page then
			if TabManager.container and info.page.Parent ~= TabManager.container then info.page.Parent = TabManager.container end;
			info.page.Visible = true;
			NAUIMANAGER.SettingsList = info.page;
			if NAmanage.SettingsScroll and NAmanage.SettingsScroll.setTarget then
				NAmanage.SettingsScroll.setTarget(info.page);
			end;
		end;
		if isAllTab and NAStuff.settingsAllDirty then
			NAmanage.prepareAllTabDisplay(info);
		end;
		return info.page;
	end;
	if not isAllTab then
		const moved = NAmanage.mountTabElements(info, name);
		if moved > 0 then
			NAStuff.settingsAllDirty = true;
		end;
	end;
	TabManager.current = name;
	if not isAllTab then
		TabManager.lastNonAll = name;
	end;
	if name == NA_TABS.TAB_BASIC_INFO and NAgui.RefreshBasicInfo then
		pcall(NAgui.RefreshBasicInfo);
	end;
	if info.page then
		NAUIMANAGER.SettingsList = info.page;
	end;
	const targetContainer = TabManager.container or (TabManager.defaultPage and TabManager.defaultPage.Parent);
	for tabName, tabInfo in TabManager.tabs do
		const isActive = tabName == name;
		if tabInfo.page then
			if isActive then
				if targetContainer and tabInfo.page.Parent ~= targetContainer then
					tabInfo.page.Parent = targetContainer;
				end;
				tabInfo.page.Visible = true;
				pcall(function() tabInfo.page.AutomaticCanvasSize = Enum.AutomaticSize.Y end);
			else
				tabInfo.page.Visible = false;
				if targetContainer and tabInfo.page.Parent == targetContainer then
					tabInfo.page.Parent = nil;
				end;
			end;
		end;
		NAmanage.updateTabVisual(tabInfo, isActive);
	end;
	if isAllTab then
		NAmanage.prepareAllTabDisplay(info);
	elseif info.page and info.page:IsA("ScrollingFrame") then
		updateCanvasSize(info.page, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
	end;
	if NAmanage.SettingsScroll and NAmanage.SettingsScroll.setTarget then
		NAmanage.SettingsScroll.setTarget(info.page);
	end;
	return info.page;
end;
NAmanage.SetSearch = NAmanage.SetSearch or {};
NAmanage.SetSearch.state = NAmanage.SetSearch.state or {
	active = false,
	last = "",
	vis = {}
};
function NAmanage.SetSearch.ignore(element)
	if not element or typeof(element) ~= "Instance" then
		return true;
	end;
	if not element:IsA("GuiObject") then
		return true;
	end;
	return element:IsA("UIListLayout") or element:IsA("UIPadding") or element:IsA("UIPageLayout");
end;
function NAmanage.SetSearch.scan(handler)
	if type(handler) ~= "function" then
		return;
	end;
	const list = NAUIMANAGER.SettingsList;
	if not list or typeof(list) ~= "Instance" then
		return;
	end;
	local root = list;
	for _, child in list:GetChildren() do
		if child:IsA("GuiObject") and NAmanage.GetAttr(child, "NAAllWrapper") then
			root = child;
			break;
		end;
	end;
	for _, child in root:GetChildren() do
		if not NAmanage.SetSearch.ignore(child) then
			handler(child);
		end;
	end;
end;
function NAmanage.SetSearch.tag(element, labelText)
	if not element or typeof(element) ~= "Instance" then
		return;
	end;
	if typeof(labelText) ~= "string" or labelText == "" then
		return;
	end;
	const cleaned = NAmanage.SetSearch.clean(labelText);
	pcall(function()
		NAmanage.SetAttr(element, "NASearchLabel", labelText);
		NAmanage.SetAttr(element, "NASearchText", cleaned);
	end);
end;
function NAmanage.SetSearch.label(element)
	if not element then
		return "";
	end;
	const stored = NAmanage.GetAttr(element, "NASearchLabel");
	if type(stored) == "string" and stored ~= "" then
		return stored;
	end;
	const title = element:FindFirstChild("Title", true);
	if title and (title:IsA("TextLabel") or title:IsA("TextBox") or title:IsA("TextButton")) then
		return title.Text or "";
	end;
	const fallbackNames = {
		"Description",
		"Desc",
		"Information"
	};
	for _, name in fallbackNames do
		const descendant = element:FindFirstChild(name, true);
		if descendant and descendant:IsA("TextLabel") then
			return descendant.Text or "";
		end;
	end;
	const fallback = element:FindFirstChildWhichIsA("TextLabel", true);
	if fallback then
		return fallback.Text or "";
	end;
	return element.Name or "";
end;
function NAmanage.SetSearch.info(element)
	if not element then
		return "";
	end;
	const storedText = NAmanage.GetAttr(element, "NASearchText");
	if type(storedText) == "string" and storedText ~= "" then
		return storedText;
	end;
	local rawText = NAmanage.SetSearch.collectText and NAmanage.SetSearch.collectText(element) or "";
	if rawText == "" then
		rawText = NAmanage.SetSearch.label(element);
	end;
	const cleaned = NAmanage.SetSearch.clean(rawText);
	pcall(function()
		NAmanage.SetAttr(element, "NASearchText", cleaned);
	end);
	return cleaned;
end;
function NAmanage.SetSearch.norm(text)
	text = text or "";
	if NAgui.normalizeCommandFilter then
		text = NAgui.normalizeCommandFilter(text);
	else
		text = Lower(text);
	end;
	text = GSub(text, "^%s*(.-)%s*$", "%1");
	return text;
end;
function NAmanage.SetSearch.clean(text)
	text = text or "";
	local lowered = Lower(text);
	lowered = GSub(lowered, "<[^>]+>", "");
	lowered = GSub(lowered, "%s+", " ");
	lowered = GSub(lowered, "^%s*(.-)%s*$", "%1");
	return lowered;
end;
function NAmanage.SetSearch.collectText(element)
	if not element or typeof(element) ~= "Instance" then
		return "";
	end;
	const parts = {};
	const function walk(obj)
		if not obj or typeof(obj) ~= "Instance" then
			return;
		end;
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			const t = obj.Text;
			if type(t) == "string" and t ~= "" then
				Insert(parts, t);
			end;
		end;
		for _, child in obj:GetChildren() do
			walk(child);
		end;
	end;
	walk(element);
	return Concat(parts, " ");
end;
function NAmanage.SetSearch.reset()
	for element, original in NAmanage.SetSearch.state.vis do
		if typeof(element) == "Instance" and element:IsA("GuiObject") then
			element.Visible = original;
		end;
	end;
	table.clear(NAmanage.SetSearch.state.vis);
	NAmanage.SetSearch.state.active = false;
	NAmanage.SetSearch.state.last = "";
	if NAUIMANAGER and NAUIMANAGER.SettingsList then
		updateCanvasSize(NAUIMANAGER.SettingsList, NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
	end;
end;
function NAmanage.SetSearch.match(element, query)
	if query == "" then
		return true;
	end;
	const info = NAmanage.SetSearch.info(element);
	if info == "" then
		return false;
	end;
	if Sub(info, 1, #query) == query then
		return true;
	end;
	return Find(info, query, 1, true) ~= nil;
end;
function NAmanage.SetSearch.isSect(element)
	if not element or typeof(element) ~= "Instance" then
		return false;
	end;
	if NAmanage.GetAttr(element, "NASettingsSection") == true then
		return true;
	end;
	return element.Name == "SectionTitle" and element:IsA("GuiObject");
end;
function NAmanage.SetSearch.sectVis(list, matchesMap)
	if not list then
		return;
	end;
	local root = list;
	for _, child in list:GetChildren() do
		if child:IsA("GuiObject") and NAmanage.GetAttr(child, "NAAllWrapper") then
			root = child;
			break;
		end;
	end;
	const children = root:GetChildren();
	const lowImpact = (NAmanage.IsLowEndUI and NAmanage.IsLowEndUI()) or IsOnMobile == true;
	const batch = lowImpact and 40 or 100;
	for index = 1, #children do
		const child = children[index];
		if child and (not NAmanage.SetSearch.ignore(child)) and NAmanage.SetSearch.isSect(child) then
			local visible = matchesMap[child];
			if not visible then
				visible = false;
				for j = index + 1, #children do
					const candidate = children[j];
					if candidate and (not NAmanage.SetSearch.ignore(candidate)) then
						if NAmanage.SetSearch.isSect(candidate) then
							break;
						end;
						if candidate.Visible then
							visible = true;
							break;
						end;
					end;
				end;
			end;
			child.Visible = visible and true or false;
		end;
		if index % batch == 0 then
			Wait();
		end;
	end;
end;
function NAmanage.SetSearch.apply(rawText)
	const list = NAUIMANAGER.SettingsList;
	if not list then
		return;
	end;
	const query = NAmanage.SetSearch.norm(rawText);
	NAmanage.SetSearch.state.last = rawText or "";
	if query == "" then
		if NAmanage.SetSearch.state.active then
			NAmanage.SetSearch.reset();
		end;
		return;
	end;
	NAmanage.SetSearch.state.active = true;
	const matchesMap = {};
	local scanned = 0;
	const lowImpact = (NAmanage.IsLowEndUI and NAmanage.IsLowEndUI()) or IsOnMobile == true;
	const batch = lowImpact and 35 or 90;
	NAmanage.SetSearch.scan(function(element)
		scanned += 1;
		if scanned % batch == 0 then
			Wait();
		end;
		if NAmanage.SetSearch.state.vis[element] == nil then
			NAmanage.SetSearch.state.vis[element] = element.Visible;
		end;
		const matches = NAmanage.SetSearch.match(element, query);
		matchesMap[element] = matches;
		element.Visible = matches;
	end);
	NAmanage.SetSearch.sectVis(list, matchesMap);
	updateCanvasSize(list, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil);
end;
function NAmanage.SetSearch.schedule(rawText, delayTime)
	const state = NAmanage.SetSearch.state;
	state.tick = (tonumber(state.tick) or 0) + 1;
	const thisTick = state.tick;
	state.pending = rawText or "";
	const lowImpact = (NAmanage.IsLowEndUI and NAmanage.IsLowEndUI()) or IsOnMobile == true;
	local waitTime = delayTime;
	if waitTime == nil then
		waitTime = lowImpact and 0.16 or 0.06;
	end;
	Delay(waitTime, function()
		if not NAmanage.SetSearch or NAmanage.SetSearch.state.tick ~= thisTick then
			return;
		end;
		NAmanage.SetSearch.apply(NAmanage.SetSearch.state.pending or "");
	end);
end;
function NAmanage.SetSearch.init()
	const input = NAUIMANAGER.SettingsSearchBox;
	if not input then
		return;
	end;
	NAlib.disconnect("settings_search_text");
	NAlib.connect("settings_search_text", (input:GetPropertyChangedSignal("Text")):Connect(function()
		NAmanage.SetSearch.schedule(input.Text or "");
	end));
	NAmanage.SetSearch.apply(input.Text or "");
end;
NAmanage.SetSearch.init();

originalIO.applyTabIDK=function()
	const baseSetTab = NAgui.setTab
	NAgui.setTab = function(name, opts)
		const page = baseSetTab(name, opts)
		if page then
			NAUIMANAGER.SettingsList = page
		end
		if opts and opts.user == true and NAmanage.BuildLazySettingsTab then
			pcall(NAmanage.BuildLazySettingsTab, name)
		end
		if NAmanage.SetSearch.state.active and NAmanage.SetSearch.state.last ~= "" then
			NAmanage.SetSearch.schedule(NAmanage.SetSearch.state.last, 0)
		end
		return page
	end
end
originalIO.applyTabIDK()

NAgui.addTab=function(name, options)
	if type(name) ~= "string" or name == "" then
		return nil
	end
	if type(NAgui.SettingsBuildState) == "table" and NAgui.SettingsBuildState.background == true then
		NAmanage.MarkExternalLagProbe("settings_tab:"..name)
	end
	const textIconOption = options and options.textIcon
	if TabManager.tabs[name] then
		const existingInfo = TabManager.tabs[name]
		if textIconOption ~= nil and existingInfo then
			existingInfo.textIcon = textIconOption
			if originalIO.applyTabDisplayText then
				originalIO.applyTabDisplayText(existingInfo, { isActive = existingInfo._isActive })
			end
		end
		if options and options.default then
			NAgui.setTab(name)
		end
		return existingInfo
	end

	const displayName = tostring((options and options.displayText) or name)
	local button
	const layoutOrder = options and options.order or (#TabManager.order + 1)
	if TabManager.holder then
		const holderLayout = TabManager.holder:FindFirstChildWhichIsA("UIListLayout") or TabManager.holder:FindFirstChildWhichIsA("UIGridLayout")
		if holderLayout then
			pcall(function() holderLayout.SortOrder = Enum.SortOrder.LayoutOrder end)
		end
	end
	if TabManager.template and TabManager.holder then
		button = TabManager.template:Clone()
		button.Visible = true
		button.Name = name.."Tab"
		const title = button:FindFirstChild("Title")
		if title then
			title.Text = displayName
		end
		button.LayoutOrder = layoutOrder
		button.Parent = TabManager.holder
		if NAmanage.SettingsTabLayout and type(NAmanage.SettingsTabLayout.StyleButton) == "function" then
			NAmanage.SettingsTabLayout.StyleButton(button, NAmanage.SettingsTabLayout.IsHorizontal())
		end
		NAgui.RegisterStrokesFromAsync(button)
		const interact = button:FindFirstChild("Interact") or button
		MouseButtonFix(interact, function()
			NAgui.setTab(name, { user = true })
		end)
	end

	local info
	if TabManager.fallback and TabManager.fallback.page then
		info = {
			name = name;
			displayName = displayName;
			page = TabManager.fallback.page;
			button = button;
			layoutIndex = TabManager.fallback.layoutIndex or 0;
			textIcon = textIconOption;
			_isActive = false;
		}
		TabManager.fallback = nil
	else
		const pageTemplate = TabManager.pageTemplate
		const page = pageTemplate and pageTemplate:Clone() or (TabManager.defaultPage and TabManager.defaultPage:Clone()) or InstanceNew("ScrollingFrame")
		page.Name = name.." Page"
		page.Visible = false
		page.CanvasPosition = Vector2.new(0, 0)
		if not page:FindFirstChildWhichIsA("UIListLayout") and TabManager.defaultPage then
			const layout = TabManager.defaultPage:FindFirstChildWhichIsA("UIListLayout")
			if layout then
				layout:Clone().Parent = page
			end
		end
		const keepMountedDuringBuild = NAStuff.SettingsBuildRunning == true and name == ((NA_TABS and NA_TABS.TAB_GENERAL) or nil)
		if keepMountedDuringBuild and TabManager.container then
			page.Parent = TabManager.container
		elseif NAStuff.SettingsBuildRunning == true then
			page.Parent = nil
		else
			page.Parent = TabManager.container or (TabManager.defaultPage and TabManager.defaultPage.Parent)
		end
		info = {
			name = name;
			displayName = displayName;
			page = page;
			button = button;
			layoutIndex = 0;
			textIcon = textIconOption;
			_isActive = false;
		}
	end

	if info.page then
		if NAmanage.SettingsScroll and NAmanage.SettingsScroll.applyPageDefaults then
			NAmanage.SettingsScroll.applyPageDefaults(info.page);
		end
		NAgui.RegisterStrokesFromAsync(info.page)
	end
	if info.button and originalIO.applyTabDisplayText then
		originalIO.applyTabDisplayText(info, { isActive = info._isActive })
	end

	info.order = layoutOrder
	info.elements = info.elements or {}
	TabManager.tabs[name] = info
	Insert(TabManager.order, name)
	table.sort(TabManager.order, function(a, b)
		const infoA = TabManager.tabs[a]
		const infoB = TabManager.tabs[b]
		const orderA = infoA and infoA.order or math.huge
		const orderB = infoB and infoB.order or math.huge
		if orderA == orderB then
			return tostring(a) < tostring(b)
		end
		return orderA < orderB
	end)
	for _, orderedName in TabManager.order do
		const tab = TabManager.tabs[orderedName]
		if tab and tab.button then
			tab.button.LayoutOrder = tab.order or layoutOrder
		end
	end

	const shouldSet = (options and options.default) or not TabManager.current
	if NAmanage.SettingsTabLayout and type(NAmanage.SettingsTabLayout.UpdateTabCanvas) == "function" then
		Defer(function()
			NAmanage.SettingsTabLayout.UpdateTabCanvas(false)
		end)
	end

	if shouldSet then
		NAgui.setTab(name)
	else
		if info.page then
			info.page.Visible = false
			if NAStuff.SettingsBuildRunning == true then
				if info.page.Parent then
					info.page.Parent = nil
				end
			elseif TabManager.container and info.page.Parent ~= TabManager.container then
				info.page.Parent = TabManager.container
			end
		end
		NAmanage.updateTabVisual(info, false)
	end

	return info
end

SpawnCall(function()
	for _,v in NAmanage.QueryDescendants(NAStuff.NASCREENGUI, "UIStroke") do
		NAgui.RegisterColoredStroke(v)
	end
end)

NAmanage.stripChar = function(text, trimWhitespace)
	if not text then
		return ""
	end
	local cleaned = text:gsub("\t", "")
	if trimWhitespace ~= false then
		cleaned = cleaned:gsub("^%s*(.-)%s*$", "%1")
	end
	return cleaned
end

predictionInput = NAUIMANAGER.cmdInput:Clone()
predictionInput.Name = "predictionInput"
predictionInput.TextEditable = false
predictionInput.Active = false
predictionInput.Selectable = false
predictionInput.TextTransparency = 0.55
predictionInput.TextColor3 = Color3.fromRGB(155, 155, 164)
predictionInput.BackgroundTransparency = 1
predictionInput.ZIndex = math.max(1, NAUIMANAGER.cmdInput.ZIndex - 1)
predictionInput.Parent = NAUIMANAGER.cmdInput.Parent
predictionInput.PlaceholderText = ""
predictionInput.Visible = false

NAmanage.SyncCmdPredictionVisual = function()
	if not predictionInput then return end
	if NAmanage.IsLegacyCommandUI and NAmanage.IsLegacyCommandUI() then
		predictionInput.Visible = true
		return
	end
	const typedText = NAUIMANAGER and NAUIMANAGER.cmdInput and NAUIMANAGER.cmdInput.Text or ""
	const hasPrediction = predictionInput.Text ~= "" and predictionInput.Text ~= typedText
	predictionInput.Visible = hasPrediction
	const centerBar = NAUIMANAGER and NAUIMANAGER.centerBar
	const hint = centerBar and centerBar:FindFirstChild("TabHint")
	if not hint then return end
	const outline = hint:FindFirstChild("TabHintOutline")
	hint.TextColor3 = hasPrediction and Color3.fromRGB(245, 245, 248) or Color3.fromRGB(150, 150, 158)
	hint.BackgroundColor3 = hasPrediction and Color3.fromRGB(42, 42, 47) or Color3.fromRGB(27, 27, 31)
	hint.BackgroundTransparency = hasPrediction and 0.04 or 0.18
	if outline then
		outline.Transparency = hasPrediction and 0.52 or 0.86
	end
end
NAlib.connect("CmdPredictionVisual", predictionInput:GetPropertyChangedSignal("Text"):Connect(NAmanage.SyncCmdPredictionVisual))
NAlib.connect("CmdPredictionTypedVisual", NAUIMANAGER.cmdInput:GetPropertyChangedSignal("Text"):Connect(NAmanage.SyncCmdPredictionVisual))
NAmanage.SyncCmdPredictionVisual()
NAmanage.ApplyCommandPredictionMode(NAmanage.IsLegacyCommandUI())

opt.NAAUTOSCALER = NAUIMANAGER.AUTOSCALER

	--[[NACaller(function()
		for i,v in NAmanage.QueryDescendants(NAStuff.NASCREENGUI, "Instance") do
			coreGuiProtection[v]=rPlayer.Name
		end
		NAlib.connect("CoreGuiProtection_Main", NAmanage.descAdd(NAStuff.NASCREENGUI, function(v)
			coreGuiProtection[v]=rPlayer.Name
		end))
		coreGuiProtection[NAStuff.NASCREENGUI]=rPlayer.Name

		meta=getrawmetatable(game)
		tostr=meta.__tostring
		setreadonly(meta,false)
		meta.__tostring=newcclosure(function(t)
			if coreGuiProtection[t] and not checkcaller() then
				return coreGuiProtection[t]
			end
			return tostr(t)
		end)
	end)
	if not __lt.cm("RunService", "IsStudio") then
		newGui=__lt.cm("CoreGui", "FindFirstChildWhichIsA", "NAStuff.NASCREENGUI")
		NAlib.connect("CoreGuiProtection_New", NAmanage.descAdd(newGui, function(v)
			coreGuiProtection[v]=rPlayer.Name
		end))
		for i,v in NAStuff.NASCREENGUI:GetChildren() do
			v.Parent=newGui
		end
		NAStuff.NASCREENGUI=newGui
	end]]

cmd.add({"rename"}, {"rename <text>", "Renames the admin UI placeholder to the given name"}, function(...)
	const newName = Concat({...}, " ")
	adminName = newName
	if NAUIMANAGER.cmdInput and NAUIMANAGER.cmdInput.PlaceholderText then
		NAUIMANAGER.cmdInput.PlaceholderText = newName
	end
end, true)

cmd.add({"unname"}, {"unname", "Resets the admin UI placeholder name to default"}, function()
	adminName = _na_env.NATestingVer and "NA Testing" or "Nameless Admin"
	if NAUIMANAGER.cmdInput and NAUIMANAGER.cmdInput.PlaceholderText then
		NAUIMANAGER.cmdInput.PlaceholderText = isAprilFools() and '🤡 '..adminName..curVer..' 🤡' or NAmanage.getSeasonEmoji()..' '..adminName..curVer..' '..NAmanage.getSeasonEmoji()
	end
end)

NAStuff._selectedCommandAddons = NAStuff._selectedCommandAddons or {}
NAStuff._selectedCommandAddons.specificTools = NAStuff._selectedCommandAddons.specificTools or {}
NAStuff._selectedCommandAddons.frozenParts = NAStuff._selectedCommandAddons.frozenParts or {}
NAStuff._selectedCommandAddons.propChanged = NAStuff._selectedCommandAddons.propChanged or {}

NAmanage.ResolveInstPath = NAmanage.ResolveInstPath or function(path)
	if typeof(path) == "Instance" then
		return path
	end
	local text = tostring(path or "")
	text = text:gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then
		return nil
	end
	const tokens = {}
	for part in text:gmatch("[^%.]+") do
		part = part:gsub("^%s+", ""):gsub("%s+$", "")
		if part ~= "" then
			tokens[#tokens + 1] = part
		end
	end
	if #tokens == 0 then
		return nil
	end
	const first = tokens[1]
	local current
	local startIndex = 2
	const lowFirst = Lower(first)
	if lowFirst == "game" then
		current = game
	elseif lowFirst == "workspace" then
		current = Services.Workspace
	elseif lowFirst == "player" or lowFirst == "localplayer" or lowFirst == "me" then
		current = Services.Players and Services.Players.LocalPlayer or nil
	elseif lowFirst == "character" or lowFirst == "char" then
		const lp = Services.Players and Services.Players.LocalPlayer
		current = lp and lp.Character or nil
	elseif lowFirst == "playergui" then
		const lp = Services.Players and Services.Players.LocalPlayer
		current = lp and lp:FindFirstChildOfClass("PlayerGui") or nil
	elseif lowFirst == "backpack" then
		const lp = Services.Players and Services.Players.LocalPlayer
		current = lp and lp:FindFirstChildOfClass("Backpack") or nil
	else
		current = game:FindFirstChild(first) or Services.Workspace:FindFirstChild(first)
		startIndex = 2
	end
	if not current then
		return nil
	end
	for i = startIndex, #tokens do
		const name = tokens[i]
		local nextObj
		pcall(function()
			nextObj = current:FindFirstChild(name)
		end)
		if not nextObj then
			local ok, val = pcall(function()
				return current[name]
			end)
			if ok then
				nextObj = val
			end
		end
		current = nextObj
		if not current then
			return nil
		end
	end
	return current
end


NAmanage.DeleteGuiAtPosition = NAmanage.DeleteGuiAtPosition or function(x, y)
	const RawCoreGui = __lt.gs("CoreGui")
	x = tonumber(x)
	y = tonumber(y)
	if not x or not y then
		return 0
	end
	const lp = Services.Players and Services.Players.LocalPlayer
	const roots = {}
	const pg = lp and lp:FindFirstChildOfClass("PlayerGui")
	if pg then roots[#roots + 1] = pg end
	if Services.CoreGui then roots[#roots + 1] = Services.CoreGui end
	local hui
	pcall(function()
		hui = NAlib.huiGrabber and NAlib.huiGrabber()
	end)
	if hui and hui ~= pg and hui ~= Services.CoreGui and hui ~= RawCoreGui then
		roots[#roots + 1] = hui
	end
	const seen = {}
	const list = {}
	for _, root in roots do
		local ok, guis = pcall(function()
			return root:GetGuiObjectsAtPosition(x, y)
		end)
		if ok and type(guis) == "table" then
			for _, gui in guis do
				if typeof(gui) == "Instance" and not seen[gui] then
					seen[gui] = true
					list[#list + 1] = gui
				end
			end
		end
	end
	table.sort(list, function(a, b)
		local za, zb = 0, 0
		pcall(function() za = a.AbsoluteSize.X * a.AbsoluteSize.Y end)
		pcall(function() zb = b.AbsoluteSize.X * b.AbsoluteSize.Y end)
		return za < zb
	end)
	for _, gui in list do
		if gui and gui.Parent and gui:IsA("GuiObject") then
			local target = gui
			while target.Parent and target.Parent:IsA("GuiObject") and target.Parent:IsA("GuiButton") == false do
				target = target.Parent
			end
			pcall(function()
				target:Destroy()
			end)
			return 1
		end
	end
	return 0
end

NAmanage.RemoveToolInst = NAmanage.RemoveToolInst or function(tool)
	if typeof(tool) ~= "Instance" then
		return false
	end
	if tool:IsA("Tool") or tool:IsA("HopperBin") then
		pcall(function()
			tool:Destroy()
		end)
		return true
	end
	return false
end

NAmanage.RemoveHeldTools = NAmanage.RemoveHeldTools or function()
	const char = getChar()
	local count = 0
	if not char then
		return 0
	end
	for _, item in char:GetChildren() do
		if NAmanage.RemoveToolInst(item) then
			count += 1
		end
	end
	return count
end

NAmanage.RemoveSpecificToolNow = NAmanage.RemoveSpecificToolNow or function(toolName)
	const wanted = Lower(tostring(toolName or ""))
	if wanted == "" then
		return 0
	end
	const char = getChar()
	const bp = getBp()
	const roots = { bp, char }
	local count = 0
	for _, root in roots do
		if root then
			for _, item in root:GetChildren() do
				if (item:IsA("Tool") or item:IsA("HopperBin")) and Lower(item.Name) == wanted then
					if NAmanage.RemoveToolInst(item) then
						count += 1
					end
				end
			end
		end
	end
	return count
end

NAmanage.SpecificToolMatches = NAmanage.SpecificToolMatches or function(item, wanted)
	return (typeof(item) == "Instance")
		and (item:IsA("Tool") or item:IsA("HopperBin"))
		and Lower(item.Name) == wanted
end

NAmanage.DisconnectSpecificToolRemovalRecord = NAmanage.DisconnectSpecificToolRemovalRecord or function(rec)
	if type(rec) ~= "table" then
		return
	end
	if type(rec.conns) == "table" then
		for i = 1, #rec.conns do
			rec.conns[i] = NAmanage.tryDisconnect(rec.conns[i])
		end
	end
	rec.conn = NAmanage.tryDisconnect(rec.conn)
end

NAmanage.StartSpecificToolRemoval = NAmanage.StartSpecificToolRemoval or function(toolName)
	const wanted = Lower(tostring(toolName or ""))
	if wanted == "" then
		return false, "Tool name is required."
	end
	const st = NAStuff._selectedCommandAddons
	const old = st.specificTools[wanted]
	NAmanage.DisconnectSpecificToolRemovalRecord(old)

	const rec = {
		name = wanted,
		conns = {},
		watched = NAmanage.ensureWeakKeyTable(),
	}
	st.specificTools[wanted] = rec

	const function removeIfMatch(item)
		if NAmanage.SpecificToolMatches(item, wanted) then
			NAmanage.RemoveToolInst(item)
		end
	end

	const function watchContainer(container)
		if typeof(container) ~= "Instance" then
			return
		end
		if rec.watched[container] then
			return
		end
		rec.watched[container] = true
		for _, item in container:GetChildren() do
			removeIfMatch(item)
		end
		local childConn
		local ancestryConn
		childConn = container.ChildAdded:Connect(removeIfMatch)
		ancestryConn = container.AncestryChanged:Connect(function(_, parent)
			if parent then
				return
			end
			rec.watched[container] = nil
			childConn = NAmanage.tryDisconnect(childConn)
			ancestryConn = NAmanage.tryDisconnect(ancestryConn)
		end)
		rec.conns[#rec.conns + 1] = childConn
		rec.conns[#rec.conns + 1] = ancestryConn
	end

	const function bindCurrentContainers()
		if st.specificTools[wanted] ~= rec then
			return
		end
		watchContainer(getBp())
		watchContainer(getChar())
	end

	NAmanage.RemoveSpecificToolNow(wanted)
	bindCurrentContainers()
	const lp = Services.Players and Services.Players.LocalPlayer
	if lp then
		rec.conns[#rec.conns + 1] = lp.CharacterAdded:Connect(function(char)
			if st.specificTools[wanted] ~= rec then
				return
			end
			if typeof(char) == "Instance" then
				watchContainer(char)
			end
			NAmanage.RemoveSpecificToolNow(wanted)
		end)
		rec.conns[#rec.conns + 1] = lp.ChildAdded:Connect(function(child)
			if st.specificTools[wanted] ~= rec then
				return
			end
			if child and child:IsA("Backpack") then
				watchContainer(child)
				NAmanage.RemoveSpecificToolNow(wanted)
			end
		end)
	end
	return true, wanted
end

NAmanage.StopSpecificToolRemoval = NAmanage.StopSpecificToolRemoval or function(toolName)
	const wanted = Lower(tostring(toolName or ""))
	const st = NAStuff._selectedCommandAddons
	if wanted == "" then
		return false, "Tool name is required."
	end
	const rec = st.specificTools[wanted]
	if not rec then
		return false, "No removal loop for "..wanted
	end
	NAmanage.DisconnectSpecificToolRemovalRecord(rec)
	st.specificTools[wanted] = nil
	return true, wanted
end

NAmanage.ClearSpecificToolRemoval = NAmanage.ClearSpecificToolRemoval or function()
	const st = NAStuff._selectedCommandAddons
	local count = 0
	for key, rec in st.specificTools do
		NAmanage.DisconnectSpecificToolRemovalRecord(rec)
		st.specificTools[key] = nil
		count += 1
	end
	return count
end

NAmanage.ShouldFreezePart = NAmanage.ShouldFreezePart or function(part)
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") or part.Anchored then
		return false
	end
	const char = getChar()
	if char and part:IsDescendantOf(char) then
		return false
	end
	const n = part.Name
	if n == "HumanoidRootPart" or n == "Head" or n == "Torso" or n == "UpperTorso" or n == "LowerTorso" or n == "Right Arm" or n == "Left Arm" or n == "Right Leg" or n == "Left Leg" or n:find("Upper") or n:find("Lower") or n:find("Hand") or n:find("Foot") then
		const model = part:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			return false
		end
	end
	return true
end

NAmanage.FreezeUnanchoredPart = NAmanage.FreezeUnanchoredPart or function(part)
	if not NAmanage.ShouldFreezePart(part) then
		return false
	end
	const st = NAStuff._selectedCommandAddons
	if st.frozenParts[part] then
		return false
	end
	const rec = {}
	rec.bp = InstanceNew("BodyPosition")
	rec.bg = InstanceNew("BodyGyro")
	rec.bp.Position = part.Position
	rec.bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	rec.bp.P = 50000
	rec.bg.CFrame = part.CFrame
	rec.bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	rec.bg.P = 50000
	rec.bp.Parent = part
	rec.bg.Parent = part
	st.frozenParts[part] = rec
	return true
end

NAmanage.ThawUnanchored = NAmanage.ThawUnanchored or function()
	const st = NAStuff._selectedCommandAddons
	NAlib.disconnect("freeze_unanchored_added")
	local count = 0
	for part, rec in st.frozenParts do
		if rec then
			NAmanage.tryDisconnect(rec.conn)
			if rec.bp then pcall(function() rec.bp:Destroy() end) end
			if rec.bg then pcall(function() rec.bg:Destroy() end) end
		end
		st.frozenParts[part] = nil
		count += 1
	end
	return count
end

NAmanage.FreezeUnanchored = NAmanage.FreezeUnanchored or function()
	local count = 0
	for _, inst in Services.Workspace:QueryDescendants("BasePart") do
		if NAmanage.FreezeUnanchoredPart(inst) then
			count += 1
		end
	end
	NAlib.disconnect("freeze_unanchored_added")
	NAlib.connect("freeze_unanchored_added", Services.Workspace.DescendantAdded:Connect(function(inst)
		if NAmanage.FreezeUnanchoredPart(inst) then
			DebugNotif("Froze new unanchored part: "..inst.Name, 1)
		end
	end))
	return count
end

cmd.add({"autorespawn", "autore", "arespawn"}, {"autorespawn (autore,arespawn)", "Teleports you back to your death position after respawn"}, function()
	NAlib.disconnect("auto_respawn")
	const st = NAStuff._selectedCommandAddons
	st.autoRespawn = true
	const function bind(char)
		if not st.autoRespawn or not char then return end
		const hum = getHum(char, 5)
		const root = getRoot(char) or char:WaitForChild("HumanoidRootPart", 5)
		if not hum or not root then return end
		NAlib.connect("auto_respawn", hum.Died:Connect(function()
			const ch = getChar()
			const r = ch and getRoot(ch)
			st.autoRespawnCFrame = r and r.CFrame or root.CFrame
		end))
	end
	const lp = Services.Players and Services.Players.LocalPlayer
	if lp then
		bind(lp.Character)
		NAlib.connect("auto_respawn", lp.CharacterAdded:Connect(function(char)
			const cf = st.autoRespawnCFrame
			bind(char)
			if cf then
				const root = getRoot(char) or char:WaitForChild("HumanoidRootPart", 8)
				if root then
					for _ = 1, 8 do
						root.CFrame = cf
						Wait(0.08)
					end
				end
			end
		end))
	end
	DebugNotif("AutoRespawn enabled", 2)
end)

cmd.add({"unautorespawn", "unautore", "unarespawn"}, {"unautorespawn (unautore,unarespawn)", "Stops AutoRespawn"}, function()
	NAStuff._selectedCommandAddons.autoRespawn = false
	NAStuff._selectedCommandAddons.autoRespawnCFrame = nil
	NAlib.disconnect("auto_respawn")
	DebugNotif("AutoRespawn disabled", 2)
end)

cmd.add({"guidelete", "gdel", "guidel"}, {"guidelete (gdel,guidel)", "Deletes GUI under mouse with Backspace/Delete, or under tap on mobile"}, function()
	NAlib.disconnect("gui_delete")
	NAlib.connect("gui_delete", Services.UserInputService.InputBegan:Connect(function(input, gp)
		if gp or not input then return end
		if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
			local pos
			pcall(function()
				pos = Services.UserInputService:GetMouseLocation()
			end)
			if not pos then
				const mouse = Services.Players.LocalPlayer and Services.Players.LocalPlayer:GetMouse()
				pos = mouse and Vector2.new(mouse.X, mouse.Y) or nil
			end
			if pos then
				const count = NAmanage.DeleteGuiAtPosition(pos.X, pos.Y)
				DebugNotif(count > 0 and "Deleted GUI under cursor" or "No GUI under cursor", 2)
			end
		end
	end))
	NAlib.connect("gui_delete", Services.UserInputService.TouchTap:Connect(function(positions, gp)
		if gp then return end
		const pos = type(positions) == "table" and positions[1] or positions
		if typeof(pos) == "Vector2" then
			const count = NAmanage.DeleteGuiAtPosition(pos.X, pos.Y)
			DebugNotif(count > 0 and "Deleted GUI under tap" or "No GUI under tap", 2)
		end
	end))
	DebugNotif("GUI delete enabled. PC: Backspace/Delete. Mobile: tap GUI.", 3)
end)

cmd.add({"unguidelete", "noguidelete", "ungdel", "unguidel"}, {"unguidelete (noguidelete,ungdel,unguidel)", "Disables GUI delete"}, function()
	NAlib.disconnect("gui_delete")
	DebugNotif("GUI delete disabled", 2)
end)

cmd.add({"deleteselectedtool", "dst", "dstool", "delstool"}, {"deleteselectedtool (dst,dstool,delstool)", "Deletes currently equipped tools"}, function()
	const count = NAmanage.RemoveHeldTools()
	DebugNotif(count > 0 and ("Deleted "..count.." selected tool(s)") or "No selected tool found", 2)
end)

cmd.add({"removespecifictool", "rstool", "rsptool", "rmsptool"}, {"removespecifictool <name> (rstool,rsptool,rmsptool)", "Automatically removes a specific tool from backpack/character"}, function(...)
	const name = Concat({...}, " ")
	local ok, msg = NAmanage.StartSpecificToolRemoval(name)
	DebugNotif(ok and ("Removing tool: "..msg) or msg, ok and 2 or 3)
end, true)

cmd.add({"unremovespecifictool", "unrstool", "unrsptool", "unrmsptool"}, {"unremovespecifictool <name> (unrstool,unrsptool,unrmsptool)", "Stops removing a specific tool"}, function(...)
	const name = Concat({...}, " ")
	local ok, msg = NAmanage.StopSpecificToolRemoval(name)
	DebugNotif(ok and ("Stopped removing tool: "..msg) or msg, ok and 2 or 3)
end, true)

cmd.add({"clearremovespecifictool", "clrrstool", "clearrstool", "crstool"}, {"clearremovespecifictool (clrrstool,clearrstool,crstool)", "Stops all specific tool removal loops"}, function()
	const count = NAmanage.ClearSpecificToolRemoval()
	DebugNotif("Cleared "..count.." specific tool removal loop(s)", 2)
end)

cmd.add({"propertychanged", "changed", "pchanged", "propchanged"}, {"propertychanged <path> <property> <command> [args]", "Runs a command when an instance property changes"}, function(path, prop, name, ...)
	if not path or not prop or not name then
		DebugNotif("Usage: propertychanged <path> <property> <command> [args]", 3)
		return
	end
	const obj = NAmanage.ResolveInstPath(path)
	if typeof(obj) ~= "Instance" then
		DebugNotif("Object not found: "..tostring(path), 3)
		return
	end
	const args = {...}
	local okProp, signal = pcall(function()
		return obj:GetPropertyChangedSignal(tostring(prop))
	end)
	if not okProp or not signal then
		DebugNotif("Invalid property: "..tostring(prop), 3)
		return
	end
	const st = NAStuff._selectedCommandAddons
	const key = tostring(obj:GetFullName()).."."..tostring(prop).." -> "..tostring(name).." "..Concat(args, " ")
	if st.propChanged[key] and st.propChanged[key].conn then
		NAmanage.tryDisconnect(st.propChanged[key].conn)
	end
	const conn = signal:Connect(function()
		const runArgs = { name }
		for i = 1, #args do
			runArgs[#runArgs + 1] = args[i]
		end
		cmd.run(runArgs)
	end)
	st.propChanged[key] = { conn = conn, obj = obj, prop = tostring(prop), name = tostring(name), args = args }
	DebugNotif("Listening for "..obj:GetFullName().."."..tostring(prop), 3)
end, true)

cmd.add({"unpropertychanged", "unchanged", "unpchanged", "unpropchanged"}, {"unpropertychanged [path] [property]", "Stops propertychanged listeners"}, function(path, prop)
	const st = NAStuff._selectedCommandAddons
	local count = 0
	const obj = path and NAmanage.ResolveInstPath(path) or nil
	for key, rec in st.propChanged do
		local remove = false
		if not path then
			remove = true
		elseif obj and rec and rec.obj == obj and (not prop or tostring(rec.prop) == tostring(prop)) then
			remove = true
		end
		if remove then
			NAmanage.tryDisconnect(rec.conn)
			st.propChanged[key] = nil
			count += 1
		end
	end
	DebugNotif("Stopped "..count.." propertychanged listener(s)", 2)
end, true)

cmd.add({"loop"}, {"loop [delay] <command> [args]", "Directly starts a command loop without opening the loop popup"}, function(...)
	const args = {...}
	local idx = 1
	local delay = tonumber(args[idx])
	if delay then
		idx += 1
	else
		delay = 0.05
	end
	const name = args[idx]
	if not name then
		DebugNotif("Usage: loop [delay] <command> [args]", 3)
		return
	end
	const cmdArgs = {}
	for i = idx + 1, #args do
		cmdArgs[#cmdArgs + 1] = args[i]
	end
	delay = math.clamp(tonumber(delay) or 0.05, 0, 60)
	local ok, result, loopData = NAmanage.StartLoop(tostring(name), cmdArgs, delay, NAStuff.LoopMethod)
	DebugNotif(ok and ("Loop started: "..loopData.commandName.." every "..loopData.interval.."s") or result, ok and 3 or 3)
end, true)

cmd.add({"unloop"}, {"unloop", "Stops all active command loops"}, function()
	local count = 0
	for _, entry in NAmanage.GetLoops() do
		if entry and entry.key then
			const ok = NAmanage.StopLoop(entry.key)
			if ok then
				count += 1
			end
		end
	end
	DebugNotif("Stopped "..count.." loop(s)", 2)
end)

cmd.add({"repeat"}, {"repeat [amount] [delay] <command> [args]", "Runs a command a repeated amount of times"}, function(...)
	const args = {...}
	local amount = tonumber(args[1])
	local idx = 1
	if amount then
		idx = 2
	else
		amount = 1
	end
	local delay = tonumber(args[idx])
	if delay then
		idx += 1
	else
		delay = 0
	end
	const name = args[idx]
	if not name then
		DebugNotif("Usage: repeat [amount] [delay] <command> [args]", 3)
		return
	end
	const cmdArgs = {}
	for i = idx + 1, #args do
		cmdArgs[#cmdArgs + 1] = args[i]
	end
	amount = math.clamp(math.floor(amount), 1, 1000)
	delay = math.clamp(delay, 0, 60)
	SpawnCall(function()
		for _ = 1, amount do
			const runArgs = { tostring(name) }
			for i = 1, #cmdArgs do
				runArgs[#runArgs + 1] = cmdArgs[i]
			end
			cmd.run(runArgs)
			if delay > 0 then
				Wait(delay)
			else
				Wait()
			end
		end
		DebugNotif("Repeated "..tostring(name).." "..amount.." time(s)", 2)
	end)
end, true)

cmd.add({"freezeunanchored", "freezeua", "fua"}, {"freezeunanchored (freezeua,fua)", "Freezes unanchored non-character parts"}, function()
	const count = NAmanage.FreezeUnanchored()
	DebugNotif("Froze "..count.." unanchored part(s)", 2)
end)

cmd.add({"thawunanchored", "thawua", "unfreezeunanchored", "unfreezeua", "tua"}, {"thawunanchored (thawua,unfreezeua,tua)", "Thaws parts frozen by freezeunanchored"}, function()
	const count = NAmanage.ThawUnanchored()
	DebugNotif("Thawed "..count.." frozen part(s)", 2)
end)

NAStuff.LastInputConns = NAStuff.LastInputConns or {}
NAStuff.PreferredInputConns = NAStuff.PreferredInputConns or {}
NAStuff.LastInputPatched = NAStuff.LastInputPatched or false

originalIO.ApplyLastInputPatch = function()
	if not IsOnMobile then
		return
	end

	if getconnections and not NAStuff.LastInputPatched then
		table.clear(NAStuff.LastInputConns)
		table.clear(NAStuff.PreferredInputConns)

		for _, c in getconnections(Services.UserInputService.LastInputTypeChanged) do
			Insert(NAStuff.LastInputConns, c)
			pcall(function()
				if c.Disable then
					c:Disable()
				end
			end)
		end

		local prefSignal
		pcall(function()
			prefSignal = __lt.cm("UserInputService", "GetPropertyChangedSignal", "PreferredInput")
		end)

		if prefSignal then
			for _, c in getconnections(prefSignal) do
				Insert(NAStuff.PreferredInputConns, c)
				pcall(function()
					if c.Disable then
						c:Disable()
					end
				end)
			end
		end
	end

	pcall(function()
		GS.TouchControlsEnabled = true
	end)

	if NAlib and NAlib.connect and NAlib.disconnect then
		NAlib.disconnect("NA_LastInputTouch")
		NAlib.connect("NA_LastInputTouch", __lt.cm("GuiService", "GetPropertyChangedSignal", "TouchControlsEnabled"):Connect(function()
			if IsOnMobile then
				pcall(function()
					Services.GuiService.TouchControlsEnabled = true
				end)
			end
		end))
	else
		__lt.cm("GuiService", "GetPropertyChangedSignal", "TouchControlsEnabled"):Connect(function()
			if IsOnMobile then
				pcall(function()
					Services.GuiService.TouchControlsEnabled = true
				end)
			end
		end)
	end

	NAStuff.LastInputPatched = true
end

originalIO.RevertLastInputPatch = function()
	if NAlib and NAlib.disconnect then
		NAlib.disconnect("NA_LastInputTouch")
	end

	if getconnections then
		if NAStuff.LastInputConns and #NAStuff.LastInputConns > 0 then
			for _, c in NAStuff.LastInputConns do
				pcall(function()
					if c.Enable then
						c:Enable()
					end
				end)
			end
		end

		if NAStuff.PreferredInputConns and #NAStuff.PreferredInputConns > 0 then
			for _, c in NAStuff.PreferredInputConns do
				pcall(function()
					if c.Enable then
						c:Enable()
					end
				end)
			end
		end
	end

	NAStuff.LastInputPatched = false
end

--[[ GUI FUNCTIONS ]]--
patchedCommandColor = Color3.fromRGB(255, 115, 115)
pluginCommandColor = Color3.fromRGB(255, 196, 125)
cmdIntegrationColor = Color3.fromRGB(120, 180, 255)
iyIntegrationColor = Color3.fromRGB(255, 205, 110)

NAgui.addPatchedLabel=function(text)
	if not text then return text end
	if Lower(text):find("patched", 1, true) then
		return text
	end
	return "[PATCHED] "..text
end

NAgui.txtSize=function(ui,x,y)
	const textService = Services.TextService
	if not (textService and ui) then
		return Vector2.new(0, 0)
	end

	local font = ui.Font
	if font == nil or font == Enum.Font.Unknown then
		font = Enum.Font.SourceSans
	end

	const text = ui.Text or ""
	const size = tonumber(ui.TextSize) or 14
	const bounds = Vector2.new(tonumber(x) or 100, tonumber(y) or 100)

	local ok, result = pcall(textService.GetTextSize, textService, text, size, font, bounds)
	if ok and result then
		return result
	end

	return Vector2.new(0, 0)
end
NAmanage._commandWorkStates = NAmanage.ensureWeakKeyTable and NAmanage.ensureWeakKeyTable(NAmanage._commandWorkStates) or setmetatable({}, { __mode = "k" })
NAmanage.resetCommandWorkBudget = function()
	const thread = coroutine.running()
	if type(thread) == "thread" then
		const now = os.clock()
		NAmanage._commandWorkStates[thread] = {
			started = now;
			last = now;
			count = 0;
			lowImpact = IsOnMobile == true or (type(NAmanage.IsLowEndUI) == "function" and NAmanage.IsLowEndUI() == true);
		}
	end
end

NAmanage.cmdYield=function()
	return
end

NAmanage.sortCommandEntries = function(entries)
	if type(entries) ~= "table" or #entries < 2 then
		return entries
	end
	const work = {}
	const count = #entries
	local width = 1
	while width < count do
		local left = 1
		while left <= count do
			const middle = math.min(left + width - 1, count)
			const right = math.min(left + width * 2 - 1, count)
			local a = left
			local b = middle + 1
			local write = left
			while a <= middle and b <= right do
				const aEntry = entries[a]
				const bEntry = entries[b]
				const aKey = tostring(aEntry and (aEntry.sortKey or aEntry.display or aEntry.name) or "")
				const bKey = tostring(bEntry and (bEntry.sortKey or bEntry.display or bEntry.name) or "")
				if aKey <= bKey then
					work[write] = aEntry
					a += 1
				else
					work[write] = bEntry
					b += 1
				end
				write += 1
				NAmanage.cmdYield(write, 24)
			end
			while a <= middle do
				work[write] = entries[a]
				a += 1
				write += 1
				NAmanage.cmdYield(write, 24)
			end
			while b <= right do
				work[write] = entries[b]
				b += 1
				write += 1
				NAmanage.cmdYield(write, 24)
			end
			left += width * 2
		end
		for index = 1, count do
			entries[index] = work[index]
			work[index] = nil
			NAmanage.cmdYield(index, 36)
		end
		width *= 2
	end
	return entries
end

NAStuff.CommandBuildRevision = tonumber(NAStuff.CommandBuildRevision) or 0
NAStuff.CommandBuildSignatureApplied = NAStuff.CommandBuildSignatureApplied or nil

NAmanage.invalidateCommandBuild = NAmanage.invalidateCommandBuild or function()
	NAStuff.CommandBuildRevision = (tonumber(NAStuff.CommandBuildRevision) or 0) + 1
	NAStuff.CommandBuildSignatureCache = nil
	NAStuff.CommandBuildSignatureCacheRevision = nil
	return NAStuff.CommandBuildRevision
end

NAmanage.getCommandBuildSignature = NAmanage.getCommandBuildSignature or function()
	const revision = tonumber(NAStuff.CommandBuildRevision) or 0
	if NAStuff.CommandBuildSignatureCacheRevision == revision and type(NAStuff.CommandBuildSignatureCache) == "string" then
		return NAStuff.CommandBuildSignatureCache
	end
	const signature = Concat({
		tostring(revision),
		tostring(countDictNA(cmds.Commands)),
		tostring(countDictNA(cmds.Aliases)),
		tostring(countDictNA(cmds.NASAVEDALIASES)),
		tostring(type(NAStuff.CmdIntegrationCommands) == "table" and #NAStuff.CmdIntegrationCommands or 0),
		tostring(type(NAStuff.IYIntegrationCommands) == "table" and #NAStuff.IYIntegrationCommands or 0),
	}, ":")
	NAStuff.CommandBuildSignatureCache = signature
	NAStuff.CommandBuildSignatureCacheRevision = revision
	return signature
end

NAmanage.isCommandDataStale = NAmanage.isCommandDataStale or function()
	const currentSignature = NAmanage.getCommandBuildSignature and NAmanage.getCommandBuildSignature() or nil
	return currentSignature ~= (NAStuff.CommandBuildSignatureApplied or nil)
end

NAmanage.buildCommandDataPackage = function()
	if type(NAmanage.resetCommandWorkBudget) == "function" then
		NAmanage.resetCommandWorkBudget()
	end
	const signature = NAmanage.getCommandBuildSignature and NAmanage.getCommandBuildSignature() or nil
	const entries = {}
	const metaByName = {}
	const used = {}
	const aliasByFunc = {}
	const dataToName = {}
	const aliasOwnerMap = {}
	const savedOwnerMap = {}
	local aliasStep = 0
	local cmdMapStep = 0
	for name, data in cmds.Commands or {} do
		cmdMapStep += 1
		if name then
			dataToName[data] = tostring(name)
		end
		NAmanage.cmdYield(cmdMapStep, 220)
	end
	for alias, data in cmds.Aliases or {} do
		aliasStep += 1
		NAmanage.cmdYield(aliasStep, 180)
		const lowerAlias = Lower(tostring(alias or ""))
		if lowerAlias ~= "" then
			const owner = dataToName[data]
			if owner then
				aliasOwnerMap[lowerAlias] = owner
			end
		end
		const func = type(data) == "table" and data[1]
		if func then
			local bucket = aliasByFunc[func]
			if not bucket then
				bucket = {}
				aliasByFunc[func] = bucket
			end
			bucket[Lower(tostring(alias))] = true
		end
	end
	for alias, original in cmds.NASAVEDALIASES or {} do
		const lowerAlias = Lower(tostring(alias or ""))
		const lowerOriginal = Lower(tostring(original or ""))
		if lowerAlias ~= "" and lowerOriginal ~= "" then
			savedOwnerMap[lowerAlias] = lowerOriginal
		end
	end
	const function resolveCommandDisplay(name, data)
		const dInfo = data and data[2] and data[2][1] or ""
		const func = data and data[1]
		const aliasSet = {}
		const fromFunc = func and aliasByFunc[func]
		if fromFunc then
			for alias in fromFunc do
				aliasSet[alias] = true
			end
		end
		const main = name and Lower(name)
		local prefix, aliasBlock = dInfo:match("^(.-)%s*%((.-)%)$")
		if aliasBlock then
			for a in aliasBlock:gmatch("[^,%s]+") do
				aliasSet[Lower(a)] = true
			end
		end
		const final = {}
		for alias in aliasSet do
			if alias ~= main then
				Insert(final, alias)
			end
		end
		table.sort(final)
		local updatedText
		if prefix then
			updatedText = prefix.." ("..Concat(final, ", ")..")"
		else
			updatedText = dInfo
			if #final > 0 then
				updatedText = updatedText.." ("..Concat(final, ", ")..")"
			end
		end
		return updatedText, final
	end

	const function addNACommand(name, data)
		if not name or name == "" then return end
		local displayText, extraAliases = resolveCommandDisplay(name, data)
		if displayText and displayText ~= "" then
			if type(data[2]) == "table" then
				data[2][1] = displayText
			end
		else
			displayText = (type(data[2]) == "table" and data[2][1]) or name
		end
		const aliasList = {}
		for _, alias in extraAliases or {} do
			Insert(aliasList, alias:lower())
		end
		const commandMeta = (type(data[4]) == "table") and data[4] or {}
		const isPatched = commandMeta.patched == true
		local isPluginCmd, pluginType = NAmanage.IsPluginCommand and NAmanage.IsPluginCommand(name)
		local pluginTag = nil
		if isPluginCmd then
			pluginTag = pluginType or true -- keep a marker even if type is unknown so coloring works
		end
		local finalText = displayText
		if isPluginCmd then
			finalText = finalText.." ["..(pluginType and (pluginType.." plugin") or "plugin").."]"
		end
		if isPatched then
			finalText = NAgui.addPatchedLabel(finalText)
		end
		if isAprilFools() then
			finalText = maybeMock(finalText)
		end
		local desc = ""
		if type(data[2]) == "table" then
			desc = data[2][2] or ""
		end
		if isPatched then
			if desc == "" then
				desc = "Patched / may not work; might work again later or be removed if it stays patched"
			elseif not Lower(desc):find("patched", 1, true) then
				desc = desc.." (patched; might work again later or be removed if it stays patched)"
			end
		end
		used[Lower(name)] = true
		local searchable = NAmanage.stripMarkup(Lower(finalText or displayText or name))
		if #aliasList > 0 then
			searchable = searchable.." "..Concat(aliasList, " ")
		end
		if desc ~= "" then
			searchable = searchable.." "..NAmanage.stripMarkup(Lower(desc))
		end
		if isPatched then
			searchable = searchable.." patched"
		end
		metaByName[name] = {
			origin = "na";
			displayText = finalText;
			usage = displayText;
			argumentHint = type(commandMeta.argumentHint) == "string" and commandMeta.argumentHint or nil;
			searchable = searchable;
			aliases = aliasList;
			pluginType = pluginTag;
			desc = desc;
			requiresArguments = type(data) == "table" and data[3] == true or false;
			patched = isPatched;
		}
		entries[#entries + 1] = {
			name = name;
			display = finalText;
			meta = metaByName[name];
			sortKey = Lower(tostring(finalText or name));
		}
	end

	local cmdStep = 0
	for name, data in cmds.Commands do
		cmdStep += 1
		addNACommand(name, data)
		NAmanage.cmdYield(cmdStep, 120)
	end

	const cmdList = NAStuff.CmdIntegrationCommands
	if type(cmdList) == "table" then
		for cmdInfoIndex, info in cmdList do
			NAmanage.cmdYield(cmdInfoIndex, 120)
			local baseName = info and info.name
			if baseName then
				baseName = tostring(baseName)
			end
			if baseName and baseName ~= "" then
				const canonicalName = "cmd:"..baseName
				const aliases = { Lower(baseName), Lower(canonicalName) }
				const displayAliases = {}
				const seenAliases = {
					[Lower(baseName)] = true;
					[Lower(canonicalName)] = true;
				}
				if type(info.aliases) == "table" then
					for _, alias in info.aliases do
						const rawAlias = tostring(alias or "")
						const lowerAlias = Lower(rawAlias)
						if rawAlias ~= "" and lowerAlias ~= Lower(baseName) then
							if not seenAliases[lowerAlias] then
								seenAliases[lowerAlias] = true
								Insert(aliases, lowerAlias)
							end
							const explicitAlias = "cmd:"..rawAlias
							const lowerExplicitAlias = Lower(explicitAlias)
							if not seenAliases[lowerExplicitAlias] then
								seenAliases[lowerExplicitAlias] = true
								Insert(aliases, lowerExplicitAlias)
								Insert(displayAliases, explicitAlias)
							end
						end
					end
				end
				local usage = canonicalName
				const argumentHints = {}
				if type(info.arguments) == "table" then
					for index, argument in info.arguments do
						local argumentName = type(argument) == "table" and tostring(argument.name or argument.type or "arg"..tostring(index)) or "arg"..tostring(index)
						if argumentName == "" then
							argumentName = "arg"..tostring(index)
						end
						Insert(argumentHints, "<"..argumentName..">")
					end
				end
				if #argumentHints > 0 then
					usage = usage.." "..Concat(argumentHints, " ")
				end
				const sourceDesc = type(info.desc) == "string" and info.desc or ""
				const descParts = { "Run: "..usage }
				if #displayAliases > 0 then
					Insert(descParts, "Aliases: "..Concat(displayAliases, ", "))
				end
				if sourceDesc ~= "" then
					Insert(descParts, sourceDesc)
				end
				const desc = Concat(descParts, "\n")
				local finalText = "[Cmd] "..canonicalName
				if #displayAliases > 0 then
					finalText = finalText.." ("..Concat(displayAliases, ", ")..")"
				end
				local searchable = NAmanage.stripMarkup(Lower(finalText.." "..baseName))
				if #aliases > 0 then
					searchable = searchable.." "..Concat(aliases, " ")
				end
				if sourceDesc ~= "" then
					searchable = searchable.." "..NAmanage.stripMarkup(Lower(sourceDesc))
				end
				used[Lower(canonicalName)] = true
				metaByName[canonicalName] = {
					origin = "cmd";
					displayText = finalText;
					searchable = searchable;
					aliases = aliases;
					sourceName = baseName;
					duplicate = used[Lower(baseName)] == true;
					usage = usage;
					requiresArguments = #argumentHints > 0 or info.requiresArguments == true or info.RequiresArguments == true;
					desc = desc;
				}
				entries[#entries + 1] = {
					name = canonicalName;
					display = finalText;
					meta = metaByName[canonicalName];
					sortKey = Lower(tostring(finalText));
				}
			end
		end
	end

	const iyList = NAStuff.IYIntegrationCommands
	if type(iyList) == "table" then
		for iyInfoIndex, info in iyList do
			NAmanage.cmdYield(iyInfoIndex, 120)
			local baseName = info and info.name
			if baseName then baseName = tostring(baseName) end
			if baseName and baseName ~= "" then
				const canonicalName = "iy:"..baseName
				const aliases = { Lower(baseName), Lower(canonicalName) }
				const displayAliases = {}
				const seenAliases = { [Lower(baseName)] = true; [Lower(canonicalName)] = true; }
				if type(info.aliases) == "table" then
					for _, alias in info.aliases do
						const rawAlias = tostring(alias or "")
						const lowerAlias = Lower(rawAlias)
						if rawAlias ~= "" and lowerAlias ~= Lower(baseName) then
							if not seenAliases[lowerAlias] then seenAliases[lowerAlias] = true; Insert(aliases, lowerAlias) end
							const explicitAlias = "iy:"..rawAlias
							const lowerExplicitAlias = Lower(explicitAlias)
							if not seenAliases[lowerExplicitAlias] then
								seenAliases[lowerExplicitAlias] = true
								Insert(aliases, lowerExplicitAlias)
								Insert(displayAliases, explicitAlias)
							end
						end
					end
				end
				local usage = canonicalName
				const argumentHints = {}
				if type(info.arguments) == "table" then
					for index, argument in info.arguments do
						local argumentName = type(argument) == "table" and tostring(argument.name or argument.type or "arg"..tostring(index)) or "arg"..tostring(index)
						if argumentName == "" then argumentName = "arg"..tostring(index) end
						Insert(argumentHints, "<"..argumentName..">")
					end
				end
				if #argumentHints > 0 then usage = usage.." "..Concat(argumentHints, " ") end
				const sourceDesc = type(info.desc) == "string" and info.desc or ""
				const descParts = { "Run: "..usage }
				if #displayAliases > 0 then Insert(descParts, "Aliases: "..Concat(displayAliases, ", ")) end
				if sourceDesc ~= "" then Insert(descParts, sourceDesc) end
				const desc = Concat(descParts, "\n")
				local finalText = "[IY] "..canonicalName
				if #displayAliases > 0 then finalText = finalText.." ("..Concat(displayAliases, ", ")..")" end
				local searchable = NAmanage.stripMarkup(Lower(finalText.." "..baseName))
				if #aliases > 0 then searchable = searchable.." "..Concat(aliases, " ") end
				if sourceDesc ~= "" then searchable = searchable.." "..NAmanage.stripMarkup(Lower(sourceDesc)) end
				used[Lower(canonicalName)] = true
				metaByName[canonicalName] = {
					origin = "iy";
					displayText = finalText;
					searchable = searchable;
					aliases = aliases;
					sourceName = baseName;
					duplicate = used[Lower(baseName)] == true;
					usage = usage;
					requiresArguments = #argumentHints > 0 or info.requiresArguments == true or info.RequiresArguments == true;
					desc = desc;
				}
				entries[#entries + 1] = { name = canonicalName; display = finalText; meta = metaByName[canonicalName]; sortKey = Lower(tostring(finalText)); }
			end
		end
	end

	if type(NAmanage.sortCommandEntries) == "function" then
		NAmanage.sortCommandEntries(entries)
	else
		table.sort(entries, function(a, b)
			return tostring(a.sortKey or a.display or a.name) < tostring(b.sortKey or b.display or b.name)
		end)
	end

	const searchEntries = {}
	const defaultEntryMap = {}
	const defaultTargets = {}
	for _, cmdName in defaultBarCommands or {} do
		const lowerCmd = Lower(tostring(cmdName or ""))
		if lowerCmd ~= "" then
			defaultTargets[lowerCmd] = true
		end
	end
	for i = 1, #entries do
		NAmanage.cmdYield(i, 180)
		const entry = entries[i]
		const cmdName = entry and entry.name
		if cmdName then
			const meta = entry.meta or metaByName[cmdName] or {}
			const lowerName = Lower(tostring(cmdName))
			const extraAliases = {}
			if type(meta.aliases) == "table" then
				for j = 1, #meta.aliases do
					const aliasText = Lower(tostring(meta.aliases[j] or ""))
					if aliasText ~= "" then
						extraAliases[#extraAliases + 1] = aliasText
						if defaultTargets[aliasText] and not defaultEntryMap[aliasText] then
							defaultEntryMap[aliasText] = entry
						end
					end
				end
			end
			if defaultTargets[lowerName] and not defaultEntryMap[lowerName] then
				defaultEntryMap[lowerName] = entry
			end
			searchEntries[#searchEntries + 1] = {
				name = cmdName,
				lowerName = lowerName,
				searchable = meta.searchable or NAmanage.stripMarkup(Lower(tostring(entry.display or cmdName))),
				extraAliases = extraAliases,
				display = entry.display,
				meta = meta,
			}
		end
	end

	return {
		signature = signature;
		totalCount = NAmanage.totalCommandCount and NAmanage.totalCommandCount() or #entries;
		entries = entries;
		metaByName = metaByName;
		searchEntries = searchEntries;
		aliasOwnerMap = aliasOwnerMap;
		savedOwnerMap = savedOwnerMap;
		defaultEntryMap = defaultEntryMap;
	}
end

NAmanage.buildCommandEntries=function()
	const package = NAmanage.buildCommandDataPackage()
	NAStuff.AutofillMetaByName = package and package.metaByName or {}
	return package and package.entries or {}, package and package.metaByName or {}
end

NAmanage.totalCommandCount=function()
	local count = countDictNA(cmds.Commands)
	if type(NAStuff.CmdIntegrationCommands) == "table" then
		count = count + #NAStuff.CmdIntegrationCommands
	end
	if type(NAStuff.IYIntegrationCommands) == "table" then
		count = count + #NAStuff.IYIntegrationCommands
	end
	return count
end
COMMAND_LIST_TOP_PADDING = 5
COMMAND_OVERSCAN_ROWS = 8
COMMAND_MIN_VISIBLE_ROWS = 18

NAmanage.cmdStatic = function()
	return false
end

NAmanage.vpSize = function()
	const sg = NAStuff and NAStuff.NASCREENGUI
	local vp = nil
	if sg and sg.AbsoluteSize then
		vp = sg.AbsoluteSize
	end
	if (not vp or vp.X <= 0 or vp.Y <= 0) and Services.Workspace.CurrentCamera then
		vp = Services.Workspace.CurrentCamera.ViewportSize
	end
	vp = vp or Vector2.new(1280, 720)

	local scale = 1
	const scaler = NAUIMANAGER and NAUIMANAGER.AUTOSCALER
	if scaler then
		scale = tonumber(scaler.Scale) or 1
	end
	if not scale or scale <= 0 then
		scale = 1
	end

	return Vector2.new(math.max(1, vp.X / scale), math.max(1, vp.Y / scale))
end

NAmanage.virtView = function(sf, viewH, totalH, minH)
	const floorH = math.max(1, tonumber(minH) or 1)
	local winH = 0
	if sf and NAmanage.GetLogicalWindowSize then
		local ok, logicalWindow = pcall(NAmanage.GetLogicalWindowSize, sf)
		if ok and logicalWindow then
			winH = tonumber(logicalWindow.Y) or 0
		end
	end

	if not viewH or viewH <= 0 then
		const vp = NAmanage.vpSize and NAmanage.vpSize() or Vector2.new(1280, 720)
		viewH = math.max(floorH, winH, vp.Y * 0.25)
	else
		viewH = math.max(floorH, tonumber(viewH) or 0, winH)
	end

	totalH = math.max(0, tonumber(totalH) or 0)
	local y = 0
	local x = 0
	if sf then
		const pos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(sf) or sf.CanvasPosition
		x = tonumber(pos.X) or 0
		y = tonumber(pos.Y) or 0
	end

	const maxY = math.max(0, totalH - viewH)
	const nextY = math.clamp(y, 0, maxY)
	if sf and math.abs(nextY - y) > 0.5 then
		y = nextY
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(sf, x, y)
		else
			sf.CanvasPosition = Vector2.new(x, y)
		end
	else
		y = nextY
	end

	return viewH, y
end

NAmanage.cmdResp = function(center)
	const frame = NAUIMANAGER and NAUIMANAGER.commandsFrame
	if not (frame and frame:IsA("GuiObject")) then
		return
	end

	if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
		const container = frame:FindFirstChild("Container")
		if container and container:IsA("GuiObject") then
			container.Visible = false
		end
		return
	end

	const vp = NAmanage.vpSize()
	const margin = (vp.X < 420 or vp.Y < 260) and 8 or 16
	const maxW = math.max(180, vp.X - margin)
	const maxH = math.max(118, vp.Y - margin)
	const minW = math.min(260, math.max(180, maxW))
	const minH = math.min(180, math.max(118, maxH))
	const curW = tonumber(frame.Size.X.Offset) or 300
	const curH = tonumber(frame.Size.Y.Offset) or 320
	const nextW = math.clamp(curW, minW, maxW)
	const nextH = math.clamp(curH, minH, maxH)

	if nextW ~= curW or nextH ~= curH then
		frame.Size = UDim2.new(0, math.floor(nextW + 0.5), 0, math.floor(nextH + 0.5))
	end

	const compact = nextH <= 190 or nextW <= 235
	const container = frame:FindFirstChild("Container")
	if container and container:IsA("GuiObject") then
		container.Visible = true
		container.Size = compact and UDim2.new(1, -10, 1, -42) or UDim2.new(1, -15, 1, -50)
		container.Position = compact and UDim2.new(0.5, 0, 1, -6) or UDim2.new(0.5, 0, 1, -10)

		const filter = container:FindFirstChild("Filter")
		if filter and filter:IsA("GuiObject") then
			filter.Size = compact and UDim2.new(1, -8, 0, 20) or UDim2.new(1, -10, 0, 24)
			filter.Position = compact and UDim2.new(0.5, 0, 0, 4) or UDim2.new(0.5, 0, 0, 5)
			if NAlib and NAlib.isProperty and NAlib.isProperty(filter, "TextSize") then
				filter.TextSize = compact and 14 or 16
			end
		end

		const list = container:FindFirstChild("List")
		if list and list:IsA("GuiObject") then
			list.Position = compact and UDim2.new(0, 4, 0, 27) or UDim2.new(0, 5, 0, 30)
			list.Size = compact and UDim2.new(1, -24, 1, -31) or UDim2.new(1, -28, 1, -35)
		end

		const scrollBar = container:FindFirstChild("CustomScrollBar")
		if scrollBar and scrollBar:IsA("GuiObject") then
			scrollBar.Position = compact and UDim2.new(1, -17, 0, 27) or UDim2.new(1, -18, 0, 30)
			scrollBar.Size = compact and UDim2.new(0, 14, 1, -31) or UDim2.new(0, 16, 1, -35)
			if list and list:IsA("GuiObject") then
				scrollBar.Position = UDim2.new(scrollBar.Position.X.Scale, scrollBar.Position.X.Offset, list.Position.Y.Scale, list.Position.Y.Offset)
				scrollBar.Size = UDim2.new(scrollBar.Size.X.Scale, scrollBar.Size.X.Offset, list.Size.Y.Scale, list.Size.Y.Offset)
			end
		end
	end

	if center and NAmanage.centerFrame then
		NAmanage.centerFrame(frame)
	end
end

NAmanage.Commands_ParseInlineArguments = function(raw)
	const out = {}
	raw = tostring(raw or "")
	if raw == "" then
		return out
	end
	if type(ParseArguments) == "function" then
		local okParse, parsed = pcall(ParseArguments, raw)
		if okParse and type(parsed) == "table" then
			for _, value in parsed do
				out[#out + 1] = value
			end
			return out
		end
	end
	for value in raw:gmatch("%S+") do
		out[#out + 1] = value
	end
	return out
end

NAmanage.Commands_RunInline = function(name, rawArguments)
	name = tostring(name or "")
	if name == "" or type(cmd) ~= "table" or type(cmd.run) ~= "function" then
		return
	end
	const runArgs = { name }
	for _, value in NAmanage.Commands_ParseInlineArguments(rawArguments) do
		runArgs[#runArgs + 1] = value
	end
	SpawnCall(function()
		cmd.run(runArgs)
	end)
end
