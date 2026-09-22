originalIO.startMultiTool=function()
	const localPlayer = Services.Players.LocalPlayer
	const char = getChar()
	const backpack = getBp()

	if not localPlayer or not char or not backpack then
		DoNotif("Could not find your character or backpack.", 2)
		return
	end

	originalIO.stopMultiTool(true)

	const tracked = {}
	const UNEQUIP_WINDOW = 0.25
	MultiToolCons.tracked = tracked
	MultiToolCons.equipToken = 0
	MultiToolCons.restacking = false
	MultiToolCons.enabled = true

	const function trackTool(tool)
		if typeof(tool) == "Instance" and tool:IsA("Tool") then
			tracked[tool] = true
		end
	end

	const function untrackTool(tool)
		if tool then
			tracked[tool] = nil
		end
	end

	const function stackTrackedTools()
		if MultiToolCons.restacking then
			return
		end

		const activeChar = getChar()
		const activeBackpack = getBp()
		if not activeChar or not activeBackpack then
			return
		end

		MultiToolCons.restacking = true
		for tool in tracked do
			if typeof(tool) ~= "Instance" or tool.Parent == nil then
				untrackTool(tool)
			elseif tool.Parent == activeBackpack then
				NACaller(function()
					if tool.Parent == activeBackpack then
						tool.Parent = activeChar
					end
				end)
			elseif tool.Parent ~= activeChar then
				untrackTool(tool)
			end
		end
		MultiToolCons.restacking = false
	end

	const function connectCharacter(charRef)
		if MultiToolCons.charChildAdded then
			MultiToolCons.charChildAdded:Disconnect()
			MultiToolCons.charChildAdded = nil
		end
		if MultiToolCons.charChildRemoved then
			MultiToolCons.charChildRemoved:Disconnect()
			MultiToolCons.charChildRemoved = nil
		end

		if typeof(charRef) ~= "Instance" then
			return
		end

		for tool in tracked do
			tracked[tool] = nil
		end

		for _, item in charRef:GetChildren() do
			if item:IsA("Tool") then
				trackTool(item)
			end
		end

		MultiToolCons.charChildAdded = NAmanage.childAdd(charRef, function(item)
			if item:IsA("Tool") then
				if MultiToolCons.restacking then
					return
				end
				MultiToolCons.equipToken = (MultiToolCons.equipToken or 0) + 1
				trackTool(item)
				Defer(stackTrackedTools)
			end
		end, function(item)
			return item and item:IsA("Tool")
		end)

		MultiToolCons.charChildRemoved = NAmanage.childRem(charRef, function(item)
			if not item:IsA("Tool") then
				return
			end
			if MultiToolCons.restacking then
				return
			end

			const tokenAtRemoval = MultiToolCons.equipToken or 0
			Delay(UNEQUIP_WINDOW, function()
				if not MultiToolCons.enabled or MultiToolCons.tracked ~= tracked then
					return
				end

				if (MultiToolCons.equipToken or 0) ~= tokenAtRemoval then
					return
				end

				const activeChar = getChar()
				const activeBackpack = getBp()

				if typeof(item) ~= "Instance" or item.Parent == nil then
					untrackTool(item)
					return
				end

				if activeBackpack and item.Parent == activeBackpack then
					-- No new equip followed: treat as intentional unequip.
					untrackTool(item)
					return
				end

				if not (activeChar and item.Parent == activeChar) then
					untrackTool(item)
				end
			end)
		end, function(item)
			return item and item:IsA("Tool")
		end)
	end

	const function connectBackpack(backpackRef)
		if MultiToolCons.backpackChildAdded then
			MultiToolCons.backpackChildAdded:Disconnect()
			MultiToolCons.backpackChildAdded = nil
		end

		if typeof(backpackRef) ~= "Instance" then
			return
		end

		MultiToolCons.backpackChildAdded = NAmanage.childAdd(backpackRef, function(item)
			if item:IsA("Tool") and tracked[item] then
				-- Re-equip only when a true equip-swap happens (handled by char ChildAdded).
			end
		end, function(item)
			return item and item:IsA("Tool")
		end)
	end

	connectCharacter(char)
	connectBackpack(backpack)

	MultiToolCons.charAdded = localPlayer.CharacterAdded:Connect(function(newChar)
		connectCharacter(newChar)
		Defer(stackTrackedTools)
	end)

	MultiToolCons.playerChildAdded = NAmanage.childAdd(localPlayer, function(child)
		if typeof(child) == "Instance" and child:IsA("Backpack") then
			connectBackpack(child)
			Defer(stackTrackedTools)
		end
	end, function(child)
		return typeof(child) == "Instance" and child:IsA("Backpack")
	end)

	DoNotif("Multitool enabled. Equip another tool to stack it.", 3)
end

cmd.add({"edgejump", "ejump"}, {"edgejump (ejump)", "Automatically jumps when you get to the edge of an object"}, function()
	local Char = speaker.Character
	local Human = getHum()
	local currentState
	local previousState
	local lastCFrame

	const function edgeJump()
		if Char and Human then
			previousState = currentState
			currentState = Human:GetState()
			if previousState ~= currentState and currentState == Enum.HumanoidStateType.Freefall and previousState ~= Enum.HumanoidStateType.Jumping then
				const rootPart = getRoot(Char)
				rootPart.CFrame = lastCFrame
				rootPart.Velocity = Vector3.new(rootPart.Velocity.X, Human.JumpPower or Human.JumpHeight, rootPart.Velocity.Z)
			end
			lastCFrame = getRoot(Char).CFrame
		end
	end

	edgeJump()
	if HumanModCons.ejLoop then HumanModCons.ejLoop:Disconnect() end
	HumanModCons.ejLoop = NAlib.reconnect("edgejump_loop", Services.RunService.RenderStepped:Connect(edgeJump))
	HumanModCons.ejCA = (HumanModCons.ejCA and HumanModCons.ejCA:Disconnect() and false) or speaker.CharacterAdded:Connect(function(newChar)
		Char = newChar
		Human = getPlrHum(newChar)
		edgeJump()
		if HumanModCons.ejLoop then HumanModCons.ejLoop:Disconnect() end
		HumanModCons.ejLoop = NAlib.reconnect("edgejump_loop", Services.RunService.RenderStepped:Connect(edgeJump))
	end)
end)

cmd.add({"unedgejump", "noedgejump", "noejump", "unejump"}, {"unedgejump (noedgejump, noejump, unejump)", "Disables edgejump"}, function()
	if HumanModCons.ejLoop then
		HumanModCons.ejLoop:Disconnect()
		HumanModCons.ejLoop = nil
	end
	NAlib.disconnect("edgejump_loop")

	if HumanModCons.ejCA then
		HumanModCons.ejCA:Disconnect()
		HumanModCons.ejCA = nil
	end
end)

cmd.add({"equiptools","etools","equipt"},{"equiptools (etools,equipt)","Equips every tool in your inventory"},function()
	for i,v in LocalPlayer:FindFirstChildOfClass("Backpack"):GetChildren() do
		if v:IsA("Tool") then
			v.Parent = getChar()
		end
	end
end)
cmd.add({"unequiptools"},{"unequiptools","Unequips every tool you are currently holding"},function()
	if getChar() then
		getChar():FindFirstChildOfClass('Humanoid'):UnequipTools()
	end
end)

cmd.add({"equiptool","etool"},{"equiptool (etool)","Equip a specific tool by name or selection"},function(...)
	local char, backpack, tools = originalIO.gatherPlayerTools()
	if not char or not backpack then
		DoNotif("Could not find your character or backpack.", 2)
		return
	end

	if #tools == 0 then
		DoNotif("You do not have any tools to equip.", 2)
		return
	end

	local rawInput = Concat({...}, " ")
	rawInput = (type(rawInput) == "string") and rawInput:gsub("^%s+", ""):gsub("%s+$", "") or ""

	if rawInput ~= "" then
		const match = originalIO.findToolByName(tools, rawInput)
		if match then
			originalIO.equipToolInstance(match)
		else
			DoNotif(Format("No tools matching '%s' found.", rawInput), 2)
		end
		return
	end

	if type(Popup) ~= "function" then
		DoNotif("Popup UI is unavailable in this session. Provide a tool name instead.", 3)
		return
	end

	const buttons = originalIO.buildToolButtons(tools, function(toolRef)
		originalIO.equipToolInstance(toolRef)
	end)

	Popup({
		Title = "Equip Tool",
		Description = "Select a tool to equip.",
		Buttons = buttons
	})
end)

cmd.add({"loopequiptool","lequiptool","loopet"},{"loopequiptool <tool name>","Keeps a specific tool equipped until disabled"},function(...)
	local char, backpack, tools = originalIO.gatherPlayerTools()
	if not char or not backpack then
		DoNotif("Could not find your character or backpack.", 2)
		return
	end

	if #tools == 0 then
		DoNotif("You do not have any tools to loop equip.", 2)
		return
	end

	local rawInput = Concat({...}, " ")
	rawInput = (type(rawInput) == "string") and rawInput:gsub("^%s+", ""):gsub("%s+$", "") or ""

	if rawInput ~= "" then
		const match = originalIO.findToolByName(tools, rawInput)
		if match then
			originalIO.startLoopForTool(match)
		else
			DoNotif(Format("No tools matching '%s' found.", rawInput), 2)
		end
		return
	end

	if type(Popup) ~= "function" then
		DoNotif("Popup UI is unavailable in this session. Provide a tool name instead.", 3)
		return
	end

	const buttons = originalIO.buildToolButtons(tools, function(toolRef)
		originalIO.startLoopForTool(toolRef)
	end)

	Popup({
		Title = "Loop Equip Tool",
		Description = "Select a tool to keep equipped.",
		Buttons = buttons
	})
end)

cmd.add({"unloopequiptool","unloopet","unlequiptool"},{"unloopequiptool","Stops the loop equip behaviour"},function()
	originalIO.stopEquipToolLoop()
end)

cmd.add({"multitool","mtool"},{"multitool (mtool)","Allows stacking equipped tools from your inventory"},function(mode)
	const arg = type(mode) == "string" and Lower(mode) or ""
	if arg == "off" or arg == "false" or arg == "0" then
		if MultiToolCons.enabled then
			originalIO.stopMultiTool()
		else
			DoNotif("Multitool is already disabled.", 2)
		end
		return
	end

	if MultiToolCons.enabled then
		DoNotif("Multitool is already enabled. Use unmultitool to disable.", 2)
		return
	end

	originalIO.startMultiTool()
end)

cmd.add({"unmultitool","nomultitool"},{"unmultitool (nomultitool)","Disables multitool mode"},function()
	if MultiToolCons.enabled then
		originalIO.stopMultiTool()
	else
		DoNotif("Multitool is already disabled.", 2)
	end
end)

bangLoop = nil
bangAnim = nil
bangDied = nil
doBang = nil
BANGPARTS = {}
bangWeld = nil

originalIO.stopBang = function()
	if bangWeld then bangWeld:Destroy() bangWeld = nil end
	NAlib.disconnect("bang_loop")
	if doBang then doBang:Stop() doBang = nil end
	if bangAnim then bangAnim:Destroy() bangAnim = nil end
	if bangDied then bangDied:Disconnect() bangDied = nil end
	for _, p in BANGPARTS do pcall(function() p:Destroy() end) end
	BANGPARTS = {}
end

cmd.addRestricted({"bang", "fuck"}, {"bang <player> <number> (fuck)", "fucks the player by attaching to them"}, function(h, d)
	originalIO.stopBang()
	const speed = d or 10
	const targets = h and h ~= "" and getPlr(h) or {}
	const plr = targets[1]
	if h and h ~= "" and not plr then return DoNotif("No targets found", 2) end
	const targetChar = plr and plr.Character
	const targetRoot = targetChar and getRoot(targetChar)
	if not targetRoot then return end

	bangAnim = InstanceNew("Animation")
	bangAnim.AnimationId = not IsR15(Services.Players.LocalPlayer) and "rbxassetid://148840371" or "rbxassetid://5918726674"
	const hum = getHum()
	if not hum then return end
	doBang = hum:LoadAnimation(bangAnim)
	doBang:Play(0.1, 1, 1)
	doBang:AdjustSpeed(speed)

	bangWeld = NAmanage.WeldToPlayerPart(targetRoot, CFrame.new(0, 0, 1.1), LocalPlayer, nil)
	if not bangWeld then return originalIO.stopBang() end
	bangDied = NAmanage.ConnectHumanoidDeath(hum, originalIO.stopBang)
end, true)

cmd.addRestricted({"unbang", "unfuck"}, {"unbang (unfuck)", "Unbangs the player"}, function()
	originalIO.stopBang()
end)

carpetLoop = nil
carpetAnim = nil
carpetTrack = nil
carpetDied = nil
CARPETPARTS = {}
carpetWeld = nil
originalIO.stopCarpet=function()
	if carpetWeld then carpetWeld:Destroy() carpetWeld = nil end
	NAlib.disconnect("carpet_loop")
	if carpetDied then carpetDied:Disconnect() carpetDied = nil end
	if carpetTrack then carpetTrack:Stop() carpetTrack = nil end
	if carpetAnim then carpetAnim:Destroy() carpetAnim = nil end
	for _, part in CARPETPARTS do pcall(function() part:Destroy() end) end
	CARPETPARTS = {}
	const char = getChar()
	const root = char and getRoot(char)
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end
	const hum = getHum(char)
	if hum then hum.Sit = false hum.PlatformStand = false end
end

cmd.add({"carpet"}, {"carpet <player>", "Be someone's carpet"}, function(username)
	if not IsR6() then return DoNotif("This command requires the R6 rig type", 3) end
	originalIO.stopCarpet()
	const targets = username and username ~= "" and getPlr(username) or {}
	if username and username ~= "" and #targets == 0 then return DoNotif("No targets found", 2) end
	const targetPlayer = targets[1]
	const targetRoot = targetPlayer and targetPlayer.Character and getRoot(targetPlayer.Character)
	const character = getChar()
	const humanoid = character and getHum(character)
	if not (targetRoot and character and humanoid) then return end

	carpetAnim = InstanceNew("Animation")
	carpetAnim.AnimationId = "rbxassetid://282574440"
	carpetTrack = humanoid:LoadAnimation(carpetAnim)
	carpetTrack:Play(0.1, 1, 1)
	carpetWeld = NAmanage.WeldToPlayerPart(targetRoot, CFrame.new(), LocalPlayer, nil)
	if not carpetWeld then return originalIO.stopCarpet() end
	carpetDied = NAmanage.ConnectHumanoidDeath(humanoid, originalIO.stopCarpet)
end, true)

cmd.add({"uncarpet", "nocarpet"}, {"uncarpet (nocarpet)", "Undoes carpet"}, function()
	originalIO.stopCarpet()
end)

climbPart = nil
climbLoop = nil
originalIO.stopClimb=function()
	if climbLoop then
		climbLoop:Disconnect()
		climbLoop = nil
	end
	NAlib.disconnect("climb_loop")
	if climbPart then
		climbPart:Destroy()
		climbPart = nil
	end
end

cmd.add({"climb"}, {"climb", "Allows you to climb while in air"}, function()
	originalIO.stopClimb()

	const char = getChar()
	const root = char and getRoot(char)
	if not (char and root) then
		return DoNotif and DoNotif("Your character is unavailable.", 3) or nil
	end

	climbPart = InstanceNew("TrussPart")
	climbPart.Size = Vector3.new(2, 10, 2)
	climbPart.Transparency = 1
	climbPart.CanCollide = true
	climbPart.Anchored = true
	climbPart.Name = NAmanage.GetSessionInstanceName("ClimbPart")
	climbPart.Parent = Services.Workspace

	climbLoop = NAlib.reconnect("climb_loop", Services.RunService.Heartbeat:Connect(function()
		NACaller(function()
			if not climbPart or not climbPart.Parent then
				return originalIO.stopClimb()
			end
			const c = getChar()
			const r = c and getRoot(c)
			if not r then
				return originalIO.stopClimb()
			end
			climbPart.CFrame = r.CFrame * CFrame.new(0, 0, -1.5)
		end)
	end))
end)

cmd.add({"unclimb"}, {"unclimb", "Disables climb"}, function()
	originalIO.stopClimb()
end)

inversebangLoop = nil
inversebangAnim = nil
inversebangAnim2 = nil
inversebangDied = nil
doInversebang = nil
doInversebang2 = nil
INVERSEBANGPARTS = {}
inversebangWeld = nil

function stopInversebang()
	if inversebangWeld then inversebangWeld:Destroy() inversebangWeld = nil end
	NAlib.disconnect("inversebang_loop")
	if inversebangDied then inversebangDied:Disconnect() inversebangDied = nil end
	if doInversebang then doInversebang:Stop() doInversebang = nil end
	if doInversebang2 then doInversebang2:Stop() doInversebang2 = nil end
	if inversebangAnim then inversebangAnim:Destroy() inversebangAnim = nil end
	if inversebangAnim2 then inversebangAnim2:Destroy() inversebangAnim2 = nil end
	for _, p in INVERSEBANGPARTS do pcall(function() p:Destroy() end) end
	INVERSEBANGPARTS = {}
end

cmd.addRestricted({"inversebang","ibang","inverseb"},{"inversebang <player> <number>","you're the one getting fucked today ;)"},function(h,d)
	stopInversebang()
	const speed = d or 10
	const targets = h and h ~= "" and getPlr(h) or {}
	const plr = targets[1]
	if h and h ~= "" and not plr then return DoNotif("No targets found", 2) end
	const targetRoot = plr and plr.Character and getRoot(plr.Character)
	if not targetRoot then return end

	inversebangAnim = InstanceNew("Animation")
	const isR15 = IsR15(Services.Players.LocalPlayer)
	if not isR15 then
		inversebangAnim.AnimationId = "rbxassetid://189854234"
		inversebangAnim2 = InstanceNew("Animation")
		inversebangAnim2.AnimationId = "rbxassetid://106772613"
	else
		inversebangAnim.AnimationId = "rbxassetid://10714360343"
		inversebangAnim2 = nil
	end
	const hum = getHum()
	if not hum then return end
	doInversebang = hum:LoadAnimation(inversebangAnim)
	doInversebang:Play(0.1,1,1)
	doInversebang:AdjustSpeed(speed)
	if not isR15 and inversebangAnim2 then
		doInversebang2 = hum:LoadAnimation(inversebangAnim2)
		doInversebang2:Play(0.1,1,1)
		doInversebang2:AdjustSpeed(speed)
	end

	inversebangWeld = NAmanage.WeldToPlayerPart(targetRoot, CFrame.new(0,0,-1.3), LocalPlayer, nil)
	if not inversebangWeld then return stopInversebang() end
	inversebangDied = NAmanage.ConnectHumanoidDeath(hum, stopInversebang)
end,true)

cmd.addRestricted({"uninversebang","unibang","uninverseb"},{"uninversebang","no more fun"},function()
	stopInversebang()
end)

sussyID = "rbxassetid://106772613"
susTrack, susCONN = nil, nil

cmd.addRestricted({"suslay", "laysus"}, {"suslay (laysus)", "Lay down in a suspicious way"}, function()
	if not IsR6() then return DoNotif("R6 only") end

	if susTrack then
		susTrack:Stop()
		susTrack = nil
	end

	if susCONN then
		susCONN:Disconnect()
		susCONN = nil
	end

	const hum = getHum()
	const root = hum.RootPart

	hum.Sit = true
	Wait(0.1)
	NAmanage.UG_setRootCFrame(root, (NAmanage.UG_clientCFrame(root) or root.CFrame) * CFrame.Angles(math.pi * 0.5, 0, 0))

	for _, a in hum:GetPlayingAnimationTracks() do
		a:Stop()
	end

	const anim = InstanceNew("Animation")
	anim.AnimationId = sussyID
	susTrack = hum:LoadAnimation(anim)
	susTrack:Play()

	susCONN = hum:GetPropertyChangedSignal("Jump"):Connect(function()
		if susTrack then
			susTrack:Stop()
			susTrack = nil
		end
		if susCONN then
			susCONN:Disconnect()
			susCONN = nil
		end
	end)
end)

cmd.addRestricted({"unsuslay"}, {"unsuslay", "Stand up from the sussy lay"}, function()
	const hum = getHum()
	if hum then
		NAmanage.LaunchHumanoid(hum)
	end

	if susTrack then
		susTrack:Stop()
		susTrack = nil
	end

	if susCONN then
		susCONN:Disconnect()
		susCONN = nil
	end
end)

cmd.addRestricted({"jerk", "jork"}, {"jerk (jork)", "jorking it"}, function()
	const humanoid = getHum()
	const backpack = getBp()
	if not humanoid or not backpack then return end

	const tool = InstanceNew("Tool")
	tool.Name = "Jerk"
	tool.ToolTip = "oh yes i am feeling it COMING OUT AHHHHHHHHHHHHHHHHHHHHH"
	tool.RequiresHandle = false
	tool.Parent = backpack

	local jorkin = false
	local track = nil

	const function stopTomfoolery()
		jorkin = false
		if track then
			track:Stop()
			track = nil
		end
	end

	tool.Equipped:Connect(function() jorkin = true end)
	tool.Unequipped:Connect(stopTomfoolery)
	NAmanage.ConnectHumanoidDeath(humanoid, stopTomfoolery)

	while Wait() do
		if not jorkin then continue end

		if not track then
			const anim = InstanceNew("Animation")
			anim.AnimationId = not IsR15() and "rbxassetid://72042024" or "rbxassetid://698251653"
			track = humanoid:LoadAnimation(anim)
		end

		track:Play()
		track:AdjustSpeed(IsR15() and 0.7 or 0.65)
		track.TimePosition = 0.6
		Wait(0.2)
		while track and track.TimePosition < (not IsR15() and 0.65 or 0.7) do Wait(0.2) end
		if track then
			track:Stop()
			track = nil
		end
	end
end)

huggiePARTS = {}
hugUI = nil
currentHugTracks = {}
currentHugTarget = nil
currentHugWeld = nil
hugFromFront = false
hugModeEnabled = false

originalIO.stopCurrentHugWeld = function()
	if currentHugWeld then
		currentHugWeld:Destroy()
		currentHugWeld = nil
	end
end

originalIO.startCurrentHugWeld = function(targetCharacter)
	originalIO.stopCurrentHugWeld()
	if not targetCharacter then return false end
	const targetHRP = getRoot(targetCharacter)
	if not targetHRP then return false end
	local offset
	if hugFromFront then
		offset = CFrame.new(0, 0, -1.5) * CFrame.Angles(0, math.pi, 0)
	else
		offset = CFrame.new(0, 0, 1.5)
	end
	currentHugWeld = NAmanage.WeldToPlayerPart(targetHRP, offset, LocalPlayer, nil)
	return currentHugWeld ~= nil
end

