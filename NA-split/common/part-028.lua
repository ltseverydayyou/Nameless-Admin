if type(NAmanage.RegisterUnloadCleanup) == "function" then
	NAmanage.RegisterUnloadCleanup("mobile_fly_ui", function()
		if type(NAmanage._destroyMobileFlyUI) == "function" then
			NAmanage._destroyMobileFlyUI()
		end
	end, 150)
end
