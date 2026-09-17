local meta = {
	version = "922c5010d4d9cf8";
	count = 29;
	directory = "common";
	loader_version = "20260914-8c2437a1-45bc2ed6";
	parts = {
		["part-001.lua"] = "c98ce2e90fa249554c631fbaf59e506fab3f88e5";
		["part-002.lua"] = "7f034b13997f9535aeac1776847b86cab48526be";
		["part-003.lua"] = "1d5b84b4312b51137342668cac6069b5cb0c7c0b";
		["part-004.lua"] = "404a2c03ef6c6922c5010d4d9cf8990690df865e";
		["part-005.lua"] = "d0e70e007ae09c14a14457e351a5e54c5d631b16";
		["part-006.lua"] = "9b475c5d7a3ed2170f58c880b4189bf020d44447";
		["part-007.lua"] = "4579a0fa92bb1342552c5a21a7d011f50f6a80ad";
		["part-008.lua"] = "d07d4fd719aac865e562d3ace821eb3ebb7fbff0";
		["part-009.lua"] = "744e4a690025634a48800c796fb4a315e8046c28";
		["part-010.lua"] = "b80876ed4d84ead644df93a547b2a4304b53c3c5";
		["part-011.lua"] = "f771a1c46cd81998cd8cbf82adaaeea02178e72c";
		["part-012.lua"] = "ca9bd6d227a824b9f4dbfd6bb644a730ca66861f";
		["part-013.lua"] = "f49381e30366b1b51f7f573ce46a32589e1ee9ef";
		["part-014.lua"] = "9f9bcaf4bf0bffaaeb69b2067fb5333b1014d822";
		["part-015.lua"] = "9535fb7ac7692c78f9aa32efa0c9bef48ba4dc55";
		["part-016.lua"] = "10d8b30116bd6375020d2ba98c9059bc89faed49";
		["part-017.lua"] = "e296c9e88e60914d85d21fa547946d2c827254d4";
		["part-018.lua"] = "ba7263ba338ce4dbed67f2accd90aeeee281e5c9";
		["part-019.lua"] = "f4e3a487f9b699c5f02a0f15c0b601d9bad849f6";
		["part-020.lua"] = "8ecf5deaa900573c0c9403c43463a1933358bfdf";
		["part-021.lua"] = "20e9e8c9a06fafee053273b56c0721eee89f1408";
		["part-022.lua"] = "75ac52f0e5cc427581d0cce21877ac8cc5bea31c";
		["part-023.lua"] = "48e8fe8078b451a1bd252fb441fad8571e13e2d2";
		["part-024.lua"] = "9d3c51db1d2d8347c32056e27394ca2558d13a0c";
		["part-025.lua"] = "fd7e5263a016293b62bea46c22b96d7685222e0c";
		["part-026.lua"] = "d3b206543ea7ab075b9d427f510c0e1d88fddfaa";
		["part-027.lua"] = "12919b7e202dc80b728b65fb559a0394dcf2cb08";
		["part-028.lua"] = "39581f0f9679ba7b94ff2b64f7622ce69e4cd625";
		["part-029.lua"] = "59cd4422e023b98226873f313d7b32c7f54427cb";
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
