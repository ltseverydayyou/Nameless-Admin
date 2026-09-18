cmd.add({"fullbright","fullb","fb"},{"fullbright (fullb,fb)","makes dark games bright without destroying effects"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	const function ensureFB()
		st.fb = st.fb or {init=false,enabled=false,baseline={},target={Brightness=1,ClockTime=12,FogEnd=786543,GlobalShadows=false,Ambient=Color3.fromRGB(178,178,178)}}
		if st.fb.baseline.Brightness == nil then st.fb.baseline.Brightness = st.safeGet(Services.Lighting,"Brightness") or 2 end
		if st.fb.baseline.ClockTime == nil then st.fb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or 12 end
		if st.fb.baseline.FogEnd == nil then st.fb.baseline.FogEnd = st.safeGet(Services.Lighting,"FogEnd") or 100000 end
		if st.fb.baseline.GlobalShadows == nil then const v=st.safeGet(Services.Lighting,"GlobalShadows") st.fb.baseline.GlobalShadows = v~=nil and v or true end
		if st.fb.baseline.Ambient == nil then st.fb.baseline.Ambient = st.safeGet(Services.Lighting,"Ambient") or Color3.fromRGB(128,128,128) end
		if not st.initFB then
			st.initFB = function()
				st.hook("fb_brightness", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "Brightness"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"Brightness") ~= st.fb.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.fb.target.Brightness) end
						else
							st.fb.baseline.Brightness = st.safeGet(Services.Lighting,"Brightness") or st.fb.baseline.Brightness
						end
					end) end)
				st.hook("fb_clocktime", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "ClockTime"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"ClockTime") ~= st.fb.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.fb.target.ClockTime) end
						else
							st.fb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or st.fb.baseline.ClockTime
						end
					end) end)
				st.hook("fb_fogend", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "FogEnd"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"FogEnd") ~= st.fb.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.fb.target.FogEnd) end
						else
							st.fb.baseline.FogEnd = st.safeGet(Services.Lighting,"FogEnd") or st.fb.baseline.FogEnd
						end
					end) end)
				st.hook("fb_shadows", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "GlobalShadows"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"GlobalShadows") ~= st.fb.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.fb.target.GlobalShadows) end
						else
							const v=st.safeGet(Services.Lighting,"GlobalShadows") if v~=nil then st.fb.baseline.GlobalShadows=v end
						end
					end) end)
				st.hook("fb_ambient", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "Ambient"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"Ambient") ~= st.fb.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.fb.target.Ambient) end
						else
							st.fb.baseline.Ambient = st.safeGet(Services.Lighting,"Ambient") or st.fb.baseline.Ambient
						end
					end) end)
				st.hook("fb_loop", function() return Services.RunService.RenderStepped:Connect(function()
						if not (st.fb and st.fb.enabled) then return end
						if st.safeGet(Services.Lighting,"Brightness") ~= st.fb.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.fb.target.Brightness) end
						if st.safeGet(Services.Lighting,"ClockTime") ~= st.fb.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.fb.target.ClockTime) end
						if st.safeGet(Services.Lighting,"FogEnd") ~= st.fb.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.fb.target.FogEnd) end
						const gs = st.safeGet(Services.Lighting,"GlobalShadows")
						if gs~=nil and gs ~= st.fb.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.fb.target.GlobalShadows) end
						if st.safeGet(Services.Lighting,"Ambient") ~= st.fb.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.fb.target.Ambient) end
					end) end)
			end
		end
		if not st.applyFB then
			st.applyFB = function()
				st.safeSet(Services.Lighting,"Brightness",st.fb.target.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.fb.target.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.fb.target.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.fb.target.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.fb.target.Ambient)
			end
		end
		if not st.restoreFB then
			st.restoreFB = function()
				st.safeSet(Services.Lighting,"Brightness",st.fb.baseline.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.fb.baseline.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.fb.baseline.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.fb.baseline.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.fb.baseline.Ambient)
			end
		end
		if not st.toggleFB then
			st.toggleFB = function(on)
				st.initFB()
				st.fb.enabled = on
				if on then st.applyFB() else st.restoreFB() end
				_na_env.FullBrightExecuted = true
				_na_env.FullBrightEnabled = st.fb.enabled
			end
		end
	end
	ensureFB()
	if not st.fb.enabled then st.cancelFor("fb") end
	st.toggleFB(not st.fb.enabled)
end)

cmd.add({"loopday","lday"},{"loopday","Sunshiiiine!"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	st.fb = st.fb or {enabled=false,baseline={},target={Brightness=1,ClockTime=12,FogEnd=786543,GlobalShadows=false,Ambient=Color3.fromRGB(178,178,178)}}
	st.fb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or 12
	st.cancelFor("day")
	NAlib.disconnect("time_day")
	st.safeSet(Services.Lighting,"ClockTime",14)
	NAlib.connect("time_day", __lt.cm("Lighting", "GetPropertyChangedSignal", "ClockTime"):Connect(function()
		if st.safeGet(Services.Lighting,"ClockTime") ~= 14 then st.safeSet(Services.Lighting,"ClockTime",14) end
	end))
end)

cmd.add({"unloopday","unlday"},{"unloopday","No more sunshine"},function()
	if not Services.Lighting then return end
	const st = _na_env._LState
	if not st then return end
	NAlib.disconnect("time_day")
	const target = (st.fb and st.fb.enabled) and ((st.fb.target and st.fb.target.ClockTime) or 12) or ((st.fb and st.fb.baseline and st.fb.baseline.ClockTime) or (st.safeGet and st.safeGet(Services.Lighting,"ClockTime")) or 12)
	if st.safeSet then st.safeSet(Services.Lighting,"ClockTime",target) else Services.Lighting.ClockTime = target end
end)

cmd.add({"loopfullbright","loopfb","lfb"},{"loopfullbright","Sunshiiiine!"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	const function ensureFB()
		st.fb = st.fb or {init=false,enabled=false,baseline={},target={Brightness=1,ClockTime=12,FogEnd=786543,GlobalShadows=false,Ambient=Color3.fromRGB(178,178,178)}}
		if st.fb.baseline.Brightness == nil then st.fb.baseline.Brightness = st.safeGet(Services.Lighting,"Brightness") or 2 end
		if st.fb.baseline.ClockTime == nil then st.fb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or 12 end
		if st.fb.baseline.FogEnd == nil then st.fb.baseline.FogEnd = st.safeGet(Services.Lighting,"FogEnd") or 100000 end
		if st.fb.baseline.GlobalShadows == nil then const v=st.safeGet(Services.Lighting,"GlobalShadows") st.fb.baseline.GlobalShadows = v~=nil and v or true end
		if st.fb.baseline.Ambient == nil then st.fb.baseline.Ambient = st.safeGet(Services.Lighting,"Ambient") or Color3.fromRGB(128,128,128) end
		if not st.initFB then
			st.initFB = function()
				st.hook("fb_brightness", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "Brightness"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"Brightness") ~= st.fb.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.fb.target.Brightness) end
						else
							st.fb.baseline.Brightness = st.safeGet(Services.Lighting,"Brightness") or st.fb.baseline.Brightness
						end
					end) end)
				st.hook("fb_clocktime", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "ClockTime"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"ClockTime") ~= st.fb.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.fb.target.ClockTime) end
						else
							st.fb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or st.fb.baseline.ClockTime
						end
					end) end)
				st.hook("fb_fogend", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "FogEnd"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"FogEnd") ~= st.fb.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.fb.target.FogEnd) end
						else
							st.fb.baseline.FogEnd = st.safeGet(Services.Lighting,"FogEnd") or st.fb.baseline.FogEnd
						end
					end) end)
				st.hook("fb_shadows", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "GlobalShadows"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"GlobalShadows") ~= st.fb.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.fb.target.GlobalShadows) end
						else
							const v=st.safeGet(Services.Lighting,"GlobalShadows") if v~=nil then st.fb.baseline.GlobalShadows=v end
						end
					end) end)
				st.hook("fb_ambient", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "Ambient"):Connect(function()
						if st.fb and st.fb.enabled then
							if st.safeGet(Services.Lighting,"Ambient") ~= st.fb.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.fb.target.Ambient) end
						else
							st.fb.baseline.Ambient = st.safeGet(Services.Lighting,"Ambient") or st.fb.baseline.Ambient
						end
					end) end)
				st.hook("fb_loop", function() return Services.RunService.RenderStepped:Connect(function()
						if not (st.fb and st.fb.enabled) then return end
						if st.safeGet(Services.Lighting,"Brightness") ~= st.fb.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.fb.target.Brightness) end
						if st.safeGet(Services.Lighting,"ClockTime") ~= st.fb.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.fb.target.ClockTime) end
						if st.safeGet(Services.Lighting,"FogEnd") ~= st.fb.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.fb.target.FogEnd) end
						const gs = st.safeGet(Services.Lighting,"GlobalShadows")
						if gs~=nil and gs ~= st.fb.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.fb.target.GlobalShadows) end
						if st.safeGet(Services.Lighting,"Ambient") ~= st.fb.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.fb.target.Ambient) end
					end) end)
			end
		end
		if not st.applyFB then
			st.applyFB = function()
				st.safeSet(Services.Lighting,"Brightness",st.fb.target.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.fb.target.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.fb.target.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.fb.target.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.fb.target.Ambient)
			end
		end
		if not st.restoreFB then
			st.restoreFB = function()
				st.safeSet(Services.Lighting,"Brightness",st.fb.baseline.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.fb.baseline.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.fb.baseline.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.fb.baseline.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.fb.baseline.Ambient)
			end
		end
		if not st.toggleFB then
			st.toggleFB = function(on)
				st.initFB()
				st.fb.enabled = on
				if on then st.applyFB() else st.restoreFB() end
				_na_env.FullBrightExecuted = true
				_na_env.FullBrightEnabled = st.fb.enabled
			end
		end
	end
	ensureFB()
	st.cancelFor("fb")
	st.toggleFB(true)
end)

cmd.add({"unloopfullbright","unloopfb","unlfb"},{"unloopfullbright","No more sunshine"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	const function ensureFB()
		st.fb = st.fb or {init=false,enabled=false,baseline={},target={Brightness=1,ClockTime=12,FogEnd=786543,GlobalShadows=false,Ambient=Color3.fromRGB(178,178,178)}}
		if st.fb.baseline.Brightness == nil then st.fb.baseline.Brightness = st.safeGet(Services.Lighting,"Brightness") or 2 end
		if st.fb.baseline.ClockTime == nil then st.fb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or 12 end
		if st.fb.baseline.FogEnd == nil then st.fb.baseline.FogEnd = st.safeGet(Services.Lighting,"FogEnd") or 100000 end
		if st.fb.baseline.GlobalShadows == nil then const v=st.safeGet(Services.Lighting,"GlobalShadows") st.fb.baseline.GlobalShadows = v~=nil and v or true end
		if st.fb.baseline.Ambient == nil then st.fb.baseline.Ambient = st.safeGet(Services.Lighting,"Ambient") or Color3.fromRGB(128,128,128) end
		if not st.applyFB then
			st.applyFB = function()
				st.safeSet(Services.Lighting,"Brightness",st.fb.target.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.fb.target.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.fb.target.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.fb.target.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.fb.target.Ambient)
			end
		end
		if not st.restoreFB then
			st.restoreFB = function()
				st.safeSet(Services.Lighting,"Brightness",st.fb.baseline.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.fb.baseline.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.fb.baseline.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.fb.baseline.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.fb.baseline.Ambient)
			end
		end
	end
	ensureFB()
	if st.fb and st.fb.enabled then
		st.toggleFB(false)
	end
end)

cmd.add({"loopnight","loopn","ln"},{"loopnight","Moonlight."},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	st.cancelFor("night")
	const function ensureNB()
		st.nb = st.nb or {init=false,enabled=false,baseline={},target={Brightness=1,ClockTime=0,FogEnd=786543,GlobalShadows=false,Ambient=Color3.fromRGB(178,178,178)}}
		if st.nb.baseline.Brightness == nil then st.nb.baseline.Brightness = st.safeGet(Services.Lighting,"Brightness") or 2 end
		if st.nb.baseline.ClockTime == nil then st.nb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or 12 end
		if st.nb.baseline.FogEnd == nil then st.nb.baseline.FogEnd = st.safeGet(Services.Lighting,"FogEnd") or 100000 end
		if st.nb.baseline.GlobalShadows == nil then const v=st.safeGet(Services.Lighting,"GlobalShadows") st.nb.baseline.GlobalShadows = v~=nil and v or true end
		if st.nb.baseline.Ambient == nil then st.nb.baseline.Ambient = st.safeGet(Services.Lighting,"Ambient") or Color3.fromRGB(128,128,128) end
		if not st.initNB then
			st.initNB = function()
				st.hook("nb_brightness", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "Brightness"):Connect(function()
						if st.nb and st.nb.enabled then
							if st.safeGet(Services.Lighting,"Brightness") ~= st.nb.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.nb.target.Brightness) end
						else
							st.nb.baseline.Brightness = st.safeGet(Services.Lighting,"Brightness") or st.nb.baseline.Brightness
						end
					end) end)
				st.hook("nb_clocktime", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "ClockTime"):Connect(function()
						if st.nb and st.nb.enabled then
							if st.safeGet(Services.Lighting,"ClockTime") ~= st.nb.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.nb.target.ClockTime) end
						else
							st.nb.baseline.ClockTime = st.safeGet(Services.Lighting,"ClockTime") or st.nb.baseline.ClockTime
						end
					end) end)
				st.hook("nb_fogend", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "FogEnd"):Connect(function()
						if st.nb and st.nb.enabled then
							if st.safeGet(Services.Lighting,"FogEnd") ~= st.nb.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.nb.target.FogEnd) end
						else
							st.nb.baseline.FogEnd = st.safeGet(Services.Lighting,"FogEnd") or st.nb.baseline.FogEnd
						end
					end) end)
				st.hook("nb_shadows", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "GlobalShadows"):Connect(function()
						if st.nb and st.nb.enabled then
							if st.safeGet(Services.Lighting,"GlobalShadows") ~= st.nb.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.nb.target.GlobalShadows) end
						else
							const v=st.safeGet(Services.Lighting,"GlobalShadows") if v~=nil then st.nb.baseline.GlobalShadows=v end
						end
					end) end)
				st.hook("nb_ambient", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "Ambient"):Connect(function()
						if st.nb and st.nb.enabled then
							if st.safeGet(Services.Lighting,"Ambient") ~= st.nb.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.nb.target.Ambient) end
						else
							st.nb.baseline.Ambient = st.safeGet(Services.Lighting,"Ambient") or st.nb.baseline.Ambient
						end
					end) end)
				st.hook("nb_loop", function() return Services.RunService.RenderStepped:Connect(function()
						if not (st.nb and st.nb.enabled) then return end
						if st.safeGet(Services.Lighting,"Brightness") ~= st.nb.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.nb.target.Brightness) end
						if st.safeGet(Services.Lighting,"ClockTime") ~= st.nb.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.nb.target.ClockTime) end
						if st.safeGet(Services.Lighting,"FogEnd") ~= st.nb.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.nb.target.FogEnd) end
						const gs = st.safeGet(Services.Lighting,"GlobalShadows")
						if gs~=nil and gs ~= st.nb.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.nb.target.GlobalShadows) end
						if st.safeGet(Services.Lighting,"Ambient") ~= st.nb.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.nb.target.Ambient) end
					end) end)
			end
		end
		if not st.applyNB then
			st.applyNB = function()
				st.safeSet(Services.Lighting,"Brightness",st.nb.target.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.nb.target.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.nb.target.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.nb.target.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.nb.target.Ambient)
			end
		end
		if not st.restoreNB then
			st.restoreNB = function()
				st.safeSet(Services.Lighting,"Brightness",st.nb.baseline.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.nb.baseline.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.nb.baseline.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.nb.baseline.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.nb.baseline.Ambient)
			end
		end
		if not st.toggleNB then
			st.toggleNB = function(on)
				st.initNB()
				st.nb.enabled = on
				if on then st.applyNB() else st.restoreNB() end
			end
		end
	end
	ensureNB()
	st.toggleNB(true)
end)

cmd.add({"unloopnight","unloopn","unln"},{"unloopnight","No more moonlight."},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	const function ensureNB()
		st.nb = st.nb or {init=false,enabled=false,baseline={},target={Brightness=1,ClockTime=0,FogEnd=786543,GlobalShadows=false,Ambient=Color3.fromRGB(178,178,178)}}
		if not st.restoreNB then
			st.restoreNB = function()
				st.safeSet(Services.Lighting,"Brightness",st.nb.baseline.Brightness)
				st.safeSet(Services.Lighting,"ClockTime",st.nb.baseline.ClockTime)
				st.safeSet(Services.Lighting,"FogEnd",st.nb.baseline.FogEnd)
				st.safeSet(Services.Lighting,"GlobalShadows",st.nb.baseline.GlobalShadows)
				st.safeSet(Services.Lighting,"Ambient",st.nb.baseline.Ambient)
			end
		end
	end
	ensureNB()
	if st.nb and st.nb.enabled then
		st.toggleNB(false)
	end
end)

cmd.add({"loopnoeffect","lnoeffect","loopne","lne"},{"loopnoeffect","Keeps Lighting and CurrentCamera effects disabled"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	const w = Services.Workspace
	st.ne = st.ne or {init=false,enabled=false,cache=NAmanage.ensureWeakKeyTable(nil),sticky=false}
	const ne = st.ne
	ne.cache = NAmanage.ensureWeakKeyTable(ne.cache)
	const function cacheProperty(inst,prop,value)
		if not inst then return end
		local saved = ne.cache[inst]
		if not saved then
			saved={}
			ne.cache[inst]=saved
		end
		if saved[prop]==nil then
			local v=value
			if v==nil then v=st.safeGet(inst,prop) end
			if v~=nil then saved[prop]=v end
		end
	end
	const function disableEffect(inst)
		if not inst or not inst.Parent then return end
		if inst:IsA("PostEffect") then
			const enabled=st.safeGet(inst,"Enabled")
			if enabled~=nil then
				cacheProperty(inst,"Enabled",enabled)
				if enabled~=false then st.safeSet(inst,"Enabled",false) end
			end
		end
		if inst:IsA("Atmosphere") then
			const density=st.safeGet(inst,"Density")
			if density~=nil then cacheProperty(inst,"Density",density); if density~=0 then st.safeSet(inst,"Density",0) end end
			const haze=st.safeGet(inst,"Haze")
			if haze~=nil then cacheProperty(inst,"Haze",haze); if haze~=0 then st.safeSet(inst,"Haze",0) end end
			const glare=st.safeGet(inst,"Glare")
			if glare~=nil then cacheProperty(inst,"Glare",glare); if glare~=0 then st.safeSet(inst,"Glare",0) end end
		end
	end
	const function processLighting()
		for _,inst in NAmanage.QueryDescendants(Services.Lighting, "Instance") do disableEffect(inst) end
	end
	const function processCamera()
		const cam = w.CurrentCamera
		if not cam then
			ne.lastCamera=nil
			return
		end
		if ne.lastCamera~=cam then
			ne.lastCamera=cam
		end
		for _,inst in NAmanage.QueryDescendants(cam, "Instance") do disableEffect(inst) end
	end
	const function attachCameraWatcher()
		if ne.camDescConn then
			pcall(function() ne.camDescConn:Disconnect() end)
			ne.camDescConn=nil
		end
		const cam = w.CurrentCamera
		if not cam then
			ne.lastCamera=nil
			return
		end
		ne.lastCamera = cam
		processCamera()
		local ok,conn=pcall(function()
			return NAmanage.descAdd(cam, function(child)
				if not (st.ne and st.ne.enabled) then return end
				if not ne.lastCamera or (child and not child:IsDescendantOf(ne.lastCamera)) then return end
				disableEffect(child)
			end)
		end)
		if ok and conn then
			ne.camDescConn=conn
		end
	end
	if not ne.init then
		ne.init=true
		st.hook("ne_camera_changed", function() return w:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				if not (st.ne and st.ne.enabled) then return end
				attachCameraWatcher()
			end) end)
		st.hook("ne_loop", function() return Services.RunService.RenderStepped:Connect(function()
				if not (st.ne and st.ne.enabled) then return end
				processLighting()
				processCamera()
			end) end)
	end
	ne.enabled=true
	ne.sticky=true
	processLighting()
	processCamera()
	attachCameraWatcher()
end)

cmd.add({"unloopnoeffect","unlnoeffect","unloopne","unlne"},{"unloopnoeffect","Restores Lighting and CurrentCamera effects"},function()
	if not Services.Lighting then return end
	const st = _na_env._LState
	if not st or not st.ne then return end
	const ne = st.ne
	ne.sticky=false
	ne.enabled=false
	if ne.camDescConn then
		pcall(function() ne.camDescConn:Disconnect() end)
		ne.camDescConn=nil
	end
	const cache = ne.cache
	if cache then
		for inst,saved in cache do
			if inst and inst.Parent and saved then
				for prop,value in saved do
					if st.safeSet then
						st.safeSet(inst,prop,value)
					else
						pcall(function() inst[prop]=value end)
					end
				end
			end
			cache[inst] = nil
		end
	end
end)

cmd.add({"noeffect","cleareffects","disableeffects"},{"noeffect","Disables Lighting and CurrentCamera effects"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	const function disableEffect(inst)
		if not inst then return end
		if inst:IsA("PostEffect") then
			const enabled=st.safeGet(inst,"Enabled")
			if enabled~=nil and enabled~=false then st.safeSet(inst,"Enabled",false) end
		end
		if inst:IsA("Atmosphere") then
			const density=st.safeGet(inst,"Density")
			if density~=nil and density~=0 then st.safeSet(inst,"Density",0) end
			const haze=st.safeGet(inst,"Haze")
			if haze~=nil and haze~=0 then st.safeSet(inst,"Haze",0) end
			const glare=st.safeGet(inst,"Glare")
			if glare~=nil and glare~=0 then st.safeSet(inst,"Glare",0) end
		end
	end
	for _,inst in NAmanage.QueryDescendants(Services.Lighting, "Instance") do disableEffect(inst) end
	const cam = Services.Workspace.CurrentCamera
	if cam then
		for _,inst in NAmanage.QueryDescendants(cam, "Instance") do disableEffect(inst) end
	end
end)

cmd.add({"loopnofog","lnofog","lnf","loopnf"},{"loopnofog","See clearly forever!"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	if st.disableNM then st.disableNM() end
	st.nf = st.nf or {init=false,enabled=false,baselineFogEnd=st.safeGet(Services.Lighting,"FogEnd") or 100000,baselineFogStart=st.safeGet(Services.Lighting,"FogStart") or 0,cache=NAmanage.ensureWeakKeyTable(nil),sticky=false}
	const nf = st.nf
	nf.cache = NAmanage.ensureWeakKeyTable(nf.cache)
	const function cacheOnce(inst, props)
		if nf.cache[inst] then return end
		const saved = {}
		for _,p in props do const v = st.safeGet(inst,p); if v~=nil then saved[p]=v end end
		nf.cache[inst]=saved
	end
	const function disableEffect(inst)
		if inst and inst:IsA("PostEffect") then cacheOnce(inst,{"Enabled"}); st.safeSet(inst,"Enabled",false) end
		if inst and inst:IsA("Atmosphere") then cacheOnce(inst,{"Density","Haze","Glare"}); st.safeSet(inst,"Density",0); st.safeSet(inst,"Haze",0); st.safeSet(inst,"Glare",0) end
	end
	const function enforceNoFog()
		if not (st.nf and st.nf.enabled) then return end
		st.safeSet(Services.Lighting,"FogEnd",786543)
		if st.safeGet(Services.Lighting,"FogStart") ~= nil then
			st.safeSet(Services.Lighting,"FogStart",0)
		end
		for inst,_ in nf.cache do
			if inst and inst.Parent then
				disableEffect(inst)
			end
		end
	end
	if not nf.init then
		nf.init = true
		local scanAccumulator = 0
		st.hook("nf_prop_end", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "FogEnd"):Connect(function()
				if st.nf and st.nf.enabled then
					if st.safeGet(Services.Lighting,"FogEnd") ~= 786543 then st.safeSet(Services.Lighting,"FogEnd",786543) end
				end
			end) end)
		st.hook("nf_prop_start", function() return __lt.cm("Lighting", "GetPropertyChangedSignal", "FogStart"):Connect(function()
				if st.nf and st.nf.enabled then
					if st.safeGet(Services.Lighting,"FogStart") ~= 0 then st.safeSet(Services.Lighting,"FogStart",0) end
				end
			end) end)
		st.hook("nf_added", function() return NAmanage.descAdd(Services.Lighting, function(inst)
				if not (st.nf and st.nf.enabled) then return end
				disableEffect(inst)
			end) end)
		st.hook("nf_loop", function() return Services.RunService.RenderStepped:Connect(function(dt)
				if not (st.nf and st.nf.enabled) then return end
				enforceNoFog()
				scanAccumulator = scanAccumulator + dt
				if scanAccumulator >= 0.5 then
					scanAccumulator = 0
					for _, inst in NAmanage.QueryDescendants(Services.Lighting, "Instance") do
						disableEffect(inst)
					end
				end
			end) end)
	end
	nf.enabled = true
	enforceNoFog()
	nf.sticky = true
	nf.baselineFogEnd = st.safeGet(Services.Lighting,"FogEnd") or nf.baselineFogEnd
	nf.baselineFogStart = st.safeGet(Services.Lighting,"FogStart") or nf.baselineFogStart
	st.safeSet(Services.Lighting,"FogEnd",786543)
	st.safeSet(Services.Lighting,"FogStart",0)
	for _,v in NAmanage.QueryDescendants(Services.Lighting, "Instance") do disableEffect(v) end
end)

cmd.add({"unloopnofog","unlnofog","unlnf","unloopnf","unnf"},{"unloopnofog","No more sight."},function()
	if not Services.Lighting then return end
	const st = _na_env._LState
	if not st or not st.nf then return end
	st.nf.sticky = false
	st.nf.enabled = false
	if not ((st.fb and st.fb.enabled) or (st.nb and st.nb.enabled)) then
		if st.safeSet then
			st.safeSet(Services.Lighting,"FogEnd",st.nf.baselineFogEnd or 100000)
			if st.safeGet(Services.Lighting,"FogStart")~=nil then
				st.safeSet(Services.Lighting,"FogStart",st.nf.baselineFogStart or 0)
			end
		end
	end
	const cache = st.nf.cache
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
end)

cmd.add({"nofog"},{"nofog","Removes all fog from the game"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	const function disableEffect(inst)
		if inst and inst:IsA("PostEffect") then st.safeSet(inst,"Enabled",false) end
		if inst and inst:IsA("Atmosphere") then
			if st.safeGet(inst,"Density")~=nil then st.safeSet(inst,"Density",0) end
			if st.safeGet(inst,"Haze")~=nil then st.safeSet(inst,"Haze",0) end
			if st.safeGet(inst,"Glare")~=nil then st.safeSet(inst,"Glare",0) end
		end
	end
	st.safeSet(Services.Lighting,"FogEnd",786543)
	if st.safeGet(Services.Lighting,"FogStart")~=nil then st.safeSet(Services.Lighting,"FogStart",0) end
	for _,v in NAmanage.QueryDescendants(Services.Lighting, "Instance") do disableEffect(v) end
end)

cmd.add({"nightmare","nm"},{"nightmare","Make it dark and spooky"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	if not st.disableNM then
		const prevCancel = st.cancelFor
		st.disableNM = function()
			NAlib.disconnect("nm_brightness")
			NAlib.disconnect("nm_clocktime")
			NAlib.disconnect("nm_fogstart")
			NAlib.disconnect("nm_fogend")
			NAlib.disconnect("nm_shadows")
			NAlib.disconnect("nm_ambient")
			NAlib.disconnect("nm_loop")
			if st.nm and st.nm.enabled then
				if st.restoreNM then st.restoreNM() end
				st.nm.enabled = false
			end
		end
		st.cancelFor = function(mode)
			if prevCancel then prevCancel(mode) end
			if mode=="nm" then
				st.disableTimeLoops()
				if st.disableNB then st.disableNB() end
				st.disableFB()
				st.disableNF(true)
				st.disableNM()
			end
		end
	end
	st.cancelFor("nm")
	st.nm = st.nm or {enabled=false,baseline={},target={Brightness=0.4,ClockTime=0,FogStart=0,FogEnd=28,GlobalShadows=true,Ambient=Color3.fromRGB(50,50,65)},effects={}}
	const function ensureEffect(className, key)
		const name = "NA_nm_"..key
		local inst = __lt.cm("Lighting", "FindFirstChild", name)
		if not inst then inst = InstanceNew(className); inst.Name = name; inst.Parent = Services.Lighting end
		st.nm.effects[key] = inst
		return inst
	end
	if not st.captureNM then
		st.captureNM = function()
			st.nm.baseline = {
				Brightness = st.safeGet(Services.Lighting,"Brightness") or 2,
				ClockTime = st.safeGet(Services.Lighting,"ClockTime") or 12,
				FogStart = st.safeGet(Services.Lighting,"FogStart"),
				FogEnd = st.safeGet(Services.Lighting,"FogEnd") or 100000,
				GlobalShadows = st.safeGet(Services.Lighting,"GlobalShadows"),
				Ambient = st.safeGet(Services.Lighting,"Ambient") or Color3.fromRGB(128,128,128)
			}
		end
	end
	if not st.applyNM then
		st.applyNM = function()
			st.captureNM()
			st.safeSet(Services.Lighting,"Brightness",st.nm.target.Brightness)
			st.safeSet(Services.Lighting,"ClockTime",st.nm.target.ClockTime)
			if st.safeGet(Services.Lighting,"FogStart")~=nil then st.safeSet(Services.Lighting,"FogStart",st.nm.target.FogStart) end
			st.safeSet(Services.Lighting,"FogEnd",st.nm.target.FogEnd)
			const gs = st.safeGet(Services.Lighting,"GlobalShadows"); if gs~=nil then st.safeSet(Services.Lighting,"GlobalShadows",st.nm.target.GlobalShadows) end
			st.safeSet(Services.Lighting,"Ambient",st.nm.target.Ambient)
			const cc = ensureEffect("ColorCorrectionEffect","cc")
			st.safeSet(cc,"Enabled",true)
			st.safeSet(cc,"Brightness",-0.05)
			st.safeSet(cc,"Contrast",0.2)
			st.safeSet(cc,"Saturation",-0.25)
			st.safeSet(cc,"TintColor",Color3.fromRGB(180,170,255))
			const bloom = ensureEffect("BloomEffect","bloom")
			st.safeSet(bloom,"Enabled",true)
			st.safeSet(bloom,"Intensity",0.15)
			st.safeSet(bloom,"Size",20)
			const dof = ensureEffect("DepthOfFieldEffect","dof")
			st.safeSet(dof,"Enabled",true)
			st.safeSet(dof,"NearIntensity",0.15)
			st.safeSet(dof,"FarIntensity",0.6)
			st.safeSet(dof,"FocusDistance",25)
			st.safeSet(dof,"InFocusRadius",14)
			const blur = ensureEffect("BlurEffect","blur")
			st.safeSet(blur,"Enabled",true)
			st.safeSet(blur,"Size",1)
		end
	end
	if not st.restoreNM then
		st.restoreNM = function()
			st.safeSet(Services.Lighting,"Brightness",st.nm.baseline.Brightness)
			st.safeSet(Services.Lighting,"ClockTime",st.nm.baseline.ClockTime)
			if st.nm.baseline.FogStart~=nil then st.safeSet(Services.Lighting,"FogStart",st.nm.baseline.FogStart) end
			st.safeSet(Services.Lighting,"FogEnd",st.nm.baseline.FogEnd)
			if st.nm.baseline.GlobalShadows~=nil then st.safeSet(Services.Lighting,"GlobalShadows",st.nm.baseline.GlobalShadows) end
			st.safeSet(Services.Lighting,"Ambient",st.nm.baseline.Ambient)
			for _,inst in st.nm.effects do if inst and inst.Parent then inst:Destroy() end end
			st.nm.effects = {}
		end
	end
	const function rehookNM()
		NAlib.disconnect("nm_brightness")
		NAlib.disconnect("nm_clocktime")
		NAlib.disconnect("nm_fogstart")
		NAlib.disconnect("nm_fogend")
		NAlib.disconnect("nm_shadows")
		NAlib.disconnect("nm_ambient")
		NAlib.disconnect("nm_loop")
		NAlib.connect("nm_brightness", __lt.cm("Lighting", "GetPropertyChangedSignal", "Brightness"):Connect(function()
			if st.nm and st.nm.enabled and st.safeGet(Services.Lighting,"Brightness") ~= st.nm.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.nm.target.Brightness) end
		end))
		NAlib.connect("nm_clocktime", __lt.cm("Lighting", "GetPropertyChangedSignal", "ClockTime"):Connect(function()
			if st.nm and st.nm.enabled and st.safeGet(Services.Lighting,"ClockTime") ~= st.nm.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.nm.target.ClockTime) end
		end))
		NAlib.connect("nm_fogstart", __lt.cm("Lighting", "GetPropertyChangedSignal", "FogStart"):Connect(function()
			if st.nm and st.nm.enabled then const fs = st.safeGet(Services.Lighting,"FogStart"); if fs==nil or fs ~= st.nm.target.FogStart then st.safeSet(Services.Lighting,"FogStart",st.nm.target.FogStart) end end
		end))
		NAlib.connect("nm_fogend", __lt.cm("Lighting", "GetPropertyChangedSignal", "FogEnd"):Connect(function()
			if st.nm and st.nm.enabled and st.safeGet(Services.Lighting,"FogEnd") ~= st.nm.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.nm.target.FogEnd) end
		end))
		NAlib.connect("nm_shadows", __lt.cm("Lighting", "GetPropertyChangedSignal", "GlobalShadows"):Connect(function()
			if st.nm and st.nm.enabled then const gs = st.safeGet(Services.Lighting,"GlobalShadows"); if gs==nil or gs ~= st.nm.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.nm.target.GlobalShadows) end end
		end))
		NAlib.connect("nm_ambient", __lt.cm("Lighting", "GetPropertyChangedSignal", "Ambient"):Connect(function()
			if st.nm and st.nm.enabled and st.safeGet(Services.Lighting,"Ambient") ~= st.nm.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.nm.target.Ambient) end
		end))
		NAlib.connect("nm_loop", Services.RunService.RenderStepped:Connect(function()
			if not (st.nm and st.nm.enabled) then return end
			if st.safeGet(Services.Lighting,"Brightness") ~= st.nm.target.Brightness then st.safeSet(Services.Lighting,"Brightness",st.nm.target.Brightness) end
			if st.safeGet(Services.Lighting,"ClockTime") ~= st.nm.target.ClockTime then st.safeSet(Services.Lighting,"ClockTime",st.nm.target.ClockTime) end
			const fs = st.safeGet(Services.Lighting,"FogStart"); if fs==nil or fs ~= st.nm.target.FogStart then st.safeSet(Services.Lighting,"FogStart",st.nm.target.FogStart) end
			if st.safeGet(Services.Lighting,"FogEnd") ~= st.nm.target.FogEnd then st.safeSet(Services.Lighting,"FogEnd",st.nm.target.FogEnd) end
			const gs = st.safeGet(Services.Lighting,"GlobalShadows"); if gs==nil or gs ~= st.nm.target.GlobalShadows then st.safeSet(Services.Lighting,"GlobalShadows",st.nm.target.GlobalShadows) end
			if st.safeGet(Services.Lighting,"Ambient") ~= st.nm.target.Ambient then st.safeSet(Services.Lighting,"Ambient",st.nm.target.Ambient) end
			ensureEffect("ColorCorrectionEffect","cc")
			ensureEffect("BloomEffect","bloom")
			ensureEffect("DepthOfFieldEffect","dof")
			ensureEffect("BlurEffect","blur")
			const cc = st.nm.effects.cc
			if cc then
				if st.safeGet(cc,"Enabled") ~= true then st.safeSet(cc,"Enabled",true) end
				if st.safeGet(cc,"Brightness") ~= -0.05 then st.safeSet(cc,"Brightness",-0.05) end
				if st.safeGet(cc,"Contrast") ~= 0.2 then st.safeSet(cc,"Contrast",0.2) end
				if st.safeGet(cc,"Saturation") ~= -0.25 then st.safeSet(cc,"Saturation",-0.25) end
				if st.safeGet(cc,"TintColor") ~= Color3.fromRGB(180,170,255) then st.safeSet(cc,"TintColor",Color3.fromRGB(180,170,255)) end
			end
			const bloom = st.nm.effects.bloom
			if bloom then
				if st.safeGet(bloom,"Enabled") ~= true then st.safeSet(bloom,"Enabled",true) end
				if st.safeGet(bloom,"Intensity") ~= 0.15 then st.safeSet(bloom,"Intensity",0.15) end
				if st.safeGet(bloom,"Size") ~= 20 then st.safeSet(bloom,"Size",20) end
			end
			const dof = st.nm.effects.dof
			if dof then
				if st.safeGet(dof,"Enabled") ~= true then st.safeSet(dof,"Enabled",true) end
				if st.safeGet(dof,"NearIntensity") ~= 0.15 then st.safeSet(dof,"NearIntensity",0.15) end
				if st.safeGet(dof,"FarIntensity") ~= 0.6 then st.safeSet(dof,"FarIntensity",0.6) end
				if st.safeGet(dof,"FocusDistance") ~= 25 then st.safeSet(dof,"FocusDistance",25) end
				if st.safeGet(dof,"InFocusRadius") ~= 14 then st.safeSet(dof,"InFocusRadius",14) end
			end
			const blur = st.nm.effects.blur
			if blur then
				if st.safeGet(blur,"Enabled") ~= true then st.safeSet(blur,"Enabled",true) end
				if st.safeGet(blur,"Size") ~= 1 then st.safeSet(blur,"Size",1) end
			end
		end))
	end
	st.nm.enabled = true
	st.applyNM()
	rehookNM()
