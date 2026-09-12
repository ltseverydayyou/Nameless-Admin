if type(NAmanage.queueCommandDataBuild) == "function" then
	NAmanage.queueCommandDataBuild({ force = true; startup = true; })
else
	NAgui.loadCMDS({ force = true })
end
NAgui.searchCommands()
Defer(function()
	if type(NAmanage.ApplyCmdAutofillVisibility) == "function" then
		NAmanage.ApplyCmdAutofillVisibility({ refresh = false })
	end
end)

NAgui.autoFILLLL=function()
	if not NAUIMANAGER.cmdInput then return end
	if not NAmanage.isCmdBarActive() then
		if predictionInput then
			predictionInput.Text = ""
		end
		NAStuff.lastCmdAutofillCompletion = ""
		NAgui.hideFill()
		return
	end
	const ctx = NAmanage.getCmdAutofillContext(NAUIMANAGER.cmdInput.Text or "")
	const query = ctx.query or ""
	lastSearchText = query
	gen += 1
	NAmanage.performSearch(query, ctx)
end

if NAUIMANAGER.cmdInput then
	NAlib.disconnect("cmdbar_input_focused")
	NAlib.connect("cmdbar_input_focused", NAUIMANAGER.cmdInput.Focused:Connect(function()
		NAStuff.cmdSearchSuspendUntil = 0
		Delay(0, NAgui.autoFILLLL)
	end))
	NAlib.disconnect("cmdbar_input_soft_click")
	NAlib.connect("cmdbar_input_soft_click", NAUIMANAGER.cmdInput.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and NAmanage.CmdInputUseSoftFocus and NAmanage.CmdInputUseSoftFocus() then
			NAgui.barSelect(0.12)
			NAmanage.CmdSoftInputStart()
		end
	end))
end

--[[ OPEN THE COMMAND BAR ]]--
--[[mouse.KeyDown:Connect(function(k)
	if k:lower()==opt.prefix then
		Wait();
		NAgui.barSelect()
		cmdInput.Text=''
		cmdInput:CaptureFocus()
	end
end)]]
NAlib.disconnect("cmdbar_hotkeys")
NAStuff.prefixKeyAliasMap = NAStuff.prefixKeyAliasMap or {
	[";"] = "Semicolon",
	[","] = "Comma",
	["."] = "Period",
	["/"] = "Slash",
	["\\"] = "BackSlash",
	["`"] = "Backquote",
	["-"] = "Minus",
	["="] = "Equals",
	["["] = "LeftBracket",
	["]"] = "RightBracket",
	["'"] = "Quote",
}
NAStuff.prefixDigitMap = NAStuff.prefixDigitMap or {
	["0"] = Enum.KeyCode.Zero,
	["1"] = Enum.KeyCode.One,
	["2"] = Enum.KeyCode.Two,
	["3"] = Enum.KeyCode.Three,
	["4"] = Enum.KeyCode.Four,
	["5"] = Enum.KeyCode.Five,
	["6"] = Enum.KeyCode.Six,
	["7"] = Enum.KeyCode.Seven,
	["8"] = Enum.KeyCode.Eight,
	["9"] = Enum.KeyCode.Nine,
}
NAStuff.cachedPrefixChar = NAStuff.cachedPrefixChar or nil
NAStuff.cachedPrefixKey = NAStuff.cachedPrefixKey or nil
NAStuff.pfxMap = NAStuff.pfxMap or (function()
	const lookup = {}
	local ok, enumItems = pcall(function()
		return Enum.KeyCode:GetEnumItems()
	end)
	if ok and type(enumItems) == "table" then
		for _, keyCode in enumItems do
			const keyName = Lower(tostring(keyCode.Name or ""))
			if keyName ~= "" then
				lookup[keyName] = keyCode
			end
			const keyValue = tonumber(keyCode.Value)
			if keyValue then
				lookup[keyValue] = keyCode
			end
		end
	end
	return lookup
end)()
originalIO.resolvePrefixKey=function()
	const function sKey(name)
		if type(name) ~= "string" or name == "" then
			return nil
		end
		local ok, value = pcall(function()
			return Enum.KeyCode[name]
		end)
		if ok and value then
			return value
		end
		return nil
	end

	const prefixChar = tostring(opt.prefix or ""):sub(1, 1)
	if prefixChar == NAStuff.cachedPrefixChar then
		return NAStuff.cachedPrefixKey
	end
	NAStuff.cachedPrefixChar = prefixChar
	NAStuff.cachedPrefixKey = nil
	if prefixChar == "" then
		return nil
	end
	const alias = NAStuff.prefixKeyAliasMap[prefixChar]
	const aliasEnum = sKey(alias)
	if aliasEnum then
		NAStuff.cachedPrefixKey = aliasEnum
		return NAStuff.cachedPrefixKey
	end
	if NAStuff.prefixDigitMap[prefixChar] then
		NAStuff.cachedPrefixKey = NAStuff.prefixDigitMap[prefixChar]
		return NAStuff.cachedPrefixKey
	end
	const upper = prefixChar:upper()
	const upperEnum = (#upper == 1) and sKey(upper) or nil
	if upperEnum then
		NAStuff.cachedPrefixKey = upperEnum
		return NAStuff.cachedPrefixKey
	end
	const fbMap = NAStuff.pfxMap
	if fbMap then
		const byName = fbMap[Lower(prefixChar)]
		if byName then
			NAStuff.cachedPrefixKey = byName
			return NAStuff.cachedPrefixKey
		end
		const byValue = fbMap[string.byte(prefixChar)]
		if byValue then
			NAStuff.cachedPrefixKey = byValue
			return NAStuff.cachedPrefixKey
		end
	end
	return nil
end
NAlib.connect("cmdbar_soft_repeat_end", Services.UserInputService.InputEnded:Connect(function(i, g)
	if not (NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive()) then
		return
	end
	if not i or i.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	const repeatKey = NAStuff and NAStuff.cmdInputSoftRepeatKey or nil
	if i.KeyCode == Enum.KeyCode.Backspace
		or i.KeyCode == Enum.KeyCode.Delete
		or (repeatKey ~= nil and i.KeyCode == repeatKey) then
		if NAmanage.CmdInputStopKeyRepeat then
			NAmanage.CmdInputStopKeyRepeat()
		end
	end
end))
NAlib.connect("cmdbar_hotkeys", Services.UserInputService.InputBegan:Connect(function(i, g)
	if NAmanage.HandleCmdSoftInput and NAmanage.HandleCmdSoftInput(i, g) then
		return
	end
	if not i or i.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if i.KeyCode == Enum.KeyCode.Tab
		and (__lt.cm("UserInputService", "GetFocusedTextBox") == (NAUIMANAGER and NAUIMANAGER.cmdInput)) then
		NAmanage.CmdInputApplyPrediction()
		return
	end
	if g then return end
	const k = originalIO.resolvePrefixKey()
	if not k or i.KeyCode ~= k then
		return
	end
	const cmdInput = NAUIMANAGER and NAUIMANAGER.cmdInput
	if not cmdInput then
		return
	end
	const now = os.clock()
	if NAStuff._cmdbarFocusPending then
		return
	end
	const lastFocusHotkey = tonumber(NAStuff._cmdbarFocusHotkeyTick) or 0
	if (now - lastFocusHotkey) < 0.12 then
		return
	end
	NAStuff._cmdbarFocusHotkeyTick = now
	NAStuff._cmdbarFocusPending = true
	Defer(function()
		const box = NAUIMANAGER and NAUIMANAGER.cmdInput
		if not box then
			NAStuff._cmdbarFocusPending = false
			return
		end
		const focused = NAgui.activateCmdInput({
			clear = true,
			prefixChar = tostring(opt.prefix or ""):sub(1, 1)
		})
		if not focused and type(DoNotif) == "function" then
			DoNotif("Command bar focus delayed.", 1.5)
		end
		NAStuff._cmdbarFocusPending = false
	end)
end))

--[[ CLOSE THE COMMAND BAR ]]--
NAlib.disconnect("cmdbar_input_focuslost")
NAlib.connect("cmdbar_input_focuslost", NAUIMANAGER.cmdInput.FocusLost:Connect(function(enter)
	if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
		return
	end
	if IsOnMobile and NAStuff.cmdFocusGuardUntil and os.clock() < NAStuff.cmdFocusGuardUntil then
		return
	end
	if IsOnMobile and NAStuff.autofillRefocusGuard > 0 and os.clock() < NAStuff.autofillRefocusGuard then
		return
	end
	if IsOnMobile and NAStuff.cmdFocusGuardUntil then
		const sinceGuardStart = os.clock() - (NAStuff.cmdFocusGuardUntil - 0.45)
		if sinceGuardStart > 0 and sinceGuardStart < 0.55 then
			return
		end
	end
	if NAStuff.autofillSelecting then
		return
	end
	if enter then
		NAStuff.cmdSearchSuspendUntil = os.clock() + 0.35
		gen += 1
		local txt = NAmanage.stripChar(NAUIMANAGER.cmdInput.Text or "")
		if txt and #txt > 0 then
			const prefix = tostring(opt.prefix or "")
			if prefix ~= "" then
				const escapedPrefix = (NAmanage.StreamerEscapePattern and NAmanage.StreamerEscapePattern(prefix)) or prefix:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
				txt = txt:gsub("^%s*"..escapedPrefix.."+%s*", "")
			end
			if txt ~= "" then
				Defer(function()
					NAlib.parseCommand(prefix..txt)
				end)
			end
		end
	end
	if predictionInput then
		predictionInput.Text = ""
	end
	local checkDelay = 0.05
	if IsOnMobile and NAStuff.autofillRefocusGuard > 0 then
		checkDelay = math.max(0.22, NAStuff.autofillRefocusGuard - os.clock())
	end
	Wait(checkDelay)
	if NAmanage.isCmdSoftInputActive and NAmanage.isCmdSoftInputActive() then
		return
	end
	if not NAUIMANAGER.cmdInput:IsFocused() then NAgui.barDeselect() end
end))

NAlib.disconnect("cmdbar_input_text")
NAlib.connect("cmdbar_input_text", NAUIMANAGER.cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
	if not NAUIMANAGER.cmdInput then
		return
	end

	const suspendedUntil = tonumber(NAStuff.cmdSearchSuspendUntil) or 0
	if suspendedUntil > 0 and os.clock() < suspendedUntil then
		return
	end

	const box = NAUIMANAGER.cmdInput
	const t = box.Text
	const c = NAmanage.stripChar(t, false)
	if c ~= t then
		box.Text = c
		if NAmanage.CmdInputSetCursor then
			NAmanage.CmdInputSetCursor(box, #c + 1)
		else
			box.CursorPosition = #c + 1
		end
	end
	NAgui.searchCommands()
	if NAmanage.CmdInputUpdateSoftVisual then
		NAmanage.CmdInputUpdateSoftVisual()
	end
end))

if NAUIMANAGER.filterBox then
	NAlib.disconnect("waypoint_filter_text")
	NAlib.connect("waypoint_filter_text", NAUIMANAGER.filterBox:GetPropertyChangedSignal("Text"):Connect(NAmanage.UpdateWaypointList))
end
if NAUIMANAGER.WaypointSetBtn then
	NAlib.disconnect("waypoint_set_custom_btn")
	MouseButtonFix(NAUIMANAGER.WaypointSetBtn, function()
		NAmanage.WaypointSetFromUI()
	end)
end
if NAUIMANAGER.WaypointCurrentBtn then
	NAlib.disconnect("waypoint_current_fill_btn")
	MouseButtonFix(NAUIMANAGER.WaypointCurrentBtn, function()
		NAmanage.WaypointFillCurrentUI()
	end)
end
if NAUIMANAGER.WaypointCoordBox then
	NAlib.disconnect("waypoint_coord_enter")
	NAlib.connect("waypoint_coord_enter", NAUIMANAGER.WaypointCoordBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and NAUIMANAGER.WaypointNameBox and NAUIMANAGER.WaypointNameBox.Text ~= "" then
			NAmanage.WaypointSetFromUI()
		end
	end))
end

NAStuff.ExecutorKeywordSet = NAStuff.ExecutorKeywordSet or {
	["and"] = true, ["break"] = true, ["continue"] = true, ["do"] = true, ["else"] = true, ["elseif"] = true,
	["end"] = true, ["false"] = true, ["for"] = true, ["function"] = true, ["if"] = true, ["in"] = true,
	["local"] = true, ["nil"] = true, ["not"] = true, ["or"] = true, ["repeat"] = true, ["return"] = true,
	["then"] = true, ["true"] = true, ["until"] = true, ["while"] = true, ["export"] = true, ["type"] = true,
	["typeof"] = true, ["as"] = true,
}
NAStuff.ExecutorGlobalSet = NAStuff.ExecutorGlobalSet or {
	["game"] = true, ["workspace"] = true, ["script"] = true, ["shared"] = true, ["plugin"] = true, ["Enum"] = true,
	["Color3"] = true, ["Vector2"] = true, ["Vector3"] = true, ["CFrame"] = true, ["UDim"] = true, ["UDim2"] = true,
	["Instance"] = true, ["TweenInfo"] = true, ["Ray"] = true, ["Rect"] = true, ["Region3"] = true, ["Random"] = true,
	["DateTime"] = true, ["NumberRange"] = true, ["NumberSequence"] = true, ["ColorSequence"] = true,
	["BrickColor"] = true, ["Axes"] = true, ["Faces"] = true, ["Font"] = true, ["math"] = true, ["string"] = true,
	["table"] = true, ["task"] = true, ["debug"] = true, ["coroutine"] = true, ["os"] = true, ["utf8"] = true,
	["vector"] = true,
	["pairs"] = true, ["ipairs"] = true, ["next"] = true, ["print"] = true, ["warn"] = true, ["error"] = true,
	["assert"] = true, ["pcall"] = true, ["xpcall"] = true, ["select"] = true, ["rawequal"] = true,
	["rawget"] = true, ["rawset"] = true, ["rawlen"] = true, ["setmetatable"] = true, ["getmetatable"] = true,
	["loadstring"] = true, ["load"] = true, ["require"] = true, ["tonumber"] = true, ["tostring"] = true,
	["type"] = true, ["typeof"] = true, ["unpack"] = true, ["wait"] = true, ["delay"] = true, ["spawn"] = true,
	["tick"] = true, ["time"] = true, ["elapsedTime"] = true, ["gcinfo"] = true, ["collectgarbage"] = true,
	["getfenv"] = true, ["setfenv"] = true, ["newproxy"] = true, ["settings"] = true, ["UserSettings"] = true,
}
NAStuff.ExecutorTypeSet = NAStuff.ExecutorTypeSet or {
	["any"] = true, ["boolean"] = true, ["buffer"] = true, ["nil"] = true, ["number"] = true,
	["string"] = true, ["thread"] = true, ["unknown"] = true, ["never"] = true, ["userdata"] = true,
}

NAmanage.ExecutorSplitEditorLines = NAmanage.ExecutorSplitEditorLines or function(source)
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

NAmanage.ExecutorJoinEditorLines = NAmanage.ExecutorJoinEditorLines or function(lines)
	if type(lines) ~= "table" or #lines == 0 then
		return ""
	end
	return Concat(lines, "\n")
end

