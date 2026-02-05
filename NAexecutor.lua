local cg = (function()
	local S = game.GetService;
	local ok, s = pcall(function()
		return S(game, "CoreGui");
	end);
	return ok and s or nil;
end)();
local function pickPar()
	if gethui then
		local ok, h = pcall(gethui);
		if ok and h then
			return h;
		end;
	end;
	if cg and cg:FindFirstChild("RobloxGui") then
		return cg.RobloxGui;
	end;
	return cg;
end;
do
	local p = pickPar();
	if p then
		local old = p:FindFirstChild("AdvExec");
		if old then
			old:Destroy();
		end;
	end;
end;
local NA_SRV = setmetatable({}, {
	__index = function(self, n)
		local R = cloneref and type(cloneref) == "function" and cloneref or function(x)
			return x;
		end;
		local ok, svc = pcall(function()
			return R(game:GetService(n));
		end);
		if ok and svc then
			rawset(self, n, svc);
			return svc;
		end;
	end
});
local function S(n)
	return NA_SRV[n];
end;
local function AttachEditor(cfg)
	local sf = cfg.sf;
	local src = cfg.src;
	local lines = cfg.lines;
	src.MultiLine = true;
	src.ClearTextOnFocus = false;
	src.TextXAlignment = Enum.TextXAlignment.Left;
	src.TextYAlignment = Enum.TextYAlignment.Top;
	src.BackgroundTransparency = 1;
	local TS = game:GetService("TextService");
	local TweenService = game:GetService("TweenService");
	src.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			task.defer(function()
				local pos = src.CursorPosition;
				if pos and pos > 0 then
					src.SelectionStart = pos;
				end;
			end);
		end;
	end);
	local function getLineHeight()
		return src.TextSize + 4;
	end;
	local function newLayer(name, col, dz)
		local l = Instance.new("TextLabel");
		l.Name = name;
		l.BackgroundTransparency = 1;
		l.BorderSizePixel = 0;
		l.ZIndex = src.ZIndex + (dz or 0);
		l.FontFace = src.FontFace;
		l.TextSize = src.TextSize;
		l.TextXAlignment = src.TextXAlignment;
		l.TextYAlignment = src.TextYAlignment;
		l.TextColor3 = col;
		l.RichText = false;
		l.TextWrapped = false;
		l.Size = UDim2.new(1, 0, 1, 0);
		l.Position = UDim2.new(0, 0, 0, 0);
		l.Text = "";
		l.Parent = src;
		return l;
	end;
	local layerNumbers = newLayer("Numbers_", Color3.fromRGB(255, 198, 0), 0);
	local layerTokens = newLayer("Tokens_", Color3.fromRGB(204, 204, 204), 1);
	local layerKeywords = newLayer("Keywords_", Color3.fromRGB(248, 109, 124), 2);
	local layerGlobals = newLayer("Globals_", Color3.fromRGB(132, 214, 247), 2);
	local layerTypes = newLayer("Types_", Color3.fromRGB(97, 161, 241), 2);
	local layerRobloxAPI = newLayer("RobloxAPI_", Color3.fromRGB(253, 251, 172), 2);
	local layerRemote = newLayer("RemoteHighlight_", Color3.fromRGB(248, 109, 124), 2);
	local layerStrings = newLayer("Strings_", Color3.fromRGB(173, 241, 149), 3);
	local layerComments = newLayer("Comments_", Color3.fromRGB(102, 102, 102), 4);
	local layerMap = {
		Numbers = layerNumbers,
		Tokens = layerTokens,
		Keywords = layerKeywords,
		Globals = layerGlobals,
		Types = layerTypes,
		RobloxAPI = layerRobloxAPI,
		Remote = layerRemote,
		Strings = layerStrings,
		Comments = layerComments
	};

	local typeMap = {
		[1] = "String",
		[2] = "String",
		[3] = "String",
		[4] = "Comment",
		[5] = "Operator",
		[6] = "Number",
		[7] = "Keyword",
		[8] = "BuiltIn",
		[9] = "LocalMethod",
		[10] = "LocalProperty",
		[11] = "Nil",
		[12] = "Bool",
		[13] = "Function",
		[14] = "Local",
		[15] = "Self",
		[16] = "FunctionName",
		[17] = "Bracket"
	};

	local specialKeywordsTypes = {
		["nil"] = 11,
		["true"] = 12,
		["false"] = 12,
		["function"] = 13,
		["local"] = 14,
		["self"] = 15
	};
	local lua_keywords = {
		"and",
		"break",
		"do",
		"else",
		"elseif",
		"end",
		"false",
		"for",
		"function",
		"goto",
		"if",
		"in",
		"local",
		"nil",
		"not",
		"or",
		"repeat",
		"return",
		"then",
		"true",
		"until",
		"while"
	};
	local keywordSet = {}
	for _, v in ipairs(lua_keywords) do
		keywordSet[v] = true
	end
	keywordSet.plugin = true
	local lua_types = {
		"any",
		"nil",
		"boolean",
		"number",
		"string",
		"table",
		"thread",
		"userdata",
		"vector",
		"Instance",
		"CFrame",
		"Vector2",
		"Vector3"
	};
	local global_env = {
		"game",
		"workspace",
		"script",
		"math",
		"string",
		"table",
		"coroutine",
		"task",
		"bit32",
		"print",
		"warn",
		"error",
		"wait",
		"tick",
		"pairs",
		"ipairs",
		"next",
		"select",
		"unpack",
		"Instance",
		"Vector2",
		"Vector3",
		"CFrame",
		"Ray",
		"UDim2",
		"BrickColor",
		"Color3",
		"Enum",
		"assert",
		"loadstring",
		"_G",
		"shared",
		"getfenv",
		"setfenv",
		"setmetatable",
		"getmetatable",
		"os",
		"debug",
		"pcall",
		"xpcall",
		"type",
		"typeof",
		"require",
		"spawn",
		"delay",
		"getgenv",
		"getgc",
		"getloadedmodules",
		"getrunningscripts",
		"getsenv",
		"getrenv",
		"getreg",
		"getregistry",
		"getrawmetatable",
		"setrawmetatable",
		"newcclosure",
		"hookfunction",
		"hookmetamethod",
		"setreadonly",
		"getnamecallmethod",
		"checkcaller",
		"islclosure",
		"isexecutorclosure",
		"isourclosure",
		"getinstances",
		"getnilinstances",
		"getscripts",
		"gethui",
		"fireclickdetector",
		"fireproximityprompt",
		"firetouchinterest",
		"firesignal",
		"gethiddenproperty",
		"sethiddenproperty",
		"setclipboard",
		"isfile",
		"writefile",
		"readfile",
		"listfiles",
		"makefolder",
		"isfolder",
		"delfile",
		"appendfile",
		"loadfile",
		"saveinstance",
		"identifyexecutor",
		"cloneref",
		"setfpscap",
		"request",
		"http_request",
		"syn"
	};
	local roblox_api = {
		"GetService",
		"WaitForChild",
		"FindFirstChild",
		"FindFirstChildOfClass",
		"FindFirstChildWhichIsA",
		"IsA",
		"Destroy",
		"Clone",
		"ClearAllChildren",
		"GetChildren",
		"GetDescendants",
		"GetPropertyChangedSignal",
		"GetPlayers",
		"GetMouse",
		"GetFocusedTextBox",
		"GetFullName",
		"Kick",
		"SetPrimaryPartCFrame",
		"PivotTo"
	};
	local builtIns = {}
	for _, v in ipairs(global_env) do
		builtIns[v] = true
	end
	for _, v in ipairs(roblox_api) do
		builtIns[v] = true
	end
	local function mapNewLines(text)
		local newLines = {}
		local init = 1
		local pos = string.find(text, "\n", init, true)
		local count = 1
		while pos do
			newLines[count] = pos
			count = count + 1
			init = pos + 1
			pos = string.find(text, "\n", init, true)
		end
		newLines[count] = #text + 1
		return newLines
	end

	local function preHighlightText(text, newLines)
		local found, foundMap, extras = {}, {}, {}
		local function findAll(str, pattern, typ, raw)
			local count = #found + 1
			local init = 1
			local x, y, extra = string.find(str, pattern, init, raw)
			while x do
				found[count] = x
				foundMap[x] = typ
				if extra then
					extras[x] = extra
				end
				count = count + 1
				init = y + 1
				x, y, extra = string.find(str, pattern, init, raw)
			end
		end

		findAll(text, '"', 1, true)
		findAll(text, "'", 2, true)
		findAll(text, "%[(=*)%[", 3)
		findAll(text, "--", 4, true)
		table.sort(found)

		local textLen = #text
		local curLine = 1
		local lineStart = 0
		local lineEnd = newLines[curLine] or textLen + 1
		local lastEnding = 0
		local foundHighlights = {}

		for i = 1, #found do
			local pos = found[i]
			if pos <= lastEnding then
			else
			local typ = foundMap[pos]
			local ending = pos
			if typ == 1 then
				ending = string.find(text, '"', pos + 1, true)
				while ending and string.sub(text, ending - 1, ending - 1) == "\\" do
					ending = string.find(text, '"', ending + 1, true)
				end
				if not ending then
					ending = textLen
				end
			elseif typ == 2 then
				ending = string.find(text, "'", pos + 1, true)
				while ending and string.sub(text, ending - 1, ending - 1) == "\\" do
					ending = string.find(text, "'", ending + 1, true)
				end
				if not ending then
					ending = textLen
				end
			elseif typ == 3 then
				local _, e2 = string.find(text, "]" .. (extras[pos] or "") .. "]", pos + 1, true)
				ending = e2 or textLen
			elseif typ == 4 then
				local ahead = foundMap[pos + 2]
				if ahead == 3 then
					local _, e2 = string.find(text, "]" .. (extras[pos + 2] or "") .. "]", pos + 1, true)
					ending = e2 or textLen
				else
					ending = string.find(text, "\n", pos + 1, true) or textLen
				end
			end

			while pos > lineEnd do
				curLine = curLine + 1
				lineStart = newLines[curLine - 1] or 0
				lineEnd = newLines[curLine] or textLen + 1
			end

			while true do
				local lineTable = foundHighlights[curLine]
				if not lineTable then
					lineTable = {}
					foundHighlights[curLine] = lineTable
				end
				lineTable[pos] = { typ, ending }
				if ending > lineEnd then
					curLine = curLine + 1
					lineStart = newLines[curLine - 1] or 0
					lineEnd = newLines[curLine] or textLen + 1
				else
					break
				end
			end
			lastEnding = ending
			end
		end

		return foundHighlights
	end

	local function highlightLineDex(lineText, lineIndex, newLines, preHighlights)
		local highlights = {}
		local pre = preHighlights[lineIndex] or {}
		local lineLen = #lineText
		local lastEnding = 0
		local currentType = 0
		local lastWord = nil
		local wordBeginsDotted = false
		local funcStatus = 0
		local lineStart = (newLines[lineIndex - 1] or 0)

		local preHighlightMap = {}
		for pos, data in pairs(pre) do
			local relativePos = pos - lineStart
			if relativePos < 1 then
				currentType = data[1]
				lastEnding = data[2] - lineStart
			else
				preHighlightMap[relativePos] = { data[1], data[2] - lineStart }
			end
		end

		for col = 1, lineLen do
			if col <= lastEnding then
				highlights[col] = currentType
			else
				local preEntry = preHighlightMap[col]
				if preEntry then
					currentType = preEntry[1]
					lastEnding = preEntry[2]
					highlights[col] = currentType
					wordBeginsDotted = false
					lastWord = nil
					funcStatus = 0
				else
					local char = string.sub(lineText, col, col)
					if string.find(char, "[%a_]") then
						local word = string.match(lineText, "[%a%d_]+", col)
						local wordType = (keywordSet[word] and 7) or (builtIns[word] and 8)

						lastEnding = col + #word - 1

						if wordType ~= 7 then
							if wordBeginsDotted then
								wordType = 10
							end

							if wordType ~= 8 then
								local x, _, br = string.find(lineText, "^%s*([%({\"'])", lastEnding + 1)
								if x then
									wordType = (funcStatus > 0 and br == "(" and 16) or 9
									funcStatus = 0
								end
							end
						else
							wordType = specialKeywordsTypes[word] or wordType
							funcStatus = (word == "function" and 1 or 0)
						end

						lastWord = word
						wordBeginsDotted = false
						if funcStatus > 0 then
							funcStatus = 1
						end

						if wordType then
							currentType = wordType
							highlights[col] = currentType
						else
							currentType = nil
						end
					elseif string.find(char, "%p") then
						local isDot = (char == ".")
						local isNum = isDot and string.find(string.sub(lineText, col + 1, col + 1), "%d")
						highlights[col] = (isNum and 6 or 5)

						if not isNum then
							local dotStr = isDot and string.match(lineText, "%.%.?%.?", col)
							if dotStr and #dotStr > 1 then
								currentType = 5
								lastEnding = col + #dotStr - 1
								wordBeginsDotted = false
								lastWord = nil
								funcStatus = 0
							else
								if isDot then
									if wordBeginsDotted then
										lastWord = nil
									else
										wordBeginsDotted = true
									end
								else
									wordBeginsDotted = false
									lastWord = nil
								end

								funcStatus = ((isDot or char == ":") and funcStatus == 1 and 2) or 0
							end
						end
					elseif string.find(char, "%d") then
						local _, endPos = string.find(lineText, "%x+", col)
						local endPart = string.sub(lineText, endPos, endPos + 1)
						if (endPart == "e+" or endPart == "e-") and string.find(string.sub(lineText, endPos + 2, endPos + 2), "%d") then
							endPos = endPos + 1
						end
						currentType = 6
						lastEnding = endPos
						highlights[col] = 6
						wordBeginsDotted = false
						lastWord = nil
						funcStatus = 0
					else
						highlights[col] = currentType
						local _, endPos = string.find(lineText, "%s+", col)
						if endPos then
							lastEnding = endPos
						end
					end
				end
			end
		end

		return highlights
	end
	local function HighlightString(str, keywords)
		local K = {};
		local S = str;
		local Token = {
			["="] = true,
			["."] = true,
			[","] = true,
			["("] = true,
			[")"] = true,
			["["] = true,
			["]"] = true,
			["{"] = true,
			["}"] = true,
			[":"] = true,
			["*"] = true,
			["/"] = true,
			["+"] = true,
			["-"] = true,
			["%"] = true,
			[";"] = true,
			["~"] = true
		};
		for _, v in ipairs(keywords) do
			K[v] = true;
		end;
		S = S:gsub(".", function(c)
			if Token[c] ~= nil then
				return " ";
			else
				return c;
			end;
		end);
		S = S:gsub("%S+", function(c)
			if K[c] ~= nil then
				return c;
			else
				return (" "):rep(#c);
			end;
		end);
		return S;
	end;
	local function HighlightTokens(str)
		local Token = {
			["="] = true,
			["."] = true,
			[","] = true,
			["("] = true,
			[")"] = true,
			["["] = true,
			["]"] = true,
			["{"] = true,
			["}"] = true,
			[":"] = true,
			["*"] = true,
			["/"] = true,
			["+"] = true,
			["-"] = true,
			["%"] = true,
			[";"] = true,
			["~"] = true
		};
		local A = "";
		str:gsub(".", function(c)
			if Token[c] then
				A = A .. c;
			elseif c == "\n" then
				A = A .. "\n";
			elseif c == "\t" then
				A = A .. "\t";
			else
				A = A .. " ";
			end;
		end);
		return A;
	end;
	local function HighlightStrings(str)
		local res = {}
		local i = 1
		local n = #str
		local inString = false
		local quote = nil
		while i <= n do
			local c = str:sub(i, i)
			if not inString then
				local two = i < n and str:sub(i, i + 1) or ""
				if c == "[" and two == "[[" then
					inString = true
					quote = "[["
					res[#res + 1] = "["
					res[#res + 1] = "["
					i = i + 2
				elseif c == "\"" or c == "'" then
					inString = true
					quote = c
					res[#res + 1] = c
					i = i + 1
				else
					if c == "\n" or c == "\t" then
						res[#res + 1] = c
					else
						res[#res + 1] = " "
					end
					i = i + 1
				end
			else
				if quote == "[[" then
					local two = i < n and str:sub(i, i + 1) or ""
					if c == "]" and two == "]]" then
						res[#res + 1] = "]"
						res[#res + 1] = "]"
						i = i + 2
						inString = false
						quote = nil
					else
						res[#res + 1] = c
						i = i + 1
					end
				else
					res[#res + 1] = c
					if c == quote then
						inString = false
						quote = nil
					end
					i = i + 1
				end
			end
		end
		return table.concat(res)
	end;
	local function HighlightComments(str)
		local res = {}
		local inComm = false
		local i = 1
		local n = #str

		while i <= n do
			local c = str:sub(i, i)

			if c == "\n" then
				inComm = false
				res[#res + 1] = "\n"
				i = i + 1
			elseif not inComm and c == "-" and i < n and str:sub(i + 1, i + 1) == "-" then
				inComm = true
				res[#res + 1] = "-"
				res[#res + 1] = "-"
				i = i + 2
			else
				if inComm then
					res[#res + 1] = c
				elseif c == "\t" then
					res[#res + 1] = "\t"
				else
					res[#res + 1] = " "
				end
				i = i + 1
			end
		end

		return table.concat(res)
	end;
	local function HighlightNumbers(str)
		local A = "";
		str:gsub(".", function(c)
			if tonumber(c) ~= nil then
				A = A .. c;
			elseif c == "\n" then
				A = A .. "\n";
			elseif c == "\t" then
				A = A .. "\t";
			else
				A = A .. " ";
			end;
		end);
		return A;
	end;
	local function updateLinesSize()
		if not lines then
			return;
		end;
		lines.Size = UDim2.new(lines.Size.X.Scale, lines.Size.X.Offset, 0, src.AbsoluteSize.Y);
	end;
	local function BuildLayers(str)
		local n = #str
		local code = {}
		local sLayer = {}
		local cLayer = {}

		local i = 1
		local inLineComment = false
		local inBlockComment = false
		local inString = false
		local stringType = nil

		while i <= n do
			local c = str:sub(i, i)

			if c == "\n" then
				inLineComment = false
				code[#code + 1] = "\n"
				sLayer[#sLayer + 1] = "\n"
				cLayer[#cLayer + 1] = "\n"
				i = i + 1
			elseif inBlockComment then
				if i < n and str:sub(i, i + 1) == "]]" then
					cLayer[#cLayer + 1] = "]"
					cLayer[#cLayer + 1] = "]"
					code[#code + 1] = " "
					code[#code + 1] = " "
					sLayer[#sLayer + 1] = " "
					sLayer[#sLayer + 1] = " "
					inBlockComment = false
					i = i + 2
				else
					cLayer[#cLayer + 1] = c
					code[#code + 1] = " "
					sLayer[#sLayer + 1] = " "
					i = i + 1
				end
			elseif inString then
				if stringType == "[[" then
					if i < n and str:sub(i, i + 1) == "]]" then
						sLayer[#sLayer + 1] = "]"
						sLayer[#sLayer + 1] = "]"
						code[#code + 1] = " "
						code[#code + 1] = " "
						cLayer[#cLayer + 1] = " "
						cLayer[#cLayer + 1] = " "
						inString = false
						stringType = nil
						i = i + 2
					else
						sLayer[#sLayer + 1] = c
						code[#code + 1] = " "
						cLayer[#cLayer + 1] = " "
						i = i + 1
					end
				else
					sLayer[#sLayer + 1] = c
					code[#code + 1] = " "
					cLayer[#cLayer + 1] = " "
					if c == stringType then
						inString = false
						stringType = nil
					end
					i = i + 1
				end
			else
				if i < n and str:sub(i, i + 1) == "--" then
					if i + 3 <= n and str:sub(i + 2, i + 3) == "[[" then
						cLayer[#cLayer + 1] = "-"
						cLayer[#cLayer + 1] = "-"
						cLayer[#cLayer + 1] = "["
						cLayer[#cLayer + 1] = "["
						code[#code + 1] = " "
						code[#code + 1] = " "
						code[#code + 1] = " "
						code[#code + 1] = " "
						sLayer[#sLayer + 1] = " "
						sLayer[#sLayer + 1] = " "
						sLayer[#sLayer + 1] = " "
						sLayer[#sLayer + 1] = " "
						inBlockComment = true
						i = i + 4
					else
						cLayer[#cLayer + 1] = "-"
						cLayer[#cLayer + 1] = "-"
						code[#code + 1] = " "
						code[#code + 1] = " "
						sLayer[#sLayer + 1] = " "
						sLayer[#sLayer + 1] = " "
						inLineComment = true
						i = i + 2
					end
				elseif i < n and str:sub(i, i + 1) == "[[" then
					sLayer[#sLayer + 1] = "["
					sLayer[#sLayer + 1] = "["
					code[#code + 1] = " "
					code[#code + 1] = " "
					cLayer[#cLayer + 1] = " "
					cLayer[#cLayer + 1] = " "
					inString = true
					stringType = "[["
					i = i + 2
				elseif c == "\"" or c == "'" then
					sLayer[#sLayer + 1] = c
					code[#code + 1] = " "
					cLayer[#cLayer + 1] = " "
					inString = true
					stringType = c
					i = i + 1
				elseif inLineComment then
					cLayer[#cLayer + 1] = c
					code[#code + 1] = " "
					sLayer[#sLayer + 1] = " "
					i = i + 1
				else
					code[#code + 1] = c
					sLayer[#sLayer + 1] = " "
					cLayer[#cLayer + 1] = " "
					i = i + 1
				end
			end
		end

		return table.concat(code), table.concat(sLayer), table.concat(cLayer)
	end;
	local function highlight_source()
		local s = src.Text or "";
		s = s:gsub("\r", "");
		local sTabs = s:gsub("\t", "    ");
		local newLines = mapNewLines(sTabs);
		local preHighlights = preHighlightText(sTabs, newLines);

		local layerBuffers = {
			Numbers = {},
			Tokens = {},
			Keywords = {},
			Globals = {},
			Types = {},
			RobloxAPI = {},
			Remote = {},
			Strings = {},
			Comments = {}
		};

		local layerTypes = {
			Numbers = {
				[6] = true,
				[11] = true,
				[12] = true
			},
			Tokens = {
				[5] = true,
				[17] = true
			},
			Keywords = {
				[7] = true,
				[13] = true,
				[14] = true,
				[15] = true
			},
			Globals = {
				[8] = true
			},
			Types = {
				[10] = true
			},
			RobloxAPI = {
				[9] = true,
				[16] = true
			},
			Remote = {},
			Strings = {
				[1] = true,
				[2] = true,
				[3] = true
			},
			Comments = {
				[4] = true
			}
		};

		local lineCount = 0;
		local lineIndex = 1;

		for line in (sTabs .. "\n"):gmatch("([^\n]*)\n") do
			local hl = highlightLineDex(line, lineIndex, newLines, preHighlights);
			for i = 1, #line do
				local ch = string.sub(line, i, i);
				local t = hl[i] or 0;
				for name, buf in pairs(layerBuffers) do
					if layerTypes[name][t] then
						buf[#buf + 1] = ch;
					else
						buf[#buf + 1] = " ";
					end
				end
			end
			for _, buf in pairs(layerBuffers) do
				buf[#buf + 1] = "\n";
			end
			lineCount = lineCount + 1;
			lineIndex = lineIndex + 1;
		end

		layerNumbers.Text = table.concat(layerBuffers.Numbers);
		layerTokens.Text = table.concat(layerBuffers.Tokens);
		layerKeywords.Text = table.concat(layerBuffers.Keywords);
		layerGlobals.Text = table.concat(layerBuffers.Globals);
		layerTypes.Text = table.concat(layerBuffers.Types);
		layerRobloxAPI.Text = table.concat(layerBuffers.RobloxAPI);
		layerRemote.Text = table.concat(layerBuffers.Remote);
		layerStrings.Text = table.concat(layerBuffers.Strings);
		layerComments.Text = table.concat(layerBuffers.Comments);

		if lines then
			local t = {};
			for i = 1, lineCount do
				t[#t + 1] = tostring(i);
			end;
			lines.Text = table.concat(t, "\n");
		end;
	end;
	local function updateCanvas()
		local pad = sf:FindFirstChildOfClass("UIPadding");
		local leftPad = pad and pad.PaddingLeft.Offset or 0;
		local text = src.Text or "";
		local lineHeight = getLineHeight();
		local _, lineCount = text:gsub("\n", "");
		lineCount = lineCount + 1;
		local viewH = sf.AbsoluteSize.Y;
		local contentH = math.max(viewH, lineCount * lineHeight + 5);
		local maxW = 0;
		local sTabs = (text:gsub("\r", "")):gsub("\t", "    ");
		for line in (sTabs .. "\n"):gmatch("([^\n]*)\n") do
			local l = line;
			if l == "" then
				l = " ";
			end;
			local bounds = TS:GetTextSize(l, src.TextSize, src.Font, Vector2.new(1000000, lineHeight));
			if bounds.X > maxW then
				maxW = bounds.X;
			end;
		end;
		local viewW = sf.AbsoluteSize.X;
		local textOffset = src.Position.X.Offset or 0;
		local contentW = math.max(viewW, leftPad + textOffset + maxW + 20);
		src.Size = UDim2.new(1, -leftPad, 0, contentH);
		sf.CanvasSize = UDim2.new(0, contentW, 0, contentH);
		updateLinesSize();
	end;
	local function getLineInfo()
		local text = src.Text or "";
		local cursorPos = src.CursorPosition;
		if not cursorPos or cursorPos <= 0 then
			local linesPos = {
				0,
				(#text) + 1
			};
			return linesPos, 0, 1;
		end;
		cursorPos -= 1;
		local prefix = text:sub(1, cursorPos);
		local _, lineNumber = prefix:gsub("\n", "");
		lineNumber = lineNumber + 1;
		local linesPos = {
			0
		};
		for i = 1, #text do
			if text:sub(i, i) == "\n" then
				linesPos[(#linesPos) + 1] = i;
			end;
		end;
		linesPos[(#linesPos) + 1] = (#text) + 1;
		local maxLine = (#linesPos) - 1;
		if lineNumber > maxLine then
			lineNumber = maxLine;
		end;
		if lineNumber < 1 then
			lineNumber = 1;
		end;
		local lineStart = linesPos[lineNumber] or 0;
		return linesPos, lineStart, lineNumber;
	end;
	local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
	local function updateHighlight()
		local text = src.Text or "";
		local cursorPos = src.CursorPosition;
		if not cursorPos or cursorPos <= 0 then
			return;
		end;
		local pad = sf:FindFirstChildOfClass("UIPadding");
		local left = pad and pad.PaddingLeft.Offset or 0;
		local w = math.max(1, src.AbsoluteSize.X - left);
		local lineHeight = getLineHeight();
		local before = text:sub(1, cursorPos - 1);
		local bounds = TS:GetTextSize(before, src.TextSize, src.Font, Vector2.new(w, 99999));
		local targetY = math.max(0, bounds.Y - lineHeight);
		local maxY = math.max(0, sf.CanvasSize.Y.Offset - sf.AbsoluteSize.Y);
		local newY = math.clamp(targetY - sf.AbsoluteSize.Y * 0.3, 0, maxY);
		(TweenService:Create(sf, tweenInfo, {
			CanvasPosition = Vector2.new(0, newY)
		})):Play();
	end;
	(src:GetPropertyChangedSignal("Text")):Connect(function()
		highlight_source();
		updateCanvas();
		updateHighlight();
	end);
	(src:GetPropertyChangedSignal("CursorPosition")):Connect(updateHighlight);
	(src:GetPropertyChangedSignal("SelectionStart")):Connect(updateHighlight);
	src.Focused:Connect(updateHighlight);
	src.FocusLost:Connect(function()
	end);
	(sf:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
		updateCanvas();
		updateHighlight();
	end);
	(src:GetPropertyChangedSignal("AbsoluteSize")):Connect(updateLinesSize);
	highlight_source();
	updateCanvas();
	updateHighlight();
	return {
		textbox = src,
		scroll = sf,
		lines = lines,
		refresh = function()
			highlight_source();
			updateCanvas();
			updateHighlight();
		end
	};
end;
local ts, uis, gsv, txt, rs, hs = S("TweenService"), S("UserInputService"), S("GuiService"), S("TextService"), S("RunService"), S("HttpService");
local isM = uis.TouchEnabled and (not uis.KeyboardEnabled);
local BS = isM and 0.84 or 1;
local TSZ = isM and 18 or 16;
local col = {
	bg = Color3.fromRGB(6, 6, 8),
	panel = Color3.fromRGB(10, 10, 12),
	top = Color3.fromRGB(14, 14, 18),
	sep = Color3.fromRGB(20, 20, 24),
	scroll = Color3.fromRGB(4, 4, 6),
	lnBg = Color3.fromRGB(10, 10, 12),
	lnTx = Color3.fromRGB(155, 155, 160),
	tx = Color3.fromRGB(235, 235, 235),
	ph = Color3.fromRGB(130, 130, 130),
	car = Color3.fromRGB(245, 245, 245),
	btn = Color3.fromRGB(12, 12, 14),
	btnA = Color3.fromRGB(18, 18, 20),
	btnTx = Color3.fromRGB(235, 235, 235),
	st = Color3.fromRGB(70, 70, 70),
	ok = Color3.fromRGB(215, 215, 215),
	bad = Color3.fromRGB(150, 150, 150),
	warn = Color3.fromRGB(190, 190, 190),
	sel = Color3.fromRGB(210, 210, 210),
	selT = 0.78,
	err = Color3.fromRGB(220, 220, 220),
	sb = Color3.fromRGB(130, 130, 130),
	title = Color3.fromRGB(230, 230, 230),
	tabI = Color3.fromRGB(18, 18, 22),
	tabA = Color3.fromRGB(24, 24, 30),
	tabTI = Color3.fromRGB(170, 170, 175),
	tabTA = Color3.fromRGB(235, 235, 235),
	ind = Color3.fromRGB(235, 235, 235),
	hub = Color3.fromRGB(10, 10, 12),
	hub2 = Color3.fromRGB(14, 14, 16)
};
local twm = setmetatable({}, {
	__mode = "k"
});
local function tw(o, ti, p)
	local old = twm[o];
	if old then
		pcall(function()
			old:Cancel();
		end);
	end;
	local nw = ts:Create(o, ti, p);
	twm[o] = nw;
	nw:Play();
	return nw;
end;
local dir = "AdvExecutor";
local fCfg = dir .. "/settings.json";
local fTab = dir .. "/tabs.json";
local sDir = dir .. "/Scripts";
local fsOk = typeof(isfile) == "function" and typeof(readfile) == "function" and typeof(writefile) == "function" and typeof(makefolder) == "function" and typeof(isfolder) == "function";
local delOk = typeof(delfile) == "function";
local listOk = typeof(listfiles) == "function";
local cfg = {
	a = 0,
	fs = false,
	z = BS,
	ln = true,
	an = true,
	hb = false
};
if fsOk then
	pcall(function()
		if not isfolder(dir) then
			makefolder(dir);
		end;
		if not isfolder(sDir) then
			makefolder(sDir);
		end;
	end);
	pcall(function()
		if isfile(fCfg) then
			local raw = readfile(fCfg);
			if raw and raw ~= "" then
				local ok, dec = pcall(function()
					return hs:JSONDecode(raw);
				end);
				if ok and type(dec) == "table" then
					if type(dec.a) == "number" then
						cfg.a = math.clamp(dec.a, 0, 1);
					end;
					if type(dec.fs) == "boolean" then
						cfg.fs = dec.fs;
					end;
					if type(dec.z) == "number" then
						cfg.z = math.clamp(dec.z, 0.6, 1.35);
					end;
					if type(dec.ln) == "boolean" then
						cfg.ln = dec.ln;
					end;
					if type(dec.an) == "boolean" then
						cfg.an = dec.an;
					end;
					if type(dec.hb) == "boolean" then
						cfg.hb = dec.hb;
					end;
				end;
			end;
		end;
	end);
end;
local cD, cS = false, false;
local function saveCfg()
	if not fsOk then
		return;
	end;
	local ok, enc = pcall(function()
		return hs:JSONEncode(cfg);
	end);
	if ok then
		pcall(function()
			writefile(fCfg, enc);
		end);
	end;
end;
local function schCfg()
	if not fsOk then
		return;
	end;
	cD = true;
	if cS then
		return;
	end;
	cS = true;
	task.delay(1.05, function()
		if cD then
			cD = false;
			saveCfg();
		end;
		cS = false;
	end);
end;
local tabs = {};
local cur = 1;
local tD, tS = false, false;
local function saveTabs()
	if not fsOk then
		return;
	end;
	local p = {
		cur = cur,
		tabs = {}
	};
	for i, v in ipairs(tabs) do
		p.tabs[i] = v.text or "";
	end;
	local ok, enc = pcall(function()
		return hs:JSONEncode(p);
	end);
	if ok then
		pcall(function()
			writefile(fTab, enc);
		end);
	end;
end;
local function schTabs()
	if not fsOk then
		return;
	end;
	tD = true;
	if tS then
		return;
	end;
	tS = true;
	task.delay(1.05, function()
		if tD then
			tD = false;
			saveTabs();
		end;
		tS = false;
	end);
end;
local function protect(g)
	if g:IsA("ScreenGui") then
		g.ZIndexBehavior = Enum.ZIndexBehavior.Global;
		g.DisplayOrder = 999999999;
		g.ResetOnSpawn = false;
		g.IgnoreGuiInset = true;
	end;
	local p = pickPar();
	if p then
		g.Parent = p;
	end;
end;
local e = Instance.new("ScreenGui");
e.Name = "AdvExec";
protect(e);
local m = Instance.new("Frame");
m.Name = "Main";
m.Parent = e;
m.Active = true;
m.BackgroundColor3 = col.bg;
m.ClipsDescendants = true;
m.AnchorPoint = Vector2.new(0, 0);
m.Position = UDim2.new(0, 0, 0, 0);
m.Size = UDim2.new(0, 440, 0, 340);
local c1 = Instance.new("UICorner", m);
c1.CornerRadius = UDim.new(0, 12);
local sc = Instance.new("UIScale", m);
sc.Scale = cfg.z * 0.92;
tw(sc, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Scale = cfg.z
});
local minW = isM and 280 or 380;
local minH = isM and 420 or 300;
local szc = Instance.new("UISizeConstraint", m);
szc.MinSize = Vector2.new(minW, minH);
local MAX0 = Vector2.new(860, 720);
szc.MaxSize = MAX0;
local BMIN = szc.MinSize;
local tb = Instance.new("Frame");
tb.Name = "TopBar";
tb.Parent = m;
tb.BackgroundColor3 = col.top;
tb.BorderSizePixel = 0;
tb.Size = UDim2.new(1, 0, 0, 44);
local c6 = Instance.new("UICorner", tb);
c6.CornerRadius = UDim.new(0, 12);
local tt = Instance.new("TextLabel");
tt.Name = "Title";
tt.Parent = tb;
tt.BackgroundTransparency = 1;
tt.Position = UDim2.new(0, 16, 0, 0);
tt.Size = UDim2.new(1, -220, 1, 0);
tt.Font = Enum.Font.GothamBold;
tt.Text = "Executor";
tt.TextColor3 = col.title;
tt.TextSize = 20;
tt.TextXAlignment = Enum.TextXAlignment.Left;
local function topBtn(tx2, x)
	local b = Instance.new("TextButton");
	b.Parent = tb;
	b.BackgroundTransparency = 1;
	b.Position = UDim2.new(1, x, 0, 0);
	b.Size = UDim2.new(0, 44, 1, 0);
	b.Font = Enum.Font.GothamBold;
	b.Text = tx2;
	b.TextColor3 = col.title;
	b.TextSize = 16;
	b.AutoButtonColor = true;
	local s2 = Instance.new("UIScale", b);
	s2.Scale = 1;
	b.MouseButton1Down:Connect(function()
		if not cfg.an then
			return;
		end;
		tw(s2, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = 0.92
		});
	end);
	b.MouseButton1Up:Connect(function()
		if not cfg.an then
			return;
		end;
		tw(s2, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = 1
		});
	end);
	return b;
end;
local xt = topBtn("X", -44);
local mn = topBtn("-", -88);
local fsb = topBtn("FS", -132);
local stb = topBtn("S", -176);
local hbb = topBtn("H", -220);
local d = Instance.new("Frame");
d.Name = "Sep";
d.Parent = m;
d.BackgroundColor3 = col.sep;
d.Position = UDim2.new(0, 0, 0, 44);
d.Size = UDim2.new(1, 0, 0, 2);
local c2 = Instance.new("UICorner", d);
c2.CornerRadius = UDim.new(0, 1);
local tbar = Instance.new("Frame");
tbar.Name = "TabBar";
tbar.Parent = m;
tbar.BackgroundTransparency = 1;
tbar.Position = UDim2.new(0, 12, 0, 46);
tbar.Size = UDim2.new(1, -24, 0, isM and 34 or 28);
tbar.ZIndex = 6;
tbar.ClipsDescendants = true;
local tsf = Instance.new("ScrollingFrame");
tsf.Name = "TSF";
tsf.Parent = tbar;
tsf.BackgroundTransparency = 1;
tsf.BorderSizePixel = 0;
tsf.Position = UDim2.new(0, 0, 0, 0);
tsf.Size = UDim2.new(1, 0, 1, 0);
tsf.ScrollBarThickness = isM and 6 or 0;
tsf.ScrollBarImageTransparency = isM and 0.2 or 1;
tsf.ScrollBarImageColor3 = col.sb;
tsf.ScrollingDirection = Enum.ScrollingDirection.X;
tsf.AutomaticCanvasSize = Enum.AutomaticSize.X;
tsf.CanvasSize = UDim2.new(0, 0, 0, 0);
tsf.ScrollingEnabled = true;
tsf.ElasticBehavior = Enum.ElasticBehavior.Always;
tsf.Active = true;
tsf.ClipsDescendants = true;
local tabTouch, tabTouchX = nil, nil;
if isM then
	local function inTabBar(pos)
		local a = tsf.AbsolutePosition;
		local s2 = tsf.AbsoluteSize;
		return pos.X >= a.X and pos.X <= a.X + s2.X and pos.Y >= a.Y and pos.Y <= a.Y + s2.Y;
	end;
	uis.TouchStarted:Connect(function(i, gpe)
		if gpe or tabTouch then
			return;
		end;
		if inTabBar(i.Position) then
			tabTouch = i;
			tabTouchX = i.Position.X;
		end;
	end);
	uis.TouchMoved:Connect(function(i, gpe)
		if gpe or i ~= tabTouch or not tabTouchX then
			return;
		end;
		local dx = i.Position.X - tabTouchX;
		tabTouchX = i.Position.X;
		local maxX = math.max(0, tsf.CanvasSize.X.Offset - tsf.AbsoluteSize.X);
		local nx = math.clamp(tsf.CanvasPosition.X - dx, 0, maxX);
		tsf.CanvasPosition = Vector2.new(nx, 0);
	end);
	uis.TouchEnded:Connect(function(i, gpe)
		if i == tabTouch then
			tabTouch = nil;
			tabTouchX = nil;
		end;
	end);
end;
local twp = Instance.new("Frame");
twp.Name = "Wrap";
twp.Parent = tsf;
twp.BackgroundTransparency = 1;
twp.Position = UDim2.new(0, 0, 0, 0);
twp.Size = UDim2.new(0, 0, 1, 0);
twp.AutomaticSize = Enum.AutomaticSize.X;
twp.ZIndex = 7;
local tly = Instance.new("UIListLayout", twp);
tly.FillDirection = Enum.FillDirection.Horizontal;
tly.HorizontalAlignment = Enum.HorizontalAlignment.Left;
tly.VerticalAlignment = Enum.VerticalAlignment.Center;
tly.SortOrder = Enum.SortOrder.LayoutOrder;
tly.Padding = UDim.new(0, isM and 8 or 6);
local tad = Instance.new("TextButton");
tad.Name = "Add";
tad.Parent = twp;
tad.BackgroundColor3 = col.btn;
tad.BorderSizePixel = 0;
tad.AutoButtonColor = true;
tad.Font = Enum.Font.GothamSemibold;
tad.Text = "+";
tad.TextColor3 = col.btnTx;
tad.TextSize = isM and 18 or 16;
tad.Size = UDim2.new(0, isM and 42 or 32, 0, isM and 30 or 24);
tad.LayoutOrder = 999999;
local tadc = Instance.new("UICorner", tad);
tadc.CornerRadius = UDim.new(0, 10);
local tads = Instance.new("UIStroke", tad);
tads.Thickness = 1;
tads.Color = col.st;
tads.Transparency = 0.25;
local tadscl = Instance.new("UIScale", tad);
tadscl.Scale = 1;
local editorCore
local s = Instance.new("ScrollingFrame");
s.Name = "Scroll";
s.Parent = m;
s.Active = true;
s.BackgroundColor3 = col.scroll;
s.BorderSizePixel = 0;
s.ScrollBarThickness = 6;
s.ScrollBarImageColor3 = col.sb;
s.CanvasSize = UDim2.new(0, 0, 0, 0);
s.ScrollingDirection = Enum.ScrollingDirection.XY;
s.ClipsDescendants = true;
local ln = Instance.new("TextLabel");
ln.Name = "LN";
ln.Parent = s;
ln.BackgroundColor3 = col.lnBg;
ln.BorderSizePixel = 0;
ln.Position = UDim2.new(0, 0, 0, 0);
ln.Size = UDim2.new(0, 40, 1, 0);
ln.Font = Enum.Font.Code;
ln.Text = "1";
ln.TextColor3 = col.lnTx;
ln.TextSize = TSZ;
ln.TextXAlignment = Enum.TextXAlignment.Right;
ln.TextYAlignment = Enum.TextYAlignment.Top;
ln.RichText = false;
ln.ZIndex = 1;
local t = Instance.new("TextBox");
t.Name = "Text";
t.Parent = s;
t.BackgroundTransparency = 1;
t.BorderSizePixel = 0;
t.Position = UDim2.new(0, 46, 0, 0);
t.Size = UDim2.new(1, -52, 1, 0);
t.ClearTextOnFocus = false;
t.Font = Enum.Font.Code;
t.MultiLine = true;
t.PlaceholderText = "-- Script here";
t.PlaceholderColor3 = col.ph;
t.Text = "";
t.TextColor3 = col.tx;
t.TextSize = TSZ;
t.TextXAlignment = Enum.TextXAlignment.Left;
t.TextYAlignment = Enum.TextYAlignment.Top;
t.TextWrapped = false;
t.ZIndex = 4;
local function updateEditorLayout()
	if cfg.ln then
		ln.Visible = true;
		t.Position = UDim2.new(0, 46, 0, 0);
		t.Size = UDim2.new(1, -52, 1, 0);
	else
		ln.Visible = false;
		t.Position = UDim2.new(0, 6, 0, 0);
		t.Size = UDim2.new(1, -12, 1, 0);
	end;
	if editorCore and editorCore.refresh then
		editorCore.refresh();
	end;
end;
editorCore = AttachEditor({
	sf = s,
	src = t,
	lines = ln
});
updateEditorLayout();
local bf = Instance.new("Frame");
bf.Name = "Btns";
bf.Parent = m;
bf.BackgroundTransparency = 1;
local gl = Instance.new("UIGridLayout", bf);
gl.SortOrder = Enum.SortOrder.LayoutOrder;
gl.CellPadding = UDim2.new(0, isM and 8 or 8, 0, isM and 6 or 4);
gl.CellSize = UDim2.new(isM and 0.5 or 0.25, -6, 0, isM and 40 or 28);
gl.FillDirectionMaxCells = isM and 2 or 4;
local function sbtn(tx2, bg)
	local b = Instance.new("TextButton");
	b.Name = tx2;
	b.Parent = bf;
	b.Text = tx2;
	b.BackgroundColor3 = bg;
	b.TextColor3 = col.btnTx;
	b.BorderSizePixel = 0;
	b.Font = Enum.Font.GothamSemibold;
	b.TextSize = isM and 17 or 16;
	local cr = Instance.new("UICorner", b);
	cr.CornerRadius = UDim.new(0, 10);
	local st = Instance.new("UIStroke", b);
	st.Thickness = 1;
	st.Color = col.st;
	local sc2 = Instance.new("UIScale", b);
	sc2.Scale = 1;
	local function hov(on)
		if not cfg.an then
			return;
		end;
		if on then
			tw(sc2, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = 1.04
			});
			tw(b, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundColor3 = bg:Lerp(Color3.new(1, 1, 1), 0.06)
			});
		else
			tw(sc2, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = 1
			});
			tw(b, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundColor3 = bg
			});
		end;
	end;
	b.MouseEnter:Connect(function()
		if not isM then
			hov(true);
		end;
	end);
	b.MouseLeave:Connect(function()
		if not isM then
			hov(false);
		end;
	end);
	b.MouseButton1Down:Connect(function()
		if not cfg.an then
			return;
		end;
		tw(sc2, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = 0.96
		});
	end);
	b.MouseButton1Up:Connect(function()
		if not cfg.an then
			return;
		end;
		tw(sc2, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = 1.04
		});
	end);
	return b;
end;
local ex = sbtn("Execute", col.btnA);
local cl = sbtn("Clear", col.btn);
local cp = sbtn("Copy", col.btn);
local nl = sbtn("New Line", col.btn);
local sb = Instance.new("TextLabel");
sb.Name = "Status";
sb.Parent = m;
sb.BackgroundTransparency = 1;
sb.Font = Enum.Font.Gotham;
sb.Text = "Ready";
sb.TextColor3 = col.ok;
sb.TextSize = 14;
sb.TextXAlignment = Enum.TextXAlignment.Left;
local sp = Instance.new("Frame");
sp.Name = "SP";
sp.Parent = m;
sp.AnchorPoint = Vector2.new(1, 0);
sp.Position = UDim2.new(1, -10, 0, 52);
sp.Size = UDim2.new(0, isM and 300 or 270, 0, isM and 240 or 230);
sp.BackgroundColor3 = col.panel;
sp.Visible = false;
sp.ZIndex = 50;
sp.ClipsDescendants = true;
local spc = Instance.new("UICorner", sp);
spc.CornerRadius = UDim.new(0, 10);
local sps = Instance.new("UIStroke", sp);
sps.Thickness = 1;
sps.Color = col.st;
sps.Transparency = 0.2;
local spp = Instance.new("UIPadding", sp);
spp.PaddingLeft = UDim.new(0, 10);
spp.PaddingRight = UDim.new(0, 10);
spp.PaddingTop = UDim.new(0, 8);
spp.PaddingBottom = UDim.new(0, 8);
local spT = Instance.new("TextLabel");
spT.Parent = sp;
spT.BackgroundTransparency = 1;
spT.Size = UDim2.new(1, 0, 0, 20);
spT.Font = Enum.Font.GothamBold;
spT.Text = "Settings";
spT.TextSize = 16;
spT.TextXAlignment = Enum.TextXAlignment.Left;
spT.TextColor3 = col.title;
spT.ZIndex = 51;
local ssf = Instance.new("ScrollingFrame");
ssf.Parent = sp;
ssf.BackgroundTransparency = 1;
ssf.BorderSizePixel = 0;
ssf.Position = UDim2.new(0, 0, 0, 26);
ssf.Size = UDim2.new(1, 0, 1, -26);
ssf.ScrollBarThickness = 5;
ssf.ScrollBarImageColor3 = col.sb;
ssf.ScrollingDirection = Enum.ScrollingDirection.Y;
ssf.CanvasSize = UDim2.new(0, 0, 0, 0);
ssf.ClipsDescendants = true;
ssf.ZIndex = 51;
local scn = Instance.new("Frame");
scn.Parent = ssf;
scn.BackgroundTransparency = 1;
scn.Position = UDim2.new(0, 0, 0, 0);
scn.Size = UDim2.new(1, 0, 0, 0);
scn.ZIndex = 51;
local sll = Instance.new("UIListLayout", scn);
sll.FillDirection = Enum.FillDirection.Vertical;
sll.SortOrder = Enum.SortOrder.LayoutOrder;
sll.Padding = UDim.new(0, 8);
(sll:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
	ssf.CanvasSize = UDim2.new(0, 0, 0, sll.AbsoluteContentSize.Y + 2);
	scn.Size = UDim2.new(1, 0, 0, sll.AbsoluteContentSize.Y + 2);
end);
local function mkRow(h)
	local r = Instance.new("Frame");
	r.Parent = scn;
	r.BackgroundTransparency = 1;
	r.Size = UDim2.new(1, 0, 0, h);
	r.ZIndex = 52;
	return r;
end;
local function mkLbl(p, tx2)
	local l = Instance.new("TextLabel");
	l.Parent = p;
	l.BackgroundTransparency = 1;
	l.Position = UDim2.new(0, 0, 0, 0);
	l.Size = UDim2.new(1, 0, 0, 16);
	l.Font = Enum.Font.Gotham;
	l.Text = tx2;
	l.TextSize = 13;
	l.TextXAlignment = Enum.TextXAlignment.Left;
	l.TextColor3 = col.ok;
	l.ZIndex = 53;
	return l;
end;
local function mkPick(p, mnv, mxv, curP, onSet, step)
	step = step or 10
	local sf = Instance.new("ScrollingFrame");
	sf.Parent = p;
	sf.BackgroundTransparency = 1;
	sf.BorderSizePixel = 0;
	sf.Position = UDim2.new(0, 0, 0, 18);
	sf.Size = UDim2.new(1, 0, 0, 78);
	sf.ScrollBarThickness = 4;
	sf.ScrollBarImageColor3 = col.sb;
	sf.ScrollingDirection = Enum.ScrollingDirection.Y;
	sf.CanvasSize = UDim2.new(0, 0, 0, 0);
	sf.ClipsDescendants = true;
	sf.ZIndex = 53;
	local cn = Instance.new("Frame");
	cn.Parent = sf;
	cn.BackgroundTransparency = 1;
	cn.Position = UDim2.new(0, 0, 0, 0);
	cn.Size = UDim2.new(1, 0, 0, 0);
	cn.ZIndex = 54;
	local grid = Instance.new("UIGridLayout", cn);
	grid.SortOrder = Enum.SortOrder.LayoutOrder;
	grid.CellSize = UDim2.new(0, 52, 0, 24);
	grid.CellPadding = UDim2.new(0, 8, 0, 8);
	(grid:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
		sf.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 2);
		cn.Size = UDim2.new(1, 0, 0, grid.AbsoluteContentSize.Y + 2);
	end);
	local btns = {};
	local function ref()
		for i, b in ipairs(btns) do
			b.BackgroundColor3 = (i - 1) * step == curP and col.btnA or col.btn;
		end;
	end;
	for p2 = 0, 100, step do
		local b = Instance.new("TextButton");
		b.Parent = cn;
		b.BackgroundColor3 = col.btn;
		b.BorderSizePixel = 0;
		b.AutoButtonColor = true;
		b.Font = Enum.Font.GothamSemibold;
		b.Text = tostring(p2) .. "%";
		b.TextSize = 12;
		b.TextColor3 = col.btnTx;
		b.ZIndex = 55;
		local bc = Instance.new("UICorner", b);
		bc.CornerRadius = UDim.new(0, 8);
		local bs = Instance.new("UIStroke", b);
		bs.Thickness = 1;
		bs.Color = col.st;
		bs.Transparency = 0.25;
		btns[(#btns) + 1] = b;
		b.MouseButton1Click:Connect(function()
			curP = p2;
			ref();
			if onSet then
				local v = mnv + p2 / 100 * (mxv - mnv);
				onSet(v, p2);
			end;
		end);
	end;
	task.defer(ref);
	return {
		setP = function(p3)
			curP = math.clamp(math.floor(p3 + 0.5), 0, 100);
			ref();
		end
	};
end;
local function mkTg(tx2, get, set)
	local r = mkRow(32);
	mkLbl(r, tx2);
	local b = Instance.new("TextButton");
	b.Parent = r;
	b.BackgroundColor3 = col.btn;
	b.BorderSizePixel = 0;
	b.AutoButtonColor = true;
	b.AnchorPoint = Vector2.new(1, 0);
	b.Position = UDim2.new(1, 0, 0, 6);
	b.Size = UDim2.new(0, 92, 0, 22);
	b.Font = Enum.Font.GothamSemibold;
	b.TextSize = 12;
	b.TextColor3 = col.btnTx;
	b.ZIndex = 54;
	local bc = Instance.new("UICorner", b);
	bc.CornerRadius = UDim.new(0, 8);
	local bs = Instance.new("UIStroke", b);
	bs.Thickness = 1;
	bs.Color = col.st;
	bs.Transparency = 0.25;
	local function ref()
		b.Text = get() and "On" or "Off";
		b.BackgroundColor3 = get() and col.btnA or col.btn;
	end;
	ref();
	b.MouseButton1Click:Connect(function()
		set(not get());
		ref();
	end);
	return b;
end;
local function mkAct(tx2, cb)
	local r = mkRow(28);
	local b = Instance.new("TextButton");
	b.Parent = r;
	b.BackgroundColor3 = col.btn;
	b.BorderSizePixel = 0;
	b.AutoButtonColor = true;
	b.Size = UDim2.new(1, 0, 1, 0);
	b.Font = Enum.Font.GothamSemibold;
	b.Text = tx2;
	b.TextSize = 13;
	b.TextColor3 = col.btnTx;
	b.ZIndex = 54;
	local bc = Instance.new("UICorner", b);
	bc.CornerRadius = UDim.new(0, 8);
	local bs = Instance.new("UIStroke", b);
	bs.Thickness = 1;
	bs.Color = col.st;
	bs.Transparency = 0.25;
	b.MouseButton1Click:Connect(function()
		if cb then
			cb();
		end;
	end);
	return b;
end;
local function setStat(msg, c, dur)
	sb.Text = msg;
	sb.TextColor3 = c or col.ok;
	if dur then
		task.spawn(function()
			task.wait(dur);
			sb.Text = "Ready";
			sb.TextColor3 = col.ok;
		end);
	end;
end;
local function applyA()
	local a = cfg.a or 0;
	m.BackgroundTransparency = a;
	tb.BackgroundTransparency = a;
	d.BackgroundTransparency = a;
	s.BackgroundTransparency = a;
	ln.BackgroundTransparency = a;
	sp.BackgroundTransparency = a;
	for _, v in ipairs(tabs) do
		if v and v.h then
			v.h.BackgroundTransparency = a;
		end;
	end;
end;
local function updFSUI()
	fsb.TextColor3 = cfg.fs and col.ok or col.title;
end;
local function updHBUI()
	hbb.TextColor3 = cfg.hb and col.ok or col.title;
end;
local opRow = mkRow(98);
mkLbl(opRow, "Opacity");
local opPick = mkPick(opRow, 0, 1, math.floor((cfg.a or 0) * 100 + 0.5), function(v)
	cfg.a = v;
	applyA();
	schCfg();
end, 10);
mkTg("Line Numbers", function()
	return cfg.ln;
end, function(v)
	cfg.ln = v;
	updateEditorLayout();
	schCfg();
end);
mkTg("Animations", function()
	return cfg.an;
end, function(v)
	cfg.an = v;
	schCfg();
end);
mkAct("Reset (UI)", function()
	cfg.a = 0;
	cfg.z = BS;
	cfg.ln = true;
	cfg.an = true;
	opPick.setP(0);
	updateEditorLayout();
	if cfg.an then
		tw(sc, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Scale = cfg.z
		});
	else
		sc.Scale = cfg.z;
	end;
	applyA();
	schCfg();
end);
local hp = Instance.new("Frame");
hp.Name = "Hub";
hp.Parent = m;
hp.BackgroundColor3 = col.hub;
hp.BorderSizePixel = 0;
hp.Visible = false;
hp.ZIndex = 20;
hp.ClipsDescendants = true;
local hpc = Instance.new("UICorner", hp);
hpc.CornerRadius = UDim.new(0, 10);
local hps = Instance.new("UIStroke", hp);
hps.Thickness = 1;
hps.Color = col.st;
hps.Transparency = 0.25;
local hpt = Instance.new("TextLabel");
hpt.Parent = hp;
hpt.BackgroundTransparency = 1;
hpt.Position = UDim2.new(0, 10, 0, 8);
hpt.Size = UDim2.new(1, -20, 0, 18);
hpt.Font = Enum.Font.GothamBold;
hpt.Text = "Script Hub";
hpt.TextSize = 14;
hpt.TextXAlignment = Enum.TextXAlignment.Left;
hpt.TextColor3 = col.title;
hpt.ZIndex = 21;
local hpb = Instance.new("Frame");
hpb.Parent = hp;
hpb.BackgroundTransparency = 1;
hpb.Position = UDim2.new(0, 10, 0, 30);
hpb.Size = UDim2.new(1, -20, 0, 30);
hpb.ZIndex = 21;
local function hBtn(tx2)
	local b = Instance.new("TextButton");
	b.BackgroundColor3 = col.btn;
	b.BorderSizePixel = 0;
	b.AutoButtonColor = true;
	b.Font = Enum.Font.GothamSemibold;
	b.Text = tx2;
	b.TextSize = 12;
	b.TextColor3 = col.btnTx;
	b.ZIndex = 22;
	local bc = Instance.new("UICorner", b);
	bc.CornerRadius = UDim.new(0, 8);
	local bs = Instance.new("UIStroke", b);
	bs.Thickness = 1;
	bs.Color = col.st;
	bs.Transparency = 0.25;
	return b;
end;
local hSav = hBtn("Save");
hSav.Parent = hpb;
local hDel = hBtn("Del");
hDel.Parent = hpb;
local hgl = Instance.new("UIGridLayout", hpb);
hgl.SortOrder = Enum.SortOrder.LayoutOrder;
hgl.FillDirectionMaxCells = 2;
hgl.CellPadding = UDim2.new(0, 8, 0, 0);
hgl.CellSize = UDim2.new(0.5, -4, 1, 0);
local mode = "Replace";
local mWrap = Instance.new("Frame");
mWrap.Parent = hp;
mWrap.BackgroundTransparency = 1;
mWrap.Position = UDim2.new(0, 10, 0, 66);
mWrap.Size = UDim2.new(1, -20, 0, 30);
mWrap.ZIndex = 21;
local bR = hBtn("Replace");
bR.Parent = mWrap;
local bT = hBtn("New Tab");
bT.Parent = mWrap;
local bA = hBtn("Append");
bA.Parent = mWrap;
local bO = hBtn("Open");
bO.Parent = mWrap;
local mgl = Instance.new("UIGridLayout", mWrap);
mgl.SortOrder = Enum.SortOrder.LayoutOrder;
mgl.FillDirectionMaxCells = 4;
mgl.CellPadding = UDim2.new(0, 8, 0, 0);
mgl.CellSize = UDim2.new(0.25, -6, 1, 0);
local function refMode()
	bR.BackgroundColor3 = mode == "Replace" and col.btnA or col.btn;
	bT.BackgroundColor3 = mode == "Tab" and col.btnA or col.btn;
	bA.BackgroundColor3 = mode == "Append" and col.btnA or col.btn;
end;
bR.MouseButton1Click:Connect(function()
	mode = "Replace";
	refMode();
end);
bT.MouseButton1Click:Connect(function()
	mode = "Tab";
	refMode();
end);
bA.MouseButton1Click:Connect(function()
	mode = "Append";
	refMode();
end);
local hsf = Instance.new("ScrollingFrame");
hsf.Parent = hp;
hsf.BackgroundTransparency = 1;
hsf.BorderSizePixel = 0;
hsf.Position = UDim2.new(0, 10, 0, 104);
hsf.Size = UDim2.new(1, -20, 1, -114);
hsf.ScrollBarThickness = 5;
hsf.ScrollBarImageColor3 = col.sb;
hsf.ScrollingDirection = Enum.ScrollingDirection.Y;
hsf.CanvasSize = UDim2.new(0, 0, 0, 0);
hsf.ZIndex = 21;
hsf.ClipsDescendants = true;
local hcn = Instance.new("Frame");
hcn.Parent = hsf;
hcn.BackgroundTransparency = 1;
hcn.Position = UDim2.new(0, 0, 0, 0);
hcn.Size = UDim2.new(1, 0, 0, 0);
hcn.ZIndex = 21;
local hll = Instance.new("UIListLayout", hcn);
hll.FillDirection = Enum.FillDirection.Vertical;
hll.SortOrder = Enum.SortOrder.LayoutOrder;
hll.Padding = UDim.new(0, 6);
(hll:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
	hsf.CanvasSize = UDim2.new(0, 0, 0, hll.AbsoluteContentSize.Y + 2);
	hcn.Size = UDim2.new(1, 0, 0, hll.AbsoluteContentSize.Y + 2);
end);
local md = Instance.new("Frame");
md.Parent = m;
md.Visible = false;
md.ZIndex = 200;
md.AnchorPoint = Vector2.new(0.5, 0.5);
md.Position = UDim2.new(0.5, 0, 0.5, 0);
md.Size = UDim2.new(0, 320, 0, 150);
md.BackgroundColor3 = col.panel;
md.ClipsDescendants = true;
local mdc = Instance.new("UICorner", md);
mdc.CornerRadius = UDim.new(0, 12);
local mds = Instance.new("UIStroke", md);
mds.Thickness = 1;
mds.Color = col.st;
mds.Transparency = 0.2;
local mdt = Instance.new("TextLabel");
mdt.Parent = md;
mdt.BackgroundTransparency = 1;
mdt.Position = UDim2.new(0, 14, 0, 10);
mdt.Size = UDim2.new(1, -28, 0, 18);
mdt.Font = Enum.Font.GothamBold;
mdt.Text = "Name";
mdt.TextSize = 14;
mdt.TextXAlignment = Enum.TextXAlignment.Left;
mdt.TextColor3 = col.title;
mdt.ZIndex = 201;
local mdb = Instance.new("TextBox");
mdb.Parent = md;
mdb.BackgroundColor3 = col.btn;
mdb.BorderSizePixel = 0;
mdb.Position = UDim2.new(0, 14, 0, 40);
mdb.Size = UDim2.new(1, -28, 0, 32);
mdb.Font = Enum.Font.Gotham;
mdb.Text = "";
mdb.PlaceholderText = "script name";
mdb.PlaceholderColor3 = col.ph;
mdb.TextColor3 = col.tx;
mdb.TextSize = 14;
mdb.ClearTextOnFocus = false;
mdb.ZIndex = 201;
local mdbc = Instance.new("UICorner", mdb);
mdbc.CornerRadius = UDim.new(0, 10);
local mdbs = Instance.new("UIStroke", mdb);
mdbs.Thickness = 1;
mdbs.Color = col.st;
mdbs.Transparency = 0.25;
local mdf = Instance.new("Frame");
mdf.Parent = md;
mdf.BackgroundTransparency = 1;
mdf.Position = UDim2.new(0, 14, 1, -48);
mdf.Size = UDim2.new(1, -28, 0, 34);
mdf.ZIndex = 201;
local okb = Instance.new("TextButton");
okb.Parent = mdf;
okb.BackgroundColor3 = col.btnA;
okb.BorderSizePixel = 0;
okb.Position = UDim2.new(0, 0, 0, 0);
okb.Size = UDim2.new(0.5, -6, 1, 0);
okb.Font = Enum.Font.GothamSemibold;
okb.Text = "OK";
okb.TextSize = 13;
okb.TextColor3 = col.btnTx;
okb.ZIndex = 202;
local okc = Instance.new("UICorner", okb);
okc.CornerRadius = UDim.new(0, 10);
local oks = Instance.new("UIStroke", okb);
oks.Thickness = 1;
oks.Color = col.st;
oks.Transparency = 0.25;
local cnb = Instance.new("TextButton");
cnb.Parent = mdf;
cnb.BackgroundColor3 = col.btn;
cnb.BorderSizePixel = 0;
cnb.Position = UDim2.new(0.5, 6, 0, 0);
cnb.Size = UDim2.new(0.5, -6, 1, 0);
cnb.Font = Enum.Font.GothamSemibold;
cnb.Text = "Cancel";
cnb.TextSize = 13;
cnb.TextColor3 = col.btnTx;
cnb.ZIndex = 202;
local cnc = Instance.new("UICorner", cnb);
cnc.CornerRadius = UDim.new(0, 10);
local cns = Instance.new("UIStroke", cnb);
cns.Thickness = 1;
cns.Color = col.st;
cns.Transparency = 0.25;
local mdCb = nil;
local function askName(title, cb)
	mdt.Text = title or "Name";
	mdb.Text = "";
	md.Visible = true;
	mdCb = cb;
	if cfg.an then
		md.BackgroundTransparency = 1;
		tw(md, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = cfg.a
		});
	else
		md.BackgroundTransparency = cfg.a;
	end;
	task.defer(function()
		pcall(function()
			mdb:CaptureFocus();
		end);
	end);
end;
local function closeMd(ok)
	md.Visible = false;
	local cb = mdCb;
	mdCb = nil;
	if cb then
		cb(ok, mdb.Text or "");
	end;
end;
okb.MouseButton1Click:Connect(function()
	closeMd(true);
end);
cnb.MouseButton1Click:Connect(function()
	closeMd(false);
end);
local function tabCS()
	local contentX = twp.AbsoluteSize.X;
	local maxX = math.max(0, contentX - tsf.AbsoluteSize.X);
	local cx = tsf.CanvasPosition.X;
	if maxX <= 0 then
		if cx ~= 0 then
			tsf.CanvasPosition = Vector2.new(0, 0);
		end;
		return;
	end;
	if cx < 0 or cx > maxX then
		tsf.CanvasPosition = Vector2.new(math.clamp(cx, 0, maxX), 0);
	end;
end;
local function lh()
	return TSZ + 4;
end;
local CH, eLn, co = "UserScript", nil, nil;
local em = Instance.new("Frame");
em.Name = "EM";
em.Parent = s;
em.BackgroundColor3 = col.err;
em.BackgroundTransparency = 0.85;
em.BorderSizePixel = 0;
em.Visible = false;
em.ZIndex = 2;
local function goLn(n)
	local y = math.max(0, (n - 1) * lh() - s.AbsoluteSize.Y * 0.3);
	s.CanvasPosition = Vector2.new(0, y);
end;
local function syncTab()
	if tabs[cur] then
		tabs[cur].text = t.Text;
	end;
end;
(t:GetPropertyChangedSignal("Text")):Connect(function()
	syncTab();
	schTabs();
end);
uis.InputBegan:Connect(function(i, gpe)
	if gpe then
		return;
	end;
	if i.KeyCode == Enum.KeyCode.Tab and t:IsFocused() then
		local pos = t.CursorPosition or 1;
		local tx2 = t.Text;
		if pos < 1 then
			pos = 1;
		end;
		local pre = tx2:sub(1, pos - 1);
		local suf = tx2:sub(pos);
		t.Text = pre .. "    " .. suf;
		t.CursorPosition = pos + 4;
	end;
end);
local function mkTab(tx2)
	local v = {
		text = tx2 or ""
	};
	local h = Instance.new("Frame");
	h.Parent = twp;
	h.BackgroundColor3 = col.tabI;
	h.BorderSizePixel = 0;
	h.Size = UDim2.new(0, 92, 0, isM and 30 or 24);
	h.ZIndex = 7;
	h.ClipsDescendants = true;
	local hc = Instance.new("UICorner", h);
	hc.CornerRadius = UDim.new(0, 10);
	local hs2 = Instance.new("UIStroke", h);
	hs2.Thickness = 1;
	hs2.Color = col.st;
	hs2.Transparency = 0.3;
	local u = Instance.new("Frame");
	u.Parent = h;
	u.BackgroundColor3 = col.ind;
	u.BorderSizePixel = 0;
	u.AnchorPoint = Vector2.new(0, 1);
	u.Position = UDim2.new(0, 10, 1, -2);
	u.Size = UDim2.new(1, -20, 0, 2);
	u.Visible = false;
	u.ZIndex = 9;
	local uc = Instance.new("UICorner", u);
	uc.CornerRadius = UDim.new(0, 99);
	local b = Instance.new("TextButton");
	b.Parent = h;
	b.BackgroundTransparency = 1;
	b.BorderSizePixel = 0;
	b.AutoButtonColor = true;
	b.Font = Enum.Font.GothamSemibold;
	b.Text = "Tab";
	b.TextSize = 14;
	b.TextColor3 = col.tabTI;
	b.TextXAlignment = Enum.TextXAlignment.Left;
	b.Position = UDim2.new(0, 10, 0, 0);
	b.Size = UDim2.new(1, -38, 1, 0);
	b.ZIndex = 8;
	local x = Instance.new("TextButton");
	x.Parent = h;
	x.BackgroundTransparency = 1;
	x.BorderSizePixel = 0;
	x.AutoButtonColor = true;
	x.Font = Enum.Font.GothamBold;
	x.Text = "X";
	x.TextSize = 12;
	x.TextColor3 = col.tabTI;
	x.AnchorPoint = Vector2.new(1, 0.5);
	x.Position = UDim2.new(1, -8, 0.5, 0);
	x.Size = UDim2.new(0, isM and 22 or 18, 0, isM and 22 or 18);
	x.ZIndex = 9;
	x.Visible = isM;
	if not isM then
		h.MouseEnter:Connect(function()
			x.Visible = true;
		end);
		h.MouseLeave:Connect(function()
			x.Visible = false;
		end);
	end;
	local hscl = Instance.new("UIScale", h);
	hscl.Scale = cfg.an and 0.94 or 1;
	if cfg.an then
		tw(hscl, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1
		});
	end;
	v.h = h;
	v.b = b;
	v.x = x;
	v.u = u;
	v.sc = hscl;
	tabs[(#tabs) + 1] = v;
	tad.LayoutOrder = (#tabs) + 1000;
	return v;
end;
local function renum()
	for i, v in ipairs(tabs) do
		if v and v.h and v.b then
			v.h.LayoutOrder = i;
			local nm = "Tab " .. i;
			v.b.Text = nm;
			local w = (txt:GetTextSize(nm, 14, v.b.Font, Vector2.new(10000, 10000))).X + (isM and 54 or 46);
			local mnw = isM and 120 or 92;
			local mxw = isM and 280 or 220;
			if w < mnw then
				w = mnw;
			end;
			if w > mxw then
				w = mxw;
			end;
			v.h.Size = UDim2.new(0, w, 0, isM and 30 or 24);
		end;
	end;
	tad.LayoutOrder = (#tabs) + 1000;
	task.defer(tabCS);
end;
local function ensureTab()
	local v = tabs[cur];
	if not v or (not v.h) then
		return;
	end;
	task.defer(function()
		if not v.h or (not v.h.Parent) then
			return;
		end;
		local l = v.h.AbsolutePosition.X - tsf.AbsolutePosition.X;
		local r = l + v.h.AbsoluteSize.X;
		local vp = tsf.AbsoluteSize.X;
		local cx = tsf.CanvasPosition.X;
		local pad = 18;
		local nx = cx;
		if l < pad then
			nx = math.max(0, cx + l - pad);
		elseif r > vp - pad then
			nx = math.max(0, cx + (r - (vp - pad)));
		end;
		local maxX = math.max(0, twp.AbsoluteSize.X - tsf.AbsoluteSize.X);
		nx = math.clamp(nx, 0, maxX);
		if math.abs(nx - cx) > 1 then
			if cfg.an then
				tw(tsf, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					CanvasPosition = Vector2.new(nx, 0)
				});
			else
				tsf.CanvasPosition = Vector2.new(nx, 0);
			end;
		end;
	end);
end;
local function refTabs()
	for i, v in ipairs(tabs) do
		if v and v.h and v.b and v.x and v.u then
			local on = i == cur;
			if cfg.an then
				tw(v.h, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					BackgroundColor3 = on and col.tabA or col.tabI
				});
			else
				v.h.BackgroundColor3 = on and col.tabA or col.tabI;
			end;
			v.b.TextColor3 = on and col.tabTA or col.tabTI;
			v.x.TextColor3 = on and col.tabTA or col.tabTI;
			if on then
				v.u.Visible = true;
				if cfg.an then
					v.u.BackgroundTransparency = 1;
					tw(v.u, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0
					});
				else
					v.u.BackgroundTransparency = 0;
				end;
			elseif cfg.an then
				tw(v.u, TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				});
				task.delay(0.14, function()
					if v.u then
						v.u.Visible = false;
					end;
				end);
			else
				v.u.Visible = false;
				v.u.BackgroundTransparency = 1;
			end;
		end;
	end;
	ensureTab();
end;
local function selTab(i)
	if not tabs[i] then
		return;
	end;
	cur = i;
	t.Text = tabs[cur].text or "";
	refTabs();
	schTabs();
end;
local function delTab(i)
	if #tabs <= 1 then
		return;
	end;
	local v = tabs[i];
	if not v then
		return;
	end;
	if v.h then
		if cfg.an and v.sc then
			tw(v.sc, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = 0.85
			});
			tw(v.h, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1
			});
			task.delay(0.14, function()
				if v.h then
					v.h:Destroy();
				end;
			end);
		else
			v.h:Destroy();
		end;
	end;
	table.remove(tabs, i);
	if cur == i then
		if i > (#tabs) then
			i = #tabs;
		end;
		cur = i;
		t.Text = tabs[cur].text or "";
	elseif cur > i then
		cur -= 1;
	end;
	renum();
	tabCS();
	refTabs();
	applyA();
	schTabs();
end;
local function bindTab(v)
	v.b.MouseButton1Click:Connect(function()
		local i = table.find(tabs, v);
		if i then
			selTab(i);
		end;
	end);
	v.x.MouseButton1Click:Connect(function()
		local i = table.find(tabs, v);
		if i then
			delTab(i);
		end;
	end);
end;
local function initTabs()
	if fsOk and isfile(fTab) then
		local ok, raw = pcall(function()
			return readfile(fTab);
		end);
		if ok and raw and raw ~= "" then
			local ok2, dat = pcall(function()
				return hs:JSONDecode(raw);
			end);
			if ok2 and type(dat) == "table" then
				local arr = dat.tabs;
				if type(arr) == "table" and typeof(arr[1]) == "string" then
					for i = 1, #arr do
						local v = mkTab(arr[i] or "");
						bindTab(v);
					end;
				end;
				if #tabs == 0 then
					local v = mkTab("");
					bindTab(v);
				end;
				local ci = type(dat.cur) == "number" and dat.cur or 1;
				if ci < 1 or ci > (#tabs) then
					ci = 1;
				end;
				cur = ci;
				renum();
				tabCS();
				t.Text = tabs[cur].text or "";
				return;
			end;
		end;
	end;
	local v = mkTab("");
	bindTab(v);
	cur = 1;
	renum();
	tabCS();
	t.Text = "";
	schTabs();
end;
tad.MouseButton1Click:Connect(function()
	local v = mkTab("");
	bindTab(v);
	renum();
	tabCS();
	selTab(#tabs);
	applyA();
	schTabs();
end);
tad.MouseEnter:Connect(function()
	if isM or (not cfg.an) then
		return;
	end;
	tw(tadscl, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Scale = 1.05
	});
end);
tad.MouseLeave:Connect(function()
	if isM or (not cfg.an) then
		return;
	end;
	tw(tadscl, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		Scale = 1
	});
end);
local function topH()
	return tb.AbsoluteSize.Y + 2;
end;
local min = false;
local exSz;
local drag, din, ds, sp0 = false, nil, nil, nil;
local userPos = false;
local restorePos = nil;
local fsRestorePos = nil;

local function centerMain(w, h, forceCenter)
	if drag then
		return;
	end;
	local cam = workspace.CurrentCamera;
	if not cam then
		return;
	end;
	if not (forceCenter or (not userPos)) then
		return;
	end;

	local vp = cam.ViewportSize;
	local k = sc and sc.Scale or 1;
	if k <= 0 then
		k = 1;
	end;
	w = w or m.Size.X.Offset;
	h = h or m.Size.Y.Offset;

	local px = vp.X / (2 * k) - w * 0.5;
	local py = vp.Y / (2 * k) - h * 0.5;
	m.Position = UDim2.new(0, math.floor(px + 0.5), 0, math.floor(py + 0.5));
end;
local function tgtSz()
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
	local ins = gsv:GetGuiInset()
	local ux = math.max(0, vp.X - ins.X * 2)
	local uy = math.max(0, vp.Y - ins.Y * 2)
	local availW = math.max(BMIN.X, ux - 12)
	local availH = math.max(BMIN.Y, uy - 12)
	local w, h
	if cfg.fs then
		local scale = cfg.z > 0 and cfg.z or 1
		local targetW = ux
		local targetH = uy
		w = math.max(BMIN.X, math.floor(targetW / scale))
		h = math.max(BMIN.Y, math.floor(targetH / scale))
	else
		local wMul = isM and 0.78 or 0.56
		local hMul = isM and 0.9 or 0.66
		w = math.clamp(ux * wMul, BMIN.X, szc.MaxSize.X)
		h = math.clamp(uy * hMul, BMIN.Y, szc.MaxSize.Y)
	end
	w = math.clamp(w, BMIN.X, math.min(availW, szc.MaxSize.X))
	h = math.clamp(h, BMIN.Y, math.min(availH, szc.MaxSize.Y))
	return w, h
end
local function setVis(v)
	s.Visible = v;
	bf.Visible = v;
	sb.Visible = v;
	d.Visible = v;
	tbar.Visible = v;
	if not v then
		sp.Visible = false;
	end;
end;
local function lay()
	local th, sh = tb.AbsoluteSize.Y, 18;
	local gp = isM and 18 or 10;
	local bh = isM and 54 or 38;
	local tbh = tbar.AbsoluteSize.Y;
	local hubW = cfg.hb and (isM and 260 or 240) or 0;
	local pad = isM and 10 or 12;
	local gapHub = cfg.hb and (isM and 8 or 10) or 0;
	if min then
		setVis(false);
		hp.Visible = false;
	else
		setVis(true);
		hp.Visible = cfg.hb;
		local top = th + tbh + gp;
		local res = bh + gp + sh + gp + 2;
		if cfg.hb then
			hp.Position = UDim2.new(1, -(pad + hubW), 0, top);
			hp.Size = UDim2.new(0, hubW, 1, -(top + res));
		end;
		s.Position = UDim2.new(0, pad, 0, top);
		s.Size = UDim2.new(1, -(pad * 2 + hubW + gapHub), 1, -(top + res));
		bf.Position = UDim2.new(0, pad, 1, -(sh + gp + bh));
		bf.Size = UDim2.new(1, -(pad * 2 + hubW + gapHub), 0, bh);
	end;
	if editorCore and editorCore.refresh then
		editorCore.refresh();
	end;
	tabCS();
	refTabs();
	sb.Position = UDim2.new(0, 14, 1, -22);
	sb.Size = UDim2.new(1, -28, 0, 18);
end;
local function upDrag(i)
	local d2 = i.Position - ds;
	m.Position = UDim2.new(sp0.X.Scale, sp0.X.Offset + d2.X, sp0.Y.Scale, sp0.Y.Offset + d2.Y);
	if min then
		restorePos = m.Position;
	end;
end;
tb.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		drag = true;
		userPos = true;
		ds = i.Position;
		sp0 = m.Position;
		i.Changed:Connect(function()
			if i.UserInputState == Enum.UserInputState.End then
				drag = false;
			end;
		end);
	end;
end);
tb.InputChanged:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		din = i;
	end;
end);
uis.InputChanged:Connect(function(i)
	if drag and i == din then
		upDrag(i);
	end;
end);
(tly:GetPropertyChangedSignal("AbsoluteContentSize")):Connect(function()
	tabCS();
end);
(tsf:GetPropertyChangedSignal("AbsoluteSize")):Connect(function()
	tabCS();
end);
local function upFS()
	szc.MaxSize = cfg.fs and Vector2.new(1000000, 1000000) or MAX0
	local w, h = tgtSz()
	exSz = Vector2.new(w, h)
	if cfg.an then
		tw(m, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, w, 0, h)
		})
	else
		m.Size = UDim2.new(0, w, 0, h)
	end
	if fsRestorePos then
		m.Position = fsRestorePos
		userPos = true
		fsRestorePos = nil
	end
	task.delay(0.02, lay)
end
local function chkErr(msg)
	local ln2 = tonumber((tostring(msg)):match(CH .. ":(%d+):") or (tostring(msg)):match(":(%d+):"));
	if ln2 then
		eLn = ln2;
		em.Size = UDim2.new(0, math.max(0, s.AbsoluteSize.X - 60), 0, lh());
		em.Position = UDim2.new(0, cfg.ln and 46 or 6, 0, (ln2 - 1) * lh());
		em.Visible = true;
		goLn(ln2);
	end;
end;
ex.MouseButton1Click:Connect(function()
	eLn = nil;
	em.Visible = false;
	setStat("Running...", col.warn);
	local f, er = loadstring(t.Text, CH);
	if not f then
		chkErr(er);
		setStat(tostring(er), col.bad);
		return;
	end;
	co = coroutine.create(function()
		local ok, e2 = xpcall(f, function(x)
			return tostring(x) .. "\n" .. debug.traceback(nil, 2);
		end);
		if not ok then
			chkErr(e2);
			setStat(tostring(e2), col.bad);
		else
			setStat("Executed", col.ok, 2);
		end;
		co = nil;
	end);
	task.spawn(function()
		local ok, e2 = coroutine.resume(co);
		if not ok then
			setStat(tostring(e2), col.bad);
		end;
	end);
end);
cl.MouseButton1Click:Connect(function()
	t.Text = "";
	eLn = nil;
	em.Visible = false;
	setStat("Cleared", col.warn, 1.2);
end);
cp.MouseButton1Click:Connect(function()
	local ok = pcall(function()
		setclipboard(t.Text);
	end);
	if ok then
		setStat("Copied", col.ok, 1.6);
	else
		setStat("Copy failed", col.bad);
	end;
end);
nl.MouseButton1Click:Connect(function()
	local tx2 = t.Text or "";
	if not t:IsFocused() then
		t.Text = tx2 .. "\n";
		return;
	end;
	local pos = t.CursorPosition or (#tx2) + 1;
	if pos < 1 then
		pos = 1;
	end;
	local ss2 = t.SelectionStart;
	if ss2 and ss2 > 0 and ss2 ~= pos then
		local a, b = ss2, pos;
		if a > b then
			a, b = b, a;
		end;
		tx2 = tx2:sub(1, a - 1) .. tx2:sub(b);
		pos = a;
	end;
	t.Text = tx2:sub(1, pos - 1) .. "\n" .. tx2:sub(pos);
	t.CursorPosition = pos + 1;
end);
local function hubPath(name)
	name = tostring(name or "");
	name = name:gsub("[\\/:*?\"<>|]", "");
	name = name:gsub("%s+", " ");
	name = (name:gsub("^%s+", "")):gsub("%s+$", "");
	if name == "" then
		name = "script";
	end;
	if not (name:lower()):match("%.lua$") then
		name = name .. ".lua";
	end;
	return sDir .. "/" .. name;
end;
local selFile = nil;
local function hubClear()
	for _, ch in ipairs(hcn:GetChildren()) do
		if not ch:IsA("UIListLayout") then
			ch:Destroy();
		end;
	end;
end;
local function hubRefSel()
	for _, it in ipairs(hcn:GetChildren()) do
		if it:IsA("TextButton") then
			it.BackgroundColor3 = it.Text == selFile and col.btnA or col.hub2;
		end;
	end;
end;
local function hubItem(name)
	local b = Instance.new("TextButton");
	b.Parent = hcn;
	b.BackgroundColor3 = col.hub2;
	b.BorderSizePixel = 0;
	b.AutoButtonColor = true;
	b.Size = UDim2.new(1, 0, 0, 30);
	b.Font = Enum.Font.GothamSemibold;
	b.Text = name;
	b.TextSize = 12;
	b.TextXAlignment = Enum.TextXAlignment.Left;
	b.TextColor3 = col.btnTx;
	b.ZIndex = 22;
	local bc = Instance.new("UICorner", b);
	bc.CornerRadius = UDim.new(0, 9);
	local bs = Instance.new("UIStroke", b);
	bs.Thickness = 1;
	bs.Color = col.st;
	bs.Transparency = 0.3;
	local pad = Instance.new("UIPadding", b);
	pad.PaddingLeft = UDim.new(0, 10);
	pad.PaddingRight = UDim.new(0, 10);
	b.MouseButton1Click:Connect(function()
		selFile = name;
		hubRefSel();
	end);
end;
local function hubRef()
	hubClear();
	selFile = nil;
	if fsOk and listOk then
		local ok, arr = pcall(function()
			return listfiles(sDir);
		end);
		if ok and type(arr) == "table" then
			local names = {};
			for _, p in ipairs(arr) do
				if type(p) == "string" then
					local n = p:match("([^/\\]+)$");
					if n then
						if (n:lower()):match("%.lua$") or (n:lower()):match("%.txt$") then
							table.insert(names, n);
						end;
					end;
				end;
			end;
			table.sort(names, function(a, b)
				return a:lower() < b:lower();
			end);
			for _, n in ipairs(names) do
				hubItem(n);
			end;
		end;
	end;
end;
local function newTabWith(tx2)
	local v = mkTab(tx2 or "");
	bindTab(v);
	renum();
	tabCS();
	selTab(#tabs);
	applyA();
	schTabs();
end;
bO.MouseButton1Click:Connect(function()
	if not fsOk then
		setStat("No filesystem", col.bad, 1.6);
		return;
	end;
	if not selFile then
		setStat("Select a file", col.warn, 1.2);
		return;
	end;
	local p = hubPath(selFile);
	if not isfile(p) then
		setStat("Missing file", col.bad, 1.4);
		return;
	end;
	local raw = readfile(p);
	if type(raw) ~= "string" then
		setStat("Read failed", col.bad, 1.6);
		return;
	end;
	if mode == "Replace" then
		t.Text = raw;
		if tabs[cur] then
			tabs[cur].text = raw;
		end;
		schTabs();
		setStat("Loaded", col.ok, 1.2);
	elseif mode == "Tab" then
		newTabWith(raw);
		setStat("Loaded (new tab)", col.ok, 1.2);
	elseif mode == "Append" then
		t.Text = (t.Text or "") .. raw;
		if tabs[cur] then
			tabs[cur].text = t.Text;
		end;
		schTabs();
		setStat("Appended", col.ok, 1.2);
	end;
end);
hSav.MouseButton1Click:Connect(function()
	if not fsOk then
		setStat("No filesystem", col.bad, 1.6);
		return;
	end;
	if selFile then
		local p = hubPath(selFile);
		local ok2 = pcall(function()
			writefile(p, t.Text or "");
		end);
		if ok2 then
			setStat("Saved", col.ok, 1.2);
			hubRef();
			selFile = selFile;
			hubRefSel();
		else
			setStat("Save failed", col.bad, 1.6);
		end;
		return;
	end;
	askName("Save as", function(ok, name)
		if not ok then
			return;
		end;
		local p = hubPath(name);
		local ok2 = pcall(function()
			writefile(p, t.Text or "");
		end);
		if ok2 then
			setStat("Saved", col.ok, 1.2);
			hubRef();
		else
			setStat("Save failed", col.bad, 1.6);
		end;
	end);
end);
hDel.MouseButton1Click:Connect(function()
	if not fsOk or (not delOk) then
		setStat("No delete", col.bad, 1.6);
		return;
	end;
	if not selFile then
		setStat("Select a file", col.warn, 1.2);
		return;
	end;
	local p = hubPath(selFile);
	local ok = pcall(function()
		delfile(p);
	end);
	if ok then
		setStat("Deleted", col.ok, 1.2);
		hubRef();
	else
		setStat("Delete failed", col.bad, 1.6);
	end;
end);
local function wheelTab(i)
	if isM then
		return;
	end;
	if i.UserInputType ~= Enum.UserInputType.MouseWheel then
		return;
	end;
	local mp = uis:GetMouseLocation();
	local ax = tsf.AbsolutePosition.X;
	local ay = tsf.AbsolutePosition.Y;
	local aw = tsf.AbsoluteSize.X;
	local ah = tsf.AbsoluteSize.Y;
	if mp.X < ax or mp.X > ax + aw or mp.Y < ay or mp.Y > ay + ah then
		return;
	end;
	local dx = (-i.Position.Z) * 70;
	local nx = math.clamp(tsf.CanvasPosition.X + dx, 0, math.max(0, tsf.CanvasSize.X.Offset - tsf.AbsoluteSize.X));
	tsf.CanvasPosition = Vector2.new(nx, 0);
end;
uis.InputChanged:Connect(wheelTab);
fsb.MouseButton1Click:Connect(function()
	cfg.fs = not cfg.fs;
	updFSUI();
	schCfg();
	fsRestorePos = m.Position
	if not min then
		upFS();
	end;
end);
stb.MouseButton1Click:Connect(function()
	sp.Visible = not sp.Visible;
	if sp.Visible then
		if cfg.an then
			sp.BackgroundTransparency = 1;
			tw(sp, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = cfg.a
			});
		else
			sp.BackgroundTransparency = cfg.a;
		end;
	end;
end);
hbb.MouseButton1Click:Connect(function()
	cfg.hb = not cfg.hb;
	updHBUI();
	schCfg();
	if not min then
		lay();
	end;
	if cfg.hb then
		hubRef();
	end;
end);
mn.MouseButton1Click:Connect(function()
	min = not min
	local rot = min and 180 or 0

	if cfg.an then
		tw(mn, TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Rotation = rot
		})
	else
		mn.Rotation = rot
	end

	if min then
		userPos = true
		restorePos = m.Position;
		szc.MinSize = Vector2.new(0, 0)
		if not exSz then
			local w0, h0 = tgtSz()
			exSz = Vector2.new(w0, h0)
		end
		local w = exSz.X
		local th = topH()
		if cfg.an then
			tw(m, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, w, 0, th)
			})
			tw(sc, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = cfg.z * 0.94
			})
			tw(s, TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CanvasPosition = Vector2.new(0, 0)
			})
		else
			m.Size = UDim2.new(0, w, 0, th)
			sc.Scale = cfg.z * 0.94
			s.CanvasPosition = Vector2.new(0, 0)
		end
		task.delay(0.1, function()
			if min then
				setVis(false)
				hp.Visible = false
			end
		end)
	else
		szc.MinSize = BMIN
		szc.MaxSize = cfg.fs and Vector2.new(1000000, 1000000) or MAX0

		local w, h = tgtSz()
		exSz = Vector2.new(w, h)
		setVis(true)

		if restorePos then
			m.Position = restorePos
			userPos = true
			restorePos = nil
		end

		if cfg.an then
			tw(m, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, w, 0, h)
			})
			tw(sc, TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = cfg.z
			})
		else
			m.Size = UDim2.new(0, w, 0, h)
			sc.Scale = cfg.z
		end

		task.delay(0.02, lay)
	end
end)
xt.MouseButton1Click:Connect(function()
	if cfg.an then
		tw(sc, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Scale = cfg.z * 0.9
		});
		tw(m, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		});
		task.delay(0.14, function()
			e:Destroy();
		end);
	else
		e:Destroy();
	end;
end);
local lastCam = nil;
local function bindCam(cam)
	if not cam or cam == lastCam then
		return;
	end;
	lastCam = cam;
	(cam:GetPropertyChangedSignal("ViewportSize")):Connect(function()
		if not min then
			local w, h = tgtSz();
			exSz = Vector2.new(w, h);
			if cfg.an then
				tw(m, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, w, 0, h)
				});
			else
				m.Size = UDim2.new(0, w, 0, h);
			end;
		end;
		lay();
	end);
end;
bindCam(workspace.CurrentCamera);
(workspace:GetPropertyChangedSignal("CurrentCamera")):Connect(function()
	bindCam(workspace.CurrentCamera);
end);
local function first()
	initTabs();
	renum();
	tabCS();
	refMode();
	updFSUI();
	updHBUI();
	updateEditorLayout();
	applyA();
	if cfg.fs then
		szc.MaxSize = Vector2.new(1000000, 1000000);
	else
		szc.MaxSize = MAX0;
	end;
	local w, h = tgtSz();
	exSz = Vector2.new(w, h);
	m.Size = UDim2.new(0, w, 0, h);
	centerMain(w, h, true);
	if editorCore and editorCore.refresh then
		editorCore.refresh();
	end;
	refTabs();
	lay();
	if cfg.hb then
		hubRef();
	end;
end;
first();
