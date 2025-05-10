local e = Instance.new("ScreenGui")
local m = Instance.new("Frame")
local c1 = Instance.new("UICorner")
local d = Instance.new("Frame")
local c2 = Instance.new("UICorner")
local s = Instance.new("ScrollingFrame")
local ln = Instance.new("TextLabel")
local t = Instance.new("TextBox")
local bf = Instance.new("Frame")
local gl = Instance.new("UIGridLayout")
local ex = Instance.new("TextButton")
local c5 = Instance.new("UICorner")
local cl = Instance.new("TextButton")
local c3 = Instance.new("UICorner")
local cp = Instance.new("TextButton")
local c4 = Instance.new("UICorner")
local tb = Instance.new("Frame")
local c6 = Instance.new("UICorner")
local tt = Instance.new("TextLabel")
local xt = Instance.new("TextButton")
local mn = Instance.new("TextButton")
local sb = Instance.new("TextLabel")

function protectUI(sGui)
    local function blankfunction(...)
        return ...
    end

    local cloneref = cloneref or blankfunction

    local function SafeGetService(service)
        return cloneref(game:GetService(service)) or game:GetService(service)
    end

    if sGui:IsA("ScreenGui") then
        sGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		sGui.DisplayOrder = 999999999
		sGui.ResetOnSpawn = false
		sGui.IgnoreGuiInset = true
    end
    local cGUI = SafeGetService("CoreGui")
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

    if cGUI and cGUI:FindFirstChild("RobloxGui") then
		NAProtection(sGui)
		sGui.Parent = cGUI:FindFirstChild("RobloxGui")
		return sGui
	elseif cGUI then
		NAProtection(sGui)
		sGui.Parent = cGUI
		return sGui
	elseif lPlr and lPlr:FindFirstChild("PlayerGui") then
		NAProtection(sGui)
		sGui.Parent = lPlr:FindFirstChild("PlayerGui")
		sGui.ResetOnSpawn = false
		return sGui
	else
		return nil
	end
end

e.Name = "AdvExec"
protectUI(e)
e.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
e.ResetOnSpawn = false

m.Name = "Main"
m.Parent = e
m.Active = true
m.BackgroundColor3 = Color3.fromRGB(24, 25, 35)
m.BackgroundTransparency = 0
m.ClipsDescendants = true
m.Position = UDim2.new(0.308, 0, 0.262, 0)
m.Size = UDim2.new(0, 520, 0, 360)

c1.CornerRadius = UDim.new(0, 10)
c1.Parent = m

d.Name = "Down"
d.Parent = m
d.BackgroundColor3 = Color3.fromRGB(34, 36, 50)
d.BackgroundTransparency = 0
d.Position = UDim2.new(0, 0, 0, 354)
d.Size = UDim2.new(1, 0, 0, 6)

c2.Parent = d

s.Name = "Scroll"
s.Parent = m
s.Active = true
s.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
s.BackgroundTransparency = 0.2
s.BorderSizePixel = 0
s.Position = UDim2.new(0, 10, 0, 50)
s.Size = UDim2.new(0, 500, 0, 230)
s.ScrollBarThickness = 5
s.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
s.ClipsDescendants = true

ln.Name = "LineNum"
ln.Parent = s
ln.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
ln.BackgroundTransparency = 0.5
ln.BorderSizePixel = 0
ln.Position = UDim2.new(0, 0, 0, 0)
ln.Size = UDim2.new(0, 30, 1, 0)
ln.Font = Enum.Font.Gotham
ln.Text = "1"
ln.TextColor3 = Color3.fromRGB(140, 140, 160)
ln.TextSize = 14
ln.TextYAlignment = Enum.TextYAlignment.Top

t.Name = "Text"
t.Parent = s
t.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
t.BackgroundTransparency = 0.7
t.Position = UDim2.new(0, 35, 0, 0)
t.Size = UDim2.new(0, 440, 0, 230)
t.ClearTextOnFocus = false
t.Font = Enum.Font.Gotham
t.MultiLine = true
t.PlaceholderText = "-- Script here"
t.PlaceholderColor3 = Color3.fromRGB(170, 170, 190)
t.Text = ""
t.TextColor3 = Color3.fromRGB(255, 255, 255)
t.TextSize = 16
t.TextWrapped = true
t.TextXAlignment = Enum.TextXAlignment.Left
t.TextYAlignment = Enum.TextYAlignment.Top
t.ZIndex = 2
t.TextTransparency = 0

bf.Name = "Buttons"
bf.Parent = m
bf.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
bf.BackgroundTransparency = 0
bf.Position = UDim2.new(0, 10, 0, 290)
bf.Size = UDim2.new(0, 500, 0, 45)

gl.Parent = bf
gl.SortOrder = Enum.SortOrder.LayoutOrder
gl.CellPadding = UDim2.new(0, 10, 0, 10)
gl.CellSize = UDim2.new(0, 150, 0, 40)

local function applyButtonStyle(btn, bgColor)
    btn.BackgroundColor3 = bgColor
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamSemibold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
end

applyButtonStyle(ex, Color3.fromRGB(59, 130, 246))
ex.Name = "Exec"
ex.Text = "Execute"
ex.Parent = bf

applyButtonStyle(cl, Color3.fromRGB(120, 120, 140))
cl.Name = "Clear"
cl.Text = "Clear"
cl.Parent = bf

