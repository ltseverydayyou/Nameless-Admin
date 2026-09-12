NAmanage.dropToolCache=function(tool)
	if typeof(tool) == "Instance" and tool:IsA("Tool") then
		NAmanage.toolCache[tool] = nil
		NAmanage.grabBusy[tool] = nil
		NAmanage.restoreToolCollision(tool)
	end
end

NAmanage.initToolCache=function()
	if NAmanage.toolCacheStarted then
		return
	end

	NAmanage.toolCacheStarted = true
	NAmanage.toolCache = NAmanage.ensureWeakKeyTable(NAmanage.toolCache)
	NAmanage.grabBusy = NAmanage.ensureWeakKeyTable(NAmanage.grabBusy)
	NAmanage.toolGrabCol = NAmanage.ensureWeakKeyTable(NAmanage.toolGrabCol)

	for _, ch in Services.Workspace:GetChildren() do
		NAmanage.scanToolBranch(ch)
	end

	NAlib.connect("grabtools_cache_add", NAmanage.descAdd(Services.Workspace, function(inst)
		NAmanage.scanToolBranch(inst)
		if inst:IsA("Folder") or inst:IsA("Model") then
			Defer(function()
				if inst and inst.Parent then
					NAmanage.scanToolBranch(inst)
				end
			end)
		end
	end, function(inst)
		return inst and (inst:IsA("Tool") or inst:IsA("Folder") or inst:IsA("Model"))
	end))

	NAlib.connect("grabtools_cache_rem", NAmanage.descRem(Services.Workspace, function(inst)
		if inst:IsA("Tool") then
			NAmanage.dropToolCache(inst)
		end
	end, function(inst)
		return inst and inst:IsA("Tool")
	end))

	Spawn(function()
		local scanned = 0
		for _, inst in NAmanage.QueryDescendants(Services.Workspace, "Tool") do
			NAmanage.addToolCache(inst)
			scanned += 1
			if scanned % 2500 == 0 then
				Wait()
			end
		end
		NAmanage.toolCacheReady = true
	end)
end

