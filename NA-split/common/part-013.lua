NAmanage.callRaknetDesync = function(rk, enabled)
	if type(rk) ~= "table" and type(rk) ~= "userdata" then
		return false, "raknet unavailable"
	end

	local helper
	const okGet = pcall(function()
		helper = rk.desync
	end)
	if not okGet or type(helper) ~= "function" then
		return false, "raknet.desync unavailable"
	end

	local ok, ret = pcall(helper, enabled == true)
	if ok and ret ~= false then
		return true, ret
	end

	return false, ret or "raknet.desync failed"
end

NAmanage.setRaknetDesync = function(enabled)
	local ok, msg = NAmanage.callRaknetDesync(NAmanage.getRaknet(), enabled == true)
	if not ok then
		return false, msg
	end

	NAStuff.raknetDesyncOn = enabled == true
	if enabled then
		return true, "RakNet desync enabled [raknet.desync(true)]"
	end
	return true, "RakNet desync disabled [raknet.desync(false)]"
end

cmd.add({"raknetdesync", "rkdesync", "rkds", "rkd"},{"raknetdesync (rkdesync,rkds,rkd)","Enables RakNet desync using raknet.desync(true)"},function()
	if NAStuff.raknetDesyncOn then
		DoNotif("RakNet desync is already enabled", 3)
		return
	end

	local ok, msg = NAmanage.setRaknetDesync(true)
	if ok then
		DoNotif(msg, 4)
	else
		DoNotif("Failed to enable RakNet desync: "..tostring(msg), 4)
	end
end)

cmd.add({"unraknetdesync", "unrkdesync", "unrkds", "unrkd"},{"unraknetdesync (unrkdesync,unrkds,unrkd)","Disables RakNet desync using raknet.desync(false)"},function()
	if not NAStuff.raknetDesyncOn then
		DoNotif("RakNet desync is already disabled", 3)
		return
	end

	local ok, msg = NAmanage.setRaknetDesync(false)
	if ok then
		DoNotif(msg, 3)
	else
		DoNotif("Failed to disable RakNet desync: "..tostring(msg), 4)
	end
end)

cmd.add({"runanim", "playanim", "anim"}, {"runanim <id> [speed] (playanim,anim)", "Plays an animation by ID with optional speed multiplier"}, function(id, speed)
	const hum = getHum()
	if not hum then return end
	id = tostring(id)
	speed = tonumber(speed) or 1
	const animator = hum:FindFirstChildOfClass("Animator") or InstanceNew("Animator", hum)
	const anim = InstanceNew("Animation")
	anim.AnimationId = "rbxassetid://"..id
	const track = animator:LoadAnimation(anim)
	track:Play()
	track:AdjustSpeed(speed)
	Delay(track.Length / speed, function()
		track:Stop()
		track:Destroy()
		anim:Destroy()
	end)
end, true)

NAStuff.storedAnims = NAStuff.storedAnims or {}
NAStuff.savedAnims = NAStuff.savedAnims or {}
builderAnim = nil

NAmanage.animBuilderPath = NAmanage.animBuilderPath or (((NAfiles and NAfiles.NAFILEPATH) or "Nameless-Admin").."/AnimBuilder.json")

NAmanage.abFileOk=function()
	return type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"
		and Services.HttpService
		and type(Services.HttpService.JSONEncode) == "function"
		and type(Services.HttpService.JSONDecode) == "function"
end

NAmanage.abDir=function()
	const dir = (NAfiles and NAfiles.NAFILEPATH) or "Nameless-Admin"
	if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return
	end
	local ok, ex = pcall(isfolder, dir)
	if ok and not ex then
		pcall(makefolder, dir)
	end
end

NAmanage.abId=function(raw)
	raw = tostring(raw or ""):match("%d+")
	if raw and raw ~= "" then
		return "rbxassetid://"..raw, raw
	end
end

NAmanage.abRead=function()
	if not NAmanage.abFileOk() then
		return {}
	end
	const path = NAmanage.animBuilderPath
	local okEx, ex = pcall(isfile, path)
	if not okEx or not ex then
		return {}
	end
	local okRead, raw = pcall(readfile, path)
	if not okRead or type(raw) ~= "string" or raw == "" then
		return {}
	end
	local okDec, data = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if okDec and type(data) == "table" then
		return data
	end
	return {}
end

NAmanage.abWrite=function(data)
	if not NAmanage.abFileOk() then
		return false
	end
	NAmanage.abDir()
	local okEnc, enc = pcall(Services.HttpService.JSONEncode, Services.HttpService, data)
	if not okEnc or type(enc) ~= "string" then
		return false
	end
	const okWrite = pcall(writefile, NAmanage.animBuilderPath, enc)
	return okWrite == true
end

NAmanage.abClean=function(src)
	const out = {}
	if type(src) ~= "table" then
		return out
	end
	for k, v in src do
		local _, num = NAmanage.abId(v)
		if num then
			out[tostring(k):lower()] = num
		end
	end
	return out
end

NAmanage.abHas=function(t)
	if type(t) ~= "table" then
		return false
	end
	for _, v in t do
		if NAmanage.abId(v) then
			return true
		end
	end
	return false
end

NAmanage.abRig=function(char)
	local hum
	if typeof(char) == "Instance" then
		hum = char:FindFirstChildWhichIsA("Humanoid",true)
	end
	if not hum then
		if type(IsR6) == "function" and IsR6() then
			return "R6"
		end
		if type(IsR15) == "function" and IsR15() then
			return "R15"
		end
		hum = getHum and getHum()
	end
	if hum and hum.RigType == Enum.HumanoidRigType.R15 then
		return "R15"
	end
	return "R6"
end

NAmanage.abKey=function(rig)
	return tostring(rig or NAmanage.abRig())
end

NAmanage.abLoad=function(rig)
	const rigKey = tostring(rig or NAmanage.abRig())
	const memKey = NAmanage.abKey(rigKey)
	if type(NAStuff.savedAnims) ~= "table" then
		NAStuff.savedAnims = {}
	end
	const mem = NAStuff.savedAnims[memKey]
	if type(mem) == "table" then
		return mem
	end
	const data = NAmanage.abRead()
	local got
	if type(data.rigs) == "table" then
		got = data.rigs[rigKey]
	end
	if type(got) ~= "table" and type(data[rigKey]) == "table" then
		got = data[rigKey]
	end
	got = NAmanage.abClean(got)
	NAStuff.savedAnims[memKey] = got
	return got
end

NAmanage.abSave=function(rig, src)
	const rigKey = tostring(rig or NAmanage.abRig())
	const memKey = NAmanage.abKey(rigKey)
	const data = NAmanage.abRead()
	const clean = NAmanage.abClean(src)
	data._ver = 4
	data.rigs = type(data.rigs) == "table" and data.rigs or {}
	data.rigs[rigKey] = clean
	data.R6 = nil
	data.R15 = nil
	data.animations = nil
	NAStuff.savedAnims[memKey] = clean
	return NAmanage.abWrite(data)
end

NAmanage.abForget=function(rig)
	const rigKey = tostring(rig or NAmanage.abRig())
	const memKey = NAmanage.abKey(rigKey)
	if type(NAStuff.savedAnims) == "table" then
		NAStuff.savedAnims[memKey] = nil
	end
	const data = NAmanage.abRead()
	data._ver = 4
	if type(data.rigs) == "table" then
		data.rigs[rigKey] = nil
	else
		data.rigs = {}
	end
	data[rigKey] = nil
	data.animations = nil
	return NAmanage.abWrite(data)
end

NAmanage.abAutoEnabled=function()
	if type(NAStuff.abAutoReapply) == "boolean" then
		return NAStuff.abAutoReapply
	end
	const data = NAmanage.abRead()
	local got = false
	if type(data.settings) == "table" and type(data.settings.autoReapply) == "boolean" then
		got = data.settings.autoReapply
	end
	NAStuff.abAutoReapply = got
	return got
end

NAmanage.abSetAuto=function(val)
	val = val == true
	NAStuff.abAutoReapply = val
	NAStuff.abAutoApplyRespawn = nil
	const data = NAmanage.abRead()
	data._ver = 5
	data.settings = type(data.settings) == "table" and data.settings or {}
	data.settings.autoReapply = val
	data.settings.autoRespawn = nil
	data.autoRespawn = nil
	return NAmanage.abWrite(data)
end

NAmanage.abStates = NAmanage.abStates or {"Idle","Walk","Run","Jump","Fall","Climb","Swim","Sit"}

NAmanage.abData=function(char)
	local c = typeof(char) == "Instance" and char or nil
	local hum
	if c then
		hum = c:FindFirstChildOfClass("Humanoid")
		if not hum then
			pcall(function() hum = c:WaitForChild("Humanoid", 5) end)
		end
	else
		hum = getHum and getHum()
		c = hum and hum.Parent
	end
	if not hum or not c then return end
	local animate = c:FindFirstChild("Animate")
	if not animate then
		pcall(function() animate = c:WaitForChild("Animate", 5) end)
	end
	if not animate then return end
	return hum, animate
end

NAmanage.abCapture=function(rig, char)
	const rk = tostring(rig or NAmanage.abRig(char))
	const ak = NAmanage.abKey(rk)
	if type(NAStuff.storedAnims) ~= "table" then
		NAStuff.storedAnims = {}
	end
	if type(NAStuff.storedAnims[ak]) == "table" then
		return NAStuff.storedAnims[ak]
	end
	local _, animate = NAmanage.abData(char)
	if not animate then return end
	const store = {}
	for _, v in animate:GetChildren() do
		if v:IsA("StringValue") then
			const a = v:FindFirstChildWhichIsA("Animation")
			if a then
				store[v.Name:lower()] = a.AnimationId
			end
		end
	end
	NAStuff.storedAnims[ak] = store
	return store
end

NAmanage.abSetAnim=function(animate, key, raw)
	local id, num = NAmanage.abId(raw)
	if not id or not animate then return false end
	const sv = animate:FindFirstChild(tostring(key):lower())
	if not sv or not sv:IsA("StringValue") then return false end
	local hit = false
	for _, obj in NAmanage.QueryDescendants(sv, "Animation") do
		obj.AnimationId = id
		hit = true
	end
	const a = sv:FindFirstChildWhichIsA("Animation")
	if a and not hit then
		a.AnimationId = id
		hit = true
	end
	return hit, num
end

NAmanage.abRefresh=function(hum, animate)
	if animate and NAlib and NAlib.isProperty and NAlib.isProperty(animate, "Disabled") ~= nil then
		pcall(function()
			animate.Disabled = true
			Delay(0.04, function()
				if animate and animate.Parent then
					animate.Disabled = false
				end
			end)
		end)
	elseif hum then
		pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
	end
end

NAmanage.abApply=function(src, rig, opts)
	opts = type(opts) == "table" and opts or {}
	const char = opts.char
	const rk = tostring(rig or NAmanage.abRig(char))
	const cur = NAmanage.abRig(char)
	if cur ~= rk then
		return false, "rig"
	end
	local hum, animate = NAmanage.abData(char)
	if not animate then
		return false, "animate"
	end
	NAmanage.abCapture(rk, char)
	const data = NAmanage.abClean(src or NAmanage.abLoad(rk))
	if not NAmanage.abHas(data) then
		return false, "empty"
	end
	local did = false
	for _, n in NAmanage.abStates do
		const key = Lower(n)
		local ok, num = NAmanage.abSetAnim(animate, key, data[key])
		if ok then
			did = true
			if opts.inputs and opts.inputs[key] then
				opts.inputs[key].Text = num or ""
			end
		end
	end
	if did and opts.refresh ~= false then
		NAmanage.abRefresh(hum, animate)
	end
	return did, did and "ok" or "none"
end

NAmanage.abApplySaved=function(rig, opts)
	const char = type(opts) == "table" and opts.char or nil
	const rk = tostring(rig or NAmanage.abRig(char))
	const data = NAmanage.abLoad(rk)
	return NAmanage.abApply(data, rk, opts)
end

NAmanage.abQueue=function(char, force)
	if force ~= true and not NAmanage.abAutoEnabled() then return end
	NAStuff.abTok = (NAStuff.abTok or 0) + 1
	const tok = NAStuff.abTok
	for _, d in {0.15, 0.75, 1.5} do
		Delay(d, function()
			if NAStuff.abTok ~= tok then return end
			if force ~= true and not NAmanage.abAutoEnabled() then return end
			const rk = NAmanage.abRig(char)
			NAmanage.abApplySaved(rk, {char = char, silent = true, refresh = true})
		end)
	end
end


cmd.add({"animbuilder","abuilder"},{"animbuilder (abuilder)","Opens animation builder GUI"},function()
	if builderAnim then NACaller(function() builderAnim:Destroy() end) builderAnim = nil end
	const rig = NAmanage.abRig()
	const animKey = NAmanage.abKey(rig)
	local autoApply = NAmanage.abAutoEnabled()
	local abMinimized = false
	local abPlaced = false
	const cons = {}

	NAmanage.abTrack=function(conn)
		cons[#cons + 1] = conn
		return conn
	end

	NAmanage.abClearCons=function()
		for i = 1, #cons do
			if cons[i] then
				pcall(function() cons[i]:Disconnect() end)
				cons[i] = nil
			end
		end
	end

	NAmanage.getData=NAmanage.abData

	if not NAmanage.abCapture(rig) then return end

	local savedData = NAmanage.abLoad(rig)

	builderAnim = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(builderAnim)
	builderAnim.Name = "AnimationBuilder"
	builderAnim.ResetOnSpawn = false
	builderAnim.IgnoreGuiInset = true
	pcall(function() builderAnim.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)
	pcall(function() builderAnim.ClipToDeviceSafeArea = true end)
	pcall(function() builderAnim.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension end)

	const main = InstanceNew("Frame", builderAnim)
	main.AnchorPoint = Vector2.new(0.5,0.5)
	main.Size = UDim2.new(0, 660, 0, 500)
	main.Position = UDim2.new(0.5,0,0.5,0)
	main.BackgroundColor3 = Color3.fromRGB(16,17,22)
	main.BackgroundTransparency = 0.03
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	InstanceNew("UICorner", main).CornerRadius = UDim.new(0, 6)
	const mainStroke = InstanceNew("UIStroke", main)
	mainStroke.Color = Color3.fromRGB(65,68,82)
	mainStroke.Thickness = 1
	mainStroke.Transparency = 0.1

	const uiScale = InstanceNew("UIScale", main)
	uiScale.Scale = 1

	local headerH = 74
	local footerH = 74
	local isMob = false

	const header = InstanceNew("Frame", main)
	header.Size = UDim2.new(1,0,0,headerH)
	header.BackgroundColor3 = Color3.fromRGB(20,21,28)
	header.BorderSizePixel = 0
	InstanceNew("UICorner", header).CornerRadius = UDim.new(0, 6)

	const title = InstanceNew("TextLabel", header)
	title.Position = UDim2.new(0,20,0,10)
	title.Size = UDim2.new(1,-86,0,30)
	title.BackgroundTransparency = 1
	title.Text = "Animation Builder · "..rig
	title.TextColor3 = Color3.fromRGB(245,246,250)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 21
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.TextTruncate = Enum.TextTruncate.AtEnd

	const sub = InstanceNew("TextLabel", header)
	sub.Position = UDim2.new(0,20,0,42)
	sub.Size = UDim2.new(1,-86,0,20)
	sub.BackgroundTransparency = 1
	sub.Text = "Edit "..rig.." Animate IDs, test, save, or auto re-apply"
	sub.TextColor3 = Color3.fromRGB(150,154,170)
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 13
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextYAlignment = Enum.TextYAlignment.Center
	sub.TextTruncate = Enum.TextTruncate.AtEnd

	const closeBtn = InstanceNew("TextButton", header)
	closeBtn.Position = UDim2.new(1,-52,0,20)
	closeBtn.Size = UDim2.new(0,34,0,34)
	closeBtn.BackgroundColor3 = Color3.fromRGB(36,37,48)
	closeBtn.BackgroundTransparency = 0.05
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255,105,105)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.AutoButtonColor = true
	InstanceNew("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
	const closeStroke = InstanceNew("UIStroke", closeBtn)
	closeStroke.Color = Color3.fromRGB(68,70,86)
	closeStroke.Transparency = 0.3

	const minBtn = InstanceNew("TextButton", header)
	minBtn.Position = UDim2.new(1,-92,0,20)
	minBtn.Size = UDim2.new(0,34,0,34)
	minBtn.BackgroundColor3 = Color3.fromRGB(36,37,48)
	minBtn.BackgroundTransparency = 0.05
	minBtn.Text = "–"
	minBtn.TextColor3 = Color3.fromRGB(210,215,235)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 18
	minBtn.AutoButtonColor = true
	InstanceNew("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
	const minStroke = InstanceNew("UIStroke", minBtn)
	minStroke.Color = Color3.fromRGB(68,70,86)
	minStroke.Transparency = 0.3

	const scroll = InstanceNew("ScrollingFrame", main)
	scroll.Position = UDim2.new(0,14,0,headerH + 12)
	scroll.Size = UDim2.new(1,-28,1,-headerH-footerH-24)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Color3.fromRGB(94,98,118)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0,0,0,0)

	const pad = InstanceNew("UIPadding", scroll)
	pad.PaddingTop = UDim.new(0,2)
	pad.PaddingBottom = UDim.new(0,2)
	pad.PaddingLeft = UDim.new(0,2)
	pad.PaddingRight = UDim.new(0,8)

	const list = InstanceNew("UIListLayout", scroll)
	list.Padding = UDim.new(0, 8)
	list.SortOrder = Enum.SortOrder.LayoutOrder

	const footer = InstanceNew("Frame", main)
	footer.Position = UDim2.new(0,0,1,-footerH)
	footer.Size = UDim2.new(1,0,0,footerH)
	footer.BackgroundColor3 = Color3.fromRGB(18,19,25)
	footer.BorderSizePixel = 0

	const bar = InstanceNew("Frame", footer)
	bar.Position = UDim2.new(0,20,0,13)
	bar.Size = UDim2.new(1,-40,0,46)
	bar.BackgroundTransparency = 1

	const states = NAmanage.abStates
	const inputs = {}
	const rows = {}
	local autoBtn

	NAmanage.abAutoText=function()
		autoBtn.Text = autoApply and "Auto Re-apply: ON" or "Auto Re-apply: OFF"
		autoBtn.BackgroundColor3 = autoApply and Color3.fromRGB(94,92,162) or Color3.fromRGB(72,74,88)
	end

	NAmanage.abStatus=function(txt, col)
		sub.Text = txt or ""
		sub.TextColor3 = col or Color3.fromRGB(150,154,170)
	end

	NAmanage.abButton=function(parent, text, col, pos)
		const b = InstanceNew("TextButton", parent)
		b.Position = pos
		b.Size = UDim2.new(0.333,-8,1,0)
		b.BackgroundColor3 = col
		b.BackgroundTransparency = 0
		b.BorderSizePixel = 0
		b.Text = text
		b.TextColor3 = Color3.fromRGB(248,248,252)
		b.Font = Enum.Font.GothamSemibold
		b.TextSize = 15
		b.AutoButtonColor = true
		InstanceNew("UICorner", b).CornerRadius = UDim.new(0, 6)
		const st = InstanceNew("UIStroke", b)
		st.Color = Color3.fromRGB(255,255,255)
		st.Transparency = 0.88
		st.Thickness = 1
		return b
	end

	const apply = NAmanage.abButton(bar, "Apply Test", Color3.fromRGB(70,104,178), UDim2.new(0,0,0,0))
	const save = NAmanage.abButton(bar, "Save", Color3.fromRGB(56,137,78), UDim2.new(0.333,4,0,0))
	autoBtn = NAmanage.abButton(bar, "Auto Re-apply: ON", Color3.fromRGB(94,92,162), UDim2.new(0.666,8,0,0))
	NAmanage.abAutoText()
	const revert = NAmanage.abButton(bar, "Revert", Color3.fromRGB(150,76,78), UDim2.new(0,0,0,50))
	const forget = NAmanage.abButton(bar, "Forget", Color3.fromRGB(82,84,100), UDim2.new(0.5,4,0,50))

	NAmanage.abVP=function()
		const cam = Services.Workspace.CurrentCamera
		local vp = cam and cam.ViewportSize
		if not vp or vp.X <= 0 or vp.Y <= 0 then
			vp = Vector2.new(660, 500)
		end
		return vp
	end

	NAmanage.abArea=function()
		local area
		pcall(function()
			area = main.Parent and main.Parent.AbsoluteSize
		end)
		if typeof(area) ~= "Vector2" or area.X <= 0 or area.Y <= 0 then
			area = NAmanage.abVP()
		end
		return area
	end

	NAmanage.abSetTopLeft=function(x, y, w, h)
		const area = NAmanage.abArea()
		const maxX = math.max(4, area.X - w - 4)
		const maxY = math.max(4, area.Y - h - 4)
		x = math.clamp(math.floor((tonumber(x) or 4) + 0.5), 4, maxX)
		y = math.clamp(math.floor((tonumber(y) or 4) + 0.5), 4, maxY)
		main.Position = UDim2.new((x + (w * main.AnchorPoint.X)) / area.X, 0, (y + (h * main.AnchorPoint.Y)) / area.Y, 0)
	end

	NAmanage.abFit=function()
		const vp = NAmanage.abVP()
		const area = NAmanage.abArea()
		const old = main.AbsolutePosition
		local oldX = old and old.X or 0
		local oldY = old and old.Y or 0
		const touch = IsOnMobile == true
		isMob = vp.X <= 560 or vp.Y <= 520 or (touch and vp.X <= 900)
		const mx = isMob and 12 or 80
		const my = isMob and 12 or 80
		const minW = math.min(300, math.max(240, vp.X - 8))
		const minH = math.min(340, math.max(300, vp.Y - 8))
		const maxW = isMob and 560 or 660
		const maxH = isMob and 620 or 520
		const w = math.clamp(vp.X - mx, minW, maxW)
		local h = math.clamp(vp.Y - my, minH, maxH)
		headerH = isMob and 62 or 74
		footerH = isMob and 236 or 122
		if abMinimized then
			h = headerH
		end
		if not abPlaced then
			oldX = math.floor((area.X - w) * 0.5)
			oldY = math.floor((area.Y - h) * 0.5)
			abPlaced = true
		end
		uiScale.Scale = vp.X <= 320 and math.clamp(vp.X / 320, 0.84, 1) or 1
		main.Size = UDim2.new(0, w, 0, h)
		NAmanage.abSetTopLeft(oldX, oldY, w, h)
		header.Size = UDim2.new(1, 0, 0, headerH)
		title.Position = UDim2.new(0, isMob and 16 or 20, 0, isMob and 8 or 10)
		title.Size = UDim2.new(1, isMob and -106 or -126, 0, isMob and 26 or 30)
		title.TextSize = isMob and 18 or 21
		sub.Position = UDim2.new(0, isMob and 16 or 20, 0, isMob and 35 or 42)
		sub.Size = UDim2.new(1, isMob and -106 or -126, 0, isMob and 18 or 20)
		sub.TextSize = isMob and 11 or 13
		minBtn.Position = UDim2.new(1, isMob and -82 or -92, 0, isMob and 14 or 20)
		minBtn.Size = UDim2.new(0, isMob and 32 or 34, 0, isMob and 32 or 34)
		minBtn.TextSize = isMob and 17 or 18
		minBtn.Text = abMinimized and "+" or "–"
		closeBtn.Position = UDim2.new(1, isMob and -46 or -52, 0, isMob and 14 or 20)
		closeBtn.Size = UDim2.new(0, isMob and 32 or 34, 0, isMob and 32 or 34)
		closeBtn.TextSize = isMob and 15 or 16
		scroll.Visible = not abMinimized
		footer.Visible = not abMinimized
		scroll.Position = UDim2.new(0, isMob and 10 or 14, 0, headerH + (isMob and 8 or 12))
		scroll.Size = UDim2.new(1, isMob and -20 or -28, 1, -headerH - footerH - (isMob and 16 or 24))
		scroll.ScrollBarThickness = isMob and 3 or 4
		footer.Position = UDim2.new(0, 0, 1, -footerH)
		footer.Size = UDim2.new(1, 0, 0, footerH)
		bar.Position = UDim2.new(0, isMob and 12 or 20, 0, isMob and 10 or 13)
		bar.Size = UDim2.new(1, isMob and -24 or -40, 1, isMob and -20 or -28)
		if isMob then
			apply.Position = UDim2.new(0, 0, 0, 0)
			save.Position = UDim2.new(0, 0, 0, 40)
			autoBtn.Position = UDim2.new(0, 0, 0, 80)
			revert.Position = UDim2.new(0, 0, 0, 120)
			forget.Position = UDim2.new(0, 0, 0, 160)
			apply.Size = UDim2.new(1, 0, 0, 36)
			save.Size = UDim2.new(1, 0, 0, 36)
			autoBtn.Size = UDim2.new(1, 0, 0, 36)
			revert.Size = UDim2.new(1, 0, 0, 36)
			forget.Size = UDim2.new(1, 0, 0, 36)
		else
			apply.Position = UDim2.new(0, 0, 0, 0)
			save.Position = UDim2.new(0.333, 4, 0, 0)
			autoBtn.Position = UDim2.new(0.666, 8, 0, 0)
			revert.Position = UDim2.new(0, 0, 0, 50)
			forget.Position = UDim2.new(0.5, 4, 0, 50)
			apply.Size = UDim2.new(0.333, -8, 0, 40)
			save.Size = UDim2.new(0.333, -8, 0, 40)
			autoBtn.Size = UDim2.new(0.333, -8, 0, 40)
			revert.Size = UDim2.new(0.5, -6, 0, 40)
			forget.Size = UDim2.new(0.5, -6, 0, 40)
		end
		for _, row in rows do
			const r = row.r
			const label = row.label
			const box = row.box
			if isMob then
				r.Size = UDim2.new(1, 0, 0, 76)
				label.Position = UDim2.new(0, 14, 0, 7)
				label.Size = UDim2.new(1, -28, 0, 22)
				label.TextSize = 14
				box.Position = UDim2.new(0, 12, 0, 34)
				box.Size = UDim2.new(1, -24, 0, 34)
				box.TextSize = 14
			else
				r.Size = UDim2.new(1, 0, 0, 50)
				label.Position = UDim2.new(0, 16, 0, 0)
				label.Size = UDim2.new(0, 116, 1, 0)
				label.TextSize = 15
				box.Position = UDim2.new(0, 132, 0.5, -17)
				box.Size = UDim2.new(1, -148, 0, 34)
				box.TextSize = 15
			end
		end
	end

	NAmanage.makeRow=function(name, ord)
		const r = InstanceNew("Frame", scroll)
		r.Name = "AnimRow_"..name
		r.LayoutOrder = ord
		r.Size = UDim2.new(1,0,0,50)
		r.BackgroundColor3 = Color3.fromRGB(27,28,36)
		r.BackgroundTransparency = 0
		r.BorderSizePixel = 0
		InstanceNew("UICorner", r).CornerRadius = UDim.new(0, 6)
		const rs = InstanceNew("UIStroke", r)
		rs.Color = Color3.fromRGB(54,57,70)
		rs.Thickness = 1
		rs.Transparency = 0.18

		const label = InstanceNew("TextLabel", r)
		label.Position = UDim2.new(0,16,0,0)
		label.Size = UDim2.new(0,116,1,0)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Color3.fromRGB(232,234,242)
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = 15
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center

		const box = InstanceNew("TextBox", r)
		box.Position = UDim2.new(0,132,0.5,-17)
		box.Size = UDim2.new(1,-148,0,34)
		box.Text = ""
		box.PlaceholderText = "animation id"
		box.ClearTextOnFocus = false
		box.TextColor3 = Color3.fromRGB(245,246,250)
		box.PlaceholderColor3 = Color3.fromRGB(118,122,138)
		box.BackgroundColor3 = Color3.fromRGB(40,42,52)
		box.BorderSizePixel = 0
		box.Font = Enum.Font.Gotham
		box.TextSize = 15
		box.TextXAlignment = Enum.TextXAlignment.Center
		box.TextYAlignment = Enum.TextYAlignment.Center
		box.TextTruncate = Enum.TextTruncate.AtEnd
		InstanceNew("UICorner", box).CornerRadius = UDim.new(0, 6)
		const bs = InstanceNew("UIStroke", box)
		bs.Color = Color3.fromRGB(58,61,74)
		bs.Transparency = 0.15
		bs.Thickness = 1

		NAmanage.abTrack(box.Focused:Connect(function()
			bs.Color = Color3.fromRGB(115,135,255)
			bs.Transparency = 0
			box.BackgroundColor3 = Color3.fromRGB(46,48,60)
		end))

		NAmanage.abTrack(box.FocusLost:Connect(function()
			bs.Color = Color3.fromRGB(58,61,74)
			bs.Transparency = 0.15
			box.BackgroundColor3 = Color3.fromRGB(40,42,52)
		end))

		NAmanage.abTrack(box:GetPropertyChangedSignal("Text"):Connect(function()
			const clean = box.Text:gsub("%D","")
			if box.Text ~= clean then box.Text = clean end
		end))

		inputs[Lower(name)] = box
		rows[Lower(name)] = {r = r, label = label, box = box}
	end

	for i, n in states do NAmanage.makeRow(n, i) end
	NAmanage.abFit()
	const cam = Services.Workspace.CurrentCamera
	if cam then
		NAmanage.abTrack(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			NAmanage.abFit()
		end))
	end
	NAmanage.abTrack(Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Defer(NAmanage.abFit)
	end))

	NAmanage.setBoxes=function(src, fallback)
		for _, k in states do
			const key = Lower(k)
			local raw = src and src[key]
			if not NAmanage.abId(raw) then
				raw = fallback and fallback[key]
			end
			local _, num = NAmanage.abId(raw)
			inputs[key].Text = num or ""
		end
	end

	NAmanage.applyAnims=function(mode)
		const curRig = NAmanage.abRig()
		if curRig ~= rig then
			NAmanage.abStatus("Rig changed to "..curRig.."; reopen AnimBuilder", Color3.fromRGB(255,205,120))
			DoNotif("Rig changed. Reopen AnimBuilder")
			return
		end
		if mode == "save" or mode == "test" then
			const out = {}
			for _, k in states do
				const key = Lower(k)
				local _, num = NAmanage.abId(inputs[key].Text)
				if num then
					out[key] = num
				end
			end
			const applied = NAmanage.abApply(out, rig, {inputs = inputs, refresh = true})
			if not applied then
				NAmanage.abStatus(mode == "save" and "No valid animation IDs to save" or "No valid animation IDs to apply", Color3.fromRGB(255,120,120))
				DoNotif(mode == "save" and "No valid animation IDs to save" or "No valid animation IDs to apply")
				return
			end
			if mode == "test" then
				NAmanage.abStatus("Applied test "..rig.." animations without saving", Color3.fromRGB(120,190,255))
				DoNotif("Applied test animations without saving")
				return
			end
			const ok = NAmanage.abSave(rig, out)
			savedData = NAmanage.abLoad(rig)
			NAmanage.abQueue(getChar and getChar())
			if ok then
				NAmanage.abStatus("Saved and applied "..rig.." animations", Color3.fromRGB(120,220,145))
				DoNotif("Saved and applied "..rig.." animations")
			else
				NAmanage.abStatus("Applied, but file save failed", Color3.fromRGB(255,205,120))
				DoNotif("Applied animations, but file save failed")
			end
		else
			const raw = NAStuff.storedAnims[animKey]
			const applied = NAmanage.abApply(raw, rig, {inputs = inputs, refresh = true})
			if applied then
				NAmanage.abStatus("Reverted "..rig.." Animate values", Color3.fromRGB(255,205,120))
				DoNotif("Reverted "..rig.." animations")
			else
				NAmanage.abStatus("No "..rig.." default animations captured", Color3.fromRGB(255,120,120))
				DoNotif("No "..rig.." default animations captured")
			end
		end
	end

	NAmanage.abClose=function()
		NAmanage.abClearCons()
		const pos = main.AbsolutePosition
		const sz = main.AbsoluteSize
		const area = NAmanage.abArea()
		main.Position = UDim2.new((pos.X + sz.X * main.AnchorPoint.X) / area.X, 0, (pos.Y + sz.Y * main.AnchorPoint.Y) / area.Y, 0)
		const t = __lt.cm("TweenService", "Create", main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
			Size = UDim2.new(0, 12, 0, 12),
			BackgroundTransparency = 1
		})
		t:Play()
		t.Completed:Wait()
		NACaller(function() builderAnim:Destroy() end)
		builderAnim = nil
	end

	NAmanage.setBoxes(savedData, NAStuff.storedAnims[animKey])
	if NAmanage.abHas(savedData) then
		if autoApply then
			const applied = NAmanage.abApply(savedData, rig, {inputs = inputs, refresh = true})
			if applied then
				NAmanage.abStatus("Loaded and auto re-applied saved "..rig.." animations", Color3.fromRGB(120,220,145))
				DoNotif("Loaded and auto re-applied saved "..rig.." animations")
			else
				NAmanage.abStatus("Loaded saved "..rig.." values, but could not apply", Color3.fromRGB(255,205,120))
				DoNotif("Loaded saved values, but could not apply")
			end
		else
			NAmanage.abStatus("Loaded saved "..rig.." values", Color3.fromRGB(150,154,170))
		end
	else
		NAmanage.abStatus("Edit "..rig.." Animate IDs, test, save, or auto re-apply", Color3.fromRGB(150,154,170))
	end

	MouseButtonFix(closeBtn, function() NAmanage.abClose() end)
	MouseButtonFix(minBtn, function()
		abMinimized = not abMinimized
		NAmanage.abFit()
	end)
	MouseButtonFix(apply, function() NAmanage.applyAnims("test") end)
	MouseButtonFix(save, function() NAmanage.applyAnims("save") end)
	MouseButtonFix(autoBtn, function()
		autoApply = not autoApply
		NAmanage.abSetAuto(autoApply)
		NAmanage.abAutoText()
		NAmanage.abStatus(autoApply and "Auto Re-apply enabled" or "Auto Re-apply disabled", autoApply and Color3.fromRGB(120,220,145) or Color3.fromRGB(255,205,120))
		DoNotif(autoApply and "Auto Re-apply enabled" or "Auto Re-apply disabled")
	end)
	MouseButtonFix(revert, function() NAmanage.applyAnims("revert") end)
	MouseButtonFix(forget, function()
		const ok = NAmanage.abForget(rig)
		savedData = {}
		NAmanage.setBoxes(nil, NAStuff.storedAnims[animKey])
		if ok then
			NAmanage.abStatus("Forgot saved "..rig.." Animation Builder values", Color3.fromRGB(255,205,120))
			DoNotif("Forgot saved "..rig.." Animation Builder values")
		else
			NAmanage.abStatus("Cleared saved values for this session only", Color3.fromRGB(255,205,120))
			DoNotif("Cleared saved values for this session only")
		end
	end)

	NAgui.dragger(main, header)