applyButtonStyle(cp, Color3.fromRGB(120, 120, 140))
cp.Name = "Copy"
cp.Text = "Copy"
cp.Parent = bf

tb.Name = "TopBar"
tb.Parent = m
tb.BackgroundColor3 = Color3.fromRGB(30, 32, 45)
tb.BorderSizePixel = 0
tb.Position = UDim2.new(0, 0, 0, 0)
tb.Size = UDim2.new(1, 0, 0, 40)

c6.CornerRadius = UDim.new(0, 10)
c6.Parent = tb

tt.Name = "Title"
tt.Parent = tb
tt.BackgroundTransparency = 1
tt.Position = UDim2.new(0, 15, 0, 0)
tt.Size = UDim2.new(0, 200, 1, 0)
tt.Font = Enum.Font.GothamBold
tt.Text = "Executor"
tt.TextColor3 = Color3.fromRGB(255, 255, 255)
tt.TextSize = 20
tt.TextXAlignment = Enum.TextXAlignment.Left

xt.Name = "Exit"
xt.Parent = tb
xt.BackgroundTransparency = 1
xt.Position = UDim2.new(1, -40, 0, 0)
xt.Size = UDim2.new(0, 40, 1, 0)
xt.Font = Enum.Font.GothamBold
xt.Text = "X"
xt.TextColor3 = Color3.fromRGB(255, 100, 100)
xt.TextSize = 18

mn.Name = "Min"
mn.Parent = tb
mn.BackgroundTransparency = 1
mn.Position = UDim2.new(1, -80, 0, 0)
mn.Size = UDim2.new(0, 40, 1, 0)
mn.Font = Enum.Font.GothamBold
mn.Text = "-"
mn.TextColor3 = Color3.fromRGB(120, 120, 255)
mn.TextSize = 20

sb.Name = "Status"
sb.Parent = m
sb.BackgroundTransparency = 1
sb.Position = UDim2.new(0, 10, 0, 335)
sb.Size = UDim2.new(1, -20, 0, 20)
sb.Font = Enum.Font.Gotham
sb.Text = "Ready"
sb.TextColor3 = Color3.fromRGB(120, 255, 120)
sb.TextSize = 14
sb.TextXAlignment = Enum.TextXAlignment.Left

local function updateEditorSize()
    local padding = 20
    local fixedTextWidth = 440
    local leftMargin = 35
    local text = t.Text
    if text == "" then text = " " end

    local textSize = game:GetService("TextService"):GetTextSize(
        text, t.TextSize, t.Font, Vector2.new(fixedTextWidth, math.huge)
    )
    
    local newHeight = math.max(230, textSize.Y + padding)
    
    t.Size = UDim2.new(0, fixedTextWidth, 0, newHeight)
    
    s.CanvasSize = UDim2.new(0, fixedTextWidth + leftMargin, 0, newHeight)
    
    local visualLines = math.ceil(textSize.Y / t.TextSize)
    local lineText = ""
    for i = 1, visualLines do
        lineText = lineText .. i .. "\n"
    end
    ln.Text = lineText

    ln.Size = UDim2.new(0, 30, 0, newHeight)
end

local function u()
    local txt = t.Text
    local lines = 1
    for i = 1, #txt do
        if txt:sub(i, i) == "\n" then
            lines = lines + 1
        end
    end
    
    local lineText = ""
    for i = 1, lines do
        lineText = lineText..i.."\n"
    end
    ln.Text = lineText
    
    local h = math.max(230, lines * 16 + 10)
    t.Size = UDim2.new(0.93, -35, 0, h)
    s.CanvasSize = UDim2.new(0, 0, 0, h)
end

local function h(err)
    sb.Text = err or "Error executing script"
    sb.TextColor3 = Color3.fromRGB(255, 100, 100)
    wait(3)
    sb.Text = "Ready"
    sb.TextColor3 = Color3.fromRGB(100, 255, 100)
end

local function r()
    t:GetPropertyChangedSignal("Text"):Connect(u)
    
    ex.MouseButton1Click:Connect(function()
        sb.Text = "Executing..."
        sb.TextColor3 = Color3.fromRGB(255, 255, 100)
        local s, e = pcall(function()
            loadstring(t.Text)()
        end)
        if not s then
            h(e)
        else
            sb.Text = "Executed successfully"
            wait(2)
            sb.Text = "Ready"
            sb.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end)
    
    cl.MouseButton1Click:Connect(function()
        t.Text = ""
    end)
    
    cp.MouseButton1Click:Connect(function()
        setclipboard(t.Text)
        sb.Text = "Copied to clipboard"
        wait(2)
        sb.Text = "Ready"
    end)
    
    xt.MouseButton1Click:Connect(function()
        e:Destroy()
    end)
    
    mn.MouseButton1Click:Connect(function()
        if m.Size.Y.Offset > 40 then
            m:TweenSize(UDim2.new(0, 520, 0, 40), "Out", "Quad", 0.5, true)
        else
            m:TweenSize(UDim2.new(0, 520, 0, 350), "Out", "Quad", 0.5, true)
        end
    end)
    
    m.Active = true
    m.Draggable = true
    e.ResetOnSpawn = false
    
    m:TweenPosition(UDim2.new(0.308, 0, 0.262, 0), "Out", "Quad", 1, true)
end

t:GetPropertyChangedSignal("Text"):Connect(updateEditorSize)
updateEditorSize()

r()
u()