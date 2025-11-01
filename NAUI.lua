local G2L = {};

local function getImageAsset(fileName, fallback)
	if type(getcustomasset) ~= "function" then
		return fallback
	end

	local assetsRoot = "Nameless-Admin"
	local assetsFolder = assetsRoot .. "/Assets"
	local assetPath = assetsFolder .. "/" .. fileName
	local assetUrl = "https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NAimages/" .. fileName

	local function safeCall(fn, ...)
		if type(fn) ~= "function" then
			return nil
		end
		local ok, result = pcall(fn, ...)
		if ok then
			return result
		end
		return nil
	end

	if type(isfolder) == "function" and type(makefolder) == "function" then
		if not safeCall(isfolder, assetsRoot) then
			safeCall(makefolder, assetsRoot)
		end
		if not safeCall(isfolder, assetsFolder) then
			safeCall(makefolder, assetsFolder)
		end
	end

	local hasFile = type(isfile) == "function" and safeCall(isfile, assetPath)
	if not hasFile and type(writefile) == "function" then
		local ok, data = pcall(function()
			return game:HttpGet(assetUrl)
		end)
		if ok and data then
			safeCall(writefile, assetPath, data)
		end
	end

	local customAsset = safeCall(getcustomasset, assetPath)
	if customAsset then
		return customAsset
	end

	return fallback
end