end)

cmd.add({"unnightmare","unnm"},{"unnightmare (unnm)","Disable nightmare mode"},function()
	if not Services.Lighting then return end
	const st = NAmanage._ensureL()
	if st.disableNM then st.disableNM() end
end)

cmd.add({"brightness"},{"brightness <number>","Changes the brightness lighting property"},function(num)
	loopBrightnessValue = tonumber(num)
	Services.Lighting.Brightness = loopBrightnessValue
end,true)

cmd.add({"loopbrightness","loopbri","loopb"},{"loopbrightness (loopbri,loopb)","Lock the brightness lighting property"},function(num)
	loopBrightnessValue = tonumber(num)
	NAlib.disconnect("loopbrightness")
	Services.Lighting.Brightness = loopBrightnessValue
	NAlib.connect("loopbrightness", __lt.cm("Lighting", "GetPropertyChangedSignal", "Brightness"):Connect(function()
		if Services.Lighting.Brightness ~= loopBrightnessValue then
			Services.Lighting.Brightness = loopBrightnessValue
		end
	end))
end,true)

cmd.add({"unloopbrightness","unloopbri","unloopb"},{"unloopbrightness (unloopbri,unloopb)","Stop locking brightness"},function()
	NAlib.disconnect("loopbrightness")
end)

cmd.add({"globalshadows","gshadows"},{"globalshadows","Enables global shadows"},function()
	Services.Lighting.GlobalShadows=true
end)

cmd.add({"unglobalshadows","nogshadows","ungshadows","noglobalshadows"},{"unglobalshadows (nogshadows,ungshadows,noglobalshadows)","Disables global shadows"},function()
	Services.Lighting.GlobalShadows=false
end)

cmd.add({"gamma", "exposure"},{"gamma (exposure)","gamma vision (real)"},function(num)
	expose = tonumber(num) or 0
	Services.Lighting.ExposureCompensation = expose
end,true)

cmd.add({"loopgamma", "loopexposure"},{"loopgamma (loopexposure)","loop gamma vision (mega real)"},function(num)
	expose = tonumber(num) or 0
	NAlib.disconnect("loopgamma")
	Services.Lighting.ExposureCompensation = expose
	NAlib.connect("loopgamma", __lt.cm("Lighting", "GetPropertyChangedSignal", "ExposureCompensation"):Connect(function()
		if Services.Lighting.ExposureCompensation ~= expose then
			Services.Lighting.ExposureCompensation = expose
		end
	end))
end, true)

cmd.add({"unloopgamma", "unlgamma", "unloopexposure", "unlexposure"},{"unloopgamma (unlgamma, unloopexposure, unlexposure)","stop gamma vision (real)"},function()
	NAlib.disconnect("loopgamma")
end)

cmd.add({"firstp","1stp","firstperson","fp"},{"firstperson (1stp,firstp,fp)","Makes you go in first person mode"},function()
	Player.CameraMode="LockFirstPerson"
end)

cmd.add({"thirdp","3rdp","thirdperson"},{"thirdperson (3rdp,thirdp)","Makes you go in third person mode"},function()
	Player.CameraMaxZoomDistance=math.huge
	Player.CameraMode="Classic"
end)

NAStuff.loopZoomState = NAStuff.loopZoomState or {}
NAStuff.loopZoomState.maxApply = false
NAStuff.loopZoomState.minApply = false

originalIO.applyLoopMaxZoom=function()
	const z = NAStuff.loopZoomState
	if not z or z.max == nil or z.maxApply then return true end
	const p = Services.Players.LocalPlayer
	if not p then return false end
	if p.CameraMaxZoomDistance ~= z.max then
		z.maxApply = true
		local ok, err = pcall(function()
			p.CameraMaxZoomDistance = z.max
		end)
		z.maxApply = false
		if not ok then
			z.max = nil
			NAlib.disconnect("loopmaxzoom")
			DoNotif("Max zoom loop failed: "..tostring(err),3)
			return false
		end
	end
	return true
end

originalIO.applyLoopMinZoom=function()
	const z = NAStuff.loopZoomState
	if not z or z.min == nil or z.minApply then return true end
	const p = Services.Players.LocalPlayer
	if not p then return false end
	if p.CameraMinZoomDistance ~= z.min then
		z.minApply = true
		local ok, err = pcall(function()
			p.CameraMinZoomDistance = z.min
		end)
		z.minApply = false
		if not ok then
			z.min = nil
			NAlib.disconnect("loopminzoom")
			DoNotif("Min zoom loop failed: "..tostring(err),3)
			return false
		end
	end
	return true
end

originalIO.startLoopMaxZoom=function(num)
	NAStuff.loopZoomState = NAStuff.loopZoomState or {}
	NAStuff.loopZoomState.max = num
	NAStuff.loopZoomState.maxApply = false
	NAlib.disconnect("loopmaxzoom")
	const p = Services.Players.LocalPlayer
	if p then
		if not originalIO.applyLoopMaxZoom() then return end
		if NAStuff.loopZoomState.max ~= nil then
			NAlib.connect("loopmaxzoom", p:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(originalIO.applyLoopMaxZoom))
		end
	end
	DoNotif("Max zoom loop set to "..tostring(num),2)
end

originalIO.startLoopMinZoom=function(num)
	NAStuff.loopZoomState = NAStuff.loopZoomState or {}
	NAStuff.loopZoomState.min = num
	NAStuff.loopZoomState.minApply = false
	NAlib.disconnect("loopminzoom")
	const p = Services.Players.LocalPlayer
	if p then
		if not originalIO.applyLoopMinZoom() then return end
		if NAStuff.loopZoomState.min ~= nil then
			NAlib.connect("loopminzoom", p:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(originalIO.applyLoopMinZoom))
		end
	end
	DoNotif("Min zoom loop set to "..tostring(num),2)
end

originalIO.stopLoopMaxZoom=function()
	if NAStuff.loopZoomState then
		NAStuff.loopZoomState.max = nil
		NAStuff.loopZoomState.maxApply = false
	end
	NAlib.disconnect("loopmaxzoom")
end

originalIO.stopLoopMinZoom=function()
	if NAStuff.loopZoomState then
		NAStuff.loopZoomState.min = nil
		NAStuff.loopZoomState.minApply = false
	end
	NAlib.disconnect("loopminzoom")
end

cmd.add({"maxzoom"},{"maxzoom <amount>","Set your maximum camera distance"},function(num)
	const num=tonumber(num) or 128
	Services.Players.LocalPlayer.CameraMaxZoomDistance=num
end,true)

cmd.add({"minzoom"},{"minzoom <amount>","Set your minimum camera distance"},function(...)
	const args={...}
	local num=args[1]

	if num==nil then
		num=0
	else
		num=tonumber(num)
	end
	Services.Players.LocalPlayer.CameraMinZoomDistance=num
end,true)

cmd.add({"loopmaxzoom","lmaxzoom","lmzoom","lmz","forcemaxzoom","fmaxzoom"},{"loopmaxzoom <amount> (lmaxzoom,lmzoom,lmz,forcemaxzoom,fmaxzoom)","Loop your maximum camera distance and restore it when changed"},function(num)
	const num=tonumber(num) or 128
	originalIO.startLoopMaxZoom(num)
end,true)

cmd.add({"unloopmaxzoom","unlmaxzoom","unlmzoom","unlmz","unforcemaxzoom","unfmaxzoom"},{"unloopmaxzoom (unlmaxzoom,unlmzoom,unlmz,unforcemaxzoom,unfmaxzoom)","Stop looping your maximum camera distance"},function()
	if NAStuff.loopZoomState and NAStuff.loopZoomState.max ~= nil then
		originalIO.stopLoopMaxZoom()
		DoNotif("Max zoom loop disabled",2)
	else
		DoNotif("Max zoom loop is already off",2)
	end
end)

cmd.add({"loopminzoom","lminzoom","lnzoom","lnz","forceminzoom","fminzoom"},{"loopminzoom <amount> (lminzoom,lnzoom,lnz,forceminzoom,fminzoom)","Loop your minimum camera distance and restore it when changed"},function(...)
	const args={...}
	local num=args[1]

	if num==nil then
		num=0
	else
		num=tonumber(num) or 0
	end
	originalIO.startLoopMinZoom(num)
end,true)

cmd.add({"unloopminzoom","unlminzoom","unlnzoom","unlnz","unforceminzoom","unfminzoom"},{"unloopminzoom (unlminzoom,unlnzoom,unlnz,unforceminzoom,unfminzoom)","Stop looping your minimum camera distance"},function()
	if NAStuff.loopZoomState and NAStuff.loopZoomState.min ~= nil then
		originalIO.stopLoopMinZoom()
		DoNotif("Min zoom loop disabled",2)
	else
		DoNotif("Min zoom loop is already off",2)
	end
end)

cmd.add({"cameranoclip","camnoclip","cnoclip","nccam"},{"cameranoclip (camnoclip,cnoclip,nccam)","Makes your camera clip through walls"}, function()
	const player = Services.Players.LocalPlayer
	const camera = Services.Workspace.CurrentCamera

	const SetConstant = (debug and debug.setconstant) or setconstant
	const GetConstants = (debug and debug.getconstants) or getconstants
	const HasAdvancedAccess = (getgc and SetConstant and GetConstants)

	const function useAdvancedMode()
		if not HasAdvancedAccess then return end
		const PlayerModule = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("PlayerModule")
		const Popper = PlayerModule and PlayerModule:FindFirstChild("CameraModule") and PlayerModule.CameraModule:FindFirstChild("ZoomController") and PlayerModule.CameraModule.ZoomController:FindFirstChild("Popper")

		if Popper then
			for i, v in getgc() do
				if type(v) == "function" and getfenv(v).script == Popper then
					for i2, v2 in GetConstants(v) do
						if tonumber(v2) == 0.25 then
							SetConstant(v, i2, 0)
						elseif tonumber(v2) == 0 then
							SetConstant(v, i2, 0.25)
						end
					end
				end
			end
		end
	end

	const function useInvisCamMode()
		if NAlib.isConnected("ilovesolara") then
			NAlib.disconnect("ilovesolara")
			player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
			return
		end
		NAlib.connect("ilovesolara", player:GetPropertyChangedSignal("DevCameraOcclusionMode"):Connect(function()
			if player.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam then
				player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
			end
		end))
		player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	end

	const currentMode = NAStuff.cameranoclipMode
	if currentMode == "advanced" then
		useAdvancedMode()
		NAStuff.cameranoclipMode = nil
		return
	elseif currentMode == "invis" then
		useInvisCamMode()
		NAStuff.cameranoclipMode = nil
		return
	elseif NAlib.isConnected("ilovesolara") then
		useInvisCamMode()
		NAStuff.cameranoclipMode = nil
		return
	end

	if not HasAdvancedAccess then
		useInvisCamMode()
		NAStuff.cameranoclipMode = "invis"
		return
	end

	const show = Window or DoWindow
	const buttons = {
		{
			Text = "Invisicam (DevCameraOcclusionMode.Invisicam)",
			Callback = function()
				useInvisCamMode()
				NAStuff.cameranoclipMode = "invis"
			end
		},
		{
			Text = "Current method (Popper getgc tweak)",
			Callback = function()
				useAdvancedMode()
				NAStuff.cameranoclipMode = "advanced"
			end
		},
	}

	if type(show) == "function" then
		show({
			Title = "Camera noclip mode",
			Description = "Choose how cameranoclip should behave.",
			Buttons = buttons
		})
	else
		useAdvancedMode()
		NAStuff.cameranoclipMode = "advanced"
	end
end)

cmd.add({"uncameranoclip","uncamnoclip","uncnoclip","unnccam"},{"uncameranoclip (uncamnoclip,uncnoclip,unnccam)","Restores normal camera"}, function()
	const player = Services.Players.LocalPlayer
	const camera = Services.Workspace.CurrentCamera

	const SetConstant = (debug and debug.setconstant) or setconstant
	const GetConstants = (debug and debug.getconstants) or getconstants
	const HasAdvancedAccess = (getgc and SetConstant and GetConstants)

	const mode = NAStuff.cameranoclipMode
	NAStuff.cameranoclipMode = nil

	if mode == "advanced" and HasAdvancedAccess then
		const PlayerModule = player:FindFirstChild("PlayerScripts") and player.PlayerScripts:FindFirstChild("PlayerModule")
		const Popper = PlayerModule and PlayerModule:FindFirstChild("CameraModule") and PlayerModule.CameraModule:FindFirstChild("ZoomController") and PlayerModule.CameraModule.ZoomController:FindFirstChild("Popper")

		if Popper then
			for i, v in getgc() do
				if type(v) == "function" and getfenv(v).script == Popper then
					for i2, v2 in GetConstants(v) do
						if tonumber(v2) == 0.25 then
							SetConstant(v, i2, 0)
						elseif tonumber(v2) == 0 then
							SetConstant(v, i2, 0.25)
						end
					end
				end
			end
		end
	end

	if NAlib.isConnected("ilovesolara") then
		NAlib.disconnect("ilovesolara")
	end

	if player and player.DevCameraOcclusionMode then
		player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
	end
end)

cmd.add({"oganims"},{"oganims","Old animations from 2007"},function()
	Wait();
	DebugNotif("OG animations set")
	NAmanage.RunURL(('https://pastebin.com/raw/6GNkQUu6'),true)
end)

cmd.add({"fakechat"},{"fakechat","Fake a chat gui"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/fake%20chatte")
end)

cmd.add({"fpscap"},{"fpscap <number>","Sets the fps cap to whatever you want"},function(arg)
	const cap = tonumber(arg)
	if cap then
		setfpscap(math.clamp(cap, 1, 999))
	else
		DoNotif("invalid input",1.3)
	end
end,true)

cmd.add({"toolinvisible", "tinvis"}, {"toolinvisible (tinvis)", "Be invisible while still being able to use tools"}, function()
	const offset = 1100
	invisible = false
	const grips = {}
	local heldTool
	local gripChanged
	local handle
	local weld
	HH = getHum().HipHeight

	function setDisplayDistance(distance)
		for _, player in __lt.cm("Players", "GetPlayers") do
			if getPlrChar(player) and getPlrHum(player) then
				getPlrHum(player).NameDisplayDistance = distance
				getPlrHum(player).HealthDisplayDistance = distance
			end
		end
	end

	const tool = InstanceNew("Tool", Services.Players.LocalPlayer.Backpack)
	tool.Name = "Turn Invisible"
	tool.RequiresHandle = false
	tool.CanBeDropped = false

	tool.Equipped:Connect(function()
		Wait()
		if not invisible then
			invisible = true
			tool.Name = "Visible Enabled"

			if handle then
				handle:Destroy()
			end
			if weld then
				weld:Destroy()
			end

			handle = InstanceNew("Part", Services.Workspace)
			handle.Name = "Handle"
			handle.Transparency = 1
			handle.CanCollide = false
			handle.Size = Vector3.new(2, 1, 1)

			weld = InstanceNew("Weld", handle)
			weld.Part0 = handle
			weld.Part1 = getRoot(getChar())
			weld.C0 = CFrame.new(0, offset - 1.5, 0)

			setDisplayDistance(offset + 100)
			Services.Workspace.CurrentCamera.CameraSubject = handle
			getRoot(getChar()).CFrame = getRoot(getChar()).CFrame * CFrame.new(0, offset, 0)
			getHum().HipHeight = offset
			getHum():ChangeState(11)

			for _, child in Services.Players.LocalPlayer.Backpack:GetChildren() do
				if child:IsA("Tool") and child ~= tool then
					grips[child] = child.Grip
				end
			end
			if getHum() then
				getHum():SetStateEnabled("Seated", false)
				getHum().Sit = true
			end
		else
			invisible = false
			tool.Name = "Visible Disabled"

			if handle then
				handle:Destroy()
			end
			if weld then
				weld:Destroy()
			end

			for _, child in getChar():GetChildren() do
				if child:IsA("Tool") then
					child.Parent = Services.Players.LocalPlayer.Backpack
				end
			end

			for tool, grip in grips do
				if tool then
					tool.Grip = grip
				end
			end

			heldTool = nil
			setDisplayDistance(100)
			Services.Workspace.CurrentCamera.CameraSubject = getHum()
			getRoot(getChar()).CFrame = getRoot(getChar()).CFrame * CFrame.new(0, -offset, 0)
			getHum().HipHeight = HH

			if getHum() then
				getHum():SetStateEnabled("Seated", true)
				getHum().Sit = false
			end
		end

		tool.Parent = Services.Players.LocalPlayer.Backpack
	end)

	NAmanage.childAdd(getChar(), function(child)
		Wait()
		if invisible and child:IsA("Tool") and child ~= heldTool and child ~= tool then
			heldTool = child
			local lastGrip = heldTool.Grip

			if not grips[heldTool] then
				grips[heldTool] = lastGrip
			end

			for _, track in getHum():GetPlayingAnimationTracks() do
				track:Stop()
			end

			getChar().Animate.Disabled = true
			heldTool.Grip = heldTool.Grip * (CFrame.new(0, offset - 1.5, 1.5) * CFrame.Angles(math.rad(-90), 0, 0))
			heldTool.Parent = Services.Players.LocalPlayer.Backpack
			heldTool.Parent = getChar()

			if gripChanged then
				gripChanged:Disconnect()
			end

			gripChanged = heldTool:GetPropertyChangedSignal("Grip"):Connect(function()
				Wait()
				if not invisible then
					gripChanged:Disconnect()
				end

				if heldTool.Grip ~= lastGrip then
					lastGrip = heldTool.Grip * (CFrame.new(0, offset - 1.5, 1.5) * CFrame.Angles(math.rad(-90), 0, 0))
					heldTool.Grip = lastGrip
					heldTool.Parent = Services.Players.LocalPlayer.Backpack
					heldTool.Parent = getChar()
				end
			end)
		end
	end, function(child)
		return child and child:IsA("Tool")
	end)
end)

invisBtnlol = nil
invisKeybindConnection = nil
IsInvis = false
InvisibleCharacter = nil
OriginalPosition = nil
InvisBindLol = Enum.KeyCode.E

cmd.add({"invisible", "invis"},{"invisible (invis)", "Sets invisibility to scare people or something"}, function()
	if invisKeybindConnection then
		DebugNotif("Invisibility is already loaded!")
		return
	end

	const Character = Services.Players.LocalPlayer.Character or Services.Players.LocalPlayer.CharacterAdded:Wait()
	Character.Archivable = true
	OriginalPosition = getRoot(Character).CFrame

	const function TurnVisible()
		if not IsInvis then return end
		IsInvis = false
		OriginalPosition = getRoot(InvisibleCharacter).CFrame
		if InvisibleCharacter then
			InvisibleCharacter:Destroy()
			InvisibleCharacter = nil
		end
		Services.Players.LocalPlayer.Character = Character
		Character.Parent = Services.Workspace
		Services.RunService.Heartbeat:Wait()
		const root = getRoot(Character)
		if root then
			NAmanage.UG_setRootCFrame(root, OriginalPosition)
		end
		DebugNotif("Invisibility turned off.")
		__lt.cm("StarterGui", "SetCore", "ResetButtonCallback", true)
	end

	const function ToggleInvisibility()
		if not IsInvis then
			IsInvis = true
			InvisibleCharacter = Character:Clone()
			InvisibleCharacter.Parent = Services.Workspace
			for _, v in InvisibleCharacter:QueryDescendants("BasePart") do
				v.Transparency = v.Name:lower() == "humanoidrootpart" and 1 or 0.5
			end
			const root = getRoot(Character)
			if root then
				OriginalPosition = root.CFrame
				NAmanage.UG_setRootCFrame(root, CFrame.new(0, math.pi * 1000000, 0))
			end
			Wait(0.1)
			Character.Parent = Services.ReplicatedStorage
			const invisRoot = getRoot(InvisibleCharacter)
			if invisRoot then
				invisRoot.CFrame = OriginalPosition
			end
			Services.Players.LocalPlayer.Character = InvisibleCharacter
			Services.Workspace.CurrentCamera.CameraSubject = getPlrHum(InvisibleCharacter)
			DebugNotif("You are now invisible.")
			__lt.cm("StarterGui", "SetCore", "ResetButtonCallback", false)
		else
			TurnVisible()
		end
	end

	if invisKeybindConnection then
		invisKeybindConnection:Disconnect()
		invisKeybindConnection = nil
	end

	invisKeybindConnection = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == InvisBindLol and not gameProcessed then
			ToggleInvisibility()
		end
	end)

	const humanoid = getPlrHum(Character)
	if humanoid then
		NAmanage.ConnectHumanoidDeath(humanoid, function()
			cmd.run({"vis"})
		end)
	end

	if IsOnMobile then
		if invisBtnlol then invisBtnlol:Destroy() invisBtnlol = nil end
		invisBtnlol = InstanceNew("ScreenGui")
		const TextButton = InstanceNew("TextButton")
		const UICorner = InstanceNew("UICorner")
		UICorner.CornerRadius = UDim.new(0, 6)
		const UIAspectRatioConstraint = InstanceNew("UIAspectRatioConstraint")
		NAgui.NaProtectUI(invisBtnlol)
		invisBtnlol.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		TextButton.Parent = invisBtnlol
		TextButton.BackgroundColor3 = Color3.fromRGB(12, 4, 20)
		TextButton.BackgroundTransparency = 0.14
		TextButton.Position = UDim2.new(0.9, 0, 0.8, 0)
		TextButton.Size = UDim2.new(0.1, 0, 0.1, 0)
		TextButton.Font = Enum.Font.SourceSansBold
		TextButton.Text = "Invisible"
		TextButton.TextColor3 = Color3.new(1, 1, 1)
		TextButton.TextSize = 15
		TextButton.TextWrapped = true
		TextButton.TextScaled = true
		TextButton.Active = true
		UICorner.Parent = TextButton
		UIAspectRatioConstraint.Parent = TextButton
		UIAspectRatioConstraint.AspectRatio = 1
		NAgui.draggerV2(TextButton)
		MouseButtonFix(TextButton, function()
			ToggleInvisibility()
			TextButton.Text = IsInvis and "Visible" or "Invisible"
		end)
	end

	Wait()
	DebugNotif("Invisible loaded. Press "..InvisBindLol.Name.." or use the mobile button",2.5)
end)

cmd.add({"visible", "vis"}, {"visible", "turn visible"}, function()
	if invisKeybindConnection then
		invisKeybindConnection:Disconnect()
		invisKeybindConnection = nil
	end
	if invisBtnlol then
		invisBtnlol:Destroy()
		invisBtnlol = nil
	end
	const Character = Services.Players.LocalPlayer.Character or Services.Players.LocalPlayer.CharacterAdded:Wait()
	if IsInvis then
		IsInvis = false
		if InvisibleCharacter then InvisibleCharacter:Destroy() InvisibleCharacter = nil end
		Services.Players.LocalPlayer.Character = Character
		Character.Parent = Services.Workspace
	end
	DebugNotif("Invisibility Disabled",2)
end)

cmd.add({"invisbind", "invisiblebind","bindinvis"}, {"invisbind (invisiblebind, bindinvis)", "set a custom keybind for the 'Invisible' command"}, function(...)
	const args = {...}
	if args[1] then
		InvisBindLol = Enum.KeyCode[args[1]] or Enum.KeyCode[args[1]:upper()]
		if InvisBindLol then
			DebugNotif("Invis bind set to "..InvisBindLol.Name)
		else
			DebugNotif("Invalid keybind, defaulting to E")
			InvisBindLol = Enum.KeyCode.E
		end
	else
		DebugNotif("No keybind provided")
	end
end,true)