NAmanage.ExecutorRepairTabText = NAmanage.ExecutorRepairTabText or function(source)
	source = tostring(source or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
	if source == "" then
		return ""
	end
	const var = source:match("unpack%s*%(%s*([%a_][%w_]*)%s*%)")
	if not var then
		return source
	end
	if not (source:find(":FireServer%s*%(%s*unpack%s*%(") or source:find(":InvokeServer%s*%(%s*unpack%s*%(")) then
		return source
	end
	const fixed = {}
	local lastKeyLine
	for line in (source.."\n"):gmatch("(.-)\n") do
		const keyLine = line:match("^%s*%[%s*[%d\"'].-%]%s*=%s*.+$") and line:gsub("%s+", "") or nil
		if not (keyLine and keyLine == lastKeyLine) then
			fixed[#fixed + 1] = line
		end
		lastKeyLine = keyLine
	end
	source = Concat(fixed, "\n")
	if source:match("^%s*local%s+"..var.."%s*=%s*{") or source:match("^%s*"..var.."%s*=%s*{") then
		return source
	end
	if source:match("^%s*%[%s*[%d\"'].-%]%s*=") then
		return "local "..var.." = {\n"..source
	end
	return source
end

NAmanage.ExecutorSliceEditorLines = NAmanage.ExecutorSliceEditorLines or function(lines, firstLine, lastLine)
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

NAmanage.ExecutorReplaceEditorLineRange = NAmanage.ExecutorReplaceEditorLineRange or function(lines, firstLine, lastLine, text)
	lines = type(lines) == "table" and lines or { "" }
	const insertLines = NAmanage.ExecutorSplitEditorLines(text)
	const rebuilt = {}
	firstLine = math.clamp(tonumber(firstLine) or 1, 1, math.max(#lines + 1, 1))
	lastLine = math.clamp(tonumber(lastLine) or (firstLine - 1), firstLine - 1, math.max(#lines, firstLine - 1))
	for line = 1, firstLine - 1 do
		rebuilt[#rebuilt + 1] = tostring(lines[line] or "")
	end
	for _, lineText in insertLines do
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

NAmanage.ExecutorStripLuauLineForIndent = NAmanage.ExecutorStripLuauLineForIndent or function(line, state)
	line = tostring(line or "")
	state = state or {}
	const out = {}
	local i = 1
	const len = #line
	const function pushSpaces(count)
		if count > 0 then
			out[#out + 1] = string.rep(" ", count)
		end
	end
	while i <= len do
		if state.longClose then
			local closeStart, closeEnd = line:find(state.longClose, i, true)
			if closeStart then
				pushSpaces(closeEnd - i + 1)
				i = closeEnd + 1
				state.longClose = nil
			else
				pushSpaces(len - i + 1)
				break
			end
		else
			const two = line:sub(i, i + 1)
			if two == "--" then
				const eq = line:match("^%-%-%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					const closeStart = line:find(closePattern, i + 4 + #eq, true)
					if closeStart then
						pushSpaces(len - i + 1)
					else
						state.longClose = closePattern
						pushSpaces(len - i + 1)
					end
				else
					pushSpaces(len - i + 1)
				end
				break
			elseif line:sub(i, i):match("[\"'`]") then
				const quote = line:sub(i, i)
				local j = i + 1
				local escaped = false
				while j <= len do
					const ch = line:sub(j, j)
					if escaped then
						escaped = false
					elseif ch == "\\" then
						escaped = true
					elseif ch == quote then
						break
					end
					j += 1
				end
				if j > len then
					j = len
				end
				pushSpaces(j - i + 1)
				i = j + 1
			else
				const eq = line:match("^%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					local closeStart, closeEnd = line:find(closePattern, i + 2 + #eq, true)
					if closeStart then
						pushSpaces(closeEnd - i + 1)
						i = closeEnd + 1
					else
						state.longClose = closePattern
						pushSpaces(len - i + 1)
						break
					end
				else
					out[#out + 1] = line:sub(i, i)
					i += 1
				end
			end
		end
	end
	return Concat(out)
end

NAmanage.ExecutorSplitLuauStatementLine = NAmanage.ExecutorSplitLuauStatementLine or function(line, state)
	line = tostring(line or "")
	state = state or {}
	const parts = {}
	local startPos = 1
	local i = 1
	const len = #line
	while i <= len do
		if state.longClose then
			local closeStart, closeEnd = line:find(state.longClose, i, true)
			if closeStart then
				i = closeEnd + 1
				state.longClose = nil
			else
				break
			end
		else
			const two = line:sub(i, i + 1)
			if two == "--" then
				const eq = line:match("^%-%-%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					local closeStart, closeEnd = line:find(closePattern, i + 4 + #eq, true)
					if closeStart then
						i = closeEnd + 1
					else
						state.longClose = closePattern
						break
					end
				else
					break
				end
			elseif line:sub(i, i):match("[\"'`]") then
				const quote = line:sub(i, i)
				i += 1
				local escaped = false
				while i <= len do
					const ch = line:sub(i, i)
					if escaped then
						escaped = false
					elseif ch == "\\" then
						escaped = true
					elseif ch == quote then
						break
					end
					i += 1
				end
				i += 1
			else
				const eq = line:match("^%[(=*)%[", i)
				if eq then
					const closePattern = "]"..eq.."]"
					local closeStart, closeEnd = line:find(closePattern, i + 2 + #eq, true)
					if closeStart then
						i = closeEnd + 1
					else
						state.longClose = closePattern
						break
					end
				elseif line:sub(i, i) == ";" then
					parts[#parts + 1] = line:sub(startPos, i - 1)
					startPos = i + 1
					i += 1
				else
					i += 1
				end
			end
		end
	end
	parts[#parts + 1] = line:sub(startPos)
	return parts
end

NAmanage.ExecutorFormatLuauLineSpacing = NAmanage.ExecutorFormatLuauLineSpacing or function(line)
	line = tostring(line or "")
	const out = {}
	local i = 1
	const len = #line
	const function currentText()
		return Concat(out)
	end
	const function trimRight()
		if #out > 0 then
			out[#out] = out[#out]:gsub("%s+$", "")
			if out[#out] == "" then
				table.remove(out, #out)
			end
		end
	end
	const function append(text)
		out[#out + 1] = text
	end
	const function appendOperator(op)
		trimRight()
		append(" "..op.." ")
		while i <= len and line:sub(i, i):match("%s") do
			i += 1
		end
	end
	const function previousSignificant()
		const text = currentText():gsub("%s+$", "")
		return text:sub(-1)
	end
	const function previousWord()
		return currentText():match("([%a_][%w_]*)%s*$")
	end
	const function isUnaryMinus()
		const prev = previousSignificant()
		const word = previousWord()
		return prev == "" or prev:match("[%(%[%{=,%+%-%*/%%%^#<>~]") or word == "return" or word == "local" or word == "then" or word == "do" or word == "else" or word == "elseif" or word == "and" or word == "or" or word == "not"
	end
	while i <= len do
		const ch = line:sub(i, i)
		const two = line:sub(i, i + 1)
		const three = line:sub(i, i + 2)
		if two == "--" then
			if #out > 0 and not currentText():match("%s$") then
				append(" ")
			end
			append(line:sub(i))
			break
		elseif ch:match("[\"'`]") then
			const quote = ch
			const startQuote = i
			i += 1
			local escaped = false
			while i <= len do
				const cur = line:sub(i, i)
				if escaped then
					escaped = false
				elseif cur == "\\" then
					escaped = true
				elseif cur == quote then
					break
				end
				i += 1
			end
			if i > len then
				i = len
			end
			append(line:sub(startQuote, i))
			i += 1
		else
			const eq = line:match("^%[(=*)%[", i)
			if eq then
				const closePattern = "]"..eq.."]"
				local closeStart, closeEnd = line:find(closePattern, i + 2 + #eq, true)
				if closeStart then
					append(line:sub(i, closeEnd))
					i = closeEnd + 1
				else
					append(line:sub(i))
					break
				end
			elseif three == "..." then
				append("...")
				i += 3
			elseif three == "//=" or three == "..=" then
				i += 3
				appendOperator(three)
			elseif two == "//" or two == "->" then
				i += 2
				appendOperator(two)
			elseif two == ".." then
				i += 2
				appendOperator("..")
			elseif two == "::" then
				append("::")
				i += 2
			elseif two == "==" or two == "~=" or two == "<=" or two == ">=" or two == "+=" or two == "-=" or two == "*=" or two == "/=" or two == "%=" or two == "^=" then
				i += 2
				appendOperator(two)
			elseif ch == "?" then
				append("?")
				i += 1
			elseif ch == "=" or ch == "+" or ch == "*" or ch == "/" or ch == "%" or ch == "^" or ch == "<" or ch == ">" or ch == "|" or ch == "&" then
				i += 1
				appendOperator(ch)
			elseif ch == "-" then
				if isUnaryMinus() then
					if currentText():sub(-1) == "-" then
						append(" ")
					end
					append("-")
					i += 1
					while i <= len and line:sub(i, i):match("%s") do
						i += 1
					end
				else
					i += 1
					appendOperator("-")
				end
			elseif ch == "," then
				trimRight()
				append(", ")
				i += 1
				while i <= len and line:sub(i, i):match("%s") do
					i += 1
				end
			else
				append(ch)
				i += 1
			end
		end
	end
	return Concat(out):gsub("%s+$", "")
end

NAmanage.ExecutorLuauParenBalance = NAmanage.ExecutorLuauParenBalance or function(line)
	line = tostring(line or "")
	local balance = 0
	local i = 1
	const len = #line
	while i <= len do
		const ch = line:sub(i, i)
		const two = line:sub(i, i + 1)
		if two == "--" then
			break
		elseif ch:match("[\"'`]") then
			const quote = ch
			i += 1
			local escaped = false
			while i <= len do
				const cur = line:sub(i, i)
				if escaped then
					escaped = false
				elseif cur == "\\" then
					escaped = true
				elseif cur == quote then
					break
				end
				i += 1
			end
		elseif ch == "(" then
			balance += 1
		elseif ch == ")" then
			balance -= 1
		end
		i += 1
	end
	return balance
end

NAmanage.ExecutorCollapseLuauShortCalls = NAmanage.ExecutorCollapseLuauShortCalls or function(source)
	const lines = {}
	for line in (tostring(source or "").."\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line
	end
	if #lines > 0 and lines[#lines] == "" and tostring(source or ""):sub(-1) ~= "\n" then
		table.remove(lines)
	end

	const out = {}
	local i = 1
	const function hasCollapseBlockKeyword(text)
		for _, word in { "function", "then", "do", "end", "repeat", "until", "else", "elseif" } do
			if text:find("%f[%w_]"..word.."%f[^%w_]") then
				return true
			end
		end
		return false
	end
	while i <= #lines do
		const line = lines[i]
		local indent, content = line:match("^(%s*)(.-)%s*$")
		if content and content:match("%(%s*$") then
			local balance = NAmanage.ExecutorLuauParenBalance(content)
			const pieces = { content }
			local j = i + 1
			local canCollapse = balance > 0
			while canCollapse and j <= #lines and balance > 0 do
				const nextContent = lines[j]:match("^%s*(.-)%s*$") or ""
				if nextContent == "" or nextContent:find("%-%-", 1, true) or hasCollapseBlockKeyword(nextContent) then
					canCollapse = false
					break
				end
				pieces[#pieces + 1] = nextContent
				balance += NAmanage.ExecutorLuauParenBalance(nextContent)
				j += 1
			end
			if canCollapse and balance <= 0 and #pieces > 1 then
				local joined = pieces[1]
				for pieceIndex = 2, #pieces do
					const piece = pieces[pieceIndex]
					if piece:match("^%)") then
						joined = joined:gsub("%s+$", "")..piece
					else
						joined = joined:gsub("%s+$", "")..(joined:match("%(%s*$") and "" or " ")..piece
					end
				end
				joined = NAmanage.ExecutorFormatLuauLineSpacing(joined)
				if #joined <= 160 then
					out[#out + 1] = indent..joined
					i = j
				else
					out[#out + 1] = line
					i += 1
				end
			else
				out[#out + 1] = line
				i += 1
			end
		else
			out[#out + 1] = line
			i += 1
		end
	end
	return Concat(out, "\n")
end

NAmanage.ExecutorFormatLuauSource = function(source)
	source = tostring(source or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
	if source:gsub("%s+", "") == "" then
		return source
	end

	const function compileCheck(text, chunkName)
		if type(loadstring) ~= "function" then
			return true
		end
		local ok, fn, err = pcall(loadstring, text, chunkName)
		if not ok then
			return false, tostring(fn or "unknown syntax error")
		end
		if fn then
			return true
		end
		return false, tostring(err or "unknown syntax error")
	end

	local sourceValid, sourceErr = compileCheck(source, "Executor/FormatInput")
	if not sourceValid then
		return nil, "Input has a syntax error: " .. sourceErr
	end

	const lines = {}
	for line in (source .. "\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line
	end
	if #lines > 0 and lines[#lines] == "" and source:sub(-1) ~= "\n" then
		table.remove(lines)
	end

	const formatted = {}
	local indent = 0
	const state = {}
	const indentText = "\t"
	const workState = { lastYield = os.clock() }

	for lineIndex, rawLine in lines do
		const line = tostring(rawLine or ""):gsub("%s+$", "")
		const trimmed = line:gsub("^%s+", "")
		const wasInsideLongToken = state.longClose ~= nil
		const code = NAmanage.ExecutorStripLuauLineForIndent(trimmed, state)
		const compact = code:gsub("^%s+", "")
		local lineIndent = indent
		local leadingClose = 0
		local branchLine = false

		if compact ~= "" then
			if compact:match("^end%f[^%w_]") or compact:match("^until%f[^%w_]") or compact:sub(1, 1) == "}" then
				leadingClose = 1
			elseif compact:match("^else%f[^%w_]") or compact:match("^elseif%f[^%w_]") then
				leadingClose = 1
				branchLine = true
			end
		end

		lineIndent = math.max(lineIndent - leadingClose, 0)
		if wasInsideLongToken then
			formatted[#formatted + 1] = tostring(rawLine or "")
		elseif trimmed == "" then
			formatted[#formatted + 1] = ""
		else
			const spaced = NAmanage.ExecutorFormatLuauLineSpacing(trimmed)
			formatted[#formatted + 1] = string.rep(indentText, lineIndent) .. spaced
		end

		local opens = 0
		local closes = 0
		for token in code:gmatch("%f[%w_](%w+)%f[^%w_]") do
			if token == "function" or token == "then" or token == "do" or token == "repeat" then
				opens += 1
			elseif token == "end" or token == "until" then
				closes += 1
			end
		end
		for _ in code:gmatch("{") do
			opens += 1
		end
		for _ in code:gmatch("}") do
			closes += 1
		end

		indent = math.max(indent - leadingClose, 0)
		closes = math.max(closes - leadingClose, 0)
		indent = math.max(indent + opens - closes, 0)
		if branchLine and not compact:match("^elseif%f[^%w_]") then
			indent += 1
		end

		if lineIndex % 128 == 0 and type(NAmanage.ExecutorYieldWork) == "function" then
			NAmanage.ExecutorYieldWork(workState)
		end
	end

	local result = Concat(formatted, "\n"):gsub("%s+$", "")
	local resultValid, resultErr = compileCheck(result, "Executor/FormatOutput")
	if not resultValid then
		return nil, "Formatter validation failed; original text was kept: " .. resultErr
	end
	return result
end
NAmanage.ExecutorMergeEditorChunks = NAmanage.ExecutorMergeEditorChunks or function(chunks)
	if type(chunks) ~= "table" or #chunks == 0 then
		return ""
	end
	return Concat(chunks, "")
end

NAmanage.ExecutorNormalizeTab = NAmanage.ExecutorNormalizeTab or function(tab)
	if not tab then
		return nil
	end
	if type(tab.text) ~= "string" then
		if type(tab.chunks) == "table" and #tab.chunks > 0 then
			tab.text = NAmanage.ExecutorMergeEditorChunks(tab.chunks)
		else
			tab.text = ""
		end
	end
	if type(tab.lines) ~= "table" or #tab.lines == 0 then
		tab.lines = NAmanage.ExecutorSplitEditorLines(tab.text)
	end
	tab.linesDeferred = false
	tab.viewLine = math.clamp(tonumber(tab.viewLine or tab.page) or 1, 1, math.max(#tab.lines, 1))
	tab.page = 1
	tab.chunks = { tab.text }
	return tab
end

NAmanage.ExecutorGetTabText = NAmanage.ExecutorGetTabText or function(tab)
	tab = NAmanage.ExecutorNormalizeTab(tab)
	if not tab then
		return ""
	end
	if tab.textDirty == true or type(tab.text) ~= "string" then
		tab.text = NAmanage.ExecutorJoinEditorLines(tab.lines)
		tab.chunks = { tab.text }
		tab.textDirty = false
	end
	return tostring(tab.text or "")
end

NAmanage.ExecutorPlaceSettingsPanel = NAmanage.ExecutorPlaceSettingsPanel or function(settingsPanel)
	settingsPanel.AnchorPoint = Vector2.new(1, 0)
	settingsPanel.Position = UDim2.new(1, -10, 0, 42)
end

NAmanage.ExecutorBindSetting = NAmanage.ExecutorBindSetting or function(toggle, hit, cfg, key, applySettings)
	const function flip()
		cfg[key] = not cfg[key]
		applySettings()
	end
	toggle.MouseButton1Click:Connect(flip)
	if hit then
		hit.MouseButton1Click:Connect(flip)
	end
end

NAStuff.ExecutorCodec = NAStuff.ExecutorCodec or {}
NAStuff.ExecutorCodec.Alphabet92 = " !#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~"
NAStuff.ExecutorCodec.Base64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

NAStuff.ExecutorCodec.Base64Encode = NAStuff.ExecutorCodec.Base64Encode or function(source)
	source = tostring(source or "")
	const alphabet = NAStuff.ExecutorCodec.Base64Alphabet
	const out = {}
	for i = 1, #source, 3 do
		const a = string.byte(source, i) or 0
		const b = string.byte(source, i + 1)
		const c = string.byte(source, i + 2)
		const n = a * 65536 + (b or 0) * 256 + (c or 0)
		const ia = math.floor(n / 262144) % 64 + 1
		const ib = math.floor(n / 4096) % 64 + 1
		const ic = math.floor(n / 64) % 64 + 1
		const id = n % 64 + 1
		out[#out + 1] = alphabet:sub(ia, ia)
		out[#out + 1] = alphabet:sub(ib, ib)
		out[#out + 1] = b and alphabet:sub(ic, ic) or "="
		out[#out + 1] = c and alphabet:sub(id, id) or "="
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base64Decode = NAStuff.ExecutorCodec.Base64Decode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 4 ~= 0 then
		return nil, "invalid Base64 length"
	end
	const alphabet = NAStuff.ExecutorCodec.Base64Alphabet
	const map = {}
	for i = 1, #alphabet do
		map[alphabet:sub(i, i)] = i - 1
	end
	const out = {}
	for i = 1, #source, 4 do
		const ca = source:sub(i, i)
		const cb = source:sub(i + 1, i + 1)
		const cc = source:sub(i + 2, i + 2)
		const cd = source:sub(i + 3, i + 3)
		const a = map[ca]
		const b = map[cb]
		const c = cc == "=" and 0 or map[cc]
		const d = cd == "=" and 0 or map[cd]
		if a == nil or b == nil or c == nil or d == nil then
			return nil, "invalid Base64 character"
		end
		const n = a * 262144 + b * 4096 + c * 64 + d
		out[#out + 1] = string.char(math.floor(n / 65536) % 256)
		if cc ~= "=" then out[#out + 1] = string.char(math.floor(n / 256) % 256) end
		if cd ~= "=" then out[#out + 1] = string.char(n % 256) end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.HexDecode = NAStuff.ExecutorCodec.HexDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 2 ~= 0 or source:find("[^%x]") then
		return nil, "invalid hex"
	end
	const out = {}
	for i = 1, #source, 2 do
		out[#out + 1] = string.char(tonumber(source:sub(i, i + 1), 16))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.HexEncode = NAStuff.ExecutorCodec.HexEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.format("%02X", string.byte(source, i))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base64UrlEncode = NAStuff.ExecutorCodec.Base64UrlEncode or function(source)
	return (NAStuff.ExecutorCodec.Base64Encode(source):gsub("%+", "-"):gsub("/", "_"):gsub("=+$", ""))
end

NAStuff.ExecutorCodec.Base64UrlDecode = NAStuff.ExecutorCodec.Base64UrlDecode or function(source)
	source = tostring(source or ""):gsub("%s+", ""):gsub("-", "+"):gsub("_", "/")
	if source == "" or source:find("[^%w%+/%=]") then return nil, "invalid Base64URL" end
	while #source % 4 ~= 0 do source ..= "=" end
	return NAStuff.ExecutorCodec.Base64Decode(source)
end

NAStuff.ExecutorCodec.Base32Alphabet = NAStuff.ExecutorCodec.Base32Alphabet or "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

NAStuff.ExecutorCodec.Base32Encode = NAStuff.ExecutorCodec.Base32Encode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const alphabet = NAStuff.ExecutorCodec.Base32Alphabet
	const out = {}
	local buffer = 0
	local bits = 0
	for i = 1, #source do
		buffer = buffer * 256 + string.byte(source, i)
		bits += 8
		while bits >= 5 do
			bits -= 5
			const div = 2 ^ bits
			const index = math.floor(buffer / div) % 32
			out[#out + 1] = alphabet:sub(index + 1, index + 1)
			buffer %= div
		end
	end
	if bits > 0 then
		const index = (buffer * (2 ^ (5 - bits))) % 32
		out[#out + 1] = alphabet:sub(index + 1, index + 1)
	end
	while #out % 8 ~= 0 do out[#out + 1] = "=" end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base32Decode = NAStuff.ExecutorCodec.Base32Decode or function(source)
	source = tostring(source or ""):upper():gsub("%s+", "")
	if source == "" then return nil, "empty Base32" end
	source = source:gsub("=+$", "")
	const alphabet = NAStuff.ExecutorCodec.Base32Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	local buffer = 0
	local bits = 0
	for i = 1, #source do
		const value = map[source:sub(i, i)]
		if value == nil then return nil, "invalid Base32 character" end
		buffer = buffer * 32 + value
		bits += 5
		while bits >= 8 do
			bits -= 8
			const div = 2 ^ bits
			out[#out + 1] = string.char(math.floor(buffer / div) % 256)
			buffer %= div
		end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.PercentEncode = NAStuff.ExecutorCodec.PercentEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.format("%%%02X", string.byte(source, i))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.PercentDecode = NAStuff.ExecutorCodec.PercentDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 3 ~= 0 then return nil, "invalid percent encoding" end
	const out = {}
	for i = 1, #source, 3 do
		if source:sub(i, i) ~= "%" then return nil, "invalid percent encoding" end
		const hex = source:sub(i + 1, i + 2)
		if not hex:match("^%x%x$") then return nil, "invalid percent byte" end
		out[#out + 1] = string.char(tonumber(hex, 16))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DecimalEncode = NAStuff.ExecutorCodec.DecimalEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = tostring(string.byte(source, i)) end
	return table.concat(out, ",")
end

NAStuff.ExecutorCodec.DecimalDecode = NAStuff.ExecutorCodec.DecimalDecode or function(source)
	const out = {}
	for token in tostring(source or ""):gmatch("[^,%s]+") do
		const value = tonumber(token)
		if not value or value < 0 or value > 255 or value % 1 ~= 0 then return nil, "invalid decimal byte" end
		out[#out + 1] = string.char(value)
	end
	if #out == 0 then return nil, "empty decimal stream" end
	return table.concat(out)
end

NAStuff.ExecutorCodec.BinaryEncode = NAStuff.ExecutorCodec.BinaryEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local value = string.byte(source, i)
		local bits = ""
		for bit = 7, 0, -1 do
			const unit = 2 ^ bit
			if value >= unit then bits ..= "1"; value -= unit else bits ..= "0" end
		end
		out[i] = bits
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.BinaryDecode = NAStuff.ExecutorCodec.BinaryDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 8 ~= 0 or source:find("[^01]") then return nil, "invalid binary stream" end
	const out = {}
	for i = 1, #source, 8 do
		out[#out + 1] = string.char(tonumber(source:sub(i, i + 7), 2))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.OctalEncode = NAStuff.ExecutorCodec.OctalEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.format("%03o", string.byte(source, i)) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.OctalDecode = NAStuff.ExecutorCodec.OctalDecode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 3 ~= 0 or source:find("[^0-7]") then return nil, "invalid octal stream" end
	const out = {}
	for i = 1, #source, 3 do
		const value = tonumber(source:sub(i, i + 2), 8)
		if not value or value > 255 then return nil, "invalid octal byte" end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Rot13 = NAStuff.ExecutorCodec.Rot13 or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local byte = string.byte(source, i)
		if byte >= 65 and byte <= 90 then byte = 65 + ((byte - 65 + 13) % 26)
		elseif byte >= 97 and byte <= 122 then byte = 97 + ((byte - 97 + 13) % 26) end
		out[i] = string.char(byte)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.ByteShift = NAStuff.ExecutorCodec.ByteShift or function(source, amount)
	source = tostring(source or "")
	amount = math.floor(tonumber(amount) or 0)
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char((string.byte(source, i) + amount) % 256) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Complement = NAStuff.ExecutorCodec.Complement or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char(255 - string.byte(source, i)) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.NibbleSwap = NAStuff.ExecutorCodec.NibbleSwap or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char((byte % 16) * 16 + math.floor(byte / 16))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RotateLeft = NAStuff.ExecutorCodec.RotateLeft or function(source, amount)
	source = tostring(source or "")
	amount = math.floor(tonumber(amount) or 3) % 8
	if amount == 0 then return source end
	const high = 2 ^ amount
	const low = 2 ^ (8 - amount)
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char(((byte * high) % 256) + math.floor(byte / low))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RotateRight = NAStuff.ExecutorCodec.RotateRight or function(source, amount)
	source = tostring(source or "")
	amount = math.floor(tonumber(amount) or 3) % 8
	if amount == 0 then return source end
	return NAStuff.ExecutorCodec.RotateLeft(source, 8 - amount)
end

NAStuff.ExecutorCodec.RepeatXor = NAStuff.ExecutorCodec.RepeatXor or function(source, key)
	source = tostring(source or "")
	key = tostring(key or "")
	if key == "" then key = "NA" end
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.char(NAStuff.ExecutorCodec.XorByte(string.byte(source, i), string.byte(key, ((i - 1) % #key) + 1)))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DeltaEncode = NAStuff.ExecutorCodec.DeltaEncode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const out = type(table.create) == "function" and table.create(#source) or {}
	local previous = 0
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char((byte - previous) % 256)
		previous = byte
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DeltaDecode = NAStuff.ExecutorCodec.DeltaDecode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const out = type(table.create) == "function" and table.create(#source) or {}
	local previous = 0
	for i = 1, #source do
		previous = (previous + string.byte(source, i)) % 256
		out[i] = string.char(previous)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RLEEncode = NAStuff.ExecutorCodec.RLEEncode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const out = {}
	local i = 1
	while i <= #source do
		const byte = string.byte(source, i)
		local count = 1
		while i + count <= #source and count < 255 and string.byte(source, i + count) == byte do count += 1 end
		out[#out + 1] = string.char(count, byte)
		i += count
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.RLEDecode = NAStuff.ExecutorCodec.RLEDecode or function(source)
	source = tostring(source or "")
	if #source % 2 ~= 0 then return nil, "invalid RLE stream" end
	const out = {}
	for i = 1, #source, 2 do
		const count = string.byte(source, i)
		const char = source:sub(i + 1, i + 1)
		out[#out + 1] = string.rep(char, count)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Z85Alphabet = NAStuff.ExecutorCodec.Z85Alphabet or "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"

NAStuff.ExecutorCodec.Z85Encode = NAStuff.ExecutorCodec.Z85Encode or function(source)
	source = tostring(source or "")
	const originalLength = #source
	if source == "" then return "", 0 end
	while #source % 4 ~= 0 do source ..= "\0" end
	const alphabet = NAStuff.ExecutorCodec.Z85Alphabet
	const out = {}
	for i = 1, #source, 4 do
		local value = string.byte(source, i) * 16777216 + string.byte(source, i + 1) * 65536 + string.byte(source, i + 2) * 256 + string.byte(source, i + 3)
		const chars = table.create and table.create(5) or {}
		for j = 5, 1, -1 do
			const index = value % 85
			chars[j] = alphabet:sub(index + 1, index + 1)
			value = math.floor(value / 85)
		end
		out[#out + 1] = table.concat(chars)
	end
	return table.concat(out), originalLength
end

NAStuff.ExecutorCodec.Z85Decode = NAStuff.ExecutorCodec.Z85Decode or function(source, originalLength)
	source = tostring(source or "")
	if source == "" then return originalLength == 0 and "" or nil end
	if #source % 5 ~= 0 then return nil, "invalid Z85 length" end
	const alphabet = NAStuff.ExecutorCodec.Z85Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	for i = 1, #source, 5 do
		local value = 0
		for j = 0, 4 do
			const digit = map[source:sub(i + j, i + j)]
			if digit == nil then return nil, "invalid Z85 character" end
			value = value * 85 + digit
		end
		out[#out + 1] = string.char(
			math.floor(value / 16777216) % 256,
			math.floor(value / 65536) % 256,
			math.floor(value / 256) % 256,
			value % 256
		)
	end
	local result = table.concat(out)
	originalLength = tonumber(originalLength)
	if originalLength then result = result:sub(1, originalLength) end
	return result
end

NAStuff.ExecutorCodec.Base4Encode = NAStuff.ExecutorCodec.Base4Encode or function(source)
	source = tostring(source or "")
	const alphabet = "0123"
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local value = string.byte(source, i)
		local chunk = ""
		for power = 3, 0, -1 do
			const unit = 4 ^ power
			const digit = math.floor(value / unit) % 4
			chunk ..= alphabet:sub(digit + 1, digit + 1)
		end
		out[i] = chunk
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base4Decode = NAStuff.ExecutorCodec.Base4Decode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 4 ~= 0 or source:find("[^0-3]") then return nil, "invalid Base4 stream" end
	const out = {}
	for i = 1, #source, 4 do
		local value = 0
		for j = 0, 3 do value = value * 4 + tonumber(source:sub(i + j, i + j)) end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base36Alphabet = NAStuff.ExecutorCodec.Base36Alphabet or "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

NAStuff.ExecutorCodec.Base36Encode = NAStuff.ExecutorCodec.Base36Encode or function(source)
	source = tostring(source or "")
	const alphabet = NAStuff.ExecutorCodec.Base36Alphabet
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const value = string.byte(source, i)
		const a = math.floor(value / 36)
		const b = value % 36
		out[i] = alphabet:sub(a + 1, a + 1)..alphabet:sub(b + 1, b + 1)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base36Decode = NAStuff.ExecutorCodec.Base36Decode or function(source)
	source = tostring(source or ""):upper():gsub("%s+", "")
	if source == "" or #source % 2 ~= 0 then return nil, "invalid Base36 byte stream" end
	const alphabet = NAStuff.ExecutorCodec.Base36Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	for i = 1, #source, 2 do
		const a = map[source:sub(i, i)]
		const b = map[source:sub(i + 1, i + 1)]
		if a == nil or b == nil then return nil, "invalid Base36 character" end
		const value = a * 36 + b
		if value > 255 then return nil, "invalid Base36 byte" end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base62Alphabet = NAStuff.ExecutorCodec.Base62Alphabet or "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

NAStuff.ExecutorCodec.Base62Encode = NAStuff.ExecutorCodec.Base62Encode or function(source)
	source = tostring(source or "")
	const alphabet = NAStuff.ExecutorCodec.Base62Alphabet
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const value = string.byte(source, i)
		const a = math.floor(value / 62)
		const b = value % 62
		out[i] = alphabet:sub(a + 1, a + 1)..alphabet:sub(b + 1, b + 1)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Base62Decode = NAStuff.ExecutorCodec.Base62Decode or function(source)
	source = tostring(source or ""):gsub("%s+", "")
	if source == "" or #source % 2 ~= 0 then return nil, "invalid Base62 byte stream" end
	const alphabet = NAStuff.ExecutorCodec.Base62Alphabet
	const map = {}
	for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
	const out = {}
	for i = 1, #source, 2 do
		const a = map[source:sub(i, i)]
		const b = map[source:sub(i + 1, i + 1)]
		if a == nil or b == nil then return nil, "invalid Base62 character" end
		const value = a * 62 + b
		if value > 255 then return nil, "invalid Base62 byte" end
		out[#out + 1] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.PairSwap = NAStuff.ExecutorCodec.PairSwap or function(source)
	source = tostring(source or "")
	const out = {}
	for i = 1, #source, 2 do
		const a = source:sub(i, i)
		const b = source:sub(i + 1, i + 1)
		if b ~= "" then out[#out + 1] = b..a else out[#out + 1] = a end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.IndexShift = NAStuff.ExecutorCodec.IndexShift or function(source, decode)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const amount = i % 256
		const byte = string.byte(source, i)
		out[i] = string.char((byte + (decode and -amount or amount)) % 256)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.AffineEncode = NAStuff.ExecutorCodec.AffineEncode or function(source, add)
	source = tostring(source or "")
	add = math.floor(tonumber(add) or 37) % 256
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char((string.byte(source, i) * 5 + add) % 256) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.AffineDecode = NAStuff.ExecutorCodec.AffineDecode or function(source, add)
	source = tostring(source or "")
	add = math.floor(tonumber(add) or 37) % 256
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char(((string.byte(source, i) - add) * 205) % 256) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.BitReverse = NAStuff.ExecutorCodec.BitReverse or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local value = string.byte(source, i)
		local reversed = 0
		for _ = 1, 8 do
			reversed = reversed * 2 + (value % 2)
			value = math.floor(value / 2)
		end
		out[i] = string.char(reversed)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.XorByte = NAStuff.ExecutorCodec.XorByte or function(a, b)
	if type(bit32) == "table" and type(bit32.bxor) == "function" then
		return bit32.bxor(a, b)
	end
	local result = 0
	local place = 1
	while a > 0 or b > 0 do
		const aa = a % 2
		const bb = b % 2
		if aa ~= bb then result += place end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
		place *= 2
	end
	return result
end

NAStuff.ExecutorCodec.IndexXor = NAStuff.ExecutorCodec.IndexXor or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do out[i] = string.char(NAStuff.ExecutorCodec.XorByte(string.byte(source, i), i % 256)) end
	return table.concat(out)
end

NAStuff.ExecutorCodec.GrayEncode = NAStuff.ExecutorCodec.GrayEncode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		const byte = string.byte(source, i)
		out[i] = string.char(NAStuff.ExecutorCodec.XorByte(byte, math.floor(byte / 2)))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.GrayDecode = NAStuff.ExecutorCodec.GrayDecode or function(source)
	source = tostring(source or "")
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		local gray = string.byte(source, i)
		local value = gray
		while gray > 0 do
			gray = math.floor(gray / 2)
			value = NAStuff.ExecutorCodec.XorByte(value, gray)
		end
		out[i] = string.char(value)
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.Xor = NAStuff.ExecutorCodec.Xor or function(source, key)
	source = tostring(source or "")
	key = math.clamp(math.floor(tonumber(key) or 91), 0, 255)
	const out = type(table.create) == "function" and table.create(#source) or {}
	for i = 1, #source do
		out[i] = string.char(NAStuff.ExecutorCodec.XorByte(string.byte(source, i), key))
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.LZW92Encode = NAStuff.ExecutorCodec.LZW92Encode or function(source)
	source = tostring(source or "")
	if source == "" then return "" end
	const alphabet = NAStuff.ExecutorCodec.Alphabet92
	local dictionary = {}
	for i = 0, 255 do dictionary[string.char(i)] = i end
	local nextCode = 256
	local previous = source:sub(1, 1)
	const result = {}
	const function emit(code)
		const a = math.floor(code / 92)
		const b = code % 92
		result[#result + 1] = alphabet:sub(a + 1, a + 1)
		result[#result + 1] = alphabet:sub(b + 1, b + 1)
	end
	for i = 2, #source do
		const current = source:sub(i, i)
		const combined = previous..current
		if dictionary[combined] ~= nil then
			previous = combined
		else
			emit(dictionary[previous])
			dictionary[combined] = nextCode
			nextCode += 1
			if nextCode > 8463 then
				dictionary = {}
				for j = 0, 255 do dictionary[string.char(j)] = j end
				nextCode = 256
			end
			previous = current
		end
	end
	emit(dictionary[previous])
	return table.concat(result)
end

NAStuff.ExecutorCodec.LZW92Decode = NAStuff.ExecutorCodec.LZW92Decode or function(source, alphabet)
	source = tostring(source or "")
	alphabet = tostring(alphabet or NAStuff.ExecutorCodec.Alphabet92)
	if #alphabet ~= 92 or #source < 2 or #source % 2 ~= 0 then
		return nil, "invalid Base92/LZW stream"
	end
	const map = {}
	for i = 1, 92 do map[alphabet:sub(i, i)] = i - 1 end
	local dictionary = {}
	for i = 0, 255 do dictionary[i] = string.char(i) end
	const function readCode(i)
		const a = map[source:sub(i, i)]
		const b = map[source:sub(i + 1, i + 1)]
		if a == nil or b == nil then return nil end
		return a * 92 + b
	end
	const firstCode = readCode(1)
	if firstCode == nil or dictionary[firstCode] == nil then
		return nil, "invalid initial LZW code"
	end
	local nextCode = 256
	local previous = dictionary[firstCode]
	const result = { previous }
	for i = 3, #source, 2 do
		const code = readCode(i)
		if code == nil then return nil, "invalid Base92 character" end
		local entry = dictionary[code]
		if entry == nil then entry = previous..previous:sub(1, 1) end
		result[#result + 1] = entry
		dictionary[nextCode] = previous..entry:sub(1, 1)
		nextCode += 1
		if nextCode > 8463 then
			dictionary = {}
			for j = 0, 255 do dictionary[j] = string.char(j) end
			nextCode = 256
		end
		previous = entry
	end
	return table.concat(result)
end

NAStuff.ExecutorCodec.DecodeLuaEscapes = NAStuff.ExecutorCodec.DecodeLuaEscapes or function(source)
	source = tostring(source or "")
	const out = {}
	local i = 1
	while i <= #source do
		const ch = source:sub(i, i)
		if ch ~= "\\" then
			out[#out + 1] = ch
			i += 1
		else
			const nextChar = source:sub(i + 1, i + 1)
			if nextChar == "n" then out[#out + 1] = "\n"; i += 2
			elseif nextChar == "r" then out[#out + 1] = "\r"; i += 2
			elseif nextChar == "t" then out[#out + 1] = "\t"; i += 2
			elseif nextChar == "a" then out[#out + 1] = string.char(7); i += 2
			elseif nextChar == "b" then out[#out + 1] = string.char(8); i += 2
			elseif nextChar == "f" then out[#out + 1] = string.char(12); i += 2
			elseif nextChar == "v" then out[#out + 1] = string.char(11); i += 2
			elseif nextChar == "\\" or nextChar == '"' or nextChar == "'" then out[#out + 1] = nextChar; i += 2
			elseif nextChar == "x" and source:sub(i + 2, i + 3):match("^%x%x$") then
				out[#out + 1] = string.char(tonumber(source:sub(i + 2, i + 3), 16)); i += 4
			elseif nextChar:match("%d") then
				const digits = source:sub(i + 1):match("^(%d%d?%d?)") or ""
				const value = tonumber(digits)
				if value and value <= 255 then out[#out + 1] = string.char(value); i += 1 + #digits else out[#out + 1] = nextChar; i += 2 end
			elseif nextChar == "z" then
				i += 2
				while i <= #source and source:sub(i, i):match("%s") do i += 1 end
			else
				out[#out + 1] = nextChar
				i += 2
			end
		end
	end
	return table.concat(out)
end

NAStuff.ExecutorCodec.DecodeCharList = NAStuff.ExecutorCodec.DecodeCharList or function(numbers)
	const out = {}
	for token in tostring(numbers or ""):gmatch("[^,%s]+") do
		const value = tonumber(token)
		if not value or value < 0 or value > 255 or value % 1 ~= 0 then return nil end
		out[#out + 1] = string.char(value)
	end
	if #out == 0 then return nil end
	return table.concat(out)
end

NAStuff.ExecutorCodec.TextScore = NAStuff.ExecutorCodec.TextScore or function(source)
	source = tostring(source or "")
	if source == "" then return 0 end
	local good = 0
	for i = 1, #source do
		const byte = string.byte(source, i)
		if byte == 9 or byte == 10 or byte == 13 or (byte >= 32 and byte <= 126) then good += 1 end
	end
	return good / #source
end

NAStuff.ExecutorCodec.StripLeadingJunk = NAStuff.ExecutorCodec.StripLeadingJunk or function(source)
	source = tostring(source or "")
	const out = {}
	local removed = 0
	local scanning = true
	const trailing = source:sub(-1) == "\n"
	for line in (source.."\n"):gmatch("(.-)\n") do
		if scanning then
			const trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
			const body = trimmed:match("^%-%-%[%[(.-)%]%]$")
			if body then
				const low = body:lower()
				if low:find("obfuscated by", 1, true) or low:find("was here", 1, true) or low:find("made by", 1, true) or low:find("on discord", 1, true) or low:find("on top", 1, true) then
					removed += 1
				else
					scanning = false
					out[#out + 1] = line
				end
			elseif trimmed == "" and removed > 0 then
			else
				scanning = false
				out[#out + 1] = line
			end
		else
			out[#out + 1] = line
		end
	end
	local result = table.concat(out, "\n")
	if not trailing then result = result:gsub("\n$", "") end
	return result, removed
end

NAStuff.ExecutorCodec.TryFullLayer = NAStuff.ExecutorCodec.TryFullLayer or function(source)
	source = tostring(source or "")
	const wrdRecoveryIdPrefix = "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V2:"
	if source:sub(1, #wrdRecoveryIdPrefix) == wrdRecoveryIdPrefix then
		const closePos = source:find("]]", #wrdRecoveryIdPrefix + 1, true)
		if closePos then
			const recoveryId = source:sub(#wrdRecoveryIdPrefix + 1, closePos - 1)
			if recoveryId ~= "" and not recoveryId:find("[^%w%-%_]") and type(readfile) == "function" then
				const recoveryPath = "Nameless-Admin/ExecutorPrometheusRecovery/"..recoveryId..".txt"
				local okRead, payload = pcall(readfile, recoveryPath)
				if okRead and type(payload) == "string" and payload ~= "" then
					const packed = NAStuff.ExecutorCodec.Base64Decode(payload)
					if packed then
						const original = NAStuff.ExecutorCodec.LZW92Decode(packed)
						if type(original) == "string" then
							return original, "WeAreDevs / Prometheus local recovery"
						end
					end
				end
			end
		end
	end
	const wrdRecoveryPrefix = "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V1:"
	if source:sub(1, #wrdRecoveryPrefix) == wrdRecoveryPrefix then
		const closePos = source:find("]]", #wrdRecoveryPrefix + 1, true)
		if closePos then
			const payload = source:sub(#wrdRecoveryPrefix + 1, closePos - 1)
			if payload ~= "" then
				const packed = NAStuff.ExecutorCodec.Base64Decode(payload)
				if packed then
					const original = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if type(original) == "string" then
						return original, "WeAreDevs / Prometheus embedded recovery"
					end
				end
			end
		end
	end
	const markerName = source:match("%-%-%[%[NA_OBF:([A-Z0-9_]+)%]%]")
	if markerName then
		const payload = source:match('local%s+P%s*=%s*"([^"]*)"') or source:match('const%s+P%s*=%s*"([^"]*)"')
		const keyNumber = tonumber(source:match("local%s+K%s*=%s*(%d+)") or source:match("const%s+K%s*=%s*(%d+)"))
		const keyString = source:match('local%s+K%s*=%s*"([^"]*)"') or source:match('const%s+K%s*=%s*"([^"]*)"')
		const originalLength = tonumber(source:match("local%s+L%s*=%s*(%d+)") or source:match("const%s+L%s*=%s*(%d+)"))
		if payload then
			if markerName == "B4" then
				const decoded = NAStuff.ExecutorCodec.Base4Decode(payload)
				if decoded then return decoded, "NA Base4 bytes" end
			elseif markerName == "B36" then
				const decoded = NAStuff.ExecutorCodec.Base36Decode(payload)
				if decoded then return decoded, "NA Base36 bytes" end
			elseif markerName == "B62" then
				const decoded = NAStuff.ExecutorCodec.Base62Decode(payload)
				if decoded then return decoded, "NA Base62 bytes" end
			elseif markerName == "B64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return decoded, "NA Base64" end
			elseif markerName == "B64URL" then
				const decoded = NAStuff.ExecutorCodec.Base64UrlDecode(payload)
				if decoded then return decoded, "NA Base64URL" end
			elseif markerName == "B32" then
				const decoded = NAStuff.ExecutorCodec.Base32Decode(payload)
				if decoded then return decoded, "NA Base32" end
			elseif markerName == "Z85" then
				const decoded = NAStuff.ExecutorCodec.Z85Decode(payload, originalLength)
				if decoded then return decoded, "NA Z85" end
			elseif markerName == "HEX" then
				const decoded = NAStuff.ExecutorCodec.HexDecode(payload)
				if decoded then return decoded, "NA Hex" end
			elseif markerName == "PERCENT" then
				const decoded = NAStuff.ExecutorCodec.PercentDecode(payload)
				if decoded then return decoded, "NA Percent" end
			elseif markerName == "DEC" then
				const decoded = NAStuff.ExecutorCodec.DecimalDecode(payload)
				if decoded then return decoded, "NA Decimal bytes" end
			elseif markerName == "BIN" then
				const decoded = NAStuff.ExecutorCodec.BinaryDecode(payload)
				if decoded then return decoded, "NA Binary" end
			elseif markerName == "OCT" then
				const decoded = NAStuff.ExecutorCodec.OctalDecode(payload)
				if decoded then return decoded, "NA Octal" end
			elseif markerName == "REV64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload:reverse())
				if decoded then return decoded, "NA Reverse Base64" end
			elseif markerName == "ROT13_64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.Rot13(decoded), "NA ROT13+Base64" end
			elseif markerName == "SHIFT64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.ByteShift(decoded, -keyNumber), "NA byte shift+Base64" end
			elseif markerName == "COMP64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.Complement(decoded), "NA complement+Base64" end
			elseif markerName == "NIBBLE64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.NibbleSwap(decoded), "NA nibble swap+Base64" end
			elseif markerName == "ROL64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.RotateRight(decoded, keyNumber), "NA rotate+Base64" end
			elseif markerName == "PAIR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.PairSwap(decoded), "NA pair swap+Base64" end
			elseif markerName == "REVB64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return decoded:reverse(), "NA reversed bytes+Base64" end
			elseif markerName == "IDXOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.IndexXor(decoded), "NA index XOR+Base64" end
			elseif markerName == "IDSHIFT64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.IndexShift(decoded, true), "NA index shift+Base64" end
			elseif markerName == "AFFINE64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.AffineDecode(decoded, keyNumber), "NA affine bytes+Base64" end
			elseif markerName == "BITREV64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.BitReverse(decoded), "NA bit reverse+Base64" end
			elseif markerName == "GRAY64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.GrayDecode(decoded), "NA Gray code+Base64" end
			elseif markerName == "XOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then return NAStuff.ExecutorCodec.Xor(decoded, keyNumber), "NA XOR+Base64" end
			elseif markerName == "RXOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyString then return NAStuff.ExecutorCodec.RepeatXor(decoded, keyString), "NA repeating XOR+Base64" end
			elseif markerName == "DELTA64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then return NAStuff.ExecutorCodec.DeltaDecode(decoded), "NA delta+Base64" end
			elseif markerName == "RLE64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then
					const result = NAStuff.ExecutorCodec.RLEDecode(decoded)
					if result then return result, "NA RLE+Base64" end
				end
			elseif markerName == "JSCAMO" or markerName == "PYCAMO" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then
					return NAStuff.ExecutorCodec.Xor(decoded, keyNumber), markerName == "JSCAMO" and "JavaScript camouflage" or "Python camouflage"
				end
			elseif markerName == "JSCAMO_STRONG" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyString then
					const packed = NAStuff.ExecutorCodec.RepeatXor(decoded, keyString)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "JavaScript camouflage strong" end
				end
			elseif markerName == "PYCAMO_STRONG" then
				const decoded = NAStuff.ExecutorCodec.Base32Decode(payload)
				if decoded and keyString then
					const packed = NAStuff.ExecutorCodec.RepeatXor(decoded, keyString)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "Python camouflage strong" end
				end
			elseif markerName == "LZW92" then
				const decoded = NAStuff.ExecutorCodec.LZW92Decode(payload)
				if decoded then return decoded, "NA LZW92" end
			elseif markerName == "LZW92_B64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded then
					const result = NAStuff.ExecutorCodec.LZW92Decode(decoded)
					if result then return result, "NA LZW92+Base64" end
				end
			elseif markerName == "LZW92_XOR64" then
				const decoded = NAStuff.ExecutorCodec.Base64Decode(payload)
				if decoded and keyNumber then
					const packed = NAStuff.ExecutorCodec.Xor(decoded, keyNumber)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "NA LZW92+XOR+Base64" end
				end
			elseif markerName == "LZW92_RXOR32" then
				const decoded = NAStuff.ExecutorCodec.Base32Decode(payload)
				if decoded and keyString then
					const packed = NAStuff.ExecutorCodec.RepeatXor(decoded, keyString)
					const result = NAStuff.ExecutorCodec.LZW92Decode(packed)
					if result then return result, "NA LZW92+repeating XOR+Base32" end
				end
			end
		end
	end

	if source:find("local z_as2=", 1, true) and source:find("local s=", 1, true) and source:find("local b=", 1, true) then
		const payload = source:match('local%s+s%s*=%s*"([^"]*)"%s*local%s+b%s*=%s*"')
		const alphabet = source:match('local%s+b%s*=%s*"([^"]+)"')
		if payload and alphabet and #alphabet == 92 then
			const decoded = NAStuff.ExecutorCodec.LZW92Decode(payload, alphabet)
			if decoded then return decoded, "z_as Base92/LZW" end
		end
	end

	const loader = source:gsub("^%s+", ""):gsub("%s+$", ""):gsub(";%s*$", "")
	local literal = loader:match('^loadstring%s*%(%s*"([^"\\]*)"%s*%)%s*%(%s*%)$')
	if literal then return NAStuff.ExecutorCodec.DecodeLuaEscapes(literal), "loadstring literal" end
	literal = loader:match("^loadstring%s*%(%s*'([^'\\]*)'%s*%)%s*%(%s*%)$")
	if literal then return NAStuff.ExecutorCodec.DecodeLuaEscapes(literal), "loadstring literal" end

	const charList = loader:match("^loadstring%s*%(%s*string%.char%s*%(([%d,%s]+)%)%s*%)%s*%(%s*%)$")
	if charList then
		const decoded = NAStuff.ExecutorCodec.DecodeCharList(charList)
		if decoded then return decoded, "string.char loader" end
	end

	local reversed = loader:match('^loadstring%s*%(%s*string%.reverse%s*%(%s*"([^"\\]*)"%s*%)%s*%)%s*%(%s*%)$')
	if reversed then return reversed:reverse(), "string.reverse loader" end
	reversed = loader:match("^loadstring%s*%(%s*string%.reverse%s*%(%s*'([^'\\]*)'%s*%)%s*%)%s*%(%s*%)$")
	if reversed then return reversed:reverse(), "string.reverse loader" end

	const compact = source:gsub("%s+", "")
	if #compact >= 16 and #compact % 4 == 0 and not compact:find("[^%w%+/%=]") then
		const decoded = NAStuff.ExecutorCodec.Base64Decode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base64" end
	end
	if #compact >= 16 and not compact:find("[^%w%-%_%=]") and (compact:find("-", 1, true) or compact:find("_", 1, true)) then
		const decoded = NAStuff.ExecutorCodec.Base64UrlDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base64URL" end
	end
	if #compact >= 16 and not compact:find("[^A-Z2-7=]") then
		const decoded = NAStuff.ExecutorCodec.Base32Decode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base32" end
	end
	if #compact >= 16 and #compact % 2 == 0 and not compact:find("[^%x]") then
		const decoded = NAStuff.ExecutorCodec.HexDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw hex" end
	end
	if #compact >= 24 and #compact % 4 == 0 and not compact:find("[^0-3]") then
		const decoded = NAStuff.ExecutorCodec.Base4Decode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw Base4 bytes" end
	end
	if #compact >= 24 and #compact % 8 == 0 and not compact:find("[^01]") then
		const decoded = NAStuff.ExecutorCodec.BinaryDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw binary" end
	end
	if #compact >= 18 and #compact % 3 == 0 and not compact:find("[^0-7]") then
		const decoded = NAStuff.ExecutorCodec.OctalDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw octal" end
	end
	if #compact >= 18 and #compact % 3 == 0 and compact:sub(1, 1) == "%" and compact:gsub("%%[%x][%x]", "") == "" then
		const decoded = NAStuff.ExecutorCodec.PercentDecode(compact)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw percent encoding" end
	end
	if source:match("^%s*%d+%s*,") and not source:find("[^%d,%s]") then
		const decoded = NAStuff.ExecutorCodec.DecimalDecode(source)
		if decoded and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "raw decimal bytes" end
	end
	if source:find("\\x", 1, true) or source:match("\\%d%d?%d?") then
		const decoded = NAStuff.ExecutorCodec.DecodeLuaEscapes(source)
		if decoded ~= source and NAStuff.ExecutorCodec.TextScore(decoded) >= 0.90 and decoded:find("[%a_][%w_]*") then return decoded, "Lua byte escapes" end
	end
	return nil
end

NAStuff.ExecutorCodec.AutoDeobfuscate = NAStuff.ExecutorCodec.AutoDeobfuscate or function(source)
	source = tostring(source or "")
	local current = source
	const applied = {}
	for _ = 1, 24 do
		local nextSource, engine = NAStuff.ExecutorCodec.TryFullLayer(current)
		if type(nextSource) ~= "string" or nextSource == current then break end
		current = nextSource
		applied[#applied + 1] = engine or "decoded layer"
	end
	local cleaned, removed = NAStuff.ExecutorCodec.StripLeadingJunk(current)
	if removed > 0 then
		current = cleaned
		applied[#applied + 1] = "junk comments x"..tostring(removed)
	end
	return current, applied
end

NAStuff.ExecutorCodec.MakeBase64Decoder = NAStuff.ExecutorCodec.MakeBase64Decoder or function(tail)
	return 'local A="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,4 do local a=I[P:sub(i,i)] or 0 local b=I[P:sub(i+1,i+1)] or 0 local c=P:sub(i+2,i+2) local d=P:sub(i+3,i+3) local n=a*262144+b*4096+(I[c] or 0)*64+(I[d] or 0) O[#O+1]=string.char(math.floor(n/65536)%256) if c~="=" then O[#O+1]=string.char(math.floor(n/256)%256) end if d~="=" then O[#O+1]=string.char(n%256) end end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBase64UrlDecoder = NAStuff.ExecutorCodec.MakeBase64UrlDecoder or function(tail)
	return 'P=P:gsub("-","+"):gsub("_","/") while #P%4~=0 do P=P.."=" end '..NAStuff.ExecutorCodec.MakeBase64Decoder(tail)
end

NAStuff.ExecutorCodec.MakeBase32Decoder = NAStuff.ExecutorCodec.MakeBase32Decoder or function(tail)
	return 'local A="ABCDEFGHIJKLMNOPQRSTUVWXYZ234567" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end P=P:gsub("=+$","") local O={} local B,N=0,0 for i=1,#P do local V=I[P:sub(i,i)] B=B*32+V N=N+5 while N>=8 do N=N-8 local Q=2^N O[#O+1]=string.char(math.floor(B/Q)%256) B=B%Q end end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeHexDecoder = NAStuff.ExecutorCodec.MakeHexDecoder or function(tail)
	return 'local O={} for i=1,#P,2 do O[#O+1]=string.char(tonumber(P:sub(i,i+1),16)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakePercentDecoder = NAStuff.ExecutorCodec.MakePercentDecoder or function(tail)
	return 'local O={} for i=1,#P,3 do O[#O+1]=string.char(tonumber(P:sub(i+1,i+2),16)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeDecimalDecoder = NAStuff.ExecutorCodec.MakeDecimalDecoder or function(tail)
	return 'local O={} for N in P:gmatch("[^,]+") do O[#O+1]=string.char(tonumber(N)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBinaryDecoder = NAStuff.ExecutorCodec.MakeBinaryDecoder or function(tail)
	return 'local O={} for i=1,#P,8 do O[#O+1]=string.char(tonumber(P:sub(i,i+7),2)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeOctalDecoder = NAStuff.ExecutorCodec.MakeOctalDecoder or function(tail)
	return 'local O={} for i=1,#P,3 do O[#O+1]=string.char(tonumber(P:sub(i,i+2),8)) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeZ85Decoder = NAStuff.ExecutorCodec.MakeZ85Decoder or function(tail)
	return 'local A="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,5 do local V=0 for j=0,4 do V=V*85+I[P:sub(i+j,i+j)] end O[#O+1]=string.char(math.floor(V/16777216)%256,math.floor(V/65536)%256,math.floor(V/256)%256,V%256) end local D=table.concat(O):sub(1,L) '..tail
end

NAStuff.ExecutorCodec.MakeBase4Decoder = NAStuff.ExecutorCodec.MakeBase4Decoder or function(tail)
	return 'local O={} for i=1,#P,4 do local V=0 for j=0,3 do V=V*4+tonumber(P:sub(i+j,i+j)) end O[#O+1]=string.char(V) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBase36Decoder = NAStuff.ExecutorCodec.MakeBase36Decoder or function(tail)
	return 'local A="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,2 do O[#O+1]=string.char(I[P:sub(i,i)]*36+I[P:sub(i+1,i+1)]) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakeBase62Decoder = NAStuff.ExecutorCodec.MakeBase62Decoder or function(tail)
	return 'local A="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" local I={} for i=1,#A do I[A:sub(i,i)]=i-1 end local O={} for i=1,#P,2 do O[#O+1]=string.char(I[P:sub(i,i)]*62+I[P:sub(i+1,i+1)]) end local D=table.concat(O) '..tail
end

NAStuff.ExecutorCodec.MakePairSwapDecoder = NAStuff.ExecutorCodec.MakePairSwapDecoder or function(tail)
	return 'local T={} for i=1,#D,2 do local a,b=D:sub(i,i),D:sub(i+1,i+1) T[#T+1]=b~="" and b..a or a end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeIndexXorDecoder = NAStuff.ExecutorCodec.MakeIndexXorDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do T[i]=string.char(X(string.byte(D,i),i%256)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeIndexShiftDecoder = NAStuff.ExecutorCodec.MakeIndexShiftDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char((string.byte(D,i)-(i%256))%256) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeAffineDecoder = NAStuff.ExecutorCodec.MakeAffineDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char(((string.byte(D,i)-K)*205)%256) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeBitReverseDecoder = NAStuff.ExecutorCodec.MakeBitReverseDecoder or function(tail)
	return 'local T={} for i=1,#D do local b,r=string.byte(D,i),0 for j=1,8 do r=r*2+(b%2)b=math.floor(b/2) end T[i]=string.char(r) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeGrayDecoder = NAStuff.ExecutorCodec.MakeGrayDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do local g=string.byte(D,i)local v=g while g>0 do g=math.floor(g/2)v=X(v,g) end T[i]=string.char(v) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeXorDecoder = NAStuff.ExecutorCodec.MakeXorDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do T[i]=string.char(X(string.byte(D,i),K)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRepeatXorDecoder = NAStuff.ExecutorCodec.MakeRepeatXorDecoder or function(tail)
	return 'local X=(bit32 and bit32.bxor) or (bit and bit.bxor) or function(a,b)local r,p=0,1 while a>0 or b>0 do local aa,bb=a%2,b%2 if aa~=bb then r=r+p end a=math.floor(a/2)b=math.floor(b/2)p=p*2 end return r end local T={} for i=1,#D do T[i]=string.char(X(string.byte(D,i),string.byte(K,((i-1)%#K)+1))) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRot13Decoder = NAStuff.ExecutorCodec.MakeRot13Decoder or function(tail)
	return 'local T={} for i=1,#D do local b=string.byte(D,i) if b>=65 and b<=90 then b=65+((b-65+13)%26) elseif b>=97 and b<=122 then b=97+((b-97+13)%26) end T[i]=string.char(b) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeShiftDecoder = NAStuff.ExecutorCodec.MakeShiftDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char((string.byte(D,i)-K)%256) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeComplementDecoder = NAStuff.ExecutorCodec.MakeComplementDecoder or function(tail)
	return 'local T={} for i=1,#D do T[i]=string.char(255-string.byte(D,i)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeNibbleDecoder = NAStuff.ExecutorCodec.MakeNibbleDecoder or function(tail)
	return 'local T={} for i=1,#D do local b=string.byte(D,i) T[i]=string.char((b%16)*16+math.floor(b/16)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRotateDecoder = NAStuff.ExecutorCodec.MakeRotateDecoder or function(tail)
	return 'local T={} local S=8-(K%8) local H=2^S local L=2^(8-S) for i=1,#D do local b=string.byte(D,i) T[i]=string.char(((b*H)%256)+math.floor(b/L)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeDeltaDecoder = NAStuff.ExecutorCodec.MakeDeltaDecoder or function(tail)
	return 'local T={} local V=0 for i=1,#D do V=(V+string.byte(D,i))%256 T[i]=string.char(V) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeRLEDecoder = NAStuff.ExecutorCodec.MakeRLEDecoder or function(tail)
	return 'local T={} for i=1,#D,2 do T[#T+1]=string.rep(D:sub(i+1,i+1),string.byte(D,i)) end D=table.concat(T) '..tail
end

NAStuff.ExecutorCodec.MakeLZWDecoder = NAStuff.ExecutorCodec.MakeLZWDecoder or function(tail)
	return 'local B=" !#$%&()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmnopqrstuvwxyz{|}~" local M,R={},{} for i=1,92 do M[B:sub(i,i)]=i-1 end local Z={} for i=0,255 do Z[i]=string.char(i) end local N=256 local W=Z[M[D:sub(1,1)]*92+M[D:sub(2,2)]] R[1]=W for i=3,#D,2 do local C=M[D:sub(i,i)]*92+M[D:sub(i+1,i+1)] local E=Z[C] or W..W:sub(1,1) R[#R+1]=E Z[N]=W..E:sub(1,1) N=N+1 if N>8463 then Z={} for j=0,255 do Z[j]=string.char(j) end N=256 end W=E end D=table.concat(R) '..tail
end

NAStuff.ExecutorCodec.MakeDirectLZWDecoder = NAStuff.ExecutorCodec.MakeDirectLZWDecoder or function(tail)
	return 'local D=P '..NAStuff.ExecutorCodec.MakeLZWDecoder(tail)
end

NAStuff.ExecutorCodec.UniversalRunTail = NAStuff.ExecutorCodec.UniversalRunTail or 'local F=loadstring or load;if not F then error("dynamic loader unavailable") end;local C,E=F(D);if not C then error(E or "compile failed") end;C()'

NAStuff.ExecutorCodec.MakeJavaScriptCamouflage = NAStuff.ExecutorCodec.MakeJavaScriptCamouflage or function(payload, keyValue, strong, sourceLength)
	const decoy = '--[[\n"use strict";\n\nconst Runtime = Object.freeze({\n    engine: "V8",\n    platform: "node",\n    module: "executor.bundle.js",\n    sourceMap: false,\n    byteLength: '..tostring(sourceLength or 0)..',\n});\n\nclass ScriptRuntime {\n    constructor(options = {}) {\n        this.options = { sandbox: true, strict: true, ...options };\n        this.ready = false;\n    }\n\n    async initialize() {\n        this.ready = true;\n        return this;\n    }\n\n    async execute() {\n        if (!this.ready) await this.initialize();\n        const module = await import("./runtime.js");\n        return module.default(Runtime);\n    }\n}\n\nnew ScriptRuntime({ optimize: true })\n    .execute()\n    .catch(error => console.error(error));\n]]\n'
	if strong then
		return decoy..'--[[NA_OBF:JSCAMO_STRONG]]\nlocal P="'..payload..'";local K="'..tostring(keyValue or "")..'";'..
			NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail)))
	end
	return decoy..'--[[NA_OBF:JSCAMO]]\nlocal P="'..payload..'";local K='..tostring(keyValue or 0)..';'..
		NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail))
end

NAStuff.ExecutorCodec.MakePythonCamouflage = NAStuff.ExecutorCodec.MakePythonCamouflage or function(payload, keyValue, strong, sourceLength)
	const decoy = '--[[\nfrom __future__ import annotations\n\nfrom dataclasses import dataclass\nfrom typing import Any, Final\n\nENGINE: Final[str] = "CPython"\nSOURCE_BYTES: Final[int] = '..tostring(sourceLength or 0)..'\n\n@dataclass(slots=True)\nclass RuntimeConfig:\n    sandbox: bool = True\n    optimize: bool = True\n    trace: bool = False\n\nclass ScriptRuntime:\n    def __init__(self, config: RuntimeConfig) -> None:\n        self.config = config\n        self.ready = False\n\n    def initialize(self) -> "ScriptRuntime":\n        self.ready = True\n        return self\n\n    def execute(self) -> Any:\n        if not self.ready:\n            self.initialize()\n        return Runtime.execute(config=self.config)\n\nif __name__ == "__main__":\n    ScriptRuntime(RuntimeConfig()).execute()\n]]\n'
	if strong then
		return decoy..'--[[NA_OBF:PYCAMO_STRONG]]\nlocal P="'..payload..'"\nlocal K="'..tostring(keyValue or "")..'"\n'..
			NAStuff.ExecutorCodec.MakeBase32Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail)))
	end
	return decoy..'--[[NA_OBF:PYCAMO]]\nlocal P="'..payload..'"\nlocal K='..tostring(keyValue or 0)..'\n'..
		NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail))
end

NAStuff.ExecutorCodec.PrometheusRemote = type(NAStuff.ExecutorCodec.PrometheusRemote) == "table" and NAStuff.ExecutorCodec.PrometheusRemote or {
	BaseUrl = "https://raw.githubusercontent.com/prometheus-lua/Prometheus/v0.2.11.1/src/",
	Modules = {},
	Sources = {},
	Loading = {},
	LoadErrors = {},
	Runtime = nil,
	Build = "v0.2.11.1-r6",
}
if NAStuff.ExecutorCodec.PrometheusRemote.Build ~= "v0.2.11.1-r6" then
	NAStuff.ExecutorCodec.PrometheusRemote.BaseUrl = "https://raw.githubusercontent.com/prometheus-lua/Prometheus/v0.2.11.1/src/"
	NAStuff.ExecutorCodec.PrometheusRemote.Modules = {}
	NAStuff.ExecutorCodec.PrometheusRemote.Sources = {}
	NAStuff.ExecutorCodec.PrometheusRemote.Loading = {}
	NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors = {}
	NAStuff.ExecutorCodec.PrometheusRemote.Runtime = nil
	NAStuff.ExecutorCodec.PrometheusRemote.Build = "v0.2.11.1-r6"
else
	NAStuff.ExecutorCodec.PrometheusRemote.BaseUrl = "https://raw.githubusercontent.com/prometheus-lua/Prometheus/v0.2.11.1/src/"
	NAStuff.ExecutorCodec.PrometheusRemote.Modules = type(NAStuff.ExecutorCodec.PrometheusRemote.Modules) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.Modules or {}
	NAStuff.ExecutorCodec.PrometheusRemote.Sources = type(NAStuff.ExecutorCodec.PrometheusRemote.Sources) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.Sources or {}
	NAStuff.ExecutorCodec.PrometheusRemote.Loading = type(NAStuff.ExecutorCodec.PrometheusRemote.Loading) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.Loading or {}
	NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors = type(NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors) == "table" and NAStuff.ExecutorCodec.PrometheusRemote.LoadErrors or {}
end

NAStuff.ExecutorCodec.PrometheusHttpGet = NAStuff.ExecutorCodec.PrometheusHttpGet or function(url)
	if type(_na_boot) == "table" and type(_na_boot.httpGet) == "function" then
		return _na_boot.httpGet(url, { maxAttempts = 3; timeout = 12; })
	end
	local ok, body = pcall(function()
		return game:HttpGet(url, true)
	end)
	if ok and type(body) == "string" and body ~= "" then
		return body
	end
	error("Prometheus source download failed: "..tostring(body or "empty response"), 0)
end

NAStuff.ExecutorCodec.PrometheusBuildMath = function(hostMath)
	if type(hostMath) ~= "table" then
		return hostMath
	end
	const mathProxy = {}
	for key, value in hostMath do
		mathProxy[key] = value
	end
	if type(mathProxy.log10) ~= "function" and type(hostMath.log) == "function" then
		mathProxy.log10 = function(value)
			return hostMath.log(value, 10)
		end
	end
	const rawRandom = hostMath.random
	if type(rawRandom) == "function" then
		local supportsWideRandom = false
		pcall(function()
			rawRandom(1, 2 ^ 40)
			supportsWideRandom = true
		end)
		if not supportsWideRandom then
			local compatRandom
			compatRandom = function(a, b)
				if a == nil and b == nil then
					return rawRandom()
				end
				if b == nil then
					return compatRandom(1, a)
				end
				a = tonumber(a) or 0
				b = tonumber(b) or 0
				if a > b then
					a, b = b, a
				end
				a = math.ceil(a)
				b = math.floor(b)
				if a > b then
					error("interval is empty", 2)
				end
				const diff = b - a
				if diff > 2147483647 then
					return math.floor(rawRandom() * diff + a)
				end
				return rawRandom(a, b)
			end
			mathProxy.random = compatRandom
		end
	end
	return mathProxy
end

NAStuff.ExecutorCodec.PrometheusGetRuntime = function()
	const state = NAStuff.ExecutorCodec.PrometheusRemote
	if type(state.Runtime) == "table" then
		if type(state.Runtime.arg) ~= "table" then
			state.Runtime.arg = {}
		end
		if type(state.Runtime.package) ~= "table" then
			state.Runtime.package = {}
		end
		state.Runtime.package.loaded = state.Modules
		state.Runtime.package.preload = type(state.Runtime.package.preload) == "table" and state.Runtime.package.preload or {}
		state.Runtime.math = NAStuff.ExecutorCodec.PrometheusBuildMath(state.Runtime.math)
		return state.Runtime
	end
	const host = (getgenv and getgenv()) or _G or {}
	local hostPackage = type(host) == "table" and rawget(host, "package") or nil
	local hostArg = type(host) == "table" and rawget(host, "arg") or nil
	const hostMath = type(host) == "table" and rawget(host, "math") or math
	const runtime = {
		arg = type(hostArg) == "table" and hostArg or {},
		math = NAStuff.ExecutorCodec.PrometheusBuildMath(hostMath),
		package = {
			path = type(hostPackage) == "table" and tostring(hostPackage.path or "") or "",
			config = type(hostPackage) == "table" and tostring(hostPackage.config or "") or "",
			loaded = state.Modules,
			preload = {},
		},
	}
	setmetatable(runtime, { __index = host })
	runtime._G = runtime
	runtime.require = function(moduleName)
		return NAStuff.ExecutorCodec.PrometheusRequire(moduleName)
	end
	if type(runtime.newproxy) ~= "function" then
		runtime.newproxy = function(useMetatable)
			local proxy = {}
			if useMetatable then
				setmetatable(proxy, {})
			end
			return proxy
		end
	end
	state.Runtime = runtime
	return runtime
end

NAStuff.ExecutorCodec.PrometheusRequire = function(moduleName)
	moduleName = tostring(moduleName or "")
	if moduleName == "" then
		error("Prometheus require received an empty module name", 0)
	end
	const state = NAStuff.ExecutorCodec.PrometheusRemote
	if state.Modules[moduleName] ~= nil then
		return state.Modules[moduleName]
	end

	const currentThread = coroutine.running()
	local activeLoad = state.Loading[moduleName]
	if type(activeLoad) == "table" then
		if activeLoad.thread == currentThread then
			error("Prometheus circular require: "..moduleName, 0)
		end
		local deadline = os.clock() + 45
		while type(state.Loading[moduleName]) == "table" do
			local owner = state.Loading[moduleName]
			if type(owner.thread) == "thread" then
				local okStatus, status = pcall(coroutine.status, owner.thread)
				if okStatus and status == "dead" then
					state.Loading[moduleName] = nil
					break
				end
			end
			if os.clock() >= deadline then
				error("Prometheus require timed out waiting for module: "..moduleName, 0)
			end
			if type(task) == "table" and type(task.wait) == "function" then
				task.wait()
			elseif type(wait) == "function" then
				wait()
			else
				break
			end
		end
		if state.Modules[moduleName] ~= nil then
			return state.Modules[moduleName]
		end
		local priorError = state.LoadErrors[moduleName]
		if priorError ~= nil then
			error(priorError, 0)
		end
		if state.Loading[moduleName] ~= nil then
			error("Prometheus module is already loading: "..moduleName, 0)
		end
	end

	const loadToken = { thread = currentThread; started = os.clock(); }
	state.Loading[moduleName] = loadToken
	state.LoadErrors[moduleName] = nil
	local ok, result = xpcall(function()
		const path = moduleName:gsub("%.", "/")..".lua"
		local source = state.Sources[moduleName]
		if type(source) ~= "string" or source == "" then
			source = NAStuff.ExecutorCodec.PrometheusHttpGet(state.BaseUrl..path)
			state.Sources[moduleName] = source
		end
		const runtime = NAStuff.ExecutorCodec.PrometheusGetRuntime()
		local chunk, compileErr
		if type(loadstring) == "function" then
			chunk, compileErr = loadstring(source, "@Prometheus/"..path)
			if chunk and type(setfenv) == "function" then
				setfenv(chunk, runtime)
			elseif chunk then
				error("Prometheus integration requires setfenv when loadstring is used", 0)
			end
		elseif type(load) == "function" then
			chunk, compileErr = load(source, "@Prometheus/"..path, "t", runtime)
		else
			error("Prometheus integration requires loadstring or load", 0)
		end
		if type(chunk) ~= "function" then
			error("Prometheus module compile failed ("..moduleName.."): "..tostring(compileErr), 0)
		end
		local value = chunk()
		if value == nil then value = true end
		return value
	end, function(message)
		local raw = tostring(message or "Unknown Prometheus error")
		if type(debug) == "table" and type(debug.traceback) == "function" then
			local traceOk, trace = pcall(debug.traceback, raw, 2)
			if traceOk and type(trace) == "string" and trace ~= "" then
				return trace
			end
		end
		return raw
	end)
	if state.Loading[moduleName] == loadToken then
		state.Loading[moduleName] = nil
	end
	if not ok then
		state.LoadErrors[moduleName] = result
		error(result, 0)
	end
	state.LoadErrors[moduleName] = nil
	state.Modules[moduleName] = result
	return result
end

NAStuff.ExecutorCodec.PrometheusObfuscate = function(source)
	source = tostring(source or "")
	if source == "" then
		return nil, "Nothing to obfuscate"
	end
	const state = NAStuff.ExecutorCodec.PrometheusRemote
	if state.Obfuscating == true then
		return nil, "Prometheus obfuscation is already in progress"
	end
	state.Obfuscating = true
	local function finish(output, err)
		state.Obfuscating = false
		return output, err
	end
	local okBootstrap, Pipeline, Presets, Logger = pcall(function()
		return NAStuff.ExecutorCodec.PrometheusRequire("prometheus.pipeline"), NAStuff.ExecutorCodec.PrometheusRequire("presets"), NAStuff.ExecutorCodec.PrometheusRequire("logger")
	end)
	if not okBootstrap then
		return finish(nil, tostring(Pipeline))
	end
	if type(Pipeline) ~= "table" or type(Pipeline.fromConfig) ~= "function" then
		return finish(nil, "Prometheus pipeline module is unavailable")
	end
	if type(Presets) ~= "table" or type(Presets.Strong) ~= "table" then
		return finish(nil, "Prometheus Strong preset is unavailable")
	end
	if type(Logger) == "table" then
		if type(Logger.LogLevel) == "table" then
			Logger.logLevel = Logger.LogLevel.Error or 0
		end
		Logger.debugCallback = function() end
		Logger.logCallback = function() end
		Logger.warnCallback = function() end
		Logger.errorCallback = function(...)
			const parts = {}
			for i = 1, select("#", ...) do
				parts[#parts + 1] = tostring(select(i, ...))
			end
			error(table.concat(parts, " "), 0)
		end
	end
	const config = {}
	for key, value in Presets.Strong do
		config[key] = value
	end
	config.LuaVersion = "LuaU"
	config.PrettyPrint = false
	config.Seed = math.max(1, math.floor(((os.clock() * 1000000) + os.time()) % 2147483646))
	local okPipeline, pipeline = pcall(Pipeline.fromConfig, Pipeline, config)
	if not okPipeline or type(pipeline) ~= "table" then
		return finish(nil, "Prometheus pipeline setup failed: "..tostring(pipeline))
	end
	local okApply, output = pcall(pipeline.apply, pipeline, source, "Executor/WeAreDevs-Prometheus")
	if not okApply or type(output) ~= "string" or output == "" then
		return finish(nil, "Prometheus obfuscation failed: "..tostring(output))
	end
	local recoveryPayload
	local okRecovery, recoveryResult = pcall(function()
		return NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.LZW92Encode(source))
	end)
	if okRecovery and type(recoveryResult) == "string" and recoveryResult ~= "" then
		recoveryPayload = recoveryResult
	end
	if type(recoveryPayload) ~= "string" or recoveryPayload == "" then
		return finish(nil, "Prometheus recovery payload generation failed")
	end

	local recoveryId
	if type(writefile) == "function" then
		pcall(function()
			if type(makefolder) == "function" then
				if type(isfolder) ~= "function" or not isfolder("Nameless-Admin") then makefolder("Nameless-Admin") end
				if type(isfolder) ~= "function" or not isfolder("Nameless-Admin/ExecutorPrometheusRecovery") then makefolder("Nameless-Admin/ExecutorPrometheusRecovery") end
			end
			local generatedId
			pcall(function()
				generatedId = game:GetService("HttpService"):GenerateGUID(false):gsub("[^%w%-]", "")
			end)
			if type(generatedId) ~= "string" or generatedId == "" then
				generatedId = tostring(os.time()).."-"..tostring(math.floor((os.clock() * 1000000) % 1000000000)).."-"..tostring(math.random(1, 999999999))
			end
			const recoveryPath = "Nameless-Admin/ExecutorPrometheusRecovery/"..generatedId..".txt"
			writefile(recoveryPath, recoveryPayload)
			recoveryId = generatedId
		end)
	end

	state.Obfuscating = false
	if type(recoveryId) == "string" and recoveryId ~= "" then
		return "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V2:"..recoveryId.."]]\n"..output
	end
	return "--[[NA_OBF:WRD_PROMETHEUS_RECOVERY_V1:"..recoveryPayload.."]]\n"..output
end

NAStuff.ExecutorCodec.Obfuscate = NAStuff.ExecutorCodec.Obfuscate or function(source, mode)
	source = tostring(source or "")
	mode = tostring(mode or "auto"):lower():gsub("[%s%-%_]+", "")
	const aliases = {
		light = "base64", b4 = "base4", b36 = "base36", b62 = "base62", b64 = "base64", b64url = "base64url", b32 = "base32",
		dec = "decimal", bin = "binary", oct = "octal", rev = "reverse64", reverse = "reverse64", reversebytes64 = "reversebytes",
		pair = "pairswap", rot = "rot13", shift64 = "shift", comp = "complement", nibble64 = "nibble", rol = "rotate",
		idxor = "indexxor", idxshift = "indexshift", bitrev = "bitreverse", rxor = "repeatxor", delta64 = "delta", rle64 = "rle",
		lzw = "lzw92", lzw64 = "lzw92base64", js = "jscamo", javascript = "jscamo", jsstrong = "jscamostrong", python = "pycamo", py = "pycamo", pystrong = "pycamostrong", wrd = "wearedevs", prometheus = "wearedevs", wrdprometheus = "wearedevs", ultra = "ultra"
	}
	mode = aliases[mode] or mode
	if mode == "auto" then
		if #source <= 70000 then mode = "ultra"
		elseif #source <= 180000 then mode = "strong"
		else mode = "balanced" end
	end
	const valid = {
		base4=true, base36=true, base62=true, base64=true, base64url=true, base32=true, z85=true, hex=true, percent=true, decimal=true, binary=true, octal=true,
		reverse64=true, reversebytes=true, pairswap=true, rot13=true, shift=true, complement=true, nibble=true, rotate=true, indexxor=true, indexshift=true,
		affine=true, bitreverse=true, gray=true, xor=true, repeatxor=true, delta=true, rle=true, lzw92=true, lzw92base64=true, jscamo=true, jscamostrong=true, pycamo=true, pycamostrong=true, wearedevs=true, balanced=true, strong=true, ultra=true
	}
	if not valid[mode] then return nil, nil, "Unsupported obfuscation method" end

	local key = math.floor((os.clock() * 100000) % 223) + 17
	if key > 255 then key = 251 end
	const repeatKey = "NA"..string.format("%X", math.floor((os.clock() * 1000000) % 16777215)).."X"

	if mode == "base4" then
		const payload = NAStuff.ExecutorCodec.Base4Encode(source)
		return '--[[NA_OBF:B4]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase4Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base4 bytes"
	elseif mode == "base36" then
		const payload = NAStuff.ExecutorCodec.Base36Encode(source)
		return '--[[NA_OBF:B36]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase36Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base36 bytes"
	elseif mode == "base62" then
		const payload = NAStuff.ExecutorCodec.Base62Encode(source)
		return '--[[NA_OBF:B62]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase62Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base62 bytes"
	elseif mode == "base64" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(source)
		return '--[[NA_OBF:B64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base64"
	elseif mode == "base64url" then
		const payload = NAStuff.ExecutorCodec.Base64UrlEncode(source)
		return '--[[NA_OBF:B64URL]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64UrlDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base64URL"
	elseif mode == "base32" then
		const payload = NAStuff.ExecutorCodec.Base32Encode(source)
		return '--[[NA_OBF:B32]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase32Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Base32"
	elseif mode == "z85" then
		local payload, originalLength = NAStuff.ExecutorCodec.Z85Encode(source)
		return '--[[NA_OBF:Z85]]\nlocal P="'..payload..'" local L='..tostring(originalLength)..' '..NAStuff.ExecutorCodec.MakeZ85Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Z85"
	elseif mode == "hex" then
		const payload = NAStuff.ExecutorCodec.HexEncode(source)
		return '--[[NA_OBF:HEX]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeHexDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Hex"
	elseif mode == "percent" then
		const payload = NAStuff.ExecutorCodec.PercentEncode(source)
		return '--[[NA_OBF:PERCENT]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakePercentDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Percent bytes"
	elseif mode == "decimal" then
		const payload = NAStuff.ExecutorCodec.DecimalEncode(source)
		return '--[[NA_OBF:DEC]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeDecimalDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Decimal bytes"
	elseif mode == "binary" then
		const payload = NAStuff.ExecutorCodec.BinaryEncode(source)
		return '--[[NA_OBF:BIN]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBinaryDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Binary bytes"
	elseif mode == "octal" then
		const payload = NAStuff.ExecutorCodec.OctalEncode(source)
		return '--[[NA_OBF:OCT]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeOctalDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "Octal bytes"
	elseif mode == "reverse64" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(source):reverse()
		return '--[[NA_OBF:REV64]]\nlocal P="'..payload..'" P=P:reverse() '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.UniversalRunTail), "Reverse Base64"
	elseif mode == "pairswap" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.PairSwap(source))
		return '--[[NA_OBF:PAIR64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakePairSwapDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Pair swap+Base64"
	elseif mode == "reversebytes" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(source:reverse())
		return '--[[NA_OBF:REVB64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder('D=D:reverse();'..NAStuff.ExecutorCodec.UniversalRunTail), "Reversed bytes+Base64"
	elseif mode == "indexxor" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.IndexXor(source))
		return '--[[NA_OBF:IDXOR64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeIndexXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Index XOR+Base64"
	elseif mode == "indexshift" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.IndexShift(source, false))
		return '--[[NA_OBF:IDSHIFT64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeIndexShiftDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Index shift+Base64"
	elseif mode == "affine" then
		const affineAdd = key
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.AffineEncode(source, affineAdd))
		return '--[[NA_OBF:AFFINE64]]\nlocal P="'..payload..'" local K='..tostring(affineAdd)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeAffineDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Affine bytes+Base64"
	elseif mode == "bitreverse" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.BitReverse(source))
		return '--[[NA_OBF:BITREV64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeBitReverseDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Bit reverse+Base64"
	elseif mode == "gray" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.GrayEncode(source))
		return '--[[NA_OBF:GRAY64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeGrayDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Gray code+Base64"
	elseif mode == "rot13" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Rot13(source))
		return '--[[NA_OBF:ROT13_64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRot13Decoder(NAStuff.ExecutorCodec.UniversalRunTail)), "ROT13+Base64"
	elseif mode == "shift" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.ByteShift(source, key))
		return '--[[NA_OBF:SHIFT64]]\nlocal P="'..payload..'" local K='..tostring(key)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeShiftDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Byte shift+Base64"
	elseif mode == "complement" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Complement(source))
		return '--[[NA_OBF:COMP64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeComplementDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Byte complement+Base64"
	elseif mode == "nibble" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.NibbleSwap(source))
		return '--[[NA_OBF:NIBBLE64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeNibbleDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Nibble swap+Base64"
	elseif mode == "rotate" then
		const rotateBy = 3
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RotateLeft(source, rotateBy))
		return '--[[NA_OBF:ROL64]]\nlocal P="'..payload..'" local K='..tostring(rotateBy)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRotateDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Bit rotate+Base64"
	elseif mode == "xor" or mode == "balanced" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(source, key))
		return '--[[NA_OBF:XOR64]]\nlocal P="'..payload..'" local K='..tostring(key)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), mode == "balanced" and "Balanced" or "XOR+Base64"
	elseif mode == "repeatxor" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RepeatXor(source, repeatKey))
		return '--[[NA_OBF:RXOR64]]\nlocal P="'..payload..'" local K="'..repeatKey..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Repeating XOR+Base64"
	elseif mode == "delta" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.DeltaEncode(source))
		return '--[[NA_OBF:DELTA64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeDeltaDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "Delta bytes+Base64"
	elseif mode == "rle" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RLEEncode(source))
		return '--[[NA_OBF:RLE64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeRLEDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "RLE+Base64"
	elseif mode == "jscamo" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(source, key))
		return NAStuff.ExecutorCodec.MakeJavaScriptCamouflage(payload, key, false, #source), "JavaScript Camouflage"
	elseif mode == "jscamostrong" then
		const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.RepeatXor(packed, repeatKey))
		return NAStuff.ExecutorCodec.MakeJavaScriptCamouflage(payload, repeatKey, true, #source), "JavaScript Camouflage Strong"
	elseif mode == "pycamo" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(source, key))
		return NAStuff.ExecutorCodec.MakePythonCamouflage(payload, key, false, #source), "Python Camouflage"
	elseif mode == "pycamostrong" then
		const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
		const payload = NAStuff.ExecutorCodec.Base32Encode(NAStuff.ExecutorCodec.RepeatXor(packed, repeatKey))
		return NAStuff.ExecutorCodec.MakePythonCamouflage(payload, repeatKey, true, #source), "Python Camouflage Strong"
	elseif mode == "lzw92" then
		const payload = NAStuff.ExecutorCodec.LZW92Encode(source)
		return '--[[NA_OBF:LZW92]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeDirectLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail), "LZW92"
	elseif mode == "lzw92base64" then
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.LZW92Encode(source))
		return '--[[NA_OBF:LZW92_B64]]\nlocal P="'..payload..'" '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail)), "LZW92+Base64"
	elseif mode == "strong" then
		const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
		const payload = NAStuff.ExecutorCodec.Base64Encode(NAStuff.ExecutorCodec.Xor(packed, key))
		return '--[[NA_OBF:LZW92_XOR64]]\nlocal P="'..payload..'" local K='..tostring(key)..' '..NAStuff.ExecutorCodec.MakeBase64Decoder(NAStuff.ExecutorCodec.MakeXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail))), "Strong"
	elseif mode == "wearedevs" then
		local output, err = NAStuff.ExecutorCodec.PrometheusObfuscate(source)
		if type(output) ~= "string" or output == "" then
			return nil, nil, err or "WeAreDevs/Prometheus obfuscation failed"
		end
		return output, "WeAreDevs / Prometheus Strong"
	end

	const packed = NAStuff.ExecutorCodec.LZW92Encode(source)
	const payload = NAStuff.ExecutorCodec.Base32Encode(NAStuff.ExecutorCodec.RepeatXor(packed, repeatKey))
	return '--[[NA_OBF:LZW92_RXOR32]]\nlocal P="'..payload..'" local K="'..repeatKey..'" '..NAStuff.ExecutorCodec.MakeBase32Decoder(NAStuff.ExecutorCodec.MakeRepeatXorDecoder(NAStuff.ExecutorCodec.MakeLZWDecoder(NAStuff.ExecutorCodec.UniversalRunTail))), "Ultra"
end

NAmanage.Executor_Init = NAmanage.Executor_Init or function()
	if not (NAUIMANAGER and NAUIMANAGER.ExecutorFrame and NAUIMANAGER.ExecutorContainer) then
		return false
	end

	const frame = NAUIMANAGER.ExecutorFrame
	const container = NAUIMANAGER.ExecutorContainer
	if frame.GetAttribute and NAmanage.GetAttr(frame, "NAExecutorReady") then
		return true
	end
	if frame.SetAttribute then
		NAmanage.SetAttr(frame, "NAExecutorReady", true)
	end

	for _, child in container:GetChildren() do
		child:Destroy()
	end

	const TextServiceRef = Services.TextService
	const UserInputServiceRef = Services.UserInputService
	const GuiServiceRef = Services.GuiService
	const execResponsive = {
		compact = false,
		phone = false,
		lastW = 0,
		lastH = 0,
	}
	const execSizeXAttr = "NAExecutorSavedSizeX"
	const execSizeYAttr = "NAExecutorSavedSizeY"
	const function saveExecutorFrameSize()
		if not (frame and frame.Parent and frame.SetAttribute) then
			return
		end
		if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
			return
		end
		const w = tonumber(frame.Size.X.Offset) or 0
		const h = tonumber(frame.Size.Y.Offset) or 0
		if w > 0 and h > 0 then
			NAmanage.SetAttr(frame, execSizeXAttr, math.floor(w + 0.5))
			NAmanage.SetAttr(frame, execSizeYAttr, math.floor(h + 0.5))
		end
	end
	const function getExecutorSavedSize()
		if frame and frame.GetAttribute then
			const w = tonumber(NAmanage.GetAttr(frame, execSizeXAttr))
			const h = tonumber(NAmanage.GetAttr(frame, execSizeYAttr))
			if w and h and w > 0 and h > 0 then
				return w, h
			end
		end
		return nil
	end
	NAmanage.Executor_SaveFrameSize = saveExecutorFrameSize
	const baseExecDir = "Nameless-Admin"
	const execDir = baseExecDir.."/NA-Exec"
	const settingsFile = execDir.."/settings.json"
	const tabsFile = execDir.."/tabs.json"
	const indexFile = execDir.."/scripts.json"
	const scriptsDir = execDir.."/Scripts"
	const folderApiOk = type(isfolder) == "function"
		and type(makefolder) == "function"
	const fsOk = type(isfile) == "function"
		and type(readfile) == "function"
		and type(writefile) == "function"
	const delOk = type(delfile) == "function"
	const listOk = type(listfiles) == "function"
	const cfg = {
		syntax = true,
		lineNumbers = true,
		showHub = true,
		runInCurrentThread = false,
		threadIdentity = false,
		identityLevel = 8,
		profileExecution = false,
		fontSize = 15,
	}
	const colors = {
		panel = Color3.fromRGB(17, 17, 21),
		panel2 = Color3.fromRGB(24, 24, 30),
		panel3 = Color3.fromRGB(31, 31, 38),
		stroke = Color3.fromRGB(72, 72, 82),
		text = Color3.fromRGB(235, 235, 242),
		subtle = Color3.fromRGB(170, 170, 180),
		tabIdle = Color3.fromRGB(27, 27, 34),
		tabActive = Color3.fromRGB(40, 40, 52),
		tabTextIdle = Color3.fromRGB(178, 178, 190),
		tabTextActive = Color3.fromRGB(241, 241, 248),
		lineNumber = Color3.fromRGB(125, 125, 140),
		code = Color3.fromRGB(230, 230, 236),
		keyword = Color3.fromRGB(255, 171, 247),
		global = Color3.fromRGB(132, 203, 255),
		string = Color3.fromRGB(166, 226, 128),
		comment = Color3.fromRGB(112, 122, 132),
		number = Color3.fromRGB(255, 214, 112),
		func = Color3.fromRGB(130, 230, 210),
		method = Color3.fromRGB(118, 194, 255),
		property = Color3.fromRGB(205, 194, 255),
		operator = Color3.fromRGB(255, 155, 190),
		bracket = Color3.fromRGB(210, 210, 225),
		success = Color3.fromRGB(156, 235, 174),
		warn = Color3.fromRGB(255, 214, 112),
		error = Color3.fromRGB(255, 146, 146),
	}
	const function makeCornerAndStroke(obj, radius, thickness)
		const corner = InstanceNew("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = obj
		const stroke = InstanceNew("UIStroke")
		stroke.Color = colors.stroke
		stroke.Transparency = 0.18
		stroke.Thickness = thickness or 1
		stroke.Parent = obj
		return corner, stroke
	end

	const function makeButton(parent, text, background)
		const button = InstanceNew("TextButton")
		button.AutoButtonColor = false
		button.BackgroundColor3 = background or colors.panel3
		button.BorderSizePixel = 0
		button.Font = Enum.Font.GothamSemibold
		button.Text = text
		button.TextColor3 = colors.text
		button.TextSize = 13
		button.Parent = parent
		makeCornerAndStroke(button, 8, 1)
		button.MouseEnter:Connect(function()
			Services.TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = (background or colors.panel3):Lerp(Color3.new(1, 1, 1), 0.06)
			}):Play()
		end)
		button.MouseLeave:Connect(function()
			local targetColor = background or colors.panel3
			if button.GetAttribute and NAmanage.GetAttr(button, "NAExecutorSelected") then
				targetColor = colors.tabActive
			end
			Services.TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetColor
			}):Play()
		end)
		return button
	end

	const function isScriptFileName(name)
		const low = tostring(name or ""):lower()
		return low:match("%.lua$") ~= nil or low:match("%.luau$") ~= nil or low:match("%.txt$") ~= nil
	end

	const function sanitizeScriptName(name)
		name = tostring(name or "")
		name = name:gsub('[\\/:*?"<>|]', "")
		name = name:gsub("%s+", " ")
		name = name:gsub("^%s+", ""):gsub("%s+$", "")
		if name == "" then
			name = "script"
		end
		if not isScriptFileName(name) then
			name ..= ".luau"
		end
		return name
	end

	const function stripLuauExt(name)
		return tostring(name or ""):gsub("%.luau$", ""):gsub("%.lua$", ""):gsub("%.txt$", "")
	end

	const function scriptPath(name)
		return scriptsDir.."/"..sanitizeScriptName(name)
	end

	local ensureExecutorFolders

	const function readScriptIndex()
		const list = {}
		if not (fsOk and isfile(indexFile)) then
			return list
		end
		local ok, raw = pcall(readfile, indexFile)
		if not ok or type(raw) ~= "string" or raw == "" then
			return list
		end
		local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
		if okDecode and type(decoded) == "table" then
			for _, value in decoded do
				if type(value) == "string" and value ~= "" then
					list[#list + 1] = sanitizeScriptName(value)
				end
			end
		end
		return list
	end

	const function saveScriptIndex(names)
		if not ensureExecutorFolders() then
			return false
		end
		const seen = {}
		const clean = {}
		for _, name in names or {} do
			const fileName = sanitizeScriptName(name)
			const key = fileName:lower()
			if not seen[key] then
				seen[key] = true
				clean[#clean + 1] = fileName
			end
		end
		table.sort(clean, function(a, b)
			return a:lower() < b:lower()
		end)
		local ok, encoded = pcall(function()
			return Services.HttpService:JSONEncode(clean)
		end)
		if ok and encoded then
			return pcall(writefile, indexFile, encoded)
		end
		return false
	end

	const function addScriptIndex(name)
		const fileName = sanitizeScriptName(name)
		const names = readScriptIndex()
		local exists = false
		for _, item in names do
			if item:lower() == fileName:lower() then
				exists = true
				break
			end
		end
		if not exists then
			names[#names + 1] = fileName
		end
		saveScriptIndex(names)
	end

	const function removeScriptIndex(name)
		const fileName = sanitizeScriptName(name)
		const names = readScriptIndex()
		for i = #names, 1, -1 do
			if names[i]:lower() == fileName:lower() then
				table.remove(names, i)
			end
		end
		saveScriptIndex(names)
	end

	const function setStatus(message, color)
		NAStuff.ExecutorStatusText = message or "Ready"
		NAStuff.ExecutorStatusColor = color or colors.subtle
		if not NAStuff.ExecutorStatusLabel then
			return
		end
		pcall(function()
			if typeof(NAStuff.ExecutorStatusLabel) == "Instance" and NAStuff.ExecutorStatusLabel.Parent then
				NAStuff.ExecutorStatusLabel.Text = NAStuff.ExecutorStatusText
				NAStuff.ExecutorStatusLabel.TextColor3 = NAStuff.ExecutorStatusColor
			end
		end)
	end

	function ensureExecutorFolders()
		if not fsOk then
			return false
		end
		if not folderApiOk then
			return true
		end
		local ok = true
		const function mk(path)
			if not ok then
				return
			end
			local has = false
			local okCheck, result = pcall(isfolder, path)
			if okCheck and result == true then
				has = true
			end
			if not has then
				const okMake = pcall(makefolder, path)
				if not okMake then
					ok = false
				end
			end
		end
		mk(baseExecDir)
		mk(execDir)
		mk(scriptsDir)
		return ok
	end

	if fsOk then
		ensureExecutorFolders()
		pcall(function()
			if isfile(settingsFile) then
				const raw = readfile(settingsFile)
				if raw and raw ~= "" then
					local ok, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
					if ok and type(decoded) == "table" then
						if type(decoded.syntax) == "boolean" then cfg.syntax = decoded.syntax end
						if type(decoded.lineNumbers) == "boolean" then cfg.lineNumbers = decoded.lineNumbers end
						if type(decoded.showHub) == "boolean" then cfg.showHub = decoded.showHub end
						if type(decoded.scriptHub) == "boolean" then cfg.showHub = decoded.scriptHub end
						if type(decoded.runInCurrentThread) == "boolean" then cfg.runInCurrentThread = decoded.runInCurrentThread end
						if type(decoded.threadIdentity) == "boolean" then cfg.threadIdentity = decoded.threadIdentity end
						if type(decoded.profileExecution) == "boolean" then cfg.profileExecution = decoded.profileExecution end
						if tonumber(decoded.identityLevel) then cfg.identityLevel = math.clamp(math.floor(tonumber(decoded.identityLevel) + 0.5), 0, 8) end
						if tonumber(decoded.fontSize) then cfg.fontSize = math.clamp(math.floor(tonumber(decoded.fontSize) + 0.5), 11, 24) end
					end
				end
			end
		end)
	end

	const function saveSettings()
		if not fsOk then
			return false
		end
		if not ensureExecutorFolders() then
			return false
		end
		const payload = {
			syntax = cfg.syntax == true,
			lineNumbers = cfg.lineNumbers == true,
			showHub = cfg.showHub ~= false,
			scriptHub = cfg.showHub ~= false,
			runInCurrentThread = cfg.runInCurrentThread == true,
			threadIdentity = cfg.threadIdentity == true,
			identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8),
			profileExecution = cfg.profileExecution == true,
			fontSize = math.clamp(math.floor((tonumber(cfg.fontSize) or 15) + 0.5), 11, 24),
		}
		local ok, encoded = pcall(function()
			return Services.HttpService:JSONEncode(payload)
		end)
		if ok and encoded then
			const wrote = pcall(writefile, settingsFile, encoded)
			return wrote == true
		end
		return false
	end

	const function getExecutorViewport()
		const screenGui = NAStuff and NAStuff.NASCREENGUI
		if screenGui and screenGui.AbsoluteSize and screenGui.AbsoluteSize.X > 0 and screenGui.AbsoluteSize.Y > 0 then
			return screenGui.AbsoluteSize
		end
		const cam = Services.Workspace and Services.Workspace.CurrentCamera
		if cam and cam.ViewportSize and cam.ViewportSize.X > 0 and cam.ViewportSize.Y > 0 then
			return cam.ViewportSize
		end
		return Vector2.new(1280, 720)
	end

	const function getSafePad()
		local x, y = 12, 12
		if GuiServiceRef and GuiServiceRef.GetGuiInset then
			local ok, a, b = pcall(function()
				return GuiServiceRef:GetGuiInset()
			end)
			if ok and typeof(a) == "Vector2" and typeof(b) == "Vector2" then
				x += math.max(a.X, b.X)
				y += math.max(a.Y, b.Y)
			end
		end
		return x, y
	end

	const function isTouchCompact(vp)
		const touch = UserInputServiceRef and UserInputServiceRef.TouchEnabled
		const mouse = UserInputServiceRef and UserInputServiceRef.MouseEnabled
		const key = UserInputServiceRef and UserInputServiceRef.KeyboardEnabled
		return IsOnMobile or vp.Y < 600 or vp.X < 900 or (touch and not (mouse or key))
	end

	const function getExecutorSize(vp)
		local padX, padY = getSafePad()
		const maxW = math.max(1, math.floor(vp.X - padX * 2 + 0.5))
		const maxH = math.max(1, math.floor(vp.Y - padY * 2 + 0.5))
		const mobile = isTouchCompact(vp)
		const baseW, baseH = 920, 540
		local capW = mobile and math.floor(maxW * 0.90 + 0.5) or math.min(baseW, maxW)
		local capH = mobile and math.floor(maxH * 0.90 + 0.5) or math.min(baseH, maxH)
		capW = math.max(1, capW)
		capH = math.max(1, capH)
		local scale = math.min(capW / baseW, capH / baseH, 1)
		if not scale or scale <= 0 then
			scale = 1
		end
		local w = math.floor(baseW * scale + 0.5)
		local h = math.floor(baseH * scale + 0.5)
		const minW = math.min(mobile and 340 or 680, capW)
		const minH = math.min(mobile and 280 or 420, capH)
		w = math.clamp(w, minW, capW)
		h = math.clamp(h, minH, capH)
		return w, h, capW, capH, mobile
	end

	const function applyExecutorFrameSize(center)
		if not frame or not frame.Parent then
			return
		end
		if frame.GetAttribute and NAmanage.GetAttr(frame, "NAMenuMinimized") == true then
			return
		end
		const vp = getExecutorViewport()
		local defW, defH, capW, capH, mobile = getExecutorSize(vp)
		const initialized = frame.GetAttribute and NAmanage.GetAttr(frame, "NAExecutorDefaultSized") == true
		const minW = math.min(mobile and 340 or 680, capW)
		const minH = math.min(mobile and 280 or 420, capH)
		const curW = tonumber(frame.Size.X.Offset) or 0
		const curH = tonumber(frame.Size.Y.Offset) or 0
		local savedW, savedH = getExecutorSavedSize()
		local targetW = defW
		local targetH = defH
		if savedW and savedH then
			targetW = math.clamp(math.floor(savedW + 0.5), minW, capW)
			targetH = math.clamp(math.floor(savedH + 0.5), minH, capH)
		elseif initialized and curW > 0 and curH > 0 then
			targetW = math.clamp(math.floor(curW + 0.5), minW, capW)
			targetH = math.clamp(math.floor(curH + 0.5), minH, capH)
			if mobile and (targetW >= capW * 0.96 or targetW / math.max(targetH, 1) > 1.95 or targetH < defH * 0.82) then
				targetW = defW
				targetH = defH
			end
		end
		execResponsive.compact = targetW < 760 or targetH < 430
		execResponsive.phone = targetW < 560
		execResponsive.lastW = targetW
		execResponsive.lastH = targetH
		frame.AnchorPoint = Vector2.new(0, 0)
		if frame.AbsoluteSize.X ~= targetW or frame.AbsoluteSize.Y ~= targetH then
			frame.Size = UDim2.fromOffset(targetW, targetH)
		end
		if frame.SetAttribute then
			NAmanage.SetAttr(frame, "NAExecutorDefaultSized", true)
		end
		saveExecutorFrameSize()
		if center == true and NAmanage.centerFrame then
			NAmanage.centerFrame(frame)
		end
	end
	NAmanage.Executor_ApplyResponsive = applyExecutorFrameSize
	const rootPad = InstanceNew("UIPadding")
	rootPad.PaddingBottom = UDim.new(0, 10)
	rootPad.PaddingLeft = UDim.new(0, 10)
	rootPad.PaddingRight = UDim.new(0, 10)
	rootPad.PaddingTop = UDim.new(0, 10)
	rootPad.Parent = container

	const topbar = frame:FindFirstChild("Topbar")
	local settingsButton = topbar and topbar:FindFirstChild("Settings")
	if settingsButton then
		settingsButton.AnchorPoint = Vector2.new(1, 0.5)
		settingsButton.Position = UDim2.new(1, -112, 0.5, 0)
	end
	if topbar and not settingsButton then
		settingsButton = InstanceNew("TextButton")
		settingsButton.Name = "Settings"
		settingsButton.Parent = topbar
		settingsButton.BorderSizePixel = 0
		settingsButton.TextSize = 15
		settingsButton.TextColor3 = Color3.fromRGB(245, 245, 245)
		settingsButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
		settingsButton.Font = Enum.Font.Gotham
		settingsButton.AnchorPoint = Vector2.new(1, 0.5)
		settingsButton.BackgroundTransparency = 0.3
		settingsButton.Size = UDim2.new(0, 24, 0, 24)
		settingsButton.Text = "S"
		settingsButton.Position = UDim2.new(1, -112, 0.5, 0)
		makeCornerAndStroke(settingsButton, 6, 2)
	end

	const tabsBar = InstanceNew("Frame")
	tabsBar.Name = "TabsBar"
	tabsBar.BackgroundTransparency = 1
	tabsBar.BorderSizePixel = 0
	tabsBar.Position = UDim2.new(0, 0, 0, 0)
	tabsBar.Size = UDim2.new(1, 0, 0, 34)
	tabsBar.Parent = container

	const tabScroll = InstanceNew("ScrollingFrame")
	tabScroll.Name = "Tabs"
	tabScroll.Active = true
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScroll.Position = UDim2.new(0, 0, 0, 0)
	tabScroll.ScrollBarImageColor3 = colors.subtle
	tabScroll.ScrollBarThickness = 3
	tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
	tabScroll.Size = UDim2.new(1, -42, 1, 0)
	tabScroll.Parent = tabsBar

	const tabWrap = InstanceNew("Frame")
	tabWrap.Name = "Wrap"
	tabWrap.BackgroundTransparency = 1
	tabWrap.BorderSizePixel = 0
	tabWrap.Position = UDim2.new(0, 0, 0, 0)
	tabWrap.Size = UDim2.new(0, 0, 1, 0)
	tabWrap.Parent = tabScroll

	const tabLayout = InstanceNew("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Parent = tabWrap

	const addTabButton = makeButton(tabsBar, "+", colors.panel3)
	addTabButton.Name = "AddTab"
	addTabButton.Position = UDim2.new(1, -34, 0, 1)
	addTabButton.Size = UDim2.new(0, 34, 0, 28)
	addTabButton.TextSize = 18

	const body = InstanceNew("Frame")
	body.Name = "Body"
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.Position = UDim2.new(0, 0, 0, 42)
	body.Size = UDim2.new(1, 0, 1, -92)
	body.Parent = container

	const editorPane = InstanceNew("Frame")
	editorPane.Name = "EditorPane"
	editorPane.BackgroundColor3 = colors.panel
	editorPane.BorderSizePixel = 0
	editorPane.Position = UDim2.new(0, 0, 0, 0)
	editorPane.Size = UDim2.new(1, -252, 1, 0)
	editorPane.Parent = body
	makeCornerAndStroke(editorPane, 10, 1)

	const hubPane = InstanceNew("Frame")
	hubPane.Name = "ScriptHub"
	hubPane.BackgroundColor3 = colors.panel
	hubPane.BorderSizePixel = 0
	hubPane.Position = UDim2.new(1, -242, 0, 0)
	hubPane.Size = UDim2.new(0, 242, 1, 0)
	hubPane.Parent = body
	makeCornerAndStroke(hubPane, 10, 1)

	const editorPad = InstanceNew("UIPadding")
	editorPad.PaddingBottom = UDim.new(0, 8)
	editorPad.PaddingLeft = UDim.new(0, 8)
	editorPad.PaddingRight = UDim.new(0, 8)
	editorPad.PaddingTop = UDim.new(0, 8)
	editorPad.Parent = editorPane

	const gutter = InstanceNew("Frame")
	gutter.Name = "Gutter"
	gutter.BackgroundColor3 = colors.panel2
	gutter.BorderSizePixel = 0
	gutter.Position = UDim2.new(0, 0, 0, 0)
	gutter.Size = UDim2.new(0, 44, 1, 0)
	gutter.Parent = editorPane
	makeCornerAndStroke(gutter, 8, 1)

	const gutterClip = InstanceNew("Frame")
	gutterClip.BackgroundTransparency = 1
	gutterClip.BorderSizePixel = 0
	gutterClip.ClipsDescendants = true
	gutterClip.Size = UDim2.new(1, 0, 1, 0)
	gutterClip.Parent = gutter

	const gutterLabel = InstanceNew("TextLabel")
	gutterLabel.Name = "Lines"
	gutterLabel.AnchorPoint = Vector2.new(1, 0)
	gutterLabel.BackgroundTransparency = 1
	gutterLabel.BorderSizePixel = 0
	gutterLabel.Font = Enum.Font.Code
	gutterLabel.Position = UDim2.new(1, -6, 0, 0)
	gutterLabel.Size = UDim2.new(1, -10, 0, 0)
	gutterLabel.Text = "1"
	gutterLabel.TextColor3 = colors.lineNumber
	gutterLabel.TextSize = 15
	gutterLabel.TextXAlignment = Enum.TextXAlignment.Right
	gutterLabel.TextYAlignment = Enum.TextYAlignment.Top
	gutterLabel.Parent = gutterClip

	const editorScroll = InstanceNew("ScrollingFrame")
	editorScroll.Name = "Scroll"
	editorScroll.Active = true
	editorScroll.BackgroundColor3 = colors.panel
	editorScroll.BorderSizePixel = 0
	editorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	editorScroll.Position = UDim2.new(0, 50, 0, 0)
	editorScroll.ScrollBarImageColor3 = colors.subtle
	editorScroll.ScrollBarThickness = 0
	editorScroll.ScrollingDirection = Enum.ScrollingDirection.XY
	editorScroll.Size = UDim2.new(1, -50, 1, 0)
	editorScroll.Parent = editorPane
	makeCornerAndStroke(editorScroll, 8, 1)

	const editorLineScroll = InstanceNew("ScrollingFrame")
	editorLineScroll.Name = "LineScrollProxy"
	editorLineScroll.Active = false
	editorLineScroll.BackgroundTransparency = 1
	editorLineScroll.BorderSizePixel = 0
	editorLineScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	editorLineScroll.Position = editorScroll.Position
	editorLineScroll.ScrollBarThickness = 0
	editorLineScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	editorLineScroll.Size = editorScroll.Size
	editorLineScroll.Visible = false
	editorLineScroll.Parent = editorPane

	const function makeEditorScrollBar(parent, name, axis)
		const horizontal = axis == "X"
		const bar = InstanceNew("Frame")
		bar.Name = name
		bar.BackgroundColor3 = colors.panel2
		bar.BorderSizePixel = 0
		bar.Visible = false
		bar.ZIndex = 35
		bar.Parent = parent
		makeCornerAndStroke(bar, 7, 1)

		const upButton = InstanceNew("TextButton")
		upButton.Name = horizontal and "Left" or "Up"
		upButton.AutoButtonColor = false
		upButton.BackgroundColor3 = colors.panel3
		upButton.BorderSizePixel = 0
		upButton.Font = Enum.Font.GothamBold
		upButton.Text = horizontal and "<" or "^"
		upButton.TextColor3 = colors.text
		upButton.TextSize = 10
		upButton.ZIndex = 36
		upButton.Parent = bar
		makeCornerAndStroke(upButton, 5, 1)

		const downButton = InstanceNew("TextButton")
		downButton.Name = horizontal and "Right" or "Down"
		downButton.AutoButtonColor = false
		downButton.BackgroundColor3 = colors.panel3
		downButton.BorderSizePixel = 0
		downButton.Font = Enum.Font.GothamBold
		downButton.Text = horizontal and ">" or "v"
		downButton.TextColor3 = colors.text
		downButton.TextSize = 10
		downButton.ZIndex = 36
		downButton.Parent = bar
		makeCornerAndStroke(downButton, 5, 1)

		const track = InstanceNew("Frame")
		track.Name = "Track"
		track.BackgroundColor3 = colors.panel
		track.BorderSizePixel = 0
		track.ZIndex = 36
		track.Parent = bar
		makeCornerAndStroke(track, 5, 1)

		const thumb = InstanceNew("Frame")
		thumb.Name = "Thumb"
		thumb.BackgroundColor3 = colors.subtle
		thumb.BorderSizePixel = 0
		thumb.ZIndex = 37
		thumb.Parent = track
		makeCornerAndStroke(thumb, 5, 1)

		if horizontal then
			bar.Size = UDim2.new(0, 120, 0, 16)
			upButton.Position = UDim2.new(0, 0, 0, 0)
			upButton.Size = UDim2.new(0, 16, 1, 0)
			downButton.AnchorPoint = Vector2.new(1, 0)
			downButton.Position = UDim2.new(1, 0, 0, 0)
			downButton.Size = UDim2.new(0, 16, 1, 0)
			track.Position = UDim2.new(0, 18, 0, 0)
			track.Size = UDim2.new(1, -36, 1, 0)
		else
			bar.Size = UDim2.new(0, 16, 0, 120)
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

	const editorVScroll = makeEditorScrollBar(editorPane, "CustomScrollBar", "Y")
	const editorHScroll = makeEditorScrollBar(editorPane, "CustomHorizontalScrollBar", "X")
	local editorGetVisibleLines
	local editorGetTotalLines
	local editorGetViewLine
	local editorSetViewLine

	const function layoutEditorScrollBar(_, target, widgets)
		const bar = widgets and widgets.bar
		if not (target and bar and bar.Parent) then
			return
		end
		const parentPos = bar.Parent.AbsolutePosition
		const relX = math.floor(target.AbsolutePosition.X - parentPos.X + 0.5)
		const relY = math.floor(target.AbsolutePosition.Y - parentPos.Y + 0.5)
		const w = math.floor(target.AbsoluteSize.X + 0.5)
		const h = math.floor(target.AbsoluteSize.Y + 0.5)
		if bar == editorHScroll.bar then
			bar.Position = UDim2.new(0, relX, 0, relY + h - 16)
			bar.Size = UDim2.new(0, math.max(48, w - 18), 0, 16)
		else
			bar.Position = UDim2.new(0, relX + w - 16, 0, relY)
			bar.Size = UDim2.new(0, 16, 0, math.max(48, h - 18))
		end
	end

	const executorVerticalScroll = NAmanage.CustomScroll and NAmanage.CustomScroll.create and NAmanage.CustomScroll.create("executor_editor_v", {
		getWidgets = function()
			return editorVScroll
		end,
		getTarget = function()
			return editorScroll
		end,
		getVisibleSpace = function()
			return editorGetVisibleLines and editorGetVisibleLines() or 1
		end,
		getTotalSpace = function()
			return editorGetTotalLines and editorGetTotalLines() or 1
		end,
		getPosition = function()
			return math.max(0, (editorGetViewLine and editorGetViewLine() or 1) - 1)
		end,
		setPosition = function(_, _, pos)
			if editorSetViewLine then
				editorSetViewLine(math.floor((tonumber(pos) or 0) + 1.5))
			end
		end,
		layoutForTarget = layoutEditorScrollBar,
		step = 3,
	})
	const executorHorizontalScroll = NAmanage.CustomScroll and NAmanage.CustomScroll.create and NAmanage.CustomScroll.create("executor_editor_h", {
		axis = "X",
		getWidgets = function()
			return editorHScroll
		end,
		getTarget = function()
			return editorScroll
		end,
		layoutForTarget = layoutEditorScrollBar,
		step = 96,
	})
	if executorVerticalScroll and executorVerticalScroll.install then
		executorVerticalScroll.install()
	end
	if executorHorizontalScroll and executorHorizontalScroll.install then
		executorHorizontalScroll.install()
	end

	const textBox = InstanceNew("TextBox")
	textBox.Name = "Source"
	textBox.BackgroundTransparency = 1
	textBox.BorderSizePixel = 0
	textBox.ClearTextOnFocus = false
	textBox.Font = Enum.Font.Code
	textBox.MultiLine = true
	textBox.PlaceholderColor3 = colors.subtle
	textBox.PlaceholderText = "-- Write your script here"
	textBox.Position = UDim2.new(0, 8, 0, 0)
	textBox.Size = UDim2.new(0, 320, 0, 200)
	textBox.Text = ""
	textBox.TextColor3 = colors.code
	textBox.TextSize = 15
	textBox.TextWrapped = false
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.TextYAlignment = Enum.TextYAlignment.Top
	textBox.Parent = editorScroll

	const function makeLayer(name, color, zIndex)
		const layer = InstanceNew("TextLabel")
		layer.Name = name
		layer.BackgroundTransparency = 1
		layer.BorderSizePixel = 0
		layer.Font = Enum.Font.Code
		layer.Position = textBox.Position
		layer.Size = textBox.Size
		layer.Text = ""
		layer.TextColor3 = color
		layer.TextSize = textBox.TextSize
		layer.TextWrapped = false
		layer.TextXAlignment = Enum.TextXAlignment.Left
		layer.TextYAlignment = Enum.TextYAlignment.Top
		layer.ZIndex = zIndex
		layer.Parent = editorScroll
		return layer
	end

	const keywordLayer = makeLayer("Keywords", colors.keyword, 4)
	const globalLayer = makeLayer("Globals", colors.global, 4)
	const stringLayer = makeLayer("Strings", colors.string, 4)
	const commentLayer = makeLayer("Comments", colors.comment, 4)
	const numberLayer = makeLayer("Numbers", colors.number, 4)
	const functionLayer = makeLayer("Functions", colors.func, 4)
	const methodLayer = makeLayer("Methods", colors.method, 4)
	const propertyLayer = makeLayer("Properties", colors.property, 4)
	const operatorLayer = makeLayer("Operators", colors.operator, 4)
	const bracketLayer = makeLayer("Brackets", colors.bracket, 4)
	textBox.ZIndex = 3

	const pagePanel = InstanceNew("Frame")
	pagePanel.Name = "PageControls"
	pagePanel.AnchorPoint = Vector2.new(1, 0)
	pagePanel.BackgroundColor3 = colors.panel2
	pagePanel.BorderSizePixel = 0
	pagePanel.Position = UDim2.new(1, -14, 0, 14)
	pagePanel.Size = UDim2.new(0, 210, 0, 28)
	pagePanel.ZIndex = 30
	pagePanel.Parent = editorPane
	makeCornerAndStroke(pagePanel, 8, 1)

	const pageLayout = InstanceNew("UIListLayout")
	pageLayout.FillDirection = Enum.FillDirection.Horizontal
	pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	pageLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 5)
	pageLayout.Parent = pagePanel

	const pagePad = InstanceNew("UIPadding")
	pagePad.PaddingLeft = UDim.new(0, 5)
	pagePad.PaddingRight = UDim.new(0, 5)
	pagePad.Parent = pagePanel

	const pagePrev = makeButton(pagePanel, "<", colors.panel3)
	pagePrev.LayoutOrder = 1
	pagePrev.Size = UDim2.new(0, 32, 0, 22)
	pagePrev.ZIndex = 31
	const pageLabel = InstanceNew("TextLabel")
	pageLabel.BackgroundTransparency = 1
	pageLabel.BorderSizePixel = 0
	pageLabel.Font = Enum.Font.GothamSemibold
	pageLabel.LayoutOrder = 2
	pageLabel.Size = UDim2.new(1, -74, 0, 22)
	pageLabel.Text = "Lines 1-1/1"
	pageLabel.TextColor3 = colors.subtle
	pageLabel.TextSize = 12
	pageLabel.TextXAlignment = Enum.TextXAlignment.Center
	pageLabel.ZIndex = 31
	pageLabel.Parent = pagePanel
	const pageNext = makeButton(pagePanel, ">", colors.panel3)
	pageNext.LayoutOrder = 3
	pageNext.Size = UDim2.new(0, 32, 0, 22)
	pageNext.ZIndex = 31

	const hubPad = InstanceNew("UIPadding")
	hubPad.PaddingBottom = UDim.new(0, 8)
	hubPad.PaddingLeft = UDim.new(0, 8)
	hubPad.PaddingRight = UDim.new(0, 8)
	hubPad.PaddingTop = UDim.new(0, 8)
	hubPad.Parent = hubPane

	const hubTitle = InstanceNew("TextLabel")
	hubTitle.BackgroundTransparency = 1
	hubTitle.BorderSizePixel = 0
	hubTitle.Font = Enum.Font.GothamBold
	hubTitle.Size = UDim2.new(1, 0, 0, 18)
	hubTitle.Text = "Saved Scripts"
	hubTitle.TextColor3 = colors.text
	hubTitle.TextSize = 15
	hubTitle.TextXAlignment = Enum.TextXAlignment.Left
	hubTitle.Parent = hubPane

	const hubSubtitle = InstanceNew("TextLabel")
	hubSubtitle.Name = "SelectedLabel"
	hubSubtitle.BackgroundTransparency = 1
	hubSubtitle.BorderSizePixel = 0
	hubSubtitle.Font = Enum.Font.Gotham
	hubSubtitle.Position = UDim2.new(0, 0, 0, 20)
	hubSubtitle.Size = UDim2.new(1, 0, 0, 14)
	hubSubtitle.Text = "No script selected"
	hubSubtitle.TextColor3 = colors.subtle
	hubSubtitle.TextSize = 11
	hubSubtitle.TextWrapped = true
	hubSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	hubSubtitle.Parent = hubPane

	const hubList = InstanceNew("ScrollingFrame")
	hubList.Name = "List"
	hubList.Active = true
	hubList.BackgroundColor3 = colors.panel2
	hubList.BorderSizePixel = 0
	hubList.CanvasSize = UDim2.new(0, 0, 0, 0)
	hubList.Position = UDim2.new(0, 0, 0, 42)
	hubList.ScrollBarImageColor3 = colors.subtle
	hubList.ScrollBarThickness = 5
	hubList.Size = UDim2.new(1, 0, 1, -204)
	hubList.Parent = hubPane
	makeCornerAndStroke(hubList, 8, 1)

	const hubListLayout = InstanceNew("UIListLayout")
	hubListLayout.Padding = UDim.new(0, 6)
	hubListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	hubListLayout.Parent = hubList

	const hubListPad = InstanceNew("UIPadding")
	hubListPad.PaddingBottom = UDim.new(0, 8)
	hubListPad.PaddingLeft = UDim.new(0, 8)
	hubListPad.PaddingRight = UDim.new(0, 8)
	hubListPad.PaddingTop = UDim.new(0, 8)
	hubListPad.Parent = hubList

	const hubButtons = InstanceNew("ScrollingFrame")
	hubButtons.Name = "Actions"
	hubButtons.Active = true
	hubButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y
	hubButtons.BackgroundTransparency = 1
	hubButtons.BorderSizePixel = 0
	hubButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
	hubButtons.ElasticBehavior = Enum.ElasticBehavior.Never
	hubButtons.Position = UDim2.new(0, 0, 1, -154)
	hubButtons.ScrollingDirection = Enum.ScrollingDirection.Y
	hubButtons.ScrollBarImageColor3 = colors.subtle
	hubButtons.ScrollBarThickness = 4
	hubButtons.Size = UDim2.new(1, 0, 0, 154)
	hubButtons.Parent = hubPane

	const hubButtonsLayout = InstanceNew("UIListLayout")
	hubButtonsLayout.Padding = UDim.new(0, 6)
	hubButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	hubButtonsLayout.Parent = hubButtons

	const hubButtonsPad = InstanceNew("UIPadding")
	hubButtonsPad.PaddingRight = UDim.new(0, 5)
	hubButtonsPad.Parent = hubButtons

	const hubOpen = makeButton(hubButtons, "Open In Tab", colors.panel3)
	hubOpen.Size = UDim2.new(1, 0, 0, 26)
	const hubOpenNew = makeButton(hubButtons, "Open In New Tab", colors.panel3)
	hubOpenNew.Size = UDim2.new(1, 0, 0, 26)
	const hubSave = makeButton(hubButtons, "Save Current Script", colors.panel3)
	hubSave.Size = UDim2.new(1, 0, 0, 26)
	const hubClear = makeButton(hubButtons, "Clear Selection", colors.panel3)
	hubClear.Size = UDim2.new(1, 0, 0, 26)
	const hubNew = makeButton(hubButtons, "New Script Tab", colors.panel3)
	hubNew.Size = UDim2.new(1, 0, 0, 26)
	const hubDelete = makeButton(hubButtons, "Delete Selected", colors.panel3)
	hubDelete.Size = UDim2.new(1, 0, 0, 26)
	const hubRefresh = makeButton(hubButtons, "Refresh List", colors.panel3)
	hubRefresh.Size = UDim2.new(1, 0, 0, 26)
	NAStuff.ExecutorTools = NAStuff.ExecutorTools or {}
	NAStuff.ExecutorTools.HubStopLast = makeButton(hubButtons, "Stop Last Task", colors.panel3)
	NAStuff.ExecutorTools.HubStopLast.Size = UDim2.new(1, 0, 0, 26)

	const statusLabel = InstanceNew("TextLabel")
	statusLabel.Name = "Status"
	statusLabel.BackgroundTransparency = 1
	statusLabel.BorderSizePixel = 0
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.Position = UDim2.new(0, 0, 1, -42)
	statusLabel.Size = UDim2.new(1, 0, 0, 16)
	statusLabel.Text = "Ready"
	statusLabel.TextColor3 = colors.subtle
	statusLabel.TextSize = 12
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Parent = container
	NAStuff.ExecutorStatusLabel = statusLabel

	const actions = InstanceNew("Frame")
	actions.Name = "Buttons"
	actions.BackgroundTransparency = 1
	actions.BorderSizePixel = 0
	actions.Position = UDim2.new(0, 0, 1, -22)
	actions.Size = UDim2.new(1, 0, 0, 28)
	actions.Parent = container

	const actionLayout = InstanceNew("UIGridLayout")
	actionLayout.CellPadding = UDim2.new(0, 6, 0, 0)
	const hasClipboardPaste = type(getclipboard) == "function"
	const actionButtonCount = hasClipboardPaste and 12 or 11
	actionLayout.CellSize = UDim2.new(1 / actionButtonCount, -6, 1, 0)
	actionLayout.FillDirectionMaxCells = actionButtonCount
	actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	actionLayout.Parent = actions

	const safeExecuteButton = makeButton(actions, "Safe Execute", colors.tabActive)
	const executeButton = makeButton(actions, "Execute", colors.tabActive)
	const clearButton = makeButton(actions, "Clear", colors.panel3)
	const copyButton = makeButton(actions, "Copy", colors.panel3)
	const newLineButton = makeButton(actions, "New Line", colors.panel3)
	const pasteButton = hasClipboardPaste and makeButton(actions, "Paste from Clipboard", colors.panel3) or nil
	if pasteButton then
		pasteButton.TextSize = 10
	end
	const formatButton = makeButton(actions, "Format", colors.panel3)
	NAStuff.ExecutorTools.DeobfuscateButton = makeButton(actions, "Deobfuscate", colors.panel3)
	NAStuff.ExecutorTools.ObfuscateButton = makeButton(actions, "Obfuscate", colors.panel3)
	const renameButton = makeButton(actions, "Rename Tab", colors.panel3)
	const duplicateButton = makeButton(actions, "Duplicate Tab", colors.panel3)
	const deleteTabButton = makeButton(actions, "Delete Tab", colors.panel3)

	const settingsPanel = InstanceNew("Frame")
	settingsPanel.Name = "SettingsPanel"
	settingsPanel.BackgroundColor3 = colors.panel
	settingsPanel.BorderSizePixel = 0
	settingsPanel.AnchorPoint = Vector2.new(1, 0)
	settingsPanel.Position = UDim2.new(1, -10, 0, 42)
	settingsPanel.Size = UDim2.new(0, 236, 0, 328)
	settingsPanel.Visible = false
	settingsPanel.ZIndex = 45
	settingsPanel.Parent = frame
	makeCornerAndStroke(settingsPanel, 10, 1)

	const settingsTitle = InstanceNew("TextLabel")
	settingsTitle.BackgroundTransparency = 1
	settingsTitle.BorderSizePixel = 0
	settingsTitle.Font = Enum.Font.GothamBold
	settingsTitle.Position = UDim2.new(0, 12, 0, 10)
	settingsTitle.Size = UDim2.new(1, -24, 0, 18)
	settingsTitle.Text = "Executor Settings"
	settingsTitle.TextColor3 = colors.text
	settingsTitle.TextSize = 14
	settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
	settingsTitle.ZIndex = 46
	settingsTitle.Parent = settingsPanel

	const settingsContent = InstanceNew("Frame")
	settingsContent.Name = "Content"
	settingsContent.BackgroundTransparency = 1
	settingsContent.BorderSizePixel = 0
	settingsContent.Position = UDim2.new(0, 0, 0, 36)
	settingsContent.Size = UDim2.new(1, 0, 1, -36)
	settingsContent.ZIndex = 46
	settingsContent.Parent = settingsPanel

	const settingsList = InstanceNew("UIListLayout")
	settingsList.Padding = UDim.new(0, 8)
	settingsList.SortOrder = Enum.SortOrder.LayoutOrder
	settingsList.Parent = settingsContent

	const settingsPad = InstanceNew("UIPadding")
	settingsPad.PaddingTop = UDim.new(0, 0)
	settingsPad.PaddingBottom = UDim.new(0, 12)
	settingsPad.PaddingLeft = UDim.new(0, 12)
	settingsPad.PaddingRight = UDim.new(0, 12)
	settingsPad.Parent = settingsContent

	const function makeSettingToggle(labelText)
		const row = InstanceNew("Frame")
		row.BackgroundTransparency = 1
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 28)
		row.ZIndex = 46
		row.Parent = settingsContent

		const label = InstanceNew("TextLabel")
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.Gotham
		label.Size = UDim2.new(1, -84, 1, 0)
		label.Text = labelText
		label.TextColor3 = colors.text
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 46
		label.Parent = row

		const hit = InstanceNew("TextButton")
		hit.Name = "Hitbox"
		hit.AutoButtonColor = false
		hit.BackgroundTransparency = 1
		hit.BorderSizePixel = 0
		hit.Text = ""
		hit.Position = UDim2.new(0, 0, 0, 0)
		hit.Size = UDim2.new(1, -82, 1, 0)
		hit.ZIndex = 47
		hit.Parent = row

		const toggle = makeButton(row, "On", colors.panel3)
		toggle.AnchorPoint = Vector2.new(1, 0.5)
		toggle.Position = UDim2.new(1, 0, 0.5, 0)
		toggle.Size = UDim2.new(0, 74, 0, 24)
		toggle.ZIndex = 48

		return toggle, hit
	end

	local syntaxToggle, syntaxHit = makeSettingToggle("Syntax Highlight")
	local lineNumbersToggle, lineNumbersHit = makeSettingToggle("Line Numbers")
	local scriptHubToggle, scriptHubHit = makeSettingToggle("Script Hub")
	NAStuff.ExecutorTools.CurrentThreadToggle, NAStuff.ExecutorTools.CurrentThreadHit = makeSettingToggle("Current Thread Run")
	NAStuff.ExecutorTools.ThreadIdentityToggle, NAStuff.ExecutorTools.ThreadIdentityHit = makeSettingToggle("Thread Identity")
	NAStuff.ExecutorTools.ProfileExecutionToggle, NAStuff.ExecutorTools.ProfileExecutionHit = makeSettingToggle("Profile Execution")

	const function makeSettingStepper(labelText)
		const row = InstanceNew("Frame")
		row.BackgroundTransparency = 1
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 28)
		row.ZIndex = 46
		row.Parent = settingsContent

		const label = InstanceNew("TextLabel")
		label.BackgroundTransparency = 1
		label.BorderSizePixel = 0
		label.Font = Enum.Font.Gotham
		label.Size = UDim2.new(1, -104, 1, 0)
		label.Text = labelText
		label.TextColor3 = colors.text
		label.TextSize = 12
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 46
		label.Parent = row

		const minus = makeButton(row, "-", colors.panel3)
		minus.AnchorPoint = Vector2.new(1, 0.5)
		minus.Position = UDim2.new(1, -66, 0.5, 0)
		minus.Size = UDim2.new(0, 28, 0, 24)
		minus.ZIndex = 48

		const value = InstanceNew("TextLabel")
		value.BackgroundTransparency = 1
		value.BorderSizePixel = 0
		value.Font = Enum.Font.GothamSemibold
		value.Position = UDim2.new(1, -62, 0, 0)
		value.Size = UDim2.new(0, 30, 1, 0)
		value.Text = ""
		value.TextColor3 = colors.subtle
		value.TextSize = 12
		value.TextXAlignment = Enum.TextXAlignment.Center
		value.ZIndex = 46
		value.Parent = row

		const plus = makeButton(row, "+", colors.panel3)
		plus.AnchorPoint = Vector2.new(1, 0.5)
		plus.Position = UDim2.new(1, 0, 0.5, 0)
		plus.Size = UDim2.new(0, 28, 0, 24)
		plus.ZIndex = 48

		return minus, value, plus
	end

	local fontMinus, fontValue, fontPlus = makeSettingStepper("Font Size")
	NAStuff.ExecutorTools.IdentityMinus, NAStuff.ExecutorTools.IdentityValue, NAStuff.ExecutorTools.IdentityPlus = makeSettingStepper("Identity Level")

	const promptOverlay = InstanceNew("Frame")
	promptOverlay.Name = "Prompt"
	promptOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	promptOverlay.BackgroundTransparency = 0.3
	promptOverlay.BorderSizePixel = 0
	promptOverlay.Size = UDim2.new(1, 0, 1, 0)
	promptOverlay.Visible = false
	promptOverlay.ZIndex = 50
	promptOverlay.Parent = container

	const promptCard = InstanceNew("Frame")
	promptCard.BackgroundColor3 = colors.panel
	promptCard.BorderSizePixel = 0
	promptCard.AnchorPoint = Vector2.new(0.5, 0.5)
	promptCard.Position = UDim2.new(0.5, 0, 0.5, 0)
	promptCard.Size = UDim2.new(1, -28, 0, 170)
	promptCard.ZIndex = 51
	promptCard.Parent = promptOverlay
	makeCornerAndStroke(promptCard, 10, 1)
	NAStuff.ExecutorTools.PromptSizeConstraint = InstanceNew("UISizeConstraint")
	NAStuff.ExecutorTools.PromptSizeConstraint.MaxSize = Vector2.new(360, 170)
	NAStuff.ExecutorTools.PromptSizeConstraint.MinSize = Vector2.new(220, 170)
	NAStuff.ExecutorTools.PromptSizeConstraint.Parent = promptCard

	const promptTitle = InstanceNew("TextLabel")
	promptTitle.BackgroundTransparency = 1
	promptTitle.BorderSizePixel = 0
	promptTitle.Font = Enum.Font.GothamBold
	promptTitle.Position = UDim2.new(0, 14, 0, 10)
	promptTitle.Size = UDim2.new(1, -28, 0, 36)
	promptTitle.Text = "Name"
	promptTitle.TextColor3 = colors.text
	promptTitle.TextSize = 15
	promptTitle.TextWrapped = true
	promptTitle.TextXAlignment = Enum.TextXAlignment.Left
	promptTitle.TextYAlignment = Enum.TextYAlignment.Top
	promptTitle.ZIndex = 52
	promptTitle.Parent = promptCard

	const promptInput = InstanceNew("TextBox")
	promptInput.BackgroundColor3 = colors.panel2
	promptInput.BorderSizePixel = 0
	promptInput.ClearTextOnFocus = false
	promptInput.Font = Enum.Font.Gotham
	promptInput.PlaceholderText = "Enter a name"
	promptInput.Position = UDim2.new(0, 14, 0, 54)
	promptInput.Size = UDim2.new(1, -28, 0, 38)
	promptInput.Text = ""
	promptInput.TextColor3 = colors.text
	promptInput.TextSize = 14
	promptInput.ZIndex = 52
	promptInput.Parent = promptCard
	makeCornerAndStroke(promptInput, 8, 1)

	const promptOk = makeButton(promptCard, "OK", colors.tabActive)
	promptOk.Position = UDim2.new(0, 14, 1, -42)
	promptOk.Size = UDim2.new(0.5, -20, 0, 28)
	promptOk.ZIndex = 52
	const promptCancel = makeButton(promptCard, "Cancel", colors.panel3)
	promptCancel.Position = UDim2.new(0.5, 6, 1, -42)
	promptCancel.Size = UDim2.new(0.5, -20, 0, 28)
	promptCancel.ZIndex = 52

	NAStuff.ExecutorTools.ObfuscationMenu = {}
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay = InstanceNew("Frame")
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Name = "ObfuscationMenu"
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.BackgroundTransparency = 0.3
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Size = UDim2.new(1, 0, 1, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Visible = false
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.ZIndex = 54
	NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Parent = container

	NAStuff.ExecutorTools.ObfuscationMenu.Card = InstanceNew("Frame")
	NAStuff.ExecutorTools.ObfuscationMenu.Card.BackgroundColor3 = colors.panel
	NAStuff.ExecutorTools.ObfuscationMenu.Card.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Card.AnchorPoint = Vector2.new(0.5, 0.5)
	NAStuff.ExecutorTools.ObfuscationMenu.Card.Position = UDim2.new(0.5, 0, 0.5, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.Card.Size = UDim2.new(1, -28, 0, 340)
	NAStuff.ExecutorTools.ObfuscationMenu.Card.ZIndex = 55
	NAStuff.ExecutorTools.ObfuscationMenu.Card.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Overlay
	makeCornerAndStroke(NAStuff.ExecutorTools.ObfuscationMenu.Card, 10, 1)

	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint = InstanceNew("UISizeConstraint")
	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint.MaxSize = Vector2.new(420, 340)
	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint.MinSize = Vector2.new(220, 280)
	NAStuff.ExecutorTools.ObfuscationMenu.SizeConstraint.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.Title = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.ObfuscationMenu.Title.BackgroundTransparency = 1
	NAStuff.ExecutorTools.ObfuscationMenu.Title.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Font = Enum.Font.GothamBold
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Position = UDim2.new(0, 14, 0, 12)
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Size = UDim2.new(1, -28, 0, 22)
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Text = "Obfuscation Method"
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextColor3 = colors.text
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextSize = 15
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextWrapped = true
	NAStuff.ExecutorTools.ObfuscationMenu.Title.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.ObfuscationMenu.Title.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.Title.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.BackgroundTransparency = 1
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Font = Enum.Font.Gotham
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Position = UDim2.new(0, 14, 0, 38)
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Size = UDim2.new(1, -28, 0, 32)
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Text = "Select a method for the current Executor tab."
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextColor3 = colors.subtle
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextSize = 12
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextWrapped = true
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.TextYAlignment = Enum.TextYAlignment.Top
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.Subtitle.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.List = InstanceNew("ScrollingFrame")
	NAStuff.ExecutorTools.ObfuscationMenu.List.Name = "Methods"
	NAStuff.ExecutorTools.ObfuscationMenu.List.BackgroundColor3 = colors.panel2
	NAStuff.ExecutorTools.ObfuscationMenu.List.BackgroundTransparency = 0.08
	NAStuff.ExecutorTools.ObfuscationMenu.List.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.List.Position = UDim2.new(0, 14, 0, 76)
	NAStuff.ExecutorTools.ObfuscationMenu.List.Size = UDim2.new(1, -28, 0, 180)
	NAStuff.ExecutorTools.ObfuscationMenu.List.CanvasSize = UDim2.new(0, 0, 0, 0)
	NAStuff.ExecutorTools.ObfuscationMenu.List.AutomaticCanvasSize = Enum.AutomaticSize.Y
	NAStuff.ExecutorTools.ObfuscationMenu.List.ScrollingDirection = Enum.ScrollingDirection.Y
	NAStuff.ExecutorTools.ObfuscationMenu.List.ScrollBarThickness = 4
	NAStuff.ExecutorTools.ObfuscationMenu.List.ScrollBarImageColor3 = colors.subtle
	NAStuff.ExecutorTools.ObfuscationMenu.List.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.List.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card
	makeCornerAndStroke(NAStuff.ExecutorTools.ObfuscationMenu.List, 8, 1)

	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout = InstanceNew("UIListLayout")
	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout.Padding = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NAStuff.ExecutorTools.ObfuscationMenu.ListLayout.Parent = NAStuff.ExecutorTools.ObfuscationMenu.List

	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding = InstanceNew("UIPadding")
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingTop = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingBottom = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingLeft = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.PaddingRight = UDim.new(0, 6)
	NAStuff.ExecutorTools.ObfuscationMenu.ListPadding.Parent = NAStuff.ExecutorTools.ObfuscationMenu.List

	NAStuff.ExecutorTools.ObfuscationMenu.Buttons = {}
	NAStuff.ExecutorTools.ObfuscationMenu.Selected = "auto"
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod = function(mode, title, detail)
		local button = InstanceNew("TextButton")
		button.Name = mode
		button.AutoButtonColor = false
		button.BackgroundColor3 = mode == "auto" and colors.tabActive or colors.panel3
		button.BorderSizePixel = 0
		button.Font = Enum.Font.Gotham
		button.Size = UDim2.new(1, -2, 0, 42)
		button.Text = title.."  -  "..detail
		button.TextColor3 = mode == "auto" and colors.tabTextActive or colors.text
		button.TextSize = 12
		button.TextWrapped = true
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.ZIndex = 57
		button.Parent = NAStuff.ExecutorTools.ObfuscationMenu.List
		makeCornerAndStroke(button, 7, 1)
		NAStuff.ExecutorTools.ObfuscationMenu.Buttons[mode] = button
		button.MouseButton1Click:Connect(function()
			NAStuff.ExecutorTools.ObfuscationMenu.Selected = mode
			for method, methodButton in NAStuff.ExecutorTools.ObfuscationMenu.Buttons do
				const selected = method == mode
				methodButton.BackgroundColor3 = selected and colors.tabActive or colors.panel3
				methodButton.TextColor3 = selected and colors.tabTextActive or colors.text
			end
			NAStuff.ExecutorTools.ObfuscationMenu.Selection.Text = "Selected: "..title
			NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Text = "Obfuscate: "..title
		end)
	end

	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("auto", "Auto", "Chooses Ultra, Strong, or Balanced by script size")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("wearedevs", "WeAreDevs / Prometheus", "Prometheus Strong LuaU pipeline - reversible with NA Deobfuscate")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("light", "Light", "Compatibility alias for Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base4", "Base4 Bytes", "Four base-4 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base36", "Base36 Bytes", "Two fixed base-36 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base62", "Base62 Bytes", "Two fixed base-62 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base64", "Base64", "Standard Base64 text encoding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base64url", "Base64URL", "URL-safe Base64 alphabet without padding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("base32", "Base32", "RFC-style A-Z and 2-7 encoding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("z85", "Z85", "Compact printable base-85 encoding")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("hex", "Hex", "Two hexadecimal digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("percent", "Percent Bytes", "Every byte encoded as %XX")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("decimal", "Decimal Bytes", "Comma-separated byte values")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("binary", "Binary Bytes", "Eight 0/1 digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("octal", "Octal Bytes", "Three octal digits per source byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("reverse64", "Reverse Base64", "Base64 payload stored backwards")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("pairswap", "Pair Swap + Base64", "Swaps each adjacent byte pair")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("reversebytes", "Reverse Bytes + Base64", "Reverses the complete source byte order")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("indexxor", "Index XOR + Base64", "XOR key changes with each byte position")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("indexshift", "Index Shift + Base64", "Byte shift changes with each byte position")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("affine", "Affine Bytes + Base64", "Invertible multiply-and-add byte transform")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("bitreverse", "Bit Reverse + Base64", "Reverses the 8 bits inside every byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("gray", "Gray Code + Base64", "Converts every byte to Gray code")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("rot13", "ROT13 + Base64", "ROT13 letter transform then Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("shift", "Byte Shift + Base64", "Adds a rotating numeric byte offset")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("complement", "Complement + Base64", "Maps each byte to 255-byte")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("nibble", "Nibble Swap + Base64", "Swaps high and low 4-bit halves")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("rotate", "Bit Rotate + Base64", "Rotates every source byte by 3 bits")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("xor", "XOR + Base64", "Single-byte XOR with generated key")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("repeatxor", "Repeating XOR + Base64", "Multi-byte repeating generated key")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("delta", "Delta + Base64", "Stores byte differences instead of bytes")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("rle", "RLE + Base64", "Run-length packs repeated bytes")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("lzw92", "LZW92", "LZW compression packed in base-92 pairs")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("lzw92base64", "LZW92 + Base64", "LZW92 stream wrapped in Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("jscamo", "JavaScript Camouflage", "Looks like a JavaScript module but executes as Luau")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("jscamostrong", "JavaScript Camouflage Strong", "JavaScript decoy + LZW92 + repeating XOR")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("pycamo", "Python Camouflage", "Looks like a Python module but executes as Luau")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("pycamostrong", "Python Camouflage Strong", "Python decoy + LZW92 + repeating XOR")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("balanced", "Balanced", "XOR + Base64 compatibility preset")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("strong", "Strong", "LZW92 + XOR + Base64")
	NAStuff.ExecutorTools.ObfuscationMenu.AddMethod("ultra", "Ultra", "LZW92 + repeating XOR + Base32")

	NAStuff.ExecutorTools.ObfuscationMenu.Selection = InstanceNew("TextLabel")
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.BackgroundTransparency = 1
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.BorderSizePixel = 0
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Font = Enum.Font.Gotham
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Position = UDim2.new(0, 14, 0, 262)
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Size = UDim2.new(1, -28, 0, 16)
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Text = "Selected: Auto"
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.TextColor3 = colors.subtle
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.TextSize = 11
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.TextXAlignment = Enum.TextXAlignment.Left
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.ZIndex = 56
	NAStuff.ExecutorTools.ObfuscationMenu.Selection.Parent = NAStuff.ExecutorTools.ObfuscationMenu.Card

	NAStuff.ExecutorTools.ObfuscationMenu.Confirm = makeButton(NAStuff.ExecutorTools.ObfuscationMenu.Card, "Obfuscate: Auto", colors.tabActive)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Position = UDim2.new(0, 14, 1, -42)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Size = UDim2.new(0.62, -18, 0, 28)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.ZIndex = 56

	NAStuff.ExecutorTools.ObfuscationMenu.Cancel = makeButton(NAStuff.ExecutorTools.ObfuscationMenu.Card, "Cancel", colors.panel3)
	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.Position = UDim2.new(0.62, 4, 1, -42)
	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.Size = UDim2.new(0.38, -18, 0, 28)
	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.ZIndex = 56

	NAStuff.ExecutorTools.ObfuscationMenu.Show = function()
		NAStuff.ExecutorTools.ObfuscationMenu.Selected = "auto"
		for method, methodButton in NAStuff.ExecutorTools.ObfuscationMenu.Buttons do
			const selected = method == "auto"
			methodButton.BackgroundColor3 = selected and colors.tabActive or colors.panel3
			methodButton.TextColor3 = selected and colors.tabTextActive or colors.text
		end
		NAStuff.ExecutorTools.ObfuscationMenu.Selection.Text = "Selected: Auto"
		NAStuff.ExecutorTools.ObfuscationMenu.Confirm.Text = "Obfuscate: Auto"
		NAStuff.ExecutorTools.ObfuscationMenu.List.CanvasPosition = Vector2.new(0, 0)
		NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Visible = true
	end

	NAStuff.ExecutorTools.ObfuscationMenu.Hide = function()
		NAStuff.ExecutorTools.ObfuscationMenu.Overlay.Visible = false
	end

	NAStuff.ExecutorTools.ObfuscationMenu.Cancel.MouseButton1Click:Connect(NAStuff.ExecutorTools.ObfuscationMenu.Hide)
	NAStuff.ExecutorTools.ObfuscationMenu.Confirm.MouseButton1Click:Connect(function()
		const mode = NAStuff.ExecutorTools.ObfuscationMenu.Selected or "auto"
		NAStuff.ExecutorTools.ObfuscationMenu.Hide()
		if type(NAStuff.ExecutorTools.RunObfuscateMode) == "function" then
			NAStuff.ExecutorTools.RunObfuscateMode(mode)
		end
	end)

	local promptCallback
	const tabs = {}
	local currentTab = 1
	local selectedScript
	local refreshQueued = false
	local tabSaveDirty = false
	local tabSaveScheduled = false
	local lastTabClickIndex = 0
	local lastTabClickTime = 0
	const editorLineBuffer = 24
	local editorVirtualStart = 1
	local editorVirtualEnd = 1
	local editorVirtualLineHeight = 19
	local editorLoading = false
	local editorLoaded = false
	local editorTextLock = 0
	local editorRenderedText = ""
	local editorRenderedStart = 1
	local editorRenderedEnd = 1
	local editorLastCursorPosition = 1
	NAStuff.ExecutorTools.TabsLoaded = false
	local commitCurrentPage
	local queueRefreshEditor

	NAmanage.ExecutorYieldWork = function(state)
		const now = os.clock()
		if now - (state.lastYield or now) < 0.006 then
			return
		end
		if type(task) == "table" and type(task.wait) == "function" then
			task.wait()
		elseif type(wait) == "function" then
			wait()
		end
		state.lastYield = os.clock()
	end

	NAmanage.ExecutorHydrateTab = function(tab)
		if not tab then
			return nil
		end
		if type(tab.lines) == "table" and #tab.lines > 0 then
			tab.linesDeferred = false
			return tab
		end
		const source = NAmanage.ExecutorRepairTabText(tab.text or "")
		tab.text = source
		const lines = {}
		local cursor = 1
		const workState = { lastYield = os.clock() }
		while true do
			const newline = source:find("\n", cursor, true)
			if not newline then
				lines[#lines + 1] = source:sub(cursor)
				break
			end
			lines[#lines + 1] = source:sub(cursor, newline - 1)
			cursor = newline + 1
			if #lines % 128 == 0 then
				NAmanage.ExecutorYieldWork(workState)
			end
		end
		if #lines == 0 then
			lines[1] = ""
		end
		tab.lines = lines
		tab.viewLine = math.clamp(tonumber(tab.viewLine or tab.page) or 1, 1, math.max(#lines, 1))
		tab.page = 1
		tab.chunks = { tab.text }
		tab.textDirty = false
		tab.linesDeferred = false
		return tab
	end

	NAStuff.ExecutorTools.GetCurrentTab = function()
		const tab = tabs[currentTab]
		if tab and tab.linesDeferred == true then
			return nil
		end
		return NAmanage.ExecutorNormalizeTab(tab)
	end

	const function showPrompt(title, initialText, callback)
		promptTitle.Text = title or "Name"
		promptInput.Text = initialText or ""
		promptCallback = callback
		promptOverlay.Visible = true
		Defer(function()
			pcall(function()
				promptInput:CaptureFocus()
				promptInput.CursorPosition = #promptInput.Text + 1
			end)
		end)
	end

	const function closePrompt(okPressed)
		promptOverlay.Visible = false
		const callback = promptCallback
		promptCallback = nil
		if callback then
			callback(okPressed == true, promptInput.Text or "")
		end
	end

	promptOk.MouseButton1Click:Connect(function()
		closePrompt(true)
	end)
	promptCancel.MouseButton1Click:Connect(function()
		closePrompt(false)
	end)
	promptInput.FocusLost:Connect(function(enterPressed)
		if promptOverlay.Visible and enterPressed == true then
			closePrompt(true)
		end
	end)

	const function updateTabCanvas()
		const width = tabLayout.AbsoluteContentSize.X
		tabWrap.Size = UDim2.new(0, width, 1, 0)
		tabScroll.CanvasSize = UDim2.new(0, width, 0, 0)
	end
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
	tabScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTabCanvas)

	const function saveTabsNow()
		if not NAStuff.ExecutorTools.TabsLoaded then
			return false
		end
		if not fsOk then
			setStatus("Executor tabs cannot save: filesystem unavailable", colors.error)
			return false
		end
		if not ensureExecutorFolders() then
			setStatus("Executor tabs cannot save: folder create failed", colors.error)
			return false
		end
		if editorLoaded and type(commitCurrentPage) == "function" then
			commitCurrentPage(true)
		end
		const payload = { cur = currentTab, tabs = {} }
		const workState = { lastYield = os.clock() }
		for i, tab in tabs do
			local tabText
			if tab.linesDeferred == true and tab.textDirty ~= true then
				tabText = tostring(tab.text or "")
			else
				NAmanage.ExecutorNormalizeTab(tab)
				tabText = NAmanage.ExecutorRepairTabText(NAmanage.ExecutorGetTabText(tab))
				if tabText ~= tab.text then
					tab.text = tabText
					tab.lines = NAmanage.ExecutorSplitEditorLines(tabText)
					tab.chunks = { tabText }
					tab.textDirty = false
				end
			end
			payload.tabs[i] = {
				title = tab.title or ("Tab "..i),
				text = tabText,
			}
			NAmanage.ExecutorYieldWork(workState)
		end
		local ok, encoded = pcall(function()
			return Services.HttpService:JSONEncode(payload)
		end)
		if not (ok and encoded) then
			setStatus("Executor tabs cannot save: encode failed", colors.error)
			return false
		end
		const function tryWrite(fn)
			if type(fn) ~= "function" then
				return false, "writefile missing"
			end
			local wrote, err = pcall(fn, tabsFile, encoded)
			if not wrote then
				return false, err or "writefile failed"
			end
			if type(readfile) == "function" then
				local okRead, saved = pcall(readfile, tabsFile)
				if okRead and saved == encoded then
					return true
				end
				return false, "write verification failed"
			end
			return true
		end

		local wrote, err = tryWrite(writefile)
		if not wrote and NAStuff and type(NAStuff._wf) == "function" and NAStuff._wf ~= writefile then
			wrote, err = tryWrite(NAStuff._wf)
		end
		if not wrote then
			setStatus("Executor tabs cannot save: "..tostring(err or "writefile failed"), colors.error)
			return false
		end
		setStatus("Executor tabs saved", colors.success)
		return true
	end

	const function scheduleTabsSave()
		if not fsOk then
			setStatus("Executor tabs cannot save: filesystem unavailable", colors.error)
			return
		end
		tabSaveDirty = true
		if tabSaveScheduled then
			return
		end
		tabSaveScheduled = true
		Delay(0.8, function()
			if tabSaveDirty then
				tabSaveDirty = false
				if not saveTabsNow() then
					tabSaveDirty = true
				end
			end
			tabSaveScheduled = false
			if tabSaveDirty then
				scheduleTabsSave()
			end
		end)
	end

	const function getEditorLineHeight()
		const fallback = tonumber(textBox.TextSize) or 15
		local ok, measured = pcall(function()
			return TextServiceRef:GetTextSize("M", textBox.TextSize, textBox.Font, Vector2.new(1000, 1000)).Y
		end)
		return math.max(1, math.ceil((ok and type(measured) == "number" and measured or fallback)))
	end

	const function updatePageInfo()
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		const total = tab and math.max(#tab.lines, 1) or 1
		const lineHeight = getEditorLineHeight()
		local viewHeight = (editorScroll.AbsoluteSize.Y or 0) - 22
		if NAmanage.virtView then
			viewHeight = NAmanage.virtView(editorLineScroll, viewHeight, editorLineScroll.CanvasSize.Y.Offset, lineHeight * 3)
		end
		viewHeight = math.max(1, viewHeight)
		const visibleCount = math.max(1, math.floor(viewHeight / math.max(lineHeight, 1)))
		const editorLinePos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorLineScroll) or editorLineScroll.CanvasPosition
		const firstLine = math.clamp(math.floor(math.max(editorLinePos.Y, 0) / math.max(lineHeight, 1)) + 1, 1, total)
		const lastLine = math.clamp(firstLine + visibleCount - 1, firstLine, total)
		pageLabel.Text = "Lines "..tostring(firstLine).."-"..tostring(lastLine).."/"..tostring(total)
		pagePrev.Visible = false
		pageNext.Visible = false
		pagePanel.Visible = total > math.max(1, lastLine - firstLine + 1)
	end

	const function beginEditorTextSet()
		editorTextLock += 1
		editorLoading = true
	end

	const function finishEditorTextSet()
		editorLoading = false
		Defer(function()
			editorTextLock = math.max(editorTextLock - 1, 0)
		end)
	end

	const function setEditorBoxText(text)
		beginEditorTextSet()
		textBox.Text = tostring(text or "")
		finishEditorTextSet()
	end

	const function insertEditorNewLine()
		const currentText = tostring(textBox.Text or "")
		local cursor = tonumber(textBox.CursorPosition) or -1
		const selectionStart = tonumber(textBox.SelectionStart) or -1
		if cursor <= 0 then
			cursor = tonumber(editorLastCursorPosition) or (#currentText + 1)
		end
		cursor = math.clamp(cursor, 1, #currentText + 1)

		local startPos = cursor
		local endPos = cursor - 1
		if selectionStart > 0 and selectionStart ~= cursor then
			startPos = math.clamp(math.min(selectionStart, cursor), 1, #currentText + 1)
			endPos = math.clamp(math.max(selectionStart, cursor) - 1, 0, #currentText)
		end

		setEditorBoxText(currentText:sub(1, startPos - 1).."\n"..currentText:sub(endPos + 1))
		editorLastCursorPosition = math.clamp(startPos + 1, 1, #textBox.Text + 1)
		commitCurrentPage(true)
		scheduleTabsSave()
		queueRefreshEditor()
	end

	commitCurrentPage = function(skipSave)
		if editorLoading then
			return
		end
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		if not tab then
			return
		end
		const visibleText = tostring(textBox.Text or "")
		const lineHeight = getEditorLineHeight()
		const function syncViewOnly()
			const editorLinePos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorLineScroll) or editorLineScroll.CanvasPosition
			tab.viewLine = math.clamp(math.floor(math.max(editorLinePos.Y, 0) / lineHeight) + 1, 1, math.max(#tab.lines, 1))
			updatePageInfo()
		end
		if visibleText == tostring(editorRenderedText or "") then
			syncViewOnly()
			return
		end
		const total = math.max(#tab.lines, 1)
		const firstLine = math.clamp(tonumber(editorRenderedStart) or editorVirtualStart or 1, 1, total)
		const lastLine = math.clamp(tonumber(editorRenderedEnd) or editorVirtualEnd or firstLine, firstLine, total)
		tab.lines = NAmanage.ExecutorReplaceEditorLineRange(tab.lines, firstLine, lastLine, visibleText)
		editorVirtualStart = firstLine
		editorVirtualEnd = firstLine + #(NAmanage.ExecutorSplitEditorLines(visibleText)) - 1
		editorRenderedStart = editorVirtualStart
		editorRenderedEnd = editorVirtualEnd
		editorRenderedText = visibleText
		tab.textDirty = true
		syncViewOnly()
		if not skipSave then
			scheduleTabsSave()
		end
	end

	const function setTabFullText(tab, source, deferLines)
		if not tab then
			return
		end
		tab.text = tostring(source or "")
		if deferLines == true then
			tab.lines = nil
			tab.linesDeferred = true
		else
			tab.lines = NAmanage.ExecutorSplitEditorLines(tab.text)
			tab.linesDeferred = false
		end
		tab.chunks = { tab.text }
		tab.textDirty = false
		tab.page = 1
		tab.viewLine = 1
	end

	const function measureSource(source)
		const lineHeight = getEditorLineHeight()
		local longest = 0
		local lines = 0
		for line in ((source or "").."\n"):gmatch("(.-)\n") do
			lines += 1
			const width = TextServiceRef:GetTextSize((line ~= "" and line or " "), textBox.TextSize, textBox.Font, Vector2.new(10000, 10000)).X
			if width > longest then
				longest = width
			end
		end
		if lines <= 0 then
			lines = 1
		end
		const viewportWidth = math.max(1, (editorScroll.AbsoluteSize.X or 0) - 18)
		const desiredWidth = math.max(viewportWidth, longest + 12)
		const desiredHeight = math.max(math.max(editorScroll.AbsoluteSize.Y - 22, 1), lines * lineHeight + 12)
		return desiredWidth, desiredHeight, lines, lineHeight
	end

	const function getEditorViewportHeight()
		local h = (editorScroll.AbsoluteSize.Y or 0) - 22
		if NAmanage.virtView then
			h = NAmanage.virtView(editorLineScroll, h, editorLineScroll.CanvasSize.Y.Offset, getEditorLineHeight() * 3)
		end
		return math.max(1, h)
	end

	const function getEditorWindowMetrics()
		const lineHeight = getEditorLineHeight()
		const visible = math.max(1, math.floor(getEditorViewportHeight() / math.max(lineHeight, 1)))
		return lineHeight, visible
	end

	const function getEditorVisibleLine(totalLines)
		const lineHeight = getEditorWindowMetrics()
		const total = math.max(tonumber(totalLines) or 1, 1)
		const editorLinePos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorLineScroll) or editorLineScroll.CanvasPosition
		return math.clamp(math.floor(math.max(editorLinePos.Y, 0) / math.max(lineHeight, 1)) + 1, 1, total)
	end

	const function getEditorWindowRange(totalLines, firstVisibleLine)
		local _, visibleLines = getEditorWindowMetrics()
		const total = math.max(tonumber(totalLines) or 1, 1)
		const firstVisible = math.clamp(tonumber(firstVisibleLine) or getEditorVisibleLine(total), 1, total)
		const lastVisible = math.clamp(firstVisible + visibleLines - 1, firstVisible, total)
		const firstRender = firstVisible
		const lastRender = lastVisible
		return firstRender, lastRender, firstVisible, lastVisible
	end

	const function buildHighlightLayers(source)
		source = source or ""
		const buffers = {
			keywords = {},
			globals = {},
			strings = {},
			comments = {},
			numbers = {},
			functions = {},
			methods = {},
			properties = {},
			operators = {},
			brackets = {},
		}
		const function blankFor(ch)
			if ch == "\n" or ch == "\r" or ch == "\t" then
				return ch
			end
			return " "
		end
		const function appendToLayer(layerName, text)
			for i = 1, #text do
				const ch = text:sub(i, i)
				for key, arr in buffers do
					arr[#arr + 1] = (key == layerName) and ch or blankFor(ch)
				end
			end
		end
		const function appendPlain(text)
			for i = 1, #text do
				const ch = text:sub(i, i)
				const blank = blankFor(ch)
				for _, arr in buffers do
					arr[#arr + 1] = blank
				end
			end
		end
		local i = 1
		const n = #source
		const function findLongBracket(pos)
			const eq = source:match("^%[(=*)%[", pos)
			if not eq then
				return nil
			end
			const closePattern = "]"..eq.."]"
			local closeStart, closeEnd = source:find(closePattern, pos + 2 + #eq, true)
			return closeStart, closeEnd, closePattern
		end
		const function nextNonSpace(pos)
			local j = pos
			while j <= n and source:sub(j, j):match("%s") do
				j += 1
			end
			return source:sub(j, j), j
		end
		const function prevNonSpace(pos)
			local j = pos
			while j >= 1 and source:sub(j, j):match("%s") do
				j -= 1
			end
			return source:sub(j, j), j
		end
		while i <= n do
			const ch = source:sub(i, i)
			const nextTwo = source:sub(i, i + 1)
			if nextTwo == "--" and source:sub(i + 2, i + 2) == "[" then
				local _, closeEnd = findLongBracket(i + 2)
				const endIndex = closeEnd or n
				appendToLayer("comments", source:sub(i, endIndex))
				i = endIndex + 1
			elseif nextTwo == "--" then
				const newlineIndex = source:find("\n", i + 2, true)
				const endIndex = newlineIndex and (newlineIndex - 1) or n
				appendToLayer("comments", source:sub(i, endIndex))
				i = endIndex + 1
			elseif ch == "\"" or ch == "'" or ch == "`" then
				const quote = ch
				local j = i + 1
				local escaped = false
				while j <= n do
					const cur = source:sub(j, j)
					if escaped then
						escaped = false
					elseif cur == "\\" then
						escaped = true
					elseif cur == quote then
						break
					end
					j += 1
				end
				if j > n then
					j = n
				end
				appendToLayer("strings", source:sub(i, j))
				i = j + 1
			elseif ch == "[" and findLongBracket(i) then
				local _, closeEnd = findLongBracket(i)
				const endIndex = closeEnd or n
				appendToLayer("strings", source:sub(i, endIndex))
				i = endIndex + 1
			elseif ch:match("[%a_]") then
				local j = i
				while j <= n and source:sub(j, j):match("[%w_]") do
					j += 1
				end
				const token = source:sub(i, j - 1)
				const prevChar = prevNonSpace(i - 1)
				const nextChar = nextNonSpace(j)
				if NAStuff.ExecutorKeywordSet[token] then
					appendToLayer("keywords", token)
				elseif NAStuff.ExecutorTypeSet[token] then
					appendToLayer("keywords", token)
				elseif prevChar == ":" and nextChar == "(" then
					appendToLayer("methods", token)
				elseif prevChar == "." then
					appendToLayer("properties", token)
				elseif nextChar == "(" then
					appendToLayer(NAStuff.ExecutorGlobalSet[token] and "globals" or "functions", token)
				elseif NAStuff.ExecutorGlobalSet[token] then
					appendToLayer("globals", token)
				else
					appendPlain(token)
				end
				i = j
			elseif ch:match("%d") then
				local j = i
				while j <= n and source:sub(j, j):match("[%w_%.]") do
					j += 1
				end
				appendToLayer("numbers", source:sub(i, j - 1))
				i = j
			elseif ch:match("[%[%]%(%){}]") then
				appendToLayer("brackets", ch)
				i += 1
			elseif source:sub(i, i + 2) == "..." then
				appendToLayer("operators", "...")
				i += 3
			elseif source:sub(i, i + 2) == "//=" or source:sub(i, i + 2) == "..=" then
				appendToLayer("operators", source:sub(i, i + 2))
				i += 3
			elseif ch:match("[%+%-%*/%%%^#=<>~:;,%.,|&%?]") or nextTwo == ".." or nextTwo == "==" or nextTwo == "~=" or nextTwo == "<=" or nextTwo == ">=" or nextTwo == "//" or nextTwo == "->" then
				if nextTwo == ".." or nextTwo == "==" or nextTwo == "~=" or nextTwo == "<=" or nextTwo == ">=" or nextTwo == "::" or nextTwo == "//" or nextTwo == "->" then
					appendToLayer("operators", nextTwo)
					i += 2
				else
					appendToLayer("operators", ch)
					i += 1
				end
			else
				appendPlain(ch)
				i += 1
			end
		end
		return Concat(buffers.keywords), Concat(buffers.globals), Concat(buffers.strings), Concat(buffers.comments), Concat(buffers.numbers), Concat(buffers.functions), Concat(buffers.methods), Concat(buffers.properties), Concat(buffers.operators), Concat(buffers.brackets)
	end

	const function syncCurrentTabText()
		commitCurrentPage()
	end

	const function refreshEditorNow()
		const current = tabs[currentTab]
		if current and current.linesDeferred == true then
			return
		end
		const source = textBox.Text or ""
		updatePageInfo()
		const tab = NAmanage.ExecutorNormalizeTab(current)
		const totalLineCount = tab and math.max(#tab.lines, 1) or 1
		local width, visibleHeight, renderedLineCount, lineHeight = measureSource(source)
		editorVirtualLineHeight = lineHeight
		const fullHeight = math.max(getEditorViewportHeight(), totalLineCount * lineHeight + 12)
		local _, visibleLines = getEditorWindowMetrics()
		const virtualTotal = math.max(totalLineCount + 1, visibleLines)
		const maxTopY = math.max(0, (virtualTotal - visibleLines) * lineHeight)
		const proxyHeight = math.max(fullHeight + lineHeight + 8, (editorScroll.AbsoluteSize.Y or 0) + maxTopY + lineHeight)
		const yOffset = 0
		textBox.Position = UDim2.new(0, 8, 0, 0)
		textBox.Size = UDim2.new(0, width, 0, visibleHeight)
		for _, layer in { keywordLayer, globalLayer, stringLayer, commentLayer, numberLayer, functionLayer, methodLayer, propertyLayer, operatorLayer, bracketLayer } do
			layer.Position = textBox.Position
			layer.Size = textBox.Size
		end
		const canvasWidth = math.max(editorScroll.AbsoluteSize.X or 1, 8 + width + 2)
		editorScroll.CanvasSize = UDim2.new(0, canvasWidth, 0, math.max(editorScroll.AbsoluteSize.Y, 1))
		editorLineScroll.Position = editorScroll.Position
		editorLineScroll.Size = editorScroll.Size
		editorLineScroll.CanvasSize = UDim2.new(0, 0, 0, proxyHeight)
		if NAmanage.CustomScroll and NAmanage.CustomScroll.refreshByTarget then
			NAmanage.CustomScroll.refreshByTarget(editorScroll)
			NAmanage.CustomScroll.refreshByTarget(editorLineScroll)
		end
		local gutterWidth = 0
		if cfg.lineNumbers then
			const digits = #tostring(totalLineCount)
			gutterWidth = math.max(44, 16 + digits * 9)
			gutter.Size = UDim2.new(0, gutterWidth, 1, 0)
		end
		editorScroll.Position = UDim2.new(0, gutterWidth > 0 and (gutterWidth + 6) or 0, 0, 0)
		editorScroll.Size = UDim2.new(1, gutterWidth > 0 and -(gutterWidth + 6) or 0, 1, 0)
		const numbers = {}
		for index = editorVirtualStart, editorVirtualEnd do
			numbers[#numbers + 1] = tostring(index)
		end
		gutterLabel.Text = Concat(numbers, "\n")
		gutterLabel.Size = UDim2.new(1, -10, 0, math.max(renderedLineCount, 1) * lineHeight + 8)
		local keywordText, globalText, stringText, commentText, numberText, functionText, methodText, propertyText, operatorText, bracketText = buildHighlightLayers(source)
		keywordLayer.Text = keywordText
		globalLayer.Text = globalText
		stringLayer.Text = stringText
		commentLayer.Text = commentText
		numberLayer.Text = numberText
		functionLayer.Text = functionText
		methodLayer.Text = methodText
		propertyLayer.Text = propertyText
		operatorLayer.Text = operatorText
		bracketLayer.Text = bracketText
		gutterLabel.Position = UDim2.new(1, -6, 0, 0)
	end

	queueRefreshEditor = function()
		if refreshQueued then
			return
		end
		refreshQueued = true
		Defer(function()
			refreshQueued = false
			refreshEditorNow()
		end)
	end

	const function loadCurrentPage(preserveScroll)
		const targetIndex = currentTab
		local tab = tabs[targetIndex]
		if tab and tab.linesDeferred == true then
			tab = NAmanage.ExecutorHydrateTab(tab)
		else
			tab = NAmanage.ExecutorNormalizeTab(tab)
		end
		if currentTab ~= targetIndex or tabs[targetIndex] ~= tab then
			return false
		end
		if not tab then
			editorRenderedStart = 1
			editorRenderedEnd = 1
			editorRenderedText = ""
			setEditorBoxText("")
			updatePageInfo()
			queueRefreshEditor()
			return true
		end
		const total = math.max(#tab.lines, 1)
		const lineHeight = getEditorWindowMetrics()
		const visibleLine = preserveScroll == true and getEditorVisibleLine(total) or math.clamp(tonumber(tab.viewLine) or 1, 1, total)
		local firstRender, lastRender, firstVisible = getEditorWindowRange(total, visibleLine)
		editorVirtualStart = firstRender
		editorVirtualEnd = lastRender
		tab.viewLine = firstVisible
		const renderedText = NAmanage.ExecutorSliceEditorLines(tab.lines, editorVirtualStart, editorVirtualEnd)
		editorRenderedStart = editorVirtualStart
		editorRenderedEnd = editorVirtualEnd
		editorRenderedText = renderedText
		beginEditorTextSet()
		if preserveScroll ~= true then
			if NAmanage.SetLogicalCanvasPosition then
				NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, (firstVisible - 1) * lineHeight))
			else
				editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (firstVisible - 1) * lineHeight))
			end
		end
		textBox.Text = renderedText
		finishEditorTextSet()
		updatePageInfo()
		queueRefreshEditor()
		return true
	end

	editorGetVisibleLines = function()
		local _, visibleLines = getEditorWindowMetrics()
		return math.max(1, visibleLines)
	end
	editorGetTotalLines = function()
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		return tab and math.max(#tab.lines + 1, editorGetVisibleLines()) or 1
	end
	editorGetViewLine = function()
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		return tab and getEditorVisibleLine(math.max(#tab.lines, 1)) or 1
	end
	editorSetViewLine = function(line)
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		if not tab then
			return
		end
		commitCurrentPage(true)
		const total = math.max(#tab.lines, 1)
		const lineHeight = getEditorWindowMetrics()
		const nextLine = math.clamp(tonumber(line) or 1, 1, total)
		tab.viewLine = nextLine
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, (nextLine - 1) * lineHeight))
		else
			editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (nextLine - 1) * lineHeight))
		end
		loadCurrentPage(true)
	end

	const function turnEditorPage(delta)
		const tab = NAStuff.ExecutorTools.GetCurrentTab()
		if not tab then
			return
		end
		commitCurrentPage()
		local _, windowLines = getEditorWindowMetrics()
		const total = math.max(#tab.lines, 1)
		const currentLine = getEditorVisibleLine(total)
		const nextLine = math.clamp(currentLine + (delta * windowLines), 1, total)
		if nextLine == tab.viewLine then
			updatePageInfo()
			return
		end
		tab.viewLine = nextLine
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, (nextLine - 1) * editorVirtualLineHeight))
		else
			editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, (nextLine - 1) * editorVirtualLineHeight))
		end
		loadCurrentPage()
		scheduleTabsSave()
		setStatus("Scrolled to line "..tostring(nextLine).."/"..tostring(total), colors.subtle)
	end

	editorLineScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if editorLoading then
			return
		end
		local tab = NAStuff.ExecutorTools.GetCurrentTab()
		const total = tab and math.max(#tab.lines, 1) or 1
		local _, _, firstVisible, lastVisible = getEditorWindowRange(total)
		const edgeBuffer = math.max(1, math.floor(editorLineBuffer / 3))
		if firstVisible < editorVirtualStart or lastVisible > editorVirtualEnd or (firstVisible - editorVirtualStart) < edgeBuffer or (editorVirtualEnd - lastVisible) < edgeBuffer then
			commitCurrentPage(true)
			tab = NAStuff.ExecutorTools.GetCurrentTab()
			if tab then
				tab.viewLine = firstVisible
			end
			loadCurrentPage(true)
		else
			gutterLabel.Position = UDim2.new(1, -6, 0, 0)
		end
	end)
	local redirectingEditorScroll = false
	editorScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if editorLoading or redirectingEditorScroll then
			return
		end
		const editorScrollPos = NAmanage.GetLogicalCanvasPosition and NAmanage.GetLogicalCanvasPosition(editorScroll) or editorScroll.CanvasPosition
		const y = tonumber(editorScrollPos.Y) or 0
		if math.abs(y) <= 0.5 then
			return
		end
		redirectingEditorScroll = true
		if executorVerticalScroll and executorVerticalScroll.scrollBy then
			local lineDelta = y / math.max(editorVirtualLineHeight, 1)
			if math.abs(lineDelta) < 1 then
				lineDelta = y > 0 and 1 or -1
			end
			executorVerticalScroll.scrollBy(lineDelta)
		else
			if NAmanage.GetLogicalCanvasPosition and NAmanage.SetLogicalCanvasPosition then
				const editorLinePos = NAmanage.GetLogicalCanvasPosition(editorLineScroll)
				NAmanage.SetLogicalCanvasPosition(editorLineScroll, 0, math.max(0, editorLinePos.Y + y))
			else
				editorLineScroll.CanvasPosition = Vector2.new(0, math.max(0, editorLineScroll.CanvasPosition.Y + y))
			end
		end
		if NAmanage.SetLogicalCanvasPosition then
			NAmanage.SetLogicalCanvasPosition(editorScroll, editorScrollPos.X, 0)
		else
			editorScroll.CanvasPosition = Vector2.new(editorScroll.CanvasPosition.X, 0)
		end
		redirectingEditorScroll = false
	end)
	editorScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if editorLoading then
			return
		end
		const tab = tabs[currentTab]
		if tab and tab.linesDeferred == true then
			queueRefreshEditor()
		elseif NAmanage.ExecutorNormalizeTab(tab) then
			commitCurrentPage(true)
			loadCurrentPage(true)
		else
			queueRefreshEditor()
		end
	end)

	const function handleEditorWheel(input)
		if not input or input.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end
		const wheel = input.Position and input.Position.Z or 0
		if wheel == 0 then
			return
		end
		const step = math.max(24, getEditorLineHeight() * 3)
		const horizontal = Services.UserInputService and (Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or Services.UserInputService:IsKeyDown(Enum.KeyCode.RightShift))
		if horizontal and executorHorizontalScroll and executorHorizontalScroll.scrollBy then
			executorHorizontalScroll.scrollBy(-wheel * step)
		elseif executorVerticalScroll and executorVerticalScroll.scrollBy then
			executorVerticalScroll.scrollBy(-wheel * 3)
		end
	end
	editorScroll.InputChanged:Connect(handleEditorWheel)
	textBox.InputChanged:Connect(handleEditorWheel)

	const function refreshSettingsButtons()
		cfg.fontSize = math.clamp(math.floor((tonumber(cfg.fontSize) or 15) + 0.5), 11, 24)
		cfg.identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8)
		const identitySetterAvailable = type(setthreadidentity) == "function" or type(setidentity) == "function" or type(set_thread_identity) == "function" or type(setthreadcontext) == "function"
		syntaxToggle.Text = cfg.syntax and "On" or "Off"
		syntaxToggle.BackgroundColor3 = cfg.syntax and colors.tabActive or colors.panel3
		lineNumbersToggle.Text = cfg.lineNumbers and "On" or "Off"
		lineNumbersToggle.BackgroundColor3 = cfg.lineNumbers and colors.tabActive or colors.panel3
		scriptHubToggle.Text = cfg.showHub and "On" or "Off"
		scriptHubToggle.BackgroundColor3 = cfg.showHub and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.CurrentThreadToggle.Text = cfg.runInCurrentThread and "On" or "Off"
		NAStuff.ExecutorTools.CurrentThreadToggle.BackgroundColor3 = cfg.runInCurrentThread and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.ThreadIdentityToggle.Text = identitySetterAvailable and (cfg.threadIdentity and "On" or "Off") or "N/A"
		NAStuff.ExecutorTools.ThreadIdentityToggle.BackgroundColor3 = (identitySetterAvailable and cfg.threadIdentity) and colors.tabActive or colors.panel3
		NAStuff.ExecutorTools.ProfileExecutionToggle.Text = cfg.profileExecution and "On" or "Off"
		NAStuff.ExecutorTools.ProfileExecutionToggle.BackgroundColor3 = cfg.profileExecution and colors.tabActive or colors.panel3
		fontValue.Text = tostring(cfg.fontSize)
		NAStuff.ExecutorTools.IdentityValue.Text = tostring(cfg.identityLevel)
	end

	const function updateBodyLayout()
		const function num(v, fallback)
			v = tonumber(v)
			if v == nil or v ~= v or v == math.huge or v == -math.huge then
				return fallback
			end
			return v
		end

		const function clamp(v, min, max)
			min = num(min, 0)
			max = num(max, min)
			if max < min then
				max = min
			end
			return math.clamp(num(v, min), min, max)
		end

		const abs = frame.AbsoluteSize
		const bAbs = body.AbsoluteSize
		const size = frame.Size
		local w = num(abs.X, 0)
		local h = num(abs.Y, 0)
		if w <= 0 then
			w = num(execResponsive.lastW, 0)
		end
		if h <= 0 then
			h = num(execResponsive.lastH, 0)
		end
		if w <= 0 then
			w = num(size.X.Offset, 640)
		end
		if h <= 0 then
			h = num(size.Y.Offset, 420)
		end

		execResponsive.lastW = w
		execResponsive.lastH = h
		execResponsive.compact = w < 760 or h < 430
		execResponsive.phone = w < 560

		const compact = execResponsive.compact
		const gap = compact and 6 or 8
		const pad = compact and 6 or 10
		const showHub = cfg.showHub == true

		rootPad.PaddingBottom = UDim.new(0, pad)
		rootPad.PaddingLeft = UDim.new(0, pad)
		rootPad.PaddingRight = UDim.new(0, pad)
		rootPad.PaddingTop = UDim.new(0, pad)
		tabsBar.Size = UDim2.new(1, 0, 0, compact and 30 or 34)
		body.Position = UDim2.new(0, 0, 0, compact and 36 or 42)
		body.Size = UDim2.new(1, 0, 1, compact and -112 or -92)
		statusLabel.Position = UDim2.new(0, 0, 1, compact and -68 or -42)
		actions.Position = UDim2.new(0, 0, 1, compact and -50 or -22)
		actions.Size = UDim2.new(1, 0, 0, compact and 48 or 28)

		hubPane.Visible = showHub
		editorPane.Visible = true
		if showHub then
			const bodyW = num(bAbs.X, 0)
			const useSplit = bodyW <= 0 or bodyW >= 360
			if useSplit then
				editorPane.Position = UDim2.new(0, 0, 0, 0)
				editorPane.Size = UDim2.new(0.5, -math.ceil(gap / 2), 1, 0)
				hubPane.Position = UDim2.new(0.5, math.floor(gap / 2), 0, 0)
				hubPane.Size = UDim2.new(0.5, -math.floor(gap / 2), 1, 0)
			else
				editorPane.Position = UDim2.new(0, 0, 0, 0)
				editorPane.Size = UDim2.new(0.5, -math.ceil(gap / 2), 1, 0)
				hubPane.Position = UDim2.new(0.5, math.floor(gap / 2), 0, 0)
				hubPane.Size = UDim2.new(0.5, -math.floor(gap / 2), 1, 0)
			end

			const top = compact and 36 or 42
			const innerGap = compact and 6 or 8
			hubButtons.Position = UDim2.new(0, 0, 0, top)
			hubButtons.Size = UDim2.new(0.5, -math.ceil(innerGap / 2), 1, -top)
			hubList.Position = UDim2.new(0.5, math.floor(innerGap / 2), 0, top)
			hubList.Size = UDim2.new(0.5, -math.floor(innerGap / 2), 1, -top)
		else
			editorPane.Position = UDim2.new(0, 0, 0, 0)
			editorPane.Size = UDim2.new(1, 0, 1, 0)
		end

		const actionPad = w < 420 and 2 or (compact and 4 or 6)
		const actionColumns = compact and math.ceil(actionButtonCount / 2) or actionButtonCount
		actionLayout.CellPadding = UDim2.new(0, actionPad, 0, compact and 4 or 0)
		actionLayout.CellSize = UDim2.new(1 / math.max(1, actionColumns), -actionPad, 0, compact and 22 or 28)
		actionLayout.FillDirectionMaxCells = actionColumns
		hubButtons.ScrollBarThickness = compact and 3 or 4
		for _, btn in { hubOpen, hubOpenNew, hubSave, hubClear, hubNew, hubDelete, hubRefresh, NAStuff.ExecutorTools.HubStopLast } do
			btn.Size = UDim2.new(1, -2, 0, compact and 22 or 26)
			btn.TextSize = compact and 11 or 13
		end
		const actionButtons = { safeExecuteButton, executeButton, clearButton, copyButton, newLineButton }
		if pasteButton then
			actionButtons[#actionButtons + 1] = pasteButton
		end
		actionButtons[#actionButtons + 1] = formatButton
		actionButtons[#actionButtons + 1] = NAStuff.ExecutorTools.DeobfuscateButton
		actionButtons[#actionButtons + 1] = NAStuff.ExecutorTools.ObfuscateButton
		actionButtons[#actionButtons + 1] = renameButton
		actionButtons[#actionButtons + 1] = duplicateButton
		actionButtons[#actionButtons + 1] = deleteTabButton
		for _, btn in actionButtons do
			const longAction = btn == pasteButton or btn == NAStuff.ExecutorTools.DeobfuscateButton or btn == NAStuff.ExecutorTools.ObfuscateButton
			btn.TextSize = longAction and (compact and 9 or 10) or (compact and 11 or 13)
		end
		cfg.fontSize = clamp(math.floor(num(cfg.fontSize, 15) + 0.5), 11, 24)
		textBox.TextSize = clamp(cfg.fontSize + (compact and -2 or 0), 10, 24)
		gutterLabel.TextSize = textBox.TextSize
		for _, layer in { keywordLayer, globalLayer, stringLayer, commentLayer, numberLayer, functionLayer, methodLayer, propertyLayer, operatorLayer, bracketLayer } do
			layer.TextSize = textBox.TextSize
		end
	end

	const function queueExecutorResponsive(resizeFrame)
		if resizeFrame == true then
			applyExecutorFrameSize()
		end
		updateBodyLayout()
		Defer(function()
			if frame and frame.Parent then
				updateBodyLayout()
			end
		end)
		const tab = tabs[currentTab]
		if tab and tab.linesDeferred == true then
			queueRefreshEditor()
		elseif NAmanage.ExecutorNormalizeTab(tab) then
			commitCurrentPage(true)
			loadCurrentPage(true)
		else
			queueRefreshEditor()
		end
	end

	const function applySettings(skipSave)
		cfg.syntax = cfg.syntax == true
		cfg.lineNumbers = cfg.lineNumbers == true
		cfg.showHub = cfg.showHub ~= false
		cfg.runInCurrentThread = cfg.runInCurrentThread == true
		cfg.threadIdentity = cfg.threadIdentity == true
		cfg.profileExecution = cfg.profileExecution == true
		cfg.identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8)
		cfg.fontSize = math.clamp(math.floor((tonumber(cfg.fontSize) or 15) + 0.5), 11, 24)
		for _, layer in { keywordLayer, globalLayer, stringLayer, commentLayer, numberLayer, functionLayer, methodLayer, propertyLayer, operatorLayer, bracketLayer } do
			layer.Visible = cfg.syntax
		end
		gutter.Visible = cfg.lineNumbers
		updateBodyLayout()
		refreshSettingsButtons()
		queueRefreshEditor()
		if not skipSave then
			if saveSettings() then
				setStatus("Saved executor settings", colors.success)
			else
				setStatus("Executor settings changed locally", colors.warn)
			end
		end
	end

	const function updateTabButtonVisuals()
		for index, tab in tabs do
			if tab.holder and tab.label and tab.close then
				const isCurrent = index == currentTab
				tab.holder.BackgroundColor3 = isCurrent and colors.tabActive or colors.tabIdle
				tab.label.TextColor3 = isCurrent and colors.tabTextActive or colors.tabTextIdle
				tab.close.TextColor3 = isCurrent and colors.tabTextActive or colors.tabTextIdle
			end
		end
	end

	const function renameTab(index)
		const tab = tabs[index]
		if not tab then
			return
		end
		showPrompt("Rename tab", tab.title or "", function(okPressed, value)
			if not okPressed then
				return
			end
			value = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if value == "" then
				value = "Tab "..index
			end
			tab.title = value
			if tab.label then
				tab.label.Text = value
				const width = TextServiceRef:GetTextSize(value, 13, Enum.Font.GothamSemibold, Vector2.new(1000, 1000)).X + 46
				tab.holder.Size = UDim2.new(0, math.clamp(width, 96, 230), 0, 28)
			end
			updateTabCanvas()
			scheduleTabsSave()
			setStatus("Renamed tab", colors.success)
		end)
	end

	const function selectTab(index, skipCommit, skipSave)
		const tab = tabs[index]
		if not tab then
			return
		end
		if editorLoaded and skipCommit ~= true then
			commitCurrentPage(true)
		end
		currentTab = index
		const wasDeferred = tab.linesDeferred == true
		if wasDeferred then
			setStatus("Loading "..tostring(tab.title or ("Tab "..index)).."...", colors.warn)
		end
		const loaded = loadCurrentPage()
		if loaded == false or currentTab ~= index then
			return
		end
		editorLoaded = true
		updateTabButtonVisuals()
		if skipSave ~= true then
			scheduleTabsSave()
		end
		if wasDeferred then
			setStatus("Loaded "..tostring(tab.title or ("Tab "..index)), colors.success)
		end
	end

	const function closeTab(index)
		if #tabs <= 1 then
			setTabFullText(tabs[currentTab], "")
			loadCurrentPage()
			scheduleTabsSave()
			setStatus("Cleared current tab", colors.warn)
			return
		end
		const wasCurrent = index == currentTab
		if editorLoaded and not wasCurrent then
			commitCurrentPage(true)
		end
		const tab = tabs[index]
		if tab and tab.holder then
			tab.holder:Destroy()
		end
		table.remove(tabs, index)
		if wasCurrent then
			currentTab = math.clamp(index, 1, #tabs)
		elseif currentTab > #tabs then
			currentTab = #tabs
		elseif currentTab > index then
			currentTab -= 1
		end
		for tabIndex, entry in tabs do
			if (entry.title or "") == "" then
				entry.title = "Tab "..tabIndex
			end
		end
		selectTab(currentTab, true)
		setStatus("Deleted tab", colors.warn)
	end

	const function createTab(initialText, initialTitle, deferLines)
		const tab = {
			title = initialTitle and tostring(initialTitle) or ("Tab "..(#tabs + 1)),
			text = tostring(initialText or ""),
		}
		if deferLines == true then
			tab.linesDeferred = true
			tab.viewLine = 1
			tab.page = 1
			tab.chunks = { tab.text }
			tab.textDirty = false
		else
			NAmanage.ExecutorNormalizeTab(tab)
		end
		const holder = InstanceNew("Frame")
		holder.BackgroundColor3 = colors.tabIdle
		holder.BorderSizePixel = 0
		holder.Size = UDim2.new(0, 120, 0, 28)
		holder.Parent = tabWrap
		makeCornerAndStroke(holder, 8, 1)

		const openButton = InstanceNew("TextButton")
		openButton.AutoButtonColor = false
		openButton.BackgroundTransparency = 1
		openButton.BorderSizePixel = 0
		openButton.Position = UDim2.new(0, 10, 0, 0)
		openButton.Size = UDim2.new(1, -34, 1, 0)
		openButton.Font = Enum.Font.GothamSemibold
		openButton.Text = tab.title
		openButton.TextColor3 = colors.tabTextIdle
		openButton.TextSize = 13
		openButton.TextXAlignment = Enum.TextXAlignment.Left
		openButton.Parent = holder

		const closeButton = InstanceNew("TextButton")
		closeButton.AutoButtonColor = false
		closeButton.BackgroundTransparency = 1
		closeButton.BorderSizePixel = 0
		closeButton.Position = UDim2.new(1, -24, 0, 0)
		closeButton.Size = UDim2.new(0, 24, 1, 0)
		closeButton.Font = Enum.Font.GothamBold
		closeButton.Text = "×"
		closeButton.TextColor3 = colors.tabTextIdle
		closeButton.TextSize = 13
		closeButton.Parent = holder

		tab.holder = holder
		tab.label = openButton
		tab.close = closeButton
		tabs[#tabs + 1] = tab

		const width = TextServiceRef:GetTextSize(tab.title, 13, Enum.Font.GothamSemibold, Vector2.new(1000, 1000)).X + 46
		holder.Size = UDim2.new(0, math.clamp(width, 96, 230), 0, 28)

		openButton.MouseButton1Click:Connect(function()
			const tabIndex = Discover(tabs, tab)
			if not tabIndex then
				return
			end
			const now = os.clock()
			if lastTabClickIndex == tabIndex and (now - lastTabClickTime) <= 0.35 then
				renameTab(tabIndex)
			else
				selectTab(tabIndex)
			end
			lastTabClickIndex = tabIndex
			lastTabClickTime = now
		end)
		closeButton.MouseButton1Click:Connect(function()
			const tabIndex = Discover(tabs, tab)
			if tabIndex then
				closeTab(tabIndex)
			end
		end)
		updateTabCanvas()
		return #tabs
	end

	const function readScriptFile(name)
		if not (fsOk and name) then
			return nil
		end
		const path = scriptPath(name)
		if not isfile(path) then
			return nil
		end
		local ok, data = pcall(readfile, path)
		if ok and type(data) == "string" then
			return data
		end
		return nil
	end

	const function selectSavedScript(name, opts)
		opts = type(opts) == "table" and opts or {}
		if opts.toggle == true and selectedScript == name then
			name = nil
		end
		selectedScript = name
		hubSubtitle.Text = name and ("Selected: "..name) or "No script selected"
		for _, child in hubList:GetChildren() do
			if child:IsA("TextButton") then
				if child.SetAttribute then
					NAmanage.SetAttr(child, "NAExecutorSelected", child.Name == (name or ""))
				end
				child.BackgroundColor3 = (child.Name == (name or "")) and colors.tabActive or colors.panel3
			end
		end
	end

	const function refreshSavedScripts()
		const workState = { lastYield = os.clock() }
		for _, child in hubList:GetChildren() do
			if child:IsA("TextButton") then
				child:Destroy()
				NAmanage.ExecutorYieldWork(workState)
			end
		end
		const names = {}
		const seen = {}
		const function pushName(name, fromDisk)
			if type(name) ~= "string" then
				return
			end
			name = name:match("([^/\\]+)$") or name
			name = sanitizeScriptName(name)
			if not isScriptFileName(name) then
				return
			end
			if fromDisk ~= true and fsOk and type(isfile) == "function" and not isfile(scriptPath(name)) then
				return
			end
			const key = name:lower()
			if seen[key] then
				return
			end
			seen[key] = true
			names[#names + 1] = name
		end
		if fsOk and listOk then
			ensureExecutorFolders()
			local ok, files = pcall(listfiles, scriptsDir)
			if ok and type(files) == "table" then
				for _, file in files do
					pushName(file, true)
				end
			end
		end
		for _, name in readScriptIndex() do
			pushName(name, false)
		end
		table.sort(names, function(a, b)
			return a:lower() < b:lower()
		end)
		saveScriptIndex(names)
		local selectedAlive = selectedScript == nil
		for _, name in names do
			if selectedScript and name:lower() == tostring(selectedScript):lower() then
				selectedAlive = true
			end
			const item = makeButton(hubList, name, colors.panel3)
			item.Name = name
			item.Size = UDim2.new(1, 0, 0, 28)
			item.TextSize = 12
			item.TextXAlignment = Enum.TextXAlignment.Left
			item.MouseButton1Click:Connect(function()
				selectSavedScript(name, { toggle = true })
			end)
			NAmanage.ExecutorYieldWork(workState)
		end
		if not selectedAlive then
			selectedScript = nil
		end
		hubList.CanvasSize = UDim2.new(0, 0, 0, hubListLayout.AbsoluteContentSize.Y + 14)
		selectSavedScript(selectedScript)
	end

	hubListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		hubList.CanvasSize = UDim2.new(0, 0, 0, hubListLayout.AbsoluteContentSize.Y + 14)
	end)

	const function getCurrentScriptName()
		const tab = tabs[currentTab]
		local title = tab and tab.title or selectedScript or "script"
		title = stripLuauExt(title)
		if title == "" or title:match("^Tab%s*%d+$") then
			title = "Script_"..os.date("%Y%m%d_%H%M%S")
		end
		return title
	end

	const function saveCurrentScriptAs(name)
		if not fsOk then
			setStatus("Filesystem unavailable", colors.error)
			return false
		end
		if not ensureExecutorFolders() then
			setStatus("Failed to create Scripts folder", colors.error)
			return false
		end
		syncCurrentTabText()
		const fileName = sanitizeScriptName(name)
		const path = scriptPath(fileName)
		local ok, err = pcall(writefile, path, NAmanage.ExecutorGetTabText(tabs[currentTab]))
		if ok and (type(isfile) ~= "function" or isfile(path)) then
			addScriptIndex(fileName)
			refreshSavedScripts()
			selectSavedScript(fileName)
			setStatus("Saved script: "..fileName, colors.success)
			return true
		end
		setStatus("Failed to save script: "..tostring(err or "writefile failed"), colors.error)
		return false
	end

	const function promptSaveCurrentScript()
		saveCurrentScriptAs(selectedScript or getCurrentScriptName())
	end

	const function loadSavedScriptIntoCurrent(newTab)
		if not selectedScript then
			setStatus("Select a saved script first", colors.warn)
			return
		end
		const source = readScriptFile(selectedScript)
		if type(source) ~= "string" then
			setStatus("Could not read saved script", colors.error)
			return
		end
		if newTab then
			const tabIndex = createTab(source, stripLuauExt(selectedScript), true)
			selectTab(tabIndex)
			setStatus("Opened "..selectedScript.." in a new tab", colors.success)
		else
			if tabs[currentTab] then
				setTabFullText(tabs[currentTab], source, true)
				if (tabs[currentTab].title or "") == "" or tabs[currentTab].title:match("^Tab %d+$") then
					tabs[currentTab].title = stripLuauExt(selectedScript)
					tabs[currentTab].label.Text = tabs[currentTab].title
					const width = TextServiceRef:GetTextSize(tabs[currentTab].title, 13, Enum.Font.GothamSemibold, Vector2.new(1000, 1000)).X + 46
					tabs[currentTab].holder.Size = UDim2.new(0, math.clamp(width, 96, 230), 0, 28)
				end
			end
			loadCurrentPage()
			updateTabButtonVisuals()
			scheduleTabsSave()
			setStatus("Loaded "..selectedScript, colors.success)
		end
	end

	NAmanage.Executor_LoadTabsFromDisk = function()
		local loaded = false
		const workState = { lastYield = os.clock() }
		if fsOk and isfile(tabsFile) then
			local ok, raw = pcall(readfile, tabsFile)
			if ok and raw and raw ~= "" then
				local okDecode, decoded = pcall(Services.HttpService.JSONDecode, Services.HttpService, raw)
				if okDecode and type(decoded) == "table" then
					if type(decoded.tabs) == "table" then
						for index, entry in decoded.tabs do
							if type(entry) == "table" then
								createTab(entry.text or "", entry.title or ("Tab "..index), true)
								loaded = true
							elseif type(entry) == "string" then
								createTab(entry, "Tab "..index, true)
								loaded = true
							end
							NAmanage.ExecutorYieldWork(workState)
						end
						currentTab = math.clamp(tonumber(decoded.cur) or 1, 1, math.max(#tabs, 1))
					elseif type(decoded[1]) == "string" then
						for index, entry in decoded do
							createTab(entry, "Tab "..index, true)
							loaded = true
							NAmanage.ExecutorYieldWork(workState)
						end
						currentTab = 1
					end
				end
			end
		end
		if not loaded then
			createTab("", "Tab 1")
			currentTab = 1
		end
		NAStuff.ExecutorTools.TabsLoaded = true
	end

	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		if not editorLoading and editorTextLock <= 0 then
			syncCurrentTabText()
		end
		queueRefreshEditor()
	end)
	textBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		const cursor = tonumber(textBox.CursorPosition) or -1
		if cursor > 0 then
			editorLastCursorPosition = cursor
		end
	end)
	textBox.FocusLost:Connect(function()
		if editorLoaded and type(saveTabsNow) == "function" then
			saveTabsNow()
		end
	end)

	addTabButton.MouseButton1Click:Connect(function()
		const tabIndex = createTab("", "Tab "..(#tabs + 1))
		selectTab(tabIndex)
		scheduleTabsSave()
		setStatus("Created a new tab", colors.success)
	end)

	if settingsButton then
		settingsButton.MouseButton1Click:Connect(function()
			NAmanage.ExecutorPlaceSettingsPanel(settingsPanel)
			settingsPanel.Visible = not settingsPanel.Visible
		end)
	end
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		NAmanage.ExecutorPlaceSettingsPanel(settingsPanel)
	end)

	NAmanage.ExecutorBindSetting(syntaxToggle, syntaxHit, cfg, "syntax", applySettings)
	NAmanage.ExecutorBindSetting(lineNumbersToggle, lineNumbersHit, cfg, "lineNumbers", applySettings)
	NAmanage.ExecutorBindSetting(scriptHubToggle, scriptHubHit, cfg, "showHub", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.CurrentThreadToggle, NAStuff.ExecutorTools.CurrentThreadHit, cfg, "runInCurrentThread", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.ThreadIdentityToggle, NAStuff.ExecutorTools.ThreadIdentityHit, cfg, "threadIdentity", applySettings)
	NAmanage.ExecutorBindSetting(NAStuff.ExecutorTools.ProfileExecutionToggle, NAStuff.ExecutorTools.ProfileExecutionHit, cfg, "profileExecution", applySettings)
	fontMinus.MouseButton1Click:Connect(function()
		cfg.fontSize = math.clamp((tonumber(cfg.fontSize) or 15) - 1, 11, 24)
		applySettings(false)
	end)
	fontPlus.MouseButton1Click:Connect(function()
		cfg.fontSize = math.clamp((tonumber(cfg.fontSize) or 15) + 1, 11, 24)
		applySettings(false)
	end)
	NAStuff.ExecutorTools.IdentityMinus.MouseButton1Click:Connect(function()
		cfg.identityLevel = math.clamp((tonumber(cfg.identityLevel) or 8) - 1, 0, 8)
		applySettings(false)
	end)
	NAStuff.ExecutorTools.IdentityPlus.MouseButton1Click:Connect(function()
		cfg.identityLevel = math.clamp((tonumber(cfg.identityLevel) or 8) + 1, 0, 8)
		applySettings(false)
	end)

	MouseButtonFix(pagePrev, function()
		turnEditorPage(-1)
	end)
	MouseButtonFix(pageNext, function()
		turnEditorPage(1)
	end)

	NAStuff.ExecutorTools.LastThread = nil
	NAStuff.ExecutorTools.LastStartedAt = 0

	NAStuff.ExecutorTools.ThreadStatus = function(thread)
		if type(thread) ~= "thread" then
			return "none"
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Status = pcall(coroutine.status, thread)
		return NAStuff.ExecutorTools.Ok and tostring(NAStuff.ExecutorTools.Status) or "unknown"
	end

	NAStuff.ExecutorTools.MemoryKb = function()
		if type(collectgarbage) ~= "function" then
			return nil
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Value = pcall(collectgarbage, "count")
		if NAStuff.ExecutorTools.Ok and type(NAStuff.ExecutorTools.Value) == "number" then
			return NAStuff.ExecutorTools.Value
		end
		return nil
	end

	NAStuff.ExecutorTools.GetIdentity = function()
		NAStuff.ExecutorTools.IdentityGetter = type(getthreadidentity) == "function" and getthreadidentity
			or type(getidentity) == "function" and getidentity
			or type(get_thread_identity) == "function" and get_thread_identity
			or type(getthreadcontext) == "function" and getthreadcontext
		if type(NAStuff.ExecutorTools.IdentityGetter) ~= "function" then
			return nil
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Value = pcall(NAStuff.ExecutorTools.IdentityGetter)
		if NAStuff.ExecutorTools.Ok then
			return NAStuff.ExecutorTools.Value
		end
		return nil
	end

	NAStuff.ExecutorTools.SetIdentity = function(level)
		NAStuff.ExecutorTools.IdentitySetter = type(setthreadidentity) == "function" and setthreadidentity
			or type(setidentity) == "function" and setidentity
			or type(set_thread_identity) == "function" and set_thread_identity
			or type(setthreadcontext) == "function" and setthreadcontext
		if type(NAStuff.ExecutorTools.IdentitySetter) ~= "function" then
			return false, "setthreadidentity unavailable"
		end
		NAStuff.ExecutorTools.Ok, NAStuff.ExecutorTools.Err = pcall(NAStuff.ExecutorTools.IdentitySetter, level)
		if not NAStuff.ExecutorTools.Ok then
			return false, NAStuff.ExecutorTools.Err
		end
		return true
	end

	NAStuff.ExecutorTools.RunFunction = function(fn)
		NAStuff.ExecutorTools.OldIdentity = nil
		NAStuff.ExecutorTools.IdentityChanged = false
		if cfg.threadIdentity == true then
			cfg.identityLevel = math.clamp(math.floor((tonumber(cfg.identityLevel) or 8) + 0.5), 0, 8)
			NAStuff.ExecutorTools.OldIdentity = NAStuff.ExecutorTools.GetIdentity() or 2
			NAStuff.ExecutorTools.OkSet, NAStuff.ExecutorTools.SetErr = NAStuff.ExecutorTools.SetIdentity(cfg.identityLevel)
			if not NAStuff.ExecutorTools.OkSet then
				return false, tostring(NAStuff.ExecutorTools.SetErr or "setthreadidentity unavailable")
			end
			NAStuff.ExecutorTools.IdentityChanged = true
		end

		NAStuff.ExecutorTools.StartClock = os.clock()
		NAStuff.ExecutorTools.StartMem = NAStuff.ExecutorTools.MemoryKb()
		NAStuff.ExecutorTools.RunOk, NAStuff.ExecutorTools.RunErr = xpcall(fn, function(err)
			NAStuff.ExecutorTools.Traceback = "debug.traceback unavailable"
			if type(debug) == "table" and type(debug.traceback) == "function" then
				NAStuff.ExecutorTools.OkTb, NAStuff.ExecutorTools.TbResult = pcall(debug.traceback, nil, 2)
				if NAStuff.ExecutorTools.OkTb and NAStuff.ExecutorTools.TbResult then
					NAStuff.ExecutorTools.Traceback = tostring(NAStuff.ExecutorTools.TbResult)
				end
			end
			return tostring(err).."\n"..NAStuff.ExecutorTools.Traceback
		end)

		if NAStuff.ExecutorTools.IdentityChanged and NAStuff.ExecutorTools.OldIdentity ~= nil then
			pcall(NAStuff.ExecutorTools.SetIdentity, NAStuff.ExecutorTools.OldIdentity)
		end

		if NAStuff.ExecutorTools.RunOk then
			if cfg.profileExecution == true then
				NAStuff.ExecutorTools.Duration = math.max(os.clock() - NAStuff.ExecutorTools.StartClock, 0)
				NAStuff.ExecutorTools.EndMem = NAStuff.ExecutorTools.MemoryKb()
				NAStuff.ExecutorTools.Suffix = Format(" (%.3fs", NAStuff.ExecutorTools.Duration)
				if NAStuff.ExecutorTools.StartMem and NAStuff.ExecutorTools.EndMem then
					NAStuff.ExecutorTools.Suffix ..= Format(", %.1f KB", NAStuff.ExecutorTools.EndMem - NAStuff.ExecutorTools.StartMem)
				end
				NAStuff.ExecutorTools.Suffix ..= ")"
				return true, "Execution finished"..NAStuff.ExecutorTools.Suffix
			end
			return true, "Execution finished"
		end
		return false, tostring(NAStuff.ExecutorTools.RunErr)
	end


	safeExecuteButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const source = NAmanage.ExecutorGetTabText(tabs[currentTab])
		if source == "" then
			setStatus("Nothing to execute", colors.warn)
			return
		end
		setStatus("Queueing safe execution...", colors.warn)
		const chunkName = "Executor/"..(tabs[currentTab] and (tabs[currentTab].title or ("Tab "..currentTab)) or "Script")
		local okRun, runErr = NAmanage.RunSource(source, chunkName)
		if okRun then
			setStatus("Safe execution queued", colors.success)
		else
			setStatus(tostring(runErr or "Safe execution failed"), colors.error)
		end
	end)

	executeButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const source = NAmanage.ExecutorGetTabText(tabs[currentTab])
		if source == "" then
			setStatus("Nothing to execute", colors.warn)
			return
		end
		setStatus("Running script...", colors.warn)
		const chunkName = "Executor/"..(tabs[currentTab] and (tabs[currentTab].title or ("Tab "..currentTab)) or "Script")
		local fn, loadErr = NAmanage.RawCompile(source, chunkName)
		if not fn then
			setStatus(tostring(loadErr), colors.error)
			return
		end
		NAStuff.ExecutorTools.LastStartedAt = os.clock()
		if cfg.runInCurrentThread == true then
			NAStuff.ExecutorTools.LastThread = nil
			local okRun, result = NAStuff.ExecutorTools.RunFunction(fn)
			setStatus(result, okRun and colors.success or colors.error)
			return
		end
		NAStuff.ExecutorTools.LastThread = Spawn(function()
			local okRun, result = NAStuff.ExecutorTools.RunFunction(fn)
			pcall(Defer, setStatus, result, okRun and colors.success or colors.error)
		end)
	end)
	clearButton.MouseButton1Click:Connect(function()
		setTabFullText(tabs[currentTab], "")
		loadCurrentPage()
		scheduleTabsSave()
		setStatus("Cleared current tab", colors.warn)
	end)
	copyButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const ok = pcall(setclipboard, NAmanage.ExecutorGetTabText(tabs[currentTab]))
		if ok then
			setStatus("Copied tab contents", colors.success)
		else
			setStatus("Clipboard unavailable", colors.error)
		end
	end)
	newLineButton.MouseButton1Click:Connect(function()
		insertEditorNewLine()
	end)
	if pasteButton then
		pasteButton.MouseButton1Click:Connect(function()
			local ok, clip = pcall(getclipboard)
			if not ok or type(clip) ~= "string" then
				setStatus("Clipboard unavailable", colors.error)
				return
			end
			const currentText = tostring(textBox.Text or "")
			const cursor = tonumber(textBox.CursorPosition) or -1
			const selectionStart = tonumber(textBox.SelectionStart) or -1
			local startPos
			local endPos
			if cursor > 0 and selectionStart > 0 and cursor ~= selectionStart then
				startPos = math.min(cursor, selectionStart)
				endPos = math.max(cursor, selectionStart) - 1
			else
				startPos = cursor > 0 and cursor or (#currentText + 1)
				endPos = startPos - 1
			end
			startPos = math.clamp(startPos, 1, #currentText + 1)
			endPos = math.clamp(endPos, 0, #currentText)
			setEditorBoxText(currentText:sub(1, startPos - 1)..clip..currentText:sub(endPos + 1))
			pcall(function()
				textBox.CursorPosition = math.clamp(startPos + #clip, 1, #textBox.Text + 1)
			end)
			commitCurrentPage(true)
			scheduleTabsSave()
			queueRefreshEditor()
			setStatus("Pasted clipboard", colors.success)
		end)
	end
	formatButton.MouseButton1Click:Connect(function()
		if NAStuff.ExecutorTools.FormatBusy == true then
			setStatus("Formatter is already running", colors.warn)
			return
		end
		commitCurrentPage(true)
		const tab = tabs[currentTab]
		const source = NAmanage.ExecutorGetTabText(tab)
		if source:gsub("%s+", "") == "" then
			setStatus("Nothing to format", colors.warn)
			return
		end
		NAStuff.ExecutorTools.FormatBusy = true
		formatButton.Text = "Formatting..."
		setStatus("Formatting Luau script...", colors.warn)
		Spawn(function()
			local okFormat, formatted, formatErr = pcall(NAmanage.ExecutorFormatLuauSource, source)
			if not okFormat then
				formatErr = formatted
				formatted = nil
			end
			Defer(function()
				NAStuff.ExecutorTools.FormatBusy = false
				if formatButton and formatButton.Parent then
					formatButton.Text = "Format"
				end
				if type(formatted) ~= "string" then
					setStatus(tostring(formatErr or "Formatting failed"), colors.error)
					return
				end
				if NAmanage.ExecutorGetTabText(tab) ~= source then
					setStatus("Format cancelled because the tab changed", colors.warn)
					return
				end
				if formatted == source then
					setStatus("Already formatted", colors.subtle)
					return
				end
				setTabFullText(tab, formatted, true)
				scheduleTabsSave()
				if tabs[currentTab] == tab then
					loadCurrentPage()
					setStatus("Formatted Luau script (validated)", colors.success)
				else
					setStatus("Formatted tab in background", colors.success)
				end
			end)
		end)
	end)
	NAStuff.ExecutorTools.DeobfuscateButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		local targetTab = tabs[currentTab]
		local source = NAmanage.ExecutorGetTabText(targetTab)
		if source:gsub("%s+", "") == "" then
			setStatus("Nothing to deobfuscate", colors.warn)
			return
		end
		setStatus("Auto-detecting obfuscation...", colors.warn)
		Spawn(function()
			local okDecode, decoded, applied = pcall(NAStuff.ExecutorCodec.AutoDeobfuscate, source)
			if not okDecode then
				Defer(setStatus, "Deobfuscation failed: "..tostring(decoded), colors.error)
				return
			end
			if type(decoded) ~= "string" or decoded == source then
				Defer(setStatus, "No supported obfuscation layer detected", colors.warn)
				return
			end
			Defer(function()
				setTabFullText(targetTab, decoded, true)
				if tabs[currentTab] == targetTab then loadCurrentPage() end
				scheduleTabsSave()
				local detail = type(applied) == "table" and table.concat(applied, " -> ") or "decoded"
				if #detail > 96 then detail = detail:sub(1, 93).."..." end
				setStatus("Deobfuscated: "..detail, colors.success)
			end)
		end)
	end)
	NAStuff.ExecutorTools.RunObfuscateMode = function(mode)
		commitCurrentPage(true)
		local targetTab = tabs[currentTab]
		local source = NAmanage.ExecutorGetTabText(targetTab)
		if source:gsub("%s+", "") == "" then
			setStatus("Nothing to obfuscate", colors.warn)
			return
		end
		setStatus("Obfuscating script...", colors.warn)
		Spawn(function()
			local okObfuscate, encoded, selectedMode, transformErr = pcall(NAStuff.ExecutorCodec.Obfuscate, source, mode)
			if not okObfuscate then
				Defer(setStatus, "Obfuscation failed: "..tostring(encoded), colors.error)
				return
			end
			if type(encoded) ~= "string" then
				Defer(setStatus, tostring(transformErr or "Unsupported obfuscation mode"), colors.error)
				return
			end
			local compiled, compileErr = loadstring(encoded, "Executor/ObfuscationCheck")
			if not compiled then
				Defer(setStatus, "Generated wrapper failed compile check: "..tostring(compileErr), colors.error)
				return
			end
			Defer(function()
				setTabFullText(targetTab, encoded, true)
				if tabs[currentTab] == targetTab then loadCurrentPage() end
				scheduleTabsSave()
				setStatus("Obfuscated ("..tostring(selectedMode or mode or "Auto").."): "..tostring(#source).." -> "..tostring(#encoded).." bytes", colors.success)
			end)
		end)
	end
	NAStuff.ExecutorTools.ObfuscateButton.MouseButton1Click:Connect(function()
		NAStuff.ExecutorTools.ObfuscationMenu.Show()
	end)
	renameButton.MouseButton1Click:Connect(function()
		renameTab(currentTab)
	end)
	duplicateButton.MouseButton1Click:Connect(function()
		commitCurrentPage(true)
		const tab = tabs[currentTab]
		const tabIndex = createTab(tab and NAmanage.ExecutorGetTabText(tab) or "", tab and ((tab.title or "Tab").." Copy") or "Copy", true)
		selectTab(tabIndex)
		scheduleTabsSave()
		setStatus("Duplicated tab", colors.success)
	end)
	deleteTabButton.MouseButton1Click:Connect(function()
		closeTab(currentTab)
		scheduleTabsSave()
	end)

	hubOpen.MouseButton1Click:Connect(function()
		loadSavedScriptIntoCurrent(false)
	end)
	hubOpenNew.MouseButton1Click:Connect(function()
		loadSavedScriptIntoCurrent(true)
	end)
	hubSave.MouseButton1Click:Connect(function()
		const target = selectedScript or getCurrentScriptName()
		saveCurrentScriptAs(target)
	end)
	hubClear.MouseButton1Click:Connect(function()
		selectSavedScript(nil)
		setStatus("Cleared saved script selection", colors.subtle)
	end)
	hubNew.MouseButton1Click:Connect(function()
		selectSavedScript(nil)
		const tabIndex = createTab("", "Script_"..os.date("%Y%m%d_%H%M%S"))
		selectTab(tabIndex)
		scheduleTabsSave()
		setStatus("Created a new script tab", colors.success)
	end)
	hubDelete.MouseButton1Click:Connect(function()
		if not selectedScript then
			setStatus("Select a saved script first", colors.warn)
			return
		end
		if not (fsOk and delOk) then
			setStatus("Delete is unavailable here", colors.error)
			return
		end
		ensureExecutorFolders()
		const deleting = selectedScript
		const ok = pcall(delfile, scriptPath(deleting))
		if ok then
			removeScriptIndex(deleting)
			selectedScript = nil
			refreshSavedScripts()
			selectSavedScript(nil)
			setStatus("Deleted "..deleting, colors.warn)
		else
			setStatus("Failed to delete "..deleting, colors.error)
		end
	end)
	hubRefresh.MouseButton1Click:Connect(function()
		refreshSavedScripts()
		setStatus("Refreshed saved scripts", colors.success)
	end)
	NAStuff.ExecutorTools.HubStopLast.MouseButton1Click:Connect(function()
		if type(task) ~= "table" or type(task.cancel) ~= "function" then
			setStatus("task.cancel unavailable", colors.error)
			return
		end
		if NAStuff.ExecutorTools.ThreadStatus(NAStuff.ExecutorTools.LastThread) ~= "suspended" then
			setStatus("No cancellable executor task", colors.warn)
			return
		end
		local okCancel, cancelErr = pcall(task.cancel, NAStuff.ExecutorTools.LastThread)
		if okCancel then
			setStatus("Cancel requested for last executor task", colors.warn)
		else
			setStatus(tostring(cancelErr), colors.error)
		end
	end)

	queueExecutorResponsive(true)
	NAlib.disconnect("NAExecutorResponsive")
	if Services.Workspace and Services.Workspace.CurrentCamera then
		NAlib.connect("NAExecutorResponsive", Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			queueExecutorResponsive(false)
		end))
	end
	if NAStuff and NAStuff.NASCREENGUI then
		NAlib.connect("NAExecutorResponsive", NAStuff.NASCREENGUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			queueExecutorResponsive(false)
		end))
	end
	NAlib.connect("NAExecutorResponsive", frame:GetPropertyChangedSignal("Size"):Connect(saveExecutorFrameSize))
	NAlib.connect("NAExecutorResponsive", frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateBodyLayout()
		queueRefreshEditor()
	end))

	applySettings(true)
	NAStuff.ExecutorRefresh = queueRefreshEditor
	NAStuff.ExecutorSaveTabs = saveTabsNow
	setStatus("Loading executor data...", colors.warn)
	Defer(function()
		if not (frame and frame.Parent) then
			return
		end
		NAmanage.Executor_LoadTabsFromDisk()
		selectTab(currentTab, true, true)
		refreshSavedScripts()
		queueRefreshEditor()
		setStatus("Executor ready", colors.success)
	end)
	return true
end

NAmanage.Executor_Toggle = NAmanage.Executor_Toggle or function(forceState)
	if not (NAUIMANAGER and NAUIMANAGER.ExecutorFrame) then
		local ok, err = pcall(function()
			NAmanage.RunURL("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/NAexecutor.lua")
		end)
		if not ok then
			DoNotif("Executor UI unavailable: "..tostring(err), 3)
		end
		return false
	end
	if NAUIMANAGER.ExecutorFrame.GetAttribute and NAmanage.GetAttr(NAUIMANAGER.ExecutorFrame, "NAExecutorReady") ~= true then
		if NAmanage.pulseLoadingUI then
			NAmanage.pulseLoadingUI("building executor on demand", 0.99)
		end
	end
	NAmanage.Executor_Init()
	const execFrame = NAUIMANAGER.ExecutorFrame
	local nextState = forceState
	if type(nextState) ~= "boolean" then
		nextState = not execFrame.Visible
	end
	if execFrame.Visible and nextState == false then
		if type(NAmanage.Executor_SaveFrameSize) == "function" then
			pcall(NAmanage.Executor_SaveFrameSize)
		end
		if type(NAStuff.ExecutorSaveTabs) == "function" then
			pcall(NAStuff.ExecutorSaveTabs)
		end
	end
	execFrame.Visible = nextState
	if execFrame.Visible then
		if NAmanage.centerFrame then
			pcall(NAmanage.centerFrame, execFrame)
		end
		if type(NAStuff.ExecutorRefresh) == "function" then
			Defer(NAStuff.ExecutorRefresh)
		end
	end
	return true
end