G2L["1"] = Instance.new("ScreenGui");
G2L["1"]["Name"] = [[AdminUI]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(24, 24, 29);
G2L["2"]["Size"] = UDim2.new(0, 450, 0, 300);
G2L["2"]["Position"] = UDim2.new(0.64327, 0, 0.49955, 0);
G2L["2"]["Name"] = [[ChatLogs]];
G2L["2"]["BackgroundTransparency"] = 0.05;


G2L["3"] = Instance.new("Frame", G2L["2"]);
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(34, 34, 39);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["ClipsDescendants"] = true;
G2L["3"]["Size"] = UDim2.new(1, -15, 0.96667, -30);
G2L["3"]["Position"] = UDim2.new(0.5, 0, 0.51667, 15);
G2L["3"]["Name"] = [[Container]];
G2L["3"]["BackgroundTransparency"] = 1;


G2L["4"] = Instance.new("ScrollingFrame", G2L["3"]);
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4"]["Name"] = [[Logs]];
G2L["4"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4"]["Size"] = UDim2.new(1, -15, 1, -15);
G2L["4"]["ScrollBarImageColor3"] = Color3.fromRGB(124, 124, 134);
G2L["4"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["4"]["ScrollBarThickness"] = 2;
G2L["4"]["BackgroundTransparency"] = 1;


G2L["5"] = Instance.new("UIListLayout", G2L["4"]);
G2L["5"]["Padding"] = UDim.new(0, 8);
G2L["5"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


G2L["6"] = Instance.new("TextLabel", G2L["4"]);
G2L["6"]["TextWrapped"] = true;
G2L["6"]["TextSize"] = 16;
G2L["6"]["TextScaled"] = true;
G2L["6"]["RichText"] = true;
G2L["6"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["6"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["6"]["TextColor3"] = Color3.fromRGB(224, 224, 234);
G2L["6"]["BackgroundTransparency"] = 0.4;
G2L["6"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["6"]["Text"] = [[[Roblox]: Hello, World!]];


G2L["7"] = Instance.new("UICorner", G2L["6"]);
G2L["7"]["CornerRadius"] = UDim.new(0, 4);


G2L["8"] = Instance.new("Frame", G2L["2"]);
G2L["8"]["BorderSizePixel"] = 0;
G2L["8"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["8"]["Size"] = UDim2.new(1, 0, 0, 40);
G2L["8"]["Name"] = [[Topbar]];
G2L["8"]["BackgroundTransparency"] = 0.1;


G2L["9"] = Instance.new("TextLabel", G2L["8"]);
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["TextSize"] = 20;
G2L["9"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9"]["TextColor3"] = Color3.fromRGB(244, 244, 254);
G2L["9"]["BackgroundTransparency"] = 1;
G2L["9"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["9"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["9"]["Text"] = [[Chat Logs]];
G2L["9"]["Name"] = [[Title]];
G2L["9"]["Position"] = UDim2.new(0, 15, 0.5, 0);


G2L["a"] = Instance.new("UIGradient", G2L["8"]);
G2L["a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["b"] = Instance.new("UICorner", G2L["8"]);
G2L["b"]["CornerRadius"] = UDim.new(0, 10);


G2L["c0"] = Instance.new("TextButton", G2L["8"]);
G2L["c0"]["BorderSizePixel"] = 0;
G2L["c0"]["TextSize"] = 14;
G2L["c0"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["c0"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["c0"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c0"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c0"]["BackgroundTransparency"] = 0.2;
G2L["c0"]["Size"] = UDim2.new(0, 88, 0, 26);
G2L["c0"]["Text"] = [[Translate]];
G2L["c0"]["Name"] = [[Translate]];
G2L["c0"]["Position"] = UDim2.new(0.98222, -145, 0.5, 0);


G2L["c1"] = Instance.new("UICorner", G2L["c0"]);
G2L["c1"]["CornerRadius"] = UDim.new(0, 6);


G2L["c2"] = Instance.new("UIStroke", G2L["c0"]);
G2L["c2"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c2"]["Thickness"] = 2;
G2L["c2"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["c3"] = Instance.new("TextBox", G2L["8"]);
G2L["c3"]["BorderSizePixel"] = 0;
G2L["c3"]["TextSize"] = 14;
G2L["c3"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["c3"]["BackgroundColor3"] = Color3.fromRGB(48, 48, 58);
G2L["c3"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c3"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c3"]["PlaceholderText"] = [[Lang]];
G2L["c3"]["Size"] = UDim2.new(0, 70, 0, 26);
G2L["c3"]["Text"] = [[EN]];
G2L["c3"]["Name"] = [[TranslateInput]];
G2L["c3"]["Position"] = UDim2.new(0.98222, -235, 0.5, 0);


G2L["c4"] = Instance.new("UICorner", G2L["c3"]);
G2L["c4"]["CornerRadius"] = UDim.new(0, 6);


G2L["c5"] = Instance.new("UIStroke", G2L["c3"]);
G2L["c5"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c5"]["Thickness"] = 2;
G2L["c5"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["c"] = Instance.new("TextButton", G2L["8"]);
G2L["c"]["BorderSizePixel"] = 0;
G2L["c"]["TextSize"] = 14;
G2L["c"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["c"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c"]["BackgroundTransparency"] = 0.2;
G2L["c"]["Size"] = UDim2.new(0, 60, 0, 26);
G2L["c"]["Text"] = [[Clear]];
G2L["c"]["Name"] = [[Clear]];
G2L["c"]["Position"] = UDim2.new(0.98222, -70, 0.5, 0);


G2L["d"] = Instance.new("UICorner", G2L["c"]);
G2L["d"]["CornerRadius"] = UDim.new(0, 6);


G2L["e"] = Instance.new("UIStroke", G2L["c"]);
G2L["e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["e"]["Thickness"] = 2;
G2L["e"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["f"] = Instance.new("TextButton", G2L["8"]);
G2L["f"]["BorderSizePixel"] = 0;
G2L["f"]["TextSize"] = 16;
G2L["f"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["f"]["BackgroundColor3"] = Color3.fromRGB(184, 54, 54);
G2L["f"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["f"]["BackgroundTransparency"] = 0.2;
G2L["f"]["Size"] = UDim2.new(0, 26, 0, 26);
G2L["f"]["Text"] = [[×]];
G2L["f"]["Name"] = [[Exit]];
G2L["f"]["Position"] = UDim2.new(0.98222, 0, 0.5, 0);


G2L["10"] = Instance.new("UICorner", G2L["f"]);
G2L["10"]["CornerRadius"] = UDim.new(0, 6);


G2L["11"] = Instance.new("UIStroke", G2L["f"]);
G2L["11"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["11"]["Thickness"] = 2;
G2L["11"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["12"] = Instance.new("TextButton", G2L["8"]);
G2L["12"]["BorderSizePixel"] = 0;
G2L["12"]["TextSize"] = 16;
G2L["12"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["12"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["12"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["12"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["12"]["BackgroundTransparency"] = 0.2;
G2L["12"]["Size"] = UDim2.new(0, 26, 0, 26);
G2L["12"]["Text"] = [[−]];
G2L["12"]["Name"] = [[Minimize]];
G2L["12"]["Position"] = UDim2.new(0.98222, -35, 0.5, 0);


G2L["13"] = Instance.new("UICorner", G2L["12"]);
G2L["13"]["CornerRadius"] = UDim.new(0, 6);


G2L["14"] = Instance.new("UIStroke", G2L["12"]);
G2L["14"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["14"]["Thickness"] = 2;
G2L["14"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["15"] = Instance.new("UIStroke", G2L["8"]);
G2L["15"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["15"]["Thickness"] = 2;
G2L["15"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["16"] = Instance.new("UICorner", G2L["2"]);
G2L["16"]["CornerRadius"] = UDim.new(0, 10);


G2L["17"] = Instance.new("UIGradient", G2L["2"]);
G2L["17"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 29, 34)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(24, 24, 29))};


G2L["18"] = Instance.new("UIStroke", G2L["2"]);
G2L["18"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["18"]["Thickness"] = 2;
G2L["18"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["19"] = Instance.new("Frame", G2L["1"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(29, 29, 34);
G2L["19"]["Size"] = UDim2.new(0, 300, 0, 320);
G2L["19"]["Position"] = UDim2.new(0.01177, 0, 0.01911, 0);
G2L["19"]["Name"] = [[Commands]];
G2L["19"]["BackgroundTransparency"] = 0.1;


G2L["1a"] = Instance.new("Frame", G2L["19"]);
G2L["1a"]["BorderSizePixel"] = 0;
G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["1a"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["1a"]["ClipsDescendants"] = true;
G2L["1a"]["Size"] = UDim2.new(1, -15, 1, -50);
G2L["1a"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["1a"]["Name"] = [[Container]];
G2L["1a"]["BackgroundTransparency"] = 0.3;


G2L["1b"] = Instance.new("ScrollingFrame", G2L["1a"]);
G2L["1b"]["BorderSizePixel"] = 0;
G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["Name"] = [[List]];
G2L["1b"]["Size"] = UDim2.new(1, -10, 1, -35);
G2L["1b"]["ScrollBarImageColor3"] = Color3.fromRGB(104, 104, 114);
G2L["1b"]["Position"] = UDim2.new(0, 5, 0, 30);
G2L["1b"]["ScrollBarThickness"] = 3;
G2L["1b"]["BackgroundTransparency"] = 1;


G2L["1c"] = Instance.new("UIListLayout", G2L["1b"]);
G2L["1c"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["1c"]["Padding"] = UDim.new(0, 5);


G2L["1d"] = Instance.new("TextLabel", G2L["1b"]);
G2L["1d"]["TextWrapped"] = true;
G2L["1d"]["TextSize"] = 16;
G2L["1d"]["TextScaled"] = true;
G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["1d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1d"]["TextColor3"] = Color3.fromRGB(224, 224, 234);
G2L["1d"]["BackgroundTransparency"] = 0.4;
G2L["1d"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["1d"]["Text"] = [[example <player> <text>]];


G2L["1e"] = Instance.new("UICorner", G2L["1d"]);
G2L["1e"]["CornerRadius"] = UDim.new(0, 4);


G2L["1f"] = Instance.new("TextBox", G2L["1a"]);
G2L["1f"]["Name"] = [[Filter]];
G2L["1f"]["PlaceholderColor3"] = Color3.fromRGB(154, 154, 164);
G2L["1f"]["BorderSizePixel"] = 0;
G2L["1f"]["TextSize"] = 16;
G2L["1f"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["1f"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1f"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["1f"]["PlaceholderText"] = [[Filter commands...]];
G2L["1f"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["1f"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["1f"]["Text"] = [[]];
G2L["1f"]["BackgroundTransparency"] = 0.5;


G2L["20"] = Instance.new("UICorner", G2L["1f"]);
G2L["20"]["CornerRadius"] = UDim.new(0, 6);


G2L["21"] = Instance.new("UIStroke", G2L["1f"]);
G2L["21"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["21"]["Thickness"] = 2;
G2L["21"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["22"] = Instance.new("UICorner", G2L["1a"]);



G2L["23"] = Instance.new("UIGradient", G2L["1a"]);
G2L["23"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["24"] = Instance.new("Frame", G2L["19"]);
G2L["24"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["24"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["24"]["Name"] = [[Topbar]];
G2L["24"]["BackgroundTransparency"] = 0.2;


G2L["25"] = Instance.new("TextButton", G2L["24"]);
G2L["25"]["BorderSizePixel"] = 0;
G2L["25"]["TextSize"] = 16;
G2L["25"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["25"]["BackgroundColor3"] = Color3.fromRGB(184, 54, 54);
G2L["25"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["25"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["25"]["BackgroundTransparency"] = 0.3;
G2L["25"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["25"]["Text"] = [[×]];
G2L["25"]["Name"] = [[Exit]];
G2L["25"]["Position"] = UDim2.new(1, -10, 0.5, 0);


G2L["26"] = Instance.new("UICorner", G2L["25"]);
G2L["26"]["CornerRadius"] = UDim.new(0, 6);


G2L["27"] = Instance.new("UIStroke", G2L["25"]);
G2L["27"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["27"]["Thickness"] = 2;
G2L["27"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["28"] = Instance.new("TextButton", G2L["24"]);
G2L["28"]["BorderSizePixel"] = 0;
G2L["28"]["TextSize"] = 16;
G2L["28"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["28"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["28"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["28"]["BackgroundTransparency"] = 0.3;
G2L["28"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["28"]["Text"] = [[−]];
G2L["28"]["Name"] = [[Minimize]];
G2L["28"]["Position"] = UDim2.new(1, -40, 0.5, 0);


G2L["29"] = Instance.new("UICorner", G2L["28"]);
G2L["29"]["CornerRadius"] = UDim.new(0, 6);


G2L["2a"] = Instance.new("UIStroke", G2L["28"]);
G2L["2a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["2a"]["Thickness"] = 2;
G2L["2a"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["2b"] = Instance.new("TextLabel", G2L["24"]);
G2L["2b"]["BorderSizePixel"] = 0;
G2L["2b"]["TextSize"] = 18;
G2L["2b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["2b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2b"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["2b"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["2b"]["BackgroundTransparency"] = 1;
G2L["2b"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["2b"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["2b"]["Text"] = [[Commands]];
G2L["2b"]["Name"] = [[Title]];
G2L["2b"]["Position"] = UDim2.new(0, 10, 0.5, 0);


G2L["2c"] = Instance.new("UICorner", G2L["24"]);
G2L["2c"]["CornerRadius"] = UDim.new(0, 10);


G2L["2d"] = Instance.new("UIStroke", G2L["24"]);
G2L["2d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["2d"]["Thickness"] = 2;
G2L["2d"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["2e"] = Instance.new("UICorner", G2L["19"]);
G2L["2e"]["CornerRadius"] = UDim.new(0, 10);


G2L["2f"] = Instance.new("UIGradient", G2L["19"]);
G2L["2f"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(34, 34, 39)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(24, 24, 29))};


G2L["30"] = Instance.new("UIStroke", G2L["19"]);
G2L["30"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["30"]["Thickness"] = 2;
G2L["30"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["31"] = Instance.new("Frame", G2L["1"]);
G2L["31"]["BorderSizePixel"] = 0;
G2L["31"]["BackgroundColor3"] = Color3.fromRGB(32, 32, 36);
G2L["31"]["Size"] = UDim2.new(0, 420, 0, 280);
G2L["31"]["Position"] = UDim2.new(0.6609, 0, 0.00745, 0);
G2L["31"]["Name"] = [[soRealConsole]];
G2L["31"]["BackgroundTransparency"] = 0.1;


G2L["32"] = Instance.new("Frame", G2L["31"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["32"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["32"]["ClipsDescendants"] = true;
G2L["32"]["Size"] = UDim2.new(1, -15, 1, -45);
G2L["32"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["32"]["Name"] = [[Container]];
G2L["32"]["BackgroundTransparency"] = 0.3;


G2L["33"] = Instance.new("ScrollingFrame", G2L["32"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["33"]["Name"] = [[Logs]];
G2L["33"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["33"]["Size"] = UDim2.new(1, -10, 0.9, -35);
G2L["33"]["ScrollBarImageColor3"] = Color3.fromRGB(104, 104, 114);
G2L["33"]["Position"] = UDim2.new(0.5, 0, 0.62, 0);
G2L["33"]["ScrollBarThickness"] = 3;
G2L["33"]["BackgroundTransparency"] = 1;


G2L["34"] = Instance.new("UIListLayout", G2L["33"]);
G2L["34"]["Padding"] = UDim.new(0, 5);
G2L["34"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


G2L["35"] = Instance.new("TextLabel", G2L["33"]);
G2L["35"]["TextWrapped"] = true;
G2L["35"]["TextSize"] = 16;
G2L["35"]["TextScaled"] = true;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["35"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["35"]["TextColor3"] = Color3.fromRGB(224, 224, 234);
G2L["35"]["BackgroundTransparency"] = 0.5;
G2L["35"]["Size"] = UDim2.new(1, 0, 0, 26);
G2L["35"]["Text"] = [[[Output]: failed print 1]];


G2L["36"] = Instance.new("UICorner", G2L["35"]);
G2L["36"]["CornerRadius"] = UDim.new(0, 5);


G2L["37"] = Instance.new("UICorner", G2L["32"]);



G2L["38"] = Instance.new("UIGradient", G2L["32"]);
G2L["38"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["39"] = Instance.new("TextBox", G2L["32"]);
G2L["39"]["Name"] = [[Filter]];
G2L["39"]["PlaceholderColor3"] = Color3.fromRGB(154, 154, 164);
G2L["39"]["BorderSizePixel"] = 0;
G2L["39"]["TextSize"] = 16;
G2L["39"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["39"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["39"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["39"]["PlaceholderText"] = [[Search...]];
G2L["39"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["39"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["39"]["Text"] = [[]];
G2L["39"]["BackgroundTransparency"] = 0.5;


G2L["3a"] = Instance.new("UICorner", G2L["39"]);
G2L["3a"]["CornerRadius"] = UDim.new(0, 6);


G2L["3b"] = Instance.new("UIStroke", G2L["39"]);
G2L["3b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["3b"]["Thickness"] = 2;
G2L["3b"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["3c"] = Instance.new("Frame", G2L["31"]);
G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["3c"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["3c"]["Name"] = [[Topbar]];
G2L["3c"]["BackgroundTransparency"] = 0.2;


G2L["3d"] = Instance.new("TextButton", G2L["3c"]);
G2L["3d"]["BorderSizePixel"] = 0;
G2L["3d"]["TextSize"] = 16;
G2L["3d"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["3d"]["BackgroundColor3"] = Color3.fromRGB(184, 54, 54);
G2L["3d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3d"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["3d"]["BackgroundTransparency"] = 0.3;
G2L["3d"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["3d"]["Text"] = [[×]];
G2L["3d"]["Name"] = [[Exit]];
G2L["3d"]["Position"] = UDim2.new(1, -10, 0.5, 0);


G2L["3e"] = Instance.new("UICorner", G2L["3d"]);
G2L["3e"]["CornerRadius"] = UDim.new(0, 6);


G2L["3f"] = Instance.new("UIStroke", G2L["3d"]);
G2L["3f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["3f"]["Thickness"] = 2;
G2L["3f"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["40"] = Instance.new("TextButton", G2L["3c"]);
G2L["40"]["BorderSizePixel"] = 0;
G2L["40"]["TextSize"] = 16;
G2L["40"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["40"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["40"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["40"]["BackgroundTransparency"] = 0.3;
G2L["40"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["40"]["Text"] = [[−]];
G2L["40"]["Name"] = [[Minimize]];
G2L["40"]["Position"] = UDim2.new(1, -40, 0.5, 0);


G2L["41"] = Instance.new("UICorner", G2L["40"]);
G2L["41"]["CornerRadius"] = UDim.new(0, 6);


G2L["42"] = Instance.new("UIStroke", G2L["40"]);
G2L["42"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["42"]["Thickness"] = 2;
G2L["42"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["43"] = Instance.new("TextButton", G2L["3c"]);
G2L["43"]["BorderSizePixel"] = 0;
G2L["43"]["TextSize"] = 14;
G2L["43"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["43"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["43"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["43"]["BackgroundTransparency"] = 0.3;
G2L["43"]["Size"] = UDim2.new(0, 60, 0, 24);
G2L["43"]["Text"] = [[Clear]];
G2L["43"]["Name"] = [[Clear]];
G2L["43"]["Position"] = UDim2.new(0, 10, 0.5, 0);


G2L["44"] = Instance.new("UICorner", G2L["43"]);
G2L["44"]["CornerRadius"] = UDim.new(0, 6);


G2L["45"] = Instance.new("UIStroke", G2L["43"]);
G2L["45"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["45"]["Thickness"] = 2;
G2L["45"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["46"] = Instance.new("TextLabel", G2L["3c"]);
G2L["46"]["TextWrapped"] = true;
G2L["46"]["BorderSizePixel"] = 0;
G2L["46"]["TextSize"] = 18;
G2L["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["46"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["46"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["46"]["BackgroundTransparency"] = 1;
G2L["46"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["46"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["46"]["Text"] = [[NA Console]];
G2L["46"]["Name"] = [[Title]];
G2L["46"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


G2L["47"] = Instance.new("UICorner", G2L["3c"]);
G2L["47"]["CornerRadius"] = UDim.new(0, 10);


G2L["48"] = Instance.new("UIStroke", G2L["3c"]);
G2L["48"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["48"]["Thickness"] = 2;
G2L["48"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["49"] = Instance.new("UICorner", G2L["31"]);
G2L["49"]["CornerRadius"] = UDim.new(0, 10);


G2L["4a"] = Instance.new("UIGradient", G2L["31"]);
G2L["4a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(34, 34, 39)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 29, 34))};


G2L["4b"] = Instance.new("UIStroke", G2L["31"]);
G2L["4b"]["Thickness"] = 2;
G2L["4b"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["4c"] = Instance.new("Frame", G2L["1"]);
G2L["4c"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4c"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4c"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["4c"]["Position"] = UDim2.new(0.5, 0, 0.5, -20);
G2L["4c"]["Name"] = [[CmdBar]];
G2L["4c"]["BackgroundTransparency"] = 1;


G2L["4d"] = Instance.new("Frame", G2L["4c"]);
G2L["4d"]["ZIndex"] = 2;
G2L["4d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4d"]["Size"] = UDim2.new(0, 280, 1, 10);
G2L["4d"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["4d"]["Name"] = [[CenterBar]];
G2L["4d"]["BackgroundTransparency"] = 1;


G2L["4e"] = Instance.new("Frame", G2L["4d"]);
G2L["4e"]["ZIndex"] = 2;
G2L["4e"]["BorderSizePixel"] = 0;
G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["4e"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["4e"]["Name"] = [[Horizontal]];
G2L["4e"]["BackgroundTransparency"] = 0.2;


G2L["4f"] = Instance.new("UICorner", G2L["4e"]);



G2L["50"] = Instance.new("UIGradient", G2L["4e"]);
G2L["50"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["51"] = Instance.new("TextBox", G2L["4d"]);
G2L["51"]["Active"] = false;
G2L["51"]["Name"] = [[Input]];
G2L["51"]["ZIndex"] = 2;
G2L["51"]["TextWrapped"] = true;
G2L["51"]["TextSize"] = 20;
G2L["51"]["TextColor3"] = Color3.fromRGB(244, 244, 254);
G2L["51"]["TextScaled"] = true;
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["51"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["51"]["ClipsDescendants"] = true;
G2L["51"]["Size"] = UDim2.new(1, -10, 0.7, 0);
G2L["51"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["51"]["Text"] = [[]];
G2L["51"]["BackgroundTransparency"] = 1;


G2L["52"] = Instance.new("Frame", G2L["4c"]);
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["52"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["52"]["Size"] = UDim2.new(0.5, -140, 1, 0);
G2L["52"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["52"]["Name"] = [[LeftFill]];
G2L["52"]["BackgroundTransparency"] = 1;


G2L["53"] = Instance.new("Frame", G2L["52"]);
G2L["53"]["BorderSizePixel"] = 0;
G2L["53"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["53"]["Size"] = UDim2.new(1.005, 0, 1, 0);
G2L["53"]["Name"] = [[Horizontal]];
G2L["53"]["BackgroundTransparency"] = 0.2;


G2L["54"] = Instance.new("UICorner", G2L["53"]);



G2L["55"] = Instance.new("UIGradient", G2L["53"]);
G2L["55"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["56"] = Instance.new("Frame", G2L["4c"]);
G2L["56"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["56"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["56"]["Size"] = UDim2.new(0.5, -140, 1, 0);
G2L["56"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["56"]["Name"] = [[RightFill]];
G2L["56"]["BackgroundTransparency"] = 1;


G2L["57"] = Instance.new("Frame", G2L["56"]);
G2L["57"]["BorderSizePixel"] = 0;
G2L["57"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["57"]["Size"] = UDim2.new(1.005, 0, 1, 0);
G2L["57"]["Position"] = UDim2.new(-0.005, 0, 0, 0);
G2L["57"]["Name"] = [[Horizontal]];
G2L["57"]["BackgroundTransparency"] = 0.2;


G2L["58"] = Instance.new("UICorner", G2L["57"]);



G2L["59"] = Instance.new("UIGradient", G2L["57"]);
G2L["59"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["5a"] = Instance.new("ScrollingFrame", G2L["4c"]);
G2L["5a"]["CanvasSize"] = UDim2.new(0, 0, 5, 0);
G2L["5a"]["ScrollingEnabled"] = false;
G2L["5a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5a"]["Name"] = [[Autofill]];
G2L["5a"]["Selectable"] = false;
G2L["5a"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["5a"]["Size"] = UDim2.new(1, 0, 0, 150);
G2L["5a"]["Position"] = UDim2.new(0.5, 0, -6.5, 15);
G2L["5a"]["BackgroundTransparency"] = 1;


G2L["5b"] = Instance.new("Frame", G2L["5a"]);
G2L["5b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5b"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["5b"]["Size"] = UDim2.new(0.5, 0, 0, 28);
G2L["5b"]["Position"] = UDim2.new(0.5, 0, 0.82, 0);
G2L["5b"]["Name"] = [[Cmd]];
G2L["5b"]["BackgroundTransparency"] = 1;


G2L["5c"] = Instance.new("TextButton", G2L["5b"]);
G2L["5c"]["TextWrapped"] = true;
G2L["5c"]["TextSize"] = 18;
G2L["5c"]["TextScaled"] = true;
G2L["5c"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["5c"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 26);
G2L["5c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5c"]["ZIndex"] = 2;
G2L["5c"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["5c"]["BackgroundTransparency"] = 1;
G2L["5c"]["Size"] = UDim2.new(1, 0, 1, -5);
G2L["5c"]["ClipsDescendants"] = true;
G2L["5c"]["Text"] = [[example <player> <text>]];
G2L["5c"]["Name"] = [[Input]];
G2L["5c"]["Position"] = UDim2.new(0, 0, 0.5, 0);


G2L["5d"] = Instance.new("Frame", G2L["5b"]);
G2L["5d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5d"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["5d"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5d"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["5d"]["Name"] = [[Background]];
G2L["5d"]["BackgroundTransparency"] = 1;


G2L["5e"] = Instance.new("Frame", G2L["5d"]);
G2L["5e"]["BorderSizePixel"] = 0;
G2L["5e"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["5e"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5e"]["Name"] = [[Horizontal]];
G2L["5e"]["BackgroundTransparency"] = 0.3;


G2L["5f"] = Instance.new("UICorner", G2L["5e"]);
G2L["5f"]["CornerRadius"] = UDim.new(0, 6);


G2L["60"] = Instance.new("UIGradient", G2L["5e"]);
G2L["60"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(49, 49, 54)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(39, 39, 44))};


G2L["61"] = Instance.new("UIListLayout", G2L["5a"]);
G2L["61"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["61"]["Padding"] = UDim.new(0, 5);
G2L["61"]["VerticalAlignment"] = Enum.VerticalAlignment.Bottom;
G2L["61"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


G2L["62"] = Instance.new("TextLabel", G2L["1"]);
G2L["62"]["TextWrapped"] = true;
G2L["62"]["TextSize"] = 13;
G2L["62"]["TextScaled"] = true;
G2L["62"]["BackgroundColor3"] = Color3.fromRGB(21, 13, 29);
G2L["62"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["62"]["TextColor3"] = Color3.fromRGB(250, 250, 250);
G2L["62"]["BackgroundTransparency"] = 0.3;
G2L["62"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["62"]["Size"] = UDim2.new(0, 191, 0, 26);
G2L["62"]["Visible"] = false;
G2L["62"]["BorderColor3"] = Color3.fromRGB(62, 62, 62);
G2L["62"]["Text"] = [[Name]];
G2L["62"]["Name"] = [[Description]];


G2L["63"] = Instance.new("UICorner", G2L["62"]);



G2L["64"] = Instance.new("UIScale", G2L["1"]);
G2L["64"]["Name"] = [[AutoScale]];


G2L["65"] = Instance.new("ImageButton", G2L["1"]);
G2L["65"]["BackgroundTransparency"] = 1;
G2L["65"]["Name"] = [[Modal]];


G2L["66"] = Instance.new("Frame", G2L["1"]);
G2L["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["66"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["66"]["Name"] = [[Resizeable]];
G2L["66"]["BackgroundTransparency"] = 1;


G2L["67"] = Instance.new("Frame", G2L["66"]);
G2L["67"]["BorderSizePixel"] = 0;
G2L["67"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["67"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["67"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["67"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["67"]["Name"] = [[Left]];
G2L["67"]["BackgroundTransparency"] = 1;


G2L["68"] = Instance.new("Frame", G2L["66"]);
G2L["68"]["BorderSizePixel"] = 0;
G2L["68"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["68"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["68"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["68"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["68"]["Name"] = [[Right]];
G2L["68"]["BackgroundTransparency"] = 1;


G2L["69"] = Instance.new("Frame", G2L["66"]);
G2L["69"]["BorderSizePixel"] = 0;
G2L["69"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["69"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["69"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["69"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["69"]["Name"] = [[Top]];
G2L["69"]["BackgroundTransparency"] = 1;


G2L["6a"] = Instance.new("Frame", G2L["66"]);
G2L["6a"]["BorderSizePixel"] = 0;
G2L["6a"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["6a"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["6a"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["6a"]["Position"] = UDim2.new(0.5, 0, 1, 0);
G2L["6a"]["Name"] = [[Bottom]];
G2L["6a"]["BackgroundTransparency"] = 1;


G2L["6b"] = Instance.new("Frame", G2L["66"]);
G2L["6b"]["BorderSizePixel"] = 0;
G2L["6b"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["6b"]["AnchorPoint"] = Vector2.new(1, 1);
G2L["6b"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6b"]["Position"] = UDim2.new(0, 4, 0, 4);
G2L["6b"]["Name"] = [[TopLeft]];
G2L["6b"]["BackgroundTransparency"] = 1;


G2L["6c"] = Instance.new("Frame", G2L["66"]);
G2L["6c"]["BorderSizePixel"] = 0;
G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["6c"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["6c"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6c"]["Position"] = UDim2.new(1, -4, 0, 4);
G2L["6c"]["Name"] = [[TopRight]];
G2L["6c"]["BackgroundTransparency"] = 1;


G2L["6d"] = Instance.new("Frame", G2L["66"]);
G2L["6d"]["BorderSizePixel"] = 0;
G2L["6d"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["6d"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["6d"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6d"]["Position"] = UDim2.new(0, 4, 1, -4);
G2L["6d"]["Name"] = [[BottomLeft]];
G2L["6d"]["BackgroundTransparency"] = 1;


G2L["6e"] = Instance.new("Frame", G2L["66"]);
G2L["6e"]["BorderSizePixel"] = 0;
G2L["6e"]["BackgroundColor3"] = Color3.fromRGB(0, 209, 255);
G2L["6e"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6e"]["Position"] = UDim2.new(1, -4, 1, -4);
G2L["6e"]["Name"] = [[BottomRight]];
G2L["6e"]["BackgroundTransparency"] = 1;


G2L["6f"] = Instance.new("Frame", G2L["1"]);
G2L["6f"]["BorderSizePixel"] = 0;
G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(29, 29, 34);
G2L["6f"]["Size"] = UDim2.new(0, 520, 0, 360);
G2L["6f"]["Position"] = UDim2.new(0.46273, 0, 0.74352, 0);
G2L["6f"]["Name"] = [[setsettings]];
G2L["6f"]["BackgroundTransparency"] = 0.1;


G2L["70"] = Instance.new("Frame", G2L["6f"]);
G2L["70"]["BorderSizePixel"] = 0;
G2L["70"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["70"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["70"]["ClipsDescendants"] = true;
G2L["70"]["Size"] = UDim2.new(1, -15, 1, -40);
G2L["70"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["70"]["Name"] = [[Container]];
G2L["70"]["BackgroundTransparency"] = 0.3;


G2L["70a"] = Instance.new("Frame", G2L["70"]);
G2L["70a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["70a"]["BackgroundTransparency"] = 1;
G2L["70a"]["BorderSizePixel"] = 0;
G2L["70a"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["70a"]["Name"] = [[TabContainer]];

G2L["70b"] = Instance.new("ScrollingFrame", G2L["70a"]);
G2L["70b"]["AutomaticCanvasSize"] = Enum.AutomaticSize.X;
G2L["70b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["70b"]["BackgroundTransparency"] = 1;
G2L["70b"]["BorderSizePixel"] = 0;
G2L["70b"]["ScrollBarImageColor3"] = Color3.fromRGB(104, 104, 114);
G2L["70b"]["ScrollBarThickness"] = 3;
G2L["70b"]["ScrollingDirection"] = Enum.ScrollingDirection.X;
G2L["70b"]["Size"] = UDim2.new(1, -10, 0, 36);
G2L["70b"]["Position"] = UDim2.new(0, 5, 0, 5);
G2L["70b"]["Name"] = [[TabList]];

G2L["70c"] = Instance.new("UIListLayout", G2L["70b"]);
G2L["70c"]["FillDirection"] = Enum.FillDirection.Horizontal;
G2L["70c"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Left;
G2L["70c"]["Padding"] = UDim.new(0, 6);

G2L["70d"] = Instance.new("UIPadding", G2L["70b"]);
G2L["70d"]["PaddingBottom"] = UDim.new(0, 4);
G2L["70d"]["PaddingLeft"] = UDim.new(0, 4);
G2L["70d"]["PaddingRight"] = UDim.new(0, 4);
G2L["70d"]["PaddingTop"] = UDim.new(0, 4);

G2L["70e"] = Instance.new("Frame", G2L["70b"]);
G2L["70e"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["70e"]["BackgroundTransparency"] = 0.25;
G2L["70e"]["BorderSizePixel"] = 0;
G2L["70e"]["Size"] = UDim2.new(0, 120, 0, 28);
G2L["70e"]["Visible"] = false;
G2L["70e"]["Name"] = [[TabButton]];

G2L["70f"] = Instance.new("TextLabel", G2L["70e"]);
G2L["70f"]["TextWrapped"] = true;
G2L["70f"]["BorderSizePixel"] = 0;
G2L["70f"]["TextSize"] = 16;
G2L["70f"]["TextXAlignment"] = Enum.TextXAlignment.Center;
G2L["70f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["70f"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["70f"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["70f"]["BackgroundTransparency"] = 1;
G2L["70f"]["Size"] = UDim2.new(1, -10, 1, 0);
G2L["70f"]["Position"] = UDim2.new(0, 5, 0, 0);
G2L["70f"]["Text"] = [[Tab]];
G2L["70f"]["Name"] = [[Title]];

G2L["70g"] = Instance.new("TextButton", G2L["70e"]);
G2L["70g"]["BorderSizePixel"] = 0;
G2L["70g"]["TextSize"] = 14;
G2L["70g"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["70g"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["70g"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["70g"]["BackgroundTransparency"] = 1;
G2L["70g"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["70g"]["Name"] = [[Interact]];
G2L["70g"]["Text"] = [[]];

G2L["70h"] = Instance.new("UICorner", G2L["70e"]);
G2L["70h"]["CornerRadius"] = UDim.new(0, 6);

G2L["70i"] = Instance.new("UIStroke", G2L["70e"]);
G2L["70i"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["70i"]["Thickness"] = 1.5;
G2L["70i"]["Color"] = Color3.fromRGB(154, 99, 255);

G2L["70j"] = Instance.new("Frame", G2L["70a"]);
G2L["70j"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["70j"]["BackgroundTransparency"] = 1;
G2L["70j"]["BorderSizePixel"] = 0;
G2L["70j"]["ClipsDescendants"] = true;
G2L["70j"]["Size"] = UDim2.new(1, -10, 1, -55);
G2L["70j"]["Position"] = UDim2.new(0, 5, 0, 45);
G2L["70j"]["Name"] = [[Pages]];


G2L["71"] = Instance.new("ScrollingFrame", G2L["70j"]);
G2L["71"]["BorderSizePixel"] = 0;
G2L["71"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["71"]["Name"] = [[List]];
G2L["71"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["71"]["ScrollBarImageColor3"] = Color3.fromRGB(104, 104, 114);
G2L["71"]["Position"] = UDim2.new(0, 0, 0, 0);
G2L["71"]["ScrollBarThickness"] = 3;
G2L["71"]["BackgroundTransparency"] = 1;


G2L["72"] = Instance.new("UIListLayout", G2L["71"]);
G2L["72"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["72"]["Padding"] = UDim.new(0, 5);
G2L["72"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


G2L["73"] = Instance.new("Frame", G2L["71"]);
G2L["73"]["BorderSizePixel"] = 0;
G2L["73"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["73"]["Size"] = UDim2.new(1, -10, 0, 42);
G2L["73"]["Name"] = [[Toggle]];


G2L["74"] = Instance.new("TextLabel", G2L["73"]);
G2L["74"]["TextWrapped"] = true;
G2L["74"]["BorderSizePixel"] = 0;
G2L["74"]["TextSize"] = 16;
G2L["74"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["74"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["74"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["74"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["74"]["BackgroundTransparency"] = 1;
G2L["74"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["74"]["Size"] = UDim2.new(0, 180, 0, 16);
G2L["74"]["Text"] = [[random toggle]];
G2L["74"]["Name"] = [[Title]];
G2L["74"]["Position"] = UDim2.new(0, 15, 0.5, 0);


G2L["75"] = Instance.new("TextButton", G2L["73"]);
G2L["75"]["BorderSizePixel"] = 0;
G2L["75"]["TextTransparency"] = 1;
G2L["75"]["TextSize"] = 14;
G2L["75"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["75"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["75"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["75"]["ZIndex"] = 5;
G2L["75"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["75"]["BackgroundTransparency"] = 1;
G2L["75"]["Size"] = UDim2.new(0.237, 0, 1, 0);
G2L["75"]["Text"] = [[]];
G2L["75"]["Name"] = [[Interact]];
G2L["75"]["Position"] = UDim2.new(0.881, 0, 0.5, 0);


G2L["76"] = Instance.new("Frame", G2L["73"]);
G2L["76"]["BorderSizePixel"] = 0;
G2L["76"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["76"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["76"]["Size"] = UDim2.new(0, 45, 0, 22);
G2L["76"]["Position"] = UDim2.new(1, -15, 0.5, 0);
G2L["76"]["Name"] = [[Switch]];


G2L["77"] = Instance.new("UICorner", G2L["76"]);
G2L["77"]["CornerRadius"] = UDim.new(0, 15);


G2L["78"] = Instance.new("Frame", G2L["76"]);
G2L["78"]["BorderSizePixel"] = 0;
G2L["78"]["BackgroundColor3"] = Color3.fromRGB(114, 114, 124);
G2L["78"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["78"]["Size"] = UDim2.new(0, 18, 0, 18);
G2L["78"]["Position"] = UDim2.new(1, -42, 0.5, 0);
G2L["78"]["Name"] = [[Indicator]];


G2L["79"] = Instance.new("UICorner", G2L["78"]);
G2L["79"]["CornerRadius"] = UDim.new(1, 0);


G2L["7a"] = Instance.new("UIStroke", G2L["78"]);
G2L["7a"]["Color"] = Color3.fromRGB(83, 83, 83);


G2L["7b"] = Instance.new("UIStroke", G2L["76"]);
G2L["7b"]["Color"] = Color3.fromRGB(71, 71, 71);


G2L["7c"] = Instance.new("UICorner", G2L["73"]);



G2L["7d"] = Instance.new("Frame", G2L["71"]);
G2L["7d"]["BorderSizePixel"] = 0;
G2L["7d"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["7d"]["Size"] = UDim2.new(1, -10, 0, 38);
G2L["7d"]["Position"] = UDim2.new(0.01, 0, 0.45, 0);
G2L["7d"]["Name"] = [[Slider]];


G2L["7e"] = Instance.new("UICorner", G2L["7d"]);



G2L["7f"] = Instance.new("TextLabel", G2L["7d"]);
G2L["7f"]["TextWrapped"] = true;
G2L["7f"]["BorderSizePixel"] = 0;
G2L["7f"]["TextSize"] = 16;
G2L["7f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["7f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7f"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["7f"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["7f"]["BackgroundTransparency"] = 1;
G2L["7f"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["7f"]["Size"] = UDim2.new(0, 200, 0, 16);
G2L["7f"]["Text"] = [[Slider]];
G2L["7f"]["Name"] = [[Title]];
G2L["7f"]["Position"] = UDim2.new(0, 15, 0.5, 0);


G2L["80"] = Instance.new("CanvasGroup", G2L["7d"]);
G2L["80"]["BorderSizePixel"] = 0;
G2L["80"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["80"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["80"]["Size"] = UDim2.new(0, 222, 0, 30);
G2L["80"]["Position"] = UDim2.new(1, -10, 0.5, 0);
G2L["80"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["80"]["Name"] = [[Main]];
G2L["80"]["BackgroundTransparency"] = 0.8;


G2L["81"] = Instance.new("UICorner", G2L["80"]);
G2L["81"]["CornerRadius"] = UDim.new(1, 0);


G2L["82"] = Instance.new("UIStroke", G2L["80"]);
G2L["82"]["Transparency"] = 0.4;
G2L["82"]["Thickness"] = 1.2;
G2L["82"]["Color"] = Color3.fromRGB(56, 56, 56);


G2L["83"] = Instance.new("TextButton", G2L["80"]);
G2L["83"]["BorderSizePixel"] = 0;
G2L["83"]["TextSize"] = 14;
G2L["83"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["83"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["83"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["83"]["ZIndex"] = 10;
G2L["83"]["BackgroundTransparency"] = 1;
G2L["83"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["83"]["BorderColor3"] = Color3.fromRGB(33, 48, 59);
G2L["83"]["Text"] = [[]];
G2L["83"]["Name"] = [[Interact]];


G2L["84"] = Instance.new("TextLabel", G2L["80"]);
G2L["84"]["TextWrapped"] = true;
G2L["84"]["ZIndex"] = 5;
G2L["84"]["BorderSizePixel"] = 0;
G2L["84"]["TextSize"] = 15;
G2L["84"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["84"]["TextTransparency"] = 0.3;
G2L["84"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["84"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["84"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["84"]["BackgroundTransparency"] = 1;
G2L["84"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["84"]["Size"] = UDim2.new(0, 168, 0, 15);
G2L["84"]["BorderColor3"] = Color3.fromRGB(33, 48, 59);
G2L["84"]["Text"] = [[750 studs]];
G2L["84"]["Name"] = [[Information]];
G2L["84"]["Position"] = UDim2.new(0.4536, 0, 0.5, 0);


G2L["85"] = Instance.new("Frame", G2L["80"]);
G2L["85"]["BorderSizePixel"] = 0;
G2L["85"]["BackgroundColor3"] = Color3.fromRGB(99, 99, 99);
G2L["85"]["Size"] = UDim2.new(0.80097, 0, 1, 0);
G2L["85"]["BorderColor3"] = Color3.fromRGB(33, 48, 59);
G2L["85"]["Name"] = [[Progress]];


G2L["86"] = Instance.new("UICorner", G2L["85"]);
G2L["86"]["CornerRadius"] = UDim.new(1, 0);


G2L["87"] = Instance.new("UIStroke", G2L["85"]);
G2L["87"]["Transparency"] = 0.3;
G2L["87"]["Thickness"] = 1.2;
G2L["87"]["Color"] = Color3.fromRGB(56, 56, 56);


G2L["88"] = Instance.new("Frame", G2L["71"]);
G2L["88"]["BorderSizePixel"] = 0;
G2L["88"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["88"]["Size"] = UDim2.new(1, 0, 0, 20);
G2L["88"]["Name"] = [[SectionTitle]];
G2L["88"]["BackgroundTransparency"] = 1;


G2L["89"] = Instance.new("TextLabel", G2L["88"]);
G2L["89"]["TextWrapped"] = true;
G2L["89"]["BorderSizePixel"] = 0;
G2L["89"]["TextSize"] = 16;
G2L["89"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["89"]["TextTransparency"] = 0.4;
G2L["89"]["TextScaled"] = true;
G2L["89"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["89"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["89"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["89"]["BackgroundTransparency"] = 1;
G2L["89"]["Size"] = UDim2.new(0.874, 0, 0, 16);
G2L["89"]["Text"] = [[random title]];
G2L["89"]["Name"] = [[Title]];
G2L["89"]["Position"] = UDim2.new(0, 10, 0.1, 0);


G2L["8a"] = Instance.new("Frame", G2L["71"]);
G2L["8a"]["BorderSizePixel"] = 0;
G2L["8a"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["8a"]["Size"] = UDim2.new(1, -10, 0, 42);
G2L["8a"]["Position"] = UDim2.new(0.01, 0, 0.669, 0);
G2L["8a"]["Name"] = [[Keybind]];


G2L["8b"] = Instance.new("UICorner", G2L["8a"]);



G2L["8c"] = Instance.new("TextLabel", G2L["8a"]);
G2L["8c"]["TextWrapped"] = true;
G2L["8c"]["BorderSizePixel"] = 0;
G2L["8c"]["TextSize"] = 16;
G2L["8c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["8c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8c"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["8c"]["BackgroundTransparency"] = 1;
G2L["8c"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["8c"]["Size"] = UDim2.new(0, 200, 0, 16);
G2L["8c"]["Text"] = [[Keybind]];
G2L["8c"]["Name"] = [[Title]];
G2L["8c"]["Position"] = UDim2.new(0, 15, 0.5, 0);


G2L["8d"] = Instance.new("Frame", G2L["8a"]);
G2L["8d"]["BorderSizePixel"] = 0;
G2L["8d"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["8d"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["8d"]["Size"] = UDim2.new(0, 40, 0, 28);
G2L["8d"]["Position"] = UDim2.new(1, -10, 0.5, 0);
G2L["8d"]["Name"] = [[KeybindFrame]];


G2L["8e"] = Instance.new("TextBox", G2L["8d"]);
G2L["8e"]["Name"] = [[KeybindBox]];
G2L["8e"]["BorderSizePixel"] = 0;
G2L["8e"]["TextSize"] = 16;
G2L["8e"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["8e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8e"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8e"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["8e"]["ClearTextOnFocus"] = false;
G2L["8e"]["PlaceholderText"] = [[Keybind]];
G2L["8e"]["Size"] = UDim2.new(1, -15, 0, 16);
G2L["8e"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["8e"]["Text"] = [[Q]];
G2L["8e"]["BackgroundTransparency"] = 1;


G2L["8f"] = Instance.new("UICorner", G2L["8d"]);



G2L["90"] = Instance.new("UIStroke", G2L["8d"]);
G2L["90"]["Color"] = Color3.fromRGB(71, 71, 71);


G2L["91"] = Instance.new("Frame", G2L["71"]);
G2L["91"]["BorderSizePixel"] = 0;
G2L["91"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["91"]["Size"] = UDim2.new(1, -10, 0, 42);
G2L["91"]["Position"] = UDim2.new(0.01, 0, 0.669, 0);
G2L["91"]["Name"] = [[Input]];


G2L["92"] = Instance.new("UICorner", G2L["91"]);



G2L["93"] = Instance.new("TextLabel", G2L["91"]);
G2L["93"]["TextWrapped"] = true;
G2L["93"]["BorderSizePixel"] = 0;
G2L["93"]["TextSize"] = 16;
G2L["93"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["93"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["93"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["93"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["93"]["BackgroundTransparency"] = 1;
G2L["93"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["93"]["Size"] = UDim2.new(0, 200, 0, 16);
G2L["93"]["Text"] = [[Input Element]];
G2L["93"]["Name"] = [[Title]];
G2L["93"]["Position"] = UDim2.new(0, 15, 0.5, 0);


G2L["94"] = Instance.new("Frame", G2L["91"]);
G2L["94"]["BorderSizePixel"] = 0;
G2L["94"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["94"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["94"]["Size"] = UDim2.new(0, 125, 0, 28);
G2L["94"]["Position"] = UDim2.new(1, -10, 0.5, 0);
G2L["94"]["Name"] = [[InputFrame]];


G2L["95"] = Instance.new("TextBox", G2L["94"]);
G2L["95"]["CursorPosition"] = -1;
G2L["95"]["Name"] = [[InputBox]];
G2L["95"]["BorderSizePixel"] = 0;
G2L["95"]["TextSize"] = 16;
G2L["95"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["95"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["95"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["95"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["95"]["ClearTextOnFocus"] = false;
G2L["95"]["PlaceholderText"] = [[Dynamic Input]];
G2L["95"]["Size"] = UDim2.new(1, -15, 0, 16);
G2L["95"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["95"]["Text"] = [[]];
G2L["95"]["BackgroundTransparency"] = 1;


G2L["96"] = Instance.new("UICorner", G2L["94"]);



G2L["97"] = Instance.new("UIStroke", G2L["94"]);
G2L["97"]["Color"] = Color3.fromRGB(71, 71, 71);


G2L["98"] = Instance.new("Frame", G2L["71"]);
G2L["98"]["BorderSizePixel"] = 0;
G2L["98"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["98"]["Size"] = UDim2.new(1, -10, 0, 125);
G2L["98"]["Position"] = UDim2.new(0.01, 0, 0.573, 0);
G2L["98"]["Name"] = [[ColorPicker]];


G2L["99"] = Instance.new("UICorner", G2L["98"]);



G2L["9a"] = Instance.new("TextButton", G2L["98"]);
G2L["9a"]["BorderSizePixel"] = 0;
G2L["9a"]["TextTransparency"] = 1;
G2L["9a"]["TextSize"] = 14;
G2L["9a"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9a"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9a"]["ZIndex"] = 5;
G2L["9a"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9a"]["BackgroundTransparency"] = 1;
G2L["9a"]["Size"] = UDim2.new(0.574, 0, 1, 0);
G2L["9a"]["Text"] = [[]];
G2L["9a"]["Name"] = [[Interact]];
G2L["9a"]["Position"] = UDim2.new(0.289, 0, 0.5, 0);


G2L["9b"] = Instance.new("Frame", G2L["98"]);
G2L["9b"]["BorderSizePixel"] = 0;
G2L["9b"]["BackgroundColor3"] = Color3.fromRGB(105, 255, 0);
G2L["9b"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["9b"]["Size"] = UDim2.new(0, 180, 0, 90);
G2L["9b"]["Position"] = UDim2.new(0, 455, 0, 15);
G2L["9b"]["Name"] = [[CPBackground]];


G2L["9c"] = Instance.new("ImageButton", G2L["9b"]);
G2L["9c"]["BorderSizePixel"] = 0;
G2L["9c"]["ImageTransparency"] = 0.1;
G2L["9c"]["BackgroundTransparency"] = 1;
G2L["9c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9c"]["ZIndex"] = 2;
G2L["9c"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9c"]["Image"] = getImageAsset("shadeGradientFlipped.png", "rbxassetid://11413591840");
G2L["9c"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["9c"]["Name"] = [[MainCP]];
G2L["9c"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


G2L["9d"] = Instance.new("UICorner", G2L["9c"]);
G2L["9d"]["CornerRadius"] = UDim.new(0, 6);


G2L["9e"] = Instance.new("ImageButton", G2L["9c"]);
G2L["9e"]["Active"] = false;
G2L["9e"]["BorderSizePixel"] = 0;
G2L["9e"]["BackgroundTransparency"] = 1;
G2L["9e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9e"]["ImageColor3"] = Color3.fromRGB(35, 79, 0);
G2L["9e"]["ZIndex"] = 3;
G2L["9e"]["Image"] = getImageAsset("DotCrosshair.png", "rbxassetid://3259050989");
G2L["9e"]["Size"] = UDim2.new(0, 60, 0, 60);
G2L["9e"]["Name"] = [[MainPoint]];
G2L["9e"]["Position"] = UDim2.new(0.183, 0, 0.249, 0);


G2L["9f"] = Instance.new("UICorner", G2L["9b"]);
G2L["9f"]["CornerRadius"] = UDim.new(0, 6);


G2L["a0"] = Instance.new("Frame", G2L["9b"]);
G2L["a0"]["BorderSizePixel"] = 0;
G2L["a0"]["BackgroundColor3"] = Color3.fromRGB(105, 255, 0);
G2L["a0"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a0"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["a0"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["a0"]["Name"] = [[Display]];


G2L["a1"] = Instance.new("UICorner", G2L["a0"]);
G2L["a1"]["CornerRadius"] = UDim.new(0, 6);


G2L["a2"] = Instance.new("Frame", G2L["a0"]);
G2L["a2"]["BorderSizePixel"] = 0;
G2L["a2"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a2"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a2"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["a2"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["a2"]["BackgroundTransparency"] = 0.75;


G2L["a3"] = Instance.new("UICorner", G2L["a2"]);
G2L["a3"]["CornerRadius"] = UDim.new(0, 6);


G2L["a4"] = Instance.new("Frame", G2L["98"]);
G2L["a4"]["ZIndex"] = 10;
G2L["a4"]["BorderSizePixel"] = 0;
G2L["a4"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["a4"]["Size"] = UDim2.new(0, 125, 0, 32);
G2L["a4"]["Position"] = UDim2.new(0, 20, 0, 75);
G2L["a4"]["Name"] = [[HexInput]];


G2L["a5"] = Instance.new("UICorner", G2L["a4"]);



G2L["a6"] = Instance.new("TextBox", G2L["a4"]);
G2L["a6"]["CursorPosition"] = -1;
G2L["a6"]["Name"] = [[InputBox]];
G2L["a6"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["a6"]["ZIndex"] = 10;
G2L["a6"]["BorderSizePixel"] = 0;
G2L["a6"]["TextSize"] = 16;
G2L["a6"]["TextColor3"] = Color3.fromRGB(214, 214, 224);
G2L["a6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a6"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["a6"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a6"]["ClearTextOnFocus"] = false;
G2L["a6"]["PlaceholderText"] = [[hex]];
G2L["a6"]["Size"] = UDim2.new(0.98, -15, 0, 16);
G2L["a6"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["a6"]["Text"] = [[]];
G2L["a6"]["BackgroundTransparency"] = 1;


G2L["a7"] = Instance.new("UIStroke", G2L["a4"]);
G2L["a7"]["Color"] = Color3.fromRGB(71, 71, 71);


G2L["a8"] = Instance.new("ImageButton", G2L["98"]);
G2L["a8"]["BorderSizePixel"] = 0;
G2L["a8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a8"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["a8"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
G2L["a8"]["Size"] = UDim2.new(0, 180, 0, 14);
G2L["a8"]["ClipsDescendants"] = true;
G2L["a8"]["Name"] = [[ColorSlider]];
G2L["a8"]["Position"] = UDim2.new(0, 455, 0, 105);


G2L["a9"] = Instance.new("UIGradient", G2L["a8"]);
G2L["a9"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),ColorSequenceKeypoint.new(0.060, Color3.fromRGB(255, 92, 0)),ColorSequenceKeypoint.new(0.110, Color3.fromRGB(255, 177, 0)),ColorSequenceKeypoint.new(0.170, Color3.fromRGB(255, 255, 0)),ColorSequenceKeypoint.new(0.220, Color3.fromRGB(176, 255, 0)),ColorSequenceKeypoint.new(0.280, Color3.fromRGB(90, 255, 0)),ColorSequenceKeypoint.new(0.330, Color3.fromRGB(0, 255, 8)),ColorSequenceKeypoint.new(0.390, Color3.fromRGB(0, 255, 93)),ColorSequenceKeypoint.new(0.450, Color3.fromRGB(0, 255, 178)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),ColorSequenceKeypoint.new(0.560, Color3.fromRGB(0, 174, 255)),ColorSequenceKeypoint.new(0.610, Color3.fromRGB(0, 89, 255)),ColorSequenceKeypoint.new(0.670, Color3.fromRGB(9, 0, 255)),ColorSequenceKeypoint.new(0.720, Color3.fromRGB(95, 0, 255)),ColorSequenceKeypoint.new(0.780, Color3.fromRGB(180, 0, 255)),ColorSequenceKeypoint.new(0.840, Color3.fromRGB(255, 0, 255)),ColorSequenceKeypoint.new(0.890, Color3.fromRGB(255, 0, 173)),ColorSequenceKeypoint.new(0.950, Color3.fromRGB(255, 0, 87)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))};


G2L["aa"] = Instance.new("ImageButton", G2L["a8"]);
G2L["aa"]["Active"] = false;
G2L["aa"]["BorderSizePixel"] = 0;
G2L["aa"]["BackgroundTransparency"] = 1;
G2L["aa"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["aa"]["ImageColor3"] = Color3.fromRGB(0, 255, 0);
G2L["aa"]["ZIndex"] = 2;
G2L["aa"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["aa"]["Image"] = getImageAsset("DotCrosshair.png", "rbxassetid://3259050989");
G2L["aa"]["Size"] = UDim2.new(0, 60, 0, 60);
G2L["aa"]["Name"] = [[SliderPoint]];
G2L["aa"]["Position"] = UDim2.new(0.182, 0, 0.5, 0);


G2L["ab"] = Instance.new("TextLabel", G2L["a8"]);
G2L["ab"]["BorderSizePixel"] = 0;
G2L["ab"]["TextSize"] = 14;
G2L["ab"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["ab"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ab"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["ab"]["BackgroundTransparency"] = 0.8;
G2L["ab"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["ab"]["Text"] = [[]];
G2L["ab"]["Name"] = [[TintAdder]];


G2L["ac"] = Instance.new("UICorner", G2L["ab"]);
G2L["ac"]["CornerRadius"] = UDim.new(0, 6);


G2L["ad"] = Instance.new("UICorner", G2L["a8"]);
G2L["ad"]["CornerRadius"] = UDim.new(0, 6);


G2L["ae"] = Instance.new("TextLabel", G2L["98"]);
G2L["ae"]["TextWrapped"] = true;
G2L["ae"]["ZIndex"] = 3;
G2L["ae"]["BorderSizePixel"] = 0;
G2L["ae"]["TextSize"] = 16;
G2L["ae"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["ae"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ae"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ae"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["ae"]["BackgroundTransparency"] = 1;
G2L["ae"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ae"]["Size"] = UDim2.new(0, 240, 0, 16);
G2L["ae"]["Text"] = [[Color Picker]];
G2L["ae"]["Name"] = [[Title]];
G2L["ae"]["Position"] = UDim2.new(0, 140, 0, 25);


G2L["af"] = Instance.new("Frame", G2L["98"]);
G2L["af"]["BorderSizePixel"] = 0;
G2L["af"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["af"]["Size"] = UDim2.new(0, 240, 0, 30);
G2L["af"]["Position"] = UDim2.new(0, 20, 0, 45);
G2L["af"]["Name"] = [[RGB]];
G2L["af"]["BackgroundTransparency"] = 1;


G2L["b0"] = Instance.new("UIListLayout", G2L["af"]);
G2L["b0"]["Padding"] = UDim.new(0, 8);
G2L["b0"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
G2L["b0"]["FillDirection"] = Enum.FillDirection.Horizontal;


G2L["b1"] = Instance.new("Frame", G2L["af"]);
G2L["b1"]["ZIndex"] = 10;
G2L["b1"]["BorderSizePixel"] = 0;
G2L["b1"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["b1"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b1"]["Size"] = UDim2.new(0, 56, 0, 28);
G2L["b1"]["Position"] = UDim2.new(0.36, -7, 0.5, 0);
G2L["b1"]["Name"] = [[GInput]];
G2L["b1"]["LayoutOrder"] = 1;


G2L["b2"] = Instance.new("UICorner", G2L["b1"]);



G2L["b3"] = Instance.new("TextBox", G2L["b1"]);
G2L["b3"]["Name"] = [[InputBox]];
G2L["b3"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["b3"]["ZIndex"] = 10;
G2L["b3"]["BorderSizePixel"] = 0;
G2L["b3"]["TextSize"] = 14;
G2L["b3"]["TextColor3"] = Color3.fromRGB(214, 214, 224);
G2L["b3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b3"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["b3"]["ClearTextOnFocus"] = false;
G2L["b3"]["PlaceholderText"] = [[G]];
G2L["b3"]["Size"] = UDim2.new(0.874, -15, 0, 16);
G2L["b3"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["b3"]["Text"] = [[]];
G2L["b3"]["BackgroundTransparency"] = 1;


G2L["b4"] = Instance.new("UIStroke", G2L["b1"]);
G2L["b4"]["Color"] = Color3.fromRGB(71, 71, 71);


G2L["b5"] = Instance.new("Frame", G2L["af"]);
G2L["b5"]["ZIndex"] = 10;
G2L["b5"]["BorderSizePixel"] = 0;
G2L["b5"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["b5"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b5"]["Size"] = UDim2.new(0, 56, 0, 28);
G2L["b5"]["Position"] = UDim2.new(0.182, -5, 0.5, 0);
G2L["b5"]["Name"] = [[RInput]];


G2L["b6"] = Instance.new("UICorner", G2L["b5"]);



G2L["b7"] = Instance.new("TextBox", G2L["b5"]);
G2L["b7"]["Name"] = [[InputBox]];
G2L["b7"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["b7"]["ZIndex"] = 10;
G2L["b7"]["BorderSizePixel"] = 0;
G2L["b7"]["TextSize"] = 14;
G2L["b7"]["TextColor3"] = Color3.fromRGB(214, 214, 224);
G2L["b7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b7"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b7"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["b7"]["ClearTextOnFocus"] = false;
G2L["b7"]["PlaceholderText"] = [[R]];
G2L["b7"]["Size"] = UDim2.new(0.874, -15, 0, 16);
G2L["b7"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["b7"]["Text"] = [[]];
G2L["b7"]["BackgroundTransparency"] = 1;


G2L["b8"] = Instance.new("UIStroke", G2L["b5"]);
G2L["b8"]["Color"] = Color3.fromRGB(71, 71, 71);


G2L["b9"] = Instance.new("Frame", G2L["af"]);
G2L["b9"]["ZIndex"] = 10;
G2L["b9"]["BorderSizePixel"] = 0;
G2L["b9"]["BackgroundColor3"] = Color3.fromRGB(49, 49, 54);
G2L["b9"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b9"]["Size"] = UDim2.new(0, 56, 0, 28);
G2L["b9"]["Position"] = UDim2.new(0.928, -5, 0.465, 0);
G2L["b9"]["Name"] = [[BInput]];
G2L["b9"]["LayoutOrder"] = 2;


G2L["ba"] = Instance.new("UICorner", G2L["b9"]);



G2L["bb"] = Instance.new("TextBox", G2L["b9"]);
G2L["bb"]["Name"] = [[InputBox]];
G2L["bb"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["bb"]["ZIndex"] = 10;
G2L["bb"]["BorderSizePixel"] = 0;
G2L["bb"]["TextSize"] = 14;
G2L["bb"]["TextColor3"] = Color3.fromRGB(214, 214, 224);
G2L["bb"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["bb"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["bb"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["bb"]["ClearTextOnFocus"] = false;
G2L["bb"]["PlaceholderText"] = [[B]];
G2L["bb"]["Size"] = UDim2.new(0.874, -15, 0, 16);
G2L["bb"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["bb"]["Text"] = [[]];
G2L["bb"]["BackgroundTransparency"] = 1;


G2L["bc"] = Instance.new("UIStroke", G2L["b9"]);
G2L["bc"]["Color"] = Color3.fromRGB(71, 71, 71);


G2L["bd"] = Instance.new("Frame", G2L["71"]);
G2L["bd"]["BorderSizePixel"] = 0;
G2L["bd"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["bd"]["Size"] = UDim2.new(1, -10, 0, 38);
G2L["bd"]["Name"] = [[Button]];


G2L["be"] = Instance.new("UICorner", G2L["bd"]);



G2L["bf"] = Instance.new("TextLabel", G2L["bd"]);
G2L["bf"]["TextWrapped"] = true;
G2L["bf"]["BorderSizePixel"] = 0;
G2L["bf"]["TextSize"] = 16;
G2L["bf"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["bf"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["bf"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["bf"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["bf"]["BackgroundTransparency"] = 1;
G2L["bf"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["bf"]["Size"] = UDim2.new(0, 190, 0, 16);
G2L["bf"]["Text"] = [[Button Name]];
G2L["bf"]["Name"] = [[Title]];
G2L["bf"]["Position"] = UDim2.new(0, 15, 0.5, 0);


G2L["c0"] = Instance.new("TextButton", G2L["bd"]);
G2L["c0"]["BorderSizePixel"] = 0;
G2L["c0"]["TextTransparency"] = 1;
G2L["c0"]["TextSize"] = 14;
G2L["c0"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["c0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c0"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c0"]["ZIndex"] = 5;
G2L["c0"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["c0"]["BackgroundTransparency"] = 1;
G2L["c0"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["c0"]["Text"] = [[]];
G2L["c0"]["Name"] = [[Interact]];
G2L["c0"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


G2L["c1"] = Instance.new("TextLabel", G2L["bd"]);
G2L["c1"]["TextWrapped"] = true;
G2L["c1"]["BorderSizePixel"] = 0;
G2L["c1"]["TextSize"] = 14;
G2L["c1"]["TextXAlignment"] = Enum.TextXAlignment.Right;
G2L["c1"]["TextTransparency"] = 0.8;
G2L["c1"]["TextScaled"] = true;
G2L["c1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c1"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c1"]["TextColor3"] = Color3.fromRGB(244, 244, 249);
G2L["c1"]["BackgroundTransparency"] = 1;
G2L["c1"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c1"]["Size"] = UDim2.new(0, 110, 0, 14);
G2L["c1"]["Text"] = [[button]];
G2L["c1"]["Name"] = [[ElementIndicator]];
G2L["c1"]["Position"] = UDim2.new(1, -15, 0.5, 0);


G2L["c2"] = Instance.new("UICorner", G2L["70"]);



G2L["c3"] = Instance.new("UIGradient", G2L["70"]);
G2L["c3"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["c4"] = Instance.new("Frame", G2L["6f"]);
G2L["c4"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["c4"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["c4"]["Name"] = [[Topbar]];
G2L["c4"]["BackgroundTransparency"] = 0.2;


G2L["c5"] = Instance.new("TextButton", G2L["c4"]);
G2L["c5"]["BorderSizePixel"] = 0;
G2L["c5"]["TextSize"] = 16;
G2L["c5"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["c5"]["BackgroundColor3"] = Color3.fromRGB(184, 54, 54);
G2L["c5"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c5"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c5"]["BackgroundTransparency"] = 0.3;
G2L["c5"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["c5"]["Text"] = [[×]];
G2L["c5"]["Name"] = [[Exit]];
G2L["c5"]["Position"] = UDim2.new(1, -10, 0.5, 0);


G2L["c6"] = Instance.new("UICorner", G2L["c5"]);
G2L["c6"]["CornerRadius"] = UDim.new(0, 6);


G2L["c7"] = Instance.new("UIStroke", G2L["c5"]);
G2L["c7"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c7"]["Name"] = [[UIStroker]];
G2L["c7"]["Thickness"] = 2;
G2L["c7"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["c8"] = Instance.new("TextButton", G2L["c4"]);
G2L["c8"]["BorderSizePixel"] = 0;
G2L["c8"]["TextSize"] = 16;
G2L["c8"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["c8"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["c8"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c8"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c8"]["BackgroundTransparency"] = 0.3;
G2L["c8"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["c8"]["Text"] = [[−]];
G2L["c8"]["Name"] = [[Minimize]];
G2L["c8"]["Position"] = UDim2.new(1, -40, 0.5, 0);


G2L["c9"] = Instance.new("UICorner", G2L["c8"]);
G2L["c9"]["CornerRadius"] = UDim.new(0, 6);


G2L["ca"] = Instance.new("UIStroke", G2L["c8"]);
G2L["ca"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["ca"]["Name"] = [[UIStroker]];
G2L["ca"]["Thickness"] = 2;
G2L["ca"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["cb"] = Instance.new("TextLabel", G2L["c4"]);
G2L["cb"]["TextWrapped"] = true;
G2L["cb"]["BorderSizePixel"] = 0;
G2L["cb"]["TextSize"] = 18;
G2L["cb"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["cb"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["cb"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["cb"]["BackgroundTransparency"] = 1;
G2L["cb"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["cb"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["cb"]["Text"] = [[Settings]];
G2L["cb"]["Name"] = [[Title]];
G2L["cb"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


G2L["cc"] = Instance.new("UICorner", G2L["c4"]);
G2L["cc"]["CornerRadius"] = UDim.new(0, 10);


G2L["cd"] = Instance.new("UIStroke", G2L["c4"]);
G2L["cd"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["cd"]["Name"] = [[UIStroker]];
G2L["cd"]["Thickness"] = 2;
G2L["cd"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["ce"] = Instance.new("UICorner", G2L["6f"]);
G2L["ce"]["CornerRadius"] = UDim.new(0, 10);


G2L["cf"] = Instance.new("UIGradient", G2L["6f"]);
G2L["cf"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(34, 34, 39)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 29, 34))};


G2L["d0"] = Instance.new("UIStroke", G2L["6f"]);
G2L["d0"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["d0"]["Name"] = [[UIStroker]];
G2L["d0"]["Thickness"] = 2;
G2L["d0"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["d1"] = Instance.new("Frame", G2L["1"]);
G2L["d1"]["BorderSizePixel"] = 0;
G2L["d1"]["BackgroundColor3"] = Color3.fromRGB(33, 33, 37);
G2L["d1"]["Size"] = UDim2.new(0, 420, 0, 280);
G2L["d1"]["Position"] = UDim2.new(0.45487, -210, 0.0086, 0);
G2L["d1"]["Name"] = [[SuchWaypoint]];
G2L["d1"]["BackgroundTransparency"] = 0.1;


G2L["d2"] = Instance.new("UICorner", G2L["d1"]);
G2L["d2"]["CornerRadius"] = UDim.new(0, 10);


G2L["d3"] = Instance.new("UIGradient", G2L["d1"]);
G2L["d3"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(35, 35, 40)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(30, 30, 35))};


G2L["d4"] = Instance.new("UIStroke", G2L["d1"]);
G2L["d4"]["Thickness"] = 2;
G2L["d4"]["Color"] = Color3.fromRGB(155, 100, 255);


G2L["d5"] = Instance.new("Frame", G2L["d1"]);
G2L["d5"]["BackgroundColor3"] = Color3.fromRGB(40, 40, 45);
G2L["d5"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["d5"]["Name"] = [[Topbar]];
G2L["d5"]["BackgroundTransparency"] = 0.2;


G2L["d6"] = Instance.new("UICorner", G2L["d5"]);
G2L["d6"]["CornerRadius"] = UDim.new(0, 10);


G2L["d7"] = Instance.new("UIStroke", G2L["d5"]);
G2L["d7"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["d7"]["Thickness"] = 2;
G2L["d7"]["Color"] = Color3.fromRGB(155, 100, 255);


G2L["d8"] = Instance.new("TextButton", G2L["d5"]);
G2L["d8"]["BorderSizePixel"] = 0;
G2L["d8"]["TextSize"] = 16;
G2L["d8"]["TextColor3"] = Color3.fromRGB(245, 245, 245);
G2L["d8"]["BackgroundColor3"] = Color3.fromRGB(185, 55, 55);
G2L["d8"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d8"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["d8"]["BackgroundTransparency"] = 0.3;
G2L["d8"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["d8"]["Text"] = [[×]];
G2L["d8"]["Name"] = [[Exit]];
G2L["d8"]["Position"] = UDim2.new(1, -10, 0.5, 0);


G2L["d9"] = Instance.new("UICorner", G2L["d8"]);
G2L["d9"]["CornerRadius"] = UDim.new(0, 6);


G2L["da"] = Instance.new("UIStroke", G2L["d8"]);
G2L["da"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["da"]["Thickness"] = 2;
G2L["da"]["Color"] = Color3.fromRGB(155, 100, 255);


G2L["db"] = Instance.new("TextButton", G2L["d5"]);
G2L["db"]["BorderSizePixel"] = 0;
G2L["db"]["TextSize"] = 16;
G2L["db"]["TextColor3"] = Color3.fromRGB(245, 245, 245);
G2L["db"]["BackgroundColor3"] = Color3.fromRGB(55, 55, 65);
G2L["db"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["db"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["db"]["BackgroundTransparency"] = 0.3;
G2L["db"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["db"]["Text"] = [[−]];
G2L["db"]["Name"] = [[Minimize]];
G2L["db"]["Position"] = UDim2.new(1, -40, 0.5, 0);


G2L["dc"] = Instance.new("UICorner", G2L["db"]);
G2L["dc"]["CornerRadius"] = UDim.new(0, 6);


G2L["dd"] = Instance.new("UIStroke", G2L["db"]);
G2L["dd"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["dd"]["Thickness"] = 2;
G2L["dd"]["Color"] = Color3.fromRGB(155, 100, 255);


G2L["de"] = Instance.new("TextLabel", G2L["d5"]);
G2L["de"]["TextWrapped"] = true;
G2L["de"]["BorderSizePixel"] = 0;
G2L["de"]["TextSize"] = 18;
G2L["de"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["de"]["TextColor3"] = Color3.fromRGB(235, 235, 245);
G2L["de"]["BackgroundTransparency"] = 1;
G2L["de"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["de"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["de"]["Text"] = [[NA Waypoints]];
G2L["de"]["Name"] = [[Title]];
G2L["de"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


G2L["df"] = Instance.new("Frame", G2L["d1"]);
G2L["df"]["BorderSizePixel"] = 0;
G2L["df"]["BackgroundColor3"] = Color3.fromRGB(40, 40, 45);
G2L["df"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["df"]["ClipsDescendants"] = true;
G2L["df"]["Size"] = UDim2.new(1, -15, 1, -45);
G2L["df"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["df"]["Name"] = [[Container]];
G2L["df"]["BackgroundTransparency"] = 0.3;


G2L["e0"] = Instance.new("UICorner", G2L["df"]);
G2L["e0"]["CornerRadius"] = UDim.new(0, 6);


G2L["e1"] = Instance.new("UIGradient", G2L["df"]);
G2L["e1"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 50)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(35, 35, 40))};


G2L["e2"] = Instance.new("TextBox", G2L["df"]);
G2L["e2"]["CursorPosition"] = -1;
G2L["e2"]["Name"] = [[Filter]];
G2L["e2"]["PlaceholderColor3"] = Color3.fromRGB(155, 155, 165);
G2L["e2"]["BorderSizePixel"] = 0;
G2L["e2"]["TextSize"] = 16;
G2L["e2"]["TextColor3"] = Color3.fromRGB(235, 235, 245);
G2L["e2"]["BackgroundColor3"] = Color3.fromRGB(45, 45, 50);
G2L["e2"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["e2"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["e2"]["PlaceholderText"] = [[Search...]];
G2L["e2"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["e2"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["e2"]["Text"] = [[]];
G2L["e2"]["BackgroundTransparency"] = 0.5;


G2L["e3"] = Instance.new("UICorner", G2L["e2"]);
G2L["e3"]["CornerRadius"] = UDim.new(0, 6);


G2L["e4"] = Instance.new("UIStroke", G2L["e2"]);
G2L["e4"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["e4"]["Thickness"] = 2;
G2L["e4"]["Color"] = Color3.fromRGB(155, 100, 255);


G2L["e5"] = Instance.new("ScrollingFrame", G2L["df"]);
G2L["e5"]["BorderSizePixel"] = 0;
G2L["e5"]["Name"] = [[List]];
G2L["e5"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["e5"]["Size"] = UDim2.new(1, -10, 0.9, -35);
G2L["e5"]["ScrollBarImageColor3"] = Color3.fromRGB(105, 105, 115);
G2L["e5"]["Position"] = UDim2.new(0.5, 0, 0.62, 0);
G2L["e5"]["ScrollBarThickness"] = 3;
G2L["e5"]["BackgroundTransparency"] = 1;


G2L["e6"] = Instance.new("UIListLayout", G2L["e5"]);
G2L["e6"]["Padding"] = UDim.new(0, 5);
G2L["e6"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


G2L["e7"] = Instance.new("Frame", G2L["e5"]);
G2L["e7"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 49);
G2L["e7"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["e7"]["Position"] = UDim2.new(0, 2, 0, 0);
G2L["e7"]["Name"] = [[WP]];


G2L["e8"] = Instance.new("UICorner", G2L["e7"]);
G2L["e8"]["CornerRadius"] = UDim.new(0, 6);


G2L["e9"] = Instance.new("TextButton", G2L["e7"]);
G2L["e9"]["TextWrapped"] = true;
G2L["e9"]["TextTruncate"] = Enum.TextTruncate.AtEnd;
G2L["e9"]["TextScaled"] = true;
G2L["e9"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["e9"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["e9"]["BackgroundTransparency"] = 1;
G2L["e9"]["Size"] = UDim2.new(0.63921, 0, 1, 0);
G2L["e9"]["Text"] = [[Loading Waypoint...]];
G2L["e9"]["Name"] = [[WP_Name]];


G2L["ea"] = Instance.new("Frame", G2L["e7"]);
G2L["ea"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["ea"]["Size"] = UDim2.new(0, 133, 0, 24);
G2L["ea"]["Position"] = UDim2.new(1, -8, 0.5, 0);
G2L["ea"]["Name"] = [[ButtonsHolder]];
G2L["ea"]["BackgroundTransparency"] = 1;


G2L["eb"] = Instance.new("UIListLayout", G2L["ea"]);
G2L["eb"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Right;
G2L["eb"]["Padding"] = UDim.new(0, 6);
G2L["eb"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
G2L["eb"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
G2L["eb"]["FillDirection"] = Enum.FillDirection.Horizontal;


G2L["ec"] = Instance.new("TextButton", G2L["ea"]);
G2L["ec"]["TextWrapped"] = true;
G2L["ec"]["TextScaled"] = true;
G2L["ec"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ec"]["BackgroundColor3"] = Color3.fromRGB(88, 173, 0);
G2L["ec"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["ec"]["Size"] = UDim2.new(0, 40, 1, 0);
G2L["ec"]["LayoutOrder"] = 1;
G2L["ec"]["Text"] = [[TP]];
G2L["ec"]["Name"] = [[TPBtn]];


G2L["ed"] = Instance.new("UICorner", G2L["ec"]);
G2L["ed"]["CornerRadius"] = UDim.new(0, 4);


G2L["ee"] = Instance.new("TextButton", G2L["ea"]);
G2L["ee"]["TextWrapped"] = true;
G2L["ee"]["TextScaled"] = true;
G2L["ee"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ee"]["BackgroundColor3"] = Color3.fromRGB(0, 124, 206);
G2L["ee"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["ee"]["Size"] = UDim2.new(0, 40, 1, 0);
G2L["ee"]["LayoutOrder"] = 2;
G2L["ee"]["Text"] = [[Copy]];
G2L["ee"]["Name"] = [[CopyBtn]];


G2L["ef"] = Instance.new("UICorner", G2L["ee"]);
G2L["ef"]["CornerRadius"] = UDim.new(0, 4);


G2L["f0"] = Instance.new("TextButton", G2L["ea"]);
G2L["f0"]["TextWrapped"] = true;
G2L["f0"]["TextScaled"] = true;
G2L["f0"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["f0"]["BackgroundColor3"] = Color3.fromRGB(255, 0, 0);
G2L["f0"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["f0"]["Size"] = UDim2.new(0, 40, 1, 0);
G2L["f0"]["LayoutOrder"] = 3;
G2L["f0"]["Text"] = [[Del]];
G2L["f0"]["Name"] = [[DelBtn]];


G2L["f1"] = Instance.new("UICorner", G2L["f0"]);
G2L["f1"]["CornerRadius"] = UDim.new(0, 4);


G2L["f2"] = Instance.new("Frame", G2L["1"]);
G2L["f2"]["BorderSizePixel"] = 0;
G2L["f2"]["BackgroundColor3"] = Color3.fromRGB(29, 29, 34);
G2L["f2"]["Size"] = UDim2.new(0, 420, 0, 280);
G2L["f2"]["Position"] = UDim2.new(0.02568, 0, 0.50937, 0);
G2L["f2"]["Name"] = [[binders]];
G2L["f2"]["BackgroundTransparency"] = 0.1;


G2L["f3"] = Instance.new("Frame", G2L["f2"]);
G2L["f3"]["BorderSizePixel"] = 0;
G2L["f3"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["f3"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["f3"]["ClipsDescendants"] = true;
G2L["f3"]["Size"] = UDim2.new(1, -15, 1, -40);
G2L["f3"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["f3"]["Name"] = [[Container]];
G2L["f3"]["BackgroundTransparency"] = 0.3;


G2L["f4"] = Instance.new("ScrollingFrame", G2L["f3"]);
G2L["f4"]["BorderSizePixel"] = 0;
G2L["f4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["f4"]["Name"] = [[List]];
G2L["f4"]["Size"] = UDim2.new(1, -10, 1, -10);
G2L["f4"]["ScrollBarImageColor3"] = Color3.fromRGB(104, 104, 114);
G2L["f4"]["Position"] = UDim2.new(0, 5, 0, 5);
G2L["f4"]["ScrollBarThickness"] = 3;
G2L["f4"]["BackgroundTransparency"] = 1;


G2L["f5"] = Instance.new("UIListLayout", G2L["f4"]);
G2L["f5"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["f5"]["Padding"] = UDim.new(0, 5);
G2L["f5"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


G2L["f6"] = Instance.new("UICorner", G2L["f3"]);



G2L["f7"] = Instance.new("UIGradient", G2L["f3"]);
G2L["f7"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(44, 44, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(34, 34, 39))};


G2L["f8"] = Instance.new("Frame", G2L["f2"]);
G2L["f8"]["BackgroundColor3"] = Color3.fromRGB(39, 39, 44);
G2L["f8"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["f8"]["Name"] = [[Topbar]];
G2L["f8"]["BackgroundTransparency"] = 0.2;


G2L["f9"] = Instance.new("TextButton", G2L["f8"]);
G2L["f9"]["BorderSizePixel"] = 0;
G2L["f9"]["TextSize"] = 16;
G2L["f9"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["f9"]["BackgroundColor3"] = Color3.fromRGB(184, 54, 54);
G2L["f9"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f9"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["f9"]["BackgroundTransparency"] = 0.3;
G2L["f9"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["f9"]["Text"] = [[×]];
G2L["f9"]["Name"] = [[Exit]];
G2L["f9"]["Position"] = UDim2.new(1, -10, 0.5, 0);


G2L["fa"] = Instance.new("UICorner", G2L["f9"]);
G2L["fa"]["CornerRadius"] = UDim.new(0, 6);


G2L["fb"] = Instance.new("UIStroke", G2L["f9"]);
G2L["fb"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["fb"]["Name"] = [[UIStroker]];
G2L["fb"]["Thickness"] = 2;
G2L["fb"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["fc"] = Instance.new("TextButton", G2L["f8"]);
G2L["fc"]["BorderSizePixel"] = 0;
G2L["fc"]["TextSize"] = 16;
G2L["fc"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["fc"]["BackgroundColor3"] = Color3.fromRGB(54, 54, 64);
G2L["fc"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["fc"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["fc"]["BackgroundTransparency"] = 0.3;
G2L["fc"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["fc"]["Text"] = [[−]];
G2L["fc"]["Name"] = [[Minimize]];
G2L["fc"]["Position"] = UDim2.new(1, -40, 0.5, 0);


G2L["fd"] = Instance.new("UICorner", G2L["fc"]);
G2L["fd"]["CornerRadius"] = UDim.new(0, 6);


G2L["fe"] = Instance.new("UIStroke", G2L["fc"]);
G2L["fe"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["fe"]["Name"] = [[UIStroker]];
G2L["fe"]["Thickness"] = 2;
G2L["fe"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["ff"] = Instance.new("TextLabel", G2L["f8"]);
G2L["ff"]["TextWrapped"] = true;
G2L["ff"]["BorderSizePixel"] = 0;
G2L["ff"]["TextSize"] = 18;
G2L["ff"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ff"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ff"]["TextColor3"] = Color3.fromRGB(234, 234, 244);
G2L["ff"]["BackgroundTransparency"] = 1;
G2L["ff"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ff"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["ff"]["Text"] = [[Event Binding]];
G2L["ff"]["Name"] = [[Title]];
G2L["ff"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


G2L["100"] = Instance.new("UICorner", G2L["f8"]);
G2L["100"]["CornerRadius"] = UDim.new(0, 10);


G2L["101"] = Instance.new("UIStroke", G2L["f8"]);
G2L["101"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["101"]["Name"] = [[UIStroker]];
G2L["101"]["Thickness"] = 2;
G2L["101"]["Color"] = Color3.fromRGB(154, 99, 255);


G2L["102"] = Instance.new("UICorner", G2L["f2"]);
G2L["102"]["CornerRadius"] = UDim.new(0, 10);


G2L["103"] = Instance.new("UIGradient", G2L["f2"]);
G2L["103"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(34, 34, 39)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 29, 34))};


G2L["104"] = Instance.new("UIStroke", G2L["f2"]);
G2L["104"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["104"]["Name"] = [[UIStroker]];
G2L["104"]["Thickness"] = 2;
G2L["104"]["Color"] = Color3.fromRGB(154, 99, 255);

return G2L["1"];