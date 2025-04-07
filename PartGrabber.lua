if getgenv().prtGrabLoaded then return print('Part Grabber is already running') end
getgenv().prtGrabLoaded = true

function protectUI(sGui)
	local function blankfunction(...)
		return ...
	end

	local cloneref = cloneref or blankfunction

	local function SafeGetService(service)
		return cloneref(game:GetService(service)) or game:GetService(service)
	end

	local cGUI = SafeGetService("CoreGui")
	local rPlr = SafeGetService("Players"):FindFirstChildWhichIsA("Player")
	local cGUIProtect = {}
	local rService = SafeGetService("RunService")
	local lPlr = SafeGetService("Players").LocalPlayer

	local function NAProtection(inst, var)
		if inst then
			if var then
				inst[var] = "\0"
				inst.Archivable = false
			else
				inst.Name = "\0"
				inst.Archivable = false
			end
		end
	end

	if (get_hidden_gui or gethui) then
		local hiddenUI = (get_hidden_gui or gethui)
		NAProtection(sGui)
		sGui.Parent = hiddenUI()
		return sGui
	elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
		NAProtection(sGui)
		syn.protect_gui(sGui)
		sGui.Parent = cGUI
		return sGui
	elseif cGUI:FindFirstChildWhichIsA("ScreenGui") then
		pcall(function()
			for _, v in pairs(sGui:GetDescendants()) do
				cGUIProtect[v] = rPlr.Name
			end
			sGui.DescendantAdded:Connect(function(v)
				cGUIProtect[v] = rPlr.Name
			end)
			cGUIProtect[sGui] = rPlr.Name

			local meta = getrawmetatable(game)
			local tostr = meta.__tostring
			setreadonly(meta, false)
			meta.__tostring = newcclosure(function(t)
				if cGUIProtect[t] and not checkcaller() then
					return cGUIProtect[t]
				end
				return tostr(t)
			end)
		end)
		if not rService:IsStudio() then
			local newGui = cGUI:FindFirstChildWhichIsA("ScreenGui")
			newGui.DescendantAdded:Connect(function(v)
				cGUIProtect[v] = rPlr.Name
			end)
			for _, v in pairs(sGui:GetChildren()) do
				v.Parent = newGui
			end
			sGui = newGui
		end
		return sGui
	elseif cGUI then
		NAProtection(sGui)
		sGui.Parent = cGUI
		return sGui
	elseif lPlr and lPlr:FindFirstChild("PlayerGui") then
		NAProtection(sGui)
		sGui.Parent = lPlr:FindFirstChild("PlayerGui")
		return sGui
	else
		return nil
	end
end

local TweenService = game:GetService("TweenService")

local function createButton(text, color, parent, pos, size)
	local button = Instance.new("TextButton")
	button.Name = text:gsub(" ", "")
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.TextColor3 = Color3.fromRGB(235, 235, 255)
	button.BackgroundColor3 = color
	button.Size = size
	button.Position = pos
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
	end)

	return button
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedPartGrabber"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protectUI(screenGui)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 230)
Main.Position = UDim2.new(0.5, -220, 0.5, -140)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Main.BorderSizePixel = 0
Main.Parent = screenGui
Main.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = Main

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(80, 80, 255)
uiStroke.Transparency = 0.3
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = Main

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Size = UDim2.new(1, 0, 0, 30)
topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
topbar.BorderSizePixel = 0
topbar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "🧲 Part Grabber v2.0"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.TextSize = 15
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = topbar

local Minimize = createButton("-", Color3.fromRGB(40, 40, 80), topbar, UDim2.new(1, -60, 0, 0), UDim2.new(0, 30, 1, 0))
local Exit = createButton("X", Color3.fromRGB(180, 40, 40), topbar, UDim2.new(1, -30, 0, 0), UDim2.new(0, 30, 1, 0))

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -40)
Container.Position = UDim2.new(0, 10, 0, 35)
Container.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Container.BorderSizePixel = 0
Container.Parent = Main

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = Container

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = Container

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Text = "Click on a part to select it"
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
StatusLabel.TextSize = 14
StatusLabel.Size = UDim2.new(1, 0, 0, 24)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatusLabel.BackgroundTransparency = 0.3
StatusLabel.BorderSizePixel = 0
StatusLabel.Parent = Container

