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

cmd.add({"modelesp","mesp"},{"modelesp {modelName}","Highlights matching models"},function(...)
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
			for _, model in exactMatches do
				if model and model:IsA("Model") then
					NAmanage.ModelESP_Enable(model)
				end
			end
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
					for _, model in matches do
						if model and model:IsA("Model") then
							NAmanage.ModelESP_Enable(model)
						end
					end
				end
			})
		end
		for _, model in matches do
			const modelRef = model
			Insert(buttons, {
				Text = originalIO.espDisplayName(modelRef),
				Callback = function()
					if modelRef and modelRef:IsA("Model") then
						NAmanage.ModelESP_Enable(modelRef)
					end
				end
			})
		end

		Window({
			Title = "Model ESP",
			Description = "Select model(s) to highlight. Toggle multi-select in the header to pick several.",
			Buttons = buttons
		})
	end)
end,true)

cmd.add({"unmodelesp","unmesp"},{"unmodelesp [modelName]","Disables model ESP for matching model(s) or all"},function(...)
	const models = NAStuff.modelESPModels
	if type(models) ~= "table" or #models == 0 then
		DoNotif("No model ESP entries are active.", 2)
		return
	end

	const function detachModel(model)
		if typeof(model) ~= "Instance" then
			return false
		end
		return NAmanage.ModelESP_Disable(model)
	end

	const function collectTrackedModels()
		const tracked = {}
		for i = #models, 1, -1 do
			const model = models[i]
			if typeof(model) == "Instance" and model:IsA("Model") and model.Parent and model:FindFirstChildWhichIsA("BasePart", true) then
				tracked[#tracked + 1] = model
			else
				NAmanage.ModelESP_Disable(model)
			end
		end
		table.sort(tracked, function(a, b)
			return Lower(a.Name) < Lower(b.Name)
		end)
		return tracked
	end

	const function removeAllModels()
		const tracked = collectTrackedModels()
		local removed = 0
		for _, model in tracked do
			if detachModel(model) then
				removed += 1
			end
		end
		if removed > 0 then
			DoNotif(Format("Stopped model ESP for %d model(s).", removed), 2)
		else
			DoNotif("No model ESP entries were active.", 2)
		end
	end

	const trackedModels = collectTrackedModels()
	local rawInput = Concat({...}, " ")
	rawInput = (type(rawInput) == "string") and rawInput:gsub("^%s+", ""):gsub("%s+$", "") or ""
	const loweredInput = Lower(rawInput)

	if loweredInput ~= "" then
		if loweredInput == "all" or loweredInput == "*" then
			removeAllModels()
			return
		end

		const exactModels = {}
		for _, model in trackedModels do
			if Lower(model.Name) == loweredInput then
				exactModels[#exactModels + 1] = model
			end
		end
		if #exactModels > 0 then
			local removed = 0
			for _, model in exactModels do
				if detachModel(model) then
					removed += 1
				end
			end
			DoNotif(Format("Stopped model ESP for %d model(s) named '%s'.", removed, rawInput), 2)
			return
		end

		local picked = nil
		for _, model in trackedModels do
			if Find(Lower(model.Name), loweredInput, 1, true) then
				picked = model
				break
			end
		end
		if picked and detachModel(picked) then
			DoNotif(Format("Stopped model ESP for '%s'.", picked.Name), 2)
		else
			DoNotif(Format("No model ESP entry matching '%s'.", rawInput ~= "" and rawInput or loweredInput), 3)
		end
		return
	end

	if #trackedModels == 0 then
		DoNotif("No model ESP entries are active.", 2)
		return
	end

	const buttons = {
		{
			Text = "All",
			Callback = removeAllModels
		}
	}
	for _, model in trackedModels do
		const modelRef = model
		buttons[#buttons + 1] = {
			Text = originalIO.espDisplayName(modelRef),
			Callback = function()
				if detachModel(modelRef) then
					DoNotif(Format("Stopped model ESP for '%s'.", modelRef.Name), 2)
				else
					DoNotif("Model ESP entry was not active.", 2)
				end
			end
		}
	end

	Window({
		Title = "Model ESP",
		Description = "Select a model ESP entry to disable.",
		Buttons = buttons
	})
end,true)

cmds._skipAutoSuffix = _modelESPPreviousSkipAutoSuffix
