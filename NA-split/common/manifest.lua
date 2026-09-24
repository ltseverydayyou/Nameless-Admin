local meta = {
	version = "f3ba54f4a8ce0fd4";
	count = 29;
	directory = "common";
	loader_version = "loader-184644277aba8cc2";
	parts = {
		["part-001.lua"] = "a32b52c8fdf6b9a3b24c5bfd9b03ae1937c401ab";
		["part-002.lua"] = "db0c7d2b214d6ace22ce6998a19fc32fd56a04bf";
		["part-003.lua"] = "25b9b042a65c9decc7e457d0853eb98eef35cfd8";
		["part-004.lua"] = "bfc2e053eacb7076626eb27db2f62d4754a0185d";
		["part-005.lua"] = "6e04bc0edadbd5c2c5abc844014ea79286dd621d";
		["part-006.lua"] = "9b475c5d7a3ed2170f58c880b4189bf020d44447";
		["part-007.lua"] = "083adcee7d4afd2c330bb5744124296cb8442a7b";
		["part-008.lua"] = "187eecfe41a8bc43c83709697efdf6cf3e3bddf0";
		["part-009.lua"] = "744e4a690025634a48800c796fb4a315e8046c28";
		["part-010.lua"] = "b6748a2ed9aabaa470bffa740634b22e8bf52d6d";
		["part-011.lua"] = "f771a1c46cd81998cd8cbf82adaaeea02178e72c";
		["part-012.lua"] = "0e33aa70d2f25e5dacaa7f65c08e1962364a7fbb";
		["part-013.lua"] = "bb1f0e473b76a24bd7a54ef5aa8b9ab25eef49be";
		["part-014.lua"] = "9f9bcaf4bf0bffaaeb69b2067fb5333b1014d822";
		["part-015.lua"] = "272f432eda8db8fd9ae588b45883f8d2d56c0adb";
		["part-016.lua"] = "ed1f36247448a1e7713749fc705e0e216b97c2a5";
		["part-017.lua"] = "e296c9e88e60914d85d21fa547946d2c827254d4";
		["part-018.lua"] = "ba7263ba338ce4dbed67f2accd90aeeee281e5c9";
		["part-019.lua"] = "6689d4168fb3e2dbde03be28fbf1b881ff846ab3";
		["part-020.lua"] = "61b1694a534760f7d8390199c9b288a021cabeea";
		["part-021.lua"] = "3a6bd5f13bf8c8925cd745183d5943186d6c8e1d";
		["part-022.lua"] = "79b15c67526c84312adfdc2b59acdbe6958634b1";
		["part-023.lua"] = "48e8fe8078b451a1bd252fb441fad8571e13e2d2";
		["part-024.lua"] = "89c8d5dfbceef30a0eb879d89d253ccc1c59752b";
		["part-025.lua"] = "2847dfe2fb1e857d5db3c0a07673d2bee98e537a";
		["part-026.lua"] = "139b345ad3b88236dadffa181ed4ebcc80d0064a";
		["part-027.lua"] = "7480ddc8777800c5f5f1002304ce57f882a55f23";
		["part-028.lua"] = "8d356da2543a43dfe19b58c8a7150ee91c7f8284";
		["part-029.lua"] = "f7b13a785357616f4beded4d7aa28ccef6e4f4f2";
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
