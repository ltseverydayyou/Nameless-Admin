NAmanage.FastProximityPromptsUntrack = function(pp, restore)
	const state = NAStuff.fastProximityPrompts
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

NAmanage.FastProximityPromptsDisable = function()
	const state = NAStuff.fastProximityPrompts
	state.active = false
	NAlib.disconnect("fastpp")
	NAmanage.clrWsH("fastpp_duration")
	const prompts = {}
	for pp in state.prompts do
		prompts[#prompts + 1] = pp
	end
	for i = 1, #prompts do
		NAmanage.FastProximityPromptsUntrack(prompts[i], true)
	end
end

cmd.add({"instantproximityprompts","instantpp","ipp"},{"instantproximityprompts (instantpp,ipp)","Sets proximity prompt HoldDuration values to 0"},function()
	NAmanage.FastProximityPromptsDisable()
	const state = NAStuff.instantProximityPrompts
	state.active = true
	NAmanage.setWsH("instantpp_duration", {
		added = function(inst)
			NAmanage.InstantProximityPromptsTrack(inst)
		end;
		removing = function(inst)
			NAmanage.InstantProximityPromptsUntrack(inst, true)
		end;
		classNames = { "ProximityPrompt" };
		enabled = function()
			return state.active == true
		end;
	})
	NAindex.init()
	for _, pp in InstancesTbl.proxy do
		NAmanage.InstantProximityPromptsTrack(pp)
	end
end)

cmd.add({"uninstantproximityprompts","uninstantpp","unipp"},{"uninstantproximityprompts (uninstantpp,unipp)","Restores tracked proximity prompt HoldDuration values"},function()
	NAmanage.InstantProximityPromptsDisable()
end)

cmd.add({"fastprompts","fastproximityprompts","fastpp"},{"fastprompts [speed] (fastproximityprompts,fastpp)","Makes proximity prompts use the specified speed multiplier, defaulting to 2x"},function(...)
	const multiplier = tonumber((...)) or 2
	if multiplier <= 0 then
		return DoNotif("Prompt speed multiplier must be greater than 0",3)
	end
	NAmanage.InstantProximityPromptsDisable()
	NAmanage.FastProximityPromptsDisable()
	const state = NAStuff.fastProximityPrompts
	state.multiplier = multiplier
	state.active = true
	NAmanage.setWsH("fastpp_duration", {
		added = function(inst)
			NAmanage.FastProximityPromptsTrack(inst)
		end;
		removing = function(inst)
			NAmanage.FastProximityPromptsUntrack(inst, true)
		end;
		classNames = { "ProximityPrompt" };
		enabled = function()
			return state.active == true
		end;
	})
	NAindex.init()
	for _, pp in InstancesTbl.proxy do
		NAmanage.FastProximityPromptsTrack(pp)
	end
end)

cmd.add({"unfastprompts","unfastproximityprompts","unfastpp"},{"unfastprompts (unfastproximityprompts,unfastpp)","Restores tracked proximity prompt HoldDuration values"},function()
	NAmanage.FastProximityPromptsDisable()
end)

cmd.add({"enableproximitypromptservice","enablepps","epps","ppson","ppon"},{"enableproximitypromptservice (enablepps,epps,ppson,ppon)","enable proximity prompt buttons"},function()
	SafeGetService("ProximityPromptService",false).Enabled = true
end,true)

cmd.add({"disableproximitypromptservice","disablepps","dpps","ppsoff","ppoff"},{"disableproximitypromptservice (disablepps,dpps,ppsoff,ppoff)","disable proximity prompt buttons"},function()
	SafeGetService("ProximityPromptService",false).Enabled = false
end,true)

cmd.add({"enableproximityprompts","enableprox","enprox","enprx","enpp"},{"enableproximityprompts [name]","Enable ProximityPrompts (all or matching)"},function(...)
	const term = Lower(Concat({...}," "))
	NAindex.init()
	for _,obj in InstancesTbl.proxy do
		if obj and obj.Parent then
			if term=="" or Find(Lower(obj.Name), term) then
				obj.Enabled = true
			end
		end
	end
end,true)

cmd.add({"disableproximityprompts","disableprox","disprox","dprx","dpp"},{"disableproximityprompts [name]","Disable ProximityPrompts (all or matching)"},function(...)
	const term = Lower(Concat({...}," "))
	NAindex.init()
	for _,obj in InstancesTbl.proxy do
		if obj and obj.Parent then
			if term=="" or Find(Lower(obj.Name), term) then
				obj.Enabled = false
			end
		end
	end
end,true)

proxyEnableLoopState = {active=false;}

NAmanage.StopProximityPromptEnableWatcher = function()
	const state = proxyEnableLoopState
	if state then
		state.active = false
		if type(state.records) == "table" then
			for _, record in state.records do
				for _, conn in record do
					pcall(function()
						if conn and type(conn.Disconnect) == "function" then
							conn:Disconnect()
						end
					end)
				end
			end
		end
	end
	NAlib.disconnect("loopenableproximityprompts_add")
	proxyEnableLoopState = nil
end

NAmanage.StartProximityPromptEnableWatcher = function(term)
	term = Lower(tostring(term or ""))
	NAmanage.StopProximityPromptEnableWatcher()
	const state = {
		active = true,
		term = term,
		records = {},
	}
	proxyEnableLoopState = state

	const function matches(prompt)
		return prompt and prompt:IsA("ProximityPrompt") and (term == "" or Find(Lower(prompt.Name), term))
	end

	const function disconnectRecord(prompt)
		const record = state.records[prompt]
		if record then
			for _, conn in record do
				pcall(function()
					if conn and type(conn.Disconnect) == "function" then
						conn:Disconnect()
					end
				end)
			end
			state.records[prompt] = nil
		end
	end

	const function watchPrompt(prompt)
		if not (state.active and prompt and prompt.Parent and prompt:IsA("ProximityPrompt")) then
			return
		end
		if state.records[prompt] then
			return
		end
		const record = {}
		state.records[prompt] = record

		const function enforce()
			if not (state.active and prompt and prompt.Parent and prompt:IsA("ProximityPrompt")) then
				disconnectRecord(prompt)
				return
			end
			if matches(prompt) and prompt.Enabled ~= true then
				prompt.Enabled = true
			end
		end

		record.lastEnabled = prompt.Enabled
		record.enabled = prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
			const enabledNow = prompt.Enabled
			if enabledNow == record.lastEnabled then
				return
			end
			record.lastEnabled = enabledNow
			enforce()
		end)
		record.ancestry = prompt.AncestryChanged:Connect(function(_, parent)
			if not parent then
				disconnectRecord(prompt)
			end
		end)
		if term ~= "" then
			record.lastName = prompt.Name
			record.name = prompt:GetPropertyChangedSignal("Name"):Connect(function()
				const nameNow = prompt.Name
				if nameNow == record.lastName then
					return
				end
				record.lastName = nameNow
				enforce()
			end)
		end
		enforce()
	end

	NAindex.init()
	for _, obj in InstancesTbl.proxy do
		watchPrompt(obj)
	end
	NAlib.connect("loopenableproximityprompts_add", NAmanage.descAdd(Services.Workspace, function(obj)
		watchPrompt(obj)
	end, function(obj)
		return obj and obj:IsA("ProximityPrompt")
	end))
end

cmd.add({"loopenableproximityprompts","loopenableprox","lenprox","lenpp"},{"loopenableproximityprompts [name]","Continuously enable ProximityPrompts (all or matching)"},function(...)
	NAmanage.StartProximityPromptEnableWatcher(Concat({...}," "))
end,true)

cmd.add({"unloopenableproximityprompts","unloopenableprox","unlenprox","unlenpp"},{"unloopenableproximityprompts","Stop enabling loop"},function()
	NAmanage.StopProximityPromptEnableWatcher()
end)

NAmanage.rigPromptErr = function(n, er)
	er=tostring(er or "unknown error"):gsub("[\r\n]", " ")
	if #er > 240 then
		er=er:sub(1, 240).."..."
	end
	DoNotif(n.." failed: "..er, 8, "Rig Type")
end

NAmanage.runRigPrompt = function(n, rig)
	Spawn(function()
		local con
		local done=false
		local ok, er=xpcall(function()
			const aes=SafeGetService("AvatarEditorService")
			if not aes then
				error("AvatarEditorService unavailable", 0)
			end

			const hum=getPlrHum(LocalPlayer) or getHum()
			if not hum then
				error("Humanoid unavailable", 0)
			end

			local desc
			local okDesc, res=pcall(function()
				return hum:GetAppliedDescription()
			end)
			if okDesc and res then
				desc=res
			else
				desc=hum.HumanoidDescription
			end
			if not desc then
				error("HumanoidDescription unavailable"..(okDesc and "" or ": "..tostring(res)), 0)
			end

			con=aes.PromptSaveAvatarCompleted:Connect(function(res)
				if done then return end
				done=true
				if con then
					con:Disconnect()
					con=nil
				end
				if res == Enum.AvatarPromptResult.Success then
					const h=getHum()
					if h then
						pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
						pcall(function() h.Health=0 end)
					end
				else
					NAmanage.rigPromptErr(n, res and res.Name or tostring(res or "Unknown"))
				end
			end)

			local okRun, runEr=pcall(function()
				return __lt.cm("AvatarEditorService", "PromptSaveAvatar", desc, rig)
			end)
			if not okRun then
				okRun, runEr=pcall(function()
					return aes:PromptSaveAvatar(desc, rig)
				end)
			end
			if not okRun then
				error(runEr, 0)
			end

			Delay(120, function()
				if done then return end
				done=true
				if con then
					con:Disconnect()
					con=nil
				end
				NAmanage.rigPromptErr(n, "PromptSaveAvatarCompleted timed out")
			end)
		end, function(e)
			return e
		end)

		if not ok then
			if con then
				pcall(function() con:Disconnect() end)
			end
			NAmanage.rigPromptErr(n, er)
		end
	end)
end

cmd.add({"r6"},{"r6","Shows a prompt that will switch your character rig type into R6"},function()
	NAmanage.runRigPrompt("R6", Enum.HumanoidRigType.R6)
end)

cmd.add({"r15"},{"r15","Shows a prompt that will switch your character rig type into R15"},function()
	NAmanage.runRigPrompt("R15", Enum.HumanoidRigType.R15)
end)

cmd.add({"breakvelocity","breakv","bvel","zvel","zerovel","stopvel","brkvel"},{"breakvelocity (breakv,bvel,zvel,zerovel,stopvel,brkvel)","Sets your character's velocity to zero momentarily"},function()
	const char=getChar()
	if not char then
		DoNotif("Character unavailable",2)
		return
	end
	const zero=Vector3.zero
	const stopAt=time()+1
	repeat
		for _,part in char:QueryDescendants("BasePart") do
			NAlib.setProperty(part,"AssemblyLinearVelocity",zero)
			NAlib.setProperty(part,"AssemblyAngularVelocity",zero)
			NAlib.setProperty(part,"Velocity",zero)
			NAlib.setProperty(part,"RotVelocity",zero)
		end
		Wait()
	until time()>=stopAt or not char.Parent
end)

_na_env.NamelessMaxSlopeAngle = nil
NAStuff.loopmsa = false

function applyMaxSlopeAngle(amount, notify)
	const humanoid = getHum()
	if humanoid then
		humanoid.MaxSlopeAngle = amount
		if notify then
			DebugNotif(Format("Set MaxSlopeAngle to %s", tostring(amount)), 2)
		end
		return humanoid
	end
	if notify then
		DebugNotif("Humanoid not found or invalid.", 2)
	end
	return nil
end

cmd.add({"maxslopeangle", "msa"}, {"maxslopeangle <number> (msa)", "Changes your character's MaxSlopeAngle"}, function(...)
	const args = {...}
	const amount = tonumber(args[1]) or 89
	applyMaxSlopeAngle(amount, true)
end,true)

cmd.add({"loopmaxslopeangle", "loopmsa", "lmsa"}, {"loopmaxslopeangle <number> (loopmsa,lmsa)", "Loop MaxSlopeAngle"}, function(...)
	const args = {...}
	const amount = tonumber(args[1]) or 89
	_na_env.NamelessMaxSlopeAngle = amount
	NAStuff.loopmsa = true

	NAlib.disconnect("loopmsa_apply")
	NAlib.disconnect("loopmsa_char")

	const function applyMSA()
		const humanoid = applyMaxSlopeAngle(amount)
		if not humanoid then return end

		NAlib.disconnect("loopmsa_apply")
		NAlib.connect("loopmsa_apply", humanoid:GetPropertyChangedSignal("MaxSlopeAngle"):Connect(function()
			if NAStuff.loopmsa and humanoid.Parent and humanoid.MaxSlopeAngle ~= amount then
				humanoid.MaxSlopeAngle = amount
			end
		end))
	end

	applyMSA()

	NAlib.connect("loopmsa_char", LocalPlayer.CharacterAdded:Connect(function()
		while not getHum() do Wait(.1) end
		if NAStuff.loopmsa then applyMSA() end
	end))
end,true)

cmd.add({"unloopmaxslopeangle", "unloopmsa", "unlmsa"}, {"unloopmaxslopeangle (unloopmsa,unlmsa)", "Disable loop MaxSlopeAngle"}, function()
	NAStuff.loopmsa = false
	_na_env.NamelessMaxSlopeAngle = nil
	NAlib.disconnect("loopmsa_apply")
	NAlib.disconnect("loopmsa_char")
end)

-- garbage that needs to be changed to something else

NAStuff._godEnabled = NAStuff._godEnabled or false
NAStuff._godMethod  = NAStuff._godMethod  or "nohooks_strong"
NAStuff._godTarget  = NAStuff._godTarget  or 1e9
NAStuff._godOrig    = NAStuff._godOrig    or {}
NAStuff._godSignals = NAStuff._godSignals or {}
NAStuff._godHumRef  = NAStuff._godHumRef  or nil
NAStuff._godHooked  = NAStuff._godHooked  or false
NAStuff._godOldNC   = NAStuff._godOldNC   or nil
NAStuff._godOldNI   = NAStuff._godOldNI   or nil
NAStuff._godStrong  = NAStuff._godStrong  or true

NAmanage.God_ClearSignals = function()
	NAlib.disconnect("godmode")
	NAlib.disconnect("god_char")
	NAlib.disconnect("god_loops")
	for _,arr in NAStuff._godSignals do
		for _,c in arr do if c then c:Disconnect() end end
	end
	for k in NAStuff._godSignals do NAStuff._godSignals[k] = nil end
end

NAmanage.God_UnhookMeta = function()
	if NAStuff._godHooked and NAStuff._godOldNC and NAStuff._godOldNI and typeof(getrawmetatable)=="function" and typeof(setreadonly)=="function" then
		const mt = getrawmetatable(game)
		const ro = isreadonly and isreadonly(mt)
		if ro then setreadonly(mt,false) end
		mt.__namecall = NAStuff._godOldNC
		mt.__newindex = NAStuff._godOldNI
		if ro then setreadonly(mt,true) end
	end
	NAStuff._godHooked, NAStuff._godOldNC, NAStuff._godOldNI = false, nil, nil
end

NAmanage.God_CommonApply = function(h)
	if not h then return end
	NAStuff._godHumRef = h
	if NAStuff._godOrig[h] == nil then
		NAStuff._godOrig[h] = { max = h.MaxHealth, bjd = NAlib.isProperty(h,"BreakJointsOnDeath") }
	end
	if h.MaxHealth < NAStuff._godTarget then NAlib.setProperty(h,"MaxHealth", NAStuff._godTarget) end
	if h.Health < h.MaxHealth then NAlib.setProperty(h,"Health", h.MaxHealth) end
	if NAlib.isProperty(h,"BreakJointsOnDeath") ~= false then NAlib.setProperty(h,"BreakJointsOnDeath", false) end
end

NAmanage.God_WireNoHooks = function(h, strong)
	if not h then return end
	if NAStuff._godSignals[h] then
		for _,c in NAStuff._godSignals[h] do
			if c then
				c:Disconnect()
			end
		end
	end
	NAStuff._godSignals[h] = {}
	Insert(NAStuff._godSignals[h], NAlib.connect("godmode", h.HealthChanged:Connect(function()
		if h.Health < h.MaxHealth then NAlib.setProperty(h,"Health", h.MaxHealth) end
	end)))
	Insert(NAStuff._godSignals[h], NAlib.connect("godmode", h:GetPropertyChangedSignal("Health"):Connect(function()
		if h.Health < h.MaxHealth then NAlib.setProperty(h,"Health", h.MaxHealth) end
	end)))
	Insert(NAStuff._godSignals[h], NAlib.connect("godmode", h:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		if h.MaxHealth < NAStuff._godTarget then NAlib.setProperty(h,"MaxHealth", NAStuff._godTarget) end
		if h.Health < h.MaxHealth then NAlib.setProperty(h,"Health", h.MaxHealth) end
	end)))
	if strong then
		Insert(NAStuff._godSignals[h], NAlib.connect("godmode", h:GetPropertyChangedSignal("BreakJointsOnDeath"):Connect(function()
			if NAlib.isProperty(h,"BreakJointsOnDeath") ~= false then NAlib.setProperty(h,"BreakJointsOnDeath", false) end
		end)))
		Insert(NAStuff._godSignals[h], NAlib.connect("godmode", h.StateChanged:Connect(function(_, s)
			if s == Enum.HumanoidStateType.Dead then
				if h.Health < h.MaxHealth then NAlib.setProperty(h,"Health", h.MaxHealth) end
				pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
				pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
			end
		end)))
		pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
		if h:GetState() == Enum.HumanoidStateType.Dead then pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end) end
	end
	NAStuff._godStrong = strong ~= false
	if not NAlib.isConnected("god_loops") then
		NAlib.connect("god_loops", Services.RunService.RenderStepped:Connect(function()
			if not NAStuff._godEnabled then return end
			const hh = getHum()
			if not hh then return end
			NAStuff._godHumRef = hh
			if hh.MaxHealth < NAStuff._godTarget then NAlib.setProperty(hh,"MaxHealth", NAStuff._godTarget) end
			if hh.Health < hh.MaxHealth then NAlib.setProperty(hh,"Health", hh.MaxHealth) end
			if NAStuff._godStrong then
				if NAlib.isProperty(hh,"BreakJointsOnDeath") ~= false then NAlib.setProperty(hh,"BreakJointsOnDeath", false) end
				pcall(function() hh:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
				if hh:GetState() == Enum.HumanoidStateType.Dead then
					pcall(function() hh:ChangeState(Enum.HumanoidStateType.Running) end)
				end
			end
		end))
		NAlib.connect("god_loops", Services.RunService.PreSimulation:Connect(function()
			if not NAStuff._godEnabled then return end
			const hh = getHum()
			if hh and hh.Health < hh.MaxHealth then NAlib.setProperty(hh,"Health", hh.MaxHealth) end
		end))
		NAlib.connect("god_loops", Services.RunService.Heartbeat:Connect(function()
			if not NAStuff._godEnabled then return end
			const hh = getHum()
			if hh and hh.Health < hh.MaxHealth then NAlib.setProperty(hh,"Health", hh.MaxHealth) end
		end))
	end
end

NAmanage.God_HookMeta = function()
	if NAStuff._godHooked or not (typeof(hookmetamethod)=="function" and typeof(getnamecallmethod)=="function" and typeof(newcclosure)=="function" and typeof(checkcaller)=="function") then
		return false
	end
	NAStuff._godHooked = true
	NAStuff._godOldNC = NAStuff._godOldNC or hookmetamethod(game,"__namecall",newcclosure(function(self,...)
		if not checkcaller() then
			local m = getnamecallmethod()
			if type(m) == "string" then
				m = Lower(m)
			end
			const hum = NAStuff._godHumRef
			if hum and typeof(self)=="Instance" then
				if self==hum and m=="changestate" then
					const st = ...
					if st == Enum.HumanoidStateType.Dead then
						return
					end
				end
				if self==hum and m=="setstateenabled" then
					local st,en = ...
					if st == Enum.HumanoidStateType.Dead and en == true then
						return
					end
				end
				if self==hum and m=="destroy" then
					return
				end
				const char = Services.Players.LocalPlayer.Character
				if char and self==char and m=="breakjoints" then
					return
				end
			end
		end
		return NAStuff._godOldNC(self,...)
	end))
	NAStuff._godOldNI = NAStuff._godOldNI or hookmetamethod(game,"__newindex",newcclosure(function(self,k,v)
		if not checkcaller() then
			const hum = NAStuff._godHumRef
			if hum and self==hum then
				if k=="Health" and type(v)=="number" and v<=0 then return end
				if k=="MaxHealth" and type(v)=="number" and v<NAStuff._godTarget then return end
				if k=="BreakJointsOnDeath" and v==true then return end
				if k=="Parent" and v==nil then return end
			end
		end
		return NAStuff._godOldNI(self,k,v)
	end))
	return true
end

NAmanage.God_GetAltSignal = function(lp)
	local sig
	const ok = pcall(function()
		sig = lp and lp.Kill
	end)
	if ok and sig then
		return sig
	end
	return nil
end

NAmanage.God_CanAltRepSignal = function()
	return typeof(replicatesignal)=="function" and NAmanage.God_GetAltSignal(Services.Players.LocalPlayer) ~= nil
end

NAmanage.God_SetAltStates = function(h, enabled)
	if not h then return end
	pcall(function() h:SetStateEnabled(15, enabled) end)
	pcall(function() h:SetStateEnabled(1, enabled) end)
	pcall(function() h:SetStateEnabled(0, enabled) end)
	pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Dead, enabled) end)
	pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, enabled) end)
	pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, enabled) end)
end

NAmanage.God_SetAltHealth = function(h)
	if not h then return false end
	const nan = 0/0
	local ok = false
	const hp = sethiddenproperty or set_hidden_property or set_hidden_prop
	const ss = setscriptable
	const props = {"maxHealth","MaxHealth","Health_XML","Health"}
	if typeof(hp)=="function" then
		for _,p in props do
			const s = pcall(function() hp(h,p,nan) end)
			if s then ok = true end
		end
	elseif typeof(ss)=="function" then
		for _,p in props do
			pcall(function() ss(h,p,true) end)
		end
		for _,p in props do
			const s = pcall(function() h[p] = nan end)
			if s then ok = true end
		end
		Wait()
		for _,p in props do
			pcall(function() ss(h,p,false) end)
		end
	else
		const s1 = pcall(function() h.MaxHealth = nan end)
		const s2 = pcall(function() h.Health = nan end)
		ok = s1 or s2
	end
	return ok
end

NAmanage.God_AltRepSignal = function(h)
	if not h or typeof(replicatesignal)~="function" then
		return false
	end
	const sig = NAmanage.God_GetAltSignal(Services.Players.LocalPlayer)
	if not sig then
		return false
	end
	NAmanage.God_SetAltStates(h, false)
	const rsOk = pcall(function() replicatesignal(sig) end)
	if not rsOk then
		return false
	end
	return NAmanage.God_SetAltHealth(h)
end

NAmanage.God_Enable = function(method)
	NAmanage.God_ClearSignals()
	NAmanage.God_UnhookMeta()
	NAStuff._godMethod = method or NAStuff._godMethod
	const lp = Services.Players.LocalPlayer
	const h = getHum()
	if not h then
		NAlib.connect("god_char", lp.CharacterAdded:Connect(function(char)
			local c
			c = NAmanage.descAdd(char, function(inst)
				if inst:IsA("Humanoid") then
					c:Disconnect()
					NAmanage.God_Enable(NAStuff._godMethod)
				end
			end, function(inst)
				return inst and inst:IsA("Humanoid")
			end)
		end))
		return
	end
	NAStuff._godEnabled = true
	NAmanage.God_CommonApply(h)
	if NAStuff._godMethod == "alt_replicatesignal" then
		if not NAmanage.God_AltRepSignal(h) then
			return false
		end
	elseif NAStuff._godMethod == "hook_meta" then
		NAmanage.God_WireNoHooks(h, true)
		NAmanage.God_HookMeta()
	else
		NAmanage.God_WireNoHooks(h, true)
	end
	NAlib.connect("god_char", lp.CharacterAdded:Connect(function(char)
		Wait()
		const nh = getHum()
		if nh then
			NAmanage.God_CommonApply(nh)
			if NAStuff._godMethod=="alt_replicatesignal" then
				if not NAmanage.God_AltRepSignal(nh) then
					NAStuff._godMethod = "nohooks_strong"
					NAmanage.God_WireNoHooks(nh, true)
				end
			elseif NAStuff._godMethod=="hook_meta" then
				NAmanage.God_WireNoHooks(nh, true)
				NAmanage.God_HookMeta()
			else
				NAmanage.God_WireNoHooks(nh, true)
			end
		end
	end))
	return true
