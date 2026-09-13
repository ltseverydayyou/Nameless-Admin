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
