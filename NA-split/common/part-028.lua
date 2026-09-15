flyVariables.uiSpeedBoxes = type(flyVariables.uiSpeedBoxes) == "table" and flyVariables.uiSpeedBoxes or {}

NAmanage._destroyMobileFlyUI=function()
	for m,conn in flyVariables.uiPosConns do
		pcall(function() conn:Disconnect() end)
		flyVariables.uiPosConns[m]=nil
	end
	if flyVariables.uiUpdateConn then pcall(function() flyVariables.uiUpdateConn:Disconnect() end) end
	flyVariables.uiUpdateConn=nil
	NAlib.disconnect("fly_mobile_ui_update")
	for m,speedBox in flyVariables.uiSpeedBoxes do
		if speedBox then pcall(function() speedBox:Destroy() end) end
		flyVariables.uiSpeedBoxes[m]=nil
	end
	if flyVariables.mFlyBruh then pcall(function() flyVariables.mFlyBruh:Destroy() end) flyVariables.mFlyBruh=nil end
	if flyVariables.vRAHH then pcall(function() flyVariables.vRAHH:Destroy() end) flyVariables.vRAHH=nil end
	if flyVariables.cFlyGUI then pcall(function() flyVariables.cFlyGUI:Destroy() end) flyVariables.cFlyGUI=nil end
	if flyVariables.TFLYBTN then pcall(function() flyVariables.TFLYBTN:Destroy() end) flyVariables.TFLYBTN=nil end
	if flyVariables.tflyButtonUI then pcall(function() flyVariables.tflyButtonUI:Destroy() end) flyVariables.tflyButtonUI=nil end
end

NAmanage._ensureMobileFlyUI=function(mode)
	if not IsOnMobile then return end
	NAmanage._destroyMobileFlyUI()
	const mk=function(modeKey,btnText,onToggle,getSpeed,setSpeed,storeRefs)
		local gui=NAStuff.NASCREENGUI
		if typeof(gui)~="Instance" and type(NAmanage.waitForScreenGui)=="function" then
			gui=NAmanage.waitForScreenGui(5)
		end
		if typeof(gui)~="Instance" then return end
		const btn=InstanceNew("TextButton",gui)
		const speedBox=InstanceNew("TextBox",gui)
		const toggleBtn=InstanceNew("TextButton",btn)
		const corner=InstanceNew("UICorner",btn)
		corner.CornerRadius=UDim.new(0,6)
		const corner2=InstanceNew("UICorner",speedBox)
		corner2.CornerRadius=UDim.new(0,6)
		const corner3=InstanceNew("UICorner",toggleBtn)
		corner3.CornerRadius=UDim.new(0,6)
		const aspect=InstanceNew("UIAspectRatioConstraint",btn)
		btn.BackgroundColor3=Color3.fromRGB(30,30,30)
		btn.BackgroundTransparency=0.1
		btn.Position=NAmanage._persist.uiPos[modeKey] or UDim2.new(0.9,0,0.5,0)
		btn.Size=UDim2.new(0.08,0,0.1,0)
		btn.Font=Enum.Font.GothamBold
		btn.Text=btnText()
		btn.TextColor3=Color3.fromRGB(255,255,255)
		btn.TextScaled=true
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
		toggleBtn.BackgroundColor3=Color3.fromRGB(50,50,50)
		toggleBtn.BackgroundTransparency=0.1
		toggleBtn.Position=UDim2.new(0.8,0,-0.1,0)
		toggleBtn.Size=UDim2.new(0.4,0,0.4,0)
		toggleBtn.Font=Enum.Font.SourceSans
		toggleBtn.Text="+"
		toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
		toggleBtn.TextScaled=true
		toggleBtn.AutoButtonColor=true
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
		flyVariables.uiSpeedBoxes[modeKey]=speedBox
		if storeRefs then storeRefs(btn) end
	end
	if mode=="fly" then
		mk("fly",function() return FLYING and "Unfly" or "Fly" end,function() NAmanage.toggleFly() end,function() return flyVariables.flySpeed end,function(v) flyVariables.flySpeed=v end,function(btn) flyVariables.mFlyBruh=btn end)
	elseif mode=="vfly" then
		mk("vfly",function() return FLYING and "UnvFly" or "vFly" end,function() NAmanage.toggleVFly() end,function() return flyVariables.vFlySpeed end,function(v) flyVariables.vFlySpeed=v end,function(btn) flyVariables.vRAHH=btn end)
	elseif mode=="cfly" then
		mk("cfly",function() return FLYING and "UnCfly" or "CFly" end,function() NAmanage.toggleCFly() end,function() return flyVariables.cFlySpeed end,function(v) flyVariables.cFlySpeed=v flyVariables.flySpeed=v end,function(btn) flyVariables.cFlyGUI=btn end)
	elseif mode=="tfly" then
		mk("tfly",function() return FLYING and "UnTFly" or "TFly" end,function() NAmanage.toggleTFly() end,function() return flyVariables.TflySpeed end,function(v) flyVariables.TflySpeed=v end,function(btn) flyVariables.tflyButtonUI=btn flyVariables.TFLYBTN=btn end)
	end
	if flyVariables.uiUpdateConn then pcall(function() flyVariables.uiUpdateConn:Disconnect() end) end
	flyVariables.uiUpdateConn=NAlib.reconnect("fly_mobile_ui_update",Services.RunService.Heartbeat:Connect(function()
		if mode=="fly" and flyVariables.mFlyBruh then
			const b=flyVariables.mFlyBruh
			if b then b.Text=FLYING and "Unfly" or "Fly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		elseif mode=="vfly" and flyVariables.vRAHH then
			const b=flyVariables.vRAHH
			if b then b.Text=FLYING and "UnvFly" or "vFly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		elseif mode=="cfly" and flyVariables.cFlyGUI then
			const b=flyVariables.cFlyGUI
			if b then b.Text=FLYING and "UnCfly" or "CFly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		elseif mode=="tfly" and flyVariables.tflyButtonUI then
			const b=flyVariables.tflyButtonUI
			if b then b.Text=FLYING and "UnTFly" or "TFly" b.BackgroundColor3=FLYING and Color3.fromRGB(0,170,0) or Color3.fromRGB(30,30,30) end
		end
	end))