end

NAmanage.God_Disable = function()
	NAStuff._godEnabled = false
	NAmanage.God_ClearSignals()
	NAmanage.God_UnhookMeta()
	const h = getHum()
	const o = h and NAStuff._godOrig[h]
	if h and o then
		NAlib.setProperty(h,"MaxHealth", o.max or 100)
		NAlib.setProperty(h,"Health", o.max or 100)
		if o.bjd ~= nil then NAlib.setProperty(h,"BreakJointsOnDeath", o.bjd) end
		NAmanage.God_SetAltStates(h, true)
	end
	for k in NAStuff._godOrig do NAStuff._godOrig[k] = nil end
	NAStuff._godHumRef = nil
end

cmd.add({"godmode","god"},{"godmode (god)","Pick and enable an invincibility method"},function(...)
	const args = {...}
	const choice = args[1] and Lower(args[1]) or nil
	const useHooking = (typeof(hookmetamethod)=="function" and typeof(getnamecallmethod)=="function" and typeof(newcclosure)=="function" and typeof(checkcaller)=="function")
	const useAlt = NAmanage and NAmanage.God_CanAltRepSignal and NAmanage.God_CanAltRepSignal()

	const function enableStrong()
		NAStuff._godMethod = "strong"
		if NAmanage and NAmanage.God_Enable then
			NAmanage.God_Enable("nohooks_strong")
		end
		DebugNotif("Godmode ON (strong)",2)
	end

	const function enableHooking()
		NAStuff._godMethod = "hooking"
		if not useHooking then
			DebugNotif("Hooking unavailable; falling back to strong",2)
			return enableStrong()
		end
		if NAmanage and NAmanage.God_Enable then
			NAmanage.God_Enable("hook_meta")
		end
		DebugNotif("Godmode ON (hooking)",2)
	end

	const function enableAlt()
		NAStuff._godMethod = "alt_replicatesignal"
		if not (NAmanage and NAmanage.God_Enable and NAmanage.God_CanAltRepSignal and NAmanage.God_CanAltRepSignal()) then
			DebugNotif("alt unavailable; falling back to strong",2)
			return enableStrong()
		end
		const ok = NAmanage.God_Enable("alt_replicatesignal")
		if not ok then
			DebugNotif("alt unavailable; falling back to strong",2)
			return enableStrong()
		end
		DebugNotif("Godmode ON (alt replicatesignal)",2)
	end

	const function disableGod()
		if NAmanage and NAmanage.God_Disable then
			NAmanage.God_Disable()
			DebugNotif("Godmode OFF",2)
		else
			NAlib.disconnect("godmode")
			DebugNotif("Godmode OFF",2)
		end
	end

	if choice == "strong" or choice == "normal" or choice == "nohook" or choice == "nohooks" then return enableStrong() end
	if choice == "hook" or choice == "hooking" then return enableHooking() end
	if choice == "alt" or choice == "replicatesignal" or choice == "replicatesignal" or choice == "repsignal" or choice == "rs" then return enableAlt() end
	if choice == "off" or choice == "disable" then return disableGod() end
	if not useHooking and not useAlt then
		return enableStrong()
	end

	const buttons = {}
	Insert(buttons, { Text = "Enable: Strong (no hooks)",   Callback = enableStrong })
	if useAlt then
		Insert(buttons, { Text = "alt (replicatesignal)", Callback = enableAlt })
	end
	if useHooking then
		Insert(buttons, { Text = "Enable: Hooking (metamethod)", Callback = enableHooking })
	end
	if NAStuff._godEnabled then
		Insert(buttons, { Text = "Disable Godmode", Callback = disableGod })
	end

	Window({
		Title = "Godmode Methods",
		Buttons = buttons
	})
end)

cmd.add({"ungodmode","ungod"},{"ungodmode (ungod)","Disable invincibility"},function()
	NAmanage.God_Disable()
end)

cmd.add({"controllock","ctrllock"},{"controllock (ctrllock)","Set Shiftlock keys to Control for this session"},function()
	if not IsOnPC then DebugNotif("PC-only feature") return end
	NAmanage.ControlLock_Apply("LeftControl,RightControl")
end)

cmd.add({"uncontrollock","unctrllock"},{"uncontrollock (unctrllock)","Restore Shiftlock keys to default (Shift)"},function()
	if not IsOnPC then DebugNotif("PC-only feature") return end
	NAmanage.ControlLock_Apply("LeftShift,RightShift")
end)

cmd.add({"resetlock"}, {"resetlock", "Resets your Shiftlock keybinds to default (LeftShift)"}, function()
	const player = LocalPlayer
	const mouseLockController = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("CameraModule"):WaitForChild("MouseLockController")
	const boundKeys = mouseLockController:WaitForChild("BoundKeys")

	boundKeys.Value = "LeftShift,RightShift"

	DebugNotif("Reset your Shiftlock keybinds to Shift")
end)

--[[
cmd.add({"autoreport"}, {"autoreport", "Automatically reports players to get them banned"}, function()
	ReportKeywords = {
		kid = "Bullying",
		youtube = "Offsite Links",
		date = "Dating",
		hack = "Cheating/Exploiting",
		idiot = "Bullying",
		fat = "Bullying",
		exploit = "Cheating/Exploiting",
		cheat = "Cheating/Exploiting",
		noob = "Bullying",
		clown = "Bullying",
	}

	function CheckIfReportable(message)
		message = message:lower()
		for keyword, reason in ReportKeywords do
			if message:find(keyword) then
				return keyword, reason
			end
		end
		return nil, nil
	end

	function MonitorPlayerChat(player)
		if player == LocalPlayer then return end

		player.Chatted:Connect(function(message)
			keyword, reason = CheckIfReportable(message)
			if keyword and reason then
				DebugNotif(Format("Reported %s", nameChecker(player)).." | "..Format("Reason - %s", reason))

				if reportplayer then
					reportplayer(player, reason, Format("Saying %s", keyword))
				else
					__lt.cm("Players", "ReportAbuse", player, reason, Format("Saying %s", keyword))
				end
			end
		end)
	end

	for _, player in __lt.cm("Players", "GetPlayers") do
		MonitorPlayerChat(player)
	end

	Players.PlayerAdded:Connect(function(player)
		MonitorPlayerChat(player)
	end)
end)

]]
cmd.add({"flashlight","fl"},{"flashlight (fl)","Gives you a flashlight tool"},function()
	const key = "na_flashlight_tool"
	NAlib.disconnect(key)
	NAlib.disconnect(key.."_render")

	const old = NAStuff.FlashlightTool
	if typeof(old) == "Instance" then
		pcall(function() old:Destroy() end)
	end
	NAStuff.FlashlightTool = nil

	const bp = getBp()
	if not bp then
		DoNotif("Backpack not available.", 3)
		return
	end

	const tool = InstanceNew("Tool", bp)
	tool.Name = "Flashlight"
	tool.TextureId = "rbxassetid://115955232"
	tool.GripPos = Vector3.new(0.1, -0.4, 0)
	tool.RequiresHandle = true
	tool.CanBeDropped = true
	pcall(function() tool:SetAttribute("NAFlashlight", true) end)

	const handle = InstanceNew("Part", tool)
	handle.Name = "Handle"
	handle.BrickColor = BrickColor.new("Bright yellow")
	handle.Color = Color3.fromRGB(245, 205, 48)
	handle.Locked = true
	handle.Size = Vector3.new(0.5, 0.5, 2)
	handle.CanCollide = true
	pcall(function() handle.Massless = true end)

	const lp = InstanceNew("Part", tool)
	lp.Name = "LightPart"
	lp.BrickColor = BrickColor.new("Mid gray")
	lp.Color = Color3.fromRGB(205, 205, 205)
	lp.Transparency = 1
	lp.CanCollide = false
	lp.Locked = true
	lp.Size = Vector3.new(0.2, 0.2, 0.2)
	pcall(function() lp.Massless = true end)
	pcall(function() lp.CanTouch = false end)
	pcall(function() lp.CanQuery = false end)

	const motor = InstanceNew("Motor", tool)
	motor.Name = "Motor"
	motor.Part0 = handle
	motor.Part1 = lp

	const snd = InstanceNew("Sound", handle)
	snd.Name = "Sound"
	snd.SoundId = "rbxassetid://115959318"
	snd.Volume = 1

	const mesh = InstanceNew("SpecialMesh", handle)
	mesh.Name = "Mesh"
	mesh.MeshId = "rbxassetid://115955313"
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.Scale = Vector3.new(0.7, 0.7, 0.7)
	mesh.TextureId = "rbxassetid://115955343"

	const l1 = InstanceNew("SpotLight", lp)
	l1.Name = "SpotLight"
	l1.Angle = 70
	l1.Brightness = 1
	l1.Color = Color3.fromRGB(244, 255, 233)
	l1.Enabled = false
	l1.Face = Enum.NormalId.Front
	l1.Range = 32

	const l2 = InstanceNew("SpotLight", lp)
	l2.Name = "SpotLight2"
	l2.Angle = 70
	l2.Brightness = 0.75
	l2.Color = Color3.fromRGB(244, 255, 233)
	l2.Enabled = false
	l2.Face = Enum.NormalId.Front
	l2.Range = 60

	const onTex = "rbxassetid://115984370"
	const offTex = "rbxassetid://115955343"
	local equipped = false
	local mouse = nil
	local last = 0

	const function toggle(state)
		l1.Enabled = state
		l2.Enabled = state
		mesh.TextureId = state and onTex or offTex
		pcall(function() snd:Play() end)
	end

	const function point()
		if not equipped or not tool.Parent or not l1.Enabled or not mouse then return end
		if not handle.Parent or not motor.Parent then return end
		const char = tool.Parent
		const head = char and char:FindFirstChild("Head",true)
		const hit = mouse.Hit
		if not head or typeof(hit) ~= "CFrame" then return end
		const vec = hit.Position - head.Position
		if vec.Magnitude <= 0 then return end
		const pos = (handle.CFrame * CFrame.new(0, 0, -1)).Position
		const cf = CFrame.new(pos, pos + vec)
		motor.C0 = handle.CFrame:ToObjectSpace(cf)
	end

	NAlib.connect(key, tool.Activated:Connect(function()
		const now = os.clock()
		if now - last < 0.35 then return end
		last = now
		toggle(not l1.Enabled)
	end))

	NAlib.connect(key, tool.Equipped:Connect(function(m)
		equipped = true
		mouse = m
		motor.Parent = tool
		NAlib.disconnect(key.."_render")
		NAlib.connect(key.."_render", Services.RunService.RenderStepped:Connect(point))
	end))

	NAlib.connect(key, tool.Unequipped:Connect(function()
		equipped = false
		mouse = nil
		motor.Parent = tool
		NAlib.disconnect(key.."_render")
	end))

	NAlib.connect(key, tool.Destroying:Connect(function()
		if NAStuff.FlashlightTool == tool then
			NAStuff.FlashlightTool = nil
		end
		NAlib.disconnect(key.."_render")
		NAlib.disconnect(key)
	end))

	NAStuff.FlashlightTool = tool
	DebugNotif("Flashlight added", 2)
end)