cmd.add({"hug", "clickhug"}, {"hug (clickhug)", "huggies time (click on a target to hug)"}, function()
	if not IsR6() then return DoNotif("command requires R6") end
	const mouse = NAmanage.GetMouse(LocalPlayer)
	NAlib.disconnect("hug_toggle")
	NAlib.disconnect("hug_side")
	NAlib.disconnect("hug_click")
	NAlib.disconnect("hug_plat")
	originalIO.stopCurrentHugWeld()
	for _, track in currentHugTracks do NACaller(function() track:Stop() end) end
	currentHugTracks = {}
	if hugUI then hugUI:Destroy() end
	hugFromFront = false
	currentHugTarget = nil
	hugModeEnabled = false
	for _, part in huggiePARTS do pcall(function() part:Destroy() end) end
	huggiePARTS = {}

	hugUI = InstanceNew("ScreenGui")
	hugUI.Name = "HugModeUI"
	NAgui.NaProtectUI(hugUI)
	const toggleHugButton = InstanceNew("TextButton")
	toggleHugButton.AnchorPoint = Vector2.new(0.5, 0)
	toggleHugButton.Size = UDim2.new(0, 150, 0, 50)
	toggleHugButton.Position = UDim2.new(0.4, 0, 0.1, 0)
	toggleHugButton.Text = "Hug Mode: OFF"
	toggleHugButton.TextSize = 14
	toggleHugButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	toggleHugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleHugButton.Parent = hugUI
	const sideToggleButton = InstanceNew("TextButton")
	sideToggleButton.AnchorPoint = Vector2.new(0.5, 0)
	sideToggleButton.Size = UDim2.new(0, 150, 0, 50)
	sideToggleButton.Position = UDim2.new(0.6, 0, 0.1, 0)
	sideToggleButton.Text = "Hug Side: Back"
	sideToggleButton.TextSize = 14
	sideToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	sideToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	sideToggleButton.Parent = hugUI
	const uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = toggleHugButton
	const sideUICorner = InstanceNew("UICorner")
	sideUICorner.CornerRadius = UDim.new(0, 6)
	sideUICorner.Parent = sideToggleButton
	NAgui.draggerV2(toggleHugButton)
	NAgui.draggerV2(sideToggleButton)

	const function performHug(targetCharacter)
		currentHugTarget = targetCharacter
		for _, track in currentHugTracks do NACaller(function() track:Stop() end) end
		currentHugTracks = {}
		const humanoid = getPlrHum(LocalPlayer.Character)
		if humanoid then
			const anim1 = InstanceNew("Animation")
			anim1.AnimationId = "rbxassetid://283545583"
			const track1 = humanoid:LoadAnimation(anim1)
			const anim2 = InstanceNew("Animation")
			anim2.AnimationId = "rbxassetid://225975820"
			const track2 = humanoid:LoadAnimation(anim2)
			Insert(currentHugTracks, track1)
			Insert(currentHugTracks, track2)
			track1:Play()
			track2:Play()
		end
		originalIO.startCurrentHugWeld(targetCharacter)
	end

	NAlib.connect("hug_toggle", MouseButtonFix(toggleHugButton, function()
		hugModeEnabled = not hugModeEnabled
		toggleHugButton.Text = hugModeEnabled and "Hug Mode: ON" or "Hug Mode: OFF"
		if not hugModeEnabled then
			originalIO.stopCurrentHugWeld()
			for _, track in currentHugTracks do NACaller(function() track:Stop() end) end
			currentHugTracks = {}
			currentHugTarget = nil
		end
	end))

	NAlib.connect("hug_side", MouseButtonFix(sideToggleButton, function()
		hugFromFront = not hugFromFront
		sideToggleButton.Text = hugFromFront and "Hug Side: Front" or "Hug Side: Back"
		if hugModeEnabled and currentHugTarget then
			originalIO.startCurrentHugWeld(currentHugTarget)
		end
	end))

	NAlib.connect("hug_click", mouse.Button1Down:Connect(function()
		if not hugModeEnabled then return end
		const target = NAmanage.GetMouseTargetPart(mouse, { LocalPlayer and LocalPlayer.Character }, 1024)
		if not target then return end
		const targetCharacter = NAmanage.ResolveHumanoidModelFromPart(target)
		const targetPlayer = targetCharacter and __lt.cm("Players", "GetPlayerFromCharacter", targetCharacter)
		if targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer.Character then
			performHug(targetPlayer.Character)
		end
	end))
end)

cmd.add({"unhug"}, {"unhug", "no huggies :("}, function()
	NAlib.disconnect("hug_toggle")
	NAlib.disconnect("hug_side")
	NAlib.disconnect("hug_click")
	NAlib.disconnect("hug_plat")
	originalIO.stopCurrentHugWeld()
	for _, track in currentHugTracks do NACaller(function() track:Stop() end) end
	currentHugTracks = {}
	currentHugTarget = nil
	hugFromFront = false
	hugModeEnabled = false
	for _, part in huggiePARTS do pcall(function() part:Destroy() end) end
	huggiePARTS = {}
	if hugUI then hugUI:Destroy() hugUI = nil end
end)

glueloop = {}

cmd.add({"glue","loopgoto","lgoto"},{"glue <player>","Loop teleport to a player"},function(...)
	const players = getPlr((...))
	for _, p in next, players do
		const name = p.Name
		if glueloop[name] then glueloop[name]:Destroy() end
		const targetRoot = p.Character and getRoot(p.Character)
		if targetRoot then
			glueloop[name] = NAmanage.WeldToPlayerPart(targetRoot, CFrame.new(), LocalPlayer, nil)
		end
	end
end,true)

cmd.add({"unglue","unloopgoto","noloopgoto"},{"unglue","Stops teleporting you to a player"},function()
	for name, weld in glueloop do
		if weld and weld.Destroy then weld:Destroy() end
		NAlib.disconnect("glue_loop_"..name)
	end
	glueloop = {}
end)

glueBACKER = {}

cmd.add({"glueback","loopbehind","lbehind"},{"glueback <player>","Loop teleport behind a player"},function(...)
	const targets = getPlr((...))
	for _, target in next, targets do
		const name = target.Name
		if glueBACKER[name] then glueBACKER[name]:Destroy() end
		const targetRoot = target.Character and getRoot(target.Character)
		if targetRoot then
			glueBACKER[name] = NAmanage.WeldToPlayerPart(targetRoot, CFrame.new(0,0,3), LocalPlayer, nil)
		end
	end
end,true)

cmd.add({"unglueback","unloopbehind","unlbehind"},{"unglueback","Stops teleporting you to a player"},function()
	for name, weld in glueBACKER do
		if weld and weld.Destroy then weld:Destroy() end
		NAlib.disconnect("glueback_loop_"..name)
	end
	glueBACKER = {}
end)

cmd.add({"spook", "scare"}, {"spook <player|npc:filter> (scare)", "Teleports next to a player or NPC for a few seconds"}, function(...)
	const username = (...)
	const targets = getPlr(username)
	for _, plr in next, targets do
		const char = getChar()
		const root = getRoot(char)
		const oldCF = NAmanage.UG_clientCFrame(root) or root.CFrame
		const distancepl = 2
		if getPlrHum(plr) then
			const targetRoot = getRoot(NAmanage.PlayerArgChar(plr))
			if targetRoot then
				const nextCF = targetRoot.CFrame + targetRoot.CFrame.LookVector * distancepl
				NAmanage.UG_setClientCFrame(root, nextCF)
				NAmanage.UG_setClientCFrame(root, CFrame.new(nextCF.Position, targetRoot.Position))
				Wait(0.5)
				NAmanage.UG_setClientCFrame(root, oldCF)
			end
		end
	end
end, true)

loopspook = false

cmd.add({"loopspook","loopscare"},{"loopspook <player>","Teleports next to a player repeatedly"},function(...)
	const input = (...)
	const targets = NAmanage.PersistentPlayerRefs(input)
	loopspook = true

	SpawnCall(function()
		while loopspook do
			for _, ref in targets do
				const target = NAmanage.ResolvePersistentPlayer(ref)
				if target and getPlrHum(target) then
					const lc = getChar()
					const lr = getRoot(lc)
					const tr = getRoot(target.Character)
					if lr and tr then
						const old = NAmanage.UG_clientCFrame(lr) or lr.CFrame
						const nextCF = tr.CFrame + tr.CFrame.LookVector * 2
						NAmanage.UG_setClientCFrame(lr, nextCF)
						NAmanage.UG_setClientCFrame(lr, CFrame.new(nextCF.Position, tr.Position))
						Wait(0.5)
						NAmanage.UG_setClientCFrame(lr, old)
					end
				end
			end
			Wait(0.3)
		end
	end)
end,true)

cmd.add({"unloopspook","unloopscare"},{"unloopspook","Stops the loopspook command"},function()
	loopspook = false
end)

Airwalker, awPart = nil, nil
NAStuff.airwalk = {
	Vars = {
		keybinds = {
			Increase = Enum.KeyCode.E,
			Decrease = Enum.KeyCode.Q,
		},
		decrease = false,
		increase = false,
		offset = 0,
		isTyping = false,
	},
	connections = {},
	guis = {},
	mouse = nil,
	previousTargetFilter = nil,
	targetFilterPart = nil,
	targetFilterCaptured = false,
}

NAmanage.AirwalkRestoreTargetFilter = function()
	const state = NAStuff.airwalk
	const mouse = state and state.mouse
	if state and state.targetFilterCaptured == true and mouse then
		pcall(function()
			const current = mouse.TargetFilter
			if current == state.targetFilterPart or current == nil then
				mouse.TargetFilter = state.previousTargetFilter
			end
		end)
	end
	if state then
		state.mouse = nil
		state.previousTargetFilter = nil
		state.targetFilterPart = nil
		state.targetFilterCaptured = false
	end
end

NAmanage.AirwalkApplyTargetFilter = function(part)
	NAmanage.AirwalkRestoreTargetFilter()
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return false
	end
	const player = Services.Players and Services.Players.LocalPlayer
	if not player then
		return false
	end
	local mouse
	local okMouse = pcall(function()
		mouse = type(NAmanage.GetMouse) == "function" and NAmanage.GetMouse(player) or player:GetMouse()
	end)
	if not okMouse or not mouse then
		return false
	end
	local previous
	const okRead = pcall(function()
		previous = mouse.TargetFilter
	end)
	if not okRead then
		return false
	end
	const state = NAStuff.airwalk
	state.mouse = mouse
	state.previousTargetFilter = previous
	state.targetFilterPart = part
	state.targetFilterCaptured = true
	const okSet = pcall(function()
		mouse.TargetFilter = part
	end)
	if not okSet then
		state.mouse = nil
		state.previousTargetFilter = nil
		state.targetFilterPart = nil
		state.targetFilterCaptured = false
		return false
	end
	return true
end

cmd.add({"airwalk", "float", "aw"}, {"airwalk (float, aw)", "Press space to go up, unairwalk to stop"}, function()
	DebugNotif(IsOnMobile and "Airwalk: ON" or "Airwalk: ON (Q And E)")
	if Airwalker then Airwalker:Disconnect() Airwalker = nil end
	NAlib.disconnect("airwalk_loop")
	NAmanage.AirwalkRestoreTargetFilter()
	if awPart then awPart:Destroy() awPart = nil end
	for _, conn in NAStuff.airwalk.connections do
		if conn then conn:Disconnect() end
	end
	NAStuff.airwalk.connections = {}
	for _, guiObject in NAStuff.airwalk.guis do
		if guiObject then guiObject:Destroy() end
	end
	NAStuff.airwalk.guis = {}
	NAStuff.airwalk.Vars.decrease = false
	NAStuff.airwalk.Vars.increase = false

	const function createButton(parent, text, position, callbackDown, callbackUp)
		const button = InstanceNew("TextButton")
		button.Name = "Airwalk" .. text .. "Button"
		button.Parent = parent
		button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		button.BackgroundTransparency = 0
		button.Position = position
		button.Size = UDim2.new(0.05, 0, 0.1, 0)
		button.Font = Enum.Font.Gotham
		if Font and type(Font.new) == "function" then
			local ok, font = pcall(Font.new, "rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			if ok and font then
				button.FontFace = font
			end
		end
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 18
		button.TextScaled = true
		button.AutoButtonColor = false

		const corner = InstanceNew("UICorner", button)
		corner.CornerRadius = UDim.new(0, 6)

		const stroke = InstanceNew("UIStroke", button)
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Thickness = 2

		const hoverEffect = function(isHovering)
			button.BackgroundColor3 = isHovering and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(45, 45, 45)
		end

		button.MouseEnter:Connect(function() hoverEffect(true) end)
		button.MouseLeave:Connect(function() hoverEffect(false) end)
		button.MouseButton1Down:Connect(callbackDown)
		button.MouseButton1Up:Connect(callbackUp)
		NAgui.draggerV2(button)

		return button
	end

	if IsOnMobile then
		if not NAmanage.waitForScreenGui(5) then
			DebugNotif("Airwalk: UI unavailable")
			return
		end

		NAStuff.airwalk.guis.down = createButton(NAStuff.NASCREENGUI, "DOWN", UDim2.new(0.9, 0, 0.7, 0), function() NAStuff.airwalk.Vars.decrease = true end, function() NAStuff.airwalk.Vars.decrease = false end)
		NAStuff.airwalk.guis.up = createButton(NAStuff.NASCREENGUI, "UP", UDim2.new(0.9, 0, 0.5, 0), function() NAStuff.airwalk.Vars.increase = true end, function() NAStuff.airwalk.Vars.increase = false end)
	else
		NAStuff.airwalk.connections.focused = Services.UserInputService.TextBoxFocused:Connect(function() NAStuff.airwalk.Vars.isTyping = true end)
		NAStuff.airwalk.connections.released = Services.UserInputService.TextBoxFocusReleased:Connect(function() NAStuff.airwalk.Vars.isTyping = false end)

		NAStuff.airwalk.connections.inputBegan = uis.InputBegan:Connect(function(input, gpe)
			if gpe or NAStuff.airwalk.Vars.isTyping then return end
			if input.KeyCode == NAStuff.airwalk.Vars.keybinds.Increase then NAStuff.airwalk.Vars.increase = true end
			if input.KeyCode == NAStuff.airwalk.Vars.keybinds.Decrease then NAStuff.airwalk.Vars.decrease = true end
		end)
		NAStuff.airwalk.connections.inputEnded = uis.InputEnded:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode == NAStuff.airwalk.Vars.keybinds.Increase then NAStuff.airwalk.Vars.increase = false end
			if input.KeyCode == NAStuff.airwalk.Vars.keybinds.Decrease then NAStuff.airwalk.Vars.decrease = false end
		end)
	end

	awPart = InstanceNew("Part", Services.Workspace)
	awPart.Size = Vector3.new(10, 2, 10)
	awPart.Transparency = 1
	awPart.Anchored = true
	awPart.CanCollide = true
	NAmanage.AirwalkApplyTargetFilter(awPart)

	Airwalker = NAlib.reconnect("airwalk_loop", Services.RunService.RenderStepped:Connect(function()
		if not awPart then Airwalker:Disconnect() return end

		const char = getChar()
		const root = getRoot(char)
		const hum = getHum(char)
		if not (char and root and hum) then return end

		const hrpY = root.Position.Y
		const hrpHalf = ((NAlib.isProperty(root, "Size") and root.Size.Y) or 2) * 0.5
		const partHalf = awPart.Size.Y * 0.5

		local feetFromRoot
		if IsR6() then
			feetFromRoot = hrpHalf + 2
			if hum.HipHeight and hum.HipHeight > 0 then
				feetFromRoot = hrpHalf + hum.HipHeight
			end
		else
			feetFromRoot = hrpHalf + (hum.HipHeight or 2)
		end

		const baseOffset = feetFromRoot + partHalf
		const delta = (NAStuff.airwalk.Vars.decrease and 1.5) or (NAStuff.airwalk.Vars.increase and -1.5) or 0
		NAStuff.airwalk.Vars.offset = math.max(0, baseOffset + delta)

		awPart.CFrame = CFrame.new(root.Position.X, hrpY - NAStuff.airwalk.Vars.offset, root.Position.Z)
	end))
end)

cmd.add({"unairwalk", "unfloat", "unaw"}, {"unairwalk (unfloat, unaw)", "Stops the airwalk command"}, function()
	if Airwalker then Airwalker:Disconnect() Airwalker = nil end
	NAlib.disconnect("airwalk_loop")
	NAmanage.AirwalkRestoreTargetFilter()
	if awPart then awPart:Destroy() awPart = nil end
	for _, conn in NAStuff.airwalk.connections do
		if conn then conn:Disconnect() end
	end
	NAStuff.airwalk.connections = {}
	for _, guiObject in NAStuff.airwalk.guis do
		if guiObject then guiObject:Destroy() end
	end
	NAStuff.airwalk.guis = {}
	DebugNotif("Airwalk: OFF")
end)

NAStuff.airMomentum = NAStuff.airMomentum or {
	enabled = false,
	connections = {},
	root = nil,
	hum = nil,
	flatMask = Vector3.new(1, 0, 1),
	upMask = Vector3.new(0, 1, 0),
	config = {
		airAcc = 140,
		airSpd = 70,
		airDrag = 2.5,
		keep = 0.02,
	},
}

NAmanage.AirMomentumFlat = function(v)
	return v * NAStuff.airMomentum.flatMask
end

NAmanage.AirMomentumUp = function(v)
	return v * NAStuff.airMomentum.upMask
end

NAmanage.AirMomentumDisconnect = function(key)
	const conn = NAStuff.airMomentum.connections[key]
	if conn then
		conn:Disconnect()
		NAStuff.airMomentum.connections[key] = nil
	end
end

NAmanage.AirMomentumStopSim = function()
	NAmanage.AirMomentumDisconnect("sim")
end

NAmanage.AirMomentumSim = function(dt)
	const state = NAStuff.airMomentum
	const root = state.root
	const hum = state.hum
	if not state.enabled or not root or not hum or not root.Parent then
		NAmanage.AirMomentumStopSim()
		return
	end

	const humState = hum:GetState()
	if humState ~= Enum.HumanoidStateType.Freefall and humState ~= Enum.HumanoidStateType.Jumping then
		NAmanage.AirMomentumStopSim()
		return
	end

	const velY = NAmanage.AirMomentumUp(root.AssemblyLinearVelocity)
	local velXZ = NAmanage.AirMomentumFlat(root.AssemblyLinearVelocity)
	const move = NAmanage.AirMomentumFlat(hum.MoveDirection)

	if move.Magnitude > 0.001 then
		const wish = move.Unit * state.config.airSpd
		local diff = wish - velXZ
		const add = state.config.airAcc * dt
		if diff.Magnitude > add then
			diff = diff.Unit * add
		end
		velXZ += diff
	else
		const speed = velXZ.Magnitude
		if speed > 0 then
			const drop = state.config.airDrag * dt * speed + state.config.keep
			const newSpeed = math.max(0, speed - drop)
			velXZ = newSpeed > 0 and velXZ.Unit * newSpeed or Vector3.zero
		end
	end

	if velXZ.Magnitude > state.config.airSpd then
		velXZ = velXZ.Unit * state.config.airSpd
	end

	root.AssemblyLinearVelocity = velXZ + velY
end

NAmanage.AirMomentumStartSim = function()
	const state = NAStuff.airMomentum
	if not state.enabled or state.connections.sim or not state.root or not state.hum then
		return
	end

	const signal = Services.RunService.PreSimulation or Services.RunService.Heartbeat
	state.connections.sim = signal:Connect(NAmanage.AirMomentumSim)
end

NAmanage.AirMomentumHandleState = function(_, newState)
	if newState == Enum.HumanoidStateType.Jumping or newState == Enum.HumanoidStateType.Freefall then
		NAmanage.AirMomentumStartSim()
	else
		NAmanage.AirMomentumStopSim()
	end
end

NAmanage.AirMomentumBindCharacter = function(char)
	const state = NAStuff.airMomentum
	NAmanage.AirMomentumStopSim()
	NAmanage.AirMomentumDisconnect("state")
	NAmanage.AirMomentumDisconnect("died")
	state.root = nil
	state.hum = nil

	if not state.enabled or not char or not char.Parent then
		return
	end

	const hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 5)
	const root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:WaitForChild("HumanoidRootPart", 5)
	if not hum or not root then
		return
	end

	state.hum = hum
	state.root = root
	state.connections.state = hum.StateChanged:Connect(NAmanage.AirMomentumHandleState)
	state.connections.died = hum.Died:Connect(NAmanage.AirMomentumStopSim)

	const currentState = hum:GetState()
	if currentState == Enum.HumanoidStateType.Jumping or currentState == Enum.HumanoidStateType.Freefall then
		NAmanage.AirMomentumStartSim()
	end
end

NAmanage.DisableAirMomentum = function(notify)
	const state = NAStuff.airMomentum
	state.enabled = false
	NAmanage.AirMomentumStopSim()
	NAmanage.AirMomentumDisconnect("state")
	NAmanage.AirMomentumDisconnect("died")
	NAmanage.AirMomentumDisconnect("charAdded")
	state.root = nil
	state.hum = nil
	if notify ~= false then
		DebugNotif("Air momentum: OFF")
	end
end

NAmanage.EnableAirMomentum = function()
	const state = NAStuff.airMomentum
	state.enabled = true
	NAmanage.AirMomentumDisconnect("charAdded")
	state.connections.charAdded = LocalPlayer.CharacterAdded:Connect(function(char)
		Defer(NAmanage.AirMomentumBindCharacter, char)
	end)
	NAmanage.AirMomentumBindCharacter(getChar())
	DebugNotif("Air momentum: ON")
end

cmd.add({"airmomentum", "amomentum", "aircontrol"}, {"airmomentum (amomentum, aircontrol)", "Overrides default in-air horizontal movement with custom air control"}, function()
	NAmanage.EnableAirMomentum()
end)

cmd.add({"unairmomentum", "unamomentum", "unaircontrol"}, {"unairmomentum (unamomentum, unaircontrol)", "Stops the custom air momentum command"}, function()
	NAmanage.DisableAirMomentum()
end)

bringc = {}

