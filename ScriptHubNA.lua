local function SafeGetService(name)
    local Service = (game.GetService);
	local Reference = (cloneref) or function(reference) return reference end
	return Reference(Service(game, name));
end

local r = request or http_request or (syn and syn.request) or function() end
local ts = SafeGetService("TweenService")
local uis = SafeGetService("UserInputService")
local http = SafeGetService("HttpService")
local engine = "ScriptBlox" -- current ones (RScripts, ScriptBlox)

local c = {
    bg = Color3.fromRGB(30, 30, 35),
    ac = Color3.fromRGB(0, 0, 0),
    sc = Color3.fromRGB(45, 45, 50),
    tx = Color3.fromRGB(255, 255, 255),
    td = Color3.fromRGB(180, 180, 180),
    su = Color3.fromRGB(40, 180, 99),
    wa = Color3.fromRGB(255, 153, 51),
    er = Color3.fromRGB(220, 53, 69)
}

local function protectUI(sGui)
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

    if gethui then
		NAProtection(sGui)
		sGui.Parent = gethui()
		return sGui
	elseif cGUI and cGUI:FindFirstChild("RobloxGui") then
		NAProtection(sGui)
		sGui.Parent = cGUI:FindFirstChild("RobloxGui")
		return sGui
	elseif cGUI then
		NAProtection(sGui)
		sGui.Parent = cGUI
		return sGui
	elseif lPlr and lPlr:FindFirstChildWhichIsA("PlayerGui") then
		NAProtection(sGui)
		sGui.Parent = lPlr:FindFirstChildWhichIsA("PlayerGui")
		sGui.ResetOnSpawn = false
		return sGui
	else
		return nil
	end
end

local sg = Instance.new("ScreenGui")
sg.Name = "SBHub"
protectUI(sg)
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local m = Instance.new("Frame")
m.Name = "M"
m.Size = UDim2.new(0, 500, 0, 400)
m.Position = UDim2.new(0.5, -250, 0.5, -200)
m.BackgroundColor3 = c.bg
m.BorderSizePixel = 0
m.Active = true
m.ClipsDescendants = true
m.Parent = sg

local mc = Instance.new("UICorner")
mc.CornerRadius = UDim.new(0, 10)
mc.Parent = m

local sh = Instance.new("ImageLabel")
sh.Name = "Sh"
sh.AnchorPoint = Vector2.new(0.5, 0.5)
sh.BackgroundTransparency = 1
sh.Position = UDim2.new(0.5, 0, 0.5, 0)
sh.Size = UDim2.new(1, 40, 1, 40)
sh.ZIndex = -1
sh.Image = "rbxassetid://5554236805"
sh.ImageColor3 = Color3.fromRGB(0, 0, 0)
sh.ImageTransparency = 0.4
sh.ScaleType = Enum.ScaleType.Slice
sh.SliceCenter = Rect.new(23, 23, 277, 277)
sh.Parent = m

local tb = Instance.new("Frame")
tb.Name = "TB"
tb.Size = UDim2.new(1, 0, 0, 40)
tb.BackgroundColor3 = c.ac
tb.BorderSizePixel = 0
tb.Parent = m

local tbc = Instance.new("UICorner")
tbc.CornerRadius = UDim.new(0, 10)
tbc.Parent = tb

local bf = Instance.new("Frame")
bf.Name = "BF"
bf.Size = UDim2.new(1, 0, 0, 10)
bf.Position = UDim2.new(0, 0, 1, -10)
bf.BackgroundColor3 = c.ac
bf.BorderSizePixel = 0
bf.ZIndex = tb.ZIndex
bf.Parent = tb

local t = Instance.new("TextLabel")
t.Name = "T"
t.Size = UDim2.new(1, -120, 1, 0)
t.Position = UDim2.new(0, 15, 0, 0)
t.BackgroundTransparency = 1
t.Font = Enum.Font.GothamBold
t.Text = "Script Hub - By @ltseverydayyou"
t.TextColor3 = c.tx
t.TextSize = 18
t.TextXAlignment = Enum.TextXAlignment.Left
t.Parent = tb

local dd = Instance.new("TextButton")
dd.Name = "DD"
dd.Size = UDim2.new(0, 120, 0, 27)
dd.Position = UDim2.new(1, -185, 0, 8)
dd.BackgroundColor3 = c.sc
dd.BorderSizePixel = 0
dd.Font = Enum.Font.GothamSemibold
dd.Text = "Engine: ScriptBlox"
dd.TextColor3 = c.tx
dd.TextScaled = true
dd.Parent = tb