NAmanage.toolList=function(forceScan)
	NAmanage.initToolCache()

	const list = {}
	const seen = {}
	for tool in NAmanage.toolCache do
		if NAmanage.isDroppedTool(tool) then
			if not seen[tool] then
				seen[tool] = true
				list[#list + 1] = tool
			end
		else
			NAmanage.toolCache[tool] = nil
			NAmanage.grabBusy[tool] = nil
			NAmanage.restoreToolCollision(tool)
		end
	end

	if forceScan ~= true and (#list > 0 or NAmanage.toolCacheReady) then
		return list
	end

	for _, tool in NAmanage.QueryDescendants(Services.Workspace, "Tool") do
		NAmanage.addToolCache(tool)
		if NAmanage.isDroppedTool(tool) and not seen[tool] then
			seen[tool] = true
			list[#list + 1] = tool
		end
	end
	if #list > 0 then
		return list
	end

	for _, ch in Services.Workspace:GetChildren() do
		NAmanage.scanToolBranch(ch)
	end

	for tool in NAmanage.toolCache do
		if NAmanage.isDroppedTool(tool) and not seen[tool] then
			seen[tool] = true
			list[#list + 1] = tool
		end
	end

	return list
end

NAmanage.saveToolCollision=function(tool)
	if not tool or NAmanage.toolGrabCol[tool] then
		return
	end

	const saved = setmetatable({}, { __mode = "k" })
	for _, part in NAmanage.toolParts(tool) do
		local ok, val = pcall(function()
			return part.CanCollide
		end)
		if ok then
			saved[part] = val
			if val ~= false then
				NACaller(function()
					part.CanCollide = false
				end)
			end
		end
	end
	NAmanage.toolGrabCol[tool] = saved
end

NAmanage.restoreToolCollision=function(tool)
	const saved = tool and NAmanage.toolGrabCol[tool]
	if not saved then
		return
	end

	for part, val in saved do
		if part and part.Parent then
			NACaller(function()
				part.CanCollide = val
			end)
		end
	end
	NAmanage.toolGrabCol[tool] = nil
end

NAmanage.touchTool=function(tool, root)
	if not tool or not root then
		return
	end

	for _, part in NAmanage.toolParts(tool) do
		if part and part.Parent and firetouchinterest then
			NACaller(function()
				firetouchinterest(root, part, 0)
				firetouchinterest(part, root, 0)
				firetouchinterest(root, part, 1)
				firetouchinterest(part, root, 1)
			end)
		end
	end
end

NAmanage.pullTool=function(tool, root)
	if not tool or not root then
		return
	end

	const cf = root.CFrame
	local n = 0
	for _, part in NAmanage.toolParts(tool) do
		if part and part.Parent then
			n += 1
			NACaller(function()
				part.AssemblyLinearVelocity = Vector3.zero
				part.AssemblyAngularVelocity = Vector3.zero
				part.CFrame = cf * CFrame.new((n % 3 - 1) * 0.35, 0, -0.7 - (n * 0.03))
			end)
		end
	end
end

NAmanage.grabTool=function(tool, tries)
	if not NAmanage.isDroppedTool(tool) then
		return false
	end
	if NAmanage.grabBusy[tool] then
		return false
	end

	NAmanage.grabBusy[tool] = true
	const wantsPrompt = NAmanage.toolHasPrompt(tool)
	if not wantsPrompt then
		NAmanage.saveToolCollision(tool)
	end

	local ok = false
	tries = tonumber(tries) or 6

	for _ = 1, tries do
		const char = getChar()
		const hum = char and getHum(char)
		const root = char and getRoot(char)

		if not (char and hum and root) then
			break
		end

		if not NAmanage.isDroppedTool(tool) then
			ok = NAmanage.isOwnPackTool(tool)
			break
		end

		if wantsPrompt then
			local fired, picked = NAmanage.fireToolPrompts(tool, 0.12, 2)
			if picked then
				ok = true
				break
			end

			if fired and not picked then
				_, picked = NAmanage.fireToolPromptsFromCharacter(tool)
				if picked then
					ok = true
					break
				end
			end

			if NAmanage.touchEquipTool(tool, root, hum, 0.08) then
				ok = true
				break
			end
		else
			NAmanage.pullTool(tool, root)
			NAmanage.touchTool(tool, root)
		end

		if NAmanage.isOwnPackTool(tool) then
			ok = true
			break
		end

		NACaller(function()
			hum:EquipTool(tool)
		end)

		if NAmanage.isOwnPackTool(tool) then
			ok = true
			break
		end

		Defer(function()
			const c = getChar()
			const r = c and getRoot(c)
			const h = c and getHum(c)
			if tool and r and NAmanage.isDroppedTool(tool) then
				if wantsPrompt then
					local fired, picked = NAmanage.fireToolPrompts(tool, 0.12, 2)
					if not picked then
						if fired then
							NAmanage.fireToolPromptsFromCharacter(tool)
						end
						NAmanage.touchEquipTool(tool, r, h, 0.08)
					end
				else
					NAmanage.pullTool(tool, r)
					NAmanage.touchTool(tool, r)
				end
			end
		end)

		Defer(function()
			const c = getChar()
			const h = c and getHum(c)
			const r = c and getRoot(c)
			if tool and h and r and NAmanage.isDroppedTool(tool) then
				if wantsPrompt then
					local fired, picked = NAmanage.fireToolPrompts(tool, 0.12, 2)
					if not picked then
						if fired then
							NAmanage.fireToolPromptsFromCharacter(tool)
						end
						NAmanage.touchEquipTool(tool, r, h, 0.08)
					end
				else
					NAmanage.pullTool(tool, r)
					NAmanage.touchTool(tool, r)
				end
			end
		end)

		Wait(0.01)
	end

	ok = ok or NAmanage.isOwnPackTool(tool)
	NAmanage.grabBusy[tool] = nil
	NAmanage.restoreToolCollision(tool)

	if ok then
		NAmanage.toolCache[tool] = nil
	end

	return ok
end

NAmanage.parseGrabToolArgs=function(forceQuery, ...)
	const packed = table.pack(...)
	const args = {}
	for index = 1, packed.n do
		const text = tostring(packed[index] or ""):match("^%s*(.-)%s*$") or ""
		if text ~= "" then args[#args + 1] = text end
	end

	local range
	if #args > 0 then
		const firstNumber = tonumber(args[1])
		const lastNumber = tonumber(args[#args])
		if forceQuery ~= true and firstNumber and firstNumber > 0 then
			range = firstNumber
			table.remove(args, 1)
		elseif #args > 1 and lastNumber and lastNumber > 0 then
			range = lastNumber
			table.remove(args, #args)
		elseif #args > 1 and firstNumber and firstNumber > 0 then
			range = firstNumber
			table.remove(args, 1)
		end
	end

	const query = (Concat(args, " "):match("^%s*(.-)%s*$") or "")
	return range, query
end

NAmanage.toolGrabNameMatches=function(tool, query, partial)
	query = tostring(query or "")
	if query == "" then return true end
	const name = Lower(tostring(tool and tool.Name or ""))
	const needle = Lower(query)
	if partial == true then
		return string.find(name, needle, 1, true) ~= nil
	end
	return name == needle
end

NAmanage.grabAllTools=function(range, query, partial, preserveEquipped)
	const char = getChar()
	const hum = char and getHum(char)
	const root = char and getRoot(char)
	if not hum or not root then return 0, 0 end

	range = tonumber(range)
	query = tostring(query or ""):match("^%s*(.-)%s*$") or ""
	const useRange = range and range > 0
	const keepEquipped = preserveEquipped == true
	const equippedTool = keepEquipped and char:FindFirstChildOfClass("Tool") or nil
	const hadEquippedTool = equippedTool ~= nil

	local count = 0
	local matched = 0
	for _, tool in NAmanage.QueryDescendants(Services.Workspace, "Tool") do
		if NAmanage.toolGrabNameMatches(tool, query, partial) then
			if useRange then
				const handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
				if handle and (handle.Position - root.Position).Magnitude <= range then
					matched += 1
					if NACaller(function() hum:EquipTool(tool) end) then count += 1 end
				end
			else
				matched += 1
				if NACaller(function() hum:EquipTool(tool) end) then count += 1 end
			end
		end
	end

	if keepEquipped then
		const currentChar = getChar()
		const currentHum = currentChar and getHum(currentChar)
		const currentBackpack = getBp()
		if currentHum then
			if equippedTool and equippedTool.Parent and (equippedTool.Parent == currentChar or equippedTool.Parent == currentBackpack) then
				if equippedTool.Parent ~= currentChar then
					NACaller(function() currentHum:EquipTool(equippedTool) end)
				end
			elseif not hadEquippedTool then
				NACaller(function() currentHum:UnequipTools() end)
			end
		end
	end

	return count, matched
end

NAmanage.notifyGrabToolsResult=function(count, matched, range, query, partial)
	query = tostring(query or "")
	if count > 0 then
		local text = ("Grabbed %d tool%s"):format(count, count == 1 and "" or "s")
		if query ~= "" then
			text ..= partial == true and (" matching '%s'"):format(query) or (" named '%s'"):format(query)
		end
		if range and range > 0 then text ..= (" within %d studs"):format(range) end
		DebugNotif(text, 2)
	elseif query ~= "" and matched == 0 then
		DebugNotif((partial == true and "No tools matched '" or "No tool named '")..query.."'", 2)
	else
		DebugNotif("No tools to grab", 2)
	end
end

cmd.add({"grabtools","gtools","gtls"},{"grabtools [tool name] [range]","Grabs dropped tools, optionally filtering by exact tool name"},function(...)
	const range, query = NAmanage.parseGrabToolArgs(false, ...)
	const count, matched = NAmanage.grabAllTools(range, query, false)
	NAmanage.notifyGrabToolsResult(count, matched, range, query, false)
end)

cmd.add({"grabtoolsfind","gtoolsfind","gtlsfind","grabfind"},{"grabtoolsfind <tool name> [range]","Grabs dropped tools whose names contain the given text"},function(...)
	const range, query = NAmanage.parseGrabToolArgs(true, ...)
	if query == "" then
		DebugNotif("Usage: grabtoolsfind <tool name> [range]", 3)
		return
	end
	const count, matched = NAmanage.grabAllTools(range, query, true)
	NAmanage.notifyGrabToolsResult(count, matched, range, query, true)
end)

cmd.add({"loopgrabtools","loopgrab","lgtools","lgtls","lgrab","lg"},{"loopgrabtools [range]","Loop grabs dropped tools without changing your equipped tool"},function(...)
	if loopgrab then
		DebugNotif("Loop grab already running", 2)
		return
	end
	const firstArg = ...
	const range = tonumber(firstArg)

	loopgrab = true
	DebugNotif("Started loop grabbing tools", 2)
	SpawnCall(function()
		while loopgrab do
			NAmanage.grabAllTools(range, nil, false, true)
			Wait(1)
		end
		DebugNotif("Stopped loop grabbing tools", 2)
	end)
end)

cmd.add({"unloopgrabtools","unloopgrab","unlgtools","unlgtls","unlgrab","unlg"},{"unloopgrabtools","Stops the loop grab command"},function()
	if not loopgrab then
		DebugNotif("Loop grab is not running", 2)
		return
	end
	loopgrab = false
end)

cmd.add({"dance"},{"dance","Does a random dance"},function()
	dances={"248263260","27789359","45834924","28488254","33796059","30196114","52155728"}
	if getChar():FindFirstChildOfClass('Humanoid').RigType==Enum.HumanoidRigType.R15 then
		dances={"4555808220","4555782893","3333432454","4049037604"}
	end
	if theanim then
		theanim:Stop()
		theanim:Destroy()
		const animation=InstanceNew("Animation")
		animation.AnimationId="rbxassetid://"..dances[math.random(1,#dances)]
		theanim=getChar():FindFirstChildOfClass('Humanoid'):LoadAnimation(animation)
		theanim:Play()
	else
		const animation=InstanceNew("Animation")
		animation.AnimationId="rbxassetid://"..dances[math.random(1,#dances)]
		theanim=getChar():FindFirstChildOfClass('Humanoid'):LoadAnimation(animation)
		theanim:Play()
	end
end)

cmd.add({"undance"},{"undance","Stops the dance command"},function()
	theanim:Stop()
	theanim:Destroy()
end)

cmd.add({"animspoofer","animationspoofer","spoofanim","animspoof"},{"animspoofer (animationspoofer, spoofanim, animspoof)","Loads up an animation spoofer,spoofs animations that use rbxassetid"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Animation%20Spoofer")
end)

cmd.add({"badgeviewer", "badgeview", "bviewer","badgev","bv"},{"badgeviewer (badgeview, bviewer, badgev, bv)","loads up a badge viewer UI that views all badges in the game you're in"},function()
	const BadgeService = SafeGetService("BadgeService",false)
	const Player = Services.Players.LocalPlayer

	const COLORS = {
		PANEL = Color3.fromRGB(28, 28, 32),
		TOP = Color3.fromRGB(24, 24, 26),
		TEXT = Color3.fromRGB(240, 240, 240),
		MUTED = Color3.fromRGB(180, 180, 185),
		STROKE = Color3.fromRGB(60, 60, 65),
		OWNED = Color3.fromRGB(65, 200, 120),
		BAD = Color3.fromRGB(255, 90, 90),
		BUTTON = Color3.fromRGB(34, 34, 38),
		BUTTON_DARK = Color3.fromRGB(44, 44, 48),
	}

	const OWNERSHIP_CACHE = _na_env.__BadgeOwnershipCache or {}
	_na_env.__BadgeOwnershipCache = OWNERSHIP_CACHE
	const CACHE_TTL_SECS = 600

	const function cacheGet(userId, badgeId)
		const u = OWNERSHIP_CACHE[userId]
		if not u then return nil end
		const e = u[badgeId]
		if not e then return nil end
		if os.time() - e.t > CACHE_TTL_SECS then return nil end
		return e.v
	end

	const function cachePut(userId, badgeId, value)
		OWNERSHIP_CACHE[userId] = OWNERSHIP_CACHE[userId] or {}
		OWNERSHIP_CACHE[userId][badgeId] = { v = value, t = os.time() }
	end

	const function checkBadgesViaAwardedDates(userId, badgeIds)
		const pending = {}
		const results = {}

		for _, badgeId in badgeIds do
			const cached = cacheGet(userId, badgeId)
			if cached ~= nil then
				results[badgeId] = cached
			else
				results[badgeId] = false
				Insert(pending, badgeId)
			end
		end

		if #pending == 0 then
			return true, results
		end

		const queryIds = {}
		for _, badgeId in pending do
			Insert(queryIds, tostring(badgeId))
		end

		const url = ("https://badges.roblox.com/v1/users/%d/badges/awarded-dates?badgeIds=%s"):format(
			tonumber(userId) or 0,
			Services.HttpService:UrlEncode(Concat(queryIds, ","))
		)
		const data = NAmanage.FetchRobloxApiJSON(url, { Timeout = 6 })
		if type(data) ~= "table" or type(data.data) ~= "table" then
			return false, nil
		end

		for _, entry in data.data do
			const badgeId = tonumber(entry and (entry.badgeId or entry.id))
			if badgeId then
				results[badgeId] = true
			end
		end

		for _, badgeId in pending do
			cachePut(userId, badgeId, results[badgeId] == true)
		end

		return true, results
	end

	const function checkBadgesBatchWithRetry(userId, badgeIds)
		local okApi, apiResults = checkBadgesViaAwardedDates(userId, badgeIds)
		if okApi and apiResults then
			return true, apiResults
		end

		if type(BadgeService.CheckUserBadgesAsync) ~= "function" then
			return false, nil
		end

		const results = {}
		for _, badgeId in badgeIds do
			results[badgeId] = false
		end

		local processedAny = false
		for startIndex = 1, #badgeIds, 10 do
			const chunk = {}
			for i = startIndex, math.min(startIndex + 9, #badgeIds) do
				Insert(chunk, badgeIds[i])
			end

			local tries, delay = 0, 1
			local chunkOk = false
			while tries < 3 do
				tries += 1
				local ok, ownedIds = pcall(BadgeService.CheckUserBadgesAsync, BadgeService, userId, chunk)
				if ok then
					for _, ownedId in ownedIds or {} do
						results[ownedId] = true
					end
					chunkOk = true
					processedAny = true
					break
				end
				Wait(delay)
				delay = math.min(delay * 1.8, 6)
			end

			if not chunkOk then
				return false, nil
			end
		end

		for _, badgeId in badgeIds do
			cachePut(userId, badgeId, results[badgeId] == true)
		end

		return processedAny, results
	end

	const function getBadges()
		local all, cursor = {}, ""
		repeat
			const url = ("https://badges.roblox.com/v1/universes/%d/badges?limit=100&sortOrder=Asc%s"):format(
				GameId,
				cursor ~= "" and "&cursor="..Services.HttpService:UrlEncode(cursor) or ""
			)
			const body = NAmanage.FetchRobloxApiJSON(url, { Timeout = 5 })
			if type(body) ~= "table" then break end
			for _, b in body.data or {} do
				Insert(all, {
					id = b.id,
					name = b.name,
					desc = b.displayDescription or b.description or "",
					icon = b.iconImageId,
					rarity = (b.statistics and b.statistics.winRatePercentage) or 0,
					awarded = (b.statistics and b.statistics.awardedCount) or 0,
					pastDay = (b.statistics and b.statistics.pastDayAwardedCount) or 0,
					universe = (b.awardingUniverse and b.awardingUniverse.name) or "Unknown",
				})
			end
			cursor = body.nextPageCursor or ""
		until cursor == ""
		return all
	end

	const function pill(parent, text, color)
		const p = InstanceNew("TextLabel", parent)
		p.BackgroundColor3 = color
		p.BackgroundTransparency = 0.15
		p.TextColor3 = Color3.new(1,1,1)
		p.Font = Enum.Font.GothamSemibold
		p.Text = text
		p.Size = UDim2.new(0, 0, 0, 0)
		p.AutomaticSize = Enum.AutomaticSize.XY
		p.AnchorPoint = Vector2.new(1,0)
		p.Position = UDim2.new(1, -10, 0, 10)
		p.TextScaled = true
		const pc = InstanceNew("UICorner", p); pc.CornerRadius = UDim.new(0, 6)
		const pad = InstanceNew("UIPadding", p)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.PaddingTop = UDim.new(0, 6)
		pad.PaddingBottom = UDim.new(0, 6)
		const ts = InstanceNew("UITextSizeConstraint", p); ts.MinTextSize = 10; ts.MaxTextSize = 16
		p.Visible = false
		return p
	end

	const function applyOwnedStyle(card, stroke, ownedTag)
		stroke.Color = COLORS.OWNED
		stroke.Transparency = 0
		stroke.Thickness = 2
		card.BackgroundTransparency = 0.1
		card.BackgroundColor3 = Color3.fromRGB(35, 44, 38)
		ownedTag.Visible = true
	end

	const function copyToClipboard(str, msg)
		const s = tostring(str)
		local ok
		if setclipboard then
			setclipboard(s)
			ok = true
		end
		if ok then
			DoNotif(msg or "Copied to clipboard",2)
		end
	end

	const function createBadgeUI(data)
		const sgui = InstanceNew("ScreenGui")
		NAgui.NaProtectUI(sgui)
		sgui.Name = "BadgeViewer"

		const headerH = 70
		const expandedMainSize = IsOnMobile and UDim2.new(0.96,0,0.86,0) or UDim2.new(0.75,0,0.78,0)

		const main = InstanceNew("Frame", sgui)
		main.Size = expandedMainSize
		main.Position = UDim2.new(0.5,0,0.5,0)
		main.AnchorPoint = Vector2.new(0.5,0.5)
		main.BackgroundColor3 = COLORS.PANEL
		main.BackgroundTransparency = 0.08
		main.BorderSizePixel = 0
		main.ClipsDescendants = true
		main.Active = true
		main.Name = "Main"
		const uicorner = InstanceNew("UICorner", main); uicorner.CornerRadius = UDim.new(0, 6)
		const stroke = InstanceNew("UIStroke", main); stroke.Color = COLORS.STROKE; stroke.Thickness = 1; stroke.Transparency = 0.2

		const grad = InstanceNew("UIGradient", main)
		grad.Rotation = 90
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(40,40,46)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,24))
		})
		grad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0.25)
		})

		const header = InstanceNew("Frame", main)
		header.Size = UDim2.new(1, 0, 0, headerH)
		header.BackgroundColor3 = COLORS.TOP
		header.BackgroundTransparency = 0.12

		const headerC = InstanceNew("UICorner", header); headerC.CornerRadius = UDim.new(0, 6)

		const title = InstanceNew("TextLabel", header)
		title.Position = UDim2.new(0, 12, 0, 6)
		title.Size = UDim2.new(0.5, -24, 0, 24)
		title.Text = "Badge Viewer"
		title.Font = Enum.Font.GothamBold
		title.TextColor3 = COLORS.TEXT
		title.BackgroundTransparency = 1
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextScaled = true
		const tsTitle = InstanceNew("UITextSizeConstraint", title); tsTitle.MinTextSize = 14; tsTitle.MaxTextSize = 20

		const statLabel = InstanceNew("TextLabel", header)
		statLabel.Position = UDim2.new(1, -160, 0, 6)
		statLabel.Size = UDim2.new(0, 140, 0, 24)
		statLabel.Text = ""
		statLabel.Font = Enum.Font.Gotham
		statLabel.TextColor3 = COLORS.MUTED
		statLabel.BackgroundTransparency = 1
		statLabel.TextXAlignment = Enum.TextXAlignment.Right
		statLabel.TextScaled = true
		statLabel.ZIndex = 6
		const tsStat = InstanceNew("UITextSizeConstraint", statLabel); tsStat.MinTextSize = 11; tsStat.MaxTextSize = 16

		const fixedBar = InstanceNew("Frame", header)
		fixedBar.AnchorPoint = Vector2.new(1,0)
		fixedBar.Position = UDim2.new(1, -8, 0, headerH-28)
		fixedBar.Size = UDim2.new(0, 72, 0, 22)
		fixedBar.BackgroundTransparency = 1
		fixedBar.ZIndex = 5
		const fixedLayout = InstanceNew("UIListLayout", fixedBar)
		fixedLayout.FillDirection = Enum.FillDirection.Horizontal
		fixedLayout.SortOrder = Enum.SortOrder.LayoutOrder
		fixedLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		fixedLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		fixedLayout.Padding = UDim.new(0, 4)

		const minBtn = InstanceNew("TextButton", fixedBar)
		minBtn.LayoutOrder = 1
		minBtn.Size = UDim2.new(0, 32, 1, 0)
		minBtn.Text = "-"
		minBtn.Font = Enum.Font.Gotham
		minBtn.BackgroundTransparency = 1
		minBtn.TextColor3 = COLORS.MUTED
		minBtn.TextScaled = true
		minBtn.ZIndex = 6
		const tsMin = InstanceNew("UITextSizeConstraint", minBtn); tsMin.MinTextSize = 14; tsMin.MaxTextSize = 22

		const closeBtn = InstanceNew("TextButton", fixedBar)
		closeBtn.LayoutOrder = 2
		closeBtn.Size = UDim2.new(0, 32, 1, 0)
		closeBtn.Text = "X"
		closeBtn.Font = Enum.Font.Gotham
		closeBtn.BackgroundTransparency = 1
		closeBtn.TextColor3 = COLORS.BAD
		closeBtn.TextScaled = true
		closeBtn.ZIndex = 6
		const tsClose = InstanceNew("UITextSizeConstraint", closeBtn); tsClose.MinTextSize = 14; tsClose.MaxTextSize = 22

		const tabsScroll = InstanceNew("ScrollingFrame", header)
		tabsScroll.Name = "TabsScroll"
		tabsScroll.Position = UDim2.new(0, 8, 0, headerH-30)
		tabsScroll.Size = UDim2.new(1, -16, 0, 24)
		tabsScroll.BackgroundTransparency = 1
		tabsScroll.ScrollBarThickness = 4
		tabsScroll.ScrollingDirection = Enum.ScrollingDirection.X
		tabsScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
		tabsScroll.CanvasSize = UDim2.new(0,0,0,0)

		const tabsRow = InstanceNew("Frame", tabsScroll)
		tabsRow.BackgroundTransparency = 1
		tabsRow.AutomaticSize = Enum.AutomaticSize.XY
		tabsRow.Size = UDim2.new(0,0,1,0)
		const tabsLayout = InstanceNew("UIListLayout", tabsRow)
		tabsLayout.FillDirection = Enum.FillDirection.Horizontal
		tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		tabsLayout.Padding = UDim.new(0, 8)

		const function mkBtn(parent, text, w)
			const b = InstanceNew("TextButton", parent)
			b.AutoButtonColor = false
			b.Text = text
			b.Font = Enum.Font.GothamSemibold
			b.TextColor3 = COLORS.TEXT
			b.Size = UDim2.new(0, w, 0, 24)
			b.BackgroundColor3 = COLORS.BUTTON
			b.BackgroundTransparency = 0.2
			b.TextScaled = true
			b.ZIndex = 5
			const c = InstanceNew("UICorner", b); c.CornerRadius = UDim.new(0, 6)
			const s = InstanceNew("UIStroke", b); s.Color = COLORS.STROKE; s.Thickness = 1; s.Transparency = 0.5
			const ts = InstanceNew("UITextSizeConstraint", b); ts.MinTextSize = 10; ts.MaxTextSize = 18

			const function hover(v)
				const target = v and 0.12 or 0.2
				const st = v and 0.35 or 0.5
				__lt.cm("TweenService", "Create", b, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = target}):Play()
				__lt.cm("TweenService", "Create", s, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = st}):Play()
			end

			if IsOnPC then
				NAlib.connect("BadgeViewer", b.MouseEnter:Connect(function() hover(true) end))
				NAlib.connect("BadgeViewer", b.MouseLeave:Connect(function() hover(false) end))
			end

			return b
		end

		const searchWrap = InstanceNew("Frame", tabsRow)
		searchWrap.LayoutOrder = 1
		searchWrap.BackgroundColor3 = COLORS.BUTTON
		searchWrap.BackgroundTransparency = 0.18
		searchWrap.Size = UDim2.new(0, 260, 0, 24)
		const swC = InstanceNew("UICorner", searchWrap); swC.CornerRadius = UDim.new(0, 6)
		const swS = InstanceNew("UIStroke", searchWrap); swS.Color = COLORS.STROKE; swS.Thickness = 1; swS.Transparency = 0.6

		const swPad = InstanceNew("UIPadding", searchWrap)
		swPad.PaddingLeft = UDim.new(0, 8)
		swPad.PaddingRight = UDim.new(0, 8)

		const swLayout = InstanceNew("UIListLayout", searchWrap)
		swLayout.FillDirection = Enum.FillDirection.Horizontal
		swLayout.SortOrder = Enum.SortOrder.LayoutOrder
		swLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		swLayout.Padding = UDim.new(0, 6)

		const searchIcon = InstanceNew("TextLabel", searchWrap)
		searchIcon.LayoutOrder = 1
		searchIcon.BackgroundTransparency = 1
		searchIcon.Text = "🔎"
		searchIcon.Font = Enum.Font.Gotham
		searchIcon.TextColor3 = COLORS.MUTED
		searchIcon.TextScaled = true
		searchIcon.Size = UDim2.new(0, 18, 1, 0)
		const tsSI = InstanceNew("UITextSizeConstraint", searchIcon); tsSI.MinTextSize = 12; tsSI.MaxTextSize = 18

		const search = InstanceNew("TextBox", searchWrap)
		search.LayoutOrder = 2
		search.Size = UDim2.new(1, -70, 1, 0)
		search.PlaceholderText = "Search badges..."
		search.ClearTextOnFocus = false
		search.Text = ""
		search.BackgroundTransparency = 1
		search.TextColor3 = COLORS.TEXT
		search.PlaceholderColor3 = COLORS.MUTED
		search.TextXAlignment = Enum.TextXAlignment.Left
		search.Font = Enum.Font.Gotham
		search.TextScaled = true
		const tsSearch = InstanceNew("UITextSizeConstraint", search); tsSearch.MinTextSize = 10; tsSearch.MaxTextSize = 18

		const clearSearch = InstanceNew("TextButton", searchWrap)
		clearSearch.LayoutOrder = 3
		clearSearch.BackgroundTransparency = 1
		clearSearch.Text = "Clear"
		clearSearch.Font = Enum.Font.GothamSemibold
		clearSearch.TextColor3 = COLORS.MUTED
		clearSearch.TextScaled = true
		clearSearch.Size = UDim2.new(0, 40, 1, 0)
		clearSearch.Visible = false
		const tsClr = InstanceNew("UITextSizeConstraint", clearSearch); tsClr.MinTextSize = 10; tsClr.MaxTextSize = 16

		const ownedOnlyBtn = mkBtn(tabsRow, "Owned: OFF", 110)
		ownedOnlyBtn.LayoutOrder = 2
		const unownedOnlyBtn = mkBtn(tabsRow, "Unowned: OFF", 130)
		unownedOnlyBtn.LayoutOrder = 3
		const layoutToggle = mkBtn(tabsRow, "List", 80)
		layoutToggle.LayoutOrder = 4
		const sortBtn = mkBtn(tabsRow, "Sort: Default", 130)
		sortBtn.LayoutOrder = 5
		const refreshBtn = mkBtn(tabsRow, "Refresh", 100)
		refreshBtn.LayoutOrder = 6

		const content = InstanceNew("Frame", main)
		content.Name = "Content"
		content.Size = UDim2.new(1, 0, 1, -headerH)
		content.Position = UDim2.new(0, 0, 0, headerH)
		content.BackgroundTransparency = 1
		content.ClipsDescendants = true

		const scroll = InstanceNew("ScrollingFrame", content)
		scroll.Size = UDim2.new(1, 0, 1, 0)
		scroll.BackgroundTransparency = 1
		scroll.ScrollBarThickness = 6
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.new(0,0,0,0)

		const pad = InstanceNew("UIPadding", scroll)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.PaddingTop = UDim.new(0, 10)
		pad.PaddingBottom = UDim.new(0, 10)

		const listLayout = InstanceNew("UIListLayout")
		listLayout.Padding = UDim.new(0, 10)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder

		const gridLayout = InstanceNew("UIGridLayout")
		gridLayout.FillDirection = Enum.FillDirection.Horizontal
		gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
		gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		gridLayout.CellPadding = UDim2.new(0.02, 0, 0, 8)
		gridLayout.CellSize = UDim2.new(0.48, 0, 0, 200)

		const loadingOverlay = InstanceNew("Frame", content)
		loadingOverlay.Size = UDim2.new(1,0,1,0)
		loadingOverlay.BackgroundColor3 = Color3.new(0,0,0)
		loadingOverlay.BackgroundTransparency = 0.6
		loadingOverlay.Visible = true
		loadingOverlay.ZIndex = 50
		const loadingBox = InstanceNew("Frame", loadingOverlay)
		loadingBox.AnchorPoint = Vector2.new(0.5,0.5)
		loadingBox.Position = UDim2.new(0.5,0,0.5,0)
		loadingBox.Size = UDim2.new(0,220,0,60)
		loadingBox.BackgroundColor3 = COLORS.PANEL
		loadingBox.BackgroundTransparency = 0.08
		loadingBox.ZIndex = 51
		const lbC = InstanceNew("UICorner", loadingBox); lbC.CornerRadius = UDim.new(0, 6)
		const lbS = InstanceNew("UIStroke", loadingBox); lbS.Color = COLORS.STROKE; lbS.Thickness = 1; lbS.Transparency = 0.3
		const loadingText = InstanceNew("TextLabel", loadingBox)
		loadingText.AnchorPoint = Vector2.new(0.5,0.5)
		loadingText.Position = UDim2.new(0.5,0,0.5,0)
		loadingText.Size = UDim2.new(1,0,1,0)
		loadingText.BackgroundTransparency = 1
		loadingText.Text = "Loading..."
		loadingText.Font = Enum.Font.GothamSemibold
		loadingText.TextColor3 = COLORS.TEXT
		loadingText.TextScaled = true
		loadingText.ZIndex = 52
		const ltSz = InstanceNew("UITextSizeConstraint", loadingText); ltSz.MinTextSize = 12; ltSz.MaxTextSize = 24

		const function updateGridColumns()
			const w = scroll.AbsoluteSize.X
			if w <= 0 then return end
			local cols
			if w < 480 then
				cols = 1
			elseif w < 900 then
				cols = 2
			else
				cols = 3
			end
			const padScale = 0.02
			const widthScale = (1 - padScale * (cols - 1)) / cols
			gridLayout.CellPadding = UDim2.new(padScale,0,0,8)
			gridLayout.CellSize = UDim2.new(widthScale,0,0,200)
		end
		scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGridColumns)
		Defer(updateGridColumns)

		local ownedOnly = false
		local unownedOnly = false
		local useGrid = false
		local ownedMap = {}
		local listCards, gridCards = {}, {}
		local idToCards = {}
		local badgesData = data
		local gridBuilt = false
		local ownershipRunId = 0
		local minimized = false
		local minimizeTweenId = 0
		local loadingOverlayShown = true

		const function setLoadingOverlayVisible(visible)
			loadingOverlayShown = visible and true or false
			loadingOverlay.Visible = loadingOverlayShown and content.Visible and not minimized
		end

		const function mkToolBtn(parent, label, cb)
			const b = InstanceNew("TextButton", parent)
			b.BackgroundColor3 = COLORS.BUTTON_DARK
			b.BackgroundTransparency = 0.18
			b.AutoButtonColor = true
			b.Text = label
			b.Font = Enum.Font.GothamSemibold
			b.TextColor3 = COLORS.TEXT
			b.TextScaled = true
			b.Size = UDim2.new(0, 54, 1, 0)
			const c = InstanceNew("UICorner", b); c.CornerRadius = UDim.new(0, 6)
			const s = InstanceNew("UIStroke", b); s.Color = COLORS.STROKE; s.Thickness = 1; s.Transparency = 0.4
			const ts = InstanceNew("UITextSizeConstraint", b); ts.MinTextSize = 9; ts.MaxTextSize = 13
			NAlib.connect("BadgeViewer", MouseButtonFix(b, cb))
			return b
		end

		const function makeListCard(b)
			const f = InstanceNew("Frame")
			f.Size = UDim2.new(1, 0, 0, 138)
			f.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
			f.BackgroundTransparency = 0.12
			f.ClipsDescendants = true
			const fc = InstanceNew("UICorner", f); fc.CornerRadius = UDim.new(0, 6)
			const fs = InstanceNew("UIStroke", f); fs.Color = COLORS.STROKE; fs.Thickness = 1; fs.Transparency = 0.2

			const img = InstanceNew("ImageLabel", f)
			img.Size = UDim2.new(0, 96, 0, 96)
			img.Position = UDim2.new(0, 14, 0, 16)
			img.BackgroundTransparency = 1
			img.Image = "rbxthumb://type=Asset&id="..tostring(b.icon or 0).."&w=420&h=420"

			const titleL = InstanceNew("TextLabel", f)
			titleL.Position = UDim2.new(0, 120, 0, 14)
			titleL.Size = UDim2.new(1, -140, 0, 24)
			titleL.Text = b.name or ("Badge "..tostring(b.id))
			titleL.TextColor3 = COLORS.TEXT
			titleL.BackgroundTransparency = 1
			titleL.Font = Enum.Font.GothamSemibold
			titleL.TextXAlignment = Enum.TextXAlignment.Left
			titleL.TextTruncate = Enum.TextTruncate.AtEnd
			titleL.TextScaled = true
			const tsLT = InstanceNew("UITextSizeConstraint", titleL); tsLT.MinTextSize = 10; tsLT.MaxTextSize = 18

			const desc = InstanceNew("TextLabel", f)
			desc.Position = UDim2.new(0, 120, 0, 42)
			desc.Size = UDim2.new(1, -140, 0, 34)
			desc.Text = b.desc
			desc.TextWrapped = true
			desc.TextColor3 = COLORS.MUTED
			desc.BackgroundTransparency = 1
			desc.Font = Enum.Font.Gotham
			desc.TextXAlignment = Enum.TextXAlignment.Left
			desc.TextYAlignment = Enum.TextYAlignment.Top
			desc.TextScaled = true
			const tsLD = InstanceNew("UITextSizeConstraint", desc); tsLD.MinTextSize = 9; tsLD.MaxTextSize = 14

			const stat = InstanceNew("TextLabel", f)
			stat.Position = UDim2.new(0, 120, 0, 80)
			stat.Size = UDim2.new(1, -200, 0, 26)
			stat.Text = Format("🎯 %.2f%%   📈 %d   ⏱️ %d   🧭 %s", b.rarity, b.awarded, b.pastDay, b.universe)
			stat.TextColor3 = Color3.fromRGB(160, 160, 165)
			stat.BackgroundTransparency = 1
			stat.Font = Enum.Font.Gotham
			stat.TextXAlignment = Enum.TextXAlignment.Left
			stat.TextScaled = true
			const tsLS = InstanceNew("UITextSizeConstraint", stat); tsLS.MinTextSize = 9; tsLS.MaxTextSize = 13

			const tools = InstanceNew("Frame", f)
			tools.AnchorPoint = Vector2.new(1,1)
			tools.Position = UDim2.new(1, -10, 1, -8)
			tools.Size = UDim2.new(0, 190, 0, 22)
			tools.BackgroundColor3 = COLORS.BUTTON
			tools.BackgroundTransparency = 0.35
			tools.BorderSizePixel = 0
			const tC = InstanceNew("UICorner", tools); tC.CornerRadius = UDim.new(0, 6)
			const tS = InstanceNew("UIStroke", tools); tS.Color = COLORS.STROKE; tS.Thickness = 1; tS.Transparency = 0.7
			const tl = InstanceNew("UIListLayout", tools)
			tl.FillDirection = Enum.FillDirection.Horizontal
			tl.VerticalAlignment = Enum.VerticalAlignment.Center
			tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
			tl.Padding = UDim.new(0, 6)

			mkToolBtn(tools, "Name", function()
				copyToClipboard(b.name or ("Badge "..tostring(b.id)), "Copied badge name")
			end)
			mkToolBtn(tools, "ID", function()
				copyToClipboard(b.id, "Copied badge ID")
			end)
			mkToolBtn(tools, "URL", function()
				copyToClipboard("https://www.roblox.com/badges/"..tostring(b.id), "Copied badge URL")
			end)

			const ownedTag = pill(f, "OWNED", COLORS.OWNED)

			f.Parent = scroll
			const card = {frame=f, data=b, stroke=fs, ownedTag=ownedTag}
			idToCards[b.id] = idToCards[b.id] or {}
			idToCards[b.id].list = card
			Insert(listCards, card)
			return card
		end

		const function makeGridCard(b)
			const f = InstanceNew("Frame")
			f.Size = UDim2.new(1, 0, 0, 200)
			f.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
			f.BackgroundTransparency = 0.12
			f.ClipsDescendants = true
			const fc = InstanceNew("UICorner", f); fc.CornerRadius = UDim.new(0, 6)
			const fs = InstanceNew("UIStroke", f); fs.Color = COLORS.STROKE; fs.Thickness = 1; fs.Transparency = 0.2

			const img = InstanceNew("ImageLabel", f)
			img.AnchorPoint = Vector2.new(0.5,0)
			img.Position = UDim2.new(0.5, 0, 0, 12)
			img.Size = UDim2.new(0, 72, 0, 72)
			img.BackgroundTransparency = 1
			img.Image = "rbxthumb://type=Asset&id="..tostring(b.icon or 0).."&w=420&h=420"

			const titleL = InstanceNew("TextLabel", f)
			titleL.AnchorPoint = Vector2.new(0.5,0)
			titleL.Position = UDim2.new(0.5, 0, 0, 90)
			titleL.Size = UDim2.new(0.9, 0, 0, 20)
			titleL.Text = b.name or ("Badge "..tostring(b.id))
			titleL.TextColor3 = COLORS.TEXT
			titleL.BackgroundTransparency = 1
			titleL.Font = Enum.Font.GothamSemibold
			titleL.TextXAlignment = Enum.TextXAlignment.Center
			titleL.TextTruncate = Enum.TextTruncate.AtEnd
			titleL.TextScaled = true
			const tsGT = InstanceNew("UITextSizeConstraint", titleL); tsGT.MinTextSize = 10; tsGT.MaxTextSize = 16

			const desc = InstanceNew("TextLabel", f)
			desc.AnchorPoint = Vector2.new(0.5,0)
			desc.Position = UDim2.new(0.5, 0, 0, 112)
			desc.Size = UDim2.new(0.9, 0, 0, 30)
			desc.Text = b.desc
			desc.TextWrapped = true
			desc.TextColor3 = COLORS.MUTED
			desc.BackgroundTransparency = 1
			desc.Font = Enum.Font.Gotham
			desc.TextXAlignment = Enum.TextXAlignment.Center
			desc.TextYAlignment = Enum.TextYAlignment.Top
			desc.TextScaled = true
			const tsGD = InstanceNew("UITextSizeConstraint", desc); tsGD.MinTextSize = 9; tsGD.MaxTextSize = 13

			const stat = InstanceNew("TextLabel", f)
			stat.AnchorPoint = Vector2.new(0.5,0)
			stat.Position = UDim2.new(0.5, 0, 0, 144)
			stat.Size = UDim2.new(0.9, 0, 0, 20)
			stat.Text = Format("🎯 %.1f%%  📈 %d  ⏱️ %d", b.rarity, b.awarded, b.pastDay)
			stat.TextColor3 = Color3.fromRGB(160, 160, 165)
			stat.BackgroundTransparency = 1
			stat.Font = Enum.Font.Gotham
			stat.TextXAlignment = Enum.TextXAlignment.Center
			stat.TextScaled = true
			const tsGS = InstanceNew("UITextSizeConstraint", stat); tsGS.MinTextSize = 9; tsGS.MaxTextSize = 13

			const tools = InstanceNew("Frame", f)
			tools.AnchorPoint = Vector2.new(0.5,1)
			tools.Position = UDim2.new(0.5, 0, 1, -10)
			tools.Size = UDim2.new(0.9, 0, 0, 22)
			tools.BackgroundColor3 = COLORS.BUTTON
			tools.BackgroundTransparency = 0.35
			tools.BorderSizePixel = 0
			const tC = InstanceNew("UICorner", tools); tC.CornerRadius = UDim.new(0, 6)
			const tS = InstanceNew("UIStroke", tools); tS.Color = COLORS.STROKE; tS.Thickness = 1; tS.Transparency = 0.7
			const tl = InstanceNew("UIListLayout", tools)
			tl.FillDirection = Enum.FillDirection.Horizontal
			tl.VerticalAlignment = Enum.VerticalAlignment.Center
			tl.HorizontalAlignment = Enum.HorizontalAlignment.Center
			tl.Padding = UDim.new(0, 6)

			mkToolBtn(tools, "Name", function()
				copyToClipboard(b.name or ("Badge "..tostring(b.id)), "Copied badge name")
			end)
			mkToolBtn(tools, "ID", function()
				copyToClipboard(b.id, "Copied badge ID")
			end)
			mkToolBtn(tools, "URL", function()
				copyToClipboard("https://www.roblox.com/badges/"..tostring(b.id), "Copied badge URL")
			end)

			const ownedTag = pill(f, "OWNED", COLORS.OWNED)

			const card = {frame=f, data=b, stroke=fs, ownedTag=ownedTag}
			idToCards[b.id] = idToCards[b.id] or {}
			idToCards[b.id].grid = card
			Insert(gridCards, card)
			return card
		end

		for _, b in badgesData do
			makeListCard(b)
		end

		const function buildGridIfNeeded()
			if gridBuilt then return end
			for _, b in badgesData do
				const c = makeGridCard(b)
				c.frame.Parent = nil
			end
			gridBuilt = true
		end

		const function textContains(h, n)
			if n == "" then return true end
			h = Lower(h or ""); n = Lower(n or "")
			return Find(h, n, 1, true) ~= nil
		end

		const function setStatLabel()
			const q = search.Text
			const src = useGrid and gridCards or listCards
			local visible = 0
			for _, c in src do
				if c.frame.Parent == scroll and c.frame.Visible then
					visible += 1
				end
			end
			const total = #badgesData
			local extra = ""
			if ownedOnly then extra = extra.." • owned" end
			if unownedOnly then extra = extra.." • unowned" end
			if q ~= "" then extra = extra.." • search" end
			statLabel.Text = ("%d/%d%s"):format(visible, total, extra)
		end

		const function applyOwnedVisualsFor(id)
			const pair = idToCards[id]
			if not pair then return end
			if pair.list then applyOwnedStyle(pair.list.frame, pair.list.stroke, pair.list.ownedTag) end
			if pair.grid then applyOwnedStyle(pair.grid.frame, pair.grid.stroke, pair.grid.ownedTag) end
		end

		const function refreshOwnedStylesForAll()
			for id, v in ownedMap do
				if v == true then applyOwnedVisualsFor(id) end
			end
		end

		local sortModeIndex = 1
		local sortMode = "default"
		const sortModes = {
			{id="default", label="Sort: Default"},
			{id="rarityDesc", label="Sort: Rarity ↓"},
			{id="rarityAsc", label="Sort: Rarity ↑"},
			{id="nameAsc", label="Sort: Name A-Z"},
			{id="nameDesc", label="Sort: Name Z-A"},
		}

		const function applySort()
			const arr = {}
			for _, b in badgesData do
				Insert(arr, b)
			end
			table.sort(arr, function(a, b)
				if sortMode == "rarityDesc" then
					return (a.rarity or 0) > (b.rarity or 0)
				elseif sortMode == "rarityAsc" then
					return (a.rarity or 0) < (b.rarity or 0)
				elseif sortMode == "nameAsc" then
					return Lower(a.name or "") < Lower(b.name or "")
				elseif sortMode == "nameDesc" then
					return Lower(a.name or "") > Lower(b.name or "")
				else
					return (a.id or 0) < (b.id or 0)
				end
			end)
			for i, b in arr do
				const pair = idToCards[b.id]
				if pair then
					if pair.list and pair.list.frame then pair.list.frame.LayoutOrder = i end
					if pair.grid and pair.grid.frame then pair.grid.frame.LayoutOrder = i end
				end
			end
		end

		const function applyFilters()
			const q = search.Text
			for _, card in listCards do
				if card.frame.Parent == scroll then
					const id = card.data.id
					local show = textContains(card.data.name.." "..card.data.desc, q)
					if ownedOnly then
						show = show and (ownedMap[id] == true)
					elseif unownedOnly then
						show = show and (ownedMap[id] == false)
					end
					card.frame.Visible = show
				end
			end
			for _, card in gridCards do
				if card.frame.Parent == scroll then
					const id = card.data.id
					local show = textContains(card.data.name.." "..card.data.desc, q)
					if ownedOnly then
						show = show and (ownedMap[id] == true)
					elseif unownedOnly then
						show = show and (ownedMap[id] == false)
					end
					card.frame.Visible = show
				end
			end
			clearSearch.Visible = (search.Text ~= "")
			setStatLabel()
		end

		const function attachLayout()
			listLayout.Parent = nil
			gridLayout.Parent = nil
			for _, c in listCards do c.frame.Parent = nil end
			for _, c in gridCards do c.frame.Parent = nil end
			if useGrid then
				buildGridIfNeeded()
				gridLayout.Parent = scroll
				pad.PaddingLeft = UDim.new(0, 10)
				pad.PaddingRight = UDim.new(0, 10)
				pad.PaddingTop = UDim.new(0, 10)
				pad.PaddingBottom = UDim.new(0, 10)
				for _, c in gridCards do c.frame.Parent = scroll end
				layoutToggle.Text = "Grid"
			else
				listLayout.Parent = scroll
				pad.PaddingLeft = UDim.new(0, 10)
				pad.PaddingRight = UDim.new(0, 10)
				pad.PaddingTop = UDim.new(0, 10)
				pad.PaddingBottom = UDim.new(0, 10)
				for _, c in listCards do c.frame.Parent = scroll end
				layoutToggle.Text = "List"
			end
			updateGridColumns()
			refreshOwnedStylesForAll()
			applySort()
			applyFilters()
		end

		const function setOwnedOnly(v)
			ownedOnly = v and true or false
			if ownedOnly then unownedOnly = false end
			ownedOnlyBtn.Text = ownedOnly and "Owned: ON" or "Owned: OFF"
			unownedOnlyBtn.Text = "Unowned: OFF"
			applyFilters()
		end

		const function setUnownedOnly(v)
			unownedOnly = v and true or false
			if unownedOnly then ownedOnly = false end
			unownedOnlyBtn.Text = unownedOnly and "Unowned: ON" or "Unowned: OFF"
			ownedOnlyBtn.Text = "Owned: OFF"
			applyFilters()
		end

		search:GetPropertyChangedSignal("Text"):Connect(applyFilters)
		MouseButtonFix(clearSearch, function()
			search.Text = ""
		end)
		MouseButtonFix(ownedOnlyBtn, function() setOwnedOnly(not ownedOnly) end)
		MouseButtonFix(unownedOnlyBtn, function() setUnownedOnly(not unownedOnly) end)

		MouseButtonFix(layoutToggle, function()
			useGrid = not useGrid
			attachLayout()
		end)

		MouseButtonFix(sortBtn, function()
			sortModeIndex += 1
			if sortModeIndex > #sortModes then sortModeIndex = 1 end
			sortMode = sortModes[sortModeIndex].id
			sortBtn.Text = sortModes[sortModeIndex].label
			applySort()
			applyFilters()
		end)

		const function minimize()
			if minimized then return end
			minimized = true
			minimizeTweenId += 1
			const tweenId = minimizeTweenId
			scroll.Visible = false
			loadingOverlay.Visible = false
			const tA = __lt.cm("TweenService", "Create", content, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,0)})
			const tB = __lt.cm("TweenService", "Create", main, TweenInfo.new(0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(expandedMainSize.X.Scale, expandedMainSize.X.Offset, 0, headerH)})
			tA:Play(); tB:Play()
			Delay(0.18, function()
				if minimized and minimizeTweenId == tweenId then
					content.Visible = false
				end
			end)
		end
		const function restore()
			if not minimized then return end
			minimized = false
			minimizeTweenId += 1
			const tweenId = minimizeTweenId
			content.Visible = true
			scroll.Visible = false
			loadingOverlay.Visible = false
			const tB = __lt.cm("TweenService", "Create", main, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = expandedMainSize})
			const tA = __lt.cm("TweenService", "Create", content, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1, -headerH)})
			tB:Play(); tA:Play()
			Delay(0.22, function()
				if not minimized and minimizeTweenId == tweenId then
					scroll.Visible = true
					loadingOverlay.Visible = loadingOverlayShown
				end
			end)
		end
		MouseButtonFix(minBtn, function() if minimized then restore() else minimize() end end)

		MouseButtonFix(closeBtn, function()
			const t1 = __lt.cm("TweenService", "Create", main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
				Size = UDim2.new(0.02,0,0.02,0),
				Position = UDim2.new(0.99,0,0.02,0)
			})
			t1:Play(); t1.Completed:Wait()
			sgui:Destroy()
		end)

		NAgui.dragger(main, header)

		const function runOwnershipChecks(dataset)
			ownershipRunId += 1
			const runId = ownershipRunId
			setLoadingOverlayVisible(true)
			const total = #dataset
			loadingText.Text = "Loading..."
			if total == 0 then
				setLoadingOverlayVisible(false)
				loadingText.Text = "Loading..."
				refreshBtn.AutoButtonColor = true
				refreshBtn.Text = "Refresh"
				refreshBtn.Active = true
				return
			end
			const batchSize = 50

			Spawn(function()
				local processed = 0
				local failedBatches = 0
				while processed < total do
					if runId ~= ownershipRunId or not sgui.Parent then
						return
					end

					const badgeIds = {}
					const upper = math.min(processed + batchSize, total)
					for i = processed + 1, upper do
						Insert(badgeIds, dataset[i].id)
					end

					loadingText.Text = ("Loading... %d/%d"):format(processed, total)
					local ok, results = checkBadgesBatchWithRetry(Player.UserId, badgeIds)
					if ok and results then
						for _, badgeId in badgeIds do
							const has = results[badgeId]
							ownedMap[badgeId] = has
							if has == true then
								applyOwnedVisualsFor(badgeId)
							end
						end
					else
						failedBatches += 1
						for _, badgeId in badgeIds do
							ownedMap[badgeId] = nil
						end
					end

					processed = upper
					loadingText.Text = ("Loading... %d/%d"):format(processed, total)
					if ownedOnly or unownedOnly then
						applyFilters()
					else
						setStatLabel()
					end

					if processed < total then
						Wait(0.1)
					end
				end

				if runId ~= ownershipRunId or not sgui.Parent then
					return
				end

				setLoadingOverlayVisible(false)
				loadingText.Text = "Loading..."
				refreshBtn.AutoButtonColor = true
				refreshBtn.Text = "Refresh"
				refreshBtn.Active = true
				setStatLabel()

				if failedBatches > 0 then
					DoNotif("Some badge ownership checks failed", 3)
				end
			end)
		end

		MouseButtonFix(refreshBtn, function()
			if refreshBtn.Active == false then return end
			ownershipRunId += 1
			refreshBtn.Active = false
			refreshBtn.AutoButtonColor = false
			refreshBtn.Text = "Refreshing..."
			setLoadingOverlayVisible(true)
			loadingText.Text = "Loading..."
			for _, c in listCards do if c.frame and c.frame.Parent then c.frame:Destroy() end end
			for _, c in gridCards do if c.frame and c.frame.Parent then c.frame:Destroy() end end
			listCards, gridCards, idToCards, ownedMap = {}, {}, {}, {}
			gridBuilt = false
			ownedOnly = false
			unownedOnly = false
			useGrid = false
			sortModeIndex = 1
			sortMode = "default"
			search.Text = ""
			clearSearch.Visible = false
			ownedOnlyBtn.Text = "Owned: OFF"
			unownedOnlyBtn.Text = "Unowned: OFF"
			layoutToggle.Text = "List"
			sortBtn.Text = "Sort: Default"
			local ok2, res2 = NACaller(getBadges)
			if ok2 then
				badgesData = res2
				for _, b in badgesData do
					makeListCard(b)
				end
				attachLayout()
				runOwnershipChecks(badgesData)
			else
				setLoadingOverlayVisible(false)
				refreshBtn.AutoButtonColor = true
				refreshBtn.Text = "Refresh"
				refreshBtn.Active = true
				DoNotif("Failed to refresh badge data")
			end
		end)

		attachLayout()
		runOwnershipChecks(badgesData)
	end

	local ok, result = NACaller(getBadges)
	if ok then
		const root = NAmanage.guiCHECKINGAHHHHH()
		for _, g in root:GetChildren() do
			if g:IsA("ScreenGui") and g.Name == "BadgeViewer" then g:Destroy() end
		end
		createBadgeUI(result)
	else
		DoNotif("Failed to fetch badge data")
	end