end

local _modelESPPreviousSkipAutoSuffix = cmds._skipAutoSuffix
cmds._skipAutoSuffix = true

cmd.add({"modelesp","mesp"},{"modelesp {modelName}","Highlights matching models and keeps tracking future matches"},function(...)
	const rawInput = Concat({...}, " ")
	const name = Lower(rawInput)
	if name == "" then
		return
	end
	if NAStuff.modelSearchToken then
		NAmanage.CancelTokenCancel(NAStuff.modelSearchToken)
	end
	const searchToken = NAmanage.NewCancelToken()
	NAStuff.modelSearchToken = searchToken

	SpawnCall(function()
		const exactMatches = {}
		const matches = {}
		NAmanage.ForEachWorkspaceYield(function(obj)
			if searchToken.cancelled then
				return
			end
			if obj and obj:IsA("Model") then
				const lowered = Lower(obj.Name)
				if lowered == name then
					Insert(exactMatches, obj)
				elseif Find(lowered, name, 1, true) then
					Insert(matches, obj)
				end
			end
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = searchToken,
		})

		if searchToken.cancelled then
			return
		end
		if NAStuff.modelSearchToken == searchToken then
			NAStuff.modelSearchToken = nil
		end

		if #exactMatches > 0 then
			NAmanage.ModelESP_AddRule(rawInput, "exact")
			return
		end

		if #matches == 0 then
			DoNotif(Format("No models found containing '%s'.", rawInput), 3)
			return
		end

		originalIO.espSortNameMatches(matches, name)
		const buttons = {}
		if #matches > 1 then
			Insert(buttons, {
				Text = "All Matches",
				Callback = function()
					NAmanage.ModelESP_AddRule(rawInput, "partial")
				end
			})
		end
		for _, model in matches do
			const modelRef = model
			Insert(buttons, {
				Text = originalIO.espDisplayName(modelRef),
				Callback = function()
					if modelRef and modelRef:IsA("Model") then
						NAmanage.ModelESP_AddRule(modelRef.Name, "exact")
					end
				end
			})
		end

		Window({
			Title = "Model ESP",
			Description = "Select model(s) to highlight. Selected names stay tracked for future matching models.",
			Buttons = buttons
		})
	end)
end,true)

