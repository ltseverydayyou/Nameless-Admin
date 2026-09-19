local meta = {
	version = "20260919-nachat-settingsfix";
	count = 29;
	directory = "common";
	loader_version = "20260917-2d86c2904d562946";
	parts = {
		["part-001.lua"] = "89a8f6e5a82d1290c8927bb353b10085dc4fefbc";
		["part-002.lua"] = "7f034b13997f9535aeac1776847b86cab48526be";
		["part-003.lua"] = "816cf0eec7a737258923c96fb7edd29829177ac0";
		["part-004.lua"] = "c899b099f37ffc89ed816fcf464c9c00f9633454";
		["part-005.lua"] = "4fd67e0c04dd61917ce2da2dae409aeb71765773";
		["part-006.lua"] = "9b475c5d7a3ed2170f58c880b4189bf020d44447";
		["part-007.lua"] = "4579a0fa92bb1342552c5a21a7d011f50f6a80ad";
		["part-008.lua"] = "9edef30d6448396dde1e2f26ed59e52d27c4f736";
		["part-009.lua"] = "744e4a690025634a48800c796fb4a315e8046c28";
		["part-010.lua"] = "b6748a2ed9aabaa470bffa740634b22e8bf52d6d";
		["part-011.lua"] = "f771a1c46cd81998cd8cbf82adaaeea02178e72c";
		["part-012.lua"] = "ca9bd6d227a824b9f4dbfd6bb644a730ca66861f";
		["part-013.lua"] = "7c1473a71ef800879a4ae7ca244865fceb7cd5a1";
		["part-014.lua"] = "9f9bcaf4bf0bffaaeb69b2067fb5333b1014d822";
		["part-015.lua"] = "6578d1e82f32670b5d9ed1c8768476281ae10682";
		["part-016.lua"] = "ab7c299f3d0355920a29bdb29145953f454541ee";
		["part-017.lua"] = "e296c9e88e60914d85d21fa547946d2c827254d4";
		["part-018.lua"] = "ba7263ba338ce4dbed67f2accd90aeeee281e5c9";
		["part-019.lua"] = "426a0f6cad45f809841fa639ea6d9f915d2d0890";
		["part-020.lua"] = "8fd2e7d14b62a32068424eb7156abc0c15704e7a";
		["part-021.lua"] = "20e9e8c9a06fafee053273b56c0721eee89f1408";
		["part-022.lua"] = "7626927d27ae03c0db0bb6f41bae1b5ac8a8ec37";
		["part-023.lua"] = "48e8fe8078b451a1bd252fb441fad8571e13e2d2";
		["part-024.lua"] = "0297f6e4ab0ced840a7a8483dd31e61963e3cff1";
		["part-025.lua"] = "a7b9d0ccf04ee4d17c43b43234bb4337bc80d5bc";
		["part-026.lua"] = "176476b74f9024406cbf3cf02cd76e3ef4175c3c";
		["part-027.lua"] = "09effdaa660d5fd19ea8c067d66383dde8d295c8";
		["part-028.lua"] = "39581f0f9679ba7b94ff2b64f7622ce69e4cd625";
		["part-029.lua"] = "6858b19f649588bbaf143217c9cc85bc075075ca";
	};
}

local function cacheLoader()
	if type(writefile) ~= "function" then
		return
	end

	local host = (type(getgenv) == "function" and getgenv()) or _G or {}
	local state = type(host) == "table" and rawget(host, "__NamelessAdminRuntimeState") or nil
	local sourceTag = type(state) == "table" and state.source or nil
	if sourceTag ~= "Source.lua" and sourceTag ~= "NA testing.lua" then
		return
	end

	local roots = {
		"NA-split/";
		"Nameless-Admin/NA-split/";
		"Nameless Admin/NA-split/";
	}
	local root = roots[1]
	if type(isfile) == "function" then
		for _, candidate in roots do
			if isfile(candidate.."common/manifest.lua") then
				root = candidate
				break
			end
		end
	end

	local cachePath = root..sourceTag
	local versionPath = root.."."..sourceTag:gsub("[^%w]+", "_")..".version"
	if type(readfile) == "function" then
		local okVersion, cachedVersion = pcall(readfile, versionPath)
		local okLoader, cachedLoader = pcall(readfile, cachePath)
		if okVersion and cachedVersion == meta.loader_version and okLoader and type(cachedLoader) == "string" and cachedLoader ~= "" then
			return
		end
	end

	local remoteName = sourceTag:gsub(" ", "%%20")
	local url = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/"..remoteName.."?na_loader="..meta.loader_version
	local requestFn = type(host) == "table" and (rawget(host, "request") or rawget(host, "http_request")) or nil
	local synTable = type(host) == "table" and rawget(host, "syn") or nil
	if type(requestFn) ~= "function" and type(synTable) == "table" then
		requestFn = synTable.request
	end

	local source
	if type(requestFn) == "function" then
		local ok, response = pcall(requestFn, { Method = "GET"; Url = url; })
		local status = type(response) == "table" and tonumber(response.StatusCode or response.statusCode or response.Status) or nil
		local body = type(response) == "table" and (response.Body or response.body) or nil
		if ok and type(body) == "string" and body ~= "" and (not status or status < 400) then
			source = body
		end
	end

	if not source and (type(game) == "userdata" or type(game) == "table") then
		local ok, body = pcall(function()
			return game:HttpGet(url)
		end)
		if ok and type(body) == "string" and body ~= "" then
			source = body
		end
	end
	if not source then
		return
	end

	local loader = type(host) == "table" and rawget(host, "loadstring") or nil
	loader = loader or loadstring or load
	if type(loader) ~= "function" then
		return
	end
	local okCompile, chunk = pcall(loader, source, "@"..sourceTag)
	if not okCompile or type(chunk) ~= "function" then
		return
	end

	if type(makefolder) == "function" then
		local parent = root:gsub("/$", "")
		local current = ""
		for segment in parent:gmatch("[^/]+") do
			current = current == "" and segment or current.."/"..segment
			pcall(makefolder, current)
		end
	end
	pcall(writefile, cachePath, source)
	pcall(writefile, versionPath, meta.loader_version)
end

pcall(cacheLoader)
return meta