end)

cmd.add({"bodytransparency","btransparency","bodyt"}, {"bodytransparency <number> [part1] [part2] ... (btransparency,bodyt)", "Sets LocalTransparencyModifier on selected body parts (no Head) to a value (0-1). UI supports multi-select."}, function(...)
	const a = {...}
	local vv = nil
	const q = {}
	for i = 1, #a do
		const s = a[i]
		const n = tonumber(s)
		if n ~= nil and vv == nil then
			vv = n
		elseif s ~= nil and tostring(s) ~= "" then
			q[#q+1] = tostring(s)
		end
	end
	if vv == nil then vv = 0.5 end
	if vv < 0 then vv = 0 elseif vv > 1 then vv = 1 end

	const function okp(p)
		if not p or not p.Parent then return false end
		if not p:IsA("BasePart") then return false end
		if Lower(p.Name) == "head" then return false end
		if p:FindFirstAncestorOfClass("Accessory") then return false end
		if p:FindFirstAncestorOfClass("Tool") then return false end
		return true
	end

	local st = _na_env.__na_btr_st
	if type(st) ~= "table" then
		st = {
			ch = nil, d = true, a = nil, r = nil, mp = nil,
			vv = 0, all = false, sel = {}, dirty = true,
			pend = {}, pendF = false,
		}
		_na_env.__na_btr_st = st
	end

	const function setch(ch)
		if st.a then st.a:Disconnect() st.a = nil end
		if st.r then st.r:Disconnect() st.r = nil end
		st.ch = ch
		st.d = true
		st.mp = {}
		if ch then
			st.a = NAmanage.descAdd(ch, function() st.d = true end)
			st.r = NAmanage.descRem(ch, function() st.d = true end)
		end
	end

	const function scan()
		const ch = st.ch
		if not ch then return end
		const mp = {}
		for _,p in NAmanage.QueryDescendants(ch, "Instance") do
			if okp(p) then
				const n = Lower(p.Name)
				mp[n] = mp[n] or {}
				mp[n][#mp[n]+1] = p
			end
		end
		st.mp = mp
		st.d = false
	end

	const function clr()
		const ch = st.ch
		if not ch then return end
		for _,p in NAmanage.QueryDescendants(ch, "Instance") do
			if okp(p) then
				p.LocalTransparencyModifier = 0
			end
		end
	end

	const function apply()
		const ch = getChar() or (Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character)
		if ch ~= st.ch then
			setch(ch)
			if st.ch then
				st.dirty = true
			end
		end
		if st.ch and st.d then
			scan()
		end
		if not st.ch then return end

		if st.dirty then
			clr()
			st.dirty = false
		end

		if st.all then
			for _,t in next, (st.mp or {}) do
				for i = 1, #t do
					const p = t[i]
					if p and p.Parent then
						p.LocalTransparencyModifier = st.vv
					end
				end
			end
			return
		end

		for n, on in next, (st.sel or {}) do
			if on then
				const t = st.mp and st.mp[n]
				if t then
					for i = 1, #t do
						const p = t[i]
						if p and p.Parent then
							p.LocalTransparencyModifier = st.vv
						end
					end
				end
			end
		end
	end

	const function start()
		st.vv = vv
		NAlib.disconnect("body_transparency")

		apply()

		NAlib.connect("body_transparency", Services.RunService.RenderStepped:Connect(function()
			Defer(apply)
		end))
	end

	const function setSel(list, all)
		st.all = all and true or false
		st.sel = {}
		if not st.all then
			for i = 1, #list do
				const n = Lower(tostring(list[i] or ""))
				if n ~= "" and n ~= "head" then
					st.sel[n] = true
				end
			end
		end
		st.dirty = true
		start()
	end

	const function queuePick(name)
		name = tostring(name or "")
		const n = Lower(name)
		if n == "" then return end
		st.pend[n] = true
		if st.pendF then return end
		st.pendF = true
		Defer(function()
			st.pendF = false
			local all = false
			const list = {}
			for k in next, st.pend do
				if k == "__all" or k == "all" or k == "body" then
					all = true
				elseif k ~= "head" then
					list[#list+1] = k
				end
			end
			st.pend = {}
			setSel(list, all)
			DebugNotif("Body transparency "..Format("%.2f", vv).." applied", 1.5)
		end)
	end

	if #q > 0 then
		local all = false
		const list = {}
		for i = 1, #q do
			const n = Lower(q[i])
			if n == "all" or n == "body" then
				all = true
			elseif n ~= "head" then
				list[#list+1] = q[i]
			end
		end
		setSel(list, all)
		DebugNotif("Body transparency "..Format("%.2f", vv).." set", 1.5)
		return
	end

	const ch = getChar() or (Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character)
	const btns = {}

	Insert(btns, { Text = "All", Callback = function() queuePick("__all") end })

	if ch then
		const seen = {}
		for _,p in NAmanage.QueryDescendants(ch, "Instance") do
			if okp(p) then
				const n = p.Name
				if not seen[n] then
					seen[n] = true
					Insert(btns, { Text = n, Callback = function() queuePick(n) end })
				end
			end
		end
	else
		Insert(btns, { Text = "No character", Callback = function() DebugNotif("No character found", 2) end })
	end

	Window({
		Title = "Body Transparency",
		Description = "Pick body parts to apply: "..Format("%.2f", vv),
		Buttons = btns
	})
end, true)

cmd.add({"unbodytransparency","unbtransparency","unbodyt"}, {"unbodytransparency (unbtransparency,unbodyt)", "Stops transparency loop"}, function()
	if not NAlib.isConnected("body_transparency") then
		DebugNotif("No loop running", 2)
		return
	end

	NAlib.disconnect("body_transparency")

	const ch = getChar() or (Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character)
	if ch then
		for _,p in NAmanage.QueryDescendants(ch, "BasePart") do
			if Lower(p.Name) ~= "head" and not p:FindFirstAncestorOfClass("Accessory") and not p:FindFirstAncestorOfClass("Tool") then
				p.LocalTransparencyModifier = 0
			end
		end
	end

	const st = _na_env.__na_btr_st
	if type(st) == "table" then
		st.all = false
		st.sel = {}
		st.pend = {}
		st.pendF = false
		st.dirty = true
	end
end)

NAStuff.charMaterialState = NAStuff.charMaterialState or {
	enabled = false;
	mat = nil;
	ch = nil;
	orig = setmetatable({}, { __mode = "k" });
}

originalIO.charMaterialState=function()
	local st = NAStuff.charMaterialState
	if type(st) ~= "table" then
		st = {
			enabled = false;
			mat = nil;
			ch = nil;
			orig = setmetatable({}, { __mode = "k" });
		}
		NAStuff.charMaterialState = st
	end
	if type(st.orig) ~= "table" then
		st.orig = setmetatable({}, { __mode = "k" })
	end
	return st
end

originalIO.resolveCharMaterial=function(v)
	if typeof(v) == "EnumItem" and v.EnumType == Enum.Material then
		return v
	end
	if v == nil then
		return nil
	end
	const q = tostring(v)
	if q == "" then
		return nil
	end
	const n = tonumber(q)
	const low = Lower(q)
	const key = GSub(low, "[%s_%-%./]", "")
	local fb = nil
	for _, mt in Enum.Material:GetEnumItems() do
		if n and tonumber(mt.Value) == n then
			return mt
		end
		const name = Lower(mt.Name)
		const nkey = GSub(name, "[%s_%-%./]", "")
		if name == low or nkey == key then
			return mt
		end
		if not fb and ((low ~= "" and Find(name, low, 1, true)) or (key ~= "" and Find(nkey, key, 1, true))) then
			fb = mt
		end
	end
	return fb
end

originalIO.applyCharMaterialPart=function(p, mat)
	if typeof(p) ~= "Instance" or not p:IsA("BasePart") or not mat then
		return false
	end
	const st = originalIO.charMaterialState()
	if st.orig[p] == nil then
		local ok, old = pcall(function()
			return p.Material
		end)
		if ok then
			st.orig[p] = old
		end
	end
	const ok = pcall(function()
		p.Material = mat
	end)
	return ok
end

originalIO.applyCharMaterial=function(ch, mat)
	if typeof(ch) ~= "Instance" or not mat then
		return 0
	end
	local c = 0
	for _, p in NAmanage.QueryDescendants(ch, "BasePart") do
		if originalIO.applyCharMaterialPart(p, mat) then
			c += 1
		end
	end
	return c
end

originalIO.bindCharMaterial=function(ch)
	const st = originalIO.charMaterialState()
	NAlib.disconnect("char_material_add")
	st.ch = ch
	if typeof(ch) ~= "Instance" then
		return 0
	end
	const c = originalIO.applyCharMaterial(ch, st.mat)
	NAlib.connect("char_material_add", ch.DescendantAdded:Connect(function(v)
		if st.enabled and st.mat then
			Defer(function()
				originalIO.applyCharMaterialPart(v, st.mat)
			end)
		end
	end))
	return c
end

originalIO.startCharMaterial=function(mat)
	const st = originalIO.charMaterialState()
	if not mat then
		return
	end
	st.enabled = true
	st.mat = mat
	NAlib.disconnect("char_material_char")
	const lp = Services.Players.LocalPlayer
	if lp then
		NAlib.connect("char_material_char", lp.CharacterAdded:Connect(function(ch)
			Defer(function()
				const cur = originalIO.charMaterialState()
				if cur.enabled and cur.mat then
					originalIO.bindCharMaterial(ch)
				end
			end)
		end))
	end
	const ch = getChar() or (lp and lp.Character)
	const c = originalIO.bindCharMaterial(ch)
	DoNotif("Character material set to "..tostring(mat.Name or mat).." ("..tostring(c).." parts)", 2)
end

originalIO.stopCharMaterial=function()
	const st = originalIO.charMaterialState()
	NAlib.disconnect("char_material_char")
	NAlib.disconnect("char_material_add")
	local c = 0
	if type(st.orig) == "table" then
		for p, mat in st.orig do
			if typeof(p) == "Instance" and p.Parent and mat then
				const ok = pcall(function()
					p.Material = mat
				end)
				if ok then
					c += 1
				end
			end
		end
	end
	st.enabled = false
	st.mat = nil
	st.ch = nil
	st.orig = setmetatable({}, { __mode = "k" })
	DoNotif("Character material restored ("..tostring(c).." parts)", 2)
end

cmd.add({"material","mat","charmaterial","cmat","bodymaterial","bmat"}, {"material <material> (mat, charmaterial, cmat, bodymaterial, bmat)", "Sets every BasePart in your character to a selected material"}, function(...)
	const a = {...}
	const target = a[1]
	const btns = {}
	for _, mt in Enum.Material:GetEnumItems() do
		Insert(btns, {
			Text = mt.Name,
			Callback = function()
				originalIO.startCharMaterial(mt)
			end
		})
	end
	if target and target ~= "" then
		const mt = originalIO.resolveCharMaterial(target)
		if mt then
			originalIO.startCharMaterial(mt)
		else
			DebugNotif("No matching material for: "..tostring(target), 3)
		end
		return
	end
	Window({
		Title = "Character Materials",
		Buttons = btns
	})
end)

cmd.add({"unmaterial","unmat","uncharmaterial","uncmat","unbodymaterial","unbmat","resetmaterial","restorematerial"}, {"unmaterial (unmat, uncharmaterial, uncmat, unbodymaterial, unbmat)", "Restores character materials changed by material"}, function()
	const st = originalIO.charMaterialState()
	if not st.enabled and (type(st.orig) ~= "table" or not next(st.orig)) then
		DebugNotif("No character material override running", 2)
		return
	end
	originalIO.stopCharMaterial()
end)

cmd.add({"animationspeed", "animspeed", "aspeed"}, {"animationspeed <speed> (animspeed,aspeed)", "Adjusts the speed of currently playing animations"}, function(speed)
	const targetSpeed = tonumber(speed) or 1

	NAlib.disconnect("animation_speed")

	NAlib.connect("animation_speed", Services.RunService.PreSimulation:Connect(function()
		const character = getChar()
		const humanoid = getHum()
		if humanoid then
			for _, track in humanoid:GetPlayingAnimationTracks() do
				if track and track:IsA("AnimationTrack") then
					track:AdjustSpeed(targetSpeed)
				end
			end
		end
	end))

	DebugNotif("Animation speed set to "..targetSpeed)
end, true)

cmd.add({"unanimationspeed", "unanimspeed", "unaspeed"}, {"unanimationspeed (unanimspeed,unaspeed)", "Stops the animation speed adjustment loop"}, function()
	if NAlib.isConnected("animation_speed") then
		NAlib.disconnect("animation_speed")
		DebugNotif("Animation speed disabled")
	else
		DebugNotif("No active animation speed to disable")
	end
end)

cmd.add({"placeid","pid"},{"placeid (pid)","Copies the PlaceId of the game you're in"},function()
	setclipboard(tostring(PlaceId))

	Wait();

	DebugNotif("Copied the game's PlaceId: "..PlaceId)
end)

cmd.add({"gameid","universeid","gid"},{"gameid (universeid,gid)","Copies the GameId/Universe Id of the game you're in"},function()
	setclipboard(tostring(GameId))

	Wait();

	DebugNotif("Copied the game's GameId: "..GameId)
end)

cmd.add({"firework"}, {"firework", "pop"}, function()
	const character = LocalPlayer.Character
	if not character then return end

	const root = getRoot(character)
	const humanoid = getHum()
	if not root or not humanoid then return end

	const part = InstanceNew("Part")
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.Parent = Services.Workspace

	const weld = InstanceNew("Weld")
	weld.Part0 = part
	weld.Part1 = root
	weld.C0 = CFrame.new()
	weld.Parent = part

	const bv = InstanceNew("BodyVelocity")
	bv.Velocity = Vector3.new(0, 50, 0)
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Parent = part

	const bg = InstanceNew("BodyGyro")
	bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bg.P = 10000
	bg.D = 0
	bg.Parent = part

	const spinTime = 3
	const spinSpeed = 720
	const startTime = tick()
	local angle = 0

	NAlib.connect("firework_spin", Services.RunService.Heartbeat:Connect(function(dt)
		if tick() - startTime > spinTime then
			NAlib.disconnect("firework_spin")
			bv:Destroy()
			bg:Destroy()
			part:Destroy()

			const explosion = InstanceNew("Explosion")
			explosion.Position = root.Position
			explosion.BlastRadius = 6
			explosion.BlastPressure = 500000
			explosion.Parent = Services.Workspace

			humanoid.Health = 0
			return
		end

		angle = angle + math.rad(spinSpeed * dt)
		bg.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, angle, 0)
	end))
end)

cmd.add({"placename","pname"},{"placename (pname)","Copies the game's place name to your clipboard"},function()
	placeNaem = placeName()
	setclipboard(placeNaem)

	Wait();

	DebugNotif("Copied the game's place name: "..placeNaem)
end)

cmd.add({"gameinfo","ginfo"},{"gameinfo (ginfo)","shows info about the game you're playing"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/GameInfo.lua")
end)

cmd.add({"userpreview","userp","upreview"},{"userpreview","show info about a user you name"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/UserInfo.luau")
end)

cmd.add({"copyname", "cname"}, {"copyname <player> (cname)", "Copies the username of the target"}, function(...)
	const usr = ...
	const tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.Name))
		Wait()
		DebugNotif("Copied the username of "..nameChecker(plr))
	end
end, true)

cmd.add({"copydisplay", "cdisplay"}, {"copydisplay <player> (cdisplay)", "Copies the display name of the target"}, function(...)
	const usr = ...
	const tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.DisplayName))
		Wait()
		DebugNotif("Copied the display name of "..nameChecker(plr))
	end
end, true)

cmd.add({"copyid", "id"}, {"copyid <player> (id)", "Copies the UserId of the target"}, function(...)
	const usr = ...
	const tgt = getPlr(usr)

	for _, plr in next, tgt do
		setclipboard(tostring(plr.UserId))
		Wait()
		DebugNotif("Copied the UserId of "..nameChecker(plr))
	end
end, true)

--[ PLAYER ]--
NAmanage.AntiTouchRestoreState = function()
	NAlib.disconnect("antikb")
	NAlib.disconnect("antikb_char")

	const stats = {
		movedRestored = 0;
		movedFailed = 0;
		touchRestored = 0;
		touchFailed = 0;
	}

	const moved = NAStuff._kbMovedParts or {}
	for part, parent in moved do
		if typeof(part) == "Instance" and part.Parent then
			const targetParent = (typeof(parent) == "Instance" and parent.Parent) and parent or Services.Workspace
			const ok = pcall(function()
				part.Parent = targetParent
			end)
			if ok and part.Parent == targetParent then
				stats.movedRestored += 1
			else
				stats.movedFailed += 1
			end
		end
		moved[part] = nil
	end

	const tracked = NAStuff._kbTouchParts or {}
	const original = NAStuff._kbTouchOriginal or {}
	for part in tracked do
		if typeof(part) == "Instance" and part.Parent then
			local originalValue = original[part]
			if originalValue == nil then
				originalValue = true
			end
			const ok = NAlib.setProperty(part, "CanTouch", originalValue)
			if ok and NAlib.isProperty(part, "CanTouch") == originalValue then
				stats.touchRestored += 1
			else
				stats.touchFailed += 1
			end
		end
		tracked[part] = nil
		original[part] = nil
	end

	NAStuff._kbMethod = nil
	return stats
end

NAmanage.AntiTouchEnableRemoveParts = function()
	const policy = SafeGetService("PolicyService")
	const RawPolicyService = __lt.gs("PolicyService")
	if not policy then
		return false, "AntiTouch is unavailable on this client."
	end

	NAStuff._kbMovedParts = NAStuff._kbMovedParts or {}
	const moved = NAStuff._kbMovedParts

	const function moveTouchPart(inst)
		if not (inst and inst:IsA("TouchTransmitter")) then
			return false
		end
		const part = inst.Parent
		const parent = part and part.Parent
		if not (part and parent and parent ~= RawPolicyService) then
			return false
		end
		if moved[part] == nil then
			moved[part] = parent
		end
		const ok = pcall(function()
			part.Parent = policy
		end)
		return ok and part.Parent == RawPolicyService
	end

	NAlib.connect("antikb", NAmanage.wsAdd(function(inst)
		moveTouchPart(inst)
	end))

	local changed = 0
	for _, inst in NAmanage.QueryDescendants(Services.Workspace, "TouchTransmitter") do
		if moveTouchPart(inst) then
			changed += 1
		end
	end

	NAStuff._kbMethod = "remove"
	return true, { changed = changed }
end

NAmanage.AntiTouchEnableCanTouch = function()
	NAStuff._kbTouchParts = NAStuff._kbTouchParts or {}
	NAStuff._kbTouchOriginal = NAStuff._kbTouchOriginal or {}
	const tracked = NAStuff._kbTouchParts
	const original = NAStuff._kbTouchOriginal

	const function disableTouchPart(inst)
		if not (inst and inst:IsA("TouchTransmitter")) then
			return false
		end
		const part = inst.Parent
		if not (part and part:IsA("BasePart")) then
			return false
		end
		if original[part] == nil then
			original[part] = NAlib.isProperty(part, "CanTouch")
		end
		const before = NAlib.isProperty(part, "CanTouch")
		if before ~= false then
			NAlib.setProperty(part, "CanTouch", false)
		end
		tracked[part] = true
		return before ~= false
	end

	NAlib.connect("antikb", NAmanage.wsAdd(function(inst)
		disableTouchPart(inst)
	end))

	NAlib.connect("antikb", Services.RunService.PreSimulation:Connect(function()
		for part in tracked do
			if typeof(part) == "Instance" and part.Parent then
				if NAlib.isProperty(part, "CanTouch") ~= false then
					NAlib.setProperty(part, "CanTouch", false)
				end
			else
				tracked[part] = nil
				original[part] = nil
			end
		end
	end))

	local changed = 0
	for _, inst in NAmanage.QueryDescendants(Services.Workspace, "TouchTransmitter") do
		if disableTouchPart(inst) then
			changed += 1
		end
	end

	NAStuff._kbMethod = "cantouch"
	return true, { changed = changed }
end

NAmanage.AntiTouchNormalizeMethod = function(method)
	if method == nil then
		return nil
	end
	const normalized = Lower(tostring(method)):gsub("[%s_%-]+", "")
	if normalized == "" then
		return nil
	end
	if normalized == "remove" or normalized == "removeparts" or normalized == "delete" or normalized == "loop" or normalized == "silent" or normalized == "autoremove" then
		return "remove"
	end
	if normalized == "cantouch" or normalized == "disabletouch" or normalized == "property" or normalized == "touchoff" or normalized == "autodisable" then
		return "cantouch"
	end
	return nil
end

NAmanage.AntiTouchEnable = function(method, opts)
	opts = opts or {}
	const resolved = NAmanage.AntiTouchNormalizeMethod(method) or "remove"

	NAmanage.AntiTouchRestoreState()

	local ok, result
	if resolved == "cantouch" then
		ok, result = NAmanage.AntiTouchEnableCanTouch()
	else
		ok, result = NAmanage.AntiTouchEnableRemoveParts()
	end
	if not ok then
		if opts.notify ~= false then
			DoNotif(tostring(result or "Unable to enable AntiTouch."), 3, "AntiTouch")
		end
		return false, result
	end

	const changed = (type(result) == "table" and tonumber(result.changed)) or 0
	const methodText = (resolved == "cantouch") and "Disable touchable property" or "Remove parts"
	if opts.notify ~= false then
		if changed > 0 then
			DoNotif(("AntiTouch enabled (%s). Disabled %d touchable part(s)."):format(methodText, changed), 3, "AntiTouch")
		else
			DoNotif(("AntiTouch enabled (%s). No touchable parts found yet (live tracking active)."):format(methodText), 2, "AntiTouch")
		end
	end
	return true, result, resolved
end

cmd.add({"antitouch","antikillbrick","antikb"},{"antitouch [remove/cantouch/loop] (antikillbrick, antikb)","Disables touchable parts"},function(methodArg)
	const directMethod = NAmanage.AntiTouchNormalizeMethod(methodArg)
	if directMethod then
		NAmanage.AntiTouchEnable(directMethod)
		return
	end

	if methodArg ~= nil and tostring(methodArg) ~= "" then
		DoNotif("Unknown AntiTouch method. Use remove, cantouch, or loop.", 2, "AntiTouch")
		return
	end

	if type(Window) ~= "function" then
		NAmanage.AntiTouchEnable("remove")
		return
	end

	Window({
		Title = "AntiTouch Method",
		Description = "Choose which method to use. Both methods live-track new touch parts.",
		Buttons = {
			{
				Text = "Method 1: Remove parts",
				Callback = function()
					NAmanage.AntiTouchEnable("remove")
				end
			},
			{
				Text = "Method 2: Disable touchable property",
				Callback = function()
					NAmanage.AntiTouchEnable("cantouch")
				end
			}
		}
	})
end)

cmd.add({"loopantitouch","loopantikillbrick","loopantikb"},{"loopantitouch (loopantikillbrick, loopantikb)","Enables AntiTouch live tracking without opening the method popup"},function()
	NAmanage.AntiTouchEnable("remove")
end)

cmd.add({"unantitouch","unantikillbrick","unantikb"},{"unantitouch (unantikillbrick, unantikb)","Re-enables touchable parts"},function()
	const stats = NAmanage.AntiTouchRestoreState()
	const restored = (stats.movedRestored or 0) + (stats.touchRestored or 0)
	const failed = (stats.movedFailed or 0) + (stats.touchFailed or 0)
	if restored > 0 or failed > 0 then
		DoNotif(("AntiTouch disabled. Restored %d part(s)%s."):format(restored, failed > 0 and (", failed: "..failed) or ""), 3, "AntiTouch")
	else
		DoNotif("AntiTouch is not active.", 2, "AntiTouch")
	end
end)

cmd.add({"height","hipheight","hh"},{"height <number> (hipheight,hh)","Changes your hipheight"},function(...)
	getHum().HipHeight=(...)
end,true)

cmd.add({"netbypass", "netb"}, {"netbypass (netb)", "Net bypass"}, function()
	Wait()
	DebugNotif("Netbypass enabled")
	const fenv = getfenv()
	const shp = fenv.sethiddenproperty or fenv.set_hidden_property or fenv.sethiddenprop or fenv.set_hidden_prop
	const ssr = fenv.setsimulationradius or fenv.setsimradius or fenv.set_simulation_radius
	net = shp and function(r) shp(lp, "SimulationRadius", r) end or ssr
end)

cmd.add({"day"},{"day","Makes it day"},function()
	Services.Lighting.ClockTime=14
end)

cmd.add({"night"},{"night","Makes it night"},function()
	Services.Lighting.ClockTime=0
end)

cmd.add({"time"}, {"time <number>", "Sets the time"}, function(...)
	const time = {...}
	if time then Services.Lighting.ClockTime = time[1] end
end, true)

cmd.add({"chat", "message"}, {"chat <text> (message)", "Chats for you, useful if you're muted"}, function(...)
	const chatMessage = Concat({...}, " ")
	const chatTarget = "All"
	NAlib.LocalPlayerChat(chatMessage, chatTarget)
end, true)

NA_CHAT_AFFIXES = {
	" :3",
	" >:3",
	" :333",
	" :3c",
	"!11!!",
	"!!!!",
	"!!!",
	"~~",
	"!!??!",
	"?!?!??",
	" >w<",
	" >.<",
	" owo",
	" OwO",
	" UwU",
	" nyaa~",
	" ^w^",
	" <3",
	" x3",
	" muah~",
	" :D",
	" hehe",
	" rawr",
	" mmm~",
	" ✧w✧",
	" hehehehe",
	" chu~",
	" ~nya",
	" kawaii~",
	" yay!!",
	" :DD",
	" *excited*",
	" wheee~~",
	" eheheheheheheh!",
	" heheheheh!!",
	" uheheheheheh!!",
	" uehh",
}

NAmanage.ChatCuteState = function()
	local st = NAStuff.ChatCute
	if type(st) ~= "table" then
		st = {}
		NAStuff.ChatCute = st
	end
	if type(st.opts) ~= "table" then
		st.opts = {}
	end
	if st.opts.split == nil then
		st.opts.split = true
	end
	if st.opts.suffix == nil then
		st.opts.suffix = true
	end
	if type(st.hold) ~= "table" then
		st.hold = {}
	end
	return st
end

NAmanage.ChatCuteText = function(input)
	const st = NAmanage.ChatCuteState()
	local result = tostring(input or "")
	result = GSub(result, "r", "w")
	result = GSub(result, "R", "W")
	result = GSub(result, "l", "w")
	result = GSub(result, "L", "W")
	result = GSub(result, "n", "ny")
	result = GSub(result, "N", "Ny")
	result = GSub(result, "ove", "uv")
	result = GSub(result, "OVE", "UV")
	result = GSub(result, "th", "d")
	result = GSub(result, "Th", "D")
	result = GSub(result, "TH", "D")
	result = GSub(result, "v", "w")
	result = GSub(result, "V", "W")
	result = GSub(result, "ou", "ouw")

	if st.opts.split then
		const chars = {}
		for i = 1, #result do
			const ch = Sub(result, i, i)
			Insert(chars, ch)
			if math.random() > 0.7 and ch:match("[a-zA-Z]") then
				Insert(chars, ch.."-")
			end
		end
		result = Concat(chars)
	end

	if st.opts.suffix then
		result = result..NA_CHAT_AFFIXES[math.random(#NA_CHAT_AFFIXES)]
	end

	return result
end

NAmanage.ChatCutePath = function(root, ...)
	local cur = root
	for i = 1, select("#", ...) do
		if not cur then
			return nil
		end
		cur = cur:FindFirstChild(select(i, ...))
	end
	return cur
end

NAmanage.ChatCuteChannels = function()
	local tcs = Services.TextChatService
	if not tcs and SafeGetService then
		tcs = SafeGetService("TextChatService")
	end
	const chs = tcs and tcs:FindFirstChild("TextChannels")
	if chs then
		return chs
	end
	return nil
end

NAmanage.ChatCuteDefaultChannel = function()
	const chs = NAmanage.ChatCuteChannels()
	if not chs then
		return nil
	end
	return chs:FindFirstChild("RBXGeneral") or chs:FindFirstChild("General") or chs:FindFirstChild("RBXSystem") or chs:FindFirstChildWhichIsA("TextChannel")
end

NAmanage.ChatCuteWhisper = function(recipient)
	if not recipient or recipient == "All" then
		return nil
	end
	const chs = NAmanage.ChatCuteChannels()
	if not chs then
		return nil
	end
	for _, ch in chs:GetChildren() do
		if ch:IsA("TextChannel") and ch.Name:match("^RBXWhisper:") and ch:FindFirstChild(recipient) then
			return ch
		end
	end
	return nil
end

NAmanage.ChatCuteRecipient = function(chip)
	if chip and chip:IsA("TextButton") then
		const txt = tostring(chip.Text or "")
		const who = txt:match("^%[To%s+(.+)%]$")
		if who and who ~= "" then
			const low = who:lower()
			for _, plr in Services.Players:GetPlayers() do
				if tostring(plr.DisplayName or ""):lower() == low or tostring(plr.Name or ""):lower() == low then
					return plr.Name
				end
			end
			return who
		end
	end
	return "All"
end

NAmanage.ChatCuteSend = function(message, recipient)
	const msg = tostring(message or "")
	if msg == "" then
		return false
	end
	recipient = recipient or "All"
	local ok, res = pcall(function()
		const ch = NAmanage.ChatCuteWhisper(recipient) or NAmanage.ChatCuteDefaultChannel()
		if ch then
			return ch:SendAsync(msg)
		end
		if NAlib and type(NAlib.LocalPlayerChat) == "function" then
			return NAlib.LocalPlayerChat(msg, recipient)
		end
	end)
	if not ok then
		DoNotif("Failed to send styled chat", 2)
		return false
	end
	return res ~= nil or true
end

NAmanage.ChatCuteInput = function()
	local cg = Services.CoreGui
	if not cg and SafeGetService then
		cg = SafeGetService("CoreGui")
	end
	const exp = cg and cg:FindFirstChild("ExperienceChat")
	if not exp then
		return nil, nil, nil
	end
	const al = exp:FindFirstChild("appLayout")
	const cb = al and al:FindFirstChild("chatInputBar")
	const bg = cb and cb:FindFirstChild("Background")
	const ct = bg and bg:FindFirstChild("Container")
	const tc = ct and ct:FindFirstChild("TextContainer")
	const bc = tc and tc:FindFirstChild("TextBoxContainer")
	local tb = bc and bc:FindFirstChild("TextBox")
	local btn = ct and ct:FindFirstChild("SendButton")
	const chip = tc and tc:FindFirstChild("TargetChannelChip")
	if not (tb and tb:IsA("TextBox")) then
		tb = nil
	end
	if not (btn and btn:IsA("GuiButton")) then
		btn = nil
	end
	return tb, btn, chip
end

NAmanage.ChatCuteRestore = function()
	const st = NAmanage.ChatCuteState()
	for _, id in {"chatcute_focus", "chatcute_send", "chatcute_send_alt", "chatcute_watch", "uwuify_focus", "uwuify_send", "uwuify_watch"} do
		NAlib.disconnect(id)
	end
	if type(st.hold) == "table" then
		for _, bucket in st.hold do
			if type(bucket) == "table" then
				for _, con in bucket do
					pcall(function()
						if con and con.Enable then
							con:Enable()
						end
					end)
				end
			end
		end
	end
	st.hold = {}
	st.bound = false
	st.tb = nil
	st.btn = nil
	st.chip = nil
end

NAmanage.ChatCuteSubmit = function(tb)
	const st = NAmanage.ChatCuteState()
	if not st.auto or not tb then
		return
	end
	local msg = tostring(tb.Text or "")
	if msg == "" then
		return
	end
	tb.Text = ""
	local _, _, chip = NAmanage.ChatCuteInput()
	const rec = NAmanage.ChatCuteRecipient(chip or st.chip)
	if msg:sub(1, 1) ~= "/" then
		msg = NAmanage.ChatCuteText(msg)
	end
	NAmanage.ChatCuteSend(msg, rec)
end

NAmanage.ChatCuteBind = function()
	const st = NAmanage.ChatCuteState()
	if not st.auto then
		return false
	end
	local tb, btn, chip = NAmanage.ChatCuteInput()
	if not tb or not btn then
		return nil
	end
	if st.bound and st.tb == tb and st.btn == btn and st.tb.Parent and st.btn.Parent then
		st.chip = chip
		return true
	end
	NAmanage.ChatCuteRestore()
	NAlib.connect("chatcute_focus", tb.FocusLost:Connect(function(enter)
		if enter then
			NAmanage.ChatCuteSubmit(tb)
		end
	end))
	if btn.MouseButton1Click then
		NAlib.connect("chatcute_send", btn.MouseButton1Click:Connect(function()
			NAmanage.ChatCuteSubmit(tb)
		end))
	else
		NAlib.connect("chatcute_send", btn.Activated:Connect(function()
			NAmanage.ChatCuteSubmit(tb)
		end))
	end
	st.bound = true
	st.tb = tb
	st.btn = btn
	st.chip = chip
	return true
end

NAmanage.ChatCuteAuto = function(state)
	const st = NAmanage.ChatCuteState()
	if state then
		st.auto = true
		const ok = NAmanage.ChatCuteBind()
		if ok == false then
			return false
		end
		NAlib.disconnect("chatcute_watch")
		local cg = Services.CoreGui
		if not cg and SafeGetService then
			cg = SafeGetService("CoreGui")
		end
		if cg then
			st.watch = true
			NAlib.connect("chatcute_watch", cg.DescendantAdded:Connect(function()
				const now = tick()
				if st.nextTry and st.nextTry > now then
					return
				end
				st.nextTry = now + 0.35
				Delay(0.12, function()
					if NAmanage.ChatCuteState().auto then
						NAmanage.ChatCuteBind()
					end
				end)
			end))
		end
		return true
	end
	st.auto = false
	st.watch = false
	NAlib.disconnect("chatcute_watch")
	NAmanage.ChatCuteRestore()
	return true
end

cmd.add({"uwuify", "cutechat"}, {"uwuify <text> (cutechat)", "Stylizes and sends chat text"}, function(...)
	const msg = Concat({...}, " ")
	if msg == "" then
		DoNotif("Missing text", 2)
		return
	end
	NAmanage.ChatCuteSend(NAmanage.ChatCuteText(msg))
end, true)

cmd.add({"autouwuify", "autocutechat"}, {"autouwuify (autocutechat)", "Stylizes chat input before sending"}, function()
	const ok = NAmanage.ChatCuteAuto(true)
	if ok then
		const st = NAmanage.ChatCuteState()
		if not st.bound then
			DoNotif("Chat styling enabled, waiting for chat UI", 3)
		else
			DoNotif("Chat styling enabled", 2)
		end
	end
end)

cmd.add({"unautouwuify", "unautocutechat"}, {"unautouwuify (unautocutechat)", "Stops chat input styling"}, function()
	NAmanage.ChatCuteAuto(false)
	DoNotif("Chat styling disabled", 2)
end)

cmd.add({"uwustutter", "chatstutter"}, {"uwustutter (chatstutter)", "Enables stutter styling"}, function()
	NAmanage.ChatCuteState().opts.split = true
	DoNotif("Stutter styling enabled", 2)
end)

cmd.add({"unuwustutter", "unchatstutter"}, {"unuwustutter (unchatstutter)", "Disables stutter styling"}, function()
	NAmanage.ChatCuteState().opts.split = false
	DoNotif("Stutter styling disabled", 2)
end)

cmd.add({"uwuaffix", "chataffix"}, {"uwuaffix (chataffix)", "Enables suffix styling"}, function()
	NAmanage.ChatCuteState().opts.suffix = true
	DoNotif("Suffix styling enabled", 2)
end)

cmd.add({"unuwuaffix", "unchataffix"}, {"unuwuaffix (unchataffix)", "Disables suffix styling"}, function()
	NAmanage.ChatCuteState().opts.suffix = false
	DoNotif("Suffix styling disabled", 2)
end)

cmd.add({"privatemessage", "pm"}, {"privatemessage <player> <text> (pm)", "Sends a private message to a player"}, function(...)
	const args = {...}
	const Player = getPlr(args[1])

	for _, plr in next, Player do
		const chatMessage = Concat(args, " ", 2)
		const chatTarget = plr.Name
		const result = NAlib.LocalPlayerChat(chatMessage, chatTarget)
		if result == "Hooking" then
			Wait(.5)
			NAlib.LocalPlayerChat(chatMessage, chatTarget)
		end
	end
end,true)

cmd.add({"mimicchat", "mimic"}, {"mimicchat <player> (mimic)", "Mimics the chat of a player"}, function(name)
	NAlib.disconnect("mimicchat")

	const targets = getPlr(name)
	if #targets == 0 then
		DoNotif("Player not found",2)
		return
	end

	for _, plr in targets do
		DebugNotif("Now mimicking "..plr.Name.."'s chat", 2)

		NAlib.connect("mimicchat", plr.Chatted:Connect(function(msg)
			NAlib.LocalPlayerChat(msg, "All")
		end))
	end
end, true)

cmd.add({"stopmimicchat", "unmimicchat"}, {"stopmimicchat (unmimicchat)", "Stops mimicking a player"}, function()
	NAlib.disconnect("mimicchat")
	DebugNotif("Stopped mimicking", 2)
end, true)

cmd.add({"fixcam", "fix"}, {"fixcam", "Fix your camera"}, function()
	const ws = Services.Workspace
	const plr = Services.Players.LocalPlayer
	local cam = ws.CurrentCamera
	if not cam then return end
	const al = cam:FindFirstChildOfClass("AudioListener")
	if al then
		al.Parent = nil
	end
	cam:Remove()
	Wait(0.1)
	repeat Wait() until plr.Character and ws.CurrentCamera
	cam = ws.CurrentCamera
	if al then
		al.Parent = cam
	end
	cam.CameraSubject = getHum()
	cam.CameraType = "Custom"
	plr.CameraMinZoomDistance = 0.5
	plr.CameraMaxZoomDistance = math.huge
	plr.CameraMode = "Classic"
	getHead(plr.Character).Anchored = false
end)

cmd.add({"fling"}, {"fling <player>", "Fling the given player"}, function(...)
	const RawPlayers = __lt.gs("Players")
	const LocalPlayer = Services.Players.LocalPlayer
	const query = Concat({ ... }, " ")
	if query == "" then
		return DebugNotif("Player name or selector required", 3)
	end
	const LocalUserId = tonumber(LocalPlayer.UserId)
	const function IsLocalTarget(TargetPlayer)
		if TargetPlayer == LocalPlayer then
			return true
		end
		return typeof(TargetPlayer) == "Instance"
			and TargetPlayer:IsA("Player")
			and tonumber(TargetPlayer.UserId) == LocalUserId
	end

	const Character = flingManager.GetPlayerCharacter(LocalPlayer) or LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	const Humanoid = getPlrHum(Character)
	const RootPart = Humanoid and Humanoid.RootPart or getRoot(Character)
	if not RootPart then return end

	const targets = {}
	for _, TargetPlayer in getPlr(query) do
		if typeof(TargetPlayer) == "Instance" and TargetPlayer:IsA("Player") and not IsLocalTarget(TargetPlayer) then
			Insert(targets, TargetPlayer)
		end
	end
	if #targets == 0 then
		return DebugNotif("No players matched: "..query, 3)
	end

	const flingManager       = flingManager
	const OrgDestroyHeight   = Services.Workspace.FallenPartsDestroyHeight

	const function SkidFling(TargetPlayer)
		if IsLocalTarget(TargetPlayer) then
			return
		end

		const Character = flingManager.GetPlayerCharacter(LocalPlayer) or LocalPlayer.Character
		const Humanoid  = getPlrHum(Character)
		const RootPart  = Humanoid and Humanoid.RootPart or getRoot(Character)
		const TChar     = flingManager.GetPlayerCharacter(TargetPlayer)
		if not TChar then return end
		const THumanoid = getPlrHum(TChar)
		const TRootPart = THumanoid and THumanoid.RootPart or getRoot(TChar)
		const THead     = getHead(TChar)
		const Acc       = TChar:FindFirstChildOfClass("Accessory")
		const Handle    = Acc and Acc:FindFirstChild("Handle")
		const function targetChangedOrLost(BasePart)
			const current = flingManager.GetPlayerCharacter(TargetPlayer)
			return not current or current ~= TChar or not BasePart:IsDescendantOf(current)
		end

		if Character and Humanoid and RootPart then
			local flingPart = InstanceNew("Part")
			flingPart.Anchored = false
			flingPart.CanCollide = false
			flingPart.Transparency = 1
			flingPart.Size = Vector3.new(1, 1, 1)
			flingPart.CFrame = RootPart.CFrame
			flingPart.Parent = Services.Workspace

			const flingWeld = InstanceNew("WeldConstraint")
			flingWeld.Part0 = flingPart
			flingWeld.Part1 = RootPart
			flingWeld.Parent = flingPart

			const function cleanupFlingPart()
				if flingPart then
					flingPart:Destroy()
					flingPart = nil
				end
			end

			local _, rootSpeed = flingManager.GetPartVelocity(RootPart)
			if not flingManager.cFlingOldPos or rootSpeed < 50 then
				flingManager.cFlingOldPos = NAmanage.UG_clientCFrame(RootPart) or RootPart.CFrame
			end

			if THead then
				Services.Workspace.CurrentCamera.CameraSubject = THead
			elseif Handle then
				Services.Workspace.CurrentCamera.CameraSubject = Handle
			elseif THumanoid and TRootPart then
				Services.Workspace.CurrentCamera.CameraSubject = THumanoid
			end

			if not TChar:FindFirstChildWhichIsA("BasePart") then
				cleanupFlingPart()
				return
			end

			const function FPos(BasePart, Pos, Ang)
				const targetCFrame = CFrame.new(BasePart.Position) * Pos * Ang
				flingPart.CFrame = targetCFrame
				NAmanage.UG_pivotModel(Character, targetCFrame)
				flingManager.SetFlingVelocity(flingPart)
			end

			const function SFBasePart(BasePart)
				const TimeToWait = 2
				const Time       = tick()
				local Angle      = 0
				repeat
					if RootPart and THumanoid then
						local _, baseSpeed = flingManager.GetPartVelocity(BasePart)
						if baseSpeed < 50 then
							Angle = Angle + 100
							FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection * baseSpeed/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection * baseSpeed/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(2.25,1.5,-2.25) + THumanoid.MoveDirection * baseSpeed/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(-2.25,-1.5,2.25) + THumanoid.MoveDirection * baseSpeed/1.25, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) Wait()
						else
							local _, targetRootSpeed = flingManager.GetPartVelocity(TRootPart)
							FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,-THumanoid.WalkSpeed), CFrame.Angles(0,0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,targetRootSpeed/1.25), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,-targetRootSpeed/1.25), CFrame.Angles(0,0,0)) Wait()
							FPos(BasePart, CFrame.new(0,1.5,targetRootSpeed/1.25), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(-90),0,0)) Wait()
							FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) Wait()
						end
					else
						break
					end
				until targetChangedOrLost(BasePart)
					or TargetPlayer.Parent ~= RawPlayers
					or Humanoid.Health <= 0
					or tick() > Time + TimeToWait
			end

			Services.Workspace.FallenPartsDestroyHeight = 0/0

			const BV = InstanceNew("BodyVelocity")
			BV.Parent    = flingPart
			flingManager.SetMoverFlingVelocity(BV)
			BV.MaxForce  = Vector3.new(1/0,1/0,1/0)

			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

			if TRootPart and THead then
				if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
					SFBasePart(THead)
				else
					SFBasePart(TRootPart)
				end
			elseif TRootPart then
				SFBasePart(TRootPart)
			elseif THead then
				SFBasePart(THead)
			elseif Handle then
				SFBasePart(Handle)
			end

			BV:Destroy()
			cleanupFlingPart()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			Services.Workspace.CurrentCamera.CameraSubject = Humanoid

			repeat
				NAmanage.UG_setRootCFrame(RootPart, flingManager.cFlingOldPos * CFrame.new(0, .5, 0))
				NAmanage.UG_pivotModel(Character, flingManager.cFlingOldPos * CFrame.new(0, .5, 0))
				Humanoid:ChangeState("GettingUp")
				for _, x in next, Character:GetChildren() do
					if x:IsA("BasePart") then
						flingManager.ClearPartVelocity(x)
					end
				end
				Wait()
			until (RootPart.Position - flingManager.cFlingOldPos.p).Magnitude < 25

			Services.Workspace.FallenPartsDestroyHeight = OrgDestroyHeight
		end
	end

	for _, TargetPlayer in targets do
		if typeof(TargetPlayer) == "Instance" and TargetPlayer:IsA("Player") and not IsLocalTarget(TargetPlayer) then
			SkidFling(TargetPlayer)
		end
	end
