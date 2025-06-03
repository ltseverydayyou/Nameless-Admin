local G2L = {};

-- StarterGui.AdminUI
G2L["1"] = Instance.new("ScreenGui");
G2L["1"]["Name"] = [[AdminUI]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["ResetOnSpawn"] = false;


-- StarterGui.AdminUI.AutoScale
G2L["2"] = Instance.new("UIScale", G2L["1"]);
G2L["2"]["Name"] = [[AutoScale]];


-- StarterGui.AdminUI.CmdBar
G2L["3"] = Instance.new("Frame", G2L["1"]);
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["3"]["Position"] = UDim2.new(0.5, 0, 0.5, -20);
G2L["3"]["Name"] = [[CmdBar]];
G2L["3"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.CenterBar
G2L["4"] = Instance.new("Frame", G2L["3"]);
G2L["4"]["ZIndex"] = 2;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4"]["Size"] = UDim2.new(0, 250, 1, 15);
G2L["4"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["4"]["Name"] = [[CenterBar]];
G2L["4"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal
G2L["5"] = Instance.new("Frame", G2L["4"]);
G2L["5"]["ZIndex"] = 2;
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["5"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(29, 29, 29);
G2L["5"]["Name"] = [[Horizontal]];
G2L["5"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UICorners
G2L["6"] = Instance.new("UICorner", G2L["5"]);
G2L["6"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UIGradients
G2L["7"] = Instance.new("UIGradient", G2L["5"]);
G2L["7"]["Name"] = [[UIGradients]];
G2L["7"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.CmdBar.CenterBar.Input
G2L["8"] = Instance.new("TextBox", G2L["4"]);
G2L["8"]["CursorPosition"] = -1;
G2L["8"]["Active"] = false;
G2L["8"]["Name"] = [[Input]];
G2L["8"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["8"]["ZIndex"] = 2;
G2L["8"]["TextWrapped"] = true;
G2L["8"]["TextSize"] = 24;
G2L["8"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["8"]["TextScaled"] = true;
G2L["8"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["8"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["8"]["ClipsDescendants"] = true;
G2L["8"]["Size"] = UDim2.new(1, -5, 0.7, 0);
G2L["8"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["8"]["Text"] = [[]];
G2L["8"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.LeftFill
G2L["9"] = Instance.new("Frame", G2L["3"]);
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["9"]["Size"] = UDim2.new(0.5, -125, 1, 0);
G2L["9"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["9"]["Name"] = [[LeftFill]];
G2L["9"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal
G2L["a"] = Instance.new("Frame", G2L["9"]);
G2L["a"]["BorderSizePixel"] = 0;
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["a"]["Size"] = UDim2.new(1.00599, 0, 1, 0);
G2L["a"]["BorderColor3"] = Color3.fromRGB(29, 29, 29);
G2L["a"]["Name"] = [[Horizontal]];
G2L["a"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UICorners
G2L["b"] = Instance.new("UICorner", G2L["a"]);
G2L["b"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UIGradients
G2L["c"] = Instance.new("UIGradient", G2L["a"]);
G2L["c"]["Name"] = [[UIGradients]];
G2L["c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.CmdBar.RightFill
G2L["d"] = Instance.new("Frame", G2L["3"]);
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["d"]["Size"] = UDim2.new(0.5, -125, 1, 0);
G2L["d"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["d"]["Name"] = [[RightFill]];
G2L["d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal
G2L["e"] = Instance.new("Frame", G2L["d"]);
G2L["e"]["BorderSizePixel"] = 0;
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["e"]["Size"] = UDim2.new(1.00798, 0, 1, 0);
G2L["e"]["Position"] = UDim2.new(-0.00798, 0, 0, 0);
G2L["e"]["BorderColor3"] = Color3.fromRGB(29, 29, 29);
G2L["e"]["Name"] = [[Horizontal]];
G2L["e"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UICorners
G2L["f"] = Instance.new("UICorner", G2L["e"]);
G2L["f"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UIGradients
G2L["10"] = Instance.new("UIGradient", G2L["e"]);
G2L["10"]["Name"] = [[UIGradients]];
G2L["10"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.CmdBar.Autofill
G2L["11"] = Instance.new("ScrollingFrame", G2L["3"]);
G2L["11"]["CanvasSize"] = UDim2.new(0, 0, 5, 0);
G2L["11"]["ScrollingEnabled"] = false;
G2L["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["11"]["Name"] = [[Autofill]];
G2L["11"]["Selectable"] = false;
G2L["11"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["11"]["Size"] = UDim2.new(1, 0, 0, 138);
G2L["11"]["Position"] = UDim2.new(0.5, 0, -6.52, 10);
G2L["11"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd
G2L["12"] = Instance.new("Frame", G2L["11"]);
G2L["12"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["12"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["12"]["Size"] = UDim2.new(0.5, 0, 0, 25);
G2L["12"]["Position"] = UDim2.new(0.5, 0, 0.81884, 0);
G2L["12"]["Name"] = [[Cmd]];
G2L["12"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Input
G2L["13"] = Instance.new("TextLabel", G2L["12"]);
G2L["13"]["TextWrapped"] = true;
G2L["13"]["Active"] = true;
G2L["13"]["ZIndex"] = 2;
G2L["13"]["TextSize"] = 24;
G2L["13"]["TextScaled"] = true;
G2L["13"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["13"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["13"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["13"]["BackgroundTransparency"] = 1;
G2L["13"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["13"]["Size"] = UDim2.new(1, 0, 1, -5);
G2L["13"]["ClipsDescendants"] = true;
G2L["13"]["Text"] = [[example <player> <text>]];
G2L["13"]["Selectable"] = true;
G2L["13"]["Name"] = [[Input]];
G2L["13"]["Position"] = UDim2.new(0, 0, 0.5, 0);


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background
G2L["14"] = Instance.new("Frame", G2L["12"]);
G2L["14"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["14"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["14"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["14"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["14"]["Name"] = [[Background]];
G2L["14"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal
G2L["15"] = Instance.new("Frame", G2L["14"]);
G2L["15"]["BorderSizePixel"] = 0;
G2L["15"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["15"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["15"]["Name"] = [[Horizontal]];
G2L["15"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UICorners
G2L["16"] = Instance.new("UICorner", G2L["15"]);
G2L["16"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UIGradients
G2L["17"] = Instance.new("UIGradient", G2L["15"]);
G2L["17"]["Name"] = [[UIGradients]];
G2L["17"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.CmdBar.Autofill.UIListLayout
G2L["18"] = Instance.new("UIListLayout", G2L["11"]);
G2L["18"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["18"]["Padding"] = UDim.new(0, 3);
G2L["18"]["VerticalAlignment"] = Enum.VerticalAlignment.Bottom;
G2L["18"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.Commands
G2L["19"] = Instance.new("Frame", G2L["1"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["19"]["Size"] = UDim2.new(0, 283, 0, 286);
G2L["19"]["Position"] = UDim2.new(0.01855, 0, 0.52493, 0);
G2L["19"]["BorderColor3"] = Color3.fromRGB(141, 141, 141);
G2L["19"]["Name"] = [[Commands]];
G2L["19"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.Commands.Container
G2L["1a"] = Instance.new("Frame", G2L["19"]);
G2L["1a"]["BorderSizePixel"] = 0;
G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["1a"]["ClipsDescendants"] = true;
G2L["1a"]["Size"] = UDim2.new(1, -10, 1.01154, -30);
G2L["1a"]["Position"] = UDim2.new(0.5, 0, 1, -5);
G2L["1a"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["Name"] = [[Container]];
G2L["1a"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.Commands.Container.List
G2L["1b"] = Instance.new("ScrollingFrame", G2L["1a"]);
G2L["1b"]["BorderSizePixel"] = 0;
G2L["1b"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["1b"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["Name"] = [[List]];
G2L["1b"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["1b"]["Size"] = UDim2.new(1, -10, 1, -27);
G2L["1b"]["Position"] = UDim2.new(0, 6, 0, 27);
G2L["1b"]["BorderColor3"] = Color3.fromRGB(18, 18, 18);
G2L["1b"]["ScrollBarThickness"] = 4;
G2L["1b"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Commands.Container.List.UIListLayout
G2L["1c"] = Instance.new("UIListLayout", G2L["1b"]);
G2L["1c"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["1c"]["Padding"] = UDim.new(0, 2);


-- StarterGui.AdminUI.Commands.Container.List.TextLabel
G2L["1d"] = Instance.new("TextLabel", G2L["1b"]);
G2L["1d"]["TextWrapped"] = true;
G2L["1d"]["TextSize"] = 15;
G2L["1d"]["TextScaled"] = true;
G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["1d"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["1d"]["BackgroundTransparency"] = 1;
G2L["1d"]["Size"] = UDim2.new(1, 0, 0, 20);
G2L["1d"]["Text"] = [[example <player> <text>]];
G2L["1d"]["Position"] = UDim2.new(0, 0, 0.01739, 0);


-- StarterGui.AdminUI.Commands.Container.Filter
G2L["1e"] = Instance.new("TextBox", G2L["1a"]);
G2L["1e"]["Name"] = [[Filter]];
G2L["1e"]["PlaceholderColor3"] = Color3.fromRGB(126, 126, 126);
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["TextSize"] = 18;
G2L["1e"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(6, 6, 6);
G2L["1e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["1e"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["1e"]["PlaceholderText"] = [[Filter commands...]];
G2L["1e"]["Size"] = UDim2.new(1, -10, 0, 20);
G2L["1e"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["1e"]["Text"] = [[]];
G2L["1e"]["BackgroundTransparency"] = 0.7;


-- StarterGui.AdminUI.Commands.Container.Filter.UICorner
G2L["1f"] = Instance.new("UICorner", G2L["1e"]);
G2L["1f"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.Commands.Container.UICorner
G2L["20"] = Instance.new("UICorner", G2L["1a"]);
G2L["20"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.Commands.Container.UIGradient
G2L["21"] = Instance.new("UIGradient", G2L["1a"]);
G2L["21"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(14, 6, 22))};


-- StarterGui.AdminUI.Commands.Topbar
G2L["22"] = Instance.new("Frame", G2L["19"]);
G2L["22"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["22"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["22"]["Name"] = [[Topbar]];
G2L["22"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Commands.Topbar.Exit
G2L["23"] = Instance.new("TextButton", G2L["22"]);
G2L["23"]["TextWrapped"] = true;
G2L["23"]["BorderSizePixel"] = 0;
G2L["23"]["TextSize"] = 13;
G2L["23"]["TextScaled"] = true;
G2L["23"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["23"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["23"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["23"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["23"]["BackgroundTransparency"] = 0.5;
G2L["23"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["23"]["Text"] = [[X]];
G2L["23"]["Name"] = [[Exit]];
G2L["23"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.Commands.Topbar.Exit.UICorners
G2L["24"] = Instance.new("UICorner", G2L["23"]);
G2L["24"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.Commands.Topbar.Exit.UIStroker
G2L["25"] = Instance.new("UIStroke", G2L["23"]);
G2L["25"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["25"]["Name"] = [[UIStroker]];
G2L["25"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.Commands.Topbar.Minimize
G2L["26"] = Instance.new("TextButton", G2L["22"]);
G2L["26"]["TextWrapped"] = true;
G2L["26"]["BorderSizePixel"] = 0;
G2L["26"]["TextSize"] = 13;
G2L["26"]["TextScaled"] = true;
G2L["26"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["26"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["26"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["26"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["26"]["BackgroundTransparency"] = 0.5;
G2L["26"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["26"]["Text"] = [[-]];
G2L["26"]["Name"] = [[Minimize]];
G2L["26"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.Commands.Topbar.Minimize.UICorners
G2L["27"] = Instance.new("UICorner", G2L["26"]);
G2L["27"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.Commands.Topbar.Minimize.UIStroker
G2L["28"] = Instance.new("UIStroke", G2L["26"]);
G2L["28"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["28"]["Name"] = [[UIStroker]];
G2L["28"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.Commands.Topbar.Title
G2L["29"] = Instance.new("TextLabel", G2L["22"]);
G2L["29"]["TextWrapped"] = true;
G2L["29"]["BorderSizePixel"] = 0;
G2L["29"]["TextSize"] = 17;
G2L["29"]["TextScaled"] = true;
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["29"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["29"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["29"]["BackgroundTransparency"] = 1;
G2L["29"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["29"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["29"]["Text"] = [[Commands]];
G2L["29"]["Name"] = [[Title]];
G2L["29"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.Commands.UICorners
G2L["2a"] = Instance.new("UICorner", G2L["19"]);
G2L["2a"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.Commands.UIStroker
G2L["2b"] = Instance.new("UIStroke", G2L["19"]);
G2L["2b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["2b"]["Name"] = [[UIStroker]];
G2L["2b"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.Commands.UIGradients
G2L["2c"] = Instance.new("UIGradient", G2L["19"]);
G2L["2c"]["Name"] = [[UIGradients]];
G2L["2c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.Resizeable
G2L["2d"] = Instance.new("Frame", G2L["1"]);
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2d"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["2d"]["Name"] = [[Resizeable]];
G2L["2d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Left
G2L["2e"] = Instance.new("Frame", G2L["2d"]);
G2L["2e"]["BorderSizePixel"] = 0;
G2L["2e"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["2e"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["2e"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["2e"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["2e"]["Name"] = [[Left]];
G2L["2e"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Right
G2L["2f"] = Instance.new("Frame", G2L["2d"]);
G2L["2f"]["BorderSizePixel"] = 0;
G2L["2f"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["2f"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["2f"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["2f"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["2f"]["Name"] = [[Right]];
G2L["2f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Top
G2L["30"] = Instance.new("Frame", G2L["2d"]);
G2L["30"]["BorderSizePixel"] = 0;
G2L["30"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["30"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["30"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["30"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["30"]["Name"] = [[Top]];
G2L["30"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Bottom
G2L["31"] = Instance.new("Frame", G2L["2d"]);
G2L["31"]["BorderSizePixel"] = 0;
G2L["31"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["31"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["31"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["31"]["Position"] = UDim2.new(0.5, 0, 1, 0);
G2L["31"]["Name"] = [[Bottom]];
G2L["31"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopLeft
G2L["32"] = Instance.new("Frame", G2L["2d"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["32"]["AnchorPoint"] = Vector2.new(1, 1);
G2L["32"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["32"]["Position"] = UDim2.new(0, 4, 0, 4);
G2L["32"]["Name"] = [[TopLeft]];
G2L["32"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopRight
G2L["33"] = Instance.new("Frame", G2L["2d"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["33"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["33"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["33"]["Position"] = UDim2.new(1, -4, 0, 4);
G2L["33"]["Name"] = [[TopRight]];
G2L["33"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomLeft
G2L["34"] = Instance.new("Frame", G2L["2d"]);
G2L["34"]["BorderSizePixel"] = 0;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["34"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["34"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["34"]["Position"] = UDim2.new(0, 4, 1, -4);
G2L["34"]["Name"] = [[BottomLeft]];
G2L["34"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomRight
G2L["35"] = Instance.new("Frame", G2L["2d"]);
G2L["35"]["BorderSizePixel"] = 0;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(0, 202, 255);
G2L["35"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["35"]["Position"] = UDim2.new(1, -4, 1, -4);
G2L["35"]["Name"] = [[BottomRight]];
G2L["35"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Description
G2L["36"] = Instance.new("TextLabel", G2L["1"]);
G2L["36"]["TextWrapped"] = true;
G2L["36"]["TextSize"] = 13;
G2L["36"]["TextScaled"] = true;
G2L["36"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["36"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["36"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["36"]["BackgroundTransparency"] = 0.3;
G2L["36"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["36"]["Size"] = UDim2.new(0, 191, 0, 26);
G2L["36"]["Visible"] = false;
G2L["36"]["BorderColor3"] = Color3.fromRGB(55, 55, 55);
G2L["36"]["Text"] = [[Name]];
G2L["36"]["Name"] = [[Description]];


-- StarterGui.AdminUI.Description.UICorner
G2L["37"] = Instance.new("UICorner", G2L["36"]);



-- StarterGui.AdminUI.UpdLog
G2L["38"] = Instance.new("Frame", G2L["1"]);
G2L["38"]["BorderSizePixel"] = 0;
G2L["38"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["38"]["Size"] = UDim2.new(0, 283, 0, 286);
G2L["38"]["Position"] = UDim2.new(0.61871, 0, 0.03718, 0);
G2L["38"]["BorderColor3"] = Color3.fromRGB(141, 141, 141);
G2L["38"]["Name"] = [[UpdLog]];
G2L["38"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.UpdLog.Container
G2L["39"] = Instance.new("Frame", G2L["38"]);
G2L["39"]["BorderSizePixel"] = 0;
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["39"]["ClipsDescendants"] = true;
G2L["39"]["Size"] = UDim2.new(1, -10, 1.01154, -30);
G2L["39"]["Position"] = UDim2.new(0.5, 0, 1, -5);
G2L["39"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["Name"] = [[Container]];
G2L["39"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.UpdLog.Container.List
G2L["3a"] = Instance.new("ScrollingFrame", G2L["39"]);
G2L["3a"]["BorderSizePixel"] = 0;
G2L["3a"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["3a"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3a"]["Name"] = [[List]];
G2L["3a"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["3a"]["Size"] = UDim2.new(1, -10, 1.08012, -27);
G2L["3a"]["Position"] = UDim2.new(0, 6, 0, 6);
G2L["3a"]["BorderColor3"] = Color3.fromRGB(18, 18, 18);
G2L["3a"]["ScrollBarThickness"] = 4;
G2L["3a"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.UpdLog.Container.List.UIListLayout
G2L["3b"] = Instance.new("UIListLayout", G2L["3a"]);
G2L["3b"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["3b"]["Padding"] = UDim.new(0, 2);


-- StarterGui.AdminUI.UpdLog.Container.List.
G2L["3c"] = Instance.new("TextLabel", G2L["3a"]);
G2L["3c"]["TextWrapped"] = true;
G2L["3c"]["BorderSizePixel"] = 0;
G2L["3c"]["TextSize"] = 14;
G2L["3c"]["TextScaled"] = true;
G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["3c"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["3c"]["BackgroundTransparency"] = 1;
G2L["3c"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["3c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3c"]["Text"] = [[- log 1 thingy]];
G2L["3c"]["Name"] = [[]];


-- StarterGui.AdminUI.UpdLog.Container.UICorner
G2L["3d"] = Instance.new("UICorner", G2L["39"]);
G2L["3d"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.UpdLog.Container.UIGradient
G2L["3e"] = Instance.new("UIGradient", G2L["39"]);
G2L["3e"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(14, 6, 22))};


-- StarterGui.AdminUI.UpdLog.Topbar
G2L["3f"] = Instance.new("Frame", G2L["38"]);
G2L["3f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3f"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["3f"]["Name"] = [[Topbar]];
G2L["3f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.UpdLog.Topbar.Exit
G2L["40"] = Instance.new("TextButton", G2L["3f"]);
G2L["40"]["TextWrapped"] = true;
G2L["40"]["BorderSizePixel"] = 0;
G2L["40"]["TextSize"] = 13;
G2L["40"]["TextScaled"] = true;
G2L["40"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["40"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["40"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["40"]["BackgroundTransparency"] = 0.5;
G2L["40"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["40"]["Text"] = [[X]];
G2L["40"]["Name"] = [[Exit]];
G2L["40"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.UpdLog.Topbar.Exit.UICorners
G2L["41"] = Instance.new("UICorner", G2L["40"]);
G2L["41"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.UpdLog.Topbar.Exit.UIStroker
G2L["42"] = Instance.new("UIStroke", G2L["40"]);
G2L["42"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["42"]["Name"] = [[UIStroker]];
G2L["42"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.UpdLog.Topbar.Minimize
G2L["43"] = Instance.new("TextButton", G2L["3f"]);
G2L["43"]["TextWrapped"] = true;
G2L["43"]["BorderSizePixel"] = 0;
G2L["43"]["TextSize"] = 13;
G2L["43"]["TextScaled"] = true;
G2L["43"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["43"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["43"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["43"]["BackgroundTransparency"] = 0.5;
G2L["43"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["43"]["Text"] = [[-]];
G2L["43"]["Name"] = [[Minimize]];
G2L["43"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.UpdLog.Topbar.Minimize.UICorners
G2L["44"] = Instance.new("UICorner", G2L["43"]);
G2L["44"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.UpdLog.Topbar.Minimize.UIStroker
G2L["45"] = Instance.new("UIStroke", G2L["43"]);
G2L["45"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["45"]["Name"] = [[UIStroker]];
G2L["45"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.UpdLog.Topbar.Title
G2L["46"] = Instance.new("TextLabel", G2L["3f"]);
G2L["46"]["TextWrapped"] = true;
G2L["46"]["BorderSizePixel"] = 0;
G2L["46"]["TextSize"] = 17;
G2L["46"]["TextScaled"] = true;
G2L["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["46"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["46"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["46"]["BackgroundTransparency"] = 1;
G2L["46"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["46"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["46"]["Text"] = [[Update Log]];
G2L["46"]["Name"] = [[Title]];
G2L["46"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.UpdLog.UICorners
G2L["47"] = Instance.new("UICorner", G2L["38"]);
G2L["47"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.UpdLog.UIStroker
G2L["48"] = Instance.new("UIStroke", G2L["38"]);
G2L["48"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["48"]["Name"] = [[UIStroker]];
G2L["48"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.UpdLog.UIGradients
G2L["49"] = Instance.new("UIGradient", G2L["38"]);
G2L["49"]["Name"] = [[UIGradients]];
G2L["49"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.ChatLogs
G2L["4a"] = Instance.new("Frame", G2L["1"]);
G2L["4a"]["BorderSizePixel"] = 0;
G2L["4a"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["4a"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["4a"]["Position"] = UDim2.new(0.65118, 0, 0.56114, 0);
G2L["4a"]["BorderColor3"] = Color3.fromRGB(141, 141, 141);
G2L["4a"]["Name"] = [[ChatLogs]];
G2L["4a"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.ChatLogs.Container
G2L["4b"] = Instance.new("Frame", G2L["4a"]);
G2L["4b"]["BorderSizePixel"] = 0;
G2L["4b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4b"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["4b"]["ClipsDescendants"] = true;
G2L["4b"]["Size"] = UDim2.new(1, -10, 1.00769, -30);
G2L["4b"]["Position"] = UDim2.new(0.49502, 0, 1.00379, -5);
G2L["4b"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4b"]["Name"] = [[Container]];
G2L["4b"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.ChatLogs.Container.Logs
G2L["4c"] = Instance.new("ScrollingFrame", G2L["4b"]);
G2L["4c"]["BorderSizePixel"] = 0;
G2L["4c"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["4c"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["4c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4c"]["Name"] = [[Logs]];
G2L["4c"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["4c"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4c"]["Size"] = UDim2.new(1, -10, 1, -10);
G2L["4c"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["4c"]["BorderColor3"] = Color3.fromRGB(18, 18, 18);
G2L["4c"]["ScrollBarThickness"] = 4;
G2L["4c"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.UIListLayout
G2L["4d"] = Instance.new("UIListLayout", G2L["4c"]);
G2L["4d"]["Padding"] = UDim.new(0, 3);
G2L["4d"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.TextLabel
G2L["4e"] = Instance.new("TextLabel", G2L["4c"]);
G2L["4e"]["TextWrapped"] = true;
G2L["4e"]["TextSize"] = 14;
G2L["4e"]["TextScaled"] = true;
G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["4e"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["4e"]["BackgroundTransparency"] = 1;
G2L["4e"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["4e"]["Text"] = [[[Roblox]: Hello,World!]];


-- StarterGui.AdminUI.ChatLogs.Container.UICorner
G2L["4f"] = Instance.new("UICorner", G2L["4b"]);
G2L["4f"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.ChatLogs.Container.UIGradient
G2L["50"] = Instance.new("UIGradient", G2L["4b"]);
G2L["50"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(14, 6, 22))};


-- StarterGui.AdminUI.ChatLogs.Topbar
G2L["51"] = Instance.new("Frame", G2L["4a"]);
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["51"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["51"]["Name"] = [[Topbar]];
G2L["51"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit
G2L["52"] = Instance.new("TextButton", G2L["51"]);
G2L["52"]["TextWrapped"] = true;
G2L["52"]["BorderSizePixel"] = 0;
G2L["52"]["TextSize"] = 13;
G2L["52"]["TextScaled"] = true;
G2L["52"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["52"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["52"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["52"]["BackgroundTransparency"] = 0.5;
G2L["52"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["52"]["Text"] = [[X]];
G2L["52"]["Name"] = [[Exit]];
G2L["52"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UICorners
G2L["53"] = Instance.new("UICorner", G2L["52"]);
G2L["53"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UIStroker
G2L["54"] = Instance.new("UIStroke", G2L["52"]);
G2L["54"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["54"]["Name"] = [[UIStroker]];
G2L["54"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize
G2L["55"] = Instance.new("TextButton", G2L["51"]);
G2L["55"]["TextWrapped"] = true;
G2L["55"]["BorderSizePixel"] = 0;
G2L["55"]["TextSize"] = 18;
G2L["55"]["TextScaled"] = true;
G2L["55"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["55"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["55"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["55"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["55"]["BackgroundTransparency"] = 0.5;
G2L["55"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["55"]["Text"] = [[-]];
G2L["55"]["Name"] = [[Minimize]];
G2L["55"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UICorners
G2L["56"] = Instance.new("UICorner", G2L["55"]);
G2L["56"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UIStroker
G2L["57"] = Instance.new("UIStroke", G2L["55"]);
G2L["57"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["57"]["Name"] = [[UIStroker]];
G2L["57"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear
G2L["58"] = Instance.new("TextButton", G2L["51"]);
G2L["58"]["TextWrapped"] = true;
G2L["58"]["BorderSizePixel"] = 0;
G2L["58"]["TextSize"] = 13;
G2L["58"]["TextScaled"] = true;
G2L["58"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["58"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["58"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["58"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["58"]["BackgroundTransparency"] = 0.5;
G2L["58"]["Size"] = UDim2.new(0, 48, 1, -8);
G2L["58"]["Text"] = [[Clear]];
G2L["58"]["Name"] = [[Clear]];
G2L["58"]["Position"] = UDim2.new(0, 4, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UIStroker
G2L["59"] = Instance.new("UIStroke", G2L["58"]);
G2L["59"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["59"]["Name"] = [[UIStroker]];
G2L["59"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UICorners
G2L["5a"] = Instance.new("UICorner", G2L["58"]);
G2L["5a"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Title
G2L["5b"] = Instance.new("TextLabel", G2L["51"]);
G2L["5b"]["TextWrapped"] = true;
G2L["5b"]["BorderSizePixel"] = 0;
G2L["5b"]["TextSize"] = 17;
G2L["5b"]["TextScaled"] = true;
G2L["5b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5b"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["5b"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["5b"]["BackgroundTransparency"] = 1;
G2L["5b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["5b"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["5b"]["Text"] = [[Chat Logs]];
G2L["5b"]["Name"] = [[Title]];
G2L["5b"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.UICorners
G2L["5c"] = Instance.new("UICorner", G2L["4a"]);
G2L["5c"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.UIStroker
G2L["5d"] = Instance.new("UIStroke", G2L["4a"]);
G2L["5d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["5d"]["Name"] = [[UIStroker]];
G2L["5d"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.ChatLogs.UIGradients
G2L["5e"] = Instance.new("UIGradient", G2L["4a"]);
G2L["5e"]["Name"] = [[UIGradients]];
G2L["5e"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.soRealConsole
G2L["5f"] = Instance.new("Frame", G2L["1"]);
G2L["5f"]["BorderSizePixel"] = 0;
G2L["5f"]["BackgroundColor3"] = Color3.fromRGB(27, 28, 32);
G2L["5f"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["5f"]["Position"] = UDim2.new(0.31784, 0, 0.55079, 0);
G2L["5f"]["BorderColor3"] = Color3.fromRGB(141, 141, 141);
G2L["5f"]["Name"] = [[soRealConsole]];
G2L["5f"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.soRealConsole.Container
G2L["60"] = Instance.new("Frame", G2L["5f"]);
G2L["60"]["BorderSizePixel"] = 0;
G2L["60"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["60"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["60"]["ClipsDescendants"] = true;
G2L["60"]["Size"] = UDim2.new(1, -10, 1.00769, -30);
G2L["60"]["Position"] = UDim2.new(0.49502, 0, 1.00379, -5);
G2L["60"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["60"]["Name"] = [[Container]];
G2L["60"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.soRealConsole.Container.Logs
G2L["61"] = Instance.new("ScrollingFrame", G2L["60"]);
G2L["61"]["BorderSizePixel"] = 0;
G2L["61"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["61"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["61"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["61"]["Name"] = [[Logs]];
G2L["61"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["61"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["61"]["Size"] = UDim2.new(1, -10, 0.9, -35);
G2L["61"]["Position"] = UDim2.new(0.5, 0, 0.62, 0);
G2L["61"]["BorderColor3"] = Color3.fromRGB(18, 18, 18);
G2L["61"]["ScrollBarThickness"] = 4;
G2L["61"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.UIListLayout
G2L["62"] = Instance.new("UIListLayout", G2L["61"]);
G2L["62"]["Padding"] = UDim.new(0, 3);
G2L["62"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.TextLabel
G2L["63"] = Instance.new("TextLabel", G2L["61"]);
G2L["63"]["TextWrapped"] = true;
G2L["63"]["TextSize"] = 14;
G2L["63"]["TextScaled"] = true;
G2L["63"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["63"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["63"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["63"]["BackgroundTransparency"] = 1;
G2L["63"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["63"]["Text"] = [[[Output]: failed print 1]];


-- StarterGui.AdminUI.soRealConsole.Container.UICorner
G2L["64"] = Instance.new("UICorner", G2L["60"]);
G2L["64"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.soRealConsole.Container.UIGradient
G2L["65"] = Instance.new("UIGradient", G2L["60"]);
G2L["65"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(14, 6, 22)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(14, 6, 22))};


-- StarterGui.AdminUI.soRealConsole.Container.Filter
G2L["66"] = Instance.new("TextBox", G2L["60"]);
G2L["66"]["Name"] = [[Filter]];
G2L["66"]["PlaceholderColor3"] = Color3.fromRGB(126, 126, 126);
G2L["66"]["BorderSizePixel"] = 0;
G2L["66"]["TextSize"] = 18;
G2L["66"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["66"]["BackgroundColor3"] = Color3.fromRGB(6, 6, 6);
G2L["66"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["66"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["66"]["PlaceholderText"] = [[Search...]];
G2L["66"]["Size"] = UDim2.new(1, -10, 0, 20);
G2L["66"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["66"]["Text"] = [[]];
G2L["66"]["BackgroundTransparency"] = 0.7;


-- StarterGui.AdminUI.soRealConsole.Container.Filter.UICorner
G2L["67"] = Instance.new("UICorner", G2L["66"]);
G2L["67"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.soRealConsole.Topbar
G2L["68"] = Instance.new("Frame", G2L["5f"]);
G2L["68"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["68"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["68"]["Name"] = [[Topbar]];
G2L["68"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit
G2L["69"] = Instance.new("TextButton", G2L["68"]);
G2L["69"]["TextWrapped"] = true;
G2L["69"]["BorderSizePixel"] = 0;
G2L["69"]["TextSize"] = 13;
G2L["69"]["TextScaled"] = true;
G2L["69"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["69"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["69"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["69"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["69"]["BackgroundTransparency"] = 0.5;
G2L["69"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["69"]["Text"] = [[X]];
G2L["69"]["Name"] = [[Exit]];
G2L["69"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UICorners
G2L["6a"] = Instance.new("UICorner", G2L["69"]);
G2L["6a"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UIStroker
G2L["6b"] = Instance.new("UIStroke", G2L["69"]);
G2L["6b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["6b"]["Name"] = [[UIStroker]];
G2L["6b"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize
G2L["6c"] = Instance.new("TextButton", G2L["68"]);
G2L["6c"]["TextWrapped"] = true;
G2L["6c"]["BorderSizePixel"] = 0;
G2L["6c"]["TextSize"] = 18;
G2L["6c"]["TextScaled"] = true;
G2L["6c"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["6c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["6c"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["6c"]["BackgroundTransparency"] = 0.5;
G2L["6c"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["6c"]["Text"] = [[-]];
G2L["6c"]["Name"] = [[Minimize]];
G2L["6c"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UICorners
G2L["6d"] = Instance.new("UICorner", G2L["6c"]);
G2L["6d"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UIStroker
G2L["6e"] = Instance.new("UIStroke", G2L["6c"]);
G2L["6e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["6e"]["Name"] = [[UIStroker]];
G2L["6e"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear
G2L["6f"] = Instance.new("TextButton", G2L["68"]);
G2L["6f"]["TextWrapped"] = true;
G2L["6f"]["BorderSizePixel"] = 0;
G2L["6f"]["TextSize"] = 13;
G2L["6f"]["TextScaled"] = true;
G2L["6f"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(14, 6, 22);
G2L["6f"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["6f"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["6f"]["BackgroundTransparency"] = 0.5;
G2L["6f"]["Size"] = UDim2.new(0, 48, 1, -8);
G2L["6f"]["Text"] = [[Clear]];
G2L["6f"]["Name"] = [[Clear]];
G2L["6f"]["Position"] = UDim2.new(0, 4, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UICorners
G2L["70"] = Instance.new("UICorner", G2L["6f"]);
G2L["70"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UIStroker
G2L["71"] = Instance.new("UIStroke", G2L["6f"]);
G2L["71"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["71"]["Name"] = [[UIStroker]];
G2L["71"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Title
G2L["72"] = Instance.new("TextLabel", G2L["68"]);
G2L["72"]["TextWrapped"] = true;
G2L["72"]["BorderSizePixel"] = 0;
G2L["72"]["TextSize"] = 17;
G2L["72"]["TextScaled"] = true;
G2L["72"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["72"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["72"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["72"]["BackgroundTransparency"] = 1;
G2L["72"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["72"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["72"]["Text"] = [[NA Console]];
G2L["72"]["Name"] = [[Title]];
G2L["72"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.UICorners
G2L["73"] = Instance.new("UICorner", G2L["5f"]);
G2L["73"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.UIStroker
G2L["74"] = Instance.new("UIStroke", G2L["5f"]);
G2L["74"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["74"]["Name"] = [[UIStroker]];
G2L["74"]["Color"] = Color3.fromRGB(147, 92, 255);


-- StarterGui.AdminUI.soRealConsole.UIGradients
G2L["75"] = Instance.new("UIGradient", G2L["5f"]);
G2L["75"]["Name"] = [[UIGradients]];
G2L["75"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(42, 42, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(20, 20, 24))};


-- StarterGui.AdminUI.Modal
G2L["76"] = Instance.new("ImageButton", G2L["1"]);
G2L["76"]["BackgroundTransparency"] = 1;
G2L["76"]["Name"] = [[Modal]];



return G2L["1"];