cmd.add({"light"},{"light <range> <brightness> <hexColor>","Gives your player dynamic light"},function(rangeStr,brightnessStr,colorHex)
	const range     = tonumber(rangeStr)   or settingsLight.range
	const brightness= tonumber(brightnessStr)or settingsLight.brightness
	local color     = settingsLight.color
	if colorHex and #colorHex>0 then
		local hex = colorHex:match("^#?(%x+)")
		if hex and (#hex==6 or #hex==3) then
			if #hex==3 then hex = hex:gsub(".", function(c) return c..c end) end
			const r = tonumber(hex:sub(1,2),16)/255
			const g = tonumber(hex:sub(3,4),16)/255
			const b = tonumber(hex:sub(5,6),16)/255
			color = Color3.new(r,g,b)
		end
	end

	const root = getRoot(Player.Character)
	if not root then return end

	local light = settingsLight.LIGHTER
	if not light or not light.Parent then
		light = InstanceNew("PointLight")
		settingsLight.LIGHTER = light
	end

	light.Parent     = root
	light.Range      = range
	light.Brightness = brightness
	light.Color      = color
end, true)

cmd.add({"unlight","nolight"},{"unlight (nolight)","Removes dynamic light from your player"},function()
	if settingsLight.LIGHTER then
		settingsLight.LIGHTER:Destroy()
		settingsLight.LIGHTER = nil
	end
end)

cmd.add({"lighting","lightingcontrol"},{"lighting (lightingcontrol)","Manage lighting technology settings"},function(...)
	const args = {...}
	const target = args[1]
	const buttons = {}
	const function applyLightingTechnology(tech)
		if not Services.Lighting or not tech then
			return
		end
		Services.Lighting.Technology = tech
		const style = tech == Enum.Technology.Future and Enum.LightingStyle.Realistic or Enum.LightingStyle.Soft
		NAlib.setProperty(Services.Lighting, "LightingStyle", style)
	end
	for _, lt in Enum.Technology:GetEnumItems() do
		Insert(buttons, {
			Text = lt.Name,
			Callback = function()
				applyLightingTechnology(lt)
			end
		})
	end
	if target and target ~= "" then
		local found = false
		for _, btn in buttons do
			if Match(Lower(btn.Text), Lower(target)) then
				btn.Callback()
				DebugNotif("Lighting technology set to "..btn.Text, 3)
				found = true
				break
			end
		end
		if not found then
			DebugNotif("No matching lighting tech for: "..target, 3)
		end
	else
		Window({
			Title = "Lighting Technology Options",
			Buttons = buttons
		})
	end
end)

cmd.add({"friend"}, {"friend <player>", "Sends a friend request to your target"}, function(p)
	const tg = getPlr(p)

	const function dlg()
		const rg = __lt.cm("CoreGui", "FindFirstChild", "RobloxGui")
		if not rg then return nil end
		return rg:FindFirstChild("PromptDialog", true) or rg:FindFirstChild("RobloxPromptGui", true)
	end

	const function waitPrompt()
		local t0 = os.clock()
		while os.clock() - t0 < 2.5 do
			if dlg() then break end
			Wait()
		end
		t0 = os.clock()
		while os.clock() - t0 < 60 do
			const d = dlg()
			if not d then break end
			if d:IsA("GuiObject") and not d.Visible then break end
			Wait()
		end
	end

	for _, t in tg do
		if t and t ~= LocalPlayer and not LocalPlayer:IsFriendsWith(t.UserId) then
			const ok = pcall(function()
				__lt.cm("StarterGui", "SetCore", "PromptSendFriendRequest", t)
			end)
			if ok then
				waitPrompt()
			else
				pcall(function()
					LocalPlayer:RequestFriendship(t)
				end)
			end
		end
	end
end, true)

cmd.add({"unfriend"}, {"unfriend <player>", "Prompts to unfriend your target"}, function(p)
	const tg = getPlr(p)

	const function dlg()
		const rg = __lt.cm("CoreGui", "FindFirstChild", "RobloxGui")
		if not rg then return nil end
		return rg:FindFirstChild("PromptDialog", true) or rg:FindFirstChild("RobloxPromptGui", true)
	end

	const function waitPrompt()
		local t0 = os.clock()
		while os.clock() - t0 < 2.5 do
			if dlg() then break end
			Wait()
		end
		t0 = os.clock()
		while os.clock() - t0 < 60 do
			const d = dlg()
			if not d then break end
			if d:IsA("GuiObject") and not d.Visible then break end
			Wait()
		end
	end

	for _, t in tg do
		if t and t ~= LocalPlayer and LocalPlayer:IsFriendsWith(t.UserId) then
			const ok = pcall(function()
				__lt.cm("StarterGui", "SetCore", "PromptUnfriend", t)
			end)
			if ok then
				waitPrompt()
			else
				pcall(function()
					LocalPlayer:RevokeFriendship(t)
				end)
			end
		end
	end
end, true)

NAmanage.GetBlockedUserIdsSafe = NAmanage.GetBlockedUserIdsSafe or function()
	for _ = 1, 25 do
		local ok, ids = pcall(function()
			return __lt.cm("StarterGui", "GetCore", "GetBlockedUserIds")
		end)
		if ok and type(ids) == "table" then
			return ids
		end
		Wait(0.05)
	end
	return nil
end

NAmanage.IsBlockedUserId = NAmanage.IsBlockedUserId or function(userId, ids)
	userId = tonumber(userId)
	if not userId then
		return false
	end
	ids = type(ids) == "table" and ids or NAmanage.GetBlockedUserIdsSafe()
	if type(ids) ~= "table" then
		return false
	end
	for _, id in ids do
		if tonumber(id) == userId then
			return true
		end
	end
	return false
end

NAmanage.GetCorePromptGui = NAmanage.GetCorePromptGui or function()
	local ok, rg = pcall(function()
		return __lt.cm("CoreGui", "FindFirstChild", "RobloxGui")
	end)
	if not ok or not rg then
		return nil
	end
	local okFind, gui = pcall(function()
		return rg:FindFirstChild("PromptDialog", true) or rg:FindFirstChild("RobloxPromptGui", true)
	end)
	if okFind then
		return gui
	end
	return nil
end

NAmanage.WaitCorePromptClosed = NAmanage.WaitCorePromptClosed or function()
	local t0 = os.clock()
	while os.clock() - t0 < 2.5 do
		if NAmanage.GetCorePromptGui() then
			break
		end
		Wait()
	end
	t0 = os.clock()
	while os.clock() - t0 < 60 do
		const gui = NAmanage.GetCorePromptGui()
		if not gui then
			break
		end
		if gui:IsA("GuiObject") then
			local ok, vis = pcall(function()
				return gui.Visible
			end)
			if ok and vis == false then
				break
			end
		elseif gui:IsA("LayerCollector") then
			local ok, en = pcall(function()
				return gui.Enabled
			end)
			if ok and en == false then
				break
			end
		end
		Wait(0.05)
	end
end

NAmanage.GetFirstBlockTarget = NAmanage.GetFirstBlockTarget or function(list)
	if type(list) ~= "table" then
		return nil
	end
	for _, plr in list do
		if typeof(plr) == "Instance" and plr:IsA("Player") and plr ~= LocalPlayer and tonumber(plr.UserId) and plr.UserId >= 0 then
			return plr
		end
	end
	return nil
end

NAmanage.PromptBlockState = NAmanage.PromptBlockState or function(plr, unblock)
	if typeof(plr) ~= "Instance" or not plr:IsA("Player") or plr == LocalPlayer or tonumber(plr.UserId) == nil or plr.UserId < 0 then
		return false
	end
	if NAmanage._blockPromptBusy then
		return false
	end
	if NAmanage.GetCorePromptGui() then
		return false
	end

	NAmanage._blockPromptBusy = true
	local okOpen = false
	const coreName = unblock and "PromptUnblockPlayer" or "PromptBlockPlayer"

	for _ = 1, 25 do
		const ok = pcall(function()
			__lt.cm("StarterGui", "SetCore", coreName, plr)
		end)
		if ok then
			okOpen = true
			break
		end
		Wait(0.05)
	end

	if okOpen then
		pcall(NAmanage.WaitCorePromptClosed)
	end

	NAmanage._blockPromptBusy = false
	return okOpen
end

cmd.add({"block","blockuser"},{"block <player> (blockuser)","Open block / unblock prompt for target player"},function(p)
	const t = NAmanage.GetFirstBlockTarget(getPlr(p))
	if not t then
		DoNotif("No valid player found", 2)
		return
	end

	const ids = NAmanage.GetBlockedUserIdsSafe()
	const unblock = NAmanage.IsBlockedUserId(t.UserId, ids)
	if not NAmanage.PromptBlockState(t, unblock) then
		DoNotif("Failed to open block prompt for "..tostring(t.Name), 2)
	end
end,true)

cmd.add({"unblock","unblockuser"},{"unblock <player> (unblockuser)","Open unblock prompt for target player"},function(p)
	const t = NAmanage.GetFirstBlockTarget(getPlr(p))
	if not t then
		DoNotif("No valid player found", 2)
		return
	end

	if not NAmanage.PromptBlockState(t, true) then
		DoNotif("Failed to open unblock prompt for "..tostring(t.Name), 2)
	end
end,true)

NAmanage.NAgetFriendCircles=function()
	const players = __lt.cm("Players", "GetPlayers")
	const graph, seen, groups = {}, {}, {}
	const friendSets = {}

	for _, plr in players do
		graph[plr] = {}
	end

	const function getFriendSet(plr)
		if friendSets[plr] then
			return friendSets[plr]
		end
		const set = {}
		local ok, pages = pcall(Services.Players.GetFriendsAsync, Services.Players, plr.UserId)
		if ok and pages then
			const function addPage(page)
				for _, item in page do
					if item and item.Id then
						set[item.Id] = true
					end
				end
			end
			addPage(pages:GetCurrentPage())
			while pages.IsFinished ~= nil and pages.IsFinished == false do
				local okN, nextPage = pcall(pages.AdvanceToNextPageAsync, pages)
				if not okN or not nextPage then
					break
				end
				addPage(nextPage)
			end
		end
		friendSets[plr] = set
		return set
	end

	for i = 1, #players do
		const p1 = players[i]
		const set1 = getFriendSet(p1)
		for j = i + 1, #players do
			const p2 = players[j]
			if set1[p2.UserId] then
				Insert(graph[p1], p2)
				Insert(graph[p2], p1)
			end
		end
	end

	const function dfs(plr, group)
		seen[plr] = true
		Insert(group, plr)
		for _, other in graph[plr] do
			if not seen[other] then
				dfs(other, group)
			end
		end
	end

	for _, plr in players do
		if not seen[plr] then
			const group = {}
			dfs(plr, group)
			Insert(groups, group)
		end
	end

	table.sort(groups, function(a, b)
		return #a > #b
	end)

	return groups, graph
end

NAmanage.SocialClientGetService = NAmanage.SocialClientGetService or function()
	return SafeGetService("SocialService")
end

NAmanage.SocialClientGetLocalPlayer = NAmanage.SocialClientGetLocalPlayer or function()
	return Services.Players and Services.Players.LocalPlayer or nil
end

NAmanage.SocialClientResolveUserId = NAmanage.SocialClientResolveUserId or function(value)
	value = tostring(value or "")
	if value == "" then
		return nil
	end
	const numeric = tonumber(value)
	if numeric and numeric > 0 then
		return math.floor(numeric)
	end
	if not Services.Players or type(Services.Players.GetUserIdFromNameAsync) ~= "function" then
		return nil
	end
	local ok, userId = pcall(Services.Players.GetUserIdFromNameAsync, Services.Players, value)
	if ok and tonumber(userId) and tonumber(userId) > 0 then
		return math.floor(tonumber(userId))
	end
	return nil
end

NAmanage.SocialClientPromptInvite = NAmanage.SocialClientPromptInvite or function(target)
	const service = NAmanage.SocialClientGetService()
	const player = NAmanage.SocialClientGetLocalPlayer()
	if not service or not player then
		DoNotif("SocialService is unavailable on this client.", 4, "Social")
		return false
	end
	local inviteOptions
	local targetUserId
	if target ~= nil and tostring(target) ~= "" then
		targetUserId = NAmanage.SocialClientResolveUserId(target)
		if not targetUserId then
			DoNotif("Could not resolve that username/UserId.", 4, "Social")
			return false
		end
		local okOptions, optionsOrError = pcall(function()
			const options = InstanceNew("ExperienceInviteOptions")
			options.InviteUser = targetUserId
			return options
		end)
		if not okOptions then
			DoNotif("Targeted invites are unavailable: "..tostring(optionsOrError), 5, "Social")
			return false
		end
		inviteOptions = optionsOrError
	end
	if type(service.CanSendGameInviteAsync) == "function" then
		local okCan, canInvite = pcall(function()
			if targetUserId then
				return service:CanSendGameInviteAsync(player, targetUserId)
			end
			return service:CanSendGameInviteAsync(player)
		end)
		if not okCan then
			DoNotif("Could not check invite availability: "..tostring(canInvite), 5, "Social")
			return false
		end
		if canInvite ~= true then
			DoNotif(targetUserId and "You cannot invite that user from this client." or "Game invites are unavailable on this client.", 4, "Social")
			return false
		end
	end
	local okPrompt, promptError = pcall(function()
		return service:PromptGameInvite(player, inviteOptions)
	end)
	if not okPrompt then
		DoNotif("Invite prompt failed: "..tostring(promptError), 5, "Social")
		return false
	end
	return true
end

NAmanage.SocialClientEventTitle = NAmanage.SocialClientEventTitle or function(event)
	if type(event) ~= "table" then
		return "Unknown Event"
	end
	return tostring(event.DisplayTitle or event.Title or event.Id or "Unknown Event")
end

NAmanage.SocialClientEventTime = NAmanage.SocialClientEventTime or function(value)
	if type(value) ~= "table" then
		return "Unknown"
	end
	local year = tonumber(value.Year)
	local month = tonumber(value.Month)
	local day = tonumber(value.Day)
	local hour = tonumber(value.Hour) or 0
	local minute = tonumber(value.Minute) or 0
	if year and month and day then
		return Format("%04d-%02d-%02d %02d:%02d", year, month, day, hour, minute)
	end
	return "Unknown"
end

NAmanage.SocialClientEventInfoText = NAmanage.SocialClientEventInfoText or function(event, fallbackEventId)
	if type(event) ~= "table" then
		return "Event data unavailable."
	end
	const eventId = tostring(event.Id or fallbackEventId or "Unknown")
	const lines = {
		"Title: "..NAmanage.SocialClientEventTitle(event),
		"Event ID: "..eventId,
		"Subtitle: "..tostring(event.DisplaySubtitle or event.Subtitle or ""),
		"Status: "..tostring(event.Status or "Unknown"),
		"RSVP: "..tostring(event.UserRsvpStatus or "None"),
		"Started: "..tostring(event.HasStarted == true),
		"Ended: "..tostring(event.HasEnded == true),
		"Start: "..NAmanage.SocialClientEventTime(event.StartTime),
		"End: "..NAmanage.SocialClientEventTime(event.EndTime),
	}
	const description = tostring(event.DisplayDescription or event.Description or "")
	if description ~= "" then
		lines[#lines + 1] = ""
		lines[#lines + 1] = description
	end
	return Concat(lines, "\n")
end

NAmanage.SocialClientOpenEventPopup = NAmanage.SocialClientOpenEventPopup or function(event, fallbackEventId)
	if type(event) ~= "table" then
		DoNotif("Event data unavailable.", 4, "Social")
		return false
	end
	const eventId = tostring(event.Id or fallbackEventId or "")
	const infoText = NAmanage.SocialClientEventInfoText(event, eventId)
	const buttons = {}
	if eventId ~= "" then
		buttons[#buttons + 1] = {
			Text = "Copy Event ID";
			Callback = function()
				if type(setclipboard) == "function" then
					pcall(setclipboard, eventId)
					DoNotif("Event ID copied: "..eventId, 3, "Social")
				else
					DoNotif("Clipboard unavailable. Event ID: "..eventId, 6, "Social")
				end
			end;
		}
		buttons[#buttons + 1] = {
			Text = "RSVP";
			Callback = function()
				NAmanage.SocialClientPromptRsvp(eventId)
			end;
		}
	end
	buttons[#buttons + 1] = {
		Text = "Copy Event Info";
		Callback = function()
			if type(setclipboard) == "function" then
				pcall(setclipboard, infoText)
				DoNotif("Event info copied.", 3, "Social")
			else
				DoNotif("Clipboard unavailable.", 4, "Social")
			end
		end;
	}
	Popup({
		Title = NAmanage.SocialClientEventTitle(event);
		Description = infoText;
		Buttons = buttons;
	})
	return true
end

NAmanage.SocialClientShowEvents = NAmanage.SocialClientShowEvents or function()
	const service = NAmanage.SocialClientGetService()
	if not service or type(service.GetUpcomingExperienceEventsAsync) ~= "function" then
		DoNotif("Experience events are unavailable on this client.", 4, "Social")
		return false
	end
	local ok, events = pcall(function()
		return service:GetUpcomingExperienceEventsAsync()
	end)
	if not ok then
		DoNotif("Failed to load experience events: "..tostring(events), 5, "Social")
		return false
	end
	if type(events) ~= "table" or #events == 0 then
		Popup({Title = "Experience Events", Description = "No upcoming experience events were returned."})
		return true
	end
	const buttons = {}
	const allIds = {}
	local shown = 0
	for index, event in ipairs(events) do
		if index > 15 then
			break
		end
		if type(event) == "table" then
			shown += 1
			const selectedEvent = event
			const eventId = tostring(selectedEvent.Id or "")
			const title = NAmanage.SocialClientEventTitle(selectedEvent)
			if eventId ~= "" then
				allIds[#allIds + 1] = eventId
			end
			const selectedEventId = eventId
			buttons[#buttons + 1] = {
				Text = Format("%d) %s%s", shown, title, selectedEventId ~= "" and (" | "..selectedEventId) or "");
				Callback = function()
					NAmanage.SocialClientOpenEventPopup(selectedEvent, selectedEventId)
				end;
			}
		end
	end
	if #allIds > 0 then
		buttons[#buttons + 1] = {
			Text = "Copy All Event IDs";
			Callback = function()
				const copied = Concat(allIds, "\n")
				if type(setclipboard) == "function" then
					pcall(setclipboard, copied)
					DoNotif(Format("Copied %d event ID%s.", #allIds, #allIds == 1 and "" or "s"), 3, "Social")
				else
					DoNotif("Clipboard unavailable.", 4, "Social")
				end
			end;
		}
	end
	const extra = #events > shown and Format("\nShowing the first %d of %d events.", shown, #events) or ""
	Popup({
		Title = "Experience Events";
		Description = "Select an event to view its details, copy its ID/info, or RSVP."..extra;
		Buttons = buttons;
	})
	return true
end

NAmanage.SocialClientShowEventInfo = NAmanage.SocialClientShowEventInfo or function(eventId)
	const service = NAmanage.SocialClientGetService()
	eventId = tostring(eventId or "")
	if eventId == "" then
		DoNotif("Missing event ID.", 3, "Social")
		return false
	end
	if not service or type(service.GetExperienceEventAsync) ~= "function" then
		DoNotif("Experience event lookup is unavailable on this client.", 4, "Social")
		return false
	end
	local ok, event = pcall(function()
		return service:GetExperienceEventAsync(eventId)
	end)
	if not ok then
		DoNotif("Event lookup failed: "..tostring(event), 5, "Social")
		return false
	end
	if type(event) ~= "table" then
		DoNotif("That event is unavailable in this experience.", 4, "Social")
		return false
	end
	return NAmanage.SocialClientOpenEventPopup(event, eventId)
end

NAmanage.SocialClientPromptRsvp = NAmanage.SocialClientPromptRsvp or function(eventId)
	const service = NAmanage.SocialClientGetService()
	eventId = tostring(eventId or "")
	if eventId == "" then
		DoNotif("Missing event ID.", 3, "Social")
		return false
	end
	if not service or type(service.PromptRsvpToEventAsync) ~= "function" then
		DoNotif("Event RSVP is unavailable on this client.", 4, "Social")
		return false
	end
	local ok, status = pcall(function()
		return service:PromptRsvpToEventAsync(eventId)
	end)
	if not ok then
		DoNotif("RSVP prompt failed: "..tostring(status), 5, "Social")
		return false
	end
	DoNotif("Event RSVP status: "..tostring(status), 4, "Social")
	return true, status
end

NAmanage.SocialClientPromptFeedback = NAmanage.SocialClientPromptFeedback or function()
	const service = NAmanage.SocialClientGetService()
	if not service or type(service.PromptFeedbackSubmissionAsync) ~= "function" then
		DoNotif("Feedback submission is unavailable on this client.", 4, "Social")
		return false
	end
	local ok, result = pcall(function()
		return service:PromptFeedbackSubmissionAsync()
	end)
	if not ok then
		DoNotif("Feedback prompt failed: "..tostring(result), 5, "Social")
		return false
	end
	return true, result
end

cmd.add({"invitefriends","invite"},{"invitefriends [username/userId] (invite)","Opens Roblox's client invite prompt, optionally targeting a user"},function(target)
	NAmanage.SocialClientPromptInvite(target)
end)

cmd.add({"experienceevents","events"},{"experienceevents (events)","Shows upcoming experience events with copy/details/RSVP options"},function()
	NAmanage.SocialClientShowEvents()
end)

cmd.add({"eventinfo"},{"eventinfo <eventId>","Shows an experience event with copy/details/RSVP options"},function(eventId)
	NAmanage.SocialClientShowEventInfo(eventId)
end,true)

cmd.add({"rsvpevent","eventrsvp"},{"rsvpevent <eventId> (eventrsvp)","Opens Roblox's RSVP prompt for an experience event"},function(eventId)
	NAmanage.SocialClientPromptRsvp(eventId)
end,true)

cmd.add({"feedback"},{"feedback","Opens Roblox's client experience feedback prompt"},function()
	NAmanage.SocialClientPromptFeedback()
end)

cmd.add({"friendweb","fweb"},{"friendweb (fweb)","Finds friend circles in the current server"},function()
	DoNotif("Looking for friend circles... I'll let you know what I find.", 4)

	local groups, graph = NAmanage.NAgetFriendCircles()
	local useDisplayNames = false
	local ok, enabled = pcall(function()
		return Services.StarterGui and __lt.cm("StarterGui", "GetCoreGuiEnabled", Enum.CoreGuiType.PlayerList)
	end)
	if ok and enabled then
		useDisplayNames = true
	end

	const lines = {}
	local index = 1
	for _, group in groups do
		if #group > 1 then
			table.sort(group, function(a, b)
				return (useDisplayNames and a.DisplayName or a.Name) < (useDisplayNames and b.DisplayName or b.Name)
			end)
			local edgeCount = 0
			const parts = {}
			for _, plr in group do
				const deg = graph[plr] and #graph[plr] or 0
				edgeCount += deg
				parts[#parts + 1] = Format("%s [%d]", useDisplayNames and plr.DisplayName or plr.Name, deg)
			end
			edgeCount = math.floor(edgeCount / 2)
			Insert(lines, Format("%d) %s (links: %d)", index, Concat(parts, ", "), edgeCount))
			index = index + 1
		end
	end

	const groupsFound = #lines
	const body = (groupsFound == 0) and "No friend circles found in this server." or ("Here are the circles I found:\n"..Concat(lines, "\n"))
	DoNotif(Format("Friend scan finished: %d circle%s found.", groupsFound, groupsFound == 1 and "" or "s"), 4, "Friend Web")
	DoPopup({ Title = "Friend Circles", Description = body })
end)

cmd.add({"massfollowedinto"}, {"massfollowedinto", "Shows everyone in the server that followed someone into the game"}, function()
	const lines = {}

	for _, plr in __lt.cm("Players", "GetPlayers") do
		local okFollow, followIdRaw = pcall(function()
			return plr.FollowUserId
		end)
		const followId = (okFollow and tonumber(followIdRaw)) or 0
		if followId and followId ~= 0 then
			local followedName = tostring(followId)
			local okName, resolvedName = pcall(Services.Players.GetNameFromUserIdAsync, Services.Players, followId)
			if okName and type(resolvedName) == "string" and resolvedName ~= "" then
				followedName = resolvedName
			end
			lines[#lines + 1] = plr.Name.." followed "..followedName.." into game"
		end
	end

	if #lines == 0 then
		DoNotif("No players in this server joined by following someone.", 3, "Followed Into")
		return
	end

	table.sort(lines, function(a, b)
		return a:lower() < b:lower()
	end)
	DoNotif("Showing all followed-into players.", 3, "Followed Into")
	DoWindow(Concat(lines, "\n"), "Followed Into")
end)

cmd.add({"tweengotocampos","tweentocampos","tweentcp"}, {"tweengotocampos (tweentcp)","Another version of goto camera position but bypassing more anti-cheats"}, function()
	const player = Services.Players.LocalPlayer;
	function teleportPlayer()
		const character = player.Character or player.CharacterAdded:wait(1);
		const camera = Services.Workspace.CurrentCamera;
		const cameraPosition = camera.CFrame.Position;
		const tween = __lt.cm("TweenService", "Create", character.PrimaryPart, TweenInfo.new(NAmanage.resolveTweenDuration(2)), {
			CFrame = CFrame.new(cameraPosition)
		});
		tween:Play();
	end;
	const camera = Services.Workspace.CurrentCamera;
	repeat
		Wait();
	until camera.CFrame ~= CFrame.new();
	teleportPlayer();
end);

cmd.add({"delete","remove","del"}, {"delete {partname} (remove, del)","Removes any part with a certain name from the workspace"}, function(...)
	local deleteCount = 0;
	const args = {
		...
	};
	const targetName = Concat(args, " ");
	for _, d in Services.Workspace:QueryDescendants("Instance") do
		if d.Name:lower() == targetName:lower() then
			d:Destroy();
			deleteCount = deleteCount + 1;
		end;
	end;
	Wait();
	if deleteCount > 0 then
		DebugNotif("Deleted " .. deleteCount .. " instance(s) of '" .. targetName .. "'", 2.5);
	else
		DebugNotif("'" .. targetName .. "' not found to delete", 2.5);
	end;
end, true);

cmd.add({"deletefind", "removefind", "delfind"}, {"deletefind {partname} (removefind, delfind)", "Removes any part with a name containing the given text from the workspace"}, function(...)
	local deFind = 0
	const targetName = Concat({...}, " "):lower()

	for _, d in Services.Workspace:QueryDescendants("Instance") do
		if d.Name:lower():find(targetName) then
			d:Destroy()
			deFind = deFind + 1
		end
	end

	Wait()

	if deFind > 0 then
		DebugNotif("Deleted "..deFind.." instance(s) containing '"..targetName.."'", 2.5)
	else
		DebugNotif("No instances found containing '"..targetName.."'", 2.5)
	end
end, true)

cmd.add({"deletelighting", "removelighting", "removel", "ldel"},{"deletelighting (removelighting, removel, ldel)","Removes all descendants (objects) within Lighting."},function()
	for _, l in NAmanage.QueryDescendants(Services.Lighting, "Instance") do
		l:Destroy()
	end
end)

cmd.add({"lightingdisable", "disablelighting", "ldisable"},{"lightingdisable (disablelighting, ldisable)", "Disables all post-processing effects in Lighting instead of deleting them."},function()
	for _, inst in NAmanage.QueryDescendants(Services.Lighting, "PostEffect") do
		inst.Enabled = false
	end
end)

autoRemover = {}
autoRemoveConnection = nil

function handleDescendantAdd(part)
	if #autoRemover > 0 then
		if FindInTable(autoRemover, part.Name:lower()) then
			Defer(function()
				if part and part.Parent then
					part:Destroy()
				end
			end)
		end
	else
		if autoRemoveConnection then
			autoRemoveConnection:Disconnect()
			autoRemoveConnection = nil
		end
	end
end

cmd.add({"autodelete", "autoremove", "autodel"}, {"autodelete {partname} (autoremove, autodel)", "Removes any part with a certain name from the workspace on loop"}, function(...)
	const args = {...}
	const targetName = Concat(args, " "):lower()

	if not FindInTable(autoRemover, targetName) then
		Insert(autoRemover, targetName)
		for _, part in Services.Workspace:QueryDescendants("Instance") do
			if part.Name:lower() == targetName then
				part:Destroy()
			end
		end
	end

	if not autoRemoveConnection then
		autoRemoveConnection = NAmanage.wsAdd(handleDescendantAdd)
	end

	Wait()
	DebugNotif("Auto deleting instances with name: "..targetName, 2.5)
end, true)

cmd.add({"unautodelete", "unautoremove", "unautodel"}, {"unautodelete {partname} (unautoremove, unautodel)", "Disables autodelete"}, function(...)
	if type(autoRemover) ~= "table" then
		autoRemover = {}
	end

	if #autoRemover == 0 then
		DoNotif("No autodelete names are active.", 2)
		return
	end

	const filter = Lower(Concat({...}, " "))

	const function disconnectAutoRemove()
		if autoRemoveConnection then
			autoRemoveConnection:Disconnect()
			autoRemoveConnection = nil
		end
	end

	const function cleanupConnection()
		if #autoRemover == 0 then
			disconnectAutoRemove()
		end
	end

	const function removeAll()
		autoRemover = {}
		disconnectAutoRemove()
		DoNotif("Cleared all autodelete names.", 2)
	end

	const function removeByTerm(term)
		for i = #autoRemover, 1, -1 do
			if autoRemover[i] == term then
				table.remove(autoRemover, i)
			end
		end
		cleanupConnection()
		DoNotif("Stopped autodeleting '"..term.."'.", 2)
	end

	if filter ~= "" then
		if filter == "all" then
			removeAll()
			return
		end
		local picked = nil
		for _, t in autoRemover do
			if t == filter then
				picked = t
				break
			end
		end
		if not picked then
			for _, t in autoRemover do
				if Match(t, filter) then
					picked = t
					break
				end
			end
		end
		if picked then
			removeByTerm(picked)
		else
			DoNotif("No matching autodelete name for: "..filter, 3)
		end
		return
	end

	const buttons = {}
	Insert(buttons, { Text = "All", Callback = removeAll })
	for _, t in autoRemover do
		Insert(buttons, { Text = t, Callback = function() removeByTerm(t) end })
	end

	Window({
		Title = "AutoDelete Names",
		Description = "Choose a tracked name to stop deleting (future spawns included).",
		Buttons = buttons
	})
end)

autoFinder = {}
finderConn = nil

function onAdd(obj)
	if #autoFinder > 0 then
		for _, kw in autoFinder do
			if obj.Name:lower():find(kw) then
				Defer(function()
					if obj and obj.Parent then
						obj:Destroy()
					end
				end)
				break
			end
		end
	else
		if finderConn then
			finderConn:Disconnect()
			finderConn = nil
		end
	end
end

cmd.add({"autodeletefind", "autoremovefind", "autodelfind"}, {"autodeletefind {name} (autoremovefind, autodelfind)", "Auto removes parts with names containing text"}, function(...)
	const args = {...}
	const kw = Concat(args, " "):lower()

	if not FindInTable(autoFinder, kw) then
		Insert(autoFinder, kw)
		for _, obj in Services.Workspace:QueryDescendants("Instance") do
			if obj.Name:lower():find(kw) then
				obj:Destroy()
			end
		end
	end

	if not finderConn then
		finderConn = NAmanage.wsAdd(onAdd)
	end

	Wait()
	DebugNotif("Auto deleting parts containing: "..kw, 2.5)
end, true)

cmd.add({"unautodeletefind", "unautoremovefind", "unautodelfind"}, {"unautodeletefind (unautoremovefind,unautodelfind)", "Stops autodeletefind"}, function(...)
	if type(autoFinder) ~= "table" then
		autoFinder = {}
	end

	if #autoFinder == 0 then
		DoNotif("No autodeletefind keywords are active.", 2)
		return
	end

	const filter = Lower(Concat({...}, " "))

	const function disconnectFinder()
		if finderConn then
			finderConn:Disconnect()
			finderConn = nil
		end
	end

	const function cleanupConnection()
		if #autoFinder == 0 then
			disconnectFinder()
		end
	end

	const function removeAll()
		autoFinder = {}
		disconnectFinder()
		DoNotif("Cleared all autodeletefind keywords.", 2)
	end

	const function removeByTerm(term)
		for i = #autoFinder, 1, -1 do
			if autoFinder[i] == term then
				table.remove(autoFinder, i)
			end
		end
		cleanupConnection()
		DoNotif("Stopped autodeleting parts containing '"..term.."'.", 2)
	end

	if filter ~= "" then
		if filter == "all" then
			removeAll()
			return
		end
		local picked = nil
		for _, t in autoFinder do
			if t == filter then
				picked = t
				break
			end
		end
		if not picked then
			for _, t in autoFinder do
				if Match(t, filter) then
					picked = t
					break
				end
			end
		end
		if picked then
			removeByTerm(picked)
		else
			DoNotif("No matching autodeletefind keyword for: "..filter, 3)
		end
		return
	end

	const buttons = {}
	Insert(buttons, { Text = "All", Callback = removeAll })
	for _, t in autoFinder do
		Insert(buttons, { Text = t, Callback = function() removeByTerm(t) end })
	end

	Window({
		Title = "AutoDeleteFind Keywords",
		Description = "Select a keyword to stop clearing matching descendants.",
		Buttons = buttons
	})
end)

cmd.add({"deleteclass", "removeclass", "dc"}, {"deleteclass {ClassName} (removeclass, dc)", "Removes any part with a certain classname from the workspace"}, function(...)
	const args = {...}
	const targetClass = args[1]:lower()
	local deleteCount = 0

	for _, part in Services.Workspace:QueryDescendants("Instance") do
		if part.ClassName:lower() == targetClass then
			part:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()
	if deleteCount > 0 then
		DebugNotif("Deleted "..deleteCount.." instance(s) of class: "..targetClass, 2.5)
	else
		DebugNotif("No instances of class: "..targetClass.." found to delete", 2.5)
	end
end, true)

NAStuff.autoClassRemover = {}
NAStuff.autoClassConnection = nil

function handleClassDescendantAdd(part)
	if #NAStuff.autoClassRemover > 0 then
		if FindInTable(NAStuff.autoClassRemover, part.ClassName:lower()) then
			Defer(function()
				if part and part.Parent then
					part:Destroy()
				end
			end)
		end
	else
		if NAStuff.autoClassConnection then
			NAStuff.autoClassConnection:Disconnect()
			NAStuff.autoClassConnection = nil
		end
	end
end

cmd.add({"autodeleteclass", "autoremoveclass", "autodc"}, {"autodeleteclass {ClassName} (autoremoveclass, autodc)", "Removes any part with a certain classname from the workspace on loop"}, function(...)
	const args = {...}
	const targetClass = args[1]:lower()

	if not FindInTable(NAStuff.autoClassRemover, targetClass) then
		Insert(NAStuff.autoClassRemover, targetClass)
		for _, part in Services.Workspace:QueryDescendants("Instance") do
			if part.ClassName:lower() == targetClass then
				part:Destroy()
			end
		end
	end

	if not NAStuff.autoClassConnection then
		NAStuff.autoClassConnection = NAmanage.wsAdd(handleClassDescendantAdd)
	end

	Wait()
	DebugNotif("Auto deleting instances with class: "..targetClass, 2.5)
end, true)

cmd.add({"unautodeleteclass", "unautoremoveclass", "unautodc"}, {"unautodeleteclass {ClassName} (unautoremoveclass, unautodc)", "Disables autodeleteclass"}, function(...)
	if type(NAStuff.autoClassRemover) ~= "table" then
		NAStuff.autoClassRemover = {}
	end

	if #NAStuff.autoClassRemover == 0 then
		DoNotif("No autodeleteclass entries are active.", 2)
		return
	end

	const filter = Lower(Concat({...}, " "))

	const function disconnectClass()
		if NAStuff.autoClassConnection then
			NAStuff.autoClassConnection:Disconnect()
			NAStuff.autoClassConnection = nil
		end
	end

	const function cleanupConnection()
		if #NAStuff.autoClassRemover == 0 then
			disconnectClass()
		end
	end

	const function removeAll()
		NAStuff.autoClassRemover = {}
		disconnectClass()
		DoNotif("Cleared all autodeleteclass entries.", 2)
	end

	const function removeByTerm(term)
		for i = #NAStuff.autoClassRemover, 1, -1 do
			if NAStuff.autoClassRemover[i] == term then
				table.remove(NAStuff.autoClassRemover, i)
			end
		end
		cleanupConnection()
		DoNotif("Stopped autodeleting class '"..term.."'.", 2)
	end

	if filter ~= "" then
		if filter == "all" then
			removeAll()
			return
		end
		local picked = nil
		for _, t in NAStuff.autoClassRemover do
			if t == filter then
				picked = t
				break
			end
		end
		if not picked then
			for _, t in NAStuff.autoClassRemover do
				if Match(t, filter) then
					picked = t
					break
				end
			end
		end
		if picked then
			removeByTerm(picked)
		else
			DoNotif("No matching autodeleteclass term for: "..filter, 3)
		end
		return
	end

	const buttons = {}
	Insert(buttons, { Text = "All", Callback = removeAll })
	for _, t in NAStuff.autoClassRemover do
		Insert(buttons, { Text = t, Callback = function() removeByTerm(t) end })
	end

	Window({
		Title = "AutoDeleteClass",
		Description = "Pick a class name to stop auto deleting.",
		Buttons = buttons
	})
end)

cmd.add({"chardelete", "charremove", "chardel", "cdelete", "cremove", "cdel"}, {"chardelete {partname} (charremove, chardel, cdelete, cremove, cdel)", "Removes any part with a certain name from your character"}, function(...)
	const args = {...}
	const targetName = Concat(args, " "):lower()
	local deleteCount = 0

	for _, part in NAmanage.QueryDescendants(Player.Character, "Instance") do
		if part.Name:lower() == targetName then
			part:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()
	if deleteCount > 0 then
		DebugNotif("Deleted "..deleteCount.." instance(s) of '"..targetName.."' inside the character", 2.5)
	else
		DebugNotif("'"..targetName.."' not found in the character", 2.5)
	end
end, true)

cmd.add({"chardeletefind", "charremovefind", "chardelfind", "cdeletefind", "cremovefind", "cdelfind"}, {"chardeletefind {name} (charremovefind, chardelfind, cdeletefind, cremovefind, cdelfind)", "Removes parts in your character with names containing text"}, function(...)
	const args = {...}
	const kw = Concat(args, " "):lower()
	local count = 0

	for _, obj in NAmanage.QueryDescendants(Player.Character, "Instance") do
		if obj.Name:lower():find(kw) then
			obj:Destroy()
			count = count + 1
		end
	end

	Wait()
	if count > 0 then
		DebugNotif("Deleted "..count.." instance(s) containing '"..kw.."' in character", 2.5)
	else
		DebugNotif("Nothing found containing '"..kw.."' in character", 2.5)
	end
end, true)

cmd.add({"chardeleteclass", "charremoveclass", "chardeleteclassname", "cdc"}, {"chardeleteclass {ClassName} (charremoveclass, chardeleteclassname, cdc)", "Removes any part with a certain classname from your character"}, function(...)
	const args = {...}
	const targetClass = args[1]:lower()
	local deleteCount = 0

	for _, part in NAmanage.QueryDescendants(Player.Character, "Instance") do
		if part.ClassName:lower() == targetClass then
			part:Destroy()
			deleteCount = deleteCount + 1
		end
	end

	Wait()
	if deleteCount > 0 then
		DebugNotif("Deleted "..deleteCount.." instance(s) of class: "..targetClass.." inside the character", 2.5)
	else
		DebugNotif("No instances of class: "..targetClass.." found in the character", 2.5)
	end
end, true)

NAStuff.activeTeleports = {};
originalIO.gotoNext = originalIO.gotoNext or {};

do
	const gotoNext = originalIO.gotoNext;
	const state = gotoNext.state or {
		teleporting = false,
		totalDuplicates = 0,
		duplicatesSessionOrder = {},
		tracerPart = nil,
		tracerConnection = nil,
		tracerHue = 0
	};
	gotoNext.state = state;
	function gotoNext.trim(str)
		if type(str) ~= "string" then
			return str;
		end;
		const trimmed = str:match("^%s*(.-)%s*$");
		return trimmed or str;
	end;
	function gotoNext.tokenizeArgs(rawArgs)
		const tokens = {};
		if not rawArgs or #rawArgs == 0 then
			return tokens;
		end;
		const combined = Concat(rawArgs, " ");
		if combined == "" then
			return tokens;
		end;
		const length = #combined;
		local index = 1;
		while index <= length do
			while index <= length and (combined:sub(index, index)):match("%s") do
				index = index + 1;
			end;
			if index > length then
				break;
			end;
			const ch = combined:sub(index, index);
			if ch == "\"" or ch == "'" then
				const quote = ch;
				index = index + 1;
				const buffer = {};
				while index <= length do
					const current = combined:sub(index, index);
					if current == quote then
						index = index + 1;
						break;
					end;
					buffer[(#buffer) + 1] = current;
					index = index + 1;
				end;
				tokens[(#tokens) + 1] = Concat(buffer);
			else
				const start = index;
				while index <= length and (not (combined:sub(index, index)):match("%s")) do
					index = index + 1;
				end;
				tokens[(#tokens) + 1] = combined:sub(start, index - 1);
			end;
		end;
		if #tokens == 0 then
			for _, value in rawArgs do
				if type(value) == "string" and value ~= "" then
					tokens[(#tokens) + 1] = value;
				end;
			end;
		end;
		for i = 1, #tokens do
			tokens[i] = gotoNext.trim(tokens[i]);
		end;
		return tokens;
	end;
	function gotoNext.buildSearchNames(rawPrefix, normalizedPrefix, index)
		const variants = {};
		const seen = {};
		const function add(name)
			if not name or name == "" then
				return;
			end;
			const canonical = name:lower();
			if not seen[canonical] then
				variants[(#variants) + 1] = name;
				seen[canonical] = true;
			end;
		end;
		const idx = tostring(index);
		add(idx);
		const normalized = normalizedPrefix and gotoNext.trim(normalizedPrefix) or nil;
		if normalized and normalized ~= "" then
			add(normalized .. " " .. idx);
			add(normalized .. idx);
		end;
		if rawPrefix and rawPrefix ~= "" then
			if not rawPrefix:match("%s$") then
				add(rawPrefix .. " " .. idx);
			end;
			add(rawPrefix .. idx);
		end;
		return variants;
	end;
	function gotoNext.extractIndexedToken(token)
		if type(token) ~= "string" then
			return nil;
		end;
		if token == "" then
			return nil;
		end;
		local head, digits = token:match("^(.-)(%-?%d+)%s*$");
		if not digits then
			return nil;
		end;
		local rawPrefix = head;
		local normalized = gotoNext.trim(rawPrefix or "");
		if normalized == "" then
			normalized = nil;
			rawPrefix = nil;
		end;
		return {
			raw = rawPrefix,
			normalized = normalized,
			number = tonumber(digits)
		};
	end;
	function gotoNext.sessionKey(objectType, normalizedLower, index)
		local keyPrefix = gotoNext.trim(normalizedLower or "");
		if keyPrefix ~= "" then
			keyPrefix = keyPrefix:lower();
		end;
		return (objectType or "Part") .. "|" .. keyPrefix .. "|" .. tostring(index);
	end;
	function gotoNext.notify(message, duration)
		DoNotif(message, duration or 3, "GotoNext");
	end;
	function gotoNext.clearTracer()
		if state.tracerConnection then
			state.tracerConnection:Disconnect();
			state.tracerConnection = nil;
		end;
		NAlib.disconnect("gotonext_tracer");
		if state.tracerPart and state.tracerPart.Parent then
			state.tracerPart:Destroy();
		end;
		state.tracerPart = nil;
	end;
	function gotoNext.setTracer(nextCFrame)
		gotoNext.clearTracer();
		if not nextCFrame then
			return;
		end;
		const tracer = InstanceNew("Part", Services.Workspace);
		tracer.Name = NAmanage.GetSessionInstanceName("GotoNextTracer");
		tracer.Anchored = true;
		tracer.CanCollide = false;
		tracer.Material = Enum.Material.Neon;
		tracer.Size = Vector3.new(2, 2, 2);
		tracer.CFrame = nextCFrame + Vector3.new(0, 3, 0);
		tracer.TopSurface = Enum.SurfaceType.Smooth;
		tracer.BottomSurface = Enum.SurfaceType.Smooth;
		state.tracerPart = tracer;
		state.tracerHue = 0;
		state.tracerConnection = NAlib.reconnect("gotonext_tracer", Services.RunService.Heartbeat:Connect(function(dt)
			if not state.tracerPart or (not state.tracerPart.Parent) then
				gotoNext.clearTracer();
				return;
			end;
			state.tracerHue = (state.tracerHue + dt * 0.5) % 1;
			state.tracerPart.Color = Color3.fromHSV(state.tracerHue, 1, 1);
		end));
	end;
	function gotoNext.fullPath(inst)
		if not inst then
			return "Unknown";
		end;
		const segments = {
			inst.Name
		};
		local parent = inst.Parent;
		while parent do
			Insert(segments, 1, parent.Name);
			parent = parent.Parent;
		end;
		return Concat(segments, ".");
	end;
	function gotoNext.isTypeMatch(objectType, inst)
		if objectType == "Part" then
			return inst:IsA("BasePart");
		elseif objectType == "Model" then
			return inst:IsA("Model");
		elseif objectType == "Folder" then
			return inst:IsA("Folder");
		end;
		return false;
	end;
	function gotoNext.buildNameIndex(objectType)
		const nameIndex = {};
		const queue = {
			Services.Workspace
		};
		local index = 1;
		while queue[index] do
			const current = queue[index];
			index += 1;
			for _, child in current:GetChildren() do
				if gotoNext.isTypeMatch(objectType, child) and child.Name and child.Name ~= "" then
					const lowered = child.Name:lower();
					local bucket = nameIndex[lowered];
					if not bucket then
						bucket = {};
						nameIndex[lowered] = bucket;
					end;
					Insert(bucket, {
						inst = child,
						parent = child.Parent
					});
				end;
				queue[(#queue) + 1] = child;
			end;
		end;
		return nameIndex;
	end;
	function gotoNext.findMatches(objectType, targetName, nameIndex)
		const matches = {};
		if not targetName or targetName == "" then
			return matches;
		end;
		const targetLower = targetName:lower();
		if type(nameIndex) == "table" then
			const bucket = nameIndex[targetLower];
			if not bucket then
				return matches;
			end;
			for _, info in bucket do
				const inst = info.inst;
				if inst and inst.Parent then
					Insert(matches, {
						inst = inst,
						parent = inst.Parent
					});
				end;
			end;
			return matches;
		end;
		const queue = {
			Services.Workspace
		};
		local index = 1;
		while queue[index] do
			const current = queue[index];
			index += 1;
			for _, child in current:GetChildren() do
				const isValid = gotoNext.isTypeMatch(objectType, child);
				if isValid and child.Name and child.Name:lower() == targetLower then
					Insert(matches, {
						inst = child,
						parent = child.Parent
					});
				end;
				queue[(#queue) + 1] = child;
			end;
		end;
		return matches;
	end;
	function gotoNext.resolveCFrame(inst)
		if not inst then
			return nil;
		end;
		if inst:IsA("BasePart") then
			return inst.CFrame;
		elseif inst:IsA("Model") then
			local ok, pivot = pcall(function()
				return inst:GetPivot();
			end);
			if ok then
				return pivot;
			end;
			const primary = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart");
			if primary then
				return primary.CFrame;
			end;
		end;
		return nil;
	end;
	function gotoNext.teleportToInstance(inst)
		const char = getChar();
		if not char then
			return false;
		end;
		const targetCFrame = gotoNext.resolveCFrame(inst);
		if not targetCFrame then
			return false;
		end;
		const hum = getHum(char);
		if hum then
			hum.Sit = false;
		end;
		pcall(function()
			NAmanage.UG_pivotModel(char, targetCFrame + Vector3.new(0, 4, 0));
		end);
		return true;
	end;
	function gotoNext.collectFolderParts(folder)
		const parts = {};
		for _, descendant in NAmanage.QueryDescendants(folder, "BasePart") do
			Insert(parts, descendant);
		end;
		table.sort(parts, function(a, b)
			return a:GetFullName() < b:GetFullName();
		end);
		return parts;
	end;
	function gotoNext.normalizeSelection(selection)
		const normalized = {};
		for _, inst in selection or {} do
			if inst and inst.Parent then
				Insert(normalized, {
					inst = inst,
					parent = inst.Parent
				});
			end;
		end;
		return normalized;
	end;
	function gotoNext.promptDuplicates(name, duplicates)
		const selectionEvent = InstanceNew("BindableEvent");
		local selected;
		local resolved = false;
		local window;
		const descriptionLines = {
			Format("Found %d duplicates for '%s'. Choose a starting instance or TP all.", #duplicates, name)
		};
		for idx, info in duplicates do
			Insert(descriptionLines, Format("%d) %s", idx, gotoNext.fullPath(info.inst)));
		end;
		const buttons = {};
		const function finalize(choice)
			if resolved then
				return;
			end;
			selected = choice;
			resolved = true;
			if window and window.Parent then
				window:Destroy();
			end;
			selectionEvent:Fire();
		end;
		for idx, info in duplicates do
			Insert(buttons, {
				Text = Format("Start #%d", idx),
				Callback = function()
					finalize({
						info.inst
					});
				end
			});
		end;
		Insert(buttons, {
			Text = Format("TP All (%d)", #duplicates),
			Callback = function()
				const all = {};
				for _, entry in duplicates do
					Insert(all, entry.inst);
				end;
				finalize(all);
			end
		});
		Insert(buttons, {
			Text = "Cancel",
			Callback = function()
				finalize(nil);
			end
		});
		window = Window({
			Title = "GotoNext",
			Description = Concat(descriptionLines, "\n"),
			Buttons = buttons
		});
		if window then
			window.AncestryChanged:Connect(function(_, parent)
				if not parent and (not resolved) then
					resolved = true;
					selected = nil;
					selectionEvent:Fire();
				end;
			end);
		end;
		selectionEvent.Event:Wait();
		selectionEvent:Destroy();
		return selected;
	end;
	function gotoNext.parseArgs(rawArgs)
		const tokens = gotoNext.tokenizeArgs(rawArgs);
		const args = {};
		for _, value in tokens do
			if type(value) == "string" and value ~= "" then
				Insert(args, value);
			end;
		end;
		const first = args[1];
		if not first then
			return nil, "Usage:\n- gotopartnext <start> [end] [delay]\n- gotopartnext <prefix> <start> [end] [delay]";
		end;
		local prefixRaw;
		local prefixNormalized;
		local startNum;
		local endNum;
		local delay;
		const function applyPrefix(rawCandidate, normalizedCandidate)
			if rawCandidate and rawCandidate ~= "" then
				if not prefixRaw then
					prefixRaw = rawCandidate;
				end;
			end;
			if normalizedCandidate and normalizedCandidate ~= "" then
				normalizedCandidate = gotoNext.trim(normalizedCandidate);
				if normalizedCandidate == "" then
					normalizedCandidate = nil;
				end;
			else
				normalizedCandidate = nil;
			end;
			if normalizedCandidate then
				if prefixNormalized and prefixNormalized ~= normalizedCandidate then
					return false;
				end;
				prefixNormalized = prefixNormalized or normalizedCandidate;
			end;
			if not prefixRaw and prefixNormalized then
				prefixRaw = prefixNormalized;
			end;
			return true;
		end;
		const second = args[2];
		const third = args[3];
		const fourth = args[4];
		const firstNumeric = tonumber(first);
		const firstInfo = gotoNext.extractIndexedToken(first);
		const secondNumeric = tonumber(second);
		const secondInfo = gotoNext.extractIndexedToken(second);
		const thirdNumeric = tonumber(third);
		const thirdInfo = gotoNext.extractIndexedToken(third);
		if firstNumeric then
			startNum = math.floor(firstNumeric);
			if secondNumeric then
				endNum = math.floor(secondNumeric);
				delay = tonumber(third);
			elseif secondInfo and secondInfo.number then
				if not applyPrefix(secondInfo.raw, secondInfo.normalized) then
					return nil, "Start/end names use different prefixes.";
				end;
				endNum = math.floor(secondInfo.number);
				delay = tonumber(third);
			else
				endNum = startNum;
				delay = tonumber(second);
			end;
		elseif firstInfo and firstInfo.number then
			if not applyPrefix(firstInfo.raw, firstInfo.normalized) then
				return nil, "Start/end names use different prefixes.";
			end;
			startNum = math.floor(firstInfo.number);
			if secondNumeric then
				endNum = math.floor(secondNumeric);
				delay = tonumber(third);
			elseif secondInfo and secondInfo.number then
				if not applyPrefix(secondInfo.raw, secondInfo.normalized) then
					return nil, "Start/end names use different prefixes.";
				end;
				endNum = math.floor(secondInfo.number);
				delay = tonumber(third);
			else
				endNum = startNum;
				delay = tonumber(second);
			end;
		else
			if not applyPrefix(first, first) then
				return nil, "Invalid prefix value.";
			end;
			if not second then
				return nil, "Start number missing. Example: gotopartnext checkpoint 1 5";
			end;
			if secondNumeric then
				startNum = math.floor(secondNumeric);
				if thirdNumeric then
					endNum = math.floor(thirdNumeric);
					delay = tonumber(fourth);
				elseif thirdInfo and thirdInfo.number then
					if not applyPrefix(thirdInfo.raw, thirdInfo.normalized) then
						return nil, "Start/end names use different prefixes.";
					end;
					endNum = math.floor(thirdInfo.number);
					delay = tonumber(fourth);
				else
					endNum = startNum;
					delay = tonumber(third);
				end;
			elseif secondInfo and secondInfo.number then
				if not applyPrefix(secondInfo.raw, secondInfo.normalized) then
					return nil, "Start/end names use different prefixes.";
				end;
				startNum = math.floor(secondInfo.number);
				if thirdNumeric then
					endNum = math.floor(thirdNumeric);
					delay = tonumber(fourth);
				elseif thirdInfo and thirdInfo.number then
					if not applyPrefix(thirdInfo.raw, thirdInfo.normalized) then
						return nil, "Start/end names use different prefixes.";
					end;
					endNum = math.floor(thirdInfo.number);
					delay = tonumber(fourth);
				else
					endNum = startNum;
					delay = tonumber(third);
				end;
			else
				return nil, "Start number missing. Example: gotopartnext checkpoint 1 10 0.5";
			end;
		end;
		if not startNum then
			return nil, "Start number missing. Example: gotopartnext checkpoint 1 10 0.5";
		end;
		endNum = endNum or startNum;
		delay = tonumber(delay) or 0.5;
		if delay < 0 then
			delay = 0;
		end;
		local prefixRawOriginal = prefixRaw;
		if prefixRawOriginal then
			const trimmedCandidate = gotoNext.trim(prefixRawOriginal);
			if trimmedCandidate == "" then
				prefixRawOriginal = nil;
			end;
		end;
		if prefixNormalized then
			prefixNormalized = gotoNext.trim(prefixNormalized);
			if prefixNormalized == "" then
				prefixNormalized = nil;
			end;
		end;
		if not prefixNormalized and prefixRawOriginal then
			const trimmedRaw = gotoNext.trim(prefixRawOriginal);
			if trimmedRaw ~= "" then
				prefixNormalized = trimmedRaw;
			end;
		end;
		local prefixDisplay = nil;
		if prefixRawOriginal then
			prefixDisplay = gotoNext.trim(prefixRawOriginal);
			if prefixDisplay == "" then
				prefixDisplay = nil;
			end;
		end;
		if not prefixDisplay then
			prefixDisplay = prefixNormalized;
		end;
		const prefixLower = prefixNormalized and prefixNormalized:lower() or nil;
		return {
			prefixRaw = prefixRawOriginal,
			prefixNormalized = prefixNormalized,
			prefixLower = prefixLower,
			prefixDisplay = prefixDisplay,
			startNum = startNum,
			endNum = endNum,
			delay = delay
		};
	end;
	function gotoNext.handleSequence(objectType, rawArgs)
		if state.teleporting then
			gotoNext.notify("Sequence already running.", 2);
			return;
		end;
		local parsed, err = gotoNext.parseArgs(rawArgs);
		if not parsed then
			gotoNext.notify(err or "Invalid arguments.", 4);
			return;
		end;
		state.teleporting = true;
		state.totalDuplicates = 0;
		const prefixLabel = parsed.prefixDisplay;
		local descriptor;
		if prefixLabel and prefixLabel ~= "" then
			descriptor = Format("Teleporting %s '%s' %d -> %d (delay %.2fs)", objectType, prefixLabel, parsed.startNum, parsed.endNum, parsed.delay);
		else
			descriptor = Format("Teleporting %s %d -> %d (delay %.2fs)", objectType, parsed.startNum, parsed.endNum, parsed.delay);
		end;
		gotoNext.notify(descriptor, 3);
		SpawnCall(function()
			const nameIndex = gotoNext.buildNameIndex(objectType);
			const step = parsed.startNum <= parsed.endNum and 1 or (-1);
			for index = parsed.startNum, parsed.endNum, step do
				if not state.teleporting then
					break;
				end;
				local searchNames = gotoNext.buildSearchNames(parsed.prefixRaw, parsed.prefixNormalized, index);
				if #searchNames == 0 then
					searchNames = {
						tostring(index)
					};
				end;
				const indexString = tostring(index);
				local displayName = searchNames[1];
				for _, candidateName in searchNames do
					if candidateName:find(" " .. indexString, 1, true) then
						displayName = candidateName;
						break;
					end;
				end;
				if parsed.prefixDisplay and parsed.prefixDisplay ~= "" then
					const prefixLowerForDisplay = parsed.prefixDisplay:lower();
					for _, candidateName in searchNames do
						const candidateLower = candidateName:lower();
						if candidateLower:find(prefixLowerForDisplay, 1, true) then
							displayName = candidateName;
							if candidateName:find(" " .. indexString, 1, true) then
								break;
							end;
						end;
					end;
				end;
				const sessionKey = gotoNext.sessionKey(objectType, parsed.prefixLower, index);
				local candidates = {};
				const seen = {};
				for _, name in searchNames do
					const found = gotoNext.findMatches(objectType, name, nameIndex);
					for _, info in found do
						const inst = info.inst;
						if inst and (not seen[inst]) then
							seen[inst] = true;
							Insert(candidates, info);
						end;
					end;
				end;
				if #candidates == 0 then
					gotoNext.notify(Format("No %s named '%s'.", objectType, displayName), 2);
				else
					if #candidates > 1 then
						local sessionChoice = state.duplicatesSessionOrder[sessionKey];
						if sessionChoice then
							sessionChoice = gotoNext.normalizeSelection(sessionChoice);
							if #sessionChoice == 0 then
								state.duplicatesSessionOrder[sessionKey] = nil;
								sessionChoice = nil;
							end;
						end;
						if not sessionChoice then
							const selection = gotoNext.promptDuplicates(displayName, candidates);
							if not selection or #selection == 0 then
								gotoNext.notify("Sequence canceled.", 2);
								state.teleporting = false;
								gotoNext.clearTracer();
								return;
							end;
							state.duplicatesSessionOrder[sessionKey] = selection;
							sessionChoice = gotoNext.normalizeSelection(selection);
						end;
						state.totalDuplicates = state.totalDuplicates + math.max(0, ((#sessionChoice) - 1));
						candidates = sessionChoice;
					end;
					for idx, info in candidates do
						if not state.teleporting then
							break;
						end;
						const inst = info.inst;
						if objectType == "Folder" then
							const parts = gotoNext.collectFolderParts(inst);
							for partIndex, part in parts do
								if not state.teleporting then
									break;
								end;
								const nextPart = parts[partIndex + 1];
								gotoNext.setTracer(nextPart and nextPart.CFrame or nil);
								gotoNext.teleportToInstance(part);
								Wait(parsed.delay);
							end;
						else
							const nextInfo = candidates[idx + 1];
							const nextTarget = nextInfo and gotoNext.resolveCFrame(nextInfo.inst) or nil;
							gotoNext.setTracer(nextTarget);
							gotoNext.teleportToInstance(inst);
							Wait(parsed.delay);
						end;
					end;
				end;
			end;
			gotoNext.clearTracer();
			if state.teleporting then
				gotoNext.notify(Format("Finished teleporting! Duplicates: %d", state.totalDuplicates), 4);
			else
				gotoNext.notify("Sequence stopped.", 2);
			end;
			state.teleporting = false;
		end);
	end;
	function gotoNext.cancelSequence()
		state.totalDuplicates = 0;
		state.duplicatesSessionOrder = {};
		if state.teleporting then
			state.teleporting = false;
			gotoNext.clearTracer();
			gotoNext.notify("Teleport sequence stopped!", 3);
		else
			gotoNext.clearTracer();
			gotoNext.notify("No teleport in progress.", 2);
		end;
	end;
end;

cmd.add({"gotopartnext", "gpn"}, {"gotopartnext [prefix] <start> [end] [delay] (gpn)", "Teleport sequentially to parts with optional prefix and duplicate handling."}, function(...)
	originalIO.gotoNext.handleSequence("Part", {...})
end, true)

cmd.add({"gotomodelnext", "gmn"}, {"gotomodelnext [prefix] <start> [end] [delay] (gmn)", "Teleport sequentially to models with optional prefix and duplicate handling."}, function(...)
	originalIO.gotoNext.handleSequence("Model", {...})
end, true)

cmd.add({"gotofoldernext", "gfn"}, {"gotofoldernext [prefix] <start> [end] [delay] (gfn)", "Teleport sequentially through folder contents with optional prefix."}, function(...)
	originalIO.gotoNext.handleSequence("Folder", {...})
end, true)

cmd.add({"gotobreak", "gb"}, {"gotobreak (gb)", "Stop the active goto sequence and clear duplicate selections."}, function()
	originalIO.gotoNext.cancelSequence()
end)

NAmanage.fastWorkspaceMatches=function(className, needle, mode)
	const query = type(needle) == "string" and Lower(needle) or ""
	if query == "" then
		return {}
	end

	const out = {}
	const selector = type(className) == "string" and className ~= "" and className or "Instance"
	for _, inst in Services.Workspace:QueryDescendants(selector) do
		local pass
		if mode == "class" then
			pass = Lower(inst.ClassName) == query
		else
			const instName = Lower(inst.Name)
			if mode == "exact" then
				pass = instName == query
			else
				pass = Find(instName, query, 1, true) ~= nil
			end
		end
		if pass then
			out[#out + 1] = inst
		end
	end
	return out
end

cmd.add({"gotopart", "topart", "toprt"}, {"gotopart {partname}", "Teleports you to each matching part by name once"}, function(...)
	const partName = Concat({...}, " "):lower()
	const commandKey = "gotopart"

	if NAStuff.activeTeleports[commandKey] then
		NAStuff.activeTeleports[commandKey].active = false
	end

	const taskState = {active = true}
	NAStuff.activeTeleports[commandKey] = taskState

	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		for _, part in NAmanage.fastWorkspaceMatches("BasePart", partName, "exact") do
			if not taskState.active then return end
			if part.Name:lower() == partName then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then NAmanage.UG_pivotModel(getChar(), part:GetPivot()) end
				Wait(partDelay)
			end
		end
	end)
end, true)

cmd.add({"tweengotopart","tgotopart","ttopart","ttoprt"},{"tweengotopart <partName>","Tween to each matching part by name once"},function(...)
	const partName = Concat({...}," "):lower()
	const key      = "tweengotopart"
	if NAStuff.activeTeleports[key] then NAStuff.activeTeleports[key].active = false end
	const state    = {active = true}
	NAStuff.activeTeleports[key] = state
	const tweenAttrActive = "NATweenGoToPartActive"
	const tweenAttrStart = "NATweenGoToPartStartCF"
	const tweenAttrTarget = "NATweenGoToPartTargetCF"
	const tweenAttrCurrent = "NATweenGoToPartCurrentCF"
	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		for _,obj in NAmanage.fastWorkspaceMatches("BasePart", partName, "exact") do
			if not state.active then return end
			if obj.Name:lower() == partName then
				const hum = getHum()
				if hum then hum.Sit = false end
				const char = getChar()
				if char then
					const duration = NAmanage.resolveTweenDuration()
					const root = getRoot(char)
					const startCF = (root and NAmanage.UG_clientCFrame(root)) or char:GetPivot()
					const targetCF = obj:GetPivot()
					local elapsed = 0
					local done = false
					local hbConn
					NAmanage.SetAttr(char, tweenAttrActive, true)
					NAmanage.SetAttr(char, tweenAttrStart, startCF)
					NAmanage.SetAttr(char, tweenAttrTarget, targetCF)
					hbConn = Services.RunService.Heartbeat:Connect(function(dt)
						if not state.active or not char.Parent then
							NAmanage.SetAttr(char, tweenAttrCurrent, nil)
							NAmanage.SetAttr(char, tweenAttrActive, false)
							done = true
							if hbConn then
								hbConn:Disconnect()
								hbConn = nil
							end
							return
						end
						elapsed += dt
						const alpha = duration <= 0 and 1 or math.clamp(elapsed / duration, 0, 1)
						const currentCF = startCF:Lerp(targetCF, alpha)
						NAmanage.SetAttr(char, tweenAttrCurrent, currentCF)
						NAmanage.UG_pivotModel(char, currentCF)
						if alpha >= 1 then
							NAmanage.SetAttr(char, tweenAttrCurrent, nil)
							NAmanage.SetAttr(char, tweenAttrActive, false)
							done = true
							if hbConn then
								hbConn:Disconnect()
								hbConn = nil
							end
						end
					end)
					while state.active and not done do
						Wait()
					end
					Wait(partDelay)
				end
			end
		end
	end)
end,true)


cmd.add({"gotopartfind", "topartfind", "toprtfind"}, {"gotopartfind {name}", "Teleports to each part containing name once"}, function(...)
	const name = Concat({...}, " "):lower()
	const commandKey = "gotopartfind"

	if NAStuff.activeTeleports[commandKey] then
		NAStuff.activeTeleports[commandKey].active = false
	end

	const taskState = {active = true}
	NAStuff.activeTeleports[commandKey] = taskState

	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		for _, part in NAmanage.fastWorkspaceMatches("BasePart", name, "contains") do
			if not taskState.active then return end
			if part.Name:lower():find(name) then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then NAmanage.UG_pivotModel(getChar(), part:GetPivot()) end
				Wait(partDelay)
			end
		end
	end)
end, true)

cmd.add({"tweengotopartfind", "tgotopartfind", "ttopartfind", "ttoprtfind"}, {"tweengotopartfind {name}", "Tweens to each part containing name once"}, function(...)
	const name = Concat({...}, " "):lower()
	const commandKey = "tweengotopartfind"

	if NAStuff.activeTeleports[commandKey] then
		NAStuff.activeTeleports[commandKey].active = false
	end

	const taskState = {active = true}
	NAStuff.activeTeleports[commandKey] = taskState

	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		for _, part in NAmanage.fastWorkspaceMatches("BasePart", name, "contains") do
			if not taskState.active then return end
			if part.Name:lower():find(name) then
				const hum = getHum()
				if hum then
					hum.Sit = false
					Wait(0.1)
				end
				const char = getChar()
				const root = char and getRoot(char)
				if root then
					const duration = NAmanage.resolveTweenDuration()
					const startCF = NAmanage.UG_clientCFrame(root) or root.CFrame
					const targetCF = part.CFrame
					const t0 = os.clock()
					repeat
						const alpha = duration <= 0 and 1 or math.clamp((os.clock() - t0) / duration, 0, 1)
						NAmanage.UG_pivotModel(char, startCF:Lerp(targetCF, alpha))
						Wait()
					until alpha >= 1 or not taskState.active
					Wait(partDelay)
				end
			end
		end
	end)
end, true)

cmd.add({"gotopartclass", "gpc", "gotopartc", "gotoprtc"}, {"gotopartclass {classname}", "Teleports to each part of class once"}, function(...)
	const className = ({...})[1]:lower()
	const commandKey = "gotopartclass"

	if NAStuff.activeTeleports[commandKey] then
		NAStuff.activeTeleports[commandKey].active = false
	end

	const taskState = {active = true}
	NAStuff.activeTeleports[commandKey] = taskState

	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		for _, part in NAmanage.fastWorkspaceMatches("BasePart", className, "class") do
			if not taskState.active then return end
			if part.ClassName:lower() == className then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then NAmanage.UG_pivotModel(getChar(), part:GetPivot()) end
				Wait(partDelay)
			end
		end
	end)
end, true)

cmd.add({"bringpart", "bpart", "bprt"}, {"bringpart {partname} [distance] (bpart, bprt)", "Brings a part to your character by name"}, function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 0)
	const partName = Concat(args, " "):lower()
	if partName == "" then return end
	const char = getChar()
	if not char then return end
	const root = getRoot(char)
	const pivot = NAmanage.bringOffsetCFrame((root and root.CFrame) or char:GetPivot(), distance)
	if not pivot then return end

	for _, part in NAmanage.fastWorkspaceMatches("BasePart", partName, "exact") do
		if part.Name:lower() == partName then
			part:PivotTo(pivot)
		end
	end
end, true)

cmd.add({"bringpartfind","bpartfind","bprtfind"},{"bringpartfind {name} [distance] (bpartfind, bprtfind)","Brings all parts containing name to your character"},function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 0)
	const name = Concat(args," "):lower()
	if name == "" then return end

	const char = getChar()
	if not char then return end
	const root = getRoot(char)
	const pivot = NAmanage.bringOffsetCFrame((root and root.CFrame) or char:GetPivot(), distance)
	if not pivot then return end

	for _, part in NAmanage.fastWorkspaceMatches("BasePart", name, "contains") do
		const n = part.Name:lower()
		if Find(n, name, 1, true) ~= nil then
			part:PivotTo(pivot)
		end
	end
end,true)

cmd.add({"bringmodel", "bmodel"}, {"bringmodel {modelname} [distance] (bmodel)", "Brings a model to your character by name"}, function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 0)
	const modelName = Concat(args, " "):lower()
	if modelName == "" then return end
	const char = getChar()
	if not char then return end
	const root = getRoot(char)
	const pivot = NAmanage.bringOffsetCFrame((root and root.CFrame) or char:GetPivot(), distance)
	if not pivot then return end

	for _, model in NAmanage.fastWorkspaceMatches("Model", modelName, "exact") do
		if model.Name:lower() == modelName then
			model:PivotTo(pivot)
		end
	end
end, true)

cmd.add({"bringmodelfind","bmodelfind"},{"bringmodelfind {name} [distance] (bmodelfind)","Brings all models whose name contains the given text to your character"},function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 0)
	const name = Concat(args," "):lower()
	if name == "" then return end

	const char = getChar()
	if not char then return end
	const root = getRoot(char)
	const pivot = NAmanage.bringOffsetCFrame((root and root.CFrame) or char:GetPivot(), distance)
	if not pivot then return end

	for _, model in NAmanage.fastWorkspaceMatches("Model", name, "contains") do
		const n = model.Name:lower()
		if Find(n, name, 1, true) ~= nil then
			model:PivotTo(pivot)
		end
	end
end,true)

cmd.add({"bringfolder","bfldr"},{"bringfolder {folderName} [partName] [distance] (bfldr)","Brings all parts in a folder or a specified part"},function(...)
	const raw = {...}
	const distance = NAmanage.parseBringDistance(raw, 0)
	if #raw == 0 then return end
	const lower = {}
	for i=1,#raw do lower[i] = tostring(raw[i]):lower() end
	local folder, partFilter
	do
		const nameAll = Concat(lower," ")
		for _,obj in NAmanage.fastWorkspaceMatches("Folder", nameAll, "exact") do
			if obj.Name:lower() == nameAll then folder = obj break end
		end
		if not folder and #lower>=2 then
			const nameWithoutLast = Concat(lower," ",1,#lower-1)
			const last = lower[#lower]
			for _,obj in NAmanage.fastWorkspaceMatches("Folder", nameWithoutLast, "exact") do
				if obj.Name:lower() == nameWithoutLast then folder = obj partFilter = last break end
			end
		end
		if not folder then
			for _,obj in NAmanage.fastWorkspaceMatches("Folder", lower[1], "exact") do
				if obj.Name:lower() == lower[1] then folder = obj break end
			end
			if folder and #lower>1 then
				partFilter = Concat(lower," ",2,#lower)
			end
		end
	end
	if not folder then return end
	const char = getChar()
	if not char then return end
	const root = getRoot(char)
	const pivot = NAmanage.bringOffsetCFrame((root and root.CFrame) or char:GetPivot(), distance)
	if not pivot then return end
	for _,desc in NAmanage.QueryDescendants(folder, "BasePart") do
		local ok = true
		if partFilter and partFilter ~= "" then
			const n = desc.Name:lower()
			ok = (n == partFilter) or (Find(n, partFilter, 1, true) ~= nil)
		end
		if ok then
			desc:PivotTo(pivot)
		end
	end
end,true)

cmd.add({"gotomodel", "tomodel"}, {"gotomodel {modelname}", "Teleports to each model with name once"}, function(...)
	const modelName = Concat({...}, " "):lower()
	const commandKey = "gotomodel"

	if NAStuff.activeTeleports[commandKey] then
		NAStuff.activeTeleports[commandKey].active = false
	end

	const taskState = {active = true}
	NAStuff.activeTeleports[commandKey] = taskState

	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		for _, model in NAmanage.fastWorkspaceMatches("Model", modelName, "exact") do
			if not taskState.active then return end
			if model.Name:lower() == modelName then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then NAmanage.UG_pivotModel(getChar(), model:GetPivot()) end
				Wait(partDelay)
			end
		end
	end)
end, true)

cmd.add({"gotomodelfind", "tomodelfind"}, {"gotomodelfind {name}", "Teleports to each model containing name once"}, function(...)
	const name = Concat({...}, " "):lower()
	const commandKey = "gotomodelfind"

	if NAStuff.activeTeleports[commandKey] then
		NAStuff.activeTeleports[commandKey].active = false
	end

	const taskState = {active = true}
	NAStuff.activeTeleports[commandKey] = taskState

	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		for _, model in NAmanage.fastWorkspaceMatches("Model", name, "contains") do
			if not taskState.active then return end
			if model.Name:lower():find(name) then
				if getHum() then getHum().Sit = false Wait(0.1) end
				if getChar() then NAmanage.UG_pivotModel(getChar(), model:GetPivot()) end
				Wait(partDelay)
			end
		end
	end)
end, true)

cmd.add({"gotomodelfind", "tomodelfind"}, {"gotomodelfind {name} (tomodelfind)", "Teleports you to a model whose name contains the given text"}, function(...)
	const name = Concat({...}, " "):lower()
	const partDelay = NAmanage.tpDelay()

	for _, model in NAmanage.fastWorkspaceMatches("Model", name, "contains") do
		if model.Name:lower():find(name) then
			if getHum() then
				getHum().Sit = false
				Wait(0.1)
			end
			if getChar() then
				NAmanage.UG_pivotModel(getChar(), model:GetPivot())
			end
			Wait(partDelay)
		end
	end
end, true)

cmd.add({"gotofolder","gofldr"},{"gotofolder {folderName}","Teleports you to all parts in a folder"},function(...)
	const lower = {}
	for i,v in {...} do lower[i] = tostring(v):lower() end
	const folderName = Concat(lower," ")
	if folderName == "" then return end
	const key = "gotofolder"
	if NAStuff.activeTeleports[key] then NAStuff.activeTeleports[key].active = false end
	const state = {active = true}
	NAStuff.activeTeleports[key] = state
	SpawnCall(function()
		const partDelay = NAmanage.tpDelay()
		local folder
		for _,obj in NAmanage.fastWorkspaceMatches("Folder", folderName, "exact") do
			if obj.Name:lower() == folderName then folder = obj break end
		end
		if not folder then return end
		for _,desc in NAmanage.QueryDescendants(folder, "BasePart") do
			if not state.active then return end
			const hum = getHum()
			if hum then hum.Sit = false Wait(0.1) end
			const char = getChar()
			if char then NAmanage.UG_pivotModel(char, desc:GetPivot()) end
			Wait(partDelay)
		end
	end)
end,true)

OGGRAVV = Services.Workspace.Gravity;
SWIMMERRRR = false;

NAStuff.SWIM_STATES = NAStuff.SWIM_STATES or {
	Enum.HumanoidStateType.FallingDown,
	Enum.HumanoidStateType.Freefall,
	Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.PlatformStanding,
	Enum.HumanoidStateType.Ragdoll,
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Seated
};

function ZEhumSTATE(humanoid, enabled)
	for _, st in NAStuff.SWIM_STATES do
		humanoid:SetStateEnabled(st, enabled);
	end;
end;

cmd.add({"swim"}, {"swim {speed}","Swim in the air"}, function(speed)
	const humanoid = getHum();
	if not humanoid or (not humanoid.Parent) or SWIMMERRRR then
		return;
	end;
	const hrp = getRoot(humanoid.Parent);
	if not hrp then
		return;
	end;
	const spd = tonumber(speed) or 16;
	OGGRAVV = Services.Workspace.Gravity;
	Services.Workspace.Gravity = 0;
	ZEhumSTATE(humanoid, false);
	humanoid:ChangeState(Enum.HumanoidStateType.Swimming);
	humanoid.WalkSpeed = spd;
	NAlib.connect("swim_die", NAmanage.ConnectHumanoidDeath(humanoid, function()
		Services.Workspace.Gravity = OGGRAVV;
		SWIMMERRRR = false;
		NAlib.disconnect("swim_heartbeat");
		ZEhumSTATE(humanoid, true);
	end));
	NAlib.connect("swim_heartbeat", Services.RunService.RenderStepped:Connect(function()
		NACaller(function()
			if not SWIMMERRRR then
				return;
			end;
			if not humanoid or (not humanoid.Parent) or (not hrp) then
				return;
			end;
			const move = humanoid.MoveDirection;
			local v = Vector3.zero;
			if move.Magnitude > 0 then
				v = move.Unit * spd;
			end;
			if __lt.cm("UserInputService", "IsKeyDown", Enum.KeyCode.Space) then
				v = v + Vector3.new(0, spd, 0);
			end;
			if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
				v = v + Vector3.new(0, spd, 0);
				humanoid:ChangeState(Enum.HumanoidStateType.Swimming);
			end;
			hrp.Velocity = v;
		end);
	end));
	SWIMMERRRR = true;
end, true);

cmd.add({"unswim"}, {"unswim","Stops the swim script"}, function()
	const humanoid = getHum();
	if not humanoid then
		return;
	end;
	Services.Workspace.Gravity = OGGRAVV;
	SWIMMERRRR = false;
	NAlib.disconnect("swim_die");
	NAlib.disconnect("swim_heartbeat");
	ZEhumSTATE(humanoid, true);
	humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics);
	humanoid.WalkSpeed = 16;
	const hrp = getRoot(humanoid.Parent);
	if hrp then
		hrp.Velocity = Vector3.zero;
	end;
end);

cmd.add({"punch"},{"punch","punch tool that flings"},function()
	NAmanage.RunURL('https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/puncher.luau')
end)

cmd.add({"tpua","bringua"},{"tpua <player|npc:filter>","Brings every unanchored part on the map to a player or NPC"},function(...)
	const targets=getPlr(NAmanage.PlayerQueryFromArgs(...))
	local targetPlayer=targets[1]
	if not targetPlayer then targetPlayer=LocalPlayer end

	const targetChar=getPlrChar(targetPlayer)
	const root=getRoot(targetChar)
	if not root then return end

	const targetCF=root.CFrame

	SpawnCall(function()
		while Services.RunService.Heartbeat:Wait() do
			NACaller(function()
				opt.hiddenprop(LocalPlayer,"SimulationRadius",1e9)
				LocalPlayer.MaximumSimulationRadius=1e9
			end)
		end
	end)

	const function ForcePart(v)
		if not v:IsA("BasePart") then return end
		if v.Anchored or v:IsDescendantOf(targetChar) then return end
		if v.Parent:FindFirstChildWhichIsA("Humanoid") or v.Parent:FindFirstChild("Head") or v.Name=="Handle" then return end

		for _,x in next,v:GetChildren() do
			if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
		end
		for _,n in next,{"Attachment","AlignPosition","Torque"} do
			const i=v:FindFirstChild(n)
			if i then i:Destroy() end
		end

		v.CanCollide=false
		v.CFrame=targetCF*CFrame.new(math.random(-10,10),0,math.random(-10,10))
	end

	for _, part in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do
		ForcePart(part)
	end
end,true)

cmd.add({"blackholefollow","bhf","bhpull","bhfollow"},{"blackholefollow","Pulls unanchored parts to you with spin"},function()
	if NAlib.isConnected("bhf") then return DoNotif("BHF already active") end

	const root=getRoot(getPlrChar(LocalPlayer));if not root then return end
	const att1=InstanceNew("Attachment",root);att1.Name="BHF_Attach"

	const function ForcePart(v)
		if not v:IsA("BasePart") then return end
		if v.Anchored or v:IsDescendantOf(LocalPlayer.Character) then return end
		if v.Parent:FindFirstChildWhichIsA("Humanoid") or v.Parent:FindFirstChild("Head") or v.Name=="Handle" then return end

		for _,x in next,v:GetChildren() do
			if x:IsA("BodyMover") or x:IsA("RocketPropulsion") then x:Destroy() end
		end
		for _,n in next,{"Attachment","AlignPosition","Torque"} do
			const i=v:FindFirstChild(n)
			if i then i:Destroy() end
		end

		v.CanCollide=false

		const att0=InstanceNew("Attachment",v)
		const align=InstanceNew("AlignPosition",v)
		align.Attachment0=att0
		align.Attachment1=att1
		align.MaxForce=1e9
		align.MaxVelocity=math.huge
		align.Responsiveness=200

		const torque=InstanceNew("Torque",v)
		torque.Attachment0=att0
		torque.Torque=Vector3.new(100000,100000,100000)
	end

	for _, part in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do Defer(function() ForcePart(part) end) end

	NAlib.connect("bhf",NAmanage.wsAdd(ForcePart))
	NAlib.connect("bhf_sim",Services.RunService.Heartbeat:Connect(function()
		NACaller(function()
			opt.hiddenprop(LocalPlayer,"SimulationRadius",1e9)
			LocalPlayer.MaximumSimulationRadius=1e9
		end)
	end))

	DebugNotif("Blackhole follow enabled.")
end,true)

cmd.add({"noblackholefollow","nobhf","nobhpull","stopbhf"},{"noblackholefollow","Stops blackhole follow and clears constraints"},function()
	NAlib.disconnect("bhf")
	NAlib.disconnect("bhf_sim")

	const root=getRoot(getPlrChar(LocalPlayer))
	if root then const att=root:FindFirstChild("BHF_Attach") if att then att:Destroy() end end

	for _,part in NAmanage.QueryDescendants(Services.Workspace, "BasePart") do
		if not part.Anchored then
			for _,obj in part:GetChildren() do
				if obj:IsA("AlignPosition") or obj:IsA("Torque") or obj:IsA("Attachment") then obj:Destroy() end
			end
		end
	end

	DebugNotif("Blackhole follow disabled.")
end,true)

cmd.add({"swordfighter", "sfighter", "swordf", "swordbot", "sf"},{"swordfighter (sfighter, swordf, swordbot, sf)", "Activates a sword fighting bot that engages in automated PvP combat"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/Sword%20Fight%20Bot")
end)

NAmanage.CreateBox = function(part, color, transparency, customName)
	if not part or not part.Parent then return end
	local canCreate = true
	if type(NAmanage.PartESP_CanCreateFor) == "function" then
		canCreate = NAmanage.PartESP_CanCreateFor(part)
	end
	if not canCreate then
		NAStuff.partESPSkippedLimit = (tonumber(NAStuff.partESPSkippedLimit) or 0) + 1
		return
	end
	NAmanage.RemoveEspFromPart(part)
	const c = (typeof(color) == "Color3" and color) or Color3.new(1,1,1)
	const displayName = type(customName) == "string" and customName ~= "" and customName or part.Name
	const entryTransparency = NAgui.sanitizeTransparency(transparency or (NAStuff.ESP_PartTransparency or 0.45))
	local h, s, v = Color3.toHSV(c)
	const off = 0.35
	const darker = Color3.fromHSV(h, s, math.clamp(v - off, 0, 1))
	const lighter = Color3.fromHSV(h, s, math.clamp(v + off, 0, 1))
	const mode = NAgui.getESPRenderMode("part")
	const useHighlight = mode == "Highlight"
	local useDrawing = mode == "Drawing API"
	const drawingStyle = NAgui.sanitizeESPDrawingBoxStyle(NAStuff.ESP_DrawingPartBoxStyle)
	local adornTarget = NAgui.getInstanceAdornee(part)
	const adornName = Lower(part.Name).."_peepee"
	local visual
	local drawingSquare
	local drawingCornerLines
	local drawingCornerOutlineLines
	if useDrawing then
		if drawingStyle == "Corners" and NAmanage.DrawingLineSupported() then
			drawingCornerLines = {}
			if NAStuff.ESP_DrawingPartBoxOutline ~= false then
				drawingCornerOutlineLines = {}
			end
			for i = 1, 8 do
				drawingCornerLines[i] = NAmanage.DrawingCreateLine(lighter, 1, NAStuff.ESP_DrawingPartBoxThickness)
				if drawingCornerOutlineLines then
					drawingCornerOutlineLines[i] = NAmanage.DrawingCreateLine(darker, 1, math.clamp(tonumber(NAStuff.ESP_DrawingPartBoxOutlineThickness) or 3, 1, 10))
				end
				if not drawingCornerLines[i] or (drawingCornerOutlineLines and not drawingCornerOutlineLines[i]) then
					useDrawing = false
					break
				end
			end
		else
			drawingSquare = NAmanage.DrawingCreateSquare(lighter, entryTransparency, {
				filled = NAStuff.ESP_DrawingPartFilledBoxes == true;
				thickness = NAStuff.ESP_DrawingPartBoxThickness;
			})
			if not drawingSquare then
				useDrawing = false
			end
		end
		if not useDrawing then
			if type(drawingCornerLines) == "table" then
				for i = 1, #drawingCornerLines do
					NAmanage.DrawingRemoveObject(drawingCornerLines[i])
				end
				drawingCornerLines = nil
			end
			if type(drawingCornerOutlineLines) == "table" then
				for i = 1, #drawingCornerOutlineLines do
					NAmanage.DrawingRemoveObject(drawingCornerOutlineLines[i])
				end
				drawingCornerOutlineLines = nil
			end
		end
	end
	if not useDrawing then
		if useHighlight then
			visual = InstanceNew("Highlight")
			visual.Name = adornName
			visual.Adornee = part
			visual.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			visual.FillColor = lighter
			visual.OutlineColor = darker
			visual.FillTransparency = entryTransparency
			visual.OutlineTransparency = NAgui.sanitizeTransparency(NAStuff.ESP_OutlineTransparency or 0)
			visual.Enabled = true
			NAmanage.ESP_StoreVisual(visual)
		else
			if not adornTarget then
				return
			end
			visual = InstanceNew("BoxHandleAdornment")
			visual.Name = adornName
			visual.Adornee = adornTarget
			visual.AlwaysOnTop = true
			visual.ZIndex = 0
			visual.Transparency = entryTransparency
			visual.Color3 = lighter
			NAmanage.ESP_StoreVisual(visual)
		end
	end
	local bb, tl, gr, drawingLabel = nil, nil, nil, nil
	if useDrawing then
		drawingLabel = NAmanage.DrawingCreateText(displayName, lighter, NAStuff.ESP_LabelTextSize, {
			outlineEnabled = NAStuff.ESP_DrawingPartTextOutline ~= false;
			centered = NAStuff.ESP_DrawingPartTextCentered ~= false;
			font = NAStuff.ESP_DrawingTextFont;
			textTransparency = NAStuff.ESP_DrawingPartTextTransparency;
		})
	end
	if (not useDrawing) or (not drawingLabel) then
		bb = InstanceNew("BillboardGui")
		bb.Name = Lower(part.Name).."_label"
		bb.Adornee = adornTarget
		bb.Size = UDim2.new(0, 160, 0, 28)
		bb.StudsOffset = Vector3.new(0, 0.5, 0)
		bb.AlwaysOnTop = true
		bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		NAmanage.ESP_StoreVisual(bb)
		tl = InstanceNew("TextLabel", bb)
		tl.Size = UDim2.new(1, 0, 1, 0)
		tl.BackgroundTransparency = 1
		tl.Text = displayName
		tl.TextColor3 = Color3.new(1,1,1)
		tl.Font = Enum.Font.SourceSansBold
		tl.TextStrokeTransparency = 0.5
		tl.ZIndex = 1
		NAgui.applyLabelStyle(tl)
		gr = InstanceNew("UIGradient", tl)
		gr.Color = ColorSequence.new(darker, lighter)
		NAmanage.ESP_HardenVisual(bb)
	end
	const function update()
		if not part or not part.Parent then return end
		if bb and not bb.Parent then return end
		adornTarget = NAgui.getInstanceAdornee(part)
		if visual and visual.Parent then
			NAmanage.ESP_StoreVisual(visual)
		end
		if bb and bb.Parent then
			NAmanage.ESP_StoreVisual(bb)
			if adornTarget and bb.Adornee ~= adornTarget then
				bb.Adornee = adornTarget
			end
		end
		local sizeY = 2.5
		if part:IsA("Model") then
			local ok, modelCf, ms = pcall(part.GetBoundingBox, part)
			if ok and ms then
				sizeY = ms.Y
				if (not useHighlight) and (not useDrawing) and visual and visual:IsA("BoxHandleAdornment") and adornTarget then
					if visual.Adornee ~= adornTarget then
						visual.Adornee = adornTarget
					end
					const newSize = ms + Vector3.new(0.1,0.1,0.1)
					if visual.Size ~= newSize then
						visual.Size = newSize
					end
					pcall(function()
						visual.CFrame = adornTarget.CFrame:ToObjectSpace(modelCf)
					end)
				end
				if bb and adornTarget and modelCf then
					const labelWorld = modelCf.Position + Vector3.new(0, (sizeY / 2) + 0.2, 0)
					const offsetWorld = labelWorld - adornTarget.Position
					const offsetLocal = adornTarget.CFrame:PointToObjectSpace(labelWorld)
					const usedWorldOffset = pcall(function()
						bb.StudsOffset = Vector3.new(0, 0, 0)
						bb.StudsOffsetWorldSpace = offsetWorld
					end)
					if not usedWorldOffset then
						bb.StudsOffset = offsetLocal
					end
				end
			end
		elseif part:IsA("BasePart") then
			sizeY = part.Size.Y
			if (not useHighlight) and (not useDrawing) and visual and visual:IsA("BoxHandleAdornment") then
				if visual.Adornee ~= part then
					visual.Adornee = part
				end
				const newSize = part.Size + Vector3.new(0.1,0.1,0.1)
				if visual.Size ~= newSize then
					visual.Size = newSize
				end
				pcall(function()
					visual.CFrame = CFrame.new()
				end)
			end
			if bb and bb.Adornee ~= part then
				bb.Adornee = part
			end
		end
		if bb and not part:IsA("Model") then
			pcall(function()
				bb.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
			end)
			bb.StudsOffset = Vector3.new(0, (sizeY / 2) + 0.2, 0)
		end
	end
	update()
	Defer(update)
	NAmanage._partESPUpdateKeySeq = (tonumber(NAmanage._partESPUpdateKeySeq) or 0) + 1
	const key = "esp_update_"..NAmanage.GetSessionActionName("PartESPUpdate_"..tostring(NAmanage._partESPUpdateKeySeq))
	if part:IsA("Model") then
		NAlib.connect(key, NAmanage.descAdd(part, update))
		NAlib.connect(key, NAmanage.descRem(part, update))
	elseif NAlib.isProperty(part, "Size") then
		NAlib.connect(key, part:GetPropertyChangedSignal("Size"):Connect(update))
	end
	NAlib.connect(key, part.AncestryChanged:Connect(function(_, parentNow)
		if not parentNow then
			NAlib.disconnect(key)
		end
	end))
	const entry = {
		part = part,
		billboard = bb,
		label = tl,
		drawingLabel = drawingLabel,
		visual = visual,
		drawingSquare = drawingSquare,
		drawingCornerLines = drawingCornerLines,
		drawingCornerOutlineLines = drawingCornerOutlineLines,
		baseColor = c,
		lightColor = lighter,
		darkColor = darker,
		transparency = entryTransparency,
		gradient = gr,
		useHighlight = useHighlight,
		useDrawing = useDrawing,
		updateKey = key,
		customName = displayName,
		highlightMaterialTarget = useHighlight and part or nil,
	}
	if useHighlight then
		NAmanage.ESP_AdjustHighlightMaterial(part, true, entry)
	end
	NAmanage.PartESP_RegisterEntry(entry)
	return visual or drawingSquare
end

NAmanage.RemoveEspFromPart = function(part)
	if not part then return end
	NAmanage.PartESP_QueueRemove(part)
	const partMap = NAStuff.partESPPartMap
	const bucket = type(partMap) == "table" and partMap[part] or nil
	const hadBucket = type(bucket) == "table"
	if hadBucket then
		const removeList = {}
		for _, entry in bucket do
			removeList[#removeList + 1] = entry
		end
		for i = 1, #removeList do
			NAmanage.PartESP_UnregisterEntry(removeList[i])
		end
	end
	for _, child in part:GetChildren() do
		if (child:IsA("BoxHandleAdornment") or child:IsA("Highlight")) and Sub(child.Name,-7) == "_peepee" then
			NAlib.disconnect("esp_update_"..tostring(child))
			const entry = NAStuff.partESPVisualMap and NAStuff.partESPVisualMap[child]
			if entry then
				NAmanage.PartESP_UnregisterEntry(entry)
			end
			child:Destroy()
		end
	end
	for _, child in part:GetChildren() do
		if child:IsA("BillboardGui") and Sub(Lower(child.Name),-6) == "_label" then
			const entry = NAStuff.partESPEntries and NAStuff.partESPEntries[child]
			if entry then
				NAmanage.PartESP_UnregisterEntry(entry)
			end
			child:Destroy()
		end
	end
	if (not hadBucket) and NAStuff.partESPEntries then
		const removeList = {}
		for _, entry in NAStuff.partESPEntries do
			if entry and entry.part == part then
				removeList[#removeList + 1] = entry
			end
		end
		for i = 1, #removeList do
			NAmanage.PartESP_UnregisterEntry(removeList[i])
		end
	end
end

NAmanage.GetPartESPColor = function(key, fallbackColor)
	const value = NAStuff and NAStuff[key]
	if typeof(value) == "Color3" then
		return value
	end
	return fallbackColor or Color3.new(1, 1, 1)
end

NAmanage.RecolorPartESPList = function(list, color)
	if type(list) ~= "table" then return end
	const applyColor = (typeof(color) == "Color3") and color or Color3.new(1, 1, 1)
	for _, part in list do
		if part and part.Parent then
			NAmanage.CreateBox(part, applyColor, NAStuff.ESP_PartTransparency or 0.45)
		end
	end
end

NAmanage.RecolorFolderESPEntries = function(color)
	const members = NAStuff and NAStuff.folderESPMembers
	if type(members) ~= "table" then return end
	const applyColor = (typeof(color) == "Color3") and color or Color3.fromRGB(255, 220, 0)
	for _, list in members do
		if type(list) == "table" then
			NAmanage.RecolorPartESPList(list, applyColor)
		end
	end
end

NAmanage.RecolorModelESPEntries = function(color)
	const applyColor = (typeof(color) == "Color3") and color or Color3.fromRGB(0, 200, 255)
	const members = NAStuff and NAStuff.modelESPMembers
	if type(members) == "table" then
		local found = false
		for _, list in members do
			if type(list) == "table" then
				found = true
				NAmanage.RecolorPartESPList(list, applyColor)
			end
		end
		if found then
			return
		end
	end
	const models = NAStuff and NAStuff.modelESPModels
	if type(models) ~= "table" then return end
	NAmanage.RecolorPartESPList(models, applyColor)
end

NAmanage.RecolorNameESPEntries = function(color)
	const applyColor = (typeof(color) == "Color3") and color or Color3.fromRGB(255, 255, 255)
	if NAStuff and NAStuff.nameESPPartLists then
		NAmanage.RecolorPartESPList(NAStuff.nameESPPartLists.exact, applyColor)
		NAmanage.RecolorPartESPList(NAStuff.nameESPPartLists.partial, applyColor)
	end
end

NAmanage.EnableEsp = function(objType, color, list)
	const function currentColor()
		const resolved = (type(color) == "function") and color() or color
		return (typeof(resolved) == "Color3") and resolved or Color3.new(1, 1, 1)
	end
	const setMap = NAmanage.ESP_GetListMap(list)
	const countMap = NAmanage.ESP_GetListCountMap(list)
	const objectMap = NAmanage.ESP_GetListObjectMap(list)
	const trigger = NAStuff.espTriggers[objType]
	const function trackParent(parent)
		if not (parent and setMap and countMap) then
			return
		end
		const nextCount = (tonumber(countMap[parent]) or 0) + 1
		countMap[parent] = nextCount
		if nextCount == 1 and NAmanage.ESP_ListAdd(list, setMap, parent) then
			NAmanage.PartESP_QueueCreate(parent, currentColor(), NAStuff.ESP_PartTransparency or 0.45, function(p)
				return setMap[p] ~= nil
			end)
		end
	end
	const function untrackParent(parent)
		if not (parent and setMap and countMap) then
			return
		end
		const count = tonumber(countMap[parent]) or 0
		if count <= 1 then
			countMap[parent] = nil
			if NAmanage.ESP_ListRemove(list, setMap, parent) then
				NAmanage.RemoveEspFromPart(parent)
			end
			return
		end
		countMap[parent] = count - 1
	end
	if trigger then
		NAmanage.RecolorPartESPList(list, currentColor())
		return
	end
	for _,obj in NAmanage.QueryDescendants(Services.Workspace, objType) do
		const parent = obj:FindFirstAncestorWhichIsA("BasePart") or obj:FindFirstAncestorWhichIsA("Model")
		if parent then
			objectMap[obj] = parent
			trackParent(parent)
		end
	end
	NAStuff.espTriggers[objType] = NAmanage.wsSub({
		added = function(obj)
			if not obj:IsA(objType) then
				return
			end
			const parent = obj:FindFirstAncestorWhichIsA("BasePart") or obj:FindFirstAncestorWhichIsA("Model")
			if parent then
				objectMap[obj] = parent
				trackParent(parent)
			end
		end,
		removing = function(obj)
			if not obj:IsA(objType) then
				return
			end
			local parent = objectMap[obj]
			if not parent then
				parent = obj:FindFirstAncestorWhichIsA("BasePart") or obj:FindFirstAncestorWhichIsA("Model")
			end
			objectMap[obj] = nil
			if parent then
				untrackParent(parent)
			end
		end,
	})
end

NAmanage.DisableEsp = function(objType, list)
	if NAStuff.espTriggers[objType] then
		NAStuff.espTriggers[objType]:Disconnect()
		NAStuff.espTriggers[objType] = nil
	end
	for _,part in list do
		NAmanage.RemoveEspFromPart(part)
	end
	table.clear(list)
	const setMap = NAmanage.ESP_GetListMap(list)
	if type(setMap) == "table" then
		table.clear(setMap)
	end
	const countMap = NAmanage.ESP_GetListCountMap(list)
	if type(countMap) == "table" then
		table.clear(countMap)
	end
	const objectMap = NAmanage.ESP_GetListObjectMap(list)
	if type(objectMap) == "table" then
		table.clear(objectMap)
	end
end

NAmanage.NameESP_SelfMatches = function(obj, mode)
	if typeof(obj) ~= "Instance" then
		return false
	end

	const lists = NAStuff and NAStuff.espNameLists
	const list = lists and lists[mode]
	if type(list) ~= "table" or #list == 0 then
		return false
	end

	const nm = Lower(obj.Name)
	const ex = NAStuff.nameESPExclusions and NAStuff.nameESPExclusions[mode]
	if ex and ex[nm] then
		return false
	end

	for _, term in list do
		if (mode == "exact" and nm == term) or (mode == "partial" and Find(nm, term)) then
			return true
		end
	end

	return false
end

NAmanage.NameESP_MatchedModelForPart = function(part, mode)
	const RawWorkspace = __lt.gs("Workspace")
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return nil
	end

	local obj = part.Parent
	while obj do
		if obj:IsA("Model") and NAmanage.NameESP_SelfMatches(obj, mode) then
			return obj
		end
		if obj == RawWorkspace then
			break
		end
		obj = obj.Parent
	end

	return nil
end

NAmanage.NameESP_BasePartMatches = function(part, mode)
	const RawWorkspace = __lt.gs("Workspace")
	if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
		return false
	end

	if NAmanage.NameESP_MatchedModelForPart(part, mode) then
		return false
	end

	local obj = part
	while obj do
		if obj:IsA("Model") and obj ~= part then
			if NAmanage.NameESP_SelfMatches(obj, mode) then
				return false
			end
		elseif NAmanage.NameESP_SelfMatches(obj, mode) then
			return true
		end
		if obj == RawWorkspace then
			break
		end
		obj = obj.Parent
	end

	return false
end

NAmanage.NameESP_TermMatchesPart = function(term, part, mode)
	const RawWorkspace = __lt.gs("Workspace")
	term = Lower(tostring(term or ""))
	if term == "" or typeof(part) ~= "Instance" then
		return false
	end

	local obj = part
	while obj do
		const nm = Lower(obj.Name)
		if (mode == "exact" and nm == term) or (mode == "partial" and Find(nm, term)) then
			return true
		end
		if obj == RawWorkspace then
			break
		end
		obj = obj.Parent
	end

	return false
end

NAmanage.NameESP_HasActiveMode = function(mode)
	const lists = NAStuff and NAStuff.espNameLists
	const list = type(lists) == "table" and lists[mode]
	return type(list) == "table" and #list > 0
end

NAmanage.NameESP_HasAnyActive = function()
	return NAmanage.NameESP_HasActiveMode("exact") or NAmanage.NameESP_HasActiveMode("partial")
end

NAmanage.NameESP_IsWatchable = function(obj)
	if typeof(obj) ~= "Instance" then
		return false
	end
	if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Tool") then
		return true
	end
	for _, className in { "Accessory", "WorldModel", "Actor" } do
		local ok, result = pcall(function()
			return obj:IsA(className)
		end)
		if ok and result then
			return true
		end
	end
	return false
end

NAmanage.NameESP_DisconnectWatcher = function(obj)
	const watchers = NAStuff and NAStuff.espNameWatchers
	if type(watchers) ~= "table" or obj == nil then
		return
	end
	const rec = watchers[obj]
	watchers[obj] = nil
	if type(rec) == "table" then
		for _, conn in rec do
			pcall(function()
				conn:Disconnect()
			end)
		end
	else
		pcall(function()
			rec:Disconnect()
		end)
	end
	const qMap = NAStuff and NAStuff.espNameWatchQueueMap
	if type(qMap) == "table" then
		qMap[obj] = nil
	end
end

NAmanage.NameESP_QueueCheck = function(obj, reason)
	const RawWorkspace = __lt.gs("Workspace")
	if typeof(obj) ~= "Instance" or obj == RawWorkspace then
		return
	end
	if not obj.Parent then
		return
	end
	if not NAmanage.NameESP_HasAnyActive() then
		return
	end
	local qMap = NAStuff.espNameWatchQueueMap
	if type(qMap) ~= "table" then
		qMap = NAmanage.ensureWeakTable(nil, "k")
		NAStuff.espNameWatchQueueMap = qMap
	end
	local item = qMap[obj]
	if item then
		item.reason = reason or item.reason
		return
	end
	local queue = NAStuff.espNameWatchQueue
	if type(queue) ~= "table" then
		queue = {}
		NAStuff.espNameWatchQueue = queue
		NAStuff.espNameWatchHead = 1
		NAStuff.espNameWatchTail = 0
	end
	const tail = (tonumber(NAStuff.espNameWatchTail) or 0) + 1
	item = {
		obj = obj,
		reason = reason,
	}
	queue[tail] = item
	qMap[obj] = item
	NAStuff.espNameWatchTail = tail

	if NAlib.isConnected("esp_name_watch_queue") then
		return
	end
	NAlib.connect("esp_name_watch_queue", Services.RunService.Heartbeat:Connect(function()
		const active = NAmanage.NameESP_HasAnyActive()
		const queueNow = NAStuff.espNameWatchQueue
		const mapNow = NAStuff.espNameWatchQueueMap
		local head = tonumber(NAStuff.espNameWatchHead) or 1
		const tailNow = tonumber(NAStuff.espNameWatchTail) or 0
		if not active or type(queueNow) ~= "table" or head > tailNow then
			NAStuff.espNameWatchQueue = {}
			NAStuff.espNameWatchQueueMap = NAmanage.ensureWeakTable(nil, "k")
			NAStuff.espNameWatchHead = 1
			NAStuff.espNameWatchTail = 0
			NAlib.disconnect("esp_name_watch_queue")
			return
		end

		const maxPerStep = math.clamp(math.floor(tonumber(NAStuff.ESP_NameWatchPerStep) or 96), 8, 512)
		local processed = 0
		while processed < maxPerStep and head <= tailNow do
			const itemNow = queueNow[head]
			queueNow[head] = nil
			head += 1
			processed += 1
			if itemNow then
				const inst = itemNow.obj
				if type(mapNow) == "table" and inst ~= nil and mapNow[inst] == itemNow then
					mapNow[inst] = nil
				end
				if typeof(inst) == "Instance" and inst.Parent and inst:IsDescendantOf(Services.Workspace) then
					const applicators = NAStuff.espNameApplicators
					if type(applicators) == "table" then
						if NAmanage.NameESP_HasActiveMode("exact") and type(applicators.exact) == "function" then
							pcall(applicators.exact, inst, itemNow.reason)
						end
						if NAmanage.NameESP_HasActiveMode("partial") and type(applicators.partial) == "function" then
							pcall(applicators.partial, inst, itemNow.reason)
						end
					end
				end
			end
		end
		NAStuff.espNameWatchHead = head
		if head > tailNow then
			NAStuff.espNameWatchQueue = {}
			NAStuff.espNameWatchQueueMap = NAmanage.ensureWeakTable(nil, "k")
			NAStuff.espNameWatchHead = 1
			NAStuff.espNameWatchTail = 0
			NAlib.disconnect("esp_name_watch_queue")
		end
	end))
end

NAmanage.NameESP_AttachWatcher = function(obj)
	const RawWorkspace = __lt.gs("Workspace")
	if typeof(obj) ~= "Instance" or obj == RawWorkspace then
		return
	end
	if not obj.Parent then
		return
	end
	if not NAmanage.NameESP_IsWatchable(obj) then
		return
	end
	if not NAmanage.NameESP_HasAnyActive() then
		return
	end
	local watchers = NAStuff.espNameWatchers
	if type(watchers) ~= "table" then
		watchers = NAmanage.ensureWeakTable(nil, "k")
		NAStuff.espNameWatchers = watchers
	end
	if watchers[obj] ~= nil then
		return
	end
	local ok, signal = pcall(function()
		return obj:GetPropertyChangedSignal("Name")
	end)
	if not ok or not signal then
		return
	end
	const conn = signal:Connect(function()
		NAmanage.NameESP_QueueCheck(obj, "Name")
	end)
	watchers[obj] = { conn }
end

NAmanage.NameESP_StartNameWatch = function()
	if not NAmanage.NameESP_HasAnyActive() then
		return
	end
	if not NAlib.isConnected("esp_name_watch_hub") then
		NAlib.connect("esp_name_watch_hub", NAmanage.wsSub({
			added = function(obj)
				NAmanage.NameESP_AttachWatcher(obj)
				if NAmanage.NameESP_IsWatchable(obj) then
					NAmanage.NameESP_QueueCheck(obj, "Added")
				end
			end,
			removing = function(obj)
				NAmanage.NameESP_DisconnectWatcher(obj)
			end,
		}))
	end

	const scanKey = "esp_name_watch_scan"
	const scanToken = NAmanage.ESP_StartScanToken(scanKey)
	SpawnCall(function()
		NAmanage.ForEachWorkspaceYield(function(obj)
			if scanToken and scanToken.cancelled then
				return
			end
			NAmanage.NameESP_AttachWatcher(obj)
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = scanToken,
		})
		if NAStuff.espScanTokens and NAStuff.espScanTokens[scanKey] == scanToken then
			NAStuff.espScanTokens[scanKey] = nil
		end
	end)
end

NAmanage.NameESP_StopNameWatchIfIdle = function(force)
	if force ~= true and NAmanage.NameESP_HasAnyActive() then
		return
	end
	NAlib.disconnect("esp_name_watch_hub")
	NAlib.disconnect("esp_name_watch_queue")
	NAmanage.ESP_CancelScanToken("esp_name_watch_scan")
	const watchers = NAStuff.espNameWatchers
	if type(watchers) == "table" then
		const watched = {}
		for obj, _ in watchers do
			watched[#watched + 1] = obj
		end
		for i = 1, #watched do
			NAmanage.NameESP_DisconnectWatcher(watched[i])
		end
	end
	NAStuff.espNameWatchers = NAmanage.ensureWeakTable(nil, "k")
	NAStuff.espNameWatchQueue = {}
	NAStuff.espNameWatchQueueMap = NAmanage.ensureWeakTable(nil, "k")
	NAStuff.espNameWatchHead = 1
	NAStuff.espNameWatchTail = 0
end

NAmanage.EnableNameEsp = function(mode, color, ...)
	const RawWorkspace = __lt.gs("Workspace")
	const function currentColor()
		const resolved = (type(color) == "function") and color() or color
		if typeof(resolved) == "Color3" then
			return resolved
		end
		return NAmanage.GetPartESPColor("ESP_PartColor_Name", Color3.fromRGB(255, 255, 255))
	end

	NAStuff.nameESPExclusions = NAStuff.nameESPExclusions or { exact = {}, partial = {} }
	const terms = {...}
	const list = NAStuff.espNameLists[mode]
	const parts = NAStuff.nameESPPartLists[mode]
	local partMap = NAStuff.nameESPPartMaps and NAStuff.nameESPPartMaps[mode]
	if type(partMap) ~= "table" then
		partMap = {}
		NAStuff.nameESPPartMaps[mode] = partMap
	end

	for _, term in terms do
		const t = Lower(term)
		if mode == "exact" then
			NAStuff.nameESPExclusions.exact[t] = nil
		else
			for nm, _ in NAStuff.nameESPExclusions.partial do
				if Find(nm, t) then
					NAStuff.nameESPExclusions.partial[nm] = nil
				end
			end
		end
		if not Discover(list, t) then
			Insert(list, t)
		end
	end

	const function removePart(part)
		if partMap[part] ~= nil then
			NAmanage.RemoveEspFromPart(part)
			NAmanage.ESP_ListRemove(parts, partMap, part)
		end
	end

	const function addTarget(target)
		if typeof(target) ~= "Instance" or not target.Parent then
			return
		end
		if target:IsA("Model") and not target:FindFirstChildWhichIsA("BasePart", true) then
			return
		end
		if not (target:IsA("BasePart") or target:IsA("Model")) then
			return
		end
		if NAmanage.ESP_ListAdd(parts, partMap, target) then
			NAmanage.PartESP_QueueCreate(target, currentColor(), NAStuff.ESP_PartTransparency or 0.45, function(p)
				return partMap[p] ~= nil
			end)
		end
	end

	const function clearModelParts(model)
		if typeof(model) ~= "Instance" or not model:IsA("Model") then
			return
		end
		for _, part in NAmanage.QueryDescendants(model, "BasePart") do
			if partMap[part] ~= nil then
				removePart(part)
			end
		end
	end

	const function applyModel(model)
		if typeof(model) ~= "Instance" or not model:IsA("Model") or not model.Parent then
			return
		end
		if not model:FindFirstChildWhichIsA("BasePart", true) then
			removePart(model)
			return
		end
		clearModelParts(model)
		addTarget(model)
	end

	const function applyPart(part)
		if typeof(part) ~= "Instance" or not part:IsA("BasePart") then
			return
		end

		const modelTarget = NAmanage.NameESP_MatchedModelForPart(part, mode)
		if modelTarget then
			applyModel(modelTarget)
			if partMap[part] ~= nil then
				removePart(part)
			end
			return
		end

		const matches = NAmanage.NameESP_BasePartMatches(part, mode)
		const tracked = partMap[part] ~= nil

		if matches and not tracked then
			addTarget(part)
		elseif not matches and tracked then
			removePart(part)
		end
	end

	const function applyContainer(obj)
		if typeof(obj) ~= "Instance" or obj:IsA("BasePart") then
			return
		end

		if obj:IsA("Model") and NAmanage.NameESP_SelfMatches(obj, mode) then
			applyModel(obj)
			return
		end

		if not NAmanage.NameESP_SelfMatches(obj, mode) then
			local parent = obj.Parent
			local parentMatched = false
			while parent do
				if NAmanage.NameESP_SelfMatches(parent, mode) then
					parentMatched = true
					break
				end
				if parent == RawWorkspace then
					break
				end
				parent = parent.Parent
			end
			if not parentMatched then
				return
			end
		end

		for _, part in NAmanage.QueryDescendants(obj, "BasePart") do
			applyPart(part)
		end
	end

	const function applyChangedObject(obj)
		if typeof(obj) ~= "Instance" or not obj.Parent then
			return
		end
		if obj:IsA("BasePart") then
			applyPart(obj)
			return
		end
		SpawnCall(function()
			if typeof(obj) ~= "Instance" or not obj.Parent then
				return
			end
			if obj:IsA("Model") and NAmanage.NameESP_SelfMatches(obj, mode) then
				applyModel(obj)
				return
			end
			if obj:IsA("Model") and partMap[obj] ~= nil then
				removePart(obj)
			end
			NAmanage.ForEachDescendantYield(obj, function(desc)
				if typeof(desc) ~= "Instance" then
					return
				end
				if desc:IsA("Model") and partMap[desc] ~= nil and not NAmanage.NameESP_SelfMatches(desc, mode) then
					removePart(desc)
				elseif desc:IsA("BasePart") then
					applyPart(desc)
				end
			end, {
				yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
				delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
				streaming = true,
			})
		end)
	end

	NAStuff.espNameApplicators = NAStuff.espNameApplicators or {}
	NAStuff.espNameApplicators[mode] = applyChangedObject
	NAmanage.NameESP_StartNameWatch()

	const scanKey = "esp_name_scan_"..mode
	const scanToken = NAmanage.ESP_StartScanToken(scanKey)
	SpawnCall(function()
		const direct, containers = {}, {}

		NAmanage.ForEachWorkspaceYield(function(obj)
			if scanToken and scanToken.cancelled then
				return
			end
			if typeof(obj) == "Instance" and obj.Parent and NAmanage.NameESP_SelfMatches(obj, mode) then
				if obj:IsA("BasePart") then
					Insert(direct, obj)
				else
					Insert(containers, obj)
				end
			end
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = scanToken,
		})

		for _, obj in containers do
			if scanToken and scanToken.cancelled then
				break
			end
			applyContainer(obj)
		end

		for _, part in direct do
			if scanToken and scanToken.cancelled then
				break
			end
			applyPart(part)
		end

		if NAStuff.espScanTokens and NAStuff.espScanTokens[scanKey] == scanToken then
			NAStuff.espScanTokens[scanKey] = nil
		end
	end)

	if not NAStuff.espNameTriggers[mode] then
		NAStuff.espNameTriggers[mode] = NAmanage.wsSub({
			added = function(obj)
				if typeof(obj) ~= "Instance" then
					return
				end
				if obj:IsA("BasePart") then
					applyPart(obj)
				else
					applyContainer(obj)
				end
			end,
			removing = function(obj)
				if typeof(obj) ~= "Instance" then
					return
				end
				if obj:IsA("BasePart") then
					const model = NAmanage.NameESP_MatchedModelForPart(obj, mode)
					removePart(obj)
					if model and partMap[model] ~= nil then
						Defer(function()
							if model.Parent and not model:FindFirstChildWhichIsA("BasePart", true) then
								removePart(model)
							end
						end)
					end
				else
					if obj:IsA("Model") then
						removePart(obj)
					end
					for _, part in NAmanage.QueryDescendants(obj, "BasePart") do
						removePart(part)
					end
				end
			end,
		})
	end

	NAmanage.PartESP_StartSweep("esp_name_sweep_"..mode, function(obj)
		if typeof(obj) == "Instance" and obj:IsA("BasePart") then
			applyPart(obj)
		end
	end, tonumber(NAStuff.ESP_RescanPerStep) or 90, tonumber(NAStuff.ESP_PartNameSweepInterval) or 18)
end

NAmanage.DisableNameEsp = function(mode)
	if NAStuff.espNameTriggers[mode] then
		NAStuff.espNameTriggers[mode]:Disconnect()
		NAStuff.espNameTriggers[mode] = nil
	end
	NAlib.disconnect("esp_namechange_"..mode)
	if type(NAStuff.espNameApplicators) == "table" then
		NAStuff.espNameApplicators[mode] = nil
	end
	NAmanage.PartESP_StopSweep("esp_name_sweep_"..mode)
	NAmanage.ESP_CancelScanToken("esp_name_scan_"..mode)
	if NAStuff.espSweepCursor then
		NAStuff.espSweepCursor["esp_name_sweep_"..mode] = nil
	end
	const parts = NAStuff.nameESPPartLists[mode]
	const partMap = NAStuff.nameESPPartMaps and NAStuff.nameESPPartMaps[mode]
	for _,part in parts do
		NAmanage.RemoveEspFromPart(part)
	end
	table.clear(parts)
	if type(partMap) == "table" then
		table.clear(partMap)
	end
	table.clear(NAStuff.espNameLists[mode])
	NAmanage.NameESP_StopNameWatchIfIdle()
end

NAmanage.EnableUnanchoredEsp = function(color)
	const function currentColor()
		const resolved = (type(color) == "function") and color() or color
		if typeof(resolved) == "Color3" then
			return resolved
		end
		return NAmanage.GetPartESPColor("ESP_PartColor_Unanchored", Color3.fromRGB(255,220,0))
	end
	const list = NAStuff.unanchoredESPList
	local setMap = NAStuff.unanchoredESPSet
	if type(setMap) ~= "table" then
		setMap = {}
		NAStuff.unanchoredESPSet = setMap
	end
	const function update(part)
		if not part:IsA("BasePart") then return end
		const tracked = setMap[part] ~= nil
		if part.Anchored == false and not tracked then
			if NAmanage.ESP_ListAdd(list, setMap, part) then
				NAmanage.PartESP_QueueCreate(part, currentColor(), NAStuff.ESP_PartTransparency or 0.45, function(p)
					return setMap[p] ~= nil
				end)
			end
		elseif part.Anchored == true and tracked then
			NAmanage.RemoveEspFromPart(part)
			NAmanage.ESP_ListRemove(list, setMap, part)
		end
	end
	const scanKey = "__unanchored_scan"
	const scanToken = NAmanage.ESP_StartScanToken(scanKey)
	SpawnCall(function()
		NAmanage.ForEachWorkspaceYield(function(obj)
			if obj and obj:IsA("BasePart") then
				update(obj)
			end
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = scanToken,
		})
		if NAStuff.espScanTokens and NAStuff.espScanTokens[scanKey] == scanToken then
			NAStuff.espScanTokens[scanKey] = nil
		end
	end)
	if not NAStuff.espTriggers["__unanchored"] then
		NAStuff.espTriggers["__unanchored"] = NAmanage.wsAdd(function(obj)
			if obj:IsA("BasePart") then
				update(obj)
			end
		end)
	end
	NAmanage.PartESP_StartSweep("__unanchored_sweep", function(obj)
		if obj:IsA("BasePart") then
			update(obj)
		end
	end, tonumber(NAStuff.ESP_RescanPerStep) or 90)
end

NAmanage.DisableUnanchoredEsp = function()
	if NAStuff.espTriggers["__unanchored"] then
		NAStuff.espTriggers["__unanchored"]:Disconnect()
		NAStuff.espTriggers["__unanchored"] = nil
	end
	NAlib.disconnect("esp_unanchored_prop")
	NAmanage.PartESP_StopSweep("__unanchored_sweep")
	NAmanage.ESP_CancelScanToken("__unanchored_scan")
	if NAStuff.espSweepCursor then
		NAStuff.espSweepCursor["__unanchored_sweep"] = nil
	end
	for _,part in NAStuff.unanchoredESPList do
		NAmanage.RemoveEspFromPart(part)
	end
	table.clear(NAStuff.unanchoredESPList)
	if type(NAStuff.unanchoredESPSet) == "table" then
		table.clear(NAStuff.unanchoredESPSet)
	end
end

NAmanage.EnableCollisionEsp = function(targetState, color)
	const list = targetState and NAStuff.collisiontrueESPList or NAStuff.collisionfalseESPList
	local setMap = targetState and NAStuff.collisiontrueESPSet or NAStuff.collisionfalseESPSet
	if type(setMap) ~= "table" then
		setMap = {}
		if targetState then
			NAStuff.collisiontrueESPSet = setMap
		else
			NAStuff.collisionfalseESPSet = setMap
		end
	end
	const trigKey = targetState and "__cancollide_true" or "__cancollide_false"
	const propKey = targetState and "esp_cancollide_true_prop" or "esp_cancollide_false_prop"
	const scanKey = targetState and "__cancollide_true_scan" or "__cancollide_false_scan"
	const sweepKey = targetState and "__cancollide_true_sweep" or "__cancollide_false_sweep"
	const function currentColor()
		const resolved = (type(color) == "function") and color() or color
		if typeof(resolved) == "Color3" then
			return resolved
		end
		if targetState then
			return NAmanage.GetPartESPColor("ESP_PartColor_CollisionTrue", Color3.fromRGB(0,200,255))
		end
		return NAmanage.GetPartESPColor("ESP_PartColor_CollisionFalse", Color3.fromRGB(255,120,120))
	end
	const function update(part)
		if not part:IsA("BasePart") then return end
		const tracked = setMap[part] ~= nil
		const matches = part.CanCollide == targetState
		if matches and not tracked then
			if NAmanage.ESP_ListAdd(list, setMap, part) then
				NAmanage.PartESP_QueueCreate(part, currentColor(), NAStuff.ESP_PartTransparency or 0.45, function(p)
					return setMap[p] ~= nil
				end)
			end
		elseif not matches and tracked then
			NAmanage.RemoveEspFromPart(part)
			NAmanage.ESP_ListRemove(list, setMap, part)
		end
	end
	const scanToken = NAmanage.ESP_StartScanToken(scanKey)
	SpawnCall(function()
		NAmanage.ForEachWorkspaceYield(function(obj)
			if obj and obj:IsA("BasePart") then
				update(obj)
			end
		end, {
			yieldEvery = tonumber(NAStuff.ESP_ScanBatchSize) or 160,
			delayTime = tonumber(NAStuff.ESP_ScanDelay) or 0,
			cancelToken = scanToken,
		})
		if NAStuff.espScanTokens and NAStuff.espScanTokens[scanKey] == scanToken then
			NAStuff.espScanTokens[scanKey] = nil
		end
	end)
	if not NAStuff.espTriggers[trigKey] then
		NAStuff.espTriggers[trigKey] = NAmanage.wsAdd(function(obj)
			if obj:IsA("BasePart") then
				update(obj)
			end
		end)
	end
	NAmanage.PartESP_StartSweep(sweepKey, function(obj)
		if obj:IsA("BasePart") then
			update(obj)
		end
	end, tonumber(NAStuff.ESP_RescanPerStep) or 90)
end

NAmanage.DisableCollisionEsp = function(targetState)
	const list = targetState and NAStuff.collisiontrueESPList or NAStuff.collisionfalseESPList
	const trigKey = targetState and "__cancollide_true" or "__cancollide_false"
	const propKey = targetState and "esp_cancollide_true_prop" or "esp_cancollide_false_prop"
	if NAStuff.espTriggers[trigKey] then
		NAStuff.espTriggers[trigKey]:Disconnect()
		NAStuff.espTriggers[trigKey] = nil
	end
	NAlib.disconnect(propKey)
	NAmanage.PartESP_StopSweep(targetState and "__cancollide_true_sweep" or "__cancollide_false_sweep")
	NAmanage.ESP_CancelScanToken(targetState and "__cancollide_true_scan" or "__cancollide_false_scan")
	if NAStuff.espSweepCursor then
		NAStuff.espSweepCursor[targetState and "__cancollide_true_sweep" or "__cancollide_false_sweep"] = nil
	end
	for _,part in list do
		NAmanage.RemoveEspFromPart(part)
	end
	table.clear(list)
	const setMap = targetState and NAStuff.collisiontrueESPSet or NAStuff.collisionfalseESPSet
	if type(setMap) == "table" then
		table.clear(setMap)
	end
end

NAmanage.ESP_LocatorEnsureGui = function()
	if NAStuff.ESP_LocatorGui and NAStuff.ESP_LocatorGui.Parent then return NAStuff.ESP_LocatorGui end
	const g = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(g)
	NAStuff.ESP_LocatorGui = g
	return g
end

NAmanage.ESP_LocatorDisposeHolder = function(holder)
	if typeof(holder) == "Instance" then
		if holder and holder.Parent then
			holder:Destroy()
		end
		return
	end
	if type(holder) ~= "table" then
		return
	end
	if holder.frame and typeof(holder.frame) == "Instance" and holder.frame.Parent then
		holder.frame:Destroy()
	end
	if holder.holder and typeof(holder.holder) == "Instance" and holder.holder.Parent then
		holder.holder:Destroy()
	end
	if holder.label and typeof(holder.label) == "Instance" and holder.label.Parent then
		holder.label:Destroy()
	end
	if holder.drawingArrow then
		NAmanage.DrawingRemoveObject(holder.drawingArrow)
	end
	if holder.drawingLabel then
		NAmanage.DrawingRemoveObject(holder.drawingLabel)
	end
end

NAmanage.ESP_LocatorDirection = function(camera, worldPosition, viewportPoint, viewportSize)
	if not (camera and worldPosition and viewportPoint and viewportSize) then
		return 0, -1
	end
	const cx, cy = viewportSize.X * 0.5, viewportSize.Y * 0.5
	local dirX, dirY
	if viewportPoint.Z > 0 then
		dirX = viewportPoint.X - cx
		dirY = viewportPoint.Y - cy
	else
		const rel = camera.CFrame:PointToObjectSpace(worldPosition)
		dirX = rel.X
		dirY = -rel.Y
		if math.abs(dirX) < 1e-3 and math.abs(dirY) < 1e-3 then
			dirY = 1
		end
	end
	const mag = math.sqrt((dirX * dirX) + (dirY * dirY))
	if mag < 1e-3 then
		return 0, -1
	end
	return dirX / mag, dirY / mag
end

NAmanage.ESP_LocatorUseGuiFallback = function()
	NAlib.disconnect("esp_locator_loop")
	if NAStuff.ESP_LocatorArrows then
		for _, holder in NAStuff.ESP_LocatorArrows do
			NAmanage.ESP_LocatorDisposeHolder(holder)
		end
	end
	NAStuff.ESP_LocatorArrows = {}
	NAStuff.ESP_LocatorBackend = nil
	Defer(function()
		if NAStuff.ESP_LocatorEnabled then
			NAmanage.ESP_LocatorEnableGui(true)
			NAmanage.ESP_LocatorApplyFlags()
		end
	end)
end

NAmanage.ESP_LocatorEnableGui = function(force)
	if NAStuff.ESP_LocatorEnabled and not force and NAlib.isConnected("esp_locator_loop") and NAStuff.ESP_LocatorBackend == "gui" then return end
	NAStuff.ESP_LocatorEnabled = true
	NAStuff.ESP_LocatorBackend = "gui"

	const gui = NAmanage.ESP_LocatorEnsureGui()
	NAStuff.ESP_LocatorArrows = NAStuff.ESP_LocatorArrows or {}
	const arrows = NAStuff.ESP_LocatorArrows
	const holderState = {}
	local activeCount = 0
	local iterKey = nil
	local accum = 0
	local lastCleanup = 0

	const function getHolder(entry)
		local holder = arrows[entry]
		if typeof(holder) == "Instance" and holder.Parent then
			return holder
		end
		if holder then
			NAmanage.ESP_LocatorDisposeHolder(holder)
			arrows[entry] = nil
		end

		const maxActive = math.clamp(math.floor(tonumber(NAStuff.ESP_LocatorMaxArrows) or 180), 24, 800)
		if activeCount >= maxActive then
			return nil
		end

		holder = InstanceNew("Frame")
		holder.Name = "locator"
		holder.Size = UDim2.fromOffset(1, 1)
		holder.AnchorPoint = Vector2.new(0.5, 0.5)
		holder.BackgroundTransparency = 1
		holder.ZIndex = 1
		holder.Visible = false
		holder.Parent = gui

		const pointer = InstanceNew("TextLabel")
		pointer.Name = "Pointer"
		pointer.Size = UDim2.fromOffset(NAStuff.ESP_LocatorSize or 26, NAStuff.ESP_LocatorSize or 26)
		pointer.AnchorPoint = Vector2.new(0.5, 0.5)
		pointer.Position = UDim2.fromOffset(0, 0)
		pointer.BackgroundTransparency = 1
		pointer.Text = "V"
		pointer.TextScaled = true
		pointer.TextStrokeTransparency = 0.5
		pointer.Font = Enum.Font.SourceSansBold
		pointer.ZIndex = 3
		pointer.Visible = true
		pointer.Parent = holder

		const label = InstanceNew("TextLabel")
		label.Name = "Name"
		label.Size = UDim2.fromOffset(150, 20)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromOffset(0, 0)
		label.BackgroundTransparency = 1
		label.Text = ""
		label.TextScaled = false
		label.TextSize = NAStuff.ESP_LocatorTextSize or 14
		label.TextWrapped = true
		label.Font = Enum.Font.SourceSansBold
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.TextStrokeTransparency = 0.5
		label.ZIndex = 2
		label.Visible = NAStuff.ESP_LocatorShowText == true
		label.Parent = holder

		arrows[entry] = holder
		holderState[holder] = {
			seen = os.clock(),
			lastText = nil,
			lastTextSize = nil,
			lastMaxW = nil,
		}
		activeCount += 1
		return holder
	end

	const function removeHolder(entry, holder)
		local had = false
		if holder then
			NAmanage.ESP_LocatorDisposeHolder(holder)
			had = true
		end
		if holderState[holder] then
			holderState[holder] = nil
			had = true
		end
		if entry ~= nil and arrows[entry] ~= nil then
			arrows[entry] = nil
			had = true
		end
		if had and activeCount > 0 then
			activeCount -= 1
		end
	end

	for _, holder in arrows do
		if typeof(holder) == "Instance" and holder.Parent then
			activeCount += 1
			holderState[holder] = holderState[holder] or { seen = os.clock() }
		end
	end

	const function applyStyle(holder, col)
		const size = math.clamp(tonumber(NAStuff.ESP_LocatorSize) or 26, 12, 128)
		const showText = (NAStuff.ESP_LocatorShowText == true)
		const textSize = math.clamp(tonumber(NAStuff.ESP_LocatorTextSize) or 14, 10, 48)

		const pointer = holder:FindFirstChild("Pointer")
		const label = holder:FindFirstChild("Name")

		if pointer then
			if pointer.TextColor3 ~= col then pointer.TextColor3 = col end
			const s = UDim2.fromOffset(size,size)
			if pointer.Size ~= s then pointer.Size = s end
		end
		if label then
			if label.TextColor3 ~= col then label.TextColor3 = col end
			if label.TextSize ~= textSize then label.TextSize = textSize end
			label.Visible = showText
		end
	end

	const function measure(text, textSize, maxWidth)
		const b = __lt.cm("TextService", "GetTextSize", text, textSize, Enum.Font.SourceSansBold, Vector2.new(maxWidth, 1e5))
		const w = math.clamp(b.X + 12, 40, maxWidth)
		const h = math.max(b.Y + 6, textSize + 4)
		return w, h
	end

	NAlib.disconnect("esp_locator_loop")
	NAlib.connect("esp_locator_loop", Services.RunService.RenderStepped:Connect(function(dt)
		if not NAStuff.ESP_LocatorEnabled then return end
		accum += tonumber(dt) or 0
		const updateRate = math.clamp(tonumber(NAStuff.ESP_LocatorUpdateRate) or 18, 8, 60)
		const stepInterval = 1 / updateRate
		if accum < stepInterval then
			return
		end
		accum = 0

		const cam = Services.Workspace.CurrentCamera
		if not cam then return end
		const vp = cam.ViewportSize
		if vp.X <= 0 or vp.Y <= 0 then return end

		const size = math.clamp(tonumber(NAStuff.ESP_LocatorSize) or 26, 12, 128)
		const textOn = (NAStuff.ESP_LocatorShowText == true)
		const textSize = math.clamp(tonumber(NAStuff.ESP_LocatorTextSize) or 14, 10, 48)
		const perStep = math.clamp(math.floor(tonumber(NAStuff.ESP_LocatorPerStep) or 48), 12, 400)
		const staleSeconds = math.clamp(tonumber(NAStuff.ESP_LocatorHoldSeconds) or 0.5, 0.15, 3)
		const now = os.clock()

		const cx, cy = vp.X * 0.5, vp.Y * 0.5
		const margin = 16 + size * 0.5
		const minX, maxX = margin, vp.X - margin
		const minY, maxY = margin, vp.Y - margin

		local root = nil
		if NAStuff.ESP_ShowPartDistance == true then
			const lp = Services.Players.LocalPlayer
			const ch = lp and lp.Character
			root = ch and getRoot(ch)
		end

		const entries = type(NAStuff.partESPEntries) == "table" and NAStuff.partESPEntries or {}
		local processed = 0
		while processed < perStep do
			if iterKey ~= nil and entries[iterKey] == nil then
				iterKey = nil
			end
			local key, entry = next(entries, iterKey)
			if key == nil then
				key, entry = next(entries, nil)
				if key == nil then
					iterKey = nil
					break
				end
			end
			iterKey = key
			processed += 1

			if entry and not entry.removed and entry.part and entry.part.Parent then
				const pos = NAgui.getInstanceWorldPosition(entry.part)
				if pos then
					const v3 = cam:WorldToViewportPoint(pos)
					const x, y, z = v3.X, v3.Y, v3.Z
					const onScreen = (z > 0 and x >= 0 and x <= vp.X and y >= 0 and y <= vp.Y)
					if onScreen then
						const holder = arrows[entry]
						if holder and holder.Parent then
							holder.Visible = false
							const hs = holderState[holder]
							if hs then
								hs.seen = now
							end
						end
					else
						const holder = arrows[entry] or getHolder(entry)
						if holder and holder.Parent then
							const pointer = holder:FindFirstChild("Pointer")
							const label = holder:FindFirstChild("Name")
							const col = entry.lightColor or entry.baseColor or Color3.new(1,1,1)
							applyStyle(holder, col)

							local dirX, dirY = NAmanage.ESP_LocatorDirection(cam, pos, v3, vp)

							const sx = (cx - margin) / math.max(1e-4, math.abs(dirX))
							const sy = (cy - margin) / math.max(1e-4, math.abs(dirY))
							const scale = math.min(sx, sy)
							local px = cx + dirX * scale
							local py = cy + dirY * scale
							if px < minX then px = minX elseif px > maxX then px = maxX end
							if py < minY then py = minY elseif py > maxY then py = maxY end

							const wantPos = UDim2.fromOffset(px, py)
							if holder.Position.X.Offset ~= wantPos.X.Offset or holder.Position.Y.Offset ~= wantPos.Y.Offset then
								holder.Position = wantPos
							end

							if pointer then
								const ang = math.deg(math.atan2(dirY, dirX)) - 90
								if pointer.Rotation ~= ang then pointer.Rotation = ang end
							end

							const hs = holderState[holder]
							if hs then
								hs.seen = now
							end

							if textOn and label then
								local nm = entry.customName or (entry.part and entry.part.Name) or "Part"
								if NAStuff.ESP_ShowPartDistance == true and root and root.Position then
									const d = math.floor((root.Position - pos).Magnitude + 0.5)
									nm = nm.." | "..tostring(d).." studs"
								end

								const side = math.abs(dirX) > math.abs(dirY)
								local displayText = nm
								if side then
									local nameOnly, distOnly = nm, ""
									const bar = Find(nm, "|", 1, true)
									if bar then
										nameOnly = Sub(nm, 1, bar-2)
										distOnly = Sub(nm, bar+2)
									end
									displayText = nameOnly..(distOnly ~= "" and ("\n"..distOnly) or "")
								end

								if label.Text ~= displayText then
									label.Text = displayText
								end

								const maxW = side and math.max(60, math.floor(size * 3.5)) or math.floor(vp.X * 0.25)
								local needsMeasure = true
								if hs then
									needsMeasure = not (
										hs.lastText == displayText and
										hs.lastTextSize == textSize and
										hs.lastMaxW == maxW
									)
								end
								if needsMeasure then
									local w, h = measure(displayText, textSize, maxW)
									if label.Size.X.Offset ~= w or label.Size.Y.Offset ~= h then
										label.Size = UDim2.fromOffset(w, h)
									end
									if hs then
										hs.lastText = displayText
										hs.lastTextSize = textSize
										hs.lastMaxW = maxW
									end
								end

								const gap = 6 + math.floor(size * 0.35)
								const bx, by = -dirX, -dirY
								const offX = bx * (size*0.5 + gap)
								const offY = by * (size*0.5 + gap)
								local lblAbsX = px + offX
								local lblAbsY = py + offY
								const halfW = label.Size.X.Offset * 0.5
								const halfH = label.Size.Y.Offset * 0.5
								if lblAbsX - halfW < 4 then lblAbsX = 4 + halfW end
								if lblAbsX + halfW > vp.X - 4 then lblAbsX = vp.X - 4 - halfW end
								if lblAbsY - halfH < 4 then lblAbsY = 4 + halfH end
								if lblAbsY + halfH > vp.Y - 4 then lblAbsY = vp.Y - 4 - halfH end
								const relX = lblAbsX - px
								const relY = lblAbsY - py
								const wantLabel = UDim2.fromOffset(relX, relY)
								if label.Position.X.Offset ~= wantLabel.X.Offset or label.Position.Y.Offset ~= wantLabel.Y.Offset then
									label.Position = wantLabel
								end
								if not label.Visible then label.Visible = true end
							elseif label and label.Visible then
								label.Visible = false
							end

							holder.Visible = true
						end
					end
				end
			else
				removeHolder(entry, arrows[entry])
			end
		end

		if now - lastCleanup >= 0.25 then
			lastCleanup = now
			for entry, holder in arrows do
				const hs = holderState[holder]
				const stale = (not hs) or ((now - (hs.seen or 0)) > staleSeconds)
				if (not entry) or entry.removed or (not entry.part) or (not entry.part.Parent) or (not holder) or (not holder.Parent) or stale then
					removeHolder(entry, holder)
				end
			end
		end
	end))
end

NAmanage.ESP_LocatorEnableDrawing = function(force)
	if not NAmanage.DrawingTriangleSupported(true) then
		NAStuff.ESP_LocatorEnabled = true
		NAmanage.ESP_LocatorUseGuiFallback()
		return
	end
	if NAStuff.ESP_LocatorEnabled and not force and NAlib.isConnected("esp_locator_loop") and NAStuff.ESP_LocatorBackend == "drawing" then return end
	NAStuff.ESP_LocatorEnabled = true
	NAStuff.ESP_LocatorBackend = "drawing"

	if NAStuff.ESP_LocatorGui and NAStuff.ESP_LocatorGui.Parent then
		NAStuff.ESP_LocatorGui:Destroy()
		NAStuff.ESP_LocatorGui = nil
	end

	NAStuff.ESP_LocatorArrows = NAStuff.ESP_LocatorArrows or {}
	const arrows = NAStuff.ESP_LocatorArrows
	const holderState = {}
	local activeCount = 0
	local iterKey = nil
	local accum = 0
	local lastCleanup = 0

	const function getHolder(entry)
		local holder = arrows[entry]
		if type(holder) == "table" and holder.drawingArrow then
			return holder
		end
		if holder then
			NAmanage.ESP_LocatorDisposeHolder(holder)
			arrows[entry] = nil
		end

		const maxActive = math.clamp(math.floor(tonumber(NAStuff.ESP_LocatorMaxArrows) or 180), 24, 800)
		if activeCount >= maxActive then
			return nil
		end

		const tri = NAmanage.DrawingCreateTriangle(Color3.new(1, 1, 1), 1)
		if not tri then
			NAmanage.ESP_LocatorUseGuiFallback()
			return nil
		end
		const label = NAStuff.ESP_LocatorShowText == true and NAmanage.DrawingCreateText("", Color3.new(1, 1, 1), NAStuff.ESP_LocatorTextSize or 14) or nil
		holder = {
			drawingArrow = tri,
			drawingLabel = label,
		}
		arrows[entry] = holder
		holderState[holder] = { seen = os.clock() }
		activeCount += 1
		return holder
	end

	const function removeHolder(entry, holder)
		local had = false
		if holder then
			NAmanage.ESP_LocatorDisposeHolder(holder)
			had = true
		end
		if holderState[holder] then
			holderState[holder] = nil
			had = true
		end
		if entry ~= nil and arrows[entry] ~= nil then
			arrows[entry] = nil
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

	NAlib.disconnect("esp_locator_loop")
	NAlib.connect("esp_locator_loop", Services.RunService.RenderStepped:Connect(function(dt)
		if not NAStuff.ESP_LocatorEnabled then
			return
		end
		accum += tonumber(dt) or 0
		const updateRate = math.clamp(tonumber(NAStuff.ESP_LocatorUpdateRate) or 18, 8, 60)
		const stepInterval = 1 / updateRate
		if accum < stepInterval then
			return
		end
		accum = 0

		const cam = Services.Workspace.CurrentCamera
		if not cam then return end
		const vp = cam.ViewportSize
		if vp.X <= 0 or vp.Y <= 0 then return end

		const size = math.clamp(tonumber(NAStuff.ESP_LocatorSize) or 26, 12, 128)
		const textOn = (NAStuff.ESP_LocatorShowText == true)
		const textSize = math.clamp(tonumber(NAStuff.ESP_LocatorTextSize) or 14, 10, 48)
		const perStep = math.clamp(math.floor(tonumber(NAStuff.ESP_LocatorPerStep) or 48), 12, 400)
		const staleSeconds = math.clamp(tonumber(NAStuff.ESP_LocatorHoldSeconds) or 0.5, 0.15, 3)
		const now = os.clock()

		const cx, cy = vp.X * 0.5, vp.Y * 0.5
		const margin = 16 + size * 0.5
		const minX, maxX = margin, vp.X - margin
		const minY, maxY = margin, vp.Y - margin

		local root = nil
		if NAStuff.ESP_ShowPartDistance == true then
			const lp = Services.Players.LocalPlayer
			const ch = lp and lp.Character
			root = ch and getRoot(ch)
		end

		const entries = type(NAStuff.partESPEntries) == "table" and NAStuff.partESPEntries or {}
		local processed = 0
		while processed < perStep do
			if iterKey ~= nil and entries[iterKey] == nil then
				iterKey = nil
			end
			local key, entry = next(entries, iterKey)
			if key == nil then
				key, entry = next(entries, nil)
				if key == nil then
					iterKey = nil
					break
				end
			end
			iterKey = key
			processed += 1

			if entry and not entry.removed and entry.part and entry.part.Parent then
				const pos = NAgui.getInstanceWorldPosition(entry.part)
				if pos then
					const v3 = cam:WorldToViewportPoint(pos)
					const x, y, z = v3.X, v3.Y, v3.Z
					const onScreen = (z > 0 and x >= 0 and x <= vp.X and y >= 0 and y <= vp.Y)
					if onScreen then
						const holder = arrows[entry]
						if type(holder) == "table" then
							if holder.drawingArrow then
								pcall(function() holder.drawingArrow.Visible = false end)
							end
							if holder.drawingLabel then
								pcall(function() holder.drawingLabel.Visible = false end)
							end
							const hs = holderState[holder]
							if hs then
								hs.seen = now
							end
						end
					else
						const holder = arrows[entry] or getHolder(entry)
						if type(holder) == "table" and holder.drawingArrow then
							const col = entry.lightColor or entry.baseColor or Color3.new(1, 1, 1)

							local dirX, dirY = NAmanage.ESP_LocatorDirection(cam, pos, v3, vp)

							const sx = (cx - margin) / math.max(1e-4, math.abs(dirX))
							const sy = (cy - margin) / math.max(1e-4, math.abs(dirY))
							const scale = math.min(sx, sy)
							local px = cx + (dirX * scale)
							local py = cy + (dirY * scale)
							if px < minX then px = minX elseif px > maxX then px = maxX end
							if py < minY then py = minY elseif py > maxY then py = maxY end

							if not NAmanage.DrawingUpdateTriangle(holder.drawingArrow, px, py, dirX, dirY, size, col, 1) then
								NAmanage.ESP_LocatorUseGuiFallback()
								return
							end

							const hs = holderState[holder]
							if hs then
								hs.seen = now
							end

							if textOn then
								if not holder.drawingLabel then
									holder.drawingLabel = NAmanage.DrawingCreateText("", col, textSize)
								end
								const label = holder.drawingLabel
								if label then
									local nm = entry.customName or (entry.part and entry.part.Name) or "Part"
									if NAStuff.ESP_ShowPartDistance == true and root and root.Position then
										const d = math.floor((root.Position - pos).Magnitude + 0.5)
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
				removeHolder(entry, arrows[entry])
			end
		end

		if now - lastCleanup >= 0.2 then
			lastCleanup = now
			for entry, holder in arrows do
				const hs = holderState[holder]
				const stale = (not hs) or ((now - (hs.seen or 0)) > staleSeconds)
				const hasArrow = type(holder) == "table" and holder.drawingArrow ~= nil
				if (not entry) or entry.removed or (not entry.part) or (not entry.part.Parent) or (not hasArrow) or stale then
					removeHolder(entry, holder)
				end
			end
		end
	end))
end

NAmanage.ESP_LocatorShouldUseDrawing = function()
	return NAgui.espUsesDrawing("part") and NAmanage.DrawingTriangleSupported()
end

NAmanage.ESP_LocatorEnable = function(force)
	const targetBackend = NAmanage.ESP_LocatorShouldUseDrawing() and "drawing" or "gui"
	const currentBackend = tostring(NAStuff.ESP_LocatorBackend or "")
	if NAlib.isConnected("esp_locator_loop") and (force or currentBackend ~= targetBackend) then
		NAmanage.ESP_LocatorDisable()
	end
	if targetBackend == "drawing" then
		NAmanage.ESP_LocatorEnableDrawing(force)
	else
		NAmanage.ESP_LocatorEnableGui(force)
	end
end

NAmanage.ESP_LocatorDisable = function()
	NAStuff.ESP_LocatorEnabled = false
	NAlib.disconnect("esp_locator_loop")
	if NAStuff.ESP_LocatorArrows then
		for _, holder in NAStuff.ESP_LocatorArrows do
			NAmanage.ESP_LocatorDisposeHolder(holder)
		end
	end
	NAStuff.ESP_LocatorArrows = {}
	NAStuff.ESP_LocatorBackend = nil
	if NAStuff.ESP_LocatorGui and NAStuff.ESP_LocatorGui.Parent then
		NAStuff.ESP_LocatorGui:Destroy()
		NAStuff.ESP_LocatorGui = nil
	end
end

NAmanage.ESP_PlayerLocatorEnsureGui = function()
	if NAStuff.ESP_PlayerLocatorGui and NAStuff.ESP_PlayerLocatorGui.Parent then
		return NAStuff.ESP_PlayerLocatorGui
	end
	const g = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(g)
	NAStuff.ESP_PlayerLocatorGui = g
	return g
end

NAmanage.ESP_PlayerLocatorShouldUseDrawing = function()
	return NAgui.espUsesDrawing("players") and NAmanage.DrawingTriangleSupported()
end

NAmanage.ESP_PlayerLocatorUseGuiFallback = function()
	NAlib.disconnect("esp_player_locator_loop")
	if NAStuff.ESP_PlayerLocatorArrows then
		for _, holder in NAStuff.ESP_PlayerLocatorArrows do
			NAmanage.ESP_LocatorDisposeHolder(holder)
		end
	end
	NAStuff.ESP_PlayerLocatorArrows = {}
	NAStuff.ESP_PlayerLocatorBackend = nil
	Defer(function()
		if NAStuff.ESP_PlayerLocatorEnabled then
			NAmanage.ESP_PlayerLocatorEnableGui(true)
			NAmanage.ESP_PlayerLocatorApplyFlags()
		end
	end)
end

NAmanage.ESP_PlayerLocatorEnableGui = function(force)
	if NAStuff.ESP_PlayerLocatorEnabled and not force and NAlib.isConnected("esp_player_locator_loop") and NAStuff.ESP_PlayerLocatorBackend == "gui" then return end
	NAStuff.ESP_PlayerLocatorEnabled = true
	NAStuff.ESP_PlayerLocatorBackend = "gui"

	const gui = NAmanage.ESP_PlayerLocatorEnsureGui()
	NAStuff.ESP_PlayerLocatorArrows = NAStuff.ESP_PlayerLocatorArrows or {}
	const arrows = NAStuff.ESP_PlayerLocatorArrows
	const holderState = {}
	local activeCount = 0
	local iterKey = nil
	local accum = 0
	local lastCleanup = 0

	const function getHolder(model)
		local holder = arrows[model]
		if typeof(holder) == "Instance" and holder.Parent then
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

		holder = InstanceNew("Frame")
		holder.Name = "player_locator"
		holder.Size = UDim2.fromOffset(1, 1)
		holder.AnchorPoint = Vector2.new(0.5, 0.5)
		holder.BackgroundTransparency = 1
		holder.ZIndex = 1
		holder.Visible = false
		holder.Parent = gui

		const pointer = InstanceNew("TextLabel")
		pointer.Name = "Pointer"
		pointer.Size = UDim2.fromOffset(NAStuff.ESP_PlayerLocatorSize or 26, NAStuff.ESP_PlayerLocatorSize or 26)
		pointer.AnchorPoint = Vector2.new(0.5, 0.5)
		pointer.Position = UDim2.fromOffset(0, 0)
		pointer.BackgroundTransparency = 1
		pointer.Text = "V"
		pointer.TextScaled = true
		pointer.TextStrokeTransparency = 0.5
		pointer.Font = Enum.Font.SourceSansBold
		pointer.ZIndex = 3
		pointer.Visible = true
		pointer.Parent = holder

		const label = InstanceNew("TextLabel")
		label.Name = "Name"
		label.Size = UDim2.fromOffset(170, 24)
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = UDim2.fromOffset(0, 0)
		label.BackgroundTransparency = 1
		label.Text = ""
		label.TextScaled = false
		label.TextSize = NAStuff.ESP_PlayerLocatorTextSize or 14
		label.TextWrapped = true
		label.Font = Enum.Font.SourceSansBold
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.TextStrokeTransparency = 0.5
		label.ZIndex = 2
		label.Visible = NAStuff.ESP_PlayerLocatorShowText == true
		label.Parent = holder

		arrows[model] = holder
		holderState[holder] = {
			seen = os.clock(),
			lastText = nil,
			lastTextSize = nil,
			lastMaxW = nil,
		}
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
		if typeof(holder) == "Instance" and holder.Parent then
			activeCount += 1
			holderState[holder] = holderState[holder] or { seen = os.clock() }
		end
	end

	const function applyStyle(holder, col)
		const size = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorSize) or 26, 12, 128)
		const showText = (NAStuff.ESP_PlayerLocatorShowText == true)
		const textSize = math.clamp(tonumber(NAStuff.ESP_PlayerLocatorTextSize) or 14, 10, 48)

		const pointer = holder:FindFirstChild("Pointer")
		const label = holder:FindFirstChild("Name")

		if pointer then
			if pointer.TextColor3 ~= col then pointer.TextColor3 = col end
			const s = UDim2.fromOffset(size, size)
			if pointer.Size ~= s then pointer.Size = s end
		end
		if label then
			if label.TextColor3 ~= col then label.TextColor3 = col end
			if label.TextSize ~= textSize then label.TextSize = textSize end
			label.Visible = showText
		end
	end

	const function measure(text, textSize, maxWidth)
		const b = __lt.cm("TextService", "GetTextSize", text, textSize, Enum.Font.SourceSansBold, Vector2.new(maxWidth, 1e5))
		const w = math.clamp(b.X + 12, 40, maxWidth)
		const h = math.max(b.Y + 6, textSize + 4)
		return w, h
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

		local localRoot = nil
		const lp = Services.Players.LocalPlayer
		const localChar = lp and lp.Character
		localRoot = localChar and getRoot(localChar)

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
						if holder and holder.Parent then
							holder.Visible = false
							const hs = holderState[holder]
							if hs then hs.seen = now end
						end
					else
						const holder = arrows[model] or getHolder(model)
						if holder and holder.Parent then
							const pointer = holder:FindFirstChild("Pointer")
							const label = holder:FindFirstChild("Name")
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
							applyStyle(holder, col)

							local dirX, dirY = NAmanage.ESP_LocatorDirection(cam, pos, v3, vp)

							const sx = (cx - margin) / math.max(1e-4, math.abs(dirX))
							const sy = (cy - margin) / math.max(1e-4, math.abs(dirY))
							const scale = math.min(sx, sy)
							local px = cx + dirX * scale
							local py = cy + dirY * scale
							if px < minX then px = minX elseif px > maxX then px = maxX end
							if py < minY then py = minY elseif py > maxY then py = maxY end

							const wantPos = UDim2.fromOffset(px, py)
							if holder.Position.X.Offset ~= wantPos.X.Offset or holder.Position.Y.Offset ~= wantPos.Y.Offset then
								holder.Position = wantPos
							end
							if pointer then
								const ang = math.deg(math.atan2(dirY, dirX)) - 90
								if pointer.Rotation ~= ang then pointer.Rotation = ang end
							end

							const hs = holderState[holder]
							if hs then hs.seen = now end

							if textOn and label then
								local nm = (owner and nameChecker(owner)) or (model and model.Name) or "Player"
								if localRoot then
									const d = math.floor((localRoot.Position - pos).Magnitude + 0.5)
									nm = nm.." | "..tostring(d).." studs"
								end
								const side = math.abs(dirX) > math.abs(dirY)
								local displayText = nm
								if side then
									local nameOnly, distOnly = nm, ""
									const bar = Find(nm, "|", 1, true)
									if bar then
										nameOnly = Sub(nm, 1, bar - 2)
										distOnly = Sub(nm, bar + 2)
									end
									displayText = nameOnly..(distOnly ~= "" and ("\n"..distOnly) or "")
								end
								if label.Text ~= displayText then
									label.Text = displayText
								end
								const maxW = side and math.max(60, math.floor(size * 3.5)) or math.floor(vp.X * 0.25)
								local needsMeasure = true
								if hs then
									needsMeasure = not (hs.lastText == displayText and hs.lastTextSize == textSize and hs.lastMaxW == maxW)
								end
								if needsMeasure then
									local w, h = measure(displayText, textSize, maxW)
									if label.Size.X.Offset ~= w or label.Size.Y.Offset ~= h then
										label.Size = UDim2.fromOffset(w, h)
									end
									if hs then
										hs.lastText = displayText
										hs.lastTextSize = textSize
										hs.lastMaxW = maxW
									end
								end
								const gap = 6 + math.floor(size * 0.35)
								const bx, by = -dirX, -dirY
								const offX = bx * (size * 0.5 + gap)
								const offY = by * (size * 0.5 + gap)
								local lblAbsX = px + offX
								local lblAbsY = py + offY
								const halfW = label.Size.X.Offset * 0.5
								const halfH = label.Size.Y.Offset * 0.5
								if lblAbsX - halfW < 4 then lblAbsX = 4 + halfW end
								if lblAbsX + halfW > vp.X - 4 then lblAbsX = vp.X - 4 - halfW end
								if lblAbsY - halfH < 4 then lblAbsY = 4 + halfH end
								if lblAbsY + halfH > vp.Y - 4 then lblAbsY = vp.Y - 4 - halfH end
								const relX = lblAbsX - px
								const relY = lblAbsY - py
								const wantLabel = UDim2.fromOffset(relX, relY)
								if label.Position.X.Offset ~= wantLabel.X.Offset or label.Position.Y.Offset ~= wantLabel.Y.Offset then
									label.Position = wantLabel
								end
								if not label.Visible then label.Visible = true end
							elseif label and label.Visible then
								label.Visible = false
							end

							holder.Visible = true
						end
					end
				end
			else
				removeHolder(model, arrows[model])
			end
		end

		if now - lastCleanup >= 0.25 then
			lastCleanup = now
			for model, holder in arrows do
				const hs = holderState[holder]
				const stale = (not hs) or ((now - (hs.seen or 0)) > staleSeconds)
				const data = espCONS[model]
				const invalid = (not model) or (not data) or data.isNPC == true or (not model.Parent) or (not NAmanage.IsValidESPModel(model, false))
				if invalid or (not holder) or (not holder.Parent) or stale then
					removeHolder(model, holder)
				end
			end
		end
	end))
end