cmd.add({"modelespfind","mespfind","mfindesp","modelfindesp"},{"modelespfind {modelName}","Highlights models containing the name and keeps tracking future matches"},function(...)
	const rawInput = Concat({...}, " ")
	if rawInput == "" then return end
	NAmanage.ModelESP_AddRule(rawInput, "partial")
end,true)

cmd.add({"unmodelespfind","unmespfind","unmfindesp","unmodelfindesp"},{"unmodelespfind [modelName|All]","Stops partial-name model ESP tracking rules"},function(...)
	local rawInput = Concat({...}, " ")
	rawInput = (type(rawInput) == "string") and rawInput:gsub("^%s+", ""):gsub("%s+$", "") or ""
	const loweredInput = Lower(rawInput)
	const rules = NAmanage.ModelESP_EnsureRules()
	if loweredInput == "" or loweredInput == "all" or loweredInput == "*" then
		const terms = {}
		for _, rule in rules do
			if type(rule) == "table" and rule.mode == "partial" then
				terms[#terms + 1] = rule.term
			end
		end
		for _, term in terms do NAmanage.ModelESP_RemoveRule(term, "partial") end
		DoNotif(Format("Cleared %d partial model ESP rule%s.", #terms, #terms == 1 and "" or "s"), 2)
		return
	end
	if NAmanage.ModelESP_RemoveRule(loweredInput, "partial") then
		DoNotif(Format("Stopped partial model ESP rule '%s'.", rawInput), 2)
	else
		DoNotif(Format("No partial model ESP rule matching '%s'.", rawInput), 3)
	end
end,true)

cmd.add({"unmodelesp","unmesp"},{"unmodelesp [modelName]","Stops a model ESP tracking rule or all rules"},function(...)
	const rules = NAmanage.ModelESP_EnsureRules()
	if type(rules) ~= "table" or #rules == 0 then
		if type(NAStuff.modelESPModels) == "table" and #NAStuff.modelESPModels > 0 then
			const removed = NAmanage.ModelESP_ClearRules()
			DoNotif(Format("Stopped model ESP for %d legacy tracked model(s).", removed), 2)
		else
			DoNotif("No model ESP rules are active.", 2)
		end
		return
	end

	const function collectTerms()
		const terms = {}
		const seen = {}
		for _, rule in rules do
			if type(rule) == "table" then
				const term = Lower(tostring(rule.term or ""))
				if term ~= "" and not seen[term] then
					seen[term] = true
					terms[#terms + 1] = term
				end
			end
		end
		table.sort(terms)
		return terms
	end

	const function removeAllRules()
		const count = #collectTerms()
		NAmanage.ModelESP_ClearRules()
		DoNotif(Format("Cleared %d model ESP rule%s.", count, count == 1 and "" or "s"), 2)
	end

	local rawInput = Concat({...}, " ")
	rawInput = (type(rawInput) == "string") and rawInput:gsub("^%s+", ""):gsub("%s+$", "") or ""
	const loweredInput = Lower(rawInput)
	if loweredInput ~= "" then
		if loweredInput == "all" or loweredInput == "*" then
			removeAllRules()
			return
		end
		const terms = collectTerms()
		local picked = nil
		for _, term in terms do
			if term == loweredInput then
				picked = term
				break
			end
		end
		if not picked then
			for _, term in terms do
				if Find(term, loweredInput, 1, true) then
					picked = term
					break
				end
			end
		end
		if picked and NAmanage.ModelESP_RemoveRule(picked) then
			DoNotif(Format("Stopped model ESP rule '%s'.", picked), 2)
		else
			DoNotif(Format("No model ESP rule matching '%s'.", rawInput), 3)
		end
		return
	end

	const terms = collectTerms()
	const buttons = {
		{
			Text = "All",
			Callback = removeAllRules
		}
	}
	for _, term in terms do
		const ruleTerm = term
		buttons[#buttons + 1] = {
			Text = ruleTerm,
			Callback = function()
				if NAmanage.ModelESP_RemoveRule(ruleTerm) then
					DoNotif(Format("Stopped model ESP rule '%s'.", ruleTerm), 2)
				else
					DoNotif("Model ESP rule was not active.", 2)
				end
			end
		}
	end

	Window({
		Title = "Model ESP",
		Description = "Select a tracked model-name rule to disable.",
		Buttons = buttons
	})
end,true)

cmds._skipAutoSuffix = _modelESPPreviousSkipAutoSuffix
