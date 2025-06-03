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
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["5"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(28, 28, 28);
G2L["5"]["Name"] = [[Horizontal]];
G2L["5"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UICorners
G2L["6"] = Instance.new("UICorner", G2L["5"]);
G2L["6"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UIStroker
G2L["7"] = Instance.new("UIStroke", G2L["5"]);
G2L["7"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["7"]["Name"] = [[UIStroker]];
G2L["7"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.CmdBar.CenterBar.Horizontal.UIGradients
G2L["8"] = Instance.new("UIGradient", G2L["5"]);
G2L["8"]["Name"] = [[UIGradients]];
G2L["8"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.CmdBar.CenterBar.Input
G2L["9"] = Instance.new("TextBox", G2L["4"]);
G2L["9"]["Active"] = false;
G2L["9"]["Name"] = [[Input]];
G2L["9"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9"]["ZIndex"] = 2;
G2L["9"]["TextWrapped"] = true;
G2L["9"]["TextSize"] = 24;
G2L["9"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["9"]["TextScaled"] = true;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["9"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9"]["ClipsDescendants"] = true;
G2L["9"]["Size"] = UDim2.new(1, -5, 0.7, 0);
G2L["9"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["9"]["Text"] = [[]];
G2L["9"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.LeftFill
G2L["a"] = Instance.new("Frame", G2L["3"]);
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["a"]["Size"] = UDim2.new(0.5, -125, 1, 0);
G2L["a"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["a"]["Name"] = [[LeftFill]];
G2L["a"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal
G2L["b"] = Instance.new("Frame", G2L["a"]);
G2L["b"]["BorderSizePixel"] = 0;
G2L["b"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["b"]["Size"] = UDim2.new(1.00599, 0, 1, 0);
G2L["b"]["BorderColor3"] = Color3.fromRGB(28, 28, 28);
G2L["b"]["Name"] = [[Horizontal]];
G2L["b"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UICorners
G2L["c"] = Instance.new("UICorner", G2L["b"]);
G2L["c"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UIStroker
G2L["d"] = Instance.new("UIStroke", G2L["b"]);
G2L["d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["d"]["Name"] = [[UIStroker]];
G2L["d"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.CmdBar.LeftFill.Horizontal.UIGradients
G2L["e"] = Instance.new("UIGradient", G2L["b"]);
G2L["e"]["Name"] = [[UIGradients]];
G2L["e"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.CmdBar.RightFill
G2L["f"] = Instance.new("Frame", G2L["3"]);
G2L["f"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["f"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["f"]["Size"] = UDim2.new(0.5, -125, 1, 0);
G2L["f"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["f"]["Name"] = [[RightFill]];
G2L["f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal
G2L["10"] = Instance.new("Frame", G2L["f"]);
G2L["10"]["BorderSizePixel"] = 0;
G2L["10"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["10"]["Size"] = UDim2.new(1.00798, 0, 1, 0);
G2L["10"]["Position"] = UDim2.new(-0.00798, 0, 0, 0);
G2L["10"]["BorderColor3"] = Color3.fromRGB(28, 28, 28);
G2L["10"]["Name"] = [[Horizontal]];
G2L["10"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UICorners
G2L["11"] = Instance.new("UICorner", G2L["10"]);
G2L["11"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UIStroker
G2L["12"] = Instance.new("UIStroke", G2L["10"]);
G2L["12"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["12"]["Name"] = [[UIStroker]];
G2L["12"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.CmdBar.RightFill.Horizontal.UIGradients
G2L["13"] = Instance.new("UIGradient", G2L["10"]);
G2L["13"]["Name"] = [[UIGradients]];
G2L["13"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.CmdBar.Autofill
G2L["14"] = Instance.new("ScrollingFrame", G2L["3"]);
G2L["14"]["CanvasSize"] = UDim2.new(0, 0, 5, 0);
G2L["14"]["ScrollingEnabled"] = false;
G2L["14"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["14"]["Name"] = [[Autofill]];
G2L["14"]["Selectable"] = false;
G2L["14"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["14"]["Size"] = UDim2.new(1, 0, 0, 138);
G2L["14"]["Position"] = UDim2.new(0.5, 0, -6.52, 10);
G2L["14"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd
G2L["15"] = Instance.new("Frame", G2L["14"]);
G2L["15"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["15"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["15"]["Size"] = UDim2.new(0.5, 0, 0, 25);
G2L["15"]["Position"] = UDim2.new(0.5, 0, 0.81884, 0);
G2L["15"]["Name"] = [[Cmd]];
G2L["15"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Input
G2L["16"] = Instance.new("TextLabel", G2L["15"]);
G2L["16"]["TextWrapped"] = true;
G2L["16"]["Active"] = true;
G2L["16"]["ZIndex"] = 2;
G2L["16"]["TextSize"] = 24;
G2L["16"]["TextScaled"] = true;
G2L["16"]["BackgroundColor3"] = Color3.fromRGB(18, 18, 18);
G2L["16"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["16"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["16"]["BackgroundTransparency"] = 1;
G2L["16"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["16"]["Size"] = UDim2.new(1, 0, 1, -5);
G2L["16"]["ClipsDescendants"] = true;
G2L["16"]["Text"] = [[example <player> <text>]];
G2L["16"]["Selectable"] = true;
G2L["16"]["Name"] = [[Input]];
G2L["16"]["Position"] = UDim2.new(0, 0, 0.5, 0);


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background
G2L["17"] = Instance.new("Frame", G2L["15"]);
G2L["17"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["17"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["17"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["17"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["17"]["Name"] = [[Background]];
G2L["17"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal
G2L["18"] = Instance.new("Frame", G2L["17"]);
G2L["18"]["BorderSizePixel"] = 0;
G2L["18"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["18"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["18"]["Name"] = [[Horizontal]];
G2L["18"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UICorners
G2L["19"] = Instance.new("UICorner", G2L["18"]);
G2L["19"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UIStroker
G2L["1a"] = Instance.new("UIStroke", G2L["18"]);
G2L["1a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["1a"]["Name"] = [[UIStroker]];
G2L["1a"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.CmdBar.Autofill.Cmd.Background.Horizontal.UIGradients
G2L["1b"] = Instance.new("UIGradient", G2L["18"]);
G2L["1b"]["Name"] = [[UIGradients]];
G2L["1b"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.CmdBar.Autofill.UIListLayout
G2L["1c"] = Instance.new("UIListLayout", G2L["14"]);
G2L["1c"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["1c"]["Padding"] = UDim.new(0, 3);
G2L["1c"]["VerticalAlignment"] = Enum.VerticalAlignment.Bottom;
G2L["1c"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.Commands
G2L["1d"] = Instance.new("Frame", G2L["1"]);
G2L["1d"]["BorderSizePixel"] = 0;
G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["1d"]["Size"] = UDim2.new(0, 283, 0, 286);
G2L["1d"]["Position"] = UDim2.new(0.01855, 0, 0.52493, 0);
G2L["1d"]["BorderColor3"] = Color3.fromRGB(140, 140, 140);
G2L["1d"]["Name"] = [[Commands]];
G2L["1d"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.Commands.Container
G2L["1e"] = Instance.new("Frame", G2L["1d"]);
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1e"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["1e"]["ClipsDescendants"] = true;
G2L["1e"]["Size"] = UDim2.new(1, -10, 1.01154, -30);
G2L["1e"]["Position"] = UDim2.new(0.5, 0, 1, -5);
G2L["1e"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1e"]["Name"] = [[Container]];
G2L["1e"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.Commands.Container.List
G2L["1f"] = Instance.new("ScrollingFrame", G2L["1e"]);
G2L["1f"]["BorderSizePixel"] = 0;
G2L["1f"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["1f"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1f"]["Name"] = [[List]];
G2L["1f"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["1f"]["Size"] = UDim2.new(1, -10, 1, -27);
G2L["1f"]["Position"] = UDim2.new(0, 6, 0, 27);
G2L["1f"]["BorderColor3"] = Color3.fromRGB(17, 17, 17);
G2L["1f"]["ScrollBarThickness"] = 4;
G2L["1f"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Commands.Container.List.UIListLayout
G2L["20"] = Instance.new("UIListLayout", G2L["1f"]);
G2L["20"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["20"]["Padding"] = UDim.new(0, 2);


-- StarterGui.AdminUI.Commands.Container.List.TextLabel
G2L["21"] = Instance.new("TextLabel", G2L["1f"]);
G2L["21"]["TextWrapped"] = true;
G2L["21"]["TextSize"] = 15;
G2L["21"]["TextScaled"] = true;
G2L["21"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["21"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["21"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["21"]["BackgroundTransparency"] = 1;
G2L["21"]["Size"] = UDim2.new(1, 0, 0, 20);
G2L["21"]["Text"] = [[example <player> <text>]];
G2L["21"]["Position"] = UDim2.new(0, 0, 0.01739, 0);


-- StarterGui.AdminUI.Commands.Container.Filter
G2L["22"] = Instance.new("TextBox", G2L["1e"]);
G2L["22"]["Name"] = [[Filter]];
G2L["22"]["PlaceholderColor3"] = Color3.fromRGB(125, 125, 125);
G2L["22"]["BorderSizePixel"] = 0;
G2L["22"]["TextSize"] = 18;
G2L["22"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["22"]["BackgroundColor3"] = Color3.fromRGB(5, 5, 5);
G2L["22"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["22"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["22"]["PlaceholderText"] = [[Filter commands...]];
G2L["22"]["Size"] = UDim2.new(1, -10, 0, 20);
G2L["22"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["22"]["Text"] = [[]];
G2L["22"]["BackgroundTransparency"] = 0.7;


-- StarterGui.AdminUI.Commands.Container.Filter.UICorner
G2L["23"] = Instance.new("UICorner", G2L["22"]);
G2L["23"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.Commands.Container.UICorner
G2L["24"] = Instance.new("UICorner", G2L["1e"]);
G2L["24"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.Commands.Container.UIGradient
G2L["25"] = Instance.new("UIGradient", G2L["1e"]);
G2L["25"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(13, 5, 21))};


-- StarterGui.AdminUI.Commands.Topbar
G2L["26"] = Instance.new("Frame", G2L["1d"]);
G2L["26"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["26"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["26"]["Name"] = [[Topbar]];
G2L["26"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Commands.Topbar.Exit
G2L["27"] = Instance.new("TextButton", G2L["26"]);
G2L["27"]["TextWrapped"] = true;
G2L["27"]["BorderSizePixel"] = 0;
G2L["27"]["TextSize"] = 13;
G2L["27"]["TextScaled"] = true;
G2L["27"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["27"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["27"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["27"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["27"]["BackgroundTransparency"] = 0.5;
G2L["27"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["27"]["Text"] = [[X]];
G2L["27"]["Name"] = [[Exit]];
G2L["27"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.Commands.Topbar.Exit.UICorners
G2L["28"] = Instance.new("UICorner", G2L["27"]);
G2L["28"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.Commands.Topbar.Exit.UIStroker
G2L["29"] = Instance.new("UIStroke", G2L["27"]);
G2L["29"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["29"]["Name"] = [[UIStroker]];
G2L["29"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.Commands.Topbar.Minimize
G2L["2a"] = Instance.new("TextButton", G2L["26"]);
G2L["2a"]["TextWrapped"] = true;
G2L["2a"]["BorderSizePixel"] = 0;
G2L["2a"]["TextSize"] = 13;
G2L["2a"]["TextScaled"] = true;
G2L["2a"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["2a"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["2a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["2a"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["2a"]["BackgroundTransparency"] = 0.5;
G2L["2a"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["2a"]["Text"] = [[-]];
G2L["2a"]["Name"] = [[Minimize]];
G2L["2a"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.Commands.Topbar.Minimize.UICorners
G2L["2b"] = Instance.new("UICorner", G2L["2a"]);
G2L["2b"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.Commands.Topbar.Minimize.UIStroker
G2L["2c"] = Instance.new("UIStroke", G2L["2a"]);
G2L["2c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["2c"]["Name"] = [[UIStroker]];
G2L["2c"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.Commands.Topbar.Title
G2L["2d"] = Instance.new("TextLabel", G2L["26"]);
G2L["2d"]["TextWrapped"] = true;
G2L["2d"]["BorderSizePixel"] = 0;
G2L["2d"]["TextSize"] = 17;
G2L["2d"]["TextScaled"] = true;
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["2d"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["2d"]["BackgroundTransparency"] = 1;
G2L["2d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["2d"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["2d"]["Text"] = [[Commands]];
G2L["2d"]["Name"] = [[Title]];
G2L["2d"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.Commands.UICorners
G2L["2e"] = Instance.new("UICorner", G2L["1d"]);
G2L["2e"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.Commands.UIStroker
G2L["2f"] = Instance.new("UIStroke", G2L["1d"]);
G2L["2f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["2f"]["Name"] = [[UIStroker]];
G2L["2f"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.Commands.UIGradients
G2L["30"] = Instance.new("UIGradient", G2L["1d"]);
G2L["30"]["Name"] = [[UIGradients]];
G2L["30"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.Resizeable
G2L["31"] = Instance.new("Frame", G2L["1"]);
G2L["31"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["31"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["31"]["Name"] = [[Resizeable]];
G2L["31"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Left
G2L["32"] = Instance.new("Frame", G2L["31"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["32"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["32"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["32"]["Position"] = UDim2.new(0, 0, 0.5, 0);
G2L["32"]["Name"] = [[Left]];
G2L["32"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Right
G2L["33"] = Instance.new("Frame", G2L["31"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["33"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["33"]["Size"] = UDim2.new(0, 8, 1, -8);
G2L["33"]["Position"] = UDim2.new(1, 0, 0.5, 0);
G2L["33"]["Name"] = [[Right]];
G2L["33"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Top
G2L["34"] = Instance.new("Frame", G2L["31"]);
G2L["34"]["BorderSizePixel"] = 0;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["34"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["34"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["34"]["Position"] = UDim2.new(0.5, 0, 0, 0);
G2L["34"]["Name"] = [[Top]];
G2L["34"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.Bottom
G2L["35"] = Instance.new("Frame", G2L["31"]);
G2L["35"]["BorderSizePixel"] = 0;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["35"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["35"]["Size"] = UDim2.new(1, -8, 0, 8);
G2L["35"]["Position"] = UDim2.new(0.5, 0, 1, 0);
G2L["35"]["Name"] = [[Bottom]];
G2L["35"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopLeft
G2L["36"] = Instance.new("Frame", G2L["31"]);
G2L["36"]["BorderSizePixel"] = 0;
G2L["36"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["36"]["AnchorPoint"] = Vector2.new(1, 1);
G2L["36"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["36"]["Position"] = UDim2.new(0, 4, 0, 4);
G2L["36"]["Name"] = [[TopLeft]];
G2L["36"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.TopRight
G2L["37"] = Instance.new("Frame", G2L["31"]);
G2L["37"]["BorderSizePixel"] = 0;
G2L["37"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["37"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["37"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["37"]["Position"] = UDim2.new(1, -4, 0, 4);
G2L["37"]["Name"] = [[TopRight]];
G2L["37"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomLeft
G2L["38"] = Instance.new("Frame", G2L["31"]);
G2L["38"]["BorderSizePixel"] = 0;
G2L["38"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["38"]["AnchorPoint"] = Vector2.new(1, 0);
G2L["38"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["38"]["Position"] = UDim2.new(0, 4, 1, -4);
G2L["38"]["Name"] = [[BottomLeft]];
G2L["38"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Resizeable.BottomRight
G2L["39"] = Instance.new("Frame", G2L["31"]);
G2L["39"]["BorderSizePixel"] = 0;
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(0, 201, 255);
G2L["39"]["Size"] = UDim2.new(0, 12, 0, 12);
G2L["39"]["Position"] = UDim2.new(1, -4, 1, -4);
G2L["39"]["Name"] = [[BottomRight]];
G2L["39"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.Description
G2L["3a"] = Instance.new("TextLabel", G2L["1"]);
G2L["3a"]["TextWrapped"] = true;
G2L["3a"]["TextSize"] = 13;
G2L["3a"]["TextScaled"] = true;
G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["3a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["3a"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["3a"]["BackgroundTransparency"] = 0.3;
G2L["3a"]["AnchorPoint"] = Vector2.new(0, 1);
G2L["3a"]["Size"] = UDim2.new(0, 191, 0, 26);
G2L["3a"]["Visible"] = false;
G2L["3a"]["BorderColor3"] = Color3.fromRGB(54, 54, 54);
G2L["3a"]["Text"] = [[Name]];
G2L["3a"]["Name"] = [[Description]];


-- StarterGui.AdminUI.Description.UICorner
G2L["3b"] = Instance.new("UICorner", G2L["3a"]);



-- StarterGui.AdminUI.UpdLog
G2L["3c"] = Instance.new("Frame", G2L["1"]);
G2L["3c"]["BorderSizePixel"] = 0;
G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["3c"]["Size"] = UDim2.new(0, 283, 0, 286);
G2L["3c"]["Position"] = UDim2.new(0.61871, 0, 0.03718, 0);
G2L["3c"]["BorderColor3"] = Color3.fromRGB(140, 140, 140);
G2L["3c"]["Name"] = [[UpdLog]];
G2L["3c"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.UpdLog.Container
G2L["3d"] = Instance.new("Frame", G2L["3c"]);
G2L["3d"]["BorderSizePixel"] = 0;
G2L["3d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3d"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["3d"]["ClipsDescendants"] = true;
G2L["3d"]["Size"] = UDim2.new(1, -10, 1.01154, -30);
G2L["3d"]["Position"] = UDim2.new(0.5, 0, 1, -5);
G2L["3d"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3d"]["Name"] = [[Container]];
G2L["3d"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.UpdLog.Container.List
G2L["3e"] = Instance.new("ScrollingFrame", G2L["3d"]);
G2L["3e"]["BorderSizePixel"] = 0;
G2L["3e"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["3e"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["3e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3e"]["Name"] = [[List]];
G2L["3e"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["3e"]["Size"] = UDim2.new(1, -10, 1.08012, -27);
G2L["3e"]["Position"] = UDim2.new(0, 6, 0, 6);
G2L["3e"]["BorderColor3"] = Color3.fromRGB(17, 17, 17);
G2L["3e"]["ScrollBarThickness"] = 4;
G2L["3e"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.UpdLog.Container.List.UIListLayout
G2L["3f"] = Instance.new("UIListLayout", G2L["3e"]);
G2L["3f"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
G2L["3f"]["Padding"] = UDim.new(0, 2);


-- StarterGui.AdminUI.UpdLog.Container.List.
G2L["40"] = Instance.new("TextLabel", G2L["3e"]);
G2L["40"]["TextWrapped"] = true;
G2L["40"]["BorderSizePixel"] = 0;
G2L["40"]["TextSize"] = 14;
G2L["40"]["TextScaled"] = true;
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["40"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["40"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["40"]["BackgroundTransparency"] = 1;
G2L["40"]["Size"] = UDim2.new(1, 0, 0, 35);
G2L["40"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["40"]["Text"] = [[- log 1 thingy]];
G2L["40"]["Name"] = [[]];


-- StarterGui.AdminUI.UpdLog.Container.UICorner
G2L["41"] = Instance.new("UICorner", G2L["3d"]);
G2L["41"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.UpdLog.Container.UIGradient
G2L["42"] = Instance.new("UIGradient", G2L["3d"]);
G2L["42"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(13, 5, 21))};


-- StarterGui.AdminUI.UpdLog.Topbar
G2L["43"] = Instance.new("Frame", G2L["3c"]);
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["43"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["43"]["Name"] = [[Topbar]];
G2L["43"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.UpdLog.Topbar.Exit
G2L["44"] = Instance.new("TextButton", G2L["43"]);
G2L["44"]["TextWrapped"] = true;
G2L["44"]["BorderSizePixel"] = 0;
G2L["44"]["TextSize"] = 13;
G2L["44"]["TextScaled"] = true;
G2L["44"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["44"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["44"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["44"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["44"]["BackgroundTransparency"] = 0.5;
G2L["44"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["44"]["Text"] = [[X]];
G2L["44"]["Name"] = [[Exit]];
G2L["44"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.UpdLog.Topbar.Exit.UICorners
G2L["45"] = Instance.new("UICorner", G2L["44"]);
G2L["45"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.UpdLog.Topbar.Exit.UIStroker
G2L["46"] = Instance.new("UIStroke", G2L["44"]);
G2L["46"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["46"]["Name"] = [[UIStroker]];
G2L["46"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.UpdLog.Topbar.Minimize
G2L["47"] = Instance.new("TextButton", G2L["43"]);
G2L["47"]["TextWrapped"] = true;
G2L["47"]["BorderSizePixel"] = 0;
G2L["47"]["TextSize"] = 13;
G2L["47"]["TextScaled"] = true;
G2L["47"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["47"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["47"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["47"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["47"]["BackgroundTransparency"] = 0.5;
G2L["47"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["47"]["Text"] = [[-]];
G2L["47"]["Name"] = [[Minimize]];
G2L["47"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.UpdLog.Topbar.Minimize.UICorners
G2L["48"] = Instance.new("UICorner", G2L["47"]);
G2L["48"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.UpdLog.Topbar.Minimize.UIStroker
G2L["49"] = Instance.new("UIStroke", G2L["47"]);
G2L["49"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["49"]["Name"] = [[UIStroker]];
G2L["49"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.UpdLog.Topbar.Title
G2L["4a"] = Instance.new("TextLabel", G2L["43"]);
G2L["4a"]["TextWrapped"] = true;
G2L["4a"]["BorderSizePixel"] = 0;
G2L["4a"]["TextSize"] = 17;
G2L["4a"]["TextScaled"] = true;
G2L["4a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["4a"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["4a"]["BackgroundTransparency"] = 1;
G2L["4a"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["4a"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["4a"]["Text"] = [[Update Log]];
G2L["4a"]["Name"] = [[Title]];
G2L["4a"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.UpdLog.UICorners
G2L["4b"] = Instance.new("UICorner", G2L["3c"]);
G2L["4b"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.UpdLog.UIStroker
G2L["4c"] = Instance.new("UIStroke", G2L["3c"]);
G2L["4c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["4c"]["Name"] = [[UIStroker]];
G2L["4c"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.UpdLog.UIGradients
G2L["4d"] = Instance.new("UIGradient", G2L["3c"]);
G2L["4d"]["Name"] = [[UIGradients]];
G2L["4d"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.ChatLogs
G2L["4e"] = Instance.new("Frame", G2L["1"]);
G2L["4e"]["BorderSizePixel"] = 0;
G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["4e"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["4e"]["Position"] = UDim2.new(0.65118, 0, 0.56114, 0);
G2L["4e"]["BorderColor3"] = Color3.fromRGB(140, 140, 140);
G2L["4e"]["Name"] = [[ChatLogs]];
G2L["4e"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.ChatLogs.Container
G2L["4f"] = Instance.new("Frame", G2L["4e"]);
G2L["4f"]["BorderSizePixel"] = 0;
G2L["4f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4f"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["4f"]["ClipsDescendants"] = true;
G2L["4f"]["Size"] = UDim2.new(1, -10, 1.00769, -30);
G2L["4f"]["Position"] = UDim2.new(0.49502, 0, 1.00379, -5);
G2L["4f"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4f"]["Name"] = [[Container]];
G2L["4f"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.ChatLogs.Container.Logs
G2L["50"] = Instance.new("ScrollingFrame", G2L["4f"]);
G2L["50"]["BorderSizePixel"] = 0;
G2L["50"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["50"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["50"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["50"]["Name"] = [[Logs]];
G2L["50"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["50"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["50"]["Size"] = UDim2.new(1, -10, 1, -10);
G2L["50"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["50"]["BorderColor3"] = Color3.fromRGB(17, 17, 17);
G2L["50"]["ScrollBarThickness"] = 4;
G2L["50"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.UIListLayout
G2L["51"] = Instance.new("UIListLayout", G2L["50"]);
G2L["51"]["Padding"] = UDim.new(0, 3);
G2L["51"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.ChatLogs.Container.Logs.TextLabel
G2L["52"] = Instance.new("TextLabel", G2L["50"]);
G2L["52"]["TextWrapped"] = true;
G2L["52"]["TextSize"] = 14;
G2L["52"]["TextScaled"] = true;
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["52"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["52"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["52"]["BackgroundTransparency"] = 1;
G2L["52"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["52"]["Text"] = [[[Roblox]: Hello,World!]];


-- StarterGui.AdminUI.ChatLogs.Container.UICorner
G2L["53"] = Instance.new("UICorner", G2L["4f"]);
G2L["53"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.ChatLogs.Container.UIGradient
G2L["54"] = Instance.new("UIGradient", G2L["4f"]);
G2L["54"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(13, 5, 21))};


-- StarterGui.AdminUI.ChatLogs.Topbar
G2L["55"] = Instance.new("Frame", G2L["4e"]);
G2L["55"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["55"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["55"]["Name"] = [[Topbar]];
G2L["55"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit
G2L["56"] = Instance.new("TextButton", G2L["55"]);
G2L["56"]["TextWrapped"] = true;
G2L["56"]["BorderSizePixel"] = 0;
G2L["56"]["TextSize"] = 13;
G2L["56"]["TextScaled"] = true;
G2L["56"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["56"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["56"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["56"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["56"]["BackgroundTransparency"] = 0.5;
G2L["56"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["56"]["Text"] = [[X]];
G2L["56"]["Name"] = [[Exit]];
G2L["56"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UICorners
G2L["57"] = Instance.new("UICorner", G2L["56"]);
G2L["57"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Exit.UIStroker
G2L["58"] = Instance.new("UIStroke", G2L["56"]);
G2L["58"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["58"]["Name"] = [[UIStroker]];
G2L["58"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize
G2L["59"] = Instance.new("TextButton", G2L["55"]);
G2L["59"]["TextWrapped"] = true;
G2L["59"]["BorderSizePixel"] = 0;
G2L["59"]["TextSize"] = 18;
G2L["59"]["TextScaled"] = true;
G2L["59"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["59"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["59"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["59"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["59"]["BackgroundTransparency"] = 0.5;
G2L["59"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["59"]["Text"] = [[-]];
G2L["59"]["Name"] = [[Minimize]];
G2L["59"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UICorners
G2L["5a"] = Instance.new("UICorner", G2L["59"]);
G2L["5a"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Minimize.UIStroker
G2L["5b"] = Instance.new("UIStroke", G2L["59"]);
G2L["5b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["5b"]["Name"] = [[UIStroker]];
G2L["5b"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear
G2L["5c"] = Instance.new("TextButton", G2L["55"]);
G2L["5c"]["TextWrapped"] = true;
G2L["5c"]["BorderSizePixel"] = 0;
G2L["5c"]["TextSize"] = 13;
G2L["5c"]["TextScaled"] = true;
G2L["5c"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["5c"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["5c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["5c"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["5c"]["BackgroundTransparency"] = 0.5;
G2L["5c"]["Size"] = UDim2.new(0, 48, 1, -8);
G2L["5c"]["Text"] = [[Clear]];
G2L["5c"]["Name"] = [[Clear]];
G2L["5c"]["Position"] = UDim2.new(0, 4, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UIStroker
G2L["5d"] = Instance.new("UIStroke", G2L["5c"]);
G2L["5d"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["5d"]["Name"] = [[UIStroker]];
G2L["5d"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.ChatLogs.Topbar.Clear.UICorners
G2L["5e"] = Instance.new("UICorner", G2L["5c"]);
G2L["5e"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.Topbar.Title
G2L["5f"] = Instance.new("TextLabel", G2L["55"]);
G2L["5f"]["TextWrapped"] = true;
G2L["5f"]["BorderSizePixel"] = 0;
G2L["5f"]["TextSize"] = 17;
G2L["5f"]["TextScaled"] = true;
G2L["5f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5f"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["5f"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["5f"]["BackgroundTransparency"] = 1;
G2L["5f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["5f"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["5f"]["Text"] = [[Chat Logs]];
G2L["5f"]["Name"] = [[Title]];
G2L["5f"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.ChatLogs.UICorners
G2L["60"] = Instance.new("UICorner", G2L["4e"]);
G2L["60"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.ChatLogs.UIStroker
G2L["61"] = Instance.new("UIStroke", G2L["4e"]);
G2L["61"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["61"]["Name"] = [[UIStroker]];
G2L["61"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.ChatLogs.UIGradients
G2L["62"] = Instance.new("UIGradient", G2L["4e"]);
G2L["62"]["Name"] = [[UIGradients]];
G2L["62"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.soRealConsole
G2L["63"] = Instance.new("Frame", G2L["1"]);
G2L["63"]["BorderSizePixel"] = 0;
G2L["63"]["BackgroundColor3"] = Color3.fromRGB(26, 27, 31);
G2L["63"]["Size"] = UDim2.new(0, 402, 0, 262);
G2L["63"]["Position"] = UDim2.new(0.31784, 0, 0.55079, 0);
G2L["63"]["BorderColor3"] = Color3.fromRGB(140, 140, 140);
G2L["63"]["Name"] = [[soRealConsole]];
G2L["63"]["BackgroundTransparency"] = 0.14;


-- StarterGui.AdminUI.soRealConsole.Container
G2L["64"] = Instance.new("Frame", G2L["63"]);
G2L["64"]["BorderSizePixel"] = 0;
G2L["64"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["64"]["AnchorPoint"] = Vector2.new(0.5, 1);
G2L["64"]["ClipsDescendants"] = true;
G2L["64"]["Size"] = UDim2.new(1, -10, 1.00769, -30);
G2L["64"]["Position"] = UDim2.new(0.49502, 0, 1.00379, -5);
G2L["64"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
G2L["64"]["Name"] = [[Container]];
G2L["64"]["BackgroundTransparency"] = 0.5;


-- StarterGui.AdminUI.soRealConsole.Container.Logs
G2L["65"] = Instance.new("ScrollingFrame", G2L["64"]);
G2L["65"]["BorderSizePixel"] = 0;
G2L["65"]["TopImage"] = [[rbxgameasset://Images/scrollTop]];
G2L["65"]["MidImage"] = [[rbxgameasset://Images/scrollMid]];
G2L["65"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["65"]["Name"] = [[Logs]];
G2L["65"]["BottomImage"] = [[rbxgameasset://Images/scrollBottom (1)]];
G2L["65"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["65"]["Size"] = UDim2.new(1, -10, 0.9, -35);
G2L["65"]["Position"] = UDim2.new(0.5, 0, 0.62, 0);
G2L["65"]["BorderColor3"] = Color3.fromRGB(17, 17, 17);
G2L["65"]["ScrollBarThickness"] = 4;
G2L["65"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.UIListLayout
G2L["66"] = Instance.new("UIListLayout", G2L["65"]);
G2L["66"]["Padding"] = UDim.new(0, 3);
G2L["66"]["SortOrder"] = Enum.SortOrder.LayoutOrder;


-- StarterGui.AdminUI.soRealConsole.Container.Logs.TextLabel
G2L["67"] = Instance.new("TextLabel", G2L["65"]);
G2L["67"]["TextWrapped"] = true;
G2L["67"]["TextSize"] = 14;
G2L["67"]["TextScaled"] = true;
G2L["67"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["67"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["67"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["67"]["BackgroundTransparency"] = 1;
G2L["67"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["67"]["Text"] = [[[Output]: failed print 1]];


-- StarterGui.AdminUI.soRealConsole.Container.UICorner
G2L["68"] = Instance.new("UICorner", G2L["64"]);
G2L["68"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.soRealConsole.Container.UIGradient
G2L["69"] = Instance.new("UIGradient", G2L["64"]);
G2L["69"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(13, 5, 21)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(13, 5, 21))};


-- StarterGui.AdminUI.soRealConsole.Container.Filter
G2L["6a"] = Instance.new("TextBox", G2L["64"]);
G2L["6a"]["Name"] = [[Filter]];
G2L["6a"]["PlaceholderColor3"] = Color3.fromRGB(125, 125, 125);
G2L["6a"]["BorderSizePixel"] = 0;
G2L["6a"]["TextSize"] = 18;
G2L["6a"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["6a"]["BackgroundColor3"] = Color3.fromRGB(5, 5, 5);
G2L["6a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["6a"]["AnchorPoint"] = Vector2.new(0.5, 0);
G2L["6a"]["PlaceholderText"] = [[Search...]];
G2L["6a"]["Size"] = UDim2.new(1, -10, 0, 20);
G2L["6a"]["Position"] = UDim2.new(0.5, 0, 0, 5);
G2L["6a"]["Text"] = [[]];
G2L["6a"]["BackgroundTransparency"] = 0.7;


-- StarterGui.AdminUI.soRealConsole.Container.Filter.UICorner
G2L["6b"] = Instance.new("UICorner", G2L["6a"]);
G2L["6b"]["CornerRadius"] = UDim.new(0, 9);


-- StarterGui.AdminUI.soRealConsole.Topbar
G2L["6c"] = Instance.new("Frame", G2L["63"]);
G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["6c"]["Size"] = UDim2.new(1, 0, 0, 25);
G2L["6c"]["Name"] = [[Topbar]];
G2L["6c"]["BackgroundTransparency"] = 1;


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit
G2L["6d"] = Instance.new("TextButton", G2L["6c"]);
G2L["6d"]["TextWrapped"] = true;
G2L["6d"]["BorderSizePixel"] = 0;
G2L["6d"]["TextSize"] = 13;
G2L["6d"]["TextScaled"] = true;
G2L["6d"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["6d"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["6d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["6d"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["6d"]["BackgroundTransparency"] = 0.5;
G2L["6d"]["Size"] = UDim2.new(0, 32, 1, -8);
G2L["6d"]["Text"] = [[X]];
G2L["6d"]["Name"] = [[Exit]];
G2L["6d"]["Position"] = UDim2.new(1, -4, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UICorners
G2L["6e"] = Instance.new("UICorner", G2L["6d"]);
G2L["6e"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Exit.UIStroker
G2L["6f"] = Instance.new("UIStroke", G2L["6d"]);
G2L["6f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["6f"]["Name"] = [[UIStroker]];
G2L["6f"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize
G2L["70"] = Instance.new("TextButton", G2L["6c"]);
G2L["70"]["TextWrapped"] = true;
G2L["70"]["BorderSizePixel"] = 0;
G2L["70"]["TextSize"] = 18;
G2L["70"]["TextScaled"] = true;
G2L["70"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["70"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["70"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["70"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["70"]["BackgroundTransparency"] = 0.5;
G2L["70"]["Size"] = UDim2.new(0, 28, 1, -8);
G2L["70"]["Text"] = [[-]];
G2L["70"]["Name"] = [[Minimize]];
G2L["70"]["Position"] = UDim2.new(1, -40, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UICorners
G2L["71"] = Instance.new("UICorner", G2L["70"]);
G2L["71"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Minimize.UIStroker
G2L["72"] = Instance.new("UIStroke", G2L["70"]);
G2L["72"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["72"]["Name"] = [[UIStroker]];
G2L["72"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear
G2L["73"] = Instance.new("TextButton", G2L["6c"]);
G2L["73"]["TextWrapped"] = true;
G2L["73"]["BorderSizePixel"] = 0;
G2L["73"]["TextSize"] = 13;
G2L["73"]["TextScaled"] = true;
G2L["73"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["73"]["BackgroundColor3"] = Color3.fromRGB(13, 5, 21);
G2L["73"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["73"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["73"]["BackgroundTransparency"] = 0.5;
G2L["73"]["Size"] = UDim2.new(0, 48, 1, -8);
G2L["73"]["Text"] = [[Clear]];
G2L["73"]["Name"] = [[Clear]];
G2L["73"]["Position"] = UDim2.new(0, 4, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UICorners
G2L["74"] = Instance.new("UICorner", G2L["73"]);
G2L["74"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.Topbar.Clear.UIStroker
G2L["75"] = Instance.new("UIStroke", G2L["73"]);
G2L["75"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["75"]["Name"] = [[UIStroker]];
G2L["75"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.soRealConsole.Topbar.Title
G2L["76"] = Instance.new("TextLabel", G2L["6c"]);
G2L["76"]["TextWrapped"] = true;
G2L["76"]["BorderSizePixel"] = 0;
G2L["76"]["TextSize"] = 17;
G2L["76"]["TextScaled"] = true;
G2L["76"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["76"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["76"]["TextColor3"] = Color3.fromRGB(242, 242, 242);
G2L["76"]["BackgroundTransparency"] = 1;
G2L["76"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["76"]["Size"] = UDim2.new(0.5, 0, 1, -8);
G2L["76"]["Text"] = [[NA Console]];
G2L["76"]["Name"] = [[Title]];
G2L["76"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);


-- StarterGui.AdminUI.soRealConsole.UICorners
G2L["77"] = Instance.new("UICorner", G2L["63"]);
G2L["77"]["Name"] = [[UICorners]];


-- StarterGui.AdminUI.soRealConsole.UIStroker
G2L["78"] = Instance.new("UIStroke", G2L["63"]);
G2L["78"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
G2L["78"]["Name"] = [[UIStroker]];
G2L["78"]["Color"] = Color3.fromRGB(146, 91, 255);


-- StarterGui.AdminUI.soRealConsole.UIGradients
G2L["79"] = Instance.new("UIGradient", G2L["63"]);
G2L["79"]["Name"] = [[UIGradients]];
G2L["79"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(41, 41, 47)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 19, 23))};


-- StarterGui.AdminUI.Modal
G2L["7a"] = Instance.new("ImageButton", G2L["1"]);
G2L["7a"]["BackgroundTransparency"] = 1;
G2L["7a"]["Name"] = [[Modal]];



return G2L["1"];