end)

cmd.add({"commitoof", "suicide", "kys"}, {"commitoof (suicide, kys)", "Triggers a dramatic oof sequence for the player"}, function()
	const p = Services.Players.LocalPlayer
	if not p then
		return
	end

	local c = p.Character
	if not c then
		c = p.CharacterAdded:Wait()
	end

	const h = getPlrHum(c)
	if not h then
		return
	end

	const r = getRoot(c)
	if not r then
		return
	end

	NAlib.LocalPlayerChat("Okay... I will do it.", "All")
	Wait(1.5)
	NAlib.LocalPlayerChat("I will oof now...", "All")
	Wait(1.5)
	NAlib.LocalPlayerChat("Goodbye, cruel world.", "All")
	Wait(2)

	h:MoveTo(r.Position + r.CFrame.LookVector * 10)
	NAmanage.LaunchHumanoid(h, r)
	Wait(0.45)

	cmd.run({'die'})
end)

cmd.add({"volume","vol"},{"volume <0-10> (vol)","Changes your volume"},function(vol)
	local numberValue = tonumber(vol)
	if not numberValue then
		return DoNotif("please provide a number between 0-10",2)
	end
	numberValue = numberValue / 10
	const amount = math.clamp(numberValue, 0, 1)
	UserSettings():GetService("UserGameSettings").MasterVolume = amount
end,true)