NAmanage.parseBringDistance=function(args, defaultDistance)
	const distance = tonumber(args[#args])
	if distance then
		table.remove(args, #args)
		return math.clamp(distance, 0, 1000)
	end
	return defaultDistance or 0
end

NAmanage.bringOffsetCFrame=function(cf, distance)
	if not cf then return nil end
	distance = tonumber(distance) or 0
	return cf + cf.LookVector * distance
end

cmd.add({"cbring", "clientbring", "clientb"}, {"cbring <player|npc:filter> [distance]", "Brings a player or NPC once on your client"}, function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 3)
	const username = args[1]
	const target = getPlr(username)
	if #target == 0 then return end
	const localChar = getChar()
	if not localChar then return end
	const localRoot = getRoot(localChar)
	if not localRoot then return end
	for _, plr in next, target do
		const targetChar = getPlrChar(plr)
		if targetChar then
			const targetRoot = getRoot(targetChar)
			if targetRoot then
				targetRoot.CFrame = NAmanage.bringOffsetCFrame(localRoot.CFrame, distance)
			end
		end
	end
end, true)

cmd.add({"loopcbring", "loopclientb", "loppclientb", "loopclientbring", "lcbring", "lclientb"}, {"loopcbring <player|npc:filter> [distance]", "Continuously brings a player or NPC on your client"}, function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 3)
	const username = args[1]
	const target = getPlr(username)
	if #target == 0 then return end
	for _, conn in bringc do
		conn:Disconnect()
	end
	bringc = {}
	NAlib.disconnect("cbring")
	if NAlib.isConnected("cbnoclip") then
		NAlib.disconnect("cbnoclip")
	end
	NAlib.connect("cbnoclip", Services.RunService.RenderStepped:Connect(function()
		const char = getChar()
		if not char then return end
		for _, descendant in char:QueryDescendants("BasePart") do
			descendant.CanCollide = false
		end
	end))
	for _, plr in next, target do
		if not plr then return end
		Insert(bringc, NAlib.connect("cbring", Services.RunService.RenderStepped:Connect(function()
			const targetChar = getPlrChar(plr)
			const localChar = getChar()
			if targetChar and localChar then
				const targetRoot = getRoot(targetChar)
				const localRoot = getRoot(localChar)
				if targetRoot and localRoot then
					targetRoot.CFrame = NAmanage.bringOffsetCFrame(localRoot.CFrame, distance)
				end
			end
		end)))
	end
end, true)

cmd.add({"unloopcbring", "unloopclientb", "unloopcientb", "unlcbring", "unlclientb", "uncbring", "unclientb"}, {"unloopcbring", "Disable looped client bring"}, function()
	for _, conn in bringc do
		conn:Disconnect()
	end
	bringc = {}
	NAlib.disconnect("cbring")
	if NAlib.isConnected("cbnoclip") then
		NAlib.disconnect("cbnoclip")
	end
end)

cmd.add({"mute", "muteboombox"}, {"mute <player|npc:filter> (muteboombox)", "Mutes sounds from a player or NPC"}, function(...)
	const uuuu = ...
	const pp = getPlr(uuuu)
	if #pp == 0 then return end

	const function NONOSOUND(container)
		for _, descendant in NAmanage.QueryDescendants(container, "Sound") do
			if descendant.Playing then
				descendant.Playing = false
			end
		end
	end

	for _, plr in pp do
		const targetChar = plr and NAmanage.PlayerArgChar(plr)
		if targetChar then
			NONOSOUND(targetChar)
		end

		const BK = plr:IsA("Player") and plr:FindFirstChildOfClass("Backpack") or nil
		if BK then
			NONOSOUND(BK)
		end
	end
end, true)

NAmanage.GetOffsetWalkState = function()
	if type(NAStuff.OffsetWalkState) ~= "table" then
		NAStuff.OffsetWalkState = {}
	end
	const state = NAStuff.OffsetWalkState
	state.interval = math.max(0.01, tonumber(state.interval) or 0.1)
	state.bindName = tostring(state.bindName or "NA_OffsetWalkReplication")
	state.externalTeleportDistance = math.max(0.5, tonumber(state.externalTeleportDistance) or 4)
	return state
end

NAmanage.OffsetWalkCFrameNear = function(a, b, distance)
	return typeof(a) == "CFrame" and typeof(b) == "CFrame"
		and (a.Position - b.Position).Magnitude <= (distance or 0.05)
end

NAmanage.OffsetWalkAdoptExternalCFrame = function(root, observed)
	const state = NAmanage.GetOffsetWalkState()
	if not root or typeof(observed) ~= "CFrame" then
		return false
	end
	if typeof(state.localCFrame) ~= "CFrame" then
		state.localCFrame = observed
		state.serverCFrame = observed
		state.lastBurst = os.clock()
		return true
	end
	if NAmanage.OffsetWalkCFrameNear(observed, state.serverCFrame) then
		return false
	end
	const dynamicDistance = math.max(state.externalTeleportDistance, (tonumber(state.speed) or 16) * 0.04)
	if (observed.Position - state.localCFrame.Position).Magnitude < dynamicDistance then
		return false
	end
	state.localCFrame = observed
	state.serverCFrame = observed
	state.lastBurst = os.clock()
	state.lastWriteCFrame = observed
	return true
end

NAmanage.OffsetWalkRestoreDirectSpeed = function(state, hum)
	state = type(state) == "table" and state or NAmanage.GetOffsetWalkState()
	hum = hum or getHum()
	if not hum then
		return
	end
	local restore = nil
	if NAStuff.SafeSpeedMethod == false then
		if NAStuff.loopws and tonumber(_na_env.NamelessWs) then
			restore = tonumber(_na_env.NamelessWs)
		elseif tonumber(_na_env.NamelessSpeed) then
			restore = tonumber(_na_env.NamelessSpeed)
		end
	end
	restore = restore or tonumber(state.originalWalkSpeed)
	if restore then
		pcall(function()
			hum.WalkSpeed = restore
		end)
	end
end

NAmanage.StopOffsetWalk = function(silent)
	const state = NAmanage.GetOffsetWalkState()
	const localCFrame = state.localCFrame
	state.active = false
	NAlib.disconnect("na_offsetwalk_heartbeat")
	if Services.RunService and Services.RunService.UnbindFromRenderStep then
		pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, state.bindName)
	end
	const root = getRoot(getChar())
	if root and typeof(localCFrame) == "CFrame" then
		pcall(function()
			root.CFrame = localCFrame
		end)
	end
	const hum = getHum()
	NAmanage.OffsetWalkRestoreDirectSpeed(state, hum)
	state.root = nil
	state.humanoid = nil
	state.originalWalkSpeed = nil
	state.localCFrame = nil
	state.serverCFrame = nil
	state.lastBurst = nil
	state.lastWriteCFrame = nil
	state.speed = nil
	if NAStuff._unloading ~= true then
		if NAStuff.SafeSpeedMethod ~= false then
			NAmanage.StopVelocityWalkSpeed()
			if tonumber(_na_env.NamelessSpeed) and tonumber(_na_env.NamelessSpeed) > 0 then
				NAmanage.RefreshVelocityWalkSpeed()
			end
		elseif NAStuff.loopws and tonumber(_na_env.NamelessWs) then
			NAmanage.StartLegacyLoopWalkSpeed(tonumber(_na_env.NamelessWs))
		end
	else
		NAmanage.StopVelocityWalkSpeed()
		NAmanage.StopLegacyLoopWalkSpeed()
	end
	if not silent then
		DoNotif("Offset Walk disabled", 2)
	end
end

NAmanage.StartOffsetWalk = function(value)
	const speed = tonumber(value)
	if not speed or speed <= 0 then
		NAmanage.StopOffsetWalk(true)
		return false
	end
	const char = getChar()
	const hum = getHum(char)
	const root = getRoot(char)
	if not (char and hum and root) then
		return false
	end
	if TPWalk then
		TPWalk = false
		NAlib.disconnect("TPWalkingConnection")
	end
	const state = NAmanage.GetOffsetWalkState()
	if state.active ~= true or state.root ~= root then
		state.originalWalkSpeed = tonumber(hum.WalkSpeed)
	end
	state.active = true
	state.speed = speed
	state.root = root
	state.humanoid = hum
	state.localCFrame = root.CFrame
	state.serverCFrame = root.CFrame
	state.lastBurst = os.clock()
	state.lastWriteCFrame = root.CFrame
	NAmanage.StopLegacyLoopWalkSpeed()
	if NAStuff.SafeSpeedMethod ~= false then
		NAmanage.RefreshVelocityWalkSpeed()
	else
		NAmanage.StopVelocityWalkSpeed()
		hum.WalkSpeed = speed
	end
	NAlib.disconnect("na_offsetwalk_heartbeat")
	if Services.RunService and Services.RunService.UnbindFromRenderStep then
		pcall(Services.RunService.UnbindFromRenderStep, Services.RunService, state.bindName)
	end
	NAlib.connect("na_offsetwalk_heartbeat", Services.RunService.Heartbeat:Connect(function()
		if state.active ~= true then
			return
		end
		const currentChar = getChar()
		const currentHum = getHum(currentChar)
		const currentRoot = getRoot(currentChar)
		if not (currentChar and currentHum and currentRoot) then
			return
		end
		if state.root ~= currentRoot then
			state.root = currentRoot
			state.humanoid = currentHum
			state.originalWalkSpeed = tonumber(currentHum.WalkSpeed)
			state.localCFrame = currentRoot.CFrame
			state.serverCFrame = currentRoot.CFrame
			state.lastBurst = os.clock()
			state.lastWriteCFrame = currentRoot.CFrame
		end
		if NAStuff.SafeSpeedMethod ~= false then
			if not NAlib.isConnected("na_velocityws_apply") then
				NAmanage.RefreshVelocityWalkSpeed()
			end
		else
			if currentHum.WalkSpeed ~= state.speed then
				currentHum.WalkSpeed = state.speed
			end
		end
		const observed = currentRoot.CFrame
		if not NAmanage.OffsetWalkCFrameNear(observed, state.serverCFrame) then
			NAmanage.OffsetWalkAdoptExternalCFrame(currentRoot, observed)
		end
		if not NAmanage.OffsetWalkCFrameNear(observed, state.serverCFrame) then
			state.localCFrame = observed
		end
		const now = os.clock()
		if now - (tonumber(state.lastBurst) or 0) >= state.interval then
			state.serverCFrame = state.localCFrame or observed
			state.lastBurst = now
		end
		const serverCFrame = state.serverCFrame or observed
		state.lastWriteCFrame = serverCFrame
		pcall(function()
			currentRoot.CFrame = serverCFrame
		end)
	end))
	if Services.RunService and Services.RunService.BindToRenderStep then
		Services.RunService:BindToRenderStep(state.bindName, Enum.RenderPriority.First.Value, function()
			if state.active ~= true then
				return
			end
			const currentRoot = getRoot(getChar())
			if not currentRoot then
				return
			end
			const observed = currentRoot.CFrame
			if not NAmanage.OffsetWalkCFrameNear(observed, state.serverCFrame) then
				NAmanage.OffsetWalkAdoptExternalCFrame(currentRoot, observed)
			end
			const localCFrame = state.localCFrame or observed
			state.localCFrame = localCFrame
			pcall(function()
				currentRoot.CFrame = localCFrame
			end)
		end)
	end
	return true
end

cmd.add({"offsetwalk", "owalk", "offsetspeed", "ospeed"}, {"offsetwalk <number|off> (owalk,offsetspeed,ospeed)", "moves the character by teleporting it a set number of studs every frame"}, function(...)
	const args = {...}
	const value = args[2] or args[1]
	const text = string.lower(tostring(value or "16"))
	if text == "off" or text == "disable" or text == "disabled" or text == "reset" then
		NAmanage.StopOffsetWalk(true)
		DoNotif("Offset Walk disabled", 2)
		return
	end
	const speed = tonumber(value) or 16
	if speed <= 0 then
		NAmanage.StopOffsetWalk(true)
		DoNotif("Offset Walk disabled", 2)
		return
	end
	if NAmanage.StartOffsetWalk(speed) then
		DoNotif("Offset Walk: "..tostring(speed).." ("..(NAStuff.SafeSpeedMethod ~= false and "Safe Speed" or "WalkSpeed")..")", 2)
	else
		DoNotif("Offset Walk failed: character is not ready", 3)
	end
end, true)

cmd.add({"unoffsetwalk", "unowalk", "unoffsetspeed", "unospeed"}, {"unoffsetwalk (unowalk,unoffsetspeed,unospeed)", "Stops Offset Walk"}, function()
	NAmanage.StopOffsetWalk(true)
	DoNotif("Offset Walk disabled", 2)
end)

TPWalk = false

cmd.add({"tpwalk", "tpwalk"}, {"tpwalk <number>", "More undetectable walkspeed script"}, function(...)
	if type(NAmanage.StopOffsetWalk) == "function" then
		NAmanage.StopOffsetWalk(true)
	end
	if TPWalk then
		TPWalk = false
		NAlib.disconnect("TPWalkingConnection")
	end

	TPWalk = true
	const Speed = tonumber(...) or 1
	const stepRate = 1 / 60
	const maxSteps = 3
	local accumulator = 0

	NAlib.connect("TPWalkingConnection", Services.RunService.Heartbeat:Connect(function(deltaTime)
		if not TPWalk then
			return
		end
		accumulator = math.min(accumulator + (tonumber(deltaTime) or 0), stepRate * maxSteps)
		const humanoid = getHum()
		const char = getChar()
		if not humanoid or not char or humanoid.MoveDirection.Magnitude <= 0 then
			return
		end
		const moveDirection = humanoid.MoveDirection
		local steps = 0
		while accumulator >= stepRate and steps < maxSteps do
			const stepDelta = moveDirection * Speed * stepRate * 10
			const undergroundState = NAStuff and NAStuff.NAundergroundState
			if undergroundState and undergroundState.Underground then
				undergroundState.PendingTranslation = (undergroundState.PendingTranslation or Vector3.new(0, 0, 0)) + stepDelta
			else
				char:TranslateBy(stepDelta)
			end
			accumulator -= stepRate
			steps += 1
		end
	end))
end, true)

cmd.add({"untpwalk"}, {"untpwalk", "Stops the tpwalk command"}, function()
	TPWalk = false
	NAlib.disconnect("TPWalkingConnection")
end)

TPJump = false

NAmanage.TPJumpInputAllowed = function(hum)
	if not hum then
		return false
	end
	if hum.FloorMaterial ~= Enum.Material.Air then
		return true
	end
	return (NAlib.isConnected("infjump_jump") or NAlib.isConnected("flyjump")) and true or false
end

NAmanage.TPJumpPulse = function(force)
	const st = NAStuff and NAStuff.TPJumpState
	if not (TPJump and st) then
		return false
	end

	const char = getChar()
	const hum = char and getHum(char)
	const root = char and getRoot(char)
	if not (char and hum and root and hum.Health > 0) then
		return false
	end

	if not force and not NAmanage.TPJumpInputAllowed(hum) then
		return false
	end

	const now = os.clock()
	st.untilTime = math.max(st.untilTime or 0, now + (force and 0.2 or 0.15))
	st.accumulator = math.max(st.accumulator or 0, st.stepRate or (1 / 60))
	st.lastPulse = now
	return true
end

cmd.add({"tpjump", "tjump"}, {"tpjump <number>",""}, function(...)
	if TPJump then
		TPJump = false
		NAlib.disconnect("TPJumpConnection")
		NAlib.disconnect("TPJumpRequest")
		NAlib.disconnect("TPJumpCharacter")
		NAlib.disconnect("TPJumpHumanoidJump")
	end

	TPJump = true
	const Speed = math.clamp(math.abs(tonumber(...) or 1), 0.1, 100)
	const stepRate = 1 / 60
	const maxSteps = 3
	const st = {
		speed = Speed,
		stepRate = stepRate,
		maxSteps = maxSteps,
		accumulator = 0,
		untilTime = 0,
		lastPulse = 0,
	}
	NAStuff.TPJumpState = st

	const function bindHumanoidJump()
		NAlib.disconnect("TPJumpHumanoidJump")
		const hum = getHum()
		if hum then
			NAlib.connect("TPJumpHumanoidJump", hum.Jumping:Connect(function(active)
				if active then
					NAmanage.TPJumpPulse()
				end
			end))
		end
	end

	bindHumanoidJump()

	NAlib.reconnect("TPJumpRequest", Services.UserInputService.JumpRequest:Connect(function()
		NAmanage.TPJumpPulse()
	end))

	NAlib.reconnect("TPJumpCharacter", LocalPlayer.CharacterAdded:Connect(function()
		st.accumulator = 0
		st.untilTime = 0
		Defer(function()
			Wait(0.15)
			if TPJump then
				bindHumanoidJump()
			end
		end)
	end))

	NAlib.reconnect("TPJumpConnection", Services.RunService.Heartbeat:Connect(function(deltaTime)
		if not TPJump then
			return
		end

		const humanoid = getHum()
		const char = getChar()
		if not humanoid or not char or humanoid.Health <= 0 then
			return
		end

		const state = humanoid:GetState()
		const jumping = humanoid.Jump == true or state == Enum.HumanoidStateType.Jumping
		if jumping then
			NAmanage.TPJumpPulse()
		end

		if os.clock() > (st.untilTime or 0) then
			st.accumulator = 0
			return
		end

		st.accumulator = math.min((st.accumulator or 0) + (tonumber(deltaTime) or 0), stepRate * maxSteps)
		const root = getRoot(char)
		local steps = 0
		while st.accumulator >= stepRate and steps < maxSteps do
			const stepDelta = Vector3.new(0, st.speed * stepRate * 10, 0)
			const undergroundState = NAStuff and NAStuff.NAundergroundState
			if undergroundState and undergroundState.Underground then
				undergroundState.PendingTranslation = (undergroundState.PendingTranslation or Vector3.new(0, 0, 0)) + stepDelta
			else
				char:TranslateBy(stepDelta)
			end
			st.accumulator -= stepRate
			steps += 1
		end
		if root then
			const vel = NAlib.isProperty(root, "AssemblyLinearVelocity") or root.Velocity
			if typeof(vel) == "Vector3" and vel.Y > 20 then
				NAlib.setProperty(root, "AssemblyLinearVelocity", Vector3.new(vel.X, 20, vel.Z))
			end
		end
	end))
end, true)

cmd.add({"untpjump", "untjump"}, {"untpjump", "Stops the tpjump command"}, function()
	TPJump = false
	NAStuff.TPJumpState = nil
	NAlib.disconnect("TPJumpConnection")
	NAlib.disconnect("TPJumpRequest")
	NAlib.disconnect("TPJumpCharacter")
	NAlib.disconnect("TPJumpHumanoidJump")
end)

muteLOOP = {}

cmd.add({"loopmute", "loopmuteboombox"}, {"loopmute <player|npc:filter> (loopmuteboombox)", "Loop mutes sounds from a player or NPC"}, function(...)
	const u = ...
	const pls = getPlr(u)
	if #pls == 0 then return end

	const function mute(p)
		const targetChar = p and NAmanage.PlayerArgChar(p)
		if targetChar then
			for _, d in NAmanage.QueryDescendants(targetChar, "Sound") do
				if d.Playing then
					d.Playing = false
				end
			end
		end
		const bp = p and p:IsA("Player") and p:FindFirstChildOfClass("Backpack") or nil
		if bp then
			for _, d in NAmanage.QueryDescendants(bp, "Sound") do
				if d.Playing then
					d.Playing = false
				end
			end
		end
	end

	for _, p in pls do
		const id = p:IsA("Player") and ("player:"..tostring(p.UserId)) or p
		if not muteLOOP[id] then
			muteLOOP[id] = Spawn(function()
				while p and p.Parent do
					mute(p)
					Wait(1)
				end
				muteLOOP[id] = nil
			end)
			DebugNotif("Loopmuted "..p.Name)
		else
			DebugNotif(p.Name.." already loopmuted")
		end
	end
end, true)

cmd.add({"unloopmute", "unloopmuteboombox"}, {"unloopmute <player|npc:filter> (unloopmuteboombox)", "Stops loop muting a player or NPC"}, function(...)
	const u = ...
	const pls = getPlr(u)
	if #pls == 0 then return end

	for _, p in pls do
		const id = p:IsA("Player") and ("player:"..tostring(p.UserId)) or p
		const t = muteLOOP[id]
		if t then
			coroutine.close(t)
			muteLOOP[id] = nil
			DebugNotif("Unloopmuted "..p.Name)
		else
			DebugNotif(p.Name.." not loopmuted")
		end
	end
end, true)

cmd.add({"getmass"}, {"getmass <player|npc:filter>", "Get a player or NPC root mass"}, function(...)
	const target = getPlr(NAmanage.PlayerQueryFromArgs(...))
	for _, plr in next, target do
		const char = NAmanage.PlayerArgChar(plr)
		if char then
			const root = getRoot(char)
			if root then
				const mass = root.AssemblyMass
				DoNotif(nameChecker(plr).."'s mass is "..mass)
			end
		end
		Wait()
	end
end, true)

cmd.add({"copyposition", "copypos", "cpos"}, {"copyposition <player|npc:filter>", "Get the position of a player or NPC"}, function(...)
	const args = {...}
	local targetList

	if #args == 0 then
		targetList = {Services.Players and Services.Players.LocalPlayer}
	else
		targetList = getPlr(NAmanage.PlayerQueryFromArgs(...))
	end

	const plr = targetList and targetList[1]
	if not plr then
		DebugNotif("No matching players found")
		return
	end

	const char = NAmanage.PlayerArgChar(plr)
	if not char then
		DebugNotif("Unable to find "..tostring(plr.Name).."'s character")
		return
	end

	const root = getRoot(char)
	if not root then
		DebugNotif("Unable to find "..tostring(plr.Name).."'s root part")
		return
	end

	const pos = root.Position
	const formatted = Format("%.3f, %.3f, %.3f", pos.X, pos.Y, pos.Z)
	DebugNotif(nameChecker(plr).."'s position is: "..formatted)
	if setclipboard then
		setclipboard(formatted)
	end
end, true)

cmd.add({"equiptools"},{"equiptools","Equips every tool in your inventory at once"},function()
	for i,v in Player:FindFirstChildOfClass("Backpack"):GetChildren() do
		if v:IsA("Tool") or v:IsA("HopperBin") then
			v.Parent=Player.Character
		end
	end
end)

cmd.add({"unequiptools"},{"unequiptools","Unequips every tool you are currently holding at once"},function()
	Player.Character:FindFirstChildOfClass('Humanoid'):UnequipTools()
end)

cmd.add({"removeterrain", "rterrain", "noterrain"},{"removeterrain (rterrain, noterrain)","clears terrain"},function()
	Services.Workspace:FindFirstChildOfClass('Terrain'):Clear()
end)

cmd.add({"memory", "mem"}, {"memory", "Shows you your current memory usage"}, function(args)
	--DoNotif(stats():GetTotalMemoryUsageMb().." mb",5,"Memory")
	DoNotif(__lt.cm("Stats", "WaitForChild", "PerformanceStats"):WaitForChild("Memory"):GetValueString(),5,"Memory")
end, true)

cmd.add({"clearnilinstances", "nonilinstances", "cni"},{"clearnilinstances (nonilinstances, cni)","Removes nil instances"},function()
	if getnilinstances then
		for _,nill in getnilinstances() do
			nill:Destroy()
		end
	else
		DoNotif("Your exploit does not support getnilinstances")
	end
end)

cmd.add({"inspect"}, {"inspect", "checks a user's items"}, function(args)
	const query = type(args) == "table" and NAmanage.PlayerQueryFromArgs(Unpack(args)) or tostring(args or "")
	const targetPlayers = getPlr(query)

	if targetPlayers and #targetPlayers > 0 then
		for _, plr in next, targetPlayers do
			__lt.cm("GuiService", "CloseInspectMenu")
			__lt.cm("GuiService", "InspectPlayerFromUserId", plr.UserId)
		end
	else
		const userId = NAmanage.NAClientResolveUserId(query)
		if userId then
			__lt.cm("GuiService", "InspectPlayerFromUserId", userId)
		else
			DebugNotif("No matching player or user found", 3)
		end
	end
end, true)

promptTBL = promptTBL or {}
promptTBL.tracked = promptTBL.tracked or {}
promptTBL.conns = promptTBL.conns or {}
promptTBL.blocking = promptTBL.blocking == true
promptTBL.polling = promptTBL.polling == true
promptTBL.guiConns = NAmanage.ensureWeakTable(promptTBL.guiConns, "k")
promptTBL.objConns = NAmanage.ensureWeakTable(promptTBL.objConns, "k")
promptTBL.objPrev = NAmanage.ensureWeakTable(promptTBL.objPrev, "k")
promptTBL.foundation = NAmanage.ensureWeakTable(promptTBL.foundation, "k")

function NAmanage.isPromptGuiName(name)
	if type(name) ~= "string" then
		return false
	end
	const lowerName = name:lower()
	return lowerName:find("purchaseprompt", 1, true) ~= nil or lowerName:find("foundationoverlay", 1, true) ~= nil
end

function NAmanage.isFoundationOverlay(inst)
	return typeof(inst) == "Instance" and inst:IsA("ScreenGui") and Lower(tostring(inst.Name or "")) == "foundationoverlay"
end

function NAmanage.trackPromptGui(inst)
	if not inst or typeof(inst) ~= "Instance" then
		return nil
	end
	if inst:IsA("ScreenGui") then
		return NAmanage.isPromptGuiName(inst.Name) and inst or nil
	end
	const name = inst.Name
	if type(name) == "string" and NAmanage.isPromptGuiName(name) then
		const gui = inst:FindFirstAncestorWhichIsA("ScreenGui")
		if gui and NAmanage.isPromptGuiName(gui.Name) then
			return gui
		end
	end
	const foundation = inst:FindFirstAncestor("FoundationOverlay")
	if NAmanage.isFoundationOverlay(foundation) then
		return foundation
	end
	return nil
end