local Found = Instance.new("TextLabel")
Found.Name = "Found"
Found.Text = ". . ."
Found.TextScaled = true
Found.TextColor3 = Color3.fromRGB(220, 220, 255)
Found.Size = UDim2.new(1, 0, 0, 30)
Found.Position = UDim2.new(0, 0, 0, 34)
Found.Font = Enum.Font.Code
Found.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Found.BorderColor3 = Color3.fromRGB(60, 60, 255)
Found.BorderSizePixel = 1
Found.Parent = Container

local grab = createButton("Copy Path", Color3.fromRGB(50, 120, 255), Container, UDim2.new(0, 0, 0, 75), UDim2.new(0.3, 0, 0, 35))
local copy = createButton("Drag Part", Color3.fromRGB(50, 120, 255), Container, UDim2.new(0.35, 0, 0, 75), UDim2.new(0.3, 0, 0, 35))
local del = createButton("Delete Part", Color3.fromRGB(200, 60, 60), Container, UDim2.new(0.7, 0, 0, 75), UDim2.new(0.3, 0, 0, 35))

local rename = createButton("Rename Part", Color3.fromRGB(60, 60, 100), Container, UDim2.new(0, 0, 0, 120), UDim2.new(0.48, 0, 0, 35))
local bring = createButton("Bring Part", Color3.fromRGB(60, 60, 100), Container, UDim2.new(0.52, 0, 0, 120), UDim2.new(0.48, 0, 0, 35))

Main.Position = UDim2.new(0.5, -220, 0.5, -300)
Main:TweenPosition(UDim2.new(0.5, -220, 0.5, -140), "Out", "Quint", 0.5, true)

selectedPart = nil
selectionBox = nil
mouseConnection = nil
dragging = false
dragConnection = nil

function GetInstancePath(obj)
	local path = {}
	local function isService(obj)
		return obj.Parent == game and obj ~= game
	end
	if isService(obj) then
		table.insert(path, string.format('game:GetService("%s")', obj.ClassName))
	else
		while obj and obj.Parent do
			local name = obj.Name
			if name:match("^[%a_][%w_]*$") then
				table.insert(path, 1, "." .. name)
			else
				table.insert(path, 1, string.format(':FindFirstChild("%s")', name:gsub('"', '\\"')))
			end
			if isService(obj.Parent) then
				table.insert(path, 1, string.format('game:GetService("%s")', obj.Parent.ClassName))
				break
			end
			obj = obj.Parent
		end
	end
	return table.concat(path):gsub("^%.", "")
end

local function highlightPart(part)
	if selectionBox then selectionBox:Destroy() end
	selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Name = "PartGrabberSelection"
	selectionBox.LineThickness = 0.03
	selectionBox.Color3 = Color3.fromRGB(60, 120, 255)
	selectionBox.SurfaceTransparency = 0.8
	selectionBox.SurfaceColor3 = Color3.fromRGB(60, 120, 255)
	selectionBox.Parent = part
end

local function selectPart()
	local player = game:GetService("Players").LocalPlayer
	local mouse = player:GetMouse()
	if mouse.Target then
		selectedPart = mouse.Target
		Found.Text = " "..GetInstancePath(selectedPart)
		StatusLabel.Text = "Part selected: "..selectedPart.Name
		StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		highlightPart(selectedPart)
	else
		StatusLabel.Text = "No part selected"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end

local function setupMouseConnection()
	local player = game:GetService("Players").LocalPlayer
	local mouse = player:GetMouse()
	mouse.TargetFilter = nil
	if mouseConnection then mouseConnection:Disconnect() end
	mouseConnection = mouse.Button1Down:Connect(selectPart)
end

local function enableDragging()
	local player = game:GetService("Players").LocalPlayer
	local mouse = player:GetMouse()
	local camera = workspace.CurrentCamera
	if dragConnection then dragConnection:Disconnect() end
	dragConnection = mouse.Button1Down:Connect(function()
		if selectedPart and mouse.Target == selectedPart then
			dragging = true
			local initialPartCFrame = selectedPart.CFrame
			local dragPlanePoint = initialPartCFrame.p
			local dragPlaneNormal = camera.CFrame.lookVector
			local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
			local denom = mouseRay.Direction:Dot(dragPlaneNormal)
			if math.abs(denom) > 1e-6 then
				local t = (dragPlanePoint - mouseRay.Origin):Dot(dragPlaneNormal) / denom
				local intersection = mouseRay.Origin + mouseRay.Direction * t
				local offset = initialPartCFrame:inverse() * CFrame.new(intersection)
				local moveConnection
				moveConnection = mouse.Move:Connect(function()
					local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
					local denom = mouseRay.Direction:Dot(dragPlaneNormal)
					if math.abs(denom) > 1e-6 then
						local t = (dragPlanePoint - mouseRay.Origin):Dot(dragPlaneNormal) / denom
						local intersection = mouseRay.Origin + mouseRay.Direction * t
						selectedPart.CFrame = CFrame.new(intersection) * offset
					end
				end)
				local releaseConnection
				releaseConnection = mouse.Button1Up:Connect(function()
					dragging = false
					moveConnection:Disconnect()
					releaseConnection:Disconnect()
				end)
			end
		end
	end)
	StatusLabel.Text = "Drag mode enabled! Click & hold to drag."
	StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