cmd.add({"fireremote", "fremote", "frmt"}, {"fireremote [select|remote name/full name] (fremote, frmt)", "Fire one remote by selection, name, or full path"}, function(...)
	const RawCoreGui = __lt.gs("CoreGui")
	const args = {...}
	local q = Concat(args, " ")
	q = (tostring(q or ""):gsub("^%s+", ""):gsub("%s+$", ""))

	const function isRem(r)
		return typeof(r) == "Instance" and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") or r:IsA("RemoteFunction"))
	end

	const function full(r)
		local ok, res = pcall(function()
			return r:GetFullName()
		end)
		return ok and tostring(res or r.Name) or tostring(r and r.Name or "Remote")
	end

	const function norm(v)
		v = tostring(v or ""):gsub("^%s+", ""):gsub("%s+$", "")
		v = Lower(v)
		v = v:gsub("^game%.", "")
		return v
	end

	const function scan()
		const list, seen = {}, {}
		const qlist = {game}
		local qi, qn = 1, 1
		local hit = 0

		while qi <= qn do
			const inst = qlist[qi]
			qlist[qi] = nil
			qi += 1

			if typeof(inst) == "Instance" and inst ~= RawCoreGui then
				if isRem(inst) and not seen[inst] then
					seen[inst] = true
					list[#list + 1] = inst
				end

				local ok, ch = pcall(function()
					return inst:GetChildren()
				end)
				if ok and type(ch) == "table" then
					for i = 1, #ch do
						const c = ch[i]
						if c ~= RawCoreGui then
							qn += 1
							qlist[qn] = c
						end
					end
				end
			end

			hit += 1
			if hit >= 180 then
				hit = 0
				Wait()
			end
		end

		table.sort(list, function(a, b)
			return full(a) < full(b)
		end)

		return list
	end

	const function fire(r)
		if not isRem(r) or not NAmanage.isLiveInstance(r) then
			DebugNotif("Remote is no longer available.", 3, "Fire Remote")
			return
		end

		const name = full(r)
		if r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent") then
			local ok, err = pcall(function()
				r:FireServer()
			end)
			if ok then
				DebugNotif("Fired: "..name, 3, "Fire Remote")
			else
				DebugNotif("Failed: "..tostring(err), 3, "Fire Remote")
			end
			return
		end

		Spawn(function()
			local ok, err = pcall(function()
				r:InvokeServer()
			end)
			if ok then
				DebugNotif("Invoked: "..name, 3, "Fire Remote")
			else
				DebugNotif("Failed: "..tostring(err), 3, "Fire Remote")
			end
		end)
	end

	local findOne

	const function open(list, titleText)
		if #list == 0 then
			DebugNotif("No remotes found.", 3, "Fire Remote")
			return
		end

		const buttons = {
			{
				Text = "Fire typed remote",
				Callback = function(input)
					const text = tostring(input or ""):gsub("^%s+", ""):gsub("%s+$", "")
					if text == "" then
						DebugNotif("Enter a remote name or full path.", 3, "Fire Remote")
						return
					end
					findOne(text)
				end
			}
		}

		for _, r in list do
			const rem = r
			buttons[#buttons + 1] = {
				Text = ("%s | %s"):format(rem.Name, full(rem)),
				Callback = function()
					fire(rem)
				end
			}
		end

		Window({
			Title = titleText or "Fire Remote Select",
			Description = "Select one remote, or enter a remote name/full path.",
			InputField = true,
			Buttons = buttons
		})
	end

	findOne = function(text)
		const list = scan()
		const n = norm(text)
		const fullHits, nameHits, fuzzy = {}, {}, {}

		for _, r in list do
			const fn = norm(full(r))
			const rn = norm(r.Name)

			if fn == n then
				fullHits[#fullHits + 1] = r
			elseif rn == n then
				nameHits[#nameHits + 1] = r
			elseif Find(fn, n, 1, true) or Find(rn, n, 1, true) then
				fuzzy[#fuzzy + 1] = r
			end
		end

		if #fullHits == 1 then
			fire(fullHits[1])
			return
		elseif #fullHits > 1 then
			open(fullHits, ("Select remote for full path '%s'"):format(text))
			return
		end

		if #nameHits == 1 then
			fire(nameHits[1])
			return
		elseif #nameHits > 1 then
			open(nameHits, ("Select remote named '%s'"):format(text))
			return
		end

		if #fuzzy == 1 then
			fire(fuzzy[1])
			return
		elseif #fuzzy > 1 then
			open(fuzzy, ("Select remote matching '%s'"):format(text))
			return
		end

		DebugNotif(("No remote matches '%s'"):format(text), 3, "Fire Remote")
	end

	if q == "" or norm(q) == "select" then
		open(scan(), "Fire Remote Select")
		return
	end

	findOne(q)
end,true)

cmd.add({"fireremotes", "fremotes", "frem"}, {"fireremotes (fremotes, frem)", "Fires every remote with arguments"}, function()
	const RawCoreGui = __lt.gs("CoreGui")
	const remoteList = {}
	local remoteCount = 0
	local failedCount = 0

	const q = {game}
	local qi, qn = 1, 1
	const step = 120
	local n = 0

	while qi <= qn do
		const inst = q[qi]
		qi += 1

		if inst ~= RawCoreGui then
			if inst:IsA("RemoteEvent") or inst:IsA("UnreliableRemoteEvent") or inst:IsA("RemoteFunction") then
				remoteList[#remoteList + 1] = inst
			end

			const ch = inst:GetChildren()
			for i = 1, #ch do
				const c = ch[i]
				if c ~= RawCoreGui then
					qn += 1
					q[qn] = c
				end
			end
		end

		n += 1
		if n >= step then
			n = 0
			Wait()
		end
	end

	for i = 1, #remoteList do
		const obj = remoteList[i]
		if obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
			const ok = pcall(function()
				obj:FireServer()
			end)
			if ok then
				remoteCount = remoteCount + 1
			else
				failedCount = failedCount + 1
			end
		elseif obj:IsA("RemoteFunction") then
			SpawnCall(function()
				const ok = pcall(function()
					obj:InvokeServer()
				end)
				if ok then
					remoteCount = remoteCount + 1
				else
					failedCount = failedCount + 1
				end
			end)
		end

		if i % 25 == 0 then
			Wait()
		end
	end

	Delay(2, function()
		DebugNotif("Fired " .. remoteCount .. " remotes\nFailed: " .. failedCount .. " remotes")
	end)
end)

cmd.add({"keepna"}, {"keepna", "keep executing "..adminName.." every time you teleport"}, function()
	NAQoTEnabled = true
	NAmanage.NASettingsSet("queueOnTeleport", true)
	DoNotif(adminName.." will now auto-load after teleport (QueueOnTeleport enabled)")
end)

cmd.add({"unkeepna"}, {"unkeepna", "Stop executing "..adminName.." every time you teleport"}, function()
	NAQoTEnabled = false
	NAmanage.NASettingsSet("queueOnTeleport", false)
	DoNotif("QueueOnTeleport has been disabled. "..adminName.." will no longer auto-run after teleport")
end)

do
	const FOVhandler = {mem={parent=nil,o=0,r=Vector3.new(0, 0, 0),u=Vector3.new(0, 0, 0),base={}}, loop=false, cam=nil, refreshConn=nil, loopHoldConn=nil, watchConn=nil}
	const FOV_ATTR = {
		o = "NA_FOV_O",
		base1 = "NA_FOV_BASE_1",
		rx = "NA_FOV_R_X",
		ry = "NA_FOV_R_Y",
		rz = "NA_FOV_R_Z",
		ux = "NA_FOV_U_X",
		uy = "NA_FOV_U_Y",
		uz = "NA_FOV_U_Z"
	}
	const ZERO_VECTOR = Vector3.new(0, 0, 0)
	const UNIT_VECTOR = Vector3.new(1,1,1)

	const function getFovNumberAttr(parent, key, default)
		const v = NAmanage.GetAttr(parent, key)
		if type(v) == "number" then
			return v
		end
		return default or 0
	end

	const function setFovNumberAttr(parent, key, value)
		NAmanage.SetAttr(parent, key, tonumber(value) or 0)
	end

	const function getFovVectorAttr(parent, xKey, yKey, zKey)
		return Vector3.new(
			getFovNumberAttr(parent, xKey, 0),
			getFovNumberAttr(parent, yKey, 0),
			getFovNumberAttr(parent, zKey, 0)
		)
	end

	const function setFovVectorAttr(parent, xKey, yKey, zKey, v)
		const vec = v or ZERO_VECTOR
		setFovNumberAttr(parent, xKey, vec.X)
		setFovNumberAttr(parent, yKey, vec.Y)
		setFovNumberAttr(parent, zKey, vec.Z)
	end

	const function syncFovMemFromParent(parent)
		if FOVhandler.mem.parent == parent then
			return
		end
		FOVhandler.mem.parent = parent
		FOVhandler.mem.o = getFovNumberAttr(parent, FOV_ATTR.o, 0)
		FOVhandler.mem.base = {}
		const base1 = NAmanage.GetAttr(parent, FOV_ATTR.base1)
		if type(base1) == "number" then
			FOVhandler.mem.base[1] = base1
		end
		FOVhandler.mem.r = getFovVectorAttr(parent, FOV_ATTR.rx, FOV_ATTR.ry, FOV_ATTR.rz)
		FOVhandler.mem.u = getFovVectorAttr(parent, FOV_ATTR.ux, FOV_ATTR.uy, FOV_ATTR.uz)
	end

	const function disconnectFovRefresh()
		if FOVhandler.refreshConn then
			pcall(function() FOVhandler.refreshConn:Disconnect() end)
			FOVhandler.refreshConn = nil
		end
		if NAlib and NAlib.disconnect then
			pcall(NAlib.disconnect, "fov_refresh")
		end
	end

	const function setFovRefreshConnection(conn)
		disconnectFovRefresh()
		FOVhandler.refreshConn = conn
		if conn and NAlib and NAlib.connect then
			pcall(NAlib.connect, "fov_refresh", conn)
		end
	end

	const function hasFovRefresh()
		if FOVhandler.refreshConn then
			return true
		end
		if NAlib and NAlib.isConnected then
			local ok, result = pcall(NAlib.isConnected, "fov_refresh")
			if ok and result then
				return true
			end
		end
		return false
	end

	const function disconnectLoopHold()
		if FOVhandler.loopHoldConn then
			pcall(function() FOVhandler.loopHoldConn:Disconnect() end)
			FOVhandler.loopHoldConn = nil
		end
		if NAlib and NAlib.disconnect then
			pcall(NAlib.disconnect, "fov_loop_hold")
		end
	end

	const function connectCameraWatcher()
		if FOVhandler.watchConn then
			pcall(function() FOVhandler.watchConn:Disconnect() end)
			FOVhandler.watchConn = nil
		end
		if NAlib and NAlib.disconnect then
			pcall(NAlib.disconnect, "fov_watch_cc")
		end
		local ok, conn = pcall(function()
			return Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				FOVhandler.cam = Services.Workspace.CurrentCamera
			end)
		end)
		if ok and conn then
			FOVhandler.watchConn = conn
			if NAlib and NAlib.connect then
				pcall(NAlib.connect, "fov_watch_cc", conn)
			end
		end
		FOVhandler.cam = Services.Workspace.CurrentCamera
	end

	originalIO.FOVstep=function()
		const parent = NAmanage.guiCHECKINGAHHHHH(); if not parent then return end
		syncFovMemFromParent(parent)

		const o = FOVhandler.mem.o or 0
		local sum = 0
		for i=1,#FOVhandler.mem.base do
			sum += (tonumber(FOVhandler.mem.base[i]) or 0)
		end
		const target = (o ~= 0 and o) or sum
		const cam = Services.Workspace.CurrentCamera; if not cam then return end

		if cam ~= FOVhandler.cam then
			FOVhandler.cam = cam
			setFovRefreshConnection(cam:GetPropertyChangedSignal("FieldOfView"):Connect(function()
				if not FOVhandler.loop then return end
				const t = FOVhandler.mem.o or 0
				if t > 0 then
					const vis = math.clamp(t, 25, 120)
					if cam.FieldOfView ~= vis then cam.FieldOfView = vis end
				end
			end))
		end

		if FOVhandler.loop and target > 0 then
			const vis = math.clamp(target, 25, 120)
			if cam.FieldOfView ~= vis then cam.FieldOfView = vis end
		end

		if target <= 120 or target == 0 then
			if FOVhandler.mem.r.Magnitude > 0 then
				FOVhandler.mem.r = ZERO_VECTOR
				setFovVectorAttr(parent, FOV_ATTR.rx, FOV_ATTR.ry, FOV_ATTR.rz, ZERO_VECTOR)
			end
			if FOVhandler.mem.u.Magnitude > 0 then
				FOVhandler.mem.u = ZERO_VECTOR
				setFovVectorAttr(parent, FOV_ATTR.ux, FOV_ATTR.uy, FOV_ATTR.uz, ZERO_VECTOR)
			end
			return
		end

		const f = math.clamp((target - 120) * 0.005, 0, 0.9)
		const v = Vector3.new(f,f,f)
		if FOVhandler.mem.r ~= v then
			FOVhandler.mem.r = v
			setFovVectorAttr(parent, FOV_ATTR.rx, FOV_ATTR.ry, FOV_ATTR.rz, v)
		end
		if FOVhandler.mem.u ~= v then
			FOVhandler.mem.u = v
			setFovVectorAttr(parent, FOV_ATTR.ux, FOV_ATTR.uy, FOV_ATTR.uz, v)
		end

		const c = cam.CFrame
		const p = c.Position
		const r = c.RightVector
		const u = c.UpVector
		const l = -c.LookVector
		const rs = UNIT_VECTOR - FOVhandler.mem.r
		const us = UNIT_VECTOR - FOVhandler.mem.u
		cam.CFrame = CFrame.fromMatrix(p, Vector3.new(r.X*rs.X, r.Y*rs.Y, r.Z*rs.Z), Vector3.new(u.X*us.X, u.Y*us.Y, u.Z*us.Z), l)
	end

	pcall(function() __lt.cm("RunService", "UnbindFromRenderStep", "FOV_SYS") end)
	__lt.cm("RunService", "BindToRenderStep", "FOV_SYS", Enum.RenderPriority.Camera.Value+1, originalIO.FOVstep)

	connectCameraWatcher()

	cmd.add({"fov"}, {"fov <number>", "Sets your FOV to a custom value (1–300)"}, function(num)
		const t = math.clamp(tonumber(num) or 70, 1, 300)
		const parent = NAmanage.guiCHECKINGAHHHHH(); if not parent then return end
		syncFovMemFromParent(parent)
		if FOVhandler.loop then
			FOVhandler.mem.o = t
			setFovNumberAttr(parent, FOV_ATTR.o, t)
		else
			FOVhandler.mem.base[1] = t
			setFovNumberAttr(parent, FOV_ATTR.base1, t)
		end
		const cam = Services.Workspace.CurrentCamera
		if cam then
			const vis = math.clamp(t, 25, 120)
			__lt.cm("TweenService", "Create", cam, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {FieldOfView = vis}):Play()
		end
	end, true)

	cmd.add({"loopfov","lfov"}, {"loopfov <number> (lfov)", "Locks your FOV target (1–300)"}, function(num)
		const t = math.clamp(tonumber(num) or 70, 1, 300)
		const parent = NAmanage.guiCHECKINGAHHHHH(); if not parent then return end
		syncFovMemFromParent(parent)
		FOVhandler.mem.o = t
		setFovNumberAttr(parent, FOV_ATTR.o, t)
		FOVhandler.loop = true
		if not hasFovRefresh() then
			FOVhandler.cam = nil
		end
		disconnectLoopHold()
		const cam = Services.Workspace.CurrentCamera
		if cam then
			const vis = math.clamp(t, 25, 120)
			if cam.FieldOfView ~= vis then cam.FieldOfView = vis end
		end
	end, true)

	cmd.add({"unloopfov","unlfov"}, {"unloopfov (unlfov)", "Stops FOV loop"}, function()
		FOVhandler.loop = false
		disconnectLoopHold()
		disconnectFovRefresh()
		FOVhandler.mem.o = 0
		FOVhandler.mem.r = ZERO_VECTOR
		FOVhandler.mem.u = ZERO_VECTOR
		const parent = NAmanage.guiCHECKINGAHHHHH()
		if parent then
			syncFovMemFromParent(parent)
			FOVhandler.mem.o = 0
			FOVhandler.mem.r = ZERO_VECTOR
			FOVhandler.mem.u = ZERO_VECTOR
			setFovNumberAttr(parent, FOV_ATTR.o, 0)
			setFovVectorAttr(parent, FOV_ATTR.rx, FOV_ATTR.ry, FOV_ATTR.rz, ZERO_VECTOR)
			setFovVectorAttr(parent, FOV_ATTR.ux, FOV_ATTR.uy, FOV_ATTR.uz, ZERO_VECTOR)
		end
	end)
end

-- deleted
--[[cmd.add({"homebrew"},{"homebrew","Executes homebrew admin"},function()
	_na_env.CustomUI=false
	NAmanage.RunURL(('https://raw.githubusercontent.com/mgamingpro/HomebrewAdmin/master/Main'),true)
end)]]

-- useless
--[[cmd.add({"fatesadmin"},{"fatesadmin","Executes fates admin"},function()
	NAmanage.RunURL("https://raw.githubusercontent.com/fatesc/fates-admin/main/main.lua");
end)]]

storedTools = {}

cmd.add({"savetools", "stools"}, {"savetools (stools)", "Saves your tools to memory"}, function()
	storedTools = {}

	for _, tool in LocalPlayer.Backpack:GetChildren() do
		if tool:IsA("Tool") then
			const clonedTool = tool:Clone()
			Insert(storedTools, clonedTool)
		end
	end

	for _, tool in LocalPlayer.Character:GetChildren() do
		if tool:IsA("Tool") then
			const clonedTool = tool:Clone()
			Insert(storedTools, clonedTool)
		end
	end

	DebugNotif("Tools saved: "..#storedTools,2)
end)

cmd.add({"loadtools", "ltools"}, {"loadtools (ltools)", "Restores your saved tools to your backpack"}, function()
	for _, tool in storedTools do
		if not LocalPlayer.Backpack:FindFirstChild(tool.Name) then
			const clonedTool = tool:Clone()
			clonedTool.Parent = LocalPlayer.Backpack
		end
	end

	DebugNotif("Tools loaded: "..#storedTools,2)
end)

cmd.add({"preventtools", "noequip", "antiequip"}, {"preventtools (noequip,antiequip)", "Prevents any item from being equipped"}, function()
	const p = Services.Players.LocalPlayer
	const c = p.Character

	NAlib.disconnect("noequip_char")
	NAlib.disconnect("noequip_hum")

	const h = getHum()
	if not h then return end

	h:UnequipTools()

	const function onTool(t)
		if t:IsA("Tool") then
			t.Enabled = false
			Defer(function()
				h:UnequipTools()
				DebugNotif("Tool "..t.Name.." blocked", 2)
			end)
		end
	end

	NAlib.connect("noequip_char", NAmanage.childAdd(c, onTool, function(child)
		return child and child:IsA("Tool")
	end, function(inst)
		return inst and (inst:IsA("ProximityPrompt") or inst:IsA("ClickDetector"))
	end))
	NAlib.connect("noequip_hum", NAmanage.childAdd(h, onTool, function(child)
		return child and child:IsA("Tool")
	end))

	DebugNotif("Tool prevention on", 3)
end)

cmd.add({"unpreventtools", "unnoequip", "unantiequip"}, {"unpreventtools (unnoequip,unantiequip)", "Self-explanatory"}, function()
	NAlib.disconnect("noequip_char")
	NAlib.disconnect("noequip_hum")
	DebugNotif("Tool prevention off", 2)
end)

cmd.add({"ws", "speed", "walkspeed"}, {"walkspeed <number> (speed,ws)", "Sets your WalkSpeed"}, function(...)
	const a = {...}
	const s = tonumber(a[2] or a[1]) or 16
	if s then
		_na_env.NamelessSpeed = s
		if NAStuff.SafeSpeedMethod ~= false then
			NAmanage.RefreshVelocityWalkSpeed()
		else
			NAmanage.ApplyWalkSpeed(s)
		end
	end
end, true)

cmd.add({"jp", "jumppower"}, {"jumppower <number> (jp)", "Sets your JumpPower"}, function(...)
	const a = {...}
	const j = tonumber(a[1]) or 50
	const h = getHum()
	if j and h then
		if h.UseJumpPower then
			h.JumpPower = j
		else
			h.JumpHeight = NAmanage.GetJumpHeightFromJumpPower(j) or j
		end
	end
end, true)

NAmanage.isCoreFunc=function(fn)
	local ok, env = pcall(getfenv, fn)
	if not ok or type(env) ~= "table" then return false end
	const sc = rawget(env, "script")
	return typeof(sc) == "Instance" and sc:IsDescendantOf(Services.CoreGui)
end

NAmanage.pruneBlockedRemoteState = NAmanage.pruneBlockedRemoteState or function()
	const list = NAStuff.BlockedRemotes
	if type(list) ~= "table" then
		return 0
	end
	local write = 0
	for i = 1, #list do
		const remote = list[i]
		if typeof(remote) == "Instance" and remote.Parent then
			write += 1
			list[write] = remote
		else
			if remote ~= nil then
				pcall(function()
					if typeof(remote) == "Instance" and (remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent")) then
						NAStuff.BlockedSignals[remote.OnClientEvent] = nil
					end
				end)
				NAStuff.BlockedRemoteModes[remote] = nil
				NAStuff.BlockedRemoteReturns[remote] = nil
				NAStuff.BlockedEventSaved[remote] = nil
				NAStuff.BlockedInvokeSaved[remote] = nil
			end
		end
	end
	for i = write + 1, #list do
		list[i] = nil
	end
	return write
end

NAmanage.BlockRemote = function(remote, mode)
	mode = mode or "fakeok"
	if type(NAmanage.pruneBlockedRemoteState) == "function" then
		NAmanage.pruneBlockedRemoteState()
	end
	if not Discover(NAStuff.BlockedRemotes, remote) then
		Insert(NAStuff.BlockedRemotes, remote)
	end
	NAStuff.BlockedRemoteModes[remote] = mode
	if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
		NAStuff.BlockedSignals[remote.OnClientEvent] = true
		if typeof(getconnections) == "function" then
			const saved = {funcs = {}}
			for _, c in getconnections(remote.OnClientEvent) do
				local ok, f = pcall(function() return c.Function end)
				if ok and type(f) == "function" and not NAmanage.isCoreFunc(f) then
					Insert(saved.funcs, f)
					pcall(function() c:Disconnect() end)
				end
			end
			NAStuff.BlockedEventSaved[remote] = saved
		end
	elseif remote:IsA("RemoteFunction") then
		if NAStuff.BlockedInvokeSaved[remote] == nil then
			local ok, current = pcall(function() return remote.OnClientInvoke end)
			NAStuff.BlockedInvokeSaved[remote] = ok and type(current)=="function" and current or NAStuff.NIL_SENTINEL
		end
		remote.OnClientInvoke = function(...)
			const m = NAStuff.BlockedRemoteModes[remote] or "fakeok"
			if m == "error" then
				error("Blocked remote: "..remote:GetFullName().." [OnClientInvoke]", 0)
			else
				local ret = NAStuff.BlockedRemoteReturns[remote]
				if ret == nil then ret = NAStuff.RemoteFakeReturn end
				return ret
			end
		end
	end
	DebugNotif(("Blocked: %s (%s)"):format(remote:GetFullName(), NAStuff.BlockedRemoteModes[remote]), 3, "Remote Block")
end

NAmanage.UnblockRemote = function(remote)
	if type(NAmanage.pruneBlockedRemoteState) == "function" then
		NAmanage.pruneBlockedRemoteState()
	end
	const idx = Discover(NAStuff.BlockedRemotes, remote)
	if idx then
		const name = NAStuff.BlockedRemotes[idx]:GetFullName()
		table.remove(NAStuff.BlockedRemotes, idx)
		NAStuff.BlockedRemoteModes[remote] = nil
		NAStuff.BlockedRemoteReturns[remote] = nil
		if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
			NAStuff.BlockedSignals[remote.OnClientEvent] = nil
			const saved = NAStuff.BlockedEventSaved[remote]
			if saved and saved.funcs then
				for _, f in saved.funcs do
					pcall(function() remote.OnClientEvent:Connect(f) end)
				end
			end
			NAStuff.BlockedEventSaved[remote] = nil
		elseif remote:IsA("RemoteFunction") then
			const saved = NAStuff.BlockedInvokeSaved[remote]
			if saved == NAStuff.NIL_SENTINEL then
				remote.OnClientInvoke = nil
			elseif type(saved) == "function" then
				remote.OnClientInvoke = saved
			else
				remote.OnClientInvoke = nil
			end
			NAStuff.BlockedInvokeSaved[remote] = nil
		end
		DebugNotif(("Unblocked: %s"):format(name), 3, "Remote Block")
	end
end

NAmanage.EnsureHook = function()
	if _na_env.NA_BlockHooked then return end
	const mt = getrawmetatable(game)
	const oldNamecall = mt.__namecall
	setreadonly(mt, false)
	mt.__namecall = newcclosure(function(self, ...)
		const method = getnamecallmethod()
		if (method == "FireServer" or method == "InvokeServer") and Discover(NAStuff.BlockedRemotes, self) then
			const m = NAStuff.BlockedRemoteModes[self] or "fakeok"
			if NAStuff.nuhuhNotifs then Defer(DebugNotif, ("Blocked -> %s (%s) [%s]"):format(self:GetFullName(), method, m == "error" and "ERROR" or "FAKEOK"), 2, "Remote Block") end
			if m == "error" then error("Blocked remote: "..self:GetFullName().." ["..method.."]", 0) end
			if method == "InvokeServer" then
				local ret = NAStuff.BlockedRemoteReturns[self]
				if ret == nil then ret = NAStuff.RemoteFakeReturn end
				return ret
			end
			return
		end
		if NAStuff.BlockedSignals[self] then
			if method == "Connect" or method == "Once" then
				const cb = select(1, ...)
				if type(cb) == "function" and NAmanage.isCoreFunc(cb) then
					return oldNamecall(self, ...)
				end
				if NAStuff.nuhuhNotifs then Defer(DebugNotif, "Blocked OnClientEvent:"..method.."()", 2, "Remote Block") end
				const conn = oldNamecall(self, function() end)
				pcall(function() conn:Disconnect() end)
				return conn
			elseif method == "Wait" then
				local mode = "fakeok"
				for r,_ in NAStuff.BlockedRemotes do
					if typeof(r)=="Instance" and (r:IsA("RemoteEvent") or r:IsA("UnreliableRemoteEvent")) and self==r.OnClientEvent then
						mode = NAStuff.BlockedRemoteModes[r] or "fakeok"
						break
					end
				end
				if NAStuff.nuhuhNotifs then Defer(DebugNotif, "Blocked OnClientEvent:Wait()", 2, "Remote Block") end
				if mode == "error" then error("Blocked OnClientEvent:Wait()", 0) end
				return nil
			end
		end
		return oldNamecall(self, ...)
	end)
	setreadonly(mt, true)
	_na_env.NA_BlockHooked = true
end

cmd.add({"blockremote","br"},{"blockremote [name]","Block a remote event/function by name (or pick from list)"},function(name)
	const function scanAll()
		const list, seen = {}, {}
		const function scan(parent)
			for _, className in { "RemoteEvent", "UnreliableRemoteEvent", "RemoteFunction" } do
				for _, obj in NAmanage.QueryDescendants(parent, className) do
					if not seen[obj] then
						seen[obj] = true
						Insert(list, obj)
					end
				end
			end
		end
		scan(Services.ReplicatedStorage)
		const plr = Services.Players.LocalPlayer
		const pg = PlrGui or plr:FindFirstChildOfClass("PlayerGui")
		if pg then scan(pg) else scan(plr) end
		return list
	end
	const function exactByName(q)
		const out, lq = {}, Lower(q)
		for _, r in scanAll() do
			if Lower(r.Name) == lq then Insert(out, r) end
		end
		return out
	end
	const function fuzzyByName(q)
		const out, lq = {}, Lower(q)
		for _, r in scanAll() do
			if Find(Lower(r.Name), lq, 1, true) then Insert(out, r) end
		end
		return out
	end
	const function openPicker(list, titleText, modeSel)
		if #list == 0 then DebugNotif("No remotes found.", 3, "Remote Block") return end
		const buttons = {}
		for _, r in list do
			Insert(buttons, {
				Text = ("%s | %s"):format(r.Name, r:GetFullName()),
				Callback = function()
					NAmanage.EnsureHook()
					NAmanage.BlockRemote(r, modeSel)
				end
			})
		end
		Window({ Title = titleText, Buttons = buttons })
	end
	const function afterMode(modeSel)
		const q = tostring(name or ""):gsub("^%s+",""):gsub("%s+$","")
		if q ~= "" then
			const exact = exactByName(q)
			if #exact >= 1 then
				NAmanage.EnsureHook()
				for _, r in exact do
					NAmanage.BlockRemote(r, modeSel)
				end
				return
			end
			const fuzzy = fuzzyByName(q)
			if #fuzzy == 1 then
				NAmanage.EnsureHook()
				NAmanage.BlockRemote(fuzzy[1], modeSel)
				return
			end
			openPicker(fuzzy, ("Select remote(s) to BLOCK for '%s'"):format(q), modeSel)
			return
		end
		openPicker(scanAll(), "Select remote(s) to BLOCK", modeSel)
	end
	Window({
		Title = "Remote Block Mode",
		Buttons = {
			{ Text = "Fake Success", Callback = function() afterMode("fakeok") end },
			{ Text = "Error",        Callback = function() afterMode("error")  end }
		}
	})
end,true)

cmd.add({"unblockremote","ubr"},{"unblockremote [name|all]","Unblock a remote by name, or pick from blocked list"},function(name)
	if not name or name == "" then
		const blocked = NAStuff.BlockedRemotes
		if #blocked == 0 then
			DebugNotif("No remotes are currently blocked.", 3, "Remote Block")
			return
		end
		const buttons = {}
		for _, r in blocked do
			Insert(buttons, {
				Text = ("%s | %s"):format(r.Name, r:GetFullName()),
				Callback = function() NAmanage.UnblockRemote(r) end
			})
		end
		Insert(buttons, {
			Text = "[ Unblock ALL ]",
			Callback = function()
				for i = #blocked, 1, -1 do
					NAmanage.UnblockRemote(blocked[i])
				end
			end
		})
		Window({ Title = "Blocked Remotes", Buttons = buttons })
		return
	end
	if Lower(name) == "all" or name == "*" then
		for i = #NAStuff.BlockedRemotes, 1, -1 do
			NAmanage.UnblockRemote(NAStuff.BlockedRemotes[i])
		end
		return
	end
	const lname = Lower(name)
	const exact, suggestions = {}, {}
	for _, r in NAStuff.BlockedRemotes do
		if Lower(r.Name) == lname then
			Insert(exact, r)
		elseif Find(Lower(r.Name), lname, 1, true) then
			Insert(suggestions, r)
		end
	end
	if #exact > 0 then
		for _, r in exact do
			NAmanage.UnblockRemote(r)
		end
		return
	end
	if #suggestions == 0 then
		DebugNotif(("No BLOCKED remotes match '%s'"):format(name), 3, "Remote Block")
		return
	end
	const buttons = {}
	for _, r in suggestions do
		Insert(buttons, {
			Text = ("%s | %s"):format(r.Name, r:GetFullName()),
			Callback = function() NAmanage.UnblockRemote(r) end
		})
	end
	Window({ Title = ("Select remote to UNBLOCK for '%s'"):format(name), Buttons = buttons })
end,true)

NAmanage.EnsureWalkSpeedBypassHook = function()
	if _na_env.NA_WSBP_Hooked then return end
	const mt = getrawmetatable(game)
	const oldIndex = mt.__index
	setreadonly(mt, false)
	mt.__index = newcclosure(function(self, key)
		if key == "WalkSpeed" then
			return 16
		end
		return oldIndex(self, key)
	end)
	setreadonly(mt, true)
	_na_env.NA_WSBP_Hooked = true
	DebugNotif("WalkSpeed bypass installed", 2, "Bypass Speed")
end

NAmanage.ApplyBypassSpeedOnce = function(val)
	const hum = getHum()
	if hum and val and val > 0 then
		hum.WalkSpeed = val
		DebugNotif(("BypassSpeed set to %s"):format(val), 2, "Bypass Speed")
	end
end

NAmanage.StartBypassSpeedLoop = function(val)
	if not val or val <= 0 then return end
	_na_env.NA_BPS_Enabled = true
	_na_env.NA_BPS_Val = val
	NAlib.disconnect("na_bps_apply")
	NAlib.disconnect("na_bps_char")
	const plr = Services.Players.LocalPlayer
	NAmanage.ApplyBypassSpeedOnce(val)
	NAlib.connect("na_bps_apply", Services.RunService.Heartbeat:Connect(function()
		if not _na_env.NA_BPS_Enabled then return end
		const hum = getHum()
		if hum and hum.WalkSpeed ~= _na_env.NA_BPS_Val then
			hum.WalkSpeed = _na_env.NA_BPS_Val
		end
	end))
	NAlib.connect("na_bps_char", plr.CharacterAdded:Connect(function(char)
		NAmanage.EnsureWalkSpeedBypassHook()
		while not getHum() do Wait(.05) end
		if _na_env.NA_BPS_Enabled then
			NAmanage.ApplyBypassSpeedOnce(_na_env.NA_BPS_Val)
		end
	end))
	DebugNotif(("LoopBypassSpeed: %s"):format(val), 2, "Bypass Speed")
end

NAmanage.StopBypassSpeedLoop = function()
	_na_env.NA_BPS_Enabled = false
	NAlib.disconnect("na_bps_apply")
	NAlib.disconnect("na_bps_char")
	DebugNotif("LoopBypassSpeed: OFF", 2, "Bypass Speed")
end

cmd.add({"bypassspeed","bps","bypasswalkspeed","bpws"},{"bypassspeed <number> (bps,bpws)","Set WalkSpeed (bypass variant)"},function(...)
	const a = {...}
	const arg = tostring(a[2] or a[1] or "")
	if arg == "" then return end
	if Lower(arg) == "off" then
		NAmanage.StopBypassSpeedLoop()
		return
	end
	const val = tonumber(arg)
	if not val or val <= 0 then return end
	NAmanage.EnsureWalkSpeedBypassHook()
	NAmanage.ApplyBypassSpeedOnce(val)
end, true)

cmd.add({"loopbypassspeed","lbps","loopbypasswalkspeed","lbws"},{"loopbypassspeed <number|off> (lbps,lbws)","Loop WalkSpeed (bypass variant)"},function(...)
	const arg = tostring((...) or "")
	if arg == "" then return end
	if Lower(arg) == "off" then
		NAmanage.StopBypassSpeedLoop()
		return
	end
	const val = tonumber(arg)
	if not val or val <= 0 then return end
	NAmanage.EnsureWalkSpeedBypassHook()
	NAmanage.StartBypassSpeedLoop(val)
end, true)

cmd.add({"unloopbypassspeed","unlbps","unloopbypasswalkspeed","unlbws"},{"unloopbypassspeed (unlbps,unlbws)","Disable loop WalkSpeed (bypass variant)"},function()
	NAmanage.StopBypassSpeedLoop()
end)

cmd.add({"oofspam"},{"oofspam","Spams oof"},function()
	_na_env.enabled = true
	_na_env.speed = 100
	const HRP = Humanoid.RootPart or getRoot(Humanoid.Parent)
	if not Humanoid or not _na_env.enabled then
		if Humanoid and Humanoid.Health <= 0 then
			Humanoid:Destroy()
		end
		return
	end
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	Humanoid.BreakJointsOnDeath = false
	Humanoid.RequiresNeck = false

	NAlib.connect("oofspam_forcerun", Services.RunService.PreSimulation:Connect(function()
		if not Humanoid then return NAlib.disconnect("oofspam_forcerun") end
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end))

	LocalPlayer.Character = nil
	LocalPlayer.Character = Character
	Wait(Services.Players.RespawnTime + 0.1)

	NAlib.connect("oofspam_loop", Services.RunService.Heartbeat:Connect(function()
		if not _na_env.enabled then
			NAlib.disconnect("oofspam_loop")
			return
		end
		Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
	end))
end)

cmd.add({"httpspy"},{"httpspy","HTTP Spy"},function()
	NAmanage.RunURL('https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/httpspy.lua')
end)

cmd.add({"keystroke"},{"keystroke","Executes a keystroke ui script"},function()
	NAmanage.RunURL("https://system-exodus.com/scripts/misc-releases/Keystrokes.lua",true)
end)

cmd.add({"errorchat"},{"errorchat","Makes the chat error appear when roblox chat is slow"},function()
	for i=1,3 do
		NAlib.LocalPlayerChat("\0","All")
	end
end)

cmd.add({"clearerror", "noerror"}, {"clearerror", "Clears any current error or disconnected UI immediately"}, function()
	__lt.cm("GuiService", "ClearError")
end)

cmd.add({"antierror"}, {"antierror", "Continuously blocks and clears any future error or disconnected UI"}, function()
	NAlib.disconnect("antierror")
	NAStuff.AntiErrorState = type(NAStuff.AntiErrorState) == "table" and NAStuff.AntiErrorState or {}
	NAStuff.AntiErrorState.clearing = false
	NAlib.connect("antierror", Services.GuiService.ErrorMessageChanged:Connect(function(message)
		const st = NAStuff.AntiErrorState
		if type(st) ~= "table" then
			return
		end
		if st.clearing then
			return
		end
		const msg = tostring(message or "")
		if msg == "" then
			local ok, current = pcall(function()
				return Services.GuiService.ErrorMessage
			end)
			if not ok or tostring(current or "") == "" then
				return
			end
		end
		st.clearing = true
		Spawn(function()
			pcall(function()
				__lt.cm("GuiService", "ClearError")
			end)
			st.clearing = false
		end)
	end))
	DebugNotif("Anti Error is now enabled!", 2)
end)

cmd.add({"unantierror", "noantierror"}, {"unantierror", "Disables Anti Error"}, function()
	NAlib.disconnect("antierror")
	if type(NAStuff.AntiErrorState) == "table" then
		NAStuff.AntiErrorState.clearing = false
	end
	DebugNotif("Anti Error is now disabled!",2)
end)

-- [[ Body Mods Section ]] --
do
	originalIO.bodyModsState = originalIO.bodyModsState or {
		boobs = { active = false, size = 1, conn = nil, ox = 0.5, oy = -0.4, oz = nil, rigs = {}, objs = {} },
		ass = { active = false, size = 1, conn = nil, ox = 0.48, oy = nil, oz = nil, rigs = {}, objs = {} },
		pp = { active = false, len = 1, animConn = nil, baseS = nil, baseBL = nil, baseBR = nil, rigs = {}, objs = {} },
		colorConn = nil,
		spawnConn = nil,
		apConn = nil
	}

	const state = originalIO.bodyModsState
	state.boobs.rigs = type(state.boobs.rigs) == "table" and state.boobs.rigs or {}
	state.boobs.objs = type(state.boobs.objs) == "table" and state.boobs.objs or {}
	state.ass.rigs = type(state.ass.rigs) == "table" and state.ass.rigs or {}
	state.ass.objs = type(state.ass.objs) == "table" and state.ass.objs or {}
	state.pp.rigs = type(state.pp.rigs) == "table" and state.pp.rigs or {}
	state.pp.objs = type(state.pp.objs) == "table" and state.pp.objs or {}
	state.folder = (typeof(state.folder) == "Instance" and state.folder.Parent and state.folder) or nil

	const pinkColor = Color3.fromRGB(255, 100, 150)
	const ringColor = Color3.fromRGB(225, 80, 120)
	const BODYMOD_TAIL_STEP = 0.008333333333333333
	const BODYMOD_TAIL_STIFFNESS = 248
	const BODYMOD_TAIL_DAMPING = 12
	const BODYMOD_TAIL_LINEAR_AMPLITUDE = Vector3.new(28, 9, 28)
	const BODYMOD_TAIL_ANGULAR_AMPLITUDE = Vector3.new(0, 8, 0)
	const BODYMOD_TAIL_MOVEMENT_THRESHOLD = 15

	originalIO.bodyModsTailScaleVector = function(value, scale)
		if typeof(scale) == "Vector3" then
			return Vector3.new(value.X * scale.X, value.Y * scale.Y, value.Z * scale.Z)
		end
		local n = tonumber(scale) or 1
		return value * n
	end

	originalIO.bodyModsTailBind = function(rig, pivotPosition, linearScale, angularScale)
		if type(rig) ~= "table" or not rig.root or not rig.target then
			return nil
		end

		local base = rig.base or rig.target.CFrame or CFrame.identity
		local pivot = typeof(pivotPosition) == "Vector3" and pivotPosition or base.Position
		local pivotCFrame = CFrame.new(pivot)
		local pivotOffset = base:ToObjectSpace(pivotCFrame)

		rig.tailPhysics = {
			rootPreviousCFrame = rig.root.CFrame,
			rootPreviousDeltaCFrame = CFrame.identity,
			weldPreviousCFrame = base,
			weldCurrentCFrame = base,
			currentAngle = Vector3.zero,
			angularVelocity = Vector3.zero,
			pivotCFrame = pivotCFrame,
			inversePivotOffsetCFrame = pivotOffset:Inverse(),
			linearAmplitude = originalIO.bodyModsTailScaleVector(BODYMOD_TAIL_LINEAR_AMPLITUDE, linearScale),
			angularAmplitude = originalIO.bodyModsTailScaleVector(BODYMOD_TAIL_ANGULAR_AMPLITUDE, angularScale),
			stiffness = BODYMOD_TAIL_STIFFNESS,
			damping = BODYMOD_TAIL_DAMPING,
			movementDistanceThreshold = BODYMOD_TAIL_MOVEMENT_THRESHOLD,
			accumulator = 0
		}

		rig.target.CFrame = base
		return rig.tailPhysics
	end

	originalIO.bodyModsTailReset = function(rig)
		if type(rig) ~= "table" or not rig.root or not rig.target then
			return
		end
		local sim = rig.tailPhysics
		if type(sim) ~= "table" then
			return
		end
		local base = rig.base or CFrame.identity
		sim.rootPreviousCFrame = rig.root.CFrame
		sim.rootPreviousDeltaCFrame = CFrame.identity
		sim.weldPreviousCFrame = base
		sim.weldCurrentCFrame = base
		sim.currentAngle = Vector3.zero
		sim.angularVelocity = Vector3.zero
		sim.accumulator = 0
		rig.target.CFrame = base
	end

	originalIO.bodyModsTailStep = function(rig)
		local sim = type(rig) == "table" and rig.tailPhysics or nil
		local root = type(rig) == "table" and rig.root or nil
		if type(sim) ~= "table" or not root or not root.Parent then
			return
		end

		local rootCFrame = root.CFrame
		local rootDelta = sim.rootPreviousCFrame:ToObjectSpace(rootCFrame)
		if rootDelta.Position.Magnitude > sim.movementDistanceThreshold then
			rootDelta = rootDelta.Rotation
		end

		local rootDeltaChange = sim.rootPreviousDeltaCFrame:ToObjectSpace(rootDelta)
		local deltaPosition = rootDeltaChange.Position
		local linearAmplitude = sim.linearAmplitude
		local linearInput = Vector3.new(
			deltaPosition.X * linearAmplitude.X,
			deltaPosition.Y * linearAmplitude.Y,
			deltaPosition.Z * linearAmplitude.Z
		)

		local lever = sim.pivotCFrame.Position - sim.weldPreviousCFrame.Position
		local linearTorque = lever:Cross(linearInput)

		local ax, ay, az = rootDeltaChange:ToEulerAnglesXYZ()
		local angularAmplitude = sim.angularAmplitude
		local angularInput = Vector3.new(
			ax * angularAmplitude.X,
			ay * angularAmplitude.Y,
			az * angularAmplitude.Z
		)

		local currentAngle = sim.currentAngle
		local angularVelocity = sim.angularVelocity
		local nextVelocity = angularVelocity - (sim.stiffness * currentAngle + sim.damping * angularVelocity) * BODYMOD_TAIL_STEP
		local nextAngle = currentAngle + nextVelocity * BODYMOD_TAIL_STEP

		sim.currentAngle = nextAngle
		sim.angularVelocity = nextVelocity + linearTorque - angularInput

		local nextCFrame = sim.pivotCFrame
			* CFrame.fromEulerAnglesXYZ(nextAngle.X, nextAngle.Y, nextAngle.Z)
			* sim.inversePivotOffsetCFrame

		sim.rootPreviousCFrame = rootCFrame
		sim.rootPreviousDeltaCFrame = rootDelta
		sim.weldPreviousCFrame = sim.weldCurrentCFrame
		sim.weldCurrentCFrame = nextCFrame
	end

	originalIO.bodyModsTailUpdate = function(rig, dt)
		local sim = type(rig) == "table" and rig.tailPhysics or nil
		if type(sim) ~= "table" or not rig.target then
			return
		end

		dt = math.min(math.max(tonumber(dt) or 0, 0), 0.1)
		sim.accumulator += dt

		while sim.accumulator >= BODYMOD_TAIL_STEP do
			sim.accumulator -= BODYMOD_TAIL_STEP
			originalIO.bodyModsTailStep(rig)
		end

		local alpha = sim.accumulator * 120
		rig.target.CFrame = sim.weldPreviousCFrame:Lerp(sim.weldCurrentCFrame, alpha)
	end

	originalIO.bodyModsDisconnectConnection = function(conn)
		if conn and conn.Connected then
			conn:Disconnect()
		end
		return nil
	end

	originalIO.bodyModsConnectAppearanceLoaded = originalIO.bodyModsConnectAppearanceLoaded or function(object, callback)
		if not object or type(callback) ~= "function" then
			return nil
		end
		local ok, signal = pcall(function()
			return object.CharacterAppearanceLoaded
		end)
		if ok and typeof(signal) == "RBXScriptSignal" then
			return signal:Connect(callback)
		end
		Defer(callback)
		return nil
	end

	originalIO.bodyModsLive = function(inst)
		if typeof(inst) ~= "Instance" then
			return false
		end
		local ok, parent = pcall(function()
			return inst.Parent
		end)
		return ok and parent ~= nil
	end

	originalIO.bodyModsTrack = function(bucket, inst)
		if type(bucket) == "table" and typeof(inst) == "Instance" then
			bucket[#bucket + 1] = inst
		end
		return inst
	end

	originalIO.bodyModsDestroyList = function(list)
		if type(list) ~= "table" then
			return
		end
		for i = #list, 1, -1 do
			const inst = list[i]
			if originalIO.bodyModsLive(inst) then
				pcall(function()
					inst:Destroy()
				end)
			end
			list[i] = nil
		end
	end

	originalIO.bodyModsGetFolder = function()
		local host
		if NAmanage.Helper_EnsureSecureContainer then
			local ok, res = pcall(NAmanage.Helper_EnsureSecureContainer)
			if ok and typeof(res) == "Instance" then
				host = res
			end
		end
		host = host or Services.Workspace
		local folder = state.folder
		if typeof(folder) == "Instance" and folder.Parent then
			if folder.Parent ~= host then
				pcall(function()
					folder.Parent = host
				end)
			end
			return folder
		end
		const found = host:FindFirstChild("NA_BodyMods")
		if found and found:IsA("Folder") then
			state.folder = found
			return found
		end
		folder = InstanceNew("Folder")
		folder.Name = "NA_BodyMods"
		state.folder = folder
		if NAmanage.ESP_HardenVisual then
			pcall(NAmanage.ESP_HardenVisual, folder)
		end
		folder.Parent = host
		return folder
	end

	originalIO.bodyModsIsNamedPart = function(inst, names)
		if typeof(inst) ~= "Instance" or type(names) ~= "table" then
			return false
		end
		local mark
		pcall(function()
			mark = inst:GetAttribute("NA_BodyModPart")
		end)
		return inst:IsA("BasePart") and (names[inst.Name] or (type(mark) == "string" and names[mark]))
	end

	originalIO.bodyModsDestroyOld = function(character, names)
		if type(names) ~= "table" then
			return
		end
		const roots = { character, originalIO.bodyModsGetFolder() }
		for _, root in roots do
			if typeof(root) == "Instance" and root.Parent then
				for _, inst in root:QueryDescendants("BasePart") do
					if originalIO.bodyModsIsNamedPart(inst, names) then
						pcall(function()
							inst:Destroy()
						end)
					end
				end
			end
		end
	end

	originalIO.bodyModsCollectParts = function(names, objs)
		const out = {}
		const seen = {}
		const function add(inst)
			if originalIO.bodyModsIsNamedPart(inst, names) and not seen[inst] then
				seen[inst] = true
				out[#out + 1] = inst
			end
		end
		if type(objs) == "table" then
			for _, inst in objs do
				add(inst)
			end
		end
		const character = originalIO.bodyModsGetCharacter()
		const roots = { character, originalIO.bodyModsGetFolder() }
		for _, root in roots do
			if typeof(root) == "Instance" and root.Parent then
				for _, inst in root:QueryDescendants("BasePart") do
					add(inst)
				end
			end
		end
		return out
	end

	originalIO.bodyModsSetPart = function(part, shape, size, color, name, parent, massless)
		part.Shape = shape
		part.Size = size
		part.Color = color
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		pcall(function()
			part.CustomPhysicalProperties = nil
		end)
		part.Name = name
		pcall(function()
			part:SetAttribute("NA_BodyMod", true)
			part:SetAttribute("NA_BodyModPart", name)
			part:SetAttribute("NA_BodyModVisual", true)
			part:SetAttribute("NA_BodyModDeco", massless == true)
		end)
		const character = originalIO.bodyModsGetCharacter()
		part.Parent = parent or character or originalIO.bodyModsGetFolder()
		return part
	end

	originalIO.bodyModsPart = function(shape, size, color, name, parent, massless)
		return originalIO.bodyModsSetPart(InstanceNew("Part"), shape, size, color, name, parent, massless)
	end

	originalIO.bodyModsAttachment = function(parent, name, cf, objs)
		const att = InstanceNew("Attachment")
		att.Name = name
		att.CFrame = cf or CFrame.new()
		att.Parent = parent
		return originalIO.bodyModsTrack(objs, att)
	end

	originalIO.bodyModsNoCollide = function(part, root, objs)
		if not part or not root then
			return nil
		end
		const nc = InstanceNew("NoCollisionConstraint")
		nc.Part0 = part
		nc.Part1 = root
		nc.Parent = part
		return originalIO.bodyModsTrack(objs, nc)
	end

	originalIO.bodyModsRig = function(part, root, localCf, opts, objs)
		opts = type(opts) == "table" and opts or {}
		localCf = localCf or CFrame.new()
		if not part or not root then
			return nil
		end

		const character = originalIO.bodyModsGetCharacter()
		if character and part.Parent ~= character then
			pcall(function()
				part.Parent = character
			end)
		end

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		pcall(function()
			part.CustomPhysicalProperties = nil
		end)

		const target = originalIO.bodyModsAttachment(root, "NA_BodyModsTailTarget", localCf, objs)
		const rig = {
			part = part,
			root = root,
			target = target,
			base = localCf,
			kids = {},
			cfg = opts
		}
		originalIO.bodyModsSyncRig(rig, true)
		return rig
	end

	originalIO.bodyModsSyncRig = function(rig)
		if type(rig) ~= "table" then
			return
		end
		local root = rig.root or (rig.target and rig.target.Parent)
		local localCf = rig.target and rig.target.CFrame or rig.base or CFrame.new()
		if not root or not root.Parent then
			return
		end
		local worldCf = root.CFrame * localCf
		if rig.part and rig.part.Parent then
			rig.part.CFrame = worldCf
		end
		if type(rig.kids) == "table" then
			for _, link in rig.kids do
				if type(link) == "table" and link.part and link.part.Parent then
					link.part.CFrame = worldCf * (link.cf or CFrame.new())
				end
			end
		end
	end

	originalIO.bodyModsLinkVisual = function(rig, part, cf)
		if type(rig) ~= "table" or not part then
			return nil
		end
		rig.kids = rig.kids or {}
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		pcall(function()
			part.CustomPhysicalProperties = nil
		end)
		const link = { part = part, cf = cf or CFrame.new() }
		rig.kids[#rig.kids + 1] = link
		originalIO.bodyModsSyncRig(rig, true)
		return link
	end

	originalIO.bodyModsWeld = function(part0, part1, objs)
		return nil
	end

	originalIO.bodyModsGetCharacter = function(waitFor)
		const character = Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character
		if character or not waitFor then
			return character
		end
		local ok, result = pcall(function()
			return Services.Players.LocalPlayer.Character or Services.Players.LocalPlayer.CharacterAdded:Wait()
		end)
		return ok and result or nil
	end

	originalIO.bodyModsGetHumanoid = function(waitFor)
		const character = originalIO.bodyModsGetCharacter(waitFor)
		if not character then
			return nil
		end
		const humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid or not waitFor then
			return humanoid
		end
		local ok, result = pcall(function()
			return character:WaitForChild("Humanoid", 10)
		end)
		return ok and result or nil
	end

	originalIO.bodyModsWaitFor = function(partNames, timeout)
		const deadline = os.clock() + (timeout or 10)
		while os.clock() < deadline do
			const character = Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character
			if character then
				for _, name in partNames do
					const part = character:FindFirstChild(name)
					if part then
						return part
					end
				end
			end
			Wait(0.05)
		end
		return nil
	end

	originalIO.bodyModsGetTorso = function(forBoobs)
		const character = originalIO.bodyModsGetCharacter(true)
		const humanoid = originalIO.bodyModsGetHumanoid(true)
		if not character or not humanoid then
			return nil
		end
		if forBoobs then
			return character:FindFirstChild("UpperTorso")
				or character:FindFirstChild("Torso")
				or originalIO.bodyModsWaitFor({ "UpperTorso", "Torso" }, 5)
		end
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			return character:FindFirstChild("LowerTorso") or originalIO.bodyModsWaitFor({ "LowerTorso" }, 5)
		end
		return character:FindFirstChild("Torso") or originalIO.bodyModsWaitFor({ "Torso" }, 5)
	end

	originalIO.bodyModsGetSkinColor = function()
		const character = Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character
		if not character then
			return Color3.new(1, 0.8, 0.6)
		end
		const part =
			character:FindFirstChild("LeftUpperArm") or
			character:FindFirstChild("Left Arm") or
			character:FindFirstChild("RightUpperArm") or
			character:FindFirstChild("Right Arm") or
			character:FindFirstChild("LeftUpperLeg") or
			character:FindFirstChild("Left Leg") or
			character:FindFirstChild("UpperTorso") or
			character:FindFirstChild("Torso")
		return (part and part.Color) or Color3.new(1, 0.8, 0.6)
	end

	originalIO.bodyModsAnyActive = function()
		return state.boobs.active or state.ass.active or state.pp.active
	end

	originalIO.bodyModsDisconnectColorWatcher = function()
		state.colorConn = originalIO.bodyModsDisconnectConnection(state.colorConn)
		NAlib.disconnect("bodymods_color")
	end

	originalIO.bodyModsEnsureColorWatcher = function()
		if not originalIO.bodyModsAnyActive() then
			originalIO.bodyModsDisconnectColorWatcher()
			return
		end
		if state.colorConn and state.colorConn.Connected then
			return
		end
		state.colorConn = NAlib.reconnect("bodymods_color", Services.RunService.Heartbeat:Connect(function()
			if not originalIO.bodyModsAnyActive() then
				originalIO.bodyModsDisconnectColorWatcher()
				return
			end
			const character = Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character
			if not character then
				return
			end
			const skin = originalIO.bodyModsGetSkinColor()
			const roots = { character, state.folder }
			for _, root in roots do
				if typeof(root) == "Instance" and root.Parent then
					for _, inst in root:QueryDescendants("BasePart") do
						if inst.Name == "Boob" or inst.Name == "Cheek" or inst.Name == "Balls" or (inst.Name == "penis" and inst.Shape == Enum.PartType.Cylinder) then
							if inst.Color ~= skin then
								inst.Color = skin
							end
						elseif inst.Name == "Nipple" or (inst.Name == "penis" and inst.Shape == Enum.PartType.Ball) then
							if inst.Color ~= pinkColor then
								inst.Color = pinkColor
							end
						end
					end
					for _, inst in root:QueryDescendants("Frame") do
						if inst.Name == "Disk" and inst.BackgroundColor3 ~= ringColor then
							inst.BackgroundColor3 = ringColor
						end
					end
				end
			end
		end))
	end

	originalIO.bodyModsOnAppearanceLoaded = function()
		Defer(function()
			const character = Services.Players.LocalPlayer and Services.Players.LocalPlayer.Character
			if not character then
				return
			end
			const skin = originalIO.bodyModsGetSkinColor()
			const roots = { character, state.folder }
			for _, root in roots do
				if typeof(root) == "Instance" and root.Parent then
					for _, inst in root:QueryDescendants("BasePart") do
						if inst.Name == "Boob" or inst.Name == "Cheek" or inst.Name == "Balls" or (inst.Name == "penis" and inst.Shape == Enum.PartType.Cylinder) then
							inst.Color = skin
						end
					end
				end
			end
		end)
	end

	originalIO.bodyModsAppear = function(parts, scale, time)
		const tweenInfo = TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		for _, part in parts do
			if part and part:IsA("BasePart") then
				const target = part.Size
				part.Transparency = 1
				part.Size = target * (scale or 0.2)
				__lt.cm("TweenService", "Create", part, tweenInfo, { Transparency = 0, Size = target }):Play()
			end
		end
	end

	originalIO.bodyModsRigCfg = function(sizeScale, kind)
		local scale = math.clamp(tonumber(sizeScale) or 1, 0.3, 3)
		if kind == "heavy" then
			return { linearScale = 0.72 + scale * 0.08, angularScale = 0.78 + scale * 0.05 }
		elseif kind == "loose" then
			return { linearScale = 0.98 + scale * 0.10, angularScale = 0.96 + scale * 0.08 }
		end
		return { linearScale = 0.86 + scale * 0.08, angularScale = 0.88 + scale * 0.06 }
	end

	originalIO.bodyModsApplyBoobs = function(size)
		const character = originalIO.bodyModsGetCharacter(true)
		const humanoid = originalIO.bodyModsGetHumanoid(true)
		if not character or not humanoid then
			return
		end
		const torso = originalIO.bodyModsGetTorso(true)
		if not torso then
			return
		end

		state.boobs.conn = originalIO.bodyModsDisconnectConnection(state.boobs.conn)
		NAlib.disconnect("bodymods_boobs")
		originalIO.bodyModsDestroyList(state.boobs.objs)
		state.boobs.rigs = {}
		state.boobs.objs = {}
		originalIO.bodyModsDestroyOld(character, { Boob = true, Nipple = true })

		const bodyParent = character
		const skin = originalIO.bodyModsGetSkinColor()
		const sizeScale = math.clamp(size / 4, 0.3, 2)
		const baseSize = Vector3.new(1.72, 1.54, 1.42)
		const baseNipple = Vector3.new(0.19, 0.19, 0.19)
		const boobSize = Vector3.new(
			baseSize.X * size * (1.08 + sizeScale * 0.13),
			baseSize.Y * size * (1.05 + sizeScale * 0.11),
			baseSize.Z * size * (1.04 + sizeScale * 0.15)
		)
		const nippleSize = Vector3.new(
			baseNipple.X * size * (1.05 + sizeScale * 0.10),
			baseNipple.Y * size * (1.05 + sizeScale * 0.10),
			baseNipple.Z * size * (0.98 + sizeScale * 0.09)
		)
		const popForward = 0.035
		const torsoFront = torso.Size.Z * 0.5
		state.boobs.ox = math.clamp(torso.Size.X * 0.24 + boobSize.X * 0.145, 0.46, math.max(0.72, torso.Size.X * 0.56))
		state.boobs.oy = torso.Size.Y * 0.14 + boobSize.Y * 0.055
		state.boobs.oz = -(torsoFront + math.max(0.14, (boobSize.Z * 0.5) * 0.66) - 0.025)

		const function offsetToFront(sphereSize, attachSize)
			const sphereRadius = (sphereSize and sphereSize.Z or baseSize.Z) * 0.5
			const attachRadius = (attachSize and attachSize.Z or baseNipple.Z) * 0.5
			return math.max(sphereRadius - attachRadius * 0.5 - 0.005, 0)
		end

		const function createHalf(side)
			const boob = originalIO.bodyModsTrack(state.boobs.objs, originalIO.bodyModsPart(Enum.PartType.Ball, boobSize, skin, "Boob", bodyParent, false))
			const base = CFrame.new(side * state.boobs.ox, state.boobs.oy, state.boobs.oz)
			const cfg = originalIO.bodyModsRigCfg(sizeScale, "heavy")
			const rig = originalIO.bodyModsRig(boob, torso, base, cfg, state.boobs.objs)
			if rig then
				const pivot = (base * CFrame.new(0, 0, boobSize.Z * 0.34)).Position
				originalIO.bodyModsTailBind(rig, pivot, cfg.linearScale, cfg.angularScale)
			end

			const nipple = originalIO.bodyModsTrack(state.boobs.objs, originalIO.bodyModsPart(Enum.PartType.Ball, nippleSize, pinkColor, "Nipple", bodyParent, true))
			const nippleCf = CFrame.new(0, 0, -(offsetToFront(boob.Size, nipple.Size) + popForward))
			nipple.CFrame = boob.CFrame * nippleCf
			originalIO.bodyModsLinkVisual(rig, nipple, nippleCf)

			const areola = InstanceNew("SurfaceGui")
			areola.Name = "Areola"
			areola.Face = Enum.NormalId.Front
			areola.Adornee = boob
			areola.AlwaysOnTop = false
			areola.LightInfluence = 1
			areola.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
			areola.PixelsPerStud = 120
			areola.ZOffset = 0.01
			areola.Parent = boob
			originalIO.bodyModsTrack(state.boobs.objs, areola)

			const areolaScale = math.clamp(math.max(nippleSize.Y * 2.55, nippleSize.Z * 2.55) / math.max(boob.Size.Y, boob.Size.Z), 0.22, 0.48)
			const disk = InstanceNew("Frame")
			disk.Name = "Disk"
			disk.AnchorPoint = Vector2.new(0.5, 0.5)
			disk.Position = UDim2.fromScale(0.5, 0.5)
			disk.Size = UDim2.fromScale(areolaScale, areolaScale)
			disk.BackgroundColor3 = ringColor
			disk.BorderSizePixel = 0
			disk.Parent = areola

			const corner = InstanceNew("UICorner")
			corner.CornerRadius = UDim.new(0.5, 0)
			corner.Parent = disk

			return rig, boob, nipple
		end

		local leftRig, left, leftNipple = createHalf(-1)
		local rightRig, right, rightNipple = createHalf(1)
		state.boobs.rigs = { leftRig, rightRig }
		state.boobs.size = size
		state.boobs.active = true
		state.boobs.conn = NAlib.reconnect("bodymods_boobs", Services.RunService.RenderStepped:Connect(function(dt)
			const currentChar = originalIO.bodyModsGetCharacter()
			if not currentChar or not currentChar.Parent then
				return
			end
			for _, rig in state.boobs.rigs do
				if rig and rig.root and rig.root.Parent then
					originalIO.bodyModsTailUpdate(rig, dt)
					originalIO.bodyModsSyncRig(rig)
				end
			end
		end))

		originalIO.bodyModsAppear({ left, right, leftNipple, rightNipple }, 0.35, 0.22)
		originalIO.bodyModsEnsureColorWatcher()
		originalIO.bodyModsConnectAppearanceLoaded(Services.Players.LocalPlayer, originalIO.bodyModsOnAppearanceLoaded)
		originalIO.bodyModsEnsureSpawnConnection()
		DebugNotif("Boobs "..tostring(size),1.5)
	end

	originalIO.bodyModsRemoveBoobs = function()
		const character = originalIO.bodyModsGetCharacter()
		state.boobs.conn = originalIO.bodyModsDisconnectConnection(state.boobs.conn)
		NAlib.disconnect("bodymods_boobs")
		state.boobs.active = false
		state.boobs.rigs = {}
		const oldObjs = state.boobs.objs
		state.boobs.objs = {}
		const toFade = originalIO.bodyModsCollectParts({ Boob = true, Nipple = true }, oldObjs)
		for _, part in toFade do
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			__lt.cm("TweenService", "Create", part, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
		end
		Delay(0.24, function()
			originalIO.bodyModsDestroyList(oldObjs)
			if character then
				originalIO.bodyModsDestroyOld(character, { Boob = true, Nipple = true })
			end
		end)
		originalIO.bodyModsEnsureColorWatcher()
		DebugNotif("Boobs Removed",1.5)
	end

	originalIO.bodyModsApplyAss = function(size)
		const character = originalIO.bodyModsGetCharacter(true)
		const humanoid = originalIO.bodyModsGetHumanoid(true)
		if not character or not humanoid then
			return
		end
		const torso = originalIO.bodyModsGetTorso(false)
		if not torso then
			return
		end

		state.ass.conn = originalIO.bodyModsDisconnectConnection(state.ass.conn)
		NAlib.disconnect("bodymods_ass")
		originalIO.bodyModsDestroyList(state.ass.objs)
		state.ass.rigs = {}
		state.ass.objs = {}
		originalIO.bodyModsDestroyOld(character, { Cheek = true, Hip = true })

		const bodyParent = character
		const skin = originalIO.bodyModsGetSkinColor()
		const sizeScale = math.clamp(size / 4, 0.3, 2)
		const baseSize = Vector3.new(1.58, 1.48, 1.36)
		const cheekSize = Vector3.new(
			baseSize.X * size * (1.06 + sizeScale * 0.10),
			baseSize.Y * size * (1.04 + sizeScale * 0.07),
			baseSize.Z * size * (1.05 + sizeScale * 0.13)
		)
		const radius = cheekSize.Y * 0.5
		state.ass.ox = math.clamp(torso.Size.X * 0.25 + cheekSize.X * 0.135, 0.46, math.max(0.70, torso.Size.X * 0.55))
		state.ass.oy = (humanoid.RigType == Enum.HumanoidRigType.R15) and (torso.Size.Y * 0.30 + cheekSize.Y * 0.035) or (-(0.66 + cheekSize.Y * 0.05))
		state.ass.oz = torso.Size.Z * 0.42 + radius * 0.41

		const function createCheek(side)
			const cheek = originalIO.bodyModsTrack(state.ass.objs, originalIO.bodyModsPart(Enum.PartType.Ball, cheekSize, skin, "Cheek", bodyParent, false))
			const base = CFrame.new(side * state.ass.ox, state.ass.oy, state.ass.oz)
			const cfg = originalIO.bodyModsRigCfg(sizeScale, "loose")
			const rig = originalIO.bodyModsRig(cheek, torso, base, cfg, state.ass.objs)
			if rig then
				const pivot = (base * CFrame.new(0, 0, -cheekSize.Z * 0.34)).Position
				originalIO.bodyModsTailBind(rig, pivot, cfg.linearScale, cfg.angularScale)
			end
			return rig, cheek
		end


		local leftRig, left = createCheek(-1)
		local rightRig, right = createCheek(1)
		state.ass.rigs = { leftRig, rightRig }
		state.ass.size = size
		state.ass.active = true
		state.ass.conn = NAlib.reconnect("bodymods_ass", Services.RunService.RenderStepped:Connect(function(dt)
			const currentChar = originalIO.bodyModsGetCharacter()
			if not currentChar or not currentChar.Parent then
				return
			end
			for _, rig in state.ass.rigs do
				if rig and rig.root and rig.root.Parent then
					originalIO.bodyModsTailUpdate(rig, dt)
					originalIO.bodyModsSyncRig(rig)
				end
			end
		end))

		originalIO.bodyModsAppear({ left, right }, 0.35, 0.22)
		originalIO.bodyModsEnsureColorWatcher()
		originalIO.bodyModsConnectAppearanceLoaded(Services.Players.LocalPlayer, originalIO.bodyModsOnAppearanceLoaded)
		originalIO.bodyModsEnsureSpawnConnection()
		DebugNotif("Ass "..tostring(size),1.5)
	end

	originalIO.bodyModsRemoveAss = function()
		const character = originalIO.bodyModsGetCharacter()
		state.ass.conn = originalIO.bodyModsDisconnectConnection(state.ass.conn)
		NAlib.disconnect("bodymods_ass")
		state.ass.active = false
		state.ass.rigs = {}
		const oldObjs = state.ass.objs
		state.ass.objs = {}
		const toFade = originalIO.bodyModsCollectParts({ Cheek = true, Hip = true }, oldObjs)
		for _, part in toFade do
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			__lt.cm("TweenService", "Create", part, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
		end
		Delay(0.24, function()
			originalIO.bodyModsDestroyList(oldObjs)
			if character then
				originalIO.bodyModsDestroyOld(character, { Cheek = true, Hip = true })
			end
		end)
		originalIO.bodyModsEnsureColorWatcher()
		DebugNotif("Ass Removed",1.5)
	end

	originalIO.bodyModsApplyPP = function(length)
		const character = originalIO.bodyModsGetCharacter(true)
		const humanoid = originalIO.bodyModsGetHumanoid(true)
		if not character or not humanoid then
			return
		end
		const torso = originalIO.bodyModsGetTorso(false)
		if not torso then
			return
		end

		state.pp.animConn = originalIO.bodyModsDisconnectConnection(state.pp.animConn)
		NAlib.disconnect("bodymods_pp")
		originalIO.bodyModsDestroyList(state.pp.objs)
		state.pp.rigs = {}
		state.pp.objs = {}
		originalIO.bodyModsDestroyOld(character, { Balls = true, penis = true })

		local value = tonumber(length) or state.pp.len or 1
		value = math.clamp(value, 0.5, 6)
		state.pp.len = value

		const bodyParent = character
		const skin = originalIO.bodyModsGetSkinColor()
		const shaftLength = 1.42 + value * 0.85
		const shaftRadius = math.clamp(0.34 + value * 0.042, 0.35, 0.58)
		const ballRadius = math.clamp(0.49 + value * 0.042, 0.50, 0.78)
		const tipRadius = math.clamp(shaftRadius * 1.24, 0.39, 0.65)
		const lenScale = math.clamp(value / 2, 0.45, 3)
		const offsetY = (humanoid.RigType == Enum.HumanoidRigType.R15) and -0.98 or -1.40
		const scrotumSpread = math.clamp(ballRadius * 0.44, 0.21, 0.36)
		const shaftBaseOffset = (humanoid.RigType == Enum.HumanoidRigType.R15) and 0.46 or 0.62
		const shaftBaseZ = -(torso.Size.Z * 0.5 + shaftRadius * 0.11)
		const shaftForwardBias = math.max(0, shaftLength * 0.5 - shaftRadius * 0.88)

		const leftBall = originalIO.bodyModsTrack(state.pp.objs, originalIO.bodyModsPart(Enum.PartType.Ball, Vector3.new(ballRadius * 2, ballRadius * 2.08, ballRadius * 1.98), skin, "Balls", bodyParent, false))
		const rightBall = originalIO.bodyModsTrack(state.pp.objs, originalIO.bodyModsPart(Enum.PartType.Ball, Vector3.new(ballRadius * 2, ballRadius * 2.08, ballRadius * 1.98), skin, "Balls", bodyParent, false))
		const shaft = originalIO.bodyModsTrack(state.pp.objs, originalIO.bodyModsPart(Enum.PartType.Cylinder, Vector3.new(shaftLength, shaftRadius * 2, shaftRadius * 2), skin, "penis", bodyParent, false))
		const tip = originalIO.bodyModsTrack(state.pp.objs, originalIO.bodyModsPart(Enum.PartType.Ball, Vector3.new(tipRadius * 2.15, tipRadius * 2.05, tipRadius * 2.05), pinkColor, "penis", bodyParent, true))

		state.pp.baseBL = CFrame.new(-scrotumSpread, offsetY, -0.74 - shaftRadius * 0.46)
		state.pp.baseBR = CFrame.new(scrotumSpread, offsetY, -0.74 - shaftRadius * 0.46)
		state.pp.baseS = CFrame.new(0, offsetY + shaftBaseOffset, shaftBaseZ) * CFrame.Angles(0, math.rad(270), 0) * CFrame.new(-shaftForwardBias, 0, 0)

		const ballCfg = originalIO.bodyModsRigCfg(lenScale, "loose")
		const shaftCfg = originalIO.bodyModsRigCfg(lenScale, "heavy")
		const leftRig = originalIO.bodyModsRig(leftBall, torso, state.pp.baseBL, ballCfg, state.pp.objs)
		const rightRig = originalIO.bodyModsRig(rightBall, torso, state.pp.baseBR, ballCfg, state.pp.objs)
		const shaftRig = originalIO.bodyModsRig(shaft, torso, state.pp.baseS, shaftCfg, state.pp.objs)
		if leftRig then
			const pivot = (state.pp.baseBL * CFrame.new(0, ballRadius * 0.46, ballRadius * 0.16)).Position
			originalIO.bodyModsTailBind(leftRig, pivot, ballCfg.linearScale, ballCfg.angularScale)
		end
		if rightRig then
			const pivot = (state.pp.baseBR * CFrame.new(0, ballRadius * 0.46, ballRadius * 0.16)).Position
			originalIO.bodyModsTailBind(rightRig, pivot, ballCfg.linearScale, ballCfg.angularScale)
		end
		if shaftRig then
			const pivot = (state.pp.baseS * CFrame.new(shaftLength * 0.48, 0, 0)).Position
			originalIO.bodyModsTailBind(shaftRig, pivot, shaftCfg.linearScale, shaftCfg.angularScale)
		end
		const tipCf = CFrame.new(-shaftLength * 0.5, 0, 0)
		tip.CFrame = shaft.CFrame * tipCf
		originalIO.bodyModsLinkVisual(shaftRig, tip, tipCf)

		state.pp.rigs = { shaft = shaftRig, left = leftRig, right = rightRig }
		state.pp.active = true
		state.pp.animConn = NAlib.reconnect("bodymods_pp", Services.RunService.RenderStepped:Connect(function(dt)
			const currentChar = originalIO.bodyModsGetCharacter()
			if not currentChar or not currentChar.Parent then
				return
			end
			if state.pp.rigs then
				for _, rig in { state.pp.rigs.shaft, state.pp.rigs.left, state.pp.rigs.right } do
					if rig and rig.root and rig.root.Parent then
						originalIO.bodyModsTailUpdate(rig, dt)
						originalIO.bodyModsSyncRig(rig)
					end
				end
			end
		end))

		originalIO.bodyModsAppear({ leftBall, rightBall, shaft, tip }, 0.35, 0.22)
		originalIO.bodyModsEnsureColorWatcher()
		originalIO.bodyModsConnectAppearanceLoaded(Services.Players.LocalPlayer, originalIO.bodyModsOnAppearanceLoaded)
		originalIO.bodyModsEnsureSpawnConnection()
		DebugNotif("penis "..tostring(value),1.5)
	end

	originalIO.bodyModsRemovePP = function()
		const character = originalIO.bodyModsGetCharacter()
		state.pp.animConn = originalIO.bodyModsDisconnectConnection(state.pp.animConn)
		NAlib.disconnect("bodymods_pp")
		state.pp.active = false
		state.pp.rigs = {}
		const oldObjs = state.pp.objs
		state.pp.objs = {}
		const toFade = originalIO.bodyModsCollectParts({ Balls = true, penis = true }, oldObjs)
		for _, part in toFade do
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			__lt.cm("TweenService", "Create", part, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
		end
		Delay(0.24, function()
			originalIO.bodyModsDestroyList(oldObjs)
			if character then
				originalIO.bodyModsDestroyOld(character, { Balls = true, penis = true })
			end
		end)
		state.pp.baseS = nil
		state.pp.baseBL = nil
		state.pp.baseBR = nil
		originalIO.bodyModsEnsureColorWatcher()
		DebugNotif("PP Removed",1.5)
	end

	originalIO.bodyModsReapplyOnSpawn = function(newCharacter)
		Spawn(function()
			const humanoid = newCharacter:WaitForChild("Humanoid", 10)
			if state.boobs.active then
				Spawn(function()
					if originalIO.bodyModsWaitFor({ "UpperTorso", "Torso" }, 10) then
						originalIO.bodyModsApplyBoobs(state.boobs.size or 1)
					end
				end)
			end
			if state.ass.active then
				Spawn(function()
					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
						if originalIO.bodyModsWaitFor({ "LowerTorso" }, 10) then
							originalIO.bodyModsApplyAss(state.ass.size or 1)
						end
					else
						if originalIO.bodyModsWaitFor({ "Torso" }, 10) then
							originalIO.bodyModsApplyAss(state.ass.size or 1)
						end
					end
				end)
			end
			if state.pp.active then
				Spawn(function()
					if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
						if originalIO.bodyModsWaitFor({ "LowerTorso" }, 10) then
							originalIO.bodyModsApplyPP(state.pp.len or 1)
						end
					else
						if originalIO.bodyModsWaitFor({ "Torso" }, 10) then
							originalIO.bodyModsApplyPP(state.pp.len or 1)
						end
					end
				end)
			end
		end)
	end

	originalIO.bodyModsEnsureSpawnConnection = function()
		if state.spawnConn and state.spawnConn.Connected then
			return
		end
		state.spawnConn = Services.Players.LocalPlayer.CharacterAdded:Connect(originalIO.bodyModsReapplyOnSpawn)
	end

	originalIO.bodyModsEnsurePlayerAppearanceHook = function()
		state.apConn = originalIO.bodyModsDisconnectConnection(state.apConn)
		state.apConn = originalIO.bodyModsConnectAppearanceLoaded(Services.Players.LocalPlayer, originalIO.bodyModsOnAppearanceLoaded)
	end

	originalIO.bodyModsEnsurePlayerAppearanceHook()
	originalIO.bodyModsEnsureSpawnConnection()

	cmd.add({"boobs","boobies"},{"boobs <size> (boobies)","Boobs"},function(arg)
		local value = tonumber(arg) or state.boobs.size or 1
		value = math.clamp(value, 1, 8)
		originalIO.bodyModsApplyBoobs(value)
	end,true)

	cmd.add({"unboobs","unboobies","noboobs","noboobies"},{"unboobs (unboobies,noboobs,noboobies)","Boobs"},function()
		originalIO.bodyModsRemoveBoobs()
	end)

	cmd.add({"ass","booty"},{"ass <size> (booty)","Ass"},function(arg)
		local value = tonumber(arg) or state.ass.size or 1
		value = math.clamp(value, 1, 8)
		originalIO.bodyModsApplyAss(value)
	end,true)

	cmd.add({"unass","noass"},{"unass (noass)","Ass"},function()
		originalIO.bodyModsRemoveAss()
	end)

	cmd.add({"penis","pp"},{"penis <length> (pp)","penis"},function(arg)
		local value = tonumber(arg) or state.pp.len or 1
		value = math.clamp(value, 0.5, 6)
		originalIO.bodyModsApplyPP(value)
	end,true)

	cmd.add({"unpenis","unpp","nopenis","nopp"},{"unpenis (unpp,nopenis,nopp)","penis"},function()
		originalIO.bodyModsRemovePP()
	end)
end

-- [[ NPC SECTION ]] --
cmd.add({"flingnpcs"}, {"flingnpcs", "Flings NPCs"}, function()
	const npcs = {}

	const function disappear(hum)
		if CheckIfNPC(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			hum.HipHeight = 1024
		end
	end
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		disappear(hum)
	end
end)

cmd.add({"npcfollow"}, {"npcfollow", "Makes NPCS follow you"}, function()
	const npcs = {}

	const function disappear(hum)
		if CheckIfNPC(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			const rootPart = getRoot(hum.Parent)
			const targetPos = getRoot(LocalPlayer.Character).Position
			hum:MoveTo(targetPos)
		end
	end
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		disappear(hum)
	end
end)

npcfollowloop = false
cmd.add({"loopnpcfollow"}, {"loopnpcfollow", "Makes NPCS follow you in a loop"}, function()
	npcfollowloop = true

	repeat Wait(0.1)
		const npcs = {}

		const function disappear(hum)
			if CheckIfNPC(hum.Parent) then
				Insert(npcs,{hum,hum.HipHeight})
				const rootPart = getRoot(hum.Parent)
				const targetPos = getRoot(LocalPlayer.Character).Position
				hum:MoveTo(targetPos)
			end
		end
		for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
			disappear(hum)
		end
	until npcfollowloop == false
end)

cmd.add({"unloopnpcfollow"}, {"unloopnpcfollow", "Makes NPCS not follow you in a loop"}, function()
	npcfollowloop = false
end)

cmd.add({"sitnpcs"}, {"sitnpcs", "Makes NPCS sit"}, function()
	const npcs = {}

	const function disappear(hum)
		if CheckIfNPC(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			const rootPart = getRoot(hum.Parent)
			if rootPart then
				hum.Sit = true
			end
		end
	end
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		disappear(hum)
	end
end)

cmd.add({"unsitnpcs"}, {"unsitnpcs", "Makes NPCS unsit"}, function()
	const npcs = {}

	const function disappear(hum)
		if CheckIfNPC(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			const rootPart = getRoot(hum.Parent)
			if rootPart then
				hum.Sit = true
			end
		end
	end
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		disappear(hum)
	end
end)

cmd.add({"killnpcs"}, {"killnpcs", "Kills NPCs"}, function()
	const npcs = {}

	const function disappear(hum)
		if CheckIfNPC(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			const rootPart = getRoot(hum.Parent)
			if rootPart then
				hum.Health = 0
			end
		end
	end
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		disappear(hum)
	end
end)

cmd.add({"npcwalkspeed","npcws"},{"npcwalkspeed <speed>","Sets all NPC WalkSpeed to <speed> (default 16)"},function(speedStr)
	const speed = tonumber(speedStr) or 16
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		if CheckIfNPC(hum.Parent) then
			const root = getRoot(hum.Parent)
			if root then hum.WalkSpeed = speed end
		end
	end
end,true)

cmd.add({"npcjumppower","npcjp"},{"npcjumppower <power>","Sets all NPC JumpPower to <power> (default 50)"},function(powerStr)
	const power=tonumber(powerStr) or 50
	for _,hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		if CheckIfNPC(hum.Parent) then
			const root=getRoot(hum.Parent)
			if root then hum.JumpPower=power end
		end
	end
end,true)

cmd.add({"bringnpcs"}, {"bringnpcs [distance]", "Brings NPCs"}, function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 0)
	const npcs = {}

	const function disappear(hum)
		if CheckIfNPC(hum.Parent) then
			Insert(npcs,{hum,hum.HipHeight})
			const rootPart = getRoot(hum.Parent)
			const localRoot = LocalPlayer.Character and getRoot(LocalPlayer.Character)
			if rootPart and localRoot then
				rootPart.CFrame = NAmanage.bringOffsetCFrame(localRoot.CFrame, distance)
			end
		end
	end
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		disappear(hum)
	end
end)

npcCache = {}
cmd.add({"loopbringnpcs", "lbnpcs", "loopbnpcs", "lbringnpcs", "lbringnpc", "loopbringnpc"}, {"loopbringnpcs [distance] (lbnpcs, loopbnpcs, lbringnpcs)", "Loops NPC bringing"}, function(...)
	const args = {...}
	const distance = NAmanage.parseBringDistance(args, 0)
	if NAlib.isConnected("loopbringnpcs") then NAlib.disconnect("loopbringnpcs") end
	table.clear(npcCache)
	for _, hum in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		if CheckIfNPC(hum.Parent) then
			Insert(npcCache, hum)
		end
	end

	NAlib.connect("loopbringnpcs", Services.RunService.RenderStepped:Connect(function()
		local w = 1
		for i = 1, #npcCache do
			const hum = npcCache[i]
			if hum and hum.Parent and hum.Health > 0 then
				npcCache[w] = hum
				w += 1
				const model = hum.Parent
				const rootPart = getRoot(model)
				const localRoot = LocalPlayer.Character and getRoot(LocalPlayer.Character)
				if rootPart and localRoot then
					rootPart.CFrame = NAmanage.bringOffsetCFrame(localRoot.CFrame, distance)
				end
				SpawnCall(function()
					for _, part in NAmanage.QueryDescendants(model, "BasePart") do
						if NAlib.isProperty(part, "CanCollide") then
							NAlib.setProperty(part, "CanCollide", false)
						end
					end
				end)
			end
		end
		for i = w, #npcCache do
			npcCache[i] = nil
		end
	end))
end)

cmd.add({"unloopbringnpcs", "unlbnpcs", "unloopbnpcs", "unlbringnpcs", "unlbringnpc", "unloopbringnpc"}, {"unloopbringnpcs (unlbnpcs, unloopbnpcs, unlbringnpcs)", "Stops NPC bring loop"}, function()
	NAlib.disconnect("loopbringnpcs")
	if type(npcCache) == "table" then
		table.clear(npcCache)
	end
end)

cmd.add({"gotonpcs"}, {"gotonpcs", "Teleports to each NPC"}, function()
	const LocalPlayer = Services.Players.LocalPlayer
	const npcs = {}
	for _, d in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		if CheckIfNPC(d.Parent) then
			const root = getRoot(d.Parent)
			if root then
				Insert(npcs, root)
			end
		end
	end
	SpawnCall(function()
		for _, npcRoot in npcs do
			const char = LocalPlayer.Character
			if char and getRoot(char) then
				getRoot(char).CFrame = npcRoot.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end)
end)

NAStuff.NPCControl = {
	Enabled = false,
	Connection = nil,
	CurrentTarget = nil,
	MoveCooldown = 0
}

NPCControl = NAStuff.NPCControl

cmd.add({"actnpc"}, {"actnpc", "Start acting like an NPC"}, function()
	if NPCControl.Enabled then return end
	NPCControl.Enabled = true

	const function moveToRandom()
		const char = LocalPlayer.Character
		const hum = getHum()
		const root = getRoot(char)
		if not (char and hum and root) then return end

		const randomOffset = Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))
		const targetPos = root.Position + randomOffset

		NPCControl.CurrentTarget = targetPos
		hum:MoveTo(targetPos)

		DebugNotif("Moving to: "..Format("X: %.0f, Y: %.0f, Z: %.0f", targetPos.X, targetPos.Y, targetPos.Z), 1.5)
	end

	NPCControl.Connection = NAlib.reconnect("actnpc_loop", Services.RunService.Heartbeat:Connect(function(dt)
		const char = LocalPlayer.Character
		const hum = getHum()
		const root = getRoot(char)
		if not (char and hum and root) then return end

		NPCControl.MoveCooldown=NPCControl.MoveCooldown - dt
		NPCControl._jumpCooldown = (NPCControl._jumpCooldown or 0) - dt
		NPCControl._moveTimeout = (NPCControl._moveTimeout or 0) + dt

		if hum.Sit then
			DebugNotif("Sitting detected — jumping to escape", 1.5)
			hum.Sit = false
			NAmanage.LaunchHumanoid(hum, root)
			NPCControl._jumpCooldown = 1.5
			return
		end

		if NPCControl.CurrentTarget and (root.Position - NPCControl.CurrentTarget).Magnitude < 2 then
			DebugNotif("Reached target", 1.5)
			NPCControl.CurrentTarget = nil
		end

		if not NPCControl.CurrentTarget or NPCControl._moveTimeout > 5 then
			if NPCControl._moveTimeout > 5 then
				DebugNotif("Stuck — retrying new path", 1.5)
			end
			if NPCControl.MoveCooldown <= 0 then
				moveToRandom()
				NPCControl.MoveCooldown = math.random(2, 4)
				NPCControl._moveTimeout = 0
			end
		end

		const forward = root.CFrame.LookVector
		const origin = root.Position + Vector3.new(0, 2, 0)
		const rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		rayParams.FilterDescendantsInstances = {char}
		const result = Services.Workspace:Raycast(origin, forward * 3 + Vector3.new(0, -2, 0), rayParams)

		if result and NPCControl._jumpCooldown <= 0 then
			const part = result.Instance
			const model = part:FindFirstAncestorOfClass("Model")
			const isPlayerChar = model and __lt.cm("Players", "GetPlayerFromCharacter", model)

			if part.CanCollide and not isPlayerChar then
				if hum:GetState() == Enum.HumanoidStateType.Running then
					DebugNotif("Obstacle detected — jumping", 1.5)
					NAmanage.LaunchHumanoid(hum, root)
					NPCControl._jumpCooldown = 1.5
				end
			end
		end
	end))
end)

cmd.add({"unactnpc", "stopnpc"}, {"unactnpc (stopnpc)", "Stop acting like an NPC"}, function()
	if not NPCControl.Enabled then return end
	NPCControl.Enabled = false
	if NPCControl.Connection then
		NPCControl.Connection:Disconnect()
		NPCControl.Connection = nil
	end
	NAlib.disconnect("actnpc_loop")
end)

NAStuff.clicktouchUI = nil
NAStuff.clicktouchEnabled = false
NAStuff.clicktouchTargetPart = nil
NAStuff.clicktouchTargetTouch = nil

NAmanage.ClickTouchClearVisuals = function()
	NAStuff.clicktouchTargetPart = nil
	NAStuff.clicktouchTargetTouch = nil
	const ui = NAStuff.clicktouchUI
	if not ui then
		return
	end
	const box = ui:FindFirstChild("TargetBox")
	if box then
		box.Adornee = nil
	end
	const label = ui:FindFirstChild("TargetLabel")
	if label then
		label.Text = "No touch target"
	end
end

NAmanage.ClickTouchSetVisualTarget = function(part, ti)
	const ui = NAStuff.clicktouchUI
	if not ui then
		return
	end
	NAStuff.clicktouchTargetPart = part
	NAStuff.clicktouchTargetTouch = ti
	const name = (part and ti) and NAmanage.ClickTouchName(ti, part) or "No touch target"
	const label = ui:FindFirstChild("TargetLabel")
	if label then
		label.Text = name
	end
	const cfg = NAmanage.ClickTouchGetConfig()
	const box = ui:FindFirstChild("TargetBox")
	if box then
		box.Adornee = part
		box.AlwaysOnTop = cfg.alwaysOnTop == true
		if part then
			box.Size = part.Size
		end
	end
end

NAmanage.ClickTouchMouseOverPanel = function(mouse)
	const ui = NAStuff.clicktouchUI
	const panel = ui and ui:FindFirstChild("ToggleButton")
	if not (panel and mouse) then
		return false
	end
	const x = tonumber(mouse.X) or 0
	const y = tonumber(mouse.Y) or 0
	const pos, size = panel.AbsolutePosition, panel.AbsoluteSize
	return x >= pos.X and x <= pos.X + size.X and y >= pos.Y and y <= pos.Y + size.Y
end

NAmanage.ClickTouchStop = function()
	NAStuff.clicktouchEnabled = false
	NAlib.disconnect("clicktouch_mouse")
	NAlib.disconnect("clicktouch_track")
	if NAStuff.clicktouchUI then
		NAStuff.clicktouchUI:Destroy()
		NAStuff.clicktouchUI = nil
	end
	NAStuff.clicktouchTargetPart = nil
	NAStuff.clicktouchTargetTouch = nil
end

cmd.add({"clicktouch", "ctouch"}, {"clicktouch (ctouch)", "Click a TouchTransmitter part to fire a touch"}, function()
	if typeof(firetouchinterest) ~= "function" then
		return DoNotif("firetouchinterest not available", 3)
	end
	NAStuff.clicktouchEnabled = true
	NAindex.init()

	if NAStuff.clicktouchUI then NAStuff.clicktouchUI:Destroy() end
	NAlib.disconnect("clicktouch_mouse")
	NAlib.disconnect("clicktouch_track")

	const Mouse = NAmanage.GetMouse(player)
	NAStuff.clicktouchUI = InstanceNew("ScreenGui")
	NAStuff.clicktouchUI.Name = "NAClickTouch"
	pcall(function()
		NAStuff.clicktouchUI.ResetOnSpawn = false
	end)
	NAgui.NaProtectUI(NAStuff.clicktouchUI)

	const toggleButton = InstanceNew("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0, 142, 0, 40)
	toggleButton.Text = "ClickTouch: ON"
	toggleButton.Position = UDim2.new(0.5, -71, 0, 54)
	toggleButton.TextScaled = true
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
	toggleButton.BackgroundTransparency = 0.18
	toggleButton.Parent = NAStuff.clicktouchUI

	const uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = toggleButton

	const targetLabel = InstanceNew("TextLabel")
	targetLabel.Name = "TargetLabel"
	targetLabel.Size = UDim2.new(0, 300, 0, 26)
	targetLabel.Position = UDim2.new(0.5, -150, 0, 98)
	targetLabel.BackgroundTransparency = 1
	targetLabel.Text = "No touch target"
	targetLabel.TextScaled = true
	targetLabel.TextColor3 = Color3.fromRGB(255, 235, 120)
	targetLabel.TextStrokeTransparency = 0.25
	targetLabel.Font = Enum.Font.GothamBold
	targetLabel.Parent = NAStuff.clicktouchUI

	local okBox, box = pcall(InstanceNew, "BoxHandleAdornment")
	if okBox and box then
		box.Name = "TargetBox"
		box.Color3 = Color3.fromRGB(255, 214, 64)
		box.Transparency = 0.35
		box.ZIndex = 10
		box.AlwaysOnTop = NAStuff.ClickTouchAlwaysOnTop == true
		box.Parent = NAStuff.clicktouchUI
	end

	NAgui.draggerV2(toggleButton)

	MouseButtonFix(toggleButton, function()
		NAStuff.clicktouchEnabled = not NAStuff.clicktouchEnabled
		toggleButton.Text = NAStuff.clicktouchEnabled and "ClickTouch: ON" or "ClickTouch: OFF"
		if not NAStuff.clicktouchEnabled then
			NAmanage.ClickTouchClearVisuals()
		end
	end)

	local lastScan = 0
	NAlib.connect("clicktouch_track", Services.RunService.RenderStepped:Connect(function()
		if not NAStuff.clicktouchEnabled then
			return
		end
		const now = tick()
		if now - lastScan < 0.04 then
			return
		end
		lastScan = now
		local part, ti = NAmanage.ClickTouchPickTarget(Mouse, { player and player.Character })
		if part ~= NAStuff.clicktouchTargetPart or ti ~= NAStuff.clicktouchTargetTouch then
			NAmanage.ClickTouchSetVisualTarget(part, ti)
		end
	end))

	NAlib.connect("clicktouch_mouse", Mouse.Button1Down:Connect(function()
		if not NAStuff.clicktouchEnabled then return end
		if NAmanage.ClickTouchMouseOverPanel(Mouse) then return end
		local part, ti = NAmanage.ClickTouchPickTarget(Mouse, { player and player.Character })
		if part and ti then
			NAmanage.ClickTouchSetVisualTarget(part, ti)
			local ok, err = NAmanage.ClickTouchFire(part)
			if ok then
				DebugNotif("Touched "..NAmanage.ClickTouchName(ti, part), 2)
			else
				DoNotif(tostring(err or "Failed to fire touch"), 3)
			end
		end
	end))
end)

cmd.add({"unclicktouch", "unctouch"}, {"unclicktouch (unctouch)", "Disable clicktouch"}, function()
	NAmanage.ClickTouchStop()
end)

NAStuff.clickkillUI = nil
NAStuff.clickkillEnabled = false

cmd.add({"clickkillnpc", "cknpc"}, {"clickkillnpc (cknpc)", "Click on an NPC to kill it"}, function()
	NAStuff.clickkillEnabled = true

	if NAStuff.clickkillUI then NAStuff.clickkillUI:Destroy() end
	NAlib.disconnect("clickkill_mouse")

	const Mouse = NAmanage.GetMouse(player)

	NAStuff.clickkillUI = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(NAStuff.clickkillUI)

	const toggleButton = InstanceNew("TextButton")
	toggleButton.Size = UDim2.new(0, 120, 0, 40)
	toggleButton.Text = "ClickKill: ON"
	toggleButton.Position = UDim2.new(0.5, -60, 0, 10)
	toggleButton.TextScaled = 16
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	toggleButton.BackgroundTransparency = 0.2
	toggleButton.Parent = NAStuff.clickkillUI

	const uiCorner = InstanceNew("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = toggleButton

	NAgui.draggerV2(toggleButton)

	MouseButtonFix(toggleButton, function()
		NAStuff.clickkillEnabled = not NAStuff.clickkillEnabled
		toggleButton.Text = NAStuff.clickkillEnabled and "ClickKill: ON" or "ClickKill: OFF"
	end)

	NAlib.connect("clickkill_mouse", Mouse.Button1Down:Connect(function()
		if not NAStuff.clickkillEnabled then return end

		const Target = NAmanage.GetMouseTargetPart(Mouse, { player and player.Character }, 1024)
		const Character = NAmanage.ResolveHumanoidModelFromPart(Target)
		if Character and CheckIfNPC(Character) then
			const Humanoid = getPlrHum(Character)
			if Humanoid then
				Humanoid.Health = 0
			end
		end
	end))
end)

cmd.add({"unclickkillnpc", "uncknpc"}, {"unclickkillnpc (uncknpc)", "Disable clickkillnpc"}, function()
	NAStuff.clickkillEnabled = false
	if NAStuff.clickkillUI then NAStuff.clickkillUI:Destroy() end
	NAlib.disconnect("clickkill_mouse")
end)

cmd.add({"voidnpcs", "vnpcs"}, {"voidnpcs (vnpcs)", "Teleports NPC's to void"}, function()
	for _, d in NAmanage.QueryDescendants(Services.Workspace, "Humanoid") do
		if CheckIfNPC(d.Parent) then
			const root = getPlrHum(d.Parent)
			if root then
				root.HipHeight = math.huge
			end
		end
	end
end)

clickVoidUI = nil
clickVoidEnabled = false

cmd.add({"clickvoidnpc", "cvnpc"}, {"clickvoidnpc (cvnpc)", "Click to void NPCs"}, function()
	clickVoidEnabled = true

	if clickVoidUI then clickVoidUI:Destroy() end
	NAlib.disconnect("clickvoid_mouse")

	clickVoidUI = InstanceNew("ScreenGui")
	NAgui.NaProtectUI(clickVoidUI)

	const button = InstanceNew("TextButton")
	button.Size = UDim2.new(0, 120, 0, 40)
	button.Text = "ClickVoid: ON"
	button.Position = UDim2.new(0.5, -60, 0, 10)
	button.TextScaled = true
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.GothamBold
	button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	button.BackgroundTransparency = 0.2
	button.Parent = clickVoidUI

	const corner = InstanceNew("UICorner", button)
	corner.CornerRadius = UDim.new(0, 6)
	NAgui.draggerV2(button)

	MouseButtonFix(button, function()
		clickVoidEnabled = not clickVoidEnabled
		button.Text = clickVoidEnabled and "ClickVoid: ON" or "ClickVoid: OFF"
	end)

	const mouse = NAmanage.GetMouse(player)
	NAlib.connect("clickvoid_mouse", mouse.Button1Down:Connect(function()
		if not clickVoidEnabled then return end

		const target = NAmanage.GetMouseTargetPart(mouse, { player and player.Character }, 1024)
		const character = NAmanage.ResolveHumanoidModelFromPart(target)
		if character and CheckIfNPC(character) then
			const root = getPlrHum(character)
			if root then
				root.HipHeight = math.huge
			end
		end
	end))
end)

cmd.add({"unclickvoidnpc", "uncvnpc"}, {"unclickvoidnpc (uncvnpc)","Disable click-void"}, function()
	clickVoidEnabled = false
	if clickVoidUI then clickVoidUI:Destroy() end
	NAlib.disconnect("clickvoid_mouse")
end)

clickSpeedUI,clickSpeedEnabled=nil,false

cmd.add({"clicknpcws","cnpcws"},{"clicknpcws","Click on an NPC to set its WalkSpeed"},function()
	clickSpeedEnabled=true
	if clickSpeedUI then clickSpeedUI:Destroy() end
	NAlib.disconnect("clickspeed_mouse")
	const player=Services.Players.LocalPlayer
	const mouse=NAmanage.GetMouse(player)
	clickSpeedUI=InstanceNew("ScreenGui")
	NAgui.NaProtectUI(clickSpeedUI)
	const btn=InstanceNew("TextButton")
	btn.Size=UDim2.new(0,120,0,40)
	btn.Position=UDim2.new(0.5,-130,0,10)
	btn.Text="SetSpeed: ON"
	btn.TextSize=16
	btn.TextColor3=Color3.new(1,1,1)
	btn.Font=Enum.Font.GothamBold
	btn.BackgroundColor3=Color3.fromRGB(40,40,40)
	btn.BackgroundTransparency=0.2
	btn.Parent=clickSpeedUI
	const cor1=InstanceNew("UICorner")
	cor1.CornerRadius=UDim.new(0, 6)
	cor1.Parent=btn
	NAgui.draggerV2(btn)
	const tb=InstanceNew("TextBox")
	tb.Size=UDim2.new(0,120,0,40)
	tb.Position=UDim2.new(0.5,10,0,10)
	tb.Text="16"
	tb.PlaceholderText="Speed"
	tb.TextSize=16
	tb.TextColor3=Color3.new(1,1,1)
	tb.Font=Enum.Font.Gotham
	tb.BackgroundColor3=Color3.fromRGB(50,50,50)
	tb.BackgroundTransparency=0.2
	tb.Parent=clickSpeedUI
	const cor2=InstanceNew("UICorner")
	cor2.CornerRadius=UDim.new(0, 6)
	cor2.Parent=tb
	NAgui.draggerV2(tb)
	local speedNumber=16
	tb.FocusLost:Connect(function(enterPressed)
		const n=tonumber(tb.Text)
		if n then speedNumber=n else tb.Text=tostring(speedNumber) end
	end)
	MouseButtonFix(btn,function()
		clickSpeedEnabled=not clickSpeedEnabled
		btn.Text=clickSpeedEnabled and "SetSpeed: ON" or "SetSpeed: OFF"
	end)
	NAlib.connect("clickspeed_mouse",mouse.Button1Down:Connect(function()
		if not clickSpeedEnabled then return end
		const hit=NAmanage.GetMouseTargetPart(mouse, { player and player.Character }, 1024)
		const character=NAmanage.ResolveHumanoidModelFromPart(hit)
		if character and CheckIfNPC(character) then
			const hum=getPlrHum(character)
			if hum then hum.WalkSpeed=speedNumber end
		end
	end))
end)

cmd.add({"unclicknpcws","uncnpcws"},{"unclicknpcws","Disable clicknpcws"},function()
	clickSpeedEnabled=false
	if clickSpeedUI then clickSpeedUI:Destroy() end
	NAlib.disconnect("clickspeed_mouse")
end)

clickJumpUI,clickJumpEnabled=nil,false

cmd.add({"clicknpcjp","cnpcjp"},{"clicknpcjp","Click on an NPC to set its JumpPower"},function()
	clickJumpEnabled=true
	if clickJumpUI then clickJumpUI:Destroy() end
	NAlib.disconnect("clickjump_mouse")
	const player=Services.Players.LocalPlayer
	const mouse=NAmanage.GetMouse(player)
	clickJumpUI=InstanceNew("ScreenGui")
	NAgui.NaProtectUI(clickJumpUI)
	const btn=InstanceNew("TextButton")
	btn.Size=UDim2.new(0,120,0,40)
	btn.Position=UDim2.new(0.5,-130,0,10)
	btn.Text="SetJump: ON"
	btn.TextSize=16
	btn.TextColor3=Color3.new(1,1,1)
	btn.Font=Enum.Font.GothamBold
	btn.BackgroundColor3=Color3.fromRGB(40,40,40)
	btn.BackgroundTransparency=0.2
	btn.Parent=clickJumpUI
	const cor1=InstanceNew("UICorner")
	cor1.CornerRadius=UDim.new(0, 6)
	cor1.Parent=btn
	NAgui.draggerV2(btn)
	const tb=InstanceNew("TextBox")
	tb.Size=UDim2.new(0,120,0,40)
	tb.Position=UDim2.new(0.5,10,0,10)
	tb.Text="50"
	tb.PlaceholderText="JumpPower"
	tb.TextSize=16
	tb.TextColor3=Color3.new(1,1,1)
	tb.Font=Enum.Font.Gotham
	tb.BackgroundColor3=Color3.fromRGB(50,50,50)
	tb.BackgroundTransparency=0.2
	tb.Parent=clickJumpUI
	const cor2=InstanceNew("UICorner")
	cor2.CornerRadius=UDim.new(0, 6)
	cor2.Parent=tb
	NAgui.draggerV2(tb)
	local jumpPowerNumber=50
	tb.FocusLost:Connect(function(enterPressed)
		const n=tonumber(tb.Text)
		if n then jumpPowerNumber=n else tb.Text=tostring(jumpPowerNumber) end
	end)
	MouseButtonFix(btn,function()
		clickJumpEnabled=not clickJumpEnabled
		btn.Text=clickJumpEnabled and "SetJump: ON" or "SetJump: OFF"
	end)
	NAlib.connect("clickjump_mouse",mouse.Button1Down:Connect(function()
		if not clickJumpEnabled then return end
		const hit=NAmanage.GetMouseTargetPart(mouse, { player and player.Character }, 1024)
		const character=NAmanage.ResolveHumanoidModelFromPart(hit)
		if character and CheckIfNPC(character) then
			const hum=getPlrHum(character)
			if hum then hum.JumpPower=jumpPowerNumber end
		end
	end))
end)

cmd.add({"unclicknpcjp","uncnpcjp"},{"unclicknpcjp","Disable clicknpcjp"},function()
	clickJumpEnabled=false
	if clickJumpUI then clickJumpUI:Destroy() end
	NAlib.disconnect("clickjump_mouse")
end)

--[[ FUNCTIONALITY ]]--
NAlib.connect("local_player_chatted", LocalPlayer.Chatted:Connect(function(str)
	NAlib.parseCommand(str)
	NAmanage.ExecuteBindings("OnChatted", LocalPlayer, str)
end))

--[[ Admin Player]]
function IsAdminAndRun(Message, Player)
	if not Player then
		return
	end
	const userId = Player.UserId
	const adminMap = type(Admin) == "table" and Admin or {}
	if (userId and adminMap[userId]) or isRelAdmin(Player) then
		NAlib.parseCommand(Message, Player)
	end
end

function CheckPermissions(Player)
	if not Player or not Player.Chatted then
		return
	end
	const chatKey = (NAmanage and NAmanage.lcKey and NAmanage.lcKey("adminPermission_chat", Player)) or ("adminPermission_chat_"..tostring(Player.UserId or Player))
	NAlib.disconnect(chatKey)
	NAlib.connect(chatKey, Player.Chatted:Connect(function(Message)
		IsAdminAndRun(Message,Player)
	end))
end

--[[function Getmodel(id)
	ob23e232323=nil
	s,r=NACaller(function()
		ob23e232323=game:GetObjects(id)[1]
	end)
	if s and ob23e232323 then
		return ob23e232323
	end
	Wait(1)
	warn("retrying")
	return Getmodel(id)
end]]

--[[ GUI VARIABLES ]]--
originalIO.NAfetchUILoaderSource=function()
	if NAmanage and NAmanage.uiSrcGet then
		return NAmanage.uiSrcGet(false)
	end
	return nil, "ui source helper unavailable"
end

do
	if type(NAmanage.pulseLoadingUI) == "function" then
		pcall(NAmanage.pulseLoadingUI, "starting interface loader", 0.970)
	end

	const gui = NAmanage.getUI and NAmanage.getUI() or nil
	if gui then
		NAmanage.NARegisterUI(gui)
	end

	const perf = NAStuff and NAStuff.StartupPerformance
	const uiLoadStart = os.clock()
	if type(perf) == "table" then
		perf.uiLoaderRunStarted = uiLoadStart
	end

	if not NAmanage.waitForScreenGui(0.15) then
		const maxTry = IsOnMobile == true and 3 or 4
		local attempt = 0
		local lastErr = nil
		local forcedRefreshUsed = false

		while not NAmanage.waitForScreenGui(0.05) and attempt < maxTry do
			attempt += 1

			if type(NAmanage.pulseLoadingUI) == "function" then
				pcall(NAmanage.pulseLoadingUI, "starting interface ("..tostring(attempt).."/"..tostring(maxTry)..")", 0.970 + math.min(attempt, maxTry) * 0.001)
			end

			local okRun, result = false, nil
			const attemptStart = os.clock()

			if NAmanage and NAmanage.uiRun then
				okRun, result = NAmanage.uiRun(false)
				if not okRun and not forcedRefreshUsed then
					forcedRefreshUsed = true
					NAStuff.uiFn = nil
					okRun, result = NAmanage.uiRun(true)
				end
			else
				local src, err = originalIO.NAfetchUILoaderSource()
				if not src then
					okRun, result = false, err
				else
					local fn, lerr = loadstring(src)
					if type(fn) == "function" then
						okRun, result = pcall(fn)
					else
						okRun, result = false, lerr
					end
				end
			end
			if type(perf) == "table" then
				const attempts = type(perf.uiRunAttempts) == "table" and perf.uiRunAttempts or {}
				perf.uiRunAttempts = attempts
				if #attempts < 12 then
					attempts[#attempts + 1] = {
						attempt = attempt;
						ok = okRun == true;
						elapsed = os.clock() - attemptStart;
					}
				end
			end

			if okRun then
				const registerStart = os.clock()
				const loaded = NAmanage.uiObj(result)
				if loaded and NAmanage.NARegisterUI(loaded) then
					if type(perf) == "table" then
						perf.uiRegisterElapsed = (tonumber(perf.uiRegisterElapsed) or 0) + (os.clock() - registerStart)
					end
					break
				end

				const delayedGui = NAmanage.waitForScreenGui(IsOnMobile == true and 0.65 or 0.35)
				if delayedGui and NAmanage.NARegisterUI(delayedGui) then
					if type(perf) == "table" then
						perf.uiRegisterElapsed = (tonumber(perf.uiRegisterElapsed) or 0) + (os.clock() - registerStart)
					end
					break
				end

				if type(perf) == "table" then
					perf.uiRegisterElapsed = (tonumber(perf.uiRegisterElapsed) or 0) + (os.clock() - registerStart)
				end

				lastErr = "UI loader returned " .. typeof(result)
			else
				lastErr = result
			end

			if attempt < maxTry and not NAmanage.waitForScreenGui(0.05) then
				warn(Format("%d | Failed to load UI module: %s | retrying cached loader...", math.random(1, 999999), tostring(lastErr)))
				Wait(0.12 + attempt * 0.08)
			end
		end

		if not NAmanage.waitForScreenGui(0.05) then
			warn(Format("%d | Failed to load UI module after %d attempts: %s", math.random(1, 999999), maxTry, tostring(lastErr)))
		end
	end
	if type(perf) == "table" then
		perf.uiLoaderRunElapsed = os.clock() - uiLoadStart
	end
end
rPlayer = __lt.cm("Players", "FindFirstChildWhichIsA", "Player")
coreGuiProtection = NAmanage.ensureWeakTable(coreGuiProtection, "k")
if not __lt.cm("RunService", "IsStudio") then
else
	repeat Wait() until player:FindFirstChild("AdminUI", true)
	NAStuff.NASCREENGUI = player:FindFirstChild("AdminUI", true)
	if NAStuff.NASCREENGUI and NAStuff.NASCREENGUI:IsA("ScreenGui") then
		NAStuff.uiBootHidden = true
		pcall(function()
			NAStuff.NASCREENGUI.Enabled = false
		end)
	end
end
--repeat Wait() until ScreenGui~=nil -- if it loads late then I'll just add this here

if NAmanage.pulseLoadingUI then
	NAmanage.pulseLoadingUI("waiting for interface", 0.975)
end

do
	const waitStart = os.clock()
	const ready = NAmanage.waitForScreenGui(8)
	const perf = NAStuff and NAStuff.StartupPerformance
	if type(perf) == "table" then
		perf.uiWaitElapsed = os.clock() - waitStart
		perf.uiWaitOk = ready ~= nil
	end
	if not ready then
		warn("[NA loader] UI never became a ScreenGui; stopping before NAUIMANAGER")
		if NAAssetsLoading and type(NAAssetsLoading.setStatus) == "function" then
			pcall(NAAssetsLoading.setStatus, "interface failed to load")
		end
		if NAAssetsLoading and NAAssetsLoading.completed then
			pcall(function()
				if typeof(NAAssetsLoading.completed) == "Instance" then
					NAmanage.SetAttr(NAAssetsLoading.completed, "Completed", true)
				else
					NAAssetsLoading.completed.Completed = true
				end
			end)
		end
		return
	end
	NAStuff.NASCREENGUI = ready
end

if NAStuff.NASCREENGUI and NAStuff.NASCREENGUI:IsA("ScreenGui") then
	NAStuff.uiBootHidden = true
	pcall(function()
		NAStuff.NASCREENGUI.Enabled = false
	end)
end

NAgui.NaProtectUI(NAStuff.NASCREENGUI)

uiManagerBuildStart = os.clock()
pcall(function()
	const probe = NAmanage.GetExternalLagProbe and NAmanage.GetExternalLagProbe()
	if type(probe) == "table" and type(probe.mark) == "function" then
		probe.mark("ui_manager_start")
	end
end)
local NAChatUIRoot = NAStuff.NASCREENGUI:FindFirstChild("NAChatUI")
local NAChatContainer = NAChatUIRoot and NAChatUIRoot:FindFirstChild("Container")
local NAChatTabs = NAChatUIRoot and NAChatUIRoot:FindFirstChild("Tabs")
local NAChatTopbar = NAChatUIRoot and NAChatUIRoot:FindFirstChild("Topbar")
local NAChatToolsBar = NAChatTopbar and NAChatTopbar:FindFirstChild("ToolsBar")
local NAChatMessageBar = NAChatUIRoot and NAChatUIRoot:FindFirstChild("MessageBar")
NAUIMANAGER = {
	description = NAStuff.NASCREENGUI:FindFirstChild("Description"),
	AUTOSCALER = NAStuff.NASCREENGUI:FindFirstChild("AutoScale"),
	cmdBar = NAStuff.NASCREENGUI:FindFirstChild("CmdBar"),
	centerBar = NAStuff.NASCREENGUI:FindFirstChild("CmdBar") and (NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("CenterBar"),
	cmdInput = NAStuff.NASCREENGUI:FindFirstChild("CmdBar") and (NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("CenterBar") and ((NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("CenterBar")):FindFirstChild("Input"),
	cmdAutofill = NAStuff.NASCREENGUI:FindFirstChild("CmdBar") and (NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("Autofill"),
	cmdExample = NAStuff.NASCREENGUI:FindFirstChild("CmdBar") and (NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("Autofill") and ((NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("Autofill")):FindFirstChildWhichIsA("Frame"),
	leftFill = NAStuff.NASCREENGUI:FindFirstChild("CmdBar") and (NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("LeftFill"),
	rightFill = NAStuff.NASCREENGUI:FindFirstChild("CmdBar") and (NAStuff.NASCREENGUI:FindFirstChild("CmdBar")):FindFirstChild("RightFill"),
	chatLogsFrame = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs"),
	chatLogs = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs") and (NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("Logs"),
	chatExample = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs") and (NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("Logs") and (((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("Logs")):FindFirstChildWhichIsA("TextLabel"),
	NAchatFrame = NAChatUIRoot,
	NAchatContent = NAChatContainer,
	NAchatChatScroll = NAChatContainer and NAChatContainer:FindFirstChild("ChatScroll"),
	NAchatUsersScroll = NAChatContainer and NAChatContainer:FindFirstChild("UsersScroll"),
	NAchatUsersSearch = NAChatContainer and NAChatContainer:FindFirstChild("UsersSearch"),
	NAchatListLayout = NAChatContainer and NAChatContainer:FindFirstChild("ChatScroll") and NAChatContainer:FindFirstChild("ChatScroll"):FindFirstChildWhichIsA("UIListLayout"),
	NAchatUserListLayout = NAChatContainer and NAChatContainer:FindFirstChild("UsersScroll") and NAChatContainer:FindFirstChild("UsersScroll"):FindFirstChildWhichIsA("UIListLayout"),
	NAchatInput = NAChatMessageBar and NAChatMessageBar:FindFirstChild("ChatInput"),
	NAchatSendButton = NAChatMessageBar and NAChatMessageBar:FindFirstChild("SendButton"),
	NAchatTranslateButton = (NAChatToolsBar and NAChatToolsBar:FindFirstChild("NAChatTranslate")) or (NAChatTopbar and NAChatTopbar:FindFirstChild("NAChatTranslate")),
	NAchatTranslateInput = (NAChatToolsBar and NAChatToolsBar:FindFirstChild("NAChatTranslateInput")) or (NAChatTopbar and NAChatTopbar:FindFirstChild("NAChatTranslateInput")),
	NAchatClearButton = (NAChatToolsBar and NAChatToolsBar:FindFirstChild("ClearChat")) or (NAChatTopbar and NAChatTopbar:FindFirstChild("ClearChat")),
	NAchatStatusLabel = NAChatMessageBar and NAChatMessageBar:FindFirstChild("ChatStatus"),
	NAchatReconnectButton = NAChatMessageBar and NAChatMessageBar:FindFirstChild("ReconnectButton"),
	NAchatDisconnectButton = NAChatMessageBar and NAChatMessageBar:FindFirstChild("DisconnectButton"),
	NAchatChatTab = NAChatTabs and NAChatTabs:FindFirstChild("ChatTab"),
	NAchatUsersTab = NAChatTabs and NAChatTabs:FindFirstChild("UsersTab"),
	NAchatVisibility = NAChatTabs and NAChatTabs:FindFirstChild("Visibility"),
	NAchatGameActivity = NAChatTabs and NAChatTabs:FindFirstChild("GameActivity"),
	NAchatDmNotifyButton = NAChatTabs and NAChatTabs:FindFirstChild("DMNotifs"),
	NAchatSettingsButton = NAChatTabs and NAChatTabs:FindFirstChild("Settings"),
	NAchatMessageCustomScrollBar = NAChatContainer and NAChatContainer:FindFirstChild("ChatCustomScrollBar"),
	NAchatMessageCustomScrollUp = NAChatContainer and NAChatContainer:FindFirstChild("ChatCustomScrollBar") and NAChatContainer:FindFirstChild("ChatCustomScrollBar"):FindFirstChild("Up"),
	NAchatMessageCustomScrollDown = NAChatContainer and NAChatContainer:FindFirstChild("ChatCustomScrollBar") and NAChatContainer:FindFirstChild("ChatCustomScrollBar"):FindFirstChild("Down"),
	NAchatMessageCustomScrollTrack = NAChatContainer and NAChatContainer:FindFirstChild("ChatCustomScrollBar") and NAChatContainer:FindFirstChild("ChatCustomScrollBar"):FindFirstChild("Track"),
	NAchatMessageCustomScrollThumb = NAChatContainer and NAChatContainer:FindFirstChild("ChatCustomScrollBar") and NAChatContainer:FindFirstChild("ChatCustomScrollBar"):FindFirstChild("Track") and NAChatContainer:FindFirstChild("ChatCustomScrollBar"):FindFirstChild("Track"):FindFirstChild("Thumb"),
	NAchatUsersCustomScrollBar = NAChatContainer and NAChatContainer:FindFirstChild("UsersCustomScrollBar"),
	NAchatUsersCustomScrollUp = NAChatContainer and NAChatContainer:FindFirstChild("UsersCustomScrollBar") and NAChatContainer:FindFirstChild("UsersCustomScrollBar"):FindFirstChild("Up"),
	NAchatUsersCustomScrollDown = NAChatContainer and NAChatContainer:FindFirstChild("UsersCustomScrollBar") and NAChatContainer:FindFirstChild("UsersCustomScrollBar"):FindFirstChild("Down"),
	NAchatUsersCustomScrollTrack = NAChatContainer and NAChatContainer:FindFirstChild("UsersCustomScrollBar") and NAChatContainer:FindFirstChild("UsersCustomScrollBar"):FindFirstChild("Track"),
	NAchatUsersCustomScrollThumb = NAChatContainer and NAChatContainer:FindFirstChild("UsersCustomScrollBar") and NAChatContainer:FindFirstChild("UsersCustomScrollBar"):FindFirstChild("Track") and NAChatContainer:FindFirstChild("UsersCustomScrollBar"):FindFirstChild("Track"):FindFirstChild("Thumb"),
	ChatCustomScrollBar = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs") and (NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar"),
	ChatCustomScrollUp = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs") and (NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Up"),
	ChatCustomScrollDown = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs") and (NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Down"),
	ChatCustomScrollTrack = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs") and (NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track"),
	ChatCustomScrollThumb = NAStuff.NASCREENGUI:FindFirstChild("ChatLogs") and (NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track") and ((((NAStuff.NASCREENGUI:FindFirstChild("ChatLogs")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track")):FindFirstChild("Thumb"),
	NAconsoleFrame = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole"),
	NAconsoleLogs = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("Logs"),
	NAconsoleExample = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("Logs") and (((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("Logs")):FindFirstChildWhichIsA("TextLabel"),
	NAcontainer = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container"),
	NAfilter = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("Filter"),
	ConsoleCustomScrollBar = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar"),
	ConsoleCustomScrollUp = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Up"),
	ConsoleCustomScrollDown = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Down"),
	ConsoleCustomScrollTrack = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track"),
	ConsoleCustomScrollThumb = NAStuff.NASCREENGUI:FindFirstChild("soRealConsole") and (NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track") and ((((NAStuff.NASCREENGUI:FindFirstChild("soRealConsole")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track")):FindFirstChild("Thumb"),
	commandsFrame = NAStuff.NASCREENGUI:FindFirstChild("Commands"),
	commandsFilter = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("Filter"),
	commandsList = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("List"),
	commandExample = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("List") and (((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("List")):FindFirstChild("TextLabel"),
	CommandsCustomScrollBar = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar"),
	CommandsCustomScrollUp = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Up"),
	CommandsCustomScrollDown = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Down"),
	CommandsCustomScrollTrack = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track"),
	CommandsCustomScrollThumb = NAStuff.NASCREENGUI:FindFirstChild("Commands") and (NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track") and ((((NAStuff.NASCREENGUI:FindFirstChild("Commands")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track")):FindFirstChild("Thumb"),
	CommandKeybindsFrame = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds"),
	CommandKeybindsContainer = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds") and (NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container"),
	CommandKeybindsList = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds") and (NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("List"),
	CommandKeybindsCustomScrollBar = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds") and (NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar"),
	CommandKeybindsCustomScrollUp = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds") and (NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Up"),
	CommandKeybindsCustomScrollDown = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds") and (NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Down"),
	CommandKeybindsCustomScrollTrack = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds") and (NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track"),
	CommandKeybindsCustomScrollThumb = NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds") and (NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track") and ((((NAStuff.NASCREENGUI:FindFirstChild("CommandKeybinds")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track")):FindFirstChild("Thumb"),
	resizeFrame = NAStuff.NASCREENGUI:FindFirstChild("Resizeable"),
	ModalFixer = NAStuff.NASCREENGUI:FindFirstChildWhichIsA("ImageButton"),
	SettingsFrame = NAStuff.NASCREENGUI:FindFirstChild("setsettings"),
	SettingsContainer = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container"),
	SettingsTabContainer = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer"),
	SettingsTabs = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("TabList"),
	SettingsPages = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages"),
	SettingsList = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List"),
	SettingsSearchBox = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("SearchBox"),
	SettingsTabButton = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("TabList") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("TabList")):FindFirstChild("TabButton"),
	SettingsButton = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("Button"),
	SettingsColorPicker = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("ColorPicker"),
	SettingsSectionTitle = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("SectionTitle"),
	SettingsToggle = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("Toggle"),
	SettingsInput = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("Input"),
	SettingsKeybind = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("Keybind"),
	SettingsSlider = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("Slider"),
	SettingsDropdown = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("List")):FindFirstChild("Dropdown"),
	SettingsCustomScrollBar = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar"),
	SettingsCustomScrollUp = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar")):FindFirstChild("Up"),
	SettingsCustomScrollDown = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar")):FindFirstChild("Down"),
	SettingsCustomScrollTrack = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track"),
	SettingsCustomScrollThumb = NAStuff.NASCREENGUI:FindFirstChild("setsettings") and (NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer") and (((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages") and ((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar") and (((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track") and ((((((NAStuff.NASCREENGUI:FindFirstChild("setsettings")):FindFirstChild("Container")):FindFirstChild("TabContainer")):FindFirstChild("Pages")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track")):FindFirstChild("Thumb"),
	WaypointFrame = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint"),
	WaypointContainer = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container"),
	WaypointList = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("List"),
	filterBox = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("Filter"),
	WaypointNameBox = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("NameInput"),
	WaypointCoordBox = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CoordInput"),
	WaypointSetBtn = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("SetBtn"),
	WaypointCurrentBtn = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CurrentBtn"),
	WPFrame = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("List") and (((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("List")):FindFirstChild("WP"),
	WaypointCustomScrollBar = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar"),
	WaypointCustomScrollUp = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Up"),
	WaypointCustomScrollDown = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Down"),
	WaypointCustomScrollTrack = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track"),
	WaypointCustomScrollThumb = NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint") and (NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track") and ((((NAStuff.NASCREENGUI:FindFirstChild("SuchWaypoint")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track")):FindFirstChild("Thumb"),
	BindersFrame = NAStuff.NASCREENGUI:FindFirstChild("binders"),
	BindersContainer = NAStuff.NASCREENGUI:FindFirstChild("binders") and (NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container"),
	BindersList = NAStuff.NASCREENGUI:FindFirstChild("binders") and (NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("List"),
	BindersCustomScrollBar = NAStuff.NASCREENGUI:FindFirstChild("binders") and (NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar"),
	BindersCustomScrollUp = NAStuff.NASCREENGUI:FindFirstChild("binders") and (NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Up"),
	BindersCustomScrollDown = NAStuff.NASCREENGUI:FindFirstChild("binders") and (NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Down"),
	BindersCustomScrollTrack = NAStuff.NASCREENGUI:FindFirstChild("binders") and (NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track"),
	BindersCustomScrollThumb = NAStuff.NASCREENGUI:FindFirstChild("binders") and (NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar") and (((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track") and ((((NAStuff.NASCREENGUI:FindFirstChild("binders")):FindFirstChild("Container")):FindFirstChild("CustomScrollBar")):FindFirstChild("Track")):FindFirstChild("Thumb"),
	ExecutorFrame = NAStuff.NASCREENGUI:FindFirstChild("Executor"),
	ExecutorContainer = NAStuff.NASCREENGUI:FindFirstChild("Executor") and (NAStuff.NASCREENGUI:FindFirstChild("Executor")):FindFirstChild("Container"),
	NotepadFrame = NAStuff.NASCREENGUI:FindFirstChild("Notepad"),
	NotepadContainer = NAStuff.NASCREENGUI:FindFirstChild("Notepad") and (NAStuff.NASCREENGUI:FindFirstChild("Notepad")):FindFirstChild("Container"),
	PluginsFrame = NAStuff.NASCREENGUI:FindFirstChild("Plugins"),
	PluginsContainer = NAStuff.NASCREENGUI:FindFirstChild("Plugins") and (NAStuff.NASCREENGUI:FindFirstChild("Plugins")):FindFirstChild("Container"),
	PluginsList = NAStuff.NASCREENGUI:FindFirstChild("Plugins") and (NAStuff.NASCREENGUI:FindFirstChild("Plugins")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Plugins")):FindFirstChild("Container")):FindFirstChild("List"),
	PluginsFilter = NAStuff.NASCREENGUI:FindFirstChild("Plugins") and (NAStuff.NASCREENGUI:FindFirstChild("Plugins")):FindFirstChild("Container") and ((NAStuff.NASCREENGUI:FindFirstChild("Plugins")):FindFirstChild("Container")):FindFirstChild("Filter"),
	MusicFrame = NAStuff.NASCREENGUI:FindFirstChild("MusicPlayer"),
	MusicContainer = NAStuff.NASCREENGUI:FindFirstChild("MusicPlayer") and (NAStuff.NASCREENGUI:FindFirstChild("MusicPlayer")):FindFirstChild("Container"),
	ScriptHubFrame = NAStuff.NASCREENGUI:FindFirstChild("ScriptHub"),
	ScriptHubContainer = NAStuff.NASCREENGUI:FindFirstChild("ScriptHub") and (NAStuff.NASCREENGUI:FindFirstChild("ScriptHub")):FindFirstChild("Container"),
	SubplaceViewerFrame = NAStuff.NASCREENGUI:FindFirstChild("SubplaceViewer"),
	SubplaceViewerContainer = NAStuff.NASCREENGUI:FindFirstChild("SubplaceViewer") and (NAStuff.NASCREENGUI:FindFirstChild("SubplaceViewer")):FindFirstChild("Container"),
	ServerListFrame = NAStuff.NASCREENGUI:FindFirstChild("ServerList"),
	ServerListContainer = NAStuff.NASCREENGUI:FindFirstChild("ServerList") and (NAStuff.NASCREENGUI:FindFirstChild("ServerList")):FindFirstChild("Container")
};

NAmanage.NAChatNormalizeZIndex = function()
	local frame = NAUIMANAGER and NAUIMANAGER.NAchatFrame
	if not (frame and frame.Parent) then
		return
	end
	local topbar = frame:FindFirstChild("Topbar")
	local tabs = frame:FindFirstChild("Tabs")
	local container = frame:FindFirstChild("Container")
	local messageBar = frame:FindFirstChild("MessageBar")
	local groupPopup = frame:FindFirstChild("NAChatGroupPopup")
	local invitePrompt = frame:FindFirstChild("NAChatInvitePrompt")
	frame.ZIndex = 0
	for _, item in ipairs(frame:GetDescendants()) do
		if item:IsA("GuiObject") then
			local layer = 10
			if (groupPopup and (item == groupPopup or item:IsDescendantOf(groupPopup))) or (invitePrompt and (item == invitePrompt or item:IsDescendantOf(invitePrompt))) then
				layer = 60
			elseif topbar and item:IsDescendantOf(topbar) then
				layer = 50
			elseif messageBar and item:IsDescendantOf(messageBar) then
				layer = 50
			elseif tabs and item:IsDescendantOf(tabs) then
				layer = 40
			elseif container and item:IsDescendantOf(container) then
				layer = 30
			end
			if item:GetAttribute("NAWindowBackgroundLayer") == true then
				layer = 0
			end
			item.ZIndex = layer
		end
	end
end

if NAUIMANAGER.NAchatFrame and not NAStuff.NAChatZIndexConnection then
	NAStuff.NAChatZIndexConnection = NAUIMANAGER.NAchatFrame.DescendantAdded:Connect(function()
		Defer(function()
			if NAmanage.NAChatNormalizeZIndex then
				NAmanage.NAChatNormalizeZIndex()
			end
		end)
	end)
end
NAmanage.NAChatNormalizeZIndex()
NAmanage.ScriptHub = type(NAmanage.ScriptHub) == "table" and NAmanage.ScriptHub or {}
NAmanage.ScriptHub.engines = { "RScripts", "RobloxScripts", "HaxHell", "ScriptBlox" }
NAmanage.ScriptHub.filterModes = { "all", "keyless", "key" }
NAmanage.ScriptHub.catalogModes = { "all", "games", "other" }
NAmanage.ScriptHub.tabModes = { "public", "supported", "saved" }
NAmanage.ScriptHub.tabMode = table.find(NAmanage.ScriptHub.tabModes, NAmanage.ScriptHub.tabMode) and NAmanage.ScriptHub.tabMode or "public"
NAmanage.ScriptHub.engine = table.find(NAmanage.ScriptHub.engines, NAmanage.ScriptHub.engine) and NAmanage.ScriptHub.engine or "RScripts"
NAmanage.ScriptHub.filterMode = table.find(NAmanage.ScriptHub.filterModes, NAmanage.ScriptHub.filterMode) and NAmanage.ScriptHub.filterMode or "all"
NAmanage.ScriptHub.catalogMode = table.find(NAmanage.ScriptHub.catalogModes, NAmanage.ScriptHub.catalogMode) and NAmanage.ScriptHub.catalogMode or "all"
NAmanage.ScriptHub.page = math.max(tonumber(NAmanage.ScriptHub.page) or 1, 1)
NAmanage.ScriptHub.totalPages = math.max(tonumber(NAmanage.ScriptHub.totalPages) or 1, 1)
NAmanage.ScriptHub.query = tostring(NAmanage.ScriptHub.query or "")
NAmanage.ScriptHub.entries = type(NAmanage.ScriptHub.entries) == "table" and NAmanage.ScriptHub.entries or {}
NAmanage.ScriptHub.searching = false
NAmanage.ScriptHub.fetchToken = tonumber(NAmanage.ScriptHub.fetchToken) or 0
NAmanage.ScriptHub.imageCacheDir = NAfiles.NASCRIPTIMAGEPATH or "Nameless-Admin/ScriptImages"
NAmanage.ScriptHub.imageAssets = type(NAmanage.ScriptHub.imageAssets) == "table" and NAmanage.ScriptHub.imageAssets or {}
NAmanage.ScriptHub.imagePending = type(NAmanage.ScriptHub.imagePending) == "table" and NAmanage.ScriptHub.imagePending or {}
NAmanage.ScriptHub.imageGeneration = tonumber(NAmanage.ScriptHub.imageGeneration) or 0
NAmanage.ScriptHub.placeIdCache = type(NAmanage.ScriptHub.placeIdCache) == "table" and NAmanage.ScriptHub.placeIdCache or {}
NAmanage.ScriptHub.tabStates = type(NAmanage.ScriptHub.tabStates) == "table" and NAmanage.ScriptHub.tabStates or {}
NAmanage.ScriptHub.tabStates.public = type(NAmanage.ScriptHub.tabStates.public) == "table" and NAmanage.ScriptHub.tabStates.public or {
	entries = NAmanage.ScriptHub.tabMode == "public" and NAmanage.ScriptHub.entries or {};
	query = NAmanage.ScriptHub.tabMode == "public" and NAmanage.ScriptHub.query or "";
	page = NAmanage.ScriptHub.tabMode == "public" and NAmanage.ScriptHub.page or 1;
	totalPages = NAmanage.ScriptHub.tabMode == "public" and NAmanage.ScriptHub.totalPages or 1;
}
NAmanage.ScriptHub.tabStates.supported = type(NAmanage.ScriptHub.tabStates.supported) == "table" and NAmanage.ScriptHub.tabStates.supported or {
	entries = NAmanage.ScriptHub.tabMode == "supported" and NAmanage.ScriptHub.entries or {};
	query = NAmanage.ScriptHub.tabMode == "supported" and NAmanage.ScriptHub.query or "";
	page = NAmanage.ScriptHub.tabMode == "supported" and NAmanage.ScriptHub.page or 1;
	totalPages = NAmanage.ScriptHub.tabMode == "supported" and NAmanage.ScriptHub.totalPages or 1;
}
NAmanage.ScriptHub.tabStates.saved = type(NAmanage.ScriptHub.tabStates.saved) == "table" and NAmanage.ScriptHub.tabStates.saved or {
	entries = NAmanage.ScriptHub.tabMode == "saved" and NAmanage.ScriptHub.entries or {};
	query = NAmanage.ScriptHub.tabMode == "saved" and NAmanage.ScriptHub.query or "";
	page = NAmanage.ScriptHub.tabMode == "saved" and NAmanage.ScriptHub.page or 1;
	totalPages = NAmanage.ScriptHub.tabMode == "saved" and NAmanage.ScriptHub.totalPages or 1;
}
NAmanage.ScriptHub.supportedPageSize = 16
NAmanage.ScriptHub.savedPageSize = 16
NAmanage.ScriptHub.engineDropdown = nil

NAmanage.ExecutorWindowSizing = type(NAmanage.ExecutorWindowSizing) == "table" and NAmanage.ExecutorWindowSizing or {}
NAmanage.ExecutorWindowSizing.GetScale = function()
	local scale = (NAUIMANAGER and NAUIMANAGER.AUTOSCALER and tonumber(NAUIMANAGER.AUTOSCALER.Scale)) or tonumber(NAUIScale) or 1
	if not scale or scale <= 0 then
		scale = 1
	end
	return scale
end
NAmanage.ExecutorWindowSizing.GetViewport = function()
	const screenGui = NAStuff and NAStuff.NASCREENGUI
	if screenGui and screenGui.AbsoluteSize and screenGui.AbsoluteSize.X > 0 and screenGui.AbsoluteSize.Y > 0 then
		return screenGui.AbsoluteSize
	end
	const cam = Services.Workspace and Services.Workspace.CurrentCamera
	if cam and cam.ViewportSize and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
		return cam.ViewportSize
	end
	return Vector2.new(1280, 720)
end
NAmanage.ExecutorWindowSizing.GetLogicalViewport = function()
	const viewport = NAmanage.ExecutorWindowSizing.GetViewport()
	const scale = NAmanage.ExecutorWindowSizing.GetScale()
	return Vector2.new(
		math.max(1, viewport.X / scale),
		math.max(1, viewport.Y / scale)
	)
end
NAmanage.ExecutorWindowSizing.GetSafePad = function()
	const scale = NAmanage.ExecutorWindowSizing.GetScale()
	local x = IsOnMobile and 8 or 12
	local y = IsOnMobile and 8 or 12
	if Services.GuiService and Services.GuiService.GetGuiInset then
		local ok, a, b = pcall(function()
			return Services.GuiService:GetGuiInset()
		end)
		if ok and typeof(a) == "Vector2" and typeof(b) == "Vector2" then
			x += math.max(a.X, b.X) / scale
			y += math.max(a.Y, b.Y) / scale
		end
	end
	return x, y
end
NAmanage.ExecutorWindowSizing.IsTouchCompact = function(vp)
	const touch = Services.UserInputService and Services.UserInputService.TouchEnabled
	const mouse = Services.UserInputService and Services.UserInputService.MouseEnabled
	const key = Services.UserInputService and Services.UserInputService.KeyboardEnabled
	return IsOnMobile or vp.Y < 620 or vp.X < 900 or (touch and not (mouse or key))
end
NAmanage.ExecutorWindowSizing.GetSize = function(baseWidth, baseHeight, config)
	config = type(config) == "table" and config or {}
	const vp = NAmanage.ExecutorWindowSizing.GetLogicalViewport()
	local padX, padY = NAmanage.ExecutorWindowSizing.GetSafePad()
	const maxW = math.max(1, math.floor(vp.X - padX * 2 + 0.5))
	const maxH = math.max(1, math.floor(vp.Y - padY * 2 + 0.5))
	const mobile = NAmanage.ExecutorWindowSizing.IsTouchCompact(vp)
	const baseW = math.max(1, tonumber(baseWidth) or 920)
	const baseH = math.max(1, tonumber(baseHeight) or 540)
	const viewportRatio = math.clamp(tonumber(config.viewportRatio) or 0.90, 0.60, 1)
	local capW = mobile and math.floor(maxW * viewportRatio + 0.5) or math.min(baseW, maxW)
	local capH = mobile and math.floor(maxH * viewportRatio + 0.5) or math.min(baseH, maxH)
	capW = math.max(1, capW)
	capH = math.max(1, capH)
	local factor = math.min(capW / baseW, capH / baseH, 1)
	if not factor or factor <= 0 then
		factor = 1
	end
	local width = math.floor(baseW * factor + 0.5)
	local height = math.floor(baseH * factor + 0.5)
	const mobileMinW = tonumber(config.mobileMinWidth) or math.min(baseW * 0.45, 340)
	const mobileMinH = tonumber(config.mobileMinHeight) or math.min(baseH * 0.52, 280)
	const desktopMinW = tonumber(config.minWidth) or math.min(baseW * 0.72, 680)
	const desktopMinH = tonumber(config.minHeight) or math.min(baseH * 0.76, 420)
	const minW = math.min(mobile and mobileMinW or desktopMinW, capW)
	const minH = math.min(mobile and mobileMinH or desktopMinH, capH)
	width = math.clamp(width, minW, capW)
	height = math.clamp(height, minH, capH)
	return {
		viewport = vp;
		width = width;
		height = height;
		capWidth = capW;
		capHeight = capH;
		minWidth = minW;
		minHeight = minH;
		mobile = mobile;
		scale = NAmanage.ExecutorWindowSizing.GetScale();
	}
end
NAmanage.ExecutorWindowSizing.Save = function(frame, sizeXAttr, sizeYAttr)
	if not (frame and frame.Parent and frame.SetAttribute) then
		return
	end
	if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
		return
	end
	const width = tonumber(frame.Size.X.Offset) or 0
	const height = tonumber(frame.Size.Y.Offset) or 0
	if width > 0 and height > 0 then
		NAmanage.SetAttr(frame, sizeXAttr, math.floor(width + 0.5))
		NAmanage.SetAttr(frame, sizeYAttr, math.floor(height + 0.5))
	end
end
NAmanage.ExecutorWindowSizing.GetSaved = function(frame, sizeXAttr, sizeYAttr)
	if frame and frame.GetAttribute then
		const width = tonumber(NAmanage.GetAttr(frame, sizeXAttr))
		const height = tonumber(NAmanage.GetAttr(frame, sizeYAttr))
		if width and height and width > 0 and height > 0 then
			return width, height
		end
	end
	return nil
end
NAmanage.ExecutorWindowSizing.Apply = function(frame, config)
	if not (frame and frame.Parent) then
		return false
	end
	if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
		return false
	end
	config = type(config) == "table" and config or {}
	const key = tostring(config.key or frame.Name or "Window")
	const sizeXAttr = "NA"..key.."SavedSizeX"
	const sizeYAttr = "NA"..key.."SavedSizeY"
	const initializedAttr = "NA"..key.."DefaultSized"
	const profileAttr = "NA"..key.."ViewportProfile"
	const metrics = NAmanage.ExecutorWindowSizing.GetSize(config.baseWidth, config.baseHeight, config)
	const initialized = frame.GetAttribute and NAmanage.GetAttr(frame, initializedAttr) == true
	const currentWidth = tonumber(frame.Size.X.Offset) or 0
	const currentHeight = tonumber(frame.Size.Y.Offset) or 0
	local savedWidth, savedHeight = NAmanage.ExecutorWindowSizing.GetSaved(frame, sizeXAttr, sizeYAttr)
	const currentProfile = metrics.mobile and "mobile" or "desktop"
	const previousProfile = frame.GetAttribute and tostring(NAmanage.GetAttr(frame, profileAttr) or "") or ""
	if metrics.mobile and previousProfile ~= "mobile" then
		savedWidth, savedHeight = nil, nil
	end
	local targetWidth = metrics.width
	local targetHeight = metrics.height
	if savedWidth and savedHeight then
		targetWidth = math.clamp(math.floor(savedWidth + 0.5), metrics.minWidth, metrics.capWidth)
		targetHeight = math.clamp(math.floor(savedHeight + 0.5), metrics.minHeight, metrics.capHeight)
	elseif initialized and currentWidth > 0 and currentHeight > 0 then
		targetWidth = math.clamp(math.floor(currentWidth + 0.5), metrics.minWidth, metrics.capWidth)
		targetHeight = math.clamp(math.floor(currentHeight + 0.5), metrics.minHeight, metrics.capHeight)
		if metrics.mobile and (targetWidth >= metrics.capWidth * 0.96 or targetWidth / math.max(targetHeight, 1) > 1.95 or targetHeight < metrics.height * 0.82) then
			targetWidth = metrics.width
			targetHeight = metrics.height
		end
	end
	frame.AnchorPoint = Vector2.new(0, 0)
	if frame.AbsoluteSize.X ~= math.floor(targetWidth * metrics.scale + 0.5) or frame.AbsoluteSize.Y ~= math.floor(targetHeight * metrics.scale + 0.5) then
		frame.Size = UDim2.fromOffset(targetWidth, targetHeight)
	end
	if frame.SetAttribute then
		NAmanage.SetAttr(frame, initializedAttr, true)
		NAmanage.SetAttr(frame, profileAttr, currentProfile)
	end
	NAmanage.ExecutorWindowSizing.Save(frame, sizeXAttr, sizeYAttr)
	if config.center == true and NAmanage.centerFrame then
		pcall(NAmanage.centerFrame, frame)
	end
	return true, metrics, targetWidth, targetHeight
end

NAmanage.NAChat_ApplyResponsive = function(center)
	const frame = NAUIMANAGER and NAUIMANAGER.NAchatFrame
	if not (frame and frame.Parent) then
		return false
	end
	const ok, metrics = NAmanage.ExecutorWindowSizing.Apply(frame, {
		key = "NAChat";
		baseWidth = 760;
		baseHeight = 520;
		minWidth = 520;
		minHeight = 360;
		mobileMinWidth = 300;
		mobileMinHeight = 220;
		viewportRatio = 0.94;
		center = center == true;
	})
	if not ok then
		return false
	end

	const constraint = frame:FindFirstChild("WindowSizeConstraint")
	if constraint and constraint:IsA("UISizeConstraint") and metrics then
		constraint.MinSize = Vector2.new(
			math.max(1, tonumber(metrics.minWidth) or 1),
			math.max(1, tonumber(metrics.minHeight) or 1)
		)
	end
	return true
end

NAmanage.ScriptHub_UpdateResponsiveLayout = function()
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	if not (ui and ui.frame) then
		return false
	end
	const width = math.max(1, ui.frame.AbsoluteSize.X)
	const previousCompact = hub.compact == true
	const previousPhone = hub.phone == true
	hub.compact = IsOnMobile == true or width < 690
	hub.phone = width < 500
	return previousCompact ~= hub.compact or previousPhone ~= hub.phone
end

NAmanage.ScriptHub_ApplyResponsive = function(center)
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	const frame = ui and ui.frame
	if not frame then
		return false
	end
	const ok = NAmanage.ExecutorWindowSizing.Apply(frame, {
		key = "ScriptHub";
		baseWidth = 760;
		baseHeight = 520;
		minWidth = 560;
		minHeight = 360;
		mobileMinWidth = 320;
		mobileMinHeight = 300;
		center = center == true;
	})
	if not ok then
		return false
	end
	const changed = NAmanage.ScriptHub_UpdateResponsiveLayout()
	if changed and #hub.entries > 0 and hub.rendering ~= true then
		Defer(NAmanage.ScriptHub_Render)
	end
	return true
end

NAmanage.ScriptHub_GetUI = function()
	const hub = NAmanage.ScriptHub
	const frame = NAUIMANAGER and NAUIMANAGER.ScriptHubFrame
	const container = frame and frame:FindFirstChild("Container")
	const controls = container and container:FindFirstChild("Controls")
	const topbar = frame and frame:FindFirstChild("Topbar")
	hub.ui = {
		frame = frame;
		container = container;
		topbar = topbar;
		title = topbar and topbar:FindFirstChild("Title");
		publicTab = topbar and topbar:FindFirstChild("PublicTab");
		supportedTab = topbar and topbar:FindFirstChild("SupportedTab");
		savedTab = topbar and topbar:FindFirstChild("SavedTab");
		engine = topbar and topbar:FindFirstChild("Engine");
		searchRow = container and container:FindFirstChild("SearchRow");
		searchBox = container and container:FindFirstChild("SearchBox", true);
		search = container and container:FindFirstChild("Search", true);
		controls = controls;
		first = controls and controls:FindFirstChild("First");
		prev = controls and controls:FindFirstChild("Prev");
		pageInfo = controls and controls:FindFirstChild("PageInfo");
		next = controls and controls:FindFirstChild("Next");
		last = controls and controls:FindFirstChild("Last");
		filter = controls and controls:FindFirstChild("Filter");
		results = container and container:FindFirstChild("Results");
	}
	return hub.ui
end

NAmanage.ScriptHub_SetButtonEnabled = function(button, enabled)
	if not (button and button:IsA("GuiButton")) then
		return
	end
	button.Active = enabled == true
	button.AutoButtonColor = false
	button.TextTransparency = enabled and 0 or 0.45
	button.BackgroundTransparency = enabled and 0.2 or 0.55
end

NAmanage.ScriptHub_UpdateTabButton = function(button, selected)
	if not (button and button:IsA("GuiButton")) then
		return
	end
	button.Active = true
	button.AutoButtonColor = true
	button.TextTransparency = 0
	button.BackgroundTransparency = selected and 0.04 or 0.28
	button.BackgroundColor3 = selected and Color3.fromRGB(72, 54, 104) or Color3.fromRGB(29, 30, 40)
	const stroke = button:FindFirstChild("UIStroker")
	if stroke and stroke:IsA("UIStroke") then
		stroke.Transparency = selected and 0.08 or 0.5
	end
end

NAmanage.ScriptHub_UpdateControls = function()
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	if not ui then
		return
	end
	const page = math.max(tonumber(hub.page) or 1, 1)
	const total = math.max(tonumber(hub.totalPages) or 1, 1)
	if ui.pageInfo then
		ui.pageInfo.Text = Format("Page %d / %d", page, total)
	end
	if ui.filter then
		if hub.tabMode == "supported" then
			ui.filter.Text = hub.catalogMode == "games" and "Catalog: Games" or hub.catalogMode == "other" and "Catalog: Other" or "Catalog: All"
		elseif hub.tabMode == "saved" then
			ui.filter.Text = "Saved: Local"
		else
			ui.filter.Text = hub.filterMode == "keyless" and "Filter: Keyless" or hub.filterMode == "key" and "Filter: Key Req" or "Filter: All"
		end
	end
	const ready = hub.searching ~= true
	NAmanage.ScriptHub_SetButtonEnabled(ui.first, ready and page > 1)
	NAmanage.ScriptHub_SetButtonEnabled(ui.prev, ready and page > 1)
	NAmanage.ScriptHub_SetButtonEnabled(ui.next, ready and page < total)
	NAmanage.ScriptHub_SetButtonEnabled(ui.last, ready and page < total)
	NAmanage.ScriptHub_SetButtonEnabled(ui.filter, ready and (hub.tabMode == "supported" or hub.tabMode == "public" and #hub.entries > 0))
	NAmanage.ScriptHub_SetButtonEnabled(ui.engine, ready and hub.tabMode == "public")
	NAmanage.ScriptHub_SetButtonEnabled(ui.search, ready)
	NAmanage.ScriptHub_UpdateTabButton(ui.publicTab, hub.tabMode == "public")
	NAmanage.ScriptHub_UpdateTabButton(ui.supportedTab, hub.tabMode == "supported")
	NAmanage.ScriptHub_UpdateTabButton(ui.savedTab, hub.tabMode == "saved")
	if ui.search then
		ui.search.Text = hub.searching and (hub.tabMode == "supported" and "Loading..." or "Searching...") or "Search"
	end
end
NAmanage.ScriptHub_UpdateHeader = function()
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	if not ui then
		return
	end
	if ui.engine then
		ui.engine.Text = hub.tabMode == "supported" and "Catalog: GitHub" or hub.tabMode == "saved" and "Storage: Local" or hub.phone and (hub.engine.." ▼") or ("API: "..hub.engine.." ▼")
	end
	if ui.title then
		ui.title.Text = hub.tabMode == "supported" and "Script Hub - NA Scripts" or hub.tabMode == "saved" and "Script Hub - Saved Scripts" or "Script Hub"
	end
	if ui.supportedTab then
		ui.supportedTab.Text = "NA Scripts"
	end
	if ui.savedTab then
		ui.savedTab.Text = hub.phone and "Saved" or "Saved Scripts"
	end
	if ui.searchBox then
		if hub.tabMode == "supported" then
			ui.searchBox.PlaceholderText = "Search NA scripts"
		elseif hub.tabMode == "saved" then
			ui.searchBox.PlaceholderText = "Search saved scripts"
		elseif hub.engine == "RScripts" then
			ui.searchBox.PlaceholderText = "Search for scripts (rscripts.net)"
		elseif hub.engine == "RobloxScripts" then
			ui.searchBox.PlaceholderText = "Search for scripts (robloxscripts.com)"
		elseif hub.engine == "HaxHell" then
			ui.searchBox.PlaceholderText = "Search for scripts (haxhell.com)"
		else
			ui.searchBox.PlaceholderText = "Search for scripts (scriptblox.com)"
		end
	end
	NAmanage.ScriptHub_UpdateControls()
end

NAmanage.ScriptHub_CloseEngineDropdown = function()
	const hub = NAmanage.ScriptHub
	if hub.engineDropdown and hub.engineDropdown.Parent then
		hub.engineDropdown:Destroy()
	end
	if hub.ui and hub.ui.frame then
		local dismiss = hub.ui.frame:FindFirstChild("EngineDropdownDismiss")
		if dismiss then dismiss:Destroy() end
	end
	hub.engineDropdown = nil
end

NAmanage.ScriptHub_SelectEngine = function(engine)
	const hub = NAmanage.ScriptHub
	if hub.searching or hub.tabMode ~= "public" or not table.find(hub.engines, engine) then
		return false
	end
	NAmanage.ScriptHub_CloseEngineDropdown()
	if hub.engine == engine then
		NAmanage.ScriptHub_UpdateHeader()
		return true
	end
	hub.engine = engine
	hub.page = 1
	hub.totalPages = 1
	hub.entries = {}
	hub.query = ""
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	if ui and ui.searchBox then ui.searchBox.Text = "" end
	NAmanage.ScriptHub_UpdateHeader()
	NAmanage.ScriptHub_Fetch("", 1)
	return true
end

NAmanage.ScriptHub_ToggleEngineDropdown = function()
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	if hub.searching or hub.tabMode ~= "public" or not (ui and ui.frame and ui.engine) then
		NAmanage.ScriptHub_CloseEngineDropdown()
		return false
	end
	if hub.engineDropdown and hub.engineDropdown.Parent then
		NAmanage.ScriptHub_CloseEngineDropdown()
		return true
	end
	local dismiss = Instance.new("TextButton", ui.frame)
	dismiss.Name = "EngineDropdownDismiss"
	dismiss.BorderSizePixel = 0
	dismiss.BackgroundTransparency = 1
	dismiss.Size = UDim2.fromScale(1, 1)
	dismiss.Text = ""
	dismiss.AutoButtonColor = false
	dismiss.ZIndex = 209
	dismiss.MouseButton1Click:Connect(NAmanage.ScriptHub_CloseEngineDropdown)
	local menu = Instance.new("Frame", ui.frame)
	menu.Name = "EngineDropdown"
	menu.BorderSizePixel = 0
	menu.BackgroundColor3 = Color3.fromRGB(20, 21, 28)
	menu.BackgroundTransparency = 0.03
	menu.Position = UDim2.new(ui.engine.Position.X.Scale, ui.engine.Position.X.Offset, 0, 70)
	menu.Size = UDim2.new(ui.engine.Size.X.Scale, ui.engine.Size.X.Offset, 0, #hub.engines * 30 + 8)
	menu.ZIndex = 210
	Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
	local menuStroke = Instance.new("UIStroke", menu)
	menuStroke.Color = Color3.fromRGB(155, 100, 255)
	menuStroke.Transparency = 0.22
	menuStroke.Thickness = 1
	local padding = Instance.new("UIPadding", menu)
	padding.PaddingTop = UDim.new(0, 4)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	local layout = Instance.new("UIListLayout", menu)
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	for index, engine in hub.engines do
		local option = Instance.new("TextButton", menu)
		option.Name = "API_"..tostring(engine)
		option.LayoutOrder = index
		option.BorderSizePixel = 0
		option.BackgroundColor3 = engine == hub.engine and Color3.fromRGB(72, 54, 104) or Color3.fromRGB(31, 32, 42)
		option.BackgroundTransparency = engine == hub.engine and 0.04 or 0.12
		option.Size = UDim2.new(1, 0, 0, 28)
		option.Text = engine
		option.TextColor3 = Color3.fromRGB(245, 246, 250)
		option.TextSize = 12
		option.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		option.ZIndex = 211
		Instance.new("UICorner", option).CornerRadius = UDim.new(0, 5)
		option.MouseButton1Click:Connect(function()
			NAmanage.ScriptHub_SelectEngine(engine)
		end)
	end
	hub.engineDropdown = menu
	return true
end

NAmanage.ScriptHub_SaveTabState = function()
	const hub = NAmanage.ScriptHub
	const state = type(hub.tabStates[hub.tabMode]) == "table" and hub.tabStates[hub.tabMode] or {}
	state.entries = hub.entries
	state.query = hub.query
	state.page = hub.page
	state.totalPages = hub.totalPages
	hub.tabStates[hub.tabMode] = state
end

NAmanage.ScriptHub_RestoreTabState = function(tabMode)
	const hub = NAmanage.ScriptHub
	const state = type(hub.tabStates[tabMode]) == "table" and hub.tabStates[tabMode] or {}
	hub.entries = type(state.entries) == "table" and state.entries or {}
	hub.query = tostring(state.query or "")
	hub.page = math.max(math.floor(tonumber(state.page) or 1), 1)
	hub.totalPages = math.max(math.floor(tonumber(state.totalPages) or 1), 1)
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	if ui and ui.searchBox then
		ui.searchBox.Text = hub.query
	end
end

NAmanage.ScriptHub_SetTab = function(tabMode)
	const hub = NAmanage.ScriptHub
	NAmanage.ScriptHub_CloseEngineDropdown()
	if not table.find(hub.tabModes, tabMode) or tabMode == hub.tabMode then
		return false
	end
	NAmanage.ScriptHub_SaveTabState()
	hub.fetchToken += 1
	hub.searching = false
	hub.tabMode = tabMode
	NAmanage.ScriptHub_RestoreTabState(tabMode)
	NAmanage.ScriptHub_ClearImageCache()
	NAmanage.ScriptHub_UpdateHeader()
	if #hub.entries > 0 then
		NAmanage.ScriptHub_Render()
	elseif tabMode == "supported" then
		NAmanage.ScriptHub_LoadSupported(hub.query, hub.page)
	elseif tabMode == "saved" then
		NAmanage.ScriptHub_LoadSaved(hub.query, hub.page)
	else
		NAmanage.ScriptHub_Fetch(hub.query, hub.page)
	end
	return true
end

NAmanage.ScriptHub_ClearResults = function()
	NAlib.disconnect("NAScriptHubCards")
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	const results = ui and ui.results
	if not results then
		return
	end
	for _, child in results:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	results.CanvasPosition = Vector2.new(0, 0)
end

NAmanage.ScriptHub_Message = function(text, color)
	const hub = NAmanage.ScriptHub
	const ui = hub.ui or NAmanage.ScriptHub_GetUI()
	const results = ui and ui.results
	if not results then
		return
	end
	NAmanage.ScriptHub_ClearResults()
	const message = InstanceNew("TextLabel", results)
	message.Name = "ScriptHubMessage"
	message.BorderSizePixel = 0
	message.BackgroundColor3 = color or Color3.fromRGB(55, 55, 65)
	message.BackgroundTransparency = 0.2
	message.Size = UDim2.new(1, -4, 0, 54)
	message.Text = tostring(text or "")
	message.TextWrapped = true
	message.TextColor3 = Color3.fromRGB(240, 240, 248)
	message.TextSize = 14
	message.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	const corner = InstanceNew("UICorner", message)
	corner.CornerRadius = UDim.new(0, 6)
	const stroke = InstanceNew("UIStroke", message)
	stroke.Name = "UIStroker"
	stroke.Thickness = 1.25
	stroke.Color = NAUISTROKER or Color3.fromRGB(155, 100, 255)
	stroke.Transparency = 0.35
end

NAmanage.ScriptHub_RequiresKey = function(data)
	const hub = NAmanage.ScriptHub
	if type(data) == "table" and data.naSaved == true then
		return data.requiresKey == true
	end
	if type(data) == "table" and data.naCatalog == true then
		return false
	end
	local value
	if hub.engine == "RScripts" then
		value = data.keySystem
	elseif hub.engine == "HaxHell" then
		const flags = type(data.flags) == "table" and data.flags or {}
		value = flags.keySystem
	else
		value = data.key
	end
	if value == nil and type(data.accessType) == "string" then
		value = Lower(data.accessType) == "key"
	end
	if type(value) == "boolean" then
		return value
	elseif type(value) == "number" then
		return value ~= 0
	elseif type(value) == "string" then
		const normalized = Lower(value)
		if normalized == "" or normalized == "false" or normalized == "0" or normalized == "none" or normalized == "n/a" then
			return false
		end
		if Find(normalized, "no key", 1, true) or Find(normalized, "keyless", 1, true) then
			return false
		end
		return true
	end
	return value ~= nil and value ~= false
end

NAmanage.ScriptHub_PassesFilter = function(data)
	if type(data) == "table" and (data.naCatalog == true or data.naSaved == true) then
		return true
	end
	const mode = NAmanage.ScriptHub.filterMode
	const requiresKey = NAmanage.ScriptHub_RequiresKey(data)
	if mode == "keyless" then
		return not requiresKey
	elseif mode == "key" then
		return requiresKey
	end
	return true
end

NAmanage.ScriptHub_GetSourceInfo = function(data)
	const hub = NAmanage.ScriptHub
	local source
	if type(data) == "table" and data.naSaved == true then
		if type(readfile) ~= "function" or type(data.savedPath) ~= "string" or data.savedPath == "" then
			return "", false
		end
		local okRead, savedSource = pcall(readfile, data.savedPath)
		source = okRead and type(savedSource) == "string" and savedSource or ""
	elseif type(data) == "table" and data.naCatalog == true then
		source = data.scriptUrl
	elseif hub.engine == "RScripts" then
		source = data.rawScript or data.scriptLink or data.raw or data.script
	elseif hub.engine == "HaxHell" then
		const links = type(data.links) == "table" and data.links or {}
		const sourceData = type(data.source) == "table" and data.source or {}
		source = links.raw or sourceData.rawUrl or sourceData.code or data.rawScriptUrl or data.script
	else
		source = data.script or data.rawScriptUrl or data.scriptLink or data.raw or data.rawScript
	end
	source = type(source) == "string" and source or ""
	return source, source:match("^https?://") ~= nil
end

NAmanage.ScriptHub_ResolveSource = function(data)
	local source, isUrl = NAmanage.ScriptHub_GetSourceInfo(data)
	if source == "" then
		return false, nil, "script source unavailable"
	end
	if isUrl then
		local ok, body, err = NAmanage.HttpGet(source, { timeout = 12; maxAttempts = 3; Headers = { Accept = "text/plain,*/*" } })
		if not ok or type(body) ~= "string" or body == "" then
			return false, nil, tostring(err or "failed to download script")
		end
		source = body
	end
	return true, source
end

NAmanage.ScriptHub_SafeRunEntry = function(data)
	local source, isUrl = NAmanage.ScriptHub_GetSourceInfo(data)
	if source == "" then
		DoNotif("Script source unavailable.", 3, "Script Hub")
		return false
	end
	const chunkName = "@NA-ScriptHub/"..tostring(data.title or data.name or "Script")
	if isUrl then
		local okRun, runErr = NAmanage.RunURL(source, false, chunkName)
		if okRun ~= true then
			DoNotif("Safe execution failed: "..tostring(runErr or "unable to queue URL"), 4, "Script Hub")
			return false
		end
	else
		local okRun, runErr = NAmanage.RunSourceInEnv(source, chunkName)
		if okRun ~= true then
			DoNotif("Safe execution failed: "..tostring(runErr or "unable to queue source"), 4, "Script Hub")
			return false
		end
	end
	DoNotif("Safe Execute queued "..tostring(data.title or data.name or "script"), 2, "Script Hub")
	return true
end

NAmanage.ScriptHub_RunEntry = function(data)
	SpawnCall(function()
		local source, isUrl = NAmanage.ScriptHub_GetSourceInfo(data)
		if source == "" then
			DoNotif("Script source unavailable.", 3, "Script Hub")
			return
		end
		local body = source
		if isUrl then
			body = game:HttpGet(source)
		end
		const chunkName = "@NA-ScriptHub/"..tostring(data.title or data.name or "Script")
		local fn, loadErr = NAmanage.RawCompile(body, chunkName)
		if not fn then
			error(tostring(loadErr or "compile error"), 0)
		end
		fn()
		DoNotif("Executed "..tostring(data.title or data.name or "script"), 2, "Script Hub")
	end)
end

NAmanage.ScriptHub_CopyEntry = function(data)
	if type(setclipboard) ~= "function" then
		DoNotif("Clipboard API unavailable.", 3, "Script Hub")
		return
	end
	SpawnCall(function()
		local okSource, source, sourceErr = NAmanage.ScriptHub_ResolveSource(data)
		if not okSource then
			DoNotif(tostring(sourceErr or "Script source unavailable."), 3, "Script Hub")
			return
		end
		local okCopy = pcall(setclipboard, source)
		DoNotif(okCopy and "Script copied." or "Failed to copy script.", 2, "Script Hub")
	end)
end

NAmanage.ScriptHub_JoinEntry = function(data)
	const hub = NAmanage.ScriptHub
	const placeId = tonumber(NAmanage.ScriptHub_GetPlaceId(data))
	if not placeId or placeId <= 0 then
		DoNotif("This catalog entry does not have a valid place ID.", 3, "Script Hub")
		return false
	end
	if tonumber((game and game.PlaceId) or PlaceId) == placeId then
		DoNotif("You are already in "..tostring(data.gameName or data.name or "this game")..".", 3, "Script Hub")
		return false
	end
	const now = os.clock()
	if hub.joiningPlaceId == placeId and now - (tonumber(hub.joiningStartedAt) or 0) < 3 then
		DoNotif("A teleport to this game is already being attempted.", 3, "Script Hub")
		return false
	end
	hub.joiningPlaceId = placeId
	hub.joiningStartedAt = now
	if not (cmd and type(cmd.run) == "function") then
		hub.joiningPlaceId = nil
		DoNotif("The teleporttoplace command is unavailable.", 3, "Script Hub")
		return false
	end
	local okRun, runErr = pcall(cmd.run, { "teleporttoplace", tostring(placeId) })
	if not okRun then
		hub.joiningPlaceId = nil
		DoNotif("Could not run teleporttoplace: "..tostring(runErr), 4, "Script Hub")
		return false
	end
	task.delay(3, function()
		if hub.joiningPlaceId == placeId then
			hub.joiningPlaceId = nil
		end
	end)
	return true
end

NAmanage.ScriptHub_IsUniversal = function(data)
	if type(data) ~= "table" then
		return false
	end
	return data.isUniversal == true or data.universal == true or Lower(tostring(data.type or "")) == "universal"
end

NAmanage.ScriptHub_NormalizeGameName = function(value)
	return GSub(Lower(tostring(value or "")), "[^%w]", "")
end

NAmanage.ScriptHub_GetPlaceId = function(data)
	if type(data) ~= "table" or NAmanage.ScriptHub_IsUniversal(data) then
		return nil
	end
	const gameData = type(data.game) == "table" and data.game or {}
	const candidates = {
		data.naResolvedPlaceId,
		type(data.placeIds) == "table" and data.placeIds[1],
		data.placeId,
		data.rootPlaceId,
		data.gameId,
		gameData.placeId,
		gameData.rootPlaceId,
		gameData.gameId,
		gameData.id,
	}
	for _, candidate in candidates do
		const text = tostring(candidate or "")
		if Match(text, "^%d+$") and tonumber(text) and tonumber(text) > 0 then
			return tonumber(text)
		end
	end
	for _, value in {
		data.gameLink,
		data.gameUrl,
		data.url,
		gameData.gameLink,
		gameData.gameUrl,
		gameData.url,
	} do
		if type(value) == "string" then
			const placeId = Match(value, "roblox%.com/games/(%d+)") or Match(value, "/games/(%d+)")
			if placeId and tonumber(placeId) then
				return tonumber(placeId)
			end
		end
	end
	return nil
end

NAmanage.ScriptHub_SanitizeImageName = function(value)
	return GSub(tostring(value or "image"), "[^%w%._%-]", "_")
end

NAmanage.ScriptHub_HashImageURL = function(value)
	value = tostring(value or "")
	local hash = 0
	for index = 1, #value do
		hash = (hash * 31 + string.byte(value, index)) % 4294967296
	end
	return Format("%08x", hash)
end

NAmanage.ScriptHub_NormalizeImageURL = function(value, base)
	if type(value) ~= "string" then
		return nil
	end
	const trimmed = Match(value, "^%s*(.-)%s*$") or ""
	if trimmed == "" then
		return nil
	end
	if Match(trimmed, "^rbxassetid://") or Match(trimmed, "^rbxthumb://") then
		return trimmed
	end
	if Match(trimmed, "^https?://") then
		return trimmed
	end
	if Sub(trimmed, 1, 2) == "//" then
		return "https:"..trimmed
	end
	if type(base) ~= "string" or base == "" then
		return trimmed
	end
	if Sub(trimmed, 1, 1) == "/" then
		return base..trimmed
	end
	return base.."/"..trimmed
end

NAmanage.ScriptHub_IsMeaningfulImageURL = function(value)
	if type(value) ~= "string" or value == "" then
		return false
	end
	return not Find(Lower(value), "no-script", 1, true)
end

NAmanage.ScriptHub_PickImageURL = function(values, base)
	for _, value in values do
		const normalized = NAmanage.ScriptHub_NormalizeImageURL(value, base)
		if normalized and NAmanage.ScriptHub_IsMeaningfulImageURL(normalized) then
			return normalized
		end
	end
	return nil
end

NAmanage.ScriptHub_ResolveImageURL = function(data)
	const hub = NAmanage.ScriptHub
	if type(data) ~= "table" then
		return nil
	end
	if data.naSaved == true then
		return NAmanage.ScriptHub_PickImageURL({ data.imageUrl, data.image }, "")
	end
	if data.naCatalog == true then
		return NAmanage.ScriptHub_PickImageURL({ data.imageUrl, data.image }, "")
	end
	const gameData = type(data.game) == "table" and data.game or {}
	if hub.engine == "RScripts" then
		return NAmanage.ScriptHub_PickImageURL({
			data.image,
			data.imageUrl,
			data.thumbnail,
			data.cover,
			data.banner,
			data.img,
			gameData.imgurl,
			gameData.imageUrl,
			gameData.image,
			gameData.thumbnail,
			gameData.cover,
			gameData.banner,
			gameData.gameLogo,
		}, "https://rscripts.net")
	elseif hub.engine == "RobloxScripts" then
		return NAmanage.ScriptHub_PickImageURL({
			data.image,
			data.imageUrl,
			data.thumbnail,
			gameData.iconUrl,
			gameData.image,
		}, "https://robloxscripts.com")
	elseif hub.engine == "HaxHell" then
		const media = type(data.media) == "table" and data.media or {}
		return NAmanage.ScriptHub_PickImageURL({
			media.thumbnailUrl,
			data.image,
			data.imageUrl,
			data.thumbnail,
			gameData.thumbnailUrl,
			gameData.iconUrl,
			gameData.imageUrl,
			gameData.image,
		}, "https://haxhell.com")
	end
	return NAmanage.ScriptHub_PickImageURL({
		data.image,
		data.imageUrl,
		data.thumbnail,
		data.coverImage,
		data.icon,
		gameData.imageUrl,
		gameData.thumbnail,
		gameData.image,
		gameData.coverImage,
		gameData.icon,
	}, "https://scriptblox.com")
end

NAmanage.ScriptHub_BuildPlaceThumbnail = function(placeId)
	const id = tostring(placeId or "")
	if id == "" or id == "0" then
		return nil
	end
	return "https://www.roblox.com/Thumbs/PlaceThumbnail.ashx?width=420&height=270&format=png&placeId="..id
end

NAmanage.ScriptHub_BuildGameIcon = function(universeId, placeId)
	return NAmanage.ScriptHub_BuildPlaceThumbnail(placeId)
end

NAmanage.ScriptHub_GetSavedPaths = function()
	local base, scriptsDir = NAmanage.ExecutorScriptsBase()
	return base, scriptsDir, base.."/script-hub-saved.json"
end

NAmanage.ScriptHub_EnsureSavedStorage = function()
	if type(writefile) ~= "function" then
		return false
	end
	const base, scriptsDir = NAmanage.ScriptHub_GetSavedPaths()
	if type(NAmanage.safeMakeFolder) == "function" then
		return NAmanage.safeMakeFolder(base) == true and NAmanage.safeMakeFolder(scriptsDir) == true
	end
	if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return false
	end
	for _, path in { base, scriptsDir } do
		local okFolder, exists = pcall(isfolder, path)
		if not okFolder or not exists and not pcall(makefolder, path) then
			return false
		end
	end
	return true
end

NAmanage.ScriptHub_ReadSavedRecords = function()
	const records = {}
	local _, scriptsDir, indexPath = NAmanage.ScriptHub_GetSavedPaths()
	if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(indexPath) then
		return records
	end
	local okRead, raw = pcall(readfile, indexPath)
	if not okRead or type(raw) ~= "string" or raw == "" then
		return records
	end
	local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if not okDecode or type(decoded) ~= "table" then
		return records
	end
	const sourceRecords = type(decoded.entries) == "table" and decoded.entries or decoded
	for _, record in sourceRecords do
		if type(record) == "table" and type(record.savedId) == "string" and type(record.title) == "string" and type(record.fileName) == "string" then
			const path = scriptsDir.."/"..record.fileName
			if isfile(path) then
				record.savedPath = path
				Insert(records, record)
			end
		end
	end
	return records
end

NAmanage.ScriptHub_WriteSavedRecords = function(records)
	if not NAmanage.ScriptHub_EnsureSavedStorage() then
		return false, "saved scripts storage unavailable"
	end
	local _, _, indexPath = NAmanage.ScriptHub_GetSavedPaths()
	const serializable = {}
	for _, record in records do
		if type(record) == "table" then
			Insert(serializable, {
				savedId = record.savedId;
				title = record.title;
				fileName = record.fileName;
				engine = record.engine;
				imageUrl = record.imageUrl;
				gameName = record.gameName;
				placeId = record.placeId;
				isUniversal = record.isUniversal == true;
				requiresKey = record.requiresKey == true;
				verified = record.verified == true;
				description = record.description;
				savedAt = record.savedAt;
			})
		end
	end
	local okEncode, encoded = pcall(Services.HttpService.JSONEncode, Services.HttpService, { version = 1; entries = serializable })
	if not okEncode then
		return false, encoded
	end
	if type(NAmanage.safeWriteFile) == "function" then
		return NAmanage.safeWriteFile(indexPath, encoded) == true
	end
	local okWrite, writeErr = pcall(writefile, indexPath, encoded)
	return okWrite, writeErr
end

NAmanage.ScriptHub_DeleteSavedEntry = function(data, button)
	const hub = NAmanage.ScriptHub
	if hub.tabMode ~= "saved" or type(data) ~= "table" or data.naSaved ~= true or type(data.savedId) ~= "string" then
		return false
	end
	const now = os.clock()
	if not data._deleteConfirmUntil or now > data._deleteConfirmUntil then
		data._deleteConfirmUntil = now + 3
		if button and button.Parent then
			button.Text = "Confirm?"
		end
		const confirmUntil = data._deleteConfirmUntil
		task.delay(3, function()
			if data._deleteConfirmUntil == confirmUntil then
				data._deleteConfirmUntil = nil
				if button and button.Parent then
					button.Text = "Delete"
				end
			end
		end)
		return false
	end
	data._deleteConfirmUntil = nil
	if type(delfile) ~= "function" then
		DoNotif("Filesystem delete access is unavailable.", 4, "Script Hub")
		if button and button.Parent then
			button.Text = "Delete"
		end
		return false
	end
	const records = NAmanage.ScriptHub_ReadSavedRecords()
	const remaining = {}
	local target
	for _, record in records do
		if record.savedId == data.savedId then
			target = record
		else
			Insert(remaining, record)
		end
	end
	if not target then
		DoNotif("This saved script no longer exists.", 3, "Script Hub")
		hub.tabStates.saved.entries = {}
		NAmanage.ScriptHub_LoadSaved(hub.query, hub.page)
		return false
	end
	const fileName = tostring(target.fileName or "")
	if fileName == "" or Match(fileName, "[/\\]") then
		DoNotif("The saved script path is invalid.", 4, "Script Hub")
		if button and button.Parent then
			button.Text = "Delete"
		end
		return false
	end
	local _, scriptsDir = NAmanage.ScriptHub_GetSavedPaths()
	const path = scriptsDir.."/"..fileName
	local okDelete = true
	if type(isfile) == "function" and isfile(path) then
		okDelete = pcall(delfile, path)
	end
	if not okDelete then
		DoNotif("Could not delete the saved script file.", 4, "Script Hub")
		if button and button.Parent then
			button.Text = "Delete"
		end
		return false
	end
	local okIndex, indexErr = NAmanage.ScriptHub_WriteSavedRecords(remaining)
	if not okIndex then
		DoNotif("Deleted the script file, but could not update Saved Scripts: "..tostring(indexErr or "index write failed"), 5, "Script Hub")
	else
		DoNotif("Deleted "..tostring(target.title or data.name or "saved script")..".", 3, "Script Hub")
	end
	hub.tabStates.saved.entries = {}
	NAmanage.ScriptHub_LoadSaved(hub.query, hub.page)
	return okIndex == true
end

NAmanage.ScriptHub_GetSaveId = function(data, engine)
	const identity = type(data) == "table" and (data._id or data.id or data.slug or data.rawScriptUrl or data.scriptLink or data.title or data.name) or "script"
	return tostring(engine or "ScriptHub")..":"..tostring(identity or "script")
end

NAmanage.ScriptHub_SaveEntry = function(data, button)
	const hub = NAmanage.ScriptHub
	if hub.tabMode ~= "public" or type(data) ~= "table" or data.naCatalog == true or data.naSaved == true then
		return false
	end
	if not NAmanage.ScriptHub_EnsureSavedStorage() then
		DoNotif("Filesystem access is required to save scripts.", 4, "Script Hub")
		return false
	end
	const engine = hub.engine
	const savedId = NAmanage.ScriptHub_GetSaveId(data, engine)
	const records = NAmanage.ScriptHub_ReadSavedRecords()
	for _, record in records do
		if record.savedId == savedId then
			DoNotif("This script is already saved.", 3, "Script Hub")
			if button and button.Parent then
				NAmanage.ScriptHub_SetActionText(button, "Saved", "floppy-disk")
			end
			return false
		end
	end
	if button and button.Parent then
		button.Text = "Saving..."
		button.Active = false
	end
	const title = tostring(data.title or data.name or "Saved Script")
	const imageUrl = NAmanage.ScriptHub_ResolveImageURL(data)
	const placeId = NAmanage.ScriptHub_GetPlaceId(data)
	const gameData = type(data.game) == "table" and data.game or {}
	const gameName = tostring(gameData.name or gameData.title or "")
	const requiresKey = NAmanage.ScriptHub_RequiresKey(data)
	const universal = NAmanage.ScriptHub_IsUniversal(data)
	const flags = type(data.flags) == "table" and data.flags or {}
	const verified = data.verified == true or flags.verified == true or type(data.author) == "table" and (data.author.verified == true or data.author.isScripterVerified == true)
	local description = type(data.description) == "string" and GSub(data.description, "%c", " ") or ""
	if #description > 500 then
		description = Sub(description, 1, 497).."..."
	end
	SpawnCall(function()
		local okSource, source, sourceErr = NAmanage.ScriptHub_ResolveSource(data)
		if not okSource then
			if button and button.Parent then
				NAmanage.ScriptHub_SetActionText(button, "Save", "floppy-disk")
				button.Active = true
			end
			DoNotif("Could not save script: "..tostring(sourceErr or "source unavailable"), 4, "Script Hub")
			return
		end
		local _, scriptsDir = NAmanage.ScriptHub_GetSavedPaths()
		local fileName = NAmanage.ExecutorScriptsSanitizeName(title)
		fileName = NAmanage.ExecutorScriptsStripExt(fileName).."_"..NAmanage.ScriptHub_HashImageURL(savedId)..".luau"
		const path = scriptsDir.."/"..fileName
		local okWrite
		if type(NAmanage.safeWriteFile) == "function" then
			okWrite = NAmanage.safeWriteFile(path, source)
		else
			okWrite = pcall(writefile, path, source)
		end
		if okWrite ~= true then
			if button and button.Parent then
				NAmanage.ScriptHub_SetActionText(button, "Save", "floppy-disk")
				button.Active = true
			end
			DoNotif("Could not write the saved script file.", 4, "Script Hub")
			return
		end
		Insert(records, {
			savedId = savedId;
			title = title;
			fileName = fileName;
			engine = engine;
			imageUrl = imageUrl;
			gameName = gameName;
			placeId = placeId;
			isUniversal = universal;
			requiresKey = requiresKey;
			verified = verified;
			description = description;
			savedAt = os.time();
		})
		local okIndex, indexErr = NAmanage.ScriptHub_WriteSavedRecords(records)
		if not okIndex then
			if button and button.Parent then
				NAmanage.ScriptHub_SetActionText(button, "Save", "floppy-disk")
				button.Active = true
			end
			DoNotif("Saved the script file, but could not update Saved Scripts: "..tostring(indexErr or "index write failed"), 5, "Script Hub")
			return
		end
		hub.tabStates.saved.entries = {}
		if button and button.Parent then
			NAmanage.ScriptHub_SetActionText(button, "Saved", "floppy-disk")
		end
		DoNotif("Saved "..title..".", 3, "Script Hub")
	end)
	return true
end

NAmanage.ScriptHub_LoadSaved = function(query, page)
	const hub = NAmanage.ScriptHub
	if hub.searching or hub.tabMode ~= "saved" then
		return false
	end
	query = GSub(GSub(tostring(query or ""), "^%s+", ""), "%s+$", "")
	page = math.max(math.floor(tonumber(page) or 1), 1)
	hub.query = query
	hub.page = page
	hub.searching = true
	NAmanage.ScriptHub_Message("Loading saved scripts...", Color3.fromRGB(65, 62, 82))
	NAmanage.ScriptHub_UpdateControls()
	SpawnCall(function()
		const normalizedQuery = Lower(query)
		const matches = {}
		for _, record in NAmanage.ScriptHub_ReadSavedRecords() do
			const searchable = Lower(tostring(record.title or "").." "..tostring(record.gameName or "").." "..tostring(record.engine or ""))
			if normalizedQuery == "" or Find(searchable, normalizedQuery, 1, true) then
				Insert(matches, {
					naSaved = true;
					savedId = record.savedId;
					savedPath = record.savedPath;
					name = record.title;
					title = record.title;
					savedEngine = record.engine;
					imageUrl = record.imageUrl;
					gameName = record.gameName;
					game = record.gameName ~= "" and { name = record.gameName; placeId = record.placeId } or nil;
					naResolvedPlaceId = record.placeId;
					isUniversal = record.isUniversal == true;
					requiresKey = record.requiresKey == true;
					verified = record.verified == true;
					description = record.description;
					savedAt = tonumber(record.savedAt) or 0;
				})
			end
		end
		table.sort(matches, function(a, b)
			if a.savedAt ~= b.savedAt then
				return a.savedAt > b.savedAt
			end
			return Lower(a.name) < Lower(b.name)
		end)
		const pageSize = math.max(math.floor(tonumber(hub.savedPageSize) or 16), 1)
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

NAmanage.ScriptHub_GetImageTargets = function(url)
	local subdomain, path = Match(tostring(url), "^https?://([%w%-]+)%.roblox%.com(/.*)$")
	if not subdomain then
		subdomain, path = Match(tostring(url), "^https?://([%w%-]+)%.roproxy%.com(/.*)$")
	end
	if not subdomain then
		subdomain, path = Match(tostring(url), "^https?://([%w%-]+)%.rotunnel%.com(/.*)$")
	end
	if not subdomain or not path then
		return { url }
	end
	return {
		"https://"..subdomain..".roproxy.com"..path,
		"https://"..subdomain..".rotunnel.com"..path,
		"https://"..subdomain..".roblox.com"..path,
	}
end

NAmanage.ScriptHub_GetImageHeaders = function(url)
	const host = Match(tostring(url), "^https?://([^/]+)") or ""
	const headers = {
		Accept = "image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8",
	}
	if Find(host, "rscripts.net", 1, true) then
		headers.Referer = "https://rscripts.net"
	elseif Find(host, "robloxscripts.com", 1, true) then
		headers.Referer = "https://robloxscripts.com"
	elseif Find(host, "rbxcdn.com", 1, true) or Find(host, "roblox.com", 1, true) or Find(host, "roproxy.com", 1, true) or Find(host, "rotunnel.com", 1, true) then
		headers.Referer = "https://www.roblox.com/"
	end
	return headers
end

NAmanage.ScriptHub_EnsureImageFolder = function()
	const hub = NAmanage.ScriptHub
	if type(getcustomasset) ~= "function" or type(writefile) ~= "function" then
		return false
	end
	if type(NAmanage.safeMakeFolder) == "function" then
		NAmanage.safeMakeFolder(NAfiles.NAFILEPATH)
		const ok = NAmanage.safeMakeFolder(hub.imageCacheDir)
		return ok == true
	end
	if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return false
	end
	local okRoot, rootExists = pcall(isfolder, NAfiles.NAFILEPATH)
	if not okRoot then
		return false
	end
	if not rootExists and not pcall(makefolder, NAfiles.NAFILEPATH) then
		return false
	end
	local okFolder, folderExists = pcall(isfolder, hub.imageCacheDir)
	if not okFolder then
		return false
	end
	return folderExists or pcall(makefolder, hub.imageCacheDir)
end

NAmanage.ScriptHub_ClearImageCache = function()
	const hub = NAmanage.ScriptHub
	hub.imageGeneration = (tonumber(hub.imageGeneration) or 0) + 1
	hub.imageAssets = {}
	hub.imagePending = {}
	if type(listfiles) ~= "function" or type(delfile) ~= "function" then
		return false
	end
	local folderExists = false
	if type(NAmanage.safeIsFolder) == "function" then
		folderExists = NAmanage.safeIsFolder(hub.imageCacheDir)
	elseif type(isfolder) == "function" then
		local okFolder, value = pcall(isfolder, hub.imageCacheDir)
		folderExists = okFolder and value == true
	end
	if not folderExists then
		return true
	end
	local okList, paths = pcall(listfiles, hub.imageCacheDir)
	if not okList or type(paths) ~= "table" then
		return false
	end
	for _, path in paths do
		if type(path) == "string" and path ~= "" then
			local fileExists = true
			if type(NAmanage.safeIsFile) == "function" then
				fileExists = NAmanage.safeIsFile(path)
			elseif type(isfile) == "function" then
				local okFile, value = pcall(isfile, path)
				fileExists = okFile and value == true
			end
			if fileExists then
				if type(NAmanage.safeDeleteFile) == "function" then
					NAmanage.safeDeleteFile(path)
				else
					pcall(delfile, path)
				end
			end
		end
	end
	return true
end

NAmanage.ScriptHub_ClearImageCache()

NAmanage.ScriptHub_GetImagePath = function(url, generation)
	const hub = NAmanage.ScriptHub
	local fileName = Match(tostring(url), "/([^/%?#]+)") or "image"
	fileName = Match(fileName, "([^?#]+)") or fileName
	fileName = Match(fileName, "(.+)%.") or fileName
	fileName = NAmanage.ScriptHub_SanitizeImageName(fileName)
	return hub.imageCacheDir.."/"..(fileName ~= "" and fileName or "image").."_"..NAmanage.ScriptHub_HashImageURL(url).."_"..tostring(tonumber(generation) or hub.imageGeneration)..".txt"
end