end)


cmd.add({"setkiller", "killeranim"}, {"setkiller (killeranim)", "Sets killer animation set"}, function()
	if not IsR6() then DoNotif("command requires R6") return end
	const hum = getHum()
	if not hum then return end

	const animate = hum.Parent:FindFirstChild("Animate")
	if not animate then return end

	if not NAStuff.storedAnims[hum] then
		const store = {}
		for _, obj in animate:GetChildren() do
			if obj:IsA("StringValue") then
				const anim = obj:FindFirstChildWhichIsA("Animation")
				if anim then
					store[obj.Name] = anim.AnimationId
				end
			end
		end
		NAStuff.storedAnims[hum] = store
	end

	const function setAnim(name, id)
		const obj = animate:FindFirstChild(name)
		if obj and obj:IsA("StringValue") then
			const anim = obj:FindFirstChildWhichIsA("Animation")
			if anim then
				anim.AnimationId = "rbxassetid://"..tostring(id)
			end
		end
	end

	setAnim("walk", 252557606)
	setAnim("run", 252557606)
	setAnim("jump", 165167557)
	setAnim("fall", 97170520)
end)

cmd.add({"setpsycho", "psychoanim"}, {"setpsycho (psychoanim)", "Sets psycho animation set"}, function()
	if not IsR6() then DoNotif("command requires R6") return end
	const hum = getHum()
	if not hum then return end

	const animate = hum.Parent:FindFirstChild("Animate")
	if not animate then return end

	if not NAStuff.storedAnims[hum] then
		const store = {}
		for _, obj in animate:GetChildren() do
			if obj:IsA("StringValue") then
				const anim = obj:FindFirstChildWhichIsA("Animation")
				if anim then
					store[obj.Name] = anim.AnimationId
				end
			end
		end
		NAStuff.storedAnims[hum] = store
	end

	const function setAnim(name, id)
		const obj = animate:FindFirstChild(name)
		if obj and obj:IsA("StringValue") then
			const anim = obj:FindFirstChildWhichIsA("Animation")
			if anim then
				anim.AnimationId = "rbxassetid://"..tostring(id)
			end
		end
	end

	setAnim("idle", 33796059)
	setAnim("walk", 95415492)
	setAnim("run", 95415492)
	setAnim("jump", 165167557)
	setAnim("fall", 97170520)

	const animator = hum:FindFirstChildOfClass("Animator")
	if not animator then return end

	SpawnCall(function()
		while hum and hum.Parent and hum.Health > 0 do
			for _, track in animator:GetPlayingAnimationTracks() do
				if track.Animation.AnimationId == "rbxassetid://33796059" and track.Speed < 50 then
					track:AdjustSpeed(50)
				end
			end
			Wait(0.2)
		end
	end)
end)

cmd.add({"resetanims", "defaultanims", "animsreset"}, {"resetanims (defaultanims,animsreset)", "Restores your previous animations"}, function()
	if not IsR6() then DoNotif("command requires R6") return end
	const hum = getHum()
	if not hum then return end

	const animate = hum.Parent:FindFirstChild("Animate")
	if not animate then return end

	const store = NAStuff.storedAnims[hum]
	if not store then return end

	for name, id in store do
		const obj = animate:FindFirstChild(name)
		if obj and obj:IsA("StringValue") then
			const anim = obj:FindFirstChildWhichIsA("Animation")
			if anim then
				anim.AnimationId = id
			end
		end
	end

	NAStuff.storedAnims[hum] = nil
end)

cmd.add({"animcopycore","animcopy","copyanim","copyan"}, {"animcopycore <player|npc:filter>","Copy core animations from a player or NPC"}, function(targetArg)
	if not targetArg or targetArg == "" then return end
	const targets = getPlr(targetArg)
	const target = targets and targets[1]
	if not target then return end
	const myChar = getChar()
	const targetChar = getPlrChar(target)
	if not (myChar and targetChar) then return end
	const myHum = getPlrHum(myChar)
	const targetHum = getPlrHum(targetChar)
	if not (myHum and targetHum) then return end
	const myAnimate = myChar:FindFirstChild("Animate")
	const targetAnimate = targetChar:FindFirstChild("Animate")
	if not (myAnimate and targetAnimate) then return end
	const function mapAnims(root)
		const t = {}
		for _, inst in NAmanage.QueryDescendants(root, "Animation") do
			const k = Lower(((inst.Parent and inst.Parent.Name) or "root").."|"..inst.Name)
			t[k] = inst
		end
		return t
	end
	const function refresh(hum)
		const char = hum and hum.Parent
		const animScr = char and char:FindFirstChild("Animate")
		if animScr and NAlib.isProperty(animScr, "Disabled") ~= nil then
			animScr.Disabled = true
			animScr.Disabled = false
		else
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
		end
	end
	const function captureDefaults()
		if NAStuff.SavedDefaultMap then return end
		if not myAnimate then return end
		NAStuff.SavedDefaultMap = {}
		for _, a in NAmanage.QueryDescendants(myAnimate, "Animation") do
			const parentName = Lower((a.Parent and a.Parent.Name) or "root")
			if NAStuff.CORE_FOLDERS[parentName] then
				const key = Lower(parentName.."|"..a.Name)
				NAStuff.SavedDefaultMap[key] = a.AnimationId
			end
		end
	end
	captureDefaults()
	const src = mapAnims(targetAnimate)
	const dst = mapAnims(myAnimate)
	for key, dstAnim in dst do
		const folder = Match(key, "([^|]+)|")
		if NAStuff.CORE_FOLDERS[folder or ""] then
			const srcAnim = src[key]
			if srcAnim and srcAnim.AnimationId ~= "" and dstAnim.AnimationId ~= srcAnim.AnimationId then
				dstAnim.AnimationId = srcAnim.AnimationId
			end
		end
	end
	refresh(myHum)
end)