cmd.add({"perfstats"},{"perfstats <on/off>","Shows or hides performance stats"},function(t)
	const s=UserSettings():GetService("UserGameSettings")
	const a=tostring(t or ""):lower()
	pcall(function() s.PerformanceStatsVisible=(a=="on" or a=="true" or a=="1") end)
end,true)

cmd.add({"preftransparency","prefalpha"},{"preftransparency <0-15>","Preferred UI transparency"},function(v)
	const s=UserSettings():GetService("UserGameSettings")
	const n=math.clamp(tonumber(v) or 0,0,15)
	pcall(function() s.PreferredTransparency=n end)
end,true)

cmd.add({"sensitivity","sens"},{"sensitivity <1-10> (sens)","Changes your sensitivity"},function(ss)
	Services.UserInputService.MouseDeltaSensitivity=ss
end,true)

cmd.add({"torandom","tr"},{"torandom (tr)","Teleports to a random player"},function()
	target=getPlr("random")
	for _, plr in next, target do
		SpawnCall(function() getRoot(getChar()).CFrame=getPlrHum(plr).RootPart.CFrame end)
	end
end)

cmd.add({"timestop", "tstop"}, {"timestop (tstop)", "freezes all players (ZA WARUDO)"}, function()
	const target = getPlr("others")
	if #target == 0 then return end

	for _, plr in __lt.cm("Players", "GetPlayers") do
		NAlib.disconnect("timestop_char_"..plr.UserId)
	end
	NAlib.disconnect("timestop_playeradd")

	for _, plr in target do
		const char = NAmanage.PlayerArgChar(plr)
		if char then
			for _, v in char:QueryDescendants("BasePart") do
				v.Anchored = true
			end
		end

		NAlib.connect("timestop_char_"..plr.UserId, plr.CharacterAdded:Connect(function(char)
			while not getRoot(char) do Wait(.1) end
			for _, v in char:QueryDescendants("BasePart") do
				v.Anchored = true
			end
		end))
	end

	NAlib.connect("timestop_playeradd", Services.Players.PlayerAdded:Connect(function(plr)
		NAlib.connect("timestop_char_"..plr.UserId, plr.CharacterAdded:Connect(function(char)
			while not getRoot(char) do Wait(.1) end
			for _, v in char:QueryDescendants("BasePart") do
				v.Anchored = true
			end
		end))
	end))
end)

cmd.add({"untimestop", "untstop"}, {"untimestop (untstop)", "unfreeze all players"}, function()
	const target = getPlr("all")
	if #target == 0 then return end

	for _, plr in __lt.cm("Players", "GetPlayers") do
		NAlib.disconnect("timestop_char_"..plr.UserId)
	end
	NAlib.disconnect("timestop_playeradd")

	for _, plr in target do
		const char = NAmanage.PlayerArgChar(plr)
		if char then
			for _, v in char:QueryDescendants("BasePart") do
				v.Anchored = false
			end
		end
	end
end)

NAStuff._outfitCache=NAStuff._outfitCache or{};NAStuff._httpBackoff=NAStuff._httpBackoff or{};NAStuff._httpCooldown=NAStuff._httpCooldown or{}

NAmanage._avatarHttpJSON=function(method,url,body)
	local payload=nil
	if body~=nil then
		local okEncode,encoded=pcall(Services.HttpService.JSONEncode,Services.HttpService,body)
		if not okEncode or type(encoded)~="string" then return nil end
		payload=encoded
	end
	const text=NAmanage.FetchRobloxApiBody(url,{
		Method=method or"GET",
		Headers={
			Accept="application/json",
			["Content-Type"]=payload and"application/json" or nil,
			["Cache-Control"]="no-cache",
			Pragma="no-cache",
			["User-Agent"]="Roblox-Client",
		},
		Body=payload,
		Timeout=5,
	})
	if type(text)~="string" or text=="" then return nil end
	local okDecode,decoded=pcall(Services.HttpService.JSONDecode,Services.HttpService,text)
	if not okDecode then return nil end
	return decoded
end
NAmanage._resolveHumanoidUserId=function(target)
	if target==nil then return nil end
	const userId=tonumber(target)
	if userId then return userId end
	const name=tostring(target)
	if name=="" then return nil end
	const targets=getPlr(name)
	if targets[1] then return targets[1].UserId end
	local ok,id=pcall(Services.Players.GetUserIdFromNameAsync,Services.Players,name)
	if ok and id then return id end
	const data=NAmanage._avatarHttpJSON("POST","https://users.roblox.com/v1/usernames/users",{usernames={name},excludeBannedUsers=false})
	const entry=data and data.data and data.data[1]
	const resolved=entry and tonumber(entry.id)
	if resolved then return resolved end
	return nil
end
NAmanage._mapAvatarAssetProp=function(assetType)
	const t=tostring(assetType or"")
	if t:find("Animation") then
		return t:gsub("Animation","").."Animation"
	end
	if t=="TShirt" or t=="TShirtGraphic" then
		return"GraphicTShirt"
	end
	if t=="Hat" then
		return"HatAccessory"
	end
	if t=="DynamicHead" then
		return"Head"
	end
	return t
end
NAmanage._buildHumanoidDescriptionFromAvatar=function(av)
	if type(av)~="table" then return nil end
	const desc=InstanceNew("HumanoidDescription")
	const function setProp(prop,value)
		pcall(function()
			desc[prop]=value
		end)
	end
	const bodyColors=av.bodyColors
	if type(bodyColors)=="table" then
		pcall(function() setProp("HeadColor",BrickColor.new(bodyColors.headColorId).Color) end)
		pcall(function() setProp("TorsoColor",BrickColor.new(bodyColors.torsoColorId).Color) end)
		pcall(function() setProp("LeftArmColor",BrickColor.new(bodyColors.leftArmColorId).Color) end)
		pcall(function() setProp("RightArmColor",BrickColor.new(bodyColors.rightArmColorId).Color) end)
		pcall(function() setProp("LeftLegColor",BrickColor.new(bodyColors.leftLegColorId).Color) end)
		pcall(function() setProp("RightLegColor",BrickColor.new(bodyColors.rightLegColorId).Color) end)
	elseif type(av.bodyColor3s)=="table" then
		const bodyColor3s=av.bodyColor3s
		const function parseColor3(value)
			if type(value)~="string" then return nil end
			const hex=value:gsub("#","")
			if #hex~=6 then return nil end
			const n=tonumber(hex,16)
			if not n then return nil end
			const r=math.floor(n/65536)%256
			const g=math.floor(n/256)%256
			const b=n%256
			return Color3.fromRGB(r,g,b)
		end
		const head=parseColor3(bodyColor3s.headColor3)
		const torso=parseColor3(bodyColor3s.torsoColor3)
		const leftArm=parseColor3(bodyColor3s.leftArmColor3)
		const rightArm=parseColor3(bodyColor3s.rightArmColor3)
		const leftLeg=parseColor3(bodyColor3s.leftLegColor3)
		const rightLeg=parseColor3(bodyColor3s.rightLegColor3)
		if head then setProp("HeadColor",head) end
		if torso then setProp("TorsoColor",torso) end
		if leftArm then setProp("LeftArmColor",leftArm) end
		if rightArm then setProp("RightArmColor",rightArm) end
		if leftLeg then setProp("LeftLegColor",leftLeg) end
		if rightLeg then setProp("RightLegColor",rightLeg) end
	end
	const accessoryLists={
		HairAccessory={},
		FaceAccessory={},
		NeckAccessory={},
		ShoulderAccessory={},
		FrontAccessory={},
		BackAccessory={},
		WaistAccessory={},
		HatAccessory={},
	}
	for _,asset in av.assets or{} do
		const assetType=asset and asset.assetType
		const rawType=(type(assetType)=="table" and(assetType.name or assetType.id)) or assetType
		const prop=NAmanage._mapAvatarAssetProp(rawType)
		const assetId=asset and tonumber(asset.id)
		if prop and assetId and assetId>0 then
			if prop:find("Animation",1,true) then
				setProp(prop,assetId)
			elseif accessoryLists[prop] then
				Insert(accessoryLists[prop],tostring(assetId))
			elseif prop=="Shirt" or prop=="Pants" or prop=="Face" or prop=="GraphicTShirt" then
				setProp(prop,assetId)
			elseif prop=="Head" or prop=="Torso" or prop=="LeftArm" or prop=="RightArm" or prop=="LeftLeg" or prop=="RightLeg" then
				setProp(prop,assetId)
			end
		end
	end
	for prop,ids in accessoryLists do
		if #ids>0 then
			setProp(prop,Concat(ids,","))
		end
	end
	const scales=av.scales
	if type(scales)=="table" then
		if tonumber(scales.height) then setProp("HeightScale",scales.height) end
		if tonumber(scales.width) then setProp("WidthScale",scales.width) end
		if tonumber(scales.head) then setProp("HeadScale",scales.head) end
		if tonumber(scales.depth) then setProp("DepthScale",scales.depth) end
		if tonumber(scales.bodyType) then setProp("BodyTypeScale",scales.bodyType) end
		if tonumber(scales.proportion) then setProp("ProportionScale",scales.proportion) end
	end
	if type(av.emotes)=="table" and #av.emotes>0 then
		const emoteMap={}
		const equippedMeta={}
		const usedNames={}
		for _,emote in av.emotes do
			const assetId=tonumber(emote and (emote.assetId or emote.id))
			if assetId and assetId>0 then
				local baseName=tostring((emote and (emote.assetName or emote.name)) or ("Emote"..tostring(assetId)))
				if baseName=="" then
					baseName="Emote"..tostring(assetId)
				end
				local name=baseName
				if usedNames[name] and usedNames[name]~=assetId then
					name=baseName.." ("..tostring(assetId)..")"
				end
				usedNames[name]=assetId
				emoteMap[name]={assetId}
				Insert(equippedMeta,{name=name,position=tonumber(emote.position) or math.huge,id=assetId})
			end
		end
		if next(emoteMap) then
			table.sort(equippedMeta,function(a,b)
				if a.position==b.position then
					return a.id<b.id
				end
				return a.position<b.position
			end)
			const equipped={}
			for _,entry in equippedMeta do
				Insert(equipped,entry.name)
			end
			pcall(function()
				desc:SetEmotes(emoteMap)
			end)
			pcall(function()
				desc:SetEquippedEmotes(equipped)
			end)
		end
	end
	return desc