local ddc = Instance.new("UICorner")
ddc.CornerRadius = UDim.new(0, 6)
ddc.Parent = dd

local cb = Instance.new("ImageButton")
cb.Name = "CB"
cb.Size = UDim2.new(0, 24, 0, 24)
cb.Position = UDim2.new(1, -32, 0, 8)
cb.BackgroundTransparency = 1
cb.Image = "rbxassetid://6031094678"
cb.ImageColor3 = c.tx
cb.Parent = tb

local mb = Instance.new("ImageButton")
mb.Name = "MB"
mb.Size = UDim2.new(0, 24, 0, 24)
mb.Position = UDim2.new(1, -64, 0, 8)
mb.BackgroundTransparency = 1
mb.Image = "rbxassetid://6031090990"
mb.ImageColor3 = c.tx
mb.Parent = tb

local sc = Instance.new("Frame")
sc.Name = "SC"
sc.Size = UDim2.new(1, -40, 0, 50)
sc.Position = UDim2.new(0, 20, 0, 50)
sc.BackgroundColor3 = c.sc
sc.BorderSizePixel = 0
sc.Parent = m

local scc = Instance.new("UICorner")
scc.CornerRadius = UDim.new(0, 8)
scc.Parent = sc

local si = Instance.new("ImageLabel")
si.Name = "SI"
si.Size = UDim2.new(0, 20, 0, 20)
si.Position = UDim2.new(0, 10, 0.5, -10)
si.BackgroundTransparency = 1
si.Image = "rbxassetid://3192519002"
si.ImageColor3 = c.td
si.Parent = sc

local stb = Instance.new("TextBox")
stb.Name = "STB"
stb.Size = UDim2.new(1, -80, 1, -10)
stb.Position = UDim2.new(0, 40, 0, 5)
stb.BackgroundTransparency = 1
stb.Font = Enum.Font.Gotham
stb.PlaceholderText = "Search for scripts..."
stb.Text = ""
stb.TextColor3 = c.tx
stb.TextSize = 14
stb.TextXAlignment = Enum.TextXAlignment.Left
stb.Parent = sc

local sb = Instance.new("TextButton")
sb.Name = "SB"
sb.Size = UDim2.new(0, 80, 0, 30)
sb.Position = UDim2.new(1, -90, 0.5, -15)
sb.BackgroundColor3 = c.ac
sb.BorderSizePixel = 0
sb.Font = Enum.Font.GothamSemibold
sb.Text = "Search"
sb.TextColor3 = c.tx
sb.TextSize = 14
sb.Parent = sc

local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0, 6)
sbc.Parent = sb

local rc = Instance.new("Frame")
rc.Name = "RC"
rc.Size = UDim2.new(1, -40, 1, -110)
rc.Position = UDim2.new(0, 20, 0, 110)
rc.BackgroundColor3 = c.sc
rc.BorderSizePixel = 0
rc.Parent = m

local rcc = Instance.new("UICorner")
rcc.CornerRadius = UDim.new(0, 8)
rcc.Parent = rc

local sf = Instance.new("ScrollingFrame")
sf.Name = "SF"
sf.Size = UDim2.new(1, -20, 1, -20)
sf.Position = UDim2.new(0, 10, 0, 10)
sf.BackgroundTransparency = 1
sf.BorderSizePixel = 0
sf.ScrollBarThickness = 6
sf.ScrollBarImageColor3 = c.ac
sf.CanvasSize = UDim2.new(0, 0, 0, 0)
sf.Parent = rc

local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    m.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

tb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = m.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

tb.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

uis.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

local minimized = false
mb.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ts:Create(m, TweenInfo.new(0.3), {Size = UDim2.new(0, 500, 0, 40)}):Play()
    else
        ts:Create(m, TweenInfo.new(0.3), {Size = UDim2.new(0, 500, 0, 400)}):Play()
    end
end)

cb.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

dd.MouseButton1Click:Connect(function()
    if engine == "ScriptBlox" then
        engine = "RScripts"
        dd.Text = "Engine: RScripts"
        stb.PlaceholderText = "Search for scripts (powered by rscripts.net)"
    else
        engine = "ScriptBlox"
        dd.Text = "Engine: ScriptBlox"
        stb.PlaceholderText = "Search for scripts (powered by scriptblox.com)"
    end
end)