function NAmanage.nuhuhprompt(v)
	NACaller(function()
		if v == false then
			if promptTBL.blocking then return end
			promptTBL.blocking = true

			NAmanage.CancelTokenCancel(promptTBL.scanToken)
			const scanToken = NAmanage.NewCancelToken()
			promptTBL.scanToken = scanToken

			const visited = {}

			const function disableGui(gui)
				if not promptTBL.blocking then
					return
				end
				if not gui or typeof(gui) ~= "Instance" or not gui:IsA("ScreenGui") then
					return
				end
				if promptTBL.tracked[gui] == nil then
					promptTBL.tracked[gui] = gui.Enabled
				end
				pcall(function()
					gui.Enabled = false
				end)
				if promptTBL.guiConns[gui] == nil then
					const c = gui:GetPropertyChangedSignal("Enabled"):Connect(function()
						if promptTBL.blocking then
							pcall(function()
								gui.Enabled = false
							end)
						end
					end)
					promptTBL.guiConns[gui] = c
					Insert(promptTBL.conns, c)
				end
			end

			const function disableObj(obj)
				if not promptTBL.blocking then
					return
				end
				if not obj or typeof(obj) ~= "Instance" or not obj:IsA("GuiObject") then
					return
				end
				if promptTBL.objPrev[obj] == nil then
					promptTBL.objPrev[obj] = {
						visible = obj.Visible,
						active = obj.Active,
					}
				end
				pcall(function()
					obj.Visible = false
				end)
				pcall(function()
					obj.Active = false
				end)
				if promptTBL.objConns[obj] == nil then
					promptTBL.objConns[obj] = true
					Insert(promptTBL.conns, obj:GetPropertyChangedSignal("Visible"):Connect(function()
						if promptTBL.blocking then
							pcall(function()
								obj.Visible = false
							end)
						end
					end))
					Insert(promptTBL.conns, obj:GetPropertyChangedSignal("Active"):Connect(function()
						if promptTBL.blocking then
							pcall(function()
								obj.Active = false
							end)
						end
					end))
				end
			end

			const function disableObjs(root)
				if not promptTBL.blocking or not root or typeof(root) ~= "Instance" then
					return
				end
				if root:IsA("GuiObject") then
					disableObj(root)
				end
				NAmanage.ForEachDescendantYield(root, function(obj)
					if obj:IsA("GuiObject") then
						disableObj(obj)
					end
				end, {
					yieldEvery = 80,
					delayTime = 0.015,
				})
			end

			const function bindFoundation(gui)
				if not promptTBL.blocking or not NAmanage.isFoundationOverlay(gui) then
					return
				end

				disableGui(gui)

				if promptTBL.foundation[gui] then
					return
				end
				promptTBL.foundation[gui] = true
				disableObjs(gui)

				const inner = NAmanage.descSub(gui, {
					added = function(inst2)
						if not promptTBL.blocking then
							return
						end
						if inst2:IsA("ScreenGui") then
							disableGui(inst2)
						end
						disableObjs(inst2)
					end,
					filterAdded = function(inst2)
						return inst2 and (inst2:IsA("GuiObject") or inst2:IsA("ScreenGui"))
					end,
					classNames = { "ScreenGui", "Frame", "ScrollingFrame", "TextLabel", "TextButton", "TextBox", "ImageLabel", "ImageButton", "CanvasGroup", "ViewportFrame" },
				})
				Insert(promptTBL.conns, inner)

				Insert(promptTBL.conns, gui:GetPropertyChangedSignal("Parent"):Connect(function()
					if not gui.Parent then
						promptTBL.foundation[gui] = nil
					end
				end))
			end

			const function trackAndDisable(inst)
				if not promptTBL.blocking then
					return
				end
				const gui = NAmanage.trackPromptGui(inst)
				if not gui then
					return
				end

				if NAmanage.isFoundationOverlay(gui) then
					bindFoundation(gui)
				end

				if visited[gui] then
					return
				end
				visited[gui] = true

				disableGui(gui)

				for _, x in NAmanage.QueryDescendants(gui, "ScreenGui") do
					disableGui(x)
					if NAmanage.isFoundationOverlay(x) then
						bindFoundation(x)
					end
				end

				const inner = NAmanage.descSub(gui, {
					added = function(inst2)
						if inst2:IsA("ScreenGui") then
							disableGui(inst2)
							if NAmanage.isFoundationOverlay(inst2) then
								bindFoundation(inst2)
							end
						end
					end,
					filterAdded = function(inst2)
						return inst2 and inst2:IsA("ScreenGui")
					end,
				})
				Insert(promptTBL.conns, inner)
			end

			const rootConn = NAmanage.childAdd(Services.CoreGui, trackAndDisable, function(inst)
				return inst and inst:IsA("ScreenGui") and NAmanage.isPromptGuiName(inst.Name)
			end)
			Insert(promptTBL.conns, rootConn)

			const c = NAmanage.cgSub({
				added = trackAndDisable,
				filterAdded = function(inst)
					return inst and inst:IsA("ScreenGui") and NAmanage.isPromptGuiName(inst.Name)
				end,
				classNames = "ScreenGui",
			})
			Insert(promptTBL.conns, c)

			trackAndDisable(Services.CoreGui and Services.CoreGui:FindFirstChild("FoundationOverlay"))

			SpawnCall(function()
				NAmanage.ForEachDescendantYield(Services.CoreGui, trackAndDisable, {
					cancelToken = scanToken,
					yieldEvery = 400,
				})
			end)
		else
			if not promptTBL.blocking then return end
			promptTBL.blocking = false
			NAmanage.CancelTokenCancel(promptTBL.scanToken)
			promptTBL.scanToken = nil

			for i = #promptTBL.conns, 1, -1 do
				const c = promptTBL.conns[i]
				if c and c.Connected then
					c:Disconnect()
				end
				promptTBL.conns[i] = nil
			end

			for obj, prev in promptTBL.objPrev do
				if typeof(obj) == "Instance" and obj and obj.Parent ~= nil and type(prev) == "table" then
					if prev.visible ~= nil then
						pcall(function()
							obj.Visible = prev.visible
						end)
					end
					if prev.active ~= nil then
						pcall(function()
							obj.Active = prev.active
						end)
					end
				end
				promptTBL.objPrev[obj] = nil
			end

			for gui, prev in promptTBL.tracked do
				if typeof(gui) == "Instance" and gui and gui.Parent ~= nil then
					pcall(function()
						gui.Enabled = prev
					end)
				end
				promptTBL.tracked[gui] = nil
			end

			for gui in promptTBL.guiConns do
				promptTBL.guiConns[gui] = nil
			end
			for obj in promptTBL.objConns do
				promptTBL.objConns[obj] = nil
			end
			for gui in promptTBL.foundation do
				promptTBL.foundation[gui] = nil
			end
		end
	end)
end

if NAStuff and NAStuff.PurchasePromptsDisabled == true then
	NAmanage.nuhuhprompt(false)
end

notificationButtonBlock = notificationButtonBlock or { conns = {}, blocking = false, frames = {} }

NAmanage._isFriendRequestFrame=function(inst)
	if not inst or typeof(inst) ~= "Instance" or not inst:IsA("Frame") then return false end
	if not (inst.Parent and inst.Parent.Name == "NotificationFrame") then
		return false
	end
	const function hasThumbImage(container)
		if not container or typeof(container) ~= "Instance" then return false end
		if container:IsA("ImageLabel") or container:IsA("ImageButton") then
			const img = Lower(tostring(container.Image or ""))
			return img:find("rbxthumb://", 1, true) ~= nil
		end
		return false
	end

	const function hasAcceptDeclineButtons(container)
		local foundAccept, foundDecline = false, false
		const function checkBtn(btn)
			if not btn or typeof(btn) ~= "Instance" then return end
			if btn:IsA("TextButton") then
				const txt = Lower(tostring(btn.Text or ""))
				if txt == "accept" then
					foundAccept = true
				elseif txt == "decline" then
					foundDecline = true
				end
			end
		end
		for _, d in NAmanage.QueryDescendants(container, "Instance") do
			checkBtn(d)
			if foundAccept and foundDecline then break end
		end
		return foundAccept and foundDecline
	end

	local hasThumb = hasThumbImage(inst)
	if not hasThumb then
		for _, desc in NAmanage.QueryDescendants(inst, "Instance") do
			if hasThumbImage(desc) then
				hasThumb = true
				break
			end
		end
	end

	if not hasThumb then
		return false
	end

	return hasAcceptDeclineButtons(inst)
end

NAmanage.setFriendRequestAutoDismiss = function(enable)
	NACaller(function()
		const tbl = notificationButtonBlock
		const coreGui = Services.CoreGui
		if not coreGui then
			return
		end

		const function disconnectAll()
			for i = #tbl.conns, 1, -1 do
				const c = tbl.conns[i]
				if c and c.Connected then
					c:Disconnect()
				end
				tbl.conns[i] = nil
			end
			tbl.frames = {}
			tbl.blocking = false
		end

		const function bindNotificationFrame(nf)
			if not nf or tbl.frames[nf] or not nf:IsA("Frame") then return end
			tbl.frames[nf] = true

			const function handleChild(child)
				if not tbl.blocking or not child or child.Parent ~= nf or not child:IsA("Frame") then
					return
				end
				if NAmanage._isFriendRequestFrame(child) then
					const function disableGuiObject(gui)
						if gui:IsA("GuiObject") then
							pcall(function() gui.Visible = false end)
							pcall(function() gui.Active = false end)
						end
					end

					disableGuiObject(child)
					for _, d in NAmanage.QueryDescendants(child, "GuiObject") do
						disableGuiObject(d)
					end
				end
			end

			for _, child in nf:GetChildren() do
				handleChild(child)
			end

			Insert(tbl.conns, NAmanage.childAdd(nf, handleChild, function(child)
				return child and child:IsA("Frame")
			end))
			Insert(tbl.conns, nf:GetPropertyChangedSignal("Parent"):Connect(function()
				if not nf.Parent then
					tbl.frames[nf] = nil
				end
			end))
		end

		const function attachExisting()
			const robloxGui = coreGui:FindFirstChild("RobloxGui")
			if not robloxGui then return end
			const nf = robloxGui:FindFirstChild("NotificationFrame")
			if nf and nf:IsA("Frame") then
				bindNotificationFrame(nf)
			end
		end

		const function bindRobloxGui(rg)
			if not (rg and rg:IsA("LayerCollector")) then
				return
			end
			const nf = rg:FindFirstChild("NotificationFrame")
			if nf and nf:IsA("Frame") then
				bindNotificationFrame(nf)
			end
			Insert(tbl.conns, NAmanage.childAdd(rg, function(inst)
				if not tbl.blocking or not inst then return end
				if inst.Name == "NotificationFrame" and inst:IsA("Frame") then
					bindNotificationFrame(inst)
				end
			end, function(inst)
				return inst and inst.Name == "NotificationFrame" and inst:IsA("Frame")
			end))
		end

		if enable then
			if tbl.blocking then return end
			tbl.blocking = true
			tbl.frames = tbl.frames or {}

			attachExisting()
			bindRobloxGui(coreGui:FindFirstChild("RobloxGui"))
			Insert(tbl.conns, NAmanage.childAdd(coreGui, function(inst)
				if not tbl.blocking or not inst then return end
				if inst.Name == "RobloxGui" and inst:IsA("LayerCollector") then
					bindRobloxGui(inst)
				end
			end, function(inst)
				return inst and inst.Name == "RobloxGui" and inst:IsA("LayerCollector")
			end))
		else
			if not tbl.blocking then return end
			disconnectAll()
		end
	end)
end

if NAStuff and NAStuff.FriendRequestAutoDismiss == true then
	NAmanage.setFriendRequestAutoDismiss(true)
end

networkPauseBlock = networkPauseBlock or {}
networkPauseBlock.tracked = networkPauseBlock.tracked or {}
networkPauseBlock.conns = networkPauseBlock.conns or {}
networkPauseBlock.guiEnabled = NAmanage.ensureWeakTable and NAmanage.ensureWeakTable(networkPauseBlock.guiEnabled, "k") or (networkPauseBlock.guiEnabled or {})
networkPauseBlock.guiConns = networkPauseBlock.guiConns or {}
networkPauseBlock.blocking = networkPauseBlock.blocking == true
networkPauseBlock.polling = networkPauseBlock.polling == true

