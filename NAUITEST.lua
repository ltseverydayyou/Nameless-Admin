local G2L = {};

-- StarterGui.AdminUI
G2L["1"] = Instance.new("ScreenGui");
G2L["1"]["Name"] = [[AdminUI]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;


-- StarterGui.AdminUI.ChatLogs
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(21, 21, 26);
G2L["2"]["Size"] = UDim2.new(0, 450, 0, 300);
G2L["2"]["Position"] = UDim2.new(0.60447, 0, 0.5914, 0);
G2L["2"]["Name"] = [[ChatLogs]];
G2L["2"]["BackgroundTransparency"] = 0.05;


-- StarterGui.AdminUI.ChatLogs.Container
G2L["3"] = Instance.new("Frame", G2L["2"]);
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 36);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["ClipsDescendants"] = true;
G2L["3"]["Size"] = UDim2.new(1, -15, 0.96667, -30);
G2L["3"]["Position"] = UDim2.new(0.5, 0, 0.51667, 15);
G2L["3"]["Name"] = [[Container]];
G2L["3"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Container.Logs
G2L["4"] = Instance.new("ScrollingFrame", G2L["3"]);
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4"]["Name"] = [[Logs]];
G2L["4"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4"]["Size"] = UDim2.new(1, -15, 1, -15);
G2L["4"]["ScrollBarImageColor3"] = Color3.fromRGB(121, 121, 131);
G2L["4"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["4"]["ScrollBarThickness"] = 2;
G2L["4"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.UIListLayout
G2L["5"] = Instance.new("UIListLayout", G2L["4"]);
G2L["5"]["Padding"] = UDim.new(0, 8);
G2L["5"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.TextLabel
G2L["6"] = Instance.new("TextLabel", G2L["4"]);
G2L["6"]["TextWrapped"] = true;
G2L["6"]["TextSize"] = 16;
G2L["6"]["TextScaled"] = true;
G2L["6"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["6"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["6"]["TextColor3"] = Color3.fromRGB(221, 221, 231);
G2L["6"]["BackgroundTransparency"] = 0.4;
G2L["6"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["6"]["Text"] = [[[Roblox]: Hello, World!]];


-- StarterGui.AdminUI.ChatLogs.Container.Logs.TextLabel.UICorner
G2L["7"] = Instance.new("UICorner", G2L["6"]);
G2L["7"]["CornerRadius"] = UDim.new(0, 4);


-- StarterGui.AdminUI.ChatLogs.Topbar
G2L["8"] = Instance.new("Frame", G2L["2"]);
G2L["8"]["BorderSizePixel"] = 0;
G2L["8"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["8"]["Size"] = UDim2.new(1, 0, 0, 40);
G2L["8"]["Name"] = [[Topbar]];
G2L["8"]["BackgroundTransparency"] = 0.1;


-- StarterGui.AdminUI.ChatLogs.Topbar.Title
G2L["9"] = Instance.new("TextLabel", G2L["8"]);
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["TextSize"] = 20;
G2L["9"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9"]["TextColor3"] = Color3.fromRGB(241, 241, 251);
G2L["9"]["BackgroundTransparency"] = 1;
G2L["9"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["9"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["9"]["Text"] = [[Chat Logs]];
G2L["9"]["Name"] = [[Title]];
G2L["9"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.UIGradient
G2L["a"] = Instance.new("UIGradient", G2L["8"]);
G2L["a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 46)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(31, 31, 36))};


-- StarterGui.AdminUI.ChatLogs.Topbar.UICorner
G2L["b"] = Instance.new("UICorner", G2L["8"]);
G2L["b"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear
G2L["c"] = Instance.new("TextButton", G2L["8"]);
G2L["c"]["BorderSizePixel"] = 0;
G2L["c"]["TextSize"] = 14;
G2L["c"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["c"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c"]["BackgroundTransparency"] = 0.2;
G2L["c"]["Size"] = UDim2.new(0, 60, 0, 26);
G2L["c"]["Text"] = [[Clear]];
G2L["c"]["Name"] = [[Clear]];
G2L["c"]["Position"] = UDim2.new(0.98222, -70, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UICorner
G2L["d"] = Instance.new("UICorner", G2L["c"]);
G2L["d"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UIStroke
G2L["e"] = Instance.new("UIStroke", G2L["c"]);
G2L["e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["e"]["Thickness"] = 2;
G2L["e"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit
G2L["f"] = Instance.new("TextButton", G2L["8"]);
G2L["f"]["BorderSizePixel"] = 0;
G2L["f"]["TextSize"] = 16;
G2L["f"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["f"]["BackgroundColor3"] = Color3.fromRGB(181, 51, 51);
G2L["f"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["f"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["f"]["BackgroundTransparency"] = 0.2;
G2L["f"]["Size"] = UDim2.new(0, 26, 0, 26);
G2L["f"]["Text"] = [[×]];
G2L["f"]["Name"] = [[Exit]];
G2L["f"]["Position"] = UDim2.new(0.98222, 0, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UICorner
G2L["10"] = Instance.new("UICorner", G2L["f"]);
G2L["10"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UIStroke
G2L["11"] = Instance.new("UIStroke", G2L["f"]);
G2L["11"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["11"]["Thickness"] = 2;
G2L["11"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize
G2L["12"] = Instance.new("TextButton", G2L["8"]);
G2L["12"]["BorderSizePixel"] = 0;
G2L["12"]["TextSize"] = 16;
G2L["12"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["12"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["12"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["12"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["12"]["BackgroundTransparency"] = 0.2;
G2L["12"]["Size"] = UDim2.new(0, 26, 0, 26);
G2L["12"]["Text"] = [[−]];
G2L["12"]["Name"] = [[Minimize]];
G2L["12"]["Position"] = UDim2.new(0.98222, -35, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UICorner
G2L["13"] = Instance.new("UICorner", G2L["12"]);
G2L["13"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UIStroke
G2L["14"] = Instance.new("UIStroke", G2L["12"]);
G2L["14"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["14"]["Thickness"] = 2;
G2L["14"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.UIStroke
G2L["15"] = Instance.new("UIStroke", G2L["8"]);
G2L["15"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["15"]["Thickness"] = 2;
G2L["15"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.ChatLogs.UICorner
G2L["16"] = Instance.new("UICorner", G2L["2"]);
G2L["16"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.ChatLogs.UIGradient
G2L["17"] = Instance.new("UIGradient", G2L["2"]);
G2L["17"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(26, 26, 31)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 26))};


-- StarterGui.AdminUI.ChatLogs.UIStroke
G2L["18"] = Instance.new("UIStroke", G2L["2"]);
G2L["18"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["18"]["Thickness"] = 2;
G2L["18"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.Commands
G2L["19"] = Instance.new("Frame", G2L["1"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 31);
G2L["19"]["Size"] = UDim2.new(0, 300, 0, 320);
G2L["19"]["Position"] = UDim2.new(0.01177, 0, 0.01911, 0);
G2L["19"]["Name"] = [[Commands]];
G2L["19"]["BackgroundTransparency"] = 0.1;


-- StarterGui.AdminUI.Commands.Container
G2L["1a"] = Instance.new("Frame", G2L["19"]);
G2L["1a"]["BorderSizePixel"] = 0;
G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["1a"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["1a"]["ClipsDescendants"] = true;
G2L["1a"]["Size"] = UDim2.new(1, -15, 1, -50);
G2L["1a"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["1a"]["Name"] = [[Container]];
G2L["1a"]["BackgroundTransparency"] = 0.3;


-- StarterGui.AdminUI.Commands.Container.List
G2L["1b"] = Instance.new("ScrollingFrame", G2L["1a"]);
G2L["1b"]["BorderSizePixel"] = 0;
G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["Name"] = [[List]];
G2L["1b"]["Size"] = UDim2.new(1, -10, 1, -35);
G2L["1b"]["ScrollBarImageColor3"] = Color3.fromRGB(101, 101, 111);
G2L["1b"]["Position"] = UDim2.new(0, 5, 0, 30);
G2L["1b"]["ScrollBarThickness"] = 3;
G2L["1b"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Commands.Container.List.UIListLayout
G2L["1c"] = Instance.new("UIListLayout", G2L["1b"]);
G2L["1c"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["1c"]["Padding"] = UDim.new(0, 5);


-- StarterGui.AdminUI.Commands.Container.List.TextLabel
G2L["1d"] = Instance.new("TextLabel", G2L["1b"]);
G2L["1d"]["TextWrapped"] = true;
G2L["1d"]["TextSize"] = 16;
G2L["1d"]["TextScaled"] = true;
G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["1d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1d"]["TextColor3"] = Color3.fromRGB(221, 221, 231);
G2L["1d"]["BackgroundTransparency"] = 0.4;
G2L["1d"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["1d"]["Text"] = [[example <player> <text>]];


-- StarterGui.AdminUI.Commands.Container.List.TextLabel.UICorner
G2L["1e"] = Instance.new("UICorner", G2L["1d"]);
G2L["1e"]["CornerRadius"] = UDim.new(0, 4);


-- StarterGui.AdminUI.Commands.Container.Filter
G2L["1f"] = Instance.new("TextBox", G2L["1a"]);
G2L["1f"]["Name"] = [[Filter]];
G2L["1f"]["PlaceholderColor3"] = Color3.fromRGB(151, 151, 161);
G2L["1f"]["BorderSizePixel"] = 0;
G2L["1f"]["TextSize"] = 16;
G2L["1f"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["1f"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1f"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["1f"]["PlaceholderText"] = [[Filter commands...]];
G2L["1f"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["1f"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["1f"]["Text"] = [[]];
G2L["1f"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.Commands.Container.Filter.UICorner
G2L["20"] = Instance.new("UICorner", G2L["1f"]);
G2L["20"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.Commands.Container.Filter.UIStroke
G2L["21"] = Instance.new("UIStroke", G2L["1f"]);
G2L["21"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["21"]["Thickness"] = 2;
G2L["21"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.Commands.Container.UICorner
G2L["22"] = Instance.new("UICorner", G2L["1a"]);



-- StarterGui.AdminUI.Commands.Container.UIGradient
G2L["23"] = Instance.new("UIGradient", G2L["1a"]);
G2L["23"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 46)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(31, 31, 36))};


-- StarterGui.AdminUI.Commands.Topbar
G2L["24"] = Instance.new("Frame", G2L["19"]);
G2L["24"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["24"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["24"]["Name"] = [[Topbar]];
G2L["24"]["BackgroundTransparency"] = 0.2;


-- StarterGui.AdminUI.Commands.Topbar.Exit
G2L["25"] = Instance.new("TextButton", G2L["24"]);
G2L["25"]["BorderSizePixel"] = 0;
G2L["25"]["TextSize"] = 16;
G2L["25"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["25"]["BackgroundColor3"] = Color3.fromRGB(181, 51, 51);
G2L["25"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["25"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["25"]["BackgroundTransparency"] = 0.3;
G2L["25"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["25"]["Text"] = [[×]];
G2L["25"]["Name"] = [[Exit]];
G2L["25"]["Position"] = UDim2.new(1, -10, 0.5, 0);


-- StarterGui.AdminUI.Commands.Topbar.Exit.UICorner
G2L["26"] = Instance.new("UICorner", G2L["25"]);
G2L["26"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.Commands.Topbar.Exit.UIStroke
G2L["27"] = Instance.new("UIStroke", G2L["25"]);
G2L["27"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["27"]["Thickness"] = 2;
G2L["27"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.Commands.Topbar.Minimize
G2L["28"] = Instance.new("TextButton", G2L["24"]);
G2L["28"]["BorderSizePixel"] = 0;
G2L["28"]["TextSize"] = 16;
G2L["28"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["28"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["28"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["28"]["BackgroundTransparency"] = 0.3;
G2L["28"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["28"]["Text"] = [[−]];
G2L["28"]["Name"] = [[Minimize]];
G2L["28"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.Commands.Topbar.Minimize.UICorner
G2L["29"] = Instance.new("UICorner", G2L["28"]);
G2L["29"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.Commands.Topbar.Minimize.UIStroke
G2L["2a"] = Instance.new("UIStroke", G2L["28"]);
G2L["2a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["2a"]["Thickness"] = 2;
G2L["2a"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.Commands.Topbar.Title
G2L["2b"] = Instance.new("TextLabel", G2L["24"]);
G2L["2b"]["BorderSizePixel"] = 0;
G2L["2b"]["TextSize"] = 18;
G2L["2b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["2b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2b"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["2b"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["2b"]["BackgroundTransparency"] = 1;
G2L["2b"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["2b"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["2b"]["Text"] = [[Commands]];
G2L["2b"]["Name"] = [[Title]];
G2L["2b"]["Position"] = UDim2.new(0, 10, 0.5, 0);


-- StarterGui.AdminUI.Commands.Topbar.UICorner
G2L["2c"] = Instance.new("UICorner", G2L["24"]);
G2L["2c"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.Commands.Topbar.UIStroke
G2L["2d"] = Instance.new("UIStroke", G2L["24"]);
G2L["2d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["2d"]["Thickness"] = 2;
G2L["2d"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.Commands.UICorner
G2L["2e"] = Instance.new("UICorner", G2L["19"]);
G2L["2e"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.Commands.UIGradient
G2L["2f"] = Instance.new("UIGradient", G2L["19"]);
G2L["2f"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(31, 31, 36)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 26))};


-- StarterGui.AdminUI.Commands.UIStroke
G2L["30"] = Instance.new("UIStroke", G2L["19"]);
G2L["30"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["30"]["Thickness"] = 2;
G2L["30"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.soRealConsole
G2L["31"] = Instance.new("Frame", G2L["1"]);
G2L["31"]["BorderSizePixel"] = 0;
G2L["31"]["BackgroundColor3"] = Color3.fromRGB(29, 29, 33);
G2L["31"]["Size"] = UDim2.new(0, 420, 0, 280);
G2L["31"]["Position"] = UDim2.new(0.64348, 0, 0.04497, 0);
G2L["31"]["Name"] = [[soRealConsole]];
G2L["31"]["BackgroundTransparency"] = 0.1;


-- StarterGui.AdminUI.soRealConsole.Container
G2L["32"] = Instance.new("Frame", G2L["31"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["32"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["32"]["ClipsDescendants"] = true;
G2L["32"]["Size"] = UDim2.new(1, -15, 1, -45);
G2L["32"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["32"]["Name"] = [[Container]];
G2L["32"]["BackgroundTransparency"] = 0.3;


-- StarterGui.AdminUI.soRealConsole.Container.Logs
G2L["33"] = Instance.new("ScrollingFrame", G2L["32"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["33"]["Name"] = [[Logs]];
G2L["33"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["33"]["Size"] = UDim2.new(1, -10, 0.9, -35);
G2L["33"]["ScrollBarImageColor3"] = Color3.fromRGB(101, 101, 111);
G2L["33"]["Position"] = UDim2.new(0.5, 0, 0.62, 0);
G2L["33"]["ScrollBarThickness"] = 3;
G2L["33"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.UIListLayout
G2L["34"] = Instance.new("UIListLayout", G2L["33"]);
G2L["34"]["Padding"] = UDim.new(0, 5);
G2L["34"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.TextLabel
G2L["35"] = Instance.new("TextLabel", G2L["33"]);
G2L["35"]["TextWrapped"] = true;
G2L["35"]["TextSize"] = 16;
G2L["35"]["TextScaled"] = true;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["35"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["35"]["TextColor3"] = Color3.fromRGB(221, 221, 231);
G2L["35"]["BackgroundTransparency"] = 0.5;
G2L["35"]["Size"] = UDim2.new(1, 0, 0, 26);
G2L["35"]["Text"] = [[[Output]: failed print 1]];


-- StarterGui.AdminUI.soRealConsole.Container.Logs.TextLabel.UICorner
G2L["36"] = Instance.new("UICorner", G2L["35"]);
G2L["36"]["CornerRadius"] = UDim.new(0, 5);


-- StarterGui.AdminUI.soRealConsole.Container.UICorner
G2L["37"] = Instance.new("UICorner", G2L["32"]);



-- StarterGui.AdminUI.soRealConsole.Container.UIGradient
G2L["38"] = Instance.new("UIGradient", G2L["32"]);
G2L["38"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 46)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(31, 31, 36))};


-- StarterGui.AdminUI.soRealConsole.Container.Filter
G2L["39"] = Instance.new("TextBox", G2L["32"]);
G2L["39"]["Name"] = [[Filter]];
G2L["39"]["PlaceholderColor3"] = Color3.fromRGB(151, 151, 161);
G2L["39"]["BorderSizePixel"] = 0;
G2L["39"]["TextSize"] = 16;
G2L["39"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["39"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["39"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["39"]["PlaceholderText"] = [[Search...]];
G2L["39"]["Size"] = UDim2.new(1, -10, 0, 24);
G2L["39"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["39"]["Text"] = [[]];
G2L["39"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.soRealConsole.Container.Filter.UICorner
G2L["3a"] = Instance.new("UICorner", G2L["39"]);
G2L["3a"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.soRealConsole.Container.Filter.UIStroke
G2L["3b"] = Instance.new("UIStroke", G2L["39"]);
G2L["3b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["3b"]["Thickness"] = 2;
G2L["3b"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar
G2L["3c"] = Instance.new("Frame", G2L["31"]);
G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["3c"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["3c"]["Name"] = [[Topbar]];
G2L["3c"]["BackgroundTransparency"] = 0.2;


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit
G2L["3d"] = Instance.new("TextButton", G2L["3c"]);
G2L["3d"]["BorderSizePixel"] = 0;
G2L["3d"]["TextSize"] = 16;
G2L["3d"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["3d"]["BackgroundColor3"] = Color3.fromRGB(181, 51, 51);
G2L["3d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3d"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["3d"]["BackgroundTransparency"] = 0.3;
G2L["3d"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["3d"]["Text"] = [[×]];
G2L["3d"]["Name"] = [[Exit]];
G2L["3d"]["Position"] = UDim2.new(1, -10, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UICorner
G2L["3e"] = Instance.new("UICorner", G2L["3d"]);
G2L["3e"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UIStroke
G2L["3f"] = Instance.new("UIStroke", G2L["3d"]);
G2L["3f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["3f"]["Thickness"] = 2;
G2L["3f"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize
G2L["40"] = Instance.new("TextButton", G2L["3c"]);
G2L["40"]["BorderSizePixel"] = 0;
G2L["40"]["TextSize"] = 16;
G2L["40"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["40"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["40"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["40"]["BackgroundTransparency"] = 0.3;
G2L["40"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["40"]["Text"] = [[−]];
G2L["40"]["Name"] = [[Minimize]];
G2L["40"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UICorner
G2L["41"] = Instance.new("UICorner", G2L["40"]);
G2L["41"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UIStroke
G2L["42"] = Instance.new("UIStroke", G2L["40"]);
G2L["42"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["42"]["Thickness"] = 2;
G2L["42"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear
G2L["43"] = Instance.new("TextButton", G2L["3c"]);
G2L["43"]["BorderSizePixel"] = 0;
G2L["43"]["TextSize"] = 14;
G2L["43"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["43"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["43"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["43"]["BackgroundTransparency"] = 0.3;
G2L["43"]["Size"] = UDim2.new(0, 60, 0, 24);
G2L["43"]["Text"] = [[Clear]];
G2L["43"]["Name"] = [[Clear]];
G2L["43"]["Position"] = UDim2.new(0, 10, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UICorner
G2L["44"] = Instance.new("UICorner", G2L["43"]);
G2L["44"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UIStroke
G2L["45"] = Instance.new("UIStroke", G2L["43"]);
G2L["45"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["45"]["Thickness"] = 2;
G2L["45"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Title
G2L["46"] = Instance.new("TextLabel", G2L["3c"]);
G2L["46"]["TextWrapped"] = true;
G2L["46"]["BorderSizePixel"] = 0;
G2L["46"]["TextSize"] = 18;
G2L["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["46"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["46"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["46"]["BackgroundTransparency"] = 1;
G2L["46"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["46"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["46"]["Text"] = [[NA Console]];
G2L["46"]["Name"] = [[Title]];
G2L["46"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.UICorner
G2L["47"] = Instance.new("UICorner", G2L["3c"]);
G2L["47"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.soRealConsole.Topbar.UIStroke
G2L["48"] = Instance.new("UIStroke", G2L["3c"]);
G2L["48"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["48"]["Thickness"] = 2;
G2L["48"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.soRealConsole.UICorner
G2L["49"] = Instance.new("UICorner", G2L["31"]);
G2L["49"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.soRealConsole.UIGradient
G2L["4a"] = Instance.new("UIGradient", G2L["31"]);
G2L["4a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(31, 31, 36)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(26, 26, 31))};


-- StarterGui.AdminUI.soRealConsole.UIStroke
G2L["4b"] = Instance.new("UIStroke", G2L["31"]);
G2L["4b"]["Thickness"] = 2;
G2L["4b"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.CmdBar
G2L["4c"] = Instance.new("Frame", G2L["1"]);
G2L["4c"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4c"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4c"]["Size"] = UDim2.new(1, 0, 0, 30);
G2L["4c"]["Position"] = UDim2.new(0.5, 0, 0.5, -20);
G2L["4c"]["Name"] = [[CmdBar]];
G2L["4c"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.CenterBar
G2L["4d"] = Instance.new("Frame", G2L["4c"]);
G2L["4d"]["ZIndex"] = 2;
G2L["4d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4d"]["Size"] = UDim2.new(0, 280, 1, 10);
G2L["4d"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["4d"]["Name"] = [[CenterBar]];
G2L["4d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal
G2L["4e"] = Instance.new("Frame", G2L["4d"]);
G2L["4e"]["ZIndex"] = 2;
G2L["4e"]["BorderSizePixel"] = 0;
G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["4e"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["4e"]["Name"] = [[Horizontal]];
G2L["4e"]["BackgroundTransparency"] = 0.2;


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UICorner
G2L["4f"] = Instance.new("UICorner", G2L["4e"]);



-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UIGradient
G2L["50"] = Instance.new("UIGradient", G2L["4e"]);
G2L["50"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 46)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(31, 31, 36))};


-- StarterGui.AdminUI.CmdBar.CenterBar.Input
G2L["51"] = Instance.new("TextBox", G2L["4d"]);
G2L["51"]["Active"] = false;
G2L["51"]["Name"] = [[Input]];
G2L["51"]["ZIndex"] = 2;
G2L["51"]["TextWrapped"] = true;
G2L["51"]["TextSize"] = 20;
G2L["51"]["TextColor3"] = Color3.fromRGB(241, 241, 251);
G2L["51"]["TextScaled"] = true;
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["51"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["51"]["ClipsDescendants"] = true;
G2L["51"]["Size"] = UDim2.new(1, -10, 0.7, 0);
G2L["51"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["51"]["Text"] = [[]];
G2L["51"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.LeftFill
G2L["52"] = Instance.new("Frame", G2L["4c"]);
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["52"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["52"]["Size"] = UDim2.new(0.5, -140, 1, 0);
G2L["52"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["52"]["Name"] = [[LeftFill]];
G2L["52"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal
G2L["53"] = Instance.new("Frame", G2L["52"]);
G2L["53"]["BorderSizePixel"] = 0;
G2L["53"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["53"]["Size"] = UDim2.new(1.005, 0, 1, 0);
G2L["53"]["Name"] = [[Horizontal]];
G2L["53"]["BackgroundTransparency"] = 0.2;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UICorner
G2L["54"] = Instance.new("UICorner", G2L["53"]);



-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UIGradient
G2L["55"] = Instance.new("UIGradient", G2L["53"]);
G2L["55"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 46)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(31, 31, 36))};


-- StarterGui.AdminUI.CmdBar.RightFill
G2L["56"] = Instance.new("Frame", G2L["4c"]);
G2L["56"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["56"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["56"]["Size"] = UDim2.new(0.5, -140, 1, 0);
G2L["56"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["56"]["Name"] = [[RightFill]];
G2L["56"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal
G2L["57"] = Instance.new("Frame", G2L["56"]);
G2L["57"]["BorderSizePixel"] = 0;
G2L["57"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["57"]["Size"] = UDim2.new(1.005, 0, 1, 0);
G2L["57"]["Position"] = UDim2.new(-0.005, 0, 0, 0);
G2L["57"]["Name"] = [[Horizontal]];
G2L["57"]["BackgroundTransparency"] = 0.2;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UICorner
G2L["58"] = Instance.new("UICorner", G2L["57"]);



-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UIGradient
G2L["59"] = Instance.new("UIGradient", G2L["57"]);
G2L["59"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 46)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(31, 31, 36))};


-- StarterGui.AdminUI.CmdBar.Autofill
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


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd
G2L["5b"] = Instance.new("Frame", G2L["5a"]);
G2L["5b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5b"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["5b"]["Size"] = UDim2.new(0.5, 0, 0, 28);
G2L["5b"]["Position"] = UDim2.new(0.5, 0, 0.82, 0);
G2L["5b"]["Name"] = [[Cmd]];
G2L["5b"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Input
G2L["5c"] = Instance.new("TextLabel", G2L["5b"]);
G2L["5c"]["TextWrapped"] = true;
G2L["5c"]["Active"] = true;
G2L["5c"]["ZIndex"] = 2;
G2L["5c"]["TextSize"] = 18;
G2L["5c"]["TextScaled"] = true;
G2L["5c"]["BackgroundColor3"] = Color3.fromRGB(23, 23, 23);
G2L["5c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5c"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["5c"]["BackgroundTransparency"] = 1;
G2L["5c"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["5c"]["Size"] = UDim2.new(1, 0, 1, -5);
G2L["5c"]["ClipsDescendants"] = true;
G2L["5c"]["Text"] = [[example <player> <text>]];
G2L["5c"]["Selectable"] = true;
G2L["5c"]["Name"] = [[Input]];
G2L["5c"]["Position"] = UDim2.new(0, 0, 0.5, 0);


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background
G2L["5d"] = Instance.new("Frame", G2L["5b"]);
G2L["5d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5d"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["5d"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5d"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["5d"]["Name"] = [[Background]];
G2L["5d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal
G2L["5e"] = Instance.new("Frame", G2L["5d"]);
G2L["5e"]["BorderSizePixel"] = 0;
G2L["5e"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["5e"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5e"]["Name"] = [[Horizontal]];
G2L["5e"]["BackgroundTransparency"] = 0.3;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UICorner
G2L["5f"] = Instance.new("UICorner", G2L["5e"]);
G2L["5f"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UIGradient
G2L["60"] = Instance.new("UIGradient", G2L["5e"]);
G2L["60"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(46, 46, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(36, 36, 41))};


-- StarterGui.AdminUI.CmdBar.Autofill.UIListLayout
G2L["61"] = Instance.new("UIListLayout", G2L["5a"]);
G2L["61"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["61"]["Padding"] = UDim.new(0, 5);
G2L["61"]["VerticalAlignment"] = Enum.VerticalAlignment.Bottom;
G2L["61"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.Description
G2L["62"] = Instance.new("TextLabel", G2L["1"]);
G2L["62"]["TextWrapped"] = true;
G2L["62"]["TextSize"] = 13;
G2L["62"]["TextScaled"] = true;
G2L["62"]["BackgroundColor3"] = Color3.fromRGB(18, 10, 26);
G2L["62"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["62"]["TextColor3"] = Color3.fromRGB(247, 247, 247);
G2L["62"]["BackgroundTransparency"] = 0.3;
G2L["62"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["62"]["Size"] = UDim2.new(0, 191, 0, 26);
G2L["62"]["Visible"] = false;
G2L["62"]["BorderColor3"] = Color3.fromRGB(59, 59, 59);
G2L["62"]["Text"] = [[Name]];
G2L["62"]["Name"] = [[Description]];


-- StarterGui.AdminUI.Description.UICorner
G2L["63"] = Instance.new("UICorner", G2L["62"]);



-- StarterGui.AdminUI.AutoScale
G2L["64"] = Instance.new("UIScale", G2L["1"]);
G2L["64"]["Name"] = [[AutoScale]];


-- StarterGui.AdminUI.Modal
G2L["65"] = Instance.new("ImageButton", G2L["1"]);
G2L["65"]["BackgroundTransparency"] = 1;
G2L["65"]["Name"] = [[Modal]];


-- StarterGui.AdminUI.Resizeable
G2L["66"] = Instance.new("Frame", G2L["1"]);
G2L["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["66"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["66"]["Name"] = [[Resizeable]];
G2L["66"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Left
G2L["67"] = Instance.new("Frame", G2L["66"]);
G2L["67"]["BorderSizePixel"] = 0;
G2L["67"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["67"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["67"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["67"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["67"]["Name"] = [[Left]];
G2L["67"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Right
G2L["68"] = Instance.new("Frame", G2L["66"]);
G2L["68"]["BorderSizePixel"] = 0;
G2L["68"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["68"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["68"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["68"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["68"]["Name"] = [[Right]];
G2L["68"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Top
G2L["69"] = Instance.new("Frame", G2L["66"]);
G2L["69"]["BorderSizePixel"] = 0;
G2L["69"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["69"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["69"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["69"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["69"]["Name"] = [[Top]];
G2L["69"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Bottom
G2L["6a"] = Instance.new("Frame", G2L["66"]);
G2L["6a"]["BorderSizePixel"] = 0;
G2L["6a"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["6a"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["6a"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["6a"]["Position"] = UDim2.new(0.5, 0, 1, 0);
G2L["6a"]["Name"] = [[Bottom]];
G2L["6a"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopLeft
G2L["6b"] = Instance.new("Frame", G2L["66"]);
G2L["6b"]["BorderSizePixel"] = 0;
G2L["6b"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["6b"]["AnchorPoint"] = Vector2.new(1, 1);
G2L["6b"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6b"]["Position"] = UDim2.new(0, 4, 0, 4);
G2L["6b"]["Name"] = [[TopLeft]];
G2L["6b"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopRight
G2L["6c"] = Instance.new("Frame", G2L["66"]);
G2L["6c"]["BorderSizePixel"] = 0;
G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["6c"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["6c"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6c"]["Position"] = UDim2.new(1, -4, 0, 4);
G2L["6c"]["Name"] = [[TopRight]];
G2L["6c"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomLeft
G2L["6d"] = Instance.new("Frame", G2L["66"]);
G2L["6d"]["BorderSizePixel"] = 0;
G2L["6d"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["6d"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["6d"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6d"]["Position"] = UDim2.new(0, 4, 1, -4);
G2L["6d"]["Name"] = [[BottomLeft]];
G2L["6d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomRight
G2L["6e"] = Instance.new("Frame", G2L["66"]);
G2L["6e"]["BorderSizePixel"] = 0;
G2L["6e"]["BackgroundColor3"] = Color3.fromRGB(0, 206, 255);
G2L["6e"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["6e"]["Position"] = UDim2.new(1, -4, 1, -4);
G2L["6e"]["Name"] = [[BottomRight]];
G2L["6e"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings
G2L["6f"] = Instance.new("Frame", G2L["1"]);
G2L["6f"]["BorderSizePixel"] = 0;
G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(26, 26, 31);
G2L["6f"]["Size"] = UDim2.new(0, 520, 0, 360);
G2L["6f"]["Position"] = UDim2.new(0.14365, 0, 0.51325, 0);
G2L["6f"]["Name"] = [[setsettings]];
G2L["6f"]["BackgroundTransparency"] = 0.1;


-- StarterGui.AdminUI.setsettings.Container
G2L["70"] = Instance.new("Frame", G2L["6f"]);
G2L["70"]["BorderSizePixel"] = 0;
G2L["70"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["70"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["70"]["ClipsDescendants"] = true;
G2L["70"]["Size"] = UDim2.new(1, -15, 1, -40);
G2L["70"]["Position"] = UDim2.new(0.5, 0, 1, -10);
G2L["70"]["Name"] = [[Container]];
G2L["70"]["BackgroundTransparency"] = 0.3;


-- StarterGui.AdminUI.setsettings.Container.List
G2L["71"] = Instance.new("ScrollingFrame", G2L["70"]);
G2L["71"]["BorderSizePixel"] = 0;
G2L["71"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["71"]["Name"] = [[List]];
G2L["71"]["Size"] = UDim2.new(1, -10, 1, -10);
G2L["71"]["ScrollBarImageColor3"] = Color3.fromRGB(101, 101, 111);
G2L["71"]["Position"] = UDim2.new(0, 5, 0, 5);
G2L["71"]["ScrollBarThickness"] = 3;
G2L["71"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.UIListLayout
G2L["72"] = Instance.new("UIListLayout", G2L["71"]);
G2L["72"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["72"]["Padding"] = UDim.new(0, 5);
G2L["72"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.setsettings.Container.List.Toggle
G2L["73"] = Instance.new("Frame", G2L["71"]);
G2L["73"]["BorderSizePixel"] = 0;
G2L["73"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["73"]["Size"] = UDim2.new(1, -10, 0, 42);
G2L["73"]["Name"] = [[Toggle]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Title
G2L["74"] = Instance.new("TextLabel", G2L["73"]);
G2L["74"]["TextWrapped"] = true;
G2L["74"]["BorderSizePixel"] = 0;
G2L["74"]["TextSize"] = 16;
G2L["74"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["74"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["74"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["74"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["74"]["BackgroundTransparency"] = 1;
G2L["74"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["74"]["Size"] = UDim2.new(0, 180, 0, 16);
G2L["74"]["Text"] = [[random toggle]];
G2L["74"]["Name"] = [[Title]];
G2L["74"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Interact
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


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch
G2L["76"] = Instance.new("Frame", G2L["73"]);
G2L["76"]["BorderSizePixel"] = 0;
G2L["76"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["76"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["76"]["Size"] = UDim2.new(0, 45, 0, 22);
G2L["76"]["Position"] = UDim2.new(1, -15, 0.5, 0);
G2L["76"]["Name"] = [[Switch]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.UICorner
G2L["77"] = Instance.new("UICorner", G2L["76"]);
G2L["77"]["CornerRadius"] = UDim.new(0, 15);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator
G2L["78"] = Instance.new("Frame", G2L["76"]);
G2L["78"]["BorderSizePixel"] = 0;
G2L["78"]["BackgroundColor3"] = Color3.fromRGB(111, 111, 121);
G2L["78"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["78"]["Size"] = UDim2.new(0, 18, 0, 18);
G2L["78"]["Position"] = UDim2.new(1, -42, 0.5, 0);
G2L["78"]["Name"] = [[Indicator]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator.UICorner
G2L["79"] = Instance.new("UICorner", G2L["78"]);
G2L["79"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.UIStroke
G2L["7a"] = Instance.new("UIStroke", G2L["76"]);
G2L["7a"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.UICorner
G2L["7b"] = Instance.new("UICorner", G2L["73"]);



-- StarterGui.AdminUI.setsettings.Container.List.Slider
G2L["7c"] = Instance.new("Frame", G2L["71"]);
G2L["7c"]["BorderSizePixel"] = 0;
G2L["7c"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["7c"]["Size"] = UDim2.new(1, -10, 0, 38);
G2L["7c"]["Position"] = UDim2.new(0.01, 0, 0.45, 0);
G2L["7c"]["Name"] = [[Slider]];


-- StarterGui.AdminUI.setsettings.Container.List.Slider.UICorner
G2L["7d"] = Instance.new("UICorner", G2L["7c"]);



-- StarterGui.AdminUI.setsettings.Container.List.Slider.Title
G2L["7e"] = Instance.new("TextLabel", G2L["7c"]);
G2L["7e"]["TextWrapped"] = true;
G2L["7e"]["BorderSizePixel"] = 0;
G2L["7e"]["TextSize"] = 16;
G2L["7e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["7e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7e"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["7e"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["7e"]["BackgroundTransparency"] = 1;
G2L["7e"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["7e"]["Size"] = UDim2.new(0, 200, 0, 16);
G2L["7e"]["Text"] = [[Slider]];
G2L["7e"]["Name"] = [[Title]];
G2L["7e"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main
G2L["7f"] = Instance.new("CanvasGroup", G2L["7c"]);
G2L["7f"]["BorderSizePixel"] = 0;
G2L["7f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7f"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["7f"]["Size"] = UDim2.new(0, 222, 0, 30);
G2L["7f"]["Position"] = UDim2.new(1, -10, 0.5, 0);
G2L["7f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7f"]["Name"] = [[Main]];
G2L["7f"]["BackgroundTransparency"] = 0.8;


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.UICorner
G2L["80"] = Instance.new("UICorner", G2L["7f"]);
G2L["80"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.UIStroke
G2L["81"] = Instance.new("UIStroke", G2L["7f"]);
G2L["81"]["Transparency"] = 0.4;
G2L["81"]["Thickness"] = 1.2;
G2L["81"]["Color"] = Color3.fromRGB(53, 53, 53);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Interact
G2L["82"] = Instance.new("TextButton", G2L["7f"]);
G2L["82"]["BorderSizePixel"] = 0;
G2L["82"]["TextSize"] = 14;
G2L["82"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["82"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["82"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["82"]["ZIndex"] = 10;
G2L["82"]["BackgroundTransparency"] = 1;
G2L["82"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["82"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["82"]["Text"] = [[]];
G2L["82"]["Name"] = [[Interact]];


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Information
G2L["83"] = Instance.new("TextLabel", G2L["7f"]);
G2L["83"]["TextWrapped"] = true;
G2L["83"]["ZIndex"] = 5;
G2L["83"]["BorderSizePixel"] = 0;
G2L["83"]["TextSize"] = 15;
G2L["83"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["83"]["TextTransparency"] = 0.3;
G2L["83"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["83"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["83"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["83"]["BackgroundTransparency"] = 1;
G2L["83"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["83"]["Size"] = UDim2.new(0, 168, 0, 15);
G2L["83"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["83"]["Text"] = [[750 studs]];
G2L["83"]["Name"] = [[Information]];
G2L["83"]["Position"] = UDim2.new(0.4536, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Progress
G2L["84"] = Instance.new("Frame", G2L["7f"]);
G2L["84"]["BorderSizePixel"] = 0;
G2L["84"]["BackgroundColor3"] = Color3.fromRGB(96, 96, 96);
G2L["84"]["Size"] = UDim2.new(0.80097, 0, 1, 0);
G2L["84"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["84"]["Name"] = [[Progress]];


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Progress.UICorner
G2L["85"] = Instance.new("UICorner", G2L["84"]);
G2L["85"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Progress.UIStroke
G2L["86"] = Instance.new("UIStroke", G2L["84"]);
G2L["86"]["Transparency"] = 0.3;
G2L["86"]["Thickness"] = 1.2;
G2L["86"]["Color"] = Color3.fromRGB(53, 53, 53);


-- StarterGui.AdminUI.setsettings.Container.List.SectionTitle
G2L["87"] = Instance.new("Frame", G2L["71"]);
G2L["87"]["BorderSizePixel"] = 0;
G2L["87"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["87"]["Size"] = UDim2.new(1, 0, 0, 20);
G2L["87"]["Name"] = [[SectionTitle]];
G2L["87"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.SectionTitle.Title
G2L["88"] = Instance.new("TextLabel", G2L["87"]);
G2L["88"]["TextWrapped"] = true;
G2L["88"]["BorderSizePixel"] = 0;
G2L["88"]["TextSize"] = 16;
G2L["88"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["88"]["TextTransparency"] = 0.4;
G2L["88"]["TextScaled"] = true;
G2L["88"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["88"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["88"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["88"]["BackgroundTransparency"] = 1;
G2L["88"]["Size"] = UDim2.new(0.874, 0, 0, 16);
G2L["88"]["Text"] = [[random title]];
G2L["88"]["Name"] = [[Title]];
G2L["88"]["Position"] = UDim2.new(0, 10, 0.1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Keybind
G2L["89"] = Instance.new("Frame", G2L["71"]);
G2L["89"]["BorderSizePixel"] = 0;
G2L["89"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["89"]["Size"] = UDim2.new(1, -10, 0, 42);
G2L["89"]["Position"] = UDim2.new(0.01, 0, 0.669, 0);
G2L["89"]["Name"] = [[Keybind]];


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.UICorner
G2L["8a"] = Instance.new("UICorner", G2L["89"]);



-- StarterGui.AdminUI.setsettings.Container.List.Keybind.Title
G2L["8b"] = Instance.new("TextLabel", G2L["89"]);
G2L["8b"]["TextWrapped"] = true;
G2L["8b"]["BorderSizePixel"] = 0;
G2L["8b"]["TextSize"] = 16;
G2L["8b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["8b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8b"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8b"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["8b"]["BackgroundTransparency"] = 1;
G2L["8b"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["8b"]["Size"] = UDim2.new(0, 200, 0, 16);
G2L["8b"]["Text"] = [[Keybind]];
G2L["8b"]["Name"] = [[Title]];
G2L["8b"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame
G2L["8c"] = Instance.new("Frame", G2L["89"]);
G2L["8c"]["BorderSizePixel"] = 0;
G2L["8c"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["8c"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["8c"]["Size"] = UDim2.new(0, 40, 0, 28);
G2L["8c"]["Position"] = UDim2.new(1, -10, 0.5, 0);
G2L["8c"]["Name"] = [[KeybindFrame]];


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame.KeybindBox
G2L["8d"] = Instance.new("TextBox", G2L["8c"]);
G2L["8d"]["Name"] = [[KeybindBox]];
G2L["8d"]["BorderSizePixel"] = 0;
G2L["8d"]["TextSize"] = 16;
G2L["8d"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["8d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["8d"]["ClearTextOnFocus"] = false;
G2L["8d"]["PlaceholderText"] = [[Keybind]];
G2L["8d"]["Size"] = UDim2.new(1, -15, 0, 16);
G2L["8d"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["8d"]["Text"] = [[Q]];
G2L["8d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame.UICorner
G2L["8e"] = Instance.new("UICorner", G2L["8c"]);



-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame.UIStroke
G2L["8f"] = Instance.new("UIStroke", G2L["8c"]);
G2L["8f"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.Input
G2L["90"] = Instance.new("Frame", G2L["71"]);
G2L["90"]["BorderSizePixel"] = 0;
G2L["90"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["90"]["Size"] = UDim2.new(1, -10, 0, 42);
G2L["90"]["Position"] = UDim2.new(0.01, 0, 0.669, 0);
G2L["90"]["Name"] = [[Input]];


-- StarterGui.AdminUI.setsettings.Container.List.Input.UICorner
G2L["91"] = Instance.new("UICorner", G2L["90"]);



-- StarterGui.AdminUI.setsettings.Container.List.Input.Title
G2L["92"] = Instance.new("TextLabel", G2L["90"]);
G2L["92"]["TextWrapped"] = true;
G2L["92"]["BorderSizePixel"] = 0;
G2L["92"]["TextSize"] = 16;
G2L["92"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["92"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["92"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["92"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["92"]["BackgroundTransparency"] = 1;
G2L["92"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["92"]["Size"] = UDim2.new(0, 200, 0, 16);
G2L["92"]["Text"] = [[Input Element]];
G2L["92"]["Name"] = [[Title]];
G2L["92"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame
G2L["93"] = Instance.new("Frame", G2L["90"]);
G2L["93"]["BorderSizePixel"] = 0;
G2L["93"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["93"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["93"]["Size"] = UDim2.new(0, 125, 0, 28);
G2L["93"]["Position"] = UDim2.new(1, -10, 0.5, 0);
G2L["93"]["Name"] = [[InputFrame]];


-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame.InputBox
G2L["94"] = Instance.new("TextBox", G2L["93"]);
G2L["94"]["CursorPosition"] = -1;
G2L["94"]["Name"] = [[InputBox]];
G2L["94"]["BorderSizePixel"] = 0;
G2L["94"]["TextSize"] = 16;
G2L["94"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["94"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["94"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["94"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["94"]["ClearTextOnFocus"] = false;
G2L["94"]["PlaceholderText"] = [[Dynamic Input]];
G2L["94"]["Size"] = UDim2.new(1, -15, 0, 16);
G2L["94"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["94"]["Text"] = [[]];
G2L["94"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame.UICorner
G2L["95"] = Instance.new("UICorner", G2L["93"]);



-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame.UIStroke
G2L["96"] = Instance.new("UIStroke", G2L["93"]);
G2L["96"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker
G2L["97"] = Instance.new("Frame", G2L["71"]);
G2L["97"]["BorderSizePixel"] = 0;
G2L["97"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["97"]["Size"] = UDim2.new(1, -10, 0, 125);
G2L["97"]["Position"] = UDim2.new(0.01, 0, 0.573, 0);
G2L["97"]["Name"] = [[ColorPicker]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.UICorner
G2L["98"] = Instance.new("UICorner", G2L["97"]);



-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.Interact
G2L["99"] = Instance.new("TextButton", G2L["97"]);
G2L["99"]["BorderSizePixel"] = 0;
G2L["99"]["TextTransparency"] = 1;
G2L["99"]["TextSize"] = 14;
G2L["99"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["99"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["99"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["99"]["ZIndex"] = 5;
G2L["99"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["99"]["BackgroundTransparency"] = 1;
G2L["99"]["Size"] = UDim2.new(0.574, 0, 1, 0);
G2L["99"]["Text"] = [[]];
G2L["99"]["Name"] = [[Interact]];
G2L["99"]["Position"] = UDim2.new(0.289, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground
G2L["9a"] = Instance.new("Frame", G2L["97"]);
G2L["9a"]["BorderSizePixel"] = 0;
G2L["9a"]["BackgroundColor3"] = Color3.fromRGB(102, 255, 0);
G2L["9a"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["9a"]["Size"] = UDim2.new(0, 180, 0, 90);
G2L["9a"]["Position"] = UDim2.new(0, 455, 0, 15);
G2L["9a"]["Name"] = [[CPBackground]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP
G2L["9b"] = Instance.new("ImageButton", G2L["9a"]);
G2L["9b"]["BorderSizePixel"] = 0;
G2L["9b"]["ImageTransparency"] = 0.1;
G2L["9b"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["9b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9b"]["ZIndex"] = 2;
G2L["9b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9b"]["Image"] = [[http://www.roblox.com/asset/?id=11413591840]];
G2L["9b"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["9b"]["Name"] = [[MainCP]];
G2L["9b"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP.UICorner
G2L["9c"] = Instance.new("UICorner", G2L["9b"]);
G2L["9c"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP.MainPoint
G2L["9d"] = Instance.new("ImageButton", G2L["9b"]);
G2L["9d"]["Active"] = false;
G2L["9d"]["BorderSizePixel"] = 0;
G2L["9d"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["9d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9d"]["ImageColor3"] = Color3.fromRGB(32, 76, 0);
G2L["9d"]["ZIndex"] = 3;
G2L["9d"]["Image"] = [[http://www.roblox.com/asset/?id=3259050989]];
G2L["9d"]["Size"] = UDim2.new(0, 60, 0, 60);
G2L["9d"]["Name"] = [[MainPoint]];
G2L["9d"]["Position"] = UDim2.new(0.183, 0, 0.249, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.UICorner
G2L["9e"] = Instance.new("UICorner", G2L["9a"]);
G2L["9e"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display
G2L["9f"] = Instance.new("Frame", G2L["9a"]);
G2L["9f"]["BorderSizePixel"] = 0;
G2L["9f"]["BackgroundColor3"] = Color3.fromRGB(102, 255, 0);
G2L["9f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9f"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["9f"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["9f"]["Name"] = [[Display]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.UICorner
G2L["a0"] = Instance.new("UICorner", G2L["9f"]);
G2L["a0"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.Frame
G2L["a1"] = Instance.new("Frame", G2L["9f"]);
G2L["a1"]["BorderSizePixel"] = 0;
G2L["a1"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a1"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a1"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["a1"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["a1"]["BackgroundTransparency"] = 0.75;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.Frame.UICorner
G2L["a2"] = Instance.new("UICorner", G2L["a1"]);
G2L["a2"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput
G2L["a3"] = Instance.new("Frame", G2L["97"]);
G2L["a3"]["ZIndex"] = 10;
G2L["a3"]["BorderSizePixel"] = 0;
G2L["a3"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["a3"]["Size"] = UDim2.new(0, 125, 0, 32);
G2L["a3"]["Position"] = UDim2.new(0, 20, 0, 75);
G2L["a3"]["Name"] = [[HexInput]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.UICorner
G2L["a4"] = Instance.new("UICorner", G2L["a3"]);



-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.InputBox
G2L["a5"] = Instance.new("TextBox", G2L["a3"]);
G2L["a5"]["CursorPosition"] = -1;
G2L["a5"]["Name"] = [[InputBox]];
G2L["a5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["a5"]["ZIndex"] = 10;
G2L["a5"]["BorderSizePixel"] = 0;
G2L["a5"]["TextSize"] = 16;
G2L["a5"]["TextColor3"] = Color3.fromRGB(211, 211, 221);
G2L["a5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a5"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["a5"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a5"]["ClearTextOnFocus"] = false;
G2L["a5"]["PlaceholderText"] = [[hex]];
G2L["a5"]["Size"] = UDim2.new(0.98, -15, 0, 16);
G2L["a5"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["a5"]["Text"] = [[]];
G2L["a5"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.UIStroke
G2L["a6"] = Instance.new("UIStroke", G2L["a3"]);
G2L["a6"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider
G2L["a7"] = Instance.new("ImageButton", G2L["97"]);
G2L["a7"]["BorderSizePixel"] = 0;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["a7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a7"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["a7"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
G2L["a7"]["Size"] = UDim2.new(0, 180, 0, 14);
G2L["a7"]["ClipsDescendants"] = true;
G2L["a7"]["Name"] = [[ColorSlider]];
G2L["a7"]["Position"] = UDim2.new(0, 455, 0, 105);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.UIGradient
G2L["a8"] = Instance.new("UIGradient", G2L["a7"]);
G2L["a8"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),ColorSequenceKeypoint.new(0.060, Color3.fromRGB(255, 89, 0)),ColorSequenceKeypoint.new(0.110, Color3.fromRGB(255, 174, 0)),ColorSequenceKeypoint.new(0.170, Color3.fromRGB(255, 255, 0)),ColorSequenceKeypoint.new(0.220, Color3.fromRGB(173, 255, 0)),ColorSequenceKeypoint.new(0.280, Color3.fromRGB(87, 255, 0)),ColorSequenceKeypoint.new(0.330, Color3.fromRGB(0, 255, 5)),ColorSequenceKeypoint.new(0.390, Color3.fromRGB(0, 255, 90)),ColorSequenceKeypoint.new(0.450, Color3.fromRGB(0, 255, 175)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),ColorSequenceKeypoint.new(0.560, Color3.fromRGB(0, 171, 255)),ColorSequenceKeypoint.new(0.610, Color3.fromRGB(0, 86, 255)),ColorSequenceKeypoint.new(0.670, Color3.fromRGB(6, 0, 255)),ColorSequenceKeypoint.new(0.720, Color3.fromRGB(92, 0, 255)),ColorSequenceKeypoint.new(0.780, Color3.fromRGB(177, 0, 255)),ColorSequenceKeypoint.new(0.840, Color3.fromRGB(255, 0, 255)),ColorSequenceKeypoint.new(0.890, Color3.fromRGB(255, 0, 170)),ColorSequenceKeypoint.new(0.950, Color3.fromRGB(255, 0, 84)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))};


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.SliderPoint
G2L["a9"] = Instance.new("ImageButton", G2L["a7"]);
G2L["a9"]["Active"] = false;
G2L["a9"]["BorderSizePixel"] = 0;
G2L["a9"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["a9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a9"]["ImageColor3"] = Color3.fromRGB(0, 255, 0);
G2L["a9"]["ZIndex"] = 2;
G2L["a9"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["a9"]["Image"] = [[http://www.roblox.com/asset/?id=3259050989]];
G2L["a9"]["Size"] = UDim2.new(0, 60, 0, 60);
G2L["a9"]["Name"] = [[SliderPoint]];
G2L["a9"]["Position"] = UDim2.new(0.182, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.TintAdder
G2L["aa"] = Instance.new("TextLabel", G2L["a7"]);
G2L["aa"]["BorderSizePixel"] = 0;
G2L["aa"]["TextSize"] = 14;
G2L["aa"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["aa"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["aa"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["aa"]["BackgroundTransparency"] = 0.8;
G2L["aa"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["aa"]["Text"] = [[]];
G2L["aa"]["Name"] = [[TintAdder]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.TintAdder.UICorner
G2L["ab"] = Instance.new("UICorner", G2L["aa"]);
G2L["ab"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.UICorner
G2L["ac"] = Instance.new("UICorner", G2L["a7"]);
G2L["ac"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.Title
G2L["ad"] = Instance.new("TextLabel", G2L["97"]);
G2L["ad"]["TextWrapped"] = true;
G2L["ad"]["ZIndex"] = 3;
G2L["ad"]["BorderSizePixel"] = 0;
G2L["ad"]["TextSize"] = 16;
G2L["ad"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["ad"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ad"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ad"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["ad"]["BackgroundTransparency"] = 1;
G2L["ad"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ad"]["Size"] = UDim2.new(0, 240, 0, 16);
G2L["ad"]["Text"] = [[Color Picker]];
G2L["ad"]["Name"] = [[Title]];
G2L["ad"]["Position"] = UDim2.new(0, 140, 0, 25);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB
G2L["ae"] = Instance.new("Frame", G2L["97"]);
G2L["ae"]["BorderSizePixel"] = 0;
G2L["ae"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ae"]["Size"] = UDim2.new(0, 240, 0, 30);
G2L["ae"]["Position"] = UDim2.new(0, 20, 0, 45);
G2L["ae"]["Name"] = [[RGB]];
G2L["ae"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.UIListLayout
G2L["af"] = Instance.new("UIListLayout", G2L["ae"]);
G2L["af"]["Padding"] = UDim.new(0, 8);
G2L["af"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
G2L["af"]["FillDirection"] = Enum.FillDirection.Horizontal;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput
G2L["b0"] = Instance.new("Frame", G2L["ae"]);
G2L["b0"]["ZIndex"] = 10;
G2L["b0"]["BorderSizePixel"] = 0;
G2L["b0"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["b0"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b0"]["Size"] = UDim2.new(0, 56, 0, 28);
G2L["b0"]["Position"] = UDim2.new(0.36, -7, 0.5, 0);
G2L["b0"]["Name"] = [[GInput]];
G2L["b0"]["LayoutOrder"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.UICorner
G2L["b1"] = Instance.new("UICorner", G2L["b0"]);



-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.InputBox
G2L["b2"] = Instance.new("TextBox", G2L["b0"]);
G2L["b2"]["Name"] = [[InputBox]];
G2L["b2"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["b2"]["ZIndex"] = 10;
G2L["b2"]["BorderSizePixel"] = 0;
G2L["b2"]["TextSize"] = 14;
G2L["b2"]["TextColor3"] = Color3.fromRGB(211, 211, 221);
G2L["b2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b2"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b2"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["b2"]["ClearTextOnFocus"] = false;
G2L["b2"]["PlaceholderText"] = [[G]];
G2L["b2"]["Size"] = UDim2.new(0.874, -15, 0, 16);
G2L["b2"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["b2"]["Text"] = [[]];
G2L["b2"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.UIStroke
G2L["b3"] = Instance.new("UIStroke", G2L["b0"]);
G2L["b3"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput
G2L["b4"] = Instance.new("Frame", G2L["ae"]);
G2L["b4"]["ZIndex"] = 10;
G2L["b4"]["BorderSizePixel"] = 0;
G2L["b4"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["b4"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b4"]["Size"] = UDim2.new(0, 56, 0, 28);
G2L["b4"]["Position"] = UDim2.new(0.182, -5, 0.5, 0);
G2L["b4"]["Name"] = [[RInput]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.UICorner
G2L["b5"] = Instance.new("UICorner", G2L["b4"]);



-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.InputBox
G2L["b6"] = Instance.new("TextBox", G2L["b4"]);
G2L["b6"]["Name"] = [[InputBox]];
G2L["b6"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["b6"]["ZIndex"] = 10;
G2L["b6"]["BorderSizePixel"] = 0;
G2L["b6"]["TextSize"] = 14;
G2L["b6"]["TextColor3"] = Color3.fromRGB(211, 211, 221);
G2L["b6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b6"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b6"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["b6"]["ClearTextOnFocus"] = false;
G2L["b6"]["PlaceholderText"] = [[R]];
G2L["b6"]["Size"] = UDim2.new(0.874, -15, 0, 16);
G2L["b6"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["b6"]["Text"] = [[]];
G2L["b6"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.UIStroke
G2L["b7"] = Instance.new("UIStroke", G2L["b4"]);
G2L["b7"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput
G2L["b8"] = Instance.new("Frame", G2L["ae"]);
G2L["b8"]["ZIndex"] = 10;
G2L["b8"]["BorderSizePixel"] = 0;
G2L["b8"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 51);
G2L["b8"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b8"]["Size"] = UDim2.new(0, 56, 0, 28);
G2L["b8"]["Position"] = UDim2.new(0.928, -5, 0.465, 0);
G2L["b8"]["Name"] = [[BInput]];
G2L["b8"]["LayoutOrder"] = 2;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.UICorner
G2L["b9"] = Instance.new("UICorner", G2L["b8"]);



-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.InputBox
G2L["ba"] = Instance.new("TextBox", G2L["b8"]);
G2L["ba"]["Name"] = [[InputBox]];
G2L["ba"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["ba"]["ZIndex"] = 10;
G2L["ba"]["BorderSizePixel"] = 0;
G2L["ba"]["TextSize"] = 14;
G2L["ba"]["TextColor3"] = Color3.fromRGB(211, 211, 221);
G2L["ba"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ba"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ba"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ba"]["ClearTextOnFocus"] = false;
G2L["ba"]["PlaceholderText"] = [[B]];
G2L["ba"]["Size"] = UDim2.new(0.874, -15, 0, 16);
G2L["ba"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["ba"]["Text"] = [[]];
G2L["ba"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.UIStroke
G2L["bb"] = Instance.new("UIStroke", G2L["b8"]);
G2L["bb"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.Button
G2L["bc"] = Instance.new("Frame", G2L["71"]);
G2L["bc"]["BorderSizePixel"] = 0;
G2L["bc"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 46);
G2L["bc"]["Size"] = UDim2.new(1, -10, 0, 38);
G2L["bc"]["Name"] = [[Button]];


-- StarterGui.AdminUI.setsettings.Container.List.Button.UICorner
G2L["bd"] = Instance.new("UICorner", G2L["bc"]);



-- StarterGui.AdminUI.setsettings.Container.List.Button.Title
G2L["be"] = Instance.new("TextLabel", G2L["bc"]);
G2L["be"]["TextWrapped"] = true;
G2L["be"]["BorderSizePixel"] = 0;
G2L["be"]["TextSize"] = 16;
G2L["be"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["be"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["be"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["be"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["be"]["BackgroundTransparency"] = 1;
G2L["be"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["be"]["Size"] = UDim2.new(0, 190, 0, 16);
G2L["be"]["Text"] = [[Button Name]];
G2L["be"]["Name"] = [[Title]];
G2L["be"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button.Interact
G2L["bf"] = Instance.new("TextButton", G2L["bc"]);
G2L["bf"]["BorderSizePixel"] = 0;
G2L["bf"]["TextTransparency"] = 1;
G2L["bf"]["TextSize"] = 14;
G2L["bf"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["bf"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["bf"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["bf"]["ZIndex"] = 5;
G2L["bf"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["bf"]["BackgroundTransparency"] = 1;
G2L["bf"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["bf"]["Text"] = [[]];
G2L["bf"]["Name"] = [[Interact]];
G2L["bf"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button.ElementIndicator
G2L["c0"] = Instance.new("TextLabel", G2L["bc"]);
G2L["c0"]["TextWrapped"] = true;
G2L["c0"]["BorderSizePixel"] = 0;
G2L["c0"]["TextSize"] = 14;
G2L["c0"]["TextXAlignment"] = Enum.TextXAlignment.Right;
G2L["c0"]["TextTransparency"] = 0.8;
G2L["c0"]["TextScaled"] = true;
G2L["c0"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c0"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c0"]["TextColor3"] = Color3.fromRGB(241, 241, 246);
G2L["c0"]["BackgroundTransparency"] = 1;
G2L["c0"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c0"]["Size"] = UDim2.new(0, 110, 0, 14);
G2L["c0"]["Text"] = [[button]];
G2L["c0"]["Name"] = [[ElementIndicator]];
G2L["c0"]["Position"] = UDim2.new(1, -15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.UICorner
G2L["c1"] = Instance.new("UICorner", G2L["70"]);



-- StarterGui.AdminUI.setsettings.Container.UIGradient
G2L["c2"] = Instance.new("UIGradient", G2L["70"]);
G2L["c2"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 46)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(31, 31, 36))};


-- StarterGui.AdminUI.setsettings.Topbar
G2L["c3"] = Instance.new("Frame", G2L["6f"]);
G2L["c3"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 41);
G2L["c3"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["c3"]["Name"] = [[Topbar]];
G2L["c3"]["BackgroundTransparency"] = 0.2;


-- StarterGui.AdminUI.setsettings.Topbar.Exit
G2L["c4"] = Instance.new("TextButton", G2L["c3"]);
G2L["c4"]["BorderSizePixel"] = 0;
G2L["c4"]["TextSize"] = 16;
G2L["c4"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["c4"]["BackgroundColor3"] = Color3.fromRGB(181, 51, 51);
G2L["c4"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c4"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c4"]["BackgroundTransparency"] = 0.3;
G2L["c4"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["c4"]["Text"] = [[×]];
G2L["c4"]["Name"] = [[Exit]];
G2L["c4"]["Position"] = UDim2.new(1, -10, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Topbar.Exit.UICorner
G2L["c5"] = Instance.new("UICorner", G2L["c4"]);
G2L["c5"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Topbar.Exit.UIStroker
G2L["c6"] = Instance.new("UIStroke", G2L["c4"]);
G2L["c6"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c6"]["Name"] = [[UIStroker]];
G2L["c6"]["Thickness"] = 2;
G2L["c6"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.setsettings.Topbar.Minimize
G2L["c7"] = Instance.new("TextButton", G2L["c3"]);
G2L["c7"]["BorderSizePixel"] = 0;
G2L["c7"]["TextSize"] = 16;
G2L["c7"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["c7"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 61);
G2L["c7"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c7"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c7"]["BackgroundTransparency"] = 0.3;
G2L["c7"]["Size"] = UDim2.new(0, 24, 0, 24);
G2L["c7"]["Text"] = [[−]];
G2L["c7"]["Name"] = [[Minimize]];
G2L["c7"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Topbar.Minimize.UICorner
G2L["c8"] = Instance.new("UICorner", G2L["c7"]);
G2L["c8"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Topbar.Minimize.UIStroker
G2L["c9"] = Instance.new("UIStroke", G2L["c7"]);
G2L["c9"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c9"]["Name"] = [[UIStroker]];
G2L["c9"]["Thickness"] = 2;
G2L["c9"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.setsettings.Topbar.Title
G2L["ca"] = Instance.new("TextLabel", G2L["c3"]);
G2L["ca"]["TextWrapped"] = true;
G2L["ca"]["BorderSizePixel"] = 0;
G2L["ca"]["TextSize"] = 18;
G2L["ca"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ca"]["FontFace"] = Font.new([[rbxasset://fonts/families/Roboto.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["ca"]["TextColor3"] = Color3.fromRGB(231, 231, 241);
G2L["ca"]["BackgroundTransparency"] = 1;
G2L["ca"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ca"]["Size"] = UDim2.new(0.5, 0, 1, 0);
G2L["ca"]["Text"] = [[Settings]];
G2L["ca"]["Name"] = [[Title]];
G2L["ca"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Topbar.UICorner
G2L["cb"] = Instance.new("UICorner", G2L["c3"]);
G2L["cb"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Topbar.UIStroker
G2L["cc"] = Instance.new("UIStroke", G2L["c3"]);
G2L["cc"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["cc"]["Name"] = [[UIStroker]];
G2L["cc"]["Thickness"] = 2;
G2L["cc"]["Color"] = Color3.fromRGB(151, 96, 255);


-- StarterGui.AdminUI.setsettings.UICorner
G2L["cd"] = Instance.new("UICorner", G2L["6f"]);
G2L["cd"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.UIGradient
G2L["ce"] = Instance.new("UIGradient", G2L["6f"]);
G2L["ce"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(31, 31, 36)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(26, 26, 31))};


-- StarterGui.AdminUI.setsettings.UIStroker
G2L["cf"] = Instance.new("UIStroke", G2L["6f"]);
G2L["cf"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["cf"]["Name"] = [[UIStroker]];
G2L["cf"]["Thickness"] = 2;
G2L["cf"]["Color"] = Color3.fromRGB(151, 96, 255);



return G2L["1"];