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
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["5"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(32, 32, 32);
G2L["5"]["Name"] = [[Horizontal]];
G2L["5"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UICorners
G2L["6"] = Instance.new("UICorner", G2L["5"]);
G2L["6"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UIGradients
G2L["7"] = Instance.new("UIGradient", G2L["5"]);
G2L["7"]["Name"] = [[UIGradients]];
G2L["7"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};


-- StarterGui.AdminUI.CmdBar.CenterBar.Input
G2L["8"] = Instance.new("TextBox", G2L["4"]);
G2L["8"]["CursorPosition"] = -1;
G2L["8"]["Active"] = false;
G2L["8"]["Name"] = [[Input]];
G2L["8"]["ZIndex"] = 2;
G2L["8"]["TextWrapped"] = true;
G2L["8"]["TextSize"] = 24;
G2L["8"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
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
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["a"]["Size"] = UDim2.new(1.00599, 0, 1, 0);
G2L["a"]["BorderColor3"] = Color3.fromRGB(32, 32, 32);
G2L["a"]["Name"] = [[Horizontal]];
G2L["a"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UICorners
G2L["b"] = Instance.new("UICorner", G2L["a"]);
G2L["b"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UIGradients
G2L["c"] = Instance.new("UIGradient", G2L["a"]);
G2L["c"]["Name"] = [[UIGradients]];
G2L["c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};


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
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["e"]["Size"] = UDim2.new(1.00798, 0, 1, 0);
G2L["e"]["Position"] = UDim2.new(-0.00798, 0, 0, 0);
G2L["e"]["BorderColor3"] = Color3.fromRGB(32, 32, 32);
G2L["e"]["Name"] = [[Horizontal]];
G2L["e"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UICorners
G2L["f"] = Instance.new("UICorner", G2L["e"]);
G2L["f"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UIGradients
G2L["10"] = Instance.new("UIGradient", G2L["e"]);
G2L["10"]["Name"] = [[UIGradients]];
G2L["10"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};


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
G2L["13"]["BackgroundColor3"] = Color3.fromRGB(22, 22, 22);
G2L["13"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["13"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
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
G2L["15"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["15"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["15"]["Name"] = [[Horizontal]];
G2L["15"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UICorners
G2L["16"] = Instance.new("UICorner", G2L["15"]);
G2L["16"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UIGradients
G2L["17"] = Instance.new("UIGradient", G2L["15"]);
G2L["17"]["Name"] = [[UIGradients]];
G2L["17"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};


-- StarterGui.AdminUI.CmdBar.Autofill.UIListLayout
G2L["18"] = Instance.new("UIListLayout", G2L["11"]);
G2L["18"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["18"]["Padding"] = UDim.new(0, 3);
G2L["18"]["VerticalAlignment"] = Enum.VerticalAlignment.Bottom;
G2L["18"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.Commands
G2L["19"] = Instance.new("Frame", G2L["1"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["19"]["Size"] = UDim2.new(0, 283, 0, 286);
G2L["19"]["Position"] = UDim2.new(0.22203, 0, 0.01264, 0);
G2L["19"]["BorderColor3"] = Color3.fromRGB(144, 144, 144);
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
G2L["1b"]["BorderColor3"] = Color3.fromRGB(21, 21, 21);
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
G2L["1d"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["1d"]["BackgroundTransparency"] = 1;
G2L["1d"]["Size"] = UDim2.new(1, 0, 0, 20);
G2L["1d"]["Text"] = [[example <player> <text>]];
G2L["1d"]["Position"] = UDim2.new(0, 0, 0.01739, 0);


-- StarterGui.AdminUI.Commands.Container.Filter
G2L["1e"] = Instance.new("TextBox", G2L["1a"]);
G2L["1e"]["Name"] = [[Filter]];
G2L["1e"]["PlaceholderColor3"] = Color3.fromRGB(129, 129, 129);
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["TextSize"] = 18;
G2L["1e"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(9, 9, 9);
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
G2L["21"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(17, 9, 25))};


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
G2L["23"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["23"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
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
G2L["25"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.Commands.Topbar.Minimize
G2L["26"] = Instance.new("TextButton", G2L["22"]);
G2L["26"]["TextWrapped"] = true;
G2L["26"]["BorderSizePixel"] = 0;
G2L["26"]["TextSize"] = 13;
G2L["26"]["TextScaled"] = true;
G2L["26"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["26"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
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
G2L["28"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.Commands.Topbar.Title
G2L["29"] = Instance.new("TextLabel", G2L["22"]);
G2L["29"]["TextWrapped"] = true;
G2L["29"]["BorderSizePixel"] = 0;
G2L["29"]["TextSize"] = 17;
G2L["29"]["TextScaled"] = true;
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["29"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["29"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
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
G2L["2b"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.Commands.UIGradients
G2L["2c"] = Instance.new("UIGradient", G2L["19"]);
G2L["2c"]["Name"] = [[UIGradients]];
G2L["2c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};


-- StarterGui.AdminUI.Resizeable
G2L["2d"] = Instance.new("Frame", G2L["1"]);
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2d"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["2d"]["Name"] = [[Resizeable]];
G2L["2d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Left
G2L["2e"] = Instance.new("Frame", G2L["2d"]);
G2L["2e"]["BorderSizePixel"] = 0;
G2L["2e"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["2e"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["2e"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["2e"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["2e"]["Name"] = [[Left]];
G2L["2e"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Right
G2L["2f"] = Instance.new("Frame", G2L["2d"]);
G2L["2f"]["BorderSizePixel"] = 0;
G2L["2f"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["2f"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["2f"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["2f"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["2f"]["Name"] = [[Right]];
G2L["2f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Top
G2L["30"] = Instance.new("Frame", G2L["2d"]);
G2L["30"]["BorderSizePixel"] = 0;
G2L["30"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["30"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["30"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["30"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["30"]["Name"] = [[Top]];
G2L["30"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Bottom
G2L["31"] = Instance.new("Frame", G2L["2d"]);
G2L["31"]["BorderSizePixel"] = 0;
G2L["31"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["31"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["31"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["31"]["Position"] = UDim2.new(0.5, 0, 1, 0);
G2L["31"]["Name"] = [[Bottom]];
G2L["31"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopLeft
G2L["32"] = Instance.new("Frame", G2L["2d"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["32"]["AnchorPoint"] = Vector2.new(1, 1);
G2L["32"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["32"]["Position"] = UDim2.new(0, 4, 0, 4);
G2L["32"]["Name"] = [[TopLeft]];
G2L["32"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopRight
G2L["33"] = Instance.new("Frame", G2L["2d"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["33"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["33"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["33"]["Position"] = UDim2.new(1, -4, 0, 4);
G2L["33"]["Name"] = [[TopRight]];
G2L["33"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomLeft
G2L["34"] = Instance.new("Frame", G2L["2d"]);
G2L["34"]["BorderSizePixel"] = 0;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["34"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["34"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["34"]["Position"] = UDim2.new(0, 4, 1, -4);
G2L["34"]["Name"] = [[BottomLeft]];
G2L["34"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomRight
G2L["35"] = Instance.new("Frame", G2L["2d"]);
G2L["35"]["BorderSizePixel"] = 0;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(0, 205, 255);
G2L["35"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["35"]["Position"] = UDim2.new(1, -4, 1, -4);
G2L["35"]["Name"] = [[BottomRight]];
G2L["35"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Description
G2L["36"] = Instance.new("TextLabel", G2L["1"]);
G2L["36"]["TextWrapped"] = true;
G2L["36"]["TextSize"] = 13;
G2L["36"]["TextScaled"] = true;
G2L["36"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["36"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["36"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["36"]["BackgroundTransparency"] = 0.3;
G2L["36"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["36"]["Size"] = UDim2.new(0, 191, 0, 26);
G2L["36"]["Visible"] = false;
G2L["36"]["BorderColor3"] = Color3.fromRGB(58, 58, 58);
G2L["36"]["Text"] = [[Name]];
G2L["36"]["Name"] = [[Description]];


-- StarterGui.AdminUI.Description.UICorner
G2L["37"] = Instance.new("UICorner", G2L["36"]);



-- StarterGui.AdminUI.ChatLogs
G2L["38"] = Instance.new("Frame", G2L["1"]);
G2L["38"]["BorderSizePixel"] = 0;
G2L["38"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["38"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["38"]["Position"] = UDim2.new(0.65118, 0, 0.56114, 0);
G2L["38"]["BorderColor3"] = Color3.fromRGB(144, 144, 144);
G2L["38"]["Name"] = [[ChatLogs]];
G2L["38"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.ChatLogs.Container
G2L["39"] = Instance.new("Frame", G2L["38"]);
G2L["39"]["BorderSizePixel"] = 0;
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["39"]["ClipsDescendants"] = true;
G2L["39"]["Size"] = UDim2.new(1, -10, 1.00769, -30);
G2L["39"]["Position"] = UDim2.new(0.49502, 0, 1.00379, -5);
G2L["39"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["Name"] = [[Container]];
G2L["39"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.ChatLogs.Container.Logs
G2L["3a"] = Instance.new("ScrollingFrame", G2L["39"]);
G2L["3a"]["BorderSizePixel"] = 0;
G2L["3a"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["3a"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3a"]["Name"] = [[Logs]];
G2L["3a"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["3a"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3a"]["Size"] = UDim2.new(1, -10, 1, -10);
G2L["3a"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["3a"]["BorderColor3"] = Color3.fromRGB(21, 21, 21);
G2L["3a"]["ScrollBarThickness"] = 4;
G2L["3a"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.UIListLayout
G2L["3b"] = Instance.new("UIListLayout", G2L["3a"]);
G2L["3b"]["Padding"] = UDim.new(0, 3);
G2L["3b"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.TextLabel
G2L["3c"] = Instance.new("TextLabel", G2L["3a"]);
G2L["3c"]["TextWrapped"] = true;
G2L["3c"]["TextSize"] = 14;
G2L["3c"]["TextScaled"] = true;
G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["3c"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["3c"]["BackgroundTransparency"] = 1;
G2L["3c"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["3c"]["Text"] = [[[Roblox]: Hello,World!]];


-- StarterGui.AdminUI.ChatLogs.Container.UICorner
G2L["3d"] = Instance.new("UICorner", G2L["39"]);
G2L["3d"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.ChatLogs.Container.UIGradient
G2L["3e"] = Instance.new("UIGradient", G2L["39"]);
G2L["3e"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(17, 9, 25))};


-- StarterGui.AdminUI.ChatLogs.Topbar
G2L["3f"] = Instance.new("Frame", G2L["38"]);
G2L["3f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3f"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["3f"]["Name"] = [[Topbar]];
G2L["3f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit
G2L["40"] = Instance.new("TextButton", G2L["3f"]);
G2L["40"]["TextWrapped"] = true;
G2L["40"]["BorderSizePixel"] = 0;
G2L["40"]["TextSize"] = 13;
G2L["40"]["TextScaled"] = true;
G2L["40"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["40"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["40"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["40"]["BackgroundTransparency"] = 0.5;
G2L["40"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["40"]["Text"] = [[X]];
G2L["40"]["Name"] = [[Exit]];
G2L["40"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UICorners
G2L["41"] = Instance.new("UICorner", G2L["40"]);
G2L["41"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UIStroker
G2L["42"] = Instance.new("UIStroke", G2L["40"]);
G2L["42"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["42"]["Name"] = [[UIStroker]];
G2L["42"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize
G2L["43"] = Instance.new("TextButton", G2L["3f"]);
G2L["43"]["TextWrapped"] = true;
G2L["43"]["BorderSizePixel"] = 0;
G2L["43"]["TextSize"] = 18;
G2L["43"]["TextScaled"] = true;
G2L["43"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["43"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["43"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["43"]["BackgroundTransparency"] = 0.5;
G2L["43"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["43"]["Text"] = [[-]];
G2L["43"]["Name"] = [[Minimize]];
G2L["43"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UICorners
G2L["44"] = Instance.new("UICorner", G2L["43"]);
G2L["44"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UIStroker
G2L["45"] = Instance.new("UIStroke", G2L["43"]);
G2L["45"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["45"]["Name"] = [[UIStroker]];
G2L["45"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear
G2L["46"] = Instance.new("TextButton", G2L["3f"]);
G2L["46"]["TextWrapped"] = true;
G2L["46"]["BorderSizePixel"] = 0;
G2L["46"]["TextSize"] = 13;
G2L["46"]["TextScaled"] = true;
G2L["46"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["46"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["46"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["46"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["46"]["BackgroundTransparency"] = 0.5;
G2L["46"]["Size"] = UDim2.new(0, 48, 1, -8);
G2L["46"]["Text"] = [[Clear]];
G2L["46"]["Name"] = [[Clear]];
G2L["46"]["Position"] = UDim2.new(0, 4, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UIStroker
G2L["47"] = Instance.new("UIStroke", G2L["46"]);
G2L["47"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["47"]["Name"] = [[UIStroker]];
G2L["47"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UICorners
G2L["48"] = Instance.new("UICorner", G2L["46"]);
G2L["48"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Title
G2L["49"] = Instance.new("TextLabel", G2L["3f"]);
G2L["49"]["TextWrapped"] = true;
G2L["49"]["BorderSizePixel"] = 0;
G2L["49"]["TextSize"] = 17;
G2L["49"]["TextScaled"] = true;
G2L["49"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["49"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["49"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["49"]["BackgroundTransparency"] = 1;
G2L["49"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["49"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["49"]["Text"] = [[Chat Logs]];
G2L["49"]["Name"] = [[Title]];
G2L["49"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.UICorners
G2L["4a"] = Instance.new("UICorner", G2L["38"]);
G2L["4a"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.UIStroker
G2L["4b"] = Instance.new("UIStroke", G2L["38"]);
G2L["4b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["4b"]["Name"] = [[UIStroker]];
G2L["4b"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.ChatLogs.UIGradients
G2L["4c"] = Instance.new("UIGradient", G2L["38"]);
G2L["4c"]["Name"] = [[UIGradients]];
G2L["4c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};


-- StarterGui.AdminUI.soRealConsole
G2L["4d"] = Instance.new("Frame", G2L["1"]);
G2L["4d"]["BorderSizePixel"] = 0;
G2L["4d"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["4d"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["4d"]["Position"] = UDim2.new(0.63851, 0, 0.02945, 0);
G2L["4d"]["BorderColor3"] = Color3.fromRGB(144, 144, 144);
G2L["4d"]["Name"] = [[soRealConsole]];
G2L["4d"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.soRealConsole.Container
G2L["4e"] = Instance.new("Frame", G2L["4d"]);
G2L["4e"]["BorderSizePixel"] = 0;
G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4e"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["4e"]["ClipsDescendants"] = true;
G2L["4e"]["Size"] = UDim2.new(1, -10, 1.00769, -30);
G2L["4e"]["Position"] = UDim2.new(0.49502, 0, 1.00379, -5);
G2L["4e"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4e"]["Name"] = [[Container]];
G2L["4e"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.soRealConsole.Container.Logs
G2L["4f"] = Instance.new("ScrollingFrame", G2L["4e"]);
G2L["4f"]["BorderSizePixel"] = 0;
G2L["4f"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["4f"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["4f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4f"]["Name"] = [[Logs]];
G2L["4f"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["4f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4f"]["Size"] = UDim2.new(1, -10, 0.9, -35);
G2L["4f"]["Position"] = UDim2.new(0.5, 0, 0.62, 0);
G2L["4f"]["BorderColor3"] = Color3.fromRGB(21, 21, 21);
G2L["4f"]["ScrollBarThickness"] = 4;
G2L["4f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.UIListLayout
G2L["50"] = Instance.new("UIListLayout", G2L["4f"]);
G2L["50"]["Padding"] = UDim.new(0, 3);
G2L["50"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.TextLabel
G2L["51"] = Instance.new("TextLabel", G2L["4f"]);
G2L["51"]["TextWrapped"] = true;
G2L["51"]["TextSize"] = 14;
G2L["51"]["TextScaled"] = true;
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["51"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["51"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["51"]["BackgroundTransparency"] = 1;
G2L["51"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["51"]["Text"] = [[[Output]: failed print 1]];


-- StarterGui.AdminUI.soRealConsole.Container.UICorner
G2L["52"] = Instance.new("UICorner", G2L["4e"]);
G2L["52"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.soRealConsole.Container.UIGradient
G2L["53"] = Instance.new("UIGradient", G2L["4e"]);
G2L["53"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(17, 9, 25))};


-- StarterGui.AdminUI.soRealConsole.Container.Filter
G2L["54"] = Instance.new("TextBox", G2L["4e"]);
G2L["54"]["CursorPosition"] = -1;
G2L["54"]["Name"] = [[Filter]];
G2L["54"]["PlaceholderColor3"] = Color3.fromRGB(129, 129, 129);
G2L["54"]["BorderSizePixel"] = 0;
G2L["54"]["TextSize"] = 18;
G2L["54"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["54"]["BackgroundColor3"] = Color3.fromRGB(9, 9, 9);
G2L["54"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["54"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["54"]["PlaceholderText"] = [[Search...]];
G2L["54"]["Size"] = UDim2.new(1, -10, 0, 20);
G2L["54"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["54"]["Text"] = [[]];
G2L["54"]["BackgroundTransparency"] = 0.7;


-- StarterGui.AdminUI.soRealConsole.Container.Filter.UICorner
G2L["55"] = Instance.new("UICorner", G2L["54"]);
G2L["55"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.soRealConsole.Topbar
G2L["56"] = Instance.new("Frame", G2L["4d"]);
G2L["56"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["56"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["56"]["Name"] = [[Topbar]];
G2L["56"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit
G2L["57"] = Instance.new("TextButton", G2L["56"]);
G2L["57"]["TextWrapped"] = true;
G2L["57"]["BorderSizePixel"] = 0;
G2L["57"]["TextSize"] = 13;
G2L["57"]["TextScaled"] = true;
G2L["57"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["57"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["57"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["57"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["57"]["BackgroundTransparency"] = 0.5;
G2L["57"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["57"]["Text"] = [[X]];
G2L["57"]["Name"] = [[Exit]];
G2L["57"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UICorners
G2L["58"] = Instance.new("UICorner", G2L["57"]);
G2L["58"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UIStroker
G2L["59"] = Instance.new("UIStroke", G2L["57"]);
G2L["59"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["59"]["Name"] = [[UIStroker]];
G2L["59"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize
G2L["5a"] = Instance.new("TextButton", G2L["56"]);
G2L["5a"]["TextWrapped"] = true;
G2L["5a"]["BorderSizePixel"] = 0;
G2L["5a"]["TextSize"] = 18;
G2L["5a"]["TextScaled"] = true;
G2L["5a"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["5a"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["5a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["5a"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["5a"]["BackgroundTransparency"] = 0.5;
G2L["5a"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["5a"]["Text"] = [[-]];
G2L["5a"]["Name"] = [[Minimize]];
G2L["5a"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UICorners
G2L["5b"] = Instance.new("UICorner", G2L["5a"]);
G2L["5b"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UIStroker
G2L["5c"] = Instance.new("UIStroke", G2L["5a"]);
G2L["5c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["5c"]["Name"] = [[UIStroker]];
G2L["5c"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear
G2L["5d"] = Instance.new("TextButton", G2L["56"]);
G2L["5d"]["TextWrapped"] = true;
G2L["5d"]["BorderSizePixel"] = 0;
G2L["5d"]["TextSize"] = 13;
G2L["5d"]["TextScaled"] = true;
G2L["5d"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["5d"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["5d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["5d"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["5d"]["BackgroundTransparency"] = 0.5;
G2L["5d"]["Size"] = UDim2.new(0, 48, 1, -8);
G2L["5d"]["Text"] = [[Clear]];
G2L["5d"]["Name"] = [[Clear]];
G2L["5d"]["Position"] = UDim2.new(0, 4, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UICorners
G2L["5e"] = Instance.new("UICorner", G2L["5d"]);
G2L["5e"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UIStroker
G2L["5f"] = Instance.new("UIStroke", G2L["5d"]);
G2L["5f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["5f"]["Name"] = [[UIStroker]];
G2L["5f"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Title
G2L["60"] = Instance.new("TextLabel", G2L["56"]);
G2L["60"]["TextWrapped"] = true;
G2L["60"]["BorderSizePixel"] = 0;
G2L["60"]["TextSize"] = 17;
G2L["60"]["TextScaled"] = true;
G2L["60"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["60"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["60"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["60"]["BackgroundTransparency"] = 1;
G2L["60"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["60"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["60"]["Text"] = [[NA Console]];
G2L["60"]["Name"] = [[Title]];
G2L["60"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.UICorners
G2L["61"] = Instance.new("UICorner", G2L["4d"]);
G2L["61"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.UIStroker
G2L["62"] = Instance.new("UIStroke", G2L["4d"]);
G2L["62"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["62"]["Name"] = [[UIStroker]];
G2L["62"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.soRealConsole.UIGradients
G2L["63"] = Instance.new("UIGradient", G2L["4d"]);
G2L["63"]["Name"] = [[UIGradients]];
G2L["63"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};


-- StarterGui.AdminUI.Modal
G2L["64"] = Instance.new("ImageButton", G2L["1"]);
G2L["64"]["BackgroundTransparency"] = 1;
G2L["64"]["Name"] = [[Modal]];


-- StarterGui.AdminUI.setsettings
G2L["65"] = Instance.new("Frame", G2L["1"]);
G2L["65"]["BorderSizePixel"] = 0;
G2L["65"]["BackgroundColor3"] = Color3.fromRGB(30, 31, 35);
G2L["65"]["Size"] = UDim2.new(0, 510, 0, 355);
G2L["65"]["Position"] = UDim2.new(0.14365, 0, 0.51325, 0);
G2L["65"]["BorderColor3"] = Color3.fromRGB(144, 144, 144);
G2L["65"]["Name"] = [[setsettings]];
G2L["65"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.setsettings.Container
G2L["66"] = Instance.new("Frame", G2L["65"]);
G2L["66"]["BorderSizePixel"] = 0;
G2L["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["66"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["66"]["ClipsDescendants"] = true;
G2L["66"]["Size"] = UDim2.new(1, -10, 1.01154, -30);
G2L["66"]["Position"] = UDim2.new(0.5, 0, 1, -5);
G2L["66"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["66"]["Name"] = [[Container]];
G2L["66"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.setsettings.Container.List
G2L["67"] = Instance.new("ScrollingFrame", G2L["66"]);
G2L["67"]["BorderSizePixel"] = 0;
G2L["67"]["CanvasPosition"] = Vector2.new(0, 140);
G2L["67"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["67"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["67"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["67"]["Name"] = [[List]];
G2L["67"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["67"]["Size"] = UDim2.new(1, -10, 1.08012, -27);
G2L["67"]["Position"] = UDim2.new(0, 6, 0, 6);
G2L["67"]["BorderColor3"] = Color3.fromRGB(21, 21, 21);
G2L["67"]["ScrollBarThickness"] = 4;
G2L["67"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.UIListLayout
G2L["68"] = Instance.new("UIListLayout", G2L["67"]);
G2L["68"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["68"]["Padding"] = UDim.new(0, 2);
G2L["68"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.setsettings.Container.List.Toggle
G2L["69"] = Instance.new("Frame", G2L["67"]);
G2L["69"]["BorderSizePixel"] = 0;
G2L["69"]["BackgroundColor3"] = Color3.fromRGB(38, 38, 38);
G2L["69"]["Size"] = UDim2.new(1, -10, 0, 40);
G2L["69"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["69"]["Name"] = [[Toggle]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Title
G2L["6a"] = Instance.new("TextLabel", G2L["69"]);
G2L["6a"]["TextWrapped"] = true;
G2L["6a"]["BorderSizePixel"] = 0;
G2L["6a"]["TextSize"] = 14;
G2L["6a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["6a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["6a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["6a"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["6a"]["BackgroundTransparency"] = 1;
G2L["6a"]["RichText"] = true;
G2L["6a"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["6a"]["Size"] = UDim2.new(0, 178, 0, 14);
G2L["6a"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["6a"]["Text"] = [[random toggle]];
G2L["6a"]["Name"] = [[Title]];
G2L["6a"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Interact
G2L["6b"] = Instance.new("TextButton", G2L["69"]);
G2L["6b"]["BorderSizePixel"] = 0;
G2L["6b"]["TextTransparency"] = 1;
G2L["6b"]["TextSize"] = 14;
G2L["6b"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["6b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["6b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["6b"]["ZIndex"] = 5;
G2L["6b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["6b"]["BackgroundTransparency"] = 1;
G2L["6b"]["Size"] = UDim2.new(0.23715, 0, 1, 0);
G2L["6b"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["6b"]["Text"] = [[]];
G2L["6b"]["Name"] = [[Interact]];
G2L["6b"]["Position"] = UDim2.new(0.88143, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch
G2L["6c"] = Instance.new("Frame", G2L["69"]);
G2L["6c"]["BorderSizePixel"] = 0;
G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(33, 33, 33);
G2L["6c"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["6c"]["Size"] = UDim2.new(0, 43, 0, 21);
G2L["6c"]["Position"] = UDim2.new(1, -10, 0, 20);
G2L["6c"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["6c"]["Name"] = [[Switch]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.UICorner
G2L["6d"] = Instance.new("UICorner", G2L["6c"]);
G2L["6d"]["CornerRadius"] = UDim.new(0, 15);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.UIStroke
G2L["6e"] = Instance.new("UIStroke", G2L["6c"]);
G2L["6e"]["Color"] = Color3.fromRGB(68, 68, 68);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator
G2L["6f"] = Instance.new("Frame", G2L["6c"]);
G2L["6f"]["BorderSizePixel"] = 0;
G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(103, 103, 103);
G2L["6f"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["6f"]["Size"] = UDim2.new(0, 17, 0, 17);
G2L["6f"]["Position"] = UDim2.new(1, -40, 0.5, 0);
G2L["6f"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["6f"]["Name"] = [[Indicator]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator.UICorner
G2L["70"] = Instance.new("UICorner", G2L["6f"]);
G2L["70"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator.UIStroke
G2L["71"] = Instance.new("UIStroke", G2L["6f"]);
G2L["71"]["Thickness"] = 1.2;
G2L["71"]["Color"] = Color3.fromRGB(128, 128, 128);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.UICorner
G2L["72"] = Instance.new("UICorner", G2L["69"]);
G2L["72"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.UIStroke
G2L["73"] = Instance.new("UIStroke", G2L["69"]);
G2L["73"]["Color"] = Color3.fromRGB(52, 52, 52);


-- StarterGui.AdminUI.setsettings.Container.List.SectionTitle
G2L["74"] = Instance.new("Frame", G2L["67"]);
G2L["74"]["BorderSizePixel"] = 0;
G2L["74"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["74"]["Size"] = UDim2.new(1, 0, 0, 15);
G2L["74"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["74"]["Name"] = [[SectionTitle]];
G2L["74"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.SectionTitle.Title
G2L["75"] = Instance.new("TextLabel", G2L["74"]);
G2L["75"]["TextWrapped"] = true;
G2L["75"]["BorderSizePixel"] = 0;
G2L["75"]["TextSize"] = 14;
G2L["75"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["75"]["TextTransparency"] = 0.4;
G2L["75"]["TextScaled"] = true;
G2L["75"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["75"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["75"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["75"]["BackgroundTransparency"] = 1;
G2L["75"]["Size"] = UDim2.new(0.87474, 0, 0, 13);
G2L["75"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["75"]["Text"] = [[random title]];
G2L["75"]["Name"] = [[Title]];
G2L["75"]["Position"] = UDim2.new(0, 10, 0.1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button
G2L["76"] = Instance.new("Frame", G2L["67"]);
G2L["76"]["BorderSizePixel"] = 0;
G2L["76"]["BackgroundColor3"] = Color3.fromRGB(38, 38, 38);
G2L["76"]["Size"] = UDim2.new(1, -10, 0, 35);
G2L["76"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["76"]["Name"] = [[Button]];


-- StarterGui.AdminUI.setsettings.Container.List.Button.UICorner
G2L["77"] = Instance.new("UICorner", G2L["76"]);
G2L["77"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.Button.Title
G2L["78"] = Instance.new("TextLabel", G2L["76"]);
G2L["78"]["TextWrapped"] = true;
G2L["78"]["BorderSizePixel"] = 0;
G2L["78"]["TextSize"] = 14;
G2L["78"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["78"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["78"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["78"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["78"]["BackgroundTransparency"] = 1;
G2L["78"]["RichText"] = true;
G2L["78"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["78"]["Size"] = UDim2.new(0, 188, 0, 14);
G2L["78"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["78"]["Text"] = [[Button Name]];
G2L["78"]["Name"] = [[Title]];
G2L["78"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button.Interact
G2L["79"] = Instance.new("TextButton", G2L["76"]);
G2L["79"]["BorderSizePixel"] = 0;
G2L["79"]["TextTransparency"] = 1;
G2L["79"]["TextSize"] = 14;
G2L["79"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["79"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["79"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["79"]["ZIndex"] = 5;
G2L["79"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["79"]["BackgroundTransparency"] = 1;
G2L["79"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["79"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["79"]["Text"] = [[]];
G2L["79"]["Name"] = [[Interact]];
G2L["79"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button.ElementIndicator
G2L["7a"] = Instance.new("TextLabel", G2L["76"]);
G2L["7a"]["TextWrapped"] = true;
G2L["7a"]["BorderSizePixel"] = 0;
G2L["7a"]["TextSize"] = 14;
G2L["7a"]["TextXAlignment"] = Enum.TextXAlignment.Right;
G2L["7a"]["TextTransparency"] = 0.9;
G2L["7a"]["TextScaled"] = true;
G2L["7a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["7a"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["7a"]["BackgroundTransparency"] = 1;
G2L["7a"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["7a"]["Size"] = UDim2.new(0, 108, 0, 13);
G2L["7a"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["7a"]["Text"] = [[button]];
G2L["7a"]["Name"] = [[ElementIndicator]];
G2L["7a"]["Position"] = UDim2.new(1, -10, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker
G2L["7b"] = Instance.new("Frame", G2L["67"]);
G2L["7b"]["BorderSizePixel"] = 0;
G2L["7b"]["BackgroundColor3"] = Color3.fromRGB(38, 38, 38);
G2L["7b"]["Size"] = UDim2.new(1, -10, 0, 120);
G2L["7b"]["Position"] = UDim2.new(0.01053, 0, 0.57377, 0);
G2L["7b"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["7b"]["Name"] = [[ColorPicker]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.UICorner
G2L["7c"] = Instance.new("UICorner", G2L["7b"]);
G2L["7c"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.Interact
G2L["7d"] = Instance.new("TextButton", G2L["7b"]);
G2L["7d"]["BorderSizePixel"] = 0;
G2L["7d"]["TextTransparency"] = 1;
G2L["7d"]["TextSize"] = 14;
G2L["7d"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["7d"]["ZIndex"] = 5;
G2L["7d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["7d"]["BackgroundTransparency"] = 1;
G2L["7d"]["Size"] = UDim2.new(0.57419, 0, 1, 0);
G2L["7d"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["7d"]["Text"] = [[]];
G2L["7d"]["Name"] = [[Interact]];
G2L["7d"]["Position"] = UDim2.new(0.28925, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground
G2L["7e"] = Instance.new("Frame", G2L["7b"]);
G2L["7e"]["BorderSizePixel"] = 0;
G2L["7e"]["BackgroundColor3"] = Color3.fromRGB(101, 255, 0);
G2L["7e"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["7e"]["Size"] = UDim2.new(0, 173, 0, 86);
G2L["7e"]["Position"] = UDim2.new(0, 449, 0, 11);
G2L["7e"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["7e"]["Name"] = [[CPBackground]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP
G2L["7f"] = Instance.new("ImageButton", G2L["7e"]);
G2L["7f"]["BorderSizePixel"] = 0;
G2L["7f"]["ImageTransparency"] = 0.1;
G2L["7f"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["7f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7f"]["ZIndex"] = 2;
G2L["7f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["7f"]["Image"] = [[http://www.roblox.com/asset/?id=11413591840]];
G2L["7f"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["7f"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["7f"]["Name"] = [[MainCP]];
G2L["7f"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP.UICorner
G2L["80"] = Instance.new("UICorner", G2L["7f"]);
G2L["80"]["CornerRadius"] = UDim.new(0, 5);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP.MainPoint
G2L["81"] = Instance.new("ImageButton", G2L["7f"]);
G2L["81"]["Active"] = false;
G2L["81"]["Interactable"] = false;
G2L["81"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["81"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["81"]["ImageColor3"] = Color3.fromRGB(31, 75, 0);
G2L["81"]["ZIndex"] = 3;
G2L["81"]["Image"] = [[http://www.roblox.com/asset/?id=3259050989]];
G2L["81"]["Size"] = UDim2.new(0, 59, 0, 59);
G2L["81"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["81"]["Name"] = [[MainPoint]];
G2L["81"]["Position"] = UDim2.new(0.18282, 0, 0.24896, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.UICorner
G2L["82"] = Instance.new("UICorner", G2L["7e"]);
G2L["82"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display
G2L["83"] = Instance.new("Frame", G2L["7e"]);
G2L["83"]["BackgroundColor3"] = Color3.fromRGB(101, 255, 0);
G2L["83"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["83"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["83"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["83"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["83"]["Name"] = [[Display]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.UICorner
G2L["84"] = Instance.new("UICorner", G2L["83"]);
G2L["84"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.Frame
G2L["85"] = Instance.new("Frame", G2L["83"]);
G2L["85"]["BorderSizePixel"] = 0;
G2L["85"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["85"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["85"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["85"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["85"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["85"]["BackgroundTransparency"] = 0.75;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.Frame.UICorner
G2L["86"] = Instance.new("UICorner", G2L["85"]);
G2L["86"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput
G2L["87"] = Instance.new("Frame", G2L["7b"]);
G2L["87"]["ZIndex"] = 10;
G2L["87"]["BorderSizePixel"] = 0;
G2L["87"]["BackgroundColor3"] = Color3.fromRGB(33, 33, 33);
G2L["87"]["Size"] = UDim2.new(0, 119, 0, 31);
G2L["87"]["Position"] = UDim2.new(0, 17, 0, 73);
G2L["87"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["87"]["Name"] = [[HexInput]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.UICorner
G2L["88"] = Instance.new("UICorner", G2L["87"]);
G2L["88"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.UIStroke
G2L["89"] = Instance.new("UIStroke", G2L["87"]);
G2L["89"]["Color"] = Color3.fromRGB(63, 63, 63);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.InputBox
G2L["8a"] = Instance.new("TextBox", G2L["87"]);
G2L["8a"]["Name"] = [[InputBox]];
G2L["8a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["8a"]["ZIndex"] = 10;
G2L["8a"]["BorderSizePixel"] = 0;
G2L["8a"]["TextSize"] = 14;
G2L["8a"]["TextColor3"] = Color3.fromRGB(203, 203, 203);
G2L["8a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["8a"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["8a"]["ClearTextOnFocus"] = false;
G2L["8a"]["PlaceholderText"] = [[hex]];
G2L["8a"]["Size"] = UDim2.new(0.97962, -15, 0, 14);
G2L["8a"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["8a"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["8a"]["Text"] = [[]];
G2L["8a"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider
G2L["8b"] = Instance.new("ImageButton", G2L["7b"]);
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["8b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8b"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["8b"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
G2L["8b"]["Size"] = UDim2.new(0, 173, 0, 12);
G2L["8b"]["ClipsDescendants"] = true;
G2L["8b"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["8b"]["Name"] = [[ColorSlider]];
G2L["8b"]["Position"] = UDim2.new(0, 449, 0, 102);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.UIGradient
G2L["8c"] = Instance.new("UIGradient", G2L["8b"]);
G2L["8c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),ColorSequenceKeypoint.new(0.056, Color3.fromRGB(255, 88, 0)),ColorSequenceKeypoint.new(0.111, Color3.fromRGB(255, 173, 0)),ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),ColorSequenceKeypoint.new(0.223, Color3.fromRGB(172, 255, 0)),ColorSequenceKeypoint.new(0.279, Color3.fromRGB(86, 255, 0)),ColorSequenceKeypoint.new(0.334, Color3.fromRGB(0, 255, 4)),ColorSequenceKeypoint.new(0.390, Color3.fromRGB(0, 255, 89)),ColorSequenceKeypoint.new(0.446, Color3.fromRGB(0, 255, 174)),ColorSequenceKeypoint.new(0.501, Color3.fromRGB(0, 255, 255)),ColorSequenceKeypoint.new(0.557, Color3.fromRGB(0, 170, 255)),ColorSequenceKeypoint.new(0.613, Color3.fromRGB(0, 85, 255)),ColorSequenceKeypoint.new(0.669, Color3.fromRGB(5, 0, 255)),ColorSequenceKeypoint.new(0.724, Color3.fromRGB(91, 0, 255)),ColorSequenceKeypoint.new(0.780, Color3.fromRGB(176, 0, 255)),ColorSequenceKeypoint.new(0.836, Color3.fromRGB(255, 0, 254)),ColorSequenceKeypoint.new(0.891, Color3.fromRGB(255, 0, 169)),ColorSequenceKeypoint.new(0.947, Color3.fromRGB(255, 0, 83)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))};


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.SliderPoint
G2L["8d"] = Instance.new("ImageButton", G2L["8b"]);
G2L["8d"]["Active"] = false;
G2L["8d"]["Interactable"] = false;
G2L["8d"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["8d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8d"]["ImageColor3"] = Color3.fromRGB(0, 255, 0);
G2L["8d"]["ZIndex"] = 2;
G2L["8d"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["8d"]["Image"] = [[http://www.roblox.com/asset/?id=3259050989]];
G2L["8d"]["Size"] = UDim2.new(0, 59, 0, 59);
G2L["8d"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["8d"]["Name"] = [[SliderPoint]];
G2L["8d"]["Position"] = UDim2.new(0.182, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.TintAdder
G2L["8e"] = Instance.new("TextLabel", G2L["8b"]);
G2L["8e"]["TextSize"] = 14;
G2L["8e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8e"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8e"]["BackgroundTransparency"] = 0.8;
G2L["8e"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["8e"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["8e"]["Text"] = [[]];
G2L["8e"]["Name"] = [[TintAdder]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.TintAdder.UICorner
G2L["8f"] = Instance.new("UICorner", G2L["8e"]);
G2L["8f"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.UICorner
G2L["90"] = Instance.new("UICorner", G2L["8b"]);
G2L["90"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.Title
G2L["91"] = Instance.new("TextLabel", G2L["7b"]);
G2L["91"]["TextWrapped"] = true;
G2L["91"]["ZIndex"] = 3;
G2L["91"]["BorderSizePixel"] = 0;
G2L["91"]["TextSize"] = 14;
G2L["91"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["91"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["91"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["91"]["TextColor3"] = Color3.fromRGB(243, 243, 243);
G2L["91"]["BackgroundTransparency"] = 1;
G2L["91"]["RichText"] = true;
G2L["91"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["91"]["Size"] = UDim2.new(0, 237, 0, 14);
G2L["91"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["91"]["Text"] = [[Color Picker]];
G2L["91"]["Name"] = [[Title]];
G2L["91"]["Position"] = UDim2.new(0, 135, 0, 22);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB
G2L["92"] = Instance.new("Frame", G2L["7b"]);
G2L["92"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["92"]["Size"] = UDim2.new(0, 232, 0, 29);
G2L["92"]["Position"] = UDim2.new(0, 17, 0, 40);
G2L["92"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["92"]["Name"] = [[RGB]];
G2L["92"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.UIListLayout
G2L["93"] = Instance.new("UIListLayout", G2L["92"]);
G2L["93"]["Padding"] = UDim.new(0, 5);
G2L["93"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
G2L["93"]["FillDirection"] = Enum.FillDirection.Horizontal;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput
G2L["94"] = Instance.new("Frame", G2L["92"]);
G2L["94"]["ZIndex"] = 10;
G2L["94"]["BorderSizePixel"] = 0;
G2L["94"]["BackgroundColor3"] = Color3.fromRGB(33, 33, 33);
G2L["94"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["94"]["Size"] = UDim2.new(0, 54, 0, 27);
G2L["94"]["Position"] = UDim2.new(0.35977, -7, 0.49583, 0);
G2L["94"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["94"]["Name"] = [[GInput]];
G2L["94"]["LayoutOrder"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.UICorner
G2L["95"] = Instance.new("UICorner", G2L["94"]);
G2L["95"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.InputBox
G2L["96"] = Instance.new("TextBox", G2L["94"]);
G2L["96"]["Name"] = [[InputBox]];
G2L["96"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["96"]["ZIndex"] = 10;
G2L["96"]["BorderSizePixel"] = 0;
G2L["96"]["TextSize"] = 12;
G2L["96"]["TextColor3"] = Color3.fromRGB(203, 203, 203);
G2L["96"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["96"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["96"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["96"]["ClearTextOnFocus"] = false;
G2L["96"]["PlaceholderText"] = [[G]];
G2L["96"]["Size"] = UDim2.new(0.874, -15, 0, 14);
G2L["96"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["96"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["96"]["Text"] = [[]];
G2L["96"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.UIStroke
G2L["97"] = Instance.new("UIStroke", G2L["94"]);
G2L["97"]["Color"] = Color3.fromRGB(63, 63, 63);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput
G2L["98"] = Instance.new("Frame", G2L["92"]);
G2L["98"]["ZIndex"] = 10;
G2L["98"]["BorderSizePixel"] = 0;
G2L["98"]["BackgroundColor3"] = Color3.fromRGB(33, 33, 33);
G2L["98"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["98"]["Size"] = UDim2.new(0, 54, 0, 27);
G2L["98"]["Position"] = UDim2.new(0.18152, -5, 0.49583, 0);
G2L["98"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["98"]["Name"] = [[RInput]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.UICorner
G2L["99"] = Instance.new("UICorner", G2L["98"]);
G2L["99"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.InputBox
G2L["9a"] = Instance.new("TextBox", G2L["98"]);
G2L["9a"]["Name"] = [[InputBox]];
G2L["9a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9a"]["ZIndex"] = 10;
G2L["9a"]["BorderSizePixel"] = 0;
G2L["9a"]["TextSize"] = 12;
G2L["9a"]["TextColor3"] = Color3.fromRGB(203, 203, 203);
G2L["9a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["9a"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9a"]["ClearTextOnFocus"] = false;
G2L["9a"]["PlaceholderText"] = [[R]];
G2L["9a"]["Size"] = UDim2.new(0.87372, -15, 0, 14);
G2L["9a"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["9a"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["9a"]["Text"] = [[]];
G2L["9a"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.UIStroke
G2L["9b"] = Instance.new("UIStroke", G2L["98"]);
G2L["9b"]["Color"] = Color3.fromRGB(63, 63, 63);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput
G2L["9c"] = Instance.new("Frame", G2L["92"]);
G2L["9c"]["ZIndex"] = 10;
G2L["9c"]["BorderSizePixel"] = 0;
G2L["9c"]["BackgroundColor3"] = Color3.fromRGB(33, 33, 33);
G2L["9c"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["9c"]["Size"] = UDim2.new(0, 54, 0, 27);
G2L["9c"]["Position"] = UDim2.new(0.9278, -5, 0.46552, 0);
G2L["9c"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["9c"]["Name"] = [[BInput]];
G2L["9c"]["LayoutOrder"] = 2;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.UICorner
G2L["9d"] = Instance.new("UICorner", G2L["9c"]);
G2L["9d"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.InputBox
G2L["9e"] = Instance.new("TextBox", G2L["9c"]);
G2L["9e"]["Name"] = [[InputBox]];
G2L["9e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9e"]["ZIndex"] = 10;
G2L["9e"]["BorderSizePixel"] = 0;
G2L["9e"]["TextSize"] = 12;
G2L["9e"]["TextColor3"] = Color3.fromRGB(203, 203, 203);
G2L["9e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["9e"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9e"]["ClearTextOnFocus"] = false;
G2L["9e"]["PlaceholderText"] = [[B]];
G2L["9e"]["Size"] = UDim2.new(0.874, -15, 0, 14);
G2L["9e"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["9e"]["BorderColor3"] = Color3.fromRGB(30, 45, 56);
G2L["9e"]["Text"] = [[]];
G2L["9e"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.UIStroke
G2L["9f"] = Instance.new("UIStroke", G2L["9c"]);
G2L["9f"]["Color"] = Color3.fromRGB(63, 63, 63);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.UIStroke
G2L["a0"] = Instance.new("UIStroke", G2L["7b"]);
G2L["a0"]["Color"] = Color3.fromRGB(53, 53, 53);


-- StarterGui.AdminUI.setsettings.Container.List.Input
G2L["a1"] = Instance.new("Frame", G2L["67"]);
G2L["a1"]["BorderSizePixel"] = 0;
G2L["a1"]["BackgroundColor3"] = Color3.fromRGB(37, 37, 37);
G2L["a1"]["Size"] = UDim2.new(1, -10, 0, 40);
G2L["a1"]["Position"] = UDim2.new(0.01053, 0, 0.66921, 0);
G2L["a1"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["a1"]["Name"] = [[Input]];


-- StarterGui.AdminUI.setsettings.Container.List.Input.UICorner
G2L["a2"] = Instance.new("UICorner", G2L["a1"]);
G2L["a2"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.Input.Title
G2L["a3"] = Instance.new("TextLabel", G2L["a1"]);
G2L["a3"]["TextWrapped"] = true;
G2L["a3"]["BorderSizePixel"] = 0;
G2L["a3"]["TextSize"] = 14;
G2L["a3"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["a3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a3"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["a3"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["a3"]["BackgroundTransparency"] = 1;
G2L["a3"]["RichText"] = true;
G2L["a3"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["a3"]["Size"] = UDim2.new(0, 200, 0, 14);
G2L["a3"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["a3"]["Text"] = [[Input Element]];
G2L["a3"]["Name"] = [[Title]];
G2L["a3"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Input.UIStroke
G2L["a4"] = Instance.new("UIStroke", G2L["a1"]);
G2L["a4"]["Color"] = Color3.fromRGB(52, 52, 52);


-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame
G2L["a5"] = Instance.new("Frame", G2L["a1"]);
G2L["a5"]["BorderSizePixel"] = 0;
G2L["a5"]["BackgroundColor3"] = Color3.fromRGB(32, 32, 32);
G2L["a5"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["a5"]["Size"] = UDim2.new(0, 120, 0, 30);
G2L["a5"]["Position"] = UDim2.new(1, -7, 0, 20);
G2L["a5"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["a5"]["Name"] = [[InputFrame]];


-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame.InputBox
G2L["a6"] = Instance.new("TextBox", G2L["a5"]);
G2L["a6"]["Name"] = [[InputBox]];
G2L["a6"]["BorderSizePixel"] = 0;
G2L["a6"]["TextSize"] = 14;
G2L["a6"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["a6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a6"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["a6"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a6"]["ClearTextOnFocus"] = false;
G2L["a6"]["PlaceholderText"] = [[Dynamic Input]];
G2L["a6"]["Size"] = UDim2.new(1, -15, 0, 14);
G2L["a6"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["a6"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["a6"]["Text"] = [[]];
G2L["a6"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame.UIStroke
G2L["a7"] = Instance.new("UIStroke", G2L["a5"]);
G2L["a7"]["Color"] = Color3.fromRGB(67, 67, 67);


-- StarterGui.AdminUI.setsettings.Container.List.Input.InputFrame.UICorner
G2L["a8"] = Instance.new("UICorner", G2L["a5"]);
G2L["a8"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.Keybind
G2L["a9"] = Instance.new("Frame", G2L["67"]);
G2L["a9"]["BorderSizePixel"] = 0;
G2L["a9"]["BackgroundColor3"] = Color3.fromRGB(37, 37, 37);
G2L["a9"]["Size"] = UDim2.new(1, -10, 0, 40);
G2L["a9"]["Position"] = UDim2.new(0.01053, 0, 0.66921, 0);
G2L["a9"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["a9"]["Name"] = [[Keybind]];


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.UICorner
G2L["aa"] = Instance.new("UICorner", G2L["a9"]);
G2L["aa"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.Title
G2L["ab"] = Instance.new("TextLabel", G2L["a9"]);
G2L["ab"]["TextWrapped"] = true;
G2L["ab"]["BorderSizePixel"] = 0;
G2L["ab"]["TextSize"] = 14;
G2L["ab"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["ab"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ab"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["ab"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["ab"]["BackgroundTransparency"] = 1;
G2L["ab"]["RichText"] = true;
G2L["ab"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["ab"]["Size"] = UDim2.new(0, 200, 0, 14);
G2L["ab"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["ab"]["Text"] = [[Keybind]];
G2L["ab"]["Name"] = [[Title]];
G2L["ab"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.UIStroke
G2L["ac"] = Instance.new("UIStroke", G2L["a9"]);
G2L["ac"]["Color"] = Color3.fromRGB(52, 52, 52);


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame
G2L["ad"] = Instance.new("Frame", G2L["a9"]);
G2L["ad"]["BorderSizePixel"] = 0;
G2L["ad"]["BackgroundColor3"] = Color3.fromRGB(32, 32, 32);
G2L["ad"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["ad"]["Size"] = UDim2.new(0, 34, 0, 30);
G2L["ad"]["Position"] = UDim2.new(1, -7, 0, 20);
G2L["ad"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["ad"]["Name"] = [[KeybindFrame]];


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame.KeybindBox
G2L["ae"] = Instance.new("TextBox", G2L["ad"]);
G2L["ae"]["Name"] = [[KeybindBox]];
G2L["ae"]["BorderSizePixel"] = 0;
G2L["ae"]["TextSize"] = 14;
G2L["ae"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["ae"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ae"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["ae"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ae"]["ClearTextOnFocus"] = false;
G2L["ae"]["PlaceholderText"] = [[Keybind]];
G2L["ae"]["Size"] = UDim2.new(1, -15, 0, 14);
G2L["ae"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["ae"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["ae"]["Text"] = [[Q]];
G2L["ae"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame.UIStroke
G2L["af"] = Instance.new("UIStroke", G2L["ad"]);
G2L["af"]["Color"] = Color3.fromRGB(67, 67, 67);


-- StarterGui.AdminUI.setsettings.Container.List.Keybind.KeybindFrame.UICorner
G2L["b0"] = Instance.new("UICorner", G2L["ad"]);
G2L["b0"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.Slider
G2L["b1"] = Instance.new("Frame", G2L["67"]);
G2L["b1"]["BorderSizePixel"] = 0;
G2L["b1"]["BackgroundColor3"] = Color3.fromRGB(37, 37, 37);
G2L["b1"]["Size"] = UDim2.new(1, -10, 0.02799, 35);
G2L["b1"]["Position"] = UDim2.new(0.01053, 0, 0.45038, 0);
G2L["b1"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["b1"]["Name"] = [[Slider]];


-- StarterGui.AdminUI.setsettings.Container.List.Slider.UICorner
G2L["b2"] = Instance.new("UICorner", G2L["b1"]);
G2L["b2"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Title
G2L["b3"] = Instance.new("TextLabel", G2L["b1"]);
G2L["b3"]["TextWrapped"] = true;
G2L["b3"]["BorderSizePixel"] = 0;
G2L["b3"]["TextSize"] = 14;
G2L["b3"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["b3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b3"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["b3"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["b3"]["BackgroundTransparency"] = 1;
G2L["b3"]["RichText"] = true;
G2L["b3"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["b3"]["Size"] = UDim2.new(0, 200, 0, 14);
G2L["b3"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["b3"]["Text"] = [[Slider]];
G2L["b3"]["Name"] = [[Title]];
G2L["b3"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.UIStroke
G2L["b4"] = Instance.new("UIStroke", G2L["b1"]);
G2L["b4"]["Color"] = Color3.fromRGB(52, 52, 52);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main
G2L["b5"] = Instance.new("CanvasGroup", G2L["b1"]);
G2L["b5"]["BorderSizePixel"] = 0;
G2L["b5"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["b5"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b5"]["Size"] = UDim2.new(0, 222, 0, 30);
G2L["b5"]["Position"] = UDim2.new(1, -10, 0.5, 0);
G2L["b5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["b5"]["Name"] = [[Main]];
G2L["b5"]["BackgroundTransparency"] = 0.8;


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.UICorner
G2L["b6"] = Instance.new("UICorner", G2L["b5"]);
G2L["b6"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.UIStroke
G2L["b7"] = Instance.new("UIStroke", G2L["b5"]);
G2L["b7"]["Transparency"] = 0.4;
G2L["b7"]["Thickness"] = 1.2;
G2L["b7"]["Color"] = Color3.fromRGB(52, 52, 52);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Interact
G2L["b8"] = Instance.new("TextButton", G2L["b5"]);
G2L["b8"]["BorderSizePixel"] = 0;
G2L["b8"]["TextSize"] = 14;
G2L["b8"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["b8"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b8"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["b8"]["ZIndex"] = 10;
G2L["b8"]["BackgroundTransparency"] = 1;
G2L["b8"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["b8"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["b8"]["Text"] = [[]];
G2L["b8"]["Name"] = [[Interact]];


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Information
G2L["b9"] = Instance.new("TextLabel", G2L["b5"]);
G2L["b9"]["TextWrapped"] = true;
G2L["b9"]["ZIndex"] = 5;
G2L["b9"]["BorderSizePixel"] = 0;
G2L["b9"]["TextSize"] = 15;
G2L["b9"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["b9"]["TextTransparency"] = 0.3;
G2L["b9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b9"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["b9"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b9"]["BackgroundTransparency"] = 1;
G2L["b9"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["b9"]["Size"] = UDim2.new(0, 168, 0, 15);
G2L["b9"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["b9"]["Text"] = [[750 studs]];
G2L["b9"]["Name"] = [[Information]];
G2L["b9"]["Position"] = UDim2.new(0.4536, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Progress
G2L["ba"] = Instance.new("Frame", G2L["b5"]);
G2L["ba"]["BorderSizePixel"] = 0;
G2L["ba"]["BackgroundColor3"] = Color3.fromRGB(95, 95, 95);
G2L["ba"]["Size"] = UDim2.new(0.80097, 0, 1, 0);
G2L["ba"]["BorderColor3"] = Color3.fromRGB(29, 44, 55);
G2L["ba"]["Name"] = [[Progress]];


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Progress.UICorner
G2L["bb"] = Instance.new("UICorner", G2L["ba"]);
G2L["bb"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Slider.Main.Progress.UIStroke
G2L["bc"] = Instance.new("UIStroke", G2L["ba"]);
G2L["bc"]["Transparency"] = 0.3;
G2L["bc"]["Thickness"] = 1.2;
G2L["bc"]["Color"] = Color3.fromRGB(52, 52, 52);


-- StarterGui.AdminUI.setsettings.Container.UICorner
G2L["bd"] = Instance.new("UICorner", G2L["66"]);
G2L["bd"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.UIGradient
G2L["be"] = Instance.new("UIGradient", G2L["66"]);
G2L["be"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(17, 9, 25)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(17, 9, 25))};


-- StarterGui.AdminUI.setsettings.Topbar
G2L["bf"] = Instance.new("Frame", G2L["65"]);
G2L["bf"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["bf"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["bf"]["Name"] = [[Topbar]];
G2L["bf"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Topbar.Exit
G2L["c0"] = Instance.new("TextButton", G2L["bf"]);
G2L["c0"]["TextWrapped"] = true;
G2L["c0"]["BorderSizePixel"] = 0;
G2L["c0"]["TextSize"] = 13;
G2L["c0"]["TextScaled"] = true;
G2L["c0"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["c0"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["c0"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["c0"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c0"]["BackgroundTransparency"] = 0.5;
G2L["c0"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["c0"]["Text"] = [[X]];
G2L["c0"]["Name"] = [[Exit]];
G2L["c0"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Topbar.Exit.UICorners
G2L["c1"] = Instance.new("UICorner", G2L["c0"]);
G2L["c1"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.setsettings.Topbar.Exit.UIStroker
G2L["c2"] = Instance.new("UIStroke", G2L["c0"]);
G2L["c2"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c2"]["Name"] = [[UIStroker]];
G2L["c2"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.setsettings.Topbar.Minimize
G2L["c3"] = Instance.new("TextButton", G2L["bf"]);
G2L["c3"]["TextWrapped"] = true;
G2L["c3"]["BorderSizePixel"] = 0;
G2L["c3"]["TextSize"] = 13;
G2L["c3"]["TextScaled"] = true;
G2L["c3"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["c3"]["BackgroundColor3"] = Color3.fromRGB(17, 9, 25);
G2L["c3"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["c3"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["c3"]["BackgroundTransparency"] = 0.5;
G2L["c3"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["c3"]["Text"] = [[-]];
G2L["c3"]["Name"] = [[Minimize]];
G2L["c3"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Topbar.Minimize.UICorners
G2L["c4"] = Instance.new("UICorner", G2L["c3"]);
G2L["c4"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.setsettings.Topbar.Minimize.UIStroker
G2L["c5"] = Instance.new("UIStroke", G2L["c3"]);
G2L["c5"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c5"]["Name"] = [[UIStroker]];
G2L["c5"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.setsettings.Topbar.Title
G2L["c6"] = Instance.new("TextLabel", G2L["bf"]);
G2L["c6"]["TextWrapped"] = true;
G2L["c6"]["BorderSizePixel"] = 0;
G2L["c6"]["TextSize"] = 17;
G2L["c6"]["TextScaled"] = true;
G2L["c6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c6"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["c6"]["TextColor3"] = Color3.fromRGB(246, 246, 246);
G2L["c6"]["BackgroundTransparency"] = 1;
G2L["c6"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["c6"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["c6"]["Text"] = [[Settings]];
G2L["c6"]["Name"] = [[Title]];
G2L["c6"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.UICorners
G2L["c7"] = Instance.new("UICorner", G2L["65"]);
G2L["c7"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.setsettings.UIStroker
G2L["c8"] = Instance.new("UIStroke", G2L["65"]);
G2L["c8"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["c8"]["Name"] = [[UIStroker]];
G2L["c8"]["Color"] = Color3.fromRGB(150, 95, 255);


-- StarterGui.AdminUI.setsettings.UIGradients
G2L["c9"] = Instance.new("UIGradient", G2L["65"]);
G2L["c9"]["Name"] = [[UIGradients]];
G2L["c9"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(45, 45, 51)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(23, 23, 27))};



return G2L["1"];