end
NAmanage._humanoidDescriptionHasAppearance=function(desc)
	if not desc then return false end
	for _,key in {
		"HatAccessory",
		"HairAccessory",
		"FaceAccessory",
		"NeckAccessory",
		"ShoulderAccessory",
		"ShouldersAccessory",
		"FrontAccessory",
		"BackAccessory",
		"WaistAccessory",
		"AccessoryBlob",
		"Shirt",
		"Pants",
		"GraphicTShirt",
		"TShirt",
		"Face",
		"Head",
		"Torso",
		"LeftArm",
		"RightArm",
		"LeftLeg",
		"RightLeg",
	} do
		local ok,value=pcall(function()
			return desc[key]
		end)
		if ok then
			if type(value)=="number" and value>0 then
				return true
			end
			if type(value)=="string" and value~="" then
				for id in value:gmatch("%d+") do
					if tonumber(id) and tonumber(id)>0 then
						return true
					end
				end
			end
		end
	end
	return false
end

NAmanage._resolveHumanoidDescription=function(target)
	if not target or target=="" then
		return nil
	end
	const userId=NAmanage._resolveHumanoidUserId(target)
	if not userId then return nil end
	local okDesc,desc=pcall(Services.Players.GetHumanoidDescriptionFromUserId,Services.Players,userId)
	if okDesc and desc and NAmanage._humanoidDescriptionHasAppearance(desc) then
		return desc,userId
	end
	local avatarData=NAmanage._avatarHttpJSON("GET",Format("https://avatar.roblox.com/v1/users/%d/avatar",userId))
	if not avatarData then
		avatarData=NAmanage._avatarHttpJSON("GET",Format("https://avatar.roblox.com/v2/avatar/users/%d/avatar",userId))
	end
	if not avatarData then return nil end
	const builtDesc=NAmanage._buildHumanoidDescriptionFromAvatar(avatarData)
	if not builtDesc then return nil end
	return builtDesc,userId
end

cmd.add({"team"},{"team <team name>","Changes your team (for the client)"},function(...)
	const args={...}
	local teamName=Concat(args," ")
	teamName=teamName and teamName:gsub("^%s+",""):gsub("%s+$","") or""
	if teamName=="" then DoNotif("team <team name>",3,"Team") return end
	const teamsService=SafeGetService("Teams")
	if not teamsService then return end
	const lookup=Lower(teamName)
	local targetTeam=nil
	for _,team in __lt.cm("Teams", "GetChildren") do
		if Lower(team.Name):find(lookup,1,true) then targetTeam=team break end
	end
	if not targetTeam then DoNotif(Format("Invalid team \"%s\"",teamName),3,"Team") return end
	const localPlayer=Services.Players.LocalPlayer
	if not localPlayer then return end
	const character=getChar()
	const root=character and getRoot(character)
	const function assignTeam()
		pcall(function()
			localPlayer.Neutral=false
			localPlayer.Team=targetTeam
		end)
	end
	if typeof(firetouchinterest)=="function" and root then
		for _,spawnLocation in NAmanage.QueryDescendants(Services.Workspace, "SpawnLocation") do
			if spawnLocation.BrickColor==targetTeam.TeamColor and spawnLocation.AllowTeamChangeOnTouch then
				pcall(firetouchinterest,spawnLocation,root,0)
				Wait()
				pcall(firetouchinterest,spawnLocation,root,1)
				assignTeam()
				return
			end
		end
	end
	assignTeam()
end,true)

cmd.add({"reselectchar","reselectcharacter","pickchar","charpicker"},{"reselectchar","Re-open the character picker"},function()
	if not (NA_GRAB_BODY and type(NA_GRAB_BODY.pickOverride) == "function") then
		DoNotif("Character picker is unavailable.", 3)
		return
	end
	SpawnCall(function()
		NA_GRAB_BODY.pickOverride()
	end)
end)

NAmanage._resolveExplicitOutfitId=function(target)
	const text=tostring(target or ""):gsub("^%s+",""):gsub("%s+$","")
	if text=="" then return nil end
	const matched=text:match("^[Oo][Uu][Tt][Ff][Ii][Tt]%s*[:#%-]?%s*(%d+)$")
		or text:match("^[Oo][Ii][Dd]%s*[:#%-]?%s*(%d+)$")
		or text:match("^[Ii][Dd]%s*[:#%-]?%s*(%d+)$")
		or text:match("^#(%d+)$")
	return tonumber(matched)
end

NAmanage._outfitHttpJSON=function(url)
	const req=opt and opt.NAREQUEST
	const function lowerKeys(t)const r={};for k,v in t or{} do r[Lower(k)]=v end;return r end
	const function decodeBody(text)
		if type(text)~="string" or text=="" then return nil end
		local okJ,data=pcall(Services.HttpService.JSONDecode,Services.HttpService,text)
		if okJ and type(data)=="table" then
			return data
		end
		return nil
	end
	const host=Match(url,"^https?://([^/]+)") or""
	const cd=NAStuff._httpCooldown[host]
	const cooldownActive=cd and time()<cd
	const sawCooldown=cooldownActive and true or false
	local sawRateLimit=false
	local sawServerError=false
	local lastFailure=nil
	const function markRetry(resp,kind)
		const hdrs=lowerKeys(resp and (resp.Headers or resp.headers) or{})
		const ra=tonumber(hdrs["retry-after"]) or tonumber(hdrs["x-ratelimit-retryafter"]) or nil
		local waitSec
		if kind=="429" then
			waitSec=math.clamp((ra or (NAStuff._httpBackoff[host] and NAStuff._httpBackoff[host]*2 or 1.5))+math.random()*0.25,1,10)
			sawRateLimit=true
		else
			waitSec=math.clamp((NAStuff._httpBackoff[host] and NAStuff._httpBackoff[host]*1.5 or 1.0)+math.random()*0.2,0.8,8)
			sawServerError=true
		end
		NAStuff._httpBackoff[host]=waitSec
		NAStuff._httpCooldown[host]=time()+waitSec
	end
	const function clearRetry()
		NAStuff._httpBackoff[host]=0
		NAStuff._httpCooldown[host]=nil
	end
	if type(req)=="function" and not cooldownActive then
		const payloads={
			{
				Url=url,
				Method="GET",
				Headers={Accept="application/json"},
				Timeout=5,
				FollowRedirects=true,
				SslVerify=false,
			},
			{
				Url=url,
				Method="GET",
				Timeout=5,
				FollowRedirects=true,
				SslVerify=false,
			},
			{
				Url=url,
				Method="GET",
				Headers={Accept="application/json"},
			},
			{
				Url=url,
				Method="GET",
			},
			{
				url=url,
				method="GET",
			},
		}
		for _,payload in payloads do
			local okR,resp=pcall(req,payload)
			const status=okR and resp and (resp.StatusCode or resp.Status) or 0
			const text=okR and resp and (resp.Body or resp.body) or""
			if status==200 then
				const data=decodeBody(text)
				if data then
					clearRetry()
					return true,data
				end
				lastFailure="bad json"
			elseif status==429 then
				markRetry(resp,"429")
			elseif status>=500 and status<600 then
				markRetry(resp,"5xx")
			elseif status and status~=0 then
				lastFailure="bad response "..tostring(status)
			elseif not okR then
				lastFailure=resp or lastFailure
			end
		end
	end
	local okHttpGet,textHttpGet=NAmanage.HttpGet(url, { timeout = 6, Headers = { Accept = "application/json" } })
	const dataHttpGet=okHttpGet and decodeBody(textHttpGet) or nil
	if dataHttpGet then
		clearRetry()
		return true,dataHttpGet
	end
	if sawCooldown then
		return false,"cooldown"
	end
	if sawRateLimit then
		return false,"429"
	end
	if sawServerError then
		return false,"5xx"
	end
	return false,lastFailure or "HTTP not available"
end
NAmanage._fetchUserOutfits=function(userId)
	const uid=tonumber(userId)
	if not uid or uid<=0 then return nil,"Couldn't resolve user" end
	const candidates={
		"https://avatar.roproxy.com/v1/users/%d/outfits?itemsPerPage=50%s",
		"https://avatar.rotunnel.com/v1/users/%d/outfits?itemsPerPage=50%s",
		"https://avatar.roblox.com/v1/users/%d/outfits?itemsPerPage=50%s",
	}
	local softFailure=nil
	for _,base in candidates do
		local outfits={}
		local cursor=nil
		repeat
			const cursorQuery=cursor and ("&cursor="..Services.HttpService:UrlEncode(cursor)) or ""
			const url=Format(base,uid,cursorQuery)
			local okD,data=NAmanage._outfitHttpJSON(url)
			if not okD then
				softFailure=data or softFailure
				outfits=nil
				break
			end
			for _,it in data and data.data or{} do
				if it and it.id and it.name and it.isEditable==true then
					Insert(outfits,{id=it.id,name=it.name})
				end
			end
			cursor=(data and (data.nextPageCursor or data.paginationToken)) or nil
			if cursor then
				Wait(0.4)
			end
		until not cursor
		if outfits and #outfits>0 then
			return outfits,nil,"v1-cursor"
		end
		if outfits then
			softFailure=nil
		end
	end
	if softFailure then
		return {},softFailure
	end
	return {},nil,"v1-cursor"
end

NAmanage._openOutfitPagedWindow=function(cfg,page)
	if type(cfg)~="table" then return end
	const outfits=type(cfg.outfits)=="table" and cfg.outfits or{}
	const makeCurrent=cfg.currentAvatarButton
	const makeOutfit=cfg.makeOutfitButton
	const uid=tonumber(cfg.uid) or 0
	local perPage=tonumber(NAStuff and NAStuff.OutfitPageSize) or 30
	perPage=math.max(5,math.min(45,math.floor(perPage)))
	const total=#outfits
	const totalPages=math.max(1,math.ceil(total/perPage))
	page=math.floor(tonumber(page) or 1)
	page=math.max(1,math.min(totalPages,page))
	const buttons={}
	if type(makeCurrent)=="function" then
		const button=makeCurrent()
		if button then Insert(buttons,button) end
	end
	if totalPages>1 and page>1 then
		Insert(buttons,{Text=Format("← Previous Page (%d/%d)",page-1,totalPages),Callback=function()
			NAmanage._openOutfitPagedWindow(cfg,page-1)
		end})
	end
	const first=total>0 and ((page-1)*perPage)+1 or 0
	const last=total>0 and math.min(total,first+perPage-1) or 0
	if type(makeOutfit)=="function" then
		for i=first,last do
			const outfit=outfits[i]
			if outfit then
				const button=makeOutfit(outfit,i)
				if button then Insert(buttons,button) end
			end
		end
	end
	if totalPages>1 and page<totalPages then
		Insert(buttons,{Text=Format("Next Page → (%d/%d)",page+1,totalPages),Callback=function()
			NAmanage._openOutfitPagedWindow(cfg,page+1)
		end})
	end
	local title=Format("%s • %s (%d)",tostring(cfg.titlePrefix or "Outfits"),tostring(cfg.arg or uid),uid)
	if totalPages>1 then
		title=Format("%s • Page %d/%d",title,page,totalPages)
	end
	if cfg.cache==true then
		title=title.." [cache]"
	end
	local desc=nil
	if totalPages>1 then
		desc=Format("Showing %d-%d of %d outfits.",first,last,total)
	end
	Window({Title=title,Description=desc,Buttons=buttons})
end

cmd.add({"goto","to","tp","teleport"},{"goto <player|npc:filter|X,Y,Z>","Teleport to the given player, NPC, or X,Y,Z coordinates"},function(...)
	const input = Concat({...}," ")
	const char = getChar()
	local x,y,z = input:match("^%s*([+-]?%d+%.?%d*)[,%s]+([+-]?%d+%.?%d*)[,%s]+([+-]?%d+%.?%d*)%s*$")
	if x and y and z then
		if char then
			NAmanage.UG_pivotModel(char, CFrame.new(tonumber(x),tonumber(y),tonumber(z)))
		end
		return
	end

	const targets = getPlr(input)
	if #targets > 0 then
		local moved = false
		for _,target in targets do
			const cf = NAmanage.PlayerArgPivot(target)
			if char and cf then
				NAmanage.UG_pivotModel(char, cf)
				moved = true
			end
		end
		if not moved then
			DebugNotif("No valid player or NPC root found",3)
		end
	else
		DebugNotif("Invalid input: not a valid player, NPC, or X,Y,Z coordinates",3)
	end
end,true,{argumentHint="Examples: me, nearest, npc:name, npcs, X,Y,Z"})

function stareFIXER(char, facePos)
	const root = getRoot(char)
	if not root then return end
	const pos = root.Position
	const flatTarget = Vector3.new(facePos.X, pos.Y, facePos.Z)
	if (flatTarget - pos).Magnitude < 0.1 then return end
	NAmanage.UG_setRootCFrame(root, CFrame.new(pos, flatTarget))
end

cmd.add({"lookat", "stare"}, {"lookat <player|npc:filter>", "Stare at a player or NPC"}, function(...)
	const RawPlayers = __lt.gs("Players")
	const Username = (...)
	const Target = getPlr(Username)

	for _, plr in next, Target do
		NAlib.disconnect("stare_direct")

		const lp = Services.Players.LocalPlayer
		local tchar = NAmanage.PlayerArgChar(plr)
		if not (lp.Character and getRoot(lp.Character)) then return end
		if not (tchar and tchar.Parent and getRoot(tchar)) then return end

		getHum().AutoRotate = false

		const function Stare()
			tchar = NAmanage.PlayerArgChar(plr)
			const root = tchar and getRoot(tchar)
			if lp.Character and root then
				stareFIXER(lp.Character, root.Position)
			elseif typeof(plr) ~= "Instance" or not plr.Parent or (plr:IsA("Player") and plr.Parent ~= RawPlayers) then
				NAlib.disconnect("stare_direct")
			end
		end

		NAlib.connect("stare_direct", Services.RunService.RenderStepped:Connect(Stare))
	end
end, true, {argumentHint="Examples: me, nearest, npc:name, npcs"})

cmd.add({"unlookat", "unstare"}, {"unlookat", "Stops staring"}, function()
	NAlib.disconnect("stare_direct")
	if getHum() then
		getHum().AutoRotate = true
	end
end)

cmd.add({"starenear", "stareclosest"}, {"starenear (stareclosest)", "Stare at the closest player"}, function()
	NAlib.disconnect("stare_nearest")

	const function getClosest()
		const targets = getPlr("nearest")
		return targets[1]
	end

	const lp = Services.Players.LocalPlayer
	if getHum() then
		getHum().AutoRotate = false
	end

	const function stare()
		const lp = Services.Players.LocalPlayer
		const char = lp.Character
		if not (char and getRoot(char)) then return end
		const target = getClosest()
		if target and target.Character and getRoot(target.Character) then
			stareFIXER(char, getRoot(target.Character).Position)
		end
	end

	NAlib.connect("stare_nearest", Services.RunService.RenderStepped:Connect(stare))
end)

cmd.add({"unstarenear", "unstareclosest"}, {"unstarenear (unstareclosest)", "Stop staring at closest player"}, function()
	NAlib.disconnect("stare_nearest")
	if getHum() then
		getHum().AutoRotate = true
	end
end)

specUI = nil
connStep, connAdd, connRemove = nil, nil, nil

spectateTarget, spectateSubject = nil, nil
spectateDescCharacter = nil
spectateConns = {
	char = nil,
	leave = nil,
	loop = nil,
	cam = nil,
	camW = nil,
	desc = nil
}

originalIO.disconnectSpectateConns=function()
	for k, c in spectateConns do
		if c then
			c:Disconnect()
			spectateConns[k] = nil
		end
	end
	NAlib.disconnect("spectate_char")
	NAlib.disconnect("spectate_loop")
	NAlib.disconnect("spectate_leave")
	NAlib.disconnect("spectate_cam")
	NAlib.disconnect("spectate_camW")
	NAlib.disconnect("spectate_desc")
	spectateDescCharacter = nil
end

originalIO.getSpectateSubject = function(character)
	if not (character and character.Parent) then
		return nil
	end

	const hum = getPlrHum(character)
	if hum and hum.Parent == character then
		return hum
	end

	const root = getRoot(character)
	if root and root:IsDescendantOf(character) then
		return root
	end

	const head = getHead(character)
	if head and head:IsDescendantOf(character) then
		return head
	end

	return character:FindFirstChildWhichIsA("BasePart", true)
end

originalIO.ensureCam=function()
	if not spectateTarget or not spectateSubject then return end
	if not Services.Workspace then return end
	const cam = Services.Workspace.CurrentCamera
	if not cam then return end
	if NAlib.isProperty(cam, "CameraSubject") == nil then return end
	if cam.CameraSubject ~= spectateSubject then
		NAlib.setProperty(cam, "CameraSubject", spectateSubject)
	end
end

originalIO.hookCameraGuard=function()
	if not Services.Workspace then return end
	const cam = Services.Workspace.CurrentCamera
	if not cam then return end

	if spectateConns.cam then
		spectateConns.cam:Disconnect()
		spectateConns.cam = nil
	end

	if NAlib.isProperty(cam, "CameraSubject") ~= nil then
		spectateConns.cam = NAlib.connect("spectate_cam", cam:GetPropertyChangedSignal("CameraSubject"):Connect(function()
			if not spectateTarget or not spectateSubject then return end
			originalIO.ensureCam()
		end))
	end

	if not spectateConns.camW and NAlib.isProperty(Services.Workspace, "CurrentCamera") ~= nil then
		spectateConns.camW = NAlib.connect("spectate_camW", Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if not spectateTarget or not spectateSubject then return end
			originalIO.hookCameraGuard()
			originalIO.ensureCam()
		end))
	end
end

function cleanup(preserveSpecUI)
	spectateTarget = nil
	spectateSubject = nil

	originalIO.disconnectSpectateConns()

	if connStep then connStep:Disconnect() connStep = nil end
	if connAdd then connAdd:Disconnect() connAdd = nil end
	if connRemove then connRemove:Disconnect() connRemove = nil end

	if specUI and not preserveSpecUI then
		specUI:Destroy()
		specUI = nil
	end

	const hum = getHum()
	if Services.Workspace then
		const cam = Services.Workspace.CurrentCamera
		if hum and cam and NAlib.isProperty(cam, "CameraSubject") ~= nil then
			NAlib.setProperty(cam, "CameraSubject", hum)
		end
	end
end

function spectatePlayer(targetPlayer)
	if not targetPlayer then return end

	spectateTarget = targetPlayer
	spectateSubject = nil
	originalIO.disconnectSpectateConns()

	local setCamToCharacter
	const function watchCharacter(character)
		if character and spectateConns.desc and spectateDescCharacter == character then
			return
		end
		if spectateConns.desc then
			spectateConns.desc:Disconnect()
			spectateConns.desc = nil
		end
		spectateDescCharacter = character
		if not (character and character.Parent) then
			return
		end
		spectateConns.desc = NAlib.connect("spectate_desc", NAmanage.descAdd(character, function(inst)
			if spectateTarget ~= targetPlayer or targetPlayer.Character ~= character then return end
			if inst:IsA("Humanoid") or inst:IsA("BasePart") then
				setCamToCharacter(character, true)
			end
		end, function(inst)
			return inst and (inst:IsA("Humanoid") or inst:IsA("BasePart"))
		end))
	end

	setCamToCharacter = function(character, keepOldSubject)
		if spectateTarget ~= targetPlayer or not character then return end

		const subj = originalIO.getSpectateSubject(character)
		if not subj then
			if keepOldSubject ~= true and spectateSubject and spectateSubject.Parent == nil then
				spectateSubject = nil
			end
			return false
		end

		spectateSubject = subj
		originalIO.ensureCam()
		originalIO.hookCameraGuard()
		return true
	end

	watchCharacter(targetPlayer.Character)
	setCamToCharacter(targetPlayer.Character)

	spectateConns.char = NAlib.connect("spectate_char", targetPlayer.CharacterAdded:Connect(function(character)
		if spectateTarget ~= targetPlayer then return end
		watchCharacter(character)
		setCamToCharacter(character, true)
	end))

	spectateConns.leave = NAlib.connect("spectate_leave", Services.Players.PlayerRemoving:Connect(function(player)
		if player == targetPlayer and spectateTarget == targetPlayer then
			cleanup(true)
			DebugNotif("Player left - camera reset")
		end
	end))

	spectateConns.loop = NAlib.connect("spectate_loop", Services.RunService.RenderStepped:Connect(function()
		if spectateTarget ~= targetPlayer then return end

		const char = targetPlayer.Character
		if not char or not char.Parent then
			if spectateSubject and spectateSubject.Parent then
				originalIO.ensureCam()
			end
			return
		end

		if targetPlayer.Character == char and spectateDescCharacter ~= char then
			watchCharacter(char)
		end

		if spectateSubject and not spectateSubject:IsDescendantOf(char) then
			if not setCamToCharacter(char, true) then
				if spectateSubject.Parent then
					originalIO.ensureCam()
				else
					spectateSubject = nil
				end
			end
		elseif not spectateSubject then
			setCamToCharacter(char, true)
		else
			originalIO.ensureCam()
		end
	end))
end