function NAmanage.isNetworkPauseScript(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	if not inst:IsA("BaseScript") then
		return false
	end
	const name = inst.Name or ""
	if not Lower(name):find("networkpause", 1, true) then
		return false
	end
	const robloxGui = inst:FindFirstAncestor("RobloxGui")
	if not robloxGui or not robloxGui:IsDescendantOf(Services.CoreGui) then
		return false
	end
	if name == "CoreScripts/NetworkPause" then
		return true
	end
	const parent = inst.Parent
	return parent and parent.Name == "CoreScripts" and parent:IsDescendantOf(robloxGui)
end

function NAmanage.isNetworkPauseGui(inst)
	if typeof(inst) ~= "Instance" then
		return false
	end
	local ok, isGui = pcall(function()
		return inst:IsA("ScreenGui")
	end)
	if not ok or not isGui then
		return false
	end
	const name = Lower(tostring(inst.Name or ""))
	if name ~= "robloxnetworkpausenotification" and not name:find("networkpause", 1, true) then
		return false
	end
	return inst:IsDescendantOf(Services.CoreGui)
end

function NAmanage.getNetworkPauseScript()
	const robloxGui = __lt.cm("CoreGui", "FindFirstChild", "RobloxGui")
	if not robloxGui then
		return nil
	end

	const direct = robloxGui:FindFirstChild("CoreScripts/NetworkPause")
	if direct and NAmanage.isNetworkPauseScript(direct) then
		return direct
	end
	return nil
end

function NAmanage.forceGameplayPausedOff()
	pcall(function()
		const plr = LocalPlayer
		if plr and plr.GameplayPaused == true then
			plr.GameplayPaused = false
		end
	end)
end

function NAmanage.fireNetworkPauseEnabled(enabled)
	local fired = false
	const state = enabled == true
	if Services.GuiService and type(firesignal) == "function" then
		pcall(function()
			firesignal(Services.GuiService.NetworkPausedEnabledChanged, state)
			fired = true
		end)
	end
	if Services.StarterGui then
		pcall(function()
			__lt.cm("StarterGui", "SetCore", "NetworkPausedEnabled", state)
			fired = true
		end)
	end
	if not state then
		NAmanage.forceGameplayPausedOff()
	end
	return fired
end

function NAmanage.setNetworkPauseFocused(focused)
	pcall(function()
		Services.RunService:SetRobloxGuiFocused(focused == true)
	end)
end

function NAmanage.setNetworkPauseGuiBlocked(gui, blocked)
	const tbl = networkPauseBlock
	if not blocked then
		if tbl.guiConns[gui] then
			NAmanage.tryDisconnect(tbl.guiConns[gui])
			tbl.guiConns[gui] = nil
		end
		const prev = tbl.guiEnabled[gui]
		if prev ~= nil and typeof(gui) == "Instance" and gui.Parent ~= nil then
			pcall(function()
				gui.Enabled = prev == true
			end)
		end
		tbl.guiEnabled[gui] = nil
		return true
	end
	if not NAmanage.isNetworkPauseGui(gui) then
		return false
	end
	if blocked then
		if tbl.guiEnabled[gui] == nil then
			local ok, enabled = pcall(function()
				return gui.Enabled
			end)
			tbl.guiEnabled[gui] = ok and enabled or true
		end
		pcall(function()
			gui.Enabled = false
		end)
		if not tbl.guiConns[gui] then
			local ok, conn = pcall(function()
				return gui:GetPropertyChangedSignal("Enabled"):Connect(function()
					if tbl.blocking and NAmanage.isNetworkPauseGui(gui) then
						local okEnabled, enabled = pcall(function()
							return gui.Enabled
						end)
						if okEnabled and enabled == true then
							pcall(function()
								gui.Enabled = false
							end)
							NAmanage.setNetworkPauseFocused(false)
						end
					end
				end)
			end)
			if ok and conn then
				tbl.guiConns[gui] = conn
			end
		end
		return true
	end
	return true
end

function NAmanage.scanNetworkPauseItems(callback)
	if type(callback) ~= "function" then
		return
	end
	const roots = {}
	const seen = {}
	const function add(root)
		if typeof(root) == "Instance" and not seen[root] then
			seen[root] = true
			roots[#roots + 1] = root
		end
	end
	add(Services.CoreGui)
	add(__lt.cm("CoreGui", "FindFirstChild", "RobloxGui"))
	for i = 1, #roots do
		const root = roots[i]
		if NAmanage.isNetworkPauseGui(root) or NAmanage.isNetworkPauseScript(root) then
			callback(root)
		end
		NAmanage.ForEachDescendantYield(root, function(inst)
			const name = Lower(tostring(inst.Name or ""))
			if name:find("networkpause", 1, true) then
				if NAmanage.isNetworkPauseGui(inst) or NAmanage.isNetworkPauseScript(inst) then
					callback(inst)
				end
			end
		end, {
			yieldEvery = 120,
			delayTime = 0.02,
		})
	end
end

function NAmanage.setNetworkPauseBlocked(disable)
	NACaller(function()
		const tbl = networkPauseBlock
		const function trackAndDisable(inst)
			if not tbl.blocking then
				return
			end
			if inst ~= nil then
				if NAmanage.isNetworkPauseGui(inst) then
					NAmanage.setNetworkPauseGuiBlocked(inst, true)
				end
				if NAmanage.isNetworkPauseScript(inst) then
					if tbl.tracked[inst] ~= nil then
						pcall(function()
							inst.Disabled = false
						end)
					end
				end
				return
			end
			NAmanage.scanNetworkPauseItems(function(item)
				trackAndDisable(item)
			end)
			NAmanage.fireNetworkPauseEnabled(false)
			NAmanage.setNetworkPauseFocused(false)
		end
		if disable then
			const wasBlocking = tbl.blocking == true
			tbl.blocking = true
			NAmanage.fireNetworkPauseEnabled(false)
			trackAndDisable(nil)
			if not wasBlocking then
				const function watchRoot(root)
					if typeof(root) ~= "Instance" then
						return
					end
					const conn = NAmanage.descAdd(root, function(inst)
						if not tbl.blocking or typeof(inst) ~= "Instance" then
							return
						end
						trackAndDisable(inst)
						NAmanage.fireNetworkPauseEnabled(false)
						NAmanage.setNetworkPauseFocused(false)
					end, function(inst)
						if typeof(inst) ~= "Instance" then
							return false
						end
						return Lower(tostring(inst.Name or "")):find("networkpause", 1, true) ~= nil
					end)
					if conn then
						Insert(tbl.conns, conn)
					end
				end
				watchRoot(Services.CoreGui)
				local okPause, pauseConn = pcall(function()
					return LocalPlayer:GetPropertyChangedSignal("GameplayPaused"):Connect(function()
						if tbl.blocking then
							NAmanage.fireNetworkPauseEnabled(false)
							trackAndDisable(nil)
							NAmanage.setNetworkPauseFocused(false)
						end
					end)
				end)
				if okPause and pauseConn then
					Insert(tbl.conns, pauseConn)
				end
			end
		else
			if not tbl.blocking then
				NAmanage.fireNetworkPauseEnabled(true)
				return
			end
			tbl.blocking = false
			NAmanage.CancelTokenCancel(tbl.scanToken)
			tbl.scanToken = nil
			for i = #tbl.conns, 1, -1 do
				NAmanage.tryDisconnect(tbl.conns[i])
				tbl.conns[i] = nil
			end
			for gui in tbl.guiConns do
				NAmanage.setNetworkPauseGuiBlocked(gui, false)
			end
			for gui in tbl.guiEnabled do
				NAmanage.setNetworkPauseGuiBlocked(gui, false)
			end
			for scriptInst, prev in tbl.tracked do
				if typeof(scriptInst) == "Instance" and scriptInst.Parent ~= nil then
					pcall(function()
						scriptInst.Disabled = prev == true
					end)
				end
				tbl.tracked[scriptInst] = nil
			end
			const fired = NAmanage.fireNetworkPauseEnabled(true)
			if not fired then
				local paused = false
				pcall(function()
					paused = LocalPlayer.GameplayPaused == true
				end)
				NAmanage.setNetworkPauseFocused(paused)
			end
		end
	end)
end

if NAStuff and NAStuff.NetworkPauseDisabled == true then
	NAmanage.setNetworkPauseBlocked(true)
end

cmd.add({"noprompt","nopurchaseprompts","noprompts","np"},{"noprompt (nopurchaseprompts,noprompts,np)","remove the stupid purchase prompt"},function()
	NAStuff.PurchasePromptsDisabled = true
	pcall(NAmanage.NASettingsSet, "purchasePromptsDisabled", true)
	NAmanage.nuhuhprompt(false)
	DebugNotif("Purchase prompts have been disabled")
end)

cmd.add({"prompt","purchaseprompts","showprompts","showpurchaseprompts","ppr"},{"prompt (purchaseprompts,showprompts,showpurchaseprompts,ppr)","allows the stupid purchase prompt"},function()
	NAStuff.PurchasePromptsDisabled = false
	pcall(NAmanage.NASettingsSet, "purchasePromptsDisabled", false)
	NAmanage.nuhuhprompt(true)
	DebugNotif("Purchase prompts have been enabled")
end)

cmd.add({"nonetworkpause","disableNetworkPause","nnw","nnpause"},{"nonetworkpause (disableNetworkPause,nnw,nnpause)","Disable Roblox network pause overlay"},function()
	NAStuff.NetworkPauseDisabled = true
	pcall(NAmanage.NASettingsSet, "networkPauseDisabled", true)
	NAmanage.setNetworkPauseBlocked(true)
	DoNotif("Network pause UI blocked", 3)
end)

cmd.add({"networkpause","enablenetworkpause","nw","npause"},{"networkpause (enablenetworkpause,nw,npause)","Re-enable Roblox network pause overlay"},function()
	NAStuff.NetworkPauseDisabled = false
	pcall(NAmanage.NASettingsSet, "networkPauseDisabled", false)
	NAmanage.setNetworkPauseBlocked(false)
	DoNotif("Network pause UI allowed", 3)
end)

cmd.add({"wallwalk"},{"wallwalk","Makes you walk on walls"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/WallWalk.lua") -- backup cause i don't trust pastebin
end)

hiddenGUIS = hiddenGUIS or {}
showPrev = showPrev or {}
NAStuff.TargetGuiHidePrev = NAStuff.TargetGuiHidePrev or {}
NAStuff.TargetGuiShowPrev = NAStuff.TargetGuiShowPrev or {}
NAStuff.HideCurrentGuiPrev = NAStuff.HideCurrentGuiPrev or {}

NAmanage.TargetGuiRoots = function()
	const roots = {}
	const seen = {}
	const function add(root)
		if typeof(root) == "Instance" and not seen[root] then
			seen[root] = true
			Insert(roots, root)
		end
	end
	const lp = Services.Players.LocalPlayer
	add(PlrGui)
	add(lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")))
	add(HUI)
	add(Services.CoreGui)
	return roots
end

NAmanage.TargetGuiIsUi = function(inst)
	if typeof(inst) ~= "Instance" then return false end
	if inst:IsA("GuiObject") then return true end
	local ok, isLayer = pcall(function()
		return inst:IsA("LayerCollector")
	end)
	return ok and isLayer == true
end

NAmanage.TargetGuiSetShown = function(inst, shown)
	if typeof(inst) ~= "Instance" then return false end
	if inst:IsA("GuiObject") and NAlib.isProperty(inst, "Visible") ~= nil then
		return NAlib.setProperty(inst, "Visible", shown == true)
	end
	if NAlib.isProperty(inst, "Enabled") ~= nil then
		return NAlib.setProperty(inst, "Enabled", shown == true)
	end
	return false
end

NAmanage.TargetGuiSaveState = function(store, inst)
	if type(store) ~= "table" or typeof(inst) ~= "Instance" or store[inst] then return end
	const state = {}
	const enabled = NAlib.isProperty(inst, "Enabled")
	const visible = NAlib.isProperty(inst, "Visible")
	if enabled ~= nil then state.enabled = enabled end
	if visible ~= nil then state.visible = visible end
	if state.enabled ~= nil or state.visible ~= nil then
		store[inst] = state
	end
end

NAmanage.TargetGuiRestore = function(store)
	local n = 0
	if type(store) ~= "table" then return n end
	for inst, state in store do
		if typeof(inst) == "Instance" and inst.Parent and type(state) == "table" then
			if state.enabled ~= nil then NAlib.setProperty(inst, "Enabled", state.enabled) end
			if state.visible ~= nil then NAlib.setProperty(inst, "Visible", state.visible) end
			n += 1
		end
		store[inst] = nil
	end
	return n
end

NAmanage.TargetGuiFind = function(query)
	query = type(query) == "string" and Lower(query) or ""
	if query == "" then return {} end
	const matches = {}
	const added = {}
	const function tryAdd(inst)
		if not NAmanage.TargetGuiIsUi(inst) or added[inst] then return end
		const name = Lower(inst.Name or "")
		local full = ""
		pcall(function() full = Lower(inst:GetFullName()) end)
		if name == query or name:find(query, 1, true) or full:find(query, 1, true) then
			added[inst] = true
			Insert(matches, inst)
		end
	end
	for _, root in NAmanage.TargetGuiRoots() do
		tryAdd(root)
		for _, inst in NAmanage.QueryDescendants(root, "Instance") do
			tryAdd(inst)
		end
	end
	return matches
end

NAmanage.TargetGuiCollectUi = function()
	const list = {}
	const added = {}
	const function add(inst)
		if NAmanage.TargetGuiIsUi(inst) and not added[inst] then
			added[inst] = true
			Insert(list, inst)
		end
	end
	for _, root in NAmanage.TargetGuiRoots() do
		add(root)
		for _, inst in NAmanage.QueryDescendants(root, "Instance") do
			add(inst)
		end
	end
	return list
end

NAmanage.HideCurrentGuiRoots = function()
	const roots = {}
	const seen = {}
	const function add(root)
		if typeof(root) == "Instance" and not seen[root] then
			seen[root] = true
			Insert(roots, root)
		end
	end
	const lp = Services.Players.LocalPlayer
	add(PlrGui)
	add(lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")))
	return roots
end

NAmanage.HideCurrentGuiIsShown = function(inst)
	if typeof(inst) ~= "Instance" or not inst:IsA("GuiObject") then
		return false
	end

	local okVisible, visible = pcall(function()
		return inst.Visible
	end)
	if not okVisible or visible ~= true then
		return false
	end

	local okSize, absSize = pcall(function()
		return inst.AbsoluteSize
	end)
	if okSize and absSize and (absSize.X <= 0 or absSize.Y <= 0) then
		return false
	end

	local parent = inst.Parent
	while parent do
		if parent:IsA("GuiObject") then
			local okParentVisible, parentVisible = pcall(function()
				return parent.Visible
			end)
			if not okParentVisible or parentVisible ~= true then
				return false
			end
		end

		const enabled = NAlib.isProperty(parent, "Enabled")
		if enabled == false then
			return false
		end

		parent = parent.Parent
	end

	return true
end

NAmanage.HideCurrentGuiCollect = function()
	const all = {}
	const added = {}
	const top = {}

	for _, root in NAmanage.HideCurrentGuiRoots() do
		for _, inst in NAmanage.QueryDescendants(root, "GuiObject") do
			if NAmanage.HideCurrentGuiIsShown(inst) and not added[inst] then
				added[inst] = true
				Insert(all, inst)
			end
		end
	end

	for _, inst in all do
		local parent = inst.Parent
		local skip = false

		while parent do
			if added[parent] then
				skip = true
				break
			end
			parent = parent.Parent
		end

		if not skip then
			Insert(top, inst)
		end
	end

	return top
end

cmd.add({"hideguis"}, {"hideguis","Hides GUIs"}, function()
	for _, guiElement in NAmanage.QueryDescendants(PlrGui, "GuiObject") do
		if guiElement.Visible then
			guiElement.Visible = false
			if not Discover(hiddenGUIS, guiElement) then
				Insert(hiddenGUIS, guiElement)
			end
		end
	end
end)

cmd.add({"unhideguis"}, {"unhideguis","Restores GUIs hidden by hideguis"}, function()
	for _, guiElement in hiddenGUIS do
		if guiElement and guiElement.Parent then
			guiElement.Visible = true
		end
	end
	hiddenGUIS = {}
end)

cmd.add({"hidecurrentguis","hidecurrentgui","hidecguis","hcguis","hcgui","cguis","currentguis"}, {"hidecurrentguis","Hides only currently visible GUIs"}, function()
	const store = NAStuff.HideCurrentGuiPrev
	local changed = 0

	for _, inst in NAmanage.HideCurrentGuiCollect() do
		NAmanage.TargetGuiSaveState(store, inst)
		if NAmanage.TargetGuiSetShown(inst, false) then
			changed += 1
		end
	end

	DoNotif(("Hidden %d current GUI object(s)."):format(changed), 3, "Current GUIs")
end)

cmd.add({"unhidecurrentguis","unhidecurrentgui","unhidecguis","unhcguis","unhcgui","uncguis","restorecurrentguis","restorecguis"}, {"unhidecurrentguis","Restores GUIs hidden by hidecurrentguis"}, function()
	const n = NAmanage.TargetGuiRestore(NAStuff.HideCurrentGuiPrev)
	DoNotif(("Restored %d current GUI object(s)."):format(n), 2, "Current GUIs")
end)

cmd.add({"showguis"}, {"showguis","Enables every UI"}, function()
	for _, inst in NAmanage.QueryDescendants(PlrGui, "ScreenGui") do
		if not showPrev[inst] then showPrev[inst] = {enabled = inst.Enabled} end
		inst.Enabled = true
	end
	for _, inst in NAmanage.QueryDescendants(PlrGui, "GuiObject") do
		if not showPrev[inst] then showPrev[inst] = {visible = inst.Visible} else if showPrev[inst].visible == nil then showPrev[inst].visible = inst.Visible end end
		inst.Visible = true
	end
end)

cmd.add({"unshowguis"}, {"unshowguis","Restores UI states set by showguis"}, function()
	for inst, prev in showPrev do
		if inst and inst.Parent then
			if prev.enabled ~= nil and inst:IsA("ScreenGui") then inst.Enabled = prev.enabled end
			if prev.visible ~= nil and inst:IsA("GuiObject") then inst.Visible = prev.visible end
		end
		showPrev[inst] = nil
	end
end)

cmd.add({"hidetargetgui","hidegui"},{"hidetargetgui <name>","Hides a specific GUI by name"},function(...)
	const args = {...}
	const query = (Concat(args, " "):match("^%s*(.-)%s*$"))
	if query == "" then
		DebugNotif("Usage: hidetargetgui <name>", 3)
		return
	end
	const matches = NAmanage.TargetGuiFind(query)
	if #matches == 0 then
		DebugNotif("No GUI found matching: "..query, 3)
		return
	end
	const store = NAStuff.TargetGuiHidePrev
	local changed = 0
	for _, inst in matches do
		NAmanage.TargetGuiSaveState(store, inst)
		if NAmanage.TargetGuiSetShown(inst, false) then
			changed += 1
		end
	end
	DoNotif(("Hidden %d GUI object(s) matching '%s'."):format(changed, query), 3, "Target GUI")
end)

cmd.add({"unhidetargetgui","unhidegui"},{"unhidetargetgui","Restores GUIs hidden by hidetargetgui"},function()
	const n = NAmanage.TargetGuiRestore(NAStuff.TargetGuiHidePrev)
	DoNotif(("Restored %d hidden GUI object(s)."):format(n), 2, "Target GUI")
end)

cmd.add({"showtargetgui","onlygui"},{"showtargetgui <name>","Shows only a specific GUI by name"},function(...)
	const args = {...}
	const query = (Concat(args, " "):match("^%s*(.-)%s*$"))
	if query == "" then
		DebugNotif("Usage: showtargetgui <name>", 3)
		return
	end
	const matches = NAmanage.TargetGuiFind(query)
	if #matches == 0 then
		DebugNotif("No GUI found matching: "..query, 3)
		return
	end

	const keep = {}
	for _, inst in matches do
		keep[inst] = true
		for _, desc in NAmanage.QueryDescendants(inst, "Instance") do
			if NAmanage.TargetGuiIsUi(desc) then
				keep[desc] = true
			end
		end
		local parent = inst.Parent
		while parent do
			if NAmanage.TargetGuiIsUi(parent) then
				keep[parent] = true
			end
			parent = parent.Parent
		end
	end

	const store = NAStuff.TargetGuiShowPrev
	local changed = 0
	for _, inst in NAmanage.TargetGuiCollectUi() do
		NAmanage.TargetGuiSaveState(store, inst)
		if NAmanage.TargetGuiSetShown(inst, keep[inst] == true) then
			changed += 1
		end
	end
	DoNotif(("Showing only '%s' (%d GUI object(s) updated)."):format(query, changed), 3, "Target GUI")
end)

cmd.add({"unshowtargetgui","restoreguis"},{"unshowtargetgui","Restores GUI states changed by showtargetgui"},function()
	const n = NAmanage.TargetGuiRestore(NAStuff.TargetGuiShowPrev)
	DoNotif(("Restored %d GUI object(s)."):format(n), 2, "Target GUI")
end)

spinThingy = nil
spinPart = nil

cmd.add({"spin"}, {"spin {amount}", "Makes your character spin as fast as you want"}, function(...)
	Wait()

	local spinSpeed = (...)
	if not spinSpeed then spinSpeed = 20 end

	if spinThingy then
		spinThingy:Destroy()
		spinThingy = nil
	end

	if spinPart then
		spinPart:Destroy()
		spinPart = nil
	end

	spinPart = InstanceNew("Part")
	spinPart.Anchored = false
	spinPart.CanCollide = false
	spinPart.Transparency = 1
	spinPart.Size = Vector3.new(1, 1, 1)
	NAmanage.Helper_StoreInstance(spinPart)
	spinPart.CFrame = getRoot(LocalPlayer.Character).CFrame

	spinThingy = InstanceNew("BodyAngularVelocity")
	spinThingy.Parent = spinPart
	spinThingy.MaxTorque = Vector3.new(0, math.huge, 0)
	spinThingy.AngularVelocity = Vector3.new(0, spinSpeed, 0)

	const weld = InstanceNew("WeldConstraint")
	weld.Part0 = spinPart
	weld.Part1 = getRoot(LocalPlayer.Character)
	weld.Parent = spinPart

	DebugNotif("Spinning...")
end, true)

cmd.add({"unspin"}, {"unspin", "Makes your character unspin"}, function()
	Wait()

	if spinThingy then
		spinThingy:Destroy()
		spinThingy = nil
	end

	if spinPart then
		spinPart:Destroy()
		spinPart = nil
	end

	DebugNotif("Spin Disabled", 3)
end)

cmd.add({"notepad","npad"},{"notepad","integrated notepad"},function()
	if NAmanage.Notepad_Toggle then
		NAmanage.Notepad_Toggle()
	else
		DoNotif("Notepad UI unavailable.", 3)
	end
end)

cmd.add({"rc7"},{"rc7","RC7 Internal UI"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/rc%20sexy%207")
end)

cmd.add({"scriptviewer","viewscripts"},{"scriptviewer (viewscripts)","Can view scripts made by 0866"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/scriptviewer",true)
end)

cmd.add({"moduleeditor","moduletable","modulartable","mtable","mt"},{"moduleeditor","loads the module editor UI"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/ModuleEditor.lua")
end)

cmd.add({"upvalueeditor","upvaleditor","uveditor","upeditor","uve"},{"upvalueeditor","loads the upvalue editor UI"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/UpvalueEditor.lua")
end)

cmd.add({"hydroxide","hydro"},{"hydroxide (hydro)","executes hydroxide"},function()
	Spawn(function()
		Wait(0.85)
		const user = "ltseverydayyou"
		const repo = "uuuuuuu"
		const branch = "main"
		const repoPath = "Hydroxide"

		const function webImport(file)
			const url = ("https://raw.githubusercontent.com/%s/%s/%s/%s/%s.lua"):format(user, repo, branch, repoPath, file)
			return loadstring(NAmanage.HttpGetOrError(url, { timeout = 10 }), file..".luau")()
		end

		webImport("init")
		webImport("ui/main")
	end)
end)

cmd.add({"remotespy","simplespy","rspy"},{"remotespy (simplespy,rspy)","executes simplespy that supports both pc and mobile"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/SimpleSpyRework.luau")
end)

cmd.add({"cobaltspy","cobalt","cspy"},{"cobaltspy (cobalt,cspy)"},function()
	NAmanage.RunURL("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau")
end)

cmd.add({"turtlespy","tspy"},{"turtlespy (tspy)","executes Turtle Spy that supports both pc and mobile"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Turtle%20Spy.lua")
end)

cmd.add({"gravity","grav"},{"gravity <amount> (grav)","sets game gravity to whatever u want"},function(...)
	Services.Workspace.Gravity=(...)
end,true)

cmd.add({"fireclickdetectors","fcd","firecd"},{"fireclickdetectors (fcd,firecd)","Fires every ClickDetector in Workspace"},function(...)
	const args={...}
	const targetText = args[1] and Concat(args," ")
	const target = targetText and Lower(targetText) or nil
	if typeof(fireclickdetector)~="function" then return DoNotif("fireclickdetector not available",3) end
	NAindex.init()
	local list,f={},0
	for _,inst in InstancesTbl.click or {} do
		if inst and inst.Parent then
			const names = NAindex.namesForClick(inst)
			if NAindex.matchAny(names, target) then
				Insert(list,inst)
			end
		end
	end
	if #list==0 then
		if target then return DebugNotif("No ClickDetectors found matching \""..targetText.."\"",2) end
		return DebugNotif("No ClickDetectors found",2)
	end
	for _,d in list do
		if not pcall(fireclickdetector, d) then f += 1 end
	end
	Wait()
	if f>0 then
		DebugNotif(("Fired %d ClickDetectors, Failed: %d"):format(#list,f),2)
	else
		DebugNotif(("Fired %d ClickDetectors"):format(#list),2)
	end
end,true)

cmd.add({"fireclickdetectorsfind","fcdfind","firecdfind"},{"fireclickdetectorsfind <target> (fcdfind,firecdfind)","Fires ClickDetectors substring-matching [target] in Workspace"},function(...)
	const args={...}
	if not args[1] then return DebugNotif("Usage: fireclickdetectorsfind <target>",2) end
	const targetText = Concat(args," ")
	const target = Lower(targetText)
	if typeof(fireclickdetector)~="function" then return DoNotif("fireclickdetector not available",3) end
	NAindex.init()
	local list,f={},0
	for _,inst in InstancesTbl.click or {} do
		if inst and inst.Parent then
			const names = NAindex.namesForClick(inst)
			if NAindex.matchAnyFind(names, target) then
				Insert(list,inst)
			end
		end
	end
	if #list==0 then
		return DebugNotif(("No ClickDetectors found matching \"%s\""):format(targetText),2)
	end
	for _,d in list do
		if not pcall(fireclickdetector, d) then f += 1 end
	end
	Wait()
	if f>0 then
		DebugNotif(("Fired %d ClickDetectors, Failed: %d"):format(#list,f),2)
	else
		DebugNotif(("Fired %d ClickDetectors"):format(#list),2)
	end
end,true)

cmd.add({"fireproximityprompts","fpp","firepp"},{"fireproximityprompts (fpp,firepp)","Fires every ProximityPrompt in Workspace"},function(...)
	const args={...}
	const targetText = args[1] and Concat(args," ")
	const target = targetText and Lower(targetText) or nil
	if typeof(fireproximityprompt)~="function" then return DoNotif("fireproximityprompt not available",3) end
	NAindex.init()
	local list,f={},0
	for _,inst in InstancesTbl.proxy or {} do
		if inst and inst.Parent and inst.Enabled then
			const names = NAindex.namesForPrompt(inst)
			if NAindex.matchAny(names, target) then
				Insert(list,inst)
			end
		end
	end
	if #list==0 then
		if target then return DebugNotif("No ProximityPrompts found matching \""..targetText.."\"",2) end
		return DebugNotif("No ProximityPrompts found",2)
	end
	for _,p in list do
		const ok = pcall(fireproximityprompt, p)
		if not ok then
			f += 1
		end
	end
	Wait()
	if f>0 then
		DebugNotif(("Fired %d ProximityPrompts, Failed: %d"):format(#list,f),2)
	else
		DebugNotif(("Fired %d ProximityPrompts"):format(#list),2)
	end
end,true)

cmd.add({"fireproximitypromptsfind","fppfind","fireppfind"},{"fireproximitypromptsfind <target> (fppfind,fireppfind)","Fires ProximityPrompts substring-matching [target] in Workspace"},function(...)
	const args={...}
	if not args[1] then return DebugNotif("Usage: fireproximitypromptsfind <target>",2) end
	const targetText = Concat(args," ")
	const target = Lower(targetText)
	if typeof(fireproximityprompt)~="function" then return DoNotif("fireproximityprompt not available",3) end
	NAindex.init()
	local list,f={},0
	for _,inst in InstancesTbl.proxy or {} do
		if inst and inst.Parent and inst.Enabled then
			const names = NAindex.namesForPrompt(inst)
			if NAindex.matchAnyFind(names, target) then
				Insert(list,inst)
			end
		end
	end
	if #list==0 then
		return DebugNotif(("No ProximityPrompts found matching \"%s\""):format(targetText),2)
	end
	for _,p in list do
		const ok = pcall(fireproximityprompt, p)
		if not ok then
			f += 1
		end
	end
	Wait()
	if f>0 then
		DebugNotif(("Fired %d ProximityPrompts, Failed: %d"):format(#list,f),2)
	else
		DebugNotif(("Fired %d ProximityPrompts"):format(#list),2)
	end
end,true)

cmd.add({"firetouchinterests","fti"},{"firetouchinterests (fti)","Fires every TouchInterest in Workspace"},function(...)
	const args = {...}
	const targetText = args[1] and Concat(args," ")
	const target = targetText and Lower(targetText) or nil
	if typeof(firetouchinterest) ~= "function" then return end
	const char = getChar()
	const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
	if not root then return end
	NAindex.init()
	local found = 0
	for _,ti in InstancesTbl.touch or {} do
		const container = ti.Parent
		if container and container.Parent then
			const part = NAindex.carPart(container)
			if part and part.Parent then
				const names = {}
				if ti.Name and ti.Name ~= "" then Insert(names, NAindex.lc(ti.Name)) end
				if container.Name and container.Name ~= "" then Insert(names, NAindex.lc(container.Name)) end
				if part.Name and part.Name ~= "" then Insert(names, NAindex.lc(part.Name)) end
				local model = part:FindFirstAncestorWhichIsA("Model")
				while model do
					if model.Name and model.Name ~= "" then Insert(names, NAindex.lc(model.Name)) end
					model = model:FindFirstAncestorWhichIsA("Model")
				end
				if NAindex.matchAny(names, target) then
					found += 1
					const targetPart = part
					SpawnCall(function()
						const orig = targetPart.CFrame
						targetPart.CFrame = root.CFrame
						firetouchinterest(targetPart,root,1)
						Wait()
						firetouchinterest(targetPart,root,0)
						Delay(0.1,function()
							if targetPart and targetPart.Parent then
								targetPart.CFrame = orig
							end
						end)
					end)
				end
			end
		end
	end
	if found == 0 then
		if target then
			DebugNotif(("No TouchInterests found matching \"%s\""):format(targetText),2)
		else
			DebugNotif("No TouchInterests found",2)
		end
	else
		DebugNotif(("Fired %d TouchInterests"):format(found),2)
	end
end,true)

cmd.add({"firetouchinterestsfind","ftifind","firetifind"},{"firetouchinterestsfind <target> (ftifind,firetifind)","Fires TouchInterests substring-matching [target] in Workspace"},function(...)
	const args = {...}
	if not args[1] then return DebugNotif("Usage: firetouchinterestsfind <target>",2) end
	const targetText = Concat(args," ")
	const target = Lower(targetText)
	if typeof(firetouchinterest) ~= "function" then return end
	const char = getChar()
	const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
	if not root then return end
	NAindex.init()
	local found = 0
	for _,ti in InstancesTbl.touch or {} do
		const container = ti.Parent
		if container and container.Parent then
			const part = NAindex.carPart(container)
			if part and part.Parent then
				const names = {}
				if ti.Name and ti.Name ~= "" then Insert(names, NAindex.lc(ti.Name)) end
				if container.Name and container.Name ~= "" then Insert(names, NAindex.lc(container.Name)) end
				if part.Name and part.Name ~= "" then Insert(names, NAindex.lc(part.Name)) end
				local model = part:FindFirstAncestorWhichIsA("Model")
				while model do
					if model.Name and model.Name ~= "" then Insert(names, NAindex.lc(model.Name)) end
					model = model:FindFirstAncestorWhichIsA("Model")
				end
				if NAindex.matchAnyFind(names, target) then
					found += 1
					const targetPart = part
					SpawnCall(function()
						const orig = targetPart.CFrame
						targetPart.CFrame = root.CFrame
						firetouchinterest(targetPart,root,1)
						Wait()
						firetouchinterest(targetPart,root,0)
						Delay(0.1,function()
							if targetPart and targetPart.Parent then
								targetPart.CFrame = orig
							end
						end)
					end)
				end
			end
		end
	end
	if found == 0 then
		DebugNotif(("No TouchInterests found matching \"%s\""):format(targetText),2)
	else
		DebugNotif(("Fired %d TouchInterests"):format(found),2)
	end
end,true)

NAutil.parseInterval = function(defaultInterval, ...)
	const args = { ... }
	const n1 = tonumber(args[1])
	if n1 then
		return n1, (args[2] and Lower(Concat(args, " ", 2)) or nil)
	else
		return defaultInterval, (args[1] and Lower(Concat(args, " ", 1)) or nil)
	end
end

NAmanage.getAutoInteractDefaultInterval = function()
	return math.clamp(tonumber(NAStuff.AutoInteractDefaultInterval) or 0.1, 0, 1)
end

NAmanage.getAutoFireRemoteDefaultInterval = function()
	return math.clamp(tonumber(NAStuff.AutoFireRemoteDefaultInterval) or NAmanage.getAutoInteractDefaultInterval(), 0, 1)
end

promptPartCache = NAmanage.ensureWeakTable(nil, "k")
carPartCache = NAmanage.ensureWeakTable(nil, "k")
promptNamesCache = NAmanage.ensureWeakTable(nil, "k")
clickNamesCache = NAmanage.ensureWeakTable(nil, "k")
partNamesCache = NAmanage.ensureWeakTable(nil, "k")

NAindex.pruneCaches = function()
	NAmanage.pruneInstanceKeyMap(promptPartCache)
	NAmanage.pruneInstanceValueMap(promptPartCache)
	NAmanage.pruneInstanceKeyMap(carPartCache)
	NAmanage.pruneInstanceValueMap(carPartCache)
	NAmanage.pruneInstanceKeyMap(promptNamesCache)
	NAmanage.pruneInstanceKeyMap(clickNamesCache)
	NAmanage.pruneInstanceKeyMap(partNamesCache)
end

NAindex.lc = function(s)
	if s then
		return Lower(s)
	end
	return ""
end

NAindex.carPart = function(inst)
	if not inst then
		return nil
	end
	if not NAmanage.isLiveInstance(inst) then
		carPartCache[inst] = nil
		return nil
	end
	const c = carPartCache[inst]
	if c ~= nil then
		if c == false then
			return nil
		end
		if NAmanage.isLiveInstance(c) then
			return c
		end
		carPartCache[inst] = nil
	end
	local part
	if inst:IsA("BasePart") then
		part = inst
	elseif inst:IsA("Attachment") then
		const p = inst.Parent
		if p and p:IsA("BasePart") then
			part = p
		end
	end
	if not part then
		if inst:IsA("Model") then
			part = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
		else
			const parent = inst.Parent
			if parent and parent:IsA("Model") then
				part = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)
			end
		end
	end
	if not part then
		part = inst:FindFirstAncestorWhichIsA("BasePart")
	end
	carPartCache[inst] = part or false
	return part
end

NAindex.getPromptPart = function(pp)
	if not pp then
		return nil
	end
	if not NAmanage.isLiveInstance(pp) then
		promptPartCache[pp] = nil
		return nil
	end
	const c = promptPartCache[pp]
	if c ~= nil then
		if c == false then
			return nil
		end
		if NAmanage.isLiveInstance(c) then
			return c
		end
		promptPartCache[pp] = nil
	end
	const parent = pp.Parent
	local part
	if parent then
		if parent:IsA("Attachment") then
			const p = parent.Parent
			if p and p:IsA("BasePart") then
				part = p
			end
		elseif parent:IsA("BasePart") then
			part = parent
		end
	end
	if not part then
		const model = pp:FindFirstAncestorWhichIsA("Model")
		if model then
			if model.PrimaryPart then
				part = model.PrimaryPart
			else
				part = model:FindFirstChildWhichIsA("BasePart", true)
			end
		end
	end
	if not part then
		part = pp:FindFirstAncestorWhichIsA("BasePart")
	end
	promptPartCache[pp] = part or false
	return part
end

NAindex.namesForPrompt = function(p)
	if not NAmanage.isLiveInstance(p) then
		promptNamesCache[p] = nil
		return {}
	end
	const cached = promptNamesCache[p]
	if cached then
		return cached
	end
	const names = {}
	if p.Name then
		Insert(names, p.Name)
	end
	if p.ObjectText then
		Insert(names, p.ObjectText)
	end
	if p.ActionText then
		Insert(names, p.ActionText)
	end
	const parent = p.Parent
	if parent and parent.Name then
		Insert(names, parent.Name)
	end
	const part = NAindex.getPromptPart(p)
	if part then
		Insert(names, part.Name)
		local m = part:FindFirstAncestorWhichIsA("Model")
		while m do
			Insert(names, m.Name)
			m = m:FindFirstAncestorWhichIsA("Model")
		end
	else
		local m = p:FindFirstAncestorWhichIsA("Model")
		while m do
			Insert(names, m.Name)
			m = m:FindFirstAncestorWhichIsA("Model")
		end
	end
	for i = 1, #names do
		names[i] = NAindex.lc(names[i])
	end
	promptNamesCache[p] = names
	return names
end

NAindex.namesForClick = function(d)
	if not NAmanage.isLiveInstance(d) then
		clickNamesCache[d] = nil
		return {}
	end
	const cached = clickNamesCache[d]
	if cached then
		return cached
	end
	const names = {}
	if d.Name then
		Insert(names, d.Name)
	end
	const parent = d.Parent
	if parent and parent.Name then
		Insert(names, parent.Name)
	end
	const part = NAindex.carPart(parent or d)
	if part then
		Insert(names, part.Name)
		local m = part:FindFirstAncestorWhichIsA("Model")
		while m do
			Insert(names, m.Name)
			m = m:FindFirstAncestorWhichIsA("Model")
		end
	end
	for i = 1, #names do
		names[i] = NAindex.lc(names[i])
	end
	clickNamesCache[d] = names
	return names
end

NAindex.namesForPart = function(part)
	if not part or not NAmanage.isLiveInstance(part) then
		if part then
			partNamesCache[part] = nil
		end
		return {}
	end
	const cached = partNamesCache[part]
	if cached then
		return cached
	end
	const names = {}
	Insert(names, NAindex.lc(part.Name))
	local m = part:FindFirstAncestorWhichIsA("Model")
	while m do
		Insert(names, NAindex.lc(m.Name))
		m = m:FindFirstAncestorWhichIsA("Model")
	end
	partNamesCache[part] = names
	return names
end

NAindex.matchAny = function(names, target)
	target = NAindex.lc(target)
	if not target or target == "" then
		return true
	end
	for i = 1, #names do
		if names[i] == target then
			return true
		end
	end
	return false
end

NAindex.matchAnyFind = function(names, target)
	target = NAindex.lc(target)
	if not target or target == "" then
		return true
	end
	for i = 1, #names do
		const n = names[i]
		if n == target or Find(n, target, 1, true) then
			return true
		end
	end
	return false
end

NAindex.promptTarget = function(pp)
	const part = NAindex.getPromptPart(pp)
	return part, part and part.Position or nil
end

NAindex.clickTarget = function(cd)
	const part = NAindex.carPart(cd.Parent or cd)
	return part, part and part.Position or nil
end

NAmanage.GotoInteractable = function(kind, ...)
	const args = {...}
	const targetText = args[1] and Concat(args, " ") or nil
	const target = targetText and Lower(targetText) or nil
	local char = getChar()
	local root = char and getRoot(char)
	if not (char and root) then
		return DebugNotif("Your character is invalid", 3)
	end

	NAindex.init()
	const isPrompt = kind == "prompt"
	const isClick = kind == "click"
	const isTouch = kind == "touch"
	const source = isPrompt and (InstancesTbl.proxy or {})
		or isClick and (InstancesTbl.click or {})
		or isTouch and (InstancesTbl.touch or {})
		or {}
	const label = isPrompt and "ProximityPrompt"
		or isClick and "ClickDetector"
		or isTouch and "TouchInterest"
		or "Interactable"
	local bestInst, bestPart, bestDistance, bestScore
	const rootPos = NAmanage.UG_clientPosition(root) or root.Position

	for _, inst in source do
		if inst and inst.Parent then
			local names, part
			if isPrompt then
				names = NAindex.namesForPrompt(inst)
				part = select(1, NAindex.promptTarget(inst))
			elseif isClick then
				names = NAindex.namesForClick(inst)
				part = select(1, NAindex.clickTarget(inst))
			elseif isTouch then
				const container = inst.Parent
				part = NAindex.carPart(container)
				names = {}
				if inst.Name and inst.Name ~= "" then Insert(names, NAindex.lc(inst.Name)) end
				if container and container.Name and container.Name ~= "" then Insert(names, NAindex.lc(container.Name)) end
				if part and part.Name and part.Name ~= "" then Insert(names, NAindex.lc(part.Name)) end
				local model = part and part:FindFirstAncestorWhichIsA("Model") or nil
				while model do
					if model.Name and model.Name ~= "" then Insert(names, NAindex.lc(model.Name)) end
					model = model:FindFirstAncestorWhichIsA("Model")
				end
			end

			local score = 0
			if not target or target == "" then
				score = 1
			elseif NAindex.matchAny(names or {}, target) then
				score = 2
			elseif NAindex.matchAnyFind(names or {}, target) then
				score = 1
			end

			if score > 0 and part and part.Parent then
				const distance = (part.Position - rootPos).Magnitude
				if not bestPart or score > bestScore or (score == bestScore and distance < bestDistance) then
					bestInst = inst
					bestPart = part
					bestDistance = distance
					bestScore = score
				end
			end
		end
	end

	if not bestPart then
		if targetText then
			return DebugNotif(("No %ss found matching \"%s\""):format(label, targetText), 2)
		end
		return DebugNotif("No "..label.."s found", 2)
	end

	const hum = getHum()
	if hum then
		hum.Sit = false
		Wait(0.1)
	end

	char = getChar()
	root = char and getRoot(char)
	if not (char and root and bestPart and bestPart.Parent) then
		return DebugNotif("Teleport target is no longer available", 2)
	end

	if NAmanage.UG_pivotModel(char, bestPart:GetPivot()) then
		DebugNotif(("Teleported to %s \"%s\""):format(label, bestInst and bestInst.Name or bestPart.Name), 2)
	else
		DebugNotif("Failed to teleport to "..label, 2)
	end
end

cmd.add({"proximitypromptgoto", "promptgoto", "ppgoto"}, {"proximitypromptgoto [name] (promptgoto, ppgoto)", "Teleports to the nearest ProximityPrompt part, optionally matching its name/object/action/parent/model"}, function(...)
	NAmanage.GotoInteractable("prompt", ...)
end, true)

cmd.add({"clickdetectorgoto", "clickgoto", "cdgoto"}, {"clickdetectorgoto [name] (clickgoto, cdgoto)", "Teleports to the nearest ClickDetector part, optionally matching its name/parent/model"}, function(...)
	NAmanage.GotoInteractable("click", ...)
end, true)

cmd.add({"touchinterestgoto", "touchgoto", "tigoto"}, {"touchinterestgoto [name] (touchgoto, tigoto)", "Teleports to the nearest TouchInterest part, optionally matching its name/parent/part/model"}, function(...)
	NAmanage.GotoInteractable("touch", ...)
end, true)

NAmanage.ClickTouchGetConfig = function()
	local maxDistance = math.floor((tonumber(NAStuff.ClickTouchMaxDistance) or 1024) + 0.5)
	if maxDistance > 0 then
		maxDistance = math.clamp(maxDistance, 50, 5000)
	else
		maxDistance = 0
	end
	return {
		maxDistance = maxDistance;
		screenRadius = math.clamp(math.floor((tonumber(NAStuff.ClickTouchScreenRadius) or 18) + 0.5), 2, 80);
		blockedByCollide = NAStuff.ClickTouchBlockedByCollide ~= false;
		ignoreNonCollideBlockers = NAStuff.ClickTouchIgnoreNonCollideBlockers ~= false;
		invisibleFallback = NAStuff.ClickTouchInvisibleFallback ~= false;
		alwaysOnTop = NAStuff.ClickTouchAlwaysOnTop == true;
	}
end

NAmanage.ClickTouchFindTouchForPart = function(part)
	if not (part and part:IsA("BasePart")) then
		return nil
	end
	if not (InstancesTbl and type(InstancesTbl.touch) == "table") then
		return nil
	end
	for _, ti in InstancesTbl.touch do
		if ti and ti.Parent then
			const touchPart = NAindex.carPart(ti.Parent)
			if touchPart == part then
				return ti, touchPart
			end
		end
	end
	return nil
end

NAmanage.ClickTouchName = function(ti, part)
	const names = {}
	if part and part.Name and part.Name ~= "" then
		Insert(names, part.Name)
	end
	const parent = part and part.Parent
	if parent and parent:IsA("Model") and parent.Name and parent.Name ~= "" then
		Insert(names, 1, parent.Name)
	end
	if ti and ti.Name and ti.Name ~= "" and ti.Name ~= "TouchInterest" then
		Insert(names, ti.Name)
	end
	if #names > 0 then
		return table.concat(names, " / ")
	end
	return "TouchTransmitter"
end

NAmanage.ClickTouchMouseRay = function(mouse)
	if not mouse then
		return nil
	end

	local okOrigin, origin = pcall(function()
		return mouse.Origin
	end)
	local okHit, hit = pcall(function()
		return mouse.Hit
	end)
	if not (okOrigin and typeof(origin) == "CFrame" and okHit and typeof(hit) == "CFrame") then
		return nil
	end

	const delta = hit.Position - origin.Position
	if delta.Magnitude <= 0.001 then
		return nil
	end
	return origin.Position, delta.Unit
end

NAmanage.ClickTouchOccludedByCollide = function(origin, targetPart, cfg, excludeList)
	if not (origin and targetPart and targetPart:IsA("BasePart") and Services.Workspace and Services.Workspace.Raycast) then
		return false
	end
	cfg = cfg or NAmanage.ClickTouchGetConfig()
	if cfg.blockedByCollide ~= true then
		return false
	end
	const targetPos = targetPart.Position
	const delta = targetPos - origin
	const distance = delta.Magnitude
	if distance <= 0 then
		return false
	end
	const params = RaycastParams.new()
	NAmanage._raycastFilterType(params)
	params.IgnoreWater = true
	const filter = NAmanage._raycastFilterList(excludeList)
	const direction = delta.Unit
	for _ = 1, 32 do
		params.FilterDescendantsInstances = filter
		const result = Services.Workspace:Raycast(origin, direction * distance, params)
		const hit = result and result.Instance
		if not hit then
			return false
		end
		if hit == targetPart or hit:IsDescendantOf(targetPart) then
			return false
		end
		if hit:IsA("BasePart") and hit.CanCollide then
			return true
		end
		if cfg.ignoreNonCollideBlockers ~= true then
			return true
		end
		Insert(filter, hit)
	end
	return false
end

NAmanage.ClickTouchPickRaycast = function(mouse, excludeList, cfg)
	if not (mouse and Services.Workspace and Services.Workspace.Raycast) then
		return nil
	end
	cfg = cfg or NAmanage.ClickTouchGetConfig()
	local origin, direction = NAmanage.ClickTouchMouseRay(mouse)
	if not origin then
		return nil
	end
	const params = RaycastParams.new()
	NAmanage._raycastFilterType(params)
	params.IgnoreWater = true
	const filter = NAmanage._raycastFilterList(excludeList)
	local maxDistance = tonumber(cfg.maxDistance) or 1024
	if maxDistance <= 0 then
		maxDistance = 1000000
	end
	for _ = 1, 80 do
		params.FilterDescendantsInstances = filter
		const result = Services.Workspace:Raycast(origin, direction * maxDistance, params)
		const part = result and result.Instance
		if not (part and part:IsA("BasePart")) then
			return nil
		end
		local ti, touchPart = NAmanage.ClickTouchFindTouchForPart(part)
		if ti and touchPart then
			return touchPart, ti, result, "raycast"
		end
		if cfg.blockedByCollide == true and part.CanCollide then
			return nil, nil, result, "blocked"
		end
		if cfg.blockedByCollide == true and cfg.ignoreNonCollideBlockers ~= true then
			return nil, nil, result, "blocked"
		end
		Insert(filter, part)
	end
	return nil
end

NAmanage.ClickTouchPickInvisible = function(mouse, excludeList, cfg)
	if not (mouse and Services.Workspace and Services.Workspace.CurrentCamera and InstancesTbl and type(InstancesTbl.touch) == "table") then
		return nil
	end
	cfg = cfg or NAmanage.ClickTouchGetConfig()
	if cfg.invisibleFallback ~= true then
		return nil
	end
	local origin, direction = NAmanage.ClickTouchMouseRay(mouse)
	if not origin then
		return nil
	end
	const camera = Services.Workspace.CurrentCamera
	const mousePos = Vector2.new(tonumber(mouse.X) or 0, tonumber(mouse.Y) or 0)
	local bestPart, bestTi, bestScore
	const maxDistance = tonumber(cfg.maxDistance) or 1024
	const unlimitedDistance = maxDistance <= 0
	for _, ti in InstancesTbl.touch do
		if ti and ti.Parent then
			const part = NAindex.carPart(ti.Parent)
			if part and part.Parent and part:IsA("BasePart") then
				const toPart = part.Position - origin
				const rayDistance = toPart:Dot(direction)
				if rayDistance > 0 and (unlimitedDistance or rayDistance <= maxDistance) then
					const closest = origin + direction * rayDistance
					const worldMiss = (closest - part.Position).Magnitude
					const radius = math.max(part.Size.Magnitude * 0.5, 0.5)
					if worldMiss <= radius then
						local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
						if onScreen then
							const screenMiss = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
							if screenMiss <= (cfg.screenRadius or 18) + math.min(60, radius * 8) then
								if not NAmanage.ClickTouchOccludedByCollide(origin, part, cfg, excludeList) then
									const score = screenMiss + (rayDistance * 0.001)
									if not bestScore or score < bestScore then
										bestPart, bestTi, bestScore = part, ti, score
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if bestPart and bestTi then
		return bestPart, bestTi, nil, "invisible"
	end
	return nil
end

NAmanage.ClickTouchPickTarget = function(mouse, excludeList)
	NAindex.init()
	const cfg = NAmanage.ClickTouchGetConfig()
	local part, ti, result, mode = NAmanage.ClickTouchPickRaycast(mouse, excludeList, cfg)
	if part and ti then
		return part, ti, result, mode
	end
	if mode == "blocked" then
		return nil, nil, result, mode
	end
	return NAmanage.ClickTouchPickInvisible(mouse, excludeList, cfg)
end

NAmanage.ClickTouchFire = function(part)
	if typeof(firetouchinterest) ~= "function" then
		return false, "firetouchinterest not available"
	end
	if not (part and part.Parent and part:IsA("BasePart")) then
		return false, "No touch part selected"
	end
	const char = getChar()
	const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
	if not root then
		return false, "Character root not found"
	end
	const orig = part.CFrame
	pcall(function()
		part.CFrame = root.CFrame
	end)
	pcall(firetouchinterest, part, root, 1)
	Wait()
	pcall(firetouchinterest, part, root, 0)
	Delay(0.1, function()
		if part and part.Parent then
			pcall(function()
				part.CFrame = orig
			end)
		end
	end)
	return true
end

NAindex.inRangePrompt = function(pp, rootPos, extra)
	local part, pos = NAindex.promptTarget(pp)
	if not pos then
		return false, math.huge, part
	end
	const dist = (pos - rootPos).Magnitude
	const maxd = (pp.MaxActivationDistance or 0) + (extra or 0)
	return dist <= maxd, dist, part
end

NAindex.inRangeClick = function(cd, rootPos, extra)
	local part, pos = NAindex.clickTarget(cd)
	if not pos then
		return false, math.huge, part
	end
	const dist = (pos - rootPos).Magnitude
	const maxd = (cd.MaxActivationDistance or 0) + (extra or 0)
	return dist <= maxd, dist, part
end

NAindex.init = function(opts)
	if NAindex._init and not (opts and opts.force == true) then return end
	if NAmanage.ensureInteractionIndex then
		NAindex._init = true
		NAmanage.ensureInteractionIndex(opts)
	else
		NAindex._init = false
	end
end

NAsuppress._acquire = function(pp)
	const r = NAsuppress.ref[pp] or 0
	if r == 0 then
		NAsuppress.snap[pp] = pp.Enabled
		pp.Enabled = false
	end
	NAsuppress.ref[pp] = r + 1
end

NAsuppress._release = function(pp)
	local r = NAsuppress.ref[pp]
	if not r then return end
	r -= 1
	if r <= 0 then
		const prev = NAsuppress.snap[pp]
		if prev ~= nil and pp and pp.Parent then
			pp.Enabled = prev
		end
		NAsuppress.ref[pp] = nil
		NAsuppress.snap[pp] = nil
	else
		NAsuppress.ref[pp] = r
	end
end

NAsuppress.collectAndAcquire = function(centerPos, radius, allowSet)
	NAindex.init()
	const list = {}
	if InstancesTbl and type(InstancesTbl.proxy) == "table" then
		for _, p in InstancesTbl.proxy do
			if p and p.Parent and p.Enabled and not (allowSet and allowSet[p]) then
				local _, pos = NAindex.promptTarget(p)
				if pos and (pos - centerPos).Magnitude <= radius then
					NAsuppress._acquire(p)
					Insert(list, p)
				end
			end
		end
	end
	return list
end

NAsuppress.releaseList = function(list)
	for _, p in list do
		NAsuppress._release(p)
	end
end

NAjobs._tracked = NAjobs._tracked or {}
NAjobs._tracked.prompt = NAjobs._tracked.prompt or { list = {}, idx = {} }
NAjobs._tracked.click = NAjobs._tracked.click or { list = {}, idx = {} }
NAjobs._tracked.remote = NAjobs._tracked.remote or { list = {}, idx = {} }

NAjobs._trackedAdd = function(kind, inst)
	if not inst then
		return
	end
	const bucket = NAjobs._tracked[kind]
	if not bucket then
		return
	end
	if bucket.idx[inst] then
		return
	end
	const list = bucket.list
	const n = #list + 1
	list[n] = inst
	bucket.idx[inst] = n
end

NAjobs._trackedRemove = function(kind, inst)
	if not inst then
		return
	end
	const bucket = NAjobs._tracked[kind]
	if not bucket then
		return
	end
	const idx = bucket.idx[inst]
	if not idx then
		return
	end
	const list = bucket.list
	const last = #list
	const repl = list[last]
	list[last] = nil
	if idx ~= last then
		list[idx] = repl
		if repl then
			bucket.idx[repl] = idx
		end
	end
	bucket.idx[inst] = nil
	if kind == "prompt" and type(NAjobs._lastPromptFire) == "table" then
		NAjobs._lastPromptFire[inst] = nil
	elseif kind == "click" and type(NAjobs._lastClickFire) == "table" then
		NAjobs._lastClickFire[inst] = nil
	elseif kind == "remote" and type(NAjobs._lastRemoteFire) == "table" then
		NAjobs._lastRemoteFire[inst] = nil
	end
	if #list <= 0 then
		if kind == "prompt" then
			NAjobs._promptCursor = 0
		elseif kind == "click" then
			NAjobs._clickCursor = 0
		elseif kind == "remote" then
			NAjobs._remoteCursor = 0
		end
	end
end

NAjobs._ensureTracked = function()
	if NAjobs._trackedReady then
		return
	end
	NAjobs._trackedReady = true
	if NAmanage.ensureInteractionIndex then
		NAmanage.ensureInteractionIndex()
	end
	if InstancesTbl and type(InstancesTbl.proxy) == "table" then
		for _, inst in InstancesTbl.proxy do
			if inst and inst.Parent then
				NAjobs._trackedAdd("prompt", inst)
			end
		end
	end
	if InstancesTbl and type(InstancesTbl.click) == "table" then
		for _, inst in InstancesTbl.click do
			if inst and inst.Parent then
				NAjobs._trackedAdd("click", inst)
			end
		end
	elseif not NAmanage.ensureInteractionIndex then
		for _, inst in NAmanage.QueryDescendants(Services.Workspace, "ProximityPrompt") do
			NAjobs._trackedAdd("prompt", inst)
		end
		for _, inst in NAmanage.QueryDescendants(Services.Workspace, "ClickDetector") do
			NAjobs._trackedAdd("click", inst)
		end
	end
	NAlib.connect("NAjobs_track_add", NAmanage.descAdd(Services.Workspace, function(inst)
		if inst:IsA("ProximityPrompt") then
			NAjobs._trackedAdd("prompt", inst)
		elseif inst:IsA("ClickDetector") then
			NAjobs._trackedAdd("click", inst)
		end
	end, function(inst)
		return inst and (inst:IsA("ProximityPrompt") or inst:IsA("ClickDetector"))
	end))
	NAlib.connect("NAjobs_track_rem", NAmanage.descRem(Services.Workspace, function(inst)
		if inst:IsA("ProximityPrompt") then
			NAjobs._trackedRemove("prompt", inst)
		elseif inst:IsA("ClickDetector") then
			NAjobs._trackedRemove("click", inst)
		end
	end))
end

NAjobs._isRemote = function(inst)
	return typeof(inst) == "Instance" and (inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") or inst:IsA("RemoteFunction"))
end

NAjobs._skipRemoteRoot = function(inst)
	const cg = Services.CoreGui
	if typeof(inst) ~= "Instance" or typeof(cg) ~= "Instance" then
		return false
	end
	if inst == cg then
		return true
	end
	local ok, res = pcall(function()
		return inst:IsDescendantOf(cg)
	end)
	return ok and res == true
end

NAjobs._ensureRemoteTracked = function()
	NAjobs._tracked.remote = NAjobs._tracked.remote or { list = {}, idx = {} }
	if NAjobs._remoteTrackedReady then
		return
	end
	NAjobs._remoteTrackedReady = true

	const q = { game }
	local qi, qn = 1, 1
	local step = 0
	while qi <= qn do
		const inst = q[qi]
		q[qi] = nil
		qi += 1

		if typeof(inst) == "Instance" and not NAjobs._skipRemoteRoot(inst) then
			if NAjobs._isRemote(inst) then
				NAjobs._trackedAdd("remote", inst)
			end

			local ok, ch = pcall(function()
				return inst:GetChildren()
			end)
			if ok and type(ch) == "table" then
				for i = 1, #ch do
					const c = ch[i]
					if not NAjobs._skipRemoteRoot(c) then
						qn += 1
						q[qn] = c
					end
				end
			end
		end

		step += 1
		if step >= 180 then
			step = 0
			Wait()
		end
	end

	NAlib.connect("NAjobs_remote_add", NAmanage.descAdd(game, function(inst)
		if NAjobs._isRemote(inst) and not NAjobs._skipRemoteRoot(inst) then
			NAjobs._trackedAdd("remote", inst)
		end
	end, function(inst)
		return NAjobs._isRemote(inst) and not NAjobs._skipRemoteRoot(inst)
	end))
	NAlib.connect("NAjobs_remote_rem", NAmanage.descRem(game, function(inst)
		if NAjobs._isRemote(inst) then
			NAjobs._trackedRemove("remote", inst)
		end
	end))
end

NAjobs._remoteFullName = function(r)
	local ok, res = pcall(function()
		return r:GetFullName()
	end)
	return ok and tostring(res or r.Name) or tostring(r and r.Name or "Remote")
end

NAjobs._fireRemote = function(r)
	if not NAjobs._isRemote(r) or not (r and r.Parent) then
		return false
	end
	if r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") then
		return pcall(function()
			r:FireServer()
		end)
	end
	NAjobs._remoteInvokeBusy = NAjobs._remoteInvokeBusy or NAmanage.ensureWeakTable(nil, "k")
	if NAjobs._remoteInvokeBusy[r] then
		return false
	end
	NAjobs._remoteInvokeBusy[r] = true
	SpawnCall(function()
		pcall(function()
			r:InvokeServer()
		end)
		if NAjobs._remoteInvokeBusy then
			NAjobs._remoteInvokeBusy[r] = nil
		end
	end)
	return true
end

NAjobs._resolvePromptPart = function(pp)
	if not (pp and pp.Parent) then
		return nil
	end
	const parent = pp.Parent
	if parent:IsA("Attachment") then
		const p = parent.Parent
		if p and p:IsA("BasePart") then
			return p
		end
	elseif parent:IsA("BasePart") then
		return parent
	end
	const model = pp:FindFirstAncestorWhichIsA("Model")
	if model then
		return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	end
	return pp:FindFirstAncestorWhichIsA("BasePart")
end

NAjobs._resolveClickPart = function(cd)
	if not (cd and cd.Parent) then
		return nil
	end
	const src = cd.Parent
	if src:IsA("BasePart") then
		return src
	end
	if src:IsA("Model") then
		return src.PrimaryPart or src:FindFirstChildWhichIsA("BasePart", true)
	end
	const model = cd:FindFirstAncestorWhichIsA("Model")
	if model then
		return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
	end
	return cd:FindFirstAncestorWhichIsA("BasePart")
end

NAjobs._collectNames = function(kind, inst, part)
	const names = {}
	const function add(v)
		if not v then
			return
		end
		const s = Lower(tostring(v))
		if s ~= "" then
			names[#names + 1] = s
		end
	end
	if kind == "prompt" then
		add(inst.Name)
		add(inst.ObjectText)
		add(inst.ActionText)
		const parent = inst.Parent
		if parent then
			add(parent.Name)
		end
	elseif kind == "remote" then
		add(inst.Name)
		const fn = NAjobs._remoteFullName(inst)
		add(fn)
		if fn ~= "" then
			add("game."..fn)
		end
		local parent = inst.Parent
		while parent and parent ~= game do
			add(parent.Name)
			parent = parent.Parent
		end
	else
		add(inst.Name)
		const parent = inst.Parent
		if parent then
			add(parent.Name)
		end
	end
	if part then
		add(part.Name)
		local m = part:FindFirstAncestorWhichIsA("Model")
		while m do
			add(m.Name)
			m = m:FindFirstAncestorWhichIsA("Model")
		end
	end
	return names
end

NAjobs._matchNames = function(matcher, names, target)
	if not target or target == "" then
		return true
	end
	return matcher(names, target)
end

NAjobs._claim = function(key)
	if not key then return true end
	if NAjobs._claimed[key] == NAjobs._frame then return false end
	NAjobs._claimed[key] = NAjobs._frame
	return true
end

NAjobs._restoreTouchDue = function()
	const now = time()
	for part, st in NAjobs._touchState do
		if st.moved and st.restoreAt and now >= st.restoreAt then
			if part and part.Parent then
				part.CFrame = st.orig
			end
			st.moved = false
			st.orig = nil
			st.restoreAt = nil
			NAjobs._touchState[part] = nil
		end
	end
end

NAjobs._effectiveInterval = function(job, zeroCount)
	const ivl = tonumber(job and job.interval) or 0
	if ivl > 0 then
		return ivl
	end
	const minIvl = math.max(0.01, tonumber(NAjobs._zeroMinInterval) or 0.03)
	const targetTPS = math.max(1, tonumber(NAjobs._zeroTargetTicksPerSecond) or 45)
	return math.max(minIvl, (tonumber(zeroCount) or 1) / targetTPS)
end

NAjobs._enqueue = function(job)
	const tail = (NAjobs._qTail or 0) + 1
	NAjobs._qTail = tail
	NAjobs._q[tail] = job
end

NAjobs._dequeue = function()
	local head = NAjobs._qHead or 1
	const tail = NAjobs._qTail or 0
	if head > tail then
		return nil
	end
	const job = NAjobs._q[head]
	NAjobs._q[head] = nil
	head += 1
	if head > tail then
		NAjobs._qHead = 1
		NAjobs._qTail = 0
	else
		NAjobs._qHead = head
	end
	return job
end

NAjobs._buildTargetPlan = function(dueJobs)
	const plan = {
		all = false,
		exact = {},
		findList = {},
	}
	const findSeen = {}
	for i = 1, #dueJobs do
		const job = dueJobs[i]
		const target = job and job.target
		if not target or target == "" then
			plan.all = true
		elseif job.useFind then
			if not findSeen[target] then
				findSeen[target] = true
				Insert(plan.findList, target)
			end
		else
			plan.exact[target] = true
		end
	end
	return plan
end

NAjobs._matchesTargetPlan = function(names, plan)
	if plan.all then
		return true
	end
	for i = 1, #names do
		if plan.exact[names[i]] then
			return true
		end
	end
	const findList = plan.findList
	for i = 1, #findList do
		const target = findList[i]
		for j = 1, #names do
			const name = names[j]
			if name == target or Find(name, target, 1, true) then
				return true
			end
		end
	end
	return false
end

NAjobs._batchInterval = function(dueJobs, zeroCount, floor)
	local minInterval = nil
	for i = 1, #dueJobs do
		const job = dueJobs[i]
		if job and NAjobs.jobs[job.id] == job then
			const ivl = NAjobs._effectiveInterval(job, zeroCount)
			if not minInterval or ivl < minInterval then
				minInterval = ivl
			end
		end
	end
	if not minInterval then
		minInterval = 0.1
	end
	const minFloor = tonumber(floor) or 0
	if minInterval < minFloor then
		minInterval = minFloor
	end
	return minInterval
end

NAjobs._canRefire = function(lastMap, inst, now, cooldown)
	if type(lastMap) ~= "table" or not inst then
		return true
	end
	const cd = tonumber(cooldown) or 0
	if cd <= 0 then
		return true
	end
	const last = tonumber(lastMap[inst]) or 0
	return (now - last) >= cd
end

NAjobs._promptFireBusy = NAmanage.ensureWeakKeyTable(nil)
NAjobs._promptUnblockBusy = NAmanage.ensureWeakKeyTable(nil)

NAjobs._promptInteractionContainer = function(inst)
	if not (inst and inst.Parent) then
		return nil
	end
	local node = inst.Parent
	for _ = 1, 6 do
		if not node then
			break
		end
		if node:IsA("Model") then
			return node
		end
		node = node.Parent
	end
	return inst.Parent
end

NAjobs._promptCoveredByActiveJob = function(inst)
	if not (inst and inst.Parent) then
		return false
	end
	const part = NAjobs._resolvePromptPart(inst)
	const names = NAjobs._collectNames("prompt", inst, part)
	for _, job in NAjobs.jobs do
		if job and job.kind == "prompt" then
			if not job.target or job.target == "" then
				return true
			end
			const matcher = job.m or (job.useFind and NAindex.matchAnyFind or NAindex.matchAny)
			if NAjobs._matchNames(matcher, names, job.target) then
				return true
			end
		end
	end
	return false
end

NAjobs._snapshotContainerPrompts = function(container, ignore)
	const snapshot = NAmanage.ensureWeakKeyTable(nil)
	if not (container and container.Parent) then
		return snapshot
	end
	for _, pp in NAmanage.QueryDescendants(container, "ProximityPrompt") do
		if pp ~= ignore and pp.Parent then
			snapshot[pp] = pp.Enabled == true
		end
	end
	return snapshot
end

NAjobs._dispatchPromptUnblocker = function(inst)
	if not (inst and inst.Parent and inst.Enabled) then
		return false
	end
	local busyMap = NAjobs._promptUnblockBusy
	if type(busyMap) ~= "table" then
		busyMap = NAmanage.ensureWeakKeyTable(nil)
		NAjobs._promptUnblockBusy = busyMap
	end
	if busyMap[inst] or (NAjobs._promptFireBusy and NAjobs._promptFireBusy[inst]) then
		return false
	end
	busyMap[inst] = true
	Spawn(function()
		pcall(fireproximityprompt, inst)
		busyMap[inst] = nil
	end)
	return true
end

NAjobs._watchPromptBlocker = function(source, container, before)
	if not (source and container and container.Parent) then
		return
	end
	Spawn(function()
		for _ = 1, 8 do
			Wait(0.05)
			if not (container and container.Parent) then
				return
			end
			for _, pp in NAmanage.QueryDescendants(container, "ProximityPrompt") do
				if pp ~= source and pp.Parent and pp.Enabled then
					const previous = before[pp]
					if previous ~= true and not NAjobs._promptCoveredByActiveJob(pp) then
						NAjobs._dispatchPromptUnblocker(pp)
						return
					end
				end
			end
		end
	end)
end

NAjobs._dispatchPromptFire = function(inst, lastMap, now)
	if not (inst and inst.Parent) then
		return false
	end
	local busyMap = NAjobs._promptFireBusy
	if type(busyMap) ~= "table" then
		busyMap = NAmanage.ensureWeakKeyTable(nil)
		NAjobs._promptFireBusy = busyMap
	end
	if busyMap[inst] then
		return false
	end
	const container = NAjobs._promptInteractionContainer(inst)
	const before = NAjobs._snapshotContainerPrompts(container, inst)
	busyMap[inst] = true
	if type(lastMap) == "table" then
		lastMap[inst] = tonumber(now) or time()
	end
	NAjobs._watchPromptBlocker(inst, container, before)
	Spawn(function()
		pcall(fireproximityprompt, inst)
		busyMap[inst] = nil
	end)
	return true
end

NAjobs._runPromptBatch = function(dueJobs)
	const char = getChar()
	const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
	if not root then
		return
	end
	const rootPos = root.Position
	const useRange = NAStuff.AutoInteractDistanceEnabled ~= false
	const extraRange = tonumber(NAStuff.AutoInteractExtraRange) or 5
	const tracked = (NAjobs._tracked.prompt and NAjobs._tracked.prompt.list) or {}
	const trackedCount = #tracked
	if trackedCount <= 0 then
		NAjobs._promptCursor = 0
		return
	end
	const plan = NAjobs._buildTargetPlan(dueJobs)
	const needsNames = not plan.all and (next(plan.exact) ~= nil or #plan.findList > 0)
	const maxFires = math.max(1, math.floor(tonumber(NAjobs._promptMaxFiresPerBatch) or 18))
	local scanBudget = math.max(1, math.floor(tonumber(NAjobs._promptScanPerBatch) or trackedCount))
	if scanBudget < maxFires then
		scanBudget = maxFires
	end
	if scanBudget > trackedCount then
		scanBudget = trackedCount
	end
	const cursor = tonumber(NAjobs._promptCursor) or 0
	local cooldown = tonumber(NAjobs._promptRefireFloor) or 0
	const dynamicFloor = NAjobs._batchInterval(dueJobs, 0, 0)
	if dynamicFloor > cooldown then
		cooldown = dynamicFloor
	end
	const now = time()
	const stale = {}
	local fired = 0
	local lastMap = NAjobs._lastPromptFire
	if type(lastMap) ~= "table" then
		lastMap = {}
		NAjobs._lastPromptFire = lastMap
	end
	for step = 1, scanBudget do
		if fired >= maxFires then
			break
		end
		const idx = ((cursor + step - 1) % trackedCount) + 1
		const inst = tracked[idx]
		if not (inst and inst.Parent) then
			if inst then
				Insert(stale, inst)
			end
		else
			const part = NAjobs._resolvePromptPart(inst)
			if part and inst.Enabled then
				local ok = true
				if needsNames then
					const names = NAjobs._collectNames("prompt", inst, part)
					ok = NAjobs._matchesTargetPlan(names, plan)
				end
				if ok and useRange then
					const dist = (part.Position - rootPos).Magnitude
					ok = dist <= ((inst.MaxActivationDistance or 0) + extraRange)
				end
				if ok and not NAjobs._promptFireBusy[inst] and NAjobs._claim(inst) and NAjobs._canRefire(lastMap, inst, now, cooldown) then
					if NAjobs._dispatchPromptFire(inst, lastMap, now) then
						fired += 1
					end
				end
			end
		end
	end
	NAjobs._promptCursor = (cursor + scanBudget) % trackedCount
	for i = 1, #stale do
		NAjobs._trackedRemove("prompt", stale[i])
	end
end

NAjobs._runClickBatch = function(dueJobs)
	const char = getChar()
	const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
	if not root then
		return
	end
	const rootPos = root.Position
	const useRange = NAStuff.AutoInteractDistanceEnabled ~= false
	const extraRange = tonumber(NAStuff.AutoInteractExtraRange) or 5
	const tracked = (NAjobs._tracked.click and NAjobs._tracked.click.list) or {}
	const trackedCount = #tracked
	if trackedCount <= 0 then
		NAjobs._clickCursor = 0
		return
	end
	const plan = NAjobs._buildTargetPlan(dueJobs)
	const needsNames = not plan.all and (next(plan.exact) ~= nil or #plan.findList > 0)
	const maxFires = math.max(1, math.floor(tonumber(NAjobs._clickMaxFiresPerBatch) or 18))
	local scanBudget = math.max(1, math.floor(tonumber(NAjobs._clickScanPerBatch) or trackedCount))
	if scanBudget < maxFires then
		scanBudget = maxFires
	end
	if scanBudget > trackedCount then
		scanBudget = trackedCount
	end
	const cursor = tonumber(NAjobs._clickCursor) or 0
	local cooldown = tonumber(NAjobs._clickRefireFloor) or 0
	const dynamicFloor = NAjobs._batchInterval(dueJobs, 0, 0)
	if dynamicFloor > cooldown then
		cooldown = dynamicFloor
	end
	const now = time()
	const stale = {}
	local fired = 0
	local lastMap = NAjobs._lastClickFire
	if type(lastMap) ~= "table" then
		lastMap = {}
		NAjobs._lastClickFire = lastMap
	end
	for step = 1, scanBudget do
		if fired >= maxFires then
			break
		end
		const idx = ((cursor + step - 1) % trackedCount) + 1
		const inst = tracked[idx]
		if not (inst and inst.Parent) then
			if inst then
				Insert(stale, inst)
			end
		else
			const part = NAjobs._resolveClickPart(inst)
			if part then
				local ok = true
				if needsNames then
					const names = NAjobs._collectNames("click", inst, part)
					ok = NAjobs._matchesTargetPlan(names, plan)
				end
				if ok and useRange then
					const dist = (part.Position - rootPos).Magnitude
					ok = dist <= ((inst.MaxActivationDistance or 0) + extraRange)
				end
				if ok and NAjobs._claim(inst) and NAjobs._canRefire(lastMap, inst, now, cooldown) then
					const okFire = pcall(fireclickdetector, inst)
					if okFire then
						lastMap[inst] = now
						fired += 1
					end
				end
			end
		end
	end
	NAjobs._clickCursor = (cursor + scanBudget) % trackedCount
	for i = 1, #stale do
		NAjobs._trackedRemove("click", stale[i])
	end
end


NAjobs._runRemoteBatch = function(dueJobs)
	NAjobs._ensureRemoteTracked()
	const tracked = (NAjobs._tracked.remote and NAjobs._tracked.remote.list) or {}
	const trackedCount = #tracked
	if trackedCount <= 0 then
		NAjobs._remoteCursor = 0
		return
	end
	const plan = NAjobs._buildTargetPlan(dueJobs)
	const needsNames = not plan.all and (next(plan.exact) ~= nil or #plan.findList > 0)
	const maxFires = math.max(1, math.floor(tonumber(NAjobs._remoteMaxFiresPerBatch) or 12))
	local scanBudget = math.max(1, math.floor(tonumber(NAjobs._remoteScanPerBatch) or trackedCount))
	if scanBudget < maxFires then
		scanBudget = maxFires
	end
	if scanBudget > trackedCount then
		scanBudget = trackedCount
	end
	const cursor = tonumber(NAjobs._remoteCursor) or 0
	local cooldown = tonumber(NAjobs._remoteRefireFloor) or 0
	const dynamicFloor = NAjobs._batchInterval(dueJobs, 0, 0)
	if dynamicFloor > cooldown then
		cooldown = dynamicFloor
	end
	const now = time()
	const stale = {}
	local fired = 0
	local lastMap = NAjobs._lastRemoteFire
	if type(lastMap) ~= "table" then
		lastMap = {}
		NAjobs._lastRemoteFire = lastMap
	end
	local scanned = 0
	for step = 1, scanBudget do
		if fired >= maxFires then
			break
		end
		scanned = step
		const idx = ((cursor + step - 1) % trackedCount) + 1
		const inst = tracked[idx]
		if not (inst and inst.Parent) then
			if inst then
				Insert(stale, inst)
			end
		else
			local ok = true
			if needsNames then
				const names = NAjobs._collectNames("remote", inst)
				ok = NAjobs._matchesTargetPlan(names, plan)
			end
			if ok and NAjobs._claim(inst) and NAjobs._canRefire(lastMap, inst, now, cooldown) then
				const okFire = NAjobs._fireRemote(inst)
				if okFire then
					lastMap[inst] = now
					fired += 1
				end
			end
		end
	end
	if scanned <= 0 then
		scanned = scanBudget
	end
	NAjobs._remoteCursor = (cursor + scanned) % trackedCount
	for i = 1, #stale do
		NAjobs._trackedRemove("remote", stale[i])
	end
end

NAjobs._jobMethod = function(job)
	if not job then
		return NAmanage.GetAutoFireDefaultMethod("prompt")
	end
	return NAmanage.SanitizeLoopMethod(job.method or NAmanage.GetAutoFireDefaultMethod(job.kind))
end

NAjobs._batchNextFor = function(kind, method)
	NAjobs._batchNext = type(NAjobs._batchNext) == "table" and NAjobs._batchNext or {}
	NAjobs._batchNext[kind] = type(NAjobs._batchNext[kind]) == "table" and NAjobs._batchNext[kind] or {}
	return NAjobs._batchNext[kind], NAmanage.SanitizeLoopMethod(method or "PostSimulation")
end

NAjobs._runStep = function(method)
	method = method and NAmanage.SanitizeLoopMethod(method) or nil
	NAjobs._frame = (NAjobs._frame or 0) + 1
	NAjobs._claimed = {}
	const now = time()
	local zeroCount = 0
	const duePrompt = {}
	const dueClick = {}
	const dueRemote = {}
	const dueOther = {}
	for _, job in NAjobs.jobs do
		if method and NAjobs._jobMethod(job) ~= method then
			continue
		end
		if job.interval <= 0 then
			zeroCount += 1
		end
		if now >= (job.next or 0) then
			if job.kind == "prompt" then
				Insert(duePrompt, job)
			elseif job.kind == "click" then
				Insert(dueClick, job)
			elseif job.kind == "remote" then
				Insert(dueRemote, job)
			else
				Insert(dueOther, job)
			end
		end
	end

	local ranPromptBatch = false
	local ranClickBatch = false
	local ranRemoteBatch = false
	if #duePrompt > 0 then
		NAjobs._promptBatchBucket, NAjobs._promptBatchKey = NAjobs._batchNextFor("prompt", method)
		const nextAt = tonumber(NAjobs._promptBatchBucket[NAjobs._promptBatchKey]) or 0
		if now >= nextAt then
			NAjobs._runPromptBatch(duePrompt)
			ranPromptBatch = true
			NAjobs._promptBatchBucket[NAjobs._promptBatchKey] = now + NAjobs._batchInterval(duePrompt, zeroCount, NAjobs._promptBatchFloor)
		end
	end
	if #dueClick > 0 then
		NAjobs._clickBatchBucket, NAjobs._clickBatchKey = NAjobs._batchNextFor("click", method)
		const nextAt = tonumber(NAjobs._clickBatchBucket[NAjobs._clickBatchKey]) or 0
		if now >= nextAt then
			NAjobs._runClickBatch(dueClick)
			ranClickBatch = true
			NAjobs._clickBatchBucket[NAjobs._clickBatchKey] = now + NAjobs._batchInterval(dueClick, zeroCount, NAjobs._clickBatchFloor)
		end
	end
	if #dueRemote > 0 then
		NAjobs._remoteBatchBucket, NAjobs._remoteBatchKey = NAjobs._batchNextFor("remote", method)
		const nextAt = tonumber(NAjobs._remoteBatchBucket[NAjobs._remoteBatchKey]) or 0
		if now >= nextAt then
			NAjobs._runRemoteBatch(dueRemote)
			ranRemoteBatch = true
			NAjobs._remoteBatchBucket[NAjobs._remoteBatchKey] = now + NAjobs._batchInterval(dueRemote, zeroCount, NAjobs._remoteBatchFloor)
		end
	end
	if ranPromptBatch then
		for i = 1, #duePrompt do
			const job = duePrompt[i]
			if NAjobs.jobs[job.id] == job then
				job.next = now + NAjobs._effectiveInterval(job, zeroCount)
			end
		end
	end
	if ranClickBatch then
		for i = 1, #dueClick do
			const job = dueClick[i]
			if NAjobs.jobs[job.id] == job then
				job.next = now + NAjobs._effectiveInterval(job, zeroCount)
			end
		end
	end
	if ranRemoteBatch then
		for i = 1, #dueRemote do
			const job = dueRemote[i]
			if NAjobs.jobs[job.id] == job then
				job.next = now + NAjobs._effectiveInterval(job, zeroCount)
			end
		end
	end

	const budget = math.max(1, math.floor(tonumber(NAjobs._maxTicksPerStep) or 2))
	local ran = 0
	for i = 1, #dueOther do
		if ran >= budget then
			break
		end
		const job = dueOther[i]
		if NAjobs.jobs[job.id] == job then
			job.next = now + NAjobs._effectiveInterval(job, zeroCount)
			pcall(job.tick, job)
			ran += 1
		end
	end
	NAjobs._restoreTouchDue()
end

NAjobs._sigKey = function(method)
	return "NAjobs_stp_"..NAmanage.SanitizeLoopMethod(method or "PostSimulation")
end

NAjobs._activeMethods = function()
	const methods = {}
	for _, job in NAjobs.jobs do
		if job then
			methods[NAjobs._jobMethod(job)] = true
		end
	end
	return methods
end

NAjobs._connectMethod = function(method)
	const picked = NAmanage.SanitizeLoopMethod(method or "PostSimulation")
	NAjobs.hb = type(NAjobs.hb) == "table" and NAjobs.hb or {}
	NAjobs._accum = type(NAjobs._accum) == "table" and NAjobs._accum or {}
	if NAjobs.hb[picked] then
		return
	end
	const sig = NAmanage.GetLoopSignal(picked)
	if not sig then
		return
	end
	const key = NAjobs._sigKey(picked)
	NAlib.disconnect(key)
	NAjobs._accum[picked] = 0
	NAjobs.hb[picked] = true
	NAlib.connect(key, sig:Connect(function(...)
		if not (NAjobs.hb and NAjobs.hb[picked]) then
			NAlib.disconnect(key)
			return
		end
		local step = tonumber(NAjobs._stepInterval) or (1 / 120)
		if step <= 0 then
			step = 1 / 120
		end
		const maxCatch = math.max(1, math.floor(tonumber(NAjobs._maxCatchUpSteps) or 6))
		local delta = NAmanage.GetLoopDt(...)
		if delta < 0 then
			delta = 0
		end
		NAjobs._accum[picked] = (tonumber(NAjobs._accum[picked]) or 0) + delta

		local loops = 0
		while NAjobs._accum[picked] >= step and loops < maxCatch do
			NAjobs._accum[picked] -= step
			loops += 1
			NAjobs._runStep(picked)
		end

		const maxAccum = step * maxCatch
		if NAjobs._accum[picked] > maxAccum then
			NAjobs._accum[picked] = maxAccum
		end
	end))
end

NAjobs._schedule = function()
	NAjobs.hb = type(NAjobs.hb) == "table" and NAjobs.hb or {}
	const active = NAjobs._activeMethods()
	for method in NAjobs.hb do
		if not active[method] then
			NAlib.disconnect(NAjobs._sigKey(method))
			NAjobs.hb[method] = nil
			if type(NAjobs._accum) == "table" then
				NAjobs._accum[method] = nil
			end
		end
	end
	for method in active do
		NAjobs._connectMethod(method)
	end
end

NAjobs._reschedule = function()
	if type(NAjobs.hb) == "table" then
		for method in NAjobs.hb do
			NAlib.disconnect(NAjobs._sigKey(method))
		end
	end
	NAjobs.hb = {}
	NAjobs._accum = {}
	NAjobs._batchNext = { prompt = {}, click = {}, remote = {} }
	NAjobs._schedule()
end

NAjobs._maybeStop = function()
	if not next(NAjobs.jobs) then
		if type(NAjobs.hb) == "table" then
			for method in NAjobs.hb do
				NAlib.disconnect(NAjobs._sigKey(method))
			end
		end
		NAjobs.hb = {}
		NAjobs._q = {}
		NAjobs._qHead = 1
		NAjobs._qTail = 0
		NAjobs._accum = {}
		NAjobs._batchNext = { prompt = {}, click = {}, remote = {} }
		NAjobs._promptBatchNext = 0
		NAjobs._clickBatchNext = 0
		NAjobs._remoteBatchNext = 0
		NAjobs._promptCursor = 0
		NAjobs._clickCursor = 0
		NAjobs._remoteCursor = 0
		NAjobs._lastPromptFire = {}
		NAjobs._lastClickFire = {}
		NAjobs._lastRemoteFire = {}
		NAjobs._remoteInvokeBusy = NAmanage.ensureWeakTable(nil, "k")
		NAjobs._claimed = {}
	else
		NAjobs._schedule()
	end
end

NAjobs._findExisting = function(kind, target, useFind)
	const findMode = useFind and true or false
	for id, job in NAjobs.jobs do
		if job.kind == kind and (job.target or nil) == target and (job.useFind and true or false) == findMode then
			return id, job
		end
	end
	return nil
end

NAjobs._nextIdForKind = function(kind)
	const used = {}
	for id, job in NAjobs.jobs do
		if job.kind == kind then
			const n = tonumber(tostring(id):match("^"..kind.."#(%d+)$"))
			if n then used[n] = true end
		end
	end
	local i = 1
	while used[i] do i += 1 end
	return kind.."#"..tostring(i)
end

NAjobs.start = function(kind, interval, target, useFind, method)
	NAindex.init()
	if kind == "prompt" or kind == "click" then
		NAjobs._ensureTracked()
	elseif kind == "remote" then
		NAjobs._ensureRemoteTracked()
	end
	const tgt = target and Lower(target) or nil
	const ivl = interval or 0.1
	const ivlClamped = math.max(0, ivl)
	const staggerCap = math.max(0, tonumber(NAjobs._staggerCap) or 0.003)
	const stagger = ivlClamped > 0 and math.min(staggerCap, ivlClamped / 48) or 0
	const matcher = useFind and NAindex.matchAnyFind or NAindex.matchAny
	const pickedMethod = NAmanage.SanitizeLoopMethod(method or NAmanage.GetAutoFireDefaultMethod(kind))
	local existingId, existingJob = NAjobs._findExisting(kind, tgt, useFind)
	if existingJob then
		existingJob.interval = ivlClamped
		existingJob.target = tgt
		existingJob.m = matcher
		existingJob.useFind = useFind and true or false
		existingJob.stagger = stagger
		existingJob.method = pickedMethod
		existingJob.next = time()
		return existingId, true
	end
	const id = NAjobs._nextIdForKind(kind)
	const job = {
		id = id,
		kind = kind,
		interval = ivlClamped,
		target = tgt,
		next = time(),
		stagger = stagger,
		method = pickedMethod,
		m = matcher,
		useFind = useFind and true or false
	}
	if kind == "prompt" then
		job.tick = function(self)
			const char = getChar()
			const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
			if not root then
				return
			end
			const rootPos = root.Position
			const useRange = NAStuff.AutoInteractDistanceEnabled ~= false
			const extraRange = tonumber(NAStuff.AutoInteractExtraRange) or 5
			const tracked = (NAjobs._tracked.prompt and NAjobs._tracked.prompt.list) or {}
			const hasTarget = self.target ~= nil and self.target ~= ""
			for i = #tracked, 1, -1 do
				const inst = tracked[i]
				if not (inst and inst.Parent) then
					NAjobs._trackedRemove("prompt", inst)
				else
					const part = NAjobs._resolvePromptPart(inst)
					if not part then
						continue
					end
					local ok = true
					if hasTarget then
						const names = NAjobs._collectNames("prompt", inst, part)
						ok = NAjobs._matchNames(self.m, names, self.target)
					end
					if ok and useRange then
						const dist = (part.Position - rootPos).Magnitude
						ok = dist <= ((inst.MaxActivationDistance or 0) + extraRange)
					end
					if ok and part and inst.Enabled then
						pcall(fireproximityprompt, inst)
					end
				end
			end
		end
	elseif kind == "click" then
		job.tick = function(self)
			const char = getChar()
			const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
			if not root then
				return
			end
			const rootPos = root.Position
			const useRange = NAStuff.AutoInteractDistanceEnabled ~= false
			const extraRange = tonumber(NAStuff.AutoInteractExtraRange) or 5
			const tracked = (NAjobs._tracked.click and NAjobs._tracked.click.list) or {}
			const hasTarget = self.target ~= nil and self.target ~= ""
			for i = #tracked, 1, -1 do
				const inst = tracked[i]
				if not (inst and inst.Parent) then
					NAjobs._trackedRemove("click", inst)
				else
					const part = NAjobs._resolveClickPart(inst)
					if not part then
						continue
					end
					local ok = true
					if hasTarget then
						const names = NAjobs._collectNames("click", inst, part)
						ok = NAjobs._matchNames(self.m, names, self.target)
					end
					if ok and useRange then
						const dist = (part.Position - rootPos).Magnitude
						ok = dist <= ((inst.MaxActivationDistance or 0) + extraRange)
					end
					if ok and part then
						pcall(fireclickdetector, inst)
					end
				end
			end
		end
	elseif kind == "remote" then
		job.tick = function() end
	elseif kind == "touch" then
		job.tick = function(self)
			if not InstancesTbl or type(InstancesTbl.touch) ~= "table" then
				return
			end
			const char = getChar()
			const root = char and (getRoot(char) or char:FindFirstChildWhichIsA("BasePart"))
			if not root or (not root:IsDescendantOf(Services.Workspace)) then
				return
			end
			const list = {}
			const touchTbl = InstancesTbl.touch
			const hasTarget = self.target ~= nil and self.target ~= ""
			for i = 1, #touchTbl do
				const ti = touchTbl[i]
				if ti then
					const container = ti.Parent
					if container and container.Parent then
						const part = NAindex.carPart(container)
						if part then
							local ok = false
							if hasTarget then
								const names = NAindex.namesForPart(part)
								if self.m(names, self.target) then
									ok = true
								end
							else
								ok = true
							end
							if ok then
								const asm = part.AssemblyRootPart or part
								if asm then
									const n = #list + 1
									list[n] = {
										part = asm
									}
								end
							end
						end
					end
				end
			end
			for _, it in list do
				if NAjobs._claim(it.part) then
					Spawn(function()
						const asm = it.part
						if not asm or (not asm.Parent) or (not asm:IsDescendantOf(Services.Workspace)) then
							return
						end
						local st = NAjobs._touchState[asm]
						if not st or (not st.moved) then
							st = st or {}
							st.orig = asm.CFrame
							st.moved = true
							NAjobs._touchState[asm] = st
						end
						const char2 = getChar()
						const root2 = char2 and (getRoot(char2) or char2:FindFirstChildWhichIsA("BasePart"))
						if not root2 or (not root2:IsDescendantOf(Services.Workspace)) then
							return
						end
						asm:PivotTo(root2.CFrame)
						pcall(firetouchinterest, asm, root2, 1)
						Wait()
						pcall(firetouchinterest, asm, root2, 0)
						st.restoreAt = time() + 0.05
					end)
				end
			end
		end
	end
	NAjobs.jobs[id] = job
	NAjobs._schedule()
	return id
end

NAjobs._restoreAllTouch = function()
	for part, st in NAjobs._touchState do
		if st.moved and st.orig and part and part.Parent then
			part.CFrame = st.orig
		end
		NAjobs._touchState[part] = nil
	end
end

NAjobs.stopByKind = function(kind)
	for id, job in NAjobs.jobs do
		if job.kind == kind then NAjobs.jobs[id] = nil end
	end
	if kind == "touch" then NAjobs._restoreAllTouch() end
	NAjobs._maybeStop()
end

NAjobs.stopById = function(id)
	const job = NAjobs.jobs[id]
	if not job then return end
	NAjobs.jobs[id] = nil
	if job.kind == "touch" then NAjobs._restoreAllTouch() end
	NAjobs._maybeStop()
end

NAjobs.stopAll = function()
	for id in NAjobs.jobs do NAjobs.jobs[id] = nil end
	NAjobs._restoreAllTouch()
	NAjobs._maybeStop()
end

NAjobs.setAutoIntervalLink = function(id, linked)
	const job = NAjobs.jobs[id]
	if not job then
		return false
	end
	job.autoIntervalLinked = linked == true
	return true
end

NAjobs.applyLinkedAutoInteractInterval = function(interval)
	const n = tonumber(interval)
	if not n then
		return 0
	end
	const ivl = math.max(0, n)
	local changed = 0
	for _, job in NAjobs.jobs do
		if job and (job.kind == "prompt" or job.kind == "click" or job.kind == "touch") and job.autoIntervalLinked == true then
			job.interval = ivl
			job.next = time()
			changed += 1
		end
	end
	return changed
end

NAjobs.applyLinkedAutoFireRemoteInterval = function(interval)
	const n = tonumber(interval)
	if not n then
		return 0
	end
	const ivl = math.max(0, n)
	local changed = 0
	for _, job in NAjobs.jobs do
		if job and job.kind == "remote" and job.autoIntervalLinked == true then
			job.interval = ivl
			job.next = time()
			changed += 1
		end
	end
	return changed
end

NAmanage._sortedJobs = function(kind, useFind)
	const list = {}
	const findMode = useFind and true or false
	for _, job in NAjobs.jobs do
		if job.kind == kind and (job.useFind and true or false) == findMode then
			Insert(list, job)
		end
	end
	table.sort(list, function(a, b)
		const ai = tonumber(tostring(a.id):match("#(%d+)$")) or math.huge
		const bi = tonumber(tostring(b.id):match("#(%d+)$")) or math.huge
		if ai == bi then
			return (a.target or "") < (b.target or "")
		end
		return ai < bi
	end)
	return list
end

function buildStopWindow(kind, titleText, useFind)
	const buttons = {}
	for _, job in NAmanage._sortedJobs(kind, useFind) do
		const label = job.id..(job.target and (" • "..job.target) or "")
		Insert(buttons, {
			Text = label,
			Callback = function()
				NAjobs.stopById(job.id)
				DebugNotif("stopped "..label, 2)
			end
		})
	end
	Insert(buttons, {
		Text = "All",
		Callback = function()
			for jid, j in NAjobs.jobs do
				if j.kind == kind and (j.useFind and true or false) == (useFind and true or false) then
					NAjobs.stopById(jid)
				end
			end
			const suffix = useFind and " (find)" or ""
			DebugNotif("all "..kind..suffix.." stopped", 2)
		end
	})
	Window({
		Title = titleText,
		Buttons = buttons
	})
end

NAmanage._windowStopKind=function(kind, titleText)
	buildStopWindow(kind, titleText, false)
end

NAmanage._windowStopKindFind=function(kind, titleText)
	buildStopWindow(kind, titleText, true)
end

cmd.add({"autofireproxi","afp"},{"autofireproxi <interval> [target]","Automatically fires ProximityPrompts matching [target] every <interval> seconds"}, function(...)
	const args = {...}
	local interval, target
	const defaultInterval = NAmanage.getAutoInteractDefaultInterval()
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	if args[1] and not tonumber(args[1]) then
		interval = defaultInterval
		target = Lower(Concat(args, " ", 1))
	else
		interval, target = NAutil.parseInterval(defaultInterval, ...)
	end
	local id, reused = NAjobs.start("prompt", interval, target)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("afp %s (%s) → %s"):format(action, target, id) or ("afp %s → %s"):format(action, id), 2)
end, true)

cmd.add({"autofireproxifind","afpfind"},{"autofireproxifind <interval> [target]","Automatically fires ProximityPrompts matching [target] using substring matching every <interval> seconds"}, function(...)
	const args = {...}
	local interval, target
	const defaultInterval = NAmanage.getAutoInteractDefaultInterval()
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	if args[1] and not tonumber(args[1]) then
		interval = defaultInterval
		target = Lower(Concat(args, " ", 1))
	else
		interval, target = NAutil.parseInterval(defaultInterval, ...)
	end
	local id, reused = NAjobs.start("prompt", interval, target, true)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("afpfind %s (%s) → %s"):format(action, target, id) or ("afpfind %s → %s"):format(action, id), 2)
end, true)

cmd.add({"autofireclick","afc"},{"autofireclick <interval> [target]","Automatically fires ClickDetectors matching [target] every <interval> seconds"}, function(...)
	const args = {...}
	local interval, target
	const defaultInterval = NAmanage.getAutoInteractDefaultInterval()
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	if args[1] and not tonumber(args[1]) then
		interval = defaultInterval
		target = Lower(Concat(args, " ", 1))
	else
		interval, target = NAutil.parseInterval(defaultInterval, ...)
	end
	local id, reused = NAjobs.start("click", interval, target)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("afc %s (%s) → %s"):format(action, target, id) or ("afc %s → %s"):format(action, id), 2)
end, true)

cmd.add({"autofireclickfind","afcfind"},{"autofireclickfind <interval> [target]","Automatically fires ClickDetectors matching [target] using substring matching every <interval> seconds"}, function(...)
	const args = {...}
	local interval, target
	const defaultInterval = NAmanage.getAutoInteractDefaultInterval()
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	if args[1] and not tonumber(args[1]) then
		interval = defaultInterval
		target = Lower(Concat(args, " ", 1))
	else
		interval, target = NAutil.parseInterval(defaultInterval, ...)
	end
	local id, reused = NAjobs.start("click", interval, target, true)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("afcfind %s (%s) → %s"):format(action, target, id) or ("afcfind %s → %s"):format(action, id), 2)
end, true)

cmd.add({"autotouch","at"},{"autotouch <interval> [target]","Automatically fires TouchInterests on parts matching [target] every <interval> seconds"}, function(...)
	const args = {...}
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	local interval, target = NAutil.parseInterval(NAmanage.getAutoInteractDefaultInterval(), ...)
	local id, reused = NAjobs.start("touch", interval, target)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("at %s (%s) → %s"):format(action, target, id) or ("at %s → %s"):format(action, id), 2)
end, true)

cmd.add({"autotouchfind","atfind"},{"autotouchfind <interval> [target]","Automatically fires TouchInterests on parts matching [target] using substring matching every <interval> seconds"}, function(...)
	const args = {...}
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	local interval, target = NAutil.parseInterval(NAmanage.getAutoInteractDefaultInterval(), ...)
	local id, reused = NAjobs.start("touch", interval, target, true)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("atfind %s (%s) → %s"):format(action, target, id) or ("atfind %s → %s"):format(action, id), 2)
end, true)

cmd.add({"autofireremote","afr"},{"autofireremote <interval> [target]","Automatically fires remotes matching [target] every <interval> seconds"}, function(...)
	const args = {...}
	local interval, target
	const defaultInterval = NAmanage.getAutoFireRemoteDefaultInterval()
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	if args[1] and not tonumber(args[1]) then
		interval = defaultInterval
		target = Lower(Concat(args, " ", 1))
	else
		interval, target = NAutil.parseInterval(defaultInterval, ...)
	end
	local id, reused = NAjobs.start("remote", interval, target)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("afr %s (%s) → %s"):format(action, target, id) or ("afr %s → %s"):format(action, id), 2)
end, true)

cmd.add({"autofireremotefind","afrfind"},{"autofireremotefind <interval> [target]","Automatically fires remotes matching [target] using substring matching every <interval> seconds"}, function(...)
	const args = {...}
	local interval, target
	const defaultInterval = NAmanage.getAutoFireRemoteDefaultInterval()
	const useDefaultInterval = args[1] == nil or not tonumber(args[1])
	if args[1] and not tonumber(args[1]) then
		interval = defaultInterval
		target = Lower(Concat(args, " ", 1))
	else
		interval, target = NAutil.parseInterval(defaultInterval, ...)
	end
	local id, reused = NAjobs.start("remote", interval, target, true)
	NAjobs.setAutoIntervalLink(id, useDefaultInterval)
	const action = reused and "updated" or "started"
	DebugNotif(target and ("afrfind %s (%s) → %s"):format(action, target, id) or ("afrfind %s → %s"):format(action, id), 2)
end, true)

cmd.add({"unautofireproxi","uafp"},{"unautofireproxi (uafp)","Stops all AutoFireProxi loops"}, function()
	NAmanage._windowStopKind("prompt","AutoFireProxi Jobs")
end)

cmd.add({"unautofireclick","uafc"},{"unautofireclick (uafc)","Stops all AutoFireClick loops"}, function()
	NAmanage._windowStopKind("click","AutoFireClick Jobs")
end)

cmd.add({"unautotouch","uat"},{"unautotouch (uat)","Stops all AutoTouch loops"}, function()
	NAmanage._windowStopKind("touch","AutoTouch Jobs")
end)

cmd.add({"unautofireremote","uafr"},{"unautofireremote (uafr)","Stops all AutoFireRemote loops"}, function()
	NAmanage._windowStopKind("remote","AutoFireRemote Jobs")
end)

cmd.add({"unautotouchfind","uatfind"},{"unautotouchfind (uatfind)","Stops substring-matching AutoTouch loops"}, function()
	NAmanage._windowStopKindFind("touch","AutoTouchFind Jobs")
end)

cmd.add({"unautofireproxifind","uafpfind"},{"unautofireproxifind (uafpfind)","Stops substring-matching AutoFireProxi loops"}, function()
	NAmanage._windowStopKindFind("prompt","AutoFireProxiFind Jobs")
end)

cmd.add({"unautofireclickfind","uafcfind"},{"unautofireclickfind (uafcfind)","Stops substring-matching AutoFireClick loops"}, function()
	NAmanage._windowStopKindFind("click","AutoFireClickFind Jobs")
end)

cmd.add({"unautofireremotefind","uafrfind"},{"unautofireremotefind (uafrfind)","Stops substring-matching AutoFireRemote loops"}, function()
	NAmanage._windowStopKindFind("remote","AutoFireRemoteFind Jobs")
end)

cmd.add({"noclickdetectorlimits","nocdlimits","removecdlimits"},{"noclickdetectorlimits <limit> (nocdlimits,removecdlimits)","Sets all click detectors MaxActivationDistance to math.huge"},function(...)
	const limit = (...) or math.huge
	NAindex.init()
	for _,v in InstancesTbl.click do
		v.MaxActivationDistance = limit
	end
end,true)

cmd.add({"noproximitypromptlimits","nopplimits","removepplimits"},{"noproximitypromptlimits <limit> (nopplimits,removepplimits)","Sets all proximity prompts MaxActivationDistance to math.huge"},function(...)
	const limit = (...) or math.huge
	NAindex.init()
	for _,v in InstancesTbl.proxy do
		v.MaxActivationDistance = limit
	end
end,true)

NAStuff.instantProximityPrompts = type(NAStuff.instantProximityPrompts) == "table" and NAStuff.instantProximityPrompts or {}
NAStuff.instantProximityPrompts.active = NAStuff.instantProximityPrompts.active == true
NAStuff.instantProximityPrompts.prompts = NAmanage.ensureWeakKeyTable(NAStuff.instantProximityPrompts.prompts)
NAStuff.fastProximityPrompts = type(NAStuff.fastProximityPrompts) == "table" and NAStuff.fastProximityPrompts or {}
NAStuff.fastProximityPrompts.active = NAStuff.fastProximityPrompts.active == true
NAStuff.fastProximityPrompts.multiplier = math.max(tonumber(NAStuff.fastProximityPrompts.multiplier) or 2, 0.01)
NAStuff.fastProximityPrompts.prompts = NAmanage.ensureWeakKeyTable(NAStuff.fastProximityPrompts.prompts)

NAmanage.InstantProximityPromptsTrack = function(pp)
	const state = NAStuff.instantProximityPrompts
	if state.active ~= true or typeof(pp) ~= "Instance" or not pp:IsA("ProximityPrompt") or state.prompts[pp] then
		return
	end
	local okDuration, duration = pcall(function()
		return pp.HoldDuration
	end)
	if not okDuration then
		return
	end
	const record = {
		restore = duration;
		connection = nil;
	}
	state.prompts[pp] = record
	local okConnection, connection = pcall(function()
		return pp:GetPropertyChangedSignal("HoldDuration"):Connect(function()
			if state.active ~= true or state.prompts[pp] ~= record then
				return
			end
			local okCurrent, current = pcall(function()
				return pp.HoldDuration
			end)
			if okCurrent and current ~= 0 then
				record.restore = current
				pcall(function()
					pp.HoldDuration = 0
				end)
			end
		end)
	end)
	if okConnection then
		record.connection = connection
	end
	pcall(function()
		pp.HoldDuration = 0
	end)
end

NAmanage.InstantProximityPromptsUntrack = function(pp, restore)
	const state = NAStuff.instantProximityPrompts
	const record = state.prompts[pp]
	if not record then
		return
	end
	state.prompts[pp] = nil
	record.connection = NAmanage.tryDisconnect(record.connection)
	if restore == true and typeof(pp) == "Instance" and pp:IsA("ProximityPrompt") then
		pcall(function()
			pp.HoldDuration = record.restore
		end)
	end
end

NAmanage.InstantProximityPromptsDisable = function()
	const state = NAStuff.instantProximityPrompts
	state.active = false
	NAlib.disconnect("instantpp")
	NAmanage.clrWsH("instantpp_duration")
	const prompts = {}
	for pp in state.prompts do
		prompts[#prompts + 1] = pp
	end
	for i = 1, #prompts do
		NAmanage.InstantProximityPromptsUntrack(prompts[i], true)
	end
end

NAmanage.FastProximityPromptsTrack = function(pp)
	const state = NAStuff.fastProximityPrompts
	if state.active ~= true or typeof(pp) ~= "Instance" or not pp:IsA("ProximityPrompt") or state.prompts[pp] then
		return
	end
	local okDuration, duration = pcall(function()
		return pp.HoldDuration
	end)
	if not okDuration then
		return
	end
	const record = {
		restore = duration;
		applied = math.max(duration / state.multiplier, 0);
		connection = nil;
		writing = false;
	}
	state.prompts[pp] = record
	local okConnection, connection = pcall(function()
		return pp:GetPropertyChangedSignal("HoldDuration"):Connect(function()
			if state.active ~= true or state.prompts[pp] ~= record or record.writing then
				return
			end
			local okCurrent, current = pcall(function()
				return pp.HoldDuration
			end)
			if okCurrent and current ~= record.applied then
				record.restore = current
				record.applied = math.max(current / state.multiplier, 0)
				record.writing = true
				pcall(function()
					pp.HoldDuration = record.applied
					record.applied = pp.HoldDuration
				end)
				record.writing = false
			end
		end)
	end)
	if okConnection then
		record.connection = connection
	end
	record.writing = true
	pcall(function()
		pp.HoldDuration = record.applied
		record.applied = pp.HoldDuration
	end)
	record.writing = false
end
