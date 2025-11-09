for _, value in pairs(getgc(true)) do
	if typeof(value) == 'table' then
		if rawget(value, "indexInstance") or rawget(value, "newindexInstance") or rawget(value, "namecallInstance") or rawget(value, "newIndexInstance") then
			value.tvk = {
				"kick",
				function()
					return task.wait(387420489)
				end
			}
		end
	end
end;