cmd.add({"syncanim","animsync"}, {"syncanim <player|npc:filter>","Mirror player or NPC animations (live)"}, function(targetArg)
	if not targetArg or targetArg == "" then return end
	const targets = getPlr(targetArg)
	const target = targets and targets[1]
	if not target then return end

	const myChar = getChar()
	const targetChar = getPlrChar(target)
	if not (myChar and targetChar) then return end

	const myHum = getPlrHum(myChar)
	const targetHum = getPlrHum(targetChar)
	if not (myHum and targetHum) then return end
	if myHum.RigType ~= targetHum.RigType then return end

	const function getAnimator(hum, create)
		if not hum then return nil end
		const a = hum:FindFirstChildOfClass("Animator")
		if a then return a end
		if create then return InstanceNew("Animator", hum) end
	end

	const myAnimator = getAnimator(myHum, true)
	const targetAnimator = getAnimator(targetHum, false)
	if not targetAnimator then return end

	if type(NAStuff.Sync_Stop) == "function" then
		pcall(NAStuff.Sync_Stop)
	else
		NAlib.disconnect(NAStuff.SYNC_TAG)
	end

	const myAnimate = myChar:FindFirstChild("Animate")
	if myAnimate and NAlib.isProperty(myAnimate, "Disabled") ~= nil then
		NAStuff.Sync_AnimatePrevDisabled = myAnimate.Disabled
		myAnimate.Disabled = true
	end

	for _, tr in myAnimator:GetPlayingAnimationTracks() do pcall(function() tr:Stop(0) end) end

	local stopped = false
	const slots = {}
	const ownedTracks = {}
	const activeSources = {}

	const function getTrackWeight(track)
		local ok, weight = pcall(function()
			return track.WeightCurrent
		end)
		weight = ok and tonumber(weight) or nil
		if not weight then
			local okTarget, targetWeight = pcall(function()
				return track.WeightTarget
			end)
			weight = okTarget and tonumber(targetWeight) or nil
		end
		return weight or 1
	end

	const function restoreAnimate()
		const anim = myChar and myChar:FindFirstChild("Animate")
		if anim and NAlib.isProperty(anim, "Disabled") ~= nil then
			if NAStuff.Sync_AnimatePrevDisabled ~= nil then
				anim.Disabled = NAStuff.Sync_AnimatePrevDisabled
			else
				anim.Disabled = false
			end
			anim.Disabled = true
			anim.Disabled = false
		end
	end

	const function stopAndRestore()
		if stopped then return end
		stopped = true
		NAlib.disconnect(NAStuff.SYNC_TAG)
		const tracks = {}
		for track in ownedTracks do
			tracks[#tracks + 1] = track
		end
		for _, track in tracks do
			pcall(function() track:Stop(0) end)
			ownedTracks[track] = nil
		end
		for _, tr in myAnimator:GetPlayingAnimationTracks() do pcall(function() tr:Stop(0) end) end
		restoreAnimate()
		pcall(function() myHum:ChangeState(Enum.HumanoidStateType.Jumping) end)
		NAStuff.Sync_AnimatePrevDisabled = nil
		NAStuff.Sync_Stop = nil
	end

	NAStuff.Sync_Stop = stopAndRestore

	const function keepOnlySynced()
		for _, tr in myAnimator:GetPlayingAnimationTracks() do
			if not ownedTracks[tr] then
				pcall(function() tr:Stop(0) end)
			end
		end
		if myAnimate and NAlib.isProperty(myAnimate, "Disabled") ~= nil and not myAnimate.Disabled then
			myAnimate.Disabled = true
		end
	end

	const function captureTracks()
		const list = {}
		for _, track in targetAnimator:GetPlayingAnimationTracks() do
			const anim = track.Animation
			const animId = anim and anim.AnimationId
			if animId and animId ~= "" then
				list[#list + 1] = {
					source = track,
					animId = animId,
					time = tonumber(track.TimePosition) or 0,
					speed = (type(track.Speed) == "number" and track.Speed) or 1,
					looped = track.Looped and true or false,
					priority = track.Priority,
					weight = getTrackWeight(track),
				}
			end
		end
		return list
	end

	const function loadSlot(trackState)
		local old = slots[trackState.source]
		if old and old.track and (old.animId ~= trackState.animId or not old.track.IsPlaying) then
			ownedTracks[old.track] = nil
			pcall(function() old.track:Stop(0) end)
			old = nil
			slots[trackState.source] = nil
		end
		if old and old.track then
			return old
		end
		const anim = InstanceNew("Animation")
		anim.AnimationId = trackState.animId
		local okLoad, mt = pcall(function()
			return myAnimator:LoadAnimation(anim)
		end)
		if not okLoad or not mt then return nil end
		pcall(function()
			mt.Priority = trackState.priority or mt.Priority
			mt.Looped = trackState.looped
			mt:Play(0, math.clamp(trackState.weight or 1, 0, 1), trackState.speed or 1)
			mt.TimePosition = trackState.time or 0
			mt:AdjustWeight(math.clamp(trackState.weight or 1, 0, 1), 0)
		end)
		ownedTracks[mt] = true
		old = {track = mt, animId = trackState.animId}
		slots[trackState.source] = old
		return old
	end

	const function applyTracks(trackStates)
		table.clear(activeSources)
		for _, trackState in trackStates or {} do
			activeSources[trackState.source] = true
			const slot = loadSlot(trackState)
			const mt = slot and slot.track
			if mt then
				pcall(function()
					if mt.Priority ~= trackState.priority then mt.Priority = trackState.priority end
					if mt.Looped ~= trackState.looped then mt.Looped = trackState.looped end
					mt:AdjustSpeed(trackState.speed or 1)
					mt:AdjustWeight(math.clamp(trackState.weight or 1, 0, 1), 0)
					if math.abs((mt.TimePosition or 0) - (trackState.time or 0)) > 0.05 then
						mt.TimePosition = trackState.time or 0
					end
				end)
			end
		end
		const stale = {}
		for source in slots do
			if not activeSources[source] then
				stale[#stale + 1] = source
			end
		end
		for _, source in stale do
			const slot = slots[source]
			if slot and slot.track then
				ownedTracks[slot.track] = nil
				pcall(function() slot.track:Stop(0) end)
			end
			slots[source] = nil
		end
		keepOnlySynced()
	end

	applyTracks(captureTracks())

	NAlib.connect(NAStuff.SYNC_TAG, targetHum.AnimationPlayed:Connect(function()
		applyTracks(captureTracks())
	end))

	NAlib.connect(NAStuff.SYNC_TAG, Services.RunService.Heartbeat:Connect(function()
		if stopped then return end
		if not (myChar and myChar.Parent and myHum and myHum.Parent and myAnimator and myAnimator.Parent) then stopAndRestore() return end
		if not (targetChar and targetChar.Parent and targetHum and targetHum.Parent and targetAnimator and targetAnimator.Parent) then stopAndRestore() return end
		applyTracks(captureTracks())
	end))

	NAlib.connect(NAStuff.SYNC_TAG, myChar.AncestryChanged:Connect(function() stopAndRestore() end))
	NAlib.connect(NAStuff.SYNC_TAG, targetChar.AncestryChanged:Connect(function() stopAndRestore() end))
	NAlib.connect(NAStuff.SYNC_TAG, Services.Players.LocalPlayer.CharacterAdded:Connect(function() stopAndRestore() end))

	if typeof(target) == "Instance" and target:IsA("Player") then
		NAlib.connect(NAStuff.SYNC_TAG, target.CharacterAdded:Connect(function() stopAndRestore() end))
		NAlib.connect(NAStuff.SYNC_TAG, Services.Players.PlayerRemoving:Connect(function(plr)
			if plr == target then
				stopAndRestore()
			end
		end))
	end
end)

cmd.add({"syncstop","stopsync","syncend","endsync","syncoff"}, {"syncstop","Stop live sync and restore defaults"}, function()
	if type(NAStuff.Sync_Stop) == "function" then
		pcall(NAStuff.Sync_Stop)
		return
	end
	NAlib.disconnect(NAStuff.SYNC_TAG)
	const myChar = getChar()
	const myHum = getPlrHum(myChar)
	if myHum then
		const myAnimator = myHum:FindFirstChildOfClass("Animator")
		if myAnimator then
			for _, tr in myAnimator:GetPlayingAnimationTracks() do pcall(function() tr:Stop(0) end) end
		end
	end
	const myAnimate = myChar and myChar:FindFirstChild("Animate")
	if myAnimate and NAlib.isProperty(myAnimate, "Disabled") ~= nil then
		if NAStuff.Sync_AnimatePrevDisabled ~= nil then myAnimate.Disabled = NAStuff.Sync_AnimatePrevDisabled else myAnimate.Disabled = false end
		myAnimate.Disabled = true
		myAnimate.Disabled = false
	end
	NAStuff.Sync_AnimatePrevDisabled = nil
	NAStuff.Sync_Stop = nil
	pcall(function() myHum:ChangeState(Enum.HumanoidStateType.Jumping) end)
end)

cmd.add({"animresetcore","animreset","resetanim","resetan"}, {"animresetcore","Reset core animations to saved"}, function()
	const myChar = getChar()
	const myHum = getPlrHum(myChar)
	const myAnimate = myChar and myChar:FindFirstChild("Animate")
	if not (myHum and myAnimate and NAStuff.SavedDefaultMap) then return end
	const function mapAnims(root)
		const t = {}
		for _, inst in NAmanage.QueryDescendants(root, "Animation") do
			const k = Lower(((inst.Parent and inst.Parent.Name) or "root").."|"..inst.Name)
			t[k] = inst
		end
		return t
	end
	const function refresh(hum)
		const char = hum and hum.Parent
		const animScr = char and char:FindFirstChild("Animate")
		if animScr and NAlib.isProperty(animScr, "Disabled") ~= nil then
			animScr.Disabled = true
			animScr.Disabled = false
		else
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
		end
	end
	const dst = mapAnims(myAnimate)
	for key, id in NAStuff.SavedDefaultMap do
		const dstAnim = dst[key]
		if dstAnim and dstAnim.AnimationId ~= id then
			dstAnim.AnimationId = id
		end
	end
	refresh(myHum)
end)

cmd.add({"unsyncreset","unsync","unsres","unsr"}, {"unsyncreset","Stop sync and reset saved"}, function()
	if type(NAStuff.Sync_Stop) == "function" then
		pcall(NAStuff.Sync_Stop)
	else
		NAlib.disconnect(NAStuff.SYNC_TAG)
	end
	const myChar = getChar()
	const myHum = getPlrHum(myChar)
	if myHum then
		const myAnimator = myHum:FindFirstChildOfClass("Animator")
		if myAnimator then
			for _, tr in myAnimator:GetPlayingAnimationTracks() do pcall(function() tr:Stop(0) end) end
		end
	end
	const myAnimate = myChar and myChar:FindFirstChild("Animate")
	if myAnimate and NAlib.isProperty(myAnimate, "Disabled") ~= nil then
		if NAStuff.Sync_AnimatePrevDisabled ~= nil then
			myAnimate.Disabled = NAStuff.Sync_AnimatePrevDisabled
		else
			myAnimate.Disabled = false
		end
		NAStuff.Sync_AnimatePrevDisabled = nil
	end
	NAStuff.Sync_Stop = nil
	if not (myHum and myAnimate and NAStuff.SavedDefaultMap) then return end
	const function mapAnims(root)
		const t = {}
		for _, inst in NAmanage.QueryDescendants(root, "Animation") do
			const k = Lower(((inst.Parent and inst.Parent.Name) or "root").."|"..inst.Name)
			t[k] = inst
		end
		return t
	end
	const function refresh(hum)
		const char = hum and hum.Parent
		const animScr = char and char:FindFirstChild("Animate")
		if animScr and NAlib.isProperty(animScr, "Disabled") ~= nil then
			animScr.Disabled = true
			animScr.Disabled = false
		else
			pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
		end
	end
	const dst = mapAnims(myAnimate)
	for key, id in NAStuff.SavedDefaultMap do
		const dstAnim = dst[key]
		if dstAnim and dstAnim.AnimationId ~= id then
			dstAnim.AnimationId = id
		end
	end
	refresh(myHum)
end)

cmd.add({"mimic","mirror","mclone","mcopy","mimi"}, {"mimic <player|npc:filter> [delay]","Clone player or NPC movement with optional delay"}, function(targetArg, delayArg)
	if not targetArg or targetArg == "" then return end
	local delay = tonumber(delayArg) or 0
	if delay < 0 then delay = 0 end

	const targets = getPlr(targetArg)
	const target = targets and targets[1]
	if not target then return end

	const myChar = getChar()
	const targetChar = getPlrChar(target)
	if not (myChar and targetChar) then return end

	const myHum = getPlrHum(myChar)
	const targetHum = getPlrHum(targetChar)
	if not (myHum and targetHum) then return end
	if myHum.RigType ~= targetHum.RigType then return end

	const targetAnimator = targetHum:FindFirstChildOfClass("Animator")
	if not targetAnimator then return end

	const myRoot = getRoot(myChar)
	const targetRoot = getRoot(targetChar)
	if not (myRoot and targetRoot) then return end

	if type(NAStuff.Mimic_Stop) == "function" then
		pcall(NAStuff.Mimic_Stop)
	else
		NAlib.disconnect(NAStuff.MIMIC_TAG)
	end

	const myAnimator = myHum:FindFirstChildOfClass("Animator") or InstanceNew("Animator", myHum)
	for _, tr in myAnimator:GetPlayingAnimationTracks() do pcall(function() tr:Stop(0) end) end

	const myAnimate = myChar:FindFirstChild("Animate")
	if myAnimate and NAlib.isProperty(myAnimate, "Disabled") ~= nil then
		NAStuff.Mimic_AnimatePrevDisabled = myAnimate.Disabled
		myAnimate.Disabled = true
	end

	const prevAutoRotate = myHum.AutoRotate
	myHum.AutoRotate = false

	const function now() return os.clock() end

	local stopped = false
	const animSlots = {}
	const ownedTracks = {}
	const activeTracks = {}
	local poseQ, poseHead = {}, 1
	local toolQ, toolHead = {}, 1
	local lastLook = Vector3.new(0,0,-1)
	local lastEquipName = nil

	const function clearOwnedTracks()
		const tracks = {}
		for track in ownedTracks do
			tracks[#tracks + 1] = track
		end
		for _, track in tracks do
			pcall(function() track:Stop(0) end)
			ownedTracks[track] = nil
		end
	end

	const function keepOnlyMimicTracks()
		for _, tr in myAnimator:GetPlayingAnimationTracks() do
			if not ownedTracks[tr] then
				pcall(function() tr:Stop(0) end)
			end
		end
		if myAnimate and NAlib.isProperty(myAnimate, "Disabled") ~= nil and not myAnimate.Disabled then
			myAnimate.Disabled = true
		end
	end

	const function refreshAnimate(a)
		if a and NAlib.isProperty(a, "Disabled") ~= nil then
			if NAStuff.Mimic_AnimatePrevDisabled ~= nil then
				a.Disabled = NAStuff.Mimic_AnimatePrevDisabled
			else
				a.Disabled = false
			end
			a.Disabled = true
			a.Disabled = false
		end
	end

	const function stopAndRestore()
		if stopped then return end
		stopped = true
		NAlib.disconnect(NAStuff.MIMIC_TAG)
		clearOwnedTracks()
		for _, tr in myAnimator:GetPlayingAnimationTracks() do pcall(function() tr:Stop(0) end) end
		pcall(function() myHum.AutoRotate = prevAutoRotate end)
		refreshAnimate(myChar and myChar:FindFirstChild("Animate"))
		NAStuff.Mimic_AnimatePrevDisabled = nil
		NAStuff.Mimic_Stop = nil
	end

	NAStuff.Mimic_Stop = stopAndRestore

	const function getTrackWeight(t)
		local ok, weight = pcall(function()
			return t.WeightCurrent
		end)
		weight = ok and tonumber(weight) or nil
		if not weight then
			local okTarget, targetWeight = pcall(function()
				return t.WeightTarget
			end)
			weight = okTarget and tonumber(targetWeight) or nil
		end
		return weight or 1
	end

	const function captureTracks()
		const list = {}
		for _, tTrack in targetAnimator:GetPlayingAnimationTracks() do
			const anim = tTrack.Animation
			const animId = anim and anim.AnimationId
			if animId and animId ~= "" then
				list[#list + 1] = {
					source = tTrack,
					animId = animId,
					time = tonumber(tTrack.TimePosition) or 0,
					speed = (type(tTrack.Speed) == "number" and tTrack.Speed) or 1,
					looped = tTrack.Looped and true or false,
					priority = tTrack.Priority,
					weight = getTrackWeight(tTrack),
				}
			end
		end
		return list
	end

	const function loadSlot(trackState)
		local old = animSlots[trackState.source]
		if old and old.track and (old.animId ~= trackState.animId or not old.track.IsPlaying) then
			ownedTracks[old.track] = nil
			pcall(function() old.track:Stop(0) end)
			old = nil
			animSlots[trackState.source] = nil
		end
		if old and old.track then
			return old
		end
		const anim = InstanceNew("Animation")
		anim.AnimationId = trackState.animId
		local okLoad, mt = pcall(function()
			return myAnimator:LoadAnimation(anim)
		end)
		if not okLoad or not mt then return nil end
		pcall(function()
			mt.Priority = trackState.priority or mt.Priority
			mt.Looped = trackState.looped
			mt:Play(0, math.clamp(trackState.weight or 1, 0, 1), trackState.speed or 1)
			mt.TimePosition = trackState.time or 0
			mt:AdjustWeight(math.clamp(trackState.weight or 1, 0, 1), 0)
		end)
		ownedTracks[mt] = true
		old = {track = mt, animId = trackState.animId}
		animSlots[trackState.source] = old
		return old
	end

	const function applyTracks(trackStates)
		table.clear(activeTracks)
		for _, trackState in trackStates or {} do
			activeTracks[trackState.source] = true
			const slot = loadSlot(trackState)
			const mt = slot and slot.track
			if mt then
				pcall(function()
					if mt.Priority ~= trackState.priority then mt.Priority = trackState.priority end
					if mt.Looped ~= trackState.looped then mt.Looped = trackState.looped end
					mt:AdjustSpeed(trackState.speed or 1)
					mt:AdjustWeight(math.clamp(trackState.weight or 1, 0, 1), 0)
					if math.abs((mt.TimePosition or 0) - (trackState.time or 0)) > 0.05 then
						mt.TimePosition = trackState.time or 0
					end
				end)
			end
		end
		const staleSources = {}
		for source in animSlots do
			if not activeTracks[source] then
				staleSources[#staleSources + 1] = source
			end
		end
		for _, source in staleSources do
			const slot = animSlots[source]
			if slot and slot.track then
				ownedTracks[slot.track] = nil
				pcall(function() slot.track:Stop(0) end)
			end
			animSlots[source] = nil
		end
		keepOnlyMimicTracks()
	end

	const function findLocalTool(name)
		if not name or name == "" then return nil end
		const char = getChar()
		const bp = getBp()
		const held = char and char:FindFirstChild(name)
		if held and held:IsA("Tool") then return held end
		const stored = bp and bp:FindFirstChild(name)
		if stored and stored:IsA("Tool") then return stored end
	end

	const function equipLikeTarget(toolName)
		const char = getChar()
		const held = char and char:FindFirstChildOfClass("Tool")
		if lastEquipName == toolName and ((not toolName and not held) or (toolName and held and held.Name == toolName)) then return end
		lastEquipName = toolName
		pcall(function() myHum:UnequipTools() end)
		if toolName then
			const tool = findLocalTool(toolName)
			if tool then
				pcall(function() myHum:EquipTool(tool) end)
			end
		end
	end

	const function activeTargetToolName()
		for _, child in targetChar:GetChildren() do
			if child:IsA("Tool") then
				return child.Name
			end
		end
	end

	const function queueToolEvent(kind, toolName)
		toolQ[#toolQ + 1] = {t = now() + delay, kind = kind, name = toolName}
	end

	const watchedTools = setmetatable({}, {__mode = "k"})
	const function watchTool(tool)
		if not (tool and tool:IsA("Tool")) or watchedTools[tool] then return end
		watchedTools[tool] = true
		NAlib.connect(NAStuff.MIMIC_TAG, tool.Activated:Connect(function()
			queueToolEvent("activate", tool.Name)
		end))
		NAlib.connect(NAStuff.MIMIC_TAG, tool.Deactivated:Connect(function()
			queueToolEvent("deactivate", tool.Name)
		end))
	end

	for _, child in targetChar:GetChildren() do
		if child:IsA("Tool") then watchTool(child) end
	end
	NAlib.connect(NAStuff.MIMIC_TAG, NAmanage.childAdd(targetChar, function(child)
		if child:IsA("Tool") then
			watchTool(child)
			queueToolEvent("equip", child.Name)
		end
	end, function(child)
		return child and child:IsA("Tool")
	end))
	NAlib.connect(NAStuff.MIMIC_TAG, NAmanage.childRem(targetChar, function(child)
		if child:IsA("Tool") then
			queueToolEvent("equip", nil)
		end
	end, function(child)
		return child and child:IsA("Tool")
	end))

	NAlib.connect(NAStuff.MIMIC_TAG, Services.RunService.Heartbeat:Connect(function()
		if stopped then return end
		if not (targetChar and targetChar.Parent and targetRoot and targetRoot.Parent) then stopAndRestore() return end
		if not (myChar and myChar.Parent and myRoot and myRoot.Parent) then stopAndRestore() return end
		if not (targetHum and targetHum.Parent and targetAnimator and targetAnimator.Parent) then stopAndRestore() return end
		if not (myHum and myHum.Parent and myAnimator and myAnimator.Parent) then stopAndRestore() return end

		const lv = targetRoot.CFrame.LookVector
		const flat = Vector3.new(lv.X, 0, lv.Z)
		if flat.Magnitude >= 1e-4 then lastLook = flat.Unit end
		Insert(poseQ, {
			t = now(),
			pos = targetRoot.Position,
			look = lastLook,
			vel = targetRoot.AssemblyLinearVelocity,
			ang = targetRoot.AssemblyAngularVelocity,
			state = targetHum:GetState(),
			sit = targetHum.Sit,
			jump = targetHum.Jump,
			tool = activeTargetToolName(),
			tracks = captureTracks(),
		})
		const cutoff = now() - delay
		local snap
		while poseHead <= #poseQ and poseQ[poseHead].t <= cutoff do snap = poseQ[poseHead]; poseHead += 1 end
		if snap then
			const cf = CFrame.lookAt(snap.pos, snap.pos + snap.look)
			pcall(function()
				myRoot.CFrame = cf
				myRoot.AssemblyLinearVelocity = snap.vel
				myRoot.AssemblyAngularVelocity = snap.ang
			end)
			pcall(function()
				if snap.state and snap.state ~= Enum.HumanoidStateType.Dead then myHum:ChangeState(snap.state) end
				myHum.Sit = snap.sit and true or false
				myHum.Jump = snap.jump and true or false
			end)
			equipLikeTarget(snap.tool)
			applyTracks(snap.tracks)
			if poseHead > 64 then
				const newBuf = {}
				for i = poseHead, #poseQ do newBuf[#newBuf+1] = poseQ[i] end
				poseQ, poseHead = newBuf, 1
			end
		end

		while toolHead <= #toolQ and toolQ[toolHead].t <= now() do
			const ev = toolQ[toolHead]
			toolHead += 1
			if ev.kind == "equip" then
				equipLikeTarget(ev.name)
			else
				if ev.name then equipLikeTarget(ev.name) end
				const localTool = ev.name and findLocalTool(ev.name) or (getChar() and getChar():FindFirstChildOfClass("Tool"))
				if localTool then
					if ev.kind == "activate" then
						pcall(function() localTool:Activate() end)
					elseif ev.kind == "deactivate" then
						pcall(function() localTool:Deactivate() end)
					end
				end
			end
		end
		if toolHead > 64 then
			const newToolQ = {}
			for i = toolHead, #toolQ do newToolQ[#newToolQ+1] = toolQ[i] end
			toolQ, toolHead = newToolQ, 1
		end
	end))

	NAlib.connect(NAStuff.MIMIC_TAG, myChar.AncestryChanged:Connect(function() stopAndRestore() end))
	NAlib.connect(NAStuff.MIMIC_TAG, targetChar.AncestryChanged:Connect(function() stopAndRestore() end))
	NAlib.connect(NAStuff.MIMIC_TAG, Services.Players.LocalPlayer.CharacterAdded:Connect(function() stopAndRestore() end))
	if typeof(target) == "Instance" and target:IsA("Player") then
		NAlib.connect(NAStuff.MIMIC_TAG, target.CharacterAdded:Connect(function() stopAndRestore() end))
	end
	if typeof(target) == "Instance" and target:IsA("Player") then
		NAlib.connect(NAStuff.MIMIC_TAG, Services.Players.PlayerRemoving:Connect(function(plr)
			if plr == target then stopAndRestore() end
		end))
	end
end)

cmd.add({"mstop","moff","stopmimic","mend"}, {"mstop","Stop mimic and restore defaults"}, function()
	if type(NAStuff.Mimic_Stop) == "function" then
		pcall(NAStuff.Mimic_Stop)
		return
	end
	NAlib.disconnect(NAStuff.MIMIC_TAG)
	const myChar = getChar()
	const myHum = getPlrHum(myChar)
	const myAnimator = myHum and myHum:FindFirstChildOfClass("Animator")
	if myAnimator then for _, tr in myAnimator:GetPlayingAnimationTracks() do pcall(function() tr:Stop(0) end) end end
	if myHum then myHum.AutoRotate = true end
	const a = myChar and myChar:FindFirstChild("Animate")
	if a and NAlib.isProperty(a, "Disabled") ~= nil then
		if NAStuff.Mimic_AnimatePrevDisabled ~= nil then a.Disabled = NAStuff.Mimic_AnimatePrevDisabled else a.Disabled = false end
		a.Disabled = true; a.Disabled = false
	end
	NAStuff.Mimic_AnimatePrevDisabled = nil
	NAStuff.Mimic_Stop = nil
end)

cmd.add({"bubblechat","bchat"},{"bubblechat (bchat)","Enables BubbleChat"},function()
	NAStuff.ChatSettings.bubbles.enabled = true
	NAmanage.SaveTextChatSettings()
	NAmanage.ApplyTextChatSettings()
end)

cmd.add({"unbubblechat","unbchat"},{"unbubblechat (unbchat)","Disabled BubbleChat"},function()
	NAStuff.ChatSettings.bubbles.enabled = false
	NAmanage.SaveTextChatSettings()
	NAmanage.ApplyTextChatSettings()
end)

cmd.add({"hideicon","iconhide"},{"hideicon","Hides the NA icon"},function()
	if NAmanage.IconSetInvisible then
		NAmanage.IconSetInvisible(true)
	end
end)

cmd.add({"showicon","iconshow"},{"showicon","Shows the NA icon"},function()
	if NAmanage.IconSetInvisible then
		NAmanage.IconSetInvisible(false)
	end
end)

cmd.add({"topbar","showtopbar"},{"topbar (showtopbar)","Shows the NA topbar"},function()
	if NAmanage.Topbar_SetVisible then
		NAmanage.Topbar_SetVisible(true)
	else
		NATOPBARVISIBLE = true
		if TopBarApp and TopBarApp.top then
			TopBarApp.top.Visible = true
		end
		NAmanage.NASettingsSet("topbarVisible", true)
		DebugNotif("Topbar shown", 2)
	end
end)

cmd.add({"untopbar","hidetopbar"},{"untopbar (hidetopbar)","Hides the NA topbar"},function()
	if NAmanage.Topbar_SetVisible then
		NAmanage.Topbar_SetVisible(false)
	else
		NATOPBARVISIBLE = false
		if TopBarApp and TopBarApp.top then
			TopBarApp.top.Visible = false
		end
		NAmanage.NASettingsSet("topbarVisible", false)
		DebugNotif("Topbar hidden", 2)
	end
end)

cmd.add({"lockiconposition","lockicon"},{"lockiconposition","Locks the NA icon's position (can't be dragged)"},function()
	if NAgui.setIconLocked then
		NAgui.setIconLocked(true)
	end
end)

cmd.add({"unlockiconposition","unlockicon"},{"unlockiconposition","Unlocks the NA icon's position (can be dragged again)"},function()
	if NAgui.setIconLocked then
		NAgui.setIconLocked(false)
	end
end)

NAmanage.LoadSaveInstance420 = NAmanage.LoadSaveInstance420 or function()
	const cacheHost = _na_env or _G
	const cacheKey = "__na_saveinstance420_sirmeme_v3"
	const cached = type(cacheHost) == "table" and rawget(cacheHost, cacheKey)
	if type(cached) == "function" then
		return cached
	end

	const loader = loadstring or load
	if type(loader) ~= "function" then
		error("SaveInstance 420 Edition loader unavailable")
	end

	const repoUrl = "https://sirmemegithub.com/RealSlimShady2000/SaveInstance420Edition/raw/branch/main/"
	const scriptName = "saveinstance"
	local source = NAmanage.HttpGetOrError(repoUrl..scriptName..".luau", { noCache = true, timeout = 20 })
	source = source:gsub("StatusGui%.Parent%s*=%s*global_container%.gethui%(%s*%)", [[
			local huiOk, hui = pcall(global_container.gethui)
			if huiOk and typeof(hui) == "Instance" then
				StatusGui.Parent = hui
			else
				local CoreGui = game:GetService("CoreGui")
				local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
				StatusGui.Parent = RobloxGui or CoreGui
			end
			]], 1)
	const chunk = loader(source, "@SaveInstance420Edition/"..scriptName..".luau")
	if type(chunk) ~= "function" then
		error("failed to compile SaveInstance 420 Edition")
	end

	const saveInstance420 = chunk()
	if type(saveInstance420) ~= "function" then
		error("failed to load SaveInstance 420 Edition")
	end

	const function mergeOptions(target, sourceOptions)
		if type(sourceOptions) ~= "table" then
			return
		end

		for key, value in sourceOptions do
			target[key] = value
		end
	end

	const function getLocalHumanoid()
		const player = Services.Players and Services.Players.LocalPlayer
		const character = player and player.Character
		if character then
			return character:FindFirstChildOfClass("Humanoid")
		end
	end

	const function captureClientState()
		const state = {}

		pcall(function()
			const camera = Services.Workspace and Services.Workspace.CurrentCamera
			state.Camera = camera
			if camera then
				state.CameraType = camera.CameraType
				state.CameraSubject = camera.CameraSubject
			end
		end)

		pcall(function()
			const userInput = Services.UserInputService or SafeGetService("UserInputService")
			state.UserInput = userInput
			if userInput then
				state.MouseBehavior = userInput.MouseBehavior
				state.MouseIconEnabled = userInput.MouseIconEnabled
			end
		end)

		return state
	end

	const function restoreClientState(state)
		if type(state) ~= "table" then
			return
		end

		pcall(function()
			const userInput = state.UserInput or Services.UserInputService or SafeGetService("UserInputService")
			if not userInput then
				return
			end
			if state.MouseBehavior then
				userInput.MouseBehavior = state.MouseBehavior
			end
			if state.MouseIconEnabled ~= nil then
				userInput.MouseIconEnabled = state.MouseIconEnabled
			end
		end)

		pcall(function()
			const runService = Services.RunService or SafeGetService("RunService")
			if runService and runService.Set3dRenderingEnabled then
				runService:Set3dRenderingEnabled(true)
			end
		end)

		pcall(function()
			local camera = state.Camera
			if not camera or camera.Parent == nil then
				camera = Services.Workspace and Services.Workspace.CurrentCamera
			end
			if not camera then
				return
			end

			local subject = state.CameraSubject
			if not subject or subject.Parent == nil then
				subject = getLocalHumanoid()
			end

			if subject then
				camera.CameraSubject = subject
			end

			if state.CameraType then
				camera.CameraType = state.CameraType
			elseif subject then
				camera.CameraType = Enum.CameraType.Custom
			end
		end)
	end

	const function isInstanceArray(value)
		if type(value) ~= "table" then
			return false
		end
		for _, item in value do
			if typeof(item) ~= "Instance" then
				return false
			end
		end
		return true
	end

	const function wrappedSaveInstance(parameter1, parameter2, parameter3)
		local firstArgument
		local secondArgument

		if type(parameter1) == "table" and parameter2 == nil and parameter3 == nil then
			firstArgument = parameter1
		elseif isInstanceArray(parameter1) and type(parameter2) == "table" and parameter3 == nil then
			firstArgument = parameter1
			secondArgument = parameter2
		elseif typeof(parameter1) == "Instance" then
			const options = {}
			if type(parameter2) == "table" and parameter3 == nil then
				mergeOptions(options, parameter2)
			elseif type(parameter3) == "table" then
				mergeOptions(options, parameter3)
			end
			if type(parameter2) == "string" and parameter2 ~= "" then
				options.FilePath = parameter2
			end
			firstArgument = parameter1
			secondArgument = options
		else
			const options = {}
			if type(parameter2) == "table" then
				mergeOptions(options, parameter2)
			end
			if type(parameter3) == "table" then
				mergeOptions(options, parameter3)
			end
			if type(parameter1) == "string" and parameter1 ~= "" then
				options.FilePath = parameter1
			end
			firstArgument = options
		end

		const clientState = captureClientState()
		local ok, result
		if secondArgument ~= nil then
			ok, result = pcall(saveInstance420, firstArgument, secondArgument)
		else
			ok, result = pcall(saveInstance420, firstArgument)
		end
		restoreClientState(clientState)
		Defer(restoreClientState, clientState)
		Delay(1, restoreClientState, clientState)

		if not ok then
			error(result, 0)
		end

		return result
	end

	if type(cacheHost) == "table" then
		rawset(cacheHost, cacheKey, wrappedSaveInstance)
		rawset(cacheHost, "__na_saveinstance420", wrappedSaveInstance)
	end
	return wrappedSaveInstance
end

NAmanage.SaveInstance420Loader = type(NAmanage.SaveInstance420Loader) == "table" and NAmanage.SaveInstance420Loader or {
	loading = false;
	ready = false;
	value = nil;
	error = nil;
}

NAmanage.StartSaveInstance420 = NAmanage.StartSaveInstance420 or function()
	const state = NAmanage.SaveInstance420Loader
	if state.loading or (state.ready and type(state.value) == "function") then
		return
	end

	const cacheHost = _na_env or _G
	const cached = type(cacheHost) == "table" and rawget(cacheHost, "__na_saveinstance420_sirmeme_v3")
	if type(cached) == "function" then
		state.value = cached
		state.error = nil
		state.ready = true
		return
	end

	state.loading = true
	state.error = nil
	Spawn(function()
		local ok, result = pcall(NAmanage.LoadSaveInstance420)
		state.loading = false
		if ok and type(result) == "function" then
			state.value = result
			state.error = nil
			state.ready = true
		else
			state.value = nil
			state.ready = false
			state.error = result or "failed to load SaveInstance 420 Edition"
		end
	end)
end

NAmanage.GetSaveInstance420 = function()
	const state = NAmanage.SaveInstance420Loader
	if state.ready and type(state.value) == "function" then
		return state.value
	end

	NAmanage.StartSaveInstance420()
	while state.loading do
		Wait()
	end
	if state.ready and type(state.value) == "function" then
		return state.value
	end

	const previousError = state.error
	NAmanage.StartSaveInstance420()
	while state.loading do
		Wait()
	end
	if not state.ready or type(state.value) ~= "function" then
		error(state.error or previousError or "failed to load SaveInstance 420 Edition", 0)
	end
	return state.value
end

NAmanage.StartSaveInstance420()

NAmanage.GetSaveInstancePlaceName = NAmanage.GetSaveInstancePlaceName or function()
	if type(NAStuff._SaveInstancePlaceName) == "string" and NAStuff._SaveInstancePlaceName ~= "" then
		return NAStuff._SaveInstancePlaceName
	end

	local placeName = "UnknownPlace"
	local okInfo, info = pcall(function()
		return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
	end)
	if okInfo and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
		placeName = info.Name
	end
	placeName = tostring(placeName):gsub("[%c\\/:*?\"<>|]", "_")
	placeName = placeName:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	if placeName == "" then
		placeName = "UnknownPlace"
	end

	NAStuff._SaveInstancePlaceName = placeName
	return placeName
end

NAmanage.FormatSaveInstanceFileName = NAmanage.FormatSaveInstanceFileName or function(template, extra)
	local formatText = tostring(template or "")
	if formatText == "" then
		formatText = "{placeName}_{timestamp}"
	end

	const tokens = {
		placeName = NAmanage.GetSaveInstancePlaceName();
		placeId = tostring(game.PlaceId);
		timestamp = os.date("%d-%m-%Y_%H-%M-%S");
		date = os.date("%d-%m-%Y");
		time = os.date("%H-%M-%S");
		unix = tostring(os.time());
	}
	if type(extra) == "table" then
		for key, value in extra do
			tokens[key] = value
		end
	end
	tokens.TIMESTAMP = tokens.TIMESTAMP or tokens.timestamp
	tokens.DATE = tokens.DATE or tokens.date
	tokens.TIME = tokens.TIME or tokens.time
	tokens.UNIX = tokens.UNIX or tokens.unix
	tokens.PLACENAME = tokens.PLACENAME or tokens.placeName
	tokens.PLACEID = tokens.PLACEID or tokens.placeId

	const resolved = formatText:gsub("{([%w_]+)}", function(token)
		local value = tokens[token]
		if value == nil then
			return "{"..token.."}"
		end
		value = tostring(value)
		value = value:gsub("[%c\\/:*?\"<>|]", "_")
		value = value:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
		if value == "" then
			return "Unnamed"
		end
		return value
	end)

	return resolved
end

NAmanage.TrimSaveInstanceText = NAmanage.TrimSaveInstanceText or function(value, fallback)
	const text = tostring(value or ""):match("^%s*(.-)%s*$") or ""
	if text == "" and fallback ~= nil then
		return fallback
	end
	return text
end

NAmanage.ParseSaveInstanceList = NAmanage.ParseSaveInstanceList or function(value)
	const out = {}
	const seen = {}
	for _, entry in string.split(tostring(value or ""), ",") do
		const clean = tostring(entry):match("^%s*(.-)%s*$") or ""
		if clean ~= "" and not seen[clean] then
			seen[clean] = true
			out[#out + 1] = clean
		end
	end
	return out
end

NAmanage.DecodeSaveInstanceExtraOptions = NAmanage.DecodeSaveInstanceExtraOptions or function(text)
	const trimmed = NAmanage.TrimSaveInstanceText(text, "")
	if trimmed == "" then
		return {}
	end
	local okDecode, decoded = pcall(function()
		return Services.HttpService:JSONDecode(trimmed)
	end)
	if not okDecode or type(decoded) ~= "table" then
		error("Extra Options JSON is invalid")
	end
	return decoded
end

NAmanage.BuildSaveInstanceOptions = NAmanage.BuildSaveInstanceOptions or function(extra)
	const cfg = NAStuff.SaveInstanceConfig or {}
	const streamingConcurrency = math.max(0, math.floor((tonumber(cfg.streamingConcurrency) or 0) + 0.5))
	const streamingMaxTime = math.max(0, tonumber(cfg.streamingMaxTime) or 0)
	const options = {
		SafeMode = cfg.safeMode == true;
		ShutdownWhenDone = cfg.shutdownWhenDone == true;
		AntiIdle = cfg.antiIdle ~= false;
		ShowStatus = cfg.showStatus ~= false;
		ReadMe = cfg.readMe ~= false;
		__DEBUG_MODE = cfg.debugMode == true;
		Debug = cfg.debugLog == true;
		Anonymous = cfg.anonymous == true;
		mode = (cfg.mode == "full" or cfg.mode == "scripts") and cfg.mode or "optimized";
		noscripts = cfg.decompile == false;
		scriptcache = cfg.scriptCache ~= false;
		timeout = math.clamp(tonumber(cfg.decompileTimeout) or 10, 1, 120);
		DecompileJobless = cfg.decompileJobless == true;
		SaveBytecode = cfg.saveBytecode == true;
		DecompilePrepass = cfg.decompilePrepass == true;
		PrepassConcurrency = math.clamp(math.floor((tonumber(cfg.prepassConcurrency) or 24) + 0.5), 1, 128);
		PrepassRateGap = math.max(0, tonumber(cfg.prepassRateGap) or 0.12);
		PrepassMaxScripts = math.max(1, math.floor((tonumber(cfg.prepassMaxScripts) or 6000) + 0.5));
		DecompileIgnore = NAmanage.ParseSaveInstanceList(cfg.decompileIgnore);
		IgnoreList = NAmanage.ParseSaveInstanceList(cfg.ignoreList);
		IgnoreProperties = NAmanage.ParseSaveInstanceList(cfg.ignoreProperties);
		SaveCacheInterval = math.max(0, math.floor((tonumber(cfg.saveCacheInterval) or 56320) + 0.5));
		NilInstances = cfg.nilInstances == true;
		IgnoreDefaultProperties = cfg.ignoreDefaultProperties ~= false;
		IgnoreNotArchivable = cfg.ignoreNotArchivable ~= false;
		IgnorePropertiesOfNotScriptsOnScriptsMode = cfg.ignorePropertiesOfNotScriptsOnScriptsMode == true;
		IgnoreSpecialProperties = cfg.ignoreSpecialProperties == true;
		UseUGCValidationService = cfg.useUGCValidationService ~= false;
		IsolateStarterPlayer = cfg.isolateStarterPlayer == true;
		IsolatePlayers = cfg.isolatePlayers == true;
		IsolateLocalPlayer = cfg.isolateLocalPlayer == true;
		IsolateLocalPlayerCharacter = cfg.isolateLocalPlayerCharacter == true;
		RemovePlayerCharacters = cfg.savePlayerCharacters ~= true;
		SaveNotCreatable = cfg.saveNotCreatable == true;
		AlternativeWritefile = cfg.alternativeWritefile ~= false;
		IgnoreDefaultPlayerScripts = cfg.ignoreDefaultPlayerScripts ~= false;
		IgnoreSharedStrings = cfg.ignoreSharedStrings ~= false;
		SharedStringOverwrite = cfg.sharedStringOverwrite == true;
		TreatUnionsAsParts = cfg.treatUnionsAsParts == true;
		SetStreaming = cfg.setStreaming == true;
		StreamingAreaSize = math.max(1, tonumber(cfg.streamingAreaSize) or 10000);
		StreamingRadius = math.max(1, tonumber(cfg.streamingRadius) or 1024);
		StreamingTimeout = math.max(1, tonumber(cfg.streamingTimeout) or 20);
		StreamingConcurrency = streamingConcurrency > 0 and streamingConcurrency or false;
		StreamingSlices = math.max(1, math.floor((tonumber(cfg.streamingSlices) or 2) + 0.5));
		StreamingMaxTime = streamingMaxTime > 0 and streamingMaxTime or false;
		StreamingChunkWait = math.max(1, tonumber(cfg.streamingChunkWait) or 12);
		StreamingSettleTime = math.max(0, tonumber(cfg.streamingSettleTime) or 5);
		NeutralizeLighting = cfg.neutralizeLighting == true;
		ExportObj = cfg.exportObj == true;
		NotCreatableFixes = NAmanage.ParseSaveInstanceList(cfg.notCreatableFixes);
		FilePath = NAmanage.FormatSaveInstanceFileName(cfg.fileNameFormat);
	}

	const prepassApiUrl = NAmanage.TrimSaveInstanceText(cfg.prepassApiUrl, "")
	if prepassApiUrl ~= "" then
		options.PrepassApiUrl = prepassApiUrl
	end

	local executorName = ""
	pcall(function()
		if type(identifyexecutor) == "function" then
			executorName = tostring(identifyexecutor())
		end
	end)
	if executorName == "Fluxus" and extra == nil then
		options.IgnoreSpecialProperties = true
	end

	const extraOptions = NAmanage.DecodeSaveInstanceExtraOptions(cfg.extraOptionsJson)
	for key, value in extraOptions do
		options[key] = value
	end

	if type(extra) == "table" then
		for key, value in extra do
			options[key] = value
		end
	end

	return options
end

NAmanage.RunSaveInstance = NAmanage.RunSaveInstance or function(extra)
	const saveInstance420 = NAmanage.GetSaveInstance420()
	const options = NAmanage.BuildSaveInstanceOptions(extra)
	local ok, result = pcall(saveInstance420, options)
	if not ok then
		error(result)
	end
	return result
end

NAmanage.BuildSaveInstanceTab = NAmanage.BuildSaveInstanceTab or function()
	const cfg = NAStuff.SaveInstanceConfig
	const function setValue(configKey, settingKey, value)
		cfg[configKey] = value
		pcall(NAmanage.NASettingsSet, settingKey, value)
	end
	const function dropdownValue(selection, fallback)
		local value = selection
		if type(selection) == "table" then
			value = selection[1]
		end
		value = tostring(value or fallback or "")
		if value == "" then
			return fallback
		end
		return value
	end

	NAgui.addSection("Protection")
	NAgui.addToggle("Safe Mode", cfg.safeMode == true, function(v)
		setValue("safeMode", "saveInstanceSafeMode", v == true)
	end)
	NAgui.addToggle("Shutdown When Done", cfg.shutdownWhenDone == true, function(v)
		setValue("shutdownWhenDone", "saveInstanceShutdownWhenDone", v == true)
	end)
	NAgui.addToggle("Anti Idle", cfg.antiIdle ~= false, function(v)
		setValue("antiIdle", "saveInstanceAntiIdle", v ~= false)
	end)
	NAgui.addToggle("Show Status", cfg.showStatus ~= false, function(v)
		setValue("showStatus", "saveInstanceShowStatus", v ~= false)
	end)
	NAgui.addToggle("Write ReadMe", cfg.readMe ~= false, function(v)
		setValue("readMe", "saveInstanceReadMe", v ~= false)
	end)
	NAgui.addToggle("Debug Mode", cfg.debugMode == true, function(v)
		setValue("debugMode", "saveInstanceDebugMode", v == true)
	end)
	NAgui.addToggle("Write Debug Log", cfg.debugLog == true, function(v)
		setValue("debugLog", "saveInstanceDebugLog", v == true)
	end)
	NAgui.addToggle("Anonymous", cfg.anonymous == true, function(v)
		setValue("anonymous", "saveInstanceAnonymous", v == true)
	end)

	NAgui.addSection("Decompile")
	NAgui.addDropdown("Save Mode", { "optimized", "full", "scripts" }, tostring(cfg.mode or "optimized"), function(selection)
		local mode = dropdownValue(selection, "optimized"):lower()
		if mode ~= "full" and mode ~= "scripts" then
			mode = "optimized"
		end
		setValue("mode", "saveInstanceMode", mode)
	end)
	NAgui.addToggle("Decompile Scripts", cfg.decompile ~= false, function(v)
		setValue("decompile", "saveInstanceDecompile", v ~= false)
	end)
	NAgui.addToggle("Use Script Cache", cfg.scriptCache ~= false, function(v)
		setValue("scriptCache", "saveInstanceScriptCache", v ~= false)
	end)
	NAgui.addSlider("Decompile Timeout", 1, 120, tonumber(cfg.decompileTimeout) or 10, 1, " s", function(v)
		setValue("decompileTimeout", "saveInstanceDecompileTimeout", math.clamp(math.floor((tonumber(v) or 10) + 0.5), 1, 120))
	end)
	NAgui.addToggle("Decompile Jobless", cfg.decompileJobless == true, function(v)
		setValue("decompileJobless", "saveInstanceDecompileJobless", v == true)
	end)
	NAgui.addToggle("Save Bytecode", cfg.saveBytecode == true, function(v)
		setValue("saveBytecode", "saveInstanceSaveBytecode", v == true)
	end)
	NAgui.addToggle("Decompile Prepass", cfg.decompilePrepass == true, function(v)
		setValue("decompilePrepass", "saveInstanceDecompilePrepass", v == true)
	end)
	NAgui.addSlider("Prepass Concurrency", 1, 128, tonumber(cfg.prepassConcurrency) or 24, 1, "", function(v)
		setValue("prepassConcurrency", "saveInstancePrepassConcurrency", math.clamp(math.floor((tonumber(v) or 24) + 0.5), 1, 128))
	end)
	NAgui.addInput("Prepass Rate Gap", "0.12", tostring(cfg.prepassRateGap or 0.12), function(text)
		setValue("prepassRateGap", "saveInstancePrepassRateGap", math.max(0, tonumber(text) or 0.12))
	end)
	NAgui.addInput("Prepass API URL", "https://api.lua.expert/decompile", tostring(cfg.prepassApiUrl or ""), function(text)
		setValue("prepassApiUrl", "saveInstancePrepassApiUrl", NAmanage.TrimSaveInstanceText(text, "https://api.lua.expert/decompile"))
	end)
	NAgui.addInput("Prepass Max Scripts", "6000", tostring(cfg.prepassMaxScripts or 6000), function(text)
		setValue("prepassMaxScripts", "saveInstancePrepassMaxScripts", math.max(1, math.floor((tonumber(text) or 6000) + 0.5)))
	end)
	NAgui.addInput("Decompile Ignore", "Chat,CoreGui,CorePackages", tostring(cfg.decompileIgnore or ""), function(text)
		setValue("decompileIgnore", "saveInstanceDecompileIgnore", NAmanage.TrimSaveInstanceText(text, ""))
	end)

	NAgui.addSection("Instances")
	NAgui.addInput("Ignore List", "CoreGui,CorePackages", tostring(cfg.ignoreList or ""), function(text)
		setValue("ignoreList", "saveInstanceIgnoreList", NAmanage.TrimSaveInstanceText(text, ""))
	end)
	NAgui.addInput("Ignore Properties", "PropertyA,PropertyB", tostring(cfg.ignoreProperties or ""), function(text)
		setValue("ignoreProperties", "saveInstanceIgnoreProperties", NAmanage.TrimSaveInstanceText(text, ""))
	end)
	NAgui.addInput("Not Creatable Fixes", "Player,PlayerScripts,...", tostring(cfg.notCreatableFixes or ""), function(text)
		setValue("notCreatableFixes", "saveInstanceNotCreatableFixes", NAmanage.TrimSaveInstanceText(text, ""))
	end)
	NAgui.addInput("Save Cache Interval", "56320", tostring(cfg.saveCacheInterval or 56320), function(text)
		const value = math.max(0, math.floor((tonumber(text) or 56320) + 0.5))
		setValue("saveCacheInterval", "saveInstanceSaveCacheInterval", value)
	end)
	NAgui.addToggle("Save Nil Instances", cfg.nilInstances == true, function(v)
		setValue("nilInstances", "saveInstanceNilInstances", v == true)
	end)
	NAgui.addToggle("Ignore Default Properties", cfg.ignoreDefaultProperties ~= false, function(v)
		setValue("ignoreDefaultProperties", "saveInstanceIgnoreDefaultProperties", v ~= false)
	end)
	NAgui.addToggle("Ignore Not Archivable", cfg.ignoreNotArchivable ~= false, function(v)
		setValue("ignoreNotArchivable", "saveInstanceIgnoreNotArchivable", v ~= false)
	end)
	NAgui.addToggle("Ignore Non-Script Props In Scripts Mode", cfg.ignorePropertiesOfNotScriptsOnScriptsMode == true, function(v)
		setValue("ignorePropertiesOfNotScriptsOnScriptsMode", "saveInstanceIgnorePropertiesOfNotScriptsOnScriptsMode", v == true)
	end)
	NAgui.addToggle("Ignore Special Properties", cfg.ignoreSpecialProperties == true, function(v)
		setValue("ignoreSpecialProperties", "saveInstanceIgnoreSpecialProperties", v == true)
	end)
	NAgui.addToggle("Use UGC Validation Service", cfg.useUGCValidationService ~= false, function(v)
		setValue("useUGCValidationService", "saveInstanceUseUGCValidationService", v ~= false)
	end)
	NAgui.addToggle("Isolate StarterPlayer", cfg.isolateStarterPlayer == true, function(v)
		setValue("isolateStarterPlayer", "saveInstanceIsolateStarterPlayer", v == true)
	end)
	NAgui.addToggle("Isolate Players", cfg.isolatePlayers == true, function(v)
		setValue("isolatePlayers", "saveInstanceIsolatePlayers", v == true)
	end)
	NAgui.addToggle("Isolate Local Player", cfg.isolateLocalPlayer == true, function(v)
		setValue("isolateLocalPlayer", "saveInstanceIsolateLocalPlayer", v == true)
	end)
	NAgui.addToggle("Isolate Local Player Character", cfg.isolateLocalPlayerCharacter == true, function(v)
		setValue("isolateLocalPlayerCharacter", "saveInstanceIsolateLocalPlayerCharacter", v == true)
	end)
	NAgui.addToggle("Save Player Characters", cfg.savePlayerCharacters == true, function(v)
		setValue("savePlayerCharacters", "saveInstanceSavePlayerCharacters", v == true)
	end)
	NAgui.addToggle("Save Not Creatable", cfg.saveNotCreatable == true, function(v)
		setValue("saveNotCreatable", "saveInstanceSaveNotCreatable", v == true)
	end)
	NAgui.addToggle("Alternative Writefile", cfg.alternativeWritefile ~= false, function(v)
		setValue("alternativeWritefile", "saveInstanceAlternativeWritefile", v ~= false)
	end)
	NAgui.addToggle("Ignore Default PlayerScripts", cfg.ignoreDefaultPlayerScripts ~= false, function(v)
		setValue("ignoreDefaultPlayerScripts", "saveInstanceIgnoreDefaultPlayerScripts", v ~= false)
	end)
	NAgui.addToggle("Ignore SharedStrings", cfg.ignoreSharedStrings ~= false, function(v)
		setValue("ignoreSharedStrings", "saveInstanceIgnoreSharedStrings", v ~= false)
	end)
	NAgui.addToggle("SharedString Overwrite", cfg.sharedStringOverwrite == true, function(v)
		setValue("sharedStringOverwrite", "saveInstanceSharedStringOverwrite", v == true)
	end)
	NAgui.addToggle("Treat Unions As Parts", cfg.treatUnionsAsParts == true, function(v)
		setValue("treatUnionsAsParts", "saveInstanceTreatUnionsAsParts", v == true)
	end)

	NAgui.addSection("Streaming and Export")
	NAgui.addToggle("Capture Full Streaming Map", cfg.setStreaming == true, function(v)
		setValue("setStreaming", "saveInstanceSetStreaming", v == true)
	end)
	NAgui.addInput("Streaming Area Size", "10000", tostring(cfg.streamingAreaSize or 10000), function(text)
		setValue("streamingAreaSize", "saveInstanceStreamingAreaSize", math.max(1, tonumber(text) or 10000))
	end)
	NAgui.addInput("Streaming Radius", "1024", tostring(cfg.streamingRadius or 1024), function(text)
		setValue("streamingRadius", "saveInstanceStreamingRadius", math.max(1, tonumber(text) or 1024))
	end)
	NAgui.addInput("Streaming Timeout", "20", tostring(cfg.streamingTimeout or 20), function(text)
		setValue("streamingTimeout", "saveInstanceStreamingTimeout", math.max(1, tonumber(text) or 20))
	end)
	NAgui.addInput("Streaming Concurrency", "0 = Auto", tostring(cfg.streamingConcurrency or 0), function(text)
		setValue("streamingConcurrency", "saveInstanceStreamingConcurrency", math.max(0, math.floor((tonumber(text) or 0) + 0.5)))
	end)
	NAgui.addSlider("Streaming Slices", 1, 16, tonumber(cfg.streamingSlices) or 2, 1, "", function(v)
		setValue("streamingSlices", "saveInstanceStreamingSlices", math.clamp(math.floor((tonumber(v) or 2) + 0.5), 1, 16))
	end)
	NAgui.addInput("Streaming Max Time", "0 = Auto", tostring(cfg.streamingMaxTime or 0), function(text)
		setValue("streamingMaxTime", "saveInstanceStreamingMaxTime", math.max(0, tonumber(text) or 0))
	end)
	NAgui.addInput("Streaming Chunk Wait", "12", tostring(cfg.streamingChunkWait or 12), function(text)
		setValue("streamingChunkWait", "saveInstanceStreamingChunkWait", math.max(1, tonumber(text) or 12))
	end)
	NAgui.addInput("Streaming Settle Time", "5", tostring(cfg.streamingSettleTime or 5), function(text)
		setValue("streamingSettleTime", "saveInstanceStreamingSettleTime", math.max(0, tonumber(text) or 5))
	end)
	NAgui.addToggle("Neutralize Lighting", cfg.neutralizeLighting == true, function(v)
		setValue("neutralizeLighting", "saveInstanceNeutralizeLighting", v == true)
	end)
	NAgui.addToggle("Export Meshes As OBJ", cfg.exportObj == true, function(v)
		setValue("exportObj", "saveInstanceExportObj", v == true)
	end)

	NAgui.addSection("File")
	NAgui.addInput("File Name Format", "{placeName}_{timestamp}", tostring(cfg.fileNameFormat or "{placeName}_{timestamp}"), function(text)
		setValue("fileNameFormat", "saveInstanceFileNameFormat", NAmanage.TrimSaveInstanceText(text, "{placeName}_{timestamp}"))
	end)
	NAgui.addInput("Extra Options JSON", "{\"Option\":true}", tostring(cfg.extraOptionsJson or ""), function(text)
		setValue("extraOptionsJson", "saveInstanceExtraOptionsJson", NAmanage.TrimSaveInstanceText(text, ""))
	end)
	NAgui.addButton("Save Current Game", function()
		local ok, err = pcall(NAmanage.RunSaveInstance)
		if ok then
			DoNotif("SaveInstance 420 Edition finished with your saved NA settings.", 3)
		else
			DoNotif("SaveInstance 420 Edition failed: "..tostring(err), 4)
		end
	end)
end

NAmanage.OpenSaveInstanceSettings = NAmanage.OpenSaveInstanceSettings or function()
	if NAgui and type(NAgui.settingss) == "function" then
		pcall(NAgui.settingss)
	end

	const settingsFrame = NAUIMANAGER and NAUIMANAGER.SettingsFrame
	if settingsFrame then
		pcall(function()
			if settingsFrame.Visible ~= true then
				settingsFrame.Visible = true
			end
			if NAmanage.OnUIWindowShown then pcall(NAmanage.OnUIWindowShown, settingsFrame) end

			if settingsFrame.GetAttribute and settingsFrame.Size then
				const minimized = NAmanage.GetAttr(settingsFrame, "NAMenuMinimized") == true
				if minimized then
					const restoreX = tonumber(NAmanage.GetAttr(settingsFrame, "NAMenuStoredSizeX")) or settingsFrame.Size.X.Offset
					const restoreY = tonumber(NAmanage.GetAttr(settingsFrame, "NAMenuStoredSizeY")) or settingsFrame.Size.Y.Offset
					NAmanage.SetAttr(settingsFrame, "NAMenuMinimized", false)
					settingsFrame.Size = UDim2.new(0, restoreX, 0, restoreY)
				end
			end

			if NAmanage and type(NAmanage.centerFrame) == "function" then
				NAmanage.centerFrame(settingsFrame)
			end
		end)
	end

	if NAgui and type(NAgui.setTab) == "function" then
		pcall(function()
			NAgui.setTab(NA_TABS.TAB_SAVE_INSTANCE)
		end)
	end
end

NAmanage.RunSaveInstanceCommand = NAmanage.RunSaveInstanceCommand or function()
	local ok, err = pcall(NAmanage.RunSaveInstance)
	if ok then
		DoNotif("SaveInstance 420 Edition finished with your saved NA settings.", 3)
	else
		DoNotif("SaveInstance 420 Edition failed: "..tostring(err), 4)
	end
end

cmd.add({"saveinstance","savegame"},{"saveinstance (savegame)","Saves the game with SaveInstance 420 Edition using your saved options"},function()
	if NAmanage.NASettingsGet("saveInstanceCommandHintShown") ~= true then
		pcall(NAmanage.NASettingsSet, "saveInstanceCommandHintShown", true)
		if type(Popup) == "function" then
			Popup({
				Title = "SaveInstance 420 Setup",
				Description = "Do you want to configure SaveInstance 420 Edition first? Confirm opens the Save Instance settings tab. Ignore uses the current saved defaults.",
				Duration = 0,
				Buttons = {
					{
						Text = "Confirm",
						Callback = function()
							NAmanage.OpenSaveInstanceSettings()
						end,
					},
					{
						Text = "Ignore",
						Callback = function()
							NAmanage.RunSaveInstanceCommand()
						end,
					},
				},
			})
			return
		else
			DoNotif("Tip: open the Save Instance tab in settings if you want to configure the save options first.", 7)
		end
	end
	NAmanage.RunSaveInstanceCommand()
end)

cmd.add({"admin","whitelist"},{"admin <player>","Whitelist the user to have access to *your* client-side commands, anything they type runs on *you*, not on themselves"},function(...)
	const Player=getPlr(NAmanage.PlayerQueryFromArgs(...))
	const pending={}
	for _, plr in next, Player do
		if plr~=nil and not Admin[plr.UserId] then
			pending[#pending+1]=plr
		end
	end
	if #pending==0 then
		DoNotif("No eligible player found")
		return
	end
	const names={}
	for _, plr in pending do names[#names+1]=nameChecker(plr) end
	const function grantAdmin(tellUser)
		for _, plr in pending do
			if plr and plr.Parent and not Admin[plr.UserId] then
				Admin[plr.UserId]={plr=plr}
				if tellUser then
					NAlib.LocalPlayerChat("["..adminName.."] You've got admin. Prefix: ';'. Your commands will control my client.",plr.Name)
					Wait(0.2)
				end
				DoNotif(nameChecker(plr).." has now been whitelisted to use commands"..(tellUser and " and was notified" or " silently"),15)
			end
		end
	end
	const show=Window or DoWindow
	if type(show)=="function" then
		show({
			Title="Admin Access",
			Description="Whitelist "..Concat(names, ", ").."?\n\nChoose whether they should be privately told that their ';' commands will control your client.",
			Buttons={
				{Text="Tell User",Callback=function() grantAdmin(true) end},
				{Text="Silent",Callback=function() grantAdmin(false) end},
			}
		})
	else
		grantAdmin(false)
	end
end,true)

cmd.add({"unadmin"},{"unadmin <player>","removes someone from being admin"},function(...)
	function ChatMessage(Message,Whisper)
		NAlib.LocalPlayerChat(Message,Whisper or "All")
	end
	const Player=getPlr(NAmanage.PlayerQueryFromArgs(...))
	for _, plr in next, Player do
		if plr~=nil and Admin[plr.UserId] then
			Admin[plr.UserId]=nil
			ChatMessage("You can no longer use commands",plr.Name)
			DoNotif(nameChecker(plr).." is no longer an admin",15)
		else
			DoNotif("Player not found")
		end
	end
end,true)

cmd.add({"partname","partpath","partgrabber"},{"partname (partpath,partgrabber)","gives a ui and allows you click on a part to grab it's path"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/PartGrabber.lua")
end)

cmd.add({"jobid"},{"jobid","Copies your job id"},function()
	if setclipboard then
		setclipboard(tostring(JobId))
		Wait();

		DebugNotif("Copied your jobid ("..JobId..")")
	else
		DoNotif("Your executor does not support setclipboard")
	end
end)

cmd.add({"joinjobid","joinjid","jjobid","jjid"},{"joinjobid <jobid>","Joins the job id you put in"},function(...)
	zeId={...}
	id=zeId[1]
	NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { PlaceId, id, Services.Players.LocalPlayer }, { placeId = PlaceId; placeName = game.Name; action = "JOINING SERVER"; detail = "Job ID "..tostring(id) })
end,true)

NAmanage.CopyScriptsPlugin = NAmanage.CopyScriptsPlugin or {}
(function(csp)
	csp.num = function(n)
		n = tonumber(n) or 0
		if n ~= n or n == math.huge or n == -math.huge then
			return "0"
		end
		local text = Format("%.17g", n)
		if text == "-0" then
			text = "0"
		end
		return text
	end

	csp.cf = function(cf)
		const vals = { cf:GetComponents() }
		for i = 1, #vals do
			vals[i] = csp.num(vals[i])
		end
		return "CFrame.new("..Concat(vals, ", ")..")"
	end

	csp.vec = function(vec)
		return "Vector3.new("..csp.num(vec.X)..", "..csp.num(vec.Y)..", "..csp.num(vec.Z)..")"
	end

	csp.get = function()
		const lp = Services.Players and Services.Players.LocalPlayer
		const ch = lp and lp.Character
		if not ch then
			return nil, "No character found"
		end
		const root = ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart
		local ok, piv = pcall(function()
			return ch:GetPivot()
		end)
		if not ok or typeof(piv) ~= "CFrame" then
			if not root then
				return nil, "No character pivot found"
			end
			piv = root.CFrame
		end
		return {
			ch = ch;
			root = root;
			piv = piv;
			rcf = root and root.CFrame or piv;
			pos = root and root.Position or piv.Position;
		}
	end

	csp.clip = function(text, msg)
		if type(setclipboard) ~= "function" then
			DoNotif("Your executor does not support setclipboard", 3)
			return
		end
		local ok, err = pcall(setclipboard, tostring(text or ""))
		if ok then
			DoNotif(msg or "Copied script to clipboard.", 3)
		else
			DoNotif("Clipboard failed: "..tostring(err), 4)
		end
	end

	csp.lines = function(list)
		return Concat(list, "\n")
	end

	csp.mkTeleport = function()
		local dat, err = csp.get()
		if not dat then return nil, err end
		return csp.lines({
			"local Players = game:GetService(\"Players\")",
			"local lp = Players.LocalPlayer",
			"local ch = lp.Character or lp.CharacterAdded:Wait()",
			"ch:PivotTo("..csp.cf(dat.piv)..")",
		})
	end

	csp.mkTween = function()
		local dat, err = csp.get()
		if not dat then return nil, err end
		return csp.lines({
			"local Players = game:GetService(\"Players\")",
			"local TweenService = game:GetService(\"TweenService\")",
			"local lp = Players.LocalPlayer",
			"local ch = lp.Character or lp.CharacterAdded:Wait()",
			"local root = ch:WaitForChild(\"HumanoidRootPart\")",
			"local info = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)",
			"local tw = TweenService:Create(root, info, { CFrame = "..csp.cf(dat.rcf).." })",
			"tw:Play()",
			"tw.Completed:Wait()",
		})
	end

	csp.mkMoveTo = function()
		local dat, err = csp.get()
		if not dat then return nil, err end
		return csp.lines({
			"local Players = game:GetService(\"Players\")",
			"local lp = Players.LocalPlayer",
			"local ch = lp.Character or lp.CharacterAdded:Wait()",
			"local hum = ch:FindFirstChildOfClass(\"Humanoid\") or ch:WaitForChild(\"Humanoid\")",
			"hum:MoveTo("..csp.vec(dat.pos)..")",
			"hum.MoveToFinished:Wait()",
		})
	end

	csp.mkLerp = function()
		local dat, err = csp.get()
		if not dat then return nil, err end
		return csp.lines({
			"local Players = game:GetService(\"Players\")",
			"local RunService = game:GetService(\"RunService\")",
			"local lp = Players.LocalPlayer",
			"local ch = lp.Character or lp.CharacterAdded:Wait()",
			"local root = ch:WaitForChild(\"HumanoidRootPart\")",
			"local goal = "..csp.cf(dat.rcf),
			"local con",
			"con = RunService.Heartbeat:Connect(function(dt)",
			"\tif not root.Parent then con:Disconnect() return end",
			"\troot.CFrame = root.CFrame:Lerp(goal, math.clamp(dt * 8, 0, 1))",
			"\tif (root.Position - goal.Position).Magnitude <= 0.5 then",
			"\t\troot.CFrame = goal",
			"\t\tcon:Disconnect()",
			"\tend",
			"end)",
		})
	end

	csp.mkGame = function()
		return csp.lines({
			"local Players = game:GetService(\"Players\")",
			"local TeleportService = game:GetService(\"TeleportService\")",
			"local ExperienceService = game:GetService(\"ExperienceService\")",
			"local lp = Players.LocalPlayer",
			"local params = { placeId = "..tostring(PlaceId).." }",
			"local usedFallback = false",
			"local function fallback() if usedFallback then return end usedFallback = true pcall(function() ExperienceService:LaunchExperience(params) end) end",
			"local con; con = TeleportService.TeleportInitFailed:Connect(function(player) if player == lp then if con then con:Disconnect() end fallback() end end)",
			"local ok = pcall(function() TeleportService:Teleport("..tostring(PlaceId)..", lp) end)",
			"if not ok then if con then con:Disconnect() end fallback() end",
		})
	end

	csp.mkServer = function()
		const instanceId = Format("%q", tostring(JobId or ""))
		return csp.lines({
			"local Players = game:GetService(\"Players\")",
			"local TeleportService = game:GetService(\"TeleportService\")",
			"local ExperienceService = game:GetService(\"ExperienceService\")",
			"local lp = Players.LocalPlayer",
			"local params = { placeId = "..tostring(PlaceId)..", gameInstanceId = "..instanceId.." }",
			"local usedFallback = false",
			"local function fallback() if usedFallback then return end usedFallback = true pcall(function() ExperienceService:LaunchExperience(params) end) end",
			"local con; con = TeleportService.TeleportInitFailed:Connect(function(player) if player == lp then if con then con:Disconnect() end fallback() end end)",
			"local ok = pcall(function() TeleportService:TeleportToPlaceInstance("..tostring(PlaceId)..", "..instanceId..", lp) end)",
			"if not ok then if con then con:Disconnect() end fallback() end",
		})
	end

	csp.run = function(maker, msg)
		local text, err = maker()
		if not text then
			DoNotif(tostring(err or "Failed to create script"), 3)
			return
		end
		csp.clip(text, msg)
	end
end)(NAmanage.CopyScriptsPlugin)

cmd.add({"copyteleport","ct"},{"copyteleport (ct)","Copies a script that teleports you to your coordinates"},function()
	NAmanage.CopyScriptsPlugin.run(NAmanage.CopyScriptsPlugin.mkTeleport, "Copied teleport script to clipboard.")
end)

cmd.add({"copytween","ctw"},{"copytween (ctw)","Copies a TweenService script that moves you to your coordinates"},function()
	NAmanage.CopyScriptsPlugin.run(NAmanage.CopyScriptsPlugin.mkTween, "Copied tween script to clipboard.")
end)

cmd.add({"copymoveto","cmt"},{"copymoveto (cmt)","Copies a Humanoid:MoveTo script that moves you to your coordinates"},function()
	NAmanage.CopyScriptsPlugin.run(NAmanage.CopyScriptsPlugin.mkMoveTo, "Copied MoveTo script to clipboard.")
end)

cmd.add({"copylerp","cl"},{"copylerp (cl)","Copies a CFrame:Lerp script that moves you to your coordinates"},function()
	NAmanage.CopyScriptsPlugin.run(NAmanage.CopyScriptsPlugin.mkLerp, "Copied Lerp script to clipboard.")
end)

cmd.add({"copytptogame","cttg"},{"copytptogame (cttg)","Copies a script for teleporting to the game you are currently in"},function()
	NAmanage.CopyScriptsPlugin.run(NAmanage.CopyScriptsPlugin.mkGame, "Copied game teleport script to clipboard.")
end)

cmd.add({"copytptoserver","ctts"},{"copytptoserver (ctts)","Copies a script for teleporting to your current game server"},function()
	NAmanage.CopyScriptsPlugin.run(NAmanage.CopyScriptsPlugin.mkServer, "Copied server teleport script to clipboard.")
end)

NAStuff.srv = NAStuff.srv or {}

NAStuff.srvWorker = NAStuff.srvWorker or "https://solaraserverhop.ltseverydayyou.workers.dev"

NAStuff.srv.b = {
	"https://games.rotunnel.com",
	"https://games.roproxy.com",
	"https://games.roblox.com",
}

NAStuff.srv.latency = type(NAStuff.srv.latency) == "table" and NAStuff.srv.latency or {}
NAStuff.srv.latency.cfg = {
	rovalraBase = "https://apis.rovalra.com";
	datacentersUrl = "https://apis.rovalra.com/v1/datacenters/list";
	geolocationUrl = "https://ipapi.co/json/";
	modelTtl = 900;
	regionTtl = 45;
	publicPageLimit = 25;
	regionPageLimit = 2;
	requestDelay = 0.12;
	baseOverheadMs = 30;
	defaultCoefficient = 1;
	minCoefficient = 0.3;
	maxCoefficient = 3;
	calibrationMinDistanceKm = 200;
}
NAStuff.srv.latency.model = type(NAStuff.srv.latency.model) == "table" and NAStuff.srv.latency.model or {
	ready = false;
	loading = false;
	updatedAt = 0;
	datacenters = {};
	origin = nil;
	originIsReal = false;
	coefficient = 1;
	baseOverheadMs = 30;
	currentServerRealPing = nil;
	currentServerCity = nil;
	cityOrder = {};
	cityRank = {};
	cityPing = {};
}
NAStuff.srv.latency.regionCache = type(NAStuff.srv.latency.regionCache) == "table" and NAStuff.srv.latency.regionCache or {}
NAStuff.srv.detailsCache = type(NAStuff.srv.detailsCache) == "table" and NAStuff.srv.detailsCache or {}
NAStuff.srv.countsCache = type(NAStuff.srv.countsCache) == "table" and NAStuff.srv.countsCache or {}
NAStuff.srv.detailsTtl = tonumber(NAStuff.srv.detailsTtl) or 60
NAStuff.srv.countsTtl = tonumber(NAStuff.srv.countsTtl) or 60

NAStuff.srv.j = function(self, s)
	if type(s) ~= "string" or #s == 0 then
		return nil
	end
	local ok, js = pcall(function()
		return Services.HttpService:JSONDecode(s)
	end)
	if ok and type(js) == "table" then
		return js
	end
	return nil
end

NAStuff.srv.get = function(self, url)
	local ok, body = NAmanage.HttpGet(url, {
		timeout = 6,
		maxAttempts = 5,
		Headers = { Accept = "application/json" },
	})
	if ok and type(body) == "string" and #body > 0 then
		return body
	end
end

NAStuff.srv.extractLatLon = function(self, location)
	if type(location) ~= "table" then
		return nil, nil
	end
	if type(location.latLong) == "table" then
		return tonumber(location.latLong[1]), tonumber(location.latLong[2])
	end
	if location.latitude ~= nil and location.longitude ~= nil then
		return tonumber(location.latitude), tonumber(location.longitude)
	end
	if location.lat ~= nil and location.lon ~= nil then
		return tonumber(location.lat), tonumber(location.lon)
	end
	return nil, nil
end

NAStuff.srv.haversine = function(self, lat1, lon1, lat2, lon2)
	lat1, lon1, lat2, lon2 = tonumber(lat1), tonumber(lon1), tonumber(lat2), tonumber(lon2)
	if not (lat1 and lon1 and lat2 and lon2) then
		return math.huge
	end
	const radiusKm = 6371
	const dLat = math.rad(lat2 - lat1)
	const dLon = math.rad(lon2 - lon1)
	const a = math.sin(dLat / 2) ^ 2 + math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) * math.sin(dLon / 2) ^ 2
	const c = 2 * math.atan2(math.sqrt(a), math.sqrt(math.max(0, 1 - a)))
	return radiusKm * c
end

NAStuff.srv.getCurrentRealPing = function(self)
	local ok, value = pcall(function()
		return Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(value) == "number" and value > 0 then
		return value
	end
	return nil
end

NAStuff.srv.getCurrentServerCity = function(self)
	if tostring(game.JobId or "") == "" then
		return nil
	end
	const cfg = self.latency.cfg
	const url = cfg.rovalraBase.."/v1/servers/details?place_id="..tostring(game.PlaceId).."&server_ids="..Services.HttpService:UrlEncode(tostring(game.JobId))
	const decoded = self:j(self:get(url))
	if type(decoded) == "table" and type(decoded.servers) == "table" and type(decoded.servers[1]) == "table" then
		const city = decoded.servers[1].city
		if city ~= nil and tostring(city) ~= "" then
			return tostring(city)
		end
	end
	return nil
end


NAStuff.srv.parseIsoTimestamp = function(self, value)
	if type(value) ~= "string" or value == "" then return nil end
	local y, mo, d, h, mi, s = value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)")
	y, mo, d, h, mi, s = tonumber(y), tonumber(mo), tonumber(d), tonumber(h), tonumber(mi), tonumber(s)
	if not (y and mo and d and h and mi and s) then return nil end
	local ok, dt = pcall(DateTime.fromUniversalTime, y, mo, d, h, mi, s)
	if ok and dt then return dt.UnixTimestamp end
	return nil
end

NAStuff.srv.formatUptime = function(self, seconds, estimated)
	local value = tonumber(seconds)
	if not value or value < 0 then return "Unknown" end
	value = math.floor(value)
	const days = math.floor(value / 86400)
	const hours = math.floor((value % 86400) / 3600)
	const minutes = math.floor((value % 3600) / 60)
	const secs = math.floor(value % 60)
	const parts = {}
	if days > 0 then parts[#parts + 1] = tostring(days).."d" end
	if hours > 0 then parts[#parts + 1] = tostring(hours).."h" end
	if minutes > 0 then parts[#parts + 1] = tostring(minutes).."m" end
	if #parts == 0 then parts[#parts + 1] = tostring(secs).."s" end
	return Concat(parts, " ")..(estimated == true and "~" or "")
end

NAStuff.srv.normalizeDetail = function(self, raw)
	if type(raw) ~= "table" then return nil end
	const id = tostring(raw.server_id or raw.id or "")
	if id == "" then return nil end
	local firstSeenUnix = self:parseIsoTimestamp(raw.first_seen)
	local uptime = nil
	if firstSeenUnix then
		local nowUnix = nil
		local okNow, nowDt = pcall(DateTime.now)
		if okNow and nowDt then nowUnix = nowDt.UnixTimestamp end
		if nowUnix then uptime = math.max(0, nowUnix - firstSeenUnix) end
	end
	const locationParts = {}
	if raw.city and tostring(raw.city) ~= "" and tostring(raw.city) ~= "Unknown" then locationParts[#locationParts + 1] = tostring(raw.city) end
	if raw.region and tostring(raw.region) ~= "" and tostring(raw.region) ~= "Unknown" and tostring(raw.region) ~= tostring(raw.city) then locationParts[#locationParts + 1] = tostring(raw.region) end
	if raw.country and tostring(raw.country) ~= "" and tostring(raw.country) ~= "Unknown" then locationParts[#locationParts + 1] = tostring(raw.country) end
	return {
		id = id;
		serverId = id;
		firstSeen = raw.first_seen;
		firstSeenUnix = firstSeenUnix;
		uptime = uptime;
		uptimeEstimated = firstSeenUnix ~= nil;
		placeVersion = tonumber(raw.place_version) or raw.place_version;
		city = raw.city and tostring(raw.city) or nil;
		regionName = raw.region and tostring(raw.region) or nil;
		country = raw.country and tostring(raw.country) or nil;
		ipAddress = raw.ip_address and tostring(raw.ip_address) or nil;
		datacenterId = raw.datacenter_id;
		regionLabel = #locationParts > 0 and Concat(locationParts, ", ") or nil;
	}
end

NAStuff.srv.fetchDetails = function(self, placeId, serverIds, force)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	if type(serverIds) ~= "table" or #serverIds == 0 then return {} end
	const results = {}
	const missing = {}
	const now = tick()
	for _, rawId in serverIds do
		const id = tostring(rawId or "")
		if id ~= "" then
			const key = tostring(pid).."|"..id
			const cached = self.detailsCache[key]
			if not force and type(cached) == "table" and now - (tonumber(cached.at) or 0) < self.detailsTtl and type(cached.data) == "table" then
				results[id] = cached.data
			else
				missing[#missing + 1] = id
			end
		end
	end
	local index = 1
	while index <= #missing do
		const batch = {}
		for i = index, math.min(index + 39, #missing) do batch[#batch + 1] = missing[i] end
		index += #batch
		const url = self.latency.cfg.rovalraBase.."/v1/servers/details?place_id="..tostring(pid).."&server_ids="..Services.HttpService:UrlEncode(Concat(batch, ","))
		const decoded = self:j(self:get(url))
		if type(decoded) == "table" and type(decoded.servers) == "table" then
			for _, raw in decoded.servers do
				const detail = self:normalizeDetail(raw)
				if detail then
					results[detail.id] = detail
					self.detailsCache[tostring(pid).."|"..detail.id] = { at = tick(); data = detail }
				end
			end
		end
		if index <= #missing then Wait(self.latency.cfg.requestDelay) end
	end
	return results
end

NAStuff.srv.getServerDetail = function(self, placeId, serverId, force)
	const id = tostring(serverId or "")
	if id == "" then return nil end
	const map = self:fetchDetails(placeId, { id }, force)
	return map[id]
end

NAStuff.srv.getCounts = function(self, placeId, force)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	const key = tostring(pid)
	const cached = self.countsCache[key]
	if not force and type(cached) == "table" and tick() - (tonumber(cached.at) or 0) < self.countsTtl and type(cached.data) == "table" then
		return cached.data
	end
	const url = self.latency.cfg.rovalraBase.."/v1/servers/counts?place_id="..tostring(pid)
	const decoded = self:j(self:get(url))
	if type(decoded) == "table" and type(decoded.counts) == "table" then
		self.countsCache[key] = { at = tick(); data = decoded.counts }
		return decoded.counts
	end
	return nil
end

NAStuff.srv.queryRoValraServers = function(self, path, pageLimit)
	local cursor = nil
	local page = 0
	const out = {}
	const seen = {}
	while page < math.max(1, math.floor(tonumber(pageLimit) or 3)) do
		page += 1
		local url = self.latency.cfg.rovalraBase..path
		if cursor and cursor ~= "" and cursor ~= "0" then
			url ..= (url:find("?", 1, true) and "&" or "?").."cursor="..Services.HttpService:UrlEncode(tostring(cursor))
		end
		const decoded = self:j(self:get(url))
		if type(decoded) ~= "table" or type(decoded.servers) ~= "table" then break end
		for _, raw in decoded.servers do
			if type(raw) == "table" then
				const id = tostring(raw.server_id or raw.id or "")
				if id ~= "" and not seen[id] then
					seen[id] = true
					out[#out + 1] = raw
				end
			end
		end
		cursor = decoded.next_cursor or decoded.nextPageCursor
		if not cursor or cursor == "" or cursor == "0" then break end
		Wait(self.latency.cfg.requestDelay)
	end
	return out
end

NAStuff.srv.resolveRegionQuery = function(self, query)
	const raw = tostring(query or ""):match("^%s*(.-)%s*$") or ""
	if raw == "" then return nil end
	self:refreshLatencyModel(false)
	const needle = Lower(raw)
	local best = nil
	local bestRank = math.huge
	for _, dc in self.latency.model.datacenters do
		const city = tostring(dc.city or "")
		const country = tostring(dc.country or "")
		const cityLower = Lower(city)
		const countryLower = Lower(country)
		local score = nil
		if cityLower == needle then score = 0
		elseif countryLower == needle then score = 1
		elseif cityLower:find(needle, 1, true) then score = 2
		elseif countryLower:find(needle, 1, true) then score = 3 end
		if score ~= nil then
			const rank = tonumber(self.latency.model.cityRank[city]) or math.huge
			if not best or score < best.score or (score == best.score and rank < bestRank) then
				best = { city = city; country = country; score = score }
				bestRank = rank
			end
		end
	end
	return best or { city = raw; country = nil; score = 9 }
end

NAStuff.srv.matchPublicByIds = function(self, placeId, orderedIds, mode)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	if type(orderedIds) ~= "table" or #orderedIds == 0 then return nil, "no servers returned" end
	const _, byId = self:collect(pid, mode == "fullest" and "high" or "low", self.latency.cfg.publicPageLimit)
	for _, id in orderedIds do
		const server = byId[tostring(id)]
		if server then
			local details = self:fetchDetails(pid, { tostring(id) }, false)
			const detail = details[tostring(id)]
			if detail then
				for k, v in detail do server[k] = v end
				if detail.city then server.region = detail.city end
				if detail.regionLabel then server.regionLabel = detail.regionLabel end
			end
			if self:refreshLatencyModel(false) and server.city then
				server.regionRank = self.latency.model.cityRank[server.city]
				server.latency = self.latency.model.cityPing[server.city]
				server.latencyEstimated = tonumber(server.latency) ~= nil
			end
			if not tonumber(server.latency) and (tonumber(server.ping) or 0) > 0 then
				server.latency = tonumber(server.ping)
				server.latencyEstimated = false
			end
			return server
		end
	end
	return nil, "matching public server was not found"
end

NAStuff.srv.pickUptime = function(self, placeId, kind)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	kind = kind == "newest" and "newest" or "oldest"
	const raw = self:queryRoValraServers("/v1/servers/"..kind.."?place_id="..tostring(pid).."&limit=100", 4)
	const ids = {}
	for _, entry in raw do
		const id = tostring(entry.server_id or entry.id or "")
		if id ~= "" and not (pid == tonumber(game.PlaceId) and id == tostring(game.JobId)) then ids[#ids + 1] = id end
	end
	return self:matchPublicByIds(pid, ids, "low")
end

NAStuff.srv.pickVersion = function(self, placeId, version)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	const ver = tonumber(version)
	if not ver then return nil, "invalid place version" end
	const path = "/v1/servers/versions?place_id="..tostring(pid).."&place_version="..tostring(math.floor(ver)).."&limit=100"
	const raw = self:queryRoValraServers(path, 4)
	const ids = {}
	for _, entry in raw do
		const id = tostring(entry.server_id or entry.id or "")
		if id ~= "" and not (pid == tonumber(game.PlaceId) and id == tostring(game.JobId)) then ids[#ids + 1] = id end
	end
	return self:matchPublicByIds(pid, ids, "low")
end

NAStuff.srv.pickOldestVersion = function(self, placeId)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	const counts = self:getCounts(pid, false)
	local version = counts and tonumber(counts.oldest_place_version) or nil
	if not version and counts and type(counts.place_versions) == "table" then
		for _, rawVersion in counts.place_versions do
			const n = tonumber(type(rawVersion) == "table" and (rawVersion.place_version or rawVersion.version) or rawVersion)
			if n and (not version or n < version) then version = n end
		end
	end
	if not version then return nil, "oldest active place version is unavailable" end
	local server, err = self:pickVersion(pid, version)
	if server then server.requestedVersion = version end
	return server, err, version
end

NAStuff.srv.pickRegion = function(self, placeId, query)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	const resolved = self:resolveRegionQuery(query)
	if not resolved then return nil, "region is required" end
	local path = "/v1/servers/region?place_id="..tostring(pid).."&city="..Services.HttpService:UrlEncode(tostring(resolved.city)).."&limit=100"
	local raw = self:queryRoValraServers(path, 3)
	if #raw == 0 then
		path = "/v1/servers/region?place_id="..tostring(pid).."&region="..Services.HttpService:UrlEncode(tostring(query)).."&limit=100"
		raw = self:queryRoValraServers(path, 3)
	end
	const ids = {}
	for _, entry in raw do
		const id = tostring(entry.server_id or entry.id or "")
		if id ~= "" and not (pid == tonumber(game.PlaceId) and id == tostring(game.JobId)) then ids[#ids + 1] = id end
	end
	local server, err = self:matchPublicByIds(pid, ids, "low")
	if server then
		server.region = server.city or resolved.city
		server.regionLabel = server.regionLabel or resolved.city
	end
	return server, err, resolved
end

NAStuff.srv.refreshLatencyModel = function(self, force)
	const latency = self.latency
	const cfg = latency.cfg
	const model = latency.model
	const now = tick()
	if not force and model.ready == true and now - (tonumber(model.updatedAt) or 0) < cfg.modelTtl then
		return true
	end
	if model.loading == true then
		const started = tick()
		while model.loading == true and tick() - started < 10 do
			Wait(0.05)
		end
		return model.ready == true
	end

	model.loading = true
	local okRefresh = pcall(function()
		model.ready = false
		model.datacenters = {}
		model.origin = nil
		model.originIsReal = false
		model.coefficient = cfg.defaultCoefficient
		model.baseOverheadMs = cfg.baseOverheadMs
		model.currentServerRealPing = nil
		model.currentServerCity = nil
		model.cityOrder = {}
		model.cityRank = {}
		model.cityPing = {}

		const dcDecoded = self:j(self:get(cfg.datacentersUrl))
		if type(dcDecoded) == "table" then
			const seenCities = {}
			for _, dc in dcDecoded do
				const location = type(dc) == "table" and dc.location or nil
				const city = type(location) == "table" and location.city or nil
				local lat, lon = self:extractLatLon(location)
				if city and lat and lon and not seenCities[tostring(city)] then
					seenCities[tostring(city)] = true
					model.datacenters[#model.datacenters + 1] = {
						city = tostring(city);
						country = tostring(location.country or "");
						lat = lat;
						lon = lon;
					}
				end
			end
		end

		const geoDecoded = self:j(self:get(cfg.geolocationUrl))
		if type(geoDecoded) == "table" then
			local lat, lon = self:extractLatLon(geoDecoded)
			if lat and lon then
				model.origin = { lat = lat; lon = lon }
				model.originIsReal = true
			end
		end

		model.currentServerCity = self:getCurrentServerCity()
		if not model.origin and model.currentServerCity then
			for _, dc in model.datacenters do
				if dc.city == model.currentServerCity then
					model.origin = { lat = dc.lat; lon = dc.lon }
					break
				end
			end
		end

		if model.origin and #model.datacenters > 0 then
			const ranked = {}
			for _, dc in model.datacenters do
				ranked[#ranked + 1] = {
					city = dc.city;
					distance = self:haversine(model.origin.lat, model.origin.lon, dc.lat, dc.lon);
				}
			end
			table.sort(ranked, function(a, b)
				return a.distance < b.distance
			end)

			const realPing = self:getCurrentRealPing()
			if realPing and model.currentServerCity then
				model.currentServerRealPing = math.floor(realPing)
				for _, entry in ranked do
					if entry.city == model.currentServerCity and entry.distance > cfg.calibrationMinDistanceKm then
						const coefficient = (realPing - cfg.baseOverheadMs) / math.sqrt(entry.distance)
						if coefficient == coefficient and coefficient > 0 then
							model.coefficient = math.clamp(coefficient, cfg.minCoefficient, cfg.maxCoefficient)
						end
						break
					end
				end
			end

			for index, entry in ranked do
				const estimated = math.max(1, math.floor(model.coefficient * math.sqrt(math.max(0, entry.distance)) + model.baseOverheadMs))
				model.cityOrder[index] = {
					city = entry.city;
					distance = entry.distance;
					latency = estimated;
					rank = index;
				}
				model.cityRank[entry.city] = index
				model.cityPing[entry.city] = estimated
			end
			model.ready = #model.cityOrder > 0
		end
		model.updatedAt = tick()
	end)
	model.loading = false
	if not okRefresh then
		model.ready = false
	end
	return model.ready == true
end

NAStuff.srv.pg = function(self, cid, mode, placeId)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	const sortOrder = mode == "high" and "Desc" or "Asc"
	local q = "?sortOrder="..sortOrder.."&excludeFullGames=true&limit=100"
	if cid and cid ~= "" then
		q ..= "&cursor="..Services.HttpService:UrlEncode(cid)
	end

	const primaryBase = self.b[1] or "https://games.rotunnel.com"
	local body = self:get(primaryBase.."/v1/games/"..tostring(pid).."/servers/Public"..q)
	if type(body) == "string" and #body > 0 then
		const js = self:j(body)
		if type(js) == "table" and type(js.data) == "table" then
			return js.data, js.nextPageCursor
		end
	end

	local wq = "placeId="..tostring(pid)
	wq ..= "&sortOrder="..Services.HttpService:UrlEncode(sortOrder).."&excludeFullGames=true"
	if cid and cid ~= "" then
		wq ..= "&cursor="..Services.HttpService:UrlEncode(cid)
	end
	const wbody = self:get(NAStuff.srvWorker.."/servers?"..wq)
	if type(wbody) == "string" and #wbody > 0 then
		const js = self:j(wbody)
		if type(js) == "table" and type(js.data) == "table" then
			return js.data, js.nextPageCursor
		end
	end

	for index = 2, #self.b do
		const base = self.b[index]
		body = self:get(base.."/v1/games/"..tostring(pid).."/servers/Public"..q)
		if type(body) == "string" and #body > 0 then
			const js = self:j(body)
			if type(js) == "table" and type(js.data) == "table" then
				return js.data, js.nextPageCursor
			end
		end
	end

	return nil, nil
end

NAStuff.srv.collect = function(self, placeId, mode, pageLimit)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	const maxPages = math.clamp(math.floor(tonumber(pageLimit) or self.latency.cfg.publicPageLimit), 1, self.latency.cfg.publicPageLimit)
	const servers = {}
	const byId = {}
	local cursor = nil
	local page = 0
	while page < maxPages do
		page += 1
		local data, nextCursor = self:pg(cursor, mode, pid)
		if type(data) ~= "table" then
			break
		end
		for _, raw in data do
			if type(raw) == "table" then
				const id = tostring(raw.id or "")
				const playing = tonumber(raw.playing) or 0
				const maximum = tonumber(raw.maxPlayers or raw.max) or 0
				if id ~= "" and maximum > playing and not (pid == tonumber(game.PlaceId) and id == tostring(game.JobId)) and not byId[id] then
					const server = {
						id = id;
						playing = playing;
						max = maximum;
						ping = tonumber(raw.ping) or 0;
						fps = tonumber(raw.fps) or 0;
					}
					servers[#servers + 1] = server
					byId[id] = server
				end
			end
		end
		if not nextCursor or nextCursor == "" then
			break
		end
		cursor = nextCursor
		Wait()
	end
	return servers, byId
end

NAStuff.srv.regionIds = function(self, placeId, city)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	const cfg = self.latency.cfg
	const key = tostring(pid).."|"..tostring(city)
	const cached = self.latency.regionCache[key]
	if type(cached) == "table" and tick() - (tonumber(cached.at) or 0) < cfg.regionTtl and type(cached.ids) == "table" then
		return cached.ids
	end

	const ids = {}
	local cursor = "0"
	local pages = 0
	while cursor and pages < cfg.regionPageLimit do
		pages += 1
		const url = cfg.rovalraBase.."/v1/servers/region?place_id="..tostring(pid).."&city="..Services.HttpService:UrlEncode(tostring(city)).."&limit=100&cursor="..Services.HttpService:UrlEncode(tostring(cursor))
		const decoded = self:j(self:get(url))
		if type(decoded) ~= "table" or type(decoded.servers) ~= "table" then
			break
		end
		for _, entry in decoded.servers do
			if type(entry) == "table" and entry.server_id then
				ids[tostring(entry.server_id)] = true
			end
		end
		cursor = decoded.next_cursor
		if not cursor or cursor == "" or cursor == "0" then
			break
		end
		Wait(cfg.requestDelay)
	end
	self.latency.regionCache[key] = { at = tick(); ids = ids }
	return ids
end

NAStuff.srv.sortCandidates = function(self, servers, mode)
	table.sort(servers, function(a, b)
		if mode == "low" then
			if a.playing ~= b.playing then return a.playing < b.playing end
		elseif mode == "high" then
			if a.playing ~= b.playing then return a.playing > b.playing end
		else
			const ap = tonumber(a.ping) or 0
			const bp = tonumber(b.ping) or 0
			if ap ~= bp then
				if ap <= 0 then return false end
				if bp <= 0 then return true end
				return ap < bp
			end
			if a.playing ~= b.playing then return a.playing > b.playing end
		end
		const ap = tonumber(a.ping) or 0
		const bp = tonumber(b.ping) or 0
		if ap ~= bp then
			if ap <= 0 then return false end
			if bp <= 0 then return true end
			return ap < bp
		end
		return tostring(a.id) < tostring(b.id)
	end)
	return servers
end

NAStuff.srv.pickLatency = function(self, placeId, mode)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	mode = mode == "low" and "low" or mode == "high" and "high" or "ping"
	const servers, byId = self:collect(pid, mode, self.latency.cfg.publicPageLimit)
	if #servers == 0 then
		return nil, "no joinable public servers"
	end

	if self:refreshLatencyModel(false) then
		for _, cityInfo in self.latency.model.cityOrder do
			const ids = self:regionIds(pid, cityInfo.city)
			const matches = {}
			for id in ids do
				const server = byId[id]
				if server then
					server.region = cityInfo.city
					server.regionRank = cityInfo.rank
					server.latency = cityInfo.latency
					server.latencyEstimated = true
					matches[#matches + 1] = server
				end
			end
			if #matches > 0 then
				self:sortCandidates(matches, mode)
				return matches[1]
			end
			Wait(self.latency.cfg.requestDelay)
		end
	end

	self:sortCandidates(servers, mode)
	const fallback = servers[1]
	if fallback then
		fallback.latency = tonumber(fallback.ping) or 0
		fallback.latencyEstimated = false
	end
	return fallback, fallback and nil or "no joinable public servers"
end

NAStuff.srv.latencyText = function(self, server, fallbackLatency)
	server = type(server) == "table" and server or {}
	const value = tonumber(server.latency) or tonumber(fallbackLatency) or tonumber(server.ping) or 0
	local text = value > 0 and ((server.latencyEstimated == true and "~" or "")..tostring(math.floor(value)).." ms") or "unknown latency"
	const regionText = server.regionLabel or server.region
	if regionText and tostring(regionText) ~= "" then
		text ..= " | "..tostring(regionText)
	end
	return text
end

NAStuff.srv.enrichLatencyList = function(self, placeId, servers)
	const pid = tonumber(placeId) or tonumber(PlaceId)
	if type(servers) ~= "table" or #servers == 0 then return servers, false end
	const ids = {}
	const byId = {}
	for _, server in servers do
		if type(server) == "table" and server.id then
			const id = tostring(server.id)
			ids[#ids + 1] = id
			byId[id] = server
			server.region = nil
			server.regionLabel = nil
			server.regionRank = nil
			server.latency = nil
			server.latencyEstimated = false
		end
	end
	const detailMap = self:fetchDetails(pid, ids, false)
	const modelReady = self:refreshLatencyModel(false)
	local mapped = 0
	for id, detail in detailMap do
		const server = byId[id]
		if server and detail then
			for k, v in detail do server[k] = v end
			server.region = detail.city or detail.regionName or detail.country
			server.regionLabel = detail.regionLabel or server.region
			if modelReady and detail.city then
				server.regionRank = self.latency.model.cityRank[detail.city]
				server.latency = self.latency.model.cityPing[detail.city]
				server.latencyEstimated = tonumber(server.latency) ~= nil
			end
			mapped += 1
		end
	end
	if modelReady and mapped < #servers then
		for _, cityInfo in self.latency.model.cityOrder do
			const regionIds = self:regionIds(pid, cityInfo.city)
			for id in regionIds do
				const server = byId[id]
				if server and not server.region then
					server.region = cityInfo.city
					server.regionLabel = cityInfo.city
					server.regionRank = cityInfo.rank
					server.latency = cityInfo.latency
					server.latencyEstimated = true
				end
			end
			Wait(self.latency.cfg.requestDelay)
		end
	end
	for _, server in servers do
		if type(server) == "table" and not tonumber(server.latency) then
			const rawPing = tonumber(server.ping) or 0
			if rawPing > 0 then
				server.latency = rawPing
				server.latencyEstimated = false
			end
		end
	end
	return servers, modelReady
end

NAStuff.srv.scan = function(self, mode, placeId)
	const server, err = self:pickLatency(placeId or PlaceId, mode)
	if not server then
		return nil, nil, nil, nil, err
	end
	return server.id, server.playing, tonumber(server.latency) or tonumber(server.ping), server, nil
end

NAmanage.ServerhopDefault = function()
	DebugNotif("Teleporting with the legacy serverhop method")
	local ok, err = NAmanage.TeleportServiceCall("Teleport", { PlaceId, Services.Players.LocalPlayer }, {
		placeId = PlaceId;
		placeName = game.Name;
		action = "SERVER HOP";
		detail = "Legacy Roblox serverhop";
	})
	if not ok then
		DebugNotif("Teleport failed: "..tostring(err or "?"))
		return false, err
	end
	return true
end

NAmanage.ServerhopLegacyPick = function(mode)
	if type(NAStuff.srv) ~= "table" or type(NAStuff.srv.collect) ~= "function" then
		return nil, "legacy server list is unavailable"
	end
	mode = mode == "low" and "low" or mode == "high" and "high" or "ping"
	local pageLimit = 4
	if type(NAStuff.srv.latency) == "table" and type(NAStuff.srv.latency.cfg) == "table" then
		pageLimit = tonumber(NAStuff.srv.latency.cfg.publicPageLimit) or pageLimit
	end
	local servers = NAStuff.srv:collect(PlaceId, mode, pageLimit)
	if type(servers) ~= "table" or #servers == 0 then
		return nil, "no joinable public servers"
	end
	if type(NAStuff.srv.sortCandidates) == "function" then
		NAStuff.srv:sortCandidates(servers, mode)
	else
		table.sort(servers, function(a, b)
			if mode == "low" and a.playing ~= b.playing then return a.playing < b.playing end
			if mode == "high" and a.playing ~= b.playing then return a.playing > b.playing end
			const ap, bp = tonumber(a.ping) or math.huge, tonumber(b.ping) or math.huge
			if ap ~= bp then return ap < bp end
			return tostring(a.id) < tostring(b.id)
		end)
	end
	const server = servers[1]
	if server then
		server.latency = tonumber(server.ping) or 0
		server.latencyEstimated = false
	end
	return server
end

NAmanage.ServerhopLegacyServer = function(mode, action, label)
	DebugNotif("Searching with the legacy Roblox server list")
	local server, scanErr = NAmanage.ServerhopLegacyPick(mode)
	if not server or not server.id then
		DebugNotif("No server found"..(scanErr and (": "..tostring(scanErr)) or ""))
		return false, scanErr or "no server found"
	end
	const ping = tonumber(server.ping) or 0
	const pingText = ping > 0 and (tostring(math.floor(ping)).." ms") or "unknown ping"
	DebugNotif(tostring(label or "Serverhop").." | "..pingText.." | Players: "..tostring(server.playing or "?"))
	return NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { PlaceId, server.id, Services.Players.LocalPlayer }, {
		placeId = PlaceId;
		placeName = game.Name;
		action = tostring(action or "SERVER HOP");
		detail = "Legacy Roblox data | Ping: "..pingText.." | Players: "..tostring(server.playing or "?");
	})
end

NAmanage.ServerhopAdvanced = function()
	DebugNotif("Searching with RoValra for the best-latency server")
	if type(NAStuff.srv) ~= "table" or type(NAStuff.srv.scan) ~= "function" then
		DebugNotif("RoValra serverhop is unavailable")
		return false, "RoValra serverhop is unavailable"
	end

	local id, pl, latency, server, scanErr = NAStuff.srv:scan("high")
	if not id then
		DebugNotif("No server found"..(scanErr and (": "..tostring(scanErr)) or ""))
		return false, scanErr or "no server found"
	end

	const latencyText = NAStuff.srv:latencyText(server, latency)
	DebugNotif("serverhopping | "..latencyText.." | Player Count: "..tostring(pl or "?"))
	local ok, err = NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { PlaceId, id, Services.Players.LocalPlayer }, {
		placeId = PlaceId;
		placeName = game.Name;
		action = "SERVER HOP";
		detail = "RoValra | Latency: "..latencyText.." | Players: "..tostring(pl or "?");
	})
	if not ok then
		DebugNotif("Teleport failed: "..tostring(err or "?"))
		return false, err
	end
	return true, id, pl, latency, server
end

NAmanage.SmallServerhopLegacy = function()
	return NAmanage.ServerhopLegacyServer("low", "SMALL SERVER HOP", "Legacy small server")
end

NAmanage.SmallServerhopRoValra = function()
	DebugNotif("Searching with RoValra for a small server in the best-latency region")
	local id, pl, latency, server, scanErr = NAStuff.srv:scan("low")
	if not id then
		DebugNotif("No server found"..(scanErr and (": "..tostring(scanErr)) or ""))
		return false, scanErr or "no server found"
	end
	const latencyText = NAStuff.srv:latencyText(server, latency)
	DebugNotif("serverhopping | "..latencyText.." | Player Count: "..tostring(pl or "?"))
	return NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { PlaceId, id, Services.Players.LocalPlayer }, {
		placeId = PlaceId;
		placeName = game.Name;
		action = "SMALL SERVER HOP";
		detail = "RoValra | Latency: "..latencyText.." | Players: "..tostring(pl or "?");
	})
end

NAmanage.PingServerhopLegacy = function()
	return NAmanage.ServerhopLegacyServer("ping", "PING SERVER HOP", "Legacy best Roblox ping")
end

NAmanage.PingServerhopRoValra = function()
	DebugNotif("Searching with RoValra for the best estimated-latency server")
	local id, pl, latency, server, scanErr = NAStuff.srv:scan("ping")
	if not id then
		DebugNotif("No server with latency data found"..(scanErr and (": "..tostring(scanErr)) or ""))
		return false, scanErr or "no server found"
	end
	const latencyText = NAStuff.srv:latencyText(server, latency)
	DebugNotif(Format("Serverhopping | %s | Players: %s", latencyText, tostring(pl or "?")))
	return NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { PlaceId, id, Services.Players.LocalPlayer }, {
		placeId = PlaceId;
		placeName = game.Name;
		action = "PING SERVER HOP";
		detail = "RoValra | Latency: "..latencyText.." | Players: "..tostring(pl or "?");
	})
end

NAmanage.ServerhopMethodPicker = function(title, description, legacyCallback, rovalraCallback)
	const show = Window or DoWindow
	if type(show) == "function" then
		show({
			Title = tostring(title or "Serverhop"),
			Description = tostring(description or "Choose how servers are selected.").." Legacy uses Roblox server data directly. RoValra resolves region and latency data in the background and can take a little longer.",
			Buttons = {
				{ Text = "Legacy", Callback = legacyCallback },
				{ Text = "RoValra", Callback = rovalraCallback },
			},
		})
		return true
	end
	return rovalraCallback()
end

NAmanage.ServerhopResolveMethod = function(method, title, description, legacyCallback, rovalraCallback, usage)
	const normalizedMethod = Lower(tostring(method or "")):gsub("[%s_%-%+]+", "")
	if normalizedMethod == "legacy" or normalizedMethod == "old" or normalizedMethod == "default" then
		return legacyCallback()
	end
	if normalizedMethod == "rovalra" or normalizedMethod == "advanced" or normalizedMethod == "high" then
		return rovalraCallback()
	end
	if normalizedMethod ~= "" then
		DoNotif(tostring(usage or "Usage: serverhop [legacy/rovalra]"), 4, "Serverhop")
		return false
	end
	return NAmanage.ServerhopMethodPicker(title, description, legacyCallback, rovalraCallback)
end

cmd.add({"serverhop","shop"},{"serverhop [default/advanced] (shop)","serverhop using Roblox's default handling or NA's advanced RoValra method"},function(method)
	Wait()
	const normalizedMethod = Lower(tostring(method or "")):gsub("[%s_%-%+]+", "")
	if normalizedMethod == "default" or normalizedMethod == "legacy" or normalizedMethod == "old" then
		return NAmanage.ServerhopDefault()
	end
	if normalizedMethod == "advanced" or normalizedMethod == "rovalra" or normalizedMethod == "high" then
		return NAmanage.ServerhopAdvanced()
	end
	if normalizedMethod ~= "" then
		DoNotif("Usage: serverhop [default/advanced]", 4, "Serverhop")
		return false
	end
	const show = Window or DoWindow
	if type(show) == "function" then
		show({
			Title = "Serverhop",
			Description = "Choose the original serverhop method. Default lets Roblox handle the teleport/server selection and may return you to the same server. Advanced uses RoValra-assisted server selection.",
			Buttons = {
				{ Text = "Default", Callback = NAmanage.ServerhopDefault },
				{ Text = "Advanced", Callback = NAmanage.ServerhopAdvanced },
			},
		})
		return true
	end
	return NAmanage.ServerhopAdvanced()
end)

cmd.add({"smallserverhop","sshop"},{"smallserverhop [legacy/rovalra] (sshop)","serverhop to a small server using Roblox data or RoValra"},function(method)
	Wait()
	return NAmanage.ServerhopResolveMethod(method, "Small Serverhop", "Legacy chooses the smallest server from Roblox's public server data. RoValra chooses a small server inside the best-latency region.", NAmanage.SmallServerhopLegacy, NAmanage.SmallServerhopRoValra, "Usage: smallserverhop [legacy/rovalra]")
end)

cmd.add({"pingserverhop","pshop"},{"pingserverhop [legacy/rovalra] (pshop)","serverhop by Roblox-reported ping or RoValra estimated latency"},function(method)
	Wait()
	return NAmanage.ServerhopResolveMethod(method, "Ping Serverhop", "Legacy sorts by Roblox's reported server ping. RoValra estimates the best region and latency before choosing.", NAmanage.PingServerhopLegacy, NAmanage.PingServerhopRoValra, "Usage: pingserverhop [legacy/rovalra]")
end)

NAmanage.RoValraHopServer = function(server, action, detailPrefix)
	if type(server) ~= "table" or not server.id then return false, "no server found" end
	const latencyText = type(NAStuff.srv.latencyText) == "function" and NAStuff.srv:latencyText(server) or "unknown latency"
	local detail = tostring(detailPrefix or action or "Server hop").." | "..latencyText
	if server.placeVersion then detail ..= " | Version: "..tostring(server.placeVersion) end
	if server.uptime then detail ..= " | Uptime: "..NAStuff.srv:formatUptime(server.uptime, true) end
	return NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { PlaceId, server.id, Services.Players.LocalPlayer }, {
		placeId = PlaceId;
		placeName = game.Name;
		action = tostring(action or "SERVER HOP");
		detail = detail;
	})
end

cmd.add({"oldserverhop","oldhop"},{"oldserverhop (oldhop)","serverhop to one of the oldest active servers"},function()
	Wait()
	DebugNotif("Searching for an old active server")
	local server, err = NAStuff.srv:pickUptime(PlaceId, "oldest")
	if not server then DebugNotif("No old server found: "..tostring(err or "unknown")) return end
	NAmanage.RoValraHopServer(server, "OLDEST SERVER HOP", "Oldest active server")
end)

cmd.add({"newserverhop","newhop"},{"newserverhop (newhop)","serverhop to one of the newest active servers"},function()
	Wait()
	DebugNotif("Searching for a new active server")
	local server, err = NAStuff.srv:pickUptime(PlaceId, "newest")
	if not server then DebugNotif("No new server found: "..tostring(err or "unknown")) return end
	NAmanage.RoValraHopServer(server, "NEWEST SERVER HOP", "Newest active server")
end)

cmd.add({"versionhop","vhop"},{"versionhop <version> (vhop)","serverhop to a server running a specific active place version"},function(version)
	const ver = tonumber(version)
	if not ver then DoNotif("Usage: versionhop <version>", 4, "Serverhop") return end
	Wait()
	local server, err = NAStuff.srv:pickVersion(PlaceId, ver)
	if not server then DebugNotif("No server found for version "..tostring(ver)..": "..tostring(err or "unknown")) return end
	NAmanage.RoValraHopServer(server, "VERSION SERVER HOP", "Place version "..tostring(math.floor(ver)))
end)

cmd.add({"oldversionhop","ovhop"},{"oldversionhop (ovhop)","serverhop to the oldest currently active place version"},function()
	Wait()
	local server, err, version = NAStuff.srv:pickOldestVersion(PlaceId)
	if not server then DebugNotif("No old-version server found: "..tostring(err or "unknown")) return end
	NAmanage.RoValraHopServer(server, "OLD VERSION SERVER HOP", "Oldest active version "..tostring(version or server.placeVersion or "?"))
end)

cmd.add({"regionhop","rhop"},{"regionhop <region/city> (rhop)","serverhop to a public server in a requested RoValra region"},function(...)
	const query = Concat({...}, " "):match("^%s*(.-)%s*$") or ""
	if query == "" then DoNotif("Usage: regionhop <region/city>", 4, "Serverhop") return end
	Wait()
	local server, err, resolved = NAStuff.srv:pickRegion(PlaceId, query)
	if not server then DebugNotif("No server found for region "..query..": "..tostring(err or "unknown")) return end
	NAmanage.RoValraHopServer(server, "REGION SERVER HOP", "Region: "..tostring((resolved and resolved.city) or query))
end)

cmd.add({"autorejoin", "autorj"}, {"autorejoin (autorj)", "Rejoins the server if you get kicked / disconnected"}, function()
	NAlib.disconnect("autorejoin")

	const triggerCooldown = 2
	local lastTriggerAt = 0
	local inFlight = false
	const watchedPromptLabels = {}

	const function getAutoRejoinPromptLabels()
		const promptGui = Services.CoreGui and Services.CoreGui:FindFirstChild("RobloxPromptGui")
		const promptOverlay = promptGui and promptGui:FindFirstChild("promptOverlay")
		const errorPrompt = promptOverlay and promptOverlay:FindFirstChild("ErrorPrompt")
		const titleFrame = errorPrompt and errorPrompt:FindFirstChild("TitleFrame")
		const messageArea = errorPrompt and errorPrompt:FindFirstChild("MessageArea")
		const errorFrame = messageArea and messageArea:FindFirstChild("ErrorFrame")
		const titleLabel = titleFrame and titleFrame:FindFirstChild("ErrorTitle")
		const descriptionLabel = errorFrame and errorFrame:FindFirstChild("ErrorMessage")
		return titleLabel, descriptionLabel
	end

	const function shouldTriggerFromMessage(message)
		local titleLabel, descriptionLabel = getAutoRejoinPromptLabels()
		const titleText = Lower(titleLabel and tostring(titleLabel.Text or "") or "")
		const descriptionText = Lower(descriptionLabel and tostring(descriptionLabel.Text or "") or "")
		const messageText = Lower(tostring(message or ""))
		const autoRejoinErrorCodes = {
			["264"] = true,
			["267"] = true,
			["268"] = true,
			["273"] = true,
			["277"] = true,
			["279"] = true,
		}
		const text = Concat({messageText, titleText, descriptionText}, "\n")
		if text:gsub("%s+", "") == "" then
			return false
		end
		if titleText == "disconnected" then
			const promptErrorCode = descriptionText:match("error code:%s*(%d+)")
			if promptErrorCode and autoRejoinErrorCodes[promptErrorCode] then
				return true
			end
		end
		return false
	end

	const function handleRejoin(message)
		if inFlight then
			return
		end
		if not shouldTriggerFromMessage(message) then
			return
		end
		const now = tick()
		if (now - lastTriggerAt) < triggerCooldown then
			return
		end

		lastTriggerAt = now
		inFlight = true
		Spawn(function()
			const ok = pcall(function()
				cmd.run({"rejoin"})
			end)
			if not ok then
				NAmanage.TeleportServiceCall("Teleport", { PlaceId, Services.Players.LocalPlayer }, {
					placeId = PlaceId;
					placeName = game.Name;
					action = "AUTO REJOIN";
					detail = "Recovering from disconnect";
				})
			end
			Wait(1.5)
			inFlight = false
		end)
	end

	const function watchPromptLabel(label)
		if not label or watchedPromptLabels[label] then
			return
		end
		if not label:IsA("TextLabel") then
			return
		end
		watchedPromptLabels[label] = true
		NAlib.connect("autorejoin", label:GetPropertyChangedSignal("Text"):Connect(function()
			handleRejoin(label.Text)
		end))
	end

	const function bindPromptWatchers()
		local titleLabel, descriptionLabel = getAutoRejoinPromptLabels()
		watchPromptLabel(titleLabel)
		watchPromptLabel(descriptionLabel)
		if titleLabel or descriptionLabel then
			handleRejoin(Concat({
				titleLabel and tostring(titleLabel.Text or "") or "",
				descriptionLabel and tostring(descriptionLabel.Text or "") or ""
			}, "\n"))
		end
	end

	NAlib.connect("autorejoin", Services.GuiService.ErrorMessageChanged:Connect(function(message)
		handleRejoin(message)
	end))
	NAlib.connect("autorejoin", NAmanage.descSub(Services.CoreGui, {
		added = function(descendant)
			if descendant.Name == "RobloxPromptGui"
				or descendant.Name == "promptOverlay"
				or descendant.Name == "ErrorPrompt"
				or descendant.Name == "ErrorTitle"
				or descendant.Name == "ErrorMessage"
			then
				bindPromptWatchers()
				if descendant:IsA("TextLabel") then
					handleRejoin(descendant.Text)
				end
			end
		end,
		removing = function(descendant)
			watchedPromptLabels[descendant] = nil
		end,
		filterAdded = function(descendant)
			return descendant and (
				descendant.Name == "RobloxPromptGui"
				or descendant.Name == "promptOverlay"
				or descendant.Name == "ErrorPrompt"
				or descendant.Name == "ErrorTitle"
				or descendant.Name == "ErrorMessage"
			)
		end,
		filterRemoving = function(descendant)
			return watchedPromptLabels[descendant] == true
		end,
		classAdded = { "ScreenGui", "Frame", "TextLabel" },
		classRemoving = "TextLabel",
	}))
	bindPromptWatchers()

	DebugNotif("Auto Rejoin is now enabled!")
end)

cmd.add({"unautorejoin", "unautorj"}, {"unautorejoin (unautorj)", "Disables auto rejoin command"}, function()
	if NAlib.isConnected("autorejoin") then
		NAlib.disconnect("autorejoin")
		DebugNotif("Auto Rejoin is now disabled!")
	else
		DebugNotif("Auto Rejoin is already disabled!")
	end
end)

cmd.add({"functionspy"},{"functionspy","Check console"},function()
	const toLog={
		debug.getconstants;
		getconstants;
		debug.getconstant;
		getconstant;
		debug.setconstant;
		setconstant;
		debug.getupvalues;
		debug.getupvalue;
		getupvalues;
		getupvalue;
		debug.setupvalue;
		setupvalue;
		getsenv;
		getreg;
		getgc;
		getconnections;
		firesignal;
		fireclickdetector;
		fireproximityprompt;
		firetouchinterest;
		gethiddenproperty;
		sethiddenproperty;
		hookmetamethod;
		setnamecallmethod;
		getrawmetatable;
		setrawmetatable;
		setreadonly;
		isreadonly;
		debug.setmetatable;
	}

	const FunctionSpy=InstanceNew("ScreenGui")
	const Main=InstanceNew("Frame")
	const LeftPanel=InstanceNew("ScrollingFrame")
	const UIListLayout=InstanceNew("UIListLayout")
	const example=InstanceNew("TextButton")
	const name=InstanceNew("TextLabel")
	const UIPadding=InstanceNew("UIPadding")
	const FakeTitle=InstanceNew("TextButton")
	const Title=InstanceNew("TextLabel")
	const clear=InstanceNew("ImageButton")
	const RightPanel=InstanceNew("ScrollingFrame")
	const output=InstanceNew("TextLabel")
	const clear_2=InstanceNew("TextButton")
	const copy=InstanceNew("TextButton")

	NAgui.NaProtectUI(FunctionSpy)
	FunctionSpy.Name="FunctionSpy"
	FunctionSpy.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

	Main.Name="Main"
	Main.Parent=FunctionSpy
	Main.BackgroundColor3=Color3.fromRGB(33,33,33)
	Main.BorderSizePixel=0
	Main.Position=UDim2.new(0,10,0,36)
	Main.Size=UDim2.new(0,536,0,328)

	LeftPanel.Name="LeftPanel"
	LeftPanel.Parent=Main
	LeftPanel.Active=true
	LeftPanel.BackgroundColor3=Color3.fromRGB(45,45,45)
	LeftPanel.BorderSizePixel=0
	LeftPanel.Size=UDim2.new(0.349999994,0,1,0)
	LeftPanel.CanvasSize=UDim2.new(0,0,0,0)
	LeftPanel.HorizontalScrollBarInset=Enum.ScrollBarInset.ScrollBar
	LeftPanel.ScrollBarThickness=3

	UIListLayout.Parent=LeftPanel
	UIListLayout.SortOrder=Enum.SortOrder.LayoutOrder
	UIListLayout.Padding=UDim.new(0,7)

	example.Name="example"
	example.Parent=LeftPanel
	example.BackgroundColor3=Color3.fromRGB(31,31,31)
	example.BorderSizePixel=0
	example.Position=UDim2.new(4.39481269e-08,0,0,0)
	example.Size=UDim2.new(0,163,0,19)
	example.Visible=false
	example.Font=Enum.Font.SourceSans
	example.Text=""
	example.TextColor3=Color3.fromRGB(0,0,0)
	example.TextSize=14.000
	example.TextXAlignment=Enum.TextXAlignment.Left

	name.Name="name"
	name.Parent=example
	name.BackgroundColor3=Color3.fromRGB(255,255,255)
	name.BackgroundTransparency=1.000
	name.BorderSizePixel=0
	name.Position=UDim2.new(0,10,0,0)
	name.Size=UDim2.new(1,-10,1,0)
	name.Font=Enum.Font.SourceSans
	name.TextColor3=Color3.fromRGB(255,255,255)
	name.TextSize=14.000
	name.TextXAlignment=Enum.TextXAlignment.Left

	UIPadding.Parent=LeftPanel
	UIPadding.PaddingBottom=UDim.new(0,7)
	UIPadding.PaddingLeft=UDim.new(0,7)
	UIPadding.PaddingRight=UDim.new(0,7)
	UIPadding.PaddingTop=UDim.new(0,7)

	FakeTitle.Name="FakeTitle"
	FakeTitle.Parent=Main
	FakeTitle.BackgroundColor3=Color3.fromRGB(40,40,40)
	FakeTitle.BorderSizePixel=0
	FakeTitle.Position=UDim2.new(0,225,0,-26)
	FakeTitle.Size=UDim2.new(0.166044772,0,0,26)
	FakeTitle.Font=Enum.Font.GothamMedium
	FakeTitle.Text="FunctionSpy"
	FakeTitle.TextColor3=Color3.fromRGB(255,255,255)
	FakeTitle.TextSize=14.000

	Title.Name="Title"
	Title.Parent=Main
	Title.BackgroundColor3=Color3.fromRGB(40,40,40)
	Title.BorderSizePixel=0
	Title.Position=UDim2.new(0,0,0,-26)
	Title.Size=UDim2.new(1,0,0,26)
	Title.Font=Enum.Font.GothamMedium
	Title.Text="FunctionSpy"
	Title.TextColor3=Color3.fromRGB(255,255,255)
	Title.TextSize=14.000
	Title.TextWrapped=true

	clear.Name="clear"
	clear.Parent=Title
	clear.BackgroundTransparency=1.000
	clear.Position=UDim2.new(1,-28,0,2)
	clear.Size=UDim2.new(0,24,0,24)
	clear.ZIndex=2
	clear.Image=NAmanage.getNAImageAsset("Sheet", "rbxassetid://3926305904")
	clear.ImageRectOffset=Vector2.new(924,724)
	clear.ImageRectSize=Vector2.new(36,36)

	RightPanel.Name="RightPanel"
	RightPanel.Parent=Main
	RightPanel.Active=true
	RightPanel.BackgroundColor3=Color3.fromRGB(35,35,35)
	RightPanel.BorderSizePixel=0
	RightPanel.Position=UDim2.new(0.349999994,0,0,0)
	RightPanel.Size=UDim2.new(0.649999976,0,1,0)
	RightPanel.CanvasSize=UDim2.new(0,0,0,0)
	RightPanel.HorizontalScrollBarInset=Enum.ScrollBarInset.ScrollBar
	RightPanel.ScrollBarThickness=3

	output.Name="output"
	output.Parent=RightPanel
	output.BackgroundColor3=Color3.fromRGB(255,255,255)
	output.BackgroundTransparency=1.000
	output.BorderColor3=Color3.fromRGB(27,42,53)
	output.BorderSizePixel=0
	output.Position=UDim2.new(0,10,0,10)
	output.Size=UDim2.new(1,-10,0.75,-10)
	output.Font=Enum.Font.GothamMedium
	output.Text=""
	output.TextColor3=Color3.fromRGB(255,255,255)
	output.TextSize=14.000
	output.TextXAlignment=Enum.TextXAlignment.Left
	output.TextYAlignment=Enum.TextYAlignment.Top

	clear_2.Name="clear"
	clear_2.Parent=RightPanel
	clear_2.BackgroundColor3=Color3.fromRGB(30,30,30)
	clear_2.BorderSizePixel=0
	clear_2.Position=UDim2.new(0.0631457642,0,0.826219559,0)
	clear_2.Size=UDim2.new(0,140,0,33)
	clear_2.Font=Enum.Font.SourceSans
	clear_2.Text="Clear logs"
	clear_2.TextColor3=Color3.fromRGB(255,255,255)
	clear_2.TextSize=14.000

	copy.Name="copy"
	copy.Parent=RightPanel
	copy.BackgroundColor3=Color3.fromRGB(30,30,30)
	copy.BorderSizePixel=0
	copy.Position=UDim2.new(0.545350134,0,0.826219559,0)
	copy.Size=UDim2.new(0,140,0,33)
	copy.Font=Enum.Font.SourceSans
	copy.Text="Copy info"
	copy.TextColor3=Color3.fromRGB(255,255,255)
	copy.TextSize=14.000

	--Scripts:

	function AKIHDI_fake_script()
		_na_env.functionspy={
			instance=Main.Parent;
			logging=true;
			connections={};
		}

		_na_env.functionspy.shutdown=function()
			for i,v in _na_env.functionspy.connections do
				v:Disconnect()
			end
			_na_env.functionspy.connections={}
			_na_env.functionspy=nil
			Main.Parent:Destroy()
		end

		const connections={}

		local currentInfo=nil

		function log(name,text)
			const btn=Main.LeftPanel.example:Clone()
			btn.Parent=Main.LeftPanel
			btn.Name=name
			btn.name.Text=name
			btn.Visible=true
			Insert(connections, MouseButtonFix(btn, function()
				Main.RightPanel.output.Text=text
				currentInfo=text
			end))
		end

		MouseButtonFix(Main.RightPanel.copy, function()
			if currentInfo~=nil then
				setclipboard(tostring(currentInfo))
			end
		end)

		MouseButtonFix(Main.RightPanel.clear, function()
			for i,v in connections do
				v:Disconnect()
			end
			for i,v in NAmanage.QueryDescendants(Main.LeftPanel, "TextButton") do
				if v.Visible==true then
					v:Destroy()
				end
			end
			Main.RightPanel.output.Text=""
			currentInfo=nil
		end)

		const hooked={}
		const Seralize=loadstring(NAmanage.HttpGetOrError('https://api.irisapp.ca/Scripts/SeralizeTable.lua',{noCache=true,timeout=10}))()
		for i,v in next,toLog do
			if type(v)=="string" then
				local suc,err=NACaller(function()
					const func=loadstring("return "..v)()
					hooked[i]=hookfunction(func,function(...)
						const args={...}
						if _na_env.functionspy then
							NACaller(function()
								out=""
								out=out..(v..",Args-> {")..("\n"):format()
								for l,k in args do
									if type(k)=="function" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Name-> "..getinfo(k).name)..("\n"):format()
									elseif type(k)=="table" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Data-> "..Seralize(k))..("\n"):format()
									elseif type(k)=="boolean" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k).."-> "..type(k))..("\n"):format()
									elseif type(k)=="nil" then
										out=out..("    ["..tostring(l).."] null")..("\n"):format()
									elseif type(k)=="number" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									else
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									end
								end
								out=out..("},Result-> "..tostring(nil))..("\n"):format()
								if _na_env.functionspy.logging==true then
									log(v,out)
								end
							end)
						end
						return hooked[i](...)
					end)
				end)
				if not suc then
					warn("Something went wrong while hooking "..v..". Error: "..err)
				end
			elseif type(v)=="function" then
				local suc,err=NACaller(function()
					hooked[i]=hookfunction(v,function(...)
						const args={...}
						if _na_env.functionspy then
							NACaller(function()
								out=""
								out=out..(getinfo(v).name..",Args-> {")..("\n"):format()
								for l,k in args do
									if type(k)=="function" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Name-> "..getinfo(k).name)..("\n"):format()
									elseif type(k)=="table" then
										out=out..("    ["..tostring(l).."] "..tostring(k)..",Type-> "..type(k)..",Data-> "..Seralize(k))..("\n"):format()
									elseif type(k)=="boolean" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k).."-> "..type(k))..("\n"):format()
									elseif type(k)=="nil" then
										out=out..("    ["..tostring(l).."] null")..("\n"):format()
									elseif type(k)=="number" then
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									else
										out=out..("    ["..tostring(l).."] Value-> "..tostring(k)..",Type-> "..type(k))..("\n"):format()
									end
								end
								out=out..("},Result-> "..tostring(nil))..("\n"):format()
								if _na_env.functionspy.logging==true then
									log(getinfo(v).name,out)
								end
							end)
						end
						return hooked[i](...)
					end)
				end)
				if not suc then
					warn("Something went wrong while hooking "..getinfo(v).name..". Error: "..err)
				end
			end
		end

	end
	NAmanage.Wrap(AKIHDI_fake_script)()
	function KVVJTK_fake_script()
		const UIS=Services.UserInputService
		const frame=FakeTitle.Parent
		local dragToggle=nil
		const dragSpeed=0.25
		local dragStart=nil
		local startPos=nil

		function updateInput(input)
			const delta=input.Position-dragStart
			const position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
				startPos.Y.Scale,startPos.Y.Offset+delta.Y)
			__lt.cm("TweenService", "Create", frame,TweenInfo.new(dragSpeed),{Position=position}):Play()
		end

		Insert(_na_env.functionspy.connections,frame.Title.InputBegan:Connect(function(input)
			if (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
				dragToggle=true
				dragStart=input.Position
				startPos=frame.Position
				input.Changed:Connect(function()
					if input.UserInputState==Enum.UserInputState.End then
						dragToggle=false
					end
				end)
			end
		end))

		Insert(_na_env.functionspy.connections,UIS.InputChanged:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
				if dragToggle then
					updateInput(input)
				end
			end
		end))

	end
	NAmanage.Wrap(KVVJTK_fake_script)()
	function BIPVKVC_fake_script()
		const script=InstanceNew('LocalScript',FakeTitle)

		Insert(_na_env.functionspy.connections,FakeTitle.MouseEnter:Connect(function()
			if _na_env.functionspy.logging==true then
				__lt.cm("TweenService", "Create", FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif _na_env.functionspy.logging==false then
				__lt.cm("TweenService", "Create", FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(_na_env.functionspy.connections,FakeTitle.MouseMoved:Connect(function()
			if _na_env.functionspy.logging==true then
				__lt.cm("TweenService", "Create", FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif _na_env.functionspy.logging==false then
				__lt.cm("TweenService", "Create", FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(_na_env.functionspy.connections, MouseButtonFix(FakeTitle, function()
			_na_env.functionspy.logging=not _na_env.functionspy.logging
			if _na_env.functionspy.logging==true then
				__lt.cm("TweenService", "Create", FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(0,1,0)}):Play()
			elseif _na_env.functionspy.logging==false then
				__lt.cm("TweenService", "Create", FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,0,0)}):Play()
			end
		end))

		Insert(_na_env.functionspy.connections,FakeTitle.MouseLeave:Connect(function()
			__lt.cm("TweenService", "Create", FakeTitle.Parent.Title,TweenInfo.new(0.3),{TextColor3=Color3.new(1,1,1)}):Play()
		end))
	end
	NAmanage.Wrap(BIPVKVC_fake_script)()
	function PRML_fake_script()
		MouseButtonFix(clear, function()
			_na_env.functionspy.shutdown()
		end)
	end
	NAmanage.Wrap(PRML_fake_script)()
end)

cmd.add({"fly"},{"fly [speed]","Enable flight"},function(...)
	const arg=(...) or nil
	flyVariables.flySpeed=tonumber(arg) or flyVariables.flySpeed or 1
	NAmanage.connectFlyKey()
	NAmanage.activateFlightModeFromCommand("fly")
	if not IsOnMobile then
		Wait()
		DebugNotif("Fly enabled. Press '"..string.upper(flyVariables.toggleKey).."' to fly/unfly.")
	end
end,true)

cmd.add({"unfly"},{"unfly","Disable flight"},function()
	NAmanage.deactivateMode("fly")
end)

cmd.add({"cframefly","cfly"},{"cframefly [speed] (cfly)","Enable CFrame-based flight with respawn-safe cleanup"},function(...)
	const arg=(...) or nil
	flyVariables.cFlySpeed=tonumber(arg) or flyVariables.cFlySpeed or 1
	flyVariables.flySpeed=flyVariables.cFlySpeed
	NAmanage.connectCFlyKey()
	NAmanage.activateFlightModeFromCommand("cfly")
	if not IsOnMobile then
		Wait()
		DebugNotif("CFrame Fly enabled. Press '"..string.upper(flyVariables.cToggleKey).."' to cfly/uncfly.")
	end
end,true)

cmd.add({"uncframefly","uncfly"},{"uncfly","Disable CFrame-based flight"},function()
	NAmanage.deactivateMode("cfly")
end)

cmd.add({"tfly","tweenfly"},{"tfly [speed] (tweenfly)","Enables smooth flying"},function(...)
	const arg=(...) or nil
	flyVariables.TflySpeed=tonumber(arg) or flyVariables.TflySpeed or 1
	NAmanage.connectTFlyKey()
	NAmanage.activateFlightModeFromCommand("tfly")
	if not IsOnMobile then
		Wait()
		DebugNotif("TFly enabled. Press '"..string.upper(flyVariables.tflyToggleKey).."' to tfly/untfly.")
	end
end,true)

cmd.add({"untfly","untweenfly"},{"untfly","Disables tween flying"},function()
	NAmanage.deactivateMode("tfly")
end)

-- idk what i am doing lol (bored af :P)

cmd.add({"noclip","nclip","nc"},{"noclip","Disable your player's collision"},function()
	NAStuff._ncClip = false
	if NAlib.isConnected("noclip") then
		return
	end

	NAStuff._ncColl = setmetatable({}, { __mode = "k" })
	const col = NAStuff._ncColl
	Wait(0.1)

	const function step()
		const char = getChar()
		if NAStuff._ncClip == false and char ~= nil then
			for _, part in char:QueryDescendants("BasePart") do
				if col[part] == nil then
					col[part] = part.CanCollide
				end
				if part.CanCollide == true then
					part.CanCollide = false
				end
			end
		end
	end

	step()
	NAlib.connect("noclip", Services.RunService.PreSimulation:Connect(step))
end)

cmd.add({"clip","unnoclip","stopclip","unnclip","unnc"},{"clip","Enable your player's collision"},function()
	NAStuff._ncClip = true
	NAlib.disconnect("noclip")

	const col = NAStuff._ncColl
	if type(col) == "table" then
		for part, can in col do
			if typeof(part) == "Instance" and part.Parent and part:IsA("BasePart") then
				part.CanCollide = can == true
			end
			col[part] = nil
		end
	end

	NAStuff._ncColl = nil
end)

cmd.add({"antianchor","aa"},{"antianchor","Prevent your parts from being anchored"},function()
	NAlib.disconnect("antianchor")
	NAlib.disconnect("antianchor_char")
	NAStuff._aaTracked = NAStuff._aaTracked or {}
	NAStuff._aaOrig = NAStuff._aaOrig or {}
	NAStuff._aaSignals = NAStuff._aaSignals or {}
	const tracked, orig, signals = NAStuff._aaTracked, NAStuff._aaOrig, NAStuff._aaSignals
	const lp = Services.Players.LocalPlayer
	const enforce = function(p)
		if not (p and p:IsA("BasePart")) then return end
		if orig[p] == nil then orig[p] = NAlib.isProperty(p,"Anchored") end
		tracked[p] = true
		if NAlib.isProperty(p,"Anchored") ~= false then NAlib.setProperty(p,"Anchored", false) end
		if not signals[p] then
			const c = p:GetPropertyChangedSignal("Anchored"):Connect(function()
				if NAlib.isProperty(p,"Anchored") ~= false then NAlib.setProperty(p,"Anchored", false) end
			end)
			signals[p] = c
			NAlib.connect("antianchor", c)
		end
	end
	const seed = function(char)
		if not char then return end
		for _,d in char:QueryDescendants("BasePart") do
			enforce(d)
		end
		NAlib.connect("antianchor", NAmanage.descAdd(char, function(inst)
			if inst:IsA("BasePart") then enforce(inst) end
		end, function(inst)
			return inst and inst:IsA("BasePart")
		end))
		NAlib.connect("antianchor", NAmanage.descRem(char, function(inst)
			if signals[inst] then signals[inst]:Disconnect(); signals[inst] = nil end
			tracked[inst] = nil
			orig[inst] = nil
		end, function(inst)
			return inst and inst:IsA("BasePart")
		end))
	end
	if lp.Character then seed(lp.Character) end
	NAlib.connect("antianchor_char", lp.CharacterAdded:Connect(function(char)
		for _,c in signals do if c then c:Disconnect() end end
		for k in signals do signals[k]=nil end
		for k in tracked do tracked[k]=nil end
		for k in orig do orig[k]=nil end
		Wait(); seed(char)
	end))
	NAlib.connect("antianchor_char", lp.CharacterRemoving:Connect(function()
		for _,c in signals do if c then c:Disconnect() end end
		for k in signals do signals[k]=nil end
		for k in tracked do tracked[k]=nil end
		for k in orig do orig[k]=nil end
	end))
	NAlib.connect("antianchor", Services.RunService.PreSimulation:Connect(function()
		const char = lp.Character
		if not char then return end
		for p in tracked do
			if typeof(p)=="Instance" and p:IsA("BasePart") and p:IsDescendantOf(char) then
				if p.Anchored ~= false then NAlib.setProperty(p,"Anchored", false) end
			end
		end
	end))
end)

cmd.add({"unantianchor","unaa"},{"unantianchor","Allow your parts to be anchored"},function()
	const tracked = NAStuff._aaTracked or {}
	const orig = NAStuff._aaOrig or {}
	const signals = NAStuff._aaSignals or {}
	NAlib.disconnect("antianchor")
	NAlib.disconnect("antianchor_char")
	for _,c in signals do if c then c:Disconnect() end end
	for p in tracked do
		if typeof(p)=="Instance" and p:IsA("BasePart") then
			local v = orig[p]; if v == nil then v = false end
			NAlib.setProperty(p,"Anchored", v)
		end
	end
	for k in signals do signals[k]=nil end
	for k in tracked do tracked[k]=nil end
	for k in orig do orig[k]=nil end
end)

originalPos = nil
platformPart = nil
activationTime = nil

cmd.addRestricted({"antibang"}, {"antibang", "prevents users to bang you (still WORK IN PROGRESS)"}, function()
	NAlib.disconnect("antibang_loop")

	local root = getRoot(LocalPlayer.Character)
	if not root then return end

	originalPos = root.CFrame
	const orgHeight = Services.Workspace.FallenPartsDestroyHeight
	const anims = {"rbxassetid://5918726674", "rbxassetid://148840371", "rbxassetid://698251653", "rbxassetid://72042024", "rbxassetid://189854234", "rbxassetid://106772613", "rbxassetid://10714360343", "rbxassetid://95383980"}
	local inVoid = false
	local targetPlayer = nil
	local toldNotif = false
	local activationTime = nil
	const backshotState = {}

	LocalPlayer.CharacterAdded:Connect(function(char)
		Wait(1)
		root = getRoot(char)
	end)

	const function startAntibang(player)
		if not player then
			return
		end

		inVoid = true
		activationTime = tick()
		targetPlayer = player
		Services.Workspace.FallenPartsDestroyHeight = 0/1/0

		if platformPart then
			platformPart:Destroy()
		end

		platformPart = InstanceNew("Part")
		platformPart.Size = Vector3.new(9999, 1, 9999)
		platformPart.Anchored = true
		platformPart.CanCollide = true
		platformPart.Transparency = 1
		platformPart.Position = Vector3.new(0, orgHeight - 30, 0)
		platformPart.Parent = Services.Workspace
		NAmanage.UG_setRootCFrame(root, CFrame.new(Vector3.new(0, orgHeight - 25, 0)))

		if not toldNotif then
			toldNotif = true
			DebugNotif("Antibang activated | Target: "..nameChecker(targetPlayer), 2)
		end
	end

	const function detectBackshot(player, back, deltaTime)
		const char = player.Character
		const ehrp = char and getRoot(char)
		const ehum = char and getHum(char)
		local data = backshotState[player]
		local ok = false
		local triggered = false
		const dt = deltaTime or 0

		if ehrp and ehum and root then
			const dist = (ehrp.Position - root.Position).Magnitude
			if dist < 10 then
				const dirToThem = (ehrp.Position - root.Position).Unit
				const backDot = back:Dot(dirToThem)
				if backDot > 0.5 then
					const toMe = (root.Position - ehrp.Position).Unit
					const faceDot = ehrp.CFrame.LookVector:Dot(toMe)
					if faceDot > 0.4 then
						const mv = ehum.MoveDirection
						if mv.Magnitude > 0.1 then
							ok = true
							const mvDot = mv.Unit:Dot(back)
							data = data or {lastSign = 0, flips = 0, t = 0}
							backshotState[player] = data

							local sign = 0
							if mvDot > 0.3 then
								sign = 1
							elseif mvDot < -0.3 then
								sign = -1
							end

							if sign ~= 0 and sign ~= data.lastSign then
								data.flips += 1
								data.lastSign = sign
							end

							data.t += dt
							if data.t >= 1 then
								if data.flips >= 3 then
									triggered = true
								end
								data.flips = 0
								data.t = 0
							end
						end
					end
				end
			end
		end

		if not ok and data then
			data.lastSign = 0
			data.flips = 0
			data.t = 0
		end

		return triggered
	end

	NAlib.connect("antibang_loop", Services.RunService.PreSimulation:Connect(function(_, dt)
		if not root then
			return
		end

		const back = -root.CFrame.LookVector

		for _, p in __lt.cm("Players", "GetPlayers") do
			if p ~= LocalPlayer then
				const char = p.Character
				const targetRoot = char and getRoot(char)
				if targetRoot then
					if not inVoid and detectBackshot(p, back, dt) then
						startAntibang(p)
					end

					if (targetRoot.Position - root.Position).Magnitude <= 10 then
						const humanoid = getPlrHum(p)
						if humanoid then
							const tracks = humanoid:GetPlayingAnimationTracks()
							for _, t in tracks do
								if Discover(anims, t.Animation.AnimationId) then
									if not inVoid then
										startAntibang(p)
									end
								end
							end
						end
					end
				end
			end
		end

		if inVoid then
			if (not targetPlayer or not targetPlayer.Character or not getPlrHum(targetPlayer) or getPlrHum(targetPlayer).Health <= 0)
				or (activationTime and tick() - activationTime >= 10) then
				inVoid = false
				targetPlayer = nil
				NAmanage.UG_setRootCFrame(root, originalPos)
				root.Anchored = true
				Wait()
				root.Anchored = false
				Services.Workspace.FallenPartsDestroyHeight = orgHeight
				if platformPart then
					platformPart:Destroy()
					platformPart = nil
				end
				if toldNotif then
					toldNotif = false
					if activationTime and tick() - activationTime >= 10 then
						DebugNotif("Antibang deactivated (timeout)", 2)
					else
						DebugNotif("Antibang deactivated", 2)
					end
				end
			end
		end
	end))

	DebugNotif("Antibang Enabled", 3)
end)

cmd.addRestricted({"unantibang"}, {"unantibang", "disables antibang"}, function()
	NAlib.disconnect("antibang_loop")
	if platformPart then
		platformPart:Destroy()
		platformPart = nil
	end
	DebugNotif("Antibang Disabled", 3)
end)

NAmanage.getOrbitSpeed=function(v)
	const n = tonumber(v)
	if not n then
		return 0.05
	end
	return math.clamp(n, 0.005, 1)
end

cmd.add({"orbit"}, {"orbit <player|npc:filter> <distance> [speed]", "Orbit around a player or NPC"}, function(p, d, s)
	NAlib.disconnect("orbit")
	const targets = getPlr(p)
	if #targets == 0 then return end
	const target = targets[1]
	const tchar = NAmanage.PlayerArgChar(target)
	const char = getChar()
	if not tchar or not char then return end
	const thrp = getRoot(tchar)
	const hrp = getRoot(char)
	if not thrp or not hrp then return end
	const dist = tonumber(d) or 4
	const spd = NAmanage.getOrbitSpeed(s)
	local sineX, sineZ = 0, math.pi / 2
	NAlib.connect("orbit", Services.RunService.PreSimulation:Connect(function(dt)
		if not (thrp.Parent and hrp.Parent) then
			NAlib.disconnect("orbit")
			return
		end
		const step = spd * math.clamp((tonumber(dt) or 1 / 60) * 60, 0.25, 2)
		sineX, sineZ = sineX + step, sineZ + step
		const sinX, sinZ = math.sin(sineX), math.sin(sineZ)
		hrp.Velocity = Vector3.zero
		const baseCF = NAmanage.UG_clientCFrame(hrp) or hrp.CFrame
		NAmanage.UG_setRootCFrame(hrp, CFrame.new(sinX * dist, 0, sinZ * dist) * (baseCF - baseCF.p) + thrp.CFrame.p)
	end))
end, true)

cmd.add({"uporbit"}, {"uporbit <player|npc:filter> <distance> [speed]", "Orbit around a player or NPC on the Y axis"}, function(p, d, s)
	NAlib.disconnect("orbit")
	const targets = getPlr(p)
	if #targets == 0 then return end
	const target = targets[1]
	const tchar = NAmanage.PlayerArgChar(target)
	const char = getChar()
	if not tchar or not char then return end
	const thrp = getRoot(tchar)
	const hrp = getRoot(char)
	if not thrp or not hrp then return end
	const dist = tonumber(d) or 4
	const spd = NAmanage.getOrbitSpeed(s)
	local sineX, sineY = 0, math.pi / 2
	NAlib.connect("orbit", Services.RunService.PreSimulation:Connect(function(dt)
		if not (thrp.Parent and hrp.Parent) then
			NAlib.disconnect("orbit")
			return
		end
		const step = spd * math.clamp((tonumber(dt) or 1 / 60) * 60, 0.25, 2)
		sineX, sineY = sineX + step, sineY + step
		const sinX, sinY = math.sin(sineX), math.sin(sineY)
		hrp.Velocity = Vector3.zero
		const baseCF = NAmanage.UG_clientCFrame(hrp) or hrp.CFrame
		NAmanage.UG_setRootCFrame(hrp, CFrame.new(sinX * dist, sinY * dist, 0) * (baseCF - baseCF.p) + thrp.CFrame.p)
	end))
end, true)

cmd.add({"unorbit"}, {"unorbit", "Stop orbiting"}, function()
	NAlib.disconnect("orbit")
end)

fcBTNTOGGLE = nil

NAmanage.StartFreecamAtCFrame=function(cframe)
	if typeof(cframe) ~= "CFrame" then
		return false
	end
	if NAFreecam and NAFreecam.IsEnabled() and NAFreecam.SetCFrame then
		return NAFreecam.SetCFrame(cframe)
	end
	if NAlib.isConnected("freecam") and typeof(NAStuff.FreecamLegacyPart) == "Instance" then
		NAStuff.FreecamLegacyPart.CFrame = cframe
		return true
	end
	NAStuff.FreecamStartCFrame = cframe
	cmd.run({"freecam"})
	return true
end

cmd.add({"freecam","fc","fcam"},{"freecam [speed] (fc,fcam)","Enable free camera"},function(...)
	argg = (...)
	const function normalizeLegacySpeed(value)
		const n = tonumber(value)
		if not n then
			return nil
		end
		return math.clamp(n, 0.05, 20)
	end

	const legacySpeed = normalizeLegacySpeed(argg) or normalizeLegacySpeed(NAStuff.FreecamSpeed) or 5
	const navSpeed = legacySpeed / 5
	local speed = legacySpeed
	local requestedStartCFrame = NAStuff.FreecamStartCFrame
	NAStuff.FreecamStartCFrame = nil
	const function takeStartCFrame()
		const cframe = requestedStartCFrame
		requestedStartCFrame = nil
		return cframe
	end
	NAStuff.FreecamSpeed = legacySpeed
	pcall(NAmanage.NASettingsSet, "freecamSpeed", legacySpeed)

	if NAFreecam and NAFreecam.IsEnabled() then
		if NAFreecam.SetSpeed then
			NAFreecam.SetSpeed(navSpeed)
		end
		if typeof(requestedStartCFrame) == "CFrame" and NAFreecam.SetCFrame then
			NAFreecam.SetCFrame(takeStartCFrame())
		end
		flyVariables.mOn = true
		if IsOnMobile and fcBTNTOGGLE then
			const btn = fcBTNTOGGLE:FindFirstChild("FreecamMainButton", true)
			const speedBox = fcBTNTOGGLE:FindFirstChild("FreecamSpeedBox", true)
			if speedBox then
				speedBox.Text = tostring(speed)
			end
			if btn then
				btn.Text = "UNFC"
				btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			end
		end
		DebugNotif("Freecam speed updated to "..tostring(legacySpeed), 2)
		return
	end

	if NAlib.isConnected("freecam") then
		if typeof(requestedStartCFrame) == "CFrame" and typeof(NAStuff.FreecamLegacyPart) == "Instance" then
			NAStuff.FreecamLegacyPart.CFrame = takeStartCFrame()
		end
		flyVariables.mOn = true
		if IsOnMobile and fcBTNTOGGLE then
			const btn = fcBTNTOGGLE:FindFirstChild("FreecamMainButton", true)
			const speedBox = fcBTNTOGGLE:FindFirstChild("FreecamSpeedBox", true)
			if speedBox then
				speedBox.Text = tostring(speed)
			end
			if btn then
				btn.Text = "UNFC"
				btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			end
		end
		DebugNotif("Freecam speed updated to "..tostring(legacySpeed), 2)
		return
	end
	flyVariables.mOn = false

	if fcBTNTOGGLE then
		fcBTNTOGGLE:Destroy()
		fcBTNTOGGLE = nil
	end

	const function runFREECAM()
		const freecamMoveAttr = "NAFreecamMoveCF"
		const camPart = InstanceNew("Part")
		camPart.Transparency = 1
		camPart.Anchored = true
		camPart.CFrame = typeof(requestedStartCFrame) == "CFrame" and takeStartCFrame() or camera.CFrame
		NAStuff.FreecamLegacyPart = camPart
		NAmanage.SetAttr(camPart, freecamMoveAttr, CFrame.new())
		local moveCF = NAmanage.GetAttr(camPart, freecamMoveAttr)
		if typeof(moveCF) ~= "CFrame" then
			moveCF = CFrame.new()
			NAmanage.SetAttr(camPart, freecamMoveAttr, moveCF)
		end

		NAlib.connect("freecam", Services.RunService.RenderStepped:Connect(function(dt)
			const primaryPart = camPart
			camera.CameraSubject = primaryPart

			const moveVec = GetCustomMoveVector()
			const currentSpeed = normalizeLegacySpeed(NAStuff.FreecamSpeed) or speed

			const x = moveVec.X * currentSpeed
			const y = moveVec.Y * currentSpeed
			const z = moveVec.Z * currentSpeed

			primaryPart.CFrame = CFrame.new(
				primaryPart.CFrame.p,
				(camera.CFrame * CFrame.new(0, 0, -100)).p
			)

			const moveDir = CFrame.new(x, y, z)
			moveCF = moveDir
			NAmanage.SetAttr(primaryPart, freecamMoveAttr, moveCF)
			primaryPart.CFrame = primaryPart.CFrame * moveCF
		end))
	end

	if IsOnMobile then
		if fcBTNTOGGLE then
			fcBTNTOGGLE:Destroy()
			fcBTNTOGGLE = nil
		end

		fcBTNTOGGLE = InstanceNew("ScreenGui")
		const btn = InstanceNew("TextButton")
		const speedBox = InstanceNew("TextBox")
		const toggleBtn = InstanceNew("TextButton")
		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		const corner2 = InstanceNew("UICorner")
		corner2.CornerRadius = UDim.new(0, 6)
		const corner3 = InstanceNew("UICorner")
		corner3.CornerRadius = UDim.new(0, 6)
		const aspect = InstanceNew("UIAspectRatioConstraint")

		NAgui.NaProtectUI(fcBTNTOGGLE)
		fcBTNTOGGLE.ResetOnSpawn = false

		btn.Name = "FreecamMainButton"
		btn.Parent = fcBTNTOGGLE
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.BackgroundTransparency = 0.1
		btn.Position = UDim2.new(0.9, 0, 0.5, 0)
		btn.Size = UDim2.new(0.08, 0, 0.1, 0)
		btn.Font = Enum.Font.GothamBold
		btn.Text = "FC"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 18
		btn.TextWrapped = true
		btn.Active = true
		btn.TextScaled = true

		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = btn

		aspect.Parent = btn
		aspect.AspectRatio = 1.0

		speedBox.Name = "FreecamSpeedBox"
		speedBox.Parent = fcBTNTOGGLE
		speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		speedBox.BackgroundTransparency = 0.1
		speedBox.AnchorPoint = Vector2.new(0.5, 0)
		speedBox.Position = UDim2.new(0.5, 0, 0, 10)
		speedBox.Size = UDim2.new(0, 75, 0, 35)
		speedBox.Font = Enum.Font.GothamBold
		speedBox.Text = tostring(speed)
		speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
		speedBox.TextSize = 18
		speedBox.TextWrapped = true
		speedBox.ClearTextOnFocus = false
		speedBox.PlaceholderText = "Speed"
		speedBox.Visible = false

		corner2.CornerRadius = UDim.new(0, 6)
		corner2.Parent = speedBox

		toggleBtn.Name = "FreecamSpeedToggle"
		toggleBtn.Parent = btn
		toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		toggleBtn.BackgroundTransparency = 0.1
		toggleBtn.Position = UDim2.new(0.9, 0, -0.1, 0)
		toggleBtn.Size = UDim2.new(0.4, 0, 0.4, 0)
		toggleBtn.Font = Enum.Font.SourceSans
		toggleBtn.Text = "+"
		toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		toggleBtn.TextSize = 14
		toggleBtn.TextWrapped = true
		toggleBtn.Active = true
		toggleBtn.AutoButtonColor = true

		corner3.CornerRadius = UDim.new(0, 6)
		corner3.Parent = toggleBtn

		MouseButtonFix(toggleBtn, function()
			speedBox.Visible = not speedBox.Visible
			toggleBtn.Text = speedBox.Visible and "-" or "+"
		end)

		const function applyMobileFreecamSpeed()
			const newSpeed = normalizeLegacySpeed(speedBox.Text) or speed
			speed = newSpeed
			speedBox.Text = tostring(speed)
			NAStuff.FreecamSpeed = speed
			pcall(NAmanage.NASettingsSet, "freecamSpeed", speed)
			if NAFreecam and NAFreecam.IsEnabled and NAFreecam.IsEnabled() and NAFreecam.SetSpeed then
				NAFreecam.SetSpeed(speed / 5)
			end
		end

		const function startMobileFreecam()
			applyMobileFreecamSpeed()
			if flyVariables.mOn then
				return
			end
			flyVariables.mOn = true
			btn.Text = "UNFC"
			btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			SpawnCall(function() cmd.run({"fr",''}) end)
			if NAFreecam then
				NAFreecam.Start(speed and (speed / 5) or nil, takeStartCFrame())
			else
				runFREECAM()
			end
		end

		speedBox.FocusLost:Connect(applyMobileFreecamSpeed)

		NAmanage.Wrap(function()
			MouseButtonFix(btn, function()
				applyMobileFreecamSpeed()
				if not flyVariables.mOn then
					startMobileFreecam()
				else
					flyVariables.mOn = false
					btn.Text = "FC"
					btn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
					if NAFreecam and NAFreecam.IsEnabled() then
						NAFreecam.Stop()
					end
					if NAlib.isConnected("freecam") then
						NAlib.disconnect("freecam")
					end
					camera.CameraSubject = getChar()
					SpawnCall(function() cmd.run({"unfr"}) end)
					DebugNotif("Freecam disabled", 2)
				end
			end)
		end)()

		NAgui.draggerV2(btn)
		NAgui.draggerV2(speedBox)

		startMobileFreecam()
	else
		if not IsOnPC then
			return DebugNotif("Freecam is only available on PC and mobile", 3)
		end

		DebugNotif("Roblox-style freecam enabled (WASD + mouse, "..string.upper(tostring(NAStuff.FreecamDownKey or "Q")).."/"..string.upper(tostring(NAStuff.FreecamUpKey or "E")).." down/up, arrows change speed)", 3)
		if NAFreecam then
			NAFreecam.Start(navSpeed, takeStartCFrame())
		else
			runFREECAM()
		end
	end
end, true)

cmd.add({"freecamgoto","fcgoto","fcgo","fcg","freecamto","fcto"},{"freecamgoto <player|npc:filter> (fcgoto,fcgo,fcg,freecamto,fcto)","Start or move freecam to a player or NPC"},function(...)
	const query = Concat({...}, " ")
	if query == "" then
		return DebugNotif("Player name required", 3)
	end

	local target
	local targetCFrame
	for _, candidate in getPlr(query) do
		const cframe = NAmanage.PlayerArgPivot(candidate)
		if typeof(cframe) == "CFrame" then
			target = candidate
			targetCFrame = cframe
			break
		end
	end

	if not targetCFrame then
		return DebugNotif("Player not found or has no character", 3)
	end

	NAmanage.StartFreecamAtCFrame(targetCFrame)
	DebugNotif("Freecam moved to "..NAmanage.PlayerArgName(target), 2)
end, true)

cmd.add({"freecamgotopart","fcgotopart","fcgpart","fcgp","freecamtopart","fctopart","fctp"},{"freecamgotopart <partname> (fcgotopart,fcgpart,fcgp,freecamtopart,fctopart,fctp)","Start or move freecam to an exact part name"},function(...)
	const partName = Concat({...}, " "):lower()
	if partName == "" then
		return DebugNotif("Part name required", 3)
	end

	local targetPart
	for _, part in NAmanage.fastWorkspaceMatches("BasePart", partName, "exact") do
		if part.Name:lower() == partName then
			targetPart = part
			break
		end
	end

	if not targetPart then
		return DebugNotif("Part not found: "..partName, 3)
	end

	NAmanage.StartFreecamAtCFrame(targetPart:GetPivot())
	DebugNotif("Freecam moved to "..targetPart:GetFullName(), 2)
end, true)

cmd.add({"unfreecam","unfc","unfcam"},{"unfreecam (unfc,unfcam)","Disable free camera"},function()
	NAStuff.FreecamStartCFrame = nil
	NAStuff.FreecamLegacyPart = nil
	if NAFreecam and NAFreecam.IsEnabled() then
		NAFreecam.Stop()
	end
	NAlib.disconnect("freecam")
	camera.CameraSubject = getChar()
	SpawnCall(function() cmd.run({"unfr"}) end)
	flyVariables.mOn = false
	if fcBTNTOGGLE then fcBTNTOGGLE:Destroy() fcBTNTOGGLE = nil end
	DebugNotif("Freecam disabled", 2)
end)

cmd.add({"nohats","drophats"},{"nohats (drophats)","Drop all of your hats"},function()
	for _,hat in getChar():GetChildren() do
		if hat:IsA("Accoutrement") then
			hat:FindFirstChildWhichIsA("Weld",true):Destroy()
		end
	end
end)

cmd.add({"instantrespawn", "instantr", "irespawn"}, {"instantrespawn (instantr, irespawn)", "respawn instantly"}, function()
	if not replicatesignal then
		return DoNotif("Your executor does not support 'replicatesignal'")
	end

	replicatesignal(LocalPlayer.ConnectDiedSignalBackend)

	const rootPart = LocalPlayer.Character and getRoot(LocalPlayer.Character)
	const respawnCF = rootPart and (NAmanage.UG_clientCFrame(rootPart) or rootPart.CFrame) or nil
	const cam = Services.Workspace.CurrentCamera

	Wait(Services.Players.RespawnTime - 0.165)

	const humanoid = getHum()
	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end

	Wait(0.5)

	if respawnCF then
		const newRoot = getRoot(LocalPlayer.Character)
		if newRoot then
			NAmanage.UG_setClientCFrame(newRoot, respawnCF)
		end
	end

	Services.Workspace.CurrentCamera = cam
end)

function getAllTools()
	const tools={}
	const backpack=localPlayer:FindFirstChildWhichIsA("Backpack")
	if backpack then
		for i,v in backpack:GetChildren() do
			if v:IsA("Tool") then
				Insert(tools,v)
			end
		end
	end
	for i,v in character:GetChildren() do
		if v:IsA("Tool") then
			Insert(tools,v)
		end
	end
	return tools
end

cmd.add({"circlemath", "cm"}, {"circlemath <mode> <size>", "Gay circle math\nModes: a,b,c,d,e"}, function(mode, size)
	const mode = mode or "a"
	const backpack = getBp()
	NAlib.disconnect("cm")
	if backpack and character.Parent then
		const tools = getAllTools()
		for i, tool in tools do
			local cpos, g = (math.pi*2)*(i/#tools), CFrame.new()
			const tcon = {}
			tool.Parent = backpack

			if mode == "a" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(0, 0, size)*
						CFrame.Angles(rad(90), 0, cpos)
				)
			elseif mode == "b" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(i - #tools/2, 0, 0)*
						CFrame.Angles(rad(90), 0, 0)
				)
			elseif mode == "c" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(cpos/3, 0, 0)*
						CFrame.Angles(rad(90), 0, cpos*2)
				)
			elseif mode == "d" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(clamp(tan(cpos), -3, 3), 0, 0)*
						CFrame.Angles(rad(90), 0, cpos)
				)
			elseif mode == "e" then
				size = tonumber(size) or 2
				g = (
					CFrame.new(0, 0, clamp(tan(cpos), -5, 5))*
						CFrame.Angles(rad(90), 0, cpos)
				)
			end
			tool.Grip = g
			tool.Parent = character

			tcon[#tcon] = NAlib.connect("cm", mouse.Button1Down:Connect(function()
				tool:Activate()
			end))
			tcon[#tcon] = NAlib.connect("cm", tool.Changed:Connect(function(p)
				if p == "Grip" and tool.Grip ~= g then
					tool.Grip = g
				end
			end))

			NAlib.connect("cm", tool.AncestryChanged:Connect(function()
				for i = 1, #tcon do
					tcon[i]:Disconnect()
				end
			end))
		end
	end
end,true)

GRIPUITHINGYIDFK = nil

cmd.add({"grippos", "setgrip"}, {"grippos (setgrip)", "Opens a UI to manually input grip offset and rotation."}, function()
	const plr = LocalPlayer
	if GRIPUITHINGYIDFK then return end

	GRIPUITHINGYIDFK = InstanceNew("ScreenGui")
	GRIPUITHINGYIDFK.Name = "GripAdjustUI"
	GRIPUITHINGYIDFK.ResetOnSpawn = false
	NAgui.NaProtectUI(GRIPUITHINGYIDFK)

	const frame = InstanceNew("Frame")
	frame.Size = UDim2.new(0, 320, 0, 270)
	frame.Position = UDim2.new(0.5, -160, 0.5, -135)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	frame.BorderSizePixel = 0
	frame.Parent = GRIPUITHINGYIDFK

	const corner = InstanceNew("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 6)

	const gradient = InstanceNew("UIGradient", frame)
	gradient.Rotation = 90
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
	}

	const titleBar = InstanceNew("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = frame

	const barCorner = InstanceNew("UICorner", titleBar)
	barCorner.CornerRadius = UDim.new(0, 6)

	const title = InstanceNew("TextLabel")
	title.Size = UDim2.new(1, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.Text = "Grip Position Editor"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.Parent = titleBar

	const preview = InstanceNew("TextButton")
	preview.Size = UDim2.new(0, 260, 0, 28)
	preview.Position = UDim2.new(0, 30, 0, 180)
	preview.Text = "🔍 Preview"
	preview.Font = Enum.Font.GothamBold
	preview.TextSize = 15
	preview.BackgroundColor3 = Color3.fromRGB(75, 75, 95)
	preview.TextColor3 = Color3.new(1, 1, 1)
	preview.Parent = frame
	InstanceNew("UICorner", preview).CornerRadius = UDim.new(0, 6)

	const labels = {"X", "Y", "Z", "RX", "RY", "RZ"}
	const textBoxes = {}

	for i, label in labels do
		const xOffset = ((i - 1) % 3) * 100
		const yOffset = 40 + math.floor((i - 1) / 3) * 50

		const labelUI = InstanceNew("TextLabel")
		labelUI.Size = UDim2.new(0, 40, 0, 25)
		labelUI.Position = UDim2.new(0, 10 + xOffset, 0, yOffset)
		labelUI.BackgroundTransparency = 1
		labelUI.Text = label
		labelUI.TextColor3 = Color3.fromRGB(255, 255, 255)
		labelUI.Font = Enum.Font.Gotham
		labelUI.TextSize = 14
		labelUI.Parent = frame

		const box = InstanceNew("TextBox")
		box.Size = UDim2.new(0, 50, 0, 25)
		box.Position = UDim2.new(0, 50 + xOffset, 0, yOffset)
		box.PlaceholderText = "0"
		box.Text = ""
		box.Font = Enum.Font.Gotham
		box.TextSize = 14
		box.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		box.TextColor3 = Color3.fromRGB(255, 255, 255)
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.Parent = frame

		const boxCorner = InstanceNew("UICorner", box)
		boxCorner.CornerRadius = UDim.new(0, 6)

		textBoxes[label] = box
	end

	const function getVal(name)
		return tonumber(textBoxes[name].Text) or 0
	end

	const function closeUI()
		if GRIPUITHINGYIDFK then
			GRIPUITHINGYIDFK:Destroy()
			GRIPUITHINGYIDFK = nil
		end
	end

	const function applyGrip()
		const char = getChar()
		const tool = char and char:FindFirstChildOfClass("Tool")
		const backpack = getBp() or LocalPlayer:FindFirstChild("Backpack")
		if not tool or not backpack then return end

		const pos = Vector3.new(getVal("X"), getVal("Y"), getVal("Z"))
		const rot = Vector3.new(getVal("RX"), getVal("RY"), getVal("RZ"))
		const gripCFrame = CFrame.new(pos) * CFrame.Angles(math.rad(rot.X), math.rad(rot.Y), math.rad(rot.Z))

		tool.Parent = backpack
		Wait()
		tool.Grip = gripCFrame
		tool.Parent = char

		local fix
		fix = tool.Changed:Connect(function(prop)
			if prop == "Grip" and tool.Grip ~= gripCFrame then
				tool.Grip = gripCFrame
			end
		end)

		tool.AncestryChanged:Connect(function()
			if fix then fix:Disconnect() end
		end)
	end

	const confirm = InstanceNew("TextButton")
	confirm.Size = UDim2.new(0, 130, 0, 32)
	confirm.Position = UDim2.new(0, 20, 0, 215)
	confirm.Text = "Apply"
	confirm.Font = Enum.Font.GothamBold
	confirm.TextSize = 16
	confirm.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
	confirm.TextColor3 = Color3.new(1, 1, 1)
	confirm.Parent = frame
	InstanceNew("UICorner", confirm).CornerRadius = UDim.new(0, 6)

	const cancel = InstanceNew("TextButton")
	cancel.Size = UDim2.new(0, 130, 0, 32)
	cancel.Position = UDim2.new(0, 170, 0, 215)
	cancel.Text = "Cancel"
	cancel.Font = Enum.Font.GothamBold
	cancel.TextSize = 16
	cancel.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	cancel.TextColor3 = Color3.new(1, 1, 1)
	cancel.Parent = frame
	InstanceNew("UICorner", cancel).CornerRadius = UDim.new(0, 6)

	MouseButtonFix(confirm, function()
		applyGrip()
		closeUI()
	end)

	MouseButtonFix(preview, applyGrip)
	MouseButtonFix(cancel, closeUI)

	NAgui.draggerV2(frame)
end)

cmd.add({"seizure"}, {"seizure", "Gives you a seizure"}, function()
	SpawnCall(function()
		if _na_env.Lzzz == true then return end

		const Anim = InstanceNew("Animation")
		if IsR15() then
			Anim.AnimationId = "rbxassetid://507767968"
		else
			Anim.AnimationId = "rbxassetid://180436148"
		end
		const k = getHum():LoadAnimation(Anim)
		_na_env.ssss = NAmanage.GetMouse(LocalPlayer)
		_na_env.Lzzz = false

		if Lzzz == false then
			_na_env.Lzzz = true
			if IsR15() then
				Anim.AnimationId = "rbxassetid://507767968"
			else
				Anim.AnimationId = "rbxassetid://180436148"
			end
			_na_env.currentnormal = Services.Workspace.Gravity
			Services.Workspace.Gravity = 196.2
			NAmanage.UG_pivotModel(LocalPlayer.Character, ((getRoot(LocalPlayer.Character) and NAmanage.UG_clientCFrame(getRoot(LocalPlayer.Character))) or LocalPlayer.Character:GetPivot()) * CFrame.Angles(2, 0, 0))
			Wait(0.5)
			if getHum() and getHum().PlatformStand then getHum().PlatformStand = true end
			LocalPlayer.Character.Animate.Disabled = true

			k:Play()
			k:AdjustSpeed(10)

			LocalPlayer.Character.Animate.Disabled = true
		else
			_na_env.Lzzz = false
			if IsR15() then
				Anim.AnimationId = "rbxassetid://507767968"
			else
				Anim.AnimationId = "rbxassetid://180436148"
			end
			Services.Workspace.Gravity = currentnormal
			if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
			getHum().Jump = true
			k:Stop()

			LocalPlayer.Character.Animate.Disabled = false
			Services.RunService.Heartbeat:Wait()
			for i = 1,10 do
				getRoot(LocalPlayer.Character).AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				Wait(0.1)
			end
		end

		NAlib.disconnect("seizure_loop")
		NAlib.connect("seizure_loop", Services.RunService.RenderStepped:Connect(function()
			if _na_env.Lzzz == true then
				getRoot(LocalPlayer.Character).CFrame = getRoot(LocalPlayer.Character).CFrame * CFrame.new(
					.075 * math.sin(45 * tick()),
					.075 * math.sin(45 * tick()),
					.075 * math.sin(45 * tick())
				)
			end
		end))
	end)
end)

cmd.add({"unseizure"}, {"unseizure", "Stops you from having a seizure not in real life noob"}, function()
	SpawnCall(function()
		if _na_env.Lzzz ~= true then return end
		NAlib.disconnect("seizure_loop")

		const Anim = InstanceNew("Animation")
		if IsR15() then
			Anim.AnimationId = "rbxassetid://507767968"
		else
			Anim.AnimationId = "rbxassetid://180436148"
		end

		const k = getHum():LoadAnimation(Anim)

		_na_env.Lzzz = false
		Services.Workspace.Gravity = currentnormal
		if getHum() and getHum().PlatformStand then getHum().PlatformStand = false end
		getHum().Jump = true
		k:Stop()

		LocalPlayer.Character.Animate.Disabled = false

		Services.RunService.Heartbeat:Wait()
		for i = 1, 10 do
			getRoot(LocalPlayer.Character).AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			Wait(0.1)
		end
	end)
end)

FakeLagCfg = { interval = 0.05, jitter = 0.02, duration = nil }

cmd.add({"fakelag", "flag"}, {"fakelag (flag)", "fake lag"}, function(interval, jitter, duration)
	if type(interval) == "number" then FakeLagCfg.interval = math.max(0, interval) end
	if type(jitter) == "number" then FakeLagCfg.jitter = math.max(0, jitter) end
	if type(duration) == "number" then FakeLagCfg.duration = (duration > 0) and duration or nil end
	if FakeLag then return end
	FakeLag = true
	NAlib.disconnect("FakeLag")

	const function nextInterval()
		const b = tonumber(FakeLagCfg.interval) or 0.05
		const j = tonumber(FakeLagCfg.jitter) or 0
		if j <= 0 then return math.max(0, b) end
		return math.max(0, b + Random.new():NextNumber(-j, j))
	end

	const startTs = time()
	local state = false
	local nextFlipAt = time()

	NAlib.connect("FakeLag", Services.RunService.Heartbeat:Connect(function()
		if not FakeLag then
			NAlib.disconnect("FakeLag")
			const r = getRoot(getChar())
			if r then NAlib.setProperty(r, "Anchored", false) end
			return
		end
		if FakeLagCfg.duration and (time() - startTs) > FakeLagCfg.duration then
			FakeLag = false
			NAlib.disconnect("FakeLag")
			const r = getRoot(getChar())
			if r then NAlib.setProperty(r, "Anchored", false) end
			return
		end
		const now = time()
		if now >= nextFlipAt then
			const r = getRoot(getChar())
			if r and r.Parent then
				state = not state
				NAlib.setProperty(r, "Anchored", state)
				nextFlipAt = now + nextInterval()
			else
				FakeLag = false
				NAlib.disconnect("FakeLag")
			end
		end
	end))
end)

cmd.add({"unfakelag", "unflag"}, {"unfakelag (unflag)", "stops the fake lag command"}, function()
	if not FakeLag and not NAlib.isConnected("FakeLag") then return end
	FakeLag = false
	NAlib.disconnect("FakeLag")
	const r = getRoot(getChar())
	if r then NAlib.setProperty(r, "Anchored", false) end
end)

r=math.rad
center=CFrame.new(1.5,0.5,-1.5)

cmd.add({"hide", "unshow"}, {"hide <player> (unshow)", "places the selected player to lighting"}, function(...)
	Wait()
	DebugNotif("Hid the player")
	const Username = (...)
	const target = getPlr(Username)
	for _, plr in next, target do
		if plr and plr.Character then
			const A_1 = "/mute "..plr.Name
			const A_2 = "All"
			NAlib.LocalPlayerChat(A_1, A_2)
			plr.Character.Parent = Services.Lighting
		end
	end
end, true)

cmd.add({"unhide", "show"}, {"show <player> (unhide)", "places the selected player back to workspace"}, function(...)
	Wait()
	DebugNotif("Unhid the player")
	const Username = (...)
	const target = getPlr(Username)
	for _, plr in next, target do
		if plr and plr.Character then
			const A_1 = "/unmute "..plr.Name
			const A_2 = "All"
			NAlib.LocalPlayerChat(A_1, A_2)
			plr.Character.Parent = Services.Workspace
		end
	end
end, true)

cmd.add({"aimbot","aimbotui","aimbotgui"},{"aimbot (aimbotui,aimbotgui)","aimbot and yeah"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/NewAimbot.lua")
	--NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Aimbot.lua",true)
end)

NAmanage.toolCache = NAmanage.ensureWeakKeyTable(NAmanage.toolCache or {})
NAmanage.toolGrabCol = NAmanage.ensureWeakKeyTable(NAmanage.toolGrabCol or {})
NAmanage.grabBusy = NAmanage.ensureWeakKeyTable(NAmanage.grabBusy or {})
NAmanage.toolCacheReady = NAmanage.toolCacheReady or false

NAmanage.isOwnPackTool = NAmanage.isOwnPackTool or function(tool)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return false
	end

	const char = getChar()
	const bp = getBp()
	return (char and tool:IsDescendantOf(char)) or (bp and tool:IsDescendantOf(bp))
end

NAmanage.isCharTool = NAmanage.isCharTool or function(tool)
	const RawWorkspace = __lt.gs("Workspace")
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return false
	end

	if NAmanage.isOwnPackTool(tool) then
		return false
	end

	local inst = tool.Parent
	while inst and inst ~= RawWorkspace do
		if inst:IsA("Model") then
			local okPlr, plr = pcall(function()
				return Services.Players:GetPlayerFromCharacter(inst)
			end)
			if okPlr and plr then
				return true
			end
			if inst:FindFirstChildOfClass("Humanoid") then
				return true
			end
		end
		inst = inst.Parent
	end

	return false
end

NAmanage.isDroppedTool = NAmanage.isDroppedTool or function(tool)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return false
	end
	if not tool:IsDescendantOf(Services.Workspace) then
		return false
	end
	if NAmanage.isOwnPackTool(tool) then
		return false
	end
	if NAmanage.isCharTool(tool) then
		return false
	end
	return true
end

NAmanage.toolPart = NAmanage.toolPart or function(tool)
	if typeof(tool) ~= "Instance" then
		return nil
	end

	const handle = tool:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		return handle
	end

	for _, d in NAmanage.QueryDescendants(tool, "BasePart") do
		return d
	end

	return nil
end

NAmanage.toolParts=function(tool)
	const parts = {}
	if typeof(tool) ~= "Instance" then
		return parts
	end

	const handle = tool:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		parts[#parts + 1] = handle
	end

	for _, d in NAmanage.QueryDescendants(tool, "BasePart") do
		if d ~= handle then
			parts[#parts + 1] = d
		end
	end

	return parts
end

NAmanage.toolPrompts = NAmanage.toolPrompts or function(tool)
	const prompts = {}
	if typeof(tool) ~= "Instance" then
		return prompts
	end

	for _, inst in NAmanage.QueryDescendants(tool, "ProximityPrompt") do
		if inst.Parent then
			prompts[#prompts + 1] = inst
		end
	end

	return prompts
end

NAmanage.toolHasPrompt = NAmanage.toolHasPrompt or function(tool)
	return #NAmanage.toolPrompts(tool) > 0
end

NAmanage.fireToolPrompts = NAmanage.fireToolPrompts or function(tool, waitTime, attempts)
	if typeof(tool) ~= "Instance" or typeof(fireproximityprompt) ~= "function" then
		return false, false
	end

	const prompts = NAmanage.toolPrompts(tool)
	if #prompts == 0 then
		return false, false
	end

	local fired = false
	const tries = math.max(1, tonumber(attempts) or 1)
	for attempt = 1, tries do
		for _, inst in prompts do
			if inst and inst.Parent then
				fired = true
				const holdDuration = inst.HoldDuration
				const maxDistance = inst.MaxActivationDistance

				NACaller(function()
					if holdDuration > 0 then
						inst.HoldDuration = 0
					end
					if maxDistance < 32 then
						inst.MaxActivationDistance = 32
					end
				end)

				pcall(fireproximityprompt, inst)

				NACaller(function()
					if inst and inst.Parent then
						if inst.HoldDuration ~= holdDuration then
							inst.HoldDuration = holdDuration
						end
						if inst.MaxActivationDistance ~= maxDistance then
							inst.MaxActivationDistance = maxDistance
						end
					end
				end)
			end
		end

		if NAmanage.isOwnPackTool(tool) then
			break
		end

		const settleBetween = tonumber(waitTime)
		if settleBetween and settleBetween > 0 and attempt < tries then
			Wait(settleBetween)
		end
	end

	const settle = tonumber(waitTime)
	if settle and settle > 0 then
		Wait(settle)
	end

	return fired, NAmanage.isOwnPackTool(tool)
end

NAmanage.fireToolPromptsFromCharacter = NAmanage.fireToolPromptsFromCharacter or function(tool)
	if typeof(tool) ~= "Instance" or typeof(fireproximityprompt) ~= "function" then
		return false, false
	end

	const prompts = NAmanage.toolPrompts(tool)
	if #prompts == 0 then
		return false, false
	end

	const char = getChar()
	const root = char and getRoot(char)
	if not (char and root) then
		return false, false
	end

	const oldCF = NAmanage.UG_clientCFrame(root) or root.CFrame
	local moved = false
	local firedAny = false

	for _, pp in prompts do
		if pp and pp.Parent then
			const part = (NAindex and NAindex.getPromptPart and NAindex.getPromptPart(pp)) or nil
			if part and part.Parent then
				const offset = math.max(3, math.min(6, (pp.MaxActivationDistance or 0) * 0.6))
				const targetPos = part.Position + Vector3.new(0, 0, offset)
				const targetCF = CFrame.new(targetPos, part.Position)
				NAmanage.safePivotModel(char, targetCF)
				moved = true
				Wait(0.2)

				local fired = false
				fired, _ = NAmanage.fireToolPrompts(tool, 0.12, 3)
				firedAny = firedAny or fired
				if NAmanage.isOwnPackTool(tool) then
					break
				end
			end
		end
	end

	if moved and char and char.Parent and root and root.Parent then
		NAmanage.UG_setClientCFrame(root, oldCF)
		NAmanage.safePivotModel(char, oldCF)
	end

	return firedAny, NAmanage.isOwnPackTool(tool)
end

NAmanage.touchEquipTool = NAmanage.touchEquipTool or function(tool, root, hum, settleTime)
	if not (tool and root) then
		return false
	end

	NAmanage.touchTool(tool, root)
	const settle = tonumber(settleTime) or 0.05
	if settle > 0 then
		Wait(settle)
	end

	if NAmanage.isOwnPackTool(tool) then
		return true
	end

	if hum then
		NACaller(function()
			hum:EquipTool(tool)
		end)
		if settle > 0 then
			Wait(settle)
		end
	end

	return NAmanage.isOwnPackTool(tool)
end

NAmanage.addToolCache=function(tool)
	if typeof(tool) == "Instance" and tool:IsA("Tool") then
		NAmanage.toolCache[tool] = true
	end
end

NAmanage.scanToolBranch=function(inst)
	if typeof(inst) ~= "Instance" then
		return
	end

	if inst:IsA("Tool") then
		NAmanage.addToolCache(inst)
		return
	end

	if inst:IsA("Folder") or inst:IsA("Model") then
		for _, d in NAmanage.QueryDescendants(inst, "Tool") do
			NAmanage.addToolCache(d)
		end
	end
end
