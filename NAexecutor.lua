local e = Instance.new("ScreenGui")
local m = Instance.new("Frame")
local c1 = Instance.new("UICorner")
local d = Instance.new("Frame")
local c2 = Instance.new("UICorner")
local s = Instance.new("ScrollingFrame")
local t = Instance.new("TextBox")
local ln = Instance.new("TextLabel")
local l1 = Instance.new("UIListLayout")
local bf = Instance.new("Frame")
local gl = Instance.new("UIGridLayout")
local ex = Instance.new("TextButton")
local c5 = Instance.new("UICorner")
local cl = Instance.new("TextButton")
local c3 = Instance.new("UICorner")
local cp = Instance.new("TextButton")
local c4 = Instance.new("UICorner")
local sv = Instance.new("TextButton")
local c7 = Instance.new("UICorner")
local ld = Instance.new("TextButton")
local c8 = Instance.new("UICorner")
local sh = Instance.new("TextButton")
local c9 = Instance.new("UICorner")
local tb = Instance.new("Frame")
local c6 = Instance.new("UICorner")
local tt = Instance.new("TextLabel")
local xt = Instance.new("TextButton")
local mn = Instance.new("TextButton")
local st = Instance.new("TextButton")
local sb = Instance.new("TextLabel")
local sf = Instance.new("Frame")
local c10 = Instance.new("UICorner")
local sl = Instance.new("ScrollingFrame")
local l2 = Instance.new("UIListLayout")
local st = Instance.new("TextLabel")
local sc = Instance.new("TextButton")
local sd = Instance.new("Frame")
local c11 = Instance.new("UICorner")
local svt = Instance.new("TextLabel")
local sn = Instance.new("TextBox")
local sb = Instance.new("TextButton")
local sc = Instance.new("TextButton")
local ld = Instance.new("Frame")
local c12 = Instance.new("UICorner")
local lt = Instance.new("TextLabel")
local ss = Instance.new("ScrollingFrame")
local l3 = Instance.new("UIListLayout")
local lc = Instance.new("TextButton")

e.Name = "AdvExec"
e.Parent = gethui() or (game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:FindFirstChildWhichIsA("PlayerGui"))
e.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
e.ResetOnSpawn = false

m.Name = "Main"
m.Parent = e
m.Active = true
m.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
m.BackgroundTransparency = 0.1
m.ClipsDescendants = true
m.Position = UDim2.new(0.308, 0, 0.262, 0)
m.Size = UDim2.new(0, 500, 0, 350)

c1.CornerRadius = UDim.new(0, 8)
c1.Parent = m

d.Name = "Down"
d.Parent = m
d.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
d.BackgroundTransparency = 0.3
d.Position = UDim2.new(0, 0, 0, 344)
d.Size = UDim2.new(1, 0, 0, 6)

c2.Parent = d

s.Name = "Scroll"
s.Parent = m
s.Active = true
s.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
s.BackgroundTransparency = 0.4
s.BorderSizePixel = 0
s.Position = UDim2.new(0, 10, 0, 50)
s.Size = UDim2.new(0, 480, 0, 230)
s.ScrollBarThickness = 5

ln.Name = "LineNum"
ln.Parent = s
ln.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ln.BackgroundTransparency = 0.7
ln.BorderSizePixel = 0
ln.Size = UDim2.new(0, 30, 1, 0)
ln.Font = Enum.Font.Code
ln.Text = "1"
ln.TextColor3 = Color3.fromRGB(150, 150, 150)
ln.TextSize = 16
ln.TextYAlignment = Enum.TextYAlignment.Top

t.Name = "Text"
t.Parent = s
t.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
t.BackgroundTransparency = 1
t.Position = UDim2.new(0, 35, 0, 0)
t.Size = UDim2.new(0.93, -35, 0, 230)
t.ClearTextOnFocus = false
t.Font = Enum.Font.Code
t.MultiLine = true
t.PlaceholderText = "-- Script here"
t.Text = ""
t.TextColor3 = Color3.fromRGB(255, 255, 255)
t.TextSize = 16
t.TextWrapped = true
t.TextXAlignment = Enum.TextXAlignment.Left
t.TextYAlignment = Enum.TextYAlignment.Top

l1.Parent = s
l1.FillDirection = Enum.FillDirection.Horizontal
l1.SortOrder = Enum.SortOrder.LayoutOrder

