NAmanage.Notepad_Init = function()
	if not (NAUIMANAGER and NAUIMANAGER.NotepadFrame and NAUIMANAGER.NotepadContainer) then
		return false
	end

	const frame = NAUIMANAGER.NotepadFrame
	const cont = NAUIMANAGER.NotepadContainer
	const noteSizeXAttr = "NANotepadSavedSizeX"
	const noteSizeYAttr = "NANotepadSavedSizeY"
	const function saveNotepadFrameSize()
		if not (frame and frame.Parent and frame.SetAttribute) then
			return
		end
		if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
			return
		end
		const w = tonumber(frame.Size.X.Offset) or 0
		const h = tonumber(frame.Size.Y.Offset) or 0
		if w > 0 and h > 0 then
			NAmanage.SetAttr(frame, noteSizeXAttr, math.floor(w + 0.5))
			NAmanage.SetAttr(frame, noteSizeYAttr, math.floor(h + 0.5))
		end
	end
	const function getNotepadSavedSize()
		if frame and frame.GetAttribute then
			const w = tonumber(NAmanage.GetAttr(frame, noteSizeXAttr))
			const h = tonumber(NAmanage.GetAttr(frame, noteSizeYAttr))
			if w and h and w > 0 and h > 0 then
				return w, h
			end
		end
		return nil
	end
	NAmanage.Notepad_SaveFrameSize = saveNotepadFrameSize
	const function getNotepadScale()
		local s = (NAUIMANAGER and NAUIMANAGER.AUTOSCALER and tonumber(NAUIMANAGER.AUTOSCALER.Scale)) or 1
		if not s or s <= 0 then
			s = 1
		end
		return s
	end

	const function getNotepadViewport()
		const sg = NAStuff and NAStuff.NASCREENGUI
		if sg and sg.AbsoluteSize and sg.AbsoluteSize.X > 0 and sg.AbsoluteSize.Y > 0 then
			return sg.AbsoluteSize
		end
		const cam = Services.Workspace and Services.Workspace.CurrentCamera
		if cam and cam.ViewportSize and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
			return cam.ViewportSize
		end
		return Vector2.new(1280, 720)
	end

	const function getNotepadPad()
		const s = getNotepadScale()
		local x = IsOnMobile and 8 or 16
		local y = IsOnMobile and 8 or 18
		if Services.GuiService and Services.GuiService.GetGuiInset then
			local ok, a, b = pcall(function()
				return Services.GuiService:GetGuiInset()
			end)
			if ok and typeof(a) == "Vector2" and typeof(b) == "Vector2" then
				x += math.max(a.X, b.X) / s
				y += math.max(a.Y, b.Y) / s
			end
		end
		return x, y
	end

	const function getNotepadSize(wide, tall)
		local padX, padY = getNotepadPad()
		const maxW = math.max(1, math.floor(wide - padX * 2 + 0.5))
		const maxH = math.max(1, math.floor(tall - padY * 2 + 0.5))
		const small = IsOnMobile or wide < 900 or tall < 620
		const baseW, baseH = 720, 455
		local capW = small and math.floor(maxW * 0.90 + 0.5) or math.min(baseW, maxW)
		local capH = small and math.floor(maxH * 0.90 + 0.5) or math.min(baseH, maxH)
		capW = math.max(1, capW)
		capH = math.max(1, capH)
		local scale = math.min(capW / baseW, capH / baseH, 1)
		if not scale or scale <= 0 then
			scale = 1
		end
		local w = math.floor(baseW * scale + 0.5)
		local h = math.floor(baseH * scale + 0.5)
		const minW = math.min(small and 280 or 460, capW)
		const minH = math.min(small and 230 or 340, capH)
		w = math.clamp(w, minW, capW)
		h = math.clamp(h, minH, capH)
		return w, h, capW, capH, small
	end

	const function applyNotepadResponsive(center)
		if not frame or not frame.Parent then
			return
		end
		if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
			return
		end
		const vp = getNotepadViewport()
		const s = getNotepadScale()
		const wide = math.max(1, vp.X / s)
		const tall = math.max(1, vp.Y / s)
		local defW, defH, capW, capH, small = getNotepadSize(wide, tall)
		const minW = math.min(small and 280 or 460, capW)
		const minH = math.min(small and 230 or 340, capH)
		const curW = tonumber(frame.Size.X.Offset) or 0
		const curH = tonumber(frame.Size.Y.Offset) or 0
		local savedW, savedH = getNotepadSavedSize()
		const initialized = frame.GetAttribute and NAmanage.GetAttr(frame, "NANotepadDefaultSized") == true
		local targetW = defW
		local targetH = defH
		if savedW and savedH then
			targetW = math.clamp(math.floor(savedW + 0.5), minW, capW)
			targetH = math.clamp(math.floor(savedH + 0.5), minH, capH)
		elseif initialized and curW > 0 and curH > 0 then
			targetW = math.clamp(math.floor(curW + 0.5), minW, capW)
			targetH = math.clamp(math.floor(curH + 0.5), minH, capH)
			if small and (targetW >= capW * 0.96 or targetW / math.max(targetH, 1) > 1.95 or targetH < defH * 0.82) then
				targetW = defW
				targetH = defH
			end
		end
		frame.AnchorPoint = Vector2.new(0, 0)
		if frame.AbsoluteSize.X ~= targetW or frame.AbsoluteSize.Y ~= targetH then
			frame.Size = UDim2.fromOffset(targetW, targetH)
		end
		if frame.SetAttribute then
			NAmanage.SetAttr(frame, "NANotepadDefaultSized", true)
		end
		saveNotepadFrameSize()
		if center == true and NAmanage.centerFrame then
			NAmanage.centerFrame(frame)
		end
	end

	NAmanage.Notepad_ApplyResponsive = applyNotepadResponsive
	if frame.GetAttribute and NAmanage.GetAttr(frame, "NANotepadReady") then
		if type(NAStuff.NotepadRefresh) == "function" then
			Defer(NAStuff.NotepadRefresh)
		end
		return true
	end
	if frame.SetAttribute then
		NAmanage.SetAttr(frame, "NANotepadReady", true)
	end

	for _, child in cont:GetChildren() do
		child:Destroy()
	end

	const dir = (NAfiles and NAfiles.NANOTEPADPATH) or "Nameless-Admin/NA-Notepad"
	const idx = dir.."/index.json"
	const fsOk = type(isfolder) == "function" and type(makefolder) == "function" and type(isfile) == "function" and type(readfile) == "function" and type(writefile) == "function"
	const delOk = type(delfile) == "function"
	const listOk = type(listfiles) == "function"
	local sel
	NAStuff.NotepadSettings = type(NAStuff.NotepadSettings) == "table" and NAStuff.NotepadSettings or {}
	NAStuff.NotepadSettings.fontSize = math.clamp(math.floor((tonumber(NAStuff.NotepadSettings.fontSize) or 15) + 0.5), 11, 24)
	NAStuff.NotepadSettings.wrap = NAStuff.NotepadSettings.wrap == true

	const col = {
		bg = Color3.fromRGB(17, 17, 21),
		bg2 = Color3.fromRGB(24, 24, 30),
		bg3 = Color3.fromRGB(31, 31, 38),
		st = Color3.fromRGB(72, 72, 82),
		tx = Color3.fromRGB(235, 235, 242),
		sub = Color3.fromRGB(170, 170, 180),
		on = Color3.fromRGB(45, 45, 58),
		ok = Color3.fromRGB(156, 235, 174),
		warn = Color3.fromRGB(255, 214, 112),
		err = Color3.fromRGB(255, 146, 146),
	}

	const function trim(s)
		return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
	end

	const exts = {
		".txt",
		".lua",
		".json",
		".md",
		".log",
		".cfg",
		".csv",
		".xml",
		".ini",
		".html",
		".css",
		".js",
	}
	local selectedExt = ".txt"

	const function normExt(e)
		e = trim(tostring(e or "")):lower()
		e = e:gsub("^%.", "")
		if e == "" or not e:match("^[%w]+$") or #e > 16 then
			return ".txt"
		end
		return "."..e
	end

	const function cleanName(n)
		n = trim(n)
		n = n:gsub("\\", "/")
		n = n:match("([^/]+)$") or n
		n = n:gsub('[%c%z<>:"/\\|%?%*]', "_")
		n = n:gsub("^%.*", "")
		n = n:gsub("%s+", " ")
		n = trim(n)
		if n == "" then
			n = "note"
		end
		return n
	end

	const function getExt(n)
		return normExt((tostring(n or ""):match("(%.[%w]+)$")))
	end

	const function safeName(n, forcePicker)
		n = cleanName(n)
		local base, ext = n:match("^(.*)(%.[%w]+)$")
		if forcePicker then
			const pick = normExt(selectedExt)
			n = (base and base ~= "" and base or n)..pick
		elseif ext then
			n = base..normExt(ext)
		else
			n ..= normExt(selectedExt)
		end
		base, ext = n:match("^(.*)(%.[%w]+)$")
		if #n > 96 and base and ext then
			n = base:sub(1, math.max(1, 96 - #ext))..ext
		elseif #n > 96 then
			n = n:sub(1, 96)
		end
		return n
	end

	const function filePath(n, forcePicker)
		return dir.."/"..safeName(n, forcePicker)
	end

	const function setStatus(txt, c)
		if NAStuff.NotepadStatusLabel then
			NAStuff.NotepadStatusLabel.Text = tostring(txt or "Ready")
			NAStuff.NotepadStatusLabel.TextColor3 = c or col.sub
		end
	end

	const function ensure()
		if not fsOk then
			return false
		end
		local ok = true
		const function mk(p)
			if not ok then return end
			local has = false
			local okCheck, res = pcall(isfolder, p)
			if okCheck and res == true then
				has = true
			end
			if not has then
				const okMake = pcall(makefolder, p)
				if not okMake then
					ok = false
				end
			end
		end
		mk("Nameless-Admin")
		mk(dir)
		return ok
	end

	const function readIdx()
		const names = {}
		if not (fsOk and isfile(idx)) then
			return names
		end
		local ok, raw = pcall(readfile, idx)
		if not ok or type(raw) ~= "string" or raw == "" then
			return names
		end
		local okDec, data = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if okDec and type(data) == "table" then
			for _, v in data do
				if type(v) == "string" and v ~= "" then
					names[#names + 1] = safeName(v)
				end
			end
		end
		return names
	end

	const function saveIdx(names)
		if not ensure() then
			return false
		end
		const seen = {}
		const out = {}
		for _, n in names or {} do
			const clean = safeName(n)
			const key = clean:lower()
			if not seen[key] then
				seen[key] = true
				out[#out + 1] = clean
			end
		end
		table.sort(out, function(a, b)
			return a:lower() < b:lower()
		end)
		local okEnc, raw = pcall(Services.HttpService.JSONEncode, Services.HttpService, out)
		if okEnc and raw then
			return pcall(writefile, idx, raw)
		end
		return false
	end

	const function names()
		const seen = {}
		const out = {}
		const function push(n)
			if type(n) ~= "string" then return end
			n = n:gsub("\\", "/")
			n = n:match("([^/]+)$") or n
			if n == "" or n:lower() == "index.json" then return end
			const clean = safeName(n)
			const key = clean:lower()
			if not seen[key] then
				seen[key] = true
				out[#out + 1] = clean
			end
		end
		if fsOk and listOk then
			ensure()
			local ok, files = pcall(listfiles, dir)
			if ok and type(files) == "table" then
				for _, f in files do
					push(f)
				end
			end
		end
		for _, n in readIdx() do
			push(n)
		end
		table.sort(out, function(a, b)
			return a:lower() < b:lower()
		end)
		saveIdx(out)
		return out
	end

	const function addIdx(n)
		const cur = readIdx()
		cur[#cur + 1] = safeName(n)
		saveIdx(cur)
	end

	const function remIdx(n)
		const rem = safeName(n):lower()
		const cur = readIdx()
		const out = {}
		for _, v in cur do
			if safeName(v):lower() ~= rem then
				out[#out + 1] = v
			end
		end
		saveIdx(out)
	end

	const function skin(obj, r, t)
		const c = InstanceNew("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = obj
		const s = InstanceNew("UIStroke")
		s.Color = col.st
		s.Transparency = 0.18
		s.Thickness = t or 1
		s.Parent = obj
		return obj
	end

	const function btn(par, txt, w, order)
		const b = InstanceNew("TextButton")
		b.AutoButtonColor = false
		b.BackgroundColor3 = col.bg3
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamSemibold
		b.Text = txt
		b.TextColor3 = col.tx
		b.TextSize = 13
		b.Size = UDim2.new(0, w or 64, 1, 0)
		if order ~= nil then
			b.LayoutOrder = order
		end
		b.Parent = par
		skin(b, 8, 1)
		b.MouseEnter:Connect(function()
			if Services.TweenService then
				Services.TweenService:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = col.bg3:Lerp(Color3.new(1, 1, 1), 0.06)}):Play()
			else
				b.BackgroundColor3 = col.bg3:Lerp(Color3.new(1, 1, 1), 0.06)
			end
		end)
		b.MouseLeave:Connect(function()
			const c = (sel and b.Name == sel) and col.on or col.bg3
			if Services.TweenService then
				Services.TweenService:Create(b, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = c}):Play()
			else
				b.BackgroundColor3 = c
			end
		end)
		return b
	end

	const root = InstanceNew("Frame")
	root.BackgroundTransparency = 1
	root.Size = UDim2.new(1, -14, 1, -14)
	root.Position = UDim2.new(0, 7, 0, 7)
	root.Parent = cont

	const side = InstanceNew("Frame")
	side.BackgroundColor3 = col.bg
	side.BorderSizePixel = 0
	side.Size = UDim2.new(0, 182, 1, 0)
	side.Parent = root
	skin(side, 10, 1)

	const sideTitle = InstanceNew("TextLabel")
	sideTitle.BackgroundTransparency = 1
	sideTitle.Font = Enum.Font.GothamSemibold
	sideTitle.Text = "Saved Files"
	sideTitle.TextColor3 = col.tx
	sideTitle.TextSize = 14
	sideTitle.TextXAlignment = Enum.TextXAlignment.Left
	sideTitle.Size = UDim2.new(1, -20, 0, 30)
	sideTitle.Position = UDim2.new(0, 10, 0, 4)
	sideTitle.Parent = side

	const list = InstanceNew("ScrollingFrame")
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarImageColor3 = Color3.fromRGB(125, 125, 135)
	list.ScrollBarThickness = 4
	list.Position = UDim2.new(0, 8, 0, 38)
	list.Size = UDim2.new(1, -16, 1, -46)
	list.CanvasSize = UDim2.new()
	list.Parent = side

	const listLay = InstanceNew("UIListLayout")
	listLay.SortOrder = Enum.SortOrder.LayoutOrder
	listLay.Padding = UDim.new(0, 6)
	listLay.Parent = list

	const main = InstanceNew("Frame")
	main.BackgroundColor3 = col.bg
	main.BorderSizePixel = 0
	main.Position = UDim2.new(0, 192, 0, 0)
	main.Size = UDim2.new(1, -192, 1, 0)
	main.Parent = root
	skin(main, 10, 1)

	const tool = InstanceNew("Frame")
	tool.BackgroundTransparency = 1
	tool.Position = UDim2.new(0, 10, 0, 10)
	tool.Size = UDim2.new(1, -20, 0, 30)
	tool.Parent = main

	const toolLay = InstanceNew("UIListLayout")
	toolLay.FillDirection = Enum.FillDirection.Horizontal
	toolLay.HorizontalAlignment = Enum.HorizontalAlignment.Left
	toolLay.VerticalAlignment = Enum.VerticalAlignment.Center
	toolLay.SortOrder = Enum.SortOrder.LayoutOrder
	toolLay.Padding = UDim.new(0, 6)
	toolLay.Parent = tool

	const nameBox = InstanceNew("TextBox")
	nameBox.BackgroundColor3 = col.bg2
	nameBox.BorderSizePixel = 0
	nameBox.ClearTextOnFocus = false
	nameBox.Font = Enum.Font.Gotham
	nameBox.PlaceholderText = "note"
	nameBox.Text = "note.txt"
	nameBox.TextColor3 = col.tx
	nameBox.PlaceholderColor3 = col.sub
	nameBox.TextSize = 13
	nameBox.TextXAlignment = Enum.TextXAlignment.Left
	nameBox.Size = UDim2.new(0, 135, 1, 0)
	nameBox.LayoutOrder = 1
	nameBox.Parent = tool
	skin(nameBox, 8, 1)

	const extBtn = btn(tool, selectedExt, 54, 2)
	extBtn.Name = "ExtensionPicker"

	const newBtn = btn(tool, "New", 40, 3)
	const openBtn = btn(tool, "Open", 45, 4)
	const saveBtn = btn(tool, "Save", 43, 5)
	const clearBtn = btn(tool, "Clear", 45, 6)
	const delBtn = btn(tool, "Del", 36, 7)
	const refBtn = btn(tool, "Refresh", 55, 8)
	const optBtn = btn(tool, "Options", 62, 9)

	const extDrop = InstanceNew("Frame")
	extDrop.Visible = false
	extDrop.ClipsDescendants = true
	extDrop.BackgroundColor3 = col.bg2
	extDrop.BorderSizePixel = 0
	extDrop.ZIndex = 40
	extDrop.Position = UDim2.fromOffset(0, 0)
	extDrop.Size = UDim2.new(0, 72, 0, math.min(#exts * 25 + 8, 160))
	extDrop.Parent = main
	skin(extDrop, 8, 1)

	const extScroll = InstanceNew("ScrollingFrame")
	extScroll.BackgroundTransparency = 1
	extScroll.BorderSizePixel = 0
	extScroll.ScrollBarThickness = 3
	extScroll.ScrollBarImageColor3 = Color3.fromRGB(125, 125, 135)
	extScroll.ZIndex = 41
	extScroll.Size = UDim2.new(1, -8, 1, -8)
	extScroll.Position = UDim2.new(0, 4, 0, 4)
	extScroll.CanvasSize = UDim2.new()
	extScroll.Parent = extDrop

	const extLay = InstanceNew("UIListLayout")
	extLay.Padding = UDim.new(0, 4)
	extLay.SortOrder = Enum.SortOrder.LayoutOrder
	extLay.Parent = extScroll

	const function setPicker(ext, noRename)
		selectedExt = normExt(ext)
		extBtn.Text = selectedExt
		if not noRename then
			nameBox.Text = safeName(nameBox.Text, true)
		end
	end

	const function setPickerFromName(n)
		const e = tostring(n or ""):match("(%.[%w]+)$")
		if e then
			setPicker(e, true)
		end
	end

	const function posExtDrop()
		const mainPos = main.AbsolutePosition
		const btnPos = extBtn.AbsolutePosition
		const btnSize = extBtn.AbsoluteSize
		const dropSize = extDrop.AbsoluteSize
		const dropW = dropSize.X > 0 and dropSize.X or 72
		const dropH = dropSize.Y > 0 and dropSize.Y or math.min(#exts * 25 + 8, 160)
		local x = btnPos.X - mainPos.X
		local y = btnPos.Y - mainPos.Y + btnSize.Y + 4
		x = math.clamp(x, 4, math.max(4, main.AbsoluteSize.X - dropW - 8))
		if y + dropH + 8 > main.AbsoluteSize.Y then
			y = btnPos.Y - mainPos.Y - dropH - 4
		end
		extDrop.Position = UDim2.fromOffset(x, math.max(4, y))
	end

	const function toggleExt()
		const state = not extDrop.Visible
		if state then
			posExtDrop()
		end
		extDrop.Visible = state
	end

	extBtn:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		if extDrop.Visible then
			posExtDrop()
		end
	end)
	main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if extDrop.Visible then
			posExtDrop()
		end
	end)

	for i, e in exts do
		const item = btn(extScroll, e, 1, i)
		item.Name = "Ext"..e:gsub("%.", "")
		item.Size = UDim2.new(1, -2, 0, 23)
		item.Text = e
		item.TextSize = 12
		item.ZIndex = 42
		for _, d in NAmanage.QueryDescendants(item, "GuiObject") do
			d.ZIndex = 42
		end
		MouseButtonFix(item, function()
			setPicker(e)
			extDrop.Visible = false
		end)
	end

	extLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		extScroll.CanvasSize = UDim2.new(0, 0, 0, extLay.AbsoluteContentSize.Y + 6)
	end)
	extScroll.CanvasSize = UDim2.new(0, 0, 0, extLay.AbsoluteContentSize.Y + 6)
	MouseButtonFix(extBtn, toggleExt)

	const body = InstanceNew("ScrollingFrame")
	body.Active = true
	body.BackgroundColor3 = col.bg2
	body.BorderSizePixel = 0
	body.CanvasSize = UDim2.new(0, 0, 0, 0)
	body.Position = UDim2.new(0, 10, 0, 48)
	body.ScrollBarImageColor3 = col.sub
	body.ScrollBarThickness = 0
	body.ScrollingDirection = Enum.ScrollingDirection.XY
	body.Size = UDim2.new(1, -20, 1, -88)
	body.Parent = main
	skin(body, 10, 1)

	const notepadLineScroll = InstanceNew("ScrollingFrame")
	notepadLineScroll.Name = "LineScrollProxy"
	notepadLineScroll.Active = false
	notepadLineScroll.BackgroundTransparency = 1
	notepadLineScroll.BorderSizePixel = 0
	notepadLineScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	notepadLineScroll.Position = body.Position
	notepadLineScroll.ScrollBarThickness = 0
	notepadLineScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	notepadLineScroll.Size = body.Size
	notepadLineScroll.Visible = false
	notepadLineScroll.Parent = main

	const function makeNotepadScrollBar(parent, name, axis)
		const horizontal = axis == "X"
		const bar = InstanceNew("Frame")
		bar.Name = name
		bar.BackgroundColor3 = col.bg3
		bar.BorderSizePixel = 0
		bar.Visible = false
		bar.ZIndex = 35
		bar.Parent = parent
		skin(bar, 7, 1)

		const upButton = InstanceNew("TextButton")
		upButton.Name = horizontal and "Left" or "Up"
		upButton.AutoButtonColor = false
		upButton.BackgroundColor3 = col.bg2
		upButton.BorderSizePixel = 0
		upButton.Font = Enum.Font.GothamBold
		upButton.Text = horizontal and "<" or "^"
		upButton.TextColor3 = col.tx
		upButton.TextSize = 10
		upButton.ZIndex = 36
		upButton.Parent = bar
		skin(upButton, 5, 1)

		const downButton = InstanceNew("TextButton")
		downButton.Name = horizontal and "Right" or "Down"
		downButton.AutoButtonColor = false
		downButton.BackgroundColor3 = col.bg2
		downButton.BorderSizePixel = 0
		downButton.Font = Enum.Font.GothamBold
		downButton.Text = horizontal and ">" or "v"
		downButton.TextColor3 = col.tx
		downButton.TextSize = 10
		downButton.ZIndex = 36
		downButton.Parent = bar
		skin(downButton, 5, 1)

		const track = InstanceNew("Frame")
		track.Name = "Track"
		track.BackgroundColor3 = col.bg
		track.BorderSizePixel = 0
		track.ZIndex = 36
		track.Parent = bar
		skin(track, 5, 1)

		const thumb = InstanceNew("Frame")
		thumb.Name = "Thumb"
		thumb.BackgroundColor3 = col.sub
		thumb.BorderSizePixel = 0
		thumb.ZIndex = 37
		thumb.Parent = track
		skin(thumb, 5, 1)

		if horizontal then
			upButton.Position = UDim2.new(0, 0, 0, 0)
			upButton.Size = UDim2.new(0, 16, 1, 0)
			downButton.AnchorPoint = Vector2.new(1, 0)
			downButton.Position = UDim2.new(1, 0, 0, 0)
			downButton.Size = UDim2.new(0, 16, 1, 0)
			track.Position = UDim2.new(0, 18, 0, 0)
			track.Size = UDim2.new(1, -36, 1, 0)
		else
			upButton.Position = UDim2.new(0, 0, 0, 0)
			upButton.Size = UDim2.new(1, 0, 0, 16)
			downButton.AnchorPoint = Vector2.new(0, 1)
			downButton.Position = UDim2.new(0, 0, 1, 0)
			downButton.Size = UDim2.new(1, 0, 0, 16)
			track.Position = UDim2.new(0, 0, 0, 18)
			track.Size = UDim2.new(1, 0, 1, -36)
		end

		return {
			bar = bar,
			upButton = upButton,
			downButton = downButton,
			track = track,
			thumb = thumb,
		}
	end

	const notepadVScroll = makeNotepadScrollBar(main, "CustomScrollBar", "Y")
	const notepadHScroll = makeNotepadScrollBar(main, "CustomHorizontalScrollBar", "X")
	local notepadGetVisibleLines
	local notepadGetTotalLines
	local notepadGetViewLine
	local notepadSetViewLine
	const function layoutNotepadScrollBar(_, target, widgets)
		const bar = widgets and widgets.bar
		if not (target and bar and bar.Parent) then
			return
		end
		const parentPos = bar.Parent.AbsolutePosition
		const relX = math.floor(target.AbsolutePosition.X - parentPos.X + 0.5)
		const relY = math.floor(target.AbsolutePosition.Y - parentPos.Y + 0.5)
		const w = math.floor(target.AbsoluteSize.X + 0.5)
		const h = math.floor(target.AbsoluteSize.Y + 0.5)
		if bar == notepadHScroll.bar then
			bar.Position = UDim2.new(0, relX, 0, relY + h - 16)
			bar.Size = UDim2.new(0, math.max(48, w - 18), 0, 16)
		else
			bar.Position = UDim2.new(0, relX + w - 16, 0, relY)
			bar.Size = UDim2.new(0, 16, 0, math.max(48, h - 18))
		end
	end

	const notepadVerticalScroll = NAmanage.CustomScroll and NAmanage.CustomScroll.create and NAmanage.CustomScroll.create("notepad_editor_v", {
		getWidgets = function()
			return notepadVScroll
		end,
		getTarget = function()
			return body
		end,
		getVisibleSpace = function()
			return notepadGetVisibleLines and notepadGetVisibleLines() or 1
		end,
		getTotalSpace = function()
			return notepadGetTotalLines and notepadGetTotalLines() or 1
		end,
		getPosition = function()
			return math.max(0, (notepadGetViewLine and notepadGetViewLine() or 1) - 1)
		end,
		setPosition = function(_, _, pos)
			if notepadSetViewLine then
				notepadSetViewLine(math.floor((tonumber(pos) or 0) + 1.5))
			end
		end,
		layoutForTarget = layoutNotepadScrollBar,
		step = 3,
	})
	const notepadHorizontalScroll = NAmanage.CustomScroll and NAmanage.CustomScroll.create and NAmanage.CustomScroll.create("notepad_editor_h", {
		axis = "X",
		getWidgets = function()
			return notepadHScroll
		end,
		getTarget = function()
			return body
		end,
		layoutForTarget = layoutNotepadScrollBar,
		step = 96,
	})
	if notepadVerticalScroll and notepadVerticalScroll.install then
		notepadVerticalScroll.install()
	end
	if notepadHorizontalScroll and notepadHorizontalScroll.install then
		notepadHorizontalScroll.install()
	end

	const box = InstanceNew("TextBox")
	box.BackgroundTransparency = 1
	box.ClearTextOnFocus = false
	box.Font = Enum.Font.Code
	box.MultiLine = true
	box.RichText = false
	box.PlaceholderText = "type here..."
	box.PlaceholderColor3 = col.sub
	box.Text = ""
	box.TextColor3 = col.tx
	box.TextSize = 15
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top
	box.TextWrapped = false
	box.Size = UDim2.new(0, 320, 0, 200)
	box.Position = UDim2.new(0, 8, 0, 8)
	box.Parent = body


	const fmt = {
		popups = {},
		headingSizes = { 28, 22, 19, 17, 15, 13 },
	}

	fmt.stripRich = function(source)
		source = tostring(source or "")
		source = source:gsub("<!%-%-NA_LINK:.-%-%->", "")
		source = source:gsub("<font%s+[^>]->", "")
		source = source:gsub("</font>", "")
		source = source:gsub("<b>", ""):gsub("</b>", "")
		source = source:gsub("<i>", ""):gsub("</i>", "")
		source = source:gsub("<s>", ""):gsub("</s>", "")
		source = source:gsub("<u>", ""):gsub("</u>", "")
		return source
	end

	fmt.bar = InstanceNew("Frame")
	fmt.bar.Name = "FormattingBar"
	fmt.bar.BackgroundColor3 = col.bg2
	fmt.bar.BackgroundTransparency = 0.1
	fmt.bar.BorderSizePixel = 0
	fmt.bar.ZIndex = 25
	fmt.bar.Parent = main
	skin(fmt.bar, 8, 1)

	fmt.scroll = InstanceNew("ScrollingFrame")
	fmt.scroll.Name = "FormattingTools"
	fmt.scroll.Active = true
	fmt.scroll.BackgroundTransparency = 1
	fmt.scroll.BorderSizePixel = 0
	fmt.scroll.CanvasSize = UDim2.new()
	fmt.scroll.ScrollBarThickness = 0
	fmt.scroll.ScrollingDirection = Enum.ScrollingDirection.X
	fmt.scroll.Position = UDim2.new(0, 4, 0, 2)
	fmt.scroll.Size = UDim2.new(1, -8, 1, -4)
	fmt.scroll.ZIndex = 26
	fmt.scroll.Parent = fmt.bar

	fmt.layout = InstanceNew("UIListLayout")
	fmt.layout.FillDirection = Enum.FillDirection.Horizontal
	fmt.layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	fmt.layout.VerticalAlignment = Enum.VerticalAlignment.Center
	fmt.layout.SortOrder = Enum.SortOrder.LayoutOrder
	fmt.layout.Padding = UDim.new(0, 5)
	fmt.layout.Parent = fmt.scroll

	fmt.tip = InstanceNew("TextLabel")
	fmt.tip.Name = "FormattingTooltip"
	fmt.tip.Visible = false
	fmt.tip.BackgroundColor3 = col.bg3
	fmt.tip.BackgroundTransparency = 0.02
	fmt.tip.BorderSizePixel = 0
	fmt.tip.Font = Enum.Font.Gotham
	fmt.tip.TextColor3 = col.tx
	fmt.tip.TextSize = 11
	fmt.tip.TextWrapped = false
	fmt.tip.TextXAlignment = Enum.TextXAlignment.Center
	fmt.tip.TextYAlignment = Enum.TextYAlignment.Center
	fmt.tip.ZIndex = 95
	fmt.tip.Parent = main
	skin(fmt.tip, 6, 1)

	fmt.hideTip = function()
		fmt.tip.Visible = false
	end

	fmt.showTip = function(button, text)
		if not (button and button.Parent and fmt.tip and fmt.tip.Parent) then
			return
		end
		fmt.tip.Text = tostring(text or "")
		local width = math.clamp(#fmt.tip.Text * 6 + 18, 70, 220)
		fmt.tip.Size = UDim2.fromOffset(width, 24)
		const mainPos = main.AbsolutePosition
		const pos = button.AbsolutePosition
		const size = button.AbsoluteSize
		local x = pos.X - mainPos.X + size.X * 0.5 - width * 0.5
		local y = pos.Y - mainPos.Y - 28
		if y < 4 then
			y = pos.Y - mainPos.Y + size.Y + 4
		end
		x = math.clamp(x, 4, math.max(4, main.AbsoluteSize.X - width - 4))
		fmt.tip.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
		fmt.tip.Visible = true
	end

	fmt.makeTool = function(text, width, order, tooltip)
		const b = btn(fmt.scroll, text, width, order)
		b.Name = "Format"..tostring(order)
		b.Size = UDim2.new(0, width, 1, 0)
		b.TextSize = 12
		b.ZIndex = 27
		b.MouseEnter:Connect(function()
			fmt.showTip(b, tooltip)
		end)
		b.MouseLeave:Connect(fmt.hideTip)
		return b
	end

	fmt.heading = fmt.makeTool("Body v", 62, 1, "Headings")
	fmt.list = fmt.makeTool("List v", 52, 2, "Lists")
	fmt.bold = fmt.makeTool("B", 30, 3, "Bold (Ctrl+B)")
	fmt.bold.Font = Enum.Font.GothamBold
	fmt.italic = fmt.makeTool("I", 30, 4, "Italic (Ctrl+I)")
	fmt.strike = fmt.makeTool("S", 30, 5, "Strikethrough (Ctrl+Shift+X)")
	fmt.link = fmt.makeTool("Link", 42, 6, "Link (Ctrl+K)")
	fmt.clear = fmt.makeTool("Clear", 48, 7, "Clear formatting (Ctrl+Space)")

	fmt.strikeLine = InstanceNew("Frame")
	fmt.strikeLine.AnchorPoint = Vector2.new(0.5, 0.5)
	fmt.strikeLine.BackgroundColor3 = col.tx
	fmt.strikeLine.BorderSizePixel = 0
	fmt.strikeLine.Position = UDim2.new(0.5, 0, 0.5, 0)
	fmt.strikeLine.Size = UDim2.new(0, 12, 0, 1)
	fmt.strikeLine.ZIndex = 28
	fmt.strikeLine.Parent = fmt.strike

	fmt.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		fmt.scroll.CanvasSize = UDim2.new(0, fmt.layout.AbsoluteContentSize.X + 8, 0, 0)
	end)

	fmt.positionPopup = function(popup, anchorButton)
		if not (popup and anchorButton and popup.Parent and anchorButton.Parent) then
			return
		end
		const mainPos = main.AbsolutePosition
		const buttonPos = anchorButton.AbsolutePosition
		const buttonSize = anchorButton.AbsoluteSize
		const popupSize = popup.AbsoluteSize
		local x = buttonPos.X - mainPos.X
		local y = buttonPos.Y - mainPos.Y + buttonSize.Y + 5
		local width = popupSize.X > 0 and popupSize.X or popup.Size.X.Offset
		local height = popupSize.Y > 0 and popupSize.Y or popup.Size.Y.Offset
		x = math.clamp(x, 4, math.max(4, main.AbsoluteSize.X - width - 6))
		if y + height + 6 > main.AbsoluteSize.Y then
			y = buttonPos.Y - mainPos.Y - height - 5
		end
		popup.Position = UDim2.fromOffset(math.floor(x + 0.5), math.max(4, math.floor(y + 0.5)))
	end

	fmt.hidePopups = function(except)
		for _, popup in fmt.popups do
			if popup ~= except then
				popup.Visible = false
			end
		end
		fmt.hideTip()
	end

	fmt.newPopup = function(name, width, height)
		const popup = InstanceNew("Frame")
		popup.Name = name
		popup.Visible = false
		popup.ClipsDescendants = true
		popup.BackgroundColor3 = col.bg2
		popup.BorderSizePixel = 0
		popup.Size = UDim2.fromOffset(width, height)
		popup.ZIndex = 70
		popup.Parent = main
		skin(popup, 8, 1)
		fmt.popups[#fmt.popups + 1] = popup
		return popup
	end

	fmt.headingPopup = fmt.newPopup("HeadingMenu", 166, 218)
	fmt.headingPad = InstanceNew("UIPadding")
	fmt.headingPad.PaddingTop = UDim.new(0, 6)
	fmt.headingPad.PaddingBottom = UDim.new(0, 6)
	fmt.headingPad.PaddingLeft = UDim.new(0, 6)
	fmt.headingPad.PaddingRight = UDim.new(0, 6)
	fmt.headingPad.Parent = fmt.headingPopup
	fmt.headingLayout = InstanceNew("UIListLayout")
	fmt.headingLayout.Padding = UDim.new(0, 3)
	fmt.headingLayout.SortOrder = Enum.SortOrder.LayoutOrder
	fmt.headingLayout.Parent = fmt.headingPopup
	fmt.headingOptions = {
		{ "Title", 1 },
		{ "Subtitle", 2 },
		{ "Heading", 3 },
		{ "Subheading", 4 },
		{ "Section", 5 },
		{ "Subsection", 6 },
		{ "Body", 0 },
	}

	fmt.listPopup = fmt.newPopup("ListMenu", 180, 132)
	fmt.listPad = InstanceNew("UIPadding")
	fmt.listPad.PaddingTop = UDim.new(0, 6)
	fmt.listPad.PaddingBottom = UDim.new(0, 6)
	fmt.listPad.PaddingLeft = UDim.new(0, 6)
	fmt.listPad.PaddingRight = UDim.new(0, 6)
	fmt.listPad.Parent = fmt.listPopup
	fmt.listLayout = InstanceNew("UIListLayout")
	fmt.listLayout.Padding = UDim.new(0, 4)
	fmt.listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	fmt.listLayout.Parent = fmt.listPopup

	fmt.linkPopup = fmt.newPopup("LinkMenu", 246, 112)
	fmt.linkLabel = InstanceNew("TextLabel")
	fmt.linkLabel.BackgroundTransparency = 1
	fmt.linkLabel.Font = Enum.Font.GothamSemibold
	fmt.linkLabel.Position = UDim2.new(0, 10, 0, 7)
	fmt.linkLabel.Size = UDim2.new(1, -20, 0, 20)
	fmt.linkLabel.Text = "Insert link"
	fmt.linkLabel.TextColor3 = col.tx
	fmt.linkLabel.TextSize = 12
	fmt.linkLabel.TextXAlignment = Enum.TextXAlignment.Left
	fmt.linkLabel.ZIndex = 71
	fmt.linkLabel.Parent = fmt.linkPopup
	fmt.linkUrl = InstanceNew("TextBox")
	fmt.linkUrl.BackgroundColor3 = col.bg3
	fmt.linkUrl.BorderSizePixel = 0
	fmt.linkUrl.ClearTextOnFocus = false
	fmt.linkUrl.Font = Enum.Font.Gotham
	fmt.linkUrl.PlaceholderText = "https://example.com"
	fmt.linkUrl.PlaceholderColor3 = col.sub
	fmt.linkUrl.Position = UDim2.new(0, 10, 0, 31)
	fmt.linkUrl.Size = UDim2.new(1, -20, 0, 30)
	fmt.linkUrl.Text = ""
	fmt.linkUrl.TextColor3 = col.tx
	fmt.linkUrl.TextSize = 12
	fmt.linkUrl.TextXAlignment = Enum.TextXAlignment.Left
	fmt.linkUrl.ZIndex = 71
	fmt.linkUrl.Parent = fmt.linkPopup
	skin(fmt.linkUrl, 6, 1)
	fmt.linkApply = btn(fmt.linkPopup, "Apply", 74, 1)
	fmt.linkApply.Position = UDim2.new(1, -158, 1, -38)
	fmt.linkApply.Size = UDim2.fromOffset(70, 28)
	fmt.linkApply.ZIndex = 71
	fmt.linkCancel = btn(fmt.linkPopup, "Cancel", 74, 2)
	fmt.linkCancel.Position = UDim2.new(1, -80, 1, -38)
	fmt.linkCancel.Size = UDim2.fromOffset(70, 28)
	fmt.linkCancel.ZIndex = 71


	fmt.savedCursor = 1
	fmt.savedSelectionStart = -1
	fmt.captureSelection = function()
		const liveCursor = tonumber(box.CursorPosition) or -1
		const liveAnchor = tonumber(box.SelectionStart) or -1
		if liveCursor > 0 then
			fmt.savedCursor = liveCursor
			if liveAnchor > 0 and liveAnchor ~= liveCursor then
				fmt.savedSelectionStart = liveAnchor
			elseif box:IsFocused() then
				fmt.savedSelectionStart = -1
			end
		end
	end

	fmt.getSelection = function()
		const text = tostring(box.Text or "")
		fmt.captureSelection()
		local cursor = tonumber(box.CursorPosition) or -1
		local anchor = tonumber(box.SelectionStart) or -1
		if cursor < 1 then
			cursor = tonumber(fmt.savedCursor) or (#text + 1)
		end
		if anchor < 1 then
			anchor = tonumber(fmt.savedSelectionStart) or -1
		end
		cursor = math.clamp(cursor, 1, #text + 1)
		if anchor and anchor > 0 then
			anchor = math.clamp(anchor, 1, #text + 1)
		end
		if anchor and anchor > 0 and anchor ~= cursor then
			return text, math.min(anchor, cursor), math.max(anchor, cursor), true
		end
		return text, cursor, cursor, false
	end

	fmt.setSelection = function(startPos, endPos)
		const limitNow = #tostring(box.Text or "") + 1
		startPos = math.clamp(math.floor(tonumber(startPos) or 1), 1, limitNow)
		endPos = math.clamp(math.floor(tonumber(endPos) or startPos), 1, limitNow)
		fmt.savedCursor = endPos
		fmt.savedSelectionStart = startPos ~= endPos and startPos or -1
		Defer(function()
			if not (box and box.Parent) then
				return
			end
			const limit = #tostring(box.Text or "") + 1
			startPos = math.clamp(startPos, 1, limit)
			endPos = math.clamp(endPos, 1, limit)
			pcall(function()
				box:CaptureFocus()
				box.SelectionStart = startPos
				box.CursorPosition = endPos
			end)
		end)
	end

	fmt.replaceRange = function(firstPos, lastPos, replacement, selectFirst, selectLast)
		const text = tostring(box.Text or "")
		firstPos = math.clamp(math.floor(tonumber(firstPos) or 1), 1, #text + 1)
		lastPos = math.clamp(math.floor(tonumber(lastPos) or firstPos), firstPos, #text + 1)
		replacement = tostring(replacement or "")
		box.Text = text:sub(1, firstPos - 1)..replacement..text:sub(lastPos)
		if selectFirst ~= nil then
			fmt.setSelection(selectFirst, selectLast or selectFirst)
		else
			fmt.setSelection(firstPos + #replacement, firstPos + #replacement)
		end
	end

	fmt.wrapInline = function(openMark, closeMark, placeholder, statusName)
		local text, firstPos, lastPos, selected = fmt.getSelection()
		const chosen = selected and text:sub(firstPos, lastPos - 1) or ""
		if selected and #chosen >= (#openMark + #closeMark) and chosen:sub(1, #openMark) == openMark and chosen:sub(-#closeMark) == closeMark then
			const inner = chosen:sub(#openMark + 1, #chosen - #closeMark)
			fmt.replaceRange(firstPos, lastPos, inner, firstPos, firstPos + #inner)
			setStatus("Removed "..statusName.." formatting", col.sub)
			return
		end
		if selected and firstPos > #openMark and text:sub(firstPos - #openMark, firstPos - 1) == openMark and text:sub(lastPos, lastPos + #closeMark - 1) == closeMark then
			fmt.replaceRange(firstPos - #openMark, lastPos + #closeMark, chosen, firstPos - #openMark, firstPos - #openMark + #chosen)
			setStatus("Removed "..statusName.." formatting", col.sub)
			return
		end
		const inner = selected and chosen or tostring(placeholder or "text")
		const replacement = openMark..inner..closeMark
		fmt.replaceRange(firstPos, lastPos, replacement, firstPos + #openMark, firstPos + #openMark + #inner)
		setStatus("Applied "..statusName.." formatting", col.ok)
	end

	fmt.getLineRange = function()
		local text, firstPos, lastPos, selected = fmt.getSelection()
		local before = text:sub(1, math.max(firstPos - 1, 0))
		local lineStart = before:match(".*()\n")
		lineStart = lineStart and (lineStart + 1) or 1
		local probe = selected and math.max(firstPos, lastPos - 1) or firstPos
		local nextBreak = text:find("\n", probe, true)
		local lineEnd = nextBreak and (nextBreak - 1) or #text
		return text, lineStart, lineEnd + 1
	end

	fmt.transformLines = function(transform)
		local text, firstPos, lastPos = fmt.getLineRange()
		const block = text:sub(firstPos, lastPos - 1)
		const lines = {}
		for line in (block.."\n"):gmatch("(.-)\n") do
			lines[#lines + 1] = line
		end
		if #lines == 0 then
			lines[1] = ""
		end
		for i, line in lines do
			lines[i] = tostring(transform(line, i, lines) or "")
		end
		const replacement = Concat(lines, "\n")
		fmt.replaceRange(firstPos, lastPos, replacement, firstPos, firstPos + #replacement)
		return replacement
	end

	fmt.removeHeadingPrefix = function(content)
		content = tostring(content or "")
		local _, inner = content:match('^<font size="(%d+)"><b>(.*)</b></font>$')
		if inner ~= nil then
			return inner
		end
		local hashes, rest = content:match("^(#+)%s+(.*)$")
		if hashes and #hashes <= 6 then
			return rest
		end
		return content
	end

	fmt.stripLinePrefix = function(line)
		local indent, content = tostring(line or ""):match("^(%s*)(.*)$")
		indent = indent or ""
		content = fmt.removeHeadingPrefix(content or "")
		content = content:gsub("^•%s+", "")
		content = content:gsub("^[-%*+]%s+", "")
		content = content:gsub("^%d+[%.%)]%s+", "")
		return indent, content
	end

	fmt.applyHeading = function(level)
		level = math.clamp(math.floor(tonumber(level) or 0), 0, 6)
		fmt.transformLines(function(line)
			local indent, content = tostring(line or ""):match("^(%s*)(.*)$")
			indent = indent or ""
			content = fmt.removeHeadingPrefix(content or "")
			if level == 0 then
				return indent..content
			end
			return indent..string.rep("#", level).." "..content
		end)
		fmt.heading.Text = level == 0 and "Body v" or ("H"..tostring(level).." v")
		fmt.headingPopup.Visible = false
		setStatus(level == 0 and "Changed to body text" or ("Applied heading H"..tostring(level)), col.ok)
	end

	fmt.applyList = function(kind)
		local number = 0
		fmt.transformLines(function(line)
			local indent, content = fmt.stripLinePrefix(line)
			if kind == "bullet" then
				return indent.."- "..content
			end
			number += 1
			return indent..tostring(number)..". "..content
		end)
		fmt.listPopup.Visible = false
		setStatus(kind == "bullet" and "Applied bulleted list" or "Applied numbered list", col.ok)
	end

	fmt.indentLines = function(direction)
		fmt.transformLines(function(line)
			line = tostring(line or "")
			if direction > 0 then
				return "    "..line
			end
			if line:sub(1, 1) == "\t" then
				return line:sub(2)
			end
			local spaces = line:match("^( +)")
			if spaces then
				const remove = math.min(#spaces, 4)
				return line:sub(remove + 1)
			end
			return line
		end)
		setStatus(direction > 0 and "Increased indent" or "Decreased indent", col.sub)
	end

	fmt.stripInline = function(source)
		source = fmt.stripRich(source)
		source = source:gsub("%[([^%]]-)%]%([^%)]-%)", "%1")
		source = source:gsub("%*%*", "")
		source = source:gsub("__", "")
		source = source:gsub("~~", "")
		source = source:gsub("`", "")
		source = source:gsub("_", "")
		source = source:gsub("%*", "")
		return source
	end

	fmt.clearFormatting = function()
		local text, firstPos, lastPos, selected = fmt.getSelection()
		if selected then
			local chosen = text:sub(firstPos, lastPos - 1)
			const cleaned = fmt.stripInline(chosen:gsub("(^[^\n]*)", function(line)
				local indent, content = fmt.stripLinePrefix(line)
				return indent..content
			end):gsub("\n([^\n]*)", function(line)
				local indent, content = fmt.stripLinePrefix(line)
				return "\n"..indent..content
			end))
			fmt.replaceRange(firstPos, lastPos, cleaned, firstPos, firstPos + #cleaned)
		else
			fmt.transformLines(function(line)
				local indent, content = fmt.stripLinePrefix(line)
				return indent..fmt.stripInline(content)
			end)
		end
		setStatus("Cleared formatting", col.sub)
	end

	fmt.currentLine = function()
		local text, firstPos = fmt.getSelection()
		local before = text:sub(1, math.max(firstPos - 1, 0))
		local lineStart = before:match(".*()\n")
		lineStart = lineStart and lineStart + 1 or 1
		local nextBreak = text:find("\n", firstPos, true)
		return text:sub(lineStart, nextBreak and nextBreak - 1 or #text)
	end

	fmt.syncContext = function()
		const line = fmt.currentLine()
		const richSize = tonumber(line:match('^%s*<font size="(%d+)"><b>'))
		if richSize then
			local level = 0
			for i, size in fmt.headingSizes do
				if tonumber(size) == richSize then
					level = i
					break
				end
			end
			fmt.heading.Text = level > 0 and ("H"..tostring(level).." v") or "Body v"
			return
		end
		const hashes = line:match("^%s*(#+)%s+")
		fmt.heading.Text = hashes and #hashes <= 6 and ("H"..tostring(#hashes).." v") or "Body v"
	end

	fmt.hasListContext = function()
		const line = fmt.currentLine()
		return line:match("^%s*•%s+") ~= nil or line:match("^%s*[-%*+]%s+") ~= nil or line:match("^%s*%d+[%.%)]%s+") ~= nil
	end

	fmt.setListIndentEnabled = function(enabled)
		for _, b in { fmt.indentMore, fmt.indentLess } do
			if b then
				b.Active = enabled
				b.TextColor3 = enabled and col.tx or col.sub:Lerp(col.bg2, 0.25)
				b.BackgroundColor3 = enabled and col.bg3 or col.bg2
			end
		end
	end

	for order, entry in fmt.headingOptions do
		const item = btn(fmt.headingPopup, entry[1], 1, order)
		item.Size = UDim2.new(1, 0, 0, 26)
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.TextSize = order == 1 and 18 or (order == 2 and 16 or (order == 3 and 14 or 12))
		item.ZIndex = 71
		MouseButtonFix(item, function()
			fmt.applyHeading(entry[2])
		end)
	end

	fmt.bulletItem = btn(fmt.listPopup, "Bulleted list", 1, 1)
	fmt.bulletItem.Size = UDim2.new(1, 0, 0, 27)
	fmt.bulletItem.TextXAlignment = Enum.TextXAlignment.Left
	fmt.bulletItem.ZIndex = 71
	fmt.numberItem = btn(fmt.listPopup, "Numbered list", 1, 2)
	fmt.numberItem.Size = UDim2.new(1, 0, 0, 27)
	fmt.numberItem.TextXAlignment = Enum.TextXAlignment.Left
	fmt.numberItem.ZIndex = 71
	fmt.indentMore = btn(fmt.listPopup, "Increase indent", 1, 3)
	fmt.indentMore.Size = UDim2.new(1, 0, 0, 27)
	fmt.indentMore.TextXAlignment = Enum.TextXAlignment.Left
	fmt.indentMore.ZIndex = 71
	fmt.indentLess = btn(fmt.listPopup, "Decrease indent", 1, 4)
	fmt.indentLess.Size = UDim2.new(1, 0, 0, 27)
	fmt.indentLess.TextXAlignment = Enum.TextXAlignment.Left
	fmt.indentLess.ZIndex = 71

	fmt.showLink = function()
		fmt.hidePopups(fmt.linkPopup)
		fmt.positionPopup(fmt.linkPopup, fmt.link)
		fmt.linkPopup.Visible = true
		if type(getclipboard) == "function" then
			local ok, clip = pcall(getclipboard)
			if ok and type(clip) == "string" and clip:match("^https?://") then
				fmt.linkUrl.Text = clip
			end
		end
		Defer(function()
			if fmt.linkPopup.Visible then
				pcall(function() fmt.linkUrl:CaptureFocus() end)
			end
		end)
	end

	fmt.applyLink = function()
		const url = trim(fmt.linkUrl.Text)
		if url == "" then
			setStatus("Enter a link URL", col.err)
			return
		end
		local text, firstPos, lastPos, selected = fmt.getSelection()
		const chosen = selected and text:sub(firstPos, lastPos - 1) or "link text"
		const replacement = "["..chosen.."]("..url..")"
		fmt.replaceRange(firstPos, lastPos, replacement, firstPos + 1, firstPos + 1 + #chosen)
		fmt.linkPopup.Visible = false
		setStatus("Inserted Markdown link", col.ok)
	end


	MouseButtonFix(fmt.heading, function()
		const nextState = not fmt.headingPopup.Visible
		fmt.hidePopups(fmt.headingPopup)
		if nextState then
			fmt.positionPopup(fmt.headingPopup, fmt.heading)
		end
		fmt.headingPopup.Visible = nextState
	end)
	MouseButtonFix(fmt.list, function()
		const nextState = not fmt.listPopup.Visible
		fmt.hidePopups(fmt.listPopup)
		if nextState then
			fmt.setListIndentEnabled(fmt.hasListContext())
			fmt.positionPopup(fmt.listPopup, fmt.list)
		end
		fmt.listPopup.Visible = nextState
	end)
	MouseButtonFix(fmt.bold, function()
		fmt.hidePopups()
		fmt.wrapInline("**", "**", "bold text", "bold")
	end)
	MouseButtonFix(fmt.italic, function()
		fmt.hidePopups()
		fmt.wrapInline("*", "*", "italic text", "italic")
	end)
	MouseButtonFix(fmt.strike, function()
		fmt.hidePopups()
		fmt.wrapInline("~~", "~~", "strikethrough text", "strikethrough")
	end)
	MouseButtonFix(fmt.link, fmt.showLink)
	MouseButtonFix(fmt.clear, function()
		fmt.hidePopups()
		fmt.clearFormatting()
	end)
	MouseButtonFix(fmt.bulletItem, function()
		fmt.applyList("bullet")
	end)
	MouseButtonFix(fmt.numberItem, function()
		fmt.applyList("number")
	end)
	MouseButtonFix(fmt.indentMore, function()
		if fmt.hasListContext() then
			fmt.indentLines(1)
		end
	end)
	MouseButtonFix(fmt.indentLess, function()
		if fmt.hasListContext() then
			fmt.indentLines(-1)
		end
	end)
	MouseButtonFix(fmt.linkApply, fmt.applyLink)
	MouseButtonFix(fmt.linkCancel, function()
		fmt.linkPopup.Visible = false
	end)

	box:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		fmt.captureSelection()
		fmt.syncContext()
	end)
	pcall(function()
		box:GetPropertyChangedSignal("SelectionStart"):Connect(function()
			fmt.captureSelection()
			fmt.syncContext()
		end)
	end)

	const optionsDrop = InstanceNew("Frame")
	optionsDrop.Visible = false
	optionsDrop.ClipsDescendants = true
	optionsDrop.BackgroundColor3 = col.bg2
	optionsDrop.BorderSizePixel = 0
	optionsDrop.ZIndex = 43
	optionsDrop.Size = UDim2.new(0, 188, 0, 118)
	optionsDrop.Parent = main
	skin(optionsDrop, 8, 1)

	const optionsPad = InstanceNew("UIPadding")
	optionsPad.PaddingBottom = UDim.new(0, 8)
	optionsPad.PaddingLeft = UDim.new(0, 8)
	optionsPad.PaddingRight = UDim.new(0, 8)
	optionsPad.PaddingTop = UDim.new(0, 8)
	optionsPad.Parent = optionsDrop

	const optionsLay = InstanceNew("UIListLayout")
	optionsLay.Padding = UDim.new(0, 6)
	optionsLay.SortOrder = Enum.SortOrder.LayoutOrder
	optionsLay.Parent = optionsDrop

	const fontRow = InstanceNew("Frame")
	fontRow.BackgroundTransparency = 1
	fontRow.BorderSizePixel = 0
	fontRow.LayoutOrder = 1
	fontRow.Size = UDim2.new(1, 0, 0, 25)
	fontRow.ZIndex = 44
	fontRow.Parent = optionsDrop

	const fontLabel = InstanceNew("TextLabel")
	fontLabel.BackgroundTransparency = 1
	fontLabel.BorderSizePixel = 0
	fontLabel.Font = Enum.Font.Gotham
	fontLabel.Size = UDim2.new(1, -96, 1, 0)
	fontLabel.Text = "Font"
	fontLabel.TextColor3 = col.tx
	fontLabel.TextSize = 12
	fontLabel.TextXAlignment = Enum.TextXAlignment.Left
	fontLabel.ZIndex = 44
	fontLabel.Parent = fontRow

	const fontMinus = btn(fontRow, "-", 28, 1)
	fontMinus.AnchorPoint = Vector2.new(1, 0)
	fontMinus.Position = UDim2.new(1, -64, 0, 0)
	fontMinus.Size = UDim2.new(0, 28, 1, 0)
	fontMinus.ZIndex = 44
	const fontValue = InstanceNew("TextLabel")
	fontValue.BackgroundTransparency = 1
	fontValue.BorderSizePixel = 0
	fontValue.Font = Enum.Font.GothamSemibold
	fontValue.Position = UDim2.new(1, -62, 0, 0)
	fontValue.Size = UDim2.new(0, 30, 1, 0)
	fontValue.Text = ""
	fontValue.TextColor3 = col.sub
	fontValue.TextSize = 12
	fontValue.TextXAlignment = Enum.TextXAlignment.Center
	fontValue.ZIndex = 44
	fontValue.Parent = fontRow
	const fontPlus = btn(fontRow, "+", 28, 2)
	fontPlus.AnchorPoint = Vector2.new(1, 0)
	fontPlus.Position = UDim2.new(1, 0, 0, 0)
	fontPlus.Size = UDim2.new(0, 28, 1, 0)
	fontPlus.ZIndex = 44

	const wrapBtn = btn(optionsDrop, "Wrap: Off", 1, 2)
	wrapBtn.Size = UDim2.new(1, 0, 0, 25)
	wrapBtn.ZIndex = 44
	const copyBtn = btn(optionsDrop, "Copy Text", 1, 3)
	copyBtn.Size = UDim2.new(1, 0, 0, 25)
	copyBtn.ZIndex = 44
	const pasteBtn = btn(optionsDrop, "Paste Clipboard", 1, 4)
	pasteBtn.Size = UDim2.new(1, 0, 0, 25)
	pasteBtn.ZIndex = 44

	const function applyNotepadOptions()
		NAStuff.NotepadSettings.fontSize = math.clamp(math.floor((tonumber(NAStuff.NotepadSettings.fontSize) or 15) + 0.5), 11, 24)
		box.TextSize = NAStuff.NotepadSettings.fontSize
		box.TextWrapped = NAStuff.NotepadSettings.wrap == true
		fontValue.Text = tostring(NAStuff.NotepadSettings.fontSize)
		wrapBtn.Text = "Wrap: "..(NAStuff.NotepadSettings.wrap and "On" or "Off")
		wrapBtn.BackgroundColor3 = NAStuff.NotepadSettings.wrap and col.on or col.bg3
	end

	const function posOptionsDrop()
		const mainPos = main.AbsolutePosition
		const btnPos = optBtn.AbsolutePosition
		const btnSize = optBtn.AbsoluteSize
		const dropW = optionsDrop.AbsoluteSize.X > 0 and optionsDrop.AbsoluteSize.X or 188
		const dropH = optionsDrop.AbsoluteSize.Y > 0 and optionsDrop.AbsoluteSize.Y or 118
		local x = btnPos.X - mainPos.X
		local y = btnPos.Y - mainPos.Y + btnSize.Y + 4
		x = math.clamp(x, 4, math.max(4, main.AbsoluteSize.X - dropW - 8))
		if y + dropH + 8 > main.AbsoluteSize.Y then
			y = btnPos.Y - mainPos.Y - dropH - 4
		end
		optionsDrop.Position = UDim2.fromOffset(x, math.max(4, y))
	end

	const bottom = InstanceNew("Frame")
	bottom.BackgroundTransparency = 1
	bottom.Position = UDim2.new(0, 10, 1, -32)
	bottom.Size = UDim2.new(1, -20, 0, 24)
	bottom.Parent = main

	const status = InstanceNew("TextLabel")
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.Gotham
	status.Text = fsOk and ("Ready | "..dir) or "Filesystem unavailable"
	status.TextColor3 = fsOk and col.sub or col.err
	status.TextSize = 12
	status.TextXAlignment = Enum.TextXAlignment.Left
	status.Size = UDim2.new(1, -180, 1, 0)
	status.Parent = bottom
	NAStuff.NotepadStatusLabel = status

	const count = InstanceNew("TextLabel")
	count.BackgroundTransparency = 1
	count.Font = Enum.Font.Gotham
	count.Text = "0 chars | 0 lines"
	count.TextColor3 = col.sub
	count.TextSize = 12
	count.TextXAlignment = Enum.TextXAlignment.Right
	count.AnchorPoint = Vector2.new(1, 0)
	count.Position = UDim2.new(1, 0, 0, 0)
	count.Size = UDim2.new(0, 170, 1, 0)
	count.Parent = bottom

	const pageBar = InstanceNew("Frame")
	pageBar.BackgroundTransparency = 1
	pageBar.BorderSizePixel = 0
	pageBar.AnchorPoint = Vector2.new(0.5, 0)
	pageBar.Position = UDim2.new(0.5, 30, 0, 0)
	pageBar.Size = UDim2.new(0, 174, 1, 0)
	pageBar.Parent = bottom

	const pageLay = InstanceNew("UIListLayout")
	pageLay.FillDirection = Enum.FillDirection.Horizontal
	pageLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageLay.VerticalAlignment = Enum.VerticalAlignment.Center
	pageLay.SortOrder = Enum.SortOrder.LayoutOrder
	pageLay.Padding = UDim.new(0, 5)
	pageLay.Parent = pageBar

	const pagePrev = btn(pageBar, "<", 34, 1)
	const pageText = InstanceNew("TextLabel")
	pageText.BackgroundTransparency = 1
	pageText.BorderSizePixel = 0
	pageText.Font = Enum.Font.GothamSemibold
	pageText.LayoutOrder = 2
	pageText.Size = UDim2.new(0, 86, 1, 0)
	pageText.Text = "Lines 1-1/1"
	pageText.TextColor3 = col.sub
	pageText.TextSize = 12
	pageText.Parent = pageBar
	const pageNext = btn(pageBar, ">", 34, 3)

	const function setBtnSize(b, w, s)
		if not b then
			return
		end
		b.Size = UDim2.new(0, w, 1, 0)
		b.TextSize = s
	end

	const function updateNotepadLayout()
		const w = frame.AbsoluteSize.X
		const h = frame.AbsoluteSize.Y
		const compact = w < 720 or h < 390
		const tiny = w < 590
		const micro = w < 430
		const pad = compact and 6 or 7
		const gap = compact and 8 or 10
		root.Position = UDim2.new(0, pad, 0, pad)
		root.Size = UDim2.new(1, -pad * 2, 1, -pad * 2)
		if tiny then
			side.Visible = false
			main.Position = UDim2.new(0, 0, 0, 0)
			main.Size = UDim2.new(1, 0, 1, 0)
		else
			const sideW = compact and 150 or 182
			side.Visible = true
			side.Size = UDim2.new(0, sideW, 1, 0)
			main.Position = UDim2.new(0, sideW + gap, 0, 0)
			main.Size = UDim2.new(1, -(sideW + gap), 1, 0)
		end
		const inner = compact and 8 or 10
		const toolH = compact and 28 or 30
		const txtSize = compact and 12 or 13
		tool.Position = UDim2.new(0, inner, 0, inner)
		tool.Size = UDim2.new(1, -inner * 2, 0, toolH)
		toolLay.Padding = UDim.new(0, compact and 4 or 6)
		nameBox.TextSize = txtSize
		nameBox.Size = UDim2.new(0, micro and 82 or (tiny and 100 or (compact and 110 or 135)), 1, 0)
		setBtnSize(extBtn, micro and 42 or (tiny and 44 or (compact and 46 or 54)), txtSize)
		setBtnSize(newBtn, micro and 32 or (tiny and 34 or (compact and 36 or 40)), txtSize)
		setBtnSize(openBtn, micro and 36 or (tiny and 40 or (compact and 42 or 45)), txtSize)
		setBtnSize(saveBtn, micro and 34 or (tiny and 36 or (compact and 38 or 43)), txtSize)
		setBtnSize(clearBtn, micro and 36 or (tiny and 40 or (compact and 42 or 45)), txtSize)
		setBtnSize(delBtn, micro and 28 or (tiny and 30 or (compact and 32 or 36)), txtSize)
		if micro then
			refBtn.Visible = false
			refBtn.Size = UDim2.new(0, 0, 1, 0)
			optBtn.Visible = false
			optBtn.Size = UDim2.new(0, 0, 1, 0)
			optionsDrop.Visible = false
		else
			refBtn.Visible = true
			setBtnSize(refBtn, tiny and 44 or (compact and 50 or 55), txtSize)
			optBtn.Visible = true
			setBtnSize(optBtn, tiny and 50 or (compact and 56 or 62), txtSize)
		end
		const fmtH = compact and 28 or 30
		fmt.bar.Position = UDim2.new(0, inner, 0, inner + toolH + 6)
		fmt.bar.Size = UDim2.new(1, -inner * 2, 0, fmtH)
		fmt.scroll.CanvasSize = UDim2.new(0, fmt.layout.AbsoluteContentSize.X + 8, 0, 0)
		const bodyTop = inner + toolH + fmtH + 14
		body.Position = UDim2.new(0, inner, 0, bodyTop)
		body.Size = UDim2.new(1, -inner * 2, 1, -(bodyTop + (compact and 36 or 40)))
		body.ScrollBarThickness = 0
		notepadLineScroll.Position = body.Position
		notepadLineScroll.Size = body.Size
		bottom.Position = UDim2.new(0, inner, 1, compact and -28 or -32)
		bottom.Size = UDim2.new(1, -inner * 2, 0, 24)
		status.TextSize = compact and 11 or 12
		count.TextSize = compact and 11 or 12
		count.Size = UDim2.new(0, micro and 112 or 170, 1, 0)
		status.Size = UDim2.new(1, -(micro and 116 or 180), 1, 0)
		pageBar.Position = UDim2.new(0.5, tiny and 0 or 30, 0, 0)
		pageBar.Size = UDim2.new(0, micro and 142 or 174, 1, 0)
		pageText.Size = UDim2.new(0, micro and 74 or 86, 1, 0)
		pageText.TextSize = compact and 11 or 12
		setBtnSize(pagePrev, micro and 28 or 34, compact and 11 or 12)
		setBtnSize(pageNext, micro and 28 or 34, compact and 11 or 12)
		applyNotepadOptions()
		if extDrop.Visible then
			posExtDrop()
		end
		if optionsDrop.Visible then
			posOptionsDrop()
		end
		for _, popup in fmt.popups do
			if popup.Visible then
				if popup == fmt.headingPopup then
					fmt.positionPopup(popup, fmt.heading)
				elseif popup == fmt.listPopup then
					fmt.positionPopup(popup, fmt.list)
				elseif popup == fmt.linkPopup then
					fmt.positionPopup(popup, fmt.link)
				end
			end
		end
	end

	const function lineCount(s)

		s = tostring(s or "")
		if s == "" then
			return 0
		end
		return select(2, s:gsub("\n", "")) + 1
	end

	const notepadLineBuffer = 24
	local chunks = { "" }
	local page = 1
	local visibleEndLine = 1
	local notepadLineHeight = 19
	local loadingText = false

	const function splitText(source)
		source = tostring(source or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
		const out = {}
		for line in (source.."\n"):gmatch("(.-)\n") do
			out[#out + 1] = line
		end
		if #out == 0 then
			out[1] = ""
		end
		return out
	end

	const function joinText(lines)
		if type(lines) ~= "table" or #lines == 0 then
			return ""
		end
		return Concat(lines, "\n")
	end

	const function sliceText(lines, firstLine, lastLine)
		const out = {}
		firstLine = math.max(1, tonumber(firstLine) or 1)
		lastLine = math.max(firstLine, tonumber(lastLine) or firstLine)
		for line = firstLine, lastLine do
			out[#out + 1] = tostring(lines[line] or "")
		end
		if #out == 0 then
			out[1] = ""
		end
		return Concat(out, "\n")
	end

	const function replaceTextRange(lines, firstLine, lastLine, text)
		lines = type(lines) == "table" and lines or { "" }
		const inserted = splitText(text)
		const rebuilt = {}
		firstLine = math.clamp(tonumber(firstLine) or 1, 1, math.max(#lines + 1, 1))
		lastLine = math.clamp(tonumber(lastLine) or (firstLine - 1), firstLine - 1, math.max(#lines, firstLine - 1))
		for line = 1, firstLine - 1 do
			rebuilt[#rebuilt + 1] = tostring(lines[line] or "")
		end
		for _, lineText in inserted do
			rebuilt[#rebuilt + 1] = tostring(lineText or "")
		end
		for line = lastLine + 1, #lines do
			rebuilt[#rebuilt + 1] = tostring(lines[line] or "")
		end
		if #rebuilt == 0 then
			rebuilt[1] = ""
		end
		return rebuilt
	end

	const function syncVisibleNotepadText()
		if not loadingText then
			const oldEnd = visibleEndLine
			chunks = replaceTextRange(chunks, page, oldEnd, box.Text or "")
			visibleEndLine = page + #splitText(box.Text or "") - 1
		end
	end

	const function countNotepadChars()
		local total = math.max(#chunks - 1, 0)
		for _, line in chunks do
			total += #tostring(line or "")
		end
		return total
	end

	const function buildFullText(useBox)
		if useBox and not loadingText then
			syncVisibleNotepadText()
		end
		return joinText(chunks)
	end

	const function getNotepadLineHeight()
		const fallback = tonumber(box.TextSize) or 15
		const widthService = Services.TextService or TextServiceRef
		if widthService and widthService.GetTextSize then
			local ok, measured = pcall(function()
				return widthService:GetTextSize("M", box.TextSize, box.Font, Vector2.new(1000, 1000)).Y
			end)
			if ok and type(measured) == "number" then
				return math.max(1, math.ceil(measured))
			end
		end
		return math.max(1, math.ceil(fallback))
	end

	const function measureNotepadText(source)
		const lineHeight = getNotepadLineHeight()
		local longest = 0
		local lines = 0
		for line in ((source or "").."\n"):gmatch("(.-)\n") do
			lines += 1
			local width = 0
			if Services.TextService and Services.TextService.GetTextSize then
				local ok, res = pcall(function()
					return Services.TextService:GetTextSize((line ~= "" and line or " "), box.TextSize, box.Font, Vector2.new(10000, 10000)).X
				end)
				if ok and type(res) == "number" then
					width = res
				end
			end
			if width <= 0 then
				width = #line * math.max(box.TextSize * 0.62, 8)
			end
			if width > longest then
				longest = width
			end
		end
		if lines <= 0 then
			lines = 1
		end
		const viewWidth = math.max(1, (body.AbsoluteSize.X or 0) - 18)
		const w = math.max(viewWidth, longest + 12)
		const h = math.max(math.max(body.AbsoluteSize.Y - 30, 1), lines * lineHeight + 18)
		return w, h
	end

	const function getNotepadViewportHeight()
		local h = (body.AbsoluteSize.Y or 0) - 30
		if NAmanage.virtView then
			h = NAmanage.virtView(notepadLineScroll, h, notepadLineScroll.CanvasSize.Y.Offset, getNotepadLineHeight() * 3)
		end
		return math.max(1, h)
	end

	const function getNotepadWindowMetrics()
		const lineHeight = getNotepadLineHeight()
		const visible = math.max(1, math.floor(getNotepadViewportHeight() / math.max(lineHeight, 1)))
		return lineHeight, visible
	end

	const function getNotepadVisibleLine(totalLines)
		const lineHeight = getNotepadWindowMetrics()
		const total = math.max(tonumber(totalLines) or 1, 1)
		const notepadLinePos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(notepadLineScroll) or notepadLineScroll.CanvasPosition
		return math.clamp(math.floor(math.max(notepadLinePos.Y, 0) / math.max(lineHeight, 1)) + 1, 1, total)
	end

	const function getNotepadWindowRange(totalLines, firstVisibleLine)
		local _, visibleLines = getNotepadWindowMetrics()
		const total = math.max(tonumber(totalLines) or 1, 1)
		const firstVisible = math.clamp(tonumber(firstVisibleLine) or getNotepadVisibleLine(total), 1, total)
		const lastVisible = math.clamp(firstVisible + visibleLines - 1, firstVisible, total)
		const firstRender = firstVisible
		const lastRender = lastVisible
		return firstRender, lastRender, firstVisible, lastVisible
	end

	const function updEditorSize()
		local w, h = measureNotepadText((box.RichText and box.ContentText) or box.Text or "")
		if box.RichText and box.TextBounds then
			w = math.max(w, math.ceil(box.TextBounds.X + 18))
			h = math.max(h, math.ceil(box.TextBounds.Y + 18))
		end
		notepadLineHeight = getNotepadLineHeight()
		const fullHeight = math.max(getNotepadViewportHeight(), math.max(#chunks, 1) * notepadLineHeight + 18)
		local _, visibleLines = getNotepadWindowMetrics()
		const virtualTotal = math.max(#chunks + 1, visibleLines)
		const maxTopY = math.max(0, (virtualTotal - visibleLines) * notepadLineHeight)
		const proxyHeight = math.max(fullHeight + notepadLineHeight + 16, (body.AbsoluteSize.Y or 0) + maxTopY + notepadLineHeight)
		box.Position = UDim2.new(0, 8, 0, 8)
		box.Size = UDim2.new(0, w, 0, h)
		const canvasWidth = math.max(body.AbsoluteSize.X or 1, 8 + w + 2)
		body.CanvasSize = UDim2.new(0, canvasWidth, 0, math.max(body.AbsoluteSize.Y, 1))
		notepadLineScroll.Position = body.Position
		notepadLineScroll.Size = body.Size
		notepadLineScroll.CanvasSize = UDim2.new(0, 0, 0, proxyHeight)
		if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
			NAmanage.CustomScroll.refreshByTarget(body)
			NAmanage.CustomScroll.refreshByTarget(notepadLineScroll)
		end
	end

	const function updCount()
		syncVisibleNotepadText()
		count.Text = tostring(countNotepadChars()).." chars | "..tostring(math.max(#chunks, 1)).." lines"
		page = math.clamp(tonumber(page) or 1, 1, math.max(#chunks, 1))
		visibleEndLine = math.clamp(visibleEndLine, page, math.max(#chunks, 1))
		local _, _, firstVisible, lastVisible = getNotepadWindowRange(math.max(#chunks, 1))
		pageText.Text = "Lines "..tostring(firstVisible).."-"..tostring(lastVisible).."/"..tostring(math.max(#chunks, 1))
		pageBar.Visible = #chunks > math.max(1, lastVisible - firstVisible + 1)
		pagePrev.Visible = false
		pageNext.Visible = false
		updEditorSize()
	end

	const function loadPage(nextPage, preserveScroll)
		const total = math.max(#chunks, 1)
		const lineHeight = getNotepadWindowMetrics()
		const visibleLine = preserveScroll == true and getNotepadVisibleLine(total) or math.clamp(tonumber(nextPage) or page or 1, 1, total)
		local firstRender, lastRender, firstVisible = getNotepadWindowRange(total, visibleLine)
		page = firstRender
		visibleEndLine = lastRender
		loadingText = true
		if preserveScroll ~= true then
			if NAmanage.SetLogicalCanvasPosition then
				NAmanage.SetLogicalCanvasPosition(notepadLineScroll, 0, math.max(0, (firstVisible - 1) * lineHeight))
			else
				notepadLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (firstVisible - 1) * lineHeight))
			end
		end
		box.Text = sliceText(chunks, page, visibleEndLine)
		loadingText = false
		updCount()
	end

	const function commitPage()
		if loadingText then
			return
		end
		const oldEnd = visibleEndLine
		chunks = replaceTextRange(chunks, page, oldEnd, box.Text or "")
		visibleEndLine = page + #splitText(box.Text or "") - 1
		updCount()
	end

	const function refreshNotepadViewport()
		if loadingText then
			return
		end
		commitPage()
		loadPage(getNotepadVisibleLine(math.max(#chunks, 1)), true)
	end

	notepadGetVisibleLines = function()
		local _, visibleLines = getNotepadWindowMetrics()
		return math.max(1, visibleLines)
	end
	notepadGetTotalLines = function()
		return math.max(#chunks + 1, notepadGetVisibleLines())
	end
	notepadGetViewLine = function()
		return getNotepadVisibleLine(math.max(#chunks, 1))
	end
	notepadSetViewLine = function(line)
		commitPage()
		const total = math.max(#chunks, 1)
		const lineHeight = getNotepadWindowMetrics()
		const nextLine = math.clamp(tonumber(line) or 1, 1, total)
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(notepadLineScroll, 0, math.max(0, (nextLine - 1) * lineHeight))
		else
			notepadLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (nextLine - 1) * lineHeight))
		end
		loadPage(nextLine, true)
	end

	const function setFullText(source)
		source = tostring(source or "")
		loadingText = true
		chunks = splitText(source)
		page = 1
		visibleEndLine = 1
		notepadLineScroll.CanvasPosition = Vector2.new(0, 0)
		body.CanvasPosition = Vector2.new(0, 0)
		loadingText = false
		loadPage(1)
	end

	const function getFullText()
		commitPage()
		return buildFullText(false)
	end

	const function refreshList()
		for _, child in list:GetChildren() do
			if child ~= listLay then
				child:Destroy()
			end
		end
		for i, n in names() do
			const item = btn(list, n, 1, i)
			item.Name = n
			item.Size = UDim2.new(1, -2, 0, 28)
			item.Text = n
			item.TextSize = 12
			item.TextXAlignment = Enum.TextXAlignment.Left
			item.BackgroundColor3 = (sel and sel:lower() == n:lower()) and col.on or col.bg3
			MouseButtonFix(item, function()
				sel = n
				nameBox.Text = n
				setPickerFromName(n)
				refreshList()
				setStatus("Selected "..n, col.sub)
			end)
		end
		list.CanvasSize = UDim2.new(0, 0, 0, listLay.AbsoluteContentSize.Y + 8)
	end

	listLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		list.CanvasSize = UDim2.new(0, 0, 0, listLay.AbsoluteContentSize.Y + 8)
	end)

	const function loadFile(n)
		if not fsOk then
			setStatus("Filesystem unavailable", col.err)
			return false
		end
		ensure()
		n = safeName(n or nameBox.Text, false)
		const path = filePath(n, false)
		if not isfile(path) then
			setStatus("No such file: "..n, col.err)
			return false
		end
		local ok, raw = pcall(readfile, path)
		if ok then
			sel = n
			nameBox.Text = n
			setPickerFromName(n)
			setFullText(tostring(raw or ""))
			refreshList()
			setStatus("Opened "..n, col.ok)
			return true
		end
		setStatus("Open failed: "..n, col.err)
		return false
	end

	const function saveFile(n)
		if not fsOk then
			setStatus("Filesystem unavailable", col.err)
			return false
		end
		if not ensure() then
			setStatus("Failed to create "..dir, col.err)
			return false
		end
		n = safeName(n or nameBox.Text, true)
		const path = filePath(n, false)
		local ok, err = pcall(writefile, path, getFullText())
		if ok and (type(isfile) ~= "function" or isfile(path)) then
			sel = n
			nameBox.Text = n
			setPickerFromName(n)
			addIdx(n)
			refreshList()
			setStatus("Saved "..n, col.ok)
			return true
		end
		setStatus("Save failed: "..tostring(err or n), col.err)
		return false
	end

	const function delFile(n)
		if not fsOk then
			setStatus("Filesystem unavailable", col.err)
			return false
		end
		if not delOk then
			setStatus("Delete unavailable", col.err)
			return false
		end
		ensure()
		n = safeName(n or nameBox.Text, false)
		const path = filePath(n, false)
		if not isfile(path) then
			remIdx(n)
			refreshList()
			setStatus("No such file: "..n, col.err)
			return false
		end
		const ok = pcall(delfile, path)
		if ok then
			remIdx(n)
			if sel and sel:lower() == n:lower() then
				sel = nil
			end
			refreshList()
			setStatus("Deleted "..n, col.warn)
			return true
		end
		setStatus("Delete failed: "..n, col.err)
		return false
	end

	MouseButtonFix(newBtn, function()
		sel = nil
		setPicker(".txt", true)
		nameBox.Text = "note.txt"
		setFullText("")
		refreshList()
		setStatus("New note", col.ok)
	end)

	MouseButtonFix(openBtn, function()
		loadFile(sel or nameBox.Text)
	end)

	MouseButtonFix(saveBtn, function()
		saveFile(nameBox.Text)
	end)

	MouseButtonFix(clearBtn, function()
		setFullText("")
		setStatus("Cleared notepad", col.warn)
	end)

	MouseButtonFix(delBtn, function()
		delFile(sel or nameBox.Text)
	end)

	MouseButtonFix(refBtn, function()
		refreshList()
		setStatus("Refreshed", col.ok)
	end)

	MouseButtonFix(optBtn, function()
		if not optBtn.Visible then
			return
		end
		const nextState = not optionsDrop.Visible
		if nextState then
			posOptionsDrop()
			extDrop.Visible = false
		end
		optionsDrop.Visible = nextState
	end)

	MouseButtonFix(fontMinus, function()
		NAStuff.NotepadSettings.fontSize = math.clamp((tonumber(NAStuff.NotepadSettings.fontSize) or 15) - 1, 11, 24)
		applyNotepadOptions()
		refreshNotepadViewport()
		setStatus("Font size "..tostring(NAStuff.NotepadSettings.fontSize), col.sub)
	end)

	MouseButtonFix(fontPlus, function()
		NAStuff.NotepadSettings.fontSize = math.clamp((tonumber(NAStuff.NotepadSettings.fontSize) or 15) + 1, 11, 24)
		applyNotepadOptions()
		refreshNotepadViewport()
		setStatus("Font size "..tostring(NAStuff.NotepadSettings.fontSize), col.sub)
	end)

	MouseButtonFix(wrapBtn, function()
		NAStuff.NotepadSettings.wrap = not NAStuff.NotepadSettings.wrap
		applyNotepadOptions()
		refreshNotepadViewport()
		setStatus("Wrap "..(NAStuff.NotepadSettings.wrap and "enabled" or "disabled"), col.sub)
	end)

	MouseButtonFix(copyBtn, function()
		const ok = type(setclipboard) == "function" and pcall(setclipboard, getFullText())
		setStatus(ok and "Copied notepad text" or "Clipboard unavailable", ok and col.ok or col.err)
	end)

	MouseButtonFix(pasteBtn, function()
		if type(getclipboard) ~= "function" then
			setStatus("Clipboard unavailable", col.err)
			return
		end
		local ok, clip = pcall(getclipboard)
		if not ok or type(clip) ~= "string" then
			setStatus("Clipboard unavailable", col.err)
			return
		end
		const pos = tonumber(box.CursorPosition) or -1
		const tx = tostring(box.Text or "")
		if pos and pos > 0 then
			box.Text = tx:sub(1, pos - 1)..clip..tx:sub(pos)
			box.CursorPosition = pos + #clip
		else
			box.Text = tx..clip
		end
		commitPage()
		setStatus("Pasted clipboard", col.ok)
	end)

	box:GetPropertyChangedSignal("Text"):Connect(function()
		if not loadingText then
			commitPage()
		else
			updCount()
		end
	end)
	notepadLineScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if loadingText then
			return
		end
		const total = math.max(#chunks, 1)
		local _, _, firstVisible, lastVisible = getNotepadWindowRange(total)
		const edgeBuffer = math.max(1, math.floor(notepadLineBuffer / 3))
		if firstVisible < page or lastVisible > visibleEndLine or (firstVisible - page) < edgeBuffer or (visibleEndLine - lastVisible) < edgeBuffer then
			commitPage()
			loadPage(firstVisible, true)
		end
	end)
	local redirectingNotepadScroll = false
	body:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if loadingText or redirectingNotepadScroll then
			return
		end
		const bodyPos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(body) or body.CanvasPosition
		const y = tonumber(bodyPos.Y) or 0
		if math.abs(y) <= 0.5 then
			return
		end
		redirectingNotepadScroll = true
		if notepadVerticalScroll and notepadVerticalScroll.scrollBy then
			local lineDelta = y / math.max(notepadLineHeight, 1)
			if math.abs(lineDelta) < 1 then
				lineDelta = y > 0 and 1 or -1
			end
			notepadVerticalScroll.scrollBy(lineDelta)
		else
			if NAmanage.GetLogicalCanvasPosition and NAmanage.SetLogicalCanvasPosition then
				const notepadLinePos = NAmanage.GetLogicalCanvasPosition(notepadLineScroll)
				NAmanage.SetLogicalCanvasPosition(notepadLineScroll, 0, math.max(0, notepadLinePos.Y + y))
			else
				notepadLineScroll.CanvasPosition = Vector2.new(0, math.max(0, notepadLineScroll.CanvasPosition.Y + y))
			end
		end
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(body, bodyPos.X, 0)
		else
			body.CanvasPosition = Vector2.new(body.CanvasPosition.X, 0)
		end
		redirectingNotepadScroll = false
	end)
	const function handleNotepadWheel(input)
		if not input or input.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end
		const wheel = input.Position and input.Position.Z or 0
		if wheel == 0 then
			return
		end
		const step = math.max(24, getNotepadLineHeight() * 3)
		const horizontal = Services.UserInputService and (Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightShift))
		if horizontal and notepadHorizontalScroll and notepadHorizontalScroll.scrollBy then
			notepadHorizontalScroll.scrollBy(-wheel * step)
		elseif notepadVerticalScroll and notepadVerticalScroll.scrollBy then
			notepadVerticalScroll.scrollBy(-wheel * 3)
		end
	end
	body.InputChanged:Connect(handleNotepadWheel)
	box.InputChanged:Connect(handleNotepadWheel)
	body:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshNotepadViewport)
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateNotepadLayout()
		refreshNotepadViewport()
	end)
	cont:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateNotepadLayout()
		refreshNotepadViewport()
	end)
	NAStuff.NotepadRefresh = function()
		updateNotepadLayout()
		refreshNotepadViewport()
	end
	MouseButtonFix(pagePrev, function()

		commitPage()
		local _, visibleLines = getNotepadWindowMetrics()
		const nextLine = math.clamp(getNotepadVisibleLine(math.max(#chunks, 1)) - visibleLines, 1, math.max(#chunks, 1))
		loadPage(nextLine)
		setStatus("Line "..tostring(nextLine).."/"..tostring(math.max(#chunks, 1)), col.sub)
	end)
	MouseButtonFix(pageNext, function()
		commitPage()
		local _, visibleLines = getNotepadWindowMetrics()
		const nextLine = math.clamp(getNotepadVisibleLine(math.max(#chunks, 1)) + visibleLines, 1, math.max(#chunks, 1))
		loadPage(nextLine)
		setStatus("Line "..tostring(nextLine).."/"..tostring(math.max(#chunks, 1)), col.sub)
	end)
	nameBox.FocusLost:Connect(function()
		const e = tostring(nameBox.Text or ""):match("(%.[%w]+)$")
		if e then
			setPicker(e, true)
		end
	end)

	if Services.UserInputService then
		Services.UserInputService.InputBegan:Connect(function(input, gp)
			const focused = box:IsFocused()
			const ctrl = Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			const shift = Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			if focused and ctrl and input.KeyCode == Enum.KeyCode.B then
				fmt.wrapInline("**", "**", "bold text", "bold")
			elseif focused and ctrl and input.KeyCode == Enum.KeyCode.I then
				fmt.wrapInline("*", "*", "italic text", "italic")
			elseif focused and ctrl and shift and input.KeyCode == Enum.KeyCode.X then
				fmt.wrapInline("~~", "~~", "strikethrough text", "strikethrough")
			elseif focused and ctrl and input.KeyCode == Enum.KeyCode.K then
				fmt.showLink()
			elseif focused and ctrl and input.KeyCode == Enum.KeyCode.Space then
				fmt.clearFormatting()
			elseif input.KeyCode == Enum.KeyCode.Tab and focused then
				const pos = box.CursorPosition
				if pos and pos > 0 then
					const tx = box.Text or ""
					box.Text = tx:sub(1, pos - 1).."    "..tx:sub(pos)
					box.CursorPosition = pos + 4
				end
			elseif focused and ctrl and input.KeyCode == Enum.KeyCode.S then
				saveFile(nameBox.Text)
			end
		end)
	end

	ensure()
	refreshList()
	applyNotepadResponsive(false)
	updateNotepadLayout()
	updEditorSize()
	updCount()
	NAlib.disconnect("NANotepadResponsive")
	NAlib.connect("NANotepadResponsive", frame:GetPropertyChangedSignal("Size"):Connect(saveNotepadFrameSize))
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect("NANotepadResponsive", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			Defer(function()
				if frame and frame.Parent then
					updateNotepadLayout()
					refreshNotepadViewport()
				end
			end)
		end))
	end
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NANotepadResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Defer(function()
				if frame and frame.Parent then
					updateNotepadLayout()
					refreshNotepadViewport()
				end
			end)
		end))
	end
	if NAUIMANAGER and NAUIMANAGER.AUTOSCALER then
		NAlib.connect("NANotepadResponsive", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(function()
			Defer(function()
				if frame and frame.Parent then
					updateNotepadLayout()
					refreshNotepadViewport()
				end
			end)
		end))
	end
	fmt.syncContext()
	setStatus(fsOk and ("Ready | "..dir.." | formatting uses Markdown") or "Filesystem unavailable", fsOk and col.sub or col.err)
	return true
end


NAmanage.SubplaceViewer = type(NAmanage.SubplaceViewer) == "table" and NAmanage.SubplaceViewer or {}
NAmanage.SubplaceViewer.root = "Nameless-Admin/SubplaceViewer"
NAmanage.SubplaceViewer.favoritesPath = NAmanage.SubplaceViewer.root.."/Favorites.json"
NAmanage.SubplaceViewer.favorites = type(NAmanage.SubplaceViewer.favorites) == "table" and NAmanage.SubplaceViewer.favorites or {}
NAmanage.SubplaceViewer.places = type(NAmanage.SubplaceViewer.places) == "table" and NAmanage.SubplaceViewer.places or {}
NAmanage.SubplaceViewer.placeIconAssets = type(NAmanage.SubplaceViewer.placeIconAssets) == "table" and NAmanage.SubplaceViewer.placeIconAssets or {}
NAmanage.SubplaceViewer.placeIconRequests = type(NAmanage.SubplaceViewer.placeIconRequests) == "table" and NAmanage.SubplaceViewer.placeIconRequests or {}
NAmanage.SubplaceViewer.filter = NAmanage.SubplaceViewer.filter or "all"
NAmanage.SubplaceViewer.sort = NAmanage.SubplaceViewer.sort == "id" and "id" or "name"
NAmanage.SubplaceViewer.loaded = false
NAmanage.SubplaceViewer.loading = false
NAmanage.SubplaceViewer.fetchToken = tonumber(NAmanage.SubplaceViewer.fetchToken) or 0
NAmanage.SubplaceViewer.serverToken = tonumber(NAmanage.SubplaceViewer.serverToken) or 0
NAmanage.SubplaceViewer.serverPage = math.max(math.floor(tonumber(NAmanage.SubplaceViewer.serverPage) or 1), 1)
NAmanage.SubplaceViewer.serverPageSize = math.max(math.floor(tonumber(NAmanage.SubplaceViewer.serverPageSize) or 20), 1)
NAmanage.SubplaceViewer.serverTotalPages = math.max(math.floor(tonumber(NAmanage.SubplaceViewer.serverTotalPages) or 1), 1)
NAmanage.SubplaceViewer.serverApiLoading = false
NAmanage.SubplaceViewer.serverBases = type(NAmanage.SubplaceViewer.serverBases) == "table" and NAmanage.SubplaceViewer.serverBases or {
	"https://games.rotunnel.com";
	"https://games.roproxy.com";
	"https://games.roblox.com";
}
NAmanage.SubplaceViewer.serverWorker = NAmanage.SubplaceViewer.serverWorker or "https://solaraserverhop.ltseverydayyou.workers.dev"
NAmanage.SubplaceViewer.viewMode = NAmanage.SubplaceViewer.viewMode or "places"

NAmanage.SubplaceViewer.teleportGuiToken = tonumber(NAmanage.SubplaceViewer.teleportGuiToken) or 0
NAmanage.SubplaceViewer.teleportGui = nil
NAmanage.SubplaceViewer.teleportHandoffGui = nil

NAmanage.SubplaceViewer_GetPlaceThumbnail = function(placeId, width, height)
	const destinationId = tonumber(placeId) or tonumber(game.PlaceId) or 0
	return "rbxthumb://type=Asset&id="..tostring(destinationId)
		.."&w="..tostring(tonumber(width) or 150)
		.."&h="..tostring(tonumber(height) or 150)
end

NAmanage.SubplaceViewer_GetPlaceIcon = function(placeId, width, height, iconAssetId)
	const state = NAmanage.SubplaceViewer
	const destinationId = tonumber(placeId) or tonumber(game.PlaceId) or 0
	const cached = state.placeIconAssets[destinationId]
	const resolvedIconId = tonumber(iconAssetId) or (type(cached) == "number" and cached or nil)
	if resolvedIconId and resolvedIconId > 0 then
		return "rbxthumb://type=Asset&id="..tostring(resolvedIconId)
			.."&w="..tostring(tonumber(width) or 150)
			.."&h="..tostring(tonumber(height) or 150)
	end
	return NAmanage.SubplaceViewer_GetPlaceThumbnail(destinationId, width, height)
end

NAmanage.TeleportGui_ResolveDestinationIcon = function(gui, placeId)
	if not gui then return false end
	const state = NAmanage.SubplaceViewer
	const destinationId = tonumber(placeId) or tonumber(game.PlaceId) or 0
	const function applyIcon(target, iconAssetId)
		if not target then return false end
		local matchesDestination = false
		local okAlive = pcall(function()
			matchesDestination = target:GetAttribute("NADestinationPlaceId") == destinationId
		end)
		if not okAlive or not matchesDestination then return false end
		const root = target:FindFirstChild("Root")
		const foreground = root and root:FindFirstChild("Foreground")
		const content = foreground and foreground:FindFirstChild("Content")
		const icon = content and content:FindFirstChild("DestinationIcon")
		if icon and icon:IsA("ImageLabel") then
			icon.Image = NAmanage.SubplaceViewer_GetPlaceIcon(destinationId, 420, 420, iconAssetId)
			return true
		end
		return false
	end

	const cached = state.placeIconAssets[destinationId]
	if cached ~= nil then
		return applyIcon(gui, type(cached) == "number" and cached or 0)
	end
	local waiting = state.placeIconRequests[destinationId]
	if type(waiting) ~= "table" then
		waiting = {}
		state.placeIconRequests[destinationId] = waiting
	end
	waiting[#waiting + 1] = gui
	if #waiting > 1 then return true end
	Spawn(function()
		local iconAssetId = 0
		local ok, info = pcall(Services.MarketplaceService.GetProductInfo, Services.MarketplaceService, destinationId, Enum.InfoType.Asset)
		if ok and type(info) == "table" then
			iconAssetId = tonumber(info.IconImageAssetId) or 0
			state.placeIconAssets[destinationId] = iconAssetId > 0 and iconAssetId or false
		end
		const targets = state.placeIconRequests[destinationId] or waiting
		state.placeIconRequests[destinationId] = nil
		for _, target in targets do
			applyIcon(target, iconAssetId)
		end
	end)
	return true
end

NAmanage.SubplaceViewer_GetPlaceName = function(placeId)
	const state = NAmanage.SubplaceViewer
	for _, place in state.places do
		if tonumber(place.PlaceId) == tonumber(placeId) then
			return tostring(place.Name or ("Place "..tostring(placeId)))
		end
	end
	if tonumber(placeId) == tonumber(game.PlaceId) then
		return tostring(game.Name)
	end
	return "Place "..tostring(placeId)
end

NAmanage.SubplaceViewer_ClearTeleportGui = function(gui)
	const state = NAmanage.SubplaceViewer
	state.teleportGuiToken += 1
	const target = gui or state.teleportGui
	if target then
		pcall(function() target:Destroy() end)
	end
	if state.teleportHandoffGui then
		pcall(function() state.teleportHandoffGui:Destroy() end)
		state.teleportHandoffGui = nil
	end
	if state.teleportGui == target or gui == nil then
		state.teleportGui = nil
	end
end

NAmanage.TeleportGui_ApplyStaticState = function(gui)
	if not gui then return false end
	const root = gui:FindFirstChild("Root")
	if not root then return false end
	const backdrop = root:FindFirstChild("Backdrop")
	const innerFrame = root:FindFirstChild("InnerFrame")
	const innerFrameStroke = innerFrame and innerFrame:FindFirstChildOfClass("UIStroke")
	const foreground = root:FindFirstChild("Foreground")
	const topBrand = foreground and foreground:FindFirstChild("TopBrand")
	const content = foreground and foreground:FindFirstChild("Content")
	const logo = topBrand and topBrand:FindFirstChild("Logo", true)
	const fallback = topBrand and topBrand:FindFirstChild("Fallback", true)
	const brand = topBrand and topBrand:FindFirstChild("Brand", true)
	const subBrand = topBrand and topBrand:FindFirstChild("SubBrand", true)
	const rightTag = foreground and foreground:FindFirstChild("RightTag", true)
	const statusPill = content and content:FindFirstChild("StatusPill")
	const statusDot = statusPill and statusPill:FindFirstChild("StatusDot")
	const actionLabel = statusPill and statusPill:FindFirstChild("Action")
	const destination = content and content:FindFirstChild("Destination")
	const destinationIcon = content and content:FindFirstChild("DestinationIcon")
	const contentStroke = content and content:FindFirstChildOfClass("UIStroke")
	const accent = content and content:FindFirstChild("Accent")
	const info = content and content:FindFirstChild("Info")
	const footer = content and content:FindFirstChild("Footer")
	const progressTrack = foreground and foreground:FindFirstChild("ProgressTrack")
	const runner = progressTrack and progressTrack:FindFirstChild("Runner")
	const progressCaption = foreground and foreground:FindFirstChild("ProgressCaption")
	const placeTag = foreground and foreground:FindFirstChild("PlaceTag")
	const topEdge = root:FindFirstChild("TopEdge")
	if backdrop and backdrop:IsA("ImageLabel") then
		backdrop.Position = UDim2.fromScale(0.5, 0.5)
		backdrop.Size = UDim2.fromScale(1.1, 1.1)
		backdrop.ImageTransparency = 0.22
	end
	if innerFrameStroke then innerFrameStroke.Transparency = 0.78 end
	if topBrand and topBrand:IsA("Frame") then
		topBrand.Position = UDim2.new(0, tonumber(topBrand:GetAttribute("FinalX")) or 52, 0, tonumber(topBrand:GetAttribute("FinalY")) or 88)
	end
	if content and content:IsA("Frame") then
		content.Position = UDim2.new(0, tonumber(content:GetAttribute("FinalX")) or 52, 1, tonumber(content:GetAttribute("FinalY")) or -70)
		content.BackgroundTransparency = 0.16
	end
	if contentStroke then contentStroke.Transparency = 0.56 end
	if accent and accent:IsA("Frame") then accent.BackgroundTransparency = 0 end
	if logo and logo:IsA("ImageLabel") then logo.ImageTransparency = 0 end
	if fallback and fallback:IsA("TextLabel") then fallback.TextTransparency = 0 end
	if brand and brand:IsA("TextLabel") then brand.TextTransparency = 0 end
	if subBrand and subBrand:IsA("TextLabel") then subBrand.TextTransparency = 0.18 end
	if rightTag and rightTag:IsA("TextLabel") then rightTag.TextTransparency = 0.32 end
	if statusPill and statusPill:IsA("Frame") then statusPill.BackgroundTransparency = 0.18 end
	if statusDot and statusDot:IsA("Frame") then statusDot.BackgroundTransparency = 0 end
	if actionLabel and actionLabel:IsA("TextLabel") then actionLabel.TextTransparency = 0 end
	if destination and destination:IsA("TextLabel") then destination.TextTransparency = 0 end
	if destinationIcon and destinationIcon:IsA("ImageLabel") then destinationIcon.ImageTransparency = 0.04 end
	if info and info:IsA("TextLabel") then info.TextTransparency = 0.08 end
	if footer and footer:IsA("TextLabel") then footer.TextTransparency = 0.18 end
	if progressTrack and progressTrack:IsA("Frame") then progressTrack.BackgroundTransparency = 0.58 end
	if runner and runner:IsA("Frame") then
		runner.Position = UDim2.new(0.24, 0, 0, 0)
		runner.BackgroundTransparency = 0
	end
	if progressCaption and progressCaption:IsA("TextLabel") then progressCaption.TextTransparency = 0.16 end
	if placeTag and placeTag:IsA("TextLabel") then placeTag.TextTransparency = 0.28 end
	if topEdge and topEdge:IsA("Frame") then topEdge.BackgroundTransparency = 0.18 end
	return true
end

NAmanage.SubplaceViewer_CreateTeleportGui = function(placeId, placeName, action, detail, options)
	options = type(options) == "table" and options or {}
	const prearm = options.prearm == true
	if NAStuff.CustomTeleportGuiEnabled == false or NAStuff.AntiTeleportHooked == true then
		return nil
	end
	const state = NAmanage.SubplaceViewer
	NAmanage.SubplaceViewer_ClearTeleportGui()
	const ui = {}
	const destinationId = tonumber(placeId) or tonumber(game.PlaceId) or 0
	const mobile = IsOnMobile == true
	const sidePad = mobile and 18 or 48
	local guiInsetTop = 0
	if Services.GuiService and Services.GuiService.GetGuiInset then
		local okInset, topLeftInset = pcall(Services.GuiService.GetGuiInset, Services.GuiService)
		if okInset and typeof(topLeftInset) == "Vector2" then
			guiInsetTop = math.max(0, tonumber(topLeftInset.Y) or 0)
		end
	end
	const topPad = math.max(mobile and 78 or 88, guiInsetTop + (mobile and 22 or 28))
	const bottomPad = mobile and 62 or 64
	const destinationThumbnail = NAmanage.SubplaceViewer_GetPlaceThumbnail(destinationId, 420, 420)
	const destinationIconImage = NAmanage.SubplaceViewer_GetPlaceIcon(destinationId, 420, 420)

	ui.gui = Instance.new("ScreenGui")
	ui.gui.Name = "NATeleportGui"
	ui.gui.IgnoreGuiInset = true
	ui.gui.ResetOnSpawn = false
	ui.gui.Enabled = true
	ui.gui.DisplayOrder = 2147483647
	ui.gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	pcall(function()
		ui.gui:SetAttribute("NASubplaceViewerTeleport", true)
		ui.gui:SetAttribute("NACustomTeleportGui", true)
		ui.gui:SetAttribute("NADestinationPlaceId", destinationId)
	end)

	ui.root = Instance.new("Frame")
	ui.root.Name = "Root"
	ui.root.Size = UDim2.fromScale(1, 1)
	ui.root.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.root.BorderSizePixel = 0
	ui.root.ZIndex = 1
	ui.root.ClipsDescendants = true
	ui.root.Parent = ui.gui

	ui.backdrop = Instance.new("ImageLabel")
	ui.backdrop.Name = "Backdrop"
	ui.backdrop.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.backdrop.Position = UDim2.fromScale(0.486, 0.5)
	ui.backdrop.Size = UDim2.fromScale(1.16, 1.16)
	ui.backdrop.BackgroundTransparency = 1
	ui.backdrop.Image = destinationThumbnail
	ui.backdrop.ImageColor3 = Color3.fromRGB(225, 225, 225)
	ui.backdrop.ImageTransparency = 1
	ui.backdrop.ScaleType = Enum.ScaleType.Crop
	ui.backdrop.ZIndex = 2
	ui.backdrop.Parent = ui.root

	ui.wash = Instance.new("Frame")
	ui.wash.Name = "Wash"
	ui.wash.Size = UDim2.fromScale(1, 1)
	ui.wash.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.wash.BackgroundTransparency = 0.34
	ui.wash.BorderSizePixel = 0
	ui.wash.ZIndex = 3
	ui.wash.Parent = ui.root
	ui.washGradient = Instance.new("UIGradient")
	ui.washGradient.Rotation = 90
	ui.washGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.28);
		NumberSequenceKeypoint.new(0.5, 0.58);
		NumberSequenceKeypoint.new(1, 0.2);
	})
	ui.washGradient.Parent = ui.wash

	ui.sideShade = Instance.new("Frame")
	ui.sideShade.Name = "SideShade"
	ui.sideShade.Size = UDim2.fromScale(1, 1)
	ui.sideShade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.sideShade.BackgroundTransparency = 0.22
	ui.sideShade.BorderSizePixel = 0
	ui.sideShade.ZIndex = 4
	ui.sideShade.Parent = ui.root
	ui.sideGradient = Instance.new("UIGradient")
	ui.sideGradient.Rotation = 0
	ui.sideGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.36);
		NumberSequenceKeypoint.new(0.42, 0.5);
		NumberSequenceKeypoint.new(0.74, 0.8);
		NumberSequenceKeypoint.new(1, 0.92);
	})
	ui.sideGradient.Parent = ui.sideShade

	ui.bottomShade = Instance.new("Frame")
	ui.bottomShade.Name = "BottomShade"
	ui.bottomShade.AnchorPoint = Vector2.new(0, 1)
	ui.bottomShade.Position = UDim2.fromScale(0, 1)
	ui.bottomShade.Size = UDim2.fromScale(1, 0.58)
	ui.bottomShade.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.bottomShade.BackgroundTransparency = 0.12
	ui.bottomShade.BorderSizePixel = 0
	ui.bottomShade.ZIndex = 5
	ui.bottomShade.Parent = ui.root
	ui.bottomGradient = Instance.new("UIGradient")
	ui.bottomGradient.Rotation = 90
	ui.bottomGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1);
		NumberSequenceKeypoint.new(0.42, 0.72);
		NumberSequenceKeypoint.new(1, 0.22);
	})
	ui.bottomGradient.Parent = ui.bottomShade

	ui.innerFrame = Instance.new("Frame")
	ui.innerFrame.Name = "InnerFrame"
	ui.innerFrame.Position = UDim2.fromOffset(mobile and 9 or 18, mobile and 9 or 18)
	ui.innerFrame.Size = UDim2.new(1, mobile and -18 or -36, 1, mobile and -18 or -36)
	ui.innerFrame.BackgroundTransparency = 1
	ui.innerFrame.BorderSizePixel = 0
	ui.innerFrame.ZIndex = 7
	ui.innerFrame.Parent = ui.root
	ui.innerFrameStroke = Instance.new("UIStroke")
	ui.innerFrameStroke.Color = Color3.fromRGB(255, 255, 255)
	ui.innerFrameStroke.Transparency = 1
	ui.innerFrameStroke.Thickness = 1
	ui.innerFrameStroke.Parent = ui.innerFrame

	ui.topEdge = Instance.new("Frame")
	ui.topEdge.Name = "TopEdge"
	ui.topEdge.AnchorPoint = Vector2.new(0, 0)
	ui.topEdge.Position = UDim2.new(0, sidePad, 0, mobile and 9 or 18)
	ui.topEdge.Size = UDim2.fromOffset(mobile and 72 or 112, 2)
	ui.topEdge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.topEdge.BackgroundTransparency = 1
	ui.topEdge.BorderSizePixel = 0
	ui.topEdge.ZIndex = 7
	ui.topEdge.Parent = ui.root
	ui.topEdgeGradient = Instance.new("UIGradient")
	ui.topEdgeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0));
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255));
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0));
	})
	ui.topEdgeGradient.Parent = ui.topEdge

	ui.foreground = Instance.new("Frame")
	ui.foreground.Name = "Foreground"
	ui.foreground.Size = UDim2.fromScale(1, 1)
	ui.foreground.BackgroundTransparency = 1
	ui.foreground.ZIndex = 10
	ui.foreground.Parent = ui.root

	ui.topBrand = Instance.new("Frame")
	ui.topBrand.Name = "TopBrand"
	ui.topBrand.Position = UDim2.new(0, sidePad, 0, topPad - 10)
	ui.topBrand.Size = UDim2.fromOffset(mobile and 270 or 370, 46)
	ui.topBrand.BackgroundTransparency = 1
	ui.topBrand.ZIndex = 12
	ui.topBrand:SetAttribute("FinalX", sidePad)
	ui.topBrand:SetAttribute("FinalY", topPad)
	ui.topBrand.Parent = ui.foreground

	ui.logoHolder = Instance.new("Frame")
	ui.logoHolder.Name = "LogoHolder"
	ui.logoHolder.Size = UDim2.fromOffset(42, 42)
	ui.logoHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.logoHolder.BackgroundTransparency = 0.08
	ui.logoHolder.BorderSizePixel = 0
	ui.logoHolder.ZIndex = 13
	ui.logoHolder.Parent = ui.topBrand
	ui.logoCorner = Instance.new("UICorner")
	ui.logoCorner.CornerRadius = UDim.new(0, 6)
	ui.logoCorner.Parent = ui.logoHolder
	ui.logoStroke = Instance.new("UIStroke")
	ui.logoStroke.Color = Color3.fromRGB(255, 255, 255)
	ui.logoStroke.Transparency = 0.38
	ui.logoStroke.Thickness = 1
	ui.logoStroke.Parent = ui.logoHolder
	ui.logoScale = Instance.new("UIScale")
	ui.logoScale.Scale = 1
	ui.logoScale.Parent = ui.logoHolder

	const iconAsset = NAmanage.getNAImageAsset("Icon", "")
	ui.logo = Instance.new("ImageLabel")
	ui.logo.Name = "Logo"
	ui.logo.AnchorPoint = Vector2.new(0.5, 0.5)
	ui.logo.Position = UDim2.fromScale(0.5, 0.5)
	ui.logo.Size = UDim2.new(1, -10, 1, -10)
	ui.logo.BackgroundTransparency = 1
	ui.logo.Image = iconAsset
	ui.logo.ImageTransparency = 1
	ui.logo.Visible = iconAsset ~= ""
	ui.logo.ScaleType = Enum.ScaleType.Fit
	ui.logo.ZIndex = 15
	ui.logo.Parent = ui.logoHolder

	ui.logoFallback = Instance.new("TextLabel")
	ui.logoFallback.Name = "Fallback"
	ui.logoFallback.Size = UDim2.fromScale(1, 1)
	ui.logoFallback.BackgroundTransparency = 1
	ui.logoFallback.Text = "NA"
	ui.logoFallback.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.logoFallback.TextTransparency = 1
	ui.logoFallback.TextSize = 17
	ui.logoFallback.Font = Enum.Font.GothamBold
	ui.logoFallback.Visible = iconAsset == ""
	ui.logoFallback.ZIndex = 14
	ui.logoFallback.Parent = ui.logoHolder

	ui.brand = Instance.new("TextLabel")
	ui.brand.Name = "Brand"
	ui.brand.Position = UDim2.new(0, 56, 0, 1)
	ui.brand.Size = UDim2.new(1, -56, 0, 22)
	ui.brand.BackgroundTransparency = 1
	ui.brand.Text = "NAMELESS / ADMIN"
	ui.brand.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.brand.TextTransparency = 1
	ui.brand.TextSize = mobile and 14 or 15
	ui.brand.Font = Enum.Font.GothamBold
	ui.brand.TextXAlignment = Enum.TextXAlignment.Left
	ui.brand.ZIndex = 14
	ui.brand.Parent = ui.topBrand

	ui.subBrand = Instance.new("TextLabel")
	ui.subBrand.Name = "SubBrand"
	ui.subBrand.Position = UDim2.new(0, 56, 0, 25)
	ui.subBrand.Size = UDim2.new(1, -56, 0, 16)
	ui.subBrand.BackgroundTransparency = 1
	ui.subBrand.Text = "TELEPORT"
	ui.subBrand.TextColor3 = Color3.fromRGB(198, 198, 198)
	ui.subBrand.TextTransparency = 1
	ui.subBrand.TextSize = 8
	ui.subBrand.Font = Enum.Font.GothamMedium
	ui.subBrand.TextXAlignment = Enum.TextXAlignment.Left
	ui.subBrand.ZIndex = 14
	ui.subBrand.Parent = ui.topBrand

	ui.rightTag = Instance.new("TextLabel")
	ui.rightTag.Name = "RightTag"
	ui.rightTag.AnchorPoint = Vector2.new(1, 0)
	ui.rightTag.Position = UDim2.new(1, -sidePad, 0, topPad + 12)
	ui.rightTag.Size = UDim2.fromOffset(220, 14)
	ui.rightTag.BackgroundTransparency = 1
	ui.rightTag.Text = ""
	ui.rightTag.TextColor3 = Color3.fromRGB(205, 205, 205)
	ui.rightTag.TextTransparency = 1
	ui.rightTag.TextSize = 8
	ui.rightTag.Font = Enum.Font.GothamMedium
	ui.rightTag.TextXAlignment = Enum.TextXAlignment.Right
	ui.rightTag.Visible = false
	ui.rightTag.ZIndex = 12
	ui.rightTag.Parent = ui.foreground

	ui.content = Instance.new("Frame")
	ui.content.Name = "Content"
	ui.content.AnchorPoint = Vector2.new(0, 1)
	ui.content.Position = UDim2.new(0, sidePad, 1, -(bottomPad - 12))
	ui.content.Size = UDim2.new(mobile and 1 or 0.62, mobile and -(sidePad * 2) or 0, 0, mobile and 148 or 170)
	ui.content.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
	ui.content.BackgroundTransparency = 1
	ui.content.BorderSizePixel = 0
	ui.content.ZIndex = 12
	ui.content:SetAttribute("FinalX", sidePad)
	ui.content:SetAttribute("FinalY", -bottomPad)
	ui.content.Parent = ui.foreground
	ui.contentSize = Instance.new("UISizeConstraint")
	ui.contentSize.MinSize = Vector2.new(260, mobile and 148 or 170)
	ui.contentSize.MaxSize = Vector2.new(760, mobile and 148 or 170)
	ui.contentSize.Parent = ui.content
	ui.contentCorner = Instance.new("UICorner")
	ui.contentCorner.CornerRadius = UDim.new(0, 6)
	ui.contentCorner.Parent = ui.content
	ui.contentStroke = Instance.new("UIStroke")
	ui.contentStroke.Color = Color3.fromRGB(255, 255, 255)
	ui.contentStroke.Transparency = 1
	ui.contentStroke.Thickness = 1
	ui.contentStroke.Parent = ui.content

	ui.accent = Instance.new("Frame")
	ui.accent.Name = "Accent"
	ui.accent.Position = UDim2.fromOffset(0, mobile and 14 or 18)
	ui.accent.Size = UDim2.new(0, 2, 1, mobile and -28 or -36)
	ui.accent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.accent.BackgroundTransparency = 1
	ui.accent.BorderSizePixel = 0
	ui.accent.ZIndex = 16
	ui.accent.Parent = ui.content

	ui.statusPill = Instance.new("Frame")
	ui.statusPill.Name = "StatusPill"
	ui.statusPill.Position = UDim2.fromOffset(mobile and 14 or 18, mobile and 13 or 17)
	ui.statusPill.Size = UDim2.fromOffset(mobile and 145 or 164, 24)
	ui.statusPill.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.statusPill.BackgroundTransparency = 1
	ui.statusPill.BorderSizePixel = 0
	ui.statusPill.ZIndex = 13
	ui.statusPill.Parent = ui.content
	ui.statusCorner = Instance.new("UICorner")
	ui.statusCorner.CornerRadius = UDim.new(0, 6)
	ui.statusCorner.Parent = ui.statusPill
	ui.statusStroke = Instance.new("UIStroke")
	ui.statusStroke.Color = Color3.fromRGB(255, 255, 255)
	ui.statusStroke.Transparency = 0.44
	ui.statusStroke.Thickness = 1
	ui.statusStroke.Parent = ui.statusPill

	ui.statusDot = Instance.new("Frame")
	ui.statusDot.Name = "StatusDot"
	ui.statusDot.AnchorPoint = Vector2.new(0, 0.5)
	ui.statusDot.Position = UDim2.new(0, 9, 0.5, 0)
	ui.statusDot.Size = UDim2.fromOffset(5, 5)
	ui.statusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.statusDot.BackgroundTransparency = 1
	ui.statusDot.BorderSizePixel = 0
	ui.statusDot.ZIndex = 15
	ui.statusDot.Parent = ui.statusPill
	ui.statusDotCorner = Instance.new("UICorner")
	ui.statusDotCorner.CornerRadius = UDim.new(0, 6)
	ui.statusDotCorner.Parent = ui.statusDot

	ui.actionLabel = Instance.new("TextLabel")
	ui.actionLabel.Name = "Action"
	ui.actionLabel.Position = UDim2.new(0, 23, 0, 0)
	ui.actionLabel.Size = UDim2.new(1, -28, 1, 0)
	ui.actionLabel.BackgroundTransparency = 1
	ui.actionLabel.Text = string.upper(tostring(action or "TELEPORTING"))
	ui.actionLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
	ui.actionLabel.TextTransparency = 1
	ui.actionLabel.TextSize = 9
	ui.actionLabel.Font = Enum.Font.GothamBold
	ui.actionLabel.TextXAlignment = Enum.TextXAlignment.Left
	ui.actionLabel.ZIndex = 15
	ui.actionLabel.Parent = ui.statusPill

	ui.destinationIcon = Instance.new("ImageLabel")
	ui.destinationIcon.Name = "DestinationIcon"
	ui.destinationIcon.AnchorPoint = Vector2.new(1, 0.5)
	ui.destinationIcon.Position = UDim2.new(1, mobile and -14 or -18, 0.5, 0)
	ui.destinationIcon.Size = UDim2.fromOffset(mobile and 82 or 128, mobile and 116 or 134)
	ui.destinationIcon.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ui.destinationIcon.BackgroundTransparency = 0.06
	ui.destinationIcon.BorderSizePixel = 0
	ui.destinationIcon.Image = destinationIconImage
	ui.destinationIcon.ImageColor3 = Color3.fromRGB(220, 220, 220)
	ui.destinationIcon.ImageTransparency = 1
	ui.destinationIcon.ScaleType = Enum.ScaleType.Crop
	ui.destinationIcon.ZIndex = 13
	ui.destinationIcon.Parent = ui.content
	ui.destinationIconCorner = Instance.new("UICorner")
	ui.destinationIconCorner.CornerRadius = UDim.new(0, 6)
	ui.destinationIconCorner.Parent = ui.destinationIcon
	ui.destinationIconStroke = Instance.new("UIStroke")
	ui.destinationIconStroke.Color = Color3.fromRGB(255, 255, 255)
	ui.destinationIconStroke.Transparency = 0.62
	ui.destinationIconStroke.Thickness = 1
	ui.destinationIconStroke.Parent = ui.destinationIcon

	ui.destination = Instance.new("TextLabel")
	ui.destination.Name = "Destination"
	ui.destination.Position = UDim2.new(0, mobile and 14 or 18, 0, mobile and 46 or 52)
	ui.destination.Size = UDim2.new(1, mobile and -116 or -174, 0, mobile and 34 or 42)
	ui.destination.BackgroundTransparency = 1
	ui.destination.Text = tostring(placeName or NAmanage.SubplaceViewer_GetPlaceName(destinationId))
	ui.destination.TextColor3 = Color3.fromRGB(255, 255, 255)
	ui.destination.TextTransparency = 1
	ui.destination.TextSize = mobile and 25 or 34
	ui.destination.Font = Enum.Font.GothamBold
	ui.destination.TextTruncate = Enum.TextTruncate.AtEnd
	ui.destination.TextXAlignment = Enum.TextXAlignment.Left
	ui.destination.ZIndex = 14
	ui.destination.Parent = ui.content

	ui.info = Instance.new("TextLabel")
	ui.info.Name = "Info"
	ui.info.Position = UDim2.new(0, mobile and 15 or 19, 0, mobile and 84 or 98)
	ui.info.Size = UDim2.new(1, mobile and -117 or -176, 0, 18)
	ui.info.BackgroundTransparency = 1
	ui.info.Text = tostring(detail or ("Place ID  "..tostring(destinationId)))
	ui.info.TextColor3 = Color3.fromRGB(205, 205, 205)
	ui.info.TextTransparency = 1
	ui.info.TextSize = mobile and 10 or 11
	ui.info.Font = Enum.Font.Gotham
	ui.info.TextTruncate = Enum.TextTruncate.AtEnd
	ui.info.TextXAlignment = Enum.TextXAlignment.Left
	ui.info.ZIndex = 14
	ui.info.Parent = ui.content

	ui.footer = Instance.new("TextLabel")
	ui.footer.Name = "Footer"
	ui.footer.Position = UDim2.new(0, mobile and 15 or 19, 0, mobile and 111 or 130)
	ui.footer.Size = UDim2.new(1, mobile and -117 or -176, 0, 17)
	ui.footer.BackgroundTransparency = 1
	ui.footer.Text = "Loading..."
	ui.footer.TextColor3 = Color3.fromRGB(170, 170, 170)
	ui.footer.TextTransparency = 1
	ui.footer.TextSize = 9
	ui.footer.Font = Enum.Font.GothamMedium
	ui.footer.TextXAlignment = Enum.TextXAlignment.Left
	ui.footer.ZIndex = 14
	ui.footer.Parent = ui.content

	ui.progressTrack = Instance.new("Frame")
	ui.progressTrack.Name = "ProgressTrack"
	ui.progressTrack.AnchorPoint = Vector2.new(0, 1)
	ui.progressTrack.Position = UDim2.new(0, sidePad, 1, -27)
	ui.progressTrack.Size = UDim2.new(1, -(sidePad * 2), 0, 1)
	ui.progressTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.progressTrack.BackgroundTransparency = 1
	ui.progressTrack.BorderSizePixel = 0
	ui.progressTrack.ClipsDescendants = true
	ui.progressTrack.ZIndex = 13
	ui.progressTrack.Parent = ui.foreground
	ui.runner = Instance.new("Frame")
	ui.runner.Name = "Runner"
	ui.runner.Position = UDim2.new(-0.22, 0, 0, 0)
	ui.runner.Size = UDim2.new(0.22, 0, 1, 0)
	ui.runner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ui.runner.BackgroundTransparency = 0
	ui.runner.BorderSizePixel = 0
	ui.runner.ZIndex = 15
	ui.runner.Parent = ui.progressTrack
	ui.runnerGradient = Instance.new("UIGradient")
	ui.runnerGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 88, 88));
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255));
		ColorSequenceKeypoint.new(1, Color3.fromRGB(88, 88, 88));
	})
	ui.runnerGradient.Parent = ui.runner

	ui.progressCaption = Instance.new("TextLabel")
	ui.progressCaption.Name = "ProgressCaption"
	ui.progressCaption.Position = UDim2.new(0, sidePad, 1, -48)
	ui.progressCaption.Size = UDim2.fromOffset(180, 14)
	ui.progressCaption.BackgroundTransparency = 1
	ui.progressCaption.Text = "LOADING"
	ui.progressCaption.TextColor3 = Color3.fromRGB(195, 195, 195)
	ui.progressCaption.TextTransparency = 1
	ui.progressCaption.TextSize = 7
	ui.progressCaption.Font = Enum.Font.GothamMedium
	ui.progressCaption.TextXAlignment = Enum.TextXAlignment.Left
	ui.progressCaption.ZIndex = 13
	ui.progressCaption.Parent = ui.foreground

	ui.placeTag = Instance.new("TextLabel")
	ui.placeTag.Name = "PlaceTag"
	ui.placeTag.AnchorPoint = Vector2.new(1, 0)
	ui.placeTag.Position = UDim2.new(1, -sidePad, 1, -48)
	ui.placeTag.Size = UDim2.fromOffset(220, 14)
	ui.placeTag.BackgroundTransparency = 1
	ui.placeTag.Text = "DESTINATION  //  "..tostring(destinationId)
	ui.placeTag.TextColor3 = Color3.fromRGB(195, 195, 195)
	ui.placeTag.TextTransparency = 1
	ui.placeTag.TextSize = 7
	ui.placeTag.Font = Enum.Font.GothamMedium
	ui.placeTag.TextXAlignment = Enum.TextXAlignment.Right
	ui.placeTag.ZIndex = 13
	ui.placeTag.Parent = ui.foreground

	if prearm then
		pcall(function() ui.gui:SetAttribute("NAGameTeleportPrearmed", true) end)
		NAmanage.TeleportGui_ApplyStaticState(ui.gui)
		NAmanage.TeleportGui_ResolveDestinationIcon(ui.gui, destinationId)
		state.teleportHandoffGui = ui.gui
		state.teleportGui = nil
		pcall(Services.TeleportService.SetTeleportGui, Services.TeleportService, ui.gui)
		return ui.gui
	end

	const lp = (Services.Players and Services.Players.LocalPlayer) or player
	const playerGui = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui"))
	if playerGui then
		ui.gui.Parent = playerGui
	end

	ui.handoffGui = ui.gui:Clone()
	ui.handoffGui.Name = "NATeleportGui"
	ui.handoffGui.Enabled = true
	NAmanage.TeleportGui_ApplyStaticState(ui.handoffGui)
	NAmanage.TeleportGui_ResolveDestinationIcon(ui.gui, destinationId)
	NAmanage.TeleportGui_ResolveDestinationIcon(ui.handoffGui, destinationId)
	state.teleportHandoffGui = ui.handoffGui
	pcall(Services.TeleportService.SetTeleportGui, Services.TeleportService, ui.handoffGui)
	state.teleportGui = ui.gui
	state.teleportGuiToken += 1
	const token = state.teleportGuiToken

	pcall(function()
		Services.TweenService:Create(ui.backdrop, TweenInfo.new(0.78, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0.5);
			Size = UDim2.fromScale(1.1, 1.1);
			ImageTransparency = 0.22;
		}):Play()
		Services.TweenService:Create(ui.innerFrameStroke, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.78 }):Play()
		Services.TweenService:Create(ui.topBrand, TweenInfo.new(0.48, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, sidePad, 0, topPad) }):Play()
		Services.TweenService:Create(ui.content, TweenInfo.new(0.56, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(0, sidePad, 1, -bottomPad); BackgroundTransparency = 0.16 }):Play()
		Services.TweenService:Create(ui.contentStroke, TweenInfo.new(0.58, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.56 }):Play()
		Services.TweenService:Create(ui.accent, TweenInfo.new(0.46, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
		Services.TweenService:Create(ui.logo, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
		Services.TweenService:Create(ui.logoFallback, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		Services.TweenService:Create(ui.brand, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		Services.TweenService:Create(ui.subBrand, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.18 }):Play()
		Services.TweenService:Create(ui.rightTag, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.32 }):Play()
		Services.TweenService:Create(ui.statusPill, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.18 }):Play()
		Services.TweenService:Create(ui.statusDot, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
		Services.TweenService:Create(ui.actionLabel, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		Services.TweenService:Create(ui.destination, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
		Services.TweenService:Create(ui.destinationIcon, TweenInfo.new(0.52, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.04 }):Play()
		Services.TweenService:Create(ui.info, TweenInfo.new(0.54, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.08 }):Play()
		Services.TweenService:Create(ui.footer, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.18 }):Play()
		Services.TweenService:Create(ui.progressTrack, TweenInfo.new(0.58, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.58 }):Play()
		Services.TweenService:Create(ui.progressCaption, TweenInfo.new(0.62, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.16 }):Play()
		Services.TweenService:Create(ui.placeTag, TweenInfo.new(0.62, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.28 }):Play()
		Services.TweenService:Create(ui.topEdge, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.18 }):Play()
	end)

	Spawn(function()
		local dots = 0
		while state.teleportGui == ui.gui and token == state.teleportGuiToken and ui.gui.Parent do
			dots = (dots % 3) + 1
			ui.footer.Text = "Loading"..string.rep(".", dots)
			Wait(0.34)
		end
	end)
	Spawn(function()
		while state.teleportGui == ui.gui and token == state.teleportGuiToken and ui.gui.Parent do
			ui.runner.Position = UDim2.new(-0.22, 0, 0, 0)
			local okTween, tween = pcall(Services.TweenService.Create, Services.TweenService, ui.runner, TweenInfo.new(1.12, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), { Position = UDim2.new(1, 0, 0, 0) })
			if okTween and tween then
				tween:Play()
				pcall(function() tween.Completed:Wait() end)
			else
				Wait(1.12)
			end
			Wait(0.04)
		end
	end)
	Spawn(function()
		while state.teleportGui == ui.gui and token == state.teleportGuiToken and ui.gui.Parent do
			pcall(function()
				local dim = Services.TweenService:Create(ui.statusDot, TweenInfo.new(0.56, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0.72 })
				dim:Play()
				dim.Completed:Wait()
				local bright = Services.TweenService:Create(ui.statusDot, TweenInfo.new(0.56, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { BackgroundTransparency = 0 })
				bright:Play()
				bright.Completed:Wait()
			end)
		end
	end)
	Spawn(function()
		while state.teleportGui == ui.gui and token == state.teleportGuiToken and ui.gui.Parent do
			pcall(function()
				local drift = Services.TweenService:Create(ui.backdrop, TweenInfo.new(4.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = UDim2.fromScale(0.507, 0.496);
					Size = UDim2.fromScale(1.13, 1.13);
				})
				drift:Play()
				drift.Completed:Wait()
				local driftBack = Services.TweenService:Create(ui.backdrop, TweenInfo.new(4.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Position = UDim2.fromScale(0.5, 0.5);
					Size = UDim2.fromScale(1.1, 1.1);
				})
				driftBack:Play()
				driftBack.Completed:Wait()
			end)
		end
	end)
	Spawn(function()
		while state.teleportGui == ui.gui and token == state.teleportGuiToken and ui.gui.Parent do
			pcall(function()
				local grow = Services.TweenService:Create(ui.logoScale, TweenInfo.new(1.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Scale = 1.025 })
				grow:Play()
				grow.Completed:Wait()
				local shrink = Services.TweenService:Create(ui.logoScale, TweenInfo.new(1.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Scale = 1 })
				shrink:Play()
				shrink.Completed:Wait()
			end)
		end
	end)
	return ui.gui
end

NAmanage.SubplaceViewer_PerformTeleport = function(placeId, placeName, action, serverId, detail)
	const lp = (Services.Players and Services.Players.LocalPlayer) or player
	const meta = {
		placeId = placeId;
		placeName = placeName;
		action = action;
		detail = detail;
	}
	if type(serverId) == "string" and serverId ~= "" then
		return NAmanage.TeleportServiceCall("TeleportToPlaceInstance", { placeId, serverId, lp }, meta)
	end
	return NAmanage.TeleportServiceCall("Teleport", { placeId, lp }, meta)
end

NAmanage.SubplaceViewer_HandleArrivingTeleportGui = function()
	local ok, gui = pcall(Services.TeleportService.GetArrivingTeleportGui, Services.TeleportService)
	if not (ok and gui) then return end
	local tagged = false
	pcall(function()
		tagged = gui:GetAttribute("NASubplaceViewerTeleport") == true or gui:GetAttribute("NACustomTeleportGui") == true
	end)
	if not tagged and gui.Name ~= "NATeleportGui" then return end
	const lp = (Services.Players and Services.Players.LocalPlayer) or player
	const playerGui = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui"))
	if playerGui then
		pcall(function() gui.Parent = playerGui end)
	end
	NAmanage.TeleportGui_ApplyStaticState(gui)
	const root = gui:FindFirstChild("Root")
	const backdrop = root and root:FindFirstChild("Backdrop")
	const wash = root and root:FindFirstChild("Wash")
	const sideShade = root and root:FindFirstChild("SideShade")
	const bottomShade = root and root:FindFirstChild("BottomShade")
	const innerFrame = root and root:FindFirstChild("InnerFrame")
	const innerFrameStroke = innerFrame and innerFrame:FindFirstChildOfClass("UIStroke")
	const topEdge = root and root:FindFirstChild("TopEdge")
	const foreground = root and root:FindFirstChild("Foreground")
	const topBrand = foreground and foreground:FindFirstChild("TopBrand")
	const content = foreground and foreground:FindFirstChild("Content")
	const statusPill = content and content:FindFirstChild("StatusPill")
	const statusDot = statusPill and statusPill:FindFirstChild("StatusDot")
	const actionLabel = statusPill and statusPill:FindFirstChild("Action")
	const footer = content and content:FindFirstChild("Footer")
	const progressTrack = foreground and foreground:FindFirstChild("ProgressTrack")
	const runner = progressTrack and progressTrack:FindFirstChild("Runner")
	const progressCaption = foreground and foreground:FindFirstChild("ProgressCaption")
	if actionLabel and actionLabel:IsA("TextLabel") then
		actionLabel.Text = "READY"
	end
	if footer and footer:IsA("TextLabel") then
		footer.Text = "Done"
		footer.TextColor3 = Color3.fromRGB(235, 235, 235)
	end
	if progressCaption and progressCaption:IsA("TextLabel") then
		progressCaption.Text = "READY"
	end
	if statusPill and statusPill:IsA("Frame") then
		pcall(function()
			Services.TweenService:Create(statusPill, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.18 }):Play()
		end)
	end
	if statusDot and statusDot:IsA("Frame") then
		statusDot.BackgroundTransparency = 0
	end
	if runner and runner:IsA("Frame") then
		pcall(function()
			Services.TweenService:Create(runner, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromScale(0, 0);
				Size = UDim2.fromScale(1, 1);
			}):Play()
		end)
	end
	Spawn(function()
		Wait(0.52)
		if not gui.Parent then return end
		if content and content:IsA("Frame") then
			pcall(function()
				Services.TweenService:Create(content, TweenInfo.new(0.58, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Position = UDim2.new(content.Position.X.Scale, content.Position.X.Offset, content.Position.Y.Scale, content.Position.Y.Offset - 14);
				}):Play()
			end)
		end
		if topBrand and topBrand:IsA("Frame") then
			pcall(function()
				Services.TweenService:Create(topBrand, TweenInfo.new(0.58, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
					Position = UDim2.new(topBrand.Position.X.Scale, topBrand.Position.X.Offset, topBrand.Position.Y.Scale, topBrand.Position.Y.Offset - 8);
				}):Play()
			end)
		end
		if foreground then
			for _, obj in foreground:GetDescendants() do
				if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					pcall(function()
						Services.TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							TextTransparency = 1;
							BackgroundTransparency = 1;
						}):Play()
					end)
				elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					pcall(function()
						Services.TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							ImageTransparency = 1;
							BackgroundTransparency = 1;
						}):Play()
					end)
				elseif obj:IsA("UIStroke") then
					pcall(function()
						Services.TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
					end)
				elseif obj:IsA("Frame") and obj ~= foreground then
					pcall(function()
						Services.TweenService:Create(obj, TweenInfo.new(0.52, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
					end)
				end
			end
		end
		if topEdge and topEdge:IsA("Frame") then
			pcall(function()
				Services.TweenService:Create(topEdge, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
			end)
		end
		if innerFrameStroke then
			pcall(function()
				Services.TweenService:Create(innerFrameStroke, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Transparency = 1 }):Play()
			end)
		end
		Wait(0.24)
		if backdrop and backdrop:IsA("ImageLabel") then
			pcall(function()
				Services.TweenService:Create(backdrop, TweenInfo.new(0.92, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
					ImageTransparency = 1;
					Size = UDim2.fromScale(1.02, 1.02);
				}):Play()
			end)
		end
		for _, shade in { wash, sideShade, bottomShade } do
			if shade and shade:IsA("Frame") then
				pcall(function()
					Services.TweenService:Create(shade, TweenInfo.new(0.92, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), { BackgroundTransparency = 1 }):Play()
				end)
			end
		end
		if root and root:IsA("Frame") then
			pcall(function()
				Services.TweenService:Create(root, TweenInfo.new(1.02, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), { BackgroundTransparency = 1 }):Play()
			end)
		end
		Wait(1.05)
		pcall(function() gui:Destroy() end)
	end)
end

Defer(NAmanage.SubplaceViewer_HandleArrivingTeleportGui)

NAmanage.TeleportGui_Create = function(placeId, placeName, action, detail)
	return NAmanage.SubplaceViewer_CreateTeleportGui(placeId, placeName, action, detail)
end

NAmanage.TeleportGui_Clear = function(gui)
	return NAmanage.SubplaceViewer_ClearTeleportGui(gui)
end

NAmanage.TeleportGui_GetPlaceName = function(placeId)
	return NAmanage.SubplaceViewer_GetPlaceName(placeId)
end

NAmanage.TeleportServiceCall = function(method, args, meta)
	args = type(args) == "table" and args or {}
	meta = type(meta) == "table" and meta or {}
	const expParams = NAmanage.TeleportArgsToExperienceParams(method, args, meta)
	local tp = Services.TeleportService
	if not tp then
		local okTp, resolvedTp = pcall(function()
			return game.TeleportService or game:GetService("TeleportService")
		end)
		if okTp and resolvedTp then
			Services.TeleportService = resolvedTp
			tp = resolvedTp
		end
	end
	if not tp then
		if expParams then
			return NAmanage.ExperienceServiceLaunch(expParams, meta)
		end
		return false, "TeleportService unavailable"
	end
	const fn = tp[method]
	if typeof(fn) ~= "function" then
		if expParams then
			return NAmanage.ExperienceServiceLaunch(expParams, meta)
		end
		return false, "TeleportService."..tostring(method).." unavailable"
	end
	const placeId = meta.placeId or args[1]
	const gui = NAmanage.TeleportGui_Create(
		placeId,
		meta.placeName or NAmanage.TeleportGui_GetPlaceName(placeId),
		meta.action or "TELEPORTING",
		meta.detail
	)
	const fallbackToken = NAmanage.RegisterTeleportFallback(method, args, meta)
	local ok, result = pcall(function()
		return fn(tp, Unpack(args))
	end)
	if not ok then
		NAmanage.TeleportGui_Clear(gui)
		if fallbackToken then
			local fallbackOk, fallbackResult = NAmanage.TryExperienceFallback("TeleportService call error: "..tostring(result), fallbackToken)
			if fallbackOk then
				return true, fallbackResult
			end
			return false, tostring(result).." | ExperienceService fallback: "..tostring(fallbackResult)
		end
	end
	return ok, result
end

NAmanage.GameTeleportGui = type(NAmanage.GameTeleportGui) == "table" and NAmanage.GameTeleportGui or {}

NAmanage.TeleportGui_UpdateDestination = function(gui, placeId, placeName, action, detail)
	if not gui then return false end
	placeId = tonumber(placeId) or tonumber(game.PlaceId) or 0
	local okAlive = pcall(function() return gui.Parent end)
	if not okAlive then return false end
	pcall(function()
		gui.Enabled = true
		gui:SetAttribute("NADestinationPlaceId", placeId)
	end)
	const root = gui:FindFirstChild("Root")
	const backdrop = root and root:FindFirstChild("Backdrop")
	const foreground = root and root:FindFirstChild("Foreground")
	const content = foreground and foreground:FindFirstChild("Content")
	const statusPill = content and content:FindFirstChild("StatusPill")
	const actionLabel = statusPill and statusPill:FindFirstChild("Action")
	const destination = content and content:FindFirstChild("Destination")
	const destinationIcon = content and content:FindFirstChild("DestinationIcon")
	const info = content and content:FindFirstChild("Info")
	const footer = content and content:FindFirstChild("Footer")
	const progressTrack = foreground and foreground:FindFirstChild("ProgressTrack")
	const runner = progressTrack and progressTrack:FindFirstChild("Runner")
	const progressCaption = foreground and foreground:FindFirstChild("ProgressCaption")
	const placeTag = foreground and foreground:FindFirstChild("PlaceTag")
	const destinationThumbnail = NAmanage.SubplaceViewer_GetPlaceThumbnail(placeId, 420, 420)
	const destinationIconImage = NAmanage.SubplaceViewer_GetPlaceIcon(placeId, 420, 420)
	if backdrop and backdrop:IsA("ImageLabel") then
		backdrop.Image = destinationThumbnail
	end
	if destinationIcon and destinationIcon:IsA("ImageLabel") then
		destinationIcon.Image = destinationIconImage
	end
	NAmanage.TeleportGui_ResolveDestinationIcon(gui, placeId)
	if actionLabel and actionLabel:IsA("TextLabel") then
		actionLabel.Text = string.upper(tostring(action or "GAME TELEPORT"))
	end
	if destination and destination:IsA("TextLabel") then
		destination.Text = tostring(placeName or NAmanage.TeleportGui_GetPlaceName(placeId))
	end
	if info and info:IsA("TextLabel") then
		info.Text = tostring(detail or ("Place ID  "..tostring(placeId)))
	end
	if footer and footer:IsA("TextLabel") then
		footer.Text = "Loading..."
	end
	if progressCaption and progressCaption:IsA("TextLabel") then
		progressCaption.Text = "LOADING"
	end
	if placeTag and placeTag:IsA("TextLabel") then
		placeTag.Text = "DESTINATION  //  "..tostring(placeId)
	end
	if runner and runner:IsA("Frame") then
		runner.Position = UDim2.new(-0.22, 0, 0, 0)
		runner.Size = UDim2.new(0.22, 0, 1, 0)
	end
	NAmanage.TeleportGui_ApplyStaticState(gui)
	return true
end

NAmanage.GameTeleportGui_Disarm = function()
	const state = NAmanage.GameTeleportGui
	const gui = state.prearmedGui
	state.prearmedGui = nil
	state.lastGui = nil
	state.lastPlaceId = nil
	state.lastAt = 0
	state.inFlight = false
	const teleportState = NAmanage.SubplaceViewer
	if gui then
		if teleportState and teleportState.teleportHandoffGui == gui then
			teleportState.teleportHandoffGui = nil
		end
		pcall(function() gui:Destroy() end)
	end
	if not (teleportState and teleportState.teleportGui and teleportState.teleportGui.Parent) then
		pcall(Services.TeleportService.SetTeleportGui, Services.TeleportService, nil)
	end
end

NAmanage.GameTeleportGui_Arm = function()
	if NAStuff.CustomTeleportGuiEnabled == false or NAStuff.CustomTeleportGuiGameTeleportsEnabled ~= true or NAStuff.AntiTeleportHooked == true then
		NAmanage.GameTeleportGui_Disarm()
		return false
	end
	if NAStuff.teleportTransition == true then
		return false
	end
	const state = NAmanage.GameTeleportGui
	const teleportState = NAmanage.SubplaceViewer
	if teleportState and teleportState.teleportGui and teleportState.teleportGui.Parent then
		return false
	end
	if state.prearmedGui then
		local okAlive = pcall(function() return state.prearmedGui.Name end)
		if okAlive and teleportState and teleportState.teleportHandoffGui == state.prearmedGui then
			pcall(Services.TeleportService.SetTeleportGui, Services.TeleportService, state.prearmedGui)
			return true
		end
		state.prearmedGui = nil
	end
	const gui = NAmanage.SubplaceViewer_CreateTeleportGui(
		game.PlaceId,
		tostring(game.Name or "Current place"),
		"GAME TELEPORT",
		"Waiting for game teleport",
		{ prearm = true }
	)
	if not gui then
		return false
	end
	state.prearmedGui = gui
	state.lastGui = nil
	state.lastPlaceId = nil
	state.lastAt = 0
	state.inFlight = false
	return true
end

NAmanage.GameTeleportGui_Reset = function()
	const state = NAmanage.GameTeleportGui
	state.prearmedGui = nil
	state.lastPlaceId = nil
	state.lastAt = 0
	state.lastGui = nil
	state.inFlight = false
	if NAStuff.CustomTeleportGuiEnabled ~= false and NAStuff.CustomTeleportGuiGameTeleportsEnabled == true and NAStuff.AntiTeleportHooked ~= true then
		Delay(0.25, function()
			if NAStuff.teleportTransition ~= true then
				pcall(NAmanage.GameTeleportGui_Arm)
			end
		end)
	end
end

NAmanage.GameTeleportGui_OnTeleport = function(tpState, placeId, spawnName)
	if NAStuff.CustomTeleportGuiEnabled == false or NAStuff.CustomTeleportGuiGameTeleportsEnabled ~= true or NAStuff.AntiTeleportHooked == true then
		return nil
	end
	const stateName = (typeof(tpState) == "EnumItem" and tpState.Name) or tostring(tpState or "")
	if stateName ~= "RequestedFromServer" and stateName ~= "Started" and stateName ~= "WaitingForServer" and stateName ~= "InProgress" then
		return nil
	end
	const teleportState = NAmanage.SubplaceViewer
	if teleportState and teleportState.teleportGui and teleportState.teleportGui.Parent then
		return teleportState.teleportGui
	end
	placeId = tonumber(placeId)
	if not placeId or placeId <= 0 then
		return nil
	end
	const state = NAmanage.GameTeleportGui
	local gui = state.prearmedGui
	if not gui then
		pcall(NAmanage.GameTeleportGui_Arm)
		gui = state.prearmedGui
	end
	if not gui then
		return nil
	end
	local detail = "Requested by game"
	spawnName = tostring(spawnName or "")
	if spawnName ~= "" then
		detail = "Requested by game  /  Spawn "..spawnName
	elseif stateName == "RequestedFromServer" then
		detail = "Requested by server"
	end
	NAmanage.TeleportGui_UpdateDestination(
		gui,
		placeId,
		NAmanage.TeleportGui_GetPlaceName(placeId),
		"GAME TELEPORT",
		detail
	)
	if not gui.Parent then
		const lp = (Services.Players and Services.Players.LocalPlayer) or player
		const playerGui = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui"))
		if playerGui then
			pcall(function() gui.Parent = playerGui end)
		end
	end
	if teleportState then
		teleportState.teleportHandoffGui = gui
	end
	state.lastPlaceId = placeId
	state.lastAt = os.clock()
	state.lastGui = gui
	state.inFlight = true
	return gui
end

if NAStuff.CustomTeleportGuiGameTeleportsEnabled == true then
	Delay(1.25, function()
		if NAStuff.teleportTransition ~= true then
			pcall(NAmanage.GameTeleportGui_Arm)
		end
	end)
end

NAmanage.SubplaceViewer_UpdateResponsiveLayout = function()
	const state = NAmanage.SubplaceViewer
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	if not (ui and ui.frame) then
		return false
	end
	const width = math.max(1, ui.frame.AbsoluteSize.X)
	const previousCompact = state.compact == true
	const previousPhone = state.phone == true
	state.compact = IsOnMobile == true or width < 660
	state.phone = width < 500
	return previousCompact ~= state.compact or previousPhone ~= state.phone
end

NAmanage.SubplaceViewer_ApplyResponsive = function(center)
	const state = NAmanage.SubplaceViewer
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	const frame = ui and ui.frame
	if not frame then
		return false
	end
	const ok = NAmanage.ExecutorWindowSizing.Apply(frame, {
		key = "SubplaceViewer";
		baseWidth = 780;
		baseHeight = 530;
		minWidth = 560;
		minHeight = 360;
		mobileMinWidth = 320;
		mobileMinHeight = 280;
		center = center == true;
	})
	if not ok then
		return false
	end
	const changed = NAmanage.SubplaceViewer_UpdateResponsiveLayout()
	if changed and state.loaded and state.viewMode == "places" and state.rendering ~= true then
		Defer(NAmanage.SubplaceViewer_Render)
	end
	return true
end

NAmanage.SubplaceViewer_GetUI = function()
	const state = NAmanage.SubplaceViewer
	const frame = NAUIMANAGER and NAUIMANAGER.SubplaceViewerFrame
	const container = frame and frame:FindFirstChild("Container")
	const topbar = frame and frame:FindFirstChild("Topbar")
	state.ui = {
		frame = frame;
		container = container;
		topbar = topbar;
		title = topbar and topbar:FindFirstChild("Title");
		refresh = topbar and topbar:FindFirstChild("Refresh");
		search = container and container:FindFirstChild("Search");
		filter = container and container:FindFirstChild("Filter");
		sort = container and container:FindFirstChild("Sort");
		current = container and container:FindFirstChild("Current");
		status = container and container:FindFirstChild("Status");
		list = container and container:FindFirstChild("List");
	}
	return state.ui
end

NAmanage.SubplaceViewer_RefreshScroll = function(immediate)
	const state = NAmanage.SubplaceViewer
	if state._scrollRefreshQueued and immediate ~= true then
		return
	end
	const function refresh()
		state._scrollRefreshQueued = false
		const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
		const list = ui and ui.list
		if not (list and list.Parent) then
			return
		end
		const scroll = NAmanage.SubplaceViewerScroll
		if scroll and scroll.install and scroll._installed ~= true then
			pcall(scroll.install)
		end
		if scroll and scroll.setTarget then
			pcall(scroll.setTarget, list)
		end
		pcall(updateCanvasSize, list, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
		if scroll and scroll.refresh then
			pcall(scroll.refresh)
		elseif scroll and scroll.scheduleRefresh then
			pcall(scroll.scheduleRefresh)
		end
	end
	if immediate == true then
		refresh()
		return
	end
	state._scrollRefreshQueued = true
	Defer(refresh)
end

NAmanage.SubplaceViewer_SaveFavorites = function()
	const state = NAmanage.SubplaceViewer
	if not (Services.HttpService and type(writefile) == "function") then return false end
	pcall(function()
		if type(isfolder) == "function" and type(makefolder) == "function" then
			if not isfolder("Nameless-Admin") then makefolder("Nameless-Admin") end
			if not isfolder(state.root) then makefolder(state.root) end
		end
	end)
	local ok, data = pcall(Services.HttpService.JSONEncode, Services.HttpService, state.favorites)
	if ok then return pcall(writefile, state.favoritesPath, data) end
	return false
end

NAmanage.SubplaceViewer_LoadFavorites = function()
	const state = NAmanage.SubplaceViewer
	if not (Services.HttpService and type(isfile) == "function" and type(readfile) == "function") then return end
	local okFile, exists = pcall(isfile, state.favoritesPath)
	if not (okFile and exists) then return end
	local okRead, raw = pcall(readfile, state.favoritesPath)
	if not okRead then return end
	local okDecode, data = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
	if okDecode and type(data) == "table" then state.favorites = data end
end

NAmanage.SubplaceViewer_HttpJson = function(url)
	local ok, body = pcall(_na_boot.httpGet, url, { maxAttempts = 4; timeout = 12 })
	if not ok or type(body) ~= "string" then return nil, body end
	local decodedOk, data = pcall(Services.HttpService.JSONDecode, Services.HttpService, body)
	if not decodedOk then return nil, data end
	return data
end

NAmanage.SubplaceViewer_ApplyPlaceIcon = function(place)
	const state = NAmanage.SubplaceViewer
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	const placeId = tonumber(place and place.PlaceId)
	if not (ui and ui.list and placeId) then return false end
	const row = ui.list:FindFirstChild("Place_"..tostring(placeId))
	const icon = row and row:FindFirstChild("Icon")
	if icon and icon:IsA("ImageLabel") then
		icon.Image = NAmanage.SubplaceViewer_GetPlaceIcon(placeId, 150, 150, place.IconAssetId)
		return true
	end
	return false
end

NAmanage.SubplaceViewer_FetchPlaceIconAssets = function(places, fetchToken)
	const state = NAmanage.SubplaceViewer
	const workerCount = math.min(4, #places)
	if workerCount <= 0 then return end
	Delay(0.05, function()
		if fetchToken ~= state.fetchToken then return end
		local nextIndex = 0
		for _ = 1, workerCount do
			Spawn(function()
				while fetchToken == state.fetchToken do
					nextIndex += 1
					const index = nextIndex
					const place = places[index]
					if not place then break end
					const placeId = tonumber(place.PlaceId)
					if placeId then
						local cached = state.placeIconAssets[placeId]
						if cached == nil then
							local ok, info = pcall(Services.MarketplaceService.GetProductInfo, Services.MarketplaceService, placeId, Enum.InfoType.Asset)
							if ok and type(info) == "table" then
								const iconAssetId = tonumber(info.IconImageAssetId) or 0
								cached = iconAssetId > 0 and iconAssetId or false
								state.placeIconAssets[placeId] = cached
							end
						end
						place.IconAssetId = type(cached) == "number" and cached or 0
						if fetchToken == state.fetchToken then
							NAmanage.SubplaceViewer_ApplyPlaceIcon(place)
						end
					end
				end
			end)
		end
	end)
end

NAmanage.SubplaceViewer_ApplyCachedPlaceIcons = function(places)
	const state = NAmanage.SubplaceViewer
	for _, place in places do
		const cached = state.placeIconAssets[tonumber(place.PlaceId)]
		if type(cached) == "number" then
			place.IconAssetId = cached
		elseif cached == false then
			place.IconAssetId = 0
		end
	end
end

NAmanage.SubplaceViewer_FetchServers = function(placeId, cursor, preferredSource)
	const state = NAmanage.SubplaceViewer
	const pid = tostring(placeId)
	local suffix = "/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100"
	if cursor and cursor ~= "" then suffix ..= "&cursor="..Services.HttpService:UrlEncode(tostring(cursor)) end
	const sources = {
		{ name = "rotunnel", base = state.serverBases[1] or "https://games.rotunnel.com" };
		{ name = "worker", worker = true };
		{ name = "roproxy", base = state.serverBases[2] or "https://games.roproxy.com" };
		{ name = "roblox", base = state.serverBases[3] or "https://games.roblox.com" };
	}
	if preferredSource then
		for index, source in sources do
			if source.name == preferredSource and index > 1 then
				table.remove(sources, index)
				table.insert(sources, 1, source)
				break
			end
		end
	end
	local lastErr
	for _, source in sources do
		local url
		if source.worker then
			url = state.serverWorker.."/servers?placeId="..Services.HttpService:UrlEncode(pid).."&sortOrder=Asc&excludeFullGames=true"
			if cursor and cursor ~= "" then url ..= "&cursor="..Services.HttpService:UrlEncode(tostring(cursor)) end
		else
			url = source.base..suffix
		end
		local data, err = NAmanage.SubplaceViewer_HttpJson(url)
		if type(data) == "table" and type(data.data) == "table" then return data, nil, source.name end
		lastErr = err or lastErr
	end
	return nil, lastErr, nil
end

NAmanage.SubplaceViewer_NormalizeServers = function(data, allowCurrent)
	const servers = {}
	if type(data) ~= "table" or type(data.data) ~= "table" then return servers end
	for _, server in data.data do
		if type(server) == "table" then
			const serverId = tostring(server.id or "")
			const playing = tonumber(server.playing) or 0
			const maximum = tonumber(server.maxPlayers or server.max) or 0
			if serverId ~= "" and maximum > playing and (allowCurrent or serverId ~= tostring(game.JobId)) then
				servers[#servers + 1] = {
					id = serverId;
					playing = playing;
					max = maximum;
					ping = tonumber(server.ping) or 0;
					fps = tonumber(server.fps) or 0;
				}
			end
		end
	end
	return servers
end

NAmanage.SubplaceViewer_CollectServers = function(placeId, token, allowCurrent, onPage)
	const state = NAmanage.SubplaceViewer
	const servers = {}
	const byId = {}
	const seenCursors = {}
	local cursor = nil
	local source = nil
	local page = 0
	repeat
		if token ~= state.serverToken then return nil, "cancelled" end
		page += 1
		if state.ui and state.ui.status then state.ui.status.Text = "Loading public servers... API page "..tostring(page) end
		local data, err, usedSource = NAmanage.SubplaceViewer_FetchServers(placeId, cursor, source)
		if type(data) ~= "table" or type(data.data) ~= "table" then
			if page == 1 then return nil, err or "server request failed" end
			break
		end
		source = usedSource or source
		local pageAdded = {}
		for _, server in NAmanage.SubplaceViewer_NormalizeServers(data, allowCurrent) do
			if server.id and not byId[server.id] then
				servers[#servers + 1] = server
				pageAdded[#pageAdded + 1] = server
				byId[server.id] = server
			end
		end
		local nextCursor = data.nextPageCursor or data.next_cursor
		const hasMore = nextCursor ~= nil and nextCursor ~= ""
		if type(onPage) == "function" then
			pcall(onPage, servers, pageAdded, source, page, hasMore)
		end
		if nextCursor and nextCursor ~= "" then
			if seenCursors[nextCursor] then break end
			seenCursors[nextCursor] = true
			cursor = nextCursor
			Wait()
		else
			cursor = nil
		end
	until not cursor or page >= 100
	return servers, nil, source
end

NAmanage.SubplaceViewer_TeleportServer = function(placeId, server, message)
	if type(server) ~= "table" or not server.id then
		DoNotif("No joinable server was found.", 3, "Subplace Viewer")
		return false
	end
	const latencyText = type(NAStuff.srv) == "table" and type(NAStuff.srv.latencyText) == "function" and NAStuff.srv:latencyText(server) or ((tonumber(server.ping) or 0) > 0 and (tostring(math.floor(tonumber(server.ping))).." ms") or "unknown latency")
	local ok, err = NAmanage.SubplaceViewer_PerformTeleport(
		placeId,
		NAmanage.SubplaceViewer_GetPlaceName(placeId),
		string.upper(tostring(message or "Joining server")),
		server.id,
		Format("%d/%d players  •  %s", server.playing, server.max, latencyText)
	)
	if ok then
		DoNotif((message or "Joining server")..": "..tostring(server.playing).."/"..tostring(server.max).." | "..latencyText, 4, "Subplace Viewer")
	else
		DoNotif("Teleport failed: "..tostring(err), 4, "Subplace Viewer")
	end
	return ok
end

NAmanage.SubplaceViewer_Hop = function(placeId, mode, value)
	const state = NAmanage.SubplaceViewer
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	const labels = {
		advanced = "best-latency server";
		smallest = "small server in the best-latency region";
		fullest = "full server in the best-latency region";
		oldest = "oldest active server";
		newest = "newest active server";
		version = "requested place version";
		oldversion = "oldest active place version";
		region = "requested region";
	}
	if ui and ui.status then ui.status.Text = "Finding the "..tostring(labels[mode] or "server").."..." end
	Spawn(function()
		if type(NAStuff.srv) ~= "table" then
			if ui and ui.status then ui.status.Text = "RoValra server picker is unavailable." end
			return
		end
		local server, err, extra = nil, nil, nil
		if mode == "oldest" or mode == "newest" then
			server, err = NAStuff.srv:pickUptime(placeId, mode)
		elseif mode == "version" then
			server, err = NAStuff.srv:pickVersion(placeId, value)
		elseif mode == "oldversion" then
			server, err, extra = NAStuff.srv:pickOldestVersion(placeId)
		elseif mode == "region" then
			server, err, extra = NAStuff.srv:pickRegion(placeId, value)
		else
			const pickMode = mode == "smallest" and "low" or mode == "fullest" and "high" or "ping"
			server, err = NAStuff.srv:pickLatency(placeId, pickMode)
		end
		if not server then
			if ui and ui.status then ui.status.Text = "No matching joinable public server was found." end
			DoNotif("No matching joinable public server was found: "..tostring(err or "none available"), 4, "Subplace Viewer")
			return
		end
		const latencyText = type(NAStuff.srv.latencyText) == "function" and NAStuff.srv:latencyText(server) or "unknown latency"
		if ui and ui.status then ui.status.Text = "Joining "..latencyText.."..." end
		const names = {
			smallest = "Smallest low-latency server";
			fullest = "Fullest low-latency server";
			oldest = "Oldest active server";
			newest = "Newest active server";
			version = "Version "..tostring(value or server.placeVersion or "?");
			oldversion = "Oldest active version "..tostring(extra or server.placeVersion or "?");
			region = "Region "..tostring((type(extra) == "table" and extra.city) or value or server.region or "?");
		}
		NAmanage.SubplaceViewer_TeleportServer(placeId, server, names[mode] or "Best latency hop")
	end)
end

NAmanage.SubplaceViewer_RenderServerResults = function(place, servers, token, resolving, latencyModelReady)
	const state = NAmanage.SubplaceViewer
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	if token ~= state.serverToken or not (ui and ui.list) then return end
	NAlib.disconnect("NASubplaceViewerServers")
	for _, child in ui.list:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
	end

	local function sortServers()
		const mode = state.serverSort or "latency"
		table.sort(servers, function(a, b)
			if mode == "players" then
				if a.playing ~= b.playing then return a.playing < b.playing end
			elseif mode == "uptime" then
				const au = tonumber(a.uptime) or -1
				const bu = tonumber(b.uptime) or -1
				if au ~= bu then return au > bu end
			elseif mode == "version" then
				const av = tonumber(a.placeVersion) or math.huge
				const bv = tonumber(b.placeVersion) or math.huge
				if av ~= bv then return av < bv end
			else
				const ar = tonumber(a.regionRank) or math.huge
				const br = tonumber(b.regionRank) or math.huge
				if ar ~= br then return ar < br end
				const al = tonumber(a.latency) or tonumber(a.ping) or math.huge
				const bl = tonumber(b.latency) or tonumber(b.ping) or math.huge
				if al ~= bl then return al < bl end
			end
			return tostring(a.id) < tostring(b.id)
		end)
	end
	sortServers()
	const pageSize = math.max(math.floor(tonumber(state.serverPageSize) or 20), 1)
	const totalPages = math.max(math.ceil(#servers / pageSize), 1)
	state.serverTotalPages = totalPages
	state.serverPage = math.clamp(math.floor(tonumber(state.serverPage) or 1), 1, totalPages)
	const pageStart = (state.serverPage - 1) * pageSize + 1
	const pageEnd = math.min(pageStart + pageSize - 1, #servers)
	const pageServers = {}
	for index = pageStart, pageEnd do pageServers[#pageServers + 1] = servers[index] end

	local knownRegions = 0
	for _, server in servers do if server.region or server.regionLabel then knownRegions += 1 end end
	if state.serverApiLoading == true then
		ui.status.Text = Format("Page %d/%d+ | %d servers loaded | Loading more API pages... | %s", state.serverPage, totalPages, #servers, tostring(place.Name))
	elseif resolving then
		ui.status.Text = Format("Page %d/%d | %d joinable | RoValra solving in background... | %s", state.serverPage, totalPages, #servers, tostring(place.Name))
	elseif latencyModelReady then
		ui.status.Text = Format("Page %d/%d | %d joinable | %d region-mapped | %s", state.serverPage, totalPages, #servers, knownRegions, tostring(place.Name))
	else
		ui.status.Text = Format("Page %d/%d | %d joinable | Roblox ping fallback | %s", state.serverPage, totalPages, #servers, tostring(place.Name))
	end

	local controls = Instance.new("Frame", ui.list)
	controls.Name = "ServerControls"
	controls.Size = UDim2.new(1, -4, 0, 110)
	controls.BackgroundTransparency = 1
	local grid = Instance.new("UIGridLayout", controls)
	grid.CellPadding = UDim2.new(0, 5, 0, 5)
	grid.CellSize = UDim2.new(0.25, -4, 0, 33)
	grid.FillDirectionMaxCells = 4
	local function makeControl(name, label, order)
		local b = Instance.new("TextButton", controls)
		b.Name = name
		b.LayoutOrder = order
		b.BackgroundColor3 = Color3.fromRGB(65,60,82)
		b.TextColor3 = Color3.fromRGB(245,245,250)
		b.Text = label
		b.TextSize = 12
		b.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		return b
	end
	local function makeInput(name, placeholder, order)
		local box = Instance.new("TextBox", controls)
		box.Name = name
		box.LayoutOrder = order
		box.BackgroundColor3 = Color3.fromRGB(43,43,52)
		box.TextColor3 = Color3.fromRGB(245,245,250)
		box.PlaceholderColor3 = Color3.fromRGB(160,160,176)
		box.PlaceholderText = placeholder
		box.Text = ""
		box.ClearTextOnFocus = false
		box.TextSize = 12
		box.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
		return box
	end
	local back = makeControl("Back", "Back", 1)
	local sort = makeControl("Sort", "Sort: "..string.upper(string.sub(state.serverSort,1,1))..string.sub(state.serverSort,2), 2)
	local best = makeControl("Best", "Best Latency", 3)
	local smallest = makeControl("Smallest", "Smallest", 4)
	local fullest = makeControl("Fullest", "Fullest", 5)
	local oldest = makeControl("Oldest", "Oldest", 6)
	local newest = makeControl("Newest", "Newest", 7)
	local oldversion = makeControl("OldVersion", "Old Version", 8)
	local regionInput = makeInput("RegionInput", "Region / city", 9)
	local region = makeControl("Region", "Region Hop", 10)
	local versionInput = makeInput("VersionInput", "Place version", 11)
	local version = makeControl("Version", "Version Hop", 12)
	local pager = Instance.new("Frame", ui.list)
	pager.Name = "ServerPager"
	pager.Size = UDim2.new(1, -4, 0, 34)
	pager.BackgroundTransparency = 1
	local pagerGrid = Instance.new("UIGridLayout", pager)
	pagerGrid.CellPadding = UDim2.new(0, 5, 0, 0)
	pagerGrid.CellSize = UDim2.new(0.2, -4, 1, 0)
	pagerGrid.FillDirectionMaxCells = 5
	pagerGrid.SortOrder = Enum.SortOrder.LayoutOrder
	local function makePagerButton(name, text, order, enabled)
		local button = Instance.new("TextButton", pager)
		button.Name = name
		button.LayoutOrder = order
		button.BorderSizePixel = 0
		button.BackgroundColor3 = Color3.fromRGB(48, 42, 68)
		button.BackgroundTransparency = enabled and 0.12 or 0.45
		button.Text = text
		button.TextColor3 = Color3.fromRGB(245, 246, 250)
		button.TextTransparency = enabled and 0 or 0.45
		button.TextSize = 12
		button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		button.Active = enabled
		button.AutoButtonColor = enabled
		Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
		return button
	end
	local firstPage = makePagerButton("First", "First", 1, state.serverPage > 1)
	local prevPage = makePagerButton("Prev", "Prev", 2, state.serverPage > 1)
	local pageInfo = makePagerButton("PageInfo", Format("Page %d/%d%s", state.serverPage, totalPages, state.serverApiLoading and "+" or ""), 3, false)
	local nextPage = makePagerButton("Next", "Next", 4, state.serverPage < totalPages)
	local lastPage = makePagerButton("Last", "Last", 5, state.serverPage < totalPages)
	NAlib.connect("NASubplaceViewerServers", firstPage.Activated:Connect(function() state.serverPage = 1; NAmanage.SubplaceViewer_RenderServerResults(place, servers, token, resolving, latencyModelReady) end))
	NAlib.connect("NASubplaceViewerServers", prevPage.Activated:Connect(function() state.serverPage = math.max(1, state.serverPage - 1); NAmanage.SubplaceViewer_RenderServerResults(place, servers, token, resolving, latencyModelReady) end))
	NAlib.connect("NASubplaceViewerServers", nextPage.Activated:Connect(function() state.serverPage = math.min(totalPages, state.serverPage + 1); NAmanage.SubplaceViewer_RenderServerResults(place, servers, token, resolving, latencyModelReady) end))
	NAlib.connect("NASubplaceViewerServers", lastPage.Activated:Connect(function() state.serverPage = totalPages; NAmanage.SubplaceViewer_RenderServerResults(place, servers, token, resolving, latencyModelReady) end))
	NAlib.connect("NASubplaceViewerServers", back.Activated:Connect(function() NAmanage.SubplaceViewer_Render() end))
	NAlib.connect("NASubplaceViewerServers", best.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "advanced") end))
	NAlib.connect("NASubplaceViewerServers", smallest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "smallest") end))
	NAlib.connect("NASubplaceViewerServers", fullest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "fullest") end))
	NAlib.connect("NASubplaceViewerServers", oldest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "oldest") end))
	NAlib.connect("NASubplaceViewerServers", newest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "newest") end))
	NAlib.connect("NASubplaceViewerServers", oldversion.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "oldversion") end))
	NAlib.connect("NASubplaceViewerServers", region.Activated:Connect(function()
		const query = tostring(regionInput.Text or ""):match("^%s*(.-)%s*$") or ""
		if query == "" then DoNotif("Enter a region or city first.", 3, "Subplace Viewer") return end
		NAmanage.SubplaceViewer_Hop(place.PlaceId, "region", query)
	end))
	NAlib.connect("NASubplaceViewerServers", version.Activated:Connect(function()
		const selectedVersion = tonumber(versionInput.Text)
		if not selectedVersion then DoNotif("Enter a valid place version first.", 3, "Subplace Viewer") return end
		NAmanage.SubplaceViewer_Hop(place.PlaceId, "version", selectedVersion)
	end))
	NAlib.connect("NASubplaceViewerServers", sort.Activated:Connect(function()
		const order = { latency = "players"; players = "uptime"; uptime = "version"; version = "latency" }
		state.serverSort = order[state.serverSort] or "latency"
		state.serverPage = 1
		NAmanage.SubplaceViewer_RenderServerResults(place, servers, token, resolving, latencyModelReady)
	end))

	if #servers == 0 then
		local empty = Instance.new("TextLabel", ui.list)
		empty.Size = UDim2.new(1, -4, 0, 44)
		empty.BackgroundTransparency = 1
		empty.Text = "No other joinable public servers were returned."
		empty.TextColor3 = Color3.fromRGB(205,205,218)
		empty.TextSize = 13
		empty.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		return
	end

	for index, server in pageServers do
		local row = Instance.new("Frame", ui.list)
		row.Name = "Server_"..tostring(index)
		row.Size = UDim2.new(1, -4, 0, 92)
		row.BackgroundColor3 = Color3.fromRGB(48,48,56)
		row.BackgroundTransparency = 0.12
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
		local label = Instance.new("TextLabel", row)
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0,10,0,4)
		label.Size = UDim2.new(1,-116,1,-8)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		const pingText = (tonumber(server.ping) or 0) > 0 and (tostring(math.floor(tonumber(server.ping))).." ms") or "N/A"
		if resolving then
			label.Text = Format("%d/%d players\nRoblox ping: %s | FPS: %.2f\nRoValra: Solving region, uptime, version & latency...", server.playing, server.max, pingText, server.fps)
		else
			const latencyText = type(NAStuff.srv) == "table" and NAStuff.srv:latencyText(server) or "unknown latency"
			const uptimeText = type(NAStuff.srv) == "table" and NAStuff.srv:formatUptime(server.uptime, server.uptimeEstimated == true) or "Unknown"
			const versionText = server.placeVersion and tostring(server.placeVersion) or "Unknown"
			label.Text = Format("%d/%d players\nLatency: %s\nUptime: %s | Version: %s\nRoblox ping: %s | FPS: %.2f", server.playing, server.max, latencyText, uptimeText, versionText, pingText, server.fps)
		end
		label.TextColor3 = Color3.fromRGB(225,225,235)
		label.TextSize = 12
		label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		local join = Instance.new("TextButton", row)
		join.Size = UDim2.new(0,92,0,32)
		join.Position = UDim2.new(1,-102,0.5,-16)
		join.BackgroundColor3 = Color3.fromRGB(70,65,92)
		join.Text = "Join"
		join.TextColor3 = Color3.fromRGB(245,245,250)
		join.TextSize = 13
		join.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		Instance.new("UICorner", join).CornerRadius = UDim.new(0, 6)
		NAlib.connect("NASubplaceViewerServers", join.Activated:Connect(function() NAmanage.SubplaceViewer_TeleportServer(place.PlaceId, server, "Joining server") end))
	end
end

NAmanage.SubplaceViewer_ShowServers = function(place)
	const state = NAmanage.SubplaceViewer
	state.viewMode = "servers"
	state.serverSort = state.serverSort or "latency"
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	if not (ui and ui.list) then return end
	state.serverToken += 1
	const token = state.serverToken
	state.serverPage = 1
	state.serverApiLoading = true
	NAlib.disconnect("NASubplaceViewerCards")
	NAlib.disconnect("NASubplaceViewerServers")
	for _, child in ui.list:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
	end
	ui.status.Text = "Loading public servers for "..tostring(place.Name).."..."
	Spawn(function()
		local servers, err, source = NAmanage.SubplaceViewer_CollectServers(place.PlaceId, token, place.PlaceId ~= game.PlaceId, function(partial, pageAdded, usedSource, apiPage, hasMore)
			if token ~= state.serverToken then return end
			state.serverSource = usedSource or state.serverSource
			state.serverResults = partial
			state.serverPlaceId = tonumber(place.PlaceId)
			state.serverApiLoading = hasMore
			NAmanage.SubplaceViewer_RenderServerResults(place, partial, token, false, false)
		end)
		if token ~= state.serverToken then return end
		if type(servers) ~= "table" then
			state.serverApiLoading = false
			ui.status.Text = "Server request failed: "..tostring(err or "unknown error")
			return
		end
		state.serverApiLoading = false
		state.serverSource = source
		state.serverResults = servers
		state.serverPlaceId = tonumber(place.PlaceId)
		const canEnrich = #servers > 0 and type(NAStuff.srv) == "table" and type(NAStuff.srv.enrichLatencyList) == "function"
		NAmanage.SubplaceViewer_RenderServerResults(place, servers, token, canEnrich, false)
		if not canEnrich then return end
		Spawn(function()
			local enriched, latencyModelReady = NAStuff.srv:enrichLatencyList(place.PlaceId, servers)
			if token ~= state.serverToken then return end
			if type(enriched) == "table" then servers = enriched end
			state.serverResults = servers
			NAmanage.SubplaceViewer_RenderServerResults(place, servers, token, false, latencyModelReady == true)
		end)
	end)
end

NAmanage.ServerList = type(NAmanage.ServerList) == "table" and NAmanage.ServerList or {}
NAmanage.ServerList.layout = NAmanage.ServerList.layout == "grid" and "grid" or "list"
NAmanage.ServerList.sort = table.find({"latency","players","uptime","version","fps"}, NAmanage.ServerList.sort) and NAmanage.ServerList.sort or "latency"
NAmanage.ServerList.hideFull = NAmanage.ServerList.hideFull == true
NAmanage.ServerList.servers = type(NAmanage.ServerList.servers) == "table" and NAmanage.ServerList.servers or {}
NAmanage.ServerList.fetchToken = tonumber(NAmanage.ServerList.fetchToken) or 0
NAmanage.ServerList.page = math.max(math.floor(tonumber(NAmanage.ServerList.page) or 1), 1)
NAmanage.ServerList.pageSize = math.max(math.floor(tonumber(NAmanage.ServerList.pageSize) or 20), 1)
NAmanage.ServerList.totalPages = math.max(math.floor(tonumber(NAmanage.ServerList.totalPages) or 1), 1)
NAmanage.ServerList.loading = false
NAmanage.ServerList.enriching = false
NAmanage.ServerList.apiLoading = false
NAmanage.ServerList.bound = false

NAmanage.ServerList_GetUI = function()
	const state = NAmanage.ServerList
	const frame = NAUIMANAGER and NAUIMANAGER.ServerListFrame
	const topbar = frame and frame:FindFirstChild("Topbar")
	const container = frame and frame:FindFirstChild("Container")
	const controls = container and container:FindFirstChild("Controls")
	state.ui = {
		frame = frame;
		topbar = topbar;
		container = container;
		placeId = topbar and topbar:FindFirstChild("PlaceId");
		current = topbar and topbar:FindFirstChild("Current");
		refresh = topbar and topbar:FindFirstChild("Refresh");
		controls = controls;
		layout = controls and controls:FindFirstChild("Layout");
		sort = controls and controls:FindFirstChild("Sort");
		hideFull = controls and controls:FindFirstChild("HideFull");
		copyPlayers = controls and controls:FindFirstChild("CopyPlayers");
		pager = container and container:FindFirstChild("Pager");
		pageFirst = container and container:FindFirstChild("Pager") and container:FindFirstChild("Pager"):FindFirstChild("First");
		pagePrev = container and container:FindFirstChild("Pager") and container:FindFirstChild("Pager"):FindFirstChild("Prev");
		pageInfo = container and container:FindFirstChild("Pager") and container:FindFirstChild("Pager"):FindFirstChild("PageInfo");
		pageNext = container and container:FindFirstChild("Pager") and container:FindFirstChild("Pager"):FindFirstChild("Next");
		pageLast = container and container:FindFirstChild("Pager") and container:FindFirstChild("Pager"):FindFirstChild("Last");
		status = container and container:FindFirstChild("Status");
		list = container and container:FindFirstChild("List");
		scrollBar = container and container:FindFirstChild("CustomScrollBar");
	}
	return state.ui
end

NAmanage.ServerList_EnsurePager = function()
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	if not (ui and ui.container and ui.list and ui.status) then return nil end
	local pager = ui.container:FindFirstChild("Pager")
	if not pager then
		pager = Instance.new("Frame", ui.container)
		pager.Name = "Pager"
		pager.BackgroundTransparency = 1
		pager.Position = UDim2.new(0, 8, 0, 44)
		pager.Size = UDim2.new(1, -16, 0, 30)
		local grid = Instance.new("UIGridLayout", pager)
		grid.CellPadding = UDim2.new(0, 6, 0, 0)
		grid.CellSize = UDim2.new(0.2, -5, 1, 0)
		grid.FillDirectionMaxCells = 5
		grid.SortOrder = Enum.SortOrder.LayoutOrder
		local function makeButton(name, text, order)
			local button = Instance.new("TextButton", pager)
			button.Name = name
			button.LayoutOrder = order
			button.BorderSizePixel = 0
			button.BackgroundColor3 = Color3.fromRGB(48, 42, 68)
			button.BackgroundTransparency = 0.12
			button.Text = text
			button.TextColor3 = Color3.fromRGB(245, 246, 250)
			button.TextSize = 12
			button.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
			Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)
			return button
		end
		makeButton("First", "First", 1)
		makeButton("Prev", "Prev", 2)
		local info = makeButton("PageInfo", "Page 1/1", 3)
		info.Active = false
		info.AutoButtonColor = false
		makeButton("Next", "Next", 4)
		makeButton("Last", "Last", 5)
	end
	ui.status.Position = UDim2.new(0, 10, 0, 78)
	ui.list.Position = UDim2.new(0, 8, 0, 104)
	ui.list.Size = UDim2.new(1, -32, 1, -112)
	if ui.scrollBar then
		ui.scrollBar.Position = UDim2.new(1, -14, 0, 104)
		ui.scrollBar.Size = UDim2.new(0, 10, 1, -112)
	end
	ui.pager = pager
	ui.pageFirst = pager:FindFirstChild("First")
	ui.pagePrev = pager:FindFirstChild("Prev")
	ui.pageInfo = pager:FindFirstChild("PageInfo")
	ui.pageNext = pager:FindFirstChild("Next")
	ui.pageLast = pager:FindFirstChild("Last")
	return pager
end

NAmanage.ServerList_UpdatePager = function(totalPages)
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	state.totalPages = math.max(math.floor(tonumber(totalPages) or 1), 1)
	state.page = math.clamp(math.floor(tonumber(state.page) or 1), 1, state.totalPages)
	local function enabled(button, value)
		if not button then return end
		button.Active = value
		button.AutoButtonColor = value
		button.TextTransparency = value and 0 or 0.45
		button.BackgroundTransparency = value and 0.12 or 0.45
	end
	if ui.pageInfo then ui.pageInfo.Text = Format("Page %d/%d%s", state.page, state.totalPages, state.apiLoading and "+" or "") end
	enabled(ui.pageFirst, state.page > 1)
	enabled(ui.pagePrev, state.page > 1)
	enabled(ui.pageNext, state.page < state.totalPages)
	enabled(ui.pageLast, state.page < state.totalPages)
end

NAmanage.ServerList_SetPage = function(page)
	const state = NAmanage.ServerList
	state.page = math.clamp(math.floor(tonumber(page) or 1), 1, math.max(tonumber(state.totalPages) or 1, 1))
	const ui = state.ui or NAmanage.ServerList_GetUI()
	if ui and ui.list then ui.list.CanvasPosition = Vector2.new(0, 0) end
	NAmanage.ServerList_Render()
end

NAmanage.ServerList_ApplyResponsive = function(center)
	const ui = NAmanage.ServerList.ui or NAmanage.ServerList_GetUI()
	if not (ui and ui.frame) then return false end
	if NAmanage.ExecutorWindowSizing and type(NAmanage.ExecutorWindowSizing.Apply) == "function" then
		return NAmanage.ExecutorWindowSizing.Apply(ui.frame, {
			key = "ServerList";
			baseWidth = 820;
			baseHeight = 560;
			minWidth = 620;
			minHeight = 420;
			mobileMinWidth = 340;
			mobileMinHeight = 300;
			center = center == true;
		})
	end
	if center and NAmanage.centerFrame then NAmanage.centerFrame(ui.frame) end
	return true
end

NAmanage.ServerList_HttpJson = function(url)
	if type(NAmanage.SubplaceViewer_HttpJson) == "function" then
		return NAmanage.SubplaceViewer_HttpJson(url)
	end
	if type(NAStuff.srv) == "table" and type(NAStuff.srv.get) == "function" and type(NAStuff.srv.j) == "function" then
		const body = NAStuff.srv:get(url)
		const data = NAStuff.srv:j(body)
		if type(data) == "table" then return data end
	end
	return nil, "request failed"
end

NAmanage.ServerList_FetchPage = function(placeId, cursor, preferredSource)
	const pid = tostring(placeId)
	local suffix = "/v1/games/"..pid.."/servers/Public?sortOrder=Asc&limit=100"
	if cursor and cursor ~= "" then suffix ..= "&cursor="..Services.HttpService:UrlEncode(tostring(cursor)) end
	const bases = type(NAStuff.srv) == "table" and type(NAStuff.srv.b) == "table" and NAStuff.srv.b or {
		"https://games.rotunnel.com";
		"https://games.roproxy.com";
		"https://games.roblox.com";
	}
	const sources = {
		{ name = "rotunnel", base = bases[1] or "https://games.rotunnel.com" };
		{ name = "worker", worker = true };
		{ name = "roproxy", base = bases[2] or "https://games.roproxy.com" };
		{ name = "roblox", base = bases[3] or "https://games.roblox.com" };
	}
	if preferredSource then
		for index, source in sources do
			if source.name == preferredSource and index > 1 then
				table.remove(sources, index)
				table.insert(sources, 1, source)
				break
			end
		end
	end
	local lastErr
	for _, source in sources do
		local url
		if source.worker then
			const worker = NAStuff.srvWorker or "https://solaraserverhop.ltseverydayyou.workers.dev"
			url = worker.."/servers?placeId="..Services.HttpService:UrlEncode(pid).."&sortOrder=Asc&excludeFullGames=true"
			if cursor and cursor ~= "" then url ..= "&cursor="..Services.HttpService:UrlEncode(tostring(cursor)) end
		else
			url = source.base..suffix
		end
		local data, err = NAmanage.ServerList_HttpJson(url)
		if type(data) == "table" and type(data.data) == "table" then return data, nil, source.name end
		lastErr = err or lastErr
	end
	return nil, lastErr or "server request failed", nil
end

NAmanage.ServerList_Collect = function(placeId, token, onPage)
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	const pid = tonumber(placeId)
	const out = {}
	const byId = {}
	local cursor = nil
	local source = nil
	local page = 0
	const seenCursors = {}
	repeat
		if token ~= state.fetchToken then return nil, "cancelled" end
		page += 1
		if ui and ui.status then ui.status.Text = "Loading public servers... API page "..tostring(page) end
		local data, err, usedSource = NAmanage.ServerList_FetchPage(pid, cursor, source)
		source = usedSource or source
		if type(data) ~= "table" or type(data.data) ~= "table" then
			if page == 1 then return nil, err or "server request failed" end
			break
		end
		local pageAdded = {}
		for _, raw in data.data do
			if type(raw) == "table" then
				const id = tostring(raw.id or raw.server_id or "")
				if id ~= "" and not byId[id] then
					const server = {
						id = id;
						playing = tonumber(raw.playing) or tonumber(raw.player_count) or 0;
						max = tonumber(raw.maxPlayers) or tonumber(raw.max) or tonumber(raw.max_players) or 0;
						ping = tonumber(raw.ping) or 0;
						fps = tonumber(raw.fps) or 0;
					}
					out[#out + 1] = server
					pageAdded[#pageAdded + 1] = server
					byId[id] = server
				end
			end
		end
		local nextCursor = data.nextPageCursor or data.next_cursor
		const hasMore = nextCursor ~= nil and nextCursor ~= ""
		if type(onPage) == "function" then
			pcall(onPage, out, pageAdded, byId, source, page, hasMore)
		end
		if nextCursor and nextCursor ~= "" then
			if seenCursors[nextCursor] then break end
			seenCursors[nextCursor] = true
			cursor = nextCursor
			Wait()
		else
			cursor = nil
		end
	until not cursor or page >= 100
	return out, nil, byId, source
end

NAmanage.ServerList_EnsureCurrent = function(placeId, servers, byId)
	const pid = tonumber(placeId)
	if pid ~= tonumber(game.PlaceId) or tostring(game.JobId or "") == "" then return nil end
	const currentId = tostring(game.JobId)
	local current = byId and byId[currentId] or nil
	if not current then
		local maxPlayers = 0
		pcall(function() maxPlayers = tonumber(Services.Players.MaxPlayers) or 0 end)
		current = {
			id = currentId;
			playing = Services.Players and #Services.Players:GetPlayers() or 0;
			max = maxPlayers;
			ping = 0;
			fps = 0;
		}
		servers[#servers + 1] = current
		if byId then byId[currentId] = current end
	end
	current.current = true
	pcall(function() current.playing = #Services.Players:GetPlayers() end)
	if (tonumber(current.max) or 0) <= 0 then pcall(function() current.max = tonumber(Services.Players.MaxPlayers) or 0 end) end
	if type(NAStuff.srv) == "table" and type(NAStuff.srv.getCurrentRealPing) == "function" then
		const realPing = NAStuff.srv:getCurrentRealPing()
		if realPing then
			current.latency = realPing
			current.latencyEstimated = false
		end
	end
	if (tonumber(current.fps) or 0) <= 0 and Services.Workspace then
		pcall(function() current.fps = Services.Workspace:GetRealPhysicsFPS() end)
	end
	return current
end

NAmanage.ServerList_Sort = function()
	const state = NAmanage.ServerList
	const current = {}
	const others = {}
	for _, server in state.servers do
		if server.current == true then current[#current + 1] = server else others[#others + 1] = server end
	end
	const mode = state.sort
	table.sort(others, function(a, b)
		if mode == "players" then
			if a.playing ~= b.playing then return a.playing > b.playing end
		elseif mode == "uptime" then
			const av, bv = tonumber(a.uptime) or -1, tonumber(b.uptime) or -1
			if av ~= bv then return av > bv end
		elseif mode == "version" then
			const av, bv = tonumber(a.placeVersion) or math.huge, tonumber(b.placeVersion) or math.huge
			if av ~= bv then return av < bv end
		elseif mode == "fps" then
			const av, bv = tonumber(a.fps) or 0, tonumber(b.fps) or 0
			if av ~= bv then return av > bv end
		else
			const av = tonumber(a.latency) or tonumber(a.ping) or math.huge
			const bv = tonumber(b.latency) or tonumber(b.ping) or math.huge
			if av ~= bv then return av < bv end
		end
		return tostring(a.id) < tostring(b.id)
	end)
	const sorted = {}
	for _, server in current do sorted[#sorted + 1] = server end
	for _, server in others do sorted[#sorted + 1] = server end
	state.servers = sorted
	return sorted
end

NAmanage.ServerList_ApplyLayout = function()
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	if not (ui and ui.list) then return end
	const old = ui.list:FindFirstChild("Layout")
	if old then old:Destroy() end
	if state.layout == "grid" then
		const grid = Instance.new("UIGridLayout", ui.list)
		grid.Name = "Layout"
		grid.SortOrder = Enum.SortOrder.LayoutOrder
		grid.CellPadding = UDim2.fromOffset(8, 8)
		const narrow = ui.frame and ui.frame.AbsoluteSize.X < 620
		grid.CellSize = narrow and UDim2.new(1, -8, 0, 150) or UDim2.new(0.5, -8, 0, 150)
	else
		const layout = Instance.new("UIListLayout", ui.list)
		layout.Name = "Layout"
		layout.Padding = UDim.new(0, 7)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
	end
end

NAmanage.ServerList_Render = function()
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	if not (ui and ui.list) then return end
	NAlib.disconnect("NAServerListRows")
	for _, child in ui.list:GetChildren() do
		if not child:IsA("UIPadding") and child.Name ~= "Layout" then child:Destroy() end
	end
	NAmanage.ServerList_ApplyLayout()
	NAmanage.ServerList_Sort()
	const shown = {}
	for _, server in state.servers do
		const full = (tonumber(server.max) or 0) > 0 and (tonumber(server.playing) or 0) >= (tonumber(server.max) or 0)
		if server.current == true or not (state.hideFull and full) then shown[#shown + 1] = server end
	end
	const pageSize = math.max(math.floor(tonumber(state.pageSize) or 20), 1)
	const totalPages = math.max(math.ceil(#shown / pageSize), 1)
	NAmanage.ServerList_UpdatePager(totalPages)
	const pageStart = (state.page - 1) * pageSize + 1
	const pageEnd = math.min(pageStart + pageSize - 1, #shown)
	const pageShown = {}
	for index = pageStart, pageEnd do pageShown[#pageShown + 1] = shown[index] end
	if #shown == 0 then
		const empty = Instance.new("TextLabel", ui.list)
		empty.Name = "Empty"
		empty.Size = UDim2.new(1, -4, 0, 46)
		empty.BackgroundTransparency = 1
		empty.Text = "No public servers matched the current filters."
		empty.TextColor3 = Color3.fromRGB(205, 205, 218)
		empty.TextSize = 13
		return
	end
	for localIndex, server in pageShown do
		const index = pageStart + localIndex - 1
		const card = Instance.new("Frame", ui.list)
		card.Name = "Server_"..tostring(index)
		card.LayoutOrder = server.current == true and -1000000 or index
		card.Size = state.layout == "grid" and UDim2.new(1, 0, 0, 150) or UDim2.new(1, -4, 0, 98)
		card.BackgroundColor3 = server.current == true and Color3.fromRGB(54, 46, 72) or Color3.fromRGB(42, 43, 52)
		card.BackgroundTransparency = server.current == true and 0.04 or 0.12
		card.BorderSizePixel = 0
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)
		const cardStroke = Instance.new("UIStroke", card)
		cardStroke.Color = server.current == true and Color3.fromRGB(155, 100, 255) or Color3.fromRGB(73, 74, 88)
		cardStroke.Transparency = server.current == true and 0.12 or 0.5
		cardStroke.Thickness = 1
		const label = Instance.new("TextLabel", card)
		label.Name = "Info"
		label.BackgroundTransparency = 1
		label.Position = UDim2.new(0, 10, 0, 6)
		label.Size = state.layout == "grid" and UDim2.new(1, -20, 1, -50) or UDim2.new(1, -126, 1, -12)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.TextWrapped = true
		label.TextColor3 = Color3.fromRGB(230, 231, 239)
		label.TextSize = state.layout == "grid" and 11.5 or 12
		label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		const pingText = (tonumber(server.ping) or 0) > 0 and (tostring(math.floor(tonumber(server.ping))).." ms") or "N/A"
		const head = server.current == true and "CURRENT SERVER" or ("SERVER "..tostring(index))
		if state.enriching == true or server.rovalraResolving == true then
			label.Text = Format("%s  |  %d/%d players\nRoblox ping: %s  |  FPS: %.1f\nRoValra: Solving region, uptime, version & latency...", head, tonumber(server.playing) or 0, tonumber(server.max) or 0, pingText, tonumber(server.fps) or 0)
		else
			const latencyValue = tonumber(server.latency) or tonumber(server.ping) or 0
			const latencyText = latencyValue > 0 and ((server.latencyEstimated == true and "~" or "")..tostring(math.floor(latencyValue)).." ms") or "N/A"
			const uptimeText = type(NAStuff.srv) == "table" and type(NAStuff.srv.formatUptime) == "function" and NAStuff.srv:formatUptime(server.uptime, server.uptimeEstimated == true) or "Unknown"
			const versionText = server.placeVersion and tostring(server.placeVersion) or "Unknown"
			const regionText = tostring(server.regionLabel or server.region or "Unknown")
			label.Text = Format("%s  |  %d/%d players\nLatency: %s  |  Roblox ping: %s  |  FPS: %.1f\nRegion: %s\nUptime: %s  |  Version: %s", head, tonumber(server.playing) or 0, tonumber(server.max) or 0, latencyText, pingText, tonumber(server.fps) or 0, regionText, uptimeText, versionText)
		end
		const join = Instance.new("TextButton", card)
		join.Name = "Join"
		join.Size = state.layout == "grid" and UDim2.new(1, -20, 0, 30) or UDim2.new(0, 96, 0, 34)
		join.Position = state.layout == "grid" and UDim2.new(0, 10, 1, -38) or UDim2.new(1, -106, 0.5, -17)
		join.BackgroundColor3 = server.current == true and Color3.fromRGB(67, 58, 87) or Color3.fromRGB(70, 65, 92)
		join.Text = server.current == true and "Current" or "Join"
		join.TextColor3 = Color3.fromRGB(245, 245, 250)
		join.TextSize = 13
		join.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		join.AutoButtonColor = server.current ~= true
		Instance.new("UICorner", join).CornerRadius = UDim.new(0, 6)
		if server.current ~= true then
			NAlib.connect("NAServerListRows", join.Activated:Connect(function()
				local pid = tonumber(ui.placeId and ui.placeId.Text) or tonumber(game.PlaceId)
				NAmanage.SubplaceViewer_TeleportServer(pid, server, "Joining server")
			end))
		end
	end
	if ui.status then
		if state.apiLoading == true then
			ui.status.Text = Format("Page %d/%d+ | %d on page / %d loaded | Loading more API pages...", state.page, totalPages, #pageShown, #state.servers)
		elseif state.enriching == true then
			ui.status.Text = Format("Page %d/%d | %d on page / %d matched / %d fetched | RoValra solving in background...", state.page, totalPages, #pageShown, #shown, #state.servers)
		else
			local regions = 0
			for _, server in shown do if server.region or server.regionLabel then regions += 1 end end
			ui.status.Text = Format("Page %d/%d | %d on page / %d matched / %d fetched | %d region-mapped", state.page, totalPages, #pageShown, #shown, #state.servers, regions)
		end
	end
end

NAmanage.ServerList_Refresh = function()
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	if not (ui and ui.placeId and ui.list) then return end
	const pid = tonumber(tostring(ui.placeId.Text or ""):match("^%s*(.-)%s*$"))
	if not pid or pid <= 0 then
		if ui.status then ui.status.Text = "Enter a valid PlaceId." end
		return
	end
	state.fetchToken += 1
	const token = state.fetchToken
	state.page = 1
	state.loading = true
	state.apiLoading = true
	state.enriching = false
	if ui.status then ui.status.Text = "Loading public servers..." end
	Spawn(function()
		local servers, err, byId, source = NAmanage.ServerList_Collect(pid, token, function(partial, pageAdded, partialById, usedSource, apiPage, hasMore)
			if token ~= state.fetchToken then return end
			NAmanage.ServerList_EnsureCurrent(pid, partial, partialById)
			state.servers = partial
			state.placeId = pid
			state.source = usedSource or state.source
			state.loading = hasMore
			state.apiLoading = hasMore
			state.enriching = false
			NAmanage.ServerList_Render()
		end)
		if token ~= state.fetchToken then return end
		if type(servers) ~= "table" then
			state.loading = false
			state.apiLoading = false
			state.enriching = false
			if ui.status then ui.status.Text = "Server request failed: "..tostring(err or "unknown error") end
			return
		end
		state.apiLoading = false
		NAmanage.ServerList_EnsureCurrent(pid, servers, byId)
		const canEnrich = #servers > 0 and type(NAStuff.srv) == "table" and type(NAStuff.srv.enrichLatencyList) == "function"
		for _, server in servers do server.rovalraResolving = canEnrich end
		state.servers = servers
		state.placeId = pid
		state.source = source
		state.loading = false
		state.apiLoading = false
		state.enriching = canEnrich
		NAmanage.ServerList_Render()
		if not canEnrich then return end
		Spawn(function()
			local enriched = NAStuff.srv:enrichLatencyList(pid, servers)
			if token ~= state.fetchToken then return end
			if type(enriched) == "table" then servers = enriched end
			NAmanage.ServerList_EnsureCurrent(pid, servers, byId)
			for _, server in servers do server.rovalraResolving = false end
			state.servers = servers
			state.enriching = false
			NAmanage.ServerList_Render()
		end)
	end)
end

NAmanage.ServerList_Init = function()
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	if not (ui and ui.frame) then return false end
	NAmanage.ServerList_EnsurePager()
	if ui.placeId and tostring(ui.placeId.Text or "") == "" then ui.placeId.Text = tostring(game.PlaceId) end
	if ui.layout then ui.layout.Text = "Layout: "..(state.layout == "grid" and "Grid" or "List") end
	if ui.sort then ui.sort.Text = "Sort: "..string.upper(string.sub(state.sort, 1, 1))..string.sub(state.sort, 2) end
	if ui.hideFull then ui.hideFull.Text = "Hide Full: "..(state.hideFull and "ON" or "OFF") end
	NAmanage.ServerList_UpdatePager(state.totalPages)
	if state.bound and state.boundFrame == ui.frame then return true end
	state.bound = true
	state.boundFrame = ui.frame
	NAlib.disconnect("NAServerList")
	if ui.pageFirst then NAlib.connect("NAServerList", ui.pageFirst.Activated:Connect(function() NAmanage.ServerList_SetPage(1) end)) end
	if ui.pagePrev then NAlib.connect("NAServerList", ui.pagePrev.Activated:Connect(function() NAmanage.ServerList_SetPage(state.page - 1) end)) end
	if ui.pageNext then NAlib.connect("NAServerList", ui.pageNext.Activated:Connect(function() NAmanage.ServerList_SetPage(state.page + 1) end)) end
	if ui.pageLast then NAlib.connect("NAServerList", ui.pageLast.Activated:Connect(function() NAmanage.ServerList_SetPage(state.totalPages) end)) end
	if ui.current then
		NAlib.connect("NAServerList", ui.current.Activated:Connect(function()
			ui.placeId.Text = tostring(game.PlaceId)
			NAmanage.ServerList_Refresh()
		end))
	end
	if ui.refresh then NAlib.connect("NAServerList", ui.refresh.Activated:Connect(NAmanage.ServerList_Refresh)) end
	if ui.layout then
		NAlib.connect("NAServerList", ui.layout.Activated:Connect(function()
			state.layout = state.layout == "list" and "grid" or "list"
			ui.layout.Text = "Layout: "..(state.layout == "grid" and "Grid" or "List")
			NAmanage.ServerList_Render()
		end))
	end
	if ui.sort then
		NAlib.connect("NAServerList", ui.sort.Activated:Connect(function()
			const order = { latency = "players"; players = "uptime"; uptime = "version"; version = "fps"; fps = "latency" }
			state.sort = order[state.sort] or "latency"
			state.page = 1
			ui.sort.Text = "Sort: "..string.upper(string.sub(state.sort, 1, 1))..string.sub(state.sort, 2)
			NAmanage.ServerList_Render()
		end))
	end
	if ui.hideFull then
		NAlib.connect("NAServerList", ui.hideFull.Activated:Connect(function()
			state.hideFull = not state.hideFull
			state.page = 1
			ui.hideFull.Text = "Hide Full: "..(state.hideFull and "ON" or "OFF")
			NAmanage.ServerList_Render()
		end))
	end
	if ui.copyPlayers then
		NAlib.connect("NAServerList", ui.copyPlayers.Activated:Connect(function()
			const names = {}
			for _, plr in Services.Players:GetPlayers() do names[#names + 1] = plr.Name end
			const value = Concat(names, "\n")
			if type(setclipboard) == "function" then pcall(setclipboard, value) end
			if ui.status then ui.status.Text = "Copied "..tostring(#names).." current-server player name(s)." end
		end))
	end
	if ui.frame.GetPropertyChangedSignal then
		NAlib.connect("NAServerList", ui.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if state.layout == "grid" then NAmanage.ServerList_ApplyLayout() end
		end))
	end
	return true
end

NAmanage.ServerList_Toggle = function()
	if not NAmanage.ServerList_Init() then return false end
	const state = NAmanage.ServerList
	const ui = state.ui or NAmanage.ServerList_GetUI()
	if not (ui and ui.frame) then return false end
	if ui.frame.Visible then
		ui.frame.Visible = false
		return true
	end
	ui.frame.Visible = true
	NAmanage.ServerList_ApplyResponsive(true)
	if ui.placeId and tostring(ui.placeId.Text or "") == "" then ui.placeId.Text = tostring(game.PlaceId) end
	const pid = tonumber(ui.placeId and ui.placeId.Text) or tonumber(game.PlaceId)
	if #state.servers == 0 or state.placeId ~= pid then NAmanage.ServerList_Refresh() else NAmanage.ServerList_Render() end
	return true
end

Defer(NAmanage.ServerList_Init)

NAmanage.SubplaceViewer_Render = function()
	const state = NAmanage.SubplaceViewer
	state.serverToken += 1
	state.viewMode = "places"
	state.rendering = true
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	if not (ui and ui.list) then
		state.rendering = false
		return
	end
	NAmanage.SubplaceViewer_UpdateResponsiveLayout()
	NAlib.disconnect("NASubplaceViewerCards")
	NAlib.disconnect("NASubplaceViewerServers")
	for _, child in ui.list:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then child:Destroy() end
	end
	local query = Lower(tostring(ui.search and ui.search.Text or ""))
	local entries = {}
	for _, place in state.places do
		const favorite = state.favorites[tostring(place.PlaceId)] == true
		if (state.filter == "all" or favorite) and (query == "" or Lower(place.Name):find(query, 1, true) or tostring(place.PlaceId):find(query, 1, true)) then
			entries[#entries + 1] = place
		end
	end
	table.sort(entries, function(a, b)
		const af = state.favorites[tostring(a.PlaceId)] == true
		const bf = state.favorites[tostring(b.PlaceId)] == true
		if af ~= bf then return af end
		const ac = a.PlaceId == game.PlaceId
		const bc = b.PlaceId == game.PlaceId
		if ac ~= bc then return ac end
		if state.sort == "id" then return a.PlaceId < b.PlaceId end
		return Lower(a.Name) < Lower(b.Name)
	end)
	ui.status.Text = Format("%d/%d subplaces | Universe %s", #entries, #state.places, tostring(game.GameId))
	for index, place in entries do
		const isCurrent = place.PlaceId == game.PlaceId
		const compact = state.compact == true
		const phone = state.phone == true
		const iconSize = compact and (phone and 54 or 60) or 72
		const rowHeight = compact and (phone and 176 or 182) or 126
		local row = Instance.new("Frame", ui.list)
		row.Name = "Place_"..tostring(place.PlaceId)
		row.LayoutOrder = index
		row.Size = UDim2.new(1, -4, 0, rowHeight)
		row.BackgroundColor3 = isCurrent and Color3.fromRGB(58,53,75) or Color3.fromRGB(48,48,56)
		row.BackgroundTransparency = 0.1
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
		local icon = Instance.new("ImageLabel", row)
		icon.Name = "Icon"
		icon.BackgroundColor3 = Color3.fromRGB(35,35,42)
		icon.Position = UDim2.new(0, 8, 0, 8)
		icon.Size = UDim2.new(0, iconSize, 0, iconSize)
		icon.Image = NAmanage.SubplaceViewer_GetPlaceIcon(place.PlaceId, 150, 150, place.IconAssetId)
		Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
		local label = Instance.new("TextLabel", row)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.TextWrapped = true
		label.Text = place.Name.."\nPlaceId: "..tostring(place.PlaceId)..(isCurrent and "\nCurrent Place" or "")
		label.TextColor3 = Color3.fromRGB(230,230,240)
		label.TextSize = phone and 13 or 14
		label.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		local actions = Instance.new("Frame", row)
		actions.Name = "Actions"
		actions.BackgroundTransparency = 1
		if compact then
			label.Position = UDim2.new(0, iconSize + 18, 0, 7)
			label.Size = UDim2.new(1, -(iconSize + 26), 0, iconSize + 2)
			actions.Position = UDim2.new(0, 8, 0, iconSize + 16)
			actions.Size = UDim2.new(1, -16, 0, 100)
		else
			label.Position = UDim2.new(0, 90, 0, 7)
			label.Size = UDim2.new(0.52, -98, 1, -14)
			actions.Position = UDim2.new(0.52, 0, 0, 7)
			actions.Size = UDim2.new(0.48, -8, 1, -14)
		end
		local actionGrid = Instance.new("UIGridLayout", actions)
		actionGrid.CellPadding = UDim2.new(0, compact and 5 or 6, 0, 6)
		actionGrid.CellSize = UDim2.new(0.25, compact and -4 or -5, 0, 30)
		actionGrid.FillDirection = Enum.FillDirection.Horizontal
		actionGrid.FillDirectionMaxCells = 4
		actionGrid.HorizontalAlignment = Enum.HorizontalAlignment.Right
		actionGrid.VerticalAlignment = Enum.VerticalAlignment.Center
		actionGrid.SortOrder = Enum.SortOrder.LayoutOrder
		local function makeAction(name, text, order, color)
			local b = Instance.new("TextButton", actions)
			b.Name = name
			b.LayoutOrder = order
			b.BackgroundColor3 = color or Color3.fromRGB(63,59,82)
			b.BackgroundTransparency = 0.05
			b.Text = text
			b.TextColor3 = Color3.fromRGB(245,245,250)
			b.TextSize = phone and 10 or 11
			b.TextTruncate = Enum.TextTruncate.AtEnd
			b.FontFace = Font.new("rbxasset://fonts/families/Roboto.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			return b
		end
		const isFavorite = state.favorites[tostring(place.PlaceId)] == true
		local favorite = makeAction("Favorite", isFavorite and "<b>star</b>" or "star", 1, isFavorite and Color3.fromRGB(115,88,55) or nil)
		favorite.RichText = true
		favorite.TextSize = phone and 17 or 18
		favorite.FontFace = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		local join = makeAction("Join", isCurrent and "Server Hop" or "Join", 2, isCurrent and Color3.fromRGB(55,126,255) or nil)
		local rejoin
		if isCurrent then rejoin = makeAction("Rejoin", "Rejoin", 3, Color3.fromRGB(55,126,255)) end
		local advanced = makeAction("Advanced", "Best Latency", isCurrent and 4 or 3, Color3.fromRGB(90,94,255))
		local smallest = makeAction("Smallest", "Smallest", isCurrent and 5 or 4, Color3.fromRGB(45,166,125))
		local fullest = makeAction("Fullest", "Fullest", isCurrent and 6 or 5, Color3.fromRGB(150,93,255))
		local oldest = makeAction("Oldest", "Oldest", isCurrent and 7 or 6, Color3.fromRGB(125,94,62))
		local newest = makeAction("Newest", "Newest", isCurrent and 8 or 7, Color3.fromRGB(55,126,180))
		local oldversion = makeAction("OldVersion", "Old Version", isCurrent and 9 or 8, Color3.fromRGB(125,75,110))
		local servers = makeAction("Servers", "Servers", isCurrent and 10 or 9)
		local copy = makeAction("Copy", "Copy ID", isCurrent and 11 or 10)
		NAlib.connect("NASubplaceViewerCards", favorite.Activated:Connect(function()
			const key = tostring(place.PlaceId)
			state.favorites[key] = not state.favorites[key] or nil
			NAmanage.SubplaceViewer_SaveFavorites()
			NAmanage.SubplaceViewer_Render()
		end))
		NAlib.connect("NASubplaceViewerCards", servers.Activated:Connect(function() NAmanage.SubplaceViewer_ShowServers(place) end))
		NAlib.connect("NASubplaceViewerCards", copy.Activated:Connect(function()
			if type(setclipboard) == "function" then setclipboard(tostring(place.PlaceId)) DoNotif("PlaceId copied.", 2, "Subplace Viewer") end
		end))
		NAlib.connect("NASubplaceViewerCards", join.Activated:Connect(function()
			if isCurrent then
				NAmanage.SubplaceViewer_Hop(game.PlaceId, "advanced")
			else
				local ok, err = NAmanage.SubplaceViewer_PerformTeleport(place.PlaceId, place.Name, "JOINING SUBPLACE", nil, "Place ID "..tostring(place.PlaceId))
				if ok then DoNotif("Teleporting to "..tostring(place.Name)..".", 2, "Subplace Viewer") else DoNotif("Teleport failed: "..tostring(err), 4, "Subplace Viewer") end
			end
		end))
		if rejoin then
			NAlib.connect("NASubplaceViewerCards", rejoin.Activated:Connect(function()
				local ok, err = NAmanage.SubplaceViewer_PerformTeleport(game.PlaceId, game.Name, "REJOINING SERVER", game.JobId, "Returning to the current server")
				if ok then DoNotif("Rejoining this server.", 2, "Subplace Viewer") else DoNotif("Teleport failed: "..tostring(err), 4, "Subplace Viewer") end
			end))
		end
		if advanced then
			NAlib.connect("NASubplaceViewerCards", advanced.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "advanced") end))
		end
		if smallest then NAlib.connect("NASubplaceViewerCards", smallest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "smallest") end)) end
		if fullest then NAlib.connect("NASubplaceViewerCards", fullest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "fullest") end)) end
		if oldest then NAlib.connect("NASubplaceViewerCards", oldest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "oldest") end)) end
		if newest then NAlib.connect("NASubplaceViewerCards", newest.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "newest") end)) end
		if oldversion then NAlib.connect("NASubplaceViewerCards", oldversion.Activated:Connect(function() NAmanage.SubplaceViewer_Hop(place.PlaceId, "oldversion") end)) end
	end
	state.rendering = false
	NAmanage.SubplaceViewer_RefreshScroll()
end

NAmanage.SubplaceViewer_Fetch = function(force)
	const state = NAmanage.SubplaceViewer
	const ui = state.ui or NAmanage.SubplaceViewer_GetUI()
	if state.loading then return end
	if state.loaded and not force then NAmanage.SubplaceViewer_Render() return end
	state.loading = true
	state.fetchToken += 1
	const token = state.fetchToken
	if ui and ui.status then ui.status.Text = "Fetching universe subplaces..." end
	Spawn(function()
		local places = {}
		local seen = {}
		local ok, pages = pcall(function() return __lt.cm("AssetService", "GetGamePlacesAsync") end)
		if ok and pages then
			while true do
				for _, info in pages:GetCurrentPage() do
					if info.PlaceId and not seen[info.PlaceId] then
						seen[info.PlaceId] = true
						places[#places + 1] = { Name = tostring(info.Name or ("Place "..info.PlaceId)); PlaceId = info.PlaceId }
					end
				end
				if pages.IsFinished then break end
				local advanced = pcall(function() pages:AdvanceToNextPageAsync() end)
				if not advanced then break end
			end
		end
		if not seen[game.PlaceId] then places[#places + 1] = { Name = game.Name; PlaceId = game.PlaceId } end
		if token ~= state.fetchToken then return end
		NAmanage.SubplaceViewer_ApplyCachedPlaceIcons(places)
		state.places = places
		state.loaded = true
		state.loading = false
		if #places == 0 then
			if ui and ui.status then ui.status.Text = "No subplaces were returned." end
		else
			NAmanage.SubplaceViewer_Render()
			NAmanage.SubplaceViewer_FetchPlaceIconAssets(places, token)
		end
	end)
end

NAmanage.SubplaceViewer_Init = function()
	const state = NAmanage.SubplaceViewer
	const ui = NAmanage.SubplaceViewer_GetUI()
	if state.initialized or not (ui and ui.frame) then return ui ~= nil end
	state.initialized = true
	NAmanage.SubplaceViewer_LoadFavorites()
	if ui.sort then ui.sort.Text = state.sort == "id" and "Sort: ID" or "Sort: Name" end
	NAmanage.SubplaceViewer_ApplyResponsive(false)
	NAmanage.SubplaceViewer_SaveFrameSize = function()
		NAmanage.ExecutorWindowSizing.Save(ui.frame, "NASubplaceViewerSavedSizeX", "NASubplaceViewerSavedSizeY")
	end
	NAlib.disconnect("NASubplaceViewerScrollSync")
	const listLayout = ui.list and ui.list:FindFirstChildOfClass("UIListLayout")
	if listLayout then
		NAlib.connect("NASubplaceViewerScrollSync", listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			NAmanage.SubplaceViewer_RefreshScroll()
		end))
	end
	if ui.list then
		NAlib.connect("NASubplaceViewerScrollSync", ui.list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			NAmanage.SubplaceViewer_RefreshScroll()
		end))
		NAlib.connect("NASubplaceViewerScrollSync", ui.list:GetPropertyChangedSignal("Visible"):Connect(function()
			NAmanage.SubplaceViewer_RefreshScroll()
		end))
	end
	NAlib.connect("NASubplaceViewerScrollSync", ui.frame:GetPropertyChangedSignal("Visible"):Connect(function()
		if ui.frame.Visible then
			NAmanage.SubplaceViewer_RefreshScroll()
		end
	end))
	NAlib.disconnect("NASubplaceViewerResponsive")
	NAlib.connect("NASubplaceViewerResponsive", ui.frame:GetPropertyChangedSignal("Size"):Connect(NAmanage.SubplaceViewer_SaveFrameSize))
	NAlib.connect("NASubplaceViewerResponsive", ui.frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		const changed = NAmanage.SubplaceViewer_UpdateResponsiveLayout()
		if changed and state.loaded and state.viewMode == "places" and state.rendering ~= true then
			Defer(NAmanage.SubplaceViewer_Render)
		end
	end))
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect("NASubplaceViewerResponsive", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			Defer(function()
				if ui.frame and ui.frame.Parent then
					NAmanage.SubplaceViewer_ApplyResponsive(true)
				end
			end)
		end))
	end
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NASubplaceViewerResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Defer(function()
				if ui.frame and ui.frame.Parent then
					NAmanage.SubplaceViewer_ApplyResponsive(true)
				end
			end)
		end))
	end
	if NAUIMANAGER and NAUIMANAGER.AUTOSCALER then
		NAlib.connect("NASubplaceViewerResponsive", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(function()
			Defer(function()
				if ui.frame and ui.frame.Parent then
					NAmanage.SubplaceViewer_ApplyResponsive(true)
				end
			end)
		end))
	end
	NAlib.connect("NASubplaceViewer", ui.refresh.Activated:Connect(function() NAmanage.SubplaceViewer_Fetch(true) end))
	NAlib.connect("NASubplaceViewer", ui.search:GetPropertyChangedSignal("Text"):Connect(function() if state.loaded then NAmanage.SubplaceViewer_Render() end end))
	NAlib.connect("NASubplaceViewer", ui.filter.Activated:Connect(function()
		state.filter = state.filter == "all" and "favorites" or "all"
		ui.filter.Text = state.filter == "all" and "All Places" or "Favorites"
		NAmanage.SubplaceViewer_Render()
	end))
	NAlib.connect("NASubplaceViewer", ui.sort.Activated:Connect(function()
		state.sort = state.sort == "name" and "id" or "name"
		ui.sort.Text = state.sort == "name" and "Sort: Name" or "Sort: ID"
		NAmanage.SubplaceViewer_Render()
	end))
	NAlib.connect("NASubplaceViewer", ui.current.Activated:Connect(function()
		ui.search.Text = tostring(game.PlaceId)
	end))
	NAmanage.SubplaceViewer_RefreshScroll()
	return true
end

NAmanage.SubplaceViewer_Toggle = function(forceState)
	const ui = NAmanage.SubplaceViewer_GetUI()
	if not (ui and ui.frame) then DoNotif("Subplace Viewer UI unavailable.", 3) return false end
	NAmanage.SubplaceViewer_Init()
	local visible = forceState
	if type(visible) ~= "boolean" then visible = not ui.frame.Visible end
	ui.frame.Visible = visible
	if visible then
		if NAmanage.centerFrame then pcall(NAmanage.centerFrame, ui.frame) end
		if NAmanage.OnUIWindowShown then pcall(NAmanage.OnUIWindowShown, ui.frame) end
		NAmanage.SubplaceViewer_Fetch(false)
		NAmanage.SubplaceViewer_RefreshScroll()
	end
	return true
end

NAmanage.Notepad_Toggle = function(forceState)
	if not (NAUIMANAGER and NAUIMANAGER.NotepadFrame) then
		DoNotif("Notepad UI unavailable.", 3)
		return false
	end
	NAmanage.Notepad_Init()
	const frame = NAUIMANAGER.NotepadFrame
	local nextState = forceState
	if type(nextState) ~= "boolean" then
		nextState = not frame.Visible
	end
	if frame.Visible and nextState == false and type(NAmanage.Notepad_SaveFrameSize) == "function" then
		pcall(NAmanage.Notepad_SaveFrameSize)
	end
	frame.Visible = nextState
	if frame.Visible then
		if NAmanage.centerFrame then
			pcall(NAmanage.centerFrame, frame)
		end
		if type(NAStuff.NotepadRefresh) == "function" then
			Defer(NAStuff.NotepadRefresh)
		end
	end
	return true
end

NAmanage.StandardWindowResponsive = type(NAmanage.StandardWindowResponsive) == "table" and NAmanage.StandardWindowResponsive or {}
NAmanage.StandardWindowResponsive.configs = {
	ChatLogs = { frame = "chatLogsFrame"; baseWidth = 600; baseHeight = 400; minWidth = 420; minHeight = 280; mobileMinWidth = 300; mobileMinHeight = 260; };
	Console = { frame = "NAconsoleFrame"; baseWidth = 560; baseHeight = 380; minWidth = 400; minHeight = 270; mobileMinWidth = 280; mobileMinHeight = 220; };
	CommandKeybinds = { frame = "CommandKeybindsFrame"; baseWidth = 640; baseHeight = 470; minWidth = 460; minHeight = 320; mobileMinWidth = 300; mobileMinHeight = 240; };
	Waypoints = { frame = "WaypointFrame"; baseWidth = 640; baseHeight = 430; minWidth = 460; minHeight = 300; mobileMinWidth = 320; mobileMinHeight = 270; };
	Binders = { frame = "BindersFrame"; baseWidth = 560; baseHeight = 390; minWidth = 400; minHeight = 280; mobileMinWidth = 280; mobileMinHeight = 220; };
	Plugins = { frame = "PluginsFrame"; baseWidth = 620; baseHeight = 440; minWidth = 440; minHeight = 300; mobileMinWidth = 300; mobileMinHeight = 240; };
	Music = { frame = "MusicFrame"; baseWidth = 620; baseHeight = 450; minWidth = 420; minHeight = 290; mobileMinWidth = 300; mobileMinHeight = 240; };
}
NAmanage.StandardWindowResponsive.Apply = function(center)
	for key, config in NAmanage.StandardWindowResponsive.configs do
		const frame = NAUIMANAGER and NAUIMANAGER[config.frame]
		if frame and frame.Parent then
			NAmanage.ExecutorWindowSizing.Apply(frame, {
				key = key;
				baseWidth = config.baseWidth;
				baseHeight = config.baseHeight;
				minWidth = config.minWidth;
				minHeight = config.minHeight;
				mobileMinWidth = config.mobileMinWidth;
				mobileMinHeight = config.mobileMinHeight;
				center = true;
			})
		end
	end
end
NAmanage.StandardWindowResponsive.Bind = function()
	NAlib.disconnect("NAStandardWindowsResponsive")
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NAStandardWindowsResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			Defer(function()
				NAmanage.StandardWindowResponsive.Apply(true)
			end)
		end))
	end
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect("NAStandardWindowsResponsive", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			Defer(function()
				NAmanage.StandardWindowResponsive.Apply(true)
			end)
		end))
	end
	if NAUIMANAGER and NAUIMANAGER.AUTOSCALER then
		NAlib.connect("NAStandardWindowsResponsive", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(function()
			Defer(function()
				NAmanage.StandardWindowResponsive.Apply(true)
			end)
		end))
	end
	NAmanage.StandardWindowResponsive.Apply(false)
end

NAStuff.cmdInputAtInit = NAUIMANAGER and NAUIMANAGER.cmdInput
NAStuff.keepCmdFocus = false
if NAStuff.cmdInputAtInit then
	NAStuff.keepCmdFocus = NAStuff.cmdInputAtInit:IsFocused()
	if not NAStuff.keepCmdFocus and Services.UserInputService.GetFocusedTextBox then
		NAStuff.keepCmdFocus = __lt.cm("UserInputService", "GetFocusedTextBox") == NAStuff.cmdInputAtInit
	end
end
if not NAStuff.keepCmdFocus then
	NAgui.barDeselect(0)
else
	NAStuff.cmdBarSelected = true
	NAmanage.setCmdAutofillClickable(true)
end
NAUIMANAGER.cmdBar.Visible=true

function NAStartupUI(label, _, callback)
	if NAmanage.spawnStartupLoader then
		return NAmanage.spawnStartupLoader(label, callback)
	end
	return Spawn(function()
		local ok, err = pcall(callback)
		if not ok then warn(err) end
	end)
end

NAStartupUI("Responsive:StandardWindows", 0, function()
	if NAmanage.StandardWindowResponsive and NAmanage.StandardWindowResponsive.Bind then
		NAmanage.StandardWindowResponsive.Bind()
	end
end)
NAStartupUI("Menu:ChatLogs", 0, function() if NAUIMANAGER.chatLogsFrame then NAgui.menuv3(NAUIMANAGER.chatLogsFrame) end end)
NAStartupUI("Menu:Console", 0.01, function() if NAUIMANAGER.NAconsoleFrame then NAgui.menuv2(NAUIMANAGER.NAconsoleFrame) end end)
NAStartupUI("Menu:Commands", 0.02, function()
	if NAUIMANAGER.commandsFrame then
		NAgui.menu(NAUIMANAGER.commandsFrame)
		if NAmanage.Commands_SyncHiddenState then
			NAmanage.Commands_SyncHiddenState({ responsive = false; syncRows = false })
		end
	end
end)
NAStartupUI("Menu:CommandKeybinds", 0.03, function() if NAUIMANAGER.CommandKeybindsFrame then NAgui.menu(NAUIMANAGER.CommandKeybindsFrame) end end)
NAStartupUI("Menu:Settings", 0.04, function() if NAUIMANAGER.SettingsFrame then NAgui.menu(NAUIMANAGER.SettingsFrame) end end)
NAStartupUI("Menu:Waypoints", 0.05, function() if NAUIMANAGER.WaypointFrame then NAgui.menu(NAUIMANAGER.WaypointFrame) end end)
NAStartupUI("Menu:Binders", 0.06, function() if NAUIMANAGER.BindersFrame then NAgui.menu(NAUIMANAGER.BindersFrame) end end)
NAStartupUI("Menu:PluginsBind", 0.07, function() if NAmanage.PluginsWindow_Bind then NAmanage.PluginsWindow_Bind() end end)
NAStartupUI("Menu:Music", 0.25, function()
	if NAUIMANAGER.MusicFrame then
		if NAmanage.MusicWindowInit then NAmanage.MusicWindowInit() end
		NAgui.menu(NAUIMANAGER.MusicFrame)
	end
end)
NAStartupUI("Menu:Executor", 0.08, function() if NAUIMANAGER.ExecutorFrame then NAgui.menu(NAUIMANAGER.ExecutorFrame) end end)
NAStartupUI("Menu:Notepad", 0.09, function() if NAUIMANAGER.NotepadFrame then NAgui.menu(NAUIMANAGER.NotepadFrame) end end)
NAStartupUI("Menu:ScriptHub", 0.1, function() if NAUIMANAGER.ScriptHubFrame then NAgui.menu(NAUIMANAGER.ScriptHubFrame) end end)
NAStartupUI("Menu:SubplaceViewer", 0.1, function() if NAUIMANAGER.SubplaceViewerFrame then NAgui.menu(NAUIMANAGER.SubplaceViewerFrame) end end)
NAStartupUI("Menu:ServerList", 0.105, function() if NAUIMANAGER.ServerListFrame then NAgui.menu(NAUIMANAGER.ServerListFrame) end end)

--[[ GUI RESIZE FUNCTION ]]--

NAStartupUI("Resize:ChatLogs", 0.1, function() if NAUIMANAGER.chatLogsFrame then NAgui.resizeable(NAUIMANAGER.chatLogsFrame) end end)
NAStartupUI("Resize:Console", 0.11, function() if NAUIMANAGER.NAconsoleFrame then NAgui.resizeable(NAUIMANAGER.NAconsoleFrame) end end)
NAStartupUI("Resize:Commands", 0.12, function()
	if NAUIMANAGER.commandsFrame then
		NAgui.resizeable(NAUIMANAGER.commandsFrame, Vector2.new(180, 118), Vector2.new(5000, 5000))
		if NAmanage.cmdResp then
			NAmanage.cmdResp(false)
			NAmanage.cmdRespRf = function(center)
				if not (NAUIMANAGER and NAUIMANAGER.commandsFrame and NAUIMANAGER.commandsFrame.Visible) then
					return
				end
				if NAmanage.Commands_SyncHiddenState and not NAmanage.Commands_SyncHiddenState({ center = center == true; responsive = false; syncRows = false }) then
					return
				end
				NAmanage.cmdResp(center == true)
				if NAmanage["syncVisibleCommandRows"] then
					NAmanage["syncVisibleCommandRows"]()
				end
			end
			NAlib.disconnect("NA_CommandsResponsive")
			if NAStuff.NASCREENGUI then
				NAlib.connect("NA_CommandsResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					NAmanage.cmdRespRf(true)
				end))
			end
			if NAUIMANAGER.AUTOSCALER then
				NAlib.connect("NA_CommandsResponsive", NAUIMANAGER.AUTOSCALER:GetPropertyChangedSignal("Scale"):Connect(function()
					NAmanage.cmdRespRf(true)
				end))
			end
			NAlib.connect("NA_CommandsResponsive", NAUIMANAGER.commandsFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				NAmanage.cmdRespRf(false)
			end))
		end
	end
end)
NAStartupUI("Resize:CommandKeybinds", 0.13, function()
	if NAUIMANAGER.CommandKeybindsFrame then
		const metrics = NAmanage.ExecutorWindowSizing.GetSize(640, 470, { minWidth = 460; minHeight = 320; mobileMinWidth = 300; mobileMinHeight = 240; })
		NAgui.resizeable(NAUIMANAGER.CommandKeybindsFrame, Vector2.new(metrics.minWidth, metrics.minHeight), Vector2.new(1400, 920))
	end
end)
NAStartupUI("Resize:Settings", 0.14, function()
	if NAUIMANAGER.SettingsFrame then
		NAgui.resizeable(NAUIMANAGER.SettingsFrame, NAmanage.GetSettingsResizeMin and NAmanage.GetSettingsResizeMin() or nil, Vector2.new(5000, 5000))
		if NAmanage.SettingsTabLayout and type(NAmanage.SettingsTabLayout.Apply) == "function" then
			NAmanage.SettingsTabLayout.Apply()
		end
	end
end)
NAStartupUI("Resize:Waypoints", 0.15, function() if NAUIMANAGER.WaypointFrame then NAgui.resizeable(NAUIMANAGER.WaypointFrame) end end)
NAStartupUI("Resize:Binders", 0.16, function() if NAUIMANAGER.BindersFrame then NAgui.resizeable(NAUIMANAGER.BindersFrame) end end)
NAStartupUI("Resize:Music", 0.3, function()
	if NAUIMANAGER.MusicFrame then
		const metrics = NAmanage.ExecutorWindowSizing.GetSize(620, 450, { minWidth = 420; minHeight = 290; mobileMinWidth = 300; mobileMinHeight = 240; })
		NAgui.resizeable(NAUIMANAGER.MusicFrame, Vector2.new(metrics.minWidth, metrics.minHeight), Vector2.new(1100, 820))
	end
end)
NAStartupUI("Resize:ScriptHub", 0.31, function()
	if NAUIMANAGER.ScriptHubFrame then
		const metrics = NAmanage.ExecutorWindowSizing.GetSize(760, 520, { minWidth = 560; minHeight = 360; mobileMinWidth = 280; mobileMinHeight = 230; })
		NAgui.resizeable(NAUIMANAGER.ScriptHubFrame, Vector2.new(metrics.minWidth, metrics.minHeight), Vector2.new(5000, 5000))
	end
end)
NAStartupUI("Resize:SubplaceViewer", 0.2, function()
	if NAUIMANAGER.SubplaceViewerFrame then
		const metrics = NAmanage.ExecutorWindowSizing.GetSize(780, 530, { minWidth = 560; minHeight = 360; mobileMinWidth = 280; mobileMinHeight = 230; })
		NAgui.resizeable(NAUIMANAGER.SubplaceViewerFrame, Vector2.new(metrics.minWidth, metrics.minHeight), Vector2.new(5000, 5000))
	end
end)
NAStartupUI("Resize:ServerList", 0.205, function()
	if NAUIMANAGER.ServerListFrame then
		const metrics = NAmanage.ExecutorWindowSizing.GetSize(820, 560, { minWidth = 620; minHeight = 420; mobileMinWidth = 340; mobileMinHeight = 300; })
		NAgui.resizeable(NAUIMANAGER.ServerListFrame, Vector2.new(metrics.minWidth, metrics.minHeight), Vector2.new(5000, 5000))
	end
end)
NAStartupUI("Resize:Executor", 0.17, function()
	if NAUIMANAGER.ExecutorFrame then
		const exMin = IsOnMobile and Vector2.new(340, 280) or Vector2.new(680, 420)
		NAgui.resizeable(NAUIMANAGER.ExecutorFrame, exMin, Vector2.new(5000, 5000))
	end
end)
NAStartupUI("Resize:Notepad", 0.18, function()
	if NAUIMANAGER.NotepadFrame then
		const npVp = Services.Workspace.CurrentCamera and Services.Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		const npSmall = IsOnMobile or npVp.X < 720 or npVp.Y < 520
		const npMin = npSmall and Vector2.new(280, 230) or Vector2.new(460, 340)
		NAgui.resizeable(NAUIMANAGER.NotepadFrame, npMin, Vector2.new(5000, 5000))
	end
end)

NAStuff.ExecutorStartupDeferred = true
NAStuff.NotepadStartupDeferred = true
if NAmanage.pulseLoadingUI then
	NAmanage.pulseLoadingUI("deferring heavy panels", 0.985)
end
if NAStuff.ExecutorPrewarmAfterLoad == true then
	Defer(function()
		Wait(1.25)
		if NAmanage.Executor_Init then
			pcall(NAmanage.Executor_Init)
		end
	end)
end
if NAStuff.NotepadPrewarmAfterLoad == true then
	Defer(function()
		Wait(1.5)
		if NAmanage.Notepad_Init then
			pcall(NAmanage.Notepad_Init)
		end
	end)
end
NAStartupUI("TopbarInit", 0.2, function()
	if NAmanage.Topbar_Init then
		pcall(NAmanage.Topbar_Init)
	end
end)
NAStartupUI("SideSwipeInit", 0.22, function()
	if NAmanage.SideSwipe_Init then
		pcall(NAmanage.SideSwipe_Init)
	end
end)

if NAStuff.uiBootHidden and NAStuff.NASCREENGUI and NAStuff.NASCREENGUI:IsA("ScreenGui") then
	pcall(function()
		NAStuff.NASCREENGUI.Enabled = true
	end)
	NAStuff.uiBootHidden = false
end
if NAmanage.pulseLoadingUI then
	NAmanage.pulseLoadingUI("starting icon and quick controls", 0.99)
end

--[[ CMDS COMMANDS SEARCH FUNCTION ]]--
NAgui.normalizeCommandFilter=function(text)
	text = text or ""
	return Lower(GSub(text, ";", ""))
end

NAgui.sanitizeCommandInfo=function(info)
	local searchableInfo = Lower(info or "")
	searchableInfo = GSub(searchableInfo, "<[^>]+>", "")
	searchableInfo = GSub(searchableInfo, "%[[^%]]+%]", "")
	searchableInfo = GSub(searchableInfo, "%([^%)]+%)", "")
	searchableInfo = GSub(searchableInfo, "{[^}]+}", "")
	searchableInfo = GSub(searchableInfo, "【[^】]+】", "")
	searchableInfo = GSub(searchableInfo, "〖[^〗]+〗", "")
	searchableInfo = GSub(searchableInfo, "«[^»]+»", "")
	searchableInfo = GSub(searchableInfo, "‹[^›]+›", "")
	searchableInfo = GSub(searchableInfo, "「[^」]+」", "")
	searchableInfo = GSub(searchableInfo, "『[^』]+』", "")
	searchableInfo = GSub(searchableInfo, "（[^）]+）", "")
	searchableInfo = GSub(searchableInfo, "〔[^〕]+〕", "")
	searchableInfo = GSub(searchableInfo, "‖[^‖]+‖", "")
	searchableInfo = GSub(searchableInfo, "%s+", " ")
	searchableInfo = GSub(searchableInfo, "^%s*(.-)%s*$", "%1")
	return searchableInfo
end

NAgui.filterCommandList = function(rawText)
	const state = NAmanage.ensureCommandListState and NAmanage.ensureCommandListState()
	if not (state and NAUIMANAGER.commandsList) then return end
	const searchText = NAgui.normalizeCommandFilter(rawText)
	const entries = state.entries
	if type(entries) ~= "table" then
		return
	end

	const lowImpact = (NAmanage.IsLowEndUI and NAmanage.IsLowEndUI()) or IsOnMobile == true
	const yieldEvery = lowImpact and 60 or 180
	if searchText == "" and state.staticMode ~= true then
		state.filteredEntries = entries
		NAUIMANAGER.commandsList.CanvasPosition = Vector2.new(0, 0)
		NAmanage.syncVisibleCommandRows(state)
		return
	end
	const filtered = {}
	if type(NAmanage.resetCommandWorkBudget) == "function" then
		NAmanage.resetCommandWorkBudget()
	end
	for i = 1, #entries do
		NAmanage.cmdYield(i, yieldEvery)
		const entry = entries[i]
		if entry then
			const meta = entry.meta or {}
			const lowerName = Lower(tostring(entry.name or ""))
			local matches = false
			if searchText == "" then
				matches = true
			else
				if Sub(lowerName, 1, #searchText) == searchText then
					matches = true
				else
					const searchableInfo = meta.searchable or ""
					if searchableInfo ~= "" and Find(searchableInfo, searchText, 1, true) then
						matches = true
					else
						const aliases = meta.aliases
						if type(aliases) == "table" then
							for j = 1, #aliases do
								const alias = Lower(tostring(aliases[j] or ""))
								if alias and (Sub(alias, 1, #searchText) == searchText or Find(alias, searchText, 1, true)) then
									matches = true
									break
								end
							end
						end
					end
				end
			end
			if matches then
				filtered[#filtered + 1] = entry
			end
		end
	end

	state.filteredEntries = filtered
	NAUIMANAGER.commandsList.CanvasPosition = Vector2.new(0, 0)
	if state.staticMode then
		const labels = state.staticLabels or {}
		const filteredMap = {}
		for i = 1, #filtered do
			filteredMap[filtered[i]] = true
		end
		for i = 1, #labels do
			NAmanage.cmdYield(i, yieldEvery)
			const label = labels[i]
			const entry = entries[i]
			if label and entry then
				const visible = searchText == "" or filteredMap[entry] == true
				if visible then
					if label.Parent ~= NAUIMANAGER.commandsList then
						label.Parent = NAUIMANAGER.commandsList
					end
					label.Visible = true
				else
					label.Visible = false
					label.Parent = nil
				end
			end
		end
		updateCanvasSize(NAUIMANAGER.commandsList, NAUIMANAGER and NAUIMANAGER.AUTOSCALER and NAUIMANAGER.AUTOSCALER.Scale or nil)
		if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
			NAmanage.CustomScroll.refreshByTarget(NAUIMANAGER.commandsList)
		end
		return
	end
	NAmanage.syncVisibleCommandRows(state)
end

commandFilterTick = 0
NAlib.disconnect("commands_filter_text")
NAlib.connect("commands_filter_text", NAUIMANAGER.commandsFilter:GetPropertyChangedSignal("Text"):Connect(function()
	commandFilterTick += 1
	const thisTick = commandFilterTick
	Delay(0, function()
		if thisTick ~= commandFilterTick then
			return
		end
		if NAUIMANAGER and NAUIMANAGER.commandsFilter then
			NAgui.filterCommandList(NAUIMANAGER.commandsFilter.Text)
		end
	end)
end))