local function search(q,doEmpty)
    local url = engine == "ScriptBlox" and "https://scriptblox.com/api/script/search?q="..q or "https://rscripts.net/api/v2/scripts?page=1&orderBy=date&sort=desc&q="..q

    if doEmpty and engine == "ScriptBlox" then
        url='https://www.scriptblox.com/api/script/fetch'
    end
    
    local success, response = pcall(function()
        return r({
            Url = url,
            Method = "GET"
        })
    end)
    
    sf:ClearAllChildren()
    sf.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    if not success then
        local el = Instance.new("TextLabel")
        el.Size = UDim2.new(1, 0, 0, 30)
        el.BackgroundColor3 = c.er
        el.BackgroundTransparency = 0.8
        el.BorderSizePixel = 0
        el.Font = Enum.Font.Gotham
        el.Text = "Error making request: "..tostring(response)
        el.TextColor3 = c.tx
        el.TextSize = 14
        el.Parent = sf
        
        local elc = Instance.new("UICorner")
        elc.CornerRadius = UDim.new(0, 6)
        elc.Parent = el
        return
    end
    
    if not response or not response.Body then
        local el = Instance.new("TextLabel")
        el.Size = UDim2.new(1, 0, 0, 30)
        el.BackgroundColor3 = c.er
        el.BackgroundTransparency = 0.8
        el.BorderSizePixel = 0
        el.Font = Enum.Font.Gotham
        el.Text = "No response received from "..engine
        el.TextColor3 = c.tx
        el.TextSize = 14
        el.Parent = sf
        
        local elc = Instance.new("UICorner")
        elc.CornerRadius = UDim.new(0, 6)
        elc.Parent = el
        return
    end
    
    local success, decoded = pcall(function()
        return http:JSONDecode(response.Body)
    end)
    
    if not success or not decoded then
        local el = Instance.new("TextLabel")
        el.Size = UDim2.new(1, 0, 0, 30)
        el.BackgroundColor3 = c.er
        el.BackgroundTransparency = 0.8
        el.BorderSizePixel = 0
        el.Font = Enum.Font.Gotham
        el.Text = "Failed to decode JSON response"
        el.TextColor3 = c.tx
        el.TextSize = 14
        el.Parent = sf
        
        local elc = Instance.new("UICorner")
        elc.CornerRadius = UDim.new(0, 6)
        elc.Parent = el
        return
    end
    
    local scripts = engine == "ScriptBlox" and decoded.result.scripts or decoded.scripts
    if not scripts or #scripts == 0 then
        local el = Instance.new("TextLabel")
        el.Size = UDim2.new(1, 0, 0, 30)
        el.BackgroundColor3 = c.wa
        el.BackgroundTransparency = 0.8
        el.BorderSizePixel = 0
        el.Font = Enum.Font.Gotham
        el.Text = "No scripts found for your query"
        el.TextColor3 = c.tx
        el.TextSize = 14
        el.Parent = sf
        
        local elc = Instance.new("UICorner")
        elc.CornerRadius = UDim.new(0, 6)
        elc.Parent = el
        return
    end
    
    local totalHeight = 0
    for i, script in ipairs(scripts) do
        local title = engine == "ScriptBlox" and script.title or script.title
        local raw = engine == "ScriptBlox" and script.script or script.rawScript
        local views = engine == "ScriptBlox" and script.views or script.views
        local key = engine == "ScriptBlox" and script.key or script.keySystem

        local card = Instance.new("Frame")
        card.Name = "Card"..i
        card.Size = UDim2.new(1, 0, 0, 120)
        card.Position = UDim2.new(0, 0, 0, totalHeight)
        card.BackgroundColor3 = c.bg
        card.BorderSizePixel = 0
        card.Parent = sf
        
        local cardc = Instance.new("UICorner")
        cardc.CornerRadius = UDim.new(0, 6)
        cardc.Parent = card
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 30)
        titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = c.tx
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextWrapped = true
        titleLabel.Parent = card
        
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -20, 0, 40)
        info.Position = UDim2.new(0, 10, 0, 35)
        info.BackgroundTransparency = 1
        info.Font = Enum.Font.Gotham
        if engine == "ScriptBlox" then
            info.Text = "Universal: "..(script.isUniversal and "Yes" or "No").." | Key: "..(script.key and "Yes" or "No").."\nPatched: "..(script.isPatched and "Yes" or "No").." | Views: "..script.views
        else
            local discord = script.discord or "N/A"
            info.Text = "Key: "..(key and "Yes" or "No").." | Views: "..views.."\nDiscord: "..discord.." | Mobile Compatible: "..(script.mobileReady and "Yes" or "No")
        end
        --info.Text = "Key: "..(key and "Yes" or "No").." | Views: "..views
        info.TextColor3 = c.td
        info.TextSize = 12
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Parent = card
        
        local eb = Instance.new("TextButton")
        eb.Name = "EB"
        eb.Size = UDim2.new(0, 100, 0, 30)
        eb.Position = UDim2.new(0, 10, 0, 80)
        eb.BackgroundColor3 = c.su
        eb.BorderSizePixel = 0
        eb.Font = Enum.Font.GothamSemibold
        eb.Text = "Execute"
        eb.TextColor3 = c.tx
        eb.TextSize = 14
        eb.Parent = card
        
        local ebc = Instance.new("UICorner")
        ebc.CornerRadius = UDim.new(0, 6)
        ebc.Parent = eb
        
    if setclipboard then
        local cpb = Instance.new("TextButton")
        cpb.Name = "CPB"
        cpb.Size = UDim2.new(0, 100, 0, 30)
        cpb.Position = UDim2.new(0, 120, 0, 80)
        cpb.BackgroundColor3 = c.ac
        cpb.BorderSizePixel = 0
        cpb.Font = Enum.Font.GothamSemibold
        cpb.Text = "Copy"
        cpb.TextColor3 = c.tx
        cpb.TextSize = 14
        cpb.Parent = card
        
        local cpbc = Instance.new("UICorner")
        cpbc.CornerRadius = UDim.new(0, 6)
        cpbc.Parent = cpb

        cpb.MouseButton1Click:Connect(function()
            pcall(function()
                task.spawn(function()
                    if engine == "ScriptBlox" then
                        setclipboard(raw)
                    else
                        setclipboard(game:HttpGet(raw))();
                    end
                end)
                cpb.Text = "Copied!"
                wait(1)
                cpb.Text = "Copy"
            end)
        end)
    end
        
        eb.MouseButton1Click:Connect(function()
            pcall(function()
                if engine == "ScriptBlox" then
                    loadstring(raw)()
                else
                    loadstring(game:HttpGet(raw))();
                end
            end)
        end)

        if script.discord and setclipboard then
            local discordButton = Instance.new("TextButton")
            discordButton.Name = "DiscordButton"
            discordButton.Size = UDim2.new(0, 100, 0, 30)
            discordButton.Position = UDim2.new(0, 240, 0, 80)
            discordButton.BackgroundColor3 = Color3.fromRGB(11, 114, 224)
            discordButton.BorderSizePixel = 0
            discordButton.Font = Enum.Font.GothamSemibold
            discordButton.Text = "Copy Discord"
            discordButton.TextColor3 = c.tx
            discordButton.TextSize = 14
            discordButton.Parent = card
        
            local discordButtonCorner = Instance.new("UICorner")
            discordButtonCorner.CornerRadius = UDim.new(0, 6)
            discordButtonCorner.Parent = discordButton
        
            discordButton.MouseButton1Click:Connect(function()
                pcall(function()
                    setclipboard(script.discord)
                    discordButton.Text = "Copied!"
                    wait(1)
                    discordButton.Text = "Copy Discord"
                end)
            end)
        end
        
        totalHeight = totalHeight + 130
    end
    
    sf.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

sb.MouseButton1Click:Connect(function()
    local q = stb.Text:gsub(" ", "%%20")
    if q ~= "" then
        search(q)
    else
        if engine == "ScriptBlox" then
            search(q, true)
        else
            sf:ClearAllChildren()
            local el = Instance.new("TextLabel")
            el.Size = UDim2.new(1, 0, 0, 30)
            el.BackgroundColor3 = c.wa
            el.BackgroundTransparency = 0.8
            el.BorderSizePixel = 0
            el.Font = Enum.Font.Gotham
            el.Text = "Please enter a search query"
            el.TextColor3 = c.tx
            el.TextSize = 14
            el.Parent = sf

            local elc = Instance.new("UICorner")
            elc.CornerRadius = UDim.new(0, 6)
            elc.Parent = el
        end
    end
end)