bf.Name = "Buttons"
bf.Parent = m
bf.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bf.BackgroundTransparency = 1
bf.Position = UDim2.new(0, 10, 0, 290)
bf.Size = UDim2.new(0, 480, 0, 45)

gl.Parent = bf
gl.SortOrder = Enum.SortOrder.LayoutOrder
gl.CellPadding = UDim2.new(0, 10, 0, 10)
gl.CellSize = UDim2.new(0, 150, 0, 35)

ex.Name = "Exec"
ex.Parent = bf
ex.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
ex.BorderSizePixel = 0
ex.Font = Enum.Font.GothamSemibold
ex.Text = "Execute"
ex.TextColor3 = Color3.fromRGB(255, 255, 255)
ex.TextSize = 16

c5.CornerRadius = UDim.new(0, 6)
c5.Parent = ex

cl.Name = "Clear"
cl.Parent = bf
cl.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
cl.BorderSizePixel = 0
cl.Font = Enum.Font.GothamSemibold
cl.Text = "Clear"
cl.TextColor3 = Color3.fromRGB(255, 255, 255)
cl.TextSize = 16

c3.CornerRadius = UDim.new(0, 6)
c3.Parent = cl

cp.Name = "Copy"
cp.Parent = bf
cp.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
cp.BorderSizePixel = 0
cp.Font = Enum.Font.GothamSemibold
cp.Text = "Copy"
cp.TextColor3 = Color3.fromRGB(255, 255, 255)
cp.TextSize = 16

c4.CornerRadius = UDim.new(0, 6)
c4.Parent = cp

tb.Name = "TopBar"
tb.Parent = m
tb.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
tb.BorderSizePixel = 0
tb.Position = UDim2.new(0, 0, 0, 0)
tb.Size = UDim2.new(1, 0, 0, 40)

c6.CornerRadius = UDim.new(0, 8)
c6.Parent = tb

tt.Name = "Title"
tt.Parent = tb
tt.BackgroundTransparency = 1
tt.Position = UDim2.new(0, 15, 0, 0)
tt.Size = UDim2.new(0, 200, 1, 0)
tt.Font = Enum.Font.GothamBold
tt.Text = "Executor"
tt.TextColor3 = Color3.fromRGB(255, 255, 255)
tt.TextSize = 18
tt.TextXAlignment = Enum.TextXAlignment.Left

xt.Name = "Exit"
xt.Parent = tb
xt.BackgroundTransparency = 1
xt.Position = UDim2.new(1, -40, 0, 0)
xt.Size = UDim2.new(0, 40, 1, 0)
xt.Font = Enum.Font.GothamBold
xt.Text = "X"
xt.TextColor3 = Color3.fromRGB(255, 255, 255)
xt.TextSize = 18

mn.Name = "Min"
mn.Parent = tb
mn.BackgroundTransparency = 1
mn.Position = UDim2.new(1, -80, 0, 0)
mn.Size = UDim2.new(0, 40, 1, 0)
mn.Font = Enum.Font.GothamBold
mn.Text = "-"
mn.TextColor3 = Color3.fromRGB(255, 255, 255)
mn.TextSize = 24

sb.Name = "Status"
sb.Parent = m
sb.BackgroundTransparency = 1
sb.Position = UDim2.new(0, 10, 0, 335)
sb.Size = UDim2.new(1, -20, 0, 20)
sb.Font = Enum.Font.Gotham
sb.Text = "Ready"
sb.TextColor3 = Color3.fromRGB(100, 255, 100)
sb.TextSize = 14
sb.TextXAlignment = Enum.TextXAlignment.Left

local savedScripts = {}
local scriptHub = {
    {name = "Infinite Yield", script = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()"},
    {name = "Dex Explorer", script = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()"},
    {name = "Simple Spy", script = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()"}
}

local function u()
    local txt = t.Text
    local lines = 1
    for i = 1, #txt do
        if string.sub(txt, i, i) == "\n" then
            lines = lines + 1
        end
    end
    
    local lineText = ""
    for i = 1, lines do
        lineText = lineText .. i .. "\n"
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
            m:TweenSize(UDim2.new(0, 500, 0, 40), "Out", "Quad", 0.5, true)
        else
            m:TweenSize(UDim2.new(0, 500, 0, 350), "Out", "Quad", 0.5, true)
        end
    end)
    
    m.Active = true
    m.Draggable = true
    e.ResetOnSpawn = false
    
    m:TweenPosition(UDim2.new(0.308, 0, 0.262, 0), "Out", "Quad", 1, true)
end

r()
u()