cmd.add({"watch", "view", "spectate"}, {"watch <Player> (view, spectate)", "Spectate player"}, function(...)
	cleanup()
	const targetPlayer = getPlr((...))
	for _, plr in next, targetPlayer do
		if not plr then return end
		spectatePlayer(plr)
	end
end, true)

cmd.add({"unwatch", "unview"}, {"unwatch (unview)", "Stop spectating"}, function()
	cleanup()
end)

cmd.add({"watch2","view2","spectate2"},{"watch2",""},function()
	NAlib.disconnect("spectate_char")
	NAlib.disconnect("spectate_loop")
	NAlib.disconnect("spectate_leave")

	const LocalPlayer = Services.Players.LocalPlayer
	const PAD = 8
	const CARD_W = IsOnMobile and 0.6 or 0.4
	const CARD_H = IsOnMobile and 62 or 68
	const BTN_H = IsOnMobile and 34 or 32
	const BTN_W_SIDE = IsOnMobile and 58 or 60
	const BTN_W_V = IsOnMobile and 34 or 32
	const BTN_W_X = IsOnMobile and 34 or 32
	const AV_SZ = IsOnMobile and 40 or 42
	const ROW_H = IsOnMobile and 40 or 34
	const HEADER_H = IsOnMobile and 36 or 32

	local ui, card, avatar, nameMain, nameSub, toggleBtn, btnPrev, btnNext, btnClose
	local drop, searchBox, list, listLayout, dropMaxH
	local listOpen, dropdownBusy = false, false
	local dropdownSeq = 0

	local playerList, currentIndex, spectatedPlayer = {}, 1, nil
	local rows = {}
	local searchTerm = ""
	const thumbCache = {}
	const fallbackThumbFmt = "rbxthumb://type=AvatarHeadShot&id=%d&w=420&h=420"

	const function getHeadshot(plr)
		-- Roblox occasionally throws from GetUserThumbnailAsync, cache and fall back so the UI never breaks.
		if not plr then
			return Format(fallbackThumbFmt, 0)
		end
		const userId = tonumber(plr.UserId) or 0
		if thumbCache[userId] then
			return thumbCache[userId]
		end
		local ok, image = pcall(function()
			return __lt.cm("Players", "GetUserThumbnailAsync", userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
		end)
		const resolved = (ok and image and image ~= "") and image or Format(fallbackThumbFmt, userId)
		thumbCache[userId] = resolved
		return resolved
	end

	const function insertSorted(plr)
		const n = #playerList
		if n == 0 then Insert(playerList, plr) return 1 end
		const key = Lower(plr.Name)
		local lo, hi, pos = 1, n, n + 1
		while lo <= hi do
			const mid = (lo + hi) // 2
			if Lower(playerList[mid].Name) > key then
				pos = mid
				hi = mid - 1
			else
				lo = mid + 1
			end
		end
		Insert(playerList, pos, plr)
		return pos
	end

	const function removeFromList(plr)
		const i = Discover(playerList, plr)
		if i then table.remove(playerList, i) return i end
	end

	const function matchesFilter(plr)
		if searchTerm == "" then return true end
		return Find(Lower(nameChecker(plr)), searchTerm, 1, true) ~= nil
	end

	const function setHeader(plr)
		if not plr then
			nameSub.Text = "Spectating"
			nameMain.Text = "None"
			return
		end
		nameSub.Text = "Spectating"
		nameMain.Text = nameChecker(plr)
		nameMain.TextColor3 = (plr == LocalPlayer) and Color3.fromRGB(255,255,0) or Color3.fromRGB(255,255,255)
		avatar.Image = getHeadshot(plr)
	end

	const function recolor()
		for _, btn in rows do
			const lbl = btn:FindFirstChild("NameLabel")
			if lbl then
				const uid = NAmanage.GetAttr(btn, "uid")
				const plr = __lt.cm("Players", "GetPlayerByUserId", uid)
				if plr == LocalPlayer then
					lbl.TextColor3 = Color3.fromRGB(255,255,0)
				elseif spectatedPlayer and plr == spectatedPlayer then
					lbl.TextColor3 = Color3.fromRGB(0,162,255)
				else
					lbl.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
		end
	end

	const function gotoPlayer(plr)
		if not plr then return end
		spectatedPlayer = plr
		currentIndex = Discover(playerList, plr) or currentIndex
		setHeader(plr)
		spectatePlayer(plr)
		recolor()
	end

	const function gotoIndex(idx)
		if #playerList == 0 then return end
		if idx < 1 then idx = #playerList end
		if idx > #playerList then idx = 1 end
		currentIndex = idx
		gotoPlayer(playerList[currentIndex])
	end

	const function mkRow(plr)
		if not list or rows[plr.UserId] then return end
		const pb = InstanceNew("TextButton")
		pb.Parent = list
		pb.Name = Lower(plr.Name).."|"..tostring(plr.UserId)
		pb.Size = UDim2.new(1, 0, 0, ROW_H)
		pb.BackgroundColor3 = Color3.fromRGB(40,40,40)
		pb.AutoButtonColor = true
		pb.Text = ""
		NAmanage.SetAttr(pb, "uid", plr.UserId)
		const corner = InstanceNew("UICorner", pb) corner.CornerRadius = UDim.new(0, 6)
		const stroke = InstanceNew("UIStroke", pb) stroke.Thickness = 1 stroke.Transparency = 0.6 stroke.Color = Color3.fromRGB(70,70,70)
		const img = InstanceNew("ImageLabel", pb)
		img.Size = UDim2.new(0, ROW_H, 0, ROW_H)
		img.BackgroundTransparency = 1
		img.Image = getHeadshot(plr)
		const nameLbl = InstanceNew("TextLabel", pb)
		nameLbl.Name = "NameLabel"
		nameLbl.BackgroundTransparency = 1
		nameLbl.Size = UDim2.new(1, -ROW_H-12, 1, 0)
		nameLbl.Position = UDim2.new(0, ROW_H+12, 0, 0)
		nameLbl.Font = Enum.Font.SourceSansSemibold
		nameLbl.TextScaled = true
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextColor3 = Color3.fromRGB(255,255,255)
		nameLbl.Text = nameChecker(plr)
		pb.Visible = matchesFilter(plr)
		MouseButtonFix(pb, function()
			gotoPlayer(plr)
		end)
		rows[plr.UserId] = pb
	end

	const function destroyRow(plr)
		const b = rows[plr.UserId]
		if b then b:Destroy() rows[plr.UserId] = nil end
	end

	const function filterRows()
		for uid, btn in rows do
			const plr = __lt.cm("Players", "GetPlayerByUserId", uid)
			if plr then
				btn.Visible = matchesFilter(plr)
			else
				btn.Visible = false
			end
		end
		if drop and list then
			const headerH = HEADER_H + PAD*2
			const contentY = list.AbsoluteCanvasSize.Y
			const target = math.min(headerH + contentY + PAD, dropMaxH)
			drop.Size = UDim2.new(1, 0, 0, target)
		end
	end

	const function safeConnectProp(inst, prop, mySeq, cb)
		if not inst then return end
		local ok, sig = pcall(function() return inst:GetPropertyChangedSignal(prop) end)
		if not ok or not sig then return end
		sig:Connect(function()
			if dropdownSeq ~= mySeq or not drop or not list or inst.Parent == nil then return end
			cb()
		end)
	end

	const function openDropdown()
		if dropdownBusy or listOpen then return end
		dropdownBusy = true
		toggleBtn.Active = false
		toggleBtn.AutoButtonColor = false
		dropdownSeq += 1
		const mySeq = dropdownSeq

		drop = InstanceNew("Frame", card)
		drop.BackgroundColor3 = Color3.fromRGB(34,34,34)
		drop.BorderSizePixel = 0
		drop.Position = UDim2.new(0, 0, 1, PAD)
		drop.Size = UDim2.new(1, 0, 0, 0)
		const dCorner = InstanceNew("UICorner", drop) dCorner.CornerRadius = UDim.new(0, 6)
		const dStroke = InstanceNew("UIStroke", drop) dStroke.Thickness = 1 dStroke.Transparency = 0.6 dStroke.Color = Color3.fromRGB(64,64,64)

		const header = InstanceNew("Frame", drop)
		header.BackgroundTransparency = 1
		header.Size = UDim2.new(1, -PAD*2, 0, HEADER_H)
		header.Position = UDim2.new(0, PAD, 0, PAD)

		searchBox = InstanceNew("TextBox", header)
		searchBox.Size = UDim2.new(1, 0, 1, 0)
		searchBox.BackgroundColor3 = Color3.fromRGB(45,45,45)
		searchBox.TextXAlignment = Enum.TextXAlignment.Left
		searchBox.Font = Enum.Font.SourceSans
		searchBox.TextSize = IsOnMobile and 18 or 16
		searchBox.PlaceholderText = "Type to filter players"
		searchBox.PlaceholderColor3 = Color3.fromRGB(185,185,185)
		searchBox.ClearTextOnFocus = false
		searchBox.Text = searchTerm
		searchBox.TextColor3 = Color3.fromRGB(255,255,255)
		const sCorner = InstanceNew("UICorner", searchBox) sCorner.CornerRadius = UDim.new(0, 6)
		const sStroke = InstanceNew("UIStroke", searchBox) sStroke.Thickness = 1 sStroke.Transparency = 0.6 sStroke.Color = Color3.fromRGB(70,70,70)

		list = InstanceNew("ScrollingFrame", drop)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.Position = UDim2.new(0, PAD, 0, HEADER_H + PAD*2)
		list.Size = UDim2.new(1, -PAD*2, 1, -(HEADER_H + PAD*3))
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.CanvasSize = UDim2.new(0,0,0,0)
		list.ScrollBarThickness = 8
		list.ClipsDescendants = true
		listLayout = InstanceNew("UIListLayout", list)
		listLayout.SortOrder = Enum.SortOrder.Name
		listLayout.Padding = UDim.new(0, 6)
		const padIn = InstanceNew("UIPadding", list)
		padIn.PaddingLeft = UDim.new(0, 6)
		padIn.PaddingRight = UDim.new(0, 6)
		padIn.PaddingTop = UDim.new(0, 6)
		padIn.PaddingBottom = UDim.new(0, 6)

		const vpY = Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize.Y or 720
		dropMaxH = math.floor(vpY * (IsOnMobile and 0.7 or 0.55))
		const openStart = __lt.cm("TweenService", "Create", drop, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, math.min(dropMaxH, (IsOnMobile and 280 or 240)))})
		openStart:Play()

		for _, plr in playerList do
			mkRow(plr)
		end

		filterRows()

		safeConnectProp(searchBox, "Text", mySeq, function()
			searchTerm = Lower(searchBox.Text or "")
			filterRows()
		end)

		safeConnectProp(listLayout, "AbsoluteContentSize", mySeq, function()
			filterRows()
		end)

		toggleBtn.Text = "V"
		toggleBtn.Rotation = 180
		listOpen = true
		dropdownBusy = false
		toggleBtn.Active = true
		toggleBtn.AutoButtonColor = true
	end

	const function closeDropdown()
		if not listOpen and not dropdownBusy then return end
		dropdownSeq += 1
		dropdownBusy = false
		toggleBtn.Active = true
		toggleBtn.AutoButtonColor = true
		toggleBtn.Text = "V"
		toggleBtn.Rotation = 0
		if drop then
			const tClose = __lt.cm("TweenService", "Create", drop, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
			tClose:Play()
			tClose.Completed:Wait()
			if drop then drop:Destroy() end
		end
		drop, list, listLayout, searchBox = nil, nil, nil, nil
		listOpen = false
		rows = {}
	end

	const function buildCard()
		card = InstanceNew("Frame", ui)
		card.AnchorPoint = Vector2.new(0.5, 1)
		card.Size = UDim2.new(CARD_W, 0, 0, CARD_H)
		card.Position = UDim2.new(0.5, 0, 0.14, 0)
		card.BackgroundColor3 = Color3.fromRGB(24,24,24)
		card.BorderSizePixel = 0
		const cardCorner = InstanceNew("UICorner", card) cardCorner.CornerRadius = UDim.new(0, 6)
		const cardStroke = InstanceNew("UIStroke", card) cardStroke.Thickness = 1 cardStroke.Transparency = 0.5 cardStroke.Color = Color3.fromRGB(60,60,60)
		const grad = InstanceNew("UIGradient", card) grad.Color = ColorSequence.new(Color3.fromRGB(30,30,30), Color3.fromRGB(18,18,18))
		NAgui.draggerV2(card)

		const content = InstanceNew("Frame", card)
		content.BackgroundTransparency = 1
		content.Size = UDim2.new(1, -PAD*2, 1, -PAD*2)
		content.Position = UDim2.new(0, PAD, 0, PAD)

		avatar = InstanceNew("ImageLabel", content)
		avatar.Size = UDim2.new(0, AV_SZ, 0, AV_SZ)
		avatar.Position = UDim2.new(0, 0, 0.5, -AV_SZ/2)
		avatar.BackgroundTransparency = 1
		const avCorner = InstanceNew("UICorner", avatar) avCorner.CornerRadius = UDim.new(0, 6)

		nameSub = InstanceNew("TextLabel", content)
		nameSub.BackgroundTransparency = 1
		nameSub.Position = UDim2.new(0, AV_SZ + PAD, 0, 0)
		nameSub.Size = UDim2.new(1, -(AV_SZ + PAD), 0.45, 0)
		nameSub.Font = Enum.Font.SourceSans
		nameSub.TextScaled = true
		nameSub.TextXAlignment = Enum.TextXAlignment.Left
		nameSub.TextColor3 = Color3.fromRGB(185,185,185)
		nameSub.Text = "Spectating"

		nameMain = InstanceNew("TextLabel", content)
		nameMain.BackgroundTransparency = 1
		nameMain.Position = UDim2.new(0, AV_SZ + PAD, 0.48, 0)
		nameMain.Size = UDim2.new(1, -(AV_SZ + PAD), 0.5, 0)
		nameMain.Font = Enum.Font.SourceSansBold
		nameMain.TextScaled = true
		nameMain.TextXAlignment = Enum.TextXAlignment.Left
		nameMain.TextColor3 = Color3.fromRGB(255,255,255)
		nameMain.Text = ""

		btnPrev = InstanceNew("TextButton", card)
		btnPrev.Size = UDim2.new(0, BTN_W_SIDE, 0, BTN_H)
		btnPrev.AnchorPoint = Vector2.new(1, 0.5)
		btnPrev.Position = UDim2.new(0, -PAD, 0.5, 0)
		btnPrev.BackgroundColor3 = Color3.fromRGB(45,45,45)
		btnPrev.Text = "Prev"
		btnPrev.TextColor3 = Color3.fromRGB(255,255,255)
		btnPrev.Font = Enum.Font.SourceSansBold
		btnPrev.TextSize = IsOnMobile and 16 or 16
		const pc = InstanceNew("UICorner", btnPrev) pc.CornerRadius = UDim.new(0, 6)
		const ps = InstanceNew("UIStroke", btnPrev) ps.Thickness = 1 ps.Transparency = 0.5 ps.Color = Color3.fromRGB(70,70,70)
		MouseButtonFix(btnPrev, function() gotoIndex(currentIndex - 1) end)

		btnNext = InstanceNew("TextButton", card)
		btnNext.Size = UDim2.new(0, BTN_W_SIDE, 0, BTN_H)
		btnNext.AnchorPoint = Vector2.new(0, 0.5)
		btnNext.Position = UDim2.new(1, PAD, 0.5, 0)
		btnNext.BackgroundColor3 = Color3.fromRGB(45,45,45)
		btnNext.Text = "Next"
		btnNext.TextColor3 = Color3.fromRGB(255,255,255)
		btnNext.Font = Enum.Font.SourceSansBold
		btnNext.TextSize = IsOnMobile and 16 or 16
		const nc = InstanceNew("UICorner", btnNext) nc.CornerRadius = UDim.new(0, 6)
		const ns = InstanceNew("UIStroke", btnNext) ns.Thickness = 1 ns.Transparency = 0.5 ns.Color = Color3.fromRGB(70,70,70)
		MouseButtonFix(btnNext, function() gotoIndex(currentIndex + 1) end)

		toggleBtn = InstanceNew("TextButton", card)
		toggleBtn.Size = UDim2.new(0, BTN_W_V, 0, BTN_H)
		toggleBtn.AnchorPoint = Vector2.new(1, 1)
		toggleBtn.Position = UDim2.new(1, PAD, 1, PAD)
		toggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
		toggleBtn.Text = "V"
		toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
		toggleBtn.Font = Enum.Font.SourceSansBold
		toggleBtn.TextSize = IsOnMobile and 14 or 14
		const vc = InstanceNew("UICorner", toggleBtn) vc.CornerRadius = UDim.new(0, 6)
		const vs = InstanceNew("UIStroke", toggleBtn) vs.Thickness = 1 vs.Transparency = 0.5 vs.Color = Color3.fromRGB(70,70,70)
		MouseButtonFix(toggleBtn, function()
			if listOpen then closeDropdown() else openDropdown() end
		end)

		btnClose = InstanceNew("TextButton", card)
		btnClose.Size = UDim2.new(0, BTN_W_X, 0, BTN_H)
		btnClose.AnchorPoint = Vector2.new(1, 0)
		btnClose.Position = UDim2.new(1, PAD, 0, -PAD)
		btnClose.BackgroundColor3 = Color3.fromRGB(255,60,60)
		btnClose.Text = "X"
		btnClose.TextColor3 = Color3.fromRGB(255,255,255)
		btnClose.Font = Enum.Font.SourceSansBold
		btnClose.TextSize = IsOnMobile and 14 or 14
		const xc = InstanceNew("UICorner", btnClose) xc.CornerRadius = UDim.new(0, 6)
		const xs = InstanceNew("UIStroke", btnClose) xs.Thickness = 1 xs.Transparency = 0.5 xs.Color = Color3.fromRGB(120,30,30)
		MouseButtonFix(btnClose, function()
			NAlib.disconnect("spectate2_step")
			NAlib.disconnect("spectate2_add")
			NAlib.disconnect("spectate2_remove")
			if drop then drop:Destroy() drop=nil end
			listOpen, dropdownBusy = false, false
			cleanup()
		end)
	end

	const function initialRoster()
		table.clear(playerList)
		for _, p in __lt.cm("Players", "GetPlayers") do
			insertSorted(p)
		end
	end

	initialRoster()
	if #playerList == 0 then return DebugNotif("No players to spectate", 2) end

	ui = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(ui)
	ui.ResetOnSpawn = false
	ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ui.DisplayOrder = 10

	buildCard()
	specUI = ui
	gotoIndex(1)

	NAlib.connect("spectate2_add", Services.Players.PlayerAdded:Connect(function(plr)
		const wasOpen = listOpen
		const keep = searchTerm
		const prevSel = spectatedPlayer
		insertSorted(plr)
		if wasOpen and list then mkRow(plr) filterRows() end
		if prevSel then
			currentIndex = Discover(playerList, prevSel) or currentIndex
		elseif #playerList > 0 and not prevSel then
			gotoIndex(1)
		end
		searchTerm = keep
	end))

	NAlib.connect("spectate2_remove", Services.Players.PlayerRemoving:Connect(function(plr)
		const wasOpen = listOpen
		const keep = searchTerm
		const prevSel = spectatedPlayer
		const removedIndex = removeFromList(plr)
		if wasOpen and list then destroyRow(plr) filterRows() end
		if prevSel == plr then
			spectatedPlayer = nil
			nameMain.Text = "None"
			const hum = getHum()
			if hum then Services.Workspace.CurrentCamera.CameraSubject = hum end
		else
			if prevSel then currentIndex = Discover(playerList, prevSel) or currentIndex end
		end
		searchTerm = keep
	end))
end, true)

cmd.add({"unwatch2","unview2"},{"unwatch2",""},function()
	NAlib.disconnect("spectate2_step")
	NAlib.disconnect("spectate2_add")
	NAlib.disconnect("spectate2_remove")
	cleanup()
	DebugNotif("Spectate stopped", 1.2)
end, true)