end

local function disableDragging()
	if dragConnection then dragConnection:Disconnect() dragConnection = nil end
	dragging = false
	StatusLabel.Text = "Drag mode disabled."
	StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
end

local draggingEnabled = false

copy.Text = "Drag Part"
copy.MouseButton1Click:Connect(function()
	draggingEnabled = not draggingEnabled
	if draggingEnabled then
		enableDragging()
		copy.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
	else
		disableDragging()
		copy.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
	end
end)

setupMouseConnection()

grab.MouseButton1Click:Connect(function()
	if Found.Text ~= ". . ." then
		setclipboard(Found.Text)
		StatusLabel.Text = "Path copied to clipboard!"
		StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

		grab.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
		wait(0.3)
		grab.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
	else
		StatusLabel.Text = "No part selected to copy"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

del.MouseButton1Click:Connect(function()
	if selectedPart then
		local success, err = pcall(function()
			selectedPart:Destroy()
		end)

		if success then
			StatusLabel.Text = "Part deleted successfully"
			StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			Found.Text = ". . ."
			selectedPart = nil
			if selectionBox then selectionBox:Destroy() selectionBox = nil end

			del.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
			wait(0.3)
			del.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
		else
			StatusLabel.Text = "Error deleting part: "..tostring(err):sub(1, 30)
			StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	else
		StatusLabel.Text = "No part selected to delete"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

rename.MouseButton1Click:Connect(function()
	if selectedPart then
		local textBox = Instance.new("TextBox")
		textBox.Parent = Container
		textBox.Size = Found.Size
		textBox.Position = Found.Position
		textBox.Text = selectedPart.Name
		textBox.ClearTextOnFocus = false
		textBox.Font = Enum.Font.GothamBold
		textBox.TextColor3 = Color3.fromRGB(220, 220, 255)
		textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		textBox.BorderSizePixel = 0
		textBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				selectedPart.Name = textBox.Text
				StatusLabel.Text = "Part renamed to "..textBox.Text
				StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
				textBox:Destroy()
			end
		end)
		textBox:CaptureFocus()
	else
		StatusLabel.Text = "No part selected to rename"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

bring.MouseButton1Click:Connect(function()
	if selectedPart then
		local player = game:GetService("Players").LocalPlayer
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			selectedPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
			StatusLabel.Text = "Part brought in front of you"
			StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		else
			StatusLabel.Text = "HumanoidRootPart not found"
			StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	else
		StatusLabel.Text = "No part selected to bring"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

Exit.MouseButton1Click:Connect(function()
	screenGui:Destroy()
	if mouseConnection then mouseConnection:Disconnect() end
	if selectionBox then selectionBox:Destroy() end
	selectedPart = nil
	getgenv().prtGrabLoaded = false

	for _, v in pairs(game:GetDescendants()) do
		if v.Name == "PartGrabberSelection" and v:IsA("SelectionBox") then
			v:Destroy()
		end
	end
end)

local minimized = false
Minimize.MouseButton1Click:Connect(function()
	minimized = not minimized

	if minimized then
		Main:TweenSize(UDim2.new(0, 420, 0, 30), "Out", "Quint", 0.5, true)
		Minimize.Text = "+"
	else
		Main:TweenSize(UDim2.new(0, 420, 0, 230), "Out", "Quint", 0.5, true)
		Minimize.Text = "-"
	end
end)

Main.Active = true
Main.Draggable = true

Main:TweenPosition(UDim2.new(0.5,-283/2+5,0.5,-260/2+5), "Out", "Quint", 1, true)

setupMouseConnection()

for _, button in pairs({grab, del, copy, Exit, Minimize}) do
	button.MouseEnter:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
	end)

	button.MouseLeave:Connect(function()
		game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
	end)
end