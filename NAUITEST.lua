local G2L = {};

-- StarterGui.AdminUI
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
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
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["5"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(30, 30, 30);
G2L["5"]["Name"] = [[Horizontal]];
G2L["5"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UICorners
G2L["6"] = Instance.new("UICorner", G2L["5"]);
G2L["6"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UIGradients
G2L["7"] = Instance.new("UIGradient", G2L["5"]);
G2L["7"]["Name"] = [[UIGradients]];
G2L["7"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


-- StarterGui.AdminUI.CmdBar.CenterBar.Input
G2L["8"] = Instance.new("TextBox", G2L["4"]);
G2L["8"]["CursorPosition"] = -1;
G2L["8"]["Active"] = false;
G2L["8"]["Name"] = [[Input]];
G2L["8"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["8"]["ZIndex"] = 2;
G2L["8"]["TextWrapped"] = true;
G2L["8"]["TextSize"] = 24;
G2L["8"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
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
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["a"]["Size"] = UDim2.new(1.00599, 0, 1, 0);
G2L["a"]["BorderColor3"] = Color3.fromRGB(30, 30, 30);
G2L["a"]["Name"] = [[Horizontal]];
G2L["a"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UICorners
G2L["b"] = Instance.new("UICorner", G2L["a"]);
G2L["b"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UIGradients
G2L["c"] = Instance.new("UIGradient", G2L["a"]);
G2L["c"]["Name"] = [[UIGradients]];
G2L["c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


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
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["e"]["Size"] = UDim2.new(1.00798, 0, 1, 0);
G2L["e"]["Position"] = UDim2.new(-0.00798, 0, 0, 0);
G2L["e"]["BorderColor3"] = Color3.fromRGB(30, 30, 30);
G2L["e"]["Name"] = [[Horizontal]];
G2L["e"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UICorners
G2L["f"] = Instance.new("UICorner", G2L["e"]);
G2L["f"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UIGradients
G2L["10"] = Instance.new("UIGradient", G2L["e"]);
G2L["10"]["Name"] = [[UIGradients]];
G2L["10"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


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
G2L["13"]["BackgroundColor3"] = Color3.fromRGB(20, 20, 20);
G2L["13"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["13"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
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
G2L["15"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["15"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["15"]["Name"] = [[Horizontal]];
G2L["15"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UICorners
G2L["16"] = Instance.new("UICorner", G2L["15"]);
G2L["16"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UIGradients
G2L["17"] = Instance.new("UIGradient", G2L["15"]);
G2L["17"]["Name"] = [[UIGradients]];
G2L["17"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


-- StarterGui.AdminUI.CmdBar.Autofill.UIListLayout
G2L["18"] = Instance.new("UIListLayout", G2L["11"]);
G2L["18"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["18"]["Padding"] = UDim.new(0, 3);
G2L["18"]["VerticalAlignment"] = Enum.VerticalAlignment.Bottom;
G2L["18"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.Commands
G2L["19"] = Instance.new("Frame", G2L["1"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["19"]["Size"] = UDim2.new(0, 283, 0, 286);
G2L["19"]["Position"] = UDim2.new(0.00984, 0, 0.02946, 0);
G2L["19"]["BorderColor3"] = Color3.fromRGB(142, 142, 142);
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
G2L["1b"]["BorderColor3"] = Color3.fromRGB(19, 19, 19);
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
G2L["1d"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["1d"]["BackgroundTransparency"] = 1;
G2L["1d"]["Size"] = UDim2.new(1, 0, 0, 20);
G2L["1d"]["Text"] = [[example <player> <text>]];
G2L["1d"]["Position"] = UDim2.new(0, 0, 0.01739, 0);


-- StarterGui.AdminUI.Commands.Container.Filter
G2L["1e"] = Instance.new("TextBox", G2L["1a"]);
G2L["1e"]["Name"] = [[Filter]];
G2L["1e"]["PlaceholderColor3"] = Color3.fromRGB(127, 127, 127);
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["TextSize"] = 18;
G2L["1e"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(7, 7, 7);
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
G2L["21"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(15, 7, 23))};


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
G2L["23"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["23"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["25"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.Commands.Topbar.Minimize
G2L["26"] = Instance.new("TextButton", G2L["22"]);
G2L["26"]["TextWrapped"] = true;
G2L["26"]["BorderSizePixel"] = 0;
G2L["26"]["TextSize"] = 13;
G2L["26"]["TextScaled"] = true;
G2L["26"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["26"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["28"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.Commands.Topbar.Title
G2L["29"] = Instance.new("TextLabel", G2L["22"]);
G2L["29"]["TextWrapped"] = true;
G2L["29"]["BorderSizePixel"] = 0;
G2L["29"]["TextSize"] = 17;
G2L["29"]["TextScaled"] = true;
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["29"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["29"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
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
G2L["2b"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.Commands.UIGradients
G2L["2c"] = Instance.new("UIGradient", G2L["19"]);
G2L["2c"]["Name"] = [[UIGradients]];
G2L["2c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


-- StarterGui.AdminUI.Resizeable
G2L["2d"] = Instance.new("Frame", G2L["1"]);
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2d"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["2d"]["Name"] = [[Resizeable]];
G2L["2d"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Left
G2L["2e"] = Instance.new("Frame", G2L["2d"]);
G2L["2e"]["BorderSizePixel"] = 0;
G2L["2e"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["2e"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["2e"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["2e"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["2e"]["Name"] = [[Left]];
G2L["2e"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Right
G2L["2f"] = Instance.new("Frame", G2L["2d"]);
G2L["2f"]["BorderSizePixel"] = 0;
G2L["2f"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["2f"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["2f"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["2f"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["2f"]["Name"] = [[Right]];
G2L["2f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Top
G2L["30"] = Instance.new("Frame", G2L["2d"]);
G2L["30"]["BorderSizePixel"] = 0;
G2L["30"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["30"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["30"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["30"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["30"]["Name"] = [[Top]];
G2L["30"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Bottom
G2L["31"] = Instance.new("Frame", G2L["2d"]);
G2L["31"]["BorderSizePixel"] = 0;
G2L["31"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["31"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["31"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["31"]["Position"] = UDim2.new(0.5, 0, 1, 0);
G2L["31"]["Name"] = [[Bottom]];
G2L["31"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopLeft
G2L["32"] = Instance.new("Frame", G2L["2d"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["32"]["AnchorPoint"] = Vector2.new(1, 1);
G2L["32"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["32"]["Position"] = UDim2.new(0, 4, 0, 4);
G2L["32"]["Name"] = [[TopLeft]];
G2L["32"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopRight
G2L["33"] = Instance.new("Frame", G2L["2d"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["33"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["33"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["33"]["Position"] = UDim2.new(1, -4, 0, 4);
G2L["33"]["Name"] = [[TopRight]];
G2L["33"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomLeft
G2L["34"] = Instance.new("Frame", G2L["2d"]);
G2L["34"]["BorderSizePixel"] = 0;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["34"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["34"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["34"]["Position"] = UDim2.new(0, 4, 1, -4);
G2L["34"]["Name"] = [[BottomLeft]];
G2L["34"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomRight
G2L["35"] = Instance.new("Frame", G2L["2d"]);
G2L["35"]["BorderSizePixel"] = 0;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(0, 203, 255);
G2L["35"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["35"]["Position"] = UDim2.new(1, -4, 1, -4);
G2L["35"]["Name"] = [[BottomRight]];
G2L["35"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Description
G2L["36"] = Instance.new("TextLabel", G2L["1"]);
G2L["36"]["TextWrapped"] = true;
G2L["36"]["TextSize"] = 13;
G2L["36"]["TextScaled"] = true;
G2L["36"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
G2L["36"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["36"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["36"]["BackgroundTransparency"] = 0.3;
G2L["36"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["36"]["Size"] = UDim2.new(0, 191, 0, 26);
G2L["36"]["Visible"] = false;
G2L["36"]["BorderColor3"] = Color3.fromRGB(56, 56, 56);
G2L["36"]["Text"] = [[Name]];
G2L["36"]["Name"] = [[Description]];


-- StarterGui.AdminUI.Description.UICorner
G2L["37"] = Instance.new("UICorner", G2L["36"]);



-- StarterGui.AdminUI.UpdLog
G2L["38"] = Instance.new("Frame", G2L["1"]);
G2L["38"]["BorderSizePixel"] = 0;
G2L["38"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["38"]["Size"] = UDim2.new(0, 283, 0, 286);
G2L["38"]["Position"] = UDim2.new(0.61871, 0, 0.03718, 0);
G2L["38"]["BorderColor3"] = Color3.fromRGB(142, 142, 142);
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
G2L["3a"]["BorderColor3"] = Color3.fromRGB(19, 19, 19);
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
G2L["3c"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
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
G2L["3e"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(15, 7, 23))};


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
G2L["40"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["42"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.UpdLog.Topbar.Minimize
G2L["43"] = Instance.new("TextButton", G2L["3f"]);
G2L["43"]["TextWrapped"] = true;
G2L["43"]["BorderSizePixel"] = 0;
G2L["43"]["TextSize"] = 13;
G2L["43"]["TextScaled"] = true;
G2L["43"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["45"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.UpdLog.Topbar.Title
G2L["46"] = Instance.new("TextLabel", G2L["3f"]);
G2L["46"]["TextWrapped"] = true;
G2L["46"]["BorderSizePixel"] = 0;
G2L["46"]["TextSize"] = 17;
G2L["46"]["TextScaled"] = true;
G2L["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["46"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["46"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
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
G2L["48"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.UpdLog.UIGradients
G2L["49"] = Instance.new("UIGradient", G2L["38"]);
G2L["49"]["Name"] = [[UIGradients]];
G2L["49"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


-- StarterGui.AdminUI.ChatLogs
G2L["4a"] = Instance.new("Frame", G2L["1"]);
G2L["4a"]["BorderSizePixel"] = 0;
G2L["4a"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["4a"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["4a"]["Position"] = UDim2.new(0.65118, 0, 0.56114, 0);
G2L["4a"]["BorderColor3"] = Color3.fromRGB(142, 142, 142);
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
G2L["4c"]["BorderColor3"] = Color3.fromRGB(19, 19, 19);
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
G2L["4e"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["4e"]["BackgroundTransparency"] = 1;
G2L["4e"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["4e"]["Text"] = [[[Roblox]: Hello,World!]];


-- StarterGui.AdminUI.ChatLogs.Container.UICorner
G2L["4f"] = Instance.new("UICorner", G2L["4b"]);
G2L["4f"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.ChatLogs.Container.UIGradient
G2L["50"] = Instance.new("UIGradient", G2L["4b"]);
G2L["50"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(15, 7, 23))};


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
G2L["52"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["54"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize
G2L["55"] = Instance.new("TextButton", G2L["51"]);
G2L["55"]["TextWrapped"] = true;
G2L["55"]["BorderSizePixel"] = 0;
G2L["55"]["TextSize"] = 18;
G2L["55"]["TextScaled"] = true;
G2L["55"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["55"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["57"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear
G2L["58"] = Instance.new("TextButton", G2L["51"]);
G2L["58"]["TextWrapped"] = true;
G2L["58"]["BorderSizePixel"] = 0;
G2L["58"]["TextSize"] = 13;
G2L["58"]["TextScaled"] = true;
G2L["58"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["58"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["59"]["Color"] = Color3.fromRGB(148, 93, 255);


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
G2L["5b"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
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
G2L["5d"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.ChatLogs.UIGradients
G2L["5e"] = Instance.new("UIGradient", G2L["4a"]);
G2L["5e"]["Name"] = [[UIGradients]];
G2L["5e"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


-- StarterGui.AdminUI.soRealConsole
G2L["5f"] = Instance.new("Frame", G2L["1"]);
G2L["5f"]["BorderSizePixel"] = 0;
G2L["5f"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["5f"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["5f"]["Position"] = UDim2.new(0.27746, 0, 0.04109, 0);
G2L["5f"]["BorderColor3"] = Color3.fromRGB(142, 142, 142);
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
G2L["61"]["BorderColor3"] = Color3.fromRGB(19, 19, 19);
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
G2L["63"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["63"]["BackgroundTransparency"] = 1;
G2L["63"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["63"]["Text"] = [[[Output]: failed print 1]];


-- StarterGui.AdminUI.soRealConsole.Container.UICorner
G2L["64"] = Instance.new("UICorner", G2L["60"]);
G2L["64"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.soRealConsole.Container.UIGradient
G2L["65"] = Instance.new("UIGradient", G2L["60"]);
G2L["65"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(15, 7, 23))};


-- StarterGui.AdminUI.soRealConsole.Container.Filter
G2L["66"] = Instance.new("TextBox", G2L["60"]);
G2L["66"]["Name"] = [[Filter]];
G2L["66"]["PlaceholderColor3"] = Color3.fromRGB(127, 127, 127);
G2L["66"]["BorderSizePixel"] = 0;
G2L["66"]["TextSize"] = 18;
G2L["66"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["66"]["BackgroundColor3"] = Color3.fromRGB(7, 7, 7);
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
G2L["69"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["69"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["6b"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize
G2L["6c"] = Instance.new("TextButton", G2L["68"]);
G2L["6c"]["TextWrapped"] = true;
G2L["6c"]["BorderSizePixel"] = 0;
G2L["6c"]["TextSize"] = 18;
G2L["6c"]["TextScaled"] = true;
G2L["6c"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["6e"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear
G2L["6f"] = Instance.new("TextButton", G2L["68"]);
G2L["6f"]["TextWrapped"] = true;
G2L["6f"]["BorderSizePixel"] = 0;
G2L["6f"]["TextSize"] = 13;
G2L["6f"]["TextScaled"] = true;
G2L["6f"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
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
G2L["71"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Title
G2L["72"] = Instance.new("TextLabel", G2L["68"]);
G2L["72"]["TextWrapped"] = true;
G2L["72"]["BorderSizePixel"] = 0;
G2L["72"]["TextSize"] = 17;
G2L["72"]["TextScaled"] = true;
G2L["72"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["72"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["72"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
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
G2L["74"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.soRealConsole.UIGradients
G2L["75"] = Instance.new("UIGradient", G2L["5f"]);
G2L["75"]["Name"] = [[UIGradients]];
G2L["75"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};


-- StarterGui.AdminUI.Modal
G2L["76"] = Instance.new("ImageButton", G2L["1"]);
G2L["76"]["BackgroundTransparency"] = 1;
G2L["76"]["Name"] = [[Modal]];


-- StarterGui.AdminUI.setsettings
G2L["77"] = Instance.new("Frame", G2L["1"]);
G2L["77"]["BorderSizePixel"] = 0;
G2L["77"]["BackgroundColor3"] = Color3.fromRGB(28, 29, 33);
G2L["77"]["Size"] = UDim2.new(0, 510, 0, 355);
G2L["77"]["Position"] = UDim2.new(0.14365, 0, 0.51325, 0);
G2L["77"]["BorderColor3"] = Color3.fromRGB(142, 142, 142);
G2L["77"]["Name"] = [[setsettings]];
G2L["77"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.setsettings.Container
G2L["78"] = Instance.new("Frame", G2L["77"]);
G2L["78"]["BorderSizePixel"] = 0;
G2L["78"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["78"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["78"]["ClipsDescendants"] = true;
G2L["78"]["Size"] = UDim2.new(1, -10, 1.01154, -30);
G2L["78"]["Position"] = UDim2.new(0.5, 0, 1, -5);
G2L["78"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["78"]["Name"] = [[Container]];
G2L["78"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.setsettings.Container.List
G2L["79"] = Instance.new("ScrollingFrame", G2L["78"]);
G2L["79"]["BorderSizePixel"] = 0;
G2L["79"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["79"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["79"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["79"]["Name"] = [[List]];
G2L["79"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["79"]["Size"] = UDim2.new(1, -10, 1.08012, -27);
G2L["79"]["Position"] = UDim2.new(0, 6, 0, 6);
G2L["79"]["BorderColor3"] = Color3.fromRGB(19, 19, 19);
G2L["79"]["ScrollBarThickness"] = 4;
G2L["79"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.UIListLayout
G2L["7a"] = Instance.new("UIListLayout", G2L["79"]);
G2L["7a"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["7a"]["Padding"] = UDim.new(0, 2);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle
G2L["7b"] = Instance.new("Frame", G2L["79"]);
G2L["7b"]["BorderSizePixel"] = 0;
G2L["7b"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
G2L["7b"]["Size"] = UDim2.new(1, -10, 0, 40);
G2L["7b"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["7b"]["Name"] = [[Toggle]];
G2L["7b"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Title
G2L["7c"] = Instance.new("TextLabel", G2L["7b"]);
G2L["7c"]["TextWrapped"] = true;
G2L["7c"]["BorderSizePixel"] = 0;
G2L["7c"]["TextSize"] = 14;
G2L["7c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["7c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["7c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["7c"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["7c"]["BackgroundTransparency"] = 1;
G2L["7c"]["RichText"] = true;
G2L["7c"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["7c"]["Size"] = UDim2.new(0, 178, 0, 14);
G2L["7c"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["7c"]["Text"] = [[random toggle]];
G2L["7c"]["Name"] = [[Title]];
G2L["7c"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Interact
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
G2L["7d"]["Size"] = UDim2.new(0.23715, 0, 1, 0);
G2L["7d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["7d"]["Text"] = [[]];
G2L["7d"]["Name"] = [[Interact]];
G2L["7d"]["Position"] = UDim2.new(0.88143, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch
G2L["7e"] = Instance.new("Frame", G2L["7b"]);
G2L["7e"]["BorderSizePixel"] = 0;
G2L["7e"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["7e"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["7e"]["Size"] = UDim2.new(0, 43, 0, 21);
G2L["7e"]["Position"] = UDim2.new(1, -10, 0, 20);
G2L["7e"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["7e"]["Name"] = [[Switch]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.UICorner
G2L["7f"] = Instance.new("UICorner", G2L["7e"]);
G2L["7f"]["CornerRadius"] = UDim.new(0, 15);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.UIStroke
G2L["80"] = Instance.new("UIStroke", G2L["7e"]);
G2L["80"]["Color"] = Color3.fromRGB(66, 66, 66);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator
G2L["81"] = Instance.new("Frame", G2L["7e"]);
G2L["81"]["BorderSizePixel"] = 0;
G2L["81"]["BackgroundColor3"] = Color3.fromRGB(101, 101, 101);
G2L["81"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["81"]["Size"] = UDim2.new(0, 17, 0, 17);
G2L["81"]["Position"] = UDim2.new(1, -40, 0.5, 0);
G2L["81"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["81"]["Name"] = [[Indicator]];


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator.UICorner
G2L["82"] = Instance.new("UICorner", G2L["81"]);
G2L["82"]["CornerRadius"] = UDim.new(1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Toggle.Switch.Indicator.UIStroke
G2L["83"] = Instance.new("UIStroke", G2L["81"]);
G2L["83"]["Thickness"] = 1.2;
G2L["83"]["Color"] = Color3.fromRGB(126, 126, 126);


-- StarterGui.AdminUI.setsettings.Container.List.SectionTitle
G2L["84"] = Instance.new("Frame", G2L["79"]);
G2L["84"]["BorderSizePixel"] = 0;
G2L["84"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["84"]["Size"] = UDim2.new(1, 0, 0, 15);
G2L["84"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["84"]["Name"] = [[SectionTitle]];
G2L["84"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.SectionTitle.Title
G2L["85"] = Instance.new("TextLabel", G2L["84"]);
G2L["85"]["TextWrapped"] = true;
G2L["85"]["BorderSizePixel"] = 0;
G2L["85"]["TextSize"] = 14;
G2L["85"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["85"]["TextTransparency"] = 0.4;
G2L["85"]["TextScaled"] = true;
G2L["85"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["85"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["85"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["85"]["BackgroundTransparency"] = 1;
G2L["85"]["Size"] = UDim2.new(0.87474, 0, 0, 13);
G2L["85"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["85"]["Text"] = [[random title]];
G2L["85"]["Name"] = [[Title]];
G2L["85"]["Position"] = UDim2.new(0, 10, 0.1, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button
G2L["86"] = Instance.new("Frame", G2L["79"]);
G2L["86"]["BorderSizePixel"] = 0;
G2L["86"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
G2L["86"]["Size"] = UDim2.new(1, -10, 0, 35);
G2L["86"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["86"]["Name"] = [[Button]];


-- StarterGui.AdminUI.setsettings.Container.List.Button.UICorner
G2L["87"] = Instance.new("UICorner", G2L["86"]);
G2L["87"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.Button.Title
G2L["88"] = Instance.new("TextLabel", G2L["86"]);
G2L["88"]["TextWrapped"] = true;
G2L["88"]["BorderSizePixel"] = 0;
G2L["88"]["TextSize"] = 14;
G2L["88"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["88"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["88"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["88"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["88"]["BackgroundTransparency"] = 1;
G2L["88"]["RichText"] = true;
G2L["88"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["88"]["Size"] = UDim2.new(0, 188, 0, 14);
G2L["88"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["88"]["Text"] = [[Button Name]];
G2L["88"]["Name"] = [[Title]];
G2L["88"]["Position"] = UDim2.new(0, 15, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button.Interact
G2L["89"] = Instance.new("TextButton", G2L["86"]);
G2L["89"]["BorderSizePixel"] = 0;
G2L["89"]["TextTransparency"] = 1;
G2L["89"]["TextSize"] = 14;
G2L["89"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["89"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["89"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["89"]["ZIndex"] = 5;
G2L["89"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["89"]["BackgroundTransparency"] = 1;
G2L["89"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["89"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["89"]["Text"] = [[]];
G2L["89"]["Name"] = [[Interact]];
G2L["89"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.Button.ElementIndicator
G2L["8a"] = Instance.new("TextLabel", G2L["86"]);
G2L["8a"]["TextWrapped"] = true;
G2L["8a"]["BorderSizePixel"] = 0;
G2L["8a"]["TextSize"] = 14;
G2L["8a"]["TextXAlignment"] = Enum.TextXAlignment.Right;
G2L["8a"]["TextTransparency"] = 0.9;
G2L["8a"]["TextScaled"] = true;
G2L["8a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["8a"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["8a"]["BackgroundTransparency"] = 1;
G2L["8a"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["8a"]["Size"] = UDim2.new(0, 108, 0, 13);
G2L["8a"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["8a"]["Text"] = [[button]];
G2L["8a"]["Name"] = [[ElementIndicator]];
G2L["8a"]["Position"] = UDim2.new(1, -10, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker
G2L["8b"] = Instance.new("Frame", G2L["79"]);
G2L["8b"]["BorderSizePixel"] = 0;
G2L["8b"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
G2L["8b"]["Size"] = UDim2.new(1, -10, 0, 120);
G2L["8b"]["Position"] = UDim2.new(0.01053, 0, 0.57377, 0);
G2L["8b"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["8b"]["Name"] = [[ColorPicker]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.UICorner
G2L["8c"] = Instance.new("UICorner", G2L["8b"]);
G2L["8c"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.Interact
G2L["8d"] = Instance.new("TextButton", G2L["8b"]);
G2L["8d"]["BorderSizePixel"] = 0;
G2L["8d"]["TextTransparency"] = 1;
G2L["8d"]["TextSize"] = 14;
G2L["8d"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["8d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["8d"]["ZIndex"] = 5;
G2L["8d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["8d"]["BackgroundTransparency"] = 1;
G2L["8d"]["Size"] = UDim2.new(0.57419, 0, 1, 0);
G2L["8d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["8d"]["Text"] = [[]];
G2L["8d"]["Name"] = [[Interact]];
G2L["8d"]["Position"] = UDim2.new(0.28925, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground
G2L["8e"] = Instance.new("Frame", G2L["8b"]);
G2L["8e"]["BorderSizePixel"] = 0;
G2L["8e"]["BackgroundColor3"] = Color3.fromRGB(99, 255, 0);
G2L["8e"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["8e"]["Size"] = UDim2.new(0, 173, 0, 86);
G2L["8e"]["Position"] = UDim2.new(0, 449, 0, 11);
G2L["8e"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["8e"]["Name"] = [[CPBackground]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP
G2L["8f"] = Instance.new("ImageButton", G2L["8e"]);
G2L["8f"]["BorderSizePixel"] = 0;
G2L["8f"]["ImageTransparency"] = 0.1;
G2L["8f"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["8f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["8f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["8f"]["Image"] = [[http://www.roblox.com/asset/?id=11413591840]];
G2L["8f"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["8f"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["8f"]["Name"] = [[MainCP]];
G2L["8f"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP.UICorner
G2L["90"] = Instance.new("UICorner", G2L["8f"]);
G2L["90"]["CornerRadius"] = UDim.new(0, 5);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.MainCP.MainPoint
G2L["91"] = Instance.new("ImageButton", G2L["8f"]);
G2L["91"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["91"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["91"]["ImageColor3"] = Color3.fromRGB(29, 73, 0);
G2L["91"]["Image"] = [[http://www.roblox.com/asset/?id=3259050989]];
G2L["91"]["Size"] = UDim2.new(0, 59, 0, 59);
G2L["91"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["91"]["Name"] = [[MainPoint]];
G2L["91"]["Position"] = UDim2.new(0.18282, 0, 0.24896, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.UICorner
G2L["92"] = Instance.new("UICorner", G2L["8e"]);
G2L["92"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display
G2L["93"] = Instance.new("Frame", G2L["8e"]);
G2L["93"]["BackgroundColor3"] = Color3.fromRGB(99, 255, 0);
G2L["93"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["93"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["93"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["93"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["93"]["Name"] = [[Display]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.UICorner
G2L["94"] = Instance.new("UICorner", G2L["93"]);
G2L["94"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.Frame
G2L["95"] = Instance.new("Frame", G2L["93"]);
G2L["95"]["BorderSizePixel"] = 0;
G2L["95"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["95"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["95"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["95"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["95"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["95"]["BackgroundTransparency"] = 0.75;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.CPBackground.Display.Frame.UICorner
G2L["96"] = Instance.new("UICorner", G2L["95"]);
G2L["96"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput
G2L["97"] = Instance.new("Frame", G2L["8b"]);
G2L["97"]["ZIndex"] = 10;
G2L["97"]["BorderSizePixel"] = 0;
G2L["97"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["97"]["Size"] = UDim2.new(0, 119, 0, 31);
G2L["97"]["Position"] = UDim2.new(0, 17, 0, 73);
G2L["97"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["97"]["Name"] = [[HexInput]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.UICorner
G2L["98"] = Instance.new("UICorner", G2L["97"]);
G2L["98"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.UIStroke
G2L["99"] = Instance.new("UIStroke", G2L["97"]);
G2L["99"]["Color"] = Color3.fromRGB(61, 61, 61);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.HexInput.InputBox
G2L["9a"] = Instance.new("TextBox", G2L["97"]);
G2L["9a"]["Name"] = [[InputBox]];
G2L["9a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9a"]["ZIndex"] = 10;
G2L["9a"]["BorderSizePixel"] = 0;
G2L["9a"]["TextSize"] = 14;
G2L["9a"]["TextColor3"] = Color3.fromRGB(201, 201, 201);
G2L["9a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["9a"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9a"]["ClearTextOnFocus"] = false;
G2L["9a"]["PlaceholderText"] = [[hex]];
G2L["9a"]["Size"] = UDim2.new(0.97962, -15, 0, 14);
G2L["9a"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["9a"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["9a"]["Text"] = [[]];
G2L["9a"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider
G2L["9b"] = Instance.new("ImageButton", G2L["8b"]);
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["9b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9b"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["9b"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
G2L["9b"]["Size"] = UDim2.new(0, 173, 0, 12);
G2L["9b"]["ClipsDescendants"] = true;
G2L["9b"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["9b"]["Name"] = [[ColorSlider]];
G2L["9b"]["Position"] = UDim2.new(0, 449, 0, 102);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.UIGradient
G2L["9c"] = Instance.new("UIGradient", G2L["9b"]);
G2L["9c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),ColorSequenceKeypoint.new(0.056, Color3.fromRGB(255, 86, 0)),ColorSequenceKeypoint.new(0.111, Color3.fromRGB(255, 171, 0)),ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),ColorSequenceKeypoint.new(0.223, Color3.fromRGB(170, 255, 0)),ColorSequenceKeypoint.new(0.279, Color3.fromRGB(84, 255, 0)),ColorSequenceKeypoint.new(0.334, Color3.fromRGB(0, 255, 2)),ColorSequenceKeypoint.new(0.390, Color3.fromRGB(0, 255, 87)),ColorSequenceKeypoint.new(0.446, Color3.fromRGB(0, 255, 172)),ColorSequenceKeypoint.new(0.501, Color3.fromRGB(0, 253, 255)),ColorSequenceKeypoint.new(0.557, Color3.fromRGB(0, 168, 255)),ColorSequenceKeypoint.new(0.613, Color3.fromRGB(0, 83, 255)),ColorSequenceKeypoint.new(0.669, Color3.fromRGB(3, 0, 255)),ColorSequenceKeypoint.new(0.724, Color3.fromRGB(89, 0, 255)),ColorSequenceKeypoint.new(0.780, Color3.fromRGB(174, 0, 255)),ColorSequenceKeypoint.new(0.836, Color3.fromRGB(255, 0, 252)),ColorSequenceKeypoint.new(0.891, Color3.fromRGB(255, 0, 167)),ColorSequenceKeypoint.new(0.947, Color3.fromRGB(255, 0, 81)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))};


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.SliderPoint
G2L["9d"] = Instance.new("ImageButton", G2L["9b"]);
G2L["9d"]["BackgroundTransparency"] = 1;
-- [ERROR] cannot convert ImageContent, please report to "https://github.com/uniquadev/GuiToLuaConverter/issues"
G2L["9d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9d"]["ImageColor3"] = Color3.fromRGB(0, 255, 0);
G2L["9d"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["9d"]["Image"] = [[http://www.roblox.com/asset/?id=3259050989]];
G2L["9d"]["Size"] = UDim2.new(0, 59, 0, 59);
G2L["9d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["9d"]["Name"] = [[SliderPoint]];
G2L["9d"]["Position"] = UDim2.new(0.182, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.TintAdder
G2L["9e"] = Instance.new("TextLabel", G2L["9b"]);
G2L["9e"]["TextSize"] = 14;
G2L["9e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["9e"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9e"]["BackgroundTransparency"] = 0.8;
G2L["9e"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["9e"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["9e"]["Text"] = [[]];
G2L["9e"]["Name"] = [[TintAdder]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.TintAdder.UICorner
G2L["9f"] = Instance.new("UICorner", G2L["9e"]);
G2L["9f"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.ColorSlider.UICorner
G2L["a0"] = Instance.new("UICorner", G2L["9b"]);
G2L["a0"]["CornerRadius"] = UDim.new(0, 6);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.Title
G2L["a1"] = Instance.new("TextLabel", G2L["8b"]);
G2L["a1"]["TextWrapped"] = true;
G2L["a1"]["ZIndex"] = 3;
G2L["a1"]["BorderSizePixel"] = 0;
G2L["a1"]["TextSize"] = 14;
G2L["a1"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["a1"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a1"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["a1"]["TextColor3"] = Color3.fromRGB(241, 241, 241);
G2L["a1"]["BackgroundTransparency"] = 1;
G2L["a1"]["RichText"] = true;
G2L["a1"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a1"]["Size"] = UDim2.new(0, 237, 0, 14);
G2L["a1"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["a1"]["Text"] = [[Color Picker]];
G2L["a1"]["Name"] = [[Title]];
G2L["a1"]["Position"] = UDim2.new(0, 135, 0, 22);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB
G2L["a2"] = Instance.new("Frame", G2L["8b"]);
G2L["a2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a2"]["Size"] = UDim2.new(0, 232, 0, 29);
G2L["a2"]["Position"] = UDim2.new(0, 17, 0, 40);
G2L["a2"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["a2"]["Name"] = [[RGB]];
G2L["a2"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.UIListLayout
G2L["a3"] = Instance.new("UIListLayout", G2L["a2"]);
G2L["a3"]["Padding"] = UDim.new(0, 5);
G2L["a3"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
G2L["a3"]["FillDirection"] = Enum.FillDirection.Horizontal;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput
G2L["a4"] = Instance.new("Frame", G2L["a2"]);
G2L["a4"]["ZIndex"] = 10;
G2L["a4"]["BorderSizePixel"] = 0;
G2L["a4"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["a4"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["a4"]["Size"] = UDim2.new(0, 54, 0, 27);
G2L["a4"]["Position"] = UDim2.new(0.35977, -7, 0.49583, 0);
G2L["a4"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["a4"]["Name"] = [[GInput]];
G2L["a4"]["LayoutOrder"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.UICorner
G2L["a5"] = Instance.new("UICorner", G2L["a4"]);
G2L["a5"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.InputBox
G2L["a6"] = Instance.new("TextBox", G2L["a4"]);
G2L["a6"]["Name"] = [[InputBox]];
G2L["a6"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["a6"]["ZIndex"] = 10;
G2L["a6"]["BorderSizePixel"] = 0;
G2L["a6"]["TextSize"] = 12;
G2L["a6"]["TextColor3"] = Color3.fromRGB(201, 201, 201);
G2L["a6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["a6"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["a6"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["a6"]["ClearTextOnFocus"] = false;
G2L["a6"]["PlaceholderText"] = [[G]];
G2L["a6"]["Size"] = UDim2.new(0.874, -15, 0, 14);
G2L["a6"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["a6"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["a6"]["Text"] = [[]];
G2L["a6"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.GInput.UIStroke
G2L["a7"] = Instance.new("UIStroke", G2L["a4"]);
G2L["a7"]["Color"] = Color3.fromRGB(61, 61, 61);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput
G2L["a8"] = Instance.new("Frame", G2L["a2"]);
G2L["a8"]["ZIndex"] = 10;
G2L["a8"]["BorderSizePixel"] = 0;
G2L["a8"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["a8"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["a8"]["Size"] = UDim2.new(0, 54, 0, 27);
G2L["a8"]["Position"] = UDim2.new(0.18152, -5, 0.49583, 0);
G2L["a8"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["a8"]["Name"] = [[RInput]];


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.UICorner
G2L["a9"] = Instance.new("UICorner", G2L["a8"]);
G2L["a9"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.InputBox
G2L["aa"] = Instance.new("TextBox", G2L["a8"]);
G2L["aa"]["Name"] = [[InputBox]];
G2L["aa"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["aa"]["ZIndex"] = 10;
G2L["aa"]["BorderSizePixel"] = 0;
G2L["aa"]["TextSize"] = 12;
G2L["aa"]["TextColor3"] = Color3.fromRGB(201, 201, 201);
G2L["aa"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["aa"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["aa"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["aa"]["ClearTextOnFocus"] = false;
G2L["aa"]["PlaceholderText"] = [[R]];
G2L["aa"]["Size"] = UDim2.new(0.87372, -15, 0, 14);
G2L["aa"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["aa"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["aa"]["Text"] = [[]];
G2L["aa"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.RInput.UIStroke
G2L["ab"] = Instance.new("UIStroke", G2L["a8"]);
G2L["ab"]["Color"] = Color3.fromRGB(61, 61, 61);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput
G2L["ac"] = Instance.new("Frame", G2L["a2"]);
G2L["ac"]["ZIndex"] = 10;
G2L["ac"]["BorderSizePixel"] = 0;
G2L["ac"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["ac"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["ac"]["Size"] = UDim2.new(0, 54, 0, 27);
G2L["ac"]["Position"] = UDim2.new(0.9278, -5, 0.46552, 0);
G2L["ac"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["ac"]["Name"] = [[BInput]];
G2L["ac"]["LayoutOrder"] = 2;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.UICorner
G2L["ad"] = Instance.new("UICorner", G2L["ac"]);
G2L["ad"]["CornerRadius"] = UDim.new(0, 10);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.InputBox
G2L["ae"] = Instance.new("TextBox", G2L["ac"]);
G2L["ae"]["Name"] = [[InputBox]];
G2L["ae"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["ae"]["ZIndex"] = 10;
G2L["ae"]["BorderSizePixel"] = 0;
G2L["ae"]["TextSize"] = 12;
G2L["ae"]["TextColor3"] = Color3.fromRGB(201, 201, 201);
G2L["ae"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ae"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["ae"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ae"]["ClearTextOnFocus"] = false;
G2L["ae"]["PlaceholderText"] = [[B]];
G2L["ae"]["Size"] = UDim2.new(0.874, -15, 0, 14);
G2L["ae"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["ae"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["ae"]["Text"] = [[]];
G2L["ae"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.RGB.BInput.UIStroke
G2L["af"] = Instance.new("UIStroke", G2L["ac"]);
G2L["af"]["Color"] = Color3.fromRGB(61, 61, 61);


-- StarterGui.AdminUI.setsettings.Container.List.ColorPicker.UIStroke
G2L["b0"] = Instance.new("UIStroke", G2L["8b"]);
G2L["b0"]["Color"] = Color3.fromRGB(51, 51, 51);


-- StarterGui.AdminUI.setsettings.Container.UICorner
G2L["b1"] = Instance.new("UICorner", G2L["78"]);
G2L["b1"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.setsettings.Container.UIGradient
G2L["b2"] = Instance.new("UIGradient", G2L["78"]);
G2L["b2"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(15, 7, 23)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(15, 7, 23))};


-- StarterGui.AdminUI.setsettings.Topbar
G2L["b3"] = Instance.new("Frame", G2L["77"]);
G2L["b3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["b3"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["b3"]["Name"] = [[Topbar]];
G2L["b3"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.setsettings.Topbar.Exit
G2L["b4"] = Instance.new("TextButton", G2L["b3"]);
G2L["b4"]["TextWrapped"] = true;
G2L["b4"]["BorderSizePixel"] = 0;
G2L["b4"]["TextSize"] = 13;
G2L["b4"]["TextScaled"] = true;
G2L["b4"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["b4"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
G2L["b4"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["b4"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b4"]["BackgroundTransparency"] = 0.5;
G2L["b4"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["b4"]["Text"] = [[X]];
G2L["b4"]["Name"] = [[Exit]];
G2L["b4"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Topbar.Exit.UICorners
G2L["b5"] = Instance.new("UICorner", G2L["b4"]);
G2L["b5"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.setsettings.Topbar.Exit.UIStroker
G2L["b6"] = Instance.new("UIStroke", G2L["b4"]);
G2L["b6"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["b6"]["Name"] = [[UIStroker]];
G2L["b6"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.setsettings.Topbar.Minimize
G2L["b7"] = Instance.new("TextButton", G2L["b3"]);
G2L["b7"]["TextWrapped"] = true;
G2L["b7"]["BorderSizePixel"] = 0;
G2L["b7"]["TextSize"] = 13;
G2L["b7"]["TextScaled"] = true;
G2L["b7"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["b7"]["BackgroundColor3"] = Color3.fromRGB(15, 7, 23);
G2L["b7"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["b7"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["b7"]["BackgroundTransparency"] = 0.5;
G2L["b7"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["b7"]["Text"] = [[-]];
G2L["b7"]["Name"] = [[Minimize]];
G2L["b7"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.setsettings.Topbar.Minimize.UICorners
G2L["b8"] = Instance.new("UICorner", G2L["b7"]);
G2L["b8"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.setsettings.Topbar.Minimize.UIStroker
G2L["b9"] = Instance.new("UIStroke", G2L["b7"]);
G2L["b9"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["b9"]["Name"] = [[UIStroker]];
G2L["b9"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.setsettings.Topbar.Title
G2L["ba"] = Instance.new("TextLabel", G2L["b3"]);
G2L["ba"]["TextWrapped"] = true;
G2L["ba"]["BorderSizePixel"] = 0;
G2L["ba"]["TextSize"] = 17;
G2L["ba"]["TextScaled"] = true;
G2L["ba"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["ba"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["ba"]["TextColor3"] = Color3.fromRGB(244, 244, 244);
G2L["ba"]["BackgroundTransparency"] = 1;
G2L["ba"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["ba"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["ba"]["Text"] = [[Settings]];
G2L["ba"]["Name"] = [[Title]];
G2L["ba"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.setsettings.UICorners
G2L["bb"] = Instance.new("UICorner", G2L["77"]);
G2L["bb"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.setsettings.UIStroker
G2L["bc"] = Instance.new("UIStroke", G2L["77"]);
G2L["bc"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["bc"]["Name"] = [[UIStroker]];
G2L["bc"]["Color"] = Color3.fromRGB(148, 93, 255);


-- StarterGui.AdminUI.setsettings.UIGradients
G2L["bd"] = Instance.new("UIGradient", G2L["77"]);
G2L["bd"]["Name"] = [[UIGradients]];
G2L["bd"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(43, 43, 49)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(21, 21, 25))};



return G2L["1"], require;