cmd.add({"stealaudio","getaudio","steal","logaudio"},{"stealaudio <player|npc:filter>","Save sounds playing from a player or NPC to a file -Cyrus"},function(p)
	Wait(.1)
	const players=getPlr(p)
	if not next(players) then DoNotif("Player not found") return end
	const ids={}
	for _,plr in players do
		const char=plr and NAmanage.PlayerArgChar(plr)
		if char then
			for _,snd in NAmanage.QueryDescendants(char, "Sound") do
				if snd.Playing then
					ids[#ids+1]=snd.SoundId
				end
			end
		end
	end
	if #ids>0 then
		setclipboard(Concat(ids,"\n"))
		DebugNotif("Audio links copied.")
	else
		DebugNotif("No audio found.")
	end
end,true)

cmd.add({"follow", "stalk", "walk"}, {"follow <player|npc:filter>", "Follow a player or NPC wherever they go"}, function(p)
	NAlib.disconnect("follow")
	const targetPlayers = getPlr(p)
	for _, plr in next, targetPlayers do
		if not plr then
			DoNotif("Player not found or invalid.")
			return
		end
		NAlib.connect("follow", Services.RunService.RenderStepped:Connect(function()
			const target = NAmanage.PlayerArgChar(plr)
			if target then
				const hum = getHum()
				const targetPart = getHead(target)
				if hum and targetPart then
					const targetPos = targetPart.Position
					hum:MoveTo(targetPos)
				else
					NAlib.disconnect("follow")
				end
			else
				NAlib.disconnect("follow")
			end
		end))
	end
end, true)

cmd.add({"unfollow", "unstalk", "unwalk", "unpathfind"}, {"unfollow", "Stop all attempts to follow a player"}, function()
	NAlib.disconnect("follow")
end)

PROXIMITY_RADIUS = 15
lastDistances = {}
ISfollowing = false
followTarget = nil
followConnection = nil
flwCharAdd = nil
followDeathConnection = nil

NAmanage.FollowUnload = function()
	for _, name in { "follow", "autofollow", "autofollow_target" } do
		NAlib.disconnect(name)
	end
	for _, connection in { followConnection, flwCharAdd, followDeathConnection } do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end
	followConnection = nil
	flwCharAdd = nil
	followDeathConnection = nil
	ISfollowing = false
	followTarget = nil
	const humanoid = type(getHum) == "function" and getHum() or nil
	const character = type(getChar) == "function" and getChar() or nil
	const root = character and type(getRoot) == "function" and getRoot(character) or nil
	if humanoid then
		pcall(function()
			humanoid:Move(Vector3.zero, false)
		end)
		if root then
			pcall(function()
				humanoid:MoveTo(root.Position)
			end)
		end
	end
end

cmd.add({"autofollow", "autostalk", "proxfollow"}, {"autofollow (autostalk,proxfollow)", "Automatically follow any player who comes close"}, function()
	NAlib.disconnect("autofollow")
	if followConnection then followConnection:Disconnect() followConnection = nil end
	if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
	if followDeathConnection then followDeathConnection:Disconnect() followDeathConnection = nil end
	lastDistances = {}
	ISfollowing = false
	followTarget = nil

	NAlib.connect("autofollow", Services.RunService.PreSimulation:Connect(function()
		if ISfollowing then return end

		const myChar = getChar()
		const myRoot = getRoot(myChar)
		const myHum = getHum()
		if not (myChar and myRoot and myHum) then return end

		for _, plr in __lt.cm("Players", "GetPlayers") do
			if plr ~= LocalPlayer then
				const char = plr.Character
				const root = getRoot(char)
				if char and root then
					const currentDist = (myRoot.Position - root.Position).Magnitude
					const lastDist = lastDistances[plr]

					if lastDist and lastDist > PROXIMITY_RADIUS and currentDist < PROXIMITY_RADIUS and currentDist < lastDist then
						ISfollowing = true
						followTarget = plr

						const function setupFollow(char)
							local targetRoot = getRoot(char)
							while not targetRoot do Wait(.1) targetRoot=getRoot(char) end

							if followConnection then followConnection:Disconnect() end
							NAlib.disconnect("autofollow_target")
							followConnection = NAlib.reconnect("autofollow_target", Services.RunService.PreSimulation:Connect(function()
								if myChar and myHum and targetRoot and char and char.Parent then
									myHum:MoveTo(targetRoot.Position)
								else
									if followConnection then followConnection:Disconnect() followConnection = nil end
									NAlib.disconnect("autofollow_target")
									if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
									if followDeathConnection then followDeathConnection:Disconnect() followDeathConnection = nil end
									ISfollowing = false
									followTarget = nil
								end
							end))

							const hum = getPlrHum(plr)
							if hum then
								if followDeathConnection then followDeathConnection:Disconnect() end
								followDeathConnection = NAmanage.ConnectHumanoidDeath(hum, function()
									if followConnection then followConnection:Disconnect() followConnection = nil end
									NAlib.disconnect("autofollow_target")
									if followDeathConnection then followDeathConnection:Disconnect() followDeathConnection = nil end
									ISfollowing = false
									followTarget = nil
								end)
							end
						end

						if plr.Character then
							setupFollow(plr.Character)
						end

						if flwCharAdd then flwCharAdd:Disconnect() end
						flwCharAdd = plr.CharacterAdded:Connect(function(newChar)
							Wait(0.1)
							setupFollow(newChar)
						end)

						break
					end

					lastDistances[plr] = currentDist
				end
			end
		end
	end))
end)

cmd.add({"unautofollow", "stopautofollow", "unproxfollow"}, {"unautofollow (stopautofollow,unproxfollow)", "Stop automatically following nearby players"}, function()
	NAlib.disconnect("autofollow")
	if followConnection then followConnection:Disconnect() followConnection = nil end
	NAlib.disconnect("autofollow_target")
	if flwCharAdd then flwCharAdd:Disconnect() flwCharAdd = nil end
	if followDeathConnection then followDeathConnection:Disconnect() followDeathConnection = nil end
	lastDistances = {}
	ISfollowing = false
	followTarget = nil
end)

cmd.add({"pathfind"},{"pathfind <player|npc:filter>","Follow a player or NPC using the pathfinder API"},function(p)
	Wait(.1)
	const players=getPlr(p)
	for _,plr in players do
		if plr then
			NAlib.disconnect("follow")
			const ps=SafeGetService("PathfindingService")
			local lastSrc, lastDst = Vector3.new(0, 0, 0), Vector3.new(0, 0, 0)
			NAlib.connect("follow",Services.RunService.Heartbeat:Connect(function()
				const hum=getHum() const char=getChar() const tgt=NAmanage.PlayerArgChar(plr)
				if not(hum and char and tgt and hum.RootPart) then return end
				const src=hum.RootPart.Position
				const dst=(getRoot(tgt) or getHead(tgt)).Position+Vector3.new(0,0,-2)
				if (src-lastSrc).Magnitude>1 or (dst-lastDst).Magnitude>1 then
					lastSrc, lastDst = src, dst
					const path=ps:CreatePath{AgentRadius=2,AgentHeight=5,AgentCanJump=true}
					path:ComputeAsync(src,dst)
					if path.Status~=Enum.PathStatus.NoPath then
						for _,wp in path:GetWaypoints() do
							if wp.Action==Enum.PathWaypointAction.Jump then
								if hum:GetState()~=Enum.HumanoidStateType.Freefall and hum.FloorMaterial~=Enum.Material.Air then
									NAmanage.LaunchHumanoid(hum)
								end
							end
							hum:MoveTo(wp.Position)
							hum.MoveToFinished:Wait(1)
						end
					end
				end
			end))
		end
	end
end,true)

freezeBTNTOGGLE = nil
isFrozennn = false

cmd.add({"freeze","thaw","anchor","fr"},{"freeze (thaw,anchor,fr)","Freezes your character"}, function(bool)
	const char = getChar()
	if not char then return end

	for _, part in char:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	isFrozennn = true

	if IsOnMobile and not bool then
		if freezeBTNTOGGLE then freezeBTNTOGGLE:Destroy() freezeBTNTOGGLE = nil end

		freezeBTNTOGGLE = InstanceNew("ScreenGui")
		const btn = InstanceNew("TextButton")
		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		const aspect = InstanceNew("UIAspectRatioConstraint")

		NAgui.NaProtectUI(freezeBTNTOGGLE)
		freezeBTNTOGGLE.ResetOnSpawn = false

		btn.Parent = freezeBTNTOGGLE
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.9, 0, 0.6, 0)
		btn.Size = UDim2.new(0.08, 0, 0.1, 0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "UNFRZ"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		NAgui.draggerV2(btn)

		MouseButtonFix(btn, function()
			const char = getChar()
			if not char then return end

			for _, part in char:GetChildren() do
				if part:IsA("BasePart") then
					part.Anchored = not isFrozennn
				end
			end

			isFrozennn = not isFrozennn
			btn.Text = isFrozennn and "UNFRZ" or "FRZ"
			btn.BackgroundColor3 = isFrozennn and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
		end)
	end
end)

cmd.add({"unfreeze","unthaw","unanchor","unfr"},{"unfreeze (unthaw,unanchor,unfr)","Unfreezes your character"}, function()
	const char = getChar()
	if not char then return end

	for _, part in char:GetChildren() do
		if part:IsA("BasePart") then
			part.Anchored = false
		end
	end

	isFrozennn = false

	if freezeBTNTOGGLE then
		freezeBTNTOGGLE:Destroy()
		freezeBTNTOGGLE = nil
	end
end)

cmd.add({"blackhole","bhole","bholepull"},{"blackhole","Makes unanchored parts teleport to the black hole"},function()
	if NAlib.isConnected("blackhole_force") then return DebugNotif("Blackhole already exists.") end

	const UIS=SafeGetService("UserInputService")
	const Mouse=NAmanage.GetMouse(LocalPlayer)
	const Folder=InstanceNew("Folder",Services.Workspace)
	const Part=InstanceNew("Part",Folder)
	const Attachment1=InstanceNew("Attachment",Part)
	Part.Anchored=true Part.CanCollide=false Part.Transparency=1

	const function getBlackholeTarget()
		const cf = NAmanage.GetMouseWorldCFrame(Mouse, { LocalPlayer and LocalPlayer.Character, Folder }, 2048)
		if cf then
			return cf + Vector3.new(0, 5, 0)
		end
		return CFrame.new(Part.Position)
	end

	const Updated=getBlackholeTarget()
	_na_env.BlackholeAttachment=Attachment1
	_na_env.BlackholeTarget=Updated
	_na_env.BlackholeActive=false

	NAlib.connect("blackhole_sim",Services.RunService.RenderStepped:Connect(function()
		settings().Physics.AllowSleep=false
		for _,plr in next,__lt.cm("Players", "GetPlayers") do
			if plr~=LocalPlayer then NACaller(function()
					plr.MaximumSimulationRadius=0
					opt.hiddenprop(plr,"SimulationRadius",0)
				end) end
		end
		NACaller(function()
			LocalPlayer.MaximumSimulationRadius=1e9
			opt.hiddenprop(LocalPlayer,"SimulationRadius",1e9)
		end)
	end))

	NAlib.connect("blackhole_pos",Services.RunService.RenderStepped:Connect(function()
		if _na_env.BlackholeAttachment then
			_na_env.BlackholeAttachment.WorldCFrame=_na_env.BlackholeTarget
		end
	end))

	const function ForcePart(v)
		if not _na_env.BlackholeActive then return end
		if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name~="Handle" then
			for _,x in next,v:GetChildren() do
				if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
			end
			for _,n in next,{"Attachment","AlignPosition","Torque"} do const i=v:FindFirstChild(n) if i then i:Destroy() end end
			v.CanCollide=false
			const a2=InstanceNew("Attachment",v)
			const align=InstanceNew("AlignPosition",v)
			const torque=InstanceNew("Torque",v)
			align.Attachment0=a2 align.Attachment1=_na_env.BlackholeAttachment
			align.MaxForce=1e9 align.MaxVelocity=math.huge align.Responsiveness=200
			torque.Attachment0=a2 torque.Torque=Vector3.new(100000,100000,100000)
		end
	end

	for _, v in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do ForcePart(v) end
	NAlib.connect("blackhole_force",NAmanage.wsAdd(ForcePart))

	UIS.InputBegan:Connect(function(k,chat)
		if k.KeyCode==Enum.KeyCode.E and not chat then
			_na_env.BlackholeTarget=getBlackholeTarget()
		end
	end)

	const sGUI=InstanceNew("ScreenGui")
	NAgui.NaProtectUI(sGUI)

	const toggleBtn=InstanceNew("TextButton",sGUI)
	const toggleCorner=InstanceNew("UICorner",toggleBtn)
	toggleCorner.CornerRadius = UDim.new(0, 6)
	toggleBtn.Text="Enable Blackhole"
	toggleBtn.AnchorPoint=Vector2.new(0.5,0)
	toggleBtn.Size=UDim2.new(0,160,0,40)
	toggleBtn.Position=UDim2.new(0.5,0,0.88,0)
	toggleBtn.BackgroundColor3=Color3.new(0.15,0.15,0.15)
	toggleBtn.TextColor3=Color3.new(1,1,1)
	toggleBtn.Font=Enum.Font.SourceSansBold
	toggleBtn.TextSize=18
	toggleCorner.CornerRadius=UDim.new(0, 6)

	MouseButtonFix(toggleBtn,function()
		_na_env.BlackholeActive=not _na_env.BlackholeActive
		toggleBtn.Text=_na_env.BlackholeActive and "Disable Blackhole" or "Enable Blackhole"
		if not _na_env.BlackholeActive then
			for _,p in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do
				if not p.Anchored then
					for _,o in p:GetChildren() do
						if o:IsA("AlignPosition") or o:IsA("Torque") or o:IsA("Attachment") then o:Destroy() end
					end
				end
			end
			DebugNotif("Blackhole force disabled",2)
		else
			for _, v in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do ForcePart(v) end
			DebugNotif("Blackhole force enabled",2)
		end
	end)

	const moveBtn=InstanceNew("TextButton",sGUI)
	const moveCorner=InstanceNew("UICorner",moveBtn)
	moveCorner.CornerRadius = UDim.new(0, 6)
	moveBtn.Text="Move Blackhole"
	moveBtn.AnchorPoint=Vector2.new(0.5,0)
	moveBtn.Size=UDim2.new(0,160,0,40)
	moveBtn.Position=UDim2.new(0.5,0,0.94,0)
	moveBtn.BackgroundColor3=Color3.new(0.2,0.2,0.2)
	moveBtn.TextColor3=Color3.new(1,1,1)
	moveBtn.Font=Enum.Font.SourceSansBold
	moveBtn.TextSize=18
	moveCorner.CornerRadius=UDim.new(0, 6)

	MouseButtonFix(moveBtn,function()
		_na_env.BlackholeTarget=getBlackholeTarget()
	end)

	NAgui.draggerV2(toggleBtn)
	NAgui.draggerV2(moveBtn)

	DebugNotif("Blackhole created. Tap button or press E to move",3)
end,true)

cmd.add({"disableanimations","disableanims"},{"disableanimations (disableanims)","Freezes your animations"},function()
	getChar().Animate.Disabled=true
end)

cmd.add({"undisableanimations","undisableanims"},{"undisableanimations (undisableanims)","Unfreezes your animations"},function()
	getChar().Animate.Disabled=false
end)

cmd.add({"hatresize"},{"hatresize","Makes your hats very big r15 only"},function()
	Wait();

	DebugNotif("Hat resize loaded, rthro needed")

	NAmanage.RunURL('https://raw.githubusercontent.com/DigitalityScripts/roblox-scripts/refs/heads/main/Patched/hat%20resize')
end)

cmd.add({"exit"},{"exit","Close down pedoblox"},function()
	game:Shutdown()
end)

NAmanage.NormalizeFireKeyName = function(name)
	return Lower(tostring(name or "")):gsub("[%s_%-%+]+", "")
end

NAmanage.ResolveFireKeyCode = function(input)
	if not input or input == "" then
		return nil
	end

	const cleaned = NAmanage.NormalizeFireKeyName(input)
	for _, keyCode in Enum.KeyCode:GetEnumItems() do
		const keyName = NAmanage.NormalizeFireKeyName(keyCode.Name)
		if keyName == cleaned or Match(keyName, cleaned) or Match(cleaned, keyName) then
			return keyCode
		end
	end

	return nil
end

NAmanage.IsFireKeyBlockedByTextBox = function()
	if NAmanage.isAnyNAInputActive and NAmanage.isAnyNAInputActive() then
		return true
	end

	if not (Services.UserInputService and Services.UserInputService.GetMouseLocation) then
		return false
	end

	local okMouse, mousePos = pcall(function()
		return __lt.cm("UserInputService", "GetMouseLocation")
	end)
	if not okMouse or typeof(mousePos) ~= "Vector2" then
		return false
	end

	const roots = {}
	const seen = {}
	const function addRoot(root)
		if typeof(root) == "Instance" and not seen[root] then
			seen[root] = true
			Insert(roots, root)
		end
	end

	addRoot(NAStuff.NASCREENGUI)
	if LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui") then
		addRoot(LocalPlayer:FindFirstChildOfClass("PlayerGui"))
	end
	pcall(function()
		addRoot(SafeGetService("CoreGui"))
	end)
	if type(gethui) == "function" then
		pcall(function()
			addRoot(gethui())
		end)
	end

	const function scanTextBoxes(root)
		if typeof(root) ~= "Instance" then
			return false
		end
		local hit = false
		NAmanage.ForEachDescendantYield(root, function(obj)
			if obj:IsA("TextBox") and obj.Visible then
				const pos = obj.AbsolutePosition
				const size = obj.AbsoluteSize
				if mousePos.X >= pos.X and mousePos.Y >= pos.Y and mousePos.X <= pos.X + size.X and mousePos.Y <= pos.Y + size.Y then
					hit = true
					return true
				end
			end
		end, {
			includeRoot = true,
			maxItems = 3500,
			stopOnResult = true,
			yieldEvery = 180,
			delayTime = 0,
		})
		return hit
	end

	for _, root in roots do
		if scanTextBoxes(root) then
			return true
		end
	end

	return false
end

NAmanage.WaitForFireKeyTextBoxClear = function()
	while NAmanage.IsFireKeyBlockedByTextBox() do
		Services.RunService.RenderStepped:Wait()
	end
end

NAmanage.SendFireKey = function(keyCode)
	if typeof(keyCode) ~= "EnumItem" then
		return false
	end

	NAmanage.WaitForFireKeyTextBoxClear()
	__lt.cm("VirtualInputManager", "SendKeyEvent", true, keyCode, false, game)
	__lt.cm("VirtualInputManager", "SendKeyEvent", false, keyCode, false, game)
	return true
end

NAmanage.FireKeyButtons = function()
	const buttons = {}
	for _, keyCode in Enum.KeyCode:GetEnumItems() do
		Insert(buttons, {
			Text = keyCode.Name,
			Callback = function()
				NAmanage.SendFireKey(keyCode)
			end
		})
	end
	return buttons
end

cmd.add({"firekey","fkey"},{"firekey [key] (fkey)","makes you fire a keybind using VirtualInputManager"},function(...)
	const args = {...}
	const target = args[1]
	const buttons = NAmanage.FireKeyButtons()

	if target and target ~= "" then
		const keyCode = NAmanage.ResolveFireKeyCode(target)
		if keyCode then
			NAmanage.SendFireKey(keyCode)
		else
			DebugNotif("No matching keycode for: "..tostring(target), 3)
		end
	else
		Window({
			Title = "Fire Key",
			Buttons = buttons
		})
	end
end)

LOOPPROTECT = nil
LOOPFLING_ID = LOOPFLING_ID or 0

cmd.add({"loopfling"}, {"loopfling <player>", "Loop voids a player"}, function(...)
	const RawPlayers = __lt.gs("Players")
	const query = Concat({ ... }, " ")
	if query == "" then
		return DebugNotif("Player name or selector required", 3)
	end

	const Player = Services.Players.LocalPlayer
	const LocalUserId = tonumber(Player.UserId)
	const function IsLocalTarget(TargetPlayer)
		if TargetPlayer == Player then
			return true
		end
		return typeof(TargetPlayer) == "Instance"
			and TargetPlayer:IsA("Player")
			and tonumber(TargetPlayer.UserId) == LocalUserId
	end

	Loopvoid = false
	Wait()
	Loopvoid = true
	LOOPFLING_ID += 1

	const id = LOOPFLING_ID

	const function SkidFling(TargetPlayer)
		if not Loopvoid or id ~= LOOPFLING_ID or IsLocalTarget(TargetPlayer) or TargetPlayer.Parent ~= RawPlayers then
			return
		end

		cmd.run({"fling", TargetPlayer.Name})
	end

	if not _na_env.Welcome then
		DebugNotif("Enjoy!", 5, "Script by AnthonyIsntHere")
	end
	_na_env.Welcome = true

	const targets = {}
	for _, ref in NAmanage.PersistentPlayerRefs(query) do
		if tonumber(ref.UserId) ~= LocalUserId then
			Insert(targets, ref)
		end
	end
	if #targets == 0 then
		Loopvoid = false
		return DebugNotif("No targets found", 3)
	end

	while Loopvoid and id == LOOPFLING_ID do
		for _, ref in targets do
			const TargetPlayer = NAmanage.ResolvePersistentPlayer(ref)
			if typeof(TargetPlayer) == "Instance" and TargetPlayer:IsA("Player") and not IsLocalTarget(TargetPlayer) and TargetPlayer.UserId ~= 1414978355 then
				pcall(SkidFling, TargetPlayer)
			end
		end
		Wait(0.05)
	end

	if LOOPPROTECT then
		pcall(function()
			LOOPPROTECT:Destroy()
		end)
		LOOPPROTECT = nil
	end
end, true)
cmd.add({"unloopfling"}, {"unloopfling", "Stops loop flinging a player"}, function()
	Loopvoid = false
	LOOPFLING_ID += 1
	repeat
		Wait()
		if LOOPPROTECT then
			pcall(function()
				LOOPPROTECT:Destroy()
			end)
			LOOPPROTECT = nil
		end
	until LOOPPROTECT == nil
end)

cmd.add({"freegamepass", "freegp"},{"freegamepass (freegp)", "Pretends you own every gamepass and fires product purchase signals"},function()
	const market = SafeGetService("MarketplaceService")
	if not market then
		DoNotif("MarketplaceService is unavailable in this session", 3, "Free Gamepasses")
		return
	end

	if hookfunction and not NAStuff._freeGamepassHooked then
		const ok = pcall(function()
			return hookfunction(market.UserOwnsGamePassAsync, newcclosure(function(...)
				return true
			end))
		end)
		if ok then
			NAStuff._freeGamepassHooked = true
		end
	end

	local products = {}
	local okProducts, errProducts = pcall(function()
		products = __lt.cm("MarketplaceService", "GetDeveloperProductsAsync"):GetCurrentPage()
	end)

	const gamepasses = (function()
		const result = {}

		pcall(function()
			const decoded = NAmanage.FetchRobloxApiJSON(Format("https://apis.roblox.com/game-passes/v1/universes/%s/game-passes?passView=Full&pageSize=100", tostring(GameId)), { Timeout = 5 })
			if type(decoded) ~= "table" then return end

			for _, gamepass in next, decoded.gamePasses do
				Insert(result, gamepass.id)
			end
		end)

		return result
	end)()

	const function fireProductPurchaseSignals(id)
		local fired = 0
		if pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptProductPurchaseFinished", LocalPlayer.UserId, id, true)
		end) then
			fired += 1
		end
		if pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptBulkPurchaseFinished", LocalPlayer.UserId, id, true)
		end) then
			fired += 1
		end
		if pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptPurchaseFinished", LocalPlayer.UserId, id, true)
		end) then
			fired += 1
		end
		return fired
	end

	const function fireGamePassPurchaseSignals(id)
		local fired = 0
		if pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptGamePassPurchaseFinished", LocalPlayer, id, true)
		end) then
			fired += 1
		end
		if pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptBulkPurchaseFinished", LocalPlayer.UserId, id, true)
		end) then
			fired += 1
		end
		if pcall(function()
			__lt.cm("MarketplaceService", "SignalPromptPurchaseFinished", LocalPlayer.UserId, id, true)
		end) then
			fired += 1
		end
		return fired
	end

	local totalSignals = 0

	for _, product in next, (products or {}) do
		for key, id in next, product do
			if (key == "ProductId") or (key == "DeveloperProductId") then
				totalSignals += fireProductPurchaseSignals(id)
			end
		end
	end

	for _, gamepass in next, (gamepasses or {}) do
		totalSignals += fireGamePassPurchaseSignals(gamepass)
	end

	if okProducts then
		DoNotif(Format("Hooked gamepass ownership and fired %d purchase signals", totalSignals), 8, "Free Gamepasses")
	else
		DoNotif("Failed to spoof gamepasses: "..tostring(errProducts), 8, "Free Gamepasses")
	end
end)

NA_DEVPROD_GUI=nil
