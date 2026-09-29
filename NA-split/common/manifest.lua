local meta = {
	version = "fc836127bf051f1c";
	count = 29;
	directory = "common";
	loader_version = "loader-184644277aba8cc2";
	parts = {
		["part-001.lua"] = "e3f71f57a060d152a5dd544dd748a2e1d15fcb39";
		["part-002.lua"] = "a487d92f456f0db89dcee2b3dae8b8aab652e060";
		["part-003.lua"] = "41a523dfca3f79448563baed040919fb77de4f04";
		["part-004.lua"] = "5ab95a9613c4dcdc052aa1927631902b604ff66e";
		["part-005.lua"] = "6f63370753cadd5494ae7d62b620e418c78e2631";
		["part-006.lua"] = "32eda715d8fcabb98ed0d1b0aeca7cabcdf3e3e1";
		["part-007.lua"] = "4ca504bddecb5b270bd85072719779891143d070";
		["part-008.lua"] = "fd3c9b2179c005827517afa3dd0b7b843fea5e6e";
		["part-009.lua"] = "44859e59b5d4ce8525e338d3e78310939e87b3a2";
		["part-010.lua"] = "6af02b9ee06c88b912f8b15f95076699f192c0e2";
		["part-011.lua"] = "7aa3b597e2796ef7a3ba41a2f568671d88d80522";
		["part-012.lua"] = "d8a903d9e31148bca9bfb8edd0ffb748763dcc59";
		["part-013.lua"] = "9f363890a921de8b23e69370e021f4f54643573c";
		["part-014.lua"] = "51d2051f3e8994abc8660d59be0d7987249885ba";
		["part-015.lua"] = "81d053f9e3e5202ee3940e9d685ad76374b0cbcd";
		["part-016.lua"] = "b6f05610d356ab793180a6b98267ff1dd50f0e51";
		["part-017.lua"] = "8520b3e701d06464c83dcd3c8937c401edf0dfaf";
		["part-018.lua"] = "f3e9f4d25bc40488e2aad124de2f357e5fedec1e";
		["part-019.lua"] = "02721ea6d2e4eb9a3420f71a8cc36e27e13096ed";
		["part-020.lua"] = "d4b6876ce99e77917bb2f90af074ffcdf4b9126d";
		["part-021.lua"] = "c25d275be134e9b4b4282924f11b59f14740cc5f";
		["part-022.lua"] = "6a07a767f56ef6fbfca94888b78d7cc9bd1c9580";
		["part-023.lua"] = "db7d26e8a55ba141dee86451830c7119da9ba394";
		["part-024.lua"] = "aeaf3db30d4324d2257c8871706bc29d6084e424";
		["part-025.lua"] = "21bc3c771b9c698f2dd11b5d20e668eecabc56e2";
		["part-026.lua"] = "ac988ff8f8d8e4862cff72352d9898555cf2a5f3";
		["part-027.lua"] = "3b26a4e3e43d480053eebd8f667152457a65a6dd";
		["part-028.lua"] = "95c53ef60f846a1dffe3141df4b2f4cc81bea883";
		["part-029.lua"] = "dd313e27d6bdfe9f2ec378e292a6047cc27c72f9";
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
